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
±±ºUso       ³ Grant Thornton                                             º±±
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
     
     	@ 145 ,70 BMPBUTTON TYPE 1 ACTION(BuscaEmp()) 
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
 	oMeter := TMeter():New(102,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgPrint,120,10,,.T.)
 	
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
				
			oSay:cCaption:="Não foi possível conectar "+alltrim(aAmbs[i][3])
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
 
DEFINE MSDIALOG oAtuSA1 TITLE "Atualização código telefone cliente" From 4,10 To 15,40 OF oMain     
    
    @ 5,5  TO 25,115 LABEL "" OF oAtuSA1 PIXEL    
    @ 30,5 TO 50,115 LABEL "" OF oAtuSA1 PIXEL      
    @ 55,5 TO 80,115 LABEL "" OF oAtuSA1 PIXEL
   	
   	oFont := TFont():New('Courier new',,-12,.T.)  
                                    
	oSay2:= TSay():Create(oAtuSA1,{||'Atualização código telefone'},10,10,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,150,10)
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
Local cCNPJ :=""
       
If !(MsgYesNo("Deseja atualizar todos os códigos de clientes"))
	Return .f.    
EndIf 
       
nMeter1 := 1
oMeter1 := TMeter():New(35,12,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},120,oAtuSA1,95,10,,.T.)
 
//RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil) 
oServ:=  RpcConnect("10.0.30.20",5001,"GTCORP11","Z4","05")  


     		   	
If valtype(OsERV) == 'O'
			
	oSay2:cCaption:="Conectando ao ambiente GTCorp11"
	oSay2:Refresh()
				
	aAdd(aSA1,oServ:CALLPROC("U_GTGETSA1"))    
	
	lAtu :=.T.
	  			
Else    

	oSay2:cCaption:="Não conectou ao ambiente GT"
	oSay2:Refresh()

EndIf       

If lAtu 
 
	oSay2:cCaption:="Atualizando códigos ..."
 	oSay2:Refresh() 
	
	oMeter1:SetTotal(len(aSA1[1]))  
	
	If Empty(aSA1)
 		Return .F.
	EndIf
       
    n:=0
	//Vetor com todas as empresas.
	For i:=1 to len(aSA1[1])          
	                            
	     // 1.A1_COD,2.A1_NOME,3.A1_NREDUZ,4.A1_CGC        
	             
		Z04->(DbSetOrder(2))
		If Z04->(DbSeek(xFilial("Z04")+aSA1[1][i][4]))
			
			While Z04->(!EOF()) .And. alltrim(Z04->Z04_CNPJ) == alltrim(aSA1[1][i][4])         
		   
				RecLock("Z04",.F.)
				Z04->Z04_CODTEL :=Substr(Alltrim(aSA1[1][i][1]),3,4)                                                                                             
		   		Z04->(MsUnlock())  
		   		
			    Z04->(DbSkip())
			    
			EndDo
			
			cText+="Atualizado : "+Alltrim(aSA1[1][i][2])+CHR(13)+CHR(10)			      
	         
	      	n++
	      	
	    EndIf                           

		oMeter1:Set(i)				
	Next    
	
	If Empty(alltrim(cText)) 
	   
		oSay2:cCaption:="Nenhuma empresa atualizada."
 		oSay2:Refresh()
 		
 		cText:="0 empresa atualizada."
 		
 		oTHButton := THButton():New(139,12,"                 ",oAtuSA1,,55,30,,"Detalhes da atualização")       
    
    Else           
    
		oSay2:cCaption:=Alltrim(Str(n))+" empresas atualizadas"
 		oSay2:Refresh() 

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
 	oMeter1 := TMeter():New(120,10,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},120,oDlgPrint,120,10,,.T.)
     
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
				Z04->Z04_FILIAL := xFilial("Z04")
				Z04->Z04_CODIGO := aEmp[j][i][1]
				Z04->Z04_CODFIL := aEmp[j][i][2]
				Z04->Z04_NOMFIL := aEmp[j][i][3]
				Z04->Z04_NOME   := aEmp[j][i][4]
				Z04->Z04_NOMECO := aEmp[j][i][5]		   
				Z04->Z04_CNPJ   := aEmp[j][i][6] 
				Z04->Z04_AMB    := GetAmb(aEmp[j][i][7])
				
				Z10->(DbSetOrder(1))
				If Z10->(DbSeek(xFilial("Z10")+Alltrim(aEmp[j][i][1])+AllTrim(aEmp[j][i][2])))
					Z04->Z04_SERVID := Z10->Z10_SERVID
					Z04->Z04_PORTA  := Z10->Z10_PORTA
				EndIf

				Z04->Z04_SIGMAT := "S"
				                                                                                                     
				Z04->(MsUnlock()) 
			
				cText+=Alltrim(aEmp[j][i][03])+"/"+Alltrim(aEmp[j][i][04])+CHR(13)+CHR(10)			      
	         
	       		n++ 
	    	EndIf
	       
	    	oMeter1:Set(i)
	    		   		
	    Next  	                      
						
	Next    
	
	If Empty(alltrim(cText)) 
	   
		oSay1:cCaption:="Nenhuma empresa incluída."
 		oSay1:Refresh()
 		
 		cText:="Nenhuma empresa incluída."
 		
 		//oTHButton := THButton():New(139,12,"",oDlg,,55,30,,"Detalhes da importação")       
    
    Else 
		oSay1:cCaption:=Alltrim(Str(n))+" empresas incluídas com sucesso: "
 		oSay1:Refresh() 

	    oTHButton := THButton():New(141	,10,"Detalhes da inclusão",oDlgPrint,{||EECVIEW(cText,"Empresas incluídas.") },55,20,,"Detalhes da inclusão")
    
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

cAmb := Alltrim(UPPER(cAmb))

/*             
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
	Case Alltrim(UPPER(cAmb)) =="GTIS"
		cAmb:="8"		
	Case Alltrim(UPPER(cAmb)) =="PAGUS"
		cAmb:="9"
	Case Alltrim(UPPER(cAmb)) =="GTRJ"
		cAmb:="A"		


End Case                                       
*/
                                   
Return cAmb
