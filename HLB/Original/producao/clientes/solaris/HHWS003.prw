#include "totvs.ch" 
#Include "Topconn.Ch" 
#Include "tbiconn.ch"
#include "protheus.ch"

/*
Funcao      : HHWS003 
Parametros  : Nenhum
Retorno     : 
Objetivos   : Consome webservice rest 
Autor       : Anderson Arrais
Cliente		: Solaris 
Data/Hora   : 08/05/2017
*/
*--------------------------*
User Function HHWS003(aEmp)
*--------------------------*
Local cQry 		:= ""
Local dDataProc := CTOD("//")

//Grava tabela de log se o schedule foi executado
//FUNÇÃO AQUI   

If !Used() 
	conout(aEmp[1]+" "+aEmp[2])
	
	RpcClearEnv()
	RpcSetType( 3 )
	PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SE1" MODULO "FIN"
	//PREPARE ENVIRONMENT EMPRESA "HH" FILIAL "01" TABLES "SE1" MODULO "FIN"
	conout("preparou HHWS003")
EndIf

dDataProc := SUPERGETMV("MV_P_00099", .F. , CTOD("//") )            

If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf

cQry := " Select E1_FILIAL,E1_TIPO,E1_P_RETBA,E1_P_DTRET,E1_BAIXA,E1_P_RETWS,E1_NUMBOR,E1_NUM,E1_PARCELA,E1_PREFIXO,"
cQry += " E1_CLIENTE,E1_MSEMP,E1_MSFIL,E1_CODBAR,E1_CODDIG,E1_IDCNAB,E1_NUMBCO,E1_PORTADO,E1_EMISSAO,E1_VENCREA"
cQry += " From "+RETSQLNAME("SE1")
cQry += " Where D_E_L_E_T_ <> '*' "
cQry += " AND E1_P_RETBA = '02'
cQry += " AND E1_BAIXA = ''
cQry += " AND E1_P_DTRET > '"+DTOS(dDataProc)+"' 
cQry += " AND E1_P_RETWS <> '200' 
cQry += " AND E1_NUMBOR <> '' 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SQL",.T.,.T.)

Count to nRecCount

If nRecCount > 0
	//processa o web service 
	HHAtuSE1()
EndIf

Return

/*
Funcao      : HHTOKEN 
Autor       : Anderson Arrais
Objetivos   : Conecta no WS Solaris com usuário e senha e pega Token
Data/Hora   : 09/05/2017 
*/
*------------------------*
Static Function HHTOKEN() 
*------------------------*
//Local cUrl			:= "https://hom-svc.solarisbrasil.com.br/ServiceMiddleware/ServiceMiddleWare.svc/Gettoken"
Local cUrl			:= "https://svc.solarisbrasil.com.br/ServiceMiddleWare/ServiceMiddleWare.svc/GetToken"
Local cGetParams	:= ""
Local cPostParms	:= '{"userapp":"GTACCESS", "password":"GT#sl17"}' //Usuario e senha para conectar na Solaris
Local cHeaderGet	:= ""
Local nTimeOut		:= 200
Local aHeadStr 		:= {}
Local cRetorno		:= ""
Local oObjJson		:= Nil
Local cToken		:= ""

aAdd(aHeadStr , 'Content-Type: application/json')    
        
cRetorno	:= HttpPost(cUrl, cGetParams, cPostParms ,nTimeOut, aHeadStr, @cHeaderGet)

If !FWJsonDeserialize(cRetorno, @oObjJson)
	Return Nil
EndIf

cToken	:= oObjJson:Value[1]:tokenUser

Return(cToken)

