#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "ap5mail.ch"
#Include "rwmake.ch"          
#Include "colors.ch"   
#Include "pryor.ch"   


/*
Funcao      : EGAGPE01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exportacao de dados    
Autor     	: Wederson L. Santana 
Data     	: 27/01/06 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Gestão Pessoal.
*/

*------------------------*
 User Function EGAGPE01()  
*------------------------*
                                               
If cEmpAnt $ "GA"
   Private cBuffer,nHd13,nBtLidos,nHdl3,aLog,cEol,_cCombo,_dData,_cPara,_cCopia,nHdlChk,_cSendArq,_aArquivo,_cLog
   _cData    := Space(06)
   _cPara    := Space(50)
   _cCopia   := Space(50)
   DbSelectArea("SX6")
   If! DbSeek("  MV_EGAMAIL")
	    RecLock("SX6",.T.)
	    Replace X6_VAR		 With "MV_EGAMAIL"
	    Replace X6_TIPO	    With "C"
	    Replace X6_DESCRIC   With "Especifico Ball Van Zanten" 
	    Replace X6_CONTEUD   With "wederson.lourenco@pryor.com.br"
	    Replace X6_PROPRI	 With "U"
	    MsUnLock()
	Else
	    _cPara:= X6_CONTEUD
   Endif
   
   @ 000,001 To 200,420 Dialog oLeTxt Title "Exportação dados - Ball Van Zanten do Brasil"
   @ 001,002 To 099,209 
   @ 010,005 Say "Envia arquivo com os lancamentos contabeis da folha." COLOR CLR_HRED, CLR_WHITE 
   @ 025,005 Say "Para " COLOR CLR_HRED, CLR_WHITE 
   @ 025,030 Get _cPara Size 100,100 Valid NaoVazio()   
   @ 035,005 Say "Copia " 
   @ 035,030 Get _cCopia Size 100,100    
   @ 055,005 Say "Informe a data abaixo."  COLOR CLR_HBLUE, CLR_WHITE 
   @ 065,005 Say "Data (AAAAMM)" COLOR CLR_HBLUE, CLR_WHITE 
   @ 065,050 Get _cData Size 40,40  
   @ 080,128 BmpButton Type 01 Action fOkOpc()
   @ 080,158 BmpButton Type 02 Action Close(oLeTxt)

   Activate Dialog oLeTxt Centered
Else
    MsgInfo("Especifico Ball Van Zanten .","A T E N C A O")
Endif
Return

//-------------------------------------------------------

Static Function fOkOpc()
Close(oLeTxt)
_cSendArq :=""
_aArquivo :={}        

DbSelectArea("SX6")
If DbSeek("  MV_EGAMAIL")
   RecLock("SX6",.F.)
   Replace X6_CONTEUD   With _cPara
   MsUnLock()
Endif

Processa({|| fOkProc()},"Gerando arquivo - Folha")

If Len(_cSendArq)>0
   fSendArq()
Endif   
For i:=1 To Len(_aArquivo)
    FErase(_aArquivo[i][1])
Next     
Return

//-------------------------------------------------------

Static Function fOkProc()
fGerProc()
DbSelectArea("SQL")
If RecCount()> 0

   _cArquivo:="\SIGAADV\"+Dtos(dDataBase)

   fGeraTxt(_cArquivo)
   
   DbSelectArea("SQL")
   DbGotop()
   ProcRegua(RecCount())             
   nReg   :=1
   Do While.Not.Eof()
	        IncProc()
	        _cCusto := If(AllTrim(I2_DC)$"D" ,I2_CCD,If(AllTrim(I2_LP)$ "C",I2_CCC,Space(09)))
	        If AllTrim(I2_DC) $ "X".And.I2_CCD # I2_CCC 
              cLinha := VERBA+;                                                                       //Verba
                        I2_LP+" "+;                                                                   //Lp
                        SubStr(I2_DATA,7,2)+"/"+SubStr(I2_DATA,5,2)+"/"+SubStr(I2_DATA,1,4)+" "+;     //Data da contabilização
                        I2_CCD+" "+;                                                                  //Centro de custo
                        StrZero((I2_VALOR*100),18)+;                                                  //Valor
                        I2_HIST+Chr(13)+Chr(10)                                                       //Histórico + final do arquivo        
                     
	                     FWrite(nHdlChk,cLinha,Len(cLinha))                                            

              cLinha := VERBA+;                                                                       //Verba
                        I2_LP+" "+;                                                                   //Lp
                        SubStr(I2_DATA,7,2)+"/"+SubStr(I2_DATA,5,2)+"/"+SubStr(I2_DATA,1,4)+" "+;     //Data da contabilização
                        I2_CCC+" "+;                                                                  //Centro de custo
                        StrZero((I2_VALOR*100),18)+;                                                  //Valor
                        I2_HIST+Chr(13)+Chr(10)                                                       //Histórico + final do arquivo        
                     
	                     FWrite(nHdlChk,cLinha,Len(cLinha))
	        Else
               cLinha := VERBA+;                                                                       //Verba
                         I2_LP+" "+;                                                                   //Lp
                         SubStr(I2_DATA,7,2)+"/"+SubStr(I2_DATA,5,2)+"/"+SubStr(I2_DATA,1,4)+" "+;     //Data da contabilização
                         _cCusto+" "+;                                                                 //Centro de custo
                         StrZero((I2_VALOR*100),18)+;                                                  //Valor
                         I2_HIST+Chr(13)+Chr(10)                                                       //Histórico + final do arquivo        
                     
                         FWrite(nHdlChk,cLinha,Len(cLinha))
	        EndIf
	        nReg ++
	        DbSkip()
   EndDo	   
   FClose(nHdlChk)
   _cSendArq +=_cArquivo
   AADD(_aArquivo,{_cArquivo}) 
