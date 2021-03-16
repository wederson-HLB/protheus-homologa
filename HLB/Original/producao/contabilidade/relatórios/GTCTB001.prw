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
±±∫Uso       ≥ HLB BRASIL                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

//--------------------------------------------------------------------------
// Wederson L. Santana
// Inclus„o campo/par‚metro Filial origem + complemento do histÛrico
//--------------------------------------------------------------------------


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

Private cClasseDe := ''
Private cClasseAte := ''
//InÌcio - Wederson L. Santana --> 18/09/2020
Private cFilDe     := ''
Private cFilAte    := ''
Private nCompHis   := 0
//Fim - Wederson L. Santana --> 18/09/2020

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
	cClasseDe := mv_par16
	cClasseAte := mv_par17
	//InÌcio - Wederson L. Santana --> 18/09/2020
    cFilDe     := mv_par18
    cFilAte    := mv_par19
	//nCompHis   := mv_Par20
	//nCliFor    := mv_Par21
	//Fim - Wederson L. Santana --> 18/09/2020

	//Gera o RelatÛrio
	Processa({|| lOk := GeraRel()},"Gerando o relatÛrio...")

	If !lOk
		MsgInfo("N„o foram encontrados registros para os par‚metros informados.","AtenÁ„o")
		Return Nil
	EndIf

EndIf

Return Nil                           

/*
FunÁ„o  : GeralRel
Objetivo: Gera o relatÛrio
Autor   : Eduardo C. Romanini
Data    : 13/05/2013
*/
*-----------------------*
Static Function GeraRel()
*-----------------------*
Local lGrvDados := .F.

Local cArqTrab := ""

//Cria a tabela tempor·ria para impress„o dos registros.
cArqTrab := CriaArqTrab()

//Grava os Dados na tabela tempor·ria
If !Empty(cArqTrab)
	lGrvDados := GravaDados()
EndIf

If lGrvDados
	//Imprime o relatÛrio
    ImpRel()
EndIf

Return lGrvDados

/*
FunÁ„o  : CriaArqTrab
Objetivo: Cria a tabela tempor·ria que serùEutilizada para a impress„o.
Autor   : Eduardo C. Romanini
Data    : 20/05/2013
*/
*--------------------------*
Static Function CriaArqTrab
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {}

//Cria a tabela tempor·ria
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
aAdd(aStru,{"CLASSE","C",Len(CTH->CTH_CLVL),0})
aAdd(aStru,{"FILORI","C",Len(CT2->CT2_FILORI),0})
aAdd(aStru,{"SEQUEN","C",Len(CT2->CT2_SEQUEN),0})
aAdd(aStru,{"SEQLAN","C",Len(CT2->CT2_SEQLAN),0})

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o ˙ãdice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"CONTA+DTOS(DTLANC)+DOC",,"","Selecionando Registro...")


DbSelectArea("REL")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

Return cArqTrab

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

Local cHist :=""


//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf

