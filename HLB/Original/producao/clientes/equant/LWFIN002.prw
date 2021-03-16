#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"


/*
Funcao      : LWFIN002
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função para gerar título aglutinado de outros títulos (utiliza o conceito de fatura do sistema) para clientes que tenham grupo
Autor       : Matheus Massarotto
Data/Hora   : 28/01/2015    17:45
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/

/*
Funcao      : LWFIN002()
Parametros  : 
Retorno     : 
Objetivos   : Função que gera a tela com os containers
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*---------------------*
User function LWFIN002
*---------------------*
Local cQry	:= ""
Local cPerg	:= "LWFIN002"

Local oLayer 	:= FWLayer():new()
Local aSize     := {}
Local aObjects	:= {}

Private nValor 	:= 0
Private aMark 	:= {}

AjusPerg(cPerg)

if !Pergunte(cPerg,.T.)
	Return
endif

Private oDlg
Private oBrowseE
Private oBrowseD

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()

AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

    DEFINE DIALOG oDlg TITLE "Fatura a receber" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)
		
		oFont:= TFont():New('Arial',,-14,,.f.)
        
		oLayer:init(oDlg,.F.,.T.)              

		oLayer:addLine( 'CIMA', 15 , .F. )
		oLayer:addLine( 'BAIXO',85 , .F. )
        
		oLayer:addCollumn('CEN',100,.F.,'CIMA')

		oLayer:addCollumn('ESQ',25,.F.,'BAIXO')
		oLayer:addCollumn('DIR',75,.F.,'BAIXO')
        
		oLayer:addWindow('CEN','WinCC','Opções',100,.F.,.F.,{||  },'CIMA',{||  })

        oLayer:addWindow('ESQ','WinEC','Grupos',100,.F.,.F.,{||  },'BAIXO',{||  })
		oLayer:addWindow('DIR','WinDC','Títulos',100,.F.,.F.,{||  },'BAIXO',{|| })
        
		oWinCC := oLayer:getWinPanel('CEN','WinCC','CIMA')
		
		oWinEB := oLayer:getWinPanel('ESQ','WinEC','BAIXO')
		oWinDB := oLayer:getWinPanel('DIR','WinDC','BAIXO')

		oBtn1 := TBtnBmp2():New( 01,02,26,26,'FINAL',,,,{||oDlg:end()},oWinCC,,,.T. )
		oBtn1:cTooltip:="Sair"
		
		oBtn2 := TBtnBmp2():New( 01,42,26,26,'OK',,,,{||Barpross(),oBrowseE:Refresh(.T.),oBrowseD:Refresh(.T.)},oWinCC,,,.T. )
		oBtn2:cTooltip:="Gerar Fatura"

    ACTIVATE DIALOG oDlg CENTERED ON INIT(Carrega()) 
    
Return

/*
Funcao      : Carrega()
Parametros  : 
Retorno     : 
Objetivos   : Função intermediária, da tela principal para as demais
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-------------------------*
Static function Carrega()
*-------------------------*

//Cria o temporário com os grupos selecionados
if !GrupoCli()
	MsgInfo("Nenhum grupo encontrado!")
	Return
endif

//Cria o temporário com os títulos de grupos
if !TituloCli()
	MsgInfo("Nenhum título encontrado para o(s) grupo(s) selecionado(s)!")
	Return
endif

//Chama a montagem do browse esquerdo
BrowEsq()

//Chama a montagem do browse direito
BrowDir()

//Chama a montagem da relação dos browses
Relacao()

oBrowseD:Refresh(.T.)

Return

/*
Funcao      : BxGeFat()
Parametros  : 
Retorno     : 
Objetivos   : Função que baixa os títulos e gera a fatura
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*----------------------*
Static Function BxGeFat
*----------------------*
Local cArquivo      := ""
Local nTotal		:= 0
Local nHdlPrv		:= 0
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)  
Local nValProces	:= 0
Local aRastroOri	:= {}
Local aPccBxCr		:= {0,0,0,0}
Local aFlagCTB 		:= {}
Local lPccBxCr		:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local dDatCont 		:= dDatabase

//639.04 Base Impostos diferenciada
Local lBaseImp	:= If(FindFunction('F040BSIMP'),F040BSIMP(2),.F.)

Local cPadrao	:= "595"
Local lPadrao  := VerPadrao(cPadrao)

Local lRastro		:= If(FindFunction("FVerRstFin"),FVerRstFin(),.F.)
Local aRastroDes	:= {}
Local aTitInc 		:= {}

Local lRet			:= .F.

Private cPrefix		:= ""//"FAT"//Space(3)
Private cFatura		:= ""//CRIAVAR("E1_NUM")
Private cTipo		:= "FT"//Criavar ("E1_TIPOFAT")

Private cLote
Private cNat     	:= TRBGRP->GRPNAT //CRIAVAR("E1_NATUREZ") //Natureza

Private aHeader		:= {}
Private aCols		:= {array(8)}

Private oDlg2,oPanel2, oPanel1 

Private lMsErroAuto := .F.

if MV_PAR05==1
	cPrefix:="FRP"
elseif MV_PAR05==2
	cPrefix:="FTE"
elseif MV_PAR05==3
	cPrefix:="FR "
endif

DbSelectArea("SED")
SED->(DbSetOrder(1))
if !DbSeek(xFilial("SED")+cNat)
	Alert("Natureza do grupo: "+alltrim(TRBGRP->GRPCOD)+" não encontrada!")
	Return(lRet)
endif

cPccBxCr	:= Fa280VerImp(cNat,.T.)	//Impostos PCC com calculo para o Cliente/Natureza

//**Tratamento para o número da fatura
aTam := TamSx3("E1_NUM")
cFatura	:= Soma1( GetMv("MV_NUMFAT"),  aTam[1])
cFatura	+= Space(aTam[1] - Len(cFatura))

While !MayIUseCode( "SE1"+xFilial("SE1")+cFatura)  //verifica se esta na memoria, sendo usado
	// busca o proximo numero disponivel 
	cFatura := Soma1(cFatura)                                                                                                             	
EndDo
cFatAnt := cFatura

nOpca	:= 1

cCond:= TRBGRP->GRPSE4 //condição de pagamento
nMoedFat:=1 //moeda da fatura

nTotFatura	:=0
nValTot		:=0
nValCruz	:=0

nTotPis		:=0
nTotCofins	:=0
nTotCsll	:=0
nTotBase	:=0


DbSelectArea("SA1")
SA1->(DbSetOrder(1))
if !DbSeek(xFilial("SA1")+TRBGRP->GRPCLI+TRBGRP->GRPLOJ)
	Alert("Cliente do grupo: "+alltrim(TRBGRP->GRPCOD)+" não encontrado!")
	Return(lRet)
endif

cCliFat:=TRBGRP->GRPCLI //Cliente da fatura
cLojaFat:=TRBGRP->GRPLOJ //loja do cliente da fatura

DbSelectArea("SE4")
SE4->(DbSetOrder(1))

if empty(cCond)
	Alert("Condição de pagamento do grupo: "+alltrim(TRBGRP->GRPCOD)+" não informada!")
	Return(lRet)
elseif !SE4->(DbSeek(xFilial("SE4")+cCond))
	Alert("Condição de pagamento do grupo: "+alltrim(TRBGRP->GRPCOD)+" não encontrada!")
	Return(lRet)
endif

If !((ExistBlock("F280CON")))
	cCondicao := If(nOpca=0,"   ",cCond)
	aVenc := Condicao(nValor,cCondicao,0)												 													 	
Endif

nDup	:= Len(aVenc)

	aCols := GravaDp(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc,cTipo,"FINA280")

    if len(aCols) > 0

		If Fa280Num(@cFatAnt) // Se nao existir o mesmo numero de fatura
	
			Begin Transaction	
				nTotAbat :=0
				dbSelectArea("SE1")
				nRegE1 := Nil
				nFirstE1 := NIL  // Esta variavel será utilizada no PE FA280 (Fortymil)
				For nW := 1 To Len(aMark)
					MsGoto(aMark[nW])
					cNumero		:=	SE1->E1_NUM
					cPrefixo	:=	SE1->E1_PREFIXO
					cParcela	:=	SE1->E1_PARCELA
					nRegE1		:=	aMark[nW]
					nFirstE1 := IIF(nFirstE1==Nil,aMark[nW],nFirstE1)
	
					Pergunte("AFI280",.F.)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta a Fatura no SE1,                                   ³
					//³ Verifica e efetua a Baixa de Abatimentos,                ³
					//³ Efetua a Baixa do Titulo Principal e                     ³
					//³ Gera Movimentacao no SE5 das Baixa.                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FA280MonFa( "SE1", xFilial("SE1"), cPrefixo, cNumero, cParcela, nRegE1, cFatura, cPrefix, cTipo,,,;
					            @cArquivo, @nTotal, @nHdlPrv, lUsaFlag, @aFlagCTB,@nValProces,aRastroOri,aPccBxCr)
					
					DbSelectArea("TRBTIT")
					TRBTIT->(DbSetOrder(1))
					if TRBTIT->(DbSeek(TRBGRP->GRPCOD+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
						RecLock("TRBTIT",.F.)
							TRBTIT->TIT_STATUS:="2"
						TRBTIT->(MsUnLock())
					endif
					            
					If GetNewPar("MV_RMCLASS",.F.) 
						IF alltrim(upper(SE1->E1_ORIGEM)) == 'S' .or. SE1->E1_IDLAN > 0
							//Replica a baixa do titulo para as tabelas do corpore
							ClsProcBx(SE1->(Recno()),'1','FIN280')
						Endif
					Endif
	
					dbSelectArea("SE1")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000014","02","FINA280")
				Next
				nValTotal := 0
	
				//PCC Baixa CR
				//Necessario somar o total da fatura antes da geracao da fatura
				//para proporcionalizar o valor do PCC
			   	If lPccBxCR .or. lBaseImp 
					For nW:=1 To Len(aCols)
						//If ! aCols[nW,Len(aHeader)+1] // .F. == Ativo  .T. == Deletado				
							nTotFatura += xMoeda(aCols[nW,6],nMoedFat,1)
						//Endif
					Next						
				Endif	
	           
	           
				For nW:=1 To Len(aCols)
					//If ! aCols[nW,Len(aHeader)+1] // .F. == Ativo  .T. == Deletado				
						cPrefix		:= aCols[nW][1]
						cParcela		:= aCols[nW][3]
						cTipo			:= aCols[nW][4]
						cVencmto		:= aCols[nW][5]
						nValDup		:= aCols[nW][6]
						nValCruz		:= xMoeda(aCols[nW,6],nMoedFat,1)
						cBanco		:= aCols[nW][7]
				
						//Gera fatura atraves da rotina automatica do Fina040 para que faca o recalculo 
						//e gere os abatimentos referente ao valor total titulos que serao selecionados;
						nValTotal	:= 0 
						nLen			:= Len(aCols)            
	
						//PCC Baixa CR
						//Tratamento da proporcionalizacao dos impostos PCC
						//para posterior gravacao na parcela gerada
						If lPccBxCR .or. lBaseImp
							nPropPcc		:= nValCruz / nTotFatura
							nPis			:= Round(NoRound(aPccBxCr[1] * nPropPcc,3),2)
							nCofins		:= Round(NoRound(aPccBxCr[2] * nPropPcc,3),2)						
							nCsll			:= Round(NoRound(aPccBxCr[3] * nPropPcc,3),2)
							nBaseImp		:= Round(NoRound(aPccBxCr[4] * nPropPcc,3),2)
							nTotPis		+= nPis
							nTotCofins	+= nCofins
							nTotCsll		+= nCsll
							nTotBase		+= nBaseImp
							 						
							//Acerto de eventuais problemas de arredondamento
							If aPccBxCr[1] - nTotPis <= 0.01
								nPis		+= aPccBxCr[1] - nTotPis
							Endif
	
							If aPccBxCr[2] - nTotCofins <= 0.01
								nCofins	+= aPccBxCr[2] - nTotCofins
							Endif
	
							If aPccBxCr[3] - nTotCsll <= 0.01
								nCSll		+= aPccBxCr[3] - nTotCsll
							Endif
	
							If aPccBxCr[4] - nTotBase <= 0.01
								nBaseImp	+= aPccBxCr[4] - nTotBase
							Endif
	
						Endif
							
						IncProc("Incluindo a fatura...")
						If ! GdDeleted(nW) // .F. == Ativo  .T. == Deletado
							dbSelectArea("SA1")
							If Empty( cCliFat )
								MsSeek(xFilial("SA1")+cCli+cLoja)
							Else
								MsSeek(xFilial("SA1")+cCliFat+cLojaFat)
							Endif
							aTit := {}
							AADD(aTit , {"E1_FILIAL"	, xFilial("SE1")									, NIL})						
							AADD(aTit , {"E1_PREFIXO"	, cPrefix											, NIL})
							AADD(aTit , {"E1_NUM"    	, cFatura											, NIL})
							AADD(aTit , {"E1_PARCELA"	, cParcela											, NIL})
							AADD(aTit , {"E1_TIPO"   	, cTipo												, NIL})
							AADD(aTit , {"E1_NATUREZ"	, cNat												, NIL})
							AADD(aTit , {"E1_SITUACA"	, "0"													, NIL})
							AADD(aTit , {"E1_VENCTO" 	, cVencmto											, NIL})
							AADD(aTit , {"E1_VENCREA"	, DataValida(cVencmto,.T.)						, NIL})
							AADD(aTit , {"E1_VENCORI"	, DataValida(cVencmto,.T.)						, NIL})
							AADD(aTit , {"E1_EMISSAO"	, dDataBase											, NIL})
							AADD(aTit , {"E1_EMIS1"		, dDataBase											, NIL})
							AADD(aTit , {"E1_CLIENTE"	, IIF( Empty( cCliFat ), cCli, cCliFat )	, NIL})
							AADD(aTit , {"E1_LOJA"   	, IIF( Empty(cCliFat),cLoja,cLojaFat )		, NIL})
							AADD(aTit , {"E1_NOMCLI" 	, SA1->A1_NREDUZ									, NIL})
							AADD(aTit , {"E1_MOEDA"  	, nMoedFat											, NIL})
							AADD(aTit , {"E1_VALOR"  	, nValDup											, NIL})
							AADD(aTit , {"E1_SALDO"  	, nValDup											, NIL})
							AADD(aTit , {"E1_VLCRUZ" 	, xMoeda(nValDup,nMoedFat,1)					, NIL})
							AADD(aTit , {"E1_STATUS" 	, "A"													, NIL})
							AADD(aTit , {"E1_OCORREN"	, "01"												, NIL})
							AADD(aTit , {"E1_ORIGEM" , "FINA280"											, NIL})
							AADD(aTit , {"E1_FATURA" , "NOTFAT"												, NIL})
							AADD(aTit , {"E1_CREDIT"   ,  SE1->E1_CREDIT									, NIL})
							AADD(aTit , {"E1_DEBITO"   ,  SE1->E1_DEBITO									, NIL})
							AADD(aTit , {"E1_CCC"      ,  SE1->E1_CCC										, NIL})
							AADD(aTit , {"E1_ITEMC"    ,  SE1->E1_ITEMC									, NIL}) 
							AADD(aTit , {"E1_CLVLCR"   ,  SE1->E1_CLVLCR									, NIL})
							AADD(aTit , {"E1_CCD"      ,  SE1->E1_CCD										, NIL})
							AADD(aTit , {"E1_ITEMD"    ,  SE1->E1_ITEMD									, NIL}) 
							AADD(aTit , {"E1_CLVLDB"   ,  SE1->E1_CLVLDB									, NIL})
	
							// Se o vendedor nao estiver bloqueado, inclui nos titulos de fatura gerados
							//If !F280BlqVen()
							//	AADD( aTit , {"E1_VEND1", SE1->E1_VEND1									, NIL})
							//EndIf	
	
							If lPccBxCr
								If "PIS" $ cPccBxCr .and. nPis > 0
									AADD(aTit , {"E1_PIS"   ,  nPis		, NIL})
								Endif
								If "COF" $ cPccBxCr .and. nCofins > 0							
									AADD(aTit , {"E1_COFINS",  nCofins	, NIL}) 
								Endif
								If "CSL" $ cPccBxCr .and. nCsll > 0
									AADD(aTit , {"E1_CSLL"  ,  nCsll		, NIL})
								Endif
							Endif						
	
							//639.04 Base Impostos diferenciada
							If lBaseImp .and. nPis+nCofins+nCsll > 0
								AADD(aTit , {"E1_BASEIRF"  ,  nBaseImp 	, NIL})
							Endif
	
							If GetMv('MV_ACATIVO')
								AADD(aTit , {"E1_NUMRA" , alltrim(cRA)	, NIL})
							Endif
							
							If GetNewPar("MV_RMCLASS",.F.) 
								AADD(aTit , {"E1_NUMRA" , SE1->E1_NUMRA								    	, NIL})
								if SE1->(FieldPos("E1_TURMA")) > 0
									AADD(aTit , {"E1_TURMA" , SE1->E1_TURMA								    , NIL})
								endif
							endif
											
							//Ponto de entrada para adicionar mais campos antes da geração das novas faturas.
							//If ExistBlock("A280GERF")							
							//	ExecBlock("A280GERF",.F.,.F.,{cPrefix,cFatura,cParcela,cTipo,DTOC(cVencmto),nW})
							//EndIf
							
							if !GetNewPar("MV_RMCLASS",.F.) 
								MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)
							else
							    lMsErroAuto := ClsF280InT(aTit)
							endif
	      
	                  //Verifica se a gravacao ocorreu normalmente, e possibilita o uso do PE FA280
	                  //para complementar a gravacao.
							If  lMsErroAuto
							    MOSTRAERRO() 
							    DisarmTransaction()
							Else
							
								lRet:=.T.
								
								//Grava na tela de títulos a fatura gerada
								RecLock("TRBTIT",.T.)
									TRBTIT->TIT_GRUPO	:= TRBGRP->GRPCOD
									TRBTIT->TIT_STATUS	:= "1" //aberto
									TRBTIT->TIT_PREFIX  := SE1->E1_PREFIXO
									TRBTIT->TIT_NUM     := SE1->E1_NUM
									TRBTIT->TIT_PARCEL	:= SE1->E1_PARCELA
									TRBTIT->TIT_TIPO    := SE1->E1_TIPO
									TRBTIT->TIT_CLIENT	:= SE1->E1_CLIENTE
									TRBTIT->TIT_LOJA	:= SE1->E1_LOJA
									TRBTIT->TIT_NOMCLI	:= SE1->E1_NOMCLI
									TRBTIT->TIT_EMISSA	:= SE1->E1_EMISSAO
									TRBTIT->TIT_VENCRE	:= SE1->E1_VENCREA
									TRBTIT->TIT_VALOR   := SE1->E1_VALOR
									TRBTIT->R_E_C_N_O_	:= SE1->(RECNO())
								TRBTIT->(MsUnlock())
								
								If ExistBlock("FA280")
									ExecBlock("FA280",.f.,.f.,nRegE1)
								Endif
								
								IF lPadrao
									If nHdlPrv <= 0
										nHdlPrv:=HeadProva(cLote,"FINA280",Substr(cUsuario,7,6),@cArquivo)
										lHead := .T.
									Endif
	
									If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
										aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
									Else
										RecLock("SE1")
										SE1->E1_LA := "S"
										MsUnlock()
									Endif
									nTotal += DetProva( nHdlPrv, cPadrao, "FINA280", cLote, /*nLinha*/, /*lExecuta*/,;
									                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
									                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
								Endif
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								PcoDetLan("000014","01","FINA280")
	
								//Rastreamento - Gerados
								If lRastro
									aadd(aRastroDes,{	SE1->E1_FILIAL,;
															SE1->E1_PREFIXO,;
															SE1->E1_NUM,;
															SE1->E1_PARCELA,;
															SE1->E1_TIPO,;
															SE1->E1_CLIENTE,;
															SE1->E1_LOJA,;
															SE1->E1_VALOR } )
								Endif			
	
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Adiciona o titulo na aTitInc - Int. Protheus x Classis³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aAdd(aTitInc,SE1->(Recno()))
								
							EndIf
							dbSelectArea("SE1")
						Endif
	
						nValTotal += xMoeda(nValDup,nMoedFat,1)  // nValCruz
						dbSelectArea("SE1")
					//Endif
				Next nW
				If ( nTotal > 0 ) .and. lPadrao
					FA280ConFa( nValTotal, cPadrao, cArquivo, nHdlPrv, @nTotal, "FINA280", @aFlagCTB )
				Endif
	
				//Gravacao do rastreamento
				If lRastro
					FINRSTGRV(2,"SE1",aRastroOri,aRastroDes,nValProces) 
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava no SX6 o numero da ultima fatura gerada. 						  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				GetMv("MV_NUMFAT")
				RecLock("SX6",.F.)
				SX6->X6_CONTEUD := cFatura
				msUnlock()
	
			End Transaction
	    
		Else
		
			Alert("Fatura já inserida: "+cPrefix+cFatura)
	
	    Endif
	    
	Endif    


