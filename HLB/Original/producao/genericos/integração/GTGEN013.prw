#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTGEN013
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fonte para atualizar o E2_CODRET e E2_DIRF dos títulos de IRRF
Autor       : Matheus Massarotto
Data/Hora   : 28/02/2013    16:39
Revisão		:
Data/Hora   :
Módulo      : Generico
*/

*---------------------*
User function GTGEN013
*---------------------*
Local cQry		:=""
Local cSubject	:="Falha na atualizacao do Codigo Retencao, Empresa:"+cEmpAnt+", Filial:"+cFilAnt
Local cBody		:=""
Local cTo		:="log.sistemas@hlb.com.br"
  			
cQry+=" UPDATE "+RETSQLNAME("SE2")+" SET E2_DIRF='1',E2_CODRET='1708'"
cQry+=" WHERE E2_NATUREZ IN ( '4202','4602') AND D_E_L_E_T_=''"
cQry+=" AND E2_CODRET=''"
cQry+=" AND ( (E2_TIPO = 'NF' AND E2_IRRF>0) OR (E2_TIPO = 'TX') )"
cQry+=" AND E2_ORIGEM='MATA100'"
cQry+=" AND E2_SALDO>0"

	if tcsqlexec(cQry)<0
		CONOUT("FONTE-->GTGEN013, Empresa:"+cEmpAnt+", Filial:"+cFilAnt+" - Ocorreu um erro na execução do update: "+TCSQLError())
		cBody:="FONTE-->GTGEN013, Empresa:"+cEmpAnt+", Filial:"+cFilAnt+" - Ocorreu um erro na execução do update: "+TCSQLError()
		ENVIA_EMAIL(cSubject,cBody,cTo)
	endIf

Return

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cSubject,cBody,cTo
Retorno     : .T.
Objetivos   : Função para envio do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 28/02/2012
*/
*----------------------------------------------*
Static Function ENVIA_EMAIL(cSubject,cBody,cTo)
*----------------------------------------------*
Local cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
Local cUser,lMens:=.T.,nOp:=0,oDlg
Local nHora:=VAL(SUBSTR(TIME(),1,2))
Local cBody1:="<p class='style21' style='text-align:justify'>"+IIF(nHora<6,"Boa noite!",IIF(nHora<12,"Bom dia!",IIF(nHora<18,"Boa tarde!","Boa noite!")))+"</p>"
Local cCC      := ""

DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT cTo      := ""

cBody1+=cBody
cBody1+="<br><br><br><br>"
cBody1+="Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da HLB BRASIL."
	
IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   

cFrom:=cAccount
cAttachment:=""

cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      BCC "matheus.massarotto@hlb.com.br";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "matheus.massarotto@hlb.com.br";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
   ConOut("E-mail enviado com sucesso.")
ENDIF   


RETURN