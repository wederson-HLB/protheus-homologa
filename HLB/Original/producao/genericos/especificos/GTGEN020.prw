#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

/*
Funcao      : GTGEN020
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função para alterar a permissão do pergunte de determinado usuário ou grupo de usuários, selecionando as empresas do ambiente
Autor       : Matheus Massarotto
Data/Hora   : 09/10/2013    19:00
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

//Para o funcionamento é necessário executar o update UZ34001 - para criação da consulta de grupos de usuários e para a criação da tabela de logs

*-----------------------*
User Function GTGEN020()
*-----------------------*
Local cNome 	:= ""
Local aDados 	:= {}
Local oBrowse
Local oBrowseD

Local oBrowEB
Local oBrowDB

Local oPanel

Local lMacTd	:= .F.
Local oMacTd

Local aSize     := {}
Local aObjects	:= {}

Local oLayer 	:= FWLayer():new()

Local cConteudo	:= ""
Local cContaCont:= ""

Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oOk 		:= LoadBitmap( GetResources(), "LBTIK" )
Local oGet1
Local cGet1 := ""

Local nPanel

Private oDlg
Private oTButton2

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()

AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)


    DEFINE DIALOG oDlg TITLE "Bloqueio de perguntes" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

		oFont:= TFont():New('Arial',,-14,,.f.)
        
		oLayer:init(oDlg,.F.,.T.)              

		oLayer:addLine( 'CIMA', 50 , .F. )
		oLayer:addLine( 'BAIXO', 50 , .F. )

		oLayer:addCollumn('ESQ',50,.F.,'CIMA')
		oLayer:addCollumn('DIR',50,.F.,'CIMA')

        oLayer:addCollumn('ESQ',50,.F.,'BAIXO')
		oLayer:addCollumn('DIR',50,.F.,'BAIXO')
		

        oLayer:addWindow('ESQ','WinEC','Perguntas',100,.F.,.F.,{||  },'CIMA',{||  })
		oLayer:addWindow('DIR','WinDC','Itens da pergunta',100,.F.,.F.,{||  },'CIMA',{|| })
        oLayer:addWindow('DIR','WinDB','Empresas',100,.F.,.F.,{||  },'BAIXO',{|| })
        oLayer:addWindow('ESQ','WinEB','Bloquear para grupo ou usuário',100,.F.,.F.,{||  },'BAIXO',{|| })
                
		oWinDC := oLayer:getWinPanel('DIR','WinDC','CIMA')
		
		oWinEC := oLayer:getWinPanel('ESQ','WinEC','CIMA')

		oWinEB := oLayer:getWinPanel('ESQ','WinEB','BAIXO')
		
		oWinDB := oLayer:getWinPanel('DIR','WinDB','BAIXO')
		
		//Botões da tela principal.
		oTBarA := TBar():New( oDlg,45,32,.T.,,,,.F. )
		oTBtnBmpA := TBtnBmp() :NewBar('SALVAR',,,,'Salvar',{|| IIF(MsgYesNo("Deseja realmente salvar?","Atencão"),BarAtuXK(),)},.F.,oTBarA,.T.,{||.T.},,.F.,,,1,,,,,.T. )
		oTBtnBmpA:cTooltip:="Salvar"

		oTBtnBmpB := TBtnBmp() :NewBar('FINAL',,,,'Sair',{|| IIF(MsgYesNo("Deseja realmente sair?","Atencão"),oDlg:end(),)},.F.,oTBarA,.T.,{||.T.},,.F.,,,1,,,,,.T. )
		oTBtnBmpB:cTooltip:="Sair"



        oFont1:= TFont():New('Arial',,-14,,.f.)
		oFont2:= TFont():New('Constantia',,-14,,.F.)
		

    ACTIVATE DIALOG oDlg CENTERED ON INIT( IIF( Barpross(cGet1,@oBrowse,@oBrowseD,@oWinEC,@oWinDC,@oBrowEB,@oWinEB,@oBrowDB),(oDlg:FreeChildren(),oDlg:Refresh()),oDlg:End())) 


Return


/*
Funcao      : BrowEsqC()
Parametros  : 
Retorno     : 
Objetivos   : Browse do lado esquedo/cima , grupo de pergunta
Autor       : Matheus Massarotto
Data/Hora   : 09/10/2013	11:10
*/

*-------------------------------------------------------------------------------------------------*
Static function BrowEsqC(oWinEC,oBrowse,oDlg1,oMeter)
*-------------------------------------------------------------------------------------------------*
Local oTBtnBmp1,oTBar


// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB" OF oWinEC			

//Adiciona coluna para marcar e desmarcar
//ADD MARKCOLUMN 		oColumn DATA { ||  } DOUBLECLICK { |oBrowse| /* RecLock("DADTRB",.F.),MARCA:=!MARCA, DADTRB->(MsUnlock())  Função que atualiza a regra*/ }  OF oBrowse

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || GRUPO 		} TITLE "Grupo"   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 10 OF oBrowse		

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

//Encerra a barra
oDlg1:end()

Return(.T.)

/*
Funcao      : BrowDirC()
Parametros  : 
Retorno     : 
Objetivos   : Browse do lado direito/cima, itens dos perguntes
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2013	11:10
*/

*-----------------------------------------------------------*
Static function BrowDirC(oScr,oBrowse,oDlg1,oMeter,oBrowseE)
*-----------------------------------------------------------*
Local oTBtnBmp1,oTBtnBmp2,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB1" OF oScr