Return(lRet)

/*
Funcao      : AjusPerg()
Parametros  : 
Retorno     : 
Objetivos   : Função de criação da pergunta
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*------------------------------*
Static Function AjusPerg(cPerg)
*------------------------------* 

U_PUTSX1( cPerg, "01", "Data De:"		, "Data De:"	, "Data De:"	, "", "D",08,00,00,"G","U_LWFIN_V1(MV_PAR01)" 	, "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Ate:"	, "Data Ate:"	, "Data Ate:"	, "", "D",08,00,00,"G","" 						, "","","","MV_PAR02")
U_PUTSX1( cPerg, "03", "Grupo De?:"	, "Grupo De?"	, "Grupo De?"	, "", "C",06,00,00,"G","" 						, "ACY","","","MV_PAR03","","","","","",,,,,,,,,,,,{"Informe o grupo inicial"})
U_PUTSX1( cPerg, "04", "Grupo Ate?:"	, "Grupo Ate?"	, "Grupo Ate?"	, "", "C",06,00,00,"G","" 						, "ACY","","","MV_PAR04","","","","","",,,,,,,,,,,,{"Informe o grupo final"})
U_PUTSX1( cPerg, "05", "Especie:"		, "Especie:"	, "Especie?"	, "", "N",01,00,00,"C","" 						, ""   ,"","","MV_PAR05","RPS","","","","Telecomunicação","","","Aluguel","",,,,,,,,{"Informe a espécie"})

Return

/*
Funcao      : LWFIN_V1()
Parametros  : 
Retorno     : 
Objetivos   : Função de validação de data no pergunte
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-----------------------------*
User Function LWFIN_V1(dData)
*-----------------------------*
Local dDtLmtIni	:= GETNEWPAR("MV_P_00043", CTOD("//"))
Local lRet		:= .T.

if dDtLmtIni>dData
	Alert("A data inicial deve ser maior ou igual a: "+DTOC(dDtLmtIni))
	lRet:=.F.
endif

Return(lRet)

/*
Funcao      : TituloCli()
Parametros  : 
Retorno     : 
Objetivos   : Função que cria o temporário TRBGRP com os grupos
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-------------------------*
Static function GrupoCli()
*-------------------------*
Local cQry	:= ""
Local lRet	:= .T.
//-->INICIO - Tabela temporária para o lado esquerdo
Local aDadTemp	:= {}

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"GRPCOD"		,"C",6,0})
AADD(aDadTemp,{"GRPDES"		,"C",20,0})
AADD(aDadTemp,{"GRPSE4"		,"C",TamSX3("E4_CODIGO")[1],0})
AADD(aDadTemp,{"GRPCLI"		,"C",6,0})
AADD(aDadTemp,{"GRPLOJ"		,"C",2,0})
AADD(aDadTemp,{"GRPNAT"		,"C",10,0})

if select("TRBGRP")>0
	TRBGRP->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBGRP",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
//cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("TRBGRP",cIndex,"GRPCOD+GRPDES",,,"Selecionando Registro...")  
//IndRegua("TRBGRP",cIndex2,"GRPDES",,,"Selecionando Registro...")  

DbSelectArea("TRBGRP")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//--> FIM - Tabela temporária para o lado esquerdo

cQry+=" SELECT ACY_GRPVEN,ACY_DESCRI,ACY_P_COND,ACY_P_CCLI,ACY_P_LOJA,ACY_P_NAT FROM "+RETSQLNAME("ACY")
cQry+=" WHERE D_E_L_E_T_='' AND ACY_GRPVEN BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND ACY_P_ATIV='T'
cQry+=" ORDER BY ACY_GRPVEN
    
	if TCSQLExec(cQry) < 0
		MsgInfo(TCSQLError())
		Return(.F.)
    endif
    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0
		QRYTEMP->(DbGoTop())
		
		While QRYTEMP->(!EOF())
		
			RecLock("TRBGRP",.T.)
				TRBGRP->MARCA	:= "2" // Imagem sem creck
				TRBGRP->GRPCOD	:= QRYTEMP->ACY_GRPVEN
				TRBGRP->GRPDES	:= QRYTEMP->ACY_DESCRI
				TRBGRP->GRPSE4	:= QRYTEMP->ACY_P_COND
				TRBGRP->GRPCLI	:= QRYTEMP->ACY_P_CCLI
				TRBGRP->GRPLOJ	:= QRYTEMP->ACY_P_LOJA
				TRBGRP->GRPNAT	:= QRYTEMP->ACY_P_NAT
			TRBGRP->(MsUnlock())
			
			QRYTEMP->(DbSkip())
		Enddo
    else
    	lRet:=.F.
    endif
    
Return(lRet)

/*
Funcao      : TituloCli()
Parametros  : 
Retorno     : 
Objetivos   : Função que cria o temporário TRBTIT com os Títulos 
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-------------------------*
Static function TituloCli()
*-------------------------*
Local cQry	:= ""
Local lRet	:= .F.
//-->INICIO - Tabela temporária para o lado esquerdo
Local aDadTemp	:= {}


AADD(aDadTemp,{"TIT_GRUPO"	,"C",6,0})
AADD(aDadTemp,{"TIT_STATUS"	,"C",1,0})
AADD(aDadTemp,{"TIT_PREFIX"	,"C",TamSX3("E1_PREFIXO")[1],0})
AADD(aDadTemp,{"TIT_NUM"	,"C",TamSX3("E1_NUM")[1],0})
AADD(aDadTemp,{"TIT_PARCEL"	,"C",TamSX3("E1_PARCELA")[1],0})
AADD(aDadTemp,{"TIT_TIPO"	,"C",TamSX3("E1_TIPO")[1],0})
AADD(aDadTemp,{"TIT_CLIENT"	,"C",TamSX3("E1_CLIENTE")[1],0})
AADD(aDadTemp,{"TIT_LOJA"	,"C",TamSX3("E1_LOJA")[1],0})
AADD(aDadTemp,{"TIT_NOMCLI"	,"C",TamSX3("E1_NOMCLI")[1],0})
AADD(aDadTemp,{"TIT_EMISSA"	,"D",TamSX3("E1_EMISSAO")[1],0})
AADD(aDadTemp,{"TIT_VENCRE"	,"D",TamSX3("E1_VENCREA")[1],0})
AADD(aDadTemp,{"TIT_VALOR"	,"N",TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2]})
AADD(aDadTemp,{"R_E_C_N_O_"	,"N",6,0})

if select("TRBTIT")>0
	TRBTIT->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBTIT",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
//cIndex2	:=CriaTrab(Nil,.F.)
//cIndex3	:=CriaTrab(Nil,.F.)


IndRegua("TRBTIT",cIndex,"TIT_GRUPO+TIT_PREFIX+TIT_NUM+TIT_PARCEL+TIT_TIPO",,,"Selecionando Registro...")  
//IndRegua("TRBTIT",cIndex2,"TIT_CLIENT+TIT_LOJA+TIT_PREFIX+TIT_NUM+TIT_PARCEL+TIT_TIPO",,,"Selecionando Registro...")  
//IndRegua("TRBTIT",cIndex3,"TIT_GRUPO",,,"Selecionando Registro...")  

DbSelectArea("TRBTIT")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//DBREINDEX()
//DbSetIndex(cIndex2+OrdBagExt())
//DbSetOrder(2)

//--> FIM - Tabela temporária para o lado direito

	DbSelectArea("TRBGRP")
	TRBGRP->(DbSetOrder(1))
	TRBGRP->(DbGotop())
	
	While TRBGRP->(!EOF())
	
		cQry:=" SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_EMISSAO,E1_VENCREA,E1_VALOR,ACY.ACY_GRPVEN,ACY.ACY_DESCRI,SE1.R_E_C_N_O_
		cQry+=" FROM "+RETSQLNAME("SE1")+" SE1"
		cQry+=" LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
		cQry+=" LEFT JOIN "+RETSQLNAME("ACY")+" ACY ON ACY_GRPVEN = A1_GRPVEN 
		cQry+=" LEFT JOIN "+RETSQLNAME("SF2")+" SF2 ON SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.F2_FILIAL = SE1.E1_FILORIG AND SF2.F2_CLIENTE = SE1.E1_CLIENTE AND SF2.F2_LOJA = SE1.E1_LOJA
		cQry+=" WHERE E1_SALDO > 0
		cQry+=" AND 
		cQry+=" SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ACY.D_E_L_E_T_='' AND SF2.D_E_L_E_T_=''
		cQry+=" AND ACY.ACY_GRPVEN='"+TRBGRP->GRPCOD+"'
		cQry+=" AND E1_SITUACA IN ('0','F','G')
		cQry+=" AND E1_FATURA<>'NOTFAT'
		cQry+=" AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
		cQry+=" AND UPPER(F2_ESPECIE) IN ( 
			if MV_PAR05==1
				cQry+=" 'RPS'
			elseif MV_PAR05==2 //Telecomunicação
				cQry+=" 'NTST','NFSC'"
			elseif MV_PAR05==3  //Aluguel
				cQry+=" 'R'"
			else
				cQry+=" ''"
			endif
		cQry+=" )	
		cQry+=" ORDER BY E1_VENCREA
	    
		if TCSQLExec(cQry) < 0
			MsgInfo(TCSQLError())
			Return(.F.)
    	endif
	
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
	        
		if nRecCount >0
			QRYTEMP->(DbGoTop())
			
			While QRYTEMP->(!EOF())
			
				RecLock("TRBTIT",.T.)
					TRBTIT->TIT_GRUPO	:= QRYTEMP->ACY_GRPVEN
					TRBTIT->TIT_STATUS	:= "1" //aberto
					TRBTIT->TIT_PREFIX  := QRYTEMP->E1_PREFIXO
					TRBTIT->TIT_NUM     := QRYTEMP->E1_NUM
					TRBTIT->TIT_PARCEL	:= QRYTEMP->E1_PARCELA
					TRBTIT->TIT_TIPO    := QRYTEMP->E1_TIPO
					TRBTIT->TIT_CLIENT	:= QRYTEMP->E1_CLIENTE
					TRBTIT->TIT_LOJA	:= QRYTEMP->E1_LOJA
					TRBTIT->TIT_NOMCLI	:= QRYTEMP->E1_NOMCLI
					TRBTIT->TIT_EMISSA	:= STOD(QRYTEMP->E1_EMISSAO)
					TRBTIT->TIT_VENCRE	:= STOD(QRYTEMP->E1_VENCREA)
					TRBTIT->TIT_VALOR   := QRYTEMP->E1_VALOR
					TRBTIT->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
				TRBTIT->(MsUnlock())
				
				QRYTEMP->(DbSkip())
			Enddo

	    	lRet:=.T.
	    else
	    	//se não encontrou títulos no para o grupo, não apresentar o grupo
	    	RecLock("TRBGRP",.F.)
	    		TRBGRP->(DbDelete())
	    	TRBGRP->(MsUnlock())
	    endif
    
    	TRBGRP->(DbSkip())
    
    enddo
    
Return(lRet)

/*
Funcao      : BrowEsq()
Parametros  : 
Retorno     : 
Objetivos   : Função do browse de grupos de clientes
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-------------------------------------------------------------------------------------------------*
Static function BrowEsq()
*-------------------------------------------------------------------------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowseE DATA TABLE ALIAS "TRBGRP" OF oWinEB			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(MARCA=="1",'LBOK',iif(MARCA=="2",'LBNO','CHECKOK')) } DOUBLECLICK { |oBrowseE|  RecLock("TRBGRP",.F.), iif(MARCA=="1", MARCA:="2",iif(MARCA=="2",MARCA:="1",)) , TRBGRP->(MsUnlock())  /*Função que atualiza a regra*/ }  OF oBrowseE

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || GRPCOD		} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowseE		
ADD COLUMN oColumn DATA { || GRPDES    	} TITLE "Descrição"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowseE		
ADD COLUMN oColumn DATA { || GRPSE4    	} TITLE "Cond. Pagto"		DOUBLECLICK  {|| PesqSE4()	} 	ALIGN 1 SIZE 06 OF oBrowseE	

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowseE

