#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.Ch"
#INCLUDE "MSGRAPHI.CH" 
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPRINTSETUP.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Empresa  ³ AKRON Projetos e Sistemas                                  ³±±
±±³          ³ Rua Jose Oscar Abreu Sampaio, 113 - Sao Paulo - SP         ³±±
±±³          ³ Fone: +55 11 3853-6470                                     ³±±
±±³          ³ Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ ORRFAT30  ³ Autor ³ Andre Minelli        ³ Data ³19/08/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao RPS e envio por Email                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ORANGE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ORRFAT30

Local cQuery	 := ""
Local nSalta	 := 12
Local nSpRow	 := 2
Local nSpCol	 := 4
Local nMgLine	 := 9
Local nTamLine	 := 2
Local cPara		 := ""
Local cAssunto   := ""
Local cTexto	 := ""
Local cTexto2	 := ""
Local cPerg		 := "ORFT30"
Local aFiles	 := {}
Local aDescrNF	 := {}
Local aPrintServ := {}

Private oMail
Private oMessage
Private cSMTPServer		:= GetMV("MV_RELSERV")
Private cSMTPUser		:= GetMV("MV_RELACNT")
Private cSMTPPass		:= GetMV("MV_RELPSW" )
Private cMailFrom		:= GetMV("MV_RELFROM")

Private nPagina			:= 0
Private cDirMail 		:= "\nfserv\"
Private cDirGer	 		:= "" //Criar um diretorio \NFSERV\ no drive informado
Private oNfServ
Private nErro   	    := 0
Private nPort			:= 587
Private lRetMail		:= .T.
Private lUseAuth		:= GetMv("MV_RELAUTH")
Private nLin  			:= 15
Private aCol		    := {10,25,200,300,400,500,580}
Private cFonte			:= "Helvetica 65 Medium"
Private nLinhas			:= 0
Private cLog			:= ""
Private cServicos	    := ""
Private cSubConta 		:= "0001"

AtuX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
End If

cDirGer	:= mv_par15+cDirMail
MakeDir(cDirGer) //Cria diretorio no local informado no parametro MV_PAR15 (DRIVE)
MakeDir(cDirMail)//Cria diretorio \NFSERV\ ROOTPATH

