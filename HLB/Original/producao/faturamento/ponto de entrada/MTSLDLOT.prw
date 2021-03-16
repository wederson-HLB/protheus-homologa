#Include 'Protheus.ch'

/*
Funcao      : MTSLDLOT
Parametros  : PARAMIXB
Retorno     : lRet
Objetivos   : Ponto que permite consultar os dados do produto com saldo por lote ou saldo por endereço
Autor     	: Renato Rezende
Data     	: 08/10/2018
Módulo      : Estoque
*/
*---------------------------------*
 User Function MTSLDLOT()
*---------------------------------*
Local aProduto	:= PARAMIXB
Local aAreaSA1	:= SA1->(GetArea())
Local cQuery	:= ""
Local lRet		:= .T.
Local dDataVenc	:= CtoD("//")
Local nRecCount	:= 0

//Exeltis
If cEmpAnt $ "LG"
	//AOA - 31/10/2018 - Ajuste para validar em qual rotinas deve ser permitido a validação por data de validade do lote customizado para EXELTIS
	If AllTrim(UPPER(FUNNAME()))$ "LGFAT006" .OR. AllTrim(UPPER(FUNNAME()))$ "MATA461" .OR. AllTrim(UPPER(FUNNAME()))$ "MATA440"
		//Customizacao para desconsiderar lotes que irao vencer para os clientes 
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(FwxFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA))
			//Verifica se o campo existe
			If SA1->(FieldPos("A1_P_TEMPL")) > 0
				If !Empty(SA1->A1_P_TEMPL)
					dDataVenc:= dDataBase + Val(SA1->A1_P_TEMPL)
					
					//Alias padrão do fonte SIGACUSB
					If Select("SLDATUEST") > 0
			    		If SLDATUEST->B8_DTVALID <= dDataVenc
							lRet := .F.				
						EndIf				
					ElseIf Select("SLDPORLOTE") > 0
			    		If SLDPORLOTE->B8_DTVALID <= dDataVenc
							lRet := .F.				
						EndIf				
					//Tratamento para a versão 12 segundo o link do TDN	
					//http://tdn.totvs.com/pages/releaseview.action?pageId=268803104
					ElseIf Select(PARAMIXB[1]) > 0
			    		If (PARAMIXB[1])->B8_DTVALID <= dDataVenc
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSA1)

Return lRet