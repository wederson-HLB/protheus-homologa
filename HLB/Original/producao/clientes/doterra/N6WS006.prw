#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS006   º Autor ³ William Souza      º Data ³  17/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ User function para atualizar a retirada o picking na FedEx º±±
±±º          ³ após a emissão da nota                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra Brasil                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------*
User Function N6WS006(aParam)
*---------------------------*
Local aHeadStr 	   := {}
Local aData    	   := {}
Local aRetorno     := {} 
Local aSku         := {}
Local aArea        := ""
Local cAreaSC5     := ""
Local cAreaSC6     := ""
Local cUrl         := ""
Local aUser        := ""
Local cSql         := ""
Local cXml    	   := "" 
Local oXml	       := ""
Local cHeadRet     := ""
Local sPostRet     := "" 
Local cError       := ""
Local cWarning     := ""
Local cRetorno     := ""
Local cMsg         := "" 
Local cContent     := ""
Local cVolume	   := ""
Local lJob	       := Type( 'oMainWnd' ) != 'O'
Local i            := 0
Local nPeso		   := 0
Local nTimeOut 	   := 120
Local lValida      := .F.
Local lValidaItem  := .F.

//rotina para deixar a função para ser chamada via menu.
If lJob 
	If ( Valtype( aParam ) != 'A' )
		cEmp := 'N6'
		cFil := '01'
	Else            
		cEmp := aParam[ 01 ]
		cFil := aParam[ 02 ]	
	EndIf

	RPCSetType(3)	
	RpcSetEnv( cEmp , cFil , "" , "" , 'FAT' )
EndIf     

//Preparando as variaveis
cUrl         := alltrim(getMV("MV_P_00116"))
aUser        := &(getMV("MV_P_00117"))
aArea        := GetArea()
cAreaSC5     := "SC5N6WS006"//GetNextAlias()
//AreaSC6    := GetNextAlias()

If Select(cAreaSC5)>0
	(cAreaSC5)->(DbCloseArea())
EndIf

//Query para trazer as notas que precisam de confirmação do saldo físico
cSQL := "SELECT * FROM " + RetSqlName("SC5") +"WHERE D_E_L_E_T_ = '' AND C5_P_STFED IN ('02') AND C5_FILIAL ='"+xFilial("SC5")+"'" 

//conecto no top e executo o SQL
cSQL := ChangeQuery(cSQL)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), cAreaSC5, .F., .T.) 

//laço para buscar a confirmação da entrada da nota com a entrada fisica	    
While !(cAreaSC5)->(Eof())
	//header do xml
	aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
	aadd(aHeadStr,"SOAPAction: sii:CONFIRM_RECEIPT_WMS10")     
	aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') 
	
	//preparação do xml de consulta
	cXml+="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:gen='http://www.rapidaocometa.com.br/genRequestConfirmCaixaSeparacaoWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"
	cXml+="<soapenv:Header/>"
	cXml+="<soapenv:Body>"
	cXml+="<HEADER_ConfSepIn>"
	cXml+="<CLIENTE>DOTERRA</CLIENTE>"
	cXml+="<DEPOSITO>WMWHSE8</DEPOSITO>"
	cXml+="<PEDIDO_det>"
	cXml+="<NUMERO_ORDEM_EXTERNA>"+ALLTRIM((cAreaSC5)->C5_P_CHAVE)+"</NUMERO_ORDEM_EXTERNA>"
	cXml+="</PEDIDO_det>"
	cXml+="</HEADER_ConfSepIn>"
	cXml+="<mesa:mesaAuth>"
	cXml += "<mesa:principal>"+aUser[1]+"</mesa:principal>"
	cXml += "<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth>"
	cXml+="</mesa:mesaAuth>"
	cXml+="</soapenv:Body>"
	cXml+="</soapenv:Envelope>"

    //Grava log Transacao 
	u_N6GEN002("SC5","E","RequestConfirmCaixaSeparacaoWMS10In","Totvs","FedEX",ALLTRIM((cAreaSC5)->C5_P_CHAVE),"{NUMERO_ORDEM_EXTERNA:"+ALLTRIM((cAreaSC5)->C5_P_CHAVE)+"}","")

	//envio NFE para a FEDEX
	sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet)      	
		
	If AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
		If AT("<faultcode>",sPostRet) == 0
		   If !empty(sPostRet)
				If AT("<GenPdvPickConfOut:Retorno>",sPostRet) == 0
				 	IF AT("HEADER_ConfSepOut",sPostRet) == 0
						//Atualizo o status para 7 informando para o usuário que a NF foi importada para a FEDEX
						//e o mesmo foi informado da nota
						TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '07' WHERE C5_P_CHAVE = '"+ALLTRIM((cAreaSC5)->C5_P_CHAVE)+"'") 
			      EndIf
			   EndIF   
			Else 	
			   cMsg := "Retorno em branco do webservice. Log gravado e entrar em contato com o time de desenvolvimento."
			   TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '06', WHERE C5_P_CHAVE = '"+ALLTRIM((cAreaSC5)->C5_P_CHAVE)+"'") 				
			EndIF	
		Else
			cMsg := "Erro na estrutura do XML para envio ao webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para correção."	    
			TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '06', WHERE C5_P_CHAVE = '"+ALLTRIM((cAreaSC5)->C5_P_CHAVE)+"'") 
		EndIF
    Else
	    cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."
		TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '06', WHERE C5_P_CHAVE = '"+ALLTRIM((cAreaSC5)->C5_P_CHAVE)+"'") 
	EndIf

	//Grava log Transacao 
	u_N6GEN002("SC5","R","RequestConfirmCaixaSeparacaoWMS10In","FedEX","Totvs",ALLTRIM((cAreaSC5)->C5_P_CHAVE),cContent,cMsg)
   (cAreaSC5)->(dbSkip())		
Enddo
	    
If Select(cAreaSC5)>0
	(cAreaSC5)->(DbCloseArea())
EndIf

RestArea(aArea)	
Return .T.