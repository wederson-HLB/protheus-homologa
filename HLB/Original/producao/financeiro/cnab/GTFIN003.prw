#include 'protheus.ch'

/*
Funcao      : GTFIN003
Parametros  : cCodBan,cAgen,cConta,cSub
Retorno     : cCont
Objetivos   : Fonte incrementa o campo EE_ULTDSK a cada execução da rotina
			  CNAB de pagamento de folha.
Autor       : Anderson Arrais
Data/Hora   : 24/04/2015
Obs         :
Revisão     :
Data/Hora   :
Módulo      : Financeiro
Cliente     : Todos
*/

*-----------------------------------------------------*
 User Function GTFIN003(cCodBan,cAgen,cConta,cSub)
*-----------------------------------------------------*        
Local cCont:= ""
    
	SEE->(DbSetOrder(1)) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA

	If SEE->(DbSeek(xFilial("SEE")+PADR(cCodBan,TamSX3("EE_CODIGO")[1],'')+PADR(cAgen,TamSX3("EE_AGENCIA")[1],'')+;
	   PADR(cConta,TamSX3("EE_CONTA")[1],'')+PADR(cSub,TamSX3("EE_SUBCTA")[1],'')))
		
		SEE->(Reclock('SEE',.F.))
  		cCont:= SEE->EE_ULTDSK
		cCont:= SOMA1(SEE->EE_ULTDSK)
		SEE->EE_ULTDSK = cCont
		SEE->(Msunlock())
	
	EndIf
		
Return(cCont)