#include "protheus.ch"
#Include "Topconn.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTGEN012 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fonte para replicar o sigamat.emp para o banco de dados.
Autor       : 
Revisão     : Matheus Massarotto
Data/Hora   : 21/02/2012
Módulo      : Configurador (Schedule)
*/

User function GTGEN012
Local cTabela	:= "SIGAMAT"

if Select("SX3")<=0
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa "YY" Filial "01"
endif

Private aArea		:= GetArea()

DbselectArea("SM0")
SM0->(DbGoTop())

//Pego a estrutura do sigamat
Private aStru:=DbStruct()

//Se o alias temporario estiver sendo usado, fecho-o
if select("TRBMAT")>0
	TRBMAT->(DbCloseArea())
endif

if !TCCanOpen(cTabela)
	//Cria a tabela no banco
	DBCREATE(cTabela,aStru,"TOPCONN")
else
	//Deleta a tabela no banco
	TCDelFile(cTabela) 

	//Cria a tabela no banco
	DBCREATE(cTabela,aStru,"TOPCONN")
endif

	dbUseArea(.T.,"TOPCONN",cTabela,"TRBMAT",.T.,.F.)
	
	While SM0->(!EOF())
        
		RecLock("TRBMAT",.T.)
		    for i:=1 to len(aStru)
		    	TRBMAT->&(aStru[i][1]):=SM0->&(aStru[i][1])
		    next
		TRBMAT->(MsUnlock())
		
		SM0->(DbSKip())
	Enddo     
	
RestArea(aArea)
Return