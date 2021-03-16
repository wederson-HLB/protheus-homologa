#include "rwmake.ch"
#include "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "totvs.ch"   


#define STATUS_ABERTO "1"
#define STATUS_CONCLUIDO "2"
#define STATUS_CANCELADO "3"
#define STATUS_ATENDIMENTO "4"
#define STATUS_RETORNO "5"  

#define MOV_ABERTURA "A"
#define MOV_COMPLEMENTO "C"
#define MOV_CANCELAMENTO "N"
#define MOV_CHECKIN "I"
#define MOV_RETORNO "R"
#define MOV_SOLUCAO "S"
#define MOV_REABERTURA "E" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDW002  ºAutor  Eduardo C. Romanini  º Data ³  09/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de controle de chamados aguardando retorno do        º±±
±±º          ³usuario.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDW002()
Objetivos   : Rotina de workflow
Autor       : Eduardo C. Romanini
Data/Hora   : 09/09/2011 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/10/2011 
*/
*----------------------*
User Function GTHDW002()
*----------------------*       

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" USER 'admin' PASSWORD 'hdgt@23' MODULO "FAT"
     
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

BeginSql Alias 'QRY'
	SELECT Z01_CODIGO,MAX(Z02_DATA) [DTMOV]
	FROM %table:Z01% Z01
	LEFT JOIN %table:Z02% Z02 ON Z02.Z02_CODIGO = Z01.Z01_CODIGO AND Z02.%notDel%
	WHERE Z01.%notDel%
	  AND Z01.Z01_STATUS = '5'       
	  AND Z02.Z02_TIPO = 'R'
	GROUP BY Z01_CODIGO
	ORDER BY Z01_CODIGO		
EndSql
          
Conout("Montou o arquivo")

QRY->(DbGoTop())
While QRY->(!EOF())
    
	//Sete dias aguardando retorno, envia e-mail de aviso.
	If dDataBase - StoD(QRY->DTMOV) == 7
		HDW002Mail("A")
	//Dez dias aguardando retorno, encerra o chamado.
	ElseIf dDataBase - StoD(QRY->DTMOV) >= 10//Alterado de 14 para 10.
		HDW002Mail("E")
	EndIf
	
	QRY->(DbSkip())
EndDo
                        
QRY->(DbCloseArea())    

RESET ENVIRONMENT

Return

*-------------------------------*
Static Function HDW002Mail(cTipo)
*-------------------------------*   

Local cHtml     := ""
Local cBody     := ""
Local cSubject  := ""       
Local cTo       := "" 
Local Ccc       := ""                   

Local cServer   := "mail.br.gt.com"   // AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount  := "totvs@br.gt.com"  // AllTrim(GetNewPar("MV_RELFROM"," "))
Local cPassword := "Protheus@2010"    // AllTrim(GetNewPar("MV_RELPSW" ," "))
Local cFrom 	:= "totvs@br.gt.com"  // AllTrim(GetNewPar("MV_RELFROM"," "))
Local lOk      	:= .F.
Local cNum      := QRY->Z01_CODIGO

cHtml += '<HTML>'
cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'
cHtml += '<head>'
cHtml += '<title>Aviso de '+IIF(cTipo=="A",'feedback','encerramento')+' do chamado.</title>'
cHtml += '</head>'
cHtml += '<body>'
cHtml += '<table width="644" border="0" align="center" cellpadding="0" cellspacing="0">'
cHtml += '<tr>'
cHtml += '<td><img width="646" height="101" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg"></td>'
cHtml += '</tr>'
cHtml += '<tr>'
cHtml += '<td align="right">'
cHtml += '<table width="644" border="0" cellspacing="0" cellpadding="0" style="font-family:Calibri, Arial, Helvetica, sans-serif; font-size:13px;">'
cHtml += '<tr>'      
cHtml += '<td width="114" style="border-left:#D9D9D9 solid 1px;border-bottom:#D9D9D9 solid 1px " >&nbsp;</td>'
cHtml += '<td width="419" align="left" valign="top" style="border-bottom:#D9D9D9 solid 1px">'
cHtml += '<p><br><br>Prezado(a),'
If cTipo=="A"  //Aviso
	cHtml +=	'<br><br>O chamado <strong>'+QRY->Z01_CODIGO+;
				'</strong> est&aacute; aguardando sua manipula&ccedil;&atilde;o e ser&aacute; encerrado '+;
				'automaticamente em 3 (tr&ecircs) dias, caso n&atilde;o haja retorno.</p>'
Else		   //Encerramento
	cHtml += '<br><br>O chamado <strong>'+QRY->Z01_CODIGO+'</strong> foi encerrado por falta de retorno.</p>'		
