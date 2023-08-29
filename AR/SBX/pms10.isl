@Trace=0
RetainGlobalVar
UseCompatFormat
UseISLTimeOuts

//ver 2.8: bug impactar tende en termico, agreguo inq 12 debe ser llamado desde macro 801
//ver 2.7: Agrego logs, minimo para impresion cupon
//ver 2.5: agrego monto extracash limite, minimo en hasar_extracash.cfg,impacta ult tender hasar_ult_tender.cfg
//ver 2.4: Extracash
//ver 2.3: lectura de driver en wsce
//ver 2.2: cambio en dllfree
//ver 2.1: ignoramos en ws viejo
//ver 2.0: cambios en borrardiaactual
//ver 1.9: soporte para contacless
//ver 1.8: Borrado archivo
//Ver 1.7: Agregado tarjetaFidelidad
//crear una imagen para el momento de compra
//VER monto si no hace pago completo
//Ojo con imprimir siempre hay que comentar
var gVersion: A14="2.8"
var g_ip: A20="172.31.1.6"
var g_puerto: A5="3000"
var g_path  : A128   
var g_pathbin: A128 
var g_path_dia_actual: A50 
var g_path_fiscal : A128
var g_path_hasar:A128
//var gpath
var g_tender:N5
var g_tender_extracash:N5
var g_empresa:A10
var g_fiscal:N1

Var gDBhdl 	: N12
Var gDBPath     : A100="MDSSysUtilsProxy.dll"
Var dll_handle							: N12
Var dll_impresora                                               : N12
Var dll_status 							: N9
Var dll_status_msg 						: A100	

Var g_sucursal: A10
Var g_rtacodigo: N5
Var g_rtadesc: A100
Var g_pathcupon: A200
Var g_codtarjeta:N5
Var g_monto:$8
var g_extracash:$8
Var g_versionLib:A60
Var g_cantefectivo:$15
var g_minefectivo:$10
var g_mincupon:$10

VAR gMsr:N1
VAR gMsrMonto:$8
//************************ HASAR   ******************
Event init
   // call setearSO
    call logear("HASAR Init",0)
    gMsr=0
    gMsrMonto=0
    dll_handle=0
    dll_impresora=0
    g_sucursal="VACIA"
    g_rtacodigo=0
    g_rtadesc=""
    g_codtarjeta=0
    //g_pathcupon=""
    g_monto=0
    g_extracash=0
    g_mincupon=0
    //Call getSucursal
    call GetModeloFiscal
    Call cargarDllHasar
    //Call ObtenerConfiguracion
    Call borrarDiaActual
   // call GetMinEfectivo
    IF (dll_handle<>0)
        DLLFree dll_handle
        dll_handle=0
    ENDIF
    //Call prueba
    //Call compra2
endevent



Event inq: 1
    gMsr=0
    gMsrMonto=0
    call cargarDLLHasar
    IF (dll_handle=0)
        call cargarDLLHasar
        //call GetMinEfectivo
        //Call ObtenerConfiguracion
    ENDIF
    call logear("Call Compra",1)
    call compra(0)
    call logear("Fin Call Compra",1)
    IF (dll_handle<>0)
        DLLFree dll_handle
        dll_handle=0
    ENDIF
endevent

Event inq: 2 //contactless
    gMsr=0
    gMsrMonto=0
    call cargarDLLHasar
    IF (dll_handle=0)
        call cargarDLLHasar
       // Call ObtenerConfiguracion
    ENDIF
    call compra(1)
    IF (dll_handle<>0)
        DLLFree dll_handle
        dll_handle=0
    ENDIF
endevent

Event inq: 3 //cierre de terminal
    IF (dll_handle=0)
        call cargarDLLHasar
    ENDIF
    call CierreTerminal
Endevent

Event Signout
    gMsr=0
    gMsrMonto=0
   // IF (dll_handle=0)
    //    call cargarDLLHasar
   // ENDIF
   // call CierreTerminal
    Call borrarDiaActual
EndEvent

Event inq: 8 //fidelidad CLub La Nacion
    call cargarDLLHasar
    call tarjetaFidelidad
    IF (dll_handle<>0)
        DLLFree dll_handle
        dll_handle=0
    ENDIF
