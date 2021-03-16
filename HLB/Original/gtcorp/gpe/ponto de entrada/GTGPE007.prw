#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.Ch"

/*
Funcao      : GTGPE007()
Parametros  : 
Retorno     : 
Objetivos   : Chamado do Fonte Rdmake Padrão RECIBO.PRX, customização da criaçaõ e envio do email de demonstrativo de pagamento.
Autor       : Jean Victor Rocha
Data/Hora   : 05/03/2014
*/
*----------------------*
User Function GTGPE007()
*----------------------*
Local nLin 			:= 20
Local nCol 			:= 15
Local nColFim		:= 580
Local nSp			:= 2
Local aFilesDel		:= {}
Local nErro			:= 0
Local cEmail		:= If(SRA->RA_RECMAIL=="S",SRA->RA_EMAIL,"    ")  
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario 
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario 

Local cDescEmp 		:= IIF(cEmpAnt $ "4J",UPPER(Desc_Fil),Capital(Desc_Fil)) //MSM - 10/09/2014 - Adicionado tratamento para maiúscula na empresa MFS, chamado: 021077 

Private cDirGer		:= GetTempPath()+"holerite\"

Private oMessage
Private oHolerite

fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc)

lEnvioOk := .T.//Variavel do Fonte Rdmake Padrão

MakeDir(cDirGer) //Cria diretorio no temporario

//Zera o conteudo da pasta Temporaria.
nTimeRef := Time()
aFilesDel := Directory(cDirGer+"*.*", "D")
While Len(aFilesDel) > 0
	If aScan(aFilesDel, { |x| x[1] == "." }) <> 0
		aDel(aFilesDel,aScan(aFilesDel, { |x| x[1] == "." }))
		aSize(aFilesDel,Len(aFilesDel)-1)
	EndIf
	If aScan(aFilesDel, { |x| x[1] == ".." }) <> 0
		aDel(aFilesDel,aScan(aFilesDel, { |x| x[1] == ".." }))
		aSize(aFilesDel,Len(aFilesDel)-1)
	EndIf
	
	If len(aFilesDel) == 0
		Exit
	EndIf
	
	For i := 1 to len(aFilesDel)
		If Ferase(cDirGer+ aFilesDel[i][1]) <> 0
			If VAL(STRTRAN(ElapTime(nTimeRef, Time()),":","")) > 30 //Se passar de 30 segundos avisa a demora.
				If MsgYesNo("Apagar o Arquivo '"+ALLTRIM(aFilesDel[i][1])+"' está demorando! Deseja abortar?")
					lEnvioOK := .T.
					Return .T.
				Else
					nTimeRef := Time()
				EndIf
			EndIf
		EndIf
	Next i
	aFilesDel := Directory(cDirGer+"*.*", "D")
EndDo

//Montagem do Arquivo -----------------------------------------------
oFont1 := TFont():New('Arial',,-14,,.T.)
oFont2 := TFont():New('Arial',,-10,,.T.)
oFont3 := TFont():New('Arial',,-10,,.F.)
oFont4 := TFont():New('Arial',,-12,,.F.)
oBrush1 := TBrush():New(,RGB(250,251,252))

