#Include "Protheus.ch"

/*
Funcao      : PE01NFSEDESCR
Parametros  : cCodMun,cTipo,dDtEmiss,cSerie,cNota,cClieFor,cLoja
Retorno     : cMsgNota
Objetivos   : Ponto de entrada na montagem do xml para a nota fiscal de serviço
Autor       : Matheus Massarotto
Data/Hora   : 29/05/2012    16:48
Revisão		: Guilherme Fernandes Pilan - GFP
Data/Hora   : 16/02/2017	16:55
Objetivos   : Ajustes para utilização na NFS-e automatica (FISA022).
Módulo      : Genérico
*/

*--------------------------*
User Function PE01NFSEDESCR 
*--------------------------*
Local cMsgNota:="",cProds := "", i:=0
Local cEstado:=UPPER(alltrim(GETMV("MV_ESTADO")))
Local aArea:=GetArea()
Local aOrd := SaveOrd({"SC6","SA1","SF2","SF3","SD2","SC5","SE1","CND","CNF"})

Local cCodMun := PARAMIXB[1]
Local cTipo   := PARAMIXB[2]
Local cSerie  := PARAMIXB[4]
Local cNota   := PARAMIXB[5]
Local cClieFor:= PARAMIXB[6]
Local cLoja   := PARAMIXB[7]
Local cCarTrb := PARAMIXB[8] 
Local lDescXML:= PARAMIXB[9]
Local lCampinas:=PARAMIXB[10]
Local aProd	  := If(Len(PARAMIXB) > 10,PARAMIXB[11],{})
Local nItem	  := If(Len(PARAMIXB) > 11,PARAMIXB[12],1)
Default cCarTrb := ""
Default lDescXML:= .F.
Default lCampinas:= .F.

If nItem == 1
	cProds += "QTDE" + Space(5) + "DESCRICAO DOS SERVICOS PRESTADOS"
	If cEmpAnt == "Z8"
		cProds += Space(10) + "VALOR UNIT" + Space(5) + "VALOR TOTAL"
	EndIf
	cProds += Chr(13)+Chr(10)
EndIf

if (!lDescXML .AND. cEmpAnt == "Z4" .AND. cCodMun == "3550308") .OR. (lDescXML .AND. cEmpAnt $ "4K/CH/Z4/Z8/ZB/ZF/ZG/RH/ZA/ZP")

