#include 'totvs.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GTCTB001  ∫Autor  ≥Eduardo C. Romanini ∫ Data ≥  13/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥RelatÛrio de Raz„o Cont·bil Customizado.                    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Grant Thornton                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
*-----------------------*
User Function GTCTB001() 
*-----------------------*
Local lOk := .F.
Local cPerg := "GTCTB001"

Private cDataDe    := ""
Private cDataAte   := ""
Private cContaDe   := ""
Private cContaAte  := ""
Private cNomeArq   := ""
Private lAbreExcel := .F.
Private cMoeda     := ""
Private lSemMov    := .F.
Private lImpSld    := .F.
Private lCCusto    := .F.
Private cCCDe      := ""
Private cCCAte     := ""
Private lItCont    := .F.
Private cItemDe    := ""
Private cItemAte   := ""
Private cDescMoe   := ""
Private lNumNFS    := .T.

//Verifica os par‚metros do relatÛrio
AjustaSX1(cPerg)
If Pergunte(cPerg,.T.)
	//Grava os par‚metros
	cDataDe   := DtoS(mv_par01)
	cDataAte  := DtoS(mv_par02)
	cContaDe  := mv_par03
	cContaAte := mv_par04
	cNomeArq  := mv_par05
	lAbreExcel:= If(mv_par06==2,.F.,.T.)
	cMoeda    := mv_par07
	lSemMov   := If(mv_par08==2,.F.,.T.)
	lImpSld   := If(mv_par08==3,.T.,.F.)
	lCCusto   := If(mv_par09==2,.F.,.T.)
	cCCDe     := mv_par10
	cCCAte    := mv_par11
	lItCont   := If(mv_par12==2,.F.,.T.)
	cItemDe   := mv_par13
	cItemAte  := mv_par14
	cDescMoe  := mv_par15
	lNumNFS   := If(mv_par16==2,.F.,.T.)
	//lSaldo    := msgYesNo("Deseja calcular o saldo?")
	lSaldo    := .T.
             
	//Busca as empresas a serem impressas
	aEmpresas := TelaEmp()

	//Gera o RelatÛrio
	If LEN(aEmpresas) <> 0
		lOk := GeraRel(aEmpresas)
		If !lOk
			MsgInfo("N„o foram encontrados registros para os par‚metros informados.","AtenÁ„o")
			Return Nil
		EndIf
	EndIf                                              	
EndIf

Return Nil                           

/*
FunÁ„o  : GeralRel
Objetivo: Gera o relatÛrio
Autor   : Eduardo C. Romanini
Data    : 13/05/2013
*/
*--------------------------------*
Static Function GeraRel(aEmpresas)
*--------------------------------*
Local i
Local lGrvDados := .F.
Local cArqTrab := ""

//Cria a tabela tempor·ria para impress„o dos registros.
cArqTrab := CriaArqTrab()

//Grava os Dados na tabela tempor·ria
If !Empty(cArqTrab)
	lGrvDados := GravaMain(aEmpresas)
EndIf

If lGrvDados
	ImpRel()//Imprime o relatÛrio
EndIf

Return lGrvDados

/*
FunÁ„o  : CriaArqTrab
Objetivo: Cria a tabela tempor·ria que ser· utilizada para a impress„o.
Autor   : Eduardo C. Romanini
Data    : 20/05/2013
*/
*---------------------------*
Static Function CriaArqTrab()
*---------------------------*
Local cArqTrab := ""
Local cIndex   := ""
Local aStru := {}

//Cria a tabela tempor·ria
aAdd(aStru,{"EMP"   ,"C",002,0})
aAdd(aStru,{"FIL"   ,"C",002,0})
aAdd(aStru,{"CONTA" ,"C",020,0})
aAdd(aStru,{"DESCR" ,"C",040,0})
aAdd(aStru,{"DTLANC","D",008,0})
aAdd(aStru,{"CPART" ,"C",020,0})
aAdd(aStru,{"HIST"  ,"C",250,0})
aAdd(aStru,{"DOC"   ,"C",020,0})
aAdd(aStru,{"DEBIT" ,"N",017,2})
aAdd(aStru,{"CREDIT","N",017,2})
aAdd(aStru,{"CCUSTO","C",009,0})
aAdd(aStru,{"ITCONT","C",009,0})
aAdd(aStru,{"F2_DOC","C",009,0})

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o Ìndice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"CONTA+DTOS(DTLANC)+DOC",,,"Selecionando Registro...")

DbSelectArea("REL")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

Return cArqTrab

/*
FunÁ„o  : GravaMain()
Objetivo: Realiza a gravaÁ„o dos dados na tabela tempor·ria.
Autor   : Jean Victor Rocha
Data    : 15/05/2017
*/
*----------------------------------*
Static Function GravaMain(aEmpresas)
*----------------------------------*
Local lDados := .F.
Local lDadosAux := .F.

Private cCdEmpAtual := ""

For i:=1 to Len(aEmpresas)
	cCdEmpAtual := aEmpresas[i]
	Processa({|| lDadosAux := GravaDados()},"Gerando o relatÛrio empresa "+cCdEmpAtual+"...")
	If lDadosAux
		lDados := .T.
	EndIf
Next i

Return lDados

