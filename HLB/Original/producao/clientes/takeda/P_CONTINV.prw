#include "rwmake.ch"        

/*
Funcao      : P_ContInv
Parametros  : 
Retorno     : 
Objetivos   : Abaixo.
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

/*
Fun��o para tratar , exclusivo modalidade 30
151 a 165 - Conta de Investimentos - Dados do Fornecedor - CNPJ/CPF do Investidor
� 151 a 159 - CNPJ/CPF Base do Investidor - 9 d�gitos - Num�rico - Obrigat�ria, modalidade 8 - TED,
quando informado finalidade de TED = 17, para Corretora
� 160 a 163 - CNPJ/CPF - Filial - 4 d�gitos - Num�rico - Obrigat�rio, modalidade 8 - TED, quando
informado finalidade de TED = 17, para Corretora
� 164 a 165 - CNPJ/CPF - Controle - 2 d�gitos - Num�rico - Obrigat�rio, modalidade 8 - TED, quando
informado finalidade de TED = 17, para Corretora
*/ 

*--------------------------*
  User Function P_ContInv()
*--------------------------*


if SE2->E2_P_TPPAG=='30'
	_cCgc := "0"+Left(SA2->A2_CGC,8)+Substr(SA2->A2_CGC,9,4)+Right(SA2->A2_CGC,2)
	
	If SA2->A2_TIPO <> "J" 
	   _cCgc := Left(SA2->A2_CGC,9)+"0000"+Substr(SA2->A2_CGC,10,2)
	Endif
else
	_cCgc :=SPACE(15)
endif

Return(_cCgc)