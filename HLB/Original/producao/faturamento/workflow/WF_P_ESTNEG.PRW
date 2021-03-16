#include "Protheus.ch"    
#INCLUDE "AP5MAIL.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  WF_P_ESTNEG  ∫Autor  Adriane Sayuri Kamiya ∫ Data ≥ 08/27/10 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o de envio de e-mail quando o estoque do produto ficar∫±±
±±∫          ≥ negativo , chamado apos gravaÁ„o da nota P.E.: M460FIM.prw ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Obs       ≥ Esta sendo chamado pelo ponto de entrada:M460FIM           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

Funcao      : WF_P_ESTNEG
Parametros  : aEstNeg
Retorno     : Nenhum
Objetivos   : FunÁ„o de envio de e-mail quando o estoque do produto ficar negativo , chamado apos gravaÁ„o da nota P.E.: M460FIM.prw
Autor     	: Adriane Sayuri Kamiya	 	
Data     	: 02/20/2011
Obs         : Esta sendo chamado pelo ponto de entrada:M460FIM 
TDN         : 
Revis„o     : Tiago Luiz MendonÁa 
Data/Hora   : 15/03/2012
MÛdulo      : Faturamento.
Cliente     : Todos.
*/                               

*----------------------------------*
 User Function WF_P_ESTNEG(aEstNeg)  
*----------------------------------*
Local lRet        := .T.    
Local cAlterou    := ''                             
Local cCompName   := ComputerName()  
Local dData       := date()
Local cHora       := Time()
Local cAmbiente   := GetEnvServer ()  
Local aEstNeg     := aEstNeg
Local cPedido     := aEstNeg[1][1]
Local cNota       := aEstNeg[1][2]
Local cSerie      := aEstNeg[1][3]
Local cCliente    := aEstNeg[1][4]
Local cLoja       := aEstNeg[1][5]                                          

Private cServer   := GetMV("MV_RELSERV")
Private cAccount  := GetMV("MV_RELACNT")

Private cFrom			:= AllTrim(GetMv("MV_RELFROM"))
Private cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
Private lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de AutenticaÁ„o

Private cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usu·rio para AutenticaÁ„o no Servidor de Email
Private cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para AutenticaÁ„o no Servidor de Email

