#Include 'Totvs.Ch'

/*
Funcao      : UYFIN001
Parametros  : nParam
Retorno     : cPrefixo
Objetivos   : Fonte cutomizado para a Media tratando o prefixo no financeiro
Autor       : Renato Rezende
Data/Hora   : 05/09/2017
Módulo      : Financeiro
Cliente		: Media
*/

*--------------------------------*
 User Function UYFIN001(nParam)
*--------------------------------* 
Local cPrefixo 	:= ""

/*
nParam = 1 - MV_1DUPREF - SF2->F2_SERIE 
nParam = 2 - MV_2DUPREF - SF1->F1_SERIE 
*/

//Verifica se é a empresa Media
If cEmpAnt $ "UY"
    //Conteúdo padrão dos parâmetros
	If nParam == 1
		cPrefixo := SF2->F2_SERIE
	ElseIf nParam == 2
		cPrefixo := SF1->F1_SERIE
	EndIf
    //Verifica se essa série não é de telecom
	If ZX1->(DbSeek(xFilial('ZX1')+cEmpAnt+cFilAnt+SF2->F2_SERIE))
		If !ZX1->ZX1_EXCLU
			If nParam == 1
				cPrefixo := SF2->F2_FILIAL+SUBSTR(SF2->F2_SERIE,1,1)
			ElseIf nParam == 2
				cPrefixo := SF1->F1_FILIAL+SUBSTR(SF1->F1_SERIE,1,1)
			EndIf
		EndIf
	EndIf

EndIf

Return cPrefixo