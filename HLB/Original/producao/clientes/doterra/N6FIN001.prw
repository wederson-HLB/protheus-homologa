


User Function N6FIN001()

Local aLegenda 		:= {{"ZX3_STATUS == '1'","BR_VERDE"},;
						{"ZX3_STATUS == '2'","BR_VERMELHO"	},;
						{"ZX3_STATUS == '3'","BR_AMARELO"	},;
						{"ZX3_STATUS == '4'","BR_AZUL"		},;
						{"ZX3_STATUS == '5'","BR_BRANCO"	},;
						{"ZX3_STATUS == '6'","BR_LARANJA"	},; //Antecipacao Nao Processada
						{"ZX3_STATUS == '7'","BR_PINK"		}}  //Antecipado
						
Private cCadastro 	:= "Conciliacao Worldpay"
Private cString 	:= "ZX3"
Private aRotina 	:= {{"Pesquisar"	,"AxPesqui"		,0,1},;
             			{"Imp Arq Worldpay","u_N6FIN003"	,0,3},;
             			{"Conciliacao"	   ,"U_N6FIN002"	,0,2},;
             			{"Visualizar"	   ,"A910ALTERA"	,0,2},;
             			{"Alterar"		   ,"A910ALTERA"	,0,4},;
             			{"Listagem Reg"	   ,"U_N6FIN004"	,0,4},;
             			{"Legenda"		   ,"A910LEGEND"	,0,5}}


dbSelectArea(cString)
dbSetOrder(1)

mBrowse(6,1,22,75,cString,,,,,,aLegenda)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ910ALEGENDบAutor  ณRafael Rosa da Silvaบ Data ณ  08/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que monsta a Legenda de status do Conciliador TEF	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static Function A910LEGEND()

BrwLegenda("Conciliacao Worldpay","Legenda",{{"BR_VERDE"		,"Nใo Processado"	},;
										{"BR_VERMELHO"	,"Conciliado Normal"},;
										{"BR_AMARELO"	,"Divergente"		},;
										{"BR_AZUL"		,"Conciliado Manual"},;
										{"BR_BRANCO"	,"Descartado"		},;
										{"BR_LARANJA"	,"Ant. Nao Processada"},;
										{"BR_PINK"		,"Antecipado"		}})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA910A  บAutor  ณMicrosiga           บ Data ณ  08/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static Function A910ALTERA(cAlias,nReg,nOpc)
                                                            		
Local aCpoEnch  := {}
Local aAlterEnch:= {}
Local aPos		:= {C(010),C(002),C(181),C(267)}                        
Local nModelo	:= 3       	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3 		:= .F.		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria  := .T.		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn	:= .F.		// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela 	:= "" 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder := .F.		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty := .T.		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
Local aButtons	:= {}
Local lRet     := .F.
Local nI       := 0
Local oDlg					// Dialog Principal

//Monto os campos da Enchoice deixando somente os campos customizados e o ZX3_STATUS para alterar
dbSelectArea("SX3")
dbSetOrder(1)
If SX3->( dbSeek( cAlias ) )
	While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cAlias
		aAdd(aCpoEnch,SX3->X3_CAMPO)
		If (Alltrim(SX3->X3_PROPRI) == "U" .Or. Alltrim(SX3->X3_CAMPO) == "ZX3_STATUS") .And. nOpc <> 2
			aAdd(aAlterEnch,SX3->X3_CAMPO)
		EndIf
		SX3->( dbSkip() )
	End
EndIf

DEFINE MSDIALOG oDlg TITLE "Conciliador Worlpay"+" - "+If(ALTERA,"Alterar","Visualizar") FROM C(178),C(181) TO C(548),C(717) PIXEL
	RegToMemory(cAlias, INCLUI, .F.)
	Enchoice(cAlias,,nOpc,,,,aCpoEnch,aPos,aAlterEnch,nModelo,,,,oDlg,lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty)
ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {|| lRet := .T.,oDlg:End()},{||lRet := .F.,oDlg:End()},,aButtons)

If lRet .And. nOpc <> 2 .And. Len(aAlterEnch) > 0
	RecLock(cAlias,.F.)
	For nI := 1 to Len(aAlterEnch)
		(cAlias)->&(aAlterEnch[nI]) :=  M->&(aAlterEnch[nI])
	Next nI
	(cAlias)->( MsUnLock() )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf

Return Int(nTam)

                                            	

