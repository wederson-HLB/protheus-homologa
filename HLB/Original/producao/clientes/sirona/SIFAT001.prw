#include "rwmake.ch"
#include "protheus.ch"
/*
Funcao      : SIFAT001
Objetivos   : Exportar tabela SD2 para ftp atraves de job.
Autor       : Jean Victor Rocha
Data/Hora   : 22/06/2012
*/
*-----------------------*
User Function SIFAT001()
*-----------------------*
Local cQry := ""

RpcSetType(2)
RpcSetEnv("SI", "01")

cAliasWork := "WORK"
If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf 

aStru := SD2->(DbStruct())
cNome := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)
cQry := "SELECT * FROM "+RetSqlName("SD2")+" WHERE D_E_L_E_T_ <> '*'"
SqlToTrb (cQry,aStru,cAliasWork)

(cAliasWork)->(DbCloseArea())

cArqOrig  := "\SYSTEM\"+cNome+".DBF"
cPath     := "\ftp\si\SD2_"+DTOS(DATE())+".DBF"
__CopyFile( cArqOrig, cPath ) 

RpcClearEnv()

Return .T.