#INCLUDE  "protheus.ch"     
#INCLUDE  "rwmake.ch"
#INCLUDE  "colors.ch"
#INCLUDE  "tbiconn.ch"
#include  "ap5mail.ch"   
#INCLUDE  "topconn.ch"
#INCLUDE  "TbiCode.ch" 

/*
Funcao      : ATUNCM
Objetivos   : Atualização da SYD
Revisão     : Tiago Luiz Mendonça
Data/Hora   : 13/01/2010
Revisao     :
Obs.        :
*/

*-------------------------*
   User Function ATUNCM()     
*-------------------------* 

Local oDlg, oMain                   
Local lOk:=.F. 
Local ctext:=cLog:=cFil:=""  
Local cImg1:="D:\Protheus10\Rdmake\GT\LogoGT.bmp"  

Private cArquivo := "C:\"+Space(40)  
Private cTipo
Private cLog:=cNome:=cArqOrig:=""
Private aList:=aRetorno:={} 

DbSelectArea("SYD") 
DbSelectArea("SB1")

SYD->(DbSetOrder(1))   
SIX->(DbSetOrder(1))  

   Processa({|| lOk:=CheckSix() })

   If lOK
      DbOrderNickName("NCM")
   Else
      MsgStop("Indice necessário para execução não encontrado, entrar em contato com IT","Atenção") 
      Return .F.
   EndIf    

   @ 190,1 TO 380,400 DIALOG oDlg TITLE OemToAnsi("Rotina de atualização de NCM")
       
      @ 01,1 TO 097,198
      @ 13,007 Say "Selecione o arquivo com as NCM's"

      @ 11,097 Get cArquivo Size 75,10   
      oBmp4  := TBtnBmp2():New( 19,348, 26, 26, 'FOLDER11'  ,,,,{|| LoadArq()  },oDlg,'Carregar arquivo'  ,,.F.,.F. )    

      @ 023,110 BMPBUTTON TYPE 1 ACTION Processa({|| ProcTxt(),oDlg:End()},,,.T.)  
      @ 023,139 BMPBUTTON TYPE 2 ACTION Processa({|| oDlg:End()}) 

      @ 45,032 Say "Atualizar as aliquotas de cadastro de produtos"
      oBmp4  := TBtnBmp2():New( 83,033, 26, 26, 'RELOAD'    ,,,,{|| Processa({|| U_AtuSB1NCM("1")})  },oDlg ,'Atualizar Produto'  ,,.F.,.F. )     
                                                                                                                                                  
      @ 066,067 TO 088,117
      oTOleContainer := TOleContainer():New( 061,75,052,20,oDlg,.T.,cImg1)   

   Activate Dialog oDlg Centered
  
Return .F.

// Carrega o arquivo
*------------------------------*
  Static Function LoadArq()
*-----------------------------*

Local nPos

cType    := "Arq.  | *.TXT"
cArquivo := Upper(cGetFile(cType, OemToAnsi(""+Subs(cType,1,6))))

Return           

*------------------------------*
  Static Function ProcTxt()
*-----------------------------*    

Local YD_FILIAL,YD_TEC,YD_DESC_P,YD_PER_IPI,YD_PER_II
Local cPicture:="00000000"
Local cLinha,nIni,nPos,nPos1
Local nAux:=0      

