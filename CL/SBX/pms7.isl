@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts

//version 9.1: control descuento empleados local chile
//version 9.0: deshabilitamos sbux cv
//version 8.9: mas codigos clarin
//version 8.8: agregamos codificaciones Clarin
//version 8.7 inq para operaciones por dia de la semana,agregamos Win32 a los tipo de pos
//version 8.6 arregla BENEFEMP el caso que si no hay nada para descontar queda abierto por enviar 0
//version 8.5 agregar lectura de track 2 para ciertas promociones con nuevo inq 18
//version 8.4 arregla bug de opciones y dentro BENEFEMP
//version 8.3 arregla descuento de empleados BENEFEMP
//version 8.2 calculo de descuento en fidelidad, validacion de que no haya un descuento previo
//version 8.1 bug de cvpais
//version 8.0 Soporte para comunicaciones con POS
//version 7.6 CV Uruguay
//version 7.5 control de productos en descuentos
//version 7.4 habilita registry CAL
//version 7.3 control cuenta en 0
//version 7.2 largo descuento
//version 7.1 control de caja asignada
//version 7.0 promocion parrilla
//version 6.4 referencia en item adicional
//version 6.3 funcion poner en hora la fiscal
//version 6.2 duplicacion en CV
//version 6.1 soluciona de nuevo el if 122
//Version 6.0 solucooa buf if
//Version 5.9 muestra e imprime cv
//Version 5.8 soluciona bug codigo cv.
//Version 5.7 soluciona liberar puerto fiscal
//Version 5.6 agregar impresión de invitación CV por fiscal
//Version 5.5 soluciona problema de 5.4 de dos items de 0,01
//Version 5.4 agrega descuentos de empleados multiple opciones

var gFrecuencia: N5 // = 2
var gCodigoIngresado: A20 = ""
var gCodigoGiftCard : A30 = ""
var gDatos: A1000=""
var gVersion: A14="9.1"
var gChile:N1=0  
var gStatus: N1 = 0 //0 ok, 1 error comunicacion
var gCodigoRespuesta: A20 = ""
var gDescRespuesta : A100 = ""
var gTipoCampana : A10 = ""
var gCodigoMicros : A16 = ""
var gCodigoMicrosNivel : N1
var gCodigoAdicional : A16 = ""
var gCodigoProducto : A16=""
var gNombreEmpleado: A50=""
var gDescVariable: A16=""
var gIdEmpleado : A20=""
var gEnTicket : N1 //=0
var gTouch : N5
var gTiendaCV : A6=""
var gProductos[20] : A40
var gCodigos[20] : A40
var gCodigosNivel[20] : N1
var gContadorOff : N4 
var gOffCamp[300] : A20
var gOffTipo[300] : N3
var gOffLen[300] : N3
var gOffCodMicros[300] : N10
var gOffCodMicrosNivel[300] : N1
var gOffRvc[300] : N2
var gOffRecibido : N1
var gOffCodIngresados[100] : A20
var gOffCodIngresadosNivel[100] :A1
var gOffCantCodIngresados : N3
var gContadorProd : N2 = 0
var gCaja : A8
var gOffline: N1
var gMaxCodigosOffline : N3=99
Var KEY_TYPE_MENU_ITEM					: N9 = 3
Var KEY_TYPE_DISCOUNT 					: N9 = 5
Var KEY_TYPE_MENU_SUB_LEVEL                             : N9 = 1
var g_path  : A128 = "\CF\micros\etc\" //:A128="d:\Micros\Res\Pos\Etc\"   
var gPmsNombre :A20="pms5.isl"
var gPmsLineas1[1000] :A200
var gPmsCantLineas1 : N4
var gPmsLineas2[1000] :A200
var gPmsCantLineas2 : N4
var gVersionCampanas : N4
var gCodigoProdCustomer : N6=900061   //Colombia: 51955 - Argentina: 900061
var gCodigoCVPais: N2  //Colombia: 57 - Argentina: 49
var gGiftCardSaldo : $7
var gImprimeCV : N1=1 //1 si imprime por fiscal la invitacion, 0 por pantalla
var gIdComunicacion :N5
var gTiempoIdleHora:N2
var gUltMinComunicacion:N5

Var dll_handle							: N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	

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
//************************ CUSTOMER VOICE   ******************
Event init
    
    gOffRecibido=1
   // @idle_seconds=7200
    gTouch=@ALPHASCREEN
    gFrecuencia=200
    gEnTicket=0
    gContadorOff=0
    gIdComunicacion=0
    gOffCantCodIngresados=0
    ClearArray gOffCodIngresados
    gCaja="NAN"
    gVersionCampanas=0
    call darModeloCaja
    IF gCaja<>"WS4"
       IF (gChile=0)
         call habilitarCal
       ENDIF
    ENDIF
    gCodigoCVPais=0
    //CV call recibeFrecuenciaCV
    //CV call recibePaisCV
    //call recibeFrecuenciaOffline
    call solicitarCampanasOffline
    call solicitarPms
    call recibeComunicacion
    gTiempoIdleHora=@Hour
    @IDLE_SECONDS=60
    gUltMinComunicacion=@Hour*60+@Minute
endevent

Event Begin_Check
    VAR aux:N5

   //CV  IF (gCodigoCVPais=0)
   //CV       call recibePaisCV
   //CV  ENDIF
    gTouch=@ALPHASCREEN
    gEnTicket=0
    call enviarCodigosOffline
    aux=@Hour*60+@Minute
    IF ((aux-gUltMinComunicacion)>30)
        call recibeComunicacion
        gUltMinComunicacion=aux
    ELSEIF (aux<gUltMinComunicacion)
        gUltMinComunicacion=aux   
    ENDIF
Endevent

Event Idle_No_trans
    VAR aux:N5
    aux=@Hour*60+@Minute

    IF ((aux-gUltMinComunicacion)>30)
        call recibeComunicacion
        gUltMinComunicacion=aux
    ELSEIF (aux<gUltMinComunicacion)
        gUltMinComunicacion=aux   
    ENDIF

Endevent

Event inq: 1
    var dia: A2=""
    var mes: A2=""
    var hora: A2=""
    var caja: A9=""
    var mensaje: A170=""
    var cheque: A10=""
    var trans: A10=""
    var survey: N1=0
    var serial: A4=""
    var haydesc : N1=0
    gCodigoRespuesta=""
    gDescRespuesta= ""
    gTipoCampana= ""
    gCodigoMicros= ""
    gCodigoProducto=""
    gTouch=@ALPHASCREEN
    //format mensaje as "Frec=",gFrecuencia," enticket=",gEnTicket," trans=",@trans_number
    //InfoMessage mensaje

    
    IF ((gEnTicket=0) and (gCodigoCVPais>0))
        //call darFrecuencia
        if (gFrecuencia=0)
            gFrecuencia=200
        endif
        
        if ((@trans_number % gFrecuencia)=0) 
            call hayDescuentos(haydesc)
            if (haydesc=0)
                   survey=1
                  if (@trans_number % 1000)<10
                        format serial as "00",@trans_number % 1000
                  elseif (@trans_number % 1000)<100
                        format serial as "0",@trans_number % 1000
                  else
                        format serial as @trans_number % 1000
                  endif


                dia=@Day
                mes=@Month
                hora=@Hour
                caja=@Wsid
                cheque=@cknum
                trans=@trans_number



                //if (Len(caja)<2)
                //    format caja as "0",@Wsid
                //endif
                if (len(caja)>1)
                    format caja as "0"
                endif
                if (Len(dia)<2) 
                    Format dia as "0",@Day
                endif
                if (Len(mes)<2) 
                    Format mes as "0",@Month 
                endif
                if (Len(hora)<2) 
                    Format hora as "0",@Hour 
                endif
                call darModeloCaja

                //format gCodigoIngresado as serial,"1",mes,dia,hora,gCodigoCVPais
                format gCodigoIngresado as serial,caja,mes,dia,hora,gCodigoCVPais
                call enviaCodigoCV

                IF (gCodigoRespuesta="1")
                   // format mensaje as "Codigo Customer Voice: ",gTiendaCV," ",serial,"  ",mes,"  ",dia, "  ",hora
                    format mensaje as "Codigo Customer Voice: ",gTiendaCV," ",serial,caja,mes,"  ",dia, "  ",hora
                    IF (gImprimeCV)
                       // format gCodigoIngresado as gTiendaCV,serial,"1",mes,dia,hora,gCodigoCVPais
                        format gCodigoIngresado as gTiendaCV,serial,caja,mes,dia,hora,gCodigoCVPais
                        call imprimirCV(gCodigoIngresado)
                    ENDIF
                    InfoMessage "Customer Voice",mensaje

                    LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoProdCustomer)
                    gEnTicket=1
                ELSEIF (gCodigoRespuesta<>"4")

                ENDIF
           ENDIF
        ENDIF
   ENDIF
