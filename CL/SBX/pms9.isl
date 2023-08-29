// Sim file which customizes operations according to Starbucks Chile Rules 
// Gsantarelli 06-2003, updated version (11.03)

@WARNINGS_ARE_FATAL = 1
//@TRACE = 9
RetainGlobalVar
Var TRUE	 				: N1 = 1
Var FALSE					: N1 = 0
//GLOBAL VARIABLES for DLLs
Var hODBCDLL 					: N12
Var idCustomer					: N9 
// Global Variables
Var CLIENTSTART_CMD 				: A100
Var OpsVer 					: A30 		// 3700 version read from the registry
Var dbDown 					: N1 		// Is the database service available
Var constatus 					: N1  		// Database connection status
Var dbclient 					: N1 		// DBClient loaded flag
Var InSarMode 					: N1 = 0 	// In Stand Alone mode flag
// Global variables for inq 7
Var ENCABEZADO					: A9
Var nroempleado					: n9		// Nro de obj num de empleado
Var nombre					: A32		// Nombre de empleado
Var Ggasto					: $12		// global gasto var
Var Gtope					: $12		// global monto tope

//*********************************************************************
//event init: initialize db connection and loads necesary dlls
//*********************************************************************
Event Init	
    Call MaintainConnection()	
EndEvent

//*********************************************************************
//inq 5: Descuento 30 SCA
//*********************************************************************
Event Inq: 5  
    Var Archivo_Empleados                       : A35 = "\CF\Micros\scripts\SCA.txt"
    Var Archivo_Reg		   		: A30 = "..\scripts\registros.TxT"
    Var RUT				       	: N19 = 0
    Var run				       	: N19 = 0
    Var First_Name             			: A30 = ""
    Var Last_Name              			: A30 = ""
    Var STATUS            			: N10 = 0
    Var EXTRA            			: A20 = ""
    Var RUTabuscar				: A19
    Var EFECTIVO				: N19 =0
    Var fn 					: n3=1
    Var fn02 					: n3=1
    Var strKey					: key		
    Var datos					:A50
    Var tarjeta					:A50
    
	Call ClearFile 		// IPN 24 08 2016
	
    Fopen Fn02, Archivo_Empleados, Read
    Window 4,75
	Display 1,10,"NUMERO DE TARJETIN"
	Display 2,10,"NRO TARJETA    :"
	DisplayMSInput 2,30,rutABUSCAR{m2, 1, 4, *},"DESLICE TARJETIN"
	WindowInput
	If Fn02 = 0
       Fopen Fn02, Archivo_Empleados, Read
      EndIf
    Fread Fn02, RUT,  First_Name, Last_Name, STATUS, EXTRA
    While Not Feof(Fn02)and STATUS=0
		
		If RUT = RUTabuscar
			Format datos as RUT," ",Last_Name
			StrKey = Key(5, 203)
			LoadKybdMacro strKey ,makekeys(DATOS), @KEY_ENTER 
			Break
		EndIf
		Fread Fn02, RUT,  First_Name, Last_Name, STATUS, EXTRA
    EndWhile
    If Feof(fn02)
    ErrorMessage " No esta en la base de datos!  ",rutABUSCAR{m2, 1, 4, *}
	EndIf
    Fclose Fn02
	LoadKyBdMacro Key (17,210)		//IPN 05 09 2016
EndEvent


//*********************************************************************
//inq 6: food
//*********************************************************************
Event Inq: 6  
    Var Archivo_Empleados                       : A35 = "\CF\Micros\scripts\food.txt"
    Var Archivo_Reg		   		: A30 = "..\scripts\registros.TxT"
    Var RUT				       	: N19 = 0
    Var run				       	: N19 = 0
    Var First_Name             			: A30 = ""
    Var Last_Name              			: A30 = ""
    Var STATUS            			: N10 = 0
    Var EXTRA            			: A20 = ""
    Var RUTabuscar				: A19
    Var EFECTIVO				: N19 =0
    Var fn 					: n3=1
    Var fn02 					: n3=1
    Var strKey					: key		
    Var datos					:A50
    Var tarjeta					:A50
    
	Call ClearFile 		// IPN 24 08 2016
	
    Fopen Fn02, Archivo_Empleados, Read
    Window 4,75
	Display 1,10,"NUMERO DE TARJETita"
	Display 2,10,"NRO TARJETA    :"
	DisplayMSInput 2,30,rutABUSCAR{m2, 1, 4, *},"DESLICE TARJETitA"
	WindowInput
	If Fn02 = 0
       Fopen Fn02, Archivo_Empleados, Read
      EndIf
    Fread Fn02, RUT,  First_Name, Last_Name, STATUS, EXTRA
    While Not Feof(Fn02)and STATUS=0
		
		If RUT = RUTabuscar
			Format datos as RUT," ",Last_Name
			StrKey = Key(5, 225)
			LoadKybdMacro strKey ,makekeys(DATOS), @KEY_ENTER 
			Break
		EndIf
		Fread Fn02, RUT,  First_Name, Last_Name, STATUS, EXTRA
    EndWhile
    If Feof(fn02)
    ErrorMessage " No esta en la base de datos!  ",rutABUSCAR{m2, 1, 4, *}
	EndIf
    Fclose Fn02
	LoadKyBdMacro Key (17,210)		// IPN 05 09 2016
