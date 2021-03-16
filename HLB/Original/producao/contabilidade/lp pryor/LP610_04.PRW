#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function LP610_04()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_CNTDEB,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CFOP5,_CFOP6")

//_cntDeb:=SPACE(15)
_cntDeb:=""

_CFOP1 := "5101/6101/5102/6102/5103/6103/5104/6104/5105/6105/5106/6106/5107/6107/5108/6108/5109/6109/5110/"
_CFOP1 += "6110/5111/6111/5112/6112/5113/6113/5114/6114/5115/6115/5116/6116/5117/6117/5118/6118/5119/6119/"
_CFOP1 += "5120/6120/5122/6122/5123/6123/5124/6124/5125/6125/5401/5402/5403/5404/5405/6401/6402/6403/6404/6405"

_CFOP2 := "5910/6910"

_CFOP3 := "5911/6911"

_CFOP4 := "5912/6912/5913/6913/5914/6914/5917/6917/5918/6918/5151/5152"

_CFOP5 := "5922/6922"

_CFOP6 := "5949"


IF SF2->F2_DOC = SD2->D2_DOC
	IF ALLTRIM(SD2->D2_CF) $ _CFOP1
		// HMO - 05/09/2018 - Retirada de IF do cliente doTerra
		// HMO - 24/08/2018 Antigo: _cntDeb:="51711009" Conforme informacao da equipe contabil a conta correta para os CFOP's contidos em _CFOP1 sao contas do grupo 3. 
		_cntDeb:="31213001"
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP2
	    // HMO - 24/08/2018 - Ticket 43718
		IF cEmpAnt $ "N6"
			_cntDeb:="41114003"
		ELSE
			_cntDeb:="51711009" 
		ENDIF
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP3
		_cntDeb:="51711012"
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP4
		_cntDeb:="51411005"

	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP5 .AND. cEmpAnt $ "G9" //CAS - 20170117 - Adicionado para solucionar o caso 038573
		_cntDeb:="31213001" 
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP5
		_cntDeb:="11320008" 
	
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP6 .AND. cEmpAnt $ "JO"
		_cntDeb:="51711009"   
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP6 .AND. cEmpAnt $ "QU"  //JSS - 20150513 - Alterado para solucionar o caso 026165
		_cntDeb:="51411012"		
		
	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP6 .AND. SD2->D2_TES $ ("50X/60X/95Z")
		_cntDeb:="41114003"
		  
    ELSEIF 	ALLTRIM(SD2->D2_CF) $ _CFOP6 .AND. SD2->D2_TES $ ("71G") //ASK - Salton			
		_cntDeb:="211130009"
		  		
	EndIf
	
EndIf

RETURN(_cntDeb)
