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
±±³ Funcao   ³ NFSERV    ³ Autor ³ Andre Minelli        ³ Data ³01/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao NF Eletronica de Telecomunicacoes                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ORGANGE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function NFSERV

Local cQuery	 := ""
Local cQuery2	 := ""
Local oFont 	 := TFont():New("Courier New",,-9 ,,.T.)
Local oFont2 	 := TFont():New("Courier New",,-11,,.T.)
Local oFont3 	 := TFont():New("Courier New",,-5 ,,.T.)
Local oFontTit1	 := TFont():New("Courier New",,-18, .T.)
Local nLinAnt	 := 0
Local nSalta	 := 12
Local nSpRow	 := 2
Local nSpCol	 := 4
Local nMgLine	 := 9
Local nTamBox	 := 120
Local nTamLine	 := 2
Local cPara		 := ""
Local cAssunto   := "Nota Fiscal de Serviços de Comunicacao"
Local cTexto	 := "<b><i>Em anexo NF de Serviços de Comunicação</i></b>"
Local cPerg		 := "SZNFSV"

Private cDirMail 		:= "\nfserv\"
Private cDirGer	 		:= "" //Criar um diretorio \NFSERV\ no drive informado
Private aFiles	 		:= {}
Private oNfServ
Private oMail
Private oMessage
Private cSMTPServer		:= GetMV("MV_RELSERV")
Private cSMTPUser		:= GetMV("MV_RELACNT")
Private cSMTPPass		:= GetMV("MV_RELPSW" )
Private cMailFrom		:= GetMV("MV_RELFROM")
Private nErro   	    := 0
Private nPort			:= 587
Private lRetMail		:= .T.
Private lUseAuth		:= GetMv("MV_RELAUTH")
Private nLin  			:= 15
Private aCol		    := {10,25,200,300,400,500,580}

AtuX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
End If

cDirGer	:= MV_PAR11+cDirMail
MakeDir(cDirGer) //Cria diretorio \nfserv\ no local informado no parametro 11

//Exclui os arquivos pre-existentes nos diretorios
aFilesDel := Directory(cDirMail+"*.*", "D")
For i := 1 to len(aFilesDel)
	Ferase(cDirMail+ aFilesDel[i][1])
Next i

aFilesDel := Directory(cDirGer+"*.*", "D")
For i := 1 to len(aFilesDel)
	Ferase(cDirGer+ aFilesDel[i][1])
Next i

//Prepara o envio de email
If MV_PAR07 == 2

	oMail := TMailManager():New()
	oServer:SetUseTLS(.T.)
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort )
	oMail:SetSmtpTimeOut( 60 )
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

cQuery := "SELECT * FROM " + RetSqlName("SF2") + " F2 LEFT JOIN " + RetSqlName("SA1") + " A1 ON F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA "
cQuery += " WHERE F2.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "' AND F2.F2_EMISSAO <= '" + DTOS(MV_PAR02) + "' AND F2.F2_CLIENTE >= '" + MV_PAR03 + "'"
cQuery += " AND F2.F2_CLIENTE <= '" + MV_PAR04 + "' AND F2.F2_DOC >= '" + MV_PAR05 + "' AND F2.F2_DOC <= '" + MV_PAR06 + "' AND F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = ''
cQuery += " ORDER BY F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_DOC, F2.F2_SERIE"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLSF2",.T.,.T.)

