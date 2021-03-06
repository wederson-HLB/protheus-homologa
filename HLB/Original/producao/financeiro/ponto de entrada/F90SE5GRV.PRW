#Include "Protheus.ch"

/*
Funcao      : F90SE5GRV
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. na baixa autom�tica que realiza a altera��o do hist�rico
Autor     	: Matheus Massarotto
Data     	: 12/12/2011  
Obs         : 
TDN         :
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 17/07/2012
M�dulo      : Financeiro
Cliente     : Engecorps
*/

*-----------------------*
User Function F90SE5GRV
*-----------------------*

if cEmpAnt $ "07"

Reclock( "SE5", .F. ) 
	SE5->E5_HISTOR:=alltrim(SE2->E2_NUM)+" "+alltrim(SE2->E2_NOMFOR)
MsUnlock()

Elseif cEmpAnt $ "1Z" //RSB - 20/01/2017 - Empresa FTC CARDS (P11_09)

Reclock( "SE5", .F. ) 
	SE5->E5_HISTOR:=alltrim(SE2->E2_NATUREZ)+"-"+Posicione("SED",1,xFilial("SED")+alltrim(SE2->E2_NATUREZ),"ED_DESCRIC")
MsUnlock()

endif

Return
