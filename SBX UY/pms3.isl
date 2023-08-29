@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts
// PAGOS ELECTRONICOS
//2.4: MP Uy. cambio de Tender
//2.3: otros errores
//2.2: error en reinitentos
//2.1: agregamo sbux mercadopagoinverso
//2.0: Comenzamos a agregar geocom uruguay
//1.4: agrega mensaje cancelar operacion desde boton y si cambia el precio del ticket. Tambien si el final tender es distinto a ML
//1.3: agregamos un heartbeat y manejo de notas de credito
//1.2: maas opciones de error
//1.1: Control de mandar status si ya tengo un id de trans
//Version 1.0

var gDatos: A1000=""
var gVersion: A14="2.4"
var gStatus: N1 = 0 //0 ok, 1 error comunicacion
var gCodigoRespuesta: A20 = ""
var gDescRespuesta : A100 = ""
var gIdTrans: N12
var gRecursivo: N2=0
var gCaja : A8
Var gTerminal: A20
VAR gTotal:$12
Var KEY_TYPE_MENU_ITEM					: N9 = 3
Var KEY_TYPE_DISCOUNT 					: N9 = 5
Var KEY_TYPE_MENU_SUB_LEVEL                             : N9 = 1
//var g_path  : A128 = "\CF\micros\etc\" 
var g_path  : A128 = "C:\Micros\Res\Pos\Etc\"   
var gPmsNombre :A20="pms3.isl"
var gPmsLineas1[1000] :A200
var gPmsCantLineas1 : N4
var gPmsLineas2[1000] :A200
var gPmsCantLineas2 : N4
var gTouch : N5

var gFechaHoy : A10
var gTiempoIdle : N2
var gTiempoIdleHora : N2

Var gTender:N4
Var gTenderMP:N4=43

Var dll_handle							: N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	

Var gblQRDrv :N12
Var PATH_TO_QR_DRIVER :A100

Var PATH_TO_PRT_DRIVER						:A100				
Var gblPRTDrv 							:N12
Var PCWS_TYPE									:N1 = 1	// Type number for PCWS
Var PPC55A_TYPE 					 			:N1 = 2 // Type number for Workstation mTablet
Var WS4_TYPE									:N1 = 3	// Type number for Workstation 4
Var WS5_TYPE									:N1 = 3	// Type number for Workstation 5
Var gbliWSType				 					:N1			// To store the current Workstation type
Var gbliRESMajVer								:N2			// To store the current RES major version
Var gbliRESMinVer								:N2			// To store the current RES minor version
Var gDBhdl 	: N12
Var gDBPath     : A100="MDSSysUtilsProxy.dll"

VAR gMsr:N1
VAR gMsrMonto:$8
VAR gMsrExito:N1
VAR gQr:N1
VAR gSbxUY:N1

VAR Mensaje:A200
//************************    ******************
Event init
    
    gTouch=@ALPHASCREEN
    call sqlDiaDeNegocio(gFechaHoy)
    call solicitarPms
    @IDLE_SECONDS=60
    gTiempoIdle=@Minute
    gTiempoIdleHora=@Hour
    gIdTrans=-1
    gQr=0
    gTotal=0
    gblQRDrv=0
    gMsr=0
    gMsrMonto=0
    gMsrExito=0
    //call CargarQRDll
    //call FreeDllQR

endevent

Event Begin_Check
    gMsrExito=0
    gTouch=@ALPHASCREEN
    gIdTrans=-1
    gQr=0
    gRecursivo=0
    gTotal=0
    call leerEsMPUruguay
Endevent

Event Idle_No_Trans
    if (gTiempoIdle<>@Minute)
        gTiempoIdle=@Minute
        @IDLE_SECONDS=60
    endif
    if (gTiempoIdleHora<>@Hour)
        call sqlDiaDeNegocio(gFechaHoy)
        call consultarTerminal(0)
        gTiempoIdleHora=@Hour
    endif
