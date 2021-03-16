#INCLUDE "totvs.ch"

#DEFINE CRLF CHR(13)+CHR(10) 
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS004  º Autor ³ William Souza      º Data ³  26/12/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ User function para enviar o pedido de venda para o Picking º±±
±±º          ³ FEDEX   (MT410INC)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra Brasil                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------*
User Function N6WS004(cChave)
*---------------------------*
Local cUrl         := alltrim(getMV("MV_P_00116"))
Local aUser        := &(getMV("MV_P_00117"))
Local aArea        := GetArea()
Local cAreaSC5     := "SC5N6WS004"//GetNextAlias()
Local cAreaSC6     := "SC6N6WS004"//GetNextAlias()
Local cSql         := ""
Local cAccount     := ""
Local cServer      := ""
Local cMailDestino := ""
Local cXml    	   := "" 
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
Local lErro		   := .F. 
Local cEmail	   := ""

Local cEndA := ""
Local cEndB := ""
Local cEndC	:= ""
Local cMun	:= ""
Local cEst	:= ""
Local cCEP	:= ""
                    
If Select(cAreaSC5)>0
	(cAreaSC5)->(DbCloseArea())
EndIf

If Select(cAreaSC6)>0
	(cAreaSC6)->(DbCloseArea())
EndIf

//Query para trazer a SC5
cSQL := "SELECT * 
cSQL += " FROM "+RetSqlName("SC5")
cSQL += " WHERE C5_P_CHAVE = '"+cChave+"'
cSQL += " 	AND C5_FILIAL = '"+xFilial("SC5")+"'
cSQL += " 	AND D_E_L_E_T_ = ''"

DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cSQL)), cAreaSC5, .F., .T.) 

