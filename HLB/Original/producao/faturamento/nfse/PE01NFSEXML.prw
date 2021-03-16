#Include 'Totvs.Ch'

/*
Funcao      : PE01NFSEXML
Parametros  : cTipoInt
Retorno     : Nil
Objetivos   : Ponto de entrada para customização no envio do XML para prefeitura.
Autor       : Renato Rezende
Data/Hora   : 14/09/2016
*/

*--------------------------------*
 User Function PE01NFSEXML()
 //            PE01NFSE
*--------------------------------*
Local aRet		:= {}
Local aArea		:= {}
Local aDest	    := ParamIXB[01]

Local cNatOper  := ParamIXB[02]
Local cDescrNFSe:= ParamIXB[03]
Local cQry		:= ""

Local nAbatim	:= 0

//RRP - 09/08/2013 - Carregar a data de Vencimento para Msg
If cEmpAnt $ '40'

	//Retirando a descrição do serviço que carrega no SX5
	cNatOper := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
	
	//JSS
	cQry := ""
	cQry += " Select Top 1 * "
	cQry += " From "+RetSQLNAME("SE1")
	cQry += " Where D_E_L_E_T_ <> '*'" 
	cQry += "		AND E1_FILIAL = '"+xFilial("SE1")+"'"
	cQry += "		AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"'"
	cQry += "		AND E1_LOJA = '"+SF2->F2_LOJA+"'"
	cQry += "		AND E1_PREFIXO = '"+SF2->F2_SERIE+"'" 
	cQry += "		AND E1_NUM = '"+SF2->F2_DOC+"'"
	cQry += "		AND E1_PARCELA = '"+" "+"'"
	cQry += "		AND E1_TIPO = '"+"NF"+"'"

	If select("QRY")>0
		QRY->(DbCloseArea())
	EndIf

	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRY", .F., .F. )

	QRY->(DbGoTop())                                                   
	If QRY->(!EOF())
		SE1->(DbGoTo(QRY->R_E_C_N_O_))
		nAbatim := SomaAbat(QRY->E1_PREFIXO,QRY->E1_NUM,QRY->E1_PARCELA,"R",QRY->E1_MOEDA,dDataBase,QRY->E1_CLIENTE,QRY->E1_LOJA)  
        nVlrIR  := QRY->E1_IRRF
       nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE, SE1->E1_LOJA, xFilial("SE1", SE1->E1_FILORIG), dDataBase, SE1->E1_TIPO)

		If !Empty(QRY->E1_VENCTO)
			cNatOper += "Vencimento: "+DtoC(StoD(QRY->E1_VENCTO))+" "     
		EndIf		
	EndIf

	// TLM - 20140205 - Chamado 014257 Tratamento do valor liquido ( F2_VALBRUT-F2_VALCOFI-F2_VALCSLL-F2_VALPIS-F2_VALIRRF) 
	//cNatOper+=" VALOR LIQUIDO: "+Alltrim(Str(SF2->F2_VALBRUT-SF2->F2_VALCOFI-SF2->F2_VALCSLL-SF2->F2_VALPIS-SF2->F2_VALIRRF))
	If QRY->E1_CLIENTE = "005699" .And. QRY->E1_LOJA = "01"
	  cNatOper+=" VALOR LIQUIDO: "+Alltrim(Str(SF2->F2_VALFAT - nVlrIR )) //SSS - 15/01/2021 Alterado para reduzir o valor de IRRF do valor total da nota
	Else  
      cNatOper+=" VALOR LIQUIDO: "+Alltrim(Str(SF2->F2_VALFAT - nAbatim ))//JSS - 16/12/2014 Alterado pois estava reduzindo o valor de PCC em notas menores q 5k. 
    EndIf
	
ElseIf cEmpAnt $ u_EmpVogel()
	
	aArea := SC6->(GetArea())
	
	cNatOper:= ""
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		While SC6->(!EOF()) .And. SC6->C6_FILIAL+SC6->C6_NUM == SC5->C5_FILIAL+SC5->C5_NUM
			cNatOper += Alltrim(SC6->C6_DESCRI)
			cNatOper += "|"			
			SC6->(DbSkip())
		EndDo
	EndIf
	
	cNatOper+= If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
	
	RestArea(aArea)