//Adiciona coluna para marcar e desmarcar                                                                                                                                                                                        //oBrowse:Refresh(.T.) posiciona no inicio após o refresh
ADD MARKCOLUMN oColumn DATA { || If(MARCA=="1"/* Função com a regra*/,'LBOK','LBNO') } DOUBLECLICK { |oBrowse| MarcBDir(oBrowseE,oBrowse)/* Função que atualiza a regra*/ }  OF oBrowse		

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || GRUPO2 	} TITLE "Grupo"  			DOUBLECLICK  {||  }  SIZE 10 OF oBrowse 
ADD COLUMN oColumn DATA { || ORDEM 		} TITLE "Ordem"  			DOUBLECLICK  {||  }  SIZE 2 OF oBrowse 
ADD COLUMN oColumn DATA { || PERGUNTA 	} TITLE "Pergunta" 			DOUBLECLICK  {||  }  SIZE 15 OF oBrowse 
ADD COLUMN oColumn DATA { || CONTEUDO 	} TITLE "Conteudo"  		DOUBLECLICK  {|| AltPerg() }  SIZE 25 OF oBrowse 


// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse


oBrowse:SetProfileID( '2' )

Return(.T.)


/*
Funcao      : BrowEsqB()
Parametros  : 
Retorno     : 
Objetivos   : Browse do lado esquerdo/baixo (Grupos e usuários)
Autor       : Matheus Massarotto
Data/Hora   : 05/10/2013	11:10
*/

*-------------------------------------------------------------------------------------------------*
Static function BrowEsqB(oWinEB,oBrowse,aCampos)
*-------------------------------------------------------------------------------------------------*
Local oTBtnBmp1,oTBar


// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB2" OF oWinEB

//Adiciona coluna para marcar e desmarcar
//ADD MARKCOLUMN 		oColumn DATA { ||  } DOUBLECLICK { |oBrowse| /* RecLock("DADTRB",.F.),MARCA:=!MARCA, DADTRB->(MsUnlock())  Função que atualiza a regra*/ }  OF oBrowse

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || GRPUSER 		} TITLE "Grupo Usuario"   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 10 OF oBrowse
ADD COLUMN oColumn DATA { || GRPDESC 		} TITLE "Descrição Grupo"  			DOUBLECLICK  {||  }	ALIGN 1 SIZE 15 OF oBrowse
ADD COLUMN oColumn DATA { || USUARIO		} TITLE "Usuario"		   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 10 OF oBrowse
ADD COLUMN oColumn DATA { || USUDESC 		} TITLE "Descrição Usuario"			DOUBLECLICK  {||  }	ALIGN 1 SIZE 15 OF oBrowse

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse


//Bara de botões do browse esquerdo de baixo
oTBar := TBar():New( oWinEB,45,32,.T.,,,,.F. )
oTBtnBmp1 := TBtnBmp() :NewBar('NOVACELULA',,,,'Incluir',{||BarConsu(),oBrowse:Refresh(.T.)},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Incluir"  

oTBtnBmp3 := TBtnBmp() :NewBar('EXCLUIR',,,,'Excluir',{||oBrowse:DelLine(),oBrowse:Refresh(.T.)},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp3:cTooltip:="Excluir"  

oBrowse:SetDelete(.T.,{|| DelGrpUs() }) //função para deleção com sua regra

	cCondicao := "alltrim(DADTRB2->MARCA) <> '2'"
	bCondicao := {|| alltrim(DADTRB2->MARCA) <> '2' }
	
	DbSelectArea("DADTRB2")

	DADTRB2->(DbSetFilter(bCondicao,cCondicao))

Return(.T.)


/*
Funcao      : BrowDirB()
Parametros  :
Retorno     : 
Objetivos   : Browse do lado direito/baixo, empresas
Autor       : Matheus Massarotto
Data/Hora   : 07/10/2013	11:10
*/

*-------------------------------------------------------------------------------------------------*
Static function BrowDirB(oWinDB,oBrowse,aCampos)
*-------------------------------------------------------------------------------------------------*
Local oTBtnBmp1,oTBar


// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB3" OF oWinDB

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(MARCA=="1"/* Função com a regra*/,'LBOK','LBNO') } DOUBLECLICK { |oBrowse|  RecLock("DADTRB3",.F.),MARCA:=IIF(MARCA=="1","2","1"), DADTRB3->(MsUnlock()) /* Função que atualiza a regra*/ }  OF oBrowse

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || CODEMP 		} TITLE "Codigo Empresa"   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 2 OF oBrowse
ADD COLUMN oColumn DATA { || EMPRESA 		} TITLE "Nome"			  			DOUBLECLICK  {||  }	ALIGN 1 SIZE 25 OF oBrowse

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

Return(.T.)

/*
Funcao      : Relacao()  
Parametros  : 
Retorno     : 
Objetivos   : Seta a relação entre os browses 
Autor       : Matheus Massarotto
Data/Hora   : 04/10/2013
*/
*---------------------------------------------------------*
Static function Relacao(oBrowseE,oBrowseD,oBrowEB,oBrowDB)
*---------------------------------------------------------*

oRelac:=FWBrwRelation():New()
oRelac:AddRelation( oBrowseE , oBrowseD , { { 'GRUPO2','GRUPO' } } )
oRelac:Activate()

oRelac2:=FWBrwRelation():New()
oRelac2:AddRelation( oBrowseE , oBrowEB , { { 'GRUPO3','GRUPO' } } )
oRelac2:Activate()

oRelac3:=FWBrwRelation():New()
oRelac3:AddRelation( oBrowseE , oBrowDB , { { 'GRUPO4','GRUPO' } } )
oRelac3:Activate()


Return


/*
Funcao      : Barpross()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 04/10/2013	15:14
*/
*-------------------------------------------------------------------------------------------------------------------*
Static Function Barpross(cGet1,oBrowse,oBrowseD,oWinEC,oWinDC,oBrowEB,oWinEB,oBrowDB)
*-------------------------------------------------------------------------------------------------------------------*
Local lTemMark	:= .F.
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.
   
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Carregando informações..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    
	    DbSelectArea("SX1")
	    conout(SX1->(RecCount()))
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},(SX1->(RecCount())*2),oDlg1,150,14,,.T.)

	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=ProcDado(cGet1,oDlg1,oWinEC,oWinDC,@oBrowse,@oBrowseD,oMeter,@oBrowEB,oWinEB,@oBrowDB))
	  
	//***********************************************************

Return(lRet)

