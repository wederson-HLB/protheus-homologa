#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : MALTCLI
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. na alteração do cliente
Autor     	: Wederson L. Santana 	
Data     	: 06/02/06
Obs         : 
TDN         : Este ponto de entrada pertence à rotina de cadastro de clientes, MATA030. Ele é executado após a gravação das alterações.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.    
Cliente     : Sector / Reddys
*/


*------------------------*
 User Function MALTCLI() 
*------------------------*  

If cEmpAnt $ "IZ"    //Sector
   Reclock("SA1",.F.)
   Replace SA1->A1_P_LOG With ""
   MsUnlock()
Endif 


/*
Objetivos   : Alteração do produto limpar o campo A1_P_STATS
Autor       : Tiago Luiz Mendonça
Data/Hora   : 04/11/08
*/

If cEmpAnt $ "U2" 
   
   If SA1->(FieldPos("A1_P_STATS")) > 0  
      Reclock("SA1",.F.)
      SA1->A1_P_STATS := ""
      MSUnlock()
   EndIf
   
EndIf 

if cEmpAnt $ "40"
	
	lHistTab	:= GetNewPar("MV_HISTTAB", .F.)
    cAssunto	:= ""
    cMsg		:= ""
    cTo			:= alltrim(SUPERGETMV("MV_P_00037",.F.,"") ) //Para
    cToOculto	:= alltrim(SUPERGETMV("MV_P_00038",.F.,"") ) //cópia oculta
    
	if lHistTab

		cAssunto:=' Codigo '+alltrim(SA1->A1_COD)+' Cliente '+alltrim(SA1->A1_NOME)+' alterado'
		
		
		cMsg+='<div style="text-align: center;">
		cMsg+='			<span style="color:#6633ff;font-family: tahoma, new york, times, serif">C&oacute;digo '+alltrim(SA1->A1_COD)+' Cliente '+alltrim(SA1->A1_NOME)+' alterado</span></div>
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
		cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">Alteraç&atilde;o</span></td>
		cMsg+='					</tr>
		cMsg+='				</tbody>
		cMsg+='			</table>
		cMsg+='			<p>
		cMsg+='				<span style="font-family: tahoma, new york, times, serif">Campo(s) alterado(s):</span></p>
		cMsg+='			<table border="1" cellpadding="1" cellspacing="1" style="width: 800px;">
		cMsg+='				<tbody>
		cMsg+='					<tr>
		cMsg+='						<td style="text-align: center;" width="50">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Campo</span></td>
		cMsg+='						<td style="text-align: center;" width="100">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Conte&uacute;do Anterior</span></td>
		cMsg+='						<td style="text-align: center;" width="100">
		cMsg+='							<span style="font-family: tahoma, new york, times, serif">Conte&uacute;do Novo</span></td>
		cMsg+='					</tr>
		
		For nX := 1 To Len(aCpoAltSA1)
		
			SX3->(DbSetOrder(2))
				if SX3->(DbSeek(aCpoAltSA1[nX][1]))
		
					cMsg+='					<tr>
					cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">'+alltrim(X3TITULO())+"("+alltrim(aCpoAltSA1[nX][1])+")"+'</span></td>'
					cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">'+alltrim(aCpoAltSA1[nX][2])+'</span></td>'
					cMsg+='						<td><span style="color:#6633ff;font-family: tahoma, new york, times, serif">'+alltrim(SA1->&(aCpoAltSA1[nX][1]))+'</span></td>'
					cMsg+='					</tr>
		        
		        endif
		Next
		
		cMsg+='				</tbody>
		cMsg+='			</table>
		cMsg+='			<p>
		cMsg+='				&nbsp;</p>
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
	conout("MALTCLI--->>> E-mail enviado com sucesso, sobre alteração de cliente")
ELSE
	conout("MALTCLI--->>> Falha no envio do e-mail, sobre alteração de cliente")
ENDIF

RETURN .T.

