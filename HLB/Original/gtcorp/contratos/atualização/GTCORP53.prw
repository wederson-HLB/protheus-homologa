#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP53
Parametros  : Nil
Retorno     : Nil
Objetivos   : Fonte para GT aprovar ou recusar as propostas, Z79 e Z78
Autor       : Matheus Massarotto
Data/Hora   : 04/12/2012    14:29
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*-----------------------*
User Function GTCORP53()
*-----------------------*
Local cString	:="Z79"
Local cIdUser	:= __cUserID // Id do usuário logado
Local cCodVend 	:= ""

Local lFilter 	:= .T.

Private aRotina:={}


if !TCCANOPEN("Z79"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z79")
	Return()
endif
if !TCCANOPEN("Z78"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z78")
	Return()
endif
if !TCCANOPEN("Z70"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z70")
	Return()
endif
if !TCCANOPEN("Z69"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z69")
	Return()
endif
if !TCCANOPEN("Z66"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z66")
	Return()
endif
if !TCCANOPEN("Z65"+cEmpAnt+"0")
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z65")
	Return()
endif
  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP52("Z79",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Recusar"			, 'U_GTCORP52("Z79",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Aprovar"			, 'U_GTCORP52("Z79",RECNO(),4)' 	, 0 , 4} ) 
AADD( aRotina, { "Legenda"			, 'U_LEGZ79GT' 						, 0 , 5 } )

Private aCores:={}

//aCores := { {"Z79_STATUS == '3'"						, "PMSINFO"	},;	// Pendente Aprovação GT
//			{"Z79_STATUS == '4' .OR. Z79_STATUS == 'A'" , "BMPDEL"	},;	// Recusado GT
//			{"Z79_STATUS == '5'"						, "PEDIDO" 	}}  // Aprovado GT

aCores := { {"Z79_STATUS == '3'"						, "UPDWARNING"	},;	// Pendente Aprovação GT
			{"Z79_STATUS == '4' .OR. Z79_STATUS == 'A'" , "NOCHECKED"	},;	// Recusado GT
			{"Z79_STATUS == '5'"						, "CHECKED" 	}}  // Aprovado GT

/*
DbSelectArea("SA3")
DbSetOrder(7) // Código usuário
if DbSeek(xFilial("SA3")+cUserLog)
	cCodVend:=SA3->A3_COD
endif

bCondicao := {|| Z79->Z79_APROVA = cCodVend .AND. Z79->Z79_STATUS $ '3/4/5/A'  }
cCondicao := "Z79->Z79_APROVA = '"+cCodVend+"' .AND. Z79->Z79_STATUS $ '3/4/5/A'"
DbSelectArea("Z79")
DbSetFilter(bCondicao,cCondicao)
*/

//Verifica se o usuário pode ver todas as propostas
DbSelectArea("Z66")
Z66->(DbSetOrder(1))
if Z66->(DbSeek(xFilial("Z66")+cIdUser))
	if Z66->Z66_LADMIN
		lFilter:=.F.
	else
		if Z66->Z66_LAPROV
       	    if Z66->Z66_LVISP
				lFilter:=.F.
			else
				cFiltro:="Z79->Z79_APROVA = '"+cIdUser+"' .AND. Z79->Z79_STATUS $ '3/4/5/A'"
			endif
		else
			Alert("Você não tem perfil de aprovador!"+CRLF+"Solicite ao seu superior ou administrador que cadastre sua alçada do controle de propostas!")
			Return
		endif
	    
    endif
else
	Alert("Você não tem permissão para operar esta rotina!"+CRLF+"Solicite ao seu superior ou administrador que cadastre sua alçada do controle de propostas!")
	Return
endif    

//Definição de filtro                                                       -
If lFilter

	bCondicao := {|| &cFiltro}
	cCondicao := cFiltro
	DbSelectArea(cString)

	DbSetFilter(bCondicao,cCondicao)
Else
	DbSelectArea(cString)
Endif


DbSetOrder(1)
MBrowse( 6,1,22,75,cString,,,,,,aCores)
 
Return

/*
Funcao      : GTCORP52()  
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z79 e Z78 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP52(xParam1,xParam2,xParam3) 
*----------------------------------------------*
Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= {}
Local aAlterEnch	:= {}
Local aCpoEnCob		:= {}
Local aAltCobEn		:= {}
Local nOpc    		:= nOpc2:= xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {012,002,161,620}//{012,002,161,422}
Local nModelo		:= 3     	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3 		  	:= .F.		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria 		:= .T.		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.		// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela 		:= "" 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .F.		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty		:= .F.		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
                                                                                                                                             
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       := {}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter     	:= {""}
Local nSuperior    	:= 165 //165       	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 002 //002       	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 253 //253       	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 620 //422       	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc1        	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= "+Z78_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysFalse"   	// Funcao executada para validar a exclusao de uma linha do aCols                   

Local aObjects      := {}
Local aObjects2		:= {}
Local aObjects2		:= {}
Local aPosObj       := {}
Local aPosObj2		:= {}
Local aObjects3		:= {}
Local aSize         := {}        

Local nUsado:=0

Local cCadastro:="Cadastro de Proposta"

Local cAno:="" //Ano que se deseja alterar

// Variáveis utilizadas na seleção de categorias
Local oChkQual,lQual,oQual,cVarQ
Local oQual1,cVarQ1
// Carrega bitmaps
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")

// Objeto no qual a MsNewGetDados sera criada                                      
Private aHeader     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols       := {}               // Array a ser tratado internamente na MsNewGetDados como aCols

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
// Privates das NewGetDados
Private oGetDados

Private aTELA[0][0] // Variáveis que serão atualizadas pela Enchoice()
Private aGETS[0] // e utilizadas pela função OBRIGATORIO()

Private aColsAux:={}  
Private nPosSta	:=0
Private aButtons:={}

Private oGroup
Private cTexto:="0"
Private oTexto,oSlider,oMemo
Private cMemo := space(200)

Private aItensZ70	:= {}
Private aItensZ70U	:= {}
//Variáveis para Aba pagamentos
Private oSayG3_1_1, oSayG3_1_2, oSayG3_1_3, oSayG3_1_4, oSayG3_1_5, oSayG3_1_6, oSayG3_1_7
Private cValG3_1_1, cValG3_1_2
//Variáveis para Aba pagamentos
Private oSayG3_2_1, oSayG3_2_2, oSayG3_2_3, oSayG3_2_4, oSayG3_2_5, oSayG3_2_6, oSayG3_2_7
Private cValG3_2_1, cValG3_2_2
//Variáveis para Aba pagamentos
Private aCombo_1_7	:= {"Sim","Nao"}
Private cCombo_1_7 	:= aCombo_1_7[2]
//Variáveis para Aba pagamentos
Private aCombo_1_8	:= {"Sim","Nao"}
Private cCombo_1_8 	:= aCombo_1_8[2]


SET DATE FORMAT "dd/mm/yyyy"

AADD( aButtons, {"ADICIONAR_001", {|| AnexoP00()}, "Arquivos...","Arquivos",{|| .T.}} )

	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z79")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z79"

		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z79_FILIAL" )
			
			
			//Aba cadastro
			if SX3->X3_FOLDER=='1'
			
				AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
				AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
				
			endif
		
			//Aba Dados de Cobrança
			if SX3->X3_FOLDER=='2'
			
				AADD(aCpoEnCob,alltrim(SX3->X3_CAMPO))
				AADD(aAltCobEn,alltrim(SX3->X3_CAMPO))
				
			endif			
		
			
		endif
			
		SX3->(DbSkip())
	Enddo

	AADD(aCpoEnch,"NOUSER")
	AADD(aCpoEnCob,"NOUSER")	

	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z78")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z78"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z78_FILIAL")
			AADD(aCpoGDa,alltrim(SX3->X3_CAMPO))
			AADD(aAlter,alltrim(SX3->X3_CAMPO))		
		endif
			
		SX3->(DbSkip())
	Enddo

Do Case
	Case xParam3 == 2
		VISUAL := .T.     
	Case xParam3 == 3
		ALTERA := .T.
		aAlterEnch	:= {"Z79_OBSGT"}
		aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 4
		ALTERA := .T.
		aAlterEnch	:= {"Z79_OBSGT"}
		aAltCobEn	:= {}
		nOpc2:=4

EndCase    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()

AAdd( aObjects, { 100, 60, .T., .T. } )
AAdd( aObjects, { 100, 40, .T., .T. } )

AAdd( aObjects2,{ 100, 100, .T., .T. } )

AAdd( aObjects3, { 100, 50, .T., .T. } )
AAdd( aObjects3, { 100, 50, .T., .T. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)
aPosObj2:= MsObjSize( aInfo, aObjects2,.T.)

aPosObj3:= MsObjSize( aInfo, aObjects3,.T.)

aPosObjEnch		:= {aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]-150}

aPosObjGroup	:= {aPosObj[1][1],aPosObj[1][4]-150+3,aPosObj[1][3],aPosObj[1][4]-4}

aPosObjFo1		:= {aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][3],aPosObj3[1][4]/2}
aPosObjFo2		:= {aPosObj3[1][1],aPosObj3[1][4]/2,aPosObj3[1][3],aPosObj3[1][4]}

aPosObjFo3		:= {aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][3]-15,aPosObj3[2][4]/2}
aPosObjFo4		:= {aPosObj3[2][1],aPosObj3[2][4]/2,aPosObj3[2][3]-15,aPosObj3[2][4]}

aLbxCoords	:= { aPosObj[2,1]		, aPosObj[2,2] , aPosObj[2,4]-5 	, RetFatListBox(aPosObj[2,3])+15 }

aLbxCooFo2	:= { aPosObj2[1,1]		, aPosObj2[1,2] , aPosObj2[1,4]-5 	, aPosObj2[1,3]-20 }

aLbxFo1		:= { aPosObj3[1,1]	, aPosObj3[1,2] , (aPosObj3[1,4]/2)-40 	, aPosObj3[1,3]-70 }

aGprCoords	:= { aPosObj[1,1]		, aPosObj[1,2] , aPosObj[1,4]-5 	, RetFatListBox(aPosObj[1,3])+15 }


// Criação do aHeader temporário para ser usado nas parcelas, Valor da proposta
Private aHeadVlr	:= {}
Private aAcolVlr	:= {}
Private nUseVlr		:= 0
Private aAlterVlr	:= {"M_VENC","M_VALOR"}

			AADD(aHeadVlr,{ TRIM("Parcela"),;
								 "M_PARC",;
								 "@999",;
								 3,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUseVlr:=nUseVlr+1
			AADD(aHeadVlr,{ TRIM("Vencimento"),;
								 "M_VENC",;
								 "",;
								 8,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "D",;
			 					 "",;
			 					 "" } )
		    nUseVlr:=nUseVlr+1
			AADD(aHeadVlr,{ TRIM("Valor"),;
								 "M_VALOR",;
								 "@E 99,999,999,999.99",;
								 17,;
			 					 2,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "N",;
			 					 "",;
			 					 "" } )
		    nUseVlr:=nUseVlr+1
		    
// Criação do aHeader temporário para ser usado nas parcelas, valor da implantação
Private aHeadImp	:= {}
Private aAcolImp	:= {}
Private nUseImp		:= 0
Private aAlterImp	:= {"M_VENC","M_VALOR"}

			AADD(aHeadImp,{ TRIM("Parcela"),;
								 "M_PARC",;
								 "@999",;
								 3,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUseImp:=nUseImp+1
			AADD(aHeadImp,{ TRIM("Vencimento"),;
								 "M_VENC",;
								 "",;
								 8,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "D",;
			 					 "",;
			 					 "" } )
		    nUseImp:=nUseImp+1
			AADD(aHeadImp,{ TRIM("Valor"),;
								 "M_VALOR",;
								 "@E 99,999,999,999.99",;
								 17,;
			 					 2,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "N",;
			 					 "",;
			 					 "" } )
		    nUseImp:=nUseImp+1		    

// Criação do aHeader temporário para ser usado nas parcelas, valor de DIPJ
Private aHeadDip	:= {}
Private aAcolDip	:= {}
Private nUseDip		:= 0
Private aAlterDip	:= {"M_VENC","M_VALOR"}

			AADD(aHeadDip,{ TRIM("Parcela"),;
								 "M_PARC",;
								 "@999",;
								 3,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUseDip:=nUseDip+1
			AADD(aHeadDip,{ TRIM("Vencimento"),;
								 "M_VENC",;
								 "",;
								 8,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "D",;
			 					 "",;
			 					 "" } )
		    nUseDip:=nUseDip+1
			AADD(aHeadDip,{ TRIM("Valor"),;
								 "M_VALOR",;
								 "@E 99,999,999,999.99",;
								 17,;
			 					 2,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "N",;
			 					 "",;
			 					 "" } )
		    nUseDip:=nUseDip+1		    

// Criação do aHeader temporário para ser usado nas parcelas, valor Anual
Private aHeadAno	:= {}
Private aAcolAno	:= {}
Private nUseAno		:= 0
Private aAlterAno	:= {"M_VENC","M_VALOR"}

			AADD(aHeadAno,{ TRIM("Parcela"),;
								 "M_PARC",;
								 "@999",;
								 3,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUseAno:=nUseAno+1
			AADD(aHeadAno,{ TRIM("Vencimento"),;
								 "M_VENC",;
								 "",;
								 8,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "D",;
			 					 "",;
			 					 "" } )
		    nUseAno:=nUseAno+1
			AADD(aHeadAno,{ TRIM("Valor"),;
								 "M_VALOR",;
								 "@E 99,999,999,999.99",;
								 17,;
			 					 2,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "N",;
			 					 "",;
			 					 "" } )
		    nUseAno:=nUseAno+1
			 					 
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
//DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To oMainWnd:nBottom-80,oMainWnd:nRight-70 of oMainWnd PIXEL
                                                 //530,850
                                                 //+100,+400

	//------>>>> Cria a Folder
	aTFolder := { 'Cadastro','Pagamentos','Histórico Posicionamento','Dados Cobrança'}
	oTFolder := TFolder():New( 2,2,aTFolder,,oDlg,,,,.T.,,623,300 )
	//------>>>> Fim do criar folder

	// <-> FOLDER 1
	//Carrega as variáveris da tabela Z79
	RegToMemory(cAliasE,.F., .T.)

    cRev	:=M->Z79_REVISA

	//Tratamento para não deixar recusar quando está vazio
	if nOpc==3
		if empty(M->Z79_NUM)
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível quando não existem propostas!")
			Return()
		elseif alltrim(M->Z79_STATUS)<>"3"
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Não é permitido recusar propostas que não estão pendentes!")
			Return()		
		endif
	endif

	//Tratamento para não deixar Aprovar quando está vazio
	if nOpc==4
		if alltrim(M->Z79_STATUS)<>"3"
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Não é permitido aprovar propostas que não estão pendentes!")
			Return()		
		endif
	endif
	                                                                   //aPos
	Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPosObjEnch,;
			aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oTFolder:aDialogs[1],lF3,;    
			lMemoria,lColumn,caTela,lNoFolder,lProperty)                    

	//------>>Posicionamento		
	oGroup:= tGroup():New(aPosObjGroup[1],aPosObjGroup[2],aPosObjGroup[3],aPosObjGroup[4],'Posicionamento',oTFolder:aDialogs[1],,,.T.)			
	//BarraProcess(oTFolder:aDialogs[1],aPosObjGroup) 
	
		//Montagem da barra
		oSlider := TSlider():New( aPosObjGroup[1]+10,aPosObjGroup[2]+10,oTFolder:aDialogs[1],{|x| ContaBarra(x,@cTexto,oTexto)},125,30,"Processamento",) 
		
		oSlider:setRange(0,100) //Seta o range: Posição inicial -- Posição final
		oSlider:setInterval(25)

		oSlider:setMarks(3) //Seta o tipo da medida 3 - medida em cima e em baixo
		oSlider:setStep(25)
		oFont:= TFont():New('Arial',,-14,.T.)

					//GarregaZ70(nOpc,1,Z79->Z79_NUM,Z79->Z79_REVISA) //Passando nopc 4 para visualizar os posicionamentos no recusar
		aItensZ70U	:= GarregaZ70(4,1,Z79->Z79_NUM,Z79->Z79_REVISA)
		if !empty(aItensZ70U)
			cTexto		:= aItensZ70U[1][3]
			cMemo		:= aItensZ70U[1][5]
			oSlider:SetValue(val(aItensZ70U[1][3]))
			oSlider:Refresh()
		endif

		
		// Exibe o texto com o valor da barrinha
		@ aPosObjGroup[1]+45,aPosObjGroup[2]+( (aPosObjGroup[4]-aPosObjGroup[2])/2 ) Say oTexto Var cTexto+" %" Size 229,041 FONT oFont COLOR CLR_BLACK PIXEL OF oTFolder:aDialogs[1]

		oSay:= tSay():New(aPosObjGroup[1]+65,aPosObjGroup[2]+10,{||'Descrição'},oTFolder:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		                                                                                                                          
		oMemo:= tMultiget():New(aPosObjGroup[1]+75,aPosObjGroup[2]+10,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oTFolder:aDialogs[1],120,aGprCoords[4]/2,,,,,,.T.)
		
		oSlider:disable()
		oMemo:disable()

		
	//------>> FIm Posicionamento					
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o aHeader										 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoGDa)                                                                                                     
		If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
			nUsado++
		AADD(aHeader,{ 	ALLTRIM(X3TITULO()), ;
						SX3->X3_CAMPO, ;
						SX3->X3_PICTURE, ;
						SX3->X3_TAMANHO, ;
						SX3->X3_DECIMAL, ;
						'ALLWAYSTRUE()', ;
						SX3->X3_USADO, ;
						SX3->X3_TIPO, ; 
						SX3->X3_F3, ;
						SX3->X3_CONTEXT, ;
						SX3->X3_CBOX, ;
						SX3->X3_RELACAO ;
						})
	
		Endif                                                                                                                         
	Next nX                                                                                                                         
	

	//Carrega as variáveis no aCols
	DbSelectArea("Z79")
	Z79->(DbGoTo(nReg))
	cFilNum:= Z79->Z79_FILIAL+Z79->Z79_NUM+Z79->Z79_REVISA
	
	aCols:={}
	dbSelectArea("Z78")
	dbSetOrder(1)
	dbSeek(cFilNum)
	While !eof() .AND. Z78_NUM==M->Z79_NUM .AND. Z78_REVISA==cRev .AND. Z78_FILIAL==xFilial("Z78")
		AADD(aCols,Array(nUsado+1))
			For nX:=1 to nUsado
				aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
			Next
		aCols[Len(aCols),nUsado+1]:=.F.
		Z78->(dbSkip())
	End
	
	if nOpc<>6
		nMax:=Len(aCols) //Tratamento para não permitir inserir mais linhas no alterar
	endif

	
	//oGetDados:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
	//                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

	oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
	                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

    oGetDados :ForceRefresh()              
    
    if nOpc<>3 .AND. nOpc<>4 .AND. nOpc<>6
	    oGetDados:Disable()
    endif

	
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	// <-> FIM FOLDER 1
	
	
	// <-> FOLDER 3
    
        if nOpc <> 6
			        //GarregaZ70(nOpc,2,Z79->Z79_NUM,Z79->Z79_REVISA) //Passando nopc 4 para visualizar os posicionamentos no recusar
			aItensZ70:=GarregaZ70(4,2,Z79->Z79_NUM,Z79->Z79_REVISA)
		endif

		@ aLbxCooFo2[1],aLbxCooFo2[2] LISTBOX oQual VAR cVarQ Fields HEADER "Data","Hora","Porcetagem","Usuário","Descrição" SIZE;
		aLbxCooFo2[3],aLbxCooFo2[4] OF oTFolder:aDialogs[3] PIXEL
		
		if !empty(aItensZ70)
			oQual:SetArray(aItensZ70)
			
			oQual:bLine := { || {aItensZ70[oQual:nAt,1],aItensZ70[oQual:nAt,2],aItensZ70[oQual:nAt,3],aItensZ70[oQual:nAt,4],aItensZ70[oQual:nAt,5]}}
	    endif
	
	// <-> FIM FOLDER 3
	
	// <-> FOLDER 2
		
		oGroup3_1	:= tGroup():New(aPosObjFo1[1],aPosObjFo1[2],aPosObjFo1[3]-2,aPosObjFo1[4]-2,'Valor Proposta',oTFolder:aDialogs[2],,,.T.)
		oGroup3_2	:= tGroup():New(aPosObjFo2[1],aPosObjFo2[2]+2,aPosObjFo2[3]-2,aPosObjFo2[4],'Valor Implantação',oTFolder:aDialogs[2],,,.T.)

		oGroup3_3	:= tGroup():New(aPosObjFo3[1],aPosObjFo3[2],aPosObjFo3[3],aPosObjFo3[4]-2,'Valor DIPJ',oTFolder:aDialogs[2],,,.T.)
		oGroup3_4	:= tGroup():New(aPosObjFo4[1],aPosObjFo4[2]+2,aPosObjFo4[3],aPosObjFo4[4],'Valor Anual',oTFolder:aDialogs[2],,,.T.)
	
		//----------Primeiro quadro - Valor da proposta		
		
			cValG3_1_1:= Transform(M->Z79_VALOR,'@E 99,999,999,999.99')
			cValG3_1_2:= ""
			cValG3_1_4:= SPACE(3)
			cValG3_1_6:= CTOD("//")//SPACE(2)

			cNum:=M->Z79_NUM
			cRev:=M->Z79_REVISA

			//Carregando itens da tabela Z69 --pagamentos
			aAcolVlrAx:=GarregaZ69(4,cNum,cRev,"PROPOSTA")

			nPosVencVl	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrVl	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolVlrAx)
				for nF:=1 to len(aAcolVlrAx)
			   		AADD(aAcolVlr,{})
			   		for nG:=1 to len(aAcolVlrAx[nF])
			   			if nG<>1
			   				if valtype(aAcolVlrAx[nF][nG-1])=="L"
			   					exit
			   				endif
			   			endif
						
						if nPosVencVl==nG
							AADD(aAcolVlr[nF],STOD(aAcolVlrAx[nF][nG]))
						else
				   			AADD(aAcolVlr[nF],aAcolVlrAx[nF][nG])
				  		endif
				  		
				  		if nPosVlrVl==nG
					  		nTotVlParc+=aAcolVlrAx[nF][nG]
				  		endif
				  		
			   		next
				next

				cValG3_1_6	:= STOD(aAcolVlrAx[1][5])//dia de vencimento
				cCombo_1_7	:= iif(UPPER(aAcolVlrAx[1][6])=="S","Sim","Nao")//inclui DIPJ
				cCombo_1_8	:= iif(UPPER(aAcolVlrAx[1][7])=="S","Sim","Nao")//inclui Anual
				cValG3_1_4	:= aAcolVlrAx[len(aAcolVlrAx)][1]//número de parcelas
				cValG3_1_2	:= Transform(nTotVlParc,'@E 99,999,999,999.99') //Total das parcelas
				cValG3_1_1	:= Transform(M->Z79_VALOR+(iif(aAcolVlrAx[1][6]=="S",M->Z79_VLDIPJ,0))+(iif(aAcolVlrAx[1][7]=="S",M->Z79_VLRANO,0)),'@E 99,999,999,999.99') //Adiciona o valor de DIPJ ou Anual caso seja sim nas opções
			
			endif
			
			
			oSayG3_1_1		:= tSay():New(aPosObjFo1[1]+15,aPosObjFo1[2]+10, {||'Valor da Proposta: ' +alltrim(cValG3_1_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_1_2		:= tSay():New(aPosObjFo1[1]+15,aPosObjFo1[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_1_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_1_3		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo1[1]+25,aPosObjFo1[2]+40	MSGET oSayG3_1_4 VAR cValG3_1_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO1(oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VALOR,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr))
	
			oSayG3_1_5		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+110, {||'Dia Vencto: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo1[1]+25,aPosObjFo1[2]+140	MSGET oSayG3_1_6 VAR cValG3_1_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cValG3_1_6,oGetDdsVlr,aHeadVlr))
			        
			
			oSayG3_1_7		:= tSay():New(aPosObjFo1[1]+14,aPosObjFo1[2]+200, {||'Incluir DIPJ: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oCombo_1_7		:= tComboBox():New(aPosObjFo1[1]+13,aPosObjFo1[2]+235,{|u|if(PCount()>0,cCombo_1_7:=u,cCombo_1_7)},aCombo_1_7,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VALOR,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr)},,,,.T.,,,,,,,,,'cCombo_1_7')
	
			oSayG3_1_8		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+200, {||'Incluir Anual: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oCombo_1_8		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+235,{|u|if(PCount()>0,cCombo_1_8:=u,cCombo_1_8)},aCombo_1_8,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VALOR,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr)},,,,.T.,,,,,,,,,'cCombo_1_8')
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsVlr:= MsNewGetDados():New(aPosObjFo1[1]+47,aPosObjFo1[2]+10,aPosObjFo1[3]-10,aPosObjFo1[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterVlr,000,val(cValG3_1_4),"U_I_FG40O1","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oCombo_1_7:Disable()
			oCombo_1_8:Disable()
			
		//----------Fim Primeiro quadro - Valor da proposta
			                                           
		//----------Segundo quadro - Valor da implantação
		
			cValG3_2_1:= Transform(M->Z79_VLRIMP,'@E 99,999,999,999.99')
			cValG3_2_2:= ""
			cValG3_2_4:= SPACE(3)
			cValG3_2_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z69 --pagamentos
			aAcolImpAx:=GarregaZ69(4,cNum,cRev,"IMPLANTACAO")

			nPosVencIm	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrIm	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolImpAx)
				for nF:=1 to len(aAcolImpAx)
			   		AADD(aAcolImp,{})
			   		for nG:=1 to len(aAcolImpAx[nF])
			   			if nG<>1
			   				if valtype(aAcolImpAx[nF][nG-1])=="L"
			   					exit
			   				endif
			   			endif
						
						if nPosVencIm==nG
							AADD(aAcolImp[nF],STOD(aAcolImpAx[nF][nG]))
						else
				   			AADD(aAcolImp[nF],aAcolImpAx[nF][nG])
				  		endif
				  		
				  		if nPosVlrIm==nG
					  		nTotVlParc+=aAcolImpAx[nF][nG]
				  		endif
				  		
			   		next
				next

				cValG3_2_6	:= STOD(aAcolImpAx[1][5])//dia de vencimento
				cValG3_2_4	:= aAcolImpAx[len(aAcolImpAx)][1]//número de parcelas
				cValG3_2_2	:= Transform(nTotVlParc,'@E 99,999,999,999.99') //Total das parcelas
			
			endif
							
			oSayG3_2_1		:= tSay():New(aPosObjFo2[1]+15,aPosObjFo2[2]+10, {||'Valor da Implantação: ' +alltrim(cValG3_2_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_2_2		:= tSay():New(aPosObjFo2[1]+15,aPosObjFo2[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_2_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_2_3		:= tSay():New(aPosObjFo2[1]+27,aPosObjFo2[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo2[1]+25,aPosObjFo2[2]+40	MSGET oSayG3_2_4 VAR cValG3_2_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO2(oGetDdsImp,cValG3_2_4,Transform(M->Z79_VLRIMP,'@E 99,999,999,999.99'),@oSayG3_2_1,@cValG3_2_1,@cValG3_2_2,oSayG3_2_2,cValG3_2_6,oGetDdsImp,aHeadImp))
	
			oSayG3_2_5		:= tSay():New(aPosObjFo2[1]+27,aPosObjFo2[2]+110, {||'Dia Vencto: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo2[1]+25,aPosObjFo2[2]+140	MSGET oSayG3_2_6 VAR cValG3_2_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cValG3_2_6,oGetDdsImp,aHeadImp))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsImp:= MsNewGetDados():New(aPosObjFo2[1]+47,aPosObjFo2[2]+10,aPosObjFo2[3]-10,aPosObjFo2[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterImp,000,val(cValG3_2_4),"U_I_FG40O2","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadImp,aAcolImp)
			
			
		//----------Fim Segundo quadro - Valor da implantação
			                                                 
		//----------Terceiro quadro - Valor de DIPJ
		
			cValG3_3_1:= Transform(M->Z79_VLDIPJ,'@E 99,999,999,999.99')
			cValG3_3_2:= ""
			cValG3_3_4:= SPACE(3)
			cValG3_3_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z69 --pagamentos
			aAcolDipAx:=GarregaZ69(4,cNum,cRev,"DIPJ")

			nPosVencDi	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrDi	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolDipAx)
				for nF:=1 to len(aAcolDipAx)
			   		AADD(aAcolDip,{})
			   		for nG:=1 to len(aAcolDipAx[nF])
			   			if nG<>1
			   				if valtype(aAcolDipAx[nF][nG-1])=="L"
			   					exit
			   				endif
			   			endif
						
						if nPosVencDi==nG
							AADD(aAcolDip[nF],STOD(aAcolDipAx[nF][nG]))
						else
				   			AADD(aAcolDip[nF],aAcolDipAx[nF][nG])
				  		endif
				  		
				  		if nPosVlrDi==nG
					  		nTotVlParc+=aAcolDipAx[nF][nG]
				  		endif
				  		
			   		next
				next

				cValG3_3_6	:= STOD(aAcolDipAx[1][5])//dia de vencimento
				cValG3_3_4	:= aAcolDipAx[len(aAcolDipAx)][1]//número de parcelas
				cValG3_3_2	:= Transform(nTotVlParc,'@E 99,999,999,999.99') //Total das parcelas
			
			endif
							
			oSayG3_3_1		:= tSay():New(aPosObjFo3[1]+15,aPosObjFo3[2]+10, {||'Valor de DIPJ: ' +alltrim(cValG3_3_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_3_2		:= tSay():New(aPosObjFo3[1]+15,aPosObjFo3[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_3_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_3_3		:= tSay():New(aPosObjFo3[1]+27,aPosObjFo3[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo3[1]+25,aPosObjFo3[2]+40	MSGET oSayG3_3_4 VAR cValG3_3_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO3(oGetDdsDip,cValG3_3_4,Transform(M->Z79_VLDIPJ,'@E 99,999,999,999.99'),@oSayG3_3_1,@cValG3_3_1,@cValG3_3_2,oSayG3_3_2,cValG3_3_6,oGetDdsDip,aHeadDip))
	
			oSayG3_3_5		:= tSay():New(aPosObjFo3[1]+27,aPosObjFo3[2]+110, {||'Dia Vencto: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo3[1]+25,aPosObjFo3[2]+140	MSGET oSayG3_3_6 VAR cValG3_3_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cValG3_3_6,oGetDdsDip,aHeadDip))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsDip:= MsNewGetDados():New(aPosObjFo3[1]+47,aPosObjFo3[2]+10,aPosObjFo3[3]-10,aPosObjFo3[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterDip,000,val(cValG3_3_4),"U_I_FG40O3","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadDip,aAcolDip)
			
			
		//----------Fim Terceiro quadro - Valor de DIPJ

		//----------Quarto quadro - Valor Anual
		
			cValG3_4_1:= Transform(M->Z79_VLRANO,'@E 99,999,999,999.99')
			cValG3_4_2:= ""
			cValG3_4_4:= SPACE(3)
			cValG3_4_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z69 --pagamentos
			aAcolAnoAx:=GarregaZ69(4,cNum,cRev,"ANUAL")

			nPosVencAn	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrAn	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolAnoAx)
				for nF:=1 to len(aAcolAnoAx)
			   		AADD(aAcolAno,{})
			   		for nG:=1 to len(aAcolAnoAx[nF])
			   			if nG<>1
			   				if valtype(aAcolAnoAx[nF][nG-1])=="L"
			   					exit
			   				endif
			   			endif
						
						if nPosVencAn==nG
							AADD(aAcolAno[nF],STOD(aAcolAnoAx[nF][nG]))
						else
				   			AADD(aAcolAno[nF],aAcolAnoAx[nF][nG])
				  		endif
				  		
				  		if nPosVlrAn==nG
					  		nTotVlParc+=aAcolAnoAx[nF][nG]
				  		endif
				  		
			   		next
				next

				cValG3_4_6	:= STOD(aAcolAnoAx[1][5])//dia de vencimento
				cValG3_4_4	:= aAcolAnoAx[len(aAcolAnoAx)][1]//número de parcelas
				cValG3_4_2	:= Transform(nTotVlParc,'@E 99,999,999,999.99') //Total das parcelas
			
			endif
							
			oSayG3_4_1		:= tSay():New(aPosObjFo4[1]+15,aPosObjFo4[2]+10, {||'Valor Anual: ' +alltrim(cValG3_4_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_4_2		:= tSay():New(aPosObjFo4[1]+15,aPosObjFo4[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_4_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_4_3		:= tSay():New(aPosObjFo4[1]+27,aPosObjFo4[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo4[1]+25,aPosObjFo4[2]+40	MSGET oSayG3_4_4 VAR cValG3_4_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO4(oGetDdsAno,cValG3_4_4,Transform(M->Z79_VLRANO,'@E 99,999,999,999.99'),@oSayG3_4_1,@cValG3_4_1,@cValG3_4_2,oSayG3_4_2,cValG3_4_6,oGetDdsAno,aHeadAno))
	
			oSayG3_4_5		:= tSay():New(aPosObjFo4[1]+27,aPosObjFo4[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo4[1]+25,aPosObjFo4[2]+140	MSGET oSayG3_4_6 VAR cValG3_4_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cValG3_4_6,oGetDdsAno,aHeadAno))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsAno:= MsNewGetDados():New(aPosObjFo4[1]+47,aPosObjFo4[2]+10,aPosObjFo4[3]-10,aPosObjFo4[4]-10,3,"AllwaysTrue","AllwaysTrue","",;
	                             aAlterAno,000,val(cValG3_4_4),"U_I_FG40O4","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadAno,aAcolAno)
			
			
		//----------Fim Quarto quadro - Valor Anual
			
			
	// <-> FIM FOLDER 2


	// <-> INICIO FOLDER 4
	
		oEnch := MsmGet():New(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnCob,aPosObjEnch,;
			aAltCobEn,/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oTFolder:aDialogs[4],/*lF3*/,lMemoria,/*lColumn*/,;
          /*caTela*/,/*lNoFolder*/,.T.,/*aField*/,/*aFolder*/,/*lCreate*/,;
          /*lNoMDIStretch*/,/*cTela*/)
	
		oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT
		
	// <-> FIM FOLDER 4

	//Se não for incluir nem alterar

		oSayG3_1_1:Disable()
		oSayG3_1_2:Disable()
		oSayG3_1_3:Disable()
		oSayG3_1_4:Disable()
		oSayG3_1_5:Disable()
		oSayG3_1_6:Disable()
		oSayG3_1_7:Disable()
		oCombo_1_7:Disable()
		oSayG3_1_8:Disable()
		oCombo_1_8:Disable()
		oGetDdsVlr:Disable()
		
		oSayG3_2_1:Disable()
		oSayG3_2_2:Disable()
		oSayG3_2_3:Disable()
		oSayG3_2_4:Disable()
		oSayG3_2_5:Disable()
		oSayG3_2_6:Disable()
		oGetDdsImp:Disable()
		
		oSayG3_3_1:Disable()
		oSayG3_3_2:Disable()
		oSayG3_3_3:Disable()
		oSayG3_3_4:Disable()
		oSayG3_3_5:Disable()
		oSayG3_3_6:Disable()
		oGetDdsDip:Disable()

		oSayG3_4_1:Disable()
		oSayG3_4_2:Disable()
		oSayG3_4_3:Disable()
		oSayG3_4_4:Disable()
		oSayG3_4_5:Disable()
		oSayG3_4_6:Disable()
		oGetDdsAno:Disable()


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| ;
iif(Grava(aHeader,IIF(nOpc==5,aColsAux,oGetDados:aCols),aCpoEnch,nOpc,aAlterEnch,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno;
,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6),oDlg:End(),);
},{||oDlg:End()},,aButtons) CENTERED
         
Return(.T.)

/*
Funcao      : Grava()  
Parametros  : Header,aCols,cAno,nOpc,aAlterEnch
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/Aprovação
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Static Function Grava(aHeader,aCols,aCpoEnch,nOpc,aAlterEnch,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*

if nOpc==3 //Recusar

    //Valida se o campo de Observação está preenchido
    if empty(M->Z79_OBSGT)
		Alert("Por favor, preencha o campo de observação.")
   		Return .F.
    endif

	BEGIN TRANSACTION	
		RECLOCK("Z79",.F.)
			Z79->Z79_STATUS	:= "4"
			Z79->Z79_OBSGT	:= M->Z79_OBSGT
			Z79->Z79_DTREGT	:= dDataBase
			Z79->Z79_HRREGT	:= TIME()
		Z79->(MsUnLock())
		ConfirmSx8()
	END TRANSACTION 

	//Pega o e-mail do responsável pela proposta.
	cTo:=UsrRetMail(M->Z79_RESPON)

	//Pega o e-mail do usuário que incluiu a proposta.
	cTo+=IIF(!empty(cTo),";","")+UsrRetMail(M->Z79_USERRE)
	
	//Envia e-mail para o responsável e o usuário, informando sobre a aprovada ou recusa
	EnvMaiSo(cTo,nOpc)

elseif nOpc==4 //Aprovar
       //transforma horas para minutos
	if Hrs2Min(Z79->Z79_TIMEUS)<>Hrs2Min(Z79->Z79_TIME)
		if !MsgYesNo("O total de horas calculadas pelo sistema é diferente do informado pelo responsável!"+CRLF+"Deseja continuar assim mesmo?")
			return(.F.)
		endif		
	endif

	BEGIN TRANSACTION	
		RECLOCK("Z79",.F.)
			Z79->Z79_STATUS	:= "5"
			Z79->Z79_OBSGT	:= M->Z79_OBSGT
			Z79->Z79_DTAPGT	:= dDataBase
			Z79->Z79_HRAPGT	:= TIME()
		Z79->(MsUnLock())
		ConfirmSx8()
	END TRANSACTION 
	

	//Pega o e-mail do responsável pela proposta.
	cTo:=UsrRetMail(M->Z79_RESPON)

	//Pega o e-mail do usuário que incluiu a proposta.
	cTo+=IIF(!empty(cTo),";","")+UsrRetMail(M->Z79_USERRE)
	
	//Envia e-mail para o responsável e o usuário, informando sobre a aprovação ou recusa
	EnvMaiSo(cTo,nOpc)
	
endif

Return(.T.)

/*
Funcao      : ContaBarra
Parametros  : x,cTexto,oTexto
Retorno     : 
Objetivos   : Função alterar a escrita(SAY) na tela, com a porcentagem da barrinha
Autor       : Matheus Massarotto
Data/Hora   : 17/10/2012
*/
*-----------------------------------------*
Static Function ContaBarra(x,cTexto,oTexto)
*-----------------------------------------*
teste:=""
if x>val(cTexto)
	if x>=0 .AND. x<=25
		x:=25
	elseif x>25 .AND. x<=50
		x:=50
	elseif x>50 .AND. x<=75
		x:=75
	elseif x>75 .AND. x<=100
		x:=100
	endif
else
	if x>=0 .AND. x<25
		x:=0
	elseif x>=25 .AND. x<50
		x:=25
	elseif x>=50 .AND. x<75
		x:=50
	elseif x>=75 .AND. x<100
		x:=75
	endif
endif

	cTexto:=cvaltochar(x)
	oTexto:Refresh()
	oSlider:SetValue(x)
Return


/*
Funcao      : GarregaZ70
Parametros  : nOpc,nMax,cNum,cRev
Retorno     : aRet
Objetivos   : Função para carregar a tabela Z70 e retornar um array com as informações
Autor       : Matheus Massarotto
Data/Hora   : 18/10/2012
*/
*-----------------------------------------*
Static Function GarregaZ70(nOpc,nMax,cNum,cRev)
*-----------------------------------------*
Local aRet	:= {}
Local cQry	:= ""


if nOpc<>3

	cQry:=" SELECT * FROM "+RETSQLNAME("Z70")+CRLF	
	cQry+=" WHERE Z70_PROPOS='"+cNum+"' "+CRLF
	cQry+=" AND Z70_REVISA='"+cRev+"' "+CRLF
	cQry+=" AND Z70_FILIAL='"+xFilial("Z70")+"' "+CRLF
	cQry+=" AND D_E_L_E_T_='' "+CRLF

	
    //nMax==1 retorna o ultimo posiionamento da proposta
	if nMax==1
		cQry+=" AND Z70_ID=(
		cQry+=" SELECT MAX(Z70_ID) FROM "+RETSQLNAME("Z70")+CRLF
		cQry+=" WHERE Z70_PROPOS='"+cNum+"' "+CRLF
		cQry+=" AND Z70_REVISA='"+cRev+"' "+CRLF
		cQry+=" AND Z70_FILIAL='"+xFilial("Z70")+"' "+CRLF
		cQry+=" AND D_E_L_E_T_='' "+CRLF
		cQry+=")"
	endif
	
	cQry+=" ORDER BY Z70_ID "
	
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
	        
			if nRecCount >0
	        	QRYTEMP->(DbGotop())
				
				While QRYTEMP->(!EOF())
					
					AADD(aRet,{DTOC(STOD(QRYTEMP->Z70_DATA)),QRYTEMP->Z70_HORA,QRYTEMP->Z70_PORCEN,QRYTEMP->Z70_USER,QRYTEMP->Z70_MOTIVO})
					QRYTEMP->(DbSkip())
				EndDo
				
	        endif
endif

Return(aRet)

/*
Funcao      : LoadPaO1
Parametros  : oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead,lIncDIPJ,lIncAnual
Retorno     : 
Objetivos   : Função para carregar as parcelas no aCols, da proposta
Autor       : Matheus Massarotto
Data/Hora   : 07/11/2012
*/

*-----------------------------------------------------------------------------------------------------------------------------------*
Static Function LoadPaO1(oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead,lIncDIPJ,lIncAnual)
*-----------------------------------------------------------------------------------------------------------------------------------*
Local nVal	 	:= val(StrTran(cValAux,"."))/val(cValG3_1_4)
Local nTotVal	:= 0
oQual1:aCols	:= {}

DEFAULT lIncDIPJ	:= .F.
DEFAULT lIncAnual	:= .F.

	if val(cValG3_1_4)<>0
		for i:=1 to val(cValG3_1_4)
			AADD(oQual1:aCols,{cvaltochar(i), CTOD("//"),nVal,.F. })
			nTotVal+=nVal
		next

		oCombo_1_7:Enable()
		oCombo_1_8:Enable()
	else
		oCombo_1_7:Disable()
		oCombo_1_8:Disable()
		oQual1:aCols:={}
	endif

cValG3_1_2:=Transform(nTotVal,'@E 99,999,999,999.99')

//Tratamento para adicionar o valor de dipj ou anual no valor total para parcelamento
if lIncDIPJ .AND. lIncAnual
	cValG3_1_1:=Transform(M->Z79_VALOR+M->Z79_VLDIPJ+M->Z79_VLRANO,'@E 99,999,999,999.99')
elseif lIncDIPJ .AND. !lIncAnual
	cValG3_1_1:=Transform(M->Z79_VALOR+M->Z79_VLDIPJ,'@E 99,999,999,999.99')
elseif !lIncDIPJ .AND. lIncAnual
	cValG3_1_1:=Transform(M->Z79_VALOR+M->Z79_VLRANO,'@E 99,999,999,999.99')
else
	cValG3_1_1:=Transform(M->Z79_VALOR,'@E 99,999,999,999.99')
endif


oQual1:Refresh()
oSayG3_1_1:Refresh()
oSayG3_1_2:Refresh()

CarregaDia(cVal,oGetDad,aHead)

Return

/*
Funcao      : LoadPaO2
Parametros  : oQual1,cValG3_2_4,cValAux,oSayG3_2_1,cValG3_2_1,cValG3_2_2,oSayG3_2_2,cVal,oGetDad,aHead
Retorno     : 
Objetivos   : Função para carregar as parcelas no aCols, da implantação
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/

*----------------------------------------------------------------------------------------------------------------*
Static Function LoadPaO2(oQual1,cValG3_2_4,cValAux,oSayG3_2_1,cValG3_2_1,cValG3_2_2,oSayG3_2_2,cVal,oGetDad,aHead)
*----------------------------------------------------------------------------------------------------------------*
Local nVal	 	:= val(StrTran(cValAux,"."))/val(cValG3_2_4)
Local nTotVal	:= 0
oQual1:aCols	:= {}

	if val(cValG3_2_4)<>0
		for i:=1 to val(cValG3_2_4)
			AADD(oQual1:aCols,{cvaltochar(i), CTOD("//"),nVal,.F. })
			nTotVal+=nVal
		next
	else
		oQual1:aCols:={}
	endif

cValG3_2_2:=Transform(nTotVal,'@E 99,999,999,999.99')

cValG3_2_1:=Transform(M->Z79_VLRIMP,'@E 99,999,999,999.99')

oQual1:Refresh()
oSayG3_2_1:Refresh()
oSayG3_2_2:Refresh()

CarregaDia(cVal,oGetDad,aHead)

Return

/*
Funcao      : LoadPaO3
Parametros  : oQual1,cValG3_3_4,cValAux,oSayG3_3_1,cValG3_3_1,cValG3_3_2,oSayG3_3_2,cVal,oGetDad,aHead
Retorno     : 
Objetivos   : Função para carregar as parcelas no aCols, da implantação
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/

*----------------------------------------------------------------------------------------------------------------*
Static Function LoadPaO3(oQual1,cValG3_3_4,cValAux,oSayG3_3_1,cValG3_3_1,cValG3_3_2,oSayG3_3_2,cVal,oGetDad,aHead)
*----------------------------------------------------------------------------------------------------------------*
Local nVal	 	:= val(StrTran(cValAux,"."))/val(cValG3_3_4)
Local nTotVal	:= 0
oQual1:aCols	:= {}

	if val(cValG3_3_4)<>0
		for i:=1 to val(cValG3_3_4)
			AADD(oQual1:aCols,{cvaltochar(i), CTOD("//"),nVal,.F. })
			nTotVal+=nVal
		next
	else
		oQual1:aCols:={}
	endif

cValG3_3_2:=Transform(nTotVal,'@E 99,999,999,999.99')

cValG3_3_1:=Transform(M->Z79_VLDIPJ,'@E 99,999,999,999.99')

oQual1:Refresh()
oSayG3_3_1:Refresh()
oSayG3_3_2:Refresh()

CarregaDia(cVal,oGetDad,aHead)

Return

/*
Funcao      : LoadPaO4
Parametros  : oQual1,cValG3_4_4,cValAux,oSayG3_4_1,cValG3_4_1,cValG3_4_2,oSayG3_4_2,cVal,oGetDad,aHead
Retorno     : 
Objetivos   : Função para carregar as parcelas no aCols, do Anual
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/

*----------------------------------------------------------------------------------------------------------------*
Static Function LoadPaO4(oQual1,cValG3_4_4,cValAux,oSayG3_4_1,cValG3_4_1,cValG3_4_2,oSayG3_4_2,cVal,oGetDad,aHead)
*----------------------------------------------------------------------------------------------------------------*
Local nVal	 	:= val(StrTran(cValAux,"."))/val(cValG3_4_4)
Local nTotVal	:= 0
oQual1:aCols	:= {}

	if val(cValG3_4_4)<>0
		for i:=1 to val(cValG3_4_4)
			AADD(oQual1:aCols,{cvaltochar(i), CTOD("//"),nVal,.F. })
			nTotVal+=nVal
		next
	else
		oQual1:aCols:={}
	endif

cValG3_4_2:=Transform(nTotVal,'@E 99,999,999,999.99')

cValG3_4_1:=Transform(M->Z79_VLRANO,'@E 99,999,999,999.99')

oQual1:Refresh()
oSayG3_4_1:Refresh()
oSayG3_4_2:Refresh()

CarregaDia(cVal,oGetDad,aHead)

Return

/*
Funcao      : CarregaDia
Parametros  : cVal,oGetDad,aHead
Retorno     : lRet
Objetivos   : Função para preencher as datas de vencimento no aCols
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/

*--------------------------------------------*
Static Function CarregaDia(cVal,oGetDad,aHead)
*--------------------------------------------*
Local lRet	:= .F.
Local nVal	:= val(cVal)
Local nPos	:= Ascan(aHead,{|x| alltrim(x[2]) = "M_VENC"})
Local dDate	:= CTOD("//")

if !empty(cVal)
	if nVal>0 .AND. nVal<32
		lRet:=.T.
	else
		alert("Dia inválido!")
	endif
else
	lRet:=.T.
endif

if lRet .AND. nPos<>0 //Se o dia for válido e o campo do acols for o de vencimento 
   	if val(cVal)<=DAY(dDataBase) //se o dia for menor que o dia da database somo 1 mês na primeira data
	   	if val(cVal)>30
	   		dDate:= LastDay(CTOD("01"+"/"+STRZERO(Month(MonthSum(dDataBase,1)),2)+"/"+cvaltochar(YEAR(MonthSum(dDataBase,1))) ))
   		else
	   		if Month(MonthSum(dDataBase,1))==2 .AND. val(cVal)>28 //Se a próxima data do sistema for fevereiro e o dia setado for maior que 28
				dDate:=LastDay(CTOD("01"+"/"+STRZERO(Month(MonthSum(dDataBase,1)),2)+"/"+cvaltochar(YEAR(MonthSum(dDataBase,1))) ))
   		    else
		   		dDate:= CTOD(cVal+"/"+STRZERO(Month(MonthSum(dDataBase,1)),2)+"/"+cvaltochar(YEAR(MonthSum(dDataBase,1))) )   		    
   		    endif
   		endif
   	else	//se o dia for maior que o dia da database não somo 1 mês na primeira data
	   	if val(cVal)>30
    		dDate:= LastDay(CTOD("01"+"/"+STRZERO(Month(dDataBase),2)+"/"+cvaltochar(YEAR(MonthSum(dDataBase,1))) ))
		else
			if Month(dDataBase)==2 .AND. val(cVal)>28 //Se a data do sistema ja for fevereiro e o dia setado for maior que 28
				dDate:=LastDay(CTOD("01"+"/"+STRZERO(Month(dDataBase),2)+"/"+cvaltochar(YEAR(MonthSum(dDataBase,1))) ))
			else
				dDate:= CTOD(cVal+"/"+STRZERO(Month(dDataBase),2)+"/"+cvaltochar(YEAR(MonthSum(dDataBase,1))) )
			endif
	    endif
   	endif

    //Roda todas as parcelas preenchendo com os meses
	for i:=1 to len(oGetDad:Acols)
      	if i==1
      		//Tratamento para depois de usar o 28 ou 29 no mês 2 voltar o dia da data para o dia selecionado
      		if DAY(dDate)<>val(cVal) .AND. Month(dDate)<>2 .AND. DAY(LastDay(dDate))>val(cVal)
      			dDate:=STOD(SUBSTR(DTOS(dDate),1,6)+cVal)
      		endif
      		
    		oGetDad:Acols[i][nPos]:=dDate
      	else
      		if !empty(cVal)
	      		if val(cVal)>30
			      	dDate:=LastDay(MonthSum(dDate ,1)) //Soma Meses em Uma Data
				else
					//Tratamento para depois de usar o 28 ou 29 no mês 2 voltar o dia da data para o dia selecionado
					if DAY(MonthSum(dDate ,1))<>val(cVal) .AND. Month(MonthSum(dDate ,1))<>2 .AND. DAY(LastDay(MonthSum(dDate ,1)))>val(cVal)
      					dDate:=STOD(SUBSTR(DTOS(MonthSum(dDate ,1)),1,6)+cVal)
		      		else
			      		dDate:=MonthSum(dDate ,1) //Soma Meses em Uma Data
		      		endif
						  	
				endif                                                 

		      	oGetDad:Acols[i][nPos]:=dDate
			else
				oGetDad:Acols[i][nPos]:=CTOD("//")
			endif
      	endif

	next
endif

oGetDad:Refresh()
Return(lRet)


/*
Funcao      : AddDipjAnual
Parametros  : x,y,oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead
Retorno     : 
Objetivos   : Função para adicionar o valor de DIPJ/Anual de acordo com a opção selecionada no Incluir DIPJ/Incluir Anual, adiciona no acols(parcelas), e no valor da proposta, e valor total das parcelas
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/

*------------------------------------------------------------------------------------------------------------------------*
Static Function AddDipjAnual(x,y,oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead)
*------------------------------------------------------------------------------------------------------------------------*
Local nValAux
Local lDipj		:= IIF(Alltrim(UPPER(x))=="SIM",.T.,.F.)
Local lAnual	:= IIF(Alltrim(UPPER(y))=="SIM",.T.,.F.)

	if lDipj .AND. lAnual
		nValAux:=val(StrTran(cValAux,"."))+M->Z79_VLDIPJ+M->Z79_VLRANO
		
		//Zerando Valores do quadro  3- DIPJ
			cValG3_3_1:=0
			cValG3_3_2:=0	
			oSayG3_3_1:Refresh()
			oSayG3_3_2:Refresh()
			oSayG3_3_1:Disable()
			oSayG3_3_2:Disable()	
			
			cValG3_3_4:=space(3)
			oSayG3_3_4:Refresh()
			oSayG3_3_4:Disable()
			
			cValG3_3_6:=space(2)
			oSayG3_3_6:Refresh()
			oSayG3_3_6:Disable()
		
			oGetDdsDip:Acols:={}
			oGetDdsDip:Refresh()
			oGetDdsDip:Disable()
			
		//Zerando Valores do quadro  4- Anual
			cValG3_4_1:=0
			cValG3_4_2:=0	
			oSayG3_4_1:Refresh()
			oSayG3_4_2:Refresh()
			oSayG3_4_1:Disable()
			oSayG3_4_2:Disable()	
			
			cValG3_4_4:=space(3)
			oSayG3_4_4:Refresh()
			oSayG3_4_4:Disable()
			
			cValG3_4_6:=space(2)
			oSayG3_4_6:Refresh()
			oSayG3_4_6:Disable()
		
			oGetDdsAno:Acols:={}
			oGetDdsAno:Refresh()
			oGetDdsAno:Disable()
					
	elseif lDipj .AND. !lAnual
		nValAux:=val(StrTran(cValAux,"."))+M->Z79_VLDIPJ
	    
		//Zerando Valores do quadro  3- DIPJ
			cValG3_3_1:=0
			cValG3_3_2:=0	
			oSayG3_3_1:Refresh()
			oSayG3_3_2:Refresh()
			oSayG3_3_1:Disable()
			oSayG3_3_2:Disable()	
			
			cValG3_3_4:=space(3)
			oSayG3_3_4:Refresh()
			oSayG3_3_4:Disable()
			
			cValG3_3_6:=space(2)
			oSayG3_3_6:Refresh()
			oSayG3_3_6:Disable()
		
			oGetDdsDip:Acols:={}
			oGetDdsDip:Refresh()
			oGetDdsDip:Disable()
			
		//Liberando manipulação dos valores do quadro  4- Anual
			oSayG3_4_1:Enable()
			oSayG3_4_2:Enable()	
			oSayG3_4_4:Enable()
			oSayG3_4_6:Enable()
			oGetDdsAno:Enable()		
		
	elseif !lDipj .AND. lAnual
		nValAux:=val(StrTran(cValAux,"."))+M->Z79_VLRANO
		
		//Zerando Valores do quadro  4- Anual
			cValG3_4_1:=0
			cValG3_4_2:=0	
			oSayG3_4_1:Refresh()
			oSayG3_4_2:Refresh()
			oSayG3_4_1:Disable()
			oSayG3_4_2:Disable()	
			
			cValG3_4_4:=space(3)
			oSayG3_4_4:Refresh()
			oSayG3_4_4:Disable()
			
			cValG3_4_6:=space(2)
			oSayG3_4_6:Refresh()
			oSayG3_4_6:Disable()
		
			oGetDdsAno:Acols:={}
			oGetDdsAno:Refresh()
			oGetDdsAno:Disable()		
			
		//Liberando manipulação dos valores do quadro  3- DIPJ
			oSayG3_3_1:Enable()
			oSayG3_3_2:Enable()	
			oSayG3_3_4:Enable()
			oSayG3_3_6:Enable()
			oGetDdsDip:Enable()		
		
	else
		nValAux:=val(StrTran(cValAux,"."))
		
		//Liberando manipulação dos valores do quadro  3- DIPJ
			oSayG3_3_1:Enable()
			oSayG3_3_2:Enable()	
			oSayG3_3_4:Enable()
			oSayG3_3_6:Enable()
			oGetDdsDip:Enable()
	
		//Liberando manipulação dos valores do quadro  4- Anual
			oSayG3_4_1:Enable()
			oSayG3_4_2:Enable()	
			oSayG3_4_4:Enable()
			oSayG3_4_6:Enable()
			oGetDdsAno:Enable()		
	endif
		
	cValAux:=Transform(nValAux,'@E 99,999,999,999.99')
	//Se for sim o parametro 11 deve ser passado para a função como .T.
	LoadPaO1(oQual1,cValG3_1_4,cValAux,@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,@oSayG3_1_2,cVal,oGetDad,aHead,lDipj,lAnual)

Return


/*
Funcao      : GarregaZ69
Parametros  : nOpc,cNum,cRev
Retorno     : aRet
Objetivos   : Função para carregar os itens da tabela Z69
Autor       : Matheus Massarotto
Data/Hora   : 14/11/2012
*/
*------------------------------------------------------*
Static Function GarregaZ69(nOpc,cNum,cRev,cTipo)
*------------------------------------------------------*
Local aRet	:= {}
Local cQry	:= ""


if nOpc<>3

			cQry:=" SELECT * FROM "+RETSQLNAME("Z69")+CRLF
			cQry+=" WHERE D_E_L_E_T_='' AND Z69_FILIAL='"+xFilial("Z69")+"' AND Z69_PROPOS='"+cNum+"' AND Z69_REVISA='"+cRev+"' AND Z69_TIPO='"+cTipo+"' "

			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
	        
			if nRecCount >0
	        	QRYTEMP->(DbGotop())
				
				While QRYTEMP->(!EOF())
					
					//AADD(aRet,{QRYTEMP->Z69_PARCEL,QRYTEMP->Z69_VENCTO,QRYTEMP->Z69_VALOR,QRYTEMP->Z69_INCDIP,QRYTEMP->Z69_INCANO})
					AADD(aRet,{QRYTEMP->Z69_PARCEL,QRYTEMP->Z69_VENCTO,QRYTEMP->Z69_VALOR,.F.,QRYTEMP->Z69_DIAVEN,QRYTEMP->Z69_INCDIP,QRYTEMP->Z69_INCANO})
					QRYTEMP->(DbSkip())
				EndDo
				
	        endif

endif

Return(aRet)


/*
Funcao      : LEGZ79GT()  
Parametros  : cTipoCtr
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 05/12/2012
*/
*--------------------*
User Function LEGZ79GT()
*--------------------*

Local aLegenda := {	{"UPDWARNING"	,"   Pendente Aprovação GT    			" },;
					{"NOCHECKED"  	,"   Recusado GT						" },;
					{"CHECKED"  	,"   Aprovado GT						" }}
					

BrwLegenda("Legenda","Status da Proposta",aLegenda)

Return


/*
Funcao      : AnexoP00
Parametros  : 
Retorno     : Nil
Objetivos   : Rotina para manutenção de anexos.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:19
*/
*-----------------------------*
Static Function AnexoP00()
*-----------------------------*
Local lRet := .F.

Local cArqAnexo := ""

Local nI := 0
Local nP := 0

Local aButtons := {}
Local aStru    := {	{"ARQUIVO","C",100,0},;
					{"DATAARQ","D",008,0},;
					{"HORAARQ","C",010,0}}

Local bOk     := {|| lRet:= .T.,oDlgAnexo:End()}
Local bCancel := {|| oDlgAnexo:End()}

Local oDlgAnexo

Private lRefresh := .T.

Private cPastaAnexo:= '\Propostas\'+cEmpAnt+'\'
Private aAnexos  := {}

Private cLastPath := cPastaAnexo

Private aHeader     := {}
Private aCols       := {}
Private aColsAcento := {}

Private oMsGet

	aAdd(aButtons,{ "BMPINCLUIR" ,{ || alert("Opção não disponível!") }, "Adicionar arquivo" + " <F3>", "Adicionar"})
	aAdd(aButtons,{ "BPMSDOCE"   ,{ || alert("Opção não disponível!") }, "Remover arquivo"            , "Remover"  })

    DbSelectArea("Z67")
    Z67->(DbGoTop())
    DbSetOrder(1)
    DbSeek(xFilial("Z67")+M->Z79_NUM+M->Z79_REVISA)
    While Z67->(!EOF()) .AND. Z67->Z67_PROPOS==M->Z79_NUM .AND. Z67->Z67_REVISA==M->Z79_REVISA
	   	AADD(aAnexos,{Z67->Z67_ITEM,Z67->Z67_TIPO,Z67->Z67_DATA,Z67->Z67_HORA,Z67->Z67_ARQUIV})
    	Z67->(DbSkip())
    Enddo

Begin Sequence

aHeader := {{"Item"   ,"ITEM"   ,"@!",002,0,".t.",nil,"C",nil,nil } ,;
			{"Tipo"   ,"TIPO"   ,"@!",003,0,".t.",nil,"C",nil,nil } ,;			
            {"Data"   ,"DATAARQ","@D",008,0,".t.",nil,"D",nil,nil } ,;
            {"Hora"   ,"HORAARQ","@!",005,0,".t.",nil,"C",nil,nil } ,;
			{"Arquivo","ARQUIVO","@!",120,0,".t.",nil,"C",nil,nil }}

If Len(aAnexos) > 0
	For nI:=1 To Len(aAnexos)
		aAdd(aCols,{aAnexos[nI][1],aAnexos[nI][2],aAnexos[nI][3],aAnexos[nI][4],aAnexos[nI][5],.F.})
		AAdd(aColsAcento,aCols[nI][5])
	Next
Endif

DEFINE MSDIALOG oDlgAnexo TITLE "Seleção de arquivo" FROM 1,1 To 300,470 OF oMainWnd Pixel
                                             
	oMSGet:= MSGetDados():New(1, 1, 1, 1, 1,,,"",.F.,{})
 	oMsGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
	oMsGet:oBrowse:blDblClick := {|| AbreArq()}
	
	oMSGet:ForceRefresh()

ACTIVATE MSDIALOG oDlgAnexo ON INIT U_GTEnchBar(oDlgAnexo,bOk,bCancel,,aButtons) CENTERED

If lRet
	For nI:=1 to Len(aCols)
		If !aCols[nI][Len(aCols[nI])] //Verifica se está deletado
        	If aScan(aAnexos,{|e| AllTrim(e[1]) == AllTrim(aCols[nI][1])}) == 0
	        	aAdd(aAnexos,{aCols[nI][1],aCols[nI][2],aCols[nI][3],aCols[nI][4],aCols[nI][5]})
	        EndIf
		Else
        
        	nP := aScan(aAnexos,{|e| AllTrim(e[1]) == AllTrim(aCols[nI][1])}) == 0
        	If nP > 0
        		aDel(aAnexos,nP)
        		ASize(aAnexos,Len(aAnexos)-1)
        	EndIf
        	
		EndIf
	Next	
EndIf

End Sequence

Return lRet


/*
Funcao      : AbreArq
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Abre o arquivo anexo selecionado.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:24
*/
*-----------------------*
Static Function AbreArq()
*-----------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local cPastaFrom  := ""
Local nDefaultMask := 0
Local cDefaultDir  := cLastPath
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY
Local nAt := 0

Local aArea := GetArea()

//Define o arquivo
If Len(aCols) > 0
	cFile := aCols[n][5]
EndIf

//Verifica se existe arquivo a ser aberto.
If Empty(cFile)
	Return
EndIf

nAt := 1
While nAt > 0
	nAt := At("\",cFile)
    cFile := Substr(cFile,nAt+1,Len(cFile))
EndDo

//Exibe tela para gravar o arquivo.
cPastaTo := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

//Grava o arquivo no local selecionado.
If !Empty(cPastaTo)

	cPastaCod   := STRTRAN(M->Z79_NUM,"/","_") + M->Z79_REVISA +"\"
	cPastaItem  := AllTrim(aCols[n][1]) + "\"

	cPastaFrom := cPastaAnexo+cPastaCod+cPastaItem
	
	cFile := cPastaFrom + AllTrim(cFile)
	
	If CpyS2T(cFile,cPastaTo,.F.)
		MsgInfo("Arquivo salvo com sucesso.","Atenção")
	Else
		MsgInfo("Erro ao salvar o arquivo.","Atenção")
	EndIf
	
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

RestArea(aArea)

Return Nil

/*
Funcao      : EnvMaiSo
Parametros  : (cTo,nOpc)
Retorno     : Nil
Objetivos   : Cria corpo do e-mail e chama a função para envio
Autor       : Matheus Massarotto
Data/Hora   : 05/03/2013 16:40
*/

*---------------------------------*
Static Function EnvMaiSo(cTo,nOpc)
*---------------------------------*
Local nHora		:= VAL(SUBSTR(TIME(),1,2))
Local cHtml		:= ""
Local aTipos	:= ""
Local cTipoDes	:= ""
Local cNomRef	:= ""
Local cPosic	:= ""
Local aArea		:= GetARea()
Local cQry1		:= ""
Local cNomeClie	:= ""

cHtml+=" <style type='text/css'>.MsgBody-text, .MsgBody-text * { font: 10pt monospace; }</style>"
cHtml+=" <html xmlns='http://www.w3.org/TR/REC-html40'><head><title>Gt mail Notify</title><style><!--"

/* Font Definitions */
cHtml+=" @font-face"
cHtml+=" 	{font-family:Calibri;"
cHtml+=" 	panose-1:2 15 5 2 2 2 4 3 2 4;}"
cHtml+=" @font-face"
cHtml+=" 	{font-family:Tahoma;"
cHtml+=" 	panose-1:2 11 6 4 3 5 4 4 2 4;}"
cHtml+=" @font-face"
cHtml+=" 	{font-family:'Segoe UI';"
cHtml+=" 	panose-1:2 11 5 2 4 2 4 2 2 3;}"
cHtml+=" /* Style Definitions */"
cHtml+=" p.MsoNormal, li.MsoNormal, div.MsoNormal"
cHtml+=" 	{margin:0cm;"
cHtml+=" 	margin-bottom:.0001pt;"
cHtml+=" 	font-size:12.0pt;"
cHtml+=" 	font-family:'Times New Roman','serif';}"
cHtml+=" a:link, span.MsoHyperlink"
cHtml+=" 	{mso-style-priority:99;"
cHtml+=" 	color:blue;"
cHtml+=" 	text-decoration:underline;}"
cHtml+=" a:visited, span.MsoHyperlinkFollowed"
cHtml+=" 	{mso-style-priority:99;"
cHtml+=" 	color:purple;"
cHtml+=" 	text-decoration:underline;}"
cHtml+=" p.MsoAcetate, li.MsoAcetate, div.MsoAcetate"
cHtml+=" 	{mso-style-priority:99;"
cHtml+=" 	mso-style-link:'Texto de balco Char';"
cHtml+=" 	margin:0cm;"
cHtml+=" 	margin-bottom:.0001pt;"
cHtml+=" 	font-size:8.0pt;"
cHtml+=" 	font-family:'Tahoma','sans-serif';}"
cHtml+=" p.style1, li.style1, div.style1"
cHtml+=" 	{mso-style-name:style1;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:12.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';}"
cHtml+=" p.style2, li.style2, div.style2"
cHtml+=" 	{mso-style-name:style2;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:12.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';"
cHtml+=" 	color:red;}"
cHtml+=" p.style21, li.style21, div.style21"
cHtml+=" 	{mso-style-name:style2;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:12.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';"
cHtml+=" 	color:black;}"
cHtml+=" p.style3, li.style3, div.style3"
cHtml+=" 	{mso-style-name:style3;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:10.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';"
cHtml+=" 	color:#254061;}"
cHtml+=" p.style31, li.style3, div.style3"
cHtml+=" 	{mso-style-name:style3;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:10.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';"
cHtml+=" 	font-weight: bold;"
cHtml+=" 	color:red;}"
cHtml+=" p.style32, li.style32, div.style32"
cHtml+=" 	{mso-style-name:style32;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:10.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';"
cHtml+=" 	font-weight: bold;"
cHtml+=" 	color: #FFF;}"
cHtml+=" p.style4, li.style4, div.style4"
cHtml+=" 	{mso-style-name:style4;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:8.0pt;"
cHtml+=" 	font-family:'Segoe UI','sans-serif';"
cHtml+=" 	color:#254061;}"
cHtml+=" p.style5, li.style5, div.style5"
cHtml+=" 	{mso-style-name:style5;"
cHtml+=" 	mso-margin-top-alt:auto;"
cHtml+=" 	margin-right:0cm;"
cHtml+=" 	mso-margin-bottom-alt:auto;"
cHtml+=" 	margin-left:0cm;"
cHtml+=" 	font-size:10.0pt;"
cHtml+=" 	font-family:'Times New Roman','serif';}"
cHtml+=" span.EstiloDeEmail22"
cHtml+=" 	{mso-style-type:personal-reply;"
cHtml+=" 	font-family:'Calibri','sans-serif';"
cHtml+=" 	color:#1F497D;}"
cHtml+=" span.TextodebaloChar"
cHtml+=" 	{mso-style-name:'Texto de balco Char';"
cHtml+=" 	mso-style-priority:99;"
cHtml+=" 	mso-style-link:'Texto de balco';"
cHtml+=" 	font-family:'Tahoma','sans-serif';}"
cHtml+=" .MsoChpDefault"
cHtml+=" 	{mso-style-type:export-only;"
cHtml+=" 	font-size:10.0pt;}"
cHtml+=" @page WordSection1"
cHtml+=" 	{size:612.0pt 792.0pt;"
cHtml+=" 	margin:70.85pt 3.0cm 70.85pt 3.0cm;}"
cHtml+=" div.WordSection1"
cHtml+=" 	{page:WordSection1;}"
cHtml+=" --></style>"
cHtml+=" </head>"

cHtml+=" <body lang='PT-BR'>"

cHtml +='<div class="WordSection1">'
cHtml +='<p class="style21" style="text-align:justify">'
cHtml +=IIF(nHora<6,"Boa noite!",IIF(nHora<12,"Bom dia!",IIF(nHora<18,"Boa tarde!","Boa noite!")))+'</p>'

if empty(cTo) .OR. empty(nOpc)
	Return
endif

if nOpc==3
	cHtml +='<p style="text-align:justify" class="style21">A proposta abaixo foi recusada .</p>'
elseif nOpc==4
	cHtml +='<p style="text-align:justify" class="style21">A proposta abaixo foi aprovada.</p>'
endif

cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0" id="total">'
cHtml +='<tr>'

//Preenche Motivo de recusa

if nOpc==3
	
	//cHtml +='<div>'
	cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0">'
	cHtml +='<tr>'

	cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">Status</p></td>'
	cHtml +='<td width="467" style="width:350.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">Observação</p></td>'
	cHtml +='</tr>'
	cHtml +='<tr>'
	
	cHtml +='<td width="267" style="width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">Recusado</p></td>'
	cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">'+alltrim(Z79->Z79_OBSGT)+'</p></td>'
	cHtml +='</tr>'
	cHtml +='</table>'
	//cHtml +='</div>'

endif

cHtml +='<br/>

cHtml +='<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0">'
cHtml +='<tr>'

if !EMPTY(M->Z79_PROSPE) //Preenche o nome do prospect
	cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify">Prospect:</p></td>'
	cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify">'+Alltrim(M->Z79_PNOME)+'<span style="color:#254061;font-weight:normal"></span></p></td>'
	cNomeClie:=Alltrim(M->Z79_PNOME)
endif
if !EMPTY(M->Z79_CLIENT)//Preenche o nome do cliente
	cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Cliente:</span></p></td>'
	cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#1F497D;font-weight:normal">'+Alltrim(M->Z79_NOME)+'</span><span style="color:#254061;font-weight:normal"></span></p></td>'
	cNomeClie:=Alltrim(M->Z79_NOME)
endif

cHtml +='</tr>'
cHtml +='</table>'

//Preenche o grupo de empresa
cHtml +='<br/>'
cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0" id="total">'
cHtml +='<tr>'
cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Empresa do Grupo:</span></p></td>'
cHtml +='<td width="267" style="width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#254061;font-weight:normal">'+alltrim(SM0->M0_CODIGO)+' - '+alltrim(SM0->M0_NOME)+'</span></p></td>'
cHtml +='</tr>'
cHtml +='<tr>'
cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Tipo:</span></p></td>'


//Preenche o tipo da proposta
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(DbSeek("Z79_TPCTR"))
	aTipos:=SEPARA(SX3->X3_CBOX,";")
	
	for i:=1 to len(aTipos)
		if SUBSTR(aTipos[i],1,1)==alltrim(M->Z79_TPCTR)
			cTipoDes:=SUBSTR(alltrim(aTipos[i]),3,len(aTipos[i]))
		endif
	next
endif

cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#1F497D;font-weight:normal"> '+cTipoDes+' </span><span style="color:#254061;font-weight:normal"> </span></p></td>'

cHtml +='</tr>'
cHtml +='</table>'

//cHtml +='<p class="MsoNormal">&nbsp;</p>
cHtml +='<br/>'
cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0" id="total">'

//Preenche quem é a indicação
DbSelectArea("Z92")
Z92->(DbSetOrder(1))
if Z92->(DbSeek(xFilial("Z92")+M->Z79_REFERE))
	
	DbSelectArea("Z93")
	Z93->(DbSetOrder(1))
	if Z93->(DbSeek(xFilial("Z93")+Z92->Z92_CODEMP))
		cNomRef:=alltrim(Z93->Z93_RAZAO)+' - '+alltrim(Z92->Z92_NOME)
	endif
endif
cHtml +='<tr>'
cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Indica&ccedil;&atilde;o:</span></p></td>'
cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#1F497D;font-weight:normal">'+cNomRef+'</span><span style="color:#254061;font-weight:normal"></span></p></td>'
cHtml +='</tr>'

//Preenche o valor da proposta
cHtml +='<tr>'
cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Valor da proposta:</span></p></td>'
cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#254061;font-weight:normal">'+Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99')+'</span></p></td>'
cHtml +='</tr>'

//Preenche o posicionamento

	cQry1:= " SELECT Z70_PORCEN,Z70_MOTIVO,Z70_ID FROM "+RETSQLNAME("Z70")
	cQry1+= " WHERE Z70_PROPOS='"+alltrim(M->Z79_NUM)+"' AND Z70_REVISA='"+alltrim(M->Z79_REVISA)+"' AND D_E_L_E_T_=''"
	cQry1+= " ORDER BY Z70_ID DESC"
	cQry1:= ChangeQuery(cQry1)

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry1), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
	
	if nRecCount > 0
		
		QRYTEMP->(DbGotop())
		
		cPosic:= alltrim(QRYTEMP->Z70_PORCEN)+'% -'+alltrim(QRYTEMP->Z70_MOTIVO)
	endif

cHtml +='<tr>'
cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Posicionamento:</span></p></td>'
cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#254061;font-weight:normal">'+cPosic+'</span></p></td>'
cHtml +='</tr>'

//Preenche a emissão
cHtml +='<tr>'
cHtml +='<td width="267" style="width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32" style="text-align:justify"><span style="color:white">Emiss&atilde;o:</span></p></td>'
cHtml +='<td width="467" style="width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3" style="text-align:justify"><span style="color:#254061;font-weight:normal">'+DTOC(M->Z79_DTINC)+'</span></p></td>'
cHtml +='</tr>'
cHtml +='</table>'

//cHtml +='<p class="MsoNormal">&nbsp;</p>
cHtml +='<br/>'
cHtml +='<div>'
cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0">'
cHtml +='<tr>'
cHtml +='<td width="41" style="width:30.95pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">Item</p></td>'
cHtml +='<td width="149" style="width:111.9pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">Departamento</p></td>'
cHtml +='<td width="130" style="width:97.75pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">&Aacute;rea</p></td>'
cHtml +='<td width="310" style="width:232.35pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">Servi&ccedil;o</p></td>'
cHtml +='<td width="103" style="width:77.05pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt"><p class="style32">Volume</p></td>'
cHtml +='</tr>'

//Preenche os itens
DbSelectArea("Z78")
Z78->(DbSetORder(1))
if Z78->(DbSeek(xFilial("Z78")+M->Z79_NUM+M->Z79_REVISA))
	while Z78->(!eof()) .AND. Z78->Z78_FILIAL==M->Z79_FILIAL .AND. Z78->Z78_NUM==M->Z79_NUM .AND. Z78->Z78_REVISA==M->Z79_REVISA
			cHtml +='<tr>'
			cHtml +='<td width="41" style="width:30.95pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">'+alltrim(Z78->Z78_ITEM)+'</p></td>'
			cHtml +='<td width="149" style="width:111.9pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">'+alltrim(Z78->Z78_DESCDE)+'</p></td>'
			cHtml +='<td width="130" style="width:97.75pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">'+alltrim(Z78->Z78_DESCAR)+'</p></td>'
			cHtml +='<td width="310" style="width:232.35pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">'+alltrim(Z78->Z78_SERVIC)+'</p></td>'
			cHtml +='<td width="103" style="width:77.05pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt"><p class="style3">'+alltrim(cvaltochar(Z78->Z78_VOLUME))+'</p></td>'
			cHtml +='</tr>'
		Z78->(DbSkip())
	enddo
endif

cHtml +='</table>'
cHtml +='</div>'

cHtml +='<p class="MsoNormal">&nbsp;</p><p class="MsoNormal">&nbsp;</p></td>'
cHtml +='</tr>'
cHtml +='</table>'
cHtml +='<p class="style21" style="text-align:justify">Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.</p>'
cHtml +='</div>'

cHtml +='</body>'
cHtml +='</html>'

if nOpc==3
	//UsrRetName(id usuário)- Nome do usuário corrente ()
	cSubject:=CAPITAL(alltrim(UsrRetName (__cUserID)))+" recusou a proposta - "+cNomeClie+"- n: "+alltrim(M->Z79_NUM)
elseif nOpc==4
	//UsrRetName(id usuário)- Nome do usuário corrente ()
	cSubject:=CAPITAL(alltrim(UsrRetName (__cUserID)))+" aprovou a proposta - "+cNomeClie+"- n: "+alltrim(M->Z79_NUM)
endif

EnviaEma(cHtml,cSubject,cTo)

RESTAREA(aArea)
Return

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 05/03/2013 16:53
*/

*-------------------------------------------*
Static Function EnviaEma(cHtml,cSubject,cTo)
*-------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""
//Local cTo			:= "matheus.massarotto@br.gt.com"

Default cTo		 := ""
Default cSubject := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   


cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)


cFrom			:= '"Controle de Proposta"<'+cAccount+'>'


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //BCC "matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com";
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //BCC "matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com";
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
	conout("GTCORP53--->>> E-mail enviado com sucesso, para o aprovador da proposta")
ELSE
	conout("GTCORP53--->>> Falha no envio do e-mail, para o aprovador da proposta")
ENDIF

RETURN .T.
