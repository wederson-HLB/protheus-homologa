#include "Protheus.ch"

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

IF SM0->M0_CODIGO=="ED"                //Okuma
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
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN})
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
	
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+" - "
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+"|"
	c_Serv += "DE ACORDO COM ARTIGO 30 DA LEI 10.833/2003 DA LISTA DE SERVIÇOS CONSTANTES NO ART 647 DO REGULAMENTO DO IMPOSTO DE RENDA, OS SERVIÇOS DE ASSISTENCIA TÉCNICA PRESTADO A TERCEIROS E CONCERNENTE A RAMO DE INDUSTRIA E COMÉRCIO EXPLORADO PELO PRESTADOR DE SERVIÇO NÃO É PASSIVEL DE RETENÇÃO DE PIS/COFINS/CONTRIBUIÇÃO SOCIAL, assim como  a MANUTENÇÃO reparadora ou corretiva , pois NÃO SE TRATA DE SERVIÇOS DE MANUTENÇÃO PREVENTIVA e CONTINUADA. - (SOLUÇÃO DE CONSULTA N.º 447 DE 30/11/2006)"

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
	
ELSEIF SM0->M0_CODIGO=="RS".OR.SM0->M0_CODIGO=="E5"   // Empresa Messe

	// Inicializa variaveis.
	_nItem  := 0
	_cTexto := ""
	_cChave := ""
	_aImpostos := {}
	_cTipo  := ""
	_nPesq  := ""
    _cNPedid:= ""
    _cChar  := IF(Alltrim(Funname()) == "MATA916", chr(13), "|")
	c_Serv	 := ""

	IF Alltrim(Funname()) == "MATA916"
		Alert("Impressão de RPS: "+Funname())
	Endif
	
	// Posiciona o SF2.
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA),.t.)
	IF Eof()
		Return("")
	Endif

	// Posiciona o SD2.
	SD2->(dbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
	SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE))
                   

	// Posiciona o SC6.
	SC6->(dbSetOrder(2))
	SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))

	// Posiciona o SC5.
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))

	// Posiciona o SE1.
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL))

	// Pega a Mensagem da Nota.
	cMens		:= Alltrim(SC5->C5_MENNOTA)

	// Pega a Mensagem da Formula.
	cMensTes := Formula(SC5->C5_MENPAD)

        
	// Pega os Itens da Nota.
	dbSelectArea("SD2")
	_nRecn   := Recno()
	_cChave  := SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
	_cNPedid := SD2->D2_PEDIDO
	_cTexto  := ""

	Do While SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+_cChave .And. ! Eof()
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))

		// Posiciona o SF4.
		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))

		If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
			_cTexto += AllTrim(SB1->B1_DESC)+" - "+AllTrim(SC6->C6_DESCRI)+_cChar
			//Aadd(aServ,{AllTrim(SB1->B1_DESC)+" - "+AllTrim(SC6->C6_DESCRI),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI,SC6->C6_P_METRO})
		Endif
		
		dbSelectArea("SD2")
		DbSkip()
	Enddo

	// Se não tem produto de serviço, encerra.
	IF Empty(_cTexto)
		IF Alltrim(Funname()) == "MATA916"
			alert("Não existe produto de serviço para esta nota...")
		Endif
		Return("")
	Else
		_cTexto := _cChar+_cTexto
	Endif
	    
	// Pega os titulos de impostos para essa nota fiscal (BOLI/PRS)
	_aImpostos := {}
	_cChave	:= SF2->(F2_CLIENTE+F2_LOJA)+"RCA"+_cNPedid //00090501RCA001465	


	dbSelectArea("SE1")
	dbSetOrder(2)  // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	dbSeek(xFilial("SE1")+_cChave)
	
	Do While !Eof() .and. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1")+_cChave
	    
		If SE1->E1_TIPO$"IR-/CS-/PI-/CF-/IS-"
			_cTipo := IF(E1_TIPO=="IR-", "IRRF", IF(E1_TIPO=="CS-", "CSLL",IF(E1_TIPO=="PI-", "PIS",IF(E1_TIPO=="CF-", "COFINS", "ISS"))))
			_nPesq := Ascan(_aImpostos, {|x| x[1] == _cTipo})
			IF _nPesq == 0
				aadd(_aImpostos,{_cTipo,  SE1->E1_VALOR})
			Else
				_aImpostos[_nPesq][2] += SE1->E1_VALOR
			Endif
		Endif
		
		dbSkip()
	Enddo
                  
	// Adiciona os impostos na mensagem do pedido. (BOLI/PRS)
	For _nItem = 1 to Len(_aImpostos)
		_cTexto += _aImpostos[_nItem][1] + ": R$ "+Alltrim(Transform(_aImpostos[_nItem][2], "@E 9,999,999.99"))+_cChar
	Next
	    

	// Adiciona a mensagem da nota no texto.
	IF  !Empty(cMens)
		Do While Len(cMens) > 0
			_cTexto += Substr(cMens,1,80)+_cChar

			cMens := Subs(cMens, 81)
		Enddo
	endif

	//_cTexto += IF(! Empty(cMens), cMens+_cChar+chr(10), " ")

	IF !Empty(cMensTes)  
		_cTexto += _cChar + _cTexto
		
		Do While Len(cMensTes) > 0
			_cTexto += Substr(cMensTes,1,80)+_cChar

			cMensTes := Subs(cMensTes, 81)
		Enddo
	Endif
               
	c_Serv := _cTexto

	DBSELECTAREA( cAlias )
	
