#include "rwmake.ch"                                   

/*
Funcao      : AJMEDICAO
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : AJUSTA QUANTIDADE INCORRETAS NA MEDICAO - AJUSTA SALDOS DE CONTRATOS
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contratos.
*/

*--------------------------*
  User Function AJMEDICAO()   
*--------------------------*

Local cAlias    := GetArea()
Local cAmbiente := "GTCORP/GTCORPTESTE/ENVGTCORP01/ENVGTCORP02/GT_LOCAL"
Local cQuery    := ""
Local cPerg     := "AJMEDI" 
Local nDif      := 0
Local aPergs    := {}
Local cItemCNE  := ""
Local cMed      := ""                            

Aadd(aPergs,{"De  Competencia","","","mv_ch1","C",7,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Competencia","","","mv_ch2","C",7,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Numero Planilha","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

If Upper(ALLTRIM(GetEnvServer())) $ Upper(cAmbiente)
	
	//AjustaSx1(cPerg,aPergs)
	If Pergunte( cPerg,.t.)
		
		// BUSCA MEDICOES PARCIAIS NA TABELA CNE - VINCULA COM TABELAS RELACIONADAS //
		//			cQuery += " AND CND.CND_DTINIC BETWEEN '"+DTOS(MV_PAR01)+ "' AND '"+DTOS(MV_PAR02)+ "' "
		
		#IFDEF TOP
			
			cQuery := " SELECT DISTINCT CNE.CNE_FILIAL,CNE.CNE_NUMMED,CNE.CNE_CONTRA,CNE.CNE_REVISA,CNE.CNE_NUMERO,CNE.CNE_ITEM,CNE.CNE_VLUNIT,CNE.CNE_VLTOT, CNE.CNE_QUANT, "
			cQuery += " CNE.R_E_C_N_O_ AS RECNO_CNE, CND.R_E_C_N_O_ AS RECNO_CND,CNF.R_E_C_N_O_ AS RECNO_CNF, CNA.R_E_C_N_O_ AS RECNO_CNA,CNB.R_E_C_N_O_ AS RECNO_CNB,CN9.R_E_C_N_O_ AS RECNO_CN9 "
			cQuery += ' FROM '+ RetSQLname("CNE")+ ' AS CNE '
			cQuery += " INNER JOIN " +RetSQLname("CND")+ " AS CND ON CNE.CNE_FILIAL = CND.CND_FILIAL AND CNE.CNE_CONTRA=CND.CND_CONTRA AND CNE.CNE_REVISA=CND.CND_REVISA AND CNE.CNE_NUMMED=CND.CND_NUMMED AND CNE.CNE_NUMERO=CND.CND_NUMERO "
			cQuery += " INNER JOIN " +RetSQLname("CNA")+ " AS CNA ON CNE.CNE_FILIAL = CNA.CNA_FILIAL AND CNE.CNE_CONTRA=CNA.CNA_CONTRA AND CNE.CNE_REVISA=CNA.CNA_REVISA AND CNE.CNE_NUMERO=CNA.CNA_NUMERO "
			cQuery += " INNER JOIN " +RetSQLname("CNB")+ " AS CNB ON CNE.CNE_FILIAL = CNB.CNB_FILIAL AND CNE.CNE_CONTRA=CNB.CNB_CONTRA AND CNE.CNE_REVISA=CNB.CNB_REVISA AND CNE.CNE_NUMERO=CNB.CNB_NUMERO "
			cQuery += " INNER JOIN " +RetSQLname("CN9")+ " AS CN9 ON CNE.CNE_FILIAL = CN9.CN9_FILIAL AND CNE.CNE_CONTRA=CN9.CN9_NUMERO AND CNE.CNE_REVISA=CN9.CN9_REVISA "
			cQuery += " INNER JOIN " +RetSQLname("CNF")+ " AS CNF ON CNE.CNE_FILIAL = CNF.CNF_FILIAL AND CNE.CNE_CONTRA=CNF.CNF_CONTRA AND CNE.CNE_REVISA=CNF.CNF_REVISA "
			cQuery += " WHERE CNE.D_E_L_E_T_ = '' AND CND.D_E_L_E_T_ = ''  AND CNF.D_E_L_E_T_ = '' AND CNA.D_E_L_E_T_ = '' AND CNB.D_E_L_E_T_ = '' "
			cQuery += " AND CNE.CNE_VLTOT < CNE.CNE_VLUNIT  AND CNE.CNE_VLTOT > 0 "
			cQuery += " AND CNE.CNE_PEDIDO <> '' "                                      
			cQuery += " AND CND.CND_PARCEL = CNF.CNF_PARCEL "                                      
			cQuery += " AND CNF.CNF_VLPREV > CNF.CNF_VLREAL  AND CNF.CNF_VLREAL > 0 "
			cQuery += " AND CNF.CNF_COMPET BETWEEN '"+MV_PAR01+ "' AND '"+MV_PAR02+ "' "
			cQuery += " AND CND.CND_COMPET BETWEEN '"+MV_PAR01+ "' AND '"+MV_PAR02+ "' "
			cQuery += " AND CNE.CNE_NUMERO = '"+MV_PAR03+"' "
			cQuery += " AND CN9.CN9_SITUAC = '05' "
			cQuery += " GROUP BY CNE.CNE_FILIAL,CNE.CNE_CONTRA,CNE.CNE_REVISA,CNE.CNE_NUMMED,CNE.CNE_NUMERO,CNE.CNE_ITEM,CNE.CNE_QUANT,CNE.CNE_VLUNIT,CNE.CNE_VLTOT,CNE.R_E_C_N_O_,CND.R_E_C_N_O_,CNA.R_E_C_N_O_,CNB.R_E_C_N_O_,CNF.R_E_C_N_O_,CN9.R_E_C_N_O_"
			cOrdem := " ORDER BY CNE.CNE_FILIAL,CNE.CNE_CONTRA,CNE.CNE_REVISA,CNE.CNE_NUMMED,CNE.CNE_NUMERO,CNE.CNE_ITEM "
			cQuery +=   cQuery + cOrdem
			MEMOWRIT("SELCNE.SQL",cQuery)
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)
			dbSelectArea("TMP")
			TCSETFIELD(Alias(),"TMP->CND_DTINIC","D")
			DbGoTop()
			
			While !Eof()
				//			nVlDoc := Posicione("SF2",1,xFilial("SF2")+TMP->C5_NOTA+TMP->C5_SERIE,"F2_VALMERC")
				nDif := TMP->CNE_VLUNIT - TMP->CNE_VLTOT
				nQtd := TMP->CNE_QUANT
				If nDif > 0
						dbSelectArea("CNE")
						dBGoTo(TMP->RECNO_CNE)
						If !CNE->CNE_VLTOT < CNE->CNE_VLUNIT
            				dbSelectArea("TMP")
			             	dbSkip()
			             	Loop
						Endif
						RecLock("CNE",.F.)
						CNE->CNE_VLTOT := CNE->CNE_VLTOT + nDif
						CNE->CNE_QUANT := 1
						CNE->CNE_PERC  := 0
						MsUnlock()
						
						dbSelectArea("CND")
						dBGoTo(TMP->RECNO_CND)
						RecLock("CND",.F.)
						CND->CND_VLSALD  := If(CND->CND_VLSALD > 0 .AND. CND->CND_VLSALD >= nDif,CND->CND_VLSALD - nDif,0)
						MsUnlock()
						
						dbSelectArea("CNF")
						dBGoTo(TMP->RECNO_CNF)
						RecLock("CNF",.F.)
						CNF->CNF_SALDO  := 0
						CNF->CNF_VLREAL := CNF->CNF_VLPREV
						MsUnlock()
						
						dbSelectArea("CNA")
						dBGoTo(TMP->RECNO_CNA)
						RecLock("CNA",.F.)
						CNA->CNA_SALDO  := If(CNA->CNA_SALDO > 0 .AND. CNA->CNA_SALDO >= nDif, CNA->CNA_SALDO - nDif, 0)
						MsUnlock()
						
						dbSelectArea("CNB")
						dBGoTo(TMP->RECNO_CNB)
						RecLock("CNB",.F.)
						CNB->CNB_VLTOT  := CNB->CNB_VLUNIT
						CNB->CNB_QTDMED  := (CNB->CNB_QTDMED - nQtd ) + CNE->CNE_QUANT
						MsUnlock()
						
						dbSelectArea("CN9")
						dBGoTo(TMP->RECNO_CN9)
						RecLock("CN9",.F.)
						CN9->CN9_SALDO  := If(CN9->CN9_SALDO > 0 .AND.CN9->CN9_SALDO >= nDif,CN9->CN9_SALDO - nDif,0)
						MsUnlock()
					Endif
				dbSelectArea("TMP")
				dbSkip()
			Enddo
			
			dbSelectArea("TMP")
			dbCloseArea("TMP")
			
		#ENDIF
		
	Endif
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

Return
