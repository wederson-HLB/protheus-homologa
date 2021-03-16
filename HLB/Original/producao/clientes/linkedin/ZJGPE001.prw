#include 'protheus.ch'
/*
Funcao      : ZJGPE001 
Parametros  : nOpc
Retorno     : cCont
Objetivos   : Fonte incrementa o campo EE_ULTDSK a cada execução da rotina CNAB de Folha.
Autor       : João Silva
Data/Hora   : 26/11/2013  
Revisão     : 
Data/Hora   : 
Módulo      : Gestão Pessoal
*/

*--------------------------*
User Function ZJGPE001()
*--------------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Versionador de arquivos remessa    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCont:=""   

	SEE->(DbSetOrder(1)) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA

	If SEE->(DbSeek(xFilial("SEE")+"755"+"1306 "+"10033016  "+"001"))
		
		SEE->(Reclock('SEE',.F.))
  	   		cCont:= SOMA1(SEE->EE_ULTDSK)
			SEE->EE_ULTDSK:=cCont
		SEE->(Msunlock())
	
	EndIf
		
Return(cCont)    

       