Return(.T.)

/*
Funcao      : PesqSE4()
Parametros  : 
Retorno     : 
Objetivos   : Função que abre consulta padrão SE4
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-----------------------*
Static Function PesqSE4
*-----------------------*
Local cRetorno
Local lRet	:= .F.
Local cTab	:= "SE4"

//exibe uma tela de consulta padrão baseada no Dicionário de Dados
lRet:=CONPAD1(,,,cTab,cRetorno,,.F.  )

//Se clicou em ok
if lRet
	RecLock("TRBGRP",.F.)
		TRBGRP->GRPSE4:=SE4->E4_CODIGO
	TRBGRP->(MsUnlock())
endif

Return

/*
Funcao      : BrowDir()
Parametros  : 
Retorno     : 
Objetivos   : Função de browse da tela de títulos
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-------------------------------------------------------------------------------------------------*
Static function BrowDir()
*-------------------------------------------------------------------------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowseD DATA TABLE ALIAS "TRBTIT" OF oWinDB			

//Adiciona coluna para marcar e desmarcar
//ADD MARKCOLUMN 		oColumn DATA { || If(MARCA,'CHECKOK','LBNO') } DOUBLECLICK { |oBrowseD|  RecLock("TRBGRP",.F.),MARCA:=!MARCA, TRBGRP->(MsUnlock())  /*Função que atualiza a regra*/ }  OF oBrowseD

