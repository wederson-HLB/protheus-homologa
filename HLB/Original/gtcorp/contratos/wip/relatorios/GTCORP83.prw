#Include "Protheus.ch"
#Include "Ap5mail.ch"
#Include "Topconn.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTCORP83
Parametros  : 
Retorno     : Nil
Objetivos   : Fonte utilizado por schedules, para envio de e-mail informativo com contrato/proposta onde a proposta ainda não foi entregue assinada 
Autor       : Matheus Massarotto
Data/Hora   : 01/11/2013    
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*------------------------------*
User function GTCORP83(aParam)
*------------------------------*
if empty(aParam[1]) .AND. empty(aParam[2])	//Empresas que serão executados
	CONOUT("GTCORP83 -- >> ERRO: Não foi informado as empresas na passagem de parametro para a rotina!")
	Return()
endif

cFil:="01"

//for i:=1 to len(aParam)

	if Select("SX3")<=0
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa aParam[1] Filial cFil
	endif
	
	cHtml	:= CriaHtml(aParam)
	cTo		:= "fernanda.abranches@br.gt.com;andressa.freitas@br.gt.com"
	cSubject:= "Pendencia de assinatura"
	
	if !empty(cHtml)
		EnviaEma(cHtml,cSubject,cTo)
    endif
    
//next

Return

*---------------------------*
Static function CriaHtml(aParam)
*---------------------------*
Local cHtml	:= ""
Local cQry	:= ""

//query - os contratos com data de inclusão superior a 01/10/13, cujo campo CN9_DTPROP esteja vazio

cQry+=" SELECT CN9_NUMERO,CN9_P_NUM,CN9_P_NOME,'"+alltrim(FWGrpName(aParam[1]))+"' as EMPRESA,CN9_FILIAL,'"+aParam[1]+"' AS CODEMP,Z55_NOMESO,Z55_NOMEGE FROM CN9"+alltrim(aParam[1])+"0 CN9
cQry+=" LEFT JOIN Z55"+alltrim(aParam[1])+"0 Z55 ON CN9_P_NUM=Z55_NUM
cQry+=" WHERE CN9.D_E_L_E_T_='' AND CN9_REVATU=''
cQry+=" AND Z55.D_E_L_E_T_='' AND Z55.Z55_STATUS<>'G'
cQry+=" AND CN9_DTINIC>='20131001' AND CN9_DTPROP=''
 
cQry+=" UNION ALL 

cQry+=" SELECT CN9_NUMERO,CN9_P_NUM,CN9_P_NOME,'"+alltrim(FWGrpName(aParam[2]))+"' as EMPRESA,CN9_FILIAL,'"+aParam[2]+"' AS CODEMP,Z55_NOMESO,Z55_NOMEGE FROM CN9"+alltrim(aParam[2])+"0 CN9
cQry+=" LEFT JOIN Z55"+alltrim(aParam[2])+"0 Z55 ON CN9_P_NUM=Z55_NUM
cQry+=" WHERE CN9.D_E_L_E_T_='' AND CN9_REVATU=''
cQry+=" AND Z55.D_E_L_E_T_='' AND Z55.Z55_STATUS<>'G'
cQry+=" AND CN9_DTINIC>='20131001' AND CN9_DTPROP=''

//Verifico se dará erro na query
if TCSQLExec(cQry) < 0
	CONOUT("GTCORP83 -->> ERRO: "+CRLF+CRLF+TCSQLError())
	Return(cHtml)
endif

if select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount
        
if nRecCount >0
	QRYTEMP->(DbGoTop())


	cHtml+=' <head>
	cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
	cHtml+=' </head>
	cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000">
	cHtml+=' <div><span>

	cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 100.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
	cHtml+=' <tbody>
	cHtml+=' <tr>
	cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">

	cHtml+=' <img border="0" width="272" height="62" id="Imagem_x0020_1" src="http://www.grantthornton.com.br/images/logo.gif">
	cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
	cHtml+=' <p>&nbsp;
	cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
	cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | Propostas</font></strong></span></span></p></td></tr>

	cHtml+=' <tr>
	cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A(s) proposta(s) abaixo está(ão) pendente(s) de&nbsp;assinatura: </span>
	cHtml+=' </span>
	cHtml+=' </td></tr>
	cHtml+=' </div>
	
	cHtml+=' </tbody>

	cHtml+=' <tr><td colspan="2">
	
	cHtml+=' <p><span></span>&nbsp;</p>
	cHtml+=' <p><span>&nbsp;</span></p>
	cHtml+=' <table style="WIDTH: 950pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
	cHtml+=' <colgroup>
	cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
	cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
	cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
	cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
	cHtml+=' </colgroup>
	
	cHtml+=' <tbody>
	cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Contrato</font></strong></p>
	cHtml+=' </td>
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Proposta</font></strong></p>
	cHtml+=' </td>
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Cliente</font></strong></p></td>
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Sócio</font></strong></p></td>
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Gerente</font></strong></p></td>
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Empresa/Filial</font></strong></p></td>
	cHtml+=' </tr>
	
	While QRYTEMP->(!eof())
	
		cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(QRYTEMP->CN9_NUMERO)+'</font>'
		cHtml+=' </td>
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(QRYTEMP->CN9_P_NUM)+'</font>'
		cHtml+=' </td>
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(QRYTEMP->CN9_P_NOME)+'</font> '
		cHtml+=' </td>
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(QRYTEMP->Z55_NOMESO)+ '</font> '
		cHtml+=' </td>
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(QRYTEMP->Z55_NOMEGE)+ '</font> '
		cHtml+=' </td>
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(QRYTEMP->EMPRESA)+"/"+alltrim( FWFilialName(QRYTEMP->CODEMP,QRYTEMP->CN9_FILIAL) )+ '</font> '
		cHtml+=' </td>
		cHtml+=' </tr>
		
	QRYTEMP->(DbSkip())
	Enddo
	
	cHtml+=' </tbody></table><span></span>


	cHtml+=' </td></tr>
	cHtml+=' <tr><td>
	cHtml+=' <p><br><br><br>&nbsp;</p>
	
	cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
	cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>
	
	cHtml+=' </td></tr>
	cHtml+=' </table>
		
	cHtml+=' </body>
	//cHtml+=' </html>

endif

Return(cHtml)


/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 01/02/2013 16:25
*/

*-------------------------------------------*
Static Function EnviaEma(cHtml,cSubject,cTo)
*-------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""
//Local cTo			:= "matheus.massarotto@br.gt.com"

Default cTo		 := ""
Default cSubject := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("GTCORP83 -->> Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("GTCORP83 -->> Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("GTCORP83 -->> E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   


cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)


cFrom			:= '"Controle de Proposta"<'+cAccount+'>'


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("GTCORP83 -->> Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         conout("GTCORP83 -->> Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //BCC "matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com";
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //BCC "matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com";
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
	conout("GTCORP83--->>> E-mail enviado com sucesso, para o aprovador da proposta")
ELSE
	conout("GTCORP83--->>> Falha no envio do e-mail, para o aprovador da proposta")
ENDIF

RETURN .T.