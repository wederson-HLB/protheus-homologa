#include 'totvs.ch'
#INCLUDE "PROTHEUS.CH"   
#include 'apwebsrv.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

/*
Funcao      : GTGEN040
Objetivos   : Retornar o nome da tabela no banco de dados.
Autor       : Jean Victor Rocha
Data        : 15/05/2017
*/
*----------------------------------------*
User Function GTGEN040(cCdEmpAtual,cAlias)
*----------------------------------------*
Local cRet := ""
Local cAliasSX2 := "SX2TMP"

If select(cAliasSX2) > 0
	(cAliasSX2)->(DbCloseArea())
EndIf 

If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	dbUseArea(.T., __LOCALDRIVER, GetSrvProfString("Startpath","")+"SX2"+cCdEmpAtual+"0.DBF", cAliasSX2, .T., .T.)
Else
	dbUseArea(.T., __LOCALDRIVER, GetSrvProfString("Startpath","")+"SX2"+cCdEmpAtual+"0.DTC", cAliasSX2, .T., .T.)
Endif                                                                                                          

cArqInd := CriaTrab(Nil, .F.) 
IndRegua(cAliasSX2,cArqInd,"X2_CHAVE",,,,.F.)

(cAliasSX2)->(DbSetOrder(1))
If (cAliasSX2)->(DbSeek(cAlias))
	cRet := (cAliasSX2)->X2_ARQUIVO
Else
	cRet := cAlias+cCdEmpAtual+"0"
EndIf

FErase(cArqInd+OrdBagExt()) 

//Tratamento para popular a tabela no banco
If Select("ID") <> 0
	ID->(DbCloseArea())	
EndIf

If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	TCQuery "Select OBJECT_ID('P11_01.dbo.GTFLG001SX2') as ID" ALIAS "ID" NEW 
Else
	TCQuery "Select OBJECT_ID('P12_01.dbo.GTFLG001SX2') as ID" ALIAS "ID" NEW 
EndIf

If ID->ID <= 0
	If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
		TCSQLEXEC("CREATE TABLE P11_01.dbo.GTFLG001SX2 (CODEMP varchar(2),X2_CHAVE varchar(3),X2_ARQUIVO varchar(6),DT_ATU varchar(8))")
	Else
		TCSQLEXEC("CREATE TABLE P12_01.dbo.GTFLG001SX2 (CODEMP varchar(2),X2_CHAVE varchar(3),X2_ARQUIVO varchar(6),DT_ATU varchar(8))")
	EndIf
EndIf
If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	TCSQLExec(" Delete P11_01.dbo.GTFLG001SX2 where CODEMP='"+cCdEmpAtual+"' AND X2_CHAVE='"+cAlias+"'")
	TCSQLExec(" Insert into P11_01.dbo.GTFLG001SX2 VALUES('"+cCdEmpAtual+"','"+cAlias+"','"+cRet+"','"+DTOS(Date())+"' )")   
Else
	TCSQLExec(" Delete P12_01.dbo.GTFLG001SX2 where CODEMP='"+cCdEmpAtual+"' AND X2_CHAVE='"+cAlias+"'")
	TCSQLExec(" Insert into P12_01.dbo.GTFLG001SX2 VALUES('"+cCdEmpAtual+"','"+cAlias+"','"+cRet+"','"+DTOS(Date())+"' )")   
EndIf               

Return ALLTRIM(cRet)
