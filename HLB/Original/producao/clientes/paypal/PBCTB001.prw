#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : PBCTB001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para gerar arquivo TXT dos lançamentos contabeis
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012                       
Obs         : Esse rdmake será também utilizado em JOB.
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Contabil. 
Cliente     : Paypal
*/

*-------------------------*
 User Function PBCTB001()
*-------------------------* 
     
If !(cEmpAnt $ ("PD/PB/7W"))
	MsgInfo("Rotina não disponivel para esse cliente","HLB BRASIL") 
	Return .F.
EndIf

//Testa para verificar se está sendo feito pelo JOB ou pelo menu				                        
If Select("SX3")<=0
	RpcSetType(3)
	RpcSetEnv("PD", "01")  //Abre ambiente em rotinas automáticas  
	PBCTB01A(.T.) 
Else
	PBCTB01A(.F.) 
EndIf		    

Return    
                 
/*
Funcao      : PBCTB01A
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para montar o arquivo Txt
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012 
Obs         :
*/              
                                                            
*-------------------------------*
  Static Function PBCTB01A(lJob)  
*-------------------------------*
            
          
Local lRet       := .F.  
Local lOK		 := .F.
Local lInc       := .T.    
Local lConnect   := .F.


Local nPos       := 0 
Local nOpc       := 0
Local nCT2Hdl    := 0  
Local nTamLin    := 0 
Local nTotItems  := 1  

Local aButtons   := {}                  

Local oFont14    := TFont():New('Courier new',,-14,.T.)

Local cData 	 := DTOS(Date())   
Local cPath 	 := AllTrim(GetTempPath()) 
Local cEOL  	 := "CHR(13)+CHR(10)" 
Local cDirBkp  	 := "\ftp\PB\BKP\"

Local cCab       := "" 
Local cId        := ""
Local cTipo      := ""   
Local cConGt     := ""   
Local cConPy     := ""   
Local cCusto     := ""       
Local cMsg       := ""
Local c0031      := ""
Local cItem      := ""
Local cClasse    := ""
Local cFile      := ""  
Local cDirFtp    := "/"     
Local cData      := ""  
Local cVal       := ""

Private nTotCred := 0
Private nTotDeb  := 0

Private oDlg
                  
Private lInverte :=.F.
Private lArq     :=.F. 

Private aCpos    := {}    

Private cMarca   := GetMark()   
  
Private cDir  	 := "\ftp\PB\CTB\"    

Private cCT2Txt  := "Paypal_tmf_bpp_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".txt"      
         
cEOL := Trim(cEOL)
cEOL := &cEOL          

		   
//Verifica se a geração é por JOB                   
If lJob	
	lRet:=PBCTB01B(.T.) 
Else
	lRet:=PBCTB01B(.F.) 
EndIf 

If !(lRet) 

	cMsg := "Nenhum lançamento encontrado para geração de arquivo" 

	If !(lJob)
		MsgInfo(cMsg,"Paypal")	
	Else
		PBCTB01C(cMsg)	
	EndIf	 
	
	Return lRet
	
EndIf                 

If !(lJob)  
    
	//Testa para ver se existe dados
	If (TempCT2->(!BOF() .and. !EOF())) 
	                                
		//Adicona o notão marca todos
		aadd(aButtons,{"PENDENTE",{|| MarcaTds()},"Marca todos","Marca todos ",{|| .T.}})

		TempCT2->(DbGoTop())       
	                                 
		//Monta a tela para seleção de lançamentos
	   	DEFINE MSDIALOG oDlg TITLE "Geração de lançamentos contabeis" FROM 000,000 TO 490,990 PIXEL
	                      
	        @ 017 , 006 TO 045,490 LABEL "" OF oDlg PIXEL 
	        @ 026 , 015 Say  "SELECIONE OS LANÇAMENTOS QUE DEVEM SER GERADOS EM ARQUIVO" COLOR CLR_HBLUE, CLR_WHITE      PIXEL SIZE 500,8 Font oFont14 OF oDlg           
	                        
	        oTMsgBar := TMsgBar():New(oDlg,"GERAÇÃO DE ARQUIVO",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont14,.F.)   
	        oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
	        oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
	    	oMarkPrd:= MsSelect():New("TempCT2","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,225,490},,,oDlg,,)   
	       	
	     	   
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOk:=check(),If(lok,nOpc:=1,nOpc:=2),If(lok,oDlg:End(),MsgStop("Lançamento não marcado ou total inválido, verificar.","Paypal"))},{|| (nOpc:=2,oDlg:End())},,aButtons) CENTERED 
		 		
		
    EndIf
