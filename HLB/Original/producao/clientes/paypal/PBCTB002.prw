#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "tbiconn.ch"

/*
Funcao      : PBCTB002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para limpar a flag do arquivo gerado.
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012                       
Obs         :
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Contabil. 
Cliente     : Paypal
*/

*-------------------------*
 User Function PBCTB002()
*-------------------------* 

                      
Local lRet       := .F.  
Local lOK		 := .F.
Local lInc       := .T.    

Local nOpc       := 0

Local oDlg
Local oMarkPrd   

Local aButtons   := {}                  

Local oFont14    := TFont():New('Courier new',,-14,.T.)

Local cQry       := ""
Local cMsg       := ""
Local cData 	 := DTOS(Date())   
Local cPath 	 := AllTrim(GetTempPath()) 

Private lInverte :=.F. 

Private aCpos    := {}    

Private cMarca   := GetMark()
         		   
	lRet:=PBCTB02B() 
	
	If !(lRet) 
		MsgInfo("Nenhum lançamento encontrado para geração de arquivo","Paypal")	
		Return lRet
	EndIf                 
	
    
	//Testa para ver se existe dados
	If (TempZX0->(!BOF() .and. !EOF())) 
	                                
		//Adicona o notão marca todos
		aadd(aButtons,{"VERNOTA",{|| PBCTB02C()},"Lançamentos do arquivo","Lançamentos do arquivo",{|| .T.}})

		TempZX0->(DbGoTop())       
	                                 
		//Monta a tela para seleção de lançamentos
	   	DEFINE MSDIALOG oDlg TITLE "Manutenção de arquivo Paypal" FROM 000,000 TO 490,990 PIXEL
	                      
	        @ 017 , 006 TO 045,490 LABEL "" OF oDlg PIXEL 
	        @ 026 , 015 Say  "SELECIONE OS ARQUIVOS QUE DEVEM SER DESVINCULADOS DOS LANÇAMENTOS " COLOR CLR_HBLUE, CLR_WHITE      PIXEL SIZE 500,8 Font oFont14 OF oDlg           
	                        
	        oTMsgBar := TMsgBar():New(oDlg,"GERAÇÃO DE ARQUIVO",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont14,.F.)   
	        oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
	        oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
	    	oMarkPrd:= MsSelect():New("TempZX0","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,225,490},,,oDlg,,)   
	     	   
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOk:=check(),If(lok,nOpc:=1,nOpc:=2),If(lok,oDlg:End(),MsgStop("Lançamento não marcado ou erro na procura.","Paypal"))},{|| (nOpc:=2,oDlg:End())},,aButtons) CENTERED 
		 		
		
    EndIf
    
	If nOpc == 1    
	
		CTG->(DbSetOrder(4))  
		If CTG->(DbSeek(xFilial("CTG")+Substr(DTOC(TempZX0->ZX0_DATA),7,4)+Substr(DTOC(TempZX0->ZX0_DATA),4,2))) 
			If CTG->CTG_STATUS <> "1"
				MsgStop("Calendario contabil não aberto para data selecionada","Paypal")
				Return .F.
			EndIf 	
		EndIf
			 
		DbSelectArea("TempZX0")   
		TempZX0->(DbGoTop())  
		While TempZX0->(!EOF())
		    
			//Verifica os arquivos selecionados
	   		If !Empty(TempZX0->cINTEGRA)
                                  
		   		cQry := "Update "+RetSqlName("CT2")+" set CT2_P_ARQ='',CT2_P_GER='' where CT2_P_ARQ='"+alltrim(TempZX0->ZX0_ARQ)+"'"
	
				If !(TCSQLExec(cQry) < 0)   
				   			
		   			RecLock("ZX0",.T.)
		   			
					ZX0->ZX0_FILIAL  := xFilial("ZX0")
					ZX0->ZX0_DATA    := Date()
					ZX0->ZX0_ARQ     := TempZX0->ZX0_ARQ
					ZX0->ZX0_USR     := cUserName
					ZX0->ZX0_HORA    := Time()
					ZX0->ZX0_TOTCR   := TempZX0->ZX0_TOTCR
					ZX0->ZX0_TOTDB   := TempZX0->ZX0_TOTDB         
					ZX0->ZX0_ID      := TempZX0->ZX0_ID
					ZX0->ZX0_TIPO    := "A"
					ZX0->ZX0_DESC    := "ALTERACAO - ARQUIVO APAGADO" 
			
					ZX0->(MsUnlock())		
			         
					cMsg:="Arquivo "+alltrim(TempZX0->ZX0_ARQ)+" apagado dos lançamentos / User: "+Upper(Alltrim(cUserName)) 
					MsgInfo(cMsg,"Paypal")
				       
					PBCTB02D(cMsg)
				
		    	Else
		    	
		    		MsgAlert("Não foi possivel limpar os lançamentos entre em contato com a TI","Paypal")
		    	
		    	EndIf    
	
	    	EndIf
	    	
	    	TempZX0->(DbSkip())

		EndDo    
	    
	Else
		TempZX0->(DbGoTop())    		
	
	EndIf


