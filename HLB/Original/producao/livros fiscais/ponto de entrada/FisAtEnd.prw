#include "Protheus.ch"

/*
Funcao      : FisAtEnd
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada que permite realizar altera��es no endere�o da funcao FISGETEND.
Autor       : Renato Rezende
TDN         : Ponto de entrada que permite realizar altera��es no endere�o da funcao FISGETEND.
Data/Hora   : 24/04/2014
M�dulo      : Livros Fiscais.
*/
*---------------------------*
 User Function FisAtEnd()
*---------------------------*

Local cEndereco := ParamIXB[1]
Local cRet      := ""

If FunName() == "MATA950"
	//Carregar o complemento de endere�o para as notas de Barueri 
	If Alltrim(MV_PAR03) == "NFEBARUE"
		cEndereco := AllTrim(cEndereco)
		//Verificando se n�o � o endere�o do Prestador do Servi�o
		If cEndereco <> Alltrim(SM0->M0_ENDENT)
			If !(SF3->F3_TIPO$"D/B")
				If !Empty(Alltrim(SA1->A1_COMPLEM))
					cEndereco+= " "+Alltrim(SA1->A1_COMPLEM)
				EndIf
			Else
				If !Empty(Alltrim(SA2->A2_COMPLEM))
					cEndereco+=	" "+Alltrim(SA2->A2_COMPLEM)
				EndIf
			EndIf
		EndIf
		cRet := cEndereco
	EndIf
EndIf

Return cRet