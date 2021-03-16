//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
 
//Variáveis Estáticas
Static cTitulo := "Pedido de Venda MVC (Mod.x)"
/*
Funcao      : TPFAT005
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Alteração dos pedidos integrados via FTP
Autor       : Renato Rezende 
Cliente		: Twitter
Data/Hora   : 14/08/2017
*/ 
*-------------------------*   
 User Function TPFAT005()
*-------------------------------*
Local aArea   := GetArea()
Local oBrowse
     
//Instânciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse():New()
     
//Setando a tabela de Pedido de Venda
oBrowse:SetAlias("SC5")
 
//Setando a descrição da rotina
oBrowse:SetDescription(cTitulo)
     
//Legendas
oBrowse:AddLegend( "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)", "GREEN",    "Aberto" )
oBrowse:AddLegend( "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)", "RED",    "Faturado" )
oBrowse:AddLegend( "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)", "BR_AMARELO",    "Liberado" )
oBrowse:AddLegend( "C5_BLQ == '1'", "BR_AZUL",    "Bloqueio por regra" )
oBrowse:AddLegend( "C5_BLQ == '2'", "BR_LARANJA",    "Bloqueio por verba" )
                  
//Desabilitar o filtro e navegador da tela
oBrowse:SetUseCursor(.F.)
     
//Ativa a Browse
oBrowse:Activate()
oBrowse:DeActivate()
oBrowse:Destroy()
oBrowse := Nil
    
RestArea(aArea)

Return Nil

/*
Funcao		: MenuDef
Objetivo	: Criação do menu MVC
Autor		: Renato Rezende
*/
*---------------------------------* 
 Static Function MenuDef()
*---------------------------------* 
Local aRot := {}
     
//Adicionando opções
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.TPFAT005' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_TPFATLeg'     OPERATION 6                      ACCESS 0 //OPERATION X
//ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.TPFAT005' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.TPFAT005' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.TPFAT005' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*
Funcao		: ModelDef
Objetivo	: Criação do modelo de dados MVC
Autor		: Renato Rezende
*/
*---------------------------------*
 Static Function ModelDef()
*---------------------------------*
Local oModel		:= Nil
Local oStPai		:= FWFormStruct(1, 'SC5')
Local oStFilho		:= Nil
Local oStNeto		:= FWFormStruct(1, 'ZX1')

Local aSC6Rel		:= {}
Local aZX1Rel		:= {}

oStFilho:= FWFormStruct(1, 'SC6',{|x|	Alltrim(x)=='C6_ITEM'   	.OR.;
										Alltrim(x)=='C6_PRODUTO'	.OR.;
										Alltrim(x)=='C6_P_NUM'		.OR.;
										Alltrim(x)=='C6_P_NOME'		.OR.;
										Alltrim(x)=='C6_P_REF'		.OR.;
										Alltrim(x)=='C6_P_AGEN'			})