endevent

Event inq: 9 //impactar ult online
    VAR tender:N5
    VAR monto:$8
     call logear("Inq 9 Ult Online",1)
    call cargarDLLHasar
    call getUltTender(tender,monto)
    call impactarTender(tender,monto)
    call GrabarUltTender(0,0)
    IF (dll_handle<>0)
        DLLFree dll_handle
        dll_handle=0
    ENDIF
endevent

Event inq: 10
    gMsr=0
    gMsrMonto=0
    call cargarDLLHasar
    IF (dll_handle=0)
       Call borrarDiaActual
        call mostrarVersionLib
    ENDIF
    
    IF (dll_handle<>0)
        DLLFree dll_handle
        dll_handle=0
    ENDIF
EndEvent

EVENT INQ : 11 //llamada desde Rewards para anular recarga
    call logear("Inq 11: Anular Rewards",1)
    gMsr=1 
    Window 1,20, gVersion		
		Display 1, 1, "monto: "
                Displayinput 1, 7, gMsrMonto{8},""
    WindowInput	
    WindowClose	

    call compra(0)
    
    IF (g_rtacodigo=0) //exito
        //pms2 es 21, inq 22 devuelvo control a rewards
        LoadKybdMacro Key(24, 16384 * 22 + 21)
    ENDIF
    gMsr=0
    gMsrMonto=0
    call logear("Inq 11: Fin Anular Rewards",1)
ENDEVENT

EVENT INQ : 12 //impacto tender por impresora termica
    IF (gMsrMonto=0)
        call impactarTender(g_tender,g_monto)
        IF (g_extracash>0)
            call logear("Compra: Hay Extracash",1)
            IF (g_tender_extracash=0)
                format aux as "HASAR EXTRACASH: NO SE ENCONTRO EL TENDER EXTRACASH DE: ",g_codtarjeta
                call mostrarMensaje(aux)
            ELSE
                call impactarExtracash(g_tender_extracash)
            ENDIF
        ENDIF
    ENDIF
ENDEVENT
//******************************************************************
// setear sistema operativo y path
//******************************************************************

Sub setearSO

        //InfoMessage @WSTYPE
        IF (@WSTYPE=1) //es windows
            g_path="" //"..\micros\etc\" //:A128="d:\Micros\Res\Pos\Etc\"   
            g_pathbin ="..\bin\"
            g_path_dia_actual="..\bin\dia_actual.txt"
            g_path_fiscal="..\bin\Fcrdll.dll"
            g_path_hasar="c:\micros\res\pos\bin\icCliente.dll"
            g_pathcupon="..\etc\" //pagotarj.txt"
        ELSE
            g_path= "\CF\micros\etc\" //:A128="d:\Micros\Res\Pos\Etc\"   
            g_pathbin="\CF\micros\bin\"
            g_path_dia_actual="\CF\micros\bin\dia_actual.txt"
            g_path_fiscal="\cf\micros\bin\FCRDriver.dll"
            g_path_hasar="\cf\micros\bin\icCliente.dll"
            g_pathcupon="\CF\micros\bin\" //pagotarj.txt"
        ENDIF

EndSub
//******************************************************************
// Load Hasar DLL
//******************************************************************
Sub cargarDllHasar
    call setearSO
    Call getSucursal
     g_rtacodigo=0
    g_rtadesc=""
    g_codtarjeta=0
    IF (g_Sucursal<>"VACIA")
        //IF (@WSTYPE=1)
            If ( dll_handle = 0 )
                //infomessage g_path_hasar
                DLLLoad dll_handle,  g_path_hasar
            EndIf

            If dll_handle = 0
                ErrorMessage "No se puede cargar driver sistema online Hasar. Reinicie el POS"
            EndIf
        // ENDIF
     ENDIF
EndSub

//************************** lib     ************************
//mostrar version lib
//*****************************************************************
SUB mostrarVersionLib
    Var status: A1000
    Var aux:A80="Version Lib Hasar: "

    DLLCall_CDECL dll_handle, versionLibBK(ref status )
    call parsearRta(status)
    format aux as aux,g_versionLib
    call mostrarMensaje(aux)