//Prepara o envio de email
If mv_par11 == 2

	//Exclui os arquivos pre-existentes nos diretorios
	aFilesDel := Directory(cDirMail+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirMail+ aFilesDel[i][1])
	Next i
	aFilesDel := Directory(cDirGer+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirGer+ aFilesDel[i][1])
	Next i

	oMail := TMailManager():New()
	oMail:SetUseSSL(.T.)
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort )
	oMail:SetSmtpTimeOut( 120 )
	nErro := oMail:SmtpConnect()
	
	If lUseAuth
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
	      
		If nErro <> 0
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			MsgAlert("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')',"AKRON")
			lRetMail := .F.
		EndIf
	EndIf
	
	If nErro <> 0
	      
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		MsgAlert(cMAilError+CRLF+"Erro de Conexão SMTP "+str(nErro,4)+CRLF+'Desconectando do SMTP',"AKRON")
		oMail:SMTPDisconnect()
		lRetMail := .F.
	      
	EndIf

End If

cQuery := "SELECT C5.C5_MENNOTA,C5.C5_MENNOT1,C5.C5_XNUMCTR,A1.*,F2.*,F3.* FROM " + RetSqlName("SF2") + " F2 LEFT JOIN " + RetSqlName("SA1") + " A1 ON F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA "
cQuery += " LEFT JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_CLIENTE = F2.F2_CLIENTE AND C5.C5_LOJACLI = F2.F2_LOJA AND C5.C5_NOTA = F2.F2_DOC AND C5.C5_SERIE = F2.F2_SERIE"
cQuery += " LEFT JOIN " + RetSqlName("SF3") + " F3 ON F3.F3_NFISCAL = F2.F2_DOC AND F3.F3_SERIE = F2.F2_SERIE AND F3.F3_CLIEFOR = F2.F2_CLIENTE AND F3.F3_LOJA = F2.F2_LOJA"
cQuery += " WHERE F2.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "' AND F2.F2_EMISSAO <= '" + DTOS(MV_PAR02) + "' AND F2.F2_CLIENTE >= '" + MV_PAR03 + "'"
cQuery += " AND F2.F2_CLIENTE <= '" + MV_PAR04 + "' AND F2_LOJA >= '" + MV_PAR05 + "' AND F2_LOJA <= '" + MV_PAR06 + "' AND F2.F2_DOC >= '" + mv_par07 + "' AND F2.F2_DOC <= '" + mv_par08 + "' AND F2.F2_SERIE >= '" + mv_par09 + "' AND F2.F2_SERIE <= '" + mv_par10 + "' AND F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = ''
cQuery += " ORDER BY F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_DOC, F2.F2_SERIE"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLSF2",.T.,.T.)

While SQLSF2->(!EOF())
	
	nLin := 15
	
	oNfServ:=FWMSPrinter():New("rps_" + alltrim(SQLSF2->F2_CLIENTE)+alltrim(SQLSF2->F2_DOC) + alltrim(SQLSF2->F2_SERIE),6,.F.,,.T.,,,,,,,.F.)
	
	oNfServ:SetPortrait()
	
	oNfServ:cPathPDF := cDirGer
	oNfServ:StartPage()
	
	KImpEstr()

	nLin += nSalta
	
	oNfServ:SetFontEX(9,cFonte,.F.,.T.,.F.)
	
	nTotal     := 0
	nTotalBase := 0
	nTotalIcm  := 0
	nTotalIss  := 0
	
	oNfServ:SetFontEX(9,cFonte,.F.,.T.,.F.)
	nLin += nSalta
	
	cDescricao := ALLTRIM(DescRps())
	aPrintServ := Mtr968Mont(cDescricao,99,5000)
	
	oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
	nLin := 240
	For nZ := 1 to Len(aPrintServ)
		If Alltrim(aPrintServ[nZ]) # ""
			If nZ % 14 == 0
			    
				If nZ <= 14
					If  SuperGetMv( "OR_XGERBOL" , .F. , .T. , Nil )
						nLin += nSalta*14
						KBLTCITI()
						SQLSE1->(DbCloseArea())
					End If
				End If
				
				oNfServ:EndPage()
				oNfServ:StartPage()
				KIMPESTR()
				nLin := 240
				
			Endif
				oNfServ:Say(nLin,aCol[2],Alltrim(aPrintServ[nZ]))
				nLin 	:= nLin + 10
		End If
	Next nZ
	
	nLin += nSalta*5
 
	oNfServ:EndPage()  
	oNfServ:Print()
	
	cNFAnt		:= SQLSF2->F2_DOC
	cNumCtr		:= SQLSF2->C5_XNUMCTR
	cSerAnt		:= SQLSF2->F2_SERIE
	cClienteAnt	:= SQLSF2->F2_CLIENTE
	cLojaAnt	:= SQLSF2->F2_LOJA
	cPara		:= SQLSF2->A1_EMAIL
	dEmissao	:= SQLSF2->F2_EMISSAO
	cTexto2		+= Alltrim(cNFAnt) + " - Número de controle " + Alltrim(cNumCtr) + "<BR>"
	
	AADD(aFiles,{"rps_" + alltrim(SQLSF2->F2_CLIENTE) + alltrim(SQLSF2->F2_DOC) + alltrim(SQLSF2->F2_SERIE) })
	
	SQLSF2->(DbSkip())
	
	If SQLSF2->F2_DOC <> cNFAnt .Or. SQLSF2->F2_SERIE <> cSerAnt
		nLinhas   := 0
	End If
		
	If SQLSF2->F2_CLIENTE <> cClienteAnt .Or. SQLSF2->F2_LOJA <> cLojaAnt
		
		If mv_par11 == 2
			SEndMail(cPara,cAssunto,cTexto,cTexto2,cDirMail,aFiles)
			If !lRetMail
				MsgStop("Erro ao enviar email ref. NF.: " + cNFAnt)
				lRetMail := .T.
			End If
		End If
		aFiles := {}
		nLinhas   := 0
		
	End If
	
End

SQLSF2->(DbCloseArea())

If MV_PAR11 == 2
	//Exclui os arquivos pre-existentes nos diretorios
	aFilesDel := Directory(cDirMail+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirMail+ aFilesDel[i][1])
	Next i
	aFilesDel := Directory(cDirGer+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirGer+ aFilesDel[i][1])
	Next i
End If

MsgInfo("Processo finalizado")

If mv_par11 == 2
	memowrite(cDirGer+"LogMail.txt",cLog)
	ShellExecute("open",cDirGer+"LogMail.txt","","",5)
End If

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ SEndMail  ³ Autor ³ Larson Zordan        ³ Data ³20/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envio de E-Mail                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Conta de E-mail                                     ³±±
±±³          ³ ExpC2: Assunto                                             ³±±
±±³          ³ ExpC3: Corpo de Texto                                      ³±±
±±³          ³ ExpC4: Diretorio Arquivos Anexos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico - .T. - Operacao realizada                          ³±±
±±³          ³        - .F. - Operacao NAO realizada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERAL                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function SEndMail(cPara,cAssunto,cTexto,cTexto2,cDirMail,aFiles)

cAssunto := "Nota Fiscal Orange " + STRZERO(Month(STOD(dEmissao)),2)+"/"+STRZERO(Year(STOD(dEmissao)),4)

cTexto := "<p>Prezado Cliente,</p>"
cTexto += "<p>Informamos a emissão da(s) Nota(s) Fiscal(is):<br>"
cTexto += cTexto2+"</p>
cTexto += "<p>Em caso de dúvidas, favor entrar em contato com:</p>"
cTexto += "<p>Faturamento: faturamento.orange@orange.com"
cTexto += "<br>Cobrança:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;jaqueline.xavier@orange.com</p>"
cTexto += "<p>Para outras dúvidas e esclarecimentos por favor entre em contato com seu Account Manager na Orange."
cTexto += "<br>Este e-mail foi enviado automaticamente.</p>"
cTexto += "<p>&nbsp</p>"
cTexto += "<p>Atenciosamente,</p>"
cTexto += "<p>Orange Business Services</p>"
cTexto += "<img src='http://www.orange.com/extension/orange/design/orangecom/images/logo_40px.png'>"

If lRetMail
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cMailFrom
	oMessage:cTo      := alltrim(cPara)
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cTexto
	oMessage:MsgBodyType( "text/html" )
	
	For i := 1 to len(aFiles)	
		CpyT2S( cDirGer + aFiles[i][1] + ".pdf", cDirMail, .F. )
	Next i
	
	For i := 1 to Len(aFiles)
		oMessage:AttachFile ( cDirMail + aFiles[i][1] + ".pdf" )
	Next i
	
	Processa( {|| nErro := oMessage:Send( oMail ) }, "Aguarde...", "Processando envio de emails...",.F.)
           
	If nErro <> 0
		xError := oMail:GetErrorString(nErro)
		MsgAlert("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")","AKRON")
		lRetMail := .F.
	Else
		cLog += "Email enviado para " + Alltrim(cPara) + " ref. NF " + Replace(cTexto2,"<BR>"," - NF ") + CRLF
	Endif
	
	oMail:SMTPDisconnect()           
EndIf

Return(lRetMail)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BLTCITI  ³ Autor ³ Totvs                 ³ Data ³ 24/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ IMPRESSAO DO BOLETO CITIBANK COM CODIGO DE BARRAS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GERAL                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function KBLTCITI()

Private lEnd     := .F.

Processa({|lEnd|MontaRel()})

Return Nil

Static Function MontaRel()

Local cAlphabt := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local _nParcela
Local nX := 0
Local cNroDoc :=  " "
Local aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     ,; //[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
								Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
								Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText := { MV_PAR19,MV_PAR20,MV_PAR21 }					   
Local nI           := 1
Local aCB_RN_NN    := {}

PRIVATE nVlrAbat   := 0         

cQueryBol := "SELECT TOP 1 * FROM " + RetSqlName("SE1") + " WHERE E1_NUM = '" + SQLSF2->F2_DOC + "' AND E1_PREFIXO = '" + SQLSF2->F2_SERIE + "' AND "
cQueryBol += " E1_CLIENTE = '" + SQLSF2->F2_CLIENTE + "' AND E1_LOJA = '" + SQLSF2->F2_LOJA + "' AND E1_VENCREA >= '" + DTOS(mv_par16) + "' AND E1_VENCREA <= '" + DTOS(mv_par17) + "'"
cQueryBol += " AND D_E_L_E_T_ = ''"

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryBol),"SQLSE1",.T.,.T.)

