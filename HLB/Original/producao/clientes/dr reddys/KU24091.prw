
/*
Funcao      : KU24091
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab Dr. Reddy´s - Unibanco  
Autor     	: Wederson L. Santana 
Data     	: 30/03/05
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro.
*/

*--------------------------*
 User Function KU24091()
*--------------------------*

If Empty(SE1->E1_NUMBCO) 
   nProx:=0
   RecLock("SE1",.F.)
   Replace SE1->E1_NUMBCO  With SEE->EE_FAXATU
   SE1->(MsUnLock())
   SEE->(DbSetOrder(1))
   SEE->(DbSeek(XFilial()+SE1->E1_PORTADO+SE1->E1_AGEDEP))	    
   nProx:=Val(SEE->EE_FAXATU)+1  
   RecLock("SEE",.F.)	
   SEE->EE_FAXATU:=Alltrim(Str(nProx))
   SEE->(MsUnlock())
   cNumBco := SEE->EE_FAXATU
Else
   cNumBco := SE1->E1_NUMBCO
Endif   
Return(cNumBco)
