//---------------------------------------------------------------------------------------------------------------------------------------------
//Wederson L. Santana - Específico Marici - 31/12/2020
//---------------------------------------------------------------------------------------------------------------------------------------------
  
#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

User Function FCIINFVI()
Local cProduto  := PARAMIXB[1]
Local cMes      := PARAMIXB[2]
Local cAno      := PARAMIXB[3]
Local nQuant    := PARAMIXB[4]
Local cOp       := PARAMIXB[5]
Local nValorImp := 0
Local aArea     := GetArea()

If cEmpAnt == "X2"//Específico FCI Marici
    If SD4->(FieldPos("D4_XXCUSTO")) > 0 .And. SD4->(FieldPos("D4_XXCPER")) > 0
       dbSelectArea("SD4")
       dbSetOrder(2)
       If dbSeek(xFilial("SD4")+cOp+cProduto)
          nValorImp:= (SD4->D4_XXCUSTO/nQuant)
          Reclock("SD4",.F.)
          SD4->D4_XXCPER:= cAno+cMes
          MsunLock()
       EndIf
    EndIf
EndIf

RestArea(aArea)
Return(nValorImp)
