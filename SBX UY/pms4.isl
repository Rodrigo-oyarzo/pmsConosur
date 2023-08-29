@Trace=0
//ContinueOnCancel
UseCompatFormat
UseISLTimeOuts
RetainGlobalVar


// menu level 9 458820
// menu level 1: 458757
//ver 6.04: error en haypedido, se envia =2 si es sbux para que valide pickup o delivery, mensaje diferenciado
//ver 6.03: correcion haypedidos
//ver 6.02: manejo de ordering en sbux
//ver 6.00: Agregamos pickup
//ver 5.10: cambiar el limite de tercer alerta de pull
//ver 5.09: cambio de mensajes al no tener caja asignada
//ver 5.08: aumentar cantidad de pedidos en pantalla
//ver 5.07: Listar pedidos por agregador
//ver 5.06: modifico re-aplicar descuento por si es mayor que el total y advertencia por diferencia entre monto y micros
//ver 5.05: por uruguay llamada especial por in q cons final o rut, agrego total ticket en info
//ver 5.04: alerta de pedido incompleto o mal - cambio en imprime comanda para sbux
//ver 5.03 efectivo en sbux
//ver 5.02 elimino mensaje paga con
//ver 5.0.1: Impresora termica
//ver 5.0: Agrego descuentos y numero de pedido proveedor, agrego uruguay
//ver 4.8: bugs notas
//ver 4.7: Agrego inq 14 para validar items delivery
//ver 4.6: Agrego nivel en lista de productos, variable global gChile 
//ver 4.5: agregar cerrar conexion en validapull
//ver 4.4 bug con efectivo
//ver 4.3: bug con ordertypes
//ver 4.2: Agregamos Glovo, cambio de ordertype
//ver 4.1: Inq para imprimir comando del pedido actual. Inq para insertar costo de envio, Inq para marcar un pedido como entregado
//ver 4.0 Agrega control de logistica para pedidosya

var gChile:N1
var gSbx:N1
var gSbxUY:N1
var gPickup:N1
var gfiscal:N1
var gFrecuencia: N5 // = 2
var gDatos: A1000=""
var gVersion: A14="6.05"
var gStatus: N1 = 0 //0 ok, 1 error comunicacion
var gCodigoRespuesta: A20 = ""
var gDescRespuesta : A100 = ""
var gTipoCampana : A10 = ""
var gCodigoMicros : A16 = ""
var gCodigoAdicional : A16 = ""
var gCodigoProducto : A16=""
var gEnTicket : N1 //=0
var gEnTicketPickup : N1
var gTouch : N5
var gCantidades[100] : A2
var gCodigos[100] : A12
var gNiveles[100] :A2
var gNombreCliente : A30
var gDireccionCliente : A35
var gDireccionCliente2 : A35
var gDireccionCliente3 : A35
var gBarrioCliente : A30
var gCiudadCliente : A30
var gTelefonoCliente : A30
var gProveedor : A30=""
var gNotasCliente : A30
var gNotasCliente2 : A30
var gNotasCliente3 : A30
var gNotasCliente4 : A30
var gNotasCliente5 : A30
var gHayNotas : N1
var gNumeroPedido : A30
var gUltNumeroPedido : A30
var gNumeroPedidoNotas : A30
var gNumeroPedidoProv:A20
var gFormaPago : A30
var gVertical	: A30
var gPagaCon : $7
var gPedidoIncompleto:N1
var gDescuentoCodigo:N5
var gDescuentoValor:$7
var gDescuentoAjuste:N9
var gPedidos[100] : A90
var gHayPedidosTipo:N1
var gContadorProd : N2 = 0
var gContadorPedidos : N2 = 0
var gContadorItems : N3 = 0
var gComanda[100]: A70
var gComandaCant :N2
var gTiempo : N9
var gDemora : N2=0
var gDemoraTexto : A50
var gCostoEnvio :N7
var gCostoEnvioCodVariable: N7
var gCostoEnvioMontoVariable: $6
var gMacroRvcDelivery: N6  //macro que cambiar al rvc que corresponda
var gMacroRvcOriginal: N6 //macro que cambiar al rvc orginal
var gRvcOriginal: N3
var gOrderType:N6
var gDescEfectivo:A15
var gDescTarjeta:A15
var gMacroComandaSbx:N5=504
var gMacroImpTermica:N5=800
var gSluPagos:N4=104 //slu con los medios de pagos

Var KEY_TYPE_MENU_ITEM					: N9 = 3
Var KEY_TYPE_DISCOUNT 					: N9 = 5
Var KEY_TYPE_MENU_SUB_LEVEL                             : N9 = 1
VAr ORDER_TYPE_BASE :N6=393232
Var ORDER_TYPE_RA   :N6 //6
Var ORDER_TYPE_PY   :N6 //4
Var ORDER_TYPE_GL   :N6 //5
var g_path  		: A128  //= "\CF\micros\etc\" //:A128="d:\Micros\Res\Pos\Etc\"   
var gPmsNombre :A10="pms4.isl"
var gPmsNombreChile:A10="pms3.isl"
var gPmsLineas1[1000] :A300
var gPmsCantLineas1 : N4
var gPmsLineas2[1000] :A300
var gPmsCantLineas2 : N4
var gTiempoIdle : N2
var gTiempoUltTicket : N2
var gTiempoUltHora  :N2
var gPantalla : N4

Var gDBhdl 	: N12
Var gDBPath     : A100="MDSSysUtilsProxy.dll"
Var dll_handle							: N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	

Var gTenderEfectivo:N4
var gTenderTarjeta:N4
Var gTenderPedidosYa:N2=42
Var gTenderPedidosYaChile:N2=55
Var gTenderGlovo:N2=45
Var gTenderRappi:N2=44
var gTender:N5

var FCR_CMD_SEPARATOR_CHR			: A1
var gsFCRCmdReturn				:A4	
var gsFCRFieldInfo				:A256
var giFCRStatus					:N2	
var gsFCRMsg								:A256	// For FCR status check message
var gsFCRFiscalStatus						:A4		// For FCR Fiscal Status return
var gsFCRExtFieldInfo						:A1000 
var FCR_CMD_OPEN_FCR_COUPON				: A4
var FCR_EXT_BITS_OFF					: A4								  
var FCR_CMD_CLOSE_FCR_NON_FISCAL_COUPON : A4
var FCR_EXT_BITS_ON						: A4

Var PCWS_TYPE									:N1 = 1	// Type number for PCWS
Var PPC55A_TYPE 					 			:N1 = 2 // Type number for Workstation mTablet
Var WS4_TYPE									:N1 = 3	// Type number for Workstation 4
Var WS5_TYPE									:N1 = 3	// Type number for Workstation 5
Var gbliWSType				 					:N1			// To store the current Workstation type
Var gbliRESMajVer								:N2			// To store the current RES major version
Var gbliRESMinVer								:N2			// To store the current RES minor version

VAR gPrinterUY:N12


Event init
    call initDelivery  
    call logear("DELIVERY INIT", 0)
endevent

Event exit
	Call ODBCbaja()
EndEvent

Event Begin_Check
    gTouch=@ALPHASCREEN
    //gEnTicket=0
    call leerEsDeli
    IF (gSbx=1 or gChile=1 or gPickup=1)
        IF (abs(@Minute-gTiempoUltTicket)>=2)
            call hayPedidosEncolados
			IF (gSbx=1)
				call hayPedidosCurbside
			EndIf
            gTiempoUltTicket=@Minute
        ELSEIF (@Hour<>gTiempoUltHora)
            //call initDelivery
        ENDIF
    ENDIF
Endevent

Event final_tender
    gNumeroPedido=""
    //IF (gRvcOriginal<>@rvc)
     //   LoadDBKybdMacro (gMacroRvcOriginal)
    //ENDIF
    gEnTicket=0
    gEnTicketPickup=0
Endevent

Event trans_cncl
    gNumeroPedido=""
    gEnTicket=0
    gEnTicketPickup=0
Endevent

Event inq: 1
    call cronometro
endevent

Event inq: 2
    
    call buscaPedidosEncolados("",0)
endevent

Event inq: 3
    call mostrarListaPedidoInfo
endevent

Event inq: 4
    call buscarNotasPedido
endevent

Event inq : 5
    call remarcarPedidoPos
endevent

Event inq: 6
    call mostrarListaPedidoInfoCancelar
endevent

Event inq: 7
    call mostrarListaPedidoConfirmar
endevent

Event inq: 8
    call cancelarPedidoActual
endevent

Event inq: 9
    VAR answer:A10=""
    IF (gSbx=0)
        call consultaragregador( answer, "Elija Agregador","PEDIDOSYA","GLOVO","RAPPI" )
    ENDIF
    call mostrarListaPedidoEntrega(answer)
