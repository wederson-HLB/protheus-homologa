#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.Ch"

/*
Funcao      : GTFLG003
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Processamentos de notificações pendentes
Autor       : Jean Victor Rocha 
Revisão		:
Data/Hora   : 01/06/2016
Módulo      : 
*/
*----------------------*
User Function GTFLG003()
*----------------------*
ConOut("$GT --- GTFLG003 - Executado em "+DTOS(date())+" - "+Time())
Private cEmpJOB := "02"//empresa teste 03 filial 01
Private cFilJOB := "01"

Private URLFLUIG := "http://187.94.57.99:8280/webdesk/"//"http://gt.fluig.com/webdesk/"//"http://gt.fluig.com:8280/webdesk/"//"http://10.11.210.3:8080/webdesk/"

Private cUserAdm := "esbUser"
Private cPassAdm := "Fluig@2014"
Private ncompanyId := 1

Private cDest := ""
Private cDestServer := ""

//Inicialização do ambiente
RpcSetType(3)
RpcSetEnv(cEmpJOB,cFilJOB)

//Busca os dados a serem processados.
BuscaDados()

ZF0->(DbSetOrder(1))

//Integração dos dados para cada solicitação de faturamento
QRY->(DbGoTop())
If QRY->(!EOF())
	While QRY->(!EOF())	
		//Verifica se ja foi processado por outra instancia.
		ZF0->(DbGoTop())
		ZF0->(DbGoTo(QRY->R_E_C_N_O_))
		If EMPTY(ZF0->ZF0_NOTIF)
			TCSQLEXEC("Update "+RetSQLName("ZF0")+" set ZF0_NOTIF = 'NOTIFICANDO' where R_E_C_N_O_ = "+ALLTRIM(STR(QRY->R_E_C_N_O_)))
			If SendMail(QRY->ZF0_STATUS,QRY->ZF0_LOGIN,QRY->ZF0_NUMPRO)
				TCSQLEXEC("Update "+RetSQLName("ZF0")+" set ZF0_NOTIF = '"+DtoS(date())+" - "+Time()+"' where R_E_C_N_O_ = "+ALLTRIM(STR(QRY->R_E_C_N_O_)))
			Else
				TCSQLEXEC("Update "+RetSQLName("ZF0")+" set ZF0_NOTIF = '' where R_E_C_N_O_ = "+ALLTRIM(STR(QRY->R_E_C_N_O_)))
			EndIf
		EndIf
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
Data/Hora   : 02/06/2016
*/
*--------------------------*
Static Function	BuscaDados()
*--------------------------*

If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf

cQry := " Select *
cQry += " From "+RetSQLName("ZF0")+" ZF0
cQry += " Where ZF0_STATUS in ('S','C')
cQry += "		AND ZF0_NOTIF = ''
cQry += "		AND ZF0_NUMPRO not like '%SFA%'

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), 'QRY', .F., .T.)

Return .T. 
                       
/*
Funcao      : SendMail
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Envia notificações
Autor       : Jean Victor Rocha 
Data/Hora   : 02/06/2016
*/
*----------------------------------------------*
Static Function	SendMail(cTipo,cLogin,cProcesso)
*----------------------------------------------*
Local cObs	:= ""
Local cNf	:= ""
Local lEnvioOK := .T.

cMailConta	:= GETMV("MV_EMCONTA",,"totvs@br.gt.com")
cMailServer	:= GETMV("MV_RELSERV",,"mail.br.gt.com")
cMailSenha	:= GETMV("MV_EMSENHA",,"Email@14")

ZW0->(DbSetOrder(1))
ZW0->(DbSeek(xFilial("ZW0")+AllTrim(cLogin)))

//Busca os dados dos arquivos anexados na solicitação.
If cTipo == "S"
	cDest := "D:\Protheus10\Portal\Fluig\"+ALLTRIM(cProcesso)
	cDestServer	:= "\Fluig\"+ALLTRIM(cProcesso)
	If !getFilesFluig(cProcesso)
		conout("GTFLG003 - Falha na busca dos anexos [process: "+cProcesso+"]" )		
		Return .F.
	EndIf
	cNf := getNumNf(cProcesso)
ElseIf cTipo == "C"
	cObs := getMotivo(cProcesso)
EndIf

