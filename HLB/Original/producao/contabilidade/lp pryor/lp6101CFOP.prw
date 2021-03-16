#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6101CFOP()        // Valor do LP61001

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CFOP")

	_vRetorno:=0

	_CFOP    := "5101/6101/5102/6102/5103/6103/5104/6104/5105/6105/5106/6106/5107/6107/5108/6108/5109/6109/5110/6110/5111/6111/5112/5910/"
    _CFOP    += "6112/5113/6113/5114/6114/5115/6115/5116/6116/5117/6117/5118/6118/5119/6119/5120/6120/5122/6122/5123/6123/5124/6124/6922/"
    _CFOP    += "5125/6125/7101/7102/7105/7106/5551/6551/7551/5922/5401/5402/5403/5404/5405/6401/6402/6403/6404/6405/5303/" //RRP - 06/10/2015 - Retirado 6949/7949/5949. Elisabete.
    _CFOP    += "6303/5301/6301/7501" //6911" JSS - 20140723
    //WFA - 25/09/2017 - Inclusão do CFOP 7501.
    
IF SF2->F2_DOC == SD2->D2_DOC
	
	IF ALLTRIM(SD2->D2_CF) $ _CFOP .AND. SD2->D2_TIPO $ "N/C/P/D/B" .AND. SF4->F4_ISS <> 'S' .AND. SF4->F4_DUPLIC $ 'S'
	    
		 _vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_VALFRE+SD2->D2_DESPESA+SD2->D2_ICMSRET  

		                      
	// TLM 20/02/2014 - Adicionado CFOP 6911 - Chamado 016871  - MABRA
	//ELSEIF ALLTRIM(SD2->D2_CF) $ "5116/5117/6116/6117" .AND. SD2->D2_TIPO $ "N/C/P/D/B"  
	ELSEIF ALLTRIM(SD2->D2_CF) $ "5116/5117/6116/6117/5933/6933" .AND. SD2->D2_TIPO $ "N/C/P/D/B" //JSS - ADD para trazer o lp para os cfos 5933 e 6933 chamado:029122
	                                                                   
		_vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_DESPESA+SD2->D2_ICMSRET+SD2->D2_VALFRE 
	   
	// TLM 05/03/2014 - Chamado 017520 - ORANGE
    ELSEIF cEmpAnt $ "LW/LX/LY"
     	//RRP - 15/07/2015 - Retirado o CFOP - 6552. Inclusão da CFOP 7301
     	//RRP - 06/10/2015 - Retirado o CFOP - 6908.
     	If ALLTRIM(SD2->D2_CF) $ _CFOP  .Or. ALLTRIM(SD2->D2_CF) $ "5302/6307/5303/6302/5307/7301"
    		_vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_DESPESA+SD2->D2_ICMSRET+SD2->D2_VALFRE
    	//Notas de Serviços e Notas de Aluguel
    	ElseIf (SF4->F4_ISS == 'S' .AND. ALLTRIM(SD2->D2_CF) $ "6949/7949/5949") .OR. (Alltrim(SD2->D2_SERIE) == 'R')
			_vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_DESPESA+SD2->D2_ICMSRET+SD2->D2_VALFRE
    	EndIf
	
	// RRP 01/03/2017 - Inclusão do grupo Vogel	
	ElseIf cEmpAnt $ u_EmpVogel()
     	If ALLTRIM(SD2->D2_CF) $ _CFOP  .Or. ALLTRIM(SD2->D2_CF) $ "5302/6307/5303/5304/6304/6302/5307/7301"
    		_vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_DESPESA+SD2->D2_ICMSRET+SD2->D2_VALFRE
    	//Notas de Serviços e Notas de Aluguel
    	ElseIf (SF4->F4_ISS == 'S' .AND. ALLTRIM(SD2->D2_CF) $ "6949/7949/5949")
			_vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_DESPESA+SD2->D2_ICMSRET+SD2->D2_VALFRE
    	EndIf	
	
	ENDIF
    
    //AOA - 21/12/2016 - Tratamento para JDSU
	If cEmpAnt $ "41"
		_vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_DESPESA+SD2->D2_ICMSRET+SD2->D2_VALFRE 	//LOS - 16/07/2018 - Tratamento para somar também o ICMS-ST - #39799
	EndIf
	
ENDIF


RETURN(_vRetorno)