Return lRet

/*
Funcao      : PBCTB02B
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para buscar os dados do arquivo
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012 
Obs         :
*/              
                                                            
*-------------------------------*
  Static Function PBCTB02B()  
*-------------------------------*
      
Local lRet:=.T.
Local lAlt:=.F.  
Local cArq:= ""

Private aStruZX0 := {}

	If Select("ZX0QRY") > 0
		ZX0QRY->(dbCloseArea())
	Endif 
	
	If Select("TempZX0") > 0
		TempZX0->(dbCloseArea())
	Endif
	
	//Seleciona os arquivos gerados na tabela de log ZX0
	
	//FIXADO a tabela ZX0PB0 pois a mesma não esta nos dicionarios, %Table:ZX0% retorna baseado nos dicionarios.
	
	BeginSql Alias 'ZX0QRY'                               
		       		
	   	SELECT C.CT2_P_ARQ,C.CT2_P_ID,Z.ZX0_TOTCR,Z.ZX0_TOTDB,MAX(Z.ZX0_DATA) as ZX0_DATA ,MAX(Z.ZX0_HORA) as ZX0_HORA  
	   	FROM %Table:CT2% C 
	   		LEFT JOIN %Table:ZX0% Z ON C.CT2_P_ARQ = Z.ZX0_ARQ 
	    WHERE
	    	C.CT2_P_ARQ <> ' '
	    GROUP BY
	    	C.CT2_P_ARQ,C.CT2_P_ID,Z.ZX0_TOTCR,Z.ZX0_TOTDB	       		
	    ORDER BY
	    	C.CT2_P_ARQ DESC	
	    	//C.CT2_P_ID DESC	
	       
	EndSql
	
	ZX0QRY->(DbGoTop())
	If !(ZX0QRY->(!BOF() .and. !EOF()))
		lRet:=.F.
	 	Return lRet
	EndIf  
	

	Aadd(aCpos, {"cINTEGRA","" ,           ,})
	Aadd(aCpos, {"ZX0_ARQ"   ,"" ,"Arquivo"  ,})
	Aadd(aCpos, {"ZX0_DATA"  ,"" ,"Data"     ,})
	Aadd(aCpos, {"ZX0_USR"   ,"" ,"User"     ,})
	Aadd(aCpos, {"ZX0_HORA"  ,"" ,"Hora"     ,})
	Aadd(aCpos, {"ZX0_TOTCR" ,"" ,"Tot Cred.",})
	Aadd(aCpos, {"ZX0_TOTDB" ,"" ,"Tot Deb." ,}) 
	Aadd(aCpos, {"ZX0_ID   " ,"" ,"Identificacao" ,}) 
  
	Aadd(aStruZX0, {"cINTEGRA"  ,"C",2   ,0})      
	Aadd(aStruZX0, {"ZX0_ARQ"   ,"C",40  ,0}) 
	Aadd(aStruZX0, {"ZX0_DATA"  ,"D",8   ,0}) 
	Aadd(aStruZX0, {"ZX0_USR"   ,"C",20  ,0})
	Aadd(aStruZX0, {"ZX0_HORA"  ,"C",5   ,0})  
	Aadd(aStruZX0, {"ZX0_TOTCR" ,"N",16  ,2})
	Aadd(aStruZX0, {"ZX0_TOTDB" ,"N",16  ,2})  
	Aadd(aStruZX0, {"ZX0_ID"    ,"C",06  ,0})  

	
	cNome := CriaTrab(aStruZX0, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'TempZX0',.F.,.F.) 
	
	ZX0->(DbSetOrder(1)) 
	  	 
    ZX0QRY->(DbGoTop())
	While ZX0QRY->(!EOF())
                                  
		RecLock("TempZX0",.T.)
        

		TempZX0->ZX0_DATA    := SToD(ZX0QRY->ZX0_DATA)
		TempZX0->ZX0_ARQ     := ZX0QRY->CT2_P_ARQ
	
		If Select("AUXQRY") > 0
			AUXQRY->(dbCloseArea())
		Endif 
	           
		cArq:=ZX0QRY->CT2_P_ARQ
	
		//Seleciona lançamentos de acordo com o arquivo selecionado
		BeginSql Alias 'AUXQRY'                               
		
			SELECT *
		 	FROM %Table:ZX0%            
		       WHERE %notDel%
		       AND ZX0_FILIAL = %exp:xFilial("ZX0")%  
		       AND ZX0_ARQ = %exp:cArq%
		       		       
		EndSql
		
		AUXQRY->(DbGoTop())

		TempZX0->ZX0_USR     := AUXQRY->ZX0_USR
		TempZX0->ZX0_HORA    := ZX0QRY->ZX0_HORA
		TempZX0->ZX0_TOTCR   := ZX0QRY->ZX0_TOTCR
		TempZX0->ZX0_TOTDB   := ZX0QRY->ZX0_TOTDB
		TempZX0->ZX0_ID      := ZX0QRY->CT2_P_ID


		TempZX0->(MsUnlock())		
	
	
    	ZX0QRY->(DbSkip())
   
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
  
