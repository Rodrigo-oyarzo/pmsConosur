// *************************************************************************//
//                     MICROS RES3000 INTERFACE ARAMARK                     //
//                         Current Version: 1.0.5                           //
// *************************************************************************//
// *************************************************************************//

// =========================================================================
// History
// =========================================================================
//
//
// 29/12/2009 - v1.0.5 * Luis Vaccaro * 
// - Added support for DISCOUNT class customers
//
// =========================================================================
// TO DO
//
// =========================================================================

// ------------------------------------------------------------- //
///////////////////////////////////////////////////////////////////
//			The Following code is not to be modified!			 //
///////////////////////////////////////////////////////////////////
// ------------------------------------------------------------- //

// SIM OPTIONS
RetainGlobalVar
SetSignOnLeft 

// --------------------------------------------------------- //
///////////////////////// Constants ///////////////////////////
// --------------------------------------------------------- //

Var IFC_VERSION							: A10 = "1.0.5"
                        				
Var EXECUTION_OK 						: A9 = 1
Var EXECUTION_ERROR						: A9 = -100
Var CONNECTION_ERROR					: A9 = -101
Var PARAM_ERROR 						: A9 = -102
                                    	
// Check detail types [@dtl_type]   	
Var DT_CHECK_INFO     					: A1 = "I"
Var DT_MENU_ITEM      					: A1 = "M"
Var DT_DISCOUNT       					: A1 = "D"
Var DT_SERVICE_CHARGE 					: A1 = "S"
Var DT_TENDER         					: A1 = "T"
Var DT_REFERENCE      					: A1 = "R"
Var DT_CA_DETAIL      					: A1 = "C"
                                    	
// Detail Status bits               	                                 	
Var DTL_ITEM_SHARED	  					: N2 = 14
                            			
// Detail TypeDef bits      			                        			
Var DTL_ITEM_PRICE_PRESET				: N2 = 1
Var DTL_ITEM_IS_WEIGHED					: N2 = 28
                            			
                            			
// Key types and codes      			                          			
Var KEY_TYPE_FUNCTION					: N9 = 1
Var KEY_TYPE_TRANSACTION				: N9 = 1	
Var KEY_TYPE_MENU_ITEM					: N9 = 3
Var KEY_TYPE_MENU_ITEM_KEYBOARD 		: N9 = 4	
Var KEY_TYPE_DISCOUNT 					: N9 = 5
Var KEY_TYPE_DISCOUNT_KEYBOARD 			: N9 = 6
Var KEY_TYPE_MENU_ITEM_SLU 				: N9 = 17
Var KEY_TYPE_MACRO 						: N9 = 23
Var KEY_TYPE_TENDER_SEQ 				: N9 = 9
Var KEY_TYPE_TENDER_KEY 				: N9 = 10
Var KEY_TYPE_TENDER_SLU 				: N9 = 19

Var KEY_CODE_CANCEL_TRANS				: N9 = 458755
Var KEY_CODE_MAIN_LEVEL_1 				: N9 = 458757	
Var KEY_CODE_MAIN_LEVEL_2 				: N9 = 458758	
Var KEY_CODE_MAIN_LEVEL_3 				: N9 = 458750	
Var KEY_CODE_MAIN_LEVEL_4 				: N9 = 458760	

Var KEY_CODE_ICARE_MEAL_1 				: N9 = 901	
Var KEY_CODE_ICARE_MEAL_2 				: N9 = 902	
Var KEY_CODE_ICARE_MEAL_3 				: N9 = 903	
Var KEY_CODE_ICARE_SIGNATURE 			: N9 = 952	

Var KEY_CODE_TENDER_MEAL 				: N9 = 399	
Var KEY_CODE_TENDER_SIGNATURE 			: N9 = 454	
Var KEY_CODE_TENDER_SLU_SIGNATURE 		: N9 = 2

Var SIGNATURE_SCREEN_CODE 				: N9 = 100
// filenames                    	
Var PATH_TO_WS4SYSTEM_DRIVER 			: A100
Var ERROR_LOG_FILE_NAME					: A100
Var PATH_TO_DB_DRIVER					: A100
Var PATH_TO_MEAL_IMPORTER_DRIVER 		: A100

// Other                            	                                  	
Var FALSE								: N1 = 0
Var TRUE								: N1 = Not FALSE
                                    	
Var CHAR_DOUBLE_QUOTE					: N3 = 34	// Ascii value for the double quote character
Var PCWS_TYPE							: N1 = 1	// Type number for PCWS
Var WS4_TYPE							: N1 = 2	// Type number for Workstation 4
Var WS5_TYPE							: N1 = 3	// Type number for Workstation 5
Var INV_MANAGEMENT_SIM_PRIVILEGE		: N1 = 4	// Sim privilege option bit for Invoice Management procedures 
Var MAX_STRING_LEN 						: N9 = 70
Var MAX_SI_NUM 							: N9 = 8 	// Max Micros Sales Itemizers
Var DB_REC_SEPARATOR					: A1 = ";"  // Field separator for returned DB records


// Aramark
Var MEAL1_ITEMIZER 						: N1 = 1
Var MEAL2_ITEMIZER 						: N1 = 2
Var MEAL3_ITEMIZER 						: N1 = 3
Var SIGNATURE_ITEMIZER 					: N1 = 4

Var INVALID_MEAL 						: N1 = -1
Var NO_ITEMIZERS 						: N1 = -2
Var MULTIPLE_ITEMIZERS 					: N1 = -3
Var XLS_FILE_NAME 						: A512 = "LISTADO IMPORTACION COMEDOR VALES.xls"

Var CUST_CLASS_CREDIT 					: A2 = "C"
Var CUST_CLASS_SIGNATURE				: A2 = "F"
Var CUST_CLASS_DISCOUNT					: A2 = "D"
Var CUST_CLASS_GENERIC 					: A2 = "G"



////////////////////////// IFC Global vars /////////////////////////////

Var gbliWSType				 			: N1		// To store the current Workstation type
Var gbliRESMajVer						: N2		// To store the current RES major version
Var gbliRESMinVer						: N2		// To store the current RES minor version   
   
// Driver handles (DLLs)
Var gblhDB								: N12
Var gblhWS4System						: N12
Var gblhMealImporter 					: N12
   
Var gblsCardId 							: A16
Var gblsCustomerDoc 					: A16
Var gblsPayrollId 						: A16
Var gblsCustomerName 					: A32
Var gblsCustomerClass 					: A2
Var gblsConsumerPayrollId 				: A32

Var gblsInitialDate 					: A16
Var gblsExpirationDate 					: A16
Var gbliDiscObjNum 						: N9

//Var gblsMicrosCustId 					: A16

Var gbliSelectedMenu 					: N9
Var gbliCheckItemQty 					: N9
Var gbliConsumeQty						: N9
Var gblsStoreId 						: A16 = ""
Var gblsMeal1Title 						: A20
Var gblsMeal2Title 						: A20
Var gblsMeal3Title 						: A20
Var gblsRestName 						: A100 = ""


////////////////////////////////////////////////////////////////
//							EVENTS							  // 
////////////////////////////////////////////////////////////////

Event init

	// get client platform
	Call setWorkstationType()

	// set file paths for this client
	Call setFilePaths()

	// Initialize ODDB driver
	Call initDBdrv()

	// Initialize system-calls driver
	Call initWS4SystemDrv()
	
	// Initialize Meal Importer driver
	//Call initMealImporterDrv()

	// reset global vars
	Call initGlobalVars()	
	
	//initializate meal titles
	Call GetMealsTitles()

