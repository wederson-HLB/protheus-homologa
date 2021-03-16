#include "Protheus.ch"    
#INCLUDE "AP5MAIL.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  MA080VLD     ∫Autor  Adriane Sayuri Kamiya ∫ Data ≥ 08/13/10 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Ponto de entrada na gravaÁ„o da TES                        ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
*----------------------*
User Function MA080VLD() 
*----------------------*
Local i := 0

Local lRet        := .T.    
Local cAlterou    := ''                             
Local lAlterouTES := .F.
Local nOrderSX3   := SX3->(IndexOrd())
Local cNomeCampo  := ''
Local cCpoSF4     := ''
Local cCpoMem     := ''
Local cCompName   := ComputerName()  
Local dData       := date()
Local cHora       := Time()
Local cAmbiente   := UPPER(GetEnvServer())
Local cTitulo     := "Grant Thonrton" 
Local cQry		  := ""
Local nConP1200	  := 0
Local aArea		  := {}

Private cServer:= GetMV("MV_RELSERV")
Private cEmail := GetMV("MV_RELACNT")
Private cPass  := GetMV("MV_RELPSW")
Private lAuth  := GetMv("MV_RELAUTH")  

//CAS - 21/02/2017 chamado 039087 - Removido o e-mail kareane.nascimento@hlb.com.br. Inclu˙Åo os e-mails priscila.santos/monalisa.martins/mariana.rodrigues
Private cDe      := AllTrim(SuperGetMv("MV_RELFROM",.F., ""))//Email de origem
Private cPara    := padr(	'carla.oliveira@hlb.com.br'+;
							',diogo.braga@hlb.com.br'+;
							',renata.melloni@hlb.com.br'+;
							',edimilso.junior@hlb.com.br'+;  
							',priscila.santos@hlb.com.br'+;  
							',monalisa.martins@hlb.com.br'+;  
							',mariana.rodrigues@hlb.com.br',200)
Private cCc      := padr('',200)
Private cAssunto := padr('',200)
Private cMsg     := ""
Private cErro    := ""


