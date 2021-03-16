#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"
#include "apwebex.ch"
#include "totvs.ch"
#include "tbiconn.ch"

/*
Funcao      : GTFLG004
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Revalidação de alteração de Status no Fluig
Autor       : Jean Victor Rocha 
Revisão		:
Data/Hora   : 29/06/2016
Módulo      : 
*/
*----------------------*
User Function GTFLG004()
*----------------------*
ConOut("$GT --- GTFLG004 - Executado em "+DTOS(date())+" - "+Time())
Private cEmpJOB := "02"//empresa teste 03 filial 01
Private cFilJOB := "01"

Private URLFLUIG := "http://187.94.57.99:8280/webdesk/"//"http://gt.fluig.com/webdesk/"//"http://gt.fluig.com:8280/webdesk/"//"http://10.11.210.3:8080/webdesk/"

Private cUserAdm := "esbUser"
Private cPassAdm := "Fluig@2014"
Private ncompanyId := 1

//Inicialização do ambiente
RpcSetType(3)
RpcSetEnv(cEmpJOB,cFilJOB)

//Busca os dados a serem processados.
BuscaDados()

//Integração dos dados para cada solicitação de faturamento
QRY->(DbGoTop())
If QRY->(!EOF())
	While QRY->(!EOF())
		getDataset(QRY->ZF0_NUMPRO,QRY->R_E_C_N_O_)
		QRY->(DbSkip())
	EndDo
EndIf

//Encerra o ambiente JOB	
RpcClearEnv()
Return .T.

/*
Funcao      : BuscaDados
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Busca dos dados a serem processados
Autor       : Jean Victor Rocha 
Data/Hora   : 10/05/2016
*/
*--------------------------*
Static Function	BuscaDados()
*--------------------------*

If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf

cQry := " Select *
cQry += " From "+RetSQLName("ZF0")
cQry += " where D_E_L_E_T_ <> '*'
cQry += " 	AND ZF0_STATUS not in ('S','C')
cQry += " 	AND ZF0_NUMPRO not like '%SFA%'
cQry += " 	AND ZF0_NUMPRO <> ''
cQry += " 	AND ZF0_NOTIF = ''

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'QRY', .T., .T.)

Return .T. 

/*
Funcao      : getDataSet
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Consulta em DataSet do Fluig.
Autor       : Jean Victor Rocha 
Data/Hora   : 12/05/2016
*/
*-----------------------------------------*
Static Function getDataSet(cBusca,nRecReg)
*-----------------------------------------*
Local WS  := WSECMDatasetServiceService():new()
Local cDataSet := "ds_gt_get_instanceactive"
          
WS:_URL             := URLFLUIG+"ECMDatasetService"
WS:ncompanyId       := ncompanyId
WS:cusername        := cUserAdm
WS:cpassword        := cPassAdm
WS:cname       		:= cDataSet

aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "MUST"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "processHistoryPK.processInstanceId"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := ALLTRIM(cBusca)
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := ALLTRIM(cBusca)
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.

Ws:getDataset()
oResult := Ws:OWSGETDATASETDATASET

If (nPos := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "PROCESSHISTORYPK.PROCESSINSTANCEID"})) <> 0
	If len(oResult:OWSVALUES) > 0
		If ALLTRIM(oResult:OWSVALUES[1]:OWSVALUE[1]:TEXT) == ALLTRIM(cBusca)
	   		If ALLTRIM(oResult:OWSVALUES[1]:OWSVALUE[2]:TEXT) == "CANCELADO"
				ConOut("$GT --- GTFLG004 - ATUALIZACAO FORCADA PARA CANCELADO ["+ALLTRIM(cBusca)+"]")
				TCSQLEXEC("Update "+RetSQLName("ZF0")+" set ZF0_STATUS = 'C' where R_E_C_N_O_ = "+ALLTRIM(STR(nRecReg)))
		   	ElseIf ALLTRIM(oResult:OWSVALUES[1]:OWSVALUE[2]:TEXT) == "FINALIZADO"
		   		ConOut("$GT --- GTFLG004 - ATUALIZACAO FORCADA PARA FINALIZADO ["+ALLTRIM(cBusca)+"]")
			   	TCSQLEXEC("Update "+RetSQLName("ZF0")+" set ZF0_STATUS = 'S' where R_E_C_N_O_ = "+ALLTRIM(STR(nRecReg)))
		   	EndIF
	 	EndIf
	EndIf
EndIf

Return .T.