#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*
Funcao      : N6FAT009
Parametros  :	aParam	=	Definição dos dados da empresa que será executada
					[1]	Empresa
					[2]	Filial
				cOpc	=	Define as ações do processamento (quando não informado, será executado todas as ações).
			  		A: Forçar a inclusão de pedidos na tabela de rastrio (desconsidera a gravação via integração FT)
			  		B: Gerar arquivos PDF e XML (somente filial 02)
			  		C: Validar arquivos Gerados PDF e XML (somente filial 02)
			  		D: Comprimir arquivos PDF e XML e gerar o ZIP (somente filial 02)
			  		E: Enviar arquivos ao SFTP (somente filial 02)
			  		F: Confirmar recebimento do arquivo no SFTP (somente filial 02)
			  		G: Confirmar arquivo PDF
			  		H: Enviar PDF e XML para SFTP doTerra
			  		I: Confirmar PDF e XML para SFTP doTerra
			  		J: Realizar a integração de pedidos Datatrax >> Protheus 
			  		K: Realizar a confirmação do picking físico na FEDEX (consultar o WS deles)
			  		L: Realizar o Faturamento dos pedidos de vendas Doterra
			  		M: Realizar liberação de estoque no Protheus do pedido de venda
			  		N: Realizar a Transmitição das Notas Fiscais de Saida a Sefaz 
			  		O: Realizar o Reenvio de Pedido com erro de WS
			  		P: Realizar a confirmação da entrada do saldo físico na FEDEX
			  		Q: Realizar a concilação entre o saldo físico e o lógico
			  		R: Força o envio da NF em paralelo ao Picking, somente filial 02
			  		S: Realizar tratamentos provisorios / HardCode
			  		T: Consultar no operador logistico se possui data e hora de Shipping
			  		U: Geração, envio e confirmação de arquivos CSV para doTerra
			  		V:
			  		X:
			  		Y:
			  		Z:
Retorno     : Nil
Objetivos   : Customização para processamento de integrações doTerra
Autor       : Jean Victor Rocha
Cliente		: doTerra
Data/Hora   : 18/10/2018
*/
*---------------------------------*
User Function N6FAT009(aParam,cOpc)
*---------------------------------*
Local i
Local aDefRot	:= {}
Local aFiliais	:= {}
Local aOpcoes	:= {}
Local aServers	:= {}
Local aAgFixos	:= {}
Local cFil		:= ""
Local cEmp		:= "N6"
Local cTime		:= Time()
Local cID		:= cValtoChar(Randomize( 1000, 9999 ))
Local lDebug	:= .F.//Utilizado para debugar (parametrizar no arquivo de parametros da rotina)
Local nPos		:= 0
Private lJob	:= Type('oMainWnd') != 'O'
Private aOpc		:= {}
Private aDiasAut	:= {}

DEFAULT cOpc := ""      
DEFAULT aParam := {}

//Carregamento dos dados de parametrização da customização.                          
aDefRot := ParamFile(cEmp)
If (nPos := aScan(aDefRot,{|x| x[1] == "FILIAIS"})) <> 0
	aFiliais := StrTokArr(aDefRot[nPos][2],",")
EndIf
If (nPos := aScan(aDefRot,{|x| x[1] == "DEBUG"})) <> 0
	lDebug := aDefRot[nPos][2] <> "0"
EndIf
If LEN(aParam) == 0 .and. (nPos := aScan(aDefRot,{|x| x[1] == "DELAY"})) <> 0 .and. IsNumeric(aDefRot[nPos][2]) 
	SLEEP(VAL(aDefRot[nPos][2]))
EndIf
If (nPos := aScan(aDefRot,{|x| x[1] == "OPCOES"})) <> 0
	aOpcoes := StrTokArr(aDefRot[nPos][2],",")
	For i:=1 to len(aOpcoes)
		aOpcoes[i] := StrTokArr(aOpcoes[i],":")
	Next i
EndIf
If (nPos := aScan(aDefRot,{|x| x[1] == "SERVERS"})) <> 0
	aServers := StrTokArr(aDefRot[nPos][2],",")
	For i:=1 to len(aServers)
		aServers[i] := StrTokArr(aServers[i],":")
		aServers[i][2] := VAL(aServers[i][2])
	Next i
EndIf
If (nPos := aScan(aDefRot,{|x| x[1] == "AGENDAMENTOS_FIXOS"})) <> 0
	aAgFixos := StrTokArr(aDefRot[nPos][2],",")
	For i:=1 to len(aAgFixos)
		aAgFixos[i] := StrTokArr(aAgFixos[i],":")
		aAgFixos[i][2] := StrTokArr(aAgFixos[i][2],"-")
	Next i
EndIf
If (nPos := aScan(aDefRot,{|x| x[1] == "DIAS_AUTORIZADOS"})) <> 0
	aDiasAut := StrTokArr(aDefRot[nPos][2],",")
	For i:=1 to len(aDiasAut)
		aDiasAut[i] := StrTokArr(aDiasAut[i],":")
		aDiasAut[i][2] := StrTokArr(aDiasAut[i][2],"-")
	Next i
EndIf

//Tratamento para Rotina JOB (apenas JOB implementado)
If !lJob
	cEmp := cEmpAnt
	cFil := cFilAnt
ElseIf LEN(aParam) == 0//Tratamento para chamada inicial
	For i:=1 to Len(aFiliais)
		cFil := aFiliais[i]
		If lDebug
			U_N6FAT009({cEmp,cFil},)
		Else
			StartJob("U_N6FAT009", GetEnvServer() , .F.,{cEmp,cFil},)
		EndIf
	Next i
	Return .T.
Else
	cEmp := aParam[1]
	cFil := aParam[2]
EndIf

//Caso tiver o cOpc preenchido, considera que já foi realizado a verificação de opção já em execução.
If cOpc == ""
	//Define as opções disponiveis por filial
	aOpc := {}
	If (nPos := aScan(aOpcoes,{|X| X[1] == cFil})) <> 0
		For i:=1 to len(aOpcoes[nPos][2])
			aAdd(aOpc,SUBSTR(aOpcoes[nPos][2],i,1))
		Next i
	EndIf
	If Len(aOpc) <> 0
		aEmExec := InExecOpc(aServers)
		//Verifica se já não existe outra instancia em execução para a opção desejada
		For i:=1 to LEN(aOpc)
			If Len(aEmExec) == 0 .or. aScan(aEmExec ,{|X| UPPER(ALLTRIM(X)) == +cFil+aOpc[i] }) == 0
				If lDebug
					U_N6FAT009({cEmp,cFil},aOpc[i])
				Else
					StartJob("U_N6FAT009     "+cFil+aOpc[i], GetEnvServer() , .F.,{cEmp,cFil},aOpc[i])
				EndIf
			EndIf
		Next i
	EndIf
Else
	If !lJob .and. LEN(aParam) == 0
		aParam[1] := cEmp
		aParam[2] := cFil
	EndIf
	If AgendLib(aParam,cOpc,aAgFixos)
		MainN6(aParam,cOpc)
	EndIf
EndIf
                
If !EMPTY(cOpc)
	conout("## N6FAT009 ("+cID+") - FIM: cOpc="+cFil+cOpc+" | processamento="+ElapTime(cTime,Time()))
EndIf

Return .T.