/*
FunÁ„o  : GravaDados()
Objetivo: Realiza a gravaÁ„o dos dados na tabela tempor·ria.
Autor   : Eduardo C. Romanini
Data    : 13/05/2013
*/
*--------------------------*
Static Function GravaDados()
*--------------------------*
Local lRet := .F.
Local cConta     := ""
Local cDescr     := ""
Local cCPart     := ""
Local cHist      := ""
Local cDoc       := ""
Local cLinha     := ""
Local cCCusto    := ""
Local cItCont    := "" 
Local cQryDebit  := ""
Local cQryCredit := ""
Local nVlDeb  := 0
Local nVlCre  := 0
Local dData := CtoD("  /  /  ")

//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf

//Imprime as contas sem movimentaÁ„o.
If lSemMov
	cQryDebit := " ( SELECT CT2_DEBITO" 
	cQryDebit += "	  FROM " +RetTabName("CT2")
	cQryDebit += "	  WHERE D_E_L_E_T_ <> '*'"
	cQryDebit += "		AND CT2_MOEDLC = '"+cMoeda+"'"
	cQryDebit += "		AND CT2_DATA >= '"+cDataDe+"'"
	cQryDebit += "		AND CT2_DATA <= '"+cDataAte+"'"
	cQryDebit += "		AND CT2_DEBITO >= '"+cContaDe+"'"
	cQryDebit += "		AND CT2_DEBITO <= '"+cContaAte+"'"
	cQryDebit += "		AND CT2_DEBITO <> ''"
	cQryDebit += "	  GROUP BY CT2_DEBITO) "
    
	cQryCredit := " ( SELECT CT2_CREDIT" 
	cQryCredit += "	  FROM " +RetTabName("CT2")
	cQryCredit += "	  WHERE D_E_L_E_T_ <> '*'"
	cQryCredit += "		AND CT2_MOEDLC = '"+cMoeda+"'"
	cQryCredit += "		AND CT2_DATA >= '"+cDataDe+"'"
	cQryCredit += "		AND CT2_DATA <= '"+cDataAte+"'"
	cQryCredit += "		AND CT2_CREDIT >= '"+cContaDe+"'"
	cQryCredit += "		AND CT2_CREDIT <= '"+cContaAte+"'"
	cQryCredit += "		AND CT2_CREDIT <> ''"
	cQryCredit += "	  GROUP BY CT2_CREDIT) "

	
	cQry := " SELECT CT1_CONTA, CT1_DESC01,CT1_DESC02,CT1_DESC03,CT1_DESC04
	cQry += " FROM "+RetTabName("CT1")
	cQry += " WHERE D_E_L_E_T_ <> '*'
	cQry += " 		AND CT1_CLASSE = '2'
	cQry += " 		AND CT1_CONTA >= '"+cContaDe+"'
	cQry += " 		AND CT1_CONTA <= '"+cContaAte+"'
	cQry += " 		AND CT1_CONTA NOT IN "+cQryDebit
	cQry += " 		AND CT1_CONTA NOT IN "+cQryCredit
	cQry += " ORDER BY CT1_CONTA
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),'TMPCT1',.T.,.T.)

	TMPCT1->(DbGoTop())
	While TMPCT1->(!EOF())
    	If lImpSld
    		If RetSaldo(TMPCT1->CT1_CONTA,StoD(cDataDe)) == 0
    			TMPCT1->(DbSkip())
    			Loop
    		EndIf
    	EndIf
    	
		//Grava o arquivo tempor·rio.
		REL->(DbAppend())
		REL->CONTA  := TMPCT1->CT1_CONTA
		REL->DESCR  := &("TMPCT1->CT1_DESC"+AllTrim(cDescMoe))
		REL->(MSUnlock())    

		TMPCT1->(DbSkip())		
	EndDo
EndIf

If Select('TMPCOUNT') > 0
	TMPCOUNT->(DbCloseArea())
EndIf

cQry := " SELECT COUNT(*) AS REGISTROS
cQry += " FROM "+RetTabName("CT2")+" CT2
cQry += " WHERE CT2.D_E_L_E_T_ <> '*'
cQry += "	AND CT2.CT2_DC <> '4'
cQry += "	AND CT2.CT2_DATA >= '"+cDataDe+"'
cQry += "	AND CT2.CT2_DATA <= '"+cDataAte+"'
cQry += "	AND CT2.CT2_MOEDLC = '"+cMoeda+"'
cQry += "	AND ((CT2.CT2_DEBITO between '"+cContaDe+"' and '"+cContaAte+"') or (CT2.CT2_CREDIT between '"+cContaDe+"' and '"+cContaAte+"')) 
cQry += "	AND ((CT2.CT2_CCD between '"+cCCDe+"' and '"+cCCAte+"') or (CT2.CT2_CCC between '"+cCCDe+"' and '"+cCCAte+"'))
cQry += "	AND ((CT2.CT2_ITEMD between '"+cITemDe+"' and '"+cITemAte+"') or (CT2.CT2_ITEMC between '"+cITemDe+"' and '"+cITemAte+"'))

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),'TMPCOUNT',.T.,.T.)
      
ProcRegua( TMPCOUNT->REGISTROS )

If Select("TMPCT2") > 0
	TMPCT2->(DbCloseArea())
EndIf