IF EMPTY((cAreaSC5)->C5_P_STFED) .Or. (cAreaSC5)->C5_P_STFED == "05" .Or. (cAreaSC5)->C5_P_STFED == "01"
	IF (cAreaSC5)->C5_TIPO $ "N" 
	   //header do xml
		aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
		aadd(aHeadStr,"SOAPAction: sii:RECEIPT_PO_ASN_WMS10")     
		aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')

		//Query para trazer os itens do pedido de venda
		cSQL := "SELECT * 
		cSQL += " FROM " + RetSqlName("SC6")
		cSQL += " WHERE C6_FILIAL = '"+xFilial("SC5")+"' "
		cSQL += "		AND C6_NUM = '" + (cAreaSC5)->C5_NUM+ "'
		cSQL += "		AND C6_CLI = '"+ (cAreaSC5)->C5_CLIENTE+"'
		cSQL += "		AND C6_LOJA = '"+(cAreaSC5)->C5_LOJACLI+"'
		cSQL += "		AND D_E_L_E_T_ = ''"

		//conecto no top e executo o SQL
		cSQL := ChangeQuery(cSQL)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), cAreaSC6, .F., .T.) 

		//Posiciona no cadastro de clientes
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + (cAreaSC5)->C5_CLIENTE + "01"))
		cEndA:= SUBSTR(RemoveChar(SA1->A1_END), 1,45)
		cEndB:= SUBSTR(RemoveChar(SA1->A1_END),46,15)
		cEndC:= SUBSTR(RemoveChar(SA1->A1_COMPLEM), 1,45)//O campo possui 50 caracteres, mas o WS so aceita 45
		cMun := ALLTRIM(SA1->A1_MUN)
		cEst := ALLTRIM(SA1->A1_EST)	
		cCEP := ALLTRIM(SA1->A1_CEP)
			
		//Casos de multiendereços de entrega
		If (cAreaSC5)->(FieldPos("C5_P_ENDEN"))  > 0  .and. !EMPTY((cAreaSC5)->C5_P_ENDEN) 
			ZX4->(DbSetOrder(2))
			If ZX4->(DbSeek(xFilial("ZX4")+(cAreaSC5)->C5_P_ENDEN))
		   		cEndA:= SUBSTR(RemoveChar(ZX4->ZX4_END), 1,45)
				cEndB:= SUBSTR(RemoveChar(ZX4->ZX4_END),46,15)
				cEndC:= SUBSTR(RemoveChar(ZX4->ZX4_COMPLE), 1,45)//O campo possui 50 caracteres, mas o WS so aceita 45
				cMun := ALLTRIM(ZX4->ZX4_MUN)
				cEst := ALLTRIM(ZX4->ZX4_EST)	
				cCEP := ALLTRIM(ZX4->ZX4_CEP) 
			EndIf
		EndIf

		//monto a estrutura do XML		
		cXml:="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:gen='http://www.rapidaocometa.com.br/GenSoWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"+ CRLF
		cXml+="<soapenv:Header/>"+ CRLF
		cXml+="<soapenv:Body>"+ CRLF
		cXml+="<InstanceSo>"+ CRLF
		cXml+="<SO>"+ CRLF
		cXml+="<HEADER>"+ CRLF
			cXml+="<TIPO-REG>H</TIPO-REG>"+ CRLF
			cXml+="<TIPO-OPER>A</TIPO-OPER>"+ CRLF
			cXml+="<TIPO-PROC-SO>1</TIPO-PROC-SO>"+ CRLF
			cXml+="<FISCAL>N</FISCAL>"+ CRLF
			cXml+="<WHSEID>WMWHSE8</WHSEID>"+ CRLF
			cXml+="<STORERKEY>DOTERRA</STORERKEY>"+ CRLF
			cXml+="<ORDERKEY></ORDERKEY>"+ CRLF
			cXml+="<EXTERNORDERKEY>"+cChave+"</EXTERNORDERKEY>"+ CRLF
			cXml+="<ORDERDATE>"+SUBSTR((cAreaSC5)->C5_EMISSAO,7,2)+SUBSTR((cAreaSC5)->C5_EMISSAO,5,2)+SUBSTR((cAreaSC5)->C5_EMISSAO,1,4)+"</ORDERDATE>"+ CRLF
			cXml+="<DELIVERYDATE></DELIVERYDATE>"+ CRLF
			cXml+="<PRIORITY>5</PRIORITY>"+ CRLF 
			cXml+="<CONSIGNEEKEY></CONSIGNEEKEY>"+ CRLF
			cXml+="<C_CONTACT1></C_CONTACT1>"+ CRLF
			cXml+="<C_CONTACT2></C_CONTACT2>"+ CRLF
			cXml+="<C_COMPANY>"+ALLTRIM(SA1->A1_NOME)+"</C_COMPANY>"+ CRLF
			cXml+="<C_ADDRESS1>"+cEndA+"</C_ADDRESS1>"+ CRLF
			cXml+="<C_ADDRESS2>"+cEndB+"</C_ADDRESS2>"+ CRLF
			cXml+="<C_ADDRESS3>"+cEndC+"</C_ADDRESS3>"+ CRLF
			cXml+="<C_ADDRESS4></C_ADDRESS4>"+ CRLF
			cXml+="<C_CITY>"+cMun+"</C_CITY>"+ CRLF
			cXml+="<C_STATE>"+cEst+"</C_STATE>"+ CRLF
			cXml+="<C_ZIP>"+cCEP+"</C_ZIP>"+ CRLF 
			cXml+="<C_COUNTRY>BRASIL</C_COUNTRY>"+ CRLF
			cXml+="<C_ISOCNTRYCODE></C_ISOCNTRYCODE>"+ CRLF
			cXml+="<C_PHONE1></C_PHONE1>"+ CRLF
			cXml+="<C_PHONE2></C_PHONE2>"+ CRLF
			cXml+="<C_FAX1></C_FAX1>"+ CRLF
			cXml+="<C_FAX2></C_FAX2>"+ CRLF
			cXml+="<C_VAT>"+ALLTRIM(SM0->M0_CGC)+"</C_VAT>"+ CRLF
			cXml+="<BILLTOKEY></BILLTOKEY>"+ CRLF
			cXml+="<B_CONTACT1></B_CONTACT1>"+ CRLF
			cXml+="<B_CONTACT2></B_CONTACT2>"+ CRLF
			cXml+="<B_COMPANY></B_COMPANY>"+ CRLF
			cXml+="<B_ADDRESS1></B_ADDRESS1>"+ CRLF
			cXml+="<B_ADDRESS2></B_ADDRESS2>"+ CRLF
			cXml+="<B_ADDRESS3></B_ADDRESS3>"+ CRLF
			cXml+="<B_ADDRESS4></B_ADDRESS4>"+ CRLF
			cXml+="<B_CITY></B_CITY>"+ CRLF
			cXml+="<B_STATE></B_STATE>"+ CRLF
			cXml+="<B_ZIP></B_ZIP>"+ CRLF
			cXml+="<B_COUNTRY></B_COUNTRY>"+ CRLF
			cXml+="<B_ISOCNTRYCODE></B_ISOCNTRYCODE>"+ CRLF
			cXml+="<B_PHONE1></B_PHONE1>"+ CRLF
			cXml+="<B_PHONE2></B_PHONE2>"+ CRLF
			cXml+="<B_FAX1></B_FAX1>"+ CRLF
			cXml+="<B_FAX2></B_FAX2>"+ CRLF
			cXml+="<B_VAT></B_VAT>"+ CRLF
			cXml+="<BATCHFLAG>0</BATCHFLAG>"+ CRLF 
			cXml+="<DISCHARGEPLACE></DISCHARGEPLACE>"+ CRLF
			cXml+="<DELIVERYPLACE></DELIVERYPLACE>"+ CRLF
			cXml+="<INTERMODALVEHICLE></INTERMODALVEHICLE>"+ CRLF
			cXml+="<COUNTRYOFORIGIN></COUNTRYOFORIGIN>"+ CRLF
			cXml+="<COUNTRYDESTINATION></COUNTRYDESTINATION>"+ CRLF
			cXml+="<TYPE>0</TYPE>"//+IIF((cAreaSC5)->C5_TIPO == "N","1",IIF((cAreaSC5)->C5_TIPO == "D","2","1"))+"</TYPE>"+ CRLF
			cXml+="<ORDERGROUP></ORDERGROUP>"+ CRLF
			cXml+="<TRANSPORTATIONMODE>1</TRANSPORTATIONMODE>"+ CRLF 
			cXml+="<EXTERNALORDERKEY2></EXTERNALORDERKEY2>"+ CRLF
			cXml+="<C_EMAIL1></C_EMAIL1>"+ CRLF
			cXml+="<C_EMAIL2></C_EMAIL2>"+ CRLF
			cXml+="<SUSR1></SUSR1>"+ CRLF
			cXml+="<SUSR2></SUSR2>"+ CRLF
			cXml+="<SUSR3></SUSR3>"+ CRLF
			cXml+="<SUSR4></SUSR4>"+ CRLF
			cXml+="<SUSR5></SUSR5>"+ CRLF
			cXml+="<NOTES_A></NOTES_A>"+ CRLF
			cXml+="<SHIPTOGETHER>N</SHIPTOGETHER>"+ CRLF 
			cXml+="<DELIVERYDATE2></DELIVERYDATE2>"+ CRLF
			cXml+="<REQUESTEDSHIPDATE></REQUESTEDSHIPDATE>"+ CRLF
			cXml+="<ACTUALSHIPDATE></ACTUALSHIPDATE>"+ CRLF
			cXml+="<DELIVER_DATE></DELIVER_DATE>"+ CRLF
			cXml+="<OHTYPE>1</OHTYPE>"+ CRLF   
			cXml+="<CARRIERCODE></CARRIERCODE>"+ CRLF
			cXml+="<CARRIERNAME></CARRIERNAME>"+ CRLF
			cXml+="<CARRIERADDRESS1></CARRIERADDRESS1>"+ CRLF
			cXml+="<CARRIERADDRESS2></CARRIERADDRESS2>"+ CRLF
			cXml+="<CARRIERCITY></CARRIERCITY>"+ CRLF
			cXml+="<CARRIERSTATE></CARRIERSTATE>"+ CRLF
			cXml+="<CARRIERZIP></CARRIERZIP>"+ CRLF
			cXml+="<CARRIERCOUNTRY></CARRIERCOUNTRY>"+ CRLF
			cXml+="<CARRIERPHONE></CARRIERPHONE>"+ CRLF
			cXml+="<DRIVERNAME></DRIVERNAME>"+ CRLF
			cXml+="<TRAILERNUMBER></TRAILERNUMBER>"+ CRLF
			cXml+="<TRAILEROWNER></TRAILEROWNER>"+ CRLF
			cXml+="<DEPDATETIME></DEPDATETIME>"+ CRLF
			cXml+="<NOTES_B></NOTES_B>"+ CRLF
			cXml+="<NVI_NUM_NOTA_FISCAL></NVI_NUM_NOTA_FISCAL>"+ CRLF
			cXml+="<NVI_SERIE></NVI_SERIE>"+ CRLF
			cXml+="<NVI_CFOP></NVI_CFOP>"+ CRLF
			cXml+="<NVI_CNPJ_TRANPORTADORA></NVI_CNPJ_TRANPORTADORA>"+ CRLF
			cXml+="<NVI_BASE_ICMS></NVI_BASE_ICMS>"+ CRLF
			cXml+="<NVI_VALOR_ICMS></NVI_VALOR_ICMS>"+ CRLF
			cXml+="<NVI_VALOR_IPI></NVI_VALOR_IPI>"+ CRLF
			cXml+="<NVI_VALOR_PRODUTOS></NVI_VALOR_PRODUTOS>"+ CRLF
			cXml+="<NVI_VALOR_TOTAL_NF></NVI_VALOR_TOTAL_NF>"+ CRLF
			cXml+="<NVI_CNPJ_DESTINATARIO></NVI_CNPJ_DESTINATARIO>"+ CRLF
			cXml+="<NVI_TIPO_NOTA_FISCAL>Venda</NVI_TIPO_NOTA_FISCAL>"+ CRLF
		cXml+="</HEADER>"+ CRLF
		//Itens
		While !(cAreaSC6)->(EOF())
			cXml+="<LINES>"+ CRLF
				cXml+="<TIPO-REG>L</TIPO-REG>"+ CRLF 
				cXml+="<TIPO-OPER>A</TIPO-OPER>"+ CRLF 
				cXml+="<TIPO-PROC-SO>1</TIPO-PROC-SO>"+ CRLF
				cXml+="<FISCAL>N</FISCAL>"+ CRLF
				cXml+="<WHSEID>WMWHSE8</WHSEID>"+ CRLF
				cXml+="<STORERKEY>DOTERRA</STORERKEY>"+ CRLF
				cXml+="<ORDERKEY></ORDERKEY>"+ CRLF
				cXml+="<EXTERNORDERKEY>"+cChave+"</EXTERNORDERKEY>"+ CRLF
				cXml+="<EXTERNLINENO>"+ALLTRIM((cAreaSC6)->C6_ITEM)+"</EXTERNLINENO>"+ CRLF  
				cXml+="<SKU>"+ALLTRIM((cAreaSC6)->C6_PRODUTO)+"</SKU>"+ CRLF 
				cXml+="<ORIGINALQTY>"+cvaltochar((cAreaSC6)->C6_QTDVEN)+"</ORIGINALQTY>"+ CRLF  
				cXml+="<UOM>EA</UOM>"+ CRLF   
				cXml+="<PACKKEY></PACKKEY>"+ CRLF
				cXml+="<PICKCODE></PICKCODE>"+ CRLF
				cXml+="<CARTONGROUP></CARTONGROUP>"+ CRLF
				cXml+="<UNITPRICE>0</UNITPRICE>"+ CRLF 
				cXml+="<LOTTABLE1></LOTTABLE1>"+ CRLF
				cXml+="<LOTTABLE2></LOTTABLE2>"+ CRLF
				cXml+="<LOTTABLE3></LOTTABLE3>"+ CRLF
				cXml+="<LOTTABLE4></LOTTABLE4>"+ CRLF
				cXml+="<LOTTABLE5></LOTTABLE5>"+ CRLF
				cXml+="<LOTTABLE6></LOTTABLE6>"+ CRLF
				cXml+="<LOTTABLE7></LOTTABLE7>"+ CRLF
				cXml+="<LOTTABLE8></LOTTABLE8>"+ CRLF
				cXml+="<LOTTABLE9></LOTTABLE9>"+ CRLF
				cXml+="<LOTTABLE10></LOTTABLE10>"+ CRLF
				cXml+="<EFFECTIVEDATE></EFFECTIVEDATE>"+ CRLF
				cXml+="<SUSR1></SUSR1>"+ CRLF
				cXml+="<SUSR2></SUSR2>"+ CRLF
				cXml+="<SUSR3></SUSR3>"+ CRLF
				cXml+="<SUSR4></SUSR4>"+ CRLF
				cXml+="<SUSR5></SUSR5>"+ CRLF
				cXml+="<NOTES></NOTES>"+ CRLF
				cXml+="<ALLOCATESTRATEGYKEY></ALLOCATESTRATEGYKEY>"+ CRLF
				cXml+="<PREALLOCATESTRATEGYKEY></PREALLOCATESTRATEGYKEY>"+ CRLF
				cXml+="<ALLOCATESTRATEGYTYPE></ALLOCATESTRATEGYTYPE>"+ CRLF
				cXml+="<SKUROTATION></SKUROTATION>"+ CRLF
				cXml+="<SHELFLIFE></SHELFLIFE>"+ CRLF
				cXml+="<OKTOSUBSTITUTE>1</OKTOSUBSTITUTE>"+ CRLF
				cXml+="<SHIPGROUP01></SHIPGROUP01>"+ CRLF
				cXml+="<SHIPGROUP02></SHIPGROUP02>"+ CRLF
				cXml+="<SHIPGROUP03></SHIPGROUP03>"+ CRLF
				cXml+="<PICKINGINSTRUCTIONS></PICKINGINSTRUCTIONS>"+ CRLF
				cXml+="<OPPREQUEST>0</OPPREQUEST>"+ CRLF 
				cXml+="<EXTERNALLOT></EXTERNALLOT>"+ CRLF
				cXml+="<NVI_NUM_NOTA_FISCAL></NVI_NUM_NOTA_FISCAL>"+ CRLF
				cXml+="<NVI_SERIE></NVI_SERIE>"+ CRLF
				cXml+="<NIV_ITEM_SEQUENCIA></NIV_ITEM_SEQUENCIA>"+ CRLF
				cXml+="<NIV_VALOR_UNITARIO></NIV_VALOR_UNITARIO>"+ CRLF
				cXml+="<NIV_ALIQUOTA_IPI></NIV_ALIQUOTA_IPI>"+ CRLF
				cXml+="<NIV_LOCAL></NIV_LOCAL>"+ CRLF
				cXml+="<NIV_LOTE></NIV_LOTE>"+ CRLF
				cXml+="<NIV_PALLET></NIV_PALLET>"+ CRLF
			cXml+="</LINES>"+ CRLF
			
			(cAreaSC6)->(DbSkip())  	
		Enddo
		
		cXml+="</SO>"+ CRLF
		cXml+="</InstanceSo>"+ CRLF
		cXml+="<mesa:mesaAuth>"+ CRLF
		cXml+="<mesa:principal>"+aUser[1]+"</mesa:principal>"+ CRLF
		cXml+="<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth>"+ CRLF
		cXml+="</mesa:mesaAuth>"+ CRLF
		cXml+="</soapenv:Body>"+ CRLF
		cXml+="</soapenv:Envelope>"+ CRLF 

		//Gravação de rastreio
		InsertZX7((cAreaSC5)->C5_FILIAL,(cAreaSC5)->C5_P_DTRAX,(cAreaSC5)->C5_NUM,"Tentativa de envio de Picking para operador logistico.","Envio de Picking")

		//envio pedido de venda para a FEDEX
		sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet) 

		//Atualizo a coluna de controle
		TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='01',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE='"+cChave+"'")  
		
		//Gravação de rastreio
		InsertZX7((cAreaSC5)->C5_FILIAL,(cAreaSC5)->C5_P_DTRAX,(cAreaSC5)->C5_NUM,"Finalizado tentativa de envio de Picking para operador logistico.","Envio de Picking")
		
		//Grava log Transacao 
		u_N6GEN002("SC5","E","GenSoWMS10In","TOTVS","FedEX",cChave,cXML,"")

		If ValType(sPostRet) == "C" .and. AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
			If AT("<faultcode>",sPostRet) == 0
				If !empty(sPostRet)			
					cRetorno := sPostRet
					oXml     := XmlParser( cRetorno, "_", @cError, @cWarning ) 
					cRetorno := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_GENSOOUT_RETORNO
					
					IF cRetorno:_GENSOOUT_COD:TEXT == "0"
						cMsg := "Pedido de venda gravado no sistema e xml de picking transmitido para a FedEx com sucesso."
						TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='02',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE = '"+cChave+"'")

						//Gravação de rastreio
						cQry := " UPDATE "+RetSqlName("ZX6")
						cQry += " SET ZX6_DTENPK='"+DTOS(Date())+"',ZX6_HRENPK='"+TIME()+"'
						cQry += " WHERE ZX6_FILIAL = '"+xFilial("SC5")+"'
						cQry += "		AND ZX6_DTRAX = '"+cChave+"'
						cQry += "		AND ZX6_DTENPK = ''
						TCSQLEXEC(cQry)
						InsertZX7((cAreaSC5)->C5_FILIAL,(cAreaSC5)->C5_P_DTRAX,(cAreaSC5)->C5_NUM,"Confirmado envio de Picking para operador logistico.","Envio de Picking")
					Else 
						cMsg := "Pedido de venda  e não transmitido para a FedEx devido ao problema interno no retorno do webservice (Código: "+cRetorno:_GENSOOUT_COD:TEXT+" - "+cRetorno:_GENSOOUT_DESCRICAO:TEXT+"), favor consultar log para maiores informações."
						TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='05',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE = '"+cChave+"'")
				        lErro := .T.
					EndIF
				Else
					cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx. Pedido Datatrax ("+(cAreaSC5)->C5_P_DTRAX+") "
					TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='05',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE = '"+cChave+"'")   	
					lErro := .T.
				EndIf 
			Else
				cMsg := "Erro na estrutura de XML de retorno do webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para correção. Pedido Datatrax ("+(cAreaSC5)->C5_P_DTRAX+") "
				TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='05',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE = '"+cChave+"'")  	
				lErro := .T.
			EndIF
		Else
			cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx. Pedido Datatrax ("+(cAreaSC5)->C5_P_DTRAX+") "
			TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='05',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE = '"+cChave+"'")   
			lErro := .T.
		EndIf
		If Select(cAreaSC6)>0
			(cAreaSC6)->(DbCloseArea())
		EndIf
	
	    //Grava log Transacao 
	    u_N6GEN002("SC5","R","GenSoWMS10In","FedEX","Totvs",cChave,sPostRet,cMsg)
			
	EndIF			