ENDSUB
//******************************************************************
// Cargar sucursal
//******************************************************************
SUB GetSucursal
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    g_sucursal="VACIO"
    FORMAT ArchConfig AS g_path, "HASAR_SUCURSAL", ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, g_sucursal
       //InfoMessage g_sucursal
       FCLOSE Handle
    ELSE
        ErrorMessage "ERROR: No se pudo acceder al numero sucursal Hasar Online"
    ENDIF
ENDSUB
//******************************************************************
// Ult Tender
//******************************************************************
SUB GetUltTender(REF ulttender,REF monto)
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   
    
    call setearSO
    ulttender=" "
    FORMAT ArchConfig AS g_path, "HASAR_ULT_TENDER", ".dat"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, ulttender,monto
       FCLOSE Handle
    ELSE
        call logear("GetUltTender: No existe hasar_ult_tender",1)
    ENDIF
ENDSUB
//******************************************************************
// grabar ultonline
//******************************************************************
Sub GrabarUltTender(VAR tender:N5,VAR monto:$8)
        VAR ArchConfig:A100
        Var handle	: N5  
        call setearSO

        FORMAT ArchConfig AS g_path, "HASAR_ULT_TENDER", ".dat"
        
	FOPEN handle, ArchConfig, write

	IF handle <> 0
		FWRITE handle, tender,monto
		FCLOSE handle
	ELSE
                call logear("GrabarUltTender: No pude grabar ulttender",1)
		ErrorMessage "No pude grabar ult tender en  ", logfile
	ENDIF
EndSub
//******************************************************************
// Cargar minefectivo
//******************************************************************
SUB GetMinEfectivo
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    g_minefectivo=1500
    FORMAT ArchConfig AS g_path, "HASAR_EXTRACASH", ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, g_minefectivo
       FCLOSE Handle
    ELSE
        call logear("GetMinEfectivo: No pude leer hasar_extracash",1)
        ErrorMessage "ERROR: No se pudo acceder al monto minimo Hasar Extracash"
    ENDIF
ENDSUB
//******************************************************************
// Cargar minimo dobre cupon
//******************************************************************
SUB GetMinCupon
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    g_mincupon=0
    FORMAT ArchConfig AS g_path, "CUPON_MIN", ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, g_mincupon
       FCLOSE Handle
    ELSE
        call logear("GetMinCupon: No pude leer cupon_min",1)
        //ErrorMessage "ERROR: No se pudo acceder al monto minimo Hasar Extracash"
    ENDIF
ENDSUB
//******************************************************************
// Cargar empersa
//******************************************************************
SUB GetEmpresa
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    g_empresa="VACIO"
    FORMAT ArchConfig AS g_path, "HASAR_EMPRESA", ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, g_empresa
       //InfoMessage g_sucursal
       FCLOSE Handle
    ELSE
        ErrorMessage "ERROR: No se pudo acceder al numero de empresa Hasar Online"
    ENDIF
ENDSUB
//******************************************************************
// Cargar modelo fiscal
//******************************************************************
SUB GetModeloFiscal
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    g_fiscal=0
    FORMAT ArchConfig AS g_path, "FISCAL", ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       FREAD Handle, g_fiscal
       FCLOSE Handle
    ENDIF
ENDSUB
//******************************************************************
// borrar diactual
//******************************************************************
SUB borrarDiaActual
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   
    IF (@WSTYPE=1)
        FORMAT ArchConfig AS g_path_dia_actual

        FOPEN Handle, ArchConfig, WRITE
        IF Handle <> 0
           FWRITE Handle, " "
           FCLOSE Handle
        ELSE
            //ErrorMessage "ERROR: No se pudo acceder al numero sucursal Hasar Online"
        ENDIF
     ENDIF
ENDSUB
//******************************************************************
// borrar pathcupon
//******************************************************************
SUB borrarCupon
    VAR ArchConfig       : A100      
    VAR Handle           : N5  = 0   

    FORMAT ArchConfig AS g_pathcupon,g_sucursal,"_",@wsid,"_pagotarj.txt"

    FOPEN Handle, ArchConfig, WRITE
    IF Handle <> 0
       FWRITE Handle, " "
       FCLOSE Handle
    ELSE
        //ErrorMessage "ERROR: No se pudo acceder al numero sucursal Hasar Online"
    ENDIF
