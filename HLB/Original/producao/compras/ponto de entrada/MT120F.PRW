#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"
#Include "rwmake.ch"

/*
Funcao      : MT120F
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. executado apos a gravacao do pedido decompra para envio de email para aprovadores.
Autor     	: Joaquim Novaes Jr., alterações Matheus Massarotto 
Data     	: 18/01/10
Obs         : 
TDN         : Function A120GRAVA - Função responsável pela gravação do Pedido de Compras e Autorização de Entrega.Após a gravação dos itens do pedido de compras, no final da função A120GRAVA, pode ser usado para manipular os dados gravados do pedido de compras na tabela SC7, recebe como parametro a filial e numero do pedido.
Revisão     : Matheus Massarotto
Data/Hora   : 26/02/2014
Módulo      : Compras
Cliente     : Globonet
*/
*----------------------*
User Function MT120F()
*----------------------*

//Globenet
If cEmpAnt == 'O9'
	Main()
EndIf

//Discovery
If cEmpAnt $ '49'
	CustDisc()
EndIf

Return .T.

/*
Funcao      : CustDisc 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Customização Discovery
Autor       : Renato Rezende
Data/Hora   : 12/04/2017
*/
*----------------------------*
 Static Function CustDisc()
*----------------------------*
Local aAreaSCR 	:= SCR->(GetArea())
Local aAreaSC7 	:= SC7->(GetArea())
Local cQuery 	:= ""
Local cNome 	:= ""
Local nPos 		:= 0
Local aEmail 	:= {}
Local cEmail 	:= ""

//Bloqueia todos os pedidos inclusos no sistema
TcSqlExec("UPDATE "+RetSqlName("SC7")+" SET C7_CONAPRO = 'B' WHERE C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM = "+SC7->C7_FILIAL+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM)

If !(SAK->(FieldPos("AK_P_EMAIL")) > 0)
    MsgInfo("Empresa não configurada para o envio de email!","HLB BRASIL")
	Return .T.
EndIf

If Select("QRY") > 0
	QRY->(dbCloseArea()) 
EndIf 

SC7->(dbSetOrder(1))
//Caso nao encontro o pedido é porque está sendo deletado.
If !SC7->(dbSeek(ParamIxb))
	Return .T.
EndIf


cQuery := "SELECT (SELECT Y1_NOME FROM "+RetSqlName("SY1")+" WHERE Y1_USER = '"+SC7->C7_USER+"' AND D_E_L_E_T_ <> '*' AND Y1_FILIAL = '"+xFilial("SY1")+"') AS COMPNOME, AK.AK_USER, AK.AK_NOME, AK.AK_P_EMAIL, SCR.* " +CRLF 
cQuery += "  FROM "+RetSqlName("SCR")+" SCR " +CRLF
cQuery += " INNER JOIN "+RetSqlName("SAK")+" AS AK ON AK.AK_USER = SCR.CR_USER AND AK.AK_COD = SCR.CR_APROV AND AK.D_E_L_E_T_ <> '*' AND AK.AK_FILIAL = '"+xFilial("SAK")+"'" +CRLF
cQuery += " WHERE CR_FILIAL = '"+xFilial("SCR")+"' AND " +CRLF
cQuery += "CR_TIPO = 'PC' AND " +CRLF
cQuery += "CR_NUM = '"+SC7->C7_NUM+"' AND " +CRLF
cQuery += "CR_DATALIB = '' AND " +CRLF
cQuery += "CR_STATUS = '02' AND " +CRLF
cQuery += "SCR.D_E_L_E_T_ <> '*' " +CRLF

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)

QRY->(DbGoTop())

Count To nRecCount