cTexto		:= ""
Do Case
	Case UPPER(LEFT(ZW0->ZW0_IDIOMA,1)) == "E"//English
  		cSubject := "[GT] - Billing Request [process: "+cProcesso+"]"
   		cTexto := "<p>Hello "+Capital(AllTrim(ZW0->ZW0_NOME))+",<br></p><br>"
		cTexto += "<p>The billing request below has been updated to "
		If cTipo == "C"
			cTexto += "canceled.</p> 
			cTexto += "<p><b>process:</b> "+AllTrim(cProcesso)+"<br> "
			cTexto += "<b>Reason:</b> "+AllTrim(cObs)+"</p> "
			cSubject += " - Canceled"
		Else
			cTexto += "finished.</p>
			cTexto += "<p><b>process:</b> "+AllTrim(cProcesso)+"<br> "
			cTexto += "<b>Invoice:</b> "+AllTrim(cNf)+"</p> "
			cSubject += " - Finished"
		EndIf
		cTexto += "<br>"
		cTexto += "<br>"
		cTexto += "<p>This email was sent automatically!"
		cTexto += "<br><b>Grant Thornton Brasil.</b></p>" 
		cTexto += "<img src='http://www.grantthornton.com.br/globalassets/1.-member-firms/global/logos/logo.png'>"

	OtherWise
   		cSubject := "[GT] - Solicitacao de faturamento [processo: "+cProcesso+"]"
   		cTexto := "<p>Olá "+Capital(AllTrim(ZW0->ZW0_NOME))+" ,</p><br>"
		cTexto += "<p>A solicitação de faturamento abaixo foi atualizada para "
		If cTipo == "C"
			cTexto += "cancelada.</p> 
			cTexto += "<p><b>processo:</b> "+AllTrim(cProcesso)+"<br> "
			cTexto += "<b>Motivo:</b> "+AllTrim(cObs)+"</p> "
			cSubject += " - Cancelada"
		Else
			cTexto += "finalizada.</p>
			cTexto += "<p><b>processo:</b> "+AllTrim(cProcesso)+"<br> "
			cTexto += "<b>NF:</b> "+AllTrim(cNf)+"</p> "
			cSubject += " - Finalizada"
		EndIf
		cTexto += "<br>"
		cTexto += "<br>"
		cTexto += "<p>Este e-mail foi enviado automaticamente!"
		cTexto += "<br><b>Grant Thornton Brasil.</b></p>"
		cTexto += "<img src='http://www.grantthornton.com.br/globalassets/1.-member-firms/global/logos/logo.png'>"
EndCase

cCC := getEmailCC(cProcesso)
cCC := STRTRAN(cCC,CHR(13)+CHR(10),"")
cCC := STRTRAN(cCC," ","")

oMessage			:= TMailMessage():New()
oMessage:Clear()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cMailConta
oMessage:cTo		:= AllTrim(ZW0->ZW0_EMAIL)
oMessage:cCC 		:= cCC
oMessage:cBCC 		:= "log.sistemas@br.gt.com"
oMessage:cReplyTo	:= "faturamento@br.gt.com"//responder para...
oMessage:cSubject	:= cSubject
oMessage:cBody		:= cTexto

