#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MT410ACE
Parametros  : 
Retorno     :
Objetivos   : P.E. para validação do PV.
Autor       : Jean Victor Rocha
Data/Hora   : 24/11/2014     
Obs         : MT410ACE - Verificar acessos dos usuários
TDN         : http://tdn.totvs.com/pages/viewpage.action?pageId=6784346
*/
*----------------------*
User Function MT410ACE()
*----------------------*
local lRet 		:= .T.
Local nOpc 		:= ParamIXB[1]
Local cRotina	:= StrTran(Alltrim(UPPER(FunName())),'U_','')

Do Case
	Case cEmpAnt == "TP"
		If nOpc == 4 .or. nOpc == 1 .or. nOpc == 3//Alteração, Exclusão, Copia
			If SC5->(FieldPos("C5_P_NUM")) <> 0
				If !EMPTY(SC5->C5_P_NUM)
			  		MsgInfo("Ação não permitida para Pedidos originados da integração Twitter!","HLB BRASIL")
			   		lRet := .F.
			   	EndIf
			EndIf
		EndIf
	//RRP - 30/05/2018 - Exeltis
	Case cEmpAnt == "LG"
		If nOpc == 4 //Alteração
			If SC5->(FieldPos("C5_P_ENV1")) <> 0 .AND. !cRotina == "LGFAT006"
				If Alltrim(SC5->C5_P_ENV1) == "3" //Enviado (Pendente retorno) 
					If !MsgYesNo("Pedido já enviado para AGV! Deseja alterá-lo?","HLB BRASIL")
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
EndCase


Return lRet