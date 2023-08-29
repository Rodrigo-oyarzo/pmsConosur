// Programa   : micros_orion.isl
// Sistema    : MICROS 9700
// Fecha      : Marzo de 2007
// Descripcion: Modulo para Tarjetas de Credito

// Sheraton Maria Isabel     pms2.isl

// agregado compatibilidad rewards
// 10/04/28 12:00 Paula     Agregado tratamiento inquiry para operaciones con Club Personal y Club La Nacion
// 09/06/26 11:00 Paula     Agrego 1 reintento de impresion ante error
// 07/05/29 16:16 Miguel    Corrijo bug de reimpresion cambiada entre ajuste de propina y cancelacion
// 07/04/30 14:29 Miguel    Agrego impresion al ajuste de propina
// 07/03/22 11:05 Miguel    Creacion del esqueleto basado en isl actual, que interactua con interfaz Micros.
//                          Este SIM va a comunicarse via dll con un PosPC

UseISLTimeOuts
//SetreRead
VAR gMsr:N1
VAR gMsrMonto:$8

VAR Printer_Secuence : N3 = 35
VAR FALSE            : N1 = 0
VAR TRUE             : N1 = 1
VAR Invoice_IsPrinting : N1 = 0
//Defino las constantes
VAR TT_COMPRA_ON   : N1 = 0
VAR TT_COMPRA_OFF  : N1 = 1
VAR TT_CANCELACION : N1 = 2
VAR TT_DEVOLUCION  : N1 = 3
VAR TT_AJUSTE_TIP  : N1 = 4
VAR TT_REIMPRESION : N1 = 5
VAR TT_COMPRA_ON_CUOTAS   : N1 = 6
VAR TT_COMPRA_ON_FIDELIDAD   : N1 = 7

VAR FileStatus       : N1 
VAR VERSION : A3 = "1.7"

//include "subutils.isl"
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Este archivo contiene subrutinas utiles, especificas o comunes, para las distintas trasacciones

// 07/04/24 10:14 Miguel    A pedido de Roberto 
// 07/03/22 11:15 Miguel    Creacion

var g_fp_handle      :  N10 = 0

var g_dllhandle      :  N10 = 0
var g_hdl            :  N3  = 0
var g_cfg_path       : A128 = "\CF\micros\etc\"

// Funcion que despliegue el resultado de una respuesta
SUB SUB1_ShowReply(VAR dllhandle : N10, VAR hdl : N3)
    // Muestro una ventana de respuesta con:
        // trn_msg_host
        // Código de Respuesta:trn_external_respcode
        // trn_warning_msg
        // Autorización:trn_auth_code
        // Nro.Seguimiento:trn_id

    VAR codres      : A3
    VAR msg_host    : A64
    VAR warning     : A64
    VAR auth_code   : A7
    VAR trn_id      : A10
    var ret         : N3
    VAR twin        : N3 = 0
    VAR tpos        : N3 = 1
    VAR pro_id      : A4

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id"               , ref trn_id        ,  10)
    IF trn_id <> ""
        twin = twin + 1
    ENDIF

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_msg_host"         , ref msg_host      ,  64)
    twin = twin + 1

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_warning_msg"      , ref warning       ,  64)
    IF warning <> ""
        twin = twin + 1
    ENDIF

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_auth_code"        , ref auth_code     ,  7)
    IF auth_code <> ""
        twin = twin + 1
    ENDIF

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_external_respcode", ref codres        ,  4)
    IF codres <> ""
        twin = twin + 1
    ENDIF

//    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_pro_id"           , ref pro_id        ,  4)

    WINDOW twin, 51
        IF msg_host <> ""
//            IF (codres = "5" OR codres = "05") AND pro_id = "49"
//                DISPLAY  tpos, 2, "CODIGO VENCIDO"
//            ELSE
                DISPLAY  tpos, 2, MID( msg_host, 1, 30 )
//            ENDIF
        ELSE
            DISPLAY  tpos, 2, dcs_reply
        ENDIF
        tpos = tpos + 1

        IF codres <> ""
            DISPLAY  tpos, 2, "Codigo de Respuesta    : ", codres{02}
            tpos = tpos + 1
        ENDIF

        IF warning <> ""
            DISPLAY  tpos, 2, warning
            tpos = tpos + 1
        ENDIF

        IF auth_code <> ""
            DISPLAY  tpos, 2, "Autorizacion           : ", auth_code
            tpos = tpos + 1
        ENDIF

        IF trn_id <> ""
            DISPLAY  tpos, 2, "Nro.Seguimiento        : ", trn_id
        ENDIF

    WAITFORENTER
    WINDOWCLOSE
ENDSUB

// Funcion que se encarga de obtener el Tender Media a partir del producto
SUB GetTender( VAR ParameterTender: N5 )
    VAR ConfigFile       : A32       // File Name
	VAR Buffer           : A256
	VAR FilePosition     : N8        // Data Pointer
    VAR FileHandle       : N5  = 0   // File handle
    VAR OrionTender      : N8
    VAR TmpMicrosTender    : N8
    VAR TmpMicrosTipTender : N8

    FORMAT ConfigFile AS g_cfg_path, "ORION_TENDER.cfg"

    FOPEN FileHandle, ConfigFile, READ

	g_MicrosTender    = 0
	g_MicrosTipTender = 0
    OrionTender     = 0


    IF FileHandle <> 0
       WHILE NOT FEOF( FileHandle )

           FREAD FileHandle, OrionTender, TmpMicrosTender, TmpMicrosTipTender
           IF ( NOT FEOF( FileHandle ) )
                IF ( OrionTender = ParameterTender )
                    g_MicrosTender    = TmpMicrosTender
                    g_MicrosTipTender = TmpMicrosTipTender
                    BREAK
	
                ENDIF
           ENDIF

       ENDWHILE

       FCLOSE FileHandle
	ENDIF

ENDSUB

// Funcion que se encarga de inpactar el tender media para la operacion
// tipo: 0 = online, 1 = offline, 2 = tip, 3 =cancelación
SUB SUB1_ImpactTender(VAR dllhandle : N10, VAR hdl : N3, VAR tipo : N1)