Private aList :={}               
Private oDlgNCM, oLbx

  FT_FUse(cArquivo)
  FT_FGOTOP()          
     
  cLinha := FT_FReadLn()          
  
  //Valida a 1º linha do arquivo
  If !(SubStr(cLinha,01,18) == "CODNCM  SEQDESCNCM" )
     MsgStop("Arquivo inválido","Atenção")
     Return .F.
  EndIf   
   
  n:=nPosIni:=1
  If File(cArquivo)
    	
     While !FT_FEof()
	 
	 	cLinha := FT_FReadLn()
		
		IncProc("Aguarde, essa execução pode demorar ..." +Alltrim(str(N))) 
        
        If !(SubStr(cLinha,01,18) == "CODNCM  SEQDESCNCM" )
               
				   //ncm               //seq               //desc                        //ii                  //ipi 
			Aadd(aList,{substr(cLinha,1,8), substr(cLinha,9,3),Alltrim(substr(cLinha,12,255)),substr(cLinha,267,6),substr(cLinha,273,6)})

			n++
	    
	    EndIf   
	     
	       
        FT_FSkip()	                      
    	 
     EndDo 
      
  EndIf          
  

  DEFINE MSDIALOG oDlgNCM TITLE "NCM's do arquivo, clique em atualizar para que as aliquotas sejam atualizadas ou cancelar para abortar essa operação." FROM 000,000 TO 445,800 PIXEL
     
     oFont := TFont():New('Courier new',,-14,.T.)
     oTMsgBar := TMsgBar():New(oDlgNCM, ' HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
   
     oTMsgItem1 := TMsgItem():New( oTMsgBar,"Qtd: " + Alltrim(Str(Len(aList))), 100,,,,.T., {||}) 
     oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||}) 
     oTMsgItem3 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
      
     oPanel:= tPanel():New(002,002,"",oDlgNCM,,,,,RGB(99,0,124),19,208)
     
     @ 002,002 TO 310,20 LABEL "" OF oDlgNCM PIXEL 
      
      ////1.NCM,2.EX,3.DESC,4.II,5.IPI 
     @ 02,24 ListBox oLbx FIELDS HEADER "NCM","EX","DESC","II","IPI" size 375,206 of oDlgNCM Pixel
     
     oLbx:SetArray(aList)
     oLbx:bLine :={|| {aList[oLbx:nAt,1],;
                       aList[oLbx:nAt,2],;
                       aList[oLbx:nAt,3],;
                       aList[oLbx:nAt,4],;
                       aList[oLbx:nAt,5]}}
                       
     oTBtnBmp1  := TBtnBmp2():New( 14, 09, 26, 26, 'reload'   ,,,,{|| Valida("NCM"),oDlgNCM:End()},oDlgNCM,'Atualiza tabela de NCM'    ,,.F.,.F. ) 
     oTBtnBmp2  := TBtnBmp2():New( 50, 09, 26, 26, 'CANCEL'   ,,,,{|| oDlgNCM:End()},oDlgNCM,'Cancela operação'    ,,.F.,.F. )
     
  ACTIVATE MSDIALOG oDlgNCM  CENTERED
  
Return      
*-----------------------------*
  Static Function AtuNCM()
*-----------------------------*    
                 
Local nPos 

Private cTextNCM:=cTextSB1:=""
Private aRetorno      
  
aRetorno:={}

