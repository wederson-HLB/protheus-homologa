#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.ch"


/*
Funcao      : GTCORP40
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z79, Cadastro de Propostas
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*-----------------------*
User Function GTCORP40()
*-----------------------*
Local cString	:= "Z79"
Local lFilter	:= .T.	//Define se deve ser filtrado a apresentação das propostas por usuário
Local cIdUser	:= __cUserID // Id do usuário logado
Local cFiltro	:= ""
Local aIndexZ79 := {}

Private aRotina	:= {}


if !TCCANOPEN("Z83"+cEmpAnt+"0")//Departamento
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z83")
	Return()
endif
if !TCCANOPEN("Z82"+cEmpAnt+"0")//Area
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z82")
	Return()
endif
if !TCCANOPEN("Z81"+cEmpAnt+"0")//Serviço
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z81")
	Return()
endif
if !TCCANOPEN("Z80"+cEmpAnt+"0")//Departamento X Area X Serviço
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z80")
	Return()
endif
if !TCCANOPEN("Z79"+cEmpAnt+"0")//Capa das propostas
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z79")
	Return()
endif
if !TCCANOPEN("Z78"+cEmpAnt+"0")//Itens das propostas
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z78")
	Return()
endif
if !TCCANOPEN("Z77"+cEmpAnt+"0")//Controle de sequencia das propostas
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z77")
	Return()
endif
if !TCCANOPEN("Z70"+cEmpAnt+"0") //Posicionamento das propostas
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z70")
	Return()
endif
if !TCCANOPEN("Z69"+cEmpAnt+"0") //Pagamentos propostas
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z69")
	Return()
endif
if !TCCANOPEN("Z68"+cEmpAnt+"0") //Follow Up
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z68")
	Return()
endif
if !TCCANOPEN("Z67"+cEmpAnt+"0") //Anexos Propostas
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z67")
	Return()
endif
if !TCCANOPEN("Z66"+cEmpAnt+"0") //Capa controle de alçada
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z66")
	Return()
endif
if !TCCANOPEN("Z65"+cEmpAnt+"0") //Itens controle de alçada
	Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z65")
	Return()
endif
  

  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } ) 
AADD( aRotina, { "Visualizar"		, 'U_GTCORP39("Z79",RECNO(),2)' 	, 0 , 2 } ) 
AADD( aRotina, { "Incluir"			, 'U_GTCORP39("Z79",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Alterar"			, 'U_GTCORP39("Z79",RECNO(),4)' 	, 0 , 4 } ) 
//AADD( aRotina, { "Aprovar"			, 'U_GTCORP39("Z79",RECNO(),5)' 	, 0 , 5 } )
AADD( aRotina, { "Revisar"			, 'U_GTCORP39("Z79",RECNO(),6)' 	, 0 , 6 } )
AADD( aRotina, { "Legenda"			, 'U_LEGZ79'  						, 0 , 7 } )
AADD( aRotina, { "Env. Aprovacao GT", 'U_GTCORP39("Z79",RECNO(),8)'		, 0 , 8 } )
AADD( aRotina, { "Env. P/ Cliente"	, 'U_GTCORP39("Z79",RECNO(),9)'		, 0 , 9 } )
AADD( aRotina, { "Aprovar Cliente"	, 'U_GTCORP39("Z79",RECNO(),10)'	, 0 , 10} )
AADD( aRotina, { "Recusar Cliente"	, 'U_GTCORP39("Z79",RECNO(),11)'	, 0 , 11} )
AADD( aRotina, { "Incluir de Draft"	, 'U_GTCORP39("Z79",RECNO(),12)'	, 0 , 3 } )
AADD( aRotina, { "Excluir"			, 'U_GTCORP39("Z79",RECNO(),13)'	, 0 , 5 } )
AADD( aRotina, { "Imprimir"			, 'U_GTCORP46(RECNO())' 			, 0 , 13} )


Private aCores:={}

aCores := { {"Z79_STATUS == '1' .OR. Z79_STATUS == ' '" , "F6_NULL" 	},; // Em Aberto
			{"Z79_STATUS == '2'"						, "F14_CINZ"   },;	// Revisado //BR_BRANCO
			{"Z79_STATUS == '3'"						, "F12_AMAR"  	},;	// Pendente Aprovação GT
			{"Z79_STATUS == '4'"						, "F7_VERM" 	},;	// Recusado GT
			{"Z79_STATUS == '5'"						, "F10_VERD" 	},; // Aprovado GT
			{"Z79_STATUS == '6'"						, "BR_AMARELO" 	},;	// Pendente Aprovação Cliente //BPMSREC
			{"Z79_STATUS == '7'"						, "BR_VERMELHO"	},;	// Recusado Cliente
			{"Z79_STATUS == '8'"						, "BR_LARANJA" 	},;	// Aprovado sem Assinatura Cliente
			{"Z79_STATUS == '9'"						, "BR_VERDE" 	}}	// Aprovado com Assinatura Cliente

//			{"Z79_STATUS == 'A'"						, "F7_CINZ"   	},;	// Recusado GT/Revisado

/*
1 =	{"F6_NULL"  	,"Em Aberto            	   			" }
2 =	{"BR_BRANCO" 	,"Revisado							" }
3 =	{"F12_AMAR" 	,"Pendente Aprovação GT    			" }
4 =	{"F7_VERM"  	,"Recusado GT						" }
5 =	{"F10_VERD"  	,"Aprovado GT						" }
6 =	{"BPMSREC"    	,"Pendente Aprovação Cliente		" }
7 =	{"BR_VERMELHO"  ,"Recusado Cliente 	  				" }
8 =	{"BR_LARANJA"  	,"Aprovado sem Assinatura Cliente	" }
9 =	{"BR_VERDE" 	,"Aprovado com Assinatura Cliente	" }
*/

/*
aCores := {{"Z79_STATUS == '1' .OR. Z79_STATUS == ' ' ", "BR_AMARELO" },; // PENDENTE
			{"Z79_STATUS == '2'", "BR_VERDE"   	},;	 	// APROVADO
			{"Z79_STATUS == '3'", "BR_AZUL"  },; 		// PARCIALMENTE APROVADO
			{"Z79_STATUS == '4'", "BR_VERMELHO" },; 		//	RECUSADO
			{"Z79_STATUS == '5'", "BR_BRANCO" }} 		//	REVISADO
*/


/*

//Verifica se o usuário pode ver todas as propostas
DbSelectArea("Z66")
Z66->(DbSetOrder(1))
if Z66->(DbSeek(xFilial("Z66")+cIdUser))
	if Z66->Z66_LADMIN
		lFilter:=.F.
	else
	    if Z66->Z66_LVISP
			lFilter:=.F.
		elseif Z66->Z66_LRESPO //.OR. Z66->Z66_LAPROV
			DbSelectArea("Z65")
			Z65->(DbSetOrder(1))
			if Z65->(DbSeek(xFilial("Z65")+Z66->Z66_IDUSER))
	
				cFiltro:="Z79->Z79_USERRE = '"+cIdUser+"'"
				
				While Z65->(!eof()) .AND. Z65->Z65_FILIAL==xFilial("Z65") .AND.  Z65->Z65_IDUSER==Z66->Z66_IDUSER
					
					if Z66->Z66_LRESPO
						cFiltro+=".OR.( Z79->Z79_USERRE = '"+alltrim(Z65->Z65_IDDEPE)+"' .AND. Z79->Z79_RESPON = '"+alltrim(cIdUser)+"' )"
	                else
	                	cFiltro+=".OR. Z79->Z79_USERRE = '"+alltrim(Z65->Z65_IDDEPE)+"'"
	                endif
	                
					Z65->(DbSkip())
				Enddo
			else
				cFiltro:="Z79->Z79_USERRE = '"+cIdUser+"'"
			endif
		else
			cFiltro:="Z79->Z79_USERRE = '"+cIdUser+"'"
		endif
	endif
else
	Alert("Você não tem permissão para operar esta rotina!"+CRLF+"Solicite ao seu superior ou administrador que cadastre sua alçada do controle de propostas!")
	Return
endif

//Definição de filtro

If lFilter

	bCondicao := {|| &cFiltro}//{|| Z79->Z79_USERRE = cIdUser }
	cCondicao := cFiltro//"Z79->Z79_USERRE = '"+cIdUser+"'"
	DbSelectArea(cString)

	DbSetFilter(bCondicao,cCondicao)
Else
	DbSelec/tArea(cString)
Endif

*/

if !U_GT40Filtro(.F.,"Z79",aIndexZ79)
	Return
endif

//Define a tecla F12 para chamar a tela de filtro.
SetKey(VK_F12,{|| U_GT40Filtro(.T.,"Z79",@aIndexZ79)} )


DbSetOrder(1)
MBrowse( 6,1,22,75,cString,,,,,,aCores)

//Retira a função de filtro da tecla F12.
Set Key VK_F12  to

//Deleta o filtro da MBrowse.
EndFilBrw("Z79",aIndexZ79)

DbSelectArea("Z79")
 
Return