//Adiciona coluna para status
ADD STATUSCOLUMN oColumn DATA { || If(TIT_STATUS=="1",'BR_VERDE','BR_VERMELHO') } DOUBLECLICK { |oBrowseD| Legenda()/* Função executada no duplo clique na coluna*/ } OF oBrowseD

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || TIT_PREFIX	} TITLE "Prefixo"  			DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 03 OF oBrowseD
ADD COLUMN oColumn DATA { || TIT_NUM   	} TITLE "Número"			DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 09 OF oBrowseD		
ADD COLUMN oColumn DATA { || TIT_PARCEL	} TITLE "Parcela"			DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 01 OF oBrowseD	
ADD COLUMN oColumn DATA { || TIT_TIPO	} TITLE "Tipo"				DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 03 OF oBrowseD	
ADD COLUMN oColumn DATA { || TIT_CLIENT	} TITLE "Cliente"			DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 06 OF oBrowseD	
ADD COLUMN oColumn DATA { || TIT_LOJA	} TITLE "Loja"				DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 02 OF oBrowseD	
ADD COLUMN oColumn DATA { || TIT_NOMCLI	} TITLE "Nome"				DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 20 OF oBrowseD	
ADD COLUMN oColumn DATA { || TIT_EMISSA	} TITLE "Emissão"			DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 10 OF oBrowseD	
ADD COLUMN oColumn DATA { || TIT_VENCRE	} TITLE "Vencto"			DOUBLECLICK  {|| WaitAxVi("SE1",TRBTIT->R_E_C_N_O_) }	ALIGN 1 SIZE 10 OF oBrowseD	
ADD COLUMN oColumn DATA { || Transform(TIT_VALOR,'@E 99,999,999,999.99') } TITLE "Valor"				DOUBLECLICK  {|| 			}	ALIGN 2 SIZE 17 OF oBrowseD