ElseIF SM0->M0_CODIGO=="ZK" .Or.  SM0->M0_CODIGO=="XC"  // Empresa Interior Design
	
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1 
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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
	
	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
    
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

ElseIF SM0->M0_CODIGO $ "CH/Z4/ZB/ZF/Z8" // Empresas gtcorp
	
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
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/	

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
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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
	
	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	
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



ElseIF SM0->M0_CODIGO=="CJ" 
	
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1 
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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
	
	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
    	
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
	
	
ElseIF SM0->M0_CODIGO=="E4"		// Empresa DexBrasil


	c_Serv	:= ""
	MenPCC	:= ""
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    	/*Consulte chamado 027985 para ver a mensagem retirada*/
		SD2->(dbSkip())
	end
	
	nServ :=1 
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
		nServ  +=1
	End
	c_Serv+=  "|"
	c_Serv+="Total dos serviços: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" ("+EXTENSO(SF2->F2_VALBRUT)+ ") -"
	i :=1
	While i <= Len(aVen)
		c_Serv+=" Vencimento "+ALLTRIM(str(i))+": "+aVen[i][1]+" - "
		i+=1
	End

	If nISS > 0
		c_Serv+= " ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))+" -"
	EndIf
	
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
	
ElseIF SM0->M0_CODIGO=="DT"  // Empresa DUN

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
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
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
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN})
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
	   IF (SE4->E4_CODIGO <> "004") .OR. (SE4->E4_CODIGO <> "031")
		c_Serv+= " Vencimento "+ALLTRIM(str(i))+" -"+aVen[i][1]+" - "
		Endif
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
	ENDIF
	IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
		c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + " /" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +" /"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99")) + " -"
	ENDIF   

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/	

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
	
	c_Serv += "||||||"
	c_Serv += "Atenção de: "+Alltrim(SA1->A1_CONTATO)+"|"
	c_Serv += "Destinatário: "+Alltrim(SA1->A1_NOME)+" - "+"CFP/CNPJ: "+ IF(SA1->A1_PESSOA="J",Transform(SA1->A1_CGC, "@R 99.999.999/9999-99"),Alltrim(Transform(SA1->A1_CGC, "@R 99.999.999-9")))+ "|"
	c_Serv += "Endereço: "+Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" - CEP: "+Alltrim(SA1->A1_CEP)+"|"
	c_Serv += "Município: "+Alltrim(SA1->A1_MUN)+" - UF: "+Alltrim(SA1->A1_EST)
	c_Serv += "||||"
	c_Serv += "************************************************************************************" + "|"
	c_Serv += "*  A D&B é comprometida com a comunidade de negócios participantes do programa de  *" + "|"
	c_Serv += "* referências comerciais. Nesse sentido, as informações relativas ao comportamento *" + "|"
	c_Serv += "* decorrente dessa fatura serão incluídas nos cadastros da própria D&B.            *" + "|"
    c_Serv += "*                                                                                  *" + "|"
	c_Serv += "* Para maiores informações, ligue (11) 2107-6831 / 2107-6800                       *" + "|"
    c_Serv += "************************************************************************************"
   
	DBSELECTAREA( cAlias )	
	                      

