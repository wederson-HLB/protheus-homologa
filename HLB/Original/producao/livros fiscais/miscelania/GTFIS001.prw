#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTFIS001  ºAutor  ³Eduardo C. Romanini º Data ³  23/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de lancamentos para o bloco F100 do sped Pis Cofinsº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------------------*
User Function GTFIS001(xRotAuto,nOpcAuto)
*---------------------------------------*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z95')
	oBrowse:SetDescription('Lançamentos manuais dos registros F100 - Sped Pis Cofins')
	oBrowse:Activate()
Else  
	MsgInfo("Essa rotina não possui suporte para ExecAuto.")
Endif

Return Nil  

//-------------------------------------------------------------------
// Menu Funcional
//-------------------------------------------------------------------
*-----------------------*
Static Function MenuDef()
*-----------------------*
Return FWMVCMenu("GTFIS001")

//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lançamento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ95 := FWFormStruct( 1, 'Z95') 
Local oModel

//Monta o modelo do formulário
oModel:= MPFormModel():New('FIS001M')

// Adiciona ao modelo um componente de formulário
oModel:AddFields('Z95MASTER',,oStruZ95) 

oModel:SetPrimaryKey({})

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Modelo de dados dos Lançamentos do bloco F100')

// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'Z95MASTER' ):SetDescription( 'Dados dos Lançamentos do bloco F100' )

//Validação para ativação do modelo.
oModel:SetVldActivate( { |oModel| PreFis001( oModel ) })

Return(oModel) 

//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*
Local oView
Local oModel   := FWLoadModel('GTFIS001')
Local oStruZ95 := FWFormStruct( 2, 'Z95') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ95',oStruZ95,'Z95MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ95","TELA")

Return oView

/*
Função  : PreFis001
Objetivo: Reaizar a pré validação do cadastro
Autor   : Eduardo C. Romanini
Data    : 27/03/2012 14:30
*/
*-------------------------------*
Static Function PreFis001(oModel)
*-------------------------------*
Local lRet    := .T.
Local lVldDel := GetNewPar("MV_GT_F100",.F.)

Local nOper := oModel:GetOperation()

//Validação para 
If nOper == MODEL_OPERATION_DELETE .or. nOper == MODEL_OPERATION_UPDATE

	//Verifica se os registros podem ser alterados após o periodo de entrega.	
	If !lVldDel
			
		If DateDiffMonth( DaySum(dDataBase,7), Z95->Z95_DATA ) > 2
			Help( ,, 'Help',, 'A data de entrega desse registro expirou. Ele não poderá ser editado.', 1, 0 )	
			lRet := .F.
		EndIf
			
    EndIf
	
EndIf

Return lRet