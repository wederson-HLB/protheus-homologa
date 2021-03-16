#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TBICONN.CH"

/*
Funcao      : GTGEN007
Parametros  : cDataBase,cProcedure
Retorno     : 
Objetivos   : Fun��o utilizada para executar procedures do banco(O database precisa estar configurado no TopConnect).
Autor       : Matheus Massarotto
Data/Hora   : 26/11/2012    14:03
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gen�rico
*/

*-------------------------------------------*
User function GTGEN007(aParam) 
*-------------------------------------------*

Local nHndOra
Local cDataBase		:=aParam[1]
Local cProcedure	:=aParam[2]

if empty(cDataBase) .OR. empty(cProcedure)
	Conout("Fun��o GTGEN007: N�o foi definido o database ou a procedure!")
	Return
endif

Private cDBOra 	:= "MSSQL7/"+cDataBase	//Nome do Banco de Dados / Nome do Ambiente
Private cSrvOra := "10.0.30.5" 			//Servidor
Private nPorta	:= 7890					//Porta

nHndOra := TcLink(cDbOra,cSrvOra,nPorta) //Abre uma conex�o com o Servidor TOPConnect

If nHndOra < 0 
	Conout("Fun��o GTGEN007: Erro ao conectar no banco, Server: "+cSrvOra+", Porta:"+cvaltochar(nPorta)+", DataBase:"+cDBOra)
Endif

if !TCSPExist(cProcedure) //Verifica se existe a procedure
	Conout("Fun��o GTGEN007: N�o existe procedure: "+cProcedure+", no DataBase:"+cDBOra)
endif

TCSPExec(cProcedure) //Executa uma Stored Procedure no Banco de Dados

TcUnlink(nHndOra)//Encerra uma conex�o com o TOPConnect.

Return
