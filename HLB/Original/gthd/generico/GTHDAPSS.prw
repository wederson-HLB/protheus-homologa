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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDAPSS  ºAutor  Tiago Luiz Mendonça  º Data ³  25/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de atualização sigapss                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDAPSS()
Objetivos   : Rotina de atualização sigapss.spf
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/

*-----------------------------*
   User function GTHDAPSS()   
*-----------------------------* 

Local cPswFile 		:= "sigapss.spf"
Local cVar1			:= ""   
Local cVar2			:= ""   
Local cVar3			:= ""   
Local cVar4			:= ""   


Local  oTodos, oP11_01, oP11_02, oP11_03, oP11_04, oP11_05, oP11_06, oP11_07, oP11_08, oP11_09, oP11_10, oP11_11, oP11_12, oP11_13, oP11_14, oP11_15, oP11_16, oP11_17, oP11_18, oP11_19, oP11_20  

Local bCkTodos	:= {||  lTodos  :=.T., lP11_01 := .F.,lP11_02 := .F.,lP11_03 := .F.,lP11_04 := .F.,lP11_05 := .F.,lP11_06 := .F.,lP11_07 := .F. , lP11_08 := .F., lP11_09 := .F., lP11_10 := .F., lP11_11 := .F., lP11_12 := .F., lP11_13 := .F., lP11_14 := .F., lP11_15 := .F., lP11_16 := .F., lP11_17 := .F., lP11_18 := .F., lP11_19 := .F., lP11_20 := .F.  }

Local bCkP11_01	:= {||  lTodos  :=.F., lP11_01 := .T.  }
Local bCkP11_02	:= {||  lTodos  :=.F., lP11_02 := .T.  }
Local bCkP11_03	:= {||  lTodos  :=.F., lP11_03 := .T.  }
Local bCkP11_04	:= {||  lTodos  :=.F., lP11_04 := .T.  }
Local bCkP11_05	:= {||  lTodos  :=.F., lP11_05 := .T.  }
Local bCkP11_06	:= {||  lTodos  :=.F., lP11_06 := .T.  }
Local bCkP11_07	:= {||  lTodos  :=.F., lP11_07 := .T.  }
Local bCkP11_08	:= {||  lTodos  :=.F., lP11_08 := .T.  }
Local bCkP11_09	:= {||  lTodos  :=.F., lP11_09 := .T.  }
Local bCkP11_10	:= {||  lTodos  :=.F., lP11_10 := .T.  }
Local bCkP11_11	:= {||  lTodos  :=.F., lP11_11 := .T.  }
Local bCkP11_12	:= {||  lTodos  :=.F., lP11_12 := .T.  }
Local bCkP11_13	:= {||  lTodos  :=.F., lP11_13 := .T.  }
Local bCkP11_14	:= {||  lTodos  :=.F., lP11_14 := .T.  }
Local bCkP11_15	:= {||  lTodos  :=.F., lP11_15 := .T.  }
Local bCkP11_16	:= {||  lTodos  :=.F., lP11_16 := .T.  }
Local bCkP11_17	:= {||  lTodos  :=.F., lP11_17 := .T.  }
Local bCkP11_18	:= {||  lTodos  :=.F., lP11_18 := .T.  }
Local bCkP11_19	:= {||  lTodos  :=.F., lP11_19 := .T.  }
Local bCkP11_20	:= {||  lTodos  :=.F., lP11_20 := .T.  }

Local nTam      := 035

Local aAmbs:= {"P11_01","P11_02","P11_03","P11_04","P11_05","P11_06","P11_07","P11_08","P11_09","P11_10","P11_11","P11_12","P11_13","P11_14","P11_15","P11_16","P11_17","P11_18","P11_19","P11_20"}

Private lTodos:=.T.

Private lP11_01,lP11_02,lP11_03,lP11_04,lP11_05,lP11_06,lP11_07,lP11_08,lP11_09,lP11_10,lP11_11,lP11_12,lP11_13,lP11_14,lP11_15,lP11_16,lP11_17,lP11_18,lP11_19,lP11_20

