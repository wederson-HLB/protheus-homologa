#include "Protheus.ch"

/*
Funcao      :GTGEN037
Objetivos   :Retornar descrição a ser impressa nas faturas dos clientes
Autor       :Leandro Diniz de Brito
Data        :26/10/2015
Revisão     :
Módulo      :Faturamento/Financeiro
*/

*-------------------------------*
User Function GTGEN037( nTipo )
*-------------------------------*    
Local 	cMensRet := ""
Default nTipo := 0

If ( cEmpAnt $ 'B1' )

	Do Case
    	
		/*
			** Boleto ou deposito pós-pago com item Publicidade CPC
		*/
		Case ( nTipo == 1 )   
			cMensRet := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMensRet += '</head><body><font face="verdana" size="2">'
			cMensRet +=	'<br>Prezado(a),'
			cMensRet +=	'<br>Segue em anexo a fatura referente a publicidade para pagamento.'
			cMensRet +=	'<br>Em caso de dúvida, entre em contato pelo e-mail: cr@zoom.com.br'
			cMensRet +=	'<br>Favor confirmar o recebimento.'
			cMensRet +=	'<p>Atenciosamente,</p>'
			cMensRet +=	'Financeiro'
			cMensRet +=	'</font></body></html>'
			
		/*
			** Boleto ou deposito pós-pago com item Publicidade Banner
		*/
		Case ( nTipo == 2 )   
			cMensRet := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMensRet += '</head><body><font face="verdana" size="2">'
			cMensRet +=	'<br>Prezado(a),'
			cMensRet +=	'<br>Segue em anexo a fatura referente a campanha de publicidade para pagamento.'
			cMensRet +=	'<br>Em caso de dúvida, entre em contato pelo e-mail: cr@zoom.com.br'
			cMensRet +=	'<br>Favor confirmar o recebimento.'
			cMensRet +=	'<p>Atenciosamente,</p>'
			cMensRet +=	'Financeiro'
			cMensRet +=	'</font></body></html>'   
			
		/*
			** Pré-pago boleto ou paypal com item Publicidade CPC
		*/
		Case ( nTipo == 3 )   
			cMensRet := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMensRet += '</head><body><font face="verdana" size="2">'
			cMensRet +=	'<br>Prezado(a),'
			cMensRet +=	'<br>Segue em anexo a fatura referente ao pagamento efetuado.'
			cMensRet +=	'<br>Em caso de dúvida, entre em contato pelo e-mail: cr@zoom.com.br'
			cMensRet +=	'<br>Favor confirmar o recebimento.'
			cMensRet +=	'<p>Atenciosamente,</p>'
			cMensRet +=	'Financeiro'
			cMensRet +=	'</font></body></html>'	 
			
		/*
			** Pub-Prepago e Pub-Paypal "Publicidade Banner
		*/
		Case ( nTipo == 4 )   
			cMensRet := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMensRet += '</head><body><font face="verdana" size="2">'
			cMensRet +=	'<br>Segue em anexo a fatura referente ao pagamento efetuado de campanha de publicidade.'
			cMensRet +=	'<br>Em caso de dúvida, entre em contato pelo e-mail: cr@zoom.com.br'
			cMensRet +=	'<p>Atenciosamente,</p>'
			cMensRet +=	'Financeiro'
			cMensRet +=	'</font></body></html>'	 
			
		/*
			** Internacional/Deposito pos-pago 
		*/
		Case ( nTipo == 5 )   
			cMensRet := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMensRet += '</head><body><font face="verdana" size="2">'
			cMensRet +=	'<br>We are attaching  your monthly invoice ' + CMonth( dDataBase )+ '/' + Str( Year( dDataBase ) , 4 ) + ' for payment.'
			cMensRet +=	'<br>Please confirm receipt.'
			cMensRet +=	'<br>Financial Department'
			cMensRet +=	'</font></body></html>'										



	EndCase

EndIf


Return( cMensRet )