/*
Funcao      : ProcDado()  
Parametros  : 
Retorno     : 
Objetivos   : Processa os dados e carrega o temporário
Autor       : Matheus Massarotto
Data/Hora   : 03/10/2013
*/
*-------------------------------------------------------------------------------------------------------------------------------*
Static Function	ProcDado(cGet1,oDlg1,oWinEC,oWinDC,oBrowse,oBrowseD,oMeter,oBrowEB,oWinEB,oBrowDB)
*-------------------------------------------------------------------------------------------------------------------------------*
Local nCont	:= 0 //Variável para controle de títulos encontrados
Local cETar	:= ""

Local lSaldoAtu := .F.

Local aRetVal	:= {}

//-->Tabela temporária para o lado esquerdo cima
aDadTemp	:= {}
MensErro	:= ""


AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"GRUPO"		,"C",10,0})
//AADD(aDadTemp,{"ID"			,"C",10,0})


if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
//cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB",cIndex,"GRUPO",,,"Selecionando Registro...")  
//IndRegua("DADTRB",cIndex2,"PERG",,,"Selecionando Registro...")  

DbSelectArea("DADTRB")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


//-->Tabela temporária para o lado direito cima
aDadTemp	:= {}
cMensErro	:= ""

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"GRUPO2"		,"C",10,0})
AADD(aDadTemp,{"ORDEM"		,"C",2,0})
AADD(aDadTemp,{"PERGUNTA"	,"C",25,0})
AADD(aDadTemp,{"CONTEUDO"	,"C",25,0})
AADD(aDadTemp,{"X1_GSC"		,"C",1,0})
AADD(aDadTemp,{"X1_DEF01"	,"C",15,0})
AADD(aDadTemp,{"X1_DEF02"	,"C",15,0})
AADD(aDadTemp,{"X1_DEF03"	,"C",15,0})
AADD(aDadTemp,{"X1_DEF04"	,"C",15,0})
AADD(aDadTemp,{"X1_DEF05"	,"C",15,0})

//AADD(aDadTemp,{"ID2"		,"C",10,0})

if select("DADTRB1")>0
	DADTRB1->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB1",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
//cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB1",cIndex,"GRUPO2+ORDEM",,,"Selecionando Registro...")  
//IndRegua("DADTRB1",cIndex2,"PERG+ORDEM",,,"Selecionando Registro...")  

DbSelectArea("DADTRB1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


//-->Tabela temporária para o lado esquerdo baixo
aDadTemp	:= {}
cMensErro	:= "" 
aCampos		:= {}

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"GRUPO3"		,"C",10,0})
AADD(aDadTemp,{"GRPUSER"	,"C",10,0})
AADD(aDadTemp,{"GRPDESC"	,"C",15,0})
AADD(aDadTemp,{"USUARIO"	,"C",10,0})
AADD(aDadTemp,{"USUDESC"	,"C",15,0})


AADD(aCampos,{"GRPUSER" ,"@!" ,"Grupo" ,10,"C",".F.",.F.})
AADD(aCampos,{"GRPDESC" ,"@!" ,"Descricaoo" ,15,"C",".F.",.F.})

//AADD(aDadTemp,{"ID2"		,"C",10,0})

if select("DADTRB2")>0
	DADTRB2->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB2",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
//cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB2",cIndex,"GRUPO3+GRPUSER+USUARIO",,,"Selecionando Registro...")  
//IndRegua("DADTRB1",cIndex2,"PERG+ORDEM",,,"Selecionando Registro...")  

DbSelectArea("DADTRB2")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)



//-->Tabela temporária para o lado direito baixo
aDadTemp	:= {}
cMensErro	:= "" 
aCampos		:= {}

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"GRUPO4"		,"C",10,0})
AADD(aDadTemp,{"CODEMP"		,"C",2,0})
AADD(aDadTemp,{"EMPRESA"	,"C",25,0})

//AADD(aDadTemp,{"ID2"		,"C",10,0})

if select("DADTRB3")>0
	DADTRB3->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB3",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB3",cIndex,"GRUPO4+CODEMP",,,"Selecionando Registro...")  

DbSelectArea("DADTRB3")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


//Carrega a tabela temporaria
DbSelectArea("SX1")
SX1->(DbSetOrder(1))
SX1->(DbGoTop())

//Inicia a régua
oMeter:Set(0)