//AOA - 02/04/2018 - Projeto NFS-e 
ElseIf cEmpAnt $ "ZJ" //LinkedIn

	//Retirando a descrição do serviço que carrega no SX5
	//cNatOper  := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
	cNatOper	:= ""
	aArea := GetArea()
	cMsgServ	:= ""
	XPCC_COF 	:= XPCC_CSLL := XPCC_PIS := 0
	nIrrf		:= nISS := nInss := nValLiq := 0
	lDescInc	:= .F.
	lTemCamp	:= .F.
	aVen   		:= {}
	aServ    	:= {}

	//Item do Pedido
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))//C6_FILIAL+C6_NUM+C6_ITEM
		
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If !Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		While SE1->(!Eof()) .And. SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				nIrrf := SE1->E1_VALOR
			EndIf			
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			EndIf
			//Add vencimento no array
			If Alltrim(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			EndIf			
			
			SE1->(DbSkip())
		EndDo
	EndIf
	
	nValLiq		:= SF2->F2_VALBRUT-(nIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	nDescon		:= 0
	
	SB1->(DbSetOrder(1))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	While SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
		Aadd(aServ,{SD2->D2_QUANT, Alltrim(SB1->B1_DESC), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		nDescon += SD2->D2_DESCON   
		
		SD2->(DbSkip())
	EndDo
	 
	cMsgServ += "DESCRICAO DOS SERVICOS PRESTADOS                         VALOR LIQUIDO"+ "|"
    
	nServ :=1
	While nServ <= Len(aServ)
		cMsgServ += PADR(aServ[nServ][2],57)+ " " +PADR(Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99")),16)+ "|"
		nServ +=1
	EndDo

	cMsgServ+=  "|" 
	
	i :=1
	While i <= Len(aVen)
		cMsgServ+="|| Vencimento: "+ALLTRIM(str(i))+" - "+aVen[i][1]
		i+=1
	End
	
	If Len(EXTENSO(nValLiq)) < 70
		cMsgServ+="|| Total Liquido (Valor Total dos Serviços): " +Alltrim(Transform(nValLiq, "@E 999,999,999,999.99"))+" ("+EXTENSO(nValLiq)+ ") "
	Else
		cMsgServ+="|| Total Liquido (Valor Total dos Serviços): " +Alltrim(Transform(nValLiq, "@E 999,999,999,999.99"))+" |("+EXTENSO(nValLiq)+") "
	EndIf

	//Mensagem para nota
	If !Empty(SC5->C5_MENNOTA)
		cMsgServ +="|| "+ Alltrim(SC5->C5_MENNOTA)
	EndIf
	
	cMsgServ +="||Agencia: "+Alltrim(SC5->C5_P_AG)
	
	cMsgServ +="|Desconto Padrão: "+Alltrim(Transform(SC5->C5_P_COMIS,"@E 99,999,999,999.99"))

	cMsgServ +="|Campanha: "+Alltrim(SC5->C5_P_CAMPA)

	cMsgServ +="|PI: "+Alltrim(SC5->C5_P_PI)

	cMsgServ +="|ID: "+Alltrim(SC5->C5_P_REF)+Space(95-TamSx3("C5_P_REF")[1])
	
	If Len(cMsgServ)> 1000
		cNatOper += SubStr(FwNoAccent(cMsgServ),1,1000)
	Else
		cNatOper += FwNoAccent(cMsgServ)
	EndIf
	RestArea(aArea)	
 	
//RRP - 16/04/2018 - Customização empresa Twitter	
ElseIf cEmpAnt $ "TP"

	//Retirando a descrição do serviço que carrega no SX5
	cNatOper := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
	
	aArea := GetArea()

	cMsgServ	:= ""
	cDescItem	:= "VEICULACAO DE MATERIAL PUBLICITARIO NA INTERNET:"
	XPCC_COF 	:= XPCC_CSLL := XPCC_PIS := 0
	nIrrf		:= nISS := nInss := nValLiq := 0
	lDescInc	:= .F.
	aVen   		:= {}
	aServ    	:= {}

	//Item do Pedido
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))//C6_FILIAL+C6_NUM+C6_ITEM

	//Desconto incondicional
	DbSelectArea ("ZX5")
	ZX5->(DbSetOrder(1))
	ZX5->(DbSeek(xFilial("ZX5")+SC5->C5_P_NUM))
	If ZX5->ZX5_MSBLQL <> '1' .AND. ZX5->ZX5_DESC == '1' 
		lDescInc:= .T.
	EndIf
	
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If !Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		While SE1->(!Eof()) .And. SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				nIrrf := SE1->E1_VALOR
			EndIf			
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			EndIf
			//Add vencimento no array
			If Alltrim(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			EndIf			
			
			SE1->(DbSkip())
		EndDo
	EndIf
	
	nValLiq		:= SF2->F2_VALBRUT-(nIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	nDescon		:= 0
	
	SB1->(DbSetOrder(1))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	While SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
		Aadd(aServ,{SD2->D2_ITEM, Alltrim(SB1->B1_DESC), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		nDescon += SD2->D2_DESCON
	
		SD2->(DbSkip())
	EndDo
	
	If !Empty(SC6->C6_P_AGEN)
		cMsgServ += " Agencia: "+Alltrim(SC6->C6_P_AGEN)+"|"
	EndIf
	
	//Numero IO e Numero PO
	If !Empty(SC5->C5_P_NUM) .OR. !Empty(SC5->C5_P_PO)
		cMsgServ +=" Numero IO: "+ Alltrim(SC5->C5_P_NUM) + "/ Numero PO: " + Alltrim(SC5->C5_P_PO) +"|"
 	EndIf
	
	i :=1
	While i <= Len(aVen)
		cMsgServ+=" Vencimento: "+Alltrim(str(i))+" - "+aVen[i][1]+"|"
		i+=1
	EndDo
 
	cMsgServ += "|ITEM DESCRICAO DOS SERVICOS PRESTADOS                        VALOR UNIT       VALOR TOTAL"+ "|"

	nServ :=1
	While nServ <= Len(aServ)
		cMsgServ += PADR(Alltrim(aServ[nServ][1]),4)+ " " +PADR(cDescItem,55)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
		cMsgServ += Space(5)+Alltrim(aServ[nServ][2])
		//Desconto incondicional
		If lDescInc
			cMsgServ += " (Pos-desconto*)|"
		Else
			cMsgServ +=	"|"
		EndIf
		nServ +=1
	EndDo
	cMsgServ+=  "|" 
	If Len(EXTENSO(SF2->F2_VALBRUT)) < 80
		cMsgServ+="Total dos servicos: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" ("+EXTENSO(SF2->F2_VALBRUT)+ ") "
	Else
		cMsgServ+="Total dos servicos: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" |("+EXTENSO(SF2->F2_VALBRUT)+") "
	EndIf
	
	//Desconto incondicional
	If lDescInc
		cMsgServ+="|| *Veiculacao de Material Publicitario na internet no valor de R$ "+AllTrim(Transform((SF2->F2_VALBRUT*100)/(ZX5->ZX5_PERDES),"@E 999,999,999.99"))
		cMsgServ+="| Desconto incondicional de "+AllTrim(Transform(ZX5->ZX5_PERDES,"@E 99.99"))+"% concedido conforme contrato de Amplify. "
		cMsgServ+="| Total Faturado R$ "+AllTrim(Transform(SF2->F2_VALBRUT,"@E 999,999,999.99"))
	ElseIf nDescon > 0
		cMsgServ +="|| Desconto "+ Alltrim(Transform (nDescon, "@E 999,999.99"))
	EndIf
	
	If nISS > 0
		cMsgServ+= "| ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))
	EndIf

	cMsgServ +="|| Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))
	//Mensagem para nota
	If !Empty(SC5->C5_MENNOTA)
		cMsgServ +="| "+ Alltrim(SC5->C5_MENNOTA)
	EndIf
		
	If Len(cMsgServ)> 1000
		cNatOper += SubStr(FwNoAccent(OemToAnsi(cMsgServ)),1,1000)
	Else
		cNatOper += FwNoAccent(OemToAnsi(cMsgServ))
	EndIf
	RestArea(aArea)
ElseIf cEmpAnt $ "S2" //Cognizant

	//Retirando a descrição do serviço que carrega no SX5
	//cNatOper  := If(FindFunction('CleanSpecChar'),CleanSpecChar(Alltrim(SC5->C5_MENNOTA)),SC5->C5_MENNOTA)+" "
	cNatOper	:= ""
	
	aArea := GetArea()

	cMsgServ	:= ""
	XPCC_COF 	:= XPCC_CSLL := XPCC_PIS := 0
	nIrrf		:= nISS := nInss := nValLiq := 0
	lDescInc	:= .F.
	lTemCamp	:= .F.
	aVen   		:= {}
	aServ    	:= {}
	aDadosBan	:= {}

	//Item do Pedido
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))//C6_FILIAL+C6_NUM+C6_ITEM
		
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))
	If !Empty(SF2->F2_PREFIXO+SF2->F2_DUPL)
		While SE1->(!Eof()) .And. SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'IR-'
				nIrrf := SE1->E1_VALOR
			EndIf			
			IF SE1->E1_TIPO = 'PI-'
				XPCC_PIS += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'CF-'
				XPCC_COF += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'CS-'
				XPCC_CSLL += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'IS-'
				nISS += SE1->E1_VALOR
			EndIf
			IF  SE1->E1_TIPO = 'IN-'
				nInss += SE1->E1_VALOR
			EndIf
			//Add vencimento no array
			If Alltrim(SE1->E1_TIPO) == 'NF'
				Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			EndIf			
			
			SE1->(DbSkip())
		EndDo
	EndIf
	
	nValLiq		:= SF2->F2_VALBRUT-(nIrrf+XPCC_PIS+XPCC_COF+XPCC_CSLL+nISS+nInss)
	nDescon		:= 0
	
	SB1->(DbSetOrder(1))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	While SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
		Aadd(aServ,{SD2->D2_QUANT, Alltrim(SB1->B1_DESC), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		nDescon += SD2->D2_DESCON   
		
		SD2->(DbSkip())
	EndDo    
	 
	cMsgServ += "DESCRICAO DOS SERVICOS PRESTADOS"+ "|"
    
	nServ :=1
	While nServ <= Len(aServ)
		cMsgServ += PADR(aServ[nServ][2],57)+ " |"
		nServ +=1
	EndDo

	cMsgServ+=  "|" 
	
	i :=1
	While i <= Len(aVen)
		cMsgServ+="|| Vencimento: "+ALLTRIM(str(i))+" - "+aVen[i][1]
		i+=1
	End
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)) 
	If  SA1->A1_P_BOLTE == '2'
		cMsgServ += "|| Banco: "+Alltrim(SA1->A1_P_BANCO)+" | Agencia: "+Alltrim(SA1->A1_P_AGENC)+" | Conta: "+Alltrim(SA1->A1_P_CONTA)
	EndIf
	 
	cMsgServ +="|| "
	
	If !Empty(RemCharEs(SC5->C5_MENNOTA))
   		cMsgServ += Alltrim(RemCharEs(SC5->C5_MENNOTA))//Remover caracteres especiais.
	EndIf
	

	If Len(EXTENSO(nValLiq)) < 70
		cMsgServ+="|| Total Liquido (Valor Total dos Serviços): " +Alltrim(Transform(nValLiq, "@E 999,999,999,999.99"))+" ("+EXTENSO(nValLiq)+ ") "
	Else
		cMsgServ+="|| Total Liquido (Valor Total dos Serviços): " +Alltrim(Transform(nValLiq, "@E 999,999,999,999.99"))+" |("+EXTENSO(nValLiq)+") "
	EndIf
	
	If Len(cMsgServ)> 1000
		cNatOper += SubStr(FwNoAccent(cMsgServ),1,1000)
	Else
		cNatOper += FwNoAccent(cMsgServ)
	EndIf
	RestArea(aArea)	
EndIf

//Ajuste para prefeitura de Porto Alegre - RS e para prefeitura de SP pois há um limite de 75 caracteres.
//Deixar um email apenas para o tomador
If Alltrim(SM0->M0_ESTCOB) == 'RS' .OR. Alltrim(SM0->M0_ESTCOB) == 'SP'
	If AT(';',aDest[16]) > 0
		aDest[16]:= SubStr(aDest[16],1, AT(';',aDest[16])-1)
	ElseIf AT(',',aDest[16]) > 0
		aDest[16]:= SubStr(aDest[16],1, AT(',',aDest[16])-1)
	EndIf
EndIf

//Gravação do retorno
aadd(aRet,aDest)
aadd(aRet,cNatOper)
aadd(aRet,cDescrNFSe) 
     
Return aRet   
//Função para remover os caracteres especiais
*-------------------------*
Static Function RemCharEs(cMensagem)
*-------------------------* 
Local cListChar := "!@#$%¨&*¬¢§"

For i := 0 To len(cListChar)
  	cMensagem := StrTran(cMensagem, SubStr(cListChar, i, 1), '')
Next

return FwCutOff(cMensagem,.T.) 