endevent

Event inq: 2
     var mensaje: A50=""
     //call darFrecuencia
     format mensaje AS "Version: ",gVersion," Frecuencia=",gFrecuencia
     ErrorMessage mensaje
endevent

Event inq: 3
     gTouch=@ALPHASCREEN
     call redimirCV
endevent

//*********************** CUPONES  **************************
Event inq: 5 
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(0,"",1)
endevent

Event inq: 6  //ingreso con tarjeta banda 1
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(1,"",1)
endevent

Event inq: 7  //evaluabk
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(0,"EVK",1)
endevent

Event inq: 8  //jumbochk
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(0,"JUM",1)
endevent

// inq para BKFree
Event inq: 4 //cambiar
    //gTouch=1010
    gTouch=@ALPHASCREEN
    call darModeloCaja
   // call procesaGiftCard
    call procesaCupones(0,"",1)
endevent
//*********************** DESC EMPLEADOS  **************************
Event inq: 9 
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaDescEmpleados
endevent
//*********************** VOUCHERS  **************************
Event inq: 10 
   // LoadKybdMacro Key(KEY_TYPE_DISCOUNT,  200), MakeKeys("50"), @KEY_ENTER
    call darModeloCaja
    call procesaVouchers
endevent

//*********************** CLARIN 365  **************************
Event inq: 11 
    Var esClasica: n1
    esClasica=-1
    call darModeloCaja
    call procesaClarin365(esClasica)
    IF (esClasica=-1) 
	errorMessage "CLARIN 365: TARJETA INVALIDA"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ELSEIF (esClasica=0) 
	LoadDBKybdMacro 9100
    ELSEIF (esClasica=1) 
	errorMessage "CLARIN 365: SOLO TARJETAS CLASICAS"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ENDIF
endevent
//*********************** CLARIN 365 PLUS  **************************
Event inq: 12 
    Var esClasica: n1
    esClasica=-1
    call darModeloCaja
    call procesaClarin365(esClasica)
    IF (esClasica=-1) 
	errorMessage "CLARIN 365: TARJETA INVALIDA"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ELSEIF (esClasica=0) 
	errorMessage "CLARIN 365: SOLO TARJETAS PLUS"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ELSEIF (esClasica=1) 
	LoadDBKybdMacro 9100
    ENDIF
endevent
//*********************** SUBE  **************************
Event inq: 13
    Var esSube: n1
    esSube=-1
    call darModeloCaja
    call procesaSube(esSube)
    IF (esSube=-1) 
	errorMessage "SUBE: TARJETA INVALIDA"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ELSEIF (esSube=1) 
	LoadDBKybdMacro 9100
    ENDIF
endevent
//*********************** GIFTCARD ************************
Event inq: 14
    gTouch=@ALPHASCREEN
    call darModeloCaja
    // consulta de saldo
    call procesaGiftCard(1)
endevent

Event inq: 15
    gTouch=@ALPHASCREEN
    call darModeloCaja
    // pagar ticket
    call procesaGiftCard(0)
endevent
//********************* Datos Promociones ***************************
Event inq: 16
    call ingresoDatosParrila
endevent
//********************* Caja asignada ***************************
Event inq: 17
    IF (@cashdrawer=0 and @Emplopt[4]=0)
        ExitWithError ("ERROR: NO TIENE ASIGNADA LA CAJA")
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ELSEIF (@TTLDUE=0)
        ExitWithError ("ERROR: CUENTA EN 0. NO ES POSIBLE IR A PAGOS")
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ENDIF
endevent
//********************* Cupones ***************************

Event inq: 18  //ingreso con tarjeta banda 2
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(1,"",2)
endevent
//********************** Descuentos Empleado **************
Event inq: 19
    //descobj,limitediario,limite en dinero, descuento
    call aplicaDescuentoLocal(224,3,7800,50)
endevent

Event inq: 20
    //descobj,limitediario,limite en dinero, descuento
    call aplicaDescuentoLocal(204,2,11040,100)
endevent

//*********************** UTILIDADES *******************************
Event inq: 30 //poner en hora la fiscal, se llama desde una macro
    Call setWorkstationType()
    Call setFilePaths()
    call SyncDateTime
Endevent
//*********************** DIAS *******************************
Event inq: 40 //Permite Lunes
   IF (@weekday<>1)
        ErrorMessage "Dia no permitido (solo Lunes)"
   ENDIF
Endevent
Event inq: 41 //Permite Martes
   IF (@weekday<>2)
        ErrorMessage "Dia no permitido (solo Martes)"
   ENDIF
Endevent
Event inq: 42 //Permite Miercoles
   IF (@weekday<>3)
        ErrorMessage "Dia no permitido (solo Miercoles)"
   ENDIF
Endevent
Event inq: 43 //Permite Jueves
   IF (@weekday<>4)
        ErrorMessage "Dia no permitido (solo Jueves)"
   ENDIF
Endevent
Event inq: 44 //Permite Viernes
   IF (@weekday<>5)
        ErrorMessage "Dia no permitido (solo Viernes)"
   ENDIF
Endevent
Event inq: 45 //Permite Sabado
   IF (@weekday<>6)
        ErrorMessage "Dia no permitido (solo Sabado)"
   ENDIF
Endevent
Event inq: 46 //Permite Domingo
   IF (@weekday<>0)
        ErrorMessage "Dia no permitido (solo Domingo)"
   ENDIF
Endevent
Event inq: 47 //6 a 12
   IF (@hour<6 and @hour>=12)
        ErrorMessage "Horario no permitido (6 a 12)"
   ENDIF
Endevent
Event inq: 48 //12 a 15
   IF (@hour<12 and @hour>=15)
        ErrorMessage "Horario no permitido (12 a 15)"
   ENDIF
Endevent
Event inq: 49 //15 a 18
   IF (@hour<15 and @hour>=18)
        ErrorMessage "Horario no permitido (15 a 18)"
   ENDIF
Endevent
Event inq: 50 //18 a 24
   IF (@hour<18)
        ErrorMessage "Horario no permitido (18 a 24)"
   ENDIF
Endevent
//*********************** UTILIDADES *******************************
Sub habilitarCal //habilita CAL
    Var errMsg   :A1024
    Var dataType:A50
    Var value:A50
    Var HKLM: N9 = 2 
    Var REG_DWORD:N9 = 4  // 32-bit number

    Call setWorkstationType()
    Call setFilePaths()

    //ErrorMessage "Escribo en CALEnabled"
    Call ReadRegistryValue(HKLM, "SOFTWARE\MICROS\CAL\Config", "CALEnabled", dataType, value,errMsg)
    IF (value="0")
        Call WriteRegistryValue(HKLM, "SOFTWARE\MICROS\CAL\Config", "CALEnabled", REG_DWORD, "1", 0, errMsg)
        ErrorMessage "POS DESACTUALIZADO, POR FAVOR REINICIELO"
    ELSE
       // ErrorMessage "CAL YA ESTA HABILITADO"
    ENDIF
    //ErrorMessage " errMsg=", errMsg 
Endsub

Sub ReadRegistryValue(Var key_ :N9, Var subKey_ :A1024, Var valueName_ :A1024, Ref dataType_, Ref value_, Ref errMsg_)
	Call LoadPRTDrv()
	If(gblPRTDrv <> 0)			
		DLLCall_CDecl gblPRTDrv, ST_ReadRegistryKeyValue(key_, subKey_, valueName_, Ref dataType_, Ref value_, Ref errMsg_)
		Call FreePRTDrv()		
		If(Trim(errMsg_) <> "")
			ErrorMessage Mid(errMsg_, 1, 79)
		EndIf			
	EndIf
EndSub