Endevent
Event inq: 11
    VAR solodeli:N2=0
    IF (gSbx=1)
        call validaItemsDelivery(solodeli)
        IF (gEnTicketPickup=0)
            IF (solodeli=1)
                //gEnTicket=1
                IF (gEnticket=1)
                    IF (@TTLDUE>0)
                        call logear("Imprimir Comanda ", 1)
                        //LoadDBKybdMacro gMacroComandaSbx
                        //LoadKybdMacro MakeKeys(@TTLDUE)
                        call ImprimirComanda
                        //pms8 uruguay es 11
                        //IF (gsbxuy=1)
                        //    LoadKybdMacro Key(24, 16384 * 6 + 11), MakeKeys( "2" ), @Key_enter
                        //ENDIF
                        call pagarConTender
                    ENDIF
                ELSE
                    ExitWithError ("Debe ir a utilidades de gerente")
                    //LoadKyBdMacro Key (19,gSluPagos) //SLU medios de pago 
                ENDIF
            ELSEIF (solodeli=2)
                ExitWithError ("NO PUEDE MEZCLAR PRODUCTOS DELIVERY CON MOSTRADOR")
            ELSEIF (gEnTicket=1 and solodeli=0 and gEnTicketPickup=0)
                ExitWithError ("TICKET INICIADO COMO DELIVERY, CANCELAR PARA PEDIDO MOSTRADOR")
            ELSE
              VAR error:A80
              format error as "Pago no automatico: Solodeli=",solodeli,"  GenTicket=",gEnTicket, " enTicketPickup=",gEnTicketPickup
              call logear(error, 1)
            ENDIF
        ELSE
            IF (solodeli<2)
                
                IF (@TTLDUE>0)
                    call logear("Imprimir Comanda ", 1)
                    //LoadDBKybdMacro gMacroComandaSbx
                    //LoadKybdMacro MakeKeys(@TTLDUE)
                    call ImprimirComanda
                    //pms8 uruguay es 11
                    //IF (gsbxuy=1)
                    //    LoadKybdMacro Key(24, 16384 * 6 + 11), MakeKeys( "2" ), @Key_enter
                    //ENDIF
                    call pagarConTender
                ENDIF
               
            ELSEIF (solodeli=2)
                ExitWithError ("NO PUEDE MEZCLAR PRODUCTOS DELIVERY CON PICKUP")
            ELSE
              VAR error:A80
              format error as "Pago no automatico pickup: Solodeli=",solodeli,"  GenTicket=",gEnTicket, " enTicketPickup=",gEnTicketPickup
              call logear(error, 1)
            ENDIF
        ENDIF
    ELSE
        IF (gEnTicket=1)
            //IF (gEnTicketPickup=1)
                call logear("Imprimir Comanda ", 1)
                call ImprimirComanda
            //ENDIF
            call pagarConTender
        ENDIF
    ENDIF
endevent

Event inq: 12
    //aplica costo de envio pedidosya
    IF (gCostoEnvio<>0)
        LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCostoEnvio)
    ELSE
        InfoMessage ("ERROR: No dispongo del costo de envio")
    ENDIF
endevent

Event inq: 13 //imprimir comanda pedido actual
    call ImprimirComanda
Endevent

Event inq: 14
    call validaItemsDelivery(solodeli)
    IF (solodeli=1)
       
    ELSEIF (solodeli=2)
        ExitWithError ("NO PUEDE MEZCLAR PRODUCTOS DELIVERY CON MOSTRADOR")
    ELSEIF (gEnTicket=1 and solodeli=0 and gEnTicketPickup=0)
        ExitWithError ("TICKET INICIADO COMO DELIVERY, CANCELAR PARA PEDIDO MOSTRADOR")
    ENDIF
    
endevent

Event inq: 15
    IF (gNumeroPedido<>"")
        call remarcarDescuentosPos
    ELSE
        infomessage "Debe existir un pedido marcado"
    ENDIF
Endevent

Event inq: 16 //cambio de rvc
    LoadDBKybdMacro (gMacroRvcDelivery)
EndEvent

Event inq: 17
      call buscaPedidosEncolados("PEDIDOSYA",0)
endevent

Event inq: 18
    call buscaPedidosEncolados("GLOVO",0)
endevent
Event inq: 19
    call buscaPedidosEncolados("RAPPI",0)
endevent

Event inq: 20 //pedidos pickup
    call buscaPedidosEncolados("",2)
endevent

Event inq: 21 //pedidos Curbside
    call buscaCurbside()
endevent

Event Idle_No_Trans
    gRvcOriginal=@RVC
    //if (@RVC=3 or gSbx=1 or gChile=1 or gPickup=1)
        if (gTiempoIdle<>@Minute)
            call hayPedidosEncolados
			
			call hayPedidosCurbside

            gTiempoIdle=@Minute
            @IDLE_SECONDS=60
		ELSEIF (@Hour<>gTiempoUltHora)
            call initDelivery
        ENDIF
    //ENDIF
endevent

Event srvc_total: *
   // gEnTicket=0
endevent

SUB initDelivery
    gTouch=@ALPHASCREEN
    gEnTicket=0
    gEnTicketPickup=0
    gTiempo=0
    gFiscal=0
    gPedidoIncompleto=0
    gNumeroPedido=""
    gNumeroPedidoProv=""
    gNumeroPedidoNotas=""
    gUltNumeroPedido=""
    gPagaCon=0
    gDescuentoCodigo=0
    gTender=0
    
    ORDER_TYPE_RA=393238 //6
    ORDER_TYPE_PY=393236 //4
    ORDER_TYPE_GL=393237 //5

    call ODBCinit
    call solicitarPms
    gCostoEnvio=0
    gCostoEnvioCodVariable=0
    gCostoEnvioMontoVariable=0
    gRvcOriginal=@RVC
    
    Call setFilePaths
    gSbxUY=0
    call esDelivery(gSbx,"DeliverySbx.cfg")
    IF (gSbx=2)
        gSbx=1
        gSbxUY=1
    ENDIF
    call esDelivery(gChile,"DeliveryChile.cfg")
    //veo si es pickup
    call esPickup(gPickup,"Pickup.cfg")
    gPantalla=1023
    IF (gSbx=1)
        ORDER_TYPE_PY=393238 //6
        gPantalla=54
    ENDIF
    gTiempoUltHora=@HOUR
    if (@RVC=3 or gSbx=1 or gChile=1 or gPickup=1)
        IF (gPickup=0) 
            call solicitarCostoEnvio
        ENDIF
        @IDLE_SECONDS=60
        gTiempoIdle=@Minute
        gTiempoUltTicket=@Minute
    endif
    
ENDSUB

SUB leerEsDeli
    Call setFilePaths
    gSbxUY=0
    call esDelivery(gSbx,"DeliverySbx.cfg")
    IF (gSbx=2)
        gSbx=1
        gSbxUY=1
    ENDIF
    call esDelivery(gChile,"DeliveryChile.cfg")
    gPantalla=1023
    IF (gSbx=1)
        ORDER_TYPE_PY=393238 //6
        gPantalla=54
    ENDIF
    call esPickup(gPickup,"Pickup.cfg")
ENDSUB
//************************  Reloj  ******************************
//cronometo
//****************************************************************
sub cronometro
    var tiempo2: N9
    var dif: N8
    var mensaje: A50
    
    if gTiempo=0
        gTiempo=@Month*2700000+@Day*86400+@Hour*3600+@Minute*60+@Second
        format mensaje as "Inicio Cronometro"           
        call mostrarMensaje(mensaje)
    else
        tiempo2=@Month*2700000+@Day*86400+@Hour*3600+@Minute*60+@Second
        dif=tiempo2-gTiempo
        

        format mensaje as "Tiempo de atencion: ",dif," segundos"
        gTiempo=0
        call mostrarMensaje(mensaje)
    endif
    
endsub
//************************  Delivery  ******************************
//Consulta Pedidos Encolados
//****************************************************************
sub buscaPedidosEncolados(VAR agregador:A20, VAR forzarpickup:N1)
    VAR statuspull :N1=0
    VAR pickup: N1=0
    IF (forzarpickup=0) THEN
        pickup=gPickup
    ELSE
        pickup=forzarpickup
    ENDIF
    call validaPull(statuspull)
    if (statuspull=1)
        format gDatos as "ENCOLADOS|",@WSID,"|",gVersion,"|",@RVC,"|",agregador,"|",pickup
   // gNumeroPedido=""
        call EnviaTransaccion
        call RecibeTransaccionPedidos
        call procesarRespuestaPedidos(1)
    else
        ErrorMessage "DEBE REALIZAR PULL ANTES DE MARCAR PEDIDO O NO TIENE CAJA ASIGNADA"
    endif
endsub

