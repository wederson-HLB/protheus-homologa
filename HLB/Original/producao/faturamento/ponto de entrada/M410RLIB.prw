
User Function M410RLIB()
Local aArea := GetArea()
Local aDados:= {}
Local nI := 1
If! Empty(PARAMIXB)
    If ValType(PARAMIXB) == "A"
        aDados:= aClone(PARAMIXB)

        For nI:=1 To Len(aDados)
            dbSelectArea("SDC")
            dbSetOrder(1)
            If! dbSeek(xFilial("SDC")+aDados[nI][1]+aDados[nI][2]+aDados[nI][3]+aDados[nI][4]+aDados[nI][5]+aDados[nI][6]+aDados[nI][7]+aDados[nI][8]+aDados[nI][9]+aDados[nI][10])
               If aDados[nI][11] >0
                    Reclock("SDC",.T.)
                    SDC->DC_FILIAL  := xFilial("SDC")
                    SDC->DC_PRODUTO := aDados[nI][1]
                    SDC->DC_LOCAL   := aDados[nI][2]
                    SDC->DC_ORIGEM  := aDados[nI][3]
                    SDC->DC_PEDIDO  := aDados[nI][4]
                    SDC->DC_ITEM    := aDados[nI][5]
                    SDC->DC_SEQ     := aDados[nI][6]
                    SDC->DC_LOTECTL := aDados[nI][7]
                    SDC->DC_NUMLOTE := aDados[nI][8]
                    SDC->DC_LOCALIZ := aDados[nI][9]
                    SDC->DC_NUMSERI := aDados[nI][10]
                    SDC->DC_QUANT   := aDados[nI][11]
                    MSunLock()
                EndIf 
            EndIf
            dbSkip()
        Next


    EndIf    
EndIf
RestArea(aArea)
Return(aDados)
