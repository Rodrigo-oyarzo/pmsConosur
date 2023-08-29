// pms2 v8.55
@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts
ContinueOnCancel

//ver 8.55: Se codifica metodo de Multiples Beneficios
//ver 8.54: Cambio de valores maximo a recargar, maximo saldo por tarjeta y recarga en efectivo (30000)
//ver 8.53: Se codifica el metodo de logout. 
//ver 8.52: Se modifica el largo de variables temporales de nombre y se restringe el largo a guardar en savechkinfo
//ver 8.51: Se modifica el largo de variable gMsrNombre para evitar errores de largo por overflow (30 a 40)
//ver 8.50: cambio de valores máximos de recarga de rewards en efectivo y tarjeta (5000 y 10000)
//ver 8.40: control de reintentos maximo gMsrMaxReintentos
//ver 8.35: Remplazo numeros por variables
//ver 8.34: bug en pausa recarga con el siguiente numero de cheque
//ver 8.33 bug en pausa y recarga >1000
//ver 8.32: call back para recibox en pausa y recarga, 
//      inq 33 agregar en gMacroImpReciboXTermica (803) y gMacroCargaFacturador (11004)
//      por bug en micros sacar pms8 inq 20 de 11000 y crear macro nueva gMacroPickPausa (11120) que llama a pms8 inq 20 y pms2 inq 33
//ver 8.3: envio fecha nacimiento en buscar solicitud
//ver 8.2 pausa y recarga
//ver 8.1: si es termico cambiamos la llamada macro recibox por procesoReciboX
//ver 8.00: Pausa y recarga
//  Boton Pausa y Recarga
//      Consultar monto a recargar mostranso o necesario para el cheque
//      Mostrar SLU de medios de pagos, asignar los correctos
//      final_tender: si estoy en pausa y pague, retomar el cheque anterior
//  SI todo ok, actualizar mi nuevo saldo
//  
//  Nuevo modelo fiscal
//  Visualizar ultimos beneficios redimidos inq 28
//  en alta giftcard envio el m�todo de pago
//ver 7.60: Agregamos MercadoPago
//ver 7.50: chequeo 0,01 beneficio sin saldo
//ver 7.40: aumento tope a 10000 por tarjeta
//ver 7.30: Activo QR
//ver 7.20: Arregla aplicar descuentos en drivethru
//ver 7.10: nueva dll para lectura de texto externo para QR dni. Agrega tiene en cuenta pms10 online
//ver 7.00: controla que no se pueda superar los 4000 pesos por tarjeta
//ver 6.90: Correccion recarga superior a 2000 no deja avanzar
//ver 6.80: Correciones en descuentos negativos
//ver 6.70: bug en pagar beneficio
//ver 6.60: Sacamos scanneo dni
//ver 6.50: Leer dni con qr, se agrega inq 25 para ingreso dni manual, correccion de negativos en pagar
//ver 6.40: mensaje de recarga con cuantos
//ver 6.30: sincronizacion de mensajes
//ver 6.20: Implementa proceso de recarga no acreditada inq 24
//ver 6.10: Olbigar a cerrar con rewards para beneficios. Marcar en ticket completo todos como redimidos
//ver 6.00: Bug recibos online datos ultima persona
//ver 5.90: Bug recibos online, mensajes pago con app/tarjeta
//ver 5.80: mas tiempo en alta giftcard
//ver 5.71: cambios en los tiempos de espera
//ver 5.70: recibos X para compras online
//ver 5.60: soluciona impresion recibo x devolucion efectivo
//ver 5.50: cheque 0 para consulta saldo
//ver 5.40: Reimpresion automatica de contratos, Ticket Completo en redimible(S/N),MENSAJE_LOG
//ver 5.30: Correcion largo digitos codigo voucher
//ver 5.20: Implementa reposicion de tarjeta
//ver 5.10: envia pago en 0 cuando no abona con rewards y es monto 0,01
//ver 5.00: correci�n dia de negocio. detectar tarjeta bloqueada al pasarl en NR
//ver 4.99: Contrato duplicado m�s grande que el normal
//ver 4.98: correcion mensaje asociacion con tarjeta 0
//ver 4.97: No se puede asociar una tarjeta en 0, comprobante de devolucion de recarga, arreglo bug no muestra numero de tarjeta
//ver 4.96: recibox imprime numero tarjeta, chequeo antes de comprar, erro de largo de beb favorita
//ver 4.95: error en reintentos giftcard, evitar operaciones durante giftcard
//ver 4.94: bugs alta giftcard sin numero.HEartbeat, cambios en mensaje nota de credito
//ver 4.93: cambios en ultimo recibo x (va al backoofice si lo necesita), devoluciones
//ver 4.92: saco proximo paso en leyenda
//INQ + id pms (16 gpay)
 //   LoadKybdMacro Key(24, 16384 * 11 + 16), MakeKeys( "100.25" ), @Key_enter
//ver 4.91: pasaje de datos a pms1 gpay
//ver 4.9: manejo notas de cr�dito, control de caja asignada, correcci�n exitwitherror login,saca teclado
//ver 4.82: diversos controles de seguridad en recarga etc, saldo en recibo x
//ver 4.8: reimprimir ult recibo x
//ver 4.7: reintentos recarga y offline
//ver 4.6: bug loop recibox
//ver 4.5: cambio mensaje error recibox
//ver 4.4: mensaje logout
//ver 4.32: control de pago en efectivo sino
//ver 4.3: control de cuenta en 0

//cambiar POR tarjeta=1

Var gPorBanda:N1=0
var gDatos: A1000=""
var gVersion: A14="8.5"
var gStatus: N1 = 0 //0 ok, 1 error comunicacion
var gGiftCardItem: N5=70068 //item para marcar giftcard

var gTenderMPago: N3=43
var gTenderTarjetas:N3=4 //a partir de 4 son tarjetas <4 efectivo
var gTenderTarjetaOnline: N3=31 //a partir de 31 los tender son de sistema propio de tarjetas
var gSecuenciaIslMPago:N3=22 //pms3 en la BD
var gSecuenciaIslTarjetas:N3=16 //pms1 gpay
var gSecuenciaIslTarjetasHasar:N3=25 //pms10 hasar


var gMacroReciboX: N5 =11000 //macro que carga/descarga driver de impresion e imprime recibo x
var gMacroPantallaInicio: N5=201 //macro que manda a la pantalla de espresso
var gMacroCargaFacturador: N5=11004 //macro para cargar dll fiscal
var gMacroAbrirCajon:N5=11005 //macro para abrir el cajon de dinero
var gMacroPickPausa:N5=11120 //macro que retoma el pick de pausa y recarga
var gMacroImpTermica:N5=800 //macro imprime en termica
var gMacroImpContrato:N5=802    //macro imprime contrato y pregunta para termica
var gMacroImpReciboXTermica:N5=803
var gMacroImpReciboXyDocTermica:N5=804

var gMontoRecargaMin: N4=100 //minimo a recargar
var gMontoRecargaMax: N5=30000 //maximo a recargar
var gMontoSaldoMax: N5=30000 //maximo saldo por tarjeta
var gMontoRecargaMaxEfectivo : N5=30000 //maximo a recargar en efectivo
var gMontoReciboXOnline: $8 //montos acumulados de recibos online
var gCodigoItemDevol: N6=920006
var gCodigoDescNoAcreditado: N6=578 //codigo de descuento para recargas no acreditadas
var gCodigoItemNoAcreditado: N6=900091 //codigo item 1 centavo recargas no acreditadas
var gMsrItemRef :N6=900088 //item para dejar referencia al producto marcado en un descuento
var gBolsaPartner: N4=430 //codigo de la bolsa partner
var gMaxOpciones :N2=11
var gCodigoRespuesta: A50 = ""
var gDescRespuesta : A100 = ""
var gTipoCampana : A10 = ""
var gCodigoMicros : A16 = ""
var gCodigoMicrosNivel : N1
var gCodigoAdicional : A16 = ""
var gCodigoProducto : A16=""
var gCodigoIngresado: A20 
var gDescVariable: A16=""
var gTouch : N5
var gTouchNumeros :N5=54
var gTouchSinNumeros :N2=55
var gProductos[20] : A40
var gCodigosTipo[20] : N1
var gCodigos[20] : N10
var gCodigosNivel[20] : N1
var gBeneficiosLista[50] : A70
var gBeneficiosCodigos[50] : N16
var gBeneficiosListaRedimidos[10] : A70
var gBeneficiosCodigosRedimidos[10] : N16
var gBeneficiosTiendaRedimidos[10]	: A40
var gBeneficiosTiempoRedimidos[10] : A30 
var gBeneficiosCant : N2
var gBeneficioSeleccionado :N16
var gBeneficioTicketCompleto: A1
var gMultTipo[20] : N1
var gMultCodigo[20] : N10
var gMultNivel[20] : N1
var gMultDesc[20] : A70
var gMultCant : N2
var gContadorProd : N2 = 0
var gMsrOk : N1
var gMsrCheque: N5
var gMsrChequeAnt: N5
var gMsrRecargaOk : N1
var gMsrMetodo : A10
var gMsrRecargaAnulacion : N1
var gMsrMontoAnulacion: $8
var gMedioAnulacion : A20
var gMsrIdAnulacion : N22
var gMsrTarjeta : A30
var gMsrIntentoPago :N1
var gMsrNombre : A40
var gMsrNivel : A10
var gMsrSaldo : $8
var gMsrMontoRecarga: $8
var gMsrStars : $8
var gMsrStarsFaltantes : $8
var gMsrBebFav : A50
var gMsrTender : N4=26
var gMsrTipoTarjeta : A15
var gMsrHayBeneficio : N1
var gMsrHayBeneficioDesc : N1
var gMsrEnVtaGiftCard : N1 //semaforo en venta giftcards
var gMsrBeneficiosLista :N1 //semaforo solo para colocar beneficios en ticket
var gMsrSaldoActual : N1
var gMsrDNI: A20
var gMsrReimprimir :A1
var gMsrMontoAnual : $8
var gMsrPrimerItem : N3
var gMsrEnRecarga : N1
var gMsrMaxReintentos: N1=1
var gOperacionMacro : N2
var gBeginCheckMacro : N1
var gFechaHoy : A10
var gAdvertenciaSaldo :N1
var gSolicitudNombre :A70
var gSolicitudDni: A20
var gSolicitudSexo: A20
var gSolicitudExtranjero: A1
var gSolicitudProxPaso : A100
var gSolicitudCantLineas :N3
var gSolicitudLineas[200]:A40
var gOffCant: N2
var gOffMax: N2=30
var gOffCargas[30]:A110
var gMedioCod:N3
var gUltMsrNombre: A40
var gUltMsrDni:A20
var gUltMsrCheque:A6
var gUltMsrMontoRecarga:$8
var gUltMsrTarjeta:A20
var gUltMsrStars : $8
var gTiempoIdle : N2
var gTiempoIdleHora : N2
var gProcesoRecargaNO: N1
var gQRDni : N1=1 //0 no scanneo dni
var gFiscal: N1

var gChequeAnt:N5
var gChequeSig:N5
var gPausaRecarga:N1
var gPausaRecargaHecha:N1
var gTenderPausa:N4=406 //codigo del tender para mandar a pausa
var gSluPagos:N4=102 //slu con los medios de pagos
var gServiceRecarga:N4=333 //servicecharge para recargas variables
var gServiceItem:N6=70064 //item trackea service charge variable

Var KEY_TYPE_MENU_ITEM					: N9 = 3
Var KEY_TYPE_DISCOUNT 					: N9 = 5
Var KEY_TYPE_MENU_SUB_LEVEL                             : N9 = 1
var g_path  : A128 //= "\CF\micros\etc\" 
//:A128="d:\Micros\Res\Pos\Etc\"   
var gPmsNombre :A20="pms2.isl"
var gNCArch : A15 = "SR-recarga.txt"
//var gPmsLineas1[1000] :A200
//var gPmsCantLineas1 : N4
//var gPmsLineas2[1000] :A200
//var gPmsCantLineas2 : N4
Var dll_handle							: N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	
Var PATH_TO_PRT_DRIVER						:A100	
Var PATH_TO_QR_DRIVER :A100			
Var gblPRTDrv 							:N12
Var gblQRDrv :N12
Var PCWS_TYPE									:N1 = 1	// Type number for PCWS
Var PPC55A_TYPE 					 			:N1 = 2 // Type number for Workstation mTablet
Var WS4_TYPE									:N1 = 3	// Type number for Workstation 4
Var WS5_TYPE									:N1 = 3	// Type number for Workstation 5
Var gbliWSType				 					:N1			// To store the current Workstation type
Var gbliRESMajVer								:N2			// To store the current RES major version
Var gbliRESMinVer								:N2			// To store the current RES minor version
//Customer Doc Type
Var CUSTOMER_DOC_TYPE_UNDEFINED 				:A2 = ""
Var CUSTOMER_DOC_TYPE_DNI 						:A2 = "1"
Var CUSTOMER_DOC_TYPE_CUIL 						:A2 = "2"
Var CUSTOMER_DOC_TYPE_CUIT 						:A2 = "3"
Var CUSTOMER_DOC_TYPE_CI 						:A2 = "4"
Var CUSTOMER_DOC_TYPE_PASSPORT 					:A2 = "5"
Var CUSTOMER_DOC_TYPE_LC 						:A2 = "6"
Var CUSTOMER_DOC_TYPE_LE 						:A2 = "7"
 
//Tax condition
Var TAX_CONDITION_UNDEFINED                     :A2 = ""
Var TAX_CONDITION_RESPONSABLE_INSCRIPTO         :A2 = "1"
Var TAX_CONDITION_NO_RESPONSABLE                :A2 = "2"
Var TAX_CONDITION_MONOTRIBUTO                   :A2 = "3"
Var TAX_CONDITION_EXENTO                        :A2 = "4"
Var TAX_CONDITION_NO_CATEGORIZADO               :A2 = "5"
Var TAX_CONDITION_CONSUMIDOR_FINAL              :A2 = "6"
Var TAX_CONDITION_MONOTRIBUTO_SOCIAL            :A2 = "7"
Var TAX_CONDITION_CONTRIBUYENTE_EVENTUAL        :A2 = "8"
Var TAX_CONDITION_CONTRIBUYENTE_EVENTUAL_SOCIAL :A2 = "9"

Var gDBhdl 	: N12
Var gDBPath     : A100="MDSSysUtilsProxy.dll"
//************************ REWARDS   ******************
Event init
    gTouch=@ALPHASCREEN
    gOffCant=0
    gMsrOk=0
    gQRDni=1
    gMsrSaldoActual=0
    gMsrMontoAnual=0
    gMsrEnRecarga=0
    gMsrStarsFaltantes=0
    gBeginCheckMacro=0
    gMsrRecargaOk=0
    gPausaRecarga=0
    gChequeAnt=0
    gChequeSig=0
    gFiscal=0
    gMsrRecargaAnulacion=0
    gMsrEnVtaGiftCard=0
    gCodigoIngresado=""
    gMsrCheque=0
    gMsrChequeAnt=0
    gOperacionMacro=0
    gMsrHayBeneficio=0
    gMsrIntentoPago=0
    gMsrHayBeneficioDesc=0
    gMsrBeneficiosLista=0
    gUltMsrNombre=""
    gUltMsrDni=""
    gUltMsrCheque=""
    gUltMsrMontoRecarga=0
    gUltMsrTarjeta=""
    gUltMsrStars=0
    gblPRTDrv=0
    gblQRDrv=0
    gMsrMontoAnulacion=0
    gMsrIdAnulacion=0
    gMedioAnulacion=""
    gMsrReimprimir=""
    gMsrMetodo="TARJETA"
    gMontoReciboXOnline=0
    gProcesoRecargaNO=0
    gPausaRecargaHecha=0
    call validarDllReciboX
    IF (gQRDni=1)
        call CargarQRDll
    ENDIF
    call sqlDiaDeNegocio(gFechaHoy)
    @IDLE_SECONDS=60
    gTiempoIdle=@Minute
    gTiempoIdleHora=@Hour
    call heartBeat
endevent

Event exit
	//Call ODBCbaja()
EndEvent