oHolerite:=FWMSPrinter():New("Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT),6,.F.,,.T.,,,,,,,.F.)
oHolerite:SetPortrait()
oHolerite:cPathPDF := cDirGer
oHolerite:StartPage()


//Inicia a Impressão do Arquivo PDF.
If File("RH_lgrl"+cEmpAnt+".bmp")
	oHolerite:SayBitmap(nLin-2,nCol+15,"RH_lgrl"+cEmpAnt+".bmp",145,28)
//ElseIf File("lgrl"+cEmpAnt+".bmp")
//	oHolerite:SayBitmap(nLin,nCol+15,"lgrl"+cEmpAnt+".bmp",097,19)
EndIf
nLin += 15
oHolerite:Say(nLin,nCol+220,"Demonstrativo de Pagamento",oFont1)

nLin += 10	
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Empresa:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+40,cDescEmp,oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
oHolerite:Line(nLin+nSp,nCol+400,nlin+18,nCol+400)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Endereço:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+42,Capital(Desc_End),oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+400,"CNPJ:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+430,ALLTRIM(Transform(Desc_CGC,"@R 99.999.999/9999-99")),oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
oHolerite:Line(nLin+nSp,nCol+200,nlin+18,nCol+200)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Crédito em",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+50,Dtoc(dDataPagto),oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+200,"Banco/Agência/Conta:",oFont2,,RGB(124, 135, 164))
If EMPTY(SRA->RA_BCDEPSA)
	oHolerite:Say(nLin,nCol+nSp+290,"< Não Informada >",oFont3,,CLR_BLACK)
Else
	oHolerite:Say(nLin,nCol+nSp+290,AllTrim(Transform(SRA->RA_BCDEPSA,"@R 999/999999"))+"/"+SRA->RA_CTDEPSA,oFont3,,CLR_BLACK)
EndIf

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Referência:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+50,cReferencia,oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
oHolerite:Line(nLin+nSp,nCol+450,nlin+18,nCol+450)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Nome:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+30,Capital(AllTrim(SRA->RA_NOME)),oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+450,"Matrícula:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+490,SRA->RA_MAT,oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)      
oHolerite:Line(nLin+nSp,nCol+150,nlin+18,nCol+150)
oHolerite:Line(nLin+nSp,nCol+300,nlin+18,nCol+300)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"CTPS:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+30,SRA->RA_NUMCP,oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+150,"Série:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+182,SRA->RA_SERCP,oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+300,"CPF:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+325,Transform(SRA->RA_CIC,"@R 999.999.999-99"),oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
oHolerite:Line(nLin+nSp,nCol+320,nlin+18,nCol+320)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Função:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+35,Capital(AllTrim(cDescFunc)),oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+320,"Salário Nominal:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+390,Transform(nSalario,cPict1),oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Centro de Custo:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+70,AllTrim(SRA->RA_CC)+" - "+Capital(AllTrim(fDesc("SI3",SRA->RA_CC,"I3_DESC",TamSx3("I3_DESC")[1]))),oFont3,,CLR_BLACK)

nLin += 5
oHolerite:Box(nLin+nSp,nCol,nlin+18,nColFim)
oHolerite:Line(nLin+nSp,nCol+150,nlin+18,nCol+150)
oHolerite:Line(nLin+nSp,nCol+320,nlin+18,nCol+320)
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Admissão:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+50,Dtoc(SRA->RA_ADMISSA),oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+150,"Dep. IR:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+190,SRA->RA_DEPIR,oFont3,,CLR_BLACK)
oHolerite:Say(nLin,nCol+nSp+320,"Dep. Sal. Família:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+nSp+400,SRA->RA_DEPSF,oFont3,,CLR_BLACK)

nLin += 20
oHolerite:Say(nLin,nCol		,"Código"		,oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+50	,"Descrição"	,oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+280	,"Referência"	,oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+400	,"Valores"		,oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+540	,"(+/-)"		,oFont2,,RGB(124, 135, 164))

nLin += 13    //Espaçamento

lBrush := .T.

//Lançamentos
For nProv:=1 To Len( aProve )
	If lBrush
		oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
	EndIf
	lBrush := !lBrush
	nLin += 13
	oHolerite:Say(nLin,nCol		,Substr(aProve[nProv,1],1 ,3)					,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+50	,Capital(AllTrim(Substr(aProve[nProv,1],4 )))	,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+280	,Transform(aProve[nProv,2],'999.99')			,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+400	,Transform(aProve[nProv,3],cPict3)				,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+540	,"(+)"											,oFont3,,CLR_BLACK)
Next nProv

//Descontos
For nDesco := 1 to Len(aDesco)
	If lBrush
		oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
	EndIf
	lBrush := !lBrush
	nLin += 13
	oHolerite:Say(nLin,nCol		,Substr(aDesco[nDesco,1],1 ,3)					,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+50	,Capital(AllTrim(Substr(aDesco[nDesco,1],4 )))	,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+280	,Transform(aDesco[nDesco,2],'999.99')			,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+400	,Transform(aDesco[nDesco,3],cPict3)				,oFont3,,CLR_BLACK)
	oHolerite:Say(nLin,nCol+540	,"(-)"											,oFont3,,CLR_BLACK)
Next nDesco

lBrush := .T.          
nLin += 13
If lBrush
	oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
EndIf
lBrush := !lBrush
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Total Bruto:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+400,Transform(TOTVENC,cPict3)	  		,oFont3,,CLR_BLACK)
If lBrush
	oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
EndIf
lBrush := !lBrush
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Total de Descontos:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+400,Transform(TOTDESC,cPict3)	   		,oFont3,,CLR_BLACK)
If lBrush
	oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
