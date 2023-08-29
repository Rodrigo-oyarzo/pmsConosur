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
//inq 5: Descuento 15% Partners Otras Marcas Alsea
//*********************************************************************
Event Inq: 5  

    Var Archivo_Empleados                       : A35 = "\CF\Micros\scripts\OMALSEA.txt"
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
		
		If RUT = RUTabuscar
			Format datos as RUT," ",Last_Name
			StrKey = Key(5, 209)
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



