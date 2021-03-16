#include "rwmake.ch"
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"     
#include "tbiconn.ch"
#include "Totvs.ch" 

#DEFINE ID_USER_ADMINISTRATOR		"000000"
#DEFINE APSWDET_USER_ID				aPswDet[01][01]
#DEFINE APSWDET_USER_NAME			aPswDet[01][02]
#DEFINE APSWDET_USER_PWD			aPswDet[01][03]
#DEFINE APSWDET_USER_FULL_NAME		aPswDet[01][04]
#DEFINE APSWDET_USER_GROUPS			aPswDet[01][10]
#DEFINE APSWDET_USER_DEPARTMENT		aPswDet[01][12]
#DEFINE APSWDET_USER_JOB			aPswDet[01][13]
#DEFINE APSWDET_USER_MAIL			aPswDet[01][14]
#DEFINE APSWDET_USER_STAFF			aPswDet[01][22]
#DEFINE APSWDET_USER_DIR_PRINTER	aPswDet[02][03]
#DEFINE APSWDET_USER_MENUS			aPswDet[03]          

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GTHDAPSS  ∫Autor  Tiago Luiz MendonÁa  ∫ Data ≥  25/07/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Rotina de atualizaÁ„o sigapss                               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

/*
Funcao      : GTHDAPSS()
Objetivos   : Rotina de atualizaÁ„o sigapss.spf
Autor       : Tiago Luiz MendonÁa
Data/Hora   : 25/07/2011
*/

*-----------------------------*
   User function GTHDAPSS()   
*-----------------------------* 

Local cPswFile 		:= "sigapss.spf"
Local lOk           :=.F.

Local  oTodos, oAmb01, oAmb02, oAmb03, oGt01, oGt02, oGt03, oGtCorp     

Local bCkTodos:= {||  lTodos  :=.T., lAmb01 := .F.,lAmb02 := .F.,lAmb03 := .F.,lGT01 := .F.,lGT02 := .F.,lGT03 := .F.,lGTCorp := .F., }

Local bCkAmb01:= {||  lTodos  :=.F., lAmb01 := .T.  }
Local bCkAmb02:= {||  lTodos  :=.F., lAmb02 := .T.  }
Local bCkAmb03:= {||  lTodos  :=.F., lAmb03 := .T.  } 

Local bCkGt01:= {||  lTodos  :=.F., lGt01 := .T.  }
Local bCkGt02:= {||  lTodos  :=.F., lGt02 := .T.  }
Local bCkGt03:= {||  lTodos  :=.F., lGt03 := .T.  }

Local bCkGtCorp:= {|| lTodos  :=.F., lGtCorp := .T. }

