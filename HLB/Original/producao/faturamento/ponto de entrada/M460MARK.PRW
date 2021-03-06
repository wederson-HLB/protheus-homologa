#include "rwmake.ch"

/*
Funcao      : M460mark
Parametros  : Nil
Retorno     : lRet
Objetivos   : Valida��o de pedidos marcados
TDN         : O ponto de entrada M460MARK � utilizado para validar os pedidos marcados e est� localizado no inicio da fun��o a460Nota (endere�a rotinas para a gera��o dos arquivos SD2/SF2).Ser� informado no terceiro par�metro a s�rie selecionada na gera��o da nota e o n�mero da nota fiscal poder� ser verificado pela vari�vel private cNumero.
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 02/07/2013
Revis�o	    :
Data/Hora   :
M�dulo      : Faturamento
*/

*------------------------*
User Function M460mark()
*------------------------*
Local cRecno
Local lRet := .T.

If SM0->M0_CODIGO $ "TM"  //Victaulic
	
	SC9->(DbGoTop())
	
	While SC9->(!EOF())
		
		If (SC9->C9_OK != PARAMIXB[1] .And. PARAMIXB[2] .AND. !A460AVALIA()) .Or. (SC9->C9_OK == PARAMIXB[1] .And. !PARAMIXB[2])
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO ))
				If SC5->C5_P_PARC == "S"
					cRecno:= SC9->(RECNO())
					SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM+'01'))
					While SC9->(!EOF()) .AND. SC9->C9_PEDIDO = SC5->C5_NUM
						If  SC9->C9_OK <> PARAMIXB[1]
							MsgStop('O pedido '+SC9->C9_PEDIDO+' n�o pode ser faturado parcialmente, verifique o campo Bloc.Parcial.','Victaulic')
							lRet:=.F.
							SC9->(DbGoTo(cRecno))
							RecLock("SC9",.F.)
							SC9->C9_OK := ' '
							SC9->(MsUnlock())
							Exit
						Else
							lRet:=.T.
							SC9->(DbSkip ())
						EndIf
					EndDo
					
				Else
					lRet:=.T.
				EndIf
			EndIf
		EndIf
		
		SC9->(DbSkip())
		
	EndDo
	
EndIf

Return lRet