// Descrição customizada liberada para todas as empresas.
//	if cCodMun == "3550308" //cEstado=="SP" //Tratamento para São Paulo
	    
	    /*
	    |  Layout da Prefeitura de São Paulo para a Discriminação dos Serviços 
	    |	Tamanho 0-2000
	    |	Texto contínuo descritivo dos serviços. 
	    |	O conjunto de caracteres correspondentes ao código ASCII 13 e ASCII 10 deverá ser substituído pelo caracter | (pipe ou barra vertical. ASCII 124). 
	    |	Exemplo: Digitado na NF “Lavagem de carro com lavagem de motor” 
	    |	Preenchimento do arquivo: “Lavagem de carro|com lavagem de motor” 
	    |	Não devem ser colocados espaços neste campo para completar seu tamanho máximo, 
	    |	devendo o campo ser preenchido apenas com conteúdo a ser processado /armazenado. 
	    |	(*) Este campo é impresso num retângulo com 95 caracteres (largura) e 24 linhas (altura). 
	    |	É permitido (não recomendável), o uso de mais de 2000 caracteres. Caso seja ultrapassado o limite de 24 linhas, o
	    |	conteúdo será truncado durante a impressão da Nota.
	    */
	    
	    DbSelectArea("SF3")
	    SF3->(DbSetOrder(4))
	    SF3->(DbSeek(xFilial("SF3")+cClieFor+cLoja+cNota+cSerie))
		
		c_Serv:= ""
		nValor	:= nValLiq:= 0
		XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
		cIrrf		:= 0
		cInss		:=0
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
				IF  SE1->E1_TIPO = 'IN-'
					cInss += SE1->E1_VALOR
				endif
				SE1->(DbSkip())
			EndDo
		Endif
		cCompara := SF2->F2_DOC+SF2->F2_SERIE
		nValLiq	:= SF2->F2_VALBRUT-(cIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+cInss)
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

		If !lCampinas
			If Len(aProd) # 0
				SD2->(DbSetOrder(3))  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+aProd[2]))
					SC6->(dbSetOrder(2))
	   				SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
					cProds += Alltrim(Transform(SD2->D2_QUANT, "@E 999999.99")) + Espacamento(Alltrim(Transform(SD2->D2_QUANT, "@E 999999.99")),9) + Alltrim(SC6->C6_DESCRI)
					If cEmpAnt == "Z8"
						cProds += Espacamento(Alltrim(SC6->C6_DESCRI),42) + Alltrim(Transform(SD2->D2_PRCVEN, "@E 999,999,999,999.99")) + Espacamento(Alltrim(Transform(SD2->D2_PRCVEN, "@E 999,999,999,999.99")),15) + Alltrim(Transform(SD2->D2_TOTAL, "@E 999,999,999,999.99"))
					EndIf
					cProds += Chr(13)+Chr(10)
				EndIf
			Else
				//SD2->(dbSetOrder(8))
				//SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+If(!lDescXML,SC6->C6_ITEM,"")))            // TLM  estava fixo "01"    //"01"))
				SD2->(DbSetOrder(3))  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
				While SD2->D2_DOC+SD2->D2_SERIE == cCompara
					SC6->(dbSetOrder(2))
					SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
					//Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN})
					Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN*SD2->D2_QUANT}) // TLM
					If lDescXML
						cProds += Alltrim(Transform(SD2->D2_QUANT, "@E 999999.99")) + Espacamento(Alltrim(Transform(SD2->D2_QUANT, "@E 999999.99")),9) + Alltrim(SC6->C6_DESCRI)
						If cEmpAnt == "Z8"
							cProds += Espacamento(Alltrim(SC6->C6_DESCRI),42) + Alltrim(Transform(SD2->D2_PRCVEN, "@E 999,999,999,999.99")) + Espacamento(Alltrim(Transform(SD2->D2_PRCVEN, "@E 999,999,999,999.99")),15) + Alltrim(Transform(SD2->D2_TOTAL, "@E 999,999,999,999.99"))
						EndIf
						cProds += Chr(13)+Chr(10)
					EndIf
					Descon += SD2->D2_DESCON
					SD2->(dbSkip())
				end
			EndIf
			If nItem # 1 .AND. !Empty(cCarTrb)  //Carga Tributária - Lei 12.741
				c_Serv += cCarTrb
			EndIf
		EndIf
		nServ :=1
		
		If !lDescXML
			While nServ <= Len(aServ)
				c_Serv+= aServ[nServ][1]+ " Valor " + Alltrim(Transform(aServ[nServ][2], "@E 999,999,999,999.99"))+ EXTENSO(aServ[nServ][2])+" - "
				nServ +=1
			End
		Else
			c_Serv+= cProds + Chr(13)+Chr(10)
		EndIf
		
		If !lDescXML .OR. lCampinas .OR. !(cCodMun == "3509502")  // CAMPINAS NÃO LEVA ESTA INFORMAÇÃO NO CORPO DA NOTA
			i :=1
			While i <= Len(aVen)
				c_Serv+=" Vencimento "+ALLTRIM(str(i))+" - "+aVen[i][1]+ If(lDescXML,Chr(13)+Chr(10)," - ")
				i+=1
			End
		
			IF Descon > 0
				c_Serv +=" Desconto: "+ Alltrim(Transform (Descon, "@E 999,999.99"))+ If(lDescXML,Chr(13)+Chr(10)," - ")
			EndIf
		
			IF cIrrf > 0
				c_Serv+= " IRRF "+Alltrim(Transform (cIrrf, "@E 999,999.99"))+ If(lDescXML,Chr(13)+Chr(10)," - ")
				IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
					c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + " / " +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +" / "+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99"))+ If(lDescXML,Chr(13)+Chr(10)," - ")
				ENDIF
			ENDIF
		
			IF cInss > 0 
				c_Serv+= " INSS "+Alltrim(Transform (cInss, "@E 999,999.99"))+ If(lDescXML,Chr(13)+Chr(10)," - ")
			ENDIF

			//Matheus - 26/12/2011 -  tratamento para exibir a msg de retenção de PCC somente se o cadastro de cliente + produto estiver informando para reter, chamado: 001625
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			if SA1->A1_RECCOFI=="S" .AND. SA1->A1_RECCSLL=="S" .AND. SA1->A1_RECPIS=="S" .AND. (SA1->A1_ABATIMP=="1" .OR. SA1->A1_ABATIMP=="2")
	
				SD2->(dbSetOrder(3))
				SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
		    
		    	DbSelectArea("SB1")
		    	SB1->(DbSetOrder(1))
		    	SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
		    	if SB1->B1_PIS=="1" .AND. SB1->B1_COFINS=="1" .AND. SB1->B1_CSLL=="1" .AND. !lDescXML
					c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
				endif
			endif
			
	//		c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"
			c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+ If(lDescXML,Chr(13)+Chr(10)," - ")
			c_Serv += Alltrim(SC5->C5_MENNOTA)
	
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
					c_Serv +=alltrim(cMsgPad)+ If(lDescXML,Chr(13)+Chr(10),"")
				endif
			endif
		
			If lDescXML .AND. !Empty(SC5->C5_MDCONTR)  // Informações do Contrato
				CN9->(DbSetOrder(1))
				If CN9->(DbSeek(xFilial("CN9")+SC5->C5_MDCONTR))
					Do While CN9->(!Eof()) .AND. CN9->CN9_FILIAL == xFilial("CN9") .AND. CN9->CN9_NUMERO == SC5->C5_MDCONTR
						If CN9->CN9_SITUAC == "05" .AND. !Empty(CN9->CN9_P_MENS)
							c_Serv += AllTrim(CN9->CN9_P_MENS) + Chr(13)+Chr(10)
							Exit
						EndIf
						CN9->(DbSkip())
					EndDo
				EndIf
				If !(cEmpAnt $ "ZB/ZF/ZG")
					CND->(DbSetOrder(4))
					If CND->(DbSeek(xFilial("CND")+SC5->C5_MDNUMED)) .AND. CND->CND_CONTRA == SC5->C5_MDCONTR
						CNF->(DbSetOrder(2))
						If CNF->(DbSeek(xFilial("CNF")+CND->CND_CONTRA+CND->CND_REVISA))
							Do While CNF->(!Eof()) .AND. CNF->(CNF_FILIAL+CNF_CONTRA+CNF_REVISA) == xFilial("CNF")+CND->CND_CONTRA+CND->CND_REVISA
								If CNF->CNF_COMPET == AvKey(StrZero(Month(dDataBase),2)+"/"+cValToChar(Year(dDataBase)),"CNF_COMPET")
									c_Serv += " Competencia: " + AllTrim(CNF->CNF_COMPET) + Chr(13)+Chr(10)
									Exit
								EndIf
								CNF->(DbSkip())
							EndDo
						EndIf
					EndIf
				EndIf
			EndIf
		
		EndIf
		If !Empty(cCarTrb)  //Carga Tributária - Lei 12.741
			c_Serv +=+ Chr(13)+Chr(10)+ cCarTrb + Chr(13)+Chr(10)
		EndIf
		
		If !lDescXML
			for i:=1 to len(c_Serv) STEP 95
				cMsgNota+=SubStr(c_Serv,i,95)+"|"
			next
		Else
			If cCodMun == "4314902" .OR. cCodMun == "3106200"  // PORTO ALEGRE / BELO HORIZONTE
				c_Serv := StrTran(c_Serv,Chr(13)+Chr(10),"|")
			EndIf
			cMsgNota := c_Serv
			cMsgNota := EncodeUTF8(cMsgNota)
		EndIf

	endif
//endif

RestArea(aArea)
RestOrd(aOrd,.T.)
Return(cMsgNota)

Static Function Espacamento(cString,nEspaco)
Return Space(nEspaco-Len(cString))
