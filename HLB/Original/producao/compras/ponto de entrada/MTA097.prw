#include "rwmake.ch"
#Include "topconn.ch"   

/*
Funcao      : MTA097
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Envio de e-mail na liberação do pedido de compra
Autor     	: Joaquim Novaes Jr., alterações necessárias Matheus Massarotto 
Data     	: 18/01/10
Obs         : 
TDN         : Function A097LIBERA - Função da Dialog de liberação e bloqueio dos documentos com alçada.Após a confirmação da liberação do documento, deve ser utilizado para executar uma validação do usuario na liberação a fim de interromper ou bloquear processo.
Revisão     : Matheus Massarotto
Data/Hora   : 26/02/2014
Módulo      : Compras
Cliente     : Globenet
*/
*--------------------*
User Function MTA097()
*--------------------*

If !(cEmpAnt $ "O9")//Globenet
	Return .T.
EndIf

Main()

Return .T.

*--------------------*
Static Function Main()
*--------------------*
Local aAreaSCR	:= SCR->(GetArea())
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local cQuery	:= ""
Local aUsers	:= AllUsers()
Local cNome		:= ""
Local nPos   	:= 0
Local aEmail 	:= {}
Local cEmail 	:= ""
Local lRet   	:= .T.    
Local lAux   	:= .F. 
Local cUser  	:= ""
Local cMoeda 	:= ""

