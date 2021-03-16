#include "rwmake.ch"        

User Function LP5131CR()        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//  CRIADO EM 31/08/04 - Francisco Ferreira de Sousa Neto
//  Define Conta Contabil a Credito para Pagamento antecipado

SetPrvt("_cntCred")

_cntCred:=SPACE(15)
	
// DFL - Adicionada a naturesa 9001
IF ALLTRIM(SED->ED_CODIGO) $ '3901/9001/' 
	_cntCred:= '211130001'     
	
ELSE       // OUTRAS 
	_cntCreb:= SA6->A6_CONTA

ENDIF


RETURN(_cntCred)
