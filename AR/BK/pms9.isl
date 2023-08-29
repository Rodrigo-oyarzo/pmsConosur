@Trace=0
//ContinueOnCancel
UseCompatFormat
UseISLTimeOuts
RetainGlobalVar

//ver 1.7: salgo solo si no hay nada o estaba en efectivo
//ver 1.6: bug nombre ticket, funcion ultimos pedidos,logeos
//ver 1.5: cierro conexiones a la base de datos
//ver 1.4: al terminar de procesar un pedido en efectivo me fijo si hay otro con tarjeta y continuo marcando
//ver 1.0 TASBK

var gUserPos: A8 //="1234"
var gFrecuencia: N5 // = 2
var gDatos: A1000=""
var gVersion: A14="1.71"
var gStatus: N1 = 0 //0 ok, 1 error comunicacion
var gCodigoRespuesta: A20 = ""
var gDescRespuesta : A100 = ""
var gTipoCampana : A10 = ""
var gCodigoMicros : A16 = ""
var gCodigoAdicional : A16 = ""
var gCodigoProducto : A16=""
var gEnTicket : N1 //=0
var gTouch : N5
var gHayPedidos : N1
var gCantidades[100] : A2
var gCodigos[100] : A12
var gNombreCliente : A30
var gProveedor : A30=""
var gNumeroPedido : A30
var gUltNumeroPedido : A30
var gUltDia:N2
var gFormaPago : A30
var gMonto: A10
var gPedidos[100] : A90
var gContadorProd : N3 = 0
var gContadorPedidos : N3 = 0
var gContadorPedidosEfectivo : N3=0
var gComanda[100]: A50
var gComandaCant :N2
var gContadorItems : N3 = 0
var gTiempo : N9
var gDemora : N2=0
var gDemoraTexto : A50
var gEnAutomatico: N1

Var KEY_TYPE_FUNCTION                                    : N9 = 1
Var KEY_TYPE_MENU_ITEM					: N9 = 3
Var KEY_TYPE_DISCOUNT 					: N9 = 5
var g_path  : A128 = "\CF\micros\etc\" //:A128="c:\Micros\Res\Pos\Etc\"   
var gPmsNombre :A20="pms9.isl"
var gPmsLineas1[1000] :A300
var gPmsCantLineas1 : N4
var gPmsLineas2[1000] :A300
var gPmsCantLineas2 : N4
var gTiempoIdle : N2
var gPantalla : N4=1023
var gIdleSec :N2=5

Var gDBhdl 	: N12
Var gDBPath     : A100="MDSSysUtilsProxy.dll"
Var dll_handle							: N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	

Var gTenderEfectivo:N2=2
Event init
    gTouch=@ALPHASCREEN
    gEnTicket=0
    gTiempo=0
    gNumeroPedido=""
    gUltNumeroPedido=""
    gHayPedidos=0
    gEnAutomatico=0
    gUltDia=@day
    
    call solicitarPms
    if (@RVC=6)
        call logear("AUTOGESTION INIT", 0)
        @IDLE_SECONDS=gIdleSec
        gTiempoIdle=@Minute
    endif
endevent

Event exit
        
EndEvent

Event Begin_Check
    
    IF (@RVC=6)
        call logear("BeginCheck", 1)
        gEnAutomatico=0
        gTouch=@ALPHASCREEN
        gEnTicket=0
        
        IF (gHayPedidos=1)
//            call buscarPrimerPedido
        ENDIF
    ENDIF
Endevent

Event inq: 2
    call logear("Inq2 mostrar pedidos efectivo", 1)
    call mostrarListaPedidoEfectivo
endevent

Event inq: 3
    call logear("inq3 pedidos pausa", 1)
    call mostrarListaPedidoPausa
endevent

Event inq : 5
    call logear("inq5 remarcar pedido", 1)
    call remarcarPedidoPos
endevent

Event inq: 6 //imprimir comanda pedido actual

    IF (gNumeroPedido<>"")
        call imprimirComandaActual
    ENDIF
Endevent

Event inq: 7 //impactar tender actual
    call logear("inq7 pagarcontender(0) actual", 1)
    call pagarConTender(0)
Endevent
Event inq: 8
    call logear("inq8 pagarcontender(1)", 1)
    call pagarConTender(1) //parte de la automatizacion para cerrar el ticket
endevent

Event inq: 9
    
    call mostrarListaUltimosPedidos
endevent