/*
Funcao      : InExecOpc
Parametros  : 
Retorno     : 
Objetivos   : Retorna as opções já em execução, para não ser exeutado multiplas vezes
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function InExecOpc(aServers)
*---------------------------------*
Local aRet := {}
Local aUsersLog := usrarray(aServers)
Local aTmp := aclone(GetUserInfoArray())

For i:=1 to Len(aTmp)
	aadd(aUsersLog,aTmp[i])
Next i

If VALTYPE(aUsersLog) == "A"
	While LEN(aUsersLog)>0 .and. (nPos := aScan(aUsersLog ,{|X| UPPER(LEFT(X[5],10)) == "U_N6FAT009" })) <> 0
		If LEN(aUsersLog[nPos][5]) > 10
			aAdd(aRet,RIGHT(aUsersLog[nPos][5],3))
		EndIf
		aDEL(aUsersLog,nPos)
		aSize(aUsersLog,Len(aUsersLog)-1)
	EndDo
EndIf
Return aRet

/*
Funcao      : MainN6
Parametros  : 
Retorno     : 
Objetivos   : Função principal
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function MainN6(aParam,cOpc)
*---------------------------------*
Local cFil		:= ""
Local cEmp		:= ""
Local cDir		:= ""
Local cUpd		:= ""
Private lJob	:= Type('oMainWnd') != 'O'
Private cFtpOL	:= ""
Private cLoginOL:= ""
Private cPassOL	:= ""
Private cFtpCLI	:= ""
Private cLoginCLI:= ""
Private cPassCLI:= ""
Private cExtZIP	:= ".zip"
Private cExtPDF	:= ".pdf"
Private cExtXML	:= ".xml"
Private cExtCSV	:= ".csv"

DEFAULT cOpc	:= ""
DEFAULT aParam	:= {}
DEFAULT aOpc	:= {}

//apenas JOB implementado
cEmp := aParam[1]
cFil := aParam[2]

//Valida se a empresa logada informada é doTerra
If !(cEmp $ 'N6')
	SendMessage('Empresa nao autorizada.',lJob)
	Return
EndIf

//Abre o ambiente Protheus (simular)
If lJob
	RPCSetType(3)
	RpcSetEnv(cEmp, cFil, "", "", 'FAT')
EndIf

If !DiaAut(aParam,cOpc,aDiasAut)
	SendMessage('Dia Não Autorizado para a opção informada',lJob)
	Return
EndIf

cFtpOL		:= Alltrim(GETMV("MV_P_00123",,"sftp1.rapidaocometa.com.br"))
cLoginOL	:= Alltrim(GETMV("MV_P_00124",,"doterra"))
cPassOL		:= Alltrim(GETMV("MV_P_00125",,"DOter22092"))

cFtpCLI		:= Alltrim(GETMV("MV_P_00126",,"upload.doterra.com"))
cLoginCLI	:= Alltrim(GETMV("MV_P_00127",,"bra_totvs"))
cPassCLI	:= Alltrim(GETMV("MV_P_00128",,"aM%%40ELc7C"))

//Verifica se estrutura dos diretorios estão ok, caso contrario os cria.
cDir := "\FTP\"+cEmpAnt+"\DANFE"
ChkDir(cDir)
cDir += "\"
ChkDir(cDir+"BAT_TEMP\")//Pasta temporaria para processamento de scripts e/ou arquivos temporarios.
ChkDir(cDir+"ZIP_A_CONFIRMAR\")//Pasta com os arquivos ZIP, só serão excluidos apos a confirmação no SFTP
ChkDir(cDir+"2DOTERRA\")//Pasta com os arquivos PDF E XML que serão enviados a doTerra, só serão excluidos apos a confirmação no SFTP

DO CASE                          
	CASE "A" == cOpc
		//Incluir Pedido do cliente na tabela de rastreio, Caso o pedido não foi incluido no inicio do Processamento (integração automatica Datatrax)
		InsertZX6()

		//Checagem de status do pedido no Protheus, em casos em que o pedido é excluido.
		ChkPV()
		
		//Buscar dados de NFs caso exista para os Pedidos da ZX6
		ChkNF()
	CASE "B" == cOpc
		//Gerar arquivos PDF e XML
		createFiles(cDir)
	CASE "C" == cOpc
		//Validar arquivos Gerados PDF e XML
		ValidFiles(cDir)
	CASE "D" == cOpc
		//Comprimir arquivos PDF e XML e gerar o ZIP
		ZipFiles(cDir)
	CASE "E" == cOpc
		//Enviar arquivos ao SFTP
		SendSFTPFiles(cDir)
	CASE "F" == cOpc
		//Confirmar recebimento do arquivo no SFTP
		ConfirmFiles(cDir)
	CASE "G" == cOpc
		//Confirmar arquivos a serem enviados a doterra
		FiledoTerra(cDir)
	CASE "H" == cOpc
		//Enviar arquivos para SFTP doTerra
		EnvdoTerra(cDir)
	CASE "I" == cOpc
		//Confirmar arquivos para SFTP doTerra
		ConfdoTerra(cDir)
	CASE "J" == cOpc
		//Realizar a integração de pedidos Datatrax >> Protheus 
		U_N6WS007({cEmp,cFil})
		Sleep(2000)//Pausa para finalizar scripts ainda em execução
	CASE "K" == cOpc
		//Realizar a confirmação do picking físico na FEDEX
		U_N6WS005({cEmp,cFil})
		//GetPick({cEmp,cFil})//U_N6WS005({cEmp,cFil})//DESATIVADA, MIGRADO PARA CA.
	CASE "L" == cOpc
		//Como Existe muitos problemas de numeração de NF, por este motivo, incluimos sempre a atualização para a ultima NF emitida.
		cUpd := " Update SX5"+cEmp+"0 set 
		cUpd += "	X5_DESCRI =(Select MAX(F2_DOC) from SF2"+cEmp+"0 Where D_E_L_E_T_ <> '*' AND F2_SERIE='1' AND F2_FILIAL='"+cFil+"'),
		cUpd += " 	X5_DESCSPA=(Select MAX(F2_DOC) from SF2"+cEmp+"0 Where D_E_L_E_T_ <> '*' AND F2_SERIE='1' AND F2_FILIAL='"+cFil+"'),
		cUpd += "	X5_DESCENG=(Select MAX(F2_DOC) from SF2"+cEmp+"0 Where D_E_L_E_T_ <> '*' AND F2_SERIE='1' AND F2_FILIAL='"+cFil+"') 
		cUpd += " Where X5_TABELA = '01' AND X5_CHAVE='1' AND X5_FILIAL ='"+cFil+"' 
		TCSQLEXEC(cUpd)
        
		If aScan(aOpc,{|x| x == "S" }) <> 0	//Realizar tratamentos provisorios
			TratProv({cEmp,cFil})//Forçar tratamento provisorios, antes do faturamento.
        EndIf
                             
		//Realizar o Faturamento dos pedidos de vendas Doterra
		U_N6FAT001({cEmp,cFil})
	CASE "M" == cOpc
		//Realizar liberação de estoque no Protheus do pedido de venda
		LibEstoque({cEmp,cFil})	//U_N6WS010({cEmp,cFil})//DESATIVADA, MIGRADO PARA CA.
	CASE "N" == cOpc
		//Realizar a Transmitição das Notas Fiscais de Saida a Sefawz
		EnvNfSefaz({cEmp,cFil})//U_N6FAT002({cEmp,cFil}) //DESATIVADA, MIGRADO PARA CA.
	CASE CHR(79) == cOpc //"O" == cOpc
		//Realizar o Reenvio de Pedido com erro de WS		
		ReenvPick({cEmp,cFil})//U_N6WS009({cEmp,cFil}) //DESATIVADA, MIGRADO PARA CA.
	CASE "P" == cOpc
		//Realizar a confirmação da entrada do saldo físico na FEDEX
		U_N6WS002({cEmp,cFil}) 
	CASE "Q" == cOpc
		//Realizar a concilação entre o saldo físico e o lógico
		U_N6WS003({cEmp,cFil}) 
	CASE "R" == cOpc
		//Força o envio da NF em paralelo ao Picking, somente filial 02
		If cFil == "02"
			cUpd := " UPDATE "+RetSqlName("SC5")
			cUpd += " SET C5_P_STFED='03'
			cUpd += " WHERE D_E_L_E_T_<>'*'
			cUpd += "	AND C5_FILIAL='"+cFil+"'
			cUpd += "	AND C5_P_STFED='02'
			cUpd += "	AND C5_P_DTRAX in (Select ZX6_DTRAX 
			cUpd += " 						From "+RetSqlName("ZX6")
			cUpd += " 						Where D_E_L_E_T_ <> '*'
			cUpd += " 					   		AND ZX6_FILIAL='"+cFil+"'
			cUpd += " 							AND ZX6_DTENPK<>''
			cUpd += " 					   		AND ZX6_DTFAT=''
			cUpd += " 						GROUP BY ZX6_DTRAX)
			TCSQLEXEC(cUpd)
		EndIf
	CASE "S" == cOpc
		//Realizar tratamentos provisorios
		TratProv({cEmp,cFil}) 
	CASE "T" == cOpc	
		//Consultar no operador logistico se possui data e hora de Shipping
		CheckDtShip({cEmp,cFil})
	CASE "U" == cOpc
		//Geração, envio e confirmação de arquivos CSV para doTerra
		NewCSV(cDir,{cEmp,cFil})
		SendCSV(cDir,{cEmp,cFil})
		ConfirmCSV(cDir,{cEmp,cFil})

END

//Fecha ambiente Protheus
If lJob
	RpcClearEnv()
EndIf

Return .T.

/*
Funcao      : SendMessage
Parametros  : 
Retorno     : 
Objetivos   : Enviar mensagem na tela ou console
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function SendMessage(cMessage,lJob)
*----------------------------------------*
Default lJob := .F.
Return (If(lJob,ConOut(cMessage),MsgStop(cMessage)))

/*
Funcao      : ChkDir
Parametros  : 
Retorno     : 
Objetivos   : Verifica se o diretorio existe, caso contrario o cria.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function ChkDir(cDir)
*--------------------------*
Local i
Local aDir := StrTokArr(cDir,"\")
Local cTempDir := ""

For i:=1 to Len(aDir)
	cTempDir += "\"+aDir[i]
	If !ExistDir(cTempDir)
		MakeDir(cTempDir,,.F.)
	EndIf
Next i

Return .T.

/*
Funcao      : InsertZX6
Parametros  : 
Retorno     : 
Objetivos   : Incluir registros na tabela ZX6, quando não existir.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function InsertZX6()
*-------------------------*
Local cInsert := ""

cInsert := " INSERT INTO "+RETSQLNAME("ZX6")
cInsert += " SELECT SC5.C5_FILIAL,SC5.C5_P_DTRAX,SC5.C5_EMISSAO,SC5.C5_NUM,"//4
cInsert += "		'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','ENABLE','',"//48 campos
cInsert += " 		(SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM "+RETSQLNAME("ZX6")+")+(ROW_NUMBER() OVER(ORDER BY SC5.R_E_C_N_O_ ASC))
cInsert += " FROM "+RETSQLNAME("SC5")+" SC5
cInsert += " LEFT OUTER JOIN "+RETSQLNAME("ZX6")+" ZX6 on ZX6.D_E_L_E_T_ <> '*' AND SC5.C5_FILIAL+SC5.C5_P_DTRAX = ZX6_FILIAL+ZX6_DTRAX  
cInsert += " WHERE SC5.D_E_L_E_T_ <> '*' 
cInsert += " 	AND SC5.C5_P_DTRAX<>''
cInsert += " 	AND SC5.C5_TIPO = 'N'
cInsert += " 	AND ZX6.ZX6_DTRAX is null
cInsert += " 	AND SC5.C5_FILIAL ='"+xFilial("SC5")+"'
TCSQLEXEC(cInsert)

Return .T.

/*
Funcao      : ChkPV
Parametros  : 
Retorno     : 
Objetivos   : Buscar o status do pedido de venda no Protheus, em casos em que o Pedido é excluido no Protheus.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------*
Static Function ChkPV()
*---------------------*
Local cUpdate := ""

//Atualização ocorre somente quando o Pedido é excluido no Protheus
cUpdate := " UPDATE ZX6	
cUpdate += " 	SET ZX6.ZX6_SITUA = (CASE WHEN SC5.D_E_L_E_T_='' THEN 'ENABLE' ELSE 'DISABLE' END )
cUpdate += " FROM "+RETSQLNAME("ZX6")+" ZX6
cUpdate += " INNER JOIN "+RETSQLNAME("SC5")+" SC5 on SC5.C5_FILIAL =  ZX6.ZX6_FILIAL AND SC5.C5_P_DTRAX =  ZX6.ZX6_DTRAX
cUpdate += " LEFT OUTER JOIN "+RETSQLNAME("SF2")+" SF2 on SF2.D_E_L_E_T_<>'*' AND SF2.F2_FILIAL=ZX6.ZX6_FILIAL AND SF2.F2_DOC=SC5.C5_NOTA AND SF2.F2_SERIE=SC5.C5_SERIE
cUpdate += " Where ZX6.D_E_L_E_T_ <> '*' 
cUpdate += " 	AND SC5.D_E_L_E_T_ = '*' 
cUpdate += " 	AND SC5.C5_TIPO = 'N'
cUpdate += " 	AND ZX6.ZX6_SITUA <> (CASE WHEN SC5.D_E_L_E_T_='' THEN 'ENABLE' ELSE 'DISABLE' END )
cUpdate += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
cUpdate += " 	AND (SELECT count(*) AS QTDE FROM "+RETSQLNAME("SC5")+" WHERE D_E_L_E_T_<>'*' AND C5_FILIAL=ZX6.ZX6_FILIAL AND C5_P_DTRAX=ZX6.ZX6_DTRAX) = 0
TCSQLEXEC(cUpdate)                                    

Return .T.

/*
Funcao      : ChkNF
Parametros  : 
Retorno     : 
Objetivos   : Buscar dados de NFs para Pedidos no ZX6 que não estão com essa informação.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------*
Static Function ChkNF()
*---------------------*
Local cUpdate := ""

cUpdate := " Update ZX6	
cUpdate += " 	SET ZX6.ZX6_DOC = SC5.C5_NOTA,
cUpdate += " 		ZX6.ZX6_SERIE = SC5.C5_SERIE,
cUpdate += " 		ZX6.ZX6_DTATSF = ISNULL(SF2.F2_DAUTNFE,''),
cUpdate += " 		ZX6.ZX6_HRATSF = LEFT(ISNULL(SF2.F2_HAUTNFE,''),5)+CASE WHEN ISNULL(SF2.F2_HAUTNFE,'') <>'' THEN ':00' ELSE '' END
cUpdate += " From "+RETSQLNAME("ZX6")+" ZX6
cUpdate += " INNER JOIN "+RETSQLNAME("SC5")+" SC5 on SC5.C5_FILIAL =  ZX6.ZX6_FILIAL AND SC5.C5_P_DTRAX =  ZX6.ZX6_DTRAX
cUpdate += " LEFT OUTER JOIN "+RETSQLNAME("SF2")+" SF2 on SF2.D_E_L_E_T_ <> '*' AND SF2.F2_FILIAL = ZX6.ZX6_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE
cUpdate += " Where ZX6.D_E_L_E_T_ <> '*' 
cUpdate += " 	AND SC5.D_E_L_E_T_ <> '*' 
cUpdate += " 	AND SC5.C5_TIPO = 'N'
cUpdate += " 	AND SC5.C5_SERIE = '1'
cUpdate += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
TCSQLEXEC(cUpdate)

Return .T.

/*
Funcao      : createFiles
Parametros  : 
Retorno     : 
Objetivos   : Criar arquivos PDF e XML na pasta informada
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------*
Static Function createFiles(cDir)
*-------------------------------*
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_01"

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT ZX6.ZX6_FILIAL,ZX6.ZX6_DTRAX,ZX6.ZX6_NUM,ZX6.ZX6_EMISSA,ZX6.ZX6_DOC,ZX6.ZX6_SERIE,SF2.R_E_C_N_O_ RECSF2,ZX6.R_E_C_N_O_ RECZX6
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " LEFT OUTER JOIN "+RETSQLNAME("SF2")+" SF2 on SF2.F2_FILIAL = ZX6.ZX6_FILIAL AND SF2.F2_DOC = ZX6.ZX6_DOC AND SF2.F2_SERIE = ZX6.ZX6_SERIE
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND SF2.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> ''
cSql += " 	AND ZX6.ZX6_SERIE = '1'
cSql += " 	AND ZX6.ZX6_DTFILE = ''
cSql += " 	AND SF2.F2_CHVNFE <> ''
//cSql += " 	AND SF2.F2_DAUTNFE <> ''
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
cSql += " ORDER BY ZX6.ZX6_EMISSA DESC

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
//gerar arquivos.
If nRecCount > 0
	While (cAlias)->(!EOF())
  		GerarArquivo(cDir,(cAlias)->RECSF2,(cAlias)->RECZX6)
		InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Arquivos PDF/XML criados.","Criação arquivo DANFE")
  		(cAlias)->(DbSkip())
	EndDo
EndIf

Return .T.

/*
Funcao      : GerarArquivo
Parametros  : 
Retorno     : 
Objetivos   : Geração dos arquivos XML e PDF.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------------------------*
Static Function GerarArquivo(cDir,nRecSF2,nRecZX6,lPDF,lXML)
*----------------------------------------------------------*
Local cArquivo	:= "" 
Local oDanfe		:= Nil
Local aXml			:= {}             
Local aNotas		:= {}

Local cUpdate		:= ""
Local cErro			:= ""
Local cModel		:= '55'
Local cModalidade	:= "" 

Private cIdEnt 	:= RetIdEnti( .F. )

//Variaveis do fonte DANFEIII
Private PixelX		:= 0
Private PixelY		:= 0
Private nConsTex 	:= 0.56 // Constante para concertar o cálculo retornado pelo GetTextWidth.
Private nConsNeg 	:= 0.43 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.

Default lPDF := .T.
Default lXML := .T.

//Posiciona no SF2.
SF2->(DbSetOrder(1))
SF2->(DbGoTo(nRecSF2))

//Nome do arquivo
cArquivo	:= 'NF_'+AllTrim(SF2->F2_DOC)+AllTrim(SF2->F2_SERIE)

Begin Sequence
	If File(cDir+cArquivo+'.rel')
		FErase(cDir+cArquivo+'.rel')
	EndIf
	If lXML
		// ### Geração do arquivo .xml ###
		cModalidade := getCfgModalidade( @cErro , cIdEnt, cModel)				
		aadd(aNotas,{})
		aadd(Atail(aNotas),.F.)
		aadd(Atail(aNotas),"S")
		aadd(Atail(aNotas),SF2->F2_DTDIGIT)
		aadd(Atail(aNotas),SF2->F2_SERIE)
		aadd(Atail(aNotas),SF2->F2_DOC)
		aadd(Atail(aNotas),SF2->F2_CLIENTE)
		aadd(Atail(aNotas),SF2->F2_LOJA)
		aXml := GetXML(cIdEnt ,aNotas ,@cModalidade)
	
		If Empty(aXml[1][2])
			SendMessage("Nao foi possivel buscar xml para nota fiscal."+SF2->F2_DOC,lJob)
			Break
		EndIf                                 
	
		If File(cDir+cArquivo+cExtXML)
			FErase(cDir+cArquivo+cExtXML)
		EndIf     
	
		MemoWrit(cDir+cArquivo+cExtXML,aXml[1][2])
	
		If !File(cDir+cArquivo+cExtXML)
			SendMessage('Nao foi possivel gravar no Protheus arquivo xml ('+cDir+cArquivo+cExtXML+') . Nota fiscal '+SF2->F2_DOC,lJob)
			Break
		EndIf 
	EndIf
	If lPDF	
		If File(cDir+cArquivo+cExtPDF)
			FErase(cDir+cArquivo+cExtPDF)
		EndIf 

		//Posiciona no SF2. (reposiciona novamente pois a função de XML pode desposicionar.)
		SF2->(DbSetOrder(1))
		SF2->(DbGoTo(nRecSF2))
		// ### Geração do arquivo .pdf ###
		oDanfe := FWMSPrinter():New(cArquivo,IMP_PDF,.F.,,.T.)
		oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
		oDanfe:SetPortrait()//retrato
		//oDanfe:SetLandscape()//Paisagem
		oDanfe:SetPaperSize(DMPAPER_A4)
		oDanfe:SetMargin(60,60,60,60)
		oDanfe:cPathPDF := cDir
		oDanfe:SetViewPDF(.F.)     
		oDanfe:nDevice := IMP_PDF                                                         
		oDanfe:lServer := .T.
		oDanfe:lInJob := .T.
	
		MV_PAR01 := SF2->F2_DOC 
		MV_PAR02 := SF2->F2_DOC
		MV_PAR03 := SF2->F2_SERIE
		MV_PAR04 := 2// [Operacao] NF de Saida
		MV_PAR05 := 1// [Frente e Verso] Sim
		MV_PAR06 := 2// [DANFE simplificado] Nao 
	
		PixelX := odanfe:nLogPixelX()
		PixelY := odanfe:nLogPixelY()
	
		//StaticCall(DANFEIII,DANFEProc,@oDanfe, .F. , cIDEnt, Nil, Nil, .F. /*@lExistNFe*/, .F. /*lIsLoja */)//Paisagem
		U_PrtNfeSef(cIdEnt,/*cVal1*/,/*cVal2*/,@oDanfe,/*oSetup*/,/*cFilePrint*/,/*lIsLoja*/,/*lView*/,.T. /*lCallExt*/)//Retrato
		oDanfe:Print()

		FreeObj(oDanfe)
		oDanfe := nil 
	
		If !File(cDir+cArquivo+cExtpdf)
			SendMessage("Nao foi possivel gerar pdf ( Danfe ) para a nota fiscal "+SF2->F2_DOC+SF2->F2_SERIE,lJob)
			Break
		EndIf
	EndIf
	Sleep(1000)	
End Sequence

If lPDF .and. lXML//quando for processado apenas um arquivo, entende que é processamento auxiliar.
	//Grava a Data e hora da geração dos arquivos.
	cUpdate := " Update "+RETSQLNAME("ZX6")
	cUpdate += " 	SET ZX6_DTFILE = '"+DTOS(date())+"'"
	cUpdate += " 		,ZX6_HRFILE = '"+LEFT(Time(),8)+"'
	cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR(nRecZX6))
	TCSQLEXEC(cUpdate)
EndIf

//Apaga o arquivo temporario da geração da DANFE
If File(cDir+cArquivo+'.rel')
	FErase(cDir+cArquivo+'.rel')
