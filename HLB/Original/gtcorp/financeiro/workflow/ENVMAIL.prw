#include "rwmake.ch"
#include "topconn.ch"        
#include 'Ap5Mail.ch'     


/*
Funcao      : ENVMAIL
Parametros  : aTit,cTpCob
Retorno     : 
Objetivos   : Envio de email.
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Generico.
*/   
 
    
*-------------------------------------*
   User Function ENVMAIL(aTit,cTpCob)    
*-------------------------------------*

Local aArea     := GetArea()
Local lOk		:= .F.		// Variavel que verifica se foi conectado OK
Local lSendOk	:= .F.		// Variavel que verifica se foi enviado OK
Local cError	:= ""
Local cAttach1	:= ""
Local cAttach2	:= ""
Local cAttach3	:= ""
Local cEmailTo	:= ""
Local cEmailBcc	:= ""

Private cCodUser  := RetCodUsr()
Private cUser       := Upper(AllTrim(Substr(cUsuario,7,15)))
Private cCRLF
Private cMensagem   := ""
Private cAssunto    := " "
Private cMailConta	:= Nil
Private cMailServer	:= Nil
Private cMailSenha	:= Nil

cCRLF := CHR(13)+CHR(10)  	//Windows

cMailConta	:= If(cMailConta 	== NIL,GETMV("MV_RELACNT"),cMailConta)
cMailServer	:= If(cMailServer 	== NIL,GETMV("MV_RELSERV"),cMailServer) // mail.br.gt.com
cMailSenha	:= If(cMailSenha 	== NIL,GETMV("MV_WFPASSW"),cMailSenha)

If 	Empty(cMailServer)
	Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
	Return(.F.)
EndIf

//Verifica se existe a CONTA
If 	Empty(cMailServer)
	Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
	Return(.F.)
EndIf

// verifica enderecos de email para envio do orcamento

nEnvia 	   := 2
//	cNomeDir   := Alltrim(SuperGetMv("MV_XDIRWOR"))
//	cArquivo   := Alltrim(cNumOrc)+Alltrim(cCliOrc)+".PDF"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Verifica se existe a Senha
If 	Empty(cMailServer)
	Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
	Return(.F.)
EndIf

cAttach1:= "" //ALLTRIM(cNomeDir) + ALLTRIM(cArquivo)
cAttach2:= ""
cAttach3:= ""
cCliente     := aTit[1][6]
cLoja        := aTit[1][7]
cNome        := aTit[1][8]
cCli         := cCliente + " " + cLoja + " - " + cNome 
nReduz       := Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NREDUZ"))
cLogoGT      := "\WORKFLOW\logogt.jpg"
If cTpCob == 1
	cAssunto := "Confirmacao de recebimento de Fatura(s) / ND(s) - GRANT THORNTON"
	cMensagem:=""
	cMensagem:= cMensagem + cCRLF + cCRLF
//	cMensagem:= cMensagem +  '<html>' + cCRLF
//	cMensagem:= cMensagem +  '<head>' + cCRLF
//	cMensagem:= cMensagem + '<title>  T I T U L O (S)   À   V E N C E R    </title>' + cCRLF
 //	cMensagem:= cMensagem +  '</head>' + cCRLF
//	cMensagem:= cMensagem + cLogoGT+ cCRLF
	cMensagem:= cMensagem + '<b><font size="2" face="Arial"> À '+cNome+' ('+cCliente+'/'+cLoja+') </font></b>' + cCRLF + cCRLF
	cMensagem:= cMensagem + "Prezado Cliente, "+ cCRLF
	cMensagem:= cMensagem + "Informamos que enviamos por email a(s) Fatura(s) / ND(s) abaixo relacionada(s):      "
	cMensagem:= cMensagem + '   ' +cCRLF+ cCRLF
	cMensagem:= cMensagem + 'CNPJ______________Documento_Serie______Dt.Emissão___Dt.Vencimento__Valor____________ ' + cCRLF + cCRLF
	For i:= 1 to Len(aTit)
		cMensagem:= cMensagem  + " "+Transform(aTit[i][18], "@R 99.999.999.9999/99") + '__'+ aTit[i][2]+'____'+aTit[i][1]+'_______'+dtoc(aTit[i][11])+ '____'+dtoc(aTit[i][12])+'______  R$ '+Transform(round(aTit[i][14],2), "@E 9,999,999.99")+ '  </font></b>' + cCRLF + cCRLF
	Next
	cMensagem:= cMensagem + "   "+ cCRLF
	cMensagem:= cMensagem + "Caso não tenha recebido, solicitamos entrar em contato conosco pelo telefone "+ cCRLF
	cMensagem:= cMensagem + "ou endereço eletrônico mencionados a seguir:      "+ cCRLF
	cMensagem:= cMensagem + "                                                                                                            "+ cCRLF
	cMensagem:= cMensagem + '<font size="2" face="Arial"> email: gtbr.contasreceber@br.gt.com </font>' + cCRLF + cCRLF
	cMensagem:= cMensagem + '<font size="2" face="Arial"> Fone: 11 3887-4800 </font>' + cCRLF + cCRLF  
	cMensagem:= cMensagem + " Desde já agradecemos. " + cCRLF + cCRLF
	cMensagem:= cMensagem + '<b><font size="2" face="Arial">Departamento Financeiro </font></b>' + cCRLF + cCRLF
	cMensagem:= cMensagem + '<b><font size="2" face="Arial">GRANT THORNTON </font></b>' + cCRLF + cCRLF
	cMensagem:= cMensagem + '</body>' + cCRLF
	cMensagem:= cMensagem + '</html>' + cCRLF