/*
Funcao      : HHAtuSE1 
Autor       : Anderson Arrais
Objetivos   : Envia dados do SE1 que foram confirmados no banco via CNAB
Data/Hora   : 09/05/2017 
*/
*-------------------------*
Static Function HHAtuSE1() 
*-------------------------*
//Local cUrl			:= "https://hom-svc.solarisbrasil.com.br/ServiceMiddleware/ServiceMiddleWare.svc/UpdateSecurity"
Local cUrl			:= "https://svc.solarisbrasil.com.br/ServiceMiddleWare/ServiceMiddleWare.svc/UpdateSecurity"
Local cGetParams	:= ""
Local cPostParms	:= ""
Local cHeaderGet	:= ""
Local nTimeOut		:= 200
Local aHeadStr 		:= {}
Local cRetorno		:= ""
Local oObjJson		:= Nil
Local oObjTit		:= Nil
Local cChave		:= "" 
Local lInclui		:= .F.
Local cContInt		:= ""
Local cArqLog		:= ""
Local cToken		:= ""
Local cRetJson      := ""
Local nR			:= 0
Local aLogMail		:= {}
Local nContOk		:= 0  
Local cNomeEmp		:= ""

aAdd(aHeadStr , 'Content-Type: application/json')    

SQL->(DbGotop())
While !SQL->(EOF())
	Sleep( 2000 ) 
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SQL->E1_PREFIXO+SQL->E1_NUM+SQL->E1_PARCELA+SQL->E1_TIPO))
	If Alltrim(SE1->E1_P_RETWS) $ '200'
		SQL->(dbSkip())
		SE1->(DBCloseArea())
		Loop
	EndIf
	
	cChave		:= SQL->E1_PREFIXO+SQL->E1_NUM+SQL->E1_PARCELA+SQL->E1_TIPO
	cToken		:= HHTOKEN()

	oObjTit		:= AtuSE1():New()
	oObjTit:Token					:= cToken 
	oObjTit:Numero					:= ALLTRIM(SE1->E1_NUM)
	oObjTit:Parcela					:= If(Empty(ALLTRIM(SE1->E1_PARCELA)),"",ALLTRIM(SE1->E1_PARCELA))
	oObjTit:Prefixo					:= ALLTRIM(SE1->E1_PREFIXO)
	oObjTit:ID_Cliente				:= VAL(SE1->E1_CLIENTE)
	oObjTit:EmpProtheus				:= ALLTRIM(SE1->E1_MSEMP)
	oObjTit:CodigoProtheus			:= ALLTRIM(SE1->E1_MSFIL)
	oObjTit:CodigodeBarras			:= ALLTRIM(SE1->E1_CODBAR)
	oObjTit:LinhaDigitavel			:= ALLTRIM(SE1->E1_CODDIG)
	oObjTit:IDCNAB					:= ALLTRIM(SE1->E1_IDCNAB)
	oObjTit:NumeroBancario			:= ALLTRIM(SE1->E1_NUMBCO)
	oObjTit:CodigoBanco				:= ALLTRIM(SE1->E1_PORTADO)
	oObjTit:CodigoRetornoBancario	:= ALLTRIM(SE1->E1_P_RETBA)
	oObjTit:RecNoProtheus			:= SE1->(RECNO())
	oObjTit:DataEmissao				:= SE1->E1_EMISSAO
	oObjTit:Vencimento				:= SE1->E1_VENCREA
	oObjTit:Excluido				:= ""	
	
	cPostParms  := FWJsonSerialize(oObjTit)
	cPostParms  := "{"+SUBSTR(cPostParms,24)
	cPostParms	:= STRTRAN(cPostParms,'TOKEN','Token')
	cPostParms	:= STRTRAN(cPostParms,'NUMEROBANCARIO','NumeroBancario')						
	cPostParms	:= STRTRAN(cPostParms,'NUMERO','Numero')				
	cPostParms	:= STRTRAN(cPostParms,'PARCELA','Parcela')				
	cPostParms	:= STRTRAN(cPostParms,'PREFIXO','Prefixo')				
	cPostParms	:= STRTRAN(cPostParms,'ID_CLIENTE','ID_Cliente')			
	cPostParms	:= STRTRAN(cPostParms,'EMPPROTHEUS','EmpProtheus')			
	cPostParms	:= STRTRAN(cPostParms,'CODIGOPROTHEUS','CodigoProtheus')		
	cPostParms	:= STRTRAN(cPostParms,'CODIGODEBARRAS','CodigodeBarras')		
	cPostParms	:= STRTRAN(cPostParms,'LINHADIGITAVEL','LinhaDigitavel')		
	cPostParms	:= STRTRAN(cPostParms,'IDCNAB','IDCNAB')				
	cPostParms	:= STRTRAN(cPostParms,'CODIGOBANCO','CodigoBanco')			
	cPostParms	:= STRTRAN(cPostParms,'CODIGORETORNOBANCARIO','CodigoRetornoBancario')
	cPostParms	:= STRTRAN(cPostParms,'RECNOPROTHEUS','RecNoProtheus')				
	cPostParms	:= STRTRAN(cPostParms,'EXCLUIDO','Excluido')	

	cRetorno	:= HttpPost(cUrl, cGetParams, cPostParms ,nTimeOut, aHeadStr, @cHeaderGet)	
	cRetorno	:= DecodeUTF8(cRetorno)
	cContInt	:= cPostParms
	 
	If !FWJsonDeserialize(cRetorno, @oObjJson)
		cRetJson    := FWJsonSerialize(oObjJson)		
		cArqLog 	:= cRetJson
		u_HHGEN002("SE1",cChave,lInclui,cContInt,cArqLog)
		
		cEmail		:= cRetJson
		cSubject	:= "ERRO JSON: "+cChave
		
		EnviaEma(cEmail,cSubject)
		
		SQL->(dbSkip())
		Loop
	EndIf
	
	cRetJson    := FWJsonSerialize(oObjJson)		
	cArqLog 	:= cRetJson
	
	If !cValToChar(oObjJson:Answer) $ "200"//Titulos com erro
		AADD(aLogMail,{cChave,cValToChar(oObjJson:Answer),cValToChar(oObjJson:Description),cValToChar(oObjJson:Value[1]:value)})
	EndIf
	
	If cValToChar(oObjJson:Answer) $ "200"//Titulos corretos
		nContOk := nContOk+1
	EndIf		

	RecLock("SE1",.F.)
		SE1->E1_P_RETWS := cValToChar(oObjJson:Answer)
	SE1->(MsUnlock())
	
	u_HHGEN002("SE1",cChave,lInclui,cContInt,cArqLog)
	
	SE1->(DBCloseArea())
	SQL->(dbSkip())