For i:=1 to Len(aList)
 
   IncProc("Aguarde, essa execução pode demorar ... " +Alltrim(str(i))) 
   
   DbSelectArea("SYD")
   SYD->(DbSetOrder(1))
   
 	//1.NCM,2.EX,3.DESC,4.II,5.IPI List          
   
   If Alltrim(aList[i][2]) == '001' // Senquencia 001, será sempre tratada como Branca.
      aList[i][2] :="   "  
   EndIf
   
   If SYD->(DbSeek(xFilial("SYD")+Alltrim(aList[i][1])+"  "+alltrim(aList[i][2])))
     
                     //Status         NCM    SEQ           Aliq Anterior / Aliq Atualizada 
      Aadd(aRetorno,{"NCM Atualizada",YD_TEC,YD_EX_NCM,YD_PER_IPI,If(alltrim(aList[i][5])=="NT" .Or. aList[i][5]==NIL .Or. Empty(aList[i][5]) ,"0",alltrim(aList[i][5])),Alltrim(aList[i][3])})
      
      RecLock("SYD",.F.)
   
      If !Empty((aList[i][4])) .And. !(aList[i][4]) $ "NT/TN/T/I/N/!/S/R" .And. (aList[i][4])<>NIL
         SYD->YD_PER_II:=Val(aList[i][4])
      Else
      	SYD->YD_PER_II:= 0
      EndIf  
      
      If !Empty((aList[i][5])) .And. !(aList[i][5]) $ "NT/TN/T/I/N/!/S/R" .And. (aList[i][5])<>NIL
      	
      	nPos:=At(",",aList[i][5])   
        If nPos > 0 
        	SYD->YD_PER_IPI:=Val(Stuff(aList[i][5],nPos,1,"."))        
        Else
        	SYD->YD_PER_IPI:=Val(aList[i][5])   
        EndIf 
	       

      Else   
      	SYD->YD_PER_IPI:=0      
      EndIf 
      
      SYD->YD_DESC_P:=Alltrim(aList[i][3])                       
      
      SYD->YD_UNID:="11"   
      SYD->YD_GRVDATA:=date()
      SYD->YD_GRVUSER:=alltrim(cUserName)
      SYD->YD_GRVHORA:=Time()      
      SYD->(MsUnlock()) 
   
      
   Else
                      //Status       NCM                     SEQ        Aliq Anterior  / Aliq Atualizada      Descr.
      	 Aadd(aRetorno,{"NCM Incluida",Alltrim(aList[i][1]),Alltrim(aList[i][2]),"",alltrim(aList[i][5]),Alltrim(aList[i][3])})  
   
       	RecLock("SYD",.T.)   
       	
   		SYD->YD_FILIAL:=xFilial("SYD")  
   		SYD->YD_TEC   :=Alltrim(aList[i][1])
   		SYD->YD_EX_NCM:=Alltrim(aList[i][2])
   		SYD->YD_DESC_P:=Alltrim(aList[i][3])     
   
      If !Empty((aList[i][4])) .And. !(aList[i][4]) $ "NT/TN/T/I/N/!/S/R" .And. (aList[i][4])<>NIL
         SYD->YD_PER_II:=Val(aList[i][4])
      EndIf  
      
      If !Empty((aList[i][5])) .And. !(aList[i][5]) $ "NT/TN/T/I/N/!/S/R" .And. (aList[i][5])<>NIL
         SYD->YD_PER_IPI:=Val(aList[i][5])
      EndIf 

       SYD->YD_UNID:="11"   
       SYD->YD_GRVDATA:=date()
       SYD->YD_GRVUSER:=alltrim(cUserName)
       SYD->YD_GRVHORA:=Time()      
       SYD->(MsUnlock()) 
       
   EndIf       
   
Next   

cArqOrig:=GeraArq("NCM")

SendEmail(cArqOrig,"NCM")   

Aviso('HLB',cTextNCM,{'Ok'},3) 

U_AtuSB1NCM("2")

Return

/*
Funcao      : AtuSB1NCM
Objetivos   : Atualização do SB1 pelo SYD
Autor       : Tiago Luiz Mendonça
Data/Hora   : 13/01/2010
Revisao     :
Obs.        :
*/
*------------------------------*
  User Function AtuSB1NCM(cTipo)
*-----------------------------*         
 