cQry := " SELECT CT2.CT2_FILIAL, CT2.CT2_DATA, CT2.CT2_LOTE, CT2.CT2_SBLOTE, CT2.CT2_DOC, CT2.CT2_LINHA, CT2.CT2_DC,
cQry += "		CT2.CT2_DEBITO, CT2.CT2_CREDIT, CT2.CT2_VALOR, CT2.CT2_HIST, CT2.CT2_CCD, CT2.CT2_CCC,
cQry += "       CT2.CT2_ITEMC, CT2.CT2_ITEMD, CT2.CT2_SEQUEN, CT2.CT2_SEQLAN,
cQry += "		CT1CD.CT1_DESC01 as CDDESC01,CT1CD.CT1_DESC02 as CDDESC01,CT1CD.CT1_DESC03 as CDDESC03,CT1CD.CT1_DESC04 as CDDESC04,CT1CD.CT1_DESC05 as CDDESC05,
cQry += "		CT1CC.CT1_DESC01 as CCDESC01,CT1CC.CT1_DESC02 as CCDESC02,CT1CC.CT1_DESC03 as CCDESC03,CT1CC.CT1_DESC04 as CCDESC04,CT1CC.CT1_DESC05 as CCDESC05,
cQry += "		CT2.CT2_KEY
cQry += "	FROM "+RetTabName("CT2")+" CT2
cQry += "		left Outer join "+RetTabName("CT1")+" as CT1CD on CT1CD.D_E_L_E_T_ <> '*' AND CT1CD.CT1_CONTA = CT2.CT2_DEBITO
cQry += "   	left Outer join "+RetTabName("CT1")+" as CT1CC on CT1CC.D_E_L_E_T_ <> '*' AND CT1CC.CT1_CONTA = CT2.CT2_CREDIT
cQry += "	WHERE CT2.D_E_L_E_T_ <> '*'
cQry += "	  AND CT2.CT2_DC <> '4'
cQry += "	  AND CT2.CT2_DATA >= '"+cDataDe+"'
cQry += "	  AND CT2.CT2_DATA <= '"+cDataAte+"'
cQry += "	  AND CT2.CT2_MOEDLC = '"+cMoeda+"'
cQry += "	  AND ((CT2.CT2_DEBITO between '"+cContaDe+"' and '"+cContaAte+"') or (CT2.CT2_CREDIT between '"+cContaDe+"' and '"+cContaAte+"'))           
cQry += "     AND ((CT2.CT2_CCD between '"+cCCDe+"' and '"+cCCAte+"')or (CT2.CT2_CCC between '"+cCCDe+"' and '"+cCCAte+"'))
cQry += "     AND ((CT2.CT2_ITEMD between '"+cITemDe+"' and '"+cITemAte+"') or (CT2.CT2_ITEMC between '"+cITemDe+"' and '"+cITemAte+"'))
cQry += "	ORDER BY CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA                                                                               

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),'TMPCT2',.T.,.T.)