//************************  Delivery  ******************************
//Hay Pedidos Encolados?
//****************************************************************
sub hayPedidosEncolados
    VAR valorpickup:N1=0
    valorpickup=gPickup
    IF (gSbx=1)
        valorpickup=2
    ENDIF
    format gDatos as "HAYPEDIDOS|",@WSID,"|",gVersion,"|",@RVC,"|",valorpickup
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(0)
endsub

//************************  Delivery  ******************************
//Hay Pedidos Curbside?
//****************************************************************
sub hayPedidosCurbside
    VAR valorpickup:N1=0
    valorpickup=gPickup
    IF (gSbx=1)
        valorpickup=2
    ENDIF
    format gDatos as "HAYCURB|",@WSID,"|",gVersion,"|",@RVC,"|",valorpickup
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(0)
endsub

//************************  Delivery  ******************************
//Consulta Pedidos Curbside
//****************************************************************
sub buscaCurbside()
    
	format gDatos as "CURBSIDE|",@WSID,"|",gVersion,"|",@RVC,"||0"

	call EnviaTransaccion
	call RecibeTransaccionPedidos
	call procesarRespuestaPedidos(1)
    
endsub
//************************  Delivery  ******************************
//COnsultar costo envio pedidosya
//****************************************************************
sub solicitarCostoEnvio
    format gDatos as "COSTOENVIO|",@WSID,"|",gVersion,"|",@RVC,"|"
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
       //InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
       gStatus=1
    else
       Split @RxMsg, "|", gCostoEnvio
    endif
endsub
//******************************************************************
// Cargar modelo fiscal
//******************************************************************
SUB GetModeloFiscal
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    gfiscal=1
    //FORMAT ArchConfig AS g_path, "FISCAL", ".cfg"

    //FOPEN Handle, ArchConfig, READ
    //IF Handle <> 0
    //   FREAD Handle, gfiscal
    //   FCLOSE Handle
	//else
	//	gfiscal = 0
    //ENDIF
ENDSUB
//----------------------------------------------------------------
//---------------- Graba una linea a archivo
//----------------------------------------------------------------
SUB grabarLinea(Var filehandle:N5,VAR texto:A65)
    VAR auxwrite:N4

     FWriteBfr FileHandle, texto,len(texto), auxwrite 
     FWriteBfr FileHandle, chr(13),1, auxwrite 
     FWriteBfr FileHandle, chr(10),1, auxwrite 
ENDSUB
//************************  Delivery  ******************************
//imprimir comanda actual
//****************************************************************
SUB ImprimirComanda
    IF (gChile=0)
		IF (gSbxUY=1)
			//call imprimirComandaActualUruguay
			call ImprimirComandaActualTermica
		ELSE
			call getModeloFiscal
			IF (gFiscal=0)
				call imprimirComandaActualTradicional
			ELSE
				call ImprimirComandaActualTermica
			ENDIF
		ENDIF
	ELSE
		call imprimirComandaActualChile
	ENDIF
ENDSUB
//************************  Delivery  ******************************
//imprimir comanda actual
//****************************************************************
sub imprimirComandaActualTermica
    Var comando		:	A20
    Var codigo		:	A2
	Var z 			: 	N1
	Var NComandas	: 	N1
    format gDatos as "IMPRIMIRCOMANDA|",@WSID,"|",gVersion,"|",@RVC,"|",gNumeroPedido
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
       InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
       gStatus=1
    else
       Split @RxMsg, "|", codigo,comando,gComandaCant,gComanda[]
       IF (gComandaCant>0)
            Var j :N3 = 0
            Var i :N1
            Var aux : A70
            Prompt "Imprimiendo Comanda......"

            VAR k:N1=0
            Var lineaaux:A50=""
            VAR ConfigFile       : A128       // File Name
            VAR FileHandle       : N5  = 0   // File handle
            VAR auxwrite : N4
			VAR sTmpText		: A1000
			
			NComandas = 2
			
			if gSbx = 1
				NComandas = 1
			EndIf
			
			if gSbxUY = 1
				NComandas = 1
			EndIf

            FORMAT ConfigFile AS g_path, "DNFH.txt"
            FOPEN FileHandle, ConfigFile, WRITE


            IF FileHandle <> 0
				for z = 1 to NComandas
					if gSbxUY = 1
						format aux as "                    COMANDA DELIVERY"
						call grabarLinea(FileHandle, aux )
						format aux as "--------------------------------------------------------"
						call grabarLinea(FileHandle, aux )
						format aux as "Nombre: ",gNombreCliente
						call grabarLinea(FileHandle, aux )
						format aux as "Tel: ",gTelefonoCliente
						call grabarLinea(FileHandle, aux )
						format aux as "Total: ",gPagaCon
						call grabarLinea(FileHandle, aux )


						IF (gNotasCliente<>"-")
							format sTmpText as gNotasCliente
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						IF (gNotasCliente2<>"-")
							 format sTmpText as gNotasCliente2
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						IF (gNotasCliente3<>"-")
							 format sTmpText as gNotasCliente3
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						IF (gNotasCliente4<>"-")
							 format sTmpText as gNotasCliente4
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						j=1
						WHILE (j<=gComandaCant and dll_status =0)               
							aux=mid(gComanda[j],1,50) 
							IF (aux="")
								aux=" "
							ENDIF
							if (j<3 or j=4)
								format sTmpText as aux
								call grabarLinea(FileHandle, sTmpText )
								format sTmpText as ""
								call grabarLinea(FileHandle, sTmpText )
							else
								format sTmpText as aux
								call grabarLinea(FileHandle, sTmpText )
							EndIf

							j=j+1
						ENDWHILE
						IF (gNumeroPedidoProv<>"" and gNumeroPedidoProv<>"0")
								format aux as "Cod: ",gNumeroPedidoProv
								call grabarLinea(FileHandle, aux )
						ENDIF

						call grabarLinea(FileHandle, " " )
						call grabarLinea(FileHandle, " " )
						if (z<NComandas)
							call grabarLinea(FileHandle, chr(&1C) )
						EndIf
					else
						format aux as "1|0|0^                    COMANDA DELIVERY"
						call grabarLinea(FileHandle, aux )
						format aux as "1|0|0^--------------------------------------------------------"
						call grabarLinea(FileHandle, aux )
						format aux as "1|0|0^Nombre: ",gNombreCliente
						call grabarLinea(FileHandle, aux )
						format aux as "1|0|0^Tel: ",gTelefonoCliente
						call grabarLinea(FileHandle, aux )
						format aux as "1|0|0^Total: ",gPagaCon
						call grabarLinea(FileHandle, aux )


						IF (gNotasCliente<>"-")
							format sTmpText as "1|0|0^", gNotasCliente
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						IF (gNotasCliente2<>"-")
							 format sTmpText as "1|0|0^", gNotasCliente2
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						IF (gNotasCliente3<>"-")
							 format sTmpText as "1|0|0^", gNotasCliente3
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						IF (gNotasCliente4<>"-")
							 format sTmpText as "1|0|0^", gNotasCliente4
							call grabarLinea(FileHandle, sTmpText )
						ENDIF
						j=1
						WHILE (j<=gComandaCant and dll_status =0)               
							aux=mid(gComanda[j],1,50) 
							IF (aux="")
								aux=" "
							ENDIF
							if (j<3 or j=4)
								format sTmpText as "1|0|1^", aux
								call grabarLinea(FileHandle, sTmpText )
								format sTmpText as "1|0|0^ "
								call grabarLinea(FileHandle, sTmpText )
							else
								format sTmpText as "1|0|0^", aux
								call grabarLinea(FileHandle, sTmpText )
							EndIf

							j=j+1
						ENDWHILE
						IF (gNumeroPedidoProv<>"" and gNumeroPedidoProv<>"0")
								format aux as "1|0|0^Cod: ",gNumeroPedidoProv
								call grabarLinea(FileHandle, aux )
						ENDIF

						call grabarLinea(FileHandle, "1|0|0^ " )
						call grabarLinea(FileHandle, "1|0|0^ " )
						if (z<NComandas)
							call grabarLinea(FileHandle, chr(&1C) )
						EndIf
					EndIf
					
				EndFor
                fclose filehandle
                //imprimo 
                LoadDBKybdMacro gMacroImpTermica 
                Prompt "idle"
            ENDIF
       ELSE
            InfoMessage("ERROR: No pude obtener la comanda")
       ENDIF
    endif
