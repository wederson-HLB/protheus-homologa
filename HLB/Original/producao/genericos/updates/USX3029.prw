/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUSX3029     บAutor  ณEduardo C. Romanini บ Data ณ  20/05/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณUpdate que transforma o campo D2_DIRF em usado.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HLB BRASIL                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*---------------------*
User Function USX3029(o)
*---------------------*

If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"FAT",{|o| USX3029(o)}} }
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente nใo estEpreparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf

Return .T.   

*------------------------*
Static Function USX3029(o)
*------------------------*

//           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"   ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"         ,"X3_DESCSPA"         ,"X3_DESCENG"         ,"X3_PICTURE"         ,"X3_VALID"                                       ,"X3_USADO"    ,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV"          ,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER","X3_CBOX"                                                                   ,"X3_CBOXSPA"                                                                ,"X3_CBOXENG"                                                                ,"X3_PICTVAR" ,"X3_WHEN"             ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"
Aadd(o:aSX3,{            ,           ,"E2_DIRF"    ,           ,             ,             ,              ,              ,              ,                     ,                     ,                     ,                     ,                                                 ,TODOS_MODULOS ,                 ,        ,           ,                     ,           ,             ,            ,            ,            ,            ,            ,             ,                                                                            ,                                                                            ,                                                                            ,             ,                      ,            ,            ,            ,           ,            ,           ,           ,            ,          , })


Return Nil