EndEvent







//******************************************************************
//Inq 7: Partner Beverage function 
//******************************************************************

Event Inq:7
	Var strKey				: key		
	Var datos				: A28
	Var strSQLCmd				: A200 	=""  
	Var intArrayCounter			: N9    = 1
	Var nombreemp				: A32	=""
	Var nroemp				: a10  	=""
	Var key_pressed				: key   
	Var nome				: a32   =""
	Var cmax	 			: $12 
	Var resp				: a2   =""
	Var totalact				: $12	=0
	Var desc				: $12	=0
	Var totalfinal				: $12	=0
	Var stotalact				: a13
	Var sdesc				: a13
	Var stotalfinal				: a13
	Var snroemp				: a13
	

	Call MaintainConnection()
	//If the database is down, just return.
	If dbDown = 1
		ErrorMessage "Sin conexion con el server, intente luego"
		Return
	EndIf
	touchscreen 51 //****************Pant Numerica*********
	Window 4,50
	DisplayMSInput 2,26,nroemp{m2, 1, 4, *},"Pase su Tarjeta Empleado"
	Display 2,6,"Numero de Empleado?"
	WindowInput     
	If nroemp="" 
		ErrorMessage "Nro. Empleado Invalido"
		//Return
	Else
		Call busca_emp(nroemp, nome, cmax,totalact)
		Window 6,50
		Display 1,10,"* DATOS DEL EMPLEADO *"
		Display 2,6,"Nro Empleado :",nroemp
		Display 3,6,"Nombre       :",nome
		Display 4,6,"Ttl Acumulado:",totalact
		WindowInput
		InputKey key_pressed, resp, "[Enter] Datos Correctos, [Clear] Salir"
	EndIf
	If (key_pressed = @Key_Enter and nroemp<>"")
		totalfinal=totalact+@TTLDUE
		If totalfinal <= cmax and desc <= @TTLDUE
			Call actualiza_emp(nroemp, totalfinal, cmax)
			snroemp=nroemp
			stotalfinal=totalfinal
			sdesc=@TTLDUE
			LoadKybdMacro Key(6, 204),makekeys(sdesc),@KEY_ENTER, makekeys(snroemp),@KEY_ENTER
			LoadKybdMacro Key(9, 101),@KEY_ENTER
		Else
			ErrorMessage "Monto supera al disponible!, Intente nuevamente"
			ExitCancel
		EndIf
	EndIf  
	Call FreeODBCDLL ()
EndEvent


//******************************************************************
//Inq 8: Updates Employee credit
//******************************************************************

Event Inq:8
    Var Archivo_Empleados                       : A35 = "\CF\Micros\scripts\STARBUCKS.txt"
    Var Archivo_Reg		   		: A30 = "..\scripts\registros.TxT"
    Var RUT				       	: N19 = 0
    Var First_Name             			: A30 = ""
    Var Last_Name              			: A30 = ""
    Var STATUS            			: N10 = 0
    Var EXTRA            			: A20 = ""
    Var RUTabuscar				: N19
    Var EFECTIVO				: N19 =0
    Var fn 					: n3=1
    Var fn02 					: n3=1
    Var strKey					: key		
    Var datos					:A50
    
	Call ClearFile 		// IPN 24 08 2016
	
    Fopen Fn02, Archivo_Empleados, Read
    Window 4,75
	Display 1,10,"NUMERO DE TARJETA"
	Display 2,10,"NRO TARJETA    :"
	DisplayMSInput 2,30,rutABUSCAR{m2, 1, 4, *},"DESLICE TARJETA"
	WindowInput
	If Fn02 = 0
       Fopen Fn02, Archivo_Empleados, Read
      EndIf
    Fread Fn02, RUT,  First_Name, Last_Name, STATUS, EXTRA
    While Not Feof(Fn02)and STATUS=0
		If rut = rutABUSCAR
			Format datos as RUT," ",Last_Name
			StrKey = Key(5, 226)					
			LoadKybdMacro strKey ,makekeys(DATOS), @KEY_ENTER 
			LoadKybdMacro Key(9, 101),@KEY_ENTER

			Break
		EndIf
		Fread Fn02, RUT,  First_Name, Last_Name, STATUS, EXTRA
    EndWhile
    If Feof(fn02)
    ErrorMessage " No esta en la base de datos!   ",rutABUSCAR{m2, 1, 4, *}
	EndIf
    Fclose Fn02
	LoadKyBdMacro Key (17,210)		// IPN 05 09 2016