Else
    MsgInfo("Nao existem dados para serem enviados.","A T E N C A O")   
Endif   
Return

//-------------------------------------------------

Static Function fGeraTxt(_cLocalArq)
	nHdlChk	:=	MsFCreate(AllTrim(_cLocalArq))
	If nHdlChk < 0      
	   MsgInfo("Arquivo nao pode ser criado em "+AllTrim(_cLocalArq),"A T E N C A O")
		Break
	EndIf
Return

//-------------------------------------------------------

Static Function fSendArq()  
Local CrLf		:= Chr(13)+Chr(10)
Local cMsg		:= ""
Local lOk      := .F.

cMsg :=""
cMsg += '<html>'+CrLf
cMsg += '<font size="4" face="Arial">Ball Van Zanten </font>'+CrLf+CrLf                  
cMsg += '<font size="2" face="Arial">Informações geradas por :</font>' +CrLf   
cMsg += '<font size="2" face="Arial">Usuario '+__cUserId+' - '+SubStr(cUsuario,7,15)+'</font>'+CrLf
cMsg += '<font size="2" face="Arial">Em '+Substr(Dtos(dDataBase),7,2)+'/'+Substr(Dtos(dDataBase),5,2)+'/'+Substr(Dtos(dDataBase),1,4)+' às '+Time()+'</font>' +CrLf+CrLf 
cMsg += '<font size="2" face="Arial">E-mail do sistema por favor nao responda.</font>' +CrLf   
cMsg +=CrLf+CrLf
cMsg += '<font size="4" face="Arial"> Pryor Technology </font>' +CrLf
cMsg += '</body>'+CrLf
cMsg += '</html>'+CrLf        

Connect Smtp Server WedConnect Account GetMv('MV_RELACNT') PassWord GetMv('MV_RELPSW') Result lConectou

If lConectou
   Send Mail ;     	
   From GetMv('MV_RELACNT');
   To _cPara;
   CC _cCopia;
   Subject 'Ball Van Zanten - Exportação dados ' ;
   Body cMsg ;    
   Attachment _cSendArq;    
   Result lEnviado    
   If lEnviado
      MsgInfo("Email enviado com sucesso."," A T E N C A O ")
   Else 
      MsgInfo("Nao foi possivel enviar o email ."+CrLf+"E-mail "+AllTrim(_cPara)+" "+AllTrim(_cCopia)+CrLf+AllTrim(MailGetErr()),"A T E N C A O")
   EndIf
   Disconnect Smtp Server
Else
   MsgInfo("Nao foi possivel conexao com o servidor ."+CrLf+WedConnect,"A T E N C A O")
EndIf

Return                                 
       
//-------------------------------------------------------

Static Function fGerProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT SUBSTRING(I2_ORIGEM,1,3)AS VERBA,I2_DC,I2_LP,I2_DATA,I2_DEBITO,I2_CREDITO,I2_CCD,I2_CCC,I2_VALOR,I2_HIST " 
cQuery += "FROM "+RetSqlName("SI2")+" WHERE "+Chr(10)
cQuery += "I2_FILIAL = '"+xFilial("SI2")+"'"+Chr(10)
//cQuery += "AND I2_LOTE = '4400' "+Chr(10)
cQuery += "AND I2_PERIODO ='"+_cData+"'"+Chr(10)
cQuery += "AND D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY I2_DATA,I2_NUM"
   
TCQuery cQuery ALIAS "SQL" NEW

cTmp := CriaTrab(NIL,.F.)
Copy To &cTmp
dbCloseArea()
dbUseArea(.T.,,cTmp,"SQL",.T.)

Return
