#include "protheus.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTHDA006
Parametros  : 
Retorno     : Nil
Objetivos   : Conectar em todas as empresas da tabela Z04 e executar o fonte GTGEN013
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2012    16:48
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gen�rico
*/

*-----------------------*
User Function GTHDA006( )
*-----------------------*
Local oServ

Local cIp		:=""
Local nPort		:=0
Local cAmbiente	:=""
Local cEmp		:=""
Local cFil		:=""

Local cSubject	:="Executou a rotina de atualizacao dos campos E2_DIRF e E2_CODRET no GTHD"
Local cBody		:=""
Local cTo		:="matheus.massarotto@br.gt.com"

if Select("SX3")<=0
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa "01" Filial "01"
endif

ENVIA_EMAIL(cSubject,cBody,cTo)

DbSelectArea("Z04")
Z04->(DbSetOrder(1))
Z04->(DbGotop())

While Z04->(!EOF())

	if empty(Z04->Z04_SERVID) .OR. empty(Z04->Z04_PORTA)
		Z04->(DbSkip())
		Loop
	endif

	if alltrim(Z04->Z04_AMB) $ "GTCORP"
		Z04->(DbSkip())
		Loop
	endif
	
	//Para valida��o, retirar
	//if alltrim(Z04->Z04_CODIGO)<>"SH"
	//		Z04->(DbSkip())
	//		Loop
	//	endif

/* Para valida��o
	if alltrim(Z04->Z04_AMB)=="AMB01"
    	cAmb:="ENV01"
	elseif alltrim(Z04->Z04_AMB)=="AMB02"
    	cAmb:="ENV03"
	elseif alltrim(Z04->Z04_AMB)=="AMB03"
    	cAmb:="ENV05"
	elseif alltrim(Z04->Z04_AMB)=="GT01"
    	cAmb:="ENV07"
	elseif alltrim(Z04->Z04_AMB)=="GT02"
    	cAmb:="ENV09"
	elseif alltrim(Z04->Z04_AMB)=="GT03"
    	cAmb:="ENV11"
	elseif alltrim(Z04->Z04_AMB)=="P11_01"
    	cAmb:="P11_01B"
	elseif alltrim(Z04->Z04_AMB)=="P11_04"
    	cAmb:="P11_04B"
	endif
*/	
	cIp			:=alltrim(Z04->Z04_SERVID)
	nPort		:=val(Z04->Z04_PORTA)
	cAmbiente	:=alltrim(Z04->Z04_AMB)
	cEmp		:=alltrim(Z04->Z04_CODIGO)
	cFil		:=alltrim(Z04->Z04_CODFIL)

	//conecta no servidor, (ip,porta,ambiente,empresa,filial)
	oServ:=  RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil)
	
	if valtype(oServ) == 'O'
	
	CONOUT("CONECTOU"+"-----> Ambiente: "+cAmbiente+", Empresa:"+cEmp)
	
		aArray := oServ:CALLPROC("U_GTGEN013") //executa a fun��o para atualiza��o do E2 da empresa
		
		RpcDisconnect(oServ)// --  finaliza a conexao remota
		
	else
		CONOUT("N�o foi poss�vel conectar!"+CRLF+"Ip: "+cIp+CRLF+"Porta: "+cvaltochar(nPort))
	endif

	Z04->(DbSkip())
enddo

Return


/*
Funcao      : ENVIA_EMAIL()
Parametros  : cSubject,cBody,cTo
Retorno     : .T.
Objetivos   : Fun��o para envio do e-mail
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
cBody1+="Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL."
	
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
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autentica��o
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usu�rio para Autentica��o no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autentica��o no Servidor de Email
cTo := AvLeGrupoEMail(cTo)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conex�o com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      BCC "matheus.massarotto@br.gt.com";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "matheus.massarotto@br.gt.com";
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