ElseIF SM0->M0_CODIGO=="07"  // Empresa Engecorps

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
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
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
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN})
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
	   IF (SE4->E4_CODIGO <> "004") .OR. (SE4->E4_CODIGO <> "031")
		c_Serv+= " Vencimento "+ALLTRIM(str(i))+" -"+aVen[i][1]+" - "
		Endif
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
	//c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"
	//c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+" - "
	//c_Serv += Alltrim(+SC5->C5_MENNOTA)
	//c_Serv += "||||||"
	//c_Serv += "Atenção de: "+Alltrim(SA1->A1_CONTATO)+"|"
	//c_Serv += "Destinatário: "+Alltrim(SA1->A1_NOME)+" - "+"CFP/CNPJ: "+ IF(SA1->A1_PESSOA="J",Transform(SA1->A1_CGC, "@R 99.999.999/9999-99"),Alltrim(Transform(SA1->A1_CGC, "@R 99.999.999-9")))+ "|"
	//c_Serv += "Endereço: "+Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO)+" - CEP: "+Alltrim(SA1->A1_CEP)+"|"
	//c_Serv += "Município: "+Alltrim(SA1->A1_MUN)+" - UF: "+Alltrim(SA1->A1_EST)
	//c_Serv += "||||"
	
	DBSELECTAREA( cAlias )	
  	                      

ElseIF SM0->M0_CODIGO =="48" .OR. SM0->M0_CODIGO =="49"	// Discovery Publ.

	c_Serv	:= ""
	nValor	:= nValLiq:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	:= 0
	nValLiq	:= 0
   xVend 	:= {}
   cVend		:= {}
  	aServ    := {}
	aVen 		:= {}
	Descon 	:= 0
   
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
	
    cAgenc   := SC5->C5_P_AGC
    cNomeAge := SC5->C5_P_NMAGC
    cNumPi   := SC5->C5_P_PI
	Descon   := SF2->F2_DESCONT
    nPerc    := SC6->C6_DESCONT 		//Comissão da agência - percentual
    mes	     := val(SC5->C5_P_VINCU)
    ano	     := SC5->C5_P_VIANO
   
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
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_TOTAL+SD2->D2_DESCON})
		SD2->(dbSkip())
	end
	
	For i:= 1 to 5
		xVend := ("SC5->C5_VEND"+(ALLTRIM(STR(I))))
		If! Empty(&xVend)   
   		SA3->(dbSetOrder(1))
		  	SA3->(DbSeek(xFilial("SA3")+&xVend))          	
			Aadd(cVend,{SA3->A3_NOME})
		EndIF   
	End
	nServ :=1
	
	While nServ <= Len(aServ)
		c_Serv+= "INSERÇÃO "+ MesExtenso(mes) +"/"+ ano +"|"  	//CAS - 27-03-2018 - Alterado De: VEICULAÇÃO Para:INSERÇÃO, conforme e-mail da Camila Lopes.  
		c_Serv+= aServ[nServ][1] +  " Valor R$: " + Alltrim(Transform(aServ[nServ][2], "@E 999,999,999,999.99"))+ EXTENSO(aServ[nServ][2]) +"|"
		nServ +=1
	End
	
	i :=1
	While i <= Len(aVen)
		c_Serv+="Vencimento: "+ALLTRIM(str(i))+" - "+aVen[i][1]+"|"
		i+=1
	End

	If nISS > 0
		c_Serv+= " ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))+" -"
	EndIf
	If nInss > 0
		c_Serv+= " INSS Retido "+Alltrim(Transform (nInss, "@E 999,999.99"))+" -"
	EndIf	
	IF cIrrf > 0
		c_Serv+= " IRRF "+Alltrim(Transform (cIrrf, "@E 999,999.99"))+" -"
		IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
			c_Serv+= " Pis/Cofins/Csll "+Alltrim(Transform (XPCC_PIS, "@E 999,999.99"))  + " /" +Alltrim(Transform (XPCC_COF, "@E 999,999.99")) +" /"+ Alltrim(Transform (XPCC_CSLL, "@E 999,999.99"))
		ENDIF
	ENDIF
	       
	If nPerc > 0
	   //c_Serv +="|Comissão Agencia: ("+AllTrim(Str(Round(nPerc,2)))+" %) R$: "+Alltrim(Transform (Descon,"@E 999,999,999.99"))+"|"
	   //alterado a pedido do chamado 000485 - M
	   c_Serv +="|REFERENCIA PADRÃO (REMUNERAÇÃO DA AGENCIA ITEM 1,11 DAS NORMAS PADRÃO DA ATIVIDADE PUBLICITÁRIA): ("+AllTrim(Str(Round(nPerc,2)))+" %) R$: "+Alltrim(Transform (Descon,"@E 999,999,999.99"))+"|"
    EndIF
   
	c_Serv +="Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+"|"
   
    If! Empty(cNumPi)
       c_Serv+= "PI no. "+cNumPi+"|"
    Endif

	If! Empty(cAgenc)
		c_Serv+="Agencia: "+cNomeAge+"|"
    Endif
	
	c_Serv += "Vendedor(s): "
	For i:=1 to LEN(cVend)
       c_Serv += Alltrim((cVend[i,1])) + " / "
    End
    
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
	