ENDSUB
//******************************************************************
// Cargar tenders
//******************************************************************
SUB GetTender(VAR medio:N5)
    VAR ArchConfig       : A32      
    VAR Handle           : N5  = 0   
    VAR auxhasar :N5=0
    VAR auxmicros:N5=0
    VAR auxextracash:N5=0

    g_tender=0
    g_tender_extracash=0
    FORMAT ArchConfig AS g_path, "HASAR_TENDER", ".cfg"

    FOPEN Handle, ArchConfig, READ
    IF Handle <> 0
       WHILE NOT FEOF( Handle ) and g_tender=0
           FREAD Handle, auxhasar,auxmicros,auxextracash
           IF ( NOT FEOF( Handle ) )
                IF ( auxhasar = medio )
                    g_tender=auxmicros	
                    g_tender_extracash=auxextracash
                ENDIF
           ENDIF
       ENDWHILE
       FCLOSE Handle
    ELSE
        call logear("GetTender: No pude leer hasar_tender",1)
        ErrorMessage "ERROR: No se pudo acceder al archivo tender Hasar Online"
    ENDIF
ENDSUB
//**********************************************************
// Impactar el tender en micros
//*********************************************************
SUB impactarTender(VAR tender:N5,VAR monto:$8)
    VAR aux:A60
    
    format aux as "ImpactoTender: ",tender," Monto: ",monto
    //VER EL MONTO A IMPACTAR
    call logear(aux,1)
    LoadKybdMacro MakeKeys(monto),  Key (9, tender)
    call GrabarUltTender(tender,monto)
ENDSUB
//**********************************************************
// Registro extracash
//*********************************************************
SUB impactarExtraCash(VAR tender:N5)
    call logear("Impacto ExtraCash",1)
    LoadKybdMacro  Key (9, tender),MakeKeys(g_extracash), @KEY_ENTER
