#include "Protheus.ch"    
#INCLUDE "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  MA900TOK     ºAutor  Adriane Sayuri Kamiya º Data ³ 08/27/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na alteração da rotina Acertos Fiscais    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

Funcao      : MA900TOK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. na alteração da rotina Acertos Fiscais
Autor     	: Adriane Sayuri Kamiya	
Data     	: 08/27/2010
Obs         : 
TDN         : Ponto de entrada 'MT410ACE' criado para verificar o acesso dos usuários nas rotinas: Excluir, Visualizar, Resúuo, Copiar e Alterar.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Livros Fiscais.    
Cliente     : Todos.
*/
          
*------------------------*
 User Function MA900TOK()  
*------------------------* 

Local lRet			:= .T.    
Local cAlterou		:= ''                             
Local lAlterouTES	:= .F.
Local nOrderSX3		:= SX3->(IndexOrd())
Local cNomeCampo	:= ''
Local cCpoSF3		:= ''
Local cCpoMem		:= ''
Local cCompName		:= ComputerName()  
Local dData			:= date()
Local cHora			:= Time()
Local cAmbiente		:= GetEnvServer ()
Local cTitulo		:= "HLB BRASIL"

Private cServer:= GetMV("MV_RELSERV")
Private cEmail := GetMV("MV_RELACNT")
Private cPass  := GetMV("MV_RELPSW")
Private lAuth  := GetMv("MV_RELAUTH")  

Private cDe      := padr('workflow@hlb.com.br',200)
Private cPara    := padr('diogo.braga@hlb.com.br;renata.melloni@hlb.com.br;edimilso.junior@hlb.com.br;carla.oliveira@hlb.com.br;priscila.santos@hlb.com.br;monalisa.martins@hlb.com.br;mariana.rodrigues@hlb.com.br',200) //CAS - 21/02/2017 chamado 039087. //JSS - Alterado para solucionaro o chamdo 018159.   //MSM - 04/12/14 - Chamado: 021581 //AOA - 08/06/2016 chamado: 034106
Private cCc      := padr('',200)
Private cAssunto := padr('',200)
Private cMsg     := ""
Private cErro    := ""

   cMsg :=  " <body style='background-color: #9370db'>"        

   cMsg += ' <table height="361" width="844" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0">'
       
   cMsg += ' <tr>  '
   cMsg += ' <td colspan="4">'
   If Val(cHora) < 13
      cMsg += ' Bom dia!<br><br> '
   ElseIf Val(cHora) > 12 .and. Val(cHora) < 19
      cMsg += ' Boa tarde!<br><br> '
   Else
      cMsg += ' Boa noite!<br><br> '   
   EndIf
   cMsg += ' </td>'
 
   cMsg += ' <tr>'
   cMsg += " <td colspan='4'>A Nota <em>"+M->F3_NFISCAL+"</em> / Série ' <em>"+M->F3_SERIE+"</em>' foi alterada pelo usuário <em>"+cUserName+"</em> na máquina <em> "+cCompName+"</em> no dia <em>"+dtoc(dData)+"</em> às <em>"+cHora+"</em> hrs.  "
   cMsg += " </td> "
   cMsg += ' </tr>'
       
   cMsg += ' <tr>'                                                    
   cMsg += ' <td width="80" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td> '
   cMsg += ' <td width="80" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td>'
   cMsg += ' <td width="80" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td> '
   cMsg += ' <td width="10" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>' 
   cMsg += ' </tr>'
      
   SX3->(DbSetOrder(2))
   SF3->(DbSetOrder(5))          
   //F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT                                                                                                     
   If SF3->(DbSeek(xFilial("SF3")+M->F3_SERIE+M->F3_NFISCAL+M->F3_CLIEFOR+M->F3_LOJA+M->F3_IDENTFT  ))
      cMsg += ' <tr>'
      cMsg += " <td colspan='4'>Cliente/Fornecedor: <em>"+M->F3_CLIEFOR+"</em> / Loja ' <em>"+M->F3_LOJA+"</em>' Cfop: <em>"+M->F3_CFO+"</em>  - Ident.: <em> "+M->F3_IDENTFT+"</em> .  "
      cMsg += " </td> "
      cMsg += ' </tr>'  
       
      cMsg += ' <tr>'                                                    
      cMsg += ' <td width="80" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td> '
      cMsg += ' <td width="80" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td>'
      cMsg += ' <td width="80" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  </b></font></td> '
      cMsg += ' <td width="10" height="20" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>' 
      cMsg += ' </tr>'
       
      cMsg += ' <tr>'                                                    
      cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Campo </b></font></td> '
      cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Conteúdo Anterior </b></font></td>'
      cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b> Alterado Para </b></font></td> '
      cMsg += ' <td width="10" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>' 
      cMsg += ' </tr>'
      FOR i := 1 TO FCount()
         cCampo := FIELDNAME(I)       
         cAssunto :="Livros Fiscais: Acertos Fiscais - Empresa : " + Alltrim(SM0->M0_NOME)+" / Ambiente: "+ Upper(cAmbiente) 
         If SF3->(FieldPos(cCampo)) # 0
            If SF3->&(cCampo) <>  M->&(cCampo)
               lAlterouTES := .T.     
               SX3->(DbSeek(Alltrim(cCampo)))
               cNomeCampo:= SX3->X3_TITULO 
               cMsg += '<tr>'
               cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+cNomeCampo+'</td>'
               If SX3->X3_TIPO == 'N'                                                                                         
                  cCpoSF3 := Alltrim(Str(SF3->&(cCampo)))
                  cCpoMem := Alltrim(Str(M->&(cCampo)))
               ElseIf SX3->X3_TIPO == 'D' 
                  cCpoSF3 := Alltrim(DtoC(SF3->&(cCampo)))
                  cCpoMem := Alltrim(DtoC(M->&(cCampo))) 
               Else
                  If SX3->X3_TAMANHO == 1  
                     nPosIni := AT(SF3->&(cCampo),SX3->X3_CBOX)+2 
                     If AT(';',Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))) = 0
                        nPosFim := len(Alltrim(Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))))
                        cCpoSF3 := Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))
                     Else
                        nPosFim := nPosIni+AT(';',Alltrim(Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))))-1
                        cCpoSF3 := Substr(SX3->X3_CBOX,nPosIni,nPosFim-nPosIni )
                     EndIf
                     nPosIni := AT(M->&(cCampo),SX3->X3_CBOX)+2
                     If AT(';',Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))) = 0
                        nPosFim := len(Alltrim(Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))))   
                        cCpoMem := Substr(SX3->X3_CBOX,nPosIni,len(SX3->X3_CBOX))
                     Else
                        nPosFim := nPosIni+AT(';',Alltrim(Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))))-1
                        cCpoMem := Substr(SX3->X3_CBOX,nPosIni,nPosFim-nPosIni)
                     EndIf
                  Else
                     cCpoSF3 := SF3->&(cCampo)
                     cCpoMem := M->&(cCampo)
                  EndIf
               EndIF
               cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">' + cCpoSF3 + '</td>'
               cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">' + cCpoMem + '</td>'
               cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </td>'
               cMsg += '</tr>'   
            EndIf
         EndIf
      End                                                                                       
   EndIf   
   cMsg += '<tr>'
   cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </font></td>' 
   cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td> '
   cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">  </font></td>' 
   cMsg += '<td width="10" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">   </font></td>' 
   cMsg += '</tr>'
  
   cMsg += '<tr> '
   cMsg += '<td colspan="4">   '
   cMsg += '<em><strong>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe TI da HLB BRASIL. </Strong></em> '              
   cMsg += '</td>'
   cMsg += '</tr>  '

   cMsg     += '</Table><BR>' +CRLF                                                   

                        
   If Empty(cServer) .And. Empty(cEmail) .And. Empty(cPass)
      MsgAlert("Não foram definidos os parâmetros do server do Protheus para envio de e-mail",cTitulo)
      Return
   Endif    

   If lAlterouTES
      IF ValidaEmail()
         Eval({||EnviaEmail()})
      EndIf
   EndIf   
 