While SQLSF2->(!EOF())
	
	nLin := 15
	
	oBrush0 := TBrush():New(,RGB(255,102,000))
	oBrush1 := TBrush():New(,RGB(255,157,000))
	
	oNfServ:=FWMSPrinter():New("NFSERV_"+alltrim(SQLSF2->F2_CLIENTE)+alltrim(SQLSF2->F2_DOC),6,.F.,,.T.,,,,,,,.F.)
	
	oNfServ:SetPortrait()
	
	oNfServ:cPathPDF := cDirGer
	
	oNfServ:SayBitmap(nLin-10,aCol[1],"logo_orange.bmp",140,62)
	oNfServ:SetFontEX(7,"Arial",.F.,.T.,.F.)
	oNfServ:Say(nLin+30,aCol[3],PADR("CNPJ: " + SM0->M0_CGC  ,40)  + space(12) + alltrim(SM0->M0_ENDCOB))
	oNfServ:Say(nLin+40,aCol[3],PADR("INSCR. ESTADUAL:  " + SM0->M0_INSC ,40)  + space(6) + alltrim(SM0->M0_BAIRCOB) + " CEP: " + alltrim(SM0->M0_CEPCOB))
	oNfServ:Say(nLin+50,aCol[3],PADR("INSCR. MUNICIPAL: " + SM0->M0_INSCM,40)  + space(5) + alltrim(SM0->M0_CIDCOB)  + ", " + alltrim(SM0->M0_ESTCOB))
	
	nLin += nSalta*6
	
	oNfServ:SetFontEX(11,"Arial",.F.,.T.,.F.)
	oNfServ:Say(nLin,aCol[4]+20,"NOTA FISCAL FATURA DE SERVIÇO DE TELECOMUNICAÇÕES",oFontTit1,,RGB(255,102,000))
	nLin += nSalta
	oNfServ:Say(nLin,aCol[7]-44,"VIA ÚNICA",oFontTit1,)
	nLin += nSalta
	oNfServ:Say(nLin,aCol[7]-50,"MODELO 22",oFontTit1,)
	nLin += nSalta
	oNfServ:Say(nLin,aCol[7]-43,"SÉRIE 001",oFontTit1,)
	nLin += nSalta
	
	nLin += 5
	oNfServ:Say(nLin,aCol[1],"NATUREZA DA OPERAÇÃO",oFont)
	oNfServ:Line(nLin+nSpRow,aCol[1],nLin+nSpRow,aCol[7])
	nLin += nSalta
	
	oNfServ:Say(nLin,aCol[1],"DATA DE EMISSÃO:" + " " + DTOC(STOD(SQLSF2->F2_EMISSAO)),oFont)
	
	oNfServ:Line(nLin-nMgLine,aCol[3]-nSpCol,nLin+nTamLine,aCol[3]-nSpCol)
	oNfServ:Say(nLin,aCol[3],"NÚMERO:" + " " + SQLSF2->F2_DOC,oFont)
	
	oNfServ:Line(nLin-nMgLine,aCol[5]-nSpCol,nLin+nTamLine,aCol[5]-nSpCol)
	oNfServ:Say(nLin,aCol[5],"N. CONTROLE:",oFont)
	oNfServ:Line(nLin+nSpRow,aCol[1],nLin+nSpRow,aCol[7])
	
	nLin += nSalta
	
	oNfServ:Say(nLin,aCol[1],"CLIENTE:" + " " + UPPER(SQLSF2->A1_NOME),oFont)
	oNfServ:Line(nLin-nMgLine,aCol[4]-nSpCol,nLin+(nTamLine*13),aCol[4]-nSpCol)
	oNfServ:Say(nLin,aCol[4],"ENDEREÇO:" + " " + UPPER(SQLSF2->A1_END),oFont)
	nLin += nSalta
	oNfServ:Say(nLin,aCol[1],"CNPJ:" + " " + Transform(SQLSF2->A1_CGC,"@R 99.999.999/9999-99"),oFont)
	oNfServ:Say(nLin,aCol[4],"BAIRRO:" + " " + UPPER(SQLSF2->A1_BAIRRO),oFont)
	nLin += nSalta
	oNfServ:Say(nLin,aCol[1],"I.E.:" + " " + SQLSF2->A1_INSCR,oFont)
	oNfServ:Say(nLin,aCol[3],"BAN:",oFont)
	oNfServ:Say(nLin,aCol[4],"CEP:" + " " + Transform(SQLSF2->A1_CEP,"@R 99999-999"),oFont)
	oNfServ:Say(nLin,aCol[5],"CIDADE" + " " + SQLSF2->A1_MUN,oFont)
	oNfServ:Say(nLin,aCol[6]+20,"ESTADO" + " " + UPPER(SQLSF2->A1_EST),oFont)
	
	nLin += nSalta*2
	
	cQuery2 := "SELECT * FROM " + RetSqlName("SD2") + " D2 LEFT JOIN " + RetSqlName("SF2") + " F2 ON D2.D2_FILIAL = F2.F2_FILIAL AND D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE"
	cQuery2 += " AND D2.D2_CLIENTE = F2.F2_CLIENTE AND D2.D2_LOJA = F2.F2_LOJA LEFT JOIN " + RetSqlName("SB1") + " B1 ON D2.D2_COD = B1.B1_COD "
	cQuery2 += " WHERE D2.D_E_L_E_T_ = '' and F2.D_E_L_E_T_ = '' AND D2.D2_FILIAL = '" + SQLSF2->F2_FILIAL + "' AND D2.D2_DOC = '" + SQLSF2->F2_DOC + "'"
	cQuery2 += " AND D2.D2_SERIE = '" + SQLSF2->F2_SERIE + "' AND D2.D2_CLIENTE = '" + SQLSF2->F2_CLIENTE + "' AND D2.D2_LOJA = '" + SQLSF2->F2_LOJA + "'"
	cQuery2 := ChangeQUery(cQuery2)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"SQLSD2",.T.,.T.)
	
	nLinAnt := nLin
	
	nTotal     := 0
	nTotalBase := 0
	nTotalIcm  := 0
	nTotalIss  := 0
	
	While SQLSD2->(!EOF())
		
		oNfServ:SetFontEX(7,"Arial",.F.,.F.,.F.)
		oNfServ:Say(nLin,aCol[1]+1,alltrim(SQLSD2->D2_COD))
		oNfServ:Say(nLin,aCol[2]+26,alltrim(UPPER(SQLSD2->B1_DESC)))
		oNfServ:Say(nLin,aCol[3]+90,Transform(SQLSD2->D2_TOTAL,"@E 999,999,999.99"))
		
		oNfServ:Say(nLin,aCol[6]-135,Transform(SQLSD2->D2_BASEICM,"@E 999,999,999.99"))
		oNfServ:Say(nLin,aCol[6]-93 ,Transform(SQLSD2->D2_PICM,"@E 999,999,999.99"))
		oNfServ:Say(nLin,aCol[6]-50, Transform(SQLSD2->D2_VALICM,"@E 999,999,999.99"))
		
		nTamBox += 10
		nLin    += 10
		
		nTotal     += SQLSD2->D2_TOTAL
		nTotalBase += SQLSD2->D2_BASEICM
		nTotalIcm  += SQLSD2->D2_VALICM
		
		SQLSD2->(DbSkip())
	End
	
	SQLSD2->(DbCloseArea())
	
	nLin := nLinAnt
	
	oNfServ:SetFontEX(11,"Arial",.F.,.T.,.F.)
	
	oNfServ:Fillrect( {nLin-10,aCol[1],nLin-10 + (nTamLine*6), aCol[6]-150 }, oBrush0, "-2")
	oNfServ:Say(nLin,aCol[2]+100,"SERVIÇOS PRESTADOS",oFont,,CLR_WHITE)
	
	oNfServ:Fillrect( {nLin+nSpRow,aCol[1],nLin + (nTamLine*6), aCol[6]-150 }, oBrush1, "-2")
	oNfServ:Line(nLin+nSpRow,aCol[1],nLin + nTamBox,aCol[1])
	oNfServ:Line(nLin+nSpRow,aCol[6]-150,nLin + nTamBox,aCol[6]-150)
	oNfServ:Line(nLin+nSpRow,aCol[1],nLin+nSpRow,aCol[6]-150)
	oNfServ:Line(nLin + nTamBox,aCol[1],nLin + nTamBox,aCol[6]-150)
	
	oNfServ:SetFontEX(7,"Arial",.F.,.T.,.F.)
	
	oNfServ:Say(nLin+10,aCol[1]+7,"Código",oFont)
	oNfServ:Say(nLin+10,aCol[1]+120,"Descrição dos Serviços",oFont)
	oNfServ:Say(nLin+10,aCol[3]+83,"Valor do Serviço",oFont)
	
	oNfServ:SetFontEX(11,"Arial",.F.,.T.,.F.)
	
	oNfServ:Line(nLin+nSpRow,aCol[2]+25,nLin + nTamBox,aCol[2]+25)
	oNfServ:Line(nLin+nSpRow,aCol[3]+80,nLin + nTamBox,aCol[3]+80)
	oNfServ:Box(nLin + nTamBox,aCol[3]+80,nLin + nTamBox + (nTamLine*6), aCol[6]-150)
	oNfServ:Say(nLin + nTamBox+10,aCol[3]+85,Transform(nTotal,"@E 999,999,999.99"))
	
	oNfServ:Fillrect( {nLin-10,aCol[6]-142,nLin-10 + (nTamLine*6), aCol[7] }, oBrush0, "-2")
	oNfServ:Say(nLin,aCol[5]-20,"DEMONSTRATIVO DE CARGA TRIBUTÁRIA",oFont,,CLR_WHITE)
	
	oNfServ:Fillrect( {nLin+nSpRow,aCol[6]-142,nLin + (nTamLine*6), aCol[7] }, oBrush1, "-2")
	oNfServ:Line(nLin+nSpRow,aCol[6]-142,nLin + nTamBox,aCol[6]-142)
	oNfServ:Line(nLin+nSpRow,aCol[7],nLin + nTamBox,aCol[7])
	oNfServ:Line(nLin+nSpRow,aCol[6]-142,nLin+nSpRow,aCol[7])
	oNfServ:Line(nLin + nTamBox,aCol[6]-142,nLin + nTamBox,aCol[7])
	
	oNfServ:SetFontEX(7,"Arial",.F.,.T.,.F.)
	
	oNfServ:Say(nLin+10,aCol[6]-135, "BASE CÁLCULO",oFont)
	oNfServ:Say(nLin+10,aCol[6]-73,"%",oFont)
	oNfServ:Say(nLin+10,aCol[6]-35,"ICMS",oFont)
	oNfServ:Say(nLin+10,aCol[6]+18,"LEG TRIBUTÁRIA",oFont)
	
	oNfServ:SetFontEX(11,"Arial",.F.,.T.,.F.)
	oNfServ:Box(nLin + nTamBox,aCol[6]-142,nLin + nTamBox + (nTamLine*6), aCol[7])
	
	oNfServ:SetFontEX(8,"Arial",.F.,.T.,.F.)
	oNfServ:Say(nLin + nTamBox+10,aCol[6]-135,Transform(nTotalBase,"@E 999,999,999.99"))
	oNfServ:Say(nLin + nTamBox+10,aCol[6]-50,Transform(nTotalIcm,"@E 999,999,999.99"))
	oNfServ:SetFontEX(11,"Arial",.F.,.T.,.F.)
	
	oNfServ:Line(nLin+nSpRow,aCol[6]-80,nLin + nTamBox+(nTamLine*6),aCol[6]-80)
	oNfServ:Line(nLin+nSpRow,aCol[6]-60,nLin + nTamBox +(nTamLine*6),aCol[6]-60)
	oNfServ:Line(nLin+nSpRow,aCol[6]+10,nLin + nTamBox +(nTamLine*6),aCol[6]+10)
	
	nLin += nTamBox + 10
	
	oNfServ:SetFontEX(7,"Arial",.T.,.T.,.F.)
	oNfServ:Say(nLin,aCol[1],"DOCUMENTO FISCAL EMITIDO CONFORME CONVÊNIO 115 DE 2003",oFont)
	
	oNfServ:SetFontEX(11,"Arial",.F.,.T.,.F.)
	
	nLin += 30
	
	oNfServ:Fillrect( {nLin-10,aCol[1],nLin-10 + (nTamLine*6), aCol[6]-150 }, oBrush0, "-2")
	oNfServ:Say(nLin,aCol[1]+100  ,"RESUMO SERVIÇOS PRESTADOS",oFont,,CLR_WHITE)
	oNfServ:Box(nLin+nSpRow,aCol[1],nLin + 35, aCol[6]-150)
	oNfServ:Line(nLin+nSpRow,aCol[3]+80,nLin + 35,aCol[3]+80)
	
	oNfServ:SetFontEX(7,"Arial",.F.,.T.,.F.)
	oNfServ:Say(nLin+11,aCol[1]+5,"TRIBUTADO ICMS ICMS",oFont3)
	oNfServ:Say(nLin+21,aCol[1]+5,"OUTROS NÃO-TRIBUTADO",oFont3)
	
	oNfServ:Fillrect( {nLin-10,aCol[6]-142,nLin-10 + (nTamLine*6), aCol[7] }, oBrush0, "-2")
	oNfServ:Say(nLin,aCol[5]-40  ,"BASE CÁLCULO" + Space(18) + "ICMS",oFont3,,CLR_WHITE)
	oNfServ:Box(nLin+nSpRow,aCol[6]-142,nLin  + 35 ,aCol[7])
	oNfServ:Line(nLin+nSpRow,aCol[6]-80,nLin + 35 ,aCol[6]-80)
	oNfServ:Line(nLin+nSpRow,aCol[6]-60,nLin  + 35 ,aCol[6]-60)
	oNfServ:Line(nLin+nSpRow,aCol[6]+10,   nLin  + 35 ,aCol[6]+10)
	
	nLin += 40
	
	oNfServ:Box(nLin+nSpRow,aCol[1],nLin + 35, aCol[7])
	oNfServ:Say(nLin+10,aCol[1]+5  ,"DADOS ADICIONAIS" ,oFont3)
	
	nLin += 40
	
	oNfServ:Box(nLin+nSpRow,aCol[1],nLin + 35, aCol[7])
	oNfServ:Say(nLin+10,aCol[1]+5  ,"RESERVADO AO FISCO",oFont3)
	
	nLin += 43
	
	oNfServ:SetFontEX(6,"Arial",.T.,.T.,.F.)
	oNfServ:Say(nLin,aCol[1]+5 ,"LEGENDA",oFont3)
	
	KBLTCITI()
	SQLSE1->(DbCloseArea())
	
	oNfServ:Print()
	
	cClienteAnt	:= SQLSF2->F2_CLIENTE
	cLojaAnt	:= SQLSF2->F2_LOJA
	cPara		:= SQLSF2->A1_EMAIL
	
	AADD(aFiles,{"nfserv_" + alltrim(SQLSF2->F2_CLIENTE) + alltrim(SQLSF2->F2_DOC)})
	
	SQLSF2->(DbSkip())
	
	If SQLSF2->F2_CLIENTE <> cClienteAnt .Or. SQLSF2->F2_LOJA <> cLojaAnt
		
		If MV_PAR07 == 2
			SEndMail(cPara,cAssunto,cTexto,cDirMail,aFiles)
			If !lRetMail
				MsgStop("Erro ao enviar email ref. NF.: " + SQLSF2->F2_DOC)
				lRetMail := .T.
			End If
		End If
		aFiles := {}
		
	End If
	