Sub WriteRegistryValue(Var key_ :N9, Var subKey_ :A1024, Var valueName_ :A1024, Var dataType_ :N9, Var value_ :A1024, Var valueSize_ :N9, Ref errMsg_)
	Call LoadPRTDrv()	
	If(gblPRTDrv <> 0)
		DLLCall_CDecl gblPRTDrv, ST_WriteRegistryKeyValue(key_, subKey_, valueName_, dataType_, value_, valueSize_, Ref errMsg_)
        	Call FreePRTDrv()		
		If(Trim(errMsg_) <> "")
			ErrorMessage Mid(errMsg_, 1, 79)
		EndIf			
	EndIf
EndSub

//************************** COMUNICACIONES ************************
//Recibe ultima comunicacion
//*****************************************************************
Sub recibeComunicacion
    var mensaje: A170=""

    format gDatos as "COMUNICACION|",gIdComunicacion

    call EnviaTransaccion
    IF @RxMsg = "_timeout" //Llega la Respuesta

    ELSE
        Split @RxMsg, "|", gCodigoRespuesta,gIdComunicacion,mensaje
        IF (gCodigoRespuesta=1)
           call mostrarmensaje(mensaje); 
        ENDIF
    ENDIF    

endsub
//************************  DESC EMPLEADOS ******************************
//Procesa Descuentos
//****************************************************************
sub procesaDescEmpleados
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    gTipoCampana= ""
    gCodigoMicros= ""

    call consultarCodigo(gIdEmpleado,"Id: ")
    var aux: A30 = ""
    var i:N4=0
    var cantItems : N4 = 0
    var items: A2000 = ""
    var haydescuento:N1=0
    if (gIdEmpleado="") 
     exitwitherror"DEBE INGRESAR UNA IDENTIFICACION"
    else

        //reviso los items en el ticket
        FOR i = 1 to @NUMDTLT
            IF (@DTL_TYPE[i]="M" AND @DTL_IS_VOID[i] = 0)
               IF (@DTL_TTL[i]>0)
                format items as items,"|",@DTL_OBJECT[i],"|",@DTL_QTY[i],"|",@DTL_TTL[i]
                cantItems=cantItems+1
               ENDIF
            ELSEIF (@DTL_TYPE[i]="D" AND @DTL_IS_VOID[i] = 0)
                haydescuento=1
            ENDIF
        ENDFOR

        IF (haydescuento=0)
            format gDatos as "BENEFEMP|",@WSID,"|",gIdEmpleado,"|",gVersion,"|",gCaja,"|",@ttldue,"|",@RVC,"|0|",cantItems,items

            gNombreEmpleado=""
            call EnviaTransaccion
            call RecibeTransaccionDescEmpleados
            call procesarRespuestaDescEmpleados
        ELSE
            exitwitherror"ERROR: EXISTE UN DESCUENTO EN EL TICKET"
        ENDIF
    endif
endsub
//************************* Desc Empleados ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionDescEmpleados
        var mensaje: A170=""
        var jj: N2
        gCodigoMicrosNivel=1
	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gTipoCampana,gCodigoMicros,gNombreEmpleado,gCodigoAdicional,gDescVariable,gCodigoMicrosNivel,gCodigoIngresado,gContadorProd,gCodigos[] : gProductos[]
           
	endif
	
endsub
//************************* Desc Empleados  *****************************
//Dispatcher de respuestas de desc empleados
//****************************************************************
Sub procesarRespuestaDescEmpleados
    VAR pricelevel: N2
    VAR aux:A19

    pricelevel=@mlvl
    if (gCodigoRespuesta="1") //Respuesta OK
        if (gTipoCampana="1") //Aplica producto
          LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+gCodigoMicrosNivel) //cambia el menulevel
          LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoMicros) //selecciona un producto
          LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+pricelevel) //vuelve el menulevel
        else
           if (gTipoCampana="2") //Cambia de pantalla
                LOADKYBDMACRO KEY(1, 196612) //Next Screen
           else
                if (gTipoCampana="3") //Aplica descuento
                    
                    LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros), MakeKeys(gNombreEmpleado), @KEY_ENTER
                else
                    if (gTipoCampana="4") //opciones de descuento
                        call procesarOpcionesDescuentos
                    else
                        if (gTipoCampana="5") //aplica macro
                            LoadDBKybdMacro gCodigoMicros
                        else
                            if (gTipoCampana="8") //Aplico descuento variable
                                IF (gDescVariable="0") //no hay nada que descontar
                                    call mostrarMensaje("NO EXISTEN PRODUCTOS A DESCONTAR")
                                ELSE
                                    LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros),MakeKeys(gDescVariable), @KEY_ENTER, MakeKeys(gNombreEmpleado),@KEY_ENTER
                                ENDIF
                            endif
                        endif
                    endif
                endif
           endif
        endif
        if (gCodigoAdicional>0)
            LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+gCodigoMicrosNivel) //cambia el menulevel
            
            IF (len(gNombreEmpleado)>19) 
                aux=mid(gNombreEmpleado,1,19)
            ELSE
                aux=gNombreEmpleado
            ENDIF
            LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoAdicional),MakeKeys(aux),@KEY_ENTER //selecciona un producto adicional al anterior
            LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+pricelevel) //vuelve el menulevel
            gCodigoAdicional=0
        endif
    else
        call mostrarMensaje(gDescRespuesta)
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    endif
endsub
//*************************** DESCUENTOS *****************************
// Procesa menu opciones de descuentos a aplicar
// ****************************************************************
Sub procesarOpcionesDescuentos
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A20
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A25
        var pricelevel          :N2
        var i                   :N4=0
        var cantItems           : N4 = 0
        var items               : A2000 = ""

        pricelevel=@mlvl

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	IF (gContadorProd>7) 
            cuantos=7
        ELSE 
            cuantos=gContadorProd
        ENDIF

	Window cuantos+1,65, "Seleccione el Descuento"
		

		FOR jj=1 to cuantos
                    
                    IF (len(gProductos[jj])<25) 
                        aux=gProductos[jj]
                        WHILE (len(aux)<25)
                            format aux as aux," "
                        ENDWHILE
                    ELSE
                        aux=mid(gProductos[jj],1,25)
                    ENDIF
                    IF ((jj+7)<=gContadorProd)
                        format texto as jj,"-",aux,"     ",jj+7,"-",gProductos[jj+7]
                    ELSE 
                        format texto as jj,"-",aux
                    ENDIF
                    Display jj,1,texto
                endfor
                Display cuantos+1,1,"Seleccion: "
		DisplayInput cuantos+1, 11, opcion{2},""
	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	//If kKeyPressed = @KEY_ENTER
                IF opcion>0 and opcion<=gContadorProd 
                    
                     //reviso los items en el ticket
                    FOR i = 1 to @NUMDTLT
                        IF (@DTL_TYPE[i]="M" AND @DTL_IS_VOID[i] = 0)
                            IF (@DTL_TTL[i]>0)
                                format items as items,"|",@DTL_OBJECT[i],"|",@DTL_QTY[i],"|",@DTL_TTL[i]
                                cantItems=cantItems+1
                            ENDIF
                        ENDIF
                    ENDFOR

                    format gDatos as "BENEFEMP|",@WSID,"|",gCodigoIngresado,"|",gVersion,"|",gCaja,"|",@ttldue,"|",@RVC,"|",gCodigos[opcion],"|",cantItems,items
    
                    gNombreEmpleado=""
                    call EnviaTransaccion
                    call RecibeTransaccionDescEmpleados
                    call procesarRespuestaDescEmpleados
                ELSE
                    format texto as "Seleccion Invalida"
                    call MostrarMensaje(texto)
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
                ENDIF

	//ElseIf kKeyPressed = @KEY_CANCEL
	//	Format opcion		As ""
        //        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	//EndIf
       // ErrorMessage codigoIngresado

EndSub
//************************ OFFLINE *******************************
//Solicita Campanas Offline
//****************************************************************
sub solicitarCampanasOffline
    

    format gDatos as "OFFLINE|",@WSID,"|",gVersion,"|",gCaja,"|",@RVC
    call EnviaTransaccion
    call RecibeTransaccionOffline
    //call procesarRespuestaOffline
