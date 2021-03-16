#include "Protheus.ch"    

/*
Funcao      : P_SINUMT
Parametros  : 
Retorno     : 
Objetivos   : Fonte para o cnab da SIRONA. Retorna o prefixo + numero + parcela , retirando caracteres do lado esquerdo do numero afim de manter 10 caracteres
Autor       : Matheus Massarotto
Data/Hora   : 19/10/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*-----------------------*
 User Function P_SINUMT   
*-----------------------*  

Local cRetorno := ""
Local cNum:=""                   

if len(ALLTRIM(SE1->E1_NUM)+ALLTRIM(SE1->E1_PREFIXO)) > 9
	cNum:=alltrim( SUBSTR(ALLTRIM(SE1->E1_NUM),len(ALLTRIM(SE1->E1_NUM)+ALLTRIM(SE1->E1_PREFIXO))-8,len(SE1->E1_NUM) ) )
else
	cNum:=ALLTRIM(SE1->E1_NUM)
endif

cRetorno := ALLTRIM(SE1->E1_PREFIXO) + cNum + alltrim(SE1->E1_PARCELA)

return cRetorno
