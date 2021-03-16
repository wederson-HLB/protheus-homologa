#include "totvs.ch"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDC001  ºAutor  Tiago Luiz Mendonça  º Data ³  20/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de cadastro de atendentes                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDC001()
Objetivos   : Rotina de cadastro de atendentes
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/07/2011
*/
*---------------------------*
  User Function GTHDC001()
*---------------------------* 

Local aRotAdic :={} 

aadd(aRotAdic,{ "Importa Users","U_GTHDAPSS", 0 , 3 })

AxCadastro("Z03","Cadastro de atendentes",,,aRotAdic)  

Return 

/*
Funcao      : HDC01DIC
Objetivos   : Tratamento de dicionário para os campos da rotina.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/07/2011
*/
*-----------------------------------*
 User Function HDC01DIC(cCampo,cTp)
*-----------------------------------*
Local cRet:=""   
Local aGetUser:=AllUsers() 

Default cCampo:=""
Default cTp:=2  
 
//Retorna o nome do usário.
If cCampo=="Z03_NOME" 
	
	IF cTp==1 //Inicializador do campo
		If !Empty(M->Z03_ID_PSS)
			nPos := ASCAN(aGetUser,{|X| X[1,1] == M->Z03_ID_PSS })
			If nPos > 1  
		   		cRet:=aGetUser[nPos,1,2]
   	   		EndIf	    		  
   		EndIf    
   	Else //Inicializador do browse.
   		If !Empty(Z03->Z03_ID_PSS)
			nPos := ASCAN(aGetUser,{|X| X[1,1] == Z03->Z03_ID_PSS })
			If nPos > 1  
		   		cRet:=aGetUser[nPos,1,2]
   	   		EndIf	    		  
   		EndIf      	
   	EndIF
EndIf

Return cRet 

/*
Funcao      : GTHDC003()
Objetivos   : Rotina de cadastro de atendentes
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/07/2011

*---------------------------*
  User Function GTHDC003()
*---------------------------*  

Local bOK:={|| ValUser("Z05") }

AxCadastro("Z05","Usuários",,,,,bOK)  

Return    

/*
Funcao      : GTHDC004()
Objetivos   : Rotina de cadastro de noticias
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/07/2011

*---------------------------*
  User Function GTHDC004()
*---------------------------* 


AxCadastro("Z06","Canal de noticias",,,)  

Return 

/*
Funcao      : GTHDC005()
Objetivos   : Rotina de cadastro de noticias
Autor       : Tiago Luiz Mendonça
Data/Hora   : 07/11/2011

*---------------------------*
  User Function GTHDC005()
*---------------------------* 

AxCadastro("Z07","TimeSheet",,,)  

Return   

Funcao      : GTHDC006()
Objetivos   : Rotina de cadastro de empresa x funcionarios
Autor       : Tiago Luiz Mendonça
Data/Hora   : 07/11/2011

*---------------------------*
  User Function GTHDC006()
*---------------------------* 

Local aRotAdic :={} 

aadd(aRotAdic,{ "Rel. Usuarios","U_GTHDR001", 0 , 3 })
aadd(aRotAdic,{ "Rel. Empresas","U_GTHDR002", 0 , 3 })

AxCadastro("Z08","Empresas x Funcionarios",,,aRotAdic)  

Return 

Funcao      : ValUser()
Objetivos   : Valida usuário na gravação do usuário
Autor       : Tiago Luiz Mendonça
Data/Hora   : 05/07/2012


*--------------------------------*
  Static Function ValUser(cAlias)
*--------------------------------* 
 
Local nPos   := 0     
Local cEmail := "" 
Local aUsers 
Local lRet   := .T.

If cAlias == "Z05"
                      
    //Carrega todos usuários.
    aUsers := AllUsers() 
            
	//Busca a posição do usuário no array
	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
		cEmail := aUsers[nPos,1,14]
	EndIf    
          
 	//Verifica se o usuário está alterando, incluindo ou deletando seu proprio usuário.
	If Alltrim(Z05->Z05_EMAIL) <> Alltrim(UPPER	(cEmail)) 
		//Se não for supervisor não pode alterar                   	
    	Z05->(DbSetOrder(1))
    	IF Z05->(DbSeek(xFilial("Z05")+Alltrim(UPPER(cEmail))))	
	    	If Alltrim(Z05->Z05_CARGO) <> "05" .And. Alltrim(Z05->Z05_CARGO) <> "04" 
	    		MsgStop("Acesso não permetido","Grant Thornton")                          
	        	lRet:=.F.   
	    	EndIf    	
		EndIf
	EndIf


EndIf

Return  lRet

