#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : FA050GRV
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Alterar o conteudo do E2_NOMFOR 
Autor       : Renato Rezende
Data/Hora   : 19/01/2015
Obs         : 
TDN         : Ponto de Entrada da Rotina FINA050 (Chamado após a gravação do dados).
Revisão     : 
Data/Hora   : 
Módulo      : Financeiro.
Cliente     : NTT
*/
*-------------------------*
 User Function FA050GRV()
*-------------------------* 
Local aArea	:= {}
Local cNum	:= ""

If cEmpAnt $ "0F"
	aArea	:= GetArea() 
	If Funname()=="FINA050" 
		cNum :=SE2->E2_PREFIXO+Alltrim(SE2->E2_NUM)
		While !SE2->(Eof()) .And. cNum==SE2->E2_PREFIXO+Alltrim(SE2->E2_NUM)
			If Empty(SE2->E2_NUM)
				SE2->(DbSkip())
				Loop
			EndIf
			ChkFile("SA2")
			SA2->(DbSetOrder(1))
			If SA2->(Dbseek(xFilial("SA2")+SE2->E2_FORNECE+E2_LOJA))
		   		SE2->(RecLock("SE2",.F.))
		   			SE2->E2_NOMFOR:= Alltrim(SA2->A2_NOME)
		   		SE2->(MsUnLock())
			EndIf
			SE2->(DbSkip())                                                           	
		EndDo
	EndIf
	RestArea(aArea)
EndIf

Return