@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts
ContinueOnCancel

//Constantes
var gVersion				: A14="8.6"

//Variables
var RewardsCardNo			: A20
Var gPorBanda				: N1=0
var gDatos					: A1000=""
var gStatus					: N1 = 0 //0 ok, 1 error comunicacion
var gFechaHoy 				: A10
Var KeyPress                : Key
Var Data                    : A20

//DB Variables
Var gDBhdl 					: N12
Var gDBPath     			: A100="MDSSysUtilsProxy.dll"

//Variables para archivos
Var gVouchersPath			: A100
//Variables Respuesta MSR
var gCodigoRespuesta		: A50 = ""
var gDescRespuesta 			: A100 = ""
var gMsrOk 					: N1
var gMsrCheque				: N5
var gMsrChequeAnt			: N5
var gMsrIntentoRecarga		: N1
var gMsrRecargaOk			: N1
var gMsrconfirmaOk			: N1
var gMsrMetodo				: A10
var gMsrRecargaAnulacion 	: N1
var gMsrMontoAnulacion		: $8
var gMedioAnulacion			: A20
var gMsrIdAnulacion			: N22
var gMsrTarjeta				: A30
var gMsrIntentoPago			: N1
var gMsrNombre				: A30
var gMsrNivel				: A10
var gMsrSaldo				: $8
var gMsrMontoRecarga		: $8
var gMsrStars				: $8
var gMsrStarsFaltantes		: $8
var gMsrBebFav				: A50
var gMsrTender				: A4="110"
var gMsrTipoTarjeta			: A15
var gMsrHayBeneficio		: N1
var gMsrHayBeneficioDesc	: N1
var gMsrEnVtaGiftCard		: N1 //semaforo en venta giftcards
var gMsrBeneficiosLista		: N1 //semaforo solo para colocar beneficios en ticket
var gMsrSaldoActual			: N1
var gMsrRUT					: A20
var gMsrReimprimir			: A1
var gMsrMontoAnual			: $8
var gMsrPrimerItem			: N3
var gMsrEnRecarga			: N1
var gSolicitudSexo			: A20
var gSolicitudExtranjero	: A1
var gMontoReciboXOnline		: $8 //montos acumulados de recibos online
var gMsrMaxReintentos		: N1=1
var gMsrItemRef 			: N6=900088 //item para dejar referencia al producto marcado en un descuento

//Variables beneficios
var gBeneficiosLista[50] 	: A70
var gBeneficiosCodigos[50] 	: N16
var gBeneficiosCant 		: N2
var gBeneficioTicketCompleto: A1
var gBeneficioSeleccionado 	: N16
var gMaxOpciones 			: N2=11
var gProductos[20] 			: A40
var gCodigosTipo[20] 		: N1
var gCodigos[20] 			: N10
var gCodigosNivel[20] 		: N1
var gContadorProd 			: N2 = 0

//Variables parametros recarga
var gMontoRecargaMin		: N4=1000 	//minimo a recargar
var gMontoRecargaMax		: N5=80000 	//maximo a recargar
var gMontoSaldoMax			: N5=80000 	//maximo saldo por tarjeta
var gMontoRecargaMaxEfectivo: N5=80000 	//maximo a recargar en efectivo
var gActivationSvcNum		: A10="501"	//Service Charge para activacion
var gRechargeSvcNum			: A10="502"	//Service Charge para Recarga

//Variables Pausa/Recarga
var gOriginalCheck			: A10
var gOriginalMSRCard		: A20
var gVuelvePausaRecarga		: N1

//TouchScreens
var gTouch 					: N5
var gTouchNumeros 			: N5=52
var gTouchSinNumeros 		: N2=51
var gDefaultScreen			: N6=10000
var gLoadAmount				: A10
var gRechargePayScreen		: A6="16"

//Teclas predefinidas
Var KEY_TYPE_MENU_ITEM		: N9 = 3
Var KEY_TYPE_DISCOUNT 		: N9 = 5

//Variables de control de Flujo
Var gEnRecarga				: N1	
Var gEnPausaRecarga			: N1
Var gEnActivacion			: N1

//Variables para control de tipo de terminal y version
Var PCWS_TYPE				:N1 = 1	// Type number for PCWS
Var WS5_TYPE				:N1 = 3	// Type number for Workstation 5
Var gbliWSType				:N1			// To store the current Workstation type
Var gbliRESMajVer			:N2			// To store the current RES major version
Var gbliRESMinVer			:N2			// To store the current RES minor version

Var gbsLOG_FILENAME			: A100
//******************************************************
//             Eventos Micros
//******************************************************
Event init
	gTouch=@ALPHASCREEN
	call sqlDiaDeNegocio(gFechaHoy)
	gEnRecarga = 0
	gEnPausaRecarga = 0
	Call setWorkstationType
	Call SetFilePaths
EndEvent

Event Begin_Check
	gMsrIntentoRecarga = 0
	if (gEnRecarga = 1)
		Call PreparaRecarga
	Endif
	
	if (gEnPausaRecarga = 1)
		Call PreparaRecarga
	EndIf
	
	if (gEnActivacion = 1)
		Call PreparaActivacion
	EndIf
EndEvent

Event final_tender  //validar si estoy pagando una recarga
    //call pagoFinal
	if (gMsrRecargaOk = 1)
		call ConfirmaRecarga(1)
	EndIf
    IF (gEnPausaRecarga=1)
		LoadKyBdMacro Key (1,327684),MakeKeys (gOriginalCheck),@KEY_ENTER //tomo el ticket anterior
        gEnPausaRecarga=0
		gVuelvePausaRecarga = 1
    ELSE
        //gFechaHoy=""
        //gPausaRecargaHecha=0
		Call ClearRewardsInfo
    ENDIF
    
    gMsrEnVtaGiftCard=0
	gEnRecarga = 0
Endevent

Event trans_cncl
	if (gMsrRecargaOk = 1)
		call ConfirmaRecarga(0)
	EndIf
	if (gEnPausaRecarga = 1)
		Call cancelarOperacion
		gEnPausaRecarga = 0
		gVuelvePausaRecarga = 1
		gEnRecarga = 0
		LoadKyBdMacro Key (1,327684),MakeKeys (gOriginalCheck),@KEY_ENTER
	//elseif (gEnRecarga = 1)
	//	if (gMsrOk=1)
	//		Call cancelarOperacion
	//		
	//		Call ClearRewardsInfo
	//	EndIf
	elseif (gEnActivacion = 1)
		Call ClearRewardsInfo
	else
		if (gMsrOk = 1)
			Call cancelarOperacion
		EndIf
		Call ClearRewardsInfo
	EndIf
	//gMsrHayBeneficio=0
    //gMsrHayBeneficioDesc=0
	//gMsrOk=0
	//gMsrTarjeta=""
	//RewardsCardNo = ""
    //IF (gPausaRecarga=1 and gMsrOk=1)
    //    call cancelarOperacion
    //    LoadKyBdMacro Key (1,327684),MakeKeys (gOriginalCheck),@KEY_ENTER //tomo el ticket anterior
    //    //LoadKyBdMacro MakeKeys(@TREMP), @KEY_ENTER //con el barista actual1234

    //    gAdvertenciaSaldo=0
    //    gPausaRecarga=0
    //ELSE
    //    call crearDiaNegocio   
    //    IF (gMsrOk=1)
    //        call cancelarOperacion
    //    ENDIF
    //    call initMsr
    //    IF (gOffCant>0)
    //        call enviarRecargasOffline
    //    ENDIF
    //ENDIF
