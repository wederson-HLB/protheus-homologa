#Include "Protheus.ch"
#INCLUDE 'RWMAKE.CH'

/*
Funcao      : F650VAR 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : O ponto de entrada F650VAR ser� executado ap�s carregar os dados do arquivo de recepcao banc�ria. Utilizado para alterar os dados recebidos
Autor       : 
Revis�o     : Jo�o Silva
Data/Hora   : 14/08/2014
M�dulo      : Financeiro.
*/

*--------------------*
User function F650VAR 
*--------------------*
If cEmpAnt $ "40"
    	//Recebe os valores passado pelo ponto de entrada
		aValores:=PARAMIXB
		//aValores := ({cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, 	
		//Valor recebido do titulo: aValores[8] , Valor Juros : aValores[9]
		//nValRec - Vari�vel do fonte principal(padr�o) com o valor recebido
		nValRec:=aValores[len(aValores)][8]+aValores[len(aValores)][5]
EndIf

If cEmpAnt $ "SU" //AOA - 14/05/2016 - Customiza��o feito pela consultoria da exeltis (Jo�o Vitor)
 	If ExistBlock("SUFIN008")
		U_SUFIN008()
	EndIf
EndIf

Return