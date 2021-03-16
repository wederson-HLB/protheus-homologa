#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6107vl2()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CFOP")

_vRetorno:=0

//_CFOP    := "5201/6201/7201/5202/6202/7202/5205/6205/7205/5206/6206/7206/5207/6207/7207/5208/6208/5209/6209/5210/6210/7210/5556" //tes de devolução S/IPI NA BASE
//IF ALLTRIM(SD2->D2_CF) $ _CFOP
  
  IF SD2->D2_TIPO == "D"
   
	 vRetorno := (SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP5 - SD2->D2_VALIMP6 + SD2->D2_VALIPI)
	
	
  ENDIF



RETURN(_vRetorno)


