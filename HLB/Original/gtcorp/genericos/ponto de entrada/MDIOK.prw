#INCLUDE "PROTHEUS.CH"

/*
Funcao      : MDIOK
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. de Valida��o do Acesso SIGAMDI
Autor     	: Jean Victor Rocha
Data     	: 19/12/2014
Obs         : 
*/
*-------------------*
User Function MdiOk()
*-------------------*
Local lRet := .F.
Local lMdiOk

//Se for Administrador n�o executa.
If FwIsAdmin()
	Return !lRet
EndIf

ALERT("Acesso ao SIGAMDI n�o autorizado, alterar o programa inicial para SIGAADV")

Return lRet