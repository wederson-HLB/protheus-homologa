#Include "Protheus.ch"
#Include "TbiConn.Ch"

/*
Funcao      : MA030TOK
Parametros  :
Retorno     : lRet
Objetivos   : Fun��o para validar se determinado campo deve ser obrigat�rio, no OK do cadastro de clientes.
TDN			: TUDOK DA INCLUS�O E ALTERA��O
: Na TudOK (valida��o da digita��o) na inclus�o e altera��o de clientes.

Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 26/09/2013    17:10
M�dulo      : Faturamento
*/

*------------------------*
User function MA030TOK
*------------------------*
Local lRet			:= .T.
Local cTitulo		:= ""
Local cDescrFol		:= ""


//Campos para validar na inlcus�o
Local aCamposINC	:= {"A1_CONTA"} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposINC	:= ""

//Campos para validar na exclus�o
Local aCamposALT	:= {} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposALT	:= ""

if INCLUI
	for i:=1 to len(aCamposINC)
		if empty(M->&(aCamposINC[i]))
			
			DbSelectArea("SX3")
			DbSetOrder(2)
			if DbSeek(aCamposINC[i])
				//Nome do campo
				cTitulo:=X3Titulo()
				
				//Busco a pasta do campo
				DbSelectArea("SXA")
				DbSetOrder(1)
				if DbSeek( SX3->X3_ARQUIVO+SX3->X3_FOLDER ) //alias do folder + numero do folder
					cDescrFol := XADescric()
				endif
				
				cCamposINC+="Aba: "+Alltrim(cDescrFol)+" - Campo: " +  alltrim(cTitulo)+" ("+aCamposINC[i]+")"+CRLF
				lRet:=.F.
				
			endif
			
		endif
	next
endif

if ALTERA
	for i:=1 to len(aCamposALT)
		if empty(M->&(aCamposALT[i]))
			
			DbSelectArea("SX3")
			DbSetOrder(2)
			if DbSeek(aCamposALT[i])
				//Nome do campo
				cTitulo:=X3Titulo()
				
				//Busco a pasta do campo
				DbSelectArea("SXA")
				DbSetOrder(1)
				if DbSeek( SX3->X3_ARQUIVO+SX3->X3_FOLDER ) //alias do folder + numero do folder
					cDescrFol := XADescric()
				endif
				
				cCamposALT+="Aba: "+Alltrim(cDescrFol)+" - Campo: " +  alltrim(cTitulo)+" ("+aCamposALT[i]+")"+CRLF
				lRet:=.F.
				
			endif
			
		endif
	next
endif

if !lRet
	MsgStop("� obrigat�rio o preenchimento do(s) campo(s) abaixo:"+CRLF+cCamposINC+cCamposALT,"Aviso")
endif


/*
* Leandro Brito - 18/04/2016
* Faz auditoria dos campos Gerente de Conta, Gerente Contabil e Socio Responsavel . Enviando email em caso de mudan�a de conteudo .
* Observa��o : Este trecho deve ser a ultima parte do fonte , ap�s todas valida��es.
*/
If ALTERA .And. lRet
	VerCampos()
EndIf


Return(lRet)

/*
Fun��o..................: VerCampos
Autor...................: Leandro Brito ( LDB ) - Adaptado atrav�s do fonte MA900TOK.PRW
Data....................: 18/04/2016
Objetivo................: Auditoria dos campos Gerente de Conta, Gerente Contabil e Socio Responsavel . Enviando email em caso de mudan�a de conteudo .
*/
*--------------------------------------------*
Static Function VerCampos
*--------------------------------------------*
Local lRet			:= .T.
Local cAlterou		:= ''
Local lAlterouTES	:= .F.
Local nOrderSX3		:= SX3->(IndexOrd())
Local cNomeCampo	:= ''
Local cCpoSF3		:= ''
Local cCpoMem		:= ''
Local cCompName		:= ComputerName()
Local dData			:= date()
Local cHora			:= Time()
Local cAmbiente		:= GetEnvServer ()
Local cTitulo		:= "Grant Thornton"
Local nX
Private cServer:= GetMV("MV_RELSERV")
Private cEmail := GetMV("MV_RELACNT")
Private cPass  := GetMV("MV_RELPSW")
Private lAuth  := GetMv("MV_RELAUTH")

Private cDe      := padr('WorkFlow@br.gt.com',200)
Private cPara     //padr('diogo.braga@br.gt.com;renata.melloni@br.gt.com;edimilso.junior@br.gt.com;carla.oliveira@br.gt.com;kareane.nascimento@br.gt.com',200) //JSS - Alterado para solucionaro o chamdo 018159.   //MSM - 04/12/14 - Chamado: 021581
Private cCc      := padr('',200)
Private cAssunto := padr('',200)
Private cMsg     := ""
Private cErro    := ""   


SX6->( DbSetOrder( 1 ) )
If SX6->( !DbSeek( Space( 2 ) + 'MV_P_GTSA1' ) )
	SX6->( RecLock( 'SX6' , .T. ) )
	SX6->X6_VAR 	:= 'MV_P_GTSA1'
	SX6->X6_TIPO 	:= 'C'
	SX6->X6_DESCRIC := 'Emails para envio alteracao socio, gerente conta' 	
	SX6->X6_DSCSPA := 'Emails para envio alteracao socio, gerente conta' 	
	SX6->X6_DSCENG := 'Emails para envio alteracao socio, gerente conta' 			
	SX6->X6_DESC1   := 'ou responsavel' 	
	SX6->X6_DSCSPA1 := 'ou responsavel' 	
	SX6->X6_DSCENG1 := 'ou responsavel' 	
	SX6->X6_CONTEUD := ''
	SX6->( MsUnlock() )
