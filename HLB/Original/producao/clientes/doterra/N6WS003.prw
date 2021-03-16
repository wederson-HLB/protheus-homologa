#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณN6WS002   บ Autor ณ William Souza      บ Data ณ  03/01/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ User function para trazer a concila็ใo entre o saldo fํsicoบฑฑ
ฑฑบ          ณ e o l๓gico                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ doTerra Brasil                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*----------------------* 
User Function N6WS003()
*-----------------------* 

Local aArea        := ""
Local AreaSB1      := ""
Local AreaSB2      := ""
Local cSql         := ""
Local cMsg         := ""
Local aRetorno     := {}
Local aSku         := {}
Local lJob		   := (Select("SX3") <= 0)
Local lValida      := .T.

//rotina para deixar a fun็ใo para ser chamada via menu.
If lJob 
	RpcClearEnv()
	RpcSetType( 3 )
    PREPARE ENVIRONMENT EMPRESA "N6" FILIAL "02" TABLES "SB1","SB2","SF1","SD1" MODULO "EST"
	conout("preparou N6WS003")
EndIf  

//Prepara็ใo das variแveis
aArea        := GetArea()
AreaSB1      := GetNextAlias()
AreaSB2      := GetNextAlias()

//Query para trazer todos os produtos para venda que tenha movimento na tabela de saldo
cSQL := "SELECT * FROM "+ RetSqlName("SB1") +" AS B1 WHERE B1.D_E_L_E_T_ = '' AND B1.B1_TIPO IN ('ME','PA','MP') AND B1.B1_FILIAL ='"+xFilial("SB1")+"' " + Chr( 13 ) + Chr( 10 ) 
cSQL += "AND B1.B1_COD IN (SELECT DISTINCT(B2.B2_COD) FROM "+RetSqlName("SB2")+" AS B2 WHERE B2.D_E_L_E_T_='' AND B2.B2_FILIAL='"+xFilial("SB2")+"') "
   
//conecto no top e executo o SQL
cSQL := ChangeQuery(cSQL)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaSB1, .F., .T.) 

//excluo os registros caso jแ tenha sido gerados anteriormente, evitando assim duplicidade de dados
TCSqlExec("UPDATE  " + RetSqlName("ZX1") + "  SET D_E_L_E_T_ = '*' WHERE  ZX1_DATA = '"+DTOS(ddatabase)+"'")   
	     
//la็o alimentar a tabela ZX1 com os dados do Ws (ws chamado pela static function)	    
While !(AreaSB1)->(Eof())

	aRetorno := saldoRetorno((AreaSB1)->B1_COD)
	if !(aRetorno[1][1])
		lValida := .F.
		cMsg    := aRetorno[1][2]
		Exit
	EndIF
    
(AreaSB1)->(dbSkip())
Enddo

