#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS001  º Autor ³ William Souza      º Data ³  26/12/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ User function para gravar a nota de entrada no ws da       º±±
±±º          ³ FEDEX                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra Brasil                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------------------------*
User Function N6WS001(nOpcao,nConfirma,nRecno)
*--------------------------------------------*
Local cUrl         := alltrim(getMV("MV_P_00116"))
Local aUser        := &(getMV("MV_P_00117"))
Local aArea        := GetArea()
Local AreaSF1      := GetNextAlias()
Local AreaSD1      := GetNextAlias()
Local cSql         := ""
Local cAccount     := ""
Local cServer      := ""
Local cMailDestino := ""
Local cXml    	    := "" 
Local oXml	       := ""
Local nTimeOut 	   := 120
Local aHeadStr 	   := {}
Local aData    	   := {}
Local cHeadRet     := ""
Local sPostRet     := "" 
Local cError       := ""
Local cWarning     := ""
Local cRetorno     := ""
Local cContent     := "" 
Local cMsg         := "" 
Local cChave       := u_N6GEN003(10)

//Query para trazer a SF1
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery("SELECT * FROM "+RetSqlName("SF1")+" WHERE R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")), AreaSF1, .F., .T.) 

If nOpcao == 3 .And. nConfirma == 1 .And. cFilAnt == "02" //inclusao
	
	IF empty((AreaSF1)->F1_P_STFED) .OR. (AreaSF1)->F1_P_STFED == ("5"+Space(TamSX3("F1_P_STFED")[1]-Len("5")))
		//Query para trazer os itens da nota de entrada
		cSQL := "SELECT ltrim(CAST(D1_VUNIT AS decimal(6,2))) AS 'D1_VUNIT', ltrim(RTRIM(D1_ITEM * 1)) AS 'D1_ITEM', ltrim(RTRIM(D1_COD)) AS 'D1_COD', ltrim(RTRIM(D1_QUANT)) AS 'D1_QUANT' "
		cSQL += "FROM "+ RetSqlName("SD1") +" WHERE D1_FILIAL = '"+xFilial("SF1")+"' AND D1_EMISSAO = '"+(AreaSF1)->F1_EMISSAO+"' " 
		cSQL += "AND D1_DOC = '" + (AreaSF1)->F1_DOC+ "' AND D1_SERIE = '"+ (AreaSF1)->F1_SERIE+"' AND D1_FORNECE = '"+(AreaSF1)->F1_FORNECE+"' AND D_E_L_E_T_ = ''"
		cSQL += "AND D1_LOJA = '"+ (AreaSF1)->F1_LOJA +"' AND D1_TP IN ('ME','PA','MP') AND D1_TES IN (SELECT F4_CODIGO FROM "+RetSqlName("SF4")+" WHERE F4_DUPLIC='S' AND D_E_L_E_T_='') " 
		
		//conecto no top e executo o SQL
		cSQL := ChangeQuery(cSQL)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaSD1, .F., .T.)
		
		IF (AreaSF1)->F1_TIPO $ "DN" .AND. !empty((AreaSD1)->D1_COD)
			
			//header do xml
			aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
			aadd(aHeadStr,"SOAPAction: sii:RECEIPT_PO_ASN_WMS10")     
			aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
			
			//monto a estrutura do XML
			   cContent := "{HEADER:{" + Chr( 13 ) + Chr( 10 )
			   cXml := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:gen='http://www.rapidaocometa.com.br/GenPoWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"+ Chr( 13 ) + Chr( 10 )
			   cXml+="<soapenv:Header/>"+ Chr( 13 ) + Chr( 10 )
			   cXml+="<soapenv:Body>"+ Chr( 13 ) + Chr( 10 )
			      cXml+="<InstancePo>"+ Chr( 13 ) + Chr( 10 )
			         cXml+="<PO>" + Chr( 13 ) + Chr( 10 )
			            cXml+="<HEADER>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-REG>H</TIPO-REG>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "TIPO-REG:H," + Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-OPER>A</TIPO-OPER>"
						   cContent += "TIPO-OPER:A," + Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-GERA>1</TIPO-GERA>"+ Chr( 13 ) + Chr( 10 )
			               cContent += "TIPO-GERA:1," + Chr( 13 ) + Chr( 10 )
						   cXml+="<TIPO-PROC-ASN>1</TIPO-PROC-ASN>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "TIPO-PROC-ASN:1," + Chr( 13 ) + Chr( 10 )
			               cXml+="<FISCAL>N</FISCAL>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "FISCAL:N," + Chr( 13 ) + Chr( 10 )
			               cXml+="<POKEY_A></POKEY_A>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<RECEIPTKEY>"+cChave+"</RECEIPTKEY>" + Chr( 13 ) + Chr( 10 )
						   cContent += "RECEIPTKEY:"+cChave+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<EXTERNPOKEY>"+cChave+"</EXTERNPOKEY>"+ Chr( 13 ) + Chr( 10 )
			               cContent += "EXTERNPOKEY:"+cChave+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<EXTERNALPOKEY2>"+cChave+"</EXTERNALPOKEY2>"+ Chr( 13 ) + Chr( 10 )
			               cContent += "EXTERNALPOKEY2:"+cChave+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<EXTERNRECEIPTKEY_1>"+cChave+"</EXTERNRECEIPTKEY_1>" + Chr( 13 ) + Chr( 10 )
			               cContent += "EXTERNRECEIPTKEY_1:"+cChave+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<EXTERNALRECEIPTKEY2></EXTERNALRECEIPTKEY2>" + Chr( 13 ) + Chr( 10 )
			               cXml+="<STATUS_A></STATUS_A>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<STATUS_B></STATUS_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<POTYPE>"+IIF((AreaSF1)->F1_TIPO == "N","0",IIF((AreaSF1)->F1_TIPO == "D","2","0"))+"</POTYPE>" + Chr( 13 ) + Chr( 10 )
						   cContent += "POTYPE:"+IIF((AreaSF1)->F1_TIPO == "N","0",IIF((AreaSF1)->F1_TIPO == "D","2","0"))+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<PODATE>"+SUBSTR((AreaSF1)->F1_EMISSAO,7,2)+SUBSTR((AreaSF1)->F1_EMISSAO,5,2)+SUBSTR((AreaSF1)->F1_EMISSAO,1,4)+"</PODATE>" + Chr( 13 ) + Chr( 10 )
			               cContent += "PODATE:"+SUBSTR((AreaSF1)->F1_EMISSAO,7,2)+SUBSTR((AreaSF1)->F1_EMISSAO,5,2)+SUBSTR((AreaSF1)->F1_EMISSAO,1,4)+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<RMA>"+cChave+"</RMA>"+ Chr( 13 ) + Chr( 10 )
			               cContent += "RMA:"+cChave+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<STORERKEY>DOTERRA</STORERKEY>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "STORERKEY:DOTERRA," + Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_VAT>"+ALLTRIM(SM0->M0_CGC)+"</STORER_VAT>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "STORER_VAT:"+ALLTRIM(SM0->M0_CGC)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_COMPANY>"+ALLTRIM(SM0->M0_NOME)+"</STORER_COMPANY>"+ Chr( 13 ) + Chr( 10 )
			               cContent += "STORER_COMPANY:"+ALLTRIM(SM0->M0_NOME)+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<ADDRESS1>"+ALLTRIM(SM0->M0_ENDCOB)+"</ADDRESS1>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "ADDRESS1:"+ALLTRIM(SM0->M0_ENDCOB)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<ADDRESS2></ADDRESS2>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ADDRESS3></ADDRESS3>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ADDRESS4></ADDRESS4>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_CITY>"+ALLTRIM(SM0->M0_CIDCOB)+"</STORER_CITY>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "STORER_CITY:"+ALLTRIM(SM0->M0_CIDCOB)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_STATE>"+ALLTRIM(SM0->M0_ESTCOB)+"</STORER_STATE>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "STORER_STATE:"+ALLTRIM(SM0->M0_ESTCOB)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_ZIP>"+ALLTRIM(SM0->M0_CEPCOB)+"</STORER_ZIP>"
						   cContent += "STORER_ZIP:"+ALLTRIM(SM0->M0_CEPCOB)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_COUNTRY></STORER_COUNTRY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<STORER_ISOCNTRYCODE></STORER_ISOCNTRYCODE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERKEY></CARRIERKEY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERNAME></CARRIERNAME>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERADDRESS1></CARRIERADDRESS1>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERADDRESS2></CARRIERADDRESS2>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERCITY></CARRIERCITY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERSTATE></CARRIERSTATE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERZIP></CARRIERZIP>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NOTE></NOTE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TYPE>1</TYPE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR1></SUSR1>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR2></SUSR2>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR3></SUSR3>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR4></SUSR4>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR5></SUSR5>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CARRIERREFEENCE></CARRIERREFEENCE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<PLACEOFDISCHARGE></PLACEOFDISCHARGE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<PLACEOFDELIVERY></PLACEOFDELIVERY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TRACKINVENTORYBY>0</TRACKINVENTORYBY>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "TRACKINVENTORYBY:0," + Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERNAME></SELLERNAME>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERVAT></SELLERVAT>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERADDRESS1></SELLERADDRESS1>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERADDRESS2></SELLERADDRESS2>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERADDRESS3></SELLERADDRESS3>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERADDRESS4></SELLERADDRESS4>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERCITY></SELLERCITY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERSTATE></SELLERSTATE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERZIP></SELLERZIP>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SELLERSREFERENCE></SELLERSREFERENCE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<BUYERSREFERENCE></BUYERSREFERENCE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<OTHERREFERENCE></OTHERREFERENCE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<VESSEL></VESSEL>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ORIGINCOUNTRY_A></ORIGINCOUNTRY_A>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<DESTINATIONCOUNTRY_A></DESTINATIONCOUNTRY_A>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<VESSELDATE></VESSELDATE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TERMSNOTE_A></TERMSNOTE_A>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<INCOTERMS_A></INCOTERMS_A>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<APPORTIONRULE></APPORTIONRULE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CONTAINERKEY></CONTAINERKEY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<WAREHOUSEREFERENCE></WAREHOUSEREFERENCE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<VEHICLENUMBER></VEHICLENUMBER>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<VEHICLEDATE></VEHICLEDATE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<PLACEOFLOADING></PLACEOFLOADING>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CONTAINERTYPE></CONTAINERTYPE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CONTAINERQTY></CONTAINERQTY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TRANSPORTATIONMODE></TRANSPORTATIONMODE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<EXPECTEDRECEIPTDATE></EXPECTEDRECEIPTDATE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ORIGINCOUNTRY_B></ORIGINCOUNTRY_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<DESTINATIONCOUNTRY_B></DESTINATIONCOUNTRY_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TERMSNOTE_B></TERMSNOTE_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<INCOTERMS_B></INCOTERMS_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NOTES></NOTES>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<POKEY_B></POKEY_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ALLOWAUTORECEIPT></ALLOWAUTORECEIPT>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ID_SITE>WMWHSE8</ID_SITE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_NUM_NOTA_FISCAL></NRI_NUM_NOTA_FISCAL>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_SERIE></NRI_SERIE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_TIPO_NOTA_FISCAL></NRI_TIPO_NOTA_FISCAL>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_VALOR_TOTAL_NOTA_FISCAL></NRI_VALOR_TOTAL_NOTA_FISCAL>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_CFOP></NRI_CFOP>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_STATUS></NRI_STATUS>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_NUM_NOTA_FISCAL_ACOB></NRI_NUM_NOTA_FISCAL_ACOB>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_SERIE_ACOB></NRI_SERIE_ACOB>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_NUM_NOTA_FISCAL_DEV></NRI_NUM_NOTA_FISCAL_DEV>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_SERIE_DEV></NRI_SERIE_DEV>"+ Chr( 13 ) + Chr( 10 )
			            cXml+="</HEADER>"+ Chr( 13 ) + Chr( 10 )
						cContent += "} ITENS:{" + Chr( 13 ) + Chr( 10 )
				While !(AreaSD1)->(EOF())
			            cXml+="<LINES>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-REG>L</TIPO-REG>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "{TIPO-REG:L," + Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-OPER>A</TIPO-OPER>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "TIPO-OPER:A," + Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-GERA>1</TIPO-GERA>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "TIPO-GERA:2," + Chr( 13 ) + Chr( 10 )
			               cXml+="<TIPO-PROC-ASN>1</TIPO-PROC-ASN>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "TIPO-PROC-ASN:1," + Chr( 13 ) + Chr( 10 )
			               cXml+="<FISCAL>N</FISCAL>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "FISCAL:N," + Chr( 13 ) + Chr( 10 )
			               cXml+="<POKEY_A></POKEY_A>"+ Chr( 13 ) + Chr( 10 )
						   cXml+="<RECEIPTKEY>"+cChave+"</RECEIPTKEY>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "RECEIPTKEY:"+cChave+"," + Chr( 13 ) + Chr( 10 )
						   cXml+="<Sequencia>"+ALLTRIM((AreaSD1)->D1_ITEM)+"</Sequencia>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "Sequencia:"+ALLTRIM((AreaSD1)->D1_ITEM)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<SKU>"+alltrim((AreaSD1)->D1_COD)+"</SKU>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "SKU:"+(AreaSD1)->D1_COD+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<SKUDESCRIPTION>"+alltrim(POSICIONE("SB1", 1, xFilial("SB1") + (AreaSD1)->D1_COD, "B1_DESC"))+"</SKUDESCRIPTION>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "SKUDESCRIPTION:"+POSICIONE("SB1", 1, xFilial("SB1") + (AreaSD1)->D1_COD, "B1_DESC")+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<PACKKEY></PACKKEY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<UOM>EA</UOM>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "UOM:EA," + Chr( 13 ) + Chr( 10 )
			               cXml+="<STATUS_1></STATUS_1>"+ Chr( 13 ) + Chr( 10 )
						   cXml+="<STATUS></STATUS>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<ORDEREDUOMQTY>"+alltrim(cvaltochar((AreaSD1)->D1_QUANT))+"</ORDEREDUOMQTY>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "ORDEREDUOMQTY:"+alltrim(cvaltochar((AreaSD1)->D1_QUANT))+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<EXPECTEDUOMQTY>"+alltrim(cvaltochar((AreaSD1)->D1_QUANT))+"</EXPECTEDUOMQTY>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "EXPECTEDUOMQTY:"+cvaltochar((AreaSD1)->D1_QUANT)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<RECEIVEDUOMQTY></RECEIVEDUOMQTY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<POKEY_B></POKEY_B>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<DATERECEIPT></DATERECEIPT>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TOID></TOID>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUPPLIERNAME></SUPPLIERNAME>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<REASONCODE></REASONCODE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<CONDITIONCODE></CONDITIONCODE>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TOLOC></TOLOC>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<TARIFFKEY></TARIFFKEY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<QCREQUIRED>0</QCREQUIRED>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "QCREQUIRED:0," + Chr( 13 ) + Chr( 10 )
			               cXml+="<QCAUTOADJUST>0</QCAUTOADJUST>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE1></LOTTABLE1>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE2></LOTTABLE2>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE3></LOTTABLE3>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE4></LOTTABLE4>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE5></LOTTABLE5>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE6></LOTTABLE6>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE7></LOTTABLE7>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE8></LOTTABLE8>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE9></LOTTABLE9>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<LOTTABLE10></LOTTABLE10>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR1>"+alltrim(StrTran(cvaltochar((AreaSD1)->D1_VUNIT),".",","))+"</SUSR1>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "SUSR1:"+cvaltochar((AreaSD1)->D1_VUNIT)+"," + Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR2></SUSR2>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR3></SUSR3>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR4></SUSR4>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<SUSR5></SUSR5>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NOTES></NOTES>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<PACKINGLIPQTY></PACKINGLIPQTY>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<MATCHLOTTABLE>0</MATCHLOTTABLE>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "MATCHLOTTABLE:0," + Chr( 13 ) + Chr( 10 )
			               cXml+="<ID_SITE>WMWHSE8</ID_SITE>"+ Chr( 13 ) + Chr( 10 )
						   cContent += "ID_SITE:WMWHSE8," + Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_NUM_NOTA_FISCAL></NRI_NUM_NOTA_FISCAL>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NRI_Serie></NRI_Serie>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<IR_ITEM_SEQUENCIA></IR_ITEM_SEQUENCIA>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_PRECO_UNITARIO></NIR_PRECO_UNITARIO>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_DESCONTO></NIR_DESCONTO>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_BASE_CALCULO_ICMS></NIR_BASE_CALCULO_ICMS>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_ALIQUOTA_ICMS></NIR_ALIQUOTA_ICMS>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_VALOR_ICMS></NIR_VALOR_ICMS>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_BASE_CALCULO_IPI></NIR_BASE_CALCULO_IPI>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_ALIQUOTA_IPI></NIR_ALIQUOTA_IPI>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_VALOR_IPI></NIR_VALOR_IPI>"+ Chr( 13 ) + Chr( 10 )
			               cXml+="<NIR_CFOP></NIR_CFOP>"+ Chr( 13 ) + Chr( 10 )
					cXml+="</LINES>"+ Chr( 13 ) + Chr( 10 )
					cContent += "}" + Chr( 13 ) + Chr( 10 )				
					(AreaSD1)->(DbSkip())  	
				Enddo
				cContent += "}" + Chr( 13 ) + Chr( 10 )	
			cXml+="</PO>"+ Chr( 13 ) + Chr( 10 )
			cXml+="</InstancePo>"+ Chr( 13 ) + Chr( 10 )
			cXml+="<mesa:mesaAuth>"+ Chr( 13 ) + Chr( 10 )
			cXml+="<mesa:principal>"+aUser[1]+"</mesa:principal>"+ Chr( 13 ) + Chr( 10 )
			cXml+="<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth>"+ Chr( 13 ) + Chr( 10 )
			cXml+="</mesa:mesaAuth>"+ Chr( 13 ) + Chr( 10 )
			cXml+="</soapenv:Body>"+ Chr( 13 ) + Chr( 10 )
			cXml+="</soapenv:Envelope>"+ Chr( 13 ) + Chr( 10 )
			
			//envio NFE para a FEDEX
			sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet) 
			
			//Atualizo a coluna de controle
			TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '1', F1_P_DTFED = '"+DTOS(ddatabase)+"',F1_P_CHAVE = '"+cChave+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")  
			
			//Grava log Transacao 
			u_N6GEN002("SF1","E","GenPoWMS10In","TOTVS","FedEX",cChave,cContent,"")

			If AT("DOCTYPE HTML PUBLIC",cvaltochar(sPostRet)) == 0 
				If AT("<faultcode>",cvaltochar(sPostRet)) == 0
					If !empty(cvaltochar(sPostRet))			
						cRetorno := sPostRet
						oXml     := XmlParser( cRetorno, "_", @cError, @cWarning ) 
						//cRetorno := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_RESPONSE:_RETORNO
						cRetorno := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_GENPOOUT_RETORNO
						
						IF cRetorno:_GENPOOUT_COD:TEXT == "000"
							cMsg := "NFe gravado no sistema e transmitido para a FedEx com sucesso."
							TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '2', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")  
							MSGINFO(cMsg,"Envio NFe para FEDEX")
						Else 	
							cMsg := "NFe gravada no sistema e não transmitida para a FedEx devido ao problema interno no retorno do webservice ("+cRetorno:_GENPOOUT_DESCRICAO:TEXT+")."
							TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '5', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")
							Alert(cMsg)  
						EndIF
					Else
							cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."
							TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '5', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")   
							Alert(cMsg)
					EndIf 
				Else
					cMsg := "Erro na estrutura do XML para envio ao webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para correção."
					TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '5', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")  
					Alert(cMsg)
				EndIF
			Else
					cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."
					Alert(cMsg)
					TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '5', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")   
			EndIf
			 DBCloseArea(AreaSD1)  
		EndIF
		
		//Grava log Transacao 
		u_N6GEN002("SF1","R","GenPoWMS10In","FedEX","Totvs",cChave,sPostRet,cMsg)
			
	Else
		Alert("Nota Fiscal já enviada e/ou processada pelo webservice da FedEx.")
	EndIF
ElseIf nOpcao == 5 .and. nConfirma == 1 .And. cFilAnt == "02" //exclusao
	IF !EMPTY((AreaSF1)->F1_P_STFED) 
		MSGINFO("NFe cancelada e solicitar o cancelamento manual da NFe na FedEx.","Cancelamento de NFe")
		TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")   
	Else
		MSGINFO("NFe cancelada com sucesso.","Cancelamento de NFe") 
		TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar(nRecno)+"'")  	 
	EndIf
EndIF 
		
DBCloseArea(AreaSF1)
RestArea(aArea)	
Return .T.