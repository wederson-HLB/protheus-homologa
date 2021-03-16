#Include "Protheus.ch"
#include "Fileio.ch"

/*
Funcao      : GTCORP59
Parametros  : Nil
Retorno     : Nil
Objetivos   : Fonte para atualizar o nosso numero dos títulos a receber, de acordo com o retorno do banco
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2013    11:07
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/

*---------------------*
User function GTCORP59
*---------------------*
Local cPosNum,cPosData,cPosDesp,cPosDesc,cPosAbat,cPosPrin,cPosJuro,cPosMult
Local cPosOcor,cPosTipo,cPosCC,cPosDtCC,cPosMot
Local lPosNum  :=.f.,lPosData:=.f.,lPosMot  :=.f.
Local lPosDesp :=.f.,lPosDesc:=.f.,lPosAbat :=.f.
Local lPosPrin :=.f.,lPosJuro:=.f.,lPosMult :=.f.
Local lPosOcor :=.f.,lPosTipo:=.f.,lPosOutrD:= .F.
Local lPosCC   :=.f.,lPosDtCC:=.f.,lPosNsNum:=.f.

Local lPosDtVc := .F.
Local nLenDtVc
Local cPosDtVc

Local nDespes :=0
Local nDescont:=0
Local nAbatim :=0
Local nValRec :=0
Local nJuros  :=0
Local nMulta  :=0
Local nValCc  :=0
Local nCM     :=0
Local nOutrDesp :=0

Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
Local nTamNum	:= TamSX3("E1_NUM")[1]
Local nTamPar	:= TamSX3("E1_PARCELA")[1]
Local nTamTit	:= nTamPre+nTamNum+nTamPar

Local aArea:=GetArea()

Local cMsg:="Nenhuma informação foi alterada!"
         
Local aTabela 	:= {}
Local cTabela 	:= ""
Local cPerg		:= "P_GTCORP59"

//Ajusta a pergunta
pergunta(cPerg)

if !Pergunte(cPerg,.T.)
	Return
endif


//------------------------******Montagem do aheader para apresentação da alteração******------------------------
Private aAlter	:= {}
Private aHeader := {}
Private aCols 	:= {}
Private nUsado 	:= 0
Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
					{"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}} 
					

			nUsado:=nUsado+1                            
			AADD(aHeader,{ TRIM(""),;
								 "E1_VISU",;
								 "@BMP",;
								 2,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
			aadd(aAlter,"E1_VISU")
			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Prefixo"),;
								 "E1_TPM_1",;
								 "@X  ",;
								 3,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Numero"),;
								 "E1_TPM_2",;
								 "  ",;
								 9,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Parcela"),;
								 "E1_TPM_3",;
								 "@X  ",;
								 2,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Tipo"),;
								 "E1_TPM_4",;
								 "@X  ",;
								 3,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Num Bco"),;
								 "E1_TPM_5",;
								 "@X  ",;
								 15,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Observação"),;
								 "E1_TPM_6",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )

//------------------------******Fim Montagem do aheader para apresentação da alteração******------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Banco indicado                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBanco  := mv_par03
cAgencia:= mv_par04
cConta  := mv_par05
cSubCta := mv_par06

dbSelectArea("SA6")
DbSetOrder(1)
SA6->( dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta) )

dbSelectArea("SEE")
DbSetOrder(1)
SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )
If !SEE->( found() )
	Help(" ",1,"PAR150")
    Return
Endif

cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )

DbSelectArea("SX5")
SX5->(DbGoTop())

If !SX5->( dbSeek( xFilial("SX5") + cTabela ) )
	Help(" ",1,"PAR150")
	Return
Endif

//Busca as especies
While !SX5->(Eof()) .and. SX5->X5_TABELA == cTabela
	AADD(aTabela,{Alltrim(X5Descri()),AllTrim(SX5->X5_CHAVE)})
	SX5->(dbSkip( ))
Enddo

/*
	Precessa o arquivo de configuração
*/

