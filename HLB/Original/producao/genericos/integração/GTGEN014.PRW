#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "APWIZARD.CH"

/*
Funcao      : GTGEN014
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função para processamento de um arquivo OFX, realizando o vinculo com os título do sistems através dos valores. 
			: O programa faz as baixas e inclusões da movimentação bancária
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/


//Para o funcionamento é necessário executar o update UZ60001 - para criação da tabela de parametrização de tarifas/rendimentos, e UZ59001 - para a criação da tabela de logs
//E ter o fonte GTOBJ003 e GTOBJ004 compilados, pois são os objetos de leitura de ofx e gravação de log

*----------------------*
User Function GTGEN014()
*----------------------*

//Chamo o wizard inicial para seleção dos parâmetros
InWizard()

Return

/*
Funcao      : Principal()  
Parametros  : 
Retorno     : 
Objetivos   : Função principal do processamento
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*--------------------------------------------------------*
Static Function Principal(cGet1,cCombo1,cCombo2,cCombo3,cCombo4,cBank,cAgency,cAccount,dDtaIni,dDtaFim)
*--------------------------------------------------------*
Local oPessoa
Local cNome 	:= ""
Local dNascimento:= CTOD("")
Local aDados 	:= {}
Local oBrowse
Local oBrowseD

Local oPanel

Local lMacTd	:= .F.
Local oMacTd

Local aSize     := {}
Local aObjects	:= {}

Local oLayer 	:= FWLayer():new()

Local cConteudo	:= ""
Local cContaCont:= ""

//Local nHRes		:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor 

Private oDlg
Private oTButton2

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()

AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)


    DEFINE DIALOG oDlg TITLE "Procesar ofx" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

		oFont:= TFont():New('Arial',,-14,,.f.)
        
		oLayer:init(oDlg,.F.,.T.)              

		oLayer:addLine( 'CIMA', 20 , .F. )
		oLayer:addLine( 'BAIXO', 80 , .F. )

		oLayer:addCollumn('ESQ',10,.F.,'CIMA')
		oLayer:addCollumn('DIR',90,.F.,'CIMA')

        oLayer:addCollumn('ESQ',50,.F.,'BAIXO')
		oLayer:addCollumn('DIR',50,.F.,'BAIXO')
		

        oLayer:addWindow('ESQ','WinEC','Opções',100,.F.,.F.,{||  },'CIMA',{||  })
		oLayer:addWindow('DIR','WinDC','Saldos',100,.F.,.F.,{||  },'CIMA',{|| })
        oLayer:addWindow('DIR','WinDB','Títulos sistema',100,.T.,.F.,{||  },'BAIXO',{|| })
        oLayer:addWindow('ESQ','WinEB','Lançamentos do arquivo',100,.T.,.F.,{||  },'BAIXO',{||  })
                
		oScr1 := oLayer:getWinPanel('DIR','WinDC','CIMA')

		
		oWinEC := oLayer:getWinPanel('ESQ','WinEC','CIMA')

		oWinEB := oLayer:getWinPanel('ESQ','WinEB','BAIXO')
		
		oWinDB := oLayer:getWinPanel('DIR','WinDB','BAIXO')
		//oWinDB:Align:= CONTROL_ALIGN_ALLCLIENT

		
		oBtn1 := TBtnBmp2():New( 01,02,26,26,'FINAL',,,,{||oDlg:end()},oWinEC,,,.T. )
		oBtn1:cTooltip:="Sair"
    
		oBtn2 := TBtnBmp2():New( 01,32,26,26,'COMPTITL',,,,{||OuWizard(oLayer,oBtn2,cGet1,cConteudo,cCombo3,cCombo4,cBank,cAgency,cAccount)},oWinEC,,,.T. )
		oBtn2:cTooltip:="Concíliar títulos"

		//oBtn3 := TBtnBmp2():New( 01,62,26,26,'S4WB016N',,,,{||msginfo("Em desenvolvimento")},oWinEC,,,.T. )
		//oBtn3:cTooltip:="Ajuda"
		
		
		//<------> primeiro retângulo do lado DIREITO - CIMA
/*	   	@ 00,01 TO 16,(aPosObj[1][4])-75 LABEL "" PIXEL OF oScr1
		
		@ 04,05 SAY "Banco: " SIZE 100,10 OF oScr1 PIXEL
	
		cGetD1	:= space(30)
		oGetD1:= TGet():New(03,25,{|u| if(PCount()>0,cGetD1:=u,cGetD1)}, oScr1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD1')

		@ 04,95 SAY "Conta: " SIZE 100,10 OF oScr1 PIXEL
		
		cGetD2	:= space(30)
		oGetD2:= TGet():New(03,115,{|u| if(PCount()>0,cGetD2:=u,cGetD2)}, oScr1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD2')
 
 		@ 04,205 SAY "Data de: " SIZE 100,10 OF oScr1 PIXEL
		
		cGetD3	:= space(30)
		oGetD3:= TGet():New(03,230,{|u| if(PCount()>0,cGetD3:=u,cGetD3)}, oScr1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD3')


 		@ 04,295 SAY "Data ate: " SIZE 100,10 OF oScr1 PIXEL
		
		cGetD4	:= space(30)
		oGetD4:= TGet():New(03,320,{|u| if(PCount()>0,cGetD4:=u,cGetD4)}, oScr1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD4')

 		@ 04,425 SAY "Usuário: " SIZE 100,10 OF oScr1 PIXEL
		
		cGetD5	:= UsrFullName(__cUserID)
		oGetD5:= TGet():New(03,455,{|u| if(PCount()>0,cGetD5:=u,cGetD5)}, oScr1,65,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD5')
        
		oGetD1:Disable()
		oGetD2:Disable()
		oGetD3:Disable()
		oGetD4:Disable()
		oGetD5:Disable()
*/		
cGetD1:=cGetD2:=cGetD3:=cGetD4:=cGetD5:=""		

		//<------> FIM Primeito Retângulo do lado DIREITO - CIMA

		//<------> Segundo retângulo do lado DIREITO - CIMA
		//@ 18,01 TO 32,(aPosObj[1][4])-75 LABEL "" PIXEL OF oScr1
        //17

		@ 01,05 SAY "Saldo Anterior(Bancario): " SIZE 100,10 OF oScr1 PIXEL
		cGetD5_Atu:= 0
		@ 01,75 SAY cGetD5_Atu Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL

		@ 01,150 SAY "Saldo Atual(Bancario): " SIZE 100,10 OF oScr1 PIXEL
		cGetD6_Atu:= 0
		@ 01,225 SAY cGetD6_Atu Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL
//diferença: 7		
		//@ 08,05 SAY "Saldo Previsto(Bancario): " SIZE 100,10 OF oScr1 PIXEL
		//cGetD6	:= 0
		//@ 08,75 SAY cGetD6 Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL
		
		//cGetD6	:= space(30)
		//oGetD6:= TGet():New(19,35,{|u| if(PCount()>0,cGetD6:=u,cGetD6)}, oScr1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD6')
		
		@ 01,295 SAY "Saldo Atual(Conciliado): " SIZE 100,10 OF oScr1 PIXEL
		cGetD7_Atu	:= 0
		@ 01,365 SAY cGetD7_Atu Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL

		@ 08,295 SAY "Saldo Previsto(Conciliado): " SIZE 100,10 OF oScr1 PIXEL
		cGetD7	:= 0
		@ 08,365 SAY cGetD7 Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL

		@ 08,05 SAY "Vlr Não Conc. Recebido: " SIZE 100,10 OF oScr1 PIXEL
		cGetDRec:= 0
		@ 08,75 SAY cGetDRec Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL

		@ 08,150 SAY "Vlr Não Conc. Pago: " SIZE 100,10 OF oScr1 PIXEL
		cGetDPag	:= 0
		@ 08,225 SAY cGetDPag Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL

		@ 15,05 SAY "Conciliados Receber: " SIZE 100,10 OF oScr1 PIXEL
		cQtDocRec:= 0
		@ 15,75 SAY cQtDocRec SIZE 100,10 OF oScr1 PIXEL

		@ 22,05 SAY "Conciliados Pagar: " SIZE 100,10 OF oScr1 PIXEL
		cQtDocPag:= 0
		@ 22,75 SAY cQtDocPag SIZE 100,10 OF oScr1 PIXEL

		@ 15,150 SAY "Valor Conc. Recebido: " SIZE 100,10 OF oScr1 PIXEL
		cConcRec	:= 0
		@ 15,225 SAY cConcRec Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL

		@ 22,150 SAY "Valor Conc. Pago: " SIZE 100,10 OF oScr1 PIXEL
		cConcPag	:= 0
		@ 22,225 SAY cConcPag Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL		
       
   		DbSelectArea("SA6")
   		SA6->(DbSetOrder(1))
   		DbSeek(xFilial("SA6")+SUBSTR(cBank,1,TamSX3("A6_COD")[1])+SUBSTR(cAgency,1,TamSX3("A6_AGENCIA")[1])+SUBSTR(cAccount,1,TamSX3("A6_NUMCON")[1]))
        cContaCont:=alltrim(SA6->A6_CONTA)
        
		@ 01,440 SAY "Saldo Contábil("+cContaCont+"): " SIZE 100,10 OF oScr1 PIXEL
		cGetD8_Atu	:= 0
		@ 01,545 SAY cGetD8_Atu Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL


		//@ 08,295 SAY "Saldo Previsto Conta("+cContaCont+"): " SIZE 100,10 OF oScr1 PIXEL
		//cGetD8	:= 0
		//@ 08,395 SAY cGetD8 Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScr1 PIXEL								
		
		//cGetD7	:= space(30)
		//oGetD7:= TGet():New(19,115,{|u| if(PCount()>0,cGetD7:=u,cGetD7)}, oScr1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGetD7')
        
		//<------> FIM Segundo Retângulo do lado DIREITO - CIMA

cGetD6:=cGetD8:=""

        oFont1:= TFont():New('Arial',,-14,,.f.)
		oFont2:= TFont():New('Constantia',,-14,,.F.)
		

    ACTIVATE DIALOG oDlg CENTERED ON INIT( IIF( Barpross(cGet1,@oBrowse,@oBrowseD,@oWinEB,@oWinDB,@cGetD1,@cGetD2,@cGetD3,@cGetD4,cCombo1,cCombo2,@cConteudo,@cGetD6,@cGetD7,cBank,cAgency,cAccount,@cGetD5_Atu,@cGetD6_Atu,@cGetD7_Atu,@cGetD8_Atu,cContaCont,@cGetD8,@cQtDocRec,@cQtDocPag,@cConcRec,@cConcPag,@cGetDRec,@cGetDPag,dDtaIni,dDtaFim),(oDlg:FreeChildren(),oDlg:Refresh()),oDlg:End())) 


Return


/*
Funcao      : BrowEsq()
Parametros  : oMeter,oDlg1,oBrowse,oScr3,cGet1,cGet2,cCombo,aAllGroup,aAllTab,oTButton2
Retorno     : 
Objetivos   : Função para processar os dados
Autor       : Matheus Massarotto
Data/Hora   : 21/05/2013	11:10
*/

*-------------------------------------------------------------------------------------------------*
Static function BrowEsq(oWinEB,oBrowse,oDlg1,oOfx,oMeter,cGetDRec,cQtDocRec,cConcRec,cGetDPag,cQtDocPag,cConcPag,cGetD7)
*-------------------------------------------------------------------------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB" OF oWinEB			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(MARCA=="1",'CHECKOK',IIF(MARCA=="2",'',IIF(MARCA=="3","LBTIK",IIF(MARCA=="5","CADEADO","LBNO") ))) } DOUBLECLICK { |oBrowse| MarcTari(@cGetDRec,@cQtDocRec,@cConcRec,@cGetDPag,@cQtDocPag,@cConcPag,@cGetD7)/* RecLock("DADTRB",.F.),MARCA:=!MARCA, DADTRB->(MsUnlock())  Função que atualiza a regra*/ }  OF oBrowse

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || TIPO 		} TITLE "Tipo"   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 20 OF oBrowse		
ADD COLUMN oColumn DATA { || DATAOP    	} TITLE "Data" 				DOUBLECLICK  {||  }	ALIGN 1 SIZE  8 OF oBrowse		
ADD COLUMN oColumn DATA { || VALOR    	} TITLE "Valor"				DOUBLECLICK  {||  }	ALIGN 1 SIZE 16 OF oBrowse	
ADD COLUMN oColumn DATA { || MEMO    	} TITLE "Descrição"			DOUBLECLICK  {||  }	ALIGN 1 SIZE 50 OF oBrowse	

//Coloca cor no browse
oBrowse:SetBlkBackColor({|| SetaCor() })

//Bara de botões do browse esquerdo
oTBar := TBar():New( oWinEB,45,32,.T.,,,,.F. )
oTBtnBmp1 := TBtnBmp() :NewBar('SVM',,,,'Legenda',{||Legenda("ESQ")},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Legenda"  

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

//Encerra a barra
oDlg1:end()

Return(.T.)

/*
Funcao      : ()
Parametros  : oMeter,oDlg1,oBrowse,oScr3,cGet1,cGet2,cCombo,aAllGroup,aAllTab,oTButton2
Retorno     : 
Objetivos   : Função para processar os dados
Autor       : Matheus Massarotto
Data/Hora   : 21/05/2013	11:10
*/

*------------------------------------*
Static function BrowDir(oScr,oBrowse,oDlg1,oOfx,oMeter,oBrowseE,cGetD7,cGetD6,cGetD8,cGetDRec,cGetDPag,cQtDocRec,cQtDocPag,cConcRec,cConcPag)
*------------------------------------*
Local oTBtnBmp1,oTBtnBmp2,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB1" OF oScr

//oBrowse:aColumns[1]:lImage:=!oBrowse:aColumns[1]:lImage
                                                                                           

//Adiciona coluna para marcar e desmarcar                                                                                                                                                                                        //oBrowse:Refresh(.T.) posiciona no inicio após o refresh
ADD MARKCOLUMN oColumn DATA { || If(MARCA=="1"/* Função com a regra*/,'LBOK',IIF(MARCA=="2",'LBNO','CADEADO')) } DOUBLECLICK { |oBrowse| MarcBDir(oBrowseE,oBrowse,@cGetD7,@cGetD6,@cGetD8,@cGetDRec,@cGetDPag,@cQtDocRec,@cQtDocPag,@cConcRec,@cConcPag)/* Função que atualiza a regra*/ }  OF oBrowse		

//Adiciona coluna para status
ADD STATUSCOLUMN oColumn DATA { || If(LSTATUS/* Função com a regra*/,'BR_VERDE','BR_MARROM') } DOUBLECLICK { |oBrowse| /* Função executada no duplo clique na coluna*/ } OF oBrowse

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || DDATA 		} TITLE "Data"  			DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE 10 OF oBrowse 
ADD COLUMN oColumn DATA { || TIPO 		} TITLE "Tipo"  			DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE 10 OF oBrowse 
ADD COLUMN oColumn DATA { || PREFIXO 	} TITLE "Prefixo"  			DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE  3 OF oBrowse 
ADD COLUMN oColumn DATA { || TITULO 	} TITLE "Titulo"   			DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE  6 OF oBrowse 
ADD COLUMN oColumn DATA { || TIPOTIT 	} TITLE "Tipo título"		DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE  3 OF oBrowse 
ADD COLUMN oColumn DATA { || VALOR	 	} TITLE "Valor"   			DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE 20 OF oBrowse		
ADD COLUMN oColumn DATA { || VLRLIQ	 	} TITLE "Valor Liquido" 	DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE 20 OF oBrowse		
ADD COLUMN oColumn DATA { || CLIFOR		} TITLE "Cli/Forn" 			DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE 50 OF oBrowse 
ADD COLUMN oColumn DATA { || OBS		} TITLE "Observação"		DOUBLECLICK  {|| WaitAxVi(DADTRB1->TABELA,DADTRB1->R_E_C_N_O_,DADTRB1->TIPO) }  SIZE 25 OF oBrowse 

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

//oBrowse:OBROWSE:bLostFocus:={|| ValidDir()}

//oBrowse:OBROWSE:bValid :={|| ValidDir()}

//oBrowse:LineOk({|| ValidDir()}) 

//oBrowse:SetLineOk ({|| ValidDir()})

//oBrowse:SetAllOk()
//oBrowse:OBROWSE:lOutGet:=.T.
                                 

//Bara de botões do browse direito
oTBar := TBar():New( oScr,25,32,.T.,,,,.F. )

//oTBtnBmp1 := TBtnBmp() :NewBar('SDUAPPEND',,,,'Adicionar título',{|| IncTitDi(),oBrowse:Refresh(),oBrowseE:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
//oTBtnBmp1:cTooltip:="Adicionar título"

//oTBtnBmp3 := TBtnBmp() :NewBar('BAIXATIT',,,,'Adicionar Mov. Bancário',{|| IncMovB(),oBrowse:Refresh(),oBrowseE:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
//oTBtnBmp3:cTooltip:="Adicionar Mov. Bancário"

