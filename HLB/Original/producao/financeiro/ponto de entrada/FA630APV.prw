#Include "Protheus.ch"

/*
Funcao      : FA630APV
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de Entrada, que ao retornar Falso, impede o prosseguimento da aprova��o da Solicita��o de Transfer�ncia de D�bito.
TDN			: 
Autor       : Anderson Arrais
Data/Hora   : 29/06/2016
Módulo      : Financeiro
*/                                        

*----------------------*
User Function FA630APV
*----------------------*
Private lRet		:= .T.
    Posicione("SE1",1,xFilial("SE1")+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO),"E1_CLIENTE")
	if ALLTRIM(SE1->E1_NUMBOR) <> ''
		Msginfo("A Solicita��o de Transfer�ncia de D�bito n�o pode ser aprovado por est� em border�.","HLB BRASIL")
		lRet:=.F.
	endif
	
Return(lRet)