#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC005  �Autor  �Tiago Luiz Mendon�a � Data �  07/11/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de timesheet                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Help Desk                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------*
User Function GTHDC005(xRotAuto,nOpcAuto)
*---------------------------------------*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z07')
	oBrowse:SetDescription('Timesheet')
	oBrowse:Activate()
Else  
	MsgInfo("Essa rotina n�o possui suporte para ExecAuto.")
Endif

Return Nil  

//-------------------------------------------------------------------
// Menu Funcional
//-------------------------------------------------------------------
*-----------------------*
Static Function MenuDef()
*-----------------------*
Return FWMVCMenu("GTHDC005")


//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan�amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ07 := FWFormStruct( 1, 'Z07') 
Local oModel

//Monta o modelo do formul�rio
oModel:= MPFormModel():New('HDC005M')

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields('Z07MASTER',,oStruZ07) 

oModel:SetPrimaryKey({})

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( 'Modelo de dados Timesheet')

// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'Z07MASTER' ):SetDescription( 'Timesheet' )

Return(oModel) 
  
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*
Local oView
Local oModel   := FWLoadModel('GTHDC005')
Local oStruZ07 := FWFormStruct( 2, 'Z07') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ07',oStruZ07,'Z07MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ07","TELA")

Return oView