End

SQLSF2->(DbCloseArea())

//Delete arquivos apos envio de email
aFilesDel := Directory(cDirMail+"*.*", "D")
For i := 1 to len(aFilesDel)
	Ferase(cDirMail+ aFilesDel[i][1])
Next i

MsgInfo("Processo finalizado")

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

Static Function SEndMail(cPara,cAssunto,cTexto,cDirMail)

If lRetMail
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cMailFrom
	oMessage:cTo      := cPara
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cTexto
	oMessage:MsgBodyType( "text/html" )
	
	aFilesCpy := Directory(cDirGer+"*.*", "D")
	For i := 1 to len(aFilesCpy)	
		CpyT2S( cDirGer + aFilesCpy[i][1], cDirMail, .F. )
	Next i
	
	For i := 1 to Len(aFiles)
		oMessage:AttachFile ( cDirMail + aFiles[i][1] + ".pdf" )
	Next i
	
	FWMsgRun(,{|| nErro := oMessage:Send( oMail )},,'Enviando Mensagem para ['+cPara+']')
           
	If nErro <> 0
		xError := oMail:GetErrorString(nErro)
		MsgAlert("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")","AKRON")
		lRetMail := .F.
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

cQueryBol := "SELECT * FROM " + RetSqlName("SE1") + " WHERE E1_NUM = '" + SQLSF2->F2_DOC + "' AND E1_PREFIXO = '" + SQLSF2->F2_SERIE + "' AND "
cQueryBol += " E1_CLIENTE = '" + SQLSF2->F2_CLIENTE + "' AND E1_LOJA = '" + SQLSF2->F2_LOJA + "' AND E1_SALDO > 0 AND E1_PARCELA = 'A' AND D_E_L_E_T_ = ''"
cQueryBol := ChangeQuery(cQueryBol)

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

	cNroDoc	:= Strzero(Val(Alltrim(SQLSE1->E1_NUM)),9)+StrZERO(_nParcela,2)               
	cDigNNum:=KCALCDp(ALLTRIM(cNroDoc),"1")     
	cNroDoc	:=cNroDoc+""+cDigNNum
	
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