// Voy a asumir que tengo la transaccion el la microsapi, y obtengo los datos de ahi
    VAR ret             : N3
    VAR tmp_propina     : A16 = "0"
    VAR tmp_importe     : A16
    VAR propina         : $12
    VAR empleado        : A20
    VAR producto        : A3
    VAR importe         : $12
    VAR tarjeta         : A26
    VAR vencimiento     : A26
    VAR mm              : A2
    VAR yy              : A2

    
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_pro_id"           , ref producto      ,   4)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_amount"           , ref tmp_importe   ,  16)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount"       , ref tmp_propina   ,  16)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_card_number"      , ref tarjeta       ,  26)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_exp_date"         , ref vencimiento   ,  26)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_usr_id"           , ref empleado      ,  20)

    propina = tmp_propina
    importe = tmp_importe

    mm = MID( vencimiento, 3, 2 )
    yy = MID( vencimiento, 1, 2 )


    IF tipo = 2// Si es por ajuste de propina
        IF ( g_MicrosTipApply = 1 )
            WINDOW 1, 58

            DISPLAY  1, 2, "Numero de Empleado     : "

            FOREVER
                DISPLAYINPUT    1, 24, empleado, "Numero de Empleado"
                WINDOWINPUT

                IF empleado > 0
                    BREAK
                ENDIF
            ENDFOR
            LOADKYBDMACRO 11:838 , MAKEKEYS ( propina ), 9:12, MAKEKEYS ( empleado ), 9:12

        ENDIF
    ELSE

        CALL GetTender( producto )
        
        IF ( g_MicrosTender <> 0 )
            importe = importe - propina
            IF tipo = 0 //si es online
                IF ( g_MicrosTipTender <> 0 )
                    IF ( propina > 0 )
                        LOADKYBDMACRO MAKEKEYS( propina ), 5:g_MicrosTipTender
                        LOADKYBDMACRO MAKEKEYS( importe + propina ), 7:g_MicrosTender,  \
                            MAKEKEYS( tarjeta ), 9:12, MAKEKEYS( mm ), MAKEKEYS( yy ), 9:12
                    ELSE
                        IF ( @TTLDUE <= ( importe ) )
                            LOADKYBDMACRO MAKEKEYS( importe + propina ), 7:g_MicrosTender,  \
                                9:12, MAKEKEYS( tarjeta ), 9:12, MAKEKEYS( mm ), MAKEKEYS( yy ), 9:12
                        ELSE
                            LOADKYBDMACRO MAKEKEYS( importe + propina  ), 7:g_MicrosTender,\
                                MAKEKEYS( propina ), \
                                9:12, MAKEKEYS( tarjeta ), 9:12, MAKEKEYS( mm ), MAKEKEYS( yy ), 9:12
                        ENDIF
                    ENDIF
                ELSE
                    LOADKYBDMACRO MAKEKEYS( importe + propina ), KEY(9, g_MicrosTender),  \
                        KEY(1, 65549)
                ENDIF
            ELSEIF tipo = 3 //si es cancelación
                LOADKYBDMACRO MAKEKEYS( -1 * importe), KEY(9, g_MicrosTender),  \
                    KEY(1, 65549)
            ELSE
                LOADKYBDMACRO MAKEKEYS( importe ), 7:g_MicrosTender,\
                9:12, MAKEKEYS( propina ), \
                9:12, MAKEKEYS( tarjeta ), 9:12
            ENDIF
        ENDIF
    ENDIF
    CALL SUB1_RemoveTenderFile()
ENDSUB

// 0=Graba, 1=Lee y 2=borra Transacciones en Archivos
SUB TrnFile( VAR Mode: n1, VAR Ext: A3, REF prt_var)

    VAR FileName      : A32       // File Name
    VAR FileHandle    : N5        // File handle
	VAR FilePosition  : N8        // Data Pointer
	VAR Buffer        : A256

    FORMAT FileName AS "ORION", @WSID, ".", Ext


    FileStatus = 1

    IF ( Mode = 2 )
//      SYSTEM "del /Q ", FileName
        SYSTEM "rm ", FileName
        FileStatus = 0
        RETURN
    ENDIF

    IF Mode = 1 OR Mode = 3


       FOPEN  FileHandle, FileName, READ

       IF FileHandle <> 0

          IF ( Mode = 1 )

             FREAD FileHandle, prt_var

          ENDIF

          FileStatus = 0

          FCLOSE FileHandle

       ENDIF

    ELSE
       // Almaceno
       FOPEN FileHandle, FileName, WRITE

       IF FileHandle <> 0

          FWRITE FileHandle, prt_var

          FCLOSE FileHandle

          FileStatus = 0

       ENDIF

    ENDIF

ENDSUB

SUB CheckReverse()

var ptr_var: A11

  CALL TrnFile( 3, "rev" ,ptr_var)

  IF ( FileStatus = 0 )
     CALL TrnFile( 1, "rev",ptr_var )
     CALL SendReverse
  ENDIF

ENDSUB

SUB SUB1_FiscalAPIInit(REF dllhandle)
    IF g_fp_handle = 0
        DLLLoad g_fp_handle, "FCRDriver.dll"
        if g_fp_handle = 0
            errormessage "Error en la carga de la dll de impresion"
            exit
        endif
    ENDIF

    dllhandle = g_fp_handle
    
ENDSUB

SUB SUB1_APIInit(REF dllhandle, REF hdl)

    IF g_dllhandle = 0
        DLLLoad g_dllhandle, "microsapi.dll"
        if g_dllhandle = 0
            errormessage "Error en la carga de la dll"
            exit
        endif
        DLLCall g_dllhandle, MICROSAPI_Startup()
    ENDIF

    dllhandle = g_dllhandle

    DLLCall dllhandle, MICROSAPI_Create(ref g_hdl)
    hdl = g_hdl


    DLLCall dllhandle, MICROSAPI_SetAttributeA(ref ret, hdl, "HOST", g_Host)
    DLLCall dllhandle, MICROSAPI_SetAttributeA(ref ret, hdl, "PORT", conf_PORT)
    DLLCall dllhandle, MICROSAPI_SetAttributeA(ref ret, hdl, "TIMEOUT", conf_TIMEOUT)
ENDSUB

