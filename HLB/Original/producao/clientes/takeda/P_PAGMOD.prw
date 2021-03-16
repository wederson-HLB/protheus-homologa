#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
  
/*
Funcao      : P_Pagmod
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA PARA INDICAR A MODALIDADE DO PAGAMENTO CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (264-265)
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

*------------------------*
User Function P_Pagmod()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*------------------------*                          

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_AMODEL,")

/////  PROGRAMA PARA INDICAR A MODALIDADE DO PAGAMENTO
/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (264-265)

_aModel := SUBSTR(SEA->EA_MODELO,1,2)

IF _aModel == "  "
   IF SUBSTR(SE2->E2_CODBAR,1,3) == "237"
      _aModel := "30"
   ELSE
      _aModel := "31"
   ENDIF
ENDIF

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __Return(_aModel)
Return(_aModel)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
