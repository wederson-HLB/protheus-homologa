#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch" 

/*
Funcao      : B1CTB001()
Parametros  : Nenhum
Retorno     : cDebito
Objetivos   : ExecBlock para tratamento das contas de débito e crédito dependendo da Natureza 
Autor       : Victor Yeh Britschka
Data/Hora   : 05/08/2016                       	
CHAMADO 035117   
*/                          
*-------------------------*
 User Function B1CTB001()
*-------------------------*  
Local cDebito := ""
Local cLP     := PARAMIXB[1]
Local cSeqLP  := PARAMIXB[2]

If cEmpAnt $ "B1" .And. cLP == "510" .And. cSeqLP == "6"
	If Alltrim(SE2->E2_NATUREZ) $ "2909/2918/2924"
		cDebito := "21116004"
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2908/2917/2923" 
		cDebito := "21116006"  
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2906/2915/2921" 
		cDebito := "21116009"
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2910/2919/2925"
		cDebito := "21116014"
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2907/2916/2922" 
		cDebito := "21116016"
	Else
	   	cDebito := SA2->A2_CONTA
  	EndIf
EndIf

If cEmpAnt $ "B1" .And. cLP == "515" .And. cSeqLP == "6"
	If Alltrim(SE2->E2_NATUREZ) $ "2909/2918/2924"
		cDebito := "21116004"
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2908/2917/2923" 
		cDebito := "21116006"  
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2906/2915/2921" 
		cDebito := "21116009"
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2910/2919/2925"
		cDebito := "21116014"
	ElseIf AllTrim(SE2->E2_NATUREZ) $ "2907/2916/2922" 
		cDebito := "21116016"
	Else
	   	cDebito := SA2->A2_CONTA
  	EndIf
EndIf

Return(cDebito)