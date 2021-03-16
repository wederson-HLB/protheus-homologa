#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP47
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relatorio informando o cliente e o vendedor vinculado (gerente de conta)
Autor       : Adriane Sayuri Kamiya
Revisão		:
Data/Hora   : 10/10/2012 18:38
Módulo      : Faturamento
*/

/*
Funcao      : GTCORP47()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da rotina principal do relatório
Autor       : Adriane Sayuri Kamiya
Data/Hora   : 10/10/2012
*/
*----------------------------*
User Function GTCORP47(aParam)
*----------------------------*
Local 	cEmail		:= ""
Local	aUsuario	:= {}
Local 	nPos		:= 0
Private cPerg   	:="GTCORP47_P"
Private cEmpTitulo	:=""
    
cEmpTitulo:= Alltrim(SM0->M0_NOME)

cAssunto:="Relacao clientes x gerente conta, "+cEmpTitulo

	//Definição das perguntas.
	PutSx1( "GTCORP47_P", "01", "Cliente de?"		, "Cliente de?"		, "Cliente de?"		, "", "C",06 ,00,00,"C","" , "CLI","","","MV_PAR01","","","","")
	PutSx1( "GTCORP47_P", "02", "Cliente Ate?"		, "Cliente Ate?"	, "Cliente Ate?"	, "", "C",06 ,00,00,"C","" , "CLI","","","MV_PAR02","","","","")
	PutSx1( "GTCORP47_P", "03", "Vendedor de?"	    , "Vendedor de?"	, "Vendedor de?"	, "", "C",06 ,00,00,"C","" , "SA3","","","MV_PAR03","","","","")
	PutSx1( "GTCORP47_P", "04", "Vendedor Ate?"	    , "Vendedor Ate?"	, "Vendedor Ate?"	, "", "C",06 ,00,00,"C","" , "SA3","","","MV_PAR04","","","","")
	PutSx1( "GTCORP47_P", "05", "Excel/E-mail?"	    , "Excel/E-mail?"	, "Excel/E-mail?"	, "", "C",06 ,00,00,"C","" , "","","","MV_PAR05","Excel","Excel","Excel","","E-mail","E-mail","E-mail","")
	                                        

	If !Pergunte(cPerg,.T.)
		Return()
	EndIf


Private cQry1:=""
Private cHtml:=""
Private nICor:=0


//Montagem da Query  
	cQry1 :=" SELECT "+CRLF
	cQry1 +=" SA1.A1_COD, "+CRLF
	cQry1 +=" SA1.A1_NOME,  "+CRLF
	cQry1 +=" SA1.A1_CGC, "+CRLF
	cQry1 +=" SA1.A1_VEND, "+CRLF
	cQry1 +=" SA3.A3_COD, "+CRLF
	cQry1 +=" SA3.A3_NOME, "+CRLF
	cQry1 +=" SA3.A3_EMAIL, "+CRLF
	cQry1 +=" SA3.A3_P_REMAI  "+CRLF
	cQry1 +=" FROM   " +CRLF
	cQry1 += RETSQLNAME("SA1")+ "  SA1,  "+CRLF
	cQry1 += RETSQLNAME("SA3")+ "  SA3   "+CRLF
	cQry1 +=" WHERE SA1.D_E_L_E_T_ = '' "
	cQry1 +=" AND SA3.D_E_L_E_T_ = '' " 
	cQry1 +=" AND SA1.A1_VEND = SA3.A3_COD"

	cQry1 +=" AND SA1.A1_COD  BETWEEN '"+Alltrim(MV_PAR01)+"' AND '"+Alltrim(MV_PAR02)+"'
	cQry1 +=" AND SA3.A3_COD  BETWEEN '"+Alltrim(MV_PAR03)+"' AND '"+Alltrim(MV_PAR04)+"' 
	
	cQry1 +=" ORDER BY SA1.A1_NOME

	If tcsqlexec(cQry1)<0
		Alert("Ocorreu um problema na busca das informações!!")
		return
	EndIf

if select("TRB47")>0
	TRB47->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRB47",.T.,.T.)

Count to nRecCount

cHtml+=" <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
cHtml+=" <html xmlns='http://www.w3.org/1999/xhtml'>"
cHtml+=" <head>"
cHtml+=" <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
cHtml+=" <title>Propostas</title>"

cHtml+=" <style type='text/css'>"
cHtml+=" .corLinHead {"
cHtml+=" 	background-color: #AA92C7;"
cHtml+="	font-weight:bold;"
cHtml+="	font-size:16px;"
cHtml+="	text-align:center;"
cHtml+=" }"

cHtml+=" .corLinBody {"
cHtml+=" 	background-color: #C2C2DC;"
cHtml+=" }"

