#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function LP610_02()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
Local cCfopBt := ""

SetPrvt("_CNTDEB,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CFOP5,_CFOP6")

//_cntDeb:=SPACE(15)
_cntDeb:=" "
                                  	
_CFOP1 := "5101/6101/5102/6102/5103/6103/5104/6104/5105/6105/5106/6106/5107/6107/5108/6108/5109/6109/5110/"
_CFOP1 += "6110/5111/6111/5112/6112/5113/6113/5114/6114/5115/6115/5116/6116/5117/6117/5118/6118/5119/6119/"
_CFOP1 += "5120/6120/5122/6122/5123/6123/5124/6124/5125/6125/5303/6303"

_CFOP2 := "5910/6910"

_CFOP3 := "5911/6911"

_CFOP4 := "5912/6912/5916/6916/5913/6913/5914/6914/5917/6917/5918/6918/5151/5152"

_CFOP5 := "5922/6922"

_CFOP6 := "5949/6949"

_CFOP7 := "5401/5402/5403/5404/5405/6401/6402/6403/6404/6405"

_CFOP8  := "6301"

cCfopBt	:= "5409/5152"

IF SF2->F2_DOC = SD2->D2_DOC
	IF ALLTRIM(SD2->D2_CF) $ _CFOP1
		_cntDeb:="31213002"
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP2
		//RSB - 09/11/2017 - Altera豫o Exeltis para incluir LG
		If cEmpAnt $ "LG"
			_cntDeb:="31213007"
		//HMO - 03/08/2018 - Alteracao de conta para Doterra - Ticket 41512
		ElseIf cEmpAnt $ "N6"
			_cntDeb:="41114005" // LSL - EZ4 - 12/03/2019 - ALTERADO A CONTA DOTERRA - TICKET 5604
		Else
			_cntDeb:="51711009"
		Endif
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP3 
	
	   If cEmpAnt $ "EQ"  // Particularidade SALTON 
	      _cntDeb:="211130021"
	   Else    
	      _cntDeb:="51711012"
	   EndIf	
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP4   
	
	   If cEmpAnt $ "PF"  // Particularidade DUCATI /FUJIFILM SONOSI 
	      _cntDeb:="11320021"
	   Else    
	      _cntDeb:="51411005"
	   EndIf 
   	   If cEmpAnt $ "KQ"  // JSS - Adicionado este tratamento para solucionar o chamado  022772
	      _cntDeb:="11320021"
	   EndIf
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP5
		_cntDeb:="11320008" 
		
	ELSEIF /*ALLTRIM(SD2->D2_CF) $ _CFOP6 .AND.*/ SD2->D2_TES $ ("50X/60X/95Z/82G") //ASK - 27/07/2010 82G Perstorp 
		_cntDeb:="41114003"

    ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP6   
	    If cEmpAnt $ "FK" .AND. SF4->F4_PODER3 $ 'R' //remessa thermofisher
		   _cntDeb:="51411005" //"411112143" //121110006"
		ElseIf cEmpAnt $ "UY"  //JSS - Adicionado este tratamento para solucionar o chamado 017807
		   _cntDeb:="51411006"  
   		ElseIf cEmpAnt $ "JO"  //JSS - 20140724 SOLICITA플O ALINE ESTOQUE.
   		   _cntDeb:="51711009"
   		ElseIf cEmpAnt $ "QU"   //JSS - 20150513 - Alterado para solucionar o caso 026165 //JSS - 22/04/2015 Ajustado para solucionar o caso 025089.
   		   _cntDeb:="51411006"   		   
		Else  
		   _cntDeb:="411112143" 
		EndIf
    ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP7 .OR. cEmpAnt == "T0" 
		_cntDeb:="31213002"
	
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP8 
		_cntDeb:="31214004"
	EndIf
	
	//RRP - 15/12/2014 - Tratamento especial Bottega. Transfer?cia entre lojas. Chamado 023169.
	If cEmpAnt == "46" .AND. Alltrim(SD2->D2_CF) $ cCfopBt
		If SD2->D2_FILIAL == "01"
			_cntDeb:="11320021"
		Else
			_cntDeb:="11320023"
		EndIf
	EndIf
	
EndIf

RETURN(_cntDeb)