Event Begin_Check
    call getModeloFiscal
    //LoadDBKybdMacro gMacroCargaFacturador
    IF (gProcesoRecargaNO=1) 
        gProcesoRecargaNO=2 //estoy en fase de otorgar descuento
    ELSE
        gProcesoRecargaNO=0
    ENDIF
    gMsrPrimerItem=0
    IF (gPausaRecarga=2) //no podr�a estar en 2 aca
        gPausaRecarga=0
    ENDIF
    IF (gPausaRecarga=0)
        call initMsr
    ELSEIF (gPausaRecarga=1)
        VAR error:N1=0
        call loginPausaRecarga(error)
        IF (error<>0)
            call MostrarMensaje("PAUSA Y RECARGA: NO PUEDO CREAR TRANSACCION: POR FAVOR CANCELAR")
        ENDIF
    ENDIF
    call crearDiaNegocio
    IF (gOffCant>0)
        call enviarRecargasOffline
    ENDIF
    IF (gBeginCheckMacro=1)
        IF (gOperacionMacro=1)
            IF (gMsrEnVtaGiftCard=0)
                call loginMSR("DESLIZAR_TARJETA",0)
                IF (gMsrOk=1)
                     LoadDBKybdMacro gMacroPantallaInicio //cambio de pantalla
                     IF (gMsrReimprimir="S")
                        call reimprimirContrato
                     ENDIF
                     IF (gMontoReciboXOnline>0)
                        //call imprimirRecibosOnline
                        infomessage "Recibo X Online", "SE IMPRIMIRAN RECIBOS X DE RECARGAS ONLINE"
                        IF (gFiscal=0)
                            LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                        ELSE
                            call procesoReciboX
                        ENDIF
                     ENDIF
                ELSE
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
                ENDIF
            ELSE
                ExitWithError "NO PUEDE CAMBIAR DE TARJETA DURANTE UNA VENTA DE TARJETA NO REGISTRADA"
            ENDIF
            gMsrBeneficiosLista=0
        ELSEIF (gOperacionMacro=3)
            IF (gMsrEnVtaGiftCard=0)
                call consultaSaldoMSR(1,0)
            ELSE
                ExitWithError "NO PUEDE CAMBIAR DE TARJETA DURANTE UNA VENTA DE TARJETA NO REGISTRADA"
            ENDIF
        ELSEIF (gOperacionMacro=4)
            IF (gMsrEnVtaGiftCard=0)
                call prechequeoCarga
             ELSE
                 ExitWithError "NO PUEDE CAMBIAR DE TARJETA DURANTE UNA VENTA DE TARJETA NO REGISTRADA"
             ENDIF
        ELSEIF (gOperacionMacro=6)
            IF (gMsrEnVtaGiftCard=0)
                //Call cargarDllImpresora
                call buscarSolicitud(0,gQRDni)
                //Call descargarDllImpresora
            ELSE
                call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
            ENDIF
        ELSEIF (gOperacionMacro=7)
             IF (gMsrEnVtaGiftCard=0)
                IF (@SVC>0)
                    call mostrarmensaje ("DEBE FINALIZAR LA RECARGA PRIMERO")
                ELSEIF (gMsrOk=1)
                    call mostrarmensaje ("DEBE REALIZAR LOGOUT PRIMERO")
                ELSE
                    call asociarTarjetaDni(0,gQRDni)
                ENDIF
            ELSE
                call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
            ENDIF
        ELSEIF (gOperacionMacro=8)
            //Call cargarDllImpresora
            call buscarSolicitud(1,gQRDni)
            //Call descargarDllImpresora
        ELSEIF (gOperacionMacro=14)
            IF (gMsrEnVtaGiftCard=0)
                //gMsrEnVtaGiftCard=1
                call prechequeoVtaGift
                IF (gMsrEnVtaGiftCard=0)
                    //ExitWithError "NO SE LEYO TARJETA"
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
                ENDIF
            ELSE
                ExitWithError "NO ES POSIBLE VENDER DOS TARJETAS NO REGISTRADAS EN EL MISMO TICKET"
            ENDIF
        ELSEIF (gOperacionMacro=23)
             call asociarTarjetaDni(1,gQrDNI) //es reposicion
        ELSEIF (gOperacionMacro=25)
            IF (gMsrEnVtaGiftCard=0)
                call buscarSolicitud(0,0)
            ELSE
                call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
            ENDIF
        ELSEIF (gOperacionMacro=26) //reimprimir con autorizacion
            call buscarSolicitud(1,0)
        ELSEIF (gOperacionMacro=27) //asociar tarjeta con dni autorizacion
             IF (gMsrEnVtaGiftCard=0)
                IF (@SVC>0)
                    call mostrarmensaje ("DEBE FINALIZAR LA RECARGA PRIMERO")
                ELSEIF (gMsrOk=1)
                    call mostrarmensaje ("DEBE REALIZAR LOGOUT PRIMERO")
                ELSE
                    call asociarTarjetaDni(0,gQRDni)
                ENDIF
            ELSE
                call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
            ENDIF
            
        ENDIF

    ENDIF
    gOperacionMacro=0
    call comienzoCheque
    gMsrHayBeneficio=0
    gMsrHayBeneficioDesc=0
Endevent

Event Idle_No_Trans
    if (gTiempoIdle<>@Minute)
        IF (gOffCant>0)
            call enviarRecargasOffline
        ENDIF
        gTiempoIdle=@Minute
        @IDLE_SECONDS=60
    endif
    if (gTiempoIdleHora<>@Hour)
        call HeartBeat
        call sqlDiaDeNegocio(gFechaHoy)
        gTiempoIdleHora=@Hour
    endif
endevent

Event trans_cncl
    IF (gPausaRecarga=1 and gMsrOk=1)
        call cancelarOperacion
        LoadKyBdMacro Key (1,327684),MakeKeys (gChequeAnt),@KEY_ENTER //tomo el ticket anterior
        //LoadKyBdMacro MakeKeys(@TREMP), @KEY_ENTER //con el barista actual1234

        gAdvertenciaSaldo=0
        gPausaRecarga=0
    ELSE
        call crearDiaNegocio   
        IF (gMsrOk=1)
            call cancelarOperacion
        ENDIF
        call initMsr
        IF (gOffCant>0)
            call enviarRecargasOffline
        ENDIF
    ENDIF
Endevent

Event inq: 1
    call getModeloFiscal
    IF (gMsrOk=0)
        gTouch=@ALPHASCREEN
        call crearDiaNegocio   
        IF (@cknum=0)
            gOperacionMacro=1
            call comienzoCheque
           // LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
        ELSE
            IF (gMsrEnVtaGiftCard=0)
                call loginMSR("DESLIZAR_TARJETA",0)
                IF (gMsrOk=1)
                    LoadDBKybdMacro gMacroPantallaInicio //cambio de pantalla
                    IF (gMsrReimprimir="S")
                        call reimprimirContrato
                     ENDIF
                    IF (gMontoReciboXOnline>0)
                        //call imprimirRecibosOnline
                        infomessage "Recibo X Online", "SE IMPRIMIRAN RECIBOS X DE RECARGAS ONLINE"
                        IF (gFiscal=0)
                            LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                        ELSE
                            call procesoReciboX
                        ENDIF
                    ENDIF
                ENDIF
            ELSE
                ExitWithError "NO PUEDE CAMBIAR DE TARJETA DURANTE UNA VENTA DE TARJETA NO REGISTRADA"
            ENDIF
            gMsrBeneficiosLista=0
        ENDIF
    ELSE
        call mostrarMensaje("DEBE REALIZAR UN LOGOUT DE REWARDS PREVIAMENTE")
    ENDIF
endevent

Event inq: 2 //Beneficios
    call crearDiaNegocio
    call consultarBeneficios
Endevent

Event inq: 3 //consulta saldo
    call crearDiaNegocio
    //IF (@cknum=0)
   //     gOperacionMacro=3
   //     call comienzoCheque
   //     LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
   // ELSE
        IF (gMsrEnVtaGiftCard=0)
            call consultaSaldoMSR(1,0)
        ELSE
            call MostrarMensaje("NO PUEDE CAMBIAR DE TARJETA DURANTE UNA VENTA DE TARJETA NO REGISTRADA")
        ENDIF
   // ENDIF
Endevent

Event inq: 4 //carga saldo valido login y paso pantalla
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=4
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        IF (gMsrEnVtaGiftCard=0)
           call prechequeoCarga
        ELSE
            ExitWithError "NO PUEDE CAMBIAR DE TARJETA DURANTE UNA VENTA DE TARJETA NO REGISTRADA"
        ENDIF
    ENDIF
Endevent

Event inq: 5 //pagar cuenta
    call crearDiaNegocio
    call pagarMSR
Endevent

Event inq : 6 //Buscar Solicitud
   
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=6
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        IF (gMsrEnVtaGiftCard=0)
            //Call cargarDllImpresora
            call buscarSolicitud(0,gQRDni)
            //Call descargarDllImpresora
        ELSE
            call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
        ENDIF
    ENDIF
Endevent

Event inq : 7 //Asociar tarjeta por documento
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=7
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE    
        IF (gMsrEnVtaGiftCard=0)
            IF (@SVC>0)
                call mostrarmensaje ("DEBE FINALIZAR LA RECARGA PRIMERO")
            ELSEIF (gMsrOk=1)
                call mostrarmensaje ("DEBE REALIZAR LOGOUT PRIMERO")
            ELSE
                call asociarTarjetaDni(0,gQRDni)
            ENDIF
        ELSE
            call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
        ENDIF
    ENDIF
Endevent

Event inq : 8 //reimprimir contrato
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=8
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        //Call cargarDllImpresora
        call buscarSolicitud(1,gQRDni)
        //Call descargarDllImpresora
    ENDIF
Endevent

Event inq : 9 //Asociar tarjeta por medio de otra tarjeta
    call crearDiaNegocio  
    IF (@cknum=0)
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        IF (@SVC=0)
            call asociarTarjeta
        ELSE
            call mostrarmensaje ("DEBE FINALIZAR LA RECARGA O VENTA NO REGISTRADA PRIMERO")
        ENDIF
    ENDIF
Endevent

Event inq : 10 //contrato firmado
    call crearDiaNegocio
Endevent

Event inq : 11 //validar no hay mezcla de recarga e items
    call crearDiaNegocio
    call validarItemsTicket
Endevent

Event inq : 12 //deslogear rewards
    call crearDiaNegocio
    call desLogearMSR
Endevent

Event inq : 13 //imprimo recibo X
    Call procesoReciboX
    LoadDBKybdMacro gMacroPickPausa
Endevent

Event inq: 14 //venta de giftcard valido login y paso pantalla
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=14
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        IF (gMsrEnVtaGiftCard=0)
            //gMsrEnVtaGiftCard=1
            call prechequeoVtaGift
            IF (gMsrEnVtaGiftCard=0)
                LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
            ENDIF
        ELSE
            ExitWithError "NO ES POSIBLE VENDER DOS TARJETAS NO REGISTRADAS EN EL MISMO TICKET"
        ENDIF
    ENDIF
Endevent

Event inq: 15 //creo ticket para macro de identificar
     call crearDiaNegocio
     call comienzoCheque
Endevent

Event inq: 16 //macro pagos llama para validar recargas minimas
     IF (@TTLDUE=0 and @SVC=0)
        InfoMessage "CUENTA EN 0, NO ES POSIBLE EFECTIVIZAR"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
     ELSEIF (@cashdrawer=0)
        infomessage "ERROR: NO TIENE ASIGNADA LA CAJA"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
     ELSE
        call validarRecargaMinima
     ENDIF
Endevent

Event inq: 17 //macro que asegura si se quiere pagar en efectivo o con rewards
    VAR answer:N1=0

    IF ((gMsrOk=0) or ((gMsrOK=1) and (@SVC>0)))
        //LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
        LoadKybdMacro Key (9, 2) //aplico tender efectivo
    ELSE
         call consultarsino(answer, "DESEA PAGAR EN EFECTIVO Y NO REWARDS?" )
         IF (answer=1)
            LoadKybdMacro Key (9, 2) //aplico tender efectivo
         ENDIF
    ENDIF
Endevent

Event inq: 18 //valida durante el marcado que tenga saldo rewards
    VAR aux:A70=""

    IF (gMsrOk=1 and gAdvertenciaSaldo=0)
        IF (@SVC=0 and @TTLDUE>gMsrSaldo and @TTLDUE>=1)
            gAdvertenciaSaldo=1
            format aux as "Saldo Rewards (",gMsrSaldo,") insuficiente para este pedido"
            call mostrarMensaje(aux)
        ENDIF
    ENDIF
Endevent

Event inq : 19 //imprimo ultimo recibo X
    //IF (gUltMsrMontoRecarga>0)
        Call setWorkstationType
        Call setFilePaths
        call imprimirUltimoReciboX
    //ELSE
    //    infomessage "Ultimo Recibo X", "NO EXISTEN DATOS DE RECIBO X"
    //ENDIF
Endevent

Event inq : 20 //confirmo reseteo
    InfoMessage "Restablecimiento realizado"
Endevent

Event inq : 21 //NC para recargas
    IF (@SVC=0 and @TTLDUE=0)
        Call cancelarRecarga(0)
    ELSE
        InfoMessage "PRIMERO DEBE ELIMINAR LOS ITEMS"
    ENDIF
EndEvent

Event inq : 22 //callback tarjeta online por anulacion recarga
    Format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","NOTA_CREDITO_RECARGA","|",gMsrTarjeta,"|",gMsrIdAnulacion
    call EnviaTransaccion
    call RecibeTransaccion
    gMsrRecargaAnulacion=2
    IF @RxMsg <> "_timeout" 
        call procesarRespuesta
        IF (gMsrRecargaOk=1)
            gUltMsrNombre=gMsrNombre
            gUltMsrDni=gMsrDNI
            gUltMsrTarjeta=gMsrTarjeta
            gUltMsrStars=gMsrStars
            call getModeloFiscal
            IF (gFiscal=0)
                LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                Call cargarDllImpresora
                call imprimirComprobanteDevolucion
                Call descargarDllImpresora
            ELSE
                //imprimo recibo x y comprobante
                call ImprimirReciboX
                call imprimirComprobanteDevolucionTermica
                LoadDBKybdMacro gMacroImpReciboXyDocTermica
            ENDIF
            
        ELSE
            call mostrarmensaje ("ERROR EN CANCELACION DE RECARGA, VALIDE EL SALDO")
        ENDIF
    ENDIF
    IF (gMsrRecargaOk=1)
        InfoMessage "DEVOLUCION REALIZADA"
    ENDIF
    gMsrRecargaAnulacion=0
EndEvent

Event inq: 23 //reposicion de tarjeta
     call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=23
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE    
        call asociarTarjetaDni(1,gQRDni)
    ENDIF
Endevent

Event inq: 24 //entrego descuento recarga no acreditada
    VAR itemspadre:N3=0
    VAR itemnivel:N1=0
    VAR descnombre:A8=""

    IF (gProcesoRecargaNO=2)       
        call validaItemsPadre(itemspadre,itemnivel) 
        IF (itemspadre=1)
          format descnombre as @DTL_OBJECT[gMsrPrimerItem]
          LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gMsrItemRef),MakeKeys(descnombre), @KEY_ENTER
          LoadKybdMacro Key(KEY_TYPE_DISCOUNT,  gCodigoDescNoAcreditado),  @KEY_ENTER
          LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoItemNoAcreditado), @KEY_ENTER
          gProcesoRecargaNO=0
          LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, 2)  //cierro en efectivo
        ELSE
         call mostrarmensaje("DEBE MARCAR UNA SOLA BEBIDA ALTA")
        ENDIF      
    ELSE
        call mostrarmensaje("CORTESIA NO HABILITADA")
    ENDIF
Endevent

Event inq : 25 //Buscar Solicitud con ingreso manual dni
   
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=25
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        IF (gMsrEnVtaGiftCard=0)
            //Call cargarDllImpresora
            call buscarSolicitud(0,0)
            //Call descargarDllImpresora
        ELSE
            call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
        ENDIF
    ENDIF
Endevent

Event inq : 26 //reimprimir contrato con ingreso dni
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=26
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE
        //Call cargarDllImpresora
        call buscarSolicitud(1,0)
        //Call descargarDllImpresora
    ENDIF
Endevent

Event inq : 27 //Asociar tarjeta por documento manual
    call crearDiaNegocio
    IF (@cknum=0)
        gOperacionMacro=27
        call comienzoCheque
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    ELSE    
        IF (gMsrEnVtaGiftCard=0)
            IF (@SVC>0)
                call mostrarmensaje ("DEBE FINALIZAR LA RECARGA PRIMERO")
            ELSEIF (gMsrOk=1)
                call mostrarmensaje ("DEBE REALIZAR LOGOUT PRIMERO")
            ELSE
                call asociarTarjetaDni(0,0)
            ENDIF
        ELSE
            call MostrarMensaje("DEBE FINALIZAR LA VENTA DE TARJETA NO REGISTRADA O CANCELAR EL TICKET")
        ENDIF
    ENDIF
Endevent

Event inq: 28 //Beneficios
    call crearDiaNegocio
    call consultarBeneficiosRedimidos
Endevent

Event inq: 30 //poner en hora la fiscal, se llama desde una macro
    Call setWorkstationType
    Call setFilePaths
    call SyncDateTime
Endevent

Event inq: 31 //pausa y recarga
    VAR diferencia:$8
    VAR monto:N8
    VAR aux:A30
    VAR error:N1=0

    gPausaRecarga=0
    IF (@cashdrawer=0)
        infomessage "ERROR: NO TIENE ASIGNADA LA CAJA"
    ELSE
        IF (gMsrOk=1) //estoy en rewards
            IF (gPausaRecargaHecha=0)
                IF (@SVC=0 and @TTLDUE>0)
                    diferencia=@TTLDUE-gMsrSaldo
                    IF (diferencia>0)
                        //diferencia=diferencia*100
                    ELSE
                        diferencia=0
                    ENDIF
                    gChequeAnt=@cknum
                    //gChequeSig=@cknum+1
                    //IF (gChequeSig=10000)
                     //   gChequeSig=1
                   // ENDIF

                    LoadKyBdMacro Key(9, gTenderPausa)    //Mando a pausa
                    LoadKyBdMacro Key(1, 327681)          //Open check

                    LoadKyBdMacro MakeKeys(@TREMP), @KEY_ENTER //con el barista actual
                   // LoadKyBdMacro MakeKeys("0"), @KEY_ENTER

                    Touchscreen gTouchNumeros
                    format aux as "Monto a Recargar ",diferencia
                    Input monto, aux
                    Touchscreen gTouch
                    IF (monto>0)
                        IF (monto>gMontoRecargaMax)
                            infomessage "El monto de recarga supera el maximo permitido"
                            exitcancel
                        ELSEIF ((monto+gMsrSaldo)>gMontoSaldoMax)
                            infomessage "El monto de recarga supera el saldo maximo permitido"
                            exitcancel
                        ELSE
                            gOperacionMacro=31
                            gPausaRecarga=1
                            gPausaRecargaHecha=1
                            //me logeo de nuevo con rewards
                            call registrarOperacion("INGRESAR PAUSA Y RECARGA",gMsrTarjeta)
                            //call loginPausaRecarga(error)
                           // IF (error=0)
                                monto=monto*100
                                LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gServiceItem)    //inyecto seguimiento
                                LoadKybdMacro MakeKeys(monto),  Key (7, gServiceRecarga) //service charge
                                LoadKyBdMacro Key (19,gSluPagos) //SLU medios de pago 
                            //ELSE
                              //  call MostrarMensaje("PAUSA Y RECARGA: NO PUEDO CREAR TRANSACCION")
                            //ENDIF
                        ENDIF
                    ELSE
                        exitcancel
                    ENDIF
                ELSE
                    call MostrarMensaje("NO PERMITIDO")
                ENDIF
            ELSE
                call MostrarMensaje("YA REALIZO UNA PAUSA Y RECARGA")
            ENDIF
        ELSE
            call MostrarMensaje("DEBE ENCONTRARSE EN UNA OPERACION REWARDS")
        ENDIF
    ENDIF
