#Include "Protheus.ch"
#include "rwmake.ch"


/*
Funcao      : GTGEN016
Parametros  : cVar = campo a ser validado.
Retorno     : Nil
Objetivos   : Valida��o para campos do cadastro de clientes.  
Chamado		: 012544
Autor       : Jean Victor Rocha
Data/Hora   : 29/05/2013
M�dulo      : Gen�rico
*/                  
*--------------------------*
User Function GTGEN016(cVar)
*--------------------------*
Local lRet 		:= .T.
//RRP - 17/02/2014 - Inclus�o de caracteres especiais %, ~, ^, [, ], {, }, ;, >, <, �.
Local aCarac 	:= {"_","�","�","*","|","\","�","#","$","@","!",'"',"'","+","=","�","=","?","~","^","[","]","{","}",";",">","<","�"} 

Default cVar	:= ""

For i:=1 to Len(aCarac)
	If AT(aCarac[i],cVar) <> 0 
		//RRP - 17/02/2014 - Altera��o da Mensagem
		MsgStop("Nao � permitido utilizar o Caractere: " + aCarac[i],"HLB BRASIL")
		Return .F.	
	EndIf
Next i

Return lRet