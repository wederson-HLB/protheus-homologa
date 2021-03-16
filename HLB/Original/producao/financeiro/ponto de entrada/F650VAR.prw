#Include "Protheus.ch"
#INCLUDE 'RWMAKE.CH'

/*
Funcao      : F650VAR 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : O ponto de entrada F650VAR será executado após carregar os dados do arquivo de recepcao bancária. Utilizado para alterar os dados recebidos
Autor       : 
Revisão     : João Silva
Data/Hora   : 14/08/2014
Módulo      : Financeiro.
*/

*--------------------*
User function F650VAR 
*--------------------*
If cEmpAnt $ "40"
    	//Recebe os valores passado pelo ponto de entrada
		aValores:=PARAMIXB
		//aValores := ({cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, 	
		//Valor recebido do titulo: aValores[8] , Valor Juros : aValores[9]
		//nValRec - Variável do fonte principal(padrão) com o valor recebido
		nValRec:=aValores[len(aValores)][8]+aValores[len(aValores)][5]
EndIf

If cEmpAnt $ "SU" //AOA - 14/05/2016 - Customização feito pela consultoria da exeltis (João Vitor)
 	If ExistBlock("SUFIN008")
		U_SUFIN008()
	EndIf
EndIf

Return