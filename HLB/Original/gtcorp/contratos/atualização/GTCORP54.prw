#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TBICONN.CH"

/*
Funcao      : GTCORP54
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função que executa uma thread para envio programado de msg sobre determinado lembrete, utiliza a tabela Z68 como base
Autor       : Matheus Massarotto
Data/Hora   : 12/12/2012    16:32
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*----------------------*
User function GTCORP54()
*----------------------*
Local cAmbiente	:= GetEnvServer()
Local nPort		:= Val( GetPVProfString("TCP","PORT","",GetAdv97()) ) 

conout("Fonte: GTCORP54, --> Server ini: "+GetAdv97())
conout("Fonte: GTCORP54, --> Server port: "+cvaltochar(nPort))

if TCCANOPEN("Z68"+cEmpAnt+"0")
	StartJob( "U_AUGTCORP54", GetEnvServer(),.F.,ThreadID(),__cUserID,GetComputerName(),LogUserName(),cEmpAnt,dDataBase,cAmbiente,nPort)
endif

Return

/*
Funcao      : AUGTCORP54
Parametros  : nID,cIdUser,cCompName,cUseLog,cEmp,dDataAtu
Retorno     : 
Objetivos   : Processa os dados da tabela Z68(Follow up) armazenados
Autor       : Matheus Massarotto
Data/Hora   : 12/12/2012
*/

*------------------------------------------------------------------------------------*
User function AUGTCORP54(nID,cIdUser,cCompName,cUseLog,cEmp,dDataAtu,cAmbiente,nPort)
*------------------------------------------------------------------------------------*
Local nTempo	:= 10000
Local cQry		:= ""
Local cDataAtu	:= DTOS(dDataAtu)
Local dDataQry	:= CTOD("//")
Local cObsQry	:= ""
Local cHora		:= ""
Local cTaskCod	:= ""
Local aTasks	:= {}
Local aTasksAux	:= {}


RpcClearEnv() //Limpa o ambiente
RpcSetType(3) //Nao utiliza licenca
			
lRet	:= 	RpcSetEnv( cEmp,"01")

if lRet
	conout("Fonte: GTCORP54, --> Ambiente preparado com sucesso")
else
	conout("Fonte: GTCORP54, --> Não foi possível preparar ambiente, Empresa: "+cEmp+", Filial: 01 ")
	Return
endif

cQry+=" SELECT * FROM "+RETSQLNAME("Z68")
cQry+=" WHERE Z68_DATA<='"+cDataAtu+"' AND Z68_USER='"+cIdUser+"' AND Z68_EXECUT='F'"

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
    
	Count to nRecCount
	
	if nRecCount >0
		QRYTEMP->(DbGotop())
			
			While QRYTEMP->(!EOF())
				if QRYTEMP->Z68_ATIVO=="T" .AND. QRYTEMP->Z68_EXECUT=="F" .AND. STOD(QRYTEMP->Z68_DATA)==dDataBase
					AADD(aTasks,{Alltrim(QRYTEMP->Z68_OBS),STOD(QRYTEMP->Z68_DATA),QRYTEMP->Z68_HORA,QRYTEMP->Z68_CODIGO})					
					//cObsQry		:= Alltrim(QRYTEMP->Z68_OBS)
					//dDataQry	:= STOD(QRYTEMP->Z68_DATA)
					//cHora		:= QRYTEMP->Z68_HORA
					//cTaskCod	:= QRYTEMP->Z68_CODIGO
				endif
				
				QRYTEMP->(DbSkip())
			Enddo
    endif

//Finaliza o ambiente
RESET ENVIRONMENT
    
	//if !empty(cObsQry) .AND. !empty(dDataQry)
	if !empty(aTasks)
		conout("Fonte: GTCORP54, --> Antes do PowerSh")

		for j:=1 to len(aTasks)
		    
			if aTasks[j][2]<dDataAtu
				AADD(aTasksAux,{aTasks[j][1],aTasks[j][2],aTasks[j][3],aTasks[j][4]})
				
			elseif HTON(SUBSTR(TIME(),1,5))>HTON(aTasks[j][3])
				//U_PowerSh(nID,cIdUser,cCompName,cUseLog,cObsQry,dDataQry,cHora,cTaskCod,cEmp,cAmbiente,nPort)
				//U_PowerSh(nID,cIdUser,cCompName,cUseLog,cEmp,cAmbiente,nPort,aTasks)
				

				AADD(aTasksAux,{aTasks[j][1],aTasks[j][2],aTasks[j][3],aTasks[j][4]})
			else
	
					
				//conout("Fonte: GTCORP54, -->No sleep, por: "+cvaltochar(SegtoMilS(cHora)))
				//sleep(SegtoMilS(cHora))
					
				conout("Fonte: GTCORP54, -->No sleep, por: "+cvaltochar(SegtoMilS(aTasks[j][3])))
				sleep(SegtoMilS(aTasks[j][3]))
					
				//U_PowerSh(nID,cIdUser,cCompName,cUseLog,cObsQry,dDataQry,cHora,cTaskCod,cEmp,cAmbiente,nPort)
				U_PowerSh(nID,cIdUser,cCompName,cUseLog,cEmp,cAmbiente,nPort,{{aTasks[j][1],aTasks[j][2],aTasks[j][3],aTasks[j][4]}})
				
			endif
		    
		next
		
		if !empty(aTasksAux)
			U_PowerSh(nID,cIdUser,cCompName,cUseLog,cEmp,cAmbiente,nPort,aTasksAux)
		endif
		
		
	endif
	
Return

/*
Funcao      : SegtoMilS
Parametros  : cHora
Retorno     : nRet
Objetivos   : Processa a hora passada com a hora atual retornando os milisegundos faltantes
Autor       : Matheus Massarotto
Data/Hora   : 12/12/2012
*/

*------------------------------*
Static function SegtoMilS(cHora)
*------------------------------*
Local nRet:=0

//sleep() --milisegundos
//1ms = 0,001s
//1s = 1000ms

//subtraio a hora atual com o tempo que esta programado
nSegWait:=ABS(HTON(SUBSTR(TIME(),1,5))-HTON((cHora)))

//multiplica por 60 para horas em minutos, multiplica por 60 para minutos em segundos e multiplica por 1000 (milisegndos)
nRet	:= ((nSegWait*60)*60 )*1000

Return(nRet)