If cTipo <> "C"
	aArquivos := DIRECTORY(cDestServer+"\*.*","A")
	For i:=1 to len(aArquivos)
		xRet := oMessage:AttachFile(cDestServer+"\"+aArquivos[i][1])
		If xRet < 0
			conout( "Could not attach file " + cDestServer+"\"+aArquivos[i][1] )
		EndIf
	Next j
EndIf

oServer				:= tMailManager():New()
cUser				:= cMailConta
cPass				:= cMailSenha
xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 0 )
If xRet != 0
	conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SetSMTPTimeout( 60 )
If xRet != 0
    conout( "Could not set timeout to " + cValToChar( 60 ) ) 
	lEnvioOK := .F.
EndIf
xRet := oServer:SMTPConnect()
If xRet <> 0
	conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SmtpAuth( cUser, cPass )
If xRet <> 0
    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
    lEnvioOK := .F.
    oServer:SMTPDisconnect()
EndIf      
//Envio
xRet := oMessage:Send( oServer )
If xRet <> 0
    conout( "Could not send message: " + oServer:GetErrorString( xRet ))
    lEnvioOK := .F.
EndIf
//Encerra
xRet := oServer:SMTPDisconnect()
If xRet <> 0
    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
EndIf

Return lEnvioOK

/*
Funcao      : GrvFile64
Parametros  : 
Retorno     : 
Objetivos   : Grava o arquivo recebido do WS.
Autor       : Jean Victor Rocha
Data/Hora   : 07/06/2016
Obs         : 
*/                 
*--------------------------------------*
Static Function getFilesFluig(cProcesso) 
*--------------------------------------*
Local lRet := .T.
Local aFilesFluig := {}
Local aFiles := {}
Local aInfoFile := {}
//Cria a pasta e limpa o conteudo
setFolderFluig()

//Tratamento dos dados dos arquivos que foram informado pelo Fluig
oFilesFluig := getFile(cProcesso)
      
If (nPosId := aScan(oFilesFluig:CCOLUMNS, {|x| UPPER(x) == "NUM_PROCES" }) ) <> 0 .and.;
	(nPosDocId := aScan(oFilesFluig:CCOLUMNS, {|x| UPPER(x) == "NR_DOCUMENTO" }) )  <> 0 .and.;
	(nPosVersao := aScan(oFilesFluig:CCOLUMNS, {|x| UPPER(x) == "NR_VERSAO" }) )  <> 0 .and.;
	(nPosNome := aScan(oFilesFluig:CCOLUMNS, {|x| UPPER(x) == "NM_ARQUIVO_FISICO" }) )  <> 0
	For i:=1 to Len(oFilesFluig:OWSVALUES)
		oFilesFluig:OWSVALUES[i]:OWSVALUE[nPosId]:TEXT
		//aAdd(aFilesFluig, {DocId,docVersao,docName})
		aAdd(aFilesFluig, {oFilesFluig:OWSVALUES[i]:OWSVALUE[nPosDocId]:TEXT,;
							oFilesFluig:OWSVALUES[i]:OWSVALUE[nPosVersao]:TEXT,;
							oFilesFluig:OWSVALUES[i]:OWSVALUE[nPosNome]:TEXT})
	Next i
EndIf

//Manipulação de Arquivos.
For i:=1 to len(aFilesFluig)
	//Faz o Download dos arquivos
	FlgWS  := WSECMDocumentServiceService():new()
	FlgWs:_URL				:= URLFLUIG+"ECMDocumentService"
	FlgWS:cusername			:= cUserAdm
	FlgWS:cpassword			:= cPassAdm
	FlgWS:ncompanyId		:= ncompanyId
	FlgWS:ndocumentId		:= val(aFilesFluig[i][1])
	FlgWS:ccolleagueId		:= cUserAdm
	FlgWS:ndocumentoVersao	:= val(aFilesFluig[i][2])
	FlgWS:cnomeArquivo		:= ""//aFilesFluig[i][3]
	FlgWs:getDocumentContent()
	If FlgWs:cfolder <> nil
		cNameFile := ALLTRIM(aFilesFluig[i][3])
		GrvFile64(Encode64(FlgWs:cfolder),cNameFile+".TXT")
		//Decodifica os arquivos
		WaitRunSrv('certutil -decode "'+cDest+'\'+cNameFile+'.TXT"'+' "'+cDest+'\'+cNameFile+'"', .T., cDest+"\" )
		//Apaga os codificados.
		FErase(cDestServer+"\"+cNameFile+".TXT")
	EndIf
Next i     

//Validação de arquivos
aArquivos := DIRECTORY(cDestServer+"\*.*","A")
lRet := len(aArquivos) > 0

Return lRet

/*
Funcao      : setFolderFluig
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Jean Victor Rocha
Data/Hora   : 07/06/2016
Obs         : 
*/                 
*------------------------------*
Static Function setFolderFluig()
*------------------------------*
MakeDir(cDestServer)

aArquivos := DIRECTORY(cDestServer+"\*.*","D")

For i:=1 to len(aArquivos)
	FErase(cDestServer+"\"+aArquivos[i][1])
Next j

Return .T.

/*
Funcao      : GrvFile64
Parametros  : 
Retorno     : 
Objetivos   : Grava o arquivo recebido do WS.
Autor       : Jean Victor Rocha
Data/Hora   : 07/06/2016
Obs         : 
*/                 
*----------------------------------------*
Static Function GrvFile64(cTexto,cArquivo) 
*----------------------------------------*
Local nHandle := 0

If File(cDestServer+"\"+cArquivo)
	FErase(cDestServer+"\"+cArquivo,2)
EndIf

nHandle := FCreate(cDestServer+"\"+cArquivo, 0)
                
FSeek(nHandle,0,2)
FWRITE(nHandle, cTexto)
fclose(nHandle)

Return .T.


/*
Funcao      : getDataSet
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Consulta em DataSet do Fluig.
Autor       : Jean Victor Rocha 
Data/Hora   : 12/05/2016
*/
*--------------------------------*
Static Function getFile(cProcesso)
*--------------------------------*
Local WS  := WSECMDatasetServiceService():new()

WS:_URL             := URLFLUIG+"ECMDatasetService"
WS:ncompanyId       := ncompanyId
WS:cusername        := cUserAdm
WS:cpassword        := cPassAdm
WS:cname			:= "ds_gt_get_document"

aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "SHOLD"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "NUM_PROCES"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.	

Ws:getDataset()
oResult := Ws:OWSGETDATASETDATASET

Return oResult

/*
Funcao      : getNumNf
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Consulta em DataSet do Fluig para buscar informações da solicitacao.
Autor       : Jean Victor Rocha 
Data/Hora   : 17/05/2016
*/
*---------------------------------*
Static Function getNumNf(cProcesso)
*---------------------------------*
Local WS  := WSECMDatasetServiceService():new()
Local oResult
Local cResult := ""

WS:_URL             := URLFLUIG+"ECMDatasetService"
WS:ncompanyId       := ncompanyId
WS:cusername        := cUserAdm
WS:cpassword        := cPassAdm
WS:cname			:= "ds_gt_get_numnf"

aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "SHOLD"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "vl_solic"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.	

Ws:getDataset()
oResult := Ws:OWSGETDATASETDATASET
                
If (nPosId := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "VL_SOLIC" }) ) <> 0 .and.;
	(nPosEmail := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "CD_NF" }) )  <> 0
	for i:=1 to len(oResult:OWSVALUES)
		If !EMPTY(oResult:OWSVALUES[i]:OWSVALUE[nPosId]:TEXT)
			cResult += oResult:OWSVALUES[i]:OWSVALUE[nPosEmail]:TEXT
		Else
			Return ""
		EndIf
	Next i
EndIf

Return cResult

/*
Funcao      : getEmailCC
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Consulta em DataSet do Fluig para buscar informações da solicitacao.
Autor       : Jean Victor Rocha 
Data/Hora   : 12/05/2016
*/
*-----------------------------------*
Static Function getEmailCC(cProcesso)
*-----------------------------------*
Local WS  := WSECMDatasetServiceService():new()
Local oResult
Local cResult := ""

WS:_URL             := URLFLUIG+"ECMDatasetService"
WS:ncompanyId       := ncompanyId
WS:cusername        := cUserAdm
WS:cpassword        := cPassAdm
WS:cname			:= "ds_gt_get_emailcc"

aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "SHOLD"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "vl_solic"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.	

Ws:getDataset()
oResult := Ws:OWSGETDATASETDATASET
                
If (nPosId := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "VL_SOLIC" }) ) <> 0 .and.;
	(nPosEmail := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "EMAIL_CC" }) )  <> 0
	for i:=1 to len(oResult:OWSVALUES)
		If !EMPTY(oResult:OWSVALUES[i]:OWSVALUE[nPosId]:TEXT)
			cResult += oResult:OWSVALUES[i]:OWSVALUE[nPosEmail]:TEXT
		Else
			Return ""
		EndIf
	Next i