oNfServ:SetFontEX(10,"Arial",.F.,.T.,.F.)
oNfServ:SayBitmap(nLin-5,aCol[1]+2,"tesoura.bmp",10,7.5)
oNfServ:Say(nLin,aCol[2]-5,Replicate("-",215))
oNfServ:Say(nLin-5,aCol[6]-30,"AUTENTICAÇÃO MECÂNICA")

nLin += 12

nTamBol := 178

oNfServ:Box(nLin,aCol[1],nLin+nTamBol,aCol[7])
oNfServ:SayBitmap(nLin+1,aCol[1]+3,"logo_citibank.bmp",80,23.5)
oNfServ:Line(nLin,aCol[1]+100,nLin+nTamLinBol+8,aCol[1]+100) //"linha vertical"
oNfServ:SetFontEX(16,"Arial",.F.,.T.,.F.)
oNfServ:Say(nLin+20,aCol[1]+105,aDadosBanco[1]+"-5") //"Numero do Banco"
oNfServ:Line(nLin,aCol[1]+150,nLin+nTamLinBol+8,aCol[1]+150) //"linha vertical"
oNfServ:Say(nLin+20,aCol[1]+155,aCB_RN_NN[2]) //"Linha Digitavel do Codigo de Barras"

nLin+=25
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"VENCIMENTO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,alltrim(DTOC(STOD(SQLSE1->E1_VENCREA))))
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"Local DE PAGAMENTO")
oNfServ:Line(nLin,aCol[6]-50,nLin+(nTamLinBol*9)-5,aCol[6]-50) //"linha vertical grande"
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1]+5,alltrim(MV_PAR08))

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"AGENCIA / CODIGO DO CEDENTE")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5]))
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"CEDENTE")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1]+5,"EQUANT DO BRASIL LTDA")

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"NOSSO NÚMERO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,Alltrim(aDadosTit[6]))
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"DATA DO DOCUMENTO")
oNfServ:Line(nLin,aCol[1]+70,nLin+(nTamLinBol*2),aCol[1]+70) //"linha vertical"
oNfServ:Say(nLin+6,aCol[2]+60,"N. DO DOCUMENTO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[2]+60,alltrim(aDadosTit[7])+aDadosTit[1])
oNfServ:Line(nLin,aCol[2]+130,nLin+nTamLinBol,aCol[2]+130) //"linha vertical"
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[3]-40,"ESPÈCIE DOCUMENTO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[3]-40,"DM")
oNfServ:Line(nLin,aCol[4]-55,nLin+(nTamLinBol),aCol[4]-55) //"linha vertical"
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[4]-50,"ACEITE")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[4]-50,"N")
oNfServ:Line(nLin,aCol[3]+120,nLin+(nTamLinBol*2),aCol[3]+120) //"linha vertical"
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[5]-75,"DATA PROCESSAMENTO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[5]-75,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4))
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1]+5,alltrim(DTOC(STOD(SQLSE1->E1_VENCREA))))

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"VALOD DO DOCUMENTO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")))
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"USO DO BANCO")
oNfServ:Line(nLin,aCol[1]+70,nLin+(nTamLinBol),aCol[1]+70) //"linha vertical"
oNfServ:Say(nLin+6,aCol[2]+60,"CARTEIRA")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[2]+60,aDadosBanco[6])
oNfServ:Line(nLin,aCol[2]+100,nLin+nTamLinBol,aCol[2]+100) //"linha vertical"
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[3]-70,"ESPÉCIE")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[3]-70,"R$")
oNfServ:Line(nLin,aCol[3]-18,nLin+nTamLinBol,aCol[3]-18) //"linha vertical"
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[4]-112,"QUANTIDADE")

