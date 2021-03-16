#Include "rwmake.ch"    

/*
Funcao      : GTFIN032
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Trata código de transmissão para cobrança Santander.
Autor       : 
TDN         : 
OBS			: Layout Santander de 400 posições contas a receber	
Revisão     : Anderson Arrais
Data/Hora   : 02/06/2017
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN032(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Código de transmissão					   						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
    cRet := cValToChar(&(SuperGetMv("MV_P_00103"))[1])
Endif

RestArea(aArea)
Return(cRet)