ElseIf SM0->M0_CODIGO=="GY" .Or. SM0->M0_CODIGO=="GV"  //   VSB e VeriSing Internet

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
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
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
		c_Serv+= aServ[nServ][1]+ " Valor R$ " + Alltrim(Transform(aServ[nServ][2], "@E 999,999,999,999.99")) + EXTENSO(aServ[nServ][2])+" - "
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
	
	//c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"    // TLM 
	//c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+" - "      // TLM 
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

ElseIf SM0->M0_CODIGO=="GY" .Or. SM0->M0_CODIGO=="GV" .Or. SM0->M0_CODIGO=="96"  //   VSB e VeriSing Internet

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
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
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
	
	//c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"    // TLM 
	//c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+" - "      // TLM 
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
	
	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/		

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



Elseif SM0->M0_CODIGO $ "57"

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

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	
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


//--------------fim da 57	
// MSM - 14/06/2012 - Alterado para atender o chamado 005620, tratamento de ISS
Elseif SM0->M0_CODIGO $ "XN"

	c_Serv:= ""
	nValor	:= nValLiq:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS :=0
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

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	
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
	
//TGS - 21/08/2012 - Parametrização para atender o chamado 006537 - PCC RPS
ElseIF SM0->M0_CODIGO=="63"  // Empresa JM&A GT01
	
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
			 //RRP - 22/10/2013 - Ajuste chamado 011219.
			IF SE1->E1_TIPO $ 'PIS/PI-'
				XPCC_PIS += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO $ 'COF/CF-'
				XPCC_COF += SE1->E1_VALOR
			endif
			IF  SE1->E1_TIPO $ 'CSL/CS-'
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1 
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	

	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
	
	//TGS - 21/08/2012 : - tratamento para atender a erro missmatch quando C5_MENPAD esta em branco. Chamado: 006537
	if !empty(SC5->C5_MENPAD)
		c_Serv += Formula(SC5->C5_MENPAD)
	endif      
	DBSELECTAREA( cAlias ) 
	
//TGS - 30/08/2012 - Parametrização para atender o chamado 006784 - PCC RPS
ElseIF SM0->M0_CODIGO=="2O"  // Empresa ABSOLUTE GT03
	
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1 
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	

	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
	
	//TGS - 21/08/2012 : - tratamento para atender a erro missmatch quando C5_MENPAD esta em branco. Chamado: 006537
	if !empty(SC5->C5_MENPAD)
		c_Serv += Formula(SC5->C5_MENPAD)
	endif      
	DBSELECTAREA( cAlias )
     
