#include "rwmake.ch"        

User Function LP513_DB()        

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

//  CRIADO EM 31/08/04 - Francisco Ferreira de Sousa Neto
//  Define Conta Contabil a Debito para Pagamento antecipado

SetPrvt("_cntDebi")

_cntDebi:=SPACE(15)
	
IF SED->ED_CODIGO $ '6899/4799/4003/2602/' 
	_cntDebi:=SED->ED_CONTA
ELSE       // OUTRAS 
	_cntDebi:='11317001'
ENDIF
	
RETURN(_cntDebi)
