#include "protheus.ch"   

/*
Funcao      : F200PORT
Parametros  : 
Retorno     : lRet
Objetivos   : Utilizado para definir o banco a ser utilizado na baixa do título no retorno CNAB a Receber.
Autor       : 
TDN         : 
Revisão     : Matheus Massarotto
Data/Hora   : 19/08/2015
Módulo      : Financeiro.
*/                      

*--------------------------*
 User Function F200PORT()   
*--------------------------*   
//.T. = Utiliza o portador do titulo, ignorando o banco do retorno CNAB (padrão caso não exista o ponto de entrada)
//.F. = Utiliza o banco do retorno CNAB
Local lRet:=.T.

if cEmpAnt $ "MN/MR/HH/HJ"
	lRet:=.F.
endif

Return(lRet)