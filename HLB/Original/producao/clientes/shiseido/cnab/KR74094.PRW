
/*
Funcao      : KR74094
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emissao Boleto unibanco
Autor     	: Renato Mendonça                          
Data     	: 04/01/07                     
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Financeiro. 
Cliente     : Shiseido
*/

*-----------------------*
 User Function KR74094() 
*-----------------------*
 
Local nBaseDiv := 0                                 
Local	cStrMult := "43298765432"         //    Sequencia de verificacao
Local	_nTam    := Len(cStrMult)         //--> Quantidade de Digitos Sequencia verificacao
Local cNumBco  := SE1->E1_NUMBCO          //--> Digitos Nosso Numero
//Local cNumBco  := "8411390469"
Local	_nNumBco := Len(Alltrim(cNumBco)) //--> Quantidade de Digitos Nosso Numero

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