Endevent

Event Pickup_Check
	if (gVuelvePausaRecarga = 1)
		//Carga default Screen
		LoadKyBdMacro Key (17,gDefaultScreen)
	EndIf
EndEvent


event dsc_void
    Call deseleccionarBeneficio
endevent
//******************************************
//       Consulta Beneficios Tarjeta
//******************************************
Event Inq : 1
	call loginMSR("DESLIZAR_TARJETA") //Consulta info de Rewards
	if (gMsrOk=1)
		call logoutMSR
	EndIf
	clearchkinfo
	Call ClearRewardsInfo
EndEvent
//******************************************
//       Cargar Tarjeta en POS
//******************************************
Event Inq : 2
	gEnRecarga = 1
	
	if (@cknum=0)
		LoadKyBdMacro Key(1, 327681)
	else
		call PreparaRecarga
	Endif
EndEvent

//******************************************
//       Canje Beneficio
//******************************************
Event Inq : 3
	IF (gMsrBeneficiosLista=0)
		IF (gBeneficiosCant>0)
			call mostrarBeneficios
		ELSE
			call mostrarmensaje("NO POSEE BENEFICIOS ACTIVOS")
		ENDIF
	ENDIF
EndEvent

//******************************************
//       Activa tarjeta
//******************************************
Event Inq : 4
	gEnActivacion = 1
	
	if (@cknum=0)
		LoadKyBdMacro Key(1, 327681)
	else
		call PreparaActivacion
	Endif
	
	
EndEvent
//******************************************
//       Asocia Rewards a Check
//******************************************
Event Inq : 6
	If @CKNUM <> 0
		
		var temporal:A30 = ""
		
		If Len(gMsrTarjeta) > 0 //Sbux card 
			
			If Len(Trim(gMsrTarjeta)) = 16
				call loginMSR("DESLIZAR_TARJETA") //Consulta info de Rewards
				Call CheckPausaRecarga
			else
				Call Pago_Efectivo1
			endif
			 
		Else // Efectivo
			Call Pago_Efectivo1
		EndIF
	ENDIF
EndEvent

//******************************************
//       Desliga Rewards a Check
//******************************************
Event Inq : 7
	if (gMsrHayBeneficio>0)
		exitwitherror "SE APLICARON BENEFICIOS, DEBE CANCELAR EL TICKET, NO DESLIGAR REWARDS"
	else	
		call logoutMSR
		clearchkinfo
		Call ClearRewardsInfo
	EndIf
    LoadKyBdMacro Key (17,gDefaultScreen) //Carga pantalla expresso
EndEvent

//******************************************
//       Carga Rewards
//******************************************
Event Inq : 8
	Call CargaRewards
EndEvent

//******************************************************
//             Funciones internas
//******************************************************

//******************************************************
// Procedure: setWorkstationType()
//******************************************************
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
//******************************************************
// Procedure: 	SetFilePaths()
//******************************************************
Sub SetFilePaths		
	// general paths
	If gbliWSType = PCWS_TYPE
		// This is a Win32 client
		Format gVouchersPath as "..\Etc\"
		format gbsLOG_FILENAME as "..\etc\logs\"		
	Else	// This is a WinCE 5.0/6.0 client	
		Format gVouchersPath  as "\CF\micros\etc\"
		format gbsLOG_FILENAME as "\cf\micros\etc\logs\"		
    EndIf	

EndSub
//*****************************************************
//Login MSR. Comando: DESLIZAR_TARJETA SALDO
//*****************************************************
sub loginMSR(VAR comando:A20)
    var porTarjeta : N1=1
    gCodigoRespuesta = ""
    gDescRespuesta  = ""
    porTarjeta=gPorBanda
	
	call sqlDiaDeNegocio(gFechaHoy)
	if (gMsrTarjeta="")
		call consultarCodigoTarjeta("Lee Rewards",gMsrTarjeta,porTarjeta) // carga rewards
	EndIf
	if (gMsrTarjeta="" or len(gMsrTarjeta)<>16) 
		infomessage "DEBE INGRESAR UNA TARJETA REWARDS"
		format gMsrTarjeta as ""
		gMsrOk = 0
	else
		//infomessage "Consulta miembro"
		format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|DESLIZAR_TARJETA|",gMsrTarjeta
		//format gDatos as gVersion,"|",@WSID,"|",@RVC,"|6743|",gFechaHoy,"|DESLIZAR_TARJETA|",gMsrTarjeta
		call EnviaTransaccion
		call RecibeTransaccion
		
		IF (gCodigoRespuesta="INFO_MIEMBRO")
			if (gEnActivacion=1)
				errormessage "TARJETA YA ACTIVADA"
				call logoutMSR
				clearchkinfo
				Call ClearRewardsInfo
				exitcontinue
			EndIf
			
			//infomessage "Consulta beneficios"
			if (gMsrRUT<>"")
				format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","GET_BENEFICIOS","|",gMsrTarjeta
				//format gDatos as gVersion,"|",@WSID,"|",@RVC,"|6743|",gFechaHoy,"|","GET_BENEFICIOS","|",gMsrTarjeta

				call EnviaTransaccion
				call RecibeTransaccionBeneficios
				
				IF (gCodigoRespuesta="LISTADO_DE_BENEFICIOS")
					window 12,70, "INFORMACION REWARDS"
						// first column
						Display 1,1, "NRO TARJETA: "
						Display 2,1, "NOMBRE     : "
						Display 3,1, "SALDO      : "
						Display 4,1, "ESTADO     : "
						Display 5,1, "NIVEL      : "
						Display 6,1, "CUMPLEANOS : "
						Display 7,1, "STARS      : "
						Display 8,1, "BENEFICIOS : "
						Display 9,1, ""
						Display 10,1, ""
						Display 11,1, ""
						Display 12,1, ""
						// second column
						Display 1,31, gMsrTarjeta
						Display 2,31, mid(gMsrNombre,1,35)
						Display 3,31, gMsrSaldo
						Display 4,31, "Activo"
						Display 5,31, gMsrNivel
						Display 6,31, ""
						Display 7,31, gMsrStars
						

						Var ZZ	: N3
						Var Ben : N3
						Var JJ	: N3

						
						Ben = 1
						For JJ = 1 to gBeneficiosCant
							If Len(Trim(gBeneficiosLista[JJ])) > 0 
								ZZ = 7 + Ben
								Display ZZ, 31, Mid(gBeneficiosLista[JJ], 1, 35)	
								Ben = Ben + 1
								if Ben = 5
									JJ = 100
								EndIf
							EndIF
						EndFor
						TouchScreen 54		
					WaitForEnter
					
					WindowClose
									
					gMsrOk = 1
					
					if (comando="BENEFICIOS")
					//Do something to show beneficios
					else
						call cargarInfoLines
					EndIf
				else
					errormessage "ERROR AL CARGAR BENEFICIOS"
					format gMsrTarjeta as ""
				Endif
			else
				window 12,70, "INFORMACION TARJETA NO ASOCIADA"
					// first column
					Display 1,1, "NRO TARJETA: "
					Display 2,1, "NOMBRE     : "
					Display 3,1, "SALDO      : "
					Display 4,1, "ESTADO     : "
					Display 5,1, "NIVEL      : "
					Display 6,1, "CUMPLEANOS : "
					Display 7,1, "STARS      : "
					Display 8,1, "BENEFICIOS : "
					Display 9,1, ""
					Display 10,1, ""
					Display 11,1, ""
					Display 12,1, ""
					// second column
					Display 1,31, gMsrTarjeta
					Display 2,31, ""
					Display 3,31, gMsrSaldo
					Display 4,31, "Activo"
					Display 5,31, ""
					Display 6,31, ""
					Display 7,31, ""
					

					Var ZZ	: N3
					Var Ben : N3
					Var JJ	: N3

					
					Ben = 1
					For JJ = 1 to gBeneficiosCant
						If Len(Trim(gBeneficiosLista[JJ])) > 0 
							ZZ = 7 + Ben
							Display ZZ, 31, Mid(gBeneficiosLista[JJ], 1, 35)	
							Ben = Ben + 1
							if Ben = 5
								JJ = 11
							EndIf
						EndIF
					EndFor
					TouchScreen 54		
				WaitForEnter
				
				WindowClose
				
				gMsrOk = 1
				
			EndIf
		elseif(gCodigoRespuesta="ERROR")
			IF (mid(gDescRespuesta,1,31)="No existe la tarjeta solicitada")
				if (gEnActivacion = 0)
					errormessage "TARJETA NO ACTIVADA"
					format gMsrTarjeta as ""
				else
					gMsrOk = 1
				Endif
			elseif (mid(gDescRespuesta,31,14)="esta bloqueada")
				errormessage "TARJETA BLOQUEADA"
				format gMsrTarjeta as ""
			else
				errormessage "ERROR AL CARGAR REWARDS"
				gMsrTarjeta = ""
			EndIf
		else
			errormessage "ERROR AL CARGAR REWARDS"
			gMsrTarjeta = ""
		EndIf
		
	endif
