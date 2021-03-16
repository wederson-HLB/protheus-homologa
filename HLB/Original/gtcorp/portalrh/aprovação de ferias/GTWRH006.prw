#Include "apwebex.ch"
#include "tbiconn.ch"     
#include "totvs.ch"
#Include "topconn.ch"  
#Include "tcfwfun.ch"
#Include "tcfwdef.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWRH006   ºAutor  ³Tiago Luiz Mendonça º Data ³  21/09/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte html da solicitação de ferias - gravação cancelamento º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                               
/*
Funcao      : GTWRH006
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX para solicitação de ferias - gravação
Autor       : Tiago Luiz Mendonça
Data/Hora   : 21/09/12
*/

*--------------------------*
  User Function GTWRH006()
*--------------------------*    

Local cHtml    := ""   

Local aMat     := {} 
Local aResult  := {}



WEB EXTENDED INIT  cHtml 
  

	If  !(ValType(HttpSession->_TCFWFIL))<> "C" 
   	    		
 		aMat:= StrTokArr(HttpSession->cSolicitacoes,",") 	
   		 
   		conout(alltrim(HttpPost->Obs))
   		
   		For i=1 to len(aMat)   
    		
    		Z75->(DbGoTop())  
			Z75->(DbSetOrder(2))  
			If Z75->(DbSeek("  "+alltrim(aMat[i]) )) 
				//Se estiver pendente, monta a tela
				If Alltrim(Z75->Z75_STATUS) == "P"  
					//RecLock("Z75",.F.)  
					//Z75->Z75_DTCANC	:= dDataBase      
				   //	Z75->Z75_STATUS	:= "C" 
				   //Z75->Z75_OBS := Alltrim(HttpPost->Obs) 
				   //	Z75->(MsUnlock())
					
					Aadd(aResult,{aMat[i],"T"})
				Else
					Aadd(aResult,{aMat[i],"F"})
				EndIf
			Else
				Aadd(aResult,{aMat[i],"F"})
			EndIf 
	    
		next 
		
		cHtml += '<html> ' 
  		cHtml +='	<Head>' 
		cHtml +='	</Head>'
		cHtml +='	<Body>' 
   		cHtml +='	 	<span class="dados">'
  		cHtml +='		<div  align="center">' 
  		cHtml +='			<table border="0">'
  		cHtml +='			 	<tr>'
  		cHtml +='					<td>'
  		cHtml +='						<img border="0" src="imagens/icon_cancel2.png" width="40" height="40">'
  		cHtml +='					<td>' 
  		cHtml +='					<td>'
  		cHtml +='						<b>&nbsp;&nbsp;Cancelamento</b>' 
  		cHtml +='					<td>'									
  		cHtml +='				</tr>'
  		cHtml +='			</table>'   
   		cHtml +='       	<hr>' 		
		cHtml +='		</div>' 
		cHtml +="		<div  align='left'>"  
		For i=1 to Len(aResult)            
			If Alltrim(aResult[i][2]) == "T" 
				cHtml +='Solicitação: '+Substr(aResult[i][1],5,6)+' cancelada <img border="0" src="imagens/icon_ok.png" width="28" height="28">' 
				cHtml +='<br>'
			Else
		   		cHtml +='Solicitação: '+Substr(aResult[i][1],5,6)+' não pode ser cancelada <img border="0" src="imagens/icon_cancel.png" width="28" height="28">' 
				cHtml +='<br>'
			EndIf		
		Next
		cHtml +='		</div>'
		cHtml +='	 	</span>'  
  		cHtml +="	</body>" 	
		cHtml += '</html> ' 	
		
	Else
		cHtml += '<html> '  
		cHtml += '	<div align="center" >' 
		cHtml += '		<span class="dados">'  	  
		cHtml += '			<br>'
		cHtml += '			<br>'
		cHtml += '			<br>'  
		cHtml += '			<img border="0" src="imagens/icon_connectivity.png" width="96" height="96">'  
		cHtml += '			<br>'  
		cHtml += '			<br>'  
		cHtml += '			Sessão expirada'
		cHtml += '			<br>'
		cHtml += '			<br>'
		cHtml += '			<br>' 
		cHtml += '		</span>' 
		cHtml += '	</div>' 				
		cHtml += '<html> ' 

	EndIf	
			     

WEB EXTENDED END     

HttpLeaveSession()

Return cHtml   
