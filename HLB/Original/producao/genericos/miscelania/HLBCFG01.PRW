#Include "Protheus.ch"                      
#Include "FWBROWSE.CH"
#INCLUDE "TBICONN.CH" 

User Function HLBCFG01()
Local lJob 	:= (Select("SX3") <= 0)

If lJob 
	
	RpcClearEnv()
	RpcSetType( 3 )

	PREPARE ENVIRONMENT EMPRESA "50" FILIAL "01" TABLES "CT2" MODULO "CTB"
	
    conout("Fonte HLBCFG01: preparou AMBIENTE ")

    fSendMail()

    //Encerra o PREPARE ENVIRONMENT
    RpcClearEnv()

Else

	If ( !cEmpAnt $ '50' )
		MsgInfo( 'Empresa nao autorizada para utilizar essa rotina!',"HLB BRASIL" )
	EndIf

   fSendMail()

EndIf

Return

//----------------------------------------------------------------------

Static Function fSendMail()
*---------------------------------------------------------------------*
Local cAssunto    := ""
Local cTexto      := ""
Local cQry        := ""
Local cDataIni    := SubStr(Dtos(MonthSub(dDataBase,1)),1,6)+"01"
Local cServer     := AllTrim(GetNewPar("MV_RELSERV",""))
Local cAccount    := AllTrim(GetNewPar("MV_RELACNT",""))
Local cTo         := SuperGetMV("MV_XEMAILT", .F.,"vitor.oliveira@ez4.com.br")
Local cPassword   := AllTrim(GetNewPar("MV_RELPSW"," "))         
Local lAutentica  := GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
Local cUserAut    := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
Local cPassAut    := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
Local cFrom       := AllTrim(GetNewPar("MV_RELFROM",""))
Local cTime       := Time()
Local nTot        := 0
Local nAtv        := 0
Local nDel        := 0
Local cDirMail		:= "\anexoemail\"
Local cNomArq     := "Logct2.CSV"
Local cLinha      := ""
Local nHdlChk
Local cAttachment := cDirMail+cNomArq
Local cEOL := CHR(13)+CHR(10)   
Local cCopia      := SuperGetMV("MV_XEMAILC", .F.,"dunalva.santos@hlb.com.br;wederson.santana.ext@hlb.com.br")

MakeDir(cDirMail)

conout("Fonte HLBCFG01: Leitura dados. "+Dtos(dDataBase))

If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry:="SELECT CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE,D_E_L_E_T_ AS DEL,COUNT(*) AS REG FROM "+RetSqlName("CT2")+" "
cQry+="WHERE CT2_DATA >= '"+cDataIni+"' " 
cQry+="AND CT2_DATA <= '"+Dtos(dDataBase)+"' "
cQry+="GROUP BY CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE,D_E_L_E_T_ "
cQry+="ORDER BY CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE"
                    
dbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

nHdlChk:=MsFCreate(cDirMail+cNomArq)

If nHdlChk > 0

   cLinha:= "Data Geracao;Hora Geracao;Data Contabil;Lote;Documento;Sub Lote;Deletados;Quantidade"+cEol
   FWrite(nHdlChk,cLinha,Len(cLinha))

   dbSelectArea("QRYTEMP")
   While !Eof()

         If Empty(QRYTEMP->DEL)
            nAtv ++
         Else
            nDel ++
         EndIf

         cLinha:=Dtos(dDataBase)+";"+cTime+";"+QRYTEMP->CT2_DATA+";"+QRYTEMP->CT2_LOTE+";"+QRYTEMP->CT2_DOC+";"+QRYTEMP->CT2_SBLOTE+";"+QRYTEMP->DEL+";"+Str(QRYTEMP->REG)+cEol

         FWrite(nHdlChk,cLinha,Len(cLinha))

         nTot ++
         dbSkip()
   End
   FClose(nHdlChk) 
EndIf