While SQLSE1->(!EOF()) 
    
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SQLSE1->E1_PORTADO+SQLSE1->E1_AGEDEP+SQLSE1->E1_CONTA,.T.)
	
	aDadosBanco  := {"745",; 																     // [1]Numero do Banco
				     SA6->A6_NREDUZ,;  																  // [2]Nome do Banco
	                 "0001",; // [3]Agência
                    SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),2,10),; 	     // [4]Conta Corrente
                    ""  ,;    	  // [5]Dígito da conta corrente
                    "100"}																		   	  // [6]Codigo da Carteira 

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SQLSF2->A1_NOME)           ,;      	// [1]Razão Social
		AllTrim(SQLSF2->A1_COD )+" - "+SQLSF2->A1_LOJA           ,;      	// [2]Código
		AllTrim(SQLSF2->A1_END )+" - "+AllTrim(SQLSF2->A1_BAIRRO),;      	// [3]Endereço
		AllTrim(SQLSF2->A1_MUN )                            ,;  			// [4]Cidade
		SQLSF2->A1_EST                                      ,;     		// [5]Estado
		SQLSF2->A1_CEP                                      ,;      	// [6]CEP
		SQLSF2->A1_CGC										          ,;  			// [7]CGC
		SQLSF2->A1_PESSOA										}       				// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SQLSF2->A1_NOME)            	 ,;   	// [1]Razão Social
		AllTrim(SQLSF2->A1_COD )+" - "+SQLSF2->A1_LOJA              ,;   	// [2]Código
		AllTrim(SQLSF2->A1_ENDCOB)+" - "+AllTrim(SQLSF2->A1_BAIRROC),;   	// [3]Endereço
		AllTrim(SQLSF2->A1_MUNC)	                             ,;   	// [4]Cidade
		SQLSF2->A1_ESTC	                                     ,;   	// [5]Estado
		SQLSF2->A1_CEPC                                        ,;   	// [6]CEP
		SQLSF2->A1_CGC												 		 ,;		// [7]CGC
		SQLSF2->A1_PESSOA												 }				// [8]PESSOA
	Endif
	
	nVlrAbat   :=  SomaAbat(SQLSE1->E1_PREFIXO,SQLSE1->E1_NUM,SQLSE1->E1_PARCELA,"R",1,,SQLSE1->E1_CLIENTE,SQLSE1->E1_LOJA)

	//Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo. 

	If AllTrim(SQLSE1->E1_PARCELA) $ cAlphabt
		_nParcela := at(AllTrim(SQLSE1->E1_PARCELA),cAlphabt)
	Else
		_nParcela := val(AllTrim(SQLSE1->E1_PARCELA))
	EndIf

	//JSS - Alterado para solucionar o caso 022316
	//Inicio Alteração...
		//cNroDoc	:= Strzero(Val(Alltrim(SQLSE1->E1_NUM)),9)+StrZERO(_nParcela,2)               
		//cDigNNum:=KCALCDp(ALLTRIM(cNroDoc),"1")     
		//cNroDoc	:=cNroDoc+""+cDigNNum   
	If Empty(SQLSE1->E1_NUMBCO)
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		SEE->(DbGoTop())
		//EE_FILIAL + EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA
		SEE->(DbSeek(xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]))
		RecLock("SEE",.F.)
		cNroDoc			:= AllTrim (SEE->EE_FAXATU)
		SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
		MsUnLock()
	
		DbSelectArea("SE1")
		SE1->(RecLock("SE1",.f.))
		SE1->E1_NUMBCO 	:=	cNroDoc  
		SE1->(MsUnlock())
		Else
			cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
		EndIf
	//Fim Alteração.
	
	//Monta codigo de barras
	aCB_RN_NN    := Ret_cBarra( SQLSE1->E1_PREFIXO	,SQLSE1->E1_NUM	,SQLSE1->E1_PARCELA	,SQLSE1->E1_TIPO	,;
						       Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[4] ,aDadosBanco[5]	,;
						       cNroDoc		,(SQLSE1->E1_VALOR-nVlrAbat)	, "18"	,"9"	)
	aDadosTit	:= {AllTrim(SQLSE1->E1_NUM)+AllTrim(SQLSE1->E1_PARCELA)		,;  // [1] Número do título
						SQLSE1->E1_EMISSAO                              	,;  // [2] Data da emissão do título
						dDataBase                    					,;  // [3] Data da emissão do boleto
						SQLSE1->E1_VENCTO                               	,;  // [4] Data do vencimento
						(SQLSE1->E1_SALDO - nVlrAbat)                  	,;  // [5] Valor do título
						cNroDoc                             ,; //aCB_RN_NN[3],;  // [6] Nosso número (Ver fórmula para calculo)
						SQLSE1->E1_PREFIXO                               	,;  // [7] Prefixo da NF
						SQLSE1->E1_TIPO	                           		}   // [8] Tipo do Titulo

	nDataBase 	:= CtoD("07/10/1997") // data base para calculo do fator
	nFatorVen	:= STOD(SQLSE1->E1_VENCTO) - nDataBase // acha a diferenca em dias para o fator de vencimento
			
	Impress(oNfServ,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	nX := nX + 1

	SQLSE1->(dbSkip())
	nI++
	
EndDo

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress | Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO COM CODIGO DE BARRAS                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga Protheus                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oNfServ,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

Local nI := 0
Local nTamLinBol := 17
nLin += 20

oNfServ:SetFontEX(5,cFonte,.F.,.T.,.F.)
oNfServ:SayBitmap(nLin,aCol[1]+2,"tesoura.bmp",10,7.5)
oNfServ:Say(nLin,aCol[2]-5,Replicate("-",210))
oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin-5,aCol[6]-20,"AUTENTICAÇÃO MECÂNICA")
oNfServ:SetFontEX(8,cFonte,.F.,.T.,.F.)

