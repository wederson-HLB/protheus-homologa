/*
Funcao      : CODBAR07
Parametros  : Nenhum
Retorno     : cCodBar
Objetivos   : Monta código de Barras para o Sispag da Engecorps
Autor     	: Vitor Bedin
Data     	: 22/07/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 

*-------------------------*
 User Function CODBAR07()   
*-------------------------*

Private cCodBar

cCodBar := SUBSTR(SE2->E2_CODBAR,1,4) + SUBSTR(SE2->E2_CODBAR,33,1)+SUBSTR(SE2->E2_CODBAR,34,14)+SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)

Return cCodBar