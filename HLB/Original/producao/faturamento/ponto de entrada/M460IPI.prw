#include "rwmake.ch"

/*
Funcao      : M460IPI
Parametros  : Nil
Retorno     : VALORIPI
Objetivos   : Rotina para recalculo do valor do IPI na NF de Venda
TDN         : ALIQUOTA DO IPI Retorna o valor do IPI Variaveis Disponiveis no ponto de entrada: VALORIPI BASEIPI QUANTIDADE ALIQIPI BASEIPIFRETE.
Autor       : Marçal de Campos (Pessoa externa)
Data/Hora   : 29/07/2011    10:14
Revisão		: Matheus Massarotto                   
Data/Hora   : 12/09/2012    13:46
Módulo      : Gestão de Contratos
*/

*---------------------*
User Function M460IPI()
*---------------------*

Local _nValTab:= 0 
Local _nAliqP := 0  
Local cTES

if cEmpAnt $ "VJ/R7" //Shiseido TESTE

	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek(xFilial("SB1") + SC9->C9_PRODUTO)
	
	Dbselectarea("SB0")
	Dbsetorder(1)
	Dbseek(xFilial("SB0") + SC9->C9_PRODUTO)
	
	Dbselectarea("SC6")
	Dbsetorder(1)
	Dbseek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM)
	        
	cTes:=Alltrim(GetMv("MV_P_TESLJ"))
	
	If SC6->C6_TES $ cTes
	
		_nAliqP  := SB1->B1_IPI
		_nValTab := SB0->B0_PRV1
		
		BASEIPI  := ((_nValTab * QUANTIDADE) * 0.90) 
		ALIQIPI  := _nAliqP
		VALORIPI := (((_nValTab * QUANTIDADE) * 0.90) * _nAliqP)/100
	
	Endif

endif

Return(VALORIPI)