//arquivo de configuração
FT_FUse(UPPER(MV_PAR02)) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
 	//aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o tipo de qual registro foi lido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		IF SubStr(cLinha,1,1) == CHR(1)
			FT_FSkip()
			Loop
		EndIF
		IF SubStr(cLinha,1,1) == CHR(3)
  			FT_FSkip()
			Exit
		EndIF

		IF !lPosNum
			cPosNum:=Substr(cLinha,17,10)
			nLenNum:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosNum:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosData
			cPosData:=Substr(cLinha,17,10)
			nLenData:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosData:=.t.
			FT_FSkip()
			Loop
		End
		IF !lPosDesp
			cPosDesp:=Substr(cLinha,17,10)
			nLenDesp:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosDesp:=.t.
			FT_FSkip()
			Loop
		End
		IF !lPosDesc
			cPosDesc:=Substr(cLinha,17,10)
			nLenDesc:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosDesc:=.t.
			FT_FSkip()
			Loop
		End
		IF !lPosAbat
			cPosAbat:=Substr(cLinha,17,10)
			nLenAbat:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosAbat:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosPrin
			cPosPrin:=Substr(cLinha,17,10)
			nLenPrin:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosPrin:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosJuro
			cPosJuro:=Substr(cLinha,17,10)
			nLenJuro:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosJuro:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosMult
			cPosMult:=Substr(cLinha,17,10)
			nLenMult:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosMult:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosOcor
			cPosOcor:=Substr(cLinha,17,10)
			nLenOcor:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosOcor:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosTipo
			cPosTipo:=Substr(cLinha,17,10)
			nLenTipo:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosTipo:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosOutrD
			cPosOutrD:=Substr(cLinha,17,10)
			nLenOutrD:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosOutrD:=.t.
			FT_FSkip()
			Loop
		EndIF	
		IF !lPosCC
			cPosCC:=Substr(cLinha,17,10)
			nLenCC:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosCC:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosDtCc
			cPosDtCc:=Substr(cLinha,17,10)
			nLenDtCc:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosDtCc:=.t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosNsNum
			cPosNsNum := Substr(cLinha,17,10)
			nLenNsNum := 1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosNsNum := .t.
			FT_FSkip()
			Loop
		EndIF
		IF !lPosMot									// codigo do motivo da ocorrencia
			cPosMot:=Substr(cLinha,17,10)
			nLenMot:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosMot:=.t.
			FT_FSkip()
			Loop
		EndIF
		If !lPosDtVc
			cPosDtVc:=Substr(cLinha,17,10)
			nLenDtVc:=1+Int(Val(Substr(cLinha,20,3)))-Int(Val(Substr(cLinha,17,3)))
			lPosDtVc:=.t.
			FT_FSkip()
			Loop
		Endif


	FT_FSkip() // Proxima linha

EndDo 


FT_FUse() // Fecha o arquivo                     

/*
	Precessa o arquivo retorno do bando
*/

FT_FUse(UPPER(MV_PAR01)) // Abre o arquivo
FT_FGOTOP()      // Posiciona no inicio do arquivo

