#Include "Protheus.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTFIN010
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina para alteração do parâmetro MV_P_00061, que é a data de bloqueio do baixas a pagar
Autor       : Matheus Massarotto
Data/Hora   : 23/11/2015    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/
*-----------------------*
User Function GTFIN010()
*-----------------------*
Private dDataBlq	:= SUPERGETMV("MV_P_00061", .F. , CTOD("//") )

DbSelectArea("SX6")
SX6->(DbSetOrder(1))
if !SX6->(DbSeek(xFilial("SX6")+"MV_P_00061"))
	Aviso("Bloqueio Fiscal/Contábil (MV_P_00061) - HLB","Parâmetro não existe!",{"Ok"})
	Return
elseif SX6->X6_TIPO <> "D"
	Aviso("Bloqueio Fiscal/Contábil (MV_P_00061) - HLB","Parâmetro MV_P_00061 não é do tipo data!",{"Ok"})
	Return
endif

if !TCCANOPEN("Z23YY0")//Tabela de log
	Aviso("Bloqueio Fiscal/Contábil (Z23) - HLB","Tabela Z23YY0 não encontrada",{"Ok"})
	Return()
endif

//Criação da janela
DEFINE DIALOG oDlg TITLE "Bloqueio de Baixa Contas a Pagar" FROM 100,100 TO 272,376 PIXEL
@ 05,01 SAY "Selecione a data final do bloqueio de baixas a pagar." SIZE 250,20 OF oDlg PIXEL

//Cria o objeto
oMsCalend := MsCalend():New(20,01,oDlg,.F.)

//Define o dia a ser exibido no calendário
oMsCalend:dDiaAtu := dDataBlq

//Define mudança de Dia
oMsCalend:bChange := {||AltData(oMsCalend:dDiaAtu),oDlg:End()}

//Deleta todas as restrições
oMsCalend:DelAllRestri()

//Atualiza o calendário
oMsCalend:CtrlRefresh()

ACTIVATE DIALOG oDlg CENTERED

Return

/*
Funcao      : AltData
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que altera parametro
Autor       : Matheus Massarotto
Data/Hora   : 23/11/2015
*/

*---------------------------------*
Static Function AltData(dDataAtu)
*---------------------------------*
Local lRet	:=	.T.

if dDataAtu <> dDataBlq
	if 	MsgYesNo("Deseja realmente alterar a data para: "+cValToChar(dDataAtu)+" ?","Atenção")
		
		//Grava log
		GravLog(dDataAtu)
		//Atualização do parametro
		PutMv ("MV_P_00061",dDataAtu)

	else
		lRet:=.F.

	endif
else
	Msginfo("Data não foi alterada!")
endif

Return(lRet)

/*
Funcao      : GravLog
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Grava log tabela z23 e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 23/11/2015
*/

*--------------------------------*
Static Function GravLog(dDataAtu)
*--------------------------------*

DbselectArea("Z23")
if select("Z23")>0

	RecLock("Z23",.T.)
		Z23->Z23_EMP	:= cEmpAnt
		Z23->Z23_DATA	:= DATE()
		Z23->Z23_HORA	:= TIME()
		Z23->Z23_CODUSE	:= __cUserID
		Z23->Z23_NOMUSE	:= UsrRetName(__cUserID)
		Z23->Z23_DTBLQA	:= dDataBlq
		Z23->Z23_DTBLQ	:= dDataAtu
	Z23->(MsUnlock())

endif


