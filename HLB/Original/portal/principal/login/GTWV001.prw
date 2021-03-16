#include "apwebex.ch"
#include "totvs.ch"
#Include "tbiconn.ch"
#include 'Ap5Mail.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTWV001   �Autor  �Eduardo C. Romanini � Data �  26/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o da tela de login do portal GT.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GT                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------*
User Function GTWV001()
*---------------------*
Local cHtml    := ""
Local cLogin   := HttpPost->cLogin
Local cPass    := HttpPost->cPassword
Local cEmpresa := HttpPost->cEmpresa

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

WEB EXTENDED INIT cHtml

	HttpSession->cLogin    := cLogin
	HttpSession->cPassword := cPass
	HttpSession->cEmpresa  := cEmpresa

	//Verifica se a sess�o expirou.
	If  ValType(HttpSession->cLogin)<> "C" .or. Empty(HttpSession->cLogin);
	.or. ValType(HttpSession->cEmpresa)<> "C" .or. Empty(HttpSession->cEmpresa)
		cHtml := ExecInPage("GTWP007") //Pagina de sess�o expirada.
	Else
		// Inicializa o idioma do sistema
		If !Empty(ZW0->ZW0_IDIOMA)
			u_GTWF002(ZW0->ZW0_IDIOMA)
		EndIf
	
		HttpSession->cCombo    := ""

		cHtml := ExecInPage("GTWP002")	
	EndIf

WEB EXTENDED END

Return cHtml

/*
Fun��o  : WV001Emp
Objetivo: Carregar o combo de empresas
Autor   : Eduardo C. Romanini
Data    : 16/04/2012
*/
*----------------------*
User Function WV001Emp()
*----------------------*
Local cHtml    := ""
Local cLogin   := HttpGet->cLogin
Local cPass    := HttpGet->cPass
Local cPswBase := ""

Local nI := 0

Local aSelect   := {}
Local aEmpresas := {}

WEB EXTENDED INIT cHtml

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

//Op��o padr�o do combobox
aSelect := {{u_WFTraduzir("--Selecione--")," "}}

//Preenchimento do array aSelect com as op��es a serem exibidas no comboBox
If !Empty(cLogin) .and. !Empty(cPass)
	
	aEmpresas := {}
	
	ZW0->(DbSetOrder(1))
	If (ZW0->(DbSeek(xFilial("ZW0")+cLogin)))

		//Tratamento da senha na base de dados
		cPswBase := Alltrim(ZW0->ZW0_SENHA)
		cPswBase := Substr(cPswBase,2,Len(cPswBase)-2) //Retira os delimitadores
		
		//Verifica se a senha digitada est� correta.
		If cPass == Encript(cPswBase,0)
		    
			//Verifica as empresas utilizadas pelo usu�rio
			ZW2->(DbSetOrder(1))
			If ZW2->(DbSeek(xFilial("ZW2")+cLogin))	
					
                While ZW2->(!EOF()) .and. ZW2->ZW2_FILIAL+AllTrim(ZW2->ZW2_LOGIN) == xFilial("ZW2")+AllTrim(cLogin)

					ZW1->(DbSetOrder(1))
					If ZW1->(DbSeek(xFilial("ZW1")+ZW2->ZW2_CODIGO+ZW2->ZW2_CODFIL))
						
						aAdd(aEmpresas,{ AllTrim(ZW1->ZW1_NFANT) , ZW2->ZW2_CODIGO+ZW2->ZW2_CODFIL })
																	
					EndIf
					ZW2->(DbSkip())				
				EndDo
			EndIf
		EndIf
	EndIf			
EndIf

//Se foram encontradas empresas para o usu�rio, exibe no comboBox.
If Len(aEmpresas) > 0
	aSort(aEmpresas,,,{|x,y| x[1] < y[1]})
	aSelect := aClone(aEmpresas)
EndIf

//Tratamento do array para o formato aceito pelo ajax.
For nI:=1 To Len(aSelect)
	cHtml += aSelect[nI][1] + "|" + aSelect[nI][2] + ";"
Next

WEB EXTENDED END

Return cHtml

/*
Fun��o  : WV001ValLogin
Objetivo: Validar o login e a senha
Autor   : Eduardo C. Romanini
Data    : 31/05/2012
*/
*---------------------------*
User Function WV001ValLogin()
*---------------------------*
Local cRet     := ""
Local cLogin   := ""
Local cPass    := ""  
Local cPswBase := ""

WEB EXTENDED INIT cRet

cLogin := HttpGet->cLogin
cPass  := HttpGet->csenha

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

//Verifica se o login informado esta cadastrado.
ZW0->(DbSetOrder(1))
If !ZW0->(DbSeek(xFilial("ZW0")+AllTrim(cLogin)))
	cRet := u_WFTraduzir("Login n�o cadastrado")
EndIf

//Tratamento da senha na base de dados
cPswBase := Alltrim(ZW0->ZW0_SENHA)
cPswBase := Substr(cPswBase,2,Len(cPswBase)-2) //Retira os delimitadores

//Verifica se a senha esta correta
If Empty(cRet)
	If cPass <> Encript(cPswBase,0)
		cRet := u_WFTraduzir("Senha incorreta")
	EndIf
EndIf

//Verifica se o usu�rio est� bloqueado
If Empty(cRet)
	If AllTrim(ZW0->ZW0_BLOQUE) == "S"
		cRet := u_WFTraduzir("Usu�rio Bloqueado")
	EndIf