Endevent

Event inq :32 //callback imp termica imrimio contrato
    VAR firmo:N1=0
    call consultarMensaje("FIRMO EL CONTRATO?",firmo)
    IF (firmo=1)
        call contratoFirmado
    ELSE
        call mostrarMensaje("EL CONTRATO NO SE HA FIRMADO. NO SE COMPLETO EL REGISTRO")
    ENDIF
Endevent

Event inq :33 //callback recibo x en pausa y recarga
    VAR aux:A20
    format aux as "gP=",gPausaRecarga," Ck=",gChequeAnt
    call registrarOperacion("CALLBACK inq33",aux)
    IF (gPausaRecarga=1)
        LoadKyBdMacro Key (1,327684),MakeKeys (gChequeAnt),@KEY_ENTER //tomo el ticket anterior
    ENDIF
EndEvent
 
Event tndr
    IF (gPausaRecarga=1)
        IF (@TTLDUE>0)
                LoadKyBdMacro Key (19,gSluPagos) //SLU medios de pago
        ENDIF 
    ENDIF
	
EndEvent

Event Pickup_Check
    IF (gMsrOk=1 and gPausaRecarga=1)
		LoadDBKybdMacro gMacroImpReciboXTermica
        gPausaRecarga=0
        call cargarInfoLines
	else
		call initMsr
    ENDIF
EndEvent

Event final_tender  //validar si estoy pagando una recarga
    call crearDiaNegocio
    call pagoFinal  
    IF (gPausaRecarga=1)
       // LoadKyBdMacro Key (1,327684),MakeKeys (gChequeAnt),@KEY_ENTER //tomo el ticket anterior
        gAdvertenciaSaldo=0
        //gPausaRecarga=0
        //call consultaSaldoMsr(0,0) //consulto el nuevo saldo MSR ya viene en recargaok10
    ELSE
        gFechaHoy=""
        gPausaRecargaHecha=0
    ENDIF
    
    gMsrEnVtaGiftCard=0
Endevent

Event Signin

	//LoadDBKybdMacro gMacroReciboX 
        call sqlDiaDeNegocio(gFechaHoy)
EndEvent


//*****************************************************
// inicializo variables
//*****************************************************
SUB initMsr
    gblPRTDrv=0
    gMsrOk=0
    gMsrEnRecarga=0
    //gBeginCheckMacro=0
    gMsrEnVtaGiftCard=0
    gFechaHoy=""
    gMsrTarjeta =""
    gMsrNombre=""
    gMsrNivel =""
    gMsrSaldo =0
    gMsrStars =0
    gMsrStarsFaltantes=0
    gMsrRecargaAnulacion=0
    gMsrRecargaOk=0
    gMsrTipoTarjeta=""
    gMsrSaldoActual=0
    gMsrBebFav=""
    gPausaRecarga=0
    gPausaRecargaHecha=0
    gChequeAnt=0
    gMsrEnVtaGiftCard=0
    gMsrHayBeneficio=0
    gMsrHayBeneficioDesc=0
    gAdvertenciaSaldo=0
    gMsrPrimerItem=0
    gMsrMontoAnulacion=0
    gMsrIdAnulacion=0
    gMedioAnulacion=""
    gMsrReImprimir=""
    gMontoReciboXOnline=0
    gMsrMetodo="TARJETA"
    gMsrIntentoPago=0
    gBeneficioTicketCompleto="N"
    call crearDiaNegocio
ENDSUB
//*****************************************************
// crear dia de negocio
//*****************************************************
SUB crearDiaNegocio
   IF (gFechaHoy="") 
        call sqlDiaDeNegocio(gFechaHoy)
    ENDIF 
ENDSUB
//*****************************************************
//heartbeat
//*****************************************************
sub heartBeat 
    call crearDiaNegocio
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",0,"|",gFechaHoy,"|HEARTBEAT"

    call EnviaTransaccion
    call RecibeTransaccion
    gCodigoRespuesta=""
endsub
//*****************************************************
// Comienzo un cheque
//*****************************************************
SUB comienzoCheque    

    call crearDiaNegocio

    gTouch=@ALPHASCREEN
    IF (gBeginCheckMacro=1)
        gBeginCheckMacro=0
    ENDIF
    IF (@cknum=0)  
        gBeginCheckMacro=1
        LoadKybdMacro Key(1,327681) //abro un ticket
    ENDIF
   
ENDSUB
//*****************************************************
//Cancelar Operacion. 
//*****************************************************
sub cancelarOperacion 
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|CANCELAR|",gMsrTarjeta

    call EnviaTransaccion
    call RecibeTransaccion
    if @RxMsg <> "_timeout" 
        call procesarRespuesta
    endif
endsub
//*****************************************************
//Cancelar Operacion. 
//*****************************************************
sub logoutMSR 
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|LOGOUT|",gMsrTarjeta

    call EnviaTransaccion
    call RecibeTransaccion
    if @RxMsg <> "_timeout" 
        call procesarRespuesta
    endif
endsub
//*****************************************************
//Login MSR. Comando: DESLIZAR_TARJETA SALDO
//*****************************************************
sub loginPausaRecarga(VAR error:N1)
    error=0
    //gChequeSig
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|DESLIZAR_TARJETA|",gMsrTarjeta
       
    call EnviaTransaccion
    call RecibeTransaccion
    if @RxMsg <> "_timeout" 
       call procesarRespuesta
       IF (gPausaRecarga=2)
            gPausaRecarga=1
       ELSE
            error=1 //algo sucedio
       ENDIF
    ELSE
        error=1
        Call mostrarmensaje ("PAUSA Y RECARGA: NO PUEDO CREAR TRANSACCION (SIN CONEXION)")
    endif
endsub
//*****************************************************
//Login MSR. Comando: DESLIZAR_TARJETA SALDO
//*****************************************************
sub loginMSR(VAR comando:A20,VAR engiftcard:N1)
    var porTarjeta : N1=1
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    porTarjeta=gPorBanda
    call comienzoCheque
	if (gMsrTarjeta="")
		call consultarCodigoTarjeta("Lee Rewards",gMsrTarjeta,porTarjeta) // carga rewards
	EndIf
    //call consultarCodigoTarjeta("Deslice Tarjeta Rewards",gCodigoIngresado,porTarjeta)

    //if (gCodigoIngresado="" or len(gCodigoIngresado)<>16)
	if (gMsrTarjeta="" or len(gMsrTarjeta)<>16) 
     infomessage "DEBE INGRESAR UNA TARJETA REWARDS"
     LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual
    else
        IF (engiftcard=1)
            gMsrEnVtaGiftCard=1
        ENDIF
        //format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|",comando,"|",gCodigoIngresado
		format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|",comando,"|",gMsrTarjeta
        var aux:A20
        //format aux as "TRANS=",@trans_number
        //call mostrarmensaje(aux)
        call EnviaTransaccion
        call RecibeTransaccion
        if @RxMsg <> "_timeout" 
            call procesarRespuesta
        endif
    endif
endsub
//*****************************************************
//delogear MSR.
//*****************************************************
sub desLogearMSR

    IF (gMsrHayBeneficio>=1)
        exitwitherror "SE APLICARON BENEFICIOS, DEBE CANCELAR EL TICKET PARA DESLOGEAR REWARDS" 
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ELSEIF (@SVC=0 and @TTLDUE=0) 
        gMsrSaldoActual=0
        gBeginCheckMacro=0
        gMsrEnVtaGiftCard=0

        clearchkinfo
        IF (gMsrOk=1)
            call logoutMSR
            gMsrOk=0
            gMsrPrimerItem=0
        ENDIF
    ELSE
        exitwitherror "TICKET CON ITEMS, DEBE ELIMINARLOS ANTES DE DESLOGEAR REWARDS" 
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ENDIF

    
endsub
//*****************************************************
//prechequeoCarga
//*****************************************************
sub prechequeoCarga
    VAR aux:A100

    IF (@CashDrawer>0)

        IF (@SVC>=0 and (@TTLDUE=0 or @TTLDUE=@SVC)) 
            call loginMSR("DESLIZAR_TARJETA",0) 
        ELSE
            format aux as "TICKET CON ITEMS DE VENTA, DEBE ELIMINARLOS " 
            ExitWithError aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ENDIF
        IF (gMsrTipoTarjeta="Gift Card" and gCodigoIngresado<>"")
            ExitWithError "ERROR: NO SE PUEDE RECARGAR UNA TARJETA NO REGISTRADA"
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (gMsrTipoTarjeta="NUEVA" and gMsrEnVtaGiftCard=1 and gCodigoIngresado<>"")
            //entoy en etapa de vender una giftcard 
            //inyecto el item de giftcard
            LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gGiftCardItem)    
        ELSEIF (gMsrOk=0)
            //no le� una tarjeta valida
            //ExitWithError "NO SE LEYO TARJETA"
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ENDIF
    ELSE
        infomessage "ERROR: NO TIENE ASIGNADA LA CAJA"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ENDIF
    
endsub
//*****************************************************
//prechequeoVtaGift
//*****************************************************
sub prechequeoVtaGift
    VAR aux:A100
    
    IF (@CashDrawer>0) 
        IF (@SVC=0 and (@TTLDUE=0 or @TTLDUE=@SVC)) 
            call loginMSR("DESLIZAR_TARJETA",1) 
        ELSE
            gMsrEnVtaGiftCard=0
            format aux as "TICKET CON ITEMS DE VENTA, DEBE ELIMINARLOS "
            infomessage aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ENDIF
        IF (gMsrTipoTarjeta="Gift Card")
            gMsrEnVtaGiftCard=0
            infomessage "ERROR: TARJETA NO REGISTRADA YA UTILIZADA"
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (gMsrTipoTarjeta="Starbucks Card")
            gMsrEnVtaGiftCard=0
            infomessage "ERROR: ES UNA TARJETA REGISTRADA"
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (gMsrTipoTarjeta="NUEVA" )
            //entoy en etapa de vender una giftcard 
            //inyecto el item de giftcard
            savechkinfo "EN VENTA TARJETA"
            savechkinfo "NO REGISTRADA"
            gMsrEnVtaGiftCard=1
            LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gGiftCardItem)    
        ELSE
            //no le� una tarjeta valida
            gMsrEnVtaGiftCard=0
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ENDIF 
    ELSE
        gMsrEnVtaGiftCard=0
        infomessage "ERROR: NO TIENE ASIGNADA LA CAJA"
        LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
    ENDIF
endsub
//*****************************************************
//valida si hay bolsa partner
//*****************************************************
sub hayCafePartner(REF bolsapartner)
    VAR i:N3
    bolsapartner=0

    i=1
    WHILE i < @NUMDTLT
        IF (@DTL_TYPE[i]="D" )AND @DTL_IS_VOID[i] = 0
           IF(@DTL_OBJECT[i]=gBolsaPartner)
               bolsapartner=1 
           ENDIF
        ENDIF
        i=i+1
    ENDWHILE
endsub
//*****************************************************
//validadRecargaMinima y que no hay bolsa de cafe de partner
//*****************************************************
sub validarRecargaMinima
    VAR aux:A100
    VAR i:N3
    VAR bolsapartner:N1=0

    IF (gMsrOk=1 and gMsrEnVtaGiftCard=0 and @SVC>0 and @SVC>gMsrMontoAnual)
        format aux as "LIMITE ANUAL DE RECARGAS SUPERADO, DISPONIBLE " ,gMsrMontoAnual
        exitwitherror aux
    ELSE
        IF ((@SVC+gMsrSaldo)>gMontoSaldoMax)
            format aux as "LA TARJETA SUPERARIA EL MONTO MAXIMO PERMITIDO: " ,gMontoSaldoMax," ACTUAL: ",gMsrSaldo
            exitwitherror aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (@SVC>0 and @SVC<gMontoRecargaMin)
            format aux as "LA RECARGA DEBE SER POR LO MENOS DE " ,gMontoRecargaMin," PESOS"
            exitwitherror aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error  
        ELSEIF (@SVC>gMontoRecargaMax)
            format aux as "LA RECARGA DEBE SER INFERIOR A " ,gMontoRecargaMax," PESOS"
            exitwitherror aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (@SVC>=gMontoRecargaMaxEfectivo)
            format aux as "LA RECARGA IGUAL O SUPERIOR A " ,gMontoRecargaMaxEfectivo," PESOS SE DEBE ABONAR CON TARJETA"
            infomessage aux
            //LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (@SVC>0 and @TTLDUE>@SVC)
			infomessage "SVC", @SVC
			infomessage "TTLDUE", @TTLDUE
            exitwitherror "ERROR: EL TICKET CONTIENE RECARGAS Y PRODUCTOS"
        ELSEIF (gMsrEnVtaGiftCard=1 and gMsrTarjeta="")
            exitwitherror "ERROR: NO SE LEYO EL NUMERO DE TARJETA NR"
        ELSEIF (gMsrEnVtaGiftCard=1 and @SVC=0)
            exitwitherror "ERROR: EL MONTO DE LA TARJETA NR NO PUEDE SER 0, SI LO ELIMINO DEBE CANCELAR TK"
        ELSEIF (@SVC>0) //estoy por cargar saldo
            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONSULTAR_SALDO","|",gMsrTarjeta
            call EnviaTransaccion
            call RecibeTransaccion
    
            IF @RxMsg <> "_timeout" 
                UpperCase gDescRespuesta
                IF (mid(gDescRespuesta,1,2)="01") //error con valuelink
                    exitwitherror "NO HAY COMUNICACION CON VALUELINK - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS"
                ENDIF
            ELSE
                exitwitherror "NO HAY COMUNICACION CON REWARDS - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS (SIN INTERNET)"
            ENDIF
        ENDIF
    ENDIF
    IF (gMsrOk=1)
        call hayCafePartner(bolsapartner)
    
        IF (bolsapartner=1)
            format aux as "NO ES POSIBLE APLICAR EL BENEFICIO DE CAFE PARTNER CON REWARDS" 
            exitwitherror aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSE //fuerzo el pago con rewards si hay beneficios
            IF (gMsrHayBeneficio=1)
                call pagarMsr
            ENDIF
        ENDIF
    ENDIF
endsub
//*****************************************************
//pagar MSR
//*****************************************************
sub pagarMSR
    var porTarjeta : N1=1
    var i: N4 = 0
    var cantItems : N4 = 0
    var items: A2000 = ""
    var aux: A40=""
    var tipo: N1=1
    var nivel :N2
    var eltotal :$12
    var montopagado :$12
    var pagomixto:N1=0
    var encuenta:A2="SI"
    var bolsapartner:N1=0
    porTarjeta=gPorBanda
    gMsrSaldoActual=0
    IF (gMsrOk=1)
        call hayCafePartner(bolsapartner)
        IF (bolsapartner=1)
            format aux as "NO ES POSIBLE APLICAR EL BENEFICIO DE CAFE PARTNER CON REWARDS" 
            exitwitherror aux
            LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ELSEIF (@SVC=0) 
            i=1
            WHILE (pagomixto=0 and i<=@NUMDTLT)
                IF (@DTL_TYPE[i]="T" AND @DTL_IS_VOID[i] = 0)
                    pagomixto=1
                ENDIF
                i=i+1
            ENDWHILE    
            IF (pagomixto=0)
                call loginMSR("CONSULTAR_SALDO",0)
                IF (gMsrTarjeta="")
                    exitwitherror "NO SE INGRESO TARJETA"      
                ELSEIF (gMsrSaldoActual=1)
                    IF (gMsrSaldo<@TTLDUE and @TTLDUE>=1 and gMsrIntentoPago=0)
                        format aux as "SALDO INSUFICIENTE REWARDS  (",gMsrSaldo,")"
                        exitwitherror aux
                    ELSE
                        gMsrIntentoPago=1
                        
                        eltotal=@TTLDUE
                        FOR i = 1 to @NUMDTLT
                            IF ((@DTL_TYPE[i]="M" or @DTL_TYPE[i]="D" ))
                               IF (@DTL_IS_VOID[i] = 0 and @DTL_QTY[i]>0)
                                    tipo=1
                                    nivel=@DTL_SLVL[i]
                                    IF (@DTL_TYPE[i]="D")
                                         tipo=2
                                         nivel=0
                                    ENDIF
                                    IF (i=gMsrPrimerItem)
                                         encuenta="NO"
                                    ELSE
                                         encuenta="SI"
                                    ENDIF
                                    format items as items,"|",@DTL_QTY[i],"|",tipo,"|",@DTL_OBJECT[i],"|",nivel,"|",encuenta
                                    cantItems=cantItems+1
                                    IF ((@DTL_TYPE[i]="M") and (@DTL_TTL[i]<0.05) and (@DTL_TTL[i]>0))

                                         eltotal=eltotal-@DTL_TTL[i]
                                    ENDIF
                               ENDIF
                            ENDIF
                        ENDFOR
                        //infomessage "antes if"
                        IF (eltotal<0.05) 
                            IF (eltotal>0)
                                eltotal=0
                            ENDIF
                        ENDIF
                       //infomessage eltotal
                        montopagado=eltotal
                        IF (eltotal>=0)
                            call registrarOperacion("PAGAR",gMsrTarjeta)
                            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",montopagado,"|",gMsrMetodo,"|",cantItems,items
                        ELSE
                            //format montopagado as "-",(eltotal*-1)
                            montopagado=montopagado*(-1)
                            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","NOTA_CREDITO_COMPRA","|",gMsrTarjeta,"|",montopagado
                        ENDIF

                        

                        call EnviaTransaccion
                        call RecibeTransaccion
                        IF @RxMsg <> "_timeout" 
                            call procesarRespuesta
                        ENDIF
                    ENDIF
                ELSE
                    exitwitherror "ERROR PagarMsr" 
                ENDIF
            ELSE
                exitwitherror "NO SE PUEDEN REALIZAR PAGOS MIXTOS CON SBX CARD" 
            ENDIF
        ELSE //hay cargos de servicio, no se puede pagar con rewards
            exitwitherror "TICKET CON RECARGAS DE SALDO, NO SE PUEDE PAGAR CON SBX CARD"
        ENDIF
   ELSE
      call mostrarmensaje("PRIMERO DEBE IDENTIFICARSE")
   ENDIF