EndEvent


Event trans_cncl
	
	// reset global vars
	Call initGlobalVars()

EndEvent


Event srvc_total: *
	
	// reset global vars
	Call initGlobalVars()

EndEvent


Event final_tender							
EndEvent


Event signin
EndEvent


Event signout

	// reset global vars
	Call initGlobalVars()

EndEvent


Event exit

	Call UnloadDBdrv()
	Call unloadWS4SystemDrv()
	Call unloadMealImporterDrv()

EndEvent


////////////////////////////////////////////////////////////////
//						INQ EVENTS							  //
////////////////////////////////////////////////////////////////



Event Inq : 1 //validar empleado y mostrar créditos disponibles

	Call GetCustomerCredits()

EndEvent

Event Inq : 2 //validar mezcla / existencia de itemizers en cuenta
	
	Call VerifyValidCheckItems()

EndEvent

Event Inq : 3 //validar todo sin consumir

	Call VerifyCustomerItemAvailability()

EndEvent

Event Inq : 4 //validar todo y consumir

	Call ProcessMealConsumption()

EndEvent

Event Inq : 5 //Importar planilla

	Call ImportCustomerMeals()

EndEvent

Event Inq : 6 //Validar todo y consumir descuento especial

	Call ProcessMealConsumptionEspecial()

EndEvent


///////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                       //
//========================================= INTERFACE FUNCTIONS =========================================//
//                                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//******************************************************************
// Procedure: 	ProcessMealConsumption()
// Author:		Luis Vaccaro 	
//******************************************************************
Sub ProcessMealConsumption()
	
	Var descuentoespecial		: N1 = FALSE
	Var availableMeal1 		: N9
	Var availableMeal2 		: N9
	Var availableMeal3 		: N9
	Var consumedMeal1 		: N9 = 0
	Var consumedMeal2 		: N9 = 0
	Var consumedMeal3 		: N9 = 0
	Var itemsQty 			: N9
	Var sStoreId 			: A8
	Var sTemp 				: A512
	
	Call VerifyCustomerItemAvailability()
        ErrorMessage "Nombre: ",gblsCustomerName
	
	If(gbliConsumeQty > 0)

		If 	(gblsCustomerClass = CUST_CLASS_DISCOUNT)
			LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gbliDiscObjNum), MakeKeys(gblsCustomerName), @KEY_ENTER
			LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, 900060)
		
		Elseif 	(gblsCustomerClass <> CUST_CLASS_SIGNATURE)
		
			If(gbliSelectedMenu = MEAL1_ITEMIZER)
				consumedMeal1 = gbliConsumeQty
			
			Elseif(gbliSelectedMenu = MEAL2_ITEMIZER)
				consumedMeal2 = gbliConsumeQty
			
			Elseif(gbliSelectedMenu = MEAL3_ITEMIZER)
				consumedMeal3 = gbliConsumeQty
				
			Endif	
		
			//if we have reached this point, everything is OK, so consume the item freely
			Call UpdateCustomerMeal(gblsCardId, gblsCustomerDoc, gblsPayrollId, consumedMeal1, consumedMeal2, consumedMeal3)
		
			//launch 0.0 Tender with employee obj number
			LoadKybdMacro MakeKeys("0.0"), Key(KEY_TYPE_TENDER_SEQ, KEY_CODE_TENDER_MEAL), MakeKeys(gblsConsumerPayrollId), @KEY_ENTER
		
		
			//launch icare macro
			Format sTemp As @TTLDUE
			 
			If(gbliSelectedMenu = MEAL1_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_MEAL_1) 
			
			Elseif(gbliSelectedMenu = MEAL2_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_MEAL_2) 
			
			Elseif(gbliSelectedMenu = MEAL3_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_MEAL_3)
			
			Elseif(gbliSelectedMenu = SIGNATURE_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_SIGNATURE)//, Key(KEY_TYPE_TENDER_SEQ, KEY_CODE_ICARE_SIGNATURE), MakeKeys(gblsConsumerPayrollId), @KEY_ENTER
				LoadKybdMacro Key(KEY_TYPE_TENDER_SLU, KEY_CODE_TENDER_SLU_SIGNATURE)
				
			Endif
		
		Else //it's a signatured customer
						
		Endif
		
		Call initGlobalVars()

	Endif

EndSub


//******************************************************************
// Procedure: 	ProcessMealConsumptionEspecial()
// Author:		Luis Vaccaro 	
//******************************************************************
Sub ProcessMealConsumptionEspecial()
	
	Var descuentoespecial		: N1 = TRUE
	Var availableMeal1 		: N9
	Var availableMeal2 		: N9
	Var availableMeal3 		: N9
	Var consumedMeal1 		: N9 = 0
	Var consumedMeal2 		: N9 = 0
	Var consumedMeal3 		: N9 = 0
	Var itemsQty 			: N9
	Var sStoreId 			: A8
	Var sTemp 				: A512
	
	Call VerifyCustomerItemAvailability()
        ErrorMessage "Nombre: ",gblsCustomerName
	
	If(gbliConsumeQty > 0)

		If 	(gblsCustomerClass = CUST_CLASS_DISCOUNT)
			LoadKybdMacro Key(KEY_TYPE_DISCOUNT, gbliDiscObjNum), MakeKeys(gblsCustomerName), @KEY_ENTER
			LoadKybdMacro Key(KEY_TYPE_MENU_ITEM, 900060)
		
		Elseif 	(gblsCustomerClass <> CUST_CLASS_SIGNATURE)
		
			If(gbliSelectedMenu = MEAL1_ITEMIZER)
				consumedMeal1 = gbliConsumeQty
			
			Elseif(gbliSelectedMenu = MEAL2_ITEMIZER)
				consumedMeal2 = gbliConsumeQty
			
			Elseif(gbliSelectedMenu = MEAL3_ITEMIZER)
				consumedMeal3 = gbliConsumeQty
				
			Endif	
		
			//if we have reached this point, everything is OK, so consume the item freely
			Call UpdateCustomerMeal(gblsCardId, gblsCustomerDoc, gblsPayrollId, consumedMeal1, consumedMeal2, consumedMeal3)
		
			//launch 0.0 Tender with employee obj number
			LoadKybdMacro MakeKeys("0.0"), Key(KEY_TYPE_TENDER_SEQ, KEY_CODE_TENDER_MEAL), MakeKeys(gblsConsumerPayrollId), @KEY_ENTER
		
		
			//launch icare macro
			Format sTemp As @TTLDUE
			 
			If(gbliSelectedMenu = MEAL1_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_MEAL_1) 
			
			Elseif(gbliSelectedMenu = MEAL2_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_MEAL_2) 
			
			Elseif(gbliSelectedMenu = MEAL3_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_MEAL_3)
			
			Elseif(gbliSelectedMenu = SIGNATURE_ITEMIZER)
				LoadKybdMacro MakeKeys(sTemp), Key(KEY_TYPE_MACRO, KEY_CODE_ICARE_SIGNATURE)//, Key(KEY_TYPE_TENDER_SEQ, KEY_CODE_ICARE_SIGNATURE), MakeKeys(gblsConsumerPayrollId), @KEY_ENTER
				LoadKybdMacro Key(KEY_TYPE_TENDER_SLU, KEY_CODE_TENDER_SLU_SIGNATURE)
				
			Endif
		
		Else //it's a signatured customer
						
		Endif
		
		Call initGlobalVars()

	Endif

EndSub



