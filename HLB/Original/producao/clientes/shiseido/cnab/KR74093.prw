
/*
Funcao      : KR74093
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab Shiseido - Unibanco  
Autor     	: Renato Mendon�a                          
Data     	: 04/01/07                     
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Financeiro. 
Cliente     : Shiseido
*/

*-----------------------*
 User Function KR74093()
*-----------------------*

If Empty(SE1->E1_NUMBCO)
   RecLock("SE1",.F.)
   Replace SE1->E1_NUMBCO  With SEE->EE_FAXATU
   SE1->(MsUnLock())
   RecLock("SEE",.F.)	
   Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,10)
   SEE->(MsUnlock())
   cNumBco := SEE->EE_FAXATU
Else
   cNumBco := SE1->E1_NUMBCO
Endif   
Return(cNumBco)