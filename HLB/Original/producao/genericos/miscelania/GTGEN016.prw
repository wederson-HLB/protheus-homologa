#Include "Protheus.ch"
#include "rwmake.ch"


/*
Funcao      : GTGEN016
Parametros  : cVar = campo a ser validado.
Retorno     : Nil
Objetivos   : Validação para campos do cadastro de clientes.  
Chamado		: 012544
Autor       : Jean Victor Rocha
Data/Hora   : 29/05/2013
Módulo      : Genérico
*/                  
*--------------------------*
User Function GTGEN016(cVar)
*--------------------------*
Local lRet 		:= .T.
//RRP - 17/02/2014 - Inclusão de caracteres especiais %, ~, ^, [, ], {, }, ;, >, <, €.
Local aCarac 	:= {"_","º","ª","*","|","\","¨","#","$","@","!",'"',"'","+","=","§","=","?","~","^","[","]","{","}",";",">","<","€"} 

Default cVar	:= ""

For i:=1 to Len(aCarac)
	If AT(aCarac[i],cVar) <> 0 
		//RRP - 17/02/2014 - Alteração da Mensagem
		MsgStop("Nao é permitido utilizar o Caractere: " + aCarac[i],"HLB BRASIL")
		Return .F.	
	EndIf
Next i

Return lRet