EndIf				

Z01->(DbSetOrder(1))
If Z01->(DbSeek(xFilial("Z01")+QRY->Z01_CODIGO)) 
	cHtml += '<p><strong>Resumo do chamado :</strong>'+Z01->Z01_RESUMO+'</p>'												
	cHtml += '<p><strong>Incidente :</strong>'+Z01->Z01_SOLICI
Else
	cHtml += '<p><strong>Incidente :</strong> N&atilde;o foi possivel imprimir o incidente'
EndIf
cHtml += '<p style="color:#064f92"><strong>Esta &eacute; uma mensagem autom&aacute;tica, favor n&atilde;o responder este e-mail.</strong></p></td>'
cHtml += '<td width="111" align="right" valign="bottom" style="border-right:#D9D9D9 solid 1px;border-bottom:#D9D9D9 solid 1px " >&nbsp;</td>'
cHtml += '</tr>'
cHtml += '</table>'
cHtml += '</td>'
cHtml += '</tr>'
cHtml += '</table>'
cHtml += '</body>'
cHtml += '</html>'

cSubject	:= "Aviso de "+IIF(cTipo=="A",'feedback','encerramento')+" do chamado - "+Alltrim(cNum)
cBody   	:= cHtml
cAnexos     := ""      
   
//Conecta ao servidor de e-mail                                  	
//Connect Smtp Server cServer Account cAccount Password cPassword Result lOk
                              
//Conectado
//If lOk           
If .T.
	Conout("Conectado ao servidor de email")
	If Select("QRY2") > 0
		QRY2->(DbCloseArea())
	EndIf
           
	// Pega o último item do chamado
	BeginSql Alias 'QRY2'
	SELECT MAX(Z02_ITEM) [ITEM]
	FROM %table:Z02% Z02
   		WHERE Z02.%notDel%
		AND Z02.Z02_CODIGO = %exp:cNum%
	EndSql
                 
    // Se encontrou o último item do chamado
    If QRY2->(!EOF())
 		// Posiciona no último item do chamado.
 		Z02->(DbSetOrder(1))
    	If Z02->(DbSeek(xFilial("Z02")+cNum+QRY2->ITEM))
    	    // Encerramento    
    		If cTipo == "E"      
    			Conout(cNum + " - Chamado encerrado")
    			RecLock("Z01",.F.)  
    			Z01->Z01_PARECE := Z02->Z02_DESCRI
				Z01->Z01_STATUS := STATUS_CONCLUIDO
				Z01->Z01_DT_ENC := dDataBase

				//Na solução do chamado, altera o status do chamado Totvs para Encerrado.
				If !Empty(Z01->Z01_CTOTVS) .and. AllTrim(Z01->Z01_STOTVS) <> "E"
		        	Z01->Z01_STOTVS := "E" //Encerrado
				EndIf

				Z01->(MsUnlock())    
    
   				RecLock("Z02",.T.)
				Z02->Z02_CODIGO := QRY->Z01_CODIGO       
    			Z02->Z02_ITEM   := Strzero((Val(QRY2->ITEM)+1),2) 
    			Z02->Z02_DATA   := dDataBase
    			Z02->Z02_HORA   := Time()
    			Z02->Z02_TIPO   := MOV_SOLUCAO
    			Z02->Z02_DESCRI := "Chamado concluído por falta de retorno"
    			Z02->Z02_CODUSR := "000000"
   				Z02->(MsUnlock()) 
   			EndIf
   			
   			//Email do atendente
   			If !Empty(Z01->Z01_CODATE) .or. !Empty(Z01->Z01_CODAT2)
				Z03->(DbSetOrder(1))
		 		If Z03->(DbSeek(xFilial("Z03")+ ALLTRIM((Z01->Z01_CODATE+Z01->Z01_CODAT2)) ))
		   			cTo += Alltrim(UsrRetMail(Z03->Z03_ID_PSS))+";"
		   		EndIf
		    EndIf

			//Adiciona o e-mail do solicitante do chamado.
			cTo += Alltrim(UsrRetMail(Z01->Z01_CODUSR))+";"

			//Envio do email.
			oEmail          := DEmail():New()
			oEmail:cFrom   	:= cFrom
			oEmail:cTo		:= cTo
			oEmail:cSubject	:= cSubject
			oEmail:cBody   	:= cBody
			oEmail:Envia()
			//SEND MAIL FROM cFrom TO cTo BCC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk
   		EndIf
	EndIf   
 	QRY2->(DbCloseArea())
EndIf

DISCONNECT SMTP SERVER 

Return Nil