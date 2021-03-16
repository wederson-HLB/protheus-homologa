#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : GTHDC010
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Painel de Atualização Noturna.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------*
User Function GTHDC010()
*----------------------*
Local aCores    := {{"Z12->Z12_STATUS == '1'","BR_VERDE"   },; //Em Aberto
					{"Z12->Z12_STATUS == '2'","BR_VERMELHO"},; //Concluido
				    {"Z12->Z12_STATUS == '3'","BR_PRETO"   },; //Cancelado
				    {"Z12->Z12_STATUS == '4'","BR_AMARELO" }} //Em Atendimento

Private cCadastro  := "Painel de Atualização Noturna."
Private aRotina	  := {}
Private aIndexSA1 := {}  

Private cFiltra := "Z12_STATUS == '4'

aAdd(aRotina, { "Pesquisar"		,"PesqBrw"   , 0, 1})
aAdd(aRotina, { "Visualizar"	,"AxVisual"  , 0, 2})
aAdd(aRotina, { "Ferramentas"	,"U_HDC010T" , 0, 3})
aAdd(aRotina, { "Finalizar"		,"U_HDC010F" , 0, 4})

FilBrowse("Z12",@aIndexSA1,@cFiltra)

//Exibe o browse.
mBrowse( 6,1,22,75,"Z12",,,,,,aCores)

EndFilBrw("Z12",aIndexSA1)

Return .T.                 

