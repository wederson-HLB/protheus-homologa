#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//------------------------------------------------------------------------------------------
#DEFINE ENTER CHR(13)+CHR(10)
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTGEN047
Realiza a importação dos arquivos de entrada de notas

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
User Function GTGEN047()

	Local oBtnSair
	Local oBtnImp
	Local nJanAltu := 140
	Local nJanLarg := 650
	Local oBtnArq
	Local nPosEF
	
	Private oSayArq, oGetArq, cGetArq := Space(200)
	Private oDlg
	Private nQtdOk   	:= 0
	Private lSchedule	:= FWGetRunSchedule()
	Private cLocArq 	:= GetNewPar('EZ_LOCARQ','\GTGEN047\ENTRADAS\')
	Private cLocImp 	:= GetNewPar('EZ_LOCIMP','\GTGEN047\IMPORTADOS\')
	Private cLocRet 	:= GetNewPar('EZ_LOCRET','\GTGEN047\RETORNOS\')
	Private lForcaSchd	:= GetNewPar('EZ_FSCHD' ,.F.)	// Se .T. -> Força a Execução sem a intervenção do usuário
	Private cMsgPlan	:= ""
	
	Private aEmpresas := FWLoadSM0()
	Private cEmpFilial := ''
	
	nPosEF := Ascan( aEmpresas, {|x| Alltrim(x[1])+Alltrim(x[2])  == Alltrim(SM0->M0_CODIGO)+Alltrim(SM0->M0_CODFIL) } )
	cEmpFilial := Alltrim(aEmpresas[nPosEF,1])+Alltrim(aEmpresas[nPosEF,2])
	
	If lForcaSchd
		lSchedule := .T.
	Endif
	
	dbSelectArea("SX3")
	SX2->(dbSetOrder(1))
	If !SX2->(dbSeek("Z0E"))
		MsgAlert("Tabela Z0E não existente, é necessário criar o compatiblizador!")
		Return
	Endif
	
	//--------------------------------------------------------------------------------------------
	// Caso a tabela de De-Para não exista, cria-se a tabela e popula os dados principais
	//--------------------------------------------------------------------------------------------	
	dbSelectArea("Z0E")
	If Z0E->(Eof())
		MsgAlert("FALTA DADOS NA TABELA DE DE-PARA, ACIONAR O T.I. E PEDIR PARA REALIZAR O APPEND DO DE-PARA") 
		MsgAlert("OPERAÇÃO ABORTADA! IMPORTAÇÃO NÃO REALIZADA")
	    Return
	Endif

	//--------------------------------------------------------------------------------------------
	// Fim da Criação da Z0E
	//--------------------------------------------------------------------------------------------
	
	//-----------------------------------------------------------------------------
	// Tratametno para criação das pastas -> Schedule
	//-----------------------------------------------------------------------------
	If !ExistDir('\GTGEN047\')
		MakeDir('\GTGEN047\')
	EndIf
		
	If !ExistDir(cLocArq)
		MakeDir(cLocArq)
	EndIf
	
	If !ExistDir(cLocImp)
		MakeDir(cLocImp)
	Endif

	If !ExistDir(cLocRet)
		MakeDir(cLocRet)
	Endif
	//-----------------------------------------------------------------------------
	//-----------------------------------------------------------------------------
	
	//-----------------------------------------------------------------------------
	// FTP para uso no schedule
	// Posso realizar uma chamada aqui para a rotina de busca no FTP
	//-----------------------------------------------------------------------------
	// 
	//-----------------------------------------------------------------------------
	//-----------------------------------------------------------------------------

	If !lSchedule
	
		Conout("Usuario -> B2LeArquivo")
	
		DEFINE MSDIALOG oDlg TITLE "Importação de Fornecedores e Notas Fiscais" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		@ 003, 003     GROUP oGrpPar TO 060, (nJanLarg/2)     PROMPT "Parâmetros: "         OF oDlg COLOR 0, 16777215 PIXEL
		//Caminho do arquivo
		@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"                  SIZE 060, 007 OF oDlg PIXEL
		@ 010, 070 MSGET      oGetArq VAR    cGetArq                     SIZE 240, 010 OF oDlg PIXEL
		oGetArq:bHelp := {||    ShowHelpCpo(    "cGetArq",;
		{"Arquivo CSV que se importado."+STR_PULA+"Exemplo: C:\teste.csv"},2,{},2)}
		@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlg ACTION (B2PegaArq()) PIXEL
			
		@ 040, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlg ACTION (oDlg:End()) PIXEL
		@ 040, (nJanLarg/2)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"  SIZE 60, 014 OF oDlg ACTION (Processa({|| B2LeArquivo(), oDlg:End()}, "Aguarde...")) PIXEL
	
		ACTIVATE MSDIALOG oDlg CENTERED
	
	Else
		
		Conout("Schedule -> B2LeArquivo")
		Processa({|| B2LeArquivo()}, "Aguarde...")
		
	Endif	

	Z0E->(dbCloseArea())

Return Nil



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} B2LeArquivo
Realiza a leitura do(s) arquivo(s)

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function B2LeArquivo()

	Local nBytes
	Local oFile
	Local cLinha	:= ''
	Local nLinha	:= 1
	Local nCont		:= 0
	Local nCabec	:= 0 
	Local aVirgula	:= {}
	Local nX		:= 1
	Local nM		:= 1
	Local nN		:= 1

	Local nHnd := 0

	Private aCabec	:= {}	// Armazeno o cabeçalho para saber a posição
	Private Itens		:= {}
	
	Private aItem	:= {}	
	Private nErros	:= 0
	Private cMsg	:= ''	
	Private aFiles  := {}	

	Private nPsGrupo   
	Private nPsFil     
	Private nPsForn    
	Private nPsNota    
	Private nPsSerie
	Private nPSSeqErr
	Private nPsMsgRet  	

	If !lSchedule
		aDir(cGetArq,aFiles)		
	Else		
		aDir(cLocArq+cEmpFilial+"*.csv",aFiles)
	Endif

	For nX := 1 to Len(aFiles)
		
		If lSchedule
			cGetArq := cLocArq+aFiles[nX]
		Endif		
		
		If File(cGetArq)
			oFile := FWFileReader():New(cGetArq)
			nBytes := ft_flastrec()
		Else
			MsgStop("Erro ao abrir: "+cGetArq,"Error")
			Return
		Endif
	
		If (oFile:Open())
			
			aCabec	:= {}
			aItens	:= {} 
			aItem	:= {}			
			nLinha	:= 1
			
			ProcRegua(nBytes/30)
			
			conout("Processando arquivo: " + cGetArq)
			
			While (oFile:hasLine())
				
				cLinha := Alltrim(Upper(oFile:GetLine()))

/*				
				cLinha := NoAcento(cLinha)				
				cLinha := StrTran(cLinha,chr(10),"")
				cLinha := StrTran(cLinha,chr(13),"")
*/
				IncProc("Lendo arquivo... Linha " + cValToChar(nLinha))
				
				aVirgula := {}
				aItens	 := {}
				nCont := 0 
				For ni:= 1 To Len(cLinha)
				
					If SubStr(cLinha,ni,1)==";"
					
						aAdd(aVirgula,ni)
						
						If nLinha == 1
						
							CpoPlan := AllTrim(SubStr(cLinha,If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1),aVirgula[Len(aVirgula)]-If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1)))
							
							SX3->(dbSetOrder(2))
							dbSelectArea("Z0E")
							Z0E->(dbSetOrder(2))
							If Z0E->(dbSeek(xFilial("Z0E")+Padr(CpoPlan,TamSX3("Z0E_CPOPLA")[1])))
							
								If SubStr(Z0E->Z0E_CPOSX3,1,3) == 'M0_'
								
									aAdd(aCabec, { 	CpoPlan					,;	// Campo Planilha
													Alltrim(Z0E->Z0E_CPOSX3),;	// Campo SX3
													"C"						,;	// Tipo
													Z0E->Z0E_EMUSO			,;	// Em uso
													0						,;	// Tamanho
													''						,;	// Troca
													Z0E->Z0E_ACAO			})	// Ação
													
								Else
								
									aAdd(aCabec, { 	CpoPlan											,;	// Campo Planilha
													Z0E->Z0E_CPOSX3									,;	// Campo SX3 
													Posicione("SX3",2,Z0E->Z0E_CPOSX3,"X3_TIPO")	,;	// Tipo
													Z0E->Z0E_EMUSO									,;	// Em uso
													Posicione("SX3",2,Z0E->Z0E_CPOSX3,"X3_TAMANHO")	,;	// Tamanho
													''												,;	// Troca
													Z0E->Z0E_ACAO									})	// Ação
													
								Endif
															
							Else
							
								//-----------------------------------------------------------------------------
								// 18/07/2019 - Marcio Martins - EZ4
								// Melhoria aplicada pois mesmo havendo o header no de-para ele não encontrava
								//-----------------------------------------------------------------------------
								lLocaliza := .F.
								dbSelectArea("Z0E")
								Z0E->(dbSetOrder(2))
								Z0E->(dbGoTop())
								While !Z0E->(Eof())
									If CpoPlan $ Z0E->Z0E_CPOPLA 
										lLocaliza := .T.
										aAdd(aCabec, { 	CpoPlan											,;	// Campo Planilha
														Z0E->Z0E_CPOSX3									,;	// Campo SX3 
														Posicione("SX3",2,Z0E->Z0E_CPOSX3,"X3_TIPO")	,;	// Tipo
														Z0E->Z0E_EMUSO									,;	// Em uso
														Posicione("SX3",2,Z0E->Z0E_CPOSX3,"X3_TAMANHO")	,;	// Tamanho
														''												,;	// Troca
														Z0E->Z0E_ACAO									})	// Ação
										
										Exit
									Endif
									Z0E->(dbSkip())
								Enddo
								//-----------------------------------------------------------------------------
								
								If !lLocaliza
									aAdd(aCabec, { 	CpoPlan		,;	// Campo Planilha
													""			,;	// Campo SX3
													"C"			,;	// Tipo
													""			,;	// Em Usp
													0			,;	// Tamanho
													""			,;	// Troca
													""			})	// Ação
								Endif
																				
							Endif				
																							
						Else
						
							aAdd(aItens, AllTrim(SubStr(cLinha,If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1),aVirgula[Len(aVirgula)]-If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1))) )
							
						Endif
						
						nCont++
																
					EndIf
					
				Next ni
				
				If nLinha == 1
					CpoPlan := AllTrim(substr(cLinha,aVirgula[Len(aVirgula)]+1,len(cLinha)))
					cCampo	:= Posicione("Z0E",2,xFilial("Z0E")+Padr(CpoPlan,TamSX3("Z0E_CPOPLA")[1]),"Z0E_CPOSX3")
					aAdd(aCabec, { 	CpoPlan																						,;
					 				cCampo																						,;
					 				Posicione("SX3",2,cCampo,"X3_TIPO")															,;
					 				Posicione("Z0E",2,xFilial("Z0E")+Padr(CpoPlan,TamSX3("Z0E_CPOPLA")[1]),"Z0E_EMUSO")			,;
									Posicione("SX3",2,cCampo,"X3_TAMANHO")														,;
									""																							,;
									Posicione("Z0E",2,xFilial("Z0E")+Padr(CpoPlan,TamSX3("Z0E_CPOPLA")[1]),"Z0E_ACAO")			})
					// Essa coluna irá conter o erro caso tenha
					aAdd(aCabec, { 	"MSGSEQRET"	,;
									""			,;
									""			,;
									""			,;
									""			,;
									""			,;
									""			})												
					aAdd(aCabec, { 	"MSGRETORNO",;
									""			,;
									""			,;
									""			,;
									""			,;
									""			,;
									""			})							

				Else
					aAdd(aItens, AllTrim(substr(cLinha,aVirgula[Len(aVirgula)]+1,len(cLinha))) )
					aAdd(aItens, "" )
					aAdd(aItens, "" )
					aAdd(aItem , aItens)
				Endif
				nLinha++
				ft_fskip()
				
			Enddo
			
		Endif
		
		oFile:Close()
	
		If Len(aCabec) > 0 .and. Len(aItem) > 0 

			For nI := 1 to Len(aItem)
				For nJ := 1 to Len(aCabec)
					If aCabec[nJ,3] == "N" .and. Empty(aCabec[nJ,6])
						// Realizei tratamento para remover possível casa de milhar (.)
						If RAT(",",aItem[nI,nJ]) > RAT(".",aItem[nI,nJ])
							aItem[nI,nJ] := VAL(StrTran(StrTran(aItem[nI,nJ],".",""),",","."))
						Else
							aItem[nI,nJ] := VAL(StrTran(aItem[nI,nJ],",","."))
						Endif
					Endif
				Next nJ
			Next nI

			
			// Posição das colunas que vamos utilizar na chave
			nPsGrupo   := Ascan( aCabec, {|x| Alltrim(x[2])  == "M0_CODIGO" 	} )
			nPsFil     := Ascan( aCabec, {|x| Alltrim(x[2])  == "M0_CODFIL"		} )
			nPsForn    := Ascan( aCabec, {|x| Alltrim(x[2])  == "A2_CGC" 		} )
			nPsNota    := Ascan( aCabec, {|x| Alltrim(x[2])  == "F1_DOC" 		} )
			nPsSerie   := Ascan( aCabec, {|x| Alltrim(x[2])  == "F1_SERIE" 		} )
			nPSSeqErr  := Ascan( aCabec, {|x| Alltrim(x[1])  == "MSGSEQRET"	 	} )
			nPsMsgRet  := Ascan( aCabec, {|x| Alltrim(x[1])  == "MSGRETORNO" 	} )	
			nPsIdenti  := Ascan( aCabec, {|x| Alltrim(x[1])  == "IDENTIFICACAO" } )
			nPsEst     := Ascan( aCabec, {|x| Alltrim(x[2])  == "A2_EST" 		} )
			nPsMun 	   := Ascan( aCabec, {|x| Alltrim(x[2])  == "A2_MUN" 		} )
			nPsProd    := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_COD"   		} )
			nPsItem    := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_ITEM"  		} )
			nPsUM      := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_UM"  		} )
			nPsQtd     := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_QUANT" 		} )
			nPsVuni    := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_VUNIT" 		} )
			nPsTES     := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_TES" 		} )
			nPsPC      := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_PEDIDO"		} )
			nPsItePC   := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_ITEMPC"		} )
			nPsEspec   := Ascan( aCabec, {|x| Alltrim(x[2])  == "F1_ESPECIE"	} )
			nPsVencto  := Ascan( aCabec, {|x| Alltrim(x[2])  == "E2_VENCTO"		} )
			nPsCodRet  := Ascan( aCabec, {|x| Alltrim(x[2])  == "E2_CODRET"		} )
			nPsCriaSC7 := Ascan( aCabec, {|x| Alltrim(x[1])  == "CRIA PO" 		} )	
			nPsCriaSB1 := Ascan( aCabec, {|x| Alltrim(x[1])  == "CRIA ITEM"		} )
			nPsCriaSA2 := Ascan( aCabec, {|x| Alltrim(x[1])  == "CRIA FORNECEDOR"} )			
			nPsNCM 	   := Ascan( aCabec, {|x| Alltrim(x[2])  == "B1_POSIPI"		} )
			nPsDSC     := Ascan( aCabec, {|x| Alltrim(x[2])  == "B1_DESC"		} )
			nPsConta   := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_CONTA" 		} )
			nPsIDProd  := Ascan( aCabec, {|x| Alltrim(x[2])  == "D1_P_NUMFL" 	} )			
			nPsCond    := Ascan( aCabec, {|x| Alltrim(x[2])  == "F1_COND" 		} )
			nPsTpFret  := Ascan( aCabec, {|x| Alltrim(x[2])  == "F1_TPFRETE" 	} )
			
			// 25/07/2019 -> Marcio Martins -> Ajustado: Erro ocorria pois não estava considerando B1_CONTA ou A2_CONTA 
			If nPsConta == 0
				nPsConta := Ascan( aCabec, {|x| Alltrim(x[2])  == "B1_CONTA" } )
				If nPsConta == 0
					nPsConta := Ascan( aCabec, {|x| Alltrim(x[2])  == "A2_CONTA" } )
				Endif
			Endif				
						
			// Isso se deve ao fato de ter nomeclatura diferente nas planilhas de produtos e serviços
			If nPsIdenti == 0
				nPsIdenti := Ascan( aCabec, {|x| Alltrim(x[1])  == "IDENTIFIC." 	} )
			Endif
			
			If nPsIdenti == 0			 	
				MsgAlert("O Campo Identificação está incorreto na planilha, processamento interrompido!")
				return
			Endif
			
			Conout("Schedule -> Processando Criação dos Produtos")
			For nX := 1 to Len(aItem)
				If !Empty(aItem[nX,nPsProd])
					If Alltrim(aItem[nX,nPsCriaSB1]) == "SIM" 
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If !SB1->(dbSeek(xFilial("SB1")+Padr(aItem[nX,nPsProd],TamSX3("B1_COD")[1])))
							//         				Linha	Produto		 		Descrição		  	NCM					Conta Contábil		uNID.mEDIDA		 Cabec
							Processa({|| B2CriaProd(nX, 	aItem[nX,nPsProd],	aItem[nX,nPsDSC],	aItem[nX,nPsNCM],	aItem[nX,nPsConta], aItem[nX,nPsUM], aCabec)}, "Criando Produto... " + Alltrim(aItem[nX,nPsProd]) )
						Endif
					Endif
				Endif
			Next nX
			
			Conout("Schedule -> Processando importação de fornecedores")
			Processa({|| B2ImpFor(aCabec,aItem)}, "Lendo fornecedores...aguarde...")
			
			Conout("Schedule -> Processando importação de notas ")
			Processa({|| B2ImpNfs(aCabec,aItem)}, "Lendo notas...aguarde...")
			
			If !lForcaSchd
			
				If !Empty(cMsg)
					Aviso( "Importação" ,cMsg, {"OK"}, 3,"Log do Processamento")
				Endif
							
			Endif
			
		Endif
		
		//--------------------------------------------------------------------------------
		// Geração do arquivo de retorno, tendo como base principal os dados de origem
		//--------------------------------------------------------------------------------
		If !lSchedule
			
			// Renomeio o arquivo original para .imp e mantenho na mesma pasta aonde o usuário buscou
			fRename(cGetArq,SubStr(cGetArq,1,rat(".",cGetArq))+"imp")
			Conout("Usuario -> Renomeado arquivo na mesma pasta")
			
			// Cria na mesma pasta aonde o usuário buscou
			nHnd := FCreate(SubStr(cGetArq,1,rat(".",cGetArq))+"ret")
			conout("Gerando arquivo retorno: " + SubStr(cGetArq,1,rat(".",cGetArq))+"ret")			
			
		Else
		
			// Copio o arquivo para a pasta de importados
			__CopyFile(cGetArq,cLocImp+aFiles[nX])
			conout("Movimento arquivo arquivo para pasta " + cLocImp+aFiles[nX])
			
			// Removo o arquivo da pasta de entrada, pois já movimentei o mesmo para importados
			FErase(cGetArq)	
			conout("Removendo arquivo: " + cGetArq)
			
			
			nHnd := FCreate(SubStr(cLocRet+aFiles[nX],1,rat(".",cLocRet+aFiles[nX]))+"ret")	// Crio o arquivo de retorno na pasta especifica
			conout("Gerando arquivo retorno: " + cLocRet+aFiles[nX])
			
		Endif
		
		If nHnd < 0
		
			msgalert("O arquivo de Retorno não pode ser gerado!")
			conout("O arquivo de Retorno não pode ser gerado!")
			
		Else
			
			cTexto := ""
			For nM := 1 to Len(aCabec)
				cTexto += aCabec[nM,1]+";"
			Next nM
			cTexto := SubStr(cTexto,1,Len(cTexto)-1) + Chr(13) + Chr(10)			
			FWrite(nHnd,cTexto)

			cTexto := ""
			For nM := 1 to Len(aItem)
				cTexto := ""
				For nN := 1 to Len(aItem[nM])
					If Valtype(aItem[nM,nN])=="N"
						cTexto += cValToChar(aItem[nM,nN])+";"
					ElseIf Valtype(aItem[nM,nN])=="D"
						cTexto += DTOC(aItem[nM,nN])+";"
					Else
						cTexto += aItem[nM,nN]+";"
					Endif
				Next nN
				cTexto := SubStr(cTexto,1,Len(cTexto)-1) + Chr(13) + Chr(10)
				FWrite(nHnd,cTexto)
			Next nM
			FClose(nHnd)
			
			conout("Arquivo gerado com sucesso!")
			
		Endif
		//-------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------		
		
	Next nX
	
	Conout("Schedule -> Processamento finalizado!")
	If lForcaSchd
		cMsgFim := ""
		If Len(aFiles) == 0
			cMsgFim := "Não Foram Encontrados arquivos na pasta" + CRLF
		Endif
		cMsgFim += "Processamento finalizado!" 
		MsgAlert(cMsgFim)
	Endif	
	
Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} B2ImpNfs
Realiza a importação das notas de entrada