DbSelectArea("TempZX0")   
TempZX0->(DbGoTop())  
While TempZX0->(!EOF())
	
	RecLock("TempZX0",.F.)     
 	If TempZX0->cINTEGRA == cMarca
  		TempZX0->cINTEGRA:=Space(02)   
    Else
    	TempZX0->cINTEGRA:= cMarca
    EndIf 
    TempZX0->(MsUnlock())
    TempZX0->(DbSkip())

EndDo         
TempZX0->(DbGoTop())      
      
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
           
Local lRet     :=.F. 
Local cArq     := "%('" 

	DbSelectArea("TempZX0")   
	TempZX0->(DbGoTop())  
	While TempZX0->(!EOF())
		    
		//Verifica os arquivos selecionados
	 	If !Empty(TempZX0->cINTEGRA)
	                 
		 	If !(alltrim(cArq) == "%('")
	   			cArq+="','"	
	      	EndIf
	        
	       	cArq +=Alltrim(TempZX0->ZX0_ARQ)     
			
			lRet:=.T.
	
	    EndIf 
	    
	  	TempZX0->(DbSkip()) 
	  	
	EndDo 

	cArq+="')%"   
	
	If Select("CT2QRY") > 0
		CT2QRY->(dbCloseArea())
	Endif 


	//Seleciona lançamentos de acordo com o arquivo selecionado
	BeginSql Alias 'CT2QRY'                               
	
		SELECT *
	 	FROM %Table:CT2%
	       WHERE %notDel%
	       AND CT2_FILIAL = %exp:xFilial("CT2")%  
	       AND CT2_P_ARQ IN %exp:cArq%  
	       AND CT2_MOEDLC IN ('04')      
	       AND CT2_DATA > '20121130' // Lançamentos antigos não devem ser mostradas.
	
	       ORDER BY CT2_P_ARQ,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_LINHA,CT2_DOC
	       
	EndSql
	
	CT2QRY->(DbGoTop())
	If !(CT2QRY->(!BOF() .and. !EOF()))
		MsgStop("Não foi encontrado lançamentos para esse arquivo, entrar em contato com a TI.","PayPal")
	    lRet :=.F.
	 	Return lRet
	EndIf

	If lRet
		
		If !(MsgYesNO("Deseja realmente limpar esse(s) arquivo(s) do(s) lançamento(s)","Paypal"))
	    	lRet:=.F.
		EndIf
	EndIf
	
	       
	TempZX0->(DbGoTop())      
      
