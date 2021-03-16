#Include "Protheus.ch"
#Include "topconn.ch"

/*
Funcao      : MT097END
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Ponto de entrada, para envio de e-mail no fim da execução da função. Neste ponto específico para a Globenet é usado para bloqueio do pedido.
TDN			: No fim da execução do fonte, para fins de necessidade do usuário
Autor       : Matheus Massarotto
Data/Hora   : 26/02/2014    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Compras
*/
*---------------------*
User function MT097END
*---------------------*
Local nOpc	:= PARAMIXB[3] //nOpc

//Globenet
If cEmpAnt == 'O9' .AND. nOpc == 3 //3 é a opção de bloquear
	Main()
EndIf

//Discovery
If cEmpAnt $ '49'
	If nOpc == 3 //3 é a opção de bloquear
		CustDisc(3)
	ElseIf nOpc == 2 //2 é a opção de liberar
		CustDisc(2)
	EndIf
EndIf

Return

/*
Funcao      : CustDisc 
Parametros  : Opção de Liberar ou Bloquear nOpcao
Retorno     : Nenhum
Objetivos   : Customização Discovery
Autor       : Renato Rezende
Data/Hora   : 12/04/2017
*/
*----------------------------*
 Static Function CustDisc(nOpcao)
*----------------------------* 
Local cDoc		:= PARAMIXB[1] //Documento
Local aAreaSC7 	:= SC7->(GetArea())
Local aAreaSCR	:= SCR->(GetArea())
Local cQuery 	:= ""
Local cQuery2	:= ""
Local cNome 	:= ""
Local nPos 		:= 0
Local aEmail 	:= {}
Local cEmail 	:= ""
Local cStatus	:= ""

If Select("QRY") > 0
	QRY->(dbCloseArea()) 
EndIf

If Select("QRY2") > 0
	QRY2->(dbCloseArea()) 
EndIf

SC7->(dbSetOrder(1))
SC7->(DbGotop())
SC7->(DbSeek(xFilial("SC7")+Alltrim(cDoc)))


If nOpcao == 3
	
	cStatus	:= "REJEITADO"
	
	cQuery := "SELECT Y1_NOME, Y1_EMAIL, Y1_USER FROM "+RetSqlName("SY1")+" " +CRLF 
	cQuery += " WHERE Y1_USER = '"+SC7->C7_USER+"' AND D_E_L_E_T_ <> '*' AND Y1_FILIAL = '"+xFilial("SY1")+"'" +CRLF 
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
	
ElseIf nOpcao == 2

	cQuery2 := "SELECT * FROM "+RetSqlName("SCR")+" " +CRLF
	cQuery2 += " WHERE CR_FILIAL = '"+xFilial("SCR")+"' AND " +CRLF
	cQuery2 += "CR_NUM = '"+SC7->C7_NUM+"' AND " +CRLF
	cQuery2 += "CR_STATUS = '02' AND CR_DATALIB = '' AND D_E_L_E_T_ <> '*' " +CRLF 
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery2), 'QRY2', .F., .T.)
	
	QRY2->(DbGoTop())
	
	Count To nRecCount
	
	If nRecCount == 0 //Resultado
		
		cStatus := "APROVADO"
		
		cQuery := "SELECT Y1_NOME, Y1_EMAIL, Y1_USER FROM "+RetSqlName("SY1")+" " +CRLF 
		cQuery += " WHERE Y1_USER = '"+SC7->C7_USER+"' AND D_E_L_E_T_ <> '*' AND Y1_FILIAL = '"+xFilial("SY1")+"'" +CRLF 
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)	
	//Pedido ainda está pendente para aprovação
	Else
		Return .T.
	EndIf
EndIf

QRY->(DbGoTop())

Count To nRecCount

QRY->(DbGoTop())
If nRecCount > 0 //Resultado
	
	cNome := Alltrim(QRY->Y1_NOME)

	//Armazena email do comprador.
	If !Empty(QRY->Y1_EMAIL)
		AADD(aEmail,QRY->Y1_EMAIL)
	EndIf
	
    //Caso nao encontro email
	If Len(aEmail) == 0
		MsgStop("O comprador desse pedido não possui email cadastrado. Informe a área responsável!")

	//Monta pagina html que ira compor o email.
	Else
		cEmail := '<html>
		cEmail += '	<head>
		cEmail += '	<title>Email-Discovery</title>
		cEmail += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		cEmail += '	</head>
		cEmail += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		cEmail += '<p align="center"><font face="Tahoma" size="2"><u><b>'
		cEmail += 'PEDIDO DE COMPRA '+cStatus+' PELO(S) APROVADOR(ES)</b></u></p>'
		cEmail += '<table border="0" cellpadding="0" cellspacing="0">
		//Pedido Rejeitado
		If nOpcao == 3		
			cEmail += '	<tr>'
			cEmail += '		<td width="150"><font face="Tahoma" size="2">Aprovador :</font></td>'
			cEmail += '		<td><font face="Tahoma" size="2">'+UsrFullName(RetCodUsr())+'</font></td>'
			cEmail += '	</tr>'
		EndIf
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
		While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+alltrim(cDoc)
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
		SC7->(dbSeek(xFilial("SC7")+Alltrim(cDoc)))
		cFile := "\SYSTEM\"+SC7->C7_NUM+".html"
		nHdl := FCreate( cFile )
		FWrite( nHdl,  cEmail, Len( cEmail ) )
		FClose( nHdl )
		
		//Envia email para todos aprovadores
	  	For nI:=1 to Len(aEmail)
			
			oEmail := DEmail():New()
			oEmail:cFrom	:= AllTrim(GetMv("MV_RELFROM"))
			oEmail:cTo		:= aEmail[nI] 
			oEmail:cSubject	:= "Pedido de compra "+cStatus+": " + SC7->C7_NUM
			oEmail:cBody	:= cEmail
			oEmail:cAnexos  := cFile
			oEmail:lExibMsg:= .F. //Não apresenta msg de enviado.
			oEmail:Envia()

		Next nI
		
		FErase(cFile)
	EndIf