//Private cPara     := padr('marcia.matuda@hlb.com.br;michele.moreira@hlb.com.br;sergio.augusto@hlb.com.br;juliane.dalaqua@hlb.com.br;ricardo.oliveira@hlb.com.br;camila.teles@hlb.com.br;daniela.cruz@hlb.com.br;karla.minhaco@hlb.com.br;daiana.pereira@hlb.com.br',200)
//Private cCc       := padr('flau.oliveira@hlb.com.br;valdecir.galvao@hlb.com.br;wagner.feitosa@hlb.com.br;marizelia.sousa@hlb.com.br;ana.camilis@hlb.com.br;pamella.ribeiro@hlb.com.br;reginaldo.moura@hlb.com.br;eunice.gaieta@hlb.com.br',200)
//JVR - 28/03/2012 - AtualizaÁ„o dos destinatarios, chamado 004259.
//JSS - 29/09/2015 - AtualizaÁ„o dos destinatarios chamado 029752 
//Private cPara     := padr('ricardo.oliveira@hlb.com.br;daniela.cruz@hlb.com.br;karla.minhaco@hlb.com.br',200)
Private cTo		  := GetMV("MV_P_00053",.T.,.F.) // E-mail que receberam a informacao de estoque negativo
Private cCc       := padr('',200)
Private cSubject  := padr('',200)
Private cMsg      := ""
Private cErro     := ""           

  
   cSubject :="Estoque/Custos: Estoque Negativo - Empresa : " + Alltrim(SM0->M0_NOME)+" / Ambiente: "+ Upper(cAmbiente) 
    
   cMsg :=  " <body style='background-color: #9370db'>"        
   
   cMsg += ' <table height="361" width="844" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0">'
       
   cMsg += ' <tr>  '
   cMsg += ' <td colspan="7">'
   If Val(cHora) < 13
      cMsg += ' Bom dia!<br><br> '                                                     
   ElseIf Val(cHora) > 12 .and. Val(cHora) < 19
      cMsg += ' Boa tarde!<br><br> '
   Else
      cMsg += ' Boa noite!<br><br> '   
   EndIf
   cMsg += ' </td>'
   
   cMsg += ' <tr>'
   cMsg += " <td colspan='7'>A  Nota  <em>"+cNota+"</em>  /  SÈrie  <em>"+cSerie+"</em>  gerou  estoque  negativo  para  os  itens  abaixo:  "
   cMsg += " </td> "
   cMsg += ' </tr>'
       
   cMsg += ' <tr>'
   cMsg += " <td colspan='7'> "+SPACE(20)
   cMsg += " </td> "
   cMsg += ' </tr>'
                                
   cMsg += ' <tr>'
   cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Pedido </b></font></td> '
   cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Item </b></font></td> '
   cMsg += ' <td width="200" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  CÛdigo </b></font></td>'
   cMsg += ' <td width="120" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b> Quantidade </b></font></td> '
   cMsg += ' <td width="120" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b> Saldo no Estoque </b></font></td> '
   cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b> ArmazÈm </b></font></td> '
   cMsg += ' <td width="50" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>' 
   cMsg += ' </tr>'
      
   For i := 1 to len(aEstNeg)
      cMsg += '<tr>' 
      cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+aEstNeg[i][1]+'</td>'
      cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+aEstNeg[i][9]+'</td>'
      cMsg += '<td width="200" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+aEstNeg[i][6]+'</td>'
      cMsg += '<td width="120" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+Str(aEstNeg[i][7])+'</td>'
      cMsg += '<td width="120" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+Str(aEstNeg[i][8])+'</td>'
      cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+(aEstNeg[i][10])+'</td>'
      cMsg += '<td width="50" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </td>'
      cMsg += '</tr>'   
   Next
   
   cMsg += '<tr>'
   cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </font></td>' 
   cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </font></td>' 
   cMsg += '<td width="200" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td> '
   cMsg += '<td width="120" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>' 
   cMsg += '<td width="120" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>' 
   cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>' 
   cMsg += '<td width="50" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">   </font></td>' 
   cMsg += '</tr>'
  
   cMsg += ' <tr>'
   cMsg += " <td colspan='7'>Esta  nota  foi  gerada  pelo  usu·rio  <em>"+cUserName+"</em> na m·quina <em> "+cCompName+"</em> no dia <em>"+dtoc(dData)+"</em> ‡s <em>"+cHora+"</em> hrs.  "
   cMsg += " </td> "
   cMsg += ' </tr>'   
  
   cMsg += '<tr>'
   cMsg += '<td width="80" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </font></td>' 
   cMsg += '<td width="80" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </font></td>' 
   cMsg += '<td width="200" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td> '
   cMsg += '<td width="120" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>' 
   cMsg += '<td width="120" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>' 
   cMsg += '<td width="120" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>'    
   cMsg += '<td width="50" height="120" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">   </font></td>' 
   cMsg += '</tr>'
  
   cMsg += '<tr> '
   cMsg += '<td colspan="7">   '
   cMsg += '<em><strong>Este ÅEum e-mail autom·tico. Por favor, n„o responda.</Strong></em> '              
   cMsg += '</td>'
   cMsg += '</tr>  '

   cMsg     += '</Table><BR>' +CRLF                                                   

                        
   If Empty(cServer) .And. Empty(cAccount) .And. Empty(cPassword)
      MsgAlert("N„o foram definidos os par‚metros do server do Protheus para envio de e-mail",cTitulo)
      Return
   Endif    


   IF ValidaEmail()
      Eval({||EnviaEmail()})
   EndIf
 
  
Return .T.          
   
STATIC FUNCTION ValidaEmail()
Local lRet := .T.

	If Empty(cFrom)
	   MsgInfo("Campo 'De' preenchimento obrigatÛrio",cTitulo)
	   lRet:=.F.
	Endif
	If Empty(cTo) .And. lRet
	   MsgInfo("Campo 'Para' preenchimento obrigatÛrio",cTitulo)
	   lRet:=.F.
   	Endif
	If Empty(cSubject) .And. lRet
	   MsgInfo("Campo 'Assunto' preenchimento obrigatÛrio",cTitulo)
	   lRet:=.F.
	Endif
	
	If lRet
	   cFrom    := AllTrim(cFrom)
	   cTo    := AllTrim(cTo)
	   cCC      := AllTrim(cCC)
	   cSubject := AllTrim(cSubject)
	Endif

RETURN(lRet)

STATIC FUNCTION EnviaEmail()
Local lOK 			:= .T.
Local lResulSend	:= .T.
Local cError 		:= ""  
Local cAttachment	:= ""
Local cToOculto 	:= ""
	
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
	
If !lOK
	ConOut("Falha na Conex„o com Servidor de E-Mail")
	Return .F.
Else
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			ConOut("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			Return .F.
		EndIf
	EndIf
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK
	Else
		SEND MAIL FROM cFrom TO cTo BCC cToOculto;
		SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK
	EndIf
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+Alltrim(cTo))
		DISCONNECT SMTP SERVER
		Return .F.
	EndIf
EndIf

DISCONNECT SMTP SERVER

Return .T.