// Ativação do Browse	
ACTIVATE FWBROWSE oBrowseD

Return(.T.)


/*
Funcao      : Relacao()  
Parametros  : 
Retorno     : 
Objetivos   : Seta a relação do browse esquerdo com o browse direito
Autor       : Matheus Massarotto
Data/Hora   : 27/01/2015
*/
*-----------------------------------------*
Static function Relacao()
*-----------------------------------------*

oRelac:=FWBrwRelation():New()
oRelac:AddRelation( @oBrowseE , @oBrowseD , { { 'TIT_GRUPO','GRPCOD' } } )
oRelac:Activate()

Return

/*
Funcao      : Barpross()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 16/05/2013	15:14
*/
*-------------------------------------------------------------------------------------------------------------------*
Static Function Barpross()
*-------------------------------------------------------------------------------------------------------------------*
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.
Local nTamBar	:= TRBGRP->(RecCount()) * TRBTIT->(RecCount())

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTamBar,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=Process(oMeter,oDlg1))
	  
	//***********************************************************

Return(lRet)

/*
Funcao      : Process()
Parametros  : 
Retorno     : 
Objetivos   : Função percorrer os títulos por grupo e chamar a rotina de baixa/geração fatura
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2013	17:10
*/
*-------------------------------------*
Static Function Process(oMeter,oDlg1)
*-------------------------------------*