ENDSUB
//************************** Transacciones     ************************
//Venta
//*****************************************************************
SUB Compra(VAR contact:N1)
    Var terminal :A100
    Var param: A1000
    Var status: A1000
    Var aux:A70
    Var auxextracash:A10=""
    Var resp:N2
    VAR auxcontact:A40=""
    VAR textolog:A100=""
    VAR auxentero:N6=0
    
    Call getSucursal
    Call getEmpresa
    call getModeloFiscal
    Call borrarCupon
    Call GetMinEfectivo
    Call GetMinCupon
    
    call GrabarUltTender(0,0)
    g_extracash=0
    g_cantefectivo=0
    
    aux=(@TTLDUE*100) 
    IF (gMsrMonto>0)
        aux=(gMsrMonto*100*(-1))
    ELSE
        call maxEfectivo
        IF ((g_cantefectivo-g_minefectivo)>0)
            g_cantefectivo=(g_cantefectivo-g_minefectivo)
        ENDIF
        auxentero=(g_cantefectivo/100)*100
        auxextracash=auxentero
        format textolog as "Min Efectivo: ",g_minefectivo," Disponible para retirar: ",g_cantefectivo
        call logear(textolog,1)

    ENDIF
    Format terminal  as "empresa:",g_empresa,"|sucursal:",g_sucursal,"|caja:",@WSID,"|"
	if (contact=1)
		auxcontact="codigoTarjeta:1|esContactLess:1|"
	else
		auxcontact="codigoTarjeta:0|"
	endif

      Format param as "codBanco:0|monto:",aux,"|fechaOriginal:|cuotas:1|moneda:PE|cajero:999|ticket:",@trans_number,"|nroUnicoOriginal:|codigoAutorizacion:|horaOriginal:|montoCashBack:|ticketOriginal:|esTarjetaPromocion:0|cashDisponible:",auxextracash,"|",auxcontact
    
    //call mostrarMensaje(terminal)
    //call mostrarMensaje(param)
    
    call logear("Compra: Envio mensaje CompraBK",1)
    IF (aux<0)
        call logear("Compra: Envio mensaje Devolucion",1)
        DLLCall_CDECL dll_handle, devolucionBK( terminal,param,ref status )
        call logear("Compra: FIN mensaje Devolucion",1)
    ELSE
        call logear("Compra: Envio mensaje Compra",1)
        DLLCall_CDECL dll_handle, compraBK( ref terminal,ref param,ref status )
        call logear("Compra: FIN mensaje Compra",1)
    ENDIF
    format aux as "Largo status: ",len(status)
    //call mostrarMensaje (aux)
    call parsearRta(status)
    //call mostrarMensaje (g_rtadesc)

    IF (g_rtacodigo=0)
        call logear("Compra: Transaccion Aprobada",1)
        //call mostrarMensaje("TRANSACCION APROBADA")
        call getTender(g_codtarjeta)
        IF (g_tender=0)
            //call imprimirCupon
            format aux as "HASAR ONLINE: NO SE ENCONTRO EL TENDER TRADUCIDO DE: ",g_codtarjeta
            call mostrarMensaje(aux)
        ELSE
            call logear("Compra: Envio mensaje Confirmacion",1)
            DLLCall_CDECL dll_handle, confirmacionBK( terminal)
            call logear("Compra: FIN mensaje Confirmacion",1)
            IF (g_fiscal=0)
                IF (gMsrMonto=0)
                    call impactarTender(g_tender,g_monto)
                    IF (g_extracash>0)
                        call logear("Compra: Hay Extracash",1)
                        IF (g_tender_extracash=0)
                            format aux as "HASAR EXTRACASH: NO SE ENCONTRO EL TENDER EXTRACASH DE: ",g_codtarjeta
                            call mostrarMensaje(aux)
                        ELSE
                            call impactarExtracash(g_tender_extracash)
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
            call logear("Compra: Voy a imprimir Cupon",1)
            call imprimirCupon(0,0)
            call logear("Compra: Fin imprimir Cupon",1)
            IF (g_extracash>0)
                call logear("Compra: Voy a imprimir Cupon Extracash",1)
                call imprimirCupon(1,1)
                call logear("Compra: Fin imprimir Cupon Extracash",1)
            ELSEIF ((g_mincupon>0) and (@ttldue>=g_mincupon))
                call logear("Compra: Voy a imprimir Cupon para firma",1)
                call imprimirCupon(1,1)
                call logear("Compra: Fin imprimir Cupon para firma",1)
            ENDIF
        ENDIF
    ELSE
        call logear("Compra: ERROR devuelto",1)
        call logear(g_rtadesc,1)
        call mostrarMensaje(g_rtadesc)
    ENDIF
    //call mostrarMensaje("Desp dll")

ENDSUB

//************************** Transacciones     ************************
//Fidelidad
//*****************************************************************
SUB tarjetaFidelidad
    Var terminal :A100
    Var param: A1000
    Var status: A1000
    Var aux:A70
    Var resp:N2

    Call getSucursal
    Call getEmpresa

    
    Format terminal  as "empresa:",g_empresa,"|sucursal:",g_sucursal,"|caja:",@WSID,"|"

    Format param as "codBanco:0|monto:110|fechaOriginal:|cuotas:1|moneda:PE|cajero:999|ticket:",@trans_number,"|nroUnicoOriginal:|codigoAutorizacion:|horaOriginal:|codigoTarjeta:0|montoCashBack:|ticketOriginal:|esTarjetaPromocion:1|"
    call logear("TarjFidelidad: Voy a llamar Compra",1)
    DLLCall_CDECL dll_handle, compraBK( ref terminal,ref param,ref status )
    call logear("TarjFidelidad: Fin llamar Compra",1)
    format aux as "Largo status: ",len(status)
    //call mostrarMensaje (aux)
    call parsearRta(status)

    IF (g_rtacodigo=0)
        LOADKYBDMACRO KEY(1, 196612) //next screen
        call logear("TarjFidelidad: Voy a llamar confirmacion",1)
        DLLCall_CDECL dll_handle, confirmacionBK( terminal)
        call logear("TarjFidelidad: Fin a llamar Confirmacion",1)
    ELSE
        //call mostrarMensaje(g_rtadesc)
        ExitWithError (g_rtadesc)
    ENDIF
