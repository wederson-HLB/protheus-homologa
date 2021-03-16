#Include "Protheus.ch"

/*
Funcao      : 200GEMBX 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada, para alterar o valor a ser baixado, na rotina comunicações bancárias->Retorno de cobranca.
Autor       : 
TDN         : O ponto de entrada 200GEMBX tratará os valores dos títulos na rotina de retorno da comunicação bancária.O tratamento deste ponto de entrada é igual ao do ponto de entrada padrao do financeiro F200VAR, onde o array com os valores dos títulos pode ser manipulado dentro do ponto de entrada..
Revisão     : Matheus Massarotto
Data/Hora   : 27/08/2012
Módulo      : Financeiro.
*/

*--------------------*
User function 200GEMBX
*--------------------*
//if cEmpAnt $ "Z8" .and. FUNNAME()=="FINA200"

if FUNNAME()=="FINA200"
    //Recebe os valores passado pelo ponto de entrada
	aValores:=PARAMIXB
	
	//Valor recebido do titulo: aValores[8] , Valor Juros : aValores[9]
	//nValRec - Variável do fonte principal(padrão) com o valor recebido
	nValRec:=aValores[len(aValores)][8]+aValores[len(aValores)][9]

endif	
//endif

Return