endsub
//************************  Delivery  ******************************
//imprimir comanda actual
//****************************************************************
sub imprimirComandaActualTradicional
    Var comando:A20
    Var codigo:A2
    format gDatos as "IMPRIMIRCOMANDA|",@WSID,"|",gVersion,"|",@RVC,"|",gNumeroPedido
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
       InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
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
            FOR i=1 to 1 
                DLLCall_CDECL dll_handle, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )

                IF ( dll_status <> 0 )
                        ErrorMessage dll_status_msg
                ENDIF
                j=1    
                
                format aux as "Nombre: ",gNombreCliente
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )                
                format aux as "Tel: ",gTelefonoCliente
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )                
                format aux as "Total: ",gPagaCon
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )                

                 IF (gNotasCliente<>"-")
                        DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, gNotasCliente )
                   ENDIF
                   IF (gNotasCliente2<>"-")
                        DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, gNotasCliente2 )
                   ENDIF
                   IF (gNotasCliente3<>"-")
                        DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, gNotasCliente3 )
                   ENDIF
                   IF (gNotasCliente4<>"-")
                        DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, gNotasCliente4 )
                   ENDIF

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
                IF (gNumeroPedidoProv<>"" and gNumeroPedidoProv<>"0")
                        format aux as "Cod: ",gNumeroPedidoProv
                        DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
                ENDIF


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
//************************  Delivery  ******************************
//imprimir comanda actual Uruguay
//****************************************************************
sub imprimirComandaActualUruguay
    Var comando:A20
    Var codigo:A2
    VAR retval:N9
    Var auximp:A4

    format gDatos as "IMPRIMIRCOMANDA|",@WSID,"|",gVersion,"|",@RVC,"|",gNumeroPedido
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
       InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
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
            FOR i=1 to 1 
                DLLCall_CDecl dll_handle,InitializeDriver(ref retVal)
                IF ( retval <> 0 )
                        ErrorMessage "Delivery:Error inicializando impresora"
                ENDIF
                j=1    
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                
                format aux as "Nombre: ",gNombreCliente
                DLLCall_CDecl dll_handle, PrintLine(aux, Ref retVal)
                format aux as "Tel: ",gTelefonoCliente
                DLLCall_CDecl dll_handle, PrintLine(aux, Ref retVal)
                format aux as "Total: ",gPagaCon
                DLLCall_CDecl dll_handle, PrintLine(aux, Ref retVal)


                 IF (gNotasCliente<>"-")
                        DLLCall_CDecl dll_handle, PrintLine(gNotasCliente, Ref retVal)
                   ENDIF
                   IF (gNotasCliente2<>"-")
                        DLLCall_CDecl dll_handle, PrintLine(gNotasCliente2, Ref retVal)
                   ENDIF
                   IF (gNotasCliente3<>"-")
                        DLLCall_CDecl dll_handle, PrintLine(gNotasCliente3, Ref retVal)
                   ENDIF
                   IF (gNotasCliente4<>"-")
                        DLLCall_CDecl dll_handle, PrintLine(gNotasCliente4, Ref retVal)
                   ENDIF

                WHILE (j<=gComandaCant and retval =0)

                   


                    aux=gComanda[j]
                    IF (aux="")
                        aux=" "
                    ENDIF
                    DLLCall_CDecl dll_handle, PrintLine(aux, Ref retVal)
                    DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                    IF ( retval <> 0 )
                        ErrorMessage "Delivery: Error linea comanda"
                    ENDIF
                    j=j+1
                ENDWHILE
                IF (gNumeroPedidoProv<>"" and gNumeroPedidoProv<>"0")
                        format aux as "Cod: ",gNumeroPedidoProv
                        DLLCall_CDecl dll_handle, PrintLine(aux, Ref retVal)
                ENDIF

                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)
                DLLCall_CDecl dll_handle, PrintLine(" ", Ref retVal)

                Format auximp As Chr(&1D), Chr(&56), "1" 
                DLLCall_CDecl dll_handle, PrintLine(auximp, Ref retVal)

                IF ( retval <> 0 )
                        ErrorMessage "Delivery: Error cortando comanda"
                ENDIF
            ENDFOR
            Prompt "idle"

            Call descargarDllImpresora
       ELSE
            InfoMessage("ERROR: No pude obtener la comanda")
       ENDIF
    endif
endsub
//************************  Delivery  ******************************
//imprimir comanda actual CHILE
//****************************************************************
sub imprimirComandaActualChile
    Var comando:A20
    Var codigo:A2
    var sExtBits	 : A4

    sExtBits = FCR_EXT_BITS_ON

    format gDatos as "IMPRIMIRCOMANDA|",@WSID,"|",gVersion,"|",@RVC,"|",gNumeroPedido
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
       InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
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
            FOR i=1 to 1 

                format gsFCRCmdReturn as ""
                format gsFCRFieldInfo as FCR_CMD_SEPARATOR_CHR,"0",  FCR_CMD_SEPARATOR_CHR,"0"
                DLLCall_CDECL dll_handle, epson_generic_fiscal_command(ref giFCRStatus, ref gsFCRMsg, \
													  ref gsFCRCmdReturn, \
													  ref FCR_CMD_OPEN_FCR_NON_FISCAL_COUPON, \
													  ref FCR_EXT_BITS_OFF, \
													  ref gsFCRFieldInfo, \
													  ref gsFCRFiscalStatus)
                IF ( gsFCRCmdReturn <> "0000" )
                        ErrorMessage "Error driver epson"
                ENDIF
                j=1    

                WHILE (j<=gComandaCant and gsFCRCmdReturn <> "0000")
                    aux=gComanda[j]
                    IF (aux="")
                        aux=" "
                    ENDIF
                    format gsFCRFieldInfo as FCR_CMD_SEPARATOR_CHR,aux{=42}
                    DLLCall_CDECL dll_handle, epson_generic_fiscal_command(ref giFCRStatus, ref gsFCRMsg, \
													  ref gsFCRCmdReturn, \
													  ref FCR_CMD_PRINT_FCR_NON_FISCAL_ITEM, \
													  ref FCR_EXT_BITS_OFF, \
													  ref gsFCRFiscalStatus)
													  ref gsFCRFieldInfo, \
													  ref gsFCRFiscalStatus)
	
                    IF ( gsFCRCmdReturn <> "0000" )
                        rrorMessage "Error driver epson 2"
                    ENDIF
                    j=j+1
                ENDWHILE

                format gsFCRFieldInfo as FCR_CMD_SEPARATOR_CHR, "0", \
							 FCR_CMD_SEPARATOR_CHR, "", \
							 FCR_CMD_SEPARATOR_CHR, "0", \
							 FCR_CMD_SEPARATOR_CHR, "", \
							 FCR_CMD_SEPARATOR_CHR, "0", \
							 FCR_CMD_SEPARATOR_CHR, ""
                                                  
		DLLCall_CDECL dll_handle, epson_generic_fiscal_command(ref giFCRStatus, ref gsFCRMsg, \
													  ref gsFCRCmdReturn, \
													  ref FCR_CMD_CLOSE_FCR_NON_FISCAL_COUPON, \
													  ref sExtBits, \
													  ref gsFCRFieldInfo, \
													  ref gsFCRFiscalStatus)
                IF ( gsFCRCmdReturn <> "0000" )
                        rrorMessage "Error driver epson 3"
                ENDIF
            ENDFOR
            Prompt "idle"

            Call descargarDllImpresora
       ELSE
            InfoMessage("ERROR: No pude obtener la comanda")
       ENDIF
    endif
endsub
//************************  Delivery  ******************************
//Consulta Pedidos Encolados
//****************************************************************
sub buscarNotasPedido

    if (gNumeroPedido<>"")
        format gDatos as "NOTAS|",@WSID,"|",gVersion,"|",gNumeroPedidoNotas

        call EnviaTransaccion
        call RecibeTransaccionPedidos
        call procesarRespuestaPedidos(0)
    endif
endsub
//************************  Delivery  ******************************
//Consulta lista de Pedidos Encolados para mostrar info
//****************************************************************
sub mostrarListaPedidoInfo
    format gDatos as "ENCOLADOSINFO|",@WSID,"|",gVersion,"|","|","|",gPickup
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(2)
endsub
//************************  Delivery  ******************************
//Consulta lista de Pedidos Encolados para mostrar info con cancelacion
//****************************************************************
sub mostrarListaPedidoInfoCancelar
    format gDatos as "ENCOLADOS|",@WSID,"|",gVersion,"|","|","|",gPickup
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(3)
endsub
//************************  Delivery  ******************************
//Consulta lista de Pedidos Encolados para confirmar tiempo entrega
//****************************************************************
sub mostrarListaPedidoConfirmar
    format gDatos as "ENCOLADOSCONF|",@WSID,"|",gVersion,"|","|","|",gPickup
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(4)
endsub
//************************  Delivery  ******************************
//Consulta lista de Pedidos para confirmar la entrega
//****************************************************************
sub mostrarListaPedidoEntrega(VAR agregador:A20)
    format gDatos as "ENCOLADOSENTREGA|",@WSID,"|",gVersion,"|",@RVC,"|",agregador,"|",gPickup
    
    call EnviaTransaccion
    call RecibeTransaccionPedidos
    call procesarRespuestaPedidos(5)
