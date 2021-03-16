#include 'protheus.ch'
#include 'parmtype.ch'
#include "TOTVS.CH"
#include "SHELL.CH"
#Include "Ap5mail.ch"
#Include "TopConn.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Programa  * GTFAT016.PRW *                                              ³±?
±±?Autor     * Guilherme Fernandes Pilan - GFP *                           ³±?
±±?Data      * 06/02/2017 - 09:29 *                                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao * Estrutura de envio de e-mail *                              ³±?
±±?          * Utilização automatica, após a transmissão da NFS-e *        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       * FATURAMENTO                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*-------------------------------------*
User Function GTFAT016(lEmail,cBoleto)
*-------------------------------------*
Local aOrd	:= SaveOrd({"SA1","SE1","SF3","SC5","SD2","CN9"})
Local cTo := "", cCC := "", cEmailUser := ""
//Local lEmail := .T.
Default lEmail := .F.
Default cBoleto := ""

Begin Sequence

	If lEmail // Chamada atraves dos fontes de geração de boletos.
		//AOA - 27/10/2017 - Ajuste para envio de mais de um boleto anexo quando tem parcela - Ticket 16886
		If AT(";",cBoleto) > 0
			cBolParc := SUBSTR(cBoleto, 1, AT(";", cBoleto) - 1)
		Else
			cBolParc := cBoleto
		EndIf
		If !File(cBolParc)
			Alert("Boleto não gerado ou não localizado.","Grant Thornton")
			Break
		EndIf

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			cTo += AllTrim(SA1->A1_P_EMAIC)
		EndIf
		
		cCC += If(cEmpAnt == "Z8","nfc@br.gt.com; ","nfe@br.gt.com; ")
		If !Empty(cEmailUser := UsrRetMail(__cUserID))
			cCC += AllTrim(cEmailUser) + "; "
		EndIf

		//cCC += EmailSocio()//Retirado - chamado 041240    

		Processa({|| EnvEmail(cTo, cCC, cBoleto) } ,"Envio de e-mail","Processando envio de e-mail...")
		
		
	Else // Chamada atraves do ponto de entrada "F022ATUNF".
		//AOA - 27/10/2017 - Ajuste para envio de mais de um boleto anexo quando tem parcela - Ticket 16886
		cQry:=" SELECT E1_PARCELA FROM "+RETSQLNAME("SE1")
		cQry+=" WHERE E1_NUM='"+SF2->F2_DUPL+"' AND D_E_L_E_T_='' AND E1_PREFIXO='"+SF2->F2_PREFIXO+"'"
		cQry+=" AND E1_TIPO='NF' AND E1_CLIENTE+E1_LOJA='"+SF2->(F2_CLIENTE+F2_LOJA)+"' "
		cQry+=" AND E1_FILORIG='"+SF2->F2_FILIAL+"'"
		
		if select("TEMPE1")>0
			TEMPE1->(DbCloseArea())
		endif
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TEMPE1",.T.,.T.)
		
		SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL+TEMPE1->E1_PARCELA+"NF "))
			If !U_GTCORP84(.T.)  //Geração de Boleto
				Alert("Não foi possível efetuar a geração do boleto.","Grant Thornton")
			EndIf
		EndIf

	EndIf

End Sequence

RestOrd(aOrd,.T.)
Return NIL

*----------------------------------------------------*
Static Function EnvEmail(cTo, cCC, cAnexo)
*----------------------------------------------------* 
Local i, cServer, cAccount, cLink, cNotaEltr, cIM, cCodVerif
Local xRet, lEnvioOK := .T.
Local cEmail := ""

IF EMPTY(cServer := AllTrim(GetNewPar("MV_RELSERV","")))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY(cAccount := AllTrim(GetNewPar("MV_RELACNT","")))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF

cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email

///********* MONTAGEM DE MENSAGEM *********///
oMessage 			:= TMailMessage():New()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= "workflow@br.gt.com"//cAccount//If(cEmpAnt == "Z8","nfc@br.gt.com","nfe@br.gt.com")
oMessage:cReplyTo   := If(cEmpAnt == "Z8","nfc@br.gt.com","nfe@br.gt.com")
oMessage:cTo		:= cTo
oMessage:cCC		:= cCC

