#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00


/*
Funcao      : P_Pagagen
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA PARA SEPARAR A AGENCIA DO CODIGO DE BARRA CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (99-104)
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

*-------------------------*
 User Function P_Pagagen()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*-------------------------*                           

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_AGENCIA,_RETDIG,_DIG1,_DIG2,_DIG3,_DIG4")
SetPrvt("_MULT,_RESUL,_RESTO,_DIGITO,")

//     PROGRAMA PARA SEPARAR A AGENCIA DO CODIGO DE BARRA 
//     CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (99-104)

_Agencia := "000000"
_cBanco := SUBSTR(SE2->E2_CODBAR,1,3)

Do Case 

   Case _cBanco == "237"	// BRADESCO
       //tratamento c�digo de barras
	   if len(alltrim(SE2->E2_CODBAR))<=44
		  	_Agencia  :=  "0" + SUBSTR(SE2->E2_CODBAR,20,4)
		
			_RETDIG := " "
			_DIG1   := SUBSTR(SE2->E2_CODBAR,20,1)
			_DIG2   := SUBSTR(SE2->E2_CODBAR,21,1)
			_DIG3   := SUBSTR(SE2->E2_CODBAR,22,1)
			_DIG4   := SUBSTR(SE2->E2_CODBAR,23,1)
		
			_MULT   := (VAL(_DIG1)*5) +  (VAL(_DIG2)*4) +  (VAL(_DIG3)*3) +   (VAL(_DIG4)*2)
			_RESUL  := INT(_MULT /11 )
			_RESTO  := INT(_MULT % 11)
			_DIGITO := 11 - _RESTO
		
			_RETDIG := IF( _RESTO == 0,"0",IF(_RESTO == 1,"0",ALLTRIM(STR(_DIGITO))))
	
	      	_Agencia:= _Agencia + _RETDIG
	    //tratamento linha digitavel
		else
		   _Agencia  :=  "0" + SUBSTR(SE2->E2_CODBAR,5,4)
	
	      _RETDIG := " "
	      _DIG1   := SUBSTR(SE2->E2_CODBAR,5,1)
	      _DIG2   := SUBSTR(SE2->E2_CODBAR,6,1)
	      _DIG3   := SUBSTR(SE2->E2_CODBAR,7,1)
	      _DIG4   := SUBSTR(SE2->E2_CODBAR,8,1)
	
	      _MULT   := (VAL(_DIG1)*5) +  (VAL(_DIG2)*4) +  (VAL(_DIG3)*3) +   (VAL(_DIG4)*2)
	      _RESUL  := INT(_MULT /11 )
	      _RESTO  := INT(_MULT % 11)
	      _DIGITO := 11 - _RESTO
	
	      _RETDIG := IF( _RESTO == 0,"0",IF(_RESTO == 1,"0",ALLTRIM(STR(_DIGITO))))
	
	      _Agencia:= _Agencia + _RETDIG		
		
		
		endif
	   

   Otherwise 
   	//Tratamento de digito              
      if At("-",SA2->A2_AGENCIA)>0
	      	_Agencia :=  STRZERO(val(STRTRAN(SA2->A2_AGENCIA,"-")),6)	        		
      else
	      if len(alltrim(SA2->A2_AGENCIA))==5
	      	_Agencia :=  STRZERO(VAL(SA2->A2_AGENCIA),6)	  
		  else
	      	_Agencia :=  STRZERO(VAL(SA2->A2_AGENCIA),5)+" "	  
		  endif
	  endif
Endcase
// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __Return(_Agencia)
Return(_Agencia)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