endevent

Event Signin
        call sqlDiaDeNegocio(gFechaHoy)
        gIdTrans=-1
        gQr=0
EndEvent

Event inq: 1 //pago mercadopago
    gMsr=0
    gMsrExito=0
    gMsrMonto=0
    call leerEsMPUruguay    
    gTender=gTenderMP  //seteo el tender
    call crearDiaNegocio
    IF (gIdTrans=-1)
        gTotal=@ttldue
        call pagoMercadoPago(0)
    ELSE
        IF (gTotal<>@ttldue)
            call cancelarPago
            gTotal=@ttldue
            gIdTrans=-1
            call pagoMercadoPago(0)
        ELSE
            call consultarStatus
        ENDIF
    ENDIF
endevent

Event inq: 2 //muestro la terminal
    gMsr=0
    gMsrMonto=0
    gMsrExito=0
    call crearDiaNegocio 
    call consultarTerminal(1)  
endevent

Event inq: 3 //cancelar solicitud de pago
    gMsr=0
    gMsrMonto=0
    gMsrExito=0
    IF (gIdTrans<>-1)
        call cancelarPago
        InfoMessage ("SOLICITUD CANCELADA")
    ENDIF 
endevent

Event inq: 4 //mercadopago con lectura QR
    gMsr=0
    gMsrMonto=0
    gMsrExito=0
    call leerEsMPUruguay
    gTender=gTenderMP  //seteo el tender

    //format Mensaje as "Tender: ",gTender
    //InfoMessage(Mensaje)

    call crearDiaNegocio
    gQr=1
    IF (gIdTrans=-1)
        gTotal=@ttldue
        call pagoMercadoPago(1)
    ELSE    
        //un reintento de cobro
        call reintentoMercadoPagoQR
    ENDIF
endevent

EVENT INQ : 11 //llamada desde Rewards para anular recarga
    //call logear("Inq 11: Anular Rewards",1)
    gMsr=1 
    gMsrExito=0
    Window 1,20, gVersion		
		Display 1, 1, "monto: "
                Displayinput 1, 7, gMsrMonto{8},""
    WindowInput	
    WindowClose	

    call pagoMercadoPago(1)
    
    IF (gMsrExito=1) //exito
        //pms2 es 21, inq 22 devuelvo control a rewards
        LoadKybdMacro Key(24, 16384 * 22 + 21)
    ENDIF
    gMsr=0
    gMsrMonto=0
    gMsrExito=0
    //call logear("Inq 11: Fin Anular Rewards",1)
ENDEVENT

Event trans_cncl
    IF (gIdTrans<>-1)
        call cancelarPago
    ENDIF
endevent

Event final_tender
    var i:N3
    var tender:N6
    //veo con cual tender se pago
    IF (gIdTrans<>-1) //hay una solicitud de pago
        FOR i=1 to @NUMDTLT
            IF (@DTL_TYPE[i]="T" AND @DTL_IS_VOID[i] = 0)
               tender=@DTL_OBJECT[i]
            ENDIF
        ENDFOR
        IF (tender<>gTender) //no pague con mercadopago
            call cancelarPago
        ENDIF
    ENDIF
Endevent
//*****************************************************
// Funcion que lee si el tender de MP es de AR o de UY
//*****************************************************
SUB esTenderUY(Ref es,var archivo:A30)
    VAR ConfigFile       : A128       // File Name
    VAR FileHandle       : N5  = 0   // File handle
    es=0
    FORMAT ConfigFile AS g_path, archivo
    FOPEN FileHandle, ConfigFile, READ
    IF FileHandle <> 0
        IF not feof( filehandle)
            FREAD FileHandle, es           
            IF (es<>1 AND es<>2)
             es=0
            ENDIF
        ENDIF
        FCLOSE FileHandle
    ENDIF
ENDSUB