//AOA - 27/10/2017 - Ajuste para envio de mais de um boleto anexo quando tem parcela - Ticket 16886
If AT(";",cAnexo) > 0
	aBol := separa(cAnexo,";")
	
	For i:=1 to len(aBol)
		If oMessage:AttachFile(aBol[i]) < 0
			Conout("Não foi possível anexar o arquivo: '" + AllTrim(cAnexo) + "' no e-mail.")
		EndIf
	Next
Else
	If oMessage:AttachFile(cAnexo) < 0
		Conout("Não foi possível anexar o arquivo: '" + AllTrim(cAnexo) + "' no e-mail.")
	EndI
EndIf

cNotaEletr := AllTrim(SF2->F2_NFELETR)
// Para as prefeituras de Porto Alegre e Belo Horizonte, número da NFS deve possuir ANO + NUMERO (2017/0000054)
If SM0->M0_CODMUN == "4314902" .OR. SM0->M0_CODMUN == "3106200" // PORTO ALEGRE / BELO HORIZONTE
	cNotaEletr := AllTrim(cValToChar(Year(SF2->F2_EMINFE))+"/"+cNotaEletr)
EndIf

//AOA - 27/10/2017 - Ajuste para envio de mais de um boleto anexo quando tem parcela - Ticket 16886
cQry:=" SELECT E1_PARCELA FROM "+RETSQLNAME("SE1")
cQry+=" WHERE E1_NUM='"+SF2->F2_DUPL+"' AND D_E_L_E_T_='' AND E1_PREFIXO='"+SF2->F2_PREFIXO+"'"
cQry+=" AND E1_TIPO='NF' AND E1_CLIENTE+E1_LOJA='"+SF2->(F2_CLIENTE+F2_LOJA)+"' "
cQry+=" AND E1_FILORIG='"+SF2->F2_FILIAL+"'"

if select("TEMPE1")>0
	TEMPE1->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TEMPE1",.T.,.T.)

SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL+TEMPE1->E1_PARCELA+"NF "))

oMessage:cSubject	:= "Boleto para pagamento em " + DTOC(SE1->E1_VENCREA) + " - " +;
						AllTrim(SM0->M0_NOMECOM) + " - NF. " + AllTrim(cNotaEletr)

cIM := If(SM0->M0_CODMUN == "3509502",StrTran(AllTrim(SM0->M0_INSCM),"0000",""),AllTrim(SM0->M0_INSCM))
cCodVerif := If(SM0->M0_CODMUN == "3304557",StrTran(AllTrim(SF2->F2_CODNFE),"-",""),AllTrim(SF2->F2_CODNFE))

cLink := MontaLink()

cEmail := Email()
cEmail := StrTran(cEmail,"[#CLIENTE]"	, AllTrim(SA1->A1_NOME))
cEmail := StrTran(cEmail,"[#LINK_NFS]"	, If(!Empty(cLink),cLink,""))
cEmail := StrTran(cEmail,"[#NUMERO_NF]"	, cNotaEletr)
cEmail := StrTran(cEmail,"[#COD_VER]"	, cCodVerif)
cEmail := StrTran(cEmail,"[#CNPJ]"		, Transform(StrZero(Val(AllTrim(SM0->M0_CGC)),14),"@R 99.999.999/9999-99"))
cEmail := StrTran(cEmail,"[#INSC_MUN]"	, cIM)

oMessage:cBody		:= cEmail

///********* CONEXÃO DE E-MAIL *********///
oServer := TMailManager():New()
oServer:SetUseTLS(.T.)
cServer := SUBSTR(cServer, 1, AT(":", cServer) - 1)// AOA - 14/09/2017 - Remove a porta do server do parametro MV
xRet := oServer:Init( "", cServer, cAccount, cPassword, 0, 587 )//AOA - 14/09/2017 - Mantem fixo a porta do SMPT e pega só o server do parametro MV
If xRet != 0
	conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SetSMTPTimeout( 60 )
