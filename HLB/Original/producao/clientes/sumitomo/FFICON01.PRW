#Include "tbiconn.ch"
#Include "ap5mail.ch"
#Include "rwmake.ch"          
#Include "colors.ch"   
#Include "pryor.ch"  

/*
Funcao      : FFICON01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importação lançamentos contábeis folha
Autor     	: Wederson L. Santana 	
Data     	: 20/12/2005
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Financeiro.
*/
 
*-------------------------* 
 User Function FFICON01()   
*-------------------------*  

Private oLeTxt,cArquivo,cType,nHdl3,nTamlin,nTamFile,cBuffer,nBtLidos,cEol

@ 200,001 To 380,420 Dialog oLeTxt Title "Importação dados contabeis"
@ 001,002 To 089,209 
@ 010,080 Say "S U M I T O M O " COLOR CLR_HRED, CLR_WHITE 
@ 030,030 Say "Importacao dos lancamentos contabeis - folha de pagamento."
@ 055,005 Say "Local " COLOR CLR_HBLUE, CLR_WHITE 
@ 055,020 Get cArquivo Size 180,180                         
@ 070,098 BmpButton Type 14 Action fBuscaArq()
@ 070,128 BmpButton Type 01 Action Processa ({||fOkProc()},"Importacao dados contabeis")  
@ 070,158 BmpButton Type 02 Action Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return

//------------------------------------------------------

Static Function fBuscaArq()
	cType := "Arq.   | *.TXT"
	cArquivo := cGetFile(cType, OemToAnsi("Selecione arquivo "+Subs(cType,1,6)))
Return(NIL)

//------------------------------------------------------

Static Function fOkProc()                        

Close(oLeTxt)