//Inicia a régua
oMeter:Set(0)

    DbSelectArea("TRBGRP")
    TRBGRP->(DbSetOrder(1))
    TRBGRP->(DbGoTop())
    
    While TRBGRP->(!EOF())

  		//Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) +1 // pega valor corrente da régua + 1
  		oMeter:Set(nCurrent) //seta o valor na régua
	    
	    if TRBGRP->MARCA=="1"
	    	nValor	:= 0
	    	aMark	:= {}
	    	
	    	//Percorre o temporário com os títulos para carregar o array com os títulos que precisam gerar a fatura
	    	DbSelectArea("TRBTIT")
	    	TRBTIT->(DbSetOrder(1))
	    	TRBTIT->(DbGoTop())
	    	if DbSeek(TRBGRP->GRPCOD)
	    		While TRBTIT->(!EOF()) .AND. TRBTIT->TIT_GRUPO == TRBGRP->GRPCOD
	    				AADD(aMark,TRBTIT->R_E_C_N_O_)
	    				nValor+=TRBTIT->TIT_VALOR
	    			TRBTIT->(DbSkip())
	    		
	    			//Processamento da régua
					nCurrent:= Eval(oMeter:bSetGet) +1 // pega valor corrente da régua + 1
		  			oMeter:Set(nCurrent) //seta o valor na régua
	    		
	    		Enddo
	    	endif
	    	
			if !empty(aMark)
			    if BxGeFat()
			    	RecLock("TRBGRP",.F.)
			    		TRBGRP->MARCA:="3"		
	    			TRBGRP->(MsUnlock())
			    endif
		    endif
	    
	    endif
	    
    	TRBGRP->(DbSkip())
    Enddo