nLin += 12

nTamBol := 178

oNfServ:Box(nLin,aCol[1],nLin+nTamBol,aCol[7])
oNfServ:SayBitmap(nLin+5,aCol[1]+3,"logo_citibank.bmp",70,20)
oNfServ:Line(nLin,aCol[1]+100,nLin+nTamLinBol+8,aCol[1]+100) //"linha vertical"
oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin+20,aCol[1]+105,aDadosBanco[1]+"-5") //"Numero do Banco"
oNfServ:Line(nLin,aCol[1]+150,nLin+nTamLinBol+8,aCol[1]+150) //"linha vertical"
oNfServ:Say(nLin+20,aCol[1]+155,aCB_RN_NN[2]) //"Linha Digitavel do Codigo de Barras"

nLin+=25
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"VENCIMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,alltrim(DTOC(STOD(SQLSE1->E1_VENCTO))))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"LOCAL DE PAGAMENTO")
oNfServ:Line(nLin,aCol[6]-50,nLin+(nTamLinBol*9)-5,aCol[6]-50) //"linha vertical grande"
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1],alltrim(mv_par12))

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"AGENCIA / CODIGO DO CEDENTE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5]))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"CEDENTE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1],"EQUANT DO BRASIL LTDA")

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"NOSSO NÚMERO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,Alltrim(aDadosTit[6]))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"DATA DO DOCUMENTO")
oNfServ:Line(nLin,aCol[1]+70,nLin+(nTamLinBol*2),aCol[1]+70) //"linha vertical"
oNfServ:Say(nLin+6,aCol[2]+60,"N. DO DOCUMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[2]+60,alltrim(aDadosTit[7])+aDadosTit[1])
oNfServ:Line(nLin,aCol[2]+130,nLin+nTamLinBol,aCol[2]+130) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[3]-40,"ESPÈCIE DOCUMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[3]-40,"DM")
oNfServ:Line(nLin,aCol[4]-55,nLin+(nTamLinBol),aCol[4]-55) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[4]-50,"ACEITE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[4]-50,"N")
oNfServ:Line(nLin,aCol[3]+120,nLin+(nTamLinBol*2),aCol[3]+120) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[5]-75,"DATA PROCESSAMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[5]-75,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4))
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1],alltrim(DTOC(STOD(SQLSE1->E1_VENCREA))))

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"VALOR DO DOCUMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"USO DO BANCO")
oNfServ:Line(nLin,aCol[1]+70,nLin+(nTamLinBol),aCol[1]+70) //"linha vertical"
oNfServ:Say(nLin+6,aCol[2]+60,"CARTEIRA")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[2]+60,aDadosBanco[6])
oNfServ:Line(nLin,aCol[2]+100,nLin+nTamLinBol,aCol[2]+100) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[3]-70,"ESPÉCIE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[3]-70,"R$")
oNfServ:Line(nLin,aCol[3]-18,nLin+nTamLinBol,aCol[3]-18) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[4]-112,"QUANTIDADE")

