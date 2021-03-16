#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC004  �Autor  �Tiago Luiz Mendon�a � Data �  20/07/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de informativos                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Help Desk                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------*
User Function GTHDC004(xRotAuto,nOpcAuto)
*---------------------------------------*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z06')
	oBrowse:SetDescription('Informativo')
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
Return FWMVCMenu("GTHDC004")


//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan�amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ06 := FWFormStruct( 1, 'Z06') 
Local oModel

//Monta o modelo do formul�rio
oModel:= MPFormModel():New('HDC004M')

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields('Z06MASTER',,oStruZ06) 

oModel:SetPrimaryKey({})

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( 'Modelo de dados Informativo')

// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'Z06MASTER' ):SetDescription( 'Informativo' )

Return(oModel) 
  
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*
Local oView
Local oModel   := FWLoadModel('GTHDC004')
Local oStruZ06 := FWFormStruct( 2, 'Z06') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ06',oStruZ06,'Z06MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ06","TELA")

Return oView

