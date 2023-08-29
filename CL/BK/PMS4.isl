// Micros 3700 version
//
// Purpose: Quickly identify the Workstation
//
// Display and print the Workstation Name and some other information
//
// Press "Clear" to exit the script
//
// Set a "SIM" interface
//
// Create a "SIM/PMS Inquire" button with the "Inquire Number"= 1
//
// On the "Login" or "Manager" screen
//
// Boris Vasiliev      bvasiliev@hotmail.com       November 14 2008

event inq : 1

var	Header		: a40
var	Date		: a40
var	Server		: a40
var	Workstation	: a40
var	RVC		: a40
var	Serving_P	: a40
var	Cashier		: a40
var	MLevel		: a40
var	OrderType	: a40

   format Date          as "Date - Time   : "{<17},   \
                             @Day{02},     "/",	      \
                             @Month{02},   "/",       \	
                             @Year{02},	   "-",	      \
                             @Hour{02},    ":",       \
                             @Minute{02},  ":",       \
                             @Second{02}


   format Header         as "Workstation Status"{=38}  
   format Server         as "Server Name   :"{<16}, "       " {7},@servername{<16}  
   format Workstation    as "Workstation   :"{<16}, @wsid {>6}," ", @wsname {<16}
   format RVC            as "RVC           :"{<16}, @rvc {>6}," ", @rvcname {<16}
   format Serving_P      as "Serving Period:"{<16}, @srvprd {>6}, " "
   format Cashier        as "Cashier       :"{<16}, @cashier{>6}," ", @cashier_name {<16}
   format OrderType      as "Order Type    :"{<16}, @ordertype{>6}
   format MLevel         as "Menu Level/SL :"{<16},  "     ", @mlvl," / ",@slvl


   window  12, 50
     display  1, 1, Header
     display  3, 1, Date
     display  4, 1, Server
     display  5, 1, Workstation
     display  6, 1, RVC
     display  7, 1, Serving_P
     display  8, 1, Cashier
     display  9, 1, OrderType
     display 10, 1, MLevel
     display 12, 1, "Press Clear to exit "{=38}

//   startprint @chk
// startprint @Rcpt

//     printline  Header
//     printline  " "
//     printline  Date
//     printline  " "
//     printline  Server
//     printline  " "
//     printline  Workstation
//     printline  " "
//     printline  RVC
//     printline  " "
//     printline  Serving_P
//     printline  " "
//     printline  Cashier
//     printline  " "
//     printline  OrderType
//     printline  " "
//     printline  MLevel

//   endprint

        waitforclear

endevent