endsub
//************************  Delivery  ******************************
//Remarca pedido en pos por si cortaron el proceso
//****************************************************************
sub remarcarPedidoPos
    if (gNumeroPedido<>"")
        gDemoraTexto=""
        format gDatos as "REPEDIDO|",@WSID,"|",gVersion,"|",gUltNumeroPedido,"|",gDemora
        call EnviaTransaccion
        call RecibeTransaccionIngresarPedido
        IF (gDemoraTexto="")
            call textoDemora(gDemora)
        ENDIF
        call procesarRespuestaPedidos(0)
    endif
endsub
//************************  Delivery  ******************************
//Remarca descuentos en pos por si cortaron el proceso
//****************************************************************
sub remarcarDescuentosPos
    if (gNumeroPedido<>"")
        gDemoraTexto=""
        format gDatos as "REDESCUENTO|",@WSID,"|",gVersion,"|",gNumeroPedido
        call EnviaTransaccion
        call RecibeTransaccionRemarcarDescuento
        call procesarRespuestaPedidos(0)
    endif
endsub
//************************  Delivery ******************************
//Envia transaccion al servidor central
//****************************************************************
sub EnviaTransaccion
	gStatus=0
	TXMSG gDatos //Manda los datos al puerto que definimos
	//ErrorMessage "Enviado"
	GetRXMsg "Esperando Respuesta de Servicio" //Estado de espera
endsub
//************************* Delivery ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionPedidos
        var mensaje: A170=""
        var jj: N2

        gHayPedidosTipo=0

	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
           gStatus=1
	else
          Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gContadorPedidos,gPedidos[],gCostoEnvio,gHayPedidosTipo
	endif
	
endsub
//************************* Delivery ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionIngresarPedido
        var mensaje: A170=""
        var jj: N2

        gContadorItems=0

	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gNumeroPedido,gDemora,gDemoraTexto,gNombreCliente,gDireccionCliente,gDireccionCliente2,gDireccionCliente3,gTelefonoCliente,\
                gNotasCliente,gNotasCliente2,gNotasCliente3,gNotasCliente4,gFormaPago,gVertical,gPagaCon,gDescuentoCodigo,gDescuentoValor,gDescuentoAjuste,gCostoEnvioCodVariable,gCostoEnvioMontoVariable,gMacroRvcDelivery,gMacroRvcOriginal,gOrderType,gDescEfectivo,gDescTarjeta,gTenderEfectivo,gTenderTarjeta,gProveedor,gNumeroPedidoProv,gHayNotas,gPedidoIncompleto,gContadorItems,gCodigos[]:gCantidades[]:gNiveles[],gEnTicketPickup
           IF (gDemoraTexto="")
                call textoDemora(gDemora)
           ENDIF
	endif
endsub
//************************* Delivery ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccionRemarcarDescuento
        var mensaje: A170=""
        var jj: N2

        gContadorItems=0

	if @RxMsg = "_timeout" //Llega la Respuesta
	   InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO DE DELIVERY"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gDescuentoCodigo,gDescuentoValor,gDescuentoAjuste,gCostoEnvioCodVariable,gCostoEnvioMontoVariable
           
	endif
endsub
//************************* Delivery  *****************************
//Dispatcher de respuestas de pedidos encolados
//****************************************************************
Sub procesarRespuestaPedidos(Var tipo:N1)
    //var tipo: N1
    //tipo=1
    if (gCodigoRespuesta="1") //Respuesta OK lista de pedidos
       call procesarMenuPedidos(tipo)
    elseif (gCodigoRespuesta="2") //Respuesta OK ingresar pedido a pos
        call ingresarPedidoPos
        gNumeroPedidoNotas=gNumeroPedido
        if (gHayNotas=1)
            call buscarNotasPedido
        endif
    elseif (gCodigoRespuesta="3") //Respuesta OK lista de pedidos para mostrar info sin cancelar
      // tipo=2
       call procesarMenuPedidos(tipo)
    elseif (gCodigoRespuesta="4") //Respuesta OK Mostrar Info pedido con o sin cancelar
        call mostrarInfoPedido(tipo)
    elseif (gCodigoRespuesta="5") //Respuesta OK Mostrar Notas pedido
        call mostrarNotasPedido
    elseif (gCodigoRespuesta="6") //hay pedidos para idle
        if (gContadorPedidos=1)
            Beep
            ErrorBeep
            Beep
            ErrorBeep
            Beep
            ErrorBeep
            IF (gHayPedidosTipo=1)
                //call mostrarMensaje("HAY PEDIDOS DELIVERY")
				call mostrarMensaje("HAY PEDIDOS")
            ELSEIF (gHayPedidosTipo=2)   
                //call mostrarMensaje("HAY PEDIDOS PICKUP")
				call mostrarMensaje("HAY PEDIDOS")
            ELSEIF (gHayPedidosTipo=3)
                //call mostrarMensaje("HAY PEDIDOS PICKUP Y DELIVERY")
				call mostrarMensaje("HAY PEDIDOS")
            ELSE
                //call mostrarMensaje("HAY PEDIDOS DELIVERY")
				call mostrarMensaje("HAY PEDIDOS")
            ENDIF
        endif
    elseif (gCodigoRespuesta="7") //Respuesta OK lista de pedidos para mostrar info sin cancelar
       //tipo=3
       call procesarMenuPedidos(tipo)
    //elseif (gCodigoRespuesta="8") //Respuesta OK Mostrar Info pedido CON cancelar
      //  call mostrarInfoPedido(1)
    elseif (gCodigoRespuesta="10") //Respuesta OK lista de pedidos para marcar entrega a deliverybiy
       call procesarMenuPedidos(tipo)
    elseif (gCodigoRespuesta="11") //Respuesta OK reaplicar descuento
       call aplicarDescuentoYCostoEnvio
	elseif (gCodigoRespuesta="12") //Respuesta OK reaplicar descuento
       if (gContadorPedidos=1)
            Beep
            ErrorBeep
            Beep
            ErrorBeep
            Beep
            ErrorBeep
            call mostrarMensaje("CLIENTE EN ESPERA")
        endif
	elseif (gCodigoRespuesta="13") //Respuesta OK lista de pedidos curbside para marcar entrega
       call procesarCurbsidePedidos()
    else
        call mostrarMensaje(gDescRespuesta)     
    endif
endsub

//*************************** Delivery *****************************
// Ingresa items del pedido al pos
// ****************************************************************
Sub ingresarPedidoPos
    Var texto   :A80
    Var jj      :N3
    Var ii      :N2
    Var pricelevel:N2
    Var priceaux:N2
    format texto as "Error: el pedido tiene 0 items"
    IF (gContadorItems=0)
        call MostrarMensaje(texto)
    ELSE
        IF (gPedidoIncompleto=1)
            call MostrarMensaje("VERIFICAR PEDIDO CON COMANDA")
        ENDIF
        //LoadDBKybdMacro (gMacroRvcDelivery)
        //guardo en las infolines la direccion
        clearchkinfo
        savechkinfo gNombreCliente
        savechkinfo gDireccionCliente
       // savechkinfo gDireccionCliente2

		var Tempvert	: A40
		if (gVertical<>"")
			format TempVert as "VERT: ", gVertical
		EndIf
		

        savechkinfo gNotasCliente
        savechkinfo gNotasCliente2
        savechkinfo gNotasCliente3
        savechkinfo gNotasCliente4
		savechkinfo TempVert

       // savechkinfo gTelefonoCliente

      // LoadKybdMacro Key(1,ORDER_TYPE_BASE+gOrderType)
        
        format texto as "P ",gNumeroPedido,"-",gProveedor
         call logear(texto, 1)
        LoadKybdMacro Key(1,ORDER_TYPE_BASE+gOrderType)
        IF (gFormaPago="EFECTIVO")
            gFormaPago=gDescEfectivo
            gTender=gTenderEfectivo
        ELSE
            gFormaPago=gDescTarjeta
            gTender=gTenderTarjeta
        ENDIF

        savechkinfo texto
        format texto as "Total: ",gPagaCon
        savechkinfo texto
        format texto as "Paga: ",gFormaPago," ",gTender
        call logear(texto, 1)
        savechkinfo texto
        savechkinfo gDemoraTexto
        IF (gNumeroPedidoProv<>"" and gNumeroPedidoProv<>"0")
            format texto as "Cod:",gNumeroPedidoProv
            savechkinfo texto
        ENDIF
        gEnTicket=1
        //------------------
        gUltNumeroPedido=gNumeroPedido
        pricelevel=@slvl
        FOR jj=1 to gContadorItems
            FOR ii=1 to gCantidades[jj]              
                IF (gNiveles[jj]>0)
                    IF (gNiveles[jj]<5)
                        LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+gNiveles[jj]) //cambia el menulevel antes 458756
                        priceaux=gNiveles[jj]
                    ELSE
                        priceaux=gNiveles[jj]
                        LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458823+gNiveles[jj])
                    ENDIF
                ENDIF
                LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigos[jj])
                IF (pricelevel<5)
                    LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+pricelevel) //cambia el menulevel antes 458756
                ELSE
                    LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458823+pricelevel)
                ENDIF
            ENDFOR
        ENDFOR
       
        //aplico costo envio variable
        IF ((gCostoEnvioCodVariable>0) or (gDescuentoCodigo>0))
            IF (priceaux>0)
                IF (priceaux<5)
                    LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+priceaux) //cambia el menulevel antes 458756
                ELSE
                    LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458823+priceaux)
                ENDIF
            ENDIF
            IF (gCostoEnvioMontoVariable>0)
                 call logear("Costo Envio Variable", 1)
                 LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCostoEnvioCodVariable), MakeKeys(gCostoEnvioMontoVariable), @KEY_ENTER
            ENDIF
               //aplico descuento si hay
            IF (gDescuentoCodigo>0)
                IF (gDescuentoValor>0)
                     call logear("Descuento Variable", 1)
                    LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gDescuentoCodigo), MakeKeys(gDescuentoValor), @KEY_ENTER
                ENDIF
                LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gDescuentoAjuste)
            ENDIF
            //
        ENDIF
        
        IF (pricelevel<5)
            LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+pricelevel) //cambia el menulevel antes 458756
        ELSE
            LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458823+pricelevel)
        ENDIF
       // LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+pricelevel) //vuelve el menulevel
       //call MostrarMensaje("PEDIDO INGRESADO")
       
        
       
    ENDIF
