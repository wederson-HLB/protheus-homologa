#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC006  �Autor  �Tiago Luiz Mendon�a � Data �  07/11/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Empresa x Colaboradores                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Help Desk                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------*
User Function GTHDC006(xRotAuto,nOpcAuto)
*---------------------------------------*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z08')
	oBrowse:SetDescription('Empresa x Colaboradores')
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
Return FWMVCMenu("GTHDC006")


//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan�amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ08 := FWFormStruct( 1, 'Z08') 
Local oModel

//Monta o modelo do formul�rio
oModel:= MPFormModel():New('HDC006M')

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields('Z08MASTER',,oStruZ08) 

oModel:SetPrimaryKey({})

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( 'Modelo de dados Empresa x Colaboradores')

// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'Z08MASTER' ):SetDescription( 'Empresa x Colaboradores' )

Return(oModel) 
  
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*
Local oView
Local oModel   := FWLoadModel('GTHDC006')
Local oStruZ08 := FWFormStruct( 2, 'Z08') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ08',oStruZ08,'Z08MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ08","TELA")

Return oView