//Imprime as contas sem movimentaÁ„o.
If lSemMov

	cQryDebit := "% ( SELECT CT2_DEBITO" 
	cQryDebit += "	  FROM " +RetSqlName("CT2")
	cQryDebit += "	  WHERE D_E_L_E_T_ <> '*'"
	cQryDebit += "	    AND CT2_FILIAL = '"+xFilial("CT2")+"'"
	cQryDebit += "		AND CT2_MOEDLC = '"+cMoeda+"'"
	cQryDebit += "		AND CT2_DATA >= '"+cDataDe+"'"
	cQryDebit += "		AND CT2_DATA <= '"+cDataAte+"'"
	cQryDebit += "		AND CT2_DEBITO >= '"+cContaDe+"'"
	cQryDebit += "		AND CT2_DEBITO <= '"+cContaAte+"'"
	cQryDebit += "		AND CT2_DEBITO <> ''"
	//InÌcio - Wederson L. Santana --> 18/09/2020
	cQryDebit += "		AND CT2_FILORI >= '"+cFilDe+"'"
	cQryDebit += "		AND CT2_FILORI <= '"+cFilAte+"'"
	//Fim - Wederson L. Santana --> 18/09/2020
	cQryDebit += "	  GROUP BY CT2_DEBITO) %"
    
	cQryCredit := "% ( SELECT CT2_CREDIT" 
	cQryCredit += "	  FROM " +RetSqlName("CT2")
	cQryCredit += "	  WHERE D_E_L_E_T_ <> '*'"
	cQryCredit += "	    AND CT2_FILIAL = '"+xFilial("CT2")+"'"
	cQryCredit += "		AND CT2_MOEDLC = '"+cMoeda+"'"
	cQryCredit += "		AND CT2_DATA >= '"+cDataDe+"'"
	cQryCredit += "		AND CT2_DATA <= '"+cDataAte+"'"
	cQryCredit += "		AND CT2_CREDIT >= '"+cContaDe+"'"
	cQryCredit += "		AND CT2_CREDIT <= '"+cContaAte+"'"
	//InÌcio - Wederson L. Santana --> 18/09/2020
	cQryCredit += "		AND CT2_FILORI >= '"+cFilDe+"'"
	cQryCredit += "		AND CT2_FILORI <= '"+cFilAte+"'"
	//Fim - Wederson L. Santana --> 18/09/2020
	cQryCredit += "		AND CT2_CREDIT <> ''"
	cQryCredit += "	  GROUP BY CT2_CREDIT) %"

	BeginSql Alias 'TMPCT1'
	
		SELECT CT1_CONTA, CT1_DESC01,CT1_DESC02,CT1_DESC03,CT1_DESC04
		FROM %table:CT1% 
		WHERE %notDel%
		  AND CT1_FILIAL = %xFilial:CT1%
		  AND CT1_CLASSE = '2'
		  AND CT1_CONTA >= %exp:cContaDe%
		  AND CT1_CONTA <= %exp:cContaAte%
		  AND CT1_CONTA NOT IN %exp:cQryDebit%
		  AND CT1_CONTA NOT IN %exp:cQryCredit% 
	 	ORDER BY CT1_CONTA
	 	
	EndSql

	aCT1:= GetLastQuery() 
	nICT1:=0
	TMPCT1->(DbGoTop())
	While TMPCT1->(!EOF())
        conout("CT1: "+cvaltochar(nICT1+=1))
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

//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT2") > 0
	TMPCT2->(DbCloseArea())
EndIf

cQryCT2:=""

//--LAN«AMENTOS DE D…BITO E CR…DITO
cQryCT2+=" SELECT (CASE WHEN C.CT2_DC='1' THEN C.CT2_DEBITO ELSE C.CT2_CREDIT END) [CONTA],
cQryCT2+=" CT1_DESC01 [DESCR],
//cQryCT2+=" CONVERT(VARCHAR(10),CONVERT(DateTime, CT2_DATA, 103),103) [DTLANC],
cQryCT2+=" CT2_DATA [DTLANC],
cQryCT2+=" '' [CPART],
cQryCT2+=" CT2_HIST AS [HIST],
cQryCT2+=" CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA [DOC],
cQryCT2+=" (CASE WHEN C.CT2_DC='1' THEN C.CT2_VALOR ELSE 0 END) [DEBIT],
cQryCT2+=" (CASE WHEN C.CT2_DC='2' THEN C.CT2_VALOR ELSE 0 END) [CREDIT],
cQryCT2+=" (CASE WHEN C.CT2_DC='1' THEN C.CT2_CCD ELSE CT2_CCC END) [CCUSTO],
cQryCT2+=" (CASE WHEN C.CT2_DC='1' THEN C.CT2_ITEMD ELSE CT2_ITEMC END) [ITCONT],
cQryCT2+=" (CASE WHEN C.CT2_DC='1' THEN C.CT2_CLVLDB ELSE CT2_CLVLCR END) [CLASSE],
cQryCT2+=" CT2_FILORI as [FILORI],
cQryCT2+=" CT2_SEQUEN as [SEQUEN],
cQryCT2+=" CT2_SEQLAN as [SEQLAN]
cQryCT2+=" FROM "+RETSQLNAME("CT2")+" C
cQryCT2+=" LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON (CASE WHEN C.CT2_DC='1' THEN C.CT2_DEBITO ELSE C.CT2_CREDIT END) = CT1.CT1_CONTA AND CT1.D_E_L_E_T_=''
cQryCT2+=" WHERE C.D_E_L_E_T_= ' ' AND C.CT2_DC IN ('1','2') 
//InÌcio - Wederson L. Santana --> 18/09/2020
cQryCT2+=" AND C.CT2_FILORI >= '"+cFilDe+"' 
cQryCT2+=" AND C.CT2_FILORI <= '"+cFilAte+"' 
//cQryCT2+=" AND C.CT2_FILIAL = '"+xFilial("CT2")+"' 
//Fim - Wederson L. Santana --> 18/09/2020
cQryCT2+=" AND C.CT2_DATA >= '"+cDataDe+"' 
cQryCT2+=" AND C.CT2_DATA <= '"+cDataAte+"' 
cQryCT2+=" AND C.CT2_MOEDLC = '"+cMoeda+"' 
cQryCT2+=" AND ((C.CT2_DEBITO BETWEEN '"+cContaDe+"' AND '"+cContaAte+"') OR (C.CT2_CREDIT BETWEEN '"+cContaDe+"' AND '"+cContaAte+"')) 
cQryCT2+=" AND ((C.CT2_CCD BETWEEN '"+cCCDe+"' AND '"+cCCAte+"') OR (C.CT2_CCC BETWEEN '"+cCCDe+"' AND '"+cCCAte+"'))
cQryCT2+=" AND ((C.CT2_ITEMD BETWEEN '"+cITemDe+"' AND '"+cITemAte+"') OR (C.CT2_ITEMC BETWEEN '"+cITemDe+"' AND '"+cITemAte+"')) 
cQryCT2+=" AND ((C.CT2_CLVLDB BETWEEN '"+cClasseDe+"' AND '"+cClasseAte+"') OR (C.CT2_CLVLCR BETWEEN '"+cClasseDe+"' AND '"+cClasseAte+"')) 
	