Else
	cAssunto := "Grant Thornton - Cobranca de Fatura(s)/ND(s) em aberto de "+nReduz
	cMensagem:=""
	cMensagem:= cMensagem + cCRLF 
//    cMensagem:= cMensagem + '<img border="0" src="http://www.alka.com.br/site/ekp/financeiro/topoa.jpg" width="610" height="121"></h2>  </font>' + _CRLF +_CRLF  
//	cMensagem:= cMensagem + '<b><font size="2" face="Arial">  GRANT THORNTON' + cCRLF+ cCRLF
	cMensagem:= cMensagem + '<b><font size="2" face="Arial"> À  '+cNome+' ('+cCliente+'/'+cLoja+') </font></b>' + cCRLF + cCRLF 
	cMensagem:= cMensagem + "   " +cCRLF+cCRLF
	cMensagem:= cMensagem + 'Prezado Cliente, '+ cCRLF
	cMensagem:= cMensagem + "Informamos que a(s) Fatura(s) / ND(s) abaixo relacionada(s) encontra(m)-se 'EM ABERTO' em nosso sistema :      "
	cMensagem:= cMensagem + '   ' +cCRLF+ cCRLF
	cMensagem:= cMensagem + 'CNPJ______________Documento_Serie______Dt.Emissão___Dt.Vencimento__Valor____________ ' + cCRLF + cCRLF
	For i:= 1 to Len(aTit)
		cMensagem:= cMensagem  + " "+Transform(aTit[i][18], "@R 99.999.999.9999/99") + '__'+ aTit[i][2]+'____'+aTit[i][1]+'_______'+dtoc(aTit[i][11])+ '____'+dtoc(aTit[i][12])+'______  R$ '+Transform(round(aTit[i][14],2), "@E 9,999,999.99")+ '  </font></b>' + cCRLF + cCRLF
	Next
	cMensagem:= cMensagem + "   "+ cCRLF
	cMensagem:= cMensagem + "Caso já tenha(m) sido quitada(s), solicitamos a gentileza de nos enviarem cópia do(s) comprovante(s) de pagamento  "+ cCRLF
	cMensagem:= cMensagem + "ao endereço eletrônico ou fax mencionados a seguir:      "+ cCRLF
	cMensagem:= cMensagem + "                                                                                                            "+ cCRLF
	cMensagem:= cMensagem + '<font size="2" face="Arial"> e-mail: gtbr.contasreceber@br.gt.com </font>' + cCRLF  //+ cCRLF
	cMensagem:= cMensagem + '<font size="2" face="Arial"> Fax: 11 3887-4800   </font>' + cCRLF + cCRLF  
	cMensagem:= cMensagem + "No aguardo de um breve retorno. " + cCRLF + cCRLF
	cMensagem:= cMensagem + "Atenciosamente, " + cCRLF + cCRLF
	cMensagem:= cMensagem + '<b><font size="2" face="Arial">Departamento de Cobranca </font></b>' + cCRLF + cCRLF
	cMensagem:= cMensagem + '<b><font size="2" face="Arial">GRANT THORNTON </font></b>' + cCRLF + cCRLF
	cMensagem:= cMensagem + '</body>' + cCRLF
	cMensagem:= cMensagem + '</html>' + cCRLF
Endif

cEmailBcc:= aTit[1][10] 
cEmailTo := aTit[1][9] 

// Envia e-mail com os dados necessarios
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	
	CONNECT SMTP SERVER "mail.br.gt.com" ACCOUNT "totvs@br.gt.com" PASSWORD "Protheus@2010" RESULT lOk
//	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	If 	lOk
		SEND MAIL 	FROM  "totvs@br.gt.com"; //cMailConta;
		TO cEmailTo;
		BCC cEmailBcc;
		SUBJECT cAssunto;
		BODY cMensagem;
		RESULT lSendOk
		If !lSendOk
			//Erro no Envio do e-mail
			GET MAIL ERROR cError
//			MsgInfo(cError,OemToAnsi("Erro no envio do Email")) //"Erro no envio de Email"
    	    lRetEmail := .F.
		Else    
		    lRetEmail := .T.
//			MsgInfo("O Email foi enviado com sucesso!!!",OemToAnsi("Email enviado")) //"Envio de Email OK"
		EndIf
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("Erro no envio do Email")) // "Erro no envio de Email"
	EndIf
//	If lRetEmail
//	    MsgInfo("Email(s) enviado(s) com sucesso!!!",OemToAnsi("Email enviado")) //"Envio de Email OK"
//	Endif
EndIf
Return Nil

