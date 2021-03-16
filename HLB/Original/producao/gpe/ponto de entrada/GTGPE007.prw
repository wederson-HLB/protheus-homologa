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
Objetivos   : Chamado do Fonte Rdmake Padrão RECIBO.PRX, customização da criação e envio do email de demonstrativo de pagamento.
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

Local aAux			:= {}        

//Local cDescEmp 		:= IIF(cEmpAnt $ "4J",UPPER(Desc_Fil),Capital(Desc_Fil)) //MSM - 10/09/2014 - Adicionado tratamento para maiúscula na empresa MFS, chamado: 021077 
Local cDescEmp 		:= UPPER(Desc_Fil)

Private cDirGer		:= GetTempPath()+"holerite\"

Private lSenha := GetMv("MV_P_00034",,.F.)//Define se compacta o arquivo e usa senha ou nao.
Private lCompl := GetMv("MV_P_00052",,.F.)//Define se email com senha deve ser com complexidade elevada.
Private cCompl := ""

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
oHolerite:Say(nLin,nCol+nSp+35,AllTrim(cDescFunc),oFont3,,CLR_BLACK)
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

//Caso possuir senha no arquivo, informa como foi definida a senha.
If lSenha .and. !lCompl
	cTexto += "<p>*ATENÇÃO:" 
	cTexto += "<br>O Demonstrativo enviado esta compactado e com Senha"
	cTexto += "<br>-> Para descompactar, clique como botão direito do mouse e escolha 'extrair aqui'.
	cTexto += "<br>-> A senha é formada pelo Dia do seu Aniversario(DD) + 2 ultimos Digito do seu CPF(NN) + Ano do Seu Aniversario(AAAA) = (DDNNAAAA)</p>"
	cTexto += "<br>"
EndIf

//MSM - 10/09/2014 - Adicionado tratamento para apresentar o contato do RH para a empresa MFS, chamado: 021077 
//if cEmpAnt $ "4J"
//	cTexto += "<p>Em caso de dúvidas, favor entrar em contato com o Gustavo Freitas - Departamento de RH.</p>"
//else
//	cTexto += "<p>Em caso de dúvidas, favor entrar em contato com o Departamento de RH.</p>"
//endif
//JVR - 01/12/2014 - Alterado tratamento para Parametro.
cTexto += "<p>"+ALLTRIM(GetMv("MV_P_00033",,"Em caso de dúvidas, favor entrar em contato com o Departamento de RH."))+"</p>"

cTexto += "<br>"
cTexto += "<p>Este e-mail foi enviado automaticamente, favor não responder!"
cTexto += "<br>Atenciosamente,</p>"

oMessage			:= TMailMessage():New()
oMessage:Clear()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cMailConta
oMessage:cTo		:= cEmail
oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"//responder para...
oMessage:nXPriority := 2//Prioridade do email(1 maxima...5 minima - 3 default)
oMessage:cSubject	:= cSubject
oMessage:cBody		:= cTexto

