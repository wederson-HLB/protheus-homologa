#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function LP6102ICM()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CNTDEB,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CFOP5,_CFOP6")

//_cntDeb:=SPACE(15)
_cntDeb:=" "
                                  	
_CFOP1 := "5101/6101/5102/6102/5103/6103/5104/6104/5105/6105/5106/6106/5107/6107/5108/6108/5109/6109/5110/"
_CFOP1 += "6110/5111/6111/5112/6112/5113/6113/5114/6114/5115/6115/5116/6116/5117/6117/5118/6118/5119/6119/"
_CFOP1 += "5120/6120/5122/6122/5123/6123/5124/6124/5125/6125/5303/6303"

_CFOP2 := "5910/6910"

_CFOP3 := "5911/6911"

_CFOP4 := "5912/6912/5913/6913/5914/6914/5917/6917/5918/6918/5151/5152/6152"

_CFOP5 := "5922/6922"

_CFOP6 := "5949/6949"

_CFOP7 := "5401/5402/5403/5404/5405/6401/6402/6403/6404/6405"


IF SF2->F2_DOC = SD2->D2_DOC
	IF ALLTRIM(SD2->D2_CF) $ '5106/6106' .AND. cEmpAnt $ "SI"
		_cntDeb:="311105051"
	
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP1
		_cntDeb:="311105051"
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP2 .AND. cEmpAnt <> "SI"
	                   
	    // TLM - 18/09/2012 - Tratamento de brinde Shiseido
	   	If cEmpAnt == "R7"
	   		_cntDeb:="511136365"	
		Else
			_cntDeb:="511136363"
		EndIf           

	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP2 .AND. cEmpAnt == "SI"
		_cntDeb:="311106007"  
	
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP5 .AND. cEmpAnt == "SI"
		_cntDeb:="311106003"
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP3 
	
	   If cEmpAnt $ "EQ"  // Particularidade SALTON 
	      _cntDeb:="211130021"
	   Else    
	      _cntDeb:="511136365"
	   EndIf	
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP4
		_cntDeb:="121110006"   
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP5
		_cntDeb:="211240001"           
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ '6949' .AND. SD2->D2_TES $ '70V' .AND. SM0->M0_CODIGO $ 'FF'//JAM - chamado 001633
		_cntDeb:="121110006"
		
	ELSEIF /*ALLTRIM(SD2->D2_CF) $ _CFOP6 .AND.*/ SD2->D2_TES $ ("50X/60X/95Z/82G") //ASK - 27/07/2010 82G Perstorp 
		_cntDeb:="411112145"

    ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP6   
	    If cEmpAnt $ "FK" .AND. SF4->F4_PODER3 $ 'R'  //remessa thermofisher
		   _cntDeb:="121110006" //"411112143" //121110006"
		
		ElseIf cEmpAnt $ "FF" .AND. SD2->D2_TES $ '89V/86H' //MSM - chamado 002389 
		   _cntDeb:="511145454"	

		ElseIf cEmpAnt $ "IL"  // JSS - 20140724 
		   _cntDeb:="121110006"	
	
		ElseIf cEmpAnt $ "JM" .AND. SD2->D2_TES $ '5DG'  // JSS - 20140724 
		   _cntDeb:="311105051"	
		
		ElseIf cEmpAnt $ "JM" .AND. SD2->D2_TES $ '54H'  // JSS - 20140724 
		   _cntDeb:="511136363"

		ElseIf cEmpAnt $ "SI" //ECR - 15/08/2012 - Tratamento para Sirona
  			If AllTrim(SD2->D2_TES) $ '5E7|5F0|5T1'	
     			_cntDeb:="311106003"//ICMS sobre garantia 
	        EndIf
	        
		ElseIf cEmpAnt $ "MN" //JSS - 19/10/2012 - Tratamento para MindLab chamado: 007608
  			If AllTrim(SD2->D2_TES) $ '5BR'	
     			_cntDeb:="511140405" 
			ElseIf AllTrim(SD2->D2_TES) $ '5EL'	
     			_cntDeb:="511140406" 
			Else  
		   		_cntDeb:="411112143"  
		   	EndIf	
		EndIf
    ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP7
		_cntDeb:="311105051"
		
	EndIf

EndIf

RETURN(_cntDeb)