//******************************************************************
// Procedure: 	GetCustomerCredits()
// Author:		Luis Vaccaro 	
//******************************************************************
Sub GetCustomerCredits()
	
	Var isValid 			: N1 = FALSE
	Var availableMeal1 		: N9
	Var availableMeal2 		: N9
	Var availableMeal3 		: N9
	Var totalMeal1 			: N9
	Var totalMeal2 			: N9
	Var totalMeal3 			: N9

	Call initGlobalVars()

	If(gblsCardId = "" And  gblsCustomerDoc = "" And gblsPayrollId = "")
		Call AskForGuestId(gblsCardId, gblsCustomerDoc, gblsPayrollId)
	Endif

	Call VerifyCustomerExistance(gblsCardId, gblsCustomerDoc, gblsPayrollId, gblsCustomerName, gblsCustomerClass, gbliDiscObjNum, isValid)
	
	If(isValid)
			
		Call GetAvailableMeals(gblsCardId, gblsCustomerDoc, gblsPayrollId, totalMeal1, totalMeal2, totalMeal3, availableMeal1, availableMeal2, availableMeal3, gblsInitialDate, gblsExpirationDate) 
		
		Window 11, 30, "Consumicion Disponible"
		
			DisplayInverse 2, 1, gblsCustomerName {=30}
			
			DisplayInverse 4, 1, "Clase  :"
			DisplayInverse 5, 1, "Tarjeta:"
			DisplayInverse 6, 1, "Dni    :"
			DisplayInverse 7, 1, "Legajo :"
			
			Display 8, 1, "------------------------------"
			
			DisplayInverse 9, 1, gblsMeal1Title
			DisplayInverse 10, 1, gblsMeal3Title
			DisplayInverse 11, 1, gblsMeal2Title
			
			Display 4, 21, gblsCustomerClass
			Display 5, 21, gblsCardId
			Display 6, 21, gblsCustomerDoc
			Display 7, 21, gblsPayrollId

			Display 9, 21, availableMeal1
			Display 10, 21, availableMeal2
			Display 11, 21, availableMeal3
						
			WaitForConfirm "Imprimir?"

		WindowClose
	
	
		If(@INPUTSTATUS)		
			Call PrintVoucher(gblsCardId, gblsCustomerDoc, gblsPayrollId, gblsCustomerName, availableMeal1, availableMeal2, availableMeal3, totalMeal1, totalMeal2, totalMeal3, gblsInitialDate, gblsExpirationDate)
	
		Endif
	 	
	Else	
		ErrorMessage "El cliente no existe."
		Call initGlobalVars()
		ExitCancel

	Endif

EndSub

//******************************************************************
// Procedure: 	VerifyValidCheckItems()
// Author:		Luis Vaccaro 	
//******************************************************************
Sub VerifyValidCheckItems()
	
	Call ValidateCheckItems(gbliSelectedMenu, gbliCheckItemQty)
		
	If(gbliSelectedMenu = NO_ITEMIZERS)
		ErrorMessage "La cuenta no tiene items de canje."
		ExitCancel
			
	ElseIf(gbliSelectedMenu = MULTIPLE_ITEMIZERS)
		ErrorMessage "La cuenta tiene tipos de items mezclados."
		ExitCancel
	
	Endif
		
EndSub

//******************************************************************
// Procedure: 	VerifyCustomerItemAvailability()
// Author:		Luis Vaccaro 	
//******************************************************************
Sub VerifyCustomerItemAvailability()
	
	Var cardId 				: A16 = ""
	Var custId 				: A16 = ""
	Var payrollId 			: A16 = ""
	Var custName 			: A32 = ""
	Var custClass 			: A2  = ""
	Var isValid 			: N1  = FALSE
	Var availableMeal1 		: N9
	Var availableMeal2 		: N9
	Var availableMeal3 		: N9
	Var totalMeal1 			: N9
	Var totalMeal2 			: N9
	Var totalMeal3 			: N9
	
	//validate check items
	//Call VerifyValidCheckItems()
		
	//Check is valid, continue with customer validations
	If(gblsCardId = "" And  gblsCustomerDoc = "" And gblsPayrollId = "")
		Call AskForGuestId(gblsCardId, gblsCustomerDoc, gblsPayrollId)
	
	Endif
	
	//Get customer data
	Call VerifyCustomerExistance(gblsCardId, gblsCustomerDoc, gblsPayrollId, gblsCustomerName, gblsCustomerClass, gbliDiscObjNum, isValid)
	
	gblsConsumerPayrollId = gblsPayrollId
	//ask for particular card
	If(gblsCustomerClass = CUST_CLASS_GENERIC)
		
		Call AskForGuestId(cardId, custId, payrollId)
		
		//Get customer data
		Call VerifyCustomerExistance(cardId, custId, payrollId, custName, custClass, gbliDiscObjNum, isValid)
		
		If(isValid And custClass <> CUST_CLASS_GENERIC)
			gblsConsumerPayrollId = payrollId	
			
		Else
			ErrorMessage "El cliente asociado es generico o inexistente." 
			Call initGlobalVars()
			ExitCancel
			
		Endif
		
	Elseif(gblsCustomerClass = CUST_CLASS_SIGNATURE)	
		gbliConsumeQty 		= 1
		gbliSelectedMenu 	= SIGNATURE_ITEMIZER 
		Return

	Elseif(gblsCustomerClass = CUST_CLASS_DISCOUNT)	
		gbliConsumeQty 		= 1
		gbliSelectedMenu 	= NO_ITEMIZERS 
		Return
	
	Endif
	
	If(isValid)
		
		//Get customer available meals
		Call GetAvailableMeals(gblsCardId, gblsCustomerDoc, gblsPayrollId, totalMeal1, totalMeal2, totalMeal3, availableMeal1, availableMeal2, availableMeal3, gblsInitialDate, gblsExpirationDate) 

		//test availabilty
		If((gbliSelectedMenu = MEAL1_ITEMIZER And availableMeal1 >= gbliCheckItemQty) Or \
			 (gbliSelectedMenu = MEAL2_ITEMIZER And availableMeal2 >= gbliCheckItemQty) Or \
			 (gbliSelectedMenu = MEAL3_ITEMIZER And availableMeal3 >= gbliCheckItemQty))
			
			gbliConsumeQty = gbliCheckItemQty
		
		Else
			gbliConsumeQty = 0
			ErrorMessage "El cliente no tiene creditos disponibles." 
			Call initGlobalVars()
			ExitCancel
							
		Endif			
		
	Else	
		ErrorMessage "El cliente no existe." 
		Call initGlobalVars()
		ExitCancel
	
	Endif
	
EndSub

//******************************************************************
// Procedure: 	ImportCustomerMeals()
// Author: 		Luis Vaccaro
// Purpose: 	Import xls customer meals file into DB
// Parameters:
//	 -
//******************************************************************
Sub ImportCustomerMeals()
		
	Var errorCode 	: N9 = 0

	If @EMPLOPT[INV_MANAGEMENT_SIM_PRIVILEGE] 

		Prompt "Importando datos..."
	
		If gbliRESMinVer >= 2 or gbliRESMajVer >= 3
			DLLCall_CDECL gblhMealImporter, UpdateMealWorksheet(XLS_FILE_NAME, Ref errorCode)
		Else
			DLLCall gblhMealImporter, UpdateMealWorksheet(XLS_FILE_NAME, Ref errorCode)
		Endif
		
		If(errorCode = 1)
			InfoMessage "Importacion finalizada." 
			
		Else
			ErrorMessage "Error al importar tabla: #", errorCode 
		
		Endif
	
	Else
		// signed-in user doesn't have enough privileges.
		ErrorMessage "Contacte a su supervisor."

	Endif
	
