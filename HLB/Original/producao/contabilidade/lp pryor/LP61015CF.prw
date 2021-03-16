#include "rwmake.ch"        // inclui	do pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp61015CF()   // LP 610-15 CREDITO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          

    _CFOP1 := "5101/6101/5102/6102/5103/6103/5104/6104/5105/6105/5106/6106/5107/6107/5108/6108/5109/6109/"
    _CFOP1 += "5110/6110/5111/6111/5112/6112/5113/6113/5114/6114/5115/6115/5116/6116/5117/6117/5118/6118/5303/6303"
    _CFOP1 += "5119/6119/5120/6120/5122/6122/5123/6123/5124/6124/5125/6125/5401/5402/5403/5404/5405/6401/6402/6403/6404/6405"
    
    _CFOP2 := "7101/7102/7105/7106"

    _CFOP3 := "5551/6551/7551"
    
    _CFOP4 := "5922/6922"
    
    _CTES  := "94V/85V/50X/85X"     // CFOP 5949 Vendas de Sucatas


 SetPrvt("_CNTCRED,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CTES")

 
_cntCred:=SPACE(15)
        
If cEmpAnt $ "U6/EG/FF/JN/"
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
    _cntCred := SB1->B1_CONTA 	   	  	 
Else

   IF ALLTRIM(SD2->D2_CF) $ _CFOP1
       _cntCred:="311101001"
       
   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP2
       _cntCred:="311102021"
       
   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP3
       _cntCred:="611150503"
       
   ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP4
       _cntCred:="211410001"
   
   ELSEIF cEmpAnt $ "MN/" .AND. ALLTRIM(SD2->D2_TES) $ _CTES   //JSS 29-11-2012 - criado tratamento especial para empresa mindlab onde todos as vendas de sucatas receberam a conta 611150504 (ref. Caso 008239)
       _cntCred:="611150504" 
       
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
 
RETURN(_cntCred)
                                                                             