endsub
//************************ OFFLINE *******************************
//Envia codigos Offline procesados
//****************************************************************
sub enviarCodigosOffline
    var i : N3
    If (gOffCantCodIngresados>0)
        i=gOffCantCodIngresados
        gOffRecibido=1
        WHILE ((i>0) and (gOffRecibido=1))
            format gDatos as "OFFCOD|",@WSID,"|",gOffCodIngresados[i],"|",@RVC,"|"
            call EnviaTransaccion
            call RecibeTransaccionOfflineEncolados
            if (gOffRecibido=1)
                i=i-1
                gOffCantCodIngresados=gOffCantCodIngresados-1
            ENDIF
        ENDWHILE
    ENDIF
endsub
//************************* OFFLINE ******************************
//Recibe respuesta de campanas offline del servidor central
//****************************************************************
sub RecibeTransaccionOffline
        var mensaje: A170=""
        var jj: N2


	if @RxMsg = "_timeout" //Llega la Respuesta
	   //InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
	else
            clearArray gOffCamp
            clearArray gOffTipo
            clearArray gOffLen
            clearArray gOffCodMicros
            clearArray gOffCodMicrosNivel
            clearArray gOffRvc
            gContadorOff=0
	    Split @RxMsg, "|", gContadorOff,gOffCamp[]:gOffTipo[]:gOffLen[]:gOffCodMicros[]:gOffRvc[]:gOffCodMicrosNivel[]
            //InfoMessage "offline campanas",gContadorOff
	endif
	
endsub

//************************* OFFLINE ******************************
//Recibe respuesta de campanas offline encolados del servidor central
//****************************************************************
sub RecibeTransaccionOfflineEncolados
        var mensaje: A170=""
        var jj: N2


	if @RxMsg = "_timeout" //Llega la Respuesta
	   //InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gOffRecibido=0
	endif
	
endsub
//************************* OFFLINE ******************************
//Recibe respuesta de frecuencia idle del servidor central
//****************************************************************
sub RecibeTransaccionOfflineFrec
        var frecaux: N5
        

	if @RxMsg = "_timeout" //Llega la Respuesta
        else
            Split @RxMsg, "|", gCodigoRespuesta,frecaux
            
             IF (gCodigoRespuesta="1")
                //@idle_seconds=frecaux
             ENDIF
	endif
	