Local oDlgSB1,oLbx,oPanel,n    
Default cTipo="3" // Tipo 3 usuários 
Private lSb1Ok:=lOk :=.F.
Private cLog:=""

   If cTipo=="1" .Or. cTipo=="3"   
                                 
      DbSelectArea("SB1")
      Processa({|| lOk:=CheckSix() }) 
                
      If lOK           
         DbOrderNickName("NCM")
      Else
         MsgStop("Indice necessário para execução não encontrado, entrar em contato com IT","Atenção") 
         Return .F.
      EndIf    
   
      aRetorno:={}    
   
      Processa({|| CarregaSYD() })
  
   EndIf
     
	If !Empty(aRetorno)

	   DEFINE MSDIALOG oDlgSB1 TITLE "Atualização do produto" FROM 000,000 TO 445,800 PIXEL
	     
	      @ 02,24 ListBox oLbx FIELDS HEADER "Status","NCM","EX NCM","Aliq. Anterior IPI","Aliq.Atual IPI","Descrição" size 375,206 of oDlgSB1 Pixel
	     
	      oLbx:SetArray(aRetorno)
	      oLbx:bLine :={|| {aRetorno[oLbx:nAt,1],;
	                        aRetorno[oLbx:nAt,2],; 
	                        aRetorno[oLbx:nAt,3],;
	                        aRetorno[oLbx:nAt,4],;
	                        aRetorno[oLbx:nAt,5],;
	                        aRetorno[oLbx:nAt,6]}}                             
	     
	     oPanel:= tPanel():New(002,002,"",oDlgSB1,,,,,RGB(99,0,124),19,208)                                          
	      
	     oTBtnBmp1  := TBtnBmp2():New( 15, 09, 26, 26, 'avgarmazem',,,,{|| Valida("SB1"),oDlgSB1:Refresh()},oDlgSB1,'Atualiza produtos'    ,,.F.,.F. )   
	     oTBtnBmp2  := TBtnBmp2():New( 50, 09, 26, 26, 'BMPVISUAL'     ,,,,{|| LogAtu()}    ,oDlgSB1,'Visualizar log de atualização'    ,,.F.,.F. )                           
	     oTBtnBmp3  := TBtnBmp2():New( 85, 09, 26, 26, 'mdiexcel'  ,,,,{|| ExpExcel("NCM")}   ,oDlgSB1,'Exporta Excel'    ,,.F.,.F. )
	     oTBtnBmp4  := TBtnBmp2():New( 120, 09, 26, 26, 'CANCEL',,,,{|| If(lRet:=Finaliza(),oDlgSB1:End(),)},oDlgSB1,'Cancela atualização de produtos'    ,,.F.,.F. ) 
	      
	     oFont      := TFont():New('Courier new',,-14,.T.)
	     oTMsgBar   := TMsgBar():New(oDlgSB1, 'HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
	     oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
	     oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})  

	ACTIVATE MSDIALOG oDlgSB1  CENTERED 
	  
  Else
  	MsgStop("Necessário checar a tabela SYD, entrar em contato com IT","Atenção") 
   	Return .F.    
   	  
  EndIf
  
  
  

    
Return
*------------------------------*
  Static Function GravaSB1()
*-----------------------------*         

Local nAux:=nPos:=0
Private aAux,aLogSB1 

aLogSB1:={}                 
cLog:="Produto           NCM              IPI-Atual           IPI-Anterior"+CHR(13)+CHR(10)
cLog+=CHR(13)+CHR(10)
cFil:=xFilial("SB1")

SB1->(DbGotop())   
While SB1->(!EOF())
   If SYD->(DbSeek("  "+Alltrim(SB1->B1_POSIPI)+"  "+SB1->B1_EX_NCM))
      RecLock("SB1",.F.)    
      If cFil==SB1->B1_FILIAL  
			nAux:=SB1->B1_IPI
   			cLog+=(SB1->B1_COD+"  "+SB1->B1_POSIPI+"        "+Alltrim(Str(SYD->YD_PER_IPI))+"                  "+Alltrim(Str(nAux)))+CHR(13)+CHR(10)               
      		SB1->B1_IPI:=SYD->YD_PER_IPI   
        	Aadd(aLogSb1,{SB1->B1_FILIAL,SB1->B1_COD,SB1->B1_POSIPI,Alltrim(Str(SYD->YD_PER_IPI)),Alltrim(Str(nAux))})  
      EndIf        
      SB1->(MsUnlock())          
   EndIf 
   SB1->(DbSkip())
EndDo 
   
cTextSB1:="Aliquota de IPI atualizada  com sucesso, para todos os produtos vinculados à uma NCM , clique em visualizar log."+CHR(13)+CHR(10)
cTextSB1+=CHR(13)+CHR(10)  
 
lSb1Ok:=.T.

cArqOrig:=GeraArq("SB1")

SendEmail(cArqOrig,"SB1")   

Aviso('HLB',cTextSB1,{'Ok'},3)   
       
Return    
           
*------------------------------*
  Static Function Finaliza()
*------------------------------*  

Local lRet:=.F.

If lSb1Ok 
   If MSGYESNO("Deseja sair ?","HLB") //"Deseja sair ?","Atenção"    
      lRet:=.T.
  EndIf
Else   
   If MSGYESNO("Deseja sair sem atualizar os produtos ?","HLB") //"Deseja sair ?","Atenção"    
     lRet:=.T.
   EndIf
EndIf 

Return lRet      

*------------------------------*
  Static Function LogAtu()