oTBtnBmp1 := TBtnBmp() :NewBar('SDUAPPEND',,,,'Adicionar título',{|| BuscaTit(oBrowse,oBrowseE,@cGetD7,@cGetD6,@cGetD8),oBrowse:Refresh(),oBrowseE:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Adicionar título"

oTBtnBmp2 := TBtnBmp() :NewBar('SVM',,,,'Legenda',{||Legenda("DIR")},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp2:cTooltip:="Legenda"  

Return(.T.)

/*
Funcao      : Relacao()  
Parametros  : 
Retorno     : 
Objetivos   : Seta a relação do browse esquerdo(Informações do arquivo) com o browse direito(Títulos do sistema)
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*-----------------------------------------*
Static function Relacao(oBrowseE,oBrowseD)
*-----------------------------------------*

oRelac:=FWBrwRelation():New()
oRelac:AddRelation( @oBrowseE , @oBrowseD , { { 'ID2','ID' } } )
oRelac:Activate()

Return


/*
Funcao      : Barpross()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 16/05/2013	15:14
*/
*-------------------------------------------------------------------------------------------------------------------*
Static Function Barpross(cGet1,oBrowse,oBrowseD,oWinEB,oWinDB,cGetD1,cGetD2,cGetD3,cGetD4,cCombo1,cCombo2,cConteudo,cGetD6,cGetD7,cBank,cAgency,cAccount,cGetD5_Atu,cGetD6_Atu,cGetD7_Atu,cGetD8_Atu,cConta,cGetD8,cQtDocRec,cQtDocPag,cConcRec,cConcPag,cGetDRec,cGetDPag,dDtaIni,dDtaFim)
*-------------------------------------------------------------------------------------------------------------------*
Local lTemMark	:= .F.
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

//Fazendo as validações

	if empty(cGet1)
	    Alert("Por favor informar o arquivo para processamento!","Atenção")
		Return(.F.)
	endif
	

//Fim - Fazendo as validações
    
	//Verifico se o objeto ja foi utilizado para limpá-lo antes da próxima pesquisa
	if valtype(oBrowse)=="O"
		oBrowse:DeActivate()   //Desabilito o objeto do browse
		oBrowseD:DeActivate()   //Desabilito o objeto do browse

		oWinEB:FreeChildren() //Libero todos os objetos da classe onde este método é chamado
		oWinEB:Refresh()

		oWinDB:FreeChildren() //Libero todos os objetos da classe onde este método é chamado
		oWinDB:Refresh()
	endif

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=ProcDado(cGet1,oDlg1,oWinEB,oWinDB,@oBrowse,@oBrowseD,@cGetD1,@cGetD2,@cGetD3,@cGetD4,oMeter,cCombo1,cCombo2,@cConteudo,@cGetD6,@cGetD7,cBank,cAgency,cAccount,@cGetD5_Atu,@cGetD6_Atu,@cGetD7_Atu,@cGetD8_Atu,cConta,@cGetD8,@cQtDocRec,@cQtDocPag,@cConcRec,@cConcPag,@cGetDRec,@cGetDPag,dDtaIni,dDtaFim))
	  
	//***********************************************************

Return(lRet)

/*
Funcao      : ProcDado()  
Parametros  : 
Retorno     : 
Objetivos   : Processa os dados e carrega o temporário
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*-------------------------------------------------------------------------------------------------------------------------------*
Static Function	ProcDado(cGet1,oDlg1,oWinEB,oWinDB,oBrowse,oBrowseD,cGetD1,cGetD2,cGetD3,cGetD4,oMeter,cCombo1,cCombo2,cConteudo,cGetD6,cGetD7,cBank,cAgency,cAccount,cGetD5_Atu,cGetD6_Atu,cGetD7_Atu,cGetD8_Atu,cConta,cGetD8,cQtDocRec,cQtDocPag,cConcRec,cConcPag,cGetDRec,cGetDPag,dDtaIni,dDtaFim)
*-------------------------------------------------------------------------------------------------------------------------------*
Local nCont	:= 0 //Variável para controle de títulos encontrados
Local cETar	:= ""

Local lSaldoAtu := .F.
Local lSaldoAnt	:= .F.

Local aRetVal	:= {}

Local lSoConc	:= GETNEWPAR( "MV_P_OFXB" , .F. )

//Faz a leitura do arquivo retornando o objeto com a estrutuda do OFX
oOfx := OFX():New(cGet1)
    
cConteudo:=oOfx:CCONTEUDO
    
    //Valido se o banco do arquivo é o mesmo do selecionado pelo usuário
	/*if alltrim(UPPER(cGetD1))<>RIGHT(alltrim(UPPER(oOfx:BANKACCTFROM:BANKID)),3)
    	oDlg1:End()
    	Alert("O banco selecionado é diferente do contido no arquivo!","Atenção")
    	Return(.F.)
	endif
	*/
	if valtype(oOfx)=="O"
		//Preenche as informações dos dados do arquivo
		cGetD1:=oOfx:BANKACCTFROM:BANKID
		cGetD2:=oOfx:BANKACCTFROM:ACCTID
		cGetD3:=DTOC(STOD(oOfx:BANKTRANLIST:DTSTART))
		cGetD4:=DTOC(STOD(oOfx:BANKTRANLIST:DTEND))
		

		// <Inicio> - Preenchimento dos saldos iniciais
		dbSelectArea( "SE8" )
		SE8->(DbSetOrder(1))
		//SE8->(dbSeek( xFilial("SE8")+cBank+cAgency+cAccount+DTOS(CTOD(cGetD4)),.T. ))
		SE8->(dbSeek( xFilial("SE8")+cBank+cAgency+cAccount+DTOS(dDtaFim),.T. ))
		If E8_BANCO != cBank .or. E8_AGENCIA != cAgency .or. E8_CONTA != cAccount .or.; 			//DTOS(CTOD(cGetD4)) != DTOS(E8_DTSALAT) .or. BOF() .or. EOF()
			DTOS(dDtaFim) != DTOS(E8_DTSALAT) .or. BOF() .or. EOF()
			dbSkip(-1)    
			lSaldoAtu := ! (E8_BANCO+E8_AGENCIA+E8_CONTA != cBank+cAgency+cAccount .or. BOF() .or. EOF())
		Else
			lSaldoAtu := .T.
		Endif	 
		     
		// Atualiza o valor do saldo atual
		If !lSaldoAtu
			cGetD7_Atu:=cGetD7	:= 0	//Saldo atual (Reconciliados)
			cGetD6_Atu:=cGetD6	:= 0	//Saldo atual (Bancario)
		Else
			cGetD6_Atu:=cGetD6	:= ROUND(E8_SALATUA,2)	//Saldo atual (Reconciliados)
			cGetD7_Atu:=cGetD7	:= ROUND(E8_SALRECO,2)	//Saldo atual (Reconciliados)
		EndIf
        
		// Saldo anterior
		dbSelectArea( "SE8" )
		SE8->(DbSetOrder(1))
		SE8->(dbSeek( xFilial("SE8")+cBank+cAgency+cAccount+DTOS(dDtaIni),.T. ))
		If E8_BANCO != cBank .or. E8_AGENCIA != cAgency .or. E8_CONTA != cAccount .or.;
			DTOS(dDtaIni) != DTOS(E8_DTSALAT) .or. BOF() .or. EOF()
			dbSkip(-1)    
			lSaldoAnt := ! (E8_BANCO+E8_AGENCIA+E8_CONTA != cBank+cAgency+cAccount .or. BOF() .or. EOF())
		Else
			dbSkip(-1)
			lSaldoAnt := .T.
		Endif	 
		     
		// Atualiza o valor do saldo anterior
		If !lSaldoAnt

			cGetD5_Atu:=cGetD6	:= 0	//Saldo anterior (Bancario)
		Else
			cGetD5_Atu:=cGetD6	:= ROUND(E8_SALATUA,2)	//Saldo anterior (Reconciliados)

		EndIf

        
  		//--------Saldo da conta contábil, continuar aki
  		//SaldoCt7(cConta,dData,cMoeda,cTpSald)
  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno:                                             ³
		//³ [1] Saldo Atual (com sinal)                          ³
		//³ [2] Debito na Data                                   ³
		//³ [3] Credito na Data                                  ³
		//³ [4] Saldo Atual Devedor                              ³
		//³ [5] Saldo Atual Credor                               ³
		//³ [6] Saldo Anterior (com sinal)                       ³
		//³ [7] Saldo Anterior Devedor                           ³
		//³ [8] Saldo Anterior Credor                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
  		aRetVal		:= SaldoCt7(cConta,CTOD(cGetD4),"01","01")
  		cGetD8:=cGetD8_Atu  := aRetVal[1]
       
        // <Fim> - Preenchimento dos saldos iniciais
		
    else
    	Alert("Não foi possível processar o arquivo informado!","Atenção")
    	oMeter:End()
    	Return(.F.)
    endif
    

//-->Tabela temporária para o lado esquerdo
aDadTemp	:= {}
MensErro	:= ""


AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"TIPO"		,"C",20,0})
AADD(aDadTemp,{"DATAOP"		,"D",8 ,0})
AADD(aDadTemp,{"VALOR"		,"C",14,0})
AADD(aDadTemp,{"MEMO"		,"C",50,0})
AADD(aDadTemp,{"ID"			,"C",10,0})
AADD(aDadTemp,{"IDBANCO"	,"C",20,0})

if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB",cIndex,"ID",,,"Selecionando Registro...")  
IndRegua("DADTRB",cIndex2,"DATAOP",,,"Selecionando Registro...")  

DbSelectArea("DADTRB")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


//-->Tabela temporária para o lado direito
aDadTemp	:= {}
cMensErro	:= ""

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"LSTATUS"	,"L",1,0})
AADD(aDadTemp,{"TABELA"		,"C",3,0})
AADD(aDadTemp,{"TIPO"		,"C",15,0})
AADD(aDadTemp,{"PREFIXO"	,"C",TamSX3("E1_PREFIXO")[1],0})
AADD(aDadTemp,{"TITULO"		,"C",TamSX3("E1_NUM")[1]	,0})
AADD(aDadTemp,{"PARCELA"	,"C",TamSX3("E1_PARCELA")[1],0})
AADD(aDadTemp,{"TIPOTIT"	,"C",TamSX3("E1_TIPO")[1]	,0})
AADD(aDadTemp,{"VALOR"		,"N",14,2})
AADD(aDadTemp,{"VLRLIQ"		,"N",14,2})
AADD(aDadTemp,{"CLIFOR"		,"C",50,0})
AADD(aDadTemp,{"DDATA"		,"D",8,0})
AADD(aDadTemp,{"OBS"		,"C",25,0})
AADD(aDadTemp,{"R_E_C_N_O_"	,"N",6,0})
AADD(aDadTemp,{"IDBANCO"	,"C",20,0})
AADD(aDadTemp,{"ID2"		,"C",10,0})

if select("DADTRB1")>0
	DADTRB1->(DbCloseArea())
endif



// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB1",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB1",cIndex,"ID2",,,"Selecionando Registro...")  
IndRegua("DADTRB1",cIndex2,"PREFIXO+TITULO",,,"Selecionando Registro...")  