EndSub



///////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                       //
//=========================================== UTIL FUNCTIONS ============================================//
//                                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////


//******************************************************************
// Procedure: setWorkstationType()
// Author: Al Vidal
// Purpose: sets the SAROPS workstation type (Win32 | WinCE)
// Parameters:
//
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
// Procedure: 	setFilePaths()
// Author: 		Luis Vaccaro
// Purpose: 	Sets file paths used by this script, depending on the
//				type of WS (Win32 | WS4) running it
// Parameters:
//
//******************************************************************
Sub setFilePaths()
		
	// general paths
	If gbliWSType = PCWS_TYPE	
		// This is a Win32 client
		Format PATH_TO_DB_DRIVER 			As "..\bin\MDSSysUtilsProxy.dll"
		Format PATH_TO_MEAL_IMPORTER_DRIVER As "..\bin\CustMealImporterDll.dll"
		Format ERROR_LOG_FILE_NAME 			As "CustomerMeal.log"

	Else 
		// This is a WS4 client
		Format PATH_TO_DB_DRIVER 			As "MDSSysUtilsProxy.dll"
		Format PATH_TO_WS4SYSTEM_DRIVER 	As "\CF\micros\bin\WS4System.dll"
		Format ERROR_LOG_FILE_NAME 			As "\cf\micros\etc\CustomerMeal.txt"	

	Endif
	
EndSub

//******************************************************************
// Procedure: logInfo()
// Author: Alex Vidal
// Purpose: Logs information passed as a parameter to a specified
//			log file
// Parameters:
//	- sFileName_ = Log file name
//	- sInfo_ = Information to log
//	- iAppend_ = If TRUE, it will append the "sInfo_" to the
//					 specified "sFileName_". If FALSE, it will
//				 	 overwrite existing data
//	- iAddTimeStamp_ = If TRUE, adds a timestamp for the logged
//					  record.
//  
//******************************************************************
Sub logInfo(Var sFileName_ : A100, Var sInfo_ : A3000, Var iAppend_ : N1, Var iAddTimeStamp_ : N1)

	Var fn			: N5  // file handle
	Var sTmpInfo	: A2500

	
	If iAppend_
		// append info to log file
		FOpen fn, sFileName_, append
	Else
		// overwrite existing info
		FOpen fn, sFileName_, write
	Endif
	

	If fn <> 0
		
		If iAddTimeStamp_
			// add a time stamp to the record
			Format sTmpInfo As @MONTH{02}, "/", @DAY{02}, "/", (@YEAR + 2000){04}, 		\
							   " - ", @HOUR{02}, ":", @MINUTE{02}, ":", @SECOND{02}, 	\
							   " | FIP: ", IFC_VERSION, " | WSID: ", @WSID, " | Emp: ", \
							   @CKEMP, " | Chk: ", @CKNUM, " -> ", sInfo_
		Else
			// only log passed info
			Format sTmpInfo As "WSID: ", @WSID, " -> ", sInfo_

		Endif

		// write info to log file
		FWrite fn, sTmpInfo

		// close handle to file
		FClose fn
	Else
		// error! Warn user
		ErrorMessage "No se pudo guardar info en ", sFileName_

	EndIf

EndSub

//******************************************************************
// Procedure: 	initWS4SystemDrv()
// Author: 		Al Vidal
// Modified by: Luis Vaccaro
// Purpose: 	Initializes the WS4 system driver
// Parameters:
//******************************************************************
//Luis 08-2009
Sub initWS4SystemDrv()

	If (gbliWSType = PCWS_TYPE)
		// This function is not available for Win 32 clients
		Return
	EndIf

	If ( gblhWS4System = 0 )
        DLLLoad gblhWS4System, PATH_TO_WS4SYSTEM_DRIVER
    EndIf

	If gblhWS4System = 0
        ErrorMessage "Failed to load WS4System driver!"
		call logInfo(ERROR_LOG_FILE_NAME,"Failed to load WS4System driver",TRUE,TRUE)
    EndIf
	
EndSub

//******************************************************************
// Procedure: 	unloadWS4SystemDrv()
// Author: 		Al Vidal
// Modified by: Luis Vaccaro	
// Purpose: Unloads the WS4System driver
// Parameters:
//******************************************************************
Sub unloadWS4SystemDrv()

	If (gbliWSType = PCWS_TYPE)
		// This function is not available for Win 32 clients
		Return
	EndIf

	If gblhWS4System <> 0

		// unload Dll from memory
		DLLFree gblhWS4System
		gblhWS4System = 0
	
	EndIf

EndSub