cQryCT2+=" UNION ALL
//--LAN«AMENTOS DE PARTIDA DOBRADA - D…BITO
cQryCT2+=" SELECT C.CT2_DEBITO [CONTA],
cQryCT2+=" CT1_DESC01 [DESCR],
//cQryCT2+=" CONVERT(VARCHAR(10),CONVERT(DateTime, CT2_DATA, 103),103) [DTLANC],
cQryCT2+=" CT2_DATA [DTLANC],
cQryCT2+=" C.CT2_CREDIT [CPART],
cQryCT2+=" CT2_HIST AS [HIST],
cQryCT2+=" CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA [DOC],
cQryCT2+=" C.CT2_VALOR [DEBIT],
cQryCT2+=" 0 [CREDIT],
cQryCT2+=" C.CT2_CCD [CCUSTO],
cQryCT2+=" C.CT2_ITEMD  [ITCONT],
cQryCT2+=" C.CT2_CLVLDB  [CLASSE],
cQryCT2+=" CT2_FILORI as [FILORI],
cQryCT2+=" CT2_SEQUEN as [SEQUEN],
cQryCT2+=" CT2_SEQLAN as [SEQLAN]
cQryCT2+=" FROM "+RETSQLNAME("CT2")+" C
cQryCT2+=" LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON C.CT2_DEBITO = CT1.CT1_CONTA AND CT1.D_E_L_E_T_=''
cQryCT2+=" WHERE C.D_E_L_E_T_= ' ' AND C.CT2_DC IN ('3') 
//InÌcio - Wederson L. Santana --> 18/09/2020
cQryCT2+=" AND C.CT2_FILORI >= '"+cFilDe+"' 
cQryCT2+=" AND C.CT2_FILORI <= '"+cFilAte+"' 
//cQryCT2+=" AND C.CT2_FILIAL = '"+xFilial("CT2")+"' 
//Fim - Wederson L. Santana --> 18/09/2020
cQryCT2+=" AND C.CT2_DATA >= '"+cDataDe+"' 
cQryCT2+=" AND C.CT2_DATA <= '"+cDataAte+"' 
cQryCT2+=" AND C.CT2_MOEDLC = '"+cMoeda+"' 
cQryCT2+=" AND ((C.CT2_DEBITO BETWEEN '"+cContaDe+"' AND '"+cContaAte+"'))" //--OR (C.CT2_CREDIT BETWEEN '"+cContaDe+"' AND '"+cContaAte+"')) 
cQryCT2+=" AND ((C.CT2_CCD BETWEEN '"+cCCDe+"' AND '"+cCCAte+"') OR (C.CT2_CCC BETWEEN '"+cCCDe+"' AND '"+cCCAte+"'))
cQryCT2+=" AND ((C.CT2_ITEMD BETWEEN '"+cITemDe+"' AND '"+cITemAte+"') OR (C.CT2_ITEMC BETWEEN '"+cITemDe+"' AND '"+cITemAte+"')) 
cQryCT2+=" AND ((C.CT2_CLVLDB BETWEEN '"+cClasseDe+"' AND '"+cClasseAte+"') OR (C.CT2_CLVLCR BETWEEN '"+cClasseDe+"' AND '"+cClasseAte+"')) 

