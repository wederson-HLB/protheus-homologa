/*
Funcao      : KFI341
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Especifico Cnab - Contas a receber - Banco ITAÚ - Geração do nosso numero e digito verificador
Autor     	: Wederson L. Santana  
Data     	: 23/12/2004
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro.
*/

*----------------------*
 User Function KFI341()
*----------------------*

If Empty(SE1->E1_NUMBCO)
   DbSelectArea("SEE")
   RecLock("SEE",.f.)
   Replace SEE->EE_FAXATU With StrZero(Val(SEE->EE_FAXATU)+=1,10)
   MsUnlock()

   chave := "121212121212121212"
   ndig  :=0
   nresto:=0
   nsoma :=0
   nsoma1:=0
   nTot	:=0
   cNosNum:= AllTrim(SubString(SEE->EE_FAXATU,3,8))
   cnum  := AllTrim(SubString(SEE->EE_FAXATU,3,8))+ Alltrim(SEE->EE_AGENCIA)+ AllTrim(SEE->EE_CODEMP) 
   For a:=1 to len(CHAVE)
       nSoma1+=val(substr(cnum,a,1))*val(substr(chave,a,1))
       if nSoma1 > 9
       		nSoma1+= val(substr(STRZERO(nSoma1),29,1))+val(substr(STRZERO(nSoma1),30,1))	
       endif	
   Next
	nResto1:=nSoma1%10
	nResto:=(10-nResto1)
	
	If nResto = 10
	   nDig := 0
   Else
	   nDig:=nresto
   Endif	

    cNum+=str(nDig,1)
     
    Reclock("SE1",.F.)
    Replace SE1->E1_NUMBCO With STRZERO(VAL(cNosNum),10)
    MsUnlock()                       
Else
    	 cNosNum := SUBSTR(SE1->E1_NUMBCO,3,8)

Endif    

Return(cNosNum)