ENDSUB

//************************** Transacciones     ************************
//cierre terminal
//*****************************************************************
SUB CierreTerminal
    Var terminal :A100
    Var param: A1000
    Var status: A1000
    Var resp:N2
    
    Call getSucursal
    Call getEmpresa
    Format terminal  as "empresa:",g_empresa,"|sucursal:",g_sucursal,"|caja:",@WSID,"|"

    DLLCall_CDECL dll_handle, cierreTerminalBK( terminal)
ENDSUB
//************************** Transacciones     ************************
//obtener configuracion
//*****************************************************************
SUB ObtenerConfiguracion
    Var terminal :A100
    Var param: A1000
    Var status: A1000
    Var resp:N2

    Call getSucursal
    Call getEmpresa
    
    Format terminal  as "empresa:",g_empresa,"|sucursal:",g_sucursal,"|caja:",@WSID,"|"

    DLLCall_CDECL dll_handle, obtenerConfiguracionBK(terminal) //obtenerConfiguracion
ENDSUB
//**************************************************************
// Parsear un campo
//**************************************************************
SUB parsearCampo(VAR campo:A100, REF valor)
    VAR i:N3

    i=Instr(1,campo,":")
    valor=mid(campo,i+1,len(campo)-i)

ENDSUB
//**************************************************************
//**************************************************************
// Parsear campos de status
//**************************************************************
SUB parsearRta(REF rta)
    var nroCupon:A40
    var tipoDeIngreso: A40
    var glosaRta:A100
    var codigoRespuesta:A40
    var nroLote:A40
    var descripcion_plan:A40
    var codigoAutorizacion:A40
    var nroComercio:A40
    var autorizador:A40
    var tipoTarjeta:A40
    var nroCuotas:A40
    var fecha:A40
    var tasa_aplicada:A40
    var codigo_tarjeta:A40
    var numeroUnico:A40
    var hora:A40
    var tarjeta:A40
    var path_cupon:A100
    var version_soft:A40
    var monto_original:A40
    var monto_rd:A40
    var nroTerminal:A40
    var tipoDeAprobacion:A40
    var tipo_identificador:A40
    var aux:A100
    var versionLibreria: A60
    var monto_extracash:A40
    
    Split rta, "|",codigoRespuesta,glosaRta,nroCupon,tipoDeIngreso,nroLote,descripcion_plan,codigoAutorizacion,nroComercio,autorizador,tipoTarjeta,nroCuotas,fecha,tasa_aplicada,codigo_tarjeta,numeroUnico,hora,tarjeta,path_cupon,version_soft,monto_original,monto_rd,nroTerminal,tipoDeAprobacion,tipo_identificador,versionLibreria,monto_extracash
    //ErrorMessage rta
    call parsearCampo(codigoRespuesta,aux)
    g_rtacodigo=aux
    call parsearCampo(glosaRta, g_rtadesc)
    IF (g_rtacodigo=0) //0 es exito
        call parsearCampo(path_cupon,g_pathcupon)
        
        call parsearCampo(codigo_tarjeta,aux) //tipo de tarjeta
        g_codtarjeta=aux
        call parsearCampo(monto_original,aux)
        g_monto=aux/100.0
        call parsearCampo(monto_extracash,aux)
        g_extracash=aux/100.0
        call parsearCampo(versionLibreria,g_versionLib)
    ENDIF   
ENDSUB
//*****************************************************
//  Imprimir cupon tarjeta
//*****************************************************
SUB imprimirCupon(VAR copiaempresa:N1,VAR segundo:N1)
   // call getModeloFiscal
    IF (g_fiscal=0)
        call imprimirCuponTradicional(copiaempresa)
    ELSE
        call imprimirCuponTermico(copiaempresa,segundo)
    ENDIF
ENDSUB