QRY->(DbGoTop())
If nRecCount > 0 //Resultado
	
	cNome := Alltrim(QRY->COMPNOME)

	//Armazena emails dos aprovadores.
	While !QRY->(Eof())
		If !Empty(QRY->AK_P_EMAIL)
			AADD(aEmail,QRY->AK_P_EMAIL)
		EndIf
		QRY->(dbSkip())
	End
	
    //Caso nao encontro email
	If Len(aEmail) == 0
		MsgStop("O(s) aprovador(es) desse pedido não possui(em) email cadastrado(s). Informe a área responsável!")

	//Monta pagina html que ira compor o email.
	Else
		cEmail := '<html>
		cEmail += '	<head>
		cEmail += '	<title>Email-Discovery</title>
		cEmail += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		cEmail += '	</head>
		cEmail += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		cEmail += '<p align="center"><font face="Tahoma" size="2"><u><b>'
		cEmail += 'PEDIDO DE COMPRA PENDENTE DE APROVAÇÃO</b></u></p>'
		cEmail += '<table border="0" cellpadding="0" cellspacing="0">
		cEmail += '	<tr>'
		cEmail += '		<td width="150"><font face="Tahoma" size="2">Pedido de Compra :</font></td>'
		cEmail += '		<td><font face="Tahoma" size="2">'+SC7->C7_NUM+'</font></td>'
		cEmail += '	</tr>'
		cEmail += '	<tr>'
		cEmail += '		<td width="150"><font face="Tahoma" size="2">Cód. do Fornecedor:</font></td>'
		cEmail += '		<td><font face="Tahoma" size="2">'+SC7->C7_FORNECE+'/'+SC7->C7_LOJA+'</font></td>'
		cEmail += '	</tr>'
		cEmail += '	<tr>'
		cEmail += '		<td width="150"><font face="Tahoma" size="2">Nome Forn.:</font></td>'
		cEmail += '		<td><font face="Tahoma" size="2">'+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")+'</font></td>'
		cEmail += '	</tr>'
		cEmail += '	<tr>'
		cEmail += '		<td width="150"><font face="Tahoma" size="2">Comprador :</font></td>'
		cEmail += '		<td><font face="Tahoma" size="2">'+Alltrim(cNome)+'</font></td>'
		cEmail += '	</tr>'		
		cEmail += '</table>
		cEmail += '<br>'
		cEmail += '<br>'

		cEmail += '<table border="1" width="1200" style="padding: 0">'
		cEmail += '	<tr>'
		cEmail += '		<td width="40"><font face="Tahoma" size="2">Item</font></td>'
		cEmail += '		<td width="113"><font face="Tahoma" size="2">Produto/Serviço</font></td>'
		cEmail += '		<td width="378"><font face="Tahoma" size="2">Descrição</font></td>'
		cEmail += '		<td width="111" align="right"><font face="Tahoma" size="2">Quantidade</font></td>'
		cEmail += '		<td align="center" width="122"><font face="Tahoma" size="2">Valor Unit.</font></td>'
		cEmail += '		<td align="center" width="119"><font face="Tahoma" size="2">Valor Total</font></td>'
		cEmail += '		<td align="center"><font face="Tahoma" size="2">Comprador</font></td>'
		cEmail += '		<td width="350" align="center"><font face="Tahoma" size="2">Obs.</font></td>'
		cEmail += '	</tr>'
		nTotal := 0
		//Itens
		While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == ParamIxb
			cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Tahoma" size="2">'+SC7->C7_ITEM+'</font></td>'
			cEmail += '		<td width="113"><font face="Tahoma" size="2">'+AllTrim(SC7->C7_PRODUTO)+'</font></td>'
			cEmail += '		<td width="378"><font face="Tahoma" size="2">'+AllTrim(SC7->C7_DESCRI)+'</font></td>'
			cEmail += '		<td width="111" align="right"><font face="Tahoma" size="2">'+Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</font></td>'
			cEmail += '		<td align="right" width="122"><font face="Tahoma" size="2">'+Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</font></td>'
			cEmail += '		<td align="right" width="119"><font face="Tahoma" size="2">'+Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</font></td>'
			cEmail += '		<td align="center"><font face="Tahoma" size="2">'+IIF(Empty(SC7->C7_USER),"Uninformed",USRRETNAME(SC7->C7_USER))+'</font></td>'
			cEmail += '		<td align="center" width="350"><font face="Tahoma" size="2">'+IIF(Empty(AllTrim(SC7->C7_OBS)),"&nbsp;",AllTrim(SC7->C7_OBS))+'</font></td>'
			cEmail += '	</tr>'
			nTotal += SC7->C7_TOTAL
			SC7->(DbSkip())
		EndDo
		cEmail += '</table>'
		cEmail += '<p>Valor Total do Pedido: '+Transform(nTotal,PesqPict("SC7","C7_TOTAL"))+'</p>'
    	 
  	    cEmail += '<br>'
		cEmail += '<br>'
		cEmail += '<br>'
		cEmail += '<p align="center">Por favor não responder essa mensagem. Esse é um email automático.</p></font> '
		
		cEmail += '</body></html>'
		
		//Salva html em arquivo para dar opcao de envio em anexo
		SC7->(dbSeek(ParamIxb))
		cFile := "\SYSTEM\"+SC7->C7_NUM+".html"
		nHdl := FCreate( cFile )
		FWrite( nHdl,  cEmail, Len( cEmail ) )
		FClose( nHdl )
		
		//Envia email para todos aprovadores
	  	For nI:=1 to Len(aEmail)
			
			oEmail := DEmail():New()
			oEmail:cFrom	:= AllTrim(GetMv("MV_RELFROM"))
			oEmail:cTo		:= aEmail[nI] 
			oEmail:cSubject	:= "Pedido de compra para aprovação: " + SC7->C7_NUM
			oEmail:cBody	:= cEmail
			oEmail:cAnexos  := cFile
			oEmail:lExibMsg:= .F. //Não apresenta msg de enviado.
			oEmail:Envia()

		Next nI
		
		FErase(cFile)
	EndIf