cQryCT2+=" UNION ALL
//--LAN«AMENTOS DE PARTIDA DOBRADA - CR…DITO

cQryCT2+=" SELECT C.CT2_CREDIT [CONTA],
cQryCT2+=" CT1_DESC01 [DESCR],
//cQryCT2+=" CONVERT(VARCHAR(10),CONVERT(DateTime, CT2_DATA, 103),103) [DTLANC],
cQryCT2+=" CT2_DATA [DTLANC],
cQryCT2+=" C.CT2_DEBITO [CPART],
cQryCT2+=" CT2_HIST AS [HIST],
cQryCT2+=" CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA [DOC],
cQryCT2+=" 0 [DEBIT],
cQryCT2+=" C.CT2_VALOR [CREDIT],
cQryCT2+=" C.CT2_CCC [CCUSTO],
cQryCT2+=" C.CT2_ITEMC  [ITCONT],
cQryCT2+=" C.CT2_CLVLCR  [CLASSE],
cQryCT2+=" CT2_FILORI as [FILORI],
cQryCT2+=" CT2_SEQUEN as [SEQUEN],
cQryCT2+=" CT2_SEQLAN as [SEQLAN]
cQryCT2+=" FROM "+RETSQLNAME("CT2")+" C
cQryCT2+=" LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON C.CT2_CREDIT = CT1.CT1_CONTA AND CT1.D_E_L_E_T_=''
cQryCT2+=" WHERE C.D_E_L_E_T_= ' ' AND C.CT2_DC IN ('3') 
//InÌcio - Wederson L. Santana --> 18/09/2020
cQryCT2+=" AND C.CT2_FILORI >= '"+cFilDe+"' 
cQryCT2+=" AND C.CT2_FILORI <= '"+cFilAte+"' 
//cQryCT2+=" AND C.CT2_FILIAL = '"+xFilial("CT2")+"' 
//Fim - Wederson L. Santana --> 18/09/2020
cQryCT2+=" AND C.CT2_DATA >= '"+cDataDe+"' 
cQryCT2+=" AND C.CT2_DATA <= '"+cDataAte+"' 
cQryCT2+=" AND C.CT2_MOEDLC = '"+cMoeda+"' 
//cQryCT2+=" AND ((C.CT2_DEBITO BETWEEN '"+cContaDe+"' AND '"+cContaAte+"') OR (C.CT2_CREDIT BETWEEN '"+cContaDe+"' AND '"+cContaAte+"')) 
cQryCT2+=" AND (C.CT2_CREDIT BETWEEN '"+cContaDe+"' AND '"+cContaAte+"') 
cQryCT2+=" AND ((C.CT2_CCD BETWEEN '"+cCCDe+"' AND '"+cCCAte+"') OR (C.CT2_CCC BETWEEN '"+cCCDe+"' AND '"+cCCAte+"'))
cQryCT2+=" AND ((C.CT2_ITEMD BETWEEN '"+cITemDe+"' AND '"+cITemAte+"') OR (C.CT2_ITEMC BETWEEN '"+cITemDe+"' AND '"+cITemAte+"')) 
cQryCT2+=" AND ((C.CT2_CLVLDB BETWEEN '"+cClasseDe+"' AND '"+cClasseAte+"') OR (C.CT2_CLVLCR BETWEEN '"+cClasseDe+"' AND '"+cClasseAte+"')) 