//*****************************************************
// Verificar Tender MP
//*****************************************************
SUB leerEsMPUruguay
   Call setFilePaths
   Call esTenderUY(gSbxUY,"deliverysbx.cfg")
   IF (gSbxUY=2)
      gTenderMP=47 
   ELSE
      gTenderMP=43
   ENDIF
ENDSUB

//*****************************************************
// crear dia de negocio
//*****************************************************
SUB crearDiaNegocio
   IF (gFechaHoy="") 
        call sqlDiaDeNegocio(gFechaHoy)
    ENDIF 
ENDSUB


//************************ Pagos ** ******************************
//Procesa pagos
//****************************************************************
sub pagoMercadoPago(VAR porqr:N1)
    VAR numcobro:A16="0|"
    VAR auxcobro:A16=""
    VAR respuesta:N1=0
    VAR total:$12=0
    VAR comando:A20="PAGO"
    Var auxqr               :A1024=""
    Var resqr               :N2=0

    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    IF (porqr=1)
        comando="PAGOINVERSO"
    ENDIF
    total=@ttldue
    IF (gMsr=1)
        total=gMsrMonto*(-1)
    ENDIF
    
    IF (total<0)
        call consultarCodigo(auxcobro,"INGRESE NUMERO DE COBRO")
        format numcobro as auxcobro,"|"
        total=total*(-1)
        IF (porqr=1)
            comando="DEVOLUCIONINVERSO"
        ELSE
            comando="DEVOLUCION"
        ENDIF
    ENDIF
    IF (porqr=1)
        call leerTextoQR(auxqr,resqr)
        IF ((resqr>0) and (auxqr<>""))
            format gDatos as comando,"|",@WSID,"|MERCADOPAGO|",gVersion,"|",@cknum,"|",total,"|",@RVC,"|",gFechaHoy,"|",numcobro,"|",auxqr
            call EnviaTransaccion
            call RecibeTransaccion
            call procesarRespuestaPago
        ENDIF
    ELSE
        format gDatos as comando,"|",@WSID,"|MERCADOPAGO|",gVersion,"|",@cknum,"|",total,"|",@RVC,"|",gFechaHoy,"|",numcobro
        call EnviaTransaccion
        call RecibeTransaccion
        call procesarRespuestaPago

    ENDIF
    

    
endsub

//************************ Pagos ** ******************************
//Consulta pagos inverso
//****************************************************************
sub reintentoMercadoPagoQR
    VAR numcobro:A16="0|"
    VAR auxcobro:A16=""
    VAR respuesta:N1=0
    VAR total:$12=0
    VAR comando:A20="PAGO"
    Var auxqr               :A1024=""
    Var resqr               :N2=0

    auxqr="1"
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    comando="PAGOINVERSO"
    total=@ttldue
    IF (gMsr=1)
        total=gMsrMonto*(-1)
    ENDIF
    
    IF (total<0)
        numcobro="0|"
        total=total*(-1)
        comando="DEVOLUCIONINVERSO"
    ENDIF
    format gDatos as comando,"|",@WSID,"|MERCADOPAGO|",gVersion,"|",@cknum,"|",total,"|",@RVC,"|",gFechaHoy,"|",numcobro,"|",auxqr
    call EnviaTransaccion
    call RecibeTransaccion
    call procesarRespuestaPago
      
endsub
//************************ Pagos ** ******************************
//Status transaccion
//****************************************************************
sub consultarStatus
    gCodigoRespuesta = ""
    gDescRespuesta  = ""

   
    format gDatos as "STATUS|",@WSID,"|MERCADOPAGO|",gVersion,"|",gIdTrans
    

    call EnviaTransaccion
    call RecibeTransaccion
    call procesarRespuestaPago

endsub
//************************ Pagos ** ******************************
//Status transaccion
//****************************************************************
sub cancelarPago
    gCodigoRespuesta = ""
    gDescRespuesta  = ""

   
    format gDatos as "CANCELAR|",@WSID,"|MERCADOPAGO|",gVersion,"|",gIdTrans
    

    call EnviaTransaccion
    call RecibeTransaccion
    gIdTrans=-1
   // call procesarRespuestaPago