//******************************************************************
// Procedure: initDBdrv()
// Author: Alex Vidal
// Purpose: Initializes the dat abase driver
// Parameters:
//	- 
//
//******************************************************************
Sub initDBdrv()

	Var sSQLErr	: A500 = ""


	If ( gblhDB = 0 )
			DLLLoad gblhDB, PATH_TO_DB_DRIVER
		EndIf
    EndIf

	If gblhDB = 0
		call logInfo(ERROR_LOG_FILE_NAME,"Failed to load DB driver",TRUE,TRUE)
		ErrorMessage "Falla al cargar driver de BD!"
		Return  // bail out!
    EndIf

	// start up driver!
	Call sqlInitConnection()
	Call sqlGetLastErrorString(sSQLErr)
	
	If sSQLErr <> ""
		Call logInfo(ERROR_LOG_FILE_NAME,"Failed to initialize connection to DB",TRUE,TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
		ErrorMessage "Falla al inicializar conexion a BD!"
	EndIf

EndSub

//******************************************************************
// Procedure: UnloadDBdrv()
// Author: Al Vidal
// Purpose: Unloads the database driver
// Parameters:
//	- 
//
//******************************************************************
Sub UnloadDBdrv()

	// stop driver. (Disconnect from DB)

	If gblhDB <> 0

		Call sqlCloseConnection()

		// unload Dll from memory
		DLLFree gblhDB
		gblhDB = 0
	
	EndIf

EndSub

//******************************************************************
// Procedure: 	initMealImporterDrv()
// Author: 		Luis Vaccaro
// Purpose: 	Initializes Meal Importer Dll
// Parameters:
//******************************************************************
Sub initMealImporterDrv()

	If(gbliWSType <> PCWS_TYPE)
		// This function is not available for Win CE clients
		gblhMealImporter = 0
		Return
	EndIf

	If(gblhMealImporter = 0)
        DLLLoad gblhMealImporter, PATH_TO_MEAL_IMPORTER_DRIVER
    EndIf

	If(gblhMealImporter = 0)
        ErrorMessage "Failed to load Meal Importer driver!"
		Call logInfo(ERROR_LOG_FILE_NAME, "Failed to load Meal Importer driver", TRUE, TRUE)
    EndIf
	
EndSub

//******************************************************************
// Procedure: 	unloadMealImporterDrv()
// Author: 		Luis Vaccaro
// Purpose: 	Unloads Meal Importer Dll
// Parameters:
//******************************************************************
Sub unloadMealImporterDrv()

	If(gbliWSType <> PCWS_TYPE)
		// This function is not available for Win CE clients
		Return
	EndIf

	If(gblhMealImporter <> 0)
		// unload Dll from memory
		DLLFree gblhMealImporter
		gblhMealImporter = 0
    EndIf
	
EndSub

//******************************************************************
// Procedure: 	getBizDate()
// Author: 		Luis Vaccaro
// Purpose: 	Returns last business date (ISO FORMAT YYYYMMDD)
// Parameters:
//	- sBizDate_ = Function's return value
//******************************************************************
Sub getBizDate(Ref sBizDate_)
	
	Var iDBOK			: N1
	Var sSQLCmd			: A1000 = ""
	Var sRecordData		: A1000 = ""
	Var sSQLErr			: A500  = ""
	Var sTmp			: A2000 = ""
	
	// check connection to DB
	Call CheckDBConnection(iDBOK)

	If Not iDBOK
		// connection to DB lost
	Else
	
		// search in the DB for inputed "Registro" value
		Format sSQLCmd As 	"SELECT CONVERT(varchar(20), business_date, 112) FROM micros.REST_STATUS"

		Call sqlGetRecordSet(sSQLCmd)
		Call sqlGetLastErrorString(sSQLErr)
		
		If sSQLErr = ""
	
			// Try to get first record (if any).
			Call sqlGetFirst(sRecordData)
			
			If sRecordData <> ""
				// get retrieved biz dates
				Split sRecordData, DB_REC_SEPARATOR, sBizDate_
			Else
				// this shouldn't happen
				// An error occurred. Warn user and log error
				Call logInfo(ERROR_LOG_FILE_NAME,"Error while querying DB (getBizDates): No biz dates returned",TRUE,TRUE)
				Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
				Call logInfo(ERROR_LOG_FILE_NAME,sSQLCmd,TRUE,TRUE)
			Endif
		Else
			// An error occurred. Warn user and log error
			Call logInfo(ERROR_LOG_FILE_NAME,"Error while querying DB (getBizDates)",TRUE,TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME,sSQLCmd,TRUE,TRUE)
		EndIf
	Endif
	
EndSub

//******************************************************************
// Procedure: CheckDBConnection()
// Author: Alex Vidal
// Purpose: Checks if an active connection exists to the Micros DB
// Parameters:
//	- retVal_ = Function's return value 
//			    ( 1 = connected | 0 = error/not connected )
//
//******************************************************************
Sub CheckDBConnection( ref retVal_ )

	var iConnStatus		: N4
	var sSQLErr			: A500 = ""


	If (@INSTANDALONEMODE = FALSE) And (@INBACKUPMODE = FALSE)
	
		// check for connection
		Call sqlIsConnectionOpen(iConnStatus)

		If iConnStatus =  0
		  
			// Connection to the DB has been lost. Try to reconnect!
			
			Call sqlInitConnection()
		  	Call sqlGetLastErrorString(sSQLErr)

			If sSQLErr <> ""	
				// DB driver returned an error. DB might not be up.
				retVal_ = FALSE
				call logInfo(ERROR_LOG_FILE_NAME,"Error while initializing DB connection",TRUE,TRUE)
				call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)

				// close connection to DB
				Call sqlCloseConnection()

			Else				
				// We're connected!
				retVal_ = TRUE

			Endif
			
		Else		
			// we're connected!
			retVal_ = TRUE

		EndIf
	Else
		
		// we are in SAR o BackUp mode! Connection to DB is lost.
		retVal_ = FALSE

		// close connection to DB
		Call sqlCloseConnection()
	Endif

EndSub

//******************************************************************
// Procedure: sqlInitConnection()
// Author: Alex Vidal
// Purpose: Initializes a connection to the Micros DB through the
//				active DB driver
// Parameters:
//	 -
//******************************************************************
Sub sqlInitConnection()

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		if gbliRESMajVer >= 4
			// Use 4.x "Fiscal" user
			DLLCall_CDECL gblhDB, sqlInitConnection("micros","ODBC;UID=Fiscal;PWD=AvNaGssLc1Kv", "")
		else
			// User "Custom" user
			DLLCall_CDECL gblhDB, sqlInitConnection("micros","ODBC;UID=custom;PWD=custom", "")
		endif
	Else
		DLLCall gblhDB, sqlInitConnection("micros","UID=custom;PWD=custom")
	Endif

EndSub

//******************************************************************
// Procedure: sqlExecuteQuery()
// Author: Alex Vidal
// Purpose: Executes a SQL query against the Micros DB through the
//				active DB driver
// Parameters:
//	 - sSQLCmd_ = SQL query to execute
//******************************************************************
Sub sqlExecuteQuery( ref sSQLCmd_ )

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDECL gblhDB, sqlExecuteQuery(ref sSQLCmd_) 
	Else
		DLLCall gblhDB, sqlExecuteQuery(ref sSQLCmd_) 
	Endif

EndSub

//******************************************************************
// Procedure: sqlGetRecordSet()
// Author: Alex Vidal
// Purpose: Executes a ReadOnly SQL query against the Micros DB 
//				through the active DB driver
// Parameters:
//	 - sSQLCmd_ = SQL query to execute
//******************************************************************
Sub sqlGetRecordSet( ref sSQLCmd_ )

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDECL gblhDB, sqlGetRecordSet(ref sSQLCmd_) 
	Else
		DLLCall gblhDB, sqlGetRecordSet(ref sSQLCmd_) 
	Endif

EndSub

//******************************************************************
// Procedure: sqlGetFirst()
// Author: Alex Vidal
// Purpose: Returns active DB driver data for first record in open 
//				recordset
// Parameters:
//	 - sRecordData_ = Returned record data
//******************************************************************
Sub sqlGetFirst( ref sRecordData_ )

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDECL gblhDB, sqlGetFirst(ref sRecordData_) 
	Else
		DLLCall gblhDB, sqlGetFirst(ref sRecordData_) 
	Endif

EndSub

//******************************************************************
// Procedure: sqlGetNext()
// Author: Alex Vidal
// Purpose: Returns active DB driver data for next record in open 
//				recordset
// Parameters:
//	 - sRecordData_ = Returned record data
//******************************************************************
Sub sqlGetNext( ref sRecordData_ )

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDecl gblhDB, sqlGetNext( ref sRecordData_ )
	Else
		DLLCall gblhDB, sqlGetNext( ref sRecordData_ )
	Endif

EndSub


//******************************************************************
// Procedure: sqlGetLastErrorString()
// Author: Alex Vidal
// Purpose: Returns last error string from the active DB driver	
// Parameters:
//	 - sSQLErr_ = returned error string
//******************************************************************
Sub sqlGetLastErrorString( ref sSQLErr_ )

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDECL gblhDB, sqlGetLastErrorString(ref sSQLErr_)
	Else
		DLLCall gblhDB, sqlGetLastErrorString(ref sSQLErr_)
	EndIf

EndSub

//******************************************************************
// Procedure: sqlIsConnectionOpen()
// Author: Alex Vidal
// Purpose: Returns current connection status from the active DB 
//				driver	
// Parameters:
//	 - iConnStatus_ = returned connection status
//******************************************************************
Sub sqlIsConnectionOpen( ref iConnStatus_ )

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDECL gblhDB, sqlIsConnectionOpen(ref iConnStatus_)
	Else
		DLLCall gblhDB, sqlIsConnectionOpen(ref iConnStatus_)
	EndIf

EndSub

//******************************************************************
// Procedure: sqlCloseConnection()
// Author: Alex Vidal
// Purpose: closes active DB driver connection to DB
// Parameters:
//	 - 
//******************************************************************
Sub sqlCloseConnection()

	if gbliRESMinVer >= 2 or gbliRESMajVer >= 3
		DLLCall_CDECL gblhDB, sqlCloseConnection()
	Else
		DLLCall gblhDB, sqlCloseConnection()
	EndIf

EndSub


