
/*
Funcao      : K487451
Parametros  : Nenhum
Retorno     : cNumBco+cResto
Objetivos   : Cnab CitiBank   
Autor     	: Wederson L. Santana / José Ferreira
Data     	: 10/03/06
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro.
*/
   
*-----------------------*
 User Function K487451()  
*-----------------------*  

Local cNumBco :=""

If Empty(SE1->E1_NUMBCO)
	RecLock("SE1",.F.)
	Replace SE1->E1_NUMBCO  With SEE->EE_FAXATU
	SE1->(MsUnLock())
	cNumBco := SEE->EE_FAXATU
	RecLock("SEE",.F.)	
	Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,11)
	SEE->(MsUnlock())
Else
   cNumBco := AllTrim(SE1->E1_NUMBCO)
Endif                
nBaseDiv := 0
cStrMult := "3298765432"
_nTam    := Len(cstrMult)
_nNumBco := Len(Alltrim(cNumBco))
While _nNumBco > 0
	   nBaseDiv += Val(SubStr(cNumBco,_nNumBco,1)) * Val(SubStr(cStrMult,_nTam,1))
		_nNumBco -=1
		_nTam    -=1
End
nResto  := nBaseDiv%11		// Calcula Modulo 11

If nResto > 1
   cResto  := Alltrim (Str(11-nResto))
 	If AllTrim(cResto) == "10" 
	   cResto := "1"
    EndIf
Else
   cResto :=Alltrim (Str(nResto))
  If cResto == "1" 
	 cResto := "0"
  Endif	 
EndIf
       
Return(StrZero(Val(cNumBco+cResto),12))