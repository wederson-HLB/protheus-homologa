#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GQREENTR()
Ponto de entrada utilizado para a rotina GTGEN047 quando a nota vier dessa rotina

@author    Marcio Martins Pereira
@version   1.xx
@since     10/06/2019
/*/
//------------------------------------------------------------------------------------------

User Function GQREENTR()

Local nX := 0
Local nZ := 0

If  IsInCallStack("U_GTGEN047")
	
	cQuery 	 := ''
	nValBrut := 0
	nValDesc := 0 
	nBrICMS  := 0 
	nICMSRet := 0  
	nVALFEEF := 0 
	nBasFECP := 0   

	aSFTCFOP := {}
	For nZ := 1 to Len(aIteSD1)
		nPsD1Item := Ascan( aIteSD1[nZ], {|x| Alltrim(x[1]) == "D1_ITEM" } )									
		nPsD1Prod := Ascan( aIteSD1[nZ], {|x| Alltrim(x[1]) == "D1_COD"  } )		
		cAliasTRB	:= GetNextAlias()
		cQuery := " SELECT R_E_C_N_O_ RECSD1 FROM "+RetSqlName("SD1")+" (NOLOCK) " + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += "       D1_SERIE   = '" + SF1->F1_SERIE + "'   AND D1_DOC  = '"+SF1->F1_DOC+"'  AND " + CRLF 
		cQuery += "       D1_FORNECE = '" + SF1->F1_FORNECE + "' AND D1_LOJA = '"+SF1->F1_LOJA+"' AND " + CRLF
		cQuery += "       D1_COD     = '" + aIteSD1[nZ,nPsD1Prod,2] + "' AND D1_ITEM = '"+aIteSD1[nZ,nPsD1Item,2]+"' AND D_E_L_E_T_ = '' " + CRLF
		DBUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), (cAliasTRB), .F., .T.)
		If !(cAliasTRB)->(Eof())
			SD1->(dbGoTo((cAliasTRB)->RECSD1))
			RecLock("SD1",.F.)
			For nZZ := 1 to Len(aIteSD1[nZ])
				SD1->&(aIteSD1[nZ,nZZ,1]) := aIteSD1[nZ,nZZ,2]
			Next nZZ
			SD1->D1_VALFECP := 0 
			SD1->D1_BASFECP := 0
			SD1->D1_VFECPST := 0
			//SD1->D1_P_NUMFL := cIDProd 
			MsUnlock()
			dbSelectArea("SFT")
			SFT->(dbSetOrder(1))	// FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
			If SFT->(dbSeek(xFilial("SFT")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD)))
				RecLock("SFT",.F.)
				SFT->FT_VFECPST := SD1->D1_VFECPST
				SFT->FT_BSFCPST := SD1->D1_BASFECP
				SFT->FT_ALIQINS := SD1->D1_ALIQINS
				SFT->FT_ALIQIRR := SD1->D1_ALIQIRR
				SFT->FT_ALIQSOL := SD1->D1_ALIQSOL
				SFT->FT_ALIQCOF := SD1->D1_ALQIMP5
				SFT->FT_ALIQCSL := SD1->D1_ALQCSL 
				SFT->FT_ALIQPIS := SD1->D1_ALQIMP6
				SFT->FT_BASECOF := SD1->D1_BASIMP5
				SFT->FT_BASECSL := SD1->D1_BASECSL
				SFT->FT_BASEICM := SD1->D1_BASEICM
				SFT->FT_BASEINS := SD1->D1_BASEINS				
				SFT->FT_BASEIRR := SD1->D1_BASEIRR
				SFT->FT_BASEPIS := SD1->D1_BASIMP6
				SFT->FT_BASNDES := SD1->D1_BASNDES
				SFT->FT_BASERET := SD1->D1_BRICMS
				SFT->FT_VALCOF  := SD1->D1_VALIMP5
				SFT->FT_VALCSL  := SD1->D1_VALCSL 
				SFT->FT_VALICM  := SD1->D1_VALICM 
				If Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_CREDIPI") == "S"
					SFT->FT_BASEIPI := SD1->D1_BASEIPI
					SFT->FT_VALIPI  := SD1->D1_VALIPI
					SFT->FT_ALIQIPI	:= SD1->D1_IPI
				Endif	
				SFT->FT_VALIRR  := SD1->D1_VALIRR 
				SFT->FT_VALPIS  := SD1->D1_VALIMP6
				SFT->FT_VALFEEF := SD1->D1_VALFEEF
				SFT->FT_VALFECP := SD1->D1_VALFECP
				SFT->FT_CFOP    := SD1->D1_CF
				SFT->FT_VALFECP := SD1->D1_VALFECP
				SFT->FT_BASFECP := SD1->D1_BASFECP
				If SFT->FT_OUTRICM > 0  
					If SFT->FT_OUTRICM - SD1->D1_TOTAL == 0.01
						SFT->FT_OUTRICM := SD1->D1_TOTAL
					Endif
				Endif
				If SFT->FT_OUTRIPI > 0  
					If SFT->FT_OUTRIPI - SD1->D1_TOTAL == 0.01
						SFT->FT_OUTRIPI := SD1->D1_TOTAL
					Endif
				Endif
				
				MsUnlock()
		
				nPos := Ascan( aSFTCFOP, {|x| x[1] == SD1->D1_CF } )		
				If nPos == 0 
					aAdd( aSFTCFOP , { 	SD1->D1_CF														,;	// 1
										SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_VALFRE+SD1->D1_DESPESA+SD1->D1_ICMSRET-SD1->D1_VALDESC	,;	// 2
										SD1->D1_BRICMS									,;	// 3
										SD1->D1_ICMSRET									,;	// 4
										SD1->D1_VALFEEF									,;	// 5
										SD1->D1_BSFCPST									,;	// 6
										SFT->FT_OUTRICM									,;	// 7
										SFT->FT_OUTRIPI									})	// 8
				Else
					aSFTCFOP[nPos,2] += SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_VALFRE+SD1->D1_DESPESA+SD1->D1_ICMSRET-SD1->D1_VALDESC
					aSFTCFOP[nPos,3] += SD1->D1_BRICMS								
					aSFTCFOP[nPos,4] += SD1->D1_ICMSRET								
					aSFTCFOP[nPos,5] += SD1->D1_VALFEEF								 
					aSFTCFOP[nPos,6] += SD1->D1_BSFCPST								 
					aSFTCFOP[nPos,7] += SFT->FT_OUTRICM								 
					aSFTCFOP[nPos,8] += SFT->FT_OUTRIPI								 
				Endif
	
				nValBrut += SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_VALFRE+SD1->D1_DESPESA+SD1->D1_ICMSRET-SD1->D1_VALDESC
				nValDesc += SD1->D1_VALDESC
				nBrICMS  += SD1->D1_BRICMS
				nICMSRet += SD1->D1_ICMSRET
				nBasFECP += SD1->D1_BSFCPST
			
			Endif
			
		Endif
		(cAliasTRB)->(dbCloseArea())
		
	Next nZ  

	RecLock("SF1",.F.)
	SF1->F1_VALBRUT := nValBrut
	SF1->F1_BRICMS  := nBrICMS  
	SF1->F1_ICMSRET := nICMSRet
	SF1->F1_BASFECP	:= nBasFECP
	MsUnlock()

	For nX := 1 To Len(aSFTCFOP)
		SF3->(dbSetOrder(1))	// F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO
		If SF3->(dbSeek(xFilial("SF3")+DTOS(SF1->F1_DTDIGIT)+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+Padr(aSFTCFOP[nX,1],5)))
			RecLock("SF3",.F.)
			SF3->F3_CFO		:= aSFTCFOP[nX,1]
			SF3->F3_VALFECP := 0
			SF3->F3_BSFCPST	:= 0
			SF3->F3_VALCONT := aSFTCFOP[nX,2]
			SF3->F3_BASERET := aSFTCFOP[nX,3]
			SF3->F3_ICMSRET	:= aSFTCFOP[nX,4]
			SF3->F3_BASFECP := aSFTCFOP[nX,6]
			SF3->F3_VFECPST := aSFTCFOP[nX,5]
			SF3->F3_OUTRICM := aSFTCFOP[nX,7]
			SF3->F3_OUTRIPI := aSFTCFOP[nX,8]
			MsUnlock()
		Endif
	Next nX

Endif

Return