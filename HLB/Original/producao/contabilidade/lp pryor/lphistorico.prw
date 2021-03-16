//---------------------------------------------------------------------------------------------------------------//
//--Wederson - 13/04/2006 - Histórico dos lançamentos contábeis                                                  //
//---------------------------------------------------------------------------------------------------------------//
User Function LpHistorico()

Local cRefProcesso  :=""
Private _cHistorico :="" 

if Type("cMotBx") == "U"  // Variavel cMotBx não disponível na funcao FINA750 - ticket 52001 - João Carlos - 30/11/2018
	cMotBx := ""
endif

IF GetMv("MV_MCONTAB") $ "CON"
	If AllTrim(FUNNAME())$ "FINA080" 
	   Do Case
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53003/53011" 
	           _cHistorico := If(cMotBx $ "DEBITO CC","DEB. ",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),"","CH. "+AllTrim(cCheque)),""))+;
	                          " REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53103/53111" 
	           If Empty(SE2->E2_NUMBOR)
	              SE5->(DbSetOrder(7))
	              If SE5->(DbSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
	                 While SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA ==;
	                       SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA
	                       If SE5->E5_MOTBX $ "NOR".AND.SE5->E5_SITUACA <> 'C'
	                          _cHistorico := "EST.CH."+AllTrim(SE5->E5_NUMCHEQ)+"REF.PGTO"+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)
	                       ElseIf SE5->E5_MOTBX $ "DEB".AND.SE5->E5_SITUACA <> 'C'    
	                          _cHistorico :="EST.DEB.REF.PGTO"+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)
	                       Endif     
	                       SE5->(DbSkip())
	                 End      
	              Endif   
	           Else
	               _cHistorico := "EST.BORD."+Alltrim(SE2->E2_NUMBOR)+"REF.PGTO"+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)              
	           Endif   
	   EndCase   
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	   Do Case
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53103/53111" 
	           _cHistorico := "EST.BORD."+Alltrim(SE2->E2_NUMBOR)+"REF.PGTO"+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53110"            
	           _cHistorico := "EST.PCC.REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
	   EndCase                              
	ElseIf AllTrim(FUNNAME())$ "FINA190"       
	   Do Case
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "59001/59005" 
	           
   			//23/03/2014 - JSS - Fonte ajustado para atender a solicitação do chamado 024556
			//Inicio
			IF SM0->M0_CODIGO $"OZ"   //FISERV / 0001-47                   
				IF ALLTRIM(SE2->E2_NATUREZ)$"4202"   		   /// IRRF S/ SERVICOS
					_cHistorico := "CH. "+AllTrim(cCheque190)+" REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)+"IR RETIDO"
				ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211/4213"    /// PCC S/ SERVIÇO
					_cHistorico := "CH. "+AllTrim(cCheque190)+" REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)+"PCC" 
				ELSE
					_cHistorico := "CH. "+AllTrim(cCheque190)+" REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)   
	      		ENDIF
		    ELSE
				_cHistorico := "CH. "+AllTrim(cCheque190)+" REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)	      		
	      	ENDIF
			//Fim	     
			                     
	      Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "59101/59105"            
	           _cHistorico := "EST.CH. "+AllTrim(SE2->E2_NUMBCO)+" REF.PGTO "+SE2->E2_TIPO+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)      
	   EndCase
	Endif  