cTexto := ' <table class="MsoNormalTable" style="WIDTH: 450pt" cellspacing="0" cellpadding="0" width="600" border="0">
cTexto += ' <tbody>
cTexto += ' <tr>
cTexto += ' <td style="PADDING-BOTTOM: 15pt; PADDING-TOP: 15pt; PADDING-LEFT: 15pt; PADDING-RIGHT: 15pt" valign="top">
cTexto += ' <div style="MARGIN-BOTTOM: 5pt; MARGIN-TOP: 5pt">
cTexto += ' <p class="MsoNormal" style="mso-margin-top-alt: auto; mso-margin-bottom-alt: auto"><span style="font-family: Georgia, serif;"><span style="color: rgb(153, 0, 153); font-size: 30pt;"></span><font color="#990099" style="font-size: 30pt;">Informativo</font><br><font size="5">Parâmetro de controle de bloqueio de baixas a pagar alterado</font></span></p>
cTexto += ' <div class="MsoNormal" style="TEXT-ALIGN: center; mso-margin-top-alt: auto; mso-margin-bottom-alt: auto" align="center">
cTexto += ' <hr style="COLOR: black" align="center" size="1" width="100%" noshade="">
cTexto += ' </div></div>
cTexto += ' <p class="MsoNormal" style="mso-margin-top-alt: auto; mso-margin-bottom-alt: auto"></p>
cTexto += ' <p class="margin"><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif; COLOR: black"><br></span></b></p><p class="margin"><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif; COLOR: black">Dados de alteração</span></b><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif">,</span></b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif"></span></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">Empresa: '+alltrim(SM0->M0_NOME)+'</span></font></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">Ambiente: '+alltrim(GetEnvServer())+'</span></font></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">Data de bloqueio anterior: '+DTOC(dDataBlq)+'</span></font></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">Data de bloqueio atual: '+DTOC(dDataAtu)+'</span></font></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">Usuário da alteração: '+UsrRetName(__cUserID)+'</span></font></p>
cTexto += ' <font face="Calibri, sans-serif"><span style="font-size: 11pt;"><strong></strong></span></font>
cTexto += ' <p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"></p><p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><br></p>
cTexto += ' <p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><b><span style="FONT-SIZE: 9pt; COLOR: black">&nbsp;</span></b></p>
cTexto += ' <p class="MsoNormal"><font face="Arial, sans-serif" size="2" color="#ff0000"><b>E-mail informativo enviado automaticamente.</b></font></p><p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><b style="font-size: 14.6667px;"><span style="font-size: 6.5pt; font-family: Arial, sans-serif; color: rgb(116, 118, 120);"><br></span></b></p><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif">
cTexto += ' <p class="MsoNormal"><b><span style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">©2015 HLB BRASIL -&nbsp; Todos os direitos reservados</span></b></p>
cTexto += ' <p class="MsoNormal"><b><span style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678"><a href="http://www.grantthornton.com.br/" target="_blank"><span lang="EN-US">www.GrantThornton.com.br</span></a></span></b><b><span lang="EN-US" style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678"><br></span></b><b><span lang="EN-GB" style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">Member of HLB BRASIL International Ltd</span></b><b><span lang="EN-US" style="FONT-SIZE: 8pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">.</span></b><span lang="EN-US"></span></p></span>
cTexto += ' </td>
cTexto += ' </tr>
cTexto += ' </tbody>
cTexto += ' </table>


EnviaEma(cTexto)

Return

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 01/02/2013 16:25
*/

*-------------------------------------------*
Static Function EnviaEma(cHtml)
*-------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= SUPERGETMV("MV_P_00062", .F. , "" )
Local cTo			:= UsrRetMail ( __cUserID ) //email usuario logado
Local cSubject		:= "Bloqueio baixa a pagar"

Default cTo		 := ""
Default cSubject := ""


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


cFrom			:= '"Log Protheus"<'+cAccount+'>'

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
      SEND MAIL FROM cFrom TO cTo CC cCC;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //BCC "matheus.massarotto@hlb.com.br;alexandre.mori@hlb.com.br";
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //BCC "matheus.massarotto@hlb.com.br;alexandre.mori@hlb.com.br";
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
	conout("GTFIS006--->>> E-mail enviado com sucesso, para o aprovador da proposta")
ELSE
	conout("GTFIS006--->>> Falha no envio do e-mail, para o aprovador da proposta")
ENDIF

RETURN .T.

