#Include "Protheus.ch"

/*
Funcao      : FA630APV
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de Entrada, que ao retornar Falso, impede o prosseguimento da aprovação da Solicitação de Transferência de Débito.
TDN			: 
Autor       : Anderson Arrais
Data/Hora   : 29/06/2016
MÃ³dulo      : Financeiro
*/                                        

*----------------------*
User Function FA630APV
*----------------------*
Private lRet		:= .T.
    Posicione("SE1",1,xFilial("SE1")+SE6->(E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO),"E1_CLIENTE")
	if ALLTRIM(SE1->E1_NUMBOR) <> ''
		Msginfo("A Solicitação de Transferência de Débito não pode ser aprovado por está em borderô.","HLB BRASIL")
		lRet:=.F.
	endif
	
Return(lRet)