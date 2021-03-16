#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "ap5mail.ch"

//---------------------------------------------------------------------------------------------------------------//
// Wederson L. Santana - 06/04/05                                                                                //
// Pryor Technology                                                                                              //
//---------------------------------------------------------------------------------------------------------------//
// Especifico Intralox                                                                                           //
//---------------------------------------------------------------------------------------------------------------//

User Function YYSMTP1(_cVar,_cLog)

Local CRLF		:= chr(13)+chr(10)
Local cMSG		:= ""

DbSelectArea("SX6")
If !dbSeek("  MV_PRESTCT")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_PRESTCT"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Email do Setor de Estoque"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
cMsg += '<html>'+CrLf
cMsg += '<font size="3" face="Arial">A T E N Ç Ã O !! </font>'+CrLf+CrLf
If _cLog $ "2"
   cMsg += '<font size="2" face="Arial">Não foi possivel gerar as movimentações para a OP do pedido '+AllTrim(_cVar)+' .</font>'+CRLF
ElseIf _cLog $ "1"
   cMsg += '<font size="2" face="Arial">Existem componentes para a OP do pedido '+AllTrim(_cVar)+' com a quantidade zerada .</font>'+CRLF
Endif   
cMsg += '<font size="2" face="Arial">Usuario '+__cUserId+' - '+SubStr(cUsuario,7,15)+'</font>'+CRLF
cMsg += '<font size="2" face="Arial">'+Substr(Dtos(dDataBase),7,2)+'/'+Substr(Dtos(dDataBase),5,2)+'/'+Substr(Dtos(dDataBase),1,4)+' às '+Time()+'</font>'    +CRLF+CRLF 
cMsg += '<font size="2" face="Arial">E-mail do sistema por favor nao responda.</font>' +CRLF
cMsg += '</body>'+CrLf
cMsg += '</html>'+CrLf        

CONNECT SMTP SERVER GetMv('MV_RELSERV') ACCOUNT GetMv('MV_RELACNT') PASSWORD GetMv('MV_RELPSW') RESULT lConectou

If lConectou
	SEND MAIL FROM GetMv('MV_RELACNT') TO GetMv('MV_PRESTCT') CC '' SUBJECT 'Intralox - Importação' BODY cMsg ;
	RESULT lEnviado
	If lEnviado
	   If _cLog $ "2"
         MsgInfo("Componentes da OP para o pedido "+AllTrim(_cVar)+"."+Chr(13)+" nao encontrada no arquivo BOM.TXT"," A T E N C A O ")
      ElseIf _cLog $ "1"
         MsgInfo("Existem componentes para a OP do pedido"+AllTrim(_cVar)+"."+Chr(13)+"com quantidade zerada no arquivo BOM.TXT"," A T E N C A O ")      
      Endif  
	EndIf
	DISCONNECT SMTP SERVER
Else
   MsgInfo("Problema na conexão no envio do e-mail para o Estoque."+Chr(10)+Chr(13)+" Favor entrar em contato com o departamento de TI da Pryor.", " A T E N C A O ")
EndIf

Return