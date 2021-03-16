#include 'protheus.ch'

/*
Funcao      : GTFIN016
Parametros  : cCodBan,cAgen,cConta,cSub
Retorno     : cCont
Objetivos   : Fonte incrementa o campo EE_FAXATU a cada execução, gerando parte do nr do documento obrigatorio
			  CNAB de pagamento de folha.
Autor       : Anderson Arrais
Data/Hora   : 11/01/2016
Obs         : CNAB de folha de pagamento HSBC 240
Revisão     :
Data/Hora   :
Módulo      : Financeiro
Cliente     : Todos
*/

*-----------------------------------------------------*
 User Function GTFIN016(cCodBan,cAgen,cConta,cSub)
*-----------------------------------------------------*        
Local cCont:= ""
Local cRet := ""
    
	SEE->(DbSetOrder(1)) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA

	If SEE->(DbSeek(xFilial("SEE")+PADR(cCodBan,TamSX3("EE_CODIGO")[1],'')+PADR(cAgen,TamSX3("EE_AGENCIA")[1],'')+;
	   PADR(cConta,TamSX3("EE_CONTA")[1],'')+PADR(cSub,TamSX3("EE_SUBCTA")[1],'')))
		
		SEE->(Reclock('SEE',.F.))
  		cCont:= AllTrim(SEE->EE_FAXATU)
		cCont:= SOMA1(SEE->EE_FAXATU)
		SEE->EE_FAXATU = cCont
		cRet := SubStr(AllTrim(cCont),5,8)
		SEE->(Msunlock())

	EndIf

Return(cRet)