endsub
//*************************** Delivery *****************************
// Reaplica descuentos
// ****************************************************************
Sub aplicarDescuentoYCostoEnvio
    Var texto   :A80
     call logear("AplicarDescuentoyCostoEnvio", 1)
    //aplico costo envio variable
       IF (gCostoEnvioCodVariable>0)
            LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCostoEnvioCodVariable), MakeKeys(gCostoEnvioMontoVariable), @KEY_ENTER
       ENDIF
    //aplico descuento si hay
    IF (gDescuentoCodigo>0)
        IF (gDescuentoValor>0)
            IF (gDescuentoValor>@TTLDUE)
                gDescuentoValor=@TTLDUE
            ENDIF
            LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gDescuentoCodigo), MakeKeys(gDescuentoValor), @KEY_ENTER
        ENDIF
        LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gDescuentoAjuste)
    ENDIF
endsub
//************************* Delivery  *****************************
//Valida que todos los items sean de un nivel
//****************************************************************
Sub validaItemsDelivery(Ref solodelivery)
    VAR status:A12=""
    VAR i:N3=0
    solodelivery=-1
    //1 solo deli, 0 solo normales, 2 mezclados
    For i = 1 to @NUMDTLT 
       status=mid(@Dtl_status[i],5,1)
        IF ((@DTL_TYPE[i]="M" or @DTL_TYPE[i]="D" ) and @DTL_IS_VOID[i] = 0 and (status="4" or status="C") and @dtl_is_combo_main[i]=0)
            
            IF (solodelivery<2)
                IF (@DTL_SLVL[i]>=7)
                    IF (solodelivery=0)
                        solodelivery=2
                    ELSE
                        solodelivery=1
                    ENDIF
                ELSE
                    IF (solodelivery=1)
                        solodelivery=2
                    ELSE
                        solodelivery=0
                    ENDIF
                ENDIF
            ENDIF
	ENDIF
    EndFor 
EndSub		
//*************************** Delivery *****************************
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
        var lineas              :N2=11

        format mensaje as "Seleccione el pedido - TOTAL: ",gContadorPedidos," -   Version ",gVersion
	Touchscreen	gPantalla
        opcion=0
        maxsel=gContadorPedidos

	IF (gContadorPedidos>lineas) 
            cuantos=lineas            
            maxcar=34
            //maxcar=74
        ELSE 
            cuantos=gContadorPedidos
            maxcar=74
        ENDIF
        //
        IF (gContadorPedidos>(lineas*2)) 
            maxsel=lineas*2
        ENDIF
        
        //maxsel=cuantos

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
                   
                    IF ((jj+lineas)<=gContadorPedidos)
                        IF (len(gPedidos[jj+lineas])<maxcar) 
                            aux2=gPedidos[jj+lineas]  
                        ELSE
                            aux2=mid(gPedidos[jj+lineas],1,maxcar)
                        ENDIF


                        format texto as jj,"-",aux,"   ",jj+lineas,"-",aux2
                    ELSE 
                        format texto as jj,"-",aux
                    ENDIF
                    
                    Display jj,1,texto
                endfor

                Display cuantos+1,1,"Seleccion: "
		DisplayInput cuantos+1, lineas, opcion{2},""
	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	//If kKeyPressed = @KEY_ENTER
                IF opcion>0 and opcion<=maxsel
                     IF tipo=1 //marcar pedido
                        
                        
                        //if (mid(gPedidos[opcion],1,1)=" ")
                        //    call consultarDemora
                        //ELSEIF (mid(gPedidos[opcion],1,1)="L")
                         //   gDemora=-2
                        //else
                         //   gDemora=-1
                        //endif
                        gDemora=-2
                        aux=gDemora
                        if (gDemora<>0)
                           format gDatos as "PEDIDO|",@WSID,"|",gVersion,"|",gPedidos[opcion],"|",aux,"|"
                           call EnviaTransaccion
                           call RecibeTransaccionIngresarPedido
                           call procesarRespuestaPedidos(0)
                        ENDIF
                     ELSEIF (tipo=2 or tipo=3) //info con o sin opcion cancelar
                        format gDatos as "PEDIDOINFO|",@WSID,"|",gVersion,"|",gPedidos[opcion]
                        call EnviaTransaccion
                        call RecibeTransaccionIngresarPedido
                        call procesarRespuestaPedidos(tipo-2)
                     ELSEIF tipo=4  //solo confirmacion de tiempos
                        call consultarDemora
                        if (gDemora<>0)
                           format gDatos as "DEMORA|",@WSID,"|",gVersion,"|",gPedidos[opcion],"|",gDemora
                           call EnviaTransaccion
                           call RecibeTransaccionIngresarPedido
                           //call procesarRespuestaPedidos(0)
                        ENDIF
                     ELSEIF (tipo=5) //entregue al delivery boy
                        format gDatos as "PEDIDOENTREGADO|",@WSID,"|",gVersion,"|",gPedidos[opcion]
                        call EnviaTransaccion
                        call RecibeTransaccionIngresarPedido
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

//*************************** Delivery *****************************
// Procesa menu de pedidos curbside
// ****************************************************************
Sub procesarCurbsidePedidos()
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
	Var mensaje             : A60
	var jj          	:N2
	var texto               : A80
	Var cuantos             :N2
	Var maxsel              :N2
	var aux                 :A80
	var aux2                :A80
	var maxcar              :N2
	var lineas              :N2=11

    format mensaje as "Seleccione pedido a entregar- TOTAL: ",gContadorPedidos," -   Version ",gVersion
	Touchscreen	gPantalla
	opcion=0
	maxsel=gContadorPedidos

	IF (gContadorPedidos>lineas) 
		cuantos=lineas            
		maxcar=34
		//maxcar=74
	ELSE 
		cuantos=gContadorPedidos
		maxcar=74
	ENDIF
        
	IF (gContadorPedidos>(lineas*2)) 
		maxsel=lineas*2
	ENDIF
        

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
				   
			IF ((jj+lineas)<=gContadorPedidos)
				IF (len(gPedidos[jj+lineas])<maxcar) 
					aux2=gPedidos[jj+lineas]  
				ELSE
					aux2=mid(gPedidos[jj+lineas],1,maxcar)
				ENDIF


				format texto as jj,"-",aux,"   ",jj+lineas,"-",aux2
			ELSE 
				format texto as jj,"-",aux
			ENDIF
					
			Display jj,1,texto
		endfor

		Display cuantos+1,1,"Seleccion: "
		DisplayInput cuantos+1, lineas, opcion{2},""
	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	If kKeyPressed = @KEY_ENTER
		IF opcion>0 and opcion<=maxsel
		   format gDatos as "ENTREGACURB|",@WSID,"|",gVersion,"|",gPedidos[opcion],"|",aux,"|"
		   call EnviaTransaccion
		   call RecibeTransaccionIngresarPedido
		   call procesarRespuestaPedidos(0)
		ELSE
			format texto as "Seleccion Invalida"
			call MostrarMensaje(texto)
		ENDIF

	//ElseIf kKeyPressed = @KEY_CANCEL
	//	Format opcion		As ""
         //       LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	EndIf
    Touchscreen	gTouch
