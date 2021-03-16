#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp61013CFOP()        // Valor do LP61013

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CFOP")

	_vRetorno:=0

	_CFOP1    := "5949/6949/7949" 
                        
    
//    IIF(Alltrim(SD2->D2_CF)$"5949/6949/7949" ,IIF(SUBSTR(SD2->D2_COD,1,3)$"3RD",SD2->D2_TOTAL-(SD2->D2_TOTAL*0.15),SD2->D2_TOTAL),0)                                                
IF SF2->F2_DOC = SD2->D2_DOC
	
	IF ALLTRIM(SD2->D2_CF) $ _CFOP1 .AND. SF4->F4_ISS == "S"
	   If Substr(ALLTRIM(SD2->D2_CF),1,1) == '7'
	      If SM0->M0_CODIGO $ 'S8/S9' //WDF e WDF Testes
	         If SUBSTR(SD2->D2_COD,1,3)$"3RD"
	            nTaxa1663 := (SD2->D2_TOTAL - SD2->D2_VALACRS)
                n3rd      := ((SD2->D2_TOTAL - SD2->D2_VALACRS) * 0.1304)
                _vRetorno := nTaxa1663 - n3rd
	         Else 
                _vRetorno:= SD2->D2_TOTAL - SD2->D2_VALACRS
	         EndIf
	      Else
	         _vRetorno:=SD2->D2_TOTAL
	      EndIf	
	   EndIf
	ENDIF   
ENDIF

RETURN(_vRetorno)
