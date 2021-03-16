//Irei incluir algumas bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "FwMVCDef.ch"
#INCLUDE "AP5MAIL.CH"
 
/*
Funcao      : LGFAT006
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exportação pedido de venda AGV
Autor       : Renato Rezende
Cliente		: Exeltis
Data/Hora   : 15/05/2018
*/
*--------------------------*
 User Function LGFAT006() 
*--------------------------*
Local cArqTrb		:= ""
Local cMsgErro		:= "Nenhum pedido foi selecionado!"
Local cMsg			:= ""
Local aColumn		:= {}
Local bKeyF12		:= {||  FiltroSC5("F12"),oMark:SetInvert(.F.),oMark:Refresh(),oMark:GoTop(.T.) } //Programar a tecla F12 

Private aStruSC5	:= {} 
Private aDadosLog	:= {}
Private aGrvSC5		:= {}
Private aErroSC5	:= {}
Private oMark		:= Nil
Private cPerg		:= "LGFAT006"
Private cMarca 		:= ""
Private lCtrArq		:= .F.

//Validação de empresa
If !cEmpAnt $ "LG/SU" 
	Alert("Função desenvovida para empresa Exeltis e não disponivel para esta empresa.","HLB BRASIL")
	Return Nil
Endif
     
//Criando Pergunte
CriaPerg()

//Chamando Pergunte
If !Pergunte(cPerg,.T.)
	Return nil  
EndIf


//Verifico se já  existe esta tabela
If Select ("TMPSC5")>0
	TMPSC5->(DbCloseArea())
EndIf

//Estrutura da tabela
aAdd(aStruSC5,{"C5_OK"    	,"C"					,2  	  						,0						})
aAdd(aStruSC5,{"C5_P_ENV1"	,AvSx3("C5_P_ENV1"		,2),AvSx3("C5_P_ENV1"	,3)		,AvSx3("C5_P_ENV1"	,4)	})
aAdd(aStruSC5,{"C5_FILIAL"	,AvSx3("C5_FILIAL"		,2),AvSx3("C5_FILIAL"	,3)		,AvSx3("C5_FILIAL"	,4)	})
aAdd(aStruSC5,{"C5_NUM"		,AvSx3("C5_NUM"			,2),AvSx3("C5_NUM"		,3)		,AvSx3("C5_NUM"	 	,4)	})
aAdd(aStruSC5,{"C5_TIPO"	,AvSx3("C5_TIPO"		,2),AvSx3("C5_TIPO"		,3)		,AvSx3("C5_TIPO" 	,4)	})
aAdd(aStruSC5,{"C5_CLIENTE"	,AvSx3("C5_CLIENTE"		,2),AvSx3("C5_CLIENTE"	,3)		,AvSx3("C5_CLIENTE" ,4)	})
aAdd(aStruSC5,{"C5_LOJACLI"	,AvSx3("C5_LOJACLI"		,2),AvSx3("C5_LOJACLI"	,3)		,AvSx3("C5_LOJACLI"	,4)	})
aAdd(aStruSC5,{"C5_EMISSAO"	,AvSx3("C5_EMISSAO"		,2),AvSx3("C5_EMISSAO"	,3)		,AvSx3("C5_EMISSAO"	,4)	})

//Cria Coluna do Browse
aAdd(aColumn,{"Filial"		,{||TMPSC5->C5_FILIAL}	,TAMSX3("C5_FILIAL")[3]	,PesqPict("SC5","C5_FILIAL")	,1,TAMSX3("C5_FILIAL")[1]	,TAMSX3("C5_FILIAL")[2]	})
aAdd(aColumn,{"Num. Pedido"	,{||TMPSC5->C5_NUM}		,TAMSX3("C5_NUM")[3]	,PesqPict("SC5","C5_NUM")  		,1,TAMSX3("C5_NUM")[1]		,TAMSX3("C5_NUM")[2]	})
aAdd(aColumn,{"Tipo Pedido"	,{||TMPSC5->C5_TIPO}	,TAMSX3("C5_TIPO")[3]	,PesqPict("SC5","C5_TIPO")		,1,TAMSX3("C5_TIPO")[1]		,TAMSX3("C5_TIPO")[2]	})
aAdd(aColumn,{"Cliente"		,{||TMPSC5->C5_CLIENTE}	,TAMSX3("C5_CLIENTE")[3],PesqPict("SC5","C5_CLIENTE")	,1,TAMSX3("C5_CLIENTE")[1]	,TAMSX3("C5_CLIENTE")[2]})
aAdd(aColumn,{"Loja Cli."	,{||TMPSC5->C5_LOJACLI}	,TAMSX3("C5_LOJACLI")[3],PesqPict("SC5","C5_LOJACLI")	,1,TAMSX3("C5_LOJACLI")[1]	,TAMSX3("C5_LOJACLI")[2]})
aAdd(aColumn,{"Dt. Emissão"	,{||TMPSC5->C5_EMISSAO}	,TAMSX3("C5_EMISSAO")[3],PesqPict("SC5","C5_EMISSAO")	,1,TAMSX3("C5_EMISSAO")[1]	,TAMSX3("C5_EMISSAO")[2]})