cQryCT2+=" ORDER BY  [DTLANC],[DOC]
        
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryCT2),"TMPCT2",.F.,.T.)

	nICT2:=0
	TMPCT2->(DbGoTop())
	While TMPCT2->(!EOF())
        conout("CT2: "+cvaltochar(nICT2+=1))

		cHist := AllTrim(TMPCT2->HIST)
		//Busca o histÛrico
		cHist += getHist(xFilial("CT2")+TMPCT2->(DTLANC+SubStr(DOC,1,15)),;
								AllTrim(TMPCT2->SEQUEN),;
								AllTrim(TMPCT2->SEQLAN))
	    	
		//Grava o arquivo tempor·rio.
	   	//REL->(DbAppend())
		RecLock("REL", .T.)		
				
				REL->CONTA  := AllTrim(TMPCT2->CONTA)
				REL->DESCR  := SUBSTR(AllTrim(TMPCT2->DESCR),1,40)
				REL->DTLANC := STOD(TMPCT2->DTLANC)
			 	REL->CPART  := AllTrim(TMPCT2->CPART)
				REL->HIST   := cHist
				REL->DOC    := AllTrim(TMPCT2->DOC)
				REL->DEBIT  := TMPCT2->DEBIT
				REL->CREDIT := TMPCT2->CREDIT
				REL->CCUSTO := AllTrim(TMPCT2->CCUSTO)
				REL->ITCONT := AllTrim(TMPCT2->ITCONT)
				REL->CLASSE := AllTrim(TMPCT2->CLASSE)
				REL->FILORI := AllTrim(TMPCT2->FILORI)
		
		//REL->( DBCommit() )	
		REL->(MsUnLock())    

		TMPCT2->(DbSkip())		
	EndDo


lRet  := .T.
If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf
If Select("TMPCT2") > 0
	TMPCT2->(DbCloseArea())
EndIf

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

Local aSaldo := {}

Local aAux  := {}

Local oExcel

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

oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Empresa: ", AllTrim(SM0->M0_NOMECOM)})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Data Inicial: ", DtoC(StoD(cDataDe))})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Data Final: ", DtoC(StoD(cDataAte))})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Data Emiss„o: ", DtoC(dDataBase)})
oExcel:AddRow("Par‚metros","Par‚metros - Raz„o Cont·bil",{"Hora Emiss„o: ", Time()})

oExcel:AddWorkSheet("Razao") 
oExcel:AddTable ("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM))

oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Conta (Anal˙ëica)",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Nome Conta",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Data",2,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Contra Partida",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"HistÛrico",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Documento",1,1,.F.)

If lCCusto
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"C.Custo.",1,1,.F.)
EndIf

If lItCont
	oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"It.Cont.",1,1,.F.)
EndIf

oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Saldo Anterior",3,2,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Tipo",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"DÈbitos",3,2,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"CrÈditos",3,2,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Saldo Atual",3,2,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Tipo",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Classe Valor",1,1,.F.)
oExcel:AddColumn("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),"Filial Origem",1,1,.F.)

   
REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF())
		        
	If cConta == REL->CONTA
 		nSldAnt := nSldAtu
	Else
		If Empty(DtoS(REL->DTLANC))
			nSldAnt := RetSaldo(REL->CONTA,StoD(cDataDe))
			//aSaldo := RetSaldo(REL->CONTA,StoD(cDataDe))
		Else
			nSldAnt := RetSaldo(REL->CONTA,REL->DTLANC)
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

	If lItCont .and. lCCusto
		aAux := {REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->CCUSTO,REL->ITCONT,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu,REL->CLASSE,REL->FILORI}
	ElseIf lCCusto
		aAux := {REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->CCUSTO,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu,REL->CLASSE,REL->FILORI}	
	ElseIf lItCont
		aAux := {REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,REL->ITCONT,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu,REL->CLASSE,REL->FILORI}
	Else
		aAux := {REL->CONTA,REL->DESCR,DtoC(REL->DTLANC),REL->CPART,REL->HIST,REL->DOC,Abs(nSldAnt),cTpAnt,REL->DEBIT,REL->CREDIT,Abs(nSldAtu),cTpAtu,REL->CLASSE,REL->FILORI}
	EndIf
	  
	oExcel:AddRow("Razao","Razao Contabil - Empresa: "+AllTrim(SM0->M0_NOMECOM),aAux)

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
	
	Sleep(2000)
	FERASE (cArq)
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
*--------------------------------------*
Static Function RetSaldo(cConta,dDtLanc)
*--------------------------------------*
Local nRet   := 0
Local nVlCre := 0
Local nVlDeb := 0
Local aRet
Local cDtLanc := DtoS(dDtLanc)
//AOA - 04/12/2018 - Ajuste para validar se estùEna vers„o 11 ou 12
If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"

	If Select("TMPCT7") > 0
		TMPCT7->(DbCloseArea())
	EndIf
	
	BeginSql Alias 'TMPCT7'
	
		SELECT TOP 1 CT7_ATUCRD,CT7_ATUDEB
		FROM %table:CT7%
		WHERE %notDel%
		  AND CT7_MOEDA = %exp:cMoeda%
		  AND CT7_CONTA = %exp:cConta%
		  AND CT7_DATA < %exp:cDtLanc%
		ORDER BY CT7_DATA DESC    
		
	EndSql
	
	TMPCT7->(DbGoTop())
	If TMPCT7->(!EOF())
		nVlCre := TMPCT7->CT7_ATUCRD
		nVlDeb := TMPCT7->CT7_ATUDEB
	EndIf
	
	nRet := nVlDeb - nVlCre
Else
	//aRet := SaldoCQFil("CT1",cConta,,,,,cDtLanc,cMoeda,"1",,,,,)
	//MATHEUS RIBEIROSaldoCQ
	//aRet := CTB01SAL("CT1",cConta,,,,,STOD(cDtLanc),cMoeda,"1",,,,,)
	aRet := SaldoCQ("CT1",cConta,,,,,STOD(cDtLanc),cMoeda,"1",,,,,)
	nRet := aRet[6]*-1 // Ajuste pois o sinal estùEvindo invertido com a lÛgica desenvolvida no programa.
EndIf

Return nRet 
//Return aRet

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
  					{"16","Da Classe Valor ?"    },;
  					{"17","Ate Classe Valor ?"   },;
   					{"18","Da Filial Origem ?"   },;
  					{"19","Ate Filial Origem ?"  }}
					//{"20","Imprime Cont.HistÛrico ?"}}
					//{"21","Imprime Cliente/Fornecedor ?"  }}
					//Inclus„o par‚metros 18,19,20 e 21 - Wederson L. Santana --> 18/09/2020  