/*
Funcao      : HDC010T
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibir Painel com Algumas ferramentas de Auxilio.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------*
User Function HDC010T()
*----------------------*

oDlg1      := MSDialog():New( 146,277,431,465,"Grant Thornton Brasil.",,,.F.,,,,,,.T.,,,.T. )

oGrp1      := TGroup():New( 024,004,076,084,"Brastorage",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn1      := TButton():New( 036,008,"Envia Email de Inicio"	,oGrp1,{|| SendBS(1) },072,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 056,008,"Envia Email de Conclusão"	,oGrp1,{|| SendBS(2) },072,012,,,,.T.,,"",,,,.F. )

oGrp2      := TGroup():New( 080,004,132,084,"Services",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn3      := TButton():New( 092,008,"Start Services"	,oGrp1,{|| Services(1) },072,012,,,,.T.,,"",,,,.F. )
oBtn4      := TButton():New( 112,008,"Stop Services"	,oGrp1,{|| Services(2) },072,012,,,,.T.,,"",,,,.F. )

oSBtn1     := SButton():New( 004,056,1,,oDlg1,,"", )

oDlg1:Activate(,,,.T.)


Return .T.   

/*
Funcao      : Services
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tela para Tratamento de Serviços.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-----------------------------*
Static Function Services(nOpcS)
*-----------------------------*
Local cMsgBtn := ""

Private lCheck1 := lCheck2 := lCheck3:= lCheck4 := .F.

If nOpcS == 1
	cMsgBtn := "START"
ElseIf nOpcS == 2
	cMsgBtn := "STOP"
EndIf

SetPrvt("oDlgS","oGrp1","oCBox1","oCBox2","oGrp2","oCBox3","oCBox4","oSBtn1","oBtn1")

oDlgS      := MSDialog():New( 214,501,434,768,"Services - Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,004,040,088,"GTCORP",oDlgS,CLR_BLACK,CLR_WHITE,.T.,.F. )
oCBox1     := TCheckBox():New( 016,008,"Balance",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox2     := TCheckBox():New( 028,008,"Slaves",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oGrp2      := TGroup():New( 048,004,084,088,"PRODUÇÃO",oDlgS,CLR_BLACK,CLR_WHITE,.T.,.F. )
oCBox3     := TCheckBox():New( 060,008,"Balance",,oGrp2,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox4     := TCheckBox():New( 072,008,"Slaves",,oGrp2,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oSBtn1     := SButton():New( 008,096,1,{|| oDlgS:end()},oDlgS,,"", )
oBtn1      := TButton():New( 088,004,cMsgBtn,oDlgS,{|| (ActionS(nOpcS),oDlgS:end())},084,012,,,,.T.,,"",,,,.F. )

oCBox1:bLClicked := {|| lCheck1:=!lCheck1 }
oCBox2:bLClicked := {|| lCheck2:=!lCheck2 }
oCBox3:bLClicked := {|| lCheck3:=!lCheck3 }
oCBox4:bLClicked := {|| lCheck4:=!lCheck4 }

oCBox1:bSetGet := {|| lCheck1 }
oCBox2:bSetGet := {|| lCheck2 }
oCBox3:bSetGet := {|| lCheck3 }
oCBox4:bSetGet := {|| lCheck4 }

oCBox1:bWhen := {|| .T. }
oCBox2:bWhen := {|| .T. }
oCBox3:bWhen := {|| .T. }
oCBox4:bWhen := {|| .T. }

oDlgS:Activate(,,,.T.)

Return .T.

/*
Funcao      : ActionS
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ação de Stop/Start Service
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*------------------------------*
Static Function ActionS(nOpcS)
*------------------------------*
Local aGTCORP	:= {}
Local aPRD		:= {}
              
aAdd(aGTCORP,".Balance GTCORP11")
aAdd(aGTCORP,".GTCORP11 01")
aAdd(aGTCORP,".GTCORP11 02")
aAdd(aGTCORP,".GTCORP11 03")
aAdd(aGTCORP,".GTCORP11 04")
aAdd(aGTCORP,".GTCORP11 05")
aAdd(aGTCORP,".GTCORP11 06")
aAdd(aGTCORP,".GTCORP11 07")
aAdd(aGTCORP,".GTCORP11 08")

aAdd(aPRD,".P11 - Balance Server")
aAdd(aPRD,".P11 - Server01")
aAdd(aPRD,".P11 - Server02")
aAdd(aPRD,".P11 - Server03")
aAdd(aPRD,".P11 - Server04")
aAdd(aPRD,".P11 - Server05")
aAdd(aPRD,".P11 - Server06")
aAdd(aPRD,".P11 - Server07")
aAdd(aPRD,".P11 - Server08")
aAdd(aPRD,".P11 - Server09")
aAdd(aPRD,".P11 - Server10")
aAdd(aPRD,".P11 - Server11")
aAdd(aPRD,".P11 - Server12")
aAdd(aPRD,".P11 - Server13")
aAdd(aPRD,".P11 - Server14")
aAdd(aPRD,".P11 - Server15")
aAdd(aPRD,".P11 - Server16")
aAdd(aPRD,".P11 - Server17")
aAdd(aPRD,".P11 - Server18")
aAdd(aPRD,".P11 - Server19")
aAdd(aPRD,".P11 - Server20")
aAdd(aPRD,".P11 - Server21")
aAdd(aPRD,".P11 - Server22")
aAdd(aPRD,".P11 - Server23")
aAdd(aPRD,".P11 - Server24")
aAdd(aPRD,".P11 - Server25")
aAdd(aPRD,".P11 - Server26")
aAdd(aPRD,".P11 - Server27")
aAdd(aPRD,".P11 - Server28")
aAdd(aPRD,".P11 - Server29")
aAdd(aPRD,".P11 - Server30")
aAdd(aPRD,".P11 - Server31")
aAdd(aPRD,".P11 - Server32")
aAdd(aPRD,".P11 - Server33")
aAdd(aPRD,".P11 - Server34")
aAdd(aPRD,".P11 - Server35")
aAdd(aPRD,".P11 - Server36")
aAdd(aPRD,".P11 - Server37")
aAdd(aPRD,".P11 - Server38")
aAdd(aPRD,".P11 - Server39")
aAdd(aPRD,".P11 - Server40")
aAdd(aPRD,".P11 - Server41")
aAdd(aPRD,".P11 - Server42")
aAdd(aPRD,".P11 - Server43")
aAdd(aPRD,".P11 - Server44")
aAdd(aPRD,".P11 - Server45")
aAdd(aPRD,".P11 - Server46")
aAdd(aPRD,".P11 - Server47")
aAdd(aPRD,".P11 - Server48")
aAdd(aPRD,".P11 - Server49")
aAdd(aPRD,".P11 - Server50")
                            
//GTCORP
If lCheck1  
	//StartJob( "U_Serv" , GetEnvServer() , .F., nOpcS,aGTCORP[1],"GTCORP",1)
	Serv(nOpcS,aGTCORP[1],"GTCORP",1)
EndIf
If lCheck2
	For i := 2 to Len(aGTCORP)                                                       
		//StartJob( "U_Serv" , GetEnvServer() , .F., nOpcS,aGTCORP[i],"GTCORP",i)
		Serv(nOpcS,aGTCORP[i],"GTCORP",i)
	Next i
EndIf

//PRD
If lCheck3
	//StartJob( "U_Serv" , GetEnvServer() , .F., nOpcS,aPRD[1],"PRD",1)
	Serv(nOpcS,aPRD[1],"PRD",1)
EndIf
If lCheck4
	For i := 2 to Len(aPRD) 
		//StartJob( "U_Serv" , GetEnvServer() , .F., nOpcS,aPRD[i],"PRD",i)
		Serv(nOpcS,aPRD[i],"PRD",i)
	Next i
EndIf

Return .T.

/*
Funcao      : Serv
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Manipular Serviço do Servidor.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------------------------*
//User Function Serv(nOpcS,cService,cAmb,nI)
Static Function Serv(nOpcS,cService,cAmb,nI)
*----------------------------------------*
Local cArq := GetTempPath()+ALLTRIM(STR(nOpcS))+cAmb+ALLTRIM(STR(nI))+".BAT"
Private nHandle := 0

nHandle := MSFCREATE(cArq)
If nOpcS == 1
	Fwrite(nHandle, 'Net Start "'+cService+'"')
ElseIf  nOpcS == 2
	Fwrite(nHandle, 'Net Stop "'+cService+'"')
EndIf
FClose(nHandle)                           
           
shellExecute( "Open", cArq, "", /*"C:\"*/GetTempPath(), 0 )
Sleep(500)