/*
Funcao      : GTCORP39()  
Parametros  : xParam1,xParam2,xParam3
Retorno     : .T.
Objetivos   : Montagem da tela para manutenção das informações da Tabela Z79 e Z78 (Enchoice e Getdados)
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*----------------------------------------------*
User Function GTCORP39(xParam1,xParam2,xParam3) 
*----------------------------------------------*
Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= {}
Local aAlterEnch	:= {}
Local aCpoEnch2		:= {}
Local aAlterEn2		:= {}
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


// Objeto no qual a MsNewGetDados sera criada                                      
Private aHeader     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aCols       := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 

// Informações da Z73 de Draft
Private aHeaZ73     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Private aColsZ73    := {}               // Array a ser tratado internamente na MsNewGetDados como aCols 
Private aCpoZ73		:= {}

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

Private cItemZ67	:= "" //Para itens do anexo

Private lUsaVlrTot	:= .F. // Valor total
Private lUsaVlrImp	:= .F. // Valor da implantação
Private lUsaVlrDip	:= .F. // Valor de DIPJ
Private lUsaVlrAno	:= .F. // Valor de anuidade


Private oGetDdsImp,oGetDdsDip,oGetDdsAno
Private cValG3_2_6,cValG3_3_6,cValG3_4_6

SET DATE FORMAT "dd/mm/yyyy"


//Verifica se o usuário tem permissão de incluir propostas
if nOpc<>2
	DbSelectArea("Z66")
	Z66->(DbSetOrder(1))
	if Z66->(DbSeek(xFilial("Z66")+cIdUser))
	   	if !Z66->Z66_LADMIN

		    if !Z66->Z66_LINCP
		    	alert("Você não tem permissão para esta opção!")
		    	Return
		    endif

		endif
	endif
	
endif

//if M->Z79_STATUS == '1' .OR. M->Z79_STATUS == ''
	AADD( aButtons, {"SDUIMPORT", {|| ServPAcol(nOpc)}, "Servicos...","Servicos",{|| .T.}} )
//endif
//if nOpc==10 .OR. nOpc==4
if nOpc<>3
	AADD( aButtons, {"ADICIONAR_001", {|| AnexoP00(nOpc,@cItemZ67)}, "Arquivos...","Arquivos",{|| .T.}} )
endif

	/*Preenche o array com os campos que serão utilizados na Enchoice*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("Z79")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z79"
		
		if X3Uso(SX3->X3_USADO) .AND. !(alltrim(SX3->X3_CAMPO) $ "Z79_FILIAL/Z79_MOTIGT"+iif(nOpc<>5 .AND. nOpc<>2,"/Z79_MOTIVO","")+iif(nOpc<>4 .AND. nOpc<>2,"/Z79_MOTALT","")+iif(nOpc<>8,"/Z79_APROVA","")+iif(nOpc<>10 .AND. nOpc<>11,"/Z79_OBSREC","")+iif(nOpc==3,"/Z79_MOTREC/Z79_OBSGT",""))
			
			if nOpc<>8 .AND. alltrim(SX3->X3_CAMPO) <> "Z79_NOMEAP"
			
				//Aba cadastro
				if SX3->X3_FOLDER=='1'
				
					AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
					AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
				    
					// Campos para alimentar através de draft
					if xParam3==12 .AND. (alltrim(SX3->X3_CAMPO)<>("Z79_DRAFT"))
						AADD(aCpoDra,alltrim(SX3->X3_CAMPO))
					endif
				endif
			
			else
			
				//Aba cadastro
				if SX3->X3_FOLDER=='1'
				
					AADD(aCpoEnch,alltrim(SX3->X3_CAMPO))
					AADD(aAlterEnch,alltrim(SX3->X3_CAMPO))
					
				endif
			
			endif
			
				//Aba Dados de Cobrança
				if SX3->X3_FOLDER=='2'
				
					AADD(aCpoEnCob,alltrim(SX3->X3_CAMPO))
					AADD(aAltCobEn,alltrim(SX3->X3_CAMPO))
					
				endif
			
		endif
		
		//Verificação da usabilidade dos campos para apresentação da aba pagamentos: 

		if alltrim(SX3->X3_CAMPO)=="Z79_VLRTOT" .AND. X3Uso(SX3->X3_USADO)//Valor da proposta
			lUsaVlrTot:=.T.
		elseif alltrim(SX3->X3_CAMPO)=="Z79_VLRIMP" .AND. X3Uso(SX3->X3_USADO) //Valor implantação
			lUsaVlrImp:=.T.
		elseif alltrim(SX3->X3_CAMPO)=="Z79_VLDIPJ" .AND. X3Uso(SX3->X3_USADO) //Valor DIPJ
			lUsaVlrDip:=.T.
		elseif alltrim(SX3->X3_CAMPO)=="Z79_VLRANO" .AND. X3Uso(SX3->X3_USADO) //Valor Anuidade
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
	DbSeek("Z78")
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="Z78"
		
		if X3Uso(SX3->X3_USADO) .AND. !(SX3->X3_CAMPO $ "Z78_FILIAL") 
			AADD(aCpoGDa,alltrim(SX3->X3_CAMPO))
			AADD(aAlter,alltrim(SX3->X3_CAMPO))		
		endif
			
		SX3->(DbSkip())
	Enddo

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
	Case xParam3 == 3
		INCLUI := .T. 
		//aAlter := {} 
		//aAlterEnch	:= {}
	Case xParam3 == 4 
		ALTERA := .T.
		aAlter := {}
		//aAlterEnch	:= {"Z79_VALOR","Z79_DESCON","Z79_VLRTOT","Z79_DESPER","Z79_DESCON","Z79_TPVLR","Z79_VLRTOT","Z79_MOTALT"}
		aAlterEnch	:= {"Z79_MOTALT"}
	Case xParam3 == 5
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z79_MOTIVO"}
		aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 6
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z79_RESPON","Z79_CLIENT","Z79_LOJA","Z79_PROSPE","Z79_PLOJA","Z79_REFERE","Z79_MOEDA","Z79_TIPOCT","Z79_VLREXT","Z79_VLDIPJ","Z79_VLRANO","Z79_VLRIMP","Z79_ADVOGA","Z79_VALOR","Z79_DESCON","Z79_VLRTOT","Z79_DESPER","Z79_DESCON","Z79_VLRTOT","Z79_MOTALT","Z79_MOTIVO","Z79_DREEMB","Z79_IDIOMA","Z79_VLDPFI","Z79_TIMEUS"}
		nOpc2:=4
	Case xParam3 == 8
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z79_APROVA","Z79_NOMEAP"}
		aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 9
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {}
		aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 10
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z79_OBSREC"}
		//aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 11
		//DELETA := .T.
		ALTERA := .T.
		aAlterEnch	:= {"Z79_OBSREC","Z79_MOTREC"}
		aAltCobEn	:= {}
		nOpc2:=4
	Case xParam3 == 13
		VISUAL := .T.     
		nOpc2:=2
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
	aTFolder := { 'Cadastro','Pagamentos','Histórico Posicionamento','Follow Up','Dados Cobrança'}
	oTFolder := TFolder():New( 2,2,aTFolder,,oDlg,,,,.T.,,623,300 )
	//------>>>> Fim do criar folder

	// <-> FOLDER 1
	//Carrega as variáveris da tabela Z79
	RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .T.)
    
    //Tratamento para Draft, preenchendo a capa da proposta com as informações do draft
	if xParam3==12
		RegToMemory("Z74",.F.,.T.)
		
		For d:=1 to len(aCpoDra)-1
			if alltrim(aCpoDra[d])<>"Z79_NUM"
				&(Z79->(aCpoDra[d])):=&(Z74->(aZ74Ench[d]))
			endif
		Next
		
		M->Z79_DRAFT:= Z74->Z74_NUM

		For d:=1 to len(aCpoEnCob)-1
			&(Z79->(aCpoEnCob[d])):=&(Z74->(aZ74EnCob[d]))
		Next

    endif
    
    cRev	:=M->Z79_REVISA
	if nOpc==6 .OR. nOpc==4
		//Tratamento para não deixar revisar/alterar um contrato revisado
		if Z79->Z79_STATUS $ '2' //'2/A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Revisado'")
			Return()
		endif
		//Tratamento para não deixar alterar um contrato recusado GT
		if nOpc==4 .AND. Z79->Z79_STATUS $ '4'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Recusado GT'")
			Return()		
		endif       

		if nOpc==6 //Revisar
			M->Z79_REVISA:=SOMA1(M->Z79_REVISA)
		endif
	endif

	//Tratamento para não deixar alterar/enviar para aprovação GT propostas recusadas ou aprovadas
	//if nOpc==4 .OR. nOpc==5 .OR. nOpc==8
	if nOpc==5 .OR. nOpc==8
		if Z79->Z79_STATUS $ '5/8/9'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Aprovado'")
			Return()
		elseif Z79->Z79_STATUS $ '4/7'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Recusado'")
			Return()
		//Tratamento para não deixar revisar um contrato revisado
		elseif Z79->Z79_STATUS $ '2' //'2/A'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Revisado'")
			Return()
		endif
	endif
	
	//Tratamento para não deixar Revisar/Alterar/Enviar p aprovação GT propostas aprovadas	
	//if nOpc==6 .OR. nOpc==4 .OR. nOpc==8
	if nOpc==6 .OR. nOpc==8
		if Z79->Z79_STATUS $ '5/8/9'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Aprovado'")
			Return()
		elseif Z79->Z79_STATUS $ '6'
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Pendente Aprovação Cliente'")
			Return()
		endif
	endif
	
	//Tratamento para não deixar manipular proposta que está em aprovação da GT
	if nOpc<>3 .AND. nOpc<>2 //diferente de incluir e visualizar
		if Z79->Z79_STATUS $ '3' //Pendente Aprovação GT
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta com status 'Pendente Aprovação GT'")
			Return()
		endif
	endif

	//Tratamento para não deixar Env. P/ Cliente propostas que não estão aprovadas GT
	if nOpc==9
		if !(Z79->Z79_STATUS $ '5')
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Aprovado GT'")
			Return()
		endif
	endif

	//Tratamento para não deixar Env. P/ Cliente propostas que não estão aprovadas GT
	if nOpc==10 .OR. nOpc==11
		if !(Z79->Z79_STATUS $ '6')
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Pendente Aprovação Cliente'")
			Return()
		endif
	endif
	//Tratamento para não deixar exluir proposta que não esteja em aberto

	if nOpc==13
		if ! (empty(Z79->Z79_STATUS) .OR. (Z79->Z79_STATUS $ '1'))
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta que não possui status 'Em aberto'")
			Return()
		elseif (empty(Z79->Z79_STATUS) .OR. (Z79->Z79_STATUS $ '1')) .AND. alltrim(M->Z79_REVISA)<>"000"
			ACTIVATE MSDIALOG oDlg ON INIT oDlg:end()
			Alert("Opção não disponível para proposta derivada de revisão")
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

		if nOpc<>3 //.AND. nOpc<>6  // Se não for incluir ou revisar, preencho as informações da barrinha
			aItensZ70U	:= GarregaZ70(nOpc,1,Z79->Z79_NUM,M->Z79_REVISA)
			if !empty(aItensZ70U)
				cTexto		:= aItensZ70U[1][3]
				cMemo		:= aItensZ70U[1][5]
				oSlider:SetValue(val(aItensZ70U[1][3]))
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
		if nOpc==4 .AND. (M->Z79_STATUS $ '3/5/6/7/8/9') //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
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

	
	//Carrega as variáveis no aCols de acordo com a opção selecionada       
	If nOpc == 3 .AND. xParam3<>12
		AADD(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			if Alltrim(aHeader[nI,2]) == "Z78_ITEM"
				aCols[len(aCols)][nI] := "01"
			else
				aCols[len(aCols)][nI] := CriaVar(aHeader[nI][2])
			endif
		Next
		aCols[len(aCols)][nUsado+1] := .F.
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

		endif		

	EndIf                            
	
	if nOpc==5
	
		aColsAux:=aCols
		nPosSta:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_STATUS"})
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

		oGetDados:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
		                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[1],aHeader,aCols)

	    oGetDados :ForceRefresh()              
	    
	    if nOpc<>3 .AND. nOpc<>4 .AND. nOpc<>6
		    oGetDados:Disable()
	    endif
	    
	    //Para permitir somente manipular a barra de status da proposta 
	    /*if nOpc<>4 .AND. (M->Z79_STATUS $ '3/5/6/7/8/9')   //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
			oGetDados:Disable()
	    endif
	    */
	endif
	
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	// <-> FIM FOLDER 1
	
	
	// <-> FOLDER 3
    
        //if nOpc <> 6
			aItensZ70:=GarregaZ70(nOpc,2,Z79->Z79_NUM,M->Z79_REVISA)
		//endif
		//@ nSuperior,nEsquerda LISTBOX oQual VAR cVarQ Fields HEADER "","Item","Departamento","Descrição","Area","Descrição","Servico","Descrição","Volume" SIZE;
		//420,90 ON DBLCLICK (aColsAux:=Troca(oQual:nAt,aColsAux),oQual:Refresh()) NoScroll OF oTFolder:aDialogs[1] PIXEL
		@ aLbxCooFo2[1],aLbxCooFo2[2] LISTBOX oQual VAR cVarQ Fields HEADER "Data","Hora","Porcetagem","Usuário","Descrição" SIZE;
		aLbxCooFo2[3],aLbxCooFo2[4] OF oTFolder:aDialogs[3] PIXEL
		
		if !empty(aItensZ70)
			oQual:SetArray(aItensZ70)
			
			oQual:bLine := { || {aItensZ70[oQual:nAt,1],aItensZ70[oQual:nAt,2],aItensZ70[oQual:nAt,3],aItensZ70[oQual:nAt,4],aItensZ70[oQual:nAt,5]}}
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
		                           //Z79_VALOR
			cValG3_1_1:= Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99')
			cValG3_1_2:= ""
			cValG3_1_4:= SPACE(3)
			cValG3_1_6:= CTOD("//")//cValG3_1_6:= SPACE(2)
            
			if xParam3==12 //Se for inclusão de através de informações de draft
				cNum:=M->Z74_NUM
				cRev:=M->Z74_REVISA			
			else
				cNum:=M->Z79_NUM
				cRev:=M->Z79_REVISA
            endif

			//Carregando itens da tabela Z69 --pagamentos
			aAcolVlrAx:=GarregaZ69(nOpc,cNum,cRev,"PROPOSTA",xParam3)

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
				cValG3_1_1	:= Transform(M->Z79_VLRTOT+(iif(aAcolVlrAx[1][6]=="S",M->Z79_VLDIPJ,0))+(iif(aAcolVlrAx[1][7]=="S",M->Z79_VLRANO,0)),'@E 99,999,999,999.99') //Adiciona o valor de DIPJ ou Anual caso seja sim nas opções
			                            //Z79_VALOR
			endif
			
			
			oSayG3_1_1		:= tSay():New(aPosObjFo1[1]+15,aPosObjFo1[2]+10, {||'Valor da Proposta: ' +alltrim(cValG3_1_1)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oSayG3_1_2		:= tSay():New(aPosObjFo1[1]+15,aPosObjFo1[2]+110,{||'Valor das Parcelas: '+alltrim(cValG3_1_2)},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			
			oSayG3_1_3		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+10, {||'Parcelas: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                               //Z79_VALOR
			@aPosObjFo1[1]+25,aPosObjFo1[2]+40	MSGET oSayG3_1_4 VAR cValG3_1_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO1(oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,,,cValG3_1_6))
	
			//oSayG3_1_5		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+110, {||'Dia Vencto: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			//@aPosObjFo1[1]+25,aPosObjFo1[2]+140	MSGET oSayG3_1_6 VAR cValG3_1_6 PICTURE "99" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cValG3_1_6,oGetDdsVlr,aHeadVlr))
			oSayG3_1_5		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo1[1]+25,aPosObjFo1[2]+140	MSGET oSayG3_1_6 VAR cValG3_1_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,cValG3_1_6))
/*			
			oSayG3_1_7		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+180, {||'Incluir DIPJ: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                                 //Z79_VALOR
			oCombo_1_7		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+210,{|u|if(PCount()>0,cCombo_1_7:=u,cCombo_1_7)},aCombo_1_7,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr)},,,,.T.,,,,,,,,,'cCombo_1_7')
	
			oSayG3_1_8		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+250, {||'Incluir Anuid: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                               //Z79_VALOR
			oCombo_1_8		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+285,{|u|if(PCount()>0,cCombo_1_8:=u,cCombo_1_8)},aCombo_1_8,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cValG3_1_6,oGetDdsVlr,aHeadVlr)},,,,.T.,,,,,,,,,'cCombo_1_8')
*/
			if lUsaVlrDip
				oSayG3_1_7		:= tSay():New(aPosObjFo1[1]+14,aPosObjFo1[2]+200, {||'Incluir DIPJ: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                                 //Z79_VALOR
				oCombo_1_7		:= tComboBox():New(aPosObjFo1[1]+13,aPosObjFo1[2]+235,{|u|if(PCount()>0,cCombo_1_7:=u,cCombo_1_7)},aCombo_1_7,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,cValG3_1_6)},,,,.T.,,,,,,,,,'cCombo_1_7')
	        endif
	        if lUsaVlrAno
				oSayG3_1_8		:= tSay():New(aPosObjFo1[1]+27,aPosObjFo1[2]+200, {||'Incluir Anuid: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)                                                                               //Z79_VALOR
				oCombo_1_8		:= tComboBox():New(aPosObjFo1[1]+25,aPosObjFo1[2]+235,{|u|if(PCount()>0,cCombo_1_8:=u,cCombo_1_8)},aCombo_1_8,30,20,oTFolder:aDialogs[2],,{||AddDipjAnual(cCombo_1_7,cCombo_1_8,oGetDdsVlr,cValG3_1_4,Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99'),@oSayG3_1_1,@cValG3_1_1,@cValG3_1_2,oSayG3_1_2,cvaltochar(DAY(cValG3_1_6)),oGetDdsVlr,aHeadVlr,cValG3_1_6)},,,,.T.,,,,,,,,,'cCombo_1_8')
			endif
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsVlr:= MsNewGetDados():New(aPosObjFo1[1]+47,aPosObjFo1[2]+10,aPosObjFo1[3]-10,aPosObjFo1[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterVlr,000,val(cValG3_1_4),"U_I_FG40O1","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
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
		
			cValG3_2_1:= Transform(M->Z79_VLRIMP,'@E 99,999,999,999.99')
			cValG3_2_2:= ""
			cValG3_2_4:= SPACE(3)
			cValG3_2_6:= CTOD("//")

			//Carregando itens da tabela Z69 --pagamentos
			aAcolImpAx:=GarregaZ69(nOpc,cNum,cRev,"IMPLANTACAO",xParam3)

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
			@aPosObjFo2[1]+25,aPosObjFo2[2]+40	MSGET oSayG3_2_4 VAR cValG3_2_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO2(oGetDdsImp,cValG3_2_4,Transform(M->Z79_VLRIMP,'@E 99,999,999,999.99'),@oSayG3_2_1,@cValG3_2_1,@cValG3_2_2,oSayG3_2_2,cvaltochar(DAY(cValG3_2_6)),oGetDdsImp,aHeadImp,cValG3_2_6))
	
			oSayG3_2_5		:= tSay():New(aPosObjFo2[1]+27,aPosObjFo2[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo2[1]+25,aPosObjFo2[2]+140	MSGET oSayG3_2_6 VAR cValG3_2_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_2_6)),oGetDdsImp,aHeadImp,cValG3_2_6))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsImp:= MsNewGetDados():New(aPosObjFo2[1]+47,aPosObjFo2[2]+10,aPosObjFo2[3]-10,aPosObjFo2[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterImp,000,val(cValG3_2_4),"U_I_FG40O2","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadImp,aAcolImp)
			
			
		//----------Fim Segundo quadro - Valor da implantação
		endif

		if lUsaVlrDip	                                                 
		//----------Terceiro quadro - Valor de DIPJ
		
			cValG3_3_1:= Transform(M->Z79_VLDIPJ,'@E 99,999,999,999.99')
			cValG3_3_2:= ""
			cValG3_3_4:= SPACE(3)
			cValG3_3_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z69 --pagamentos
			aAcolDipAx:=GarregaZ69(nOpc,cNum,cRev,"DIPJ",xParam3)

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
			@aPosObjFo3[1]+25,aPosObjFo3[2]+40	MSGET oSayG3_3_4 VAR cValG3_3_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO3(oGetDdsDip,cValG3_3_4,Transform(M->Z79_VLDIPJ,'@E 99,999,999,999.99'),@oSayG3_3_1,@cValG3_3_1,@cValG3_3_2,oSayG3_3_2,cvaltochar(DAY(cValG3_3_6)),oGetDdsDip,aHeadDip,cValG3_3_6))
	
			oSayG3_3_5		:= tSay():New(aPosObjFo3[1]+27,aPosObjFo3[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo3[1]+25,aPosObjFo3[2]+140	MSGET oSayG3_3_6 VAR cValG3_3_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_3_6)),oGetDdsDip,aHeadDip,cValG3_3_6))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsDip:= MsNewGetDados():New(aPosObjFo3[1]+47,aPosObjFo3[2]+10,aPosObjFo3[3]-10,aPosObjFo3[4]-10,3,"AllwaysTrue","AllwaysTrue","AllwaysTrue",;
	                             aAlterDip,000,val(cValG3_3_4),"U_I_FG40O3","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadDip,aAcolDip)
			
			
		//----------Fim Terceiro quadro - Valor de DIPJ
        endif        
        
        if lUsaVlrAno
		//----------Quarto quadro - Valor Anual
		
			cValG3_4_1:= Transform(M->Z79_VLRANO,'@E 99,999,999,999.99')
			cValG3_4_2:= ""
			cValG3_4_4:= SPACE(3)
			cValG3_4_6:= CTOD("//")//SPACE(2)

			//Carregando itens da tabela Z69 --pagamentos
			aAcolAnoAx:=GarregaZ69(nOpc,cNum,cRev,"ANUAL",xParam3)

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
			@aPosObjFo4[1]+25,aPosObjFo4[2]+40	MSGET oSayG3_4_4 VAR cValG3_4_4 PICTURE "999" SIZE 15,8 OF oTFolder:aDialogs[2] PIXEL VALID(LoadPaO4(oGetDdsAno,cValG3_4_4,Transform(M->Z79_VLRANO,'@E 99,999,999,999.99'),@oSayG3_4_1,@cValG3_4_1,@cValG3_4_2,oSayG3_4_2,cvaltochar(DAY(cValG3_4_6)),oGetDdsAno,aHeadAno,cValG3_4_6))
	
			oSayG3_4_5		:= tSay():New(aPosObjFo4[1]+27,aPosObjFo4[2]+110, {||'Dt Inicial: '},oTFolder:aDialogs[2],,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			@aPosObjFo4[1]+25,aPosObjFo4[2]+140	MSGET oSayG3_4_6 VAR cValG3_4_6 SIZE 40,8 OF oTFolder:aDialogs[2] PIXEL VALID(CarregaDia(cvaltochar(DAY(cValG3_4_6)),oGetDdsAno,aHeadAno,cValG3_4_6))
			        
			
			//oGetDdsVlr:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	        //                     aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oTFolder:aDialogs[2],aHeadVlr,aAcolVlr)
			
			oGetDdsAno:= MsNewGetDados():New(aPosObjFo4[1]+47,aPosObjFo4[2]+10,aPosObjFo4[3]-10,aPosObjFo4[4]-10,3,"AllwaysTrue","AllwaysTrue","",;
	                             aAlterAno,000,val(cValG3_4_4),"U_I_FG40O4","AllwaysTrue","AllwaysFalse",oTFolder:aDialogs[2],aHeadAno,aAcolAno)
			
			
		//----------Fim Quarto quadro - Valor Anual
		endif	
			
	// <-> FIM FOLDER 2

	// <-> FOLDER 4

		RegToMemory("Z68",If(nOpc == 3,.T.,.F.), .T.)
	
		//Montagem do browse para manipulação dos follow ups
		FormBrwTable(nOpc)

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

	
	//Se não for incluir nem revisar
	if nOpc<>3 .AND. nOpc<>6
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
	if nOpc==4 .AND. M->Z79_STATUS $ '3/5/6/7/8/9' //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
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
  
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| ;
iif(Grava(aHeader,IIF(nOpc==5,aColsAux,oGetDados:aCols),aCpoEnch,aCpoEnCob,nOpc,aAlterEnch,aAltCobEn,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno;
,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6),oDlg:End(),);
},{||oDlg:End()},,aButtons);
,iif(nOpc==10,iif(MsgYesNo("Deseja adicionar proposta assinada?"),AnexoP00(nOpc,@cItemZ67),),) )CENTERED //Tratamento para verificar se o usuário quer anexar a proposta assinada, quando está aprovando cliente

Return(.T.)

/*
Funcao      : Grava()  
Parametros  : Header,aCols,cAno,nOpc,aAlterEnch
Retorno     : .T. ou .F.
Objetivos   : Função para gravação/alteração/Aprovação
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Static Function Grava(aHeader,aCols,aCpoEnch,aCpoEnCob,nOpc,aAlterEnch,aAltCobEn,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Local nPosVal	:= 0
Local cNum		:= ""
Local cRev		:= ""
Local nPosGetDad:= 0
Local cTipoZ67	:= ""
Local cTo		:= ""

if nOpc==3 //Incluir

	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif

    /*Valida se o valor é diferente de 0(zero)*/
			
    if empty(M->Z79_VALOR) .OR. empty(M->Z79_VLRTOT)
		Alert("Campo valor deve ser preenchido!")
   		Return .F.
    endif
    
    /*Valida se o campo cliente ou prospect estão preenchidos*/
    if empty(M->Z79_CLIENT) .AND. empty(M->Z79_PROSPE)
		Alert("Deve ser informado um cliente ou um prospect!")
   		Return .F.
    endif

    /*Valida se o campo responsável deve ser preenchido*/
	cQry:=" SELECT * FROM "+RETSQLNAME("Z65")+" Z65"
	cQry+=" JOIN "+RETSQLNAME("Z66")+" Z66 ON Z66_IDUSER=Z65_IDUSER AND Z66_FILIAL=Z65_FILIAL "
	cQry+=" WHERE Z65.D_E_L_E_T_='' AND Z66.D_E_L_E_T_='' AND Z65_IDDEPE='' "
	cQry+=" AND Z66_LRESPO='T'
    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
        
	if nRecCount >0
	    if empty(M->Z79_RESPON)
			Alert("Deve ser informado o responsável!")
	   		Return .F.
	    endif
    endif
    
	/*Validação do preenchimento da GetDados*/
	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_DEPART"})
	nPosGetAre:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_AREA"})
	nPosGetSer:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_SERVIC"})
	nPosGetVol:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_VOLUME"})
    
    if empty(aCols)
		Alert("Verifique se existe serviço preenchido!")
    	Return .F.
	endif
	
 	for h:=1 to len(aCols)

    	if nPosGetDep>0
    		if empty(aCols[h][nPosGetDep])
	    		Alert("Existe linha com Departamento não preenchido!")
	    		Return .F.
				Exit
			endif
		endif         
		
    	if nPosGetAre>0
    		if empty(aCols[h][nPosGetAre])
	    		Alert("Existe linha com Area não preenchida!")
	    		Return .F.
				Exit
			endif
		endif

    	if nPosGetSer>0
    		if empty(aCols[h][nPosGetSer])
	    		Alert("Existe linha com Serviço não preenchido!")
	    		Return .F.
				Exit
			endif

		endif
		    
    	if nPosGetVol>0
    		//Desenvolvendo aqui §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
			aCbox:={}
			
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek("Z79_TPCTR"))
			
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
    			if alltrim(aCbox[Ascan(aCbox,{|x| UPPER(alltrim(x[2])) = "ESPECIAL"})][1])!=alltrim(M->Z79_TPCTR)

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

    next

	nPosNum		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_NUM"})
	nPosVlrIni	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_VLRINI"})
	nPosValor	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_VALOR"})
	
	//Se buscar de draft irá preencher o número da proposta com o número do draft
 	//if Empty(M->Z79_DRAFT) 
	
	if cEmpAnt $ "CH" //Technology não grava sequência, deve ser informado
		cNum:=M->&(aCpoEnch[nPosNum])
	else
		cNum:=ProxNum(M->Z79_TPCTR)
	endif
	//else
	//	cNum:=M->Z79_DRAFT
	//endif		
	
	BEGIN TRANSACTION	
		//Gravando ENCHOICE principal
		RecLock("Z79",iif(nOpc==3,.T.,.F.)) 
			Z79->Z79_FILIAL	:= xFilial("Z79")
			Z79->Z79_FILORI	:= cFilAnt
			for nx:=1 to len(aCpoEnch)-1
	    		if nx==nPosNum
					Z79->&(aCpoEnch[nx]) := cNum
	    		elseif nx==nPosVlrIni
	    			Z79->&(aCpoEnch[nx]) := M->&(aCpoEnch[nPosValor])
	    		else
	    			Z79->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
	    		endif
			next 
			Z79->Z79_DTINC	:= ddatabase	
			Z79->Z79_USERRE	:= __cUserID	//Usuário responsável
			Z79->Z79_USERNO	:= UsrFullName(__cUserID)
			Z79->Z79_TPVLR	:= "1"	//Pois foi retirado o campo valor c/ impostos  
			

			//Gravando os dados da aba de pagamentos
			for ny:=1 to len(aCpoEnCob)-1
				Z79->&(aCpoEnCob[ny]) := M->&(aCpoEnCob[ny])
			next
			
			
	    Z79->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
			for i:=1 to len(aCols)
		    	RecLock("Z78",.T.)
		    		Z78->Z78_FILIAL	:= xFilial("Z78")
   					Z78->Z78_FILORI	:= cFilAnt
		    		Z78->Z78_NUM	:= cNum
		    		Z78->Z78_REVISA	:= M->Z79_REVISA
		    		for j:=1 to len(aHeader)
		    			Z78->&(aHeader[j][2]):=aCols[i][j]
		    		next
		    	MsUnlock()
		    next
		//GRAVANDO TABELA DE SEQUENCIA DE NUMERACAO
			DbSelectArea("Z77")
			DbSetOrder(1)
			if !DbSeek(xFilial("Z77")+cNum)
				RecLock("Z77",.T.) 
					Z77->Z77_FILIAL	:=xFilial("Z77")
					Z77->Z77_NUM := cNum
			    Z77->(MSUNLOCK())
			endif

	END TRANSACTION
	
	/*Atualiza o Status da tabela de draft*/
	if !Empty(M->Z79_DRAFT)
		DbSelectArea("Z74")
		DbSetOrder(1)
		if DbSeek(xFilial("Z74")+M->Z79_TPCTR+M->Z79_DRAFT)
			RecLock("Z74",.F.)
				Z74->Z74_STATUS:='3' //Em proposta
			Z74->(MsUnlock())
		else
			MsgInfo("Não foi possível atualizar o status do draft!")
		endif
	endif
	/*Fim Atualiza o Status da tabela de draft*/
    
	/*Atualiza o status de conflito da tabela de prospect*/
	if !empty(M->Z79_PROSPE) .AND. !empty(M->Z79_PLOJA) .AND. empty(M->Z79_CLIENT) .AND. empty(M->Z79_LOJA)
		DbSelectArea("SUS")
		DbSetOrder(1)
		if DbSeek(xFilial("SUS")+M->Z79_PROSPE+M->Z79_PLOJA) //Se encontrou na tabela SUS
			if empty(SUS->US_CODCLI)
				RecLock("SUS",.F.)
					SUS->US_P_CONFL:='1' //Sim
				SUS->(MsUnlock())
			endif
		endif
	endif	
	/*Fim Atualiza o status de conflito da tabela de prospect*/
	
	//Gravação da tabela Z70 - Posicionamento
	GravaZ70(nOpc)
    
	//Gravação da tabela Z69 - Pagamentos	
	GravaZ69(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)
	
	//RRP - 05/06/2013 - Chama a função para gravar a Classe de Valor
	if !(cEmpAnt $ "CH") //Technology não grava sequência, deve ser informado
		GrvClVl(cNum)
	endif
	
	MsgInfo("Foi gerada a proposta: "+cNum)
    
elseif nOpc==4 //Alterar

	cNum:=M->Z79_NUM
	cRev:=M->Z79_REVISA

	/*Verifica se nenhum está marcado, e o campo Z79_MOTIVO está preenchido*/
	if empty(M->Z79_MOTALT)
		Alert("Campo motivo de alteração deve ser preenchido!")
		Return(.F.)		
	endif

	/*Verifica se o campo memo está preenchido*/
	if empty(alltrim(cMemo))
		Alert("Campo descrição do posicionamento deve ser preenchido!")
		Return(.F.)		    
	endif
	
	//Gravando ENCHOICE
	RecLock("Z79",iif(nOpc==3,.T.,.F.)) 
		for nx:=1 to len(aAlterEnch)
    		Z79->&(aAlterEnch[nx]) := M->&(aAlterEnch[nx])
    	next
        //Gravando os dados da aba de dados de cobrança
		for ny:=1 to len(aAltCobEn)
    		Z79->&(aAltCobEn[ny]) := M->&(aAltCobEn[ny])
    	next
    	
    Z79->(MSUNLOCK())

    //Se já existir algo preenchido.
    if !empty(aItensZ70U)

	    //Verificando se a barra foi movimentada, e se a descrição foi alterada, para que possa ser salvo.
	    if alltrim(cTexto)<>alltrim(aItensZ70U[1][3]) .OR. alltrim(cMemo)<>alltrim(aItensZ70U[1][5])
		   	//Gravação da tabela Z70 -- Posicionamento
			GravaZ70(nOpc)
	    endif
    else
	   	//Gravação da tabela Z70 -- Posicionamento
		GravaZ70(nOpc)    
	endif

	//Gravação da tabela Z69 - Pagamentos
	GravaZ69(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)


	if M->Z79_STATUS $ '8' //Alterando proposta aprovada sem assinatura do cliente
		//Gravando ENCHOICE
		//Tratamento para verificar se a proposta assinada foi anexada
		DbSelectArea("Z67")
		Z67->(DbSetOrder(1))
		if DbSeek(xFilial("Z67")+M->Z79_NUM+M->Z79_REVISA+cItemZ67)
			cTipoZ67:=Z67->Z67_TIPO
		endif
		
		RecLock("Z79",.F.) 
			if Alltrim(UPPER(cTipoZ67))<>"P"
				Z79->Z79_STATUS:= "8"
	        else
				Z79->Z79_STATUS:= "9"
			endif
	    Z79->(MSUNLOCK())  		
	endif
	
elseif nOpc==5 //Aprovar
    //Gravando a aprovação
	Private lApro:=.F.
	Private lRecu:=.F.
	
	DbSelectArea("Z78")
	Z78->(DbSetOrder(1))
	
	for k:=1 to len(aCols)
		if DbSeek(M->Z79_FILIAL+M->Z79_NUM+aCols[k][2]+aCols[k][3])
			RecLock("Z78",.F.)
				if aCols[k][1]
					Z78->Z78_STATUS:="2" 
					lApro:=.T.
				else
					Z78->Z78_STATUS:="3"
					lRecu:=.T.
				endif
			MsUnlock()
		endif
	next
	
	/*Verifica se nenhum está marcado, e o campo Z79_MOTIVO está preenchido*/
	if !lApro .AND. lRecu .AND. empty(M->Z79_MOTIVO)
		Alert("Campo motivo deve ser preenchido!")
		Return(.F.)		
	endif
	//Grava o motivo na tabela
	if !empty(M->Z79_MOTIVO)
		RecLock("Z79",.F.)
			Z79->Z79_MOTIVO:=M->Z79_MOTIVO
		MsUnLock()
	endif

	/*Se for aprovar um draft com prospect, torna o prospect cliente e grava na proposta o código do cliente gerado*/
	if lApro    
	    //Verifica se o prospect esta preenchido e o cliente não
		if !empty(Z79->Z79_PROSPE) .AND. !empty(Z79->Z79_PLOJA) .AND. empty(Z79->Z79_CLIENT) .AND. empty(Z79->Z79_LOJA)

			DbSelectArea("SUS")
			DbSetOrder(1)
			if DbSeek(xFilial("SUS")+Z79->Z79_PROSPE+Z79->Z79_PLOJA) //Se encontrou na tabela SUS
				if !empty(SUS->US_CODCLI)
					RecLock("Z79",.F.)
						Z79->Z79_CLIENT	:= SUS->US_CODCLI
						Z79->Z79_LOJA	:= SUS->US_LOJACLI
						Z79->Z79_NOME	:= SUS->US_NOME
					MsUnLock()
                else
					if U_GTP2C(Z79->Z79_PROSPE,Z79->Z79_PLOJA) //Se Virou cliente
						DbSelectArea("SUS")
						DbSetOrder(1)
						if DbSeek(xFilial("SUS")+Z79->Z79_PROSPE+Z79->Z79_PLOJA) //Se encontrou na tabela SUS
						    //Grava o cliente e a loja na tabela de proposta
							RecLock("Z79",.F.)
								Z79->Z79_CLIENT	:= SUS->US_CODCLI
								Z79->Z79_LOJA	:= SUS->US_LOJACLI
								Z79->Z79_NOME	:= SUS->US_NOME
							MsUnLock()				
						endif
					else
						Alert("Não foi possível tornar o prospect em cliente!")
						Return(.F.)
					endif
				 endif
			else
				Alert("Prospect não encontrado!")
				Return(.F.)			
			endif
		endif	
	endif
	/*FIM Se for aprovar um draft com prospect, torna o prospect cliente e grava na proposta o código do cliente gerado*/
	
	/*Se for recusar um draft com prospect, grava o cliente caso o prospect já tenha sido convertido*/
	if lRecu
	    //Verifica se o prospect esta preenchido e o cliente não
		if !empty(Z79->Z79_PROSPE) .AND. !empty(Z79->Z79_PLOJA) .AND. empty(Z79->Z79_CLIENT) .AND. empty(Z79->Z79_LOJA)

			DbSelectArea("SUS")
			DbSetOrder(1)
			if DbSeek(xFilial("SUS")+Z79->Z79_PROSPE+Z79->Z79_PLOJA) //Se encontrou na tabela SUS
				if !empty(SUS->US_CODCLI)
					RecLock("Z79",.F.)
						Z79->Z79_CLIENT	:= SUS->US_CODCLI
						Z79->Z79_LOJA	:= SUS->US_LOJACLI
						Z79->Z79_NOME	:= SUS->US_NOME
					MsUnLock()
				endif
			endif
	     endif
	endif
	/*Fim Se for recusar um draft com prospect, grava o cliente caso o prospect já tenha sido convertido*/

	/*Atualiza o status da capa das Propostas*/
	if lApro .AND. !lRecu
		RecLock("Z79",.F.)
			Z79->Z79_STATUS:="5"
			Z79->Z79_DTAPRO:=ddatabase
		MsUnLock()
	elseif lApro .AND. lRecu
		RecLock("Z79",.F.)
			Z79->Z79_STATUS:="3"
			Z79->Z79_DTAPRO:=ddatabase
		MsUnLock()
	elseif !lApro .AND. lRecu
		RecLock("Z79",.F.)
			Z79->Z79_STATUS:="4"
			Z79->Z79_DTRECU:=ddatabase
		MsUnLock()
	endif
	/*Fim do Atualiza o status da capa das Propostas*/
		
	/*Atualiza o Status da tabela de draft
	if !Empty(M->Z79_DRAFT)
		DbSelectArea("Z74")
		DbSetOrder(1)
		if DbSeek(xFilial("Z74")+M->Z79_TPCTR+M->Z79_DRAFT)
			RecLock("Z74",.F.)
				Z74->Z74_STATUS:='2' //Aprovado
			Z74->(MsUnlock())
		else
			MsgInfo("Não foi possível atualizar o status do draft!")
		endif
	endif
	Fim Atualiza o Status da tabela de draft*/

elseif nOpc==6 //Revisar

	/*Valida o cabecalho*/
	if !Obrigatorio(aGets,aTela) 
		Return .F.
	endif

    /*Valida se o valor é diferente de 0(zero)*/
    if empty(M->Z79_VALOR) .OR. empty(M->Z79_VLRTOT)
		Alert("Campo valor deve ser preenchido!")
   		Return .F.
    endif
    
    /*Valida se o campo cliente ou prospect estão preenchidos*/
    if empty(M->Z79_CLIENT) .AND. empty(M->Z79_PROSPE)
		Alert("Deve ser informado um cliente ou um prospect!")
   		Return .F.
    endif
    
	/*Validação do preenchimento da GetDados*/
	nPosGetDep:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_DEPART"})
	nPosGetAre:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_AREA"})
	nPosGetSer:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_SERVIC"})
	nPosGetVol:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_VOLUME"})
    
    if empty(aCols)
		Alert("Verifique se existe serviço preenchido!")
    	Return .F.
	endif

 	for h:=1 to len(aCols)

    	if nPosGetDep>0
    		if empty(aCols[h][nPosGetDep])
	    		Alert("Existe linha com Departamento não preenchido!")
	    		Return .F.
				Exit
			endif
		endif
    	if nPosGetAre>0
    		if empty(aCols[h][nPosGetAre])
	    		Alert("Existe linha com Area não preenchida!")
	    		Return .F.
				Exit
			endif
		endif
    	if nPosGetSer>0
    		if empty(aCols[h][nPosGetSer])
	    		Alert("Existe linha com Serviço não preenchido!")
	    		Return .F.
				Exit
			endif
    	endif
    	if nPosGetVol>0
    		if empty(aCols[h][nPosGetVol])
	    		Alert("Existe linha com Volume não informado!")
	    		Return .F.
				Exit
			endif
    	endif

    next

	nPosNum		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_NUM"})
	nPosRev		:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_REVISA"})
	nPosVlrIni	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_VLRINI"})
	nPosValor	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_VALOR"})
	nPosStatu	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_STATUS"})	
	nPosMotCan	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_MOTREC"})
	nPosObsGt	:= Ascan(aCpoEnch,{|x| alltrim(x) = "Z79_OBSGT"})
	
/*	//Se buscar de draft irá preencher o número da proposta com o número do draft
 	if Empty(M->Z79_DRAFT) 
		cNum:=ProxNum(M->Z79_TPCTR)
	else
		cNum:=M->Z79_DRAFT
	endif		
*/	
    
	cNum:=M->Z79_NUM
	cRev:=M->Z79_REVISA

	BEGIN TRANSACTION	
		
		//Gravando Status Proposta antiga
		/*if alltrim(M->Z79_STATUS)=="4"
			RecLock("Z79",.F.) 
				Z79->Z79_STATUS:='A'
		    Z79->(MSUNLOCK())
		else
			RecLock("Z79",.F.) 
				Z79->Z79_STATUS:='2'
		    Z79->(MSUNLOCK())
		endif
		*/
		RecLock("Z79",.F.) 
			Z79->Z79_STATUS:='2'
	    Z79->(MSUNLOCK())
		    		
		//Gravando ENCHOICE
		RecLock("Z79",.T.) 
			Z79->Z79_FILIAL	:=xFilial("Z79")
			Z79->Z79_FILORI	:= cFilAnt
			for nx:=1 to len(aCpoEnch)-1
	    		if nx==nPosNum
					Z79->&(aCpoEnch[nx]) := cNum
	    		elseif nx==nPosRev
	    			Z79->&(aCpoEnch[nx]) := cRev
	    		elseif nx==nPosVlrIni
	    			Z79->&(aCpoEnch[nx]) := M->&(aCpoEnch[nPosValor])
	    		elseif nx==nPosStatu
		    		Z79->&(aCpoEnch[nx]) := "1"
	    		elseif nx==nPosObsGt
		    		Z79->&(aCpoEnch[nx]) := ""
	    		elseif nx==nPosMotCan
		    		Z79->&(aCpoEnch[nx]) := ""
	    		else
	    			Z79->&(aCpoEnch[nx]) := M->&(aCpoEnch[nx])
	    		endif
			next 
			Z79->Z79_DTINC:=ddatabase
			
			//Gravando os dados da aba de dados de cobranca
			for ny:=1 to len(aCpoEnCob)-1
				Z79->&(aCpoEnCob[ny]) := M->&(aCpoEnCob[ny])
			next
			
	    Z79->(MSUNLOCK())
	    
	    //GRAVANDO GETDADOS
			for i:=1 to len(aCols)
		    	RecLock("Z78",.T.)
		    		Z78->Z78_FILIAL	:= xFilial("Z78")
   					Z78->Z78_FILORI	:= cFilAnt
		    		Z78->Z78_NUM	:= cNum
		    		Z78->Z78_REVISA	:= cRev
		    		for j:=1 to len(aHeader)
		    			Z78->&(aHeader[j][2]):=aCols[i][j]
		    		next
		    	MsUnlock()
		    next

	END TRANSACTION
    
	/*Atualiza o status de conflito da tabela de prospect*/
	if !empty(M->Z79_PROSPE) .AND. !empty(M->Z79_PLOJA) .AND. empty(M->Z79_CLIENT) .AND. empty(M->Z79_LOJA)
		DbSelectArea("SUS")
		DbSetOrder(1)
		if DbSeek(xFilial("SUS")+M->Z79_PROSPE+M->Z79_PLOJA) //Se encontrou na tabela SUS
			if empty(SUS->US_CODCLI)
				RecLock("SUS",.F.)
					SUS->US_P_CONFL:='1' //Sim
				SUS->(MsUnlock())
			endif
		endif
	endif	
	/*Fim Atualiza o status de conflito da tabela de prospect*/
	
	//Gravação da tabela Z70 - Posicionamento
	GravaZ70(nOpc)
	
	//Gravação da tabela Z69 - Pagamentos
	GravaZ69(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRev,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)    
	
	//Atualiza revisão atual dos demais contratos envolvidos.
	cQry79:=" UPDATE "+RETSQLNAME("Z79")+" SET Z79_REVATU='"+cRev+"'"+CRLF
	cQry79+=" WHERE Z79_NUM='"+cNum+"' AND D_E_L_E_T_='' AND Z79_REVISA<>'"+cRev+"'

	TCSQLExec(cQry79)

	MsgInfo("Revisão gerada com sucesso!")

elseif nOpc==8 //Enviar para aprovação GT


	/*Verifica se o aprovador está preenchido*/
	if empty(M->Z79_APROVA)
		Alert("Campo aprovador não está preenchido!")
		Return(.F.)		
	endif
	
	//Gravando ENCHOICE
	RecLock("Z79",.F.) 
		Z79->Z79_APROVA	:= M->Z79_APROVA
		Z79->Z79_NOMEAP	:= M->Z79_NOMEAP
		Z79->Z79_DTREMG	:= dDataBase
		Z79->Z79_HRREMG	:= TIME()
		Z79->Z79_STATUS:= "3"
    Z79->(MSUNLOCK())
	
	//Pega o e-mail do usuário selecionado como aprovador.
	cTo:=UsrRetMail(M->Z79_APROVA)

	//Envia e-mail para o aprovador, informando sobre o envio de proposta para aprovar
	EnvMaiSo(cTo)

elseif nOpc==9 //Enviar para aprovação Cliente


	//Gravando ENCHOICE
	RecLock("Z79",.F.) 
		Z79->Z79_DTREMC	:= dDataBase
		Z79->Z79_HRREMC	:= TIME()
		Z79->Z79_INFCLI	:= "Enviado p/ cliente data: "+DTOC(dDataBase)+" ,hora: "+SUBSTRING(TIME(),1,5)
		Z79->Z79_STATUS	:= "6"
    Z79->(MSUNLOCK())

elseif nOpc==10 //Cliente aprovou
cCampo:=""

	//Verifica se alguns dados importantes de cobrança estão preenchidos
	for ny:=1 to len(aCpoEnCob)-1
		if aCpoEnCob[ny] $ "Z79_COBTIP/Z79_COBHON/Z79_COBRES/Z79_COBTEL/Z79_COBEMA"
			
			if empty(M->&(aCpoEnCob[ny]))
				DbSelectArea("SX3")
				SX3->(DbSetOrder(2))
				if DbSeek(aCpoEnCob[ny])
					cCampo+=X3Titulo()+", "
				endif
				
			endif

		endif
	next

	cCampo:=SUBSTR(cCampo,1,len(cCampo)-2)
	if !empty(cCampo)

		Alert("O(s) campo(s) da aba Dados Cobraça não está(ão) preenchido(s) :"+CRLF+cCampo,"Atenção")
		Return(.F.)
    
	endif
	
	//Gravando ENCHOICE
	RecLock("Z79",.F.) 
		Z79->Z79_DTAPRO	:= dDataBase
		Z79->Z79_HRAPCL	:= TIME()

		DbSelectArea("Z67")
		Z67->(DbSetOrder(1))
		if DbSeek(xFilial("Z67")+M->Z79_NUM+M->Z79_REVISA+cItemZ67)
			cTipoZ67:=Z67->Z67_TIPO
		endif
		
		if Alltrim(UPPER(cTipoZ67))<>"P"
			Z79->Z79_STATUS:= "8"
        else
			Z79->Z79_STATUS:= "9"
		endif
		
		//Gravando os dados da aba de dados de cobranca
		for ny:=1 to len(aCpoEnCob)-1
			Z79->&(aCpoEnCob[ny]) := M->&(aCpoEnCob[ny])
		next
		
    Z79->(MSUNLOCK())
    
    //RRP - 17/09/2013 - Inclusão do tratamento para alteração do prospect para cliente na proposta
    //Verifica se o prospect esta preenchido e o cliente não
	if !empty(Z79->Z79_PROSPE) .AND. !empty(Z79->Z79_PLOJA) .AND. empty(Z79->Z79_CLIENT) .AND. empty(Z79->Z79_LOJA)
		DbSelectArea("SUS")
		DbSetOrder(1)
		if DbSeek(xFilial("SUS")+Z79->Z79_PROSPE+Z79->Z79_PLOJA) //Se encontrou na tabela SUS
			if !empty(SUS->US_CODCLI)
				RecLock("Z79",.F.)
				Z79->Z79_CLIENT := SUS->US_CODCLI
				Z79->Z79_LOJA 	:= SUS->US_LOJACLI
				Z79->Z79_NOME 	:= SUS->US_NOME
				MsUnLock()
 			else
				if U_GTP2C(Z79->Z79_PROSPE,Z79->Z79_PLOJA) //Se Virou cliente
					DbSelectArea("SUS")
					DbSetOrder(1)
					if DbSeek(xFilial("SUS")+Z79->Z79_PROSPE+Z79->Z79_PLOJA) //Se encontrou na tabela SUS
						//Grava o cliente e a loja na tabela de proposta
						RecLock("Z79",.F.)
						Z79->Z79_CLIENT := SUS->US_CODCLI
						Z79->Z79_LOJA 	:= SUS->US_LOJACLI
						Z79->Z79_NOME 	:= SUS->US_NOME
						MsUnLock()    
					endif
				else
					Alert("Não foi possível tornar o prospect em cliente!")
					Return(.F.)
				endif
			endif
		else
			Alert("Prospect não encontrado!")
			Return(.F.)   
		endif
 
	elseif !empty(Z79->Z79_CLIENT) .AND. !empty(Z79->Z79_LOJA)
		if MsgYesNo("Deseja atualizar os dados de cobrança do cliente com base na proposta?")
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			if Sa1->(DbSeek(xFilial("SA1")+Z79->Z79_CLIENT+Z79->Z79_LOJA))
            
				RecLock("SA1",.F.)
				//endereço
				if SA1->(FieldPos("A1_ENDCOB"))>0 .AND. Z79->(FieldPos("Z79_COBEND"))>0
					SA1->A1_ENDCOB:=Z79->Z79_COBEND
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMAIC"))>0 .AND. Z79->(FieldPos("Z79_COBEMA"))>0
					SA1->A1_P_EMAIC:=Z79->Z79_COBEMA
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMACO"))>0 .AND. Z79->(FieldPos("Z79_COBEMA"))>0
					SA1->A1_P_EMACO:=Z79->Z79_COBEMA
				endif
				//e-mail
				if SA1->(FieldPos("A1_P_EMAIL"))>0 .AND. Z79->(FieldPos("Z79_COBEMA"))>0
					SA1->A1_P_EMAIL:=Z79->Z79_COBEMA
				endif
				//bairro
				if SA1->(FieldPos("A1_BAICOB"))>0 .AND. Z79->(FieldPos("Z79_COBBAI"))>0
					SA1->A1_BAICOB:=Z79->Z79_COBBAI
				endif   
				//bairro
				if SA1->(FieldPos("A1_BAIRROC"))>0 .AND. Z79->(FieldPos("Z79_COBBAI"))>0
					SA1->A1_BAIRROC:=Z79->Z79_COBBAI
				endif   
				//municipio
				if SA1->(FieldPos("A1_MUNCOB"))>0 .AND. Z79->(FieldPos("Z79_COBMUN"))>0
					SA1->A1_MUNCOB:=Z79->Z79_COBMUN
				endif
				//CEP
				if SA1->(FieldPos("A1_CEPCOB"))>0 .AND. Z79->(FieldPos("Z79_COBCEP"))>0
					SA1->A1_CEPCOB:=Z79->Z79_COBCEP
				endif    
			endif

			SA1->(MsUnlock())    
		endif
          
	endif    
    
             
elseif nOpc==11 //Cliente recusou

	/*Verifica o campo Z79_OBSREC está preenchido*/
	if empty(M->Z79_MOTREC)
		Alert("Campo motivo recusa deve ser preenchido!")
		Return(.F.)		
	else
		aCbox	:={}
		cDescOpc:=""
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("Z79_MOTREC"))
		
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
	
		nPos := aScan(aCbox,{|a| Alltrim(a[1])== AllTrim(M->Z79_MOTREC)})
		if nPos > 0
			cDescOpc := alltrim(aCbox[nPos][2])
		endif
		
		if alltrim(Upper(cDescOpc))=="OUTROS" .OR. alltrim(Upper(cDescOpc))=="CONCORRENTE"
			if empty(M->Z79_OBSREC)
				Alert("Campo observação da recusa deve ser preenchido!")
				Return(.F.)		
			endif
		endif
	
	endif


	//Gravando ENCHOICE
	RecLock("Z79",.F.) 
		Z79->Z79_DTRECU	:= dDataBase
		Z79->Z79_HRRECL	:= TIME()
		Z79->Z79_STATUS:= "7"
    Z79->(MSUNLOCK())


elseif nOpc==13	 //Exclusão
	if !MsgYesNo("Deseja realmente excluir a proposta selecionada?")		
 		Return(.F.)
    endif
    
    cNum:=Z79->Z79_NUM
    cRev:=Z79->Z79_REVISA

	// Excluindo a capa
	RecLock("Z79",.F.)
		Z79->(DbDelete())
	MsUnlock()    
    
	// Excluindo os itens
    DbSelectArea("Z78")
    Z78->(DbSetOrder(1))
    if DbSeek(xFilial("Z78")+cNum+cRev)
		
		While Z78->(!EOF()) .AND. Z78->Z78_NUM==cNum .AND. Z78->Z78_REVISA==cRev
			RecLock("Z78",.F.)
				Z78->(DbDelete())
			Z78->(MsUnlock())
			Z78->(DbSkip())
		Enddo

	endif

	// Excluindo os posicionamentos
    DbSelectArea("Z70")
    Z70->(DbSetOrder(2))
    if DbSeek(xFilial("Z70")+cNum+cRev)
		
		While Z70->(!EOF()) .AND. Z70->Z70_PROPOS==cNum .AND. Z70->Z70_REVISA==cRev
			RecLock("Z70",.F.)
				Z70->(DbDelete())
			Z70->(MsUnlock())
			Z70->(DbSkip())
		Enddo

	endif	

	// Excluindo os pagamentos
    DbSelectArea("Z69")
    Z69->(DbSetOrder(1))
    if DbSeek(xFilial("Z69")+cNum+cRev)
		
		While Z69->(!EOF()) .AND. Z69->Z69_PROPOS==cNum .AND. Z69->Z69_REVISA==cRev
			RecLock("Z69",.F.)
				Z69->(DbDelete())
			Z69->(MsUnlock())
			Z69->(DbSkip())
		Enddo

	endif


	// Excluindo os anexos
    DbSelectArea("Z67")
    Z67->(DbSetOrder(1))
    if DbSeek(xFilial("Z67")+cNum+cRev)
		
		While Z67->(!EOF()) .AND. Z67->Z67_PROPOS==cNum .AND. Z67->Z67_REVISA==cRev
			RecLock("Z70",.F.)
				Z67->(DbDelete())
			Z67->(MsUnlock())
			Z67->(DbSkip())
		Enddo

	endif		

	// Excluindo a numeração sequncial
    DbSelectArea("Z77")
    Z77->(DbSetOrder(1))
    if DbSeek(xFilial("Z77")+cNum)
		
		While Z77->(!EOF()) .AND. Z77->Z77_NUM==cNum
			RecLock("Z77",.F.)
				Z77->(DbDelete())
			Z77->(MsUnlock())
			Z77->(DbSkip())
		Enddo

	endif	

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
	If SX3->(DbSeek("Z79_TPCTR"))
	
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
	//cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z79_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z79")+CRLF
	//cQry+=" WHERE D_E_L_E_T_='' AND RIGHT(RTRIM(Z79_NUM),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z79_NUM),3)='"+cDescOpc+"'"

	cQry:=" SELECT MAX(SUBSTRING(LTRIM(Z77_NUM),4,4)) AS SEQ FROM "+RETSQLNAME("Z77")+CRLF
	cQry+=" WHERE D_E_L_E_T_='' AND RIGHT(RTRIM(Z77_NUM),2)='"+cAnoAtu+"' AND LEFT(LTRIM(Z77_NUM),3)='"+cDescOpc+"' AND Z77_FILIAL='"+xFilial("Z77")+"'"
		
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
Funcao      : LEGZ79()  
Parametros  : cTipoCtr
Retorno     : 
Objetivos   : Função para exibição da legenda
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*--------------------*
User Function LEGZ79()
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
					{"BR_VERDE" 	,"Aprovado com Assinatura Cliente	" }}

