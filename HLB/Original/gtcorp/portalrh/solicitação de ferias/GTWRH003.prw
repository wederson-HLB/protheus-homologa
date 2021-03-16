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
±±ºPrograma  ³GTWRH003   ºAutor  ³Tiago Luiz Mendonça º Data ³  11/09/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte html da solicitação de ferias - gravação              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                               
/*
Funcao      : GTWRH003
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX para solicitação de ferias - gravação
Autor       : Tiago Luiz Mendonça
Data/Hora   : 11/09/12
*/

*--------------------------*
  User Function GTWRH003()
*--------------------------*    

Local cHtml    := ""   
Local cNome    := ""
Local cMat     := ""


WEB EXTENDED INIT  cHtml 

	//Define o Modulo em Uso                          				
	SetModulo( "SIGAGPE" , "GPE" )
	
	SRA->( dbSetOrder( RetOrdem("SRA") ) )
	SRA->( MsSeek( xFilial( "SRA" , TCFWGetFil() ) + TCFWGetMat() ) )

	cNome := Capital( AllTrim( SRA->RA_NOME ) )
	cMat  := TCFWGetMat()
	         	 	
	Z75->(DbGoTop()) 
	Z75->(DbSetOrder(1))  
	//Tenta posicionar no registro de solicitação de ferias
	If Z75->(DbSeek("  "+cEmpAnt+TCFWGetFil()+TCFWGetMat()) )
		                       
		//Se estiver pendente, monta a tela
		If Alltrim(Z75->Z75_STATUS) == "P"  
		   
			cHtml += '<html> ' 
  			cHtml +='	<Head>' 
  			cHtml +='  		<script language=”JavaScript”> '
	 		cHtml +=' 			function noBack(){window.history.forward()} '
	   		cHtml +='				 noBack();'
	   		cHtml +=' 				 window.onload=noBack;'
	  		cHtml +='				 window.onpageshow=function(evt){if(evt.persisted)noBack()}'
	   		cHtml +=' 				 window.onunload=function(){void(0)}'
  			cHtml +='		</script>'
	   		cHtml +='	</Head>'
			cHtml +='	<Body >'  
			cHtml +='	 	<span class="dados">' 
   	   		cHtml +='		<div  align="center">'
   	   		cHtml +='   	 	<span class="dados">'  
   	   		cHtml +='				<table border="0">'
   	   		cHtml +='			 		<tr>'
   	   		cHtml +='						<td>'
   	   		cHtml +='							<img border="0" src="imagens/icon_solicitacoes.png" width="42" height="42">'
   	   		cHtml +='						</td>' 
   	   		cHtml +='						<td>'
			cHtml +="		   					Solicitação: "+Z75->Z75_CODIGO+" | Data emissão :"+DtoC(Z75->Z75_DTEMIS)
   	   		cHtml +='						</td>'									
   	   		cHtml +='					</tr>'
   	   		cHtml +='				</table>'	
   	   		cHtml +='			</span>'
   	   		cHtml +='			<hr>'
			cHtml +='		</div>'  
   	   		cHtml +='		<div  align="left" class="dados">'				 
			cHtml +='		    <br>' 
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Matricula: '+cMat+" 
			cHtml +='		    <br>'
 			cHtml +='			&nbsp;&nbsp;&nbsp;&nbsp;Nome : '+cNome   		   		   
			cHtml +='		    <br>'
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Data inical: '+DtoC(Z75->Z75_DTINI)
			cHtml +='		    <br>'
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Data final : '+DtoC(Z75->Z75_DTFIM)	
			cHtml +='		    <br>'
			If Alltrim(Z75->Z75_ADIAN13) == "1" 
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Adianta 13º: Sim'
			Else
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Adianta 13º: Não'		
			EndIf
			cHtml +='		    <br>' 
			If Alltrim(Z75->Z75_ABONA) == "1" 		
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Abono      : Sim'			  
			Else
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Abono      : Não'		
			EndIf		  
			cHtml +='		    <br>'  		   
			cHtml +='		    <br>' 
			cHtml +='		    <hr>'   			
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Status : Pendente de aprovação'  
			cHtml +='		    <br>'
			cHtml +='			&nbsp;&nbsp;&nbsp;&nbsp;Superior : '+Alltrim(HttpSession->cNomeSup)
			cHtml +='		    <br>'
			cHtml +='		    <hr>'    		
			cHtml +='		</div>'
		cHtml +='		</span>'						
			cHtml +='	</Body>'
			cHtml +='</html>' 
		
		//Caso contrario grava
		Else   
		
			RecLock("Z75",.T.)  
			Z75->Z75_FILIAL := "  " // Tabela será única para todas as empresas  "YY"
			Z75->Z75_CODIGO	:= GetSx8Num("Z75","Z75_CODIGO")  
			ConfirmSX8()
			Z75->Z75_NOME   := HttpSession->cNome
			Z75->Z75_NSUP  	:= HttpSession->cNomeSup
			Z75->Z75_DTEMIS	:= dDataBase      
			Z75->Z75_MAT	:= cMat       	
			Z75->Z75_STATUS	:= "P" 
			Z75->Z75_MATSUP := HttpSession->cMatSup  
	   		Z75->Z75_EMP    := cEmpAnt  
	   		Z75->Z75_FILORI := TCFWGetFil()
			  
		    If Alltrim(HttpSession->cDecimo) == "Sim"
				Z75->Z75_ADIAN13	:= "1"
			Else
				Z75->Z75_ADIAN13	:= "2"	
			EndIf 
			
			If Alltrim(HttpSession->cAbono) == "Sim"
				Z75->Z75_ABONA	:= "1"
			Else
				Z75->Z75_ABONA	:= "2"	
			EndIf       
	   		Z75->Z75_DTINI	:= Dtos(CToD(HttpSession->cDtIni)) 
	   		Z75->Z75_DTFIM	:= Dtos(CToD(HttpSession->cDtFim)) 
			//Z75->Z75_OBS		:=
			//Z75_LOGIN 	:=

			Z75->Z75_DESCSTS	:= "Pendente de aprovação"
			
			Z75->(MsUnlock())   
			
			cHtml += '<html> ' 
  			cHtml +='	<Head>' 
  			cHtml +='  		<script language=”JavaScript”> '
			cHtml +=' 			function noBack(){window.history.forward()} '
	  		cHtml +='				 noBack();'
	  		cHtml +=' 				 window.onload=noBack;'
	  		cHtml +='				 window.onpageshow=function(evt){if(evt.persisted)noBack()}'
	  		cHtml +=' 				 window.onunload=function(){void(0)}'
  			cHtml +='		</script>'
	   		cHtml +='	</Head>'
			cHtml +='	<Body>'
  		 	cHtml +='	 	<span class="dados">' 
   			cHtml +='		<div  align="center">'
   	   		cHtml +='   	 	<span class="dados">'  
   	   		cHtml +='				<table border="0">'
   	   		cHtml +='			 		<tr>'
   	   		cHtml +='						<td>'
   	   		cHtml +='							<img border="0" src="imagens/icon_solicitacoes.png" width="42" height="42">'
   	   		cHtml +='						</td>' 
   	   		cHtml +='						<td>'
			cHtml +="		   					Solicitação: "+Z75->Z75_CODIGO+" | Data emissão :"+DtoC(Z75->Z75_DTEMIS)+'  <img border="0" src="imagens/icon_ok.png" width="28" height="28">'
   	   		cHtml +='						</td>'									
   	   		cHtml +='					</tr>'
   	   		cHtml +='				</table>'	
   	   		cHtml +='			</span>'
   	   		cHtml +='			<hr>'
			cHtml +='		</div>' 
   	   		cHtml +='		<div  align="left" class="dados">' 	
			cHtml +='		    <br>' 
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Matricula: '+cMat+" 
			cHtml +='		    <br>'
 			cHtml +='			&nbsp;&nbsp;&nbsp;&nbsp;Nome : '+cNome   		   		   
			cHtml +='		    <br>'
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Data inical: '+DtoC(Z75->Z75_DTINI)
			cHtml +='		    <br>'
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Data final : '+DtoC(Z75->Z75_DTFIM)	
			cHtml +='		    <br>'
			If Alltrim(Z75->Z75_ADIAN13) == "1" 
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Adianta 13º: Sim'
			Else
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Adianta 13º: Não'		
			EndIf
			cHtml +='		    <br>' 
			If Alltrim(Z75->Z75_ABONA) == "1" 		
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Abono      : Sim'			  
			Else
				cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Abono      : Não'		
			EndIf			  
			cHtml +='		    <br>'  		   
			cHtml +='		    <br>' 
			cHtml +='		    <hr>'   			
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Status : Pendente de aprovação'  
			cHtml +='		    <br>'
			cHtml +='			&nbsp;&nbsp;&nbsp;&nbsp;Superior : '+Alltrim(HttpSession->cNomeSup)
			cHtml +='		    <br>'			 
			cHtml +='		    <hr>'   		
			cHtml +='		</div>'
	  		cHtml +='		</span>'						
			cHtml +='	</Body>'
			cHtml +='</html>' 

		EndIf		
	
	//Se não encontrar grava
	Else
		RecLock("Z75",.T.)  
		Z75->Z75_FILIAL := "  "
		Z75->Z75_CODIGO	:= GetSx8Num("Z75","Z75_CODIGO") 
		ConfirmSX8()	 
		Z75->Z75_NOME   := HttpSession->cNome 
		Z75->Z75_NSUP  	:= HttpSession->cNomeSup	
		Z75->Z75_DTEMIS	:= dDataBase      
		Z75->Z75_MAT	:= cMat       	
		Z75->Z75_MATSUP	:= HttpSession->cMatSup  
		Z75->Z75_STATUS	:= "P" 
		Z75->Z75_EMP    := cEmpAnt  
	 	Z75->Z75_FILORI := TCFWGetFil()
			  
		If Alltrim(HttpSession->cDecimo) == "Sim"
			Z75->Z75_ADIAN13	:= "1"
		Else
			Z75->Z75_ADIAN13	:= "2"	
		EndIf 
			
		If Alltrim(HttpSession->cAbono) == "Sim"
			Z75->Z75_ABONA	:= "1"
		Else
			Z75->Z75_ABONA	:= "2"	
		EndIf   
	
		Z75->Z75_DTINI	:= CToD(HttpSession->cDtIni)
		Z75->Z75_DTFIM	:= CToD(HttpSession->cDtFim) 
		//Z75->Z75_OBS		:=
		//Z75_LOGIN 	:=
		Z75->Z75_DESCSTS	:= "Pendente de aprovação"
			
		Z75->(MsUnlock())   
			
		cHtml += '<html> ' 
   		cHtml +='	<Head>' 
		cHtml +='  		<script language=”JavaScript”> '
		cHtml +=' 			function noBack(){window.history.forward()} '
		cHtml +='				 noBack();'
		cHtml +=' 				 window.onload=noBack;'
		cHtml +='				 window.onpageshow=function(evt){if(evt.persisted)noBack()}'
		cHtml +=' 				 window.onunload=function(){void(0)}'
  		cHtml +='		</script>'
	 	cHtml +='	</Head>'
		cHtml +='	<Body>' 
		cHtml +='	 	<span class="dados">' 
  		cHtml +='		<div  align="center">'
 		cHtml +='   	 	<span class="dados">'  
  		cHtml +='				<table border="0">'
  		cHtml +='			 		<tr>'
 		cHtml +='						<td>'
 		cHtml +='							<img border="0" src="imagens/icon_solicitacoes.png" width="42" height="42">'
  		cHtml +='						</td>' 
   		cHtml +='						<td>'
		cHtml +="		   					Solicitação: "+Z75->Z75_CODIGO+" | Data emissão :"+DtoC(Z75->Z75_DTEMIS)
  		cHtml +='						</td>'									
 		cHtml +='					</tr>'
   		cHtml +='				</table>'	
   		cHtml +='			</span>'
   		cHtml +='			<hr>'           
    	cHtml +='		</div>'   		
  		cHtml +='		<div  align="left" class="dados">' 	 
		cHtml +='		    <br>' 
		cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Matricula: '+cMat+" 
		cHtml +='		    <br>'
   		cHtml +='			&nbsp;&nbsp;&nbsp;&nbsp;Nome : '+cNome   		   		   
		cHtml +='		    <br>'
		cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Data inical: '+DtoC(Z75->Z75_DTINI)
		cHtml +='		    <br>'
		cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Data final : '+DtoC(Z75->Z75_DTFIM)	
		cHtml +='		    <br>'
		If Alltrim(Z75->Z75_ADIAN13) == "1" 
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Adianta 13º: Sim'
		Else
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Adianta 13º: Não'		
		EndIf
		cHtml +='		    <br>' 
		If Alltrim(Z75->Z75_ABONA) == "1" 		
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Abono      : Sim'			  
		Else
			cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Abono      : Não'		
		EndIf
		cHtml +='		    <br>'  		   
		cHtml +='		    <br>' 
		cHtml +='		    <hr>'   			
		cHtml +='		    &nbsp;&nbsp;&nbsp;&nbsp;Status : Pendente de aprovação'  
		cHtml +='		    <br>'
		cHtml +='			&nbsp;&nbsp;&nbsp;&nbsp;Superior : '+Alltrim(HttpSession->cNomeSup)
		cHtml +='		    <br>'		
		cHtml +='		    <hr>'   		
		cHtml +='		</div>'
		cHtml +='		</span>'		
		cHtml +='	</Body>'
		cHtml +='</html>' 
		
		GTWRH03A(cHtml)           


	EndIf	
			     