//Looping nos registros
TMPCT2->(DbGoTop())
If TMPCT2->(!EOF())
	lRet  := .T.
	countWhile := 0
	While TMPCT2->(!EOF())
		countWhile ++
		IncProc(ALLTRIM(STR(countWhile))+"/"+ALLTRIM(STR(TMPCOUNT->REGISTROS))+" Processando...")
		cDescr := ""
		cHist  := ""
		If AllTrim(TMPCT2->CT2_DC) == "1" //Debito
			//Busca a descriÁ„o da conta
			cDescr := &("TMPCT2->CDDESC"+AllTrim(cDescMoe))
			cHist := AllTrim(TMPCT2->CT2_HIST)
			//Busca o histÛrico
			cHist += getHist(TMPCT2->CT2_FILIAL+TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC),;
							AllTrim(TMPCT2->CT2_SEQUEN),;
							AllTrim(TMPCT2->CT2_SEQLAN))
			    
			//Grava o arquivo tempor·rio.
			REL->(RecLock("REL",.T.))
			REL->EMP	:= cCdEmpAtual
			REL->FIL    := TMPCT2->CT2_FILIAL
			REL->CONTA  := AllTrim(TMPCT2->CT2_DEBITO)
			REL->DESCR  := AllTrim(cDescr)
			REL->DTLANC := StoD(TMPCT2->CT2_DATA)
			REL->CPART  := ""
			REL->HIST   := cHist
			REL->DOC    := AllTrim(TMPCT2->CT2_LOTE)+AllTrim(TMPCT2->CT2_SBLOTE)+AllTrim(TMPCT2->CT2_DOC)+AllTrim(TMPCT2->CT2_LINHA)
			REL->DEBIT  := TMPCT2->CT2_VALOR
			REL->CREDIT := 0
			REL->CCUSTO := AllTrim(TMPCT2->CT2_CCD)
			REL->ITCONT := AllTrim(TMPCT2->CT2_ITEMD)
			If lNumNFS .and. !EMPTY(TMPCT2->CT2_KEY)
				REL->F2_DOC := getNFS(TMPCT2->CT2_KEY)
			EndIf
			REL->(MSUnlock())

		ElseIf AllTrim(TMPCT2->CT2_DC) == "2" //Credito		   
			//Busca a descriÁ„o da conta
			cDescr := &("TMPCT2->CCDESC"+AllTrim(cDescMoe))
			cHist := AllTrim(TMPCT2->CT2_HIST)
			//Busca o histÛrico
			cHist += getHist(TMPCT2->CT2_FILIAL+TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC),;
							AllTrim(TMPCT2->CT2_SEQUEN),;
							AllTrim(TMPCT2->CT2_SEQLAN))

			//Grava o arquivo tempor·rio.
			REL->(RecLock("REL",.T.))
			REL->EMP	:= cCdEmpAtual
			REL->FIL    := TMPCT2->CT2_FILIAL
			REL->CONTA  := AllTrim(TMPCT2->CT2_CREDIT)
			REL->DESCR  := AllTrim(cDescr)
			REL->DTLANC := StoD(TMPCT2->CT2_DATA)
			REL->CPART  := ""
			REL->HIST   := cHist
			REL->DOC    := AllTrim(TMPCT2->CT2_LOTE)+AllTrim(TMPCT2->CT2_SBLOTE)+AllTrim(TMPCT2->CT2_DOC)+AllTrim(TMPCT2->CT2_LINHA)
			REL->DEBIT  := 0
			REL->CREDIT := TMPCT2->CT2_VALOR
			REL->CCUSTO := AllTrim(TMPCT2->CT2_CCC)
			REL->ITCONT := AllTrim(TMPCT2->CT2_ITEMC)
			If lNumNFS .and. !EMPTY(TMPCT2->CT2_KEY)
				REL->F2_DOC := getNFS(TMPCT2->CT2_KEY)
			EndIf
			REL->(MSUnlock())

		ElseIf AllTrim(TMPCT2->CT2_DC) == "3" //Partida Dobrada
			///////////////////////////////
			//Inicia a gravaÁ„o do debito//
			///////////////////////////////
			If AllTrim(TMPCT2->CT2_DEBITO) >= AllTrim(cContaDe) .and. AllTrim(TMPCT2->CT2_DEBITO) <= AllTrim(cContaAte)
				//Busca a descriÁ„o da conta
				cDescr := &("TMPCT2->CDDESC"+AllTrim(cDescMoe))
				cHist := AllTrim(TMPCT2->CT2_HIST)
				//Busca o histÛrico
				cHist += getHist(TMPCT2->CT2_FILIAL+TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC),;
								AllTrim(TMPCT2->CT2_SEQUEN),;
								AllTrim(TMPCT2->CT2_SEQLAN))

				//Grava o arquivo tempor·rio.
				REL->(RecLock("REL",.T.))
				REL->EMP	:= cCdEmpAtual
				REL->FIL    := TMPCT2->CT2_FILIAL
				REL->CONTA  := AllTrim(TMPCT2->CT2_DEBITO)
				REL->DESCR  := AllTrim(cDescr)
				REL->DTLANC := StoD(TMPCT2->CT2_DATA)
				REL->CPART  := AllTrim(TMPCT2->CT2_CREDIT)
				REL->HIST   := AllTrim(TMPCT2->CT2_HIST)
				REL->DOC    := AllTrim(TMPCT2->CT2_LOTE)+AllTrim(TMPCT2->CT2_SBLOTE)+AllTrim(TMPCT2->CT2_DOC)+AllTrim(TMPCT2->CT2_LINHA)
				REL->DEBIT  := TMPCT2->CT2_VALOR
				REL->CREDIT := 0
				REL->CCUSTO := AllTrim(TMPCT2->CT2_CCD)
				REL->ITCONT := AllTrim(TMPCT2->CT2_ITEMD)
				If lNumNFS .and. !EMPTY(TMPCT2->CT2_KEY)
					REL->F2_DOC := getNFS(TMPCT2->CT2_KEY)
				EndIf
				REL->(MSUnlock())
			EndIf             

			////////////////////////////////
			//Inicia a gravaÁ„o do crÈdito//
			////////////////////////////////
			If AllTrim(TMPCT2->CT2_CREDIT) >= AllTrim(cContaDe) .and. AllTrim(TMPCT2->CT2_CREDIT) <= AllTrim(cContaAte)
			   	//Busca a descriÁ„o da conta
				cDescr := &("TMPCT2->CCDESC"+AllTrim(cDescMoe))
				cHist := AllTrim(TMPCT2->CT2_HIST)
				//Busca o histÛrico
				cHist += getHist(TMPCT2->CT2_FILIAL+TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC),;
								AllTrim(TMPCT2->CT2_SEQUEN),;
								AllTrim(TMPCT2->CT2_SEQLAN))
	
				//Grava o arquivo tempor·rio.
				REL->(RecLock("REL",.T.))
				REL->EMP	:= cCdEmpAtual
				REL->FIL    := TMPCT2->CT2_FILIAL
				REL->CONTA  := AllTrim(TMPCT2->CT2_CREDIT)
				REL->DESCR  := AllTrim(cDescr)
				REL->DTLANC := StoD(TMPCT2->CT2_DATA)
			 	REL->CPART  := AllTrim(TMPCT2->CT2_DEBITO)
				REL->HIST   := AllTrim(TMPCT2->CT2_HIST)
				REL->DOC    := AllTrim(TMPCT2->CT2_LOTE)+AllTrim(TMPCT2->CT2_SBLOTE)+AllTrim(TMPCT2->CT2_DOC)+AllTrim(TMPCT2->CT2_LINHA)
				REL->DEBIT  := 0
				REL->CREDIT := TMPCT2->CT2_VALOR
				REL->CCUSTO := AllTrim(TMPCT2->CT2_CCC)
				REL->ITCONT := AllTrim(TMPCT2->CT2_ITEMC)
				If lNumNFS .and. !EMPTY(TMPCT2->CT2_KEY)
					REL->F2_DOC := getNFS(TMPCT2->CT2_KEY)
				EndIf
				REL->(MSUnlock())
			EndIf	   
		EndIf

		TMPCT2->(DbSkip())	
	EndDo
