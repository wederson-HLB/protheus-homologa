*------------------------------*
 User Function Lp531Val()
*------------------------------*
Local nTotRet := 0
Local lImpost := .F.
Local nTotRet := 0
Local lImpost := .F.
Local aArea   := GetArea()

Private _nValor:=0

IF GetMv("MV_MCONTAB") $ "CON"
	If AllTrim(FUNNAME())$ "FINA080" 
	   If (Empty(cCheque).And.!Empty(SE2->E2_NUMBOR)).Or.;
	      (!Empty(cCheque).And.Empty(SE2->E2_NUMBOR)).Or.;
	       cMotBx $ "DEBITO CC"
	       Do Case                                                            
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53102" 
						IF  SE2->E2_NUMBCO == SEF->EF_NUM
	               	_nValor :=IIF(SE5->E5_MOTBX=="DAC",0,SE2->E2_MULTA)           
						ENDIF
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53103" 
	               _nValPis  := 0
	               _nValCof  := 0
	               _nValCsl  := 0          
	                   
	               _cParcela := SE2->E2_PARCELA
	               _cParcPis := SE2->E2_PARCPIS
	               _cParcCof := SE2->E2_PARCCOF
	               _cParcSll := SE2->E2_PARCSLL                                        
					   _nValor   := SE2->E2_VALOR
	
	               SE2->(DbSetOrder(1))
	               If SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcPis)) 
	                  _nValPis := SE2->E2_VALOR
	               Endif
	               If SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcCof)) 
	                  _nValCof := SE2->E2_VALOR
	               Endif
	               If SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcSll)) 
	                  _nValCsl := SE2->E2_VALOR
	               Endif
	               SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcela))
						  					  	
					  	If Alltrim(SE2->E2_ORIGEM) == 'FINA050' .AND. !cMotBx $ "DEBITO CC"
						   _nValor :=SE5->E5_VALOR
						EndIf                 
						If Alltrim(SE2->E2_ORIGEM) == 'MATA100'
					  	   _nValor :=SE5->E5_VALOR
	               EndIf
	
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53104" 
						IF  SE2->E2_NUMBCO == SEF->EF_NUM
	               	_nValor :=IIF(SE5->E5_MOTBX=="DAC",0,SE2->E2_JUROS)                                                                                                                                                               
						 ENDIF
  				 Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53105" 		 
  				      _nValor :=SE2->E2_DESCONT
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53107" 
	               _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_PIS,0) 
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53108" 
	               _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_COFINS,0)                                                                                                                                                          
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53109" 
	               _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_CSLL,0)
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53111" 
	               _nValPis  := 0
	               _nValCof  := 0
	               _nValCsl  := 0          
	                   
	               _cParcela := SE2->E2_PARCELA
	               _cParcPis := SE2->E2_PARCPIS
	               _cParcCof := SE2->E2_PARCCOF
	               _cParcSll := SE2->E2_PARCSLL                                        
	               _nValor   := (SE2->E2_VALOR-SE2->E2_SALDO-SE2->E2_DESCONT)+(SE2->E2_MULTA+SE2->E2_JUROS)
	               
	               SE2->(DbSetOrder(1))
	               If SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcPis))
	                  _nValPis := SE2->E2_VALOR
	               Endif
	               If SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcCof))
	                  _nValCof := SE2->E2_VALOR
	               Endif
	               If SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcSll))
	                  _nValCsl := SE2->E2_VALOR
	               Endif
	               SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+_cParcela))
	               _nValor := _nValor-(_nValPis+_nValCof+_nValCsl)
		       EndCase
	   Endif    
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	     Do Case                                                            
	        Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53107" 
	             _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_PIS,0) 
	        Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53108" 
	             _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_COFINS,0)                                                                                                                                                          
	        Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53109" 
	             _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_CSLL,0)
	     EndCase
	Endif
	
ELSE // CONTABILIDADE GERENCIAL
ComparaE:=paramixb

	If AllTrim(FUNNAME())$ "FINA080/FINA750" 
        //RRP - 20/11/2016 - Ajuste geral, error de valores ao cancelar a baixa.
        nTotRet:= SuperGetMv("MV_VL13137" , .F., 0)
        lImpost:= SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL >= nTotRet
        
        //JSS - Ajustado para solucionaor o caso 029836                          
		If (Empty(cCheque).Or.cMotBx $ "DEB")
	       Do Case                                                            
	          Case AllTrim(ComparaE) $ "531002" 
					IF  SE2->E2_NUMBCO == SEF->EF_NUM
						_nValor :=IIF(SE5->E5_MOTBX=="DAC",0,SE2->E2_MULTA)           
					ENDIF
	          Case AllTrim(ComparaE) $ "531003" 
	                                                                                
			  	IF Alltrim(SE2->E2_ORIGEM) == 'FINA050' .AND. !cMotBx $ "DEB" .OR. !Empty(SE2->E2_NUMBOR)
				   _nValor :=SE2->E2_VALOR
			  	ELSEIF Alltrim(SE2->E2_ORIGEM) == 'MATA100'
				   _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->E2_VALOR)-(SE2->E2_MULTA+SE2->E2_JUROS))
				ELSE
				   _nValor := SE2->E2_VALOR-(SE2->E2_MULTA+SE2->E2_JUROS)
				EndIf
	
	          Case AllTrim(ComparaE) $ "531004" 
				IF  SE2->E2_NUMBCO == SEF->EF_NUM
					_nValor :=IIF(SE5->E5_MOTBX=="DAC",0,SE2->E2_JUROS)                                                                                                                                                               
				ENDIF 
	          Case AllTrim(ComparaE) $ "531007" 
	               _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="".AND.lImpost,SE2->E2_PIS,0) 
	          Case AllTrim(ComparaE) $ "531008"
	               _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="".AND.lImpost,SE2->E2_COFINS,0)                                                                                                                                                          
	          Case AllTrim(ComparaE) $ "531009" 
	               _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="".AND.lImpost,SE2->E2_CSLL,0)
	          Case AllTrim(ComparaE) $ "531011"
	               
					IF !Empty(SE2->E2_NUMBOR)
						_nValor := SE5->E5_VALOR
					ELSE
						If lImpost
							_nValor   := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_DESCONT)
						Else
							_nValor   := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_DESCONT)
						EndIf
					ENDIF
	               
		       EndCase
	   Endif    
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	     Do Case                                                            
	        Case AllTrim(ComparaE) $ "531007" 
	             _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_PIS,0) 
	        Case AllTrim(ComparaE) $ "531008" 
	             _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_COFINS,0)                                                                                                                                                          
	        Case AllTrim(ComparaE) $ "531009" 
	             _nValor :=IIF(ALLTRIM(SE2->E2_LOTE)=="",SE2->E2_CSLL,0)
	     EndCase
	Endif
ENDIF
RestArea(aArea)

Return(_nValor)