Event Idle_No_Trans
    VAR statuspull :N1=0
    if (@RVC=6)
        gHayPedidos=0
       // if (gTiempoIdle<>@Minute)

            call hayPedidosEncolados
            IF (gHayPedidos=1)

                call buscaEmpleadoAsignado
                IF (gUserPos<>"")
                    call validaPull(statuspull)
                    if (statuspull=1)
                        call buscaEmpleadoAsignado
                            call logear(" ",1)
                            call logear("Ingreso Automatico hay pedidos.....",1)
                            LoadKybdMacro MakeKeys(gUserPos),key(1,65549)
                            //LoadKybdMacro Key(1,327681) //abro un ticket
                            call buscarPrimerPedido

                    else
                        call logear("Error: Debe hacer Pull",1)
                        call mostrarMensaje("TAS: DEBE REALIZAR PULL ANTES DE MARCAR PEDIDO")
                    endif
                ELSE
                        call MostrarMensaje("TAS: DEBE ASIGNAR UN CAJERO")
                ENDIF
            ENDIF
            //gHayPedidos=0
            gTiempoIdle=@Minute
            @IDLE_SECONDS=gIdleSec
       // endif
    endif
endevent

Event singin
    gNumeroPedido=""
    call logear("SINGIN", 1)
    //call buscaPedidosEncolados
EndEvent

Event singout
        gNumeroPedido=""
        IF (@RVC=6)
            call logear("SINGOUT", 1)
            call hayPedidosEncolados
            IF (gHayPedidos=1)
                LoadKybdMacro MakeKeys(gUserPos),key(1,65549)
                //LoadKybdMacro Key(1,327681) //abro un ticket
                call buscarPrimerPedido
            ENDIF
            gHayPedidos=0
            @IDLE_SECONDS=gIdleSec
         ENDIF
EndEvent
//Event srvc_total: *
Event final_tender
    gHayPedidos=0
    IF (@RVC=6)
        call logear("FinalTender", 1)
        call logear("", 1)
        gNumeroPedido=""
        IF (gEnAutomatico=0)
            call hayPedidosEncolados
            IF (gHayPedidos=1)
               //LoadKybdMacro Key(1,327681) //abro un ticket
               call buscarPrimerPedido
            ELSE
                call logear("Salgo gAutomatico=0 final tender.....",1)
                LoadKybdMacro Key(KEY_TYPE_FUNCTION , 458755) //salgo
            ENDIF
        ELSE
            call logear("Salgo gAutomatico=1 final tender.....",1)
            LoadKybdMacro Key(KEY_TYPE_FUNCTION , 458755) //salgo
        ENDIF
    ENDIF
 //   call mostrarMensaje("srvc total")
endevent
Event trans_cncl
    IF (@RVC=6)
        call logear("TransCncl", 1)
    ENDIF
endevent
//************************  TAS  ******************************
//Consulta Pedidos Encolados con efectivo
//****************************************************************
sub mostrarListaPedidoEfectivo
    VAR statuspull :N1=0
    call validaPull(statuspull)
    if (statuspull=1)
        format gDatos as "PEDIDOSEFECTIVO|",@WSID,"|",gVersion,"|",@RVC,"|"
        call EnviaTransaccion
        call RecibeTransaccionPedidos
        call procesarRespuestaPedidos(1)
    else
        ErrorMessage "TAS: DEBE REALIZAR PULL ANTES DE MARCAR PEDIDO"
    endif
endsub
//************************  TAS  ******************************
//Consulta Ultimos Pedidos Encolados 
//****************************************************************
sub mostrarListaUltimosPedidos
    VAR statuspull :N1=0
    call validaPull(statuspull)
    if (statuspull=1)
        format gDatos as "ULTPEDIDOS|",@WSID,"|",gVersion,"|",@RVC,"|"
        call EnviaTransaccion
        call RecibeTransaccionPedidos
        call procesarRespuestaPedidos(9)
    else
        ErrorMessage "TAS: DEBE REALIZAR PULL ANTES DE MARCAR PEDIDO"
    endif
endsub
//************************  TAS  ******************************
//Hay Pedidos Encolados?
//****************************************************************
sub hayPedidosEncolados
    format gDatos as "HAYPEDIDOS|",@WSID,"|",gVersion,"|",@RVC,"|"
    call EnviaTransaccion
    call RecibeTransaccionHayPedidos
    call procesarRespuestaPedidos(0)
endsub
//************************  TAS  ******************************
//Marca el pedido siguiente
//****************************************************************
SUB buscarPrimerPedido
    format gDatos as "PRIMERPEDIDO|",@WSID,"|",gVersion
    call EnviaTransaccion
    call RecibeTransaccionIngresarPedido
    call procesarRespuestaPedidos(0)
