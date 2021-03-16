#INCLUDE "protheus.ch"     
#INCLUDE "rwmake.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#include "ap5mail.ch"   
#INCLUDE "topconn.ch"
#INCLUDE "TbiCode.ch" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"

/*
Funcao      : GTFIS005
Objetivos   : Atualização da SYD
Revisão     : Jean Victor Rocha
Data/Hora   : 25/11/2014
Revisao     :
Obs.        :
*/
*----------------------*
User Function GTFIS005()     
*----------------------*
Local lJob := Select("SX3") == 0

Private cDirSrv := "\FTP\NCM"
Private cArq := ""

//Abertura do Ambiente caso seja JOB
If lJob
	RpcSetType(3)
	RpcSetEnv("YY","01")
EndIf

//Validação do Ambiente executado, ambiente TESTE liberado para testes.
If (LEFT(GetEnvServer(),6) <> "P12_01" .or. cEmpAnt <> "YY") .and. LEFT(GetEnvServer(),6) <> "P12_TE"
	If lJob
		conout( "Favor Executar esta rotina apenas na 'YY - Empresa Modelo' do ambiente P12_01")
	Else
		MsgInfo("Favor Executar esta rotina apenas na 'YY - Empresa Modelo' do ambiente P12_01","HLB BRASIL")
	EndIf
	Return .T.
EndIf

//Busca os dados dos Email de destinatarios.
Private ctoArq := GetMV("MV_P_00031",,"log.sistemas@hlb.com.br")
Private ctoSYD := GetMV("MV_P_00032",,"log.sistemas@hlb.com.br")

If lJob
	//Executa a leitura de arquivos na pasta especifica e grava.
	ProcArq()

	//Encerra o ambiente JOB	
	RpcClearEnv()
Else
	//Abre a opção para seleção do arquivo pelo usuario.
	UpLoad()
EndIf

Return .T.

/*
Funcao      : UpLoad
Objetivos   : Função responsavel pelo upload do arquivo a ser processado pelo sistema (via JOB).
Revisão     : Jean Victor Rocha
Data/Hora   : 25/11/2014
Revisao     :
Obs.        :
*/
*----------------------*
Static Function UpLoad()
*----------------------*
Local lWizard := .F.

Private oWizard

