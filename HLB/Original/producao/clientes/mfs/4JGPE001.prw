#include 'protheus.ch'
/*
Funcao      : 4JGPE001 
Parametros  : 
Retorno     : cCont
Objetivos   : Fonte incrementa o campo EE_ULTDSK a cada execução da rotina CNAB de Folha.
Autor       : João Silva
Data/Hora   : 24/06/2014 - 17:50
Revisão     : 
Data/Hora   : 
Módulo      : Gestão Pessoal
*/

*--------------------------*
User Function 4JGPE001()
*--------------------------*
Local cCont:=""
	SEE->(DbSetOrder(1)) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA

	If SEE->(DbSeek(xFilial("SEE")+"033"+"2271 "+"13005733  "+"001"))
		
		SEE->(Reclock('SEE',.F.))
  	   		cCont:= SOMA1(SEE->EE_ULTDSK)
			SEE->EE_ULTDSK:=cCont
		SEE->(Msunlock())
	
	EndIf
		
Return(cCont)