EndIf

//Verifica se existe alguma empresa vinculada ao usu�rio
If Empty(cRet)
	ZW2->(DbSetOrder(1))
	If !(ZW2->(DbSeek(xFilial("ZW2")+Alltrim(cLogin))))
		cRet := u_WFTraduzir("Nenhuma empresa vinculada a esse usuario")
	EndIf	
EndIf

//Tratamento de acentua��o para a msg de erro.
If !Empty(cRet)	
	cRet := EncodeUTF8(cRet)
EndIf

WEB EXTENDED END

Return cRet

/*
Fun��o  : WV001AltSenha
Objetivo: Verifica se a senha ser� alterada
Autor   : Eduardo C. Romanini
Data    : 31/05/2012
*/
*---------------------------*
User Function WV001AltSenha()
*---------------------------*
Local cRet   := ""
Local cLogin := ""
Local cPass := ""  

WEB EXTENDED INIT cRet

cLogin := HttpGet->cLogin
cPass  := HttpGet->csenha

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

//Verifica se o login informado esta cadastrado.
ZW0->(DbSetOrder(1))
If ZW0->(DbSeek(xFilial("ZW0")+AllTrim(cLogin)))
	If ZW0->ZW0_ALTSEN == "S"
		cRet := u_WFTraduzir("Altera") 	
	EndIf
EndIf

//Tratamento de acentua��o para a msg de erro.
If !Empty(cRet)	
	cRet := EncodeUTF8(cRet)
EndIf

WEB EXTENDED END

Return cRet

/*
Fun��o  : WV001Login
Objetivo: Verificar se o login existe
Autor   : Eduardo C. Romanini
Data    : 30/05/2012
*/
*------------------------*
User Function WV001Login()
*------------------------*
Local lEnviado := .F.

Local cRet      := ""
Local cLogin    := ""
Local cServer   := ""
Local cAccount  := ""
Local cEnvia    := ""
Local cRecebe   := ""
Local cPassword := ""
Local cMensagem := ""
Local cNewSenha := ""

WEB EXTENDED INIT cRet

cLogin := HttpGet->cLogin

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

cNewSenha := Str(Randomize(1000,9999))

//Verifica se o login informado sta cadastrado.
ZW0->(DbSetOrder(1))
If !ZW0->(DbSeek(xFilial("ZW0")+AllTrim(cLogin)))
	cRet := u_WFTraduzir("O login informado n�o est� cadastrado.")
EndIf

//Verifica se existe e-mail para o usu�rio.
If Empty(cRet)
	If Empty(ZW0->ZW0_EMAIL)
		cRet := u_WFTraduzir("N�o existe e-mail cadastrado para esse login")
	EndIf
EndIf

//Envia o e-mail com a senha.
If Empty(cRet)

	cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
	cAccount  := AllTrim(GetNewPar("MV_RELFROM"," "))
	cEnvia    := "portal.cliente@br.gt.com"
	cRecebe   := AllTrim(ZW0->ZW0_EMAIL)
	cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))

	cMensagem := u_WFTraduzir("Voc� est� recebendo a senha de utiliza��o do portal do cliente da Grant Thornton.") + CRLF
	cMensagem += u_WFTraduzir("A senha do usu�rio") + " " + Alltrim(ZW0->ZW0_LOGIN) + " " + u_WFTraduzir("�") + " " + AllTrim(cNewSenha)
	 
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou     //realiza conex�o com o servidor de internet
	
	If lConectou
		SEND MAIL FROM cEnvia;
		TO cRecebe;
		SUBJECT u_WFTraduzir("Envio de senha do portal do cliente") ;
		BODY cMensagem ;
		RESULT lEnviado
	Endif
	 
	If !lEnviado
		cRet := u_WFTraduzir("Erro no envio do e-mail.")
	Endif
	 
	DISCONNECT SMTP SERVER Result lDisConectou
Endif


If !Empty(cRet)	
	//Tratamento de acentua��o para a msg de erro.
	cRet := EncodeUTF8(cRet)
Else
	//Grava��o da  nova senha
	ZW0->(RecLock("ZW0",.F.))
	ZW0->ZW0_SENHA  := "/"+Encript(AllTrim(cNewSenha),1)+"/"
	ZW0->ZW0_ALTSEN := "S"
	ZW0->(MsUnlock())
EndIf

WEB EXTENDED END

Return cRet

/*
Fun��o  : WV001MudaSenha
Objetivo: Altera a seha do usu�rio
Autor   : Eduardo C. Romanini
Data    : 31/05/2012
*/
*----------------------------*
User Function WV001MudaSenha()
*----------------------------*
Local cRet   := ""
Local cLogin := ""
Local cPass := ""  

WEB EXTENDED INIT cRet

cLogin := HttpGet->cLogin
cPass  := HttpGet->cSenha

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

//Verifica se o login informado esta cadastrado.
ZW0->(DbSetOrder(1))
If ZW0->(DbSeek(xFilial("ZW0")+AllTrim(cLogin)))

	ZW0->(RecLock("ZW0",.F.))
	ZW0->ZW0_SENHA  := "/"+Encript(AllTrim(cPass),1)+"/"
	ZW0->ZW0_ALTSEN := ""
	ZW0->(MsUnlock())
EndIf

WEB EXTENDED END

Return cRet