endsub
//*****************************************************
//procesar pago MSR
//*****************************************************
sub procesarPagoMSR
    gMsrHayBeneficio=0
    gMsrHayBeneficioDesc=0
    LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, gMsrTender) 
    gMsrOk=0
endsub
//*****************************************************
//consulta saldo MSR
//*****************************************************
SUB consultaSaldoMSR(VAR conlectura:N1,VAR silencioso:N1)
    VAR aux: A20
    VAR porTarjeta: N1=1
    VAR MsrActual: A20
    porTarjeta=gPorBanda
    //call crearDiaNegocio
    gMsrSaldoActual=0
    MsrActual=gMsrTarjeta
    IF (conlectura=1)
        call consultarCodigoTarjeta("Deslice Tarjeta Rewards",aux,porTarjeta)
    ENDIF
    
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONSULTAR_SALDO","|",aux
    call EnviaTransaccion
    call RecibeTransaccion
    
    if @RxMsg <> "_timeout" 
        call procesarRespuesta
        UpperCase gDescRespuesta
        IF (mid(gDescRespuesta,1,2)="01") //error con valuelink
            exitwitherror "NO HAY COMUNICACION CON VALUELINK - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS"
        ENDIF
    ELSE
        exitwitherror "NO HAY COMUNICACION CON REWARDS - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS (SIN INTERNET)"
    ENDIF

    gMsrTarjeta=MsrActual

    IF (gMsrSaldoActual=1 and silencioso=0)
        format aux as "SALDO: ",gMsrSaldo
        CALL mostrarmensaje(aux)
    ENDIF
ENDSUB
//*****************************************************
//Registrar operacion
//*****************************************************
sub registrarOperacion(VAR operacion:A30, VAR texto:A40)
     VAR textoenviar:A80
     call crearDiaNegocio
     format textoenviar as "LOG: ",operacion," ",texto, " ",@TTLDUE," ",@SVC," Metodo: ",gMsrMetodo
     format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","MENSAJE_LOG","|",textoenviar
     call EnviaTransaccion
     call RecibeTransaccion
EndSub
//*****************************************************
//cargar Saldo MSR
//*****************************************************
sub cargarSaldoMSR
    var porTarjeta : N1=1
    var i: N4 = 0
    var cantItems : N4 = 0
    var items: A400 = ""
    porTarjeta=gPorBanda
    gCodigoRespuesta = ""
    gDescRespuesta  = ""

    IF (gMsrOk=1)
            call registrarOperacion("RECARGA",gMsrTarjeta)
            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","RECARGAR_TARJETA","|",gMsrTarjeta,"|",@TTLDUE,"|",gMsrMetodo

            call EnviaTransaccion
            call RecibeTransaccion
            IF @RxMsg <> "_timeout" 
                call procesarRespuesta
                //call mostrarmensaje("GENERAR RECIBO X, CIERRO TICKET")
                
                LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, 2)
            ENDIF
    ELSE
        call mostrarmensaje("PRIMERO DEBE IDENTIFICARSE")
    ENDIF
endsub
//*****************************************************
//cargar Saldo MSR
//*****************************************************
sub consultarBeneficios
    var porTarjeta : N1=1
    var i: N4 = 0
    var cantItems : N4 = 0
    var items: A400 = ""
    porTarjeta=gPorBanda
    gCodigoRespuesta = ""
    gDescRespuesta  = ""

    IF (gMsrOk=1)
            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","GET_BENEFICIOS","|",gMsrTarjeta

            call EnviaTransaccion
            call RecibeTransaccionBeneficios
            IF @RxMsg <> "_timeout" 
                call procesarRespuesta
            ENDIF
    ELSE
        call mostrarmensaje("PRIMERO DEBE IDENTIFICARSE")
    ENDIF
endsub
//*****************************************************
//ultimos beneficios redimidos
//*****************************************************
sub consultarBeneficiosRedimidos
    var porTarjeta : N1=1
    var i: N4 = 0
    var cantItems : N4 = 0
    var items: A400 = ""
    porTarjeta=gPorBanda
    gCodigoRespuesta = ""
    gDescRespuesta  = ""

    IF (gMsrOk=1)
            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PEDIDO_DE_BENEFICIOS_REDIMIDOS","|",gMsrTarjeta

            call EnviaTransaccion
            call RecibeTransaccionBeneficiosRedimidos
            IF @RxMsg <> "_timeout" 
                call procesarRespuesta
            ENDIF
    ELSE
        call mostrarmensaje("PRIMERO DEBE IDENTIFICARSE")
    ENDIF
endsub
//************************* MSR  *****************************
//valido si hay items de recarga y venta en el mismo ticket
//****************************************************************
Sub validarItemsTicket
    IF (@SVC>0 and @TTLDUE>0)
        exitwitherror "ERROR: EL TICKET CONTIENE RECARGAS Y PRODUCTOS"
    ENDIF
    IF (gMsrTipoTarjeta="Gift Card")
        exitwitherror "ERROR: NO SE PUEDE RECARGAR UNA TARJETA NO REGISTRADA"
    ENDIF  
endsub
//************************ MSR *******************************
//Envia recargas OFFLINE
//****************************************************************
sub enviarRecargasOffline
    var i : N3
    var recibido:N1
    var cuantas :N3
    var aux: A50

    cuantas=0
    If (gOffCant>0)
        i=gOffCant
        recibido=1
        WHILE ((i>0) and (recibido=1))
            TXMSG gOffCargas[i] 
            GetRXMsg "Enviando recargas OFFLINE...." 
            IF @RxMsg = "_timeout" //Llega la Respuesta
                recibido=0
            ENDIF
            if (recibido=1)
                i=i-1
                gOffCant=gOffCant-1
                cuantas=cuantas+1
            ENDIF
        ENDWHILE
    ENDIF
    IF (cuantas>0)
        format aux as "SE ENVIARON CON EXITO ",cuantas," RECARGAS PENDIENTES"
        call MostrarMensaje(aux)
    ENDIF
endsub
//************************* MSR  *****************************
//valido si estoy haciendo el pago de recarga de saldo
//****************************************************************
Sub pagoFinal
    VAR aux:A100
    VAR intentos:N1=0
    VAR i:N3=0
    VAR tender:N5=0
    VAR tenderdesc:A15="EFECTIVO"
    VAR espera:N5=5000

    gMsrRecargaOk=0
    
    gMsrMontoRecarga=0
    //gMsrRecargaAnulacion=0
    IF gMsrOk=1  //estoy en una transaccion MSR, tengo que validar que sea recarga
        IF (@SVC>0 and @TTLDUE=0) //solo tengo en el item la recarga de saldo
            gMsrMontoRecarga=@SVC
            WHILE (intentos<gMsrMaxReintentos and gMsrRecargaOk=0)
                IF (intentos>0)
                    format aux as "ERROR EN CARGA DE SALDO. REINTENTO ",intentos," .NO APAGUE EL POS"
                    call mostrarmensaje (aux)
                    msleep espera
                    espera=espera+5000*intentos
                ENDIF  

                //veo con cual tender se pago
                FOR i=1 to @NUMDTLT
                    IF (@DTL_TYPE[i]="T" AND @DTL_IS_VOID[i] = 0)
                       tender=@DTL_OBJECT[i]
                    ENDIF
                ENDFOR
                IF (tender>=gTenderTarjetas)
                    IF (tender=gTenderMPago) //MPAGO
                        format tenderdesc as "MERCADO PAGO|",tender
                        format gMedioAnulacion as "MPAGO - ",tender
                    ELSE
                        format tenderdesc as "TARJETA|",tender
                        format gMedioAnulacion as "TARJETA - ",tender
                    ENDIF
                ELSE
                    format tenderdesc as "EFECTIVO|",tender
                    format gMedioAnulacion as "EFECTIVO - ",tender
                ENDIF
                format aux as "RECARGA ",intentos
                call registrarOperacion(aux,gMsrTarjeta)
 
                format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","RECARGAR_TARJETA","|",gMsrTarjeta,"|",@SVC,"|",tenderdesc,"|",gMsrMetodo
                gMsrEnRecarga=1
                gUltMsrMontoRecarga=@SVC
                gUltMsrNombre=gMsrNombre
                gUltMsrDni=gMsrDNI
                gUltMsrTarjeta=gMsrTarjeta
                gUltMsrStars=gMsrStars
                gUltMsrCheque=@cknum
                
                call EnviaTransaccion
                call RecibeTransaccion
                IF @RxMsg <> "_timeout" 
                    call procesarRespuesta
                    gMsrEnRecarga=0
                    
                    IF (gMsrRecargaOk=1)
                        IF (gFiscal=0)
                            LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                        ELSE
							//infomessage "Imprime comprobante"
                            call procesoReciboX
                        ENDIF
                    ENDIF
                    //call mostrarmensaje("GENERAR RECIBO X, CIERRO TICKET")
                ENDIF
                intentos=intentos+1
             ENDWHILE
             IF (gMsrRecargaOk=0)
                
                //recarga offline
                //IF (gOffCant<gOffMax)
                //    gOffCant=gOffCant+1

                //    call registrarOperacion("RECARGA_OFFLINE",gMsrTarjeta)

                //    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","RECARGAR_OFFLINE","|",gMsrTarjeta,"|",@SVC,"|",tenderdesc,"|",gMsrMetodo
                //    gOffCargas[gOffCant]=gDatos
                //ENDIF
                IF (intentos=gMsrMaxReintentos)
                    gProcesoRecargaNO=1
                    call mostrarmensaje("ERROR AL CARGAR SALDO. SE GENERA BEBIDA POR FALLA EN RECARGA")                  
                    IF (gFiscal=0)
                        LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                    ELSE
                        call procesoReciboX
                    ENDIF
                ENDIF
             ENDIF
        ELSE
           IF (gMsrHayBeneficio>=1) //tengo un beneficio pero no pago con rewards
                IF (@TTLDUE<1) //debo registrar en backoffice
                    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",0,"|",gMsrMetodo,"|1|1|1|10|1|NO"
                ELSE
                    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",0,"|",gMsrMetodo,"|0|0|0|0|0|NO"
                ENDIF
                call EnviaTransaccion
                call RecibeTransaccion
                
                IF @RxMsg <> "_timeout" 
                    call procesarRespuestaSinMsr
                ENDIF
           ENDIF
        ENDIF
    ELSEIF (gMsrEnVtaGiftCard=1) //estoy en transaccion de venta giftcard
        gMsrMontoRecarga=@SVC

        //veo con cual tender se pago
        FOR i=1 to @NUMDTLT
            IF (@DTL_TYPE[i]="T" AND @DTL_IS_VOID[i] = 0)
               tender=@DTL_OBJECT[i]
            ENDIF
        ENDFOR
        IF (tender>3)
            IF (tender=43) //MPAGO
                format tenderdesc as "MERCADO PAGO|",tender
            ELSE
                format tenderdesc as "TARJETA|",tender
            ENDIF
        ELSE
            format tenderdesc as "EFECTIVO|",tender
        ENDIF

        format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","ALTA_GIFTCARD","|",gMsrTarjeta,"|",@SVC,"|",tenderdesc
         WHILE (intentos<gMsrMaxReintentos and gMsrRecargaOk=0)
            IF (intentos>0)
                format aux as "ERROR EN VENTA GIFTCARD CARGANDO SALDO. REINTENTO ",intentos," .NO APAGUE EL POS"
                call mostrarmensaje (aux)
                msleep espera
                espera=espera+7000*intentos
            ENDIF
            call EnviaTransaccion
            call RecibeTransaccion
            IF @RxMsg <> "_timeout" 
                call procesarRespuesta
                IF (gMsrRecargaOk=1)
                    gUltMsrMontoRecarga=@SVC
                    gUltMsrNombre=""
                    gUltMsrDni=0
                    gUltMsrTarjeta=gMsrTarjeta
                    gUltMsrStars=0
                    IF (gFiscal=0)
                        LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                    ELSE
                        call procesoReciboX
                    ENDIF
                ELSE
                    //call mostrarmensaje ("ERROR EN ACTIVACION DE GIFTCARD, VALIDE EL SALDO")
                ENDIF
            ELSE
                //call mostrarmensaje ("ERROR EN VTA GIFTCARD, VALIDE SALDO")
            ENDIF
            intentos=intentos+1
         ENDWHILE
         IF (gMsrRecargaOk=0 and intentos=gMsrMaxReintentos)
            //activaci�n giftcard offline?
             call mostrarmensaje ("ERROR EN VTA GIFTCARD, VALIDE SALDO") 
         ENDIF
    ELSEIF (gMsrHayBeneficio>=1) //tengo un beneficio pero no pago con rewards
        format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",0,"|",gMsrMetodo,"|",0,0,0,0
        call EnviaTransaccion
        call RecibeTransaccion
        IF @RxMsg <> "_timeout" 
            call procesarRespuestaSinMsr //
        ENDIF
    ENDIF
    IF (gMsrRecargaAnulacion=1) //estoy haciendo devolucion en efectivo
        IF (gFiscal=0)
            LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
        ELSE
            call procesoReciboX
        ENDIF
    ENDIF
   
    IF (gPausaRecarga=0)
        gMsrOk=0
        gMsrHayBeneficio=0
        gMsrHayBeneficioDesc=0
    ENDIF
    gMsrRecargaOk=0
    gMsrEnVtaGiftCard=0
    
ENDSUB
//************************  MSR ******************************
//Envia transaccion al servidor central
//****************************************************************
sub EnviaTransaccion
	gStatus=0
	TXMSG gDatos 
	GetRXMsg "Esperando Respuesta de Servicio" 
endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion del servidor central
//****************************************************************
sub RecibeTransaccion
        gCodigoMicrosNivel=1
        
	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gMsrSaldo,gMsrTarjeta,gMsrNombre,gMsrNivel,gMsrStars,gMsrBebFav,gMsrTipoTarjeta,gMsrStarsFaltantes,gMsrDNI,gMsrMontoAnual,gSolicitudExtranjero,gSolicitudSexo,gMsrReimprimir,gMontoReciboXOnline
	endif
	
endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion de beneficios del servidor central
//****************************************************************
sub RecibeTransaccionBeneficios
        var mensaje: A170=""
        var jj: N2
        gCodigoMicrosNivel=1

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
	else
           clearArray gBeneficiosLista
           clearArray gBeneficiosCodigos
           gBeneficiosCant=0
           gBeneficioTicketCompleto="N"
           
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gBeneficiosCant,gBeneficiosCodigos[]:gBeneficiosLista[]
	endif

endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion de beneficios redimidos del servidor central
//****************************************************************
sub RecibeTransaccionBeneficiosRedimidos
        var mensaje: A170=""
        var jj: N2

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
	else
           clearArray gBeneficiosListaRedimidos
           clearArray gBeneficiosCodigosRedimidos
           clearArray gBeneficiosTiendaRedimidos
		   clearArray gBeneficiosTiempoRedimidos
           gBeneficiosCant=0
           
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gBeneficiosCant,gBeneficiosCodigosRedimidos[]:gBeneficiosListaRedimidos[]:gBeneficiosTiendaRedimidos[]:gBeneficiosTiempoRedimidos[]
	endif

endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion de solicitud del servidor central
//****************************************************************
sub RecibeTransaccionSolicitud
        var mensaje: A170=""

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
	else
           clearArray gSolicitudLineas
           gSolicitudCantLineas=0        
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gSolicitudNombre,gSolicitudDni,gSolicitudExtranjero,gSolicitudSexo,gSolicitudProxPaso,gSolicitudCantLineas,gSolicitudLineas[]
	endif
endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion de solicitud del servidor central
//****************************************************************
sub RecibeTransaccionSimple
        var mensaje: A170=""

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
           InfoMessage "Descuentos", "NO SE PUDO REVERTIR EL DESCUENTO, CANCELE EL TICKET"
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta
	endif
endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion de beneficios de la opcion del servidor central
//****************************************************************
sub RecibeTransaccionBeneficiosOpcion
        gCodigoMicrosNivel=1

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
	else
           clearArray gCodigosTipo
           clearArray gCodigos
           clearArray gCodigosNivel
           gContadorProd=0
           gBeneficioTicketCompleto="N"
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gBeneficioTicketCompleto,gContadorProd,gCodigosTipo[]:gCodigos[]:gCodigosNivel[]
	endif
endsub
//************************* MSR ******************************
//Recibe respuesta de transaccion de multiples de la opcion del servidor central
//****************************************************************
sub RecibeTransaccionMultOpciones
        gCodigoMicrosNivel=1

	if @RxMsg = "_timeout" //Llega la Respuesta
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           gStatus=1
	else
           clearArray gMultDesc
           clearArray gMultTipo
           clearArray gMultNivel
           clearArray gMultCodigo
           gMultCant=0
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gMultCant,gMultDesc[]:gMultTipo[]:gMultCodigo[]:gMultNivel[]
	endif