Else
	MsgStop("Nenhum aprovador encontrado para esse pedido de compra. Informe a área responsável!")
EndIf

QRY->(DbCloseArea())
	
RestArea(aAreaSCR)
RestArea(aAreaSC7)

Return .T.

*----------------------*
Static Function Main()
*----------------------*
Local aAreaSCR 	:= SCR->(GetArea())
Local aAreaSC7 	:= SC7->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local cQuery 	:= ""
Local aUsers	:=AllUsers()
Local cNome 	:= cValor:= ""
Local nPos 		:= 0
Local aEmail 	:= {}
Local cEmail 	:= ""
Local cMoeda 	:= ""

If (  cEmpAnt $ "O9") //Globenet     
	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
		cNome := aUsers[nPos,1,4]
	EndIf        
	
	If Select("QRY") > 0
      QRY->(dbCloseArea()) 
    EndIf 
	
	SC7->(dbSetOrder(1))
	SC7->(dbSeek(ParamIxb))

	cQuery := "SELECT TOP 1 * FROM "+RetSqlName("SCR")+" SCR "
	cQuery += "WHERE "
	cQuery += "CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQuery += "CR_TIPO = 'PC' AND "
	cQuery += "CR_NUM = '"+SC7->C7_NUM+"' AND "
	//cQuery += "CR_APROV = '"+RetCodUsr()+"' AND "
	cQuery += "CR_DATALIB = '' AND "
	cQuery += "CR_STATUS = '02' AND "
	cQuery += "SCR.D_E_L_E_T_ <> '*'
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
	(dbGoTop())
	Count To nTotal
	QRY->(dbGoTop())
	If nTotal > 0 //voltar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena emails de aprovadores.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !QRY->(Eof())
			nPos := ASCAN(aUsers,{|X| X[1,1] == QRY->CR_USER})
			nPos := ASCAN(aUsers,{|X| X[1,1] == QRY->CR_USER})
			AADD(aEmail,aUsers[nPos,1,14])
			QRY->(dbSkip())
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta pagina html que ira compor o email.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Len(aEmail) == 0
			MsgStop("None of the approvers email that request has entered in its register of users Protheus system. Inform the responsible area!")
		Else

			cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '<title>Nova pagina 1</title></head><body>'
			cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>'
			cEmail += 'PURCHASE ORDER PENDING TO APPROVAL</b></u></font></p>'
			
			cEmail += '<p><font face="Courier New" size="2">
			cEmail += 'Branch&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : '+alltrim(cFilAnt)+' - '+alltrim(FWFilialName())
			cEmail += '<br>
			cEmail += 'P.O. Number&nbsp;&nbsp;&nbsp; : '+SC7->C7_NUM

			if valtype(SC7->C7_MOEDA)=="N"
				cMoeda:= cvaltochar(SC7->C7_MOEDA)
			elseif valtype(SC7->C7_MOEDA)=="C"
				if len(alltrim(SC7->C7_MOEDA))>1
					cMoeda:= NTOC(val(SC7->C7_MOEDA),16,1)//base 16, retorno com 1 caracter
				else
					cMoeda:= alltrim(SC7->C7_MOEDA)
				endif

			endif         
			
			cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '			
			cEmail += 'Currency&nbsp;&nbsp; : '+GetNewPar("MV_MOEDA"+ cMoeda ,"")
			cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
			cEmail += 'Rate&nbsp;&nbsp;&nbsp;&nbsp; : '+Transform(SC7->C7_TXMOEDA,PesqPict("SC7","C7_TXMOEDA"))			
			cEmail += '<br>'
			
			cEmail += 'Vendor Code&nbsp;&nbsp;&nbsp; : '+SC7->C7_FORNECE+'/'+SC7->C7_LOJA
			cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
			cEmail += 'Vendor Name: '+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
			cEmail += '<br>Requestor&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : '+Alltrim(cNome)
			cEmail += '</font></p>'

			cEmail += '<table border="1" width="1200" style="padding: 0">'
			cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Courier New" size="2">Item</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Product/Service</font></td>'
			cEmail += '		<td width="378"><font face="Courier New" size="2">Description</font></td>'
			cEmail += '		<td width="111" align="right">'
			cEmail += '		<p align="right"><font face="Courier New" size="2">Quantity</font></td>'
			cEmail += '		<td align="center" width="122"><font face="Courier New" size="2">Unit Value</font></td>'
			cEmail += '		<td align="center" width="119"><font face="Courier New" size="2" size="2">Total Value</font></td>'
			cEmail += '		<td align="center"><font size="2" face="Courier New">Requestor</font></td>' 
			cEmail += '		<td width="350" align="center"><font size="2" face="Courier New">Note</font></td>' 
			cEmail += '		<td width="500" align="center"><font size="2" face="Courier New">Last purchase value</font></td>'
			cEmail += '	</tr>'
			nTotal := 0
			SC1->(dbSetOrder(1))
			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == ParamIxb
				SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
				cEmail += '	<tr>'
				cEmail += '		<td width="40"><font face="Courier New" size="2">'+SC7->C7_ITEM+'</font></td>'
				cEmail += '		<td width="113"><font face="Courier New" size="2">'+AllTrim(SC7->C7_PRODUTO)+'</font></td>'
				cEmail += '		<td width="378"><font face="Courier New" size="2">'+AllTrim(SC7->C7_DESCRI)+'</font></td>'
				cEmail += '		<td width="111" align="right">'
				cEmail += '		<p align="right"><font face="Courier New" size="2">'+Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</font></td>'
				cEmail += '		<td align="right" width="122"><font face="Courier New" size="2">'+Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</font></td>'
				cEmail += '		<td align="right" width="119"><font face="Courier New" size="2">'+Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</font></td>'
				cEmail += '		<td align="center"><font size="2" face="Courier New">'+IIF(Empty(SC7->C7_USER),"Uninformed",USRRETNAME(SC7->C7_USER))+'</font></td>'
				cValor := BuscaNf(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO)
				cEmail += '		<td align="center" width="350"><font face="Courier New" size="2">'+IIF(Empty(AllTrim(SC7->C7_OBS)),"&nbsp;",AllTrim(SC7->C7_OBS))+'</font></td>' 
				cEmail += '		<td align="center" width="500"><font face="Courier New" size="2">'+IIF(Empty(cValor),"Invoice not found",cValor)+'</font></td>'
				cEmail += '	</tr>'
				nTotal += SC7->C7_TOTAL
				SC7->(dbSkip())
			End
			cEmail += '</table>'
			cEmail += '<p><font face="Courier New">P.O. Grand Total: '+Transform(nTotal,PesqPict("SC7","C7_TOTAL"))+'</font></p>'    
	    	 
    	    cEmail += '<br>'
            cEmail += '<br>'
            cEmail += '<br>'
            cEmail += '<p align="center">This message is automatically generated and can not be answered.</p> '
			
			cEmail += '</body></html>'
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva html em arquivo para dar opcao de envio em anexo           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SC7->(dbSeek(ParamIxb))
			cFile := "\SYSTEM\"+SC7->C7_NUM+".html"
			nHdl := FCreate( cFile )
			FWrite( nHdl,  cEmail, Len( cEmail ) )
			FClose( nHdl )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia email para aprovadores do proximo nivel.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   
		  	For nI:=1 to Len(aEmail) //voltar
				
				oEmail := DEmail():New()
				oEmail:cFrom	:= 	AllTrim(GetMv("MV_RELFROM"))
				oEmail:cTo		:=  aEmail[nI] 
				oEmail:cSubject	:=	"Purchase order pending to approval: " + SC7->C7_NUM
				oEmail:cBody	:= 	cEmail
				oEmail:cAnexos  := cFile
				oEmail:Envia()

			Next i
			
			FErase(cFile)
		EndIf
	Else
		MsgStop("No approver this bound to that request. Inform the responsible area!")
	EndIf

	QRY->(dbCloseArea())