Return lRet

                                	
/*
Funcao      : PBCTB02C
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para visualizar os lançamentos do arquivo selecionado
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012 
Obs         :
*/              
                                                            
*---------------------------*
  Static Function PBCTB02C()  
*---------------------------*

// Variáveis para o Arquivo Temporario
Local cChave	:= ""
Local cArqTrb	:= ""
Local cArq      := "%('"  
Local cFunLeg   := "" 							// Função que deverá retornar um valor lógico e com isso será atribuído semafóro na primeira coluna do browse
Local cTopFun   := "" 							// Mostrar os registros com a chave de
Local cBotFun   := "" 							// Mostrar os registros com a chave ate
Local cTitulo   := "Lançamentos do arquivo"		// Título obrigatório
Local cAlias    := "TRB" 						// Alias da tabela corrente podendo ser TRB
Local cSeek     := ""							// Chave principal para a busca, exemplo: xFilial("???")

Local aStruTRB  := {}                           // Array da estrutura
Local aResource := {}							// aAdd(aResource,{"IMAGEM","Texto significativo"})
Local aPesqui   := {}

Local lCentered := .T.							// Valor verdadeiro centraliza
Local lSavOrd   := .F. 							// Estabelecer a ordem após pesquisas.
Local lRet      := .F.  						// Retorno da função 
Local lDic      := .F. 							// Parâmetro em conjunto com aCampos
Local lEnchBar  := .F. 							// Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao   := .F.						    // Se a janela deve respeitar as medidas padrões do //Protheus (.T.) ou usar o máximo disponível (.F.)

Local nMinY	    := 400 							// Altura mínima da janela
Local nModelo   := 1 					   	 	// 1- Menu do aRotina  