EndIf  

cPara := GetMV( 'MV_P_GTSA1' )

cMsg :=  " <body style='background-color: #9370db'>"

cMsg += ' <table height="361px" width="100%" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0">'

cMsg += ' <tr>  '
cMsg += ' <td colspan="4">'
If Val(cHora) < 13
	cMsg += ' Bom dia!<br><br> '
ElseIf Val(cHora) > 12 .and. Val(cHora) < 19
	cMsg += ' Boa tarde!<br><br> '
Else
	cMsg += ' Boa noite!<br><br> '
EndIf
cMsg += ' </td>'

cMsg += ' <tr>'
cMsg += " <td colspan='4'>O cadastro do cliente  <em>"+alltrim(SA1->A1_COD)+"/"+alltrim(SA1->A1_LOJA)+" - "+SA1->A1_NREDUZ+If(!Empty(M->A1_CGC), "[" + M->A1_CGC + "]" , "" ) + "</em> foi alterado pelo usu�rio <em>"+cUserName+"</em> na m�quina <em> "+cCompName+"</em> no dia <em>"+dtoc(dData)+"</em> �s <em>"+cHora+"</em> hrs.  "
cMsg += " </td> "
cMsg += ' </tr>'

cMsg += ' <tr>'
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td> '
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td>'
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td> '
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>'
cMsg += ' </tr>'

SX3->(DbSetOrder(2))
cMsg += ' <tr>'
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td> '
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td>'
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td> '
cMsg += ' <td width="100" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>'
cMsg += ' </tr>'

cMsg += ' <tr>'
cMsg += ' <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Campo </b></font></td> '
cMsg += ' <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Conte�do Anterior </b></font></td>'
cMsg += ' <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b> Alterado Para </b></font></td> '
cMsg += ' <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>'
cMsg += ' </tr>'
aFields := { "A1_P_GECTA" , "A1_P_GECTB" , "A1_P_SORES" }
nLenSX3 := Len( SX3->X3_CAMPO )
For nX := 1 To Len( aFields )
	cCampo := PadR( aFields[ nX ] , nLenSX3 )
	cAssunto :="Cadastro de Clientes:  - Empresa : " + Alltrim(SM0->M0_NOME)+" / Ambiente: "+ Upper(cAmbiente)
	If SA1->(FieldPos(cCampo)) # 0
		If SA1->&(cCampo) <>  M->&(cCampo)
			lAlterouTES := .T.
			SX3->(DbSeek(cCampo))
			cNomeCampo:= SX3->X3_TITULO
			cMsg += '<tr>'
			cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+cNomeCampo+'</td>'
			
			cCpoSA1 := U_GTSXB002( SA1->&(cCampo) )
			cCpoMem := U_GTSXB002( M->&(cCampo) )
			cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">' + cCpoSA1 + '</td>'
			cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">' + cCpoMem + '</td>'
			cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </td>'
			cMsg += '</tr>'
		EndIf
	EndIf
Next
cMsg += '<tr>'
cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </font></td>'
cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td> '
cMsg += '<td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>'
cMsg += '<td width="10" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">   </font></td>'
cMsg += '</tr>'

cMsg += '<tr> '
cMsg += '<td colspan="4">   '
cMsg += '<em><strong>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe TI da GRANT THORNTON BRASIL. </Strong></em> '
cMsg += '</td>'
cMsg += '</tr>  '

cMsg     += '</Table><BR>' +CRLF


If Empty(cServer) .And. Empty(cEmail) .And. Empty(cPass)
	MsgAlert("N�o foram definidos os par�metros do server do Protheus para envio de e-mail",cTitulo)
	Return
Endif

If lAlterouTES
	IF ValidaEmail()
		Eval({||EnviaEmail()})
	EndIf
EndIf

SX3->(DbSetOrder(nOrderSX3))
Return .T.

STATIC FUNCTION ValidaEmail()
Local lRet := .T.

If Empty(cDe)
	MsgInfo("Campo 'De' preenchimento obrigat�rio",cTitulo)
	lRet:=.F.
Endif
If Empty(cPara) .And. lRet
	MsgInfo("Campo 'Para' preenchimento obrigat�rio",cTitulo)
	lRet:=.F.
Endif
If Empty(cAssunto) .And. lRet
	MsgInfo("Campo 'Assunto' preenchimento obrigat�rio",cTitulo)
	lRet:=.F.
Endif

If lRet
	cDe      := AllTrim(cDe)
	cPara    := AllTrim(cPara)
	cCC      := AllTrim(cCC)
	cAssunto := AllTrim(cAssunto)
Endif

RETURN(lRet)

STATIC FUNCTION EnviaEmail()
Local lResulConn := .T.
Local lResulSend := .T.
Local cError := ""

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

lAuth    := GetMv("MV_RELAUTH")
If lAuth
	lOk := MailAuth( cEmail ,GetMV("MV_RELAPSW"))
	If !lOk
		lOk := QAGetMail()
	EndIf
EndIf

If !lResulConn
	GET MAIL ERROR cError
	MsgAlert("Falha na conex�o "+cError)
	Return(.F.)
Endif


SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg  RESULT lResulSend

GET MAIL ERROR cError
If !lResulSend
	MsgAlert("Falha no Envio do e-mail " + cError)
Endif

DISCONNECT SMTP SERVER


Return .T.
