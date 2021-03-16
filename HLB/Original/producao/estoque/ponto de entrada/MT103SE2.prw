#Include 'Protheus.ch'

/*
Funcao      : MT103SE2()
Objetivos   : Este ponto de entrada tem o objetivo de possibilitar a adi��o de campos ao aCols de informa��es do t�tulo financeiro 
              gravado para o documento de entrada, para as op��es de visualiza��o, inclus�o e exclus�o do documento.
              Ex.: Permite adicionar o campo de Vencimento Original ao aCols de informa��es quando visualizar ou excluir o documento.
              Localiza��o: Function NfeFldFin() - Fun��o respons�vel pelo tratamento do folder financeiro no documento de entrada.
Autor       : Jo�o Silva	
Data/Hora   : 30/09/2015
*/

*-----------------------*
User Function MT103SE2()
*-----------------------*
Local aHead:= PARAMIXB[1]
Local lVisual:= PARAMIXB[2]
Local aRet:= {} 

If  MsSeek("E2_HIST")
	
	AADD(aRet,{ TRIM(X3Titulo()),SX3->X3_CAMPO, SX3->X3_PICTURE,SX3->X3_TAMANHO,;
	SX3->X3_DECIMAL, "",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,;
	SX3->X3_CBOX, SX3->X3_RELACAO, ".T."})
EndIf

//AOA - 28/08/2017 - Solaris inclus�o do campo forma de pagamento
If cEmpAnt $ "HH/HJ"
	If  MsSeek("E2_P_FOPAG")
	
		AADD(aRet,{ TRIM(X3Titulo()),SX3->X3_CAMPO, SX3->X3_PICTURE,SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL, "",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,;
		SX3->X3_CBOX, SX3->X3_RELACAO, ".T."})
	EndIf
EndIf

Return (aRet)
