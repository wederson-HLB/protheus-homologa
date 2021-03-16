
/*
Funcao      : KR73413
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab Shiseido - Unibanco
Autor     	: José Ferreira                            
Data     	: 04/01/07                     
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Financeiro. 
Cliente     : Shiseido
*/

*------------------------*
 User Function KR73413() 
*------------------------* 
 
         If Empty(SE1->E1_NUMBCO)
            RecLock("SE1",.F.)
            Replace SE1->E1_NUMBCO  With StrZero(VAL(SEE->EE_FAXATU)+1,8)
            SE1->(MsUnLock())
            RecLock("SEE",.F.)	
            Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,8)
            SEE->(MsUnlock())
            cNumBco := SUBSTR(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
         Else
            //cNumBco := SE1->E1_NUMBCO AOA - 18/12/2015 - Completando o nosso número com zeros a esquerda.
            cNumBco := SUBSTR(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
         Endif    
         
Return(cNumBco)