User Function LP61013VAL()                

_CCUSTO := " " 
_cTes1  := "78V/75T/76T/77T/78T/79T/66V/69V/63V" 
_cTes2  := "1H0"
_cTes3  := "56M/5OQ/132"  // TES Usadas para Lojas - 132 para teste

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
	   
  	If cEmpAnt $ "R7/VJ" 
  		
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
   
  	If cEmpAnt $ "Z4" // TLM 10/10/2011 - Chamado 000701
  	
 		If SM0->M0_CODFIL='01'
 		//RPB - 31/08/2016 - Inclusão de regra para centro de custo, dependendo do grupo.
  		//	_CCUSTO:="3201"
  		   IF !Alltrim(SB1->B1_COD) $ '300007/300010/300041/300099/400007/400041'
        	    _CCUSTO := Alltrim(SB1->B1_CC)
            ELSE
         		_CCUSTO := Alltrim(SA1->A1_CC_CUSTO)
 		   ENDIF 	
        /*
      	Elseif SM0->M0_CODFIL='02'
  			_CCUSTO:="3181" 
  		*/ 
   		Elseif SM0->M0_CODFIL='03'  						//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503
   			SB1->(DbSetOrder(1))
       		If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
           		_CCUSTO:=Alltrim(SB1->B1_CC)
       		EndIf
  		Elseif SM0->M0_CODFIL='04'
  			_CCUSTO:= '3195'      
  		Elseif SM0->M0_CODFIL='05'
  			_CCUSTO:= alltrim(SA1->A1_CC_CUSTO)
   		Elseif SM0->M0_CODFIL='06'      					//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503
   			SB1->(DbSetOrder(1))
       		If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
           		_CCUSTO:=Alltrim(SB1->B1_CC)
       		EndIf   		
    	Elseif SM0->M0_CODFIL='08' 							//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503
   			SB1->(DbSetOrder(1))
       		If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
           		_CCUSTO:=Alltrim(SB1->B1_CC)
       		EndIf   		
   		EndIf  		
  		
 	EndIf

   
  	If cEmpAnt $ "ZB" // TLM - 18/02/2014 - Chamado 016883
  	
  		If SM0->M0_CODFIL='01'
  			_CCUSTO:=SA1->A1_CC_CUST
    	Elseif SM0->M0_CODFIL='02'
  			_CCUSTO:="7103"
   		Elseif SM0->M0_CODFIL='03'
  			_CCUSTO:="7104"  
  		Elseif SM0->M0_CODFIL='04'
  			_CCUSTO:="7106"
  		Elseif SM0->M0_CODFIL='05'  
  			_CCUSTO:="7102"     
   		Elseif SM0->M0_CODFIL='06' 
    		_CCUSTO:="7105"
   		EndIf

 	EndIf


 	
 	If cEmpAnt $ "4C" // RRP - 15/05/2013 - Chamado 012163 
 		_ccusto:="4101"
 	EndIf
 	
 	If cEmpAnt $ "4K" 										//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503 
   		SB1->(DbSetOrder(1))
      	If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
        	_CCUSTO:=Alltrim(SB1->B1_CC)
        EndIf
 	EndIf 
 
  	If cEmpAnt $ "Z8" // TLM 10/10/2011 - Chamado 000701
  		_CCUSTO:="8100"
  	EndIf  
  	
  	If cEmpAnt $ "CH" 									 	//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503 
   		SB1->(DbSetOrder(1))
      	If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
        	_CCUSTO:=Alltrim(SB1->B1_CC)
        EndIf
  	EndIf
  	
  	If cEmpAnt $ "ZP" 									 	//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503  	
   		SB1->(DbSetOrder(1))
      	If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
        	_CCUSTO:=Alltrim(SB1->B1_CC)
        EndIf
  	EndIf   
  	
 	If cEmpAnt $ "RH" 										//CAS - 15/03/2018 - Alterado Centro de custo para pegar do cadastro do produto. Ticket 21503  	
   		SB1->(DbSetOrder(1))
      	If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
        	_CCUSTO:=Alltrim(SB1->B1_CC)
        EndIf
  	EndIf  	

// RRP - 15/05/2013 - Chamado 012163 - O Tratamento esta no CT5_CCC.  	
// 	If cEmpAnt $ "RH" // TLM 10/10/2011 - Chamado 000701
// 		_CCUSTO:="1100"
// 	EndIf
  	
   	//IF cEmpAnt $ "Z4/ZP/Z6/Z8/CH/RH/ZB/ZG"         /// EMPRESAS DO GRUPO PRYOR  // TLM 10/10/2011 - Chamado 000701
   	IF cEmpAnt $ "Z6/ZG"         /// EMPRESAS DO GRUPO PRYOR
      IF !ALLTRIM(SF2->F2_SERIE) == "ND"
	     _CCUSTO:=SA1->A1_CC_CUST  
	   ENDIF	

    ELSEIF cEmpAnt $ "FF/S8/LN/SI" //RRP - 22/10/2012 - Chamado 007758 - Inclusão da Sirona
	   _CCUSTO:=SB1->B1_CC

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

   If cEmpAnt $ "F2/F0" //Creata        
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
EndIf

Return(_CCUSTO)        