*------------------------------*  
  
 If Empty(cLog)
    cLog:="Atualização dos produtos não realizada"
    EECVIEW(cLog,"Detalhes da atualização") 
 Else
    EECVIEW(cLog,"Detalhes da atualização")  
 EndIf
      
Return   

*--------------------------------------------*
  Static Function SendEmail(cArqOrig,cTipo)
*--------------------------------------------*     

Local cServer   := "mail.hlb.com.br" 	// AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount  := "totvs@hlb.com.br" 	// AllTrim(GetNewPar("MV_RELFROM"," "))
Local cPassword := "Protheus@2010" 		// AllTrim(GetNewPar("MV_RELPSW" ," "))
Local lAutent   := .F.					// GetMv("MV_RELAUTH",,.F.)
Local cFrom 	:= "totvs@hlb.com.br" 	// AllTrim(GetNewPar("MV_RELFROM"," "))
Local lOk      	:= .F.
Local cBody:=cSubject:= ""       
Local nPos   
Local cC

If cTipo=="NCM"

   cSubject := "Msg Automatica Gt Protheus11 - Atualização de NCM "
// cTo      := "monalisa.martins@hlb.com.br;priscila.santos@hlb.com.br;germano.costa@hlb.com.br;Diego.libanori@hlb.com.br " //MSM - 12/03/2012
// cTo      := "monalisa.martins@hlb.com.br;priscila.santos@hlb.com.br;almeida.lima@hlb.com.br "// RRP - 30/11/2012 - Alteração nos emails de recebimento conforme solicitado no chamado: 008481
// cTo		:= "monalisa.martins@hlb.com.br;jefferson.bernardino@hlb.com.br;carla.oliveira@hlb.com.br;cristovão.cruz@hlb.com.br;fernanda.bernardes@hlb.com.br;vilma.oliveira@hlb.com.br;sergio.dechechi@hlb.com.br " // RSB - 30/01/2017 - Alteração nos emails de recebimento conforme solicitado no chamado: 035504
   cTo		:= "monalisa.martins@hlb.com.br;jefferson.bernardino@hlb.com.br;carla.oliveira@hlb.com.br;cristovão.cruz@hlb.com.br;fernanda.bernardes@hlb.com.br;vilma.oliveira@hlb.com.br;sergio.dechechi@hlb.com.br;juliane.balbo@hlb.com.br;luis.costa@hlb.com.br;tatiane.tandu@hlb.com.br"
   cCc      := "logncm@gmail.com"
   cBody    := "Rotina de atualização de NCM executada pelo usuário :  "+cUserName
   cAnexos  := ""
                                                  
   If Select("INT_SYD")>0
      DbCloseArea("INT_SYD")
   EndIf
                                   
   nPos:=At(".",cArqOrig)

   FreName(cArqOrig,Substr(cArqOrig,1,nPos-1)+"_NCM_"+SM0->M0_CODIGO+".XLS")
   cArqOrig:=(Substr(cArqOrig,1,nPos-1)+"_NCM_"+SM0->M0_CODIGO+".XLS")
   cAnexos  :=cArqOrig

   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk      

   If lOk  
      If lAutent 
         lAutent := MAILAUTH(cFrom,cPassword)
	  EndIf
	  
	  SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk   
	  cTextNCM+="Email de Log de atualização enviado com sucesso."+CHR(13)+CHR(10) 	  
   Else
      cTextNCM+="Não foi possivel enviar e-mail com log de atualização."+CHR(13)+CHR(10) 	  
   EndIf

   DISCONNECT SMTP SERVER 
     
   cDest:="D:\Protheus10\"+Alltrim(GetEnvServer())+"\Log\NCM"

   //If ExistDir("\Log\NCM")   
   //   If CpyS2t(cArqOrig,cDest)
   //      MsgAlert("Log Gravado","HLB")
   //   EndIf 
   //EndIf   

EndIf

If cTipo=="SB1"

   cSubject := "Msg Automatica Gt Protheus11 - Atualização de Produtos - "+Alltrim(SM0->M0_NOME)