//					{"F7_CINZ"  	,"Recusado GT/Revisado 	   			" },;

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
Funcao      : Z79_PROS
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se o prospect tem o conflito confirmado
Autor       : Matheus Massarotto
Data/Hora   : 03/07/2012
*/
*-------------------------------*
User Function Z79_PROS()
*-------------------------------*
Local lRet		:= .T.
Local cSta		:= POSICIONE("SUS",1,xFilial("SUS")+M->Z79_PROSPE+M->Z79_PLOJA,"US_STATUS")
Local cCodCli	:= SUS->US_CODCLI
Local cConfli	:= SUS->US_P_CONFL

if alltrim(cSta)=='6'
	Alert("Prospect já é cliente com código: "+cCodCli)
	lRet:=.F.
elseif cConfli<>'1'
	Alert("Prospect não tem o conflito confirmado!"+CRLF+"Por favor inclua um Draft!")
	lRet:=.F.	
endif

Return lRet

/*
Funcao      : VALIDZ78
Parametros  : cAlias,cChave,nOrdem
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 17/08/2012
*/

User function VALIDZ78(cAlias,cChave,nOrdem)
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

/*
Funcao      : Z78PZ80
Parametros  : cVerif
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*-------------------------------*
User Function Z78PZ80(cVerif)
*-------------------------------*
Local lRet	:=.T.

DbSelectArea("Z80")
DbSetOrder(1)
if !DbSeek(xFilial("Z80")+cVerif)
	lRet:=.F.
	alert("Verifique as opções permitidas para esta operação"+CRLF+"Clicando na lupa, ou pressionando F3.","Atenção")
endif

Return lRet

/*
Funcao      : Z78VOLUME
Parametros  : 
Retorno     : lRet
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012
*/
*---------------------*
User function Z78VOLUME
*---------------------*
Local cRet		:=""
Local nHora		:=0
Local nTotal	:=0
Local nPosVol	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_VOLUME"})
Local nPosSer	:=Ascan(aHeader,{|x| alltrim(x[2]) = "Z78_SERVIC"})