EndSub

//*************************** Delivery *****************************
// Muestra notas del pedido
// ****************************************************************
Sub mostrarNotasPedido
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A20
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A80
        var aux2                :A80
        var maxcar              :N2

        format mensaje as "Version ",gVersion
	Touchscreen	gPantalla
        maxcar=74
        //call mostrarMensaje(mensaje)
	IF (gContadorPedidos>11) 
            cuantos=11
        ELSE 
            cuantos=gContadorPedidos
        ENDIF
        
	Window cuantos+1,78, "Notas"
		

		FOR jj=1 to cuantos
                    
                    IF (len(gPedidos[jj])<maxcar) 
                        aux=gPedidos[jj]
                        WHILE (len(aux)<maxcar)
                            format aux as aux," "
                        ENDWHILE
                    ELSE
                        aux=mid(gPedidos[jj],1,maxcar)
                    ENDIF
                    format texto as aux
                   
                    Display jj,1,texto
                endfor

               Display cuantos+1,1,"Ok: "
		DisplayInput cuantos+1, 4, opcion{2},""
	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
        Touchscreen gTouch
EndSub
//*************************** Delivery *****************************
// Procesa menu de ingreso de demora o cancelacion
// ****************************************************************
Sub consultarDemora
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A20
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A80

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	opcion=0
        gDemoraTexto=""

	Window 7,75, "Seleccione la demora, 0 salir"
            Display 1,1,"1 - Entre 15 y 30 min"
            Display 2,1,"2 - Entre 30 y 45 min"
            Display 3,1,"3 - Entre 45 y 60 min"
            Display 4,1,"4 - Entre 60 y 90 min"
           // Display 5,1,"5 - Entre 90 y 120 min"
           // Display 6,1,"6 - Entre 120 y 150 min"
           // Display 7,1,"7 - Entre 150 y 180 min"

            Display 7,1,"Seleccion: "
            DisplayInput 7, 11, opcion{2},""
	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
	gDemora=0
			
	//If kKeyPressed = @KEY_ENTER
        if (opcion>=1 and opcion<=5)
            call textoDemora(opcion)
        else
            gDemora=0
        endif
       // call mostrarmensaje(gDemoraTexto)
	//EndIf
        IF (gDemora=0)
            format texto as "Debe seleccionar una demora para procesar el pedido"
            call MostrarMensaje(texto)
        ENDIF

EndSub
//*************************** Delivery *****************************
// setea el texto correspondiente a la demora
// ****************************************************************
Sub textoDemora(Var opcion:N2)

        gDemoraTexto=""
	
        IF opcion>0 and opcion<=5
             gDemora=opcion
             IF opcion=1
                gDemoraTexto="Entre 15 y 30 min"
             ELSEIF opcion=2
                gDemoraTexto="Entre 30 y 45 min"
             ELSEIF opcion=3
                gDemoraTexto="Entre 45 y 60 min"
             ELSEIF opcion=4
                gDemoraTexto="Entre 60 y 90 min"
             ELSEIF opcion=5
                gDemoraTexto="Entre 90 y 120 min"
             ELSEIF opcion=6
                gDemoraTexto="Entre 120 y 150 min"
             ELSE 
                gDemoraTexto="Entre 150 y 180 min"
             ENDIF
        ENDIF
EndSub
//*************************** Delivery *****************************
// Muestra informacion del pedido
// ****************************************************************
Sub mostrarInfoPedido(Var tipo:N1)
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : A2
        var opcion2             : N1
        Var mensaje             : A20
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A80

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	
        format aux as "Informacion del Pedido ",gNumeroPedido," (Presione C para cancelar el pedido)"
        if (tipo=0)
             format aux as "Informacion del Pedido ",gNumeroPedido
        endif
	Window 8,75, aux
            format aux as "Cliente: ",gNombreCliente
            Display 1,1,aux
            format aux as "Direccion: ",gDireccionCliente,gDireccionCliente2
            Display 2,1,aux
            format aux as "Direccion: ",gBarrioCliente," ",gCiudadCliente
            Display 3,1,aux
            format aux as "Notas: ",gNotasCliente," ",gNotasCliente2
            Display 4,1,aux
            format aux as "Telefono: ",gTelefonoCliente
            Display 5,1,aux
            format aux as "Total: ",gFormaPago," ",gPagaCon
            Display 6,1,aux
            format aux as "Demora: ",gDemoraTexto
            Display 7,1,aux
            DisplayInput 8, 1, opcion{2},""
	WindowEdit	
	WindowClose	
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"

        //If kKeyPressed = @KEY_ENTER
                IF (opcion="c" and tipo=1)
                    opcion=""
                    format aux as "Confirmacion"
                    Window 4,55, aux
                        Display 1,1,"Escriba la palabra 'SI' para confirmar la cancelacion"
                       
                        DisplayInput 3, 1, opcion{2},""
                    WindowEdit	
                    WindowClose
                    //InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
                   // If kKeyPressed = @KEY_ENTER
                        if opcion="si"
                            opcion2=0
                            Touchscreen	gPantalla
                            Window 10,75, "Seleccione el motivo, 0 salir"
                                Display 1,1,"1 - No llegamos hasta la zona indicada"
                                Display 2,1,"2 - No llega al monto minimo"
                                Display 3,1,"3 - Local cerrado"
                                Display 4,1,"4 - Datos del cliente insuficientes"
                                Display 5,1,"5 - Datos del medio de pago incorrectos"
                                Display 6,1,"6 - El cliente lo cancelo"
                                Display 7,1,"7 - Falta de productos en el local"
                                Display 8,1,"8 - Local fuera de servicio"

                                Display 10,1,"Seleccion: "
                                DisplayInput 10, 11, opcion2{1},""
                            WindowEdit	
                            WindowClose	
                            Touchscreen	gTouch
                            //InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
                            //If kKeyPressed = @KEY_ENTER
                            if opcion2>0 and opcion2<9
                                format gDatos as "PEDIDOCANCELAR|",@WSID,"|",gVersion,"|",gNumeroPedido,"|",opcion2
                                call EnviaTransaccion
                                call RecibeTransaccionIngresarPedido
                                call procesarRespuestaPedidos(0)
                            else
                                format aux as "El pedido NO fue cancelado - Opcion invalida"
                                call mostrarMensaje(aux)
                            endif
                        else
                            format aux as "El pedido NO fue cancelado"
                            call mostrarMensaje(aux)
                        endif
                    //endif
                ENDIF
	//EndIf	

EndSub
//*************************** Delivery *****************************
// Cancelar pedido actual
// ****************************************************************
Sub cancelarPedidoActual
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : A2
        var opcion2             : N1
        Var mensaje             : A20
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A80

        format mensaje as "Version ",gVersion
	Touchscreen	gTouch
	
        
        


        if (gUltNumeroPedido<>"")


            format aux as "Informacion del Pedido ",gUltNumeroPedido," (Presione C para cancelar el pedido)"

                Window 8,75, aux
                    format aux as "Cliente: ",gNombreCliente
                    Display 1,1,aux
                    format aux as "Direccion: ",gDireccionCliente,gDireccionCliente2
                    Display 2,1,aux
                    format aux as "Direccion: ",gBarrioCliente," ",gCiudadCliente
                    Display 3,1,aux
                    format aux as "Notas: ",gNotasCliente," ",gNotasCliente2
                    Display 4,1,aux
                    format aux as "Telefono: ",gTelefonoCliente
                    Display 5,1,aux
                    format aux as "Total: ",gFormaPago," ",gPagaCon
                    Display 6,1,aux
                    format aux as "Demora: ",gDemoraTexto
                    Display 7,1,aux
                    DisplayInput 8, 1, opcion{2},""
                WindowEdit	
                WindowClose	

                        IF (opcion="c")
                            opcion=""
                            format aux as "Confirmacion"
                            Window 4,55, aux
                                Display 1,1,"Escriba la palabra 'SI' para confirmar la cancelacion"

                                DisplayInput 3, 1, opcion{2},""
                            WindowEdit	
                            WindowClose
                                 if opcion="si"
                                    opcion2=0
                                    Window 10,75, "Seleccione el motivo, 0 salir"
                                        Display 1,1,"1 - No llegamos hasta la zona indicada"
                                        Display 2,1,"2 - No llega al monto minimo"
                                        Display 3,1,"3 - Local cerrado"
                                        Display 4,1,"4 - Datos del cliente insuficientes"
                                        Display 5,1,"5 - Datos del medio de pago incorrectos"
                                        Display 6,1,"6 - El cliente lo cancelo"
                                        Display 7,1,"7 - Falta de productos en el local"
                                        Display 8,1,"8 - Local fuera de servicio"

                                        Display 10,1,"Seleccion: "
                                        DisplayInput 10, 11, opcion2{1},""
                                    WindowEdit	
                                    WindowClose	

                                    if opcion2>0 and opcion2<9
                                        format gDatos as "PEDIDOCANCELAR|",@WSID,"|",gVersion,"|",gUltNumeroPedido,"|",opcion2
                                        call EnviaTransaccion
                                        call RecibeTransaccionIngresarPedido
                                        call procesarRespuestaPedidos(0)
                                        LOADKYBDMACRO KEY(1, 458755) //cancelo el ticket
                                        gUltNumeroPedido=""
                                        gNumeroPedido=""
                                    else
                                        format aux as "El pedido NO fue cancelado - Opcion invalida"
                                        call mostrarMensaje(aux)
                                    endif
                                else
                                    format aux as "El pedido NO fue cancelado"
                                    call mostrarMensaje(aux)
                                endif
                        ENDIF
        endif
