
User Function CriaSb2()

dbSelectArea("SB1")
dbSetOrder(1)
While! Eof()

    dbSelectArea("SB2")
    dbsetOrder(1)
    If !dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
	    CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
    EndIf

   dbSelectArea("SB1")
   dbSkip()
End
Return