endsub
//************************ Pagos ** ******************************
//muestra el numero de terminal
//****************************************************************
sub consultarTerminal(VAR mostrar:N1)
    VAR aux:A20=""
    VAR trans:N12=0
    gDescRespuesta  = ""
    
   
    format gDatos as "TERMINAL|",@WSID,"|MERCADOPAGO|",gVersion,"|"
    

    call EnviaTransaccion
    trans=gIdTrans
    call RecibeTransaccion
    gIdTrans=trans
    IF (mostrar=1)
        format aux as "TERMINAL: ",gDescRespuesta
        call mostrarMensaje(aux)
    ENDIF
    

endsub
//************************  Pagos ******************************
//Envia transaccion al servidor central
//****************************************************************
sub EnviaTransaccion
	gStatus=0
	TXMSG gDatos //Manda los datos al puerto que definimos
	//ErrorMessage "Enviado"
	GetRXMsg "Esperando Respuesta de Servicio" //Estado de espera
endsub
//************************* Pagos ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccion
        var mensaje: A170=""
        var jj: N2

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE PAGOS"
           gStatus=1

	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gIdTrans
          
	endif

endsub

//************************* PAGOS  *****************************
//Dispatcher de respuestas de PAGOS
//****************************************************************
Sub procesarRespuestaPago
    VAR respuesta:N1=0

    IF (gCodigoRespuesta="1") //Respuesta OK
        LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, gTender)  //aplico el pago
    ELSEIF (gCodigoRespuesta="2") //reintento transaccion en progreso
        call consultarsino(respuesta, "Pago en progreso: Desea esperar?")
        IF (respuesta=1)
            gRecursivo=gRecursivo+1
            IF (gRecursivo<10)
                call consultarStatus
            ELSE
                gRecursivo=0
                InfoMessage ("Mercado Pago: Realice el cobro nuevamente")
                //call cancelarPago
            ENDIF
        ELSE
            //call cancelarPago
        ENDIF
    ELSEIF (gCodigoRespuesta="3") //reintento esperando aprobacion cliente
        call consultarsino(respuesta, "Cliente: Necesita mas tiempo?")
        IF (respuesta=1)
            gRecursivo=gRecursivo+1
            IF (gRecursivo<10)
                call consultarStatus
            ELSE
                gRecursivo=0
                InfoMessage ("Mercado Pago: Realice el cobro nuevamente")
                //call cancelarPago
            ENDIF
        ELSE
            //call cancelarPago
        ENDIF
    ELSEIF (gCodigoRespuesta="4")  //pedir otro medio de pago      
        IF (gQr=1)
            gIdTrans=-1 
        ENDIF
        call mostrarMensaje(gDescRespuesta)
    ELSEIF (gCodigoRespuesta="5")  //cancelaciones
        
        gRecursivo=0
        gIdTrans=-1
        InfoMessage ("Mercado Pago: Operacion Cancelada")
    ELSEIF (gCodigoRespuesta="6")  //nota de credito ok       
        gRecursivo=0
        gIdTrans=-1
        InfoMessage ("Mercado Pago: Devolucion aprobada")
        gMsrExito=1
        IF (gMsr=0)
            LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, gTender)  //aplico el pago
        ENDIF
    ELSE
        call mostrarMensaje(gDescRespuesta)
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ENDIF

endsub
//******************************************************************
// Cargar sucursal
//******************************************************************
SUB GetSucursal
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    gTerminal="VACIO"
    FORMAT ArchConfig AS g_path, "GEOCOM",@WSID, ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, gTerminal
       FCLOSE Handle
    ELSE
        ErrorMessage "ERROR: No se pudo acceder al numero de terminal Geocom"
    ENDIF