endsub
/************************* OFFLINE ******************************
//Procesa respuesta de campanas offline del servidor central
//****************************************************************
sub procesarCuponOffline
    var i: N3=1
    var encontro: N3=0
    var mensaje : A50

   // format mensaje as "Cant Offline: ",gContadorOff
   // call mostrarMensaje(mensaje)


    gCodigoRespuesta=0
    gDescRespuesta="OFFLINE: Promocion inexistente o inactiva"
    IF (gCodigoIngresado<>"")
        //veo que campana uso
        IF (gContadorOff>0)
            While (encontro=0 and i<=gContadorOff)
                if (gOffCamp[i]=mid(gCodigoIngresado,1,len(gOffCamp[i])))
                    encontro=i
                else
                    i=i+1
                endif
            ENDWhile
        ENDIF
    ENDIF

    if (encontro>0)
        if (gOffRvc[encontro]<>0 and gOffRvc[encontro]<>@RVC)
            gdescRespuesta="OFFLINE: Este cupon no puede ser utilizado en este RVC"
        elseif (gOffLen[encontro]=len(gCodigoIngresado))
            gCodigoRespuesta=1
            if (gOffCantCodIngresados<gMaxCodigosOffline)
                gOffCantCodIngresados=gOffCantCodIngresados+1
                gOffCodIngresados[gOffCantCodIngresados]=gCodigoIngresado
                gOffCodIngresadosNivel[gOffCantCodIngresados]=gOffCodMicrosNivel[encontro]
            endif
        else
            gDescRespuesta="OFFLINE: Cantidad de digitos incorrectos"
        endif
        gTipoCampana=gOffTipo[encontro]
        gCodigoMicros=gOffCodMicros[encontro]
        gCodigoMicrosNivel=gOffCodMicrosNivel[encontro]
    endif

    call procesarRespuesta
   
endsub
//************************** OFFLINE ************************
//recibe configuracion idle
//*****************************************************************
Sub recibeFrecuenciaOffline
    var mensaje: A170=""

    format gDatos as "OFF-FREC|",@WSID,"|","0","|",gVersion,"|",gCaja,"|",@RVC,"|",@RVC
    call EnviaTransaccion
    call RecibeTransaccionOfflineFrec

endsub
//************************  CUPONES ******************************
//Procesa Cupones
//****************************************************************
sub procesaCupones(Var porTarjeta: N1,Var prefijo: A5, VAR banda: N1)
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    gTipoCampana= ""
    gCodigoMicros= ""
    gCodigoProducto=""
    
    clearArray gProductos
    clearArray gCodigos
    clearArray gCodigosNivel
    gContadorProd=0

   // IF (porTarjeta=0)
   //     call consultarCodigo(gCodigoIngresado)
    //ELSE
    //    call consultarCodigoTarjeta(gCodigoIngresado)
    //ENDIF
    call consultarCodigoTarjeta(gCodigoIngresado,porTarjeta,banda)
    var aux: A30 = ""
    //aux="Codigo invitacion"
    //call mostrarMensaje(aux)
    if (gCodigoIngresado="") 
     exitwitherror"DEBE INGRESAR UN CODIGO"
    else
        format aux as prefijo,gCodigoIngresado
        format gCodigoIngresado as aux
        format gDatos as "CUPON|",@WSID,"|",gCodigoIngresado,"|",gVersion,"|",gCaja,"|",porTarjeta,"|",@RVC
    //@WSType

        call EnviaTransaccion
        call RecibeTransaccion
        if @RxMsg <> "_timeout" 
            call procesarRespuesta
        endif
    endif
endsub
//************************  CUPONES ******************************
//Envia transaccion al servidor central
//****************************************************************
sub EnviaTransaccion
	gStatus=0
	TXMSG gDatos //Manda los datos al puerto que definimos
	//ErrorMessage "Enviado"
	GetRXMsg "Esperando Respuesta de Servicio" //Estado de espera
endsub
//************************* CUPONES ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccion
        var mensaje: A170=""
        var jj: N2
        var VersionCampanas : N4
        gCodigoMicrosNivel=1
        VersionCampanas=gVersionCampanas

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
           gOffline=1
           call procesarCuponOffline 
           gOffline=0
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gTipoCampana,gCodigoMicros,gCodigoMicrosNivel,gCodigoProducto,VersionCampanas,gContadorProd,gProductos[]: gCodigos[]: gCodigosNivel[]
           If (gOffCantCodIngresados>0) 
                call enviarCodigosOffline
           ENDIF
           IF (VersionCampanas<>gVersionCampanas and VersionCampanas<>0)
                gVersionCampanas=VersionCampanas
                call solicitarCampanasOffline
           ENDIF
	endif
	//format mensaje AS gCodigoRespuesta," ",gDescRespuesta," ",gTipoCampana," ",gCodigoMicros
       // call mostrarMensaje(mensaje)
endsub

//************************* CUPONES  *****************************
//Dispatcher de respuestas de cupones
//****************************************************************
Sub procesarRespuesta
    VAR pricelevel :N2
    pricelevel=@mlvl
    if (gCodigoRespuesta="1") //Respuesta OK
        if (gTipoCampana="1") //Aplica producto
          LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+gCodigoMicrosNivel) //cambia el menulevel
          LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoMicros) //selecciona un producto
          LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+pricelevel) //vuelve el menulevel
        else
           if (gTipoCampana="2") //Cambia de pantalla
                LOADKYBDMACRO KEY(1, 196612) //Next Screen
           else
                if (gTipoCampana="3") //Aplica descuento
                    LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros), MakeKeys("VALIDADOR CUPON"), @KEY_ENTER
                else
                    if (gTipoCampana="4") //Menu de opciones
                        call procesarMenuOpciones
		     else
			if (gTipoCampana="5") //aplica macro
			    LoadDBKybdMacro gCodigoMicros
			endif
                    endif
                endif
           endif
        endif
    else
        if (gCodigoRespuesta="3")
            //se proceso el cupon de opciones
        else
            //Error 2 cupon ya redimido o sin stock
            //Error 0 cupon no encontrado
            call mostrarMensaje(gDescRespuesta)
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        endif
    endif
endsub
//*************************** CUPONES *****************************
// Ingreso de codigo
// ****************************************************************
Sub consultarCodigo(Ref codigoIngresado_,Var titulo:A20)
        Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A20
        Var mensaje             : A20
	var indice		: N2

	 @validate_mag_track = 0 // disable track 2 validation

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	
	Window 2,50, "Ingresar"
		
		Display 1, 1, titulo
		Display 2, 1, mensaje
                DisplayMSinput 1, 10, codigoIngresado{m1, 1, 1, 20},"(max. 20 carac.)"

	WindowEdit	
	WindowClose	
	
	Format codigoIngresado_ 	As Trim(codigoIngresado)

        IF @MAGSTATUS = "Y"
            IF (len(codigoIngresado_)=13)
                indice=instr(1,codigoIngresado_,":")
                IF (indice=1)
                    codigoIngresado_=mid(codigoIngresado_,4,14)
                ENDIF
            ENDIF
        ENDIF
EndSub
//*************************** CUPONES *****************************
// Ingreso de codigo tarjeta
// ****************************************************************
Sub consultarCodigoTarjeta(Ref codigoIngresado_, Ref porbanda, VAR banda:N1)   	
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A30
        Var mensaje             : A20
        Var espacio             : N2
        Var aux                 : A30
	
        @validate_mag_track = 0 // disable track 2 validation
        format mensaje as "Version ",gVersion
        porbanda=1
	//Touchscreen	gTouch
	
	Window 2,50, "Ingrese Codigo o Deslice Tarjeta"
		
		Display 1, 1, "Codigo: "
		Display 2, 1, mensaje
                IF (banda=2)
                    DisplayMSinput 1, 10, codigoIngresado{m2, 1, 1, 20},""
                ELSE
                    DisplayMSinput 1, 10, codigoIngresado{m1, 1, 1, 20},""
                ENDIF
		//DisplayInput 1, 10, codigoIngresado{20},"(max. 20 carac.)"

	WindowInput	
	WindowClose	
		

		Format codigoIngresado_ 	As Trim(codigoIngresado)
                //ErrorMessage codigoIngresado
                IF @MAGSTATUS = "N"
                        porbanda=0
                       // Format codigoIngresado		As ""
                        //ErrorMessage "Debe deslizar la tarjeta"
                ELSE
                    IF (len(codigoIngresado_)>16)
                        espacio=instr(2,codigoIngresado_," ")
                         //Format aux as codigoIngresado_," ",len(codigoIngresado_)," esp=",espacio
                         //ErrorMessage aux
                        IF (espacio=0)
                            IF (asc(codigoIngresado_)<48 or asc(codigoIngresado_)>57)
                            	//codigoIngresado_=mid(codigoIngresado_,2,16)
                                codigoIngresado_=mid(codigoIngresado_,2,len(codigoIngresado_))
			     ENDIF
                        ELSE
                            codigoIngresado_=mid(codigoIngresado_,espacio-16,16)
                            //split codigoIngresado_," ",codigoIngresado_,aux
                        ENDIF
                    ENDIF
		    //ErrorMessage codigoIngresado_
                ENDIF

	

EndSub
//*************************** CUPONES *****************************
// Procesa menu opciones para aplicar
// ****************************************************************
Sub procesarMenuOpciones
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A20
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A25
        var pricelevel          :N2

        pricelevel=@mlvl

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	IF (gContadorProd>7) 
            cuantos=7
        ELSE 
            cuantos=gContadorProd
        ENDIF

	Window cuantos+1,65, "Seleccione el Producto"
		

		FOR jj=1 to cuantos
                    
                    IF (len(gProductos[jj])<25) 
                        aux=gProductos[jj]
                        WHILE (len(aux)<25)
                            format aux as aux," "
                        ENDWHILE
                    ELSE
                        aux=mid(gProductos[jj],1,25)
                    ENDIF
                    IF ((jj+7)<=gContadorProd)
                        format texto as jj,"-",aux,"     ",jj+7,"-",gProductos[jj+7]
                    ELSE 
                        format texto as jj,"-",aux
                    ENDIF
                    Display jj,1,texto
                endfor
                Display cuantos+1,1,"Seleccion: "
		DisplayInput cuantos+1, 11, opcion{2},""
	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	If kKeyPressed = @KEY_ENTER
                IF opcion>0 and opcion<=gContadorProd 
                     format gDatos as "CUPONOPC|",@WSID,"|",gCodigoIngresado,"|",gVersion,"|",gCaja,"|",gCodigos[opcion],"|",gCodigosNivel[opcion]
                     call EnviaTransaccion
                     call RecibeTransaccion
                     call procesarRespuesta
                     IF (gCodigoRespuesta="3") 
                        LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+gCodigosNivel[opcion]) //cambia el menulevel
                        LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigos[opcion]) //selecciona un producto
                        LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+pricelevel) //vuelve el menulevel
                     ENDIF
                ELSE
                    format texto as "Seleccion Invalida"
                    call MostrarMensaje(texto)
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
                ENDIF

	ElseIf kKeyPressed = @KEY_CANCEL
		Format opcion		As ""
                LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	EndIf
       // ErrorMessage codigoIngresado

EndSub
//************************* CUSTOMER VOICE ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionCV
        var mensaje: A170=""
        var frecaux: N5
	if @RxMsg = "_timeout" //Llega la Respuesta
	   //InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gTipoCampana,gCodigoMicros,gCodigoProducto,frecaux,gTiendaCV
            
             IF (gCodigoRespuesta="1")
               // InfoMessage "Voy a grabar 0" 
                gFrecuencia=frecaux
               // call grabarFrecuencia
             ENDIF
	endif
	//format mensaje AS gCodigoRespuesta," ",gDescRespuesta," ",gTipoCampana," ",gCodigoMicros
       // call mostrarMensaje(mensaje)
endsub
// ********************* GENERAL ***********
// Funcion que lee el modelo de caja
// ************************************************
SUB darModeloCaja
    VAR ConfigFile       : A32       // File Name
    VAR FileHandle       : N5  = 0   // File handle

    IF (@WSTYPE=1)
        gCaja="WIN32"
    ELSE
        FORMAT ConfigFile AS g_path, "WS4.txt"

        FOPEN FileHandle, ConfigFile, READ

        IF FileHandle <> 0
           gCaja="WS4"
           FCLOSE FileHandle
        ELSE
             FORMAT ConfigFile AS g_path, "WS4LX.txt"

             FOPEN FileHandle, ConfigFile, READ

             IF FileHandle <> 0
                gCaja="WS4LX"
                FCLOSE FileHandle
             ELSE
                FORMAT ConfigFile AS g_path, "WS5.txt"

                FOPEN FileHandle, ConfigFile, READ

                IF FileHandle <> 0
                   gCaja="WS5"
                   FCLOSE FileHandle
                ELSE
                    FORMAT ConfigFile AS g_path, "WS5A.txt"

                    FOPEN FileHandle, ConfigFile, READ

                    IF FileHandle <> 0
                       gCaja="WS5A"
                       FCLOSE FileHandle
                    ELSE
                        gCaja="NAN"
                    ENDIF
                ENDIF
             ENDIF
        ENDIF
    ENDIF
ENDSUB
// ********************* CUSTOMER VOICE ***********
// Funcion que valida si hay descuentos marcados
// ************************************************
SUB hayDescuentos(ref hay)
    var i : N3

    For i = 1 to @NUMDTLT
        If @DTL_TYPE[i]   = "D" AND @DTL_IS_VOID[i] = 0
           hay=1
        EndIf
    EndFor

ENDSUB
// ********************* CUSTOMER VOICE ***********
// Funcion que lee la frecuencia de Customer Voice
// ************************************************
SUB darFrecuencia
    VAR ConfigFile       : A32       // File Name
    VAR FileHandle       : N5  = 0   // File handle

    FORMAT ConfigFile AS g_path, "CVFrecuencia.txt"

    FOPEN FileHandle, ConfigFile, READ
    
    IF FileHandle <> 0
       FREAD FileHandle, gFrecuencia
       FCLOSE FileHandle
    ELSE
        gFrecuencia=2
    ENDIF

ENDSUB
// ********************* CUSTOMER VOICE ***********
// Funcion que graba la frecuencia de Customer Voice
// ************************************************
SUB grabarFrecuencia
    VAR ConfigFile       : A32       // File Name
    VAR FileHandle       : N5  = 0   // File handle

    FORMAT ConfigFile AS g_path, "CVFrecuencia.txt"
    // InfoMessage "Voy a grabar 1"
    FOPEN FileHandle, ConfigFile, WRITE
    // InfoMessage "Voy a grabar 2"
    IF FileHandle <> 0
       FWRITE FileHandle, gFrecuencia
       FCLOSE FileHandle
    ENDIF
    // InfoMessage "Voy a grabar 3"
ENDSUB
//************************** CUTOMER VOICE ************************
//Muestra mensaje en pantalla
//*****************************************************************
Sub mostrarMensaje(Var mensaje:A170)
    var aux: A170=""
    format aux as "Mensaje (Version: ",gVersion,")"
    InfoMessage aux,mensaje
    //Window 3,50, "Mensaje"
		
//        Display 1,1,mensaje
  //      Display 2,1, gVersion
    //    Waitforconfirm
    //WindowClose
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
    //InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
    //IF (iOption=@KEY_ENTER)
     //   respuesta=1
    //ENDIF

endsub
//*************************** CUSTOMER VOICE **********************
// Impresion de invitacion customer voice
// ****************************************************************
Sub imprimirCV(VAR elcodigo:A20)
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50
	Prompt "Imprimiendo Customer Voice......"
	
            IF (dll_handle=0)
                call cargarDllImpresora
            ENDIF
            IF (dll_handle<>0)

                DLLCall_CDECL dll_handle, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )


                DLLCall_CDECL dll_handle, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )

                IF ( dll_status <> 0 )
                        ErrorMessage dll_status_msg
                ENDIF

                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Contanos tu experiencia en esta tienda" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Utilizando el siguiente codigo de cliente" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, elcodigo )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "WWW.MYSTARBUCKSVISIT-AR.COM" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Al completar la encuesta anota el codigo" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "- - - - -" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Y disfruta tu bebida favorita" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Bases y Condiciones en el Cupon Adjunto" )

                DLLCall_CDECL dll_handle, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )

                IF ( dll_status <> 0 )
                        ErrorMessage dll_status_msg
                ENDIF
                IF (dll_handle <> 0)
                    DLLFree dll_handle
                    dll_handle = 0
                ENDIF
           ELSE
                call mostrarMensaje("ERROR IMPRIMIENDO C.VOICE - DLL PRINTER")
           ENDIF
 
        Prompt "idle"
EndSub
//************************** CUTOMER VOICE ************************
//Envia codigo generado a servidor central
//*****************************************************************
Sub enviaCodigoCV
    var mensaje: A170=""

    format gDatos as "CV-ALTA|",@WSID,"|",gCodigoIngresado,"|",gVersion,"|",gCaja,"|",@RVC,"|",@RVC

    call EnviaTransaccion
    call RecibeTransaccionCV

    IF (gStatus=1) //Error de comunicacion
       // call procesarRespuesta
    ELSE
        IF (gCodigoRespuesta<>"1")
            format mensaje AS "ERROR: ",gDescRespuesta," Version: ",gVersion
            InfoMessage "Customer Voice",mensaje
        ENDIF
    ENDIF
endsub
//************************** CUTOMER VOICE ************************
//Envia codigo generado a servidor central
//*****************************************************************
Sub recibeFrecuenciaCV
    var mensaje: A170=""

    format gDatos as "CV-FREC|",@WSID,"|","0","|",gVersion,"|",gCaja,"|",@RVC,"|",@RVC

    call EnviaTransaccion
    call RecibeTransaccionCV

endsub
//************************** CUTOMER VOICE ************************
//Recibe codigo de pais
//*****************************************************************
Sub recibePaisCV
    var mensaje: A170=""

    format gDatos as "CV-PAIS|",@WSID,"|","0","|",gVersion,"|",gCaja,"|",@RVC,"|",@RVC

    call EnviaTransaccion
    IF @RxMsg = "_timeout" //Llega la Respuesta

    ELSE
        Split @RxMsg, "|", gCodigoRespuesta,gCodigoCVPais
    ENDIF    

endsub
//************************** CUTOMER VOICE ************************
// Redimir CV
// ****************************************************************
Sub redimirCV
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A18
        Var codigoPremio        : A18
	var mensaje: A170=""

	Touchscreen	@ALPHASCREEN
	
	Window 5,50, "Cupon Customer Voice"
		
		Display 1, 1, "Codigo Customer Voice: "
                Display 2, 1, "Codigo Premio: "
		Display 3, 1, gVersion
                Display 4, 1, gFrecuencia
                Display 5,1,@trans_number
		DisplayInput 1, 23, codigoIngresado{17},"(max. 17 carac.)"
                DisplayInput 2, 16, codigoPremio{17},"(max. 17 carac.)"

	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	If kKeyPressed = @KEY_ENTER
		Format codigoIngresado 	As Trim(codigoIngresado)
                Format codigoPremio As Trim(codigoPremio)

                format gDatos as "CV-REDIMIR|",@WSID,"|",codigoIngresado,"|",codigoPremio

                call EnviaTransaccion
                call RecibeTransaccionCV

                IF (gStatus=1) //Error de comunicacion
                    InfoMessage "Customer Voice","ERROR: No hay comunicacion con servidor CV"
                ELSE
                    call ProcesarRespuestaCV(codigoIngresado)
                ENDIF

	ElseIf kKeyPressed = @KEY_CANCEL
		Format codigoIngresado		As ""
                Format codigoPremio As ""
	EndIf
       
EndSub
//************************** CUTOMER VOICE ************************
// procerar respuesta CV
// ****************************************************************
Sub procesarRespuestaCV(Ref codigoIngresado)
    if (gCodigoRespuesta="1") //Respuesta OK
        LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros), MakeKeys(codigoIngresado), @KEY_ENTER
        LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoProducto)
        gEnTicket=1
    else
        InfoMessage "Customer Voice",(gDescRespuesta)
    endif
endsub
//************************  Vouchers ******************************
//Procesa Vouchers: Envia el ticket para consultar impresion voucher
//****************************************************************
sub procesaVouchers
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    gTipoCampana= ""
    gCodigoMicros= ""
    var i: N4 = 0
    var cantItems : N4 = 0
    var items: A400 = ""
    var aux: A30 = ""
   
    For i = 1 to @NUMDTLT[i] 
        If @DTL_TYPE[i]   = "M" AND @DTL_IS_VOID[i] = 0
           format items as items,"|",@DTL_OBJECT[i]
            cantItems=cantItems+1
        EndIf
    EndFor
    format gDatos as "VOUCHER|",@WSID,"|",gVersion,"|",gCaja,"|",@RVC,"|",@ttldue,"|",@trans_number,"|",cantItems,items
    
    call EnviaTransaccion
    call RecibeTransaccionVouchers
    if (gStatus=0)
        call procesarRespuestaVouchers
    endif
endsub
//************************* Vouchers ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionVouchers
        var mensaje: A170=""
        var jj: N2

	if @RxMsg = "_timeout" //Llega la Respuesta
	  // InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
	else
	   Split @RxMsg, "|", gContadorProd,gCodigos[] : gProductos[]  
           
	endif
	
endsub

//************************* VOUCHERS  *****************************
//Dispatcher de respuestas de Vouchers
//****************************************************************
Sub procesarRespuestaVouchers
    For i = 1 to gContadorProd 
        if (gCodigos[i]="1" or gCodigos[i]="5") //Aplica producto
          LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gProductos[i]) //selecciona un producto
        else
           if (gCodigos[i]="2" or gCodigos[i]="7") //aplica macro
                LoadDBKybdMacro gProductos[i]
           else
                if (gCodigos[i]="3" or gCodigos[i]="6") //Aplica descuento
                    LoadKybdMacro Key(KEY_TYPE_DISCOUNT,  gProductos[i]), MakeKeys("VOUCHER"), @KEY_ENTER
                endif
           endif
        endif
    EndFor
endsub

//*************************** CLARIn 365 *****************************
// Ingreso de codigo tarjeta
// esClasica: 0 si es Clasica, 1 si es Plus, -1 error
// ****************************************************************
Sub procesaClarin365(Ref esClasica)   	
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A30
        Var codigoIngresado2    : A30
        Var mensaje             : A20
        Var espacio             : N2
        Var aux                 : A30
        Var porbanda            : N1

        @validate_mag_track = 0 // disable track 2 validation
        format mensaje as "Version ",gVersion
        porbanda=1
        esClasica=-1
	//Touchscreen	gTouch
	
	Window 2,50, "Deslice Tarjeta 365"
		
		Display 1, 1, "Tarjeta: "
		Display 2, 1, mensaje
                DisplayMSinput 1, 10, codigoIngresado{m1, 1, 1, 20},""
		//DisplayInput 1, 10, codigoIngresado{20},"(max. 20 carac.)"

	WindowInput	
	WindowClose	
		

        Format codigoIngresado2 	As Trim(codigoIngresado)
        //ErrorMessage codigoIngresado
        IF (len(codigoIngresado2)>16)
                espacio=instr(2,codigoIngresado2," ")
                IF (espacio=0)
                    IF (asc(codigoIngresado2)<48 or asc(codigoIngresado2)>57)
                        codigoIngresado2=mid(codigoIngresado2,2,len(codigoIngresado2))
                     ENDIF
                ELSE
                    codigoIngresado2="1234567890"
                ENDIF
            ENDIF
            aux=mid(codigoIngresado2,7,2)
            //ErrorMessage aux
            IF (aux="00" or aux="99" or aux="01" or aux="02" or aux="03" or aux="10" or aux="50"  or aux="60" or aux="70" or aux="88" or aux="40" or aux="41" or aux="42" or aux="43") 
		esClasica=0
            ELSEIF (aux="05" or aux="98" or aux="15" or aux="55" or aux="65" or aux="75") 
		esClasica=1
            ENDIF
        ENDIF
       // ErrorMessage codigoIngresado2
EndSub

//*************************** SUBE *****************************
// Ingreso de codigo tarjeta
// esSube: 1 si esta ok, -1 error
// ****************************************************************
Sub procesaSube(Ref esSube)   	
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A30
        Var codigoIngresado2    : A30
        Var mensaje             : A20
        Var espacio             : N2
        Var aux                 : A30
        Var porbanda            : N1

        @validate_mag_track = 0 // disable track 2 validation
        format mensaje as "Version ",gVersion
        porbanda=1
        esSube=-1
	//Touchscreen	gTouch
	
	Window 2,50, "Deslice Sube"
		
		Display 1, 1, "Tarjeta: "
		Display 2, 1, mensaje
                DisplayMSinput 1, 10, codigoIngresado{m1, 1, 1, 20},""
		//DisplayInput 1, 10, codigoIngresado{20},"(max. 20 carac.)"

	WindowInput	
	WindowClose	
		

        Format codigoIngresado2 	As Trim(codigoIngresado)
        IF (len(codigoIngresado2)>16)
            aux=mid(codigoIngresado2,2,6)
            IF (aux="606126") 
		esSube=1
            ENDIF
        ENDIF
EndSub
//************************  GIFTCARDS  ***************************
//Procesa Gift Cards, consulto saldo
//****************************************************************
sub procesaGiftCard(Var solosaldo:N1)
    Var porBanda: N1=0
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    gTipoCampana= ""
    gCodigoMicros= ""
    

    call consultarCodigoTarjeta(gCodigoGiftCard,porBanda,1)
    var aux: A30 = ""
 
    if (gCodigoGiftCard="") 
     exitwitherror"DEBE INGRESAR UN NUMERO DE TARJETA"
    else
        
        format gDatos as "CRED-SALDO|",@WSID,"|",gCodigoGiftCard,"|",gVersion,"|",gCaja,"|",porBanda,"|",@RVC

        call EnviaTransaccion
        call RecibeTransaccionGiftCard
        if @RxMsg <> "_timeout" 
            call procesarRespuestaGiftCard(solosaldo)
        endif
    endif
endsub

//************************* GIFTCARDS ****************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionGiftCard
        var mensaje: A170=""
        var jj: N2

        gGiftCardSaldo=0

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gCodigoMicros,gCodigoAdicional,gGiftCardSaldo
	endif
endsub

//************************* GIFTCARDS  *****************************
//Dispatcher de respuestas de giftcard
//****************************************************************
Sub procesarRespuestaGiftCard(Var solosaldo:N1)
    Var aux: A20=""
    if (gCodigoRespuesta="1") //Respuesta OK trato de pagar con la tarjeta
        if (solosaldo=1)
            format aux as "Saldo: ",gGiftCardSaldo
            call mostrarMensaje(aux)
        else
            call pagoGiftCard
        endif
    else
       //Errores muestro mensaje
        call mostrarMensaje(gDescRespuesta)
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    endif
endsub
//************************* GIFTCARDS  *****************************
//pago con GiftCard
//****************************************************************
Sub pagoGiftCard
    VAR aux :A200
    VAR auxdif: $7
    VAR respuesta: N1

    IF (@ttldue<gGiftCardSaldo)
        //tengo saldo suficiente aplico el descuento variable
        LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros),MakeKeys(@ttldue), @KEY_ENTER, MakeKeys(gCodigoGiftCard),@KEY_ENTER
        //aplico el item de 0,01
        LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoAdicional) 
        //envio al servidor central la compra
        format gDatos as "CRED-COMPRA|",@WSID,"|",gCodigoGiftCard,"|",gVersion,"|",gCaja,"|",@ttldue,"|",@RVC
        call EnviaTransaccion
        call RecibeTransaccionGiftCard
        IF @RxMsg <> "_timeout" 
             IF (gCodigoRespuesta<>"1") //hubo un error?
                call mostrarMensaje(gDescRespuesta)
             ELSE
                format aux as "Saldo: ",gGiftCardSaldo
                call mostrarMensaje(aux)
             ENDIF
        ENDIF
    ELSE
        //no tengo saldo suficiente, consulto
        auxdif=@ttldue-gGiftCardSaldo
        
        IF (gGiftCardSaldo>0)
            format aux as "Saldo Insuficiente (",gGiftCardSaldo,"). Faltaria: ",auxdif,". Continuamos ?"
            call consultarMensaje(aux,respuesta)
            IF (respuesta=1)
                //NO tengo saldo suficiente aplico el descuento variable de una parte
                LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros),MakeKeys(gGiftCardSaldo), @KEY_ENTER, MakeKeys(gCodigoGiftCard),@KEY_ENTER
                //aplico el item de 0,01
                LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoAdicional) 
                //envio al servidor central la compra
                format gDatos as "CRED-COMPRA|",@WSID,"|",gCodigoGiftCard,"|",gVersion,"|",gCaja,"|",gGiftCardSaldo,"|",@RVC
                call EnviaTransaccion
                call RecibeTransaccionGiftCard
                IF @RxMsg <> "_timeout" 
                     IF (gCodigoRespuesta<>"1") //hubo un error?
                        call mostrarMensaje(gDescRespuesta)
                     ENDIF
                ENDIF
            ENDIF
        ELSE
            call mostrarMensaje ("NO TIENE FONDOS EN SU CUENTA")
        ENDIF
    ENDIF
endsub
//********************** PROMOCIONES GENTE *****
// Ingreso de datos promocion parrila
//**********************************************
Sub ingresoDatosParrila
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var nombre              : A50
        Var dni                 : A10
        Var mail                : A50
        Var telefono            : A50
	var mensaje: A170=""

	Touchscreen	@ALPHASCREEN
	
	Window 5,70, "Datos cliente PARRILLA"
		
		Display 1, 1, "Nombre: "
                Display 2, 1, "DNI: "
		Display 3, 1, "Mail: "
                Display 4, 1, "Telefono: "

		DisplayInput 1, 10, nombre{50},"(max. 50 carac.)"
                DisplayInput 2, 10, dni{10},"(max. 10 carac.)"
                DisplayInput 3, 10, mail{50},"(max. 50 carac.)"
                DisplayInput 4, 10, telefono{50},"(max. 50 carac.)"

	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	If kKeyPressed = @KEY_ENTER
		Format nombre 	As Trim(nombre)
                Format dni 	As Trim(dni)
                Format mail 	As Trim(mail)
                Format telefono As Trim(telefono)
                
                IF (telefono="" and mail="")
                    InfoMessage "Datos Cliente","ERROR: Debe ingresar mail o telefono"
                ELSE
                    format gDatos as "DATOS-PROM|",@WSID,"|",gVersion,"|",nombre,"|PARRILLA|",dni,"|",mail,"|",telefono,"|PARR|1"

                    call EnviaTransaccion
                    call RecibeTransaccionGeneral

                    IF (gStatus=1) //Error de comunicacion
                        InfoMessage "Datos Cliente","ERROR: No hay comunicacion con servidor de fidelidad"
                    ELSE
                        IF (gCodigoRespuesta<>1)
                            InfoMessage "Datos Cliente",gDescRespuesta
                        ELSE
                            InfoMessage "Datos Cliente", "Datos ingresados con exito"
                        ENDIF
                    ENDIF
                ENDIF

	ElseIf kKeyPressed = @KEY_CANCEL

	EndIf
       
EndSub
//************************* PROMOCIONES GENTE  ****************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionGeneral
        var mensaje: A170=""
        var jj: N2

        gGiftCardSaldo=0

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE VALIDACION"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta
	endif
endsub
// ********************* GENERALES ***********
// Funcion que graba el pms5
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
Sub setWorkstationType()
	
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
Sub SetFilePaths()
		
	// general paths
	If gbliWSType = PCWS_TYPE
		// This is a Win32 client
		Format PATH_TO_PRT_DRIVER 				As "..\bin\TWSEpsonArg.dll"		
		// This is a WinCE 5.0/6.0 client		
	ElseIf gbliWSType = WS5_TYPE		
		Format PATH_TO_PRT_DRIVER 				As "CF\micros\bin\TWSEpsonArgCE50.dll"
	Else
		// This is a WS4 client	WinCE 4.2	
		Format PATH_TO_PRT_DRIVER 				As "CF\micros\bin\TWSEpsonArgCE40.dll"		
	EndIf
		
EndSub
//******************************************************************
// Procedure: LoadPRTDrv() para recibos X
//******************************************************************
Sub LoadPRTDrv()

	Var retMessage :A512
	If (gblPRTDrv = 0)
		DLLLoad gblPRTDrv, PATH_TO_PRT_DRIVER
    EndIf

	If gblPRTDrv = 0
		ErrorMessage "Failed to load PRT driver!"
                ErrorMessage PATH_TO_PRT_DRIVER
		Return 
    EndIf
	DLLCall_CDecl gblPRTDrv, PRARG_InitializeDriver("COM1", 9600, 8, 0,0,Ref retMessage)
		
	If(Trim(retMessage) <> "")
		ErrorMessage Mid(retMessage, 1, 79)
	EndIf
		
EndSub
//******************************************************************
// Procedure: FreePRTDrv()
//******************************************************************
Sub FreePRTDrv()

	If gblPRTDrv <> 0
		DLLFree gblPRTDrv
		gblPRTDrv = 0	
	EndIf

EndSub
//******************************************************************
// Procedure: SyncDateTime()
//******************************************************************
Sub SyncDateTime

	Var print		:N1 = 1
	Var retMessage 	:A512

	Call LoadPRTDrv()

	
	If(gblPRTDrv <> 0)

		//DLLCall_CDecl gblPRTDrv, PRARG_SyncDateTime(print, Ref retMessage)
                DLLCall_CDecl gblPRTDrv, PRARG_SetDateTime(@DAY, @MONTH, @YEAR+2000, @HOUR, @MINUTE, @SECOND,print, Ref retMessage)
		Call FreePRTDrv()		

		If(Trim(retMessage) <> "")
			//ErrorMessage Mid(retMessage, 1, 79)
		EndIf
		
	EndIf


EndSub
//************************* DESCUENTOS EMPLEADOS LOCAL ******************************
//Aplica un descuento local
//****************************************************************
SUB aplicaDescuentoLocal(Var descobjnum:N3,VAR limitecant:N2,VAR limitemonto:$8, VAR porcentaje:$8)
    Var kKeyPressed		: Key
    Var iOption 		: N1
    Var id 			: A16
    Var aux                     :A16
    Var texto                   :A80
    Var cant                    :N3
    //VAr descobjnum              :N3=224
    Var nombre                  :A50
    Var monto                   :$8
    IF (((@TTLDUE*porcentaje)/100)>limitemonto)
        
        format texto as "EL MONTO A DESCONTAR DEBE SER INFERIOR A ",limitemonto
        INFOMESSAGE texto
    ELSE

	Touchscreen	@ALPHASCREEN
	
	Window 2,50, "Identificacion"
		
		Display 1, 1, "ID: "
		DisplayInput 1, 4, aux{16},"(max. 16 carac.)"

	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	//If kKeyPressed = @KEY_ENTER
		Format id 		As Trim(aux)
	//ElseIf kKeyPressed = @KEY_CANCEL
	//	Format id 		As ""
	//EndIf
        IF (id<>"")
            call sqlCantDescEmpleado(descobjnum, id,cant,monto,nombre)
            IF (cant=limitecant)
                format texto as "SUPERO EL LIMITE DE DESCUENTOS DIARIO PERMITIDO (",limitecant,")"
                InfoMessage texto
            ELSEIF ((monto+((@TTLDUE*porcentaje)/100))>=limitemonto)
                format texto as "SUPERO EL LIMITE DE DINERO DIARIO PERMITIDO (",limitemonto,") CONSUMIDO (",monto,")"
                InfoMessage texto
            ELSE
                LoadKybdMacro Key(KEY_TYPE_DISCOUNT, descobjnum), MakeKeys(nombre), @KEY_ENTER
            ENDIF
        ELSE
            infomessage "DEBE INGRESAR UN ID"
        ENDIF
    ENDIF
ENDSUB
//************************* DESCUENTOS EMPLEADOS ******************************
//Cuenta la cantidad de descuentos de 
//****************************************************************
Sub sqlCantDescEmpleado(Ref objnum, VAR id:A10,Ref cantdesc, Ref monto,Ref nombre)

	Var dbok     	: N1
	Var comando     : A850= ""
        Var comandonombre :A300=""
	Var resultado	: A100= ""
	Var error	: A200= ""
        Var nombreaux      :A50=""
        var aux :A10=""
        
        gDBhdl=0
        Call ODBCinit
	Call ODBCconvalida(dbok)
	If dbok
 		Format comandonombre as "SELECT long_last_name+' '+long_first_name FROM  micros.emp_def CM WHERE (CM.id = '",id,"')"

               
		
                DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comandonombre) 
                DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
                IF (error="")
                    DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 
                    Split resultado, ";",nombre

                    IF (len(nombre)>19)
                        nombreaux=mid(nombre,1,19)
                    ELSE
			nombreaux=nombre
                    ENDIF
                    nombre=nombreaux
                    uppercase nombre


                     Format comando As "select count(trans_dtl.trans_seq),sum((-sttl_dsc_ttl+tax_coll_ttl))  ,(select ref from micros.ref_dtl where ref_dtl.trans_Seq = trans_dtl.trans_seq and ref_dtl.dtl_seq =(select min(dtl_seq) from micros.ref_dtl where ref_dtl.trans_Seq = trans_dtl.trans_seq)) as ref  ",  \
                    "  FROM  micros.chk_dtl  inner join micros.trans_dtl on chk_dtl.chk_seq = trans_dtl.chk_Seq ",\
                    " inner join micros.sale_dtl on sale_dtl.trans_seq=trans_dtl.trans_seq  ", \
                   " where trans_dtl.trans_Seq in (select trans_seq from micros.dsvc_dtl A,micros.dsvc_def B where A.dsvc_seq=B.dsvc_seq and B.obj_num=",objnum,"   )",\
                   "  and business_Date  =(SELECT business_date FROM micros.rest_status) and ref='",nombre,"' group by ref"
                    DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comando) 
                    DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
                    If (error="")
                        DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 

                        Split resultado, ";",aux,monto
                        if (aux<>"") 
                            cantdesc=aux
                        ELSE
                            cantdesc=0
                            //ErrorMessage "PMS: DescEmpeladoLocal: Sin descuentos"
                        endif	
                    Else 	

                        ExitWithError "PMS: DescEmpleadoLocal: Error al obtener sql 2"
                       // ErrorMessage error
                    Endif
                ELSE
                    ExitWithError "PMS: DescEmpleadoLocal: Error al obtener sql 1"
                    //ErrorMessage error
                Endif
                call ODBCbaja
	Else
            ExitWithError "PMS: DesEmpleadoLocal: Error al conectar BD"
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