Else
	MsgStop("Nenhum comprador encontrado para esse pedido de compra. Informe a área responsável!")
EndIf


If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

If Select("QRY2") > 0
	QRY2->(DbCloseArea())
EndIf
	
RestArea(aAreaSC7)
RestArea(aAreaSCR)

Return

/*
Funcao      : Main
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Função Principal.
*/
*---------------------*
Static function Main()
*---------------------*
Local cDoc	:= PARAMIXB[1] //Documento
Local cTipo	:= PARAMIXB[2] //tipo
Local nOpc	:= PARAMIXB[3] //nOpc
Local cFilD	:= PARAMIXB[4] //FilDoc
Local aAreaSCR := SCR->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSC1 := SC1->(GetArea())
Local cQuery := ""
Local aUsers:=AllUsers()
Local cNome := cValor:= ""
Local nPos := 0
Local aEmail := {}
Local cEmail := ""
Local cObsRej:= ""
Local cMoeda := ""

	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
		cNome := aUsers[nPos,1,4]
	EndIf        
	
	If Select("QRY") > 0
      QRY->(dbCloseArea()) 
    EndIf 
	
	SC7->(dbSetOrder(1))
	SC7->(DbGotop())
	if SC7->(DbSeek(xFilial("SC7")+alltrim(cDoc)))
 		//conout("Achou!!")
 	endif
 	conout("DOC: "+cDoc)
	cQuery := "SELECT TOP 1 * FROM "+RetSqlName("SCR")+" SCR "
	cQuery += "WHERE "
	cQuery += "CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQuery += "CR_TIPO = 'PC' AND "
	cQuery += "CR_NUM = '"+SC7->C7_NUM+"' AND "
	cQuery += "CR_STATUS = '04' AND "
	cQuery += "SCR.D_E_L_E_T_ <> '*'


	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
	(dbGoTop())
	Count To nTotal
	QRY->(dbGoTop())
	If nTotal > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena emails de aprovadores.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cObsRej:=QRY->CR_OBS
/*		While !QRY->(Eof())
			nPos := ASCAN(aUsers,{|X| X[1,1] == QRY->CR_USER})
			AADD(aEmail,aUsers[nPos,1,14])
			QRY->(dbSkip())
		End
*/

		
		   nPos := ASCAN(aUsers,{|X| X[1,1] == SC7->C7_USER})
		   If nPos > 0
		      cNome := AllTrim(aUsers[nPos,1,4])
		      AADD(aEmail,aUsers[nPos,1,14])
		   EndIf
		   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta pagina html que ira compor o email.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aEmail) == 0
			MsgStop("None of the approvers email that request has entered in its register of users Protheus system. Inform the responsible area!")
		Else
			cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '<title>Nova pagina 1</title></head><body>'
			cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>'
			cEmail += 'PURCHASE ORDER REJECTED</b></u></font></p>'
			cEmail += '<p><font face="Courier New" size="2">'
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
			cEmail += '<br>Requestor&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : '+Alltrim(cNome)+'</font></p>'
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
			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+alltrim(cDoc)
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
				cEmail += '		<td align="center" width="350"><font face="Courier New" size="2">'+IIF(Empty(AllTrim(cObsRej)),"&nbsp;",AllTrim(cObsRej))+'</font></td>' 
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
			SC7->(dbSeek(xFilial("SC7")+alltrim(cDoc)))
			cFile := "\SYSTEM\"+SC7->C7_NUM+".html"
			nHdl := FCreate( cFile )
			FWrite( nHdl,  cEmail, Len( cEmail ) )
			FClose( nHdl )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia email para aprovadores do proximo nivel.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   
		 	For nI:=1 to Len(aEmail)
				
				oEmail := DEmail():New()
				oEmail:cFrom	:= 	AllTrim(GetMv("MV_RELFROM"))
				oEmail:cTo		:=  aEmail[nI]
				oEmail:cSubject	:=	"Purchase order rejected: " + SC7->C7_NUM
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

	
	RestArea(aAreaSCR)
	RestArea(aAreaSC7)
	RestArea(aAreaSC1)

Return
                      
//Busca Numero de nota  
*-------------------------------------------------*
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