While SX1->(!EOF())

   	//Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=2 	// atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua

	if empty(SX1->X1_GRUPO)
		SX1->(DbSkip())
		Loop
	endif
	
	if SX1->X1_ORDEM=="01"
		RecLock("DADTRB",.T.)
	    	DADTRB->MARCA	:= "2"
	    	DADTRB->GRUPO	:= alltrim(SX1->X1_GRUPO)
		DADTRB->(MsUnlock())
		
		aModSXK		:= {}
		lJaEntrou	:= .F.
		
		//Gravando as empresas por grupo
		DbSelectArea("SM0")
		DbSetOrder(1)
		SM0->(DbGoTop())
		While SM0->(!EOF())
            
			aTemSXK:= VerSXKSM0(SM0->M0_CODIGO,alltrim(SX1->X1_GRUPO))
            
			lTemSXK:= aTemSXK[1][1]	
            
			if lTemSXK
				aModSXK:=aTemSXK
			endif

			RecLock("DADTRB3",.T.)
		    	DADTRB3->MARCA	:= IIF(lTemSXK,"1","2")
		    	DADTRB3->GRUPO4	:= alltrim(SX1->X1_GRUPO)
		    	DADTRB3->CODEMP := SM0->M0_CODIGO
		    	DADTRB3->EMPRESA:= SM0->M0_NOME
			DADTRB3->(MsUnlock())
			
			SM0->(DbSkip())

		Enddo
        
	endif  
		
		nRetOrd:=0
		
		RecLock("DADTRB1",.T.)
            
            if len(aModSXK)>1 //se eu tenho mais itens além do lógico
	    		nRetOrd:=Ascan(aModSXK,{|x| alltrim(x[1]) = alltrim(SX1->X1_ORDEM)})
	    	endif
	    	
	    	DADTRB1->MARCA      := IIF(nRetOrd>0,"1","2")
	    	DADTRB1->GRUPO2		:= alltrim(SX1->X1_GRUPO)
			DADTRB1->ORDEM		:= SX1->X1_ORDEM
			DADTRB1->PERGUNTA	:= SX1->X1_PERGUNT	
			DADTRB1->X1_GSC		:= SX1->X1_GSC

			if SX1->X1_TIPO=='N'
				if nRetOrd>0
					DADTRB1->CONTEUDO   := aModSXK[nRetOrd][3]
				else
					DADTRB1->CONTEUDO   := IIF(SX1->X1_GSC=="C",cvaltochar(SX1->X1_PRESEL),SX1->X1_CNT01)
				endif
			else
				if nRetOrd>0
					DADTRB1->CONTEUDO   := aModSXK[nRetOrd][3]
				else
					DADTRB1->CONTEUDO   := IIF(SX1->X1_GSC=="C",cvaltochar(SX1->X1_PRESEL),SX1->X1_CNT01)
				endif

				//DADTRB1->CONTEUDO   := IIF(SX1->X1_GSC=="C",cvaltochar(SX1->X1_PRESEL),SX1->X1_CNT01)
			endif

			DADTRB1->X1_DEF01	:= SX1->X1_DEF01
			DADTRB1->X1_DEF02	:= SX1->X1_DEF02
			DADTRB1->X1_DEF03	:= SX1->X1_DEF03
			DADTRB1->X1_DEF04	:= SX1->X1_DEF04
			DADTRB1->X1_DEF05	:= SX1->X1_DEF05
			
		DADTRB1->(MsUnlock())    
	
	
	//Adiciono o usuário ou grupo de usuário
	if len(aModSXK)>1 .AND. !lJaEntrou
		lJaEntrou:=.T.
		
		for iMod:=1 to len(aModSXK)
		
			if SUBSTR(aModSXK[iMod][2],1,1)=="G"

				cCod:=SUBSTR(aModSXK[iMod][2],2,len(aModSXK[iMod][2]))

				DbSelectArea("DADTRB2")
				DADTRB2->(DbSetOrder(1))
			    if DADTRB2->(DbSeek(SX1->X1_GRUPO+cCod))
			    	loop
			    endif
			    
				RecLock("DADTRB2",.T.)
					
					DADTRB2->GRUPO3	:= alltrim(SX1->X1_GRUPO)
					DADTRB2->GRPUSER:= cCod
					DADTRB2->GRPDESC:= GrpRetName(cCod)  //Retorna o nome do grupo de usuários.
					
				DADTRB2->(MsUnlock())
	
			elseif SUBSTR(aModSXK[iMod][2],1,1)=="U"

				cCod:=SUBSTR(aModSXK[iMod][2],2,len(aModSXK[iMod][2]))			

				DbSelectArea("DADTRB2")
				DADTRB2->(DbSetOrder(1))
			    if DADTRB2->(DbSeek(SX1->X1_GRUPO+space(10)+cCod))
			    	loop
			    endif
			    
				RecLock("DADTRB2",.T.)
					
					DADTRB2->GRUPO3		:= alltrim(SX1->X1_GRUPO)
					DADTRB2->USUARIO	:= cCod
					DADTRB2->USUDESC	:= UsrRetName(cCod) //Retorna o nome do usuário informado no parâmetro.
					
				DADTRB2->(MsUnlock())		
	
			endif

		next
		
	endif
		
	SX1->(DbSkip())
Enddo
	
	//******** Carrega os browses
    
    //Carrega as informações do browse esquerdo cima
    BrowEsqC(@oWinEC,@oBrowse,oDlg1,oMeter)
	
	//Carrega as informações do browse direito cima
	BrowDirC(@oWinDC,@oBrowseD,oDlg1,oMeter,oBrowse)
	
	//Carrega as informações do browse esquerdo baixo
	BrowEsqB(@oWinEB,@oBrowEB,aCampos)

	//Carrega as informações do browse direito baixo
	BrowDirB(@oWinDB,@oBrowDB)
	
	//Adiciona relação dos browses
	Relacao(oBrowse,oBrowseD,oBrowEB,oBrowDB)

Return(.T.)


/*
Funcao      : BarConsu()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 10/10/2013	15:14
*/
*-------------------------------------------------*
Static Function BarConsu()
*-------------------------------------------------*
Local oDlg3
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg3 TITLE "Localizando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg3,70,34,,.T.,,,,,,,,,)
	    
	  ACTIVATE DIALOG oDlg3 CENTERED ON INIT(lRet:=IncGprUsr(oMeter,oDlg3))
	  
	//*************************************

Return(lRet)                                                             


/*
Funcao      : MarcBDir()  
Parametros  : 
Retorno     : 
Objetivos   : Função para marcar o browse do lado direito
Autor       : Matheus Massarotto
Data/Hora   : 10/10/2013
*/
*-----------------------------------------*
Static Function MarcBDir(oBrowseE,oBrowse)
*-----------------------------------------*

if DADTRB1->MARCA=="1"
	RecLock("DADTRB1",.F.)
		DADTRB1->MARCA:="2"
	DADTRB1->(MsUnlock())
else
	RecLock("DADTRB1",.F.)
		DADTRB1->MARCA:="1"
	DADTRB1->(MsUnlock())
endif

//Atualiza a linha do browse esquerdo(Títulos do banco)
oBrowseE:Refresh()//LineRefresh(oBrowseE:nAt)

oBrowse:Refresh() //Atualiza o browse direito(Títulos do sistema)

Return


//Função para marcação dos itens 
*--------------------------------*
Static function MarcBro()
*--------------------------------*
Local cRec	:= DADGRP->(RECNO())

DADGRP->(DbGoTo(cRec))

	RecLock("DADGRP",.F.)
		DADGRP->MARCA:=IIF(DADGRP->MARCA=="1","2","1") 
	DADGRP->(MsUnlock())