//Editando dicionário SC5
oStPai:SetProperty('C5_NUM',		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição  
oStPai:SetProperty('C5_TIPO',		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição  
oStPai:SetProperty('C5_CLIENTE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição  
oStPai:SetProperty('C5_LOJACLI',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição  
oStPai:SetProperty('C5_P_NUM',    	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição 

//Editando dicionário SC6
oStFilho:SetProperty('C6_ITEM',		MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
oStFilho:SetProperty('C6_PRODUTO',	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
oStFilho:SetProperty('C6_P_NUM',	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
oStFilho:SetProperty('C6_P_REF',	MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição

//Editando dicionário ZX1
oStNeto:SetProperty('ZX1_ID',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
oStNeto:SetProperty('ZX1_NAME',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
oStNeto:SetProperty('ZX1_NAMEF', MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.T.'))     //Modo de Edição
oStNeto:SetProperty('ZX1_P_NUM', MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
oStNeto:SetProperty('ZX1_P_REF', MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))     //Modo de Edição
     
//Criando o modelo e os relacionamentos
oModel := MPFormModel():New('TPFAT05M')

oModel:AddFields('SC5MASTER',/*cOwner*/,oStPai)

//Adiciona ao modelo uma componente de grid 
oModel:AddGrid('SC6DETAIL','SC5MASTER',oStFilho)
oModel:AddGrid('ZX1DETAIL','SC6DETAIL',oStNeto) 
     
//Fazendo o relacionamento entre o Pai e Filho
aAdd(aSC6Rel, {'C6_FILIAL', 'C5_FILIAL'} )
aAdd(aSC6Rel, {'C6_NUM',    'C5_NUM'})
    
//Fazendo o relacionamento entre o Filho e Neto
aAdd(aZX1Rel, {'ZX1_P_NUM', 'C6_P_NUM'} ) 
aAdd(aZX1Rel, {'ZX1_P_REF', 'C6_P_REF'} )   

oModel:SetRelation('SC6DETAIL', aSC6Rel, SC6->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
oModel:SetPrimaryKey({})
    
oModel:SetRelation('ZX1DETAIL', aZX1Rel, ZX1->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
oModel:SetPrimaryKey({})
     
//Setando as descrições
oModel:SetDescription("Pedido de venda - Mod. x")
oModel:GetModel('SC5MASTER'):SetDescription('Cabeçalho')
oModel:GetModel('SC6DETAIL'):SetDescription('Itens')
oModel:GetModel('ZX1DETAIL'):SetDescription('Campanha')

//Bloqueando as Grids
//Não insere linha
oModel:GetModel('SC6DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('ZX1DETAIL'):SetNoInsertLine(.T.)
//Não deleta linha
oModel:GetModel('ZX1DETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('SC6DETAIL'):SetNoDeleteLine(.T.)

//Validando para abrir ativar o omodel
oModel:SetVldActivate({ |oModel| ValidMVC( oModel ) }) 

Return oModel


/*
Funcao		: ViewDef
Objetivo	: Criação da visão MVC
Autor		: Renato Rezende
*/
*-------------------------------* 
 Static Function ViewDef()
*-------------------------------*
Local oView			:= Nil
Local oModel		:= FWLoadModel('TPFAT005')
Local oStPai		:= Nil
Local oStFilho		:= Nil
Local oStNeto		:= Nil

oStPai:= FWFormStruct(2, 'SC5',{|x|		Alltrim(x)=='C5_NUM'   		.OR.;
										Alltrim(x)=='C5_TIPO'  		.OR.;
										Alltrim(x)=='C5_CLIENTE'	.OR.;
										Alltrim(x)=='C5_LOJACLI'	.OR.;
										Alltrim(x)=='C5_P_NUM'		.OR.;
										Alltrim(x)=='C5_P_PO'		.OR.;
										Alltrim(x)=='C5_P_EMAIL'	.OR.;
										Alltrim(x)=='C5_P_EMAI1'	.OR.;
										Alltrim(x)=='C5_P_EMAI2'	.OR.;
										Alltrim(x)=='C5_P_EMAI3'		})

oStFilho:= FWFormStruct(2, 'SC6',{|x|	Alltrim(x)=='C6_ITEM'   	.OR.;
										Alltrim(x)=='C6_PRODUTO'	.OR.;
										Alltrim(x)=='C6_P_NUM'		.OR.;
										Alltrim(x)=='C6_P_NOME'		.OR.;
										Alltrim(x)=='C6_P_REF'		.OR.;
										Alltrim(x)=='C6_P_AGEN'			})
									
oStNeto:= FWFormStruct(2, 'ZX1',{|x|	Alltrim(x)=='ZX1_ID'   		.OR.;
								 		Alltrim(x)=='ZX1_NAME'  	.OR.;
								 		Alltrim(x)=='ZX1_P_NUM'		.OR.;
								 		Alltrim(x)=='ZX1_P_REF'		.OR.;
								 		Alltrim(x)=='ZX1_NAMEF'			})
    
//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)
     
//Adicionando os campos do cabeçalho e o grid dos filhos
oView:AddField('VIEW_SC5',oStPai,'SC5MASTER')
oView:AddGrid('VIEW_SC6',oStFilho,'SC6DETAIL')
oView:AddGrid('VIEW_ZX1',oStNeto,'ZX1DETAIL')
    
//Setando o dimensionamento de tamanho
oView:CreateHorizontalBox('CABEC',35)
oView:CreateHorizontalBox('GRID',25) 
oView:CreateHorizontalBox('GRID2',40)
     
//Amarrando a view com as box
oView:SetOwnerView('VIEW_SC5','CABEC')
oView:SetOwnerView('VIEW_SC6','GRID')
oView:SetOwnerView('VIEW_ZX1','GRID2')

     
//Habilitando título
oView:EnableTitleView('VIEW_SC5','Capa')
oView:EnableTitleView('VIEW_SC6','Item') 
oView:EnableTitleView('VIEW_ZX1','Campanha')

//Força o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView

/*
Funcao		: TPFATLeg
Objetivo	: Legenda da tela MVC
Autor		: Renato Rezende
*/
*------------------------------*
User Function TPFATLeg()
*------------------------------*
Local aLegenda := {}
	
//Monta as cores
AADD(aLegenda,{"BR_VERDE",		"Aberto"  })
AADD(aLegenda,{"BR_VERMELHO",	"Faturado"})
AADD(aLegenda,{"BR_AMARELO",	"Liberado"})
AADD(aLegenda,{"BR_AZUL",		"Bloqueio por Regra"})
AADD(aLegenda,{"BR_LARANJA",	"Bloqueio por Verba"})
	
BrwLegenda("Legenda", "Status do Pedido", aLegenda)

Return nil 

/*
Funcao		: ValidMVC
Parametro	: oModel
Retorno		: lRet
Objetivo	: Legenda da tela MVC
Autor		: Renato Rezende
*/
*----------------------------------------*
 Static Function ValidMVC( oModel )
*----------------------------------------*
Local nOperation := oModel:GetOperation()
Local lRet := .T.

If nOperation == MODEL_OPERATION_UPDATE
	//Não veio via integração
	If Empty(SC5->C5_P_NUM) .OR. Alltrim(SC5->C5_P_INT) <> 'S'
		lRet:= .F.
	EndIf 
	//Já faturado
	/*If (!Empty(SC5->C5_NOTA).OR.SC5->C5_LIBEROK=='E' .AND. Empty(SC5->C5_BLQ))
		lRet:= .F.
	EndIf*/
EndIf

If !lRet
	Help( ,, 'HELP',, 'Pedido não pode ser alterado!', 1, 0)
EndIf

Return lRet