oNfServ:Say(nLin+6,aCol[5]-75,"VALOR")

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(-) DESCONTOS / ABATIMENTO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(nVlrAbat,"@E 999,999,999.99")))
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"INSTRUCOES (TEXTO DE RESPONSABILIDADE DO CEDENTE")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+20,aCol[1]+5,alltrim(MV_PAR09))
oNfServ:Say(nLin+30,aCol[1]+5,alltrim(MV_PAR10))

nLin += nTamLinBol
//Linhas Verticais (direita)
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(-) OUTRAS DEDUÇÕES")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(+) MORA ? MULTA")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(SQLSE1->E1_MULTA,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(+) OUTROS ACRÉSCIMOS")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(=) VALOR COBRADO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(aDadosTit[5]-nVlrAbat+SQLSE1->E1_MULTA,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])

nLin += nTamLinBol
oNfServ:Box(nLin-51,aCol[1],nLin-17,aCol[6]-50)
oNfServ:SetFontEX(6,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin-45,aCol[1]+5,"SACADO")
oNfServ:SetFontEX(8,"Arial",.F.,.F.,.F.)
oNfServ:Say(nLin-35,aCol[1]+5,aDatSacado[1] + " - CPF/CNPJ: " + IIF(Len(aDatSacado[7])==11,Transform(aDatSacado[7],"@R 999.999.999-99"),Transform(aDatSacado[7],"@R 99.999.999/9999-99")) )
oNfServ:Say(nLin-27,aCol[1]+5,aDatSacado[3] + aDatSacado[4] + " - " + aDatSacado[5] + " - " + aDatSacado[6])

oNfServ:FWMSBAR("INT25" /*cTypeBar*/,64.2/*nRow*/ ,1/*nCol*/,aCB_RN_NN[1]/*cCode*/,oNfServ/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

oNfServ:Say(nLin,aCol[5]+50,"FICHA DE COMPESNAÇÃO")

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
±±ºFuncao    |AtuX1     ºAutor  ³Andre Minelli       º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para atualizacao do arquivo de perguntas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NFSERV                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuX1(cPerg)

U_PUTSX1(cPerg, "01", "Da Emissao",        "Da Emissao",        "Da Emissao",        "mv_ch01","D",10,0,1,"G","","",   "","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Ate Emissao",       "Ate Emissao",       "Ate Emissao",       "mv_ch02","D",10,0,1,"G","","",   "","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "03", "Do Cliente",        "Do Cliente",        "Do Cliente",        "mv_ch03","C",9,0,1, "G","","SA1","","","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "04", "Ate Cliente",       "Ate Cliente",       "Ate Cliente",       "mv_ch04","C",9,0,1, "G","","SA1","","","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "05", "Da NF",             "Da NF",             "Da NF",             "mv_ch05","C",12,0,1,"G","","",   "","","mv_par05","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "06", "Ate NF",            "Ate NF",            "Ate NF",            "mv_ch06","C",12,0,1,"G","","",   "","","mv_par06","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "07", "Envia por E-mail ?","Envia por E-mail ?","Envia por E-mail ?","mv_ch07","N",1, 0,1,"C","","",   "","","mv_par07","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "08", "Local de Pagamento","Local de Pagamento","Local de Pagamento","mv_ch08","C",60,0,1,"C","","",   "","","mv_par08","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "09", "Instrucao 1",       "Instrucao 1",       "Instrucao 1",       "mv_ch09","C",60,0,1,"C","","",   "","","mv_par09","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "10", "Instrucao 2",       "Instrucao 2",       "Instrucao 2",       "mv_ch10","C",60,0,1,"C","","",   "","","mv_par10","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "11", "Drive de Impressao","Drive de Impressao","Drive de Impressao","mv_ch11","C",2,0,1, "C","","",   "","","mv_par11","","","","","","","","","","","","","","","","",{},{},{},"")

Return