Private lTodos:=.T.
Private lAmb01,lAmb02,lAmb03, lGT01,lGT02,lGT03,lGTCorp :=.F.   
Private oMain,oDlg,oSay,oSay1,oFont,oBtn        

  
	DEFINE MSDIALOG oDlg TITLE "Selecione o ambiente" From 8,20 To 30,55 OF oMain     
    
         
        @ 5,5 TO 26,133 LABEL "" OF oDlg PIXEL 
                                                            
        oTodos:= TCheckBox():New(10,15,"Todos",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oTodos:cVariable := "lTodos"
		oTodos:bSetGet   :={|| lTodos }
		oTodos:bLClicked :={|| Eval(bCkTodos)}   
		
		 oBtn := TBtnBmp2():New( 15,220,26,26,'critica',,,,{|| BuscaAmb(.T.)},oDlg,"ConfiguraÁ„o dos ambientes",,.T. )     
                  
   		@ 30,5 TO 86,133 LABEL "" OF oDlg PIXEL
   	  		          
        oAmb01:= TCheckBox():New(35,15,"Amb01",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oAmb01:cVariable := "lAmb01"
		oAmb01:bSetGet   :={|| lAmb01 }
		oAmb01:bLClicked :={|| Eval(bCkAmb01)}     
		
		oAmb02:= TCheckBox():New(50,15,"Amb02",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oAmb02:cVariable := "lAmb02"
		oAmb02:bSetGet   :={|| lAmb02 }
		oAmb02:bLClicked :={|| Eval(bCkAmb02)} 
		
		oAmb03:= TCheckBox():New(65,15,"Amb03",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oAmb03:cVariable := "lAmb03"
		oAmb03:bSetGet   :={|| lAmb03 }
		oAmb03:bLClicked :={|| Eval(bCkAmb03)}       

		oGt01:= TCheckBox():New(35,53,"GT01",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oGt01:cVariable := "lGt01"
		oGt01:bSetGet   :={|| lGt01 }
		oGt01:bLClicked :={|| Eval(bCkGt01)}    
		
		oGt02:= TCheckBox():New(50,53,"GT02",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oGt02:cVariable := "lGt02"
		oGt02:bSetGet   :={|| lGt02 }
		oGt02:bLClicked :={|| Eval(bCkGt02)}   	
			
		oGt03:= TCheckBox():New(65,53,"GT03",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oGt03:cVariable := "lGt03"
		oGt03:bSetGet   :={|| lGt03 }
		oGt03:bLClicked :={|| Eval(bCkGt03)}   			

		oGtCorp:= TCheckBox():New(35,82,"GTCorp",,oDlg,055,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oGtCorp:cVariable := "lGtCorp"
		oGtCorp:bSetGet   :={|| lGtCorp }
		oGtCorp:bLClicked :={|| Eval(bCkGtCorp)} 
		
		@ 90 , 5 TO 135,133 LABEL "" OF oDlg PIXEL 
		  		
    	oSay  := TSay():Create(oDlg,{||''},93,10,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,10)
		oSay:Refresh()   
		
		oSay1  := TSay():Create(oDlg,{||''},113,10,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,10)
		oSay1:Refresh()
		
   		oFont := TFont():New('Courier new',,-12,.T.)   
   		
    	@ 140 , 5 TO 160,133 LABEL "" OF oDlg PIXEL
     
     	@ 145 ,70 BMPBUTTON TYPE 1 ACTION(BuscaUser()) 
      	@ 145 ,100 BMPBUTTON TYPE 2 ACTION(oDlg:End()) 
    
    ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())         
    

Return   

/*
Funcao      : BuscaUser()
Objetivos   : Rotina que busca os usu·rios em outros ambientes.
Autor       : Tiago Luiz MendonÁa
Data/Hora   : 25/07/2011
*/

*-----------------------------*        
  Static Function BuscaUser()   
*-----------------------------*

Local aUsers,aAmbs
Local oFont
Local cIp,nPort,cAmbiente,cEmp,cFil  
Local latu:=.F. 

Local nMeter,oMeter

aUsers:={}
aAmbs :={}
          
    oSay:cCaption:="Preparando para atualizar ..."
   	oSay:Refresh()
	   	
	If !MsgYesNo("Deseja atualizar ?","HelpDesk")
 		oSay:cCaption:="Cancelado..."
   		oSay:Refresh()
    	Return .F. 
    EndIf
      
    //Barra de incremeto
	nMeter := 1
 	oMeter := TMeter():New(102,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg,120,10,,.T.)
 	
 	aAmbs:=BuscaAmb(.F.) 
	
	oMeter:SetTotal(len(aAmbs))       
        
  	For i:=1 to len(aAmbs)   
	        
		//RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil) 
		oServ:=  RpcConnect(aAmbs[i][1],Val(aAmbs[i][2]),aAmbs[i][3],aAmbs[i][4],aAmbs[i][5])        
		   	
  		If valtype(OsERV) == 'O'
			
			oSay:cCaption:="Buscando ambiente "+alltrim(aAmbs[i][3])
   			oSay:Refresh()
				
 			aAdd(aUsers,oServ:CALLPROC("U_USERSGT")  )
			
			RpcDisconnect(oServ)  
											
    		lAtu:=.T.
		    
		Else
				
			oSay:cCaption:="N„o foi poss˙ìel conectar "+alltrim(aAmbs[i][3])
			oSay:Refresh()  

			exit
	
		EndIf
			
		oMeter:Set(i)   
			
	Next			

	If lAtu   
		oSay:cCaption:="Conectado aos ambientes. "
   		oSay:Refresh()  
   		
   		CompUsers(aUsers)
   		
    EndIf


Return 

/*
Funcao      : USERSGT()
Objetivos   : Conectar em outros ambientes.
Autor       : Tiago Luiz MendonÁa
Data/Hora   : 25/07/2011
*/

*-------------------------------------------*
  User Function USERSGT(cEmp,cFil,cAmbiente)
*-------------------------------------------*

     
Local aList

	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil USER 'USRHD' PASSWORD 'hdgt@23' MODULO "FAT"  

		aList:=AllUsers() 
		
	RESET ENVIRONMENT	

Return aList 
           
/*
Funcao      : BuscaAmb()
Objetivos   : Selecionar os ambientes.
Autor       : Tiago Luiz MendonÁa
Data/Hora   : 25/07/2011
*/

*--------------------------------*
  Static Function BuscaAmb(lTela)
*--------------------------------*     

Local aAmbs:={} 
Local oScreenConf 
Local nLin, nCol
Local cAmb01,cAmb02,cAmb03,cGT01cGT02,cGT03,cGTCorp

Default lTela:=.F. 

cAmb01 :=" IP 10.0.30.4, Port 5024, Amb01 , YY, 01 "
cAmb02 :=" IP 10.0.30.4, Port 5024, Amb02 , YY, 01 "
cAmb03 :=" IP 10.0.30.4, Port 5024, Amb03 , YY, 01 "
cGT01  :=" IP 10.0.30.4, Port 5024, GT01  , YY, 01 "
cGT02  :=" IP 10.0.30.4, Port 5024, GT02  , YY, 01 "
cGT03  :=" IP 10.0.30.4, Port 5024, GT03  , YY, 01 " 
cGTCorp:=" IP 10.0.30.4, Port 5024, GTCorp, Z4, 05 "


If lTodos   
   
	//(cIp,nPort,cAmbiente,cEmp,cFil)

	aAdd(aAmbs,{"10.0.30.4","5024","Amb01" ,"YY","01"})
	aAdd(aAmbs,{"10.0.30.4","5024","Amb02" ,"YY","01"})
	aAdd(aAmbs,{"10.0.30.4","5024","Amb03" ,"YY","01"})
	aAdd(aAmbs,{"10.0.30.4","5024","GT01"  ,"YY","01"})
	aAdd(aAmbs,{"10.0.30.4","5024","GT02"  ,"YY","01"})
	aAdd(aAmbs,{"10.0.30.4","5024","GT03"  ,"YY","01"})
	aAdd(aAmbs,{"10.0.30.4","5024","GTCORP","Z4","05"})	

Else  

	If lAmb01
		aAdd(aAmbs,{"10.0.30.4","5024","Amb01" ,"YY","01"})
	EndIf

	If lAmb02
		aAdd(aAmbs,{"10.0.30.4","5024","Amb02" ,"YY","01"})
	EndIf
	
	If lAmb03
		aAdd(aAmbs,{"10.0.30.4","5024","Amb03" ,"YY","01"})
	EndIf
	
	If lGT01
		aAdd(aAmbs,{"10.0.30.4","5024","GT01" ,"YY","01"})
	EndIf  
	
	If lGT02
		aAdd(aAmbs,{"10.0.30.4","5024","GT02" ,"YY","01"})
	EndIf
		
	If lGT03
		aAdd(aAmbs,{"10.0.30.4","5024","GT03" ,"YY","01"})
	EndIf
	
	If lGTCORP
		aAdd(aAmbs,{"10.0.30.4","5024","GTCORP","Z4","05"})	
	EndIf


EndIf

If lTela
	
	DEFINE MSDIALOG oScreenConf TITLE "ConfiguraÁ„o dos servidores" From 8,20 To 30,55 OF oMain
  		
  		@ 5,5 TO 160,133 LABEL "" OF oScreenConf PIXEL   
  		
  		nLin:=15
  		nCol:=15
  		
  		@ nLin     ,nCol Get cAmb01  PIXEL SIZE 110,6 When .F. OF oScreenConf  
   		@ nLin+=020,nCol Get cAmb02  PIXEL SIZE 110,6 When .F. OF oScreenConf
   		@ nLin+=020,nCol Get cAmb03  PIXEL SIZE 110,6 When .F. OF oScreenConf
   		@ nLin+=020,nCol Get cGT01   PIXEL SIZE 110,6 When .F. OF oScreenConf
   		@ nLin+=020,nCol Get cGT02   PIXEL SIZE 110,6 When .F. OF oScreenConf 
  		@ nLin+=020,nCol Get cGT03   PIXEL SIZE 110,6 When .F. OF oScreenConf
  		@ nLin+=020,nCol Get cGTCorp PIXEL SIZE 110,6 When .F. OF oScreenConf      
  
 	ACTIVATE DIALOG oScreenConf CENTERED ON INIT(oScreenConf:Refresh())   

EndIf

Return aAmbs    

/*
Funcao      : CompUsers()
Objetivos   : Comparar os us·rios e incluir  
Autor       : Tiago Luiz MendonÁa
Data/Hora   : 25/07/2011
*/

*------------------------------------*
 Static Function CompUsers(aAtuUser)
*------------------------------------*
  
Local n,i   

Local aInclui := {}     
Local aUserHD := AllUsers()  

Local cPswDet := ""
Local cPswPwd := ""
Local cPswName:= ""
Local cPswId  := "" 
Local cNewPsw := "" 
Local cText   := "" 
Local cId     := ""
Local cPswFile:= "sigapss.spf"


Local cPswPwd,nPswRec,cOldPsw,cText

Local lEncrypt	:= .F.

Local nMeter1,oMeter1  
       
	nMeter1 := 1
 	oMeter1 := TMeter():New(120,10,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},120,oDlg,120,10,,.T.)
     
	oSay1:cCaption:="Atualizando usu·rios ..."
 	oSay1:Refresh() 
	
	oMeter1:SetTotal(len(aAtuUser))  
	
	// aUserHD  - Usu·rios do ambiente local     
    // aAtuUser - Usu·rios dos ambientes a serem importados 
    // aInclui  - Uus·rios que ser„o inclu˙Åos no ambiente local
    
	//Vetor com usu·rios de todos os ambientes.
	For n:=1 to len(aAtuUser)          
		//Loop dos usu·rios do ambiente  
		
		If Empty(aAtuUSer[1])
			Exit
		EndIf
		
		For i:=1 to len(aAtuUser[n])                    
		                          
			//Testa se o usu·rio existe no local.
   	  		If !(aScanX(aUserHD,{ |X,Y|  X[1][2] == aAtuUser[n][i][1][2] }) > 0 )
	  			//Testa se o usu·rio estÅEbloqueado
	   			If !(aAtuUser[n][i][1][17])
	   				//Testa para n„o incluir duas vezes
	   				If  !(aScanX(aInclui,{ |X,Y|  X[1][2] == aAtuUser[n][i][1][2] }) > 0 )	                     
			    		aAdd(aInclui,aAtuUser[n][i])   
			    	EndIf		
	   	 		EndIf
	  		EndIf
  		Next
  		
  		oMeter1:Set(n)				
	Next   

	SPF_CanOpen(cPswFile)
	
	For N:=1 to Len(aInclui)  
		
		//Procuro pelo usuario Base
   		nPswRec 					:= spf_Seek( cPswFile , "1U"+"000003" , 1 ) 

		//Obtenho as Informacoes do usuario Base ( retornadas por referencia na variavel cPswDet)
 		spf_GetFields( @cPswFile , @nPswRec , @cPswId , @cPswName , @cPswPwd , @cPswDet )

		//Converto o conteudo da string cPswDet em um Array
   		aPswDet 					:= Str2Array( @cPswDet , @lEncrypt )  
	    

		aPswDet[1][1]:= aInclui[n][1][1]                // C     N˙mero de identificaÁ„o seqÅEncial com o tamanho de 6 caracteres
		aPswDet[1][2]:= aInclui[n][1][2]   			    // C     Nome do usu·rio
		aPswDet[1][3]:= aInclui[n][1][3]   				// C     Senha (criptografada)
		aPswDet[1][4]:= aInclui[n][1][4]   				// C     Nome completo do usu·rio
		aPswDet[1][5]:= aInclui[n][1][5]   				// A     Vetor contendo as ˙ltimas n senhas do usu·rio
		aPswDet[1][6]:= aInclui[n][1][6]  				// D     Data de validade
		aPswDet[1][7]:= aInclui[n][1][7]   				// N     N˙mero de dias para expirar
		aPswDet[1][8]:= aInclui[n][1][8]   	   			// L     AutorizaÁ„o para alterar a senha
		aPswDet[1][9]:= .T.    //aInclui[n][1][9]       // L     Alterar a senha no prÛximo logon
		aPswDet[1][10]:= aInclui[n][1][10]  			// A     Vetor com os grupos
		aPswDet[1][11]:= aInclui[n][1][11]  			// C     N˙mero de identificaÁ„o do superior
		aPswDet[1][12]:= aInclui[n][1][12]  			// C     Departamento
		aPswDet[1][13]:= aInclui[n][1][13]  			// C     Cargo
		aPswDet[1][14]:= aInclui[n][1][14]  			// C     E-mail
		aPswDet[1][15]:= aInclui[n][1][15]  			// N     N˙mero de acessos simult‚neos
		aPswDet[1][16]:= aInclui[n][1][16]  			// D     Data da ˙ltima alteraÁ„o
		aPswDet[1][17]:= aInclui[n][1][17]  			// L     Usu·rio bloqueado
		aPswDet[1][18]:= aInclui[n][1][18]  			// N     N˙mero de d˙Ñitos para o ano
		aPswDet[1][19]:= aInclui[n][1][19]  			// L     Listner de ligaÁıes
		aPswDet[1][20]:= aInclui[n][1][20]  			// C     Ramal
		aPswDet[1][21]:= aInclui[n][1][21] 				// C     Log de operaÁıes
		aPswDet[1][22]:= aInclui[n][1][22]  			// C     Empresa, filial e matricula
		//aPswDet[1][23]:= aInclui[n][1][23]  			// A     InformaÁıes do sistema 
    		aPswDet[1][23][1]:= aInclui[n][1][23][1]  	// L     Permite alterar database do sistema
       		aPswDet[1][23][2]:= aInclui[n][1][23][2]    // N     Dias a retroceder
    		aPswDet[1][23][3]:= aInclui[n][1][23][3]    // N     Dias a avanÁar
		aPswDet[1][24]:= aInclui[n][1][24] 				// D     Data de inclus„o no sistema
		aPswDet[1][25]:= aInclui[n][1][24] 				// C     N„o usado
		aPswDet[1][26]:= aInclui[n][1][24] 				// U     N„o usado   

        /*
		aPswDet[2][1]:= aInclui[n][2][1]   				// A    Vetor contendo os hor·rios dos acessos. Cada elemento do vetor corresponde a um dia da semana com a hora inicial e final.
		aPswDet[2][2]:= aInclui[n][2][2]   				// N    Uso interno
		aPswDet[2][3]:= aInclui[n][2][3]   				// C    Caminho para impress„o em disco
		aPswDet[2][4]:= aInclui[n][2][4]   				// C    Driver para impress„o direto na porta. Ex: EPSON.DRV
		aPswDet[2][5]:= aInclui[n][2][5]   				// C    Acessos
		aPswDet[2][6]:= aInclui[n][2][6]   				// A    Vetor contendo as empresas, cada elemento contÈm a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
		aPswDet[2][7]:= aInclui[n][2][7]   				// C    Elemento alimentado pelo ponto de entrada USERACS
		aPswDet[2][8]:= aInclui[n][2][8]   				// N    Tipo de impress„o: 1 - em disco, 2 - via Windows e 3 direto na porta
		aPswDet[2][9]:= aInclui[n][2][9]   				// N    Formato da p·gina: 1 ÅEretrato, 2 - paisagem
		aPswDet[2][10]:= aInclui[n][2][10] 				// N    Tipo de Ambiente: 1 ÅEservidor, 2 - cliente
		aPswDet[2][11]:= aInclui[n][2][11] 				// L     Priorizar configuraÁ„o do grupo
		aPswDet[2][12]:= aInclui[n][2][12] 				// C    OpÁ„o de impress„o
		aPswDet[2][13]:= aInclui[n][2][13] 				// L    Acessar outros diretÛrios de impress„o
  		*/
		
		For i:=1 to Len(aInclui[n][2])
			aPswDet[2][i] = aInclui[n][2][i]    
  		Next 
  			
  		//Testa o vetor com mais posiÁıes
  		If Len(aPswDet[3]) < Len(aInclui[n][3])  				
			//[n][3]  Vetor contendo o mÛdulo, o n˙ìel e o menu do usu·rio. 
	   		For i:=1 to Len(aPswDet[3])
		   		aPswDet[3][i] = aInclui[n][3][i]    //  C  Exemplos >  "019\sigaadv\sigaatf.xnu"    "029\sigaadv\sigacom.xnu"
  			Next 
  		Else 
  			For i:=1 to Len(aInclui[n][3])
		   		aPswDet[3][i] = aInclui[n][3][i]    //  C  Exemplos >  "019\sigaadv\sigaatf.xnu"    "029\sigaadv\sigacom.xnu"
  			Next     		
  		EndIf	

		//Atribuindo o Novo user ID
		APSWDET_USER_ID				:= GetNextUser(aUserHD) 
	
		//Atribuindo o Nome do novo usuario
		APSWDET_USER_NAME			:= aInclui[n][01][02]

		//Decriptando a senha antiga para obter o tamanho valido para a senha
   	    cOldPsw						:= "123456"
   
		//Encriptando a senha para o novo usuario
		cNewPsw	 					:= PswEncript(cOldPsw,0)

		//Atribuindo a nova senha ao novo usuario
		APSWDET_USER_PWD			:= cNewPsw

		//Atribuindo o nome completo ao novo usuario
   		//APSWDET_USER_FULL_NAME		:= aInclui[i][01][04]

		//Atribuindo o Departamento ao novo usuario
   		//APSWDET_USER_DEPARTMENT		:= aInclui[i][01][12]
   	
   		//Atribuindo o cargo ao novo usuario
   		//APSWDET_USER_JOB			:= aInclui[i][01][13]

   		//Atribuindo o email ao novo usuario
   		//APSWDET_USER_MAIL			:= aInclui[i][01][14]

   		//Atribuindo o vinculo funcional ao novo usuario
   		//APSWDET_USER_STAFF			:= cEmpAnt+cFilAnt+APSWDET_USER_ID

		//Atribuindo o diretorio de impressao ao novo usuario
   		//APSWDET_USER_DIR_PRINTER    := "\SPOOL\"+APSWDET_USER_NAME

   		//Convertendo as informacoes no novo usuario para gravacao
   		cPswDet						:= Array2Str( @aPswDet , @lEncrypt )

   		//Incluindo o novo usuario
   		spf_Insert(cPswFile , "1U"+APSWDET_USER_ID , Upper("1U"+APSWDET_USER_NAME) , "1U"+APSWDET_USER_PWD , cPswDet )
        
        cText+=Alltrim(aInclui[n][01][02])+CHR(13)+CHR(10)
                      
   	Next

	SPF_Close(cPswFile)
	 		
	If Empty(aInclui) 
	   
		oSay1:cCaption:="Nenhum usu·rio inclu˙Åo."
 		oSay1:Refresh()
 		
 		cText:="Nenhum usu·rio inclu˙Åo."
 		
 		//oTHButton := THButton():New(139,12,"                 ",oDlg,,55,30,,"Detalhes da inclus„o")       
    
    Else 
		oSay1:cCaption:=Alltrim(Str(Len(aInclui)))+" usu·rio(s) inclu˙Åo(s) com sucesso: "
 		oSay1:Refresh() 

	    oTHButton := THButton():New(141	,10,"Detalhes da inclus„o",oDlg,{||EECVIEW(cText,"Usu·rios inclu˙Åos.") },55,20,,"Detalhes da inclus„o")
    
	EndIf   
	
Return     
   
/*
Funcao      : GetNextUser()
Objetivos   : Buscar numeraÁ„o dispon˙ìel para inclus„o no sigapss 
Autor       : Tiago Luiz MendonÁa
Data/Hora   : 25/07/2011
*/

*---------------------------------------*
  Static Function GetNextUser(aAllUsers) 
*---------------------------------------* 

Local bPswSeek  := ( {||  PswSeek(@cUser)} ) 
Local cUser     := "000000"

 
While Eval(bPswSeek)
	cUser := soma1(cUser)
EndDo
          
Return Alltrim(cUser)