endsub
//************************* MSR  *****************************
//Dispatcher de respuestas de MSR
//****************************************************************
Sub procesarRespuesta
    VAR pricelevel :N2
    VAR aux : A200
    pricelevel=@slvl

    IF (gCodigoRespuesta="INFO_MIEMBRO") 
        IF (gMsrEnVtaGiftCard=0 and gPausaRecarga=0)           
            gMsrOk=1
            call cargarInfoLines
        ELSEIF (gPausaRecarga=1)
            gPausaRecarga=2
        ELSE
            gMsrEnVtaGiftCard=0
        ENDIF
        //call mostrarmensaje("gMsrOk=1")
    ELSEIF (gCodigoRespuesta="PAGAR_OK")
        call procesarPagoMSR
    ELSEIF (gCodigoRespuesta="SALDO_TARJETA")
        gMsrSaldoActual=1
    ELSEIF (gCodigoRespuesta="RECARGA_OK")
        gMsrRecargaOk=1
    ELSEIF (gCodigoRespuesta="ALTA_GIFTCARD_OK")
        gMsrRecargaOk=1
    ELSEIF (gCodigoRespuesta="INFO_DE_TARJETA")
        call mostrarmensaje("SALDO CARGADO")
    ELSEIF (gCodigoRespuesta="LISTADO_DE_BENEFICIOS")
        IF (gMsrBeneficiosLista=0)
            IF (gBeneficiosCant>0)
                call mostrarBeneficios
            ELSE
                call mostrarmensaje("NO POSEE BENEFICIOS ACTIVOS")
            ENDIF
        ENDIF
    ELSEIF (gCodigoRespuesta="LISTADO_DE_BENEFICIOS_REDIMIDOS")
            IF (gBeneficiosCant>0)
                call mostrarBeneficiosRedimidos
            ELSE
                call mostrarmensaje("NO POSEE BENEFICIOS REDIMIDOS EN LOS ULTIMOS 15 DIAS")
            ENDIF
    ELSEIF (gCodigoRespuesta="LISTADO_DE_OPCIONES")
        call mostrarOpciones
    ELSEIF (gCodigoRespuesta="SELECCIONAR_OK")
        call aplicarBeneficio
    ELSEIF (gCodigoRespuesta="CANCELAR_OK")
        //no hago nada
    ELSEIF (gCodigoRespuesta="NOTA_CREDITO_OK")
        IF (gMsrRecargaAnulacion>=1)
            gMsrRecargaOk=1
        ELSE
            call procesarPagoMSR
        ENDIF
    ELSEIF (gCodigoRespuesta="LOGOUT_OK")
        gMsrTarjeta = ""
    ELSEIF (gCodigoRespuesta="DETALLE_SOLICITUD")
        call procesarSolicitud(0,0)
    ELSEIF (gCodigoRespuesta="REIMPRIMIR_CONTRATO_OK")
        call procesarSolicitud(1,0)
    ELSEIF (gCodigoRespuesta="CONTRATO_FIRMADO_OK")
        call mostrarMensaje("El contrato fue confirmado con exito")
    ELSEIF (gMsrEnVtaGiftCard=1)
        //salteo el error si estoy validando una tarjeta nueva giftcard
        gMsrTipoTarjeta="NUEVA"
        IF (gCodigoRespuesta="ERROR")
            UpperCase gDescRespuesta
           
            IF (len(gDescRespuesta>10))
                IF (mid(gDescRespuesta,len(gDescRespuesta)-8,9)="BLOQUEADA")
                    gMsrTipoTarjeta="ERROR"
                    call mostrarmensaje("ERROR: TARJETA BLOQUEDA")
                ENDIF
            ENDIf
        ENDIF
    ELSEIF (gCodigoRespuesta="ASOCIAR_TARJETA_OK")
        call mostrarMensaje("Tarjeta asociada con exito")
    ELSEIF (gCodigoRespuesta="HEARTBEAT_OK")
        //no hago nada
    ELSE
        gMsrRecargaOk=0
        format aux as gCodigoRespuesta," : ",gDescRespuesta
        call mostrarmensaje(aux)
        LOADKYBDMACRO KEY(1, 196613) //me quedo en la pantalla actual
        IF (gMsrEnRecarga=1) //estoy recargando, en pago final pero dio error
            gProcesoRecargaNO=1
            call mostrarmensaje("ERROR AL CARGAR SALDO. SE GENERA BEBIDA POR FALLA EN RECARGA")
		else
			gMsrTarjeta=""
        ENDIF
    ENDIF
endsub
//************************* MSR  *****************************
//Dispatcher de respuestas de MSR
//****************************************************************
Sub procesarRespuestaSinMsr
    VAR pricelevel :N2
    VAR aux : A200
    pricelevel=@slvl

    IF (gCodigoRespuesta<>"PAGAR_OK")
        format aux as gCodigoRespuesta," : ",gDescRespuesta
        call mostrarmensaje(aux)
    ENDIF
endsub
//*************************** MSR *****************************
// Carga de infolines
// **********************************************************
Sub cargarInfoLines
    Var texto   :A30
    Var saldo   :A30
    Var i:N1
    Var cuantos: N1

    clearchkinfo
    IF (gMsrTipoTarjeta="Gift Card")
        savechkinfo "NO REGISTRADA"
        format texto as "Saldo: ",gMsrSaldo
        savechkinfo texto
        format saldo as "NO REGISTRADA: ",gMsrSaldo        
    ELSE

        //la ultima persona pasa a ser esta
        gUltMsrNombre=gMsrNombre
        gUltMsrDni=gMsrDNI
        gUltMsrTarjeta=gMsrTarjeta
        gUltMsrStars=gMsrStars

        savechkinfo mid(gMsrNombre,1,30)
        format texto as "Nivel: ",gMsrNivel
        savechkinfo texto
        format texto as "Saldo: ",gMsrSaldo
        saldo=texto
        savechkinfo texto
        format texto as "Stars: ",gMsrStars
        savechkinfo texto
        format texto as "Prox Nivel: ",gMsrStarsFaltantes," Stars"
        savechkinfo texto

	IF (len(gMsrBebFav)<24)
                format texto as "F: ",gMsrBebFav
        else
                format texto as "F: ",mid(gMsrBebFav,1,24)
        endif

        savechkinfo texto
         //mostramos beneficios
         gMsrBeneficiosLista=1
         call consultarBeneficios
         IF (gBeneficiosCant>4) 
            cuantos=4
         ELSE
            cuantos=gBeneficiosCant
         ENDIF
         FOR i=1 to cuantos
            IF (len(gBeneficiosLista[i])<24)
                texto=gBeneficiosLista[i]
            ELSE
                texto=mid(gBeneficiosLista[i],1,24)
            ENDIF
            savechkinfo texto
         ENDFOR
         gMsrBeneficiosLista=0
    ENDIF 
    IF (@cknum=0)  
        gBeginCheckMacro=1
       // LoadKybdMacro Key(1,327681) //abro un ticket
    ENDIF
endsub
//*************************** MSR *****************************
// Ingreso de codigo tarjeta
// ****************************************************************
Sub consultarCodigoTarjeta(Var titulo:A50,Ref codigoIngresado_, Ref porbanda)   	
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var codigoIngresado	: A40
        Var mensaje             : A30
        Var espacio             : N2
        Var aux                 : A30
        
        Touchscreen gTouchSinNumeros
        @validate_mag_track = 0 // disable track 2 validation
        format mensaje as "Version ",gVersion," Chk:",@cknum
        porbanda=1
	
	Window 2,50, titulo		
		Display 1, 1, "Codigo: "
		Display 2, 1, mensaje
                DisplayMSinput 1, 10, codigoIngresado{m2, *},""
	WindowInput	
	WindowClose	
		
                IF @MAGSTATUS = "N"
                        porbanda=0
                        gMsrMetodo="APP"
                        IF len(codigoIngresado>16)
                            codigoIngresado_=mid(codigoIngresado,1,16)
                        ELSE
                            Format codigoIngresado_ 	As Trim(codigoIngresado)
                        ENDIF
                        //call MostrarMensaje ("Debe deslizar la tarjeta")
                ELSE
                    gMsrMetodo="TARJETA"
                    Format aux     As Mid(codigoIngresado,30,1)
                    Format aux     As aux, Mid(codigoIngresado,32,2)
                    Format aux     As aux, Mid(codigoIngresado, 7,1)
                    Format aux     As aux, Mid(codigoIngresado, 8,8)
                    Format aux     As aux, Mid(codigoIngresado,34,4)
                    codigoIngresado_= aux
                ENDIF
                IF (codigoIngresado_="")
                    gMsrMetodo="TARJETA"
                ENDIF
       Touchscreen gTouch
EndSub
//*************************** MSR *****************************
// Ingreso de Busqueda de Solicitud o reimprime un contrato
// ****************************************************************
Sub buscarSolicitud(VAR reimprimir:N1,VAR porqr:N1)   	
        Var mensaje             :A50
        Var dni                 :A15
        Var dniaux              :A38=""
        Var sexo                :A1
        Var trajodoc            :A1
        Var extranjero          :A1
        Var datosok             :N1
        Var auxqr               :A1024=""
        Var resqr               :N2=0
        Var aux1                :A50=""
        Var aux2                :A50=""
        Var aux3                :A50=""
        Var aux4                :A50=""
        Var aux5                :A50=""
        Var aux6                :A50=""
        Var aux7                :A50=""
        VAr fechanac            :A12=""
        Var dia                 :A2=""
        Var mes                 :A2=""
        Var ano                 :A4=""

        IF (reimprimir=0)
            format mensaje as "Busqueda de Solicitud - Version ",gVersion," Chk:",@cknum
        ELSE
            format mensaje as "Reimpresion de Contrato - Version ",gVersion," Chk:",@cknum
        ENDIF
        
        IF (porqr=1) THEN
            call leerTextoQR(auxqr,resqr)
            IF ((resqr>0) and (auxqr<>""))
                IF (mid(auxqr,1,1)="@")
                    //dni viejo
                    Split auxqr, "@", aux1,dniaux,aux2,aux3,aux4,aux5,aux6,fechanac,sexo
                    extranjero="N"
                ELSE
                    //dni nuevo
                    Split auxqr, "@", aux1,aux2,aux3,sexo,dniaux,aux4,fechanac
                    extranjero="N"
                ENDIF
            ENDIF
            TouchScreen gTouch
            Split fechanac, "/", dia, mes,ano
           
        ELSE
            dniaux=" "
        ENDIF

        IF (dniaux<>"") THEN
            
            Window 6,50, mensaje

                    IF (porqr=0) THEN
                        Display 1, 1, "DNI: "
                        //Display 2, 1, "Sexo: "
                        IF (reimprimir=0)
                            Display 2, 1, "Dia: "
                            Display 3, 1, "Mes: "
                            Display 4, 1, "A#o: "
                        ENDIF
                        Display 5, 1, "Extranjero: "
                    ENDIF
                    
                    IF (reimprimir=0) 
                        //Display 4, 1, "Entrego Doc: "
                    ENDIF
                    IF (porqr=0) THEN
                        DisplayInput 1, 13, dniaux{15},""
                       // DisplayInput 2, 13, sexo{1},"M/F"
                        IF (reimprimir=0)
                            DisplayInput 2, 13, dia{2},""
                            DisplayInput 3, 13, mes{2},""
                            DisplayInput 4, 13, ano{2},""
                        ENDIF
                        DisplayInput 5, 13, extranjero{1},"S/N"
                    ENDIF
                    
                    IF (reimprimir=0) 
                        //DisplayInput 4, 13, trajodoc{1},"S/N"
                    ENDIF
            WindowInput	
            WindowClose	
            trajodoc="S"
            IF (@Inputstatus=1 or resqr>0)
                datosok=1     
                uppercase sexo
                uppercase dniaux
                
                dni=trim(dniaux)
                
                uppercase extranjero 
                uppercase trajodoc

                //IF (sexo<>"M" and sexo<>"F")
                 //   datosok=0
                IF (extranjero<>"S" and extranjero<>"N")
                    datosok=0
                ELSEIF (reimprimir=0 and trajodoc<>"S" and trajodoc<>"N")
                    datosok=0
                ELSEIF ((reimprimir=0) and (dia="" or mes="" or ano=""))
                    datosok=0
                ENDIF
                IF (datosok=1)
                    
                     IF (reimprimir=0) 
                        format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","BUSCAR_SOLICITUD","|",sexo,"|",dni,"|",extranjero,"|",trajodoc,"|",dia,"|",mes,"|",ano
                     ELSE
                        format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","REIMPRIMIR_CONTRATO","|",sexo,"|",dni,"|",extranjero
                     ENDIF
                     call EnviaTransaccion
                     call RecibeTransaccionSolicitud
                     call procesarRespuesta
                ELSE
                    call mostrarMensaje("Datos ingresados incorrectos")
                ENDIF
            ELSE
                call mostrarMensaje ("Debe completar todos los campos")
            ENDIF
       ELSE
        call mostrarMensaje("Debe scanear el DNI")
       ENDIF
EndSub

//*************************** MSR *****************************
// Asociacion de tarjeta por dni
// ****************************************************************
Sub asociarTarjetaDni(VAR esrepo:N1, VAR porqr:N1)   	
        Var mensaje             :A50
        Var dni                 :A15
        Var dniaux              :A15
        Var sexo                :A1
        Var extranjero          :A1
        Var datosok             :N1
        Var numtarjeta          :A20
        Var porTarjeta          :N1=0
        Var auxqr               :A1024=""
        Var resqr               :N2=0
        Var aux1                :A50=""
        Var aux2                :A50=""
        Var aux3                :A50=""
        Var aux4                :A50=""
        Var aux5                :A50=""
        Var aux6                :A50=""
        Var aux7                :A50=""

        format mensaje as "Asociar Tarjeta - Version ",gVersion," Chk:",@cknum
	
        IF (porqr=1) THEN
            call leerTextoQR(auxqr,resqr)
            IF ((resqr>0) and (auxqr<>""))
                IF (mid(auxqr,1,1)="@")
                    Split auxqr, "@", aux1,dniaux,aux2,aux3,aux4,aux5,aux6,aux7,sexo
                    extranjero="N"
                ELSE
                    Split auxqr, "@", aux1,aux2,aux3,sexo,dniaux
                    extranjero="N"
                ENDIF
            ENDIF
            TouchScreen gTouch
        ELSE
            Window 3,50, mensaje
		
		Display 1, 1, "DNI: "
		//Display 2, 1, "Sexo: "
                Display 3, 1, "Extranjero: "
                DisplayInput 1, 13, dniaux{15},""
                //DisplayInput 2, 13, sexo{1},"M/F"
                DisplayInput 3, 13, extranjero{1},"S/N"
            WindowInput	
            WindowClose	
        ENDIF

	
        IF (@Inputstatus=1 or resqr>0)
            datosok=1
        
            uppercase sexo
            uppercase dniaux
            dni=trim(dniaux)
            uppercase extranjero 
            
           // IF (sexo<>"M" and sexo<>"F")
            //    datosok=0
            IF (extranjero<>"S" and extranjero<>"N")
                datosok=0
            ENDIF
            IF (datosok=1)
                IF (porqr=1) THEN
                    format aux7 as "ASOCIAR TARJETA A DNI: ",dni
                    InfoMessage aux7
                ENDIF
                
                IF (esrepo=1)
                    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","ASOCIAR_TARJETA_POR_REPOSICION","|",sexo,"|",dni,"|",extranjero,"|",gCodigoIngresado,"|S"
                    call EnviaTransaccion
                    call RecibeTransaccion
                    IF @RxMsg <> "_timeout"
                        UpperCase gDescRespuesta
                        IF (gCodigoRespuesta="ASOCIAR_TARJETA_OK")
                            //impacto tender
                            gMsrEnVtaGiftCard=0
                            LoadKybdMacro Key (9, 2) //aplico tender efectivo
                        ELSE
                            exitwitherror gDescRespuesta
                        ENDIF
                    ELSE
                        exitwitherror "NO HAY COMUNICACION CON SERVICIO REWARDS - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS  (SIN INTERNET)"
                    ENDIF
                ELSE

                    call consultarCodigoTarjeta("Deslice Nueva Tarjeta Rewards",numtarjeta,porTarjeta)
                    //porTarjeta=1 //CAMBIAR
                    IF (numtarjeta="")
                       call mostrarMensaje("NO SE PUDO LEER LA TARJETA")
                    ELSE
                       IF (porTarjeta=1 or gPorBanda=0)
                           format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONSULTAR_SALDO","|",numtarjeta
                           call EnviaTransaccion
                           call RecibeTransaccion

                           IF @RxMsg <> "_timeout" 
                               UpperCase gDescRespuesta
                               IF (gCodigoRespuesta="SALDO_TARJETA")
                                   IF (gMsrSaldo>0)
                                       format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","ASOCIAR_TARJETA","|",sexo,"|",dni,"|",extranjero,"|",numtarjeta
                                       call EnviaTransaccion
                                       call RecibeTransaccion
                                       call procesarRespuesta
                                   ELSE
                                       exitwitherror "NO SE PUEDE ASOCIAR UNA TARJETA SIN SALDO"
                                   ENDIF
                               ELSE
                                   IF (gDescRespuesta="NO EXISTE LA TARJETA SOLICITADA")
                                       exitwitherror "NO SE PUEDE ASOCIAR UNA TARJETA SIN SALDO"
                                   ELSE
                                       exitwitherror gDescRespuesta
                                   ENDIF
                               ENDIF

                               //IF (mid(gDescRespuesta,1,2)="01") //error con valuelink
                               //    exitwitherror "NO HAY COMUNICACION CON VALUELINK - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS"
                               //ENDIF
                           ELSE
                               exitwitherror "NO HAY COMUNICACION CON SERVICIO REWARDS - PRUEBE NUEVAMENTE EN UNOS SEGUNDOS (SIN INTERNET)"
                           ENDIF


                       ELSE
                           call mostrarMensaje("Solo se permite lectura de banda magnetica")
                       ENDIF
                    ENDIF
                 ENDIF
            ELSE
                call mostrarMensaje("Datos ingresados incorrectos")
            ENDIF
        ELSE
            call mostrarMensaje ("Debe completar todos los campos")
        ENDIF
