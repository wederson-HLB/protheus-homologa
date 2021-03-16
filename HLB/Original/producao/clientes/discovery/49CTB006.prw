#include "rwmake.ch"        
#include "protheus.ch"

/*
Funcao      : 49CTB006
Parametros  : 
Retorno     : 
Objetivos   : Lancamento Padrao de Compras (Pelo Codigo da Retencao - IRRF)
Autor       : Cesar Alves dos Santos
Data/Hora   : 11/07/2017         
Modulo      : Contabilidade
*/

*-----------------------*
User Function 49CTB006()
*-----------------------*   

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_CNTCRED,")

_cntCred:=space(9)


If cEmpAnt $ "49"

	IF ALLTRIM(CCODRET)=="0588"   
		_cntCred:="211230014"
	
	ELSEIF ALLTRIM(CCODRET)=="8045"     
		_cntCred:="211230013"

	ELSEIF ALLTRIM(CCODRET)=="1708"
		_cntCred:="211230003"       
 	  
	ENDIF
	
ENDIF


RETURN(_cntCred)