EndIf
If File('\RELATO\'+cArquivo+'.rel')
	FErase('\RELATO\'+cArquivo+'.rel')
EndIf
	
Return .T.

/*
Funcao      : GetXML
Parametros  : 
Retorno     : 
Objetivos   : Função auxiliar para geração do XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------------------*
Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  
*-----------------------------------------------*
Local aRetorno		:= {}
Local aDados		:= {}
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"
Local nZ			:= 0
Local nCount		:= 0
Local oWS

If Empty(cModalidade)    
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo    := cModel 
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf  
EndIf  
         
oWs := nil
For nZ := 1 To len(aIdNfe) 
	nCount++
	aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
	If ( nCount == 10 )
		delClassIntF()
		nCount := 0
	EndIf
	aAdd(aRetorno,aDados)
Next nZ

Return(aRetorno)

/*
Funcao      : ExecuteRetorna
Parametros  : 
Retorno     : 
Objetivos   : Função auxiliar para geração do XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------------*
Static Function ExecuteRetorna(aNfe,cIdEnt,lUsacolab)
*---------------------------------------------------*
Local aExecute		:= {}  
Local aFalta		:= {}
Local aResposta		:= {}
Local aRetorno		:= {}
Local aDados		:= {} 
Local aIdNfe		:= {}
Local cAviso		:= "" 
Local cDHRecbto		:= ""
Local cDtHrRec		:= ""
Local cDtHrRec1		:= ""
Local cErro			:= "" 
Local cModTrans		:= ""
Local cProtDPEC		:= ""
Local cProtocolo	:= ""
Local cMsgNFE		:= ""
Local cRetDPEC		:= ""
Local cRetorno		:= ""
Local cCodRetNFE	:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"
Local cCab1			:= ""
Local cRodap		:= ""
Local cVerNfe		:= ""
Local dDtRecib		:= CToD("")
Local lFlag			:= .T.
Local nDtHrRec1		:= 0
Local nL			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nCount		:= 0
Local nLenNFe
Local nLenWS
Local oWS

Private oDHRecbto
Private oNFeRet
Private oDoc

Default lUsacolab	:= .F.

aAdd(aIdNfe,aNfe)

If !lUsacolab
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()  

	aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})

	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]

	If oWS:RETORNANOTASNX()
		If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
			For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
				cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
				cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO								
				cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
				oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
				cModTrans		  := IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
				If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
					cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
					cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
				EndIf

				//Tratamento para gravar a hora da transmissao da NFe
				If !Empty(cProtocolo)
					oDHRecbto		:= XmlParser(cDHRecbto,"","","")
					cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
					nDtHrRec1		:= RAT("T",cDtHrRec)

					If nDtHrRec1 <> 0
						cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
						dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
					EndIf
					AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
				EndIf

				nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})

				oWS:cIdInicial    := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				oWS:cIdFinal      := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				If oWS:MONITORFAIXA()
					cCodRetNFE := oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CCODRETNFE
					cMsgNFE	:= oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE
				EndIf
				//RRP - 04/07/2018 - Ajuste no layout do XML exportado
				cVerNfe := IIf(Type("oNFeRet:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oNFeRet:_NFE:_INFNFE:_VERSAO:TEXT, '')
				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
				Do Case
					Case cVerNfe <= "1.07"
						cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
					Case cVerNfe >= "2.00" .And. "cancNFe" $ cRetorno
						cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
					OtherWise
						cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
				EndCase
				cRodap := '</nfeProc>'
				cRetorno:= AllTrim(cCab1)+AllTrim(cRetorno)+Alltrim(cDHRecbto)+AllTrim(cRodap) 

				If nY > 0
					aRetorno[nY][1] := cProtocolo
					aRetorno[nY][2] := cRetorno
					aRetorno[nY][4] := cRetDPEC
					aRetorno[nY][5] := cProtDPEC
					aRetorno[nY][6] := cDtHrRec1
					aRetorno[nY][7] := dDtRecib
					aRetorno[nY][8] := cModTrans
					aRetorno[nY][9] := cCodRetNFE
					aRetorno[nY][10]:= cMsgNFE
					//aadd(aResposta,aIdNfe[nY])
				EndIf
				cRetDPEC := ""
				cProtDPEC:= ""
			Next nX
		EndIf
	Else
		//Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	EndIf 
EndIf

oWS       := Nil
oDHRecbto := Nil
oNFeRet   := Nil

Return aRetorno[len(aRetorno)]

/*
Funcao      : atuSF2Hora
Parametros  : 
Retorno     : 
Objetivos   : Atualização da hora na tabela SF2
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static function atuSF2Hora(cDtHrRec,cSeek)
*----------------------------------------*
Local aArea := GetArea()

dbSelectArea("SF2")
dbSetOrder(1)
If MsSeek(xFilial("SF2")+cSeek)
	If SF2->(FieldPos("F2_HORA"))<>0 .And. ( Empty(SF2->F2_HORA) .Or. SF2->F2_HORA <> cDtHrRec )
		RecLock("SF2")
		SF2->F2_HORA := cDtHrRec
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*
Funcao      : ValidFiles
Parametros  : 
Retorno     : 
Objetivos   : Validação dos arquivos gerados (PDF e XML)
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static function ValidFiles(cDir)
*------------------------------*
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_02"
Local cUpdate	:= ""
Local cArquivo	:= ""
Local lFileOk	:= .T.

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT *
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> ''
cSql += " 	AND ZX6.ZX6_DTFILE <> ''
cSql += " 	AND ZX6.ZX6_DTFLOK = ''
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
  		cArquivo:= "NF_"+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)
  		lFileOk	:= .T.
  		If !File(cDir+cArquivo+cExtPDF) .or. ChkLenFile(cDir,cArquivo+cExtPDF) <= 10000 //Considera que o PDF tem que ser maior que 1Kb, para reprocessar paginas em branco
	  		lFileOk	:= .F.
	  		//Gravar Log de falha no PDF
  		EndIf
  		If !File(cDir+cArquivo+cExtXML) .or. ChkLenFile(cDir,cArquivo+cExtPDF) <= 100 //Considera que o XML tem que ser maior que 0.1Kb, para reprocessar arquivos corrompidos
	  		lFileOk	:= .F.
	  		//Gravar Log de falha no XML
  		EndIf
  		If lFileOk
	  		//Grava a Data e hora da confirmação da geração dos arquivos.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTFLOK = '"+DTOS(date())+"'"
			cUpdate += " 		,ZX6_HRFLOK = '"+LEFT(Time(),8)+"'
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Arquivos PDF/XML confirmados no Protheus.","Confirmação arquivo DANFE")
			
			TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='11' WHERE C5_NOTA='"+(cAlias)->ZX6_DOC+"' AND C5_SERIE='"+(cAlias)->ZX6_SERIE+"' AND C5_FILIAL='"+(cAlias)->ZX6_FILIAL+"' AND C5_P_DTRAX='"+(cAlias)->ZX6_DTRAX+"'")
    		TCSqlExec("UPDATE "+RetSqlName("SF2")+" SET F2_P_ENVD='1'   WHERE F2_DOC='"+(cAlias)->ZX6_DOC+"' AND F2_SERIE='"+(cAlias)->ZX6_SERIE+"' AND F2_FILIAL='"+(cAlias)->ZX6_FILIAL+"' ")
		Else
			//Limpa a geração dos arquivos para ser reprocessado.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTFILE = ''"
			cUpdate += " 		,ZX6_HRFILE = ''
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Enviado para reprocessar geração do PDF/XML, arquivos não localizado no Protheus.","Confirmação arquivo DANFE")
			
			//TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '12' WHERE C5_NOTA='"+(cAlias)->ZX6_DOC+"' AND C5_SERIE='"+(cAlias)->ZX6_SERIE+"' AND C5_FILIAL='"+(cAlias)->ZX6_FILIAL+"' AND C5_P_DTRAX='"+(cAlias)->ZX6_DTRAX+"'")
  		EndIf
  		(cAlias)->(DbSkip())
	EndDo
EndIf

Return .T.

/*
Funcao      : ChkLenFile
Parametros  : 
Retorno     : 
Objetivos   : Verifica o tamanho do arquivo fisico
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------------*
Static Function ChkLenFile(cDir,cFile) 
*------------------------------------*
Local nPos := 0 
Local aLista := DIRECTORY(cDir+ALLTRIM(cFile),,,.T.) 
Local nTam   := 0 

If (nPos := aScan(aLista,{|X| UPPER(Alltrim(X[1]))==UPPER(ALLTRIM(cFile)) }) ) > 0 
   nTam := aLista[nPos,2] 
EndIf 
Return nTam 

/*
Funcao      : ZIPFiles
Parametros  : 
Retorno     : 
Objetivos   : Compressão dos arquivos XML e PDF
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static function ZIPFiles(cDir)
*----------------------------*
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_03"
Local cUpdate	:= ""
Local cArquivo	:= ""

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT *
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> ''
cSql += " 	AND ZX6.ZX6_DTFILE <> ''
cSql += " 	AND ZX6.ZX6_DTFLOK <> ''
cSql += " 	AND ZX6.ZX6_DTZPOK = ''
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
  		cArquivo:= "NF_"+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)
  		If File(cDir+cArquivo+cExtPDF) .and. File(cDir+cArquivo+cExtXML)
  			//Apagar arquivo ZIP caso exista, para ser criado o novo
			If File(cDir+cArquivo+cExtZIP)
				fErase(cDir+cArquivo+cExtZIP)
			EndIf
			If File(cDir+"ZIP_A_CONFIRMAR\"+cArquivo+cExtZIP)
				fErase(cDir+"ZIP_A_CONFIRMAR\"+cArquivo+cExtZIP)
			EndIf

			//Realiza a Copia do arquivo para a pasta a ser enviado para SFTP doTerra
			//copy2doTerra(cDir,cArquivo+cExtpdf,cArquivo+cExtXML,cDir+"2DOTERRA\",(cAlias)->R_E_C_N_O_)

			//Comprimir os arquivos
			compacta(cDir+cArquivo+cExtXML,cDir+cArquivo+cExtZIP,.T.)
			compacta(cDir+cArquivo+cExtPDF,cDir+cArquivo+cExtZIP,.T.)

	  		//Grava a Data e hora da compressão dos arquivos.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTZPOK = '"+DTOS(date())+"'"
			cUpdate += " 		,ZX6_HRZPOK = '"+LEFT(Time(),8)+"'
			cUpdate += " 		,ZX6_FILE = '"+cArquivo+cExtZIP+"'
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Arquivos PDF/XML confirmados, gerado compressão dos arquivos.","Compressão arquivo DANFE")
		Else
			//Limpa a confirmação da geração dos arquivos para ser reprocessado.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTFLOK = ''"
			cUpdate += " 		,ZX6_HRFLOK = ''
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)

			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Enviado para reprocessar geração do PDF/XML, arquivos não localizado no Protheus para compressão.","Compressão arquivo DANFE")
  		EndIf
  		(cAlias)->(DbSkip())
	EndDo
EndIf

Sleep(1000)

Return .T.  
          
/*
Funcao      : SendSFTPFiles
Parametros  : 
Retorno     : 
Objetivos   : Compressão dos arquivos XML e PDF
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function SendSFTPFiles(cDir)
*---------------------------------*
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_04"
Local cUpdate	:= ""

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT *
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> ''
cSql += " 	AND ZX6.ZX6_DTFILE <> ''
cSql += " 	AND ZX6.ZX6_DTFLOK <> ''
cSql += " 	AND ZX6.ZX6_DTZPOK <> ''
cSql += " 	AND ZX6.ZX6_DTENFL = '' 
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
  		If File(cDir+(cAlias)->ZX6_FILE) .and. ChkLenFile(cDir,(cAlias)->ZX6_FILE) > 10000
			//Enviar o arquivo ZIP
			If SendSFTP(cDir,(cAlias)->ZX6_FILE)
				//Grava a Data e hora do envio dos arquivos ao SFTP.
				cUpdate := " Update "+RETSQLNAME("ZX6")
				cUpdate += " 	SET ZX6_DTENFL = '"+DTOS(date())+"'"
				cUpdate += " 		,ZX6_HRENFL = '"+LEFT(Time(),8)+"'
				cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
				TCSQLEXEC(cUpdate)

				InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Arquivo ZIP enviado na pasta Incoming do SFTP","Envio do ZIP")

				//Move o arquivo para Pasta de aguardando confirmação
				frename(cDir+(cAlias)->ZX6_FILE,cDir+"ZIP_A_CONFIRMAR\"+(cAlias)->ZX6_FILE,,.F.)
			Else
				//Gravar log de falha
			EndIf
		Else
			//Limpar os dados até o momento, para que possa ser reprocessado.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTFILE=''
			cUpdate += " 		,ZX6_HRFILE=''
			cUpdate += " 		,ZX6_DTFLOK = ''
			cUpdate += " 		,ZX6_HRFLOK = ''
			cUpdate += " 		,ZX6_DTZPOK = ''
			cUpdate += " 		,ZX6_HRZPOK = ''
			cUpdate += " 		,ZX6_DTINFL = ''
			cUpdate += " 		,ZX6_HRINFL = ''
			cUpdate += " 		,ZX6_DTOUFL = ''
			cUpdate += " 		,ZX6_HROUFL = ''
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
			
			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Enviado para reprocessar geração do ZIP, arquivo ZIP não localizado no Protheus para envio.","Envio do ZIP")
  		EndIf
  		(cAlias)->(DbSkip())
	EndDo
EndIf

Return .t.

/*
Funcao      : SendSFTP
Parametros  : 
Retorno     : 
Objetivos   : Conectar com o SFTP e realizar o envio do arquivo ZIP.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------*
Static Function SendSFTP(cDir,cArquivo)
*-------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cFileZIP	:= alltrim(cArquivo)
Local cNameFile	:= alltrim(STRTRAN(cArquivo,".zip",""))
Local cBatWscp	:= ""

//Definição da pasta do "script" temporario
cBatWscp := cDir+"BAT_TEMP\"+cNameFile+".bat"

If FILE(cBatWscp)
	fErase(cBatWscp)
EndIf

//Cria arquivo BAT para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1
	cMsg:="O bat "+cBatWscp+" nao pode ser criado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" ^'+CRLF
cCommand+= '  /log="D:\TOTVS12\P12_26\DATATRAX\LOG\fedex_%date:~10,4%%date:~4,2%%date:~7,2%.log" /ini=nul ^'+CRLF
cCommand+= '  /command ^'+CRLF
cCommand+= '    "open sftp://'+cLoginOL+':'+cPassOL+'@'+cFtpOL+'/ -certificate="*"" ^'+CRLF
cCommand+= '    "cd incoming" ^'+CRLF 	
cCommand+= '    "cd NFZIP " ^'+CRLF 	
cCommand+= '    "put '+cRootPath+cDir+cFileZIP+' " ^'+CRLF
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'set WINSCP_RESULT=%ERRORLEVEL%'+CRLF
cCommand+= 'if %WINSCP_RESULT% equ 0 ('+CRLF
cCommand+= '  echo Success'+CRLF
cCommand+= ') else ('+CRLF
cCommand+= '  echo Error'+CRLF
cCommand+= ')'+CRLF
cCommand+= CRLF
cCommand+= 'exit /b %WINSCP_RESULT%'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )
//lRet := shellExecute("Open", @cRootPath+cBatWscp , " /k dir", @cRootPath, 0 )
Sleep(500)

fErase(cBatWscp)//Apaga o BAT

Return lRet

/*
Funcao      : SendSFTP
Parametros  : 
Retorno     : 
Objetivos   : Confirmação de arquivos enviados ao SFTP
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static Function ConfirmFiles(cDir)
*--------------------------------*
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_05"
Local cUpdate	:= ""
Local lZIPOk	:= .F.

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT *
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> '' 
cSql += " 	AND ZX6.ZX6_DTFILE <> ''
cSql += " 	AND ZX6.ZX6_DTFLOK <> ''
cSql += " 	AND ZX6.ZX6_DTZPOK <> ''
cSql += " 	AND ZX6.ZX6_DTENFL <> ''
cSql += " 	AND (ZX6.ZX6_DTINFL = '' OR ZX6.ZX6_DTOUFL = '')
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
  		If ChkSFTPFILES(cDir,(cAlias)->ZX6_FILE,"outcoming")//Confirmar o envio dos arquivos ZIP
			//Grava a Data e hora da confirmação do SFTP Outcoming e incoming (quando confirmado no Out, já passou por In e FEDEX processou)
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTOUFL = '"+DTOS(date())+"'
			cUpdate += " 		,ZX6_HROUFL = '"+LEFT(Time(),8)+"'
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
			
			//Grava a Data e hora da confirmação do SFTP incoming(grava somente se não tiver confirmado anteriormente.(para não sobrescrever primeira confirmação.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTINFL = '"+DTOS(date())+"'
			cUpdate += " 		,ZX6_HRINFL = '"+LEFT(Time(),8)+"'
			cUpdate += " Where ZX6_DTINFL='' AND R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)

			lZIPOk := .T.

			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Arquivo confirmado na pasta Outcoming e Incoming do SFTP.","Confirmação ZIP enviado")
			
			//Apaga o Arquivo no SFTP (outcoming)
			DelSFTPFile(cDir,(cAlias)->ZX6_FILE,"outcoming")
		ElseIf ChkSFTPFILES(cDir,(cAlias)->ZX6_FILE,"incoming")//Confirmar o envio dos arquivos ZIP
			//Grava a Data e hora da confirmação do SFTP incoming
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTINFL = '"+DTOS(date())+"'
			cUpdate += " 		,ZX6_HRINFL = '"+LEFT(Time(),8)+"'
			cUpdate += " Where ZX6_DTINFL='' AND R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)

			lZIPOk := .T.            

			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Arquivo confirmado na pasta Incoming do SFTP.","Confirmação ZIP enviado")
		Else
			//Limpa o envio dos arquivos para ser reprocessado.
			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTENFL = ''"
			cUpdate += " 		,ZX6_HRENFL = ''
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)

			//Move o arquivo para a pasta principal.
			frename(cDir+"ZIP_A_CONFIRMAR\"+(cAlias)->ZX6_FILE,cDir+(cAlias)->ZX6_FILE,,.F.)

			InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Enviado para reprocessar envio do ZIP, arquivo não localizado na pasta Outcoming/Incoming do SFTP.","Confirmação ZIP enviado")
  		EndIf
  		
		//Apagar arquivo ZIP apos o envio
		If lZIPOk .and. File(cDir+"ZIP_A_CONFIRMAR\"+(cAlias)->ZX6_FILE)
			fErase(cDir+"ZIP_A_CONFIRMAR\"+(cAlias)->ZX6_FILE)
		EndIf

  		(cAlias)->(DbSkip())
	EndDo
EndIf

Return .t.
          
/*
Funcao      : ChkSFTPFILES
Parametros  : 
Retorno     : 
Objetivos   : Confirmação do arquivo nos SFTP
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------------------*
Static Function ChkSFTPFILES(cDir,cArquivo,cTipo)
*-----------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cFileZIP	:= alltrim(cArquivo)
Local cNameFile	:= alltrim(STRTRAN(cArquivo,".zip",""))
Local cBatWscp	:= ""

//Definição da pasta do "script" temporario
cDir += "BAT_TEMP\"
ChkDir(cDir)
cBatWscp := cDir+"CONFIRMAR_"+cNameFile+".bat"

If FILE(cBatWscp)
	fErase(cBatWscp)
EndIf

//Cria arquivo BAT para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1
	cMsg:="O bat "+cBatWscp+" nao pode ser criado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= 'set REMOTE_PATH=/'+cTipo+'/NFZIP/'+cFileZIP+CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" /command ^'+CRLF
cCommand+= '    "open sftp://'+cLoginOL+':'+cPassOL+'@'+cFtpOL+'/ -certificate="*"" ^'+CRLF
cCommand+= '    "stat %REMOTE_PATH%" ^'+CRLF 	
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'if %ERRORLEVEL% neq 0 goto error'+CRLF
cCommand+= CRLF
cCommand+= 'echo File %REMOTE_PATH% exists'+CRLF
cCommand+= 'echo '+cFileZIP+' > '+"D:\TOTVS12\P12_26"+cDir+cNameFile+'.OK'+CRLF
cCommand+= 'exit /b 0'+CRLF
cCommand+= CRLF
cCommand+= ':error'+CRLF
cCommand+= 'echo '+cFileZIP+' > '+"D:\TOTVS12\P12_26"+cDir+cNameFile+'.NOK'+CRLF
cCommand+= 'exit /b 1'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )
Sleep(500)

fErase(cBatWscp)//Apaga o BAT

//Apaga os arquivos de retorno de consultas.
If FILE(cDir+cNameFile+".OK")
	lRet := .T.
	fErase(cDir+cNameFile+".OK")
ElseIf FILE(cDir+cNameFile+".NOK")
	fErase(cDir+cNameFile+".NOK")
EndIf

Return lRet

/*
Funcao      : compacta
Parametros  : 
Retorno     : 
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri)
*--------------------------------------------------*
Local lRet		:= .F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := "C:\Program Files\WinRAR\"

Default lApagaOri := .T.

If lApagaOri
	cCommand	:= cPath+'WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Else
	cCommand 	:= cPath+'WinRAR.exe a -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
EndIf
lRet := WaitRunSrv(cCommand,@lWait,@cPath)

Return(lRet)

/*
Funcao      : InsertZX7
Parametros  : 
Retorno     : 
Objetivos   : Gravação do Log de movimentação
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------------------*
Static Function InsertZX7(cFil,cDtrax,cNum,cOcorr,cEtapa)
*-------------------------------------------------------*
Local cInsert := ""

If EMPTY(cFil) .or. EMPTY(cDtrax) .or. EMPTY(cNum)
	Return .F.
EndIf

cInsert := " INSERT INTO "+RETSQLNAME("ZX7") 
cInsert += " VALUES('"+LEFT(cFil	,TamSX3("ZX7_FILIAL")[1])+"',
cInsert += " 		'"+LEFT(cDtrax	,TamSX3("ZX7_DTRAX")[1])+"',
cInsert += " 		'"+LEFT(cNum	,TamSX3("ZX7_NUM")[1])+"',
cInsert += " 		(SELECT ISNULL(MAX(ZX7_SEQ),0)+1 FROM "+RETSQLNAME("ZX7")+" WHERE ZX7_DTRAX = '"+LEFT(cDtrax,TamSX3("ZX7_DTRAX")[1])+"'),
cInsert += " 		'"+DTOS(date())+"',
cInsert += " 		'"+LEFT(Time()	,8)+"',
cInsert += " 		'"+LEFT(cOcorr	,TamSX3("ZX7_OCORR")[1])+"',
cInsert += " 		'"+LEFT(cEtapa	,TamSX3("ZX7_ETAPA")[1])+"',
cInsert += " 		'',
cInsert += " 		(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM "+RETSQLNAME("ZX7")+"))
TCSQLEXEC(cInsert)

Return .T.

/*
Funcao      : DelSFTPFile
Parametros  : 
Retorno     : 
Objetivos   : Apaga o arquivo no SFTP
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------------------*
Static Function DelSFTPFile(cDir,cArquivo,cFolderSFTP)
*----------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cFileZIP	:= alltrim(cArquivo)
Local cNameFile	:= alltrim(STRTRAN(cArquivo,".zip",""))
Local cBatWscp	:= ""

//Definição da pasta do "script" temporario
cDir += "BAT_TEMP\"
ChkDir(cDir)
cBatWscp := cDir+"APAGAR_"+cNameFile+".bat"

If FILE(cBatWscp)
	fErase(cBatWscp)
EndIf

//Cria arquivo BAT para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1// Testa se o arquivo foi gerado 
	cMsg:="O bat "+cBatWscp+" nao pode ser criado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= 'set REMOTE_PATH=/'+cFolderSFTP+'/NFZIP/'+cFileZIP+CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" /command ^'+CRLF
cCommand+= '    "open sftp://'+cLoginOL+':'+cPassOL+'@'+cFtpOL+'/ -certificate="*"" ^'+CRLF
cCommand+= '    "rm %REMOTE_PATH%" ^'+CRLF 	
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'exit /b 0'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )
Sleep(500)

fErase(cBatWscp)//Apaga o BAT

Return lRet

/*
Funcao      : usrarray
Parametros  : 
Retorno     : 
Objetivos   : Retorna todas as conexões ativas no sistema
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------------------------*
Static Function usrarray(aServers,cAmb,cEmpAnt,cfilAtu)
*-----------------------------------------------------*
local oSrv		:= nil
local aUsers	:= {}
local i			:= 0
local y			:= 0
local aTmp		:= {}

DEFAULT cAmb	:= "P12_26"
DEFAULT cEmpAnt := "N6"
DEFAULT cfilAtu := "01"

//Assim que possivel, incluir um tratamento para que seja possivel parametrizar estas informações, e não deixar hardcode.

// neste caso, quero apenas o balance, que me retorna todos os slaves conectados.
//aadd(aServers, {"10.0.30.4", 1024})//tcp
//aadd(aServers, {"10.0.30.4", 5063})//P11-40
//aadd(aServers, {"10.0.30.4", 5064})//P11-41
//aadd(aServers, {"10.0.30.4", 5065})//P11-42

For i := 1 to len(aServers)
     // conecta no slave via rpc
     oSrv := rpcconnect(aServers[i,1], aServers[i,2], cAmb, cEmpAnt,cfilAtu)
     If valtype(oSrv) == "O"
          oSrv:callproc("RPCSetType", 3)
          // chama a funcao remotamente no server, retornando a lista de usuarios conectados
          aTmp := oSrv:callproc("GetUserInfoArray")
          For y:=1 to len(aTmp)
	          aadd(aUsers, aclone(aTmp[y]))
          Next y
          aTmp := nil
          // limpa o ambiente
          oSrv:callproc("RpcClearEnv")
          // fecha a conexao
          rpcdisconnect(oSrv)
     //Else
     //     return "Falha ao obter a lista de usuarios."
     EndIf
Next i

Return aUsers

/*
Funcao      : copy2doTerra
Parametros  : 
Retorno     : 
Objetivos   : Realiza a Copia do arquivo para a pasta a ser enviado para SFTP doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------------------*
Static Function copy2doTerra(cDirOri,cPDF,cXML,cDirDest,nRecZX6)
*--------------------------------------------------------------*
Local cUpdate := ""

//Apaga o arquivo no destino, caso já exista.
If File(cDirDest+cPDF)
	FErase(cDirDest+cPDF)
EndIf
//If File(cDirDest+cXML)
//	FErase(cDirDest+cXML)
//EndIf

__CopyFile(cDirOri+cPDF, cDirDest+cPDF)
//__CopyFile(cDirOri+cDirDest+cXML, cDirDest+cDirDest+cXML)

cUpdate := " Update "+RETSQLNAME("ZX6")
cUpdate += " 	SET ZX6_DTFLCL = '"+DTOS(date())+"'
cUpdate += " 		,ZX6_HRFLCL = '"+LEFT(Time(),8)+"'
cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR(nRecZX6))
TCSQLEXEC(cUpdate)

Return .T. 

/*
Funcao      : EnvdoTerra
Parametros  : 
Retorno     : 
Objetivos   : Realiza o envio do arquivo para o SFTP doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function EnvdoTerra(cDir)
*------------------------------*
Local cUpdate := ""
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_06"
Local cUpdate	:= ""
Local lZIPOk	:= .F.
Local cNameFile	:= ""

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT *
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> '' 
If xFilial("SC5")<>'01'
	cSql += " 	AND ZX6.ZX6_DTFILE <> ''
	cSql += " 	AND ZX6.ZX6_DTFLOK <> ''
EndIf
cSql += " 	AND ZX6.ZX6_DTFLCL <> ''
cSql += " 	AND ZX6.ZX6_DTENCL = ''
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
		cNameFile := "NF_"+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)
 		If FILE(cDir+"2DOTERRA\"+cNameFile+cExtPDF) .and. ChkLenFile(cDir+"2DOTERRA\",cNameFile+cExtPDF) > 10000
 			If SendSFTPdoTerra(cDir,(cAlias)->ZX6_FILIAL,'NF_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE),.T.)
				//Gravação do Rastreio para envio do arquivo para SFTP doterra 		
	 			cUpdate := " Update "+RETSQLNAME("ZX6")
				cUpdate += " 	SET ZX6_DTENCL = '"+DTOS(date())+"'
				cUpdate += " 		,ZX6_HRENCL = '"+LEFT(Time(),8)+"'
				cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
				TCSQLEXEC(cUpdate)
			EndIf
		Else
			//reenvia para reprocessamento dos arquivos para a doterra
 			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTFLCL = ''
			cUpdate += " 		,ZX6_HRFLCL = ''
			cUpdate += " 		,ZX6_DTENCL = ''
			cUpdate += " 		,ZX6_HRENCL = ''
			cUpdate += " 		,ZX6_DTOKCL = ''
			cUpdate += " 		,ZX6_HROKCL = ''
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
		EndIf
 		(cAlias)->(DBSKIP())
	EndDo
EndIf

Return .T.

/*
Funcao      : SendSFTPdoTerra
Parametros  : 
Retorno     : 
Objetivos   : Conectar com o SFTP doTerra e realizar o envio dos arquivos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------------------------*
Static Function SendSFTPdoTerra(cDir,cFilArq,cNameFile,lPDF)
*----------------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cBatWscp	:= ""

DEFAULT lPDF := .T.

//Definição da pasta do "script" temporario
cBatWscp := cDir+"BAT_TEMP\SFTP_SEND_DOTERRA_"+cNameFile+".bat"

If FILE(cBatWscp)
	fErase(cBatWscp)
EndIf

//Cria arquivo BAT para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1
	cMsg:="O bat "+cBatWscp+" nao pode ser criado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" ^'+CRLF
cCommand+= '  /log="D:\TOTVS12\P12_26\DATATRAX\LOG\fedex_%date:~10,4%%date:~4,2%%date:~7,2%.log" /ini=nul ^'+CRLF
cCommand+= '  /command ^'+CRLF
cCommand+= '    "open sftp://'+cLoginCLI+':'+cPassCLI+'@'+cFtpCLI+'/ -certificate="*"" ^'+CRLF
cCommand+= '    "cd nf" ^'+CRLF 	
cCommand+= '    "cd '+cFilArq+' " ^'+CRLF
If lPDF
	cCommand+= '    "cd NFe" ^'+CRLF
	cCommand+= '    "put '+cRootPath+cDir+"2DOTERRA\"+cNameFile+cExtPDF+' " ^'+CRLF
Else
	cCommand+= '    "cd import" ^'+CRLF
	cCommand+= '    "put '+cRootPath+cDir+"2DOTERRA\"+cNameFile+cExtCSV+' " ^'+CRLF
EndIf
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'set WINSCP_RESULT=%ERRORLEVEL%'+CRLF
cCommand+= 'if %WINSCP_RESULT% equ 0 ('+CRLF
cCommand+= '  echo Success'+CRLF
cCommand+= ') else ('+CRLF
cCommand+= '  echo Error'+CRLF
cCommand+= ')'+CRLF
cCommand+= CRLF
cCommand+= 'exit /b %WINSCP_RESULT%'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )
Sleep(500)

fErase(cBatWscp)//Apaga o BAT

Return lRet

/*
Funcao      : ConfdoTerra
Parametros  : 
Retorno     : 
Objetivos   : Realiza a confirmação do arquivo no SFTP doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------*
Static Function ConfdoTerra(cDir)
*-------------------------------*
Local cUpdate := ""
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_07"
Local cUpdate	:= ""
Local lZIPOk	:= .F.

//Carregar registros não enviados. (com base no ZX6)
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT *
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> ''
cSql += " 	AND ZX6.ZX6_SERIE = '1'  
If xFilial("SC5")<>'01'
	cSql += " 	AND ZX6.ZX6_DTFILE <> ''
	cSql += " 	AND ZX6.ZX6_DTFLOK <> ''
EndIf
cSql += " 	AND ZX6.ZX6_DTFLCL <> ''
cSql += " 	AND ZX6.ZX6_DTENCL <> ''
cSql += " 	AND ZX6.ZX6_DTOKCL = ''
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
 		If ConfirmSFTPdoTerra(cDir,(cAlias)->ZX6_FILIAL,'nf_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE),cExtPDF) 
 				//.and. ConfirmSFTPdoTerra(cDir,(cAlias)->ZX6_FILIAL,'nf_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE),cExtXML)
			If File(cDir+"2DOTERRA\"+'NF_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)+cExtPDF)
				FErase(cDir+"2DOTERRA\"+'NF_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)+cExtPDF)
			EndIf
			//If File(cDir+"2DOTERRA\"+'NF_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)+cExtXML)
			//	FErase(cDir+"2DOTERRA\"+'NF_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)+cExtXML)
			//EndIf			
			
			//Gravação do Rastreio para Confirmação do arquivo no SFTP doterra 		
 			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTOKCL = '"+DTOS(date())+"'
			cUpdate += " 		,ZX6_HROKCL = '"+LEFT(Time(),8)+"'
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)
			
			TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='11' WHERE C5_NOTA='"+(cAlias)->ZX6_DOC+"' AND C5_SERIE='"+(cAlias)->ZX6_SERIE+"' AND C5_FILIAL='"+(cAlias)->ZX6_FILIAL+"' AND C5_P_DTRAX='"+(cAlias)->ZX6_DTRAX+"'")
    		TCSqlExec("UPDATE "+RetSqlName("SF2")+" SET F2_P_ENVD='1'   WHERE F2_DOC='"+(cAlias)->ZX6_DOC+"' AND F2_SERIE='"+(cAlias)->ZX6_SERIE+"' AND F2_FILIAL='"+(cAlias)->ZX6_FILIAL+"' ")
		Else
			//Reenvia para processamento do envio dos arquivos ao SFTP doTerra
 			cUpdate := " Update "+RETSQLNAME("ZX6")
			cUpdate += " 	SET ZX6_DTENCL = ''
			cUpdate += " 		,ZX6_HRENCL = ''
			cUpdate += " Where R_E_C_N_O_ = "+ALLTRIM(STR((cAlias)->R_E_C_N_O_))
			TCSQLEXEC(cUpdate)		
		EndIf
 		(cAlias)->(DBSKIP())
	EndDo
EndIf

Return .T.

/*
Funcao      : ConfirmSFTPdoTerra
Parametros  : 
Retorno     : 
Objetivos   : Confirmação do arquivo no SFTP doterra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------------------------*
Static Function ConfirmSFTPdoTerra(cDir,cFilArq,cNameFile,cExt)
*-------------------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cBatWscp	:= ""

//Definição da pasta do "script" temporario
cDir += "BAT_TEMP\"
ChkDir(cDir)
cBatWscp := cDir+"CONFIRMAR_ARQ_DOTERRA_"+cNameFile+".bat"

If FILE(cBatWscp)
	fErase(cBatWscp)
EndIf

//Cria arquivo BAT para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1
	cMsg:="O bat "+cBatWscp+" nao pode ser criado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= 'set REMOTE_PATH=/nf/'+cFilArq+'/'+IIF(cExt==".pdf",'NFe','import')+'/'+cNameFile+cExt+CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" /command ^'+CRLF
cCommand+= '    "open sftp://'+cLoginCLI+':'+cPassCLI+'@'+cFtpCLI+'/ -certificate="*"" ^'+CRLF
cCommand+= '    "stat %REMOTE_PATH%" ^'+CRLF 	
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'if %ERRORLEVEL% neq 0 goto error'+CRLF
cCommand+= CRLF
cCommand+= 'echo File %REMOTE_PATH% exists'+CRLF
cCommand+= 'echo '+cNameFile+' > '+"D:\TOTVS12\P12_26"+cDir+'DOTERRA_'+cNameFile+'.OK'+CRLF
cCommand+= 'exit /b 0'+CRLF
cCommand+= CRLF
cCommand+= ':error'+CRLF
cCommand+= 'echo '+cNameFile+' > '+"D:\TOTVS12\P12_26"+cDir+'DOTERRA_'+cNameFile+'.NOK'+CRLF
cCommand+= 'exit /b 1'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )
Sleep(500)

fErase(cBatWscp)//Apaga o BAT

//Apaga os arquivos de retorno de consultas.
If FILE(cDir+'DOTERRA_'+cNameFile+".OK")
	lRet := .T.
	fErase(cDir+'DOTERRA_'+cNameFile+".OK")
ElseIf FILE(cDir+'DOTERRA_'+cNameFile+".NOK")
	fErase(cDir+'DOTERRA_'+cNameFile+".NOK")
EndIf

Return lRet

/*
Funcao      : FiledoTerra
Parametros  : 
Retorno     : 
Objetivos   : Geração de arquivos para doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------*
Static Function FiledoTerra(cDir)
*-------------------------------*
Local cUpdate := ""
Local nRecCount	:= 0
Local cSql		:= ""
Local cAlias	:= "N6FAT009_08"
Local cUpdate	:= ""
Local lZIPOk	:= .F.
Local cArquivo	:= ""

//Carregar registros não gerados
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cSql := " SELECT ZX6.ZX6_FILIAL,ZX6.ZX6_DTRAX,ZX6.ZX6_NUM,ZX6.ZX6_EMISSA,ZX6.ZX6_DOC,ZX6.ZX6_SERIE,SF2.R_E_C_N_O_ RECSF2,ZX6.R_E_C_N_O_ RECZX6
cSql += " FROM "+RETSQLNAME("ZX6")+" ZX6
cSql += " LEFT OUTER JOIN "+RETSQLNAME("SF2")+" SF2 on SF2.F2_FILIAL = ZX6.ZX6_FILIAL AND SF2.F2_DOC = ZX6.ZX6_DOC AND SF2.F2_SERIE = ZX6.ZX6_SERIE
cSql += " WHERE ZX6.D_E_L_E_T_ <> '*'
cSql += " 	AND ZX6.ZX6_DOC <> '' 
cSql += " 	AND ZX6.ZX6_SERIE = '1'
If xFilial("SC5")<>'01'
	cSql += " 	AND ZX6.ZX6_DTFILE <> ''
	cSql += " 	AND ZX6.ZX6_DTFLOK <> ''
EndIf
cSql += " 	AND ZX6.ZX6_DTFLCL = ''
cSql += " 	AND ZX6.ZX6_FILIAL ='"+xFilial("SC5")+"'
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

Count to nRecCount
(cAlias)->(DbGoTop())
If nRecCount > 0
	While (cAlias)->(!EOF())
  		cArquivo := 'NF_'+AllTrim((cAlias)->ZX6_DOC)+AllTrim((cAlias)->ZX6_SERIE)
  		If !FILE(cDir+cArquivo+cExtpdf)
			fErase(cDir+cArquivo+cExtpdf)
		EndIf
		If !FILE(cDir+"2DOTERRA\"+cArquivo+cExtpdf)
	   		fErase(cDir+"2DOTERRA\"+cArquivo+cExtpdf)
	 	EndIf
	 	GerarArquivo(cDir,(cAlias)->RECSF2,(cAlias)->RECZX6,.T.,.F.)
	 	copy2doTerra(cDir,cArquivo+cExtpdf,cArquivo+cExtXML,cDir+"2DOTERRA\",(cAlias)->RECZX6)
		fErase(cDir+cArquivo+cExtpdf)
 		(cAlias)->(DBSKIP())
	EndDo
EndIf

Return .T.

/*
Funcao      : ParamFile
Parametros  : 
Retorno     : 
Objetivos   : Carrega as parametrizações para a rotina customizada
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static function ParamFile(cEmp)
*-----------------------------*
Local i
Local aConteudo	:= {}
Local oFile
Local cDir		:= "\system\"
Local cFileParam:= ""
Local cConteu	:= ""

DEFAULT cEmp := "N6"

cFileParam := cEmp+"_N6FAT009.PARAM"

//Verificar se arquivos existe, se sim
If File(cDir+cFileParam) .or. NewFileParam(cDir+cFileParam)
	oFile := FWFileReader():New(cDir+cFileParam)
	If (oFile:Open())
		aLinhas := oFile:getAllLines()
		oFile:Close()
	EndIf
EndIf

//Separar as informações
If Len(aLinhas) > 0
	For i:=1 to len(aLinhas)
		If LEFT(aLinhas[i],1) == "$"//Verifica se é parametro
			cAux := SUBSTR(aLinhas[i],2,LEN(aLinhas[i]))
			aAux := StrTokArr(cAux,"=")
			aAdd(aConteudo,aAux)
		EndIf
	Next i
EndIf

Return aConteudo

/*
Funcao      : NewFileParam
Parametros  : 
Retorno     : 
Objetivos   : Cria um arquivo modelo em caso que não o encontre
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function NewFileParam(cFile)
*---------------------------------*
Local lRet := .F.
Local cConteu := ""

//Definição do arquivo padrão
//Layout: TAG=CONTEUDO
cConteu += "$FILIAIS=01,02"+CRLF//Filiais que serão processadas. Ex: FILIAIS=01,02
cConteu += "$OPCOES=01:AGHIJLMN,02:ABCDEFGHIJKLMNOPQ"+CRLF//As opções que serão executadas por filial. Ex: OPCOES=01:ABC,02:ABC
cConteu += " *****************************************************************************************************"+CRLF
cConteu += " * Opções disponiveis:                                                                               *"+CRLF
cConteu += " *   A: Forçar a inclusão de pedidos na tabela de rastrio (desconsidera a gravação via integração FT)*"+CRLF
cConteu += " *   B: Gerar arquivos PDF e XML (somente filial 02)                                                 *"+CRLF
cConteu += " *   C: Validar arquivos Gerados PDF e XML (somente filial 02)                                       *"+CRLF
cConteu += " *   D: Comprimir arquivos PDF e XML e gerar o ZIP (somente filial 02)                               *"+CRLF
cConteu += " *   E: Enviar arquivos ao SFTP (somente filial 02)                                                  *"+CRLF
cConteu += " *   F: Confirmar recebimento do arquivo no SFTP (somente filial 02)                                 *"+CRLF
cConteu += " *   G: Confirmar arquivo PDF                                                                        *"+CRLF
cConteu += " *   H: Enviar PDF e XML para SFTP doTerra                                                           *"+CRLF
cConteu += " *   I: Confirmar PDF e XML para SFTP doTerra                                                        *"+CRLF
cConteu += " *   J: Realizar a integração de pedidos Datatrax >> Protheus                                        *"+CRLF
cConteu += " *   K: Realizar a confirmação do picking físico na FEDEX (consultar o WS deles)                     *"+CRLF
cConteu += " *   L: Realizar o Faturamento dos pedidos de vendas Doterra                                         *"+CRLF
cConteu += " *   M: Realizar liberação de estoque no Protheus do pedido de venda                                 *"+CRLF
cConteu += " *   N: Realizar a Transmitição das Notas Fiscais de Saida a Sefaz                                   *"+CRLF
cConteu += " *   O: Realizar o Reenvio de Pedido com erro de WS                                                  *"+CRLF
cConteu += " *   P: Realizar a confirmação da entrada do saldo físico na FEDEX                                   *"+CRLF
cConteu += " *   Q: Realizar a concilação entre o saldo físico e o lógico                                        *"+CRLF
cConteu += " *   R: Força o envio da NF em paralelo ao Picking, somente filial 02                                *"+CRLF
cConteu += " *   S: Realizar tratamentos provisorios / HardCode                                                  *"+CRLF
cConteu += " *   T: Consultar no operador logistico se possui data e hora de Shipping                            *"+CRLF
cConteu += " *   U: Geração, envio e confirmação de arquivos CSV para doTerra                                    *"+CRLF
cConteu += " *   V:                                                                                              *"+CRLF
cConteu += " *   X:                                                                                              *"+CRLF
cConteu += " *   Y:                                                                                              *"+CRLF
cConteu += " *   Z:                                                                                              *"+CRLF
cConteu += " *****************************************************************************************************"+CRLF
cConteu += "$DELAY=0"+CRLF//Caso seja necessario incluir algum delay entre uma execução e outra. Ex: DELAY=1000
cConteu += "$DEBUG=0"+CRLF//Parametro para informar se esta debugando ou não. Ex: DEBUG=0 // 0=Não;1=Sim
cConteu += "$SERVERS=10.0.30.4:1024,10.0.30.4:5063,10.0.30.4:5064,10.0.30.4:5065"+CRLF//Verifica os servidores que precisam ser avaliados na execução de uma nova thread. Ex: SERVERS=10.0.30.4:1024
	
nHdl := FCREATE(cFile,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1
	Return lRet
EndIf
fWrite(nHdl,cConteu)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := File(cFile)

Return lRet

/*
Funcao      : LibEstoque
Parametros  : 
Retorno     : 
Objetivos   : Realiza a liberação de estoque para o pedido e atualiza o Status do Pedido.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static Function LibEstoque(aParam)
*--------------------------------*
Local cAreaSC5     := "N6FAT009_09"
Local cSql         := ""
Local cData        := dtoc(ddatabase)
Local chora        := Time() 
Local cEmp         := aParam[ 01 ]
Local cFil		   := aParam[ 02 ] 
Local aPvlNfs 	   := {}
Local aBloqueio    := {}
Local aRet         := {}

If Select(cAreaSC5)>0
	(cAreaSC5)->(DbCloseArea())
EndIf
cSql := "SELECT C5_NUM,C5_P_CHAVE
cSql += " FROM "+retsqlname("SC5")
cSql += " WHERE C5_P_STFED = '' AND C5_P_DTFED = '' AND C5_P_CHAVE <> '' AND C5_FILIAL = '"+cFil+"' AND D_E_L_E_T_ = '' AND C5_P_STFED<>'91'
cSql += " ORDER BY R_E_C_N_O_ DESC
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cSql)), cAreaSC5, .F., .T.)

While !(cAreaSC5)->(Eof())
	aBloqueio	:={}
	aPvlNfs		:={}

	DbSelectArea("SC5")
	DbSetorder(1)
	SC5->(DbSeek(xFilial("SC5")+(cAreaSC5)->C5_NUM))
	aRet := U_RETSB2(SC5->C5_NUM,cfil,"2") 

	If LEN(aRet) == 0  
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)//Liberacao de pedido
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)//Checa itens liberados
		//Verificação de Saldo em Estoque (Rotina Padrão) 
		If Empty(aBloqueio) .And. !Empty(aPvlNfs) 
		    If cfil == "02"	
		  		//Envio do Picking list para a Fedex
	  			U_N6WS004((cAreaSC5)->C5_P_CHAVE)
		  	Else
	  			If aScan(aOpc,{|x| x == "S" }) <> 0	//Realizar tratamentos provisorios
					TratProv({cEmp,cFil})//Forçar tratamento provisorios, antes da liberação
		        EndIf
		   		TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='03',C5_P_DTFED='"+DTOS(ddatabase)+"' WHERE C5_P_CHAVE='"+(cAreaSC5)->C5_P_CHAVE+"' AND D_E_L_E_T_='' AND C5_FILIAL='"+cFil+"' AND C5_P_STFED<>'91'")
		  	EndIf
		EndIf
	EndIf
	(cAreaSC5)->(dbSkip())
Enddo
(cAreaSC5)->(DBCloseArea()) 	 	  

Return .T.

/*
Funcao      : ReenvPick
Parametros  : 
Retorno     : 
Objetivos   : Reenvia Picking para os que apresentaram problemas na comunicação/envio.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------*
Static Function ReenvPick(aParam) 
*-------------------------------*
Local cEmp		:= aParam[ 01 ]
Local cFil		:= aParam[ 02 ]	
Local cQry		:= ""
Local cAlias	:= "N6FAT009_10"

If Select(cAlias)>0
	(cAlias)->(DbCloseArea())
EndIf
cQry := "SELECT C5_P_CHAVE
cQry += " FROM "+RetSqlName("SC5")
cQry += " WHERE C5_P_STFED in ('05','01')
cQry += " 	AND C5_FILIAL = '"+cfil+"'" 
DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), cAlias, .F., .T.) 

While !(cAlias)->(Eof())
 	U_N6WS004((cAlias)->C5_P_CHAVE)
 	(cAlias)->(dbSkip())	 
Enddo
(cAlias)->(DbCloseArea())

Return .T.

/*
Funcao      : EnvNfSefaz
Parametros  : 
Retorno     : 
Objetivos   : Realizar o envio das NFS para SEFAZ
Autor       : Jean Victor Rocha
Data/Hora   : 
*/       
*--------------------------------*
Static Function EnvNfSefaz(aParam)                      
*--------------------------------*
Local cEmp		:= aParam[01]
Local cFil		:= aParam[02]
Local nCount	:= 0                                                           
Local cSql		:= ""
Local cAlias	:= "N6FAT009_11"
Local cUrl		:= Padr(GetNewPar("MV_SPEDURL",""), 250 )
Local cIdEnt 	:= RetIdEnti(.F.)
Local aRetorno

cSql := "SELECT SF3.F3_SERIE,SF3.F3_NFISCAL,COUNT( SF3.F3_SERIE) OVER (PARTITION BY 1) TOTREG, SC5.C5_P_DTRAX
cSql += " FROM "+RetSqlName('SF3')+" SF3
cSql += "	INNER JOIN "+RetSqlName('SC5')+" SC5 ON 	SC5.C5_FILIAL	= SF3.F3_FILIAL 
cSql += "											AND SC5.C5_NOTA		= SF3.F3_NFISCAL
cSql += "											AND SC5.C5_SERIE	= SF3.F3_SERIE
cSql += "											AND SC5.C5_CLIENTE	= SF3.F3_CLIEFOR
cSql += "											AND SC5.C5_LOJACLI	= SF3.F3_LOJA
cSql += "											AND SC5.D_E_L_E_T_	= ''
cSql += " WHERE SF3.F3_FILIAL = '"+cFil+"'
cSql += "		AND SF3.D_E_L_E_T_ <> '*'
cSql += "		AND (SF3.F3_CODRSEF > '102' OR SF3.F3_CODRSEF = '')
cSql += "		AND LEFT( SF3.F3_CFO,1 ) >= '5'
cSql += "		AND SF3.F3_ESPECIE IN ('SPED','NFE','NF')
cSql += "		AND SF3.F3_DTLANC = ''
cSql += "		AND SC5.C5_P_STFED<>'91' "//Status provisorio, para realizar algum tipo de ajuste e não transmitir automatico.
cSql += " GROUP BY SF3.F3_SERIE,SF3.F3_NFISCAL,SC5.C5_P_DTRAX

TCQuery cSql ALIAS (cAlias) NEW                                

While (cAlias)->(!Eof())
	aRetorno := getListBox(cIdEnt, cUrl, {(cAlias)->F3_SERIE,(cAlias)->F3_NFISCAL,(cAlias)->F3_NFISCAL}, 1, '55', .F., .T., .F., .F., .F.)
	If Valtype(aRetorno)==Nil  .Or. Len(aRetorno)==0 .Or. (Len( aRetorno )>0 .And. Empty(aRetorno[1][5])) //** Se ainda nao obteve aceite, faz tentativa de transmissao
		//U_EnvNfSef( (cAlias)->F3_NFISCAL, (cAlias)->F3_NFISCAL, (cAlias)->F3_SERIE, (cAlias)->C5_P_DTRAX)//N6FAT001
		TransNF(cFil, (cAlias)->F3_NFISCAL, (cAlias)->F3_NFISCAL, (cAlias)->F3_SERIE, (cAlias)->C5_P_DTRAX)
		//Gravação de LOG ZX2
		U_N6GEN002( "SF3"/*TABELA*/,"E"/*E=ENVIO/R=RETORNO*/,"N6FAT002"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,(cAlias)->F3_NFISCAL+(cAlias)->F3_SERIE/*CHAVE DE PESQUISA*/,;
					""/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,'Nota Fiscal Transmitida.' /*CAMPO OBS*/)						
		nCount += 1
	EndIf
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbCloseArea())

Return                                                                                 
                                
/*
Funcao      : getListBox
Parametros  : 
Retorno     : 
Objetivos   : Execução da opção de monitor SEFAZ
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------------------------------------------------------------*
static function getListBox(cIdEnt,cUrl,aParam,nTpMonitor,cModelo,lCte,lMsg,lMDfe,lTMS,lUsaColab)
*----------------------------------------------------------------------------------------------*
Local aLote			:= {}
Local aListBox		:= {}
Local aRetorno		:= {}
Local cId			:= ""
Local cProtocolo	:= ""
Local cRetCodNfe	:= ""
Local cAviso		:= ""
Local cSerie		:= ""
Local cNota			:= ""
Local nAmbiente		:= ""
Local nModalidade	:= ""
Local cRecomendacao	:= ""
Local cTempoDeEspera:= ""
Local nTempomedioSef:= ""
Local nX			:= 0
Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")

Default lUsaColab		:= .F.
Default lMsg			:= .T.
Default lCte			:= .F.
Default lMDfe			:= .F.
Default cModelo			:= IIf(lCte,"57",IIf(lMDfe,"58","55"))
Default lTMS			:= .F.

//If cModelo <> "65"
//	lUsaColab := UsaColaboracao( IIf(lCte,"2",IIf(lMDFe,"5","1")) )
//EndIf	
//If 	lUsaColab
//	aRetorno := colNfeMonProc( aParam, nTpMonitor, cModelo, lCte, @cAviso, lMDfe, lTMS ,lUsaColab )//processa monitoramento por tempo
//else
	aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)//processa monitoramento
//EndIf	

If empty(cAviso)
	For nX := 1 to len(aRetorno)
		cId				:= aRetorno[nX][1]
		cSerie			:= aRetorno[nX][2]
		cNota			:= aRetorno[nX][3]
		cProtocolo		:= aRetorno[nX][4]	
		cRetCodNfe		:= aRetorno[nX][5]
		nAmbiente		:= aRetorno[nX][7]
		nModalidade	    := aRetorno[nX][8]
		cRecomendacao	:= aRetorno[nX][9]
		cTempoDeEspera  := aRetorno[nX][10]
		nTempomedioSef  := aRetorno[nX][11]
		aLote			:= aRetorno[nX][12]

		aadd(aListBox,{	iif(empty(cProtocolo) .Or.  cRetCodNfe $ RetCodDene(),oNo,oOk),;
						cId,;
						if(nAmbiente == 1,"Produção","Homologação"),; //"Produção"###"Homologação"
						IIF(lUsaColab,iif(nModalidade==1,"Normal","Contingência"),IIf(nModalidade ==1 .Or. nModalidade == 4 .Or. nModalidade == 6,"Normal","Contingência")),; //"Normal"###"Contingência"								
						cProtocolo,;
						cRecomendacao,;
						cTempoDeEspera,;
						nTempoMedioSef,;	
						aLote})
	Next nX    
EndIf
    
Return aListBox

/*
Funcao      : TransNF
Parametros  : 
Retorno     : 
Objetivos   : Execução a transmissão da NF
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function TransNF(cFil,cNfIni,cNfFim,cSerieNf,cDtrax)
*---------------------------------------------------------*
Local cIdEnt
Local cErro
Local cModalidade
Local cAmbiente
Local cRet 		:= ""    
Local cModel 		:= '55'

Begin Sequence
	cIdEnt		:= RetIdEnti(.F.)         
	cErro		:= ""
	cModalidade	:= getCfgModalidade(@cErro, cIdEnt, cModel)				

	If !Empty(cErro)
		cRet := "Erro : nao foi possivel obter modalidade de transmissao." 
		Break
	EndIf

	cErro		:= ""
	cAmbiente	:= getCfgAmbiente(@cErro, cIdEnt, cModel)
	If !Empty(cErro)
		cRet := "Erro : nao foi possivel obter configuração do ambiente." 
		Break
	EndIf

	cErro		:= ""
	cVersao		:= getCfgVersao(@cErro, cIdEnt, cModel)
	If !Empty(cErro)
		cRet := "Erro : nao foi possivel obter versao da Nfe." 
		Break
	EndIf

	If Empty(cErro)
		//cRet := SpedNFeTrf('SF2',cSerieNF,cNfIni,cNfFim,cIdEnt,cAmbiente,cModalidade,cVersao,,.F.,.T.)
		//Parametros AutoNfeEnv : 
		//cEmpresa, 
		//cFilial, 
		//cEspera, 
		//cAmbiente (1=producao,2=Homologacao) Muito cuidado.
		//cSerie
		//cDoc.Inicial
		//cDoc.Final 
		AutoNfeEnv(cEmpAnt,cFil,"0",LEFT(cAmbiente,1),cSerieNF,cNfIni,cNfFim)
	EndIf
End Sequence

If !Empty(cErro)
	//Gravação de LOG ZX2
	U_N6GEN002("SF2"/*TABELA*/,"E"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,cNfIni + cSerieNF/*CHAVE DE PESQUISA*/,;
				""/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,cErro+"/"+cRet /*CAMPO OBS*/)

	//Atualização de Status 10= Erro transmissao
	TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='10' WHERE C5_P_DTRAX='"+cDtrax+"' AND C5_FILIAL='"+cFil+"'")