EndIf
lBrush := !lBrush
nLin += 13
oHolerite:Say(nLin,nCol+nSp,"Líquido a Receber:",oFont2,,RGB(124, 135, 164))
oHolerite:Say(nLin,nCol+400,Transform((TOTVENC-TOTDESC),cPict3)	,oFont3,,CLR_BLACK)

lBrush := .T.
nLin += 13//Espaçamento
If Esc == 1//Base de Adiantamento
	If cBaseAux = "S" .And. nBaseIr # 0
		If lBrush
			oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
		EndIf
		lBrush := !lBrush
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,"Base de Anticipo",oFont2,,RGB(124, 135, 164))
		oHolerite:Say(nLin,nCol+200,Transform(nBaseIr	,cPict3),oFont3,,CLR_BLACK)
		oHolerite:Say(nLin,nCol+300,Transform(0.00		,cPict3),oFont3,,CLR_BLACK)
	EndIf

ElseIf Esc = 2 .Or. Esc = 4//Base de Folha e de 13o 20 Parc.
	If cBaseAux = "S"
		If lBrush
			oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
		EndIf
		lBrush := !lBrush
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,"Base FGTS/Valor FGTS:",oFont2,,RGB(124, 135, 164))
		oHolerite:Say(nLin,nCol+200,Transform(nBaseFgts,cPict3)	,oFont3,,CLR_BLACK)
		oHolerite:Say(nLin,nCol+300,Transform(nFgts,cPict3),oFont3,,CLR_BLACK)
		If lBrush
			oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
		EndIf
		lBrush := !lBrush
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,"Base IRRF Folha/Férias:",oFont2,,RGB(124, 135, 164))
		oHolerite:Say(nLin,nCol+200,Transform(nBaseIr	,cPict3),oFont3,,CLR_BLACK)
		oHolerite:Say(nLin,nCol+300,Transform(0.00		,cPict3),oFont3,,CLR_BLACK)
		If lBrush
			oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
		EndIf
		lBrush := !lBrush
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,"Base INSS:",oFont2,,RGB(124, 135, 164))
		oHolerite:Say(nLin,nCol+200,Transform(nAteLim	,cPict3),oFont3,,CLR_BLACK)
	EndIf

ElseIf Esc = 3//Bases de FGTS e FGTS Depositado da 1¦ Parcela 
	If cBaseAux = "S"
		If lBrush
			oHolerite:Fillrect( {nLin+nSp+nSp,nCol,nlin+16,nColFim}, oBrush1, "-2" )
		EndIf
		lBrush := !lBrush
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,"Base FGTS/Valor FGTS:",oFont2,,RGB(124, 135, 164))
		oHolerite:Say(nLin,nCol+200,Transform(nBaseFgts,cPict3)	,oFont3,,CLR_BLACK)
		oHolerite:Say(nLin,nCol+300,Transform(nFgts,cPict3),oFont3,,CLR_BLACK)
	EndIf
EndIf

// MENSAGENS PADRAO
If !Empty(MENSAG1)
	If FPHIST82(SRA->RA_FILIAL, "06", RHTamFilial(SRA->RA_FILIAL)+MENSAG1)
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,Left(SRX->RX_TXT,30),oFont4,,CLR_BLACK)
	ElseIf FPHIST82(SRA->RA_FILIAL, "06", RhTamFilial(Space(FWGETTAMFILIAL))+MENSAG1)
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,Left(SRX->RX_TXT,30),oFont4,,CLR_BLACK)
	Endif
Endif
If !Empty(MENSAG2)
	If FPHIST82(SRA->RA_FILIAL, "06", RHTamFilial(SRA->RA_FILIAL)+MENSAG2)
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,Left(SRX->RX_TXT,30),oFont4,,CLR_BLACK)
	ElseIf FPHIST82(SRA->RA_FILIAL, "06",  RhTamFilial(Space(FWGETTAMFILIAL))+MENSAG2)
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,Left(SRX->RX_TXT,30),oFont4,,CLR_BLACK)
	Endif
Endif
If !Empty(MENSAG3)
	If FPHIST82(SRA->RA_FILIAL, "06", RHTamFilial(SRA->RA_FILIAL)+MENSAG3)
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,Left(SRX->RX_TXT,30),oFont4,,CLR_BLACK)
	ElseIf FPHIST82(SRA->RA_FILIAL, "06",  RhTamFilial(Space(FWGETTAMFILIAL))+MENSAG3)
		nLin += 13
		oHolerite:Say(nLin,nCol+nSp,Left(SRX->RX_TXT,30),oFont4,,CLR_BLACK)
	Endif
