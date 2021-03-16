#include "Protheus.ch"
#Include "TopConn.ch"
/*
Funcao      : MTDESCRNFE 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada, para alterar a descrição(corpo) da nota fiscal de serviço.
Autor       : 
TDN         : Este ponto de entrada tem a finalidade de compor a descrição dos serviços prestados na operação. Essa descrição será utilizada para a impressão do RPS e para geração do arquivo de exportação para a prefeitura. 
Revisão     : Matheus Henrique Semanaka Massarotto
Data/Hora   : 06/02/2012
Módulo      : Livros Fiscais.
*/


*---------------------------*
  User Function MTDESCRNFE()
*---------------------------*   

cAlias:=Alias()

//RRP - 01/07/2015 - Retirada as empresas que não são GTCORP.
IF SM0->M0_CODIGO $ "CH/Z4/ZB/ZF/Z8/4C/4K/JW/ZA/ZG" // Empresas gtcorp
	
	c_Serv	:= ""
	cQry	:= "" //Variável utilizada para query
	nValor	:= nValLiq:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	:= 0
	nValLiq	:= 0
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'NF'
				nValor:= SE1->E1_VALOR
			EndIf
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
			endif
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			endif
			SE1->(DbSkip())
		EndDo
	Endif
	cCompara := SF2->F2_DOC+SF2->F2_SERIE
	nValLiq	:= SF2->F2_VALBRUT-(cIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	aServ    :={}
	aVen 		:= {}
	Descon 	:=0
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF ALLTRIM(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			ENDIF
			SE1->(DbSkip())
		EndDo
	Endif
	
//	SD2->(dbSetOrder(8))
//	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Descon = Descon + SD2->D2_DESCON
		
		if SM0->M0_CODIGO $ "Z4" .AND. SM0->M0_CODFIL $ "02" //MSM - 15/08/2012 - tratamento específico para a prefeitura do RJ para apresentação do valor total com o desconto
			Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,40), SD2->D2_PRCVEN+Descon, SD2->D2_TOTAL})
		else
			Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,40), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		endif
		
		SD2->(dbSkip())
	end
	nServ :=1
	
	if SM0->M0_CODIGO $ "Z4" //MSM - 01/08/2016 - Tratamento para não exibir os valores da empresa Z4	
		c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                                              "+ "|"
	else
		c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS               VALOR UNIT          VALOR TOTAL"+ "|"
	endif
	
	While nServ <= Len(aServ)
		
		if SM0->M0_CODIGO $ "Z4" //MSM - 01/08/2016 - Tratamento para não exibir os valores da empresa Z4
			c_Serv += +(Transform(aServ[nServ][1], "@E 999.9"))+ "     " +aServ[nServ][2]+"     " +space(14)+ "       "  +space(14)+ "|"
		else
			c_Serv += +(Transform(aServ[nServ][1], "@E 999.9"))+ "     " +aServ[nServ][2]+"     " +(Transform(aServ[nServ][3], "@E 999,999,999.99"))+ "       " +(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"		
		endif
		nServ  +=1
	End
	c_Serv+=  "|"
	c_Serv+="Total dos serviços: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" ("+EXTENSO(SF2->F2_VALBRUT)+ ") -"
	i :=1
	While i <= Len(aVen)
		c_Serv+=" Vencimento "+ALLTRIM(str(i))+": "+aVen[i][1]+" - "
		i+=1
	End
	
	IF Descon > 0
		c_Serv +=" Desconto: "+ Alltrim(Transform (Descon, "@E 999,999.99"))+" - "
	EndIf

	If nISS > 0
		c_Serv+= " ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))+" -"
	EndIf
	If nInss > 0
		c_Serv+= " INSS Retido "+Alltrim(Transform (nInss, "@E 999,999.99"))+" -"
	EndIf	
	IF cIrrf > 0
		c_Serv+= " IRRF "+Alltrim(Transform (cIrrf, "@E 999,999.99"))+" -"
		
		if SM0->M0_CODIGO $ '4C/4K'
			if SF2->F2_VALBRUT>5000
				IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
					c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + "/" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +"/"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
				ENDIF
			endif
		else
			IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
				c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + "/" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +"/"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
			ENDIF		
		endif
		
	ENDIF

	//Matheus - 26/12/2011 -  tratamento para exibir a msg de retenção de PCC somente se o cadastro de cliente + produto estiver informando para reter, chamado: 001625
	/* RRP - 01/07/2015 - Retirado mensagem de impostos. Chamado 027815.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	if SA1->A1_RECCOFI=="S" .AND. SA1->A1_RECCSLL=="S" .AND. SA1->A1_RECPIS=="S" .AND. (SA1->A1_ABATIMP=="1" .OR. SA1->A1_ABATIMP=="2")

		SD2->(dbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	    
	    DbSelectArea("SB1")
	    SB1->(DbSetOrder(1))
	    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	    if SB1->B1_PIS=="1" .AND. SB1->B1_COFINS=="1" .AND. SB1->B1_CSLL=="1"
			
			if SM0->M0_CODIGO $ '4C/4K'
				if SF2->F2_VALBRUT>5000
					c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
				endif
			else
				c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
			endif
		endif
	endif*/
	
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
	
	//Matheus - 26/11/2011 - tratamento para considerar a mensagem padrão do pedido de venda, no corpo da nota de serviço, chamado: 002027
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	
	if !empty(SC5->C5_MENPAD)
		cMsgPad:=FORMULA(SC5->C5_MENPAD)
		if valtype(cMsgPad)=="C"
			c_Serv +=" |"+alltrim(cMsgPad)
		endif
	endif
		
	DBSELECTAREA( cAlias )


	    //MSM - 22/02/2013 - Tratamento para observações dos itens gerados através das medições automáticas(contratos), buscando as informações dos contratos
		
		cQry:=" SELECT ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CN9_P_MENS)),'') AS CN9_P_MENS FROM "+RETSQLNAME("CN9")
		cQry+=" WHERE D_E_L_E_T_='' AND CN9_FILIAL='"+xFilial("CN9")+"' AND CN9_NUMERO='"+SC5->C5_MDCONTR+"' AND CN9_SITUAC='05'"
		
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount

		if nRecCount >0

			QRYTEMP->(DbGotop())
			c_Serv +="Observações:|"
			//c_Serv +=STRTRAN(alltrim(QRYTEMP->CN9_P_MENS),CRLF,"") 
			c_Serv +=Alltrim(STRTRAN(alltrim(QRYTEMP->CN9_P_MENS),chr(10),""))

	    else
		    //MSM - 20/06/2012 - Tratamento para observações dos itens gerados através das medições(contratos)
			
			cQry:=" SELECT ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),CND_OBS)),'') AS CND_OBS,CND_POBS FROM "+RETSQLNAME("CND")
			cQry+=" WHERE D_E_L_E_T_='' AND CND_FILIAL='"+xFilial("CND")+"' AND CND_CONTRA='"+SC5->C5_MDCONTR+"' AND CND_NUMMED='"+SC5->C5_MDNUMED+"'"
			
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
	        
			if nRecCount >0
				QRYTEMP->(DbGotop())
				c_Serv +="Observações:|"
				c_Serv +=STRTRAN(alltrim(QRYTEMP->CND_OBS)+alltrim(QRYTEMP->CND_POBS),CRLF,"")
	        else
	        	if !empty(SC5->C5_OBS)
					c_Serv +="Observações:|"
				c_Serv +=STRTRAN(alltrim(SC5->C5_OBS)+alltrim(SC5->C5_OBS),CRLF,"")        	
	        	endif
	        endif
	        
		endif	

ElseIF SM0->M0_CODIGO $ "RH/Z8" //Empresa Pryor RH e Pryor Consultores
	
	c_Serv	:= ""
	nValor	:= nValLiq:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	:= 0
	nValLiq	:= 0
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'NF'
				nValor:= SE1->E1_VALOR
			EndIf
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
			endif
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			endif
			SE1->(DbSkip())
		EndDo
	Endif
	cCompara := SF2->F2_DOC+SF2->F2_SERIE
	nValLiq	:= SF2->F2_VALBRUT-(cIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	aServ    :={}
	aVen 		:= {}
	Descon 	:=0
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF ALLTRIM(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			ENDIF
			SE1->(DbSkip())
		EndDo
	Endif
/*	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,50), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
*/    
	//SD2->(dbSetOrder(8))
	//SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,50), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end

	nServ :=1
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                    VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		//c_Serv += +(Transform(aServ[nServ][1], "@E 999.99"))+ "     " +aServ[nServ][2]+ "               " +(Transform(aServ[nServ][3], "@E 999,999,999.99"))+ "       " +(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
		c_Serv += +(Transform(aServ[nServ][1], "@E 999.99"))+ "     " +aServ[nServ][2]+ "  " +(Transform(aServ[nServ][3], "@E 999,999.99"))+ "    " +(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
		nServ  +=1
	End
	c_Serv+=  "|"
	c_Serv+="Total dos serviços: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" ("+EXTENSO(SF2->F2_VALBRUT)+ ") -"
	i :=1
	While i <= Len(aVen)
		c_Serv+=" Vencimento "+ALLTRIM(str(i))+": "+aVen[i][1]+" - "
		i+=1
	End
	
	IF Descon > 0
		c_Serv +=" Desconto: "+ Alltrim(Transform (Descon, "@E 999,999.99"))+" - "
	EndIf

	If nISS > 0
		c_Serv+= " ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))+" -"
	EndIf
	If nInss > 0
		c_Serv+= " INSS Retido "+Alltrim(Transform (nInss, "@E 999,999.99"))+" -"
	EndIf	
	IF cIrrf > 0
		c_Serv+= " IRRF "+Alltrim(Transform (cIrrf, "@E 999,999.99"))+" -"
		IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
			c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + "/" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +"/"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
		ENDIF
	ENDIF
	
	//Matheus - 26/12/2011 -  tratamento para exibir a msg de retenção de PCC somente se o cadastro de cliente + produto estiver informando para reter, chamado: 001625
	/*RRP - 01/07/2015 - Retirado mensagem de impostos. Chamado 027815.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	if SA1->A1_RECCOFI=="S" .AND. SA1->A1_RECCSLL=="S" .AND. SA1->A1_RECPIS=="S" .AND. (SA1->A1_ABATIMP=="1" .OR. SA1->A1_ABATIMP=="2")

		SD2->(dbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	    
	    DbSelectArea("SB1")
	    SB1->(DbSetOrder(1))
	    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	    if SB1->B1_PIS=="1" .AND. SB1->B1_COFINS=="1" .AND. SB1->B1_CSLL=="1"
			c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
		endif
	endif*/	
	
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
	
	//Matheus - 26/11/2011 - tratamento para considerar a mensagem padrão do pedido de venda, no corpo da nota de serviço, chamado: 002027
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	
	if !empty(SC5->C5_MENPAD)
		cMsgPad:=FORMULA(SC5->C5_MENPAD)
		if valtype(cMsgPad)=="C"
			c_Serv +=" |"+alltrim(cMsgPad)
		endif
	endif
		
	DBSELECTAREA( cAlias )


ElseIf SM0->M0_CODIGO=="Z4"  //   GtAuditores 

	c_Serv:= ""
	nValor	:= nValLiq:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	:= 0
	nValLiq	:= 0
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'NF'
				nValor:= SE1->E1_VALOR
			
			EndIf
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
			endif
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			endif
			SE1->(DbSkip())
		EndDo
	Endif
	cCompara := SF2->F2_DOC+SF2->F2_SERIE
	nValLiq	:= SF2->F2_VALBRUT-(cIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	aServ    :={}
	aVen := {}
	Descon :=0
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF ALLTRIM(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			ENDIF
			SE1->(DbSkip())
		EndDo
	Endif
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))            // TLM  estava fixo "01"    //"01"))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		//Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN})
		Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN*SD2->D2_QUANT}) // TLM
		Descon += SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1
	
	While nServ <= Len(aServ)
		c_Serv+= aServ[nServ][1]+ " Valor R$ " + Alltrim(Transform(aServ[nServ][2], "@E 999,999,999,999.99"))+ EXTENSO(aServ[nServ][2])+" - "
		nServ +=1
	End
	
	i :=1
	While i <= Len(aVen)
		c_Serv+=" Vencimento "+ALLTRIM(str(i))+" -"+aVen[i][1]+" - "
		i+=1
	End
	
	IF Descon > 0
		c_Serv +=" Desconto: "+ Alltrim(Transform (Descon, "@E 999,999.99"))+" - "
	EndIf

	If nISS > 0
		c_Serv+= " ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))+" -"
	EndIf
	If nInss > 0
		c_Serv+= " INSS Retido "+Alltrim(Transform (nInss, "@E 999,999.99"))+" -"
	EndIf	
	IF cIrrf > 0
		c_Serv+= " IRRF "+Alltrim(Transform (cIrrf, "@E 999,999.99"))+" -"
		IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
			c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + " /" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +" /"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
		ENDIF
	ENDIF
	
	//Matheus - 26/12/2011 -  tratamento para exibir a msg de retenção de PCC somente se o cadastro de cliente + produto estiver informando para reter, chamado: 001625
	/*RRP - 01/07/2015 - Retirado mensagem de impostos. Chamado 027815.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	if SA1->A1_RECCOFI=="S" .AND. SA1->A1_RECCSLL=="S" .AND. SA1->A1_RECPIS=="S" .AND. (SA1->A1_ABATIMP=="1" .OR. SA1->A1_ABATIMP=="2")

		SD2->(dbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	    
	    DbSelectArea("SB1")
	    SB1->(DbSetOrder(1))
	    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	    if SB1->B1_PIS=="1" .AND. SB1->B1_COFINS=="1" .AND. SB1->B1_CSLL=="1"
			c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
		endif
	endif*/
		
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+" - "
	c_Serv += Alltrim(+SC5->C5_MENNOTA)

	//Matheus - 26/11/2011 - tratamento para considerar a mensagem padrão do pedido de venda, no corpo da nota de serviço, chamado: 002027
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	
	if !empty(SC5->C5_MENPAD)
		cMsgPad:=FORMULA(SC5->C5_MENPAD)
		if valtype(cMsgPad)=="C"
			c_Serv +=" |"+alltrim(cMsgPad)
		endif
	endif

	DBSELECTAREA( cAlias )

Else

	c_Serv:= ""
	nValor	:= nValLiq:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	:= 0
	nValLiq	:= 0
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'NF'
				nValor:= SE1->E1_VALOR
			EndIf
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
			endif			
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			endif
			SE1->(DbSkip())
		EndDo
	Endif
	cCompara := SF2->F2_DOC+SF2->F2_SERIE
	nValLiq	:= SF2->F2_VALBRUT-(cIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	aServ    :={}
	aVen := {}
	Descon :=0
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If! Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		Do While.Not.Eof().And.SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF ALLTRIM(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			ENDIF
			SE1->(DbSkip())
		EndDo
	Endif
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))            // TLM  estava fixo "01"    //"01"))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		//Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN})
		Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN*SD2->D2_QUANT}) // TLM
		Descon += SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1
	
	While nServ <= Len(aServ)
		c_Serv+= aServ[nServ][1]+ " Valor R$ " + Alltrim(Transform(aServ[nServ][2], "@E 999,999,999,999.99"))+ EXTENSO(aServ[nServ][2])+" - "
		nServ +=1
	End
	
	i :=1
	While i <= Len(aVen)
		c_Serv+=" Vencimento "+ALLTRIM(str(i))+" -"+aVen[i][1]+" - "
		i+=1
	End
	
	IF Descon > 0
		c_Serv +=" Desconto: "+ Alltrim(Transform (Descon, "@E 999,999.99"))+" - "
	EndIf
	If nISS > 0
		c_Serv+= " ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))+" -"
	EndIf
	If nInss > 0
		c_Serv+= " INSS Retido "+Alltrim(Transform (nInss, "@E 999,999.99"))+" -"
	EndIf
	IF cIrrf > 0
		c_Serv+= " IRRF "+Alltrim(Transform (cIrrf, "@E 999,999.99"))+" -"
		IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
			c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + " /" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +" /"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
		ENDIF
	ELSE
		IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
			c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + " /" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +" /"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
		ENDIF	
	ENDIF

	//Matheus - 26/12/2011 -  tratamento para exibir a msg de retenção de PCC somente se o cadastro de cliente + produto estiver informando para reter, chamado: 001625
	/*RRP - 01/07/2015 - Retirado mensagem de impostos. Chamado 027815.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	if SA1->A1_RECCOFI=="S" .AND. SA1->A1_RECCSLL=="S" .AND. SA1->A1_RECPIS=="S" .AND. (SA1->A1_ABATIMP=="1" .OR. SA1->A1_ABATIMP=="2")

		SD2->(dbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	    
	    DbSelectArea("SB1")
	    SB1->(DbSetOrder(1))
	    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	    if SB1->B1_PIS=="1" .AND. SB1->B1_COFINS=="1" .AND. SB1->B1_CSLL=="1"
			c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
		endif
	endif*/
	
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+" - "
	c_Serv += Alltrim(+SC5->C5_MENNOTA)
	
	//Matheus - 26/11/2011 - tratamento para considerar a mensagem padrão do pedido de venda, no corpo da nota de serviço, chamado: 002027
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
	
	if !empty(SC5->C5_MENPAD)
		cMsgPad:=FORMULA(SC5->C5_MENPAD)
		if valtype(cMsgPad)=="C"
			c_Serv +=" |"+alltrim(cMsgPad)
		endif
	endif
	
	DBSELECTAREA( cAlias )
                              