EndIf

If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf
TMPCT2->(DbCloseArea())

Return lRet

/*
Funcao  : ImpRel()
Objetivo: Imprime o relatÛrio
Autor   : Eduardo C. Romanini
Data    : 20/05/2013
*/                   
*----------------------*
Static Function ImpRel()
*----------------------*
Local cConta   := ""
Local cTpAnt   := ""
Local cTpAtu   := ""
Local nSldAnt := 0
Local nSldAtu := 0
Local aAux  := {}
Local oExcel

//cEmpName := AllTrim(SM0->M0_NOMECOM)
cEmpName := ""

//Gera o cabeÁalho da planilha
oExcel := FWMSEXCEL():New()

oExcel:SetFont("Verdana")
oExcel:SetFontSize(8)
oExcel:SetBgGeneralColor("#FCFCFC")
oExcel:SetBgColorHeader("#666666")
oExcel:Set2LineBgColor("#E1E1E1")
oExcel:SetFrColorHeader("#FFFFFF")

oExcel:AddWorkSheet("Par‚metros")
oExcel:AddTable ("Par‚metros","Par‚metros - Raz„o Cont·bil")

oExcel:AddColumn("Par‚metros","Par‚metros - Raz„o Cont·bil","Par‚metro",1,1,.F.)
oExcel:AddColumn("Par‚metros","Par‚metros - Raz„o Cont·bil","Valor",1,1,.F.)

//oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Empresa: ", cEmpName})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Data Inicial: ", DtoC(StoD(cDataDe))})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Data Final: ", DtoC(StoD(cDataAte))})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Data Emiss„o: ", DtoC(dDataBase)})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Hora Emiss„o: ", Time()})

oExcel:AddWorkSheet("Razao") 
oExcel:AddTable ("Razao","Razao Contabil - Empresa: "+cEmpName)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"CÛd. Empresa",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"CÛd. Filial",1,1,.F.) 
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Nome Empresa",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Nome Filial",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Conta (AnalÌtica)",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Nome Conta",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Data",2,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Contra Partida",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"HistÛrico",1,1,.F.)
If lNumNFS
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"N˙m. NFS",1,1,.F.)
EndIf
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Documento",1,1,.F.)
If lCCusto
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"C.Custo.",1,1,.F.)
EndIf
If lItCont
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"It.Cont.",1,1,.F.)
EndIf
If lSaldo
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Saldo Anterior",3,2,.F.)
EndIf
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Tipo",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"DÈbitos",3,2,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"CrÈditos",3,2,.F.)
If lSaldo
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Saldo Atual",3,2,.F.)
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+cEmpName,"Tipo",1,1,.F.)
EndIf
   
REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF())
	If EMPTY(REL->EMP)
   		REL->(DbSkip())
		Loop
	EndIf
                            
	If lSaldo
		If cConta == REL->CONTA
	 		nSldAnt := nSldAtu
		Else
			If Empty(DtoS(REL->DTLANC))
				nSldAnt := RetSaldo(REL->CONTA,StoD(cDataDe),REL->EMP)
			Else
				nSldAnt := RetSaldo(REL->CONTA,REL->DTLANC,REL->EMP)
			EndIf
		EndIf

		If REL->CREDIT > 0
	    	nSldAtu := nSldAnt - REL->CREDIT 	
	    Else
	     	nSldAtu := nSldAnt + REL->DEBIT	
		EndIf	       
		If nSldAnt > 0
			cTpAnt := "D"
		ElseIf nSldAnt < 0
			cTpAnt := "C"	        
		Else
			cTpAnt := ""
		EndIf
		If nSldAtu > 0
			cTpAtu := "D"
		ElseIf nSldAtu < 0
			cTpAtu := "C"	        
		Else
			cTpAtu := ""
		EndIf
	EndIf
	
	If lNumNFS
		If lSaldo
			If lItCont .and. lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,REL->CCUSTO,REL->ITCONT,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}
			ElseIf lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,REL->CCUSTO,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}	
			ElseIf lItCont
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,REL->ITCONT,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}
			Else
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}
			EndIf
		Else
			If lItCont .and. lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,REL->CCUSTO,REL->ITCONT,cTpAnt,REL->DEBIT,REL->CREDIT}
			ElseIf lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,REL->CCUSTO,cTpAnt,REL->DEBIT,REL->CREDIT}	
			ElseIf lItCont
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,REL->ITCONT,cTpAnt,REL->DEBIT,REL->CREDIT}
			Else
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->F2_DOC,REL->DOC,cTpAnt,REL->DEBIT,REL->CREDIT}
			EndIf		
		EndIf
	Else
		If lSaldo
			If lItCont .and. lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->CCUSTO,REL->ITCONT,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}
			ElseIf lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->CCUSTO,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}	
			ElseIf lItCont
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->ITCONT,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}
			Else
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu}
			EndIf
		Else
			If lItCont .and. lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->CCUSTO,REL->ITCONT,cTpAnt,REL->DEBIT,REL->CREDIT}
			ElseIf lCCusto
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->CCUSTO,cTpAnt,REL->DEBIT,REL->CREDIT}	
			ElseIf lItCont
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->ITCONT,cTpAnt,REL->DEBIT,REL->CREDIT}
			Else
				aAux := {REL->EMP,REL->FIL,FWEmpName(REL->EMP),FWFilName(REL->EMP,REL->FIL),REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,cTpAnt,REL->DEBIT,REL->CREDIT}
			EndIf		
		EndIf
	
	EndIf
	oExcel:AddRow("Razao","Razao Contabil - Empresa: "+cEmpName,aAux)
	cConta  := REL->CONTA
	
	REL->(DbSkip())