///////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                       //
//========================================= AUXILIARY FUNCTIONS =========================================//
//                                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////


//******************************************************************
// Procedure: initGlobalVars()
// Author: Al Vidal
// Purpose: resets values in global variables used in this script
// Parameters: 
//
//******************************************************************
Sub initGlobalVars()
	
	Format gblsCardId 			As ""
	Format gblsCustomerDoc 		As ""
	Format gblsPayrollId 		As ""
	Format gblsCustomerName 	As ""
	Format gblsInitialDate 		As ""			
	Format gblsExpirationDate 	As ""		
	Format gblsCustomerClass  	As ""

	//Format gblsMicrosCustId As ""
	
	gbliSelectedMenu 	= INVALID_MEAL
	gbliCheckItemQty 	= 0
	gbliConsumeQty 		= 0
	gbliDiscObjNum 		= 0
	
EndSub

//******************************************************************
// Procedure: 	AskForGuestId()
// Author: 		Luis Vaccaro
//
//******************************************************************
Sub AskForGuestId(Ref cardId_, Ref dni_, Ref payrollId_)
		
	Var kKeyPressed		: Key
	Var iOption 		: N1
	Var cardId 			: A16
	Var dni 			: A16
	
	Touchscreen	@ALPHASCREEN
	
	Window 2,50, "Identificacion (Version: 2.0 23-2-15)"
		
		//Display 1, 1, "Tarjeta: "
		Display 1, 1, "Legajo : "
		//Display 1, 1, "Legajo : "

		//DisplayInput 1, 10, cardId{16},"(max. 16 carac.)"
		DisplayInput 1, 10, dni{16},"(max. 16 carac.)"
		//DisplayInput 1, 10, payrollId_{16},"(max. 16 carac.)"

	WindowEdit	
	WindowClose	
		
	InputKey kKeyPressed, iOption, "Aceptar o Cancelar"
				
	If kKeyPressed = @KEY_ENTER
		Format cardId_ 		As Trim(cardId)
		Format dni_ 		As Trim(dni)
		Format payrollId_ 	As Trim(payrollId_)

	ElseIf kKeyPressed = @KEY_CANCEL
		Format cardId_ 		As ""
		Format dni_ 		As ""
		Format payrollId_ 	As ""

	EndIf

EndSub


//******************************************************************
// Procedure: 	GetStoreId()
// Author: 		Luis Vaccaro
//
//******************************************************************
Sub GetStoreId(Ref id_)
	
	Var iDBOK 			: N1
	Var sqlCommand 		: A1024	= ""
	Var sRecordData		: A1000 = ""
	Var sSQLErr			: A500 	= ""
	Var iTmp 			: N9
	
	Format id_ As ""
	
	If(gblsStoreId <> "")
		iTmp = gblsStoreId			
		Format id_ As iTmp{03}
		Return
		
	Endif
	
	// Check DB Connection
	Call CheckDBConnection(iDBOK)
	
	If iDBOK
		
		// Format query
		Format sqlCommand As "SELECT store_id FROM micros.rest_def"
										
		Call sqlGetRecordSet(sqlCommand)
		Call sqlGetLastErrorString(sSQLErr)

		If sSQLErr = ""
			// Try to get first record (if any).
			Call sqlGetFirst(sRecordData)
			
			If sRecordData <> ""
				Split sRecordData, DB_REC_SEPARATOR, gblsStoreId						
				
				iTmp = gblsStoreId
				Format id_ As iTmp{03}
			Endif
			
		Else 
			// an error ocurred!
			Call logInfo(ERROR_LOG_FILE_NAME, "Error while querying record in DB (GetStoreId)", TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sSQLErr, TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sqlCommand, TRUE, TRUE)

			ErrorMessage "Error al consultar la BD!"
			Return  // bail out!
			
		Endif	
		
	Else
		Call logInfo(ERROR_LOG_FILE_NAME,"No Connection to DB (GetStoreId)", TRUE, TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sqlCommand,TRUE,TRUE)
		ErrorMessage "Error al verificar el estado del comprobante!"
	Endif

EndSub

//******************************************************************
// Procedure: 	GetRestName()
// Author: 		Luis Vaccaro
// Purpose: 	Returns Restaurant Name

//******************************************************************
Sub GetRestName(Ref name_)
	
	Var iDBOK 			: N1
	Var sqlCommand 		: A1024	= ""
	Var sRecordData		: A1000 = ""
	Var sSQLErr			: A500 	= ""
	
	//if name was read
	If(gblsRestName <> "")
		Format name_ As gblsRestName
		Return		
	Endif
	
	// Check DB Connection
	Call CheckDBConnection(iDBOK)
	
	If iDBOK
		
		// Format query
		Format sqlCommand As "SELECT rest_name FROM micros.rest_def"
										
		Call sqlGetRecordSet(sqlCommand)
		Call sqlGetLastErrorString(sSQLErr)

		If sSQLErr = ""
			// Try to get first record (if any).
			Call sqlGetFirst(sRecordData)
			
			If sRecordData <> ""
				Split sRecordData, DB_REC_SEPARATOR, gblsRestName
				Format name_ As gblsRestName
				
			Endif
			
		Else 
			// an error ocurred!
			Call logInfo(ERROR_LOG_FILE_NAME, "Error while querying record in DB (GetRestName)", TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sSQLErr, TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sqlCommand, TRUE, TRUE)

			ErrorMessage "Error al consultar la BD!"
			Return  // bail out!
			
		Endif	
		
	Else
		Call logInfo(ERROR_LOG_FILE_NAME,"No Connection to DB (GetRestName)", TRUE, TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sqlCommand,TRUE,TRUE)
		ErrorMessage "Error al verificar el estado del comprobante!"
	Endif
	
EndSub

