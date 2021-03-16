#Include 'Protheus.ch'

/*
Funcao      : FR150FLT()
Objetivos   : O ponto de entrada FR150FLT permite criar um filtro para determinar quais registros não devem ser 
   			  apresentados no Relatório Posição de Títulos a Pagar.
Autor       : Anderson Arrais
Data/Hora   : 29/08/2017
*/       

*----------------------*
User Function FR150FLT()
*----------------------*
Local cExpressao := ""

If cEmpAnt $ "HH/HJ" .AND. !EMPTY(MV_PAR39)//Tem opção de "Forma de pagamento" no sx1 FIN150
	cExpressao := "E2_P_FOPAG <> '"+MV_PAR39+"'"
EndIf

Return(cExpressao)