//TGS - 30/08/2012 - Parametrização para atender o chamado 006952 - PCC RPS
ElseIF SM0->M0_CODIGO=="FN"  // Empresa APPLEBEE´S AMB01
	
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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
	    if SB1->B1_PIS=="1" .AND. SB1->B1_COFINS=="1" .AND. SB1->B1_CSLL=="1"
			c_Serv +=" Reter 4,65% ref. PIS/COFINS/CSLL somente se o valor for superior a R$ 5.000,00"	    
		endif
	endif

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
	
	//TGS - 21/08/2012 : - tratamento para atender a erro missmatch quando C5_MENPAD esta em branco. Chamado: 006537
	if !empty(SC5->C5_MENPAD)
		c_Serv += Formula(SC5->C5_MENPAD)
	endif      
	DBSELECTAREA( cAlias )   
	
//JSS - 29/09/2014 - Tratamento para empresa Mediamath
ElseIF SM0->M0_CODIGO=="IY"  // Empresa APPLEBEE´S AMB01
	
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SD2->D2_QUANT, subs(SC6->C6_DESCRI,1,30), SD2->D2_PRCVEN, SD2->D2_TOTAL})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1
	//RRP - 11/02/2015 - Ajuste para alinhamento das colunas. Chamado 024366.
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"
	While nServ <= Len(aServ)
		c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
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

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
    
	c_Serv +=" Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))+"|"
	c_Serv += Alltrim(+SC5->C5_MENNOTA)+Alltrim(+SC5->C5_P_MENS1)+Alltrim(+SC5->C5_P_MENS2)+Alltrim(+SC5->C5_P_MENS3)+ "|"
	
	if !empty(SC5->C5_MENPAD)
		c_Serv += Formula(SC5->C5_MENPAD)
	endif      
	DBSELECTAREA( cAlias )
	
//RRP - 28/01/2013 - Tratamento para empresa IS Informatica
ElseIf SM0->M0_CODIGO=="4Z"
	//Verifica se o campo customizado no pedido de venda está preenchido para enviar a descrição do RPS.
	If !Empty(SC5->C5_P_DESCR)
		c_Serv:= ""
		c_Serv:=(SC5->C5_P_DESCR)
		
		aSepara := SEPARA(cServ,(Chr(13)+Chr(10)))
		c_Serv	:=""
		For j:= 1 To Len(aSpeara)
	    	c_Serv += aSepara[j]+"|"
		Next j
	
	//Se o campo estiver em branco preencher com as configurações padrões.
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

		//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
	    /*Consulte chamado 027985 para ver a mensagem retirada*/
	
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
	Endif
//RRP - 28/01/2013 - Final do tratamento para empresa IS Informatica

//JSS - 05/08/2014 - Alterado para solucionar o caso 0020263  
//RRP - 02/12/2013 - Tratamento para empresa Equant (Orange)
/*ElseIf SM0->M0_CODIGO $ "LW/LX/LY"
	c_Serv:= ""
	DbSelectArea("SD2")
	DbSetOrder(3)
	If DbSeek(xFilial("SD2") + PARAMIXB[1] + PARAMIXB[2] + PARAMIXB[3] + PARAMIXB[4])
		While SD2->(!EOF()) .And. SD2->D2_DOC == PARAMIXB[1] .And. SD2->D2_SERIE == PARAMIXB[2] .And. SD2->D2_CLIENTE == PARAMIXB[3]
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + SD2->D2_COD))
			c_Serv += Alltrim(SB1->B1_DESC)+"; "
			SD2->(DbSkip())
		End
	EndIf
*/
//RRP - 30/10/2015 - Realmedia. Chamado 030416.
ElseIf cEmpAnt == "BJ"

	c_Serv:= ""
	nValor	:= 0
	XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	:= 0
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

	c_Serv += Alltrim(+SC5->C5_MENNOTA)
	
	i :=1
	While i <= Len(aVen)
		c_Serv+="|| Vencimento: "+aVen[i][1]
		i+=1
	End
	
	IF Descon > 0
		c_Serv +="|| Desconto "+ Alltrim(Transform (Descon, "@E 999,999.99"))
	EndIf
	If nISS > 0
		c_Serv+= "|| ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))
	EndIf
		
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

