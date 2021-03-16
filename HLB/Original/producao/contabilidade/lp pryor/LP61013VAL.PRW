User Function LP61013VAL()

Local cSeq		:= ""
Local cLp		:= "" 
Local cConta	:= ""

//Array que recebe os parâmetros informados no Lançamento Padrão.
If ValType(PARAMIXB) == "A" 
	cSeq	:= PARAMIXB[2]
	cLp		:= PARAMIXB[1]
EndIf

_CCUSTO		 := " " 
_cTes1		 := "78V/75T/76T/77T/78T/79T/66V/69V/63V" 
_cTes2		 := "1H0"
_cTes3		 := "56M/5OQ/132"  // TES Usadas para Lojas - 132 para teste

lEasy     := SuperGetMV("MV_EASY") == "S"

//If !lEasy  
If EMPTY(SD1->D1_CONHEC)
	
	If cEmpAnt $ "A6" 
		If (SD1->D1_TES $ _cTes2)
	        _CCUSTO := ""
	     Else
	        _CCUSTO := SD1->D1_CC
	     EndIf
	EndIf
	   
  	If cEmpAnt $ "VJ"
  		
  		//RRP - 14/08/2013 - Tratamento conforme chamado 013385
  		If cLp == "610"
	   		Do Case
	    		Case cSeq == "02"
	    			cConta := U_LP6102ICM()
	    		Case cSeq == "04"
	    			cConta := U_LP6102IPI()
	    		Case cSeq == "15" 
	    			cConta := U_lp61015CF()	    		
	    		Case cSeq == "16"
					cConta := U_lp61016()	    		
	    	EndCase
	    	                               
    		If (cFilAnt) $ "01/10"     
    			//TLM 17/02/2014  - Tratamento de centro de custo - Chamado 017144
    	   		If SubStr(Alltrim(cConta), 1, 1) $ "3/5" .And. cFilAnt $ "10" 
     	   			_CCUSTO := "BE 6000"	   	   		
    	   		Else
         			_CCUSTO := "SB 6000"	   		
    	   		EndIf
    	   	Else
      			DbSelectArea("SC5")
      			SC5->(DbSetOrder(1))//C5_FILIAL, C5_NUM
      			If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
         			_CCUSTO := Alltrim(SC5->C5_CCUSTO)
         		EndIf		 
    	   	EndIf
 	    	
  		Else
  			If (SD2->D2_TES $ _cTes1)
	    		_CCUSTO := "6000"     
	  	    EndIf   
	  	          
	  	    //TLM 27/06/2012  - Tratamento de centro de custo para as lojas
	  	    If (SD2->D2_TES $ _cTes3)
	    		_CCUSTO := "8300" 
	  	    EndIf 
	  	    
	  	    If (alltrim(SD2->D2_CF) == "5557")
	     		_CCUSTO := "8000"  	    
	  	    EndIf
		EndIf    
  	    
  	   
  	EndIf       
  	//JSS - 20140724 ALTERAÇ~SO SOLICITADA PELA ALINE ESTOQUE
  	If cEmpAnt $ "R7"
  		
  		//RRP - 14/08/2013 - Tratamento conforme chamado 013385
  		If cLp == "610"
	   		Do Case
	    		Case cSeq == "02"
	    			cConta := U_LP6102ICM()
	    		Case cSeq == "04"
	    			cConta := U_LP6102IPI()
	    		Case cSeq == "15" 
	    			cConta := SB1->B1_CC	    		
	    		Case cSeq == "16"
					cConta := SB1->B1_CC	    		
	    	EndCase
	    	                               
    		If (cFilAnt) $ "01/10"     
    			//TLM 17/02/2014  - Tratamento de centro de custo - Chamado 017144
    	   		If SubStr(Alltrim(cConta), 1, 1) $ "3/5" .And. cFilAnt $ "10" 
     	   			_CCUSTO := "BE 6000"	   	   		
    	   		Else
         			_CCUSTO := "SB 6000"	   		
    	   		EndIf
    	   	Else
      			DbSelectArea("SC5")
      			SC5->(DbSetOrder(1))//C5_FILIAL, C5_NUM
      			If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
         			_CCUSTO := Alltrim(SC5->C5_CCUSTO)
         		EndIf		 
    	   	EndIf
 	    	
  		Else
  			If (SD2->D2_TES $ _cTes1)
	    		_CCUSTO := "6000"     
	  	    EndIf   
	  	          
	  	    //TLM 27/06/2012  - Tratamento de centro de custo para as lojas
	  	    If (SD2->D2_TES $ _cTes3)
	    		_CCUSTO := "8300" 
	  	    EndIf 
	  	    
	  	    If (alltrim(SD2->D2_CF) == "5557")
	     		_CCUSTO := "8000"  	    
	  	    EndIf
		EndIf    
  	    
  	   
  	EndIf
   
  	If cEmpAnt $ "Z4" // TLM 10/10/2011 - Chamado 000701
  	
  		If SM0->M0_CODFIL='01'
  			_CCUSTO:="3201"
    	Elseif SM0->M0_CODFIL='02'
  			_CCUSTO:="3181"
   		Elseif SM0->M0_CODFIL='03'
  			_CCUSTO:="3240"
  		Elseif SM0->M0_CODFIL='05'
  			_CCUSTO:="1100"
   		Elseif SM0->M0_CODFIL='06' 
    		_CCUSTO:="3180"
   		EndIf

 	EndIf 
 
  	If cEmpAnt $ "Z8" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:="8100"
  	EndIf
  	
  	If cEmpAnt $ "JO" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:= SA1->A1_P_CC
  	EndIf
  	  
  	If cEmpAnt $ "EF" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:="1000"
  	EndIf
  	
  	If cEmpAnt $ "CH" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:="3601"
  	EndIf
  	
  	If cEmpAnt $ "ZP" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:="9100"
  	EndIf
  	
  	If cEmpAnt $ "RH" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:="1100"
  	EndIf
  	
   	//IF cEmpAnt $ "Z4/ZP/Z6/Z8/CH/RH/ZB/ZG"         /// EMPRESAS DO GRUPO PRYOR  // TLM 10/10/2011 - Chamado 000701
   	IF cEmpAnt $ "Z6/ZB/ZG"         /// EMPRESAS DO GRUPO PRYOR
      IF !ALLTRIM(SF2->F2_SERIE) == "ND"
	     _CCUSTO:=SA1->A1_CC_CUST  
	  ENDIF	

    ELSEIF cEmpAnt $ "S8/LN/ZB/SI" //RRP - 22/10/2012 - Chamado 007758 - Inclusão da Sirona
	   _CCUSTO:=SB1->B1_CC
	
	//RRP - 16/08/2013 - Alteração feita devida a solicitação do cliente.
	ElseIf cEmpAnt $ "FF"
	    If cLp == "610"
		    Do Case
		    
		    	Case cSeq == "01"
		    		If !(SubStr(Alltrim(SA1->A1_CONTA), 1, 1)) $ "1/2" .AND. !(SD2->D2_CF) $ '5116/6116/5117/6117'
		    			_CCUSTO:=SB1->B1_CC
		    		EndIf	
		    	
		    	Case cSeq == "15"
		    		cConta := U_lp61015CF()
		    		If !(SubStr(Alltrim(cConta), 1, 1)) $ "1/2"
		    			_CCUSTO:=SB1->B1_CC	
		    		EndIf
		    	
		    EndCase
	    Else
	    	_CCUSTO:=SB1->B1_CC
	    EndIf

    ELSEIF cEmpAnt $ "DJ"        // WFI  
       SC6->(DbSetOrder(1))
	   SC6->(DbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	   _CCUSTO :=SC6->C6_P_CC

    ELSEIF cEmpAnt $ "DT"
	   _CCUSTO :=SA3->A3_P_CCUST     //DUN
    ENDIF 

    If cEmpAnt $ "CD/EQ" //salton        
       _CCUSTO := '11200'
    EndIf
         
    If cEmpAnt $ "HO"   //ALPUNTO 
  
      SB1->(DbSetOrder(1))

      If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
         _CCUSTO:=Alltrim(SB1->B1_CC)
      EndIf

    EndIf
   
   // EBF - 02/07/2013 - Chamado 013238
   If cEmpAnt $ "FV"   //FIVETEN 
  
      SB1->(DbSetOrder(1))

      If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
         _CCUSTO:=Alltrim(SB1->B1_CC)
      EndIf

   EndIf   

   If cEmpAnt $ "F2" //Creata        
      DbSelectArea("SC6")
      SC6->(DbSetOrder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
      If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
         _CCUSTO := Alltrim(SC6->C6_P_CC)
      Else
         _CCUSTO := ""
      EndIf
   EndIf

   //MSM - 08/05/2012 - Inclusão de regra para centro de custo, dependendo do grupo.
   if cEmpAnt $ "ZF" //Corporate
   		DbSelectArea("SBM")
   		SBM->(DbSetOrder(1))
   		SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
   		
   		if alltrim(SBM->BM_TIPGRU)=="11"
   			_CCUSTO:="7201"	
   		elseif alltrim(SBM->BM_TIPGRU)=="12"
   			_CCUSTO:="7202"
   		endif
   endif
   
   //RSB - 30/08/2017 - Inclusão de regra para centro de custo, dependendo do D2_CODISS.
   If cEmpAnt $ "4Z" .and. !Empty(SD2->D2_CODISS) //IS INFORMATICA
  		If ALLTRIM(SD2->D2_CODISS) $ '05762/02917/02919'	//CAS - 02/04/2018 - Ajuste para a empresa Viavi, D2_CODISS=2919. Ticket #30432
   			_CCUSTO:="44010"	
   		Elseif ALLTRIM(SD2->D2_CODISS) $ '02879/02881' 		//CAS - 02/04/2018 - Ajuste para a empresa Viavi, D2_CODISS=2881. Ticket #30432	
   			_CCUSTO:="46000"
   		Elseif ALLTRIM(SD2->D2_CODISS) $ '02798/02800'   	//CAS - 02/04/2018 - Ajuste para a empresa Viavi, D2_CODISS=2800. Ticket #30432
   			_CCUSTO:="41010"
   		Endif
   Endif
   
EndIf

Return(_CCUSTO)        