ENDSUB
//************************  TAS  ******************************
//Consulta lista de Pedidos Encolados para mostrar info
//****************************************************************
sub mostrarListaPedidoInfo
    format gDatos as "ENCOLADOSINFO|",@WSID,"|",gVersion,"|"
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(2)
endsub
//************************  TAS  ******************************
//Consulta lista de Pedidos Encolados en pausa
//****************************************************************
sub mostrarListaPedidoPausa
    format gDatos as "PEDIDOSPAUSA|",@WSID,"|",gVersion,"|"
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(3)
endsub
//************************  TAS  ******************************
//Consulta lista de Pedidos Encolados para confirmar tiempo entrega
//****************************************************************
sub mostrarListaPedidoConfirmar
    format gDatos as "ENCOLADOSCONF|",@WSID,"|",gVersion,"|"
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(4)
endsub
//************************  TAS  ******************************
//Remarca pedido en pos por si cortaron el proceso
//****************************************************************
sub remarcarPedidoPos
    if (gNumeroPedido<>"")
        //gDemoraTexto=""
        format gDatos as "REPEDIDO|",@WSID,"|",gVersion,"|",gUltNumeroPedido
        call EnviaTransaccion
        call RecibeTransaccionIngresarPedido
        //IF (gDemoraTexto="")
        //    call textoDemora(gDemora)
        //ENDIF
        call procesarRespuestaPedidos(0)
    endif
endsub
//************************  TAS ******************************
//Envia transaccion al servidor central
//****************************************************************
sub EnviaTransaccion
	gStatus=0
	TXMSG gDatos //Manda los datos al puerto que definimos
	//ErrorMessage "Enviado"
	GetRXMsg "Esperando Respuesta de Servicio" //Estado de espera
endsub
//************************* TAS ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionPedidos
        var mensaje: A170=""
        var jj: N2
	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE TAS"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gContadorPedidos,gPedidos[]
           
	endif
	
endsub
//************************* TAS ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionHayPedidos
        var mensaje: A170=""
        var jj: N2
	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE TAS"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gContadorPedidos,gContadorPedidosEfectivo
           
	endif
	
endsub
//************************* TAS ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionIngresarPedido
        var mensaje: A170=""
        var jj: N2

        gContadorItems=0

	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE TAS"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gNumeroPedido,gNombreCliente,gFormaPago,gMonto,gContadorItems,gCodigos[]:gCantidades[]
          
	endif
endsub

//************************* TAS  *****************************
//Dispatcher de respuestas de pedidos encolados
//****************************************************************
Sub procesarRespuestaPedidos(Var tipo:N1)
    //var tipo: N1
    //tipo=1
    if (gCodigoRespuesta="1") //Respuesta OK lista de pedidos efectivo
       call procesarMenuPedidos(tipo)
    elseif (gCodigoRespuesta="2") //Respuesta OK ingresar pedido a pos
        call ingresarPedidoPos(1)
    elseif (gCodigoRespuesta="3") //Respuesta OK lista de pedidos en pausa
      // tipo=2
       call procesarMenuPedidos(tipo)
    elseif (gCodigoRespuesta="4") //Respuesta OK Mostrar Info pedido con o sin cancelar
        call mostrarInfoPedido(tipo)
    elseif (gCodigoRespuesta="6") //hay pedidos para idle
        gHayPedidos=0
        if (gContadorPedidos=1)
            //call mostrarMensaje("HAY PEDIDOS TAS")
            gHayPedidos=1
        endif
    elseif (gCodigoRespuesta="9")
        call procesarMenuPedidos(tipo)
    elseif (gCodigoRespuesta="7") //Respuesta OK lista de pedidos para mostrar info sin cancelar
       //tipo=3
       call procesarMenuPedidos(tipo)
    //elseif (gCodigoRespuesta="8") //Respuesta OK Mostrar Info pedido CON cancelar
      //  call mostrarInfoPedido(1)
    else
        call mostrarMensaje(gDescRespuesta)     
    endif
    