If xRet != 0
    conout( "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout ) ) 
	lEnvioOK := .F.
EndIf
xRet := oServer:SMTPConnect()
If xRet <> 0
	conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
If lAutentica
	// try with account and pass
	nRet:=oServer:SMTPAuth(cAccount,cPassword)
	If nRet != 0
		// try with user and pass
		nRet := oServer:SMTPAuth(cUserAut,cPassAut)
		If nRet != 0
			conout("[Autentica] FAIL TRY with USER() and PASS()" )
			conout("[Autentica][ERROR] "+str(nRet,6),oServer:GetErrorString(nRet))
			Return .F.
   		Endif
	Endif
Endif 

///********* ENVIO DE E-MAIL *********///
xRet := oMessage:Send( oServer )
If xRet <> 0
    cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
    lEnvioOK := .F.
EndIf

xRet := oServer:SMTPDisconnect()
If xRet <> 0
    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
EndIf

If !lEnvioOK
	Alert("Não foi possível enviar o e-mail com NFS-e e Boleto.")
EndIf
Return lEnvioOK

*------------------------------------*
Static Function Email(aHeader,aDetail)
*------------------------------------*  
Local cAux := ""
Local cHtml := ""

cHtml += '<html>'
cHtml += '	<span style="font-size:11.5pt;font-family:&quot;Arial&quot;,&quot;serif&quot;;color:black">'
cHtml += '		[#CLIENTE],<br><br>'
cHtml += '		Nesta mensagem encontra-se o link da Nota Fiscal de Servi&ccedil;os Eletr&ocirc;nica (NFS-e).<br>'
cHtml += '		[#LINK_NFS]'
cHtml += '		<br><br>'
cHtml += '		Caso n&atilde;o consiga visualizar a NFS-e atrav&eacute;s do link acima citado, acessar o site da prefeitura e digitar os dados abaixo:'
cHtml += '		<br><br>'
cHtml += '		N&uacute;mero NF: [#NUMERO_NF]<br>'
cHtml += '		C&oacute;digo Verificador: [#COD_VER]<br>'
cHtml += '		CNPJ do Prestador de Servi&ccedil;os: [#CNPJ]<br>'
cHtml += '		Inscri&ccedil;&atilde;o Municipal do Prestador de Servi&ccedil;os: [#INSC_MUN]'
cHtml += '		<br><br>'
cHtml += '		Segue tamb&eacute;m o boleto correspondente para programa&ccedil;&atilde;o de pagamento. '
cHtml += '		Conforme as condi&ccedil;&otilde;es contratuais, efetivaremos a aplica&ccedil;&atilde;o de cobran&ccedil;a de juros '
cHtml += '		e multa para pagamentos em atraso. As prorroga&ccedil;&otilde;es tamb&eacute;m ser&atilde;o acrescidas de encargos.<br>'
cHtml += '		Caso encontre alguma diverg&ecirc;ncia nas informa&ccedil;&otilde;es, por favor entre em contato atrav&eacute;s dos e-mails'
//WFA - 26/06/2018 - Alteração dos endereços de email que apareceram no corpo do email. Ticket: #36651
//CAS - 01/10/2018 - Alteração dos endereços de email que apareceram no corpo do email. Ticket: #46806 - De: ricardo.souza@br.gt.com - Para: fernando.brasao@br.gt.com
cHtml += '		<a href="mailto:fernando.brasao@br.gt.com">'
cHtml += '			fernando.brasao@br.gt.com'
cHtml += '		</a> e'
cHtml += '		<a href="mailto:adilson.moura@br.gt.com">'
cHtml += '			adilson.moura@br.gt.com'
cHtml += '		</a>.'
cHtml += '		<br>'
cHtml += '		Qualquer d&uacute;vida, estamos &agrave; disposi&ccedil;&atilde;o.'
cHtml += '	</span>'
cHtml += '	<br>'
cHtml += '	<style type="text/css">.MsgBody-text, .MsgBody-text * { font: 10pt monospace; }</style>'				
cHtml += '	<p>'
cHtml += '		<span style=font-size:10pt;font-family:"sans-serif";color:black>'
cHtml += '			Grant Thornton Brasil<br>'
//WFA - 26/06/2018 - Alteração do endereço na assinatura do email. Ticket: #36651
cHtml += '			Av Alfredo Egídio de Souza Aranha, 100 - Bloco B, 12º andar &#124; Chácara Santo Antonio &#124; S&atilde;o Paulo&#47;SP &#124; 04726-170 &#124; BR<br>'
cHtml += '		</span>'
cHtml += '		<span style=font-size:9.5pt;font-family:"Arial";color:#4C2D7F;font-weight:bold>T (office) '
cHtml += '		</span>'
cHtml += '		<span style=font-size:10pt;font-family:"sans-serif";color:black>'
cHtml += '			<a href="about:blank" target="_blank">'
cHtml += '				+55 11 3886-4800'
cHtml += '			</a><br>'
cHtml += '		</span>'
cHtml += '		<span style=font-size:9.5pt;font-family:"Arial";color:#4C2D7F;font-weight:bold>W '
cHtml += '		</span>'
cHtml += '		<span style=font-size:10pt;font-family:"sans-serif";color:black>'
cHtml += '			<a href="http://www.grantthornton.com.br">'
cHtml += '				www.grantthornton.com.br'
cHtml += '			</a><br>'
cHtml += '		</span>'
cHtml += '	</p>'
cHtml += '	<p>'
cHtml += '		<span lang="EN-US" style=font-size:8pt;font-family:Arial;color:#009B76>'
cHtml += '			Please consider the environment before printing this email.'
cHtml += '		</span>'
cHtml += '	</p>'
cHtml += '</html>'

Return cHtml

*--------------------------*
Static Function MontaLink()
*--------------------------*
Local cLinkNFS := GetLink(AllTrim(SM0->M0_CODMUN))
cLinkNFS := STRTran(cLinkNFS,"[#NUMERO_NF]",AllTrim(SF2->F2_NFELETR))  
cLinkNFS := STRTran(cLinkNFS,"[#IM]",AllTrim(SM0->M0_INSCM))
cLinkNFS := STRTran(cLinkNFS,"[#COD_VER]",If(SM0->M0_CODMUN == "3304557",StrTran(AllTrim(SF2->F2_CODNFE),"-",""),AllTrim(SF2->F2_CODNFE)))
Return cLinkNFS

*-----------------------------------*
Static Function GetLink(cMunicipio) 
*-----------------------------------*
Local cLink := ""

Do Case
	Case cMunicipio == "3550308"	//"SAO PAULO"
		cLink := "https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?nf=[#NUMERO_NF]&inscricao=[#IM]&verificacao=[#COD_VER]&returnurl=..%2fpublico%2fverificacao.aspx%3ftipo%3d0"
	Case cMunicipio == "3304557"	//"RIO DE JANEIRO"
		cLink := "https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?ccm=[#IM]&nf=[#NUMERO_NF]&cod=[#COD_VER]"
	Case cMunicipio == "4314902"	//"PORTO ALEGRE"
		cLink := "https://nfe.portoalegre.rs.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf"
	Case cMunicipio == "3106200"	//"BELO HORIZONTE"
		cLink := "https://bhissdigital.pbh.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf"
	Case cMunicipio == "3509502"	//"CAMPINAS"
		cLink := "http://nfse.campinas.sp.gov.br/NotaFiscal/verificarAutenticidade.php"
	Case cMunicipio == "4106902"	//"CURITIBA"
		cLink := "http://isscuritiba.curitiba.pr.gov.br/portalNfse/autenticidade.aspx"
	Case cMunicipio == "5208707"	//"GOIANIA"
		cLink := "http://www2.goiania.go.gov.br/sistemas/snfse/asp/snfse00210f0.asp"
End Case

Return cLink

*-------------------------------*
Static Function EmailSocio()
*-------------------------------*
Local cEmail := "", nHandle
Local cProc := "uspObterEmailSocioProjeto"
Local aOrd := SaveOrd({"SD2","SC5","SC6"})

Begin Sequence
	If (nHandle := TCLink("MSSQL/dbMIS","10.0.30.5",7894)) < 0
		Break
	EndIf

	If TCSpExist( cProc )
		SD2->(dbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		SC5->(dbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	
		If Empty(SC5->C5_MDCONTR)
			Break
		EndIf
	
		cQuery := "EXEC " + cProc + " 0, '"
		cQuery += SC5->C5_MDCONTR + "', '"
		cQuery += SM0->M0_CODIGO  + "', '"
		cQuery += SM0->M0_CODFIL  + "'"
		
		TCQuery cQuery ALIAS "TRB" NEW
		
		TRB->(DbgoTop())
		Do While TRB->(!Eof())
			If !Empty(AllTrim(TRB->EMAILUSUARIO))
				cEmail += AllTrim(TRB->EMAILUSUARIO) + ";"
			EndIf
			TRB->(DbSkip())
		EndDo
	EndIf

End Sequence

If nHandle > 0
	TCUnlink(nHandle)
EndIf
If Select("TRB") # 0
	TRB->(DbCloseArea())
EndIf
RestOrd(aOrd,.T.)
Return cEmail