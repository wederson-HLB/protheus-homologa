#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Empresa  ³ AKRON Projetos e Sistemas                                  ³±±
±±³          ³ Rua Jose Oscar Abreu Sampaio, 113 - Sao Paulo - SP         ³±±
±±³          ³ Fone: (11) 3853-6470                                       ³±±
±±³          ³ Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa  ³ AKULTMV   ³ Autor ³ Larson Zordan        ³ Data ³13/11/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de importação de pedido de vendas para ORANGE a   ³±±
±±³          ³ partir de Layout estabelecido.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AKORA01(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG - ORANGE                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AKORA01()
Local aRet  := {Space(120),Space(3)}

If SM0->M0_CODIGO $ GetNewPar("MV_INTORA","LW/LX/LY")
	If ParamBox( {	{6,"Selecionar a Arquivo",aRet[1],"@!","FILE(mv_par01)"          ,"",80,.T.,"Arquivo CSV | *.CSV","C:\"},;
					{1,"Qual a TES"          ,aRet[2],"@!","ExistCpo('SF4',mv_par02)","SF4","",20,.T.}}, "Importar CSV Pedido de Vendas - Orange", @aRet)
		Processa( { || ProcArq(aRet[1],aRet[2]) }, "Aguarde", "Iniciando o Processo de Importação..." )
	EndIf
Else
	Aviso("Atenção", "Esta função não está disponivel para a empresa: "+ALLTRIM(SM0->M0_NOME), { "Sair >>" }, 2, "Funcionalidade Inválida")
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcArq  ³ Autor ³ Larson Zordan         ³ Data ³06/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a leitura do arquivo e a gravacao do pedido venda ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProcArq(ExpC1,ExpC2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Arquivo a ser importado                            ³±±
±±³          ³ ExpC2 - TES a ser considerada no PV                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG - ORANGE                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcArq(cArqTXT,cTES)

Local aCab      := {}
Local aErroCli  := {}
Local aErroCPg  := {}
Local aErroPrd  := {}
Local aErroTrp  := {} 
Local aItens    := {}
Local aItensOK  := {}
Local aVetorPed := {}
Local aVetorTXT := {}

Local cCliente  := ""
Local cCodCtrl  := ""
Local cCPag     := ""
Local cFilial   := cFilAnt
Local cItem     := "00"
Local cLine     := ""
Local cLineOk   := ""
Local cLog      := ""
Local cLogErro	:= ""
Local cProduto  := ""
Local cTransp   := ""
Local cDest		:= ""


Local cFilIni  := cFilAnt

Local dDataPed  := CtoD("")

Local lContinua := .T.
Local lSB1      := SB1->(FieldPos("B1_XCODBEP")) > 0
Local lPedido   := .F.
Local cCodCli	:= ""
Local cCLojCli	:= ""
Local aCliente	:= {}
Local cCodOra	:= ""

Local nTotalArq := 0
Local nX        := 0

Local nPosLoj	:=  4
Local nPosClie  :=  5
Local nPosFil   :=  4
Local nPosTran  :=  6
Local nPosCPag  :=  7
Local nPosEmis  :=  8
Local nPosMsg1  :=  9
Local nPosMsg2  := 10
Local nPosMsg3  := 11
Local nPosMsg4  := 12
Local nPosProd  := 13
Local nPosDesc  := 14
Local nPosSeri  := 15
Local nPosQtde  := 16
Local nPosVUni  := 17
Local nPosTota  := 18
Local nPosTes   := 19
Local nPosCtr   := 20
Local nPosTipo  := 21

Local cCodLocal	:= ""
Local cNum		:= ""
Local aArea		:= GetArea()

Local cTipo		:= ""
Local cFilAux 	:= cFilAnt

Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

nTotalArq := FT_FUse(cArqTXT)

If nTotalArq == 0
	Aviso("Atenção","O Arquivo: " + cArqTXT + " está vazio, processo finalizado!", { "Sair >>" }, 2, "Arquivo Inválido")
	Return
EndIf

FT_FGOTOP()
ProcRegua(1)
While !FT_FEof()
	IncProc("Lendo Arquivo de Importação...")

	cLine     := FT_FReadLn()
	cLineOk   := StrTran(cLine,";;",";NIL;",1) //SUBSTITUIR ";;" POR ";NIL;" EM TODO O TXT
	aVetorTXT := Separa(cLineOk,";",.T.)

	aAdd( aVetorPed, aVetorTXT )

	FT_FSkip()
EndDo
FT_FUse()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processo de Verificar os dados do Arq. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(Len(aVetorPed))
For nX := 2 To Len(aVetorPed)
	If !(Empty(aVetorPed[nX][nPosClie])) .And. Alltrim(aVetorPed[nX][nPosClie]) # "NIL"

		IncProc("Verificando Informações do Arquivo...")
	
		cCodCtrl := aVetorPed[nX][nPosCtr]
		cCliente := StrTran(StrTran(StrTran(aVetorPed[nX][nPosClie],".",""),"/",""),"-","")
		cTransp  := StrTran(StrTran(StrTran(aVetorPed[nX][nPosTran],".",""),"/",""),"-","")
		If lSB1
			cProduto := PadR(aVetorPed[nX][nPosProd],Len(SB1->B1_XCODBEP))
		Else	
			cProduto := PadR(aVetorPed[nX][nPosProd],Len(SB1->B1_COD))
		EndIf	
		
		//--> Posiciona na Transportadora
		SF4->(DbSetOrder(1)) 
		SF4->(DbSeek(xFilial("SF4") + cTes))
		//If Right(alltrim(SF4->F4_CF),3) # "933" .And. Left(alltrim(SF4->F4_CF),3) # "530" .And. Left(alltrim(SF4->F4_CF),3) # "630"
		//RRP - 13/01/2014 - Retirada o tratamento por CFOP conforme solicitado pela Fernanda Almeida.
		If Type(cTransp) <> 'U'
			//RRP - 04/02/2014 - Alterado para Filial + Código.		 
			SA4->(dbSetOrder(1))
			If !SA4->(dbSeek( xFilial("SA4")+cTransp )) .And. aScan( aErroTrp , aVetorPed[nX][nPosTran] ) == 0
				aAdd( aErroTrp , aVetorPed[nX][nPosTran] )
				lContinua := .F.
			EndIf
		End If
	
		//--> Posiciona nos Produtos
		If lSB1
			SB1->(DbOrderNickName("AKO"))//SB1->(dbSetOrder(12))
			If !SB1->(dBSeek(xFilial("SB1")+cProduto)) .And. aScan( aErroPrd , cProduto ) == 0 //RRP - 13/01/2014 - Ajuste no dbSeek
				SB1->(dbSetOrder(1))
				cProduto := PadR(aVetorPed[nX][nPosProd],Len(SB1->B1_COD))
				If !SB1->(dBSeek(xFilial("SB1")+cProduto)) .And. aScan( aErroPrd , cProduto ) == 0 //RRP - 13/01/2014 - Ajuste no dbSeek
					aAdd( aErroPrd , cProduto )
					lContinua := .F.
				EndIf	
			EndIf	
		Else	
			SB1->(dbSetOrder(1))
			If !SB1->(dBSeek("  "+cProduto)) .And. aScan( aErroPrd , cProduto ) == 0
				aAdd( aErroPrd , cProduto )
				lContinua := .F.
			EndIf	
	    EndIf
	End If
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processo de Importar o Pedido de Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	cLog += "------------------------"+CRLF
	cLog += "    PEDIDOS GERADOS     "+CRLF
	cLog += "------------------------"+CRLF
	cLog += "EMP | FIL | PEDIDO VENDA"+CRLF
	cLog += "------------------------"+CRLF
	
	cLogErro += "------------------------------------------------------------------------------"+CRLF
	cLogErro += "    		LINHAS COM PROBLEMAS 				      					  	   "+CRLF
	cLogErro += "------------------------------------------------------------------------------"+CRLF
	cLogErro += "EMP | LINHA | NUMERO CONTROLE  |  OBS              						   "+CRLF
	cLogErro += "------------------------------------------------------------------------------"+CRLF
	

	ProcRegua(Len(aVetorPed))
	For nX := 2 To Len(aVetorPed)
	
		If !(Empty(aVetorPed[nX][nPosClie])) .And. Alltrim(aVetorPed[nX][nPosClie]) # "NIL"
		
			IncProc("Importando Pedido de Venda...")
			
			If !Empty(cCliente) .And. (cCliente <> StrTran(StrTran(StrTran(aVetorPed[nX][nPosClie],".",""),"/",""),"-","")) .Or. (cCodCtrl <> aVetorPed[nX][nPosCtr])
	
				If Len(aCab) > 0 .And. Len(aItensOK) > 0 
					Begin Transaction
					MsExecAuto({|x,y,z| Mata410(x,y,z)},aCab,aItensOK,3)
					End Transaction
					
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						ROLLBACKSXE()
						Exit
					Else
						CONFIRMSX8()
						RecLock("SC5",.F.)
						SC5->C5_TRANSP := SA4->A4_COD
						SC5->(MsUnLock())
			
						lPedido := .T.	
						cLog += cEmpAnt + "  | " + cFilial + "  | " + SC5->C5_NUM + CRLF
						
						//MSM - 05/06/2015 - Gravação de log na tabela ZX4
						GravaLog("INSERIDO","",SC5->C5_NUM,SC5->C5_XNUMCTR,cTipo,cArqTXT,cFilAnt)
						
					EndIf
				EndIf
		
				aCab     := {}
				aItens   := {}
				aItensOK := {}
				cCliente := ""
				cCodCtrl := ""		
				cTransp  := ""
				cItem    := "00"
		
			EndIf
	
			cCodCtrl := aVetorPed[nX][nPosCtr]
			cCliente := StrTran(StrTran(StrTran(aVetorPed[nX][nPosClie],".",""),"/",""),"-","")
			cTransp  := StrTran(StrTran(StrTran(aVetorPed[nX][nPosTran],".",""),"/",""),"-","")
			
			//--> Monta Cabecalho
			If Len(aCab) == 0
				
				//--> Posiciona na Filial da Orange do Pedido de Venda
				//RRP - 21/01/2014 - Comentado, pois estava desposicionando o SM0
				/*SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt))
				While !SM0->(Eof()) .And. cEmpAnt == SM0->M0_CODIGO
					If SM0->M0_CGC == PadR(aVetorPed[nX][nPosFil], Len(SM0->M0_CGC) )
						cFilial := SM0->M0_CODFIL
						Exit
					EndIf
					SM0->(dbSkip())
				EndDo*/

				cTipo := Upper(alltrim(aVetorPed[nX][nPosTipo]))
				
				//MSM - 03/06/2015 - Tratamento para coluna tipo, se for diferente de SRV, incluir na filial contida no numero do controle
				if Upper(alltrim(aVetorPed[nX][nPosTipo]))<>"SRV"

					//MSM - 04/02/2015 - Tratamento para inclusão em filiais diferentes
					cCodLocal	:= Substr(aVetorPed[nX][nPosCtr],1,3)
					cFilAux		:= DePaFili(cCodLocal)				
					if empty(cFilAux)

						cLogErro += cEmpAnt + "  | " + PADL(cvaltochar(nX),5) + " | " + PADL(alltrim(aVetorPed[nX][nPosCtr]),16) + " | "+"Não encontrado filial para número de controle"  + CRLF
						cMotivo	:= cEmpAnt + "  | " + PADL(cvaltochar(nX),5) + " | " + PADL(alltrim(aVetorPed[nX][nPosCtr]),16) + " | "+"Não encontrado filial para número de controle"

						//MSM - 05/06/2015 - Gravação de log na tabela ZX4
						GravaLog("ERRO",cMotivo,"",aVetorPed[nX][nPosCtr],cTipo,cArqTXT,cFilAnt)

						Loop
					endif

					//Altera o cFilAnt para poder incluir pedidos em outra filial
					cFilAnt	:= cFilAux
				
				//MSM - 03/06/2015 - Tratamento para coluna tipo, se for SRV, incluir na matriz
				else
					//Altera o cFilAnt para poder incluir pedidos na matriz
					cFilAnt	:= "01" //Matriz				
					cFilAux := "01" //Matriz
				endif
				
				
				cNum	:= GetSxEnum("SC5","C5_NUM")	                
				
				//--> Posiciona na Transportadora
				//RRP - 13/01/2014 - Retirada o tratamento por CFOP conforme solicitado pela Fernanda Almeida. 
				//If Right(alltrim(SF4->F4_CF),3) # "933" .And. Left(alltrim(SF4->F4_CF),3) # "530" .And. Left(alltrim(SF4->F4_CF),3) # "630"
				If Type(cTransp) <> 'U'
					//RRP - 04/02/2014 - Alterado para Filial + Código. 
					SA4->(dbSetOrder(1))
					SA4->(dbSeek( xFilial("SA4")+cTransp ))
				End If
				
				//--> Posiciona nos Clientes
				cCodOra		:= aVetorPed[nX][nPosClie]
				aCliente	:= U_ORGTCLI(cCodOra)
				cCodCli 	:= aCLiente[1][1]
				cLojCli		:= aCLiente[1][2]
				
				//--> Muda a DataBase do Protheus em relacao ao Pedido de Vendas
				dDataPed  := CtoD(Left(aVetorPed[nX][nPosEmis],10))
				dDataBase := dDataPed
		
				SA1->(dbSetOrder(1))
				If SA1->(dBSeek( xFilial("SA1") + cCodCli + cLojCli ))
					aAdd( aCab, {"C5_FILIAL" , cFilAux		    						,Nil})
					aAdd( aCab, {"C5_NUM" 	 , cNum			    						,Nil})
					aAdd( aCab, {"C5_TIPO"   , "N"               						,Nil})
					aAdd( aCab, {"C5_CLIENTE", cCodCli								 	,Nil})
					aAdd( aCab, {"C5_LOJACLI", cLojCli	    				        	,Nil})
					
   					//RRP - 13/01/2014 - Retirada o tratamento por CFOP conforme solicitado pela Fernanda Almeida.
					//If Right(alltrim(SF4->F4_CF),3) # "933" .And. Left(alltrim(SF4->F4_CF),3) # "530" .And. Left(alltrim(SF4->F4_CF),3) # "630" 
					If Type(cTransp) <> 'U'
						aAdd( aCab, {"C5_TRANSP" , SA4->A4_COD							,Nil})
					Else
						aAdd( aCab, {"C5_TRANSP" , ""									,Nil})
					End If
					
					aAdd( aCab, {"C5_TPFRETE", "C"             					     	,Nil})
					aAdd( aCab, {"C5_RECFAUT", "1"               						,Nil})
					aAdd( aCab, {"C5_CONDPAG", aVetorPed[nX][nPosCPag]				 	,Nil})
					aAdd( aCab, {"C5_EMISSAO", dDataPed             					,Nil})
					aAdd( aCab, {"C5_MENNOTA", IIF(aVetorPed[nX][nPosMsg1]#"NIL",aVetorPed[nX][nPosMsg1],"") ,Nil})
					aAdd( aCab, {"C5_MENNOT1", IIF(aVetorPed[nX][nPosMsg2]#"NIL",aVetorPed[nX][nPosMsg2],"") ,Nil})
					aAdd( aCab, {"C5_MENNOT2", IIF(aVetorPed[nX][nPosMsg3]#"NIL",aVetorPed[nX][nPosMsg3],"") ,Nil})
					aAdd( aCab, {"C5_MENNOT3", IIF(aVetorPed[nX][nPosMsg4]#"NIL",aVetorPed[nX][nPosMsg4],"") ,Nil})
					aAdd( aCab, {"C5_XNUMCTR", aVetorPed[nX][nPosCtr]				    ,Nil})
					
				Else
					Aviso( "Atenção", "O Cliente "+cCliente+" não foi localizado no cadastro de Clientes."+CRLF+CRLF+"O Pedido Não será importado.", { "Sair >>" }, 1, "Cliente Inválido")
					cLogErro += cEmpAnt + "  | " + PADL(cvaltochar(nX),5) + " | " + PADL(alltrim(aVetorPed[nX][nPosCtr]),16) + " | "+"O Cliente "+cCliente+" não foi localizado no cadastro de Clientes " + CRLF
					cMotivo := cEmpAnt + "  | " + PADL(cvaltochar(nX),5) + " | " + PADL(alltrim(aVetorPed[nX][nPosCtr]),16) + " | "+"O Cliente "+cCliente+" não foi localizado no cadastro de Clientes "

					//MSM - 05/06/2015 - Gravação de log na tabela ZX4
					GravaLog("ERRO",cMotivo,"",aVetorPed[nX][nPosCtr],cTipo,cArqTXT,cFilAnt)
					
					Exit
				EndIf
			EndIf	
			
			//--> Monta Itens
			lContinua := .T.
			If lSB1
				SB1->(DbOrderNickName("AKO"))//SB1->(DbSetOrder(12))
				cProduto := PadR(aVetorPed[nX][nPosProd],Len(SB1->B1_XCODBEP))
				If !SB1->(dBSeek(xFilial("SB1")+cProduto))//RRP - 13/01/2014 - Ajuste no dbSeek
					SB1->(dbSetOrder(1))
					cProduto := PadR(aVetorPed[nX][nPosProd],Len(SB1->B1_COD))
					If !SB1->(dBSeek(xFilial("SB1")+cProduto))//RRP - 13/01/2014 - Ajuste no dbSeek
						lContinua := .F.
					EndIf
				EndIf	
			Else	
				SB1->(dbSetOrder(1))
				If !SB1->(dBSeek("  "+cProduto))
					lContinua := .F.
				EndIf	
		    EndIf
	
			SB1->(dbSetOrder(1))
			If lContinua
			    If !SB2->(dbSeek(XFilial("SB2")+cProduto+SB1->B1_LOCPAD))
					CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
			    EndIf				
				cItem := Soma1(cItem)
				aAdd( aItens,{"C6_FILIAL" , cFilAux		                         																,Nil})
				aAdd( aItens,{"C6_ITEM"   , cItem                                  																,Nil})
				aAdd( aItens,{"C6_PRODUTO", SB1->B1_COD			 																				,Nil})
				aAdd( aItens,{"C6_DESCRI" , alltrim(SB1->B1_DESC) + " " + IIF(aVetorPed[nX][nPosDesc]#"NIL",alltrim(aVetorPed[nX][nPosDesc]),"")	,Nil})
				aAdd( aItens,{"C6_NUMSERI", aVetorPed[nX][nPosSeri] 											,Nil})
				aAdd( aItens,{"C6_LOCAL"  , SB1->B1_LOCPAD                         								,Nil})
				aAdd( aItens,{"C6_QTDVEN" , Val(StrTran(aVetorPed[nX][nPosQtde],",","."))						,Nil})  
				aAdd( aItens,{"C6_PRCVEN" , Val(StrTran(aVetorPed[nX][nPosVUni],",","."))						,Nil})
				aAdd( aItens,{"C6_VALOR"  , Val(StrTran(aVetorPed[nX][nPosTota],",",".")) 						,Nil})
				If alltrim(aVetorPed[nX][nPosTes]) # "" .And. alltrim(aVetorPed[nX][nPosTes]) # "NIL"
					aAdd( aItens,{"C6_TES"    , alltrim(aVetorPed[nX][nPosTes])   								,Nil})
				Else
					aAdd( aItens,{"C6_TES"    , cTES							   								,Nil})
				End If
				aAdd( aItensOK, aItens )
				aItens := {}
			Else
				Aviso("Atenção","O Produto "+cProduto+" não foi localizado na base."+CRLF+CRLF+"O pedido Não será importado.", {"Sair >>"}, 2, "Produto Inválido" )
				cLogErro += cEmpAnt + "  | " + PADL(cvaltochar(nX),5) + " | " + PADL(alltrim(aVetorPed[nX][nPosCtr]),16) + " | "+"O Produto "+cProduto+" não foi localizado na base" + CRLF
				cMotivo	:= cEmpAnt + "  | " + PADL(cvaltochar(nX),5) + " | " + PADL(alltrim(aVetorPed[nX][nPosCtr]),16) + " | "+"O Produto "+cProduto+" não foi localizado na base"
				
				//MSM - 05/06/2015 - Gravação de log na tabela ZX4
				GravaLog("ERRO",cMotivo,"",aVetorPed[nX][nPosCtr],cTipo,cArqTXT,cFilAnt)				
				
				Exit
			EndIf
			
		End If
		
	Next nX
	
	If Len(aCab) > 0 .And. Len(aItensOK) > 0 
		Begin Transaction
		MsExecAuto({|x,y,z| Mata410(x,y,z)},aCab,aItensOK,3)
		End Transaction
		
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			ROLLBACKSXE()
		Else
			CONFIRMSX8()
			RecLock("SC5",.F.)
			SC5->C5_TRANSP := SA4->A4_COD
			SC5->(MsUnLock())

			lPedido := .T.	
			cLog += cEmpAnt + "  | " + cFilial + "  | " + SC5->C5_NUM + CRLF
			
			//MSM - 05/06/2015 - Gravação de log na tabela ZX4
			GravaLog("INSERIDO","",SC5->C5_NUM,SC5->C5_XNUMCTR,cTipo,cArqTXT,cFilAnt)
		EndIf
	EndIf
	
	dDataBase := Date()
Else

	cLog += Replicate("-",100)+CRLF
	cLog += "INCONSISTENCIAS ENCONTRADAS NO ARQUIVO: " + AllTrim(cArqTXT) + CRLF + Replicate("-",100)+CRLF

	ProcRegua(Len(aErroCli))
	For nX := 1 To Len(aErroCli)
		IncProc("Gerando Log dos Erros...")
		cLog += "Cliente com o CNPF/CPF " + aErroCli[nX] + " Não existe na base de dados de Clientes."+CRLF+Replicate("-",100)+CRLF
		lPedido := .T.
	Next nX

	ProcRegua(Len(aErroPrd))
	For nX := 1 To Len(aErroPrd)
		IncProc("Gerando Log dos Erros...")
		cLog += "Produto " + aErroPrd[nX] + " Não existe na base de dados de Produtos."+CRLF+Replicate("-",100)+CRLF
		lPedido := .T.
	Next nX

	ProcRegua(Len(aErroCPg)+Len(aErroTrp))
	For nX := 1 To Len(aErroCPg)
		IncProc("Gerando Log dos Erros...")
		cLog += "Condição de Pagamento " + aErroCPg[nX] + " Não existe na base de dados de Condições de Pagamentos."+CRLF+Replicate("-",100)+CRLF
		lPedido := .T.
	Next nX

	ProcRegua(Len(aErroTrp))
	For nX := 1 To Len(aErroTrp)
		IncProc("Gerando Log dos Erros...")
		cLog += "Transportadora " + aErroTrp[nX] + " Não existe na base de dados de Transportadoras."+CRLF+Replicate("-",100)+CRLF
		lPedido := .T.
	Next nX
EndIf

cLog += CRLF
cLog += cLogErro

//cFilial := c1Filial
cFilAnt	:= cFilIni
RestArea(aArea)
If lPedido
    //RRP - 13/01/2014 - Alteração na gravação do arquivo de log
	cDest	:=  GetTempPath()
	memowrite(cDest+"logprt.txt",cLog)
	ShellExecute("open",cDest+"logprt.txt","","",5)
EndIf	
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcArq  ³ Autor ³ Andre Minelli         ³ Data ³31/07/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtem o codigo do cliente e loja                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGTCLI(cCodOra)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodOra - Codigo do cliente na planilha (CODORA ou CNPJ)   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄmahtueÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG - ORANGE                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ORGTCLI(cCodOra)
Local aCliente 	:= {}
Local cQuery	:= ""

if SELECT("SQLSA1")>0
	SQLSA1->(DbCloseArea())
endif

cQuery := "SELECT A1_COD,A1_LOJA FROM " + RetSqlName("SA1") + " WHERE A1_CODORA = '" + cCOdOra + "' AND D_E_L_E_T_ = ''"
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLSA1",.T.,.T.)

If SQLSA1->(!EOF())

	AADD(aCliente, {SQLSA1->A1_COD,SQLSA1->A1_LOJA})
	SQLSA1->(DbCloseArea())

Else

	if SELECT("SQLSA1")>0
		SQLSA1->(DbCloseArea())
	endif

	cQuery := "SELECT A1_COD,A1_LOJA FROM " + RetSqlName("SA1") + " WHERE A1_CGC = '" + cCodOra + "' AND D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLSA1",.T.,.T.)
	If SQLSA1->(!EOF())
		AADD(aCliente, {SQLSA1->A1_COD,SQLSA1->A1_LOJA})
		SQLSA1->(DbCloseArea())
	End If
	
End If

if empty(aCliente)
	AADD(aCliente,{"",""})
endif

Return (aCliente)

/*
Funcao      : DePaFili()
Parametros  : 
Retorno     : 
Objetivos   : Função De Para, de códigos "Brazil Location" com as Filiais do sistema.
Autor       : Matheus Massarotto
Data/Hora   : 04/02/2015	12:10
*/

*-----------------------------*
Static Function DePaFili(cCod)
*-----------------------------*
Local aDePara	:= {}
Local nPos		:= 0
Local cRet		:= ""

Default cCod	:= ""

/*
			//Código, Filial
AADD(aDePara,{"MOA","29"})  //Amazonas
AADD(aDePara,{"BSB","23"})	//Distrito federal
//AADD(aDePara,{"VIX","18"})	//Espirito Santo
AADD(aDePara,{"GYN","13"})	//Goias
AADD(aDePara,{"REC","28"})	//Pernambuco
AADD(aDePara,{"POA","07"})	//Rio Grande do Sul
AADD(aDePara,{"BLU","08"})	//Santa Catarina
AADD(aDePara,{"SSA","31"})	//Bahia
AADD(aDePara,{"FOR","25"})	//Ceará
AADD(aDePara,{"BHO","19"})	//Minas Gerais
AADD(aDePara,{"CUR","05"})	//Paraná
//AADD(aDePara,{"RJT","12"})	//Rio de Janeiro
//AADD(aDePara,{"SPB","01"})	//São Paulo
*/

DbSelectArea("ZX3")
DbSetOrder(1)
ZX3->(DbGoTop())
While ZX3->(!EOF())
	
	AADD(aDePara,{ZX3->ZX3_BRCOD,ZX3->ZX3_FIL})
	
	ZX3->(DbSkip())
Enddo


nPos := aScanX( aDePara, { |X,Y| X[1] == UPPER(alltrim(cCod))})
if nPos>0
	cRet:= aDePara[nPos][2]
endif

Return(cRet)

/*
Funcao      : GravaLog()
Parametros  : 
Retorno     : 
Objetivos   : Função Para gravar log na tabela ZX4
Autor       : Matheus Massarotto
Data/Hora   : 05/06/2015	12:10
*/

*--------------------------------------------------------------*
Static Function GravaLog(cStatus,cMotivo,cPed,cNCont,cTipo,cArq,cFilInc)
*--------------------------------------------------------------*

RecLock("ZX4",.T.)
	ZX4->ZX4_DATA	:= DTOS(date())
	ZX4->ZX4_HORA	:= SUBSTR(TIME(),1,8)
	ZX4->ZX4_STATUS	:= cStatus
	ZX4->ZX4_MOTIVO := cMotivo
	ZX4->ZX4_PEDIDO := cPed
	ZX4->ZX4_NCONTR := cNCont
	ZX4->ZX4_TIPO   := cTipo
	ZX4->ZX4_ARQ    := cArq
	ZX4->ZX4_FILINC := cFilInc
	ZX4->ZX4_USER	:= UsrFullName(__cUserID)
MsUnLock()


Return