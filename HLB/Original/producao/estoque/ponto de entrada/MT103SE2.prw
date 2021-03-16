#Include 'Protheus.ch'

/*
Funcao      : MT103SE2()
Objetivos   : Este ponto de entrada tem o objetivo de possibilitar a adição de campos ao aCols de informações do título financeiro 
              gravado para o documento de entrada, para as opções de visualização, inclusão e exclusão do documento.
              Ex.: Permite adicionar o campo de Vencimento Original ao aCols de informações quando visualizar ou excluir o documento.
              Localização: Function NfeFldFin() - Função responsável pelo tratamento do folder financeiro no documento de entrada.
Autor       : João Silva	
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

//AOA - 28/08/2017 - Solaris inclusão do campo forma de pagamento
If cEmpAnt $ "HH/HJ"
	If  MsSeek("E2_P_FOPAG")
	
		AADD(aRet,{ TRIM(X3Titulo()),SX3->X3_CAMPO, SX3->X3_PICTURE,SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL, "",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,;
		SX3->X3_CBOX, SX3->X3_RELACAO, ".T."})
	EndIf
EndIf

Return (aRet)