EndSub
//*************************** MSR *****************************
// Asociacion de tarjeta por otra tarjeta
// ****************************************************************
Sub asociarTarjeta   	
        Var mensaje             :A50
        Var datosok             :N1
        Var numtarjeta          :A20
        Var porTarjeta          :N1=0
        porTarjeta=gPorBanda
        call consultarCodigoTarjeta("Deslice Tarjeta Rewards del Cliente",numtarjeta,porTarjeta)
        IF (porTarjeta=1 or gPorBanda=0)
           format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","ASOCIAR_TARJETA","|",sexo,"|",dni,"|",extranjero,"|",numtarjeta
           call EnviaTransaccion
           call RecibeTransaccion
           call procesarRespuesta
        ELSE
           call mostrarMensaje("Solo se permite lectura de banda magnetica")
        ENDIF
EndSub
//*************************** MSR *****************************
// Proceso de Reimpresion de contrato
// ****************************************************************
Sub reimprimirContrato
    gSolicitudNombre=gMsrNombre
    gSolicitudDni=gMsrDNI
    
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","REIMPRIMIR_CONTRATO","|",gSolicitudSexo,"|",gSolicitudDni,"|",gSolicitudExtranjero
    call EnviaTransaccion
    call RecibeTransaccionSolicitud
    //call procesarRespuesta

    call procesarSolicitud(1,1)
EndSub
//*************************** MSR *****************************
// Proceso de Solicitud de adhesion
// ****************************************************************
Sub procesarSolicitud(Var reimprimir:N1, VAR reimpautomatica:N1)   	
        Var mensaje             :A50
        Var aux : A80
        Var aux1: A80
        Var imprimir: A1
        Var firmo:N1
        format mensaje as "Proceso de Solicitud - Version ",gVersion," Chk: ",@cknum
	IF (reimpautomatica=1)
            format mensaje as "PEDIDO DE REIMPRESION DE CONTRATO DESDE OFICINAS"
        ENDIF
	Window 7,75, mensaje
		format aux as "Nombre: ",gSolicitudNombre
		Display 1, 1, aux
                format aux as "Dni: ",gSolicitudDni," - Extranjero: ",gSolicitudExtranjero
//," - Sexo: ",gSolicitudSexo
		Display 2, 1, aux
                
                //IF (len(gSolicitudProxPaso)>60)
                //    format aux as "Prox Paso: ",mid(gSolicitudProxPaso,1,60)
                //    format aux1 as "           ",mid(gSolicitudProxPaso,61,len(gSolicitudProxPaso))
                //ELSE
                //    format aux as "Prox Paso: ",gSolicitudProxPaso
                //    aux1=""
                //ENDIF

               // Display 3, 1, aux
                //Display 4, 1, aux1
                IF (reimpautomatica=1)
                    Display 4, 1, "PEDIDO DE REIMPRESION DE CONTRATO"
                    Display 5, 1, "SOLICITAR AL CLIENTE QUE FIRME NUEVAMENTE EL CONTRATO,"
                    Display 6, 1, "YA QUE LA COPIA ORIGINAL NO ERA LEGIBLE. GRACIAS"
                ENDIF
                Display 7, 1, "Confirma datos? (S/N): "
                
                DisplayInput 7, 23, imprimir{1},"S/N"
	WindowInput	
	WindowClose	
	
        IF (@Inputstatus=1)       
            uppercase imprimir
           
            IF (imprimir="S")
                call contratoFirmado


                //IF (gSolicitudCantLineas>0) 
                //    call getModeloFiscal
                //    IF (gFiscal=0)
                //        Call cargarDllImpresora
                //        call imprimirContrato(reimprimir)
                //        Call descargarDllImpresora

                //        call consultarMensaje("FIRMO EL CONTRATO?",firmo)
                        //call consultarsino(firmo,"FIRMO EL CONTRATO?")
                //        IF (firmo=1)
                //            call contratoFirmado
                //        ELSE
                //            call mostrarMensaje("EL CONTRATO NO SE HA FIRMADO. NO SE COMPLETO EL REGISTRO")
                //        ENDIF
                //    ELSE
                //        call imprimirContrato(reimprimir)
                //    ENDIF
                //ELSE
                //    call mostrarMensaje("No se recibio el contrato del servidor")
                //ENDIF
            ENDIF
            
        ELSE
            call mostrarMensaje ("Debe completar todos los campos")
        ENDIF
EndSub
//*****************************************************
//confirmar firma contrato 
//*****************************************************
sub contratoFirmado 
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|CONTRATO_FIRMADO|",gSolicitudSexo,"|",gSolicitudDni,"|",gSolicitudExtranjero
    call EnviaTransaccion
    call RecibeTransaccion
    if @RxMsg <> "_timeout" 
        call procesarRespuesta
    endif
endsub
//*************************** MSR *****************************
// Impresion de comprobante devolucion recarga
// ****************************************************************
Sub imprimirComprobanteDevolucion
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50
	Prompt "Imprimiendo Comprobante......"
	
        dll_status=0
        DLLCall_CDECL dll_handle, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )
        IF ( dll_status <> 0 )
                ErrorMessage dll_status_msg
        ELSE
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "COMPROBANTE DE DEVOLUCION DE RECARGA" )
            //DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "DE RECARGA" )
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
            format aux as "Tarjeta: ",gUltMsrTarjeta
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
            format aux as "Nombre: ",gUltMsrNombre
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
            format aux as "Monto: ",gUltMsrMontoRecarga
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
            format aux as "Medio: ",gMedioAnulacion
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
           // format aux as "Fecha: ",gFechaHoy," ",@hour," ",@minute
            //DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
            format aux as "Cajero: ",@TREMP_FNAME," ",@TREMP_LNAME
            DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
            
            IF ( dll_status <> 0 )
                ErrorMessage dll_status_msg
            ENDIF
        ENDIF

        DLLCall_CDECL dll_handle, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )

        IF ( dll_status <> 0 )
                ErrorMessage dll_status_msg
        ENDIF
        Prompt "idle"
EndSub
//*************************** MSR *****************************
// Impresion de comprobante devolucion recarga termica
// ****************************************************************
Sub imprimirComprobanteDevolucionTermica
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50
	Prompt "Imprimiendo Comprobante......"
	
        VAR k:N1=0
        Var lineaaux:A50=""
        VAR ConfigFile       : A128       // File Name
        VAR FileHandle       : N5  = 0   // File handle
        VAR auxwrite : N4

        FORMAT ConfigFile AS g_path, "DNFH.txt"
        FOPEN FileHandle, ConfigFile, WRITE
           
        IF FileHandle <> 0
            call grabarLinea(FileHandle, " " )
            call grabarLinea(FileHandle, " " )
            call grabarLinea(FileHandle, "COMPROBANTE DE DEVOLUCION DE RECARGA" )
            call grabarLinea(FileHandle, " " )
            format aux as "Tarjeta: ",gUltMsrTarjeta
            call grabarLinea(FileHandle, aux )
            format aux as "Nombre: ",gUltMsrNombre
            call grabarLinea(FileHandle, aux )
            format aux as "Monto: ",gUltMsrMontoRecarga
            call grabarLinea(FileHandle, aux )
            format aux as "Medio: ",gMedioAnulacion
            call grabarLinea(FileHandle, aux )
            format aux as "Cajero: ",@TREMP_FNAME," ",@TREMP_LNAME
            call grabarLinea(FileHandle, aux )
            fclose filehandle
            //imprimo 
           LoadDBKybdMacro gMacroImpTermica 
        ENDIF
        Prompt "idle"

EndSub
//*************************** MSR *****************************
// Impresion de comprobante de error de recarga Termica
// ****************************************************************
Sub imprimirComprobanteFallaRecargaTermica
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50

	Prompt "Imprimiendo Comprobante......"
	
        VAR k:N1=0
        Var lineaaux:A50=""
        VAR ConfigFile       : A128       // File Name
        VAR FileHandle       : N5  = 0   // File handle
        VAR auxwrite : N4

        FORMAT ConfigFile AS g_path, "DNFH.txt"
        FOPEN FileHandle, ConfigFile, WRITE
           
        IF FileHandle <> 0

            FOR i=1 to 2 
                IF (i=2)
                    call grabarLinea(FileHandle,chr(&1C))
                ENDIF
                
                call grabarLinea(FileHandle, " " )
                call grabarLinea(FileHandle, "COMPROBANTE DE RECARGA NO ACREDITADA" )
                call grabarLinea(FileHandle, " " )
                IF (i=1)
                    call grabarLinea(FileHandle, "      COPIA CLIENTE" )
                ELSE
                    call grabarLinea(FileHandle, "      COPIA BARISTA" )
                ENDIF 
                call grabarLinea(FileHandle, " " )
                call grabarLinea(FileHandle, "Estimado Cliente, conserve este ticket" )
                call grabarLinea(FileHandle, "como comprobante de su recarga no" )
                call grabarLinea(FileHandle, "acreditada. Por cualquier duda,por favor" ) 
                call grabarLinea(FileHandle, "contactar al centro de atencion al" )
                call grabarLinea(FileHandle, "cliente 0810-122-7289 de lunes a" )
                call grabarLinea(FileHandle, "viernes de 9 a 18 hs. Gracias." )
                call grabarLinea(FileHandle, " " )
                format aux as "SBux Card: ",gUltMsrTarjeta
                call grabarLinea(FileHandle, aux )
                format aux as "Cliente: ",gUltMsrNombre
                call grabarLinea(FileHandle, aux )
                format aux as "Importe: ",gUltMsrMontoRecarga
                call grabarLinea(FileHandle, aux )
                format aux as "Medio de pago: ",gMedioAnulacion
                call grabarLinea(FileHandle, aux )
                format aux as "CHK POS: ",gUltMsrCheque
                call grabarLinea(FileHandle, aux )
                format aux as "Cajero: ",@TREMP_FNAME," ",@TREMP_LNAME
                call grabarLinea(FileHandle, aux )

            ENDFOR
            fclose filehandle
            //imprimo 
           LoadDBKybdMacro gMacroImpTermica 
        ENDIF
        Prompt "idle"
EndSub
//*************************** MSR *****************************
// Impresion de comprobante de error de recarga
// ****************************************************************
Sub imprimirComprobanteFallaRecarga
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50
	Prompt "Imprimiendo Comprobante......"
        
        FOR i=1 to 2
            dll_status=0
            DLLCall_CDECL dll_handle, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )
            IF ( dll_status <> 0 )
                    ErrorMessage dll_status_msg
            ELSE
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "COMPROBANTE DE RECARGA NO ACREDITADA" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                IF (i=1)
                    DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "      COPIA CLIENTE" )
                ELSE
                    DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "      COPIA BARISTA" )
                ENDIF 
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Estimado Cliente, conserve este ticket" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "como comprobante de su recarga no" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "acreditada. Por cualquier duda,por favor" ) 
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "contactar al centro de atencion al" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "cliente 0810-122-7289 de lunes a" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "viernes de 9 a 18 hs. Gracias." )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                format aux as "SBux Card: ",gUltMsrTarjeta
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
                format aux as "Cliente: ",gUltMsrNombre
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
                format aux as "Importe: ",gUltMsrMontoRecarga
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
                format aux as "Medio de pago: ",gMedioAnulacion
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
                format aux as "CHK POS: ",gUltMsrCheque
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
               // format aux as "Fecha: ",gFechaHoy," ",@hour," ",@minute
                //DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )
                format aux as "Cajero: ",@TREMP_FNAME," ",@TREMP_LNAME
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, aux )

                IF ( dll_status <> 0 )
                    ErrorMessage dll_status_msg
                ENDIF
            ENDIF

            DLLCall_CDECL dll_handle, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )

            IF ( dll_status <> 0 )
                    ErrorMessage dll_status_msg
            ENDIF
        ENDFOR
        Prompt "idle"
EndSub
//*************************** MSR *****************************
// Impresion de contrato
// ****************************************************************
Sub imprimirContrato(VAR reimprimir:N1)
    //call getModeloFiscal
    IF (gFiscal=1)
        call imprimirContratoTermico(reimprimir)
    ELSE
        call imprimirContratoTradicional(reimprimir)
    ENDIF
ENDSUB
//*************************** MSR *****************************
// Impresion de contrato
// ****************************************************************
Sub imprimirContratoTradicional(VAR reimprimir:N1)
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50
	Prompt "Imprimiendo Contrato......"
	
        dll_status=0
        FOR i=1 to 2 
            DLLCall_CDECL dll_handle, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )

            IF ( dll_status <> 0 )
                    ErrorMessage dll_status_msg
            ENDIF
            j=1    
            
            IF (reimprimir=1)
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
            ENDIF
      
            WHILE (j<=gSolicitudCantLineas and dll_status =0)
                aux=gSolicitudLineas[j]
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
            
             IF (reimprimir=1)
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
                DLLCall_CDECL dll_handle, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "***** DUPLICADO DE CONTRATO *****" )
            ENDIF

            DLLCall_CDECL dll_handle, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )

            IF ( dll_status <> 0 )
                    ErrorMessage dll_status_msg
            ENDIF
        ENDFOR
        Prompt "idle"
EndSub
//*************************** MSR *****************************
// Impresion de contrato
// ****************************************************************
Sub imprimirContratoTermico(VAR reimprimir:N1)
	
	Var j :N3 = 0
	Var i :N1
        Var aux : A50
	Prompt "Imprimiendo Contrato......"
	
        VAR k:N1=0
        Var lineaaux:A50=""
        VAR ConfigFile       : A128       // File Name
        VAR FileHandle       : N5  = 0   // File handle
        VAR auxwrite : N4

        FORMAT ConfigFile AS g_path, "DNFH.txt"
        FOPEN FileHandle, ConfigFile, WRITE
           
        IF FileHandle <> 0

            FOR i=1 to 2 
                IF (i=2)
                    call grabarLinea(FileHandle,chr(&1C))
                ENDIF
                j=1    

                IF (reimprimir=1)
                    FOR K=1 to 4
                        call grabarLinea(FileHandle,"***** DUPLICADO DE CONTRATO *****")
                    ENDFOR
                ENDIF

                WHILE (j<=gSolicitudCantLineas)
                    aux=gSolicitudLineas[j]
                    IF (aux="")
                        aux=" "
                    ENDIF
                    call grabarLinea(FileHandle,aux)
                    j=j+1
                ENDWHILE

                 call grabarLinea(FileHandle," ")
                 call grabarLinea(FileHandle," ")
                 IF (reimprimir=1)
                   FOR K=1 to 4
                        call grabarLinea(FileHandle,"***** DUPLICADO DE CONTRATO *****")
                    ENDFOR
                ENDIF
            ENDFOR
            fclose filehandle
            //imprimo y sigo con consulta contrato
            LoadDBKybdMacro gMacroImpContrato 
        ENDIF
        Prompt "idle"
EndSub
//*************************** MSR *****************************
// Procesa menu opciones de beneficios
// ****************************************************************
Sub mostrarBeneficios
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A30
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A35
        var pricelevel          :N2

        pricelevel=@slvl
        gBeneficioSeleccionado=0

        Touchscreen gTouchNumeros

        format mensaje as "Version ",gVersion," Chk: ",@cknum
	//Touchscreen	gTouch
	IF (gBeneficiosCant>gMaxOpciones) 
            cuantos=gMaxOpciones
        ELSE 
            cuantos=gBeneficiosCant
        ENDIF
	Window cuantos+1,70, "Seleccione el Beneficio (0 para salir)"	
		FOR jj=1 to cuantos
                    
                    IF (len(gBeneficiosLista[jj])<30) 
                        aux=gBeneficiosLista[jj]
                        WHILE (len(aux)<30)
                            format aux as aux," "
                        ENDWHILE
                    ELSE
                        aux=mid(gBeneficiosLista[jj],1,30)
                    ENDIF
                    IF ((jj+gMaxOpciones)<=gBeneficiosCant)
                        format texto as jj,"-",aux,"  ",jj+gMaxOpciones,"-",gBeneficiosLista[jj+gMaxOpciones]
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
                IF opcion>0 and opcion<=gBeneficiosCant 
                    gBeneficioSeleccionado=gBeneficiosCodigos[opcion]
                    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","SELECCIONAR_BENEFICIO","|",gMsrTarjeta,"|",gBeneficioSeleccionado
                    call EnviaTransaccion
                    call RecibeTransaccionBeneficiosOpcion
                    call procesarRespuesta
                ELSE
                    format texto as "Seleccion Invalida"
                    IF (opcion<>0) 
                        call MostrarMensaje(texto)
                    ENDIF
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
                ENDIF

	ElseIf kKeyPressed = @KEY_CANCEL
		Format opcion		As ""
                LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	EndIf
       Touchscreen gTouch
EndSub
//*************************** MSR *****************************
// Procesa menu opciones de beneficios redimdos
// ****************************************************************
Sub mostrarBeneficiosRedimidos
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A30
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A35

        gBeneficioSeleccionado=0

        Touchscreen gTouchNumeros

        format mensaje as "Version ",gVersion," Chk: ",@cknum
	//Touchscreen	gTouch
	IF (gBeneficiosCant>gMaxOpciones) 
            cuantos=gMaxOpciones
        ELSE 
            cuantos=gBeneficiosCant
        ENDIF
	Window cuantos+1,70, "Beneficios redimidos"	
		FOR jj=1 to cuantos
                    format texto as mid(gBeneficiosListaRedimidos[jj],1,25),"-",mid(gBeneficiosTiendaRedimidos[jj],1,20), "-", gBeneficiosTiempoRedimidos[jj]
                    Display jj,1,texto
                endfor
                Display cuantos+1,1,"Ok: "
		DisplayInput cuantos+1, 11, opcion{2},""
	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	
       Touchscreen gTouch