endsub

sub PagoRewards
	Call LoginMSR("DESLIZAR_TARJETA")
	
EndSub

sub PreparaRecarga
	var sTmpText	: A100
	var KeepInLoop	: N1
	
	if (gEnPausaRecarga = 1)
		Call LoginMSR("DESLIZAR_TARJETA")
		if (gMsrOk=1)
			if (gLoadAmount = 0)
				KeepInLoop = 1
				Call PideMontoRecarga()
				While (KeepInLoop = 1)
					KeepInLoop = 0
					if gLoadAmount > 0
						if (gLoadAmount<gMontoRecargaMin)
							format sTmpText as "Recarga debe ser superior a $ ", gMontoRecargaMin
							errormessage sTmpText
							KeepInLoop = 1
						EndIf
						
						if (gLoadAmount>gMontoRecargaMax)
							format sTmpText as "Recarga debe ser inferior a $ ", gMontoRecargaMax
							errormessage sTmpText
							KeepInLoop = 1
						EndIf

						if ((gLoadAmount + gMsrSaldo) >gMontoSaldoMax)
							format sTmpText as "Saldo maximo debe ser inferior a $ ", gMontoSaldoMax
							errormessage sTmpText
							KeepInLoop = 1
						EndIf

						if KeepInLoop = 1
							Call PideMontoRecarga()
						EndIf
					EndIf
				EndWhile
			EndIf
		else
			exitcancel
		EndIf
	else
		IF (gMsrOk=0)
			//La tarjeta no ha sido leida, por lo que requerimos leerla antes de continuar
			Call LoginMSR("DESLIZAR_TARJETA")
		EndIf
	EndIf
	
	IF (gMsrOk=0)
		//La tarjeta no ha sido leida, por lo que no podemos continuar
		exitcancel
	EndIf
		
	if (gLoadAmount = 0)
		KeepInLoop = 1
		Call PideMontoRecarga()
		While (KeepInLoop = 1)
			KeepInLoop = 0
			if gLoadAmount > 0
				if (gLoadAmount<gMontoRecargaMin)
					format sTmpText as "Recarga debe ser superior a $ ", gMontoRecargaMin
					errormessage sTmpText
					KeepInLoop = 1
				EndIf
				
				if (gLoadAmount>gMontoRecargaMax)
					format sTmpText as "Recarga debe ser inferior a $ ", gMontoRecargaMax
					errormessage sTmpText
					KeepInLoop = 1
				EndIf
				
				if ((gLoadAmount + gMsrSaldo) >gMontoSaldoMax)
					format sTmpText as "Saldo maximo debe ser inferior a $ ", gMontoSaldoMax
					errormessage sTmpText
					KeepInLoop = 1
				EndIf
				if KeepInLoop = 1
					Call PideMontoRecarga()
				EndIf
			EndIf
		EndWhile
	EndIf
	
	if (gLoadAmount>0)
		//LoadKyBdMacro Key(1, 327681)
		//Se agrega la recarga inmediata, para luego realizar la confirmacion en final_tender
		if gMsrIntentoRecarga
			Call ConfirmaRecarga(1)
		EndIf
		Call EnviaRecarga
		if (gMsrRecargaOk = 1)
			loadkybdmacro key(1,270336), makekeys(gRechargeSvcNum) , @Key_Enter, makekeys(gLoadAmount),@Key_Enter
		EndIf
	else
		errormessage ("NO INGRESO MONTO")
		call logoutMSR
		clearchkinfo
		Call ClearRewardsInfo
		exitcancel
	EndIf
	//infomessage "cambia a payment screen"
	LoadKyBdMacro Key (19,105)

EndSub