oNfServ:Say(nLin+6,aCol[5]-75,"VALOR")

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(-) DESCONTOS / ABATIMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(nVlrAbat,"@E 999,999,999.99")))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"INSTRUCOES (TEXTO DE RESPONSABILIDADE DO CEDENTE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+20,aCol[1],alltrim(mv_par13))
oNfServ:Say(nLin+30,aCol[1],alltrim(mv_par14))

nLin += nTamLinBol
//Linhas Verticais (direita)
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(-) OUTRAS DEDUÇÕES")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(+) MORA / MULTA")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(+) OUTROS ACRÉSCIMOS")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(=) VALOR COBRADO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])

nLin += nTamLinBol
oNfServ:Box(nLin-51,aCol[1],nLin-17,aCol[6]-50)
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin-45,aCol[1],"SACADO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin-35,aCol[1],aDatSacado[1] + " - CPF/CNPJ: " + IIF(Len(aDatSacado[7])==11,Transform(aDatSacado[7],"@R 999.999.999-99"),Transform(aDatSacado[7],"@R 99.999.999/9999-99")) )
oNfServ:Say(nLin-27,aCol[1],aDatSacado[3] + aDatSacado[4] + " - " + aDatSacado[5] + " - " + aDatSacado[6])

oNfServ:FWMSBAR("INT25" /*cTypeBar*/,61.5/*nRow*/ ,1/*nCol*/,aCB_RN_NN[1]/*cCode*/,oNfServ/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,cFonte/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

oNfServ:Say(nLin,aCol[5]+50,"FICHA DE COMPENSAÇÃO")

DbSelectArea("SE1")
DbGoTo(SQLSE1->R_E_C_N_O_)
RecLock("SE1",.f.)
   SE1->E1_NUMBCO 	:=	aDadosTit[6] //aCB_RN_NN[3]  // Nosso número (Ver fórmula para calculo)
   SE1->E1_PORTADO := "745"
   SE1->E1_HIST := "BOLETO CITIBANK GERADO"
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra| Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO COM CODIGO DE BARRAS                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga Protheus                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
						cBanco		,cAgencia	,cConta		,cDacCC	,;
						cNroDoc		,nValor		,cCart		,cMoeda	)

Local cNosso		:= ""
Local cDigNosso	:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra	:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}

cAgencia:=STRZERO(Val(cAgencia),4)
cCart := "18"		
cNosso := ""
       
cNosso:= cNroDoc
nNum  := cNroDoc

If nValor > 0
	cFatorValor  := Kfator1347()+Strzero(nValor*100,10)
Else
	cFatorValor  := Kfator1347()+strzero(SQLSE1->E1_VALOR*100,10)
EndIf

cConvenio := ALLTRIM(SA6->A6_NUMBCO) 

DO CASE 
  CASE LEN(ALLTRIM(cConvenio)) == 6
     cCampoL := cConvenio+alltrim(NNUM)+"21"
  CASE LEN(ALLTRIM(cConvenio)) == 7
     cCampoL := "000000"+alltrim(NNUM)+cCart   
ENDCASE
  
cLivre := cBanco+cMoeda+cFatorValor+"3"+"100"+SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),2,10)+nNum 

// campo do codigo de barra
cDigBarra := KCALCDp(alltrim(cLivre),"2" )

cBarra    := Substr(cLivre,1,4)+cDigBarra+cFatorValor+Substr(cLivre,19,25)
//MSGALERT(cBarra,"Codigo de Barras")

// composicao da linha digitavel
cParte1  := cBanco+cMoeda+"3"+"100"+"0"
cDig1    := KDIGIT0347( cParte1,1 )
//cParte2  := "49229"+"01"+"1"+SUBSTR(nNum,1,2 ) 
cParte2  := SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),3,10)+SUBSTR(nNum,1,2) 
cDig2    := KDIGIT0347( cParte2,2 )
cParte3  := SUBSTR(nNum,3,10 )
cDig3    := KDIGIT0347( cParte3,2 )
cParte4  := cDigBarra 
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
			cParte4+" "+;                                              
			cParte5
//MSGALERT(cDigital,"Linha Digitavel")

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)		

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALCdiE   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do Citibank                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALCdiE(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT0347 ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Citibank                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function KDIGIT0347(cVariavel,nOp)

Local aMultiplic := {}  // Resultado das Multiplicacoes de cada algarismo
Local _cRet      := " "
Local aBaseNum   := {}
Local cDigVer    := 0 
Local nB         := 0  
Local nC         := 0 
Local nSum       := 0 
Local _cNossoNum := ""
Local _cCalcdig  := ""
cbase  := cVariavel 
IF nOp == 1 
  aBaseNum   := { 2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2}
ELSE
  aBaseNum   := { 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
ENDIF

For nB := 1 To Len(cbase)
		
		nMultiplic := Val(Subs(cbase,nB,1) ) * aBaseNum[nB]
		Aadd(aMultiplic,StrZero(nMultiplic,2) )
		
next nB
For nC := 1 To Len(aMultiplic)
		nAlgarism1 := Val(Subs(aMultiplic[nC],1,1) )
		nAlgarism2 := Val(Subs(aMultiplic[nC],2,1) )
		nSum       := nSum + nAlgarism1 + nAlgarism2
Next nC

cDigVer := 10 - Mod(nSum,10)

IF cDigVer == 10 
   cDigVer := 0 
Endif

Return(str(cDigVer,1,0))

Static function KFator1347()
If Len(ALLTRIM(SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,4))) = 4
	cData := SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,4)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),4,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),1,2)
Else
	cData := "20"+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),4,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |CALCDp    ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Citibank                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function KCALCDp(cVariavel,_cRegra)
