#include 'protheus.ch'
/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ?9XFIN001 ()?Autor  ?Jo?o Silva         ? Data ?  21/062013   ???
?????????????????????????????????????????????????????????????????????????͹??
???Desc.     ?Fonte incrementa o campo EE_ULTDSK a cada execu??o da rotina???
???          ?CNAB de pagamento.                                          ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Gilead - P11_09 		                                      ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/
*--------------------------*
User Function 9XFIN001()
*--------------------------*        
Local cCont:= ""
    
	SEE->(DbSetOrder(1)) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA

	If SEE->(DbSeek(xFilial("SEE")+"376"+"0001 "+"01101772  "+"001"))
		
		SEE->(Reclock('SEE',.F.))
  		cCont:= SEE->EE_ULTDSK
		cCont:= SOMA1(SEE->EE_ULTDSK)
		SEE->EE_ULTDSK = cCont
		SEE->(Msunlock())
	
	EndIf
		
Return(cCont)