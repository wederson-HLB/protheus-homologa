#INCLUDE "PROTHEUS.CH"

/*
Funcao      : MDIOK
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. de Validação do Acesso SIGAMDI
Autor     	: Jean Victor Rocha
Data     	: 19/12/2014
Obs         : 
*/
*-------------------*
User Function MdiOk()
*-------------------*
Local lRet := .F.
Local lMdiOk

//Se for Administrador não executa.
If FwIsAdmin()
	Return !lRet
EndIf

ALERT("Acesso ao SIGAMDI não autorizado, alterar o programa inicial para SIGAADV")

Return lRet