Else
	nOpc:=1    
EndIf      

//nOpc 1.geração ou  2.Cancelar
If nOPc == 1 .And. lRet  

	nCT2Hdl:= fCreate(cDir+cCT2Txt)
	If nCT2Hdl == -1 // Testa se o arquivo foi gerado 
	
		cMsg:="O arquivo "+cCT2Txt+" nao pode ser executado." 
	
		If !(lJob)
			MsgAlert(cMsg,"Atenção")  
		Else
			PBCTB01C(cMsg)
		EndIf  
		
  		Return .F.  
  		
	EndIf  
	
	cData:=substr(Dtoc(Date()),4,2)+"/"+substr(Dtoc(Date()),1,2)+"/"+substr(Dtoc(Date()),7,4)   
	     
	//IDENT
	nTamLin   := 34   
	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	cCab  	  := "FH|BRZLPAYPAL|"+alltrim(cData)+"|"+TIME()+cEOL 
	
	If fWrite(nCT2Hdl,cCab,Len(cCab)) != (Len(cCab))   
	
		cMsg:="Ocorreu um erro na gravacao do arquivo, cabeçalho FH (Var:cCab). "
		
		If !(lJob) 
 			MsgAlert(cMsg,"Atencao!")
 		Else
 			PBCTB01C(cMsg)
 		EndIf 
 		
 		Return .F.    
 		
	EndIf  
	
	//HEADER    		
	nTamLin   := 248   
	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao                     
    // Exemplo enviado pelo cliente :  H|06/28/2012|ZL|0646|06/28/2012|BRL||||YOKIM|PAYPAL BRAZIL - Jun 2012|||||||||||||||||||||||||||||||||
	//cCab      := "H|"+alltrim(cData)+"|ZL|0646|"+alltrim(cData)+"|BRL||||YOKIM|PAYPAL BRAZIL - "+Substr(cMonth(Date()),1,3)+" "+alltrim(str(year(Date())))+"|||||||||||||||||||||||||||||||||"+cEOL              		                          
	 
	//TLM 20150605 - Ajuste do aprovador de YOKIM para GPEREIRAARAN
	cCab      := "H|"+alltrim(cData)+"|ZL|0646|"+alltrim(cData)+"|BRL||||GPEREIRAARAN|PAYPAL BRAZIL - "+Substr(cMonth(Date()),1,3)+" "+alltrim(str(year(Date())))+"|||||||||||||||||||||||||||||||||"+cEOL              		                          

	If fWrite(nCT2Hdl,cCab,Len(cCab)) != (Len(cCab))
		
		cMsg:="Ocorreu um erro na gravacao do arquivo, cabeçalho H(Var:cCab). "
		
		If !(lJob) 
			MsgAlert(cMsg,"Atencao!")
		Else
			PBCTB01C(cMsg)
		EndIf
 	   
 		Return .F. 
   
	EndIf   
	
	//Conexao do FTP interno
	For i:=1 to 3    // Tenta conectar no FTP 3 vezes.
                                     
 		lConnect:=ConectaFTP()

		If lConnect
	 		i:=3
	   	EndIf
   
    Next   

	If !(lJob) 
		If !(lConnect)      
			MsgAlert("Não foi possivel estabelecer conexão com FTP interno.","Atenção")   		
		 	Return .F.
	   	EndIf  	
	Else
		If !(lConnect)  
			Return .F.
		EndIf
	EndIf 

	 
	
	TempCT2->(DbGoTop()) 
	While TempCT2->(!EOF()) 
	   	   	
		If !Empty(TempCT2->cINTEGRA) .And. TempCT2->CT2_MOEDLC=="04"
		                                        			
			If  TempCT2->CT2_DC == "1"
		    	cTipo  := "40" //Dedito   
		    	cConGt := TempCT2->CT2_DEBITO
		    	cCusto := TempCT2->CT2_CCD
		    	cItem  := TempCT2->CT2_ITEMD
		    	cClasse:= TempCT2->CT2_CLVLDB
		    Else
		        cTipo:="50" //Credito 
		        cConGt := TempCT2->CT2_CREDIT  
		    	cCusto := TempCT2->CT2_CCC 
		    	cItem  := TempCT2->CT2_ITEMC 
		    	cClasse:= TempCT2->CT2_CLVLCR
		    EndIf     
		    
		    CT1->(DbSetOrder(1))   
		    If CT1->(DbSeek(xFilial("CT1")+cConGt))
		    	
		    	cConPy:= CT1->CT1_P_CONT
		    	
		    	//Caso a conta contabil não esteja preenchida a execução deve parar
		    	If Empty(cConPy)   
		    	
			    	cMsg:="A conta do Paypal não está preenchida no cadastro de conta contabil HLB          Conta : "+Alltrim(cConGt)+" , não foi gerado arquivo."      
	    	
					If !(lJob) 
						MsgStop(cMsg,"Atencao!")
					Else
						PBCTB01C(cMsg)     
					EndIf  
					
			 		Return .F. 		    	
		    	
		    	
		    	EndIf	
		    
		    	
		    Else        
		    
			   	cMsg:="A conta do Paypal não está preenchida no cadastro de conta contabil HLB          Conta :"+Alltrim(cConGt)+" , não foi gerado arquivo."      
		    
		    	//Caso a conta contabil não esteja preenchida a execução deve parar
		    	If !(lJob) 
					MsgStop(cMsg,"Atencao!")
				Else	
					PBCTB01C(cMsg)
				EndIf 
				
		   		Return .F. 
		   				    
		    EndIf
		    		        
		    //Codigo fixo conforme alinha em reunião 21/01/2013
		     
		    //Resposta: Verifiquei com o Yong Kim e na verdade é mandatório somente para as contas de receita (contas tipo 4), mas para os demais não tem nenhuma implicação, ou seja, favor incluir para todos os lançamentos. P&L e balance sheet
		    //If SubStr(cConPy,1,1) == "4"
		    	c0031:="0031"
		    //EndIf     
		    
		    cVal :=Alltrim(Transform(TempCT2->CT2_VALOR,"@E 9999999999999.99")) 
			nPos:=At(",",Alltrim(cVal))   
   			cVal:=Stuff(cVal,nPos,1,".")
	    	
		   	// DETAIL
		   	nTamLin   := 248   
		   	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao 
   			// Exemplo enviado pelo cliente :  L|||||||||||||50|221030|||         ||59,855.00||||||||60000     |||BRAZIL SEAT ACCRUAL - 6465099405|||||||||||||| 
		   	cCab      := "L|||||||||||||"+cTipo+"|"+alltrim(cConPy)+"|"+alltrim(cClasse)+"||"+Alltrim(RegrasPY("001","1",cConGt))+"||"+cVal+"||||||"+alltrim(cCusto)+"||"+alltrim(cItem)+"|||"+Alltrim(TempCT2->CT2_HIST)+"|||||||||||||"+c0031+"|"+cEOL              		                          
	
			If fWrite(nCT2Hdl,cCab,Len(cCab)) != (Len(cCab))
		 		
		 		cMsg:="Ocorreu um erro na gravacao do arquivo, itens L (Var:cCab). "
		 		
		 		If !(lJob) 
		 			MsgAlert(cMsg,"Atencao!")
		   		Else
		   	   		PBCTB01C(cMsg)
		   		EndIf 
		   		
		   		Return .F. 
		   		
		   	EndIf  
		   	
		   	nTotItems++
		   	
 	    EndIf
 	        
    	TempCT2->(DbSkip())
    	
	EndDo   	
	    
	// FOOTER	
	nTamLin   := 10  
	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao 
	cCab      := "FT|END|"+alltrim(str(nTotItems))+cEOL              		                          
	
	If fWrite(nCT2Hdl,cCab,Len(cCab)) != (Len(cCab))
		If !(lJob) 
	   		MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho YY (Var:cCab). ","Atencao!")
	 	Else
	 		PBCTB01C()
	 	EndIf
	  	Return .F. 
	EndIf           	       			       	
	
	fClose(nCT2Hdl) 
	
	//Inclusão novo ID
	If Empty(TempCT2->CT2_P_ID)    
		cId:=GetSx8Num("CT2","CT2_P_ID")   
	Else   
		lInc:=.F.           
		//Alteração utiliza o mesmo ID
   		cId:=TempCT2->CT2_P_ID
	EndIF
	        
	CT2->(DbSetOrder(1))
	TempCT2->(DbGoTop()) 
	While TempCT2->(!EOF()) 
	   	   	
		If !Empty(TempCT2->cINTEGRA)  
		        
		    //Atualiza os lançamentos com gerado SIM   
			If CT2->(DbSeek(xFilial("CT2")+DTOS(TempCT2->CT2_DATA)+TempCT2->CT2_LOTE+TempCT2->CT2_SBLOTE+TempCT2->CT2_DOC+TempCT2->CT2_LINHA))                
		   		
		   		While TempCT2->(!EOF()) .And. ;
		   		xFilial("CT2")+DTOS(TempCT2->CT2_DATA)+TempCT2->CT2_LOTE+TempCT2->CT2_SBLOTE+TempCT2->CT2_DOC+TempCT2->CT2_LINHA==xFilial("CT2")+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA
			   		
			   		RecLock("CT2",.F.)
			   		CT2->CT2_P_GER := 'S' 
			   		CT2->CT2_P_ID  := cId   
			   		CT2->CT2_P_ARQ := cCT2Txt
			   		CT2->(MsUnlock()) 
				
					CT2->(DbSkip())     
				
				EndDo
			
			EndIf
		
		EndIf
		
		TempCT2->(DbSkip())	              
		
	EndDo	
	
	ConfirmSX8()   
	 
	//Atualiza a tabela de log     
	ZX0->(DbSetOrder(1)) 
	
	RecLock("ZX0",.T.)
	ZX0->ZX0_FILIAL  := xFilial("ZX0")
	ZX0->ZX0_ID      := cId
	ZX0->ZX0_ARQ     := cCT2Txt

	If lJob
		ZX0->ZX0_USR := "JOB"
	Else  
		ZX0->ZX0_USR := cUserName
	EndIf

	ZX0->ZX0_DATA    := Date()
	ZX0->ZX0_HORA    := TIME()
		   	
	//Inclusão
	If lInc
		ZX0->ZX0_TIPO    := "I"
	 	ZX0->ZX0_DESC    := "INCLUSAO"
	EndIf
		   	
	ZX0->ZX0_TOTCR   := nTotCred
	ZX0->ZX0_TOTDB   := nTotDeb
	ZX0->(MsUnlock())      
	
	lArq:=.T.  
	cMsg:="Arquivo gerado com sucesso: "+alltrim(cCT2Txt)          	

	If !(lJob) 
		MsgInfo(cMsg,"Grant Thorton")  
	EndIf 
	
	__CopyFile(cDir+cCT2Txt,cDirBkp+cCT2Txt)   
	
	//cFile:="C:\Windows\SysWOW64\cmd.exe /c xcopy d:\Protheus10\gt03\ftp\PB\CTB\"+alltrim(cCT2Txt)+" x:\" 
	//lRet:=WaitRunSrv(cFile,.T.,"C:\Windows\SysWOW64\")
   
	If lConnect                                       
	
		FTPDirChange(cDirFtp)  // Monta o diretório do FTP, será gravado na raiz "/"
	
		// Grava Arquivo no FTP
   		If FTPUpLoad(alltrim(cDir+cCT2Txt),alltrim(cCT2Txt))
			If !(lJob)
			 	cMsg:="Arquivo "+alltrim(cCT2Txt)+" gerado com sucesso no FTP interno."         
				MsgInfo(cMsg,"Grant Thorton")  
			EndIf 		
		Else 
			If !(lJob)
			 	cMsg:="O Arquivo "+alltrim(cCT2Txt)+" não pode ser gravado no FTP interno"         
				MsgStop(cMsg,"Grant Thorton")  
			EndIf 
		EndIf
	
	EndIf
	 
	FTPDisconnect()    

	PBCTB01C(cMsg)