cAssunto := "CT2 - Log registros deletados em "+Dtoc(dDataBase)+" às "+cTime+"."

cTexto := ' <table class="MsoNormalTable" style="WIDTH: 450pt" cellspacing="0" cellpadding="0" width="600" border="0">
cTexto += ' <tbody>
cTexto += ' <tr>
cTexto += ' <td style="PADDING-BOTTOM: 15pt; PADDING-TOP: 15pt; PADDING-LEFT: 15pt; PADDING-RIGHT: 15pt" valign="top">
cTexto += ' <div style="MARGIN-BOTTOM: 5pt; MARGIN-TOP: 5pt">
cTexto += ' <p class="MsoNormal" style="mso-margin-top-alt: auto; mso-margin-bottom-alt: auto"><span style="font-family: Georgia, serif;"><span style="color: rgb(153, 0, 153); font-size: 30pt;"></span><font color="#990099" style="font-size: 30pt;">Monitoramento dos registros da tabela CT2 do contabil.</font><br><font size="5">Periodo: '+SubStr(cDataIni,7,2)+'/'+SubStr(cDataIni,5,2)+'/'+SubStr(cDataIni,1,4)+' ate '+Dtoc(dDataBase)+'  Empresa: '+cEmpAnt+' Ambiente: P12_14</font></span></p>
cTexto += ' <div class="MsoNormal" style="TEXT-ALIGN: center; mso-margin-top-alt: auto; mso-margin-bottom-alt: auto" align="center">
cTexto += ' <hr style="COLOR: black" align="center" size="1" width="100%" noshade="">
cTexto += ' </div></div>
cTexto += ' <p class="MsoNormal" style="mso-margin-top-alt: auto; mso-margin-bottom-alt: auto"></p>
cTexto += ' <p class="margin"><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif; COLOR: black"><br></span></b></p><p class="margin"><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif; COLOR: black">Total registros: '+StrZero(nTot,6)+'   Ativos: '+StrZero(nAtv,6)+'   Deletados: '+StrZero(nDel,6)+'</span></b><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif">.</span></b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif"></span></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">Relatorio analitico em anexo.&nbsp;</span></font></p><font face="Calibri, sans-serif"><span style="font-size: 11pt;"><strong></strong></span></font>
cTexto += ' <p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"></p><p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><br></p>
cTexto += ' <p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><b><span style="FONT-SIZE: 9pt; COLOR: black">&nbsp;</span></b></p>
cTexto += ' <p class="MsoNormal"><font face="Arial, sans-serif" size="2" color="#ff0000"><b>E-mail informativo enviado automaticamente.</b></font></p><p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><b style="font-size: 14.6667px;"><span style="font-size: 6.5pt; font-family: Arial, sans-serif; color: rgb(116, 118, 120);"><br></span></b></p><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif">
cTexto += ' <p class="MsoNormal"><b><span style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">©2020 HLB BRASIL -&nbsp; Todos os direitos reservados</span></b></p>
cTexto += ' <p class="MsoNormal"><b><span style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678"><a href="http://www.HLB.com.br/" target="_blank"><span lang="EN-US">www.HLB.com.br</span></a></span></b><b><span lang="EN-US" style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678"><br></span></b><b><span lang="EN-GB" style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">Member of HLB BRASIL International Ltd</span></b><b><span lang="EN-US" style="FONT-SIZE: 8pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">.</span></b><span lang="EN-US"></span></p></span>
cTexto += ' </td>
cTexto += ' </tr>
cTexto += ' </tbody>
cTexto += ' </table>

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

   SEND MAIL FROM cFrom TO cTo BCC cCopia SUBJECT cAssunto BODY EncodeUTF8(cTexto) ATTACHMENT cAttachment RESULT lOK

   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   Else
      ConOut("E-Mail enviado para: "+ALLTRIM(cTo))
      Ferase(cDirMail+cNomArq)
   ENDIF

ENDIF

DISCONNECT SMTP SERVER
	
Return