Private oMain,oDlg,oSay,oSay1,oFont,oBtn,oDlgPrint        

  
	DEFINE MSDIALOG oDlgPrint TITLE "Selecione o ambiente" From 8,20 To 30,55 OF oMain     
    
         
        nLin1:=10  
    	nLin2:=80
      
      	nCol1:=15
      	nCol2:=133     
        
      	oDlg := TScrollBox():New( oDlgPrint,nLin1,nCol1-10,nLin2-4,nCol2-4,.T.,.T.,.T. )

                                                            
        oTodos:= TCheckBox():New(05,15,"Todos",,oDlg,nTam,008,,,,,CLR_BLUE,CLR_WHITE,,.T.,"",, )
		oTodos:cVariable := "lTodos"
		oTodos:bSetGet   :={|| lTodos }
		oTodos:bLClicked :={|| Eval(bCkTodos)}   
		
		 oBtn := TBtnBmp2():New( 10,180,26,26,'critica',,,,{|| BuscaAmb(.T.)},oDlg,"Configuração dos ambientes",,.T. )     
   	  	        
   	  	For i:=1 to Len(aAmbs)   
   	  	
   	  		nLin1+=10     
   	  		
   	  		cVar1:="o"+aAmbs[i]+":= TCheckBox():New("+Alltrim(str(nLin1))+","+Alltrim(str(nCol1))+",'"+aAmbs[i]+"',,oDlg,"+alltrim(str(nTam))+",008,,,,,,,,.T.,'',, )"
			 &(cVar1)
			cVar2:="o"+aAmbs[i]+':cVariable := "l'+aAmbs[i]+'"'
  			 &(cVar2)
			cVar3:="o"+aAmbs[i]+':bSetGet   :={|| l'+aAmbs[i]+' }'
  			 &(cVar3)
  			 cVar4:="o"+aAmbs[i]+':bLClicked :={|| Eval(bCk'+aAmbs[i]+')}'
  			 &(cVar4) 
  			 
  			 i++
  			 
  			 cVar1:="o"+aAmbs[i]+":= TCheckBox():New("+Alltrim(str(nLin1))+","+Alltrim(str(nCol1+50))+",'"+aAmbs[i]+"',,oDlg,"+alltrim(str(nTam))+",008,,,,,,,,.T.,'',, )"
			 &(cVar1)
			cVar2:="o"+aAmbs[i]+':cVariable := "l'+aAmbs[i]+'"'
  			 &(cVar2)
			cVar3:="o"+aAmbs[i]+':bSetGet   :={|| l'+aAmbs[i]+' }'
  			 &(cVar3)
  			 cVar4:="o"+aAmbs[i]+':bLClicked :={|| Eval(bCk'+aAmbs[i]+')}'
  			 &(cVar4)
  			 
  				  	
   	  	
   	  	Next
   	  	
 	  
  	  
		@ 90 , 5 TO 135,133 LABEL "" OF oDlgPrint PIXEL 
		  		
    	oSay  := TSay():Create(oDlgPrint,{||''},93,10,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,10)
		oSay:Refresh()   
		
		oSay1  := TSay():Create(oDlgPrint,{||''},113,10,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,10)
		oSay1:Refresh()
		
   		oFont := TFont():New('Courier new',,-12,.T.)   
   		
    	@ 140 , 5 TO 160,133 LABEL "" OF oDlgPrint PIXEL
     
     	@ 145 ,70 BMPBUTTON TYPE 1 ACTION(BuscaUser()) 
      	@ 145 ,100 BMPBUTTON TYPE 2 ACTION(oDlgPrint:End()) 
    
    ACTIVATE DIALOG oDlgPrint CENTERED ON INIT(oDlgPrint:Refresh())         
    
     
    

Return   

