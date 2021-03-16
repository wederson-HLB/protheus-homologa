#Include "apwebex.ch"
#include "tbiconn.ch"     
#include "totvs.ch"
#Include "topconn.ch"     
#INCLUDE "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWGM006  ºAutor  ³Tiago Luiz Mendonça º Data ³  20/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Movimentação por empresa - Dashboard.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
                               
/*
Funcao      : GTWGM006
Parametros  : Modulo que deve ser executado
Retorno     : Nil
Objetivos   : Rotina APWBEX de grafico de movimentação  .
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/06/12 20:00
*/

*-------------------------------*
  User Function GTWGM006(cTipo)
*-------------------------------*    

Local cTipo
Local cHtml:="" 
Local cFil     		:= ""
Local cEmp  	 	:= ""
Local cBanco 		:= "" 
Local cAno      	:= "" 
Local cAux          := ""                           
Local cNome         := ""   

Local aStru         := {} 
                      
	Private nCon 		:= 0   
	
WEB EXTENDED INIT  cHtml 

	If Select("SX2") == 0
		PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' MODULO 'FIN'
	EndIf  
    
    //Cria variaveis com dados da empresa
	ZW1->(DbSetOrder(1))
	If ZW1->(DbSeek(xFilial("ZW1")+HttpSession->cEmpresa))
		cEmp   := ZW1->ZW1_CODIGO
		cFil   := ZW1->ZW1_CODFIL
		cBanco := RetBanco(ZW1->ZW1_AMB) 
		cNome  := alltrim(ZW1->ZW1_NFANT)
		cAno   := HttpSession->cAno 
	EndIf 

	//Abre conexão com banco 
 	nCon := TCLink("MSSQL7/DbCorporativo","10.0.30.5",7894)  
	If Select("cMovTipo") > 0
		cMovTipo->(DbCloseArea())	               
	EndIf  
	
	//Monta estrutura do temporario
	aStru := {     {"TIPO"	,"C", 200,0  } ,;
	               {"JAN" 	,"C" ,30 ,0  } ,;
	               {"FEV" 	,"C" ,30 ,0  } ,;
	               {"MAR" 	,"C" ,30 ,0  } ,;
	               {"ABR"	,"C" ,30 ,0  } ,;
	               {"MAI" 	,"C" ,30 ,0  } ,;
	               {"JUN" 	,"C" ,30 ,0  } ,;
	               {"JUL" 	,"C" ,30 ,0  } ,; 
	               {"AGO" 	,"C" ,30 ,0  } ,;
	               {"SETE"	,"C" ,30 ,0  } ,;
	               {"OUTU" 	,"C" ,30 ,0  } ,;
	               {"NOV" 	,"C" ,30 ,0  } ,;
	               {"DEZ" 	,"C" ,30 ,0  } }
	         	  
     
    //Cria temporario com dados que serão apresentados no grafico pelo tipo.                              
 	cQuery:=" SELECT * "
	cQuery+=" FROM MOV_"+Alltrim(cEmp)+" where ANO='"+cAno+"' AND TIPO like '"+cTIPO+"%'" 

	TCQuery cQuery ALIAS "cMovTipo" NEW

	For nX := 1 To Len(aStru)
	    If aStru[nX,2]<>"C"
		    TcSetField("cMovTipo",aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    EndIf
	Next nX

	cTMP := CriaTrab(NIL,.F.)
	Copy To &cTMP
	dbCloseArea()
	dbUseArea(.T.,,cTMP,"cMovTipo",.T., .F.)    
	
	cMovTipo->(DbGoTop())  
	 
	//Cria sessão para validação de dados T possui / F não possui 
	If !Empty(cMovTipo->Tipo)
   		&("HttpSession->l"+cTipo) :="T"	
		Conout("Possui dados:"+cTipo+" ok ")
	Else    
		&("HttpSession->l"+cTipo) :="F"	
		Conout("Não possui dados:"+cTipo)
	EndIf 
	         		
		 	
    //Fecha a conexão do banco
	TcUnlink(nCon) 
              
	//Dados encontrados , monta script do gráfico
	If 	&("HttpSession->l"+cTipo) =="T"		
	
		Conout("Montando grafico :"+cTipo)
 		
		cHtml += "['Meses'"
		
   		//Monta os tipo de movimentos
   		cMovTipo->(DbGoTop())	   
		While cMovTipo->(!EOF())  

			cHtml +=",'"+Substr(Alltrim(cMovTipo->TIPO),5,20)+"'" 

	    	cMovTipo->(DbSkip())	   
	    EndDo 
	    
	    cHtml += "],['JAN' 
		 
		//Monta Janeiro
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->JAN)

			EndIf

			cMovTipo->(DbSkip())
	  	EndDo 
	  	
	  	cHtml += "],['FEV' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->FEV)	
   
			EndIf

			cMovTipo->(DbSkip())
	  	EndDo
	  	
	  	cHtml += "],['MAR' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->MAR)	

			EndIf

			cMovTipo->(DbSkip())
	  	EndDo	  	

	  	cHtml += "],['ABR' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)
 	
 				cHtml += ","+Alltrim(cMovTipo->ABR)	
    
			EndIf

			cMovTipo->(DbSkip())
	  	EndDo	  	

	  	cHtml += "],['MAI' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->MAI)	

			EndIf    

			cMovTipo->(DbSkip())
	  	EndDo	 

	  	cHtml += "],['JUN' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->JUN)	
    
			EndIf

			cMovTipo->(DbSkip())
	  	EndDo

	  	cHtml += "],['JUL' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->JUL)	
     
			EndIf

			cMovTipo->(DbSkip())
	  	EndDo   
	  	
	  	cHtml += "],['AGO' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->AGO)	
    
			EndIf

			cMovTipo->(DbSkip())
	  	EndDo
	  	
	  	
	  	cHtml += "],['SET' 	 
	    
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			     
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->SETE)	

			EndIf             

			cMovTipo->(DbSkip())
	  	EndDo
	  	
	  	cHtml += "],['OUT' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
  			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)
		
				cHtml += ","+Alltrim(cMovTipo->OUTU)	
	
			EndIf
		
			cMovTipo->(DbSkip())
	  	EndDo	  	
	  		  	
	  	
	  	cHtml += "],['NOV' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->NOV)	
    
			EndIf

			cMovTipo->(DbSkip())
	  	EndDo
	  	
	  	cHtml += "],['DEZ' 	 
	  
		//Monta 
		cMovTipo->(DbGoTop())
		While cMovTipo->(!EOF())          
			                   
			If Substr(cMovTipo->TIPO,1,3)==alltrim(cTipo)

				cHtml += ","+Alltrim(cMovTipo->DEZ)	
			
			EndIf    

			cMovTipo->(DbSkip())
	  	EndDo
	  	
	  	
 		cHtml += "]]);"     
 		
 		Conout("Grafico montado :"+cTipo)
 		
   
 	//Dados não encontrados, monta o gráfico com zeros				
 	Else
 	
		cHtml += "['Meses'"
		cHtml +=",'"+Alltrim(cTipo)+"'" 
	    cHtml += "],['JAN' 
		cHtml += ",0" 	
	  	cHtml += "],['FEV' 	 
		cHtml += ",0" 	  
	  	cHtml += "],['MAR' 	 
		cHtml += ",0" 	 
	  	cHtml += "],['ABR' 	 
		cHtml += ",0" 	  
	  	cHtml += "],['MAI' 	 
		cHtml += ",0" 
	  	cHtml += "],['JUN' 	 
		cHtml += ",0" 	  
	  	cHtml += "],['JUL' 	 
		cHtml += ",0" 
	  	cHtml += "],['AGO' 	 
		cHtml += ",0" 
	  	cHtml += "],['SET' 	 
		cHtml += ",0" 	   
	  	cHtml += "],['OUT' 	 
		cHtml += ",0" 	  	
	  	cHtml += "],['NOV' 	 
		cHtml += ",0" 	  
	  	cHtml += "],['DEZ' 	 
		cHtml += ",0" 	  	
 		cHtml += "]]);" 
 		
 		Conout("Grafico montado com valores zerados :"+cTipo)

 	
 	EndIf		

WEB EXTENDED END     

Return cHtml            


/*
Funcao      : RETBANCO
Parametros  : cAmb
Retorno     : cNome
Objetivos   : Retornar o banco utilizado pela conexão
Autor       : Tiago Luiz Mendonça
Data/Hora   : 09/08/12 
*/

*------------------------------*
 Static Function RETBANCO(cAmb)
*------------------------------*  

Local cNome := ""
	            
	If Alltrim(cAmb) == "AMB01"
		cNome:="AMB01_P10"
	ElseIf Alltrim(cAmb) == "AMB02"	
		cNome:="AMB02_P10"	
	ElseIf Alltrim(cAmb) == "AMB03"	
		cNome:="AMB03_P10"	
	Else
		cNome:=cAmb
	EndIf	
	
Return cNome   