//AOA - 02/08/2016 - Customização da descrição da nota de serviço
ElseIF SM0->M0_CODIGO=="EI" // Empresa ACCEDIAN
	
	c_Serv	    := ""
	nValor	    := nValLiq:= 0
	XPCC_COF    := XPCC_CSLL := XPCC_PIS := 0
	cIrrf		:= 0
	nISS		:= 0
	nInss		:= 0
	xReter 	    := 0
	nValLiq	    := 0
	nNumItem    := 0
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
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
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
	
	SD2->(dbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(dbSetOrder(2))
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		Aadd(aServ,{SC6->C6_P_COD, SC6->C6_DESCRI,SD2->D2_QUANT, SD2->D2_PRCVEN, SD2->D2_TOTAL, SD2->D2_UM, SC6->C6_P_ITEMT})
		Descon = Descon + SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1 
	
	If SUBSTR(SA1->A1_CGC,1,8) = '02558157' //Telfonica 
		c_Serv += "ITEM   CODIGO     DESCRICAO                               QTDE   VALOR UNITARIO  VALOR TOTAL"+ "|"
		While nServ <= Len(aServ)
			nNumItem := nNumItem+10
			c_Serv   += +STRZERO(nNumItem,5)+"  "+PADR(Alltrim(aServ[nServ][1]),8)+"   "+PADR(Alltrim(aServ[nServ][2]),39)+" "+PADR(Alltrim(Transform(aServ[nServ][3], "@E 99.99")),5)+"  R$ "+PADR(Alltrim(Transform(aServ[nServ][4], "@E 9,999,999.9999")),13)+"R$ "+Alltrim(Transform(aServ[nServ][5], "@E 999,999,999.99"))+"|"
			//Verifica se ainda tem mais descrição
			If LEN(SUBSTR(Alltrim(aServ[nServ][2]),40,39)) > 1
				c_Serv   += +"                 "+SUBSTR(Alltrim(aServ[nServ][2]),40,39)+"|"
				If LEN(SUBSTR(Alltrim(aServ[nServ][2]),78,39)) > 1
					c_Serv   += +"                 "+SUBSTR(Alltrim(aServ[nServ][2]),78,39)+"|"
				EndIf
			EndIf
			nServ    +=1
		End                              
		c_Serv += +"|"
	    
		c_Serv += +" Operadora: "+Alltrim(SC5->C5_P_OPERA)+"||"

		c_Serv += +" Pedido nº: "+Alltrim(SC5->C5_P_PEDID)+"||"

		c_Serv += +" Nº do Contrato: "+Alltrim(SC5->C5_P_CONTR)+"||"

		c_Serv += +" Condição de Pagamento: "+Alltrim(SC5->C5_P_CONDP)+"||"

		c_Serv += +" Elemento Pep: "+Alltrim(SC5->C5_P_ELPEP)+"||"
		
		c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
		
		if !empty(SC5->C5_MENPAD)
			c_Serv += Formula(SC5->C5_MENPAD)
		endif    
	
	Else //Intelig
		c_Serv += "ITEM    QTDE   UN  DESCRICAO                                VALOR UNITARIO   VALOR TOTAL"+ "|"
		While nServ <= Len(aServ)
			c_Serv   += +Alltrim(aServ[nServ][7])+"  "+STRZERO(aServ[nServ][3],5)+"   "+PADR(Alltrim(aServ[nServ][6]),2)+"  "+PADR(Alltrim(aServ[nServ][2]),39)+"  R$ "+PADR(Alltrim(Transform(aServ[nServ][4], "@E 9,999,999.9999")),13)+" R$ "+Alltrim(Transform(aServ[nServ][5], "@E 999,999,999.99"))+"|"
			//Verifica se ainda tem mais descrição
			If LEN(SUBSTR(Alltrim(aServ[nServ][2]),40,39)) > 1
				c_Serv   += +"                   "+SUBSTR(Alltrim(aServ[nServ][2]),40,39)+"|"
				If LEN(SUBSTR(Alltrim(aServ[nServ][2]),78,39)) > 1
					c_Serv   += +"                   "+SUBSTR(Alltrim(aServ[nServ][2]),78,39)+"|"
				EndIf
			EndIf
			nServ    +=1
		End                              
		c_Serv += +"|"
	    
		c_Serv += +" CONTRATO "+Alltrim(SC5->C5_P_CONTR)+"||"

		c_Serv += +" Nº PEDIDO "+Alltrim(SC5->C5_P_PEDID)+"||"

		c_Serv += +" CONDIÇÃO DE PAGAMENTO "+Alltrim(SC5->C5_P_CONDP)+"||"

		c_Serv += +" FOLHA DE SERVIÇO - "+Alltrim(SC5->C5_P_FOSER)+" - ITEM "+Alltrim(SC6->C6_P_ITEMT)+"||"
		
		c_Serv += Alltrim(+SC5->C5_MENNOTA)+ "|"
		
		if !empty(SC5->C5_MENPAD)
			c_Serv += Formula(SC5->C5_MENPAD)
		endif    	     

	EndIf
			
	DBSELECTAREA( cAlias )
	
Else

	c_Serv:= ""
	cValExt:= ""
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

	SC6->(dbSetOrder(2))
	SD2->(dbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+cCompara)) //RRP - 27/08/2015 - Ajuste no Seek porque tinha casos que não trazia todos os itens.
	While SD2->D2_DOC+SD2->D2_SERIE == cCompara
		SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
		//Aadd(aServ,{Alltrim(SC6->C6_DESCRI),SD2->D2_PRCVEN*SD2->D2_QUANT,SD2->D2_TOTAL}) // TLM  
		Aadd(aServ,{SD2->D2_QUANT, subs(Alltrim(SC6->C6_DESCRI),1,90), SD2->D2_PRCVEN, SD2->D2_TOTAL})//RRP - 26/08/2014 - 30 para 90 caracteres o corte do Campo C6_DESCRI
		Descon += SD2->D2_DESCON
		SD2->(dbSkip())
	end
	nServ :=1

	// JSS - 20140722 
	c_Serv += "QUANT     DESCRICAO DOS SERVICOS PRESTADOS                   VALOR UNIT       VALOR TOTAL"+ "|"

	While 	nServ <= Len(aServ)
			//RRP - 04/02/2015 - Ajuste para alinhamento das colunas. Chamado 022426. 
			c_Serv += +PADR(Alltrim(Transform(aServ[nServ][1], "@E 999,999.9")),9)+ " " +PADR(Alltrim(aServ[nServ][2]),50)+ " " +PADR(Alltrim(Transform(aServ[nServ][3], "@E 999,999,999.99")),16)+ " " +Alltrim(Transform(aServ[nServ][4], "@E 999,999,999.99"))+ "|"
			nServ  +=1
	End            
	c_Serv+=  "|" 
	//WFA - 01/09/2017 - Incluído quebra de linha quando o valor bruto por extenso for maior que 80 caracteres. Ticket 11138.
	If Len(EXTENSO(SF2->F2_VALBRUT)) < 80
		c_Serv+="Total dos serviços: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" ("+EXTENSO(SF2->F2_VALBRUT)+ ") "
	Else
		c_Serv+="Total dos serviços: " +Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+" |("+EXTENSO(SF2->F2_VALBRUT)+") "
	EndIf
	i :=1
	i :=1
	While i <= Len(aVen)
		c_Serv+="|| Vencimento: "+ALLTRIM(str(i))+" - "+aVen[i][1]
		i+=1
	End
	
	IF Descon > 0
		c_Serv +="|| Desconto "+ Alltrim(Transform (Descon, "@E 999,999.99"))
	EndIf
	If nISS > 0
		c_Serv+= "|| ISS Retido "+Alltrim(Transform (nISS, "@E 999,999.99"))
	EndIf

	//Matheus - 14/10/2015 - Retirado a msg de reter PCC, chamado: 027985	
    /*Consulte chamado 027985 para ver a mensagem retirada*/
	
	c_Serv +="|| Valor Liquido: "+ Alltrim(Transform (nValLiq, "@E 999,999,999,999.99"))
	c_Serv +=" "+ Alltrim(+SC5->C5_MENNOTA)
	
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

RETURN(c_Serv)