DbSelectArea("Z81")
DbSetOrder(1)

For i:=1 to len(aCols)
	if DbSeek(xFilial("Z81")+aCols[i][nPosSer])
		nHora	:=HTON(Z81->Z81_TEMPO)
		nTotal	+=(nHora*aCols[i][nPosVol])
	endif
Next

cRet	:=NTOH(nTotal)
M->Z79_TIME:=cRet

//para atualizar a tela com os dados novos
GetDRefresh()	

return(cRet)

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

if M->Z79_STATUS $ '3/5/6/7/8/9' //Pendente Aprovação GT,Aprovado GT,Pendente Aprovação Cliente,Recusado Cliente,Aprovado sem Assinatura Cliente,Aprovado com Assinatura Cliente
	Alert("Não é possível selecionar serviços."+CRLF+"Esta opção somente funciona quando se está incluindo, alterando ou revisando propostas com situação 'Em Aberto'.")
	Return	
endif

oTFolder:SetOption(1) //Seleciona folder desejado

aArray	:= U_GTF3Z80()  //chama rotina com os serviços para escolha.
aCols	:= oGetDados:aCols

	if len(aCols)>0
	    for u:=len(aCols) to 1 Step -1
		    
		    for v:=1 to len(aCols[u])-1
				if Alltrim(aHeader[v,2])=="Z78_SERVIC"
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
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_DEPART" //nSeqJ==2 // Código do Departamento
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][5]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_DESCDE" //nSeqJ==3 // Descrição do Departamento
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][6]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_AREA" //nSeqJ==4 // Código da Área
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][3]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_DESCAR" //nSeqJ==5 // Descrição da Área
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][4]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_SERVIC" //nSeqJ==6 // Código do Serviço
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][1]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_DESCSE" //nSeqJ==7 // Descrição do Serviço
					aCols[Len(aCols)][nSeqJ]:=aArray[nSeqI][2]
				elseif Alltrim(aHeader[nSeqJ,2])=="Z78_VOLUME" //nSeqJ==8 // Volume
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
Funcao      : GravaZ70
Parametros  : nOpc
Retorno     : 
Objetivos   : Função para gravar a tabela Z70
Autor       : Matheus Massarotto
Data/Hora   : 18/10/2012
*/
*-----------------------------------------*
Static Function GravaZ70(nOpc)
*-----------------------------------------*

	BEGIN TRANSACTION	
		RECLOCK("Z70",.T.)
			Z70->Z70_FILIAL	:= xFilial("Z70")
			Z70->Z70_ID		:= GETSXENUM("Z70","Z70_ID")
			Z70->Z70_PROPOS	:= Z79->Z79_NUM
			Z70->Z70_REVISA := Z79->Z79_REVISA
			Z70->Z70_DATA  	:= DATE()
			Z70->Z70_HORA   := TIME()
			Z70->Z70_PORCEN := cTexto
			Z70->Z70_MOTIVO := cMemo
			Z70->Z70_USER  	:= LOGUSERNAME()
		Z70->(MsUnLock())
		ConfirmSx8()
	END TRANSACTION 
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