EndSub

//**************************  ************************
//Pagar con el tender
//*****************************************************************
Sub pagarConTender
    var i : n3
    var cntInf :n3 = 0
    var Coma :n2 = 0
    var montoTotal:A16
    var tender: A6
    var paga:A8
    tender=""
    var aux:A60
    var sigue:N1=1
    var pregunta:A60
   
    //paga=gPagaCon+0
    //format aux as "Total: ",@ttldue," gPaga: ",gPagaCon, " paga: ",paga 
   
     call logear("PagarConTender", 1)

     IF ((@TTLDUE-gPagaCon)>5)
        format aux as "Diferencia con Agregador: ",gPagaCon," Micros: ",@TTLDUE
        call logear(aux, 1)
        call consultarsino(sigue, "Diferencia entre monto Agregador y Micros. Continuamos?" )
     ENDIF
    IF (sigue=1)
        IF (gEnTicket=1)
            IF (gTender>0)
                if (gPagaCon<@TTLDUE)
                    gPagaCon=@TTLDUE
                endif
                format paga as @TTLDUE

                format aux as "Total: ",paga,"  Tender: ",gTender
                call logear(aux,1)
                LoadKybdMacro MakeKeys(paga),  Key (9, gTender) 
            ELSE
                format aux as "Error sin tender: ",paga,"  Tender: ",gTender
                call logear(aux,1)
                call mostrarmensaje("ERROR: No hay medio de pago, vaya a pantalla pagos gte")
            ENDIF
        ENDIF

        gPagaCon=""
        gFormaPago=""
        gTender=0
		gVertical=""
        gEnTicket=0
        gEnTicketPickup=0
    ELSE
        ExitCancel
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
// ********************* GENERALES ***********
// Funcion que graba el pms4
// ************************************************
SUB grabarPms
    VAR ConfigFile       : A128       // File Name
    VAR FileHandle       : N5  = 0   // File handle
    VAR i : N4 = 1
    VAR auxwrite : N4
    Var aux : A300

    IF (gChile=1)
        FORMAT ConfigFile AS g_path, gPmsNombreChile
    ELSE
        FORMAT ConfigFile AS g_path, gPmsNombre
    ENDIF
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
//Solicita si hay nuevo pms4
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

//************************* PULL ******************************
//Valida que hay lugar ante de pull
//****************************************************************
Sub validaPull(Ref ok)

	Var dbok     	: N1
	Var comando     : A350= ""
	Var resultado	: A20= ""
	Var error	: A500= ""
        Var mensaje     :A500=""

        ok=1
        call ODBCinit
	Call ODBCconvalida(dbok)
	If dbok
 		Format comando As "SELECT case when (cash_pull_accumulator+P.starting_amount)<cash_pull_threshold_3  THEN 1 ELSE 0 END AS cpull",\
                                  " FROM micros.cm_receptacle_dtl AS P INNER JOIN micros.uws_status AS U ON U.cm_drawer_",@CashDrawer,"_till_assigned = P.receptacle_seq",\
                                  " INNER JOIN micros.uws_def AS D ON D.uws_seq = U.uws_seq WHERE  obj_num=",@WSID
		
                DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comando) 
                DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
		If (error="")
                    DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 
                    if (resultado="0;") 
                        ok=0
                    endif	
		Else 	
                    
                    ErrorMessage "PMS4 ERROR: El usuario no tiene caja asignada"
                    IF (len(error)>300)
                        mensaje=mid(error,1,300)
                    ELSE
                        mensaje=error
                    ENDIF
                    call logear(error, 1)
                    //ErrorMessage mensaje
		Endif	
                call ODBCcerrarconexion()
                call ODBCbaja()
	Else
            ErrorMessage "PMS4: ValidarPull: Error al conectar BD"
            call ODBCbaja()
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
		ErrorMessage "PMS4: Error al cargar BD"
        Else
            Call ODBCConexion()
            DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
            If error <> ""
                    ErrorMessage "PMS4: Error al init conexion BD"
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
    IF (gChile=0)
        IF (gSbxUY=1)
            DLLLoad dll_handle,  "..\bin\TMT88Dll32.dll"
        ELSEIF (@WSTYPE=1) //es windows
                DLLLoad dll_handle,  "..\bin\Fcrdll.dll"
            ELSE
                DLLLoad dll_handle,  "\cf\micros\bin\FCRDriver.dll"
        ENDIF
    ELSE
        IF (@WSTYPE=1) //es windows
            DLLLoad dll_handle,  "..\bin\ESCPosPrinterW32.dll"
        ELSE
            DLLLoad dll_handle,  "\cf\micros\bin\ESCPMicrosDllCE.dll"
        ENDIF
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

// ********************* Delivery en Sbux ***********
// Funcion que lee el si es delivery 
// ************************************************
SUB esDelivery(Ref es,Var archivo:A30)
    VAR ConfigFile       : A32       // File Name
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
// ********************* Pickup ***********
// Funcion que lee el si es pickup solo en RVC=1
// ************************************************
SUB esPickup(Ref es,Var archivo:A30)
    es=0
    IF (@RVC=1)
        call esDelivery(es,archivo)
    ENDIF
ENDSUB
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
// Procedure: 	SetFilePaths() recibo X
//******************************************************************
Sub setFilePaths
        Call setWorkstationType
	// general paths
	If gbliWSType = PCWS_TYPE
		// This is a Win32 client
                Format g_path as "..\Etc\"   
		// This is a WinCE 5.0/6.0 client		
	ElseIf gbliWSType = WS5_TYPE		
                Format g_path  as "\CF\micros\etc\"    
        Else
		// This is a WS4 client	WinCE 4.2	
                Format g_path  as "\CF\micros\etc\" 
        EndIf		
EndSub
//******************************************************************
// Procedure: 	logear
//******************************************************************
Sub logear(var mensaje: A1000, var agregar : N1)
        call setFilePaths
        VAR logfile:A100
        FORMAT LogFile AS g_path, "logPms4-",@day,".txt"
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
		 " | WSID: ", @WSID, " | Pedido: ", gNumeroPedido, " === ", mensaje
	
		FWrite fhandle, aux
		FClose fhandle
	Else
		ErrorMessage "No pude grabar log en  ", logfile
	EndIf

EndSub
//***********************************************
sub consultarsino( ref answer, var prompt_s:A60 )
    var keypress : key
    var data : A20

    clearislts

    SetIslTsKeyx  1,  1, 4, 30, 6, @Key_HOME, 0, "L", 3, prompt_s
    SetIslTsKeyx  5,  1, 6, 15, 7, @Key_Enter, 10059, "L", 4, "Si"
    SetIslTsKeyx  5, 16, 6, 15, 7, @Key_Clear, 10058, "L", 2, "No"

    displayislts
    inputkey keypress, data, prompt_s
    if keypress = @Key_Enter
        answer = 1
    else
        answer = 0
    endif
    ClearIslTs
endsub 
//***********************************************
sub consultaragregador( ref answer, var prompt_s:A60, var texto1:A12,var texto2:A12, var texto3:A12 )
    var keypress : key
    var data : A20

    clearislts

    SetIslTsKeyx  1,  1, 4, 30, 6, Key(2,32), 0, "L", 3, prompt_s
    SetIslTsKeyx  5,  1, 5, 9, 6, @Key_enter,0,"L",4, texto1
    SetIslTsKeyx  5, 12, 5, 9, 6, @Key_clear,0,"L",5,  texto2
    SetIslTsKeyx  5, 22, 5, 9, 6, @KEY_HOME,0,"L",6, texto3
	//SetIslTsKeyx  5,  1, 6, 15, 7, @Key_Enter, 10059, "L", 4, "Si"
   

    displayislts
    inputkey keypress, data, prompt_s
    if keypress = @Key_Enter
        answer=texto1
    elseif keypress=@key_clear
        answer = texto2
	else
		answer=texto3
    endif
	//infomessage data
    ClearIslTs
endsub 