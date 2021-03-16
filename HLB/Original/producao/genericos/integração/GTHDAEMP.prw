#include "rwmake.ch"
#include "Totvs.ch" 
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDAEMP  ºAutor  Tiago Luiz Mendonça  º Data ³  04/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de atualização sigapss                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


/*
Funcao      : GTHDAEMP()
Objetivos   : Rotina de atualização sigapss.spf
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/   

*-----------------------------*
   User function GTHDAEMP()   
*-----------------------------* 

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
		
		 oBtn := TBtnBmp2():New( 15,220,26,26,'critica',,,,{|| BuscaAmb(.T.)},oDlg,"Configuração dos ambientes",,.T. )     
                  
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
     
     	@ 145 ,70 BMPBUTTON TYPE 1 ACTION(BuscaEmp()) 
      	@ 145 ,100 BMPBUTTON TYPE 2 ACTION(oDlg:End()) 
    
    ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())         
    

Return  

/*
Funcao      : BuscaUser()
Objetivos   : Rotina que busca os usuários em outros ambientes.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/

*-----------------------------*        
  Static Function BuscaEmp()   
*-----------------------------*

Local aEmp,aAmbs
Local oFont
Local cIp,nPort,cAmbiente,cEmp,cFil  
Local latu:=.F. 

Local nMeter,oMeter

aEmp  :={}
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
				
 			aAdd(aEmp,oServ:CALLPROC("U_GTSM0EMP"))
			
			lAtu:=.T.
		    
		Else
				
			oSay:cCaption:="Não foi possú“el conectar "+alltrim(aAmbs[i][3])
			oSay:Refresh()  

			exit
	
		EndIf
			
		oMeter:Set(i)   
			
	Next			

	If lAtu   
		oSay:cCaption:="Conectado aos ambientes. "
   		oSay:Refresh()  
   		
   		CompEmp(aEmp)
   		
    EndIf


Return 

/*
Funcao      : GTSM0EMP()
Objetivos   : Conectar em outros ambientes.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/

*---------------------------------------------*
  User Function GTSM0EMP(cEmp,cFil,cAmbiente)
*---------------------------------------------*

Local bCampo   
Local aSM0:={}


	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil USER 'USRHD' PASSWORD 'hdgt@23' MODULO "FAT"  


		SM0->(DbGoTop())

		While SM0->(!Eof())
	         
			If !Empty(SM0->M0_CGC)
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_NOMECOM,SM0->M0_CGC,GetEnvServer()})
			EndIf
   	         			
			SM0->(DbSkip())
	
		EndDo 
		
	RESET ENVIRONMENT	

Return aSM0   

/* 
Funcao      : GTSA1COD()
Objetivos   : Tela para atualização de clientes.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/08/2011
*/                        

*--------------------------------------------*
  User Function GTSA1COD(cEmp,cFil,cAmbiente)
*---------------------------------------------*


Private oSay2,oServ,oMain,oFont,oAtuSA1 
 
DEFINE MSDIALOG oAtuSA1 TITLE "Atualização de código de cliente" From 4,10 To 15,40 OF oMain     
    
    @ 5,5  TO 25,115 LABEL "" OF oAtuSA1 PIXEL    
    @ 30,5 TO 50,115 LABEL "" OF oAtuSA1 PIXEL      
    @ 55,5 TO 80,115 LABEL "" OF oAtuSA1 PIXEL
   	
   	oFont := TFont():New('Courier new',,-12,.T.)  
                                    
	oSay2:= TSay():Create(oAtuSA1,{||'Atualização código cliente'},10,10,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,150,10)
	oSay2:Refresh()	
	
                                                              
	@ 062 ,35 BMPBUTTON TYPE 1 ACTION(AtuSA1()) 
 	@ 062 ,65 BMPBUTTON TYPE 2 ACTION(oAtuSA1:End()) 
    
  ACTIVATE DIALOG oAtuSA1 CENTERED ON INIT( oAtuSA1:Refresh())         
    
    
 
 Return 
 
/* 
Funcao      : AtuSA1()
Objetivos   : Buscar códigos de clientes no ambiente GTCorp
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/08/2011
*/                        

*---------------------------*
  Static Function AtuSA1()
*---------------------------*

Local aSA1  :={}     
Local lAtu  :=.F. 
Local cText	:=""   
Local nMeter1,oMeter1  
       
If !(MsgYesNo("Deseja atualizar todos os códigos de clientes"))
	Return .f.    
EndIf 
       
 nMeter1 := 1
oMeter1 := TMeter():New(35,12,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},120,oAtuSA1,95,10,,.T.)
 
//RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil) 
oServ:=  RpcConnect("10.0.30.4",5024,"GTCORP","Z4","05")  
     		   	
If valtype(OsERV) == 'O'
			
	oSay2:cCaption:="Conectando ao ambiente GTCorp"
	oSay2:Refresh()
				
	aAdd(aSA1,oServ:CALLPROC("U_GTGETSA1"))
	  			
Else    

	oSay2:cCaption:="Não conectou ao ambiente GT"
	oSay2:Refresh()

EndIf       