@author    Marcio Martins Pereira
@version   1.xx
@since     03/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function B2ImpNfs(aCabec,aItem)

	Local nY  		:= 1
	Local nPs 		:= 0
	Local cCNPJ		:= ''
	Local cDoc		:= ''
	Local nOpcSA2	:= 3	// Padrão Inclusão
	Local aCabSC7	:= {}
	Local aIteSC7	:= {}
	Local aLinAux	:= {}
	Local aLinAsc7	:= {}
	Local aRetorno	:= {}
	Local cCodPC	:= ""
	Local lSC7Exist := .F.
	Local lMata103	:= GetNewPar('EZ_MATA103',.T.)	// Se .F. gera pré-nota / Se .T. gera Documento de Entrada (default) 
	//Local cItemNF   := StrZero(0,TamSX3("D1_ITEM")[1])

	Private aCabSF1 	:= {}
	Private aIteSD1	:= {}
	
	Private nX  	   	:= 1	
	Private aSFT		:= {}
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	Private cTpFrete	:= ""
	
	ProcRegua(Len(aItem))	

	If nPsForn > 0	
		cDoc    := StrZero(Val(aItem[1,nPsNota]),TAMSX3("F1_DOC")[1])
		cCNPJ   := StrTran(StrTran(StrTran(aItem[1,nPsForn],".",""),"/",""),"-","")
	Endif
	
	cCriaPO := Upper(aItem[1,nPsCriaSC7])
	
	For nX := 1 to Len(aItem)		
	
		If !Empty(aItem[nX,nPsNota])

			cDoc   := StrZero(Val(aItem[nX,nPsNota]),TAMSX3("F1_DOC")[1])
			cSerie := aItem[nX,nPsSerie]
			cCNPJ  := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")				

			If Alltrim(aItem[nX,nPsGrupo])+Alltrim(aItem[nX,nPsFil]) == cEmpFilial	//Alltrim(SM0->M0_CODIGO)+Alltrim(SM0->M0_CODFIL)
				
				cIdent := SubStr(aItem[nX,nPsIdenti],1,1) 
				
				If cIdent == "1"
					dbSelectArea("SA1")
					SA1->(dbSetOrder(3))
					lRetSeek := SA1->(dbSeek(xFilial('SA1')+cCNPJ))				
				Else
					dbSelectArea("SA2")
					SA2->(dbSetOrder(3))
					lRetSeek := SA2->(dbSeek(xFilial('SA2')+cCNPJ))				
				Endif
				
				If lRetSeek
			
					If Val(cDoc) == Val(aItem[nX,nPsNota])
						
						If Len(aCabSF1) == 0
							
							IncProc("Processando nota nº " + cDoc)
							Conout("Processando nota nº " + cDoc)
							
							dVencto := CTOD(aItem[nX,nPsVencto])
							cCodRet := aItem[nX,nPsCodRet]
							If nPsIDProd > 0 
								cIDProd := aItem[nX,nPsIDProd]
							Endif
							
							cCondPagto := aItem[nX,nPsCond]
							cTpFrete   := aItem[nX,nPsTpFret]
							
							If cIdent == "1"
							
								aAdd(aCabSF1,{"F1_FORNECE"	, SA1->A1_COD		,	Nil})
								aAdd(aCabSF1,{"F1_LOJA"		, SA1->A1_LOJA		,	Nil})
								aAdd(aCabSF1,{'F1_EST'		, SA1->A1_EST		,	Nil})
				   				aAdd(aCabSF1,{'F1_TIPO'		, 'D'				,	Nil})			    
							    aAdd(aCabSF1,{'F1_FORMUL'	, 'N'				,	Nil})
							    aAdd(aCabSF1,{"E1_NATUREZ"  , SA1->A1_NATUREZ	,	Nil})
							    aAdd(aCabSF1,{"F1_COND"  	, cCondPagto		,	Nil})
							    
							Else
							
								aAdd(aCabSF1,{"F1_FORNECE"	, SA2->A2_COD		,	Nil})
								aAdd(aCabSF1,{"F1_LOJA"		, SA2->A2_LOJA		,	Nil})
								aAdd(aCabSF1,{'F1_EST'		, SA2->A2_EST		,	Nil})
				   				aAdd(aCabSF1,{'F1_TIPO'		, 'N'				,	Nil})			    
							    aAdd(aCabSF1,{'F1_FORMUL'	, 'N'				,	Nil})
							    aAdd(aCabSF1,{"E2_NATUREZ"  , SA2->A2_NATUREZ	,	Nil})
							    aAdd(aCabSF1,{"F1_COND"  	, cCondPagto		,	Nil})
							    
							    lSC7Exist := .F.
							    
							    If cCriaPO == "SIM"
								    If Empty(aItem[nX,nPsPC])
										lCont := .T.
										While lCont 
											cCodPC := GetSXENum("SC7","C7_NUM")
										    dbSelectArea("SC7")
										    SC7->(dbSetOrder(1))
										    If SC7->(dbSeek(xFilial("SC7")+cCodPC))
												ConfirmSX8()
											Else
												lCont := .F. 
											Endif
										enddo 						
								    Else								    
									    dbSelectArea("SC7")
									    SC7->(dbSetOrder(1))
									    If SC7->(dbSeek(xFilial("SC7")+aItem[nX,nPsPC]))
									    	lSC7Exist := .T.
									    	cCodPC := SC7->C7_NUM
									    Else
									    	// Não existe, logo, forço o P.O. que está  
									    	// vindo para dar erro na geração da nota.
									    	lSC7Exist := .T.
									    	cCodPC := aItem[nX,nPsPC]	
									    Endif
								    Endif
							    Endif
							    
							    If cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC) 
							    	aAdd(aCabSC7,{"C7_NUM"		, cCodPC		})
								    aAdd(aCabSC7,{"C7_EMISSAO"	, dDatabase		})
									aAdd(aCabSC7,{"C7_FORNECE"	, SA2->A2_COD	})
									aAdd(aCabSC7,{"C7_LOJA"		, SA2->A2_LOJA	})								
					   				aAdd(aCabSC7,{'C7_CONTATO'	, "AUTO"		})			    
								    aAdd(aCabSC7,{'C7_FILENT'	, cFilAnt		})
							    Endif
							    
							Endif
							
							For nY := 1 to Len(aCabec)
								If aCabec[nY,4] == "1"
									If Substr(aCabec[nY,2],1,3) == "F1_"
										If aCabec[nY,3] == "D"
											cConteudo := CTOD(aItem[nX,nY])
										Else
											If Alltrim(aCabec[nY,2]) == "F1_TPFRETE"
												// Não faço nada, apenas vou gravar por RecLock
												// a pedido da Aline Sonego 
											ElseIf Alltrim(aCabec[nY,2]) == "F1_COND"
											 	// Já Tratei no cabeçalho
											ElseIf Alltrim(aCabec[nY,2]) == "F1_ESPECIE" 
												//cConteudo  := If(Alltrim(aItem[nX,nPsEspec])=="NFS","NFS","SPED")
												cConteudo  := aItem[nX,nPsEspec]
											ElseIf Alltrim(aCabec[nY,2]) == "F1_DOC"
												cConteudo := StrZero(Val(aItem[nX,nY]),TamSX3("F1_DOC")[1])
											Else
												cConteudo := aItem[nX,nY]
											Endif								
										Endif
										If !Alltrim(aCabec[nY,2]) == "F1_TPFRETE"
											aAdd( aCabSF1, { aCabec[nY,2] , cConteudo , Nil } )
										Endif

										If cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
											If Alltrim(aCabec[nY,2]) == "F1_COND"
												aAdd(aCabSC7,{'C7_COND'	, cCondPagto	})
											Endif
										Endif
										
									Endif
								Endif
							Next nY
							aCabSF1 := FWVetByDic(aCabSF1, "SF1")
							If cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
								aCabSC7 := FWVetByDic(aCabSC7, "SC7")
							Endif
							
						Endif				
						
						aLinAux  := {}
						aLinASC7 := {}
						aSFTItem := {}
						For nY := 1 to Len(aCabec)
							dbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(xFilial("SB1")+aItem[nX,nPsProd]))					
							If aCabec[nY,4] == "1"
								If Substr(aCabec[nY,2],1,3) == "FT_"
									
									aAdd( aSFTItem , { aCabec[nY,2] , aItem[nX,nPsProd], StrZero(Val(aItem[nX,nPsItem]),TamSX3("FT_ITEM")[1]) , aItem[nX,nY] } )
								Endif
								If nY == 1
								    aAdd(aLinAux,{"D1_TIPO"		, 'N'				,Nil})
								    aAdd(aLinAux,{"D1_LOCAL"	, SB1->B1_LOCPAD	,Nil})				    
								Endif
								If Substr(aCabec[nY,2],1,3) == "D1_"
									If aCabec[nY,3] == "D"
										cConteudo := CTOD(aItem[nX,nY])										
									Else
										If Alltrim(aCabec[nY,2]) == "D1_COD"
											cConteudo := aItem[nX,nY]
										ElseIf Alltrim(aCabec[nY,2]) == "D1_DOC"
											cConteudo := StrZero(Val(aItem[nX,nY]),TamSX3("D1_DOC")[1])
										ElseIf Alltrim(aCabec[nY,2]) == "D1_UM"
											cConteudo := Posicione("SB1",1,xFilial("SB1")+aItem[nX,nPsProd],"B1_UM")
										ElseIf Alltrim(aCabec[nY,2]) == "D1_TOTAL"
											cConteudo := aItem[nX,nPsQtd]*aItem[nX,nPsVuni]		
										ElseIf Alltrim(aCabec[nY,2]) == "D1_P_NUMFL"
											cConteudo := cIDProd
										Else									
											cConteudo := aItem[nX,nY]
										Endif
									Endif
									If cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
										If Alltrim(aCabec[nY,2]) == "D1_COD"										
											AAdd( aLinASC7, { "C7_PRODUTO" , cConteudo , Nil } )
										ElseIf Alltrim(aCabec[nY,2]) == "D1_ITEM"										
											AAdd( aLinASC7, { "C7_ITEM" , StrZero(Val(aItem[nX,nPsItem]),TamSX3("C7_ITEM")[1]) , Nil } )											
										ElseIf Alltrim(aCabec[nY,2]) == "D1_QUANT"
											AAdd( aLinASC7, { "C7_QUANT" , cConteudo , Nil } )
										ElseIf Alltrim(aCabec[nY,2]) == "D1_VUNIT"
											AAdd( aLinASC7, { "C7_PRECO" , cConteudo , Nil } )
										ElseIf Alltrim(aCabec[nY,2]) == "D1_TOTAL"
											AAdd( aLinASC7, { "C7_TOTAL" , cConteudo , Nil } )
										ElseIf Alltrim(aCabec[nY,2]) == "D1_TES"
											AAdd( aLinASC7, { "C7_TES" , cConteudo , Nil } )
										Endif
									Endif
									If Alltrim(aCabec[nY,2]) == "D1_ITEM"										
										AAdd( aLinAux, { aCabec[nY,2] , StrZero(Val(cConteudo),TamSX3("C7_ITEM")[1]) , Nil } )
									ElseIf Alltrim(aCabec[nY,2]) == "D1_ITEMPC"
										If cCriaPO == "SIM" .And. lSC7Exist
											AAdd( aLinAux, { "D1_ITEMPC" , StrZero(Val(aItem[nX,nPsItePC]),TamSX3("D1_ITEMPC")[1]) , Nil } )
										ElseIf cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
											AAdd( aLinAux, { "D1_ITEMPC" , "" , Nil } )
										Endif
									ElseIf Alltrim(aCabec[nY,2]) == "D1_PEDIDO"
										If cCriaPO == "SIM" .And. lSC7Exist
											AAdd( aLinAux, { "D1_PEDIDO" , StrZero(Val(aItem[nX,nPsPC]),TamSX3("D1_PEDIDO")[1]) , Nil } )
										ElseIf cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
											AAdd( aLinAux, { "D1_PEDIDO" , "" , Nil } )
										Endif
									ElseIf Alltrim(aCabec[nY,2]) == "D1_CONTA"
										AAdd( aLinAux, { "D1_CONTA" , aItem[nX,nPsConta] , Nil } )
									eLSE
										AAdd( aLinAux, { aCabec[nY,2] , cConteudo , Nil } )
									Endif							
								Endif
							Endif
						Next nY
						aadd(aIteSD1,FWVetByDic(aLinAux,"SD1",.F.,1))
						aadd(aSFT,FWVetByDic(aSFTItem,"SD1",.F.,1))
						If cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
							aadd(aIteSC7,FWVetByDic(aLinASC7,"SC7",.F.,1))
						Endif
						
					Endif
				
				Endif
				
				cGrpCrtl := aItem[nX,nPsGrupo]
				cFilCrtl := aItem[nX,nPsFil]
				cCNPJ 	 := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")
				cDoc  	 := StrZero(Val(aItem[nX,nPsNota]),TAMSX3("F1_DOC")[1])
				cSerie   := aItem[nX,nPsSerie]
				cCriaPO  := Upper(aItem[nX,nPsCriaSC7])
				lSC7OK	 := .F.
				
				If ( nX+1 > Len(aItem) )  .Or. ( Val(cDoc) <> Val(aItem[nX+1,nPsNota]) )
					
					If cCriaPO == "SIM" .And. !lSC7Exist .And. !Empty(cCodPC)
						
						nPsNum := Ascan( aCabSC7, {|x| Alltrim(x[1]) == "C7_NUM" } )
						
						If nPsNum > 0 
						
							dbSelectArea("SC7")
							SC7->(dbSetOrder(1))
							If !SC7->(dbSeek(xFilial("SC7")+aCabSC7[nPsNum,2]))
							
								If Len(aCabSC7) > 0 .And. Len(aIteSc7) > 0 
									
									lMsErroAuto := .F.
									
									//aCabSC7 := FWVetByDic(aCabSC7, "SC7")
									
									Processa({|| MATA120(1,aCabSC7,aIteSC7,3) }, "Processando P.O. ...aguarde")
									
									If lMsErroAuto 
										lSC7OK	 := .F.
										MostraErro()
										cMsgPlan := ""
										nErros++
									    aErro := GetAutoGRLog()
									    cMsg += "Erro ao incluir o documento: " + cDoc +ENTER
									    For i := 1 To Len(aErro)
										    cMsg += aErro[i] + Chr(13) + Chr(10)
										    cMsgPlan += StrTran(StrTran(StrTran(aErro[i],";"," "),chr(10)," / "),chr(13)," / ")
									    Next i

									Else
										lSC7OK	 := .T.
										ConfirmSX8()

										For nMX := 1 to Len(aIteSC7)
											nPedSD1 := Ascan( aIteSD1[nMX], {|x| Alltrim(x[1])  == "D1_PEDIDO" 	} )
											nItmSD1 := Ascan( aIteSD1[nMX], {|x| Alltrim(x[1])  == "D1_ITEMPC" 	} )
											If nPedSD1 > 0 .and. nItmSD1 > 0
												aIteSD1[nMX,nPedSD1,2] := SC7->C7_NUM
												aIteSD1[nMX,nItmSD1,2] := aIteSC7[nMX,1,2]
											Endif
										Next nMX 
																				
									Endif
									
								Endif
							Else							
								lMsErroAuto := .T.							
							Endif
						Endif
																		
					Endif
					
					If Len(aCabSF1) > 0 .And. Len(aIteSD1) > 0
						
						dbSelectArea("SF1")
						SF1->(dbSetOrder(1))	// F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
						If !SF1->(dbSeek(xFilial("SF1")+Padr(cDoc,TamSX3("F1_DOC")[1])+Padr(cSerie,TamSX3("F1_SERIE")[1])+SA2->(A2_COD+A2_LOJA)))
							
							lMsErroAuto := .F.
							
							aIteSD1 := FWVetByDic(aIteSD1,"SD1",.T.,1)
							
							nPsCndpg := Ascan( aCabSF1 , {|x| Alltrim(x[1])  == "F1_COND" 	} )
							nPsForne := Ascan( aCabSF1 , {|x| Alltrim(x[1])  == "F1_FORNECE"} )
							nPsLoja  := Ascan( aCabSF1 , {|x| Alltrim(x[1])  == "F1_LOJA" 	} )

							dbSelectArea("SA2")
							SA2->(dbSetOrder(1))
							SA2->(dbSeek(xFilial("SA2")+aCabSF1[nPsForne,2]+aCabSF1[nPsLoja,2]))

							dbSelectArea("SED")
							SED->(dbSetOrder(1))
							SED->(dbSeek(xFilial("SED")+SA2->A2_NATUREZ))														
							
							dbSelectArea("SE4")
							SE4->(dbSetOrder(1))
							SE4->(dbSeek(xFilial("SE4")+aCabSF1[nPsCndpg,2]))							
							
							
							//----------------------------------------------------------------------------------
							// Márcio Martins - 10/09/2019
							// Implementado ponto de entrada para trocar o armazém conforme a Empresa e TES
							//----------------------------------------------------------------------------------
							If ExistBlock("PEGTGEN47")
								For nG := 1 To Len(aIteSD1)
									nPsSD1TES := Ascan( aIteSD1[nG], {|x| Alltrim(x[1]) == "D1_TES" 	} )
									nPsSD1LOC := Ascan( aIteSD1[nG], {|x| Alltrim(x[1]) == "D1_LOCAL" 	} )
									cSD1TES   := aIteSD1[nG,nPsSD1TES,2]						
									cRetLoc   := ExecBlock("PEGTGEN47", .F., .F., { cSD1TES } )
									If !Empty(cRetLoc)
									   aIteSD1[nG,nPsSD1LOC,2] := cRetLoc
									Endif
								Next nG
							Endif
						   // ----------------------------------------------------------------------------------
							
							If lMata103								
								Processa({|| MSExecAuto({|x, y, z| Mata103(x, y, z)}, aCabSF1, aIteSD1, 3) }, "Processando nota " + cDoc)
							Else								
								Processa({|| MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabSF1, aIteSD1, 3,,) }, "Processando nota " + cDoc)								
							Endif
							
							If lMSErroAuto
								cMsgPlan := ""
								nErros++
							    aErro := GetAutoGRLog()
							    cMsg += "Erro ao incluir o documento: " + cDoc +ENTER
							    For i := 1 To Len(aErro)
								    cMsg += aErro[i] + Chr(13) + Chr(10)
								    cMsgPlan += StrTran(StrTran(StrTran(aErro[i],";"," "),chr(10)," / "),chr(13)," / ")
							    Next i

								//lMsErroAuto := .F.								
								//MATA120(1,aCabSC7,aIteSC7,5)	// Excluindo o P.O. caso dê erro na nota
							    
							Else
								RecLock("SF1",.F.)
								SF1->F1_TPFRETE := cTpFrete
								MsUnlock()								
								If SE2->E2_NUM == SF1->F1_DOC
									nRec := 0 
									cAliasTRB	:= GetNextAlias()
									cSQL := " SELECT R_E_C_N_O_ RECSE2 FROM " + RetSqlName("SE2") + " " 
									cSQL += " WHERE E2_NUM = '" + SF1->F1_DOC + "' AND E2_FORNECE = '" + SF1->F1_FORNECE +"' "
									DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)
									If !(cAliasTRB)->(Eof())
										nRec := (cAliasTRB)->RECSE2 
									Endif
									(cAliasTRB)->(dbCloseArea())
									
									If nRec > 0 
										SE2->(dbGoTo(nRec))
										RecLock("SE2",.F.)
										SE2->E2_VENCTO  := dVencto
										SE2->E2_VENCORI := dVencto
										SE2->E2_VENCREA := DataValida(dVencto,.T.)
										If !Empty(SE2->E2_CODRET)	// Se estiver preenchido é porque tem IR
											SE2->E2_CODRET := cCodRet
										Endif
										If nPsIDProd > 0 
											SE2->E2_P_NUMFL := cIDProd
										Endif
										MsUnlock()
									Endif

									If nPsCodRet > 0 
									
										nRec := 0
										cAliasTRB	:= GetNextAlias()
										cSQL := " SELECT R_E_C_N_O_ RECSE2 FROM " + RetSqlName("SE2") + " " 
										cSQL += " WHERE E2_FORNECE = 'UNIAO' AND E2_NUM = '" + SF1->F1_DOC + "' AND E2_TIPO = 'TX' "
										DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)
										While !(cAliasTRB)->(Eof())
											SE2->(dbGoTo((cAliasTRB)->RECSE2))
											RecLock("SE2",.F.)
											SE2->E2_CODRET := cCodRet
											MsUnlock()
											(cAliasTRB)->(dbSkip())
										Enddo
										(cAliasTRB)->(dbCloseArea())
									
									Endif 
									
								Endif								
								/*
								//-> TRATAMENTO PARA para SF3 -> MARCAR PARA NAO REPROCESSAR
								If SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
									RecLock("SF3",.F.)
									SF3->F3_REPROC := 'N'
									MsUnlock()
								Endif
								*/
								//-> TRATAMENTO PARA para SF3 -> MARCAR PARA NAO REPROCESSAR
								aAreaSF3 := GetArea()
								//-> TRATAMENTO PARA para SF3 -> MARCAR PARA NAO REPROCESSAR
								SF3->(dbSetOrder(4))
								If SF3->(dbSeek(xFilial("SF3")+SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)))
									While !SF3->(Eof()) .and. xFilial("SF3")+SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE) == SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) 
										RecLock("SF3",.F.)
										SF3->F3_REPROC := 'N'
										MsUnlock()
										SF3->(dbSkip())
									Enddo
								Endif
								RestArea(aAreaSF3)
								
								//-> TRATAMENTO PARA para SFT -> CORREÇÃO DOS ITENS DO LIVRO FISCAL
								For nZ := 1 to Len(aSFT)
									/*	Posições do array
										1. Campo a ser alterado na SFT
										2. Produto a ser considerado na chave de pesquisa
										3. Item a ser considerado na chave de pesquisa
										4. Valor a ser considerado no RecLock() 									
									*/
									For nZZ := 1 to Len(aSFT[nZ])
										dbSelectArea("SFT")
										SFT->(dbSetOrder(1))	// FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
										If SFT->(dbSeek(xFilial("SFT")+"E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+Padr(aSFT[nZ,nZZ,3],TamSX3("FT_ITEM")[1])+Padr(aSFT[nZ,nZZ,2],TamSX3("FT_PRODUTO")[1])))
											RecLock("SFT",.F.)
											SFT->&(aSFT[nZ,nZZ,1]) := aSFT[nZ,nZZ,4] 
											MsUnlock()
										Endif
									Next nZZ
								Next nZ

								cMsg += If(lMata103,"Nota fiscal: ","Pré-nota: ") + cDoc + " incluida com sucesso!"+ENTER
								
							Endif
							
							aCabSC7 := {}
							aIteSC7 := {}

							aAdd(aRetorno , { cGrpCrtl , cFilCrtl , cCNPJ , cDoc , If(lMSErroAuto,cMsgPlan,"SUCESSO") } )
						
						Else
						
							aAdd(aRetorno , { cGrpCrtl , cFilCrtl , cCNPJ , cDoc , If(lMata103,"Nota fiscal: ","Pré-nota: ") + cDoc + " já incluida para esse Fornecedor" } )
							cMsg += If(lMata103,"Nota fiscal: ","Pré-nota: ") + cDoc + " já incluida anteriormente para esse Fornecedor"+ENTER
							
						Endif
						
					Endif
					
					aCabSF1 := {}
					aIteSD1 := {}
					//cItemNF := StrZero(0,TamSX3("D1_ITEM")[1])			
								
				Endif
			
			Else
			
				If Ascan( aRetorno, {|x| Alltrim(x[3])  == cCNPJ } ) == 0
					aAdd(aRetorno , { aItem[nX,nPsGrupo] , aItem[nX,nPsFil] , cCNPJ , cDoc , "CNPJ: " + cCNPJ+ " - Nota: " + cDoc + " -> Registro não pertence a essa Empresa/Filial " + Alltrim(SM0->M0_CODIGO)+"/"+Alltrim(SM0->M0_CODFIL)} )
					cMsg += "CNPJ: " + cCNPJ+ " - Nota: " + cDoc + " -> Registro não pertence a essa Empresa/Filial " + Alltrim(SM0->M0_CODIGO)+"/"+Alltrim(SM0->M0_CODFIL) + ENTER
				Endif
			
			Endif
			
		Endif
					
	Next nX
	
	// Tratamento do retorno 
	For nM := 1 to Len(aRetorno)
		For nN := 1 to Len(aItem)
			cCNPJStr := StrTran(StrTran(StrTran(aItem[nN,nPsForn],".",""),"/",""),"-","")
			If Alltrim(aItem[nN,nPsGrupo])+Alltrim(aItem[nN,nPsFil])+Alltrim(cCNPJStr)+Alltrim(aItem[nN,nPsNota]) == Alltrim(aRetorno[nM,1])+Alltrim(aRetorno[nM,2])+Alltrim(aRetorno[nM,3])+Alltrim(aRetorno[nM,4])
				aItem[nN,nPSSeqErr] := If(aRetorno[nM,5]=="SUCESSO","0","1")
				aItem[nN,nPsMsgRet] := aRetorno[nM,5]				
			Endif
		Next nN
	Next nM

Return


Static Function B2CriaProd(nLinha, cProd, cDescric, cNCM, cConta, cUm, aCab)

	Local nOpcao := 3	
	Local nY
	Local nX
	Local aVetor := {}
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.	

	//-------------------------------------------------------------------
	// Uso o armazém que estiver disponível  
	//-------------------------------------------------------------------
	dbSelectArea("NNR")
	NNR->(dbSetOrder(1))
	NNR->(dbGoTop())
	//-------------------------------------------------------------------

	aAdd( aVetor , {"B1_COD"        ,cProd									    				,NIL})
	aAdd( aVetor , {"B1_DESC"       ,Padr(cDescric,TAMSX3("B1_DESC")[1]) 						,NIL})
	aAdd( aVetor , {"B1_LOCPAD"  	,NNR->NNR_CODIGO											,Nil})
	aAdd( aVetor , {"B1_PICM"    	,0               											,Nil})
	aAdd( aVetor , {"B1_IPI"     	,0               											,Nil})
	aAdd( aVetor , {"B1_CONTRAT" 	,"N"             											,Nil})
	aAdd( aVetor , {"B1_LOCALIZ" 	,"N"             											,Nil})
	aAdd( aVetor , {"B1_POSIPI" 	,PADR(cNCM,TAMSX3("B1_POSIPI")[1]) 							,Nil})
	aAdd( aVetor , {"B1_CONTA" 		,cConta	            										,Nil})
	aAdd( aVetor , {"B1_GARANT"		,"2"			 											,Nil})
	aAdd( aVetor , {"B1_INSS"		,"S"			 											,Nil})
	aAdd( aVetor , {"B1_COFINS"		,"1"			 											,Nil})
	aAdd( aVetor , {"B1_PIS"		,"1"			 											,Nil})
	aAdd( aVetor , {"B1_CSLL"		,"1"			 											,Nil})
	aAdd( aVetor , {"B1_RETOPER"	,"2"			 											,Nil})
	aAdd( aVetor , {"B1_UM"			,cUm			 											,Nil})
	aAdd( aVetor , {"B1_IRRF"		,"S"			 											,Nil})
	
	For nY := 1 to Len(aCab)
		If Substr(aCab[nY,2],1,3) == "B1_"
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(Padr(aCab[nY,2],10)))
				nPs := Ascan( aVetor, {|x| Alltrim(x[1])  == Alltrim(aCab[nY,2]) } )
				If nPS == 0
					aAdd( aVetor , { Alltrim(aCab[nY,2]) , aItem[nLinha,nY] , Nil } )
				Endif
			Endif
		Endif
	Next nY

	//--< Inicializa variáveis para uso na rotina automática >------------------------------
	lMSErroAuto	:= .F.
	lMSHelpAuto	:= .T.
    
    aVetor := FwVetByDic(aVetor,"SB1")
    
	MSExecAuto({|x,y| Mata010(x,y)},aVetor,nOpcao)
	
	If lMSErroAuto
		cMsgPlan := ""
		nErros++
	    aErro := GetAutoGRLog()
	    cMsg += "Erro ao incluir o produto: " +ENTER
	    For i := 1 To Len(aErro)
		    cMsg += aErro[i] + Chr(13) + Chr(10)
		    cMsgPlan += StrTran(StrTran(StrTran(aErro[i],";"," "),chr(10)," / "),chr(13)," / ")
	    Next i
							    	    
	Endif 

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} B2ImpFor
Realiza a importação dos Fornecedores

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function B2ImpFor(aCabec,aItem)

	Local nX  := 1
	Local nY  := 1
	Local nPs := 0
	Local aFornece   := {}
	Local aRetorno	 := {}
	Local cCNPJ		 := ''
	Local nOpcSA2	 := 3	// Padrão Inclusão
	Local nPsCriaSA2 := Ascan( aCabec, {|x| Alltrim(x[1])  == "CRIA FORNECEDOR" } )	
	
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
	ProcRegua(Len(aItem))
	
	For nX := 1 to Len(aItem)
		
		cDoc  := aItem[nX,nPsNota]
		cCNPJ := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")				

		If Alltrim(aItem[nX,nPsGrupo])+Alltrim(aItem[nX,nPsFil]) == cEmpFilial	//Alltrim(SM0->M0_CODIGO)+Alltrim(SM0->M0_CODFIL)
		
			If Alltrim(Upper(aItem[nX,nPsCriaSA2])) == "SIM"
					
				If Ascan( aRetorno, {|x| Alltrim(x[3])  == cCNPJ } ) == 0 

					IncProc("Processando CNPJ " + aItem[nX,nPsForn])
					Conout("Processando CNPJ " + aItem[nX,nPsForn])
							
					aFornece := {}
					nOpcSA2 := 3
					
					cIdent := SubStr(aItem[nX,nPsIdenti],1,1) 

					If cIdent == "2" 
					
						dbSelectArea("SA2")
						SA2->(dbSetOrder(3))
						If SA2->(dbSeek(xFilial("SA2")+cCNPJ))
							nOpcSA2 := 4
							cCodFor := SA2->A2_COD
							CCodLoj := SA2->A2_LOJA
						Else
							// Criado pois estavamos tendo problema de códigos que 
							// não estavam confirmados 
							lCont := .T.
							While lCont 
								cCodFor := GetSXENum("SA2","A2_COD")
								CCodLoj := "01"
								dbSelectArea("SA2")
								SA2->(dbSetOrder(1))
								If SA2->(dbSeek(xFilial("SA2")+cCodFor+CCodLoj))
									ConfirmSX8()
								Else
									lCont := .F. 
								Endif
							enddo 						
						Endif
						
						For nY := 1 to Len(aCabec)
							If aCabec[nY,4] == "1"
								If Substr(aCabec[nY,2],1,3) == "A2_"
									If nOpcSA2 == 3
										If Alltrim(aCabec[nY,2]) == "A2_COD"
											cConteudo := cCodFor
										ElseIf Alltrim(aCabec[nY,2]) == "A2_LOJA"
											cConteudo := cCodLoj				
										ElseIf Alltrim(aCabec[nY,2]) == "A2_NREDUZ"
											If !Empty(aItem[nX,nY])
												cConteudo := SubStr(aItem[nX,nY],1,TamSX3("A2_NREDUZ")[1])
											Else
												nPsNome  := Ascan( aCabec, {|x| Alltrim(x[2])  == "A2_NOME" } )
												cConteudo := SubStr(aItem[nX,nPsNome],1,TamSX3("A2_NREDUZ")[1])
											Endif																			
										ElseIf Alltrim(aCabec[nY,2]) == "A2_CGC"
											cConteudo := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")
										ElseIf Alltrim(aCabec[nY,2]) $ "A2_INSCR|A2_INSCRM"	// Confirmar com cliente
											cConteudo := If(Empty(aItem[nX,nY]),"ISENTO",aItem[nX,nY])
										ElseIf Alltrim(aCabec[nY,2]) == "A2_COD_MUN"
											CC2->(dbSetOrder(4))
											If CC2->(dbSeek(xFilial("CC2")+aItem[nX,nPsEst]+Padr(aItem[nX,nPsMun],TamSX3("A2_MUN")[1])))
												cConteudo := CC2->CC2_CODMUN
											Endif
											CC2->(dbSetOrder(1))							
										ElseIf aCabec[nY,3] == "C"
											cConteudo := SubStr(aItem[nX,nY],1,aCabec[nY,5])
										ElseIf aCabec[nY,3] == "D"
											cConteudo := CTOD(aItem[nX,nY])
										ElseIf aCabec[nY,3] == "N"
											cConteudo := Val(aItem[nX,nY])
										Endif
										AAdd( aFornece, { aCabec[nY,2] , cConteudo , Nil } )
									Else
										If aCabec[nY,7] == "1"	// Desconsidero a ação 1 que é inclusão/alteração
											If Alltrim(aCabec[nY,2]) $ "A2_COD"
												cConteudo := SA2->A2_COD
											ElseIf Alltrim(aCabec[nY,2]) $ "A2_LOJA"	// Confirmar com cliente
												cConteudo := SA2->A2_LOJA
											ElseIf Alltrim(aCabec[nY,2]) == "A2_INSCR"	// Confirmar com cliente
												If "ISENT" $ SA2->A2_INSCR
													cConteudo := If(Empty(aItem[nX,nY]),"ISENTO",aItem[nX,nY])
												Else
													cConteudo := SA2->A2_INSCR
												Endif
											ElseIf Alltrim(aCabec[nY,2]) == "A2_INSCRM"	// Confirmar com cliente
												If "ISENT" $ SA2->A2_INSCRM
													cConteudo := If(Empty(aItem[nX,nY]),"ISENTO",aItem[nX,nY])
												Else
													cConteudo := SA2->A2_INSCRM
												Endif
											ElseIf Alltrim(aCabec[nY,2]) == "A2_COD_MUN"
												CC2->(dbSetOrder(4))
												If CC2->(dbSeek(xFilial("CC2")+aItem[nX,nPsEst]+Padr(aItem[nX,nPsMun],TamSX3("A2_MUN")[1])))
													cConteudo := CC2->CC2_CODMUN
												Endif
											ElseIf aCabec[nY,3] == "C"
												cConteudo := SubStr(aItem[nX,nY],1,aCabec[nY,5])
											ElseIf aCabec[nY,3] == "D"
												cConteudo := CTOD(aItem[nX,nY])
											ElseIf aCabec[nY,3] == "N"
												cConteudo := Val(aItem[nX,nY])
											Endif
											AAdd( aFornece, { aCabec[nY,2] , cConteudo , Nil } )							
										Endif
									Endif
								Endif
							Endif
						Next nY
			
						If Len(aFornece) > 0
							
							// Aqui eu passo campos com conteudo fixo
							AAdd( aFornece, { "A2_ID_FBFN" 	, "3" , Nil } )
							AAdd( aFornece, { "A2_RECISS" 	, "N" , Nil } )
							AAdd( aFornece, { "A2_RECPIS" 	, "2" , Nil } )
							AAdd( aFornece, { "A2_RECCOFI" 	, "2" , Nil } )
							AAdd( aFornece, { "A2_RECCSLL" 	, "2" , Nil } )
							
							aFornece := FWVetByDic(aFornece, "SA2")
							
							cGrpCrtl := aItem[nX,nPsGrupo]
							cFilCrtl := aItem[nX,nPsFil]
							cCNPJ 	 := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")
							cDoc  	 := aItem[nX,nPsNota]
											
							//--< Inicializa variáveis para uso na rotina automática >------------------------------
							
							// Retorno a Ordem para Principal
							CC2->(dbSetOrder(1))
							
							lMSErroAuto	:= .F.
							
							//--< Rotina automática de cadastro do fornecedor. >-----------------------------------							
							Processa({|| MSExecAuto({|x,y| MATA020(x,y)}, aFornece, nOpcSA2) }, If(nOpcSA2==3,"Incluindo","Alterando") + " Fornecedor " + cCNPJ)
							
							If lMSErroAuto
								If nOpcSA2 == 4
									SA2->(dbSetOrder(3))
									If SA2->(dbSeek(xFilial('SA2')+cCNPJ))
										RecLock("SA2",.F.)
										For nA := 1 to Len(aFornece)
											&(aFornece[nA,1]) := aFornece[nA,2]										
										Next
										MsUnlock()
										cMsg += "Fornecedor: " + SA2->A2_CGC + If(nOpcSA2==3," incluido"," alterado") + " com sucesso!"+ENTER
										lMSErroAuto := .F.	// Forço
									Endif 
								Else
									/*
									If nOpcSA2 == 3
										SA2->(dbSetOrder(3))
										If !SA2->(dbSeek(xFilial('SA2')+cCNPJ))
											RecLock("SA2",.T.)
											For nA := 1 to Len(aFornece)
												&(aFornece[nA,1]) := aFornece[nA,2]										
											Next
											MsUnlock()
											cMsg += "Fornecedor: " + SA2->A2_CGC + If(nOpcSA2==3," incluido"," alterado") + " com sucesso!"+ENTER
											lMSErroAuto := .F.	// Forço
										Endif 									
										ConfirmSX8()
										cMsg += "Fornecedor: " + SA2->A2_CGC + If(nOpcSA2==3," incluido"," alterado") + " com sucesso!"+ENTER
										lMSErroAuto := .F.	// Forço
									Endif
									*/
									ConfirmSX8()
								    cMsgPlan := ""
									nErros++
								    aErro := GetAutoGRLog()
								    cMsg += "Erro ao " + If(nOpcSA2==3," incluir"," alterar") + " fornecedor " + SA2->A2_CGC +ENTER
								    For i := 1 To Len(aErro)
									    cMsg += aErro[i] + Chr(13) + Chr(10)
									    cMsgPlan += StrTran(StrTran(StrTran(aErro[i],";"," "),chr(10),"/"),chr(13),"/")
									Next i

								Endif
							Else
								cMsg += "Fornecedor: " + SA2->A2_CGC + If(nOpcSA2==3," incluido"," alterado") + " com sucesso!"+ENTER
							Endif
		
							aAdd(aRetorno , { cGrpCrtl , cFilCrtl , cCNPJ , cDoc , If(lMSErroAuto,cMsgPlan,"SUCESSO") } )					
		
						Endif
					
					Endif
					
				Endif
				
			Endif
		
		Else
		
			If Ascan( aRetorno, {|x| Alltrim(x[3])  == cCNPJ } ) == 0
				aAdd(aRetorno , { aItem[nX,nPsGrupo] , aItem[nX,nPsFil] , cCNPJ , cDoc , "Registro não pertence a essa Empresa/Filial " + Alltrim(SM0->M0_CODIGO)+"/"+Alltrim(SM0->M0_CODFIL)} )
				cMsg += "CNPJ: " + cCNPJ+ " -> Registro não pertence a essa Empresa/Filial " + Alltrim(SM0->M0_CODIGO)+"/"+Alltrim(SM0->M0_CODFIL) + ENTER
			Endif
		
		Endif
		
	Next nX

	// Tratamento do retorno 
	For nM := 1 to Len(aRetorno)
		For nN := 1 to Len(aItem)
			cCNPJStr := StrTran(StrTran(StrTran(aItem[nN,nPsForn],".",""),"/",""),"-","")
			If Alltrim(aItem[nN,nPsGrupo])+Alltrim(aItem[nN,nPsFil])+Alltrim(cCNPJStr)+Alltrim(aItem[nN,nPsNota]) == Alltrim(aRetorno[nM,1])+Alltrim(aRetorno[nM,2])+Alltrim(aRetorno[nM,3])+Alltrim(aRetorno[nM,4])
				aItem[nN,nPSSeqErr] := If(aRetorno[nM,5]=="SUCESSO","0","1")
				aItem[nN,nPsMsgRet] := aRetorno[nM,5]				
			Endif
		Next nN
	Next nM