Local aSize		:= MsAdvSize(lEnchBar, lPadrao, nMinY)

  
Private cCadastro := " "
Private aCpos	  := {}
Private aRotina   := {} // Idêntico ao aRotina para mBrowse     

	If Select("CT2QRY") > 0
		CT2QRY->(dbCloseArea())
	Endif 
	
	If Select("TempCT2") > 0
		TempCT2->(dbCloseArea())
	Endif

	If Select("TRB") > 0
		TRB->(dbCloseArea())
	Endif 

	DbSelectArea("TempZX0")   
	TempZX0->(DbGoTop())  
	While TempZX0->(!EOF())		    
		//Verifica os arquivos selecionados
	 	If !Empty(TempZX0->cINTEGRA)  
	 	
	 		If !(alltrim(cArq) == "%('")
        		cArq+="','"	
       		EndIf
        
       		cArq +=Alltrim(TempZX0->ZX0_ARQ)     
       		              
			lRet:=.T.
	    EndIf 
	    
	  	TempZX0->(DbSkip()) 
	  	
	EndDo 
	
	TempZX0->(DbGoTop())  
	
	cArq+="')%"   
	
	If !(lRet) 
	    MsgStop("Selecione pelo menos um arquivo para visualizar os lançamentos","Paypal")
		Return lret
	EndIf  
 	
 	AADD(aStruTRB, {"TRB_FILIAL" ,"C",02,0})    
	Aadd(aStruTRB, {"TRB_P_ARQ" ,"C",30  ,0})   
	Aadd(aStruTRB, {"TRB_DATA"  ,"D",8   ,0}) 
	Aadd(aStruTRB, {"TRB_LOTE"  ,"C",6   ,0})
	Aadd(aStruTRB, {"TRB_SBLOTE","C",3   ,0})   
	Aadd(aStruTRB, {"TRB_DOC"   ,"C",6   ,0}) 
	Aadd(aStruTRB, {"TRB_LINHA" ,"C",3   ,0})
	Aadd(aStruTRB, {"TRB_DC"    ,"C",1   ,0})   
	Aadd(aStruTRB, {"TRB_DEBITO","C",20  ,0}) 
	Aadd(aStruTRB, {"TRB_CREDIT","C",20  ,0})
	Aadd(aStruTRB, {"TRB_VALOR" ,"N",17  ,2})   
	Aadd(aStruTRB, {"TRB_HIST"  ,"C",40  ,0}) 
	Aadd(aStruTRB, {"TRB_CCD"   ,"C",9   ,0})
	Aadd(aStruTRB, {"TRB_CCC"   ,"C",9   ,0})   
	Aadd(aStruTRB, {"TRB_ITEMD" ,"C",9   ,0}) 
	Aadd(aStruTRB, {"TRB_ITEMC" ,"C",9   ,0})
	Aadd(aStruTRB, {"TRB_CLVLDB","C",9   ,0})   
	Aadd(aStruTRB, {"TRB_CLVLCR","C",9   ,0})
	Aadd(aStruTRB, {"TRB_MOEDLC","C",2   ,0})

	Aadd(aCpos, {"TRB_FILIAL" ,"@!","Filial"    			 ,02,"C",".F.",.T.}) 
	Aadd(aCpos, {"TRB_P_ARQ"  ,"@!","Arquivo"    			 ,30,"C",".T.",.T.}) 
	Aadd(aCpos, {"TRB_DATA"   ,"@!","Dt Lcto"     		 	 ,08,"C",".T.",.T.}) 
	Aadd(aCpos, {"TRB_LOTE"   ,"@!","Nr. Lote"     		 	 ,06,"C",".T.",.T.})                              
	Aadd(aCpos, {"TRB_SBLOTE" ,"@!","Sub. Lote"   			 ,03,"C",".T.",.T.})
	Aadd(aCpos, {"TRB_DOC"    ,"@!","Documento"   			 ,06,"C",".T.",.T.})	
	Aadd(aCpos, {"TRB_LINHA"  ,"@!","Seq. Lcto"   			 ,03,"C",".T.",.T.})
	Aadd(aCpos, {"TRB_DC"     ,"@!","Tipo Lcto"   			 ,01,"C",".T.",.T.})
	Aadd(aCpos, {"TRB_DEBITO" ,"@!","Cta Debito"  			 ,20,"C",".T.",.T.})		
	Aadd(aCpos, {"TRB_CREDIT" ,"@!","Cta Credito" 			 ,20,"C",".T.",.T.})
	Aadd(aCpos, {"TRB_VALOR"  ,"@E 999,999,999.99","Valor"   ,17,"N",".T.",.F.})     				
	Aadd(aCpos, {"TRB_HIST"   ,"@!","Historico"   			 ,40,"C",".T.",.T.})
	Aadd(aCpos, {"TRB_CCD"    ,"@!","C Custo Deb."			 ,09,"C",".T.",.T.})		
	Aadd(aCpos, {"TRB_CCC"    ,"@!","C Custo Cred."		     ,09,"C",".T.",.T.}) 
	Aadd(aCpos, {"TRB_ITEMD"  ,"@!","Item C Deb."            ,09,"C",".T.",.T.})				
	Aadd(aCpos, {"TRB_ITEMC"  ,"@!","Item C Cred." 			 ,09,"C",".T.",.T.}) 
	Aadd(aCpos, {"TRB_CLVLDB" ,"@!","Clasee V Deb."			 ,09,"C",".T.",.T.})		
	Aadd(aCpos, {"TRB_CLVLCR" ,"@!","Classe V Cred."		 ,09,"C",".T.",.T.}) 
	Aadd(aCpos, {"TRB_MOEDLC" ,"@!","Moeda Lancto"			 ,02,"C",".T.",.T.})  
	  
		                          
	cArqTrb		:= CriaTrab(aStruTRB,.t.)
	dbUseArea(.T.,,cArqTrb,"TRB",.T.,.F.)
	
	cChave 		:= "TRB_FILIAL+TRB_P_ARQ"
	IndRegua("TRB",cArqTrb,cChave,,,"Selecionando Registros...")  
	
	
	//Seleciona lançamentos de acordo com o arquivo selecionado
	BeginSql Alias 'CT2QRY'                               
	
		SELECT *
	 	FROM %Table:CT2%
	       WHERE %notDel%
	       AND CT2_FILIAL = %exp:xFilial("CT2")%  
	       AND CT2_P_ARQ IN %exp:cArq%  
	       AND CT2_MOEDLC IN ('04')      
	       AND CT2_DATA > '20121130' // Lançamentos antigos não devem ser mostradas.
	
	       ORDER BY CT2_P_ARQ,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_LINHA,CT2_DOC
	       
	EndSql
	
	CT2QRY->(DbGoTop())
	If !(CT2QRY->(!BOF() .and. !EOF()))
		MsgStop("Houve erro na busca de lançamentos desse arquivo, entrar em contato com a TI.","PayPal")
	 	Return .F.
	EndIf


    CT2QRY->(DbGoTop())
	While CT2QRY->(!EOF())
                                  
		RecLock("TRB",.T.)
		TRB->TRB_FILIAL  := CT2QRY->CT2_FILIAL
		TRB->TRB_P_ARQ   := CT2QRY->CT2_P_ARQ
		TRB->TRB_DATA    := SToD(CT2QRY->CT2_DATA)
		TRB->TRB_LOTE    := CT2QRY->CT2_LOTE
		TRB->TRB_SBLOTE  := CT2QRY->CT2_SBLOTE
		TRB->TRB_DOC     := CT2QRY->CT2_DOC
		TRB->TRB_LINHA   := CT2QRY->CT2_LINHA
		TRB->TRB_DC      := CT2QRY->CT2_DC
		TRB->TRB_DEBITO  := CT2QRY->CT2_DEBITO
		TRB->TRB_CREDIT  := CT2QRY->CT2_CREDIT
		TRB->TRB_VALOR   := CT2QRY->CT2_VALOR
		TRB->TRB_HIST    := CT2QRY->CT2_HIST
		TRB->TRB_CCD     := CT2QRY->CT2_CCD
		TRB->TRB_CCC     := CT2QRY->CT2_CCC
		TRB->TRB_ITEMD   := CT2QRY->CT2_ITEMD
		TRB->TRB_ITEMC   := CT2QRY->CT2_ITEMC
		TRB->TRB_CLVLDB  := CT2QRY->CT2_CLVLDB
		TRB->TRB_CLVLCR  := CT2QRY->CT2_CLVLCR
		TRB->TRB_MOEDLC  := CT2QRY->CT2_MOEDLC
		TRB->(MsUnlock())		
	
	
    	CT2QRY->(DbSkip())
   
	EndDo    
	
	Aadd(aPesqui,{"Filial + arquivo",1})
	
	TRB->(DbGoTop())
	dbSelectArea( "TRB" )
	MaWndBrowse(aSize[7],aSize[2],aSize[6],aSize[5],cTitulo,cAlias,aCpos,aRotina,,,,.T.,,,aPesqui,"",.F.)
	
	TRB->(DbGoTop())

	
	If Select("TRB") > 0
		TRB->(dbCloseArea())
	Endif 
	
	
