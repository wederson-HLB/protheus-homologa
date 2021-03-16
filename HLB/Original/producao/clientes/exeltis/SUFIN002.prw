//|=====================================================================|
//|Programa: SUFIN002		   |Autor: Jo�o Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: CONVERSAO DE LINHA DIGITAVEL PARA CODIGO DE BARRAS		|
//|                                                                     |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: 									                            |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
///--------------------------------------------------------------------------\
//| Fun��o: SUFIN002				Autor: Infinit Tecnologia   Data: 13/05/2016 |
//|--------------------------------------------------------------------------|
//| Descri��o: Fun��o para Convers�o da Representa��o Num�rica do C�digo de  |
//|            Barras - Linha Digit�vel (LD) em C�digo de Barras (CB).       |
//|                                                                          |
//|            Para utiliza��o dessa Fun��o, deve-se criar um Gatilho para o |
//|            campo E2_CODBAR, Conta Dom�nio: E2_CODBAR, Tipo: Prim�rio,    |
//|            Regra: EXECBLOCK("SUFIN002",.T.), Posiciona: N�o.               |
//|                                                                          |
//|            Utilize tamb�m a Valida��o do Usu�rio para o Campo E2_CODBAR  |
//|            EXECBLOCK("SUFIN001",.T.) para Validar a LD ou o CB.            |
//\--------------------------------------------------------------------------/
#include "rwmake.ch"

USER FUNCTION SUFIN002()
SETPRVT("cStr,cFgts")

cStr := LTRIM(RTRIM(M->E2_CODBAR))

IF VALTYPE(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
	// Se o Campo est� em Branco n�o Converte nada.
	cStr := ""
ELSE
	// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
	// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
    // Completa as 14 posicoes do valor do documento.
    //--- Marciane 25.05.06 - Completar com zeros a esquerda o valor do codigo de barras se n�o tiver preenchido
    //cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
    cStr := IF(LEN(cStr)<44,subs(cStr,1,33)+Strzero(val(Subs(cStr,34,14)),14),cStr)                            
    //--- fim Marciane 25.05.06
ENDIF

DO CASE
	CASE LEN(cStr) == 47
		cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
	CASE LEN(cStr) == 48
   
       cFgts := Substr(cStr,17,4)  //--- Posicao 17 - 4 caracteres igual a 0179 ou 0180 ou 0181 significa FGTS
       If cFgts == "0179" .or. cFgts == "0180" .or. cFgts == "0181"                 
          cStr := cStr+SPACE(48-LEN(cStr)) 
       Else
          cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
	   EndIf
	OTHERWISE
		cStr := cStr+SPACE(48-LEN(cStr))
ENDCASE

RETURN(cStr)