Local Auxi := 0, sumdig := 0
Local aBasecalc := {4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
Local aBaseNNum := {4,3,2,9,8,7,6,5,4,3,2}
Local nMult     := 0
Local nD        := 0      
Local nE        := 0      
Local aMult     := {}
Local nDigbar   := 0
Local nSoma     := 0
cbase  := cVariavel

If _cRegra == "1"  
For nD := 1 To Len(cbase)
		nMult := Val(Subs(cbase,nD,1) ) * aBaseNNum[nD]
		Aadd(aMult,StrZero(nMult,2) )
next nD          
Else
For nD := 1 To Len(cbase)
		nMult := Val(Subs(cbase,nD,1) ) * aBasecalc[nD]
		Aadd(aMult,StrZero(nMult,2) )
next nD          
Endif
	
nSoma := 0 
nAlgarism1 := 0 
nAlgarism2 := 0 
For nE := 1 To Len(aMult)                         
    	nAlgarism1 := Val(aMult[nE])
		nSoma      := nSoma + nAlgarism1 // + nAlgarism2
Next nC
nDigbar := 11 - Mod(nSoma,11)

IF nDigbar == 0  .or. nDigbar == 1 .or. nDigbar == 10 .or. nDigbar == 11   
   nDigbar := 1 
Endif
  
Return(str(nDigbar,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    KIMPESTR   ºAutor  ³Andre Minelli       º Data ³  27/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para impressao da estrutura do RPS                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       KIMPESTR                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function KIMPESTR()

Local nTamLine 	:= 2
Local nSpRow	:= 2
Local nSalta	:= 12
Local nMgLine	:= 9
Local nSpCol	:= 4
Local nTamLine 		:= 2
Local nSpRow		:= 2
Local nSalta		:= 12
Local nMgLine		:= 9
Local nSpCol		:= 4
Local lLastPag		:= .F.

nPagina++
nLin := 15

oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)
oNfServ:Say(10,aCol[4]+240,"Pagina " + StrZero(nPagina,2))
oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin+10,aCol[3],"RECIBO PROVISORIO DE SERVIÇOS - RPS")
oNfServ:SayBitmap(nLin-10,aCol[1],"logo_orange.bmp",140,62)
oNfServ:SetFontEX(8,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin+30,aCol[3],Alltrim(SM0->M0_NOMECOM))
oNfServ:Say(nLin+30,aCol[5]+50,"Número/Série/Nr. Controle")
oNfServ:Say(nLin+40,aCol[3],Alltrim(SM0->M0_ENDCOB))
oNfServ:Say(nLin+40,aCol[5]+50,Alltrim(SQLSF2->F2_DOC) + "/" + Alltrim(SQLSF2->F2_SERIE) + "/" + Alltrim(SQLSF2->C5_XNUMCTR))
oNfServ:Say(nLin+50,aCol[3],Alltrim(SM0->M0_BAIRCOB) + " - " + Alltrim(SM0->M0_CEPCOB))
oNfServ:Say(nLin+50,aCol[5]+50,"Data de Emissão")
oNfServ:Say(nLin+60,aCol[3],Alltrim(SM0->M0_CIDCOB) + " - " + Alltrim(SM0->M0_ESTCOB))
oNfServ:Say(nLin+60,aCol[5]+50,DTOC(STOD(SQLSF2->F2_EMISSAO)))
oNfServ:Say(nLin+70,aCol[3],"CNPJ: " + SM0->M0_CGC)
oNfServ:Say(nLin+70,aCol[5]+50,"Hora Emissão")
oNfServ:Say(nLin+80,aCol[3],"I.M.: " + SM0->M0_INSCM)
oNfServ:Say(nLin+80,aCol[5]+50,SQLSF2->F2_HORA)

nLin += nSalta*9

oNfServ:Box(nLin,aCol[1],nLin+(nSalta*7)+5,aCol[7])
oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin-5,aCol[3]+20,"DADOS DO DESTINATÁRIO",)

oNfServ:SetFontEX(8,cFonte,.F.,.T.,.F.)
nLin += 10
oNfServ:Say(nLin,aCol[2],"Nome/Razão Social: " + Alltrim(SQLSF2->A1_NOME))
nLin += nSalta

oNfServ:Say(nLin,aCol[2],"CPF/CNPJ: " + alltrim(SQLSF2->A1_CGC))
nLin += nSalta

oNfServ:Say(nLin,aCol[2],"Inscrição Munip.: " + Alltrim(SQLSF2->A1_INSCRM))
nLin += nSalta

oNfServ:Say(nLin,aCol[2],"Endereço: " + Alltrim(SQLSF2->A1_END))
nLin += nSalta

oNfServ:Say(nLin,aCol[2],"CEP: " + SQLSF2->A1_CEP)
nLin += nSalta

oNfServ:Say(nLin,aCol[2],"Município: " + Alltrim(SQLSF2->A1_MUN))
nLin += nSalta                         

oNfServ:Say(nLin,aCol[2],"E-mail: " + Alltrim(SQLSF2->A1_EMAIL))
nLin += nSalta*2

oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
oNfServ:Box(nLin,aCol[1],nLin+(nSalta*12)+5,aCol[7])
oNfServ:Say(nLin-5,aCol[2]+180,"DISCRIMINAÇÃO DOS SERVIÇOS")

nLin += nSalta*12

oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
	