//Encerra a barra
oDlg1:end()

Return(.T.)


/*
Funcao      : Legenda()  
Parametros  : 
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 28/01/2015
*/
*-----------------------------*
Static Function Legenda()
*-----------------------------*
Local aLegenda:={}

aLegenda := {	{"BR_VERDE"  	,"Título aberto				" },;
				{"BR_VERMELHO"  ,"Título baixado			" }}

BrwLegenda("Legenda","Legenda",aLegenda)

Return


/*
Funcao      : WaitAxVi()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 28/01/2015	15:14
*/
*-------------------------------------------------*
Static Function WaitAxVi(cAlias,nReg)
*-------------------------------------------------*
Local oDlg2
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg2 TITLE "Abrindo..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg2,70,34,,.T.,,,,,,,,,)
	    
	  ACTIVATE DIALOG oDlg2 CENTERED ON INIT(lRet:=Visual(cAlias,nReg,oMeter,oDlg2))
	  
	//*************************************

Return(lRet)

/*
Funcao      : Visual()
Parametros  : 
Retorno     : 
Objetivos   : Função para visualizar o resgistro posicionado
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	11:10
*/
*------------------------------------------------------------*
Static Function Visual(cAlias,nReg,oMeter,oDlg2)
*------------------------------------------------------------*
Local nOpc		:= 2
Local lMaximized:= .T.
Local aArea 	:= GetArea() 

Private	cCadastro:= "Título a receber" //Variavel q é responsável pelo título da dialog do AXVISUAL

//Inicia a régua
oMeter:Set(0)
oMeter:Set(98) //posiciona no fim da regua

	&(cAlias)->(DbGoTo(nReg))
	AXVISUAL(cAlias, nReg, nOpc, , , , , , lMaximized )

oDlg2:end()

RestArea(aArea)
Return