endsub
//************************  TAS  ******************************
//imprimir comanda actual
//****************************************************************
sub imprimirComandaActual
    var comando :A20
    var codigo :A2
    format gDatos as "IMPRIMIRCOMANDA|",@WSID,"|",gVersion,"|",@RVC,"|",gNumeroPedido
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
       InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE TAS"
       gStatus=1
    else
       Split @RxMsg, "|", codigo,comando,gComandaCant,gComanda[]
       IF (gComandaCant>0)
            Call cargarDllImpresora


            Var j :N3 = 0
            Var i :N1
            Var aux : A50
            Prompt "Imprimiendo Comanda......"

            dll_status=0
            FOR i=1 to 2 
                DLLCall_CDECL dll_handle, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )

                IF ( dll_status <> 0 )
                        ErrorMessage dll_status_msg
                ENDIF
                j=1    

                WHILE (j<=gComandaCant and dll_status =0)
                    aux=gComanda[j]
                    IF (aux="")
                        aux=" "
                    ENDIF
                    DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )

                    IF ( dll_status <> 0 )
                        ErrorMessage dll_status_msg
                    ENDIF
                    j=j+1
                ENDWHILE

                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )

                DLLCall_CDECL dll_handle, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )

                IF ( dll_status <> 0 )
                        ErrorMessage dll_status_msg
                ENDIF
            ENDFOR
            Prompt "idle"

            Call descargarDllImpresora
       ELSE
            InfoMessage("ERROR: No pude obtener la comanda")
       ENDIF
    endif
endsub
//*************************** TAS *****************************
// Ingresa items del pedido al pos
// ****************************************************************
Sub ingresarPedidoPos(Var automatico:N1)
    Var texto   :A80
    Var jj      :N3
    Var ii      :N2

    format texto as "Error: el pedido tiene 0 items"
    IF (gContadorItems=0)
        call MostrarMensaje(texto)
    ELSE
        //@CKID=gNombreCliente //asigna nombre de cliente
        call logear("Ingresar Pedido Pos", 1)
        LoadKybdMacro makekeys(gnombrecliente),Key(1,327683) 
        //guardo en las infolines la direccion
        clearchkinfo
        savechkinfo gNombreCliente
        call logear(gNombreCliente, 1)
        savechkinfo gFormaPago
        format texto as gNumeroPedido

        savechkinfo texto
        //------
         //por como procesan las macros lo hago aca
        //------------------
        gUltNumeroPedido=gNumeroPedido
        FOR jj=1 to gContadorItems
            FOR ii=1 to gCantidades[jj]
                LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigos[jj])
            ENDFOR
        ENDFOR
       //call MostrarMensaje("PEDIDO INGRESADO")
      // LoadDBKybdMacro 11101  //envio el pago
       call logear("Voy a enviar pago", 1)
       call pagarConTender(automatico)
       call logear("Fin enviar pago", 1)
    ENDIF
endsub
		
//*************************** TAS *****************************
// Procesa menu de pedidos encolados
// tipo=1 selecciona pedido
// tipo=2 muestra mas info pedido
// tipo=3 cancela pedido
// ****************************************************************
Sub procesarMenuPedidos(Ref tipo)
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A50
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N2
        Var maxsel              :N2
        var aux                 :A80
        var aux2                :A80
        var maxcar              :N2

        format mensaje as "PEDIDOS CON EFECTIVO - TOTAL: ",gContadorPedidos," -   Version ",gVersion
        IF (tipo=3)
            format mensaje as "PEDIDOS PAUSADOS - TOTAL: ",gContadorPedidos," -   Version ",gVersion
        ELSEIF (tipo=9)
            format mensaje as "ULTIMOS PEDIDOS - TOTAL: ",gContadorPedidos," -   Version ",gVersion
        ENDIF
	Touchscreen	gPantalla
        opcion=0
       // maxsel=gContadorPedidos

	IF (gContadorPedidos>11) 
            cuantos=11            
            //maxcar=36
            maxcar=74
        ELSE 
            cuantos=gContadorPedidos
            maxcar=74
        ENDIF
        //
        //IF (gContadorPedidos>28) 
        //    maxsel=28
        //ENDIF
        //
        maxsel=cuantos

    	Window cuantos+1,78, mensaje
		

		FOR jj=1 to cuantos
                    
                    IF (len(gPedidos[jj])<maxcar) 
                        aux=gPedidos[jj]
                        WHILE (len(aux)<maxcar)
                            format aux as aux," "
                        ENDWHILE
                    ELSE
                        aux=mid(gPedidos[jj],1,maxcar)
                    ENDIF
                    format texto as jj,"-",aux
                   
                    
                    Display jj,1,texto
                endfor

                Display cuantos+1,1,"Seleccion: "
		DisplayInput cuantos+1, 11, opcion{2},""
	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	//If kKeyPressed = @KEY_ENTER
                IF opcion>0 and opcion<=maxsel
                     IF (tipo=1 or tipo=3) //marcar pedido
                        
                        
                        format gDatos as "PEDIDO|",@WSID,"|",gVersion,"|",gPedidos[opcion],"|"
                           call EnviaTransaccion
                           call RecibeTransaccionIngresarPedido
                           call procesarRespuestaPedidos(0)
                      ENDIF  
                     
                ELSE
                    format texto as "Seleccion Invalida"
                    call MostrarMensaje(texto)
                    //LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
                ENDIF

	//ElseIf kKeyPressed = @KEY_CANCEL
	//	Format opcion		As ""
         //       LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	//EndIf
        Touchscreen	gTouch
