#include "rwmake.ch"       

User Function lp6401val()  
_nRetorno:=0 
lEasy     := SuperGetMV("MV_EASY") == "S"

_cTes1   := "01E/02E/03E/04E/05E/06E/07E/08E/09E/"
_cTes1   += "10E/11E/12E/13E/"
_cTes1   += "24E/25E/26E/27E/28E/29E/"
_cTes1   += "30E/36E/"
_cTes1   += "07M/08M/"
_cTes1   += "07J/08J/08L"

//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   If SD1->D1_TES$(_cTes1)
	  _nRetorno:=(SD1->D1_TOTAL+SD1->D1_VALIPI-SD1->D1_VALFRE)
   EndIf
   
Endif

Return(_nRetorno)