Return

                                  

/*
Funcao      : PBCTB02D
Parametros  : cMsg
Retorno     : Nenhum
Objetivos   : Funcão para enviar email de notificação
Autor     	: Tiago Luiz Mendonça
Data     	: 18/12/2012 
Obs         :
*/              
                                                            
*-------------------------------*
  Static Function PBCTB02D(cMsg)  
*-------------------------------*

Local cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount  := AllTrim(GetNewPar("MV_RELACNT"," "))
Local cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))
Local cFrom 	:= AllTrim(GetNewPar("MV_RELFROM"," "))

Local lOk      	:= .F.

Local cTo       := ""
Local cEmail    := ""
Local cSubject  := ""
Local cAnexos   := ""    
Local cC        := ""     

Local aUsers    :=AllUsers()

Local nPos      := 0    

	//Nao será mais usado parametro pois existe problema no envio de anexo para mais de uma pessoa.
	//AllTrim(GetNewPar("MV_P_EMAIL"," ")) 

	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
   		cTo := Alltrim(aUsers[nPos,1,14])
	EndIf
 

	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
 	cEmail += '<title>Notificao</title></head><body>'
  	cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
    cEmail += '<br>'   
    cEmail += '<br>'   
   	cEmail += 'Noficacao da execucao da rotina de exclusao de arquivos de lançamento do cliente Paypal </b></u></font></p>'   
   	    

    cEmail += '<br>'   
    cEmail += '<br>' 
    
    cSubject:= "Noficacao da execucao da rotina de exclusao de arquivos de lancamento do cliente Paypal "      

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
    
    
         
    CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk      

   	If lOk                                          	
	        	  
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cEmail ATTACHMENT cAnexos Result lOk  

   	EndIf

   	DISCONNECT SMTP SERVER 
	
Return	
	