Else
	//Alert("Pedido de venda já enviada e/ou processada pelo webservice da FedEx.")
	u_N6GEN002("SC5","E","GenSoWMS10In","Totvs","Fedex","{chave:"+(cAreaSC5)->C5_P_CHAVE+"}",,"Pedido de venda já enviada e/ou processada pelo webservice da FedEx.")
	lErro := .T.
Endif

//Caso houver algum erro, o Job irá disparar um email informando a falha
If lErro 
	//Corpo do email
	cEmail:="<font size='3' face='Tahoma, Geneva, sans-serif'>"
	cEmail+="<p><b>Pedido de Venda Protheus:</b> "+(cAreaSC5)->C5_NUM+"<br /><b>Pedido de venda(DataTrax):</b> "+(cAreaSC5)->C5_P_DTRAX+" <br> <b>Hora:</b> "+Time()+"<br /><b>Data:</b> "+dtoc(ddatabase)+"</p>"
	cEmail+="<p>Falha na comunicação do TOTVS com FedEx para envio de picklist</p></font>"

	cEmail+="<table width='100%' border='0' cellspacing='1' cellpadding='1' align='center'><tr>"
	cEmail+="<td width='231' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Mensagem de Erro</font></td></tr>"

	cEmail+="<tr><td  bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+cMsg+"</font></td></tr>" 
	cEmail+="</table><br><br><br>"	

	u_N6GEN001(cEmail,"Erro envio picklist para FedEx - ("+(cAreaSC5)->C5_P_DTRAX+"/"+(cAreaSC5)->C5_NUM+")",,alltrim(GETMV("MV_P_00120")))
