#include "PROTHEUS.CH"

/*
Funcao      : LP59601
Parametros  : Nenhum
Retorno     : cCLVR
Objetivos   : Verificar se o tipo do documento é igual NCC oou NCD e caso for não gera contabilização.
Autor       : João Silva
Data        : 08/05/2013
Módulo      : Contabilidade Gerencial.
*/

*-------------------------*
User Function LP59601()
*-------------------------*  
Private cCLVR := " " 

If cEmpAnt $ "MN" .AND. SE1->E1_TIPO $ "NCC/NDC/"
	cCLVR:= 0
Else
	cCLVR:= SE5->E5_VALOR

EndIf

Return(cCLVR)