EndIf

Return cResult


/*
Funcao      : getMotivo
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Consulta em DataSet do Fluig para buscar informações do motivo do cancelamento da solicitação
Autor       : Jean Victor Rocha 
Data/Hora   : 15/05/2016
*/
*----------------------------------*
Static Function getMotivo(cProcesso)
*----------------------------------*
Local WS  := WSECMDatasetServiceService():new()
Local oResult
Local cResult := ""
Local i

WS:_URL             := URLFLUIG+"ECMDatasetService"
WS:ncompanyId       := ncompanyId
WS:cusername        := cUserAdm
WS:cpassword        := cPassAdm
WS:cname			:= "ds_gt_get_motivo"

aAdd(Ws:OWSGETDATASETCONSTRAINTS:oWSitem,ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New())
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CCONTRAINTTYPE := "SHOLD"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFIELDNAME := "vl_solic"
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CFINALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):CINITIALVALUE := cProcesso
aTail(Ws:OWSGETDATASETCONSTRAINTS:OWSITEM):LLIKESEARCH := .T.	

Ws:getDataset()
oResult := Ws:OWSGETDATASETDATASET
              
If (nPosId := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "VL_SOLIC" }) ) <> 0 .and.;
	(nPosSeq := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "SEQUENCIA" }) ) <> 0 .and.;
	(nPosDesc := aScan(oResult:CCOLUMNS, {|x| UPPER(x) == "DESC_MOTIVO" }) ) <> 0
	for i:=1 to len(oResult:OWSVALUES)
		If !EMPTY(oResult:OWSVALUES[i]:OWSVALUE[nPosId]:TEXT)
			cResult += removeTags(oResult:OWSVALUES[i]:OWSVALUE[nPosDesc]:TEXT)
		Else
			Return "<get error>"
		EndIf
	Next i
EndIf

Return cResult       

/*
Funcao      : removeTags
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Remove Tags do Texto
Autor       : Jean Victor Rocha 
Data/Hora   : 15/05/2016
*/
*--------------------------------*
Static function removeTags(cTexto)
*--------------------------------*
Local cRet := ""
Local aTag := {"<p>","</p>","<br />"}

cRet := cTexto

For i:=1 to len(aTag)
	cRet := STRTRAN(cRet,aTag[i],"")
Next i

Return cRet