if nOpc==6
	cRev:=STRZERO((val(cRev)-1),3)
endif


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
Static Function LoadPaO1(oQual1,cValG3_1_4,cValAux,oSayG3_1_1,cValG3_1_1,cValG3_1_2,oSayG3_1_2,cVal,oGetDad,aHead,lIncDIPJ,lIncAnual,dVal)
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
							//Z79_VALOR
	cValG3_1_1:=Transform(M->Z79_VLRTOT+M->Z79_VLDIPJ+M->Z79_VLRANO,'@E 99,999,999,999.99')
elseif lIncDIPJ .AND. !lIncAnual
							//Z79_VALOR
	cValG3_1_1:=Transform(M->Z79_VLRTOT+M->Z79_VLDIPJ,'@E 99,999,999,999.99')
elseif !lIncDIPJ .AND. lIncAnual
							//Z79_VALOR
	cValG3_1_1:=Transform(M->Z79_VLRTOT+M->Z79_VLRANO,'@E 99,999,999,999.99')
else
							//Z79_VALOR
	cValG3_1_1:=Transform(M->Z79_VLRTOT,'@E 99,999,999,999.99')
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

cValG3_2_1:=Transform(M->Z79_VLRIMP,'@E 99,999,999,999.99')

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

cValG3_3_1:=Transform(M->Z79_VLDIPJ,'@E 99,999,999,999.99')

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