sub PreparaActivacion
	var sTmpText	: A100
	var KeepInLoop	: N1
	
	if (gEnActivacion = 1)
		Call LoginMSR("DESLIZAR_TARJETA")
		if (gMsrTarjeta<>"")
			gLoadAmount = 0
		else
			exitcancel
		EndIf
	EndIf
	
	if (gLoadAmount = 0)
		KeepInLoop = 1
		Call PideMontoRecarga()
		While (KeepInLoop = 1)
			KeepInLoop = 0
			if gLoadAmount > 0
				if (gLoadAmount<gMontoRecargaMin)
					format sTmpText as "Recarga debe ser superior a $ ", gMontoRecargaMin
					errormessage sTmpText
					KeepInLoop = 1
				EndIf
				
				if (gLoadAmount>gMontoRecargaMax)
					format sTmpText as "Recarga debe ser inferior a $ ", gMontoRecargaMax
					errormessage sTmpText
					KeepInLoop = 1
				EndIf
				if KeepInLoop = 1
					Call PideMontoRecarga()
				EndIf
			EndIf
		EndWhile
	EndIf
	
	IF (gMsrOk=0)
		//La tarjeta no ha sido leida, por lo que no podemos continuar
		exitcancel
	EndIf
	
	
	if (gLoadAmount>0)
		//LoadKyBdMacro Key(1, 327681)
		if gMsrIntentoRecarga
			Call ConfirmaRecarga(1)
		EndIf
		Call EnviaRecarga
		if (gMsrRecargaOk = 1)
			loadkybdmacro key(1,270336), makekeys(gActivationSvcNum) , @Key_Enter, makekeys(gLoadAmount),@Key_Enter
		EndIf
	else
		errormessage ("NO INGRESO MONTO")
		clearchkinfo
		Call ClearRewardsInfo
		exitcancel
	EndIf
	//infomessage "cambia a payment screen"
	LoadKyBdMacro Key (19,105)

EndSub

Sub PideMontoRecarga()
	Call GetNumValueReload(gLoadAmount, "INGRESE MONTO RECARGA", 1)
EndSub

Sub pagoFinal
    VAR aux:A100
	VAR aux1:A100
    VAR intentos:N1=0
    VAR i:N3=0
    VAR tender:N5=0
    VAR tenderdesc:A15="EFECTIVO"
    VAR espera:N5=5000

    gMsrRecargaOk=0
    
    //gMsrMontoRecarga=0
    //gMsrRecargaAnulacion=0
    IF gMsrOk=1  //estoy en una transaccion MSR, tengo que validar que sea recarga
        IF (@SVC>0 and @TTLDUE=0) //solo tengo en el item la recarga de saldo
            
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
                //IF (tender>=gTenderTarjetas)
                //    IF (tender=gTenderMPago) //MPAGO
                //        format tenderdesc as "MERCADO PAGO|",tender
                //        format gMedioAnulacion as "MPAGO - ",tender
                //    ELSE
                //        format tenderdesc as "TARJETA|",tender
                //        format gMedioAnulacion as "TARJETA - ",tender
                //    ENDIF
                //ELSE
                    format tenderdesc as "EFECTIVO|",tender
                    format gMedioAnulacion as "EFECTIVO - ",tender
                //ENDIF
                //format aux as "RECARGA ",intentos
                //call registrarOperacion(aux,gMsrTarjeta)
 
				if (gEnActivacion = 1)
					format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","ALTA_GIFTCARD","|",gMsrTarjeta,"|",gLoadAmount,"|",tenderdesc
				else
					format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","RECARGAR_TARJETA","|",gMsrTarjeta,"|",gLoadAmount,"|",tenderdesc,"|",gMsrMetodo
				EndIf
				
                
                call EnviaTransaccion
                call RecibeTransaccion
                IF @RxMsg <> "_timeout" 
                    call procesarRespuesta
					
                    //gMsrEnRecarga=0
                    
                    //IF (gMsrRecargaOk=1)
					//	IF (gEnActivacion=1)
					//		Call GeneraComprobanteActivacion
					//	else
					//		Call GeneraComprobanteCarga
					//	Endif
						
					//	//llama a Facturador para imprimir comprobantes
					//	
					//	//infomessage "BDMACRO"
					//	//LoadDBKybdMacro 20047
					//	
					//	//infomessage "KBDMACRO"
					//	loadKybdMacro key(24,(16384 * 10) + 10)
					//
					//	format aux as "Mensaje (Version: ",gVersion," Chk: ",@cknum,")"
					//	format aux1 as "NUEVO SALDO: ", gMsrSaldo
					//	beep
					//	infomessage aux, aux1
                    //ENDIF

                ENDIF
                intentos=intentos+1
             ENDWHILE
             IF (gMsrRecargaOk=0)
                IF (intentos=gMsrMaxReintentos)
                    //gProcesoRecargaNO=1
                    call mostrarmensaje("ERROR AL CARGAR SALDO.")                  
             //       IF (gFiscal=0)
             //           LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
             //       ELSE
             //           call procesoReciboX
             //       ENDIF
                ENDIF
             ENDIF
        //ELSE
        //   IF (gMsrHayBeneficio>=1) //tengo un beneficio pero no pago con rewards
        //        IF (@TTLDUE<1) //debo registrar en backoffice
        //            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",0,"|",gMsrMetodo,"|1|1|1|10|1|NO"
        //        ELSE
        //            format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",0,"|",gMsrMetodo,"|0|0|0|0|0|NO"
        //        ENDIF
        //        call EnviaTransaccion
        //        call RecibeTransaccion
        //        
        //        IF @RxMsg <> "_timeout" 
        //            call procesarRespuestaSinMsr
        //        ENDIF
        //   ENDIF
        ENDIF
    
    ENDIF
    
   
    //IF (gPausaRecarga=0)
        gMsrOk=0
        gMsrHayBeneficio=0
        gMsrHayBeneficioDesc=0
    //ENDIF
    //gMsrRecargaOk=0
    gMsrEnVtaGiftCard=0
    
ENDSUB

Sub EnviaRecarga
    VAR aux:A100
	VAR aux1:A100
    VAR intentos:N1=0
    VAR i:N3=0
    VAR tender:N5=0
    VAR tenderdesc:A15="EFECTIVO"
    VAR espera:N5=5000

    gMsrRecargaOk=0
    gMsrIntentoRecarga=0
    IF gMsrOk=1  //estoy en una transaccion MSR, tengo que validar que sea recarga
            
		WHILE (intentos<gMsrMaxReintentos and gMsrRecargaOk=0)
			IF (intentos>0)
				format aux as "ERROR EN CARGA DE SALDO. REINTENTO ",intentos," .NO APAGUE EL POS"
				call mostrarmensaje (aux)
				msleep espera
				espera=espera+5000*intentos
			ENDIF  
			
			format tenderdesc as "EFECTIVO|",tender
			format gMedioAnulacion as "EFECTIVO - ",tender
			
			if (gEnActivacion = 1)
				format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","ALTA_GIFTCARD","|",gMsrTarjeta,"|",gLoadAmount,"|",tenderdesc
			else
				format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","RECARGAR_TARJETA","|",gMsrTarjeta,"|",gLoadAmount,"|",tenderdesc,"|",gMsrMetodo
			EndIf
			
			gMsrIntentoRecarga=1
			
			call EnviaTransaccion
			call RecibeTransaccion
			IF @RxMsg <> "_timeout" 
				call procesarRespuesta
				
				//gMsrEnRecarga=0
				
				//IF (gMsrRecargaOk=1)
				//	IF (gEnActivacion=1)
				//		Call GeneraComprobanteActivacion
				//	else
				//		Call GeneraComprobanteCarga
				//	Endif
					
				//	//llama a Facturador para imprimir comprobantes
				//	
				//	//infomessage "BDMACRO"
				//	//LoadDBKybdMacro 20047
				//	
				//	//infomessage "KBDMACRO"
				//	loadKybdMacro key(24,(16384 * 10) + 10)
				//
				//	format aux as "Mensaje (Version: ",gVersion," Chk: ",@cknum,")"
				//	format aux1 as "NUEVO SALDO: ", gMsrSaldo
				//	beep
				//	infomessage aux, aux1
				//ENDIF

			ENDIF
			intentos=intentos+1
		 ENDWHILE
		 IF (gMsrRecargaOk=0)
			IF (intentos=gMsrMaxReintentos)
				call mostrarmensaje("ERROR AL CARGAR SALDO.")                  
			ENDIF
		ENDIF
        
    
    ENDIF
    
   
    //IF (gPausaRecarga=0)
        gMsrOk=0
        gMsrHayBeneficio=0
        gMsrHayBeneficioDesc=0
    //ENDIF
    //gMsrRecargaOk=0
    gMsrEnVtaGiftCard=0
    