EndEvent





//******************************************************************
//Looks up employee number and retrieves info by ID
//******************************************************************
Sub busca_emp(ref nro, ref nome, ref cmax, ref totalact)
	Var strSQLcmd				: a500=""
	Var strSQLCmd2				: a500=""
	Var strSQLCmd3				: a500=""
	Var max					: a12 =""
	Var ttlact				: a12 =""
	Var dia					: a26 ="" 
	Var obj_num				: a20 =""
	  
	  
	  Format strSQLCmd as "SELECT obj_num  FROM micros.emp_def where ID='",nro,"'"
//	  Format strSQLCmd as "SELECT obj_num  FROM micros.emp_def where obj_num='",nro,"'"
	  DLLCall_cdecl hODBCDLL, sqlGetRecordSet(ref strSQLCmd)
	  strSQLCmd = ""
	  DLLCall_cdecl hODBCDLL, sqlGetFirst(ref strSQLCmd)
	  Split strSQLCmd, ";",obj_num
	  DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd)
	  	   
	   
//	  Format strSQLCmd as "select * from emp_meal where obJ_num='",obj_num,"' and flag='1'" 
	  Format strSQLCmd as "select obj_num,chk_name,ttl,max from custom.emp_meal where obJ_num='",obj_num,"' and flag='1'" 
	  DLLCall_cdecl hODBCDLL, sqlGetRecordSet(ref strSQLCmd)
	  strSQLCmd = ""
	  DLLCall_cdecl hODBCDLL, sqlGetFirst(ref strSQLCmd)
//	  Split strSQLCmd, ";", nro,nome,totalact,cmax,dia
	  Split strSQLCmd, ";", nro,nome,totalact,cmax
	  DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd)
	  
EndSub



// idem by obj_num

Sub busca_emp2(ref nro, ref nome, ref cmax, ref totalact)
	Var strSQLcmd				: a500=""
	Var strSQLCmd2				: a500=""
	Var strSQLCmd3				: a500=""
	Var max					: a12 =""
	Var ttlact				: a12 =""
	Var dia					: a26 ="" 
	Var obj_num				: a20 =""

//	  Format strSQLCmd as "SELECT obj_num  FROM micros.emp_def where obj_num='",nro,"'"
//	  DLLCall_cdecl hODBCDLL, sqlGetRecordSet(ref strSQLCmd)
//	  strSQLCmd = ""
//	  DLLCall_cdecl hODBCDLL, sqlGetFirst(ref strSQLCmd)
//	  Split strSQLCmd, ";",obj_num
//	  DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd)
	  	   
	   
//	  Format strSQLCmd as "select * from emp_meal where obJ_num='",nro,"' and flag='1'" 
	  Format strSQLCmd as "select obj_num,chk_name,ttl,max from custom.emp_meal where obJ_num='",nro,"' and flag='1'" 
	  DLLCall_cdecl hODBCDLL, sqlGetRecordSet(ref strSQLCmd)
	  strSQLCmd = ""
	  DLLCall_cdecl hODBCDLL, sqlGetFirst(ref strSQLCmd)
	  Split strSQLCmd, ";", nro,nome,totalact,cmax
	  DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd)
	  
EndSub


//******************************************************************
//Update employee credit total for partner beverage
//******************************************************************	
Sub actualiza_emp(ref nro, ref total, ref cmax)
	Var strSQLcmd				:a200=""
	Var strSQLCmd2				:a200=""


		Format strSQLCmd as "update custom.emp_meal set ttl='",total,"' where obJ_num='",nro,"' and flag='1'" 
		DLLCall_cdecl hODBCDLL, sqlExecuteQuery(ref strSQLcmd) 	
		DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd)
		
	Format strSQLCmd2 as "update custom.emp_meal set last_update=current timestamp where obJ_num='",nro,"' and flag='1'" 
		DLLCall_cdecl hODBCDLL, sqlExecuteQuery(ref strSQLcmd2) 	
		DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd2)
EndSub