EndIf

Return lRet

/*
Funcao      : PBCTB01B
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para buscar os dados do arquivo
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012 
Obs         :
*/              
                                                            
*-------------------------------*
  Static Function PBCTB01B(lJob)  
*-------------------------------*
      
Local lRet:=.T.

Private aStruCT2 := {}

	If Select("CT2QRY") > 0
		CT2QRY->(dbCloseArea())
	Endif 
	
	If Select("TempCT2") > 0
		TempCT2->(dbCloseArea())
	Endif
	
	//Seleciona lançamentos que não foram geradas CT2_P_GER branco
	BeginSql Alias 'CT2QRY'                               
	
		SELECT *
	 	FROM %Table:CT2%
	       WHERE %notDel%
	       AND CT2_FILIAL = %exp:xFilial("CT2")%  
	       AND (CT2_P_GER  = 'N' Or CT2_P_GER  = ' ' )       
	       AND CT2_DC IN ('1','2')  
	       AND CT2_MOEDLC='04'
	       AND CT2_DATA > '20121130' // Lançamentos antigos não devem ser mostradas.
	
	       ORDER BY CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_LINHA,CT2_DOC
	       
	EndSql
	
	CT2QRY->(DbGoTop())
	If !(CT2QRY->(!BOF() .and. !EOF()))
		lRet:=.F.
	 	Return lRet
	EndIf
	

	Aadd(aCpos, {"cINTEGRA"   ,"",})
	Aadd(aCpos, {"CT2_DATA"   ,"","Dt Lcto"     ,}) 
	Aadd(aCpos, {"CT2_LOTE"   ,"","Nr. Lote"    ,})                               
	Aadd(aCpos, {"CT2_SBLOTE" ,"","Sub. Lote"   ,})
	Aadd(aCpos, {"CT2_DOC"    ,"","Documento"   ,})	
	Aadd(aCpos, {"CT2_LINHA"  ,"","Seq. Lcto"   ,})
	Aadd(aCpos, {"CT2_DC"     ,"","Tipo Lcto"   ,})
	Aadd(aCpos, {"CT2_DEBITO" ,"","Cta Debito"  ,})		
	Aadd(aCpos, {"CT2_CREDIT" ,"","Cta Credito" ,}) 
	Aadd(aCpos, {"CT2_VALOR"  ,"","Valor"       ,})				
	Aadd(aCpos, {"CT2_HIST"   ,"","Historico"   ,})
	Aadd(aCpos, {"CT2_CCD"    ,"","C Custo Deb.",})		
	Aadd(aCpos, {"CT2_CCC"    ,"","C Custo Cred.",}) 
	Aadd(aCpos, {"CT2_ITEMD"  ,"","Item C Deb."  ,})				
	Aadd(aCpos, {"CT2_ITEMC"  ,"","Item C Cred." ,}) 
	Aadd(aCpos, {"CT2_CLVLDB" ,"","Clasee V Deb.",})		
	Aadd(aCpos, {"CT2_CLVLCR" ,"","Classe V Cred.",}) 
	Aadd(aCpos, {"CT2_MOEDLC" ,"","Moeda Lancto",})  
	Aadd(aCpos, {"CT2_P_ID"   ,"","ID Log",})  
	  
	Aadd(aStruCT2, {"cINTEGRA"  ,"C",2   ,0})      
	Aadd(aStruCT2, {"CT2_DATA"  ,"D",8   ,0}) 
	Aadd(aStruCT2, {"CT2_LOTE"  ,"C",6   ,0})
	Aadd(aStruCT2, {"CT2_SBLOTE","C",3   ,0})   
	Aadd(aStruCT2, {"CT2_DOC"   ,"C",6   ,0}) 
	Aadd(aStruCT2, {"CT2_LINHA" ,"C",3   ,0})
	Aadd(aStruCT2, {"CT2_DC"    ,"C",1   ,0})   
	Aadd(aStruCT2, {"CT2_DEBITO","C",20  ,0}) 
	Aadd(aStruCT2, {"CT2_CREDIT","C",20  ,0})
	Aadd(aStruCT2, {"CT2_VALOR" ,"N",17  ,2})   
	Aadd(aStruCT2, {"CT2_HIST"  ,"C",40  ,0}) 
	Aadd(aStruCT2, {"CT2_CCD"   ,"C",10   ,0})
	Aadd(aStruCT2, {"CT2_CCC"   ,"C",10   ,0})   
	Aadd(aStruCT2, {"CT2_ITEMD" ,"C",10   ,0}) 
	Aadd(aStruCT2, {"CT2_ITEMC" ,"C",10   ,0})
	Aadd(aStruCT2, {"CT2_CLVLDB","C",10   ,0})   
	Aadd(aStruCT2, {"CT2_CLVLCR","C",10   ,0})
	Aadd(aStruCT2, {"CT2_MOEDLC","C",2   ,0})
	Aadd(aStruCT2, {"CT2_P_ID"  ,"C",6   ,0})
	
	cNome := CriaTrab(aStruCT2, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'TempCT2',.F.,.F.) 
	    	 
    CT2QRY->(DbGoTop())
	While CT2QRY->(!EOF())
                                  
		RecLock("TempCT2",.T.)
		TempCT2->CT2_DATA    := SToD(CT2QRY->CT2_DATA)
		TempCT2->CT2_LOTE    := CT2QRY->CT2_LOTE
		TempCT2->CT2_SBLOTE  := CT2QRY->CT2_SBLOTE
		TempCT2->CT2_DOC     := CT2QRY->CT2_DOC
		TempCT2->CT2_LINHA   := CT2QRY->CT2_LINHA
		TempCT2->CT2_DC      := CT2QRY->CT2_DC
		TempCT2->CT2_DEBITO  := CT2QRY->CT2_DEBITO
		TempCT2->CT2_CREDIT  := CT2QRY->CT2_CREDIT
		TempCT2->CT2_VALOR   := CT2QRY->CT2_VALOR
		TempCT2->CT2_HIST    := CT2QRY->CT2_HIST
		TempCT2->CT2_CCD     := CT2QRY->CT2_CCD
		TempCT2->CT2_CCC     := CT2QRY->CT2_CCC
		TempCT2->CT2_ITEMD   := CT2QRY->CT2_ITEMD
		TempCT2->CT2_ITEMC   := CT2QRY->CT2_ITEMC
		TempCT2->CT2_CLVLDB  := CT2QRY->CT2_CLVLDB
		TempCT2->CT2_CLVLCR  := CT2QRY->CT2_CLVLCR
		TempCT2->CT2_MOEDLC  := CT2QRY->CT2_MOEDLC
		TempCT2->CT2_P_ID    := CT2QRY->CT2_P_ID
		TempCT2->(MsUnlock())		
	
	
    	CT2QRY->(DbSkip())
   
	EndDo    

     

