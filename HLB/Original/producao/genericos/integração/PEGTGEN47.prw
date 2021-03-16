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
	
	If cEmpAnt == "6T" .And. cTES $ "01A/02A"
		cRet := "01"
	Endif	

Return cRet