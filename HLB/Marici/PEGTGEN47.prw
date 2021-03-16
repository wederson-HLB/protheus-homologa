#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEGTGEN47
//Ponto de entrada utilizado na rotina GTGEN047 para permitir criar a regra de troca de 
armazém conforme empresa e TES 
@author Marcio Martins pereira
@since 07/05/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------

User Function PEGTGEN47()

	Local cRet := ''           
	Local cTES := ParamIXB[1]
	
	If cEmpAnt == "JO" .And. cTES == "3D9"
		cRet := "02"
	Endif	

	If cEmpAnt == "X2"	// 35982588000100 - Marici
		nPsSD1CF := Ascan( aIteSD1[nG], {|x| Alltrim(x[1]) == "D1_CF" } )
		If SubStr(Alltrim(aIteSD1[nG,nPsSD1CF,2]),2,3) == "915"
			cRet := "05"
		Endif 
	Endif 
	
Return cRet
