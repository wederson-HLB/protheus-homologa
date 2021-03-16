#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP73
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z55, Cadastro de Propostas
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2013    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*----------------------*
User Function GTCORP73()
*----------------------*
Local cString	:= "Z55"
Local lFilter	:= .T.	//Define se deve ser filtrado a apresentação das propostas por usuário
Local cIdUser	:= __cUserID // Id do usuário logado
Local cFiltro	:= ""
Private aIndexZ55 := {}

Private aRotina	:= {}

If !cEmpAnt $ "99" .AND. !"TESTE" $ alltrim(UPPER(GetEnvServer()))

	If !TCCANOPEN("Z55"+cEmpAnt+"0")//Capa das propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z55")
		Return()
	EndIf
	If !TCCANOPEN("Z54"+cEmpAnt+"0")//Itens das propostas      Antiga Z78
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z54")
		Return()
	EndIf
	If !TCCANOPEN("Z53"+cEmpAnt+"0")//Itens das propostas      Antiga Z78
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z53")
		Return()
	EndIf
	if !TCCANOPEN("Z52"+cEmpAnt+"0")//Itens das propostas      Antiga Z78
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z52")
		Return()
	EndIf

	//if !TCCANOPEN("Z51YY0")//Controle de sequencia das novas propostas
	//	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z51")
	//	Return()
	//endif

	if !TCCANOPEN("Z50"+cEmpAnt+"0") //Posicionamento das propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z50")
		Return()
	endif
	
	if !TCCANOPEN("Z49"+cEmpAnt+"0") //Pagamentos propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z49")
		Return()
	endif

	/*if !TCCANOPEN("Z68"+cEmpAnt+"0") //Follow Up
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z68")
		Return()
	endif*/
	
	if !TCCANOPEN("Z48"+cEmpAnt+"0") //Anexos Propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z48")
		Return()
	endif
	
	if !TCCANOPEN("Z42"+cEmpAnt+"0") //Capa controle de alçada
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z42")
		Return()
	endif
	if !TCCANOPEN("Z41"+cEmpAnt+"0") //Itens controle de alçada
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z41")
		Return()
	endif
EndIf

AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP72("Z55",RECNO(),2,,"2")' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"			, 'U_GTCORP72("Z55",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Acoes"			, 'U_GT73Next("Z55",RECNO(),3)' 	, 0 , 4 } ) 
/*AADD( aRotina, { "Legenda"			, 'U_LEGZ55'  						, 0 , 7 } )
AADD( aRotina, { "Alterar"			, 'U_GTCORP72("Z55",RECNO(),4)' 	, 0 , 4 } ) 
AADD( aRotina, { "Aprovar"			, 'U_GTCORP72("Z55",RECNO(),5)' 	, 0 , 5 } )
AADD( aRotina, { "Revisar"			, 'U_GTCORP72("Z55",RECNO(),6)' 	, 0 , 6 } )
AADD( aRotina, { "Legenda"			, 'U_LEGZ55'  						, 0 , 7 } )
AADD( aRotina, { "Env. Aprovacao GT", 'U_GTCORP72("Z55",RECNO(),8)'		, 0 , 8 } )
AADD( aRotina, { "Env. P/ Cliente"	, 'U_GTCORP72("Z55",RECNO(),9)'		, 0 , 9 } )
AADD( aRotina, { "Aprovar Cliente"	, 'U_GTCORP72("Z55",RECNO(),10)'	, 0 , 10} )
AADD( aRotina, { "Recusar Cliente"	, 'U_GTCORP72("Z55",RECNO(),11)'	, 0 , 11} )
AADD( aRotina, { "Incluir de Draft"	, 'U_GTCORP72("Z55",RECNO(),12)'	, 0 , 3 } )
AADD( aRotina, { "Excluir"			, 'U_GTCORP72("Z55",RECNO(),13)'	, 0 , 5 } )
AADD( aRotina, { "Finalizar Gestor"	, 'U_GTCORP72("Z55",RECNO(),14)'	, 0 , 2 } )
AADD( aRotina, { "Imprimir"			, 'U_GTCORP46(RECNO())' 			, 0 , 13} )

Private aCores:={}
aCores := { {"Z55_STATUS == '1' .OR. Z55_STATUS == ' '" , "F6_NULL" 		},; // Em Aberto
			{"Z55_STATUS == '2'"						, "F14_CINZ"   		},;	// Revisado //BR_BRANCO
			{"Z55_STATUS == '3'"						, "F12_AMAR"  		},;	// Pendente Aprovação GT
			{"Z55_STATUS == '4'"						, "F7_VERM" 		},;	// Recusado GT
			{"Z55_STATUS == '5'"						, "F10_VERD" 		},; // Aprovado GT
			{"Z55_STATUS == '6'"						, "BR_AMARELO" 		},;	// Pendente Aprovação Cliente //BPMSREC
			{"Z55_STATUS == '7'"						, "BR_VERMELHO"		},;	// Recusado Cliente
			{"Z55_STATUS == '8'"						, "BR_LARANJA" 		},;	// Aprovado sem Assinatura Cliente
			{"Z55_STATUS == '9'"						, "BR_VERDE" 		},;	// Aprovado com Assinatura Cliente
			{"Z55_STATUS == 'A'"						, "METAS_CIMA_16"	}}	// Finalizado pelo gestor
			
			{"Z55_STATUS == 'A'"						, "F7_CINZ"   	},;	// Recusado GT/Revisado

1 =	{"F6_NULL"  	,"Em Aberto            	   			" }
2 =	{"BR_BRANCO" 	,"Revisado							" }
3 =	{"F12_AMAR" 	,"Pendente Aprovação GT    			" }
4 =	{"F7_VERM"  	,"Recusado GT						" }
5 =	{"F10_VERD"  	,"Aprovado GT						" }
6 =	{"BPMSREC"    	,"Pendente Aprovação Cliente		" }
7 =	{"BR_VERMELHO"  ,"Recusado Cliente 	  				" }
8 =	{"BR_LARANJA"  	,"Aprovado sem Assinatura Cliente	" }
9 =	{"BR_VERDE" 	,"Aprovado com Assinatura Cliente	" }

aCores := {{"Z55_STATUS == '1' .OR. Z55_STATUS == ' ' ", "BR_AMARELO" },; // PENDENTE
			{"Z55_STATUS == '2'", "BR_VERDE"   	},;	 	// APROVADO
			{"Z55_STATUS == '3'", "BR_AZUL"  },; 		// PARCIALMENTE APROVADO
			{"Z55_STATUS == '4'", "BR_VERMELHO" },; 		//	RECUSADO
			{"Z55_STATUS == '5'", "BR_BRANCO" }} 		//	REVISADO					*/

cExprFilTop:=""

if !U_GT55Filtro(.F.,"Z55",aIndexZ55,@cExprFilTop)
	Return
endif

SetKey(VK_F12,{|| U_GT55Filtro(.T.,"Z55",aIndexZ55,@cExprFilTop)} )

Z55->(DbSetOrder(1))
//MBrowse( 6,1,22,75,cString,,,,,,aCores)
//MBrowse( 6,1,22,75,cString)
            
MBrowse( 6 , 1 , 22 , 75 , cString , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , @cExprFilTop )

//Retira a função de filtro da tecla F12.
Set Key VK_F12  to

//Deleta o filtro da MBrowse.
EndFilBrw("Z55",aIndexZ55)

DbSelectArea("Z55")
 
Return

/*
Funcao      : GTCORP72()  
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z55 e Z54 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------------------------------------*
User Function GTCORP72(xParam1,xParam2,xParam3,xParam4,xParam5) 
*-------------------------------------------------------------*
Local cAliasE := xParam1    // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
							// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
							// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= {}
Local aAlterEnch	:= {}
Local aCpoEnch2		:= {}
Local aAlterEn2		:= {}
Local aCpoEnCob		:= {}
Local aAltCobEn		:= {}
Local nOpc    		:= nOpc2:= xParam3:= CTON( IIF(Valtype(xParam3)=='N',cvaltochar(xParam3),xParam3),10) //xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
								// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {012,002,161,620}//{012,002,161,422}
Local nModelo		:= 3     	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3 		  	:= .F.		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria 		:= .T.		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.		// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela 		:= "" 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .T.		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
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
Local cIniCpos     	:= "+Z54_CODIGO"    // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local cIniCposZ29  	:= "+Z29_ITEM"      // Nome dos campos do tipo caracter que utilizarao incremento automatico.            

Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 1                // Numero maximo de linhas permitidas. Valor padrao 99
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysFalse"   // Funcao executada para validar a exclusao de uma linha do aCols                   

Local nFreezeZ29  	:= 000              // Campos estaticos na GetDados.                                                               
Local nMaxZ29      	:= 99               // Numero maximo de linhas permitidas. Valor padrao 99

Local aObjects      := {}
Local aObjects2		:= {}
Local aPosObj       := {}
Local aPosObj2		:= {}
Local aObjects3		:= {}
Local aSize         := {}        

Local nUsado	:= 0
Local nUsadoZ29	:= 0
Local nUsadoZ52	:= 0

Local nUsadoZ35	:= 0

Local nUsadoZ27	:= 0                    

Local cCadastro:="Cadastro de Proposta"

Local cAno:="" //Ano que se deseja alterar

// Variáveis utilizadas na seleção de categorias
Local oChkQual,lQual,oQual,cVarQ
Local oQual1,cVarQ1
// Carrega bitmaps
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")

 // Id do usuário logado
Local cIdUser	:= __cUserID

// ------- Inicio de tratamento para DRAFT
if xParam3==12
	nOpc	:= 3
	nOpc2	:= 3
	nReg	:= 3
	
	cDraft:=SelDraft()

	//Se clicou em cancelar na tela da consulta
	if valtype(cDraft)=="L"
    	if !cDraft
    		Return
        endif
	endif
endif
//-------- 

DEFAULT xParam4		:= ""
DEFAULT xParam5		:= "" //Variável para controlar se é o visualizar com objetivo de bloquear a manipulação de anexos

// Objeto no qual a MsNewGetDados sera criada                                      
Private aHeader     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols       := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 

Private aHeaderZ29  := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aColsZ29    := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 
Private aCpoZ29		:= {}
Private aAlterServ	:= {}

// Informações da Z73 de Draft
Private aHeaZ73     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aColsZ73    := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 
Private aCpoZ73		:= {}

Private aHeaZ52     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aColsZ52    := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 
Private aCpoZ52		:= {}
Private aAlterDesp	:= {}

Private aHeaZ35     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aColsZ35    := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 
Private aCpoZ35		:= {}
Private aAlterEmp   := {}

Private aHeaZ27     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aColsZ27    := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 
Private aCpoZ27		:= {}
Private aAlterOve   := {}

Private aCpoDra		:= {}

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

Private aItensZ50	:= {}
Private aItensZ50U	:= {}
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

Private cItemZ48	:= "" //Para itens do anexo

Private lUsaVlrTot	:= .F. // Valor total
Private lUsaVlrImp	:= .F. // Valor da implantação
Private lUsaVlrDip	:= .F. // Valor de DIPJ
Private lUsaVlrAno	:= .F. // Valor de anuidade

Private oGetDdsImp,oGetDdsDip,oGetDdsAno,oGetDadEmp
Private cValG3_2_6,cValG3_3_6,cValG3_4_6

Private cAnexAtu:= ""

//Apresenta campo de overrun
Private lVeTxOve:= .F.	//Apresenta o campo de Taxa Média
Private lVeHoOve:= .F.	//Apresenta o campo de horas
Private lVeCoOve:= .T.	//Apresenta o campo de Código
Private lVeDtOve:= .T.	//Apresenta o campo de Data
Private lVeMoOve:= .T.	//Apresenta o campo de Moeda
Private lVeVLOve:= .T.	//Apresenta o campo de Valor Líquido
Private lVeImOve:= .T.	//Apresenta o campo de Imposto
Private lVeVBOve:= .T.	//Apresenta o campo de Valor Bruto
Private lVeObOve:= .T.	//Apresenta o campo de Observação

SET DATE FORMAT "dd/mm/yyyy"

//Verifica se o usuário tem permissão de incluir propostas
if nOpc<>2
	DbSelectArea("Z42")
	Z42->(DbSetOrder(1))
	if Z42->(DbSeek(xFilial("Z42")+cIdUser))
	   	if !Z42->Z42_LADMIN
		    if !Z42->Z42_LINCP
		    	alert("Você não tem permissão para esta opção!")
		    	Return
		    endif
		endif
	endif
endif

//if M->Z55_STATUS == '1' .OR. M->Z55_STATUS == ''
//	AADD( aButtons, {"SDUIMPORT", {|| ServPAcol(nOpc)}, "Servicos...","Servicos",{|| .T.}} )
//endif
//if nOpc==10 .OR. nOpc==4
if nOpc<>3
	AADD( aButtons, {"ADICIONAR_001", {|| AnexoP00(nOpc,@cItemZ48,xParam5)}, "Arquivos...","Arquivos",{|| .T.}} )
endif

/*Preenche o array com os campos que serão utilizados na Enchoice*/
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z55")
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z55"
	if X3Uso(SX3->X3_USADO) .AND. !(alltrim(SX3->X3_CAMPO) $ "Z55_FILIAL/Z55_MOTIGT"+;
		iif(nOpc<>9,"/Z55_POOLAC/Z55_POOLIN","")+;
		iif(nOpc<>5 .AND. nOpc<>2,"/Z55_MOTIVO","")+;
		iif(nOpc<>4 .AND. nOpc<>2,"/Z55_MOTALT","")+;
		iif(nOpc<>8,"/Z55_APROVA","")+;
		iif(nOpc<>10 .AND. nOpc<>11 .AND. nOpc<>2,"/Z55_OBSREC","")+;
		iif(nOpc==3,"/Z55_MOTREC/Z55_OBSGT/Z55_CODCON/Z55_NOMCON/Z55_USERRE/Z55_USERNO/Z55_INFCLI","")+;
		iif(nOpc<>15 .AND. nOpc<>2,"/Z55_DTASSI","")+;
		iif(nOpc==2,"/Z55_USERRE/Z55_USERNO","")+;
		iif(nOpc==18 .OR. nOpc==7 .OR. nOpc==6,"/Z55_USERRE/Z55_USERNO/Z55_MOTREC/Z55_CODCON/Z55_NOMCON/Z55_INFCLI",""))
		
		if nOpc<>8 .AND. alltrim(SX3->X3_CAMPO) <> "Z55_NOMEAP"
		
			//Aba cadastro
			if SX3->X3_FOLDER=='1'
			
				AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
				AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
			    
				// Campos para alimentar através de draft
				if xParam3==12 .AND. (alltrim(SX3->X3_CAMPO)<>("Z55_DRAFT"))
					AADD(aCpoDra,alltrim(SX3->X3_CAMPO))
				endif
			endif
		
		else
			//Se for visualizar, incluir ou  revisar pool não apresenta o campo Nome aprovador. Obs: tem que colocar aqui pq o Z55_NOME (que é o nome do cliente), entra na codição quando usado o $(contido)
			if (nOpc==2 .OR. nOpc==3 .OR. nOpc==18 .OR. nOpc==6) .AND. UPPER(alltrim(SX3->X3_CAMPO))=="Z55_NOMEAP"
			
			else
				//Aba cadastro
				if SX3->X3_FOLDER=='1'
				
					AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
					AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
					
				endif
			endif    
		
		endif
		
			//Aba Dados de Cobrança
			if SX3->X3_FOLDER=='2'
			
				AADD(aCpoEnCob,alltrim(SX3->X3_CAMPO))
				AADD(aAltCobEn,alltrim(SX3->X3_CAMPO))
				
			endif
		
	endif
	
	//Verificação da usabilidade dos campos para apresentação da aba pagamentos: 

	if alltrim(SX3->X3_CAMPO)=="Z55_VLRLIS" .AND. X3Uso(SX3->X3_USADO)//Valor da proposta
		lUsaVlrTot:=.T.
	elseif alltrim(SX3->X3_CAMPO)=="Z55_VLRIMP" .AND. X3Uso(SX3->X3_USADO) //Valor implantação
		lUsaVlrImp:=.T.
	elseif alltrim(SX3->X3_CAMPO)=="Z55_VLDIPJ" .AND. X3Uso(SX3->X3_USADO) //Valor DIPJ
		lUsaVlrDip:=.T.
	elseif alltrim(SX3->X3_CAMPO)=="Z55_VLRANO" .AND. X3Uso(SX3->X3_USADO) //Valor Anuidade
		lUsaVlrAno:=.T.
	endif
		
	SX3->(DbSkip())
Enddo


AADD(aCpoEnch,"NOUSER")
AADD(aCpoEnCob,"NOUSER")	

AADD(aCpoDra,"NOUSER")

aZ74Ench	:= {}
aZ74EnCob	:= {}

//Tratamento para DRAFT
if xParam3==12
	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z74")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z74"
		if X3Uso(SX3->X3_USADO) .AND. !(alltrim(SX3->X3_CAMPO) $ "Z74_FILIAL/Z74_MOTIGT"+iif(nOpc<>5 .AND. nOpc<>2,"/Z74_MOTIVO","")+iif(nOpc<>4 .AND. nOpc<>2,"/Z74_MOTALT","")+iif(nOpc<>8,"/Z74_APROVA","")+iif(nOpc<>10 .AND. nOpc<>11,"/Z74_OBSREC","")+iif(nOpc==3,"/Z74_MOTREC/Z74_OBSGT",""))
			if nOpc<>8 .AND. alltrim(SX3->X3_CAMPO) <> "Z74_NOMEAP"
				//Aba cadastro
				if SX3->X3_FOLDER=='1'
					AADD(aZ74Ench,alltrim(SX3->X3_CAMPO))
				endif
			else
				//Aba cadastro
				if SX3->X3_FOLDER=='1'
					AADD(aZ74Ench,alltrim(SX3->X3_CAMPO))
				endif
			endif

			//Aba Dados de Cobrança
			if SX3->X3_FOLDER=='2'
				AADD(aZ74EnCob,alltrim(SX3->X3_CAMPO))
			endif
		endif
		
		SX3->(DbSkip())
	Enddo
	AADD(aZ74Ench,"NOUSER")
	AADD(aZ74EnCob,"NOUSER")	
endif

/*Preenche o array com os campos que serão utilizados na Enchoice*/
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z68")
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z68"
	if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z68_FILIAL")
		AADD(aCpoEnch2,{alltrim(SX3->X3_CAMPO)})
		AADD(aAlterEn2,alltrim(SX3->X3_CAMPO))
	endif
		
	SX3->(DbSkip())
Enddo

AADD(aCpoEnch2,"NOUSER")

/*Preenche o array com os campos que serão utilizados no aHeader*/
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z54")
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z54"
	if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z54_FILIAL/Z54_RECORR/Z54_RECQTD/Z54_ANOINI") 
		AADD(aCpoGDa,alltrim(SX3->X3_CAMPO))
		AADD(aAlter,alltrim(SX3->X3_CAMPO))		
	endif
		
	SX3->(DbSkip())
Enddo


/*Preenche o array com os campos que serão utilizados no aHeaderZ29 - Descrição dos serviços*/
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z29")
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z29"
	if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z29_FILIAL") 
		AADD(aCpoZ29,alltrim(SX3->X3_CAMPO))
		AADD(aAlterServ,alltrim(SX3->X3_CAMPO))		
	endif
		
	SX3->(DbSkip())
Enddo


/*Preenche o array com os campos que serão utilizados na Enchoice*/
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z52")
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z52"
	if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z52_FILIAL")
		AADD(aCpoZ52,alltrim(SX3->X3_CAMPO))
		AADD(aAlterDesp,alltrim(SX3->X3_CAMPO))
	endif
		
	SX3->(DbSkip())
Enddo
	
/*Preenche o array com os campos que serão utilizados no getdados do OVERRUN*/
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z27")
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z27"
	if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z27_FILIAL")
		AADD(aCpoZ27,alltrim(SX3->X3_CAMPO))
	endif
		
	SX3->(DbSkip())
Enddo

/*Preenche o array com os campos que serão utilizados na empresas do prospect*/
aCpoZ35 := {"Z35_ITEM","Z35_PERCEN","Z35_NOME","Z35_CGC","Z35_CODCLI","Z35_LOJCLI"}

    //Se for inclusão de proposta por informações da draft
if xParam3==12
	/*Preenche o array com os campos que serão utilizados no aHeader*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z73")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z73"
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z73_FILIAL") 
			AADD(aCpoZ73,alltrim(SX3->X3_CAMPO))
		endif

		SX3->(DbSkip())
	Enddo	
endif 

Do Case
	Case xParam3 == 2
		VISUAL := .T.     
		aAlterDesp	:={}
	Case xParam3 == 3    //Inclusão ad Proposta
		INCLUI := .T. 
		//aAlter := {} 
		//aAlterEnch	:= {}
		aAlterEmp		:= {"Z35_PERCEN"}
	Case xParam3 == 4 
		ALTERA := .T.
		aAlter := {}	//Resumo dos serviços
		aAlterServ := {} //Descrição dos serviços
		//aAlterEnch	:= {"Z55_VALOR","Z55_DESCON","Z55_VLRLIS","Z55_DESPER","Z55_DESCON","Z55_TPVLR","Z55_VLRLIS","Z55_MOTALT"}
		aAlterEnch	:= {"Z55_MOTALT"}
		aAlterDesp	:= {}
	Case xParam3 == 5
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z55_MOTIVO"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
	Case xParam3 == 6  //Revisão da Proposta
		//DELETA := .T.
		ALTERA := .T.
		//aAlterEnch	:= {"Z55_RESPON","Z55_CLIENT","Z55_LOJA","Z55_PROSPE","Z55_PLOJA","Z55_REFERE","Z55_MOEDA","Z55_TIPOCT","Z55_VLREXT","Z55_VLDIPJ","Z55_VLRANO","Z55_VLRIMP","Z55_ADVOGA","Z55_VALOR","Z55_DESCON","Z55_VLRLIS","Z55_DESPER","Z55_DESCON","Z55_VLRLIS","Z55_MOTALT","Z55_MOTIVO","Z55_DREEMB","Z55_IDIOMA","Z55_VLDPFI","Z55_TIMEUS","Z55_SOCIO","Z55_GERENT","Z55_GLOBAL","Z55_CLIGLO","Z55_VLRCAL","Z55_VLRLIQ","Z55_SURCHA","Z55_VLRLIS","Z55_IMPOST","Z55_OBSERV"}
		aAlterEnch	:= {"Z55_RESPON","Z55_REFERE","Z55_MOEDA","Z55_TIPOCT","Z55_VLREXT","Z55_VLDIPJ","Z55_VLRANO","Z55_VLRIMP","Z55_ADVOGA","Z55_VALOR","Z55_DESCON","Z55_VLRLIS","Z55_DESPER","Z55_DESCON","Z55_VLRLIS","Z55_MOTALT","Z55_MOTIVO","Z55_DREEMB","Z55_IDIOMA","Z55_VLDPFI","Z55_TIMEUS","Z55_SOCIO","Z55_GERENT","Z55_VLRCAL","Z55_VLRLIQ","Z55_SURCHA","Z55_VLRLIS","Z55_IMPOST","Z55_OBSERV","Z55_PROJNO","Z55_ANOAUD"}
		aAlterEmp	:= {"Z35_PERCEN"}
		nOpc2:=4
	Case xParam3 == 7
		ALTERA := .T.
		aAlterEnch	:= {"Z55_OBSGT"}
		aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 8
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z55_APROVA","Z55_NOMEAP"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
	Case xParam3 == 9
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z55_POOLAC","Z55_POOLIN"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
	Case xParam3 == 10
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z55_OBSREC"}
		//aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
	Case xParam3 == 11
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z55_OBSREC","Z55_MOTREC","Z55_CODCON","Z55_NOMCON"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
	Case xParam3 == 13
		VISUAL := .T.     
		nOpc2:=2
	Case xParam3 == 14 //Finaliza a Proposta
		ALTERA := .T.
		aAlterEnch	:= {}
		//aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
		aAlter      := {"Z54_DTAINI","Z54_DTAFIM","Z54_RECQTD","Z54_ANOINI"} //Resumo dos serviços
		aAlterServ	:= {"Z29_DTAINI","Z29_DTAFIM"} //Descrição dos serviços
		aAlterEmp   := {"Z35_PERCEN"}
	Case xParam3 == 15 //Informar assinatura
		ALTERA := .T.
		aAlterEnch	:= {"Z55_DTASSI"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
		aAlter      := {} //Resumo dos serviços
		aAlterServ	:= {} //Descrição dos serviços
		aAlterEmp   := {}
	Case xParam3 == 16 //Alterar socio/gerente
		ALTERA := .T.
		aAlterEnch	:= {"Z55_GERENT","Z55_SOCIO"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
		aAlter      := {} //Resumo dos serviços
		aAlterServ	:= {} //Descrição dos serviços
		aAlterEmp   := {}
	Case xParam3 == 17 //Alterar socio/gerente
		ALTERA := .T.
		aAlterEnch	:= {"Z55_TIPOFT"}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
		aAlter      := {} //Resumo dos serviços
		aAlterServ	:= {} //Descrição dos serviços
		aAlterEmp   := {}
	Case xParam3 == 18 //Revisar POOL
		ALTERA := .T.
		aAlterEnch	:= {}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
		aAlter      := {} //Resumo dos serviços
		aAlterServ	:= {} //Descrição dos serviços
		aAlterEmp   := {}
	Case xParam3 == 19 //Informar Overrun
		ALTERA := .T.
		aAlterEnch	:= {}
		aAltCobEn	:= {}
		aAlterDesp	:= {}
		nOpc2:=4
		aAlter      := {} //Resumo dos serviços
		aAlterServ	:= {} //Descrição dos serviços
		aAlterEmp   := {}
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

	AADD(aHeadVlr,{ TRIM("Parcela")		,"M_PARC"	,"@999"					,03,0,"ALLWAYSFALSE()"	,"€€€€€€€€€€€€€€ ","C","","V","","","","V" } )
    nUseVlr:=nUseVlr+1
	AADD(aHeadVlr,{ TRIM("Vencimento")	,"M_VENC"	,""						,08,0,"ALLWAYSTRUE()"	,"€€€€€€€€€€€€€€ ","D","","" } )
    nUseVlr:=nUseVlr+1
	AADD(aHeadVlr,{ TRIM("Valor")		,"M_VALOR"	,"@E 99,999,999,999.99"	,17,2,"ALLWAYSTRUE()"	,"€€€€€€€€€€€€€€ ","N","","" } )
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

	//------>>>> Cria a Folder de cima
	//aTFolder := { 'Cadastro','Pagamentos','Histórico Posicionamento','Despesas','Dados Cobrança','Follow Up'}
	aTFolder := { 'Cadastro','Pagamentos','Histórico Posicionamento','Despesas','Dados Cobrança','Empresas','Overrun'}
	oTFolder := TFolder():New( 2,2,aTFolder,,oDlg,,,,.T.,,623,300 )
	//------>>>> Fim do criar folder
	
	//------>>>> Cria a Folder de baixo
	aTFolder2 := {'Descrição dos Serviços','Resumo dos Serviços','Projetos'}
	oTFolder2 := TFolder():New( aPosObj[2,1],aPosObj[2,2],aTFolder2,,oTFolder:aDialogs[1],,,,.T.,,aPosObj[2,4]-8,aPosObj[2,3]/3 )
	
	//Como forma de atualizar os valores da capa de serviços e resumo de serviços, no When do folder de descrição de serviços, chamo as funções para atualizar 
	//a capa da proposta e o valor de pagamento
	oTFolder2:aDialogs[1]:BWhen:={||GatServi(nOpc),Cargapag(@cValG3_1_1)}

	//------>>>> Fim a Folder de baixo

	//------>>>> Cria a Folder de da aba de overrun
	aTFolder3 := {'Totais'}
	oTFolder3 := TFolder():New( aPosObj[2,1],aPosObj[2,2],aTFolder3,,oTFolder:aDialogs[7],,,,.T.,,aPosObj[2,4]-8,aPosObj[2,3]/3 )
	//------>>>> Fim a Folder de baixo
    
    //Desabilito a aba de Overrun
	if nOpc<>2 .AND. nOpc<>19
		nItemPrin	:= 7
		oTFolder:aEnable( nItemPrin , .F. )
	endif
	
	//Se for Overrun, apresento a pasta de overrun
	if nOpc==19
		oTFolder:ShowPage(7)
	endif
	    
	//Desabilito a aba 3 da parte de serviços (Projetos)
	nItem	:= 3
	oTFolder2:aEnable( nItem , .F. )
	
	//Crio uma execução quando clica-se em uma aba, neste caso executo minha função somente quando clicar na aba 6
	oTFolder:bSetOption := ({ |x| iif(x==2,Cargapag(@cValG3_1_1),)})  //Carrega campos da aba "Pagamentos"         


	//Crio uma execução quando clica-se em uma aba, neste caso executo minha função somente quando clicar na aba 1
	oTFolder2:bSetOption := ({ |x| iif(x==2,GatServi(nOpc),)})  //Carrega campos da aba "Pagamentos"             


	// <-> FOLDER 1 
	//Carrega as variáveris da tabela Z55
	RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)
    
    //Tratamento para Draft, preenchendo a capa da proposta com as informações do draft
	if xParam3==12
		RegToMemory("Z74",.F.,.T.)
		
		For d:=1 to len(aCpoDra)-1
			if alltrim(aCpoDra[d])<>"Z55_NUM"
				&(Z55->(aCpoDra[d])):=&(Z74->(aZ74Ench[d]))
			endif
		Next
		
		M->Z55_DRAFT:= Z74->Z74_NUM

		For d:=1 to len(aCpoEnCob)-1
			&(Z55->(aCpoEnCob[d])):=&(Z74->(aZ74EnCob[d]))
		Next

    endif
    
    cRev	:=M->Z55_REVISA
	/*
	if nOpc==6 .OR. nOpc==4
		//Tratamento para não deixar revisar/alterar um contrato revisado
		if Z55->Z55_STATUS $ '2' //'2/A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Revisado'")
			Return()
		elseif Z55->Z55_STATUS $ 'A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Finalizado pelo Gestor'")
			Return()
		endif
		
		//Tratamento para não deixar alterar um contrato recusado GT
		if nOpc==4 .AND. Z55->Z55_STATUS $ '4'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Recusado GT'")
			Return()		
		endif       

		if nOpc==6 //Revisar
			M->Z55_REVISA:=SOMA1(M->Z55_REVISA)
		endif
	endif
    */
    
    if nOpc==6 //Revisar
		M->Z55_REVISA:=SOMA1(M->Z55_REVISA)
	endif
	
	If nOpc == 3 //Incluir
		IniUsuario()  //Carrega o Sócio ou o Gerente
	EndIf

	if nOpc == 6 //Revisar
		AtuDesc()  //Atualiza os campos de descrição de acordo com os cadastros básicos
	endif
		
	/*
	//Tratamento para não deixar alterar/enviar para aprovação GT propostas recusadas ou aprovadas
	//if nOpc==4 .OR. nOpc==5 .OR. nOpc==8
	if nOpc==5 .OR. nOpc==8
		if Z55->Z55_STATUS $ '5/8/9'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Aprovado'")
			Return()
		elseif Z55->Z55_STATUS $ '4/7'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Recusado'")
			Return()
		//Tratamento para não deixar revisar um contrato revisado
		elseif Z55->Z55_STATUS $ '2' //'2/A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Revisado'")
			Return()
		elseif Z55->Z55_STATUS $ 'A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Finalizado pelo Gestor'")
			Return()
		endif
	endif
	*/
	/*
	//Tratamento para não deixar Revisar/Alterar/Enviar p aprovação GT propostas aprovadas	
	//if nOpc==6 .OR. nOpc==4 .OR. nOpc==8
	if nOpc==6 .OR. nOpc==8
		if Z55->Z55_STATUS $ '5/8/9'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Aprovado'")
			Return()
		elseif Z55->Z55_STATUS $ '6'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Pendente Aprovação Cliente'")
			Return()
		elseif Z55->Z55_STATUS $ 'A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Finalizado pelo Gestor'")
			Return()
		endif
	endif
	
	//Tratamento para não deixar manipular proposta que está em aprovação da GT
	if nOpc<>3 .AND. nOpc<>2 //diferente de incluir e visualizar
		if Z55->Z55_STATUS $ '3' //Pendente Aprovação GT
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Pendente Aprovação GT'")
			Return()
		endif
	endif

	//Tratamento para não deixar Env. P/ Cliente propostas que não estão aprovadas GT
	if nOpc==9
		if !(Z55->Z55_STATUS $ '5')
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Aprovado GT'")
			Return()
		endif
	endif

	//Tratamento para não deixar Env. P/ Cliente propostas que não estão aprovadas GT
	if nOpc==10 .OR. nOpc==11
		if !(Z55->Z55_STATUS $ '6')
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Pendente Aprovação Cliente'")
			Return()
		endif
	endif
	//Tratamento para não deixar exluir proposta que não esteja em aberto

	if nOpc==13
		if ! (empty(Z55->Z55_STATUS) .OR. (Z55->Z55_STATUS $ '1'))
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Em aberto'")
			Return()
		elseif (empty(Z55->Z55_STATUS) .OR. (Z55->Z55_STATUS $ '1')) .AND. alltrim(M->Z55_REVISA)<>"000"
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta derivada de revisão")
			Return()
		endif
	endif
	
	//Tratamento para não finalizar pelo gestor se não estiver aprovado pelo cliente
	if nOpc==14
		if !(Z55->Z55_STATUS $ '8/9')
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Aprovado pelo cliente'")
			Return()
		endif
	endif
	*/
	                                                                   //aPos
	Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPosObjEnch,;
			aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oTFolder:aDialogs[1],lF3,;    
			lMemoria,lColumn,caTela,lNoFolder,lProperty)

	//tratamento para o aprovador ser o mesmo que o sócio automaticamente
	if nOpc == 8
		DbSelectArea("Z42")
		Z42->(DbSetOrder(2))
		if Z42->(DbSeek(xFilial("Z42")+Z55->Z55_SOCIO))
			M->Z55_APROVA:=Z42->Z42_IDUSER
			M->Z55_NOMEAP:=Z42->Z42_NOMEFU
		
		endif	
	endif
	
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

		if nOpc<>3 //.AND. nOpc<>6  // Se não for incluir ou revisar, preencho as informações da barrinha
			aItensZ50U	:= CarregaZ50(nOpc,1,Z55->Z55_NUM,M->Z55_REVISA)
			if !empty(aItensZ50U)
				cTexto		:= aItensZ50U[1][3]
				cMemo		:= aItensZ50U[1][5]
				oSlider:SetValue(val(aItensZ50U[1][3]))
				oSlider:Refresh()
			endif
		endif
		
		// Exibe o texto com o valor da barrinha
		@ aPosObjGroup[1]+45,aPosObjGroup[2]+( (aPosObjGroup[4]-aPosObjGroup[2])/2 ) Say oTexto Var cTexto+" %" Size 229,041 FONT oFont COLOR CLR_BLACK PIXEL OF oTFolder:aDialogs[1]

		oSay:= tSay():New(aPosObjGroup[1]+65,aPosObjGroup[2]+10,{||'Descrição'},oTFolder:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		                                                                                                                          
		oMemo:= tMultiget():New(aPosObjGroup[1]+75,aPosObjGroup[2]+10,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oTFolder:aDialogs[1],120,aGprCoords[4]/2,,,,,,.T.)
		
		//Se for visualizar desabilita alteração na barra de porcentagem e descrição
		if nOpc<>3 .AND. nOpc<>4 .AND. nOpc<>6
			oSlider:disable()
			oMemo:disable()
		endif
		/*
		if nOpc==4 .AND. (M->Z55_STATUS $ '3/5/6/7/8/9') //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
			oSlider:disable()
			oMemo:disable()			
		endif
		*/
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


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o aHeader										 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoZ29)                                                                                                     
		If SX3->(DbSeek(aCpoZ29[nX]))                                                                                                 
			nUsadoZ29++
		AADD(aHeaderZ29,{ 	ALLTRIM(X3TITULO()), ;
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

    //Se for inclusão de proposta por informações da draft
	if xParam3==12
		DbSelectArea("SX3")                                                                                                             
		SX3->(DbSetOrder(2)) // Campo                                                                                                   
		For nX := 1 to Len(aCpoZ73)                                                                                                     
			If SX3->(DbSeek(aCpoZ73[nX]))                                                                                                 
			AADD(aHeaZ73,{ 	ALLTRIM(X3TITULO()), ;
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
	endif	
	
	//Despesa
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoZ52)                                                                                                     
		If SX3->(DbSeek(aCpoZ52[nX]))                                                                                                 
			nUsadoZ52++
		AADD(aHeaZ52,{ 	ALLTRIM(X3TITULO()), ;
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


	//Empresas do prospect
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoZ35)                                                                                                     
		If SX3->(DbSeek(aCpoZ35[nX]))                                                                                                 
			nUsadoZ35++
		AADD(aHeaZ35,{ 	ALLTRIM(X3TITULO()), ;
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

	//Overrun
	DbSelectArea("SX3")                                                                                                             
	SX3->(DbSetOrder(2)) // Campo                                                                                                   
	For nX := 1 to Len(aCpoZ27)                                                                                                     
		If SX3->(DbSeek(aCpoZ27[nX]))                                                                                                 
			nUsadoZ27++
			AADD(aHeaZ27,{ 	ALLTRIM(X3TITULO()), ;
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

	
	//Carrega as variáveis no aCols de acordo com a opção selecionada       
	If nOpc == 3 .AND. xParam3<>12
		//Acols do resumo dos serviços
		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if Alltrim(aHeader[nI,2]) == "Z54_ITEM"
				aCols[len(aCols)][nI] := "01"
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.
		
		//Acols da descrição dos serviços
		AADD(aColsZ29,Array(nUsadoZ29+1))
		For nI := 1 To nUsadoZ29
			if Alltrim(aHeaderZ29[nI,2]) == "Z29_ITEM"
				aColsZ29[len(aColsZ29)][nI] := "01"
			elseif Alltrim(aHeaderZ29[nI,2]) == "Z29_SOCIO"
				aColsZ29[len(aColsZ29)][nI] :=M->Z55_SOCIO
			elseif Alltrim(aHeaderZ29[nI,2]) == "Z29_NOMESO"
				aColsZ29[len(aColsZ29)][nI] :=M->Z55_NOMESO
			else
				aColsZ29[len(aColsZ29)][nI] := CriaVar(aHeaderZ29[nI][2])
			endif
		Next
		aColsZ29[len(aColsZ29)][nUsadoZ29+1] := .F.
		
	Else
	    if xParam3==12 //se for inclusão através de informações de draft

			cFilNum:= Z74->Z74_FILIAL+Z74->Z74_NUM+Z74->Z74_REVISA
			
			aCols:={}
			dbSelectArea("Z73")
			dbSetOrder(1)
			dbSeek(cFilNum)
			While !eof() .AND. Z73_NUM==M->Z74_NUM .AND. Z73_REVISA==cRev .AND. Z73_FILIAL==xFilial("Z74")
				AADD(aCols,Array(nUsado+1))
					For nX:=1 to nUsado
						aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeaZ73[nX,2]))
					Next
				aCols[Len(aCols),nUsado+1]:=.F.
				Z73->(dbSkip())
			End
			
			if nOpc<>6
				nMax:=Len(aCols) //Tratamento para não permitir inserir mais linhas no alterar
			endif

		else

			DbSelectArea("Z55")
			Z55->(DbGoTo(nReg))
			cFilNum:= Z55->Z55_FILIAL+Z55->Z55_NUM+Z55->Z55_REVISA

			//Acols do Resumo dos Serviços			
			aCols:={}
			dbSelectArea("Z54")
			Z54->(dbSetOrder(2))
			Z54->(dbSeek(cFilNum))
			While !eof() .AND. Z54_NUMPRO==M->Z55_NUM .AND. Z54_REVISA==cRev .AND. Z54_FILIAL==xFilial("Z54")
				AADD(aCols,Array(nUsado+1))
					For nX:=1 to nUsado
						aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
					Next
				aCols[Len(aCols),nUsado+1]:=.F.
				Z54->(dbSkip())
			End
			
			//Acols da Descrição dos serviços
			aColsZ29:={}
			dbSelectArea("Z29")
			Z29->(dbSetOrder(2))
			Z29->(dbSeek(cFilNum))
			While !eof() .AND. Z29_NUMPRO==M->Z55_NUM .AND. Z29_REVISA==cRev .AND. Z29_FILIAL==xFilial("Z29")
				AADD(aColsZ29,Array(nUsadoZ29+1))
					For nX:=1 to nUsadoZ29
						if aHeaderZ29[nX,10]<>"V" //Se não for campo virtual
							aColsZ29[Len(aColsZ29),nX]:=FieldGet(FieldPos(aHeaderZ29[nX,2]))
						else
							aColsZ29[Len(aColsZ29),nX]:=CriaVar(aHeaderZ29[nX,2])
						endif
					Next
				aColsZ29[Len(aColsZ29),nUsadoZ29+1]:=.F.
				Z29->(dbSkip())
			End
			
			if nOpc<>6
				nMax:=Len(aCols) //Tratamento para não permitir inserir mais linhas no revisar
				nMaxZ29:=Len(aColsZ29)
			endif		
			

		endif		

	EndIf                            
	
	if nOpc==5
		aColsAux:=aCols
		nPosSta:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_STATUS"})
		if nPosSta<>0
			for i:=1 to len(aColsAux)
				AADD(aColsAux[i],"")
				AINS(aColsAux[i], 1) 
				AFILL( aColsAux[i] , iif(aColsAux[i][nPosSta+1]=="2",.T.,.F.), 1, 1)
			next
		endif
			
		//@ nSuperior,nEsquerda LISTBOX oQual VAR cVarQ Fields HEADER "","Item","Departamento","Descrição","Area","Descrição","Servico","Descrição","Volume" SIZE;
		//420,90 ON DBLCLICK (aColsAux:=Troca(oQual:nAt,aColsAux),oQual:Refresh()) NoScroll OF oTFolder:aDialogs[1] PIXEL
		@ aLbxCoords[1],aLbxCoords[2] LISTBOX oQual VAR cVarQ Fields HEADER "","Item","Departamento","Descrição","Area","Descrição","Servico","Descrição","Volume" SIZE;
		aLbxCoords[3],aLbxCoords[4] ON DBLCLICK (aColsAux:=Troca(oQual:nAt,aColsAux),oQual:Refresh()) NoScroll OF oTFolder:aDialogs[1] PIXEL		
		
		//320,90
		oQual:SetArray(aColsAux)
		
		oQual:bLine := { || {If(aColsAux[oQual:nAt,1],oOk,oNo),aColsAux[oQual:nAt,2],aColsAux[oQual:nAt,3],aColsAux[oQual:nAt,4],aColsAux[oQual:nAt,5],aColsAux[oQual:nAt,6],aColsAux[oQual:nAt,7],aColsAux[oQual:nAt,8],aColsAux[oQual:nAt,9]}}
	
	else
	
		//oGetDados:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		//                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)
        
		/*
		oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)
        */
        
        //GetDados do Resumo dos serviços
		oGetDados:= MsNewGetDados():New(2,2,(aPosObj[2,3]/3)-15,aPosObj[2,4]-10,nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder2:aDialogs[2],aHeader,aCols)

	    oGetDados :ForceRefresh()              
	   	if nOpc==3 .OR. nOpc==6
	   		cDelOkZ29:="IIF(oGetDadosZ29:nAt==1,AllwaysFalse(),AllwaysTrue())"
        else
        	cDelOkZ29:="AllwaysFalse()"
        endif
        
        //cTudoOk		:= "(alert('ronaldo'),.T.)"
        
        //GetDados da Descrição dos serviços
		oGetDadosZ29:= MsNewGetDados():New(2,2,(aPosObj[2,3]/3)-15,aPosObj[2,4]-10,nOpc1,cLinOk,cTudoOk,cIniCposZ29,;                               
		                             aAlterServ,nFreezeZ29,nMaxZ29,cFieldOk,cSuperDel,cDelOkZ29,oTFolder2:aDialogs[1],aHeaderZ29,aColsZ29)
        
	    oGetDadosZ29 :ForceRefresh()        

		oGetDados:Disable()
	    
	    if nOpc<>3 .AND. nOpc<>4 .AND. nOpc<>6 .AND. nOpc<>14
		    oGetDadosZ29:Disable()
	    endif
	    
	    //Para permitir somente manipular a barra de status da proposta 
	    /*if nOpc<>4 .AND. (M->Z55_STATUS $ '3/5/6/7/8/9')   //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
			oGetDados:Disable()
	    endif
	    */
	endif
	
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	
	// <-> FIM FOLDER 1


	// <-> FOLDER 1.2

		nOpc3        	:= 2
		cLinOkPrj      	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
		cTudoOkPrj     	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
		cICposPrj     	:= ""       	// Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
		nFreePrj      	:= 000              // Campos estaticos na GetDados.                                                               
		nMaxZ52        	:= 99              	// Numero maximo de linhas permitidas. Valor padrao 99                           
		cFiOkPrj     	:= ""    			// Funcao executada na validacao do campo                                           
		cSuDelPrj     	:= "AllwaysFalse"  	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
		cDelOkPrj      	:= "AllwaysFalse"   


		aHeaPrj		:= {}
		aColsPrj	:= {}
		nUsePrj		:= 0
		aAlterPrj	:= {}

		AADD(aHeaPrj,{ TRIM("Projeto"),;
							 "M_PROJ",;
							 "",;
							 20,;
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
		    nUsePrj:=nUsePrj+1
		AADD(aHeaPrj,{ TRIM("Data Inicial"),;
							 "M_DTINI",;
							 "",;
							 8,;
		 					 0,;
		 					 "ALLWAYSFALSE()",;
		 					 "€€€€€€€€€€€€€€ ",;
		 					 "D",;
		 					 "",;
		 					 "V",;
		 					 "",;
		 					 "",;
		 					 "",;
		 					 "V" } )
		    nUsePrj:=nUsePrj+1
		AADD(aHeaPrj,{ TRIM("Data Conclusao"),;
							 "M_DTCON",;
							 "",;
							 8,;
		 					 0,;
		 					 "ALLWAYSFALSE()",;
		 					 "€€€€€€€€€€€€€€ ",;
		 					 "D",;
		 					 "",;
		 					 "V",;
		 					 "",;
		 					 "",;
		 					 "",;
		 					 "V" } )
		    nUsePrj:=nUsePrj+1		    
		
		aColsPrj	:= CarregaPrj(aColsPrj,Z55->Z55_NUM)

		oGetDadPrj	:= MsNewGetDados():New(2,2,(aPosObj[2,3]/3)-15,aPosObj[2,4]-10,nOpc3,cLinOkPrj,cTudoOkPrj,cICposPrj,;                               
		                             aAlterPrj,nFreePrj,nMaxZ52,cFiOkPrj,cSuDelPrj,cDelOkPrj,oTFolder2:aDialogs[3],aHeaPrj,aColsPrj)

		if !empty(aColsPrj)
			//Habilito a aba 3 da parte de serviços (Projetos)
			nItem	:= 3
			oTFolder2:aEnable( nItem , .T. )
		endif
	// <-> FIM  FOLDER 1.2

	// <-> FOLDER 3
        //if nOpc <> 6
			aItensZ50:=CarregaZ50(nOpc,2,Z55->Z55_NUM,M->Z55_REVISA)
		//endif
		//@ nSuperior,nEsquerda LISTBOX oQual VAR cVarQ Fields HEADER "","Item","Departamento","Descrição","Area","Descrição","Servico","Descrição","Volume" SIZE;
		//420,90 ON DBLCLICK (aColsAux:=Troca(oQual:nAt,aColsAux),oQual:Refresh()) NoScroll OF oTFolder:aDialogs[1] PIXEL
		@ aLbxCooFo2[1],aLbxCooFo2[2] LISTBOX oQual VAR cVarQ Fields HEADER "Data","Hora","Porcentagem","Usuário","Descrição" SIZE;
		aLbxCooFo2[3],aLbxCooFo2[4] OF oTFolder:aDialogs[3] PIXEL
		
		if !empty(aItensZ50)
			oQual:SetArray(aItensZ50)
			
			oQual:bLine := { || {aItensZ50[oQual:nAt,1],aItensZ50[oQual:nAt,2],aItensZ50[oQual:nAt,3],aItensZ50[oQual:nAt,4],aItensZ50[oQual:nAt,5]}}
	    endif
	// <-> FIM FOLDER 3
	
	// <-> FOLDER 2
		if lUsaVlrTot
			oGroup3_1	:= tGroup():New(aPosObjFo1[1],aPosObjFo1[2],aPosObjFo1[3]-2,aPosObjFo1[4]-2,'Valor Proposta',oTFolder:aDialogs[2],,,.T.)
		endif
		if lUsaVlrImp		
			oGroup3_2	:= tGroup():New(aPosObjFo2[1],aPosObjFo2[2]+2,aPosObjFo2[3]-2,aPosObjFo2[4],'Valor Implantação',oTFolder:aDialogs[2],,,.T.)
        endif
        if lUsaVlrDip
			oGroup3_3	:= tGroup():New(aPosObjFo3[1],aPosObjFo3[2],aPosObjFo3[3],aPosObjFo3[4]-2,'Valor DIPJ',oTFolder:aDialogs[2],,,.T.)
		endif
		if lUsaVlrAno
			oGroup3_4	:= tGroup():New(aPosObjFo4[1],aPosObjFo4[2]+2,aPosObjFo4[3],aPosObjFo4[4],'Valor Anuidade',oTFolder:aDialogs[2],,,.T.)
	    endif
	    
	    
		if lUsaVlrTot
		//----------Primeiro quadro - Valor da proposta		
		                           //Z55_VALOR
			cValG3_1_1:= Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99')
			cValG3_1_2:= ""
			cValG3_1_4:= SPACE(3)
			cValG3_1_6:= CTOD("//")//cValG3_1_6:= SPACE(2)
            
			if xParam3==12 //Se for inclusão de através de informações de draft
				cNum:=M->Z74_NUM
				cRev:=M->Z74_REVISA			
			else
				cNum:=M->Z55_NUM
				cRev:=M->Z55_REVISA
            endif

			//Carregando itens da tabela Z49 --pagamentos
			aAcolVlrAx:=CarregaZ49(nOpc,cNum,cRev,"PROPOSTA",xParam3)

			nPosVencVl	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrVl	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolVlrAx) .and. (xParam3==12 .OR. nOpc<>3)
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
				cValG3_1_1	:= Transform(M->Z55_VLRTOT+(iif(aAcolVlrAx[1][6]=="S",M->Z55_VLDIPJ,0))+(iif(aAcolVlrAx[1][7]=="S",M->Z55_VLRANO,0)),'@E 99,999,999,999.99') //Adiciona o valor de DIPJ ou Anual caso seja sim nas opções
				//cValG3_1_1	:= Transform(M->Z55_VLRLIS+(iif(aAcolVlrAx[1][6]=="S",M->Z55_VLDIPJ,0))+(iif(aAcolVlrAx[1][7]=="S",M->Z55_VLRANO,0)),'@E 99,999,999,999.99') //Adiciona o valor de DIPJ ou Anual caso seja sim nas opções
			                            //Z55_VALOR
			endif
			
			
			oSayG3_1_1		:= tSay():New(aPosObjFo1[1]+15,aPosObjFo1[2]+10, {||'Valor da Proposta: ' +alltrim(cValG3_1_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_1_2		:= tSay():New(aPosObjFo1[1]+15,aPosObjFo1[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_1_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_1_3		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                               //Z55_VALOR
			//@aPosObjFo1[1]+25,aPosObjFo1[2]+40	MSGET oSayG3_1_4 VAR cValG3_1_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO1(oGetDdsVlr,cValG3_1_4,Transform(M->Z55_VLRLIS,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,,,cValG3_1_6))
			@aPosObjFo1[1]+25,aPosObjFo1[2]+40	MSGET oSayG3_1_4 VAR cValG3_1_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO1(oGetDdsVlr,cValG3_1_4,Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,,,cValG3_1_6,nOpc))
		
			//oSayG3_1_5		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+110, {||'Dia Vencto: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			//@aPosObjFo1[1]+25,aPosObjFo1[2]+140	MSGET oSayG3_1_6 VAR cValG3_1_6 PICTURE "99" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cValG3_1_6,oGetDdsVlr,aHeadVlr))
			oSayG3_1_5		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo1[1]+25,aPosObjFo1[2]+140	MSGET oSayG3_1_6 VAR cValG3_1_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,cValG3_1_6,nOpc))
/*			
			oSayG3_1_7		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+180, {||'Incluir DIPJ: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                                 //Z55_VALOR
			oCombo_1_7		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+210,{|u|if(PCount()>0,cCombo_1_7:=u,cCombo_1_7)},aCombo_1_7,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z55_VLRLIS,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr)},,,,.T.,,,,,,,,,'cCombo_1_7')
	
			oSayG3_1_8		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+250, {||'Incluir Anuid: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                               //Z55_VALOR
			oCombo_1_8		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+285,{|u|if(PCount()>0,cCombo_1_8:=u,cCombo_1_8)},aCombo_1_8,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z55_VLRLIS,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr)},,,,.T.,,,,,,,,,'cCombo_1_8')
*/
			if lUsaVlrDip
				oSayG3_1_7		:= tSay():New(aPosObjFo1[1]+14,aPosObjFo1[2]+200, {||'Incluir DIPJ: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                                 //Z55_VALOR
				oCombo_1_7		:= tComboBox():New(aPosObjFo1[1]+13,aPosObjFo1[2]+235,{|u|if(PCount()>0,cCombo_1_7:=u,cCombo_1_7)},aCombo_1_7,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,cValG3_1_6)},,,,.T.,,,,,,,,,'cCombo_1_7')
	        endif
	        if lUsaVlrAno
				oSayG3_1_8		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+200, {||'Incluir Anuid: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                               //Z55_VALOR
				oCombo_1_8		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+235,{|u|if(PCount()>0,cCombo_1_8:=u,cCombo_1_8)},aCombo_1_8,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,cValG3_1_6)},,,,.T.,,,,,,,,,'cCombo_1_8')
			endif
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsVlr:= MsNewGetDados():New(aPosObjFo1[1]+47,aPosObjFo1[2]+10,aPosObjFo1[3]-10,aPosObjFo1[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterVlr,000,val(cValG3_1_4),"U_I_FG73O1","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			if lUsaVlrDip
				oCombo_1_7:Disable()
			endif
			if lUsaVlrAno
				oCombo_1_8:Disable()
			endif
		//----------Fim Primeiro quadro - Valor da proposta
		endif
		
		if lUsaVlrImp	                                           
		//----------Segundo quadro - Valor da implantação
		
			cValG3_2_1:= Transform(M->Z55_VLRIMP,'@E 99,999,999,999.99')
			cValG3_2_2:= ""
			cValG3_2_4:= SPACE(3)
			cValG3_2_6:= CTOD("//")

			//Carregando itens da tabela Z49 --pagamentos
			aAcolImpAx:=CarregaZ49(nOpc,cNum,cRev,"IMPLANTACAO",xParam3)

			nPosVencIm	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrIm	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolImpAx) .and. (xParam3==12 .OR. nOpc<>3)
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
			@aPosObjFo2[1]+25,aPosObjFo2[2]+40	MSGET oSayG3_2_4 VAR cValG3_2_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO2(oGetDdsImp,cValG3_2_4,Transform(M->Z55_VLRIMP,'@E 99,999,999,999.99'),@oSayG3_2_1,@cValG3_2_1,@cValG3_2_2,oSayG3_2_2,cvaltochar(DAY(cValG3_2_6)),oGetDdsImp,aHeadImp,cValG3_2_6))
	
			oSayG3_2_5		:= tSay():New(aPosObjFo2[1]+27,aPosObjFo2[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo2[1]+25,aPosObjFo2[2]+140	MSGET oSayG3_2_6 VAR cValG3_2_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_2_6)),oGetDdsImp,aHeadImp,cValG3_2_6))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsImp:= MsNewGetDados():New(aPosObjFo2[1]+47,aPosObjFo2[2]+10,aPosObjFo2[3]-10,aPosObjFo2[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterImp,000,val(cValG3_2_4),"U_I_FG73O2","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadImp,aAcolImp)
			
			
		//----------Fim Segundo quadro - Valor da implantação
		endif

		if lUsaVlrDip	                                                 
		//----------Terceiro quadro - Valor de DIPJ
		
			cValG3_3_1:= Transform(M->Z55_VLDIPJ,'@E 99,999,999,999.99')
			cValG3_3_2:= ""
			cValG3_3_4:= SPACE(3)
			cValG3_3_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z49 --pagamentos
			aAcolDipAx:=CarregaZ49(nOpc,cNum,cRev,"DIPJ",xParam3)

			nPosVencDi	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrDi	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolDipAx) .and. (xParam3==12 .OR. nOpc<>3)
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
			@aPosObjFo3[1]+25,aPosObjFo3[2]+40	MSGET oSayG3_3_4 VAR cValG3_3_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO3(oGetDdsDip,cValG3_3_4,Transform(M->Z55_VLDIPJ,'@E 99,999,999,999.99'),@oSayG3_3_1,@cValG3_3_1,@cValG3_3_2,oSayG3_3_2,cvaltochar(DAY(cValG3_3_6)),oGetDdsDip,aHeadDip,cValG3_3_6))
	
			oSayG3_3_5		:= tSay():New(aPosObjFo3[1]+27,aPosObjFo3[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo3[1]+25,aPosObjFo3[2]+140	MSGET oSayG3_3_6 VAR cValG3_3_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_3_6)),oGetDdsDip,aHeadDip,cValG3_3_6))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsDip:= MsNewGetDados():New(aPosObjFo3[1]+47,aPosObjFo3[2]+10,aPosObjFo3[3]-10,aPosObjFo3[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterDip,000,val(cValG3_3_4),"U_I_FG73O3","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadDip,aAcolDip)
			
			
		//----------Fim Terceiro quadro - Valor de DIPJ
        endif        
        
        if lUsaVlrAno
		//----------Quarto quadro - Valor Anual
		
			cValG3_4_1:= Transform(M->Z55_VLRANO,'@E 99,999,999,999.99')
			cValG3_4_2:= ""
			cValG3_4_4:= SPACE(3)
			cValG3_4_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z49 --pagamentos
			aAcolAnoAx:=CarregaZ49(nOpc,cNum,cRev,"ANUAL",xParam3)

			nPosVencAn	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VENC"})
            nPosVlrAn	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VALOR"})
            nTotVlParc	:= 0

			if !empty(aAcolAnoAx) .and. (xParam3==12 .OR. nOpc<>3)
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
							
			oSayG3_4_1		:= tSay():New(aPosObjFo4[1]+15,aPosObjFo4[2]+10, {||'Valor Anuidade: ' +alltrim(cValG3_4_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_4_2		:= tSay():New(aPosObjFo4[1]+15,aPosObjFo4[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_4_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_4_3		:= tSay():New(aPosObjFo4[1]+27,aPosObjFo4[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo4[1]+25,aPosObjFo4[2]+40	MSGET oSayG3_4_4 VAR cValG3_4_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO4(oGetDdsAno,cValG3_4_4,Transform(M->Z55_VLRANO,'@E 99,999,999,999.99'),@oSayG3_4_1,@cValG3_4_1,@cValG3_4_2,oSayG3_4_2,cvaltochar(DAY(cValG3_4_6)),oGetDdsAno,aHeadAno,cValG3_4_6))
	
			oSayG3_4_5		:= tSay():New(aPosObjFo4[1]+27,aPosObjFo4[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo4[1]+25,aPosObjFo4[2]+140	MSGET oSayG3_4_6 VAR cValG3_4_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_4_6)),oGetDdsAno,aHeadAno,cValG3_4_6))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsAno:= MsNewGetDados():New(aPosObjFo4[1]+47,aPosObjFo4[2]+10,aPosObjFo4[3]-10,aPosObjFo4[4]-10,3,"AllwaysTrue","AllwaysTrue","",;
	                             aAlterAno,000,val(cValG3_4_4),"U_I_FG73O4","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadAno,aAcolAno)
			
			
		//----------Fim Quarto quadro - Valor Anual
		endif	
			
	// <-> FIM FOLDER 2

	// <-> FOLDER 4

		nOpc3        	:= GD_INSERT+GD_DELETE+GD_UPDATE
		cLinOkDesp      := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
		cTudoOkDesp     := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
		cICposDesp     	:= "+Z52_ITEM"       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
		nFreeDesp      	:= 000              // Campos estaticos na GetDados.                                                               
		nMaxZ52        	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
		cFiOkDesp     	:= "U_VLD_GT73()"    // Funcao executada na validacao do campo                                           
		cSuDelDesp     	:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    

		if nOpc == 6 .OR. nOpc == 3
			cDelOkDesp      := "AllwaysTrue"   
		else
			cDelOkDesp      := "AllwaysFalse"   
		endif
		
		aColsZ52	:= CarregaZ52(nOpc,xParam3,aColsZ52,@nMaxZ52,nUsadoZ52,nReg,aHeaZ52,cRev)

		oGetDadDes	:= MsNewGetDados():New(2,2,(aPosObj[2,3])-15,aPosObj[2,4]-2,nOpc3,cLinOkDesp,cTudoOkDesp,cICposDesp,;                               
		                             aAlterDesp,nFreeDesp,nMaxZ52,cFiOkDesp,cSuDelDesp,cDelOkDesp,oTFolder:aDialogs[4],aHeaZ52,aColsZ52)

	// <-> FIM  FOLDER 4


	// <-> FOLDER 5

		//Enchoice(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnchC,aPosObjEnch,;
		//		aAlterEnC,nModelo,/*nColMeadminns*/,/*cMensagem*/,/*cTudoOk*/,oTFolder:aDialogs[5],lF3,;    
		//		lMemoria,lColumn,caTela,lNoFolder,lProperty)
		
	
		oEnch := MsmGet():New(cAliasE,nReg,nOpc2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnCob,aPosObjEnch,;
			aAltCobEn,/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oTFolder:aDialogs[5],/*lF3*/,lMemoria,/*lColumn*/,;
          /*caTela*/,/*lNoFolder*/,.T./*lProperty*/,/*aField*/,/*aFolder*/,/*lCreate*/,;
          /*lNoMDIStretch*/,/*cTela*/)
		
		oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT
		
	// <-> FIM  FOLDER 5


	// <-> FOLDER 6

//		RegToMemory("Z68",If(nOpc == 3,.T.,.F.), .T.)
	
		//Montagem do browse para manipulação dos follow ups
//		FormBrwTable(nOpc)

		nOpc3        	:=  GD_UPDATE
		cLinOkEmp      := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
		cTudoOkEmp     := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
		cICposEmp     	:= ""       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
		nFreeEmp      	:= 0              // Campos estaticos na GetDados.                                                               
		nMaxZ35        	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
		cFiOkEmp     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
		cSuDelEmp     	:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
		cDelOkEmp      	:= "AllwaysFalse"   
		
		oGetDadEmp	:= MsNewGetDados():New(2,2,(aPosObj[2,3])-15,aPosObj[2,4]-2,nOpc3,cLinOkEmp,cTudoOkEmp,cICposEmp,;                               
		                             aAlterEmp,nFreeEmp,nMaxZ35,cFiOkEmp,cSuDelEmp,cDelOkEmp,oTFolder:aDialogs[6],aHeaZ35,aColsZ35)
       
		//Carrega as Empresas do Grupo.
		U_CarregaZ35(nOpc)		

	// <-> FIM  FOLDER 6

	// <-> FOLDER 7
        if !lVeHoOve
       		nColTotOve:=(aPosObj[2,4]/2)
       		nColBruOve:=(aPosObj[2,4]/2)
       		nColLiqOve:=2
        else
        	nColTotOve:=(aPosObj[2,4]/3)
			nColLiqOve:=(aPosObj[2,4]/3)
			nColBruOve:=(aPosObj[2,4]/3)+(aPosObj[2,4]/3)
        endif
        
		//Bara de botões da aba de overrun
		oTBarFol7 := TBar():New( oTFolder:aDialogs[7],45,32,.T.,,,,.F. )
		oTBtnBmp1 := TBtnBmp() :NewBar('BMPINCLUIR',,,,'Incluir',{|| CadOverRun(nOpc,xParam5,nUsadoZ27,3)},.F.,oTBarFol7,.T.,{||.T.},,.F.,,,1,,,,,.T. )
		oTBtnBmp1:cTooltip:="Incluir"  

		oTBtnBmp2 := TBtnBmp() :NewBar('ALTERA',,,,'Alterar',{|| CadOverRun(nOpc,xParam5,nUsadoZ27,4)},.F.,oTBarFol7,.T.,{||.T.},,.F.,,,2,,,,,.T. )
		oTBtnBmp2:cTooltip:="Alterar"  
		
		oTBtnBmp3 := TBtnBmp() :NewBar('BMPVISUAL',,,,'Visualizar',{|| CadOverRun(nOpc,xParam5,nUsadoZ27,5)},.F.,oTBarFol7,.T.,{||.T.},,.F.,,,3,,,,,.T. )
		oTBtnBmp3:cTooltip:="Visualizar"  
        
		if nOpc<>19 //Overrun
        	oTBarFol7:Hide()
        	oTBtnBmp1:Hide()
        	oTBtnBmp2:Hide()        	
		endif
		
		nOpc3        	:=  2
		cLinOkOve      := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
		cTudoOkOve     := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
		cICposOve     	:= ""       // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
		nFreeOve      	:= 0              // Campos estaticos na GetDados.                                                               
		nMaxZ27        	:= 99              // Numero maximo de linhas permitidas. Valor padrao 99                           
		cFiOkOve     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
		cSuDelOve     	:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
		cDelOkOve      	:= "AllwaysFalse"   

		aColsZ27	:= CarregaZ27(nOpc,xParam3,aColsZ27,@nMaxZ27,nUsadoZ27,nReg,aHeaZ27,cRev)

		oGetDadOve	:= MsNewGetDados():New(20,2,(aPosObj[1,3])-15,aPosObj[2,4]-2,nOpc3,cLinOkOve,cTudoOkOve,cICposOve,;                               
		                             aAlterOve,nFreeOve,nMaxZ27,cFiOkOve,cSuDelOve,cDelOkOve,oTFolder:aDialogs[7],aHeaZ27,aColsZ27)
       
		oGetDadOve:Disable()
		
        //Horas------------------------------------------------------------------------------------------
        nVZ27_H_O	:= 0
		if lVeHoOve

			oGrpZ27_H	:= tGroup():New(2,2,aPosObj[2,3]/4,(aPosObj[2,4]/3)-10,'Horas',oTFolder3:aDialogs[1],,,.T.)		
	
			oSayZ27_H_O	:= tSay():New(20,35, {||'Overrun: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@18,65	MSGET oSayGZ27_H_O VAR nVZ27_H_O PICTURE "@E 9999999.9" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
			oSayGZ27_H_O:Disable()
	
			nVZ27_H_P	:= oGetDados:Acols[len(oGetDados:Acols)][Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_HORAPR"})]
			oSayZ27_H_P	:= tSay():New(35,35, {||'Proposta: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@33,65	MSGET oSayGZ27_H_P VAR nVZ27_H_P PICTURE "@E 9999999.9" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
			oSayGZ27_H_P:Disable()
	        
			nVZ27_H_T := oGetDados:Acols[len(oGetDados:Acols)][Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_HORAPR"})]
			oSayZ27_H_T	:= tSay():New(50,35, {||'Total: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@48,65	MSGET oSayGZ27_H_T VAR nVZ27_H_T PICTURE "@E 9999999.9" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
			oSayGZ27_H_T:Disable()

		endif
								 
		//Valor Liquido------------------------------------------------------------------------------------------
		oGrpZ27_VL	 := tGroup():New(2,nColLiqOve,aPosObj[2,3]/4,( nColLiqOve+nColTotOve )-10,'Valor Liquido',oTFolder3:aDialogs[1],,,.T.)		

		nVZ27_VL_O := 0
		oSayZ27_VL_O := tSay():New(20,nColLiqOve+35, {||'Overrun: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@18,nColLiqOve+65	MSGET oSayGZ27_VL_O VAR nVZ27_VL_O PICTURE "@E 99,999,999,999.99" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
		oSayGZ27_VL_O:Disable()

		nVZ27_VL_P := Z55->Z55_VLRLIQ
		oSayZ27_VL_P := tSay():New(35,nColLiqOve+35, {||'Proposta: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@33,nColLiqOve+65	MSGET oSayGZ27_VL_P VAR nVZ27_VL_P PICTURE "@E 99,999,999,999.99" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
		oSayGZ27_VL_P:Disable()
        
		nVZ27_VL_T := Z55->Z55_VLRLIQ
		oSayZ27_VL_T := tSay():New(50,nColLiqOve+35, {||'Total: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@48,nColLiqOve+65	MSGET oSayGZ27_VL_T VAR nVZ27_VL_T PICTURE "@E 99,999,999,999.99" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
		oSayGZ27_VL_T:Disable()
		        
		//Valor Bruto------------------------------------------------------------------------------------------
		oGrpZ27_VB:= tGroup():New(2,( nColBruOve ),aPosObj[2,3]/4,(aPosObj[2,4])-15,'Valor Bruto',oTFolder3:aDialogs[1],,,.T.)				

		nVZ27_VB_O := 0
		oSayZ27_VB_O := tSay():New(20,( nColBruOve )+35, {||'Overrun: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@18,( nColBruOve )+65	MSGET oSayGZ27_VB_O VAR nVZ27_VB_O PICTURE "@E 99,999,999,999.99" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
		oSayGZ27_VB_O:Disable()

		nVZ27_VB_P := Z55->Z55_VLRTOT
		oSayZ27_VB_P := tSay():New(35,( nColBruOve )+35, {||'Proposta: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@33,( nColBruOve )+65	MSGET oSayGZ27_VB_P VAR nVZ27_VB_P PICTURE "@E 99,999,999,999.99" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
		oSayGZ27_VB_P:Disable()
        
		nVZ27_VB_T := Z55->Z55_VLRTOT
		oSayZ27_VB_T := tSay():New(50,( nColBruOve )+35, {||'Total: ' },oTFolder3:aDialogs[1],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@48,( nColBruOve )+65	MSGET oSayGZ27_VB_T VAR nVZ27_VB_T PICTURE "@E 99,999,999,999.99" SIZE 75,8 OF oTFolder3:aDialogs[1] PIXEL
		oSayGZ27_VB_T:Disable()
        
		//Cria o temporário de pagamentos para overrun
		AuxZ49Ove()
		
		//Atualiza valores da aba totais da tela de overrun
		AtuValOve()

        //Verifica como estão os anexos
		CtAnexZ27("INICIO")

		
	// <-> FIM  FOLDER 7
	
	//Se não for incluir nem revisar nem enviar para aprov. GT
	if nOpc<>3 .AND. nOpc<>6 //.AND. nOpc<>8
		oSayG3_1_1:Disable()
		oSayG3_1_2:Disable()
		oSayG3_1_3:Disable()
		oSayG3_1_4:Disable()
		oSayG3_1_5:Disable()
		oSayG3_1_6:Disable()
		if lUsaVlrDip
			oSayG3_1_7:Disable()
			oCombo_1_7:Disable()
		endif    
		if lUsaVlrAno
			oSayG3_1_8:Disable()
			oCombo_1_8:Disable()
		endif
		oGetDdsVlr:Disable()
		
		if lUsaVlrImp
			oSayG3_2_1:Disable()
			oSayG3_2_2:Disable()
			oSayG3_2_3:Disable()
			oSayG3_2_4:Disable()
			oSayG3_2_5:Disable()
			oSayG3_2_6:Disable()
			oGetDdsImp:Disable()
		endif
		
		if lUsaVlrDip		
			oSayG3_3_1:Disable()
			oSayG3_3_2:Disable()
			oSayG3_3_3:Disable()
			oSayG3_3_4:Disable()
			oSayG3_3_5:Disable()
			oSayG3_3_6:Disable()
			oGetDdsDip:Disable()
		endif
			
		if lUsaVlrAno
			oSayG3_4_1:Disable()
			oSayG3_4_2:Disable()
			oSayG3_4_3:Disable()
			oSayG3_4_4:Disable()
			oSayG3_4_5:Disable()
			oSayG3_4_6:Disable()
			oGetDdsAno:Disable()
		endif
	endif


	//Para permitir somente manipular a barra de status da proposta 
	if nOpc==4 .AND. M->Z55_STATUS $ '3/5/6/7/8/9' //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
		oSayG3_1_1:Disable()
		oSayG3_1_2:Disable()
		oSayG3_1_3:Disable()
		oSayG3_1_4:Disable()
		oSayG3_1_5:Disable()
		oSayG3_1_6:Disable()
		if lUsaVlrDip
			oSayG3_1_7:Disable()
			oCombo_1_7:Disable()
		endif
		if lUsaVlrAno
			oSayG3_1_8:Disable()
			oCombo_1_8:Disable()
		endif
		oGetDdsVlr:Disable()

		if lUsaVlrImp
			oSayG3_2_1:Disable()
			oSayG3_2_2:Disable()
			oSayG3_2_3:Disable()
			oSayG3_2_4:Disable()
			oSayG3_2_5:Disable()
			oSayG3_2_6:Disable()
			oGetDdsImp:Disable()
		endif

		if lUsaVlrDip		
			oSayG3_3_1:Disable()
			oSayG3_3_2:Disable()
			oSayG3_3_3:Disable()
			oSayG3_3_4:Disable()
			oSayG3_3_5:Disable()
			oSayG3_3_6:Disable()
			oGetDdsDip:Disable()
		endif
		
		if lUsaVlrAno
			oSayG3_4_1:Disable()
			oSayG3_4_2:Disable()
			oSayG3_4_3:Disable()
			oSayG3_4_4:Disable()
			oSayG3_4_5:Disable()
			oSayG3_4_6:Disable()
			oGetDdsAno:Disable()
		endif
	endif                                                             
  
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
											{|| iif(Grava(aHeader,IIF(nOpc==5,aColsAux,oGetDados:aCols),aCpoEnch,aCpoEnCob,nOpc,;
															aAlterEnch,aAltCobEn,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,;
															aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cValG3_1_6,cValG3_1_4,;
															cValG3_2_6,cValG3_3_6,cValG3_4_6,oGetDadDes,aHeaZ52,aCpoZ52,;
															oGetDadDes:Acols,xParam4,cValG3_1_1,cValG3_1_2,;
															oGetDadosZ29:aCols);
													,oDlg:End();
													,)},;
											{||IIF(nOpc==19,CtAnexZ27("CANCELA"),),oDlg:End()};
											,,aButtons);
								,iif(nOpc==10,iif(MsgYesNo("Deseja adicionar proposta assinada?"),;
														AnexoP00(nOpc,@cItemZ48,xParam5),);
								,) )CENTERED //Tratamento para verificar se o usuário quer anexar a proposta assinada, quando está aprovando cliente

Return(.T.)

/*
Funcao      : Grava()  
Parametros  : Header,aCols,cAno,nOpc,aAlterEnch
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/Aprovação
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Static Function Grava(aHeader,aCols,aCpoEnch,aCpoEnCob,nOpc,aAlterEnch,aAltCobEn,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cValG3_1_6,cValG3_1_4,cValG3_2_6,cValG3_3_6,cValG3_4_6,oGetDadDes,aHeaZ52,aCpoZ52,aColsZ52,xParam4,cValG3_1_1,cValG3_1_2,aColsZ29)
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Local nPosVal	:= 0
Local cNum		:= ""
Local cRev		:= ""
Local nPosGetDad:= 0
Local cTipoZ48	:= ""
Local cTo		:= ""
Local nAnexos	:= 0
Local nI        := 0


if nOpc==2 //Visualizar

cNum:=Z55->Z55_NUM
    
    //Tratamento para ver é a opção enviar final para cliente para validar se tem anexos
	if !empty(xParam4)
 		DbSelectArea("Z47")
 		Z47->(DbSetOrder(1))
 		if DbSeek(xFilial("Z47")+xParam4)
    		if UPPER("FINAL CLIENTE") $ UPPER(Z47->Z47_ACAO)

			    DbSelectArea("Z48")
			    Z48->(DbGoTop())
			    DbSetOrder(1)
			    DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA)
			    While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==M->Z55_NUM .AND. Z48->Z48_REVISA==M->Z55_REVISA
					nAnexos++
			    	Z48->(DbSkip())
			    Enddo    			
    			
    			if nAnexos<2
					Alert("O arquivo de draft e a proposta final devem estar anexados na proposta!")
			   		Return .F.    			
    			endif
    		
    		elseif UPPER("DRAFT CLIENTE") $ UPPER(Z47->Z47_ACAO)

			    DbSelectArea("Z48")
			    Z48->(DbGoTop())
			    DbSetOrder(1)
			    DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA)
			    While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==M->Z55_NUM .AND. Z48->Z48_REVISA==M->Z55_REVISA
					nAnexos++
			    	Z48->(DbSkip())
			    Enddo    	
			    
			    if nAnexos<1
					Alert("O arquivo do draft deve estar vinculado(anexado)!")
			   		Return .F.    			
    			endif
    		
    		elseif 	UPPER("CONFLITO") $ UPPER(Z47->Z47_ACAO)

				//Tratamento para enviar e-mail
				cHtml:=' <html style="padding: 0px; margin: 0px;">
				cHtml+=' <head>
				cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
				cHtml+=' </head>
				cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000"><div><span>
				//cHtml+=' <div align="left">
				cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 60.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
				cHtml+=' <tbody>
				cHtml+=' <tr>
				cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
				cHtml+=' <p>&nbsp;<img dfsrc="cid:DWT232" src="http://www.grantthornton.com.br/images/logo.gif"></p></td>
				cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
				cHtml+=' <p>&nbsp;
				cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
				cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt;'
				cHtml+='	mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin;'
				cHtml+='	mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191;'
				cHtml+='	mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+';'
				cHtml+='	FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin;'
				cHtml+='	 mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR;'
				cHtml+='	 mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | Propostas</font></strong></span></span></p></td></tr></tbody>
				//cHtml+=' </table></div><br>
				
				cHtml+=' <tr>
				cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">			
				cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo está pendente de avaliação de risco e está aguardando a sua manipulação: </span></span>
				cHtml+=' </td></tr>
				cHtml+=' </div>
				
				cHtml+=' <tr><td colspan="2">
				
				cHtml+=' <p><span></span>&nbsp;</p>
				cHtml+=' <p><span>&nbsp;</span></p>
				cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
				cHtml+=' <colgroup>
				cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
				cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
				cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
				cHtml+=' </colgroup>
				
				cHtml+=' <tbody>
				cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
				cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
				cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Número</font></strong></p>
				cHtml+=' </td>
			
				cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
				cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">'+IIF(!empty(M->Z55_NOME),"Cliente","Prospect")+'</font></strong></p></td>
			   
				cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
				cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Empresa</font></strong></p>
				cHtml+=' </td>
				cHtml+=' </tr>
					
				cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
				cHtml+=' <font size="2" face="Calibri">'+AllTrim(M->Z55_NUM)+'</font>'
				cHtml+=' </td>
			
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <font size="2" face="Calibri">'+IIF(!empty(M->Z55_NOME),alltrim(M->Z55_NOME),alltrim(M->Z55_PNOME))+'</font> '
				cHtml+=' </td>
			
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
				cHtml+=' <font size="2" face="Calibri">'+alltrim(FWFilialName())+'</font>'
				cHtml+=' </td>
				
				cHtml+=' </tr>
					
				cHtml+=' </tbody></table><span></span>

				cHtml+=' </td></tr>
				cHtml+=' <tr><td>				
				cHtml+=' <p><br><br><br>&nbsp;</p>
				
				cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
				cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>

				cHtml+=' </td></tr>
				cHtml+=' </table>
				
				cHtml+=' </body>
				cHtml+=' </html>
				
				cTo:= SUPERGETMV("MV_P_00007",.F.,"")
				
				cSubject := "Proposta para verificacao de conflito"
				
				if !empty(cTo)
					EnviaEma(cHtml,cSubject,cTo)	
				endif
    		
    		elseif UPPER("POOL") $ UPPER(Z47->Z47_ACAO)
    			//Envia e-mail informando o envio para revisão do pool, para as pessoas que estiverem no parâmetro MV_P_00018
				EmailInc(cNum,"INPOOL")
    		endif
    	endif
	endif


	//Atualizo somente o status
	GravLege(xParam4,nOpc)

elseif nOpc==3 //Incluir

	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif

    /*Valida se o valor é diferente de 0(zero)*/
	
	/*		
    if empty(M->Z55_VALOR) .OR. empty(M->Z55_VLRLIS)
		Alert("Campo valor deve ser preenchido!")
   		Return .F.
    endif
    */
   

    /*
    if empty(M->Z55_CLIENT) .AND. empty(M->Z55_PROSPE)
		Alert("Deve ser informado um cliente ou um prospect!")
   		Return .F.
    endif
    */

    /*Valida se o campo cliente ou prospect estão preenchidos*/    
    If AllTrim(M->Z55_TIPCLI) == "1" //Novo Cliente
		If Empty(M->Z55_PROSPE)
			Alert("O prospect não foi informado!")		
			Return .F.
		EndIf    

    ElseIf AllTrim(M->Z55_TIPCLI) == "2"//Cliente Reccorente
		If Empty(M->Z55_CLIENT)
			Alert("O cliente não foi informado!")		
			Return .F.
		EndIf    
	Else
		Alert("O tipo do cliente não foi informado!")
		Return .F.
	EndIf                             
    
    /*Valida se o campo global esta preenchido com 1=SIM, então o campo desc global deve ser preenchido*/
    if M->Z55_GLOBAL=="1"

		If Empty(M->Z55_GLOCOB)
			Alert("Deve ser informado o tipo de cobrança de cliente referenciado!")
	   		Return .F.
		EndIf

		if empty(M->Z55_CLIGLO)
			Alert("Deve ser informada a referencia!")
	   		Return .F.
   		endif
    endif
    
    if M->Z55_TIPOFT=="F" //Se o tipo de faturamento for fixo, valido se os dados do pagamento estão preenchidos
    
	    //Valida se o valor da proposta é o mesmo das parcelas
	    if alltrim(cValG3_1_1)<>alltrim(cValG3_1_2) .or. Empty(cValG3_1_1) .or. Empty(cValG3_1_2) .or. ROUND(M->Z55_VLRTOT,2)<>val(StrTran(StrTran(cValG3_1_1,".",""),",","."))
			Alert("Verifique os valores na aba pagamentos, o valor da proposta deve ser o mesmo do valor das parcelas!")
	   		Return .F.    
	    endif
	    
	    //Valida se as parcelas estão preenchidas corretamente
	    For nI:=1 To Len(oGetDdsVlr:aCols)
			
			//Verifica se o vencimento está preenchido
			If Empty(oGetDdsVlr:aCols[nI][2])
				Alert("Verifique a data de vencimento da parcela "+ AllTrim(Str(nI)) + ".")
	   			Return .F.  			
			EndIf
			
			//Verifica se o valor da parcela está preenchido
			If oGetDdsVlr:aCols[nI][3] <= 0
				Alert("Verifique o valor da parcela "+ AllTrim(Str(nI)) + ".")
	   			Return .F.  			
			EndIf
		Next
    
    endif
    
    /*Valida se o campo responsável deve ser preenchido*/
	
	/*cQry:=" SELECT * FROM "+RETSQLNAME("Z41")+" Z41"
	cQry+=" JOIN "+RETSQLNAME("Z42")+" Z42 ON Z42_IDUSER=Z41_IDUSER AND Z42_FILIAL=Z41_FILIAL "
	cQry+=" WHERE Z41.D_E_L_E_T_='' AND Z42.D_E_L_E_T_='' AND Z41_IDDEPE='' "
	cQry+=" AND Z42_LRESPO='T'
    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0
	    if empty(M->Z55_RESPON)
			Alert("Deve ser informado o responsável!")
	   		Return .F.
	    endif
    endif
    */
	/*Validação do preenchimento da GetDados*/
	nPosGetDiv:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODDIV"})
	nPosGetNat:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODNAT"})
	nPosGetRec:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_RECORR"})
	nPosGetRQT:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_RECQTD"})
	nPosGetRAn:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_ANOINI"})
	nPosGetHor:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_HORAPR"})
	nPosGetLiq:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_PRECOL"})
	nPosGetBru:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CUSTOT"})
	
	//nPosGetVol:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_VOLUME"})
    
    if empty(aCols)
		Alert("Verifique se existe serviço preenchido!")
    	Return .F.
	endif
	
 	for h:=1 to len(aCols)
        
 		//Verifica se a linha não está deletada
 		If !(aCols[h][Len(aCols[h])])

	    	if nPosGetDiv>0
    			if empty(aCols[h][nPosGetDiv])
	    			Alert("Existe linha com Divisão não preenchida!")
	    			Return .F.
					Exit
				endif
			endif         
		
    		if nPosGetNat>0
    			if empty(aCols[h][nPosGetNat])
	    			Alert("Existe linha com Natureza não preenchida!")
		    		Return .F.
					Exit
				endif
			endif
             
            //Validação das horas previstas
        	If nPosGetHor > 0
 				If aCols[h][nPosGetHor] <= 0
 					Alert("Existe linha com Horas Previstas não preenchida!")
 					Return .F.
 				EndIf       	
        	EndIf
            
            //Validação do preço liquido
        	If nPosGetLiq > 0
 				If aCols[h][nPosGetLiq] <= 0
 					Alert("Existe linha com Preço Liquido não preenchido!")
 					Return .F.
 				EndIf       	
        	EndIf
        
            //Validação do valor bruto
        	If nPosGetBru > 0
 				If aCols[h][nPosGetBru] <= 0
 					Alert("Existe linha com Preço Bruto não preenchido!")
 					Return .F.
 				EndIf       	
        	EndIf
        
    		if nPosGetRec>0
    			if (aCols[h][nPosGetRec])=="S"
	    		
	    			if nPosGetRQT>0 .AND. nPosGetRAn>0
	    				if empty(aCols[h][nPosGetRQT])
			    			Alert("Informe a recorrência na grade de serviços!")
				    		Return .F.
							Exit
	    				elseif empty(aCols[h][nPosGetRAn])
				    		Alert("Informe o inicio do exercício na grade de serviços!")
			    			Return .F.
							Exit	    			
		    			endif
		    		endif

				endif

			endif
		EndIf	
		/*
    	if nPosGetVol>0
    		//Desenvolvendo aqui §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
			aCbox:={}
			
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek("Z55_TPCTR"))
			
				cCbox := AllTrim(SX3->X3_CBOX)
				nAt := At(";",cCbox)
				While nAt > 0
					cAux  := Left(cCbox,nAt-1)
													
					aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 
													
					cCbox := Substr(cCbox,nAt+1)
					nAt := At(";",cCbox)
				EndDo
				cAux  := cCbox
				aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 			
			EndIf
            
            //Se existe tipo especial
    		if Ascan(aCbox,{|x| UPPER(alltrim(x[2])) = "ESPECIAL"})>0
    			//Se não for tipo especial valido o volume
    			if alltrim(aCbox[Ascan(aCbox,{|x| UPPER(alltrim(x[2])) = "ESPECIAL"})][1])!=alltrim(M->Z55_TPCTR)

		    		if empty(aCols[h][nPosGetVol])
			    		Alert("Existe linha com Volume não informado!")
			    		Return .F.
						Exit
					endif
    			
    			endif
			else
	    		
	    		if empty(aCols[h][nPosGetVol])
		    		Alert("Existe linha com Volume não informado!")
		    		Return .F.
					Exit
				endif
			
			endif
			
    	endif
        */
    next


 	for lZ29:=1 to len(aColsZ29)
    
	    if !oGetDadosZ29:ChkObrigat(lZ29)//Linha
			Return .F.        
    	endif
    	
    next

    //Valida se os totais da aba resumo dos serviços batem com os valores da aba descrição dos serviços
	if !ValidSer()
		Return .F.
	endif

	nPosNum		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_NUM"})
	nPosVlrIni	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_VLRINI"})
	nPosValor	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_VALOR"})
	
	//Se buscar de draft irá preencher o número da proposta com o número do draft
 	//if Empty(M->Z55_DRAFT) 
		cNum:= ProxNum(M->Z55_TPCTR)
		cRev:= M->Z55_REVISA
	//else
	//	cNum:=M->Z55_DRAFT
	//endif		
	
	BEGIN TRANSACTION	
		//Gravando ENCHOICE principal
		RecLock("Z55",iif(nOpc==3,.T.,.F.)) 
			Z55->Z55_FILIAL	:= xFilial("Z55")
			Z55->Z55_FILORI	:= cFilAnt
			for nx:=1 to len(aCpoEnch)-1
	    		if nx==nPosNum
					Z55->&(aCpoEnch[nx]) := cNum
	    		elseif nx==nPosVlrIni
	    			Z55->&(aCpoEnch[nx]) := M->&(aCpoEnch[nPosValor])
	    		else
	    			Z55->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
	    		endif
			next 
			Z55->Z55_DTINC	:= ddatabase	
			Z55->Z55_USERRE	:= __cUserID	//Usuário responsável
			Z55->Z55_USERNO	:= UsrFullName(__cUserID)
			Z55->Z55_TPVLR	:= "1"	//Pois foi retirado o campo valor c/ impostos  
			
            /*
            	cQrySta:=" SELECT Z47_LEGEND,Z47_CODIGO FROM "+RETSQLNAME("Z47")+" Z47"
				cQrySta+=" WHERE Z47.D_E_L_E_T_='' AND Z47_NOPC='3'
			    
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif
				
				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
				
				Count to nRecCount
			        
				if nRecCount >0
				
					QRYTEMP->(DbGotop())
								
               		Z55->Z55_STATUS:=QRYTEMP->Z47_CODIGO
               		Z55->Z55_DESCST:=alltrim(QRYTEMP->Z47_LEGEND)
               		
                endif
            */
            
                
			//Gravando os dados da aba de pagamentos
			for ny:=1 to len(aCpoEnCob)-1
				Z55->&(aCpoEnCob[ny]) := M->&(aCpoEnCob[ny])
			next
			
			
	    Z55->(MSUNLOCK())
        
		//Grava Centro de Custo
		GrvCC()

		// -- Grava Status da proposta
        GravLege(xParam4,nOpc)
	    
	    //GRAVANDO GETDADOS - Resumo de serviço
		
		nPosGetCod	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODIGO"})
		nSeqServ	:= "00"
		
			for i:=1 to len(aCols)
		    	//Pego sequencia para linha de serviços
		    	nSeqServ:=SOMA1(nSeqServ)
		    	
		    	RecLock("Z54",.T.)
		    		Z54->Z54_FILIAL	:= xFilial("Z54")
   					Z54->Z54_FILORI	:= cFilAnt
		    		Z54->Z54_NUMPRO	:= cNum
		    		Z54->Z54_REVISA	:= M->Z55_REVISA
		    		
		    		for j:=1 to len(aHeader)
		    			
		    			if j==nPosGetCod
							Z54->&(aHeader[j][2]):=alltrim(cNum)+"."+nSeqServ
		    			else
		    				Z54->&(aHeader[j][2]):=aCols[i][j]
		    			endif
		    		next
		    		
		    	MsUnlock()
		    	
		    next
		    
	    //GRAVANDO GETDADOSZ29 - Descrição de serviços
		nPosCodZ29	:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODIGO"})
		nSeqServZ29	:= "00"
		
			for i:=1 to len(aColsZ29)

				if !aColsZ29[i][len(aColsZ29[i])] //Se não tiver deletado
			    	//Pego sequencia para linha de serviços
			    	nSeqServZ29:=SOMA1(nSeqServZ29)
			    	
			    	RecLock("Z29",.T.)
			    		Z29->Z29_FILIAL	:= xFilial("Z29")
	   					Z29->Z29_FILORI	:= cFilAnt
			    		Z29->Z29_NUMPRO	:= cNum
			    		Z29->Z29_REVISA	:= M->Z55_REVISA
			    		
			    		for j:=1 to len(aHeaderZ29)
			    			
			    			if j==nPosCodZ29
								Z29->&(aHeaderZ29[j][2]):=alltrim(cNum)+"."+nSeqServZ29
			    			else
			    				Z29->&(aHeaderZ29[j][2]):=aColsZ29[i][j]
			    			endif
			    		next
			    		
			    	MsUnlock()
		    	endif

		    next		    
		    
		    
		    
		//GRAVANDO TABELA DE SEQUENCIA DE NUMERACAO
			DbSelectArea("Z51")
			DbSetOrder(1)
			if !DbSeek(xFilial("Z51")+cNum)
				RecLock("Z51",.T.) 
					Z51->Z51_FILIAL	:=xFilial("Z51")
					Z51->Z51_NUM := cNum
			    Z51->(MSUNLOCK())
			endif

	END TRANSACTION
	
	/*Atualiza o Status da tabela de draft*/
	if !Empty(M->Z55_DRAFT)
		DbSelectArea("Z74")
		DbSetOrder(1)
		if DbSeek(xFilial("Z74")+M->Z55_TPCTR+M->Z55_DRAFT)
			RecLock("Z74",.F.)
				Z74->Z74_STATUS:='3' //Em proposta
			Z74->(MsUnlock())
		else
			MsgInfo("Não foi possível atualizar o status do draft!")
		endif
	endif
	/*Fim Atualiza o Status da tabela de draft*/
    
	/*Atualiza o status de conflito da tabela de prospect*/
	if !empty(M->Z55_PROSPE) .AND. !empty(M->Z55_PLOJA) .AND. empty(M->Z55_CLIENT) .AND. empty(M->Z55_LOJA)
		DbSelectArea("SUS")
		DbSetOrder(1)
		if DbSeek(xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA) //Se encontrou na tabela SUS
			if empty(SUS->US_CODCLI)
				RecLock("SUS",.F.)
					SUS->US_P_CONFL:='1' //Sim
				SUS->(MsUnlock())
			endif
		endif
	endif	
	/*Fim Atualiza o status de conflito da tabela de prospect*/
	
	//Gravação da tabela Z50 - Posicionamento
	GravaZ50(nOpc)
    
	//Gravação da tabela Z49 - Pagamentos	
	GravaZ49(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)
	
	//Gravação da tabela Z52 - Despesas x Contrato
	GravaZ52(nOpc,oGetDadDes,aHeaZ52,cNum,cRev,aCpoZ52,aColsZ52)
   
	//Gravação da tabela Z35 - Empresas de grupo da proposta
	GravaZ35(nOpc,oGetDadEmp,cNum,cRev)

	//RRP - 05/06/2013 - Chama a função para gravar a Classe de Valor
	GrvClVl(cNum)
	
	//Envia e-mail informando a inclusão da proposta, para as pessoas que estiverem no parâmetro MV_P_00017
	EmailInc(cNum,"INCLUI")
	
	MsgInfo("Foi gerada a proposta: "+cNum)

elseif nOpc==4 //Alterar

	cNum:=M->Z55_NUM
	cRev:=M->Z55_REVISA

	/*Verifica se nenhum está marcado, e o campo Z55_MOTIVO está preenchido*/
	//if empty(M->Z55_MOTALT)
	//	Alert("Campo motivo de alteração deve ser preenchido!")
	//	Return(.F.)		
	//endif
    
	/*Verifica se o campo memo está preenchido*/
	//if empty(alltrim(cMemo))
	//	Alert("Campo descrição do posicionamento deve ser preenchido!")
	//	Return(.F.)		    
	//endif
	
	//Gravando ENCHOICE
	RecLock("Z55",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z55->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
        //Gravando os dados da aba de dados de cobrança
		for ny:=1 to len(aAltCobEn)
    		Z55->&(aAltCobEn[ny]) := M->&(aAltCobEn[ny])
    	next
    	
    Z55->(MSUNLOCK())

    //Se já existir algo preenchido.
    if !empty(aItensZ50U)

	    //Verificando se a barra foi movimentada, e se a descrição foi alterada, para que possa ser salvo.
	    if alltrim(cTexto)<>alltrim(aItensZ50U[1][3]) .OR. alltrim(cMemo)<>alltrim(aItensZ50U[1][5])
		   	//Gravação da tabela Z50 -- Posicionamento
			GravaZ50(nOpc)
	    endif
    else
	   	//Gravação da tabela Z50 -- Posicionamento
		GravaZ50(nOpc)    
	endif

	//Gravação da tabela Z49 - Pagamentos
	GravaZ49(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)

	//Gravação da tabela Z52 - Despesas x Contrato
	GravaZ52(nOpc,oGetDadDes,aHeaZ52,cNum,cRev,aCpoZ52,aColsZ52)
    
    /*
	if M->Z55_STATUS $ '8' //Alterando proposta aprovada sem assinatura do cliente
		//Gravando ENCHOICE
		//Tratamento para verificar se a proposta assinada foi anexada
		DbSelectArea("Z48")
		Z48->(DbSetOrder(1))
		if DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA+cItemZ48)
			cTipoZ48:=Z48->Z48_TIPO
		endif
		
		RecLock("Z55",.F.) 
			if Alltrim(UPPER(cTipoZ48))<>"P"
				Z55->Z55_STATUS:= "8"
	        else
				Z55->Z55_STATUS:= "9"
			endif
	    Z55->(MSUNLOCK())  		
	endif
	*/

elseif nOpc==6 //Revisar
	
	cTipoFat:= M->Z55_TIPOFT

	//Tratamento caso os campos estejam em branco, propostas antigas a criação destes campos
	if empty(cTipoFat)
		cTipoFat:="F"
	endif
	
	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif

    /*Valida se o valor é diferente de 0(zero)*/
    //if empty(M->Z55_VALOR) .OR. empty(M->Z55_VLRLIS)
	//	Alert("Campo valor deve ser preenchido!")
   	//	Return .F.
    //endif
    
    /*Valida se o campo cliente ou prospect estão preenchidos*/
    if empty(M->Z55_CLIENT) .AND. empty(M->Z55_PROSPE)
		Alert("Deve ser informado um cliente ou um prospect!")
   		Return .F.
    endif

    /*Valida se o campo global esta preenchido com 1=SIM, então o campo desc global deve ser preenchido*/
    if M->Z55_GLOBAL=="1"
		if empty(M->Z55_CLIGLO)
			Alert("Deve ser informado a descrição global!")
	   		Return .F.
   		endif
    endif

    if cTipoFat=="F" //Se o tipo de faturamento for fixo, valido se os dados do pagamento estão preenchidos
    
	    //Valida se o valor da proposta é o mesmo das parcelas
	    if alltrim(cValG3_1_1)<>alltrim(cValG3_1_2) .or. Empty(cValG3_1_1) .or. Empty(cValG3_1_2) .or. ROUND(M->Z55_VLRTOT,2)<>val(StrTran(StrTran(cValG3_1_1,".",""),",","."))
			Alert("Verifique os valores na aba pagamentos, o valor da proposta deve ser o mesmo do valor das parcelas!")
	   		Return .F.    
	    endif
	
	    //Valida se as parcelas estão preenchidas corretamente
	    For nI:=1 To Len(oGetDdsVlr:aCols)
			
			//Verifica se o vencimento está preenchido
			If Empty(oGetDdsVlr:aCols[nI][2])
				Alert("Verifique a data de vencimento da parcela "+ AllTrim(Str(nI)) + ".")
	   			Return .F.  			
			EndIf
			
			//Verifica se o valor da parcela está preenchido
			If oGetDdsVlr:aCols[nI][3] <= 0
				Alert("Verifique o valor da parcela "+ AllTrim(Str(nI)) + ".")
	   			Return .F.  			
			EndIf
		Next
    
	endif
	
	/*Validação do preenchimento da GetDados*/
	nPosGetDiv:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODDIV"})
	nPosGetNat:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODNAT"})
	nPosGetRec:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_RECORR"})
	nPosGetRQT:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_RECQTD"})
	nPosGetRAn:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_ANOINI"})
	nPosGetHor:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_HORAPR"})
	nPosGetLiq:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_PRECOL"})
	nPosGetBru:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CUSTOT"})
	
	//nPosGetVol:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_VOLUME"})
    
    if empty(aCols)
		Alert("Verifique se existe serviço preenchido!")
    	Return .F.
	endif
	
 	for h:=1 to len(aCols)
        
 		//Verifica se a linha não está deletada
 		If !(aCols[h][Len(aCols[h])])

	    	if nPosGetDiv>0
    			if empty(aCols[h][nPosGetDiv])
	    			Alert("Existe linha com Divisão não preenchida!")
	    			Return .F.
					Exit
				endif
			endif         
		
    		if nPosGetNat>0
    			if empty(aCols[h][nPosGetNat])
	    			Alert("Existe linha com Natureza não preenchida!")
		    		Return .F.
					Exit
				endif
			endif
             
            //Validação das horas previstas
        	If nPosGetHor > 0
 				If aCols[h][nPosGetHor] <= 0
 					Alert("Existe linha com Horas Previstas não preenchida!")
 					Return .F.
 				EndIf       	
        	EndIf
            
            //Validação do preço liquido
        	If nPosGetLiq > 0
 				If aCols[h][nPosGetLiq] <= 0
 					Alert("Existe linha com Preço Liquido não preenchido!")
 					Return .F.
 				EndIf       	
        	EndIf
        
            //Validação do valor bruto
        	If nPosGetBru > 0
 				If aCols[h][nPosGetBru] <= 0
 					Alert("Existe linha com Preço Bruto não preenchido!")
 					Return .F.
 				EndIf       	
        	EndIf
        
    		if nPosGetRec>0
    			if (aCols[h][nPosGetRec])=="S"
	    		
	    			if nPosGetRQT>0 .AND. nPosGetRAn>0
	    				if empty(aCols[h][nPosGetRQT])
			    			Alert("Informe a recorrência na grade de serviços!")
				    		Return .F.
							Exit
	    				elseif empty(aCols[h][nPosGetRAn])
				    		Alert("Informe o inicio do exercício na grade de serviços!")
			    			Return .F.
							Exit	    			
		    			endif
		    		endif

				endif

			endif
		EndIf	
	Next
    
 	for lZ29:=1 to len(aColsZ29)
    
	    if !oGetDadosZ29:ChkObrigat(lZ29)//Linha
			Return .F.        
    	endif
    	
    next

    //Valida se os totais da aba resumo dos serviços batem com os valores da aba descrição dos serviços
	if !ValidSer()
		Return .F.
	endif

	nPosNum		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_NUM"})
	nPosRev		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_REVISA"})
	nPosVlrIni	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_VLRINI"})
	nPosValor	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_VALOR"})
	nPosStatu	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_STATUS"})	
	nPosMotCan	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_MOTREC"})
	nPosObsGt	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z55_OBSGT"})
	
/*	//Se buscar de draft irá preencher o número da proposta com o número do draft
 	if Empty(M->Z55_DRAFT) 
		cNum:=ProxNum(M->Z55_TPCTR)
	else
		cNum:=M->Z55_DRAFT
	endif		
*/	
    
	cNum:=M->Z55_NUM
	cRev:=M->Z55_REVISA

	BEGIN TRANSACTION	
		
		//Gravando Status Proposta antiga
		/*if alltrim(M->Z55_STATUS)=="4"
			RecLock("Z55",.F.) 
				Z55->Z55_STATUS:='A'
		    Z55->(MSUNLOCK())
		else
			RecLock("Z55",.F.) 
				Z55->Z55_STATUS:='2'
		    Z55->(MSUNLOCK())
		endif
		*/
		//RecLock("Z55",.F.) 
		//	Z55->Z55_STATUS:='2'
	    //Z55->(MSUNLOCK())
		
	    //Gravo a legenda e o status
	    GravLege(xParam4,nOpc)
		    		
		//Gravando ENCHOICE
		RecLock("Z55",.T.) 
			Z55->Z55_FILIAL	:=xFilial("Z55")
			Z55->Z55_FILORI	:= cFilAnt
			for nx:=1 to len(aCpoEnch)-1
	    		if nx==nPosNum
					Z55->&(aCpoEnch[nx]) := cNum
	    		elseif nx==nPosRev
	    			Z55->&(aCpoEnch[nx]) := cRev
	    		elseif nx==nPosVlrIni
	    			Z55->&(aCpoEnch[nx]) := M->&(aCpoEnch[nPosValor])
	    		elseif nx==nPosStatu
		    		Z55->&(aCpoEnch[nx]) := "1"
	    		elseif nx==nPosObsGt
		    		Z55->&(aCpoEnch[nx]) := ""
	    		elseif nx==nPosMotCan
		    		Z55->&(aCpoEnch[nx]) := ""
	    		else
	    			Z55->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
	    		endif
			next 
			Z55->Z55_DTINC:=ddatabase
			
			//Gravando os dados da aba de dados de cobranca
			for ny:=1 to len(aCpoEnCob)-1
				Z55->&(aCpoEnCob[ny]) := M->&(aCpoEnCob[ny])
			next
			
	    Z55->(MSUNLOCK())
	            
		//Grava Centro de Custo
		GrvCC()
	    
	    //Gravo a legenda e o status
	    GravLege(xParam4,3) //Passo o nOpc igual a 3 para gravar a nova como uma inclusão nova
	    
	    //GRAVANDO GETDADOS - Resumo dos serviços
	    
	    nPosCodSe	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODIGO"})
	    cSeqServ	:= "00"
			for i:=1 to len(aCols)
		    	cSeqServ:=SOMA1(cSeqServ)
		    	
		    	RecLock("Z54",.T.)
		    		Z54->Z54_FILIAL	:= xFilial("Z54")
   					Z54->Z54_FILORI	:= cFilAnt
		    		Z54->Z54_NUMPRO	:= cNum
		    		Z54->Z54_REVISA	:= cRev
		    		for j:=1 to len(aHeader)
		    			//if j==nPosCodSe
		    			//	Z54->&(aHeader[j][2]):=cNum+"/"+cSeqServ
		    			//else
		    				Z54->&(aHeader[j][2]):=aCols[i][j]
		    			//endif
		    		next
		    	MsUnlock()
		    next

	    //GRAVANDO GETDADOSZ29 - Descrição de serviços
		nPosCodZ29	:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODIGO"})
		nSeqServZ29	:= "00"
		
			for i:=1 to len(aColsZ29)

				if !aColsZ29[i][len(aColsZ29[i])] //Se não tiver deletado
			    	//Pego sequencia para linha de serviços
			    	nSeqServZ29:=SOMA1(nSeqServZ29)
			    	
			    	RecLock("Z29",.T.)
			    		Z29->Z29_FILIAL	:= xFilial("Z29")
	   					Z29->Z29_FILORI	:= cFilAnt
			    		Z29->Z29_NUMPRO	:= cNum
			    		Z29->Z29_REVISA	:= cRev
			    		
			    		for j:=1 to len(aHeaderZ29)
			    			
			    			if j==nPosCodZ29
								Z29->&(aHeaderZ29[j][2]):=alltrim(cNum)+"."+nSeqServZ29
			    			else
			    				Z29->&(aHeaderZ29[j][2]):=aColsZ29[i][j]
			    			endif
			    			
			    		next
			    		
			    	MsUnlock()
			 	endif
			    	
		    next		    

	END TRANSACTION
    
	/*Atualiza o status de conflito da tabela de prospect*/
	if !empty(M->Z55_PROSPE) .AND. !empty(M->Z55_PLOJA) .AND. empty(M->Z55_CLIENT) .AND. empty(M->Z55_LOJA)
		DbSelectArea("SUS")
		DbSetOrder(1)
		if DbSeek(xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA) //Se encontrou na tabela SUS
			if empty(SUS->US_CODCLI)
				RecLock("SUS",.F.)
					SUS->US_P_CONFL:='1' //Sim
				SUS->(MsUnlock())
			endif
		endif
	endif	
	/*Fim Atualiza o status de conflito da tabela de prospect*/
	
	//Gravação da tabela Z50 - Posicionamento
	GravaZ50(nOpc)
	
	//Gravação da tabela Z49 - Pagamentos
	GravaZ49(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)    
	
	//Gravação da tabela Z52 - Despesas x Contrato
	GravaZ52(nOpc,oGetDadDes,aHeaZ52,cNum,cRev,aCpoZ52,aColsZ52)	
	
	//Gravação da tabela Z35 - Empresas de grupo da proposta
	GravaZ35(nOpc,oGetDadEmp,cNum,cRev)
	
	//Gravação da tabela Z48 - Anexos
	GravaZ48(nOpc,cNum,cRev)
	
	//Atualiza revisão atual dos demais contratos envolvidos.
	cQry79:=" UPDATE "+RETSQLNAME("Z55")+" SET Z55_REVATU='"+cRev+"'"+CRLF
	cQry79+=" WHERE Z55_NUM='"+cNum+"' AND D_E_L_E_T_='' AND Z55_REVISA<>'"+cRev+"'

	TCSQLExec(cQry79)
    
	//Envia e-mail informando a revisao da proposta, para os sócios e gerentes
	EmailInc(cNum,"REVISAO")

	MsgInfo("Revisão gerada com sucesso!")

elseif nOpc==7 //Aprovar ou recusar

	cNum:=Z55->Z55_NUM

    //Valida se o campo de Observação está preenchido
    if empty(M->Z55_OBSGT)
		Alert("Por favor, preencha o campo de observação.")
   		Return .F.
    endif

	BEGIN TRANSACTION	
		RECLOCK("Z55",.F.)
			Z55->Z55_OBSGT	:= M->Z55_OBSGT
			Z55->Z55_DTREGT	:= dDataBase
			Z55->Z55_HRREGT	:= TIME()
		Z55->(MsUnLock())
		ConfirmSx8()
	END TRANSACTION 
    
	// -- Grava Status da proposta
    GravLege(xParam4,nOpc)
    
	if UPPER("POOL") $ UPPER(Z55->Z55_DESCST)
    	//Envia e-mail informando o envio para revisão do pool, para as pessoas que estiverem no parâmetro MV_P_00018
		EmailInc(cNum,"INPOOL")
    else
		//Pega o e-mail do responsável pela proposta.
		cTo:=UsrRetMail(M->Z55_RESPON)
	
		//Pega o e-mail do usuário que incluiu a proposta.
		cTo+=IIF(!empty(cTo),";","")+UsrRetMail(M->Z55_USERRE)
		
		//Envia e-mail para o responsável e o usuário, informando sobre a aprovada ou recusa
		EnvMaiSo(cTo,nOpc)
	endif    

elseif nOpc==8 //Enviar para aprovação GT

	cNum	:= M->Z55_NUM
	cRev	:= M->Z55_REVISA
	cTipoFat:= M->Z55_TIPOFT

	//Tratamento caso os campos estejam em branco, propostas antigas a criação destes campos
	if empty(cTipoFat)
		cTipoFat:="F"
	endif

	/*Verifica se o aprovador está preenchido*/
	if empty(M->Z55_APROVA)
		Alert("Campo aprovador não está preenchido!")
		Return(.F.)		
	endif
    
    if cTipoFat=="F" //Se o tipo de faturamento for fixo, valido se os dados do pagamento estão preenchidos

		//Verifico se o campo parcelas está preenchido
		if empty(cValG3_1_4)
			Alert("Campo 'Parcelas' na aba pagamentos não está preenchido!")
			Return(.F.)
		endif	
		
		//Verifico se o campo data inicial está preenchido
		if empty(cValG3_1_6)
			Alert("Campo 'Dt Inicial' na aba pagamentos não está preenchido!")
			Return(.F.)
		endif
	
	endif
	
	//Verificação de anexo
	DbSelectArea("Z48")
	Z48->(DbGoTop())
    DbSetOrder(1)
    DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA)
    While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==M->Z55_NUM .AND. Z48->Z48_REVISA==M->Z55_REVISA
		nAnexos++
    	Z48->(DbSkip())
    Enddo    	
    
    if nAnexos<1
		Alert("O arquivo draft da proposta não foi anexado nessa rotina"+CRLF+"Por favor, anexe o documento para seguir com o processo.")
  		Return .F.    			
	endif

	
	//Gravando ENCHOICE
	RecLock("Z55",.F.) 
		Z55->Z55_APROVA	:= M->Z55_APROVA
		Z55->Z55_NOMEAP	:= M->Z55_NOMEAP
		Z55->Z55_DTREMG	:= dDataBase
		Z55->Z55_HRREMG	:= TIME()
		//Z55->Z55_STATUS:= "3"
    Z55->(MSUNLOCK())

	//Gravação da tabela Z49 - Pagamentos, passando o nopc como 3 pois se n está preenchido trata-se de uma inclusão
	GravaZ49(4,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)    
	
	//Atualizo o status
	GravLege(xParam4,nOpc)
	
	//Pega o e-mail do usuário selecionado como aprovador.
	cTo:=UsrRetMail(M->Z55_APROVA)

	//Envia e-mail para o aprovador, informando sobre o envio de proposta para aprovar
	EnvMaiSo(cTo,nOpc)

elseif nOpc==9 //Aprovação de conflito

	cNum	:= M->Z55_NUM

	//Gravando ENCHOICE
/*	RecLock("Z55",.F.) 
		Z55->Z55_DTREMC	:= dDataBase
		Z55->Z55_HRREMC	:= TIME()
		Z55->Z55_INFCLI	:= "Enviado p/ cliente data: "+DTOC(dDataBase)+" ,hora: "+SUBSTRING(TIME(),1,5)
		//Z55->Z55_STATUS	:= "6"
    Z55->(MSUNLOCK())
    
    //Gravo a legenda e o status
	GravLege(xParam4,nOpc)
*/

    /*Valida se o campo Aceitacao */
    if empty(M->Z55_POOLAC)
		Alert("Deve ser preenchido o campo aceitação!")
   		Return .F.
    endif
    
    /*Valida se o campo Independencia*/
    if empty(M->Z55_POOLIN)
		Alert("Deve ser preenchido o campo independência!")
   		Return .F.
    endif

	cQrySta:=" SELECT Z46_DESCRI,Z46_CODLEG,Z47_NOPC FROM "+RETSQLNAME("Z46")+" Z46
	cQrySta+=" JOIN "+RETSQLNAME("Z47")+" Z47 ON Z46.Z46_CODACA=Z47.Z47_CODIGO
	cQrySta+=" WHERE Z46.D_E_L_E_T_='' AND Z47.Z47_NOPC='9'
    				    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0
	
		QRYTEMP->(DbGotop())
		While QRYTEMP->(!EOF())
            	
            	if alltrim(M->Z55_POOLAC)=="2" .OR. alltrim(M->Z55_POOLIN)=="2"
            		if "RECUSADA" $ UPPER(QRYTEMP->Z46_DESCRI)
						cCodLeg	:= QRYTEMP->Z46_CODLEG
						cDescLeg:= QRYTEMP->Z46_DESCRI            	    
            	    endif
            	else
	            	if !"RECUSADA" $ UPPER(QRYTEMP->Z46_DESCRI)
						cCodLeg	:= QRYTEMP->Z46_CODLEG
						cDescLeg:= QRYTEMP->Z46_DESCRI            	
      				endif
            	endif
				
			QRYTEMP->(DbSkip())
        Enddo

 	endif
 	
	BEGIN TRANSACTION	
		RECLOCK("Z55",.F.)
			
			Z55->Z55_DESCST	:= cDescLeg			
			Z55->Z55_STATUS	:= cCodLeg
			Z55->Z55_POOLAC	:= M->Z55_POOLAC
			Z55->Z55_POOLIN	:= M->Z55_POOLIN
			
		Z55->(MsUnLock())
		ConfirmSx8()
	END TRANSACTION 

    //Tratamento para enviar o e-mail
		cHtml:=' <html style="padding: 0px; margin: 0px;">
		cHtml+=' <head>
		cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
		cHtml+=' </head>
		cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000"><div><span>
		//cHtml+=' <div align="left">
		cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 60.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
		cHtml+=' <tbody>
		cHtml+=' <tr>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;<img dfsrc="cid:DWT232" src="http://www.grantthornton.com.br/images/logo.gif"></p></td>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;
		cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
		cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US;'
		cHtml+='	 mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt;'
		cHtml+='	  mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%;'
		cHtml+='	  FONT-FAMILY: '+"'Georgia','serif'"+'; FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri;'
		cHtml+='	  mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR;'
		cHtml+='	  mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | Propostas</font></strong></span></span></p></td></tr>
		//cHtml+=' </table></div><br>
		cHtml+=' <tr>
		cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo foi retornada após análise de risco: </span></span>
		cHtml+=' </td></tr>
		cHtml+=' </div>

		cHtml+=' </tbody>
		
		cHtml+=' <tr><td colspan="2">
			
		cHtml+=' <p><span></span>&nbsp;</p>
		cHtml+=' <p><span>&nbsp;</span></p>
		cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
		cHtml+=' <colgroup>
		cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
		cHtml+=' </colgroup>
		
		cHtml+=' <tbody>
		cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Número</font></strong></p>
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">'+IIF(!empty(M->Z55_NOME),"Cliente","Prospect")+'</font></strong></p></td>
	   
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Parecer</font></strong></p>
		cHtml+=' </td>
		cHtml+=' </tr>
			
		cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
		cHtml+=' <font size="2" face="Calibri">'+AllTrim(M->Z55_NUM)+'</font>'
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+IIF(!empty(M->Z55_NOME),alltrim(M->Z55_NOME),alltrim(M->Z55_PNOME))+'</font> '
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
		
		if M->Z55_POOLAC=="1" .AND. M->Z55_POOLIN=="1"  //Se for aprovado
		
			cHtml+=' <font size="2" face="Calibri">Aprovado</font>'
		
		else
		
			cMot:=""
		
			if M->Z55_POOLAC=="2"
				cMot+="Aceitação"
			endif
			
			if Z55_POOLIN=="2"
				if !empty(cMot)
					cMot+=","
				endif
				
				cMot+="Independência"
			endif
			
			cHtml+=' <font size="2" face="Calibri">Reprovado: '+cMot+'</font>'
		
		endif
		
		cHtml+=' </td>
		
		cHtml+=' </tr>
			
		cHtml+=' </tbody></table><span></span>

		cHtml+=' </td></tr>
		cHtml+=' <tr><td>
		
		cHtml+=' <p><br><br><br>&nbsp;</p>
		
		cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
		cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>

		cHtml+=' </td></tr>
		cHtml+=' </table>
		
		cHtml+=' </body>
		cHtml+=' </html>
		
		//Pega o e-mail do responsável pela proposta.
		cTo:=UsrRetMail(M->Z55_RESPON)

		//Pega o e-mail do usuário que incluiu a proposta.
		cTo+=IIF(!empty(cTo),";","")+UsrRetMail(M->Z55_USERRE) 
		
		cSubject := "Retorno de verificacao de conflito"
		
		if !empty(cTo)
			EnviaEma(cHtml,cSubject,cTo)	
		endif
    
	//Envia e-mail informando o envio para revisão do pool, para as pessoas que estiverem no parâmetro MV_P_00018
	EmailInc(cNum,"INPOOL")
	
	//Grava o log de movimentações da proposta
	GravLog()

elseif nOpc==11 //Cliente recusou
   
	cDescAtu:=Z55->Z55_DESCST
	cStaAtu	:=Z55->Z55_STATUS
	
	BeginTran()  //Inicializo o comando de transação unica
	
	//Gravo a legenda e o status
	GravLege(xParam4,nOpc)
    
	if "PERDIDA" $ UPPER(Z55->Z55_DESCST)
		if empty(M->Z55_MOTREC)
			Alert("Campo motivo recusa deve ser preenchido!")
			DisarmTransaction()
			 
			//--Apago da tabela de log o registro de status que foi armazenado
			cQry:=" UPDATE "+RETSQLNAME("Z43")+" SET D_E_L_E_T_='*'
			cQry+=" WHERE R_E_C_N_O_= (
			cQry+=" SELECT MAX(R_E_C_N_O_) FROM "+RETSQLNAME("Z43")
			cQry+=" WHERE Z43_PROPOS='"+Z55->Z55_NUM+"' AND Z43_REVISA='"+Z55->Z55_REVISA+"') 
			
			TCSQLExec(cQry)
			//--Fim do apago
			
			//Volto o status que era
			RecLock("Z55",.F.)
				Z55->Z55_DESCST:=cDescAtu
				Z55->Z55_STATUS:=cStaAtu
			MsUnlock()
			//Fim Volto o status que era
				
			Return(.F.)
		else
			aCbox	:={}
			cDescOpc:=""
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek("Z55_MOTREC"))
			
				cCbox := AllTrim(SX3->X3_CBOX)
				nAt := At(";",cCbox)
				While nAt > 0
					cAux  := Left(cCbox,nAt-1)
													
					aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 
													
					cCbox := Substr(cCbox,nAt+1)
					nAt := At(";",cCbox)
				EndDo
				cAux  := cCbox
				aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 			
			EndIf
		
			nPos := aScan(aCbox,{|a| Alltrim(a[1])== AllTrim(M->Z55_MOTREC)})
			if nPos > 0
				cDescOpc := alltrim(aCbox[nPos][2])
			endif
			
			if alltrim(Upper(cDescOpc))=="OUTROS"
				if empty(M->Z55_OBSREC)
					Alert("Campo observação da recusa deve ser preenchido!")
					DisarmTransaction()

					//--Apago da tabela de log o registro de status que foi armazenado
					cQry:=" UPDATE "+RETSQLNAME("Z43")+" SET D_E_L_E_T_='*'
					cQry+=" WHERE R_E_C_N_O_= (
					cQry+=" SELECT MAX(R_E_C_N_O_) FROM "+RETSQLNAME("Z43")
					cQry+=" WHERE Z43_PROPOS='"+Z55->Z55_NUM+"' AND Z43_REVISA='"+Z55->Z55_REVISA+"') 
					
					TCSQLExec(cQry)
					//--Fim do apago
					
					//Volto o status que era
					RecLock("Z55",.F.)
						Z55->Z55_DESCST:=cDescAtu
						Z55->Z55_STATUS:=cStaAtu
					MsUnlock()
					//Fim Volto o status que era
						
					Return(.F.)

				endif
			endif
			
			if alltrim(Upper(cDescOpc))=="CONCORRENTE"
			
				if empty(M->Z55_CODCON)
					Alert("O campo concorrente deve ser preenchido!")
					DisarmTransaction()

					//--Apago da tabela de log o registro de status que foi armazenado
					cQry:=" UPDATE "+RETSQLNAME("Z43")+" SET D_E_L_E_T_='*'
					cQry+=" WHERE R_E_C_N_O_= (
					cQry+=" SELECT MAX(R_E_C_N_O_) FROM "+RETSQLNAME("Z43")
					cQry+=" WHERE Z43_PROPOS='"+Z55->Z55_NUM+"' AND Z43_REVISA='"+Z55->Z55_REVISA+"') 
					
					TCSQLExec(cQry)
					//--Fim do apago
					
					//Volto o status que era
					RecLock("Z55",.F.)
						Z55->Z55_DESCST:=cDescAtu
						Z55->Z55_STATUS:=cStaAtu
					MsUnlock()
					//Fim Volto o status que era
						
					Return(.F.)

				endif			
			
			endif
						
		endif
	endif

	RecLock("Z55",.F.) 
		Z55->Z55_MOTREC	:= M->Z55_MOTREC
		Z55->Z55_OBSREC	:= M->Z55_OBSREC
		Z55->Z55_CODCON	:= M->Z55_CODCON
    Z55->(MSUNLOCK())
	
	EndTran()	//Finalizo a transação única
	
	MsUnlockAll()
     
elseif nOpc==14	 //Finalizado pelo gestor
	cCampo:=""

    //Tela para informar se a proposta é assinada
	if empty(M->Z55_DTASSI)
		if !ProAssin()
	    	return(.F.)
	    endif
	endif
	//++ INICIO ++ Tratamento para dados de cobrança
	
	//Verifica se alguns dados importantes de cobrança estão preenchidos
	For ny:=1 to len(aCpoEnCob)-1
		If aCpoEnCob[ny] $ "Z55_COBTIP/Z55_COBHON/Z55_COBRES/Z55_COBTEL/Z55_COBEMA/Z55_RMATI/Z55_DRMAT/Z55_COBEND/Z55_COBBAI/Z55_COBMUN"
			If empty(M->&(aCpoEnCob[ny]))
				DbSelectArea("SX3")
				SX3->(DbSetOrder(2))
				If DbSeek(aCpoEnCob[ny])                                 
					cCampo+=X3Titulo()+", "
				EndIf
			EndIf
		EndIf
	Next

	cCampo:=SUBSTR(cCampo,1,len(cCampo)-2)
	If !empty(cCampo)
		Alert("O(s) campo(s) da aba Dados Cobraça não está(ão) preenchido(s) :"+CRLF+cCampo,"Atenção")
		Return(.F.)
	EndIf
    
    //Verifica se as datas de inicio e fim do projeto foram informadas.
	nPosGetIni:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_DTAINI"})
	nPosGetFim:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_DTAFIM"})
   
    if empty(aCols)
		Alert("Verifique se existe serviço preenchido!")
    	Return .F.
	endif
	
 	for h:=1 to len(aCols)
        
 		//Verifica se a linha não está deletada
 		If !(aCols[h][Len(aCols[h])])

	    	if nPosGetIni>0
    			if Empty(aCols[h][nPosGetIni])
	    			Alert("Informe a data de inicio do projeto, na aba Cadastro, sub-aba Descrição dos serviços.")
	    			Return .F.
				endif
			endif         

	    	if nPosGetFim>0
    			if Empty(aCols[h][nPosGetFim])
	    			Alert("Informa a data prevista para finalização do projeto, na aba Cadastro, sub-aba Descrição dos serviços.")
	    			Return .F.
				endif
			endif         
		    
			if nPosGetIni>0 .AND. nPosGetFim>0
				if aCols[h][nPosGetIni]>aCols[h][nPosGetFim]
					Alert("Verifique as datas de início e fim do projeto, a inicial é maior que a final. Aba Cadastro, sub-aba Descrição dos serviços.")
	    			Return .F.
				endif
			endif
		
		Endif
	Next    
    
    //Verifica se o faturamento está em 100%
    nPosEmpPer:=Ascan(oGetDadEmp:aHeader,{|x| alltrim(x[2]) = "Z35_PERCEN"})
    
    nTotPer := 0
    
    For nI:=1 To Len(oGetDadEmp:aCols)
		If !oGetDadEmp:aCols[nI][Len(oGetDadEmp:aCols[nI])]
	    	nTotPer += oGetDadEmp:aCols[nI][nPosEmpPer]
	 	EndIf
    Next
   
   	If nTotPer <> 100
    	Alert("A soma do percentual de faturamento das empresas do grupo é de " + Transform(nTotPer,"@E 999.99") + ". Esse valor deve ser 100%.")
		Return .F.
   	EndIf
    
    //Gravando ENCHOICE
	RecLock("Z55",.F.) 

		DbSelectArea("Z48")
		Z48->(DbSetOrder(1))
		if DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA+cItemZ48)
			cTipoZ48:=Z48->Z48_TIPO
		endif
		
		//Gravando os dados da aba de dados de cobranca
		for ny:=1 to len(aCpoEnCob)-1
			Z55->&(aCpoEnCob[ny]) := M->&(aCpoEnCob[ny])
		next
		
    Z55->(MSUNLOCK())

    //++ FIM ++ Tratamento para dados de cobrança
    
    cNum:=Z55->Z55_NUM
    cRev:=Z55->Z55_REVISA
    	
	//Gravando ENCHOICE
	//RecLock("Z55",.F.) 
	//	Z55->Z55_STATUS:= "A"
    //Z55->(MSUNLOCK())
    

	//Gravando os itens
	nPosGetCod	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODIGO"})
	for i:=1 to len(aCols)
    	DbSelectArea("Z54")
    	Z54->(DbSetOrder(2))
    	if Z54->(DbSeek(xFilial("Z54")+cNum+cRev+aCols[i][nPosGetCod]))
	    	RecLock("Z54",.F.)
	    		for j:=1 to len(aHeader)
	    			if j<>nPosGetCod
	    				Z54->&(aHeader[j][2]):=aCols[i][j]
	    			endif
	    		next
	    	MsUnlock()
    	endif
    next

	//Gravando os itens da tabela Z29
	nPosCodZ29	:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODIGO"})
	for i:=1 to len(aColsZ29)
    	DbSelectArea("Z29")
    	Z29->(DbSetOrder(2))
    	if Z29->(DbSeek(xFilial("Z29")+cNum+cRev+aColsZ29[i][nPosCodZ29]))
	    	RecLock("Z29",.F.)
	    		for j:=1 to len(aHeaderZ29)
	    			if j<>nPosCodZ29
	    				Z29->&(aHeaderZ29[j][2]):=aColsZ29[i][j]
	    			endif
	    		next
	    	MsUnlock()
    	endif
    next
    
  	//Gravação da tabela Z35 - Empresas de grupo da proposta
	GravaZ35(nOpc,oGetDadEmp,cNum,cRev)

	//++ INICIO ++ Tratamento para tornar o prospect como cliente
    
    //Verifica se o prospect esta preenchido e o cliente não
	if !empty(Z55->Z55_PROSPE) .AND. !empty(Z55->Z55_PLOJA) .AND. empty(Z55->Z55_CLIENT) .AND. empty(Z55->Z55_LOJA)

		DbSelectArea("SUS")
		DbSetOrder(1)
		if DbSeek(xFilial("SUS")+Z55->Z55_PROSPE+Z55->Z55_PLOJA) //Se encontrou na tabela SUS
			if !empty(SUS->US_CODCLI)
				RecLock("Z55",.F.)
					Z55->Z55_CLIENT	:= SUS->US_CODCLI
					Z55->Z55_LOJA	:= SUS->US_LOJACLI
					Z55->Z55_NOME	:= SUS->US_NOME
				MsUnLock()
			else
			
				//MSM - 04/12/2014 - Verificação de preenchimento de campos no prospect, chamado: 022337
				if alltrim(SUS->US_EST)<>"EX"
					if empty(SUS->US_CGC) .OR. empty(SUS->US_END) .OR. empty(SUS->US_P_SOCIO)
						Alert("Atualização de Prospect"+CRLF+"Código: "+alltrim(SUS->US_COD)+CRLF+"Nome: "+alltrim(SUS->US_NOME)+CRLF+"Os campos: CNPJ/CPF, Endereço e Sócio Responsável devem estar preenchidos!")
						Return(.F.)	
					endif
				else
					if empty(SUS->US_END) .OR. empty(SUS->US_P_SOCIO)
						Alert("Atualização de Prospect"+CRLF+"Código: "+alltrim(SUS->US_COD)+CRLF+"Nome: "+alltrim(SUS->US_NOME)+CRLF+"Os campos: Endereço e Sócio Responsável devem estar preenchidos!")
						Return(.F.)						
					endif
				endif
			    
				if U_GTP2C(Z55->Z55_PROSPE,Z55->Z55_PLOJA) //Se Virou cliente
					DbSelectArea("SUS")
					DbSetOrder(1)
					if DbSeek(xFilial("SUS")+Z55->Z55_PROSPE+Z55->Z55_PLOJA) //Se encontrou na tabela SUS
					    //Grava o cliente e a loja na tabela de proposta
						RecLock("Z55",.F.)
							Z55->Z55_CLIENT	:= SUS->US_CODCLI
							Z55->Z55_LOJA	:= SUS->US_LOJACLI
							Z55->Z55_NOME	:= SUS->US_NOME
						MsUnLock()				
					endif
					
					//Gera os prospects de grupo em clientes
					U_GeraEmpGrp(Z55->Z55_TPCTR,Z55->Z55_NUM,Z55->Z55_REVISA)
					
				else
					Alert("Não foi possível tornar o prospect em cliente!")
					Return(.F.)
				endif
			endif
		else
			Alert("Prospect não encontrado!")
			Return(.F.)			
		endif
	
	elseif !empty(Z55->Z55_CLIENT) .AND. !empty(Z55->Z55_LOJA)

		if MsgYesNo("Deseja atualizar os dados de cobrança do cliente com base na proposta?")

			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			if Sa1->(DbSeek(xFilial("SA1")+Z55->Z55_CLIENT+Z55->Z55_LOJA))
            
			RecLock("SA1",.F.)
	           //endereço
				if SA1->(FieldPos("A1_ENDCOB"))>0 .AND. Z55->(FieldPos("Z55_COBEND"))>0
					SA1->A1_ENDCOB:=Z55->Z55_COBEND
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMAIC"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
					SA1->A1_P_EMAIC:=Z55->Z55_COBEMA
				endif
	            //e-mail
				if SA1->(FieldPos("A1_P_EMACO"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
					SA1->A1_P_EMACO:=Z55->Z55_COBEMA
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMAIL"))>0 .AND. Z55->(FieldPos("Z55_COBEMA"))>0
					SA1->A1_P_EMAIL:=Z55->Z55_COBEMA
				endif
	            //bairro
				if SA1->(FieldPos("A1_BAICOB"))>0 .AND. Z55->(FieldPos("Z55_COBBAI"))>0
					SA1->A1_BAICOB:=Z55->Z55_COBBAI
				endif			
	            //bairro
				if SA1->(FieldPos("A1_BAIRROC"))>0 .AND. Z55->(FieldPos("Z55_COBBAI"))>0
					SA1->A1_BAIRROC:=Z55->Z55_COBBAI
				endif
	            //municipio
				if SA1->(FieldPos("A1_MUNCOB"))>0 .AND. Z55->(FieldPos("Z55_COBMUN"))>0
					SA1->A1_MUNCOB:=Z55->Z55_COBMUN
				endif
	            //CEP
				if SA1->(FieldPos("A1_CEPCOB"))>0 .AND. Z55->(FieldPos("Z55_COBCEP"))>0
					SA1->A1_CEPCOB:=Z55->Z55_COBCEP
				endif
	            //Código Ramo de atividade
				if SA1->(FieldPos("A1_P_RMATI"))>0 .AND. Z55->(FieldPos("Z55_RMATI"))>0
					SA1->A1_P_RMATI:=Z55->Z55_RMATI
				endif
				//Descrição Ramo de atividade
				if SA1->(FieldPos("A1_P_DRMAT"))>0 .AND. Z55->(FieldPos("Z55_DRMAT"))>0
					SA1->A1_P_DRMAT:=Z55->Z55_DRMAT
				endif
			endif
			
			SA1->(MsUnlock())
	    endif

	endif
    
    //Gravo a legenda e o status
	GravLege(xParam4,nOpc)

	//++ FIM ++ Tratamento para tornar o prospect como cliente    
    
    //Grava os dados de serviço na tabela de muro para gerar o projeto
    GravaPro(aCols,aHeader)
    
    //++ INICIO ++ Tratamento para gerar o contrato com base na proposta
	
Private oDlg1
	
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Gerando contrato(s)..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(GeraCT(@oMeter,oDlg1))
	  
	//***********************************************************

	if !cEmpAnt $ "99" .AND. !"TESTE" $ alltrim(UPPER(GetEnvServer()))

		if select('TMPCN9')>0
			TMPCN9->(DbCloseArea())
		endif		

		//Tratamento para enviar e-mail
		nHora := VAL(SUBSTR(TIME(),1,2))
		
		BeginSql Alias 'TMPCN9'
			SELECT CN9_NUMERO,CN9_P_NOME
			FROM %table:CN9%
			WHERE %notDel%
			  AND CN9_P_NUM = %exp:M->Z55_NUM%
			  AND CN9_SITUAC = '02'
			ORDER BY CN9_NUMERO
		EndSql
		
		//Tratamento para enviar e-mail
		cHtml:=' <html style="padding: 0px; margin: 0px;">
		cHtml+=' <head>
		cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
		cHtml+=' </head>
		cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000"><div><span>
		//cHtml+=' <div align="left">
		cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 60.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
		cHtml+=' <tbody>
		cHtml+=' <tr>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;<img dfsrc="cid:DWT232" src="http://www.grantthornton.com.br/images/logo.gif"></p></td>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 50%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;
		cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
		cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US;'
		cHtml+='	  mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt;'
		cHtml+='	  mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%;'
		cHtml+='	  FONT-FAMILY: '+"'Georgia','serif'"+'; FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri;'
		cHtml+='	  mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR;'
		cHtml+='	  mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | Propostas</font></strong></span></span></p></td></tr>
		//cHtml+=' </table></div><br>
		
		cHtml+=' <tr>
		cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">		
		cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta de número '+alltrim(M->Z55_NUM)+' foi aprovada e gerou o(s) contrato(s) abaixo na empresa '+alltrim(FWFilialName())+'. Por favor, verifique as informações. </span></span>
		cHtml+=' </td></tr>
		cHtml+=' </div>
		cHtml+=' </tbody>
		
		cHtml+=' <tr><td colspan="2">
		
		cHtml+=' <p><span></span>&nbsp;</p>
		cHtml+=' <p><span>&nbsp;</span></p>
		cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
		cHtml+=' <colgroup>
		cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
		cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' </colgroup>
		
		cHtml+=' <tbody>
		cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Contrato</font></strong></p>
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">'+IIF(!empty(M->Z55_NOME),"Cliente","Prospect")+'</font></strong></p></td>
	   
		cHtml+=' </tr>

		TMPCN9->(DbGoTop())
		While TMPCN9->(!EOF())

			cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
			cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
			cHtml+=' <font size="2" face="Calibri">'+AllTrim(TMPCN9->CN9_NUMERO)+'</font>'
			cHtml+=' </td>
		
			cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
			cHtml+=' <font size="2" face="Calibri">'+AllTrim(TMPCN9->CN9_P_NOME)+'</font> '
			cHtml+=' </td>
		
			cHtml+=' </tr>

			TMPCN9->(DbSkip())
		EndDo
			
		cHtml+=' </tbody></table><span></span>
		
		cHtml+=' </td></tr>
		cHtml+=' <tr><td>
		cHtml+=' <p><br><br><br>&nbsp;</p>
		
		cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
		cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>

		cHtml+=' </td></tr>
		cHtml+=' </table>
			
		cHtml+=' </body>
		cHtml+=' </html>
		
		
		cTo:= SUPERGETMV("MV_P_00006",.F.,"") //"Adilson.moura@br.gt.com ; Fernanda.abranches@br.gt.com ; Ricardo.souza@br.gt.com;diego.grassi@br.gt.com"
		
		cSubject := "Geracao automatica de contrato"
		
		if !empty(cTo)
			EnviaEma(cHtml,cSubject,cTo)	
		endif
	 
	    //Envia email para todos os sócios e gerentes da proposta, informando que a proposta foi ganha
		EmailInc(cNum,"GANHA")
	
	endif

elseif nOpc==15	 //Informar assinatura
cObs:=""    
    
    if empty(M->Z55_DTASSI)
		Alert("Informe a data de assinatura, na aba Cadastro.")
		Return .F.    
	endif
	
	RecLock("Z55",.F.)
		Z55->Z55_DTASSI:=M->Z55_DTASSI
	Z55->(MsUnlock())
		
	cQry:=" SELECT R_E_C_N_O_ FROM "+RETSQLNAME("CN9")
	cQry+=" WHERE D_E_L_E_T_='' AND CN9_P_NUM='"+Z55->Z55_NUM+"'"
		    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
        
        	QRYTEMP->(DbGoTop())

        	While QRYTEMP->(!EOF())

        		DbSelectArea("CN9")
        		CN9->(DbGoTo(QRYTEMP->R_E_C_N_O_))
        		
        		RecLock("CN9",.F.)
        			CN9->CN9_DTPROP:=M->Z55_DTASSI
        		MsUnlock()
        	
        	QRYTEMP->(DbSkip())
        	Enddo
        
        else
			   MsgInfo("Não foi encontrado o contrato correspondente!","Aviso")        	
        endif   
    
	cObs:="[Informar assinatura] "
	cObs+="- DATA ASSINATURA - Data: "+DTOC(Z55->Z55_DTASSI)
	
	GravLog(cObs)
	
elseif nOpc==16	 //Alterar Socio/Gerente
cObs:=""    

	if empty(M->Z55_SOCIO)
		Alert("Informe o sócio, na aba Cadastro.")
		Return .F.    
	endif
	
	cObs:="[Alterar Socio/Gerente] "
	cObs+="- SOCIO ANTERIOR - Cod: "+alltrim(Z55->Z55_SOCIO)+", Nome: "+alltrim(Z55->Z55_NOMESO)
	cObs+="- SOCIO NOVO - Cod: "+alltrim(M->Z55_SOCIO)+", Nome: "+alltrim(M->Z55_NOMESO)
	cObs+="- GERENTE ANTERIOR - Cod: "+alltrim(Z55->Z55_GERENT)+", Nome: "+alltrim(Z55->Z55_NOMEGE)
	cObs+="- GERENTE NOVO - Cod: "+alltrim(M->Z55_GERENT)+", Nome: "+alltrim(M->Z55_NOMEGE)
		
	RecLock("Z55",.F.)
		Z55->Z55_GERENT	:= M->Z55_GERENT
		Z55->Z55_NOMEGE	:= M->Z55_NOMEGE
		Z55->Z55_SOCIO	:= M->Z55_SOCIO
		Z55->Z55_NOMESO	:= M->Z55_NOMESO
	Z55->(MsUnlock())
	
	GravLog(cObs)

elseif nOpc==17	//Alterar Tipo faturamento
cObs:=""    

	if empty(M->Z55_TIPOFT)
		Alert("Informe o faturamento, na aba Cadastro.")
		Return .F.    
	endif

	cTipoFat:= M->Z55_TIPOFT

    if cTipoFat=="F" //Se o tipo de faturamento for fixo, valido se os dados do pagamento estão preenchidos
    
	    //Valida se o valor da proposta é o mesmo das parcelas
	    if alltrim(cValG3_1_1)<>alltrim(cValG3_1_2) .or. Empty(cValG3_1_1) .or. Empty(cValG3_1_2) .or. ROUND(M->Z55_VLRTOT,2)<>val(StrTran(StrTran(cValG3_1_1,".",""),",","."))
			Alert("Verifique os valores na aba pagamentos, o valor da proposta deve ser o mesmo do valor das parcelas!")
	   		Return .F.    
	    endif
	
	    //Valida se as parcelas estão preenchidas corretamente
	    For nI:=1 To Len(oGetDdsVlr:aCols)
			
			//Verifica se o vencimento está preenchido
			If Empty(oGetDdsVlr:aCols[nI][2])
				Alert("Verifique a data de vencimento da parcela "+ AllTrim(Str(nI)) + ".")
	   			Return .F.  			
			EndIf
			
			//Verifica se o valor da parcela está preenchido
			If oGetDdsVlr:aCols[nI][3] <= 0
				Alert("Verifique o valor da parcela "+ AllTrim(Str(nI)) + ".")
	   			Return .F.  			
			EndIf
		Next
    
	endif

	cObs:="[Alterar Tipo Faturamento] "
	cObs+="- FATURAMENTO ANTERIOR - "+Z55->Z55_TIPOFT
	cObs+="- FATURAMENTO NOVO - "+M->Z55_TIPOFT


	RecLock("Z55",.F.)
		Z55->Z55_TIPOFT	:= M->Z55_TIPOFT
	Z55->(MsUnlock())
	
	GravLog(cObs)
      
elseif nOpc==18 //Revisão pelo Pool
nQtdAne		:= 0
lFoiAnexado	:= .F.
cNum		:= M->Z55_NUM
    
	//if xParam4<>"K"  //Verificar draft (Pool)

		DbSelectArea("Z48")
		Z48->(DbGoTop())
		DbSetOrder(1)
		DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA)
		While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==M->Z55_NUM .AND. Z48->Z48_REVISA==M->Z55_REVISA
			if Z48->Z48_TIPO=="I"
				lFoiAnexado:= .T.
				nQtdAne+=1
				//exit
			endif
			Z48->(DbSkip())
	    Enddo    			
	    
	    if UPPER(alltrim(xParam4))=="K" //Verificar draft (Pool)

			if !lFoiAnexado
				Alert("É obrigatório anexar(arquivar) o draft revisado!")
		   		Return .F.    			
			endif

		else
			    			
			if !lFoiAnexado .OR. nQtdAne<=1
				Alert("É obrigatório anexar(arquivar) a proposta revisada!")
		   		Return .F.    			
			endif
			
		endif
    //endif
	
	//Gravo a legenda e o status
	GravLege(xParam4,nOpc)

	EmailInc(cNum,"OUTPOOL")

elseif nOpc==19 //Overrun
lIncZ27:=.F.

    cNum:=Z55->Z55_NUM
    cRev:=Z55->Z55_REVISA

    nPosZ27Cod:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_CODIGO"})
    nPosZ27Dta:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_DTAINC"})
    nPosZ27Hra:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_HORAPR"})
    nPosZ27Moe:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_MOEDA"})
    nPosZ27VlL:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRLIQ"})
    nPosZ27VlT:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRTOT"})
    nPosZ27TxM:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_TAXAME"})
    nPosZ27Imp:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_IMPOST"})


    //GRAVANDO GETDADOS - Overrun

	dbSelectArea("Z27")
	Z27->(dbSetOrder(1))
	for i:=1 to len(oGetDadOve:aCols)
		if Z27->(dbSeek(Z55->Z55_FILIAL+Z55->Z55_NUM+Z55->Z55_REVISA+oGetDadOve:aCols[i][nPosZ27Cod]))	    	
        	lIncZ27:=.F.	
        else
        	lIncZ27:=.T.
        endif

		RecLock("Z27",lIncZ27)
    		if lIncZ27
	    		Z27->Z27_FILIAL	:= xFilial("Z27")
   				Z27->Z27_FILORI	:= cFilAnt
	    		Z27->Z27_NUMPRO	:= cNum
	    		Z27->Z27_REVISA	:= cRev
	    	endif
	    	
	    	for j:=1 to len(oGetDadOve:aHeader)
	    		Z27->&(oGetDadOve:aHeader[j][2]):=oGetDadOve:aCols[i][j]
	    	next	    		

		Z27->(MsUnlock())
    next

    //Gravação da tabela Z49                        l
	GravaZ49(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)

    //Email de informativo de overrun
	EmailInc(cNum,"OVERRUN")

endif

Return(.T.)
/*
Funcao      : ProxNum()  
Parametros  : cTipoCtr
Retorno     : cRet
Objetivos   : Função Retornar a sequencia disponível para a proposta
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------*
Static Function ProxNum(cTipoCtr)
*-------------------------------*
Local cRet		:=""
Local cAnoAtu	:= Right(Str(Year(Date())),2) //Retora o ano atual (2 digitos)
Local cQry		:=""
Local aCbox		:={}
Local nAt		:=""
Local nPos		:=0
Local cDescOpc	:=""
Local cSeq		:="0001"

DEFAULT cTipoCtr:=""

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("Z55_TPCTR"))
	
		cCbox := AllTrim(SX3->X3_CBOX)
		nAt := At(";",cCbox)
		While nAt > 0
			cAux  := Left(cCbox,nAt-1)
											
			aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 
											
			cCbox := Substr(cCbox,nAt+1)
			nAt := At(";",cCbox)
		EndDo
		cAux  := cCbox
		aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 			
	EndIf

	nPos := aScan(aCbox,{|a| Alltrim(a[1])== AllTrim(cTipoCtr)})
	if nPos > 0
		cDescOpc := SUBSTR(aCbox[nPos][2],1,3)
	endif
	
	/*MONTAGEM DA QUERY*/
	//cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z55_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z55")+CRLF
	//cQry+=" WHERE D_E_L_E_T_='' AND RIGHT(RTRIM(Z55_NUM),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z55_NUM),3)='"+cDescOpc+"'"

	cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z51_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z51")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND RIGHT(RTRIM(Z51_NUM),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z51_NUM),3)='"+cDescOpc+"' AND Z51_FILIAL='"+xFilial("Z51")+"'"
		
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
        	QRYTEMP->(DbGotop())
        	cSeq:=SOMA1(QRYTEMP->SEQ)
        endif

cRet:=cDescOpc+cSeq+"/"+cAnoAtu

Return(cRet)

/*
Funcao      : LEGZ55()  
Parametros  : cTipoCtr
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*--------------------*
User Function LEGZ55()
*--------------------*
/*Local aLegenda := {	{"BR_AMARELO"  	,"Pendente             	" },;
					{"BR_VERDE"    	,"Aprovado	       	  	" },;
					{"BR_AZUL"  	,"Parcialmente Aprovado	" },;
					{"BR_VERMELHO" 	,"Recusado				" },;
					{"BR_BRANCO" 	,"Revisado				" }}
*/

Local aLegenda := {	{"F6_NULL"  	,"Em Aberto            	   			" },;
					{"F14_CINZ" 	,"Revisado							" },;
					{"F12_AMAR" 	,"Pendente Aprovação GT    			" },;
					{"F7_VERM"  	,"Recusado GT						" },;
					{"F10_VERD"  	,"Aprovado GT						" },;
					{"BR_AMARELO"  	,"Pendente Aprovação Cliente		" },;
					{"BR_VERMELHO"  ,"Recusado Cliente 	  				" },;
					{"BR_LARANJA"  	,"Aprovado sem Assinatura Cliente	" },;
					{"BR_VERDE" 	,"Aprovado com Assinatura Cliente	" },;
					{"METAS_CIMA_16","Finalizado pelo gestor			" }}

BrwLegenda("Legenda","Status da Proposta",aLegenda)

Return   

/*
Funcao      : Troca  
Parametros  : nIt,aArray
Retorno     : aArray
Objetivos   : Função para trocar a Lógica do primeiro campo, (.T. / .F.), mudando assim a imagem do check
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------*
Static Function Troca(nIt,aArray)
*-------------------------------*
aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*
Funcao      : Z55_PROS
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se o prospect tem o conflito confirmado
Autor       : Matheus Massarotto
Data/Hora   : 03/07/2012
*/
*-------------------------------*
User Function Z55_PROS()
*-------------------------------*
Local lRet		:= .T.
Local cSta		:= POSICIONE("SUS",1,xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA,"US_STATUS")
Local cCodCli	:= SUS->US_CODCLI
Local cConfli	:= SUS->US_P_CONFL

if alltrim(cSta)=='6'
	Alert("Prospect já é cliente com código: "+cCodCli)
	lRet:=.F.
//elseif cConfli<>'1'
//	Alert("Prospect não tem o conflito confirmado!"+CRLF+"Por favor inclua um Draft!")
//	lRet:=.F.	
endif

If lRet
	//Carrega as empresas do grupo.
	U_CarregaZ35()
EndIf

Return lRet

/*
Funcao      : VALIDZ54
Parametros  : cAlias,cChave,nOrdem
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 17/08/2012
*/
/*
User function VALIDZ54(cAlias,cChave,nOrdem)
Local xAlias,nSalvReg,nOldOrder,lRet

If ValType(cChave) == "U"
	cChave := &(ReadVar())
EndIf

xAlias := Alias()

DbSelectArea(cAlias)
nOldOrder := IndexOrd()

If Eof() .Or. RecC() == 0
	nSalvReg := 0
Else
	nSalvReg := RecNo()
EndIf

nOrdem := If(nOrdem == NIL,1,nOrdem)
DbSetOrder(nOrdem)
lRet := DbSeek(xFilial(cAlias)+cChave)

If nSalvReg > 0
	DbGoTo(nSalvReg)
EndIf

DbSetOrder(nOldOrder)
DbSelectArea(xAlias)


Return lRet
*/
/*
Funcao      : Z54PZ80
Parametros  : cVerif
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
/*
*-------------------------------*
User Function Z54PZ80(cVerif)
*-------------------------------*
Local lRet	:=.T.

DbSelectArea("Z80")
DbSetOrder(1)
if !DbSeek(xFilial("Z80")+cVerif)
	lRet:=.F.
	alert("Verifique as opções permitidas para esta operação"+CRLF+"Clicando na lupa, ou pressionando F3.","Atenção")
endif

Return lRet
*/
/*
Funcao      : Z54VOLUME
Parametros  : 
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
/*
*---------------------*
User function Z54VOLUME
*---------------------*
Local cRet		:=""
Local nHora		:=0
Local nTotal	:=0
Local nPosVol	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_VOLUME"})
Local nPosSer	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_SERVIC"})

DbSelectArea("Z81")
DbSetOrder(1)

For i:=1 to len(aCols)
	if DbSeek(xFilial("Z81")+aCols[i][nPosSer])
		nHora	:=HTON(Z81->Z81_TEMPO)
		nTotal	+=(nHora*aCols[i][nPosVol])
	endif
Next

cRet	:=NTOH(nTotal)
M->Z55_TIME:=cRet

//para atualizar a tela com os dados novos
GetDRefresh()	

return(cRet)
*/
/*
Funcao      : ServPAcol
Parametros  : 
Retorno     : lRet
Objetivos   : Função para preencher o aCols da rotina principal com auxilio da rotina U_GTF3Z80
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*------------------------------*
Static function ServPAcol(nOpc)
*------------------------------*
Local aArray	:={}
Local nII		:="00"
Local nUsado	:=len(oGetDados:aHeader)

if nOpc<>3 .AND. nOpc<>4 .AND. nOpc<>6 
	Alert("Não é possível selecionar serviços."+CRLF+"Esta opção somente funciona quando se está incluindo, alterando ou revisando.")
	Return	
endif

if M->Z55_STATUS $ '3/5/6/7/8/9' //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
	Alert("Não é possível selecionar serviços."+CRLF+"Esta opção somente funciona quando se está incluindo, alterando ou revisando propostas com situação 'Em Aberto'.")
	Return	
endif

oTFolder:SetOption(1) //Seleciona folder desejado

aArray	:= U_GTF3Z80()  //chama rotina com os serviços para escolha.
aCols	:= oGetDados:aCols

	if len(aCols)>0
	    for u:=len(aCols) to 1 Step -1
		    
		    for v:=1 to len(aCols[u])-1
				if Alltrim(aHeader[v,2])=="Z54_SERVIC"
					if empty(aCols[u][v])
						aSize(aCols,len(aCols)-1)
					endif
				endif
			next
			
		next
	endif


if !empty(aCols)
	nII:=aCols[Len(aCols)][1]
else
	nII:="00"
	aCols:={}
endif

	for nSeqI:=1 to len(aArray)
		if !empty(aArray[nSeqI][1]) .AND. !aArray[nSeqI][len(aArray[nSeqI])]
   	
		   	AADD(aCols,Array(nUsado+1))
			nII:=SOMA1(nII)
			for nSeqJ:=1 to len(aCols[Len(aCols)])-1
				if nSeqJ==1
					aCols[Len(aCols)][nSeqJ]:=nII
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_DEPART" //nSeqJ==2 // Código do Departamento
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][5]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_DESCDE" //nSeqJ==3 // Descrição do Departamento
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][6]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_AREA" //nSeqJ==4 // Código da Área
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][3]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_DESCAR" //nSeqJ==5 // Descrição da Área
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][4]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_SERVIC" //nSeqJ==6 // Código do Serviço
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][1]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_DESCSE" //nSeqJ==7 // Descrição do Serviço
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][2]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z54_VOLUME" //nSeqJ==8 // Volume
					aCols[Len(aCols)][nSeqJ]:=0
				else
					aCols[Len(aCols)][nSeqJ]:=""
				endif
			next
			aCols[Len(aCols)][nUsado+1] := .F.
		endif

	next

oGetDados:aCols:=aCols

Return

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
Funcao      : GravaZ50
Parametros  : nOpc
Retorno     : 
Objetivos   : Função para gravar a tabela Z50
Autor       : Matheus Massarotto
Data/Hora   : 18/10/2012
*/
*-----------------------------------------*
Static Function GravaZ50(nOpc)
*-----------------------------------------*

	BEGIN TRANSACTION	
		RECLOCK("Z50",.T.)
			Z50->Z50_FILIAL	:= xFilial("Z50")
			Z50->Z50_ID		:= GETSXENUM("Z50","Z50_ID")
			Z50->Z50_PROPOS	:= Z55->Z55_NUM
			Z50->Z50_REVISA := Z55->Z55_REVISA
			Z50->Z50_DATA  	:= DATE()
			Z50->Z50_HORA   := TIME()
			Z50->Z50_PORCEN := cTexto
			Z50->Z50_MOTIVO := cMemo
			Z50->Z50_USER  	:= LOGUSERNAME()
		Z50->(MsUnLock())
		ConfirmSx8()
	END TRANSACTION 
Return

/*
Funcao      : CarregaZ50
Parametros  : nOpc,nMax,cNum,cRev
Retorno     : aRet
Objetivos   : Função para carregar a tabela Z50 e retornar um array com as informações
Autor       : Matheus Massarotto
Data/Hora   : 18/10/2012
*/
*-----------------------------------------*
Static Function CarregaZ50(nOpc,nMax,cNum,cRev)
*-----------------------------------------*
Local aRet	:= {}
Local cQry	:= ""

if nOpc==6
	cRev:=STRZERO((val(cRev)-1),3)
endif


if nOpc<>3

	cQry:=" SELECT * FROM "+RETSQLNAME("Z50")+CRLF	
	cQry+=" WHERE Z50_PROPOS='"+cNum+"' "+CRLF
	cQry+=" AND Z50_REVISA='"+cRev+"' "+CRLF
	cQry+=" AND Z50_FILIAL='"+xFilial("Z50")+"' "+CRLF
	cQry+=" AND D_E_L_E_T_='' "+CRLF

	
    //nMax==1 retorna o ultimo posiionamento da proposta
	if nMax==1
		cQry+=" AND Z50_ID=(
		cQry+=" SELECT MAX(Z50_ID) FROM "+RETSQLNAME("Z50")+CRLF
		cQry+=" WHERE Z50_PROPOS='"+cNum+"' "+CRLF
		cQry+=" AND Z50_REVISA='"+cRev+"' "+CRLF
		cQry+=" AND Z50_FILIAL='"+xFilial("Z50")+"' "+CRLF
		cQry+=" AND D_E_L_E_T_='' "+CRLF
		cQry+=")"
	endif
	
	cQry+=" ORDER BY Z50_ID "
	
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
	        
			if nRecCount >0
	        	QRYTEMP->(DbGotop())
				
				While QRYTEMP->(!EOF())
					
					AADD(aRet,{DTOC(STOD(QRYTEMP->Z50_DATA)),QRYTEMP->Z50_HORA,QRYTEMP->Z50_PORCEN,QRYTEMP->Z50_USER,QRYTEMP->Z50_MOTIVO})
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

*-----------------------------------------------------------------------------------------------------------------------------------------*
Static Function LoadPaO1(oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead,lIncDIPJ,lIncAnual,dVal,nOpc)
*-----------------------------------------------------------------------------------------------------------------------------------------*
Local nVal	 	:= 0
Local nTotVal	:= 0

DEFAULT lIncDIPJ	:= .F.
DEFAULT lIncAnual	:= .F.

if nOpc==6 //Se for revisar
	if len(oQual1:aCols)>0
		if oQual1:aCols[len(oQual1:aCols)][1]==cValG3_1_4 //Se a quantidade de parcelas no getdados for igual ao campo de parcelas
			Return
		endif
    endif
endif

oQual1:aCols	:= {}

nVal := StrTran(cValAux,".","")
nVal := StrTran(nVal,",",".")
nVal := Val(nVal)/val(cValG3_1_4)

	if val(cValG3_1_4)<>0
		for i:=1 to val(cValG3_1_4)
			AADD(oQual1:aCols,{cvaltochar(i), CTOD("//"),nVal,.F. })
			nTotVal+=nVal
		next

		if lUsaVlrDip
			oCombo_1_7:Enable()
		endif
		if lUsaVlrAno
			oCombo_1_8:Enable()
		endif
	else
		if lUsaVlrDip
			oCombo_1_7:Enable()
		endif
		if lUsaVlrAno
			oCombo_1_8:Enable()
		endif
		oQual1:aCols:={}
	endif

cValG3_1_2:=Transform(nTotVal,'@E 99,999,999,999.99')

//Tratamento para adicionar o valor de dipj ou anual no valor total para parcelamento
if lIncDIPJ .AND. lIncAnual
							//Z55_VALOR
	//cValG3_1_1:=Transform(M->Z55_VLRLIS+M->Z55_VLDIPJ+M->Z55_VLRANO,'@E 99,999,999,999.99')
	cValG3_1_1:=Transform(M->Z55_VLRLTOT+M->Z55_VLDIPJ+M->Z55_VLRANO,'@E 99,999,999,999.99')
elseif lIncDIPJ .AND. !lIncAnual
							//Z55_VALOR
	//cValG3_1_1:=Transform(M->Z55_VLRLIS+M->Z55_VLDIPJ,'@E 99,999,999,999.99')
	cValG3_1_1:=Transform(M->Z55_VLRTOT+M->Z55_VLDIPJ,'@E 99,999,999,999.99')
elseif !lIncDIPJ .AND. lIncAnual
							//Z55_VALOR
	//cValG3_1_1:=Transform(M->Z55_VLRLIS+M->Z55_VLRANO,'@E 99,999,999,999.99')
	cValG3_1_1:=Transform(M->Z55_VLRTOT+M->Z55_VLRANO,'@E 99,999,999,999.99')
else
							//Z55_VALOR
	//cValG3_1_1:=Transform(M->Z55_VLRLIS,'@E 99,999,999,999.99')
	cValG3_1_1:=Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99')
endif


oQual1:Refresh()
oSayG3_1_1:Refresh()
oSayG3_1_2:Refresh()

CarregaDia(cVal,oGetDad,aHead,dVal)

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
Static Function LoadPaO2(oQual1,cValG3_2_4,cValAux,oSayG3_2_1,cValG3_2_1,cValG3_2_2,oSayG3_2_2,cVal,oGetDad,aHead,dVal)
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

cValG3_2_1:=Transform(M->Z55_VLRIMP,'@E 99,999,999,999.99')

oQual1:Refresh()
oSayG3_2_1:Refresh()
oSayG3_2_2:Refresh()

CarregaDia(cVal,oGetDad,aHead,dVal)

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
Static Function LoadPaO3(oQual1,cValG3_3_4,cValAux,oSayG3_3_1,cValG3_3_1,cValG3_3_2,oSayG3_3_2,cVal,oGetDad,aHead,dVal)
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

cValG3_3_1:=Transform(M->Z55_VLDIPJ,'@E 99,999,999,999.99')

oQual1:Refresh()
if lUsaVlrDip
	oSayG3_3_1:Refresh()
	oSayG3_3_2:Refresh()
endif

CarregaDia(cVal,oGetDad,aHead,dVal)

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
Static Function LoadPaO4(oQual1,cValG3_4_4,cValAux,oSayG3_4_1,cValG3_4_1,cValG3_4_2,oSayG3_4_2,cVal,oGetDad,aHead,dVal)
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

cValG3_4_1:=Transform(M->Z55_VLRANO,'@E 99,999,999,999.99')

oQual1:Refresh()

if lUsaVlrAno
	oSayG3_4_1:Refresh()
	oSayG3_4_2:Refresh()
endif

CarregaDia(cVal,oGetDad,aHead,dVal)

Return

/*
Funcao      : CarregaDia
Parametros  : cVal,oGetDad,aHead
Retorno     : lRet
Objetivos   : Função para preencher as datas de vencimento no aCols
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/

*-----------------------------------------------------------*
Static Function CarregaDia(cVal,oGetDad,aHead,dDataIni,nOpc)
*-----------------------------------------------------------*
Local lRet	:= .F.
Local nVal	:= val(cVal)
Local nPos	:= Ascan(aHead,{|x| alltrim(x[2]) = "M_VENC"})
Local dDate	:= CTOD("//")

DEFAULT dDataIni:= CTOD("//")
DEFAULT nOpc	:= 0

if !empty(cVal) .AND. alltrim(cVal)<>"0"
	if nVal>0 .AND. nVal<32
		lRet:=.T.
	else
		alert("Dia inválido!")
	endif
else
	if alltrim(cVal)<>"0"
		lRet:=.T.
	endif
endif
/*
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
*/


if lRet .AND. nPos<>0 //Se o dia for válido e o campo do acols for o de vencimento 

	if nOpc==6 //Se for revisar
		if len(oGetDad:aCols)>0
			if oGetDad:aCols[1][nPos]==dDataIni //Se o data inicial no getdados for igual ao campo de data inicial
				Return(lRet)
			endif
	    endif
	endif
	
 //  	if dDataIni<dDataBase //se o dia for menor que o dia da database somo 1 mês na primeira data
 //	   	if val(cVal)>30
 //	   		dDate:= LastDay(CTOD("01"+"/"+STRZERO(Month(MonthSum(dDataIni,1)),2)+"/"+cvaltochar(YEAR(MonthSum(dDataIni,1))) ))
 //  		else
 //	   		if Month(MonthSum(dDataIni,1))==2 .AND. val(cVal)>28 //Se a próxima data do sistema for fevereiro e o dia setado for maior que 28
 //				dDate:=LastDay(CTOD("01"+"/"+STRZERO(Month(MonthSum(dDataIni,1)),2)+"/"+cvaltochar(YEAR(MonthSum(dDataIni,1))) ))
 //  		    else
 //		   		dDate:= CTOD(cVal+"/"+STRZERO(Month(MonthSum(dDataIni,1)),2)+"/"+cvaltochar(YEAR(MonthSum(dDataIni,1))) )   		    
 //  		    endif
 //  		endif
 //  	else	//se o dia for maior que o dia da database não somo 1 mês na primeira data
	   	if val(cVal)>30
    		dDate:= LastDay(CTOD("01"+"/"+STRZERO(Month(dDataIni),2)+"/"+cvaltochar(YEAR(MonthSum(dDataIni,1))) ))
		else
			if Month(dDataIni)==2 .AND. val(cVal)>28 //Se a data do sistema ja for fevereiro e o dia setado for maior que 28
				dDate:=LastDay(CTOD("01"+"/"+STRZERO(Month(dDataIni),2)+"/"+cvaltochar(YEAR(MonthSum(dDataIni,1))) ))
			elseif Month(dDataIni)==12
			    dDate:= CTOD(cVal+"/"+STRZERO(Month(dDataIni),2)+"/"+cvaltochar(YEAR(dDataIni,1)) )
			else
				dDate:= CTOD(cVal+"/"+STRZERO(Month(dDataIni),2)+"/"+cvaltochar(YEAR(MonthSum(dDataIni,1))) )
			endif
	    endif
 //  	endif

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

if alltrim(cVal)=="0"
	lRet:=.T.
endif

oGetDad:Refresh()
Return(lRet)

/*
Funcao      : I_FG73O1
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, valor da proposta
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 1
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG73O1
*---------------------*
Local lRet		:= .T.
Local nPos		:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VALOR"})
Local nVlr		:= 0
Local cValAux	:= ''

if oGetDdsVlr:OBrowse:ColPos==nPos

	for i:=1 to len(oGetDdsVlr:Acols)
		if oGetDdsVlr:nAt==i
			nVlr+=M->M_VALOR
		else
			nVlr+=oGetDdsVlr:Acols[i][nPos]			
		endif
	next
	
    cValAux:=Transform(nVlr,'@E 99,999,999,999.99')
    
	//Verifico se o valor das parcelas é maior que o da proposta
	if val(Strtran(Strtran(cValAux,"."),",","."))>val(Strtran(Strtran(cValG3_1_1,"."),",","."))
		Alert("Valor das parcelas ultrapassa valor da proposta!"+CRLF+Alltrim(cValAux))
		lRet:=.F.
	else
		cValG3_1_2:=Transform(nVlr,'@E 99,999,999,999.99')
		oSayG3_1_2:Refresh()	
	endif

endif

Return(lRet)

/*
Funcao      : I_FG73O2
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, Valor da implantação
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 2
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG73O2
*---------------------*
Local lRet		:= .T.
Local nPos		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
Local nVlr		:= 0
Local cValAux	:= ''

if oGetDdsImp:OBrowse:ColPos==nPos

	for i:=1 to len(oGetDdsImp:Acols)
		if oGetDdsImp:nAt==i
			nVlr+=M->M_VALOR
		else
			nVlr+=oGetDdsImp:Acols[i][nPos]			
		endif
	next
	
    cValAux:=Transform(nVlr,'@E 99,999,999,999.99')
    
	//Verifico se o valor das parcelas é maior que o da implantação
	if val(Strtran(Strtran(cValAux,"."),",","."))>val(Strtran(Strtran(cValG3_2_1,"."),",","."))
		Alert("Valor das parcelas ultrapassa valor da impantação!"+CRLF+Alltrim(cValAux))
		lRet:=.F.
	else
		cValG3_2_2:=Transform(nVlr,'@E 99,999,999,999.99')
		oSayG3_2_2:Refresh()	
	endif

endif

Return(lRet)

/*
Funcao      : I_FG73O3
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, Valor de DIPJ
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 3
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG73O3
*---------------------*
Local lRet		:= .T.
Local nPos		:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VALOR"})
Local nVlr		:= 0
Local cValAux	:= ''

if oGetDdsDip:OBrowse:ColPos==nPos

	for i:=1 to len(oGetDdsDip:Acols)
		if oGetDdsDip:nAt==i
			nVlr+=M->M_VALOR
		else
			nVlr+=oGetDdsDip:Acols[i][nPos]			
		endif
	next
	
    cValAux:=Transform(nVlr,'@E 99,999,999,999.99')
    
	//Verifico se o valor das parcelas é maior que o da implantação
	if val(Strtran(Strtran(cValAux,"."),",","."))>val(Strtran(Strtran(cValG3_3_1,"."),",","."))
		Alert("Valor das parcelas ultrapassa valor de DIPJ!"+CRLF+Alltrim(cValAux))
		lRet:=.F.
	else
		cValG3_3_2:=Transform(nVlr,'@E 99,999,999,999.99')
		oSayG3_3_2:Refresh()	
	endif

endif

Return(lRet)

/*
Funcao      : I_FG73O4
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, Valor Anual
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 4
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG73O4
*---------------------*
Local lRet		:= .T.
Local nPos		:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VALOR"})
Local nVlr		:= 0
Local cValAux	:= ''

if oGetDdsAno:OBrowse:ColPos==nPos

	for i:=1 to len(oGetDdsAno:Acols)
		if oGetDdsAno:nAt==i
			nVlr+=M->M_VALOR
		else
			nVlr+=oGetDdsAno:Acols[i][nPos]			
		endif
	next
	
    cValAux:=Transform(nVlr,'@E 99,999,999,999.99')
    
	//Verifico se o valor das parcelas é maior que o da implantação
	if val(Strtran(Strtran(cValAux,"."),",","."))>val(Strtran(Strtran(cValG3_4_1,"."),",","."))
		Alert("Valor das parcelas ultrapassa valor da Anuidade!"+CRLF+Alltrim(cValAux))
		lRet:=.F.
	else
		cValG3_4_2:=Transform(nVlr,'@E 99,999,999,999.99')
		oSayG3_4_2:Refresh()	
	endif

endif

Return(lRet)

/*
Funcao      : I_FG73O5
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, valor de overrun
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 73 Objeto de overrun
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2014
*/
              
*---------------------*
User function I_FG73O5
*---------------------*
Local lRet		:= .T.
Local nPos		:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VALOR"})
Local nVlr		:= 0
Local cValAux	:= ''

if oGetDdsOve:OBrowse:ColPos==nPos

	for i:=1 to len(oGetDdsOve:Acols)
		if oGetDdsOve:nAt==i
			nVlr+=M->M_VALOR
		else
			nVlr+=oGetDdsOve:Acols[i][nPos]			
		endif
	next
	
    cValAux:=Transform(nVlr,'@E 99,999,999,999.99')
    
	//Verifico se o valor das parcelas é maior que o da proposta
	if val(Strtran(Strtran(cValAux,"."),",","."))>val(Strtran(Strtran(cValGOve_1,"."),",","."))
		Alert("Valor das parcelas ultrapassa valor de overrun!"+CRLF+Alltrim(cValAux))
		lRet:=.F.
	else
		cValGOve_2:=Transform(nVlr,'@E 99,999,999,999.99')
		oSayGOve_2:Refresh()	
	endif

endif

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
Static Function AddDipjAnual(x,y,oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead,dVal)
*------------------------------------------------------------------------------------------------------------------------*
Local nValAux
Local lDipj		:= IIF(Alltrim(UPPER(x))=="SIM",.T.,.F.)
Local lAnual	:= IIF(Alltrim(UPPER(y))=="SIM",.T.,.F.)

	if lDipj .AND. lAnual
		nValAux:=val(StrTran(cValAux,"."))+M->Z55_VLDIPJ+M->Z55_VLRANO
		
		//Zerando Valores do quadro  3- DIPJ
			cValG3_3_1:=0
			cValG3_3_2:=0	
			if lUsaVlrDip
				oSayG3_3_1:Refresh()
				oSayG3_3_2:Refresh()
				oSayG3_3_1:Disable()
				oSayG3_3_2:Disable()	
			endif
						
			cValG3_3_4:=space(3)
			oSayG3_3_4:Refresh()
			oSayG3_3_4:Disable()
			
			cValG3_3_6:=CTOD("//")//space(2)
			oSayG3_3_6:Refresh()
			oSayG3_3_6:Disable()
		
			oGetDdsDip:Acols:={}
			oGetDdsDip:Refresh()
			oGetDdsDip:Disable()
			
		//Zerando Valores do quadro  4- Anual
			cValG3_4_1:=0
			cValG3_4_2:=0	

			if lUsaVlrAno
				oSayG3_4_1:Refresh()
				oSayG3_4_2:Refresh()
				oSayG3_4_1:Disable()
				oSayG3_4_2:Disable()	
			endif
						
			cValG3_4_4:=space(3)
			oSayG3_4_4:Refresh()
			oSayG3_4_4:Disable()
			
			cValG3_4_6:=CTOD("//")//space(2)
			oSayG3_4_6:Refresh()
			oSayG3_4_6:Disable()
		
			oGetDdsAno:Acols:={}
			oGetDdsAno:Refresh()
			oGetDdsAno:Disable()
					
	elseif lDipj .AND. !lAnual
		nValAux:=val(StrTran(cValAux,"."))+M->Z55_VLDIPJ
	    
		//Zerando Valores do quadro  3- DIPJ
			cValG3_3_1:=0
			cValG3_3_2:=0	
			if lUsaVlrDip
				oSayG3_3_1:Refresh()
				oSayG3_3_2:Refresh()
				oSayG3_3_1:Disable()
				oSayG3_3_2:Disable()	
			endif
			
			cValG3_3_4:=space(3)
			oSayG3_3_4:Refresh()
			oSayG3_3_4:Disable()
			
			cValG3_3_6:=CTOD("//")//space(2)
			oSayG3_3_6:Refresh()
			oSayG3_3_6:Disable()
		
			oGetDdsDip:Acols:={}
			oGetDdsDip:Refresh()
			oGetDdsDip:Disable()
			
		//Liberando manipulação dos valores do quadro  4- Anual
			if lUsaVlrAno
				oSayG3_4_1:Enable()
				oSayG3_4_2:Enable()	
				oSayG3_4_4:Enable()
				oSayG3_4_6:Enable()
				oGetDdsAno:Enable()		
			endif
						
	elseif !lDipj .AND. lAnual
		nValAux:=val(StrTran(cValAux,"."))+M->Z55_VLRANO
		
		//Zerando Valores do quadro  4- Anual
			cValG3_4_1:=0
			cValG3_4_2:=0	

			if lUsaVlrAno
				oSayG3_4_1:Refresh()
				oSayG3_4_2:Refresh()
				oSayG3_4_1:Disable()
				oSayG3_4_2:Disable()	
			endif			

			cValG3_4_4:=space(3)
			oSayG3_4_4:Refresh()
			oSayG3_4_4:Disable()
			
			cValG3_4_6:=CTOD("//")//space(2)
			oSayG3_4_6:Refresh()
			oSayG3_4_6:Disable()
		
			oGetDdsAno:Acols:={}
			oGetDdsAno:Refresh()
			oGetDdsAno:Disable()		
			
		//Liberando manipulação dos valores do quadro  3- DIPJ
			if lUsaVlrDip
				oSayG3_3_1:Enable()
				oSayG3_3_2:Enable()	
				oSayG3_3_4:Enable()
				oSayG3_3_6:Enable()
				oGetDdsDip:Enable()		
		    endif
		    
	else
		nValAux:=val(StrTran(cValAux,"."))
		
		//Liberando manipulação dos valores do quadro  3- DIPJ
			if lUsaVlrDip
				oSayG3_3_1:Enable()
				oSayG3_3_2:Enable()	
				oSayG3_3_4:Enable()
				oSayG3_3_6:Enable()
				oGetDdsDip:Enable()
			endif
				
		//Liberando manipulação dos valores do quadro  4- Anual
		if lUsaVlrAno
			oSayG3_4_1:Enable()
			oSayG3_4_2:Enable()	
			oSayG3_4_4:Enable()
			oSayG3_4_6:Enable()
			oGetDdsAno:Enable()		
		endif
	endif
		
	cValAux:=Transform(nValAux,'@E 99,999,999,999.99')
	//Se for sim o parametro 11 deve ser passado para a função como .T.
	LoadPaO1(oQual1,cValG3_1_4,cValAux,@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,@oSayG3_1_2,cVal,oGetDad,aHead,lDipj,lAnual,dVal)

Return

/*
Funcao      : GravaZ49
Parametros  : 
Retorno     : 
Objetivos   : Função para adicionar gravar/alterar tabelaZ49
Autor       : Matheus Massarotto
Data/Hora   : 12/11/2012
*/

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Static Function GravaZ49(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRevisao,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*

if nOpc==3 //Inclusão
	Begin Transaction
		// Proposta
		nPosParc	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_PARC"})
		nPosVenc	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VENC"})
		nPosVlr		:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VALOR"})
		lIncDIPJ69	:= IIF(Alltrim(UPPER(cCombo_1_7))=="SIM",.T.,.F.)
		lIncANO69	:= IIF(Alltrim(UPPER(cCombo_1_8))=="SIM",.T.,.F.)
				
		if !empty(oGetDdsVlr:Acols)
		    for nW:=1 to len(oGetDdsVlr:Acols)
		    	if empty(oGetDdsVlr:Acols[nW][1])
		    	   loop
		    	else
		    		RecLock("Z49",.T.)
			    		Z49->Z49_FILIAL	:= xFilial("Z49")
			    		Z49->Z49_PROPOS	:= cNum
			    		Z49->Z49_REVISA	:= "000"
			    		Z49->Z49_TIPO	:= "PROPOSTA"
			    		Z49->Z49_PARCEL	:= oGetDdsVlr:Acols[nW][nPosParc]
			    		Z49->Z49_VENCTO	:= oGetDdsVlr:Acols[nW][nPosVenc]
			    		Z49->Z49_VALOR	:= oGetDdsVlr:Acols[nW][nPosVlr]
			    		Z49->Z49_INCDIP	:= IIF(lIncDIPJ69,"S","N")
			    		Z49->Z49_INCANO	:= IIF(lIncANO69,"S","N")
			    		Z49->Z49_DTINC	:= dDataBase
			    		Z49->Z49_DIAVEN	:= cValG3_1_6
			    	Z49->(MsUnLock())
		    	endif
		    next
			
		endif
		
		if lUsaVlrImp
			//Implantação
			nPosParc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_PARC"})
			nPosVenc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
			nPosVlr		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
					
			if !empty(oGetDdsImp:Acols)
			    for nW:=1 to len(oGetDdsImp:Acols)
			    	if empty(oGetDdsImp:Acols[nW][1])
			    	   loop
			    	else
			    		RecLock("Z49",.T.)
				    		Z49->Z49_FILIAL	:= xFilial("Z49")
				    		Z49->Z49_PROPOS	:= cNum
				    		Z49->Z49_REVISA	:= "000"
				    		Z49->Z49_TIPO	:= "IMPLANTACAO"
				    		Z49->Z49_PARCEL	:= oGetDdsImp:Acols[nW][nPosParc]
				    		Z49->Z49_VENCTO	:= oGetDdsImp:Acols[nW][nPosVenc]
				    		Z49->Z49_VALOR	:= oGetDdsImp:Acols[nW][nPosVlr]
				    		Z49->Z49_INCDIP	:= ""
				    		Z49->Z49_INCANO	:= ""
				    		Z49->Z49_DTINC	:= dDataBase
				    		Z49->Z49_DIAVEN	:= cValG3_2_6
						Z49->(MsUnlock())
			    	endif
			    next
				
			endif	
		    
		endif
		
		if lUsaVlrDip
			//Dipj	
			if !lIncDIPJ69 //Se já não foi incluido no valor da proposta
		
				nPosParc	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_PARC"})
				nPosVenc	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VENC"})
				nPosVlr		:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VALOR"})
						
				if !empty(oGetDdsDip:Acols)
				    for nW:=1 to len(oGetDdsDip:Acols)
				    	if empty(oGetDdsDip:Acols[nW][1])
				    	   loop
				    	else
				    		RecLock("Z49",.T.)
					    		Z49->Z49_FILIAL	:= xFilial("Z49")
					    		Z49->Z49_PROPOS	:= cNum
					    		Z49->Z49_REVISA	:= "000"
					    		Z49->Z49_TIPO	:= "DIPJ"
					    		Z49->Z49_PARCEL	:= oGetDdsDip:Acols[nW][nPosParc]
					    		Z49->Z49_VENCTO	:= oGetDdsDip:Acols[nW][nPosVenc]
					    		Z49->Z49_VALOR	:= oGetDdsDip:Acols[nW][nPosVlr]
					    		Z49->Z49_INCDIP	:= ""
					    		Z49->Z49_INCANO	:= ""
					    		Z49->Z49_DTINC	:= dDataBase
					    		Z49->Z49_DIAVEN	:= cValG3_3_6
							Z49->(MsUnlock())
				    	endif
				    next
					
				endif
			
			endif
	    endif
	    
	    if lUsaVlrAno
			//Anual	
			if !lIncAno69 //Se já não foi incluido no valor da proposta
		
				nPosParc	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_PARC"})
				nPosVenc	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VENC"})
				nPosVlr		:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VALOR"})
						
				if !empty(oGetDdsAno:Acols)
				    for nW:=1 to len(oGetDdsAno:Acols)
				    	if empty(oGetDdsAno:Acols[nW][1])
				    	   loop
				    	else
				    		RecLock("Z49",.T.)
					    		Z49->Z49_FILIAL	:= xFilial("Z49")
					    		Z49->Z49_PROPOS	:= cNum
					    		Z49->Z49_REVISA	:= "000"
					    		Z49->Z49_TIPO	:= "ANUAL"
					    		Z49->Z49_PARCEL	:= oGetDdsAno:Acols[nW][nPosParc]
					    		Z49->Z49_VENCTO	:= oGetDdsAno:Acols[nW][nPosVenc]
					    		Z49->Z49_VALOR	:= oGetDdsAno:Acols[nW][nPosVlr]
					    		Z49->Z49_INCDIP	:= ""
					    		Z49->Z49_INCANO	:= ""
					    		Z49->Z49_DTINC	:= dDataBase
					    		Z49->Z49_DIAVEN	:= cValG3_4_6
							Z49->(MsUnlock())
				    	endif
				    next
					
				endif
			endif	
		endif
	    
	End Transaction

elseif nOpc==6 //Revisar
	Begin Transaction
		// Proposta
		nPosParc	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_PARC"})
		nPosVenc	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VENC"})
		nPosVlr		:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VALOR"})
		lIncDIPJ69	:= IIF(Alltrim(UPPER(cCombo_1_7))=="SIM",.T.,.F.)
		lIncANO69	:= IIF(Alltrim(UPPER(cCombo_1_8))=="SIM",.T.,.F.)
				
		if !empty(oGetDdsVlr:Acols)
		    for nW:=1 to len(oGetDdsVlr:Acols)
		    	if empty(oGetDdsVlr:Acols[nW][1])
		    	   loop
		    	else
		    		RecLock("Z49",.T.)
			    		Z49->Z49_FILIAL	:= xFilial("Z49")
			    		Z49->Z49_PROPOS	:= cNum
			    		Z49->Z49_REVISA	:= cRevisao
			    		Z49->Z49_TIPO	:= "PROPOSTA"
			    		Z49->Z49_PARCEL	:= oGetDdsVlr:Acols[nW][nPosParc]
			    		Z49->Z49_VENCTO	:= oGetDdsVlr:Acols[nW][nPosVenc]
			    		Z49->Z49_VALOR	:= oGetDdsVlr:Acols[nW][nPosVlr]
			    		Z49->Z49_INCDIP	:= IIF(lIncDIPJ69,"S","N")
			    		Z49->Z49_INCANO	:= IIF(lIncANO69,"S","N")
			    		Z49->Z49_DTINC	:=	dDataBase
			    		Z49->Z49_DIAVEN	:= cValG3_1_6
			    	Z49->(MsUnLock())
		    	endif
		    next
			
		endif
		
		if lUsaVlrImp
			//Implantação
			nPosParc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_PARC"})
			nPosVenc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
			nPosVlr		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
					
			if !empty(oGetDdsImp:Acols)
			    for nW:=1 to len(oGetDdsImp:Acols)
			    	if empty(oGetDdsImp:Acols[nW][1])
			    	   loop
			    	else
			    		RecLock("Z49",.T.)
				    		Z49->Z49_FILIAL	:= xFilial("Z49")
				    		Z49->Z49_PROPOS	:= cNum
				    		Z49->Z49_REVISA	:= cRevisao
				    		Z49->Z49_TIPO	:= "IMPLANTACAO"
				    		Z49->Z49_PARCEL	:= oGetDdsImp:Acols[nW][nPosParc]
				    		Z49->Z49_VENCTO	:= oGetDdsImp:Acols[nW][nPosVenc]
				    		Z49->Z49_VALOR	:= oGetDdsImp:Acols[nW][nPosVlr]
				    		Z49->Z49_INCDIP	:= ""
				    		Z49->Z49_INCANO	:= ""
				    		Z49->Z49_DTINC	:= dDataBase
				    		Z49->Z49_DIAVEN	:= cValG3_2_6
						Z49->(MsUnlock())
			    	endif
			    next
				
			endif	
	    endif
	    
	    
	    if lUsaVlrDip
			//Dipj	
			if !lIncDIPJ69 //Se já não foi incluido no valor da proposta
		
				nPosParc	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_PARC"})
				nPosVenc	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VENC"})
				nPosVlr		:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VALOR"})
						
				if !empty(oGetDdsDip:Acols)
				    for nW:=1 to len(oGetDdsDip:Acols)
				    	if empty(oGetDdsDip:Acols[nW][1])
				    	   loop
				    	else
				    		RecLock("Z49",.T.)
					    		Z49->Z49_FILIAL	:= xFilial("Z49")
					    		Z49->Z49_PROPOS	:= cNum
					    		Z49->Z49_REVISA	:= cRevisao
					    		Z49->Z49_TIPO	:= "DIPJ"
					    		Z49->Z49_PARCEL	:= oGetDdsDip:Acols[nW][nPosParc]
					    		Z49->Z49_VENCTO	:= oGetDdsDip:Acols[nW][nPosVenc]
					    		Z49->Z49_VALOR	:= oGetDdsDip:Acols[nW][nPosVlr]
					    		Z49->Z49_INCDIP	:= ""
					    		Z49->Z49_INCANO	:= ""
					    		Z49->Z49_DTINC	:= dDataBase
					    		Z49->Z49_DIAVEN	:= cValG3_3_6
							Z49->(MsUnlock())
				    	endif
				    next
					
				endif
			
			endif
			
	    endif
	    
	    if lUsaVlrAno
			//Anual	
			if !lIncAno69 //Se já não foi incluido no valor da proposta
				nPosParc	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_PARC"})
				nPosVenc	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VENC"})
				nPosVlr		:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VALOR"})
						
				if !empty(oGetDdsAno:Acols)
				    for nW:=1 to len(oGetDdsAno:Acols)
				    	if empty(oGetDdsAno:Acols[nW][1])
				    	   loop
				    	else
				    		RecLock("Z49",.T.)
					    		Z49->Z49_FILIAL	:= xFilial("Z49")
					    		Z49->Z49_PROPOS	:= cNum
					    		Z49->Z49_REVISA	:= cRevisao
					    		Z49->Z49_TIPO	:= "ANUAL"
					    		Z49->Z49_PARCEL	:= oGetDdsAno:Acols[nW][nPosParc]
					    		Z49->Z49_VENCTO	:= oGetDdsAno:Acols[nW][nPosVenc]
					    		Z49->Z49_VALOR	:= oGetDdsAno:Acols[nW][nPosVlr]
					    		Z49->Z49_INCDIP	:= ""
					    		Z49->Z49_INCANO	:= ""
					    		Z49->Z49_DTINC	:= dDataBase
					    		Z49->Z49_DIAVEN	:= cValG3_4_6
							Z49->(MsUnlock())
				    	endif
				    next
				endif
			endif
		endif
	End Transaction

elseif nOpc==4 //Alterar
    
	//Apagando a informação 
	cQryDel:=" DELETE FROM "+RETSQLNAME("Z49")
	cQryDel+=" WHERE Z49_FILIAL='"+xFilial("Z49")+"' AND Z49_PROPOS='"+cNum+"' AND Z49_REVISA='"+cRevisao+"'
    
	if TcSqlExec(cQryDel)>=0
		Begin Transaction
			// Proposta
			nPosParc	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_PARC"})
			nPosVenc	:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VENC"})
			nPosVlr		:= Ascan(aHeadVlr,{|x| alltrim(x[2]) = "M_VALOR"})
			lIncDIPJ69	:= IIF(Alltrim(UPPER(cCombo_1_7))=="SIM",.T.,.F.)
			lIncANO69	:= IIF(Alltrim(UPPER(cCombo_1_8))=="SIM",.T.,.F.)
					
			if !empty(oGetDdsVlr:Acols)
			    for nW:=1 to len(oGetDdsVlr:Acols)
			    	if empty(oGetDdsVlr:Acols[nW][1])
			    	   loop
			    	else
			    		RecLock("Z49",.T.)
				    		Z49->Z49_FILIAL	:= xFilial("Z49")
				    		Z49->Z49_PROPOS	:= cNum
				    		Z49->Z49_REVISA	:= cRevisao
				    		Z49->Z49_TIPO	:= "PROPOSTA"
				    		Z49->Z49_PARCEL	:= oGetDdsVlr:Acols[nW][nPosParc]
				    		Z49->Z49_VENCTO	:= oGetDdsVlr:Acols[nW][nPosVenc]
				    		Z49->Z49_VALOR	:= oGetDdsVlr:Acols[nW][nPosVlr]
				    		Z49->Z49_INCDIP	:= IIF(lIncDIPJ69,"S","N")
				    		Z49->Z49_INCANO	:= IIF(lIncANO69,"S","N")
				    		Z49->Z49_DTINC	:=	dDataBase
				    		Z49->Z49_DIAVEN	:= cValG3_1_6
				    	Z49->(MsUnLock())
			    	endif
			    next
				
			endif
			
			if lUsaVlrImp
				//Implantação
				nPosParc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_PARC"})
				nPosVenc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
				nPosVlr		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
						
				if !empty(oGetDdsImp:Acols)
				    for nW:=1 to len(oGetDdsImp:Acols)
				    	if empty(oGetDdsImp:Acols[nW][1])
				    	   loop
				    	else
				    		RecLock("Z49",.T.)
					    		Z49->Z49_FILIAL	:= xFilial("Z49")
					    		Z49->Z49_PROPOS	:= cNum
					    		Z49->Z49_REVISA	:= cRevisao
					    		Z49->Z49_TIPO	:= "IMPLANTACAO"
					    		Z49->Z49_PARCEL	:= oGetDdsImp:Acols[nW][nPosParc]
					    		Z49->Z49_VENCTO	:= oGetDdsImp:Acols[nW][nPosVenc]
					    		Z49->Z49_VALOR	:= oGetDdsImp:Acols[nW][nPosVlr]
					    		Z49->Z49_INCDIP	:= ""
					    		Z49->Z49_INCANO	:= ""
					    		Z49->Z49_DTINC	:= dDataBase
					    		Z49->Z49_DIAVEN	:= cValG3_2_6
							Z49->(MsUnlock())
				    	endif
				    next
					
				endif	
		    endif
		    
		    if lUsaVlrDip
				//Dipj	
				if !lIncDIPJ69 //Se já não foi incluido no valor da proposta
					nPosParc	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_PARC"})
					nPosVenc	:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VENC"})
					nPosVlr		:= Ascan(aHeadDip,{|x| alltrim(x[2]) = "M_VALOR"})
							
					if !empty(oGetDdsDip:Acols)
					    for nW:=1 to len(oGetDdsDip:Acols)
					    	if empty(oGetDdsDip:Acols[nW][1])
					    	   loop
					    	else
					    		RecLock("Z49",.T.)
						    		Z49->Z49_FILIAL	:= xFilial("Z49")
						    		Z49->Z49_PROPOS	:= cNum
						    		Z49->Z49_REVISA	:= cRevisao
						    		Z49->Z49_TIPO	:= "DIPJ"
						    		Z49->Z49_PARCEL	:= oGetDdsDip:Acols[nW][nPosParc]
						    		Z49->Z49_VENCTO	:= oGetDdsDip:Acols[nW][nPosVenc]
						    		Z49->Z49_VALOR	:= oGetDdsDip:Acols[nW][nPosVlr]
						    		Z49->Z49_INCDIP	:= ""
						    		Z49->Z49_INCANO	:= ""
						    		Z49->Z49_DTINC	:= dDataBase
						    		Z49->Z49_DIAVEN	:= cValG3_3_6
								Z49->(MsUnlock())
					    	endif
					    next
						
					endif
				
				endif
		    endif
		    
		    if lUsaVlrAno
				//Anual	
				if !lIncAno69 //Se já não foi incluido no valor da proposta
					nPosParc	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_PARC"})
					nPosVenc	:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VENC"})
					nPosVlr		:= Ascan(aHeadAno,{|x| alltrim(x[2]) = "M_VALOR"})
							
					if !empty(oGetDdsAno:Acols)
					    for nW:=1 to len(oGetDdsAno:Acols)
					    	if empty(oGetDdsAno:Acols[nW][1])
					    	   loop
					    	else
					    		RecLock("Z49",.T.)
						    		Z49->Z49_FILIAL	:= xFilial("Z49")
						    		Z49->Z49_PROPOS	:= cNum
						    		Z49->Z49_REVISA	:= cRevisao
						    		Z49->Z49_TIPO	:= "ANUAL"
						    		Z49->Z49_PARCEL	:= oGetDdsAno:Acols[nW][nPosParc]
						    		Z49->Z49_VENCTO	:= oGetDdsAno:Acols[nW][nPosVenc]
						    		Z49->Z49_VALOR	:= oGetDdsAno:Acols[nW][nPosVlr]
						    		Z49->Z49_INCDIP	:= ""
						    		Z49->Z49_INCANO	:= ""
						    		Z49->Z49_DTINC	:= dDataBase
						    		Z49->Z49_DIAVEN	:= cValG3_4_6
								Z49->(MsUnlock())
					    	endif
					    next
					endif
				endif
		    endif
		End Transaction
	
	else
		Alert("Não foi possível salvar a aba pagamentos!")
	endif	

elseif nOpc==19 //Overrun
	aCodOver := {}
	cQryDel := " Select *
	cQryDel += " From "+RETSQLNAME("Z49")
	cQryDel += " Where Z49_FILIAL = '"+xFilial("Z49")+"' 
	cQryDel += "	AND Z49_PROPOS = '"+cNum+"'
	cQryDel += "	AND Z49_REVISA = '"+cRevisao+"'
	cQryDel += "	AND Z49_TIPO = 'OVERRUN'
	cQryDel += "	AND Z49_CODOVE <> ''"

	If select("QRYDEL")>0
		QRYDEL->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQryDel),"QRYDEL",.F.,.F.)
	QRYDEL->(DBGOTOP())
	While QRYDEL->(!EOF())
		If aScan(aCodOver, {|x| ALLTRIM(X) == ALLTRIM(QRYDEL->Z49_CODOVE)}) == 0
			aAdd(aCodOver, QRYDEL->Z49_CODOVE)
		EndIf
		QRYDEL->(DbSkip())
	EndDo

	//Apagando a informação 
	cQryDel:=" DELETE FROM "+RETSQLNAME("Z49")
	cQryDel+=" WHERE Z49_FILIAL='"+xFilial("Z49")+"' AND Z49_PROPOS='"+cNum+"' AND Z49_REVISA='"+cRevisao+"' AND Z49_TIPO='OVERRUN' AND Z49_CODOVE<>''"
	
	if TcSqlExec(cQryDel)>=0
		Begin Transaction
			DbSelectArea("TZ49OVE")
			TZ49OVE->(DbSetOrder(1))
			TZ49OVE->(DbGoTop())
			
			While TZ49OVE->(!EOF())
	    		RecLock("Z49",.T.)
	    		Z49->Z49_FILIAL	:= xFilial("Z49")
	    		Z49->Z49_PROPOS	:= cNum
	    		Z49->Z49_REVISA	:= cRevisao
	    		Z49->Z49_TIPO	:= "OVERRUN"
	    		Z49->Z49_PARCEL	:= TZ49OVE->PARCELA
	    		Z49->Z49_VENCTO	:= TZ49OVE->VENCIMENTO
	    		Z49->Z49_VALOR	:= TZ49OVE->VALOR
	    		Z49->Z49_INCDIP	:= "N"
	    		Z49->Z49_INCANO	:= "N"
	    		Z49->Z49_DTINC	:=	dDataBase
	    		Z49->Z49_DIAVEN	:= TZ49OVE->VENCIMENTO
	    		Z49->Z49_CODOVE	:= TZ49OVE->OVERRUN
		    	Z49->(MsUnLock())
		   		TZ49OVE->(DbSkip())
			Enddo
		End Transaction
		
		//Gravação do Orçamento
		GrvOrc(cNum,cRevisao,aCodOver)
		
	else
		Alert("Não foi possível salvar a aba pagamentos!")
	endif	
endif

Return

/*
Funcao      : CarregaZ49
Parametros  : nOpc,cNum,cRev
Retorno     : aRet
Objetivos   : Função para carregar os itens da tabela Z49
Autor       : Matheus Massarotto
Data/Hora   : 14/11/2012
*/
*------------------------------------------------------*
Static Function CarregaZ49(nOpc,cNum,cRev,cTipo,xParam3)
*------------------------------------------------------*
Local aRet	:= {}
Local cQry	:= ""


if xParam3==12 .OR. nOpc<>3

	if nOpc==6 //revisar
		cRev:=STRZERO(val(cRev)-1,3)
	endif
			cQry:=" SELECT * FROM "+RETSQLNAME("Z49")+CRLF
			cQry+=" WHERE D_E_L_E_T_='' AND Z49_FILIAL='"+xFilial("Z49")+"' AND Z49_PROPOS='"+cNum+"' AND Z49_REVISA='"+cRev+"' AND Z49_TIPO='"+cTipo+"' "
			cQry+=" ORDER BY Z49_PROPOS,CONVERT(INT ,Z49_PARCEL)"

			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
			
			Count to nRecCount
	        
			if nRecCount >0
	        	QRYTEMP->(DbGotop())
				
				While QRYTEMP->(!EOF())
					
					//AADD(aRet,{QRYTEMP->Z49_PARCEL,QRYTEMP->Z49_VENCTO,QRYTEMP->Z49_VALOR,QRYTEMP->Z49_INCDIP,QRYTEMP->Z49_INCANO})
					AADD(aRet,{QRYTEMP->Z49_PARCEL,QRYTEMP->Z49_VENCTO,QRYTEMP->Z49_VALOR,.F.,QRYTEMP->Z49_DIAVEN,QRYTEMP->Z49_INCDIP,QRYTEMP->Z49_INCANO})
					QRYTEMP->(DbSkip())
				EndDo
				
	        endif

endif

Return(aRet)

/*
Funcao      : GravaZ52
Parametros  : 
Retorno     : 
Objetivos   : Função para adicionar gravar/alterar tabelaZ52
Autor       : Matheus Massarotto
Data/Hora   : 30/07/2013
*/

*----------------------------------------------------------------------*
Static Function GravaZ52(nOpc,oGetDadDes,aHeaZ52,cNum,cRevisao,aCpoZ52,aColsZ52)
*----------------------------------------------------------------------*
//Variável para controle de inclusão ou alteração
Local lInc:=.F.
	
if nOpc==3 //Inclusão

	Begin Transaction

		// Proposta
	
		if !empty(oGetDadDes:Acols)
		    for nW:=1 to len(oGetDadDes:Acols)
		    	if empty(oGetDadDes:Acols[nW][2]) .OR. oGetDadDes:aCols[nW][len(oGetDadDes:aCols[nW])]
		    	   loop
		    	else
		    		RecLock("Z52",.T.)
			    		Z52->Z52_FILIAL	:= xFilial("Z52")
			    		Z52->Z52_NUMPRO	:= cNum
			    		Z52->Z52_REVISA	:= "000"
		    			for ny:=1 to len(aHeaZ52)
		    				Z52->&(aHeaZ52[ny][2]) := (aColsZ52[nW][nY])
		    			next
			    	Z52->(MsUnLock())
		    	endif
		    next
			
		endif
		

	End Transaction

elseif nOpc==6 //Revisar

	Begin Transaction

		// Proposta
	
		if !empty(oGetDadDes:Acols)
		    for nW:=1 to len(oGetDadDes:Acols)

		    	//Se tiver vazio ou deletado
		    	if empty(oGetDadDes:Acols[nW][2]) .OR. oGetDadDes:aCols[nW][len(oGetDadDes:aCols[nW])]
		    	   loop
		    	else
		    		RecLock("Z52",.T.)
			    		Z52->Z52_FILIAL	:= xFilial("Z52")
			    		Z52->Z52_NUMPRO	:= cNum
			    		Z52->Z52_REVISA	:= cRevisao
		    			for ny:=1 to len(aHeaZ52)
		    				Z52->&(aHeaZ52[ny][2]) := (aColsZ52[nW][nY])
		    			next
			    	Z52->(MsUnLock())
		    	endif
		    	
		    next
			
		endif
			    
	End Transaction

elseif nOpc==4 //Alterar
	
	nPosItem	:= Ascan(aHeaZ52,{|x| alltrim(x[2]) = "Z52_ITEM"})
   	
   	Begin Transaction
    	
    	if !empty(oGetDadDes:Acols)
		    for nW:=1 to len(oGetDadDes:Acols)
		    	//se tiver vazio
		    	if empty(oGetDadDes:Acols[nW][2])
		    	   loop
		    	//se tiver deletado
		    	elseif oGetDadDes:aCols[nW][len(oGetDadDes:aCols[nW])]
  					if Z52->(DbSeek(xFilial("Z52")+cNum+cRevisao+oGetDadDes:aCols[nW][nPosItem]))
			    		RecLock("Z52",.F.)
							Z52->(DbDelete())
						Z52->(MsUnlock())
					endif
		    	else
		    	    
  					if Z52->(DbSeek(xFilial("Z52")+cNum+cRevisao+oGetDadDes:aCols[nW][nPosItem]))
		    	    	lInc:=.F.
		    		else
		    			lInc:=.T.
		    		endif
		    		
		    		RecLock("Z52",lInc)
			    		Z52->Z52_FILIAL	:= xFilial("Z52")
			    		Z52->Z52_NUMPRO	:= cNum
			    		Z52->Z52_REVISA	:= cRevisao
		    			for ny:=1 to len(aHeaZ52)
		    				Z52->&(aHeaZ52[ny][2]) := (aColsZ52[nW][nY])
		    			next
			    	Z52->(MsUnLock())

		    	endif
		    next
			
		endif
		
	End Transaction
	
endif

Return

/*
Funcao      : CarregaZ52
Parametros  : nOpc,cNum,cRev
Retorno     : 
Objetivos   : Função para carregar os itens da tabela Z52
Autor       : Matheus Massarotto
Data/Hora   : 29/07/2012
*/                                                                 
*---------------------------------------------------------------*
Static Function CarregaZ52(nOpc,xParam3,aColsZ52,nMaxZ52,nUsadoZ52,nReg,aHeaZ52,cRev)
*---------------------------------------------------------------*
Local cQry	:= ""
Local nSq	:= "00"

if nOpc==6
	cRev:=STRZERO((val(cRev)-1),3)
endif

	//Carrega as variáveis no aCols de acordo com a opção selecionada       
	If nOpc == 3 .AND. xParam3<>12
		//Busco as despesas que estao com o carrega automatico preenchido
		cQry:=" SELECT Z56_CODIGO,Z56_DESCRI FROM "+RETSQLNAME("Z56")
		cQry+=" WHERE D_E_L_E_T_='' AND Z56_CARAUT='1'"

		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
	
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
		Count to nRecCount
		
		if nRecCount > 0
			
			QRYTEMP->(DbGotop())
			
			While QRYTEMP->(!EOF())
                nSq:=SOMA1(nSq)
				AADD(aColsZ52,Array(nUsadoZ52+1))
				For nI := 1 To nUsadoZ52
					if Alltrim(aHeaZ52[nI,2]) == "Z52_ITEM"
						aColsZ52[len(aColsZ52)][nI] := nSq
					elseif Alltrim(aHeaZ52[nI,2]) == "Z52_CODIGO"
						aColsZ52[len(aColsZ52)][nI] := QRYTEMP->Z56_CODIGO
					elseif Alltrim(aHeaZ52[nI,2]) == "Z52_DESCDE"
						aColsZ52[len(aColsZ52)][nI] := QRYTEMP->Z56_DESCRI
					else
						aColsZ52[len(aColsZ52)][nI] := CriaVar(aHeaZ52[nI][2])
					endif
				Next
				aColsZ52[len(aColsZ52)][nUsadoZ52+1] := .F.
			
				QRYTEMP->(DbSkip())
			Enddo
		
		else
		
			AADD(aColsZ52,Array(nUsadoZ52+1))
			For nI := 1 To nUsadoZ52
				if Alltrim(aHeaZ52[nI,2]) == "Z52_ITEM"
					aColsZ52[len(aColsZ52)][nI] := "01"
				else
					aColsZ52[len(aColsZ52)][nI] := CriaVar(aHeaZ52[nI][2])
				endif
			Next
			aColsZ52[len(aColsZ52)][nUsadoZ52+1] := .F.
			
		endif

	Else
		DbSelectArea("Z55")
		Z55->(DbGoTo(nReg))
		cFilNum:= Z55->Z55_FILIAL+Z55->Z55_NUM+Z55->Z55_REVISA
		
		aColsZ52:={}
		dbSelectArea("Z52")
		Z52->(dbSetOrder(1))
		Z52->(dbSeek(cFilNum))
		While Z52->(!EOF()) .AND. Z52_NUMPRO==M->Z55_NUM .AND. Z52_REVISA==cRev .AND. Z52_FILIAL==xFilial("Z52")
			AADD(aColsZ52,Array(nUsadoZ52+1))
				For nX:=1 to nUsadoZ52
					aColsZ52[Len(aColsZ52),nX]:=FieldGet(FieldPos(aHeaZ52[nX,2]))
				Next
			aColsZ52[Len(aColsZ52),nUsadoZ52+1]:=.F.
			Z52->(dbSkip())
		End
		
		if nOpc<>6
			nMaxZ52:=Len(aColsZ52) //Tratamento para não permitir inserir mais linhas no alterar
		endif		

	EndIf                            

Return(aColsZ52)


/*
Funcao      : CarregaZ27
Parametros  : nOpc,cNum,cRev
Retorno     : 
Objetivos   : Função para carregar os itens da tabela Z52
Autor       : Matheus Massarotto
Data/Hora   : 24/09/2014
*/                                                                 
*------------------------------------------------------------------------------------*
Static Function CarregaZ27(nOpc,xParam3,aColsZ27,nMaxZ27,nUsadoZ27,nReg,aHeaZ27,cRev)
*------------------------------------------------------------------------------------*
Local cQry	:= ""
Local nSq	:= "00"

	if nOpc==6
		cRev:=STRZERO((val(cRev)-1),3)
	endif

	DbSelectArea("Z55")
	Z55->(DbGoTo(nReg))
	cFilNum:= Z55->Z55_FILIAL+Z55->Z55_NUM+Z55->Z55_REVISA
	
	aColsZ27:={}
	dbSelectArea("Z27")
	Z27->(dbSetOrder(1))
	Z27->(dbSeek(cFilNum))
	While Z27->(!EOF()) .AND. Z27_NUMPRO==M->Z55_NUM .AND. Z27_REVISA==cRev .AND. Z27_FILIAL==xFilial("Z27")
		AADD(aColsZ27,Array(nUsadoZ27+1))
			For nX:=1 to nUsadoZ27
				aColsZ27[Len(aColsZ27),nX]:=FieldGet(FieldPos(aHeaZ27[nX,2]))
			Next
		aColsZ27[Len(aColsZ27),nUsadoZ27+1]:=.F.
		Z27->(dbSkip())
	Enddo                                                                              j
	
	//if nOpc<>6
	nMaxZ27:=Len(aColsZ27) //Tratamento para não permitir inserir mais linhas
	//endif		


Return(aColsZ27)


/*
Funcao      : BuscaArq
Parametros  : 
Retorno     : cArquivo
Objetivos   : Função auxiliar para buscar o arquivo no computador do usuário
Autor       : Matheus Massarotto
Data/Hora   : 06/12/2012
*/

*------------------------*
Static Function BuscaArq()
*------------------------*
Local cArquivo 	:=""

cArquivo := cGetFile("Arquivos .zip|*.zip|Arquivos .rar|*.rar","Selecione o Arquivo",1,'C:\',.T.,( GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE ) ,.F.)

Return(cArquivo)

/*
Funcao      : CopiaT_S
Parametros  : cUsrLocal,cLocalArq,cNomeArq
Retorno     : 
Objetivos   : Função auxiliar que copia o arquivo da maquina do usuário para o servidor
Autor       : Matheus Massarotto
Data/Hora   : 06/12/2012
*/
*----------------------------------------------------*
Static Function CopiaT_S(cUsrLocal,cLocalArq,cNomeArq)
*----------------------------------------------------*

ProcRegua(0)

	if !CpyT2S( cUsrLocal, cLocalArq)
		Alert("Não foi possível salvar o arquivo no servidor.")
	else
		RecLock("Z55",.F.)
			Z55->Z55_ANEXO:=alltrim(cLocalArq+"\"+cNomeArq)
		Z55->(MsUnlock())
		MsgInfo("Adicionado com sucesso!")
	endif

Return		

/*
Funcao      : FormBrwTable
Parametros  : nOpc
Retorno     : 
Objetivos   : Função para montagem do browse com a tabela Z68, para manipulação dos follow ups
Autor       : Matheus Massarotto
Data/Hora   : 21/12/2012
*/

*---------------------------------*
Static Function FormBrwTable(nOpc)
*---------------------------------*
Local oButton
Local oColumn
Local oDlgZ68:=oTFolder:aDialogs[6]

Local oBrowseZ68

// Abertura da tabela e carregamento dos dados
CarregaZ68(nOpc)

// Define o Browse
DEFINE FWFORMBROWSE oBrowseZ68 DATA TABLE ALIAS "DADTRB" OF oDlgZ68

// Adiciona legenda no Browse
ADD LEGEND DATA '!Z68_ATIVO'  COLOR "RED" TITLE "Inativo" OF oBrowseZ68
ADD LEGEND DATA '!Z68_EXECUT' COLOR "YELLOW" TITLE "Pendente" OF oBrowseZ68
ADD LEGEND DATA 'Z68_EXECUT'  COLOR "GRAY" TITLE "Executado" OF oBrowseZ68


// Adiciona as colunas do Browse
if nOpc<>3 .AND. nOpc<>2
	ADD BUTTON oButton TITLE "Incluir" ACTION { || IncZ68(oBrowseZ68)} OF oBrowseZ68
	ADD BUTTON oButton TITLE "Alterar" ACTION { || AltZ68(oBrowseZ68)} OF oBrowseZ68
endif

// Adiciona as colunas do Browse		
ADD COLUMN oColumn DATA { || Z68_CODIGO	} TITLE "Codigo"    SIZE  9 OF oBrowseZ68		
ADD COLUMN oColumn DATA { || Z68_DESCRI } TITLE "Descrição" SIZE 10 OF oBrowseZ68		
ADD COLUMN oColumn DATA { || Z68_DATA   } TITLE "Data" 		SIZE 10 OF oBrowseZ68		
ADD COLUMN oColumn DATA { || Z68_HORA   } TITLE "Hora"      SIZE  5 OF oBrowseZ68	
ADD COLUMN oColumn DATA { || Z68_OBS    } TITLE "Observação"SIZE 50 OF oBrowseZ68	
//ADD COLUMN oColumn DATA { || Z68_ATIVO  } TITLE "Ativo"      SIZE  1 OF oBrowse	

//Indica o tamanho em percentual do Browse na tela.
//oBrowseZ68:SetSizeBrowse(20)
//oBrowseZ68:SetSizeDetails(80)

// Ativação do Browse	
ACTIVATE FWFORMBROWSE oBrowseZ68

Return

/*
Funcao      : IncZ68
Parametros  : oBrowseZ68
Retorno     : 
Objetivos   : Função auxiliar a FormBrwTable para inclusão de um follow up(Z68)
Autor       : Matheus Massarotto
Data/Hora   : 21/12/2012
*/
*--------------------------------*
Static Function IncZ68(oBrowseZ68)
*--------------------------------*
Private cCadastro := "Follow up"
				// [ cAlias ] [ nReg ] [ nOpc ] [ aAcho ] [ cFunc ] [ aCpos ] [ cTudoOk ] [ lF3 ] [ cTransact ] 
	Z68->( AxInclui( "Z68", Recno() , 3			, 		, 			,		,			,		,	"U_P_GraZ68"	) )

    //Posiciona em um determinado registro do Browse
     				//< nGoto>, [ lRefresh]
	oBrowseZ68:GoTo(oBrowseZ68:nLen+1,.T.)

Return

/*
Funcao      : AltZ68
Parametros  : oBrowseZ68
Retorno     : 
Objetivos   : Função auxiliar a FormBrwTable para alteração de um follow up(Z68)
Autor       : Matheus Massarotto
Data/Hora   : 21/12/2012
*/
*--------------------------------*
Static Function AltZ68(oBrowseZ68)
*--------------------------------*
Private cCadastro := "Follow up"
	
	Z68->(Dbgoto(DADTRB->Z68_RECNO))
	Z68->( AxAltera( "Z68",	DADTRB->Z68_RECNO , 4,,{"Z68_ATIVO"} ) )
	
    Reclock("DADTRB",.F.)
		DADTRB->Z68_ATIVO	:=Z68->Z68_ATIVO
	DADTRB->(MsUnlock())

    //Posiciona em um determinado registro do Browse
     				//< nGoto>, [ lRefresh]	
	oBrowseZ68:GoTo(oBrowseZ68:nLen+1,.T.)
Return

/*
Funcao      : CarregaZ68
Parametros  : nOpc
Retorno     : 
Objetivos   : Função auxiliar a FormBrwTable para carregar as informações de follow ups(Z68)
Autor       : Matheus Massarotto
Data/Hora   : 21/12/2012
*/
*-------------------------------*
Static Function CarregaZ68(nOpc)
*-------------------------------*
Local aDadTemp:={}

AADD(aDadTemp,{"Z68_FILIAL","C",2,0})
AADD(aDadTemp,{"Z68_CODIGO","C",9,0})
AADD(aDadTemp,{"Z68_DESCRI","C",50,0})
AADD(aDadTemp,{"Z68_DATA","D",8,0})
AADD(aDadTemp,{"Z68_HORA","C",5,0})
AADD(aDadTemp,{"Z68_ATIVO","L",1,0})
AADD(aDadTemp,{"Z68_EXECUT","L",1,0})
AADD(aDadTemp,{"Z68_OBS","C",200,0})
AADD(aDadTemp,{"Z68_RECNO","N",6,0})

if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex:=CriaTrab(Nil,.F.)
IndRegua("DADTRB",cIndex,"Z68_FILIAL+Z68_CODIGO",,,"Selecionando Registro...")

DbSelectArea("DADTRB")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

if nOpc <>3
	
	cQry:=" SELECT * FROM "+RETSQLNAME("Z68")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND Z68_FILIAL='"+xFilial("Z68")+"' AND Z68_PROPOS='"+M->Z55_NUM+"' AND Z68_REVISA='"+M->Z55_REVISA+"'"
	
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
	
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
		Count to nRecCount
		
		if nRecCount > 0
			
			QRYTEMP->(DbGotop())
			
			While QRYTEMP->(!EOF())
			    Reclock("DADTRB",.T.)
					DADTRB->Z68_CODIGO	:= QRYTEMP->Z68_CODIGO
					DADTRB->Z68_DESCRI	:= QRYTEMP->Z68_DESCRI
					DADTRB->Z68_DATA	:= STOD(QRYTEMP->Z68_DATA)
					DADTRB->Z68_HORA	:= QRYTEMP->Z68_HORA
					DADTRB->Z68_ATIVO	:= IIF(alltrim(QRYTEMP->Z68_ATIVO)=="T",.T.,.F.)
					DADTRB->Z68_EXECUT	:= IIF(alltrim(QRYTEMP->Z68_EXECUT)=="T",.T.,.F.)
					DADTRB->Z68_OBS		:= QRYTEMP->Z68_OBS
					DADTRB->Z68_RECNO	:= QRYTEMP->R_E_C_N_O_
				DADTRB->(MsUnlock())
				QRYTEMP->(DbSkip())
			Enddo
	
		endif	
endif

Return()

/*
Funcao      : P_GraZ68
Parametros  : 
Retorno     : 
Objetivos   : Função auxiliar a IncZ68 para incluir também na tabela temporária do browse após a inclusão
Autor       : Matheus Massarotto
Data/Hora   : 21/12/2012
*/
/*
*--------------------*
User Function P_GraZ68
*--------------------*	    
	RecLock("Z68",.F.)
		Z68->Z68_PROPOS:=M->Z55_NUM
		Z68->Z68_REVISA:=M->Z55_REVISA
	Z68->(MsUnlock())

    Reclock("DADTRB",.T.)
		DADTRB->Z68_CODIGO	:=Z68->Z68_CODIGO
		DADTRB->Z68_DESCRI	:=Z68->Z68_DESCRI
		DADTRB->Z68_DATA	:=Z68->Z68_DATA
		DADTRB->Z68_HORA	:=Z68->Z68_HORA
		DADTRB->Z68_ATIVO	:=Z68->Z68_ATIVO
		DADTRB->Z68_EXECUT	:=.T.
		DADTRB->Z68_OBS		:=Z68->Z68_OBS
		DADTRB->Z68_RECNO	:=QRYTEMP->R_E_C_N_O_
	DADTRB->(MsUnlock())
Return
*/
/*
Funcao      : AnexoP00
Parametros  : nOpc, cItemZ48
Retorno     : Nil
Objetivos   : Rotina para manutenção de anexos.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:19
*/
*-----------------------------------------------*
Static Function AnexoP00(nOpc,cItemZ48,xParam5)
*-----------------------------------------------*
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
Private lEhGanha	:= .F.


if nOpc==3
	RegToMemory("Z48",If(nOpc==3,.T.,.F.))
	cItemZ48:="00"
else
    DbSelectArea("Z48")
    Z48->(DbGoTop())
    DbSetOrder(1)
    DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA)
    While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==M->Z55_NUM .AND. Z48->Z48_REVISA==M->Z55_REVISA
	   	AADD(aAnexos,{Z48->Z48_ITEM,Z48->Z48_DESCRI,Z48->Z48_DATA,Z48->Z48_HORA,Z48->Z48_ARQUIV,Z48->Z48_TIPO})
    	cItemZ48:=Z48->Z48_ITEM
    	Z48->(DbSkip())
    Enddo
    if empty(cItemZ48)
    	cItemZ48:="00"
    endif
endif


// # INICIO - Verifico se é proposta ganha #

	cQry:=" SELECT Z47_NOPC FROM "+RETSQLNAME("Z47")+" Z47 "
	cQry+=" WHERE Z47.D_E_L_E_T_='' AND Z47.Z47_CODIGO = ( "
	cQry+=" SELECT Z46_CODACA FROM "+RETSQLNAME("Z46")+" Z46"
	cQry+=" WHERE Z46.D_E_L_E_T_='' AND Z46_CODLEG='"+Z55->Z55_STATUS+"') "

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

	Count to nRecCount
	
	if nRecCount > 0
		
		QRYTEMP->(DbGotop())
		if CTON(QRYTEMP->Z47_NOPC,10)==14 //proposta ganha
			lEhGanha:=.T.
		endif
		
	endif

// # FIM - Verifico se é proposta ganha #


Begin Sequence

If xParam5 <> "2" .OR. lEhGanha  //Não será exibido o botão no visualizar
	aAdd(aButtons,{ "BMPINCLUIR" ,{ || AddFile(nOpc) }, "Adicionar arquivo" + " <F3>", "Adicionar"})
	aAdd(aButtons,{ "BPMSDOCE"   ,{ || DelFile(lEhGanha) }, "Remover arquivo"            , "Remover"  })
Else
	aAdd(aButtons,{ "BMPINCLUIR" ,{ || alert("Opção não disponível para visualizar!") }, "Adicionar arquivo" + " <F3>", "Adicionar"})
 	aAdd(aButtons,{ "BPMSDOCE"   ,{ || alert("Opção não disponível para visualizar!") }, "Remover arquivo"            , "Remover"  })
EndIf

/*aHeader := {{"Item"   	,"ITEM"   	,"@!",002,0,".t.",nil,"C",nil,nil } ,;
			{"Tipo"   	,"TIPO"   	,"@!",003,0,".t.",nil,"C",nil,nil } ,;			
            {"Data"   	,"DATAARQ"	,"@D",008,0,".t.",nil,"D",nil,nil } ,;
            {"Hora"   	,"HORAARQ"	,"@!",005,0,".t.",nil,"C",nil,nil } ,;
			{"Arquivo"	,"ARQUIVO"	,"@!",50,0,".t.",nil,"C",nil,nil },;
			{"Descricao","DESCRI"	,"@!",150,0,".t.",nil,"C",nil,nil }}
*/

aHeader := {{"Item"   	,"ITEM"   	,"@!",002,0,".t.",nil,"C",nil,nil } ,;
			{"Descricao","DESCRI"	,"@!",150,0,".t.",nil,"C",nil,nil } ,;
            {"Data"   	,"DATAARQ"	,"@D",008,0,".t.",nil,"D",nil,nil } ,;
            {"Hora"   	,"HORAARQ"	,"@!",005,0,".t.",nil,"C",nil,nil } ,;
			{"Arquivo"	,"ARQUIVO"	,"@!",500,0,".t.",nil,"C",nil,nil } ,;//JSS Ajustado para solucionar o caso 025407
			{"Tipo"   	,"TIPO"   	,"@!",003,0,".t.",nil,"C",nil,nil }}
			
If Len(aAnexos) > 0
	For nI:=1 To Len(aAnexos)
		aAdd(aCols,{aAnexos[nI][1],aAnexos[nI][2],aAnexos[nI][3],aAnexos[nI][4],aAnexos[nI][5],aAnexos[nI][6],.F.})
		AAdd(aColsAcento,aCols[nI][5])
	Next
Else
	aAdd(aCols, Array( Len(aHeader)+1 ) )
Endif

DEFINE MSDIALOG oDlgAnexo TITLE "Seleção de arquivo" FROM 1,1 To 300,470 OF oMainWnd Pixel
                                             
	oMSGet:= MSGetDados():New(1, 1, 1, 1, 1,,,"",.F.,{})
 	oMsGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
	oMsGet:oBrowse:blDblClick := {|| AbreArq()}
	
	oMSGet:ForceRefresh()

	SetKey(VK_F3,{|| AddFile(nOpc) })

//Activate MsDialog oDlgAnexo ON INIT EnchoiceBar(oDlgAnexo,bOk,bCancel,,aButtons) Centered
//Rotina personalizada para funcionar botões na versão 11
ACTIVATE MSDIALOG oDlgAnexo ON INIT U_GTEnchBar(oDlgAnexo,bOk,bCancel,,aButtons) CENTERED

SetKey(VK_F3,Nil)

If lRet
	For nI:=1 to Len(aCols)
		If !aCols[nI][Len(aCols[nI])] //Verifica se está deletado
        	If aScan(aAnexos,{|e| AllTrim(e[1]) == AllTrim(aCols[nI][1])}) == 0
	        	aAdd(aAnexos,{aCols[nI][1],aCols[nI][2],aCols[nI][3],aCols[nI][4],aCols[nI][5],aCols[nI][6]})
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
Funcao      : AddFile
Parametros  : nOpc
Retorno     : Nil
Objetivos   : Adiciona o arquivo anexo.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:20
*/
*----------------------------*
Static Function AddFile(nOpc)
*----------------------------*
Local oDlg
Local oFont
Local oSay

Local nP := 0

Local lOk := .f.
Local bOk     := {|| If(DocValid(nOpc),(oDlg:End(),lOk := .t.),lOk := .f.) },;
      bCancel := {|| oDlg:End() }
Local aDir, i, j
Local bOld,oArquivo

Private cDescri	 := SPACE(150)
Private oDesc

Private bFileAction := {|| cArquivo := ChooseFile()}, cArquivo := Space(200)

//Verifica se existe arquivo anexado.
//nP := aScan(aCols,{|a| a[1] == cItemZ02})

If nP > 0
	MsgInfo("Já existe arquivo anexado para essa movimentação.","Atenção")
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE "Seleção de arquivos" FROM 1,1 To 191,376 OF oMainWnd Pixel
      
	@ 04,4 to 33,185 Label "Escolha o arquivo a ser anexado:" PIXEL
      
	@ 15,12 MsGet oArquivo Var cArquivo Size 150,07 Pixel Of oDlg
    oArquivo:Disable()
      
	@ 15,162 Button "..." Size 10,10 Pixel Action .t. Of oDlg

	@ 35,4 to 72,185 Label "Descrição:" PIXEL
	@ 45,12 MsGet oDesc Var cDescri Size 165,07 PIXEL OF oDlg

	oDlg:aControls[3]:bAction := bFileAction

	Define Font oFont Name "Arial" SIZE 0,-10 //BOLD
	@ 16,173 Say oSay Var "(F3)" Size 10,10 Pixel Of oDlg Color CLR_GRAY
	oSay:oFont := oFont

	bOld := SetKey(VK_F3)
	SetKey(VK_F3,bFileAction)
      
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED

SetKey(VK_F3,bOld)

If !lOk
	Return
EndIf

Processa({||AddProcess(cArquivo,nOpc)}, "Aguarde enquanto o arquivo é copiado")
  
//oMsGet:oBrowse:Refresh()
oMSGet:ForceRefresh()
Return

/*
Funcao      : AddProcess
Parametros  : cArquivo,nOpc
Retorno     : Nil
Objetivos   : Deleta o arquivo anexado.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:21
*/

*---------------------------------------*
Static function AddProcess(cArquivo,nOpc)
*---------------------------------------*
Local cDesTpMov:=""

ProcRegua(0)

If Type("aCols[1][1]") <> "U" .And. Empty(aCols[1][1])
	ADel(aCols,1)
	ASize(aCols,Len(aCols)-1)
EndIf
   
cArquivo := Upper(AllTrim(cArquivo))

cFolder  := If(Right(cArquivo,1) = "\",cArquivo,SubStr(cArquivo,1,RAt("\",cArquivo)))

cArquivo += If(!File(cArquivo),"*.ZIP","")
   
aDir := Directory(cArquivo)

Private cArq

For i := 1 to Len(aDir)
	cArq := AllTrim(Upper(cFolder+aDir[i][1]))
	lLoop := .f.
	For j := 1 To Len(aColsAcento)
		If aColsAcento[j] == cArq .And. !aCols[j][Len(aCols[j])]
			lLoop := .t.
			Exit
		EndIf
	Next
	If lLoop
		Loop
	EndIf
	
	cItemZ48:=SOMA1(cItemZ48)

	aAdd(aCols, Array( Len(aHeader)+1 ) )
	n := Len(aCols)
	aCols[n][Len(aCols[n])] := .f.
	aCols[n][1] := cItemZ48    							  //item
	aCols[n][2] := cDescri
	aCols[n][3] := dDatabase                              //data
	aCols[n][4] := Time()                                 //hora
	aCols[n][5] := IncSpace(cArq,aHeader[5][4],.f.)       //nome do arquivo
	aCols[n][6] := cDesTpMov                              //tipo
	AAdd(aColsAcento,cArq)
	
	if !GrvAnexo(nOpc,cItemZ48)
		MsgStop("Não foi possível copiar arquivo.","Atenção")
		
		aDel(aCols,n)
		aSize(aCols,Len(aCols)-1)
		
		loop
	endif
Next

Return

/*
Funcao      : DelFile
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Deleta o arquivo anexado.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:21
*/
*-----------------------*
Static Function DelFile(lEhGanha)
*-----------------------*
Local nP := 0

//Verifica se existe arquivo anexado.
nP := aScan(aCols,{|a| a[1] == aCols[oMsGet:oBrowse:nAt][1]})
If nP > 0

	if lEhGanha //Valido se o anexo foi incluído neste momento, sedo possível sua exclusão
       	if aScan(aAnexos,{|a| a[1] == aCols[nP][1]})>0
			MsgAlert("Não é possível excluir este item.","Atenção")
			Return .T.
		endif
	endif
    
		If MsgYesNo("Confirma a exclusão do arquivo anexo?","Atenção")
	
			DbSelectArea("Z48")
			DbSetOrder(1)
			DbSeek(xFilial("Z48")+M->Z55_NUM+M->Z55_REVISA+aCols[nP][1])
			RecLock("Z48",.F.)
				Z48->(DbDelete())
			MsUnlock()
	
			aDel(aCols,nP)
			aSize(aCols,Len(aCols)-1)
	
			aColsAcento := {}
			
		EndIf
    
	oMsGet:oBrowse:Refresh()
	
Else
	MsgAlert("Nenhum arquivo foi anexado para essa movimentação.","Atenção")
EndIf

Return .t.

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
Local nOptions:= GETF_RETDIRECTORY+GETF_LOCALHARD //GETF_NETWORKDRIVE
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

	cPastaCod   := STRTRAN(M->Z55_NUM,"/","_") + M->Z55_REVISA +"\"
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
Funcao      : ChooseFile
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tela de seleção do arquivo anexo.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:25
*/
*--------------------------*
Static Function ChooseFile()
*--------------------------*
Local cTitle:= "Seleção de arquivos"
Local cMask := "Formato ZIP|*.zip|Formato RAR|*.rar"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cLastPath
Local nOptions:= GETF_LOCALHARD//+GETF_NETWORKDRIVE

Local aArea := GetArea()

SetKey(VK_F3,Nil)

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,.F.,nOptions,.F.)

If Empty(cFile)
   Return cArquivo
Else
	if !ValTamAn(cFile)
		Return cArquivo
	endif
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

SetKey(VK_F3,bFileAction)

RestArea(aArea)

Return IncSpace(cFile,500,.f.) //JSS Ajustado para solucionar o caso 025407


/*
Funcao      : DocValid
Parametros  : nOpc
Retorno     : Nil
Objetivos   : Validação da digitação do caminho do anexo.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:25
*/
*----------------------------*
Static Function DocValid(nOpc)
*----------------------------*
Local cArq := AllTrim(Upper(cArquivo))
Local nAt := 0

If Empty(cArq)
   MsgInfo("Informe o caminho e o nome do arquivo!","Aviso")
   Return .f.
EndIf

If empty(cDescri)
   MsgInfo("Informe a descrição sobre o arquivo!","Aviso")
   Return .f.
Endif

if nOpc==10
	if !MsgYesNo("Nesta operação somente deve ser anexado a proposta assinada, confirma documento como sendo a proposta assinada?","Atencao")
		Return(.F.)
	endif
elseif nOpc==4 .AND. M->Z55_STATUS=='8'
	if !MsgYesNo("Nesta operação somente deve ser anexado a proposta assinada, confirma documento como sendo a proposta assinada?","Atencao")
		Return(.F.)
	endif	
endif

If (Right(cArq,4) <> ".ZIP" .AND. Right(cArq,4) <> ".RAR" ) .And. Right(cArq,1) <> "\"
   cArq += "\"
EndIf

If !File(cArq)
   If !lIsDir(cArq)
      MsgStop("O arquivo especificado não existe.","Aviso")
      Return(.F.)
   EndIf
   
   If Len(Directory(cArq+"*.ZIP")) = 0 .AND. Len(Directory(cArq+"*.RAR")) = 0
      MsgStop("Não há arquivos no diretório especificado.","Aviso")
      Return(.F.)
   EndIf
EndIf

cArquivo := cArq

nAt := 1
While nAt > 0
	nAt := At("\",cArq)
    cArq := Substr(cArq,nAt+1,Len(cArq))
EndDo

Return(.T.)

/*
Funcao      : GrvAnexo
Parametros  : nOpc,cItemZ48
Retorno     : Nil
Objetivos   : Gravação das informações do anexo na tabela Z48
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:25
*/admin	

*-------------------------------------*
Static function GrvAnexo(nOpc,cItemZ48)
*-------------------------------------*
Local cTipoMov	:= ""
Local cDescMov	:= ""
Local cTempPat	:= alltrim(GetTempPatch())

if nOpc == 4 .AND. M->Z55_STATUS=='8'
	cTipoMov:="P"
	cDescMov:="Alteração de proposta: " + M->Z55_NUM
elseif nOpc == 4
	cTipoMov:="A"
	cDescMov:="Alteração de proposta: " + M->Z55_NUM
elseif nOpc == 6
	cTipoMov:="A"
	cDescMov:="Revisão de proposta: " + M->Z55_NUM
elseif nOpc == 10
	cTipoMov:="P"
	cDescMov:="Aprovado cliente proposta: " + M->Z55_NUM
elseif nOpc == 11
	cTipoMov:="A"
	cDescMov:="Recusado cliente proposta: " + M->Z55_NUM
elseif nOpc == 18
	cTipoMov:="I"
	cDescMov:="Revisado pool proposta: " + M->Z55_NUM
elseif nOpc == 19
	cTipoMov:="O"
	cDescMov:="Inclusão Overrun: " + M->Z55_NUM
else
	cTipoMov:="A"
	cDescMov:="Outra opção de proposta: " + M->Z55_NUM
endif

//Gravação do anexo (itens)
RecLock("Z48",.T.)
	Z48->Z48_FILIAL := xFilial("Z48")
	Z48->Z48_PROPOS := M->Z55_NUM
	Z48->Z48_REVISA := M->Z55_REVISA
	Z48->Z48_ITEM   := cItemZ48
	Z48->Z48_DATA   := dDataBase
	Z48->Z48_HORA   := Time()
	Z48->Z48_CODUSR := RetCodUsr()
	Z48->Z48_NOMEUS	:= CAPITAL(alltrim(UsrRetName (__cUserID)))
	Z48->Z48_TIPO   := cTipoMov
	Z48->Z48_DESCRI	:= cDescri
If nOpc == 3
	Z48->Z48_MOVIME := 	"Inclusão de proposta: " + M->Z55_NUM
Else
	Z48->Z48_MOVIME := AllTrim(cDescMov)
EndIf

//Gravação do arquivo anexo
//nP := aScan(aAnexos,{|a| a[1] == cItemZ48})
nP := aScan(aCols,{|a| a[1] == cItemZ48})
If nP > 0

	cPastaCod   := STRTRAN(Z48->Z48_PROPOS,"/","_")+(Z48->Z48_REVISA) + "\"
	cPastaItem  := AllTrim(Z48->Z48_ITEM) + "\"

	cPasta := cPastaAnexo+cPastaCod+cPastaItem

	//Monta o diretório de gravação dos anexos.		
	If !ExistDir(cPasta)
		If !MontaDir(cPasta)
			MsgInfo("Não foi possivel criar o diretório especifico de gravação de anexos","Atenção")
        	Return .F.
		EndIf
	EndIf		
	
	cArquiv := aCols[nP][5]
	nAt := 1
	While nAt > 0
       	nAt := At("\",cArquiv)
    	cArquiv := Substr(cArquiv,nAt+1,Len(cArquiv))
	EndDo
	
	//Retira o acento do nome do arquivo
	cArquiv:=NoAcento(cArquiv)
	        
	cOrig := AllTrim(aCols[nP][5])
	cDest := Alltrim(cPasta)

	if !__COPYFILE( cOrig, cTempPat+alltrim(cArquiv) )
       	MsgInfo("O arquivo anexo não foi copiado.","Atenção")
       	Return .F.    
    endif
            
	//Realiza a copia para a pasta da proposta.
  	//If !Cpyt2s(cOrig,cDest,.F.)
  	If !Cpyt2s(cTempPat+alltrim(cArquiv),cDest,.F.)
       	MsgInfo("O arquivo anexo não foi copiado.","Atenção")
       	Return .F.
	Else
		//Grava o nome do arquivo
		Z48->Z48_ARQUIV := AllTrim(cArquiv)

	EndIf
	
EndIf

Z48->(MsUnlock())

Return .T.

/*
Funcao      : EnvMaiSo
Parametros  : (cTo)
Retorno     : Nil
Objetivos   : Cria corpo do e-mail e chama a função para envio
Autor       : Matheus Massarotto
Data/Hora   : 01/02/2013 16:25
*/

*-------------------------*
Static Function EnvMaiSo(cTo,nOpc)
*-------------------------*
Local nHora		:= VAL(SUBSTR(TIME(),1,2))
Local cHtml		:= ""
Local aTipos	:= ""
Local cTipoDes	:= ""
Local cNomRef	:= ""
Local cPosic	:= ""
Local aArea		:= GetARea()
Local cQry1		:= ""
Local cNomeClie	:= ""
Local cSubject  := ""

	if nOpc==8 //Envio para aprovação
		//Tratamento para enviar e-mail
		cHtml:=' <html style="padding: 0px; margin: 0px;">
		cHtml+=' <head>
		cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
		cHtml+=' </head>
		cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000"><div><span>
		//cHtml+=' <div align="left">
		cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 60.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
		cHtml+=' <tbody>
		cHtml+=' <tr>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;<img dfsrc="cid:DWT232" src="http://www.grantthornton.com.br/images/logo.gif" width=400></p></td>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;
		cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
		cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US;'
		cHtml+='	mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt;'
		cHtml+='	mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%;'
		cHtml+='	FONT-FAMILY: '+"'Georgia','serif'"+'; FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri;'
		cHtml+='	mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR;'
		cHtml+='	mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | Propostas</font></strong></span></span></p></td></tr>
		//cHtml+=' </tbody></table></div><br>

		cHtml+=' <tr>
		cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">		
		cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo está aguardando sua análise e aprovação: </span></span>
		cHtml+=' </div>
		cHtml+=' </tbody>
		
		cHtml+=' <tr><td colspan="2">
		
		cHtml+=' <p><span></span>&nbsp;</p>
		cHtml+=' <p><span>&nbsp;</span></p>
		cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
		cHtml+=' <colgroup>
		cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
		cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' </colgroup>
		
	
		cHtml+=' <tbody>
		cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Número</font></strong></p>
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">'+IIF(!empty(M->Z55_NOME),"Cliente","Prospect")+'</font></strong></p></td>
	   
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Valor Líquido</font></strong></p>
		cHtml+=' </td>
		
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Valor Bruto</font></strong></p>
		cHtml+=' </td>
		
		cHtml+=' </tr>
			
		cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
		cHtml+=' <font size="2" face="Calibri">'+AllTrim(M->Z55_NUM)+'</font>'
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+IIF(!empty(M->Z55_NOME),alltrim(M->Z55_NOME),alltrim(M->Z55_PNOME))+'</font> '
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
		cHtml+=' <font size="2" face="Calibri">'+Transform(M->Z55_VLRLIS,'@E 99,999,999,999.99')+'</font>'
		cHtml+=' </td>

		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
		cHtml+=' <font size="2" face="Calibri">'+Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99')+'</font>'
		cHtml+=' </td>
		
		cHtml+=' </tr>
			
		cHtml+=' </tbody></table><span></span>
		
		cHtml+=' <br>

		cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
		cHtml+=' <colgroup>
		cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' </colgroup>
		cHtml+=' <tbody>
		cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
	
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Serviço</font></strong></p></td>
	   
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Horas</font></strong></p>
		cHtml+=' </td>

		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Tx.Média</font></strong></p>
		cHtml+=' </td>
		
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Tx.Média c/ Surcharge</font></strong></p>
		cHtml+=' </td>
		
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">% de Recuperação</font></strong></p>
		cHtml+=' </td>
										
		cHtml+=' </tr>
		
		//Preenche os itens
		DbSelectArea("Z54")
		Z54->(DbSetORder(2))
		if Z54->(DbSeek(xFilial("Z54")+M->Z55_NUM+M->Z55_REVISA))
			While Z54->(!eof()) .AND. Z54->Z54_FILIAL==M->Z55_FILIAL .AND. Z54->Z54_NUMPRO==M->Z55_NUM .AND. Z54->Z54_REVISA==M->Z55_REVISA

				cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <font size="2" face="Calibri">'+alltrim(Z54->Z54_DESCDI)+ " " + alltrim(Z54->Z54_DESCNA)+'</font> '
				cHtml+=' </td>
			
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
				cHtml+=' <font size="2" face="Calibri">'+AllTrim(Str(Z54->Z54_HORAPR))+'</font>'
				cHtml+=' </td>

				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
				cHtml+=' <font size="2" face="Calibri">'+Transform(Z54->Z54_TAXAME,'@E 9,999.99')+'</font>'
				cHtml+=' </td>
				
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
				cHtml+=' <font size="2" face="Calibri">'+Transform(Z54->Z54_TXMESU,'@E 9,999.99')+'</font>'
				cHtml+=' </td>

				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
				cHtml+=' <font size="2" face="Calibri">'+alltrim(Str(Z54->Z54_RECUPE))+'</font>'
				cHtml+=' </td>
														
				cHtml+=' </tr>

			Z54->(DbSkip())
			enddo
		endif
		cHtml+=' </tbody></table>
		
		cHtml+=' </td></tr>
		cHtml+=' <tr><td>
		
		cHtml+=' <p><br><br><br>&nbsp;</p>
		
		cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
		cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>
		
		cHtml+=' </td></tr>
		cHtml+=' </table>
		
		cHtml+=' </body>
		cHtml+=' </html>

	elseif nOpc==7	//Retorno da aprovação

		//Tratamento para enviar e-mail
		cHtml:=' <html style="padding: 0px; margin: 0px;">
		cHtml+=' <head>
		cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
		cHtml+=' </head>
		cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000"><div><span>
		//cHtml+=' <div align="left">
		cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 60.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
		cHtml+=' <tbody>
		cHtml+=' <tr>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;<img dfsrc="cid:DWT232" src="http://www.grantthornton.com.br/images/logo.gif" width=400></p></td>
		cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p>&nbsp;
		cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
		cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US;'
		cHtml+='	  mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt;'
		cHtml+='	  mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%;'
		cHtml+='	  FONT-FAMILY: '+"'Georgia','serif'"+'; FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri;'
		cHtml+='	  mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR;'
		cHtml+='	  mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | Propostas</font></strong></span></span></p>
		cHtml+=' </td></tr>


		//cHtml+=' </table>
		//cHtml+=' </div><b>
		cHtml+=' <tr>
		cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
		cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo foi retornada após validação interna: </span></span>
		cHtml+=' </td></tr>
		cHtml+=' </div>
		cHtml+=' </tbody>
				
		cHtml+=' <tr><td colspan="2">
		
		cHtml+=' <p><span></span>&nbsp;</p>
		cHtml+=' <p><span>&nbsp;</span></p>
		
		cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
		cHtml+=' <colgroup>
		cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
		cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
		cHtml+=' </colgroup>
		
		cHtml+=' <tbody>
		cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Número</font></strong></p>
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">'+IIF(!empty(M->Z55_NOME),"Cliente","Prospect")+'</font></strong></p></td>
	   
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Parecer</font></strong></p>
		cHtml+=' </td>
		
		cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="186">
		cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Observação</font></strong></p>
		cHtml+=' </td>
		
		cHtml+=' </tr>
			
		cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
		cHtml+=' <font size="2" face="Calibri">'+AllTrim(M->Z55_NUM)+'</font>'
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <font size="2" face="Calibri">'+IIF(!empty(M->Z55_NOME),alltrim(M->Z55_NOME),alltrim(M->Z55_PNOME))+'</font> '
		cHtml+=' </td>
	
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">

		//Pego o status ta proposta para exibir como parecer
		DbSelectArea("Z45")
		Z45->(DbSetOrder(1))
		if Z45->(DbSeek(xFilial("Z45")+Z55->Z55_STATUS))
			cHtml+=' <font size="2" face="Calibri">'+alltrim(Z45->Z45_LEGEND)+'</font>'
		endif
		
		cHtml+=' </td>

		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl67" width="186">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(M->Z55_OBSGT)+'</font>'
		cHtml+=' </td>
		
		cHtml+=' </tr>
			
		cHtml+=' </tbody></table><span></span>
		
		cHtml+=' </td></tr>
		cHtml+=' <tr><td>
		
		cHtml+=' <p><br><br><br>&nbsp;</p>
		 
		cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
		cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>
		
		cHtml+=' </td></tr>
		cHtml+=' </table>
		
		cHtml+=' </body>
		cHtml+=' </html>
		

	endif


	if empty(cTo)
	
		//UsrRetMail ( [ cCodUsr ] ) -- Retorna o e-mail do usuário
		cTo:=UsrRetMail(__cUserID)
		if nOpc==7
			cSubject:="Erro ao enviar e-mail de retorno, cliente - "+cNomeClie+"- n: "+alltrim(M->Z55_NUM)
		else
			cSubject:="Erro ao enviar e-mail para aprovador, cliente - "+cNomeClie+"- n: "+alltrim(M->Z55_NUM)
	    endif
	else
	    if nOpc==7
			cSubject:=CAPITAL(alltrim(UsrRetName (__cUserID)))+" retornou a proposta - "+cNomeClie+"- n: "+alltrim(M->Z55_NUM)
	    else
			//UsrRetName(id usuário)- Nome do usuário corrente ()
			cSubject:=CAPITAL(alltrim(UsrRetName (__cUserID)))+" enviou uma proposta para ser aprovada - "+cNomeClie+"- n: "+alltrim(M->Z55_NUM)
		endif
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
Data/Hora   : 01/02/2013 16:25
*/
*------------------------------------------*
Static Function EnviaEma(cHtml,cSubject,cTo)
*------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""
//Local cTo			:= "matheus.massarotto@br.gt.com" //alterar aqui remover aqui

Default cTo		 := ""
Default cSubject := ""

If cEmpAnt $ "99" .OR. "TESTE" $ alltrim(UPPER(GetEnvServer()))
	//cTo := "matheus.massarotto@br.gt.com;eduardo.romanini@br.gt.com"
	cTo := "matheus.massarotto@br.gt.com"
	If cEmpAnt $ "99"
		cTo := "matheus.massarotto@br.gt.com"
	EndIf
EndIf

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
	conout("GTCORP73--->>> E-mail enviado com sucesso, para o aprovador da proposta")
ELSE
	conout("GTCORP73--->>> Falha no envio do e-mail, para o aprovador da proposta")
ENDIF

RETURN .T.


/*
Funcao      : Z55_PRCL
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se o prospect ou cliente tem o conflito OK
Autor       : Matheus Massarotto
Data/Hora   : 08/04/2013
*/
*-------------------------------*
User Function Z55_PRCL(cProCli)
*-------------------------------*
Local lRet		:= .T.
Local cSta		:= ""
Local cCodCli	:= ""
Local cConfli	:= ""

Local cConfli	:= ""

Local aArea		:= GETAREA()

DEFAULT cProCli:=""

if UPPER(cProCli)=="CLI"
	
	SA1->(DbSetOrder(1))
	if SA1->(DbSeek(xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA))
		cConfli	:= SA1->A1_P_CONFL
		
		if cConfli<>'1'
			Alert("Cliente não tem o conflito OK!")
			lRet:=.F.	
		endif
	endif
	
elseif UPPER(cProCli)=="PRO"

	cSta	:= POSICIONE("SUS",1,xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA,"US_STATUS")
	cCodCli	:= SUS->US_CODCLI
	cConfli	:= SUS->US_P_CONFL
	
	if alltrim(cSta)=='6'
		Alert("Prospect já é cliente com código: "+cCodCli)
		lRet:=.F.
	elseif cConfli<>'1'
		Alert("Prospect não tem o conflito OK!")
		lRet:=.F.	
	endif

endif

RESTAREA(aArea)
Return lRet


/*
Funcao      : GT55Filtro
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Matheus Massarotto
Data/Hora   : 03/07/11 17:00
*/
*------------------------------------------------*
User Function GT55Filtro(lExibe,cAlias,aIndexZ55,cFiltro)
*------------------------------------------------*
//Local cArea    	:= (cAlias)->(GetArea())
Local cPerg		:= "GTCORP73"
Local cFiltro	:= ""
Local cIdUser	:= __cUserID // Id do usuário logado
Local cQry		:= ""
Local cClients	:= ""
Local cProspects:= ""


aHelpPor1:={"Informe a Data de Inclusão"}
aHelpPor2:={"Informe a Data de Inclusão"}

//Definição da pergunta
PutSx1(cPerg , "01","Data de  ?" 		," "," ","mv_ch01","D",08,0,0,"G","     ","","","","MV_PAR01",""	,"","","01/01/00",""	,"","" ,"","","","","","","",""," ",aHelpPor1)
PutSx1(cPerg , "02","Data ate ?" 		," "," ","mv_ch02","D",08,0,0,"G","     ","","","","MV_PAR02",""	,"","","01/01/49",""	,"","" ,"","","","","","","",""," ",aHelpPor2)
PutSx1(cPerg , "03","Exibe Revisado ?" 	," "," ","mv_ch03","N",01,0,0,"C","     ","","","","MV_PAR03","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")
PutSx1(cPerg , "04","Exibe Finalizado ?"," "," ","mv_ch04","N",01,0,0,"C","     ","","","","MV_PAR04","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")
PutSx1(cPerg , "05","Exibe Perdido ?"	," "," ","mv_ch05","N",01,0,0,"C","     ","","","","MV_PAR05","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")

//Inicializa as variaveis de pergunta.
Pergunte(cPerg,lExibe,"Filtro de exibição")

//Verifica se o usuário pode ver todas as propostas
DbSelectArea("Z42")
Z42->(DbSetOrder(1))
if Z42->(DbSeek(xFilial("Z42")+cIdUser))
	if Z42->Z42_LADMIN
		lFilter:=.F.
	else
	    if Z42->Z42_LVISP
			lFilter:=.F.
		else
			cFiltro:="( Z55_USERRE = '"+cIdUser+"'"
			
			//Filtro para sócio e gerente visualizarem as propostas que eles estão selecionados
			DbSelectArea("Z42")
			Z42->(DbSetOrder(1))
			if Z42->(DbSeek(xFilial("Z42")+cIdUser))
				cFiltro+=" OR Z55_SOCIO = '"+Z42->Z42_CPF+"'"
				cFiltro+=" OR Z55_GERENT = '"+Z42->Z42_CPF+"'"

			endif			        
			
			//Filtro para sócios e gerentes visualizarem suas propostas nos quais eles estão na aba de serviços
			cFiltro+=" OR Z55_FILIAL+Z55_NUM+Z55_REVISA IN ("
			cFiltro+=" SELECT Z29_FILIAL+Z29_NUMPRO+Z29_REVISA FROM "+RETSQLNAME("Z29")+" Z29"
			cFiltro+=" WHERE Z29.D_E_L_E_T_='' AND (Z29_SOCIO ='"+Z42->Z42_CPF+"' OR Z29_GERENT='"+Z42->Z42_CPF+"')
			cFiltro+=" )"
			
			//--Para sócios visualizarem as proposta que são responsáveis pelo prospect/cliente
			//Cliente
			cFiltro+=" OR Z55_CLIENT+Z55_LOJA IN ( SELECT A1_COD+A1_LOJA FROM "+RETSQLNAME("SA1")
			cFiltro+=" WHERE A1_P_SOCIO='"+Z42->Z42_CPF+"' AND D_E_L_E_T_='')"
			
			//Prospect            
			cFiltro+=" OR Z55_PROSPE+Z55_PLOJA IN ( SELECT US_COD+US_LOJA FROM "+RETSQLNAME("SUS")
			cFiltro+=" WHERE US_P_SOCIO='"+Z42->Z42_CPF+"' AND D_E_L_E_T_='' )"
			
			cFiltro+=" )"
			
			
		endif
	endif
else
	Alert("Você não tem permissão para operar esta rotina!"+CRLF+"Solicite ao seu superior ou administrador que cadastre sua alçada do controle de propostas!")
	Return(.F.)
endif


if !empty(cFiltro)
	cFiltro+=" AND "
endif

//Filtro para a data
	cFiltro += "( Z55_DTINC >= '"+DTOS(MV_PAR01)+"' AND Z55_DTINC <= '"+DTOS(MV_PAR02)+"' )"

//Não exibir as propostas revisadas
If MV_PAR03 == 2
	
	cQrySta:=" SELECT Z46_DESCRI,Z46_CODLEG FROM "+RETSQLNAME("Z46")+" Z46
	cQrySta+=" JOIN "+RETSQLNAME("Z47")+" Z47 ON Z46.Z46_CODACA=Z47.Z47_CODIGO
	cQrySta+=" WHERE Z46.D_E_L_E_T_='' AND Z47.Z47_NOPC='6'

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0

		QRYTEMP->(DbGotop())
			
		cFiltro += " AND "
		cFiltro += " (Z55_STATUS <> '"+QRYTEMP->Z46_CODLEG+"')"
			
	endif	
	

EndIf

//Não exibir as propostas finalizadas
If MV_PAR04 == 2
	
	cQrySta:=" SELECT Z46_DESCRI,Z46_CODLEG FROM "+RETSQLNAME("Z46")+" Z46
	cQrySta+=" JOIN "+RETSQLNAME("Z47")+" Z47 ON Z46.Z46_CODACA=Z47.Z47_CODIGO
	cQrySta+=" WHERE Z46.D_E_L_E_T_='' AND Z47.Z47_NOPC='E'

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0

		QRYTEMP->(DbGotop())
			
		cFiltro += " AND "
		cFiltro += " (Z55_STATUS <> '"+QRYTEMP->Z46_CODLEG+"')"
			
	endif	
	
EndIf


//Não exibir as propostas finalizadas
If MV_PAR05 == 2
	
	cQrySta:=" SELECT Z46_DESCRI,Z46_CODLEG FROM "+RETSQLNAME("Z46")+" Z46
	cQrySta+=" JOIN "+RETSQLNAME("Z47")+" Z47 ON Z46.Z46_CODACA=Z47.Z47_CODIGO
	cQrySta+=" WHERE Z46.D_E_L_E_T_='' AND Z47.Z47_NOPC='B' AND UPPER(Z46.Z46_DESCRI) LIKE '%PERDIDA%'"

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0

		QRYTEMP->(DbGotop())
		
		cFiltro += " AND "
		cFiltro += " (Z55_STATUS <> '"+QRYTEMP->Z46_CODLEG+"')"
			
	endif	
	
EndIf


	//Verifica se o filtro foi reformulado.
	If lExibe
		//Tratamento especial para filtro através de query no mbrowse
		cFiltro:="@"+cFiltro
		_oObj := GetObjBrow()
		DbSelectArea("Z55")
		
		if len(_oObj:OFwFilter:Afilter)>0
			_oObj:OFwFilter:Afilter[1][2]:=cFiltro
			_oObj:ExecuteFilter()
		endif
		_oObj:GoTop() 
		//_oObj:ResetLen()
		_oObj:Refresh()
	Endif



Return(.T.)

/*
Funcao      : SelDraft
Parametros  : 
Retorno     : Nil
Objetivos   : Exibe tela para seleção do draft
Autor       : Matheus Massarotto
Data/Hora   : 23/05/13 12:00
*/

*------------------------*
Static function SelDraft()
*------------------------*
Local cDraft
Local lRet	:= .F.
//Abri a consulta padrão de draft
lRet:=CONPAD1(,,,"Z74",cDraft)

	if !lRet
		Return(lRet)
	endif

cDraft:=Z74->Z74_NUM

Return(cDraft)
    
/*
Funcao      : GrvClVl
Parametros  : 
Retorno     : Nil
Objetivos   : Grava Classe de Valor ao incluir uma proposta
Autor       : Renato Rezende
Data/Hora   : 05/06/13 17:10
*/

*------------------------*
Static function GrvClVl(cNum)
*------------------------*
Local cNome	:=""

DbSelectArea("CTH")
DbSelectArea("SA1")
DbSelectArea("SUS")
CTH->(DbSetOrder(1))
//Inclusão da Classe de Valor caso não exista nenhum código igual no CTH
If !(CTH->(DbSeek(xFilial("CTH")+cNum)))
	//Verifica se ira buscar a descrição do cadastro de cliente ou Prospect 
	If Empty(M->Z55_CLIENT) 
		SUS->(DbSeek(xFilial("SUS")+M->Z55_PROSPE))
		cNome:= SUS->US_NOME
	Else
		SA1->(DbSeek(xFilial("SA1")+M->Z55_CLIENT))
		cNome:= SA1->A1_NOME			
	EndIf
	RecLock("CTH",.T.)
	CTH->CTH_FILIAL	:= xFilial("CTH")
	CTH->CTH_CLVL	:= cNum
	CTH->CTH_CLASSE	:= '2'
	CTH->CTH_NORMAL	:= '1'
	CTH->CTH_DESC01	:= cNome
	CTH->CTH_BLOQ	:= '2'
	CTH->CTH_DTEXIS	:= CtoD('01/01/1980')
	CTH->CTH_CLVLLP	:= cNum
	CTH->(MsUnlock())
	
	//MsgInfo("Foi gerada a Classe de valor: "+cNum)
Else 
	//MsgInfo("Não foi possível gerar a Classe de Valor Automática. O código "+cNum)	

EndIf

Return

/*
Funcao      : Z54CUSTO
Parametros  : 
Retorno     : nTotal
Objetivos   : Gatilhar para o campo Z55_VLRLIQ o valor de todos os serviços (Utilizado em gatilho SX7)
Autor       : Matheus Massarotto
Data/Hora   : 01/08/2013
*/
*---------------------*
User function Z54CUSTO
*---------------------*
Local nTotal	:=0
//Local nPosCus	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CUSTOT"})
//Local nPosTaxa	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_TAXAME"})
//Local nPosHora	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_HORAPR"})
Local nPosVlLiq	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_PRECOL"})

//DbSelectArea("Z81")
//DbSetOrder(1)

For i:=1 to len(aCols)
//	nTotal	+=aCols[i][nPosCus]
    
    //Verifica se a linha não está deletada
    If !(aCols[i][Len(aCols[i])])
		//nTotal	+=((aCols[i][nPosTaxa])*(aCols[i][nPosHora]))
		nTotal	+= aCols[i][nPosVlLiq]
	EndIf
Next

//Preço Liquido
//M->Z55_VLRCAL:=nTotal
M->Z55_VLRLIQ :=nTotal

//Preço Liquido + Surcharge
M->Z55_VLRLIS := nTotal + (nTotal * (M->Z55_SURCHA/100))

//Preço Total com Impostos
//M->Z55_VLRTOT := M->Z55_VLRLIS + (M->Z55_VLRLIS * (M->Z55_IMPOST/100))
M->Z55_VLRTOT := M->Z55_VLRLIS/((100-M->Z55_IMPOST)/100)

//para atualizar a tela com os dados novos
GetDRefresh()	

return(nTotal)

/*
Funcao      : VLD_GT73()  
Parametros  : 
Retorno     : .T. ou .F.
Objetivos   : Função para validação do aCols
Autor       : Matheus Massarotto
Data/Hora   : 09/08/2013
*/
*---------------------*
User Function VLD_GT73
*---------------------*
Local nPos	:= Ascan(aHeaZ52,{|x| alltrim(x[2]) = "Z52_CODIGO"})
Local lRet	:= .T.

for i:=1 to len(oGetDadDes:aCols)
	if oGetDadDes:nAt==i
		Loop
	endif
    
    if nPos==oGetDadDes:oBrowse:nColpos
		if alltrim(oGetDadDes:aCols[i][nPos])==alltrim(M->Z52_CODIGO) //oGetDados:aCols[oGetDados:nAt][nPos]
			alert("Despesa já está inserida!")
			lRet:=.F.
		endif
	endif
next

Return(lRet)

/*
Funcao      : GravaPro()  
Parametros  : aCols,aHeader
Retorno     : 
Objetivos   : Função para gravar na tabela de muro o projeto
Autor       : Matheus Massarotto
Data/Hora   : 12/08/2013
*/
*--------------------------------------*
Static function GravaPro(aCols,aHeader)
*--------------------------------------*
Local cQry		:= ""
Local cCampos   := ""
Local cConteu	:= ""

nPosCodSe	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODIGO"})
nPosDtIni	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_DTAINI"})
nPosDtFim	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_DTAFIM"})
nPosRecor	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_RECORR"})
nPosRecQt	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_RECQTD"})
nPosAnoin	:= Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_ANOINI"})

	for i:=1 to len(aCols)

   		for j:=1 to len(aHeader)
   			if j==nPosCodSe
   				cCampos+=aHeader[j][2]+','
   				cConteu+="'"+alltrim(aCols[i][j])+"'"+','
            elseif j==nPosDtIni
   				cCampos+=aHeader[j][2]+','
   				cConteu+="'"+alltrim(DTOS(aCols[i][j]))+"'"+','
  			elseif j==nPosDtFim
   				cCampos+=aHeader[j][2]+','
   				cConteu+="'"+alltrim(DTOS(aCols[i][j]))+"'"+','
			elseif j==nPosRecor
   				cCampos+=aHeader[j][2]+','
   				cConteu+="'"+alltrim(aCols[i][j])+"'"+','
			elseif j==nPosRecQt
   				cCampos+=aHeader[j][2]+','
   				cConteu+="'"+alltrim(aCols[i][j])+"'"+','
   			elseif j==nPosAnoin
   				cCampos+=aHeader[j][2]+','
   				cConteu+="'"+alltrim(aCols[i][j])+"'"+','
   			endif
   		next
        
		if !cEmpAnt $ "99" .AND. !"TESTE" $ alltrim(UPPER(GetEnvServer()))
			if !empty(cCampos) .and. !empty(cConteu)
			    
			    
			    cCampos+="M0_CODIGO,M0_CODFIL,M0_CGC,"
			    cConteu+="'"+SM0->M0_CODIGO+"',"+"'"+SM0->M0_CODFIL+"',"+"'"+SM0->M0_CGC+"',"
                
				//Adicionado 01/11/2013, pois o Luciano incluiu novo campo.
			    cCampos+="A1_NOME,"
			    cConteu+="'"+Substr(Z55->Z55_NOME,1,50)+"',"
                
				if nPosRecor<=0
					//Adicionado 04/11/2014, pois a tabela INT_PROJETOS não aceita valores nulos, para o campo.
				    cCampos+="Z54_RECORR,"
				    cConteu+="'N',"
			    endif
			    
			    if nPosRecQt<=0
					//Adicionado 04/11/2014, pois a tabela INT_PROJETOS não aceita valores nulos, para o campo.
				    cCampos+="Z54_RECQTD,"
				    cConteu+="'0',"
				endif
				
				if nPosAnoin<=0
					//Adicionado 04/11/2014, pois a tabela INT_PROJETOS não aceita valores nulos, para o campo.
				    cCampos+="Z54_ANOINI,"
				    cConteu+="'0',"				
				endif
							    			    
			    cCampos:=SUBSTR(cCampos,1,len(cCampos)-1)
	   			cConteu:=SUBSTR(cConteu,1,len(cConteu)-1)
			    cQry:="INSERT INTO Controle.dbo.INT_PROJETOS("+cCampos+") VALUES("+cConteu+")"
	            
				nCon := TCLink("MSSQL/Controle","10.0.30.5",7894)
	            
				If nCon < 0
					MsgInfo("Erro ("+str(nCon,4)+") ao conectar com banco de dados.")
				Else
					if TCSQLExec(cQry) < 0
						MsgInfo("Não foi possível gravar o projeto!"+CRLF+CRLF+TCSQLError())
				    endif
					
					TCUnlink(nCon)
				EndIf
	
				cCampos	:= ""
				cConteu	:= ""
				cQry	:= ""
			endif
		endif
    next

Return


*-----------------------*
User Function GT73Next()
*-----------------------*
Local oScr,oBtn1
Local aRotina 	:= {}
Local coBtn		:="oBtn"
Local cVar		:="cRotina"
Local cNopcAtu	:=""
Local cIdUser	:= __cUserID // Id do usuário logado


//Verifico se a pessoa tem permissão para manipular a proposta, deve ser o sócio da proposta ou quem incluiu
DbSelectArea("Z42")
Z42->(DbSetOrder(1))
if Z42->(DbSeek(xFilial("Z42")+cIdUser))
	
	if Z55->Z55_USERRE <> cIdUser .AND. Z55->Z55_SOCIO <> Z42->Z42_CPF .AND. Z55->Z55_GERENT <> Z42->Z42_CPF .and. !Z42->Z42_LADMIN
 		alert("Você não tem permissão para manipular a proposta selecionada!")
	   	Return
    endif
    
endif
/*
DbSelectArea("Z46")
Z46->(DbSetOrder(1))
if DbSeek(xFilial("Z46")+Z55->Z55_STATUS)
	
	DbSelectArea("Z47")
	Z47->(DbSetOrder(1))
	if Z47->(DbSeek(xFilial("Z47")+Z46->Z46_CODACA))
		cNopcAtu:=Z47->Z47_NOPC //Pego o nopc atual
	endif
	
	While Z46->(!EOF()) .AND. Z46->Z46_CODACA==Z55->Z55_STATUS
		
		DbSelectArea("Z47")
		Z47->(DbSetOrder(1))
		if Z47->(DbSeek(xFilial("Z47")+Z46->Z46_CODIGO))
		    
		    if cNopcAtu=='8'
				if Z55->Z55_APROVA == cIdUser
					AADD( aRotina, { alltrim(Z47->Z47_PASSO)	, 'U_GTCORP72("Z55",Z55->(RECNO()),'+Z47->Z47_NOPC+',"'+Z47->Z47_CODIGO+'")' 	, 0 , Z47->Z47_NOPC } )					
				endif
			elseif cNopcAtu=='9' //Pool
			
			else
				AADD( aRotina, { alltrim(Z47->Z47_PASSO)	, 'U_GTCORP72("Z55",Z55->(RECNO()),'+Z47->Z47_NOPC+',"'+Z47->Z47_CODIGO+'")' 	, 0 , Z47->Z47_NOPC } )
		    endif
		    
		endif
		
		Z46->(DbSkip())
	Enddo
*/


DbSelectArea("Z44")
Z44->(DbSetOrder(1))
if DbSeek(xFilial("Z44")+Z55->Z55_STATUS)
	
	
	While Z44->(!EOF()) .AND. Z44->Z44_CODLEG==Z55->Z55_STATUS
		
		DbSelectArea("Z45")
		Z45->(DbSetOrder(1))
		if Z45->(DbSeek(xFilial("Z45")+Z44->Z44_CODACA))
		    
		    //Posiciono na acao para pegar o nOpc
	    	DbSelectArea("Z47")
			Z47->(DbSetOrder(1))
			if Z47->(DbSeek(xFilial("Z47")+Z44->Z44_CODACA))
				cNopcAtu:=Z47->Z47_NOPC //Pego o nopc atual
			endif
			
		    
		    if cNopcAtu=='7'
				if Z55->Z55_APROVA == cIdUser
					AADD( aRotina, { alltrim(Z47->Z47_ACAO)	, 'U_GTCORP72("Z55",Z55->(RECNO()),"'+Z47->Z47_NOPC+'","'+Z47->Z47_CODIGO+'")' 	, 0 , Z47->Z47_NOPC } )					
				endif
			elseif cNopcAtu=='9' //Conflito
				//não faz nada
			elseif cNopcAtu=='I' //Pool
				//não faz nada
			elseif cNopcAtu=='F'
				if empty(Z55->Z55_DTASSI)
					AADD( aRotina, { alltrim(Z47->Z47_ACAO)	, 'U_GTCORP72("Z55",Z55->(RECNO()),"'+Z47->Z47_NOPC+'","'+Z47->Z47_CODIGO+'")' 	, 0 , Z47->Z47_NOPC } )
				endif
			else
				AADD( aRotina, { alltrim(Z47->Z47_ACAO)	, 'U_GTCORP72("Z55",Z55->(RECNO()),"'+Z47->Z47_NOPC+'","'+Z47->Z47_CODIGO+'")' 	, 0 , Z47->Z47_NOPC } )
		    endif
		    
		endif
		
		Z44->(DbSkip())
	Enddo


endif


if !empty(aRotina)

	DEFINE DIALOG oDlg TITLE "Opções" FROM 155,430 To 456,706 PIXEL 
	
	oScr 		:= TScrollBox():New(oDlg,000,008,112,176,.T.,.T.,.T.)
	oScr:align	:= CONTROL_ALIGN_ALLCLIENT
	nLinha		:= 4
	
	for i:=1 to len(aRotina)
	    //Criando variáveis, dinamicamente para armazenar a rotina
		cVar	:= "cRotina"+cvaltochar(i)
		&(cVar)	:= aRotina[i][2]
		
		&(coBtn+cvaltochar(i)):=TButton():New( nLinha,004,aRotina[i][1],oScr, &("{|| oDlg:end(),"+&(cVar)+" }") ,124,012,,,,.T.,,"",,,,.F. )
		//oBtn1	:= TButton():New( 004,004,"oBtn1",oScr,{||alert("11")},124,012,,,,.T.,,"",,,,.F. )
	
		nLinha+=20
	next

	ACTIVATE DIALOG oDlg CENTERED 

else
	MsgInfo("Nenhuma ação disponível para este item!","Atenção")
endif

// Chamada para manter o filtro na tabela
//U_GT55Filtro(.F.,"Z55",aIndexZ55)

Return(.T.)

//Função para gravar a legenda e o status
*--------------------------------------*
Static function GravLege(xParam4,nOpc)
*--------------------------------------*
Local cQrySta	:= ""
Local oRadio,oDlg1,oBtn1
Local nRadio 	:= 1    
Local aOpcoes	:= {}

	if nOpc = 3	
		cQrySta:=" SELECT Z46_DESCRI,Z46_CODLEG,Z46_LEGSUB,Z46_DESSUB FROM "+RETSQLNAME("Z46")+" Z46
		cQrySta+=" JOIN "+RETSQLNAME("Z47")+" Z47 ON Z46.Z46_CODACA=Z47.Z47_CODIGO
		cQrySta+=" WHERE Z46.D_E_L_E_T_='' AND Z47.Z47_NOPC='3'
    else
   		cQrySta:=" SELECT Z46_DESCRI,Z46_CODLEG,Z46_LEGSUB,Z46_DESSUB FROM "+RETSQLNAME("Z46")+" Z46"
		cQrySta+=" WHERE Z46.D_E_L_E_T_='' AND Z46_CODACA='"+cvaltochar(xParam4)+"'    
    endif
    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0

		QRYTEMP->(DbGotop())	

		if nRecCount >1

			While QRYTEMP->(!EOF())
				AADD(aOpcoes,alltrim(QRYTEMP->Z46_CODLEG)+'-'+alltrim(QRYTEMP->Z46_DESCRI))
				QRYTEMP->(DbSkip())
			Enddo			
			
			DEFINE DIALOG oDlg1 TITLE "Opções proposta" FROM 155,430 To 336,670 PIXEL STYLE DS_MODALFRAME // Cria Dialog sem o botão de Fechar.
		
			oRMenu1   := TGroup():New( 004,004,068,116,"Selecione uma posicição:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
			oRadio    := TRadMenu():New( 015,010,aOpcoes,,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,092,64,,.F.,.F.,.T. )
			oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
			
			oBtn1      := TButton():New( 072,044,"Ok",oDlg1,{|| oDlg1:end()},037,012,,,,.T.,,"",,,,.F. )			
	
			ACTIVATE DIALOG oDlg1 CENTERED

	
		endif

	
		if !empty(aOpcoes)

			cQrySub:=" SELECT Z46_DESCRI,Z46_CODLEG,Z46_LEGSUB,Z46_DESSUB FROM "+RETSQLNAME("Z46")+" Z46"
			cQrySub+=" WHERE Z46.D_E_L_E_T_='' AND Z46_CODACA='"+cvaltochar(xParam4)+"' AND Z46_CODLEG='"+SUBSTR(aOpcoes[nRadio],1,AT("-",aOpcoes[nRadio])-1)+"' AND Z46_LEGSUB<>''"
	
			if select("QRYSUB")>0
				QRYSUB->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySub), "QRYSUB", .F., .F. )
			
			Count to nRecSub
		        
			if nRecSub >0
				QRYSUB->(DbGotop())	
				
				RecLock("Z55",.F.)			
					Z55->Z55_STATUS:=QRYSUB->Z46_LEGSUB
		        	Z55->Z55_DESCST:=alltrim(QRYSUB->Z46_DESSUB)
		        Z55->(MsUnlock())						
			else
				RecLock("Z55",.F.)			
					Z55->Z55_STATUS:=SUBSTR(aOpcoes[nRadio],1,AT("-",aOpcoes[nRadio])-1)
		        	Z55->Z55_DESCST:=SUBSTR(aOpcoes[nRadio],AT("-",aOpcoes[nRadio])+1,len(aOpcoes[nRadio]))
		        Z55->(MsUnlock())			
			endif

		else

			cQrySub:=" SELECT Z46_DESCRI,Z46_CODLEG,Z46_LEGSUB,Z46_DESSUB FROM "+RETSQLNAME("Z46")+" Z46"
			cQrySub+=" WHERE Z46.D_E_L_E_T_='' AND Z46_CODACA='"+cvaltochar(xParam4)+"' AND Z46_CODLEG='"+QRYTEMP->Z46_CODLEG+"' AND Z46_LEGSUB<>''"
	
			if select("QRYSUB")>0
				QRYSUB->(DbCloseArea())
			endif
			
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySub), "QRYSUB", .F., .F. )
			
			Count to nRecSub

			if nRecSub >0
				QRYSUB->(DbGotop())	
				
				RecLock("Z55",.F.)			
					Z55->Z55_STATUS:=QRYSUB->Z46_LEGSUB
		        	Z55->Z55_DESCST:=alltrim(QRYSUB->Z46_DESSUB)
		        Z55->(MsUnlock())						
			else
				RecLock("Z55",.F.)			
					Z55->Z55_STATUS:=QRYTEMP->Z46_CODLEG
		        	Z55->Z55_DESCST:=alltrim(QRYTEMP->Z46_DESCRI)
		        Z55->(MsUnlock())		
			endif
			
		endif
	
	// gravando o log de movimentações
	GravLog()
	
    endif

Return

//Grava a sequencia de movimentações da proposta na tabela de log
*----------------------------*
Static function GravLog(cObs)
*----------------------------*
Local cSeq	:= "001"
Local cQry	:= ""

DEFAULT cObs := ""

	
	if TCCANOPEN("Z43"+cEmpAnt+"0")
	
	cQry+=" SELECT MAX(Z43_SEQ) AS Z43_SEQ FROM "+RETSQLNAME("Z43")
	cQry+=" WHERE  D_E_L_E_T_='' AND Z43_PROPOS='"+Z55->Z55_NUM+"' AND Z43_REVISA='"+Z55->Z55_REVISA+"' AND Z43_FILIAL='"+xFilial("Z43")+"'"
	
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
	        
		if nRecCount >0
	    	QRYTEMP->(DbGoTop())
			cSeq:=SOMA1(QRYTEMP->Z43_SEQ)
		endif
	
	
	
		RecLock("Z43",.T.)
			Z43->Z43_FILIAL	:= xFilial("Z43")
			Z43->Z43_PROPOS := Z55->Z55_NUM
			Z43->Z43_REVISA := Z55->Z55_REVISA
			Z43->Z43_SEQ    := cSeq
			Z43->Z43_CODLEG := Z55->Z55_STATUS
			Z43->Z43_LEGEND := Z55->Z55_DESCST
			Z43->Z43_DATA	:= dDataBase
			Z43->Z43_HORA	:= TIME()
			Z43->Z43_CODUSR	:= RetCodUsr()
			Z43->Z43_NOMEUS	:= CAPITAL(alltrim(UsrRetName (__cUserID)))

			if Z43->(FieldPos("Z43_OBS"))>0
				Z43->Z43_OBS:=cObs
			endif
			
		MsUnLock()
		
	endif


Return


/*
Funcao      : CarregaZ35
Objetivos   : Função para carregar as empresas de grupo da proposta.
Autor       : Eduardo C. Romanini
Data/Hora   : 10/09/2013
*/                                                                 
*----------------------------*
User Function CarregaZ35(nOpc)
*----------------------------*
Local cRev := ""
Local cGrp := ""

Local nI        := 0
Local nX        := 0  
Local nQtdReg   := 0
Local nUsadoZ35 := Len(aCpoZ35)
Local nPerFat   := 0
Local nPosPer   := Ascan(oGetDadEmp:aHeader,{|x| alltrim(x[2]) = "Z35_PERCEN"})

Default nOpc := 3

//Apaga o conteudo do array de empresas
oGetDadEmp:aCols:={}

If nOpc == 3 .OR. nOpc == 6   //Inclusão de Proposta ou Revisão
	
	//Tratamento para prospect        
	If !Empty(M->Z55_PROSPE)
	
		//Adiciona a empresa principal do grupo	
		nQtdReg++
		
		SUS->(DbSetOrder(1))
		If SUS->(DbSeek(xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA))	
			//Cria a linha do aCols
			aAdd(oGetDadEmp:aCols,Array(nUsadoZ35+1))
		    
			For nX:=1 To nUsadoZ35			
	           	If aCpoZ35[nX] == "Z35_ITEM"
	           		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := "00"
	           	ElseIf aCpoZ35[nX] == "Z35_NOME"
		           oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := SUS->US_NOME
	           	ElseIf aCpoZ35[nX] == "Z35_CGC"
	           		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := SUS->US_CGC
	           	ElseIf aCpoZ35[nX] == "Z35_PERCEN"
	            	oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := 0
	           	EndIf
	        Next
			
			//Indica que a linha não está deletada
			oGetDadEmp:aCols[Len(oGetDadEmp:aCols),nUsadoZ35+1]:=.F.
		EndIf
		
		//Adiciona as empresas participantes do grupo
		Z40->(DbSetOrder(1))
		If Z40->(DbSeek(xFilial("Z40")+M->Z55_PROSPE+M->Z55_PLOJA))	
			
			While Z40->(!EOF()) .and. Z40->Z40_FILIAL == xFilial("Z40");
			                    .and. AllTrim(Z40->Z40_PROSPE) == AllTrim(M->Z55_PROSPE);
			                    .and. AllTrim(Z40->Z40_PLOJA) == AllTrim(M->Z55_PLOJA)
	             
	            nQtdReg++
	            
				//Cria a linha do aCols
				aAdd(oGetDadEmp:aCols,Array(nUsadoZ35+1))
	
				For nX:=1 To nUsadoZ35			
	            	If aCpoZ35[nX] == "Z35_ITEM"
	            		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := Z40->Z40_ITEM
	            	ElseIf aCpoZ35[nX] == "Z35_NOME"
		            	oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := Z40->Z40_NOME
	            	ElseIf aCpoZ35[nX] == "Z35_CGC"
	            		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := Z40->Z40_CGC
	            	ElseIf aCpoZ35[nX] == "Z35_PERCEN"
		            	oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := 0
	            	EndIf
	            Next
							
				//Indica que a linha não está deletada
				oGetDadEmp:aCols[Len(oGetDadEmp:aCols),nUsadoZ35+1]:=.F.
				
				Z40->(DbSkip())
	    	EndDo
	       
			
		EndIf	
	    
		//Carrega o percentual de 100% quando existe apenas 1 empresa.
		If nQtdReg == 1
			oGetDadEmp:aCols[1][nPosPer] := 100
		EndIf
	
	
	//Tratamento para cliente
	ElseIf !Empty(M->Z55_CLIENT)	
		
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA))

			//Recebe o grupo do cliente			
			cGrp := SA1->A1_GRPVEN	
			
			If !Empty(cGrp)
			
	            BeginSql Alias 'TABSA1'
	            	SELECT A1_COD,A1_LOJA,A1_NOME,A1_CGC
	            	FROM %table:SA1%
	            	WHERE %notDel%
	            	  AND A1_GRPVEN = %exp:SA1->A1_GRPVEN%
	            	ORDER BY A1_COD,A1_LOJA
	            EndSql
	            
	            TABSA1->(DbGoTop())
	            While TABSA1->(!EOF())
	                
					nQtdReg++
					
					//Cria a linha do aCols
					aAdd(oGetDadEmp:aCols,Array(nUsadoZ35+1))
			    
					For nX:=1 To nUsadoZ35			
		        	   	If aCpoZ35[nX] == "Z35_ITEM"
		           			oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := StrZero(nQtdReg,2)
			           	ElseIf aCpoZ35[nX] == "Z35_NOME"
				           oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX]  := TABSA1->A1_NOME
		    	       	ElseIf aCpoZ35[nX] == "Z35_CGC"                                 
		        	   		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := TABSA1->A1_CGC
		           		ElseIf aCpoZ35[nX] == "Z35_PERCEN"
		            		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := 0
		           		ElseIf aCpoZ35[nX] == "Z35_CODCLI"
		            		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := TABSA1->A1_COD
		           		ElseIf aCpoZ35[nX] == "Z35_LOJCLI"
		            		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := TABSA1->A1_LOJA
			           	EndIf
			        Next
				
					//Indica que a linha não está deletada
					oGetDadEmp:aCols[Len(oGetDadEmp:aCols),nUsadoZ35+1]:=.F.
	
					TABSA1->(DbSkip())            
	            EndDo
				
				TABSA1->(DbCloseArea())
				
				//Carrega o percentual de 100% quando existe apenas 1 empresa.
				If nQtdReg == 1
					oGetDadEmp:aCols[1][nPosPer] := 100
				EndIf
				
			Else
			
				//Cria a linha do aCols
				aAdd(oGetDadEmp:aCols,Array(nUsadoZ35+1))
			    
				For nX:=1 To nUsadoZ35			
		           	If aCpoZ35[nX] == "Z35_ITEM"
		           		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := "00"
		           	ElseIf aCpoZ35[nX] == "Z35_NOME"
			           oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := SA1->A1_NOME
		           	ElseIf aCpoZ35[nX] == "Z35_CGC"
		           		oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := SA1->A1_CGC
		           	ElseIf aCpoZ35[nX] == "Z35_PERCEN"
		            	oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := 100
		            ElseIf aCpoZ35[nX] == "Z35_CODCLI"
		            	oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := SA1->A1_COD
		           	ElseIf aCpoZ35[nX] == "Z35_LOJCLI"
		            	oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := SA1->A1_LOJA
			        EndIf
		        Next
				
				//Indica que a linha não está deletada
				oGetDadEmp:aCols[Len(oGetDadEmp:aCols),nUsadoZ35+1]:=.F.
			EndIf	
		EndIf
	
	EndIf

Else //Qualquer outra operação que não inclusão
    
	cRev := M->Z55_REVISA

	If nOpc==6 //Tratamento em caso de revisão
		cRev:=STRZERO((val(cRev)-1),3)
	EndIf

	Z35->(DbSetOrder(1))
	If Z35->(DbSeek(xFilial("Z35")+M->Z55_NUM+cRev))
		While Z35->(!EOF()) .and. Z35->(Z35_FILIAL+Z35_PROPOS+Z35_REVISA) == xFilial("Z35")+M->Z55_NUM+cRev
		   
			nQtdReg++
		    
			//Cria a linha do aCols
			aAdd(oGetDadEmp:aCols,Array(nUsadoZ35+1))
		
			For nX:=1 To Len(oGetDadEmp:aHeader)	
				oGetDadEmp:aCols[Len(oGetDadEmp:aCols)][nX] := Z35->&(oGetDadEmp:aHeader[nX][2])
        	Next
        	
        	//Indica que a linha não está deletada
			oGetDadEmp:aCols[Len(oGetDadEmp:aCols),nUsadoZ35+1]:=.F.
        	
        	Z35->(DbSkip())
    	EndDo
	EndIf	
EndIf	

//Tratamento para não permitir inserir mais linhas no alterar
nMaxZ35:=Len(oGetDadEmp:aCols)

//Atualiza o objeto
oGetDadEmp:Refresh()

Return .T.

/*
Funcao      : GravaZ35
Objetivos   : Função para grava as empresas de grupo da proposta.
Autor       : Eduardo C. Romanini
Data/Hora   : 11/09/2013
*/ 
*-------------------------------------------------*
Static Function GravaZ35(nOpc,oGetDadEmp,cNum,cRev)
*-------------------------------------------------*
Local nI := 0
Local nX := 0
Local nPosItem := aScan(oGetDadEmp:aHeader,{|x| alltrim(x[2]) = "Z35_ITEM"})

For nI:=1 To Len(oGetDadEmp:aCols)
	
    If !oGetDadEmp:aCols[nI][Len(oGetDadEmp:aCols[nI])]   //Verifica se a linha não está deletada.
		
		//Trava a tabela
		If nOpc == 3 .or.;//Inclusão
		   nOpc == 6      //Revisão
		   
			Z35->(RecLock("Z35",.T.))
			
		    Z35->Z35_FILIAL := xFilial("Z35")
		    Z35->Z35_PROPOS := cNum
		    Z35->Z35_REVISA := cRev
		
		Else //Outras Operações
			
			cItem := oGetDadEmp:aCols[nI][nPosItem]
			
			Z35->(DbSetOrder(1))
			Z35->(DbSeek(xFilial("Z35")+cNum+cRev+cItem))
			
			Z35->(RecLock("Z35",.F.))
			
		EndIf
		
		//Grava os campos
		For nX:=1 To Len(oGetDadEmp:aHeader)	
			Z35->&(oGetDadEmp:aHeader[nX][2]) := oGetDadEmp:aCols[nI][nX]	    
        Next
		
		//Destrava a tabela
		Z35->(MsUnlock())
		    
    EndIf

Next

Return Nil

/*
Funcao      : Cargapag
Parametros  : 
Retorno     : 
Objetivos   : Carrega o valor da proposta na aba "Pagamentos"
Autor       : Matheus Massarotto
Data/Hora   : 06/09/2013
*/                                                                 
*----------------------------------*
Static Function Cargapag(cValG3_1_1)
*----------------------------------*
cValG3_1_1:=Transform(M->Z55_VLRTOT,'@E 99,999,999,999.99')

Return

*---------------------*
Static Function GrvCC()
*---------------------*
Local cCCusto := ""

//Auditores
If SM0->M0_CODIGO == "ZB"
	
	//São Paulo	
	If SM0->M0_CODFIL == "01"
		cCCusto :=	"7101"	
	//Rio de Janeiro
	ElseIf SM0->M0_CODFIL == "02"
		cCCusto :=	"7103"	
	//Campinas
	ElseIf SM0->M0_CODFIL == "03"
		cCCusto :=	"7104"	
	//Porto Alegre
	ElseIf SM0->M0_CODFIL == "04"
		cCCusto :=	"7106"	
	//Goiais
	ElseIf SM0->M0_CODFIL == "05"
		cCCusto :=	"7102"	
	//Belo Horizonte
	ElseIf SM0->M0_CODFIL == "06"
		cCCusto :=	"7105"	
	EndIf

//Corporate	
ElseIf SM0->M0_CODIGO == "ZF"

	//Tax	
    If AllTrim(M->Z55_TPCTR) == "2"
    	cCCusto :=	"7201"	
    //Advisory
    ElseIf AllTrim(M->Z55_TPCTR) == "3"
      	cCCusto :=	"7202"	
    EndIf
    
EndIf

//Grava o Centro de Custo
Z55->(RecLock("Z55",.F.))

Z55->Z55_CC := cCCusto

Z55->(MsUnlock())

Return 

*-------------------------*
Static Function IniUsuario() 
*-------------------------*
Local cRet    := ""
Local cUserId := __cUserID

Z42->(DbSetOrder(1))
If Z42->(DbSeek(xFilial("Z42")+cUserId))
	If AllTrim(Z42->Z42_TIPOFU) == "1" //Sócio
    	M->Z55_SOCIO  := Z42->Z42_CPF
    	M->Z55_NOMESO := Z42->Z42_NOMEFU
	
/*		nPosGet		:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_SOCIO"})
		nPosGetDes	:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_NOMESO"})
	
	    //Ajustado para gatilhar o cpf e o nome do sócio na linha do serviço principal da proposta
		oGetDadosZ29:aCols[1][nPosGet]		:= Z42->Z42_CPF
		oGetDadosZ29:aCols[1][nPosGetDes]	:= Z42->Z42_NOMEFU
*/	
	ElseIf AllTrim(Z42->Z42_TIPOFU) == "2" //Gerente
    	M->Z55_GERENT := Z42->Z42_CPF
    	M->Z55_NOMEGE := Z42->Z42_NOMEFU  
/*    	
		nPosGet		:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_GERENT"})
		nPosGetDes	:= Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_NOMEGE"})
	
	    //Ajustado para gatilhar o cpf e o nome do gerente na linha do serviço principal da proposta
		oGetDadosZ29:aCols[1][nPosGet]		:= Z42->Z42_CPF
		oGetDadosZ29:aCols[1][nPosGetDes]	:= Z42->Z42_NOMEFU  
*/    	
	EndIf
EndIf

Return cRet


//Função para gerar o contrato
*-----------------------------------*
Static Function GeraCT(oMeter,oDlg1)
*-----------------------------------*
Local aArea		:= GetArea()
Local cErro		:= ""
Local cTipoFat	:= Z55->Z55_TIPOFT
Local cTipoCob	:= Z55->Z55_COBTIP
Local lReemb	:= .F.

//Tratamento caso os campos estejam em branco, propostas antigas a criação destes campos
if empty(cTipoFat)
	cTipoFat:="F"
endif

if empty(cTipoCob)
   cTipoCob:="1"               
endif

aCliPerc:={}

//Inicia a régua
oMeter:Set(0)

    
	//Porcentagem por empresa(grupo de empresas)
	cQry:=" SELECT * FROM "+RETSQLNAME("Z35")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND Z35_FILIAL='"+xFilial("Z35")+"' AND Z35_PROPOS='"+cNum+"' AND Z35_REVISA='"+cRev+"'"

		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif

		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

		Count to nRecCount

		if nRecCount >0
        	QRYTEMP->(DbGotop())
            
			While QRYTEMP->(!EOF())
                
				if QRYTEMP->Z35_ITEM=="00"
					AADD(aCliPerc,{Z55->Z55_CLIENT,Z55->Z55_LOJA,QRYTEMP->Z35_PERCEN})
				else
				
					//cQryZ40:=" SELECT * FROM "+RETSQLNAME("Z40")+CRLF
					//cQryZ40+=" WHERE D_E_L_E_T_='' AND Z40_PROSPE='"+Z55->Z55_PROSPE+"' AND Z40_PLOJA='"+Z55->Z55_PLOJA+"' AND Z40_FILIAL='"+xFilial("Z40")+"'"
				
					If !Empty(QRYTEMP->Z35_CODCLI)
				       
				       If QRYTEMP->Z35_PERCEN > 0
					       AADD(aCliPerc,{QRYTEMP->Z35_CODCLI,QRYTEMP->Z35_LOJCLI,QRYTEMP->Z35_PERCEN})
					   EndIf
			    	Else
			    
					    DbSelectArea("Z40")
					    Z40->(DbSetOrder(1))
					    if DbSeek(xFilial("Z40")+Z55->Z55_PROSPE+Z55->Z55_PLOJA+QRYTEMP->Z35_ITEM)
		                	
		                	If QRYTEMP->Z35_PERCEN > 0
			                	AADD(aCliPerc,{Z40->Z40_CODCLI,Z40->Z40_LOJCLI,QRYTEMP->Z35_PERCEN})
			                EndIf
		            	endif
	                EndIf
            	endif
            
            QRYTEMP->(DbSkip())
			Enddo

        endif

oMeter:Set(25) //seta o valor na régua
nAumenta:= 75/ ( len(aCliPerc)/75 )

for nI:=1 to len(aCliPerc)

nValor	:=Z55->Z55_VLRTOT
      
nValor	:= nValor * (aCliPerc[nI][3]/100)

if cTipoFat=="F"	//Fixo

	if cTipoCob=="1" //Tipo de cobrança - Local
		cTpCto:="001"	//PRESTACAO SERVICO - FECHADO
	elseif cTipoCob=="2" // Tipo de cobrança - Invoice
		cTpCto:="004"	//PREST.SERV.-FECHADO INVOICE
	endif
	
elseif cTipoFat=="V" //Variável
	
	if cTipoCob=="1" //Tipo de cobrança - Local
		cTpCto:="002"	// PRESTAÇÃO SERVICO - TIMESHEET
	elseif cTipoCob=="2" // Tipo de cobrança - Invoice
		cTpCto:="003"	// PREST.SERV - TIMESHEET INVOICE
	endif
	
else
	cTpCto:="001"	//PRESTACAO SERVICO - FECHADO
endif
        
//[CAPA CN9]
      
      
      	aCapaCN9 := {		{"CN9_CLIENT"	,aCliPerc[nI][1]   		,Nil},;
					        {"CN9_TPCTO"	,cTpCto           		,Nil},;
        					{"CN9_LOJACL"	,aCliPerc[nI][2]     	,Nil},;
        					{"CN9_MOEDA"	,VAL(Z55->Z55_MOEDA)	,Nil},;
	       					{"CN9_CONDPG"	,"001"	            	,Nil},;
        					{"CN9_VLINI"	,nValor					,Nil},;
        					{"CN9_VLATU"	,nValor					,Nil},;
        					{"CN9_SALDO"	,nValor					,Nil},;
        					{"CN9_P_NUM"	,Z55->Z55_NUM			,Nil},;
        					{"CN9_DTPROP"	,Z55->Z55_DTASSI		,Nil}}
        					
			       if CN9->(FieldPos("CN9_P_QTHR"))>0
						DbSelectArea("Z54")
						Z54->(DbSetOrder(2))
						if Z54->(DbSeek(xFilial("Z54")+Z55->Z55_NUM+Z55->Z55_REVISA))
							AADD(aCapaCN9,{"CN9_P_QTHR",alltrim( cvaltochar( Z54->Z54_HORAPR * (aCliPerc[nI][3]/100) ) ),Nil})
						endif
			       endif

			       if CN9->(FieldPos("CN9_P_NDRE"))>0
						DbSelectArea("Z52")
						Z52->(DbGoTop())
						Z52->(DbSetOrder(1))
						if Z52->(DbSeek(xFilial("Z52")+Z55->Z55_NUM+Z55->Z55_REVISA))
							
							While Z52->(!EOF()) .AND. Z52->Z52_NUMPRO == Z55->Z55_NUM .AND. Z52->Z52_REVISA == Z55->Z55_REVISA .AND. Z52->Z52_FILIAL == xFilial("Z52")
							
								if Z52->Z52_DEREEM == "1"
									lReemb:= .T.
									exit
								endif
								
								Z52->(DbSkip())
							Enddo
							
							if lReemb
								AADD(aCapaCN9,{"CN9_P_NDRE","1",Nil})							
							else
								AADD(aCapaCN9,{"CN9_P_NDRE","2",Nil})
							endif
							
						endif
			       endif					

aCapasCNA:={}

if cTipoFat=="F" //Se for fixo, inclui planilha
        					
	//[CAPA CNA]
	

	//nValor	:=Z55->Z55_VLRTOT-(Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100))//Tiro o valor do surcharge
	nValor	:=Z55_VLRLIQ / ((100 - Z55_IMPOST)/100)//Tiro o valor do surcharge
	nValor	:= nValor * (aCliPerc[nI][3]/100)
	
	        aCapaCNA := {		{"CNA_TIPPLA"	,"001"         		,Nil},;
						        {"CNA_SALDO"	,nValor           	,Nil},;
						        {"CNA_VLTOT"	,nValor           	,Nil},;
						        {"CNA_VLCOMS"	,nValor           	,Nil}}
	
			AADD(aCapasCNA,aCapaCNA)
	
	        //Surcharge
	        if Z55->Z55_SURCHA>0
				//nValSur:= (Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100))* (aCliPerc[nI][3]/100)
				nValSur:= (Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100))
		        nValSur:= nValSur / ((100 - Z55_IMPOST)/100) //Aplico o imposto no valor do sucharge
		        nValSur:= nValSur * (aCliPerc[nI][3]/100) //Divide pela porcentagem distribuida para cada cliente do grupo
		        
		        aCapaCNA := {		{"CNA_TIPPLA"	,"001"         	,Nil},;
							        {"CNA_SALDO"	,nValSur		,Nil},;
							        {"CNA_VLTOT"	,nValSur 		,Nil},;
							        {"CNA_VLCOMS"	,nValSur 		,Nil}}
	
				AADD(aCapasCNA,aCapaCNA)
			endif

endif

aItensCNB	:= {}
aPlanCNB	:= {}
nQtdParc	:= 1

if cTipoFat=="F" //Se for fixo, itens da planilha
	
	//[ITENS CNB]
	        
			cQry:=" SELECT Z57_CODPRO,Z57_INVPRO,Z54_PRELSU,Z54_PRECOL 
			cQry+=" ,(	SELECT COUNT(*) AS QTDPARCELA FROM "+RETSQLNAME("Z49")+" Z49"
			cQry+=" WHERE Z49_PROPOS=Z54_NUMPRO AND Z49_REVISA=Z54_REVISA AND Z49_TIPO='PROPOSTA' AND Z49.D_E_L_E_T_='') AS QTDPARCELA
			cQry+=" FROM "+RETSQLNAME("Z54")+" Z54"
			cQry+=" JOIN "+RETSQLNAME("Z57")+" Z57 ON Z54_CODNAT=Z57_CODIGO
			cQry+=" WHERE Z54.D_E_L_E_T_='' AND Z57.D_E_L_E_T_='' AND Z57_FILIAL='"+xFilial("Z57")+"' AND Z54_FILIAL='"+xFilial("Z54")+"'
			cQry+=" AND Z54_NUMPRO='"+Z55->Z55_NUM+"' AND Z54_REVISA='"+Z55->Z55_REVISA+"'"
	        
            /*
			cQry:=" SELECT Z57_CODPRO,Z57_INVPRO,Z29_PRELSU,Z29_PRECOL 
			cQry+=" ,(	SELECT COUNT(*) AS QTDPARCELA FROM "+RETSQLNAME("Z49")+" Z49
			cQry+=" WHERE Z49_PROPOS=Z54_NUMPRO AND Z49_REVISA=Z54_REVISA AND Z49_TIPO='PROPOSTA' AND Z49.D_E_L_E_T_='') AS QTDPARCELA
			cQry+=" FROM "+RETSQLNAME("Z54")+" Z54
			cQry+=" JOIN "+RETSQLNAME("Z29")+" Z29 ON Z29_NUMPRO=Z54_NUMPRO AND Z29_REVISA=Z54_REVISA
			cQry+=" JOIN "+RETSQLNAME("Z57")+" Z57 ON Z29_CODNAT=Z57_CODIGO
			cQry+=" WHERE Z54.D_E_L_E_T_='' AND Z57.D_E_L_E_T_='' AND Z29.D_E_L_E_T_='' AND Z57_FILIAL='"+xFilial("Z57")+"' AND Z54_FILIAL='"+xFilial("Z54")+"' AND Z29_FILIAL='"+xFilial("Z29")+"'
			cQry+="	AND Z54_NUMPRO='"+Z55->Z55_NUM+"' AND Z54_REVISA='"+Z55->Z55_REVISA+"'"
			*/
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
	
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
			Count to nRecCount
	
			if nRecCount >0
	        	QRYTEMP->(DbGotop())
	            nQtdParc:=QRYTEMP->QTDPARCELA
	            
				While QRYTEMP->(!EOF())
					
					//nValSurB:=(Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100)) //Valor do surcharde
					//nValImpB:=( (Z55->Z55_VLRLIQ+nValSurB) *(Z55->Z55_IMPOST/100)) //Valor do imposto
					//nValImpB:= Z55->Z55_VLRLIQ -( ( (Z55->Z55_VLRLIQ+nValSurB)/((100-M->Z55_IMPOST)/100)) ) //Valor do imposto
					
					if cTipoCob=="1" //Cobrança local
						aItemCNB := { 		{"CNB_PRODUT" 	, QRYTEMP->Z57_CODPRO											, Nil},;
							   		  		{"CNB_QUANT"  	, nQtdParc														, Nil},;
							   		  		{"CNB_VLUNIT" 	, (( (QRYTEMP->Z54_PRECOL/nQtdParc)  /((100-M->Z55_IMPOST)/100) ) * (aCliPerc[nI][3]/100))	, Nil}}
							   		  		//{"CNB_VLUNIT" 	, (( (QRYTEMP->Z29_PRECOL/nQtdParc)  /((100-M->Z55_IMPOST)/100) ) * (aCliPerc[nI][3]/100))	, Nil}}
			        
					elseif cTipoCob=="2" //Invoice
						aItemCNB := { 		{"CNB_PRODUT" 	, QRYTEMP->Z57_INVPRO											, Nil},;
							   		  		{"CNB_QUANT"  	, nQtdParc														, Nil},;
							   		  		{"CNB_VLUNIT" 	, (( (QRYTEMP->Z54_PRECOL/nQtdParc) /((100-M->Z55_IMPOST)/100) ) * (aCliPerc[nI][3]/100))	, Nil}}
							   		  		//{"CNB_VLUNIT" 	, (( (QRYTEMP->Z29_PRECOL/nQtdParc) /((100-M->Z55_IMPOST)/100) ) * (aCliPerc[nI][3]/100))	, Nil}}
					endif
					
					AADD(aItensCNB,aItemCNB)
				    
					QRYTEMP->(DbSkip())
				Enddo
	        Endif
	
			AADD(aPlanCNB,aItensCNB)
	
			//Inclui item do surcharge
			if Z55->Z55_SURCHA>0
				aItensCNB:={}
				//nValZ54S :=ROUND((Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100)),2)
	   			nValZ54S:= (Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100)) //valor do surcharge
		        nValZ54S:= ROUND( nValZ54S / ((100 - Z55_IMPOST)/100) ,2) //Aplico o imposto no valor do sucharge
	            cProSurL:= "500057" //Local
	            cProSurI:= "600057"	//Invoice
				
				//Tratamento incluído por solicitação do Adilson Moura - 20/02/2014 - MSM
				if cEmpAnt $ "ZF" //Corporate
					if Z55->Z55_TPCTR=="2" //TAX
						cProSurL:= "500062"
	            		cProSurI:= "600062"
					endif
				endif
				
				If cTipoCob=="1" //Cobrança local
			   		aItemCNB := { 		{"CNB_PRODUT" 	, cProSurL								, Nil},;       //produto de surcharge
				  		   		  		{"CNB_QUANT"  	, nQtdParc								, Nil},;
				 		   		  		{"CNB_VLUNIT" 	, (( nValZ54S/nQtdParc ) * (aCliPerc[nI][3]/100))	, Nil}}
				ElseIf cTipoCob=="2" //Invoice
					aItemCNB := { 		{"CNB_PRODUT" 	, cProSurI								, Nil},;       //produto de surcharge
				  		   		  		{"CNB_QUANT"  	, nQtdParc								, Nil},;
				 		   		  		{"CNB_VLUNIT" 	, (( nValZ54S/nQtdParc ) * (aCliPerc[nI][3]/100))	, Nil}}
				EndIf	   		  		
				
				AADD(aItensCNB,aItemCNB)						   		  		
				AADD(aPlanCNB,aItensCNB)				   		  		

			endif

endif

	aItensCNF:={}
	aPlanCNF :={}

if cTipoFat=="F" //Se for fixo, inclui cronograma
			
	//[ITENS CNF]
		
			nValSLiq:= (Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100)) //valor do surcharge liquido
		    nValSImp:= ROUND( nValSLiq / ((100 - Z55_IMPOST)/100) ,2) //Aplico o imposto no valor do sucharge
	
			cQry:=" SELECT * FROM "+RETSQLNAME("Z49")
			cQry+=" WHERE D_E_L_E_T_='' AND Z49_PROPOS='"+Z55->Z55_NUM+"' AND Z49_REVISA='"+Z55->Z55_REVISA+"' AND Z49_FILIAL='"+xFilial("Z49")+"'
	
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
	
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
			Count to nRecCount
	
			if nRecCount >0
	        	QRYTEMP->(DbGotop())
	            
				While QRYTEMP->(!EOF())
		   			//nValCNF := ROUND(QRYTEMP->Z49_VALOR-( (Z55->Z55_VLRLIQ*(Z55->Z55_SURCHA/100))/nRecCount ),2)
		   			nValCNF := ROUND(QRYTEMP->Z49_VALOR -( nValSImp/nRecCount ),2)
					
					aItemCNF:= {{"CNF_VLPREV"	,nValCNF * (aCliPerc[nI][3]/100)	,NIL},;
								{"CNF_DTVENC"	,STOD(QRYTEMP->Z49_VENCTO)					,NIL}}
					
					AADD(aItensCNF,aItemCNF)
					
			  	QRYTEMP->(DbSkip())
			    Enddo
			
			endif
			
			AADD(aPlanCNF,aItensCNF)
		
			//Inclui item do surcharge
			if Z55->Z55_SURCHA>0
				QRYTEMP->(DbGotop())
	            aItensCNF:= {}
	            
				While QRYTEMP->(!EOF())
		   			nValCNF := ROUND(( nValSImp/nRecCount ),2)
					aItemCNF:= {{"CNF_VLPREV"	,nValCNF * (aCliPerc[nI][3]/100)	,NIL},;
								{"CNF_DTVENC"	,STOD(QRYTEMP->Z49_VENCTO)					,NIL}}
					
					AADD(aItensCNF,aItemCNF)
					
			  	QRYTEMP->(DbSkip())
			    Enddo
			endif
			
			AADD(aPlanCNF,aItensCNF)

endif

		
  	    //Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=nAumenta 	// atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua
		
		//execauto customizado para incluir proposta
		cErro:=U_ExecCNTA(aCapaCN9,aCapasCNA,aPlanCNB,aPlanCNF)


next

//Fecho a barra de processamento.
oDlg1:end()

if !empty(cErro)
	Alert(cErro)
else
    Msginfo("Contrato gerado com sucesso!")
endif

RestArea(aArea)
Return

//Função para copiar o arquivo anexado para novo local
*---------------------------------------*
Static function GravaZ48(nOpc,cNum,cRev)
*---------------------------------------*
Local cQry			:= ""
Local cPastaAnexo	:= '\Propostas\'+cEmpAnt+'\'

	if nOpc==6 //revisar
		cRevAnt:=STRZERO(val(cRev)-1,3)
	endif

	cQry:=" SELECT Z48_FILIAL,Z48_ITEM,Z48_TIPO,Z48_DESCRI,CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z48_MOVIME)) AS Z48_MOVIME,Z48_ARQUIV FROM "+RETSQLNAME("Z48")
	cQry+=" WHERE D_E_L_E_T_='' AND Z48_FILIAL='"+xFilial("Z48")+"' AND Z48_PROPOS='"+cNum+"' AND Z48_REVISA='"+cRevAnt+"'"

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
    
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

	Count to nRecCount

	if nRecCount >0
       	QRYTEMP->(DbGotop())


		While QRYTEMP->(!EOF())
        //While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==cNum .AND. Z48->Z48_REVISA==cRevAnt
			
			BEGIN TRANSACTION
            
	            RecLock("Z48",.T.)
					
					Z48->Z48_FILIAL := QRYTEMP->Z48_FILIAL
					Z48->Z48_PROPOS := cNum
					Z48->Z48_REVISA := cRev
					Z48->Z48_ITEM   := QRYTEMP->Z48_ITEM
					Z48->Z48_DATA   := dDataBase
					Z48->Z48_HORA   := Time()
					Z48->Z48_CODUSR := RetCodUsr()
					Z48->Z48_NOMEUS	:= CAPITAL(alltrim(UsrRetName (__cUserID)))
					Z48->Z48_TIPO   := QRYTEMP->Z48_TIPO
					Z48->Z48_DESCRI	:= QRYTEMP->Z48_DESCRI
					Z48->Z48_MOVIME := QRYTEMP->Z48_MOVIME
					Z48->Z48_ARQUIV := QRYTEMP->Z48_ARQUIV
						
				Z48->(MsUnlock())
	
	
				cPastaCod   := STRTRAN(Z48->Z48_PROPOS,"/","_")+(Z48->Z48_REVISA) + "\"
				cPastaItem  := AllTrim(Z48->Z48_ITEM) + "\"
			
				cPasta := cPastaAnexo+cPastaCod+cPastaItem
			
				//Monta o diretório de gravação dos anexos.		
				If !ExistDir(cPasta)
					If !MontaDir(cPasta)
						MsgInfo("Não foi possivel criar o diretório especifico de gravação de anexos","Atenção")
			        	Return .F.
					EndIf
				EndIf
			
				cOrig:= cPastaAnexo+STRTRAN(cNum,"/","_")+(cRevAnt) + "\"+AllTrim(Z48->Z48_ITEM) + "\"+alltrim(Z48->Z48_ARQUIV)
			    cDest:= cPasta+alltrim(Z48->Z48_ARQUIV)
			     
				if !__CopyFile( cOrig, cDest )    
					MsgInfo("O arquivo anexo não foi copiado para a revisão.","Atenção")
				endif

			END TRANSACTION
        	
		    QRYTEMP->(DbSkip())
    	Enddo
    endif
	
Return

//Função para buscar os projetos do banco controle
*----------------------------------------*
Static Function CarregaPrj(aColsPrj,cNum)
*----------------------------------------*
Local cQry	:= ""

aColsPrj	:= {}

    cQry:=" SELECT WPRJ_ID AS PROJID ,CONVERT(nvarchar(30), Z54_DTAINI, 112) AS DTAINI,ISNULL(CONVERT(nvarchar(30), WPRJ_DtaConclusao, 112),'') AS DTACONCLU FROM Controle.dbo.WIP_Projeto"
    cQry+=" WHERE SUBSTRING(Z54_CODIGO,1,LEN(Z54_CODIGO)-3) ='"+cNum+"'"

    if "TESTE" $ alltrim(UPPER(GetEnvServer()))
		nCon := TCLink("MSSQL/Controle_Teste","10.0.30.5",7894)	
	else
		nCon := TCLink("MSSQL/Controle","10.0.30.5",7894)
    endif
    
            
	If nCon < 0
		MsgInfo("Erro ("+str(nCon,4)+") ao conectar com banco de dados.")
	Else
		if TCSQLExec(cQry) < 0
			Msginfo("Não foi possível carregar o(s) projeto(s)!"+CRLF+CRLF+TCSQLError())
	    else
		
			if select("QRYTEMP")>0
				QRYTEMP->(DbCloseArea())
			endif
	    
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
			Count to nRecCount
		
			if nRecCount >0
		       	QRYTEMP->(DbGotop())
	
				//Preencho o acols de projetos, adicionando .F. de não deletado
				While QRYTEMP->(!EOF())
				    AADD(aColsPrj,{CVALTOCHAR(QRYTEMP->PROJID),STOD(QRYTEMP->DTAINI),STOD(QRYTEMP->DTACONCLU),.F.})
			    	QRYTEMP->(DbSkip())
				Enddo
				
			endif
	    endif	
	    
		TCUnlink(nCon)
	EndIf

Return(aColsPrj)

// Função para verificar se a proposta está assinada
*-------------------------*
Static Function ProAssin()
*-------------------------*
Local dGet1		:= CTOD("//")
Local nRadio	:= 1
Local lRet		:= .F.

// Declaração de Variaveis Private dos Objetos
SetPrvt("oDlg1","oSay1","oBmp1","oSay2","oRMenu1","oGet1","oBtn1","oBtn2")

// Definicao do Dialog e todos os seus componentes.

oDlg1      := MSDialog():New( 154,406,400,731,"Controle de assinatura de proposta",,,.F.,,,,,,.T.,,,.T. )

oBmp1      := TBitmap():New( 012,012,020,020,,"SDUSETDEL",.F.,oDlg1,,,.F.,.T.,,"",.T.,,.T.,,.F. )
oSay1      := TSay():New( 020,044,{||"A proposta está assinada? "},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
GoRMenu1   := TGroup():New( 036,012,072,148,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRMenu1    := TRadMenu():New( 040,018,{"Sim","Não"},,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,064,36,,.F.,.F.,.T. )

// Seta Eventos
oRMenu1:bchange := {|| iif(nRadio==1, oGet1:Enable() ,( oGet1:Disable(),dGet1:=CTOD("//"),oGet1:CtrlRefresh() ) ) }
oRMenu1:bSetGet := {|u| iif (PCount()==0,nRadio,nRadio:=u)}
oRMenu1:bWhen 	:= {|| .T. }

oSay2      := TSay():New( 080,012,{||"Data de assinatura:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
oGet1      := TGet():New( 078,068,{|u| if(PCount()>0,dGet1:=u,dGet1)},oDlg1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGet1",,)

oBtn1      := TButton():New( 100,027,"Gravar",oDlg1,{|| iif(nRadio==1 .AND. empty(dGet1), alert("Informe a data de assinatura! ") , ( GrDtAssi(dGet1),oDlg1:end(),lRet:=.T.) ) },037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 100,104,"Cancelar",oDlg1,{|| oDlg1:end(),lRet:=.F. },037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return(lRet)

//Função para gravar a data de assinatura
*------------------------------*
Static function GrDtAssi(dGet1)
*------------------------------*                   

RecLock("Z55",.F.)
	Z55->Z55_DTASSI:=dGet1
Z55->(MsUnlock())

Return

//Função que gatilhar da descrição de serviços para o resumo de serviços, como um totalizador.
*-----------------------------*
Static function GatServi(nOpc)
*-----------------------------*

if nOpc == 3 .OR. nOpc == 6 .OR. nOpc == 14
      
	For h:=1 to len(oGetDadosZ29:aCols)
		
		For l:=1 to len(aHeaderZ29)
			if alltrim(aHeaderZ29[l][2]) $ "Z29_ITEM"
				loop
			endif
			
			if oGetDadosZ29:aCols[h][len(oGetDadosZ29:aCols[h])] //Se tiver deletado
				loop 
			endif
			
			if h==1
				
				//Localizo se existe o nome da coluna do aheaderZ29 do Z29 (Descrição dos serviços) no aHeader do Z54 (Resumo dos serviços)
				//nCol:= Ascan(aHeader,{|x| alltrim(x[2]) = aHeaderZ29[l][2]})
				nCol:= Ascan(aHeader,{|x| alltrim( SUBSTR(x[2],AT("_",x[2]),LEN(x[2])) ) = alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2])) ) })
				
				if nCol>0
					oGetDados:aCols[1][nCol]:=oGetDadosZ29:aCols[h][l]
				endif
				
			elseif alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2]))) $ "_CUSTOT/_PRECOL/_PRELSU/_HORAPR"
				//Localizo se existe o nome da coluna do aheaderZ29 do Z29 (Descrição dos serviços) no aHeader do Z54 (Resumo dos serviços)
				nCol:= Ascan(aHeader,{|x| alltrim( SUBSTR(x[2],AT("_",x[2]),LEN(x[2])) ) = alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2])) ) })
				
				if nCol>0
					oGetDados:aCols[1][nCol]+=oGetDadosZ29:aCols[h][l]
				endif
			
			elseif alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2]))) $ "_DTAINI"
				//Localizo se existe o nome da coluna do aheaderZ29 do Z29 (Descrição dos serviços) no aHeader do Z54 (Resumo dos serviços)
				nCol:= Ascan(aHeader,{|x| alltrim( SUBSTR(x[2],AT("_",x[2]),LEN(x[2])) ) = alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2])) ) })
				
				if nCol>0
					
					if !empty(oGetDadosZ29:aCols[h][l])
						if empty(oGetDados:aCols[1][nCol])
							oGetDados:aCols[1][nCol]:=oGetDadosZ29:aCols[h][l]					
						elseif oGetDadosZ29:aCols[h][l]<oGetDados:aCols[1][nCol]
							oGetDados:aCols[1][nCol]:=oGetDadosZ29:aCols[h][l]					
						endif
						
					endif
				endif

			elseif alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2]))) $ "_DTAFIM"
				//Localizo se existe o nome da coluna do aheaderZ29 do Z29 (Descrição dos serviços) no aHeader do Z54 (Resumo dos serviços)
				nCol:= Ascan(aHeader,{|x| alltrim( SUBSTR(x[2],AT("_",x[2]),LEN(x[2])) ) = alltrim( SUBSTR(aHeaderZ29[l][2],AT("_",aHeaderZ29[l][2]),LEN(aHeaderZ29[l][2])) ) })
				
				if nCol>0
					
					if oGetDadosZ29:aCols[h][l]>oGetDados:aCols[1][nCol]
						oGetDados:aCols[1][nCol]:=oGetDadosZ29:aCols[h][l]					
					endif
					
				endif			
				
			endif
		Next
		
	Next

	oGetDadosZ29:Refresh()

    //Chamo a função RunTrigger para executar os gatilhos dos campos do acols de Resumo de serviço
	oGetDados:Execute( {|| RunTrigger(2,1,nil,nil,'Z54_CUSTOT'),RunTrigger(2,1,nil,nil,'Z54_PRECOL') }, .F. )

	oGetDados:ForceRefresh()

endif

Return

//Função para validar se o total da aba Resumo de serviços, é o mesmo que a somatória da aba Descrição dos serviços
*------------------------*
Static function ValidSer()
*------------------------*
Local nHoraZ29	:= 0
Local nCustoZ29	:= 0
Local nPrecoZ29	:= 0
Local nHoraZ54	:= 0
Local nCustoZ54	:= 0
Local nPrecoZ54	:= 0
Local lRet		:= .T.
	
	nPosHorZ29:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_HORAPR"})
	nPosCusZ29:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CUSTOT"})
	nPosPreZ29:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_PRECOL"})

	nPosHorZ54:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_HORAPR"})
	nPosCusZ54:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CUSTOT"})
	nPosPreZ54:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_PRECOL"})


	For h:=1 to len(oGetDadosZ29:aCols)
		
		if nPosHorZ29>0
			nHoraZ29+=oGetDadosZ29:aCols[h][nPosHorZ29]
	    endif

		if nPosCusZ29>0
			nCustoZ29+=oGetDadosZ29:aCols[h][nPosCusZ29]
	    endif

		if nPosPreZ29>0
			nPrecoZ29+=oGetDadosZ29:aCols[h][nPosPreZ29]
	    endif

	Next
	
	if nPosHorZ54>0
		nHoraZ54+=oGetDados:aCols[1][nPosHorZ54]
	endif
	
	if nPosCusZ54>0
		nCustoZ54+=oGetDados:aCols[1][nPosCusZ54]	
	endif
	
	if nPosPreZ54>0
		nPrecoZ54+=oGetDados:aCols[1][nPosPreZ54]	
	endif
	
	if nHoraZ29<>nHoraZ54 .OR. nCustoZ29<>nCustoZ54 .OR. nPrecoZ29<>nPrecoZ54
		Alert("Verifique se os totais estão corretos na aba de Resumo dos Serviços")
		lRet:= .F.
	endif
	
Return(lRet)


//Função para enviar email para quem estiver nos parametros MV_P_00017, MV_P_00018 de acordo com qual fase do fluxo se encontra,
// controlado pela variável cQualEnv, informando sobre a inclusão de proposta.
*-------------------------------------*
Static Function EmailInc(cNum,cQualEnv)
*-------------------------------------*
Local cNome		:= ""
Local cCGC 		:= ""
Local cDescOpc	:= ""
Local cNomeSoc	:= ""
Local cNomeGer	:= ""
Local cDescDiv	:= ""
Local aCbox		:= {}
Local cEmails	:= ""
Local cDescTit	:= ""
Local aOverImp	:= {}

If cQualEnv=="OVERRUN"
	If VldEnvMail()
		Return .T.
	EndIf
	cDescTit := "Overrun"
Else 
	cDescTit := "Propostas"
EndIf

//Tratamento para enviar e-mail
cHtml:=' <html style="padding: 0px; margin: 0px;">
cHtml+=' <head>
cHtml+=' <style>p { margin: 0; }</style><link rel="stylesheet" href="/zimbra/css/msgview.css?v=100820045356">
cHtml+=' </head>
cHtml+=' <body class="MsgBody MsgBody-html" style="margin: 0px;"><div style="font-family: Arial; font-size: 10pt; color: #000000"><div><span>
//cHtml+=' <div align="left">
cHtml+=' <table style="BORDER-BOTTOM: #000 1px collapse; TEXT-ALIGN: left; BORDER-LEFT: #000 1px collapse; WIDTH: 60.14%; BORDER-COLLAPSE: collapse; HEIGHT: 51px; VERTICAL-ALIGN: middle; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse cellspacing="0" cellpadding="3" align="left">
cHtml+=' <tbody>
cHtml+=' <tr>
cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
cHtml+=' <p>&nbsp;<img dfsrc="cid:DWT232" src="http://www.grantthornton.com.br/images/logo.gif" width=400></p></td>
cHtml+=' <td style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 30%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">
cHtml+=' <p>&nbsp;
cHtml+=' <span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><strong>Aviso de Pendência </strong></span></p>
cHtml+=' <p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Georgia','serif'"+'; COLOR: #5f497a; FONT-SIZE: 20pt; mso-fareast-language: EN-US;'
cHtml+='	 mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt;'
cHtml+='	 mso-themecolor: accent4; mso-themeshade: 191; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA"><span style="LINE-HEIGHT: 115%;'
cHtml+='	 FONT-FAMILY: '+"'Georgia','serif'"+'; FONT-SIZE: 16pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri;'
cHtml+='	 mso-fareast-theme-font: minor-latin; mso-bidi-font-family: Arial; mso-bidi-font-size: 11.0pt; mso-ansi-language: PT-BR;'
cHtml+='	 mso-bidi-language: AR-SA"><strong><font color="#000000">&nbsp;WIP | '+cDescTit+'</font></strong></span></span></p></td></tr>
//cHtml+=' </table></div><br>
cHtml+=' <tr>
cHtml+=' <td colspan="2" style="BORDER-BOTTOM: #000 1px collapse; BORDER-LEFT: #000 1px collapse; WIDTH: 100%; BORDER-TOP: #000 1px collapse; BORDER-RIGHT: #000 1px collapse">		

if cQualEnv == "INCLUI"
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo foi aberta no sistema. </span></span>
elseif cQualEnv == "INPOOL"
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo está disponível para revisão e está aguardando a sua manipulação: </span></span>
elseif cQualEnv == "OUTPOOL"
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo foi revisada pelo pool, e está aguardando a sua manipulação: </span></span>
elseif cQualEnv == "GANHA"
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo foi convertida para ganha: </span></span>
elseif cQualEnv == "OVERRUN"
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">Informamos que o seguinte lançamento de cobrança de overrun foi incluído no sistema: </span></span>		
elseif cQualEnv == "REVISAO"
	cHtml+=' <p style="TEXT-ALIGN: left; LINE-HEIGHT: 14pt; MARGIN: 0cm 0cm 14.2pt; tab-stops: 21.3pt" class="Normal1" align="left"><span style="FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt">Prezados<b style="mso-bidi-font-weight: normal">,</b></span></p><span style="LINE-HEIGHT: 115%; FONT-FAMILY: '+"'Arial','sans-serif'"+'; FONT-SIZE: 10pt; mso-fareast-language: EN-US; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-bidi-language: AR-SA">A proposta abaixo foi revisada no sistema. </span></span>
endif

cHtml+=' </td></tr>

cHtml+=' </div>
cHtml+=' </tbody>
cHtml+=' <tr><td colspan="2">

cHtml+=' <p><span></span>&nbsp;</p>
cHtml+=' <p><span>&nbsp;</span></p>
cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
cHtml+=' <colgroup>
cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
cHtml+=' </colgroup>

cHtml+=' <tbody>
cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #FFFFFF" class="xl65" height="21" width="205">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Número</font></strong></p>
cHtml+=' </td>

cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #FFFFFF" class="xl65" width="284">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">'+IIF(!empty(M->Z55_NOME),"Cliente","Prospect")+'</font></strong></p></td>

cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #FFFFFF" class="xl65" width="284">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">CNPJ/CPF</font></strong></p></td>

cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Empresa GT</font></strong></p></td>
   
cHtml+=' </tr>

cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
cHtml+=' <p align="center">
cHtml+=' <font size="2" face="Calibri">'+AllTrim(cNum)+'</font>'
cHtml+=' </p>
cHtml+=' </td>

if !empty(M->Z55_CLIENT)
	DbSelectArea("SA1")
	DbSetOrder(1)
	if SA1->(DbSeek(xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA))
		cNome	:= SA1->A1_NOME
		cCGC	:= SA1->A1_CGC
	endif
else
	DbSelectArea("SUS")
	DbSetOrder(1)
	if SUS->(DbSeek(xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA))
		cNome	:= SUS->US_NOME
		cCGC	:= SUS->US_CGC
	endif
endif

cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
cHtml+=' <p align="center">
cHtml+=' <font size="2" face="Calibri">'+alltrim(cNome)+'</font> '
cHtml+=' </p>	
cHtml+=' </td>

cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
cHtml+=' <p align="center">	
cHtml+=' <font size="2" face="Calibri">'+alltrim(cCGC)+'</font> '
cHtml+=' </p>
cHtml+=' </td>

cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
cHtml+=' <p align="center">
cHtml+=' <font size="2" face="Calibri">'+alltrim(FWFilialName())+'</font> '
cHtml+=' </p>
cHtml+=' </td>

cHtml+=' </tr>

cHtml+=' </tbody></table><span></span>
cHtml+=' </td></tr>

//Segundo quadro
cHtml+=' <tr><td colspan="2">

cHtml+=' <p><span></span>&nbsp;</p>
cHtml+=' <p><span>&nbsp;</span></p>
cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
cHtml+=' <colgroup>
cHtml+=' <col style="WIDTH: 154pt; mso-width-source: userset; mso-width-alt: 7497" width="205">
cHtml+=' <col style="WIDTH: 213pt; mso-width-source: userset; mso-width-alt: 10386" width="284">
cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
cHtml+=' </colgroup>

cHtml+=' <tbody>
cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 154pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Área</font></strong></p>
cHtml+=' </td>

cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Sócio</font></strong></p></td>

cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Gerente</font></strong></p></td>

cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Serviço</font></strong></p></td>

//Preenche os itens
DbSelectArea("Z29")
Z29->(DbSetORder(2))
if Z29->(DbSeek(xFilial("Z29")+Z55->Z55_NUM+Z55->Z55_REVISA))
	While Z29->(!EOF()) .AND. Z29->Z29_FILIAL==Z55->Z55_FILIAL .AND. Z29->Z29_NUMPRO==Z55->Z55_NUM .AND. Z29->Z29_REVISA==Z55->Z55_REVISA	   
		cHtml+=' </tr>
		cTipoCtr := Z29->Z29_TPCTR

		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("Z29_TPCTR"))
			cCbox := AllTrim(SX3->X3_CBOX)
			nAt := At(";",cCbox)
			While nAt > 0
				cAux  := Left(cCbox,nAt-1)
				aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 
				cCbox := Substr(cCbox,nAt+1)
				nAt := At(";",cCbox)
			EndDo
			cAux  := cCbox
			aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 			
		EndIf
		nPos := aScan(aCbox,{|a| Alltrim(a[1])== AllTrim(cTipoCtr)})
		if nPos > 0
			cDescOpc := SUBSTR(aCbox[nPos][2],1,3)
		endif

		cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 154pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
		cHtml+=' <p align="center">
		cHtml+=' <font size="2" face="Calibri">'+AllTrim(cDescOpc)+'</font>'
		cHtml+=' </p>
		cHtml+=' </td>
		cNomeSoc:=U_GTSXB002(Z29->Z29_SOCIO)
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 213pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <p align="center">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(cNomeSoc)+'</font> '
		cHtml+=' </p>
		cHtml+=' </td>
		cNomeGer:=U_GTSXB002(Z29->Z29_GERENT)
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <p align="center">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(cNomeGer)+'</font> '
		cHtml+=' </p>
		cHtml+=' </td>
		//nPosdIVZ54:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z54_CODDIV"})
        //cDescDiv:=POSICIONE("Z58",1,xFilial("SED")+oGetDados:aCols[1][nPosdIVZ54],"Z58_DESCRI")
        cDescDiv:= POSICIONE("Z58",1,xFilial("SED")+Z29->Z29_CODDIV,"Z58_DESCRI")
		if cQualEnv $ "INPOOL/INCLUI/OUTPOOL/OVERRUN/REVISAO"
			cDescNat:= " - "+ POSICIONE("Z57",1,xFilial("Z57")+Z29->Z29_CODNAT,"Z57_DESCRI")
		else
			cDescNat:= ""
		endif
		cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
		cHtml+=' <p align="center">
		cHtml+=' <font size="2" face="Calibri">'+alltrim(cDescDiv)+alltrim(cDescNat)+'</font> '
		cHtml+=' </p>
		cHtml+=' </td>

		cHtml+=' </tr>

		if cQualEnv=="GANHA" .OR. cQualEnv=="INCLUI" .OR. cQualEnv=="REVISAO"
			if !empty(Z29->Z29_SOCIO)
    		cEmails+= alltrim(UsrRetMail(Z29->Z29_SOCIO))+";"
           	endif
           	if !empty(Z29->Z29_GERENT)
           		cEmails+= alltrim(UsrRetMail(Z29->Z29_GERENT))+";"
           	endif
		endif

		Z29->(DbSkip())
	enddo
endif

cHtml+=' </tbody></table><span></span>
cHtml+=' </td></tr>

if cQualEnv=="OVERRUN"
	cHtml+=' <tr><td colspan="2">
	cHtml+=' <p><span></span>&nbsp;</p>
	cHtml+=' <p><span>&nbsp;</span></p>
	cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
	cHtml+=' <colgroup>
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	//cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' </colgroup>

	cHtml+=' <tbody>
	cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Overrun</font></strong></p>
	cHtml+=' </td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Data</font></strong></p></td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Horas</font></strong></p></td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Moeda</font></strong></p></td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Valor Liquido</font></strong></p></td>

	//cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	//cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Tx.Média</font></strong></p></td>
	
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Imposto</font></strong></p></td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Valor Bruto</font></strong></p></td>

	aOverImp := {}

	//Preenche os itens
	DbSelectArea("Z29")
	Z27->(DbSetORder(1))
	if Z27->(DbSeek(xFilial("Z27")+Z55->Z55_NUM+Z55->Z55_REVISA))
		While Z27->(!EOF()) .AND. Z27->Z27_FILIAL == Z55->Z55_FILIAL .AND. Z27->Z27_NUMPRO == Z55->Z55_NUM .AND. Z27->Z27_REVISA == Z55->Z55_REVISA	   
			If IIF(Z27->(FieldPos("Z27_MAILOK"))<>0,Z27->Z27_MAILOK <> "S",.T.)
				aAdd(aOverImp, Z27->Z27_CODIGO)
				cHtml+=' </tr>
				cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+alltrim(Z27->Z27_CODIGO)+'</font>'
				cHtml+=' </p>                                 
				cHtml+=' </td>
	
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+DTOC(Z27->Z27_DTAINC)+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>						    
	
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+cvaltochar(Z27->Z27_HORAPR)+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>
	
	            cDescMoe:=POSICIONE("CTO",1,xFilial("CTO")+Z27->Z27_MOEDA,"CTO_DESC")
	
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+alltrim(cDescMoe)+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>
	
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+Transform(Z27->Z27_VLRLIQ,'@E 99,999,999,999.99')+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>				            
	
				//cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				//cHtml+=' <p align="center">
				//cHtml+=' <font size="2" face="Calibri">'+Transform(Z27->Z27_TAXAME,'@E 9,999.99')+'</font> '
				//cHtml+=' </p>
				//cHtml+=' </td>				
	
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+Transform(Z27->Z27_IMPOST,'@E 999.99')+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>	
	
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+Transform(Z27->Z27_VLRTOT,'@E 99,999,999,999.99')+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>				            
	
				cHtml+=' </tr>
			EndIf
	
			If Z27->(FieldPos("Z27_MAILOK")) <> 0
				Z27->(RecLock("Z27",.F.))
				Z27->Z27_MAILOK := "S"
				Z27->(MsUnlock())
			EndIf

			Z27->(DbSkip())
		enddo
	endif

	cHtml+=' </tbody></table><span></span>
	
	cHtml+=' </td></tr>
	
	//Pagamentos de Overrun
	
	cHtml+=' <tr><td colspan="2">
	
	cHtml+=' <p><span></span>&nbsp;</p>
	cHtml+=' <p><span>&nbsp;</span></p>
	cHtml+=' <table style="WIDTH: 507pt; BORDER-COLLAPSE: collapse" border="0" cellspacing="0" cellpadding="0" width="675">
	cHtml+=' <colgroup>
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	cHtml+=' <col style="WIDTH: 140pt; mso-width-source: userset; mso-width-alt: 6802" width="186">
	
	cHtml+=' </colgroup>

	cHtml+=' <tbody>
	cHtml+=' <tr style="HEIGHT: 15.75pt; mso-height-source: userset">
	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; HEIGHT: 15.75pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" height="21" width="205">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Overrun</font></strong></p>
	cHtml+=' </td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Parcela</font></strong></p></td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Data</font></strong></p></td>

	cHtml+=' <td style="BORDER-BOTTOM: #f0f0f0; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #efe6d5; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl65" width="284">
	cHtml+=' <p align="center"><strong><font color="#808080" face="Calibri">Valor</font></strong></p></td>
									
	//Preenche os itens
	DbSelectArea("Z49")
	Z49->(DbSetORder(2))
	if Z49->(DbSeek(xFilial("Z49")+Z55->Z55_NUM+Z55->Z55_REVISA+"OVERRUN"))
		While Z49->(!EOF()) .AND. 	Z49->Z49_FILIAL == Z55->Z55_FILIAL .AND.;
									Z49->Z49_PROPOS == Z55->Z55_NUM .AND.;
									Z49->Z49_REVISA == Z55->Z55_REVISA .AND.;
									alltrim(Z49->Z49_TIPO) == "OVERRUN"
			If aScan(aOverImp, {|x| ALLTRIM(x) == ALLTRIM(Z49->Z49_CODOVE) }) <> 0
	
				cHtml+=' </tr>
				cHtml+=' <tr style="HEIGHT: 25.5pt; mso-height-source: userset">
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: #f0f0f0; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; HEIGHT: 25.5pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: white 0.5pt dotted" class="xl66" height="34" width="205">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+ALLTRIM(Z49->Z49_CODOVE)+'</font>'
				cHtml+=' </p>                                 
				cHtml+=' </td>
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+ALLTRIM(Z49->Z49_PARCEL)+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+DTOC(Z49->Z49_VENCTO)+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>
				cHtml+=' <td style="BORDER-BOTTOM: white 0.5pt dotted; BORDER-LEFT: white 0.5pt solid; BACKGROUND-COLOR: #d8cfbf; WIDTH: 140pt; BORDER-TOP: #f0f0f0; BORDER-RIGHT: #f0f0f0" class="xl68" width="284">
				cHtml+=' <p align="center">
				cHtml+=' <font size="2" face="Calibri">'+Transform(Z49->Z49_VALOR,'@E 99,999,999,999.99')+'</font> '
				cHtml+=' </p>
				cHtml+=' </td>				            
				cHtml+=' </tr>
			EndIf
				
			Z49->(DbSkip())
		EndDo
	endif

	cHtml+=' </tbody></table><span></span>
	cHtml+=' </td></tr>

endif
		cHtml+=' <tr><td>
		cHtml+=' <p><br><br><br>&nbsp;</p>
		
		cHtml+=' <i><span style="font-size:9.0pt;mso-bidi-font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;
		cHtml+=' color:gray;mso-themecolor:background1;mso-themeshade:128">Este e-mail foi enviado automaticamente, por favor, não responda.<o:p></o:p></span></i>

		cHtml+=' </td></tr>
		cHtml+=' </table>
			
		cHtml+=' </body>
		cHtml+=' </html>
		
		if cQualEnv=="INCLUI"
			cTo:= alltrim(SUPERGETMV("MV_P_00017",.F.,"") )+";"+cEmails
		elseif cQualEnv=="INPOOL"
			cTo:= SUPERGETMV("MV_P_00018",.F.,"") 		
		elseif cQualEnv=="OUTPOOL"
			//Pega o e-mail do socio e gerente da proposta.

				DbSelectArea("Z42")
				Z42->(DbSetOrder(2))
				Z42->(DbGoTop())
				if Z42->(DbSeek(xFilial("Z42")+Z55->Z55_SOCIO))		
					cEmails+= alltrim(UsrRetMail(Z42->Z42_IDUSER))+";"
			    endif

				if Z42->(DbSeek(xFilial("Z42")+Z55->Z55_GERENT))		
					cEmails+= UsrRetMail(Z42->Z42_IDUSER)
			    endif

			cTo:=cEmails
		elseif cQualEnv=="GANHA"
			//Pega o e-mail do socio e gerente da proposta.

				DbSelectArea("Z42")
				Z42->(DbSetOrder(2))
				Z42->(DbGoTop())
				if Z42->(DbSeek(xFilial("Z42")+Z55->Z55_SOCIO))		
					cEmails+= alltrim(UsrRetMail(Z42->Z42_IDUSER))+";"
			    endif

				if Z42->(DbSeek(xFilial("Z42")+Z55->Z55_GERENT))		
					cEmails+= UsrRetMail(Z42->Z42_IDUSER)
			    endif
			
			cTo:=cEmails
		elseif cQualEnv=="OVERRUN"
			cTo:= SUPERGETMV("MV_P_00006",.F.,"")
		elseif cQualEnv=="REVISAO"
			cTo:=cEmails		
		endif

		if cQualEnv=="INCLUI"
			cSubject := "Abertura de proposta no sistema, n: "+AllTrim(cNum)
        elseif cQualEnv=="INPOOL"
			cSubject := "Proposta disponivel para revisao, n: "+AllTrim(cNum)
        elseif cQualEnv=="OUTPOOL"
			cSubject := "Proposta revisada pelo pool, n: "+AllTrim(cNum)
        elseif cQualEnv=="GANHA"
			cSubject := "Proposta ganha"
        elseif cQualEnv=="OVERRUN"
			cSubject := "Lancamento de Overrun para proposta n: "+AllTrim(cNum)
		elseif cQualEnv=="REVISAO"
			cSubject := "Revisao de proposta no sistema, n: "+AllTrim(cNum)
		endif
		
		if !empty(cTo)
			EnviaEma(cHtml,cSubject,cTo)	
		endif

Return

//Função para atualizar os campos de descrição da proposta de acordo com os cadastros.
*-------------------------*
Static Function AtuDesc() 
*-------------------------*

//Atualiza o nome do sócio
if Z55->(FieldPos("Z55_SOCIO"))>0 .AND. Z55->(FieldPos("Z55_NOMESO"))>0
	Z42->(DbGoTop())
	Z42->(DbSetOrder(2))
	if Z42->(DbSeek(xFilial("Z42")+M->Z55_SOCIO))
	    	M->Z55_NOMESO := Z42->Z42_NOMEFU
	endIf
endif

//Atualiza o nome do gerente
if Z55->(FieldPos("Z55_GERENT"))>0 .AND. Z55->(FieldPos("Z55_NOMEGE"))>0
	Z42->(DbGoTop())
	Z42->(DbSetOrder(2))
	if Z42->(DbSeek(xFilial("Z42")+M->Z55_GERENT))
		M->Z55_NOMEGE := Z42->Z42_NOMEFU
	endif
endif

//Atualiza o nome do prospect
if Z55->(FieldPos("Z55_PROSPE"))>0 .AND. Z55->(FieldPos("Z55_PLOJA"))>0 .AND. Z55->(FieldPos("Z55_PNOME"))>0
	DbSelectArea("SUS")
	SUS->(DbGoTop())
	SUS->(DbSetOrder(1))
	if SUS->(DbSeek(xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA))
		M->Z55_PNOME:= SUS->US_NOME
	endif
endif

//Atualiza o nome do cliente
if Z55->(FieldPos("Z55_CLIENT"))>0 .AND. Z55->(FieldPos("Z55_LOJA"))>0 .AND. Z55->(FieldPos("Z55_NOME"))>0
	DbSelectArea("SA1")
	SA1->(DbGoTop())
	SA1->(DbSetOrder(1))
	if SA1->(DbSeek(xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA))
		M->Z55_NOME:= SA1->A1_NOME
	endif
endif

Return

//Cadastro de Overrun
*--------------------------------------------------------*
Static Function CadOverRun(nOpc,xParam5,nUsadoZ27,nOpcOve)
*--------------------------------------------------------*
Local aOrdLab	:= {{20,16},{20,129},;
					{40,16},{40,129},;
					{60,16},{60,129},;
					{80,16},{80,129}}

Local aOrdGet	:= {{19,45},{19,158},;
					{39,45},{39,158},;
					{59,45},{59,158},;
					{79,45},{79,158}}

Private cValGOve_1 := ""
Private cValGOve_2 := ""
Private nValGOve_4 := 0
Private dValGOve_6 := CTOD("//")

Private cGetCod    := ProxCodZ27()
Private dGetData   := dDataBase
Private nGetHora   := 0
Private nGetImp    := U_GTSX7002()
Private cGetMoeda  := Z55->Z55_MOEDA
Private nGetTxMedi := 0
Private nGetVlBru  := 0
Private nGetVlLiq  := 0
Private cObserv    := ""

SetPrvt("oDlgZ27","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oGetCod","oGetHora")
SetPrvt("oGetImp","oGetData","oGetMoeda","oGetTxMedia","oGetVlBru","oGetObserv","oGrp2","oGrp3","oBtAnexo","oBtSalvar")

// Criação do aHeader temporário para ser usado nas parcelas, Valor da proposta
Private aHeadOve	:= {}
Private aAcolOve	:= {}
Private nUseOve		:= 0
Private aAlterOve	:= {"M_VENC","M_VALOR"}

AADD(aHeadOve,{ TRIM("Parcela"),;
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
nUseOve += 1
AADD(aHeadOve,{ TRIM("Vencimento"),;
					 "M_VENC",;
					 "",;
					 8,;
 					 0,;
 					 "ALLWAYSTRUE()",;
 					 "€€€€€€€€€€€€€€ ",;
 					 "D",;
 					 "",;
 					 "" } )
nUseOve += 1
AADD(aHeadOve,{ TRIM("Valor"),;
					 "M_VALOR",;
					 "@E 99,999,999,999.99",;
					 17,;
 					 2,;
 					 "ALLWAYSTRUE()",;
 					 "€€€€€€€€€€€€€€ ",;
 					 "N",;
 					 "",;
 					 "" } )
nUseOve += 1

If nOpcOve == 4 .or. nOpcOve == 5
	//Overrrun - Coluna esquerda
    nPosZ27Cod := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_CODIGO"})
    nPosZ27Dta := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_DTAINC"})
    nPosZ27Hra := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_HORAPR"})
    nPosZ27Moe := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_MOEDA"})
   	nPosZ27VlL := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRLIQ"})
    nPosZ27VlT := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRTOT"})
    nPosZ27TxM := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_TAXAME"})
   	nPosZ27Imp := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_IMPOST"})
   	nPosZ27Obs := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_OBS"})
EndIf

if nOpcOve == 3
	cGetMoeda  := Z55->Z55_MOEDA

Elseif nOpcOve == 4
	If nPosZ27Cod > 0
		cGetCod    := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Cod]
    	//Verifico se a alteração é de um overrun incluído no momento			
		DbSelectArea("Z27")
		DbSetOrder(1)
		If Z27->(DbSeek(xFilial("Z27")+Z55->Z55_NUM+Z55->Z55_REVISA+oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Cod]))
           	Alert("Não é possível alterar Overrun cadastrado anteriormente!","Grant Thornton Brasil")
			Return
		EndIf
	EndIf
	if nPosZ27Dta>0
		dGetData   := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Dta]
	endif
	if nPosZ27Hra>0
		nGetHora   := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Hra]
	endif
	if nPosZ27Imp>0
		nGetImp    := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Imp]
	endif
	if nPosZ27Moe>0
		cGetMoeda  := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Moe]
            endif
            if nPosZ27TxM>0
		nGetTxMedi := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27TxM]
	endif
	if nPosZ27VlT>0
		nGetVlBru  := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27VlT]
	endif
	if nPosZ27VlL>0
		nGetVlLiq  := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27VlL]
	endif
	if nPosZ27Obs>0
		cObserv  := oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Obs]
	endif

	//Parcelas - Coluna direita
	cValGOve_1	:=Transform(nGetVlBru,'@E 99,999,999,999.99')
	cValGOve_2	:=Transform(nGetVlBru,'@E 99,999,999,999.99')
	
	// Gravo o temporário de parcelas de pagamentos de overrun
	nPosParc	:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_PARC"})
	nPosVenc	:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VENC"})
	nPosVlr		:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VALOR"})

	If empty(cGetCod)
		Return
	EndIf

	DbSelectArea("TZ49OVE")
	TZ49OVE->(DbSetOrder(1))
	TZ49OVE->(DbSeek(cGetCod))
	While TZ49OVE->(!EOF()) .AND. alltrim(TZ49OVE->OVERRUN)==alltrim(cGetCod)
		if alltrim(TZ49OVE->PARCELA)=="1"
			dValGOve_6:=TZ49OVE->VENCIMENTO
		endif

		AADD(aAcolOve,{TZ49OVE->PARCELA,TZ49OVE->VENCIMENTO,TZ49OVE->VALOR,.F.})

		nValGOve_4:=val(TZ49OVE->PARCELA)

		TZ49OVE->(DbSkip())
	Enddo

Elseif nOpcOve == 5
	If nPosZ27Cod == 0
       	Alert("Não foi possível visualizar Overrun cadastrado!","Grant Thornton Brasil")
		Return
	EndIf

	DbSelectArea("Z27")
	DbSetOrder(1)
	If !Z27->(DbSeek(xFilial("Z27")+Z55->Z55_NUM+Z55->Z55_REVISA+oGetDadOve:aCols[oGetDadOve:nAt][nPosZ27Cod]))
       	Alert("Visualização permitida apenas para Overrun cadastrado anteriormente!","Grant Thornton Brasil")
		Return
	EndIf

	cGetCod    := Z27->Z27_CODIGO
	dGetData   := Z27->Z27_DTAINC
	nGetHora   := Z27->Z27_HORAPR
	nGetImp    := Z27->Z27_IMPOST
	cGetMoeda  := Z27->Z27_MOEDA
	nGetTxMedi := Z27->Z27_TAXAME
	nGetVlBru  := Z27->Z27_VLRTOT
	nGetVlLiq  := Z27->Z27_VLRLIQ
	cObserv    := Z27->Z27_OBS

	//Parcelas - Coluna direita
	cValGOve_1	:=Transform(nGetVlBru,'@E 99,999,999,999.99')
	cValGOve_2	:=Transform(nGetVlBru,'@E 99,999,999,999.99')
	
	// Gravo o temporário de parcelas de pagamentos de overrun
	nPosParc	:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_PARC"})
	nPosVenc	:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VENC"})
	nPosVlr		:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VALOR"})

	If Empty(cGetCod)
		Return
	EndIf

	Z49->(DbSetOrder(2))//Z49_FILIAL+Z49_PROPOS+Z49_REVISA+Z49_TIPO+Z49_CODOVE
	If Z49->(DbSeek(xFilial("Z49")+Z55->Z55_NUM+Z55->Z55_REVISA+'OVERRUN     '+cGetCod))   
		While Z49->(!EOF()) .AND. alltrim(Z49->Z49_PROPOS) == alltrim(Z55->Z55_NUM) .and.;
									alltrim(Z49->Z49_REVISA) == alltrim(Z55->Z55_REVISA) .and.;
									alltrim(Z49->Z49_CODOVE) == alltrim(cGetCod)
			If ALLTRIM(Z49->Z49_TIPO) == 'OVERRUN'
				If alltrim(Z49->Z49_PARCEL) == "1"
					dValGOve_6:= Z49->Z49_VENCTO
				EndIf
				
				nValGOve_4 := val(Z49->Z49_PARCEL)

				AADD(aAcolOve,{Z49->Z49_PARCEL,Z49->Z49_VENCTO,Z49->Z49_VALOR,.F.})
			EndIf
			Z49->(DbSkip())
		Enddo
	EndIf
endif

oDlgZ27	:= MSDialog():New( 091,232,414,1215,"Cobrança de Overrun",,,.F.,,,,,,.T.,,,.T. )
oGrp1	:= TGroup():New( 004,004,120,236,"Overrun",oDlgZ27,CLR_BLACK,CLR_WHITE,.T.,.F. )

aLinCol:=PosCampO(@aOrdLab,lVeCoOve)
oSay1      := TSay():New( aLinCol[1],aLinCol[2],{||"Código:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeDtOve)
oSay5      := TSay():New( aLinCol[1],aLinCol[2],{||"Data:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeHoOve)
oSay2      := TSay():New( aLinCol[1],aLinCol[2],{||"Horas:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeMoOve)
oSay6      := TSay():New( aLinCol[1],aLinCol[2],{||"Moeda:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeVLOve)
oSay3      := TSay():New( aLinCol[1],aLinCol[2],{||"Vl. Liquido:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeTxOve)
oSay7      := TSay():New( aLinCol[1],aLinCol[2],{||"Tx. Média:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeImOve)
oSay4      := TSay():New( aLinCol[1],aLinCol[2],{||"Imposto:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

aLinCol:=PosCampO(@aOrdLab,lVeVBOve)
oSay8      := TSay():New( aLinCol[1],aLinCol[2],{||"Vl. Bruto:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)	

aLinCol:=PosCampO(@aOrdLab,lVeObOve)
oSay9      := TSay():New( aLinCol[1],aLinCol[2],{||"Obs:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)	

//Tratamento para edição dos campos.
lReadOnly := (nOpcOve == 5)
    
aLinCol:=PosCampO(@aOrdGet,lVeCoOve)
oGetCod    := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,cGetCod:=u,cGetCod)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,lReadOnly,.F.,"","cGetCod",,)

aLinCol:=PosCampO(@aOrdGet,lVeDtOve)
oGetData   := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,dGetData:=u,dGetData)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,lReadOnly,.F.,"","dGetData",,)

aLinCol:=PosCampO(@aOrdGet,lVeHoOve)
oGetHora   := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,nGetHora:=u,nGetHora)},oGrp1,060,008,'@E 9999999.9',{||IIF(nGetHora<0,(alert("Não é permitido informar valor negativo!"),.F.),.T.)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||AtuTxVlZ27()},lReadOnly,.F.,"","nGetHora",,)

aLinCol:=PosCampO(@aOrdGet,lVeMoOve)
oGetMoeda  := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,cGetMoeda:=u,cGetMoeda)},oGrp1,060,008,'',{|| VldMoeda()	},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,lReadOnly,.F.,"","cGetMoeda",,)

aLinCol:=PosCampO(@aOrdGet,lVeVLOve)
oGetVlLiq  := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,nGetVlLiq:=u,nGetVlLiq)},oGrp1,060,008,'@E 99,999,999,999.99',{||IIF(nGetVlLiq<0,(alert("Não é permitido valor negativo!"),.F.),.T.)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||AtuTxVlZ27()},lReadOnly,.F.,"","nGetVlLiq",,)

aLinCol:=PosCampO(@aOrdGet,lVeTxOve)
oGetTxMedi := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,nGetTxMedia:=u,nGetTxMedia)},oGrp1,060,008,'@E 9,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,lReadOnly,.F.,"","nGetTxMedia",,)

aLinCol:=PosCampO(@aOrdGet,lVeImOve)
oGetImp    := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,nGetImp:=u,nGetImp)},oGrp1,060,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,lReadOnly,.F.,"","nGetImp",,)

aLinCol:=PosCampO(@aOrdGet,lVeVBOve)
oGetVlBru  := TGet():New( aLinCol[1],aLinCol[2],{|u| If(PCount()>0,nGetVlBru:=u,nGetVlBru)},oGrp1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,lReadOnly,.F.,"","nGetVlBru",,)

aLinCol:=PosCampO(@aOrdGet,lVeObOve)  
@ aLinCol[1],aLinCol[2] GET oGetObserv VAR cObserv MEMO SIZE 170,032 PIXEL OF oGrp1 WHEN !lReadOnly

oGetCod:Disable()
oGetData:Disable()
oGetTxMedi:Disable()
oGetImp:Disable()
oGetVlBru:Disable()

oGetMoeda:cF3 := "CTO"

if !lVeCoOve
	oSay1:Hide()
	oGetCod:Hide()
endif
if !lVeDtOve
    oSay5:Hide()
	oGetData:Hide()    
    endif
if !lVeHoOve
	oSay2:Hide()
	oGetHora:Hide()
endif
if !lVeMoOve
	oSay6:Hide()
	oGetMoeda:Hide()
endif
if !lVeVLOve
	oSay3:Hide()
	oGetVlLiq:Hide()
endif
if !lVeTxOve
	oSay7:Hide()
	oGetTxMedi:Hide()
endif
if !lVeImOve
	oSay4:Hide()
	oGetImp:Hide()
endif
if !lVeVBOve
	oSay8:Hide()
	oGetVlBru:Hide()
endif

oGrp2			:= TGroup():New( 004,256,120,488,"Parcelas",oDlgZ27,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayGOve_1		:= tSay():New(15,256+10, {||'Valor Bruto: ' +alltrim(cValGOve_1)},oDlgZ27,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
oSayGOve_2		:= tSay():New(15,256+110,{||'Valor das Parcelas: '+alltrim(cValGOve_2)},oDlgZ27,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		
oSayGOve_3		:= tSay():New(27,256+10, {||'Parcelas: '},oDlgZ27,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)

@25,256+40	MSGET oSayGOve_4 VAR nValGOve_4 PICTURE "999" SIZE 15,8 OF oDlgZ27 PIXEL ; 
			VALID(LoadOve(oGetDdsOve,cvaltochar(nValGOve_4),Transform(nGetVlBru,'@E 99,999,999,999.99'),@oSayGOve_1,@cValGOve_1,@cValGOve_2,oSayGOve_2,cvaltochar(DAY(dValGOve_6)),oGetDdsOve,aHeadOve,dValGOve_6)) ;
			WHEN !lReadOnly
	
oSayGOve_5		:= tSay():New(27,256+110, {||'Dt Inicial: '},oDlgZ27,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
@25,256+140	MSGET oSayGOve_6 VAR dValGOve_6 SIZE 40,8 OF oDlgZ27 PIXEL ;
			VALID(CarregaDia(cvaltochar(DAY(dValGOve_6)),oGetDdsOve,aHeadOve,dValGOve_6)) ;
			When !lReadOnly

If nOpcOve == 5
	aAlterOve := {}
EndIf

oGetDdsOve:= MsNewGetDados():New(47,256+10,125-15,500-23,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
                             aAlterOve,000,nValGOve_4,"U_I_FG73O5","AllwaysTrue","AllwaysFalse",oDlgZ27,aHeadOve,aAcolOve)

oGrp3      := TGroup():New( 124,004,152,488,"",oDlgZ27,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtAnexo   := TButton():New( 133,016,"Anexos",oGrp3,{||AnexoP00(nOpc,@cItemZ48,xParam5)},037,012,,,,.T.,,"",,,,.F. )
If nOpcOve <> 5
	oBtSalvar  := TButton():New( 133,381,"Salvar",oGrp3,{||IIF(GravZ27Aux(nUsadoZ27,nOpcOve),oDlgZ27:End(),)},037,012,,,,.T.,,"",,,,.F. )
EndIf
oBtCancel  := TButton():New( 133,430,"Cancelar",oGrp3,{||CtAnexZ27("CANCELA"),oDlgZ27:End()},037,012,,,,.T.,,"",,,,.F. )

oDlgZ27:Activate(,,,.T.)

Return
//Busca o próximo código válido de overrun para a proposta atual
*---------------------------*
Static Function ProxCodZ27()    
*---------------------------*
Local cQry 		:= ""
Local cProxCod	:= "000001"

	cQry:=" SELECT MAX(Z27_CODIGO) AS Z27_CODIGO FROM "+RETSQLNAME("Z27")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND Z27_FILIAL='"+xFilial("Z27")+"' AND Z27_NUMPRO='' AND Z27_REVISA=''"
		
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0
        	QRYTEMP->(DbGotop())
        	cProxCod:=SOMA1(QRYTEMP->Z27_CODIGO)
        endif

		nPosZ27Cod:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_CODIGO"})
        
		if !empty(oGetDadOve:aCols[Len(oGetDadOve:aCols)][nPosZ27Cod])
	   		cProxCod:=SOMA1(oGetDadOve:aCols[Len(oGetDadOve:aCols)][nPosZ27Cod])
		endif


Return(cProxCod)

//Atualiza os campos de taxa e vlr bruto da tela de overrun
*---------------------------*
Static function AtuTxVlZ27()
*---------------------------*	
Local nVlrImp:= ((100-nGetImp)/100)

If nGetHora<>0
	nGetTxMedia := nGetVlLiq/nGetHora
EndIf

//nGetVlBru:= nGetVlLiq+(nGetVlLiq*(nGetImp/100))
nGetVlBru := nGetVlLiq/nVlrImp

cValGOve_1 := Transform(nGetVlBru,'@E 99,999,999,999.99')

oGetTxMedi:Refresh()
oGetVlBru:Refresh()

Return

/*
Funcao      : LoadOve
Parametros  : oQual1,cValParc,cValAux,oSayG3_2_1,cValG3_2_1,cValG3_2_2,oSayG3_2_2,cVal,oGetDad,aHead,dVal
Retorno     : 
Objetivos   : Função para carregar as parcelas no aCols, de Overrun
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2014
*/

*---------------------------------------------------------------------------------------------------------------------*
Static Function LoadOve(oQual1,cValParc,cValAux,oSayG3_2_1,cValG3_2_1,cValG3_2_2,oSayG3_2_2,cVal,oGetDad,aHead,dVal)
*---------------------------------------------------------------------------------------------------------------------*
Local nVal	 	:= 0
Local nTotVal	:= 0
oQual1:aCols	:= {}

nVal := StrTran(cValAux,".","")
nVal := StrTran(nVal,",",".")
nVal := Val(nVal)/val(cValParc)

	if val(cValParc)<>0
		for i:=1 to val(cValParc)
			AADD(oQual1:aCols,{cvaltochar(i), CTOD("//"),nVal,.F. })
			nTotVal+=nVal
		next
	else
		oQual1:aCols:={}
	endif

cValG3_2_2:=Transform(nTotVal,'@E 99,999,999,999.99')

cValG3_2_1:=Transform(nGetVlBru,'@E 99,999,999,999.99')

oQual1:Refresh()
oSayG3_2_1:Refresh()
oSayG3_2_2:Refresh()

CarregaDia(cVal,oGetDad,aHead,dVal)

Return

//Grava os valores de overrun no acols do Z27 e as parcelas no temporário
*-------------------------------------------*
Static Function GravZ27Aux(nUsadoZ27,nOpcOve)
*-------------------------------------------*    
Local lRet		:= .T.
Local nLinha 	:= 1
Local lFoiAnexado	:= .F.

//OBRIGATORIO - Inicio - Verifica se os campos origatórios estão preenchidos
If lVeHoOve .and. empty(nGetHora)
	Alert("Por favor, informe o campo: Horas")
	Return .F. 
ElseIf lVeMoOve .and. empty(cGetMoeda)
	Alert("Por favor, informe o campo: Moeda")
	Return .F. 
ElseIf lVeVLOve .and. empty(nGetVlLiq)
	Alert("Por favor, informe o campo: Vl. Liquido")
	Return .F. 
EndIf
//OBRIGATORIO - Fim

//Valida se o valor bruto é o mesmo das parcelas
If alltrim(cValGOve_1) <> alltrim(cValGOve_2)
	Alert("O valor das parcelas deve ser o mesmo do valor bruto!")
	Return .F.    
EndIf

//Valida se as parcelas estão preenchidas corretamente
For nI:=1 To Len(oGetDdsOve:aCols)
	//Verifica se o vencimento está preenchido
	If Empty(oGetDdsOve:aCols[nI][2])
		Alert("Verifique a data de vencimento da parcela "+ AllTrim(Str(nI)) + ".")
		Return .F.
	EndIf

	//Verifica se o valor da parcela está preenchido
	If oGetDdsOve:aCols[nI][3] <= 0
		Alert("Verifique o valor da parcela "+ AllTrim(Str(nI)) + ".")
		Return .F.
	EndIf
Next

//ANEXO - Inicio - Verifica se foi anexado um item
DbSelectArea("Z48")
Z48->(DbGoTop())
DbSetOrder(1)
DbSeek(xFilial("Z48")+Z55->Z55_NUM+Z55->Z55_REVISA)
While Z48->(!EOF()) .AND.	Z48->Z48_PROPOS == Z55->Z55_NUM .AND.;
							Z48->Z48_REVISA == Z55->Z55_REVISA
	If Z48->Z48_TIPO=="O"
		lFoiAnexado:= .T.
		exit
	EndIf
	Z48->(DbSkip())
Enddo    			
    			
If !lFoiAnexado
	Alert("É obrigatório anexar(arquivar) a cobrança de Overrun!")
	Return .F.
EndIf
//ANEXO - Fim

If empty(oGetDadOve:aCols[1][1])
	oGetDadOve:aCols:={}
EndIf

nPosZ27Cod := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_CODIGO"})
nPosZ27Dta := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_DTAINC"})
nPosZ27Hra := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_HORAPR"})
nPosZ27Moe := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_MOEDA"})
nPosZ27VlL := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRLIQ"})
nPosZ27VlT := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRTOT"})
nPosZ27TxM := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_TAXAME"})
nPosZ27Imp := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_IMPOST"})
nPosZ27Obs := Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_OBS"})

If nOpcOve==4    //Se for alterar deleto as linhas do pagamento para gerar as novas no temporário
	DbSelectArea("TZ49OVE")
	TZ49OVE->(DbSetOrder(1))
	TZ49OVE->(DbSeek(cGetCod))
	While TZ49OVE->(!EOF()) .AND. alltrim(TZ49OVE->OVERRUN) == alltrim(cGetCod)
       	Reclock("TZ49OVE",.F.)
       	TZ49OVE->(DbDelete())
   		TZ49OVE->(MsUnlock())

   		TZ49OVE->(DbSkip())
	Enddo
EndIf

If nOpcOve==3
	//Cria a linha do aCols
	aAdd(oGetDadOve:aCols,Array(nUsadoZ27+1))
	nLinha:= Len(oGetDadOve:aCols)

elseif nOpcOve==4
	nLinha:= oGetDadOve:nAt

endif

if nPosZ27Cod > 0
	oGetDadOve:aCols[nLinha][nPosZ27Cod] := cGetCod
endif
if nPosZ27Dta > 0
	oGetDadOve:aCols[nLinha][nPosZ27Dta] := dGetData
endif
if nPosZ27Hra > 0
	oGetDadOve:aCols[nLinha][nPosZ27Hra] := nGetHora
endif
if nPosZ27Moe > 0
	oGetDadOve:aCols[nLinha][nPosZ27Moe] := cGetMoeda					
endif
if nPosZ27VlL > 0
	oGetDadOve:aCols[nLinha][nPosZ27VlL] := nGetVlLiq
endif
if nPosZ27VlT > 0
	oGetDadOve:aCols[nLinha][nPosZ27VlT] := nGetVlBru
endif
if nPosZ27TxM > 0
	oGetDadOve:aCols[nLinha][nPosZ27TxM] := nGetTxMedia
endif
if nPosZ27Imp > 0
	oGetDadOve:aCols[nLinha][nPosZ27Imp] := nGetImp
endif
if nPosZ27Obs > 0
	oGetDadOve:aCols[nLinha][nPosZ27Obs] := cObserv
endif
						
//Indica que a linha não está deletada
oGetDadOve:aCols[Len(oGetDadOve:aCols),nUsadoZ27+1]:=.F.       	

// Gravo o temporário de parcelas de pagamentos de overrun
nPosParc	:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_PARC"})
nPosVenc	:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VENC"})
nPosVlr		:= Ascan(aHeadOve,{|x| alltrim(x[2]) = "M_VALOR"})

if !empty(oGetDdsOve:Acols)
    for nW:=1 to len(oGetDdsOve:Acols)
    	if empty(oGetDdsOve:Acols[nW][1])
    	   loop
    	else
    		RecLock("TZ49OVE",.T.)
    		TZ49OVE->OVERRUN	:= cGetCod
    		TZ49OVE->PARCELA	:= oGetDdsOve:Acols[nW][nPosParc]
    		TZ49OVE->VENCIMENTO	:= oGetDdsOve:Acols[nW][nPosVenc]
    		TZ49OVE->VALOR		:= oGetDdsOve:Acols[nW][nPosVlr]
	    	TZ49OVE->(MsUnLock())
    	endif
    next
endif

//Atualiza valores da aba totais da tela de overrun
AtuValOve()

oGetDadOve:Refresh()

Return(lRet)

//Cria um temporário auxíliar a tabela de pagamentos para overrun
*---------------------------*
Static Function AuxZ49Ove()
*---------------------------*
Local aDadTemp	:= {}
Local cQry		:= ""

AADD(aDadTemp,{"OVERRUN","C",6,0})
AADD(aDadTemp,{"PARCELA","C",3,0})
AADD(aDadTemp,{"VENCIMENTO","D",8,0})
AADD(aDadTemp,{"VALOR","N",17,2})


if select("TZ49OVE")>0
	TZ49OVE->(DbCloseArea())
endif

cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TZ49OVE",.T.,.F.)

cIndex:=CriaTrab(Nil,.F.)
IndRegua("TZ49OVE",cIndex,"OVERRUN+PARCELA",,,"Selecionando Registro...")

DbSelectArea("TZ49OVE")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

cNum	:= Z55->Z55_NUM
cRev	:= Z55->Z55_REVISA


	cQry:=" SELECT * FROM "+RETSQLNAME("Z49")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND Z49_FILIAL='"+xFilial("Z49")+"' AND Z49_PROPOS='"+cNum+"' AND Z49_REVISA='"+cRev+"' AND Z49_TIPO='OVERRUN' "
	cQry+=" ORDER BY Z49_CODOVE"
	
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0
 		QRYTEMP->(DbGotop())
		
		While QRYTEMP->(!EOF())
			RecLock("TZ49OVE",.T.)
				TZ49OVE->OVERRUN	:= QRYTEMP->Z49_CODOVE
				TZ49OVE->PARCELA	:= QRYTEMP->Z49_PARCEL
				TZ49OVE->VENCIMENTO	:= STOD(QRYTEMP->Z49_VENCTO)
				TZ49OVE->VALOR		:= QRYTEMP->Z49_VALOR
			MsUnlock()
		
			QRYTEMP->(DbSkip())
		EndDo
		
    endif


Return

//Atualiza valores da tela de overrun, totais
*-------------------------*
Static Function AtuValOve()
*-------------------------*
nVZ27_VL_O	:= 0
nVZ27_VB_O	:= 0
nVZ27_H_O	:= 0

	nPosZ27VlL:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRLIQ"})
	nPosZ27VlT:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_VLRTOT"})
    nPosZ27Hra:=Ascan(oGetDadOve:aHeader,{|x| alltrim(x[2]) = "Z27_HORAPR"})

	for i:=1 to len(oGetDadOve:Acols)
		if nPosZ27VlL>0
			nVZ27_VL_O+= oGetDadOve:Acols[i][nPosZ27VlL]
		endif
		if nPosZ27VlT>0
			nVZ27_VB_O+= oGetDadOve:Acols[i][nPosZ27VlT] 
		endif
		if nPosZ27Hra>0
			nVZ27_H_O += oGetDadOve:Acols[i][nPosZ27Hra] 
		endif
	next


nVZ27_VL_T:=nVZ27_VL_O+nVZ27_VL_P
nVZ27_VB_T:=nVZ27_VB_O+nVZ27_VB_P

if lVeHoOve
	nVZ27_H_T:=nVZ27_H_O+nVZ27_H_P
endif

Return

//Controle de anexo no Overrun
*-------------------------------*
Static Function CtAnexZ27(cOnde)
*-------------------------------*
Local cQry :=""

	if cOnde=="INICIO"
		cQry:=" SELECT Z48_FILIAL+Z48_PROPOS+Z48_REVISA+Z48_ITEM as CHAVE FROM "+RETSQLNAME("Z48")
		cQry+=" WHERE D_E_L_E_T_='' AND Z48_FILIAL='"+xFilial("Z48")+"' AND Z48_PROPOS='"+Z55->Z55_NUM+"' AND Z48_REVISA='"+Z55->Z55_REVISA+"'"
		cQry+=" ORDER BY Z48_FILIAL,Z48_PROPOS,Z48_REVISA,Z48_ITEM DESC
	   
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
	    
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
		Count to nRecCount
	
		if nRecCount >0
	       	QRYTEMP->(DbGotop())
			
			cAnexAtu:=QRYTEMP->CHAVE
			
	    endif
    
    elseif cOnde=="CANCELA"

			DbSelectArea("Z48")
			Z48->(DbSetOrder(1))
			Z48->(DbGoTop())
			
			if DbSeek(cAnexAtu)
				Z48->(DbSkip())
				
				While Z48->(!EOF()) .AND. Z48->Z48_PROPOS==Z55->Z55_NUM .AND. Z48->Z48_REVISA==Z55->Z55_REVISA
					
					RecLock("Z48",.F.)
						Z48->(DbDelete())
					MsUnlock()    
					
					Z48->(DbSkip())
				Enddo
			endif
    endif
    
Return

//Função para validar o tamaho do nome do arquivo selecionado.
*---------------------------------*
Static Function ValTamAn(cArquivo)
*---------------------------------*
Local nPos	:= Ascan(aHeader,{|x| alltrim(x[2]) = "ARQUIVO"})
Local lRet	:= .T.

if len(cArquivo) > aHeader[nPos][4]
	Alert("A composição do local mais o nome do arquivo é muito grande!")
	lRet:=.F.
endif

Return(lRet)

//Função para retirar acentos
*-----------------------------*
Static Function NoAcento(Arg1)
*-----------------------------*
Local nConta := 0
Local cLetra := ""
Local cRet := ""

Arg1 := Upper(Arg1)

For nConta:= 1 To Len(Arg1)

	cLetra := SubStr(Arg1, nConta, 1)

	Do Case
		Case (Asc(cLetra) > 191 .and. Asc(cLetra) < 198) .or. (Asc(cLetra) > 223 .and. Asc(cLetra) < 230)
			cLetra := "A"
		Case (Asc(cLetra) > 199 .and. Asc(cLetra) < 204) .or. (Asc(cLetra) > 231 .and. Asc(cLetra) < 236)
			cLetra := "E"
		Case (Asc(cLetra) > 204 .and. Asc(cLetra) < 207) .or. (Asc(cLetra) > 235 .and. Asc(cLetra) < 240)
			cLetra := "I"
		Case (Asc(cLetra) > 209 .and. Asc(cLetra) < 215) .or. (Asc(cLetra) == 240) .or. (Asc(cLetra) > 241 .and. Asc(cLetra) < 247)
			cLetra := "O"
		Case (Asc(cLetra) > 216 .and. Asc(cLetra) < 221) .or. (Asc(cLetra) > 248 .and. Asc(cLetra) < 253)
			cLetra := "U"
		Case Asc(cLetra) == 199 .or. Asc(cLetra) == 231
			cLetra := "C"
	EndCase
	
	cRet := cRet+cLetra
Next

Return UPPER(cRet)

//Função auxíliar a da tela de cadastro de overrun, para a montagem da ordem dos campos                        
*---------------------------------*
Static Function PosCampO(aRec,lRec)
*---------------------------------*
Local aRet:={0,0}

DEFAULT lRec := .T.

If lRec
	aRet:=aRec[1]
	ADEL(aRec,1)
EndIf

Return(aRet)

/*
Funcao      : GrvOrc
Parametros  : 
Retorno     : 
Objetivos   : Função para Gravar Orçamento de parcelas de Overrun
Autor       : Jean Victor Rocha
Data/Hora   : 23/04/2015
*/
*--------------------------------------------*
Static Function GrvOrc(cNum,cRevisao,aCodOver)
*--------------------------------------------*
Local aOrd := SaveOrd({"Z55","Z27","CN9"})
Local cQry := ""

cQry += " Select Z49.Z49_VENCTO,Z49.Z49_VALOR,Z49.Z49_CODOVE,
cQry += " 		Z55.Z55_CLIENT,Z55.Z55_LOJA,
cQry += " 		Z42.Z42_IDUSER,
cQry += " 		Z27.Z27_FILIAL,Z27.Z27_NUMPRO,Z27.Z27_MOEDA,ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), Z27.Z27_OBS)),'') AS Z27_OBS,
cQry += " 		CN9.CN9_NUMERO,
cQry += " 		SB1.B1_COD,SB1.B1_DESC,SB1.B1_TS,
cQry += " 		SCJ.CJ_FILIAL
cQry += " From "+RETSQLNAME("Z49")+" Z49
cQry += " 	Left Outer Join(Select * From "+RETSQLNAME("Z55")+") as Z55 on Z49.Z49_FILIAL = Z55.Z55_FILIAL AND
cQry += " 												  			Z49.Z49_PROPOS = Z55.Z55_NUM AND
cQry += " 												  			Z49.Z49_REVISA = Z55.Z55_REVISA
cQry += " 	left Outer Join(Select * From "+RETSQLNAME("Z42")+") as Z42 on Z42.Z42_CPF = Z55.Z55_SOCIO
cQry += " 	left Outer Join(Select * From "+RETSQLNAME("Z27")+") as Z27 on Z27.Z27_FILIAL = Z55.Z55_FILIAL AND
cQry += " 												 			Z27.Z27_NUMPRO = Z55.Z55_NUM AND
cQry += " 															Z27.Z27_REVISA = Z55.Z55_REVISA AND
cQry += " 															Z27.Z27_CODIGO = Z49.Z49_CODOVE
cQry += " 	left Outer Join(Select * From "+RETSQLNAME("CN9")+") as CN9 on CN9.CN9_FILIAL = Z55.Z55_FILIAL AND
cQry += " 												 			CN9.CN9_P_NUM = Z27.Z27_NUMPRO AND
cQry += " 											 				CN9.CN9_CLIENT = Z55.Z55_CLIENT AND
cQry += " 															CN9.CN9_LOJACL = Z55.Z55_LOJA
cQry += " 	left Outer Join(Select * From "+RETSQLNAME("SB1")+") as SB1 on SB1.B1_FILIAL = Z55.Z55_FILIAL AND
//cQry += " 												   			SB1.B1_COD = (Case When Z55.Z55_COBTIP = '1' then '500057' else '600057' end)
cQry += " 												   			SB1.B1_COD = (Case When Z27.Z27_MOEDA = '01' then '500057' else '600057' end)
cQry += " 	left Outer Join(Select * From "+RETSQLNAME("SCJ")+") as SCJ on SCJ.CJ_FILIAL = Z27.Z27_FILIAL AND
cQry += " 												  			SCJ.CJ_P_NUM = Z27.Z27_NUMPRO AND
cQry += " 															SCJ.CJ_P_OVE = Z49.Z49_CODOVE
cQry += " Where Z49.Z49_CODOVE <> ''
cQry += " 	AND Z49.Z49_PROPOS = '"+cNum+"'
cQry += " 	AND Z49.Z49_REVISA = '"+cRevisao+"'
cQry += " 	AND Z49.Z49_TIPO = 'OVERRUN'
cQry += " 	AND SCJ.CJ_FILIAL is null
If Len(aCodOver) <> 0
	cQry += " 	AND Z49.Z49_CODOVE not in (
	For i:=1 to LEN(aCodOver)
		cQry += "'"+aCodOver[i]+"',"
	Next i
	cQry := LEFT(cQry,LEN(cQry)-1)//retira a ultima virgula
	cQry += " )
EndIf

If select("QRYSCJ")>0
	QRYSCJ->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYSCJ", .F., .F. )

QRYSCJ->(DbGoTop())
If QRYSCJ->(!EOF())
	While QRYSCJ->(!EOF())
		cNumOrc := GetNumOrc()
		
		RecLock("SCJ",.T.)
		SCJ->CJ_FILIAL	:= QRYSCJ->Z27_FILIAL
		SCJ->CJ_NUM		:= cNumOrc
		SCJ->CJ_EMISSAO	:= dDataBase
		SCJ->CJ_CLIENTE	:= QRYSCJ->Z55_CLIENT
		SCJ->CJ_LOJA	:= QRYSCJ->Z55_LOJA
		SCJ->CJ_CLIENT	:= QRYSCJ->Z55_CLIENT
		SCJ->CJ_LOJAENT	:= QRYSCJ->Z55_LOJA
		SCJ->CJ_CONDPAG	:= "001"
		SCJ->CJ_MOEDA	:= VAL(QRYSCJ->Z27_MOEDA)
		SCJ->CJ_P_DTFAT	:= STOD(QRYSCJ->Z49_VENCTO)
		SCJ->CJ_DATA1	:= STOD(QRYSCJ->Z49_VENCTO)
		SCJ->CJ_P_EMAIL	:= UsrRetMail(QRYSCJ->Z42_IDUSER)
		SCJ->CJ_P_EMAIU	:= UsrRetMail(QRYSCJ->Z42_IDUSER)
		SCJ->CJ_P_NUM	:= QRYSCJ->Z27_NUMPRO
		SCJ->CJ_P_OVE	:= QRYSCJ->Z49_CODOVE
		SCJ->CJ_P_CONTR	:= QRYSCJ->CN9_NUMERO
		SCJ->CJ_P_OBSGT	:= QRYSCJ->Z27_OBS
		SCJ->CJ_STATUS	:= "A"
		SCJ->(MsUnLock())
		
		RecLock("SCK",.T.)
		SCK->CK_FILIAL	:= QRYSCJ->Z27_FILIAL
		SCK->CK_FILVEN	:= QRYSCJ->Z27_FILIAL
		SCK->CK_FILENT	:= QRYSCJ->Z27_FILIAL
		SCK->CK_NUM		:= cNumOrc
		SCK->CK_CLIENTE	:= QRYSCJ->Z55_CLIENT
		SCK->CK_LOJA	:= QRYSCJ->Z55_LOJA
		SCK->CK_ENTREG	:= dDataBase
		SCK->CK_DT1VEN	:= dDataBase
		SCK->CK_ITEM 	:= "01"
		SCK->CK_PRODUTO := QRYSCJ->B1_COD
		SCK->CK_DESCRI	:= QRYSCJ->B1_DESC + " - REF.PROP: " + QRYSCJ->Z27_NUMPRO
		SCK->CK_UM		:= "UN"
		SCK->CK_QTDVEN	:= 1
		SCK->CK_PRCVEN	:= QRYSCJ->Z49_VALOR
		SCK->CK_VALOR	:= QRYSCJ->Z49_VALOR
		SCK->CK_TES		:= QRYSCJ->B1_TS
		SCK->(MsUnLock())
				
		QRYSCJ->(DbSkip())
	EndDo
EndIf

If select("QRYSCJ")>0
	QRYSCJ->(DbCloseArea())
EndIf

RestOrd(aOrd)

Return .T.

/*
Funcao      : GetNumOrc
Parametros  : 
Retorno     : cRet
Objetivos   : Função para buscar o proximo numero de orçamento
Autor       : Jean Victor Rocha
Data/Hora   : 22/04/2015
*/
*-------------------------*
Static Function GetNumOrc()
*-------------------------*
Local cRet := "000000"
Local cQry := ""

cQry := " Select ISNULL(MAX(CJ_NUM),0)+1 AS NUMERO
cQry += "	FROM "+RETSQLNAME("SCJ")
    
If select("QRY")>0
	QRY->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRY", .F., .F. )

cRet := STRZERO(QRY->NUMERO,TamSx3("CJ_NUM")[1] )

Return cRet

/*
Funcao      : VldEnvMail
Parametros  : 
Retorno     : lRet
Objetivos   : Função para Validar o envio de email em Overrun
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2015
*/
*--------------------------*
Static Function VldEnvMail()
*--------------------------*
Local lRet := .F.
Local cQry := ""

If Z27->(FieldPos("Z27_MAILOK")) == 0
	Return lRet
EndIf

cQry := " Select COUNT(*) AS CONT 
cQry += " FROM "+RETSQLNAME("Z27")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += "		AND Z27_FILIAL = '"+Z55->Z55_FILIAL+"' 
cQry += "		AND Z27_NUMPRO = '"+Z55->Z55_NUM +"'
cQry += "		AND Z27_REVISA = '"+Z55->Z55_REVISA+"'
cQry += "		AND Z27_MAILOK <> 'S'
    
If select("QRY")>0
	QRY->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRY", .F., .F. )

lRet := QRY->CONT == 0

Return lRet

/*
Funcao      : VldMoeda
Parametros  : 
Retorno     : cRet
Objetivos   : Validação que será realizada na moeda do overrun
Autor       : Jean Victor Rocha
Data/Hora   : 30/04/2015
*/
*------------------------*
Static Function VldMoeda()
*------------------------*
Local lRet := .T.

If ExistCpo("CTO", cGetMoeda, 1)
	If cGetMoeda == "04"
		alert("Não é permitido utilizar a Moeda '04 - Gerencial'!")
		lRet := .F.
	Else
		nGetImp := AtuMoedaOver()
		AtuTxVlZ27()
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*
Funcao      : AtuMoedaOver
Parametros  : 
Retorno     : cRet
Objetivos   : GAtilho no momento em que alterar a moeda do verrun.
Autor       : Jean Victor Rocha
Data/Hora   : 29/04/2015
*/
*----------------------------*
Static Function AtuMoedaOver()
*----------------------------*
Local nRet := 0

If cGetMoeda <> "01" .And. cGetMoeda <> "04"
	nRet := 5
Else
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If DbSeek(xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA)
		If SA1->A1_PESSOA=="F"
			nRet := 5
		Else
			nRet := val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))   		
		EndIf
	EndIf
EndIf

Return nRet