SUB SUB1_MakeDCSREQ(VAR dllhandle : N10, VAR hdl : N3, VAR tipo : N1)

    VAR TrnKey          :  A6
    var ter             :  A32
    VAR dcs_form        :  A17
    var ret             :  N3
    var prt_var         :  A11

    FORMAT TrnKey AS g_TraceNumber{06}
    FORMAT ter AS TerminalPrefix, @WSID{04}

    IF tipo = TT_COMPRA_ON
        dcs_form = "t060s000"
        DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_amount"           , @TTLDUE)
    ELSEIF tipo = TT_COMPRA_ON_CUOTAS
        dcs_form = "t060s000CUOTAS"
        DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_amount"           , @TTLDUE)
    ELSEIF tipo = TT_COMPRA_ON_FIDELIDAD
        dcs_form = "t060s000FIDELIDAD"
        //DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_amount"           , @TTLDUE)
    ELSEIF tipo = TT_COMPRA_OFF
        dcs_form = "t056s000"
        DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_amount"           , @TTLDUE)
    ELSEIF tipo = TT_CANCELACION
        IF (gMsr=0)
            gMsrMonto=@TTLDUE
        ENDIF
        DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_amount"           , (-1 * gMsrMonto))
        dcs_form = "t124s000"
    ELSEIF tipo = TT_DEVOLUCION
        dcs_form = "t044s000"
    ELSEIF tipo = TT_AJUSTE_TIP
        dcs_form = "t120s001"
    ELSEIF tipo = TT_REIMPRESION
        dcs_form = "print"
        CALL TrnFile(1, "prt", prt_var)
        DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "fmi_key", prt_var)
    ENDIF

// Armo el mensaje enviando: terminal, comercio, dcs_form, monto, trn_internal_trace, ?moneda?

    DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "dcs_form"             , dcs_form)
    DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_internal_ter_id"  , ter)
    DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_internal_mer_id"  , Merchant)
    DLLCall dllhandle, MICROSAPI_SetString(ref ret, hdl, "trn_internal_trace"   , TrnKey)
ENDSUB

SUB SUB1_SendREQ(VAR dllhandle : N10, VAR hdl : N3, REF codres)

    var ret             :  N3
    var dcs_reply       :  A32
    var str             :  A128

    DLLCall dllhandle, MICROSAPI_CheckDCS(ref ret, "wDCS.exe", "CF\wDCS")
    DLLCall dllhandle, MICROSAPI_CheckDCS(ref ret, "stunnel.exe", "CF\stunnel")
    DLLCall dllhandle, MICROSAPI_Execute(ref ret, hdl)
    IF ret = 0

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "dcs_reply", ref dcs_reply, 32)
        IF ret = 0
            DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_internal_respcode", ref codres, 4)
            IF dcs_reply = "ok"
                IF ret <> 0
                    ErrorMessage "No llego el codigo de respuesta"
                    codres = -2
                ENDIF
            ELSE
                CALL SUB1_ShowReply(dllhandle, hdl)
                codres = -3
            ENDIF
        ELSE
            ErrorMessage "No llego el codigo de respuesta DCS"
            codres = -4
        ENDIF
    ELSE
        DLLCall dllhandle, MICROSAPI_GetAttribute(ref ret, hdl, "LASTERR", ref str, 128)
        ErrorMessage "Fallo la coneccion con DCS ", str
        codres = -5
    ENDIF
ENDSUB




////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////




//include "subconf.isl"
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Este archivo contiene todo lo que tiene que ver con manejo de configuraciones

// Meses
VAR conf_mes[ 12 ] :  A3
    conf_mes[  1 ]=  "Ene"
	conf_mes[  2 ]=  "Feb"
	conf_mes[  3 ]=  "Mar"
	conf_mes[  4 ]=  "Abr"
	conf_mes[  5 ]=  "May"
	conf_mes[  6 ]=  "Jun"
	conf_mes[  7 ]=  "Jul"
	conf_mes[  8 ]=  "Ago"
	conf_mes[  9 ]=  "Set"
	conf_mes[ 10 ]=  "Oct"
	conf_mes[ 11 ]=  "Nov"
	conf_mes[ 12 ]=  "Dic"


// Esto Pasar por RCV
VAR TerminalPrefix      : A10  = "MICROS"
VAR Merchant            : A15  = "Micros"
VAR conf_header1        : A30
VAR conf_header2        : A30
VAR conf_header3        : A30

VAR conf_HOST           : A30 = "127.0.0.1"
VAR conf_PORT           : A6  = "22001"
VAR conf_TIMEOUT        : A7  = "180000"

//
VAR conf_buyoff         : N1
VAR conf_cvv            : N1
VAR conf_moneda         : N1
VAR conf_cuotas         : N1
VAR conf_propina        : N1
VAR conf_productos[ 4 ] : A2

// Estas variables son para las xxxxConfig
VAR g_LastCheck      : N4   = 0
VAR g_Sequence       : N2   = 0
VAR g_TraceNumber    : N8   = 0
VAR g_InternalBatch  : N4   = 0
VAR g_AccumTip       : $12  = 0.00
VAR g_Host           : A32  = conf_HOST

VAR ConfigFileHandle    : N5   = 0     // File handle

SUB OpenConfig()
    VAR ConfigFile    : A32       // File Name
	VAR Buffer        : A256

    FORMAT ConfigFile AS "ORION", @WSID, ".cfg"

    FOPEN ConfigFileHandle, ConfigFile, READ

    IF ConfigFileHandle = 0
       FOPEN ConfigFileHandle, ConfigFile, WRITE
  	   CALL WriteConfig()
	   CALL CloseConfig()
       FOPEN ConfigFileHandle, ConfigFile, READ AND WRITE
    ELSE
        FOPEN ConfigFileHandle, ConfigFile, READ AND WRITE
    ENDIF

ENDSUB


SUB ReadConfig()
	VAR FilePosition  : N8        // Data Pointer
	VAR Buffer        : A256

    g_LastCheck     = 0
    g_Sequence      = 0
	g_TraceNumber   = 0
	g_InternalBatch = 1
	g_AccumTip      = 0.00

    IF ConfigFileHandle <> 0
	   FilePosition = FTELL( ConfigFileHandle )
       FREAD ConfigFileHandle, g_print_dev, g_LastCheck, g_Sequence, g_TraceNumber, g_InternalBatch, g_AccumTip, g_Host

	   FSEEK ConfigFileHandle, FilePosition
	ENDIF


ENDSUB