//******************************************************************
// Procedure: 	ValidateCustomer()
// Author: 		Luis Vaccaro
//
//******************************************************************
Sub ValidateCustomer(Ref cardID_, Ref custID_, Ref payrollId_, Ref name_, Ref custClass_, Ref discObjNum_, Ref valid_)

	Var iDBOK 			: N1
	Var sqlCommand 		: A1024	= ""
	Var sRecordData		: A1000 = ""
	Var sSQLErr			: A500 	= ""
	Var sTmp			: A2000 = ""
	
	valid_ = FALSE
	

	// Check DB Connection
	Call CheckDBConnection(iDBOK)
	


	if descuentoespecial = FALSE
		If iDBOK	


			// Format query	
 			Format sqlCommand As 	"SELECT  null, CM.pc_appl_id, 999999, left(long_last_name+' '+long_first_name,30),       ", \
									"        'D',  432  ", \ 
									"FROM    micros.emp_def CM ,micros.emp_class_def B     ", \
						  			"WHERE   (CM.payroll_id = '", custID_, "') and Cm.emp_class_seq=B.emp_class_seq and locate(upper(B.name),'MANAG')>0 ",\
                                                    		"UNION SELECT  null, CM.pc_appl_id, 999999, left(long_last_name+' '+long_first_name,30),       ", \
									"        'D',  if(locate(upper(D.name),'127')>0) then 431 else 437 endif  ", \ 
									"FROM    micros.emp_def CM ,micros.emp_class_def B,micros.job_rate_def C,micros.job_def D     ", \
						  			"WHERE   (CM.payroll_id = '", custID_, "') and Cm.emp_class_seq=B.emp_class_seq and c.ob_primary_job='T' and C.job_seq=D.job_seq and CM.emp_seq=c.emp_seq"
			
			Call sqlGetRecordSet(sqlCommand)
			Call sqlGetLastErrorString(sSQLErr)

			If sSQLErr = ""
				// Try to get first record (if any).
				Call sqlGetFirst(sRecordData)
			
				If sRecordData <> ""
					Split sRecordData, DB_REC_SEPARATOR, cardID_, custID_, payrollId_, name_, custClass_, discObjNum_
					valid_ = TRUE
					
				Else
					valid_ = FALSE
				
				Endif
			
			Else 
				// an error ocurred!
				Call logInfo(ERROR_LOG_FILE_NAME, "Error while querying record in DB (ValidateCustomer)", TRUE, TRUE)
				Call logInfo(ERROR_LOG_FILE_NAME, sSQLErr, TRUE, TRUE)
				Call logInfo(ERROR_LOG_FILE_NAME, sqlCommand, TRUE, TRUE)

				ErrorMessage "Error al consultar la BD!"
				Return  // bail out!
			Endif	
	
		Else
			Call logInfo(ERROR_LOG_FILE_NAME,"No Connection to DB (ValidateCustomer)", TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME,sqlCommand,TRUE,TRUE)
			ErrorMessage "Error al verificar el estado del comprobante!"
	
		

		Endif

	Else
		
		If descuentoespecial = TRUE
		
			If iDBOK	


				// Format query	
 				Format sqlCommand As 	"SELECT  null, CM.pc_appl_id, 999999, left(long_last_name+' '+long_first_name,30),       ", \
										"        'D',  432  ", \ 
										"FROM    micros.emp_def CM ,micros.emp_class_def B     ", \
							  			"WHERE   (CM.payroll_id = '", custID_, "') and Cm.emp_class_seq=B.emp_class_seq and locate(upper(B.name),'MANAG')>0 ",\
                                                    			"UNION SELECT  null, CM.pc_appl_id, 999999, left(long_last_name+' '+long_first_name,30),       ", \
										"        'D',  if(locate(upper(D.name),'127')>0) then 438 else 432 endif  ", \ 
										"FROM    micros.emp_def CM ,micros.emp_class_def B,micros.job_rate_def C,micros.job_def D     ", \
							  			"WHERE   (CM.payroll_id = '", custID_, "') and Cm.emp_class_seq=B.emp_class_seq and c.ob_primary_job='T' and C.job_seq=D.job_seq and CM.emp_seq=c.emp_seq"
			
				Call sqlGetRecordSet(sqlCommand)
				Call sqlGetLastErrorString(sSQLErr)

				If sSQLErr = ""
					// Try to get first record (if any).
					Call sqlGetFirst(sRecordData)
				
					If sRecordData <> ""
						Split sRecordData, DB_REC_SEPARATOR, cardID_, custID_, payrollId_, name_, custClass_, discObjNum_
						valid_ = TRUE
						
					Else
						valid_ = FALSE
				
					Endif
			
				Else 
					// an error ocurred!
					Call logInfo(ERROR_LOG_FILE_NAME, "Error while querying record in DB (ValidateCustomer)", TRUE, TRUE)
					Call logInfo(ERROR_LOG_FILE_NAME, sSQLErr, TRUE, TRUE)
					Call logInfo(ERROR_LOG_FILE_NAME, sqlCommand, TRUE, TRUE)

					ErrorMessage "Error al consultar la BD!"
					Return  // bail out!
				Endif	
	
			Else
				Call logInfo(ERROR_LOG_FILE_NAME,"No Connection to DB (ValidateCustomer)", TRUE, TRUE)
				Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
				Call logInfo(ERROR_LOG_FILE_NAME,sqlCommand,TRUE,TRUE)
				ErrorMessage "Error al verificar el estado del comprobante!"

			Endif

		Endif



	Endif		
EndSub

//******************************************************************
// Procedure: 	GetAvailableMeals()
// Author: 		Luis Vaccaro
//
//******************************************************************
Sub GetAvailableMeals(Var cardID_ : A16, Var custID_ : A16, Ref payrollId_, Ref totalMeal1_, Ref totalMeal2_, Ref totalMeal3_, Ref availableMeal1_, Ref availableMeal2_, Ref availableMeal3_, Ref initDate_, Ref endDate_)
	
	Var iDBOK 			: N1
	Var sqlCommand 		: A1024	= ""
	Var sRecordData		: A1000 = ""
	Var sSQLErr			: A500 	= ""
	Var sTmp			: A2000 = ""
	Var meal1 			: A8 	= ""
	Var meal2 			: A8 	= ""
	Var meal3 			: A8 	= ""		
	Var totalmeal1 		: A8 	= ""
	Var totalmeal2 		: A8 	= ""
	Var totalmeal3 		: A8 	= ""		
	Var initialDate 	: A64 	= ""
	Var expirationDate 	: A64 	= ""
	Var date 			: A64
	
	Call getBizDate(date)

	If date = ""
		Format date As (@YEAR + 2000){04}, @Month{02}, @Day{02}
	Endif

	// Check DB Connection
	Call CheckDBConnection(iDBOK)
	
	If iDBOK

		// Format query
		
		Format sqlCommand As 	"SELECT  Meal1Total - Meal1Consumed AS LeftMeal1,                                                     ", \ 
								"        Meal2Total - Meal2Consumed AS LeftMeal2,                                                     ", \
								"        Meal3Total - Meal3Consumed AS LeftMeal3,                                                     ", \
								"        Meal1Total AS TotalMeal1,                                                                    ", \ 
								"        Meal2Total AS TotalMeal2,                                                                    ", \
								"        Meal3Total AS TotalMeal3,                                                                    ", \
								"        InitialDate, ExpirationDate                                                                  ", \
								"FROM    custom.customer_meals                                                                        ", \
						  		"WHERE   (CardID = '", cardID_,"' OR CustomerID = '", custID_, "' OR PayrollID = '", payrollId_, "')  ", \
						  		"        AND CAST('", date, "' AS DATETIME) BETWEEN InitialDate AND ExpirationDate                    "
										
		Call sqlGetRecordSet(sqlCommand)
		Call sqlGetLastErrorString(sSQLErr)

		If sSQLErr = ""
			// Try to get first record (if any).
			Call sqlGetFirst(sRecordData)
			
			If sRecordData <> ""
				Split sRecordData, DB_REC_SEPARATOR, meal1, meal2, meal3, totalmeal1, totalmeal2, totalmeal3, initialDate, expirationDate
								
				availableMeal1_ = meal1
				availableMeal2_ = meal2
				availableMeal3_ = meal3
				totalMeal1_ 	= totalmeal1
				totalMeal2_ 	= totalmeal2
				totalMeal3_ 	= totalmeal3

				Format initDate_ 	As initialDate{10}
				Format endDate_ 	As expirationDate{10}
			
			Else
				availableMeal1_ = 0
				availableMeal2_ = 0
				availableMeal3_ = 0
				totalMeal1_ 	= 0
				totalMeal2_ 	= 0
				totalMeal3_ 	= 0
				
				payrollId_ 		= -1

				Format initDate_ 	As ""
				Format endDate_ 	As ""
				
			Endif
			
		Else 
			// an error ocurred!
			Call logInfo(ERROR_LOG_FILE_NAME, "Error while querying record in DB (GetAvailableMeals)", TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sSQLErr, TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sqlCommand, TRUE, TRUE)

			ErrorMessage "Error al consultar la BD!"
			Return  // bail out!
		Endif	
	
	Else
		Call logInfo(ERROR_LOG_FILE_NAME,"No Connection to DB (GetAvailableMeals)", TRUE, TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sSQLErr,TRUE,TRUE)
		Call logInfo(ERROR_LOG_FILE_NAME,sqlCommand,TRUE,TRUE)
		ErrorMessage "Error al verificar el estado del comprobante!"
	Endif
		
