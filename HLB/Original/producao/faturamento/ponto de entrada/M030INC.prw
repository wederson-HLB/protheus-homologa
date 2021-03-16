#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : M030INC
Parametros  : PARAMIXB
Retorno     : 
Objetivos   : P.E. na inclusão do cliente
Autor     	: Matheus Massarotto
Data     	: 05/01/15
Obs         : 
TDN         : APÓS INCLUSÃO DO CLIENTE. Este Ponto de Entrada é chamado após a inclusão dos dados do cliente no Arquivo.
Módulo      : Faturamento.    
*/

*------------------------*
User Function M030INC() 
*------------------------*  

// Se for diferente de 1 é que não confirmou a inclusão do cliente
if PARAMIXB <> 1
	Return
endif

if cEmpAnt $ "40"
	
	lHistTab	:= GetNewPar("MV_HISTTAB", .F.)
    cAssunto	:= ""
    cMsg		:= ""
    cTo			:= alltrim(SUPERGETMV("MV_P_00037",.F.,"") ) //Para
    cToOculto	:= alltrim(SUPERGETMV("MV_P_00038",.F.,"") ) //cópia oculta
    
	if lHistTab

		cAssunto:=' Codigo '+alltrim(SA1->A1_COD)+' Cliente '+alltrim(SA1->A1_NOME)+' incluido'
		
		
		cMsg+='<div style="text-align: center;">
		cMsg+='			<span style="color:#6633ff;font-family: tahoma, new york, times, serif">C&oacute;digo '+alltrim(SA1->A1_COD)+' Cliente '+alltrim(SA1->A1_NOME)+' inclu&iacute;do</span></div>
		cMsg+='		<div style="text-align: center;">
		cMsg+='			&nbsp;</div>
		cMsg+='		<div>
		cMsg+='			<table border="0" cellpadding="1" cellspacing="1" style="width: 500px;">
		cMsg+='				<tbody>
		cMsg+='					<tr>
		cMsg+='						<td width="80">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Usu&aacute;rio:</span></td>
		cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">'+alltrim(UsrRetName(__cUserID))+'</span></td>
		cMsg+='					</tr>
		cMsg+='					<tr>
		cMsg+='						<td width="80">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Data:</span></td>
		cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">'+DTOC(dDataBase)+'</span></td>
		cMsg+='					</tr>
		cMsg+='					<tr>
		cMsg+='						<td width="80">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Hora:</span></td>
		cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">'+Time()+'</span></td>
		cMsg+='					</tr>
		cMsg+='					<tr>
		cMsg+='						<td width="80">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Tipo:</span></td>
		cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">Inlus&atilde;o</span></td>
		cMsg+='					</tr>
		cMsg+='				</tbody>
		cMsg+='			</table>

		cMsg+='			<p>
		cMsg+='				&nbsp;</p>
		cMsg+='		</div>
		cMsg+='		<p style="text-align: center;">
		cMsg+='			<span style="color:#ff0000;">Mensagem autom&aacute;tica, favor n&atilde;o responder este e-mail.</span></p>
		cMsg+='		<hr />
		cMsg+='		<p>
		cMsg+='			&nbsp;</p>

	
		EnviaEma(cMsg,cAssunto,cTo,cToOculto)
	
	endif  
  
endif
 
Return 

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 05/01/2015 10:20
*/

*-----------------------------------------------------*
Static Function EnviaEma(cHtml,cSubject,cTo,cToOculto)
*-----------------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""

Default cTo		 := ""
Default cSubject := ""
Default cToOculto:= ""

/*if cEmpAnt $ "99" .OR. "TESTE" $ alltrim(UPPER(GetEnvServer()))
	cTo := "matheus.massarotto@hlb.com.br;eduardo.romanini@hlb.com.br"
	
	if cEmpAnt $ "99"
		cTo := "matheus.massarotto@hlb.com.br"
	endif
	
endif
*/
IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   


cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)


cFrom			:= '"Controle de Cadastro"<'+cAccount+'>'


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo BCC cToOculto ;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
	conout("M030INC--->>> E-mail enviado com sucesso, sobre alteração de cliente")
ELSE
	conout("M030INC--->>> Falha no envio do e-mail, sobre alteração de cliente")
ENDIF

RETURN .T.