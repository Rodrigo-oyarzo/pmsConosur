@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts

//Version 5.4 agrega descuentos de empleados multiple opciones

var gFrecuencia: N5 // = 2
var gCodigoIngresado: A20 = ""
var gCodigoGiftCard : A30 = ""
var gDatos: A1000=""
var gVersion: A14="5.4"
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
var gCodigoCVPais: N2=49  //Colombia: 57 - Argentina: 49
var gGiftCardSaldo : $7
//************************ CUSTOMER VOICE   ******************
Event init
    gOffRecibido=1
   // @idle_seconds=7200
    gTouch=@ALPHASCREEN
    gFrecuencia=200
    gEnTicket=0
    gContadorOff=0
    gOffCantCodIngresados=0
    ClearArray gOffCodIngresados
    gCaja="NAN"
    gVersionCampanas=0
    call darModeloCaja
    call recibeFrecuenciaCV
    //call recibeFrecuenciaOffline
    call solicitarCampanasOffline
    call solicitarPms
endevent

Event Begin_Check
    gTouch=@ALPHASCREEN
    gEnTicket=0
    call enviarCodigosOffline
Endevent

Event Idle_No_trans
     //call enviarCodigosOffline
     //call solicitarCampanasOffline
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

    
    IF (gEnTicket=0)
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



                if (Len(caja)<2)
                    format caja as "0",@Wsid
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

                format gCodigoIngresado as serial,"1",mes,dia,hora,gCodigoCVPais
                call enviaCodigoCV

                IF (gCodigoRespuesta="1")
                    format mensaje as "Codigo Customer Voice: ",gTiendaCV," ",serial,"  ",mes,"  ",dia, "  ",hora
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
    call procesaCupones(0,"")
endevent

Event inq: 6  //ingreso con tarjeta
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(1,"")
endevent

Event inq: 7  //evaluabk
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(0,"EVK")
endevent

Event inq: 8  //jumbochk
    gTouch=@ALPHASCREEN
    call darModeloCaja
    call procesaCupones(0,"JUM")
endevent

// inq para BKFree
Event inq: 4 //cambiar
    //gTouch=1010
    gTouch=@ALPHASCREEN
    call darModeloCaja
   // call procesaGiftCard
    call procesaCupones(0,"")
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
   
    if (gIdEmpleado="") 
     exitwitherror"DEBE INGRESAR UNA IDENTIFICACION"
    else
        format gDatos as "BENEFEMP|",@WSID,"|",gIdEmpleado,"|",gVersion,"|",gCaja,"|",@ttldue,"|",@RVC
    
        gNombreEmpleado=""
        call EnviaTransaccion
        call RecibeTransaccionDescEmpleados
        call procesarRespuestaDescEmpleados
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
                                LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gCodigoMicros),MakeKeys(gDescVariable), @KEY_ENTER, MakeKeys(gNombreEmpleado),@KEY_ENTER
                            endif
                        endif
                    endif
                endif
           endif
        endif
        if (gCodigoAdicional>0)
            LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+gCodigoMicrosNivel) //cambia el menulevel
            LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gCodigoAdicional) //selecciona un producto adicional al anterior
            LoadKybdMacro Key(KEY_TYPE_MENU_SUB_LEVEL,458756+pricelevel) //vuelve el menulevel
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

                    format gDatos as "BENEFEMP|",@WSID,"|",gCodigoIngresado,"|",gVersion,"|",gCaja,"|",@ttldue,"|",@RVC,"|",gCodigos[opcion]
    
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
sub procesaCupones(Var porTarjeta: N1,Var prefijo: A5)
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
    call consultarCodigoTarjeta(gCodigoIngresado,porTarjeta)
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
Sub consultarCodigoTarjeta(Ref codigoIngresado_, Ref porbanda)   	
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
                DisplayMSinput 1, 10, codigoIngresado{m1, 1, 1, 20},""
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
            IF (aux="00" or aux="99") 
		esClasica=0
            ELSEIF (aux="05" or aux="98") 
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
    

    call consultarCodigoTarjeta(gCodigoGiftCard,porBanda)
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