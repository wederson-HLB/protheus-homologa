#Include "Protheus.ch"

/*
Funcao      : F590CAN
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. no cancelamento de um titulo do border�(Manuten��o de border�)
Autor     	: Matheus Massarotto
Data     	: 28/07/2011  
Obs         : 
TDN         :
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Financeiro
Cliente     : Takeda
*/

*----------------------*
 User Function F590CAN
*----------------------*

//AOA - 14/03/2017 - Limpar c�digo de barras quando usado manuten��o de border�
If PARAMIXB[1]=="R" .AND. cEmpAnt $ "HH/HJ"	
	RecLock("SE1",.F.)
		SE1->E1_CODBAR  := ""
		SE1->E1_CODDIG  := ""
		SE1->E1_P_RETBA := ""
		SE1->E1_P_DTRET := CTOD("//")
		SE1->E1_P_RETWS := ""
	SE1->(MsUnlock())
EndIf

//AOA - 05/07/2018 - Tratamento para Les Mills
If PARAMIXB[1]=="R" .AND. cEmpAnt $ "QN"
	RecLock("SE1",.F.)
		SE1->E1_P_CONV := ""
	SE1->(MsUnlock())                   
	U_QNGEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SE1->E1_NUMBOR,SE1->E1_P_CONV,"F590CAN: Cancelamento manutencao bordero")	
EndIf

If !cEmpAnt $ "TK/UZ/JO/46/VN/TM/KI/1F/HP/L1/4V/WA/N8/I2/VW/0F/M7/QU"
	Return .F.
EndIf

If PARAMIXB[1]=="P"	
	RecLock("SE2",.F.)
		SE2->E2_IDCNAB:=""
	SE2->(MsUnlock())
EndIf

Return