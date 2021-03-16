#include "rwmake.ch"

/*
Funcao      : M460mark
Parametros  : Nil
Retorno     : lRet
Objetivos   : Validação de pedidos marcados
TDN         : O ponto de entrada M460MARK é utilizado para validar os pedidos marcados e está localizado no inicio da função a460Nota (endereça rotinas para a geração dos arquivos SD2/SF2).Será informado no terceiro parâmetro a série selecionada na geração da nota e o número da nota fiscal poderá ser verificado pela variável private cNumero.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2013
Revisão	    :
Data/Hora   :
Módulo      : Faturamento
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
							MsgStop('O pedido '+SC9->C9_PEDIDO+' não pode ser faturado parcialmente, verifique o campo Bloc.Parcial.','Victaulic')
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