EndSub

//**************************  ************************
//Pagar con el tender
//*****************************************************************
Sub pagarConTender(Var automatico:N1)
    var i : n3
    var cntInf :n3 = 0
    var Coma :n2 = 0
    var montoTotal:A16
    var tender: A6
    var paga:A8
    tender=""
    var aux:A60
   
    //paga=gPagaCon+0
    format aux as "FormaPago: ",gFormaPago
    call logear(aux, 1)
    IF (gFormaPago<>"")
        IF (gFormaPago<>"2")

            //format paga as @TTLDUE,""
            //infomessage(paga)
            LoadKybdMacro MakeKeys(gMonto),  Key (9, gFormaPago) //gMonto,@KEY_CANCEL
           // IF (gFormaPago="2")
           //     LoadKybdMacro MakeKeys(paga),  Key (9, gTenderPedidosYa) 
           // ELSE
           //     LoadKybdMacro MakeKeys(paga),  Key (9, gTenderEfectivo) 
           // ENDIF

            //veo si hay mas pedidos
            call hayPedidosEncolados
            IF (gHayPedidos=1)
                gEnAutomatico=0
                //LoadKybdMacro Key(1,327681) //abro un ticket
                //call buscarPrimerPedido
            ELSE
                    call logear("Salgo Automatico.....",1)
                    LoadKybdMacro Key(KEY_TYPE_FUNCTION , 458755) //salgo
            ENDIF
        ELSE
            IF (automatico=0)
                InfoMessage ("Efectivo: Vaya a la pantalla de pagos")
            ENDIF
        ENDIF
    ELSE
        InfoMessage ("No hay pedidos")
    ENDIF

EndSub
//**************************  ************************
//Muestra mensaje en pantalla
//*****************************************************************
Sub mostrarMensaje(Var mensaje:A170)
    var aux: A170=""
    format aux as "Mensaje (Version: ",gVersion,")"
    InfoMessage aux,mensaje
    
endsub
//******************************************************************
// setear sistema operativo y path
//******************************************************************

Sub setearSO

        //InfoMessage @WSTYPE
        IF (@WSTYPE=1) //es windows
            g_path="c:\Micros\Res\Pos\Etc\"   
          
        ELSE
            g_path= "\CF\micros\etc\" 
           
        ENDIF

EndSub
//******************************************************************
// Procedure: 	logear
//******************************************************************
Sub logear(var mensaje: A1000, var agregar : N1)
        call setearSO
        VAR logfile:A100
        IF (gUltDia<>@day)
            agregar=0
            gUltDia=@day
        ENDIF
        FORMAT LogFile AS g_path, "logPms9-",@day,".txt"
        Var fhandle	: N5  
	Var aux	: A1000

	
	If agregar
		FOpen fhandle, LogFile, append
	Else
		FOpen fhandle, LogFile, write
	EndIf

	If fhandle <> 0
		Format aux As @MONTH{02}, "/", @DAY{02}, "/", (@YEAR + 2000){04}, \
		" - ", @HOUR{02}, ":", @MINUTE{02}, ":", @SECOND{02}, \
		 " | WSID: ", @WSID, " | chkmicros: ",@cknum," | Pedido: ", gNumeroPedido, " === ", mensaje
	
		FWrite fhandle, aux
		FClose fhandle
	Else
		ErrorMessage "No pude grabar log en  ", logfile
	EndIf

