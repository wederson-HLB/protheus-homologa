
User Function M410PSDC()
Local aDados :={}
Local aArea  :=GetArea()

Do Case
   Case cEmpAnt == "X2"
        //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
        SC6->(dbSetOrder(1))
        If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
           While! Eof().And.SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM

                //DC_FILIAL, DC_PRODUTO, DC_LOCAL, DC_ORIGEM, DC_PEDIDO, DC_ITEM
                SDC->(dbSetOrder(1))
                If SDC->(dbSeek(xFilial("SDC")+SC6->C6_PRODUTO+SC6->C6_LOCAL+"SC6"+SC5->C5_NUM+SC6->C6_ITEM))
                   While! Eof().And.xFilial("SDC")+SC6->C6_PRODUTO+SC6->C6_LOCAL+"SC6"+SC5->C5_NUM+SC6->C6_ITEM == SDC->DC_FILIAL+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_ORIGEM+SDC->DC_PEDIDO+SDC->DC_ITEM
                          aadd(aDados,{SDC->DC_PRODUTO, SDC->DC_LOCAL, SDC->DC_ORIGEM, SDC->DC_PEDIDO, SDC->DC_ITEM, SDC->DC_SEQ, SDC->DC_LOTECTL, SDC->DC_NUMLOTE, SDC->DC_LOCALIZ, SDC->DC_NUMSERI, SDC->DC_QUANT})
                          SDC->(dbSkip())
                   End 
                EndIf
       
                SC6->(dbSkip())
            End    
        EndIf 
EndCase   

RestArea(aArea)
Return(aDados)