oNfServ:Box(nLin,aCol[1],nLin+20,aCol[7])
oNfServ:Say(nLin+10,aCol[2],"VALOR TOTAL DA PRESTAÇÃO DE SERVIÇOS")
oNfServ:Say(nLin+10,aCol[6],"R$ " + Alltrim(Transform(SQLSF2->F2_VALBRUT,"@E 999,999,999.99")))
	
nLin += nSalta*2
	
oNfServ:Box(nLin-5,aCol[1],nLin+20,aCol[7])
oNfServ:Say(nLin+10,aCol[2],"Código de Serviço " + cServicos)
	
nLin += nSalta*2

oNfServ:SetFontEX(8,cFonte,.F.,.T.,.F.)
oNfServ:Box(nLin-5,aCol[1],nLin+20,aCol[7])
oNfServ:Say(nLin+10,aCol[2],"Total Deduções (R$) " + Alltrim(Transform(SQLSF2->F3_ISSSUB,"@E 999,999,999.99")))
oNFServ:Line(nLin-5,aCol[3]-40,nLin+20,aCol[3]-40)
oNfServ:Say(nLin+10,aCol[3]-30,"Base de Cálculo (R$) " + Alltrim(Transform(SQLSF2->F3_BASEICM,"@E 999,999,999.99")))
oNFServ:Line(nLin-5,aCol[4],nLin+20,aCol[4])
oNfServ:Say(nLin+10,aCol[4]+10,"Alíquota (%) " + Alltrim(Transform(SQLSF2->F3_ALIQICM,"@E 999,999,999.99")))
oNFServ:Line(nLin-5,aCol[5],nLin+20,aCol[5])
oNfServ:Say(nLin+10,aCol[5]+10,"Valor do ISS (R$) " + Alltrim(Transform(SQLSF2->F3_VALICM,"@E 999,999,999.99")))

nLin += nSalta*2
oNfServ:SetFontEX(8,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin+10,aCol[3]-40,"INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA")
	
oNfServ:SetFontEX(10,cFonte,.F.,.T.,.F.)
oNfServ:Box(nLin-5,aCol[1],nLin+20,aCol[7])
oNfServ:Say(nLin+10,aCol[2],"Número: " + Alltrim(SQLSF2->F2_DOC))
oNFServ:Line(nLin-5,aCol[3]-40,nLin+20,aCol[3]-40)
oNfServ:Say(nLin+10,aCol[3]-30,"Emissão: " + Alltrim(DTOC(STOD(SQLSF2->F2_EMISSAO))))
oNFServ:Line(nLin-5,aCol[4],nLin+20,aCol[4])
oNfServ:Say(nLin+10,aCol[4]+10,"Cód. Verif: " + Alltrim(SQLSF2->F3_CODNFE))
oNFServ:Line(nLin-5,aCol[5],nLin+20,aCol[5])
oNfServ:Say(nLin+10,aCol[5]+10,"Créd. IPTU (R$) " + Alltrim(SQLSF2->F3_CREDNFE))
	
nLin += nSalta*2
oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin+10,aCol[3]+40,"OUTRAS INFORMAÇÕES")
oNfServ:Box(nLin+15,aCol[1],nLin+55,aCol[7])

oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |SaltaPag  ºAutor  ³Andre Minelli       º Data ³  27/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para salto de pagina na impressao dos itens          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFSERV                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SaltaPag()

oNfServ:EndPage()
oNfServ:StartPage()

//Inicia Impressao do cabecalho e formulario da segunda pagina
KImpEstr()
//Finaliza impressao

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |RetMD5    ºAutor  ³Andre Minelli       º Data ³  08/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para calculo do Hash Code                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NFSERV                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetMD5

Local cAutDig1 	:= ""
Local cAutDig2 	:= ""
Local nAnoMes
Local cCodMD5	:= ""
Local nIsentas	:= 0
Local nOutrIcm	:= 0
Local cSituac	:= ""
Local nAnoMes
Local nProxRegItem	:= 0

cAutDig1	:=	SQLSF2->A1_CGC+SQLSF2->F2_DOC+StrTran (StrZero (SQLSF2->F2_VALBRUT, 13, 2), ".", "")
cAutDig1	+=	StrTran (StrZero (SQLSF2->F2_BASEICM, 13, 2), ".", "")+StrTran (StrZero (SQLSF2->F2_VALICM, 13, 2), ".", "")

SFT->(DbSetOrder(1))
SFT->(DbSeek(xFilial("SFT") + "S" + SQLSF2->F2_SERIE + SQLSF2->F2_DOC + SQLSF2->F2_CLIENTE + SQLSF2->F2_LOJA ))
While SFT->(!EOF()) .And. SQLSF2->F2_DOC + SQLSF2->F2_SERIE + SQLSF2->F2_CLIENTE + SQLSF2->F2_LOJA == SFT->FT_NFISCAL + SFT->FT_SERIE + SFT->FT_CLIEFOR + SFT->FT_LOJA
	nIsentas 	+= SFT->FT_ISENICM
	nOutrIcm 	+= SFT->FT_OUTRICM
	cSituac	 	:= IIf("CANCELAD" $ SFT->FT_OBSERV .And. !Empty(SFT->FT_DTCANC),"S","N")
	nAnoMes		:= Val(SubStr (AllTrim (Str (Year (SFT->FT_ENTRADA))), 3, 2)+StrZero (Month (SFT->FT_ENTRADA), 2))
	nProxRegItem ++
SFT->(DbSkip())
End

