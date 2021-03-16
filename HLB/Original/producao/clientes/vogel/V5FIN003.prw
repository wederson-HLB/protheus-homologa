#Include 'Totvs.Ch'

/*
Funcao      : V5FIN003
Parametros  : nParam
Retorno     : cPrefixo
Objetivos   : Fonte cutomizado para a Vogel tratando o prefixo no financeiro
Autor       : Renato Rezende
Data/Hora   : 20/10/2016
Módulo      : Financeiro
Cliente		: Vogel
*/

*--------------------------------*
 User Function V5FIN003(nParam)
*--------------------------------* 
Local cPrefixo 	:= ""

/*
nParam = 1 - MV_1DUPREF - SF2->F2_SERIE 
nParam = 2 - MV_2DUPREF - SF1->F1_SERIE 
*/

//Verifica se é a empresa Vogel
If cEmpAnt $ u_EmpVogel()
    //Conteúdo padrão dos parâmetros
	If nParam == 1
		cPrefixo := SF2->F2_SERIE
	ElseIf nParam == 2
		cPrefixo := SF1->F1_SERIE
	EndIf
    //Verifica se essa série será utilizada em mais de 1 filial
	If ZX3->(DbSeek(xFilial('ZX3')+cEmpAnt+cFilAnt+SB1->B1_TIPO))
		If ZX3->ZX3_EXCLU
			If nParam == 1
				cPrefixo := SF2->F2_FILIAL+SUBSTR(SF2->F2_SERIE,1,1)
			ElseIf nParam == 2
				cPrefixo := SF1->F1_FILIAL+SUBSTR(SF1->F1_SERIE,1,1)
			EndIf
		EndIf
	EndIf

EndIf

Return cPrefixo 