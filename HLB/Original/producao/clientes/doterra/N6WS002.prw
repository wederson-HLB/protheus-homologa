#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณN6WS002   บ Autor ณ William Souza      บ Data ณ  03/01/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ User function para trazer a confirma็ใo da entrada do saldoบฑฑ
ฑฑบ          ณ fํsico na FEDEX                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ doTerra Brasil                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*----------------------*
User Function N6WS002()
*----------------------*

Local cUrl         := ""
Local aUser        := ""
Local aArea        := ""
Local cAreaSF1      := ""
Local cAreaSD1      := ""
Local cSql         := ""
Local cAccount     := ""
Local cServer      := ""
Local cMailDestino := ""
Local cXml    	   := "" 
Local oXml	       := ""
Local cHeadRet     := ""
Local sPostRet     := "" 
Local cError       := ""
Local cWarning     := ""
Local cRetorno     := ""
Local cMsg         := "" 
Local cContent     := ""
Local aRetorno     := {} 
Local aSku         := {} 
Local aHeadStr 	   := {}
Local aData    	   := {}
Local lJob	       := (Select("SX3") <= 0)
Local i            := 0
Local nTimeOut 	   := 120
Local lValida      := .F.
Local lValidaItem  := .F.
Local lVazio       := .T.

//rotina para deixar a fun็ใo para ser chamada via menu.
If lJob 
	RpcClearEnv()
	RpcSetType( 3 )
    PREPARE ENVIRONMENT EMPRESA "N6" FILIAL "02" TABLES "SB1","SB2","SF1","SD1" MODULO "EST"
	conout("preparou N6WS002")
EndIf 

//Prepara็ใo de Variแveis
cUrl         := alltrim(getMV("MV_P_00116"))
aUser        := &(getMV("MV_P_00117"))
aArea        := GetArea()
cAreaSF1     := "SF1N6WS002"//GetNextAlias()
cAreaSD1     := "SD1N6WS002"//GetNextAlias()

If Select(cAreaSF1)>0
	(cAreaSF1)->(DbCloseArea())
EndIf
If Select(cAreaSD1)>0
	(cAreaSD1)->(DbCloseArea())
EndIf

//Query para trazer as notas que precisam de confirma็ใo do saldo fํsico
cSQL := "SELECT F1_DOC,F1_SERIE,F1_FORNECE,R_E_C_N_O_ AS 'RECNOID',F1_EMISSAO,F1_P_CHAVE FROM " + RetSqlName("SF1") +"WHERE D_E_L_E_T_ = '' AND F1_P_STFED = '2' AND F1_FILIAL ='"+xFilial("SF1")+"'" 
	    
//conecto no top e executo o SQL
cSQL := ChangeQuery(cSQL)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), cAreaSF1, .F., .T.) 
	     
