#include 'protheus.ch'

/*
Funcao      : F200TIT
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Alterar o historico da baixa no SE5 quando for via CNAB de "Valor recebido s/ Titulo" para "Baixa via CNAB"
Autor       : Anderson Arrais
Data/Hora   : 05/05/2015
Obs         :
Revisão     :
Módulo      : Financeiro
*/

*------------------------*
 User Function F200TIT()
*------------------------* 
Local cRef	:= "" 

Posicione("SE5",7,xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA,"E5_NUMERO")   

//if cEmpAnt $ "49" .AND. UPPER(ALLTRIM(FUNNAME()))=="FINA200" 
//	RecLock("SE5",.F.)
//		Replace SE5->E5_HISTOR With 'Baixa via CNAB'
//	SE5->(MsUnlock())
//endif
	
//AOA - 18/08/2016 - Tratamento para retorno de CNAB BANRISUL da empresa VOGEL
if cEmpAnt $ "V5/FA/FC" .AND. UPPER(ALLTRIM(FUNNAME()))=="FINA200" .AND. SE1->E1_P_BANRI='S'
	RecLock("SE1",.F.)
		Replace SE1->E1_P_BANRI With SE1->E1_IDCNAB
		Replace SE1->E1_IDCNAB With ''
	SE1->(MsUnlock())
    
//AOA - 17/03/2017 - Tratamento para SOLARIS, alteração no historico e grava ocorencia do retorno CNAB
Elseif cEmpAnt $ "HH/HJ" .AND. UPPER(ALLTRIM(FUNNAME()))=="FINA200"
	If ALLTRIM(SE5->E5_TIPODOC) $ "VL"
		RecLock("SE5",.F.)
			Replace SE5->E5_HISTOR With 'Rec. Cobrança Bancaria - '+SEB->EB_BANCO
		SE5->(MsUnlock())
	EndIf
	If !EMPTY(SE1->E1_NUM)
		//AOA - 15/08/2017 - Ajuste no código confirmação de retorno para atender mudança do banco ABC,01 e 02 confirmação de entrada, mas na base tem que gravar 02
		If SEB->EB_BANCO == "246" .AND. ALLTRIM(SEB->EB_REFBAN) == "01"
			cRef	:= "02"
		Else
			cRef	:= SEB->EB_REFBAN
		EndIf
		RecLock("SE1",.F.)
			Replace SE1->E1_P_RETBA With cRef
			Replace SE1->E1_P_DTRET With Date()
		SE1->(MsUnlock())
	EndIf

//CAS - 02/02/2021 - Alterar historico para Baixas de Retorno de CNAB, para todas as empresas	
Else
	IF !EMPTY(SE5->E5_NUMERO)
		RecLock("SE5",.F.)
			Replace SE5->E5_HISTOR With SE5->E5_TIPO + " " + SE5->E5_NUMERO + " - " + Posicione("SED",1,xFilial("SED")+alltrim(SE5->E5_NATUREZ),"ED_DESCRIC") 
		SE5->(MsUnlock())
	EndIf
Endif

//RSB - 10/10/2017 - Inclusão da mensagem da empresa Exeltis 
//if cEmpAnt $ "LG" .AND. UPPER(ALLTRIM(FUNNAME()))=="FINA200"
//	RecLock("SE5",.F.)
//		Replace SE5->E5_HISTOR With SE5->E5_NUMERO + " " + SE5->E5_PREFIXO + " " + SE5->E5_PARCELA + " " + Posicione("SA1",1,xFilial("SA1")+alltrim(SE5->E5_CLIENTE)+alltrim(SE5->E5_LOJA),"A1_NOME") 
//	SE5->(MsUnlock())
//endif     

Return