cAutDig2 := SQLSF2->A1_CGC + SQLSF2->A1_INSCR + SQLSF2->A1_NOME+SQLSF2->A1_EST + SQLSF2->A1_TPASS + SQLSF2->A1_TPUTI
cAutDig2 += SQLSF2->A1_GRPTEN + SQLSF2->A1_COD+strzero(Val(SQLSF2->F2_EMISSAO),8)+strzero(Val(SQLSF2->F2_ESPECIE),2)+SQLSF2->F2_SERIE
cAutDig2 += SQLSF2->F2_DOC+Md5(cAutDig1)+StrTran (StrZero (SQLSF2->F2_VALBRUT, 13, 2), ".", "")
cAutDig2 += StrTran (StrZero (SQLSF2->F2_BASEICM, 13, 2), ".", "")+StrTran (StrZero (SQLSF2->F2_VALICM, 13, 2), ".", "")
cAutDig2 += StrTran (StrZero (nIsentas, 13, 2), ".", "")+StrTran (StrZero (nOutrIcm, 13, 2), ".", "")
cAutDig2 += cSituac+StrZero (nAnoMes, 4)+StrZero (nProxRegItem, 9)+Space(12)+Space (3)
				
cCodMD5 := Md5(cAutDig2)

Return (cCodMD5)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |AtuX1     ºAutor  ³Andre Minelli       º Data ³  02/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para atualizacao do arquivo de perguntas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ORRFAT30                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuX1(cPerg)                            

U_PUTSX1(cPerg, "01", "Da Emissao",        "Da Emissao",        	"Da Emissao",        "mv_ch01","D",10,0,1,"G","","",   "","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Ate Emissao",       "Ate Emissao",       	"Ate Emissao",       "mv_ch02","D",10,0,1,"G","","",   "","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "03", "Do Cliente",        "Do Cliente",        	"Do Cliente",        "mv_ch03","C",9,0,1, "G","","SA1"	,"","","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "04", "Ate Cliente",       "Ate Cliente",       	"Ate Cliente",       "mv_ch04","C",9,0,1, "G","","SA1"	,"","","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "05", "Da Loja",           "Da Loja",           	"Da Loja",     	   	 "mv_ch05","C",2,0,1, "G","","","",	"","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "06", "Ate Loja",          "Ate Loja",           	"Ate Loja",          "mv_ch06","C",2,0,1, "G","","","",	"","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "07", "Do RPS",            "Do RPS",             	"Do RPS",            "mv_ch07","C",12,0,1,"G","","",   "","","mv_par07","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "08", "Ate RPS",           "Ate RPS",            	"Ate RPS",           "mv_ch08","C",12,0,1,"G","","",   "","","mv_par08","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "09", "Da Serie",          "Da Serie",          	"Da Serie",          "mv_ch09","C",3 ,0 ,1,"G","","",  "","","mv_par09","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "10", "Ate Serie",         "Ate Serie",         	"Ate Serie",         "mv_ch10","C",3 ,0 ,1,"G","","",  "","","mv_par10","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "11", "Envia por E-mail ?","Envia por E-mail ?",	"Envia por E-mail ?","mv_ch11","N",1, 0,1,"C","","",   "","","mv_par11","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "12", "Local de Pagamento","Local de Pagamento",	"Local de Pagamento","mv_ch12","C",60,0,1,"G","","",   "","","mv_par12","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "13", "Instrucao 1",       "Instrucao 1",       	"Instrucao 1",       "mv_ch13","C",60,0,1,"G","","",   "","","mv_par13","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "14", "Instrucao 2",       "Instrucao 2",       	"Instrucao 2",       "mv_ch14","C",60,0,1,"G","","",   "","","mv_par14","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "15", "Drive de Impressao","Drive de Impressao",	"Drive de Impressao","mv_ch15","C",2,0,1, "G","","",   "","","mv_par15","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "16", "Do Vecnto",         "Do Vecnto",         	"Do Vecnto",         "mv_ch16","D",10,0,1,"G","","",   "","","mv_par16","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "17", "Ate Vecnto",        "Ate Vecnto",        	"Ate Vecnto",        "mv_ch17","D",10,0,1,"G","","",   "","","mv_par17","","","","","","","","","","","","","","","","",{},{},{},"")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTDESCRNFEºAutor  ³Andre Minelli       º Data ³  05/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteracao da descricao dos servicos prestados para impressaoº±±
±±º          ³no relatorio de RPS                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ORANGE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DescRps
Local cDescricao := ""

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek(xFilial("SD2") + SQLSF2->F2_DOC + SQLSF2->F2_SERIE + SQLSF2->F2_CLIENTE + SQLSF2->F2_LOJA)
	While SD2->(!EOF()) .And. SD2->D2_DOC == SQLSF2->F2_DOC .And. SD2->D2_SERIE == SQLSF2->F2_SERIE .And. SD2->D2_CLIENTE == SQLSF2->F2_CLIENTE .And. SD2->D2_LOJA == SQLSF2->F2_LOJA
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + SD2->D2_COD))
		cDescricao += Alltrim(SB1->B1_DESC) + "; "
		If !alltrim(SD2->D2_CODISS) $ cServicos
			cServicos  += Alltrim(SD2->D2_CODISS) + "; "
		End If
	SD2->(DbSkip())
	End
End If

Return (cDescricao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±± 
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR968                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr968Mont(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString),nLinhas)

	cMemo := MemoLine(cString,145,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,120),nLinhas)
			cAux := MemoLine(cMemo,145,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)
