#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

/*
Funcao      : P_Pagacta
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA PARA SEPARAR A C/C DO CODIGO DE BARRA e CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (105-119)
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

*------------------------*
User Function P_Pagacta()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*------------------------*                         

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_CTACED,_RETDIG,_DIG1,_DIG2,_DIG3,_DIG4,_NPOSDV")
SetPrvt("_DIG5,_DIG6,_DIG7,_MULT,_RESUL,_RESTO")
SetPrvt("_DIGITO,")

/////  PROGRAMA PARA SEPARAR A C/C DO CODIGO DE BARRA 
/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (105-119)

_CtaCed := "000000000000000"
_cBanco := SUBSTR(SE2->E2_CODBAR,1,3)
Do Case
   Case _cBanco == "237"	// BRADESCO
		if len(alltrim(SE2->E2_CODBAR))<=44
		    _CtaCed  :=  STRZERO(VAL(SUBSTR(SE2->E2_CODBAR,37,7)),13,0)
		    
		    _RETDIG := " "
		    _DIG1   := SUBSTR(SE2->E2_CODBAR,37,1)
		    _DIG2   := SUBSTR(SE2->E2_CODBAR,38,1)
		    _DIG3   := SUBSTR(SE2->E2_CODBAR,39,1)
		    _DIG4   := SUBSTR(SE2->E2_CODBAR,40,1)
		    _DIG5   := SUBSTR(SE2->E2_CODBAR,41,1)
		    _DIG6   := SUBSTR(SE2->E2_CODBAR,42,1)
		    _DIG7   := SUBSTR(SE2->E2_CODBAR,43,1)
		    
		    _MULT   := (VAL(_DIG1)*2) +  (VAL(_DIG2)*7) +  (VAL(_DIG3)*6) +   (VAL(_DIG4)*5) +  (VAL(_DIG5)*4) +  (VAL(_DIG6)*3)  + (VAL(_DIG7)*2)
		    _RESUL  := INT(_MULT /11 )
		    _RESTO  := INT(_MULT % 11)
		    _DIGITO := STRZERO((11 - _RESTO),1)
		
		    _RETDIG := IF( _resto == 0,"0",IF(_resto == 1,"P",_DIGITO))
		
		    _CtaCed := _CtaCed + _RETDIG
		else
			_CtaCed  :=  STRZERO(VAL(SUBSTR(SE2->E2_CODBAR,24,7)),13,0)
		    
		    _RETDIG := " "
		    _DIG1   := SUBSTR(SE2->E2_CODBAR,24,1)
		    _DIG2   := SUBSTR(SE2->E2_CODBAR,25,1)
		    _DIG3   := SUBSTR(SE2->E2_CODBAR,26,1)
		    _DIG4   := SUBSTR(SE2->E2_CODBAR,27,1)
		    _DIG5   := SUBSTR(SE2->E2_CODBAR,28,1)
		    _DIG6   := SUBSTR(SE2->E2_CODBAR,29,1)
		    _DIG7   := SUBSTR(SE2->E2_CODBAR,30,1)
		    
		    _MULT   := (VAL(_DIG1)*2) +  (VAL(_DIG2)*7) +  (VAL(_DIG3)*6) +   (VAL(_DIG4)*5) +  (VAL(_DIG5)*4) +  (VAL(_DIG6)*3)  + (VAL(_DIG7)*2)
		    _RESUL  := INT(_MULT /11 )
		    _RESTO  := INT(_MULT % 11)
		    _DIGITO := STRZERO((11 - _RESTO),1)
		
		    _RETDIG := IIF( _resto == 0,"0",IIF(_resto == 1,"P",_DIGITO))
		
		    _CtaCed := _CtaCed + _RETDIG
		
		endif   
OTHERWISE
	if cEmpAnt $ "MN"
		_CtaCed := SUBSTR(SA2->A2_NUMCON,1,13)
		_CtaCed := REPL("0",13-LEN(alltrim(_CtaCed)))+alltrim(_CtaCed)
		_CtaCed := _CtaCed+SUBSTR(SA2->A2_DVCTA,1,2)
	else
		_nPosDV := AT("-",SA2->A2_NUMCON)
		IF _nPosDV == 0
			 _CtaCed := REPL("0",15-LEN(LTRIM(RTRIM(SA2->A2_NUMCON))))+LTRIM(RTRIM(SA2->A2_NUMCON))
		ELSE
			_CtaCed := SUBSTR(SA2->A2_NUMCON,1,_nPosDV-1)
			_CtaCed := REPL("0",13-LEN(_CtaCed))+_CtaCed
			_CtaCed := _CtaCed+SUBSTR(SA2->A2_NUMCON,_nPosDV+1,2)
		ENDIF	
	endif
ENDCASE

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_Ctaced)
Return(_CtaCed)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00