SUB WriteConfig()

    IF ConfigFileHandle <> 0
       FWRITE ConfigFileHandle, g_print_dev, g_LastCheck, g_Sequence, g_TraceNumber, g_InternalBatch, g_AccumTip, g_Host

	ENDIF

ENDSUB


SUB CloseConfig()

    IF ConfigFileHandle <> 0

       FCLOSE ConfigFileHandle
	   ConfigFileHandle = 0
	ENDIF

ENDSUB


SUB GetConfig()

    CALL OpenConfig()
    CALL ReadConfig()

    IF ( g_LastCheck <> @CKNUM )
       g_LastCheck = @CKNUM
       g_Sequence  = 0
	   g_AccumTip  = 0.00
    ELSE
       g_Sequence  = g_Sequence + 1
    ENDIF

    g_TraceNumber = g_TraceNumber + 1

	CALL WriteConfig()
	CALL CloseConfig()

ENDSUB


// Carga parametros de configuracion de un revenue center
SUB GetRVC( VAR RVCId: a30 )
    VAR ConfigFile       : A32       // File Name
	VAR Buffer           : A256
	VAR FilePosition     : N8        // Data Pointer
    VAR FileHandle       : N5  = 0   // File handle


//    FORMAT ConfigFile AS g_cfg_path, "ORION_RVC", RVCId, ".cfg"
    FORMAT ConfigFile AS g_cfg_path, "ORION_RVC", ".cfg"


    FOPEN FileHandle, ConfigFile, READ

	conf_buyoff     = 0
    conf_cvv        = 0
    conf_propina    = 0
    conf_moneda     = 0
    conf_cuotas     = 0
    conf_header1    = "Header 1"
    conf_header2    = "Header 2"
    conf_header3    = "Header 3"

    TerminalPrefix  = "MICROS"
    Merchant        = "Micros"

    IF FileHandle <> 0
       FREAD FileHandle, Merchant,     TerminalPrefix
       FREAD FileHandle, conf_header1, conf_header2,  conf_header3
       FREAD FileHandle, conf_buyoff,  conf_cvv,      conf_propina, conf_moneda, conf_cuotas
       FCLOSE FileHandle
	ENDIF

ENDSUB



////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

VAR g_MicrosTipMode   : N8  = 1
VAR g_MicrosTender    : N8  = 0
VAR g_MicrosTipTender : N8  = 0
VAR g_MicrosTipApply  : N8  = 0

VAR g_print_copies   :  N1  = 1
VAR g_print_dev      :  N5  = 0

// Longitudes maximas permitidas
VAR len_tarjeta      : N2 = 20
VAR len_vencimiento  : N1 = 4
VAR len_autoriz      : N1 = 6
VAR len_ticket       : N2 = 8


// Cierre de lote Interno
EVENT INQ : 6
    VAR  sino : A1

    CALL OpenConfig()
	CALL ReadConfig()

    WINDOW 3, 58

    DISPLAYINVERSE  1,  1, "                 Cierre de Lotes Micros            "

    DISPLAY        3, 2, "Desea Cerrar el Lote de Micros ?"

    DISPLAYINPUT   3, 40, sino, "Ingrese S para SI y N o <ENTER> para NO"
    WINDOWINPUT

    WINDOWEDIT
    WINDOWCLOSE


    IF sino = "S"
       g_InternalBatch = g_InternalBatch + 1

       CALL WriteConfig()
    ENDIF

	CALL CloseConfig()

    WINDOW 3, 58

    DISPLAYINVERSE  1,  1, "                 Cierre de Lotes Micros            "

    DISPLAY        3, 2, "El Lote ha sido cerrado Exitosamente"

    DISPLAYINPUT   3, 40, sino, "<ENTER> para continuar"
    WINDOWINPUT

    WINDOWEDIT
    WINDOWCLOSE

ENDEVENT

SUB SUB1_Compra(VAR flg_cuotas : N1)
//    SetreRead

    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var ter             :  A32
    var propina         :  A16
    var dcs_reply       :  A32
    var prt_var         :  A11
    VAR sino            :  A1
 
    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)

    IF flg_cuotas = 0
        CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_COMPRA_ON)
    ELSEIF flg_cuotas = 1
        CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_COMPRA_ON_CUOTAS)
    ENDIF

    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
    // Si es aprobada
		//InfoMessage "Antes Tender"
    	CALL SUB1_SaveTender(dllhandle, hdl)

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount", ref propina, 16)

        CALL OpenConfig()
        CALL ReadConfig()
		//InfoMessage "Despues Tender"
        g_AccumTip = g_AccumTip + propina

        CALL WriteConfig()
        CALL CloseConfig()

        // despliego mensaje
        //CALL SUB1_ShowReply(dllhandle, hdl)
	//InfoMessage "Transaccion Aprobada"

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
        CALL TrnFile(0, "prt", prt_var)
        // imprimo
			//InfoMessage "2 Voy a imprimir"

        CALL SUB1_Print(dllhandle, hdl, TT_COMPRA_ON, 0)

        // impacto tender
	
        CALL SUB1_ImpactTender(dllhandle, hdl, 0)

    ELSEIF (codres = "2" OR codres = "1" OR codres = "91" OR codres = "3" OR codres = "54") AND conf_buyoff = "1"
    // Si falla y se puede off-line
    // PREGUNTO SI QUIERE ENVIARLA OFF_LINE???
       WINDOW 3, 58

       DISPLAY  1, 2, "Codigo de Respuesta : ", codres
//       DISPLAY  2, 2, "Descripcion         : ", MID( IsoArray[ 44 ], 4, 25 )
       DISPLAY  3, 2, "Desea pedir Autorizacion Telefonica ?"

       DISPLAYINPUT  3, 40, sino, "Ingrese S para SI y N o <ENTER> para NO"
       WINDOWINPUT

       WINDOWEDIT

       WINDOWCLOSE

       IF sino = "S"

            DLLCall dllhandle, MICROSAPI_ClearFields(hdl)
            // Repito todo pero para off-line
            CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_COMPRA_OFF)
            // Envio y recibo
            CALL SUB1_SendREQ(dllhandle, hdl, codres)
            IF codres < -1
            ELSEIF codres = "-1"
            // Si es aprobada
		    	CALL SUB1_SaveTender(dllhandle, hdl)
                CALL SUB1_ShowReply(dllhandle, hdl)

                DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount", ref propina, 16)

                CALL OpenConfig()
                CALL ReadConfig()

                g_AccumTip = g_AccumTip + propina

                CALL WriteConfig()
                CALL CloseConfig()

                DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
                CALL TrnFile(0, "prt", prt_var)
                // imprimo
                CALL SUB1_Print(dllhandle, hdl, TT_COMPRA_OFF, 0)

                // impacto tender
                CALL SUB1_ImpactTender(dllhandle, hdl, 1)
            ELSE
                CALL SUB1_ShowReply(dllhandle, hdl)
            ENDIF
        ELSE
            CALL SUB1_ShowReply(dllhandle, hdl)
        ENDIF 
    ELSE
        CALL SUB1_ShowReply(dllhandle, hdl)
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0