ENDSUB
//************************************** ************************
//Muestra mensaje en pantalla
//*****************************************************************
Sub mostrarMensaje(Var mensaje:A170)
    var aux: A170=""
    format aux as "Mensaje (Version: ",gVersion,")"
    InfoMessage aux,mensaje
endsub
//************************** GENERAL ************************
//Consulta Enter o Clear en pantalla
//*****************************************************************
Sub consultarMensaje(Var mensaje:A170,ref respuesta)
   
    Var iOption 		: N1
    Var kKeyPressed		: Key
    Var opcion                  : A1
    respuesta=0

   // getenterorclear respuesta,mensaje
   // si apreto ok continua si cancel termina
    Window 2,65, "Consulta Aceptar o Cancelar"
		
      Display 1,1,mensaje
      DisplayInput 1, len(mensaje)+2, opcion{1},""
    WindowEdit	
    WindowClose	
    respuesta=0
    if opcion="s"
        respuesta=1
    endif

endsub
//*************************** GENERAL *****************************
// Ingreso de codigo
// ****************************************************************
Sub consultarCodigo(Ref codigoIngresado_,Var titulo:A25)
        Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A20
        Var mensaje             : A20
	var indice		: N2

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	
	Window 2,50, "Ingresar"
		
		Display 1, 1, titulo
		Display 2, 1, mensaje
                DisplayMSinput 1, len(titulo)+1, codigoIngresado{m1, 1, 1, 16}," "

	WindowEdit	
	WindowClose	
	
	Format codigoIngresado_ 	As Trim(codigoIngresado)

EndSub
//***********************************************
sub consultarsino( ref answer, var prompt_s:A38 )
    var keypress : key
    var data : A20

    clearislts

    SetIslTsKeyx  1,  1, 4, 30, 7, @Key_HOME, 0, "L", 3, prompt_s
    SetIslTsKeyx  5,  1, 6, 15, 7, @Key_Enter, 10059, "L", 4, "Si"
    SetIslTsKeyx  5, 16, 6, 15, 7, @Key_Clear, 10058, "L", 2, "Cancelar"

    displayislts
    inputkey keypress, data, prompt_s
    if keypress = @Key_Enter
        answer = 1
    else
        answer = 0
    endif
    ClearIslTs
endsub 
// ********************* GENERALES ***********
// Funcion que graba el pms4
// ************************************************
SUB grabarPms
    VAR ConfigFile       : A128       // File Name
    VAR FileHandle       : N5  = 0   // File handle
    VAR i : N4 = 1
    VAR auxwrite : N4
    Var aux : A300

    FORMAT ConfigFile AS g_path, gPmsNombre
    FOPEN FileHandle, ConfigFile, WRITE
 
    IF FileHandle <> 0
       FOR i=1 to gPmsCantLineas1
           
            FWriteBfr FileHandle, gPmsLineas1[i],len(gPmsLineas1[i]), auxwrite 
            FWriteBfr FileHandle, chr(13),1, auxwrite 
            FWriteBfr FileHandle, chr(10),1, auxwrite 
       ENDFOR
       FOR i=1 to gPmsCantLineas2
            
            FWriteBfr FileHandle, gPmsLineas2[i],len(gPmsLineas2[i]), auxwrite 
            FWriteBfr FileHandle, chr(13),1, auxwrite 
            FWriteBfr FileHandle, chr(10),1, auxwrite 
       ENDFOR
       FCLOSE FileHandle
       
    ENDIF