// cTo      := "monalisa.martins@hlb.com.br;priscila.santos@hlb.com.br;germano.costa@hlb.com.br;Diego.libanori@hlb.com.br" // MSM - 12/03/2012
// cTo      := "monalisa.martins@hlb.com.br;priscila.santos@hlb.com.br;almeida.lima@hlb.com.br " // RRP - 30/11/2012 - Alteração nos emails de recebimento conforme solicitado no chamado: 008481
// cTo		:= "monalisa.martins@hlb.com.br;jefferson.bernardino@hlb.com.br;carla.oliveira@hlb.com.br;cristovão.cruz@hlb.com.br;fernanda.bernardes@hlb.com.br;vilma.oliveira@hlb.com.br;sergio.dechechi@hlb.com.br" // RSB - 30/01/2017 - Alteração nos emails de recebimento conforme solicitado no chamado: 035504
   cTo		:= "monalisa.martins@hlb.com.br;jefferson.bernardino@hlb.com.br;carla.oliveira@hlb.com.br;cristovão.cruz@hlb.com.br;fernanda.bernardes@hlb.com.br;vilma.oliveira@hlb.com.br;sergio.dechechi@hlb.com.br;juliane.balbo@hlb.com.br;luis.costa@hlb.com.br;tatiane.tandu@hlb.com.br"  
   cCc      := "logncm@gmail.com"
   cBody    := "Rotina de atualização de Produto executada pelo usuário :  "+cUserName
   cAnexos  := ""
                                                  
   If Select("INT_SB1")>0
      DbCloseArea("INT_SB1")
   EndIf
                                   
   nPos:=At(".",cArqOrig)

   FreName(cArqOrig,Substr(cArqOrig,1,nPos-1)+"_SB1_"+SM0->M0_CODIGO+".XLS")
   cArqOrig:=(Substr(cArqOrig,1,nPos-1)+"_SB1_"+SM0->M0_CODIGO+".XLS")
   cAnexos  :=cArqOrig

   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk      
 
   If lOk  
      If lAutent 
         lAutent := MAILAUTH(cFrom,cPassword)
	  EndIf
	  
	  SEND MAIL FROM cFrom TO cTo BCC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk
   	  cTextSB1+="Email de Log de atualização enviado com sucesso."+CHR(13)+CHR(10)  	  
   Else
      cTextSB1+="Não foi possivel enviar e-mail com log de atualização."+CHR(13)+CHR(10)  	  
   EndIf

   DISCONNECT SMTP SERVER 
     
   cDest:="D:\Protheus10\"+Alltrim(GetEnvServer())+"\Log\SB1"

   //If ExistDir("\Log\SB1")   
   //   If CpyS2t(cArqOrig,cDest)
   //      MsgAlert("Log Gravado","HLB")
   //   EndIf 
   //EndIf   

EndIf

Return     
  
*---------------------------------*
   Static Function GeraArq(cTipo)
*---------------------------------*    
 