DbSelectArea("DADTRB1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)



//// Carrega a tabela temporária com as informações

if valtype(oOfx)=="O"
	
	//de quanto em quanto a regua deve aumentar
	nAumenta:= 100/(len(oOfx:BANKTRANLIST:STMTTRN)/100)

	for h:=1 to len(oOfx:BANKTRANLIST:STMTTRN)
  	    
  	    //Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=nAumenta 	// atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua
        
        cETar:= "2"
        
        //Verifica se o lançamento é tarifa
		if VerifTar(oOfx:BANKACCTFROM:BANKID,oOfx:BANKTRANLIST:STMTTRN[h]:MEMO)[1]
        	//verifico se é para processar tarifa/rendimentos
        	if UPPER(alltrim(cCombo2))=="NAO"
        		loop
        	endif  
        	
        	cETar:= "4"
		endif
		
		//Verifico se n deve processar nenhuma modalidade
		if UPPER(alltrim(cCombo1)) $ "SOMENTE TARIFA" .AND. cETar<>"4"
			loop	
		endif
		
		//verifico se é para processar contas a receber, a pagar
		if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE)) == "CREDIT" .AND. UPPER(alltrim(cCombo1)) $ "CONTAS A PAGAR" .AND. cETar<>"4"
			loop
		elseif alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE)) == "DEBIT" .AND. UPPER(alltrim(cCombo1)) $ "CONTAS A RECEBER"  .AND. cETar<>"4"
			loop
		endif
		
	    Reclock("DADTRB",.T.)

			DADTRB->MARCA		:= cETar	    
			DADTRB->TIPO		:= oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE
			DADTRB->DATAOP		:= STOD(SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8))
			DADTRB->VALOR		:= cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
			DADTRB->MEMO		:= oOfx:BANKTRANLIST:STMTTRN[h]:MEMO
			DADTRB->ID			:= cvaltochar(h) //Numeração sequencial
			DADTRB->IDBANCO		:= alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)
			
		DADTRB->(MsUnlock())

        //SE FOR TARIFA
        if cETar $ "3/4"
        	//loop
        	
        	//Verifico se a tarifa ja foi incluída para ser apresentada como conciliada
			cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
			cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND E5_P_IDOFX = '"+alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)+"'"
			cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
			cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"'"        	

        	if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif

			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

			Count to nRecCount

		  	if nRecCount>0

 				QRYTEMP->(DbGotop())


				While QRYTEMP->(!EOF())

				    Reclock("DADTRB1",.T.)

						DADTRB1->MARCA		:= "3"
						DADTRB1->LSTATUS	:= .F.
						DADTRB1->TABELA		:= QRYTEMP->TABELA
						DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
						DADTRB1->TIPO		:= QRYTEMP->TIPO
						DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
						DADTRB1->TITULO		:= QRYTEMP->TITULO
						DADTRB1->PARCELA	:= QRYTEMP->PARCELA
						DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
						DADTRB1->VALOR		:= QRYTEMP->VALOR
						DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
						DADTRB1->CLIFOR		:= QRYTEMP->NOME
						DADTRB1->IDBANCO	:= QRYTEMP->IDBANCO
						DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
						DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
						DADTRB1->OBS		:= "Conciliado pela rotina"
					
					DADTRB1->(MsUnlock())
					
			        //Atualizo a quantidade de documentos conciliados
			  		if alltrim(DADTRB->TIPO)="CREDIT"
						cQtDocRec:=(cQtDocRec)+1
						cConcRec:=cConcRec+DADTRB1->VALOR
					else
						cQtDocPag:=(cQtDocPag)+1
						cConcPag:=cConcPag+DADTRB1->VALOR
					endif
					
					QRYTEMP->(DbSkip())
					
		        Enddo
				
				// Preencho como título já conciliado(Cadeado)
				Reclock("DADTRB",.F.)
					DADTRB->MARCA	:= "5"
				DADTRB->(MsUnlock())
        	
        	else
           		//Atualizo o valor de items não conciliados  
        		if alltrim(DADTRB->TIPO)="CREDIT"
        			cGetDRec:=cGetDRec+val(DADTRB->VALOR)
        	    else
        	    	cGetDPag:=cGetDPag+val(DADTRB->VALOR)
        	    endif
        	    
        	endif

        	loop
		endif
        
        //** Se o parametro estiver para verificar os títulos em aberto
        if lSoConc
	        
			//BUSCA DOS TÍTULOS ABERTOS NO SISTEMA
			if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE)) == "CREDIT" .AND. UPPER(alltrim(cCombo1)) $ "AMBAS/CONTAS A RECEBER"
	
			 /*	cQry:=" SELECT 'SE1' AS 'TABELA','RECEBER' AS 'TIPO', E1_EMISSAO AS 'DDATA',E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO',E1_PARCELA AS 'PARCELA',E1_TIPO AS 'TIPOTIT',E1_VALOR AS 'VALOR',E1_NOMCLI AS 'NOME',R_E_C_N_O_  FROM "+RETSQLNAME("SE1")
				cQry+=" WHERE D_E_L_E_T_='' AND E1_SALDO>0 "//AND E1_TIPO='NF'
				cQry+=" AND E1_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' AND E1_CONTA LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'
				cQry+=" AND E1_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
				cQry+=" AND E1_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
				cQry+=" AND E1_FILIAL = '"+xFilial("SE1")+"'"
	        */
                
				cQry:=" SELECT * FROM (
	          	cQry+=" SELECT 'SE1' AS 'TABELA','RECEBER' AS 'TIPO', E1_EMISSAO AS 'DDATA',E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO',E1_PARCELA AS 'PARCELA',E1_TIPO AS 'TIPOTIT',E1_VALOR AS 'VALOR',E1_NOMCLI AS 'NOME',R_E_C_N_O_"
				  //--CRIO A COLUNA DE SALDO LIQUIDO
				cQry+=" ,E1_SALDO - ISNULL(("
				cQry+=" SELECT SUM(E1_SALDO)"
				cQry+=" FROM "+RETSQLNAME("SE1") 
				cQry+=" WHERE E1_FILIAL  = SE1.E1_FILIAL  and E1_PREFIXO  = SE1.E1_PREFIXO  and E1_NUM  = SE1.E1_NUM  and E1_PARCELA  = SE1.E1_PARCELA "
				cQry+=" and E1_TIPO LIKE '%-'  and  (E1_CLIENTE  = SE1.E1_CLIENTE  or E1_CLIENTE  = 'UNIAO ' )  and  (E1_LOJA  = SE1.E1_LOJA "
				cQry+=" or E1_CLIENTE  = 'UNIAO ' )  and E1_EMISSAO <= '"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"' and D_E_L_E_T_  <> '*' "
				cQry+=" ),0) AS SALDOLIQ"

				cQry+=" FROM "+RETSQLNAME("SE1")+" AS SE1"

				cQry+=" WHERE SE1.D_E_L_E_T_='' AND SE1.E1_SALDO>0"
				cQry+=" AND SE1.E1_TIPO NOT LIKE '%-'"
				cQry+=" AND SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
				cQry+=" AND SE1.E1_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'"
				cQry+=" AND SE1.E1_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"'"
				cQry+=" ) AS TEMP
				cQry+=" WHERE TEMP.SALDOLIQ = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))

			elseif alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE)) == "DEBIT" .AND. UPPER(alltrim(cCombo1)) $ "AMBAS/CONTAS A PAGAR"
				
			/*	cQry:=" SELECT 'SE2' AS 'TABELA','PAGAR' AS 'TIPO',E2_EMISSAO AS 'DDATA',E2_PREFIXO AS 'PREFIXO',E2_NUM AS 'TITULO',E2_PARCELA AS 'PARCELA',E2_TIPO AS 'TIPOTIT',E2_VALOR AS 'VALOR',E2_NOMFOR AS 'NOME',R_E_C_N_O_  FROM "+RETSQLNAME("SE2")
				cQry+=" WHERE D_E_L_E_T_='' AND E2_SALDO>0 "//AND E2_TIPO='NF'
				//cQry+=" AND E2_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' "
				cQry+=" AND E2_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
				cQry+=" AND E2_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
				cQry+=" AND E2_FILIAL = '"+xFilial("SE2")+"'"
	        */
                
				cQry:=" SELECT * FROM (
				cQry+=" SELECT 'SE2' AS 'TABELA','PAGAR' AS 'TIPO',E2_EMISSAO AS 'DDATA',E2_PREFIXO AS 'PREFIXO',E2_NUM AS 'TITULO',E2_PARCELA AS 'PARCELA',E2_TIPO AS 'TIPOTIT',E2_VALOR AS 'VALOR',E2_NOMFOR AS 'NOME',R_E_C_N_O_  
				cQry+=" ,
				cQry+=" (CASE WHEN 
				
				cQry+=" ISNULL((
				cQry+=" SELECT SUM(CASE WHEN E2_SALDO>0 THEN (E2_VALOR-E2_SALDO) ELSE E2_VALOR END) AS VRLBAIXADO FROM "+RETSQLNAME("SE2")
				cQry+=" WHERE E2_FORNECE=SE2.E2_FORNECE AND E2_LOJA=SE2.E2_LOJA
				cQry+=" AND D_E_L_E_T_=''
				cQry+=" AND E2_BAIXA BETWEEN '"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,6)+"01"+"' AND '"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,6)+"31"+"'"
				cQry+=" ),0)+SE2.E2_SALDO
				cQry+=" >= "+cvaltochar(GETMV("MV_VL10925")) //Valor a ser considerado para verificação do PCC
				
				cQry+=" THEN SE2.E2_SALDO-(SE2.E2_COFINS+SE2.E2_PIS+SE2.E2_CSLL)
				cQry+=" -	ISNULL((
				cQry+=" 	SELECT SUM(E2_SALDO)
				cQry+="     FROM "+RETSQLNAME("SE2") 
				cQry+="     WHERE E2_FILIAL  = SE2.E2_FILIAL  and E2_PREFIXO  = SE2.E2_PREFIXO  and E2_NUM  = SE2.E2_NUM  and E2_PARCELA  = SE2.E2_PARCELA 
				cQry+="     and E2_TIPO LIKE '%-' and E2_FORNECE  = SE2.E2_FORNECE  and E2_LOJA  = SE2.E2_LOJA  and E2_EMISSAO  <= CONVERT(nvarchar(30), GETDATE(), 112) 
				cQry+="     and D_E_L_E_T_  <> '*' 
				cQry+=" 	),0)
				
				cQry+=" ELSE
				cQry+=" E2_SALDO
				cQry+=" END ) AS SALDOLIQ
				
				cQry+=" FROM "+RETSQLNAME("SE2")+" SE2"
				cQry+=" WHERE SE2.D_E_L_E_T_='' AND SE2.E2_SALDO>0 AND SE2.E2_TIPO NOT LIKE '%-'"
				cQry+=" AND SE2.E2_FILIAL = '"+xFilial("SE2")+"'"
		        cQry+=" ) AS TEMP"
				cQry+=" WHERE TEMP.SALDOLIQ = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))

			else
				loop
			endif
	            
	            //Tratamento para contas a receber e a pagar em aberto
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
	
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
				Count to nRecCount
	            
				nCont:=0
	
		  	    if nRecCount>0
	
		 			QRYTEMP->(DbGotop())
					
								
					While QRYTEMP->(!EOF())
					     	    
			            nCont++
					    Reclock("DADTRB1",.T.)
	
							DADTRB1->MARCA		:= "2"	    							    
							DADTRB1->LSTATUS	:= .T.
							DADTRB1->TABELA		:= QRYTEMP->TABELA
							DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
							DADTRB1->TIPO		:= QRYTEMP->TIPO
							DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
							DADTRB1->TITULO		:= QRYTEMP->TITULO
							DADTRB1->PARCELA	:= QRYTEMP->PARCELA
							DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
							DADTRB1->VALOR		:= QRYTEMP->VALOR
							DADTRB1->VLRLIQ		:= QRYTEMP->SALDOLIQ
							DADTRB1->CLIFOR		:= QRYTEMP->NOME
							DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
							DADTRB1->IDBANCO	:= alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)
							DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
						
						DADTRB1->(MsUnlock())
						QRYTEMP->(DbSkip())
					Enddo
									
				endif
	//Desenvolver o valor do movimento - impostos para encontrar o valor no E5            
	//SomaAbat((cAliasSe1)->E1_PREFIXO,(cAliasSe1)->E1_NUM,(cAliasSe1)->E1_PARCELA,"R",1,dDataBase,(cAliasSe1)->E1_CLIENTE,(cAliasSe1)->E1_LOJA)
	
			    // -- Nova Função -- Tratamento para apresentar movimentação bancária já conciliada
	/*			cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
				cQry+=" WHERE D_E_L_E_T_=''
				cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' AND E5_CONTA LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'
				cQry+=" AND E5_DATA<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
				cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
				cQry+=" AND E5_P_IDOFX = '"+alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)+"'"
				cQry+=" AND E5_RECONC<>''
	*/
	
				//BUSCA DE MOVIMENTO BANCÁRIO CONCILIADO - pela rotina
				cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
				//cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND ( E5_P_IDOFX = '"+alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)+"' OR E5_P_IDOFX ='' )"
	            cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND ( E5_P_IDOFX = '"+alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)+"')"
	            if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
					cQry+=" AND E5_RECPAG='R'
				else
					cQry+=" AND E5_RECPAG='P'
				endif
				/*cQry+=" AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA IN (
				
				if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
					cQry+=" SELECT E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA  FROM "+RETSQLNAME("SE1")
					cQry+=" WHERE D_E_L_E_T_='' AND E1_SALDO=0
					cQry+=" AND E1_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' AND E1_CONTA LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'
					cQry+=" AND E1_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
					cQry+=" AND E1_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
					cQry+=" AND E1_FILIAL = '"+xFilial("SE1")+"'"
					cQry+=" )
				else
					cQry+=" SELECT E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA  FROM "+RETSQLNAME("SE2")
					cQry+=" WHERE D_E_L_E_T_='' AND E2_SALDO=0
					//cQry+=" AND E2_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"'"
					cQry+=" AND E2_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
					cQry+=" AND E2_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
					cQry+=" AND E2_FILIAL = '"+xFilial("SE2")+"'"
					cQry+=" )
				endif
	            */
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
	
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
				Count to nRecCount
			  	
			  	if nRecCount>0
	
	 				QRYTEMP->(DbGotop())
			
			
					While QRYTEMP->(!EOF())
			    
					    Reclock("DADTRB1",.T.)
	
							DADTRB1->MARCA		:= "3"
							DADTRB1->LSTATUS	:= .F.
							DADTRB1->TABELA		:= QRYTEMP->TABELA
							DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
							DADTRB1->TIPO		:= QRYTEMP->TIPO
							DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
							DADTRB1->TITULO		:= QRYTEMP->TITULO
							DADTRB1->PARCELA	:= QRYTEMP->PARCELA
							DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
							DADTRB1->VALOR		:= QRYTEMP->VALOR
							DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
							DADTRB1->CLIFOR		:= QRYTEMP->NOME
							DADTRB1->IDBANCO	:= QRYTEMP->IDBANCO
							DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
							DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
							DADTRB1->OBS		:= "Conciliado pela rotina"
												
						DADTRB1->(MsUnlock())
						QRYTEMP->(DbSkip())
						
			        Enddo
					
					// Preencho como título já conciliado(Cadeado)
					Reclock("DADTRB",.F.)
						DADTRB->MARCA	:= "5"
					DADTRB->(MsUnlock())
			        
			        //Atualizo a quantidade de documentos conciliados
			  		if alltrim(DADTRB->TIPO)="CREDIT"
						cQtDocRec:=(cQtDocRec)+1
						cConcRec:=cConcRec+DADTRB1->VALOR
					else
						cQtDocPag:=(cQtDocPag)+1
						cConcPag:=cConcPag+DADTRB1->VALOR
					endif
								    
			    	loop    
				
				else
                
	            	//VERIFICO SE FOI CONCILIADO PELO SISTEMA
	            
       				cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
		            cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND ( E5_P_IDOFX = '')"
					cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
					cQry+=" AND E5_FILIAL = '"+xFilial("SE5")+"'"
		            cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' "
		            cQry+=" AND E5_DATA>='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
		                
		            if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
						cQry+=" AND E5_RECPAG='R'
					else
						cQry+=" AND E5_RECPAG='P'
					endif
	
					if select("QRYTEMP")>0
						QRYTEMP->(DbCloseArea())
					endif
		
					DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
					Count to nRecCount
				  	
				  	if nRecCount>0
		
		 				QRYTEMP->(DbGotop())
				
				
						While QRYTEMP->(!EOF())
				    
						    Reclock("DADTRB1",.T.)
		
								DADTRB1->MARCA		:= "3"
								DADTRB1->LSTATUS	:= .F.
								DADTRB1->TABELA		:= QRYTEMP->TABELA
								DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
								DADTRB1->TIPO		:= QRYTEMP->TIPO
								DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
								DADTRB1->TITULO		:= QRYTEMP->TITULO
								DADTRB1->PARCELA	:= QRYTEMP->PARCELA
								DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
								DADTRB1->VALOR		:= QRYTEMP->VALOR
								DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
								DADTRB1->CLIFOR		:= QRYTEMP->NOME
								DADTRB1->IDBANCO	:= QRYTEMP->IDBANCO
								DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
								DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
								DADTRB1->OBS		:= "Conciliado pelo padrão"    
							
							DADTRB1->(MsUnlock())
							QRYTEMP->(DbSkip())
							
				        Enddo
						
						// Preencho como título já conciliado(Cadeado)
						Reclock("DADTRB",.F.)
							DADTRB->MARCA	:= "5"
						DADTRB->(MsUnlock())
				    
				        //Atualizo a quantidade de documentos conciliados
				  		if alltrim(DADTRB->TIPO)="CREDIT"
							cQtDocRec:=(cQtDocRec)+1
							cConcRec:=cConcRec+DADTRB1->VALOR
						else
							cQtDocPag:=(cQtDocPag)+1
							cConcPag:=cConcPag+DADTRB1->VALOR
						endif
				    
				    	loop        
	            
		            else

	
	               		//Atualizo o valor de items não conciliados  
		        		if alltrim(DADTRB->TIPO)="CREDIT"
		        			cGetDRec:=cGetDRec+val(DADTRB->VALOR)
		        	    else
		        	    	cGetDPag:=cGetDPag+val(DADTRB->VALOR)
		        	    endif
		                
		                //Tratamento para apresentar a movimentação bancária para conciliação
					
						/*
						cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
						cQry+=" WHERE D_E_L_E_T_=''
						cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' AND E5_CONTA LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'
						cQry+=" AND E5_DATA<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
						cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
						cQry+=" AND E5_RECONC=''
			            */
		                /*
						cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
						cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC=''
		                if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
							cQry+=" AND E5_RECPAG='R'
						else
							cQry+=" AND E5_RECPAG='P'
						endif
						cQry+=" AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA IN (
		                
		                if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
							cQry+=" SELECT E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA  FROM "+RETSQLNAME("SE1")
							cQry+=" WHERE D_E_L_E_T_='' AND E1_SALDO=0
							cQry+=" AND E1_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' AND E1_CONTA LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'"
							cQry+=" AND E1_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
							cQry+=" AND E1_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
							cQry+=" AND E1_FILIAL = '"+xFilial("SE1")+"'"
							cQry+=" )
						else
							cQry+=" SELECT E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA  FROM "+RETSQLNAME("SE2")
							cQry+=" WHERE D_E_L_E_T_='' AND E2_SALDO=0
							//cQry+=" AND E2_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"'"
							cQry+=" AND E2_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
							cQry+=" AND E2_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
							cQry+=" AND E2_FILIAL = '"+xFilial("SE2")+"'"
							cQry+=" )				
						endif
						*/
						
						cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA' ,E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
						cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC='' "
						cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
						cQry+=" AND E5_FILIAL = '"+xFilial("SE5")+"'"
		                cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"'"
		                //cQry+=" AND REPLACE( REPLACE(E5_CONTA,'-',''),'.','') LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'"
		                cQry+=" AND E5_DATA>='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
						       
						if select("QRYTEMP")>0
							QRYTEMP->(DbCloseArea())
						endif
			
						DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
						Count to nRecCount
					  	
					  	if nRecCount>0
		
			 				QRYTEMP->(DbGotop())
		
							While QRYTEMP->(!EOF())
							    
							    nCont++
							    Reclock("DADTRB1",.T.)
			
									DADTRB1->MARCA		:= "2"
									DADTRB1->LSTATUS	:= .F.
									DADTRB1->TABELA		:= QRYTEMP->TABELA
									DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
									DADTRB1->TIPO		:= QRYTEMP->TIPO
									DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
									DADTRB1->TITULO		:= QRYTEMP->TITULO
									DADTRB1->PARCELA	:= QRYTEMP->PARCELA
									DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
									DADTRB1->VALOR		:= QRYTEMP->VALOR
									DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
									DADTRB1->CLIFOR		:= QRYTEMP->NOME
									DADTRB1->IDBANCO	:= alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)
									DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
									DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
								
								DADTRB1->(MsUnlock())
								QRYTEMP->(DbSkip())
								
					        Enddo
					        
					  	endif
	                
	                endif
	                
				endif

        //** Se o parametro estiver somente para verificar o movimento bancário
        else

				//BUSCA DE MOVIMENTO BANCÁRIO CONCILIADO - pela rotina customizada
				cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
				//cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND ( E5_P_IDOFX = '"+alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)+"' OR E5_P_IDOFX ='' )"
	            cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND ( E5_P_IDOFX = '"+alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)+"')"
	            if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
					cQry+=" AND E5_RECPAG='R'
				else
					cQry+=" AND E5_RECPAG='P'
				endif

				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
	
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
				Count to nRecCount
			  	
			  	if nRecCount>0
	
	 				QRYTEMP->(DbGotop())
			
			
					While QRYTEMP->(!EOF())
			    
					    Reclock("DADTRB1",.T.)
	
							DADTRB1->MARCA		:= "3"
							DADTRB1->LSTATUS	:= .F.
							DADTRB1->TABELA		:= QRYTEMP->TABELA
							DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
							DADTRB1->TIPO		:= QRYTEMP->TIPO
							DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
							DADTRB1->TITULO		:= QRYTEMP->TITULO
							DADTRB1->PARCELA	:= QRYTEMP->PARCELA
							DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
							DADTRB1->VALOR		:= QRYTEMP->VALOR
							DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
							DADTRB1->CLIFOR		:= QRYTEMP->NOME
							DADTRB1->IDBANCO	:= QRYTEMP->IDBANCO
							DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
							DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
							DADTRB1->OBS		:= "Conciliado pela rotina"
							
						DADTRB1->(MsUnlock())
						QRYTEMP->(DbSkip())
						
			        Enddo
					
					// Preencho como título já conciliado(Cadeado)
					Reclock("DADTRB",.F.)
						DADTRB->MARCA	:= "5"
					DADTRB->(MsUnlock())
			    
			        //Atualizo a quantidade de documentos conciliados
			  		if alltrim(DADTRB->TIPO)="CREDIT"
						cQtDocRec:=(cQtDocRec)+1
						cConcRec:=cConcRec+DADTRB1->VALOR
					else
						cQtDocPag:=(cQtDocPag)+1
						cConcPag:=cConcPag+DADTRB1->VALOR
					endif
			    
			    	loop    
				
				else
	            	
	            	//VERIFICO SE FOI CONCILIADO PELO SISTEMA
	            
       				cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
		            cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC<>'' AND ( E5_P_IDOFX = '')"
					cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
					cQry+=" AND E5_FILIAL = '"+xFilial("SE5")+"'"
		            cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' "
		            cQry+=" AND E5_DATA>='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
		                
		            if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
						cQry+=" AND E5_RECPAG='R'
					else
						cQry+=" AND E5_RECPAG='P'
					endif
	
					if select("QRYTEMP")>0
						QRYTEMP->(DbCloseArea())
					endif
		
					DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
					Count to nRecCount
				  	
				  	if nRecCount>0
		
		 				QRYTEMP->(DbGotop())
				
				
						While QRYTEMP->(!EOF())
				    
						    Reclock("DADTRB1",.T.)
		
								DADTRB1->MARCA		:= "3"
								DADTRB1->LSTATUS	:= .F.
								DADTRB1->TABELA		:= QRYTEMP->TABELA
								DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
								DADTRB1->TIPO		:= QRYTEMP->TIPO
								DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
								DADTRB1->TITULO		:= QRYTEMP->TITULO
								DADTRB1->PARCELA	:= QRYTEMP->PARCELA
								DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
								DADTRB1->VALOR		:= QRYTEMP->VALOR
								DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
								DADTRB1->CLIFOR		:= QRYTEMP->NOME
								DADTRB1->IDBANCO	:= QRYTEMP->IDBANCO
								DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
								DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
								DADTRB1->OBS		:= "Conciliado pelo padrão"
								
							DADTRB1->(MsUnlock())
							QRYTEMP->(DbSkip())
							
				        Enddo
						
						// Preencho como título já conciliado(Cadeado)
						Reclock("DADTRB",.F.)
							DADTRB->MARCA	:= "5"
						DADTRB->(MsUnlock())
				    
				        //Atualizo a quantidade de documentos conciliados
				  		if alltrim(DADTRB->TIPO)="CREDIT"
							cQtDocRec:=(cQtDocRec)+1
							cConcRec:=cConcRec+DADTRB1->VALOR
						else
							cQtDocPag:=(cQtDocPag)+1
							cConcPag:=cConcPag+DADTRB1->VALOR
						endif
				    
				    	loop        
	            
	            
	                else
	            
	               		//Atualizo o valor de items não conciliados  
		        		if alltrim(DADTRB->TIPO)="CREDIT"
		        			cGetDRec:=cGetDRec+val(DADTRB->VALOR)
		        	    else
		        	    	cGetDPag:=cGetDPag+val(DADTRB->VALOR)
		        	    endif
		                
		                //Tratamento para apresentar a movimentação bancária para conciliação
					
						cQry:=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA' ,E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',E5_P_IDOFX AS 'IDBANCO',R_E_C_N_O_  FROM "+RETSQLNAME("SE5")
						cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC='' "
						cQry+=" AND E5_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
						cQry+=" AND E5_FILIAL = '"+xFilial("SE5")+"'"
		                cQry+=" AND E5_BANCO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' "
		                //cQry+=" AND REPLACE( REPLACE(E5_CONTA,'-',''),'.','') LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'"
		                cQry+=" AND E5_DATA>='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
		                
		                if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
							cQry+=" AND E5_RECPAG='R'
						else
							cQry+=" AND E5_RECPAG='P'
						endif
						//cQry+=" AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA IN (
		                /*
		                if alltrim(UPPER(oOfx:BANKTRANLIST:STMTTRN[h]:TRNTYPE))=="CREDIT"
							cQry+=" SELECT E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA  FROM "+RETSQLNAME("SE1")
							cQry+=" WHERE D_E_L_E_T_='' AND E1_SALDO=0
							cQry+=" AND E1_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"' AND E1_CONTA LIKE '%"+ cvaltochar(val(oOfx:BANKACCTFROM:ACCTID)) +"'"
							cQry+=" AND E1_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
							cQry+=" AND E1_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
							cQry+=" AND E1_FILIAL = '"+xFilial("SE1")+"'"
							cQry+=" )
						else
							cQry+=" SELECT E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA  FROM "+RETSQLNAME("SE2")
							cQry+=" WHERE D_E_L_E_T_='' AND E2_SALDO=0
							//cQry+=" AND E2_PORTADO LIKE '%"+ RIGHT(oOfx:BANKACCTFROM:BANKID,3) +"'"
							cQry+=" AND E2_EMISSAO<='"+SUBSTR(oOfx:BANKTRANLIST:STMTTRN[h]:DTPOSTED,1,8)+"'
							cQry+=" AND E2_VALOR = "+cvaltochar(ABS(oOfx:BANKTRANLIST:STMTTRN[h]:TRNAMT))
							cQry+=" AND E2_FILIAL = '"+xFilial("SE2")+"'"
							cQry+=" )				
						endif
						*/
						       
						if select("QRYTEMP")>0
							QRYTEMP->(DbCloseArea())
						endif
			
						DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
						Count to nRecCount
					  	
					  	if nRecCount>0
		
			 				QRYTEMP->(DbGotop())
		
							While QRYTEMP->(!EOF())
							    
							    nCont++
							    Reclock("DADTRB1",.T.)
			
									DADTRB1->MARCA		:= "2"
									DADTRB1->LSTATUS	:= .F.
									DADTRB1->TABELA		:= QRYTEMP->TABELA
									DADTRB1->DDATA		:= STOD(QRYTEMP->DDATA)
									DADTRB1->TIPO		:= QRYTEMP->TIPO
									DADTRB1->PREFIXO	:= QRYTEMP->PREFIXO
									DADTRB1->TITULO		:= QRYTEMP->TITULO
									DADTRB1->PARCELA	:= QRYTEMP->PARCELA
									DADTRB1->TIPOTIT	:= QRYTEMP->TIPOTIT
									DADTRB1->VALOR		:= QRYTEMP->VALOR
									DADTRB1->VLRLIQ		:= QRYTEMP->VALOR
									DADTRB1->CLIFOR		:= QRYTEMP->NOME
									DADTRB1->IDBANCO	:= alltrim(oOfx:BANKTRANLIST:STMTTRN[h]:FITID)
									DADTRB1->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
									DADTRB1->ID2		:= cvaltochar(h) //Numeração sequencial
								
								DADTRB1->(MsUnlock())
								QRYTEMP->(DbSkip())
								
					        Enddo
					        
					  	endif
	            	
	            	endif
	            	
				endif        
        

        endif   
         
			/*
			//Marco a tabela do lado esquerdo e direito caso só tenha uma opção
			if nCont==1
				
				//Se não for mov. bancário
				if DADTRB1->LSTATUS
					Reclock("DADTRB1",.F.)
						DADTRB1->MARCA	:= "1"
					DADTRB1->(MsUnlock())
				
					Reclock("DADTRB",.F.)
						DADTRB->MARCA	:= "1"
					DADTRB->(MsUnlock())
				else
					Reclock("DADTRB1",.F.)
						DADTRB1->MARCA	:= "2"
					DADTRB1->(MsUnlock())
				
					Reclock("DADTRB",.F.)
						DADTRB->MARCA	:= "2"
					DADTRB->(MsUnlock())				
				endif
			endif
            */
	next

endif


	//******** Carrega os browses
    
    //Carrega as informações do browse esquerdo
    BrowEsq(@oWinEB,@oBrowse,oDlg1,oOfx,oMeter,@cGetDRec,@cQtDocRec,@cConcRec,@cGetDPag,@cQtDocPag,@cConcPag,@cGetD7)
	
	//Carrega as informações do browse direito
	BrowDir(@oWinDB,@oBrowseD,oDlg1,oOfx,oMeter,oBrowse,@cGetD7,@cGetD6,@cGetD8,@cGetDRec,@cGetDPag,@cQtDocRec,@cQtDocPag,@cConcRec,@cConcPag)
	
	//Adiciona relação dos browses
	Relacao(oBrowse,oBrowseD)

Return(.T.)


/*
Funcao      : WaitAxVi()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	15:14
*/
*-------------------------------------------------*
Static Function WaitAxVi(cAlias,nReg,cTipo)
*-------------------------------------------------*
Local oDlg2
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg2 TITLE "Abrindo..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg2,70,34,,.T.,,,,,,,,,)
	    
	  ACTIVATE DIALOG oDlg2 CENTERED ON INIT(lRet:=Visual(cAlias,nReg,oMeter,oDlg2,cTipo))
	  
	//*************************************

Return(lRet)                                                             

/*
Funcao      : Visual()
Parametros  : 
Retorno     : 
Objetivos   : Função para visualizar o resgistro posicionado
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	11:10
*/
*------------------------------------------------------------*
Static Function Visual(cAlias,nReg,oMeter,oDlg2,cTipo)
*------------------------------------------------------------*
Local nOpc		:= 2
Local lMaximized:= .T.
Local aArea 	:= GetArea() 