EndDo
	
//Gera o arquivo xml usado no excel
oExcel:Activate()

//Abre o excel
AbreExcel(oExcel)

Return

/*
Funcao  : AbreExcel()
Objetivo: FunÁ„o para abrir o excel
Autor   : Eduardo C. Romanini
Data    : 13/05/2013
*/                   
*-------------------------------*
Static Function AbreExcel(oExcel)
*-------------------------------*
Local cArq:= AllTrim(cNomeArq)

If FILE (cArq)
	FERASE (cArq)
EndIf

oExcel:GetXMLFile(cArq) // Gera o arquivo em Excel

If lAbreExcel	
	SHELLEXECUTE("open",(cArq),"","",5)   // Abre o arquivo em Excel
Else
	MsgInfo("O relatÛrio foi gerado com sucesso.","AtenÁ„o")
EndIf

Return

/*
Funcao  : RetSaldo()
Objetivo: Retorna o saldo anterior da conta,
          baseado na data de lanÁamento.
Autor   : Eduardo C. Romanini
Data    : 15/05/2013
*/  
*----------------------------------------------*
Static Function RetSaldo(cConta,dDtLanc,cCodEmp)
*----------------------------------------------*
Local nRet   := 0
Local nVlCre := 0
Local nVlDeb := 0
Local cDtLanc := DtoS(dDtLanc)

Default cCodEmp := ""

If !EMPTY(cCodEmp) .and. Type("cCdEmpAtual") <> "C"
	Private cCdEmpAtual := cCodEmp
ElseIf EMPTY(cCodEmp)
	conout("GTCTB001 - cCodEmp em branco")
EndIf

If Select("TMPCT7") > 0
	TMPCT7->(DbCloseArea())
EndIf
                         
cQry := " SELECT TOP 1 CT7_ATUCRD,CT7_ATUDEB
cQry += " FROM "+RetTabName("CT7")
cQry += " WHERE D_E_L_E_T_ <> '*'
cQry += " 		AND CT7_MOEDA = '"+cMoeda+"'
cQry += " 		AND CT7_CONTA = '"+cConta+"'
cQry += " 		AND CT7_DATA < '"+cDtLanc+"'
cQry += " ORDER BY CT7_DATA DESC

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),'TMPCT7',.T.,.T.)

TMPCT7->(DbGoTop())
If TMPCT7->(!EOF())
	nVlCre := TMPCT7->CT7_ATUCRD
	nVlDeb := TMPCT7->CT7_ATUDEB
EndIf

nRet := nVlDeb - nVlCre

Return nRet 

/*
FunÁ„o  : AjustaSX1
Objetivo: Verificar se os parametros est„o criados corretamente.
Autor   : Eduardo C. Romanini
Data    : 13/05/2013
*/
*------------------------------*
Static Function AjustaSx1(cPerg)
*------------------------------*
Local lAjuste := .F.
Local nI := 0
Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Data De ?"            },;
  					{"02","Data Ate ?"           },;
  					{"03","Da Conta ?"           },;
  					{"04","Ate Conta ?"          },;
  					{"05","Arquivo?"             },;
  					{"06","Abre Excel ?"         },;
  					{"07","Moeda ?"              },;
  					{"08","Impr. Cta S/ Movim ?" },;
  					{"09","Imprime C. Custo ?"   },;
  					{"10","Do Centro Custo ?"    },;
  					{"11","Ate Centro Custo ?"   },;
  					{"12","Imprime Item Contab ?"},;
  					{"13","Do Item Contabil ?"   },;
  					{"14","Ate Item Contabil ?"  },;
  					{"15","DescriÁ„o na Moeda ?" },;
  					{"16","Busca NFS ?" 		 }}