ENDSUB
//************************ GENERALES *******************************
//Solicita si hay nuevo pms5
//****************************************************************
sub solicitarPms
    gPmsCantLineas1=0
    gPmsCantLineas2=0
    ClearArray gPmsLineas1
    ClearArray gPmsLineas2

    format gDatos as "PMS-1|",@WSID,"|",gVersion
    call EnviaTransaccion
    //call RecibeTransaccionPms
    if @RxMsg = "_timeout" //Llega la Respuesta
	else
           if (@RxMsg<>"NOPMS")
                Split @RxMsg, chr(33), gPmsCantLineas1,gPmsLineas1[]  
                if (gPmsCantLineas1=800)
                    
                    format gDatos as "PMS-2|",@WSID,"|",gVersion
                    //InfoMessage "2",gDatos
                    call EnviaTransaccion
                    //InfoMessage "3",gDatos                   
                     if @RxMsg = "_timeout" //Llega la Respuesta
                     else
                        if (@RxMsg<>"NOPMS")
                            Split @RxMsg, chr(33), gPmsCantLineas2,gPmsLineas2[] 
                            //InfoMessage gPmsLineas2[gPmsCantLineas2+1]
                            //InfoMessage gPmsLineas2[gPmsCantLineas2]
                            call grabarPms
                        endif
                     endif
                elseif (gPmsCantLineas1<800 and gPmsCantLineas1>10)
                    call grabarPms
                endif
           endif
    endif
endsub
//************************* GENERALES ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionPms

       InfoMessage "pms"
        
	if @RxMsg = "_timeout" //Llega la Respuesta
	else
           if (@RxMsg<>"NOPMS")
            
            InfoMessage "pms",len(@RxMsg)
            
            Split @RxMsg, chr(33), gPmsCantLineas,gPmsLineas[]  
         
            if (gPmsCantLineas>0 )//llego un archivo
                 call grabarPms
            endif
           else
            InfoMessage @RxMsg
           endif
	endif
	
endsub
//******************************************************************
// Load FCR DLL
//******************************************************************
Sub cargarDllImpresora

    If ( dll_handle = 0 )
        DLLLoad dll_handle,  "\cf\micros\bin\FCRDriver.dll"
    EndIf
  
    If dll_handle = 0
        ErrorMessage "No se puede cargar driver de impresora"
    EndIf

EndSub
//******************************************************************
// Procedure: setWorkstationType()
//******************************************************************
Sub setWorkstationType
	
	// get RES major & minor version
	Split @VERSION, ".", gbliRESMajVer, gbliRESMinVer

	// set workstation type

	If gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		gbliWSType = @WSTYPE
	Else
		// older versions don't support the
		// "@WSTYPE" system variable
		gbliWSType = 1  // PCWS as default
	EndIf
	
EndSub
//******************************************************************
// Procedure: 	SetFilePaths() 
//******************************************************************
Sub SetFilePaths		
	// general paths
        call setWorkstationType
	If gbliWSType = PCWS_TYPE
		// This is a Win32 client
                Format PATH_TO_QR_DRIVER As "..\bin\TWS.QRInputW32.dll"
	ElseIf gbliWSType = WS5_TYPE		
                Format PATH_TO_QR_DRIVER As "CF\micros\bin\TWS.QRInputWCE.dll"
        Else
		// This is a WS4 client	WinCE 4.2	
                Format PATH_TO_QR_DRIVER As "CF\micros\bin\TWS.QRInputWCE.dll"
        EndIf		
EndSub

//************************* PULL ******************************
//Valida que hay lugar ante de pull
//****************************************************************
Sub sqlDiaDeNegocio(Ref fecha)

	Var dbok     	: N1
	Var comando     : A300= ""
	Var resultado	: A20= ""
	Var error	: A200= ""
        var aux :A10=""
        
        gDBhdl=0
        Call ODBCinit
	Call ODBCconvalida(dbok)
	If dbok
 		Format comando As "SELECT left(business_date,10) as fecha FROM micros.rest_status"
		
                DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comando) 
                DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
		If (error="")
                    DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 
                    
                    Split resultado, ";",aux
                    if (aux<>"") 
                        fecha=aux
                    ELSE
                        ErrorMessage "PMS3: DiaDeNegocio: Fecha vacia"
                    endif	
		Else 	
                    
                    ErrorMessage "PMS3: DiaDeNegocio: Error al obtener sql"
                    ErrorMessage error
		Endif	
                call ODBCbaja
	Else
            ErrorMessage "PMS3: DiaDeNegocio: Error al conectar BD"
	Endif		