//Rotina para montar o relat๓rio e enviar para o email do destinatแrio
If (lValida)
	//Query para trazer todos os produtos da tabela SB2 e ZX1
	cSQL := "SELECT" + Chr( 13 ) + Chr( 10 )
	
	//C๓digo Produto 
	cSQL += "SB2.B2_COD, "+ Chr( 13 ) + Chr( 10 )
	
	//Saldo Total Protheus 
	cSQL += "SUM(SB2.B2_QATU) AS B2_QATU," + Chr( 13 ) + Chr( 10 )
	
	//Saldo Total FedEX 
	cSQL += "ISNULL(ZX1.ZX1_SALDO,0) AS 'ZX1_SALDO', " + Chr( 13 ) + Chr( 10 )
	
	//Saldo Disponivel FedEX
	cSQL += "ISNULL(ZX1.ZX1_SDLDIS,0) AS 'ZX1_SDLDIS', "+ Chr( 13 ) + Chr( 10 )

	//Saldo Bloqueado FedEX
	cSQL += "ISNULL(ZX1.ZX1_SDLBLO,0) AS 'ZX1_SDLBLO', "+ Chr( 13 ) + Chr( 10 )
	
	//Recno
	cSQL += "ISNULL(ZX1.R_E_C_N_O_,0) AS 'ZX1_RECNOID', " + Chr( 13 ) + Chr( 10 )
	
	//SALDO DISPONIVEL / SALDO B2, LOCAL 01,02 MENOS OS DOCUMENTOS QUE NรO FORAM CONFIRMADOS OU COM ERRO
	cSQL += "ISNULL((SELECT SUM(B2.B2_QATU) FROM " + RetSqlName("SB2") + " B2 WHERE B2.D_E_L_E_T_='' AND B2.B2_FILIAL='"+xFilial("SB2")+"' AND B2.B2_LOCAL IN('01') AND SB2.B2_COD=B2.B2_COD GROUP BY B2.B2_COD),0) " + Chr( 13 ) + Chr( 10 )
	cSQL += "- ISNULL((SELECT SUM(D1_QUANT) FROM " + RetSqlName("SD1") + " SD1 WHERE " + Chr( 13 ) + Chr( 10 )
	cSQL += "SD1.D1_DOC IN (SELECT SF1.F1_DOC FROM " + RetSqlName("SF1") + " SF1 WHERE SF1.F1_P_STFED IN ('2','5') AND SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.D_E_L_E_T_='')" + Chr( 13 ) + Chr( 10 )
	cSQL += "AND SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_='' AND SD1.D1_COD=SB2.B2_COD),0) AS B2_SDDISP," + Chr( 13 ) + Chr( 10 )

	//Saldo em transito, ainda nใo confirmado na fedex
	cSQL += "ISNULL((SELECT SUM(SD1.D1_QUANT) FROM " + RetSqlName("SD1") + " SD1 WHERE "+ Chr( 13 ) + Chr( 10 )
	cSQL += "SD1.D1_DOC IN (SELECT SF1.F1_DOC FROM " + RetSqlName("SF1") + " SF1 WHERE SF1.F1_P_STFED ='2' AND SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.D_E_L_E_T_='')"+ Chr( 13 ) + Chr( 10 )
	cSQL += "AND SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_='' AND SD1.D1_COD=SB2.B2_COD),0) AS B2_TRANS,"+ Chr( 13 ) + Chr( 10 )

	//DIFERENวA ENTRE SALDO PROTHEUS(DISPONIVEL) E SALDO FEDEX(DISPONIVEL)
	cSQL += "(SELECT ISNULL((SELECT SUM(B2.B2_QATU) FROM " + RetSqlName("SB2") + " B2 WHERE B2.D_E_L_E_T_='' AND B2.B2_FILIAL='"+xFilial("SB2")+"' AND B2.B2_LOCAL IN('01') AND SB2.B2_COD=B2.B2_COD GROUP BY B2.B2_COD),0) " + Chr( 13 ) + Chr( 10 ) 
	cSQL += "- ISNULL((SELECT SUM(SD1.D1_QUANT) FROM " + RetSqlName("SD1") + " SD1 WHERE "+ Chr( 13 ) + Chr( 10 )
	cSQL += "SD1.D1_DOC IN (SELECT SF1.F1_DOC FROM " + RetSqlName("SF1") + " SF1 WHERE SF1.F1_P_STFED IN ('2','5') AND SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.D_E_L_E_T_='')"+ Chr( 13 ) + Chr( 10 )
	cSQL += "AND SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_='' AND SD1.D1_COD=SB2.B2_COD),0) -"+ Chr( 13 ) + Chr( 10 )
	cSQL += "ISNULL((SELECT ZX1.ZX1_SDLDIS FROM " + RetSqlName("ZX1") + " ZX1 WHERE ZX1.D_E_L_E_T_='' AND ZX1.ZX1_DATA='"+dtos(ddatabase)+"' AND ZX1.ZX1_COD=SB2.B2_COD AND ZX1.ZX1_FILIAL='"+xFilial("ZX1")+"'),0)) "+ Chr( 13 ) + Chr( 10 )
	cSQL += "AS B2_DIFF "+ Chr( 13 ) + Chr( 10 )
	
	cSQL += "FROM " + RetSqlName("SB2") + " SB2 "+ Chr( 13 ) + Chr( 10 )
	cSQL += "LEFT JOIN " + RetSqlName("ZX1") + " ZX1 ON ZX1.D_E_L_E_T_='' AND ZX1.ZX1_DATA='"+dtos(ddatabase)+"' AND ZX1.ZX1_COD=SB2.B2_COD AND ZX1.ZX1_FILIAL='"+xFilial("ZX1")+"'"+ Chr( 13 ) + Chr( 10 )
	cSQL += "WHERE SB2.D_E_L_E_T_='' AND SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_LOCAL IN ('01','02') AND SB2.B2_QATU<>0 GROUP BY SB2.B2_COD,ZX1.ZX1_SALDO,ZX1.ZX1_SDLDIS,ZX1.ZX1_SDLBLO,ZX1.R_E_C_N_O_"+ Chr( 13 ) + Chr( 10 )
					
	//conecto no top e executo o SQL
	//cSQL := ChangeQuery(cSQL)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), AreaSB2, .F., .T.)
	
	//la็o alimentar o array aSku e atualizar o saldo da SB2 na tabela ZX1     
	While !(AreaSB2)->(Eof())
		aAdd(aSku,{(AreaSB2)->B2_COD,(AreaSB2)->B2_QATU,(AreaSB2)->B2_SDDISP,(AreaSB2)->B2_TRANS,(AreaSB2)->ZX1_SALDO,(AreaSB2)->ZX1_SDLDIS,(AreaSB2)->B2_DIFF,(AreaSB2)->ZX1_SDLBLO})
		TCSqlExec("UPDATE  " + RetSqlName("ZX1") + "  SET ZX1_SLDSB2 = '"+cvaltochar((AreaSB2)->B2_DIFF)+"' WHERE  R_E_C_N_O_ = '"+cvaltochar((AreaSB2)->ZX1_RECNOID)+"'") 
		(AreaSB2)->(dbSkip())
	Enddo
	 
  	//envio o email 		 
 	sendMail(cMsg,aSku)
	DBCloseArea(AreaSB2) 
