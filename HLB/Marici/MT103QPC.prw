USER FUNCTION MT103QPC    
Local cQryPar:=ParamIxb[1]
Local cQryRet:= cQryPar
Local cOrder := ""

If cEmpAnt == "X2"
   If FieldPos("C7_P_CTRCT") > 0
      cOrder := StrTran(SubString(cQryPar,at("ORDER",cQryPar)-1,Len(cQryPar)),"'","")
      cQryRet:= SubString(cQryPar,1,at("ORDER",cQryPar)-1)+" AND C7_P_CTRCT = 'N' "+cOrder
   EndIf   
EndIf

Return cQryRet
