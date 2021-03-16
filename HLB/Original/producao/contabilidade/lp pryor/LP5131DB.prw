#include "rwmake.ch"        

User Function LP5131DB()        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//  CRIADO EM 31/08/04 - Francisco Ferreira de Sousa Neto
//  Define Conta Contabil a Debito para Pagamento antecipado

SetPrvt("_cntDebi")

_cntDebi:=SPACE(15)
	
IF ALLTRIM (SED->ED_CODIGO) $ '6899/4799/4003/2602/3901/'
	_cntDebi:=SED->ED_CONTA 
ELSEIF cEmpAnt $ 'B1' //JSS - CHAMADO 029889
	_cntDebi:='11317001'
ELSE       // OUTRAS 
	_cntDebi:= '112223002'
ENDIF
	
RETURN(_cntDebi)   