While !FT_FEof()
   	cLinha := FT_FReadln()        // Le a linha
   	
	IF SubStr(cLinha,1,1) $ "0#A"
		FT_FSkip() // Proxima linha
		Loop
	EndIF
	
	IF SubStr(cLinha,1,1) $ "1#F#J#7#2"

   	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lˆ os valores do arquivo Retorno ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumTit :=Substr(cLinha,Int(Val(Substr(cPosNum, 1,3))),nLenNum )
			cData   :=Substr(cLinha,Int(Val(Substr(cPosData,1,3))),nLenData)
			cData   :=ChangDate(cData,SEE->EE_TIPODAT)
			dBaixa  :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
			cTipo   :=Substr(cLinha,Int(Val(Substr(cPosTipo, 1,3))),nLenTipo )
			cTipo   := Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
			cNsNum  := " "
			cEspecie:= "   "
			dDataCred := Ctod("//")
			dDtVc := Ctod("//")
			cMotBan:=""
			IF !Empty(cPosDesp)
				nDespes:=Round(Val(Substr(cLinha,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100,2)
			EndIF
			IF !Empty(cPosDesc)
				nDescont:=Round(Val(Substr(cLinha,Int(Val(Substr(cPosDesc,1,3))),nLenDesc))/100,2)
			EndIF
			IF !Empty(cPosAbat)
				nAbatim:=Round(Val(Substr(cLinha,Int(Val(Substr(cPosAbat,1,3))),nLenAbat))/100,2)
			EndIF
			IF !Empty(cPosPrin)
				nValRec :=Round(Val(Substr(cLinha,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100,2)
			EndIF
			IF !Empty(cPosJuro)
				nJuros  :=Round(Val(Substr(cLinha,Int(Val(Substr(cPosJuro,1,3))),nLenJuro))/100,2)
			EndIF
			IF !Empty(cPosMult)
				nMulta  :=Round(Val(Substr(cLinha,Int(Val(Substr(cPosMult,1,3))),nLenMult))/100,2)
			EndIF
			IF !Empty(cPosOutrd)
				nOutrDesp  :=Round(Val(Substr(cLinha,Int(Val(Substr(cPosOutrd,1,3))),nLenOutrd))/100,2)
			EndIF
			IF !Empty(cPosCc)
				nValCc :=Round(Val(Substr(cLinha,Int(Val(Substr(cPosCc,1,3))),nLenCc))/100,2)
			EndIF
			IF !Empty(cPosDtCc)
				cData  :=Substr(cLinha,Int(Val(Substr(cPosDtCc,1,3))),nLenDtCc)
				cData    := ChangDate(cData,SEE->EE_TIPODAT)
				dDataCred:=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
				dDataUser:=dDataCred
			End
			IF !Empty(cPosNsNum)
				cNsNum  :=Substr(cLinha,Int(Val(Substr(cPosNsNum,1,3))),nLenNsNum)
			End
			If nLenOcor == 2
				cOcorr  :=Substr(cLinha,Int(Val(Substr(cPosOcor,1,3))),nLenOcor) + " "
			Else
				cOcorr  :=Substr(cLinha,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
			EndIf
			If !Empty(cPosMot)
				cMotBan:=Substr(cLinha,Int(Val(Substr(cPosMot,1,3))),nLenMot)
			EndIf
			IF !Empty(cPosDtVc)
				cDtVc :=Substr(cLinha,Int(Val(Substr(cPosDtVc,1,3))),nLenDtVc)
				cDtVc := ChangDate(cDtVc,SEE->EE_TIPODAT)
				dDtVc :=Ctod(Substr(cDtVc,1,2)+"/"+Substr(cDtVc,3,2)+"/"+Substr(cDtVc,5,2),"ddmmyy")
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica especie do titulo    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := Ascan(aTabela, {|aVal|aVal[1] == Substr(cTipo,1,2)})
			If nPos != 0
				cEspecie := aTabela[nPos][2]
			Else
				cEspecie	:= "  "
			EndIf
			If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
				FT_FSkip()
				Loop
			Endif
            
			// Estrutura de aValores
			//	Numero do T¡tulo	- 01
			//	data da Baixa		- 02
			// Tipo do T¡tulo		- 03
			// Nosso Numero		- 04
			// Valor da Despesa	- 05
			// Valor do Desconto	- 06
			// Valor do Abatiment- 07
			// Valor Recebido    - 08
			// Juros					- 09
			// Multa					- 10
			// Outras Despesas	- 11
			// Valor do Credito	- 12
			// Data Credito		- 13
			// Ocorrencia			- 14
			// Motivo da Baixa 	- 15
			// Linha Inteira		- 16
			// Data de Vencto	   - 17
			// Especie	   - 18

			aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, cLinha,dDtVc,cEspecie,{} })

			AlteraSE1(aValores,nTamTit,@aCols,aHeader,nUsado,nTamPre,nTamNum,nTamPar,nTamTit)

	Else
		FT_FSkip() // Proxima linha		
		Loop
	Endif   
 
	FT_FSkip() // Proxima linha

EndDo 

FT_FUse() // Fecha o arquivo    

//MsgInfo(cMsg)
if !empty(aCols)
	mostraalt(aCols,aHeader,aAlter)
else
	MsgInfo("Nenhum dado foi processado!")
endif

RestArea(aArea)
Return

/*
Funcao      : AlteraSE1()  
Parametros  : aValores,nTamTit
Retorno     : lAltera
Objetivos   : Altera o SE1, gravando o nosso numero
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2013
*/

*-----------------------------------------*
Static function AlteraSE1(aValores,nTamTit,aCols,aHeader,nUsado,nTamPre,nTamNum,nTamPar,nTamTit)
*-----------------------------------------*
Local lAltera	:= .F.
Local cObs		:= ""
Local oVisu		:= LoadBitmap( GetResources(), "WATCH")   //LUPA

if !empty(aValores[1]) .AND. !empty(aValores[4])
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbGotop())
    
    //Se for numero do título normal
    //Substr(cNumTit,1,nTamTit)+cEspecie
	if SE1->(DbSeek(xFilial("SE1")+Substr(aValores[1],1,nTamTit)+aValores[18]))
		if Empty(SE1->E1_NUMBCO)
            
        	//Tratamento para a ocorrencia
			dbSelectArea("SEB")
			dbSetOrder(1)
			if !(dbSeek(xFilial("SEB")+MV_PAR03+aValores[14]+"R"))
			    cObs:="Ocorrencia não encontrada: "+MV_PAR03+"-"+aValores[14]+"R"    
			else
				if SEB->EB_OCORR=="02" //confirmado
					RecLock("SE1",.F.)
						GravaLog(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NUMBCO,aValores[4])
						SE1->E1_NUMBCO:=aValores[4]
						lAltera:=.T.
						cObs:="Inserido"
					SE1->(MsUnlock())				
	
				else
					cObs:=SEB->EB_DESCRI
				endif
			endif

		else
			//Tratamento para a ocorrencia
			dbSelectArea("SEB")
			dbSetOrder(1)
			if !(dbSeek(xFilial("SEB")+MV_PAR03+aValores[14]+"R"))
			    cObs:="Ocorrencia não encontrada: "+MV_PAR03+"-"+aValores[14]+"R"    
			else
				if SEB->EB_OCORR=="02" //confirmado
					RecLock("SE1",.F.)
						GravaLog(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NUMBCO,aValores[4])	
						cObs:="Nosso número alterado de: "+alltrim(SE1->E1_NUMBCO)+", para: "+aValores[4]//Substr(aValores[1],1,nTamTit)
						SE1->E1_NUMBCO:=aValores[4]
						lAltera:=.T.
					SE1->(MsUnlock())
				else
					cObs:=SEB->EB_DESCRI
				endif
			endif
		endif
	else
		//Se for ID CNAB
		SE1->(DbSetOrder(16))
		SE1->(DbGotop())
		if DbSeek(xFilial("SE1")+Substr(aValores[1],1,10))
			if Empty(SE1->E1_NUMBCO)
	        	//Tratamento para a ocorrencia
				dbSelectArea("SEB")
				dbSetOrder(1)
				if !(dbSeek(xFilial("SEB")+MV_PAR03+aValores[14]+"R"))
				    cObs:="Ocorrencia não encontrada: "+MV_PAR03+"-"+aValores[14]+"R"    
				else
					if SEB->EB_OCORR=="02" //confirmado
						RecLock("SE1",.F.)
							GravaLog(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NUMBCO,aValores[4])
							SE1->E1_NUMBCO:=aValores[4]
							lAltera:=.T.
							cObs:="Inserido"
						SE1->(MsUnlock())				
					else
						cObs:=SEB->EB_DESCRI
					endif
				endif
			else
				//Tratamento para a ocorrencia
				dbSelectArea("SEB")
				dbSetOrder(1)
				if !(dbSeek(xFilial("SEB")+MV_PAR03+aValores[14]+"R"))
				    cObs:="Ocorrencia não encontrada: "+MV_PAR03+"-"+aValores[14]+"R"    
				else
					if SEB->EB_OCORR=="02" //confirmado
						RecLock("SE1",.F.)
							GravaLog(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NUMBCO,aValores[4])
							cObs:="Nosso número alterado de: "+alltrim(SE1->E1_NUMBCO)+", para: "+aValores[4]//Substr(aValores[1],1,nTamTit)		
							SE1->E1_NUMBCO:=aValores[4]
							lAltera:=.T.
						SE1->(MsUnlock())				
					else
						cObs:=SEB->EB_DESCRI
					endif
				endif
			endif	
		else
			cObs:="Título não encontrado: "+Substr(aValores[1],1,nTamTit)				
		endif
	endif

endif

if lAltera
	//Preenche o aCols para apresentação dos resultados
	AADD(aCols,Array(nUsado+1))
	For nI := 1 To nUsado
		if ALLTRIM(aHeader[nI,2]) =="E1_VISU"
			aCols[Len(aCols)][nI]:=oVisu
		elseif ALLTRIM(aHeader[nI,2]) =="E1_TPM_1"
			aCols[Len(aCols)][nI]:=Substr(aValores[1],1,nTamPre)
		elseif ALLTRIM(aHeader[nI,2]) =="E1_TPM_2"
			aCols[Len(aCols)][nI]:=Padr(Substr(aValores[1],4,6),nTamNum)
		elseif ALLTRIM(aHeader[nI,2]) =="E1_TPM_3"		    
			aCols[Len(aCols)][nI]:=SubStr(aValores[1],10,nTamPar)
		elseif ALLTRIM(aHeader[nI,2]) =="E1_TPM_4"
			aCols[Len(aCols)][nI]:=aValores[18]
		elseif ALLTRIM(aHeader[nI,2]) =="E1_TPM_5"
			aCols[Len(aCols)][nI]:=aValores[4]
		elseif ALLTRIM(aHeader[nI,2]) =="E1_TPM_6"
			aCols[Len(aCols)][nI]:=cObs
		endif
	Next
	aCols[Len(aCols)][nUsado+1] := .F.
endif
	
Return(lAltera)

/*
Funcao      : pergunta()  
Parametros  : cPerg
Retorno     : 
Objetivos   : Montagem da perunta
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2013
*/

*-----------------------------*
Static Function pergunta(cPerg)
*-----------------------------*

PutSx1( cPerg, "01", "Arquivo de Entrada ?"	, "Arquivo de Entrada ?", "Arquivo de Entrada ?", "", "C",80,00,00,"G","" , ""		,"","","MV_PAR01")
PutSx1( cPerg, "02", "Arquivo de Config ?"	, "Arquivo de Config ?"	, "Arquivo de Config ?"	, "", "C",50,00,00,"G","" , ""		,"","","MV_PAR02")
PutSx1( cPerg, "03", "Codigo do Banco ?"	, "Codigo do Banco ?"	, "Codigo do Banco ?"	, "", "C",03,00,00,"G","" , "SA6"	,"","","MV_PAR03")
PutSx1( cPerg, "04", "Codigo da Agencia ?"	, "Codigo da Agencia ?"	, "Codigo da Agencia ?"	, "", "C",05,00,00,"G","" , ""		,"","","MV_PAR04")
PutSx1( cPerg, "05", "Codigo da Conta ?"	, "Codigo da Conta ?"	, "Codigo da Conta ?"	, "", "C",10,00,00,"G","" , ""		,"","","MV_PAR05")
PutSx1( cPerg, "06", "Codigo da Sub-Conta?" , "Codigo da Sub-Conta?", "Codigo da Sub-Conta?", "", "C",03,00,00,"G","" , ""		,"","","MV_PAR06")
//PutSx1( cPerg, "07", "Configuracao CNAB ?"	, "Configuracao CNAB ?"	, "Configuracao CNAB ?" , "", "N",01,00,00,"C","" , ""		,"","","MV_PAR07","Modelo 1")

Return

/*
Funcao      : mostraalt()  
Parametros  : aCols,aHeader,aAlter
Retorno     : 
Objetivos   : Mostrar tela com registros alterados
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2013
*/
*---------------------------------------------*
Static function mostraalt(aCols,aHeader,aAlter)
*---------------------------------------------*
Private oDlg
Private oGetDados
	
oDlg := MSDIALOG():New(000,000,500,1000, "Resultado do Processamento",,,,,,,,,.T.)

oGetDados := MsGetDados():New(15, 05, 230, 500, GD_INSERT+GD_UPDATE, "AllwaysTrue()", "AllwaysTrue()",;
"", .T., aAlter, , .F., 200, "AllwaysTrue()", "AllwaysTrue()",,;
"AllwaysTrue()", oDlg)	

oDlg:bInit := {|| EnchoiceBar(oDlg, {||oDlg:End()},{||oDlg:End()})}


oGetDados :AddAction ( "E1_VISU"		, {||CarregaE1()	})

oDlg:lCentered := .T.
oDlg:Activate()

Return

/*
Funcao      : CarregaE1()  
Parametros  : 
Retorno     : 
Objetivos   : Visualizar o SE1 posicionado
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2013
*/
*-------------------------*
Static Function CarregaE1()
*-------------------------*
Local oVisu			:= LoadBitmap( GetResources(), "WATCH")
Private CCADASTRO	:= "Titulo a Receber"

aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]:=oVisu

nPos1:=aScan( aHeader, { |x| alltrim(x[2]) == "E1_TPM_1"} ) //prefixo
nPos2:=aScan( aHeader, { |x| alltrim(x[2]) == "E1_TPM_2"} )	//numero
nPos3:=aScan( aHeader, { |x| alltrim(x[2]) == "E1_TPM_3"} )	//parcela
nPos4:=aScan( aHeader, { |x| alltrim(x[2]) == "E1_TPM_4"} ) //Tipo

DbSelectArea("SE1")
SE1->(DbSEtOrder(1))
SE1->(DbSeek(xFilial("SE1")+aCols[oGetDados:Obrowse:nAt][nPos1]+aCols[oGetDados:Obrowse:nAt][nPos2]+aCols[oGetDados:Obrowse:nAt][nPos3]+aCols[oGetDados:Obrowse:nAt][nPos4]))

AxVisual( "SE1", SE1->( Recno() ), 2 )

Return

/*
Funcao      : GravaLog()  
Parametros  : cPref,cNum,cParc,cTipo,cNsNumAnt,cNsNum
Retorno     : 
Objetivos   : Gravar log de registros alterados
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2013
*/
*---------------------------------------------------------------*
Static function GravaLog(cPref,cNum,cParc,cTipo,cNsNumAnt,cNsNum)
*---------------------------------------------------------------*
Local cNomeArq:="GTCORP59.log"

//Verifica no diretório corrente do servidor se existe o arquivo
if !FILE(cNomeArq)
	nH := fCreate(cNomeArq) 
	If nH == -1                  
	   CONOUT("GTCORP59-->> Falha ao criar arquivo - erro "+str(ferror())) 
	   Return 
	Endif
else
	nH := fopen(cNomeArq,FO_WRITE)
	If nH == -1                  
	   CONOUT("GTCORP59-->> Falha ao abrir arquivo - erro "+str(ferror())) 
	   Return 
	Endif
endif

fseek(nH,FS_SET,FS_END)

cTexto:="------------------------------------------------------------------------------------------------------------------------------------------------------"+CRLF
cTexto+="Data:"+DTOC(dDataBase)+" - Empresa: ; "+cEmpAnt+" - Filial: "+cFilAnt+" - Id User:"+__cUserID+" - Nome Usuário: "+UsrFullName(__cUserID)+CRLF
cTexto+="E1_PREFIXO: "+cPref+"; E1_NUM: "+cNum+"; E1_PARCELA: "+cParc+"; E1_TIPO: "+cTipo+"; E1_NUMBCO anterior: "+cNsNumAnt+"; E1_NUMBCO novo: "+cNsNum+CRLF

fWrite(nH,cTexto)

fClose(nH)

Return