SX3->(DbSetOrder(nOrderSX3))   
Return .T.          
   
STATIC FUNCTION ValidaEmail()
Local lRet := .T.

	If Empty(cDe)
	   MsgInfo("Campo 'De' preenchimento obrigatório",cTitulo)
	   lRet:=.F.
	Endif
	If Empty(cPara) .And. lRet
	   MsgInfo("Campo 'Para' preenchimento obrigatório",cTitulo)
	   lRet:=.F.
	Endif
	If Empty(cAssunto) .And. lRet
	   MsgInfo("Campo 'Assunto' preenchimento obrigatório",cTitulo)
	   lRet:=.F.
	Endif
	
	If lRet
	   cDe      := AllTrim(cDe)
	   cPara    := AllTrim(cPara)
	   cCC      := AllTrim(cCC)
	   cAssunto := AllTrim(cAssunto)
	Endif

RETURN(lRet)

STATIC FUNCTION EnviaEmail()
Local lResulConn := .T.
Local lResulSend := .T.
Local cError := ""  
	
	CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn
	
	lAuth    := GetMv("MV_RELAUTH")
	If lAuth
		lOk := MailAuth( cEmail ,GetMV("MV_RELAPSW"))
 		If !lOk 
			lOk := QAGetMail() 
		EndIf
	EndIf
	
	If !lResulConn
	   GET MAIL ERROR cError
	   MsgAlert("Falha na conexão "+cError)
	   Return(.F.)
	Endif
	

    SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg  RESULT lResulSend   
	   
	GET MAIL ERROR cError
	If !lResulSend
		MsgAlert("Falha no Envio do e-mail " + cError)
   	Endif
	
	DISCONNECT SMTP SERVER                         
	

Return .T.