ENDSUB

Sub ConfirmaRecarga(var Confirma:N1)
    VAR aux:A100
	VAR aux1:A100
    VAR intentos:N1=0
    VAR i:N3=0
    VAR tender:N5=0
    VAR tenderdesc:A15="EFECTIVO"
    VAR espera:N5=5000
	VAR EstadoRecarga: A5
	VAR sTmp	: A200
    //gMsrRecargaOk=0
    
    //gMsrMontoRecarga=0
    //gMsrRecargaAnulacion=0
	
    IF gMsrRecargaOk=1  //estoy en una transaccion MSR, tengo que validar que sea recarga
        //IF (@SVC>0 and @TTLDUE=0) //solo tengo en el item la recarga de saldo
            WHILE (intentos<gMsrMaxReintentos AND gMsrconfirmaOK = 0)
                IF (intentos>0)
                    format aux as "ERROR AL CONFIRMAR RECARGA. REINTENTO ",intentos," .NO APAGUE EL POS"
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
                //IF (tender>=gTenderTarjetas)
                //    IF (tender=gTenderMPago) //MPAGO
                //        format tenderdesc as "MERCADO PAGO|",tender
                //        format gMedioAnulacion as "MPAGO - ",tender
                //    ELSE
                //        format tenderdesc as "TARJETA|",tender
                //        format gMedioAnulacion as "TARJETA - ",tender
                //    ENDIF
                //ELSE
                    format tenderdesc as "EFECTIVO|",tender
                    format gMedioAnulacion as "EFECTIVO - ",tender
                //ENDIF
                //format aux as "RECARGA ",intentos
                //call registrarOperacion(aux,gMsrTarjeta)
				if (Confirma)
					Format EstadoRecarga as "OK"
				else
					Format EstadoRecarga as "FAIL"
				EndIf
				format sTmp as "Envia confirmacion de recarga"
				call Writelog(gbsLOG_FILENAME,sTmp,1,1)
				//if (gEnActivacion = 1)
				//	format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONFIRMAR_TRANSACCION_AC","|",gMsrTarjeta,"|",gLoadAmount,"|",tenderdesc, "|", EstadoRecarga
				//else
				//	format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONFIRMAR_TRANSACCION_AC","|",gMsrTarjeta,"|",gLoadAmount,"|",tenderdesc,"|",gMsrMetodo, "|", EstadoRecarga
				//EndIf
				//format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONFIRMAR_TRANSACCION_AC","|",gMsrTarjeta,"|",gLoadAmount,"|", EstadoRecarga
				format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","CONFIRMAR_TRANSACCION_AC","|",gMsrTarjeta,"|",gLoadAmount,"|", gMsrMetodo, "|", tenderdesc, "|", EstadoRecarga
				
                
                call EnviaTransaccion
                call RecibeTransaccion
                IF @RxMsg <> "_timeout" 
                    call procesarRespuesta
                    //gMsrEnRecarga=0
                    if (Confirma)
						IF (gMsrconfirmaOK=1)
							format sTmp as "Confirmacion OK"
							call Writelog(gbsLOG_FILENAME,sTmp,1,1)
							IF (gEnActivacion=1)
								Call GeneraComprobanteActivacion
							else
								Call GeneraComprobanteCarga
							Endif
							
							//llama a Facturador para imprimir comprobantes
							
							//infomessage "BDMACRO"
							//LoadDBKybdMacro 20047
							
							//infomessage "KBDMACRO"
							loadKybdMacro key(24,(16384 * 10) + 10)

							format aux as "Mensaje (Version: ",gVersion," Chk: ",@cknum,")"
							format aux1 as "NUEVO SALDO: ", gMsrSaldo
							
							beep
							infomessage aux, aux1
							
						ENDIF
					else
						IF (gMsrconfirmaOK=1)
							IF (gEnActivacion=1)
								InfoMessage "Activacion Reversada"
							else
								InfoMessage "Recarga Reversada"
							EndIF
						EndIf
					EndIf
                ENDIF
                intentos=intentos+1
             ENDWHILE
             IF (gMsrconfirmaOK=0)
                IF (intentos=gMsrMaxReintentos)
                    //gProcesoRecargaNO=1
                    call mostrarmensaje("ERROR AL CONFIRMAR TRANSACCION MSR.")                  
             //       IF (gFiscal=0)
             //           LoadDBKybdMacro gMacroReciboX //llamo a la macro que carga/descarga driver impresion pms8 e imprime
             //       ELSE
             //           call procesoReciboX
             //       ENDIF
                ENDIF
             ENDIF
        //ENDIF
    
    ENDIF
    
   
    //IF (gPausaRecarga=0)
        gMsrOk=0
        gMsrHayBeneficio=0
        gMsrHayBeneficioDesc=0
    //ENDIF
    gMsrRecargaOk=0
    gMsrEnVtaGiftCard=0
	gMsrconfirmaOk = 0
    
ENDSUB

