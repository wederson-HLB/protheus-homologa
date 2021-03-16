#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FWMVCDEF.CH"

#Define ENTER CHR(13)+CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Programa  * GTFIN030.PRW *                                              ³±?
±±?Autor     * Guilherme Fernandes Pilan - GFP *                           ³±?
±±?Data      * 17/01/2017 - 14:27 *                                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao * Cadastro de Contas Ativas para Boletos. *                   ³±?
±±?          * Utilização nos fontes de geração de boletos Itau GTFIN024 * ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       * FINANCEIRO                                                  ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     
*--------------------------*
User Function GTFIN030()
*--------------------------*
Local oBrowse
Private aCores := {{"BR_VERDE"	, 'Conta Corrente com período aberto.'},;
				  {"BR_VERMELHO", 'Conta Corrente com período fechado.'}}

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("Z18")
oBrowse:SetMenuDef("GTFIN030")
oBrowse:SetDescription("Cadastro de Contas Bancárias para Boletos")
oBrowse:AddLegend("Empty(Z18_DTFIM)" , aCores[1][1] , aCores[1][2])
oBrowse:AddLegend("!Empty(Z18_DTFIM)", aCores[2][1] , aCores[2][2])
oBrowse:Activate()

Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina  := {}

aAdd( aRotina, { 'Visualizar',	'VIEWDEF.GTFIN030', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'	 ,	'VIEWDEF.GTFIN030', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'	 ,	'VIEWDEF.GTFIN030', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'	 ,	'VIEWDEF.GTFIN030', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Legendas'	 ,	'U_GTF30LEN()'		  , 0, 8, 0, NIL } )

Return aRotina

*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ18 := FWFormStruct( 1, 'Z18' )
Local oModel
//Local bPreValid := {|a,b,c| PreValidacao(a,b,c)} 
Local bPosValid := {|a| PosValidacao(a)} 

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('COMP011M' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'Z18MASTER', /*cOwner*/, oStruZ18, /*bPreValid*/, bPosValid) 

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( "Cadastro de Contas Bancárias para Boletos" )

// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'Z18MASTER' ):SetDescription( "Cadastro de Contas Bancárias para Boletos" )

// Informa chave primaria
oModel:SetPrimaryKey( {} )

// Retorna o Modelo de dados
Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel := ModelDef() //FWLoadModel( 'COMP011M' )
Local oStruZ18 := FWFormStruct( 2, 'Z18' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )

// Adiciona os campos em tela
oView:AddField( 'VIEW_Z18', oStruZ18, 'Z18MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_Z18', 'TELA' )

//Liga a identificação do componente
oView:EnableTitleView("VIEW_Z18", "Cadastro de Contas Bancárias para Boletos", RGB(240,248,255)) 

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:EnableControlBar(.T.)

// Retorna o objeto de View criado
Return oView

*-----------------------------------*
Static Function PosValidacao(oModel)
*-----------------------------------*
Local lRet := .T.
Local oModel := FWModelActive()
Local nOperacao := oModel:GetOperation()
Local aOrd := SaveOrd("Z18")
Local cChave := xFilial("Z18")+oModel:GetValue("Z18MASTER", "Z18_EMP")+oModel:GetValue("Z18MASTER", "Z18_FILEMP")
Local cBanco := oModel:GetValue("Z18MASTER", "Z18_BANCO")

If nOperacao == 3
   DbSelectarea("Z18")
   DbSetOrder(1)
   If DbSeek(cChave)
   		Do While Z18->(!Eof()) .AND. Z18->(Z18_FILIAL+Z18_EMP+Z18_FILEMP) == cChave
   			If Empty(Z18->Z18_DTFIM) .AND. Z18->Z18_BANCO == cBanco
   				EasyHelp("Existe um Banco/Agencia/Conta cadastrado com período aberto para esta Empresa/Filial." + ENTER +;
   					 	 "É necessário preencher a Data Final no registro em questão para que possa incluir um novo.")
   				lRet := .F.
   			EndIf
   			Z18->(DbSkip())
   		EndDo
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return lRet

*-----------------------*
User Function GTF30LEN()
*-----------------------*
Return BrwLegenda("Contas Bancárias para Boletos", 'Legendas', aCores)