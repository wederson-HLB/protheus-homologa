#Include "Protheus.ch"
#Include "TBICONN.CH"

/*
Funcao      : PowerSh
Parametros  : Nil
Retorno     : Nil
Objetivos   : Fun��o que executa o PowerShell do windows em parceria com o apconnxcontrol.ocx para envio de mensagem ao usu�rio logado.
Autor       : Matheus Massarotto
Data/Hora   : 12/12/2012    16:32
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gen�rico
*/
						//nID,cIdUser,cCompName,cUseLog,cObs,dData,cHora,cTaskCod,cEmp,cAmbiente,nPort
*--------------------------------------------------------------------------------------------------*
User function PowerSh(nID,cIdUser,cCompName,cUseLog,cEmp,cAmbiente,nPort,aTasks)
*--------------------------------------------------------------------------------------------------*
Local cPowerS	:=""
Local cComputer	:=cCompName			//GetComputerName()			//Retorna o nome da m�quina (Hostname) onde o Smart Client est� sendo executado.
Local cThread	:=cvaltochar(nID) 	//cvaltochar(ThreadID())	//Retorna o ID (n�mero de identifica��o) da thread em que a chamada da fun��o foi realizada.
Local cUseLog	:=cUseLog			//LogUserName()				//Obt�m o nome do usu�rio logado no sistema operacional da esta��o em que est� sendo executado o Smart Client.
Local cMsg		:=""
//Local cObs		:=cObs
Local cUsua		:="usrpdr"
Local cSenh		:="U@usrpdr2013"

DEFAULT aTasks	:={}

SET DATE FORMAT "dd/mm/yyyy"

if empty(cComputer) .OR. empty(cThread) .OR. empty(cUseLog) .OR. empty(aTasks)
	conout("Fonte: PowerSh, --> N�o foi informado nome do computador ou thread ou usu�rio ou mensagem")
	Return()
endif

cMsg+='<style type="text/css">'
cMsg+='.myTable { background-color:#E6E6FA;border-collapse:collapse; }'
cMsg+='.myTable th { background-color:#6959CD;color:white; }'
cMsg+='.myTable td, .myTable th { padding:5px;border:1px solid #BDB76B; }'
cMsg+='</style>'
cMsg+='Informa��o autom�tica sobre um agendamento para:'
cMsg+='<br>'
cMsg+='<table border="1" style="width:200px;" class="myTable">'
cMsg+='	<tr>'
cMsg+='		<th> Data </th>'
cMsg+='		<th> Hora </th>'
cMsg+='		<th> Observa��o </th>'
cMsg+='	</tr>'

for i:=1 to len(aTasks)
	cMsg+='	<tr>'
	cMsg+='		<td> '+DTOC(aTasks[i][2])+' </td>'
	cMsg+='		<td> '+aTasks[i][3]+' </td>'
	cMsg+='		<td> '+aTasks[i][1]+' </td>'
	cMsg+='	</tr>'

//	cMsg+='	<tr>'
//	cMsg+='		<td> '+DTOC(dData)+' </td>'
//	cMsg+='		<td> '+cHora+' </td>'
//	cMsg+='		<td> '+cObs+' </td>'
//	cMsg+='	</tr>'
next

cMsg+='</table>'

conout("Fonte: PowerSh, computador: "+cComputer)
conout("Fonte: PowerSh, Thread: "+cThread)
conout("Fonte: PowerSh, Usuario: "+cUseLog)

//Comando PowerShell
cPowerS+=" $TObj = New-Object -Com apconnxcontrol.apconnx;" //#Instanciando um novo objeto

//#Definindo as variaveis para Conexao
cPowerS+=" $TEnv = '"+cAmbiente+"';"
cPowerS+=" $TSrv = 'localhost';"
cPowerS+=" $TPort = "+cvaltochar(nPort)+";"
cPowerS+=" $TUser = '"+cUsua+"';"
cPowerS+=" $TPWD = '"+cSenh+"';"

//#Atribuindo as variaveis para Conexao �s Propriedades do objeto
cPowerS+=" $TObj.Environment = $TEnv;"
cPowerS+=" $TObj.Password = $TPWD;"
cPowerS+=" $TObj.Port = $TPort;"
cPowerS+=" $TObj.Server = $TSrv;"
cPowerS+=" $TObj.User = $TUser;"
//#Conectando
cPowerS+=" $TObj.Connect();"
//Enviando mensagem para o usu�rio
cPowerS+=" $TObj.SendMessage('"+cUseLog+"','"+cComputer+"','"+cThread+"','','"+cMsg+"');"
cPowerS+=" $TObj.Disconnect()"

if execPowShe(cPowerS)
	conout("Fonte: PowerSh, --> Executou")
	
	RpcClearEnv() //Limpa o ambiente
	RpcSetType(3) //Nao utiliza licenca
			
	lRet	:= 	RpcSetEnv(cEmp,"01")
	
		if lRet
			DbSelectArea("Z68")
			Z68->(DbSetOrder(1))

			for i:=1 to len(aTasks)
				//if DbSeek(xFilial("Z68")+cTaskCod)
				if DbSeek(xFilial("Z68")+aTasks[i][4])
					RecLock("Z68",.F.)
						Z68->Z68_EXECUT:=.T.
					MsUnlock()
				endif
			next
			
		endif
	
	//Finaliza o ambiente
	RESET ENVIRONMENT
	
else
	conout("Fonte: PowerSh, --> Problema na execu��o")
endif

Return


/*
Funcao      : execPowShe
Parametros  : cComando
Retorno     : lRet
Objetivos   : Executa o comando do powershell para enviar a mensagem.
Autor       : Matheus Massarotto
Data/Hora   : 11/12/2012
*/
*----------------------------------------*
Static Function execPowShe(cComando)
*----------------------------------------*
Local lRet		:=.F.

Local cCommand 	:= 'C:\Windows\syswow64\Windowspowershell\v1.0\powershell.exe -command "&{'+cComando+'}"'
Local lWait  	:= .T.
Local cPath     := "C:\Windows\syswow64\Windowspowershell\v1.0\"

conout("Fonte: PowerSh, --> Comando: "+cCommand)

lRet:=WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)