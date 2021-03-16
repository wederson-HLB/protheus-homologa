#Include "Protheus.ch"
#Include "Ap5mail.ch"
#Include "Topconn.ch"
#include "SHELL.CH"

/*
Funcao      : GTCORP13
Parametros  : 
Retorno     : Nil
Objetivos   : 	Relatório inicialmente desenvolvido pelo pessoal da Gestão Dinâmica.
			:	Mas as informações apresentadas não estavam de acordo com o que o pessoal do faturamento apresentava.
			:	O programa foi refeito.
			: 	Relatório de Faturamento Real X Orcado - com a segmentação de 2 grupos Auditores(ZB,ZF) e Consulting(CH,RH,Z4,Z8,ZP)
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012    16:34
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

User Function GTCORP13
Local aArea			:=GETAREA()
Local cTitiEmp		:="" //Armazena o nome da empresa a qual será exibido no título do e-mail
Local cPerg			:="GTCORP13_P"	//Pergunta para saber qual empresa base será utilizada

PutSx1( cPerg, "01", "Empresa?:"		, "Empresa?"		, "Empresa?"		, "", "N",1,00,00,"C","" 					 , "","","","MV_PAR01","Auditores","","","","Consulting")
PutSx1( cPerg, "02", "Calend Contábil?:", "Calend Contábil?", "Calend Contábil?", "", "C",4,00,00,"G","U_VdGTCO43(MV_PAR02)" , "","","","MV_PAR02",""		  ,"","","","",,,,,,,,,,,,{"Ano do calendário no formato(aaaa)."})      //MSM - 26/10/2012 - Adicionado pergunte para o calendário contábil, chamado: 007456

If !Pergunte(cPerg,.T.)
	Return()
EndIf

if MV_PAR01==1
	Private cEmpMandante	:="ZB"
	Private cMsg			:=""
	Private aEmpGera	:={} //Empresas para gerar o relatório 
	Private aEmpGera2	:={} //Empresas para segregação de valores da Z4
	//Seleção das empresas
	
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	
	While SM0->(!EOF())
		//if SM0->M0_CODIGO $ "ZB,ZF,MQ,MW,MY,PN" - VYB - 22/08/2016 - Chamado 035252
		if SM0->M0_CODIGO $ "ZB,ZF,MQ,MW,MY,PN,ZG"  
			if SM0->M0_CODIGO == "ZF" .And. SM0->M0_CODFIL $ "01" 
				AADD(aEmpGera,{ALLTRIM(SM0->M0_CODIGO)+"1",alltrim(SM0->M0_NOME)+" Tax"})
				AADD(aEmpGera,{ALLTRIM(SM0->M0_CODIGO)+"2",alltrim(SM0->M0_NOME)+" Advisory"})
		    else 
		    	if SM0->M0_CODFIL $ "01"
		    		AADD(aEmpGera,{SM0->M0_CODIGO,SM0->M0_NOME})
		    	endif
	    	endif
		endif
		SM0->(DbSkip())
	EndDo

	//Busco a posição da empresa que é a mandante para exibição do relatório
	cTitEmp:=aEmpGera[aScan(aEmpGera,{|x| Alltrim(x[1]) == cEmpMandante})][2]
	
	//Monta o corpo do e-mail
	cMsg:=MontaEm2(aEmpGera,cTitEmp)
	
else

	Private cEmpMandante	:="Z4"
	Private cMsg			:=""
	Private aEmpGera	:={} //Empresas para gerar o relatório 
	Private aEmpGera2	:={} //Empresas para segregação de valores da Z4
	Private aEmpNome	:={} //Array com os nomes da empresas
	//VYB - 31/08-2016 - Chamado 035252 - Inclusão da empresa ZA
	Private aSeqEmp:={"CH","RH","Z8","ZP","4C","4K","Z4","JW","MP","8F","ZA"}
	//JSS - 20150522 Add empresa 8F para atender o caso 026144.// MSM 25/06/2012 -- Array com informações de empresas que serão exibidas no realtório com a sua sequência
	//Seleção das empresas
	
	DbSelectArea("SM0")
	SM0->(DbGoTop())

	For i:=1 to len(aSeqEmp)	
		SM0->(DbSeek(aSeqEmp[i]))
		
		While SM0->(!EOF()) .AND. SM0->M0_CODIGO==aSeqEmp[i]
			//if SM0->M0_CODIGO $ "CH,RH,Z4,Z8,ZP" 
				if SM0->M0_CODIGO == "Z4" 
		 			if SM0->M0_CODFIL == "05"
						AADD(aEmpGera,{SM0->M0_CODIGO,"OUTSOURCING"})
					endif
			        
			        if SM0->M0_CODFIL <> "04" //CURITIBA //não adiciona curutiba por enquanto
				        //Armazena no segundo array as informações para segregação da Z4
				   		//VYB - 22/08-2016 - Chamado 035252 - Alteração do título para M0_FILIAL
				   		AADD(aEmpGera2,{SM0->M0_CODIGO,SM0->M0_NOME,SM0->M0_CODFIL})
				   		AADD(aEmpNome,{SM0->M0_CODIGO,SM0->M0_FILIAL,SM0->M0_FILIAL})
				 	endif

		    	else 
			    	
			    	if SM0->M0_CODFIL $ "01"
			    		if SM0->M0_CODIGO == "4C" 
			    			AADD(aEmpGera,{SM0->M0_CODIGO,SM0->M0_FILIAL})
			    		else
				    		AADD(aEmpGera,{SM0->M0_CODIGO,SM0->M0_NOME})
			    		endif
			    	endif   
			    	
		    	endif
			//endif
			SM0->(DbSkip())
		EndDo
    Next

	//Busco a posição da empresa que é a mandante para exibição do relatório
	cTitEmp:=aEmpGera[aScan(aEmpGera,{|x| Alltrim(x[1]) == cEmpMandante})][2]
	
	//Monta o corpo do e-mail
	cMsg:=MontaEm1(aEmpGera,cTitEmp)
	
endif

cAssunto:='[GTCORP] - Desempenho '+alltrim(Str(Year(ddatabase)))+' '+alltrim(cTitEmp)+' em ' + DTOC(date())
_cTo:=""

//Envia o e-mail
ENVIA_EMAIL("","Desempenho Gerencial",cAssunto,cMsg,.F.,_cTo,"")

RestArea(aArea)
Return 

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cArquivo,cTitulo,cSubject,cBody,lShedule,cTo,cCC
Retorno     : .T.
Objetivos   : Função para envio do e-mail/tela de apresentação, Baseada na Rotina do ALEX WALLAUER (AWR)
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012
*/

*-----------------------------------------------------------------------------------------*
Static Function ENVIA_EMAIL(cArquivo,cTitulo,cSubject,cBody,lShedule,cTo,cCC)
*-----------------------------------------------------------------------------------------*
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg
Local cBody1:=""