EndIf                         

// LFSS 09/01/2017 - Acrescentando a ompetencia do Cronograma 
c_Serv += " "+U_CRONCOM(SC5->C5_NUM)

RETURN(c_Serv)      
  
/*
Funcao      : CronComp 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Buscar a competencia do Cronograma dos contato
Autor       :  Luiz Fernando
Data/Hora   : 06/01/2017
Módulo      : Faturamento 
Executar u_CRONCOM('000315')	
*/   

User Function CRONCOM(cPedi)  
Local CrLf   := chr(13)+chr(10)
Local cQuery := "" 
Local cRet   := ""
Local aArea  := GetArea() 
Local cAlias := GetNextAlias()   
Local cEmpresas := SuperGetMv("MV_P_00094",,"Z4,CH,4K")   // Empresas que mostrarão o campo competencia do cronograma Gestão de Contratos. 
If SM0->M0_CODIGO $ cEmpresas 
   cQuery := "SELECT C.CNF_COMPET COMPET,A.C5_NUM,A.C5_NOTA,A.C5_CLIENTE " +CrLf 
   cQuery += "FROM "+RetSqlName("SC5")+" A INNER JOIN "+RetSqlName("CN9")+" B ON B.CN9_NUMERO = A.C5_MDCONTR AND A.C5_CLIENTE = B.CN9_CLIENT AND B.CN9_SITUAC = '05' AND B.CN9_FILIAL = A.C5_FILIAL "+CrLf 
   cQuery += "							   INNER JOIN "+RetSqlName("SE1")+" D ON A.C5_FILIAL = D.E1_FILIAL AND A.C5_NOTA = D.E1_NUM AND D.E1_SERIE = A.C5_SERIE AND A.C5_CLIENTE = D.E1_CLIENTE AND D.E1_TIPO = 'NF '"+CrLf 
   cQuery += "                             INNER JOIN "+RetSqlName("CNF")+" C ON B.CN9_NUMERO = C.CNF_CONTRA  AND C.CNF_FILIAL = A.C5_FILIAL AND C.CNF_DTREAL = A.C5_EMISSAO AND B.CN9_REVISA = C.CNF_REVISA AND SUBSTRING(C.CNF_DTVENC,1,6) = SUBSTRING(D.E1_VENCTO,1,6) "+CrLf 
   cQuery += "WHERE A.D_E_L_E_T_ <> '*' AND "+CrLf 
   cQuery += "      B.D_E_L_E_T_ <> '*' AND "+CrLf 
   cQuery += "      C.D_E_L_E_T_ <> '*' AND "+CrLf 
   cQuery += "      A.C5_MDCONTR <> '' AND "+CrLf 
   cQuery += "      A.C5_FILIAL  = '"+xFilial('SC5')+"' AND "+CrLf 
   cQuery += "      A.C5_NUM 	 = '"+cPedi+"'  "+CrLf  
   
   TCQUERY cQuery NEW ALIAS (cAlias)     
   (cAlias)->(DbGotop()) 
   if ! empty(alltrim((cAlias)->Compet))
	   cRet := "Competência: "+alltrim((cAlias)->Compet) //+ "Ped: "+(cAlias)->C5_NUM+" Not: "+(cAlias)->C5_NOTA+" Cli: "+(cAlias)->C5_CLIENTE
   endif 
   (cAlias)->(DbCloseArea())
   
Endif 
RestArea(aArea) 
                                                                	
Return(cRet)

   
  
