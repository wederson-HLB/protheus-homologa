#include "Protheus.ch"

/*
Funcao      : FisAtEnd
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada que permite realizar alterações no endereço da funcao FISGETEND.
Autor       : Renato Rezende
TDN         : Ponto de entrada que permite realizar alterações no endereço da funcao FISGETEND.
Data/Hora   : 24/04/2014
Módulo      : Livros Fiscais.
*/
*---------------------------*
 User Function FisAtEnd()
*---------------------------*

Local cEndereco := ParamIXB[1]
Local cRet      := ""

If FunName() == "MATA950"
	//Carregar o complemento de endereço para as notas de Barueri 
	If Alltrim(MV_PAR03) == "NFEBARUE"
		cEndereco := AllTrim(cEndereco)
		//Verificando se não é o endereço do Prestador do Serviço
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