ENDSUB

SUB SUB1_Compra_Fidelidad()
//    SetreRead

    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var ter             :  A32
    var propina         :  A16
    var dcs_reply       :  A32
    var prt_var         :  A11
    VAR sino            :  A1
 
    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)

    CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_COMPRA_ON_FIDELIDAD)

    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
    // Si es aprobada
    	CALL SUB1_SaveTender(dllhandle, hdl)
        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount", ref propina, 16)

        CALL OpenConfig()
        CALL ReadConfig()

        g_AccumTip = g_AccumTip + propina

        CALL WriteConfig()
        CALL CloseConfig()

        // no despliego mensaje asi se ejecuta la macro de Micros
        //CALL SUB1_ShowReply(dllhandle, hdl)

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
        CALL TrnFile(0, "prt", prt_var)
        // imprimo
        //CALL SUB1_Print(dllhandle, hdl, TT_COMPRA_ON, 0)

        // impacto tender
       //CALL SUB1_ImpactTender(dllhandle, hdl, 0)
	// 
    	//se llama a la pantalla del programa de fidelidad que sea (Personal, La Nacion, etc)
    	LOADKYBDMACRO KEY(1, 196612)
    ELSE
        CALL SUB1_ShowReply(dllhandle, hdl)
        
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0
ENDSUB

SUB SUB1_SaveTender(VAR dllhandle : N10, VAR hdl : N3)
    VAR importe     	: A16
    VAR producto        : A3
    VAR type_id         : A4
    VAR tdr_var			: A26
    
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_amount", ref importe, 16)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_pro_id", ref producto, 3)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_type_id", ref type_id, 4)
    
    FORMAT tdr_var AS importe, ",", producto, ",", type_id
    
	CALL TrnFile(0, "tdr", tdr_var)
    
ENDSUB

SUB SUB1_RemoveTenderFile()
    var ptr_var         :  A11

    CALL TrnFile(2, "tdr", ptr_var)
ENDSUB

// Peticion de Autorizacion Compra
EVENT INQ : 1
    gMsr=0
    gMsrMonto=0
    CALL SUB1_Compra(0) 
ENDEVENT

// Peticion de Autorizacion Compra en cuotas
EVENT INQ : 7
    CALL SUB1_Compra(1) 
ENDEVENT

// Peticion de Autorizacion Compra Club Personal - La Nacion
EVENT INQ : 8
    gMsr=0
    gMsrMonto=0
    CALL SUB1_Compra_Fidelidad() 
ENDEVENT

// Impacto suplementario de tender
EVENT INQ : 9
    VAR ret             : N3
    VAR tmp_importe     : A16
    VAR producto        : A3
    VAR importe         : $12
    VAR type_id         : A4
    VAR tdr_var			: A26

	  CALL TrnFile( 3, "tdr", tdr_var )
	
	  IF ( FileStatus = 0 )
    
	    CALL TrnFile(1, "tdr", tdr_var)
    
	    SPLIT tdr_var, ",", tmp_importe, producto, type_id
	    
	    importe = tmp_importe
	    
		CALL GetTender( producto )
	    
	    IF ( g_MicrosTender <> 0 )
	    
	        IF type_id = 121 OR type_id = 41
			    LOADKYBDMACRO MAKEKEYS( -1 * importe), KEY(9, g_MicrosTender),  \
			        KEY(1, 65549)
			ELSE
			    LOADKYBDMACRO MAKEKEYS( importe ), KEY(9, g_MicrosTender),  \
			        KEY(1, 65549)
		    ENDIF
	
		ENDIF
	    CALL SUB1_RemoveTenderFile()
	ENDIF
ENDEVENT

EVENT INQ : 10

    ErrorMessage VERSION

ENDEVENT

EVENT INQ : 11
   
    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var ter             :  A32
    var propina         :  A16
    var dcs_reply       :  A32
    var prt_var         :  A11
    gMsr=1

     
    Window 1,20, version		
		Display 1, 1, "monto: "
                Displayinput 1, 7, gMsrMonto{8},""
    WindowInput	
    WindowClose	

    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)


    CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_CANCELACION)

// Envio y recibo
    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
    // Si es aprobada
    	CALL SUB1_SaveTender(dllhandle, hdl)
        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount", ref propina, 16)

        CALL OpenConfig()
        CALL ReadConfig()

        g_AccumTip = g_AccumTip - propina

        CALL WriteConfig()
        CALL CloseConfig()

        // despliego mensaje
        CALL SUB1_ShowReply(dllhandle, hdl)

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
        CALL TrnFile(0, "prt", prt_var)
        // imprimo
        CALL SUB1_Print(dllhandle, hdl, TT_CANCELACION, 0)

        // impacto tender
        //CALL SUB1_ImpactTender(dllhandle, hdl, 3)
        //pms2 es 21, inq 22
        LoadKybdMacro Key(24, 16384 * 22 + 21)

    ELSE
        CALL SUB1_ShowReply(dllhandle, hdl)
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0
    gMsr=0
ENDEVENT
// Peticion de Autorizacion Cancelacion
EVENT INQ : 2

//    SetreRead

    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var ter             :  A32
    var propina         :  A16
    var dcs_reply       :  A32
    var prt_var         :  A11
    gMsr=0
    gMsrMonto=0

    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)

//    @TTLDUE es el monto total

    CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_CANCELACION)

