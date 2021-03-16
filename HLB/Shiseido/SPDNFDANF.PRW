
User Function SPDNFDANF()

If cEmpAnt == "R7"
   MsgInfo("ok","")
EndIf 

Return(Nil)

	//Ponto de entrada para o cliente customizar impressao automatica da DANFE posicionado por nota.
	//	If 	AllTrim(Upper(cEspecieNfe)) $ "SPED"
	//		If ExistBlock("SPDNFDANF")
	//			ExecBlock("SPDNFDANF",.F.,.F.,{cNota,cSerie,SubStr(NfeIdSPED(cXml,"Id"),4)})
	//		EndIf			
	//	EndIf