ELSE // CONTABILIDADE GERENCIAL
ComparaH:=paramixb
	If AllTrim(FUNNAME())$ "FINA080/FINA090/FINA750/FINA430"
	   If AllTrim(FUNNAME())$ "FINA090"
	      cCheque := ''
	   EndIf 
	   If AllTrim(FUNNAME())$ "FINA750" .AND. SM0->M0_CODIGO $"49"//JSS - Criado ajuste para solução do caso 031668
	      cCheque := ''
	   EndIf
	   Do Case
	      Case AllTrim(ComparaH) $ "530003/530011" 	           
			//23/03/2014 - JSS - Fonte ajustado para atender a solicitação do chamado 024556
			//Inicio
			IF SM0->M0_CODIGO $"OZ"   //FISERV / 0001-47                   
				IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		   		   /// INSS SOBRE SALARIOS
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"INSS FOLHA"
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"         /// FGTS SOBRE SALARIOS
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"FGTS FOLHA"  
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"    /// IRRF S/SALARIOS E FERIAS
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"IRRF FOLHA" 	                          
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206"    /// ISS S/SERVIÇOS PRESTADOS   --- ISS RETIDO
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"ISS"
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	   /// IRPJ
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"IRPJ"
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		   /// CSLL faturamento
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"CSLL"
						ELSE
							_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                          "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
				ENDIF
			ELSEIF SM0->M0_CODIGO $ "ZX/ZW/ZV/ZU/ZY/0B/0C/0E/6Z/6Y" //JSS - Ajustado para solucionar o caso 028172
				_cHistorico := "VR.REF. "+"-"+TRIM(SE5->E5_HISTOR)
			
			ELSE	
                //RSB - 05/12/2017 - Inclusão no nome do fornecedor, utilizado o pocicione. Ticket #19279
				If !Empty(SE2->E2_TITPAI)
					_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
		                           "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+Posicione("SA2",1,xFilial("SA2")+SUBSTR(SE2->E2_TITPAI,17,6)+SUBSTR(SE2->E2_TITPAI,23,2),"SA2->A2_NOME") 				
	            Else
					_cHistorico := If(cMotBx $ "DEBITO CC","DEB.",If(AllTrim(cMotBx) $ "NORMAL",If(Empty(cCheque),".","CH."+AllTrim(cCheque)),""))+;
	                           "REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)				
	            Endif               
			ENDIF
			//Fim	                          
		Case AllTrim(ComparaH) $ "531003/531011" 
			//JSS - Ajustado para solucionaor o caso 029836
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
	           If Empty(SE2->E2_NUMBOR)
	              SE5->(DbSetOrder(7))
	              If SE5->(DbSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
	                 While SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA ==;
	                       SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA
	                       If SE5->E5_MOTBX $ "NOR".AND.SE5->E5_SITUACA <> 'C'
	                          _cHistorico := "EST.CH."+AllTrim(SE5->E5_NUMCHEQ)+"REF.PGTO."+SE2->E2_TIPO+"."+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)
	                       ElseIf SE5->E5_MOTBX $ "DEB".AND.SE5->E5_SITUACA <> 'C'    
	                          _cHistorico :="EST.DEB.REF.PGTO."+AllTrim(SE2->E2_TIPO)+" "+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)
	                       Endif     
	                       SE5->(DbSkip())
	                 End      
	              Endif   
	           Else
	               _cHistorico := "EST.BORD."+Alltrim(SE2->E2_NUMBOR)+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)              
	           Endif   
	   EndCase   
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	   Do Case
	      Case AllTrim(ComparaH) $ "531003/531011" 
	           _cHistorico := "EST. BORD."+Alltrim(SE2->E2_NUMBOR)+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
	      Case AllTrim(ComparaH) $ "531010"            
	           _cHistorico := "EST.PCC.REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
	   EndCase                              
	ElseIf AllTrim(FUNNAME())$ "FINA190"       
	   Do Case
	      Case AllTrim(ComparaH) $ "590001/590005" 
	           _cHistorico := "CH."+AllTrim(cCheque190)+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)
	      Case AllTrim(ComparaH) $ "591001/591005"            
	           _cHistorico := "EST.CH."+AllTrim(SE2->E2_NUMBCO)+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+Alltrim(SA2->A2_NOME)      
	   EndCase 
	ElseIf AllTrim(FUNNAME())$ "FINA370"         	//Alterado por JSS para tender o caso 006930  
		If Type("cCheque") <> "C"//JVR - 19/09/2012 - Declaração de variavel quando nao esta carregada.
			cCheque := ''
		EndIf
	   Do Case
	      Case AllTrim(ComparaH) $ "530003/530011"
	      //23/03/2014 - JSS - Fonte ajustado para atender a solicitação do chamado 024556
			//Inicio 
			IF SM0->M0_CODIGO $"OZ"   //FISERV / 0001-47  
				IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		   		   /// INSS SOBRE SALARIOS
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"INSS FOLHA"
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"         /// FGTS SOBRE SALARIOS
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"FGTS FOLHA"  
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"    /// IRRF S/SALARIOS E FERIAS
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"IRRF FOLHA" 	                          
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206"    /// ISS S/SERVIÇOS PRESTADOS   --- ISS RETIDO
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"ISS"
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	   /// IRPJ
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"IRPJ"
						ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		   /// CSLL faturamento
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+"CSLL"
						ELSE
							_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
				ENDIF
			ELSEIF SM0->M0_CODIGO $ "ZX/ZW/ZV/ZU/ZY/0B/0C/0E/6Z/6Y" //JSS - Ajustado para solucionar o caso 028172
				_cHistorico := "VR.REF. "+"-"+TRIM(SE5->E5_HISTOR)
			ELSE					
				_cHistorico := If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)				
			ENDIF
			//Fim	 			           
	      Case AllTrim(ComparaH) $ "531003/531011"//JVR- 19/09/2012
	           _cHistorico := "EST."+If(Empty(cCheque),"","CH."+AllTrim(cCheque))+" REF.PGTO."+AllTrim(SE2->E2_TIPO)+"."+SE2->E2_NUM+" "+AllTrim(SA2->A2_NOME)
	   EndCase
	
	Endif
   
	// TLM - Tratamento do Historico de Importações.  
	If  AllTrim(ComparaH) $ "950 1" .Or. AllTrim(ComparaH) $ "950 2" .Or. AllTrim(ComparaH) $ "950 3" .Or. AllTrim(ComparaH) $ "950 4" ;
	   .Or. AllTrim(ComparaH) $ "950 5" .Or. AllTrim(ComparaH) $ "950 6"  .Or. AllTrim(ComparaH) $ "950 7"   .Or. AllTrim(ComparaH) $ "950 8" ;   
       .Or. AllTrim(ComparaH) $ "950 9" .Or. AllTrim(ComparaH) $ "950 10" .Or. AllTrim(ComparaH) $ "950 11"  .Or. AllTrim(ComparaH) $ "950 12" ;
       .Or. AllTrim(ComparaH) $ "950 13"    
       
       _cHistorico:=""
       
       SWN->(DbSetOrder(2))
      
      // If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE)) 
         If SWN->(DbSeek(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE))// JSS - Ajustado para atender o caso 015937
          
          SW6->(DbSetOrder(1))  
          If SW6->(DbSeek(xFilial("SW6")+SWN->WN_HAWB))  
                       
             IF SWN->WN_TIPO_NF <> "2"		 
          
                If AllTrim(ComparaH) == "950 1"
                   _cHistorico :="Vlr. Merc. - "
                EndIf   
             
                If AllTrim(ComparaH) == "950 2"
                   _cHistorico :="ICMS - "
                EndIf
             
                If AllTrim(ComparaH) == "950 3"
                   _cHistorico :="IPI - "
                EndIf 
             
                If AllTrim(ComparaH) == "950 4"
                   _cHistorico :="PIS - "
                EndIf                      
             
                If AllTrim(ComparaH) == "950 5"
                   _cHistorico :="COFINS - "
                EndIf
             
                If AllTrim(ComparaH) == "950 6"
                   _cHistorico :="FOB - "
                EndIf
             
                If AllTrim(ComparaH) == "950 7"
                   _cHistorico :="Adiant. - "
                EndIf 
             
             Else   
                 
                If AllTrim(ComparaH) == "950 1"
                   _cHistorico :="Complemento. Merc. - "
                EndIf      
               
                If AllTrim(ComparaH) == "950 8"
                   _cHistorico :="Estorno da Baixa de Adiantamento - "
                EndIf 
               
                If AllTrim(ComparaH) == "950 9"
                   _cHistorico :="Adiantamento ao Despachante - "
                EndIf 
               
                If AllTrim(ComparaH) == "950 10"
                   _cHistorico :="Saldo do adiantamento Debito - "
                EndIf    
               
                If AllTrim(ComparaH) == "950 11"
                   _cHistorico :="Saldo do adiantamento Credito - "
                EndIf   
               
                If AllTrim(ComparaH) == "950 12"
                   _cHistorico :="Baixa do PCC - "
                EndIf                               
               
                If AllTrim(ComparaH) == "950 13"
                   _cHistorico :="Despesa Infraero - "
                EndIf
 
             EndIf
              
             _cHistorico += "IMPORT REF.NF. "+Alltrim(SWN->WN_DOC)+" DI: "+Alltrim(SW6->W6_DI_NUM) 
             _cHistorico += " TX DOLAR: "+Alltrim(str(SW6->W6_TX_US_D))  
             
             If cEmpAnt $ "I7" .Or. cEmpAnt $ "I6"
                _cHistorico +=" REF: "+Alltrim(SW6->W6_HAWB)
             EndIf  
             
             SW9->(DbSetOrder(3)) //W9_FILIAL+W9_HAWB
             If SW9->(DbSeek(xFilial("SW9")+SW6->W6_HAWB)) 
                cInv:=""
                While SW9->(!EOF()) .And. SW6->W6_HAWB == SW9->W9_HAWB .And. cInv <> SW9->W9_INVOICE                
                   _cHistorico +=" INVOICE: "+Alltrim(SW9->W9_INVOICE) 
                   cInv:=SW9->W9_INVOICE
                SW9->(DbSkip())
                EndDo 
             EndIf  
                         
             If SW6->(FieldPos("W6_P_REF")) > 0
                cRefProcesso:=SW6->W6_P_REF
             EndIf      
             
             If !Empty(cRefProcesso) 
                _cHistorico +=" REF:"+cRefProcesso 
             EndIf
                  
          EndIf      
       EndIf                                                                  		
	EndIf   
	
	If AllTrim(ComparaH) $ "955 1" .Or. AllTrim(ComparaH) $ "955 2" .Or. AllTrim(ComparaH) $ "955 3" .Or. AllTrim(ComparaH) $ "955 4" ;
	   .Or. AllTrim(ComparaH) $ "955 5" .Or. AllTrim(ComparaH) $ "955 6" .Or. AllTrim(ComparaH) $ "955 7" .Or. AllTrim(ComparaH) $ "955 8" ; 
	   .Or. AllTrim(ComparaH) $ "955 9" .Or. AllTrim(ComparaH) $ "955 10" .Or. AllTrim(ComparaH) $ "955 11" .Or. AllTrim(ComparaH) $ "955 12";
	   .Or. AllTrim(ComparaH) $ "955 13"              
       
       _cHistorico:=""
      
       SWN->(DbSetOrder(2))
       If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))
          
          SW6->(DbSetOrder(1))  
          If SW6->(DbSeek(xFilial("SW6")+SWN->WN_HAWB)) 
             
             IF SWN->WN_TIPO_NF <> "2"    
                
                If AllTrim(ComparaH) == "955 1"
                   _cHistorico :="EST/ Vlr. Merc. - "
                EndIf   
             
                If AllTrim(ComparaH) == "955 2"
                   _cHistorico :="EST/ ICMS - "
                EndIf
             
                If AllTrim(ComparaH) == "955 3"
                   _cHistorico :="EST/ IPI - "
                EndIf 
             
                If AllTrim(ComparaH) == "955 4"
                   _cHistorico :="EST/ PIS - "
                EndIf                      
             
                If AllTrim(ComparaH) == "955 5"
                   _cHistorico :="EST/ COFINS - "
                EndIf
             
                If AllTrim(ComparaH) == "955 6"
                   _cHistorico :="EST/ FOB - "
                EndIf
             
                If AllTrim(ComparaH) == "955 7"
                   _cHistorico :="EST/ Adiant. - "
                EndIf
           
            Else   
                 
               If AllTrim(ComparaH) == "955 1"
                  _cHistorico :="Complemento. Merc. - "
               EndIf      
               
               If AllTrim(ComparaH) == "955 8"
                  _cHistorico :="EST/ Estorno da Baixa de Adiantamento - "
               EndIf 
               
               If AllTrim(ComparaH) == "955 9"
                  _cHistorico :="EST/ Adiantamento ao Despachante - "
               EndIf 
               
               If AllTrim(ComparaH) == "955 10"
                  _cHistorico :="EST/ Saldo do adiantamento Debito - "
               EndIf    
               
               If AllTrim(ComparaH) == "955 11"
                  _cHistorico :="EST/ Saldo do adiantamento Credito - "
               EndIf   
               
               If AllTrim(ComparaH) == "955 12"
                  _cHistorico :="EST/ Baixa do PCC - "
               EndIf 
               
               If AllTrim(ComparaH) == "955 13"
                  _cHistorico :="EST/ Despesa Infraero - "
               EndIf
                               
            EndIf   
            
            If SW6->(FieldPos("W6_P_REF")) > 0
               cRefProcesso:=SW6->W6_P_REF
            EndIf 
            
            _cHistorico += "IMPORT REF.NF. "+Alltrim(SWN->WN_DOC)+" DI: "+Alltrim(SW6->W6_DI_NUM)
            _cHistorico += " TX DOLAR: "+Alltrim(str(SW6->W6_TX_US_D)) 
            
            If cEmpAnt $ "I7" .Or. cEmpAnt $ "I6"
               _cHistorico +=" REF: "+Alltrim(SW6->W6_HAWB)
            EndIf  
            
                               
            SW9->(DbSetOrder(3)) //W9_FILIAL+W9_HAWB
            If SW9->(DbSeek(xFilial("SW9")+SW6->W6_HAWB)) 
                
               cInv:=""
               While SW9->(!EOF()) .And. SW6->W6_HAWB == SW9->W9_HAWB .And. cInv <> SW9->W9_INVOICE                
                  _cHistorico +=" INVOICE: "+Alltrim(SW9->W9_INVOICE) 
                  cInv:=SW9->W9_INVOICE
               SW9->(DbSkip())
               EndDo 
           
            EndIf                
               
            If !Empty(cRefProcesso) 
               _cHistorico +=" REF:"+cRefProcesso 
            EndIf
                   
         EndIf      
      EndIf       
   EndIf            

ENDIF

Return(_cHistorico)