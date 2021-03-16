
/*
Funcao      : KU24092
Parametros  : Nenhum
Retorno     : cResto
Objetivos   : Cnab Dr. Reddy´s - Unibanco  
Autor     	: Wederson L. Santana 
Data     	: 12/04/05
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro.
*/

*-------------------------*
 User Function KU24092()
*-------------------------*  

Local nBaseDiv := 0
Local	cStrMult := "43298765432"
Local	_nTam    := Len(cStrMult)
Local cNumBco  := SE1->E1_NUMBCO
Local	_nNumBco := Len(Alltrim(cNumBco))

While _nNumBco > 0
		nBaseDiv += Val(SubStr(cNumBco,_nNumBco,1)) * Val(SubStr(cStrMult,_nTam,1))
		_nNumBco -=1
		_nTam    -=1
End

nResto  := (nBaseDiv*10)%11		// Calcula Modulo 11
cResto  := Alltrim (Str(nResto))

If cResto == "0" .or. cResto == "10" 
	cResto := "0"
EndIf     

Return(cResto)