//la็o para buscar a confirma็ใo da entrada da nota com a entrada fisica	    
While !(cAreaSF1)->(Eof())
 
	//header do xml
	aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
	aadd(aHeadStr,"SOAPAction: sii:CONFIRM_RECEIPT_WMS10")     
	aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') 
	
	//prepara็ใo do xml de consulta
	cXML := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:gen='http://www.rapidaocometa.com.br/GenConfirmReceiptWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"
	cXML += "<soapenv:Header/>"
	cXML += "<soapenv:Body>"
	cXML += "<gen:InstanceConfirmPO>"
    cXML += "<gen:STORERKEY>DOTERRA</gen:STORERKEY>"
    cXML += "<gen:WHSEID>WMWHSE8</gen:WHSEID>"
	cXML += "<gen:EXTERNPOKEY>"+ALLTRIM((cAreaSF1)->F1_P_CHAVE)+"</gen:EXTERNPOKEY>"
		cContent := "{EXTERNPOKEY:"+ALLTRIM((cAreaSF1)->F1_P_CHAVE)+"}"
    cXML += "</gen:InstanceConfirmPO>"
    cXML += "<mesa:mesaAuth>"
    cXml += "<mesa:principal>"+aUser[1]+"</mesa:principal>"
	cXml += "<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth>"
    cXML += "</mesa:mesaAuth>"
   	cXML += "</soapenv:Body>"
	cXML += "</soapenv:Envelope>"
	
    //Grava log Transacao 
	u_N6GEN002("SF1","E","ConfirmReceiptWMS10In","Totvs","FedEX",ALLTRIM((cAreaSF1)->F1_P_CHAVE),cContent,"")

	//envio NFE para a FEDEX
	sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet)      	
	//sPostRet := simulaXML()
	
	If AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
		If AT("<faultcode>",sPostRet) == 0
		    If !empty(sPostRet)			
				cRetorno := sPostRet
				oXml     := XmlParser( cRetorno, "_", @cError, @cWarning ) 
				cRetorno := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_RESPONSE

			    If cRetorno:_STATUS:TEXT == "Sucesso" .AND. cRetorno:_CODIGO:TEXT == "0"
					If VALTYPE(cRetorno:_PO) == "A"
						For i := 1 to len(cRetorno:_PO)
							aAdd(aRetorno,{cRetorno:_PO[i]:_SKU:TEXT,cRetorno:_PO[i]:_EFFECTIVEDATE:TEXT,cRetorno:_PO[i]:_QTYRECEIVED:TEXT,cRetorno:_PO[i]:_STATUS:TEXT})
						    cContent += "{SKU:"+cRetorno:_PO[i]:_SKU:TEXT+",EFFECTIVEDATE:"+cRetorno:_PO[i]:_EFFECTIVEDATE:TEXT+",QTYRECEIVED:"+cRetorno:_PO[i]:_QTYRECEIVED:TEXT+",STATUS:"+cRetorno:_PO[i]:_STATUS:TEXT+"}" + Chr( 13 ) + Chr( 10 )
						Next
					Else
						aAdd(aRetorno,{cRetorno:_PO:_SKU:TEXT,cRetorno:_PO:_EFFECTIVEDATE:TEXT,cRetorno:_PO:_QTYRECEIVED:TEXT,cRetorno:_PO:_STATUS:TEXT})
						cContent += "{SKU:"+cRetorno:_PO:_SKU:TEXT+",EFFECTIVEDATE:"+cRetorno:_PO:_EFFECTIVEDATE:TEXT+",QTYRECEIVED:"+cRetorno:_PO:_QTYRECEIVED:TEXT+",STATUS:"+cRetorno:_PO:_STATUS:TEXT+"}" + Chr( 13 ) + Chr( 10 )
					EndIf

					If Select(cAreaSD1)>0
						(cAreaSD1)->(DbCloseArea())
					EndIf

				   	cSQL := "SELECT *
				   	cSQL += " FROM " + RetSqlName("SD1")
					cSQL += " WHERE D1_FILIAL = '"+xFilial("SD1")+"'
					cSQL += " 	AND D1_EMISSAO = '"+(cAreaSF1)->F1_EMISSAO+"' " 
					cSQL += "	AND D1_DOC = '" + (cAreaSF1)->F1_DOC+ "'
					cSQL += " 	AND D1_SERIE = '"+ (cAreaSF1)->F1_SERIE+"'
					cSQL += " 	AND D1_FORNECE = '"+(cAreaSF1)->F1_FORNECE+"'
					cSQL += " 	AND D_E_L_E_T_ = '' "

				    cSQL := ChangeQuery(cSQL)
					DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), cAreaSD1, .F., .T.) 	

					While !(cAreaSD1)->(Eof())
						For i := 1 to len(aRetorno)
							IF aRetorno[i][4] == "11"
								IF alltrim((cAreaSD1)->D1_COD) == alltrim(aRetorno[i][1])
									IF (cAreaSD1)->D1_QUANT != val(aRetorno[i][3])		
										aadd(aSku,{(cAreaSD1)->D1_COD,cvaltochar((cAreaSD1)->D1_QUANT),aRetorno[i][3],"Diverg๊ncia entre qtd. do item da NFe vs. entrada fํsica, favor verificar com a FedEx."})
										lValida = .T. 
										lValidaItem = .T.
									Else
										aadd(aSku,{(cAreaSD1)->D1_COD,cvaltochar((cAreaSD1)->D1_QUANT),aRetorno[i][3],"<font color ='green'>Quantidadade do item da nota de acordo com entrada fํsica (FedEx).</font>"})
										lValida = .F. 
										lValidaItem = .T.
									EndIF
								EndIf     
							Else
								aadd(aSku,{(cAreaSD1)->D1_COD,cvaltochar((cAreaSD1)->D1_QUANT),aRetorno[i][3],"Erro na contagem da quantidade fํsica, entrar em contato com a FedEx."})
								lValida = .T.
								lValidaItem = .T.
							EndIF 
						Next
					    IF  !(lValidaItem)
							aadd(aSku,{(cAreaSD1)->D1_COD,cvaltochar((cAreaSD1)->D1_QUANT),"","Item da NFe da nota inexistente no retorno do WS, favor verificar com a FedEx."})
							lValida = .T.
						EndIF
						
						i := 0
						(cAreaSD1)->(dbSkip())
					Enddo
					
					//DBCloseArea(cAreaSD1)
					//cAreaSD1 := GetNextAlias()
					
					//A linha abaixo ้ uma verifica็ใo se a nota foi processada pela FedEX, mesmo nใo sendo processada 
					//as tags vem preenchidas com o texto escrito "VAZIO". Caso havendo essa informa็ใo, eu coloco 
					//a variavel lVazio como .F. para nใo alterar os status na coluna F1_P_STFED e nใo enviar email.
					if aRetorno[1][1] == "Vazio" .and. aRetorno[1][2] == "Vazio" .and. aRetorno[1][3] == "Vazio" .and. aRetorno[1][4] == "Vazio"
					 	lVazio := .F.
					EndIf 
				    
				Else 	
				    cMsg := "NFe gravada no sistema e nใo transmitida para a FedEx devido ao problema interno no retorno do webservice (C๓digo: "+cRetorno:_CODIGO:TEXT+"), favor consultar log para maiores informa็๕es."
				    lValida := .T.
				    cContent := sPostRet
				EndIF	
		    Else
		        cMsg := "Erro de conexใo com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."
			    lValida := .T.
			    cContent := sPostRet
		    EndIF
		Else
			cMsg := "Erro na estrutura do XML para envio ao webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para corre็ใo."
			lValida := .T.
			cContent := sPostRet	    
		EndIf
	Else
	    cMsg := "Erro de conexใo com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx." 
		lValida := .T.
		cContent := sPostRet
	EndIF    
	
	If (lVazio) //condi็ใo logica para que valida se o ws retornou valores "Vazios"
		If (lValida)
			IF empty(cMsg)
				TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '4', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar((cAreaSF1)->RECNOID)+"'")
			EndIF                                                                                   	
		    sendMail((cAreaSF1)->F1_DOC,(cAreaSF1)->F1_SERIE,(cAreaSF1)->F1_EMISSAO,cMsg,aSku)
		Else
		 	TCSqlExec("UPDATE  " + RetSqlName("SF1") + "  SET F1_P_STFED = '3', F1_P_DTFED = '"+DTOS(ddatabase)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar((cAreaSF1)->RECNOID)+"'") 
	     	sendMail((cAreaSF1)->F1_DOC,(cAreaSF1)->F1_SERIE,(cAreaSF1)->F1_EMISSAO,cMsg,aSku)
		EndIF 
	EndIF	
	
	//Grava log Transacao 
	u_N6GEN002("SF1","R","ConfirmReceiptWMS10In","FedEX","Totvs",ALLTRIM((cAreaSF1)->F1_P_CHAVE),cContent,cMsg)
	(cAreaSF1)->(dbSkip())
   
   //Limpo os Arrays para um novo ciclo
	aSku     := {}
	aRetorno := {}
