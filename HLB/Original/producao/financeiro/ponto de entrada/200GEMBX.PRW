#Include "Protheus.ch"

/*
Funcao      : 200GEMBX 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada, para alterar o valor a ser baixado, na rotina comunica��es banc�rias->Retorno de cobranca.
Autor       : 
TDN         : O ponto de entrada 200GEMBX tratar� os valores dos t�tulos na rotina de retorno da comunica��o banc�ria.O tratamento deste ponto de entrada � igual ao do ponto de entrada padrao do financeiro F200VAR, onde o array com os valores dos t�tulos pode ser manipulado dentro do ponto de entrada..
Revis�o     : Jo�o Silva
Data/Hora   : 14/08/2014
M�dulo      : Financeiro.
*/

*--------------------*
User function 200GEMBX
*--------------------*
If cEmpAnt $ "40"
	If FUNNAME()=="FINA200"
    	//Recebe os valores passado pelo ponto de entrada
		aValores:=PARAMIXB
		//aValores := ({cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, 	
		//Valor recebido do titulo: aValores[8] , Valor Juros : aValores[9]
		//nValRec - Vari�vel do fonte principal(padr�o) com o valor recebido
		nValRec:=aValores[len(aValores)][8]+aValores[len(aValores)][5]

	EndIf	
EndIf

Return