EndIf 

If !Empty(cRet)
	//Gravação de LOG ZX2
	U_N6GEN002("SF2"/*TABELA*/,"E"/*E=ENVIO/R=RETORNO*/,"N6FAT001"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,cNfIni + cSerieNF/*CHAVE DE PESQUISA*/,;
				cRet/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,cRet /*CAMPO OBS*/)

	//Atualização de Status 09 = transmitido			
	TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='09' WHERE C5_P_DTRAX='"+cDtrax+"' AND C5_FILIAL='"+cFil+"'")
EndIf

Return (cRet)

/*
Funcao      : GetPick
Parametros  : 
Retorno     : 
Objetivos   : realiza a busca do Picking de acordo com a ZX6
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function GetPick(aParam)
*-----------------------------*
Local cEmp			:= aParam[01]
Local cFil			:= aParam[02]
Local cSql			:= ""
Local cUpd			:= ""
Local cAlias		:= "N6FAT009_12"
Local cUrl			:= alltrim(getMV("MV_P_00116"))
Local cXml			:= ""
Local cHeadRet		:= ""
Local sPostRet		:= ""
Local oXml			:= ""
Local cRetorno		:= ""
Local cError		:= ""
Local cWarning		:= ""
Local aUser			:= &(getMV("MV_P_00117"))
Local aHeadStr		:= {}
Local nTimeOut		:= 120
Local nVolume		:= 0
Local nPesoBruto	:= 0
Local nPesoLiquido:= 0 

If cFil <> "02"//Função habilitada apenas para filial 02 (ecommerce)
	Return .T.
EndIf

cSql := "Select * 
cSql += " From "+RetSqlName("ZX6")
cSql += " Where D_E_L_E_T_ <> '*'
cSql += "	AND ZX6_FILIAL='"+cFil+"'
cSql += "	AND ZX6_DTENPK<>''
cSql += "	AND ZX6_DTREPK=''

TCQuery cSql ALIAS (cAlias) NEW

While (cAlias)->(!Eof())
	//header do xml
	aHeadStr := {}
	aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
	aadd(aHeadStr,"SOAPAction: sii:CONFIRMACAO_SEPARACAO_WMS10")     
	aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') 

	//preparação do xml de consulta
	cXml:="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:gen='http://www.rapidaocometa.com.br/GenPdvPickConfWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"
	cXml+="<soapenv:Header/>"
	cXml+="<soapenv:Body>"
	cXml+="<Entrada>"
	cXml+="<CLIENTE_ID>DOTERRA</CLIENTE_ID>"
	cXml+="<DEPOSITO_ID>WMWHSE8</DEPOSITO_ID>"
	cXml+="<NUMERO_ORDEM_EXTERNA_ID>"+ALLTRIM((cAlias)->ZX6_DTRAX)+"</NUMERO_ORDEM_EXTERNA_ID>"
	cXml+="</Entrada>"
	cXml+="<mesa:mesaAuth>"
	cXml+="<mesa:principal>"+aUser[1]+"</mesa:principal>"
	cXml+="<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth>"
	cXml+="</mesa:mesaAuth>"
	cXml+="</soapenv:Body>"
	cXml+="</soapenv:Envelope>"

    //Grava log Transacao 
	U_N6GEN002("SC5","E","ConfirmCaixaSeparacaoWMS10In","Totvs","FedEX",ALLTRIM((cAlias)->ZX6_DTRAX),cXml,"")
	InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Consulta de status de Picking no operador logistico.","Confirmação de Picking")

	//envio NFE para a FEDEX
	sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet)
	
	Sleep(1000)
	
	If Valtype(sPostRet) == 'U'
		SQL->(dbSkip())
		Loop		
	EndIf
	If AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
		If AT("<faultcode>",sPostRet) == 0
		    If !EMPTY(sPostRet)
				If AT("<GenPdvPickConfOut:Retorno>",sPostRet) == 0
  				 	If AT("HEADER_ConfSepOut",sPostRet) == 0
						oXml	:= XmlParser( sPostRet, "_", @cError, @cWarning ) 
						cRetorno:= oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_SAIDA:_HEADER 
						If Valtype(cRetorno) == "A"
							For y := 1 to len(cRetorno)
								nPesoBruto   += val(StrTran(cRetorno[y]:_PESO_BRUTO:TEXT,",","."))									
								nPesoLiquido += val(StrTran(cRetorno[y]:_PESO_LIQUIDO:TEXT,",","."))
							Next y
							nVolume := len(cRetorno)		
						Else                
							nPesoBruto   := val(StrTran(cRetorno:_PESO_BRUTO:TEXT,",","."))							
							nPesoLiquido := val(StrTran(cRetorno:_PESO_LIQUIDO:TEXT,",","."))
							nVolume 	 := 1
						EndIF 							

						cUpd := "UPDATE "+RetSqlName("SC5")
						cUpd += " SET C5_P_STFED='03',C5_PESOL='"+cValtochar(nPesoLiquido)+"',C5_PBRUTO='"+cValtochar(nPesoBruto)+"',C5_VOLUME1='"+cValtoChar(nVolume)+"',C5_ESPECI1='CAIXA'
						cUpd += " WHERE C5_P_CHAVE='"+ALLTRIM((cAlias)->ZX6_DTRAX)+"' AND C5_P_STFED='02'
						TCSqlExec(cUpd) 
		        		cMsg := "SUCESSO"

						//Gravação de rastreio
						cQry := " UPDATE "+RetSqlName("ZX6")
						cQry += " SET ZX6_DTREPK='"+DTOS(Date())+"',ZX6_HRREPK='"+TIME()+"'
						cQry += " WHERE ZX6_FILIAL = '"+xFilial("SC5")+"'
						cQry += "		AND ZX6_DTRAX = '"+(cAlias)->ZX6_DTRAX+"'
						cQry += "		AND ZX6_DTREPK=''
						TCSQLEXEC(cQry)
						InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Picking liberado pelo operador logistico.","Confirmação de Picking")
			        EndIf
			    Else
			 		cMsg := "Vazio"
			 		//Atualizar o Status do pedido em casos que consultas anteriores retornaram com erro.
			 		TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='02' WHERE C5_P_CHAVE='"+ALLTRIM((cAlias)->ZX6_DTRAX)+"' AND C5_P_STFED='06'")
			    EndIf   
			Else 	
			   cMsg := "Retorno em branco do webservice. Log gravado e entrar em contato com o time de desenvolvimento."
			   TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='06' WHERE C5_P_CHAVE='"+ALLTRIM((cAlias)->ZX6_DTRAX)+"' AND C5_P_STFED='02'")
			EndIf
		Else
			If AT("ja em execucao",sPostRet) == 0 
				cMsg := "Erro na estrutura do XML para envio ao webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para correção."	    
				TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='06' WHERE C5_P_CHAVE='"+ALLTRIM((cAlias)->ZX6_DTRAX)+"' C5_P_STFED='02'")
			Else
				//Processo ja em execucao, refaz a tentativa 
   				U_N6GEN002("SC5","R","ConfirmCaixaSeparacaoWMS10In","FedEX","Totvs",ALLTRIM((cAlias)->ZX6_DTRAX),sPostRet,"Processo ja em execucao")
				Loop		
			EndIf				
		EndIF
    Else
	    cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."
	EndIf

   	U_N6GEN002("SC5","R","ConfirmCaixaSeparacaoWMS10In","FedEX","Totvs",ALLTRIM((cAlias)->ZX6_DTRAX),sPostRet,cMsg)

	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbCloseArea())

Return .T.

/*
Funcao      : TratProv
Parametros  : 
Retorno     : 
Objetivos   : Realiza tratamentos provisorios / Alguns Hardcode
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function TratProv(aParam)
*------------------------------*
Local cUpd := ""
Local cEmp			:= aParam[01]
Local cFil			:= aParam[02]

//Remove caracter especial do endereço
cUpd := "Update ZX4N60 SET ZX4_COMPLE=REPLACE(ZX4_COMPLE,'&','e') Where ZX4_COMPLE like '%&%'"
TCSQLEXEC(cUpd)

//Remove informações de NFs que não são de faturamento automatico
cUpd := " UPDATE "+RetSqlName("ZX6")+" SET ZX6_DOC='',ZX6_SERIE='',ZX6_DTFAT='',ZX6_HRFAT='' Where ZX6_SERIE <> '1' AND ZX6_SERIE<>''
TCSQLEXEC(cUpd)

//Atualização dos campos de data e hora que enviaram errado pela Datatrax
cUpd := " UPDATE "+RetSqlName("ZX6")
cUpd += " 	SET ZX6_HRENT=RIGHT(ZX6_HRENT,5)+':00' WHERE ZX6_HRENT<>'' AND ZX6_HRENT like '18 %' AND ZX6_FILIAL='"+cFil+"'
TCSQLEXEC(cUpd)
cUpd := " UPDATE "+RetSqlName("ZX6")
cUpd += " 	SET ZX6_HRINI=RIGHT(ZX6_HRINI,5)+':00' WHERE ZX6_HRINI<>'' AND ZX6_HRINI like '18 %' AND ZX6_FILIAL='"+cFil+"'
TCSQLEXEC(cUpd) 

//### TRATAMENTO DO Status 91 ###
//Aplica o STATUS 91 para casos em que o estado é diferente (executa sem cosiderar a Filial, pois temq ue retirar das duas)
cUpd := " Update "+RetSqlName("SC5") 
cUpd += " 	SET C5_P_STFED='91'
cUpd += " 	Where R_E_C_N_O_ In (Select SC5.R_E_C_N_O_
cUpd += " 							From "+RetSqlName("SC5")+" SC5
cUpd += " 							LEFT OUTER JOIN "+RetSqlName("ZX4")+" ZX4 on ZX4.ZX4_CODEND = SC5.C5_P_ENDEN AND ZX4.D_E_L_E_T_ <> '*'
cUpd += " 							LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 on SA1.A1_COD = SC5.C5_CLIENTE AND SA1.D_E_L_E_T_ <> '*'
cUpd += " 							LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 on SF2.F2_FILIAL = SC5.C5_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_ <> '*'
cUpd += " 							Where SC5.D_E_L_E_T_ <> '*'
cUpd += " 							AND SC5.C5_P_ENDEN <> ''
cUpd += " 							AND SC5.C5_P_DTRAX<>''
cUpd += " 							AND SC5.C5_TIPO='N'
cUpd += " 							AND (SC5.C5_P_STFED in ('02','03','04','07','08','09')
cUpd += " 									OR (SC5.C5_P_STFED in ('91') AND SC5.C5_NOTA<>'')
cUpd += " 									OR (SC5.C5_FILIAL = '01' AND SC5.C5_P_STFED in ('','01') )
cUpd += " 								)
cUpd += " 							AND SA1.A1_EST <> ZX4.ZX4_EST
cUpd += " 							AND (SF2.F2_DAUTNFE='' OR SF2.F2_DAUTNFE is null))
TCSQLEXEC(cUpd)

//Limpeza da tabela de rastreio, caso tenha sido preenchida
If cFil == '02'
	cUpd := " Update "+RetSqlName("ZX6")
	cUpd += " 	SET ZX6_DTENPK='',ZX6_HRENPK='' 
	cUpd += " 	WHERE ZX6_FILIAL='"+cFil+"' 
	cUpd += " 		AND ZX6_DTRAX in (SELECT C5_P_DTRAX 
	cUpd += " 							FROM "+RetSqlName("SC5") 
	cUpd += " 							Where D_E_L_E_T_<>'*' AND C5_FILIAL='02' AND C5_P_STFED='91' 
	cUpd += " 							GROUP BY C5_P_DTRAX)
	TCSQLEXEC(cUpd)
EndIf

//Para a filial 01 que possiem estados com IE ja faz a liberação da NF, removendo o endereço de entrega.
If cFil == '01'
	cUpd := " Update "+RetSqlName("SC5")+" 
	cUpd += " 	SET C5_P_ENDEN='',C5_P_DTFED='',C5_P_STFED='' Where R_E_C_N_O_ in (Select SC5.R_E_C_N_O_
	cUpd += " 	From "+RetSqlName("SC5")+" SC5
	cUpd += " 	LEFT OUTER JOIN "+RetSqlName("ZX4")+" ZX4 on ZX4.ZX4_CODEND = SC5.C5_P_ENDEN AND ZX4.D_E_L_E_T_ <> '*'
	cUpd += " 	LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 on SA1.A1_COD = SC5.C5_CLIENTE AND SA1.D_E_L_E_T_ <> '*'
	cUpd += " 	LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 on SF2.F2_FILIAL = SC5.C5_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_ <> '*'
	cUpd += " 	Where SC5.D_E_L_E_T_ <> '*'
	cUpd += " 		AND SC5.C5_P_ENDEN <> ''
	cUpd += " 		AND SC5.C5_P_DTRAX<>''
	cUpd += " 		AND SC5.C5_NOTA=''
	cUpd += " 		AND SC5.C5_TIPO='N'
	cUpd += " 		AND SC5.C5_P_STFED in ('91')
	cUpd += " 		AND SA1.A1_EST <> ZX4.ZX4_EST
	cUpd += " 		AND SA1.A1_EST in ('AL','BA','DF','ES','GO','MG','PB','PE','PR','RJ','RN','RO','TO','AM','SE')
	cUpd += " 		AND SC5.C5_FILIAL='"+cFil+"')
	TCSQLEXEC(cUpd)

	//Para a filial 01 e estados que não possuem IE, faz aliberação apos acordado com a operação.
	cUpd := " Update "+RetSqlName("SC5")+" 
	cUpd += " 	SET C5_P_ENDEN='',C5_P_DTFED='',C5_P_STFED='' Where R_E_C_N_O_ in (Select SC5.R_E_C_N_O_
	cUpd += " 	From "+RetSqlName("SC5")+" SC5
	cUpd += " 	LEFT OUTER JOIN "+RetSqlName("ZX4")+" ZX4 on ZX4.ZX4_CODEND = SC5.C5_P_ENDEN AND ZX4.D_E_L_E_T_ <> '*'
	cUpd += " 	LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 on SA1.A1_COD = SC5.C5_CLIENTE AND SA1.D_E_L_E_T_ <> '*'
	cUpd += " 	LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 on SF2.F2_FILIAL = SC5.C5_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_ <> '*'
	cUpd += " 	Where SC5.D_E_L_E_T_ <> '*'
	cUpd += " 		AND SC5.C5_P_ENDEN <> ''
	cUpd += " 		AND SC5.C5_P_DTRAX<>''
	cUpd += " 		AND SC5.C5_NOTA=''
	cUpd += " 		AND SC5.C5_TIPO='N'
	cUpd += " 		AND SC5.C5_P_STFED in ('91')
	cUpd += " 		AND SA1.A1_EST <> ZX4.ZX4_EST
	cUpd += " 		AND SA1.A1_EST in ('AC','AM','AP','CE','MA','MS','MT','PA','PI','RR','RS','SC')
	cUpd += " 		AND SC5.C5_FILIAL='"+cFil+"')
	TCSQLEXEC(cUpd)
EndIf 

//Ajuste do campo A1_COD, pois o intpryor esta alterando o seu conteudo
//o Que esta impactando no execauto de criação de cadastro de cliente.
If cFil == '02'//Colocado apenas na filial 02, pois como se trata de um campo em comum, não precisa ser atualizado em ambas.
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("A1_COD"))
		If SX3->X3_CAMPO == "A1_COD" .and. ALLTRIM(SX3->X3_RELACAO) <> 'GETSX8NUM("SA1")'
			SX3->(RecLock("SX3",.F.))
			SX3->X3_RELACAO := 'GETSX8NUM("SA1")'
			SX3->(MsUnlock())
		EndIf
	EndIf
EndIf

Return .T.

/*
Funcao      : CheckDtShip
Parametros  : 
Retorno     : 
Objetivos   : Realiza a consulta na FEDEX em busca das informações de Data de envio.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function CheckDtShip(aParam)
*---------------------------------*
Local cUpd		:= ""
Local cQry		:= ""
Local cEmp		:= aParam[01]
Local cFil		:= aParam[02]
Local cAlias	:= "N6FAT009_12"
Local aShip		:= {}

cSql := "SELECT * 
cSql += " FROM "+RetSqlName("ZX6")
cSql += " WHERE D_E_L_E_T_ <> '*'
cSql += "	AND ZX6_FILIAL='"+cFil+"'
cSql += "	AND ZX6_DTINFL<>''
cSql += "	AND ZX6_DTSPOK=''
cSql += " ORDER BY R_E_C_N_O_ DESC

TCQuery cSql ALIAS (cAlias) NEW                                

While (cAlias)->(!Eof())
	aShip := ChkShipWS((cAlias)->ZX6_DTRAX)
	InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Consultado Data/Hora do shipping no operador logistico.","Confirmação de shipping")
	If Len(aShip)==2 .and. !EMPTY(aShip[1])
		cQry := " UPDATE "+RetSqlName("ZX6")
		cQry += " SET ZX6_DTSPOK='"+ALLTRIM(aShip[1])+"',ZX6_HRSPOK='"+ALLTRIM(aShip[2])+"'
		cQry += " WHERE ZX6_FILIAL = '"+xFilial("SC5")+"'
		cQry += "		AND ZX6_DTRAX = '"+(cAlias)->ZX6_DTRAX+"'
		TCSQLEXEC(cQry)
		InsertZX7((cAlias)->ZX6_FILIAL,(cAlias)->ZX6_DTRAX,(cAlias)->ZX6_NUM,"Atualizado Data/Hora do shipping no operador logistico.","Confirmação de shipping")
	EndIf
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbCloseArea())

Return .T.
              
/*
Funcao      : ChkShipWS
Parametros  : 
Retorno     : 
Objetivos   : Realiza a consulta no WS da FEDEX em busca das informações de Data de envio.
Autor       : Telso Carneiro / Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static Function ChkShipWS(cPedido)
*--------------------------------*
Local cError	:= ''
Local cWarning	:= ''
Local nTimeOut	:= 120
Local cHeadRet	:= ""
Local cData		:= "" 
Local aData		:= {"",""} 
Local nI		:= 0
Local cUrl		:= alltrim(getMV("MV_P_00116"))
Local aUser		:= &(getMV("MV_P_00117")) 

aHeadStr := {}
aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
aadd(aHeadStr,"SOAPAction: executeSTATUS_PEDIDO_WMS10")
aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
 
cXml:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gen="http://www.rapidaocometa.com.br/GenStatusPedidoWMS10In" xmlns:mesa="http://www.sterlingcommerce.com/mesa">'
cXml+='<soapenv:Header/>'
cXml+='   <soapenv:Body>'
cXml+='   <gen:ListaStatusPedido>'
cXml+='      <gen:EntradaStatusPedido>'
cXml+='         <gen:WHSEID>WMWHSE8</gen:WHSEID>'
cXml+='         <gen:STORERKEY>DOTERRA</gen:STORERKEY>'
cXml+='         <gen:TIPO_PEDIDO>SO</gen:TIPO_PEDIDO>'
cXml+='         <gen:NUMERO_PEDIDO_EXTERNO>'+cPedido+'</gen:NUMERO_PEDIDO_EXTERNO>'
cXml+='      </gen:EntradaStatusPedido>'
cXml+='   </gen:ListaStatusPedido>'
cXml+='   <mesa:mesaAuth>'
cXml+='      <mesa:principal>'+aUser[1]+'</mesa:principal>'
cXml+='      <mesa:auth hashType="?">'+aUser[2]+'</mesa:auth>'
cXml+='   </mesa:mesaAuth>'
cXml+='   </soapenv:Body>'
cXml+='</soapenv:Envelope>'

U_N6GEN002("SC5","E","GenStatusPedidoWMS10In","Totvs","FedEX",cPedido,cXml,"")

nRetSoap := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet)

oXml := XmlParser(nRetSoap,"_",@cError, @cWarning) 	

aData := {"",""} 
If Valtype(oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_LISTASTATUSPEDIDO:_HEADER:_DETALHE_PEDIDO)=="O" .AND.;
	Valtype(oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_LISTASTATUSPEDIDO:_HEADER:_DETALHE_PEDIDO:_DETALHE_STATUS) == "A"
	If (nI := aScan(oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_LISTASTATUSPEDIDO:_HEADER:_DETALHE_PEDIDO:_DETALHE_STATUS, {|x| x:_STATUS:TEXT=='95'})) <> 0
		cData := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_LISTASTATUSPEDIDO:_HEADER:_DETALHE_PEDIDO:_DETALHE_STATUS[nI]:_DATA:Text 
		aData := {DTOS(CTOD(Subs(cData,1,10))),Subs(cData,12,9)}
	EndIf
EndIf

U_N6GEN002("SC5","R","GenStatusPedidoWMS10In","FedEX","Totvs",cPedido,nRetSoap,"")

Return aData

/*
Funcao      : NewCSV
Parametros  : 
Retorno     : 
Objetivos   : Criação de arquivos CSV para envio posterior no SFTP da doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function NewCSV(cDir,aParam)
*---------------------------------*
Local cEmp		:= aParam[01]
Local cFil		:= aParam[02]
Local cAlias	:= "N6FAT009_13"
Local cQry		:= ""
Local cLinha	:= ""
Local nHandle	:= 0
Local cNameCSV	:= "import_"+dtos(date())+substr(time(),1,2)+substr(time(),4,2)+".CSV"  

//Grava o nome do arquivo dos pedidos que serão enviados
cQry := " UPDATE "+RetSqlName("ZX6")
cQry += " SET ZX6_FILECS='"+cNameCSV+"'
cQry += " WHERE D_E_L_E_T_<>'*'
cQry += " 	AND ZX6_FILIAL='"+cFil+"'
cQry += " 	AND ZX6_FILECS=''
cQry += " 	AND ZX6_DTSPOK<>''
cQry += " 	AND ZX6_SITUA='ENABLE'
TCSQLEXEC(cQry)

//Gera os arquivos CSV para quando possuir nome CSV mas não possuir data/hora do arquivo.
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cQry := "Select SC5.C5_P_NSHIP,
//cQry += " 	SC5.C5_NOTA+SC5.C5_SERIE NF,
cQry += " 	SC5.C5_NOTA NF,
cQry += " 	(CASE WHEN SC6.C6_PRODUTO like '%I'   THEN left(SC6.C6_PRODUTO, LEN(C6_PRODUTO) - 1)  
cQry += " 		WHEN SC6.C6_PRODUTO like '%N'   THEN left(SC6.C6_PRODUTO, LEN(SC6.C6_PRODUTO) - 1)   
cQry += " 		WHEN SC6.C6_PRODUTO like '%IPA' THEN left(SC6.C6_PRODUTO, LEN(SC6.C6_PRODUTO) - 3)  
cQry += " 		ELSE SC6.C6_PRODUTO END) as C6_PRODUTO,
cQry += " 	SUM(SC6.C6_QTDVEN) C6_QTDVEN,
cQry += " 	ZX6.ZX6_DTSPOK
cQry += " From "+RetSqlName("ZX6")+" ZX6
cQry += " 	INNER JOIN "+RetSqlName("SC5")+" SC5	on SC5.D_E_L_E_T_<>'*' AND SC5.C5_FILIAL=ZX6.ZX6_FILIAL AND SC5.C5_P_DTRAX=ZX6.ZX6_DTRAX
cQry += " 	LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6	on SC6.D_E_L_E_T_<>'*' AND SC5.C5_FILIAL=SC6.C6_FILIAL AND SC5.C5_NUM=SC6.C6_NUM
//cQry += " 	INNER JOIN "+RetSqlName("SF2")+" SF2	on SF2.D_E_L_E_T_<>'*' AND SC5.C5_FILIAL=SF2.F2_FILIAL AND SC5.C5_NOTA=SF2.F2_DOC AND SC5.C5_SERIE=SF2.F2_SERIE
cQry += " Where ZX6.D_E_L_E_T_<>'*'
cQry += " 	AND ZX6.ZX6_FILIAL='"+cFil+"'
cQry += " 	AND ZX6.ZX6_FILECS='"+cNameCSV+"'
cQry += " 	AND ZX6.ZX6_DTFLCS=''
cQry += " 	AND ZX6.ZX6_SITUA='ENABLE'
//cQry += " GROUP BY SC5.C5_P_NSHIP,SC5.C5_NOTA+SC5.C5_SERIE,ZX6.ZX6_DTSPOK,
cQry += " GROUP BY SC5.C5_P_NSHIP,SC5.C5_NOTA,ZX6.ZX6_DTSPOK,
cQry += " 	(CASE WHEN SC6.C6_PRODUTO like '%I'   THEN left(SC6.C6_PRODUTO, LEN(C6_PRODUTO) - 1)  
cQry += " 		WHEN SC6.C6_PRODUTO like '%N'   THEN left(SC6.C6_PRODUTO, LEN(SC6.C6_PRODUTO) - 1)   
cQry += " 		WHEN SC6.C6_PRODUTO like '%IPA' THEN left(SC6.C6_PRODUTO, LEN(SC6.C6_PRODUTO) - 3)  
cQry += " 		ELSE SC6.C6_PRODUTO END)

TCQuery cQry ALIAS (cAlias) NEW                
If (cAlias)->(!Eof())
	If FILE(cDir+"2DOTERRA\"+cNameCSV)
		FERASE(cDir+"2DOTERRA\"+cNameCSV)
	EndIf
	nHandle := FCREATE(cDir+"2DOTERRA\"+cNameCSV,FC_NORMAL)
EndIf

While (cAlias)->(!Eof())
	cLinha := 	(cAlias)->C5_P_NSHIP+","+;
		   		(cAlias)->NF+","+;
				(cAlias)->C6_PRODUTO+","+;
				alltrim(cvaltochar((cAlias)->C6_QTDVEN))+","+;
				(cAlias)->ZX6_DTSPOK+","+;
				"0,"+;
				"0,"+;
				CRLF
	FWRITE(nHandle,cLinha)
	(cAlias)->(DbSkip())
EndDo    
(cAlias)->(DbCloseArea())

If nHandle <>0
	FWRITE(nHandle, ""+CRLF)
	FCLOSE(nHandle)
EndIf

If File(cDir+"2DOTERRA\"+cNameCSV)
	cQry := " UPDATE "+RetSqlName("ZX6")
	cQry += " SET ZX6_DTFLCS='"+DTOS(Date())+"',ZX6_HRFLCS='"+TIME()+"'
	cQry += " WHERE D_E_L_E_T_<>'*'
	cQry += " 	AND ZX6_FILIAL='"+cFil+"'
	cQry += " 	AND ZX6_FILECS='"+cNameCSV+"'
	cQry += " 	AND ZX6_DTFLCS=''
	TCSQLEXEC(cQry)
EndIf
	
Return .T.

/*
Funcao      : SendCSV
Parametros  : 
Retorno     : 
Objetivos   : Envio do arquivos CSV para SFTP da doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------*
Static Function SendCSV(cDir,aParam)
*----------------------------------*
Local cEmp		:= aParam[01]
Local cFil		:= aParam[02]
Local cAlias	:= "N6FAT009_14"
Local cQry		:= ""

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cQry := "Select ZX6_FILECS
cQry += " From "+RetSqlName("ZX6")
cQry += " Where D_E_L_E_T_<>'*'
cQry += " 	AND ZX6_FILIAL='02'
cQry += " 	AND ZX6_DTFLCS<>''
cQry += " 	AND ZX6_DTENCS=''
cQry += " 	AND ZX6_SITUA='ENABLE'
cQry += " GROUP BY ZX6_FILECS

TCQuery cQry ALIAS (cAlias) NEW                

While (cAlias)->(!Eof())
	If File(cDir+"2DOTERRA\"+(cAlias)->ZX6_FILECS)
		If SendSFTPdoTerra(cDir,cFil,STRTRAN(ALLTRIM((cAlias)->ZX6_FILECS),UPPER(cExtCSV),""),.F.)
			cQry := " UPDATE "+RetSqlName("ZX6")
			cQry += " SET ZX6_DTENCS='"+DTOS(Date())+"',ZX6_HRENCS='"+TIME()+"'
			cQry += " WHERE D_E_L_E_T_<>'*'
			cQry += " 	AND ZX6_FILIAL='"+cFil+"'
			cQry += " 	AND ZX6_FILECS='"+(cAlias)->ZX6_FILECS+"'
			TCSQLEXEC(cQry)
		EndIf
	Else
		//Caso não encontre o arquivo, faz a limpeza do nome para que possa enviar no proximo processamento
		cQry := " UPDATE "+RetSqlName("ZX6")
		cQry += " SET ZX6_FILECS='',ZX6_DTFLCS='',ZX6_HRFLCS=''
		cQry += " WHERE D_E_L_E_T_<>'*'
		cQry += " 	AND ZX6_FILIAL='"+cFil+"'
		cQry += " 	AND ZX6_FILECS='"+(cAlias)->ZX6_FILECS+"'
		TCSQLEXEC(cQry)
	EndIf
	(cAlias)->(DbSkip())
EndDo    
(cAlias)->(DbCloseArea())

Return .T.

/*
Funcao      : ConfirmCSV
Parametros  : 
Retorno     : 
Objetivos   : Confirmação de arquivos CSV no no SFTP da doTerra
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------*
Static Function ConfirmCSV(cDir,aParam)
*-------------------------------------*
Local cEmp		:= aParam[01]
Local cFil		:= aParam[02]
Local cAlias	:= "N6FAT009_15"
Local cQry		:= ""

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
cQry := "Select ZX6_FILECS
cQry += " From "+RetSqlName("ZX6")
cQry += " Where D_E_L_E_T_<>'*'
cQry += " 	AND ZX6_FILIAL='02'
cQry += " 	AND ZX6_DTENCS<>''
cQry += " 	AND ZX6_DTOKCS=''
cQry += " 	AND ZX6_SITUA='ENABLE'
cQry += " GROUP BY ZX6_FILECS

TCQuery cQry ALIAS (cAlias) NEW                

While (cAlias)->(!Eof())
	If ConfirmSFTPdoTerra(cDir,cFil,STRTRAN(ALLTRIM((cAlias)->ZX6_FILECS),UPPER(cExtCSV),""),cExtCSV)
		If FILE(cDir+"2DOTERRA\"+AllTrim((cAlias)->ZX6_FILECS))
			FERASE(cDir+"2DOTERRA\"+AllTrim((cAlias)->ZX6_FILECS))
		EndIf
		cQry := " UPDATE "+RetSqlName("ZX6")
		cQry += " SET ZX6_DTOKCS='"+DTOS(Date())+"',ZX6_HROKCS='"+TIME()+"'
		cQry += " WHERE D_E_L_E_T_<>'*'
		cQry += " 	AND ZX6_FILIAL='"+cFil+"'
		cQry += " 	AND ZX6_FILECS='"+(cAlias)->ZX6_FILECS+"'
		TCSQLEXEC(cQry)
	Else
		//Caso não confirme o arquivo, faz a limpeza para reprocessar etapa anterior
		cQry := " UPDATE "+RetSqlName("ZX6")
		cQry += " SET ZX6_DTENCS='',ZX6_HRENCS=''
		cQry += " WHERE D_E_L_E_T_<>'*'
		cQry += " 	AND ZX6_FILIAL='"+cFil+"'
		cQry += " 	AND ZX6_FILECS='"+(cAlias)->ZX6_FILECS+"'
		TCSQLEXEC(cQry)
	EndIf
	(cAlias)->(DbSkip())
EndDo    
(cAlias)->(DbCloseArea())

Return .T.

/*
Funcao      : ExecLib
Parametros  : 
Retorno     : 
Objetivos   : Faz o tratamento e liberação de execução de acordo com os agendamentos disponiveis.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------*
Static Function AgendLib(aParam,cOpc,aAgFixos)
*--------------------------------------------*
Local lRet	 	:= .T.
Local cEmp		:= aParam[01]
Local cFil		:= aParam[02]
Local aDefRot	:= {} 
Local nPos		:= 0
Local CONTROL	:= "20010101 00:00:00"
Local PROX		:= ""
Local AGORA		:= DTOS(date())+" "+TIME()

//Carrega o arquivo de controle, ultima execução (CONTROL)
aDefRot := ControlFile(cEmp)
If (nPos:=aScan(aDefRot,{|X| X[1]==cOpc+cFil})) <> 0
	CONTROL := aDefRot[nPos][2]
EndIf

//Carrega as informações dos parametros (PROX)
If (nPosProx := aScan(aAgFixos,{|X| X[1] == cOpc})) <>0
	lRet := .F.
    For i:=1 to len(aAgFixos[nPosProx][2])
    	PROX := DTOS(date())+" "+LEFT(aAgFixos[nPosProx][2][i],2)+":"+RIGHT(aAgFixos[nPosProx][2][i],2)+":00"
    	If CONTROL < PROX .and. PROX < AGORA
    		//Atualiza arquivo de controle
    		AtuControlFile(cEmp,cFil,cOpc,AGORA)
    		Return .T.
    	EndIf
    Next 
EndIf

Return lRet

/*
Funcao      : ControlFile
Parametros  : 
Retorno     : 
Objetivos   : Carrega as informações do arquivo de controle de agendamentos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------*
Static function ControlFile(cEmp)
*-------------------------------*
Local i
Local aConteudo	:= {}
Local oFile
Local cDir		:= "\system\"
Local cFileControl:= ""
Local cConteu	:= ""

DEFAULT cEmp := "N6"

cFileControl := cEmp+"_N6FAT009.CONTROL"

//Verificar se arquivos existe, se sim
If File(cDir+cFileControl) .or. NewFileControl(cDir+cFileControl)
	oFile := FWFileReader():New(cDir+cFileControl)
	If (oFile:Open())
		aLinhas := oFile:getAllLines()
		oFile:Close()
	EndIf
EndIf

//Separar as informações
If Len(aLinhas) > 0
	For i:=1 to len(aLinhas)
		If LEFT(aLinhas[i],1) == "$"//Verifica se é informação
			cAux := SUBSTR(aLinhas[i],2,LEN(aLinhas[i]))
			aAux := StrTokArr(cAux,"=")
			aAdd(aConteudo,aAux)
		EndIf
	Next i
EndIf

Return aConteudo

/*
Funcao      : NewFileControl
Parametros  : 
Retorno     : 
Objetivos   : Cria um arquivo modelo em caso que não o encontre
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------*
Static Function NewFileControl(cFile)
*-----------------------------------*
Local lRet := .F.
Local cConteu := ""

//Definição do arquivo padrão
//Layout: TAG=CONTEUDO
cConteu += " *****************************************************************************************************"+CRLF
cConteu += " * Caso a opção possua algum controle de agendamento, este arquivo armazenará a ultima execução      *"+CRLF
cConteu += " * Conforme o exemplo abaixo:                                                                        *"+CRLF
cConteu += " * $U02:20181206 02:30:05                                                                            *"+CRLF
cConteu += " *****************************************************************************************************"+CRLF
	
nHdl := FCREATE(cFile,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1
	Return lRet
EndIf
fWrite(nHdl,cConteu)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := File(cFile)

Return lRet

/*
Funcao      : AtuControlFile
Parametros  : 
Retorno     : 
Objetivos   : Atualiza o arquivo de controle de agendamentos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static function AtuControlFile(cEmp,cFil,cOpc,cInfo)
*--------------------------------------------------*
Local i
Local aConteudo	:= {}
Local oFile
Local cDir		:= "\system\"
Local cFileControl:= ""
Local cConteu	:= ""
Local nPos := 0

DEFAULT cEmp := "N6"

cFileControl := cEmp+"_N6FAT009.CONTROL"

//Verificar se arquivos existe, se sim
If File(cDir+cFileControl)
	oFile := FWFileReader():New(cDir+cFileControl)
	If (oFile:Open())
		aLinhas := oFile:getAllLines()
		oFile:Close()
	EndIf
EndIf

//Separar as informações
If (nPos := aScan(aLinhas, {|X| LEFT(x,4) == "$"+cOpc+cFil})) == 0
	aAdd(aLinhas,"$"+cOpc+cFil+"="+cInfo)
Else
	aLinhas[nPos] := "$"+cOpc+cFil+"="+cInfo
EndIf

For i:=1 to len(aLinhas)
	cConteu+=aLinhas[i]+CRLF
Next i

nHdl := fopen(cFileControl, FO_READWRITE + FO_SHARED )
If nHdl == -1
	Return lRet
EndIf
FSEEK(nHdl, 0)
fWrite(nHdl,cConteu)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

Return .T.              

/*
Funcao      : DiaAut
Parametros  : 
Retorno     : 
Objetivos   : Faz o tratamento e liberação de execução de acordo com os dias autorizados para a opção.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------------------*
Static Function DiaAut(aParam,cOpc,aDiasAut)
*------------------------------------------*
Local lRet		:= .T.
Local nPos		:= 0
Local cDiaSem	:= UPPER(DiaSemana(Date(),3,1))
Local lFeriado	:= ChkFeriado(Date())

If (nPos := aScan(aDiasAut, {|x| x[1]==cOpc} ) ) <> 0
	lRet := .F.
	If lFeriado
		If aScan(aDiasAut[nPos][2], {|x| x=="FER"} ) <> 0
			lRet := .T.
		EndIf 
	ElseIf aScan(aDiasAut[nPos][2], {|x| x==cDiaSem} ) <> 0
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
Funcao      : ChkFeriado
Parametros  : 
Retorno     : 
Objetivos   : Retorna se a data informada esta configurada como feriado.
Autor       : Jean Victor Rocha
Data/Hora   :    
Informações
Utiliza o cadastro de feriados regionais do Modulo TMS
Tabela: DWY
*/
*-------------------------------*
Static Function ChkFeriado(dData)
*-------------------------------*
Local lRet	:= .F.
           
If CHKFILE("DWY")
	DWY->(DbSetOrder(1))
	If DWY->(DbSeek(xFilial("DWY")+LEFT(DTOC(dData),5)+'    ')) .or.;
		DWY->(DbSeek(xFilial("DWY")+LEFT(DTOC(dData),5)+ALLTRIM(STR(YEAR(dData)))))
		lRet := .T.
	EndIf
EndIf

Return lRet