//*****************************************************
//  Imprimir cupon tarjeta fiscal termica
//*****************************************************
SUB imprimirCuponTermico(VAR copiaempresa:N1,VAR segundo:N1)
    Var i :N1
    Var aux : A50
    Var j: N2
    Var Archcupon:A128
    Var handle:N5=0
    Var linea:A50=""
    Var lineaaux:A50=""
    VAR ConfigFile       : A128       // File Name
    VAR FileHandle       : N5  = 0   // File handle
    VAR auxwrite : N4


    Prompt "Imprimiendo Cupon Tarjeta......"
    FORMAT ConfigFile AS g_path, "DNFH.txt"
    IF (segundo=1)
        FOPEN FileHandle, ConfigFile, append
        FWriteBfr FileHandle, chr(&1C),1, auxwrite 
        FWriteBfr FileHandle, chr(13),1, auxwrite 
        FWriteBfr FileHandle, chr(10),1, auxwrite 
    ELSE
        FOPEN FileHandle, ConfigFile, WRITE
    ENDIF
    IF FileHandle <> 0
        FORMAT Archcupon AS g_pathcupon,g_sucursal,"_",@wsid,"_pagotarj.txt"
        FOPEN Handle, Archcupon, READ
        IF Handle <> 0
            WHILE (not Feof(handle) and dll_status=0)
                
                FREADLN handle,linea
                IF ( NOT FEOF( Handle ) )
                    IF (linea="")
                        linea=" "
                    ENDIF
                    lineaaux=linea
                    uppercase lineaaux
                    IF ((trim(lineaaux)="COPIA CLIENTE") and copiaempresa=1) 
                        FWriteBfr FileHandle, "Firma: _______________________________",len("Firma: _______________________________"), auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite 
                        FWriteBfr FileHandle, " ",1, auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite 
                        FWriteBfr FileHandle, " ",1, auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite 
                        FWriteBfr FileHandle, "Tipo y Nro.Doc: ______________________",len("Tipo y Nro.Doc: ______________________"), auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite 
                        FWriteBfr FileHandle, " ",1, auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite 
                        FWriteBfr FileHandle, "           Original Comercio",len("           Original Comercio"), auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite                        

                    ELSE
                        FWriteBfr FileHandle, linea,len(linea), auxwrite 
                        FWriteBfr FileHandle, chr(13),1, auxwrite 
                        FWriteBfr FileHandle, chr(10),1, auxwrite 
                    ENDIF
                  
                ENDIF
            ENDWHILE    
            FORMAT lineaaux as "CAJERO: ",@TREMP_CHKNAME{15}
            FWriteBfr FileHandle, lineaaux,len(lineaaux), auxwrite 
            FCLOSE Handle
            //pms8 es 21, inq 5 imprimo cupon
            //LoadKybdMacro Key(24, 16384 * 5 + 21)
            LoadDBKybdMacro 801
        ELSE
            ErrorMessage "ERROR: No se pudo acceder al archivo de cupon de tarjeta"
        ENDIF
       
        FCLOSE FileHandle   
        Prompt "idle"
    ELSE 
        Promt "Error crear cupon tarjeta"
    ENDIF
   