cValG3_4_1:=Transform(M->Z79_VLRANO,'@E 99,999,999,999.99')

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

*------------------------------------------------------*
Static Function CarregaDia(cVal,oGetDad,aHead,dDataIni)
*------------------------------------------------------*
Local lRet	:= .F.
Local nVal	:= val(cVal)
Local nPos	:= Ascan(aHead,{|x| alltrim(x[2]) = "M_VENC"})
Local dDate	:= CTOD("//")

DEFAULT dDataIni:=CTOD("//")

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
Funcao      : I_FG40O1
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, valor da proposta
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 1
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG40O1
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
Funcao      : I_FG40O2
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, Valor da implantação
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 2
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG40O2
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
Funcao      : I_FG40O3
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, Valor de DIPJ
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 3
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG40O3
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
Funcao      : I_FG40O4
Parametros  : Função utilizada na validação do campo M_VALOR, da getdados para verificar os valores alterados nas parcelas, Valor Anual
Retorno     : lRet
Objetivos   : 
Nomenclatura: Interno Fonte Gtcorp 40 Objeto 4
Autor       : Matheus Massarotto
Data/Hora   : 08/11/2012
*/
              
*---------------------*
User function I_FG40O4
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
		nValAux:=val(StrTran(cValAux,"."))+M->Z79_VLDIPJ+M->Z79_VLRANO
		
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
		nValAux:=val(StrTran(cValAux,"."))+M->Z79_VLDIPJ
	    
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
		nValAux:=val(StrTran(cValAux,"."))+M->Z79_VLRANO
		
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
Funcao      : GravaZ69
Parametros  : 
Retorno     : 
Objetivos   : Função para adicionar gravar/alterar tabelaZ69
Autor       : Matheus Massarotto
Data/Hora   : 12/11/2012
*/

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Static Function GravaZ69(nOpc,oGetDdsVlr,aHeadVlr,cCombo_1_7,cCombo_1_8,oGetDdsImp,aHeadImp,oGetDdsDip,aHeadDip,oGetDdsAno,aHeadAno,cNum,cRevisao,cValG3_1_6,cValG3_2_6,cValG3_3_6,cValG3_4_6)
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
		    		RecLock("Z69",.T.)
			    		Z69->Z69_FILIAL	:= xFilial("Z69")
			    		Z69->Z69_PROPOS	:= cNum
			    		Z69->Z69_REVISA	:= "000"
			    		Z69->Z69_TIPO	:= "PROPOSTA"
			    		Z69->Z69_PARCEL	:= oGetDdsVlr:Acols[nW][nPosParc]
			    		Z69->Z69_VENCTO	:= oGetDdsVlr:Acols[nW][nPosVenc]
			    		Z69->Z69_VALOR	:= oGetDdsVlr:Acols[nW][nPosVlr]
			    		Z69->Z69_INCDIP	:= IIF(lIncDIPJ69,"S","N")
			    		Z69->Z69_INCANO	:= IIF(lIncANO69,"S","N")
			    		Z69->Z69_DTINC	:= dDataBase
			    		Z69->Z69_DIAVEN	:= cValG3_1_6
			    	Z69->(MsUnLock())
		    	endif
		    next
			
		endif
		
		//Implantação
		nPosParc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_PARC"})
		nPosVenc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
		nPosVlr		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
				
		if !empty(oGetDdsImp:Acols)
		    for nW:=1 to len(oGetDdsImp:Acols)
		    	if empty(oGetDdsImp:Acols[nW][1])
		    	   loop
		    	else
		    		RecLock("Z69",.T.)
			    		Z69->Z69_FILIAL	:= xFilial("Z69")
			    		Z69->Z69_PROPOS	:= cNum
			    		Z69->Z69_REVISA	:= "000"
			    		Z69->Z69_TIPO	:= "IMPLANTACAO"
			    		Z69->Z69_PARCEL	:= oGetDdsImp:Acols[nW][nPosParc]
			    		Z69->Z69_VENCTO	:= oGetDdsImp:Acols[nW][nPosVenc]
			    		Z69->Z69_VALOR	:= oGetDdsImp:Acols[nW][nPosVlr]
			    		Z69->Z69_INCDIP	:= ""
			    		Z69->Z69_INCANO	:= ""
			    		Z69->Z69_DTINC	:= dDataBase
			    		Z69->Z69_DIAVEN	:= cValG3_2_6
					Z69->(MsUnlock())
		    	endif
		    next
			
		endif	
	
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
			    		RecLock("Z69",.T.)
				    		Z69->Z69_FILIAL	:= xFilial("Z69")
				    		Z69->Z69_PROPOS	:= cNum
				    		Z69->Z69_REVISA	:= "000"
				    		Z69->Z69_TIPO	:= "DIPJ"
				    		Z69->Z69_PARCEL	:= oGetDdsDip:Acols[nW][nPosParc]
				    		Z69->Z69_VENCTO	:= oGetDdsDip:Acols[nW][nPosVenc]
				    		Z69->Z69_VALOR	:= oGetDdsDip:Acols[nW][nPosVlr]
				    		Z69->Z69_INCDIP	:= ""
				    		Z69->Z69_INCANO	:= ""
				    		Z69->Z69_DTINC	:= dDataBase
				    		Z69->Z69_DIAVEN	:= cValG3_3_6
						Z69->(MsUnlock())
			    	endif
			    next
				
			endif
		
		endif
	
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
			    		RecLock("Z69",.T.)
				    		Z69->Z69_FILIAL	:= xFilial("Z69")
				    		Z69->Z69_PROPOS	:= cNum
				    		Z69->Z69_REVISA	:= "000"
				    		Z69->Z69_TIPO	:= "ANUAL"
				    		Z69->Z69_PARCEL	:= oGetDdsAno:Acols[nW][nPosParc]
				    		Z69->Z69_VENCTO	:= oGetDdsAno:Acols[nW][nPosVenc]
				    		Z69->Z69_VALOR	:= oGetDdsAno:Acols[nW][nPosVlr]
				    		Z69->Z69_INCDIP	:= ""
				    		Z69->Z69_INCANO	:= ""
				    		Z69->Z69_DTINC	:= dDataBase
				    		Z69->Z69_DIAVEN	:= cValG3_4_6
						Z69->(MsUnlock())
			    	endif
			    next
				
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
		    		RecLock("Z69",.T.)
			    		Z69->Z69_FILIAL	:= xFilial("Z69")
			    		Z69->Z69_PROPOS	:= cNum
			    		Z69->Z69_REVISA	:= cRevisao
			    		Z69->Z69_TIPO	:= "PROPOSTA"
			    		Z69->Z69_PARCEL	:= oGetDdsVlr:Acols[nW][nPosParc]
			    		Z69->Z69_VENCTO	:= oGetDdsVlr:Acols[nW][nPosVenc]
			    		Z69->Z69_VALOR	:= oGetDdsVlr:Acols[nW][nPosVlr]
			    		Z69->Z69_INCDIP	:= IIF(lIncDIPJ69,"S","N")
			    		Z69->Z69_INCANO	:= IIF(lIncANO69,"S","N")
			    		Z69->Z69_DTINC	:=	dDataBase
			    		Z69->Z69_DIAVEN	:= cValG3_1_6
			    	Z69->(MsUnLock())
		    	endif
		    next
			
		endif
		
		//Implantação
		nPosParc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_PARC"})
		nPosVenc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
		nPosVlr		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
				
		if !empty(oGetDdsImp:Acols)
		    for nW:=1 to len(oGetDdsImp:Acols)
		    	if empty(oGetDdsImp:Acols[nW][1])
		    	   loop
		    	else
		    		RecLock("Z69",.T.)
			    		Z69->Z69_FILIAL	:= xFilial("Z69")
			    		Z69->Z69_PROPOS	:= cNum
			    		Z69->Z69_REVISA	:= cRevisao
			    		Z69->Z69_TIPO	:= "IMPLANTACAO"
			    		Z69->Z69_PARCEL	:= oGetDdsImp:Acols[nW][nPosParc]
			    		Z69->Z69_VENCTO	:= oGetDdsImp:Acols[nW][nPosVenc]
			    		Z69->Z69_VALOR	:= oGetDdsImp:Acols[nW][nPosVlr]
			    		Z69->Z69_INCDIP	:= ""
			    		Z69->Z69_INCANO	:= ""
			    		Z69->Z69_DTINC	:= dDataBase
			    		Z69->Z69_DIAVEN	:= cValG3_2_6
					Z69->(MsUnlock())
		    	endif
		    next
			
		endif	
	
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
			    		RecLock("Z69",.T.)
				    		Z69->Z69_FILIAL	:= xFilial("Z69")
				    		Z69->Z69_PROPOS	:= cNum
				    		Z69->Z69_REVISA	:= cRevisao
				    		Z69->Z69_TIPO	:= "DIPJ"
				    		Z69->Z69_PARCEL	:= oGetDdsDip:Acols[nW][nPosParc]
				    		Z69->Z69_VENCTO	:= oGetDdsDip:Acols[nW][nPosVenc]
				    		Z69->Z69_VALOR	:= oGetDdsDip:Acols[nW][nPosVlr]
				    		Z69->Z69_INCDIP	:= ""
				    		Z69->Z69_INCANO	:= ""
				    		Z69->Z69_DTINC	:= dDataBase
				    		Z69->Z69_DIAVEN	:= cValG3_3_6
						Z69->(MsUnlock())
			    	endif
			    next
				
			endif
		
		endif
	
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
			    		RecLock("Z69",.T.)
				    		Z69->Z69_FILIAL	:= xFilial("Z69")
				    		Z69->Z69_PROPOS	:= cNum
				    		Z69->Z69_REVISA	:= cRevisao
				    		Z69->Z69_TIPO	:= "ANUAL"
				    		Z69->Z69_PARCEL	:= oGetDdsAno:Acols[nW][nPosParc]
				    		Z69->Z69_VENCTO	:= oGetDdsAno:Acols[nW][nPosVenc]
				    		Z69->Z69_VALOR	:= oGetDdsAno:Acols[nW][nPosVlr]
				    		Z69->Z69_INCDIP	:= ""
				    		Z69->Z69_INCANO	:= ""
				    		Z69->Z69_DTINC	:= dDataBase
				    		Z69->Z69_DIAVEN	:= cValG3_4_6
						Z69->(MsUnlock())
			    	endif
			    next
				
			endif
		
		endif
	    
	End Transaction

