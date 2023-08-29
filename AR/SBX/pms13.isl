var ISLVersion: A30 = "Starbucks Labels V.1.0"

//*****************************************************
// Version Control
// v0.1 (31-08-2017) C. Sepulveda
// - Initial Release
//
// v1.0 (13-09-2019) C. Sepulveda
// - Includes controls to operate in Metrobar Format
//
//*****************************************************

var ID_FALSE  				: N1  = 0
var ID_TRUE   				: N1  = 1

var TRUE					: N1 = 1
var FALSE					: N1 = 0

// Detail Status Bits
var DTL_VOID	  			: N2 =  5
var DTL_ERROR_CORRECT 		: N2 = 12
var isPrinted				: N1

UseISLTimeOuts
Retainglobalvar

event INQ : 1
	call print_label()
endevent

event final_tender
	if isPrinted = FALSE
		call print_label()
	EndIf
	
	isPrinted=FALSE
endevent

event rxmsg : WRONG_MESSAGE
		Prompt "Error en etiquetas"
		exitwitherror "Error al generar etiquetas"
endevent

event rxmsg : PRINT_LABELS
		Prompt "Error en etiquetas"
		errormessage "Respuesta OK"
endEvent

event rxmsg : _TIMEOUT
		Prompt "Error en etiquetas"
		errormessage "Error al generar etiqueta"
endEvent

event rxmsg : LABEL_OK
		isPrinted = TRUE
		Prompt "Etiqueta(s) Generada(s)"
endEvent

sub Print_Label()
	var DT_MENU_ITEM      		: A1 = "M"
	
	var MI_Qty[@Numdtlt]	 		:	N5		// Menu Item Grouped Quantities
	var MI_Name[@Numdtlt]	 		:	A24		// Menu Item Grouped Names
	var MI_ObjNum[@Numdtlt]	 	: N7		// Menu Item Object Number
	var MI_FamGrp[@Numdtlt]		: N10		// Menu Item Fam Group
	var MI_Conds[@Numdtlt]		: A100	// Condiments
	var MI_MenuLevel[@Numdtlt]  : N3
	var MI_Count			 				: N5 = 0	// Menu Item Counter
	var x											:N3
	var y											:N3
	var z											:N3
	var sTmp 									:A100
	var sMessage							: A5000
	var sHeaderInfo						: A100
		
	//Structure for header will be:
	// "H" as identifier
	// Workstation ID
	// RVC number
	// Check Number
	// RVC Name
	// Customer Name
	// Date
	// Time
	
	
	format sHeaderInfo as "H;", @WSID, ";", @RVC, ";", @CkNum, ";", @RVCName, ";", trim(@ckid)
	
	format sHeaderInfo as sHeaderInfo, ";", @DAY{02}, "-", @MONTH{02}, "-", (@YEAR + 2000){04} 
	
	format sHeaderInfo as sHeaderInfo, ";", @HOUR{02}, ":", @MINUTE{02}, ":", @SECOND{02} 
	
	MI_Count = 0
	
	For x = 1 to @NUMDTLT
		@PREFIX_DTL_NAME = 0
		If @Dtl_Type[x] = DT_MENU_ITEM 
			@PREFIX_DTL_NAME = 1
			if not @dtl_is_void[x] and Not bit(@Dtl_status[x],DTL_VOID) and Not bit(@Dtl_status[x],DTL_ERROR_CORRECT)
				if not @dtl_is_cond[x]
					MI_Count = MI_Count + 1
					MI_ObjNum[MI_Count] = @Dtl_Object[x]				
					MI_Qty[MI_Count]  = @Dtl_Qty[x]
					MI_Name[MI_Count] = trim(@Dtl_Name[x])
					MI_FamGrp[MI_Count] = @DTL_FAMGRP_OBJNUM[x]
					MI_MenuLevel[MI_Count] = @dtl_mlvl[x]
					//infomessage MI_Name[MI_Count]
					format MI_Conds[MI_Count] as ""
				else
					format MI_Conds[MI_Count] as MI_Conds[MI_Count], "~", trim(@Dtl_Name[x])
				EndIf
				
			EndIf
			
			//if not @dtl_is_void[x] and Not bit(@Dtl_status[x],DTL_VOID) and Not bit(@Dtl_status[x],DTL_ERROR_CORRECT) and @dtl_is_cond[x]
				
			//EndIf
		endif
	endfor
	
	format sMessage as ""
	
	if MI_Count > 0
		//Here we will Add Total Items
		format sMessage as "^", sHeaderInfo, ";", MI_Count, "^"
		
		for y=1 to MI_Count
			for z = 1 to MI_Qty[MI_Count]
				format sMessage as sMessage, "I;", y, ";", MI_Count, ";", MI_ObjNum[y], \
													";", MI_Name[y], MI_Conds[y], ";", MI_FamGrp[y], "^" //, MI_MenuLevel[MI_Count], "^"
			EndFor
		EndFor

		MI_Count=0
		txmsg "PRINT_LABELS", sMessage
		
		waitforrxmsg
		
	endif
EndSub