ENDSUB
//*****************************************************
//  Imprimir cupon tarjeta fiscal tradicional
//*****************************************************
SUB imprimirCuponTradicional(VAR copiaempresa:N1)
    Var i :N1
    Var aux : A50
    Var j: N2
    Var Archcupon:A128
    Var handle:N5=0
    Var linea:A50=""
    Var lineaaux:A50=""

    DLLLoad dll_impresora,  g_Path_Fiscal
   // InfoMessage "Voy a Imprimir 1"
    IF dll_impresora = 0
        ErrorMessage "HASAR:No se puede cargar driver de impresora"
    ELSE
        dll_status=0
        DLLCall_CDECL dll_impresora, Epson_open_non_fiscal( ref dll_status, ref dll_status_msg )

        IF ( dll_status <> 0 )
                ErrorMessage dll_status_msg
        ELSE
           // InfoMessage "Voy a Imprimir 2"
            Prompt "Imprimiendo Cupon Tarjeta......"

            FORMAT Archcupon AS g_pathcupon,g_sucursal,"_",@wsid,"_pagotarj.txt"
            //InfoMessage g_pathcupon
            //Archcupon="\CF\MICRos\BIN\1_2_pagotarj.txt"
            FOPEN Handle, Archcupon, READ
            IF Handle <> 0
                WHILE (not Feof(handle) and dll_status=0)
                    FREADLN handle,linea
                    IF ( NOT FEOF( Handle ) )
                        IF (linea="")
                            linea=" "
                        ENDIF
                        lineaaux=linea
                        uppercase lineaaux
                        IF ((trim(lineaaux)="COPIA CLIENTE") and copiaempresa=1) 
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Firma: _______________________________" )
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "Tipo y Nro.Doc: ______________________" )
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, " " )
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, "           Original Comercio" )

                        ELSE
                            DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, linea )
                        ENDIF
                        IF ( dll_status <> 0 )
                            ErrorMessage dll_status_msg
                            ErrorMessage linea
                        ENDIF
                    ENDIF
                ENDWHILE    
                FORMAT lineaaux as "CAJERO: ",@TREMP_CHKNAME{15}
                DLLCall_CDECL dll_impresora, Epson_print_non_fiscal( ref dll_status, ref dll_status_msg, lineaaux )
                FCLOSE Handle
                DLLCall_CDECL dll_impresora, Epson_close_non_fiscal( ref dll_status, ref dll_status_msg )

            ELSE
                ErrorMessage "ERROR: No se pudo acceder al archivo de cupon de tarjeta"
            ENDIF

            Prompt "idle"

            
       ENDIF
       DLLFree dll_impresora 
       dll_impresora = 0	
    ENDIF
ENDSUB

//************************** GENERALES     ************************
//Muestra mensaje en pantalla
//*****************************************************************
SUB mostrarMensaje(VAR mensaje:A200)
    var aux: A100=""
    format aux as "Mensaje (Version: ",gVersion,")"
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

    Window 2,65, "Consulta Aceptar o Cancelar"
		
      Display 1,1,mensaje
      DisplayInput 1, len(mensaje)+2, opcion{1},""
    WindowEdit	
    WindowClose	
    respuesta=0
    if (opcion="s" or opcion="S")
        respuesta=1
    endif
    
endsub

//************************* GENERALES ******************************
//Consulta maxEfectivo
//****************************************************************
SUB maxEfectivo
    Var dbok     	: N1
    Var comando     : A300= ""
    Var resultado	: A20= ""
    Var error	: A200= ""

    g_cantefectivo=0
    call ODBCinit
    Call ODBCconvalida(dbok)
    If dbok
            Format comando As "SELECT cash_pull_accumulator+P.starting_amount ",\
                              " FROM micros.cm_receptacle_dtl AS P INNER JOIN micros.uws_status AS U ON U.cm_drawer_",@CashDrawer,"_till_assigned = P.receptacle_seq",\
                              " INNER JOIN micros.uws_def AS D ON D.uws_seq = U.uws_seq WHERE  obj_num=",@WSID
            
            DLLCall_CDECL  gDBhdl, sqlGetRecordSet(ref comando) 
            DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
            If (error="")
                DLLCall_CDECL gDBhdl, sqlGetFirst(ref resultado) 
                 Split resultado, ";",g_cantefectivo
            Else 	

                ErrorMessage "PMS10: ValidarEfectivo: Error al consulta efectivo"
                ErrorMessage error
            Endif	
            call ODBCcerrarconexion()
            call ODBCbaja()
    Else
        ErrorMessage "PMS10: ValidarEfectivo: Error al conectar BD"
    Endif
ENDSUB
//******************************************************************
// Procedure: 	logear
//******************************************************************
Sub logear(var mensaje: A1000, var agregar : N1)
        call setearSO
        VAR logfile:A100
        FORMAT LogFile AS g_path, "logPms10-",@day,".txt"
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
		 " | WSID: ", @WSID, "CHK: ",@CKNUM, " === ", mensaje
	
		FWrite fhandle, aux
		FClose fhandle
	Else
		ErrorMessage "No pude grabar log en  ", logfile
	EndIf

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
		ErrorMessage "PMS10: Error al cargar BD"
        Else
            Call ODBCConexion()
            DLLCall_CDECL gDBhdl, sqlGetLastErrorString(ref error)
            If error <> ""
                    ErrorMessage "PMS10: Error al init conexion BD"
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