/*
Funcao      : BuscaUser()
Objetivos   : Rotina que busca os usuários em outros ambientes.
Autor       : Tiago Luiz Mendonça
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
 	oMeter := TMeter():New(102,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgPrint,120,10,,.T.)
 	
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
				
			oSay:cCaption:="Não foi possível conectar "+alltrim(aAmbs[i][3])
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
Autor       : Tiago Luiz Mendonça
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
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/

*--------------------------------*
  Static Function BuscaAmb(lTela)
*--------------------------------*     
Local aAmbs:={} 
Local oScreenConf 
Local nLin, nCol
Local cP11

Default lTela:=.F. 

cP11 :=" IP 10.0.30.20   , Port 5024, P11_XX , YY, 01 "

If lTodos   
   
	//(cIp,nPort,cAmbiente,cEmp,cFil)
	aAdd(aAmbs,{"10.0.30.20","5024","P11_01","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_02","YY","01"})
   	aAdd(aAmbs,{"10.0.30.20","5024","P11_03","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_04","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_05","YY","01"}) 
	aAdd(aAmbs,{"10.0.30.20","5024","P11_06","YY","01"})	
	aAdd(aAmbs,{"10.0.30.20","5024","P11_07","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_08","YY","01"}) 
	aAdd(aAmbs,{"10.0.30.20","5024","P11_09","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_10","YY","01"})
   	aAdd(aAmbs,{"10.0.30.20","5024","P11_11","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_12","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_13","YY","01"}) 
	aAdd(aAmbs,{"10.0.30.20","5024","P11_14","YY","01"})	
	aAdd(aAmbs,{"10.0.30.20","5024","P11_15","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_16","YY","01"}) 
	aAdd(aAmbs,{"10.0.30.20","5024","P11_17","YY","01"})	
	aAdd(aAmbs,{"10.0.30.20","5024","P11_18","YY","01"})
	aAdd(aAmbs,{"10.0.30.20","5024","P11_19","YY","01"}) 
	
Else  

	If lP11_01
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_01","YY","01"})
	EndIf

	If lP11_02
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_02","YY","01"})
	EndIf

	If lP11_03
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_03","YY","01"})
	EndIf

	If lP11_04
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_04","YY","01"})
	EndIf

	If lP11_05
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_05","YY","01"})
	EndIf

	If lP11_06
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_06","YY","01"})
	EndIf

	If lP11_07
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_07","YY","01"})
	EndIf

	If lP11_08
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_08","YY","01"})
	EndIf

	If lP11_09
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_09","YY","01"})
	EndIf

	If lP11_10
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_10","YY","01"})
	EndIf

	If lP11_11
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_11","YY","01"})
	EndIf

	If lP11_12
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_12","YY","01"})
	EndIf

	If lP11_13
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_13","YY","01"})
	EndIf

	If lP11_14
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_14","YY","01"})
	EndIf
	
	If lP11_15
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_15","YY","01"})
	EndIf                                                   

	If lP11_16
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_16","YY","01"})
	EndIf
	
	If lP11_17
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_17","YY","01"})
	EndIf

	If lP11_18
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_18","YY","01"})
	EndIf

	If lP11_19
   		aAdd(aAmbs,{"10.0.30.20","5024","P11_19","YY","01"})
	EndIf
			
EndIf

If lTela
	
	DEFINE MSDIALOG oScreenConf TITLE "Configuração dos servidores" From 8,20 To 20,55 OF oMain
  		  		
  		nLin:=15
  		nCol:=15
  		
  		@ nLin     ,nCol Get cP11  PIXEL SIZE 110,6 When .F. OF oScreenConf  

  		  
 	ACTIVATE DIALOG oScreenConf CENTERED ON INIT(oScreenConf:Refresh())   

EndIf

Return aAmbs    

/*
Funcao      : CompUsers()
Objetivos   : Comparar os usários e incluir  
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/

*------------------------------------*
 Static Function CompUsers(aAtuUser)
*------------------------------------*
  
Local n,i   

Local aInclui := {}     
Local aUserHD := AllUsers()      
Local aAltera := {}

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
 	oMeter1 := TMeter():New(120,10,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},120,oDlgPrint,120,10,,.T.)
     
	oSay1:cCaption:="Atualizando usuários ..."
 	oSay1:Refresh() 
	
	oMeter1:SetTotal(len(aAtuUser))  
	
	// aUserHD  - Usuários do ambiente local     
    // aAtuUser - Usuários dos ambientes a serem importados 
    // aInclui  - Uusários que serão incluídos no ambiente local
    
	//Vetor com usuários de todos os ambientes.
	For n:=1 to len(aAtuUser)          
		//Loop dos usuários do ambiente  
		
		If Empty(aAtuUSer[1])
			Exit
		EndIf
		
		For i:=1 to len(aAtuUser[n])                    
		                          
			//Testa se o usuário existe no local.
   	  		If !(aScanX(aUserHD,{ |X,Y|  Upper(alltrim(X[1][2])) == Upper(alltrim(aAtuUser[n][i][1][2])) }) > 0 )
	  			//Testa se o usuário está bloqueado
	   			If !(aAtuUser[n][i][1][17])  //Não Bloqueado
	   				//Testa para não incluir duas vezes
	   				If  !(aScanX(aInclui,{ |X,Y|  Upper(alltrim(X[1][2])) == Upper(alltrim(aAtuUser[n][i][1][2])) }) > 0 )	                     
			    		aAdd(aInclui,aAtuUser[n][i])   
			    	EndIf		
                EndIf
	  		Else //Se existir verifica se está bloqueado                                                                                      
	  			If aAtuUser[n][i][1][17] .And. Alltrim(aAtuUser[n][i][1][1]) <> "000000"    //Bloqueado e administrador 
	  				//Testa para checar se não está bloqueado já  
	  				If (nPos:=aScanX(aUserHD,{ |X,Y|  Upper(alltrim(X[1][2])) == Upper(alltrim(aAtuUser[n][i][1][2])) })) > 0  	     
	  					If !(aUserHD[nPos][1][17]) // Não ta bloqueado 			                                                       
	  						If  !(nPos:=aScanX(aAltera,{ |X,Y|  Upper(alltrim(X[1][2])) == Upper(alltrim(aAtuUser[n][i][1][2])) }) > 0 )	                     
			    	  			aAdd(aAltera,aAtuUser[n][i])   
			       			EndIf
			       		EndIf	
			    	EndIf   		  
	   	 		EndIf

	  		EndIf
  		Next
  		
  		oMeter1:Set(n)				
	Next   
      

	SPF_CanOpen(cPswFile)
	
	For N:=1 to Len(aInclui)  
		
		//Procuro pelo usuario Base
   		nPswRec 					:= spf_Seek( cPswFile , "1U"+"000001" , 1 ) 

		//Obtenho as Informacoes do usuario Base ( retornadas por referencia na variavel cPswDet)
 		spf_GetFields( @cPswFile , @nPswRec , @cPswId , @cPswName , @cPswPwd , @cPswDet )

		//Converto o conteudo da string cPswDet em um Array
   		aPswDet 					:= Str2Array( @cPswDet , @lEncrypt )  
	    

		aPswDet[1][1]:= aInclui[n][1][1]                // C     Número de identificação seqüencial com o tamanho de 6 caracteres
		aPswDet[1][2]:= aInclui[n][1][2]   			    // C     Nome do usuário
		aPswDet[1][3]:= aInclui[n][1][3]   				// C     Senha (criptografada)
		aPswDet[1][4]:= aInclui[n][1][4]   				// C     Nome completo do usuário
		aPswDet[1][5]:= aInclui[n][1][5]   				// A     Vetor contendo as últimas n senhas do usuário
		aPswDet[1][6]:= aInclui[n][1][6]  				// D     Data de validade
		aPswDet[1][7]:= aInclui[n][1][7]   				// N     Número de dias para expirar
		aPswDet[1][8]:= aInclui[n][1][8]   	   			// L     Autorização para alterar a senha
		aPswDet[1][9]:= .T.    //aInclui[n][1][9]       // L     Alterar a senha no próximo logon
		aPswDet[1][10]:= aInclui[n][1][10]  			// A     Vetor com os grupos
		aPswDet[1][11]:= aInclui[n][1][11]  			// C     Número de identificação do superior
		aPswDet[1][12]:= aInclui[n][1][12]  			// C     Departamento
		aPswDet[1][13]:= aInclui[n][1][13]  			// C     Cargo
		aPswDet[1][14]:= aInclui[n][1][14]  			// C     E-mail
		aPswDet[1][15]:= aInclui[n][1][15]  			// N     Número de acessos simultâneos
		aPswDet[1][16]:= aInclui[n][1][16]  			// D     Data da última alteração
		aPswDet[1][17]:= aInclui[n][1][17]  			// L     Usuário bloqueado
		aPswDet[1][18]:= aInclui[n][1][18]  			// N     Número de dígitos para o ano
		aPswDet[1][19]:= aInclui[n][1][19]  			// L     Listner de ligações
		aPswDet[1][20]:= aInclui[n][1][20]  			// C     Ramal
		aPswDet[1][21]:= aInclui[n][1][21] 				// C     Log de operações
		aPswDet[1][22]:= aInclui[n][1][22]  			// C     Empresa, filial e matricula
		//aPswDet[1][23]:= aInclui[n][1][23]  			// A     Informações do sistema 
    		aPswDet[1][23][1]:= aInclui[n][1][23][1]  	// L     Permite alterar database do sistema
       		aPswDet[1][23][2]:= aInclui[n][1][23][2]    // N     Dias a retroceder
    		aPswDet[1][23][3]:= aInclui[n][1][23][3]    // N     Dias a avançar
		aPswDet[1][24]:= aInclui[n][1][24] 				// D     Data de inclusão no sistema
		aPswDet[1][25]:= aInclui[n][1][24] 				// C     Não usado
		aPswDet[1][26]:= aInclui[n][1][24] 				// U     Não usado   

        /*
		aPswDet[2][1]:= aInclui[n][2][1]   				// A    Vetor contendo os horários dos acessos. Cada elemento do vetor corresponde a um dia da semana com a hora inicial e final.
		aPswDet[2][2]:= aInclui[n][2][2]   				// N    Uso interno
		aPswDet[2][3]:= aInclui[n][2][3]   				// C    Caminho para impressão em disco
		aPswDet[2][4]:= aInclui[n][2][4]   				// C    Driver para impressão direto na porta. Ex: EPSON.DRV
		aPswDet[2][5]:= aInclui[n][2][5]   				// C    Acessos
		aPswDet[2][6]:= aInclui[n][2][6]   				// A    Vetor contendo as empresas, cada elemento contém a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
		aPswDet[2][7]:= aInclui[n][2][7]   				// C    Elemento alimentado pelo ponto de entrada USERACS
		aPswDet[2][8]:= aInclui[n][2][8]   				// N    Tipo de impressão: 1 - em disco, 2 - via Windows e 3 direto na porta
		aPswDet[2][9]:= aInclui[n][2][9]   				// N    Formato da página: 1 – retrato, 2 - paisagem
		aPswDet[2][10]:= aInclui[n][2][10] 				// N    Tipo de Ambiente: 1 – servidor, 2 - cliente
		aPswDet[2][11]:= aInclui[n][2][11] 				// L     Priorizar configuração do grupo
		aPswDet[2][12]:= aInclui[n][2][12] 				// C    Opção de impressão
		aPswDet[2][13]:= aInclui[n][2][13] 				// L    Acessar outros diretórios de impressão
  		
		For i:=1 to Len(aInclui[n][2])
			aPswDet[2][i] = aInclui[n][2][i]    
  		Next 
  			
  		//Testa o vetor com mais posições
  		If Len(aPswDet[3]) < Len(aInclui[n][3])  				
			//[n][3]  Vetor contendo o módulo, o nível e o menu do usuário. 
	   		For i:=1 to Len(aPswDet[3])
		   		aPswDet[3][i] = aInclui[n][3][i]    //  C  Exemplos >  "019\sigaadv\sigaatf.xnu"    "029\sigaadv\sigacom.xnu"
  			Next 
  		Else 
  			For i:=1 to Len(aInclui[n][3])
		   		aPswDet[3][i] = aInclui[n][3][i]    //  C  Exemplos >  "019\sigaadv\sigaatf.xnu"    "029\sigaadv\sigacom.xnu"
  			Next     		
  		EndIf	
          
		*/

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

	For N:=1 to Len(aAltera)  
                                                                              
		If ((nPos:=aScanX(aUserHD,{ |X,Y|  Upper(X[1][2]) == Upper(aAltera[n][1][2]) }))>  0  )                     
		
		
			//Procuro pelo usuario Base
   			nPswRec 					:= spf_Seek( cPswFile , "1U"+aUserHD[nPos][1][1], 1 ) 

			//Obtenho as Informacoes do usuario Base ( retornadas por referencia na variavel cPswDet)
 	   		spf_GetFields( @cPswFile , @nPswRec , @cPswId , @cPswName , @cPswPwd , @cPswDet )

	   		//Converto o conteudo da string cPswDet em um Array
   	   		aPswDet 					:= Str2Array( @cPswDet , @lEncrypt )  

			aPswDet[1][17]:= .T.				  			// L     Usuário bloqueado
	
			//Atribuindo o Novo user ID
			APSWDET_USER_ID				:= aUserHD[nPos][1][1]
	
	   		//Atribuindo o Nome do novo usuario
			APSWDET_USER_NAME			:= aUserHD[nPos][1][2]

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
   	    	//spf_Insert(cPswFile , "1U"+APSWDET_USER_ID , Upper("1U"+APSWDET_USER_NAME) , "1U"+APSWDET_USER_PWD , cPswDet )
          
        	SPF_Update(cPswFile,nPswRec ,"1U"+APSWDET_USER_ID , Upper("1U"+APSWDET_USER_NAME) , "1U"+APSWDET_USER_PWD , cPswDet)
                       
        	If !Empty(aAltera[n][01][02])
           		cText+=Alltrim(aAltera[n][01][02])+"  Bloqueado"+CHR(13)+CHR(10)
            EndIf 
                      
   		EndIf
   	
   	Next

	SPF_Close(cPswFile)
	 		
	If Empty(aAltera) .And. Empty(aInclui)  
	   
		oSay1:cCaption:="Nenhum usuário incluído."
 		oSay1:Refresh()
 		
 		cText:="Nenhum usuário incluído."
 		
 		//oTHButton := THButton():New(139,12,"                 ",oDlg,,55,30,,"Detalhes da inclusão")       
    
    Else 
    
    	If !Empty(aInclui)  
	   		oSay1:cCaption:=Alltrim(Str(Len(aInclui)))+" usuário(s) atualizados(s) com sucesso: "
 	   		oSay1:Refresh() 
        Else
        	oSay1:cCaption:=Alltrim(Str(Len(aAltera)))+" usuário(s) atualizados(s) com sucesso: "
 	   		oSay1:Refresh()        
        EndIf
	
	    oTHButton := THButton():New(141	,10,"Detalhes",oDlgPrint,{||EECVIEW(cText,"Usuários Atualizados e incluídos.") },55,20,,"Detalhes")
    
	EndIf   
	
/*
	
Return     
   
/*
Funcao      : GetNextUser()
Objetivos   : Buscar numeração disponível para inclusão no sigapss 
Autor       : Tiago Luiz Mendonça
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