//A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe
cArqTrb := CriaTrab(aStruSC5, .T.)

//A função dbUseArea abre uma tabela de dados na área de trabalho
DbUseArea(.T.,,cArqTrb,"TMPSC5",.F.,.F.)

//Select e Filtro da tela
Processa( {|| FiltroSC5() }, "Aguarde...", "Carregando os dados...",.F.)


TMPSC5->(DbGoTop())
If TMPSC5->(!BOF()) .AND. TMPSC5->(!EOF())

	//Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias("TMPSC5")
	     
	//Setando semáforo, descrição e campo de mark
	oMark:SetSemaphore(.T.)
	oMark:SetDescription('Seleção dos pedidos que serão enviados a AGV')
	oMark:SetFieldMark('C5_OK')
	oMark:SetParam(bKeyF12) // Seta tecla F12	
	
	//Setando Legenda
	oMark:AddLegend("!Alltrim(TMPSC5->C5_P_ENV1) $ '3|2' "	, "BR_VERMELHO"	, "Pedido Não Enviado")
	oMark:AddLegend("Alltrim(TMPSC5->C5_P_ENV1) == '3' "	, "BR_VERDE"	, "Pedido Enviado")
	oMark:AddLegend("Alltrim(TMPSC5->C5_P_ENV1) == '2' "	, "BR_CINZA"	, "Pedido Com Bloqueio")

	//Adiciona coluna no Browse
	oMark:SetColumns(aColumn)
	
	//Adiciona botoes na janela
	oMark:AddButton("Enviar Pedido"		, { || IIF(VldMark("TMPSC5"),LGFAT6EN(),MsgInfo(cMsgErro,"HLB BRASIL")),oMark:Refresh(.T.)}						,,,, .F., 2 )
	oMark:AddButton("Marcar/Desmarca"	, { || MarcaTds("TMPSC5",oMark:Mark()),oMark:Refresh(.T.)}															,,,, .F., 2 )
	oMark:AddButton("Legenda"			, { || LGFATLEG()}										   															,,,, .F., 2 )
	
	oMark:ForceQuitButton(.T.)
	     
	//Ativando a janela
	oMark:Activate()
	oMark:oBrowse:Setfocus()//Seta o foco na grade
	oMark:DeActivate()
	oMark := Nil
Else
	MsgInfo("ATENÇÃO!Nenhum dado encontrado para geração do arquivo."," HLB BRASIL")
	Return Nil
EndIf

Return Nil

/*
Função  	: LGFAT6EN
Objetivo	: Rotina para processamento e verificação de quantos registros estão marcados
Autor       : Renato Rezende
Data/Hora   : 15/05/2018
*/
*-----------------------------* 
 Static Function LGFAT6EN()
*-----------------------------*
Local cSubject		:= "[EXELTIS] Pedidos enviados para liberação: "+DtoC(Date())
Local cAnexos		:= ""
Local cTo			:= AllTrim(GetMv("MV_P_00040",,"renato.rezende@hlb.com.br"))
Local cToOculto		:= AllTrim(GetMv("MV_P_00041",," "))
Local nR			:= 0
Local aFile			:= {}
Local lEnvia		:= .F.
Local lGrvArqPed	:= .F.
Local lUP2Ftp		:= .F.

Private cDirFtp 	:= GetNewPar('MV_P_WMS05' , '/TEST/WMS05/')
Private cDirServ	:= "\FTP\"+cEmpAnt+"\AGV\WMS05"
Private cNomeArq	:= "SA"+STRZERO(DAY(Date()),2,0)+STRZERO(Month(Date()),2,0)+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".TXT"
Private cDate 		:= DtoC(Date())
Private cTime 		:= SubStr(Time(),1,5)
Private cUser 		:= UsrFullName(RetCodUsr())

//Verifica se será enviado o pedido realmente
If !MsgYesNo("Deseja realmente enviar os pedidos selecionados?","HLB BRASIL")
	Return .F.
EndIf

//Monta o arquivo de pedidos
lGrvArqPed:= GrvArqPed("TMPSC5")


//Subir arquivo no FTP da AGV
If lGrvArqPed 
	lUP2Ftp := UP2FTP()
	cAnexos := cDirServ +"\"+ cNomeArq
EndIf

//Monta html da mensagem do email
cMsg := HtmlEmail(lGrvArqPed,lUP2Ftp)
//Envia email de processamento
lEnvia:= EnviaEma(cMsg,cSubject,cTo,cToOculto,cAnexos)

If lEnvia .AND. lGrvArqPed .AND. lUP2Ftp
	MsgInfo("Processo finalizado, verificar log de email!","HLB BRASIL")
Else
	MsgInfo("Processo finalizado com ERRO, verificar log de email!","HLB BRASIL")
EndIf

