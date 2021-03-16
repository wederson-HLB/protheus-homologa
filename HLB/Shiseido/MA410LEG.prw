//--------------------------------------------------------------------------------------------
//Específico Shiseido - Faturamento - 07/10/2020
//Wederson L. Santana
//--------------------------------------------------------------------------------------------
//Ponto de entrada legenda da tela do pedido.
//--------------------------------------------------------------------------------------------

#include 'protheus.ch' 
#Include "rwmake.ch" 

User Function MA410LEG()
Local clegenda
Local aLegenda:=PARAMIXB
If cEmpAnt == "R7"
   aAdd(aLegenda,{"BR_BRANCO", "Atualizado pelo operador - IDL"})
EndIf 

Return(aLegenda)