CpyT2S(cDirGer+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf","\SYSTEM\", .F. )

//Caso seja tratado senha no arquivo
If lSenha
	cCompl	:= STRZERO(DAY(SRA->RA_NASC),2)+RIGHT(SRA->RA_CIC,2)+STRZERO(YEAR(SRA->RA_NASC),4)
	cDica	:= ""
	If lCompl
		aAux	:= GetPass()
		cCompl	:= aAux[1]
		cDica	:= aAux[2]
	EndIf
	cArq2Zip := "\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)
	compacta(cArq2Zip+".pdf",cArq2Zip+".ZIP",.F.,cCompl)
	xRet := oMessage:AttachFile("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".zip")
Else
	xRet := oMessage:AttachFile("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf")
EndIf

//GRAVA LOG
u_GravaZ21( cEmail , cReferencia )

If xRet < 0
	conout( "Could not attach file " + "Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+IIF(lSenha,".zip",".pdf") )
	lEnvioOK := .F.
EndIf

oServer				:= tMailManager():New()
oServer:SetUseTLS(.T.)
//AOA - 26/09/2017 - Alteração dados do SMTP do e-mail para envio
cUser				:= Alltrim(GetMv("MV_RELAUSR",," "))//cMailConta
cPass				:= Alltrim(GetMv("MV_RELAPSW",," "))//cMailSenha
If AT(":", cMailServer) > 0
	cMailServer := SUBSTR(cMailServer, 1, AT(":", cMailServer) - 1)
EndIf
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
//Apaga os arquivos criados
If File("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf")
	FErase("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".pdf")
EndIf
If File("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".zip")
	FErase("\SYSTEM\"+"Demonstrativo_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+".zip")
EndIf

//Possibilidade de impressão do padrão em caso de erro.
If !lEnvioOK                      
	Return !MsgYesNo("Não foi possivel a geração de email customizada, deseja enviar a versão padrão?","HLB BRASIL")
ElseIf lSenha .and. lCompl
	cSubject	:= "Senha Demonstrativo - "+ALLTRIM(cDescEmp)+" - "+cReferencia
	cTexto		:= ""
	cTexto		:= ""
	If SRA->RA_SEXO == "M"
		cTexto := "<p>Prezado,<br>"
	ElseIf SRA->RA_SEXO == "F"
		cTexto := "<p>Prezada,<br>"
	EndIf
	cTexto += Capital(SRA->RA_NOME)+"</p>
	cTexto += "<p>Informamos que a emissão do Demonstrativo de Pagamento "+cReferencia+" foi realizada.</p>
	cTexto += "<br>"                                                                                       
	cTexto += "<p>Abaixo segue a regra para a senha de acesso ao demonstrativo de pagamento:</p>
	cTexto += cDica
	cTexto += "<p>"+ALLTRIM(GetMv("MV_P_00033",,"Em caso de dúvidas, favor entrar em contato com o Departamento de RH."))+"</p>"
	cTexto += "<br>"
	cTexto += "<p>Este e-mail foi enviado automaticamente, favor não responder!"
	cTexto += "<br>Atenciosamente,</p>"

	oMessage			:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate		:= cValToChar(Date())
	oMessage:cFrom		:= cMailConta
	oMessage:cTo		:= cEmail
	oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
	oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"//responder para...
	oMessage:nXPriority := 2//Prioridade do email(1 maxima...5 minima - 3 default)
	oMessage:cSubject	:= cSubject
	oMessage:cBody		:= cTexto	
	
	oServer				:= tMailManager():New()
	oServer:SetUseTLS(.T.)
	//AOA - 26/09/2017 - Alteração dados do SMTP do e-mail para envio
	cUser				:= Alltrim(GetMv("MV_RELAUSR",," "))//cMailConta
	cPass				:= Alltrim(GetMv("MV_RELAPSW",," "))//cMailSenha
	If AT(":", cMailServer) > 0
		cMailServer := SUBSTR(cMailServer, 1, AT(":", cMailServer) - 1)
	EndIf
	xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 587 )
	
	//GRAVA LOG
	u_GravaZ21( cEmail , cReferencia )
	
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
	
EndIf

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri,cSenha)
*---------------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

Default lApagaOri := .T.
Default cSenha := ""

If lApagaOri
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ '+IIF(!EMPTY(cSenha),"-hp"+cSenha,"")+' "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Else
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ '+IIF(!EMPTY(cSenha),"-hp"+cSenha,"")+' "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
EndIf
lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Função.............: GravaZ21
Objetivo...........: Grava Log de envio de holerite via e-mail 
Autor..............: Anderson Arrais
Data...............: 10/06/2016
Observações........:
Parametros.........: ( cEmail , cReferencia )
*/

*---------------------------------------------------------------------*
User Function GravaZ21( cEmail , cReferencia )
*---------------------------------------------------------------------*

If AliasInDic( 'Z21' )
	Z21->( RecLock( 'Z21' , .T. ) )
	Z21->Z21_FILIAL := xFilial( 'Z21' )
	Z21->Z21_DATA	:= dDataBase
	Z21->Z21_HORA 	:= Time()
	Z21->Z21_NOME	:= SRA->RA_NOME
	Z21->Z21_MAT	:= SRA->RA_MAT
	Z21->Z21_EMAIL 	:= cEmail
	Z21->Z21_ASSUNT := cSubject
	Z21->Z21_REF	:= cReferencia
	Z21->Z21_USER	:= cUserName 
	Z21->Z21_ID		:= __cUserID 
	Z21->( MSUnlock() )
EndIf

Return .T.

/*
Funcao      : GetPass
Parametros  : 
Retorno     : aRet
				[1]	Senha
				[2] Dica da senha
Objetivos   : Função para criação da senha com complexidade alta e tratamento de dica.
Autor       : Jean Victor Rocha
Data/Hora   : 04/09/2015
*/
*-----------------------*
Static Function GetPass()
*-----------------------*
Local aRet := {}
Local i
Local aPass := {}

Local cEspecial := ""
Local nPos		:= 0
Local cPassRet := ""
Local cDicaRet := ""

Local aVarC := {	{SubStr(ALLTRIM(SRA->RA_NOME),1,1)	," - Primeira letra do seu primeiro nome em "			,"C"},;//1
					{SubStr(ALLTRIM(SRA->RA_PAI),1,1)	," - Primeira letra do primeiro nome do seu Pai em "	,"C"},;//2
					{SubStr(ALLTRIM(SRA->RA_MAE),1,1)	," - Primeira letra do primeiro nome da sua Mãe em "	,"C"},;//3
					{SubStr(ALLTRIM(SRA->RA_NOME),2,1)	," - Segunda letra do seu primeiro nome em " 			,"C"},;//4
					{SubStr(ALLTRIM(SRA->RA_NOME),3,1)	," - Terceira letra do seu primeiro nome em "  			,"C"}} //5
                                                                                                                  
Local aVarN := {	{SubStr(ALLTRIM(DTOS(SRA->RA_ADMISSA)),3,2)	," - Ano de Admissão (AA)."			   	   		,"N"},;//1
					{RIGHT(ALLTRIM(SRA->RA_CIC),2)				," - Digito do seu CPF (dois ultimos numeros)."	,"N"},;//2
					{SubStr(ALLTRIM(DTOS(SRA->RA_NASC   )),3,2)	," - Ano de nascimento (AA)."					,"N"},;//3
					{SubStr(ALLTRIM(DTOS(SRA->RA_NASC   )),5,2)	," - Mes de nascimento (MM)." 				  	,"N"},;//4
					{SubStr(ALLTRIM(DTOS(SRA->RA_NASC   )),7,2)	," - Dia de nascimento (DD)."  					,"N"}} //5

Local aVarEsp := {"!","@","#","$","%","&","(",")","-","+","="}

//Retira os campos em branco
i := 1
While LEN(aVarC) > 0 .AND. i <= LEN(aVarC)
	If EMPTY(aVarC[i][1])
		aDel(aVarC,i)
		aSize(aVarC,Len(aVarC)-1)
		i := 0
	EndIf
	i++
EndDo
i := 1
While LEN(aVarN) > 0 .AND. i <= LEN(aVarN)
	If EMPTY(aVarN[i][1])
		aDel(aVarN,i)
		aSize(aVarN,Len(aVarN)-1)
		i := 0
	EndIf
	i++
EndDo
/*
For i:=1 to Len(aVarC)
	If EMPTY(aVarC[i][1])
		aDel(aVarC,i)
		aSize(aVarC,Len(aVarC)-1)
		i:=0
		If Len(aVarC) == 0
			Exit
		EndIf
	EndIf
Next i                
For i:=1 to Len(aVarN)
	If EMPTY(aVarN[i][1])
		aDel(aVarN,i)
		aSize(aVarN,Len(aVarN)-1)
		i:=0
		If Len(aVarN) == 0
			Exit
		EndIf
	EndIf
Next i
*/
If Len(aVarC) == 0 .Or. Len(aVarN) == 0
	Return {"",""}
EndIf

//Captura das variaveis que serão utilizadas.
//Estava guardando a referencia das variaveis, foi necessario jogar em uma variavel e depois atribuir.
/*aAdd(aPass,aVarC[	Randomize(1,LEN(aVarC)+1)	])
aAdd(aPass,aVarC[	Randomize(1,LEN(aVarC)+1)	])
aAdd(aPass,aVarN[	Randomize(1,LEN(aVarN)+1)	])
aAdd(aPass,aVarN[	Randomize(1,LEN(aVarN)+1)	])
aAdd(aPass,{cEspecial," - Caracter especial '"+cEspecial+"'","E"}) */

cAux1 := ""
cAux2 := ""
cAux3 := ""      
aPass := {}                              
//C 1
nPos := Randomize(1,LEN(aVarC)+1)
cAux1 := UPPER(aVarC[nPos][1])
cAux2 := aVarC[nPos][2] + "maiuscula."
cAux3 := aVarC[nPos][3]
aAdd(aPass,{cAux1,cAux2,cAux3})
//C 2
nPos := Randomize(1,LEN(aVarC)+1)
cAux1 := LOWER(aVarC[nPos][1])
cAux2 := aVarC[nPos][2] + "minuscula."
cAux3 := aVarC[nPos][3]
aAdd(aPass,{cAux1,cAux2,cAux3})  
//N 3
nPos := Randomize(1,LEN(aVarN)+1)
cAux1 := aVarN[nPos][1]
cAux2 := aVarN[nPos][2]
cAux3 := aVarN[nPos][3]
aAdd(aPass,{cAux1,cAux2,cAux3})
//N 4
nPos := Randomize(1,LEN(aVarN)+1)
cAux1 := aVarN[nPos][1]
cAux2 := aVarN[nPos][2]
cAux3 := aVarN[nPos][3]
aAdd(aPass,{cAux1,cAux2,cAux3})
//E 5
cEspecial := aVarEsp[Randomize(1,LEN(aVarEsp)+1)]
aAdd(aPass,{cEspecial," - Caracter especial '"+cEspecial+"'","E"})

//Troca da primeira posição em Maiuscula e 2ª em minuscula.
/*aPass[1][1] := UPPER(aPass[1][1])
aPass[2][1] := LOWER(aPass[2][1])
aPass[1][2] += "maiuscula."
aPass[2][2] += "minuscula."
*/                    
//Criação da senha e da Dica
cPass := ""
cDica := "<p>"

While Len(aPass) >= 1
	nPos := Randomize(1,Len(aPass)+1)

	cPass += aPass[nPos][1]
	cDica += ALLTRIM(aPass[nPos][2])+"<br/>"+CHR(13)+CHR(10)
	aDel(aPass,nPos)
	aSize(aPass,Len(aPass)-1)
EndDo
cDica += "</p>"
aAdd(aRet,cPass)
aAdd(aRet,cDica)

Return aRet