If dDataBase >= GetMv("MV_DATADE").And.dDataBase <=GetMv("MV_DATAATE")

   cEol   :="Chr(13)+Chr(10)"
   cEol   :=Trim(cEol)
   cEOl   :=&cEol
   nHdl3  := fOpen(cArquivo)

   If nHdl3 == -1
      MsgAlert("O arquivo  "+Alltrim(cArquivo)+" nao pode ser aberto!","A t e n c a o !")
	   Return(-1)
   Endif

   aLog     :={}
   nTamLin  := 88+Len(cEol)
   nTamFile := fSeek(nHdl3,0,2)
   fSeek(nHdl3,0,0)
   cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura
   nBtLidos := fRead(nHdl3,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto
   nLinReg  := 1 
   ProcRegua(RecCount(nTamFile/nTamLin))
   While nBtLidos >= nTamLin 
         IncProc(nLinReg)
         cDc     := SubStr(cBuffer,01,01)
         cCusto  := SubStr(cBuffer,02,05)
         cContaD := StrTran(SubStr(cBuffer,07,14),".","")
         cContaC := StrTran(SubStr(cBuffer,21,14),".","")
         nValorD := Val(SubStr(cBuffer,35,09))*100
         nValorC := Val(SubStr(cBuffer,45,09))*100     
         cDocume := SubStr(cBuffer,55,04)
         cHistor := SubStr(cBuffer,59,30)

         DbSelectArea("SI1")
         DbSetOrder(1)            
         If cDc$"X" 
            If DbSeek(xFilial("SI1")+cContaD)
               If DbSeek(xFilial("SI1")+cContaC)
                  SI3->(DbSetOrder(1))
                  If SI3->(DbSeek(xFilial("SI3")+cCusto))
                     If (nValorD+nValorC) > 0 .And. nValorD == nValorc
                        fOkGrava(nValorD,cDc,cCusto,cContaD,cContaC,cDocume,cHistor,nLinReg)
                     Else
                        AADD(aLog,{"Valor Debito/Credito nao batem",TransForm(nValorD,"@E 999,999,999.99"),TransForm(nValorC,"@E 999,999,999.99"),TransForm(nLinReg,"@E 9999")})                                       
                     Endif   
                  Else
                     AADD(aLog,{"CCusto nao cadastrado","",cCusto,TransForm(nLinReg,"@E 9999")})                                                                                  
                  Endif
               Else
                   AADD(aLog,{"Conta Credito nao cadastrada","",cContaC,TransForm(nLinReg,"@E 9999")})                                       
               EnDif
            Else 
                AADD(aLog,{"Conta Debito nao cadastrada","",cContaD,TransForm(nLinReg,"@E 9999")})                                       
            Endif
         Else
             cChave := If(AllTrim(cDc)$"D",cContaD,cContaC)
             nValor := If(AllTrim(cDc)$"D",nValorD,nValorC)
             If DbSeek(xFilial("SI1")+cChave)
                SI3->(DbSetOrder(1))
                If SI3->(DbSeek(xFilial("SI3")+cCusto))
                   If nValor > 0
                      fOkGrava(nValor,cDc,cCusto,cContaD,cContaC,cDocume,cHistor,nLinReg)
                   Else
                      AADD(aLog,{"Valor do lancamento zerado","",TransForm(nValor,"@E 999,999,999.99"),TransForm(nLinReg,"@E 9999")})                                          
                   Endif
                Else
                    AADD(aLog,{"CCusto nao cadastrado","",cCusto,TransForm(nLinReg,"@E 9999")})                                                                
                Endif   
             Else
                AADD(aLog,{"Conta "+If(AllTrim(cDc)$"D","Debito","Credito")+" nao cadastrada",cChave,"",TransForm(nLinReg,"@E 9999")})                                                      
             Endif
         Endif   
         nBtLidos := fRead(nHdl3,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto
         nLinReg  ++  
   EndDo        
   
   If Len(aLog)> 0
      fSendSmtp()
   Endif   
   
Else
    MsgInfo("Verifique a Data base do sistema ,"+Chr(13)+Chr(10)+;
            "data fora do periodo contabil !","A T E N C A O")
Endif   
fClose(nHdl3)		// Fecha arquivo    
Return

//-------------------------------------

Static Function fOkGrava(_nValor,_cDc,_cCusto,_cContaD,_cContaC,_cDocume,_cHistor,nLinha)
Reclock("SI2",.T.)
Replace SI2->I2_FILIAL  With xFilial("SI1")
Replace SI2->I2_NUM     With StrZero(1,10)
Replace SI2->I2_LINHA   With StrZero(nLinha,2)
Replace SI2->I2_DATA    With dDataBase
Replace SI2->I2_DC      With _cDc
Replace SI2->I2_CREDITO With _cContaC
Replace SI2->I2_DEBITO  With _cContaD
Replace SI2->I2_CCC     With If(_cDc$"C'X",_cCusto,"")
Replace SI2->I2_CCD     With If(_cDc$"D'X",_cCusto,"")
Replace SI2->I2_MOEDAS  With "SSSSS"
Replace SI2->I2_VALOR   With _nValor
Replace SI2->I2_HIST    With _cHistor    
Replace SI2->I2_LOTE    With _cDocume
Replace SI2->I2_DOC     With StrZero(1,6)
Replace SI2->I2_DTVENC  With dDataBase
Replace SI2->I2_FILORIG With xFilial("SI2")
//Replace SI2->I2_P_LOG   With ""+Dtos(dDataBase)+_cTime
MsUnlock()
Return                                                                                  

//--------------------------------------------------

Static Function fSendSmtp()  
Local CrLf		:= Chr(13)+Chr(10)
Local cMsg		:= ""
Local lOk      := .F.

aSort(aLog,,, {|x, y| x[3] < y[3]})                   

PswOrder(1)
PswSeek(__cUserId,.T.)
aUsuario:= PswRet()
cFrom   := Alltrim(aUsuario[1,14])

If Empty(cFrom)
   cFrom := fTela()
Endif

cMsg :=""
cMsg += '<html>'+CrLf
cMsg += '<font size="4" face="Arial">A t e n ç ã o !! </font>'+CrLf+CrLf
cMsg += '<font size="2" face="Arial">Usuario '+__cUserId+' - '+SubStr(cUsuario,7,15)+'</font>'+CrLf
cMsg += '<font size="2" face="Arial">'+Substr(Dtos(dDataBase),7,2)+'/'+Substr(Dtos(dDataBase),5,2)+'/'+Substr(Dtos(dDataBase),1,4)+' às '+Time()+'</font>' +CrLf+CrLf 
cMsg += '<font size="2" face="Arial">E-mail do sistema por favor nao responda.</font>' +CrLf   
cMsg += '<font size="2" face="Arial">Foram encontradas as seguintes inconsistencias.</font>' +CrLf+CrLf   
cMsg += '<font size="2" face="Arial"> Arquivo - Campo - Conteúdo - Linha do Arquivo </font>' +CrLf+CrLf
For i:=1 To Len(aLog)
    cMsg += '<font size="2" face="Arial">'+aLog[i][1]+' - '+aLog[i][2]+Space(05)+' - '+aLog[i][3]+Space(05)+' - Linha '+aLog[i][4]+'</font>' +CrLf
Next
cMsg +=CrLf+CrLf
cMsg += '<font size="2" face="Arial"> Arquivo utilizado '+cArquivo+'</font>' +CrLf+CrLf+CrLf
cMsg += '<font size="4" face="Arial"> Pryor Technology </font>' +CrLf
cMsg += '</body>'+CrLf
cMsg += '</html>'+CrLf        

Connect Smtp Server WedConnect Account GetMv('MV_RELACNT') PassWord GetMv('MV_RELPSW') Result lConectou
   
If lConectou
	Send Mail ;     	
   From GetMv('MV_RELFROM')  To cFrom ;
   CC 'wederson.lourenco@pryor.com.br';
   Subject 'S u m i t o m o - Importação dados folha' Body cMsg ;
	Result lEnviado
	If lEnviado
      MsgInfo("Foram enviadas para o seu email inconsistencias encontradas no arquivo. "," A T E N C A O ")
   Else 
      MsgInfo("Nao foi possivel enviar o email com as inconsistencias."+CrLf+"E-mail "+cFrom+CrLf+MailGetErr(),"A T E N C A O")
   EndIf
	Disconnect Smtp Server
Else
	 MsgInfo("Nao foi possivel conexao com o servidor ."+CrLf+GetMv('MV_RELSERV'),"A T E N C A O")
EndIf

Return                                 
          
//----------------------------------------------------------Tela para informação do email

Static Function fTela()
cEmail :=Space(80)

@ 200,001 To 380,320 Dialog oLeT Title "S u m i t o m o - Imp.dados Folha de Pagamento"
@ 001,002 To 089,159 
@ 007,005 Say "Informe seu endereço de E-mail " COLOR CLR_HBLUE, CLR_WHITE 
@ 015,005 Get cEmail Size 150,150    
@ 028,005 Say "As inconsistencias encontradas nos arquivos  " 
@ 035,005 Say "serao enviadas para o seu email. " 
@ 055,005 Say "Solicite ao TI para que cadastre no sistema o seu E-mail." COLOR CLR_HRED, CLR_WHITE 
@ 070,118 BmpButton Type 01 Action Close(oLeT)

Activate Dialog oLeT Centered

Return(AllTrim(cEmail))