//******************************************************************
//Forces a new credit total for an employee
//******************************************************************	
Sub creditupdate( ref emp , ref nuevomonto)
	Var strSQLcmd				:a200=""
	
		Format strSQLCmd as "update custom.emp_meal set max='",nuevomonto,"' where obJ_num='",emp,"' and flag='1'" 
		DLLCall_cdecl hODBCDLL, sqlExecuteQuery(ref strSQLcmd) 	
		DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref strSQLcmd)
		
EndSub


//******************************************************************
//Unload DLL's
//******************************************************************
Event exit

    Call FreeODBCDll ()

EndEvent

//******************************************************************
// Unload ODBC DLL
//*****************************************************************
Sub FreeODBCdll ()
        
	If hODBCDLL <> 0

        DLLCall_cdecl hODBCDLL, sqlCloseConnection()
        DLLFree hODBCDLL
        hODBCDLL = 0
	EndIf
EndSub


//******************************************************************
// Load OBDCDLL dll
//******************************************************************
Sub LoadODBCDLL( )

    If hODBCDLL = 0
        DLLLoad hODBCDLL, "..\bin\MDSSysUtilsProxy.dll"
    EndIf
	
    If hODBCDLL = 0
       ExitWithError "Unable to Load MDSSysUtilsProxy.dll"
    EndIf

EndSub

//******************************************************************
//
// Subroutine:  MaintainConnection
//
// This Subroutine tries to maintain the database connection and allows us to
// let the system know that the database is unavailable.
//
//******************************************************************
Sub MaintainConnection()
    Var sql_cmd    				: A8096 = ""
    Var Status     				: N1    = 0
    //Var strActCode 				: A80   = "" - not in use -

    If (InSarMode = 1)		//If we're in SAR, don't try to reestablish connection
       Return
    EndIf

    If hODBCDLL = 0    		//Load SimODBC dll    
       Call LoadODBCDLL( )
    EndIf
    DLLCall_cdecl hODBCDLL, sqlIsConnectionOpen(ref constatus)
    //Call GetLicenseCode(strActCode) - not in use

	If constatus =  0		//Initialize database connection
		DLLCall_cdecl hODBCDLL, sqlInitConnection("micros","ODBC;UID=custom;PWD=custom", "")
		sql_cmd = ""
		DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref sql_cmd)
		If sql_cmd <> ""		// If we've got a error, the database isn't up
			constatus = 0
		Else
			constatus = 1
		EndIf
	EndIf
	If constatus = 1
		Format sql_cmd as "SELECT * from micros.interface_def"
		DLLCall_cdecl hODBCDLL, sqlGetRecordSet(sql_cmd)
	EndIf
	sql_cmd = ""
	DLLCall_cdecl hODBCDLL, sqlGetLastErrorString(ref sql_cmd)
	//WaitForEnter sql_cmd
	If sql_cmd <> ""	// If we've got a error, kill dbclient and restart it
		Call ODBCError()
	Else
		dbDown = 0
	EndIf
EndSub

//*************************************************************************
//????????????
// Subroutine:  ODBCError
//
// This Subroutine tries to tain the database connection and allows us to
// let the system know that the database is unavailable.
//
//*************************************************************************
Sub ODBCError()

    constatus = 0 // reset our connection status
    dbClient = 0
    dbdown = 1
    InSarMode = 1
    Call FreeODBCDLL( )

    If (Mid(OpsVer,1,1) = 2)
	If (hKILLDLL = 0)
            DLLLoad hKILLDLL, "..\bin\pskiller.dll"
        EndIf
        If (hKILLDLL = 0)
            exitwitherror "Unable to load pskiller.dll"
        Else
            DLLCall hKILLDLL, KillRunningProcess("dbclient")
        EndIf   
    EndIf        

EndSub

//*************************************************************************
// Modificacion hecha por: Mario Portal
// Rutina: Borra registro de archivo icareV.txt
// Fecha: 24 08 2016
//*************************************************************************

Sub ClearFile
	Var fn			: N5  // file handle
	Var sTmpInfo	: A30000
	Var index 		: N9
	Var size 		: N9
	Var sFileName : A100
	Var sInfo :A30000 = ""
	If @WSTYPE = 1
		Format sFileName AS "icarev.txt"
	Else
		Format sFileName AS "\cf\micros\etc\icarev.txt"
	EndIf
	size = Len(sInfo)
	index = 1		
	FOpen fn, sFileName, write
	If fn <> 0
		while index < size
			Format sTmpInfo As Mid(sInfo, index, 29000)				
			index = index + 29000
			// write info to file
			FWrite fn, sTmpInfo
		Endwhile
			// close handle to file
		FClose fn
	Else
		// error! Warn user
		ErrorMessage "No se pudo escribir informacion en ", sFileName
	EndIf
EndSub
//*************************************************************************