If lAtu 
 
	oSay2:cCaption:="Atualizando códigos ..."
 	oSay2:Refresh() 
	
	oMeter1:SetTotal(len(aSA1))  
	
	If Empty(aSA1)
 		Return .F.
	EndIf
       
    n:=0
	//Vetor com todas as empresas.
	For i:=1 to len(aSA1)          
	                            
	     // 1.A1_COD,2.A1_NOME,3.A1_NREDUZ,4.A1_CGC        
	             
		Z04->(DbSetOrder(2))
		If Z04->(DbSeek(aSA1[i][4]))
		   
			RecLock("Z04",.F.)
			Z04->Z04_CODTEL :=Substr(Alltrim(aSA1[i][4]),2,4)                                                                                             
			Z04->(MsUnlock()) 
			
			cText+="Atualizado : "+Alltrim(aSA1[i][2])+CHR(13)+CHR(10)			      
	         
	      	n++
	      	
	    EndIf                           

		oMeter1:Set(i)				
	Next    
	
	If Empty(alltrim(cText)) 
	   
		oSay2:cCaption:="Nenhuma empresa atualizada."
 		oSay2:Refresh()
 		
 		cText:="Nenhuma empresa atualizada."
 		
 		oTHButton := THButton():New(139,12,"                 ",oTelaSA1,,55,30,,"Detalhes da atualização")       
    
    Else           
    
		oSay1:cCaption:=Alltrim(Str(n))+" empresas atualizadas com sucesso: "
 		oSay1:Refresh() 

	    oTHButton := THButton():New(141	,10,"Detalhes da inclusão",oAtuSA1,{||EECVIEW(cText,"Empresas atualizadas.") },55,20,,"Detalhes da atualização")
    
	EndIf   


EndIf


Return
        
/* 
Funcao      : GTGETSA1()
Objetivos   : Conectar em outros ambientes.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/08/2011
*/


*---------------------------------------------*
  User Function GTGETSA1(cEmp,cFil,cAmbiente)
*---------------------------------------------*

Local bCampo   
Local aSA1:={}


	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil USER 'USRHD' PASSWORD 'hdgt@23' MODULO "FAT"  


		SA1->(DbGoTop())

		While SA1->(!Eof())
	         
			Aadd(aSA1,{SA1->A1_COD,SA1->A1_NOME,SA1->A1_NREDUZ,SA1->A1_CGC})
   	         			
			SA1->(DbSkip())
	
		EndDo 
		
	RESET ENVIRONMENT	

Return aSA1  



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
	
	DEFINE MSDIALOG oScreenConf TITLE "Configuração dos servidores" From 8,20 To 30,55 OF oMain
  		
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
Funcao      : CompEmp()
Objetivos   : Comparar os usários e incluir  
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/07/2011
*/

*------------------------------------*
 Static Function CompEmp(aEmp)
*------------------------------------*
  
Local n,i
Local cText   := "" 

Local nMeter1,oMeter1  
       
	nMeter1 := 1
 	oMeter1 := TMeter():New(120,10,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},120,oDlg,120,10,,.T.)
     
	oSay1:cCaption:="Atualizando empresas ..."
 	oSay1:Refresh() 
	
	oMeter1:SetTotal(len(aEmp[1]))  
	
	If Empty(aEmp[1])
 		Return .F.
	EndIf
       
    n:=0
	//Vetor com todas as empresas.
	
	For j:=1 to len(aEmp)          
		
		For i:=1 to len(aEmp[j])          
	             
			Z04->(DbSetOrder(1))
			If !(Z04->(DbSeek(xFilial("Z04")+aEmp[j][i][1]+aEmp[j][i][2])))
		   
		   		RecLock("Z04",.T.)
				Z04->Z04_FILIAL:=xFilial("Z04")
				Z04->Z04_CODIGO:=aEmp[j][i][1]
				Z04->Z04_CODFIL:=aEmp[j][i][2]
				Z04->Z04_NOMFIL:=aEmp[j][i][3]
				Z04->Z04_NOME  :=aEmp[j][i][4]
				Z04->Z04_NOMECO:=aEmp[j][i][5]		   
				Z04->Z04_CNPJ  :=aEmp[j][i][6] 
				Z04->Z04_AMB   :=GetAmb(aEmp[j][i][7])                                                                                                     
				Z04->(MsUnlock()) 
			
				cText+=Alltrim(aEmp[j][i][03])+"/"+Alltrim(aEmp[j][i][04])+CHR(13)+CHR(10)			      
	         
	       		n++ 
	    	EndIf
	       
	    	oMeter1:Set(i)
	    		   		
	    Next  	                      
						
	Next    
	
	If Empty(alltrim(cText)) 
	   
		oSay1:cCaption:="Nenhuma empresa incluúa."
 		oSay1:Refresh()
 		
 		cText:="Nenhuma empresa incluúa."
 		
 		//oTHButton := THButton():New(139,12,"",oDlg,,55,30,,"Detalhes da importação")       
    
    Else 
		oSay1:cCaption:=Alltrim(Str(n))+" empresas incluúas com sucesso: "
 		oSay1:Refresh() 

	    oTHButton := THButton():New(141	,10,"Detalhes da inclusão",oDlg,{||EECVIEW(cText,"Empresas incluúas.") },55,20,,"Detalhes da inclusão")
    
	EndIf   
	
	Z04->(DbGoTop())

Return              

/*
Funcao      : GetAmb()
Objetivos   : Rotina que retorna o ambiente 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/07/2011
*/
*-----------------------------*
 Static Function GetAmb(cAmb)
*-----------------------------* 
             
Do Case

	Case Alltrim(UPPER(cAmb)) =="AMB01"
		cAmb:="1"
	Case Alltrim(UPPER(cAmb)) =="AMB02"
		cAmb:="2"
	Case Alltrim(UPPER(cAmb)) =="AMB03"
		cAmb:="3"
	Case Alltrim(UPPER(cAmb)) =="GT01"
		cAmb:="4"
	Case Alltrim(UPPER(cAmb)) =="GT02"
		cAmb:="5"
	Case Alltrim(UPPER(cAmb)) =="GT03"
		cAmb:="6"
	Case Alltrim(UPPER(cAmb)) =="GTCORP"
		cAmb:="7"		

End Case                                       
                                   
Return cAmb
