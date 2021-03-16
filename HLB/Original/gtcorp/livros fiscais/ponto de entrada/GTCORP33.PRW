#Include "Protheus.ch"

/*
Funcao      : GTCORP33 
Parametros  : PARAMIXB
Retorno     : nRet
Objetivos   : Ponto de entrada customizado no arquivo NFERIO.ini versão protheus 11, para tratamento dos valores de PCC da nota fiscal de serviço.
Autor       : Matheus Massarotto
TDN         : 
Revisão     : 
Data/Hora   : 06/08/2012
Módulo      : Livros Fiscais.
*/

*--------------------*
User Function GTCORP33
*--------------------*
Local aParam:=PARAMIXB
Local nRet:=0
Local aArea:=GetArea()

/*
aParam[1] // Tipo CF-,CS-,PI-
aParam[2] // Prefixo
aParam[3] // Número
*/

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
if DbSeek(xFilial("SE1")+aParam[2]+aParam[3])
	while SE1->(!EOF()) .AND. aParam[2]+aParam[3]==SE1->E1_PREFIXO+SE1->E1_NUM
		if alltrim(upper(SE1->E1_TIPO))==alltrim(upper(aParam[1]))
			nRet:=SE1->E1_VALOR	
		endif
		SE1->(DbSkip())
	enddo
endif

RestArea(aArea)
Return(nRet)