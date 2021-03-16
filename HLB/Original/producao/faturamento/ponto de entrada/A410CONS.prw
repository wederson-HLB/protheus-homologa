//---------------------------------------------------------------------------------------------------------------------------------------------
//Wederson L. Santana - Específico Marici - 31/12/2020
//---------------------------------------------------------------------------------------------------------------------------------------------
  
#include 'protheus.ch'
#include 'parmtype.ch'

User function A410CONS()
Local _aButton := {}
If cEmpAnt == "X2"
    aAdd(_aButton,{"GRAF2D",{|| U_X2FAT001()},"Remessa","Remessa p/ projeto" }) 	
Else
    aAdd(_aButton,{"GRAF2D",{|| MATA030()},"Novo Cliente","Cad. Clientes" }) 	
EndIf

Return(_aButton)