EndSub
// ********************* GENERALES ***********
// Funcion que graba el pms9
// ************************************************
SUB grabarPms
    VAR ConfigFile       : A128       // File Name
    VAR FileHandle       : N5  = 0   // File handle
    VAR i : N4 = 1
    VAR auxwrite : N4
    Var aux : A300

    call setearSO
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
//Solicita si hay nuevo pms9
//****************************************************************
sub solicitarPms
    gPmsCantLineas1=0
    gPmsCantLineas2=0
    ClearArray gPmsLineas1
    ClearArray gPmsLineas2

    format gDatos as "PMS-1|",@WSID,"|",gVersion,"|",@RVC,"|"
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

       //InfoMessage "pms"
        
	if @RxMsg = "_timeout" //Llega la Respuesta
	else
           if (@RxMsg<>"NOPMS")
            
            //InfoMessage "pms",len(@RxMsg)
            
            Split @RxMsg, chr(33), gPmsCantLineas,gPmsLineas[]  
         
            if (gPmsCantLineas>0 )//llego un archivo
                 call grabarPms
            endif
           else
            //InfoMessage @RxMsg
           endif
	endif
	
endsub
//************************* Empleado Asignado ********************
//Verifica el empleado asignado
//****************************************************************
Sub buscaEmpleadoAsignado

	Var dbok     	: N1
	Var comando     : A500= ""
	Var resultado	: A20= ""
	Var error	: A200= ""

        gUserPos=""
        call ODBCinit
	Call ODBCconvalida(dbok)
	If dbok
 		Format comando As "SELECT E.id,E.emp_seq FROM micros.cm_receptacle_dtl AS P ",\
                        " INNER JOIN micros.uws_status AS U ON U.cm_drawer_1_till_assigned = P.receptacle_seq ",\                                
                        " INNER JOIN micros.uws_def AS D ON D.uws_seq = U.uws_seq ",\
                        " inner join micros.cm_employee_receptacle_assignment_dtl as R on P.receptacle_seq=R.receptacle_seq",\
                        " inner join micros.emp_def AS E on R.employee_seq=E.emp_seq",\
                        " WHERE  R.employee_assigned='T' and D.obj_num=",@WSID

                DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comando) 
                DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
		If (error="")
                    DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 
                    
                     Split resultado, ";", gUserPos
                     
		Else 	
                    
                    ErrorMessage "PMS9: Error al consulta empleado asignado"
                    ErrorMessage error
		Endif	
                call ODBCcerrarconexion()
                Call ODBCbaja()
	Else
            ErrorMessage "PMS9: EmpeladoAsignado: Error al conectar BD"
	Endif		
EndSub


//************************* PULL ******************************
//Valida que hay lugar ante de pull
//****************************************************************
Sub validaPull(Ref ok)

	Var dbok     	: N1
	Var comando     : A300= ""
	Var resultado	: A20= ""
	Var error	: A200= ""

        ok=1
        call ODBCinit
	Call ODBCconvalida(dbok)
	If dbok
 		Format comando As "SELECT case when (cash_pull_accumulator+P.starting_amount)<cash_pull_threshold  THEN 1 ELSE 0 END AS cpull",\
                                  " FROM micros.cm_receptacle_dtl AS P INNER JOIN micros.uws_status AS U ON U.cm_drawer_1_till_assigned = P.receptacle_seq",\
                                  " INNER JOIN micros.uws_def AS D ON D.uws_seq = U.uws_seq WHERE  obj_num=",@WSID
		
                DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comando) 
                DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
		If (error="")
                    DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 
                    if (resultado<>"1;") 
                        ok=0
                    endif	
		Else 	
                    
                    ErrorMessage "PMS9: ValidarPull: Error al consulta pull"
                    ErrorMessage error
		Endif	
                call ODBCcerrarconexion()
                Call ODBCbaja()
	Else
            ErrorMessage "PMS9: ValidarPull: Error al conectar BD"
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
		ErrorMessage "PMS9: Error al cargar BD"
        Else
            Call ODBCConexion()
            DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
            If error <> ""
                    ErrorMessage "PMS9: Error al init conexion BD"
            EndIf
        EndIf	
EndSub

//************************* BD ******************************
//baja driver BD
//****************************************************************
Sub ODBCbaja()

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
// Load FCR DLL
//******************************************************************
Sub cargarDllImpresora 
    IF (@WSTYPE=1) //es windows
            DLLLoad dll_handle,  "..\bin\Fcrdll.dll"
        ELSE
            DLLLoad dll_handle,  "\cf\micros\bin\FCRDriver.dll"
    ENDIF

    If dll_handle = 0
        ErrorMessage "No se puede cargar driver de impresora"
    EndIf
EndSub
//******************************************************************
// Procedure: Free FCR DLL
//******************************************************************
Sub descargarDllImpresora
	If dll_handle <> 0
		DLLFree dll_handle 
		dll_handle = 0	
	EndIf
EndSub

