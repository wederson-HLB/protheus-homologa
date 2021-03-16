#include "totvs.ch"   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC001  �Autor  Tiago Luiz Mendon�a  � Data �  20/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de cadastro de atendentes                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
Funcao      : GTHDC001()
Objetivos   : Rotina de cadastro de atendentes
Autor       : Tiago Luiz Mendon�a
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
Objetivos   : Tratamento de dicion�rio para os campos da rotina.
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 20/07/2011
*/
*-----------------------------------*
 User Function HDC01DIC(cCampo,cTp)
*-----------------------------------*
Local cRet:=""   
Local aGetUser:=AllUsers() 

Default cCampo:=""
Default cTp:=2  
 
//Retorna o nome do us�rio.
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
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 20/07/2011

*---------------------------*
  User Function GTHDC003()
*---------------------------*  

Local bOK:={|| ValUser("Z05") }

AxCadastro("Z05","Usu�rios",,,,,bOK)  

Return    

/*
Funcao      : GTHDC004()
Objetivos   : Rotina de cadastro de noticias
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 20/07/2011

*---------------------------*
  User Function GTHDC004()
*---------------------------* 


AxCadastro("Z06","Canal de noticias",,,)  

Return 

/*
Funcao      : GTHDC005()
Objetivos   : Rotina de cadastro de noticias
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 07/11/2011

*---------------------------*
  User Function GTHDC005()
*---------------------------* 

AxCadastro("Z07","TimeSheet",,,)  

Return   

Funcao      : GTHDC006()
Objetivos   : Rotina de cadastro de empresa x funcionarios
Autor       : Tiago Luiz Mendon�a
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
Objetivos   : Valida usu�rio na grava��o do usu�rio
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 05/07/2012


*--------------------------------*
  Static Function ValUser(cAlias)
*--------------------------------* 
 
Local nPos   := 0     
Local cEmail := "" 
Local aUsers 
Local lRet   := .T.

If cAlias == "Z05"
                      
    //Carrega todos usu�rios.
    aUsers := AllUsers() 
            
	//Busca a posi��o do usu�rio no array
	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
		cEmail := aUsers[nPos,1,14]
	EndIf    
          
 	//Verifica se o usu�rio est� alterando, incluindo ou deletando seu proprio usu�rio.
	If Alltrim(Z05->Z05_EMAIL) <> Alltrim(UPPER	(cEmail)) 
		//Se n�o for supervisor n�o pode alterar                   	
    	Z05->(DbSetOrder(1))
    	IF Z05->(DbSeek(xFilial("Z05")+Alltrim(UPPER(cEmail))))	
	    	If Alltrim(Z05->Z05_CARGO) <> "05" .And. Alltrim(Z05->Z05_CARGO) <> "04" 
	    		MsgStop("Acesso n�o permetido","Grant Thornton")                          
	        	lRet:=.F.   
	    	EndIf    	
		EndIf
	EndIf


EndIf

Return  lRet