sub CargaRewards
	var sLoadAmount : A10
	var cantItems : N4 = 0
    var items: A2000 = ""
	var tipo: N1=1
	var nivel :N2
	var i		:N3
	
	//Call LoginMSR("DESLIZAR_TARJETA")
	FOR i = 1 to @NUMDTLT
		IF ((@DTL_TYPE[i]="M" or @DTL_TYPE[i]="D" ))
		   IF (@DTL_IS_VOID[i] = 0 and @DTL_QTY[i]>0)
				tipo=1
				nivel=@DTL_SLVL[i]
				IF (@DTL_TYPE[i]="D")
					 tipo=2
					 nivel=0
				ENDIF
				format items as items,"|",@DTL_QTY[i],"|",tipo,"|",@DTL_OBJECT[i],"|",nivel,"|","SI"
				cantItems=cantItems+1
				IF ((@DTL_TYPE[i]="M") and (@DTL_TTL[i]<0.05) and (@DTL_TTL[i]>0))

					 eltotal=eltotal-@DTL_TTL[i]
				ENDIF
		   ENDIF
		ENDIF
	ENDFOR
	if @ttldue >= 0
		format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","PAGAR","|",gMsrTarjeta,"|",@ttldue,"|",gMsrMetodo,"|",cantItems,items
		call EnviaTransaccion
		call RecibeTransaccion
		IF @RxMsg <> "_timeout" 
			call procesarRespuesta
		ENDIF
	EndIf	
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
            //call registrarOperacion("RECARGA",gMsrTarjeta)
            //format gDatos as gVersion,"|",@WSID,"|",@RVC,"|1111|",gFechaHoy,"|","RECARGAR_TARJETA","|",gMsrTarjeta,"|2000|",gMsrMetodo
			format gDatos as gVersion,"|",@WSID,"|",@RVC,"|1111|",gFechaHoy,"|","RECARGAR_TARJETA","|",gMsrTarjeta,"|2000|EFECTIVO|101|",gMsrMetodo

            call EnviaTransaccion
            call RecibeTransaccion
            IF @RxMsg <> "_timeout" 
                //call procesarRespuesta
                //call mostrarmensaje("GENERAR RECIBO X, CIERRO TICKET")
                
                LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, 2)
            ENDIF
    ELSE
        call mostrarmensaje("PRIMERO DEBE IDENTIFICARSE")
    ENDIF
endsub
//*************************** MSR *****************************
// Consulta si aplica Rewards o no
// ****************************************************************
Sub Pago_Efectivo1
	var porTarjeta : N1=1
	porTarjeta=1
	
	ClearIslTs
            SetIslTskeyx 1,  1, 10, 10, 3, @Key_Enter, 10059, "B", 10, "SI"
            SetIslTskeyx 1, 11, 10, 10, 3, @Key_Clear, 10058, "B", 10, "NO"
            SetIslTskeyx 1,  21,10, 10, 3, Key(1,131073), 10059, "B", 10, "Volver"
            DisplayIslTs
        Inputkey keypress, data, "Pago con SBUX CARD"
		
		If KeyPress = @Key_Clear
            //Carga Pantalla Pagos Normal
			LoadKyBdMacro Key (19,103)
        ElseIf KeyPress = @Key_Enter
			call LoginMSR("DESLIZAR_TARJETA")
			//call consultarCodigoTarjeta("Deslice Tarjeta Rewards",gMsrTarjeta,porTarjeta) // carga rewards
			if (gMsrTarjeta="" or len(gMsrTarjeta)<>16) 
				infomessage "DEBE INGRESAR UNA TARJETA REWARDS"
				LoadKyBdMacro Key (17,gDefaultScreen) //Vuelvo a pantalla expresso
			else
				Call CheckPausaRecarga				
			endif
        ElseIf KeyPress = Key(1,131073)       //Volver
			LoadKyBdMacro Key (17,gDefaultScreen) //Carga pantalla expresso
        EndIf

EndSub

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
//Logout Operacion. 
//*****************************************************
sub logoutMSR
	if gMsrIntentoRecarga
		Call ConfirmaRecarga(1)
	EndIf
    format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|LOGOUT|",gMsrTarjeta

    call EnviaTransaccion
    call RecibeTransaccion
    if @RxMsg <> "_timeout" 
        call procesarRespuesta
    endif
endsub

//************************* MSR  *********************************
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
		gMsrIntentoRecarga = 0
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
	ELSEIF (gCodigoRespuesta="CONFIRMAR_TRANSACCION_AC_OK")
		gMsrconfirmaOk = 1
		gMsrIntentoRecarga = 0
    ELSE
        gMsrRecargaOk=0
        format aux as gCodigoRespuesta," : ",gDescRespuesta
        call mostrarmensaje(aux)
        LOADKYBDMACRO KEY(1, 196613) //me quedo en la pantalla actual
        IF (gMsrEnRecarga=1) //estoy recargando, en pago final pero dio error
            gProcesoRecargaNO=1
            call mostrarmensaje("ERROR AL CARGAR SALDO. SE GENERA BEBIDA POR FALLA EN RECARGA") 
        ENDIF
    ENDIF
endsub

sub procesarPagoMSR
	var sTmp	: A300
	
    gMsrHayBeneficio=0
    gMsrHayBeneficioDesc=0
	gMsrOk=0
	gMsrTarjeta=""
	//infomessage "EN PAGO MSR TENDER"
	format sTmp as "Agregando Pago con MSR"
	call Writelog(gbsLOG_FILENAME,sTmp,1,1)
    LoadKybdMacro MakeKeys(@TTLDUE),  Key (9, gMsrTender)

	format sTmp as "Pago con MSR Agregado"
	call Writelog(gbsLOG_FILENAME,sTmp,1,1)	
endsub
//*************************** MSR *****************************
// Chequea si aplica pausa/recarga
// ****************************************************************
Sub CheckPausaRecarga
	Var Keeplooping : N1
	Var ContinuePR	: N1
	Var sTmpMess	: A50
	
	if (@ttldue >0 or @dsc <> 0)
		if (@ttldue > gMsrSaldo)
			errormessage "Saldo Insuficiente!"
			
			ClearIslTs
				SetIslTskeyx 1,  1, 10, 10, 3, @Key_Enter, 10059, "B", 10, "SI"
				SetIslTskeyx 1, 11, 10, 10, 3, @Key_Clear, 10058, "B", 10, "NO"
				SetIslTskeyx 1, 21,10, 10, 3, Key(1,131073), 10059, "B", 10, "Canje Beneficio/Descuento"
				DisplayIslTs
			Inputkey keypress, data, "Desea Recargar?"
			
			If KeyPress = @Key_Clear
				LoadKyBdMacro Key (17,gDefaultScreen) //Carga pantalla expresso
				clearchkinfo
				Call logoutMSR
				Call ClearRewardsInfo						
			ElseIf KeyPress = @Key_Enter
				//LoadKybdMacro Key(24, 16384 * 4 + 24) //PausaRecarga 
				
				Keeplooping = 1
				Var RecargaMinima : N6
				While (Keeplooping = 1)
					RecargaMinima = @ttldue - gMsrSaldo
					if (RecargaMinima<gMontoRecargaMin)
						format sTmpMess as  "INGRESE MONTO (min: ", gMontoRecargaMin, ")"
					else
						format sTmpMess as  "INGRESE MONTO (min: ", RecargaMinima, ")"
					EndIf
					call GetNumValueReload( gLoadAmount, sTmpMess, 1)
					
					if (gLoadAmount > 0)
						if ((gMsrSaldo + gLoadAmount) < @ttldue)
							errorMessage "Monto Insuficiente"
							Keeplooping = 1
						elseif (gLoadAmount<gMontoRecargaMin)
							errorMessage "Monto Insuficiente"
							Keeplooping = 1
						
						elseif ((gMsrSaldo + gLoadAmount)> gMontoRecargaMax)
							errorMessage "Monto Superior al permitido"
							Keeplooping = 1
						else
							Keeplooping = 0
						EndIf
						
						if Keeplooping = 0
							if ((gLoadAmount + gMsrSaldo) >gMontoSaldoMax)
								format sTmpMess as "Saldo maximo debe ser inferior a $ ", gMontoSaldoMax
								errormessage sTmpMess
								Keeplooping = 1
							EndIf
						EndIf
					else
						Keeplooping = 0
					EndIf
					
				EndWhile

				if (gLoadAmount = 0)
					LoadKyBdMacro Key (17,gDefaultScreen) //Carga pantalla expresso
					clearchkinfo
					Call ClearRewardsInfo
				else
					gEnPausaRecarga = 1
					gOriginalCheck = @cknum
					gOriginalMSRCard = gMsrTarjeta
					gVuelvePausaRecarga = 0
					LoadKyBdMacro Key(9, 409)                    //Service Key
					LoadKyBdMacro Key(1, 327681)                 //Open check

					LoadKyBdMacro MakeKeys(@TREMP), @KEY_ENTER

				EndIf 
			ElseIf KeyPress = Key(1,131073)       //Canje Beneficio
				LoadKyBdMacro Key (19,108)
			EndIf
			
		else
			LoadKyBdMacro Key (19,104)
		Endif
	EndIf