WEB EXTENDED END     

HttpLeaveSession()

Return cHtml   
                                    
/*
Funcao      : GTWRH03A
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de workflow
Autor       : Tiago Luiz Mendonça
Data/Hora   : 17/09/12
*/

*---------------------------------*
  Static Function GTWRH03A(cEmail)
*---------------------------------* 

Local cSubject     	:= ""
Local cTo		   	:= "" 
Local cCc			:= ""     
Local cAnexos       := ""
Local cServer   	:= AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount  	:= AllTrim(GetNewPar("MV_RELFROM"," "))  
Local cFrom         := AllTrim(GetNewPar("MV_RELFROM"," "))  
Local cPassword 	:= AllTrim(GetNewPar("MV_RELPSW" ," "))
Local lAutent		:= GetMv("MV_RELAUTH",,.F.)
 	                                  
    SRA->(DbSetOrder(1)) 
 	If SRA->(Dbseek( Alltrim(TCFWGetFil())+ Alltrim(Z75->Z75_MAT)))
 		 cTo+=SRA->RA_EMAIL+";"
 	EndIf
    
    //Adicona email do superior
	cTo+=HttpSession->cEmailSup+";"
	
 	cSubject :="Solicitação de ferias "+Z75->Z75_CODIGO  
 	cBody    := cEmail 

   	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk      

   	If lOk 
    
    	If lAutent 
     		lAutent := MAILAUTH(cFrom,cPassword)
	  	EndIf
	  
	  	SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk   
	  
   	EndIf

   	DISCONNECT SMTP SERVER 
     
   
Return