#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : LVGPE002
Cliente     : Cotton on
Parametros  : nIni = caracter inicial
			  nQtd = Quantidade caracter
Retorno     : Nenhum
Objetivos   : Função auxiliar para integração de hora extra, busca pelo CPF
Autor       : Jean Victor Rocha
Data/Hora   : 07/01/2016
Revisao     :
Obs.        : 
*/
*-------------------------------*
User Function LVGPE002(nIni,nQtd)
*-------------------------------*
Local cCracha := ""

Default nIni := 3
Default nQtd := 11  

cCfp := ALLTRIM(STR(VAL(SubStr( TXT, nIni,nQtd))))

SRA->(DbSetOrder(20))//RA_CIC+RA_FILIAL+RA_MAT
If SRA->(DbSeek(cCfp))
	If !EMPTY(SRA->RA_DEMISSA)//Validação caso exista mais de uma matricula para o mesmo Funcionario
		While SRA->(!EOF()) .and. VAL(SRA->RA_CIC) == VAL(cCfp) .and. !EMPTY(SRA->RA_DEMISSA)
			SRA->(DbSkip())
		EndDo
	EndIf
	If VAL(SRA->RA_CIC) == VAL(cCfp)
		cRet := SRA->RA_MAT
	Else 
		cRet := cCfp
	EndIf
Else
	cRet := cCfp
EndIf

Return cRet