Endif

//Tratamento de Mensagem de Aniversario
If MONTH(SRA->RA_NASC) ==  MONTH(dDataPagto)
	nLin += 26
	oHolerite:Say(nLin,nCol+210,"FELIZ ANIVERSÁRIO!",oFont4,,CLR_BLACK)
EndIf

//Tratamento de Mensagem de Ferias a Vencer
If MONTH(Date()) ==  MONTH(dDataPagto)
	SRF->(DbSetOrder(1))
	If SRF->(DbSeek(xFilial("SRF")+SRA->RA_MAT )) .and. (SRF->RF_DFERVAT+SRF->RF_DFERAAT) >= 55
		nLin += 26
		oHolerite:Say(nLin,nCol+nSp,"Lembrete: Você deve contatar o RH de sua empresa para programar o gozo de suas férias",oFont4,,CLR_BLACK)
	EndIf
EndIf

nLin += 26
oHolerite:Box(nLin+nSp,nCol,nlin+36,nColFim)
nLin += 13
oHolerite:Say(nLin,nCol+170,"Válido como Comprovante Mensal de Rendimentos",oFont4,,CLR_BLACK)
nLin += 13
oHolerite:Say(nLin,nCol+130,"( Artigo no. 41 e 464 da CLT, Portaria MTPS/GM 3.626 de 13/11/1991 )",oFont4,,CLR_BLACK)

oHolerite:EndPage()  
oHolerite:Print()

//Conexão com o Email -----------------------------------------------
cSubject	:= "Demonstrativo - "+ALLTRIM(cDescEmp)+" - "+cReferencia
cTexto		:= ""

If SRA->RA_SEXO == "M"
	cTexto := "<p>Prezado,<br>"
ElseIf SRA->RA_SEXO == "F"
	cTexto := "<p>Prezada,<br>"
EndIf
cTexto += Capital(SRA->RA_NOME)+"</p>
cTexto += "<p>Informamos a emissão do Demonstrativo de Pagamento "+cReferencia+".</p>
cTexto += "<br>"

//MSM - 10/09/2014 - Adicionado tratamento para apresentar o contato do RH para a empresa MFS, chamado: 021077 
if cEmpAnt $ "4J"
	cTexto += "<p>Em caso de dúvidas, favor entrar em contato com o Gustavo Freitas - Departamento de RH.</p>"
else
	cTexto += "<p>Em caso de dúvidas, favor entrar em contato com o Departamento de RH.</p>"
endif

cTexto += "<br>"
cTexto += "<p>Este e-mail foi enviado automaticamente, favor não responder!"
cTexto += "<br>Atenciosamente,</p>"

oMessage			:= TMailMessage():New()
oMessage:Clear()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cMailConta
oMessage:cTo		:= cEmail
oMessage:cSubject	:= cSubject
oMessage:cBody		:= cTexto

CpyT2S(cDirGer+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf","\SYSTEM\", .F. )

xRet := oMessage:AttachFile("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf")
If xRet < 0
	conout( "Could not attach file " + "Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf" )
	lEnvioOK := .F.
EndIf

oServer				:= tMailManager():New()
oServer:SetUseTLS(.T.)
cUser				:= cMailConta
cPass				:= cMailSenha
xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 587 )
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
// try with account and pass
xRet:=oServer:SMTPAuth(cAccount,cPassword)
If xRet != 0
	// try with user and pass
	xRet := oServer:SMTPAuth(cUserAut,cPassAut)
	If xRet != 0
		conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
		lEnvioOK := .F.
		oServer:SMTPDisconnect()
	Endif
Endif
xRet := oServer:SmtpAuth( cUser, cPass )
If xRet <> 0
    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
    lEnvioOK := .F.
    oServer:SMTPDisconnect()
EndIf      
//Envio
xRet := oMessage:Send( oServer )
If xRet <> 0
    cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
    lEnvioOK := .F.
EndIf
//Encerra
xRet := oServer:SMTPDisconnect()
If xRet <> 0
    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
EndIf

If File("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf")
	FErase("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf")
EndIf

//Possibilidade de impressão do padrão em caso de erro.
If !lEnvioOK                      
	Return !MsgYesNo("Não foi possivel a geração de email customizada, deseja enviar a versão padrão?","Grant Thornton Brasil")
EndIf

Return .T.