EndSub
//*************************** MSR *****************************
// Procesa menu opciones multiples
// ****************************************************************
Sub mostrarOpciones
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A30
        var jj          	:N2
        var texto               : A80
	Var cuantos             :N1
        var aux                 :A35
        var pricelevel          :N2

        pricelevel=@slvl

        Touchscreen gTouchNumeros

        format mensaje as "Version ",gVersion," Chk: ",@cknum
	//Touchscreen	gTouch
	IF (gMultCant>gMaxOpciones) 
            cuantos=gMaxOpciones
        ELSE 
            cuantos=gMultCant
        ENDIF

	Window cuantos+1,70, "Seleccione la opcion (0 para salir)"
		FOR jj=1 to cuantos                   
                    IF (len(gMultDesc[jj])<30) 
                        aux=gMultDesc[jj]
                        WHILE (len(aux)<30)
                            format aux as aux," "
                        ENDWHILE
                    ELSE
                        aux=mid(gMultDesc[jj],1,30)
                    ENDIF
                    IF ((jj+gMaxOpciones)<=gBeneficiosCant)
                        format texto as jj,"-",aux,"  ",jj+gMaxOpciones,"-",gMultDesc[jj+gMaxOpciones]
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
                IF opcion>0 and opcion<=gBeneficiosCant 
                    call aplicarOpcion(gMultTipo[opcion],gMultCodigo[opcion], gMultNivel[opcion])
                ELSE
                    call deseleccionarBeneficio
                    format texto as "Seleccion Invalida"
                    IF (opcion<>0)
                        call MostrarMensaje(texto)
                    ENDIF
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
                ENDIF

	ElseIf kKeyPressed = @KEY_CANCEL
                call deseleccionarBeneficio
		Format opcion		As ""
                LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
        ElseIf kKeyPressed = @KEY_CLEAR
            call deseleccionarBeneficio 
	EndIf
       
       Touchscreen gTouch
EndSub
//************************* MSR  *****************************
//Calcula la cantidad de items padre en el ticket
//****************************************************************
Sub validaItemsPadre(Ref padre, Ref nivel)
    VAR status:A12=""
    VAR i:N3=0
    padre=0
    gMsrPrimerItem=0
    For i = 1 to @NUMDTLT 
       status=mid(@Dtl_status[i],5,1)
        IF ((@DTL_TYPE[i]="M" or @DTL_TYPE[i]="D" ) and @DTL_IS_VOID[i] = 0 and (status="4" or status="C") and @dtl_is_combo_main[i]=0)
            gMsrPrimerItem=i
            padre=padre+1
            nivel=@DTL_PLVL[i]
	ENDIF
    EndFor 
EndSub
//************************* MSR  *****************************
//realiza un undo de aplicar un beneficio
//****************************************************************
Sub deseleccionarBeneficio
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PEDIDO_DE_DESELECCION_DE_BENEFICIO","|",gMsrTarjeta,"|",gBeneficioSeleccionado
    call EnviaTransaccion
    call RecibeTransaccionSimple
    gMsrHayBeneficio=gMsrHayBeneficio-1
EndSub
//************************* MSR  *****************************
//Dispatcher de aplicar los codigos del beneficio ANTIGUO
//****************************************************************
Sub aplicarBeneficioOLD
    VAR pricelevel :N1
    VAR descnombre:A25
    VAR aux:A100
    VAR itemspadre: N3=0
    var itemnivel: N1=0
    VAR ok:N1=1
    
    IF (gContadorProd>0)
        pricelevel=@slvl
        gMsrHayBeneficio=gMSrHayBeneficio+1     
        IF (gCodigosTipo[1]=2)
            IF (gMsrHayBeneficioDesc=0)
                call validaItemsPadre(itemspadre,itemnivel)
                IF (itemspadre=1 and gBeneficioTicketCompleto="N")
                    gMsrHayBeneficioDesc=1
                    IF (gCodigosNivel[1]<>0 and itemnivel>gCodigosNivel[1])
                        ok=0
                        gMsrHayBeneficioDesc=0
                        call deseleccionarBeneficio
                        call mostrarMensaje("No puede aplicar el beneficio en este tamanio de bebida")
                    ENDIF
                ELSEIF (itemspadre>=1 and gBeneficioTicketCompleto="S")
                    gMsrHayBeneficioDesc=1
                ELSE //hay 0 items o mas de 1
                    ok=0
                    //gMsrHayBeneficio=0
                    call deseleccionarBeneficio
                    IF (itemspadre=0)
                        call mostrarMensaje("No puede aplicar un beneficio del tipo descuento sin productos")
                    ELSE
                        call mostrarMensaje("No puede aplicar un beneficio del tipo descuento con mas de 1 item marcado")
                    ENDIF
                ENDIF
             ELSE
                call deseleccionarBeneficio
                ok=0
                call mostrarMensaje("No puede aplicar 2 beneficios del tipo descuento en el mismo ticket")
             ENDIF
        ENDIF
        IF (ok=1)
            FOR i = 1 to gContadorProd 
                call aplicarOpcion(gCodigosTipo[i],gCodigos[i], gCodigosNivel[i],gBeneficioTicketCompleto)
            ENDFOR
        ENDIF
    ENDIF
endsub

//************************* MSR  *****************************
//Dispatcher de aplicar los codigos del beneficio NUEVO
//****************************************************************
Sub aplicarBeneficio
    VAR pricelevel	: N1
    VAR descnombre	: A25
    VAR aux			: A100
    VAR itemspadre	: N3=0
    var itemnivel	: N1=0
    VAR ok			: N1=1
    var i			: N3
	
    IF (gContadorProd>0)
        pricelevel=@slvl
        gMsrHayBeneficio=gMSrHayBeneficio+1     
        IF (gCodigosTipo[1]=2)
			call validaItemsPadre(itemspadre,itemnivel) //Removemos este control del bloque If
			//IF (gMsrHayBeneficioDesc=0)
            IF (gMsrHayBeneficioDesc<itemspadre)
                //Aqui iba llamado a funcion validaItemsPadre
				//IF (itemspadre=1 and gBeneficioTicketCompleto="N")
                IF (itemspadre>0 and gBeneficioTicketCompleto="N")
                    //gMsrHayBeneficioDesc= 1
					gMsrHayBeneficioDesc= gMsrHayBeneficioDesc + 1
                    IF (gCodigosNivel[1]<>0 and itemnivel>gCodigosNivel[1])
                        ok=0
                        //gMsrHayBeneficioDesc=0
						gMsrHayBeneficioDesc= gMsrHayBeneficioDesc-1
                        call deseleccionarBeneficio
                        call mostrarMensaje("No puede aplicar el beneficio en este tamanio de bebida")
                    ENDIF
                ELSEIF (itemspadre>=1 and gBeneficioTicketCompleto="S")
                    //gMsrHayBeneficioDesc=1
					gMsrHayBeneficioDesc= gMsrHayBeneficioDesc + 1
                ELSE //hay 0 items o mas de 1
                    ok=0
                    //gMsrHayBeneficio=0
                    call deseleccionarBeneficio
                    IF (itemspadre=0)
                        call mostrarMensaje("No puede aplicar un beneficio del tipo descuento sin productos")
                    ELSE
                        call mostrarMensaje("No puede aplicar un beneficio del tipo descuento con mas de 1 item marcado")
                    ENDIF
                ENDIF
             ELSE
                call deseleccionarBeneficio
                ok=0
				call mostrarMensaje("Faltan items para aplicar beneficio")
                //call mostrarMensaje("No puede aplicar 2 beneficios del tipo descuento en el mismo ticket")
             ENDIF
        ENDIF
        IF (ok=1)
            FOR i = 1 to gContadorProd 
                call aplicarOpcion(gCodigosTipo[i],gCodigos[i], gCodigosNivel[i],gBeneficioTicketCompleto)
            ENDFOR
        ENDIF
    ENDIF
endsub
//************************* MSR  *****************************
//aplica un codigo de producto-descuento-macro-etc
//****************************************************************
Sub aplicarOpcion(Ref tipo,Ref codigo, Ref nivel, Ref ticketcompleto)
    VAR pricelevel :N1
    VAR descnombre:A25
    VAR aux:A100

    pricelevel=@slvl
    
    IF (Tipo=1) //Aplica producto
        IF (Nivel>0)
          LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+Nivel) //cambia el menulevel antes 458756
        ENDIF
        LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, codigo) //selecciona un producto
        //LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458760+pricelevel) //vuelve el menulevel
    ELSEIF (Tipo=2) //Aplica descuento
        //format descnombre as gMsrTarjeta,"-",@DTL_OBJECT[gMsrPrimerItem]
        format descnombre as @DTL_OBJECT[gMsrPrimerItem]
        IF (ticketcompleto="N")
            LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gMsrItemRef),MakeKeys(descnombre), @KEY_ENTER
        ENDIF
        LoadKybdMacro Key(KEY_TYPE_DISCOUNT,  codigo),  @KEY_ENTER
        
    ELSEIF (tipo=4) //Aplica macro
        LoadDBKybdMacro codigo
    ELSEIF (tipo=3) //multiples opciones
        format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","GET_OPCIONES","|",gMsrTarjeta,"|",codigo
        call EnviaTransaccion
        call RecibeTransaccionMultOpciones
        call procesarRespuesta
    ELSE
        format aux as "aplicarBeneficio:Tipo Invalido:",codigo 
        call mostrarMensaje (aux) 
    ENDIF
endsub
//************************* MSR  *****************************
//Seleccionar Recarga
//****************************************************************
SUB CancelarRecarga(VAR esrecibo:N1)
    VAR cantrecargas:N2=0
    VAR montos[10]:A8
    VAR fechas[10]:A30
    var medios[10]:A20
    var tenders[10]:N4
    var ids[10]:N22
    VAR aux:A100

    IF (gMsrOk=1)
        format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","GET_RECARGAS","|",gMsrTarjeta
        call EnviaTransaccion
        IF @RxMsg = "_timeout" //Llega la Respuesta
            InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
        ELSE
           Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gMsrSaldo,cantrecargas,ids[]:montos[]:fechas[]:medios[]:tenders[]
           IF (gCodigoRespuesta<>"LISTADO_DE_RECARGAS")
                format aux as gCodigoRespuesta," : ",gDescRespuesta
                call mostrarmensaje(aux)
           ELSE
            IF (cantrecargas>0)
                IF (esrecibo=1)
                    gUltMsrMontoRecarga=montos[1]
                    gUltMsrNombre=gMsrNombre
                    gUltMsrDni=gMsrDni
                    gUltMsrTarjeta=gMsrTarjeta
                    gUltMsrStars=gMsrStars
                ELSE
                    call mostrarRecargas(cantrecargas,ids[],montos[],fechas[],medios[],tenders[])
                ENDIF
            ELSE
                IF (esrecibo=1)
                    InfoMessage "RECIBOX","NO HAY RECIBOSX PARA IMPRIMIR"
                ELSE
                    InfoMessage "RECARGAS","NO HAY RECARGAS PARA ANULAR"
                ENDIF
            ENDIF
           ENDIF
        ENDIF
        
    ELSE
      call mostrarmensaje("PRIMERO DEBE IDENTIFICARSE")
    ENDIF
ENDSUB
//*************************** MSR *****************************
// Procesa menu recargas a cancelar
// ****************************************************************
Sub mostrarRecargas(Ref cuantos, Ref ids[],Ref montos[], Ref fechas[], Ref medios[], Ref tenders[])
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion              : N2
        Var mensaje             : A30
        var jj          	:N2
        var texto               : A80
        var aux                 :A50
        var recargasel          :N2
        var tender              :N3
        var answer              :N1=0
        var isltarj             :N2=gSecuenciaIslTarjetas //16 gpay
        var eshasar             :N2=0
        Touchscreen gTouchNumeros

        format mensaje as "Version ",gVersion," Chk: ",@cknum
	
	Window cuantos+1,70, "Seleccione la recarga (0 para salir)"	
		FOR jj=1 to cuantos
                    aux=""
                    IF (medios[jj]="TARJETA" and (tenders[jj]<gTenderTarjetaOnline or tenders[jj]=202))
                        aux=" POSNET"
                    ELSEIF (tenders[jj]=gTenderMPago)
                        aux=" "
                    ELSEIF (tenders[jj]>=gTenderTarjetaOnline)
                        aux=" ONLINE"
                    ENDIF
                    
                    format texto as jj,"-",fechas[jj]," - ",montos[jj]," - ",medios[jj],aux
                    Display jj,1,texto
                endfor
                Display cuantos+1,1,"Seleccion: "
		DisplayInput cuantos+1, 11, opcion{2},""
	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	If kKeyPressed = @KEY_ENTER
                IF opcion>0 and opcion<=cuantos 
                    IF (gMsrSaldo<montos[opcion])
                        call mostrarMensaje("ERROR: NO POSEE SALDO SUFICIENTE PARA ANULAR LA RECARGA")
                    ELSE
                        gMsrRecargaAnulacion=1
                        IF (medios[opcion]<>"EFECTIVO")
                            //tender=mid(medios[opcion],6,len(medios[opcion]-5))+0
                            gMedioCod=tenders[opcion]
                            tender=tenders[opcion]
                            gMsrRecargaAnulacion=2
                        ELSE
                            tender=0
                        ENDIF
                        IF (medios[opcion]="EFECTIVO" or tender<gTenderTarjetaOnline or tender=202)
                            IF (medios[opcion]="EFECTIVO")
                                gMedioAnulacion="EFECTIVO"
                                format aux as "DEVOLUCION EFECTIVO: $ ",montos[opcion]
                            ELSE
                                gMedioAnulacion="POSNET"
                                format aux as "DEVOLUCION POSNET: $ ",montos[opcion]
                            ENDIF
                            call consultarsino(answer, aux )
                            IF (answer=1)
                                Format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","NOTA_CREDITO_RECARGA","|",gMsrTarjeta,"|",ids[opcion]
                                gMsrMontoAnulacion=montos[opcion]+0
                                gMsrIdAnulacion=ids[opcion]
                                call EnviaTransaccion
                                call RecibeTransaccion
                                IF @RxMsg <> "_timeout" 
                                    call procesarRespuesta
                                    IF (gMsrRecargaOk=1)

                                        gUltMsrMontoRecarga=gMsrMontoAnulacion
                                        gUltMsrNombre=gMsrNombre
                                        gUltMsrDni=gMsrDNI
                                        gUltMsrTarjeta=gMsrTarjeta
                                        gUltMsrStars=gMsrStars
                                        
                                        IF (gFiscal=0)
                                            LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
                                            Call cargarDllImpresora
                                            call imprimirComprobanteDevolucion
                                            Call descargarDllImpresora
                                        ELSE
                                            //imprimo recibo x y comprobante
                                            call ImprimirReciboX
                                            call imprimirComprobanteDevolucionTermica
                                            LoadDBKybdMacro gMacroImpReciboXyDocTermica
                                        ENDIF
                                        
                                    ELSE
                                        gMsrRecargaAnulacion=0
                                        call mostrarmensaje ("ERROR EN CANCELACION DE RECARGA, VALIDE EL SALDO")
                                    ENDIF
                                    IF (gMsrRecargaOk=1)
                                        InfoMessage "DEVOLUCION REALIZADA"
                                        IF (gMedioAnulacion="EFECTIVO")
                                             //abro el cajon con efectivo
                                             LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoItemDevol) //item 0,01
                                             LoadKybdMacro Key (9, 2) //aplico tender efectivo
                                        ENDIF
                                    ENDIF
                                ENDIF
                            ENDIF
                            //gMsrRecargaAnulacion=0
                         ELSE
                            //tengo que ver el tender
                           // tender=mid(medios[opcion],6,len(medios[opcion]-5))+0
                           tender=tenders[opcion]
                            gMedioCod=tender
                            IF (tender=gTenderMPago) //Mpago
                                gMedioAnulacion="MERCADO PAGO"
                                format aux as "MERCADO PAGO: $ ",montos[opcion]
                                call consultarsino(answer, aux )
                                IF (answer=1)
                                    //INQ + id pms (16 gpay, rewards 21, 22 pagoselectronicos)
                                    gMsrMontoAnulacion=montos[opcion]+0
                                    gMsrIdAnulacion=ids[opcion]
                                    gUltMsrMontoRecarga=gMsrMontoAnulacion
                                    gUltMsrNombre=gMsrNombre
                                    gUltMsrDni=gMsrDNI
                                    gUltMsrTarjeta=gMsrTarjeta
                                    gUltMsrStars=gMsrStars
                                    isltarj=gSecuenciaIslMPago  //pms3
                                    LoadKybdMacro Key(24, 16384 * 11 + isltarj), MakeKeys( montos[opcion] ), @Key_enter
                                ELSE
                                    gMsrRecargaAnulacion=0
                                ENDIF
                            ELSEIF (tender>=gTenderTarjetaOnline) //es online
                                gMedioAnulacion="TARJETA ONLINE"
                                format aux as "DEVOLUCION ONLINE: $ ",montos[opcion]
                                call consultarsino(answer, aux )
                                IF (answer=1)
                                    //INQ + id pms (16 gpay, rewards 21)
                                    gMsrMontoAnulacion=montos[opcion]+0
                                    gMsrIdAnulacion=ids[opcion]
                                    gUltMsrMontoRecarga=gMsrMontoAnulacion
                                    gUltMsrNombre=gMsrNombre
                                    gUltMsrDni=gMsrDNI
                                    gUltMsrTarjeta=gMsrTarjeta
                                    gUltMsrStars=gMsrStars
                                    call esHasarOnline(eshasar)
                                    IF (eshasar=1)
                                        isltarj=gSecuenciaIslTarjetasHasar  //pms10 hasar
                                    ENDIF
                                    LoadKybdMacro Key(24, 16384 * 11 + isltarj), MakeKeys( montos[opcion] ), @Key_enter
                                ELSE
                                    gMsrRecargaAnulacion=0
                                ENDIF
                             ENDIF
                         ENDIF
                         //gMsrRecargaAnulacion=0
                     ENDIF
                ELSE
                    format texto as "Seleccion Invalida"
                    IF (opcion<>0) 
                        call MostrarMensaje(texto)
                    ENDIF
                    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
                ENDIF

	ElseIf kKeyPressed = @KEY_CANCEL
		Format opcion		As ""
                LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	EndIf
       Touchscreen gTouch