elseif nOpc==4 //Alterar
    
	//Apagando a informação 
	
	cQryDel:=" DELETE FROM "+RETSQLNAME("Z69")
	cQryDel+=" WHERE Z69_FILIAL='"+xFilial("Z69")+"' AND Z69_PROPOS='"+cNum+"' AND Z69_REVISA='"+cRevisao+"'
    
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
			    		RecLock("Z69",.T.)
				    		Z69->Z69_FILIAL	:= xFilial("Z69")
				    		Z69->Z69_PROPOS	:= cNum
				    		Z69->Z69_REVISA	:= cRevisao
				    		Z69->Z69_TIPO	:= "PROPOSTA"
				    		Z69->Z69_PARCEL	:= oGetDdsVlr:Acols[nW][nPosParc]
				    		Z69->Z69_VENCTO	:= oGetDdsVlr:Acols[nW][nPosVenc]
				    		Z69->Z69_VALOR	:= oGetDdsVlr:Acols[nW][nPosVlr]
				    		Z69->Z69_INCDIP	:= IIF(lIncDIPJ69,"S","N")
				    		Z69->Z69_INCANO	:= IIF(lIncANO69,"S","N")
				    		Z69->Z69_DTINC	:=	dDataBase
				    		Z69->Z69_DIAVEN	:= cValG3_1_6
				    	Z69->(MsUnLock())
			    	endif
			    next
				
			endif
			
			//Implantação
			nPosParc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_PARC"})
			nPosVenc	:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VENC"})
			nPosVlr		:= Ascan(aHeadImp,{|x| alltrim(x[2]) = "M_VALOR"})
					
			if !empty(oGetDdsImp:Acols)
			    for nW:=1 to len(oGetDdsImp:Acols)
			    	if empty(oGetDdsImp:Acols[nW][1])
			    	   loop
			    	else
			    		RecLock("Z69",.T.)
				    		Z69->Z69_FILIAL	:= xFilial("Z69")
				    		Z69->Z69_PROPOS	:= cNum
				    		Z69->Z69_REVISA	:= cRevisao
				    		Z69->Z69_TIPO	:= "IMPLANTACAO"
				    		Z69->Z69_PARCEL	:= oGetDdsImp:Acols[nW][nPosParc]
				    		Z69->Z69_VENCTO	:= oGetDdsImp:Acols[nW][nPosVenc]
				    		Z69->Z69_VALOR	:= oGetDdsImp:Acols[nW][nPosVlr]
				    		Z69->Z69_INCDIP	:= ""
				    		Z69->Z69_INCANO	:= ""
				    		Z69->Z69_DTINC	:= dDataBase
				    		Z69->Z69_DIAVEN	:= cValG3_2_6
						Z69->(MsUnlock())
			    	endif
			    next
				
			endif	
		
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
				    		RecLock("Z69",.T.)
					    		Z69->Z69_FILIAL	:= xFilial("Z69")
					    		Z69->Z69_PROPOS	:= cNum
					    		Z69->Z69_REVISA	:= cRevisao
					    		Z69->Z69_TIPO	:= "DIPJ"
					    		Z69->Z69_PARCEL	:= oGetDdsDip:Acols[nW][nPosParc]
					    		Z69->Z69_VENCTO	:= oGetDdsDip:Acols[nW][nPosVenc]
					    		Z69->Z69_VALOR	:= oGetDdsDip:Acols[nW][nPosVlr]
					    		Z69->Z69_INCDIP	:= ""
					    		Z69->Z69_INCANO	:= ""
					    		Z69->Z69_DTINC	:= dDataBase
					    		Z69->Z69_DIAVEN	:= cValG3_3_6
							Z69->(MsUnlock())
				    	endif
				    next
					
				endif
			
			endif
		
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
				    		RecLock("Z69",.T.)
					    		Z69->Z69_FILIAL	:= xFilial("Z69")
					    		Z69->Z69_PROPOS	:= cNum
					    		Z69->Z69_REVISA	:= cRevisao
					    		Z69->Z69_TIPO	:= "ANUAL"
					    		Z69->Z69_PARCEL	:= oGetDdsAno:Acols[nW][nPosParc]
					    		Z69->Z69_VENCTO	:= oGetDdsAno:Acols[nW][nPosVenc]
					    		Z69->Z69_VALOR	:= oGetDdsAno:Acols[nW][nPosVlr]
					    		Z69->Z69_INCDIP	:= ""
					    		Z69->Z69_INCANO	:= ""
					    		Z69->Z69_DTINC	:= dDataBase
					    		Z69->Z69_DIAVEN	:= cValG3_4_6
							Z69->(MsUnlock())
				    	endif
				    next
					
				endif
			
			endif
		    
		End Transaction
	
	else
		Alert("Não foi possível salvar a aba pagamentos!")
	endif	

endif

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
Static Function GarregaZ69(nOpc,cNum,cRev,cTipo,xParam3)
*------------------------------------------------------*
Local aRet	:= {}
Local cQry	:= ""


if xParam3==12 .OR. nOpc<>3

	if nOpc==6 //revisar
		cRev:=STRZERO(val(cRev)-1,3)
	endif
	
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
		RecLock("Z79",.F.)
			Z79->Z79_ANEXO:=alltrim(cLocalArq+"\"+cNomeArq)
		Z79->(MsUnlock())
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
Local oDlgZ68:=oTFolder:aDialogs[4]

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
oBrowseZ68:SetSizeBrowse(80)


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
	cQry+=" WHERE D_E_L_E_T_='' AND Z68_FILIAL='"+xFilial("Z68")+"' AND Z68_PROPOS='"+M->Z79_NUM+"' AND Z68_REVISA='"+M->Z79_REVISA+"'"
	
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
*--------------------*
User Function P_GraZ68
*--------------------*	    
	RecLock("Z68",.F.)
		Z68->Z68_PROPOS:=M->Z79_NUM
		Z68->Z68_REVISA:=M->Z79_REVISA
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

/*
Funcao      : AnexoP00
Parametros  : nOpc, cItemZ67
Retorno     : Nil
Objetivos   : Rotina para manutenção de anexos.
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:19
*/
*-----------------------------*
Static Function AnexoP00(nOpc,cItemZ67)
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


if nOpc==3
	RegToMemory("Z67",If(nOpc==3,.T.,.F.))
	cItemZ67:="00"
else
    DbSelectArea("Z67")
    Z67->(DbGoTop())
    DbSetOrder(1)
    DbSeek(xFilial("Z67")+M->Z79_NUM+M->Z79_REVISA)
    While Z67->(!EOF()) .AND. Z67->Z67_PROPOS==M->Z79_NUM .AND. Z67->Z67_REVISA==M->Z79_REVISA
	   	AADD(aAnexos,{Z67->Z67_ITEM,Z67->Z67_TIPO,Z67->Z67_DATA,Z67->Z67_HORA,Z67->Z67_ARQUIV})
    	cItemZ67:=Z67->Z67_ITEM
    	Z67->(DbSkip())
    Enddo
    if empty(cItemZ67)
    	cItemZ67:="00"
    endif
endif


Begin Sequence

If nOpc <> 2
	aAdd(aButtons,{ "BMPINCLUIR" ,{ || AddFile(nOpc) }, "Adicionar arquivo" + " <F3>", "Adicionar"})
	aAdd(aButtons,{ "BPMSDOCE"   ,{ || DelFile() }, "Remover arquivo"            , "Remover"  })
Else
	aAdd(aButtons,{ "BMPINCLUIR" ,{ || alert("Opção não disponível para visualizar!") }, "Adicionar arquivo" + " <F3>", "Adicionar"})
	aAdd(aButtons,{ "BPMSDOCE"   ,{ || alert("Opção não disponível para visualizar!") }, "Remover arquivo"            , "Remover"  })
EndIf

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

	SetKey(VK_F3,{|| AddFile(nOpc) })

//Activate MsDialog oDlgAnexo ON INIT EnchoiceBar(oDlgAnexo,bOk,bCancel,,aButtons) Centered
//Rotina personalizada para funcionar botões na versão 11
ACTIVATE MSDIALOG oDlgAnexo ON INIT U_GTEnchBar(oDlgAnexo,bOk,bCancel,,aButtons) CENTERED

SetKey(VK_F3,Nil)

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

Private bFileAction := {|| cArquivo := ChooseFile()}, cArquivo := Space(200)

//Verifica se existe arquivo anexado.
//nP := aScan(aCols,{|a| a[1] == cItemZ02})

If nP > 0
	MsgInfo("Já existe arquivo anexado para essa movimentação.","Atenção")
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE "Seleção de arquivos" FROM 1,1 To 91,376 OF oMainWnd Pixel
      
	@ 04,4 to 43,185 Label "Escolha o arquivo a ser anexado:" PIXEL
      
	@ 15,12 MsGet oArquivo Var cArquivo Size 150,07 Pixel Of oDlg
      
	@ 15,162 Button "..." Size 10,10 Pixel Action .t. Of oDlg

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
  
oMsGet:oBrowse:Refresh()
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
	
	cItemZ67:=SOMA1(cItemZ67)

	aAdd(aCols, Array( Len(aHeader)+1 ) )
	n := Len(aCols)
	aCols[n][Len(aCols[n])] := .f.
	aCols[n][1] := cItemZ67    							  //item
	aCols[n][2] := cDesTpMov                              //tipo
	aCols[n][3] := dDatabase                              //data
	aCols[n][4] := Time()                                 //hora
	aCols[n][5] := IncSpace(cArq,aHeader[5][4],.f.)       //nome do arquivo
	AAdd(aColsAcento,cArq)
	
	if !GrvAnexo(nOpc,cItemZ67)
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
Static Function DelFile()
*-----------------------*
Local nP := 0

//Verifica se existe arquivo anexado.
nP := aScan(aCols,{|a| a[1] == aCols[oMsGet:oBrowse:nAt][1]})
If nP > 0
    
	If MsgYesNo("Confirma a exclusão do arquivo anexo?","Atenção")

		DbSelectArea("Z67")
		DbSetOrder(1)
		DbSeek(xFilial("Z67")+M->Z79_NUM+M->Z79_REVISA+aCols[nP][1])
		RecLock("Z67",.F.)
			Z67->(DbDelete())
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
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD
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
Local nOptions:= GETF_LOCALHARD+GETF_NETWORKDRIVE

Local aArea := GetArea()

SetKey(VK_F3,Nil)

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,.F.,nOptions,.F.)

If Empty(cFile)
   Return cArquivo
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

SetKey(VK_F3,bFileAction)

RestArea(aArea)

Return IncSpace(cFile,200,.f.)


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
   MsgInfo("Informe o caminho e o nome do arquivo","Aviso")
   Return .f.
EndIf

if nOpc==10
	if !MsgYesNo("Nesta operação somente deve ser anexado a proposta assinada, confirma documento como sendo a proposta assinada?","Atencao")
		Return(.F.)
	endif
elseif nOpc==4 .AND. M->Z79_STATUS=='8'
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
Parametros  : nOpc,cItemZ67
Retorno     : Nil
Objetivos   : Gravação das informações do anexo na tabela Z67
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2013 16:25
*/

*-------------------------------------*
Static function GrvAnexo(nOpc,cItemZ67)
*-------------------------------------*
Local cTipoMov	:= ""
Local cDescMov	:= ""

if nOpc == 4 .AND. M->Z79_STATUS=='8'
	cTipoMov:="P"
	cDescMov:="Alteração de proposta: " + M->Z79_NUM
elseif nOpc == 4
	cTipoMov:="A"
	cDescMov:="Alteração de proposta: " + M->Z79_NUM
elseif nOpc == 6
	cTipoMov:="A"
	cDescMov:="Revisão de proposta: " + M->Z79_NUM
elseif nOpc == 10
	cTipoMov:="P"
	cDescMov:="Aprovado cliente proposta: " + M->Z79_NUM
elseif nOpc == 11
	cTipoMov:="A"
	cDescMov:="Recusado cliente proposta: " + M->Z79_NUM
else
	cTipoMov:="A"
	cDescMov:="Outra opção de proposta: " + M->Z79_NUM
endif

//Gravação do anexo (itens)
RecLock("Z67",.T.)                               
	Z67->Z67_FILIAL := xFilial("Z67")
	Z67->Z67_PROPOS := M->Z79_NUM
	Z67->Z67_REVISA := M->Z79_REVISA
	Z67->Z67_ITEM   := cItemZ67
	Z67->Z67_DATA   := dDataBase
	Z67->Z67_HORA   := Time()
	Z67->Z67_CODUSR := RetCodUsr()
	Z67->Z67_TIPO   := cTipoMov

If nOpc == 3
	Z67->Z67_DESCRI := 	"Inclusão de proposta: " + M->Z79_NUM
Else
	Z67->Z67_DESCRI := AllTrim(cDescMov)