Else
	//envio o email 
    sendMail(cMsg,aSku)
EndIF
    
DBCloseArea(AreaSB1)  		 	  
RestArea(aArea)	
Return .T.

/*
-------------------------------------------------------
Static function para buscar o saldo do produto e gravar
na tabela ZX1
------------------------------------------------------
*/
*----------------------------------------*
Static Function saldoRetorno(cCodProduto)
*----------------------------------------*

Local cUrl         	:= alltrim(getMV("MV_P_00116"))
Local aUser        	:= &(getMV("MV_P_00117"))
Local nTimeOut 		:= 120
Local i            	:= 0
Local nSALDO  		:= 0
Local nSLDPED 		:= 0
Local nSLDPIC      	:= 0
Local nSLDRES 	   	:= 0
Local nSDLBLO 	 	:= 0
Local nSDLDIS 		:= 0
Local lValida      	:= .T.
Local aResult 		:= Array(9,1) 
Local aHeadStr 	 	:= {}
Local aData    	 	:= {} 
Local aRetorno    	:= {}
Local cHeadRet    	:= ""
Local sPostRet    	:= "" 
Local cError      	:= ""
Local cWarning    	:= ""
Local cRetorno    	:= "" 
Local cXml    	    := "" 
Local oXml	       	:= ""
Local cMsg         	:= ""
Local cContent     	:= "" 

//header do xml
aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
aadd(aHeadStr,"SOAPAction: sii:CONFIRM_RECEIPT_WMS10")     
aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') 

//prepara็ใo do xml de consulta
cXML:="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' "
cXML+="xmlns:gen='http://www.rapidaocometa.com.br/GenBalanceConciWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"
cXML+="<soapenv:Header/> "
cXML+="<soapenv:Body> "
cXML+="<gen:ListBalanceConci> "
cXML+="<gen:BalanceConci>"
cXML+="<gen:STORER_KEY>DOTERRA</gen:STORER_KEY> "
cXML+="<gen:WHSEID>WMWHSE8</gen:WHSEID> "
cXML+="<gen:SKU>"+alltrim(cCodProduto)+"</gen:SKU> "
cXML+="</gen:BalanceConci> "
cXML+="</gen:ListBalanceConci> "
cXML+="<mesa:mesaAuth> "
cXML+="<mesa:principal>"+aUser[1]+"</mesa:principal> "
cXML+="<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth> "
cXML+="</mesa:mesaAuth> "
cXML+="</soapenv:Body> "
cXML+="</soapenv:Envelope> "

//Grava log Transacao 
u_N6GEN002("ZX2","E","GenBalanceConciWMS10In","Totvs","FedEX",cCodProduto,"{SKU:"+cCodProduto+"}","")

//envio NFE para a FEDEX
sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet)      	
		
If AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
	If AT("<faultcode>",sPostRet) == 0
		If !empty(sPostRet)			
				
			//cRetorno := sPostRet
			oXml     := XmlParser( sPostRet, "_", @cError, @cWarning ) 
			cRetorno := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_LISTBALANCECONCI
			If Valtype(cRetorno:_HEADER) == "A"					
			
			   	If cRetorno:_HEADER[1]:_SKU:TEXT != "Vazio" .AND. cRetorno:_HEADER[1]:_QTY:TEXT != "Vazio"
	            		
	   			    for i:=1 to len(cRetorno:_HEADER)
	      				nSALDO  += val(cRetorno:_HEADER[i]:_QTY:TEXT)
	      			    nSLDPED += val(cRetorno:_HEADER[i]:_QTYALLOCATED:TEXT)
	      				nSLDPIC += val(cRetorno:_HEADER[i]:_QTYPICKED:TEXT)
	      				nSLDRES += val(cRetorno:_HEADER[i]:_QTYPREALLOCATED:TEXT)
	      				nSDLBLO += val(cRetorno:_HEADER[i]:_QTYHOLD:TEXT)
	      				nSDLDIS += val(cRetorno:_HEADER[i]:_QTYDISP:TEXT)
					Next
					
					dbSelectArea("ZX1")
					Reclock("ZX1",.T.)
							ZX1->ZX1_DEP      := cRetorno:_HEADER[1]:_WHSEID:TEXT
							ZX1->ZX1_ARM      := cRetorno:_HEADER[1]:_STORERKEY:TEXT
							ZX1->ZX1_COD      := cRetorno:_HEADER[1]:_SKU:TEXT
							ZX1->ZX1_SALDO    := nSALDO
							ZX1->ZX1_SLDPED   := nSLDPED 
							ZX1->ZX1_SLDPIC   := nSLDPIC
							ZX1->ZX1_SLDRES   := nSLDRES
							ZX1->ZX1_SDLBLO   := nSDLBLO 
							ZX1->ZX1_SDLDIS   := nSDLDIS
							ZX1->ZX1_DATA     := ddatabase 
							ZX1->ZX1_FILIAL   := xFilial("ZX1")														
					Msunlock() 
  								
  								//Montando string para log de dados
					cContent := "{WHSEID:"+ cRetorno:_HEADER[1]:_WHSEID:TEXT+","
					cContent += "STOREKEY:"+ cRetorno:_HEADER[1]:_STORERKEY:TEXT +","
					cContent += "SKU:"+cRetorno:_HEADER[1]:_SKU:TEXT+","
					cContent += "QTY:"+cvaltochar(nSALDO)+","
					cContent += "QTYLLOCATED:"+cvaltochar(nSLDPED)+","
					cContent += "QTYPICKED:"+cvaltochar(nSLDPIC)+","
					cContent += "QTYPRELLOCATED:"+cvaltochar(nSLDRES)+","
					cContent += "QTYHOLD:"+cvaltochar(nSDLBLO)+","
					cContent += "QTYDISP:"+cvaltochar(nSDLDIS)+"}"				
	  				aAdd(aRetorno,{.T.,"OK"})
		  		Else
			  		aAdd(aRetorno,{.T.,"Produto nใo encontrado no webservice da FedEX."})
		  		EndIF  
			Else
		  		If cRetorno:_HEADER:_SKU:TEXT != "Vazio" .AND. cRetorno:_HEADER:_QTY:TEXT != "Vazio"
    				            	
		      	    dbSelectArea("ZX1")
					Reclock("ZX1",.T.)
							ZX1->ZX1_DEP      := cRetorno:_HEADER:_WHSEID:TEXT
							ZX1->ZX1_ARM      := cRetorno:_HEADER:_STORERKEY:TEXT
							ZX1->ZX1_COD      := cRetorno:_HEADER:_SKU:TEXT 
							ZX1->ZX1_SALDO    := val(cRetorno:_HEADER:_QTY:TEXT)
							ZX1->ZX1_SLDPED   := val(cRetorno:_HEADER:_QTYALLOCATED:TEXT) 
							ZX1->ZX1_SLDPIC   := val(cRetorno:_HEADER:_QTYPICKED:TEXT)
							ZX1->ZX1_SLDRES   := val(cRetorno:_HEADER:_QTYPREALLOCATED:TEXT)
							ZX1->ZX1_SDLBLO   := val(cRetorno:_HEADER:_QTYHOLD:TEXT)
							ZX1->ZX1_SDLDIS   := val(cRetorno:_HEADER:_QTYDISP:TEXT)
							ZX1->ZX1_DATA     := ddatabase
							ZX1->ZX1_FILIAL   := xFilial("ZX1")														
					Msunlock() 
  								
  					//Montando string para log de dados
					cContent := "{WHSEID:"+cRetorno:_HEADER:_WHSEID:TEXT+","
					cContent += "STOREKEY:"+cRetorno:_HEADER:_STORERKEY:TEXT +","
					cContent += "SKU:"+cRetorno:_HEADER:_SKU:TEXT +","
					cContent += "QTY:"+cRetorno:_HEADER:_QTY:TEXT+","
					cContent += "QTYLLOCATED:"+cRetorno:_HEADER:_QTYALLOCATED:TEXT+","
					cContent += "QTYPICKED:"+cRetorno:_HEADER:_QTYPICKED:TEXT+","
					cContent += "QTYPRELLOCATED:"+cRetorno:_HEADER:_QTYPREALLOCATED:TEXT+","
					cContent += "QTYHOLD:"+cRetorno:_HEADER:_QTYHOLD:TEXT+","
					cContent += "QTYDISP:"+cRetorno:_HEADER:_QTYDISP:TEXT+"}"				
	  				
	  				aAdd(aRetorno,{.T.,"OK"})
		      
			    Else	 
					aAdd(aRetorno,{.T.,"Produto nใo encontrado no webservice da FedEX."})
			    Endif  
			EndIF								  
	   	Else
	   		aAdd(aRetorno,{.F.,"Erro de conexใo com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."})
			cContent := sPostRet
		EndIF
	Else
		aAdd(aRetorno,{.F.,"Erro na estrutura do XML para envio ao webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para corre็ใo."})			
		cContent := sPostRet
	EndIf
