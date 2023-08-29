@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts

//version 0.1 DRIVETHRU SBUX 


Var dll_handle							: N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	

Var PATH_TO_PRT_DRIVER						:A100				
Var gblPRTDrv 								:N12
Var PCWS_TYPE									:N1 = 1	// Type number for PCWS
Var PPC55A_TYPE 					 			:N1 = 2 // Type number for Workstation mTablet
Var WS4_TYPE									:N1 = 3	// Type number for Workstation 4
Var WS5_TYPE									:N1 = 3	// Type number for Workstation 5
Var gbliWSType				 					:N1			// To store the current Workstation type
Var gbliRESMajVer								:N2			// To store the current RES major version
Var gbliRESMinVer								:N2			// To store the current RES minor version

Var gblsCustName : A11

//************************************************************

Event Inq : 1
	Call consulta_nombre(gblsCustName)
EndEvent

//************************************************************
Sub consulta_nombre(Ref custName_)

	Var sAux	: A20
	Var iOk		: N1 = 0
		
	Touchscreen @ALPHASCREEN
	
	While iOk = 0
	
		Window 1,50, "Ingresar nombre"
			Display 1,1, "Nombre:    "
			DisplayInput 1,25, sAux{20}, "(max. 11 carac.)"
		WindowEdit
	
		
		If Len(sAux) > 11
			ErrorMessage "El nombre no puede contener mas de 11 caracteres"
		Else
			Format custName_ As sAux
			iOk = 1
		EndIf
	
	EndWhile
	
	WindowClose
       
EndSub
	
//************************************************************
//*********************** DRIVETHRU  **************************
Event inq: 2
	Call consulta_nombre(gblsCustName)
    call capturadrivethru
endevent


//************************************************************
//**************** DRIVETHRU // SEND THRUE *******************
Event inq: 3
	Call consulta_nombre(gblsCustName)
    Call capturadrivethru
	Call llamatender
	
	
endevent

//****************************************************************
//************************* Captura datos ************************
sub capturadrivethru
    var i: N4 = 0
    var items: A1500 = ""
	var gDatos : A2000 = ""
  
	For i = 1 to @NUMDTLT[i] 
        If @DTL_TYPE[i] = "M" AND @DTL_IS_VOID[i] = 0
            format items as items,@DTL_OBJECT[i],"|",@Dtl_Qty[i],"|",@Dtl_Name[i],"|",@Dtl_Plvl[i],"|",@Dtl_is_cond[i],"|",@Dtl_Is_Combo[i],"|"	
		EndIf		
    EndFor
	
	format gDatos as gblsCustName,"&",items
	
	TXMSG gDatos	
	GetRXMsg "Imprimiendo..." 
	
endsub

//****************************************************************
//************************* Llama a tender ***********************

Sub llamatender

	LoadKybdMacro  Key (9, 600)  //Llama al tender 600 Send Thrue

	
endsub