// Envio y recibo
    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
    // Si es aprobada
    	CALL SUB1_SaveTender(dllhandle, hdl)
        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount", ref propina, 16)

        CALL OpenConfig()
        CALL ReadConfig()

        g_AccumTip = g_AccumTip - propina

        CALL WriteConfig()
        CALL CloseConfig()

        // despliego mensaje
        CALL SUB1_ShowReply(dllhandle, hdl)

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
        CALL TrnFile(0, "prt", prt_var)
        // imprimo
        CALL SUB1_Print(dllhandle, hdl, TT_CANCELACION, 0)

        // impacto tender
        CALL SUB1_ImpactTender(dllhandle, hdl, 3)

    ELSE
        CALL SUB1_ShowReply(dllhandle, hdl)
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0
ENDEVENT


// Peticion de Autorizacion Devolucion
EVENT INQ : 5

//    SetreRead

    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var ter             :  A32
    var propina         :  A16
    var dcs_reply       :  A32
    var prt_var         :  A11

    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)

//    @TTLDUE es el monto total

    CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_DEVOLUCION)

// Envio y recibo

    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
    // Si es aprobada
    	CALL SUB1_SaveTender(dllhandle, hdl)
        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_tip_amount", ref propina, 16)

        CALL OpenConfig()
        CALL ReadConfig()

        g_AccumTip = g_AccumTip - propina

        CALL WriteConfig()
        CALL CloseConfig()

        // despliego mensaje
        CALL SUB1_ShowReply(dllhandle, hdl)

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
        CALL TrnFile(0, "prt", prt_var)
        // imprimo
        CALL SUB1_Print(dllhandle, hdl, TT_DEVOLUCION, 0)

        // impacto tender
        CALL SUB1_ImpactTender(dllhandle, hdl, 1)

    ELSE
        CALL SUB1_ShowReply(dllhandle, hdl)
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0
ENDEVENT

// Reimpresion de Cupones
EVENT INQ : 3

//    SetreRead

    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var type_id         :  A4
    var subtype_id      :  A4
    var ter             :  A32
    var tipo            :  N1
    var dcs_reply       :  A32
    var prt_var         :  A11
    gMsr=0
    gMsrMonto=0
    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)

//    @TTLDUE es el monto total

    CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_REIMPRESION)

// Envio y recibo
    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
        // imprimo
        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_type_id", ref type_id, 4)
        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_subtype_id", ref subtype_id, 4)
        
        IF type_id = 57
            tipo = TT_COMPRA_OFF
        ELSEIF type_id = 61
            tipo = TT_COMPRA_ON
        ELSEIF type_id = 121
            IF subtype_id <> 1
                tipo = TT_CANCELACION
            ELSE
                tipo = TT_AJUSTE_TIP
            ENDIF
        ELSEIF type_id = 41
            tipo = TT_DEVOLUCION
        ENDIF

        CALL SUB1_Print(dllhandle, hdl, tipo, 1)

    ELSE
        ErrorMessage "No se puede reimprimir"
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0
ENDEVENT


// Ingreso de Tip
EVENT INQ : 4

//    SetreRead

    var dllhandle       :  N10
    var hdl             :  N3
    var ret             :  N3
    VAR TrnKey          :  A6
    var str             :  A128
    var codres          :  A4
    var ter             :  A32
    var dcs_reply       :  A32
    var propina         :  A16
    var prt_var         :  A11

    CALL GetConfig()

    CALL GetRVC( @RVC )

    CALL SUB1_APIInit(dllhandle, hdl)

//    @TTLDUE es el monto total

    CALL SUB1_MakeDCSREQ(dllhandle, hdl, TT_AJUSTE_TIP)

// Envio y recibo
    CALL SUB1_SendREQ(dllhandle, hdl, codres)
    IF codres < -1
    ELSEIF codres = "-1"
    // Si es aprobada

        CALL OpenConfig()
        CALL ReadConfig()

        g_AccumTip = g_AccumTip - propina

        CALL WriteConfig()
        CALL CloseConfig()

        // despliego mensaje
        CALL SUB1_ShowReply(dllhandle, hdl)

        DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id", ref prt_var, 11)
        CALL TrnFile(0, "prt", prt_var)
        // imprimo
        CALL SUB1_Print(dllhandle, hdl, TT_AJUSTE_TIP, 0)

        // impacto tender
        CALL SUB1_ImpactTender(dllhandle, hdl, 2)

    ELSE
        CALL SUB1_ShowReply(dllhandle, hdl)
    ENDIF

    DLLFree dllhandle
    g_dllhandle=0
ENDEVENT


//*********************************************************************
//
// Printer_State_Analyze
//
// Function: Recieves printer state and displays message if necessary
// Input: Printer state from printer
// Output: None
//
//*********************************************************************
Sub Printer_State_Analyze(ref estado)

    var mensaje:  A40
    var mensaje1:  A40

    IF estado = 1 or estado < 0
        mensaje  = "Tiempo agotado esperando respuesta"
    ELSEIF estado     = 2
        mensaje  = "Impresora no configurada en UWS"
    ELSEIF estado     = 3
           mensaje  = "No hubo respuesta"
           mensaje1 = "desde la impresora"
    ELSEIF estado     = 4
        mensaje  = "No se pudo enviar"
           mensaje1 = "mensaje a la impresora"
    ELSEIF estado     = 5
           mensaje  = "El formato del mensaje"
           mensaje1 = "NO es correcto"
    ELSEIF estado     = 6
           mensaje  = "No coincide la secuencia"
           mensaje1 = "de comunicacion "
    ELSE
           mensaje  = "Error inesperado"
        estado     = 7
    ENDIF

 //report error to user
    errormessage mensaje, " ", mensaje1, " #", estado
EndSub