Else
    aAdd(aRetorno,{.F.,"Erro de conexใo com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."})	 
	cContent := sPostRet
EndIF

//Grava log Transacao 
u_N6GEN002("ZX2","R","GenBalanceConciWMS10In","FedEX","Totvs",cCodProduto,cContent,aRetorno[1][2])
		
Return aRetorno

/*
-------------------------------------------------------
Static function preparar o conte๚do do email antes de
enviar o workflow
------------------------------------------------------
*/
*---------------------------------*
Static Function sendMail(cMsg,aSku)
*---------------------------------*

Local cEmail := ""

cEmail:="<font size='3' face='Tahoma, Geneva, sans-serif'>"
cEmail+="<p align='left'>Data de Emissใo do Relat๓rio: "+dtoc(ddatabase)+"</p>"
cEmail+="<p align='left'>Relat๓rio de Concilia็ใo de Saldo de Estoque (Totvs vs FedEX)</p></font>"

If len(aSku) <> 0
	cEmail+="<table width='100%' border='0' cellspacing='1' cellpadding='1'><tr>"
	cEmail+="<td width='100' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>SKU</font></td>"
	cEmail+="<td width='300' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Descri็ใo</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Saldo Total Totvs</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Saldo Disp Totvs </font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Saldo em Transito</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Saldo Bloqueado</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Saldo Total FedEX</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Saldo Disp FedEX</font></td>"
	cEmail+="<td width='98' align='center' bgcolor='#666666'><font size='2' face='Tahoma, Geneva, sans-serif' color='#BABB00'>DIFF</font></td></tr>"
    
    for i :=1 to len(aSku)
		cEmail+="<tr>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+aSku[i][1]+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+POSICIONE("SB1", 1, xFilial("SB1") + aSku[i][1], "B1_DESC")+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][2])+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][3])+"</font></td>"		
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][4])+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][8])+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][5])+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][6])+"</font></td>"
		cEmail+="<td align='center' bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif' "+iif(aSku[i][7] <> 0, " color='red'", space(1))+">"+cvaltochar(aSku[i][7])+"</font></td>"
		cEmail+="</tr>" 
	Next
	cEmail+="</table><br><br>"
Else         
   cEmail += "<br><br><font size='3' face='Tahoma, Geneva, sans-serif'>" + cMsg + "</font>" 
EndIF

//Envio de WorkFlow
u_N6GEN001(cEmail,"Relat๓rio de Concilia็ใo de Saldo de Estoque (Doterra - concilia็ใo diแria)","",alltrim(GETMV("MV_P_00114"))) 

Return 