DEFAULT cArquivo := ""
DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT lShedule := .F.
DEFAULT cTo      := ""
DEFAULT cCc      := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   IF !lShedule
      MSGINFO("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   ELSE
      ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   ENDIF
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   IF !lShedule
      MSGINFO("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   ELSE
      ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   ENDIF
   RETURN .F.
ENDIF   

IF lShedule .AND. EMPTY(cTo)
   IF !lShedule
      ConOut("E-mail para envio, nao informado.")
   ENDIF
   RETURN .F.
ENDIF   

PswOrder(1)
PswSeek(__CUSERID,.T.)
aUsuario:= PswRet()
cFrom:= Alltrim(aUsuario[1,14])
cUser:= Subs(cUsuario,7,15)
cCC  := cCC + SPACE(200)
cTo  := cTo + SPACE(200)
cSubject:=cSubject+SPACE(100)

IF EMPTY(cFrom)
   IF !lShedule
       MsgInfo("E-mail do remetente nao definido no cad. do usuario: "+cUser)
   ELSE
       ConOut("E-mail do remetente nao definido no cad. do usuario: "+cUser)
   ENDIF
   RETURN .F.
ENDIF

DO WHILE !lShedule

   nOp  :=0
   nCol1:=8
   nCol2:=33
   nSize:=225  
   nLinha:=15 

   DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 550,544 PIXEL TITLE "Envio de E-mail"
        
  		@ nLinha,nCol1 Say "Titulo:"  Size 12,8              OF oDlg PIXEL
        @ nLinha,nCol2 MSGET cTitulo  SIZE nSize,10 WHEN .F. OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say "Usuario:" Size 20,8              OF oDlg PIXEL
        @ nLinha,nCol2 MSGET cUser    SIZE nSize,10 WHEN .F. OF oDlg PIXEL
        nLinha+=20

  		@ 000005,nCol1-4 To nLinha   ,268 LABEL " Informacoes " OF oDlg PIXEL
        nLinha+=05
        nLinAux:=nLinha
        nLinha+=10

  		@ nLinha,nCol1 Say   "De:"      Size 012,08             OF oDlg PIXEL 
  		@ nLinha,nCol2 MSGET cFrom      Size nSize,10 WHEN .F.  OF oDlg PIXEL 
        nLinha+=15

  		@ nLinha,nCol1 Say   "Para:"    Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cTo        Size nSize,10  F3 "_EM" OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "CC:"      Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cCC        Size nSize,10  F3 "_EM" OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Assunto:" Size 021,08             OF oDlg PIXEL
  		@ nLinha,nCol2 MSGET cSubject   Size nSize,10           OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "Corpo:"   Size 016,08             OF oDlg PIXEL
  		@ nLinha,nCol2 Get   cBody1      Size nSize,120  MEMO    OF oDlg PIXEL HSCROLL

  		@ nLinAux,nCol1-4 To nLinha+128,268 LABEL " Dados de Envio " OF oDlg PIXEL 
        nLinha+=135
    
    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-225 TYPE 13 ACTION(GExecl(cBody)) ENABLE Of oDlg Pixel
    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-90 TYPE 1 ACTION (If(Empty(cTo),Help("",1,"AVG0001054"),(oDlg:End(),nOp:=1))) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-45 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOp = 0
      RETURN .T.
   ENDIF

   EXIT

ENDDO

cAttachment:=cArquivo
cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)
cCC := AvLeGrupoEMail(cCC)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   IF !lShedule
       MsgInfo("Falha na Conexão com Servidor de E-Mail")
   ELSE
       ConOut("Falha na Conexão com Servidor de E-Mail")
   ENDIF
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      IF !lShedule
         MsgInfo("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
      ELSE
         ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
      ENDIF
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
   IF !lShedule
      MsgInfo("E-mail enviado com sucesso.")
   ELSE
      ConOut("E-mail enviado com sucesso.")
   ENDIF
ENDIF   

RETURN .T.

/*
Funcao      : MontaEm1()
Parametros  : aEmpGera,cTitEmp
Retorno     : _cHtml
Objetivos   : Monta a estrutura do e-mail (Consulting)
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	16:41
*/

*-----------------------------------*
Static Function MontaEm1(aEmpGera,cTitEmp)
*-----------------------------------*
Local _cSubject	:= ""
Local _cTo		:= ""
Local _cHtml	:= ""        
LOCAL _ccopia  	:= ""
Local _cENVIA  	:= ""
Local _cArqD   	:= ""                                                      	
Local _cNomeCli :=''
Local _cSubject := '[GTCORP] - Desempenho '+alltrim(Str(Year(ddatabase)))+' '+cTitEmp+' em ' + DTOC(date())

Local cHtmlAux1:=""
Local cHtmlAux2:=""
Local aReal	:= Query(aEmpGera)
Local aReal2:= Query(aEmpGera2,.T.)
             
Local aRealA := QueryAnt(aEmpGera)
Local aReal2A:= QueryAnt(aEmpGera2,.T.)

Local aOrcado := QueryORC(aEmpGera)
Local aOrcado2:= QueryORC(aEmpGera2,.T.)

Local cAnoA:=RIGHT(alltrim(cvaltochar(val(MV_PAR02)-1)),2)
Local cAno:=RIGHT(alltrim(MV_PAR02),2)

Local cMasc:="@E 999,999,999,999" //"@E 999,999,999,999.99"
Local cMascPerc:="@E 9999%" //"@E 9999.99"

Local aQtReaA	:=ARRAY(len(aEmpGera))
Local aQtRea	:=ARRAY(len(aEmpGera))
Local aQtOrc	:=ARRAY(len(aEmpGera))

Local nQtReaA	:=0
Local nQtRea	:=0
Local nQtOrc	:=0

Local aQtReaA2	:=ARRAY(len(aEmpGera2))
Local aQtRea2	:=ARRAY(len(aEmpGera2))
Local aQtOrc2	:=ARRAY(len(aEmpGera2))

Local nQtReaA2	:=0
Local nQtRea2	:=0
Local nQtOrc2	:=0

Local aTotReaA	:=ARRAY(len(aEmpGera))
Local aTotRea	:=ARRAY(len(aEmpGera))
Local aTotOrc	:=ARRAY(len(aEmpGera))

Local aTotReaA2	:=ARRAY(len(aEmpGera))
Local aTotRea2	:=ARRAY(len(aEmpGera))
Local aTotOrc2	:=ARRAY(len(aEmpGera))

AFILL(aQtReaA,0)
AFILL(aQtRea,0)
AFILL(aQtOrc,0)

AFILL(aQtReaA2,0)
AFILL(aQtRea2,0)
AFILL(aQtOrc2,0)

AFILL(aTotReaA,0)
AFILL(aTotRea,0)
AFILL(aTotOrc,0)

AFILL(aTotReaA2,0)
AFILL(aTotRea2,0)
AFILL(aTotOrc2,0)

_cHtml+='   <html xmlns="http://www.w3.org/1999/xhtml">                                                           '
_cHtml+='   <head>                                                                                                           '
_cHtml+='   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />                                            '
_cHtml+='   <title>Desempenho GTCORP '+alltrim(Str(Year(ddatabase)))+' '+cTitEmp+'</title>                                                                                '
_cHtml+=' 	<style type="text/css">'
_cHtml+=' 	.bordabx{ '
_cHtml+='		border-top-style:none;'
_cHtml+='		border-right-style:none;'
_cHtml+='		border-bottom-style:solid;'
_cHtml+='		border-left-style:none;'
_cHtml+='  		border-bottom-width: 1,0px;'
_cHtml+=' 		border-bottom-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordaci{ '
_cHtml+='		border-top-style:solid;'
_cHtml+='		border-right-style:none;'
_cHtml+='		border-bottom-style:none;'
_cHtml+='		border-left-style:none;'
_cHtml+='  		border-top-width: 1,0px;'
_cHtml+=' 		border-top-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordacidi{ '
_cHtml+='		border-top-style:solid;'
_cHtml+='		border-right-style:solid;'
_cHtml+='		border-bottom-style:none;'
_cHtml+='		border-left-style:none;'
_cHtml+='  		border-top-width: 1,0px;'
_cHtml+=' 		border-top-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordacicor{ '
_cHtml+='		border-top-style:solid;'
_cHtml+='		border-right-style:none;'
_cHtml+='		border-bottom-style:none;'
_cHtml+='		border-left-style:none;'
_cHtml+='  		background-color: #AA92C7;'
_cHtml+='  		border-top-width: 1,0px;'
_cHtml+=' 		border-top-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordadi{ '
_cHtml+='		border-top-style:none;'
_cHtml+='		border-right-style:solid;'
_cHtml+='		border-bottom-style:none;'
_cHtml+='		border-left-style:none;'
_cHtml+='  		border-bottom-width: 1,0px;'
_cHtml+=' 		border-bottom-color:#000000;'
_cHtml+=' 		border-collapse:collapse;'
_cHtml+='	}'
_cHtml+=' 	.bordabxdi{ '
_cHtml+='		border-top-style:none;'
_cHtml+='		border-right-style:solid;'
_cHtml+='		border-bottom-style:solid;'
_cHtml+='		border-left-style:none;'
_cHtml+='  		border-bottom-width: 1,0px;'
_cHtml+=' 		border-bottom-color:#000000;'
_cHtml+=' 		border-collapse:collapse;'
_cHtml+='	}'
_cHtml+=' 	.corCol {'			//#CCF	
_cHtml+=' 		background-color: #AA92C7;'
_cHtml+=' 	}'

_cHtml+=' p'
_cHtml+=' {'
_cHtml+=' text-align:center;'
_cHtml+=' font-size:9px;'
_cHtml+=' width:40px;'
_cHtml+=' color:#FFFFFF;'
_cHtml+=' }'

_cHtml+=' 	</style>'
_cHtml+='   </head>                                                                                                         '
_cHtml+='                                                                                                                   '
_cHtml+='   <body marginheight="0" marginwidth="0" style="margin:0"><br />                                                  '
_cHtml+='                                                                                                                   '
_cHtml+='   <table width="'+cvaltochar(IIF(len(aEmpGera)>len(aEmpGera2),len(aEmpGera),len(aEmpGera2))*(550))+'" cellpadding="0" cellspacing="0" border="0" style="font-family:Arial; font-size:12px; font-weight:normal; color:#000000">                         '
_cHtml+='   <tr>                                                                                                            '
_cHtml+='   <td align="center" valign="top">                                                                                '
_cHtml+='   	<table width="100%" cellpadding="0" cellspacing="0" border="0">                                            '
_cHtml+='   		<tr>                                                                                                  '
_cHtml+='           	<td align="center" valign="middle" bgcolor="#0a4c9d" style="color:#FFFFFF; line-height:50px; font-weight:bold; font-size:16px>Desempenho GTCORP '+alltrim(str(Year(dDatabase)))+' </td>'
_cHtml+='           </tr>                                                                                                   '
_cHtml+='   	</table>                                                                                                       '
_cHtml+='   <table width="94%" cellpadding="0" cellspacing="0" border="0">                                                     '
_cHtml+='   <tr>                                                                                                               '
_cHtml+='   <td>                                                                                                               '
_cHtml+='       <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:12px">                         '
_cHtml+='   		<tr>                                                                                                       '
_cHtml+='           	<td width="60%"></td>                                                                                  '
_cHtml+='               <td width="20%" align="right" colspan="3">emitido em:  '+dtoc(date())+'</td>                                      '
_cHtml+='               <td width="20%" align="right" colspan="3">Ano calendario contabil:  '+MV_PAR02+'</td>                         ' // MSM - 26/10/2012 - Incluído para apresentar o ano do calendário contábil gerado, chamado: 007456
_cHtml+='           </tr>                                                                                                      '
_cHtml+='           <tr>                                                                                      '
_cHtml+='           	<td align="left" style="font-size:14px" colspan="3"><b>Faturamento Real x Orcado</b></td>                                '
_cHtml+='               <td align="right" colspan="3">Fonte: GTCORP ERP Microsiga</td>                                    '
_cHtml+='           </tr>                                                                                     '
_cHtml+='   	</table>                                                                                      '
_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '

					//#365F91                       
_cHtml+='<tr bgcolor="#7A59A5" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td style="font-weight:bold" width="130px" align="center" class="bordabx">&nbsp;</td>                                     '

	//Montagem do cabeçalho com o nome das empresas
	for i:=1 to len(aEmpGera)
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '                                                                          
		_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx" colspan="5">'+aEmpGera[i][2]+'</td>         '
		// old _cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                    '                                                                        
	    //_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabxdi">&nbsp;</td>                    '
	
		//Montagem do cabeçalho com a descrição de Orcado Real %
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAnoA+'</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Orcado</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAno+'</td>'
		//cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">%</td>'		
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>'//%		
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabxdi">FY '+cAnoA+' x FY '+cAno+'</td>'		
		//cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>'//%		
		//cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabxdi">FY '+cAnoA+' x FY '+cAno+'</td>'

	next	

	//Montagem do Total Geral - Ultima coluna
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '
		_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx" colspan="5">Total Geral</td>         '
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                    '
		
	
		//Montagem do cabeçalho com a descrição de Orcado Real %
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAnoA+'</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Orcado</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAno+'</td>'
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>' //%
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">FY '+cAnoA+' x FY '+cAno+'</td>'		
		
    //FIM Montagem do Total Geral - Ultima coluna

_cHtml+='</tr>                                                                                                '
_cHtml+='<tr bgcolor="#7A59A5" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td width="131px" class="bordabx">&nbsp;</td>                                                                              '

// Passa para a montagem do cabeçalho a váriável com o conteudo de Orcado/Real/%
_cHtml+=cHtmlAux1

_cHtml+='</tr>                                                                                                '

   aTotO:=ARRAY(len(aEmpGera))
   AFILL(aTotO,0)
   
   aTotEmpR:=ARRAY(len(aEmpGera))
   AFILL(aTotEmpR,0)
   aTotMesR:=ARRAY(12)
   AFILL(aTotMesR,0)
   
   aTotEmpO:=ARRAY(len(aEmpGera))
   AFILL(aTotEmpO,0)
   aTotMesO:=ARRAY(12)
   AFILL(aTotMesO,0)

   aTotEmpRA:=ARRAY(len(aEmpGera))
   AFILL(aTotEmpRA,0)
   aTotMesRA:=ARRAY(12)
   AFILL(aTotMesRA,0)

nTotGO:=nTotGR:=nTotGRA:=0

nToFGO:=nToFGR:=nToFGRA:=0

//Montagem do corpo da estrutura do mês | Orcado | Real | % - informações de valores
For l:=1 to 12
	_cHtml+='           <tr>                                                                                                   '
	_cHtml+='        	    <td bgcolor="#7A59A5" align="left" style="color:#FFFFFF; line-height:24px">'+RetMes(l)+'</td>      '
	nCtlCor:=0
	For c:=1 To Len(aEmpGera)
	nCtlCor++

		//++Calcula a parte do Real FY Ano anterior a data selecionada
		nPosData:=nPosEmp:=0
		nVlRealA:=0
		
		nPosEmp:=aScan(aRealA,{|x| Alltrim(x[1]) == aEmpGera[c][1] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aRealA,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0 .AND. alltrim(aRealA[nPosData][1])==alltrim(aEmpGera[c][1])
	        	nVlRealA:=aRealA[nPosData][3]
	        	aQtReaA[c]+=1
	        endif
	    
	    endif
	    
		_cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(nVlRealA,0),cMasc)+'</td>  '		

		//++Calcula a parte do Orçado
		nPosData:=nPosEmp:=0
		nValOrc:=0
		
		nPosEmp:=aScan(aOrcado,{|x| Alltrim(x[1]) == aEmpGera[c][1] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aOrcado,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0
	        	nValOrc:=aOrcado[nPosData][3]	
	        	aQtOrc[c]+=1
	        endif
	    
	    endif	    

	    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+TRANS(nValOrc,"@E 999,999,999,999.99")+'</td>  '
	    _cHtml+='           <td align="right" > '+TRANS(ROUND(nValOrc,0),cMasc)+'</td>  '
        
		//++Calcula a parte do Real
		nPosData:=nPosEmp:=0
		nValReal:=0
		
		nPosEmp:=aScan(aReal,{|x| Alltrim(x[1]) == aEmpGera[c][1] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aReal,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0 .AND. alltrim(aReal[nPosData][1])==alltrim(aEmpGera[c][1])
	        	nValReal:=aReal[nPosData][3]	
	        	aQtRea[c]+=1
	        	
	        	//Para fazer a média do FY anterior e Orçado somente dos meses que tem FY atual
	        	aTotReaA[c]	+=nVlRealA
	        	aTotRea[c]	+=nValReal
	        	aTotOrc[c]	+=nValOrc
	        endif
	    
	    endif
	    
	    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="corCol"','')+'> '+TRANS(nValReal,"@E 999,999,999,999.99")+'</td>  '		
	    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(nValReal,0),cMasc)+'</td>  '		
	    
	    //++Calcula a porcentagem	    
        _nVar:=0
	    _cColor:=iif(nValOrc > nValReal,'#FF0000','#0000FF') 
	    _nVar:=Round(iif(nValOrc==0,0,(100*(nValReal/nValOrc))-100),0)
        //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+IIF(nValReal>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
        _cHtml+='           <td align="right" style="color:'+ _cColor +'" > '+IIF(nValReal>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
                                                                                                                                                     
	    //++Calcula a porcentagem FY Anterior com o FY Atual
        _nVarFYA:=0
	    _cColorA:=iif(nVlRealA > nValReal,'#FF0000','#0000FF') 
	    _nVarFYA:=Round(iif(nVlRealA==0,0,(100*(nValReal/nVlRealA))-100),0)
        _cHtml+='           <td align="right" style="color:'+ _cColorA +'"  class="bordadi"> '+IIF(nValReal>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '

        aTotMesRA[l]+=nVlRealA
		aTotEmpRA[c]+=nVlRealA		
        aTotMesR[l]+=nValReal
		aTotEmpR[c]+=nValReal
        aTotMesO[l]+=nValOrc
		aTotEmpO[c]+=nValOrc

	Next
	
	//Montagem dos Totais Gerais - Ultima coluna

	_nVar:=0
	_cColor:=iif(aTotMesO[l] > aTotMesR[l],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotMesO[l]==0,0,(100*(aTotMesR[l]/aTotMesO[l]))-100),0)

	//FY Anterior x FY Atual
	_nVarFYA:=0
	_cColorA:=iif(aTotMesRA[l] > aTotMesR[l],'#FF0000','#0000FF') 
    _nVarFYA:=Round(iif(aTotMesRA[l]==0,0,(100*(aTotMesR[l]/aTotMesRA[l]))-100),0)
											//aOrc[l][lt]
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="corCol"','')+'>'+TRANS(aTotMesO[l],"@E 999,999,999,999.99")+'</td>   '
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+TRANS(aTotMesR[l],"@E 999,999,999,999.99")+'</td>   '
    //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2<>0,'class="corCol"','')+'> '+IIF(aTotMesR[l]>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(aTotMesRA[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" >'+TRANS(ROUND(aTotMesO[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(aTotMesR[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'"> '+IIF(aTotMesR[l]>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'"> '+IIF(aTotMesR[l]>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
	_cHtml+='       </tr>	                                                                '

	nTotGRA+=aTotMesRA[l]
	nTotGR+=aTotMesR[l]
	nTotGO+=aTotMesO[l]
	
	if aTotMesRA[l]<>0
    	nQtReaA+=1
	endif
	if aTotMesR[l]<>0
    	nQtRea+=1

		//Para fazer a média do FY anterior e Orçado somente dos meses que tem FY atual
		nToFGRA	+=aTotMesRA[l]
		nToFGR	+=aTotMesR[l]
		nToFGO	+=aTotMesO[l]

	endif
	if aTotMesO[l]<>0
    	nQtOrc+=1
	endif
	
Next

_cHtml+='        <td bgcolor="#7A59A5" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" class="bordaci">Total</td>  '

nCtlCor:=0
//Total da parte do Faturamento Real x Orcado
For c:=1 To Len(aEmpGera)
	nCtlCor++

	_nVar:=0
	_cColor:=iif(aTotEmpO[c] > aTotEmpR[c],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotEmpO[c]==0,0,(100*(aTotEmpR[c]/aTotEmpO[c]))-100),0)
    
	//FY Anterior x FY Atual
	_nVarFYA:=0
	_cColorA:=iif(aTotEmpRA[c] > aTotEmpR[c],'#FF0000','#0000FF') 
    _nVarFYA:=Round(iif(aTotEmpRA[c]==0,0,(100*(aTotEmpR[c]/aTotEmpRA[c]))-100),0)

    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(aTotEmpO[c],"@E 999,999,999,999.99")+'</td>  '
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(aTotEmpR[c],"@E 999,999,999,999.99")+'</td>  '
    //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+IIF(aTotEmpR[c]>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpRA[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotEmpO[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpR[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci"> '+IIF(aTotEmpR[c]>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi"> '+IIF(aTotEmpR[c]>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
	
	nTotGO+=0

Next	                      

_cColor:=iif(nTotGO > nTotGR,'#FF0000','#0000FF') 
_nVar:=Round(iif(nTotGO==0,0,(100*(nTotGR/nTotGO))-100),0)

//FY Anterior x FY Atual
_cColorA:=iif(nTotGRA > nTotGR,'#FF0000','#0000FF') 
_nVarFYA:=Round(iif(nTotGRA==0,0,(100*(nTotGR/nTotGRA))-100),0)

//_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'>'+TRANS(nTotGO,"@E 999,999,999,999.99")+'</td>   '
//_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(nTotGR,"@E 999,999,999,999.99")+'</td>   '
//_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'> '+IIF(nTotGR>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>        '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGRA,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci" >'+TRANS(ROUND(nTotGO,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGR,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci"> '+IIF(nTotGR>=0,TRANS(_nVar,cMascPerc),'')+'</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci"> '+IIF(nTotGR>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>        '
_cHtml+='       </tr>'
//_cHtml+='   </table>'

//Linha em branco na tabela
_cHtml+='   <td class="bordaci">&nbsp;</td>'
For c:=1 To Len(aEmpGera)+1
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
Next 
//Fim Linha em branco na tabela

_cHtml+='   <BR>'

//------>>>>>Montagem da Média de Faturamento
//_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
_cHtml+='<tr>'           
//_cHtml+='<td bgcolor="#7A59A5" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" class="bordaci" ><p>Media de Faturamento</p></td>  '
_cHtml+='<td bgcolor="#7A59A5" class="bordaci" ><p>Media de Faturamento</p></td>  '

For c:=1 To Len(aEmpGera)

/*  Esta parte faz a média de acordo com a faturado no ano  
	_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpRA[c]/aQtReaA[c],0),cMasc)+'</td>  '
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotEmpO[c]/aQtOrc[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpR[c]/aQtRea[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi">&nbsp;</td>  '
*/
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotReaA[c]/aQtRea[c],0),cMasc)+'</td>  '
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotOrc[c]/aQtRea[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotRea[c]/aQtRea[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi">&nbsp;</td>  '
		
Next
/*  Esta parte faz a média de acordo com a faturado no ano
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGRA/nQtReaA,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nTotGO/nQtOrc,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGR/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci">&nbsp;</td>    '
*/

_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nToFGRA/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nToFGO/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nToFGR/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci">&nbsp;</td>    '

_cHtml+='</tr>'
_cHtml+='</table>'

//------>>>>>Fim Montagem da Média de Faturamento


_cHtml+='   <BR> 
_cHtml+='   <BR> 
          

//*********************************************MONTAGEM DA SEGUNDA TABELA COM A SEPARAÇÃO POR FILIAL******************************************************//
_cHtml+='<p style="font-size:14px"><b>Outsourcing</b></p>'
_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
_cHtml+='<tr bgcolor="#7A59A5" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td style="font-weight:bold" width="130px" align="center" class="bordabx">&nbsp;</td>                                     '                                       

	//Montagem do cabeçalho com o nome das empresas
	for i:=1 to len(aEmpGera2)
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '                                                                          
		_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx" colspan="5">'+aEmpNome[i][2]+'</td>         '
		// old _cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                    '
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabxdi">&nbsp;</td>                    '
	
		//Montagem do cabeçalho com a descrição de Orcado Real %
		cHtmlAux2+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAnoA+'</td>'
		cHtmlAux2+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Orcado</td>'
		cHtmlAux2+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAno+'</td>'
		//cHtmlAux2+='<td width="101px" bgcolor=#7A59A5 class="bordabx">%</td>'		
		cHtmlAux2+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>'//%
		cHtmlAux2+='<td width="101px" bgcolor=#7A59A5 class="bordabxdi">FY '+cAnoA+' x FY '+cAno+'</td>'
	next	

	//Montagem do Total Geral - Ultima coluna
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '
		_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx" colspan="5">Total Geral</td>         '
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                    '
	
		//Montagem do cabeçalho com a descrição de Orcado Real %
		cHtmlAux2+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAnoA+'</td>'
		cHtmlAux2+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Orcado</td>'
		cHtmlAux2+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAno+'</td>'
		cHtmlAux2+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>'//%
		cHtmlAux2+='<td width="101px" bgcolor=#7A59A5 class="bordabx">FY '+cAnoA+' x FY '+cAno+'</td>'
    //FIM Montagem do Total Geral - Ultima coluna

_cHtml+='</tr>                                                                                                '
_cHtml+='<tr bgcolor="#7A59A5" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td width="131px" class="bordabx">&nbsp;</td>                                                                              '

// Passa para a montagem do cabeçalho a váriável com o conteudo de Orcado/Real/%
_cHtml+=cHtmlAux2

_cHtml+='</tr>                                                                                                '

   aTotEmpR:=ARRAY(len(aEmpGera2))
   AFILL(aTotEmpR,0)
   aTotMesR:=ARRAY(12)
   AFILL(aTotMesR,0)

   aTotEmpO:=ARRAY(len(aEmpGera2))
   AFILL(aTotEmpO,0)
   aTotMesO:=ARRAY(12)
   AFILL(aTotMesO,0)

   aTotEmpRA:=ARRAY(len(aEmpGera2))
   AFILL(aTotEmpRA,0)
   aTotMesRA:=ARRAY(12)
   AFILL(aTotMesRA,0)

nTotGO:=nTotGR:=nTotGRA:=0 

nToFGO:=nToFGR:=nToFGRA:=0

//Montagem do corpo da estrutura do mês | Orcado | Real | % - informações de valores
For l:=1 to 12
	_cHtml+='           <tr>                                                                                                   '
	_cHtml+='        	    <td bgcolor="#7A59A5" align="left" style="color:#FFFFFF; line-height:24px">'+RetMes(l)+'</td>      '
	nCtlCor:=0
	
	For c:=1 To Len(aEmpGera2)
		nCtlCor++


		//++Calcula o Real FY Anterior
		nPosData:=nPosEmp:=0
		nVlRealA:=0
		
		nPosEmp:=aScan(aReal2A,{|x| Alltrim(x[4]) == aEmpGera2[c][3] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aReal2A,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0 .AND. alltrim(aReal2A[nPosData][4])==alltrim(aEmpGera2[c][3])
	        	nVlRealA:=aReal2A[nPosData][3]
	        	aQtReaA2[c]+=1
	        endif
	    
	    endif

	    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(nVlRealA,0),cMasc)+'</td>  '		

        //++Calcula o orcado
		nPosData:=nPosEmp:=0
		nValOrc:=0
		
		nPosEmp:=aScan(aOrcado2,{|x| Alltrim(x[4]) == aEmpGera2[c][3] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aOrcado2,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0
	        	nValOrc:=aOrcado2[nPosData][3]	
	        	aQtOrc2[c]+=1
	        endif
	    
	    endif
	    
	    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+TRANS(nValOrc,"@E 999,999,999,999.99")+'</td>  '
	    _cHtml+='           <td align="right" > '+TRANS(ROUND(nValOrc,0),cMasc)+'</td>  '

		//++Calcula o Real
		nPosData:=nPosEmp:=0
		nValReal:=0
		
		nPosEmp:=aScan(aReal2,{|x| Alltrim(x[4]) == aEmpGera2[c][3] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aReal2,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0 .AND. alltrim(aReal2[nPosData][4])==alltrim(aEmpGera2[c][3])
	        	nValReal:=aReal2[nPosData][3]	
	        	aQtRea2[c]+=1
				
				//Para fazer a média do FY anterior e Orçado somente dos meses que tem FY atual
	        	aTotReaA2[c]+=nVlRealA
	        	aTotRea2[c]	+=nValReal
	        	aTotOrc2[c]	+=nValOrc
	        endif
	    
	    endif

	    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="corCol"','')+'> '+TRANS(nValReal,"@E 999,999,999,999.99")+'</td>  '		
	    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(nValReal,0),cMasc)+'</td>  '		

	    //++Calcula a porcentagem	    
        _nVar:=0
	    _cColor:=iif(nValOrc > nValReal,'#FF0000','#0000FF') 
	    _nVar:=Round(iif(nValOrc==0,0,(100*(nValReal/nValOrc))-100),0)
        //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+IIF(nValReal>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
		_cHtml+='           <td align="right" style="color:'+ _cColor +'" > '+IIF(nValReal>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '

	    //++Calcula a porcentagem FY Anterior x FY Atual
        _nVarFYA:=0
	    _cColorA:=iif(nVlRealA > nValReal,'#FF0000','#0000FF')
	    _nVarFYA:=Round(iif(nVlRealA==0,0,(100*(nValReal/nVlRealA))-100),0)
		_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordadi"> '+IIF(nValReal>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
        
        aTotMesRA[l]+=nVlRealA
		aTotEmpRA[c]+=nVlRealA
        aTotMesR[l]+=nValReal
		aTotEmpR[c]+=nValReal
        aTotMesO[l]+=nValOrc
		aTotEmpO[c]+=nValOrc

	Next
	
	//Montagem dos Totais Gerais - Ultima coluna
	_nVar:=0
	_cColor:=iif(aTotMesO[l] > aTotMesR[l],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotMesO[l]==0,0,(100*(aTotMesR[l]/aTotMesO[l]))-100),0)

	//FY anterior x FY Atual
	_nVarFYA:=0
	_cColorA:=iif(aTotMesRA[l] > aTotMesR[l],'#FF0000','#0000FF') 
    _nVarFYA:=Round(iif(aTotMesRA[l]==0,0,(100*(aTotMesR[l]/aTotMesRA[l]))-100),0)

    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="corCol"','')+'>'+TRANS(aTotMesO[l],"@E 999,999,999,999.99")+'</td>   '
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+TRANS(aTotMesR[l],"@E 999,999,999,999.99")+'</td>   '
    //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2<>0,'class="corCol"','')+'> '+IIF(aTotMesR[l]>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(aTotMesRA[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" >'+TRANS(ROUND(aTotMesO[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(aTotMesR[l],0),cMasc)+'</td>   '
	_cHtml+='           <td align="right" style="color:'+ _cColor +'"> '+IIF(aTotMesR[l]>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
	_cHtml+='           <td align="right" style="color:'+ _cColorA +'"> '+IIF(aTotMesR[l]>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
	_cHtml+='       </tr>	                                                                '

	nTotGRA+=aTotMesRA[l]
	nTotGR+=aTotMesR[l]
	nTotGO+=aTotMesO[l]
	
	if aTotMesRA[l]<>0
    	nQtReaA2+=1
	endif
	if aTotMesR[l]<>0
    	nQtRea2	+=1

    	//Para fazer a média do FY anterior e Orçado somente dos meses que tem FY atual
    	nToFGO	+=aTotMesO[l]
    	nToFGR	+=aTotMesR[l]
    	nToFGRA	+=aTotMesRA[l]
	endif
	if aTotMesO[l]<>0
    	nQtOrc2+=1
	endif
Next

_cHtml+='        <td bgcolor="#7A59A5" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" class="bordaci">Total</td>  '                                               

nCtlCor:=0
//Total da parte do Faturamento Real x Orcado
For c:=1 To Len(aEmpGera2)
	nCtlCor++

	_nVar:=0
	_cColor:=iif(aTotEmpO[c] > aTotEmpR[c],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotEmpO[c]==0,0,(100*(aTotEmpR[c]/aTotEmpO[c]))-100),0)

	//FY Anterior x FY Atual
	_nVarFYA:=0
	_cColorA:=iif(aTotEmpRA[c] > aTotEmpR[c],'#FF0000','#0000FF') 
    _nVarFYA:=Round(iif(aTotEmpRA[c]==0,0,(100*(aTotEmpR[c]/aTotEmpRA[c]))-100),0)

    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(aTotEmpO[c],"@E 999,999,999,999.99")+'</td>  '
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(aTotEmpR[c],"@E 999,999,999,999.99")+'</td>  '		
    //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+IIF(aTotEmpR[c]>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpRA[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotEmpO[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpR[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci"> '+IIF(aTotEmpR[c]>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi"> '+IIF(aTotEmpR[c]>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
	nTotGO+=0

Next	                      

_cColor:=iif(nTotGO > nTotGR,'#FF0000','#0000FF') 
_nVar:=Round(iif(nTotGO==0,0,(100*(nTotGR/nTotGO))-100),0)

//FY Anterior x FY Atual
_cColorA:=iif(nTotGRA > nTotGR,'#FF0000','#0000FF') 
_nVarFYA:=Round(iif(nTotGRA==0,0,(100*(nTotGR/nTotGRA))-100),0)

//_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'>'+TRANS(nTotGO,"@E 999,999,999,999.99")+'</td>   '
//_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(nTotGR,"@E 999,999,999,999.99")+'</td>   '
//_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'> '+IIF(nTotGR>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>        '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGRA,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nTotGO,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGR,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci"> '+IIF(nTotGR>=0,TRANS(_nVar,cMascPerc),'')+'</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci"> '+IIF(nTotGR>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>        '
_cHtml+='       </tr>'
//_cHtml+='   </table>'

//Linha em branco na tabela
_cHtml+='   <td class="bordaci">&nbsp;</td>'
For c:=1 To Len(aEmpGera2)+1
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
Next 
//Fim Linha em branco na tabela

 
_cHtml+='   <BR> 

//------>>>>>Montagem da Média de Faturamento
//_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
_cHtml+='<tr>'           
//_cHtml+='<td bgcolor="#7A59A5" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" class="bordaci">Media de Faturamento</td>  '
_cHtml+='<td bgcolor="#7A59A5" class="bordaci"><p>Media de Faturamento</p></td>  '
For c:=1 To Len(aEmpGera2)
/*
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpRA[c]/aQtReaA2[c],0),cMasc)+'</td>  '
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotEmpO[c]/aQtOrc2[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpR[c]/aQtRea2[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi">&nbsp;</td>  '
*/	
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotReaA2[c]/aQtRea2[c],0),cMasc)+'</td>  '
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotOrc2[c]/aQtRea2[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotRea2[c]/aQtRea2[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi">&nbsp;</td>  '
    
Next
/*
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGRA/nQtReaA2,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nTotGO/nQtOrc2,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGR/nQtRea2,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci">&nbsp;</td>    '
*/

_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nToFGRA/nQtRea2,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nToFGO/nQtRea2,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nToFGR/nQtRea2,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci">&nbsp;</td>    '

_cHtml+='</tr>'
_cHtml+='</table>'

//------>>>>>Fim Montagem da Média de Faturamento

_cHtml+='   <BR> 
_cHtml+='   <BR> 

//*********************************************FIM MONTAGEM DA SEGUNDA TABELA COM A SEPARAÇÃO POR FILIAL******************************************************//


//INVOICE / FATURAMENTO PENDENTE


/*
// posicao cobranca
for t:=1 to 1 // 2 juridico nao sai
	_cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-family:Arial; font-size:12px; font-weight:normal; color:#000000">                         '
	_cHtml+='   <tr>                                                                                                            '
	_cHtml+='   <td align="center" valign="top">                                                                                '
	_cHtml+='   	<table width="100%" cellpadding="0" cellspacing="0" border="0">                                            '
	_cHtml+='   		<tr>                                                                                                  '
	_cHtml+='           	<td align="center" valign="middle" bgcolor="#0a4c9d" style="color:#FFFFFF; line-height:50px; font-weight:bold; font-size:16px>Desempenho GTCORP '+alltrim(str(Year(dDatabase)))+' </td>'
	_cHtml+='           </tr>                                                                                                   '
	_cHtml+='   	</table>                                                                                                       '
	_cHtml+='   <table width="94%" cellpadding="0" cellspacing="0" border="0">                                                     '
	_cHtml+='   <tr>                                                                                                               '
	_cHtml+='   <td>                                                                                                               '
	_cHtml+='       <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:14px">                         '
	_cHtml+='           <tr>                                                                                      '
	_cHtml+='           	<td align="left"><b>Posicao Cobranca'+IIF(t==1," "," - JURIDICO")+'</b></td>                                         '
	_cHtml+='           </tr>                                                                                     '
	_cHtml+='   	</table>                                                                                      '
	_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
	_cHtml+='<tr bgcolor="#365F91" align="center" style="color:#FFFFFF; line-height:24px">                '
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" >Empresas </td>                    '                                       
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 10 dias </td>   '                                                                        
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 30 dias </td>   '                                                                    
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 60 dias </td>   '                                                                   
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> < 90 dias </td>   '                                                                    
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91> > 90 dias </td>   '                       
	_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#365F91>Total Geral</td>   '                                             
	_nT3:=_nT4:=_nT5:=_nT6:=_nT7:=_nT8:=0
	For i:=1 to len(IIF(t==1,aCob,aJur))	
		_cHtml+='   <tr>                                                                                                   '
		_cHtml+='      <td bgcolor="#365F91" align="left" style="color:#FFFFFF; line-height:24px"><b>'+aCob[i][1]+'-'+aCob[i][2]+'</b></td>      '
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][3],aJur[i][3]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][4],aJur[i][4]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][5],aJur[i][5]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][6],aJur[i][6]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][7],aJur[i][7]),"@R 99,999,999")+'</td>                               '			
	    _cHtml+='   <td align="center"> '+TRANS(IIF(t==1,aCob[i][8],aJur[i][8]),"@R 99,999,999")+'</td>                               '			
		_cHtml+=    ' </tr>                                                                                            '
	    _nT3+=IIF(t==1,aCob[i][3],aJur[i][3])
	    _nT4+=IIF(t==1,aCob[i][4],aJur[i][4])
	    _nT5+=IIF(t==1,aCob[i][5],aJur[i][5])
	    _nT6+=IIF(t==1,aCob[i][6],aJur[i][6])
	    _nT7+=IIF(t==1,aCob[i][7],aJur[i][7])
	    _nT8+=IIF(t==1,aCob[i][8],aJur[i][8])
	Next
	_cHtml+=    ' <tr>                                                                                            '
	_cHtml+='        <td bgcolor="#365F91" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Right" >Total</td>                   '                                               
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT3,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT4,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT5,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT6,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT7,"@R 99,999,999")+'</td>    '	
	_cHtml+='        <td bgcolor="#365F91" style="color:#FFFFFF; line-height:24px" align="Center"> '+TRANS(_nT8,"@R 99,999,999")+'</td>    '	
	_cHtml+=    ' </tr>                                                                                            '
    _cHtml+=' </table> 
    _cHtml+=' <BR> 
    _cHtml+=' <BR> 
Next	

// fim posicao cobranca
*/
_cHtml+=' </body>                                                               '
_cHtml+=' </html>                                                               '
	
Return(_cHtml)   

/*
Funcao      : MontaEm2()
Parametros  : aEmpGera,cTitEmp
Retorno     : _cHtml
Objetivos   : Monta a estrutura do e-mail (Auditores)
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	16:41
*/

*-----------------------------------------*
Static Function MontaEm2(aEmpGera,cTitEmp)
*-----------------------------------------*
Local _cSubject	:= ""
Local _cTo		:= ""
Local _cHtml		:= ""        
LOCAL _ccopia  	:= ""
Local _cENVIA  	:= ""
Local _cArqD   	:= ""                                                      	
Local _cNomeCli :=''
Local _cSubject := '[GTCORP] - Desempenho '+alltrim(Str(Year(ddatabase)))+' '+cTitEmp+' em ' + DTOC(date())

Local cHtmlAux1:=""
Local cHtmlAux2:=""

Local aReal:=QueryGR2(aEmpGera)
Local aRealAnt:=QueryGR2Ant(aEmpGera)

Local aOrcado:=QueryGO2(aEmpGera)

Local cAnoA:=RIGHT(alltrim(cvaltochar(val(MV_PAR02)-1)),2)
Local cAno:=RIGHT(alltrim(MV_PAR02),2)

Local cMasc:="@E 999,999,999,999" //"@E 999,999,999,999.99"
Local cMascPerc:="@E 9999%" //"@E 9999.99"

Local aQtReaA	:=ARRAY(len(aEmpGera))
Local aQtRea	:=ARRAY(len(aEmpGera))
Local aQtOrc	:=ARRAY(len(aEmpGera))

Local nQtReaA	:=0
Local nQtRea	:=0
Local nQtOrc	:=0

Local aTotReaA	:=ARRAY(len(aEmpGera))
Local aTotRea	:=ARRAY(len(aEmpGera))
Local aTotOrc	:=ARRAY(len(aEmpGera))

AFILL(aQtReaA,0)
AFILL(aQtRea,0)
AFILL(aQtOrc,0)

AFILL(aTotReaA,0)
AFILL(aTotRea,0)
AFILL(aTotOrc,0)

_cHtml+='   <html xmlns="http://www.w3.org/1999/xhtml">                                                           '
_cHtml+='   <head>                                                                                                           '
_cHtml+='   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />                                            '
_cHtml+='   <title>Desempenho GTCORP '+alltrim(Str(Year(ddatabase)))+' '+cTitEmp+'</title>                                                                                '
_cHtml+=' 	<style type="text/css">'
/*_cHtml+=' 	.bordadi{ '
_cHtml+=' 		border-color: #CCCCCC #000000 #CCCCCC #CCCCCC; '
_cHtml+=' 		border-style: solid;'
_cHtml+='  		border-top-width: 0,5px;'
_cHtml+='  		border-right-width: 1px;'
_cHtml+='  		border-bottom-width: 0,5px;'
_cHtml+='  		border-left-width: 0,5px; '
_cHtml+=' 	}'*/
_cHtml+=' 	.bordabx{ '
_cHtml+='		border-top-style:none;
_cHtml+='		border-right-style:none;
_cHtml+='		border-bottom-style:solid;
_cHtml+='		border-left-style:none;
_cHtml+='  		border-bottom-width: 1,0px;'
_cHtml+=' 		border-bottom-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordaci{ '
_cHtml+='		border-top-style:solid;
_cHtml+='		border-right-style:none;
_cHtml+='		border-bottom-style:none;
_cHtml+='		border-left-style:none;
_cHtml+='  		border-top-width: 1,0px;'
_cHtml+=' 		border-top-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordacidi{ '
_cHtml+='		border-top-style:solid;
_cHtml+='		border-right-style:solid;
_cHtml+='		border-bottom-style:none;
_cHtml+='		border-left-style:none;
_cHtml+='  		border-top-width: 1,0px;'
_cHtml+=' 		border-top-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordacicor{ '
_cHtml+='		border-top-style:solid;
_cHtml+='		border-right-style:none;
_cHtml+='		border-bottom-style:none;
_cHtml+='		border-left-style:none;
_cHtml+='  		background-color: #AA92C7;'
_cHtml+='  		border-top-width: 1,0px;'
_cHtml+=' 		border-top-color:#000000;'
_cHtml+='	}'
_cHtml+=' 	.bordadi{ '
_cHtml+='		border-top-style:none;
_cHtml+='		border-right-style:solid;
_cHtml+='		border-bottom-style:none;
_cHtml+='		border-left-style:none;
_cHtml+='  		border-bottom-width: 1,0px;'
_cHtml+=' 		border-bottom-color:#000000;'
_cHtml+=' 		border-collapse:collapse;'
_cHtml+='	}'
_cHtml+=' 	.bordabxdi{ '
_cHtml+='		border-top-style:none;
_cHtml+='		border-right-style:solid;
_cHtml+='		border-bottom-style:solid;
_cHtml+='		border-left-style:none;
_cHtml+='  		border-bottom-width: 1,0px;'
_cHtml+=' 		border-bottom-color:#000000;'
_cHtml+=' 		border-collapse:collapse;'
_cHtml+='	}'
_cHtml+=' 	.corCol {'			//#CCF	
_cHtml+=' 		background-color: #AA92C7;'
_cHtml+=' 	}'

_cHtml+=' p'
_cHtml+=' {'
_cHtml+=' text-align:center;'
_cHtml+=' font-size:9px;'
_cHtml+=' width:40px;'
_cHtml+=' color:#FFFFFF;'
_cHtml+=' }'

_cHtml+=' 	</style>'
_cHtml+='   </head>                                                                                                         '
_cHtml+='                                                                                                                   '
_cHtml+='   <body marginheight="0" marginwidth="0" style="margin:0"><br />                                                  '
_cHtml+='                                                                                                                   '
_cHtml+='   <table width="'+cvaltochar(len(aEmpGera)*(550))+'" cellpadding="0" cellspacing="0" border="0" style="font-family:Arial; font-size:12px; font-weight:normal; color:#000000">                         '
_cHtml+='   <tr>                                                                                                            '
_cHtml+='   <td align="center" valign="top">                                                                                '
_cHtml+='   	<table width="100%" cellpadding="0" cellspacing="0" border="0">                                            '
_cHtml+='   		<tr>                                                                                                  '
_cHtml+='           	<td align="center" valign="middle" bgcolor="#0a4c9d" style="color:#FFFFFF; line-height:50px; font-weight:bold; font-size:16px>Desempenho GTCORP '+alltrim(str(Year(dDatabase)))+' </td>'
_cHtml+='           </tr>                                                                                                   '
_cHtml+='   	</table>                                                                                                       '


_cHtml+='   <table width="94%" cellpadding="0" cellspacing="0" border="0">                                                     '

_cHtml+='   <tr>                                                                                                               '
_cHtml+='   <td>                                                                                                               '
_cHtml+='       <table width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:12px">                         '
_cHtml+='   		<tr>                                                                                                       '
_cHtml+='           	<td width="60%"></td>                                                                                  '
_cHtml+='               <td width="20%" align="right" colspan="3">emitido em:  '+dtoc(date())+'</td>                                      '
_cHtml+='               <td width="20%" align="right" colspan="3">Ano calendario contabil:  '+MV_PAR02+'</td>                         ' // MSM - 26/10/2012 - Incluído para apresentar o ano do calendário contábil gerado, chamado: 007456
_cHtml+='           </tr>                                                                                                      '
_cHtml+='           <tr>                                                                                      '
_cHtml+='           	<td align="left" style="font-size:14px" colspan="3"><b>Faturamento Real x Orcado</b></td>                                '
_cHtml+='               <td align="right" colspan="3" >Fonte: GTCORP ERP Microsiga</td>                                    '
_cHtml+='           </tr>                                                                                     '
_cHtml+='   	</table>                                                                                      '


_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
					//#365F91                       
_cHtml+='<tr bgcolor="#7A59A5" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td style="font-weight:bold" width="130px" align="center" class="bordabx">&nbsp;</td>                                     '                                       

	//Montagem do cabeçalho com o nome das empresas
	for i:=1 to len(aEmpGera)
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '
		_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx" colspan="5">'+aEmpGera[i][2]+'</td>         '
		
		//old _cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                    '
		
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabxdi">&nbsp;</td>                    '
	
		//Montagem do cabeçalho com a descrição de Orcado Real %
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAnoA+'</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Orcado</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAno+'</td>'
		//cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">%</td>'		
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>' //%
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabxdi">FY '+cAnoA+' x FY '+cAno+'</td>' //%
	next	

	//Montagem do Total Geral - Ultima coluna
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                   '
		_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx" colspan="5">Total Geral</td>         '
		//_cHtml+='<td style="font-weight:bold" width="100px" align="center" bgcolor=#7A59A5 class="bordabx">&nbsp;</td>                    '
	
		//Montagem do cabeçalho com a descrição de Orcado Real %
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAnoA+'</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Orcado</td>'
		cHtmlAux1+='<td width="100px" bgcolor=#7A59A5 class="bordabx">Real FY '+cAno+'</td>'
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">Orcado x FY '+cAno+'</td>' //% 
		cHtmlAux1+='<td width="101px" bgcolor=#7A59A5 class="bordabx">FY '+cAnoA+' x FY '+cAno+'</td>' //% 
    //FIM Montagem do Total Geral - Ultima coluna

_cHtml+='</tr>                                                                                                '
_cHtml+='<tr bgcolor="#7A59A5" align="center" style="color:#FFFFFF; line-height:24px">                        '
_cHtml+='<td width="131px" class="bordabx">&nbsp;</td>                                                                              '

// Passa para a montagem do cabeçalho a váriável com o conteudo de Orcado/Real/%
_cHtml+=cHtmlAux1

_cHtml+='</tr>                                                                                                '

   aTotO:=ARRAY(len(aEmpGera))
   AFILL(aTotO,0)
   
   aTotEmpR:=ARRAY(len(aEmpGera))
   AFILL(aTotEmpR,0)
   aTotMesR:=ARRAY(12)
   AFILL(aTotMesR,0)
   
   aTotEmpO:=ARRAY(len(aEmpGera))
   AFILL(aTotEmpO,0)
   aTotMesO:=ARRAY(12)
   AFILL(aTotMesO,0)

   aTotEmpRA:=ARRAY(len(aEmpGera))
   AFILL(aTotEmpRA,0)
   aTotMesRA:=ARRAY(12)
   AFILL(aTotMesRA,0)

nTotGO:=nTotGR:=nTotGRA:=0 

nToFGO:=nToFGR:=nToFGRA:=0

//Montagem do corpo da estrutura do mês | Orcado | Real | % - informações de valores
For l:=1 to 12
	_cHtml+='           <tr>                                                                                                   '
	_cHtml+='        	    <td bgcolor="#7A59A5" align="left" style="color:#FFFFFF; line-height:24px">'+RetMes(l)+'</td>      '
	nCtlCor:=0
	For c:=1 To Len(aEmpGera)
	nCtlCor++

		//++Calcula a parte do Real Ano Anterior
		nPosData:=nPosEmp:=0
		nVlRealA:=0
		
		nPosEmp:=aScan(aRealAnt,{|x| Alltrim(x[1]) == aEmpGera[c][1] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aRealAnt,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0 .AND. alltrim(aRealAnt[nPosData][1])==alltrim(aEmpGera[c][1])
	        	nVlRealA:=aRealAnt[nPosData][3]
	        	aQtReaA[c]+=1
	        endif
	    
	    endif
	    
	    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(nVlRealA,0),cMasc)+'</td>  '


		//++Calcula a parte do Orçado
		nPosData:=nPosEmp:=0
		nValOrc:=0
		
		nPosEmp:=aScan(aOrcado,{|x| Alltrim(x[1]) == aEmpGera[c][1] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0			
			nPosData:=aScan(aOrcado,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0
	        	nValOrc:=aOrcado[nPosData][3]
	        	aQtOrc[c]+=1
	        endif
	    
	    endif	    

	    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+TRANS(nValOrc,"@E 999,999,999,999.99")+'</td>  '
	    _cHtml+='           <td align="right" > '+TRANS(ROUND(nValOrc,0),cMasc)+'</td>  '
        
		//++Calcula a parte do Real
		nPosData:=nPosEmp:=0
		nValReal:=0
		
		nPosEmp:=aScan(aReal,{|x| Alltrim(x[1]) == aEmpGera[c][1] }) //Retorna a linha pela posição da empresa
		if nPosEmp<>0
			nPosData:=aScan(aReal,{|x| SUBSTR(x[2],5,2) == STRZERO(Escala8(l),2) },nPosEmp) //Retorna a linha pela posição da data
	        
	        if nPosData <> 0 .AND. alltrim(aReal[nPosData][1])==alltrim(aEmpGera[c][1])
	        	nValReal:=aReal[nPosData][3]
	        	aQtRea[c]+=1

				//Para fazer a média do FY anterior e Orçado somente dos meses que tem FY atual
	        	aTotReaA[c]	+=nVlRealA
	        	aTotRea[c]	+=nValReal
	        	aTotOrc[c]	+=nValOrc	        	
	        endif
	    
	    endif
	    
	    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="corCol"','')+'> '+TRANS(nValReal,"@E 999,999,999,999.99")+'</td>  '		
	    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(nValReal,0),cMasc)+'</td>  '
	    
	    //++Calcula a porcentagem	    
        _nVar:=0
	    _cColor:=iif(nValOrc > nValReal,'#FF0000','#0000FF') 
	    _nVar:=Round(iif(nValOrc==0,0,(100*(nValReal/nValOrc))-100),0)
        //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+IIF(nValReal>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
        _cHtml+='           <td align="right" style="color:'+ _cColor +'" > '+IIF(nValReal>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '


		//++Calcula a porcentagem FY anterior e FY Atual
  		_nVarFYA:=0
	    _cColorA:=iif(nVlRealA > nValReal,'#FF0000','#0000FF')
	    _nVarFYA:=Round(iif(nVlRealA==0,0,(100*(nValReal/nVlRealA))-100),0)
        _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordadi"> '+IIF(nValReal>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '


        aTotMesRA[l]+=nVlRealA
        aTotEmpRA[c]+=nVlRealA
        aTotMesR[l]+=nValReal
		aTotEmpR[c]+=nValReal
        aTotMesO[l]+=nValOrc
		aTotEmpO[c]+=nValOrc

	Next
	
	//Montagem dos Totais Gerais - Ultima coluna

	_nVar:=0
	_cColor:=iif(aTotMesO[l] > aTotMesR[l],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotMesO[l]==0,0,(100*(aTotMesR[l]/aTotMesO[l]))-100),0)
											//aOrc[l][lt]
	//FY Anterior x FY Atual
	_nVarFYA:=0                                                                
    _cColorA:=iif(aTotMesRA[l] > aTotMesR[l],'#FF0000','#0000FF') 
	_nVarFYA:=Round(iif(aTotMesRA[l]==0,0,(100*(aTotMesR[l]/aTotMesRA[l]))-100),0)

    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="corCol"','')+'>'+TRANS(aTotMesO[l],"@E 999,999,999,999.99")+'</td>   '
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="corCol"','')+'> '+TRANS(aTotMesR[l],"@E 999,999,999,999.99")+'</td>   '
    //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2<>0,'class="corCol"','')+'> '+IIF(aTotMesR[l]>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(aTotMesRA[l],0),cMasc)+'</td>   '
	_cHtml+='           <td align="right" >'+TRANS(ROUND(aTotMesO[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" class="corCol"> '+TRANS(ROUND(aTotMesR[l],0),cMasc)+'</td>   '
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" > '+IIF(aTotMesR[l]>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" > '+IIF(aTotMesR[l]>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
	_cHtml+='       </tr>	                                                                '
	
	nTotGRA+=aTotMesRA[l]
	nTotGR+=aTotMesR[l]
	nTotGO+=aTotMesO[l]
	
	if aTotMesRA[l]<>0
		nQtReaA+=1
	endif
	if aTotMesR[l]<>0
		nQtRea+=1

		//Para fazer a média do FY anterior e Orçado somente dos meses que tem FY atual
    	nToFGO	+=aTotMesO[l]
    	nToFGR	+=aTotMesR[l]
    	nToFGRA	+=aTotMesRA[l]		
	endif
	if aTotMesO[l]<>0
		nQtOrc+=1
	endif
Next

_cHtml+='        <td bgcolor="#7A59A5" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" class="bordaci">Total</td>  '

nCtlCor:=0
//Total da parte do Faturamento Real x Orcado
For c:=1 To Len(aEmpGera)
	nCtlCor++

	_nVar:=0
	_cColor:=iif(aTotEmpO[c] > aTotEmpR[c],'#FF0000','#0000FF') 
    _nVar:=Round(iif(aTotEmpO[c]==0,0,(100*(aTotEmpR[c]/aTotEmpO[c]))-100),0)

	//FY Anterior x FY Atual
	_nVarFYA:=0                                                                
    _cColorA:=iif(aTotEmpRA[c] > aTotEmpR[c],'#FF0000','#0000FF') 
	_nVarFYA:=Round(iif(aTotEmpRA[c]==0,0,(100*(aTotEmpR[c]/aTotEmpRA[c]))-100),0)

    //_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(aTotEmpO[c],"@E 999,999,999,999.99")+'</td>  '
    //_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(aTotEmpR[c],"@E 999,999,999,999.99")+'</td>  '		
    //_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+IIF(aTotEmpR[c]>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpRA[c],0),cMasc)+'</td>  '		
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotEmpO[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpR[c],0),cMasc)+'</td>  '		
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci"> '+IIF(aTotEmpR[c]>=0,TRANS(_nVar,cMascPerc),'')+'</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi"> '+IIF(aTotEmpRA[c]>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>  '
	
	nTotGO+=0

Next

_cColor:=iif(nTotGO > nTotGR,'#FF0000','#0000FF') 
_nVar:=Round(iif(nTotGO==0,0,(100*(nTotGR/nTotGO))-100),0)

_cColorA:=iif(nTotGRA > nTotGR,'#FF0000','#0000FF') 
_nVarFYA:=Round(iif(nTotGRA==0,0,(100*(nTotGR/nTotGRA))-100),0)

//_cHtml+='           <td align="right" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'>'+TRANS(nTotGO,"@E 999,999,999,999.99")+'</td>   '
//_cHtml+='           <td align="right" '+iif(nCtlCor%2==0,'class="bordacicor"','class="bordaci"')+'> '+TRANS(nTotGR,"@E 999,999,999,999.99")+'</td>   '
//_cHtml+='           <td align="right" style="color:'+ _cColor +'" '+iif(nCtlCor%2<>0,'class="bordacicor"','class="bordaci"')+'> '+IIF(nTotGR>=0,TRANS(_nVar,"@E 9999.99"),'')+'</td>        '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGRA,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nTotGO,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGR,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci"> '+IIF(nTotGR>=0,TRANS(_nVar,cMascPerc),'')+'</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci"> '+IIF(nTotGR>=0,TRANS(_nVarFYA,cMascPerc),'')+'</td>        '
_cHtml+='       </tr>'
//_cHtml+='   </table>'

_cHtml+='   <BR>' 

//Linha em branco na tabela
_cHtml+='   <td class="bordaci">&nbsp;</td>'
For c:=1 To Len(aEmpGera)+1
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
	_cHtml+='   <td class="bordaci">&nbsp;</td>'
Next 
//Fim Linha em branco na tabela


//------>>>>>Montagem da Média de Faturamento
//_cHtml+='<table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">    '
_cHtml+='<tr>'           
//_cHtml+='<td bgcolor="#7A59A5" align="left" style="font-weight:bold; color:#FFFFFF; line-height:24px" align="Center" class="bordaci">Media de Faturamento</td>  '
_cHtml+='<td bgcolor="#7A59A5" class="bordaci"><p>Media de Faturamento</p></td>  '
For c:=1 To Len(aEmpGera)
/*
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpRA[c]/aQtReaA[c],0),cMasc)+'</td>  '
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotEmpO[c]/aQtOrc[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotEmpR[c]/aQtRea[c],0),cMasc)+'</td>  '		
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi">&nbsp;</td>  '
*/
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotReaA[c]/aQtRea[c],0),cMasc)+'</td>  '
	_cHtml+='           <td align="right" class="bordaci"> '+TRANS(ROUND(aTotOrc[c]/aQtRea[c],0),cMasc)+'</td>  '
    _cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(aTotRea[c]/aQtRea[c],0),cMasc)+'</td>  '		
    _cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>  '
    _cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordacidi">&nbsp;</td>  '
	
Next
/*
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGRA/nQtReaA,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nTotGO/nQtOrc,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nTotGR/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci">&nbsp;</td>    '
*/

_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nToFGRA/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordaci">'+TRANS(ROUND(nToFGO/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" class="bordacicor"> '+TRANS(ROUND(nToFGR/nQtRea,0),cMasc)+'</td>   '
_cHtml+='           <td align="right" style="color:'+ _cColor +'" class="bordaci">&nbsp;</td>        '
_cHtml+='           <td align="right" style="color:'+ _cColorA +'" class="bordaci">&nbsp;</td>    '

_cHtml+='</tr>'
_cHtml+='</table>'

//------>>>>>Fim Montagem da Média de Faturamento

_cHtml+='</tr>'
_cHtml+='</table>'

_cHtml+='   <BR>' 
_cHtml+='   <BR>' 

_cHtml+=' </body>'
_cHtml+=' </html>'
	
	
//Memowrite("C:/teste/sqlteste.txt",_cHtml)	
Return(_cHtml)

/*
Funcao      : RetMes()
Parametros  : nMes
Retorno     : cRet
Objetivos   : Função para retornar a abreviação do mês
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	16:41
*/

*----------------------*
Static Function RetMes(nMes)
*----------------------*
Local cRet:=""

if nMes==1
	cRet:="OUT"
elseif nMes==2
	cRet:="NOV"
elseif nMes==3
	cRet:="DEZ"
elseif nMes==4
	cRet:="JAN"
elseif nMes==5
	cRet:="FEV"
elseif nMes==6
	cRet:="MAR"
elseif nMes==7
	cRet:="ABR"
elseif nMes==8
	cRet:="MAI"
elseif nMes==9
	cRet:="JUN"
elseif nMes==10
	cRet:="JUL"
elseif nMes==11
	cRet:="AGO"
elseif nMes==12
	cRet:="SET"
endif

Return(cRet)

/*
Funcao      : Escala8()
Parametros  : nMes
Retorno     : nRet
Objetivos   : Função para retornar a número do mês 8 9 10 11 12 1 2 3 4 5 6 7
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	16:54
*/

*----------------------*
Static Function Escala8(nMes)
*----------------------*
Local nRet:=0

if nMes==1
	nRet:=10
elseif nMes==2
	nRet:=11
elseif nMes==3
	nRet:=12
elseif nMes==4
	nRet:=1
elseif nMes==5
	nRet:=2
elseif nMes==6
	nRet:=3
elseif nMes==7
	nRet:=4
elseif nMes==8
	nRet:=5
elseif nMes==9
	nRet:=6
elseif nMes==10
	nRet:=7
elseif nMes==11
	nRet:=8
elseif nMes==12
	nRet:=9
endif     

Return(nRet)

/*
Funcao      : Query()
Parametros  : aEmpGera,lFilial
Retorno     : aReal
Objetivos   : Cria a query e retorna um array com as informações |EMPRESA|EMISSAO|TOTAL|
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	17:00
*/
*-------------------------------------*
Static Function Query(aEmpGera,lFilial)
*-------------------------------------*
Local cQry:=""
Local nMes:=01 //MONTH(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro 
Local nAno:=val(MV_PAR02) //YEAR(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAnoIni:=""
Local nAnoFim:=""
Local aReal:={}

DEFAULT lFilial:=.F.

	if nMes<=09
		nAnoIni:=cvaltochar(nAno-1)
		nAnoFim:=cvaltochar(nAno)
	else
		nAnoIni:=cvaltochar(nAno)
		nAnoFim:=cvaltochar(nAno+1)
	endif

	for nSeq:=1 to len(aEmpGera)
	//ROUND(SUM(F2_VALBRUT/1000),1,2)
		//Verifica se deve considerar filtro por filial
		if lFilial
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,'"+alltrim(aEmpGera[nSeq][3])+"' AS FILIAL,ROUND(SUM(F2_VALBRUT),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
		else
			//Regra específica para a CH(Tecnologh) pegar do campo BASEISS
			if aEmpGera[nSeq][1]=='CH'
				cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(F2_BASEISS),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
			else
				cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(F2_VALBRUT),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
			endif
		endif
		
		cQry+= " WHERE "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+".D_E_L_E_T_='' "+CRLF
		
			//Verifica se deve considerar filtro por filial
			if lFilial
				cQry+= " AND F2_FILIAL='"+aEmpGera[nSeq][3]+"'"+CRLF 
			endif

		cQry+= " AND SUBSTRING(F2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND F2_SERIE<>'ND'"+CRLF
			
		cQry+= " GROUP BY SUBSTRING(F2_EMISSAO,1,6)"+CRLF
		
		if nSeq<>len(aEmpGera)
			cQry+= " UNION ALL"
		endif
	next

	//Verifica se deve considerar filtro por filial
	if lFilial
		cQry+= " ORDER BY EMPRESA,FILIAL,EMISSAO"
	else
		cQry+= " ORDER BY EMPRESA,EMISSAO"
    endif
    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				//Verifica se deve considerar filtro por filial
				if lFilial
					AADD(aReal,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL,QRYTEMP->FILIAL})
				else
					AADD(aReal,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL})
				endif
				
				QRYTEMP->(DbSkip())
			Enddo
		
		endif
Return(aReal)

/*
Funcao      : QueryAnt()
Parametros  : aEmpGera,lFilial
Retorno     : aReal
Objetivos   : Cria a query e retorna um array com as informações |EMPRESA|EMISSAO|TOTAL|, para o ano anterior ao calendário contábil
Autor       : Matheus Massarotto
Data/Hora   : 18/01/2013	14:38
*/

*-----------------------------------------*
Static Function QueryAnt(aEmpGera,lFilial)
*-----------------------------------------*
Local cQry:=""
Local nMes:=01 //MONTH(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro 
Local nAno:=val(MV_PAR02) //YEAR(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAnoIni:=""
Local nAnoFim:=""
Local aReal:={}

DEFAULT lFilial:=.F.

	if nMes<=09
		nAnoIni:=cvaltochar(nAno-1-1)
		nAnoFim:=cvaltochar(nAno-1)
	else
		nAnoIni:=cvaltochar(nAno-1)
		nAnoFim:=cvaltochar(nAno+1-1)
	endif

	for nSeq:=1 to len(aEmpGera)
	//ROUND(SUM(F2_VALBRUT/1000),1,2)
		//Verifica se deve considerar filtro por filial
		if lFilial
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,'"+alltrim(aEmpGera[nSeq][3])+"' AS FILIAL,ROUND(SUM(F2_VALBRUT),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
		else
			//Regra específica para a CH(Tecnologh) pegar do campo BASEISS
			if aEmpGera[nSeq][1]=='CH'
				cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(F2_BASEISS),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
			else
				cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(F2_VALBRUT),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
			endif
		endif
		
		cQry+= " WHERE "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+".D_E_L_E_T_='' "+CRLF
		
			//Verifica se deve considerar filtro por filial
			if lFilial
				cQry+= " AND F2_FILIAL='"+aEmpGera[nSeq][3]+"'"+CRLF 
			endif

		cQry+= " AND SUBSTRING(F2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND F2_SERIE<>'ND'"+CRLF
			
		cQry+= " GROUP BY SUBSTRING(F2_EMISSAO,1,6)"+CRLF
		
		if nSeq<>len(aEmpGera)
			cQry+= " UNION ALL"
		endif
	next

	//Verifica se deve considerar filtro por filial
	if lFilial
		cQry+= " ORDER BY EMPRESA,FILIAL,EMISSAO"
	else
		cQry+= " ORDER BY EMPRESA,EMISSAO"
    endif
    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				//Verifica se deve considerar filtro por filial
				if lFilial
					AADD(aReal,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL,QRYTEMP->FILIAL})
				else
					AADD(aReal,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL})
				endif
				
				QRYTEMP->(DbSkip())
			Enddo
		
		endif
Return(aReal)

/*
Funcao      : QueryORC()
Parametros  : aEmpGera,lFilial
Retorno     : aOrcado
Objetivos   : Função que faz o select na tabela Z89 retornando um array com o valor orçado
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	17:00
*/

Static Function QueryORC(aEmpGera,lFilial)
Local cQry:=""
Local nMes:=01 //MONTH(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAno:=val(MV_PAR02) //YEAR(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAnoIni:=""
Local nAnoFim:=""
Local aOrcado:={}

DEFAULT lFilial:=.F.

	if nMes<=09
		nAnoIni:=cvaltochar(nAno-1)
		nAnoFim:=cvaltochar(nAno)
	else
		nAnoIni:=cvaltochar(nAno)
		nAnoFim:=cvaltochar(nAno+1)
	endif

	for nSeq:=1 to len(aEmpGera)

		//Verifica se deve considerar filtro por filial
		if lFilial
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,'"+alltrim(aEmpGera[nSeq][3])+"' AS FILIAL,ROUND(SUM(Z89_VALOR),2) AS TOTAL, Z89_ANO+Z89_MES AS EMISSAO FROM Z89"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
		else
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(Z89_VALOR),2) AS TOTAL, Z89_ANO+Z89_MES AS EMISSAO FROM Z89"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+CRLF
		endif
		
		cQry+= " WHERE "+alltrim( IIF(ISDIGIT(aEmpGera[nSeq][1]),"_"+aEmpGera[nSeq][1],aEmpGera[nSeq][1] ) )+".D_E_L_E_T_='' "+CRLF
		
			//Verifica se deve considerar filtro por filial
			if lFilial
				cQry+= " AND Z89_FILIAL='"+aEmpGera[nSeq][3]+"'"+CRLF 
			endif

		cQry+= " AND Z89_ANO+Z89_MES BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' "+CRLF

		cQry+= " GROUP BY Z89_ANO+Z89_MES
		if nSeq<>len(aEmpGera)
			cQry+= " UNION ALL"
		endif
	next

	//Verifica se deve considerar filtro por filial
	if lFilial
		cQry+= " ORDER BY EMPRESA,FILIAL,EMISSAO"
	else
		cQry+= " ORDER BY EMPRESA,EMISSAO"
    endif
    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				//Verifica se deve considerar filtro por filial
				if lFilial
					AADD(aOrcado,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL,QRYTEMP->FILIAL})
				else
					AADD(aOrcado,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL})
				endif
				
				QRYTEMP->(DbSkip())
			Enddo
		
		endif

Return(aOrcado)

/*
Funcao      : QueryGO2()
Parametros  : aEmpGera
Retorno     : aOrcado
Objetivos   : Função que faz o select na tabela Z89 retornando um array com o valor orçado Para Auditores
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	17:17
*/

Static Function QueryGO2(aEmpGera)
Local cQry:=""
Local nMes:=01 //MONTH(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAno:=val(MV_PAR02) //YEAR(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAnoIni:=""
Local nAnoFim:=""
Local aOrcado:={}

	if nMes<=09
		nAnoIni:=cvaltochar(nAno-1)
		nAnoFim:=cvaltochar(nAno)
	else
		nAnoIni:=cvaltochar(nAno)
		nAnoFim:=cvaltochar(nAno+1)
	endif

	for nSeq:=1 to len(aEmpGera)

		if alltrim(aEmpGera[nSeq][1])=="ZF1"
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(Z89_VALOR,2) AS TOTAL, Z89_ANO+Z89_MES AS EMISSAO FROM Z89ZF0 "+alltrim(aEmpGera[nSeq][1])+CRLF		
			cQry+= " WHERE "+alltrim(aEmpGera[nSeq][1])+".D_E_L_E_T_='' "+CRLF		
			cQry+= " AND Z89_ANO+Z89_MES BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND Z89_GRUPO IN ('11')"+CRLF
		elseif alltrim(aEmpGera[nSeq][1])=="ZF2"
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(Z89_VALOR,2) AS TOTAL, Z89_ANO+Z89_MES AS EMISSAO FROM Z89ZF0 "+alltrim(aEmpGera[nSeq][1])+CRLF		
			cQry+= " WHERE "+alltrim(aEmpGera[nSeq][1])+".D_E_L_E_T_='' "+CRLF		
			cQry+= " AND Z89_ANO+Z89_MES BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND Z89_GRUPO IN ('12')"+CRLF		
		else
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(Z89_VALOR,2) AS TOTAL, Z89_ANO+Z89_MES AS EMISSAO FROM Z89"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim(aEmpGera[nSeq][1])+CRLF		
			cQry+= " WHERE "+alltrim(aEmpGera[nSeq][1])+".D_E_L_E_T_='' "+CRLF		
			cQry+= " AND Z89_ANO+Z89_MES BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' "+CRLF
		endif

		if nSeq<>len(aEmpGera)
			cQry+= " UNION ALL"
		endif
	next

		cQry+= " ORDER BY EMPRESA,EMISSAO"

    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				AADD(aOrcado,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL})
				
				QRYTEMP->(DbSkip())
			Enddo
		
		endif

Return(aOrcado)

/*
Funcao      : QueryGR2()
Parametros  : aEmpGera
Retorno     : aReal
Objetivos   : Cria a query e retorna um array com as informações |EMPRESA|EMISSAO|TOTAL| - Para o Grupo de Empresas setadas como Auditores
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	17:17
*/

*-----------------------------*
Static Function QueryGR2(aEmpGera)
*-----------------------------*
Local cQry:=""
Local nMes:=01 //MONTH(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAno:=val(MV_PAR02) //YEAR(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAnoIni:=""
Local nAnoFim:=""
Local aReal:={}

	if nMes<=09
		nAnoIni:=cvaltochar(nAno-1)
		nAnoFim:=cvaltochar(nAno)
	else
		nAnoIni:=cvaltochar(nAno)
		nAnoFim:=cvaltochar(nAno+1)
	endif

	for nSeq:=1 to len(aEmpGera)
		if alltrim(aEmpGera[nSeq][1])=="ZF1"
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,SUM(D2_TOTAL) AS TOTAL, SUBSTRING(D2_EMISSAO,1,6) AS EMISSAO FROM SD2ZF0 ZF"+CRLF
			cQry+= " JOIN SB1ZF0 B1 ON B1_COD=D2_COD"+CRLF
			cQry+= " JOIN SBMZF0 BM ON BM_GRUPO=B1_GRUPO"+CRLF                                                                                                                     //MSM- Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
			cQry+= " WHERE BM.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND SUBSTRING(D2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND D2_SERIE<>'ND' AND D2_CLIENTE NOT IN ('001721','001015')"+CRLF
			cQry+= " AND B1.B1_GRUPO<>'' AND BM.BM_TIPGRU IN ('11') "+CRLF
			cQry+= " GROUP BY SUBSTRING(D2_EMISSAO,1,6)"+CRLF
		elseif alltrim(aEmpGera[nSeq][1])=="ZF2"
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,SUM(D2_TOTAL) AS TOTAL, SUBSTRING(D2_EMISSAO,1,6) AS EMISSAO FROM SD2ZF0 ZF"+CRLF
			cQry+= " JOIN SB1ZF0 B1 ON B1_COD=D2_COD"+CRLF
			cQry+= " JOIN SBMZF0 BM ON BM_GRUPO=B1_GRUPO"+CRLF                                                                                                                     //MSM- Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
			cQry+= " WHERE BM.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND SUBSTRING(D2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND D2_SERIE<>'ND' AND D2_CLIENTE NOT IN ('001721','001015')"+CRLF
			cQry+= " AND B1.B1_GRUPO<>'' AND BM.BM_TIPGRU IN ('12') "+CRLF
			cQry+= " GROUP BY SUBSTRING(D2_EMISSAO,1,6)"+CRLF
		else
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(F2_VALBRUT),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim(aEmpGera[nSeq][1])+CRLF
			
			cQry+= " WHERE "+alltrim(aEmpGera[nSeq][1])+".D_E_L_E_T_='' "+CRLF
			
			cQry+= " AND SUBSTRING(F2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND F2_SERIE<>'ND'"+CRLF
				
			cQry+= " GROUP BY SUBSTRING(F2_EMISSAO,1,6)"+CRLF
		endif
		
		if nSeq<>len(aEmpGera)
			cQry+= " UNION ALL"
		endif
	next

		cQry+= " ORDER BY EMPRESA,EMISSAO"
    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				AADD(aReal,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL})
		
				QRYTEMP->(DbSkip())
			Enddo
		
		endif
Return(aReal)

********************************
/*
Funcao      : QueryGR2Ant()
Parametros  : aEmpGera
Retorno     : aReal
Objetivos   : Cria a query e retorna um array com as informações |EMPRESA|EMISSAO|TOTAL| - Para o Grupo de Empresas setadas como Auditores - Ano anterior
Autor       : Matheus Massarotto
Data/Hora   : 17/01/201132	14:42
*/

*-----------------------------*
Static Function QueryGR2Ant(aEmpGera)
*-----------------------------*
Local cQry:=""
Local nMes:=01 //MONTH(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAno:=val(MV_PAR02) //YEAR(dDataBase) // MSM - 26/10/2012 - Alterado para considerar o ano informado no parametro
Local nAnoIni:=""
Local nAnoFim:=""
Local aReal:={}

	if nMes<=09
		nAnoIni:=cvaltochar(nAno-1-1)
		nAnoFim:=cvaltochar(nAno-1)
	else
		nAnoIni:=cvaltochar(nAno-1)
		nAnoFim:=cvaltochar(nAno+1-1)
	endif

	for nSeq:=1 to len(aEmpGera)
		if alltrim(aEmpGera[nSeq][1])=="ZF1"
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,SUM(D2_TOTAL) AS TOTAL, SUBSTRING(D2_EMISSAO,1,6) AS EMISSAO FROM SD2ZF0 ZF"+CRLF
			cQry+= " JOIN SB1ZF0 B1 ON B1_COD=D2_COD"+CRLF
			cQry+= " JOIN SBMZF0 BM ON BM_GRUPO=B1_GRUPO"+CRLF                                                                                                                     //MSM- Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
			cQry+= " WHERE BM.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND SUBSTRING(D2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND D2_SERIE<>'ND' AND D2_CLIENTE NOT IN ('001721','001015')"+CRLF
			cQry+= " AND B1.B1_GRUPO<>'' AND BM.BM_TIPGRU IN ('11') "+CRLF
			cQry+= " GROUP BY SUBSTRING(D2_EMISSAO,1,6)"+CRLF
		elseif alltrim(aEmpGera[nSeq][1])=="ZF2"
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,SUM(D2_TOTAL) AS TOTAL, SUBSTRING(D2_EMISSAO,1,6) AS EMISSAO FROM SD2ZF0 ZF"+CRLF
			cQry+= " JOIN SB1ZF0 B1 ON B1_COD=D2_COD"+CRLF
			cQry+= " JOIN SBMZF0 BM ON BM_GRUPO=B1_GRUPO"+CRLF                                                                                                                     //MSM- Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
			cQry+= " WHERE BM.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND SUBSTRING(D2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND D2_SERIE<>'ND' AND D2_CLIENTE NOT IN ('001721','001015')"+CRLF
			cQry+= " AND B1.B1_GRUPO<>'' AND BM.BM_TIPGRU IN ('12') "+CRLF
			cQry+= " GROUP BY SUBSTRING(D2_EMISSAO,1,6)"+CRLF
		else
			cQry+= " SELECT '"+alltrim(aEmpGera[nSeq][1])+"' AS EMPRESA,ROUND(SUM(F2_VALBRUT),2) AS TOTAL, SUBSTRING(F2_EMISSAO,1,6) AS EMISSAO FROM SF2"+alltrim(aEmpGera[nSeq][1])+"0 "+alltrim(aEmpGera[nSeq][1])+CRLF
			
			cQry+= " WHERE "+alltrim(aEmpGera[nSeq][1])+".D_E_L_E_T_='' "+CRLF
			
			cQry+= " AND SUBSTRING(F2_EMISSAO,1,6) BETWEEN '"+nAnoIni+"10' AND '"+nAnoFim+"09' AND F2_SERIE<>'ND'"+CRLF
				
			cQry+= " GROUP BY SUBSTRING(F2_EMISSAO,1,6)"+CRLF
		endif
		
		if nSeq<>len(aEmpGera)
			cQry+= " UNION ALL"
		endif
	next

		cQry+= " ORDER BY EMPRESA,EMISSAO"
    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				AADD(aReal,{QRYTEMP->EMPRESA,QRYTEMP->EMISSAO,QRYTEMP->TOTAL})
		
				QRYTEMP->(DbSkip())
			Enddo
		
		endif
Return(aReal)
********************************

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para gerar o excel
Autor       : Matheus Massarotto
Data/Hora   : 15/05/2012	17:17
*/

Static Function GExecl(cConteu)
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

	cArq := alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cConteu ) // Gravação do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
/***********************GERANDO EXCEL************************************/          
    sleep(5000)
	FERASE (cDest+cArq)

Return

/*
Funcao      : VdGTCO43()
Parametros  : cConteudo
Retorno     : lRet
Objetivos   : Função para validar o ano inserido no pergunte, uso local. 
Autor       : Matheus Massarotto
Data/Hora   : 26/10/2012	10:50
*/

*-------------------------------*
User Function VdGTCO43(cConteudo)
*-------------------------------*
Local lRet		:= .T.
Local cAnoAux	:= ""

if len(alltrim(cConteudo))<4
	Alert("O campo Calend Contábil deve conter o Ano no formato(aaaa).")
	lRet:=.F.
else
	cAnoAux:=alltrim(cConteudo)
	for i:=1 to len(cAnoAux)
		if !ISDIGIT(substr(cAnoAux,i,1))
			Alert("O campo Calend Contábil deve conter somente números.")
			Return(.F.)
		endif
	next
endif

Return(lRet)