Private	cCadastro:= "Título a "+capital(cTipo) //Variavel q é responsável pelo título da dialog do AXVISUAL

//Inicia a régua
oMeter:Set(0)
oMeter:Set(98) //posiciona no fim da regua

	&(cAlias)->(DbGoTo(nReg))
	AXVISUAL(cAlias, nReg, nOpc, , , , , , lMaximized )


oDlg2:end()

ChkFile(cAlias)

RestArea(aArea)
Return

/*
Funcao      : SetaCor()  
Parametros  : 
Retorno     : 
Objetivos   : Função para colocar cor na linha do browse esquerdo(Títulos do arquivo)
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*------------------------*
Static Function SetaCor()
*------------------------*
Local nCor		:= RGB(255,255,255) //Branco
Local lTemMarc	:= .F.
Local cRec		:= DADTRB1->(RECNO())
Local lTemRef   := .F.


DbSelectArea("DADTRB1")
DADTRB1->(DbSetOrder(2))
DADTRB1->(DbSeek(DADTRB->ID))

While DADTRB1->(!EOF()) .AND. DADTRB1->ID2==DADTRB->ID
//	if DADTRB1->MARCA
//	  	lTemMarc:= .T.
//	endif
	
	lTemRef:=.T.
	
	DADTRB1->(DbSkip())
Enddo


if DADTRB->MARCA=="1" .AND. lTemMarc
	nCor:= RGB(0,255,128) //Verde
elseif lTemRef
	nCor:= RGB(255,255,0) //Amarelo
elseif DADTRB->MARCA $ "3/4"
	nCor:= RGB(128,128,128) //Cinza
else	
	nCor:= RGB(255,0,0) //Vermelho
endif


//Voltando para o registro que estava posicionado no browse do lado direito
DADTRB1->(DbGoTo(cRec))

Return(nCor)

/*
Funcao      : MarcBDir()  
Parametros  : 
Retorno     : 
Objetivos   : Função para marcar o browse do lado direito, fazendo os esquemas com o browse esquerdo
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*-----------------------------------------*
Static Function MarcBDir(oBrowseE,oBrowse,cGetD7,cGetD6,cGetD8,cGetDRec,cGetDPag,cQtDocRec,cQtDocPag,cConcRec,cConcPag)
*-----------------------------------------*
Local cRec	:= DADTRB1->(RECNO())

/*
if DADTRB1->(MARCA)=="2"

	DbSelectArea("DADTRB1")
	DADTRB1->(DbGoTop())
	DADTRB1->(DbSetOrder(2))
	DADTRB1->(DbSeek(DADTRB->ID))

	While DADTRB1->(!EOF()) .AND. DADTRB1->ID2==DADTRB->ID
        //Tratamento para o saldo prévio
		if DADTRB1->MARCA=="1"
			if DADTRB1->LSTATUS
   				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
					SE1->(DbGoto(DADTRB1->R_E_C_N_O_))

					//Valor liquido a ser baixado
					cGetD6-= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
			    	cGetD8-= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
			    else
					SE2->(DbGoto(DADTRB1->R_E_C_N_O_))

					//Valor liquido a ser baixado
					cGetD6+= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
			    	cGetD8+= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
			    endif
			else
				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
					cGetD7-=ROUND(DADTRB1->VALOR,2)
				else
					cGetD7+=ROUND(DADTRB1->VALOR,2)
				endif
			endif
		endif

		RecLock("DADTRB1",.F.)
			DADTRB1->MARCA:="2"
		DADTRB1->(MsUnlock())

		DADTRB1->(DbSkip())

	Enddo

endif
*/
	DADTRB1->(DbGoTo(cRec))

if DADTRB1->(MARCA)<>"3"

		RecLock("DADTRB1",.F.)
			DADTRB1->MARCA:=IIF(DADTRB1->MARCA=="1","2","1") 
		DADTRB1->(MsUnlock())

		//Se tiver marcado do lado direito, já marco do lado esquerdo
		if DADTRB1->MARCA=="1"	
			if DADTRB1->LSTATUS
				RecLock("DADTRB",.F.)	
					DADTRB->MARCA:="1"
				DADTRB->(MsUnlock())

   				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
					SE1->(DbGoto(DADTRB1->R_E_C_N_O_))

					//Valor liquido a ser baixado
					cGetD6+= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
					cGetD8+= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
			    
	    		
			    
			    nValTemp:=ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
			    
			    cGetD7+=nValTemp
			    
			    cGetDRec	-= nValTemp
			    cQtDocRec	+= 1
			    cConcRec	+= nValTemp
			    
			    else
					SE2->(DbGoto(DADTRB1->R_E_C_N_O_))

					//Valor liquido a ser baixado
					cGetD6-= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
					cGetD8-= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
				
				nValTemp:=ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
				
				cGetD7-=nValTemp
					
				cGetDPag 	-= nValTemp
				cQtDocPag	+= 1
				cConcPag	+= nValTemp
			    
			    endif

			else
				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
					cGetD7+=ROUND(DADTRB1->VALOR,2)

			    cGetDRec	-= ROUND(DADTRB1->VALOR,2)
			    cQtDocRec	+= 1
			    cConcRec	+= ROUND(DADTRB1->VALOR,2)
				
				else
					cGetD7-=ROUND(DADTRB1->VALOR,2)
				    
				cGetDPag 	-= ROUND(DADTRB1->VALOR,2)
				cQtDocPag	+= 1
				cConcPag	+= ROUND(DADTRB1->VALOR,2)
				
				endif

				RecLock("DADTRB",.F.)	
					DADTRB->MARCA:="1"
				DADTRB->(MsUnlock())
			endif
	    else

			//Se for movimento bancário
			if !DADTRB1->LSTATUS
				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
					cGetD7-=ROUND(DADTRB1->VALOR,2)

			    cGetDRec	+= ROUND(DADTRB1->VALOR,2)
			    cQtDocRec	-= 1
			    cConcRec	-= ROUND(DADTRB1->VALOR,2)

				else
					cGetD7+=ROUND(DADTRB1->VALOR,2)

				cGetDPag 	+= ROUND(DADTRB1->VALOR,2)
				cQtDocPag	-= 1
				cConcPag	-= ROUND(DADTRB1->VALOR,2)
				
				endif
			else //Se não for movimento bancário
				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
					SE1->(DbGoto(DADTRB1->R_E_C_N_O_))

					//Valor liquido a ser baixado
					cGetD6-= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
					cGetD8-= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)

                nValTemp:=ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
				
				cGetD7-=nValTemp
				
			    cGetDRec	+= nValTemp
			    cQtDocRec	-= 1
			    cConcRec	-= nValTemp
			    
			    else
					SE2->(DbGoto(DADTRB1->R_E_C_N_O_))

					//Valor liquido a ser baixado
					cGetD6+= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)			    
					cGetD8+= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)			    

				nValTemp:=ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)			    
                
				cGetD7+=nValTemp

				cGetDPag 	+= nValTemp
				cQtDocPag	-= 1
				cConcPag	-= nValTemp

			    endif			
			endif

			RecLock("DADTRB",.F.)	
				DADTRB->MARCA:="2"
			DADTRB->(MsUnlock())    
	    endif
endif

//Atualiza a linha do browse esquerdo(Títulos do banco)
oBrowseE:Refresh()//LineRefresh(oBrowseE:nAt)

oBrowse:Refresh() //Atualiza o browse direito(Títulos do sistema)

Return

/*
Funcao      : Legenda()  
Parametros  : 
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*-----------------------------*
Static Function Legenda(cLado)
*-----------------------------*
Local aLegenda:={}

DEFAULT cLado:="ESQ"

if cLado=="ESQ"
/*	aLegenda := {	{"PMSTASK3"  	,"Tarifa / Rendimento			" },;
					{"PMSTASK1"  	,"Título não encontrado 		" },;
					{"PMSTASK2"   	,"Título sem relação confirmada	" },;
					{"PMSTASK4"  	,"Título com relação confirmada	" },;
					{"CHECKOK" 		,"Título que será conciliado	" },;
					{"LBTIK"  		,"Tarifa que será incluída		" },;
					{"CADEADO" 		,"   Conciliado					" }}
*/
	aLegenda := {	{"PMSTASK3"  	,"Tarifa / Rendimento					" },;
					{"PMSTASK1"  	,"Título sem relação	 				" },;
					{"PMSTASK2"   	,"Título com relação					" },;
					{"CHECKOK" 		,"Título que será baixado / conciliado	" },;
					{"LBTIK"  		,"Tarifa que será incluída				" },;
					{"CADEADO" 		,"   Conciliado							" }}
										
elseif cLado=="DIR"
	aLegenda := {	{"BR_VERDE"  	,"Título aberto					" },;
					{"BR_MARROM"  	,"Movimento bancário			" }}
endif

BrwLegenda("Legenda","Legenda",aLegenda)

Return

/*
Funcao      : ErroLege()  
Parametros  : 
Retorno     : 
Objetivos   : Função para exibição das legendas de erro
Autor       : Matheus Massarotto
Data/Hora   : 10/06/2013
*/
*------------------------*
Static Function ErroLege()
*------------------------*
Local aLegenda := {	{"BR_VERDE"  	,"Título baixado / Movimento incluído / Conciliado				" },;
					{"BR_VERMELHO"	,"Título não baixado/ Movimento não incluído / Não conciliado	" }}

BrwLegenda("Legenda","Legenda",aLegenda)

Return

/*
Funcao      : InWizard()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard inicial para o usuário informar os dados básicos para o processamento
Autor       : Matheus Massarotto
Data/Hora   : 14/06/2013
*/
*------------------------*
Static Function InWizard()
*------------------------*
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oOk 		:= LoadBitmap( GetResources(), "LBTIK" )
Local oWizard
Local oGet1
Local cGet1 := ""

Local nPanel
Local aWiz 		:= {{"","","","",""}}
Local oLbxWiz
Local oChkTWiz
Local oChkIWiz 
Local lChkTWiz 	:= .F. 
Local lChkIWiz 	:= .F.
Local lWiz 		:= .F.
Local oBank,oAgency,oAccount
Local cBank 	:= SPACE(TamSX3("A6_COD")[1])
Local cAgency 	:= SPACE(TamSX3("A6_AGENCIA")[1])
Local cAccount 	:= SPACE(TamSX3("A6_NUMCON")[1])

Local dDtaIni	:= CTOD("//")
Local dDtaFim	:= CTOD("//")

Local oTBar,oTBtnPar2,oTBtnPar3,oTBtnPar4,oTBtnPar5
Local lEntrou:=.F.


//Preenche as informações dos parâmetros
DbSelectArea("Z60")
Z60->(DbSetOrder(1))
Z60->(DbGoTop())

While Z60->(!EOF())
    
    if Z60->(DELETED()) //se tiver deletado
	    Z60->(DbSkip())
    	Loop
    endif
    
    if !lEntrou
   		aWiz:={}
	endif
	
	AADD(aWiz,{Z60->Z60_TIPO,Z60->Z60_BANCO,Z60->Z60_DESCBC,Z60->Z60_DESCGT,Z60->Z60_NATURE,Z60->Z60_CONTID,Z60->(RECNO())})
	Z60->(DbSkip())

    lEntrou:=.T.
Enddo

DEFINE WIZARD oWizard TITLE "Conciliação" HEADER "Processamento de arquivo OFX" MESSAGE " ";		
TEXT "Esta rotina tem como objetivo processar a movimentação bancária através de arquivo .ofx "+CRLF+"Sendo apresentado o dado do arquivo e o respectivo título encontrado no sistema para sua conciliação." PANEL;
NEXT {|| .T.} FINISH {|| .T.}

//--> PANEL 2
//Painel para a seleção do arquivo

aModal:= {'Contas a Receber','Contas a Pagar','Ambas','Somente tarifa'}
cCombo1:= aModal[3]

aTar:= {'Sim','Nao'}
cCombo2:= aTar[1]

aContabil:= {'On line','Off line'}
cCombo3:= aContabil[1]
                                  
aMostCont:= {'Sim','Nao'}
cCombo4:= aMostCont[2]

CREATE PANEL oWizard HEADER "Parâmetros" MESSAGE "Selecione os parâmetros para auxílio ao processamento." PANEL;
BACK {|| .T.} NEXT {|| If(Empty(cGet1), (MsgStop("Informe o arquivo a ser processado!"), .F.), If(Empty(cCombo1) .OR. Empty(cCombo2), (MsgStop('Por favor informe todas as parametrizações acima.'), .F.), .T. ))} FINISH {|| .T.} EXEC {|| .T.}	

@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL

@ 21,20 SAY oSay1 VAR "Arquivo: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL                                                       	
oGet1:= TGet():New(20,85,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oWizard:oMPanel[2],140,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')


	oTButton := TButton():New( 16, 230, "       ",oWizard:oMPanel[2],{||ProcArq(@cGet1) },15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    // O CSS abaixo irá inserir uma imagem posicionada à esquerda/superior do botão,     
    oTButton:SetCss("QPushButton{ background-image: url(rpo:SDUOPEN.png);"+; //Pasta
                     " background-repeat: none; margin: 1px;}")
	oTButton :cTooltip = "Procurar arquivo"
	
oGet1:Disable()

@ 41,20 SAY oSay2 VAR "Modalidade: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oCombo1:= tComboBox():New(40,85,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aModal,100,20,oWizard:oMPanel[2],,{||},,,,.T.,,,,,,,,,'cCombo1')

@ 61,20 SAY oSay3 VAR "Processa tarifa?: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oCombo2:= tComboBox():New(60,85,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aTar,100,20,oWizard:oMPanel[2],,{||},,,,.T.,,,,,,,,,'cCombo2')

@ 81,20 SAY oSay4 VAR "Contabiliza?: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oCombo3:= tComboBox():New(80,85,{|u|if(PCount()>0,cCombo3:=u,cCombo3)},aContabil,100,20,oWizard:oMPanel[2],,{||},,,,.T.,,,,,,,,,'cCombo3')

@ 101,20 SAY oSay5 VAR "Mostra Lanç. Contabeis?: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oCombo4:= tComboBox():New(100,85,{|u|if(PCount()>0,cCombo4:=u,cCombo4)},aMostCont,100,20,oWizard:oMPanel[2],,{||},,,,.T.,,,,,,,,,'cCombo4')

//--> PANEL 3
//Painel para a seleção do banco

CREATE PANEL oWizard HEADER "Banco" MESSAGE "Selecione o banco para a baixa." PANEL;
BACK {|| .T.} NEXT {|| If(Empty(cBank) .OR. Empty(cAgency) .OR. Empty(cAccount) .OR. Empty(dDtaIni) .OR. Empty(dDtaFim), (MsgStop("Informe os dados do banco e periodo dos dados do arquivo para baixa!"), .F.), IIF(!ExistCpo("SA6",cBank+cAgency+cAccount, 1),.F., .T. ))} FINISH {|| .T.} EXEC {|| .T.}	

@ 010, 010 TO 125,280 OF oWizard:oMPanel[3] PIXEL

@ 21,20 SAY oSay1 VAR "Banco: " SIZE 100,10 OF oWizard:oMPanel[3] PIXEL
oBank:= TGet():New(20,45,{|u| if(PCount()>0,cBank:=u,cBank)}, oWizard:oMPanel[3],30,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cBank')

	oTButton := TBtnBmp2():New( 36, 155, 25, 25, 'PESQUISA' , , , ,{|| F3SA6(@cBank,@cAgency,@cAccount)}, oWizard:oMPanel[3], , , )
	
@ 41,20 SAY oSay2 VAR "Agência: " SIZE 100,10 OF oWizard:oMPanel[3] PIXEL
oAgency:= TGet():New(40,45,{|u| if(PCount()>0,cAgency:=u,cAgency)}, oWizard:oMPanel[3],40,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cAgency')

@ 61,20 SAY oSay3 VAR "Conta: " SIZE 100,10 OF oWizard:oMPanel[3] PIXEL
oAccount:=TGet():New(60,45,{|u| if(PCount()>0,cAccount:=u,cAccount)}, oWizard:oMPanel[3],50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cAccount')

oGrp1	:= TGroup():New( 088,15,120,275,"Periodo do arquivo:",oWizard:oMPanel[3],CLR_BLACK,CLR_WHITE,.T.,.F. )

@ 101,20 SAY oSay3 VAR "Data Inicial: " SIZE 100,10 OF oWizard:oMPanel[3] PIXEL
oDtaIni:=TGet():New(100,55,{|u| if(PCount()>0,dDtaIni:=u,dDtaIni)}, oWizard:oMPanel[3],50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'dDtaIni')

@ 101,150 SAY oSay3 VAR "Data Final: " SIZE 100,10 OF oWizard:oMPanel[3] PIXEL
oDtaFim:=TGet():New(100,185,{|u| if(PCount()>0,dDtaFim:=u,dDtaFim)}, oWizard:oMPanel[3],50,05,'',{|o|IIF(dDtaFim<dDtaIni,(msgstop("Informe uma data superior a data inicial"),.F.),.T.)},,,,,,.T.,,,,,,,,,,'dDtaFim')

// --> PANEL 4
//Painel com os parametros

CREATE PANEL oWizard HEADER "Configuração" MESSAGE "Pré-configuração para tarifas/rendimentos/transferência."+CRLF+"De-PARA das descrições para inclusão na movimentação bancária." PANEL;
BACK {|| oWizard:nPanel := 4, .T.} NEXT {|| .T.} FINISH {|| (lWiz := .T., .T.) } EXEC {|| .T.}	

@ 018, 020 LISTBOX oLbxWiz FIELDS HEADER "Tipo","Banco","Tarifa banco","Nossa tarifa","Natureza"  SIZE 251, 88  OF oWizard:oMPanel[4] PIXEL
oLbxWiz:SetArray(aWiz)	
oLbxWiz:bLine := {|| {aWiz[oLbxWiz:nAt,1],aWiz[oLbxWiz:nAt,2],aWiz[oLbxWiz:nAt,3],aWiz[oLbxWiz:nAt,4],aWiz[oLbxWiz:nAt,5]}}    
oLbxWiz:Align:= CONTROL_ALIGN_ALLCLIENT


//Bara de botões do browse direito
oTBar := TBar():New( oWizard:oMPanel[4],25,32,.T.,,,,.F. )

oTBtnPar2 := TBtnBmp() :NewBar('BMPVISUAL',,,,'Visualizar',{|| AtuList("2",@aWiz,oLbxWiz),oLbxWiz:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnPar2:cTooltip:="Visualizar"

oTBtnPar3 := TBtnBmp() :NewBar('BPMSDOCI',,,,'Incluir',{|| AtuList("3",@aWiz,oLbxWiz),oLbxWiz:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnPar3:cTooltip:="Incluir"

oTBtnPar4 := TBtnBmp() :NewBar('ALT_CAD',,,,'Alterar',{|| AtuList("4",@aWiz,oLbxWiz),oLbxWiz:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnPar4:cTooltip:="Alterar"

oTBtnPar5 := TBtnBmp() :NewBar('EXCLUIR',,,,'Excluir',{|| AtuList("5",@aWiz,oLbxWiz),oLbxWiz:Refresh() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnPar5:cTooltip:="Excluir"


oWizard:oDlg:lEscClose := .F.

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. } 

If lWiz
	//Executa a rotina de processamento após a seleção dos dados no Wizard
	Principal(cGet1,cCombo1,cCombo2,cCombo3,cCombo4,cBank,cAgency,cAccount,dDtaIni,dDtaFim)
EndIf


Return

/*
Funcao      : ProcArq()
Parametros  : 
Retorno     : 
Objetivos   : Função que abre a tela para a selação do arquivo
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*----------------------------*
Static Function ProcArq(cArq)
*----------------------------*
Local cTitle		:= "Seleção de arquivos"
Local cMask 		:= "Formato OFX|*.ofx"
Local nDefaultMask 	:= 0
Local cDefaultDir  	:= "C:\"
Local nOptions		:= GETF_LOCALHARD+GETF_NETWORKDRIVE

Local aArea := GetArea()


cArq := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

Return

/*
Funcao      : IncTitDi()
Parametros  : 
Retorno     : 
Objetivos   : Função para incluir um título do lado direito do browse(Títulos do sistema)
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*-------------------------*
Static Function IncTitDi()
*-------------------------*
Local cRetorno
Local lRet	:= .F.
Local cTab	:= ""

if UPPER(alltrim(DADTRB->TIPO))=="CREDIT"
	cTab:= "SE1014"
elseif UPPER(alltrim(DADTRB->TIPO))=="DEBIT"
	cTab:= "SE2014"
endif

lRet:=CONPAD1(,,,cTab,cRetorno,,.F.  )

//Se clicou em ok
if lRet
	//Validação sobre já existir um título do lado direito
	//if DADTRB->MARCA=="1"	    
    //	MsgInfo("Não é possível incluir, pois o relacionamento já está marcado para conciliação","Informativo!")
	//	return()
	//elseif DADTRB->MARCA $ "3/4"
	if DADTRB->MARCA $ "3/4"
		MsgInfo("Não é possível incluir, pois o relacionamento se trata de uma tarifa/rendimento","Informativo!")
		return()
	elseif DADTRB->MARCA $ "5" 
		MsgInfo("Não é possível incluir, pois o relacionamento já está conciliado","Informativo!")
		return()
	endif

	if UPPER(alltrim(DADTRB->TIPO))=="CREDIT"
	    //Informativo sobre valor
		if val(DADTRB->VALOR)<>SE1->E1_VALOR
			if !MsgYesNo("Deseja mesmo incluir um título com valor diferente do relacionado?","Atenção!")
			    return()
			endif
		endif
	elseif UPPER(alltrim(DADTRB->TIPO))=="DEBIT"
	    //Informativo sobre valor
		if val(DADTRB->VALOR)<>SE2->E2_VALOR
			if !MsgYesNo("Deseja mesmo incluir um título com valor diferente do relacionado?","Atenção!")
			    return()
			endif
		endif	
	
	endif
	
	//Se for contas a receber
	if UPPER(alltrim(DADTRB->TIPO)) == "CREDIT"
	    
	    //Grava tabela do lado direito
	    Reclock("DADTRB1",.T.)

			DADTRB1->MARCA		:= "1"
			DADTRB1->TABELA		:= "SE1"
			DADTRB1->TIPO		:= "RECEBER"
			DADTRB1->PREFIXO	:= SE1->E1_PREFIXO
			DADTRB1->TITULO		:= SE1->E1_NUM
			DADTRB1->PARCELA	:= SE1->E1_PARCELA
			DADTRB1->TIPOTIT	:= SE1->E1_TIPO
			DADTRB1->VALOR		:= SE1->E1_VALOR
			DADTRB1->CLIFOR		:= SE1->E1_NOMCLI
			DADTRB1->R_E_C_N_O_	:= SE1->(RECNO())
			DADTRB1->ID2		:= DADTRB->ID
			DADTRB1->LSTATUS	:=.T.            
			DADTRB1->IDBANCO	:= DADTRB->IDBANCO

		DADTRB1->(MsUnlock())

		//Atualiza marcador do lado esquerdo
		Reclock("DADTRB",.F.)
			DADTRB->MARCA		:= "1"
		DADTRB1->(MsUnlock())

	elseif UPPER(alltrim(DADTRB->TIPO)) == "DEBIT"
	    
	    //Grava tabela do lado direito
	    Reclock("DADTRB1",.T.)
	        
			DADTRB1->MARCA		:= "1"	    							    
			DADTRB1->TABELA		:= "SE2"
			DADTRB1->TIPO		:= "PAGAR"
			DADTRB1->PREFIXO	:= SE2->E2_PREFIXO
			DADTRB1->TITULO		:= SE2->E2_NUM
			DADTRB1->PARCELA	:= SE2->E2_PARCELA
			DADTRB1->TIPOTIT	:= SE2->E2_TIPO
			DADTRB1->VALOR		:= SE2->E2_VALOR
			DADTRB1->CLIFOR		:= SE2->E2_NOMFOR
			DADTRB1->R_E_C_N_O_	:= SE2->(RECNO())
			DADTRB1->ID2		:= DADTRB->ID
			DADTRB1->LSTATUS	:=.T.
			DADTRB1->IDBANCO	:= DADTRB->IDBANCO
		
		DADTRB1->(MsUnlock())
		
		//Atualiza marcador do lado esquerdo
		Reclock("DADTRB",.F.)
			DADTRB->MARCA		:= "1"
		DADTRB1->(MsUnlock())	

	endif
	
	
endif

Return

/*
Funcao      : AtuList()
Parametros  : 
Retorno     : 
Objetivos   : Função para visualiza, incluir, alterar e excluir os dados da tabela Z60(tarifa/rendimento) de arquivo ofx
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*-----------------------------------------*
Static Function AtuList(cTipo,aWiz,oLbxWiz)
*-----------------------------------------*
Private	cCadastro:= "De/Para"

DbSelectArea("Z60")

if cTipo=="2"
	Z60->(DbGoto(aWiz[oLbxWiz:nAt,7]))
	AxVisual("Z60",aWiz[oLbxWiz:nAt,7],2)
elseif cTipo=="3"
	if AxInclui("Z60")==1
	    if empty(aWiz[1][1])
			aWiz:={}
	    endif
	    
	    AADD(aWiz,{Z60->Z60_TIPO,Z60->Z60_BANCO,Z60->Z60_DESCBC,Z60->Z60_DESCGT,Z60->Z60_NATURE,Z60->Z60_CONTID,Z60->(RECNO())}) 
	endif	    
elseif cTipo=="4"    

	if !empty(aWiz[oLbxWiz:nAt,7])
		Z60->(DbGoto(aWiz[oLbxWiz:nAt,7]))	

		if AxAltera("Z60",aWiz[oLbxWiz:nAt,7],4)==1
	    
			//Preenche as informações dos parâmetros
			DbSelectArea("Z60")
			Z60->(DbSetOrder(1))
			Z60->(DbGoTop())

			aWiz:={}

			While Z60->(!EOF())

			    if Z60->(DELETED())
				    Z60->(DbSkip())
			    	Loop
			    endif
			
				AADD(aWiz,{Z60->Z60_TIPO,Z60->Z60_BANCO,Z60->Z60_DESCBC,Z60->Z60_DESCGT,Z60->Z60_NATURE,Z60->Z60_CONTID,Z60->(RECNO())})
				Z60->(DbSkip())
			
			Enddo
			
	    endif
	else
		MsgInfo("Selecione um item para alterar!","Atenção")
	endif

elseif cTipo=="5"
	Z60->(DbGoto(aWiz[oLbxWiz:nAt,7]))
	if AxDeleta("Z60",aWiz[oLbxWiz:nAt,7],5)==2
		//Preenche as informações dos parâmetros
		DbSelectArea("Z60")
		Z60->(DbSetOrder(1))
		Z60->(DbGoTop())
		
		aWiz:={}

		While Z60->(!EOF())
		    if Z60->(DELETED())
		    	Z60->(DbSkip())
		    	Loop
		    endif
		
			AADD(aWiz,{Z60->Z60_TIPO,Z60->Z60_BANCO,Z60->Z60_DESCBC,Z60->Z60_DESCGT,Z60->Z60_NATURE,Z60->Z60_CONTID,Z60->(RECNO())})
			Z60->(DbSkip())
		
		Enddo
		
		//Se foi deletado todos, mantenho pelo menos uma linha em branco para evitar erro
		if empty(aWiz)
			AADD(aWiz,{"","","","",""})
		endif
        oLbxWiz:SetArray(aWiz)
        oLbxWiz:bLine := {|| {aWiz[oLbxWiz:nAt,1],aWiz[oLbxWiz:nAt,2],aWiz[oLbxWiz:nAt,3],aWiz[oLbxWiz:nAt,4],aWiz[oLbxWiz:nAt,5],aWiz[oLbxWiz:nAt,6]}} 
        oLbxWiz:Refresh()
        //Volto para a primeira linha
		oLbxWiz:nAt:=1
		
		
	endif

endif       

    
Return

/*
Funcao      : VerifTar()
Parametros  : 
Retorno     : 
Objetivos   : Verifica se o lançamento do arquivo é tarifa
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*--------------------------------------*
Static function VerifTar(cBanco,cDescBC)
*--------------------------------------*
Local lRet		:= .F.
Local cRet		:= ""
Local cRetTip	:= ""
Local cRetNat	:= ""
Local aRet		:= {}
Local cQry		:= ""

if len(cBanco)>3
	cBanco:=RIGHT(cBanco,3)
endif

//Verifico a descrição da tarifa igual
cQry+=" SELECT Z60_DESCGT,Z60_TIPO,Z60_NATURE FROM "+RETSQLNAME("Z60")
cQry+=" WHERE D_E_L_E_T_=''"
cQry+=" AND Z60_BANCO='"+cBanco+"' AND UPPER(Z60_DESCBC) = '"+alltrim(UPPER(cDescBC))+"' AND Z60_CONTID ='2'"

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

	Count to nRecCount  	
  	    
  	    if nRecCount>0
	        DbSelectArea("QRYTEMP")
	        QRYTEMP->(DbGoTop())
	        
	        lRet	:= .T.
	        cRet	:= QRYTEMP->Z60_DESCGT
	        cRetTip	:= QRYTEMP->Z60_TIPO
	        cRetNat	:= QRYTEMP->Z60_NATURE
	
		else  //Busco a descrição contida      
		    //continuar aqui
			//cQry+=" SELECT Z60_DESCGT,Z60_TIPO,Z60_NATURE FROM "+RETSQLNAME("Z60")
			//cQry+=" WHERE D_E_L_E_T_=''"
			//cQry+=" AND Z60_BANCO='"+cBanco+"' AND UPPER(Z60_DESCBC) LIKE '%"+alltrim(UPPER(cDescBC))+"%' AND Z60_CONTID ='1'"

			cQry:="	SELECT * FROM ( 
			cQry+=" SELECT Z60_DESCGT,Z60_TIPO,Z60_NATURE,'"+alltrim(UPPER(cDescBC))+"' AS TARI,D_E_L_E_T_,Z60_CONTID,Z60_BANCO,Z60_DESCBC FROM "+RETSQLNAME("Z60")+" ) AS TAB"
			cQry+=" WHERE TAB.D_E_L_E_T_=''"
			cQry+=" AND TAB.Z60_BANCO='"+cBanco+"' AND UPPER(TAB.TARI) LIKE '%'+LTRIM(RTRIM(TAB.Z60_DESCBC))+'%' AND TAB.Z60_CONTID ='1'"			


				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
			
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
				Count to nRecCount  	
			  	    
			  	    if nRecCount>0
				        DbSelectArea("QRYTEMP")
				        QRYTEMP->(DbGoTop())
				        
				        lRet	:= .T.
				        cRet	:= QRYTEMP->Z60_DESCGT
				        cRetTip	:= QRYTEMP->Z60_TIPO
				        cRetNat	:= QRYTEMP->Z60_NATURE

					endif
        endif
	
AADD(aRet,lRet)
AADD(aRet,cRet)
AADD(aRet,cRetTip)
AADD(aRet,cRetNat)

Return(aRet)

/*
Funcao      : MarcTari()
Parametros  : 
Retorno     : 
Objetivos   : Função para atualizar o marcador do browse esquerdo em relação as tarifas
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*------------------------*
Static function MarcTari(cGetDRec,cQtDocRec,cConcRec,cGetDPag,cQtDocPag,cConcPag,cGetD7)
*------------------------*
if DADTRB->MARCA=="3"

	RecLock("DADTRB",.F.)
		DADTRB->MARCA:="4"
	DADTRB->(MsUnlock())

	if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
	    cGetDRec	+= val(DADTRB->VALOR)
	    cQtDocRec	-= 1
	    cConcRec	-= val(DADTRB->VALOR)
	    cGetD7		-= val(DADTRB->VALOR)
    else
	    cGetDPag	+= val(DADTRB->VALOR)
	    cQtDocPag	-= 1
	    cConcPag	-= val(DADTRB->VALOR)    
	    cGetD7		+= val(DADTRB->VALOR)
    endif

elseif DADTRB->MARCA=="4"

	RecLock("DADTRB",.F.)
		DADTRB->MARCA:="3"
	DADTRB->(MsUnlock())


	if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
	    cGetDRec	-= val(DADTRB->VALOR)
	    cQtDocRec	+= 1
	    cConcRec	+= val(DADTRB->VALOR)
	    cGetD7		+= val(DADTRB->VALOR)
    else
	    cGetDPag	-= val(DADTRB->VALOR)
	    cQtDocPag	+= 1
	    cConcPag	+= val(DADTRB->VALOR)    
	    cGetD7		-= val(DADTRB->VALOR)
    endif

endif

Return

/*
Funcao      : EXEC070()
Parametros  : 
Retorno     : 
Objetivos   : Execauto do contas a receber para baixar o título
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*-------------------------------------------------------------------------------------------------------*
Static Function EXEC070(cPref,cNum,cParcela,cTipo,cBanco,cAgencia,cConta,dDataCr,nValor,cCombo3,cCombo4,cIdBanco)
*-------------------------------------------------------------------------------------------------------*
Local aBaixa 	:= {}
Local cHist		:= ""
Local aArea		:= GetArea()
Private lMsErroAuto := .F.


//dDataCr:=dDataBase

//Posiciona no título a ser baixado
DbSelectArea("SE1")
SE1->(DbSetOrder(1))
SE1->(DbSeek(xFilial("SE1")+cPref+cNum+cParcela+cTipo))

//Pego o histórico padrão igual o da baixa
cHist := Alltrim(SE1->E1_TIPO)+" "+Alltrim(SE1->E1_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE1->E1_NATUREZ,"ED_DESCRIC")

aBaixa :=  {{"E1_FILIAL"   ,xFilial("SE1")              ,Nil},;
			{"E1_PREFIXO"  ,cPref                       ,Nil},;
			{"E1_NUM"	   ,cNum                 		,Nil},;
			{"E1_PARCELA"  ,cParcela                   	,Nil},;
			{"E1_TIPO"	   ,cTipo                       ,Nil},;
			{"AUTMOTBX"	   ,"NOR"                       ,Nil},;
			{"AUTBANCO"    ,cBanco                      ,Nil},;
			{"AUTAGENCIA"  ,cAgencia            		,Nil},;
			{"AUTCONTA"    ,cConta           			,Nil},;
			{"AUTHIST"	   ,cHist			    		,Nil},;
			{"AUTDTBAIXA"  ,dDataCr                     ,Nil},;//dDataBase
			{"AUTDTCREDITO",dDataCr                  	,Nil},; //dDataCr
			{"AUTVLRPG"    ,nValor                      ,Nil}}

//			{"AUTJUROS",	0							,nIL},;



	//Pergunte, para mostra lançamentos contabeis
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("FIN070    01")
		cPreSel:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			if UPPER(ALLTRIM(cCombo4))=="NAO"
				SX1->X1_PRESEL:=2
			elseif UPPER(ALLTRIM(cCombo4))=="SIM"
				SX1->X1_PRESEL:=1			
			endif
		MsUnlock()
	endif
	//contabiliza off-line ou on-line
	if DbSeek("FIN070    04")
		cPreSel1:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			if UPPER(ALLTRIM(cCombo3))=="OFF LINE"
				SX1->X1_PRESEL:=2
			elseif UPPER(ALLTRIM(cCombo3))=="ON LINE"
				SX1->X1_PRESEL:=1			
			endif
		MsUnlock()
	endif

	

	lMsErroAuto:= .F.
	Private lMSHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	
	DbSelectArea("SE1")
	
	MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)  

	If lMsErroAuto
		//MOSTRAERRO() 
		aAutoErro := GETAUTOGRLOG()
	    cErroCon:=XLOG(aAutoErro) 

		 RecLock("ERROTRB",.T.)
			ERROTRB->LSTATUS	:= .F.
			ERROTRB->TIPO		:= "RECEBER"
			ERROTRB->INFOTIT	:= xFilial("SE1")+cPref+cNum+cParcela+cTipo
			ERROTRB->BANCO		:= cBanco
			ERROTRB->AGENCIA	:= cAgencia
			ERROTRB->CONTA		:= cConta
			ERROTRB->VALOR		:= nValor
			ERROTRB->ERRODESC	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
			ERROTRB->ERROCOMP	:= XLOGMEMO(aAutoErro)
			ERROTRB->ROTINA		:= "GTGEN014"
			ERROTRB->TABELA		:="SE1"
			ERROTRB->ORDEM		:="1"
			ERROTRB->CHAVE		:="E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
			ERROTRB->TIPOLOG	:="A" //alteração
		ERROTRB->(MsUnLock())
		    
		Return
	Else
		//Gravo o id da operação do banco 
		RecLock("SE1",.F.)
			SE1->E1_P_IDOFX	:= cIdBanco 
		SE1->(MsUnLock())
		
		Concilia(cIdBanco)
		
		RecLock("ERROTRB",.T.)
			ERROTRB->LSTATUS	:= .T.
			ERROTRB->TIPO		:= "RECEBER"
			ERROTRB->INFOTIT	:= xFilial("SE1")+cPref+cNum+cParcela+cTipo
			ERROTRB->BANCO		:= cBanco
			ERROTRB->AGENCIA	:= cAgencia
			ERROTRB->CONTA		:= cConta
			ERROTRB->VALOR		:= nValor
			ERROTRB->ERRODESC	:= "Baixado título: "+xFilial("SE1")+cPref+cNum+cParcela+cTipo+" - Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
			ERROTRB->ERROCOMP	:= "Baixado título: "+xFilial("SE1")+cPref+cNum+cParcela+cTipo+" - Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
			ERROTRB->ROTINA		:= "GTGEN014"
			ERROTRB->TABELA		:="SE1"
			ERROTRB->ORDEM		:="1"
			ERROTRB->CHAVE		:="E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
			ERROTRB->TIPOLOG	:="A" //alteração
		ERROTRB->(MsUnLock())
		
	EndIf 
	
	//Voltando o pergunte, para o que era na opção mostra lançamentos contabeis
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("FIN070    01")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPreSel
		MsUnlock()
	endif
	//Voltando o contabiliza on-line
	if DbSeek("FIN070    04")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPreSel1
		MsUnlock()
	endif

RestArea(aArea)		
Return

/*
Funcao      : EXEC080()
Parametros  : 
Retorno     : 
Objetivos   : Execauto do contas a pagar para baixar o título
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*---------------------------------------------------------------------------------------*
Static Function EXEC080(cPref,cNum,cParcela,cTipo,cBanco,cAgencia,cConta,dDataCr,nValor,cCombo3,cCombo4,cIdBanco)
*---------------------------------------------------------------------------------------* 
Local cHist		:= ""
Local aBaixa 	:= {}
Local aArea		:= GetArea()
Private lMsErroAuto := .F.
 
//Posiciona no título a ser baixado
DbSelectArea("SE2")
SE2->(DbSetOrder(1))
SE2->(DbSeek(xFilial("SE2")+cPref+cNum+cParcela+cTipo))


//Pego o histórico padrão igual o da baixa
cHist := Alltrim(SE2->E2_TIPO)+" "+Alltrim(SE2->E2_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC")
 
	AADD(aBaixa, {"E2_FILIAL"	, xFilial("SE2")	, Nil})
    AADD(aBaixa, {"E2_PREFIXO"	, cPref 			, Nil})
    AADD(aBaixa, {"E2_NUM"		, cNum 				, Nil})
    AADD(aBaixa, {"E2_PARCELA"	, cParcela 			, Nil})
    AADD(aBaixa, {"E2_TIPO" 	, cTipo				, Nil})
    //AADD(aBaixa, {"E2_FORNECE" 	, SE2->E2_FORNECE 	, Nil})
    //AADD(aBaixa, {"E2_LOJA" 	, SE2->E2_LOJA 		, Nil}) 
    AADD(aBaixa, {"AUTMOTBX" 	, "NOR"				, Nil})
    AADD(aBaixa, {"AUTBANCO" 	, cBanco			, Nil})
    AADD(aBaixa, {"AUTAGENCIA" 	, cAgencia			, Nil})
    AADD(aBaixa, {"AUTCONTA" 	, cConta			, Nil})
    AADD(aBaixa, {"AUTDTBAIXA" 	, dDataCr 			, Nil}) //dDataBase
    AADD(aBaixa, {"AUTDTCREDITO", dDataCr	 		, Nil})
    AADD(aBaixa, {"AUTHIST" 	, cHist 			, Nil})
    AADD(aBaixa, {"AUTVLRPG" 	, nValor 			, Nil})

    ACESSAPERG("FIN080", .F.)

	//Pergunte, para mostra lançamentos contabeis
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("FIN080    01")
		cPreSel:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			if UPPER(ALLTRIM(cCombo4))=="NAO"
				SX1->X1_PRESEL:=2
			elseif UPPER(ALLTRIM(cCombo4))=="SIM"
				SX1->X1_PRESEL:=1			
			endif
		MsUnlock()
	endif
	//contabiliza off-line ou on-line
	if DbSeek("FIN080    03")
		cPreSel1:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			if UPPER(ALLTRIM(cCombo3))=="OFF LINE"
				SX1->X1_PRESEL:=2
			elseif UPPER(ALLTRIM(cCombo3))=="ON LINE"
				SX1->X1_PRESEL:=1			
			endif
		MsUnlock()
	endif

	lMsErroAuto:= .F.
	Private lMSHelpAuto := .T.
	Private lAutoErrNoFile := .T.
            
    MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)
 
    If lMsErroAuto
		aAutoErro := GETAUTOGRLOG()
	    cErroCon:=XLOG(aAutoErro) 
	    
		 RecLock("ERROTRB",.T.)
			ERROTRB->LSTATUS	:= .F.
			ERROTRB->TIPO		:= "PAGAR"
			ERROTRB->INFOTIT	:= xFilial("SE2")+cPref+cNum+cParcela+cTipo
			ERROTRB->BANCO		:= cBanco
			ERROTRB->AGENCIA	:= cAgencia
			ERROTRB->CONTA		:= cConta
			ERROTRB->VALOR		:= nValor
			ERROTRB->ERRODESC	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
			ERROTRB->ERROCOMP	:= XLOGMEMO(aAutoErro)
			ERROTRB->ROTINA		:= "GTGEN014"
			ERROTRB->TABELA		:="SE2"
			ERROTRB->ORDEM		:="1"
			ERROTRB->CHAVE		:="E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
			ERROTRB->TIPOLOG	:="A" //alteração
		ERROTRB->(MsUnLock())
		
        Return .F.
    Else
		
		//Gravo o id da operação do banco 
		RecLock("SE2",.F.)
			SE2->E2_P_IDOFX	:= cIdBanco 
		SE2->(MsUnLock())
		
		Concilia(cIdBanco)
		
   		RecLock("ERROTRB",.T.)
			ERROTRB->LSTATUS	:= .T.
			ERROTRB->TIPO		:= "PAGAR"
			ERROTRB->INFOTIT	:= xFilial("SE2")+cPref+cNum+cParcela+cTipo
			ERROTRB->BANCO		:= cBanco
			ERROTRB->AGENCIA	:= cAgencia
			ERROTRB->CONTA		:= cConta
			ERROTRB->VALOR		:= nValor
			ERROTRB->ERRODESC	:= "Baixado título: "+xFilial("SE2")+cPref+cNum+cParcela+cTipo+" - Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
			ERROTRB->ERROCOMP	:= "Baixado título: "+xFilial("SE2")+cPref+cNum+cParcela+cTipo+" - Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
			ERROTRB->ROTINA		:= "GTGEN014"
			ERROTRB->TABELA		:="SE2"
			ERROTRB->ORDEM		:="1"
			ERROTRB->CHAVE		:="E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
			ERROTRB->TIPOLOG	:="A" //alteração
		ERROTRB->(MsUnLock())
		
    EndIf 


	//Voltando o pergunte, para o que era na opção mostra lançamentos contabeis
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("FIN080    01")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPreSel
		MsUnlock()
	endif
	//Voltando o contabiliza on-line
	if DbSeek("FIN080    03")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPreSel1
		MsUnlock()
	endif

RestArea(aArea)
Return

/*
Funcao      : EXEC100()
Parametros  : 
Retorno     : 
Objetivos   : Execauto do movimento bancário
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*-----------------------------------------------------------------------------------*
Static Function EXEC100(cBanco,cAgencia,cConta,dDataCr,nValor,cTipo,cDesc,cNaturez,cCombo3,cCombo4,cIdBanco)
*-----------------------------------------------------------------------------------*
Local aFINA100 	:= {}
Local cBenef	:= ""
Local cHist		:= ""
Local aArea		:= GetArea()


if cTipo=="1" //tarifa
	cBenef:="Banco: " +cBanco
elseif cTipo=="2" //Rendimento
	cBenef:=SM0->M0_NOME
endif

cHist:=alltrim(cDesc)

	
	//Pergunte, para mostra lançamentos contabeis
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("AFI100    02")
		cPreSel:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			if UPPER(ALLTRIM(cCombo4))=="NAO"
				SX1->X1_PRESEL:=2
			elseif UPPER(ALLTRIM(cCombo4))=="SIM"
				SX1->X1_PRESEL:=1			
			endif
		MsUnlock()
	endif
	//contabiliza off-line ou on-line
	if DbSeek("AFI100    04")
		cPreSel1:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			if UPPER(ALLTRIM(cCombo3))=="OFF LINE"
				SX1->X1_PRESEL:=2
			elseif UPPER(ALLTRIM(cCombo3))=="ON LINE"
				SX1->X1_PRESEL:=1
			endif
		MsUnlock()
	endif


	lMsErroAuto:= .F.
	Private lMSHelpAuto := .T.
	Private lAutoErrNoFile := .T.
   
    If cTipo == "1"   //Mov. Banc. a pagar
        aFINA100 := {    	{"E5_FILIAL"	,xFilial("SE5")         ,Nil},;
        					{"E5_DATA"		,dDataCr	            ,Nil},;//dDataCr
                            {"E5_MOEDA"     ,"M1"                   ,Nil},;
                            {"E5_VALOR"     ,nValor                 ,Nil},;
                            {"E5_NATUREZ"	,cNaturez               ,Nil},;
                            {"E5_BANCO"     ,cBanco                 ,Nil},;
                            {"E5_AGENCIA"   ,cAgencia               ,Nil},;
                            {"E5_CONTA"     ,cConta                 ,Nil},;
                            {"E5_BENEF"     ,cBenef    				,Nil},;
                            {"E5_HISTOR"    ,cHist     				,Nil},;
						    {"E5_VENCTO"	,dDataCr	            ,Nil}}
		BEGIN TRANSACTION
						    
        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
    
        If lMsErroAuto
			aAutoErro := GETAUTOGRLOG()
		    cErroCon:=XLOG(aAutoErro) 
		    
		    DisarmTransaction()
		    
			 RecLock("ERROTRB",.T.)
				ERROTRB->LSTATUS	:= .F.
				ERROTRB->TIPO		:= "MOV. BANCARIA"
				ERROTRB->INFOTIT	:= ""
				ERROTRB->BANCO		:= cBanco
				ERROTRB->AGENCIA	:= cAgencia
				ERROTRB->CONTA		:= cConta
				ERROTRB->VALOR		:= nValor
				ERROTRB->ERRODESC	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
				ERROTRB->ERROCOMP	:= XLOGMEMO(aAutoErro)
				ERROTRB->ROTINA		:= "GTGEN014"
				ERROTRB->TABELA		:="SE5"
				ERROTRB->ORDEM		:="1"
				ERROTRB->CHAVE		:="E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
				ERROTRB->TIPOLOG	:="I" //inclusão
			ERROTRB->(MsUnLock())
	        Return .F.
        Else
	   	
   			//Gravo o id da operação do banco 
			RecLock("SE5",.F.)
				SE5->E5_P_IDOFX	:= cIdBanco 
			SE5->(MsUnLock())
				
			Concilia(cIdBanco)
	   	
	   		RecLock("ERROTRB",.T.)
				ERROTRB->LSTATUS	:= .T.
				ERROTRB->TIPO		:= "MOV. BANCARIA"
				ERROTRB->INFOTIT	:= ""
				ERROTRB->BANCO		:= cBanco
				ERROTRB->AGENCIA	:= cAgencia
				ERROTRB->CONTA		:= cConta
				ERROTRB->VALOR		:= nValor
				ERROTRB->ERRODESC	:= "Incluída mov. bancaria(pagar) - Filial:"+xFilial("SE5")+", Data:"+DTOC(dDataCr)+", Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
				ERROTRB->ERROCOMP	:= "Incluída mov. bancaria(pagar) - Filial:"+xFilial("SE5")+", Data:"+DTOC(dDataCr)+", Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
				ERROTRB->ROTINA		:= "GTGEN014"
				ERROTRB->TABELA		:="SE5"
				ERROTRB->ORDEM		:="1"
				ERROTRB->CHAVE		:="E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
				ERROTRB->TIPOLOG	:="I" //inclusão
			ERROTRB->(MsUnLock())
        EndIf       
        
        END TRANSACTION
        
    ElseIf cTipo == "2" //Mov. Banc. a receber
        aFINA100 := {    	{"E5_DATA"		,dDataCr	            ,Nil},;
                            {"E5_MOEDA"     ,"M1"                   ,Nil},;
                            {"E5_VALOR"     ,nValor                 ,Nil},;
                            {"E5_NATUREZ"	,cNaturez               ,Nil},;
                            {"E5_BANCO"     ,cBanco                 ,Nil},;
                            {"E5_AGENCIA"   ,cAgencia               ,Nil},;
                            {"E5_CONTA"     ,cConta                 ,Nil},;
                            {"E5_BENEF"     ,cBenef    				,Nil},;
                            {"E5_HISTOR"    ,cHist     				,Nil},;
						    {"E5_VENCTO"	,dDataCr	            ,Nil}}
						                                
        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,4)
    
        If lMsErroAuto
			aAutoErro := GETAUTOGRLOG()
		    cErroCon:=XLOG(aAutoErro) 
		    
			 RecLock("ERROTRB",.T.)
				ERROTRB->LSTATUS	:= .F.
				ERROTRB->TIPO		:= "MOV. BANCARIA"
				ERROTRB->INFOTIT	:= ""
				ERROTRB->BANCO		:= cBanco
				ERROTRB->AGENCIA	:= cAgencia
				ERROTRB->CONTA		:= cConta
				ERROTRB->VALOR		:= nValor
				ERROTRB->ERRODESC	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
				ERROTRB->ERROCOMP	:= XLOGMEMO(aAutoErro)
				ERROTRB->ROTINA		:= "GTGEN014"
				ERROTRB->TABELA		:="SE5"
				ERROTRB->ORDEM		:="1"
				ERROTRB->CHAVE		:="E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
				ERROTRB->TIPOLOG	:="I" //inclusão
			ERROTRB->(MsUnLock())
			
	        Return .F.
        Else
  			//Gravo o id da operação do banco 
			RecLock("SE5",.F.)
				SE5->E5_P_IDOFX	:= cIdBanco 
			SE5->(MsUnLock())
				
			Concilia(cIdBanco)
	   		
	   		RecLock("ERROTRB",.T.)
				ERROTRB->LSTATUS	:= .T.
				ERROTRB->TIPO		:= "MOV. BANCARIA"
				ERROTRB->INFOTIT	:= ""
				ERROTRB->BANCO		:= cBanco
				ERROTRB->AGENCIA	:= cAgencia
				ERROTRB->CONTA		:= cConta
				ERROTRB->VALOR		:= nValor
				ERROTRB->ERRODESC	:= "Incluída mov. bancaria(receber) - Filial:"+xFilial("SE5")+", Data:"+DTOC(dDataCr)+", Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
				ERROTRB->ERROCOMP	:= "Incluída mov. bancaria(receber) - Filial:"+xFilial("SE5")+", Data:"+DTOC(dDataCr)+", Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
				ERROTRB->ROTINA		:= "GTGEN014"				
				ERROTRB->TABELA		:="SE5"
				ERROTRB->ORDEM		:="1"
				ERROTRB->CHAVE		:="E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
				ERROTRB->TIPOLOG	:="I" //inclusão
			ERROTRB->(MsUnLock())
        EndIf       
    
    /* Falta desenvolver a transferência
    ElseIf cTipo == "3" //Transferencia
        aFINA100 := {    {"CBCOORIG"             ,"001"                            ,Nil},;
                            {"CAGENORIG"        ,"001"                            ,Nil},;
                            {"CCTAORIG"             ,"001"                            ,Nil},;
                            {"CNATURORI"         ,"001"                            ,Nil},;
                            {"CBCODEST"            ,"002"                            ,Nil},;
                            {"CAGENDEST"         ,"002"                            ,Nil},;
                            {"CCTADEST"         ,"002"                            ,Nil},;
                            {"CNATURDES"        ,"002"                            ,Nil},;
                            {"CTIPOTRAN"        ,"CH"                                ,Nil},;
                            {"CDOCTRAN"            ,"123456"                        ,Nil},;
                            {"NVALORTRAN"        ,2500                                ,Nil},;
                            {"CHIST100"            ,"TESTE TRF VIA EXECAUTO"    ,Nil},;
                            {"CBENEF100"        ,"TESTE TRF VIA EXECAUTO"    ,Nil} }
    
        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)
    
        If lMsErroAuto
			aAutoErro := GETAUTOGRLOG()
		    cErroCon:=XLOG(aAutoErro) 
		    
			 RecLock("ERROTRB",.T.)
				ERROTRB->LSTATUS	:= .F.
				ERROTRB->TIPO		:= "MOV. BANCARIA"
				ERROTRB->INFOTIT	:= ""
				ERROTRB->BANCO		:= cBanco
				ERROTRB->AGENCIA	:= cAgencia
				ERROTRB->CONTA		:= cConta
				ERROTRB->VALOR		:= nValor
				ERROTRB->ERRODESC	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
				ERROTRB->ERROCOMP	:= XLOGMEMO(aAutoErro)
				ERROTRB->ROTINA		:= "GTGEN014"				
				ERROTRB->TABELA		:="SE5"
				ERROTRB->ORDEM		:="1"
				ERROTRB->CHAVE		:="E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
				ERROTRB->TIPOLOG	:="I" //inclusão
			ERROTRB->(MsUnLock())

	        Return .F.
        Else
	   		RecLock("ERROTRB",.T.)
				ERROTRB->LSTATUS	:= .T.
				ERROTRB->TIPO		:= "MOV. BANCARIA"
				ERROTRB->INFOTIT	:= ""
				ERROTRB->BANCO		:= cBanco
				ERROTRB->AGENCIA	:= cAgencia
				ERROTRB->CONTA		:= cConta
				ERROTRB->VALOR		:= nValor
				ERROTRB->ERRODESC	:= "Incluída mov. bancaria(transferência)- Filial:"+xFilial("SE5")+", Data:"+DTOC(dDataBase)+", Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
				ERROTRB->ERROCOMP	:= "Incluída mov. bancaria(transferência)- Filial:"+xFilial("SE5")+", Data:"+DTOC(dDataBase)+", Banco:"+cBanco+", Agência: "+cAgencia+", Conta:"+cConta+", Valor:"+cvaltochar(nValor)
				ERROTRB->ROTINA		:= "GTGEN014"				
				ERROTRB->TABELA		:="SE5"
				ERROTRB->ORDEM		:="1"
				ERROTRB->CHAVE		:="E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
				ERROTRB->TIPOLOG	:="I" //inclusão
			ERROTRB->(MsUnLock())
        EndIf       
    */
    EndIf 
    
    //Voltando o pergunte, para o que era na opção mostra lançamentos contabeis
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("AFI100    02")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPreSel
		MsUnlock()
	endif
	//Voltando o contabiliza on-line
	if DbSeek("AFI100    04")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPreSel1
		MsUnlock()
	endif

RestArea(aArea)    
Return()


/*
Funcao      : OuWizard()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard de saída da tela de movimentações, para a execução da conciliação
Autor       : Matheus Massarotto
Data/Hora   : 14/06/2013
*/
*-------------------------------------*
Static Function OuWizard(oLayer,oBtn2,cArq,cConteudo,cCombo3,cCombo4,cBank,cAgency,cAccount)
*-------------------------------------*
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oOk 		:= LoadBitmap( GetResources(), "LBTIK" )
Local oWizard
Local oGet1
Local cGet1 := SPACE(TamSX3("A6_COD")[1])
Local oGet2
Local cGet2 := SPACE(TamSX3("A6_AGENCIA")[1])
Local oGet3
Local cGet3 := SPACE(TamSX3("A6_NUMCON")[1])

Local nPanel
Local aWiz := {{"","","","",""}}
Local oLbxWiz
Local lWiz := .F.

Local oTBar,oTBtnPar2,oTBtnPar3,oTBtnPar4,oTBtnPar5
Local lEntrou:=.F.


DEFINE WIZARD oWizard TITLE "Conciliação" HEADER "Processamento das baixas e movimentações bancarias" MESSAGE " ";		
TEXT "Atenção!!"+CRLF+CRLF+"No seguimento desta função os títulos relacionados anteriormente serão baixados."+CRLF+"As tarifas e rendimentos serão incluídos como movimento bancario!!" PANEL;
NEXT {|| .T.} FINISH {|| lWiz := .T.,.T.}

//--> PANEL 2
//Painel para a seleção do banco
/*
CREATE PANEL oWizard HEADER "Banco" MESSAGE "Selecione o banco para a baixa." PANEL;
BACK {|| .T.} NEXT {|| If(Empty(cGet1) .OR. Empty(cGet2) .OR. Empty(cGet3), (MsgStop("Informe os dados do banco para baixa!"), .F.), IIF(!ExistCpo("SA6",cGet1+cGet2+cGet3, 1),.F., .T. ))} FINISH {|| lWiz := .T.,.T.} EXEC {|| .T.}	

@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL

@ 21,20 SAY oSay1 VAR "Banco: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oGet1:= TGet():New(20,45,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oWizard:oMPanel[2],30,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')

	oTButton := TBtnBmp2():New( 36, 155, 25, 25, 'PESQUISA' , , , ,{|| F3SA6(@cGet1,@cGet2,@cGet3)}, oWizard:oMPanel[2], , , )
	
@ 41,20 SAY oSay2 VAR "Agência: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oGet2:= TGet():New(40,45,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oWizard:oMPanel[2],40,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')

@ 61,20 SAY oSay3 VAR "Conta: " SIZE 100,10 OF oWizard:oMPanel[2] PIXEL
oGet3:=TGet():New(60,45,{|u| if(PCount()>0,cGet3:=u,cGet3)}, oWizard:oMPanel[2],50,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet3')
*/

oWizard:oDlg:lEscClose := .F.

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. } 


If lWiz //Se tiver tudo OK

	//-->Tabela temporária para o resultado (Erros e Oks)
	aDadTemp	:= {}
	cMensErro	:= ""

	AADD(aDadTemp,{"LSTATUS"	,"L",1,0})
	AADD(aDadTemp,{"TIPO"		,"C",15,0})
	AADD(aDadTemp,{"INFOTIT"	,"C",TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+TamSX3("E1_TIPO")[1],0})
	AADD(aDadTemp,{"BANCO"		,"C",TamSX3("A6_COD")[1],0})
	AADD(aDadTemp,{"AGENCIA"	,"C",TamSX3("A6_AGENCIA")[1],0})
	AADD(aDadTemp,{"CONTA"		,"C",TamSX3("A6_NUMCON")[1],0})
	AADD(aDadTemp,{"VALOR"		,"N",14,2})
	AADD(aDadTemp,{"ERRODESC"	,"C",100,0})
	AADD(aDadTemp,{"ERROCOMP"	,"M",10,0})
	AADD(aDadTemp,{"ROTINA"		,"C",15,0})
	AADD(aDadTemp,{"TABELA"		,"C",3,0})
	AADD(aDadTemp,{"ORDEM"		,"C",1,0})
	AADD(aDadTemp,{"CHAVE"		,"C",50,0})	
	AADD(aDadTemp,{"TIPOLOG"	,"C",1,0})
		
	if select("ERROTRB")>0
		ERROTRB->(DbCloseArea())
	endif

	// Abertura da tabela
	cNome := CriaTrab(aDadTemp,.T.)
	dbUseArea(.T.,,cNome,"ERROTRB",.T.,.F.)

	cIndex	:=CriaTrab(Nil,.F.)
	cIndex2	:=CriaTrab(Nil,.F.)

	IndRegua("ERROTRB",cIndex,"LSTATUS",,,"Selecionando Registro...")  

	DbSelectArea("ERROTRB")
	DbSetIndex(cIndex+OrdBagExt())
	DbSetOrder(1)


	//Executa a rotina de processamento após a seleção dos dados no Wizard
	//**********>><<***********
	WaitResul(cBank,cAgency,cAccount,cCombo3,cCombo4) //DoBaixas(cGet1,cGet2,cGet3)
	//**********>><<***********
	
	//Chama a função para gravar o log na tabela Z59
	GravaLog(cArq,cConteudo)
	
	//<INICIO> -- Tratamento para eliminar as colunas de marcações e apresentar uma coluna única com os resultados    
    oColEsq:=oLayer:getColPanel('ESQ','BAIXO')
    oColDir:=oLayer:getColPanel('DIR','BAIXO')
    oColEsq:hide()
    oColDir:hide()
    
	oLinha:=oLayer:getLinePanel('BAIXO')

	oLayRes	:= FWLayer():new()
	oLayRes:init(oLinha,.F.,.T.)              

	oLayRes:addLine( 'BAIXO2', 100 , .F. ) 
	
	oLayRes:addCollumn('CENTRAL',100,.F.,'BAIXO2')
		
    oLayRes:addWindow('CENTRAL','WinResult','Resultados',100,.F.,.F.,{||  },'BAIXO2',{|| })
    
	oWinResul := oLayRes:getWinPanel('CENTRAL','WinResult','BAIXO2')

	//<FIM> -- Tratamento para eliminar as colunas de marcações e apresentar uma coluna única com os resultados    

	//Desabilito o botão de conciliação
    oBtn2:DIsable()

    //Chamo o browse para apresentação dos erros 
	Resultado(oWinResul)
	
EndIf


Return

/*
Funcao      : F3SA6()
Parametros  : 
Retorno     : 
Objetivos   : Função para buscar o banco e retornar o código, agencia e conta
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*---------------------------------------*
Static function F3SA6(cBank,cAgency,cAccount)
*---------------------------------------*
Local cRetorno
Local cRet	:= .F.

lRet:=CONPAD1(,,,"SA6",cRetorno,,.F. )

//Se clicou em ok
if lRet
	
	cBank:=SA6->A6_COD
	cAgency:=SA6->A6_AGENCIA
	cAccount:=SA6->A6_NUMCON

endif

Return

/*
Funcao      : DoBaixas()
Parametros  : 
Retorno     : 
Objetivos   : Realiza o processamento dos itens marcados, fazendo as baixas e incluões em movimentação bancária
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013	15:14
*/
*------------------------------------------------------*
Static function DoBaixas(cBanco,cAgencia,cConta,oMeter,oDlg3,cCombo3,cCombo4)
*------------------------------------------------------*
Local aRet	:= {}	

//Inicia a régua
oMeter:Set(0)

DbSelectArea("DADTRB")
DADTRB->(DbSetOrder(1))

Count to nRecCount

//de quanto em quanto a regua deve aumentar
nAumenta:= 100/(nRecCount/100)

DADTRB->(DbGotop())

While DADTRB->(!EOF())

oMeter:Set(nAumenta)

	if DADTRB->MARCA=="1" //Se do lado esquerdo estiver marcado para ser baixado

		DbSelectArea("DADTRB1")
		DADTRB1->(DbSetOrder(2))
		DADTRB1->(DbSeek(DADTRB->ID))

		While DADTRB1->(!EOF()) .AND. DADTRB1->ID2==DADTRB->ID
			if DADTRB1->MARCA=="1" .AND. DADTRB1->LSTATUS //se tiver marcado e for título
			  	if ALLTRIM(UPPER(DADTRB1->TIPO))=="RECEBER"
			  		//EXEC070(DADTRB1->PREFIXO,DADTRB1->TITULO,DADTRB1->PARCELA,DADTRB1->TIPOTIT,cBanco,cAgencia,cConta,DADTRB->DATAOP,val(DADTRB->VALOR),cCombo3,cCombo4,DADTRB1->IDBANCO)
				  	EXEC070(DADTRB1->PREFIXO,DADTRB1->TITULO,DADTRB1->PARCELA,DADTRB1->TIPOTIT,cBanco,cAgencia,cConta,DADTRB->DATAOP,DADTRB1->VALOR,cCombo3,cCombo4,DADTRB->IDBANCO)
			  	elseif ALLTRIM(UPPER(DADTRB1->TIPO))=="PAGAR"
			  		//EXEC080(DADTRB1->PREFIXO,DADTRB1->TITULO,DADTRB1->PARCELA,DADTRB1->TIPOTIT,cBanco,cAgencia,cConta,DADTRB->DATAOP,val(DADTRB->VALOR),cCombo3,cCombo4,DADTRB1->IDBANCO)
					EXEC080(DADTRB1->PREFIXO,DADTRB1->TITULO,DADTRB1->PARCELA,DADTRB1->TIPOTIT,cBanco,cAgencia,cConta,DADTRB->DATAOP,DADTRB1->VALOR,cCombo3,cCombo4,DADTRB->IDBANCO)
			  	endif

			  	//exit
			elseif DADTRB1->MARCA=="1" .AND. !DADTRB1->LSTATUS //se tiver marcado e for movimento bancário
				DbSelectArea("SE5")
				SE5->(DbgoTo(DADTRB1->R_E_C_N_O_))
				
				Concilia(DADTRB1->IDBANCO)
				
				//exit
			endif

			DADTRB1->(DbSkip())
		Enddo

    elseif DADTRB->MARCA=="3"  //Se estiver marcado para ser inserido como movimento bancário
    	aRet:=VerifTar(cBanco,DADTRB->MEMO)
    	
    	EXEC100(cBanco,cAgencia,cConta,DADTRB->DATAOP,val(DADTRB->VALOR),alltrim(aRet[3]),aRet[2],aRet[4],cCombo3,cCombo4,DADTRB->IDBANCO)	
        
	elseif DADTRB->MARCA=="5"  //Se estiver marcado para ser conciliado
	/*	
		DbSelectArea("DADTRB1")
		DADTRB1->(DbSetOrder(2))
		DADTRB1->(DbSeek(DADTRB->ID))

		While DADTRB1->(!EOF()) .AND. DADTRB1->ID2==DADTRB->ID
			if DADTRB1->MARCA=="1"
				DbSelectArea("SE5")
				SE5->(DbgoTo(DADTRB1->R_E_C_N_O_))
				
				Concilia()
				
				exit
			endif
			DADTRB1->(DbSkip())
		Enddo
    */
	endif
	
	DADTRB->(DbSkip())
Enddo

	oDlg3:end()

Return

/*
Funcao      : XLOG()  
Parametros  : aAutoErro
Retorno     : cRet
Objetivos   : Busca o erro gerado no msexecauto
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013
*/
*------------------------------*
Static Function XLOG(aAutoErro)
*------------------------------*
    LOCAL cRet := ""
    LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; "
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet

/*
Funcao      : XlogMEMO()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro para campo memo, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 25/06/2013 18:15
*/
*----------------------------------*
Static Function XLOGMEMO(aAutoErro)  
*----------------------------------*     
LOCAL cRet := ""
LOCAL nX := 1

FOR nX := 1 to Len(aAutoErro)
	cRet+=aAutoErro[nX]+CRLF
NEXT nX                        

RETURN cRet

/*
Funcao      : Resultado()
Parametros  : 
Retorno     : 
Objetivos   : Função para apresentar o resultado do processamento
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013	15:14
*/
*------------------------------------*
Static function Resultado(oWinResul)
*------------------------------------*
Local oBrowErro
// Define o Browse	
DEFINE FWBROWSE oBrowErro DATA TABLE ALIAS "ERROTRB" OF oWinResul			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowErro| /* Função que atualiza a regra*/ }  OF oBrowErro

	AADD(aDadTemp,{"TIPO"		,"C",10,0})
	AADD(aDadTemp,{"INFOTIT"	,"C",TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+TamSX3("E1_TIPO")[1],0})
	AADD(aDadTemp,{"BANCO"		,"C",TamSX3("A6_COD")[1],0})
	AADD(aDadTemp,{"AGENCIA"	,"C",TamSX3("A6_AGENCIA")[1],0})
	AADD(aDadTemp,{"CONTA"		,"C",TamSX3("A6_NUMCON")[1],0})
	AADD(aDadTemp,{"VALOR"		,"N",14,2})
	AADD(aDadTemp,{"ERRODESC"	,"C",100,0})
	AADD(aDadTemp,{"ERROCOMP"	,"M",10,0})

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || TIPO 		} TITLE "Tipo"   			DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 15 OF oBrowErro
ADD COLUMN oColumn DATA { || INFOTIT   	} TITLE "Informação título"	DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 14	OF oBrowErro
ADD COLUMN oColumn DATA { || BANCO    	} TITLE "Banco"				DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 3 	OF oBrowErro
ADD COLUMN oColumn DATA { || AGENCIA   	} TITLE "Agência"			DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 6 	OF oBrowErro
ADD COLUMN oColumn DATA { || CONTA   	} TITLE "Conta"				DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 10 OF oBrowErro
ADD COLUMN oColumn DATA { || VALOR   	} TITLE "Valor"				DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 16 OF oBrowErro
ADD COLUMN oColumn DATA { || ERRODESC  	} TITLE "Erro"				DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 50 OF oBrowErro
ADD COLUMN oColumn DATA { || ERROCOMP  	} TITLE "Erro completo"		DOUBLECLICK  {|| ExibMemo(ERROTRB->ERROCOMP) }	ALIGN 1 SIZE 10 OF oBrowErro

//Bara de botões do browse esquerdo
oTBar := TBar():New( oWinResul,45,32,.T.,,,,.F. )
oTBtnBmp1 := TBtnBmp() :NewBar('SVM',,,,'Legenda',{|| ErroLege()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Legenda"  


// Ativação do Browse	
ACTIVATE FWBROWSE oBrowErro

Return

/*
Funcao      : ExibMemo()
Parametros  : 
Retorno     : 
Objetivos   : Função para visualizar o campo memo do erro
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013	15:14
*/
*------------------------------*
Static function ExibMemo(cMemo)
*------------------------------*
Local oDlgErro,oTMultiget1
Local cTexto1	:= ""

	DEFINE DIALOG oDlgErro TITLE "Erro completo" FROM 180, 180 TO 550, 700 PIXEL

		cTexto1 := cMemo
		//Crio o objeto tipo memo para visualização da msg
		oTMultiget1 := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) }, oDlgErro, 960, 102, , , , , , .T.,,,,,.T.,,,,.F.,.T.)
	  
		 oTMultiget1:Align:= CONTROL_ALIGN_ALLCLIENT
		
	ACTIVATE DIALOG oDlgErro CENTERED

return


/*
Funcao      : WaitAxVi()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	15:14
*/
*-------------------------------------------------*
Static Function WaitResul(cBank,cAgency,cAccount,cCombo3,cCombo4)
*-------------------------------------------------*
Local oDlg3
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg3 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg3,70,34,,.T.,,,,,,,,,)
	    
	  ACTIVATE DIALOG oDlg3 CENTERED ON INIT(lRet:=DoBaixas(cBank,cAgency,cAccount,oMeter,oDlg3,cCombo3,cCombo4))
	  
	//*************************************

Return(lRet)

/*
Funcao      : GravaLog()
Parametros  : 
Retorno     : 
Objetivos   : Grava o log na tabela Z59
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013	15:14
*/
*------------------------------------------*
Static function GravaLog(cNomeArq,cConteudo)
*------------------------------------------*
Local oLog
Local cNomeArq	:= SUBSTR(cNomeArq,RAT("\",cNomeArq)+1,len(cNomeArq))
Local aArray	:= {}
Local cErroLog	:= ""
Local cRotina	:= ""

DbSelectArea("ERROTRB")
ERROTRB->(DbSetOrder(1))
ERROTRB->(DbGoTop())

While ERROTRB->(!EOF())

    if ERROTRB->LSTATUS
    	cErroLog+= ERROTRB->ERROCOMP+CRLF
    	AADD(aArray,{ERROTRB->TABELA,val(ERROTRB->ORDEM),ERROTRB->CHAVE,ERROTRB->TIPOLOG})
    	cRotina:=ERROTRB->ROTINA
    	//nome do arquivo, conteudo, nome da rotina, conteúdo do log, array{tabela,ordem,chave,tipo[I-inclusão,A-alteração,e-Exclusão]}
    	//oLog:=GtIntLog():New(cNomeArq,cConteudo,ERROTRB->ROTINA,ERROTRB->ERROCOMP,{{ERROTRB->TABELA,ERROTRB->ORDEM,ERROTRB->CHAVE,ERROTRB->TIPOLOG}})
    endif
    
	ERROTRB->(DbSkip())
Enddo

if !empty(aArray)
	oLog:=GtIntLog():New(cNomeArq,cConteudo,cRotina,cErroLog,aArray)
endif

Return



*---------------------------------*
Static function Concilia(cIdBanco)
*---------------------------------*
Local nReconc:= 1
Local nRecAtu:= 0

	RecLock("SE5",.F.)
		SE5->E5_RECONC := "x"
		SE5->E5_P_IDOFX:= cIdBanco
	MSUnlock()
	
	nRecAtu:=SE5->(RECNO())
	
	//<CHEQUE> Verifico se tem cheque para ser conciliado
	cQry:=" SELECT R_E_C_N_O_ FROM "+RETSQLNAME("SE5")
   	cQry+=" WHERE D_E_L_E_T_='' AND E5_BANCO='"+SE5->E5_BANCO+"' AND E5_AGENCIA='"+SE5->E5_AGENCIA+"' AND E5_CONTA='"+SE5->E5_CONTA+"' AND E5_NUMCHEQ='"+SE5->E5_NUMCHEQ+"' AND E5_TIPODOC='CH' AND E5_RECONC=''"

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

	Count to nRecCount  	
  	    
  	    if nRecCount>0
  	    
  	    QRYTEMP->(DbGoTop())
    		
    		While QRYTEMP->(!EOF())// .AND. SE5->E5_BANCO== .AND. SE5->E5_AGENCIA== .AND. SE5->E5_CONTA== .AND. SE5->E5_NUMCHEQ== .AND. 
				SE5->(DbGoto(QRYTEMP->R_E_C_N_O_))
					RecLock("SE5",.F.)
						SE5->E5_RECONC := "x"
						SE5->E5_P_IDOFX:= cIdBanco
					MSUnlock()    		
    			QRYTEMP->(DbSkip())
    		Enddo
    		
    	endif
	//<CHEQUE> Verifico se tem cheque para ser conciliado
	
	SE5->(DbGoTo(nRecAtu))
		
	//Atualiza apenas o saldo reconciliado
	If nReconc == 2	//Desconciliou
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,IIF(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)			
	Endif
	If nReconc == 1	//Conciliou
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,IIF(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)			
	Endif
	
	//Preenchendo a tabela de logs
	RecLock("ERROTRB",.T.)
		ERROTRB->LSTATUS	:= .T.
		ERROTRB->TIPO		:= "MOV.BANCARIO"
		ERROTRB->INFOTIT	:= xFilial("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO
		ERROTRB->BANCO		:= SE5->E5_BANCO
		ERROTRB->AGENCIA	:= SE5->E5_AGENCIA
		ERROTRB->CONTA		:= SE5->E5_CONTA
		ERROTRB->VALOR		:= SE5->E5_VALOR
		ERROTRB->ERRODESC	:= "Concíliado título: "+xFilial("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+" - Banco:"+alltrim(SE5->E5_BANCO)+", Agência: "+alltrim(SE5->E5_AGENCIA)+", Conta:"+alltrim(SE5->E5_CONTA)+", Valor:"+cvaltochar(SE5->E5_VALOR)
		ERROTRB->ERROCOMP	:= "Concíliado título: "+xFilial("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+" - Banco:"+alltrim(SE5->E5_BANCO)+", Agência: "+alltrim(SE5->E5_AGENCIA)+", Conta:"+alltrim(SE5->E5_CONTA)+", Valor:"+cvaltochar(SE5->E5_VALOR)
		ERROTRB->ROTINA		:= "GTGEN014"
		ERROTRB->TABELA		:="SE5"
		ERROTRB->ORDEM		:="7"
		ERROTRB->CHAVE		:="E5_FILIAL+E5_PREFIXO+E5_NUM+E5_PARCELA+E5_TIPO"
		ERROTRB->TIPOLOG	:="A" //alteração
	ERROTRB->(MsUnLock())

Return


/*
Funcao      : IncMovB()
Parametros  : 
Retorno     : 
Objetivos   : Função para incluir um título do lado direito do browse(Títulos do sistema)
Autor       : Matheus Massarotto
Data/Hora   : 24/06/2013	15:14
*/
*-------------------------*
Static Function IncMovB()
*-------------------------*
Local cRetorno
Local lRet	:= .F.
Local cTab	:= ""

if UPPER(alltrim(DADTRB->TIPO))=="CREDIT"
	cTab:= "SE5R14"
elseif UPPER(alltrim(DADTRB->TIPO))=="DEBIT"
	cTab:= "SE5P14"
endif

lRet:=CONPAD1(,,,cTab,cRetorno,,.F.  )

//Se clicou em ok
if lRet
	//Validação sobre já existir um título do lado direito
	if DADTRB->MARCA $ "3/4"
		MsgInfo("Não é possível incluir, pois o relacionamento se trata de uma tarifa/rendimento","Informativo!")
		return()
	elseif DADTRB->MARCA $ "5" 
		MsgInfo("Não é possível incluir, pois o relacionamento já está conciliado","Informativo!")
		return()
	endif

    //Informativo sobre valor
	if val(DADTRB->VALOR)<>SE5->E5_VALOR
		if !MsgYesNo("Deseja mesmo incluir um título com valor diferente do relacionado?","Atenção!")
		    return()
		endif
	endif	
	

	//Se for contas a receber
	if UPPER(alltrim(DADTRB->TIPO)) == "CREDIT"
	    
	    //Grava tabela do lado direito
	    Reclock("DADTRB1",.T.)

			DADTRB1->MARCA		:= "1"
			DADTRB1->TABELA		:= "SE5"
			DADTRB1->TIPO		:= "MOV.BANCARIO"
			DADTRB1->PREFIXO	:= SE5->E5_PREFIXO
			DADTRB1->TITULO		:= SE5->E5_NUMERO
			DADTRB1->PARCELA	:= SE5->E5_PARCELA
			DADTRB1->TIPOTIT	:= SE5->E5_TIPO
			DADTRB1->VALOR		:= SE5->E5_VALOR
			DADTRB1->CLIFOR		:= POSICIONE("SA1",1,xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA,"A1_NOME")
			DADTRB1->R_E_C_N_O_	:= SE5->(RECNO())
			DADTRB1->ID2		:= DADTRB->ID
			DADTRB1->LSTATUS	:= .T.
			DADTRB1->IDBANCO	:= DADTRB->IDBANCO

		DADTRB1->(MsUnlock())

		//Atualiza marcador do lado esquerdo
		Reclock("DADTRB",.F.)
			DADTRB->MARCA		:= "1"
		DADTRB1->(MsUnlock())

	elseif UPPER(alltrim(DADTRB->TIPO)) == "DEBIT"
	    
	    //Grava tabela do lado direito
	    Reclock("DADTRB1",.T.)
	
			DADTRB1->MARCA		:= "1"	    							    
			DADTRB1->TABELA		:= "SE5"
			DADTRB1->TIPO		:= "MOV.BANCARIO"
			DADTRB1->PREFIXO	:= SE5->E5_PREFIXO
			DADTRB1->TITULO		:= SE5->E5_NUMERO
			DADTRB1->PARCELA	:= SE5->E5_PARCELA
			DADTRB1->TIPOTIT	:= SE5->E5_TIPO
			DADTRB1->VALOR		:= SE5->E5_VALOR
			DADTRB1->CLIFOR		:= POSICIONE("SA2",1,xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,"A2_NOME") //SE5->E5_NOMFOR
			DADTRB1->R_E_C_N_O_	:= SE5->(RECNO())
			DADTRB1->ID2		:= DADTRB->ID
			DADTRB1->LSTATUS	:= .T.
			DADTRB1->IDBANCO	:= DADTRB->IDBANCO
		
		DADTRB1->(MsUnlock())
		
		//Atualiza marcador do lado esquerdo
		Reclock("DADTRB",.F.)
			DADTRB->MARCA		:= "1"
		DADTRB1->(MsUnlock())	

	endif
	
endif

Return

*------------------------*
Static Function ValidDir()
*------------------------*
Local aArea		:= GetArea()
Local nValorEsq	:= val(DADTRB->VALOR)
Local nSumValDir:= 0
Local lRet		:= .T.

if DADTRB->MARCA=="1"

	DbSelectArea("DADTRB1")
	DADTRB1->(DbSetOrder(2))
	DADTRB1->(DbSeek(DADTRB->ID))

	While DADTRB1->(!EOF()) .AND. DADTRB1->ID2==DADTRB->ID
        	
       	if DADTRB1->MARCA=="1"
       		nSumValDir+=DADTRB1->VALOR
       	endif

       	DADTRB1->(DbSkip())
	Enddo

	if nValorEsq<>nSumValDir
		MsgInfo("A valor total do(s) título(s) selecionado(s) no sistema, deve ser igual ao do arquivo.","Atenção!")
		lRet:=.F.
	endif

endif

RestArea(aArea)
Return(lRet)


//Função para trazer todos títulos do sistema e selecionar o desejado, ou os desejados
*---------------------------------------------------------------*
Static function BuscaTit(oBrowseD,oBrowseE,cGetD7,cGetD6,cGetD8)
*---------------------------------------------------------------*
Local oDlgTit,oGetDadTit
Local aHeadtit	:= {}
Local aAcoltit	:= {}
Local nUseTit	:= 0

Local aAlterTit	:={}

Local bOk     := {|| lRet:= .T.,oDlgTit:End()}
Local bCancel := {|| oDlgTit:End()}

Local oLayer 	:= FWLayer():new()
Local oScrBx


Local aItems	:= {"Títulos","Mov.Bancario"}

Local lSoConc	:= GETNEWPAR( "MV_P_OFXB" , .F. )                 

Private aButtons	:= {}
Private oBrowse

if DADTRB->MARCA=="5" //Se for cadeado, n  busca título
	MsgInfo("O lançamento já está conciliado.","Atenção!")
	Return
endif

//-->Tabela temporária
aDadTemp	:= {}

AADD(aDadTemp,{"MARCA"		,"C",1,0})
AADD(aDadTemp,{"LSTATUS"	,"L",1,0})
AADD(aDadTemp,{"TABELA"		,"C",3,0})
AADD(aDadTemp,{"DDATA"		,"D",8,0})
AADD(aDadTemp,{"TIPO"		,"C",15,0})
AADD(aDadTemp,{"PREFIXO"	,"C",TamSX3("E1_PREFIXO")[1],0})
AADD(aDadTemp,{"TITULO"		,"C",TamSX3("E1_NUM")[1]	,0})
AADD(aDadTemp,{"PARCELA"	,"C",TamSX3("E1_PARCELA")[1],0})
AADD(aDadTemp,{"TIPOTIT"	,"C",TamSX3("E1_TIPO")[1]	,0})
AADD(aDadTemp,{"VALOR"		,"N",14,2})
AADD(aDadTemp,{"CLIFOR"		,"C",50,0})
AADD(aDadTemp,{"R_E_C_N_O_"	,"N",6,0})
AADD(aDadTemp,{"IDBANCO"	,"C",20,0})
AADD(aDadTemp,{"ID2"		,"C",10,0})
	
		    
if select("DADTIT")>0
	DADTIT->(DbCloseArea())
endif

//Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTIT",.T.,.F.)

//cIndex	:=CriaTrab(Nil,.F.)
cIndex2	:=CriaTrab(Nil,.F.)
cIndex3	:=CriaTrab(Nil,.F.)

//IndRegua("DADTIT",cIndex,"ID2",,,"Selecionando Registro...")  
IndRegua("DADTIT",cIndex2,"PREFIXO+TITULO",,,"Selecionando Registro...")
IndRegua("DADTIT",cIndex3,"DDATA",,,"Selecionando Registro...")
//Indice decrescente
Index On Descend(DDATA) To &(cNome)

DbSelectArea("DADTIT")
DbSetIndex(cIndex2+OrdBagExt())
DbSetOrder(1)
                      

								                                           //retira o botão X
		DEFINE DIALOG oDlgTit TITLE "Títulos - sistema" FROM 137,285 TO 594,1166 PIXEL//STYLE DS_MODALFRAME FROM 137,285 TO 544,1066 PIXEL

			oLayer:init(oDlgTit,.F.,.T.)              

			oLayer:addLine( 'CIMA', 20 , .F. )
			oLayer:addLine( 'BAIXO', 80 , .F. )
            
			oLayer:addCollumn('CC',100,.F.,'CIMA')
			oLayer:addCollumn('CB',100,.F.,'BAIXO')

            oLayer:addWindow('CC','WinC','',100,.F.,.F.,{||},'CIMA',{||})
	        oLayer:addWindow('CB','WinB','Títulos sistema',100,.F.,.F.,{||},'BAIXO',{|| })
            
            oScrCi := oLayer:getWinPanel('CC','WinC','CIMA')
			oScrBx := oLayer:getWinPanel('CB','WinB','BAIXO')
            
            if lSoConc
				cCombo:= aItems[1]
			else
				cCombo:= aItems[2]
			endif
			
			oCombo:= tComboBox():New(05,05,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,100,20,oScrCi,,{||Filtra(cCombo),oBrowse:Refresh(.T.)},,,,.T.,,,,,,,,,'cCombo')

			if !lSoConc
	            oCombo:Disable()
			endif

			@ 05,130 SAY "Valor arquivo: " SIZE 100,10 OF oScrCi PIXEL
			cGetD_Arq:= val(DADTRB->VALOR)
			@ 05,165 SAY cGetD_Arq Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScrCi PIXEL

			@ 05,250 SAY "Valor título(s) selecionado(s): " SIZE 100,10 OF oScrCi PIXEL
			cGetD_Sis:= 0
			@ 05,325 SAY cGetD_Sis Picture PesqPict("SE5","E5_VALOR",19) SIZE 100,10 OF oScrCi PIXEL

			CarregaTit()
			
			//Chamo uma vez para realizar o filtro na temporária
			Filtra(cCombo)
			
			BrowDir2(oScrBx,@oBrowse,@cGetD_Sis,oDlgTit,cGetD_Arq,oBrowseD,oBrowseE,@cGetD7,@cGetD6,@cGetD8)

		ACTIVATE DIALOG oDlgTit CENTERED

Return()

*------------------------------------*
Static function CarregaTit(cPgRecMov)
*------------------------------------*
            if UPPER(ALLTRIM(DADTRB->TIPO))=="CREDIT"
				cQry:=" SELECT 'SE1' AS 'TABELA','RECEBER' AS 'TIPO',E1_EMISSAO AS 'DDATA',E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO',E1_PARCELA AS 'PARCELA',E1_TIPO AS 'TIPOTIT',E1_VALOR AS 'VALOR',E1_NOMCLI AS 'NOME',R_E_C_N_O_,E1_P_IDOFX AS 'IDBANCO' FROM "+RETSQLNAME("SE1")
				cQry+=" WHERE D_E_L_E_T_='' AND E1_SALDO>0 AND E1_SALDO<="+alltrim(DADTRB->VALOR)
				cQry+=" AND E1_FILIAL = '"+xFilial("SE1")+"'"
	            
	            cQry+=" UNION ALL"
	            
				cQry+=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',R_E_C_N_O_,E5_P_IDOFX AS 'IDBANCO'  FROM "+RETSQLNAME("SE5")
				cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC=''"
	            cQry+=" AND E5_SITUACA<>'C' AND E5_NUMERO<>''
	            cQry+=" AND E5_FILIAL = '"+xFilial("SE5")+"'"
	            cQry+=" AND E5_RECPAG='R'
	            cQry+=" AND E5_VALOR<="+alltrim(DADTRB->VALOR)
	            
            elseif UPPER(ALLTRIM(DADTRB->TIPO))=="DEBIT"
				
				cQry:=" SELECT 'SE2' AS 'TABELA','PAGAR' AS 'TIPO',E2_EMISSAO AS 'DDATA',E2_PREFIXO AS 'PREFIXO',E2_NUM AS 'TITULO',E2_PARCELA AS 'PARCELA',E2_TIPO AS 'TIPOTIT',E2_VALOR AS 'VALOR',E2_NOMFOR AS 'NOME',R_E_C_N_O_,E2_P_IDOFX AS 'IDBANCO'  FROM "+RETSQLNAME("SE2")
				cQry+=" WHERE D_E_L_E_T_='' AND E2_SALDO>0 AND E2_SALDO<="+alltrim(DADTRB->VALOR)
				cQry+=" AND E2_FILIAL = '"+xFilial("SE2")+"'"
	            
	            cQry+=" UNION ALL"
	            
				cQry+=" SELECT 'SE5' AS 'TABELA','MOV.BANCARIO' AS 'TIPO',E5_DATA AS 'DDATA',E5_PREFIXO AS 'PREFIXO',E5_NUMERO AS 'TITULO',E5_PARCELA AS 'PARCELA',E5_TIPO AS 'TIPOTIT',E5_VALOR AS 'VALOR',E5_BENEF AS 'NOME',R_E_C_N_O_,E5_P_IDOFX AS 'IDBANCO'  FROM "+RETSQLNAME("SE5")
				cQry+=" WHERE D_E_L_E_T_='' AND E5_RECONC=''"
	            cQry+=" AND E5_SITUACA<>'C' AND E5_NUMERO<>''
	            cQry+=" AND E5_FILIAL = '"+xFilial("SE5")+"'"
	            cQry+=" AND E5_RECPAG='P'"
	            cQry+=" AND E5_VALOR<="+alltrim(DADTRB->VALOR)
	            	            
            endif 
            
            //Tratamento para contas a receber e a pagar em aberto
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif

			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

			Count to nRecCount
            
			nCont:=0

	  	    if nRecCount>0

	 			QRYTEMP->(DbGotop())
				
							
				While QRYTEMP->(!EOF())
				     	    
		            nCont++
				    Reclock("DADTIT",.T.)

						DADTIT->MARCA		:= "2"	    							    
						DADTIT->LSTATUS		:= IIF(ALLTRIM(QRYTEMP->TABELA)=="SE5",.F.,.T.)
						DADTIT->TABELA		:= QRYTEMP->TABELA
						DADTIT->DDATA		:= STOD(QRYTEMP->DDATA)
						DADTIT->TIPO		:= QRYTEMP->TIPO
						DADTIT->PREFIXO		:= QRYTEMP->PREFIXO
						DADTIT->TITULO		:= QRYTEMP->TITULO
						DADTIT->PARCELA		:= QRYTEMP->PARCELA
						DADTIT->TIPOTIT		:= QRYTEMP->TIPOTIT
						DADTIT->VALOR		:= QRYTEMP->VALOR
						DADTIT->CLIFOR		:= QRYTEMP->NOME
						DADTIT->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
						DADTIT->IDBANCO		:= QRYTEMP->IDBANCO

					DADTIT->(MsUnlock())
					QRYTEMP->(DbSkip())
				Enddo
								
			endif
Return


/*
Funcao      : ()
Parametros  : oMeter,oDlg1,oBrowse,oScr3,cGet1,cGet2,cCombo,aAllGroup,aAllTab,oTButton2
Retorno     : 
Objetivos   : Função para processar os dados
Autor       : Matheus Massarotto
Data/Hora   : 21/05/2013	11:10
*/

*-------------------------------------------------------------------*
Static function BrowDir2(oScrBx,oBrowse,cGetD_Sis,oDlgTit,cGetD_Arq,oBrowseD,oBrowseE,cGetD7,cGetD6,cGetD8)
*-------------------------------------------------------------------*
Local oTBtnBmp1,oTBtnBmp2,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTIT" OF oScrBx

//Adiciona coluna para marcar e desmarcar                                                                                                                                                                                        //oBrowse:Refresh(.T.) posiciona no inicio após o refresh
ADD MARKCOLUMN oColumn DATA { || If(MARCA=="1"/* Função com a regra*/,'LBOK',IIF(MARCA=="2",'LBNO',)) } DOUBLECLICK { |oBrowse| MarcBro(@cGetD_Sis) /* Função que atualiza a regra*/ }  OF oBrowse		

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || DDATA 		} TITLE "Data"  			DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE 10 OF oBrowse 
ADD COLUMN oColumn DATA { || TIPO 		} TITLE "Tipo"  			DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE 10 OF oBrowse 
ADD COLUMN oColumn DATA { || PREFIXO 	} TITLE "Prefixo"  			DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE  3 OF oBrowse 
ADD COLUMN oColumn DATA { || TITULO 	} TITLE "Titulo"   			DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE  6 OF oBrowse 
ADD COLUMN oColumn DATA { || TIPOTIT 	} TITLE "Tipo título"		DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE  3 OF oBrowse 
ADD COLUMN oColumn DATA { || VALOR	 	} TITLE "Valor"   			DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE 20 OF oBrowse		
ADD COLUMN oColumn DATA { || CLIFOR		} TITLE "Cli/Forn" 			DOUBLECLICK  {|| WaitAxVi(DADTIT->TABELA,DADTIT->R_E_C_N_O_,DADTIT->TIPO) }  SIZE 50 OF oBrowse 

//Bara de botões do browse direito
oTBar := TBar():New( oScrBx,25,32,.T.,"BOTTOM",,,.F. )

//oTBar:SetButtonAlign( CONTROL_ALIGN_RIGHT )

oTBtnBmp1 := TBtnBmp() :NewBar('OK',,,,'Ok',{|| IIF(GravBDir(cGetD_Arq,cGetD_Sis,oBrowseE,oBrowseD,@cGetD7,@cGetD6,@cGetD8),oDlgTit:End(),) },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Ok"

oTBtnBmp2 := TBtnBmp() :NewBar('FINAL',,,,'Sair',{|| oDlgTit:End() },.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp2:cTooltip:="Sair"

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

Return(.T.)

//Função para marcação dos itens 
*--------------------------------*
Static function MarcBro(cGetD_Sis)
*--------------------------------*
Local cRec	:= DADTIT->(RECNO())

DADTIT->(DbGoTo(cRec))

	RecLock("DADTIT",.F.)
		DADTIT->MARCA:=IIF(DADTIT->MARCA=="1","2","1") 
	DADTIT->(MsUnlock())

	if DADTIT->MARCA=="1"
		cGetD_Sis+=DADTIT->VALOR
	elseif DADTIT->MARCA=="2"
		cGetD_Sis-=DADTIT->VALOR
	endif

Return

//Filtra o temporário
*----------------------------*
Static function Filtra(cTipo)
*----------------------------*    
	if cTipo == "Títulos"
		bCondicao := {|| DADTIT->TABELA $ 'SE1/SE2'}
		cCondicao := "DADTIT->TABELA $ 'SE1/SE2'"
	elseif cTipo == "Mov.Bancario"
			bCondicao := {|| DADTIT->TABELA $ 'SE5'}
		cCondicao := "DADTIT->TABELA $ 'SE5'"
	endif
	
	DbSelectArea("DADTIT")

	DbSetFilter(bCondicao,cCondicao)
    
	DADTIT->(DbGoTop())
	
Return

*-----------------------------------------------------------------------------------*
Static Function GravBDir(cGetD_Arq,cGetD_Sis,oBrowseE,oBrowseD,cGetD7,cGetD6,cGetD8)
*-----------------------------------------------------------------------------------*
Local lRet	:= .T.

if cGetD_Arq<>cGetD_Sis
	Alert("O valor do arquivo deve ser o mesmo no sistema!","Atenção")
	lRet:=.F.
else
    
	//<Detelando os registros existentes do lado direito
	DbSelectArea("DADTRB1")
	DADTRB1->(DbSetOrder(2))
	DADTRB1->(DbSeek(DADTRB->ID))
	
	While DADTRB1->(!EOF()) .AND. DADTRB1->ID2==DADTRB->ID
		RecLock("DADTRB1",.F.)
			DADTRB1->(DbDelete())
		DADTRB1->(MsUnlock())
		
		DADTRB1->(DbSkip())
	Enddo
	//<Fim da deleção

	DbSelectArea("DADTIT")
	DbSetORder(1)
	DADTIT->(DbGoTop())
	While DADTIT->(!EOF())
	    if DADTIT->MARCA=="1"
            
			RecLock("DADTRB1",.T.)
				DADTRB1->MARCA		:= "1"
				DADTRB1->TABELA		:= DADTIT->TABELA
				DADTRB1->DDATA		:= DADTIT->DDATA
				DADTRB1->TIPO		:= DADTIT->TIPO
				DADTRB1->PREFIXO	:= DADTIT->PREFIXO
				DADTRB1->TITULO		:= DADTIT->TITULO
				DADTRB1->PARCELA	:= DADTIT->PARCELA
				DADTRB1->TIPOTIT	:= DADTIT->TIPOTIT
				DADTRB1->VALOR		:= DADTIT->VALOR
				DADTRB1->CLIFOR		:= DADTIT->CLIFOR
				DADTRB1->R_E_C_N_O_	:= DADTIT->R_E_C_N_O_
				DADTRB1->ID2		:= DADTRB->ID
				DADTRB1->LSTATUS	:= DADTIT->LSTATUS            
				DADTRB1->IDBANCO	:= DADTIT->IDBANCO
			MsUnlock()        
	        
	
			//Se tiver marcado do lado direito, já marco do lado esquerdo
			if DADTRB1->MARCA=="1"	
				if DADTRB1->LSTATUS
					RecLock("DADTRB",.F.)	
						DADTRB->MARCA:="1"
					DADTRB->(MsUnlock())
	
	   				if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
						SE1->(DbGoto(DADTRB1->R_E_C_N_O_))
	
						//Valor liquido a ser baixado
						cGetD6+= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
						cGetD8+= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
				    else
						SE2->(DbGoto(DADTRB1->R_E_C_N_O_))
	
						//Valor liquido a ser baixado
						cGetD6-= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
						cGetD8-= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)
				    endif
	
				else
					if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
						cGetD7+=ROUND(DADTRB1->VALOR,2)
					else
						cGetD7-=ROUND(DADTRB1->VALOR,2)
					endif
	
					RecLock("DADTRB",.F.)	
						DADTRB->MARCA:="1"
					DADTRB->(MsUnlock())
				endif
		    else
	
				//Se for movimento bancário
				if !DADTRB1->LSTATUS
					if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
						cGetD7-=ROUND(DADTRB1->VALOR,2)
					else
						cGetD7+=ROUND(DADTRB1->VALOR,2)
					endif
				else //Se não for movimento bancário
					if alltrim(UPPER(DADTRB->TIPO))=="CREDIT"
						SE1->(DbGoto(DADTRB1->R_E_C_N_O_))
	
						//Valor liquido a ser baixado
						cGetD6-= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
						cGetD8-= ROUND(SE1->E1_VALOR-SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA),2)
				    else
						SE2->(DbGoto(DADTRB1->R_E_C_N_O_))
	
						//Valor liquido a ser baixado
						cGetD6+= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)			    
						cGetD8+= ROUND(SE2->E2_VALOR-SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA),2)			    
				    endif			
				endif
	
				RecLock("DADTRB",.F.)	
					DADTRB->MARCA:="2"
				DADTRB->(MsUnlock())    
		    endif
	
	    endif

		DADTIT->(DbSkip())
	Enddo
	
endif

Return(lRet)