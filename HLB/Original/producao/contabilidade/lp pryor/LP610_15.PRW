#include "rwmake.ch"       

User Function LP610_15()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
          

    _CFOP1 := "5101/6101/5102/6102/5103/6103/5104/6104/5105/6105/5106/6106/5107/6107/5108/6108/5109/6109/"
    _CFOP1 += "5110/6110/5111/6111/5112/6112/5113/6113/5114/6114/5115/6115/5116/6116/5117/6117/5118/6118/5303/6303/"
    _CFOP1 += "5119/6119/5120/6120/5122/6122/5123/6123/5124/6124/5125/6125/5401/5402/5403/5404/5405/6401/6402/6403/6404/6405"
    
    _CFOP2 := "7101/7102/7105/7106"

    _CFOP3 := "5551/6551/7551"
    
    _CFOP4 := "5922/6922" 
       
    _CFOP5 := "5301/6301"
    
    _CFOP5 := "5949/6949/7949" 
        
    _CTES  := "94V/85V/50X/85X"     // CFOP 5949 Vendas de Sucatas


 SetPrvt("_CNTCRED,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CFOP5,_CTES")

 
_cntCred:=SPACE(15)

If cEmpAnt $ "U6/EG/FF/JN/"
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
    _cntCred := SB1->B1_CONTA 	   	  	 
Else

   IF ALLTRIM(SD2->D2_CF) $ _CFOP1  .AND. cEmpAnt $ "JG" 	//CAS - 20170620 - Adicionado para solucionar o caso 041936 -Nova Conta: 31112001
       _cntCred:="31112001"

   ElseIF ALLTRIM(SD2->D2_CF) $ _CFOP1
       _cntCred:="31111001"
       
   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP2
       _cntCred:="31111002"
       
   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP3
       If cEmpAnt $ "K1"
       	_cntCred:="53112003"
       Else 
       	_cntCred:="53112001"        	
       Endif	
   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP4  .AND. cEmpAnt $ "G9" //CAS - 20170117 - Adicionado para solucionar o caso 038573
       _cntCred:="21114001"

   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP4
       _cntCred:="211410001"
       
   ELSEIF ALLTRIM(SD2->D2_TES) $ _CTES
       _cntCred:="611150506" 
   Endif        
   
EndIf

IF SM0->M0_CODIGO = '68' .and. alltrim(SD2->D2_CLIENTE) = '20570'  
   _cntCred:= "311101002" 
EndIf
  	  	 
IF SM0->M0_CODIGO = 'EF' .and. ALLTRIM(SD2->D2_CF) = '5106/6106'
   _cntCred:= "311101002" 
EndIf
  	  	 
IF SM0->M0_CODIGO $ 'MV/GV/S8/' .AND. ALLTRIM(SD2->D2_CF) $ _CFOP1
   _cntCred:= SB1->B1_CONTA 
EndIf    

IF SM0->M0_CODIGO $ 'UY' .AND. ALLTRIM(SD2->D2_CF) $ _CFOP5
   _cntCred:= "31113004" 
EndIf    

//RSB - 09/11/2017 - Altera豫o Exeltis para incluir LG
IF SM0->M0_CODIGO $ 'SU/LG' .AND. ALLTRIM(SD2->D2_CF) $ _CFOP1
   _cntCred:="31112001"
EndIf  

//AOA - 15/12/2016 - Tratamento de contas conforme chamado 037746 
IF SM0->M0_CODIGO $ '41' .AND. ALLTRIM(SD2->D2_CF) $ _CFOP1
   _cntCred:="31101001"
ElseIf ALLTRIM(SD2->D2_CF) $ _CFOP5
   _cntCred:="35101001"
EndIf  

//RSB - 30/08/2017 - Inclus? de regra para centro de custo, dependendo do Codigo do ISS (D2_CODISS).
If SM0->M0_CODIGO $ '4Z' 
	If !Empty(SD2->D2_CODISS)
		If ALLTRIM(SD2->D2_CODISS) $ '05762'
			_cntCred:="311130011"
	   	Elseif ALLTRIM(SD2->D2_CODISS) $ '02917/02919'	//CAS - 02/04/2018 - Ajuste para a empresa Viavi, D2_CODISS=2919. Ticket #30432
	   		_cntCred:="311130012"
		Elseif ALLTRIM(SD2->D2_CODISS) $ '02879/02881'	//CAS - 02/04/2018 - Ajuste para a empresa Viavi, D2_CODISS=2881. Ticket #30432
			_cntCred:="311130013"
		Elseif ALLTRIM(SD2->D2_CODISS) $ '02798/02800'	//CAS - 02/04/2018 - Ajuste para a empresa Viavi, D2_CODISS=2800. Ticket #30432
			_cntCred:="311130014"
		Elseif ALLTRIM(SD2->D2_CODISS) $ '02692'    	//Paulo Silva - EZ4 - 15/04/2020 - IS INFORMATICA - CHAMADO - 22070
			_cntCred:="311130010"
		Endif	
	Else
		_cntCred:="311130011"
	Endif	
Endif

 
RETURN(_cntCred)
                                                                             
                                                                             
