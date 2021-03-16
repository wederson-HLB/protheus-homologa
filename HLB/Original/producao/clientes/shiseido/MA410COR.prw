//--------------------------------------------------------------------------------------------
//Específico Shiseido - Faturamento - 07/10/2020
//Wederson L. Santana
//--------------------------------------------------------------------------------------------
//Ponto de entrada legenda da tela do pedido.
//--------------------------------------------------------------------------------------------

#include 'protheus.ch' 
#Include "rwmake.ch" 

User Function MA410COR()
Local aLegCor:=PARAMIXB
Local nX :=0
If cEmpAnt == "R7"
   For nX:=1 To Len(aLegCor)
       If Upper(AllTrim(aLegCor[nX][2])) == "ENABLE"
          aLegCor[nX][1]:=  aLegCor[nX][1]+".And. AllTrim(C5_XXOPERA) <> 'S'" 
       EndIf
   Next
   aAdd(aLegCor,{ " AllTrim(C5_XXOPERA) == 'S'.And. Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)"	,	'BR_BRANCO'	,	'Atualizado pelo operador - IDL'	})
EndIf 

Return(aLegCor)
