#include 'protheus.ch'

/*
Funcao      : GTFIN004
Parametros  : 
Retorno     : cRet
Objetivos   : Identifica e retorna a modalidade de pagamento para o CNAB 500 Bradesco
			: De acordo com o banco e valor (01=Conta Corrente / 03=DOC / 08=TED)
Autor       : Anderson Arrais
Data/Hora   : 18/08/2015
Obs         :
Revisão     :
Data/Hora   :
Módulo      : Financeiro
Cliente     : Todos
*/

*-----------------------------------------------------*
 User Function GTFIN004()
*-----------------------------------------------------*        
Local cRet:= ""

If SUBSTR(SRA->RA_BCDEPSA,1,3)=="237"
	If cEmpAnt $ "7M/JO/N7/QI/XC"//AOA - 22/12/2016 - Alterado conforme solicitação do chamado 038193
		cRet:="05"
	Else
		cRet:="01"
    EndIf
//ElseIf SUBSTR(SRA->RA_BCDEPSA,1,3)<>"237" .AND. NVALOR < 500
	//cRet:="03"

//AOA 03/02/2016 - Alterado tratamento para todos diferentes de 237 gerar TED independente de valor.
ElseIf SUBSTR(SRA->RA_BCDEPSA,1,3)<>"237" //.AND. NVALOR >= 500
	cRet:="08"

EndIf

Return(cRet)