If (cEmpAnt $ "O9") //Globenet
    If Select("QRY") > 0
       QRY->(dbCloseArea()) 
    EndIf 
	
	cQuery := "SELECT * FROM "+RetSqlName("SCR")+" "
	cQuery += "WHERE "
	cQuery += "CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQuery += "CR_TIPO = '"+SCR->CR_TIPO+"' AND "
	cQuery += "CR_NUM = '"+SCR->CR_NUM+"' AND "
	//cQuery += "CR_APROV = '"+SCR->CR_USER+"' AND "
	//cQuery += "CR_STATUS == '02' AND "
    //cQuery += "CR_NIVEL <> '01' AND "
	//cQuery += "CR_DATALIB = '' AND "
	cQuery += "D_E_L_E_T_ <> '*'
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
	QRY->(dbGoTop())
	Count To nTotal
	QRY->(dbGoTop())

    If nTotal > 0
		While !QRY->(Eof())
			cUser:=QRY->CR_USER
			If  QRY->CR_STATUS='01'  
				nPos := ASCAN(aUsers,{|X| X[1,1] == cUser })
				AADD(aEmail,aUsers[nPos,1,14])    		  
				lAux:=.T.
				Exit  
			EndIf 
			QRY->(dbSkip())
		EndDo  
 	   
	
	 If lAux  .And. SCR->CR_TIPO=="PC" 
	 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena emails de aprovadores.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    //	While !QRY->(Eof())
		//	nPos := ASCAN(aUsers,{|X| X[1,1] == QRY->CR_USER})
		//	AADD(aEmail,aUsers[nPos,1,14])
		//	QRY->(dbSkip())
		//End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no primeiro registro do pedido de compras.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
		
		nPos := ASCAN(aUsers,{|X| X[1,1] == SC7->C7_USER})
		If nPos > 0
			cNome := AllTrim(aUsers[nPos,1,4])
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta pagina html que ira compor o email.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aEmail) == 0
			MsgStop("None of the approvers email that request has entered in its register of users Protheus system. Inform the responsible area!")
		Else
 /*			cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '<title>Nova pagina 1</title></head><body>'
			cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>'
			cEmail += 'PEDIDO DE COMPRA PENDENTE DE APROVAÇÃO</b></u></font></p>'
			cEmail += '<p><font face="Courier New" size="2">Pedido de Compra: '+SC7->C7_NUM+'<br>'
			cEmail += 'Fornecedor&nbsp;&nbsp;&nbsp;&nbsp; : '+SC7->C7_FORNECE+'/'+SC7->C7_LOJA
			cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
			cEmail += 'Razão Social: '+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
			cEmail += '<br>Comprador&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : '+cNome+'</font></p>'
			cEmail += '<table border="1" width="1200" style="padding: 0">'
			cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Courier New" size="2">Item</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Produto</font></td>'
			cEmail += '		<td width="378"><font face="Courier New" size="2">Descrição</font></td>'
			cEmail += '		<td width="111" align="right">'
			cEmail += '		<p align="right"><font face="Courier New" size="2">Quantidade</font></td>'
			cEmail += '		<td align="right" width="122"><font face="Courier New" size="2">Val.Unitário</font></td>'
			cEmail += '		<td align="right" width="119"><font face="Courier New" size="2" size="2">Valor TotaL</font></td>'
			cEmail += '		<td align="center"><font size="2" face="Courier New">Solicitante</font></td>' 
			cEmail += '		<td width="350" align="center"><font size="2" face="Courier New">Observação</font></td>' 
			cEmail += '		<td width="500" align="center"><font size="2" face="Courier New">Valor última compra</font></td>'
			cEmail += '	</tr>'
			nTotal := 0
			SC1->(dbSetOrder(1))
			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+AllTrim(SCR->CR_NUM)
				SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
				cEmail += '	<tr>'
				cEmail += '		<td width="40"><font face="Courier New" size="2">'+SC7->C7_ITEM+'</font></td>'
				cEmail += '		<td width="113"><font face="Courier New" size="2">'+AllTrim(SC7->C7_PRODUTO)+'</font></td>'
				cEmail += '		<td width="378"><font face="Courier New" size="2">'+AllTrim(SC7->C7_DESCRI)+'</font></td>'
				cEmail += '		<td width="111" align="right">'
				cEmail += '		<p align="right"><font face="Courier New" size="2">'+Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</font></td>'
				cEmail += '		<td align="right" width="122"><font face="Courier New" size="2">'+Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</font></td>'
				cEmail += '		<td align="right" width="119"><font face="Courier New" size="2">'+Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</font></td>'
				cEmail += '		<td align="center"><font size="2" face="Courier New">'+IIF(Empty(SC1->C1_SOLICIT),"NÃO INFORMADO",SC1->C1_SOLICIT)+'</font></td>'
				cValor := BuscaNf(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO)
				cEmail += '		<td align="center" width="=350"><font face="Courier New" size="2">'+AllTrim(SC7->C7_OBS)+'</font></td>' 
				cEmail += '		<td align="center" width="500"><font face="Courier New" size="2">'+IIF(Empty(cValor),"NF NÃO ENCONTRADA",cValor)+'</font></td>'
				cEmail += '	</tr>'
				nTotal += SC7->C7_TOTAL
				SC7->(dbSkip())
			End
			cEmail += '</table>'
			cEmail += '<p><font face="Courier New">Valor total do Pedido: '+Transform(nTotal,PesqPict("SC7","C7_TOTAL"))+'</font></p>'
			cEmail += '</body></html>'
*/			

			cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '<title>Nova pagina 1</title></head><body>'
			cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>'
			cEmail += 'PURCHASE ORDER PENDING TO APPROVAL</b></u></font></p>'
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
//			SC1->(dbSetOrder(1))
//			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == ParamIxb
//				SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			SC1->(dbSetOrder(1))
			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+AllTrim(SCR->CR_NUM)
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
			SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
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
				oEmail:cSubject	:=	"Purchase order pending to approval: " + SC7->C7_NUM
				oEmail:cBody	:= 	cEmail
				oEmail:cAnexos  := cFile
				oEmail:Envia()
			Next i
			
			FErase(cFile)
	    EndIf

	 ElseIf SCR->CR_TIPO=="PC"  
	       SC7->(dbSetOrder(1))
		   SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
		
		   nPos := ASCAN(aUsers,{|X| X[1,1] == SC7->C7_USER})
		   If nPos > 0
		      cNome := AllTrim(aUsers[nPos,1,4])
		      AADD(aEmail,aUsers[nPos,1,14])
		   EndIf		

	    If Len(aEmail) == 0
			MsgStop("None of the approvers email that request has entered in its register of users Protheus system. Inform the responsible area!")
		Else
			/*cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '<title>Nova pagina 1</title></head><body>'
			cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>'
			cEmail += 'PEDIDO DE COMPRA APROVADO</b></u></font></p>'
			cEmail += '<p><font face="Courier New" size="2">Pedido de Compra: '+SC7->C7_NUM+'<br>'
			cEmail += 'Fornecedor&nbsp;&nbsp;&nbsp;&nbsp; : '+SC7->C7_FORNECE+'/'+SC7->C7_LOJA
			cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
			cEmail += 'Razão Social: '+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
			cEmail += '<br>Comprador&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : '+cNome+'</font></p>'
			cEmail += '<table border="1" width="1200" style="padding: 0">'
			cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Courier New" size="2">Item</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Produto</font></td>'
			cEmail += '		<td width="378"><font face="Courier New" size="2">Descrição</font></td>'
			cEmail += '		<td width="111" align="right">'
			cEmail += '		<p align="right"><font face="Courier New" size="2">Quantidade</font></td>'
			cEmail += '		<td align="right" width="122"><font face="Courier New" size="2">Val.Unitário</font></td>'
			cEmail += '		<td align="right" width="119"><font face="Courier New" size="2" size="2">Valor Total</font></td>'
			cEmail += '		<td align="center"><font size="2" face="Courier New">Solicitante</font></td>' 
			cEmail += '		<td width="350" align="center"><font size="2" face="Courier New">Observação</font></td>' 
			cEmail += '		<td width="500" align="center"><font size="2" face="Courier New">Valor última compra</font></td>'
			cEmail += '	</tr>'
			nTotal := 0
			SC1->(dbSetOrder(1))
			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+AllTrim(SCR->CR_NUM)
				SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
				cEmail += '	<tr>'
				cEmail += '		<td width="40"><font face="Courier New" size="2">'+SC7->C7_ITEM+'</font></td>'
				cEmail += '		<td width="113"><font face="Courier New" size="2">'+AllTrim(SC7->C7_PRODUTO)+'</font></td>'
				cEmail += '		<td width="378"><font face="Courier New" size="2">'+AllTrim(SC7->C7_DESCRI)+'</font></td>'
				cEmail += '		<td width="111" align="right">'
				cEmail += '		<p align="right"><font face="Courier New" size="2">'+Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</font></td>'
				cEmail += '		<td align="right" width="122"><font face="Courier New" size="2">'+Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</font></td>'
				cEmail += '		<td align="center" width="130"><font face="Courier New" size="2">'+Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</font></td>'
				cEmail += '		<td align="center"><font size="2" face="Courier New">'+IIF(Empty(SC1->C1_SOLICIT),"NÃO INFORMADO",SC1->C1_SOLICIT)+'</font></td>'
				cValor := BuscaNf(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO)
				cEmail += '		<td align="center" width="=350"><font face="Courier New" size="2">'+AllTrim(SC7->C7_OBS)+'</font></td>' 
				cEmail += '		<td align="center" width="500"><font face="Courier New" size="2">'+IIF(Empty(cValor),"NF NÃO ENCONTRADA",cValor)+'</font></td>' 
				cEmail += '	</tr>'
				nTotal += SC7->C7_TOTAL
				SC7->(dbSkip())
			End
			cEmail += '</table>'   
			
			cEmail += '<p><font face="Courier New">Valor total do Pedido: '+Transform(nTotal,PesqPict("SC7","C7_TOTAL"))+'</font></p>'
			cEmail += '</body></html>'*/			
			cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '<title>Nova pagina 1</title></head><body>'
			cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>'
			cEmail += 'PURCHASE ORDER APPROVED</b></u></font></p>'
			cEmail += '<p><font face="Courier New" size="2">P.O. Number&nbsp;&nbsp;&nbsp; : '+SC7->C7_NUM
			
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
//			SC1->(dbSetOrder(1))
//			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == ParamIxb
//				SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			SC1->(dbSetOrder(1))
			While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+AllTrim(SCR->CR_NUM)
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
			SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
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
				oEmail:cSubject	:=	"Purchase order approved: " + SC7->C7_NUM
				oEmail:cBody	:= 	cEmail
				oEmail:cAnexos  := cFile
				oEmail:Envia()
			Next i
			
			FErase(cFile)

	   EndIf     
	EndIf
	QRY->(dbCloseArea())
	
  EndIf	
	
EndIf

RestArea(aAreaSCR)
RestArea(aAreaSC7)
RestArea(aAreaSC1)

Return(lRet)         

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
   //cRet:=" Vlr Unitario: "+STR(SQL->VALOR)+" NF: "+SQL->DOC+" Serie: "+SQL->SERIE
   cRet:=" Unit Value: "+STR(SQL->VALOR)+" Invoice Number: "+SQL->DOC+" Serie: "+SQL->SERIE
EndIf

Return cRet