Return




//------------------------------------------------------------------------------------------
/*/{Protheus.doc} B2ImpFor
Realiza a importação dos Fornecedores

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function xB2ImpFor(aCabec,aItem)

	Local nX  := 1
	Local nY  := 1
	Local nPs := 0
	Local oModel
	Local aFornece   := {}
	Local aRetorno	 := {}
	Local cCNPJ		 := ''
	Local nOpcSA2	 := 3	// Padrão Inclusão
	Local nPsCriaSA2 := Ascan( aCabec, {|x| Alltrim(x[1])  == "CRIA FORNECEDOR" } )	

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	Private Inclui			:= .T.
	Private	Altera			:= .F.
	Private CGRPCRTL		:= .T.
	Private lCGCValido		:= .F.	// Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup)
	Private lConfBco			:= .F. // Confirmacao da Dialog de amarracao fornecedor x bancos (Localizados) - FIL
	
	ProcRegua(Len(aItem))
	
	For nX := 1 to Len(aItem)
		
		cDoc  := aItem[nX,nPsNota]
		cCNPJ := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")				

		If Alltrim(aItem[nX,nPsGrupo])+Alltrim(aItem[nX,nPsFil]) == cEmpFilial	//Alltrim(SM0->M0_CODIGO)+Alltrim(SM0->M0_CODFIL)
		
			If Alltrim(Upper(aItem[nX,nPsCriaSA2])) == "SIM"
					
				If Ascan( aRetorno, {|x| Alltrim(x[3])  == cCNPJ } ) == 0 

					IncProc("Processando CNPJ " + aItem[nX,nPsForn])
					Conout("Processando CNPJ " + aItem[nX,nPsForn])
							
					aFornece := {}
					nOpcSA2 := 3
					
					cIdent := SubStr(aItem[nX,nPsIdenti],1,1) 

					If cIdent == "2" 
					
						dbSelectArea("SA2")
						SA2->(dbSetOrder(3))
						If SA2->(dbSeek(xFilial("SA2")+cCNPJ))
							nOpcSA2 := 4
							Inclui  := .F.
							Altera	:= .T.
						Endif
						
						For nY := 1 to Len(aCabec)
							If aCabec[nY,4] == "1"
								If Substr(aCabec[nY,2],1,3) == "A2_"
									If nOpcSA2 == 3
										If Alltrim(aCabec[nY,2]) == "A2_CGC"
											cConteudo := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")
										ElseIf Alltrim(aCabec[nY,2]) $ "A2_INSCR|A2_INSCRM"	// Confirmar com cliente
											cConteudo := If(Empty(aItem[nX,nY]),"ISENTO",aItem[nX,nY])
										ElseIf Alltrim(aCabec[nY,2]) == "A2_COD_MUN"
											cConteudo := Alltrim(aItem[nX,nY])
											CC2->(dbSetOrder(3))
											If !CC2->(dbSeek(xFilial("CC2")+Padr(cConteudo,TamSX3("CC2_CODMUN")[1])))
												nPsEst := Ascan( aCabec, {|x| Alltrim(x[2]) == "A2_EST" } )
												nPsMun := Ascan( aCabec, {|x| Alltrim(x[2]) == "A2_MUN" } )
												CC2->(dbSetOrder(4))
												If CC2->(dbSeek(xFilial("CC2")+aItem[nX,nPsEst]+Padr(aItem[nX,nPsMun],TamSX3("A2_MUN")[1])))
													cConteudo := CC2->CC2_CODMUN
												Endif
											Endif											
										ElseIf aCabec[nY,3] == "C"
											cConteudo := SubStr(aItem[nX,nY],1,aCabec[nY,5])
										ElseIf aCabec[nY,3] == "D"
											cConteudo := CTOD(aItem[nX,nY])
										ElseIf aCabec[nY,3] == "N"
											cConteudo := Val(aItem[nX,nY])
										Endif
										AAdd( aFornece, { aCabec[nY,2] , cConteudo , Nil } )
									Else
										If aCabec[nY,7] == "1"	// Desconsidero a ação 1 que é inclusão/alteração
											If Alltrim(aCabec[nY,2]) $ "A2_COD"
												cConteudo := SA2->A2_COD
											ElseIf Alltrim(aCabec[nY,2]) $ "A2_LOJA"	// Confirmar com cliente
												cConteudo := SA2->A2_LOJA											
											ElseIf Alltrim(aCabec[nY,2]) $ "A2_INSCR|A2_INSCRM|"	// Confirmar com cliente
												cConteudo := If(Empty(aItem[nX,nY]),"ISENTO",aItem[nX,nY])
											ElseIf Alltrim(aCabec[nY,2]) == "A2_COD_MUN"
												cConteudo := Alltrim(aItem[nX,nY])
												//-------------------------------------------------------------------------
												// Tratamento necessário pois o cod.municipio esta vindo s/ Zero a esquerda
												//-------------------------------------------------------------------------
												CC2->(dbSetOrder(3))
												If !CC2->(dbSeek(xFilial("CC2")+Padr(cConteudo,TamSX3("CC2_CODMUN")[1])))
													nPsEst := Ascan( aCabec, {|x| Alltrim(x[2]) == "A2_EST" } )
													nPsMun := Ascan( aCabec, {|x| Alltrim(x[2]) == "A2_MUN" } )
													CC2->(dbSetOrder(4))
													If CC2->(dbSeek(xFilial("CC2")+aItem[nX,nPsEst]+Padr(aItem[nX,nPsMun],TamSX3("A2_MUN")[1])))
														cConteudo := CC2->CC2_CODMUN
													Endif
												Endif												
												//-------------------------------------------------------------------------											
											ElseIf aCabec[nY,3] == "C"
												cConteudo := SubStr(aItem[nX,nY],1,aCabec[nY,5])
											ElseIf aCabec[nY,3] == "D"
												cConteudo := CTOD(aItem[nX,nY])
											ElseIf aCabec[nY,3] == "N"
												cConteudo := Val(aItem[nX,nY])
											Endif
											AAdd( aFornece, { aCabec[nY,2] , cConteudo , Nil } )							
										Endif
									Endif
								Endif
							Endif
						Next nY
						
						If Len(aFornece) > 0
							
							//AAdd( aFornece, { "A2_FILIAL" , xFilial("SA2") , Nil } )
							
							aFornece := FWVetByDic(aFornece, "SA2")
							
							cGrpCrtl := aItem[nX,nPsGrupo]
							cFilCrtl := aItem[nX,nPsFil]
							cCNPJ 	 := StrTran(StrTran(StrTran(aItem[nX,nPsForn],".",""),"/",""),"-","")
							cDoc  	 := aItem[nX,nPsNota]
											
							//--< Inicializa variáveis para uso na rotina automática >------------------------------
							
							// Retorno a Ordem para Principal
							CC2->(dbSetOrder(1))
							SA1->(dbCloseArea())
							// Retorno a Ordem para Principal 							
							SA2->(dbSetOrder(1))
							
							lMSErroAuto	:= .F.
							
							//--< Rotina automática de cadastro do fornecedor. >-----------------------------------
							MSExecAuto({|x,y| MATA020(x,y)}, aFornece, nOpcSA2)
							
							If lMSErroAuto				    
							    cMsgPlan := ""
								nErros++
							    aErro := GetAutoGRLog()
							    cMsg += "Erro ao " + If(nOpcSA2==3," incluir"," alterar") + " fornecedor " + SA2->A2_CGC +ENTER
							    For i := 1 To Len(aErro)
								    //cMsg += aErro[i] + Chr(13) + Chr(10)
								    cMsgPlan += StrTran(StrTran(StrTran(aErro[i],";"," "),chr(10),"/"),chr(13),"/")
							    Next i
							Else
								cMsg += "Fornecedor: " + SA2->A2_CGC + If(nOpcSA2==3," incluido"," alterado") + " com sucesso!"+ENTER
							Endif
		
							aAdd(aRetorno , { cGrpCrtl , cFilCrtl , cCNPJ , cDoc , If(lMSErroAuto,cMsgPlan,"SUCESSO") } )					
		
						Endif

						/*
						If Len(aFornece) > 0
						
							If  oModel == NIL
								oModel := FwLoadModel("MATA020M")
								oModel:SetOperation(nOpcSA2)
								oModel:Activate()
							EndIf
							
							If nOpcSA2 == 4							
								oModel:SetValue("SA2MASTER","A2_COD" ,SA2->A2_COD)
								oModel:SetValue("SA2MASTER","A2_LOJA",SA2->A2_LOJA) 		
							Endif
							
							For nY := 1 to Len(aFornece)
								If nOpcSA2 == 4 .And. Alltrim(aFornece[nY,1]) $ "A2_COD|A2_LOJA|"								
								Else
									oModel:SetValue("SA2MASTER",aFornece[nY,1],aFornece[nY,2])
								Endif							
							Next nY
						
						Endif

						If oModel:VldData()
							oModel:CommitData()
						Else
						    cMsgPlan := ""
							nErros++
						    aErro := GetAutoGRLog()
						    cMsg += "Erro ao " + If(nOpcSA2==3," incluir"," alterar") + " fornecedor " + SA2->A2_CGC +ENTER
						    For i := 1 To Len(aErro)
							    //cMsg += aErro[i] + Chr(13) + Chr(10)
							    cMsgPlan += StrTran(StrTran(StrTran(aErro[i],";"," "),chr(10),"/"),chr(13),"/")
						    Next i
						EndIf
						
						aAdd(aRetorno , { cGrpCrtl , cFilCrtl , cCNPJ , cDoc , If(lMSErroAuto,cMsgPlan,"SUCESSO") } )
				
						oModel:DeActivate()
						oModel:Destroy()
						oModel := Nil						
						*/
					
					Endif
					
				Endif
				
			Endif
		
		Else
		
			If Ascan( aRetorno, {|x| Alltrim(x[3])  == cCNPJ } ) == 0
				aAdd(aRetorno , { aItem[nX,nPsGrupo] , aItem[nX,nPsFil] , cCNPJ , cDoc , "Registro não pertence a essa Empresa/Filial " + Alltrim(SM0->M0_CODIGO)+"/"+Alltrim(SM0->M0_CODFIL)} )
				cMsg += "CNPJ: " + cCNPJ+ " -> Registro não pertence a essa Empresa/Filial " + Alltrim(SM0->M0_CODIGO)+"/"+Alltrim(SM0->M0_CODFIL) + ENTER
			Endif
		
		Endif
		
	Next nX

	// Tratamento do retorno 
	For nM := 1 to Len(aRetorno)
		For nN := 1 to Len(aItem)
			cCNPJStr := StrTran(StrTran(StrTran(aItem[nN,nPsForn],".",""),"/",""),"-","")
			If Alltrim(aItem[nN,nPsGrupo])+Alltrim(aItem[nN,nPsFil])+Alltrim(cCNPJStr)+Alltrim(aItem[nN,nPsNota]) == Alltrim(aRetorno[nM,1])+Alltrim(aRetorno[nM,2])+Alltrim(aRetorno[nM,3])+Alltrim(aRetorno[nM,4])
				aItem[nN,nPSSeqErr] := If(aRetorno[nM,5]=="SUCESSO","0","1")
				aItem[nN,nPsMsgRet] := aRetorno[nM,5]				
			Endif
		Next nN
	Next nM


Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} B2PegaArq
Pega os arquivos no diretório apontado pelo usuário

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function B2PegaArq()

	Local cArqAux := ""

