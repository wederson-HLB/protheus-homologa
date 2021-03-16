
User Function A650CCF()
Local cCodProd := PARAMIXB[1]
Local cFabCom  := PARAMIXB[2]

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cCodProd))
   If! Empty(SB1->B1_PRODSBP)
       cFabCom := Iif(SB1->B1_PRODSBP == "P","F","C")
   EndIf    
EndIf

Return(cFabCom)