EndSub

//******************************************************************
// Procedure: GeneraComprobanteCarga()
// Author		: C Sepulveda
// Purpose	: Generate reload voucher to be printed by FCR
//******************************************************************
Sub GeneraComprobanteCarga
	var sTmpLine	: A100
	var FileHandle1 : N5
	var FileHandle2 : N5
	var FileName1	: A100
	var FileName2	: A100
	
	Prompt "Generando Comprobantes......"
	
	//Seteamos nombres de vouchers
	FORMAT FileName1 AS gVouchersPath, "RewCustV.txt"
	//FORMAT FileName2 AS gVouchersPath, "RewStorV.txt"
	
	FOPEN FileHandle1, FileName1, WRITE
	//FOPEN FileHandle2, FileName2, WRITE
	
	if FileHandle1 = 0
		errormessage "ERROR AL GENERAR VOUCHER CLIENTE"
	Endif

	//if FileHandle2 = 0
	//	errormessage "ERROR AL GENERAR VOUCHER TIENDA"
	//	if FileHandle1 >0
	//		FCLOSE FileHandle1
	//	EndIf
	//Endif
	
	format sTmpLine as "********************************************"
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   COMPROBANTE DE CARGA STARBUCKS REWARDS   "
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   "
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "FECHA : ", @DAY{02}, "-", @MONTH{02}, "-", 2000+@YEAR, "     HORA      : ", @HOUR{02}, ":", @MINUTE{02}
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "CAJA  : ", @WSID{>4}, " CHECK : ", @CKNUM{04}, " CAJERO : ", @CKEMP{09}
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "********************************************"
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   "
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "CLIENTE        : ", gMsrNombre
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "TARJETA        : ", "************", mid(gMsrTarjeta,13,4)
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "MONTO          : $ ", gLoadAmount{>10}
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "NUEVO SALDO    : $ ", gMsrSaldo{>10}
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   "
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "  ESTE COMPROBANTE NO ES VALIDO COMO BOLETA"
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "  RECIBIRAS TU BOLETA AL MOMENTO DE REALIZAR"
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "                CADA COMPRA."
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as " "
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "               COPIA CLIENTE"
	FWrite FileHandle1, sTmpLine
	
	format sTmpLine as "               COPIA COMERCIO"
	//FWrite FileHandle2, sTmpLine
	
	format sTmpLine as ""
	FWrite FileHandle1, sTmpLine
	//FWrite FileHandle2, sTmpLine
	
	FCLOSE FileHandle1
	//FCLOSE FileHandle2
EndSub



//******************************************************************
// Procedure: GeneraComprobanteActivacion()
// Author		: C Sepulveda
// Purpose	: Generate activation voucher to be printed by FCR
//******************************************************************
Sub GeneraComprobanteActivacion
	var sTmpLine	: A100
	var FileHandle1 : N5
	var FileHandle2 : N5
	var FileName1	: A100
	var FileName2	: A100
	
	Prompt "Generando Comprobantes......"
	
	//Seteamos nombres de vouchers
	FORMAT FileName1 AS gVouchersPath, "RewCustV.txt"
	FORMAT FileName2 AS gVouchersPath, "RewStorV.txt"
	
	FOPEN FileHandle1, FileName1, WRITE
	FOPEN FileHandle2, FileName2, WRITE
	
	if FileHandle1 = 0
		errormessage "ERROR AL GENERAR VOUCHER CLIENTE"
	Endif

	if FileHandle2 = 0
		errormessage "ERROR AL GENERAR VOUCHER TIENDA"
		if FileHandle1 >0
			FCLOSE FileHandle1
		EndIf
	Endif
	
	format sTmpLine as "********************************************"
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "COMPROBANTE DE ACTIVACION STARBUCKS REWARDS "
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   "
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "FECHA : ", @DAY{02}, "-", @MONTH{02}, "-", 2000+@YEAR, "     HORA      : ", @HOUR{02}, ":", @MINUTE{02}
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "CAJA  : ", @WSID{>4}, " CHECK : ", @CKNUM{04}, " CAJERO : ", @CKEMP{09}
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "********************************************"
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   "
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "CLIENTE        : ", gMsrNombre
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "TARJETA        : ", "************", mid(gMsrTarjeta,13,4)
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "MONTO          : $ ", gLoadAmount{>10}
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "NUEVO SALDO    : $ ", gMsrSaldo{>10}
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "   "
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "  ESTE COMPROBANTE NO ES VALIDO COMO BOLETA"
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "  RECIBIRAS TU BOLETA AL MOMENTO DE REALIZAR"
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "                CADA COMPRA."
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as " "
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as "               COPIA CLIENTE"
	FWrite FileHandle1, sTmpLine
	
	format sTmpLine as "               COPIA COMERCIO"
	FWrite FileHandle2, sTmpLine
	
	format sTmpLine as ""
	FWrite FileHandle1, sTmpLine
	FWrite FileHandle2, sTmpLine
	
	FCLOSE FileHandle1
	FCLOSE FileHandle2
EndSub

//******************************************************************
// Procedure: GetNumValueReload()
// Author		: C Sepulveda
// Purpose	: Requesta numeric value for general use
//******************************************************************
Sub GetNumValueReload( ref retValue_, var prompt_ : A100, var force_ : N1)

	var kKeyPressed	: Key
	var sValue 		: A100
	var iValOK		: N1 = 0
	

	// Get DB numeric touchscreen
	Touchscreen gTouchNumeros

	While Not iValOK

		// show prompt and ask for value

		InputKey kKeyPressed, sValue, prompt_
		
		// check input...

		If kKeyPressed = @Key_Clear
		
			If force_
				// user must enter a value.
				errorMessage "Debe ingresar un valor!"
			Else
				iValOK = 1  // bail out!
				format retValue_ as ""
			EndIf

		ElseIf kKeyPressed = @Key_Enter
		
			If sValue <> ""
				iValOK = 1  // bail out!
				format retValue_ as sValue
			Else
				// user must enter a value.
				errorMessage "Debe ingresar un valor!"
			EndIf

		Else

			// user must enter a value.
			errorMessage "Debe ingresar un valor!"
		EndIf

	EndWhile
	