//	cArqAux := cGetFile( "Arquivo Texto *.ent | *.ent",;    //Mascara
//	cArqAux := cGetFile( "Arquivo Texto "+SM0->(M0_CODIGO+M0_CODFIL)+"*.ent | "+SM0->(M0_CODIGO+M0_CODFIL)+"*.ent",;    //Mascara
	cArqAux := cGetFile( "Arquivo Texto "+cEmpFilial+"*.csv | "+cEmpFilial+"*.csv",;    //Mascara
	"Arquivo...",;                        					//Tatulo
	,;                                   				     //Numero da mascara
	,;                                				        //Diretario Inicial
	.F.,;                          				         	//.F. == Abrir; .T. == Salvar
	GETF_LOCALHARD,;              				       		//Diretrio full. Ex.: 'C:\TOTVS\arquivo.xlsx'
	.F.)                                					//Nao exibe diretrio do servidor

	cGetArq := PadR(cArqAux,200)
	oGetArq:Refresh()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
//Função para utilização no Schedule 
@author Marcio Martins pereira
@since 07/05/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function SchedDef()

	Local _aPar 	:= {}		//array de retorno
	Local _cFunc	:= "GTGEN047"
	Local _cPerg	:= PadR(_cFunc, 10)


	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return _aPar
//--< fim de arquivo >----------------------------------------------------------------------