//Verifica se o SX1 est· correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste
    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)
			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja o relatÛrio.") 
	PutSx1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatÛrio.")
	PutSx1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	PutSx1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final atÈ a qual")
	Aadd( aHlpPor, "se desej· imprimir o relatÛrio.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	PutSx1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"ser· ser· gerado.")
	PutSx1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\GTCTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo ser· aberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	PutSx1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatÛrio.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	PutSx1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir ou n„o as")
	Aadd( aHlpPor, "contas sem movimento.")      
	Aadd( aHlpPor, "'Sim' - Imprime contas mesmo sem saldo ")
	Aadd( aHlpPor, "ou movimento.")   
	Aadd( aHlpPor, "'Nao' - Imprime somente contas com ")
	Aadd( aHlpPor, "movimento no periodo.   ")   
	Aadd( aHlpPor, "'Nao c/ Sld.Ant.' - Imprime somente  ")
	Aadd( aHlpPor, "contas com movimento ou com saldo")   
	Aadd( aHlpPor, "anterior.")   
	PutSx1(cPerg,"08","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","mv_ch8","N",01,0,1,"C","","","","S","mv_par08","Sim","Sim","Sim","","Nao","Nao","Nao","Nao c/Sld Ant.","Nao c/Sld Ant.","Nao c/Sld Ant.","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Centros")
	Aadd( aHlpPor, "de Custo.")      
	PutSx1(cPerg,"09","Imprime C. Custo ?","Imprime C. Custo ?","Imprime C. Custo ?","mv_ch9","N",01,0,1,"C","","","","S","mv_par09","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Centros")
	Aadd( aHlpPor, "de Custo, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime C. Custo?'")      
	PutSx1(cPerg,"10","Do Centro Custo ?","Do Centro Custo ?","Do Centro Custo ?","mv_cha","C",09,0,0,"G","","CTT","","S","mv_par10","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo final atÈ o qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Centros ")    
	Aadd( aHlpPor, "de Custo, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime C. Custo?'")          
	PutSx1(cPerg,"11","Ate Centro Custo ?","Ate Centro Custo ?","Ate Centro Custo ?","mv_chb","C",09,0,0,"G","","CTT","","S","mv_par11","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Itens")
	Aadd( aHlpPor, "Cont·beis.")      
	PutSx1(cPerg,"12","Imprime Item Contab ?","Imprime Item Contab ?","Imprime Item Contab ?","mv_chc","N",01,0,1,"C","","","","S","mv_par12","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Itens")
	Aadd( aHlpPor, "Cont·beis, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime Item Contab?'")      
	PutSx1(cPerg,"13","Do Item Contabil ?","Do Item Contabil ?","Do Item Contabil ?","mv_chd","C",09,0,0,"G","","CTD","","S","mv_par13","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil final atÈ o qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")          
	PutSx1(cPerg,"14","Ate Item Contabil ?","Ate Item Contabil ?","Ate Item Contabil ?","mv_che","C",09,0,0,"G","","CTD","","S","mv_par14","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	PutSx1(cPerg,"15","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","mv_chf","C",02,0,0,"G","","CTO","","S","mv_par15","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja buscar o numero da NFS ")
	Aadd( aHlpPor, "de acordo com o numero de RPS.")
	PutSx1(cPerg,"16","Busca NFS ?","Busca NFS ?","Busca NFS ?","mv_chg","N",01,0,1,"C","","","","S","mv_par16","Sim","Sim","Sim","Sim","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
EndIf
	
Return Nil

/*
Funcao  : getHist()
Objetivo: FunÁ„o para retornar o historico do lanÁamento
Autor   : Jean Victor Rocha
Data    : 20/03/2017
*/                   
*---------------------------------------------*
Static Function getHist(cChave,cSequen,cSeqLan)
*---------------------------------------------*
Local cRet := ""
Local cQryHist := ""

If select("TEMPHIST") > 0
	TEMPHIST->(DbCloseArea())
EndIf

cQryHist := " SELECT CT2_HIST"
cQryHist += " FROM "+RetTabName("CT2")
cQryHist += " WHERE CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC = '"+cChave+"'"
cQryHist += " 		AND CT2_DC = '4'"
cQryHist += " 		AND CT2_SEQUEN = '"+cSequen+"'"
cQryHist += " 		AND CT2_SEQLAN = '"+cSeqLan+"'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryHist),"TEMPHIST",.T.,.T.)

While TEMPHIST->(!EOF())
	cRet += TEMPHIST->CT2_HIST
	TEMPHIST->(DbSkip())
EndDo

Return cRet

/*
Funcao  : getNFS()
Objetivo: FunÁ„o que retorna o numero da NFS
Autor   : Jean Victor Rocha
Data    : 07/04/17
*/                   
*--------------------------*
Static Function getNFS(cKey)
*--------------------------*
Local cRet := ""
Local cQry := ""

If select("TEMP") > 0
	TEMP->(DbCloseArea())
EndIf

cQry := " Select TOP 1 SF2.F2_NFELETR
cQry += " FROM "+RetTabName("SD2")+" SD2
cQry += "	Inner join "+RetTabName("SF2")+" as SF2 on SD2.D2_FILIAL = SF2.F2_FILIAL
cQry += "							  	   		AND SD2.D2_DOC = SF2.F2_DOC
cQry += "							 	  		AND SD2.D2_SERIE = SF2.F2_SERIE
cQry += "							 	   		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
cQry += "							 	   		AND SD2.D2_LOJA = SF2.F2_LOJA
cQry += " WHERE SD2.D_E_L_E_T_ <> '*' AND
cQry += " 		SF2.D_E_L_E_T_ <> '*' AND 
cQry += " 		SD2.D2_FILIAL+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_CLIENTE+SD2.D2_LOJA+SD2.D2_COD+SD2.D2_ITEMPV = '"+cKey+"'

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TEMP",.T.,.T.)

If TEMP->(!EOF())
	cRet := TEMP->F2_NFELETR
EndIf

Return cRet

/*
Funcao      : TelaEmp
Objetivos   : Exibe a tela para seleÁ„o de empresas
Autor       : Jean Victor Rocha
Data        : 15/05/2017
*/
*-----------------------*
Static Function TelaEmp()
*-----------------------*
Local nOpc := 0
Local oDlg
Local oGrp
Local oSel
Local oBtOk
Local oBtCan
Local lInverte	:= .F.
Local aExibe	:= {}
Local aEmpresas := {}

Private cMarca  := GetMark()

aCpEmp := {	{"WKMARCA"   ,"C",02,0},;
			{"M0_CODIGO" ,"C",02,0},;
			{"M0_NOMECOM","C",60,0}}

//Cria o arquivo tempor·rio das empresas
cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)

aAreaSM0 := SM0->(GetArea())
SM0->(DbGoTop())
While SM0->(!EOF())
    If !ALLTRIM(SM0->M0_CODIGO) $ "YY" .and. aScan(aEmpresas,{|x| x == ALLTRIM(SM0->M0_CODIGO)}) == 0
    	aAdd(aEmpresas, SM0->M0_CODIGO)
		TMPEMP->(DbAppend())	
		TMPEMP->WKMARCA   := cMarca
		TMPEMP->M0_CODIGO := SM0->M0_CODIGO
		TMPEMP->M0_NOMECOM:= SM0->M0_NOMECOM	        
	EndIf	
	SM0->(DbSkip())	
EndDo
RestArea(aAreaSM0)

aExibe  := {{"WKMARCA"   ,,""       ,""  },;
			{"M0_CODIGO" ,,"CÛdigo" ,"@!"},;
			{"M0_NOMECOM",,"Empresa","@!"}}

oDlg := MSDialog():New( 100,230,500,830,"Empresas",,,.F.,,,,,,.T.,,,.T. )

oGrp := TGroup():New( 008,008,178,294,"Marque as empresas/filiais",oDlg,,,.T.,.F. )

TMPEMP->(DbGoTop())
oSel := MsSelect():New("TMPEMP","WKMARCA","",aExibe,@lInverte,@cMarca,{020,016,172,286},,, oGrp ) 
oSel:oBrowse:lHasMark := .T.
oSel:oBrowse:lCanAllMark:=.T.
oSel:oBrowse:bAllMark := {|| MarkAll("TMPEMP",cMarca,@oDlg)}

oBtOk  := SButton():New( 184,230,1,{|| nOpc:=1,oDlg:End()},oDlg,,"Confirmar", )
oBtCan := SButton():New( 184,262,2,{|| nOpc:=0,oDlg:End()},oDlg,,"Cancelar" , )

oDlg:Activate(,,,.T.)

aEmpresas := {}
If nOpc == 1
	TMPEMP->(DbGoTop())
	While TMPEMP->(!EOF())
    	If TMPEMP->WKMARCA == cMarca
    		aAdd(aEmpresas, TMPEMP->M0_CODIGO)
    	EndIf
   		TMPEMP->(DbSkip())	
	EndDo
EndIf

TMPEMP->(DbCloseArea())
fErase(cArqTmp)

Return aEmpresas

/*
Funcao      : MarkAll
Objetivos   : Inverter a marcaÁ„o do MSSelect.
Autor       : Jean Victor Rocha
Data        : 15/05/2017
*/
*-------------------------------------------*
Static Function MarkAll(cAlias, cMarca, oDlg)
*-------------------------------------------*
Local nReg := (cAlias)->(RecNo())

(cAlias)->(dbGoTop())
While (cAlias)->(!EOF())
    (cAlias)->(RecLock(cAlias,.F.))
	If Empty((cAlias)->WKMARCA)
		(cAlias)->WKMARCA := cMarca
	Else
		(cAlias)->WKMARCA := "  "
	EndIf
	(cAlias)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(dbGoto(nReg))

oDlg:Refresh()
Return Nil

/*
Funcao      : RetTabName
Objetivos   : Retornar o nome da tabela no banco de dados.
Autor       : Jean Victor Rocha
Data        : 15/05/2017
*/
*--------------------------------*
Static Function RetTabName(cAlias)
*--------------------------------*
Local cRet := ""
Local cAliasSX2 := "SX2TMP"

If select(cAliasSX2) > 0
	(cAliasSX2)->(DbCloseArea())
EndIf 

dbUseArea(.T., "DBFCDX", GetSrvProfString("Startpath","")+"SX2"+cCdEmpAtual+"0.DBF", cAliasSX2, .T., .T.)
cArqInd := CriaTrab(Nil, .F.) 
IndRegua(cAliasSX2,cArqInd,"X2_CHAVE",,,,.F.)

(cAliasSX2)->(DbSetOrder(1))
If (cAliasSX2)->(DbSeek(cAlias))
	cRet := (cAliasSX2)->X2_ARQUIVO
Else
	cRet := cAlias+cCdEmpAtual+"0"
EndIf                       

(cAliasSX2)->(DbCloseArea())
FErase(cArqInd+OrdBagExt()) 

Return ALLTRIM(cRet)