//RRP - 06/04/2018 - ValidaÁ„o se estÅEno ambiente produÁ„o ou homologaÁ„o
aArea := GetArea()  
nConP1200 := TcLink( "MSSQL7/P12117_00","10.0.30.56",7891 )
If nConP1200 # 0

	cQry :=" SELECT Z06_AMB FROM P12_00..Z06YY0 WHERE Z06_AMB LIKE '"+Left(cAmbiente,6)+"%' AND Z06_PROD = 'S' AND Z06_TES = 'S' "
	
	If TCSQLExec(cQry)<0
		MsgInfo("Ocorreu um problema na busca das informaÁıes no Amb. Adm P12_00!Favor abrir um chamado!","HLB BRASIL")
		Return
	EndIf

	If select("TRBPRO")>0
		TRBPRO->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBPRO",.T.,.T.)

	Count to nRecCount

	//Encerra a conex„o
	TCunLink(nConP1200)	

	If nRecCount > 0

	aArea := RestArea(aArea)

		cMsg :=  " <body style='background-color: #9370db'>"        
		cMsg += ' <table height="361" width="844" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0">'
		cMsg += ' <tr>  '
		cMsg += ' <td colspan="4">'
		cMsg += ' Boa tarde!<br><br> '
		cMsg += ' </td>'
		 
		cMsg += ' <tr>'
		cMsg += " <td colspan='4'>A TES <em>"+M->F4_CODIGO+"</em> foi alterada pelo usu·rio <em>"+cUserName+"</em> na m·quina <em> "+cCompName+"</em> no dia <em>"+dtoc(dData)+"</em> ‡s <em>"+cHora+"</em> hrs.  "
		cMsg += " </td> "
		cMsg += ' </tr>'
		       
		cMsg += ' <tr>'
		cMsg += " <td colspan='4'> "+SPACE(20)
		cMsg += " </td> "
		cMsg += ' </tr>'
		                                
		cMsg += ' <tr>'
		cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Campo </b></font></td> '
		cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>  Conte˙do Anterior </b></font></td>'
		cMsg += ' <td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b> Alterado Para </b></font></td> '
		cMsg += ' <td width="10" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"><b>   </b></font></td>' 
		cMsg += ' </tr>'

  
		SX3->(DbSetOrder(2))
		SF4->(DbSeek(xFilial("SF4")+M->F4_CODIGO))
		FOR i := 1 TO FCount()
			cCampo := FIELDNAME(I)       
			cAssunto :="AlteraÁ„o da TES  "+M->F4_CODIGO+  "  no Ambiente "+ Upper(cAmbiente) + " - Empresa : " + SM0->M0_NOME
			If SF4->(FieldPos(cCampo)) # 0
				If SF4->&(cCampo) <>  M->&(cCampo)
					lAlterouTES := .T.     
					SX3->(DbSeek(Alltrim(cCampo)))
					cNomeCampo:= SX3->X3_TITULO 
					cMsg += '<tr>'
					cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">'+cNomeCampo+'</td>'
					If SX3->X3_TIPO = 'N'
						cCpoSF4 := Alltrim(Str(SF4->&(cCampo)))
						cCpoMem := Alltrim(Str(M->&(cCampo)))
					ElseIf SX3->X3_TIPO = 'D' //ER - 02/02/2012
						cCpoSF4 := Alltrim(DtoC(SF4->&(cCampo)))
						cCpoMem := Alltrim(DtoC(M->&(cCampo)))
					Else
						If SX3->X3_TAMANHO = 1  
							If Empty(SF4->&(cCampo))
								cCpoSF4:= ""
							Else
								nPosIni := AT(SF4->&(cCampo),SX3->X3_CBOX)+2 
								If AT(';',Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))) = 0
									nPosFim := len(Alltrim(Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))))
									cCpoSF4 := Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))
								Else
									nPosFim := nPosIni+AT(';',Alltrim(Substr(SX3->X3_CBOX,nPosIni,Len(SX3->X3_CBOX))))-1
									cCpoSF4 := Substr(SX3->X3_CBOX,nPosIni,nPosFim-nPosIni)
								EndIf
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
							cCpoSF4 := SF4->&(cCampo)
							cCpoMem := M->&(cCampo)
						EndIf
					EndIF 
              
					cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">' + cCpoSF4 + '</td>'
					cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3">' + cCpoMem + '</td>'
					cMsg += '<td width="80" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "center"><font face="times" color="black" size="3"> </td>'
					cMsg += '</tr>'   
				EndIf
			EndIf
		End                                                                                       
   
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
		
		cMsg     += '</Table><BR?>' +CRLF                                                   

		If Empty(cServer) .And. Empty(cEmail) .And. Empty(cPass)
			MsgAlert("N„o foram definidos os par‚metros do server do Protheus para envio de e-mail",cTitulo)
			Return
		Endif    

		If lAlterouTES
			IF ValidaEmail()
				Eval({||EnviaEmail()})
			EndIf
		EndIf
	EndIf
EndIf
 
SX3->(DbSetOrder(nOrderSX3))   
Return .T.          

*---------------------------*
STATIC FUNCTION ValidaEmail()   
*---------------------------*
Local lRet := .T.

If Empty(cDe)
   MsgInfo("Campo 'De' preenchimento obrigatÛrio",cTitulo)
   lRet:=.F.
Endif
If Empty(cPara) .And. lRet
   MsgInfo("Campo 'Para' preenchimento obrigatÛrio",cTitulo)
   lRet:=.F.
Endif
If Empty(cAssunto) .And. lRet
   MsgInfo("Campo 'Assunto' preenchimento obrigatÛrio",cTitulo)
   lRet:=.F.
Endif

If lRet
   cDe      := AllTrim(cDe)
   cPara    := AllTrim(cPara)
   cCC      := AllTrim(cCC)
   cAssunto := AllTrim(cAssunto)
Endif

RETURN(lRet)

*--------------------------*
STATIC FUNCTION EnviaEmail()
*--------------------------*
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
   MsgAlert("Falha na conex„o "+cError)
   Return(.F.)
Endif

SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg  RESULT lResulSend   

GET MAIL ERROR cError
If !lResulSend
	MsgAlert("Falha no Envio do e-mail " + cError)
Endif

DISCONNECT SMTP SERVER                         

Return .T.