//Verifica se o SX1 estùEcorreto
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
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatÛrio.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final atùEa qual")
	Aadd( aHlpPor, "se desejùEimprimir o relatÛrio.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"serùEserùEgerado.")
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\GTCTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo serùEaberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatÛrio.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
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
	
	U_PUTSX1(cPerg,"08","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","mv_ch8","N",01,0,1,"C","","","","S","mv_par08","Sim","Sim","Sim","","Nao","Nao","Nao","Nao c/Sld Ant.","Nao c/Sld Ant.","Nao c/Sld Ant.","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Centros")
	Aadd( aHlpPor, "de Custo.")      
	
	U_PUTSX1(cPerg,"09","Imprime C. Custo ?","Imprime C. Custo ?","Imprime C. Custo ?","mv_ch9","N",01,0,1,"C","","","","S","mv_par09","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Centros")
	Aadd( aHlpPor, "de Custo, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime C. Custo?'")      
	
	U_PUTSX1(cPerg,"10","Do Centro Custo ?","Do Centro Custo ?","Do Centro Custo ?","mv_cha","C",09,0,0,"G","","CTT","","S","mv_par10","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo final atùEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Centros ")    
	Aadd( aHlpPor, "de Custo, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime C. Custo?'")          
	
	U_PUTSX1(cPerg,"11","Ate Centro Custo ?","Ate Centro Custo ?","Ate Centro Custo ?","mv_chb","C",09,0,0,"G","","CTT","","S","mv_par11","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Itens")
	Aadd( aHlpPor, "Cont·beis.")      
	
	U_PUTSX1(cPerg,"12","Imprime Item Contab ?","Imprime Item Contab ?","Imprime Item Contab ?","mv_chc","N",01,0,1,"C","","","","S","mv_par12","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Itens")
	Aadd( aHlpPor, "Cont·beis, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime Item Contab?'")      
	
	U_PUTSX1(cPerg,"13","Do Item Contabil ?","Do Item Contabil ?","Do Item Contabil ?","mv_chd","C",09,0,0,"G","","CTD","","S","mv_par13","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil final atùEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")          
	
	U_PUTSX1(cPerg,"14","Ate Item Contabil ?","Ate Item Contabil ?","Ate Item Contabil ?","mv_che","C",09,0,0,"G","","CTD","","S","mv_par14","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	
	U_PUTSX1(cPerg,"15","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","mv_chf","C",02,0,0,"G","","CTO","","S","mv_par15","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	aHlpPor := {}
	U_PUTSX1(cPerg,"16","Da Classe de Valor ?","Da Classe de Valor ?","Da Classe de Valor ?","mv_chg","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par16","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	Aadd( aHlpPor, "Informe o Item Cont·bil final atùEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")     
   
	U_PUTSX1(cPerg,"17","Ate Classe de Valor ?","Ate Classe de Valor ?","Ate Classe de Valor ?","mv_chh","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par17","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

    //InÌcio - Wederson L. Santana --> 18/09/2020
	Aadd( aHlpPor, "Informe a filial de origem")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir o movimento de ")    
	Aadd( aHlpPor, "todos as filiais, preencha este campo com ")
	Aadd( aHlpPor, "'ZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: ")
	Aadd( aHlpPor, "")     
   
	U_PUTSX1(cPerg,"18","Da Filial Origem ?","Da Filial Origem ?","Da Filial Origem ?","mv_chi","C",Len( CT2->CT2_FILORI ),0,0,"G","","SM0","","S","mv_par18","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	U_PUTSX1(cPerg,"19","Ate Filial Origem ?","Ate Filial Origem ?","Ate Filial Origem ?","mv_chj","C",Len( CT2->CT2_FILORI ),0,0,"G","","SM0","","S","mv_par19","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

    /*Aadd( aHlpPor, "Imprime continuaÁ„o histÛrico")
	Aadd( aHlpPor, "deseja imprimir no relatÛrio.")
	Aadd( aHlpPor, "ContinuaÁ„o do histÛrico. ")    
	Aadd( aHlpPor, "Informe S-Sim - N-N„o. ")
	Aadd( aHlpPor, " ")
	Aadd( aHlpPor, " ")    
	Aadd( aHlpPor, "Obs: ")
	Aadd( aHlpPor, "")     
   
	U_PUTSX1(cPerg,"20","Imprime Cont.HistÛrico ?","Imprime Cont.HistÛrico ?","Imprime Cont.HistÛrico ?","mv_chl","N",1,0,0,"G","","","","S","mv_par20","Sim","Si","Yes","","","N„o","No","No","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

    
    Aadd( aHlpPor, "Imprime cliente/fornecedor")
	Aadd( aHlpPor, "deseja imprimir no relatÛrio.")
	Aadd( aHlpPor, "cliente/fornecedor. ")    
	Aadd( aHlpPor, "Informe S-Sim - N-N„o. ")
	Aadd( aHlpPor, " ")
	Aadd( aHlpPor, " ")    
	Aadd( aHlpPor, "Obs: ")
	Aadd( aHlpPor, "")     
   
	U_PUTSX1(cPerg,"21","Imprime cliente/fornecedor ?","Imprime cliente/fornecedor ?","Imprime cliente/fornecedor ?","mv_chm","N",1,0,0,"G","","","","S","mv_par21","Sim","Si","Yes","","","N„o","No","No","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
    */
	//Fim - Wederson L. Santana --> 18/09/2020
EndIf
	
Return Nil

//-------------------

Static Function getHist(cChave,cSequen,cSeqLan)

Local cRet := ""
Local cQryHist := ""

If select("TEMPHIST") > 0
	TEMPHIST->(DbCloseArea())
EndIf

cQryHist := " SELECT CT2_HIST"
cQryHist += " FROM "+RetSqlName("CT2")
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