//Grava campo no SC5 de pedidos enviados.
GrvSC5()

//Compacta pasta no servidor
If Compacta( cDirServ + "\*.txt" , cDirServ + "\processados.rar" )
	conout("Pasta Zipada "+cDirServ+"\WMS05\")
EndIf

Return NIL

/*
Função  	: ConectaFTP
Objetivo	: Conexão ao servidor FTP
*/
*---------------------------------*
 Static Function ConectaFTP()
*---------------------------------*  
Local lRet 		:= .T.  
Local i
Local nTry 		:= 3 
Local cFtp 		:= GETMV("MV_P_FTP",,'ftp.agv.com.br') 
Local cLogin	:= GETMV("MV_P_USR",,'exeltis') 
Local cPass		:= GETMV("MV_P_PSW",,'7Tp@ex3lt!s') 

For i := 1 To nTry 
	If (lRet := FTPConnect(cFtp,,cLogin,cPass))
		Exit
	EndIf   
	Sleep(5000)//5 segundos
Next

Return(lRet)

/*
Função  	: UP2FTP
Objetivo	: Envio do arquivo para FTP da AGV
*/
*------------------------------------------------*
 Static Function UP2FTP()
*------------------------------------------------*  
Local lRet := .T.

//Conecta no FTP
If ConectaFTP()

	If !FtpDirChange(cDirFtp)
		MsgStop("Erro na mudança de pasta do Ftp ( WMS05 )", "HLB BRASIL")
		lRet := .F.	
		Break
	EndIf
	
	If !FtpUpLoad(cDirServ +"\"+ cNomeArq , cNomeArq)
		MsgStop("Erro ao efetuar upload do arquivo " + cNomeArq + " ao servidor Ftp.", "HLB BRASIL")
		lRet := .F.	
		Break
	EndIf
EndIf

Return(lRet)

/*
Funcao		: LGFATLeg
Objetivo	: Legenda da tela MVC
*/
*------------------------------*
 Static Function LGFATLEG()
*------------------------------*
Local oLegenda  :=  FWLegend():New()
	
//Monta as cores
oLegenda:Add("","BR_VERDE"		,"Pedido Enviado"	)
oLegenda:Add("","BR_VERMELHO"	,"Pedido Não Enviado"	)
oLegenda:Add("","BR_CINZA"		,"Pedido Com Bloqueio"	)
	
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return nil

/*
Funcao      : CriaPerg
Objetivos   : Cria o Pergunte no SX1
Autor     	: Renato Rezende
*/
*----------------------------*
 Static Function CriaPerg()
*----------------------------*
PutSx1(cPerg,"01" ,"Emissao De: ? "					,"Emissao De: ?"  					,"Emissao De: ?"  					,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,"01012000"	,""		,""		,""		,"","","","","","","","","",{"Data Inicial de emissão"} 							,{},{})
PutSx1(cPerg,"02" ,"Emissao Ate: ?"					,"Emissao Ate: ?" 					,"Emissao Ate: ?"	  				,"mv_ch2","D",08,0, 0,"G","","","","","mv_par02",""		,""		,""		,"01012030"	,""		,""		,""		,"","","","","","","","","",{"Data Final de emissão" }								,{},{})
PutSx1(cPerg,"03" ,"Mostrar Pedidos já enviados ?" 	,"Mostrar titulos já enviados ?"	,"Mostrar titulos já enviados ?"	,"mv_ch3","N",01,0,01,"C","","","","","mv_par03","Não"	,"Não"	,"Não"	,"Não"		,"Sim"	,"Sim"	,"Sim"	,"Ambos","Ambos","Ambos","","","","","","",{"Informar se deja que aparecão so titulos ja enviados"},{},{})
PutSx1(cPerg,"04" ,"Pedido de: ? "					,"Nota de: ? "  					,"Nota de: ? "  					,"mv_ch4","C",09,0, 0,"G","","","","","mv_par04",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Numero da nota fiscal Inicial"} 						,{},{})
PutSx1(cPerg,"05" ,"Pedido Ate: ?"					,"Nota Ate: ?" 						,"Nota Ate: ?" 		  				,"mv_ch5","C",09,0, 0,"G","","","","","mv_par05",""		,""		,""		,"ZZZZZZZZZ",""		,""		,""		,"","","","","","","","","",{"Numero da nota fiscal Final" }						,{},{})

Return Nil

/*
Função  : FiltroSC5()
Objetivo: Filtro e select do conteúdo da tela
Autor   : Renato Rezende
*/
*-----------------------------------*
 Static Function FiltroSC5(cOpcao)
*-----------------------------------*
Default cOpcao := ""

If cOpcao == "F12"
	//Chamando Pergunte
	If !Pergunte(cPerg,.T.)
		Return  
	EndIf
EndIf

//Verifico se ja existe esta Query
If Select("QRY1") > 0
	QRY1->(DbCloseArea())
EndIf 

//Verifico se já  existe esta tabela
If Select ("TMPSC5")>0
	TMPSC5->(DbCloseArea()) 
	
	//Cria tabela temporaria
	cNome	:=	CriaTrab(aStruSC5, .T.)
	DbUseArea(.T.,,cNome,'TMPSC5',.F.,.F.)
EndIf

//Qyery para pegar os dados que seram apresentados
cQuery1 := "	SELECT C5_FILIAL,C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_EMISSAO,C5_P_ENV1,C5_OK,C5_NOTA FROM "+RetSqlName("SC5")+" "  + CRLF
cQuery1 += "	 WHERE C5_FILIAL = '"+FwxFilial("SC5")+"' " + CRLF 

If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cQuery1 += "  AND (C5_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"') " + CRLF 
EndIf

If !Empty(MV_PAR04) .OR. !Empty(MV_PAR05)
	cQuery1 += "	   AND (C5_NUM BETWEEN '"+Alltrim(MV_PAR04)+"' AND '"+Alltrim(MV_PAR05)+"') " + CRLF 
EndIf

cQuery1 += "	   AND D_E_L_E_T_ <> '*' " + CRLF
cQuery1 += "	   AND C5_NOTA = '' "  + CRLF

If MV_PAR03 == 2
	cQuery1 += "  AND C5_P_ENV1 = '3' " 
ElseIf MV_PAR03 == 1 
	cQuery1 += "  AND C5_P_ENV1 <> '3'	
EndIf 

cQuery1 += "ORDER BY C5_NUM+C5_EMISSAO " + CRLF

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery1),"QRY1",.F.,.T.)

//Coloco os dados da query na tabela temporaria
QRY1->(DbGoTop())
While QRY1->(!EOF())

	RecLock("TMPSC5",.T.)
	
	TMPSC5->C5_FILIAL   := QRY1->C5_FILIAL
	TMPSC5->C5_NUM  	:= QRY1->C5_NUM
	TMPSC5->C5_TIPO		:= QRY1->C5_TIPO
	TMPSC5->C5_CLIENTE	:= QRY1->C5_CLIENTE
	TMPSC5->C5_LOJACLI	:= QRY1->C5_LOJACLI
	TMPSC5->C5_EMISSAO	:= STOD(QRY1->C5_EMISSAO)
	TMPSC5->C5_P_ENV1	:= QRY1->C5_P_ENV1
	
	TMPSC5->(MsUnlock())
	QRY1->(DbSkip())
EndDO

Return

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : lRet
Objetivos   : Conecta e envia e-mail
Autor     	: Renato Rezende
*/
*----------------------------------------------------------------*
 Static Function EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
*----------------------------------------------------------------*
Local cFrom			:= AllTrim(GetMv("MV_RELFROM"	,,""))
Local cPassword 	:= AllTrim(GetMv("MV_RELPSW"	,,""))
Local cUserAut  	:= Alltrim(GetMv("MV_RELAUSR"	,,""))//Usuário para Autenticação no Servidor de Email 
Local cPassAut  	:= Alltrim(GetMv("MV_RELAPSW"	,,""))//Senha para Autenticação no Servidor de Email
Local cServer		:= AllTrim(GetMv("MV_RELSERV"	,,""))//Nome do Servidor de Envio de Email
Local cAccount		:= AllTrim(GetMv("MV_RELACNT"	,,""))//Conta para acesso ao Servidor de Email
Local cAttachment	:= cAnexos
Local cCC      		:= ""
Local cTo			:= AvLeGrupoEMail(cTo)

Local lAutentica	:= GetMv("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local lRet			:= .T.

If Empty(cServer)
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	lRet := .F.
EndIf

If Empty(cAccount)
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	lRet := .F.
EndIf

If lRet
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
	
	If !lOK
		MsgInfo("Falha na Conexão com Servidor de E-Mail","HLB BRASIL")
		lRet := .F.
	Else
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				MsgInfo("Falha na Autenticacao do Usuario","HLB BRASIL")
				DISCONNECT SMTP SERVER RESULT lOk
				lRet := .F.
			EndIf
		EndIf
		IF !EMPTY(cCC)
			SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
			SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		Else
			SEND MAIL FROM cFrom TO cTo BCC cToOculto ;
			SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		EndIf
		If !lOK
			ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
			lRet := .F.
		ENDIF
	ENDIF
	
	DISCONNECT SMTP SERVER
Else
	MsgInfo("Falha na Conexão com Servidor de E-Mail","HLB BRASIL")
EndIf

Return lRet

/*
Funcao      : MarcaTds
Parametros  : cAlias,cMarca
Objetivos   : Marcar todos os registros do FWMarkBrowse
Autor     	: Renato Rezende
*/
*----------------------------------------*
Static Function MarcaTds(cAlias,cMarca)
*----------------------------------------*

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	RecLock(cAlias,.F.)
		If (cAlias)->C5_OK == cMarca
			(cAlias)->C5_OK :=Space(02)
		Else
			(cAlias)->C5_OK := cMarca
		EndIf
	(cAlias)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbGoTop())

Return Nil

/*
Funcao      : HtmlEmail
Retorno     : cHtml
Objetivos   : Criar corpo do email de Notificação
Autor       : Renato Rezende
Data/Hora   : 
*/
*--------------------------------------------*
 Static Function HtmlEmail(lGeraArq,lUPArq)
*--------------------------------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>PROCESSAMENTO</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
//Arquivo gerado com sucesso
If lGeraArq .AND. lUPArq
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVO GERADO COM SUCESSO</font></td>
	cHtml += '			</tr>
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVO ANEXO NO EMAIL</font></td>
	cHtml += '			</tr>
EndIf
//Arquivo não gerado
If !lGeraArq
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVO NÃO FOI GERADO, FAVOR VERIFICAR!!</font></td>
	cHtml += '			</tr>
EndIf
//Arquivo não subiu para o FTP
If !lUPArq 
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVO NÃO ENVIADO AO FTP, FAVOR VERIFICAR!!</font></td>
	cHtml += '			</tr>
EndIf
If Len(aErroSC5) > 0
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">PEDIDOS COM ERRO:</font></td>
	cHtml += '			</tr>
	//Log gerado do processamento
	For nR:= 1 to Len(aErroSC5)
		cHtml += '			<tr>
		cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">
		cHtml += '				Pedido: '+Alltrim(aErroSC5[nR][1])+' <br/>
		cHtml += '				Mensagem: '+Alltrim(aErroSC5[nR][3])+' <br/>
		cHtml += '				------------------</font></td>
		cHtml += '			</tr>
	Next nR	
EndIf
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml

/*
Funcao      : GrvArqPed
Objetivos   : Gera arquivo TXT dos Pedidos
Autor       : Renato Rezende
*/                              
*--------------------------------------------*
 Static Function GrvArqPed(cAlias)                  
*--------------------------------------------* 
Local lRet 		:= .T.
Local cQuery	:= ""
Local cConteudo	:= ""
Local cCodAGV	:= AllTrim(GetMv("MV_P_CDAGV"	,,"C5376"))//Código da Exeltis na AGV
Local cCCAGV	:= AllTrim(GetMv("MV_P_CCADV"	,,"B5352060000"))//Centro de Custo da Exeltis na AGV
Local lLiberado	:= .F.
Local cStatus	:= "0"
Local oFile		:= nil
Local aArqs		:= {}
Local cMsg		:= ""

//Verifica pasta no servidor para salvar o arquivo
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\AGV")
		MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS05")
	Elseif !ExistDir("\FTP\"+cEmpAnt+"\AGV")
		MakeDir("\FTP\"+cEmpAnt+"\AGV")
		MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS05")
	Elseif !ExistDir("\FTP\"+cEmpAnt+"\AGV\WMS05")
		MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS05") 
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
	MakeDir("\FTP\"+cEmpAnt+"\AGV")
	MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS05")
EndIf

If !ExistDir("\FTP\"+cEmpAnt+"\AGV\WMS05")
	conout("Fonte LGFAT006: Falha ao carregar diretório FTP no Servidor!")
	lRet := .F.
Else	
	
	//Apaga arquivos que ficaram na pasta por erro
	aArqs:= Directory(cDirServ+"\*.txt")
	For nR:=1 to Len(aArqs)
		FErase(cDirServ+"\"+aArqs[nR][1])
	Next nR
	
	//Cria arquivo txt e preenche com dados.
	nHdl := FCREATE(cDirServ+"\"+cNomeArq,0 )  //Criação do Arquivo txt.
	If nHdl == -1 // Testa se o arquivo foi gerado 
		conout("Fonte LGFAT006: O arquivo "+cNomeArq+" nao pode ser executado.")
		lRet := .F.
	Else
		//Geração do arquivo
		(cAlias)->(DbGoTop())
	
		While (cAlias)->(!EOF())
			cQuery 		:= ""
			cConteudo	:= ""
			lLiberado	:= .F.
			cStatus		:= "0"
			
			//Verifico se ja existe esta Query
			If Select("TMPARQ") > 0
				TMPARQ->(DbCloseArea())
			EndIf 
			
			//Verifica pedido marcado no Browse
			If(!Empty(Alltrim((cAlias)->C5_OK)))
							
				//Liberar Pedido
				lLiberado:= LibPed((cAlias)->C5_NUM) 
				
				If lLiberado
					cQuery:= "	SELECT A1.A1_FILIAL,A1.A1_CGC, A1.A1_NOME, A1.A1_PESSOA, A1.A1_INSCR, A1.A1_END, A1.A1_BAIRRO, A1.A1_MUN, A1.A1_EST, A1.A1_CEP, A1.A1_PAIS, A1.A1_COD, A1.A1_LOJA, A1.A1_TEL,A1.A1_CODPAIS,RIGHT(RTRIM(A1.A1_DDD),2)AS DDD,RTRIM(REPLACE(A1.A1_TEL,'-','')) AS TEL, " + CRLF	
	 		   		cQuery+= "		   (SELECT SUM(C6_VALOR) FROM SC6LG0 AS TC6 WHERE TC6.C6_NUM = C9.C9_PEDIDO AND TC6.C6_FILIAL = C9.C9_FILIAL AND TC6.D_E_L_E_T_ <> '*' ) AS VALORTOTAL , " + CRLF
	 		   		cQuery+= "		   C9.C9_PEDIDO, C9.C9_FILIAL, C9.C9_ITEM, C9.C9_PRODUTO, C9.C9_QTDLIB, C9.C9_LOTECTL, C9.C9_DTVALID, C9.C9_LOCAL, " + CRLF
	 		   		cQuery+= "		   C5.C5_FILIAL, C5.C5_NUM, C5.C5_EMISSAO, C5.C5_CLIENTE, C5.C5_LOJACLI, C5.C5_CONDPAG, " + CRLF
	 		   		cQuery+= "		   ISNULL(CH.CCH_CODIGO,'')AS CODPAIS,ISNULL(CH.CCH_PAIS,'') AS NOMEPAIS " + CRLF  	
	 		   		cQuery+= "	  FROM "+RetSQLName("SC9")+" AS C9 " + CRLF
	 		   		cQuery+= "	  LEFT JOIN "+RetSQLName("SC5")+" AS C5 ON C5.C5_NUM = C9.C9_PEDIDO AND C5.C5_FILIAL = C9.C9_FILIAL AND C5.D_E_L_E_T_ <> '*' " + CRLF
	 		   		cQuery+= "	  LEFT JOIN "+RetSQLName("SA1")+" AS A1 ON A1.A1_COD = C9.C9_CLIENTE AND A1.A1_LOJA	 = C9.C9_LOJA AND A1.A1_FILIAL = '"+FwxFilial("SA1")+"' AND A1.D_E_L_E_T_ <> '*' " + CRLF
	 		   		cQuery+= "	  LEFT JOIN "+RetSQLName("CCH")+" AS CH ON CH.CCH_CODIGO = A1.A1_CODPAIS AND CH.CCH_FILIAL = '"+FwxFilial("CCH")+"' AND CH.D_E_L_E_T_ <> '*' " + CRLF 
	 		   		cQuery+= "	 WHERE C9.D_E_L_E_T_<>'*' AND C9.C9_NFISCAL = ''  " + CRLF
	 		   		cQuery+= "	   AND C5.C5_NUM = '"+Alltrim((cAlias)->C5_NUM)+"' AND C5.C5_FILIAL = '"+FwxFilial("SC5")+"' " + CRLF
					cQuery+= "	 ORDER BY C9.C9_ITEM " + CRLF
					
					DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),"TMPARQ",.F.,.T.)
					
					TMPARQ->(DbGoTop())
					While TMPARQ->(!EOF())
						
						cConteudo:= PADR(Alltrim(TMPARQ->C5_NUM),10)//Número de Documento
						cConteudo+=	GravaData(StoD(TMPARQ->C5_EMISSAO),.F.,5)//Data Saída/Emissão
						cConteudo+=	PADL(Alltrim(TRANSFORM((TMPARQ->VALORTOTAL),"@R 9999999999.99")),13, "0")//Valor NF
						cConteudo+=	Space(3)//Serie NF
						cConteudo+=	StrZero(0,6)//Volume
						cConteudo+=	Space(8)//Data geração
						cConteudo+=	Space(4)//Hora geração
						cConteudo+=	Space(8)//Natureza Operação
						cConteudo+=	PADR(Alltrim(TMPARQ->A1_CGC),18)//CNPJ
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_NOME)),40)//Razão Social
						cConteudo+=	PADR(TMPARQ->A1_PESSOA,1)//Tipo Destinatário
						cConteudo+=	IIF(Empty(TMPARQ->A1_INSCR),PADR("ISENTO",20),PADR(Alltrim(TMPARQ->A1_INSCR),20))//Inscr.Estadual
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_END,.T.)),40)//Endereço
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_BAIRRO)),20)//Bairro
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_MUN)),20)//Cidade
						cConteudo+=	PADR(TMPARQ->A1_EST,2)//Estado
						cConteudo+=	IIF(Empty(TMPARQ->A1_CEP),StrZero(8),PADR(Alltrim(TMPARQ->A1_CEP),8))//Cep
						cConteudo+=	PADR(TMPARQ->NOMEPAIS,30)//Pais
						cConteudo+=	PADR(TMPARQ->C5_CLIENTE,10)//Código do cliente
						cConteudo+=	PADR(Alltrim(TMPARQ->DDD)+Alltrim(TMPARQ->TEL),15)//Telefone cliente
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_END)),40)//Endereço entrega
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_BAIRRO)),20)//Bairro entrega
						cConteudo+=	PADR(Alltrim(FwCutOff(TMPARQ->A1_MUN)),20)//Cidade entrega
						cConteudo+=	PADR(TMPARQ->A1_EST,2)//Estado entrega
						cConteudo+=	IIF(Empty(TMPARQ->A1_CEP),StrZero(8),PADR(Alltrim(TMPARQ->A1_CEP),8))//Cep entrega
						cConteudo+=	PADR(Alltrim(TMPARQ->DDD)+Alltrim(TMPARQ->TEL),15)//Telefone cliente entrega
						cConteudo+=	PADR(TMPARQ->C9_PRODUTO,15)//Código do Produto
						cConteudo+=	PADL(Alltrim(TRANSFORM(TMPARQ->C9_QTDLIB,"@R 9999999999.99")),13, "0")//Quantidade
						cConteudo+=	PADR(TMPARQ->C9_LOTECTL,20)//Lote do Produto
						cConteudo+=	GravaData(StoD(TMPARQ->C9_DTVALID),.F.,5)//Data da Produção
						cConteudo+=	PADL(Alltrim(TRANSFORM(0,"@R 9999999999.99")),13, "0")//Peso Bruto
						cConteudo+=	PADL(Alltrim(TRANSFORM(0,"@R 9999999999.99")),13, "0")//Peso Liquido
						cConteudo+=	Space(10)//Transportadora
						cConteudo+=	Space(1)//Venda Proibida Amostra Grátis*
						cConteudo+=	Space(1)//Laudo Técnico
						cConteudo+=	Space(1)//PIN
						cConteudo+=	"S"//Endereço Entrega
						cConteudo+=	Space(44)//Chave de acesso
						cConteudo+=	PADR(Alltrim(cCCAGV),11)//Centro de Custo - Fixo AGV
						cConteudo+=	PADR(Alltrim(cCodAgv),5)//Cliente - Fixo AGV
						
						fWrite(nHdl,cConteudo+Chr(13)+Chr(10))
							
						TMPARQ->(DbSkip())
					EndDo
				
					cStatus	:= "3"
					cMsg	:= "Pedidos enviados com sucesso."
					//Grava tabela de log
					GravaLog(cMsg, cStatus, Alltrim((cAlias)->C5_NUM))
					Aadd(aGrvSC5,{Alltrim((cAlias)->C5_NUM),"SUCESSO",cMsg})
				EndIf
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		
		fclose(nHdl) //Fecha o arquivo que foi gerado
		If !lCtrArq
			FErase(cDirServ+"\"+cNomeArq)
			lRet:= .F.
		EndIf
	EndIf
	
EndIf

Return lRet


/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Renato Rezende 
*/
*--------------------------------------------------*
 Static Function compacta(cArquivo,cArqRar)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files (x86)\WinRAR\'

cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : LibPed
Parametros  : cNumPed
Retorno     : lRet
Objetivos   : Libera Pedido de venda
Autor       : Renato Rezende 
*/
*----------------------------------------*
 Static Function LibPed(cNumPed)
*----------------------------------------*
Local lRet		:= .F.
Local lAltPed	:= .T.
Local nR		:= 0
Local aArea     := GetArea()
Local aAreaC5   := SC5->(GetArea())
Local cMsg		:= ""

DbSelectArea("SC5")
SC5->(DbSetOrder(1))
SC5->(DbSeek(FwxFilial("SC5")+cNumPed))

//Valida pedido já está liberado
If !Empty(SC5->C5_LIBEROK)
	lAltPed := ExcLiber(cNumPed)	
EndIf

If lAltPed	
	//Liberacao do Pedido de Venda	
	aPvlNfs:={} ;aBloqueio:={}
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
	If !Empty(aBloqueio)
	
		cStatus := "2"
		cMsg	:= "Pedidos com bloqueio, não enviado."
		//Grava tabela de log
		GravaLog(cMsg, cStatus, cNumPed)
		Aadd(aGrvSC5,{Alltrim(cNumPed),"ERRO",cMsg})
		Aadd(aErroSC5,{Alltrim(cNumPed),"ERRO",cMsg})
		
	Else
		//Pedido Liberado
		lRet	:= .T.
		lCtrArq	:= .T.
	EndIf
EndIf

RestArea(aAreaC5)
RestArea(aArea)

Return(lRet)

/*
Funcao      : GrvSC5
Objetivos   : Gravar pedidos enviados
Autor       : Renato Rezende 
*/
*----------------------------*
 Static Function GrvSC5()
*----------------------------*
Local nR:= 0
Local aArea     := GetArea()
Local aAreaC5   := SC5->(GetArea())

/*
STATUS C5_P_ENV1
0 - Pedido não Enviado
1 - Erro Processo
2 - Pedido Bloqueado
3 - Enviado (Pendente retorno)
4 - Pedido Rejeitado
5 - Pedido Faturado
*/

DbSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
SC5->(DbGoTop())

//Grava C5_P_ENV1, pedido enviado AGV
For nR:= 1 to len(aGrvSC5)
	If SC5->(DbSeek(FwxFilial("SC5")+aGrvSC5[nR][1]))
		SC5->(RecLock("SC5",.F.))
			If aGrvSC5[nR][2]=="SUCESSO"
				SC5->C5_P_ENV1 := "3"
			Else
				SC5->C5_P_ENV1 := "2"
			EndIf
		SC5->(MsUnlock())
	EndIf
Next nR

RestArea(aAreaC5)
RestArea(aArea)
Return nil

/*
Funcao      : ExcLiber
Objetivos   : Exclui liberação do pedido de venda
Autor       : Renato Rezende 
*/
*----------------------------------*
 Static Function ExcLiber(cPedido)
*----------------------------------*
Local aArea     := GetArea()
Local aAreaC5   := SC5->(GetArea())
Local aAreaC6   := SC6->(GetArea())
Local aAreaC9	:= SC9->(GetArea())
Local lRet		:= .T.
     
DbSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
SC5->(DbGoTop())
     
DbSelectArea("SC6")
SC6->(DbSetOrder(1)) //C6_FILIAL + C6_NUM + C6_ITEM
SC6->(DbGoTop())

DbSelectArea("SC9")
SC9->(DbSetOrder(1)) //C9_FILIAL + C9_PEDIDO + C9_ITEM
SC9->(DbGoTop())

//Se conseguir posicionar no pedido
If SC5->(DbSeek(FWxFilial("SC5") + cPedido))

	//Se conseguir posicionar nos itens do pedido
	If SC6->(DbSeek(FWxFilial("SC6") + SC5->C5_NUM))
     
		//Percorre todos os itens
		While ! SC6->(EoF()) .And. SC6->C6_FILIAL = FWxFilial("SC6") .And. SC6->C6_NUM == cPedido

			SC9->(DbSeek(FWxFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
			While  (!SC9->(Eof())) .AND. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == FWxFilial("SC9")+SC6->(C6_NUM+C6_ITEM)
				SC9->(a460Estorna(.T.,.T.))
				SC9->(DbSkip())
			EndDo	  
	  
			SC6->(DbSkip())
		EndDo
		
		SC5->(RecLock("SC5", .F.))
			SC5->C5_LIBEROK := ""
		SC5->(MsUnLock())
	
	EndIf
EndIf

RestArea(aAreaC9)
RestArea(aAreaC6)
RestArea(aAreaC5)
RestArea(aArea)
Return lRet

/*
Funcao      : GravaLog
Objetivos   : Gravar Log da Integracao
Autor       : Renato Rezende
*/
*-------------------------------------------------------------*
 Static Function GravaLog(cLog , cStatus, cNumPed)                  
*-------------------------------------------------------------* 
/*
STATUS ZX0_STATUS
0 - Pedido não Enviado
1 - Erro Processo
2 - Pedido Bloqueado
3 - Enviado (Pendente retorno)
4 - Pedido Rejeitado
5 - Pedido Faturado 
*/

DbSelectArea("ZX0")

//Ocorreu problema no envio dos pedidos
ZX0->( RecLock("ZX0" , .T. ))
	ZX0->ZX0_FILIAL := FwxFilial("ZX0")
	ZX0->ZX0_USER 	:= cUserName
	ZX0->ZX0_DATA	:= dDatabase
	ZX0->ZX0_HORA 	:= Left(Time(), 5)
	ZX0->ZX0_PEDNUM	:= cNumPed
	ZX0->ZX0_ARQ	:= IIF(cStatus $ "0|1|2", "", cNomeArq)
	ZX0->ZX0_LOG 	:= cLog 
	ZX0->ZX0_STATUS	:= cStatus
	ZX0->ZX0_PFTP	:= cDirFtp
	ZX0->ZX0_TAB	:= "SC5"
	ZX0->ZX0_EMPT	:= "AGV"
ZX0->(MSunlock())

ZX0->(DbCloseArea())

Return Nil

/*
Funcao      : VldMark
Objetivos   : Valida se foi selecionado algum pedido no browser
Autor       : Renato Rezende
*/
*----------------------------------------*
 Static Function VldMark(cAlias)                  
*----------------------------------------* 
Local lRet := .F.

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	If(!Empty(Alltrim((cAlias)->C5_OK)))
		lRet:= .T.
		Exit
	EndIf
	(cAlias)->(DbSkip())
EndDo

Return lRet

/*
Funcao      : TratLog
Objetivos   : Função para tratar o log de erro.
Autor       : Renato Rezende
*/
*-------------------------------------*
 Static Function TratLog(aAutoErro)
*-------------------------------------*     
Local cRet	:= ""
Local nX	:= 1
 	
For nX:= 1 to Len(aAutoErro)
	If nX == 1
		cRet+=Alltrim(SubStr(aAutoErro[nX],1,At(CHR(13)+CHR(10),aAutoErro[nX])-1)+"; ")
	Else
		If At("INVALIDO",UPPER(aAutoErro[nX]))>0
			cRet += Alltrim(aAutoErro[nX])+"; "
		EndIf
	EndIf
Next nX

Return cRet