oWizard := APWizard():New("Atualização de NCM", ""/*<chMsg>*/, "Atualização de NCM",;
													"Esta rotina tem por objetivo o upload de arquivos de atualização de NCM para "+CRLF+;
													"processamento posterior pelo sistema."+CRLF+;
													"- Apos o Upload do arquivo sera enviado um email de notificação para:"+CRLF+;
													ALLTRIM(ctoArq)+CRLF+;
													"Apos o processamento do arquivo sera enviado um email de notificação para o mesmo grupo de e-mails.",;
											 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
          
//Painel 2
oWizard:NewPanel( "Buscar arquivo", "Informe o local do Arquivo",{ ||.T.}/*<bBack>*/,;
												 {|| (IIF(!FILE(cArq),Alert("Arquivo não encontrado!"),""),IIF(FILE(cArq),SaveArq(),""),FILE(cArq)) }/*<bNext>*/,;
												 {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtRef	:= dDataBase
nPercPad:= 10

@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizard:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Arquivo ? " SIZE 100,10 OF oSBox1 PIXEL
oDirArq	:= TGet():New(20,85,{|u| if(PCount()>0,cArq:=u,cArq)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,	 ,'cArq')
oBtn1	:= TButton():New( 20,135,"?",oSBox1,{|| GetArq()},008,012,,,,.T.,,"",,,,.F. )

//--> PANEL 3
oWizard:NewPanel( "Manutenção", "",{ ||.F.}/*<bBack>*/,/*<bNext>*/, {|| lWizard := .T.,.T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.} /*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizard:oMPanel[3] PIXEL
oSBox2 := TScrollBox():New( oWizard:oMPanel[3],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay1 VAR "Processamento Finalizado!" SIZE 100,10 OF oSBox2 PIXEL

oWizard:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return .T.

/*
Funcao      : SaveArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : salva o arquivo no servidor para ser processado posteriormente.
Autor       : Jean Victor Rocha.
Data/Hora   : 26/11/2014
*/
*-----------------------*
Static Function SaveArq()
*-----------------------*
Local i
Local aArqDir := {}

//Ajusta o Diretorio do arquivo no Servidor
For i:=1 to 2
	If !ExistDir(cDirSrv)
		cAux := ALLTRIM(cDirSrv)
		cAux := Left(cDirSrv,AT("\",RIGHT(cDirSrv,LEN(cDirSrv)-1)))
		While cAux <>  cDirSrv
			If !ExistDir(cAux)
				MakeDir(cAux)
			EndIf
			cAux2:= SUBSTR(cDirSrv,LEN(cAux)+1,Len(cDirSrv))
			cAux += Left(cAux2,IF(AT("\",RIGHT(cAux2,LEN(cAux2)-1))==0,LEN(cAux2),AT("\",RIGHT(cAux2,LEN(cAux2)-1)))  )
		EndDo
		If !ExistDir(cAux)
			MakeDir(cAux)
		EndIf
	EndIf
Next i

//Limpeza da Pasta.
//aArqDir := DIRECTORY(cDirSrv+"\*.TXT",)
//For i:=1 to Len(aArqDir)
//	FErase(cDirSrv+"\"+aArqDir[i][1])
//Next i

//Gravação do Arquivo no Servidor
CPYT2S(cArq,cDirSrv,.T.)

//Envia Email de Notificação de Novo arquivo a ser processado no servidor.
If !EMPTY(ctoArq)
	Notifica(ctoArq,"[NCM] - Novo Arquivo enviado, aguardando processamento.",Email("1"))
EndIf

Return .T.

/*
Funcao      : GetArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetArq()
*---------------------------*
Local cTitle:= "Selecione o diretório"
Local cFile := "Arquivos| *.txt|"
Local nDefaultMask := 0
Local cDefaultDir  := cArq
Local nOptions:= GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

cArq := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)+Space(200)

Return .T.

/*
Funcao      : Email
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criar Email de Notificação
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function Email(cTipo)
*--------------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>
If cTipo == "1"
	cHtml += 				'Novo arquivo enviado para o servidor, aguardando processamento Automatico!</b></font>   </td>
ElseIf cTipo == "2"
	cHtml += 				'Foi finalizado o processamento de um novo arquivo de atualização de NCM via evento automatico!</b></font>   </td>
EndIf
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(DTOC(Date()))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(Time())+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
If cUserName == ""
	cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+ALLTRIM(cUserName)+'</font></td>
Else
	cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: JOB</font></td>
EndIf
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Esta e uma mensagem automatica, favor nao responder este e-mail.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml

/*
Funcao      : ProcArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Processa os arquivos que estão na pasta de NCM
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function ProcArq()
*-----------------------*
Local i
Local cLinha := ""
Local aArqDir := {}
Local oFT   := fT():New()//FUNCAO GENERICA

Private aList := {}

//Carrega arquivos para o array
aArqDir := DIRECTORY(cDirSrv+"\*.TXT",)

//Tratamento para considerar somente os arquivos do tipo TXT
i:=1
While i <= Len(aArqDir)
	If RIGHT(aArqDir[i][1],3) <> "TXT"
		aDel(aArqDir,i)
		aSize(aArqDir,Len(aArqDir)-1)
	Else
		i++
	EndIf
EndDo

//Log no servidor
If Len(aArqDir) <> 0
	conout("GTFIS005 - Encontrado um novo arquivo para processamento.")
EndIf

//Leitura dos Arquivos.
For i:=1 to Len(aArqDir)
	//Verifica se o arquivo realmente existe, evitando o conflito em MultiJobs.
	If File(cDirSrv+"\"+aArqDir[i][1])
		aList := {}
	
		//Leitura do arquivo de tratamento.
		oFT:FT_FUse(cDirSrv+"\"+aArqDir[i][1])
		oFT:FT_FGoTop()
		While !oFT:FT_FEof()
			cLinha := oFT:FT_FReadln()
	
			//tratamento de identificação das informações.
	        If !(SubStr(cLinha,01,18) == "CODNCM  SEQDESCNCM" )
							//ncm               //seq               //desc                        //ii                  //ipi 
				Aadd(aList,{substr(cLinha,1,8), substr(cLinha,9,3),Alltrim(substr(cLinha,12,255)),substr(cLinha,267,6),substr(cLinha,273,6)})
		    EndIf   
	
	        oFT:FT_FSkip() // Proxima linha
		Enddo
		oFT:FT_FUse() // Fecha o arquivo 
	
		//Renomeia o Arquivo durante a atualização do Arquivo, evita varios serviços utilizarem subirem juntos.
		FRename(cDirSrv+"\"+aArqDir[i][1],cDirSrv+"\"+aArqDir[i][1]+"_USO")
	
		//Execução do Conteudo carregado.
		SaveNCM(cDirSrv+"\"+aArqDir[i][1])
	
		//Monitoramento para envio do Email.
		//U_GTFIS05M(cDirSrv,ctoArq,aArqDir[i][1])	
		StartJob( "U_GTFIS05M", GetEnvServer() , .F., cDirSrv,ctoArq,aArqDir[i][1])

	Else
		conout("GTFIS005 - Arquivo não se encontra mais disponivel para execução por esta chamada. '"+ALLTRIM(aArqDir[i][1])+"'")
	EndIf
Next i

Return .T.

/*
Funcao      : Notifica
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Processa os arquivos que estão na pasta de NCM
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/        
*----------------------------------------------*
Static Function Notifica(cTo,cSubject,cMsg,cArq)
*----------------------------------------------*
Local cArqZip := ""

Private cFrom		:= "totvs@hlb.com.br"

Default cArq := ""

If !EMPTY(cArq)
	cArqZip := LEFT(cArq,LEN(cArq)-3)+"ZIP"
	compacta(cArq,cArqZip,.F.)
EndIf

oEmail          := DEmail():New()
oEmail:cFrom   	:= cFrom
oEmail:cTo		:= PADR(cTo,200)
If File(cArqZip)
	oEmail:cAnexos := cArqZip
EndIf
oEmail:cSubject	:= padr(cSubject,200)
oEmail:cBody   	:= cMsg
oEmail:lExibMsg := .F.
oEmail:Envia()

//Apaga o arquivo Zip criado.
Sleep(1000)
FERASE(cArqZip)
	
Return .T.

/*
Funcao      : SaveNCM
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Processa a Lista Carregada em todos os ambientes.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/        
*-------------------------------*
Static Function	SaveNCM(cArquivo)
*-------------------------------*
Local i,a
//Local aAmb := {	{"P11_20","MSSQL7/P11_20"   ,"10.0.30.5"}}
Local aAmb := {}
               
//JVR - Novo tratamento baseado no GTHD para busca do Banco das empresas.	
aArea := GetArea()
aGTHD  := {}
	aAdd(aGTHD,"MSSQL7/GTHD")//Banco
	aAdd(aGTHD,"10.0.30.5")//Ip
	aAdd(aGTHD,"")//Ambiente
	aAdd(aGTHD,"")//Servidor
	aAdd(aGTHD,"")//Porta
	aAdd(aGTHD,7894)//Top Porta
cBanco:= aGTHD[1]
cIp   := aGTHD[2]
nCon := TCLink(cBanco,cIp,aGTHD[6])

If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf
cQuery := " Select * 
cQuery += " From Z10010
cQuery += " Where Z10_BLOQ <> 'S'
cQuery += " 	AND Z10_AMB not in ('GTHD')

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!BOF() .and. !EOF())
	aAux := {}
	aAdd(aAux,ALLTRIM(QRY->Z10_BANCO)		)//1-Banco
	aAdd(aAux,ALLTRIM(QRY->Z10_IPBD)		)//2-Ip
	IF QRY->Z10_AMB == "GTCORP"
		aAdd(aAux,ALLTRIM(QRY->Z10_AMB)+"11")//3-Ambiente
	Else                       
		aAdd(aAux,ALLTRIM(QRY->Z10_AMB)		)//3-Ambiente
	EndIf
	aAdd(aAux,ALLTRIM(QRY->Z10_SERVID)		)//4-Servidor
	aAdd(aAux,ALLTRIM(QRY->Z10_PORTA)		)//5-Porta
	aAdd(aAux,VAL(ALLTRIM(QRY->Z10_TOPORT))	)//6-Porta Top
	aAdd(aAux,ALLTRIM(QRY->Z10_RELEAS)		)//7-Release
	aAdd(aAmb,aAux)
	QRY->(DbSkip())
EndDo 
QRY->(DbCloseArea())

TCunLink(nCon)    
RestArea(aArea)

//Criação dos arquivos de controle de processamento.
For i:=1 to Len(aAmb)
	GeraArq(cArquivo+"_"+aAmb[i][3]+aAmb[i][7])
Next i

//Execução dos processamentos por ambiente.
For i:=1 to Len(aAmb)
	//Validação para que aguarde terminar todos os Jobs.
	nCount := 12
	nTime  := 200
	While nCount >= 12
		aThread := GetUserInfoArray()
		nCount := 0
		For j := 1 to len(aThread)
			If RIGHT(ALLTRIM(aThread[j][1]),1) == "_" .and. LEFT(ALLTRIM(aThread[j][5]),10) == "U_GTFIS05P"
				nCount++
			EndIf            	
		Next j
	    Sleep(nTime)//Para não ficar um processamento muito alto.
		If nTime <= 3000
			nTime := nTime + 100
		EndIf
	EndDo

	StartJob( "U_GTFIS05P     "+aAmb[i][3]+aAmb[i][7],GetEnvServer(),.F.,aAmb[i],aList,cArquivo+"_"+aAmb[i][3]+aAmb[i][7])
Next i

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

Default lApagaOri := .T.

If lApagaOri
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Else
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
EndIf
lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : GTFIS05P
Parametros  : cArquivo
Retorno     : lRet
Objetivos   : Função de processamento e gravação das NCM nos ambientes.
Autor       : Jean Victor Rocha
Data/Hora   : 05/12/2014
*/
*-----------------------------------------*
User Function GTFIS05P(aAmb,aList,cArquivo)
*-----------------------------------------*
Local nCon := 0
Local cQry	:= ""
Local cQuery := ""
                          
//Abre nova conexão com o ambiente
RpcSetType(3)
RpcSetEnv("YY","01")

//Execução em Todos os Ambientes
If (nCon := TCLink(aAmb[1],aAmb[2],aAmb[6])) <> 0
	//Verifica todas as tabelas na base do ambiente.
	If Select("TAB") > 0
		TAB->(DbClosearea())
	EndIf  

	cQuery := " Select name as TABELA
	cQuery += "	From sys.objects
	cQuery += " Where type = 'U'
	cQuery += "		AND name like 'SYD%0'
	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TAB",.F.,.T.)
    
	TAB->(DbGoTop())
	While TAB->(!EOF())
		//Executa atualização da Lista de NCM em todas as tabelas.
		For i:=1 to Len(aList)
			//1.NCM,2.EX,3.DESC,4.II,5.IPI List          
			If Alltrim(aList[i][2]) == '001' // Senquencia 001, será sempre tratada como Branca.
				aList[i][2] :="   "  
			EndIf

			//Verifica se existe, caso sim, atualiza, senão inclui
			If Select("QRY") > 0
				QRY->(DbClosearea())
			Endif  
			cQuery := " Select COUNT(*) as COUNT
			cQuery += " From "+ALLTRIM(TAB->TABELA)
			cQuery += " Where D_E_L_E_T_ <> '*' 
			cQuery += " 		AND YD_TEC		= '"+Alltrim(aList[i][1])+"'
			cQuery += " 		AND YD_EX_NCM	= '"+alltrim(aList[i][2])+"' "
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

			cQry := ""
			If QRY->COUNT <> 0
				cQry += " Update "+ALLTRIM(TAB->TABELA)
				cQry += " Set
				If !Empty((aList[i][4])) .And. !(aList[i][4]) $ "NT/TN/T/I/N/!/S/R" .And. (aList[i][4])<>NIL
					cQry += " YD_PER_II = "+ALLTRIM(STRTRAN(aList[i][4],",","."))
				Else
					cQry += " YD_PER_II = 0
				EndIf
				If !Empty((aList[i][5])) .And. !(aList[i][5]) $ "NT/TN/T/I/N/!/S/R" .And. (aList[i][5])<>NIL
					cQry += " ,YD_PER_IPI = "+ALLTRIM(STRTRAN(aList[i][5],",","."))        
				Else   
					cQry += " ,YD_PER_IPI = 0      
				EndIf 
				cQry += " ,YD_DESC_P	= LEFT('"+ALLTRIM(aList[i][3])+"',(Select CHARACTER_MAXIMUM_LENGTH 
				cQry += "													From INFORMATION_SCHEMA.COLUMNS 
				cQry += "													Where TABLE_NAME = '"+ALLTRIM(TAB->TABELA)+"' 
				cQry += "																AND COLUMN_NAME = 'YD_DESC_P'))
				cQry += " ,YD_UNID		= '11'   
				cQry += " ,YD_GRVDATA	= '"+DTOS(date())+"'
				cQry += " ,YD_GRVUSER	= 'JOB'
				cQry += " ,YD_GRVHORA	= '"+Time()+"'

				cQry += " Where D_E_L_E_T_ <> '*' 
				cQry += " 		AND YD_TEC = '"+Alltrim(aList[i][1])+"'
				cQry += " 		AND YD_EX_NCM = '"+alltrim(aList[i][2])+"' "
            Else
			    cQry += " Insert "+ALLTRIM(TAB->TABELA)
			    cQry += " (YD_FILIAL,YD_TEC,YD_EX_NCM,YD_DESC_P,YD_PER_II,YD_PER_IPI,YD_UNID,YD_GRVDATA,YD_GRVUSER,YD_GRVHORA,R_E_C_N_O_)
			    cQry += " Values
   			    cQry += " ('  ',
   			    cQry += " '"+Alltrim(aList[i][1])+"',
   			    cQry += " '"+Alltrim(aList[i][2])+"',
   			    cQry += " LEFT('"+ALLTRIM(aList[i][3])+"',(Select CHARACTER_MAXIMUM_LENGTH 
				cQry += "									From INFORMATION_SCHEMA.COLUMNS 
				cQry += "									Where TABLE_NAME = '"+ALLTRIM(TAB->TABELA)+"' 
				cQry += "											AND COLUMN_NAME = 'YD_DESC_P')),
   			    cQry += " "+ALLTRIM(STRTRAN(aList[i][4],",","."))+",
   			    cQry += " "+ALLTRIM(STRTRAN(aList[i][5],",","."))+",
   			    cQry += " '11',
   			    cQry += " '"+DTOS(Date())+"',
   			    cQry += " 'JOB',
   			    cQry += " '"+alltrim(Time())+"',
   			    cQry += " (Select ISNULL(MAX(R_E_C_N_O_)+1,0) From "+ALLTRIM(TAB->TABELA)+")
   			    cQry += " )
            EndIf

			//Execução da Query para Atualização/Inclusão
			TCSQLExec(cQry)
		Next i
		TAB->(DbSkip())
	EndDo
Else
	Conout("GTFIS005 - Não foi possivel conexão ao Banco "+aAmb[1])
EndIf

//Encerra a conexão
TCunLink(nCon)

//Deleta o Arquivo de trava de Processamento
FErase(cArquivo)

//Encerra conexão com o Ambiente
RpcClearEnv()

Return .T.

/*
Funcao      : GTFIS05M
Parametros  : cArquivo
Retorno     : lRet
Objetivos   : Função de monitoramento da finalização do processamento para envio do email de notificação.
Autor       : Jean Victor Rocha
Data/Hora   : 05/12/2014
*/
*---------------------------------------------*
User Function GTFIS05M(cDirSrv,ctoArq,cArquivo)
*---------------------------------------------*
Local aDir := {}
Local lWhile := .T.

//Abre nova conexão com o ambiente
RpcSetType(3)
RpcSetEnv("YY","01")

While lWhile
	aDir := DIRECTORY(cDirSrv+"\*.*",)
	cArqProc := UPPER(ALLTRIM(cArquivo+"_P11_"))//verifica se possui execução para o arquivo.
	If aScan(aDir,{|x| LEFT(UPPER(ALLTRIM(x[1])),Len(cArqProc) ) == cArqProc  }) == 0
		//Envia Email de Notificação	
		If !EMPTY(ctoArq)
			//Reverte o Nome do Arquivo para o Original.
			FRename(cDirSrv+"\"+cArquivo+"_USO",cDirSrv+"\"+cArquivo)

			//Envia notificação para os emails.
			Notifica(ctoArq,"[NCM] - Processamento de arquivo Finalizado!",Email("2"),cDirSrv+"\"+cArquivo)
		EndIf
		lWhile := .F.
	Else
		Sleep(2000)
	EndIf
EndDo

FErase(cDirSrv+"\"+cArquivo)

//Encerra conexão com o Ambiente
RpcClearEnv()

Return .T.

/*
Funcao      : GeraArq
Parametros  : 
Retorno     : 
Objetivos   : Gera um arquivo em branco com o nome passado por parametro
Autor       : Jean Victor Rocha
Data/Hora   : 05/12/2014
Obs         : 
*/                 
*-------------------------------*
Static Function GeraArq(cNomeArq)
*-------------------------------*
Local nHandle := 0

If File(cNomeArq)
	ferase(cNomeArq)
EndIf

nHandle := FCreate(cNomeArq, 0)
fclose(nHandle)

Return .T.