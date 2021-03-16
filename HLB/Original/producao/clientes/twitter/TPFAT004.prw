//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
Funcao      : TPFAT004
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Altera��o da tabela SX5(S�rie)
Autor       : Renato Rezende 
Cliente		: Twitter
Data/Hora   : 14/08/2017
*/ 
*-------------------------*   
 User Function TPFAT004()
*-------------------------*
Local aArea   := GetArea()
Local oBrowse

Private cTabela:= "01"	
Private cTabX := cTabela
Private cTitulo:= ""


If !cEmpAnt $ "TP"
	MsgInfo("Empresa n�o autorizada para utilizar essa rotina!","HLB BRASIL")
	Return nil
EndIf
//Sen�o tiver chave, finaliza	
If Empty(cTabela)
	Return nil
EndIf

DbSelectArea('SX5')
SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->(DbGoTop())

//Se conseguir posicionar
If SX5->(DbSeek(FWxFilial("SX5") + "00" + cTabela))
	cTitulo := SX5->X5_DESCRI
	
Else
	MsgAlert("Tabela SX5 n�o encontrada!", "HLB BRASIL")
	Return
EndIf

oBrowse := FWMBrowse():New()

//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias("SX5")

//Setando a descri��o da rotina
oBrowse:SetDescription(cTitulo)

//Filtrando apenas a serie que deve ser alterada
oBrowse:SetFilterDefault("SX5->X5_TABELA = '"+cTabela+"' .AND. SX5->X5_CHAVE = 'UNI' ")

//Desabilitar o filtro e navegador da tela
oBrowse:SetUseCursor(.F.)

//Ativa a Browse
oBrowse:Activate()
oBrowse:DeActivate()
oBrowse:Destroy()
oBrowse := Nil

RestArea(aArea)
Return nil

/*
Funcao		: MenuDef
Objetivo	: Cria��o do menu MVC
Autor		: Renato Rezende
*/
*--------------------------------*
 Static Function MenuDef()
*--------------------------------*
Local aRot := {}

//Adicionando op��es
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.TPFAT004' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
//ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.TPFAT004' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.TPFAT004' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.TPFAT004' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*
Funcao		: ModelDef
Objetivo	: Cria��o do modelo de dados MVC
Autor		: Renato Rezende
*/
*--------------------------------*
 Static Function ModelDef()
*--------------------------------*
Local oModel := Nil
Local oStSX5 := FWFormStruct(1, "SX5")	

//Editando caracter�sticas do dicion�rio
oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edi��o
oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabX'))                     //Ini Padr�o
oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edi��o
oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigat�rio
oStSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigat�rio
	
//Instanciando o modelo, n�o � recomendado colocar nome da user function
oModel := MPFormModel():New("TPFAT04M",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 

//Atribuindo formul�rios para o modelo
oModel:AddFields("FORMSX5",/*cOwner*/,oStSX5)

//Setando a chave prim�ria da rotina
oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})

//Adicionando descri��o ao modelo
oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

//Setando a descri��o do formul�rio
oModel:GetModel("FORMSX5"):SetDescription("Formul�rio do Cadastro "+cTitulo)

//Validando para abrir ativar o omodel
oModel:SetVldActivate({ |oModel| ValidMVC( oModel ) }) 

Return oModel

/*
Funcao		: ViewDef
Objetivo	: Cria��o da vis�o MVC
Autor		: Renato Rezende
*/
*--------------------------------*
 Static Function ViewDef()
*--------------------------------*
Local oModel := FWLoadModel("TPFAT004")
Local oStSX5 := FWFormStruct(2, "SX5", {|x|Alltrim(x) $ 'X5_TABELA|X5_CHAVE|X5_DESCRI|'})  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SX5_NOME|SX5_DTAFAL|'}
Local oView := Nil

//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formul�rios para interface
oView:AddField("VIEW_SX5", oStSX5, "FORMSX5")

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_SX5', 'Dados - '+cTitulo )  

//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView("VIEW_SX5","TELA")

//Retira o campo de tabela da visualiza��o
oStSX5:RemoveField("X5_TABELA") 

Return oView

/*
Funcao		: ValidMVC
Parametro	: oModel
Retorno		: lRet
Objetivo	: Valida��o da tela MVC
Autor		: Renato Rezende
*/
*----------------------------------------*
 Static Function ValidMVC( oModel )
*----------------------------------------*
Local nOperation := oModel:GetOperation()
Local lRet := .T.


If Alltrim(SX5->X5_TABELA) <> '01' .OR. Alltrim(SX5->X5_CHAVE) <> 'UNI'
	lRet:= .F.
EndIf 


If !lRet
	Help( ,, 'HELP',, 'Tabela gen�rica n�o pode ser alterada!', 1, 0)
EndIf

Return lRet