EndSub
//************************* MSR  *****************************
//Imprimo recibo X
//****************************************************************
SUB ImprimirReciboX
    Var param :A2048
    //gUltMsrNombre=gMsrNombre
    //gUltMsrDni=gMsrDNI
    //gUltMsrTarjeta=gMsrTarjeta
    //gUltMsrStars=gMsrStars

    IF (gMsrRecargaAnulacion>=1)
        gMsrMontoRecarga=gMsrMontoAnulacion
    ENDIF
    call getModeloFiscal
    call SetMinimalReceiptX(param,gMsrMontoRecarga,gUltMsrNombre,gUltMsrDNI,1,gUltMsrTarjeta,gUltMsrStars,0)
    IF (gFiscal=1)
        call generarReciboXTermico(param)
        IF (gPausaRecarga=1) 
            LoadKyBdMacro Key (1,327684),MakeKeys (gChequeAnt),@KEY_ENTER
        ENDIF
    ELSE
        Call PrintXReceipt(param)
    ENDIF
    gMsrRecargaAnulacion=0
   
    

ENDSUB
//************************* MSR  *****************************
//Imprimo recibo X de compras online
//****************************************************************
SUB ImprimirRecibosOnline
    
    Var param :A2048
    
    Call setWorkstationType
    Call setFilePaths
    
    //infomessage "Recibo X Online", "SE IMPRIMIRAN RECIBOS X DE RECARGAS ONLINE"
    call getModeloFiscal
    call SetMinimalReceiptX(param,gMontoReciboXOnline,gUltMsrNombre,gUltMsrDNI,1,gUltMsrTarjeta,gUltMsrStars,1)
    IF (gFiscal=1)
        call generarReciboXTermico(param)
    ELSE
        Call PrintXReceipt(param)
    ENDIF

    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONSUMIR_MONTO_RECIBOS_X","|",gMsrTarjeta,"|",gMontoReciboXOnline
    gMontoReciboXOnline=0
    call EnviaTransaccion
    call RecibeTransaccion
ENDSUB
//************************* MSR  *****************************
//Imprimo Ultimo recibo X
//****************************************************************
SUB ImprimirUltimoReciboX
    Var param :A2048
    Var mostrar:N1=1
    IF (gUltMsrMontoRecarga=0)
        //busco en backoffice ultima carga
        IF (gMsrOk=1)
            //1=es recibox
            call CancelarRecarga(1)
        ELSE
            call MostrarMensaje("PRIMERO DEBE IDENTIFICARSE")
            mostrar=0
        ENDIF
    ENDIF
    IF (gUltMsrMontoRecarga>0)
        call getModeloFiscal
        call SetMinimalReceiptX(param,gUltMsrMontoRecarga,gUltMsrNombre,gUltMsrDni,0,gUltMsrTarjeta,gUltMsrStars,0)
        
        IF (gFiscal=1)
            call generarReciboXTermico(param)
        ELSE
            Call PrintXReceipt(param)
        ENDIF  
    ELSE
        IF (mostrar=1)
            infomessage "Ultimo Recibo X", "NO EXISTEN DATOS DE RECIBO X"
        ENDIF
    ENDIF
ENDSUB
//************************ GENERALES     ************************
//Muestra mensaje en pantalla
//*****************************************************************
Sub mostrarMensaje(VAR mensaje:A200)
    var aux: A100=""
    format aux as "Mensaje (Version: ",gVersion," Chk: ",@cknum,")"
    IF (len(mensaje)>80)
        mensaje=mid(mensaje,1,80)
    ENDIF
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

    Window 2,65, "Presione S/N"
		
      Display 1,1,mensaje
      DisplayInput 1, len(mensaje)+2, opcion{1},""
    WindowEdit	
    WindowClose	
    respuesta=0
    if (opcion="s" or opcion="S")
        respuesta=1
    endif  
endsub
//***********************************************
sub consultarsino( ref answer, var prompt_s:A38 )
    var keypress : key
    var data : A20

    clearislts

    SetIslTsKeyx  1,  1, 4, 30, 7, @Key_HOME, 0, "L", 3, prompt_s
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
// ********************* GENERALES ***********
// Funcion que graba el pms2
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
//Solicita si hay nuevo pms2
//****************************************************************
sub solicitarPms
    gPmsCantLineas1=0
    gPmsCantLineas2=0
    ClearArray gPmsLineas1
    ClearArray gPmsLineas2

    format gDatos as "PMS-1|",@WSID,"|",gVersion
    call EnviaTransaccion
    if @RxMsg = "_timeout" //Llega la Respuesta
	else
           if (@RxMsg<>"NOPMS")
                Split @RxMsg, chr(33), gPmsCantLineas1,gPmsLineas1[]  
                if (gPmsCantLineas1=800)
                    
                    format gDatos as "PMS-2|",@WSID,"|",gVersion
                    call EnviaTransaccion
                     if @RxMsg = "_timeout" //Llega la Respuesta
                     else
                        if (@RxMsg<>"NOPMS")
                            Split @RxMsg, chr(33), gPmsCantLineas2,gPmsLineas2[] 
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
Sub SetFilePaths		
	// general paths
	If gbliWSType = PCWS_TYPE
		// This is a Win32 client
		Format PATH_TO_PRT_DRIVER 				As "..\bin\TWSEpsonArg.dll"	
                Format PATH_TO_QR_DRIVER As "..\bin\TWS.QRInputW32.dll"
                Format g_path as "..\Etc\"   
		// This is a WinCE 5.0/6.0 client		
	ElseIf gbliWSType = WS5_TYPE		
		Format PATH_TO_PRT_DRIVER 				As "CF\micros\bin\TWSEpsonArgCE50.dll"
                Format PATH_TO_QR_DRIVER As "CF\micros\bin\TWS.QRInputWCE.dll"
                Format g_path  as "\CF\micros\etc\"    
        Else
		// This is a WS4 client	WinCE 4.2	
		Format PATH_TO_PRT_DRIVER 				As "CF\micros\bin\TWSEpsonArgCE40.dll"		
                Format PATH_TO_QR_DRIVER As "CF\micros\bin\TWS.QRInputWCE.dll"
                Format g_path  as "\CF\micros\etc\" 
        EndIf		
EndSub
//******************************************************************
// Procedure: Valido si el driver dll existe
//*****************************************************************
Sub validarDllReciboX
    var fn : N5
    
    Call setWorkstationType
    call SetFilePaths
    fopen fn, PATH_TO_PRT_DRIVER, read
    IF (fn<>0)
        fclose fn
    ELSE
        ErrorMessage "ERROR: No se puede acceder a dll Recibos X"
    ENDIF
EndSub


//******************************************************************
// Procedure: 	ReadInputQR()
//******************************************************************
Sub ReadInputQR(Ref buffer_, Var bufferSize_ :N9, Ref res_)
			
	buffer = ""
	res = 0
	
        DLLCall_CDecl gblQRDrv, InputDialog("Scanee el DNI",Ref buffer_, bufferSize_, Ref res_)

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
	Call ReadInputQR(buffer, 1024, res)

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

	If (gblQRDrv = 0)
                call SetFilePaths
		DLLLoad gblQRDrv, PATH_TO_QR_DRIVER
        EndIf

	If gblQRDrv = 0
		InfoMessage "DNI por QR","ERROR DRIVER: No se puede cargar driver QR" 
                gQRDni=0
        ELSE
            gQRDni=1
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
//******************************************************************
// Procedure: LoadPRTDrv() para recibos X
//******************************************************************
Sub LoadPRTDrv
	Var retMessage :A512
        Var i:N1=0
        Var dllok:N1=0

	If (gblPRTDrv = 0)
		DLLLoad gblPRTDrv, PATH_TO_PRT_DRIVER
        EndIf

	If gblPRTDrv = 0
                LoadDBKybdMacro gMacroCargaFacturador
		InfoMessage "Recibo x","ERROR DRIVER: No se pueden imprimir recibos X"
                InfoMessage "Recibo x",PATH_TO_PRT_DRIVER
               
		Return 
        EndIf
        
        WHILE (i<2 and dllok=0)
            DLLCall_CDecl gblPRTDrv, PRARG_InitializeDriver("COM1", 9600, 8, 0,0,Ref retMessage)
            i=i+1
            If(Trim(retMessage) = "")
                dllok=1
            ELSE
                msleep 2000
            ENDIF
	ENDWHILE
	
	If(dllok=0)
                LoadDBKybdMacro gMacroCargaFacturador
		InfoMessage "ERROR Recibo X, LOAD DRIVER",Mid(retMessage, 1, 79)
                LoadDBKybdMacro gMacroCargaFacturador
	EndIf		
EndSub
//******************************************************************
// Procedure: procesoReciboX, antes en inq 13
//******************************************************************
SUB procesoReciboX
    Call setWorkstationType
    Call setFilePaths
    IF (gMontoReciboXOnline=0)
        call imprimirReciboX
    ELSE
        call imprimirRecibosOnline
    ENDIF
    IF (gProcesoRecargaNO=1) //tengo que imprimir comprobante de falla
        call getModeloFiscal
        IF (gFiscal=1)
            Call imprimirComprobanteFallaRecargaTermica
        ELSE
            Call cargarDllImpresora
            Call imprimirComprobanteFallaRecarga
            Call descargarDllImpresora
        ENDIF
    ENDIF
ENDSUB
//******************************************************************
// Procedure: PrintXReceipt()
//******************************************************************
Sub PrintXReceipt(Ref param_)

	Var retMessage 		:A512="-"
	Var xReceiptParams	:A4096 = ""
        VAR i:N1=0
        VAR aux:A100    
	
        WHILE (i<3 and retMessage<>"")
            msleep 1000
            Call LoadPRTDrv
            If(gblPRTDrv <> 0)
                   DLLCall_CDecl gblPRTDrv, PRARG_PrintXReceipt(param_, "|", Ref retMessage)
                   Call FreePRTDrv		

                    If(Trim(retMessage) <> "")
                            LoadDBKybdMacro gMacroCargaFacturador
                            format aux as "Error Recibo X, PRINT, Intento: ",i
                            InfoMessage aux,Mid(retMessage, 1, 79)
                            LoadDBKybdMacro gMacroCargaFacturador
                    EndIf
            EndIf
            i=i+1
         ENDWHILE

EndSub
//******************************************************************
// Procedure: FreePRTDrv()
//******************************************************************
Sub FreePRTDrv
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
	Call LoadPRTDrv	
	If(gblPRTDrv <> 0)
		//DLLCall_CDecl gblPRTDrv, PRARG_SyncDateTime(print, Ref retMessage)
                DLLCall_CDecl gblPRTDrv, PRARG_SetDateTime(@DAY, @MONTH, @YEAR+2000, @HOUR, @MINUTE, @SECOND,print, Ref retMessage)
		Call FreePRTDrv		
		If(Trim(retMessage) <> "")
			//ErrorMessage Mid(retMessage, 1, 79)
		EndIf		
	EndIf
EndSub
//---------------- Graba una linea a archivo
SUB grabarLinea(Var filehandle:N5,VAR texto:A500)
    VAR auxwrite:N4

     FWriteBfr FileHandle, texto,len(texto), auxwrite 
     FWriteBfr FileHandle, chr(13),1, auxwrite 
     FWriteBfr FileHandle, chr(10),1, auxwrite 
ENDSUB
//******************************************************************
// Procedure: generarArchivoReciboX()
//******************************************************************
Sub generarReciboXTermico(VAR recibox:A500)      
        VAR ConfigFile       : A128       // File Name
        VAR FileHandle       : N5  = 0   // File handle


        Prompt "Generando archivo x......"
        FORMAT ConfigFile AS g_path, "XRECEIPT"
        FOPEN FileHandle, ConfigFile, WRITE
        IF FileHandle <> 0
            call grabarLinea(FileHandle,recibox)
            FCLOSE FileHandle
            IF (gMsrRecargaAnulacion=0)
                LoadDBKybdMacro gMacroImpReciboXTermica
            ENDIF
        ENDIF									
EndSub
//******************************************************************
// Procedure: SetMinimalReceiptX()
//******************************************************************
Sub SetMinimalReceiptX(Ref paramStr_,Ref Monto,Ref Nombre, Ref Dni,Var impsaldo:N1,Ref Tarjeta, Ref Stars, Var Online:N1)
	
	Var EMPTY 	:A1 = ""	
	Var TRUE	:N1 = 1
        Var FALSE	:N1 = 0
        Var aux :A50=""
        Var saldo:A50=""
        VAR mensaje:A50=""
        VAR mensaje2:A50="STARBUCKS REWARDS."
        VAR mensaje3:A50="RECUERDE QUE SU FACTURA SERA EMITIDA"
        VAR mensaje4:A50="AL MOMENTO DE REALIZAR LA COMPRA."
        Var auxstars:A20=""
        
        format mensaje as "CARGA DE SALDO:",Tarjeta
        format aux as Monto," pesos"
        IF (gMsrRecargaAnulacion>=1)
            IF (gFiscal<>1)
                format aux as "-",aux
            ENDIF
            format mensaje as "ANULACION DE RECARGA:",Tarjeta
        ENDIF
        IF (Online=1)
            mensaje="Recibo oficial correspondiente a sus"
            mensaje2="ultimas recargas online.Podra ver el"
            mensaje3="detalle en STARBUCKSREWARDS.COM.AR o APP"
            mensaje4="SE EMITIRA FACTURA AL REALIZAR LA COMPRA"
        ENDIF

        IF (Nombre="")
            Nombre="GIFT CARD"
            Dni="-"
        ELSE
            format auxstars as "Stars: ",Stars
        ENDIF
        IF (Dni="")
            Dni="0"
        ENDIF
        IF (impsaldo=1)
            format saldo as "SALDO: ",gMsrSaldo," pesos"
        ENDIF
	Format paramStr_ As TRUE,  							"|", \ 	//01 - Cut paper
        FALSE, 							"|", \ 	//02 - Print Customer Name dotted line 
        FALSE, 							"|", \ 	//03 - Print Customer Sign dotted line
        FALSE, 							"|", \ 	//04 - Print Header & Trailer
        FALSE, 							"|", \ 	//05 - Print $ Symbol
        FALSE, 							"|", \ 	//06 - Print Store Lines
        EMPTY, 							"|", \ 	//07 - Internal Document Number
        Nombre, 		"|", \ 	//08 - Customer Name Line #1
        EMPTY, 							"|", \ 	//09 - Customer Name line #2
        EMPTY, 							"|", \ 	//10 - Customer Address line #2
        EMPTY, 							"|", \ 	//11 - Customer Address line #2
        CUSTOMER_DOC_TYPE_UNDEFINED, 	"|", \ 	//12 - Customer Document Type
        Dni,    	"|", \ 	//13 - Customer Document Number
        TAX_CONDITION_UNDEFINED,       	"|", \ 	//14 - Customer Tax Condition
        EMPTY,                         	"|", \ 	//15 - Reference Document Number
        aux,       	"|", \ 	//16 - Amount in Words line #1
        saldo,                         	"|", \ 	//17 - Amount in Words line #2
        auxstars,                         	"|", \ 	//18 - Amount in Words line #3
        mensaje, 	"|", \ 	//19 - Description Line #1
        mensaje2,                         	"|", \ 	//20 - Description Line #2
        mensaje3,	"|", \ 	//21 - Description Line #3
        mensaje4,     "|", \ 	//22 - Description Line #4
        Monto,                      	"|", \ 	//23 - Receipt Amount
        EMPTY,                         	"|", \ 	//24 - Free Text Extra Line #1
        EMPTY,                         	"|", \ 	//25 - Free Text Extra Line #2
        EMPTY,                         	"|", \ 	//26 - Free Text Extra Line #3
        "0",                           	"|", \ 	//27 - Trailer Replacement Line Number #1
        "0",                           	"|", \ 	//28 - Trailer Replacement Line Number #2
        "0",                           	"|", \ 	//29 - Trailer Replacement Line Number #3
        EMPTY,                         	"|", \ 	//30 - Trailer Replacement Line Text #1
        EMPTY,                         	"|", \ 	//31 - Trailer Replacement Line Text #2
        EMPTY									//32 - Trailer Replacement Line Text #3
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
                        ErrorMessage "PMS2: DiaDeNegocio: Fecha vacia"
                    endif	
		Else 	
                    
                    ErrorMessage "PMS2: DiaDeNegocio: Error al obtener sql"
                    ErrorMessage error
		Endif	
                call ODBCbaja
	Else
            ErrorMessage "PMS2: DiaDeNegocio: Error al conectar BD"
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
// ********************* Hasar Online ***********
// Funcion que lee el tipo de sistema de tarjetas, 1=Hasar
// ************************************************
SUB esHasarOnline(Ref eshasar)
    VAR ConfigFile       : A32       // File Name
    VAR FileHandle       : N5  = 0   // File handle

    eshasar=0
    FORMAT ConfigFile AS g_path, "Hasar.cfg"

    FOPEN FileHandle, ConfigFile, READ
    
    IF FileHandle <> 0
        IF not feof( filehandle)
            FREAD FileHandle, eshasar           
            IF (eshasar<>1)
             eshasar=0
            ENDIF
        ENDIF
        FCLOSE FileHandle
    ENDIF

ENDSUB
//******************************************************************
// Cargar modelo fiscal
//******************************************************************
SUB GetModeloFiscal
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    gFiscal=1
    //FORMAT ArchConfig AS g_path, "FISCAL", ".cfg"

    //FOPEN Handle, ArchConfig, READ
    //IF Handle <> 0
    //   FREAD Handle, gFiscal
    //   FCLOSE Handle
    //ENDIF
ENDSUB 