EndSub

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
        
        Touchscreen 13
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
    Touchscreen @ALPHASCREEN
EndSub

//*************************** MSR *****************************
// Procesa menu opciones de beneficios
// ****************************************************************
Sub mostrarBeneficios
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var opcion          : N2
	Var mensaje         : A30
	var jj          	: N2
	var texto           : A80
	Var cuantos         : N2
    var aux             : A35
    var pricelevel      : N2

	pricelevel=@slvl
	gBeneficioSeleccionado=0

	Touchscreen gTouchNumeros

	format mensaje as "Version ",gVersion," Chk: ",@cknum

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
		
	//InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	//If kKeyPressed = @KEY_ENTER
		IF opcion>0 and opcion<=gBeneficiosCant 
			gBeneficioSeleccionado=gBeneficiosCodigos[opcion]
			format gDatos as gVersion,"|",@WSID,"|",@RVC,"|",@cknum,"|",gFechaHoy,"|","SELECCIONAR_BENEFICIO","|",gMsrTarjeta,"|",gBeneficioSeleccionado
			call EnviaTransaccion
			call RecibeTransaccionBeneficiosOpcion
			IF (gCodigoRespuesta="SELECCIONAR_OK")
				call aplicarBeneficio
			Endif
		ELSE
			format texto as "Seleccion Invalida"
			IF (opcion<>0) 
				call MostrarMensaje(texto)
			ENDIF
			LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
		ENDIF

	//ElseIf kKeyPressed = @KEY_CANCEL
	//	Format opcion		As ""
    //    LOADKYBDMACRO KEY(1, 196613) //Me quedo en la pantalla actual, es error
	//EndIf
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
//Dispatcher de aplicar los codigos del beneficio
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
        //IF (ticketcompleto="N")
        //    LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, gMsrItemRef),MakeKeys(descnombre), @KEY_ENTER
        //ENDIF
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
    //gCodigoMicrosNivel=1
        
	if @RxMsg = "_timeout" //Llega la Respuestaew
           InfoMessage "Validacion","NO HAY COMUNICACION CON SERVICIO REWARDS (SIN INTERNET)"
           //gStatus=1
	else
	   Split @RxMsg, "|", gCodigoRespuesta,gDescRespuesta,gMsrSaldo,gMsrTarjeta,gMsrNombre,gMsrNivel,gMsrStars,gMsrBebFav,gMsrTipoTarjeta,gMsrStarsFaltantes,gMsrRUT,gMsrMontoAnual,gSolicitudExtranjero,gSolicitudSexo,gMsrReimprimir,gMontoReciboXOnline
	   //infomessage gCodigoRespuesta
	endif
	
endsub

//************************* MSR ******************************
//Recibe respuesta de transaccion de beneficios del servidor central
//****************************************************************
sub RecibeTransaccionBeneficios
        var mensaje: A170=""
        var jj: N2
        //gCodigoMicrosNivel=1

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
//Recibe respuesta de transaccion de beneficios de la opcion del servidor central
//****************************************************************
sub RecibeTransaccionBeneficiosOpcion
    //gCodigoMicrosNivel=1

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
//*************************** MSR ***************************
// Limpia Info Rewards
// **********************************************************
Sub ClearRewardsInfo
	RewardsCardNo 			= ""
	gMsrSaldo 				= 0
	gMsrNombre 				= ""
	gMsrNivel 				= ""
	gMsrStars 				= 0
	gMsrBebFav 				= ""
	gMsrTipoTarjeta 		= ""
	gMsrStarsFaltantes 		= 0
	gMsrRUT 				= ""
	gMsrMontoAnual 			= 0
	gSolicitudExtranjero 	= ""
	gSolicitudSexo 			= ""
	gMsrReimprimir 			= ""
	gMontoReciboXOnline 	= 0
	gBeneficiosCant 		= 0
	gOriginalCheck			= ""
	gOriginalMSRCard		= ""
	gVuelvePausaRecarga		= 0
	gMsrTarjeta				= ""
	gEnPausaRecarga			= 0
	gLoadAmount				= 0
	gMsrOk					= 0
	gEnRecarga				= 0
	gEnActivacion			= 0
	gMsrHayBeneficioDesc	= 0
	
	ClearArray gBeneficiosCodigos
	ClearArray gBeneficiosLista
	clearchkinfo
EndSub
//*************************** MSR ***************************
// Carga de infolines
// **********************************************************
Sub cargarInfoLines
    Var texto   :A30
    Var saldo   :A30
    Var i:N1
    Var cuantos: N1

    clearchkinfo

	IF (gMsrRUT="")
        savechkinfo "NO REGISTRADA"
        format texto as "Saldo: ",gMsrSaldo
        savechkinfo texto        
    ELSE
	
		savechkinfo gMsrNombre
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
	EndIf
endsub

//******************************************************************
// Procedure: Writelog()
// Author: C Sepulveda
//  
//******************************************************************
Sub Writelog(var sFileName_ : A100, var sInfo_ : A1000, var iAppend_ : N1, \
			var iAddTimeStamp_ : N1)

	var fn			: N5  // file handle
	var sTmpInfo	: A1100

	format sFileName_ as sFileName_, "rewards_",(@YEAR + 2000) {04}, @MONTH{02}, @DAY{02}, ".log"
	
	If iAppend_
		// append info to log file
		Fopen fn, sFileName_, append
	Else
		// overwrite existing info
		Fopen fn, sFileName_, write
	EndIf

	If fn <> 0
		
		If iAddTimeStamp_
			// add a time stamp to the record				   
			Format sTmpInfo as @MONTH{02}, "/", @DAY{02}, "/", (@YEAR + 2000) {04}, \
							   	" - ", @HOUR{02}, ":", @MINUTE{02}, ":", @SECOND{02}, \
							   	" | WSID: ", @WSID, " | CHK: ", \
							   	@CKNUM, " | EMP: ", @TREMP, " -> ", sInfo_

		Else
			// only log passed info
			format sTmpInfo as sInfo_

		EndIf

		// write info to log file
		FWrite fn, sTmpInfo

		// close handle to file
		Fclose fn
	Else
		// error! Warn user
		errorMessage "Could not log information in ", sFileName_

	EndIf

EndSub

//**************************************************
// Obtiene fecha de negocio desde BD
//**************************************************
Sub sqlDiaDeNegocio(Ref fecha)

	Var dbok     	: N1
	Var comando     : A300= ""
	Var resultado	: A20= ""
	Var error		: A200= ""
    var aux 		: A10=""
        
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