EndIf

If Select(cAreaSC5)>0
	(cAreaSC5)->(DbCloseArea())
EndIf

If Select(cAreaSC6)>0
	(cAreaSC6)->(DbCloseArea())
EndIf

RestArea(aArea)	

Return .T.

*--------------------------------*
Static Function RemoveChar(cTexto)
*--------------------------------*
Local i
Local aChar := {",","|"}
Local cRet := ""

cRet := ALLTRIM(cTexto)

For i:=1 to Len(aChar)
	cRet := StrTran(cRet,aChar[i],'')
Next i

Return cRet

/*
Funcao      : InsertZX7
Parametros  : 
Retorno     : 
Objetivos   : Gravação do Log de movimentação
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------------------*
Static Function InsertZX7(cFil,cDtrax,cNum,cOcorr,cEtapa)
*-------------------------------------------------------*
Local cInsert := ""

If EMPTY(cFil) .or. EMPTY(cDtrax) .or. EMPTY(cNum)
	Return .F.
EndIf

cInsert := " INSERT INTO "+RETSQLNAME("ZX7") 
cInsert += " VALUES('"+LEFT(cFil	,TamSX3("ZX7_FILIAL")[1])+"',
cInsert += " 		'"+LEFT(cDtrax	,TamSX3("ZX7_DTRAX")[1])+"',
cInsert += " 		'"+LEFT(cNum	,TamSX3("ZX7_NUM")[1])+"',
cInsert += " 		(SELECT ISNULL(MAX(ZX7_SEQ),0)+1 FROM "+RETSQLNAME("ZX7")+" WHERE ZX7_DTRAX = '"+LEFT(cDtrax,TamSX3("ZX7_DTRAX")[1])+"'),
cInsert += " 		'"+DTOS(date())+"',
cInsert += " 		'"+LEFT(Time()	,8)+"',
cInsert += " 		'"+LEFT(cOcorr	,TamSX3("ZX7_OCORR")[1])+"',
cInsert += " 		'"+LEFT(cEtapa	,TamSX3("ZX7_ETAPA")[1])+"',
cInsert += " 		'',
cInsert += " 		(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM "+RETSQLNAME("ZX7")+"))
TCSQLEXEC(cInsert)

Return .T.