ENDDO

If cEmpAnt $ "HH"
	cNomeEmp := "SOLARIS"
Else
	cNomeEmp := "SULLAIR"
EndIf

If !Empty(aLogMail)
	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252"></head><body>'
	cEmail += '<span style="text-align: left; font-style: italic; font-size: 11pt; font-family: calibri, sans-serif; color: #005A95;">'
	cEmail += 'Log de processamento WebService,'
	cEmail += '<br /><br />'
	
	For nR:=1 to Len(aLogMail)
		cEmail += '<b>Chave do título: </b>'+cValToChar(aLogMail[nR][1])+'<br />'
		cEmail += '<b>Código de resposta: </b>'+cValToChar(aLogMail[nR][2])+'<br />'
		cEmail += '<b>Descrição: </b>'+cValToChar(aLogMail[nR][3])+'<br />'
		cEmail += '<b>Erro: </b>'+cValToChar(aLogMail[nR][4])+'<br /><br />'
	Next nR 
	
	cEmail += '<br />**Favor não responder este e-mail**</span><br />'
	cEmail += '</body></html>'
		
	cSubject	:= "ERRO WEBSERVICE "+cNomeEmp
	
	EnviaEma(cEmail,cSubject)
EndIf

If nContOk > 0
	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252"></head><body>'
	cEmail += '<span style="text-align: left; font-style: italic; font-size: 11pt; font-family: calibri, sans-serif; color: #005A95;">'
	cEmail += 'Log de processamento WebService,'
	cEmail += '<br /><br />'
	cEmail += 'Foram enviados com sucesso '+cValToChar(nContOk)+' títulos via Webservice.'
	cEmail += '<br />'
	
	cEmail += '<br />**Favor não responder este e-mail**</span><br />'
	cEmail += '</body></html>'
		
	cSubject	:= "SUCESSO WEBSERVICE "+cNomeEmp
	
	EnviaEma(cEmail,cSubject)