FErase(cArq)  

Return .T.
/*
Funcao      : SendINIBS
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Enviar Atividade Brastorage
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------*
Static Function SendBS(nOpcBS)
*----------------------*
Local cMsg := ""           
Local lOk := .F.
Local lCheck1 := lCheck2 := lCheck3:= lCheck4 := lCheck6 := .F.
Local lCheck5 := .T.
Local cCodUsr := RetCodUsr()

oDlg2      := MSDialog():New( 193,251,438,433,"Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 020,004,112,080,"Seleciones os Servidores:",oDlg2,CLR_BLACK,CLR_WHITE,.T.,.F. )
oCBox1     := TCheckBox():New( 028,008,"10.0.30.2",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox2     := TCheckBox():New( 040,008,"10.0.30.3",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox3     := TCheckBox():New( 052,008,"10.0.30.4",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox4     := TCheckBox():New( 064,008,"10.0.30.5",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox5     := TCheckBox():New( 076,008,"10.0.30.20",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox6     := TCheckBox():New( 088,008,"10.0.30.22",,oGrp1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oSBtn1     := SButton():New( 004,056,1,{|| (lOk:=.T.,oDlg2:end())},oDlg2,,"", )

oCBox1:bLClicked := {|| lCheck1:=!lCheck1 }
oCBox2:bLClicked := {|| lCheck2:=!lCheck2 }
oCBox3:bLClicked := {|| lCheck3:=!lCheck3 }
oCBox4:bLClicked := {|| lCheck4:=!lCheck4 }
oCBox5:bLClicked := {|| lCheck5:=!lCheck5 }
oCBox6:bLClicked := {|| lCheck6:=!lCheck6 }

oCBox1:bSetGet := {|| lCheck1 }
oCBox2:bSetGet := {|| lCheck2 }
oCBox3:bSetGet := {|| lCheck3 }
oCBox4:bSetGet := {|| lCheck4 }
oCBox5:bSetGet := {|| lCheck5 }
oCBox6:bSetGet := {|| lCheck6 }

oCBox1:bWhen := {|| .T. }
oCBox2:bWhen := {|| .T. }
oCBox3:bWhen := {|| .T. }
oCBox4:bWhen := {|| .T. }
oCBox5:bWhen := {|| .T. }
oCBox6:bWhen := {|| .T. }

oDlg2:Activate(,,,.T.)                     

If lOk .And. (lCheck1 .or. lCheck2 .or. lCheck3 .or. lCheck4 .or. lCheck5 .or. lCheck6)
	If lCheck1
		cMsg += IIF(nOpcBS==1,"Início","Conclusão")+" da atualização do servidor "+"10.0.30.2"+CHR(13)+CHR(10)
	EndIf
	If lCheck2
		cMsg += IIF(nOpcBS==1,"Início","Conclusão")+" da atualização do servidor "+"10.0.30.3"+CHR(13)+CHR(10)
	EndIf
	If lCheck3                                       
		cMsg += IIF(nOpcBS==1,"Início","Conclusão")+" da atualização do servidor "+"10.0.30.4"+CHR(13)+CHR(10)
	EndIf
	If lCheck4
		cMsg += IIF(nOpcBS==1,"Início","Conclusão")+" da atualização do servidor "+"10.0.30.5"+CHR(13)+CHR(10)
	EndIf
	If lCheck5
		cMsg += IIF(nOpcBS==1,"Início","Conclusão")+" da atualização do servidor "+"10.0.30.20"+CHR(13)+CHR(10)
	EndIf
	If lCheck6                                       
		cMsg += IIF(nOpcBS==1,"Início","Conclusão")+" da atualização do servidor "+"10.0.30.22"+CHR(13)+CHR(10)
	EndIf                                                                       
	
	If !EMPTY(cMsg)
		cMsg +=	CHR(13)+CHR(10)+"Responsavel Atualização: "+AllTrim(cUserName)+CHR(13)+CHR(10)
		cMsg +=" Email:"+ALLTRIM(UsrRetMail(cCodUsr))+CHR(13)+CHR(10)                       
		Z03->(DbSetOrder(2))
		If Z03->(DbSeek(xFilial("Z03")+cCodUsr)) .and. !EMPTY(Z03->Z03_TEL)
	   		cMsg +=" Telefone: "+Z03->Z03_TEL+CHR(13)+CHR(10) 
		EndIf
		SendMail(cMsg)
	Else
		MsgInfo("Sem conteudo para envio de email","Grant Thornton Brasil.")
	EndIf
Else
	ALERT("Email não enviado!")
EndIf

Return .T.

/*
Funcao      : SendMail
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Enviar Conclusão de Atividade Brastorage
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------------*
Static Function SendMail(cMsg)
*----------------------------*
oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@br.gt.com"
oEmail:cTo		:= PADR("log.sistemas@br.gt.com,operacao@brastorage.com.br,luis.santos@brastorage.com.br,"+ALLTRIM(UsrRetMail(RetCodUsr())),200)
oEmail:cSubject	:= padr("GT - Atualizacao noturna",200)
oEmail:cBody   	:= cMsg
oEmail:Envia()

Return .T.     

/*                                                                    
Funcao      : HDC010F
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Finalizar atividade.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-------------------------------------*
USer Function HDC010F(cAlias,nReg,nOpc) 
*-------------------------------------*            
Local lOk := .F.
Local lCheck2 := lCheck3 := .F.
Local lCheck1 := .T.

Private cMGetNew := ""

(cAlias)->(DbGoTo(nReg))              

oDlg3      := MSDialog():New( 127,279,486,649,"Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,028,{||"Finalização de Atendimento."},oDlg3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,084,008)
oSay2      := TSay():New( 080,004,{||"Cometario:"},oDlg3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSBtn1     := SButton():New( 004,148,1,{|| (lOk := .T., oDlg3:end())},oDlg3,,"", )
oCBox1     := TCheckBox():New( 032,004,"Concluida com sucesso.",,oDlg3,156,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox2     := TCheckBox():New( 044,004,"Finalizado c/ Erro, Reabertura do Atendimento.",,oDlg3,156,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox3     := TCheckBox():New( 056,004,"Finalizado c/ Erro, Encerrar o atendimento.",,oDlg3,156,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oMGetNew := TMultiGet():New(092,004,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oDlg3,168,075,,.F.,,,,.T.,,,,,,)
oMGetNew:EnableVScroll(.T.)

oCBox1:bLClicked := {|| (lCheck1:=lCheck2:=lCheck3:=.F.,lCheck1:=.T.) }
oCBox2:bLClicked := {|| (lCheck1:=lCheck2:=lCheck3:=.F.,lCheck2:=.T.) }
oCBox3:bLClicked := {|| (lCheck1:=lCheck2:=lCheck3:=.F.,lCheck3:=.T.) }

oCBox1:bSetGet := {|| lCheck1 }
oCBox2:bSetGet := {|| lCheck2 }
oCBox3:bSetGet := {|| lCheck3 }

oCBox1:bWhen := {|| .T. }
oCBox2:bWhen := {|| .T. }
oCBox3:bWhen := {|| .T. }

oDlg3:Activate(,,,.T.)

If lOk .and. (lCheck1 .or. lCheck2 .or. lCheck3)
	cHist := ""
	If lCheck1 .or. lCheck3
		cStatus := "2"
		cHist := "Finalizado:"

		(cAlias)->(RecLock(cAlias,.F.))	
		(cAlias)->Z12_USERAT := cUserName
		(cAlias)->Z12_DTAT   := dDataBase
		(cAlias)->Z12_HRAT   := LEFT(STRTRAN(Time(),":",""),4)
		(cAlias)->(MsUnlock()) 

	ElseIf lCheck2             
		cStatus := "1"
		cHist := "Reaberto:"

	EndIf

	cHist += cUserName+" Data/hora:"+DtoC(dDataBase)+"-"+Time()+CHR(13)+CHR(10)

	If !EMPTY(cMGetNew)
		cHist += "Comentarios: "+CHR(13)+CHR(10)
		cHist += cMGetNew+CHR(13)+CHR(10)
	EndIf

	(cAlias)->(RecLock(cAlias,.F.))	
	(cAlias)->Z12_STATUS := cStatus
	(cAlias)->Z12_HIST   := ALLTRIM((cAlias)->Z12_HIST)+cHist
	(cAlias)->(MsUnlock())  
	 
	//Envio de Email de Finalizado ao solicitante
	cTo	:= ""
	cMsg := ""
	cMsg += "Atualização:"+ALLTRIM(Z12->Z12_CODIGO)+CHR(13)+CHR(10)
	cMsg += "Finalizado por:"+ALLTRIM(cUserName)+CHR(13)+CHR(10)
	cMsg += CHR(13)+CHR(10)
	cMsg += "Historico: "+CHR(13)+CHR(10)
	cMsg += (cAlias)->Z12_HIST
	
	oEmail          := DEmail():New()
	oEmail:cFrom   	:= "totvs@br.gt.com"
	Z03->(DbSetOrder(1))
	Z03->(DbGoTop())
	While Z03->(!EOF())
		If ALLTRIM(Z03->Z03_ATIVO) == "S"
			If UPPER(ALLTRIM(Z03->Z03_NOME)) == UPPER(ALLTRIM(Z12->Z12_USER))
				cTo		+= ALLTRIM(UsrRetMail(Z03->Z03_ID_PSS ))+";"
			EndIf
			If UPPER(ALLTRIM(Z03->Z03_TIPO)) $ "L|M"
				cTo		+= ALLTRIM(UsrRetMail(Z03->Z03_ID_PSS ))+";"
			EndIf
		EndIf
		Z03->(DbSkip())
	EndDo    
	If !EMPTY(cTo) 
	 	oEmail:cTo	:= PADR(ALLTRIM(cTo),200)
	  	oEmail:cSubject	:= padr("FINALIZADO - Atualizacao noturna - '"+Z12->Z12_CODIGO+"'",200)
		oEmail:cBody   	:= cMsg
		oEmail:Envia()
	Else
		MsgInfo("Falha no Envio de Email - Destinatario nao encontrado!","Grant Thornton Brasil.")
	EndIf

Else
	MsgInfo("Operação Abortada!","Grant Thornton Brasil.")
EndIf

Return .T.