Return lRet 

/*
Funcao      : MarcaTds
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Função para selecionar todos os registros do temporario.
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012 
*/  

*---------------------------*
  Static Function MarcaTds()
*---------------------------* 
  
DbSelectArea("TempCT2")   
TempCT2->(DbGoTop())  
While TempCT2->(!EOF())
	
	RecLock("TempCT2",.F.)     
 	If TempCT2->cINTEGRA == cMarca
  		TempCT2->cINTEGRA:=Space(02)   
    Else
    	TempCT2->cINTEGRA:= cMarca
    EndIf 
    TempCT2->(MsUnlock())
    TempCT2->(DbSkip())

EndDo         
TempCT2->(DbGoTop())      
      

Return 

/*
Funcao      : Check
Parametros  : nenhum
Retorno     : lRet
Objetivos   : Função para validar se os lançamentos foram marcados.
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012 
*/  

*---------------------------*
  Static Function Check()
*---------------------------* 
           
Local lRet    :=.F.  
Local nLinha  := 0

nTotCred := 0
nTotDeb  := 0
  
DbSelectArea("TempCT2")   
TempCT2->(DbGoTop())  
While TempCT2->(!EOF())
	
 	If !Empty(TempCT2->cINTEGRA)
   
    	If TempCT2->CT2_DC=="2"
       		nTotCred+=TempCT2->CT2_VALOR
    	End
  
    	If TempCT2->CT2_DC=="1"
    		nTotDeb+=TempCT2->CT2_VALOR
    	End      
    	
    	nLinha++
    	          
        lRet:=.T.

    EndIf 
    
  	TempCT2->(DbSkip())
  