Private aCpos,aStruSYD,aStruSB1                               
  
  aCpos:={}  
  aStruSYD:={} 
  aStruSB1:={}  


      If cTipo=="NCM"    

         If Select("INT_SYD") > 0
            INT_SYD->(DBCLoseArea())
         EndIf
        
         Aadd(aStruSYD, {"cSTATUS"      ,"C",20,0})
         Aadd(aStruSYD, {"NCM"          ,"C",8 ,0}) 
         Aadd(aStruSYD, {"EX_NCM"          ,"C",8 ,0})   
         Aadd(aStruSYD, {"IPI_ANT"      ,"C",2 ,0})
         Aadd(aStruSYD, {"IPI_ATUAL"    ,"C",2 ,0}) 
         Aadd(aStruSYD, {"DESCRICAO"    ,"C",70,0}) 
         Aadd(aStruSYD, {"USUARIO"      ,"C",30,0})
         Aadd(aStruSYD, {"EMPRESA"      ,"C",30,0})  
         Aadd(aStruSYD, {"DATAI"        ,"D",8,0}) 
         Aadd(aStruSYD, {"HORA"         ,"C",8,0})  
         Aadd(aStruSYD, {"COD"          ,"C",02,0}) 
                
         cNome := CriaTrab(aStruSYD, .T.)                   
         DbUseArea(.T.,"DBFCDX",cNome,'Int_SYD',.F.,.F.)
         
         For i:=1 to Len(aRetorno)
         
            RecLock("Int_SYD",.T.)  
            Int_SYD->cStatus     :=aRetorno[i][1]
            Int_SYD->NCM         :=aRetorno[i][2]  
            Int_SYD->EX_NCM      :=aRetorno[i][3] 
           
            If ValType(aRetorno[i][4])<>"C"
               Int_SYD->IPI_ANT :=Alltrim(Str(aRetorno[i][4]))
            Else
               Int_SYD->IPI_ANT :=aRetorno[i][4]
            EndIf  
            
            If ValType(aRetorno[i][5])<>"C"
               Int_SYD->IPI_ATUAL :=Alltrim(Str(aRetorno[i][5]))
            Else
               Int_SYD->IPI_ATUAL :=aRetorno[i][5]
            EndIf   
            
            Int_SYD->DESCRICAO :=aRetorno[i][6]             
            Int_SYD->USUARIO   := alltrim(cUserName)
            Int_SYD->EMPRESA   := SM0->M0_NOME
            Int_SYD->COD       := SM0->M0_CODIGO
            Int_SYD->DATAI     := Date()     
            Int_SYD->HORA      := Time()
            
            Int_SYD->(MsUnlock())
         
         Next  
         
         cArqOrig := "\SYSTEM\"+cNome+".DBF"
         
         cTextNCM:="Cadastro de NCM atualizado com sucesso."+CHR(13)+CHR(10)
         cTextNCM+=CHR(13)+CHR(10)  
                  
      EndIf 
  
      If cTipo=="SB1"   

         If Select("INT_SB1") > 0
            INT_SYD->(DBCLoseArea())
         EndIf
      
         Aadd(aStruSB1, {"cSTATUS"      ,"C",15,0}) 
         Aadd(aStruSB1, {"FILIAL"       ,"C",2 ,0}) 
         Aadd(aStruSB1, {"PRODUTO"      ,"C",15,0}) 
         Aadd(aStruSB1, {"NCM"          ,"C",8 ,0})  
         Aadd(aStruSB1, {"IPI_ANT"      ,"C",2 ,0})
         Aadd(aStruSB1, {"IPI_ATUAL"    ,"C",2 ,0}) 
         Aadd(aStruSB1, {"USUARIO"      ,"C",30,0})  
         Aadd(aStruSB1, {"DATAI"        ,"D",8,0}) 
         Aadd(aStruSB1, {"HORA"         ,"C",8,0})  
         Aadd(aStruSB1, {"COD"          ,"C",02,0})
         Aadd(aStruSB1, {"EMPRESA"      ,"C",30,0}) 
                
         cNome := CriaTrab(aStruSB1, .T.)                   
         DbUseArea(.T.,"DBFCDX",cNome,'Int_SB1',.F.,.F.)
         
         For i:=1 to Len(aLogSb1)
         
            RecLock("Int_SB1",.T.)  
            Int_SB1->cStatus     :="Atualizado"
            Int_SB1->FILIAL      :=aLogSb1[i][1]
            Int_SB1->PRODUTO     :=aLogSb1[i][2]
            Int_SB1->NCM         :=aLogSb1[i][3] 
            Int_SB1->IPI_ANT     :=aLogSb1[i][4] 
            Int_SB1->IPI_ATUAL   :=aLogSb1[i][5] 
            Int_SB1->USUARIO     :=alltrim(cUserName)
            Int_SB1->DATAI       :=Date()  
            Int_SB1->HORA        :=Time()
            Int_SB1->COD         :=SM0->M0_CODIGO
            Int_SB1->EMPRESA     :=SM0->M0_NOME
            Int_SB1->(MsUnlock())
         
         Next  
         
         cArqOrig := "\SYSTEM\"+cNome+".DBF"  
            
                   
      EndIf           
                                               
Return cArqOrig                     

*--------------------------------*
  Static Function Valida(cTipo)
*--------------------------------*