EndSub

//******************************************************************
// Procedure: 	UpdateCustomerMeal()
// Author: 		Luis Vaccaro
//
//******************************************************************
Sub UpdateCustomerMeal(Var cardID_ : A16, Var custID_ : A16, Var payrollId_ : A16, Var meal1Qty_ : N9, Var meal2Qty_ : N9, Var meal3Qty_ : N9)

	Var iDBOK			: N1
	Var sSQLCmd			: A1000 = ""
	Var sSQLErr			: A500 	= ""
	Var sTmp			: A2000 = ""
	Var date 			: A64
	

	Call getBizDate(date)

	If date = ""
		Format date As (@YEAR + 2000){04}, @Month{02}, @Day{02}
	Endif

	// check connection to DB
	Call CheckDBConnection(iDBOK)

	If Not iDBOK
		// connection to DB lost
		ErrorMessage "Conexion a BD perdida! Los datos no seran modificados."
	Else

		// insert new customer data
		Format sSQLCmd As "UPDATE custom.customer_meals                                                                        ", \
						  "SET    Meal1Consumed = Meal1Consumed + '", meal1Qty_,        					               "', ", \
						  "       Meal2Consumed = Meal2Consumed + '", meal2Qty_,        					               "', ", \
						  "       Meal3Consumed = Meal3Consumed + '", meal3Qty_,        					               "'  ", \
						  "WHERE  (CardID = '", cardID_,"' OR CustomerID = '", custID_, "' OR PayrollID = '", payrollId_,  "') ", \
						  "       AND CAST('", date, "' AS DATETIME) BETWEEN InitialDate AND ExpirationDate                    "
					  						   
		Call sqlExecuteQuery(sSQLCmd)
		Call sqlGetLastErrorString(sSQLErr)

		If sSQLErr <> ""
			// An error has occurred. Warn user and
			// log error		
			Call logInfo(ERROR_LOG_FILE_NAME, "Error while updating DB (UpdateCustomerMeal)", TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sSQLErr, TRUE, TRUE)
			Call logInfo(ERROR_LOG_FILE_NAME, sSQLCmd, TRUE, TRUE)
			ErrorMessage "Ha ocurrido un error al querer actualizar el registro en la BD!"
		EndIf

	EndIf

EndSub

//******************************************************************
// Procedure: 	GetItemsCount()
// Author: 		Luis Vaccaro
// Purpose: 	Returns the number of items valid for printing
// Parameters:
//	- retVal_ = Function's return value
//******************************************************************
Sub GetItemsCount(Ref retVal_)

	Var index		: N9
	
	retVal_ = 0
	
	For index = 1 To @NUMDTLT

		If(@DTL_TYPE[index] = DT_MENU_ITEM And @DTL_TTL[index] <> 0.0)
		
			retVal_ = retVal_ + @DTL_QTY[index]
		
		ElseIf (@DTL_TYPE[index] = DT_SERVICE_CHARGE Or @DTL_TYPE[index] = DT_DISCOUNT)
			//do not allow any other type
			retVal_ = -1
			Break
		Endif 
	Endfor			

EndSub

//******************************************************************
// Procedure: 	GetMealsTitles()
// Author: 		Luis Vaccaro
//******************************************************************
Sub GetMealsTitles()	

	Format gblsMeal1Title As "Desayuno"
	Format gblsMeal3Title As "Almuerzo"
	Format gblsMeal2Title As "Colacion"

EndSub


//******************************************************************
// Procedure: 	PrintVoucher()
// Author: 		Luis Vaccaro
//******************************************************************
Sub PrintVoucher(Ref cardId_, Ref custId_, Ref payrollId_, Ref name_, Ref availMeal1_, Ref availMeal2_, Ref availMeal3_, Ref totalMeal1_, Ref totalMeal2_, Ref totalMeal3_, Ref initDate_, Ref endDate_)

	Var sTxtLine 		: A64
	Var sRestName 		: A100

	Call GetRestName(sRestName)
	
	Prompt "Imprimiendo..."
	
	StartPrint @VALD  // Print on Guest Check Printer
		
		PrintLine sRestName{=32}
		PrintLine " "
				
		Format sTxtLine As name_{=32}
		PrintLine sTxtLine

		Format sTxtLine As payrollId_{=32}
		PrintLine sTxtLine

		PrintLine "--------------------------------"
		
		PrintLine "             |Inic.|Cons.|Disp.|"
		PrintLine "             |-----|-----|-----|"
		
		Format sTxtLine As gblsMeal1Title{13}, "|", totalMeal1_{>5}, "|", (totalMeal1_ - availableMeal1){>5}, "|", availableMeal1{>5}, "|"
		PrintLine sTxtLine

		Format sTxtLine As gblsMeal2Title{13}, "|", totalMeal2_{>5}, "|", (totalMeal2_ - availableMeal2){>5}, "|", availableMeal2{>5}, "|"
		PrintLine sTxtLine

		Format sTxtLine As gblsMeal3Title{13}, "|", totalMeal3_{>5}, "|", (totalMeal3_ - availableMeal3){>5}, "|", availableMeal3{>5}, "|"
		PrintLine sTxtLine
							
		PrintLine "             -------------------"
		
		Format sTxtLine As "Validez: ", initDate_, " a ", endDate_
		PrintLine sTxtLine
		

		Format sTxtLine As @DAY{02}, "/", @MONTH{02}, "/", (@YEAR + 2000){04}, "  ", @HOUR{02}, ":", @MINUTE{02}, ":", @SECOND{02}
		PrintLine sTxtLine{>32}
		
		PrintLine " "
		PrintLine " "
		PrintLine " "
		PrintLine " "
		PrintLine " "
		PrintLine " "

	EndPrint

EndSub

//******************************************************************
// Procedure: 	ValidateCheckItems()
// Author: 		Luis Vaccaro
//
//******************************************************************
Sub ValidateCheckItems(Ref mealItemizer_, Ref itemQty_)
	
	Var index 			: N9
	Var itemizerCount 	: N9 = 0
		
	itemQty_ = 0
	
	For index = 1 To MAX_SI_NUM
				
		If(@SI[index] > 0.0)
			
			If(index = MEAL1_ITEMIZER Or index = MEAL2_ITEMIZER Or index = MEAL3_ITEMIZER)
				mealItemizer_ = index
			Endif
			
			itemizerCount = itemizerCount + 1

		Endif	
	
	Endfor

	If(itemizerCount = 0)		
		mealItemizer_ = NO_ITEMIZERS
		
	ElseIf(itemizerCount > 1)
		mealItemizer_ = MULTIPLE_ITEMIZERS
	
	Else
		Call GetItemsCount(itemQty_)
	
	Endif
	
EndSub

//******************************************************************
// Procedure: 	VerifyCustomerExistance()
// Author:		Luis Vaccaro 	
//******************************************************************
Sub VerifyCustomerExistance(Ref cardId_, Ref custId_, Ref payrollId_, Ref name_, Ref custClass_, Ref discObjNum_, Ref retVal_)
	
	retVal_ = FALSE
	
	If(cardId_ <> "" Or custId_ <> "" Or payrollId_ <> "")
		
		Call ValidateCustomer(cardId_, custId_, payrollId_, name_, custClass_, discObjNum_, retVal_)
					
	Endif

EndSub
