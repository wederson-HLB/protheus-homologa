#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function 6504VCFO()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VALRESULT")       


_valResult:=0
                                                                     
lEasy     := SuperGetMV("MV_EASY") == "S"

//IF !lEasy
If EMPTY(SD1->D1_CONHEC)
   IF (Alltrim(SD1->D1_CF)$ '1911/2911/1353/2353' .And. SF4->F4_LFIPI <> 'T') .OR.  SD1->D1_TIPO $ "D/"  
  		_valResult:=0
   ELSE
        //Tratamento da empresa Media - chamado 9908 
   		If cEmpAnt $  "UY/JO/K1/50/HL/O5/OD/WA/BJ/9J/8Z/G2/N5/28/BI/MM/7N/S2/VW/XC/10/OU/EI/FG/H9/RY/NN/K2/BT/9X/IN/GN/4Z/SS/M1/RF/RT/ZJ/MR/ZR/MA/MB/S1/JV/40/ED/QU/7I/LB/JP/R7/DW/AT/26/SC/S6/2E/6Q/XR/7M/6T/TP/D8/7G/41/TM/UZ/HH/HJ/M7/QN/0F"		//CAS - 04/06/2019 - TAXID(N? contabilizar IPI, n? tomar?cr?ito)
			If SF4->F4_CREDIPI <> "N"
		   		_valResult:=(SD1->D1_VALIPI) 
		   	Else
		   		_valResult:=0
		   	EndIf	
		   		
		Else	
			_valResult:=(SD1->D1_VALIPI)
   		EndIf
   ENDIF

EndIf

RETURN(_valResult)
                                                                                           