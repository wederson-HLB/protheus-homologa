#include "protheus.ch"   

/*
Funcao      : F200PORT
Parametros  : 
Retorno     : lRet
Objetivos   : Utilizado para definir o banco a ser utilizado na baixa do t�tulo no retorno CNAB a Receber.
Autor       : 
TDN         : 
Revis�o     : Matheus Massarotto
Data/Hora   : 19/08/2015
M�dulo      : Financeiro.
*/                      

*--------------------------*
 User Function F200PORT()   
*--------------------------*   
//.T. = Utiliza o portador do titulo, ignorando o banco do retorno CNAB (padr�o caso n�o exista o ponto de entrada)
//.F. = Utiliza o banco do retorno CNAB
Local lRet:=.T.

if cEmpAnt $ "MN/MR/HH/HJ"
	lRet:=.F.
endif

Return(lRet)