cHtml+=" </style>"
cHtml+=" </head>"

cHtml+=" <body>"
cHtml+=" <table border='1'>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead' colspan='15'><font color='#FFFFFF'>"+cEmpTitulo+"</font></td>"
cHtml+=" </tr>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead'>COD CLIENTE</td>"
cHtml+="    <td class='corLinHead'>NOME CLIENTE</td>"
cHtml+="    <td class='corLinHead'>CNPJ</td>"
cHtml+="    <td class='corLinHead'>COD VENDEDOR</td>"
cHtml+="    <td class='corLinHead'>NOME VENDEDOR</td>"
cHtml+="    <td class='corLinHead'>E-MAIL VENDEDOR</td>"
cHtml+="    <td class='corLinHead'>RECEBE E-MAIL</td>"
cHtml+=" </tr>"

if nRecCount>0
	TRB47->(DbGoTop())
	
	While TRB47->(!EOF())
	nICor++
		
		cHtml+=" <tr>"
		cHtml+=" 	<td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB47->A1_COD)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB47->A1_NOME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB47->A1_CGC)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB47->A3_COD)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB47->A3_NOME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB47->A3_EMAIL)+"</td>"
	   	cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB47->A3_P_REMAI )+"</td>"
		cHtml+=" </tr>	"
		TRB47->(DbSkip())
	Enddo
endif

cHtml+=" </table>"
cHtml+=" </body>"
cHtml+=" </html>"

TRB47->(DBCloseArea())
        
If mv_par05 = 1
   GExecl(cHtml)
Else
	aUsuario:= ALLUSERS(.F.)
	nPos	:= aScan(aUsuario,{|x| x[1][1] == __CUSERID })
 	cEmail	:= Alltrim(aUsuario[nPos][1][14])
	If !Empty(cEmail)
		cSubject:="Relatorio de Clientes x Gerente de Conta : "+ Alltrim(SM0->M0_NOME)
		ENVIA_EMAIL(cSubject,cHtml,cEmail)   
		
	Else
		MSGSTOP("Email não cadastrado, entrar em contato com o suporte para atualização!","Grant Thornton Brasil")
	EndIf
EndIf

Return

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para gerar o excel
Autor       : Matheus Massarotto
Data/Hora   : 16/07/2012	17:17
*/
*------------------------------*
Static Function GExecl(cConteu)
*------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

	cArq := "Clientesxvendedores_"+alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cConteu ) // Gravação do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
/***********************GERANDO EXCEL************************************/          

	FERASE (cDest+cArq)

Return

/*
Funcao      : IsEmpty()
Parametros  : cConteudo
Retorno     : cRet
Objetivos   : Função para retornar &nbsp; caso o campo seja braco
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012	17:17
*/
*--------------------------------*
Static Function IsEmpty(cConteudo)
*--------------------------------*
Local cRet:="&nbsp;"

if !empty(cConteudo)
	cRet:=cConteudo
endif

Return(cRet)

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cSubject,cBody,cTo
Retorno     : .T.
Objetivos   : Função para envio do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012
*/

*-----------------------------------------------------------------------------------------*
Static Function ENVIA_EMAIL(cSubject,cBody,cTo)
*-----------------------------------------------------------------------------------------*
Local cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
Local cUser,lMens:=.T.,nOp:=0,oDlg
Local nHora:=VAL(SUBSTR(TIME(),1,2))
Local cBody1:="<p class='style21' style='text-align:justify'>"+IIF(nHora<6,"Boa noite!",IIF(nHora<12,"Bom dia!",IIF(nHora<18,"Boa tarde!","Boa noite!")))+"</p>"
Local cCC      := ""

DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT cTo      := ""

cBody1+="Por favor, verifique o anexo."
cBody1+="<br><br><br><br>"
cBody1+="Este e-mail foi enviado automaticamente pelo Sistema Microsiga Protheus da GRANT THORNTON BRASIL."
	
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

/***********************GERANDO DO ARQUIVO EXCEL, Para anexo************************************/
Private cDest :=  "\"+CURDIR()//Retorna o diretório corrente do servidor   //GetTempPath()

	cArq := "Clientesxvendedores_"+alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cBody ) // Gravação do seu Conteudo.
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		CONOUT("Erro de gravação do Destino. ROTINA: GTCORP47 . Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado	
		cAttachment:=cDest+cArq
	endif
/***********************FIM DA GERAÇÃO DO ARQUIVO EXCEL, Para anexo************************************/

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
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
   ConOut("E-mail enviado com sucesso.")
   Msginfo("E-mail enviado com sucesso.")
ENDIF   

FERASE (cDest+cArq)

RETURN .T.