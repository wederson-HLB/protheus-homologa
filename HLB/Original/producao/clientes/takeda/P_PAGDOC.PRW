#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

/*
Funcao      : P_Pagdoc
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA GRAVAR AS INFORMACOES COMPLEMENTARES CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (374-413)
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 
 
*-------------------------*
 User Function P_Pagdoc()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*-------------------------* 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_Doc,_Mod,")

/////  PROGRAMA GRAVAR AS INFORMACOES COMPLEMENTARES
/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (374-413)


if cEmpAnt $ "MN"
	_Mod := SUBSTR(SEA->EA_MODELO,1,2)
else
	_Mod := SUBSTR(SE2->E2_P_TPPAG,1,2)
endif

IF _Mod == "  "
   IF SUBSTR(SE2->E2_CODBAR,1,3) == "237"
      _Mod == "30"
   ELSE
      _Mod == "31"
   ENDIF
ENDIF

DO CASE
   CASE _Mod == "03" .OR. _Mod == "07" .OR. _Mod == "08"
        _Doc := IIF(SA2->A2_CGC==SM0->M0_CGC,"D","C")+"000000"+"01"+"01"+SPACE(29)
   CASE _Mod == "31"
        
       /* if(len(alltrim(SE2->E2_CODBAR))==48)//tratamento do codigo de barras outros bancos.
        	_Doc :=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)+SUBSTR(SE2->E2_CODBAR,33,1)+SUBSTR(SE2->E2_CODBAR,4,1)
        else
        	_Doc := SUBSTR(SE2->E2_CODBAR,20,25)+SUBSTR(SE2->E2_CODBAR,5,1)+SUBSTR(SE2->E2_CODBAR,4,1)+SPACE(13)
        endif
        */
        if(len(alltrim(SE2->E2_CODBAR))<=44)//tratamento do codigo de barras outros bancos.
        	_Doc := SUBSTR(SE2->E2_CODBAR,20,25)+SUBSTR(SE2->E2_CODBAR,5,1)+SUBSTR(SE2->E2_CODBAR,4,1)+SPACE(13)	
        else
        	_Doc :=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)+SUBSTR(SE2->E2_CODBAR,33,1)+SUBSTR(SE2->E2_CODBAR,4,1)
        endif
   OTHERWISE
        _Doc := SPACE(40)
ENDCASE

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_DOC)
Return(_Doc)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