Return

//Altera item da pergunta
*-----------------------*
Static Function AltPerg
*-----------------------*

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1","oSay1","oGet1","oCBox1","oSBtn1","oSBtn2")
Private cGet1:=DADTRB1->CONTEUDO

Private aItems:= {}
Private cCombo:= ""

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 227,376,341,716,"Pergunta",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 015,008,{||alltrim(DADTRB1->PERGUNTA)},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)


if DADTRB1->X1_GSC=="C"
    
	if !empty(DADTRB1->X1_DEF01)
		AADD(aItems,"1-"+DADTRB1->X1_DEF01)
	endif
	if !empty(DADTRB1->X1_DEF02)
		AADD(aItems,"2-"+DADTRB1->X1_DEF02)
	endif
	if !empty(DADTRB1->X1_DEF03)
		AADD(aItems,"3-"+DADTRB1->X1_DEF03)
	endif
	if !empty(DADTRB1->X1_DEF04)
		AADD(aItems,"4-"+DADTRB1->X1_DEF04)
	endif
	if !empty(DADTRB1->X1_DEF05)
		AADD(aItems,"5-"+DADTRB1->X1_DEF05)
	endif

	if val(DADTRB1->CONTEUDO)>0
		cGet1:=aItems[val(DADTRB1->CONTEUDO)]
	endif
	
	oCBox1     := TComboBox():New( 013,068,{|u| iif(PCount()>0,cGet1:=SUBSTR(u,1,1),SUBSTR(cGet1,1,1))},aItems,084,010,oDlg1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
else
	oGet1      := TGet():New( 013,068,{|u| iif(PCount()>0,cGet1:=u,cGet1)},oDlg1,084,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
endif

oSBtn1     := SButton():New( 035,040,1,{|| RecLock("DADTRB1",.F.),DADTRB1->CONTEUDO:=cGet1,DADTRB1->(MsUnlock()), oDlg1:end() },oDlg1,,"", )
oSBtn2     := SButton():New( 035,105,2,{|| oDlg1:end() },oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return


//Tela para seleção dos grupos e/ou usuários
*-------------------------------------*
Static function IncGprUsr(oMeter,oDlg3)
*-------------------------------------*
Local oDlgUsr

Local bOk     := {|| lRet:= .T.,oDlgUsr:End()}
Local bCancel := {|| oDlgUsr:End()}

Local oLayer 	:= FWLayer():new()
Local oScrBx

Private cGetGrp :=SPACE(10)
Private cGetGrpD:=""

Private aButtons	:= {}
Private oBrowAux

//Inicia a régua
oMeter:Set(30)

//-->Tabela temporária
aDadTemp	:= {}

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"GRPUSER"	,"C",10,0})
AADD(aDadTemp,{"USUARIO"	,"C",10,0})
AADD(aDadTemp,{"USUDESC"	,"C",15,0})
	
if select("DADGRP")>0
	DADGRP->(DbCloseArea())
endif

//Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADGRP",.T.,.F.)

//cIndex	:=CriaTrab(Nil,.F.)
cIndex2	:=CriaTrab(Nil,.F.)

//IndRegua("DADGRP",cIndex,"ID2",,,"Selecionando Registro...")  
IndRegua("DADGRP",cIndex2,"GRPUSER+USUARIO",,,"Selecionando Registro...")  

DbSelectArea("DADGRP")
DbSetIndex(cIndex2+OrdBagExt())
DbSetOrder(1)

								                                           //retira o botão X
		DEFINE DIALOG oDlgUsr TITLE "Usuários" FROM 137,285 TO 594,1166 PIXEL//STYLE DS_MODALFRAME FROM 137,285 TO 544,1066 PIXEL

			oLayer:init(oDlgUsr,.F.,.T.)              

			oLayer:addLine( 'CIMA', 20 , .F. )
			oLayer:addLine( 'BAIXO', 80 , .F. )
            
			oLayer:addCollumn('CC',100,.F.,'CIMA')
			oLayer:addCollumn('CB',100,.F.,'BAIXO')

            oLayer:addWindow('CC','WinC','',100,.F.,.F.,{||},'CIMA',{||})
	        oLayer:addWindow('CB','WinB','Usuários',100,.F.,.F.,{||},'BAIXO',{|| })
            
            oScrCi := oLayer:getWinPanel('CC','WinC','CIMA')
			oScrBx := oLayer:getWinPanel('CB','WinB','BAIXO')
             
            oSay1		:= TSay():New( 06,05,{||"Grupo:"},oScrCi,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
			oGetGrp    	:= TGet():New( 05,25,{|u| iif(PCount()>0,cGetGrp:=SxbGrp(u,oBrowAux),cGetGrp)},oScrCi,054,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||Filtra(cGetGrp),oBrowAux:Refresh(.T.)},.F.,.F.,"","cGetGrp",,)
            oGetGrp:cF3 := "GRPUSR"

			oGetGrpD   	:= TGet():New( 05,135,{|u| iif(PCount()>0,cGetGrpD:=u,cGetGrpD)},oScrCi,084,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
            oGetGrpD:Disable()
            

			CargaUsr(oMeter)

			//Chamo uma vez para realizar o filtro na temporária
			Filtra(cGetGrp)
			
			BrowDir2(oScrBx,@oBrowAux,oDlgUsr)

		ACTIVATE DIALOG oDlgUsr CENTERED

oDlg3:end()

Return()


/*
Funcao      : BrowDir2()
Parametros  : 
Retorno     : 
Objetivos   : Função para processar os dados da tela de busca de usuáros/grupos
Autor       : Matheus Massarotto
Data/Hora   : 02/10/2013	11:10
*/

*-----------------------------------------------*
Static function BrowDir2(oScrBx,oBrowAux,oDlgUsr)
*-----------------------------------------------*
Local oTBtnBmp1,oTBtnBmp2,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowAux DATA TABLE ALIAS "DADGRP" OF oScrBx

//Adiciona coluna para marcar e desmarcar                                                                                                                                                                                        //oBrowAux:Refresh(.T.) posiciona no inicio após o refresh
ADD MARKCOLUMN oColumn DATA { || If(MARCA=="1"/* Função com a regra*/,'LBOK',IIF(MARCA=="2",'LBNO',)) } DOUBLECLICK { |oBrowAux| MarcBro() /* Função que atualiza a regra*/ }  OF oBrowAux		

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || USUARIO	} TITLE "Usuario"  			DOUBLECLICK  {||  }  SIZE 10 OF oBrowAux 
ADD COLUMN oColumn DATA { || USUDESC 	} TITLE "Nome"  		  	DOUBLECLICK  {||  }  SIZE 15 OF oBrowAux 

//Bara de botões do browse direito
oTBar := TBar():New( oScrBx,25,32,.T.,"BOTTOM",,,.F. )

//oTBar:SetButtonAlign( CONTROL_ALIGN_RIGHT )

oTBtnBmp1 := TBtnBmp() :NewBar('OK',,,,'Ok',{|| IIF( GravTRB2(cGetGrp,cGetGrpD),oDlgUsr:End(),) },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Ok"

oTBtnBmp2 := TBtnBmp() :NewBar('FINAL',,,,'Sair',{|| oDlgUsr:End() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp2:cTooltip:="Sair"

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowAux

Return(.T.)

//Carrega os usuários no temporário
*-------------------------------*
Static Function CargaUsr(oMeter)
*-------------------------------*
//Carregando todos os usuários
aUsuarios	:= AllUsers()
//Ajustando array para um aceitável a apresentação no combobox
	
	for i:=1 to len(aUsuarios)
	    
		for j:=1 to len(aUsuarios[i][1][10])
			
			RecLock("DADGRP",.T.)
	
				DADGRP->MARCA	:="1"
				DADGRP->GRPUSER :=aUsuarios[i][1][10][j] //Grupos
				DADGRP->USUARIO	:=aUsuarios[i][1][1] //Codigo
				DADGRP->USUDESC	:=aUsuarios[i][1][2] //Nome do usuario
			
			DADGRP->(MsUnlock())
			
		next
	next

//Posiciona a régua
oMeter:Set(70)

Return


//Cria a regra de filtro para temporário
*----------------------------*
Static function Filtra(cGrupo)
*----------------------------*    
	
	cCondicao := "alltrim(DADGRP->GRPUSER) $ '"+cGrupo+"'"
	bCondicao := {|| alltrim(DADGRP->GRPUSER) $ cGrupo }
	
	DbSelectArea("DADGRP")

	DbSetFilter(bCondicao,cCondicao)

Return


/*
Funcao      : SxbGrp()
Parametros  : 
Retorno     : 
Objetivos   : Função para filtrar e atualizar o browse quando clicar na busca(F3)
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*--------------------------------------*
Static function SxbGrp(cGetGrp,oBrowAux)
*--------------------------------------*
cteste:=""
Filtra(cGetGrp)

if valtype(oBrowAux)=="O"
	oBrowAux:Refresh(.T.)
endif

Return(cGetGrp)

//Grava na tabela de grupos e usuários os selecionados
*-----------------------------------------*
Static function GravTRB2(cGetGrp,cGetGrpD)
*-----------------------------------------*
Local lTemNMark:=.F.

//Verifico se tem algum usuário que não está marcado
DbSelectArea("DADGRP")
DADGRP->(DbSetOrder(1))
DADGRP->(DbGoTop())
if DADGRP->(DbSeek(cGetGrp))

	While DADGRP->(!EOF()) .AND. alltrim(DADGRP->GRPUSER)==alltrim(cGetGrp)
		
		if DADGRP->MARCA<>"1"
			lTemNMark:=.T.
		endif

		DADGRP->(DbSkip())
		
	enddo
	
endif

//Preencho a teporária
if !lTemNMark		
    
    DbSelectArea("DADTRB2")
    DbSetOrder(1)
    if DADTRB2->(DbSeek(DADTRB->GRUPO+cGetGrp))
    	
    	Alert("Grupo já inserido","Atenção")
    	
    	Return(.F.)
    
    endif
    
	RecLock("DADTRB2",.T.)
		DADTRB2->GRUPO3	:= DADTRB->GRUPO
		DADTRB2->GRPUSER:= cGetGrp
		DADTRB2->GRPDESC:= cGetGrpD
	DADTRB2->(MsUnlock())
	
else

	//Verifico se tem algum usuário que não está marcado
	DbSelectArea("DADGRP")
	DADGRP->(DbSetOrder(1))
	DADGRP->(DbGoTop())
	if DADGRP->(DbSeek(cGetGrp))
	
		While DADGRP->(!EOF()) .AND. alltrim(DADGRP->GRPUSER)==alltrim(cGetGrp)
	
			if DADGRP->MARCA=="1"
			
			    DbSelectArea("DADTRB2")
				DbSetOrder(1)
				if DADTRB2->(DbSeek(DADTRB->GRUPO+space(10)+DADGRP->USUARIO))
				    	
				  	Alert("Usuário já inserido","Atenção")
				   	
				 	Return(.F.)
				    
				endif
			
				RecLock("DADTRB2",.T.)				
					DADTRB2->GRUPO3		:= DADTRB->GRUPO
					DADTRB2->USUARIO	:= DADGRP->USUARIO
					DADTRB2->USUDESC	:= DADGRP->USUDESC
				DADTRB2->(MsUnlock())
				
		    endif
		
			DADGRP->(DbSkip())
			
		enddo
		
    endif
    
endif
	
Return(.T.)

//Função para gravar na tabela SXK as regras definidas na rotina
*-----------------------------------*
Static function AtuSXK(oMeter,oDlg2)
*-----------------------------------*

//Limpo o filtro da tabela de grupos e usuários
DADTRB2->(DBCLEARALLFILTER())

//Inicia a régua
oMeter:Set(0)

DbSelectArea("DADTRB1")
DbSetOrder(1)
DADTRB1->(DbGoTop())
//**Percorro a tabela 2 - lado direito em cima
While DADTRB1->(!EOF())

   	//Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=2 	// atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua

	if DADTRB1->MARCA=="1" //Se tiver marcado
		//**Posiciona no usuários ou grupos
		DbSelectArea("DADTRB2")
		DADTRB2->(DbSetOrder(1))
		DADTRB2->(DbGoTop())

		if DADTRB2->(DbSeek(DADTRB1->GRUPO2))
        	
        	While DADTRB2->(!EOF()) .AND. DADTRB2->GRUPO3==DADTRB1->GRUPO2

                
            	//Se for grupo ou usuário
            	if !empty(DADTRB2->GRPUSER) .OR. !empty(DADTRB2->USUARIO)
            		
	           		//**Posiciono na tabela de empresas relacionadas
       				DbSelectArea("DADTRB3")
					DADTRB3->(DbSetOrder(1))
					DADTRB3->(DbGoTop())
    				if DADTRB3->(DbSeek(DADTRB1->GRUPO2))
                    	
                    	While DADTRB3->(!EOF()) .AND. DADTRB3->GRUPO4==DADTRB1->GRUPO2
	                    	if DADTRB3->MARCA=="1" //Se a empresa estiver marcada
	                    	
	                    		//DADTRB3->CODEMP - código da empresa
								if select("TMP")>0
									TMP->(DbCloseArea())
								endif
								
//								dbUseArea( .T.,"dbfcdxads", "SXK"+DADTRB3->CODEMP+"0.dbf","TMP",.T., .F. )	                    	
								If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
									dbUseArea( .T.,__LOCALDRIVER, "SXK"+DADTRB3->CODEMP+"0.dbf","TMP",.T., .F. )	                    	
    							Else 
									dbUseArea( .T.,__LOCALDRIVER, "SXK"+DADTRB3->CODEMP+"0.dtc","TMP",.T., .F. )	                    	
    							Endif
								
								if select("TMP")>0 								


									DbSelectArea("TMP")
									//DbSetIndex(cIndex+OrdBagExt())
									TMP->(DbSetOrder(1))
								    
								    cGUPesq:=""
								    
								    //Se for grupo de usuários
								    if !empty(DADTRB2->GRPUSER)
								    	cGUPesq:="G"+DADTRB2->GRPUSER
								    elseif !empty(DADTRB2->USUARIO)
									    cGUPesq:="U"+DADTRB2->USUARIO
								    endif
								                 //Grupo + Sequencia da pergunta + usuario ou grupo
                                    if TMP->(DbSeek(DADTRB1->GRUPO2+DADTRB1->ORDEM+cGUPesq)) //se encontrei cadastrado
                                        
                                        if DADTRB2->MARCA=="2"
											RecLock("TMP",.F.)
                                            	TMP->(DbDelete())
											TMP->(MsUnlock())
											
											GravaLog(DADTRB3->CODEMP,"",DADTRB1->GRUPO2,DADTRB1->ORDEM,DADTRB1->PERGUNTA,DADTRB1->CONTEUDO,DADTRB2->USUARIO,DADTRB2->GRPUSER,"EXCLUIR")
											
										else
											RecLock("TMP",.F.)
												//TMP->XK_GRUPO	:= 
												//TMP->XK_SEQ     := 
												//TMP->XK_IDUSER	:= 
												TMP->XK_CONTEUD	:= DADTRB1->CONTEUDO
												//TMP->XK_FORM	:= 
											TMP->(MsUnlock())
											
											GravaLog(DADTRB3->CODEMP,"",DADTRB1->GRUPO2,DADTRB1->ORDEM,DADTRB1->PERGUNTA,DADTRB1->CONTEUDO,DADTRB2->USUARIO,DADTRB2->GRPUSER,"ALTERAR")
											
                                        endif  
									else
										
										if DADTRB2->MARCA<>"2"
											RecLock("TMP",.T.)
												TMP->XK_GRUPO	:= DADTRB1->GRUPO2
												TMP->XK_SEQ     := DADTRB1->ORDEM
												TMP->XK_IDUSER	:= cGUPesq
												TMP->XK_CONTEUD	:= DADTRB1->CONTEUDO
												//TMP->XK_FORM	:= 
											TMP->(MsUnlock())
											
											GravaLog(DADTRB3->CODEMP,"",DADTRB1->GRUPO2,DADTRB1->ORDEM,DADTRB1->PERGUNTA,DADTRB1->CONTEUDO,DADTRB2->USUARIO,DADTRB2->GRPUSER,"INCLUIR")
											
                                        endif
                                        
									endif
									

								endif

							else //se a empresa não estiver marcada
							
								if select("TMP")>0
									TMP->(DbCloseArea())
								endif
								
//								dbUseArea( .T.,"dbfcdxads", "SXK"+DADTRB3->CODEMP+"0.dbf","TMP",.T., .F. )	                    	
								If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
									dbUseArea( .T.,__LOCALDRIVER, "SXK"+DADTRB3->CODEMP+"0.dbf","TMP",.T., .F. )	                    	
    							Else 
									dbUseArea( .T.,__LOCALDRIVER, "SXK"+DADTRB3->CODEMP+"0.dtc","TMP",.T., .F. )	                    	
    							Endif

								if select("TMP")>0 								

									DbSelectArea("TMP")
									TMP->(DbSetOrder(1))
									if TMP->(DbSeek(DADTRB1->GRUPO2))
							        	While TMP->(!EOF()) .AND. TMP->XK_GRUPO==DADTRB1->GRUPO2
								        	
								        	RecLock("TMP",.F.)
									        	TMP->(DbDelete())
											TMP->(MsUnlock())
											
											GravaLog(DADTRB3->CODEMP,"",DADTRB1->GRUPO2,DADTRB1->ORDEM,DADTRB1->PERGUNTA,DADTRB1->CONTEUDO,DADTRB2->USUARIO,DADTRB2->GRPUSER,"EXCLUIR")
											
											TMP->(DbSkip())
										Enddo
							    	endif
									
								endif
									
	                    	endif

	                    	DADTRB3->(DbSkip())
                    	Enddo
                    	
                    endif
                    
            	
            	endif
            
            	DADTRB2->(DbSkip())
        	Enddo
        
        endif
	else //se estiver desmarcado eu verifico se na empresa tem para apagar o registro da SXK
	
		DbSelectArea("SM0")
		DbSetOrder(1)
		SM0->(DbGoTop())
		While SM0->(!EOF())
            
			if select("TMP")>0
				TMP->(DbCloseArea())
			endif
			
//			dbUseArea( .T.,"dbfcdxads", "SXK"+SM0->M0_CODIGO+"0.dbf","TMP",.T., .F. )	                    	
			If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
				dbUseArea( .T.,__LOCALDRIVER, "SXK"+SM0->M0_CODIGO+"0.dbf","TMP",.T., .F. )
			Else 
				dbUseArea( .T.,__LOCALDRIVER, "SXK"+SM0->M0_CODIGO+"0.dtc","TMP",.T., .F. )
			Endif

			DbSelectArea("TMP")
			TMP->(DbSetOrder(1))

			if TMP->(DbSeek(DADTRB1->GRUPO2+DADTRB1->ORDEM))
	        	While TMP->(!EOF()) .AND. TMP->XK_GRUPO==DADTRB1->GRUPO2 .AND. TMP->XK_SEQ==DADTRB1->ORDEM
		        	
		        	RecLock("TMP",.F.)
			        	TMP->(DbDelete())
					TMP->(MsUnlock())
					
					GravaLog(SM0->M0_CODIGO,SM0->M0_CODFIL,DADTRB1->GRUPO2,DADTRB1->ORDEM,DADTRB1->PERGUNTA,DADTRB1->CONTEUDO,DADTRB2->USUARIO,DADTRB2->GRPUSER,"EXCLUIR")

					TMP->(DbSkip())
				Enddo
	    	endif
	    
			SM0->(DbSkip())
	    Enddo
	    
	endif
	
	DADTRB1->(DbSkip())
Enddo	


	//Volto o filtro do grupo e usuários
	cCondicao := "alltrim(DADTRB2->MARCA) <> '2'"
	bCondicao := {|| alltrim(DADTRB2->MARCA) <> '2' }
	DbSelectArea("DADTRB2")
	DADTRB2->(DbSetFilter(bCondicao,cCondicao))
	

//Encerra a barra
oDlg2:end()

msginfo("Salvo com sucesso!")

Return

//Função para verificar o SXK da empresa, retornando um array com as informações
*------------------------------------*
Static Function VerSXKSM0(cEmp,cGrupo)
*------------------------------------*
Local lRet:= .F.
Local aRet:= {}

	AADD(aRet,{lRet,"",""})
	
	if select("TMP")>0
		TMP->(DbCloseArea())
	endif
	
//	dbUseArea( .T.,"dbfcdxads", "SXK"+cEmp+"0.dbf","TMP",.T., .F. )	   
	If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
		dbUseArea( .T.,__LOCALDRIVER, "SXK"+cEmp+"0.dbf","TMP",.T., .F. )	   
	Else 
		dbUseArea( .T.,__LOCALDRIVER, "SXK"+cEmp+"0.dtc","TMP",.T., .F. )	   
	Endif
	
	if select("TMP")>0 								

		DbSelectArea("TMP")
		TMP->(DbSetOrder(1))
        if TMP->(DbSeek(cGrupo))
        	aRet[1][1]:=.T.
        	While TMP->(!EOF()) .AND. alltrim(TMP->XK_GRUPO)==alltrim(cGrupo)
        			AADD(aRet,{TMP->XK_SEQ,TMP->XK_IDUSER,TMP->XK_CONTEUD})
        		TMP->(DbSkip())
        	Enddo
        	
        endif
    endif

Return(aRet)



/*
Funcao      : BarAtuXK()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 09/10/2013	15:14
*/
*-------------------------*
Static Function BarAtuXK()
*-------------------------*
Local lTemMark	:= .F.
Local oDlg2
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

    
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg2 TITLE "Salvando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    
	    DbSelectArea("DADTRB1")
	    conout(DADTRB1->(RecCount()))
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},(DADTRB1->(RecCount())*2),oDlg2,150,14,,.T.)

	  ACTIVATE DIALOG oDlg2 CENTERED ON INIT(lRet:=AtuSXK(oMeter,oDlg2))
	  
	//***********************************************************

Return(lRet)

//função para marcar a tabela de grupos e usuários como o campo MARCA == 2 representando q está apagado
*-------------------------*
Static Function DelGrpUs()
*-------------------------*      
if DADTRB2->(!EOF())
	RecLock("DADTRB2",.F.)
	
	DADTRB2->MARCA:="2"
	
	DADTRB2->(MsUnlock())
endif

Return

//Função para gravar o log na tabela Z34
*------------------------------------------------------------------------------------------*
Static Function GravaLog(cEmp,cFil,cPergun,cSeq,cDesc,cConteu,cUsrlib,cGrpLib,cTipo)
*------------------------------------------------------------------------------------------*                            
DbSelectArea("Z34")

if select("Z34")>0

	RecLock("Z34",.T.)

		Z34->Z34_EMP	:= cEmp
		Z34->Z34_FIL	:= cFil
		Z34->Z34_CODUSE	:= __cUserID
		Z34->Z34_USER	:= UsrFullName(__cUserID)
		Z34->Z34_DATA	:= ddatabase
		Z34->Z34_HORA	:= TIME()
		Z34->Z34_PERG	:= cPergun
		Z34->Z34_PSEQ	:= cSeq
		Z34->Z34_PDESC	:= cDesc
		Z34->Z34_CONTEU	:= cConteu
		Z34->Z34_LIBUSR	:= cUsrlib
		Z34->Z34_GRPLIB	:= cGrpLib
		Z34->Z34_TIPO	:= cTipo
		
    Z34->(MsUnlock())
    
endif

Return