EndDo 

If nTotDeb <> nTotCred
	MsgStop("Soma do credito: "+alltrim(str(nTotCred))+" difere do debito: "+alltrim(str(nTotDeb))+" , verificar.","Paypal")
	lRet:=.F.
EndIf       


If nLinha > 1000
	MsgStop("Quantidade registros marcados inválido :"+alltrim(str(nLinha))+" | deve ser no máximo 1000 , verificar.","Paypal")
	lRet:=.F.
EndIf
        
TempCT2->(DbGoTop())  

      
Return lRet


/*
Funcao      : PBCTB01C
Parametros  : cMsg
Retorno     : Nenhum
Objetivos   : Funcão para enviar email de notificação
Autor     	: Tiago Luiz Mendonça
Data     	: 18/12/2012 
Obs         :
*/              
                                                            
*-------------------------------*
  Static Function PBCTB01C(cMsg)  
*-------------------------------*

Local cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
//Local cAccount  := AllTrim(GetNewPar("MV_RELFROM"," "))
Local cAccount	:= AllTrim(SuperGetMv("MV_RELACNT",.F.,	""))
Local cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))
Local cFrom 	:= AllTrim(GetNewPar("MV_RELFROM"," "))
Local cTo       := AllTrim(GetNewPar("MV_P_EMAIL"," "))
Local cUserAut  := Alltrim(SuperGetMv("MV_RELAUSR",.F., ""))//Usuário para Autenticação no Servidor de Email
Local cPassAut 	:= Alltrim(SuperGetMv("MV_RELAPSW",.F., ""))//Senha para Autenticação no Servidor de Email
Local lAutentica:= GetMv("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local cCC       := ""
Local lOk      	:= .F.
Local cEmail    := ""
Local cSubject  := ""
Local cAnexos   := ""    
Local cC        := ""     

 
	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
 	cEmail += '<title>Notificao</title></head><body>'
  	cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
    cEmail += '<br>'   
    cEmail += '<br>'   
   	cEmail += 'Noficacao da execucao da rotina de geracao de arquivo do cliente Paypal  </b></u></font></p>'   
   	    

    cEmail += '<br>'   
    cEmail += '<br>' 
    
    cSubject:= "Noficacao da execucao da rotina de geracao de arquivo do cliente Paypal"      

	cEmail += '	<tr>'
	cEmail += '		<td width="40"><font face="Courier New" size="2">Mensagem</font></td> <br><br>'  
	cEmail += '		<td width="40"><font face="Courier New" size="2">'+Alltrim(cMsg)+'</font></td>'  
	cEmail += '	</tr>'
	cEmail += '<br>'                	
    cEmail += '<br>'   
    cEmail += '<br>'
          	 
    cEmail += '<b><p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
    cEmail += '<p align="center">www.grantthornton.com.br</p><b>'
    cEmail += '</body></html>'    
    
    
    If lArq
    	cAnexos  :=  cDir+cCT2Txt
    EndIf
    
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk      

	If !lOK
		ConOut("Falha na Conexão com Servidor de E-Mail")
		Return .F.
	Else
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				ConOut("Falha na Autenticacao do Usuario")
				DISCONNECT SMTP SERVER RESULT lOk          
				Return .F.
			EndIf
		EndIf
		
		SEND MAIL FROM cFrom TO cTo BCC cCC;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAnexos RESULT lOK

		If !lOK
			ConOut("Falha no Envio do E-Mail: "+Alltrim(cTo))
			DISCONNECT SMTP SERVER
			Return .F.
		EndIf
	EndIf

DISCONNECT SMTP SERVER

Return  

/*
Funcao      : ConectaFTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para conectar no FTP
Autor     	: Tiago Luiz Mendonça
Data     	: 10/01/2013 
Obs         :
*/          
*-----------------------------*
 Static Function ConectaFTP()
*-----------------------------*

Local cPath 	:= GETMV("MV_P_FTP") // "200.196.242.81"
Local clogin	:= GETMV("MV_P_USR") // "tiago"
Local cPass 	:= GETMV("MV_P_PSW") // "123" 
Local lRet		:= .F.

cPath  := Alltrim(cPath)
cLogin := Alltrim(cLogin)
cPass  := Alltrim(cPass) 

// Conecta no FTP
lRet := FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)         
               