Enddo
	    
If Select(cAreaSF1)>0
	(cAreaSF1)->(DbCloseArea())
EndIf
If Select(cAreaSD1)>0
	(cAreaSD1)->(DbCloseArea())
EndIf
  		 	  
RestArea(aArea)	

Return .T.

/*-----------------------------------------------------  
Static function para preparar o corpo do email para envio
-------------------------------------------------------*/
*-------------------------------------------------------*
Static Function sendMail(cNota,cSerie,dEmissao,cMsg,aSku)
*-------------------------------------------------------*
Local cEmail := ""

cEmail:="<font size='3' face='Tahoma, Geneva, sans-serif'>"
cEmail+="<p>Nota Fiscal: "+cNota+"<br /> S้rie: "+cSerie+"<br />Data de Emissใo: "+SUBSTR(dEmissao,7,2)+"/"+SUBSTR(dEmissao,5,2)+"/"+SUBSTR(dEmissao,1,4)+"</p>"
cEmail+="<p>NFe vs Entrada Fํsica</p></font>"

If  Empty(cMsg)
	cEmail+="<table width='100%' border='0' cellspacing='1' cellpadding='1' align='center'><tr>"
	cEmail+="<td width='100' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>SKU</font></td>"
	cEmail+="<td width='131' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Descri็ใo</font></td>"
	cEmail+="<td width='94' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Qtd Nota</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Qtd Fํsco</font></td>"
	cEmail+="<td width='290' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Mensagem</font></td></tr>"
    
    for i :=1 to len(aSku)
		cEmail+="<tr>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+aSku[i][1]+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+POSICIONE("SB1", 1, xFilial("SB1") + aSku[i][1], "B1_DESC")+"</font></td>"
		if aSku[i][2] > aSku[i][3]
			cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' color='Red'>"+aSku[i][2]+"</font></td>"
			cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+aSku[i][3]+"</font></td>"
		ElseiF aSku[i][2] < aSku[i][3]
			cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+aSku[i][2]+"</font></td>"
			cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' color='Red'>"+aSku[i][3]+"</font></td>"
		ElseIF aSku[i][2] == aSku[i][3]
			cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+aSku[i][2]+"</font></td>"
			cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+aSku[i][3]+"</font></td>"
		Endif
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+aSku[i][4]+"</font></td></tr>" 
	Next
	cEmail+="</table><br><br><br>"
Else         
   cEmail += "<br><br><font size='3' face='Tahoma, Geneva, sans-serif'>" + cMsg + "</font>" 
EndIF

//Envio de WorkFlow
u_N6GEN001(cEmail,"Confirma็ใo de Entrada Fํsica vs NFe (DoTerra - concilia็ใo recebimento)","",alltrim(GETMV("MV_P_00114"))) 

Return 