EndIf

Return

/*
Funcao      : EnviaEma
Parametros  : cEmail,cSubject
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Anderson Arrais	
Data/Hora   : 11/05/2017
*/

*--------------------------------------------------------------*
Static Function EnviaEma(cEmail,cSubject)
*--------------------------------------------------------------*
Local cFrom			:= ""
Local cCC      		:= ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF

cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo 		:= AllTrim(GetNewPar("MV_P_00100"," ")) 
cCC			:= ""
cFrom		:= AllTrim(GetMv("MV_RELFROM"))

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf
	IF !EMPTY(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC ;
		SUBJECT cSubject BODY cEmail RESULT lOK
	ELSE
		SEND MAIL FROM cFrom TO cTo ;
		SUBJECT cSubject BODY cEmail RESULT lOK
	ENDIF
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER   

Return( .t. )

/*/
{Protheus.doc} HHWS003 
Classe de financeiro para realizar a serialização do objeto do SE1
@author Anderson Arrais
@since 10/05/2017
@Type Class
@version 1.0
/*/
Class AtuSE1
	
	Data Token					As String
	Data Numero  				As String
	Data Parcela 				As String
	Data Prefixo 				As String
	Data ID_Cliente				As Integer 
	Data EmpProtheus			As String
	Data CodigoProtheus			As String
	Data CodigodeBarras			As String
	Data LinhaDigitavel			As String
	Data IDCNAB 				As String
	Data NumeroBancario			As String
	Data CodigoBanco  			As String
	Data CodigoRetornoBancario 	As String
	Data RecNoProtheus 			As Integer
	Data DataEmissao 			As data
	Data Vencimento 			As data
	Data Excluido 				As String
			
	Method New(Token, Numero, Parcela, Prefixo, ID_Cliente, EmpProtheus, CodigoProtheus, CodigodeBarras, LinhaDigitavel, IDCNAB, NumeroBancario, CodigoBanco, CodigoRetornoBancario, RecNoProtheus, DataEmissao, Vencimento, Excluido) Constructor 
EndClass

/*/{Protheus.doc} new
Metodo construtor
@author Anderson Arrais
@since 10/05/2017
@Type Method
@version 1.0
/*/
Method New(cToken, cNumTit, nParce, cPrexi, nIDCli, cCodEmp, cCodFil, cCobBar, cLinBar, cIDCNAB, cNumBan, cCodBan, cRetBan, cRecNum, cDatEmi, cDatVen, cExclu) Class AtuSE1

	::Token					  := cToken
	::Numero  				  := cNumTit
	::Parcela 			  	  := nParce 
	::Prefixo 			  	  := cPrexi 
	::ID_Cliente			  := nIDCli 
	::EmpProtheus			  := cCodEmp
	::CodigoProtheus		  := cCodFil
	::CodigodeBarras		  := cCobBar
	::LinhaDigitavel		  := cLinBar
	::IDCNAB 				  := cIDCNAB
	::NumeroBancario		  := cNumBan
	::CodigoBanco  		  	  := cCodBan
	::CodigoRetornoBancario   := cRetBan
	::RecNoProtheus 		  := cRecNum
	::DataEmissao 			  := cDatEmi
	::Vencimento 			  := cDatVen
	::Excluido 			      := cExclu 
		
Return(Self) 