/*
Funcao      : RegrasPY
Parametros  : cRegra,cTipo,cConta,
Retorno     : cRet
Objetivos   : Funcão para retornar dados de regras Paypal
Autor     	: Tiago Luiz Mendonça
Data     	: 23/01/2013 
Obs         :                          

[ cRegra - Códigos de regras ] 

	001 - Asset Transaction Type 

[ cTipo - Tipo da conta ] 

	1 - Conta HLB BRASIL
	2 - Conta Paypal
                      
[ cConta - Conta para procura da regra }
	
	Exemplo: 12214005 - MARCAS E PATENTES

*/          
*--------------------------------------------*
 Static Function RegrasPY(cRegra,cTipo,cConta)
*---------------------------------------------*
   
Local cRet
                      
//Se for conta GT seta o indice 1         
If cTipo=="1"
	ZX1->(DbSetOrder(1))
//Se for conta Paypal seta o indice 2  
Else
	ZX1->(DbSetOrder(2))
EndIf
     
//Pesquisa na tabela pelo código da regra e conta 
If ZX1->(DbSeek(xFilial("ZX1")+cRegra+cConta))                 
	//Retorna a Regra
	cRet:=ZX1->ZX1_REGRA
Else
	cRet:="" 
EndIf


Return (cRet) 