EndSub
//************************* BD ******************************
//Leo driver BD
//****************************************************************
Sub ODBCinit

	Var error	: A500 = ""

	If (gDBhdl=0)
            DLLLoad gDBhdl, gDBPath
        EndIf
	If (gDBhdl=0)
		ErrorMessage "REWARDS: Error al cargar BD"
        Else
            Call ODBCConexion()
            DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
            If error <> ""
                    ErrorMessage "REWARDS: Error al init conexion BD"
            EndIf
        EndIf	
EndSub

//************************* BD ******************************
//baja driver BD
//****************************************************************
Sub ODBCbaja

	If (gDBhdl<>0)

		Call ODBCcerrarconexion()
		DLLFree gDBHdl
		gDBHdl = 0
	EndIf
EndSub
//************************* BD ******************************
//inicializo conexion
//****************************************************************
Sub ODBCConexion()
        DLLCall_CDECL gDBhdl, sqlInitConnection("micros","ODBC;UID=custom;PWD=custom", "")
EndSub

//************************* BD ******************************
//ejecuto consulta sql
//****************************************************************
Sub ODBCQuery( ref comando_ )
	DLLCall_CDECL gDBhdl, sqlExecuteQuery(ref comando_) 
EndSub
//************************* BD ******************************
//cerrar conexion
//****************************************************************
Sub ODBCcerrarconexion()
    DLLCall_CDECL gDBhdl, sqlCloseConnection()
EndSub
//************************* BD ******************************
//valida si estoy conectado
//****************************************************************
Sub ODBCconvalida(ref res_)

	var status	: N4
	var error       : A500 = ""

	If (@INSTANDALONEMODE = 0) And (@INBACKUPMODE = 0)

                DLLCall_CDECL gDBhdl, sqlIsConnectionOpen(ref status)
		If status =  0
                    //no hay conexion
                    Call ODBCConexion()
                    DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
                    If (error<>"")	
                        res_=0
                        Call ODBCcerrarconexion()
                    Else				
                        res_=1
                    Endif	
		Else		
                    res_=1
		EndIf
	Else
            res_=0
            Call ODBCcerrarconexion()
	Endif
EndSub
//******************************************************************
// Procedure: 	ingresarTextoQR()
//******************************************************************
Sub leerTextoQR(ref buffer,ref res)

	//Var buffer 		:A1024
	//Var res 		:N18

        call cargarQRDll
        res=0
        buffer=""
        DLLCall_CDecl gblQRDrv, InputDialog("Scanee MercadoPago",Ref buffer, 1024, Ref res)

	If res = 0 
		If Trim(buffer) <> "" 
			//ERROR 
			ErrorMessage "Error:", Mid(buffer, 1, 70) 
		Else
			//Cancalado
			ErrorMessage "Operacion cancelada" 
				
		EndIf	
			
	EndIf	
        call FreeDllQR
EndSub

//******************************************************************
// Procedure: CargarQRDll() para QR
//******************************************************************
Sub CargarQRDll
	Var retMessage :A512
        Var i:N1=0
        Var dllok:N1=0
        gblQRDrv=0
	call SetFilePaths
	DLLLoad gblQRDrv, PATH_TO_QR_DRIVER
        

	If gblQRDrv = 0
		InfoMessage "MP por QR","ERROR DRIVER: No se puede cargar driver QR MPAGO" 
        
        EndIf    	
EndSub
//******************************************************************
// Procedure: 	FreeDllQR()
//******************************************************************
Sub FreeDllQR
	If(gblQRDrv <> 0)
		DLLFree gblQRDrv
		gblQRDrv = 0
	EndIf
EndSub