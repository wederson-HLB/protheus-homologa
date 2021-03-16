#include "PROTHEUS.CH"

/*
Funcao      : 61013CLVR
Parametros  : Nenhum
Retorno     : cCLVL
Objetivos   : Alimentar o campos Classe de valor na contabilização com a informação do campos C5_P_NUM.
Autor       : João Silva
Data        : 02/05/2013
Módulo      : Contabilidade Gerencial.
*/

*-------------------------*
User Function 61013CLVR()
*-------------------------*  
Private cCLVL := " "

if cEmpAnt $ "ZB/ZF" 
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		cCLVL:=SC5->C5_P_NUM  
    EndIf
    
Else
	Return(cCLVL)
	
EndIf

Return(cCLVL)     