//**********************************************************************/
// Printer_Response_Analyze
// Analyzes the response from the printer
//
// Input: Printer_Response with string returned from any calling function.
// Output: intResponse set to TRUE if problems encoutered
//
//**********************************************************************/
Sub Printer_Response_Analyze(ref Printer_Response, Ref intResponse)

    var Fiscal_Status   : a4
    var Printer_Status  : a4
    var intCounterX     : n1
    var intBit          : n1
    var PStatus[16]     : a1
    var FStatus[16]     : a1

    Printer_Status = Mid(Printer_Response, 4,4)
    Fiscal_Status = Mid(Printer_Response,9,4)

    For intCounterX = 1 to 16
        intBit = Bit(Printer_Status, intCounterX)
        format PStatus[intCounterX] as intBit

        intBit = Bit(Fiscal_Status, intCounterX)
        format FStatus[intCounterX] as intBit
    EndFor

      //analyze printer status bits...
    if PStatus[12] = TRUE
        ErrorMessage "Impresor Fuera de Papel"
        intResponse = TRUE
    ElseIf PStatus[10] = TRUE
        ErrorMessage "Bufer de impresor lleno"
        intResponse = TRUE
    ElseIf PStatus[11] = TRUE or PStatus[12] = TRUE
        ErrorMessage "Poco papel en impresor"
        intResponse = TRUE
    ElseIf PStatus[13] = TRUE
        ErrorMessage "Impresor fuera de linea"
        intResponse = TRUE
    ElseIf PStatus[14] = TRUE
        ErrorMessage "Error de impresora"
        intResponse = TRUE
    EndIf

    if intResponse = 0
        //analyze fiscal status bits...
        If FStatus[4] = TRUE and Invoice_IsPrinting = FALSE

            ErrorMessage "Documento fiscal abierto-se cancelara"
            Call Invoice_CancelDocument() //cancel invoice
        ElseIf FStatus[5]   = TRUE
            ErrorMessage "Se requiere Cierre Z"
//            CALL XZ_report(ZZ)
        ElseIf FStatus[8]   = TRUE
             ErrorMessage "Memoria fiscal casi llena, favor de llamar a Soporte Tecnico"
        ElseIf FStatus[9]   = TRUE
            ErrorMessage "Memoria fiscal llena. Llame a soporte tecnico inmediatamente"
            intResponse = TRUE
        ElseIf FStatus[10]  = TRUE
            ErrorMessage "Desborde de totales"
            intResponse = TRUE
        ElseIf FStatus[11]  = TRUE
            ErrorMessage "Comando invalido para estado logico-por favor reinicie placa fiscal"
            intResponse = TRUE
        ElseIf FStatus[12]  = TRUE
            ErrorMessage "Campo de datos invalido-llame a Soporte Tecnico"
            intResponse = TRUE
        ElseIf FStatus[13]  = TRUE
            Errormessage "Comando no reconocido-llame a Soporte Tecnico"
            intResponse = TRUE
        ElseIf FStatus[14]  = TRUE
            ErrorMessage "Bateria de impresora baja-llame a Soporte Tecnico"
        ElseIf FStatus[15]  = TRUE
            ErrorMessage "Error de verificacion de memoria-llame a Soporte Tecnico"
            intResponse = TRUE
        ElseIF FStatus[16]  = TRUE
            Errormessage "Error de verificacion de memoria-llame a Soporte Tecnico"
        Endif
    EndIf
EndSub

//**********************************************************************/
// Printer_CheckStatus
// Checks status of printer
//
// Input: None
// Output: intReturnValue set to TRUE if status OK, else FALSE
//**********************************************************************/
Sub Printer_CheckStatus(ref intReturnValue)


    var Printer_State                : n2
    Var Printer_Response            : A200
    var string            : a20
    Call Printer_GetSecuence()
    //build the string to send
    format string as Chr(Printer_Secuence), Chr(&2A)
    //let user know what we're doing
    prompt "Chequeando conexion con impresor..."
        //send command to printer
    FiscalPrint Printer_State, Printer_Response, string

//let calling function know if we had problems
    intReturnValue = Printer_State <> 0
    //if problems, analyze the printer state
    If Printer_State <> 0
            Call Printer_State_Analyze(Printer_State)
    EndIf
    //analyze the printer response
    Call Printer_Response_Analyze(Printer_Response, intReturnValue)
EndSub


//***************************************************************************
// Function name: Printer_OpenDNFH
// Description: Opens a DNFH (Documento No fiscal homologado)
//
// Input: None
// Output: None
//
//***************************************************************************
Sub Printer_OpenDNFH(ref intCancel, var strType : A1, var strIdentification : a19, var intSyncMode : n1)

var string        : A300
    var tempstring    : a30
    var state    : n1
    var response    : a300
    var FS        : A1 = Chr( &1C )
    var intResponse    : n1
    var intCounter    : n1


    //generate a printer secuence
    Call Printer_GetSecuence( )
    //build the output string
    format string as  Chr( Printer_Secuence ), Chr( &80 ), FS,  \
        strType, FS,     "T", FS, strIdentification, FS

//send the command to the printer
    if intSyncMode = SYNCH
        FiscalPrint state, response, string
        //analyze printer response

        Call Printer_Response_Analyze( response, intResponse )
        //check for problems printing
        if state <> 0 or intResponse = 1//problems printing
            if intResponse = 0
                //after anaylzying response, analyze state
                Call Printer_State_Analyze(state)
            endIf

intCancel = TRUE
        Else
            intCancel = FALSE
        EndIf
    elseif intSyncMode = ASYNCH
        Call WriteTransToLog(string)
    endif
EndSub

//Generate a secuence number
Sub Printer_GetSecuence( )

    if Printer_Secuence >=127 or Printer_Secuence < 35
        Printer_Secuence = 35
    Else
        Printer_Secuence = Printer_Secuence + 1
    EndIf

EndSub

//***************************************************************************
// Function name: Print_CreditCard
// Description: Print a Credicard Voucher
//              DNFH for Epson
// Input: None
// Output: None
//
//***************************************************************************
SUB SUB1_Print(VAR dllhandle : N10, VAR hdl : N3, VAR tipo : N1, VAR duplicado : N1)

    VAR ii       : N2
    VAR FileName : A32
    VAR FileHandle : N5
    VAR string              : A500
    VAR tempstring          : A30
    VAR state               : N9
    VAR status_msg 	    : A100	
    VAR response            : A600
    VAR error_message       : A300
    VAR intCancel           : A1
    var fp_handle           : N10

    VAR FS                              : A1  = CHR( &1C ) // Field Separator
    VAR command                         : A1  = CHR( &4F ) // Fiscal Command
    VAR STX                             : A1  = CHR( &02 ) // Start Data
    VAR ETX                             : A1  = CHR( &03 ) // End Data
    VAR NFDN                            : A2  = "1"        // Non Fiscal Document Number
    VAR DPL                             : A1  = CHR( &7F ) // Don't Print Line
    VAR PL                              : A1  = "P"        // Print Line

    VAR intResponse         : n1
    VAR intCounter          : n1

    VAR tmp_amount                      : $12
    VAR print_amount                    : N12
    VAR tmp_tip                         : $12
    VAR tmp_pro_name                    : A20
    VAR tmp_name                        : A23
    VAR tmp_merchant                    : A16
    VAR tmp_terminal                    : A16
    VAR tmp_operation_name              : A20
    VAR tmp_operation                   : A20
    VAR tmp_expiration                  : A6
    VAR tmp_ticket                      : A4
    VAR tmp_checkid                     : A20 = ""
    VAR tmp_tarjeta                     : A20
    VAR tmp_qty_pay                     : A2
    VAR tmp_currency                    : A15
    VAR tmp_batch                       : A10
    VAR tmp_autoriz                     : A6
    VAR tmp_importe                     : A16
    VAR tmp_id                          : A12
    VAR vencimiento                     : A6
    VAR tmp_last4                       : A4 
	Var sFCRResp			: A500
    
    CALL OpenConfig()
    CALL ReadConfig()
    CALL CloseConfig()

    CALL GetRVC( @RVC )

    