EndIf

//Gravação do arquivo anexo
//nP := aScan(aAnexos,{|a| a[1] == cItemZ67})
nP := aScan(aCols,{|a| a[1] == cItemZ67})
If nP > 0

	cPastaCod   := STRTRAN(Z67->Z67_PROPOS,"/","_")+(Z67->Z67_REVISA) + "\"
	cPastaItem  := AllTrim(Z67->Z67_ITEM) + "\"

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
	        
	cOrig := AllTrim(aCols[nP][5])
	cDest := Alltrim(cPasta)
            
	//Realiza a copia para a pasta da proposta.
	If !Cpyt2s(cOrig,cDest,.F.)
       	MsgInfo("O arquivo anexo não foi copiado.","Atenção")
       	Return .F.
	Else
		//Grava o nome do arquivo
		Z67->Z67_ARQUIV := AllTrim(cArquiv)

	EndIf
EndIf

Z67->(MsUnlock())

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
Static Function EnvMaiSo(cTo)
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

if !empty(cTo)
	cHtml +='<p style="text-align:justify" class="style21">A proposta abaixo está aguardando sua aprovação.</p>'
else
	cHtml +='<p style="text-align:justify" class="style21">A proposta abaixo não pode ser entregue por e-mail ao aprovador!</p>'
endif
cHtml +='<table class="MsoNormalTable" border="0" cellpadding="0" id="total">'
cHtml +='<tr>'
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
/*
<style type="text/css">.ExternalClass{width:100% !important;}
    
</style>


<body marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" bgcolor="#f3f3f3">
<table width="100%" align="center" cellspacing="0" cellpadding="0" border="0" bgcolor="#f3f3f3">
	<tr>
		<td>
			<table width="600" cellpadding="0" cellspacing="0" border="0" align="center">
				<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="20" vspace="0" hspace="0"></td></tr>
				<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="22" vspace="0" hspace="0"></td></tr>
				<tr>
					<td>
						<table width="100%" cellspacing="0" cellpadding="0" border="0">
							<tr>
								<td bgcolor="#e2e2e2" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="19" height="1" vspace="0" hspace="0"></td>
								<td bgcolor="#e2e2e2" style="font-size:0; line-height:0;"><img width="9" vspace="0" hspace="0" border="0" height="32" align="left" src="images/5cf89d91c3504a0332f056760e0c5e29.gif" alt=""></td>
								<td bgcolor="#e2e2e2" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="9" height="1" vspace="0" hspace="0"></td>
								<td valign="middle" width="400" bgcolor="#e2e2e2" style="line-height:16px;" name="gentil">
									<font face="Arial, Helvetica, sans-serif" size="2" color="#b5b5b5" style="line-height:16px; font-size:12px;"><strong>"+IIF(nHora<6,"Boa noite!",IIF(nHora<12,"Bom dia!",IIF(nHora<18,"Boa tarde!","Boa noite!")))+"</strong></font>
								</td>
								<td bgcolor="#e2e2e2" style="font-size:0; line-height:0;"><img width="10" vspace="0" hspace="0" border="0" height="32" align="left" src="images/e7944ba85a8321b50eee257088f675e3.gif" alt=""></td>
								<td valign="middle" width="115" align="right" style="line-height:16px; text-align:right;">
									<font face="Arial, Helvetica, sans-serif" size="2" color="#707070" style="line-height:16px; font-size:12px;"><strong>"+DTOC(DATE())+"</strong></font>
								</td>
								<td bgcolor="#f3f3f3" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="9" height="1" vspace="0" hspace="0"></td>
								<td bgcolor="#f3f3f3" style="font-size:0; line-height:0;"><img width="9" vspace="0" hspace="0" border="0" height="32" align="left" src="images/78d26cc7d88084cf90abe40b99629144.gif" alt=""></td>
								<td bgcolor="#f3f3f3" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="20" height="1" vspace="0" hspace="0"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="10" vspace="0" hspace="0"></td></tr>
				<tr>
					<td width="600">
						<table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="ffffff">
							<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="15" vspace="0" hspace="0"></td></tr>
							<tr>
								<td>
									<table width="100%" cellspacing="0" cellpadding="0" border="0">
										<tr>
											<td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="19" height="1" vspace="0" hspace="0"></td>
											<td bgcolor="#ffffff" style="font-size:0; line-height:0;"><a href="" target=_blank><img src="http://dc628.4shared.com/img/GO9l02H7/0.5058860903272262/logo.png" border="0"></a></td>
											<td valign="top" width="334" align="right" style="text-align=right;">
												<table border="0" align="right" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
													<tr>
														<td colspan="4" align="right" style="line-height:15px; text-align=right;">
															<font face="Arial, Helvetica, sans-serif" size="2" color="#c5c5c5" style="line-height:15px; font-size:38px;">Informativo: </font>
														</td>
													</tr>
													<tr><td colspan="4" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="7" vspace="0" hspace="0"></td></tr>
													<tr>
														<td colspan="4" align="right" style="font-size:0; line-height:0;">&nbsp;</td>
													</tr>
											  </table>
											</td>
											<td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="20" height="1" vspace="0" hspace="0"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="19" vspace="0" hspace="0"></td></tr>
							<tr><td bgcolor="#ececec" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="1" vspace="0" hspace="0"></td></tr>
							<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="19" vspace="0" hspace="0"></td></tr>
							<tr>
							  <td style="font-size:0; line-height:0;">colocar as paradas aqui</td></tr>
							<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="10" vspace="0" hspace="0"></td></tr>
							<tr>
								<td width="600">
									<table width="100%" cellspacing="0" cellpadding="0" border="0">
										<tr>
											<td valign="middle" width="457" align="center" style="line-height:17px; text-align=center;">
												<font face="Arial, Helvetica, sans-serif" size="2" color="#313131" style="line-height:17px; font-size:10px;">Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.</font>
											</td>

											
										</tr>
									</table>
								</td>
							</tr>
							<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="8" vspace="0" hspace="0"></td></tr>
							<tr><td bgcolor="#ececec" style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="1" vspace="0" hspace="0"></td></tr>
							<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="19" vspace="0" hspace="0"></td></tr>
						</table>
					</td>
				</tr>
				<tr><td style="font-size:0; line-height:0;"><img src="images/0ea5c802b4e9dc73e7bf1470a843261c.gif" width="1" height="12" vspace="0" hspace="0"></td></tr>
			</table>
		</td>
	</tr>
</table>
</body>
*/

if empty(cTo)

	//UsrRetMail ( [ cCodUsr ] ) -- Retorna o e-mail do usuário
	cTo:=UsrRetMail(__cUserID)
	cSubject:="Erro ao enviar e-mail para aprovador, cliente - "+cNomeClie+"- n: "+alltrim(M->Z79_NUM)

else

	//UsrRetName(id usuário)- Nome do usuário corrente ()
	cSubject:=CAPITAL(alltrim(UsrRetName (__cUserID)))+" enviou uma proposta para ser aprovada - "+cNomeClie+"- n: "+alltrim(M->Z79_NUM)

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
	conout("GTCORP40--->>> E-mail enviado com sucesso, para o aprovador da proposta")
ELSE
	conout("GTCORP40--->>> Falha no envio do e-mail, para o aprovador da proposta")
ENDIF

RETURN .T.


/*
Funcao      : Z79_PRCL
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se o prospect ou cliente tem o conflito OK
Autor       : Matheus Massarotto
Data/Hora   : 08/04/2013
*/
*-------------------------------*
User Function Z79_PRCL(cProCli)
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
	if SA1->(DbSeek(xFilial("SA1")+M->Z79_CLIENT+M->Z79_LOJA))
		cConfli	:= SA1->A1_P_CONFL
		
		if cConfli<>'1'
			Alert("Cliente não tem o conflito OK!")
			lRet:=.F.	
		endif
	endif
	
elseif UPPER(cProCli)=="PRO"

	cSta	:= POSICIONE("SUS",1,xFilial("SUS")+M->Z79_PROSPE+M->Z79_PLOJA,"US_STATUS")
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
Funcao      : GT40Filtro
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Matheus Massarotto
Data/Hora   : 03/07/11 17:00
*/
*------------------------------------------------*
User Function GT40Filtro(lExibe,cAlias,aIndexZ79)
*------------------------------------------------*
Local cArea    	:= (cAlias)->(GetArea())
Local cPerg		:= "GTCORP40"
Local cFiltro	:= ""
Local cIdUser	:= __cUserID // Id do usuário logado

                                                    //40
aHelpPor1:={"Informe a Data de Inclusão"}
aHelpPor2:={"Informe a Data de Inclusão"}

//Definição da pergunta
PutSx1(cPerg , "01","Data de  ?" 		," "," ","mv_ch01","D",08,0,0,"G","     ","","","","MV_PAR01",""	,"",""," ",""	,"","" ,"","","","","","","",""," ",aHelpPor1)
PutSx1(cPerg , "02","Data ate ?" 		," "," ","mv_ch02","D",08,0,0,"G","     ","","","","MV_PAR02",""	,"",""," ",""	,"","" ,"","","","","","","",""," ",aHelpPor2)
PutSx1(cPerg , "03","Exibe Revisado ?" 	," "," ","mv_ch03","N",01,0,0,"C","     ","","","","MV_PAR03","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")
PutSx1(cPerg , "04","Exibe Recusado ?" 	," "," ","mv_ch04","N",01,0,0,"C","     ","","","","MV_PAR04","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")
PutSx1(cPerg , "05","Exibe Aprovado ?" 	," "," ","mv_ch05","N",01,0,0,"C","     ","","","","MV_PAR05","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")
PutSx1(cPerg , "06","Exibe Pendente ?" 	," "," ","mv_ch06","N",01,0,0,"C","     ","","","","MV_PAR06","Sim"	,"",""," ","Nao","","" ,"","","","","","","",""," ")


//Inicializa as variaveis de pergunta.
Pergunte(cPerg,lExibe,"Filtro de exibição")


//Verifica se o usuário pode ver todas as propostas
DbSelectArea("Z66")
Z66->(DbSetOrder(1))
if Z66->(DbSeek(xFilial("Z66")+cIdUser))
	if Z66->Z66_LADMIN
		lFilter:=.F.
	else
	    if Z66->Z66_LVISP
			lFilter:=.F.
		elseif Z66->Z66_LRESPO //.OR. Z66->Z66_LAPROV
			DbSelectArea("Z65")
			Z65->(DbSetOrder(1))
			if Z65->(DbSeek(xFilial("Z65")+Z66->Z66_IDUSER))
	
				cFiltro:="Z79->Z79_USERRE = '"+cIdUser+"'"
				
				While Z65->(!eof()) .AND. Z65->Z65_FILIAL==xFilial("Z65") .AND.  Z65->Z65_IDUSER==Z66->Z66_IDUSER
					
					if Z66->Z66_LRESPO
						cFiltro+=".OR.( Z79->Z79_USERRE = '"+alltrim(Z65->Z65_IDDEPE)+"' .AND. Z79->Z79_RESPON = '"+alltrim(cIdUser)+"' )"
	                else
	                	cFiltro+=".OR. Z79->Z79_USERRE = '"+alltrim(Z65->Z65_IDDEPE)+"'"
	                endif
	                
					Z65->(DbSkip())
				Enddo
			else
				cFiltro:="Z79->Z79_USERRE = '"+cIdUser+"'"
			endif
		else
			cFiltro:="Z79->Z79_USERRE = '"+cIdUser+"'"
		endif
	endif
else
	Alert("Você não tem permissão para operar esta rotina!"+CRLF+"Solicite ao seu superior ou administrador que cadastre sua alçada do controle de propostas!")
	Return(.F.)
endif


if !empty(cFiltro)
	cFiltro+=" .AND. "
endif

//Filtro para a data
	cFiltro += "( DTOS(Z79_DTINC) >= '"+DTOS(MV_PAR01)+"' .AND. DTOS(Z79_DTINC) <= '"+DTOS(MV_PAR02)+"' )"

//Não exibir as propostas revisadas
If MV_PAR03 == 2
	cFiltro += " .AND. "
	cFiltro += " (Z79_STATUS <> '2')"
EndIf

//Não exibir as propostas recusadas
If MV_PAR04 == 2
	cFiltro += " .AND. "
	cFiltro += " (Z79_STATUS <> '4' .AND. Z79_STATUS <> '7')"
EndIf

//Não exibir as propostas aprovados
If MV_PAR05 == 2
	cFiltro += " .AND. "
	cFiltro += " (Z79_STATUS <> '5' .AND. Z79_STATUS <> '8' .AND. Z79_STATUS <> '9')"
EndIf

//Não exibir as propostas pendentes
If MV_PAR06 == 2
	cFiltro += " .AND. "
	cFiltro += " (Z79_STATUS <> '3' .AND. Z79_STATUS <> '6')"
EndIf


//Verifica se o filtro foi reformulado.                      
If lExibe
	// Deleta o filtro anterior utilizado na função FilBrowse
	EndFilBrw(cAlias,aIndexZ79)
	_oObj := GetObjBrow()
EndIf

//Determina o novo filtro
bFiltraBrw := {|| FilBrowse(cAlias,@aIndexZ79,@cFiltro)}

//Atualiza o MBrowse.
Eval(bFiltraBrw)

RestArea(cArea)

//(cAlias)->(DbGoTop())

	//Verifica se o filtro foi reformulado.
	If lExibe
		_oObj:Refresh() //Refresh na mBrowse
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
	If Empty(M->Z79_CLIENT) 
		SUS->(DbSeek(xFilial("SUS")+M->Z79_PROSPE))
		cNome:= SUS->US_NOME
	Else
		SA1->(DbSeek(xFilial("SA1")+M->Z79_CLIENT))
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
	
	MsgInfo("Foi gerada a Classe de valor: "+cNum)
Else 
	MsgInfo("Não foi possível gerar a Classe de Valor Automática. O código "+cNum)	

EndIf

Return