EndIf
	
	RestArea(aAreaSCR)
	RestArea(aAreaSC7)
	RestArea(aAreaSC1)

Return
                      
//Busca Numero de nota  
*----------------------------------------------*
Static Function BuscaNf(cFornecedor,cLoja,cItem)
*----------------------------------------------*
Local cRet:=""

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT D1_DOC AS DOC ,D1_SERIE AS SERIE ,D1_VUNIT AS VALOR "+Chr(10)
cQuery += " FROM "+RetSqlName("SD1")+Chr(10)
cQuery += " WHERE D1_FILIAL='"+xFilial("SD1")+"'"
cQuery += " AND D_E_L_E_T_ <> '*' AND D1_EMISSAO IN "
cQuery += " ( SELECT  MAX(D1_EMISSAO) FROM "+RetSqlName("SD1")+Chr(10)
cQuery += " WHERE D1_FORNECE='"+cFornecedor+"'"
cQuery += " AND D1_LOJA='"+cLoja+"'"  
cQuery += " AND D1_COD='"+cItem+"'"
cQuery += " )"  

TCQuery cQuery ALIAS "SQL" NEW
           
If !Empty(SQL->DOC)           
   cRet:=" Unit Value: "+STR(SQL->VALOR)+" Invoice Number: "+SQL->DOC+" Serie: "+SQL->SERIE
EndIf

Return cRet