#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
/*
Funcao      : MTA103OK
Parametros  : Nil
Retorno     : Nil
Objetivos   : Ponto de Entrada MTA103OK na fun��o A103LinOk() Rotina de validacao da LinhaOk. Esse ponto permite a alterar o 
				resultado da valida��o padr�o para inclus�o/altera��o de registros de entrada, por customiza��es do cliente.
Autor       : Jean Victor Rocha
Data/Hora   : 11/08/2014
TDN			: http://tdn.totvs.com/pages/releaseview.action?pageId=6087790
*/
*----------------------*
User Function MTA103OK()
*----------------------*
Local lRet	:= ParamIxb[1]
Local aOrd	:= {}
Local nPosLoteCtl	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTECTL"})
Local nPosTES		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})

//Verifica se ja n�o esta rejeitado.
If !lRet
	Return lRet
EndIf
     
//Tratamento para alerta de lote automatico para o usuario.
If GETMV("MV_P_00016",,.F.)
	If !EMPTY(aCols[n][nPosTES])
		aOrd := SaveOrd({"SF4"})
		SF4->(DbSetOrder(1))
		If SF4->(DBSeek(xFilial("SF4")+aCols[n][nPosTES]))  
			If SF4->F4_ESTOQUE == 'S'
				If SB1->B1_RASTRO $  "S/L" 
					If n <> 0 .and. nPosLoteCtl <> 0 .and. EMPTY(aCols[n][nPosLoteCtl])
						lRet := MsgYesNo("Lote n�o informado, ser� gerado autom�ticamente pelo sistema, deseja continuar?","HLB BRASIL")
					EndIf
				EndIf
			EndIf
		EndIf
		RestOrd(aOrd)
	EndIf
EndIf

Return lRet