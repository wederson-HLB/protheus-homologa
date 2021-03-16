#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

/*
Funcao      : F150GRV 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : No momento da chamada deste ponto de entrada, a tabela SE1 (T�tulos a Receber) est� posicionada 
			  no titulo j� gravado na linha de detalhe (tipo "1")
Autor       : Anderson Arrais
Data        : 07/05/2019
*/

*-----------------------*
User Function F150GRV
*-----------------------*
Local cLog := "ROTINA: F150GRV - gera��o do arquivo e atribui��o da carteira"
    
If cEmpAnt $ "QN"
	If SEE->(FieldPos("EE_P_CONV")) <> 0
		If EMPTY(SE1->E1_P_CONV)
			//Atualiza tabela SE1 com dados de convenio
			Reclock("SE1")
				SE1->E1_P_CONV := Alltrim(SEE->EE_P_CONV)
			MsUnlock()
			U_QNGEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SE1->E1_NUMBOR,SE1->E1_P_CONV,cLog)
		Else
			//Campo j� preenchido
			If MsgYesNo( 'Arquivo j� gerado com carteira '+ Alltrim(SE1->E1_P_CONV)+ ',Confirma nova gera��o na carteira '+ Alltrim(SEE->EE_P_CONV)+'?', 'HLB BRASIL' )
				Reclock("SE1")
					SE1->E1_P_CONV := Alltrim(SEE->EE_P_CONV)
				MsUnlock()
				U_QNGEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SE1->E1_NUMBOR,SE1->E1_P_CONV,cLog)
			Else
				MsgInfo( 'O arquivo ser� gerado e mantido a carteira '+Alltrim(SE1->E1_P_CONV), 'HLB BRASIL' )
			Endif
		EndIf
	EndIf
EndIf

Return