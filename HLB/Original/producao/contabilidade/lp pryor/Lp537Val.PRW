
User Function Lp537Val()       
Private _nValor:=0    
_nValor:=0
IF GetMv("MV_MCONTAB") $ "CON"   // SIGACON
	If AllTrim(FUNNAME())$ "FINA080"  
	   If! Empty(cCheque).Or.cMotBx $ "DEBITO CC"   // Se o numero do cheque for <> de branco, ou se o motivo baixa <> debito cc
	       Do Case
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53701"
	               _nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC".OR.SE2->E2_NUMBOR <>"",0, (SE2->((E2_VALOR-E2_JUROS-E2_MULTA)+E2_DESCONT))*SEZ->EZ_PERC )
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53702" 
	               _nValor := SE2->E2_MULTA       
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53703" 
	               _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0, (SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS)))*SEZ->EZ_PERC )
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53704"
	               _nValor := SE2->E2_JUROS*SEZ->EZ_PERC
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53705" 
	               _nValor := SE2->E2_DESCONT*SEZ->EZ_PERC
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53707"
	               _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS*SEZ->EZ_PERC,0)
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53708" 
	               _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS*SEZ->EZ_PERC,0)
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53709" 
	               _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL*SEZ->EZ_PERC,0)
	          //Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53710" 
	               //_nValor := SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53711" 
	               _nValor := ((SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT+SE2->E2_SALDO))*SEZ->EZ_PERC
	          EndCase
	   Endif
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	    Do Case
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53707" 
	            _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS*SEZ->EZ_PERC,0)
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53708" 
	            _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS*SEZ->EZ_PERC,0)
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53709" 
	            _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL*SEZ->EZ_PERC,0)
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53710" 
	            _nValor := (SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL)*SEZ->EZ_PERC //IIF(ALLTRIM(SE5->E5_MOTBX)=="PCC",SE2->E2_VALLIQ,0)
		 EndCase
	ELSEIf AllTrim(FUNNAME())$ "FINA370" 
		Do Case
	   	Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53706" 
		      	_nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC", ((SE2->E2_VALOR+SE2->E2_JUROS+SE2->E2_MULTA)-SE2->E2_DESCONT)*SEZ->EZ_PERC ,0)
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53707" 
	         _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS*SEZ->EZ_PERC,0)
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53708" 
	         _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS*SEZ->EZ_PERC,0)
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53709" 
	         _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL*SEZ->EZ_PERC,0)
	      EndCase
	Endif  

ELSE // CONTABILIDADE GERENCIAL
Compara:=paramixb //Parâmetro passado no execblock contendo o numero do lancto e a sua sequencia.
	If AllTrim(FUNNAME())$ "FINA080/FINA090/FINA750"
	   If AllTrim(FUNNAME())$ "FINA090"
	      cCheque := ''
	   EndIf
	   If! Empty(cCheque).Or.cMotBx $ "DEBITO CC"   
	       Do Case
	          Case Alltrim(Compara) $ "537001"
	               _nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC".OR.SE2->E2_NUMBOR <>"",0,(SE2->((E2_VALOR-E2_JUROS-E2_MULTA)+E2_DESCONT))*SEZ->EZ_PERC )
	          Case AllTrim(Compara) $ "537002" 
	               _nValor := SE2->E2_MULTA       
	          Case AllTrim(Compara) $ "537003" 
	               _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS)))*SEZ->EZ_PERC )
	          Case AllTrim(Compara) $ "537004"
	               _nValor := SE2->E2_JUROS*SEZ->EZ_PERC
	          Case AllTrim(Compara) $ "537005" 
	               _nValor := SE2->E2_DESCONT*SEZ->EZ_PERC
	          Case AllTrim(Compara) $ "537007"
	               _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS*SEZ->EZ_PERC,0)
	          Case AllTrim(Compara) $ "537008" 
	               _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS*SEZ->EZ_PERC,0)
	          Case AllTrim(Compara) $ "537009" 
	               _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL*SEZ->EZ_PERC,0)
	          Case AllTrim(Compara) $ "537011" 
	               _nValor := ((SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT))*SEZ->EZ_PERC
	          EndCase
	   Endif
	
	
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	    Do Case
	       Case AllTrim(Compara) $ "537007" 
	            _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS*SEZ->EZ_PERC,0)
	       Case AllTrim(Compara) $ "537008" 
	            _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS*SEZ->EZ_PERC,0)
	       Case AllTrim(Compara) $ "537009" 
	            _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL*SEZ->EZ_PERC,0)
	       Case AllTrim(Compara) $ "537010" 
	            _nValor := (SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL)*SEZ->EZ_PERC
		 EndCase
	ELSEIf AllTrim(FUNNAME())$ "FINA370" 
		Do Case
	   	Case AllTrim(Compara) $ "537006" 
	      	_nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC",((SE2->E2_VALOR+SE2->E2_JUROS+SE2->E2_MULTA)-SE2->E2_DESCONT)*SEZ->EZ_PERC ,0)
	      Case AllTrim(Compara) $ "537007" 
	         _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS*SEZ->EZ_PERC,0)
	      Case AllTrim(Compara) $ "537008" 
	         _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS*SEZ->EZ_PERC,0)
	      Case AllTrim(Compara) $ "537009" 
	         _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL*SEZ->EZ_PERC,0)
	      EndCase
	Endif
	
ENDIF
	
Return(_nValor)
