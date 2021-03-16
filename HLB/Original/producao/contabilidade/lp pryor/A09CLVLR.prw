#include "rwmake.ch"


*-------------------------*
 User Function A09CLVLR()
*-------------------------* 

Local cRet:=""

If SubStr(SRZ->RZ_CC,1,1) == "1" 
	cRet:="01"
ElseIf  SubStr(SRZ->RZ_CC,1,1) == "2" 
	cRet:="02"                                                                                                                                                                                           
ElseIf SubStr(SRZ->RZ_CC,1,1) == "3" 
	cRet:="03"
EndIf

Return cRet           