//Control de Producto
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_pro_name"         , ref tmp_pro_name      ,  20)
    IF tmp_pro_name = ""
        tmp_pro_name = DPL
    ENDIF

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_exp_date"         , ref vencimiento       ,  5)
    IF vencimiento = ""
        vencimiento = "0000"
    ENDIF
    

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_name"             , ref tmp_name      ,  23)
    IF tmp_name = ""
       tmp_name = DPL
    ENDIF

    FORMAT tmp_expiration AS vencimiento, "01"
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_external_mer_id"  , ref tmp_merchant      ,  16)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_external_ter_id"  , ref tmp_terminal      ,  16)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_ticket_number"    , ref tmp_ticket        ,  5)
    IF tmp_ticket = ""
        tmp_ticket = "0000"
    ENDIF
//    tmp_checkid  = MID( IsoArray[ 65 ], 4,  6 )
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_qty_pay"          , ref tmp_qty_pay       ,  3)
    IF tmp_qty_pay = ""
        tmp_qty_pay = "01"
    ENDIF
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_bat_number_external", ref tmp_batch       ,  5)
    IF tmp_batch = ""
        tmp_batch = DPL
    ENDIF
    
    
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_card_number"      , ref tmp_tarjeta       ,  21)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_auth_code"        , ref tmp_autoriz       ,  7)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_amount"           , ref tmp_importe       ,  16)
    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_id"               , ref tmp_id            ,  13)

    DLLCall dllhandle, MICROSAPI_GetString(ref ret, hdl, "trn_cur_id1"          , ref tmp_currency      ,  4)
    IF tmp_currency <> "840"
       tmp_currency = "Pesos"
    ELSE
       tmp_currency = "Dolares"
    ENDIF
    
    tmp_amount = tmp_importe

    tmp_last4 = MID(tmp_tarjeta, LEN(tmp_tarjeta) - 3, 4)
    FORMAT tmp_tarjeta AS MID("********************", 1, LEN(tmp_tarjeta) - 4), tmp_last4 
    
    IF tipo = TT_COMPRA_ON OR tipo = TT_COMPRA_OFF  // Tipo es venta
       tmp_operation_name = "CP"
    ELSEIF tipo = TT_CANCELACION // tipo es cancelacion
       tmp_operation_name = "AN"
    ELSEIF tipo = TT_DEVOLUCION// tipo es devolucion
       tmp_operation_name = "DV"
    ENDIF

    intCancel = FALSE

    FOR ii = 1 TO g_print_copies

        //generate a printer secuence
					//InfoMessage "3 Recibo"
        CALL Printer_GetSecuence( )

        print_amount = ToInteger( tmp_amount )

//        IF intCancel = TRUE
//            BREAK
//        ENDIF

        IF duplicado = 1
            FORMAT tmp_operation AS "R", tmp_operation_name
        ELSE
            IF ii = 1
                FORMAT tmp_operation AS "O", tmp_operation_name
            ELSEIF ii = 2
                FORMAT tmp_operation AS "C", tmp_operation_name
            ELSE
                FORMAT tmp_operation AS tmp_operation_name
            ENDIF
        ENDIF
        
        //build the output string
        FORMAT string AS tmp_pro_name{6}, FS, tmp_tarjeta{19}, FS, DPL, FS,\
                 tmp_expiration, FS, tmp_merchant{11}, FS, tmp_ticket{4}, FS,\
                 DPL, FS, tmp_autoriz{6}, FS, tmp_operation{5},tmp_id{>10}, FS,\
                 print_amount{08}, FS, tmp_qty_pay, FS, tmp_currency{1}, FS,\
                 tmp_terminal, FS, tmp_batch{3}, FS,\
                 DPL, FS, DPL, FS, DPL, FS, DPL, FS,\
                 PL, FS, PL, FS, DPL


            CALL SUB1_FiscalAPIInit(fp_handle)
            DLLCall fp_handle, Epson_cc_voucher(ref state, ref status_msg, ref response , ref string)
//              DLLCall fp_handle, Epson_cc_voucher(ref state, ref response , ref string)

        
//            FiscalPrint state, response, string

            IF state <> 0
                //1 print retry
                DLLCall fp_handle, Epson_cc_voucher(ref state, ref status_msg, ref response , ref string)
//                DLLCall fp_handle, Epson_cc_voucher(ref state, ref response , ref string)
                IF state <> 0
		    FORMAT error_message AS "Error  ", state , "  en impresion de operacion aprobada",\
		    " NO pase la tarjeta de nuevo"
                    ErrorMessage error_message
                    //CALL TrnFile(0, "per", response)
	            //ErrorMessage status_msg  
                    intCancel = TRUE
                ENDIF

//                CALL Printer_Response_Analyze( response, intResponse )
                //check for problems printing
//                IF state <> 0 or intResponse = 1 //problems printing
//                    IF intResponse = 0
//                        //after anaylzying response, analyze state
//                        CALL Printer_State_Analyze( state )
//                    ELSE
//                    ENDIF
//                    intCancel = TRUE
//                ELSE
//                    intCancel = FALSE
//                ENDIF
            ENDIF
        ENDIF
         //por rewards
        IF (fp_handle<>0)
            Dllfree fp_handle
            //g_dllhandle=0
            g_fp_handle=0
        ENDIF
    ENDFOR

ENDSUB


