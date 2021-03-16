#include "totvs.ch"  
#include "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWRHG02  ºAutor  ³Tiago Luiz Mendonça º Data ³  24/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envio de email de senha baseado no SRA                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
                               
/*
Funcao      : GTWRHG02
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Envio de email de senha baseado no SRA  
Autor       : Tiago Luiz Mendonça
Data/Hora   : 10/09/12
*/

*-----------------------*
User Function GTWRHG02()
*-----------------------*
 
Local aTable     := {	"SRAYY0","SRACH0","SRA1T0","SRARH0","SRAZ40","SRAZ50","SRAZ60",;
						"SRAZB0","SRAZD0","SRAZF0","SRAZG0","SRAZP0","SRA4C0","SRAZB0",;
						"SRA4K0","SRAMP0","SRAMQ0","SRAMW0","SRAMY0","SRAPN0","SRAZ80"}

Local cFil	 	 := SPACE(6)
Local cTable     := ""
Local cHtml 	 := ""
Local cLog       := ""

Local  oMain 
Local  oDlg	

Local lOk		 := .F. 
Local lRet		 := .F. 

Local cLogOk     := ""
Local cLogErro   := ""
Local cLogEmail  := ""


	DEFINE MSDIALOG oDlg TITLE "Envio de senha para Portal RH"  From 1,16 To 16,75 OF oMain     
	   
		@ 015,020 SAY "Selecione a empresa: " PIXEL SIZE 60,6 of oDlg
 		@ 030,020 COMBOBOX cTable ITEMS aTable PIXEL SIZE 60,6 of oDlg
		@ 015,100 SAY "Informe a Filial: " PIXEL SIZE 60,6 of oDlg
 		@ 030,100 MSGET cFil PIXEL SIZE 30,6 OF oDlg PIXEL PICTURE "99"
		@ 045,020 BUTTON "Cancelar" ACTION Processa({|| oDlg:End(),lOk:=.F. },"Processando...") of oDlg Pixel
  		@ 045,100 BUTTON "Enviar" ACTION Processa({|| oDlg:End(),lOk:=.T. },"Processando...") of oDlg Pixel
			
	ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())	   
    
	If lOk 
	
		If Select("OKSRA") > 0
			OKSRA->(DbCloseArea())	               
		EndIf    
			  
	 	aStruSRA := SRA->(dbStruct())
	    
	 	//Cria temporario dos funcionarios                        
	/*	Select padrão da rotina
		cQuery:=" SELECT * "
		cQuery+=" FROM "+cTable 
		cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
		cQuery+=" AND RA_FILIAL = '"+cFil+"'"  
		cQuery+=" AND RA_DEMISSA = ''"  		
		cQuery+=" AND RA_EMAIL <> ''"  
	*/	
		// AOA - 25/04/2016 - Select exclusivo para enviar informações dos funcionarios transferidos da filial 05 para 01 da empresa Z4
		cQuery:=" SELECT * "
		cQuery+=" FROM "+cTable
		cQuery+=" WHERE RA_FILIAL='"+cFil+"'"
		cQuery+=" AND D_E_L_E_T_='' "
		cQuery+=" AND RA_DEMISSA='' "
		cQuery+=" AND RA_EMAIL<>'' "
		cQuery+=" AND RA_CIC IN (SELECT RA_CIC  FROM "+cTable
		cQuery+=" WHERE RA_DEMISSA = '20160401' "
		cQuery+=" AND RA_FILIAL='05' "
		cQuery+=" AND D_E_L_E_T_='' "
		cQuery+=" AND RA_RESCRAI IN ('30','31')) "

	 	TCQuery cQuery ALIAS "OKSRA" NEW
	
		For nX := 1 To Len(aStruSRA)
			If aStruSRA[nX,2]<>"C"
				TcSetField("OKSRA",aStruSRA[nX,1],aStruSRA[nX,2],aStruSRA[nX,3],aStruSRA[nX,4])
			 EndIf
		Next nX
				
		cTMP := CriaTrab(NIL,.F.)
		Copy To &cTMP
		dbCloseArea()
		dbUseArea(.T.,,cTMP,"OKSRA",.T.)    

		If Select("ERROSRA") > 0
			ERROSRA->(DbCloseArea())	               
		EndIf    
			  
	 	aStruSRA := SRA->(dbStruct())
	    
	 	//Cria temporario dos funcionarios                        
	/*	Select padrão da rotina
		cQuery:=" SELECT * "
		cQuery+=" FROM "+cTable 
		cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
		cQuery+=" AND RA_FILIAL = '"+cFil+"'" 
		cQuery+=" AND RA_DEMISSA = ''"  				 
		cQuery+=" AND RA_EMAIL = ''"  
	*/  
		// AOA - 25/04/2016 - Select exclusivo para enviar informações dos funcionarios transferidos da filial 05 para 01 da empresa Z4
		cQuery:=" SELECT * "
		cQuery+=" FROM "+cTable
		cQuery+=" WHERE RA_FILIAL='"+cFil+"'"
		cQuery+=" AND D_E_L_E_T_='' "
		cQuery+=" AND RA_DEMISSA='' "
		cQuery+=" AND RA_EMAIL='' "
		cQuery+=" AND RA_CIC IN (SELECT RA_CIC  FROM "+cTable
		cQuery+=" WHERE RA_DEMISSA = '20160401' "
		cQuery+=" AND RA_FILIAL='05' "
		cQuery+=" AND D_E_L_E_T_='' "
		cQuery+=" AND RA_RESCRAI IN ('30','31')) "
		
	 	TCQuery cQuery ALIAS "ERROSRA" NEW
	
		For nX := 1 To Len(aStruSRA)
			If aStruSRA[nX,2]<>"C"
				TcSetField("ERROSRA",aStruSRA[nX,1],aStruSRA[nX,2],aStruSRA[nX,3],aStruSRA[nX,4])
			 EndIf
		Next nX
				
		cTMP := CriaTrab(NIL,.F.)
		Copy To &cTMP
		dbCloseArea()
		dbUseArea(.T.,,cTMP,"ERROSRA",.T.)  
	
		OKSRA->(DbGoTop())	    
		If OKSRA->(!BOF() .and. !EOF())
 	    	
 	       
 	    	
 	    	While OKSRA->(!EOF())        
 	    	
				cHtml+='<div style="font-family: Arial;">'
				cHtml+='<p class="MsoNormal" style="font-family: Arial, Helvetica, sans-serif; font-size: 13.3333px; background-color: rgb(255, 255, 255);">'
				cHtml+='<span style="font-family: Georgia, serif; font-size: 25pt;">'
				cHtml+='<span style="color: rgb(139, 71, 137);">'
				cHtml+='<span id="DWT590" class="ZM-SPELLCHECK-MISSPELLED">Comunicado</span></span><br>'
				cHtml+='</span></p>'
				cHtml+='<p class="MsoNormal" style="font-family: Arial, Helvetica, sans-serif; font-size: 13.3333px; background-color: rgb(255, 255, 255);">'
				cHtml+='<span style="font-family: Georgia, serif; font-size: 15pt;">'
				cHtml+='<span id="DWT591" class="ZM-SPELLCHECK-MISSPELLED">Envio de dados para acessar o Portal RH.</span></p>'
				cHtml+='<br style="font-family: Arial, Helvetica, sans-serif; font-size: 13.3333px; background-color: rgb(255, 255, 255);">'
				cHtml+='<div class="MsoNormal" style="font-family: Arial, Helvetica, sans-serif; font-size: 13.3333px; text-align: center; background-color: rgb(255, 255, 255);" align="center"><hr noshade="" size="1" width="100%" align="center"></div>'
				cHtml+='<p class="MsoNormal" style="font-family: Arial, Helvetica, sans-serif; font-size: 13.3333px; background-color: rgb(255, 255, 255);"><b><span style="font-family: Arial, sans-serif; color: rgb(146, 208, 80); font-size: 10pt;">&nbsp;</span></b></p>'
				cHtml+='<span style="font-size: 10pt; font-family: Georgia, serif; background-color: rgb(255, 255, 255);">Para acessar o portal RH clique no link :&nbsp;<br><br><b>'
				cHtml+='<a class="moz-txt-link-freetext" href="http://portalrh.grantthornton.com.br/" target="_blank" style="color: darkblue; text-decoration: none; cursor: pointer;">'
				cHtml+='<span id="DWT596" class="ZM-SPELLCHECK-MISSPELLED">http://portalrh.grantthornton.com.br</span></a>'
				cHtml+='</b><br><br><b>'+Alltrim(OKSRA->RA_NOME)+'</b>&nbsp;, '
				cHtml+='abaixo suas informações para acessar o portal:&nbsp;<br><br>'
				cHtml+='<span id="DWT605" class="ZM-SPELLCHECK-MISSPELLED">Matricula</span>:<b>&nbsp;'+OKSRA->RA_MAT+'</b>&nbsp;<br>'
				cHtml+='<br>Senha:<b>&nbsp;'+Substr(OKSRA->RA_SENHA,4,1)+Substr(OKSRA->RA_SENHA,1,1)+Substr(OKSRA->RA_SENHA,5,1)+Substr(OKSRA->RA_SENHA,2,1)+Substr(OKSRA->RA_SENHA,6,1)+Substr(OKSRA->RA_SENHA,3,1)+'</b>&nbsp;<br><br>'
				cHtml+='<span id="DWT608" class="ZM-SPELLCHECK-MISSPELLED">Código da Empresa / Filial</span>:<b>&nbsp;'+substr(cTable,4,2)+' / '+cFil+'&nbsp;</b>'
				cHtml+='</span></div>'
				cHtml+='<br><br>'
				cHtml+='<div class="MsoNormal" style="font-family: Arial, Helvetica, sans-serif; font-size: 13.3333px; text-align: center; background-color: rgb(255, 255, 255);" align="center"><hr noshade="" size="1" width="100%" align="center"></div>'
				cHtml+="<center><span style='font-size:10pt;font-family:"
				cHtml+='"Verdana","sans-serif"'
				cHtml+=";mso-fareast-font-family:"
				cHtml+='"Times New Roman"'
				cHtml+=";color:Red'>"	
				cHtml+="GRANT THORNTON - Mensagem automática, favor não responder este e-mail."
				cHtml+="</span></center>"
	    	
		    	cFrom:="portalrh@br.gt.com"
		    	
				lRet:=U_GTCORP43(cFrom,OKSRA->RA_EMAIL,"","Acesso ao Portal Rh",cHtml,"\Doc\Doc_Portal_RH.pdf")
				      
				If lRet
					cLogOk  += "ENVIADO | Matricula: "+alltrim(OKSRA->RA_MAT)+" Nome: "+alltrim(OKSRA->RA_NOME)+" | Email: "+alltrim(OKSRA->RA_EMAIL)+CHR(13)+CHR(10) 	
				Else
					cLogErro    += "FALHA | Matricula: "+alltrim(OKSRA->RA_MAT)+" Nome: "+alltrim(OKSRA->RA_NOME)+" | Email: "+alltrim(OKSRA->RA_EMAIL)+CHR(13)+CHR(10) 					
				EndIf
				
				cHtml   := ""

				 
				OKSRA->(DbSkip())
		    
		    EndDo 
	   		
	   		ERROSRA->(DbGoTop())	    
	   		If ERROSRA->(!BOF() .and. !EOF())
 	    		While ERROSRA->(!EOF()) 		    
					cLogEmail  += "EMAIL VAZIO | Matricula: "+alltrim(ERROSRA->RA_MAT)+" Nome: "+alltrim(ERROSRA->RA_NOME)+CHR(13)+CHR(10) 
		  			ERROSRA->(DbSkip())
		    	EndDo 
	   	   EndIf			        
		    
		    
		  	DEFINE MSDIALOG oDlg TITLE "Resultado"  From 1,16 To 16,75 OF oMain     
			   

		  		@ 015,100 BUTTON "Log de envio" ACTION Processa({|| EECVIEW(cLogOk,"Detalhes da atualização")}) of oDlg Pixel
		  		@ 035,100 BUTTON "Log de falha" ACTION Processa({|| EECVIEW(cLogErro,"Detalhes da atualização")}) of oDlg Pixel
		  		@ 055,100 BUTTON "Log sem email" ACTION Processa({|| EECVIEW(cLogEmail,"Detalhes da atualização")}) of oDlg Pixel
				@ 065,020 BUTTON "Sair" ACTION Processa({|| oDlg:End()}) of oDlg Pixel 
			
			ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())	     	 
		
		Else    
			DEFINE MSDIALOG oDlg TITLE "Colaborador invalido" From 1,12 To 12,45 OF oMain       
	   
		  		@ 010,008 SAY "Não foi encontrado nenhum colaborador"	Of oDlg PIXEL 
		    	@ 020,008 SAY "com o campo RA_EMAIL preenchido "  	Of oDlg PIXEL                        
	        
	        ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())
		
		EndIf  
		    

           
    EndIf


Return  
	         
	 