Local cText,aSays,aButtons 

  aSays:={}
  aButtons:={}

   If cTipo=="NCM"

      cText:="Rotina de atualizacao de NCM"     
      Aadd(aSays,"Essa rotina ira atualizar as Alíquotas de IPI de todas as NCMs") 
      Aadd(aSays,"integradas pelo arquivo. Será gravado um log desse procedimento. ")
      Aadd(aSays," " )   
      Aadd(aSays,"Deseja prosseguir ? " )                                 
      Aadd(aButtons, { 1,.T.,{|o| Processa({|| AtuNCM(),,,.T.}) ,o:oWnd:End() }} )
      Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
   
      FormBatch( cText, aSays, aButtons,,200,405  ) 
   
   
   EndIf  
   
            
   If cTipo=="SB1"
                        
      If lSb1OK 
         cText:="Rotina de atualizacao de IPI - produtos"     
         Aadd(aSays,"Essa rotina já foi executada. ")
         Aadd(aSays," " )  
         Aadd(aSays,"Deseja executar novamente ? ")                                                                                                        
                                        
         Aadd(aButtons, { 1,.T.,{|o|  Processa({|| GravaSB1(),,,.T.}),o:oWnd:End() }} )
         Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
   
         FormBatch( cText, aSays, aButtons,,200,405  ) 
      
      Else
         cText:="Rotina de atualizacao de IPI - produtos"     
         Aadd(aSays,"Essa rotina ira atualizar as Alíquotas de IPI de todos os produtos ")
         Aadd(aSays,"relacionados as NCMs. Será gravado um log desse procedimento. ")
         Aadd(aSays," " )  
         Aadd(aSays,"Deseja prosseguir ? ")                                                                                                        
         Aadd(aButtons, { 1,.T.,{|o| Processa({|| GravaSB1(),,,.T.}),o:oWnd:End() }} )
         Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
   
         FormBatch( cText, aSays, aButtons,,200,405  )  
         
      EndIf   

   EndIf        
          

Return 

*------------------------------*
   Static Function ExpExcel()
*------------------------------*   

Local cPath    

   If !(MsgYesNo("Deseja exportar as NCMs ? ","HLB")) 
      Return .F.
   EndIf
   
   If ApOleClient("MsExcel")
         
      If !(lSb1Ok)
         GeraArq("NCM")       
      EndIf
   
   
      If Select("INT_SYD")>0
         DbCloseArea("INT_SYD")
      EndIf

      cPath     := AllTrim(GetTempPath())                                                   
      CpyS2T( cArqOrig , cPath, .T. )
           
      oExcelApp:=MsExcel():New()
      //oExcelApp:WorkBooks:Open("Z:\AMB01\SYSTEM\"+cNome+".DBF") 
      oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
      oExcelApp:SetVisible(.T.)   
    
   Else 
      
      Alert("Excel não instalado") 
      
   EndIf

Return      

*--------------------------------*
   Static Function CarregaSYD()
*--------------------------------*  
                          
DbSelectArea("SYD")
SYD->(DbSetOrder(1))    
SYD->(DbGoTop())
               
n:=1
While SYD->(!EOF()) 
                    
	If Len(Alltrim(SYD->YD_TEC)) == 8  
   		IncProc("Aguarde, carregando NCM's: " +Alltrim(Str(n))) 
   		Aadd(aRetorno,{"Disponivel",Alltrim(SYD->YD_TEC),Alltrim(SYD->YD_EX_NCM),"-",Alltrim(Str(SYD->YD_PER_IPI)),Alltrim(SYD->YD_DESC_P)}) 
   
   		n++
   	EndIf	
   		
   	SYD->(DbSkip())
   
      
EndDo  
   
GeraArq("NCM")
   
Return 
                
*------------------------------*
   Static Function CheckSIX()
*------------------------------*  
                           
Local lOk:=.F.

SIX->(DbSeek("SB1"))    
While SIX->(!EOF()) .And. SIX->INDICE=="SB1"
  If Alltrim(SIX->NICKNAME)=="NCM"
      lOk:=.T.
   EndIf
   SIX->(DbSkip())
EndDo

Return lOk                
