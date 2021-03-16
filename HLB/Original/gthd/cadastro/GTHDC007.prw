#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC007  �Autor  �Eduardo C. Romanini � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro do relacionamento entre Ambientes e Servidores.    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Help Desk                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------*
User Function GTHDC007(xRotAuto,nOpcAuto)
*---------------------------------------*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z10')
	oBrowse:SetDescription('Ambientes X Servidores')
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
Return FWMVCMenu("GTHDC007")


//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan�amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ10 := FWFormStruct( 1, 'Z10') 
Local oModel

//Monta o modelo do formul�rio
oModel:= MPFormModel():New('HDC007M')

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields('Z10MASTER',,oStruZ10) 

oModel:SetPrimaryKey({})

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( 'Modelo de dados de Ambientes X Servidores')

// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'Z10MASTER' ):SetDescription( 'Dados de Ambientes X Servidores' )

Return(oModel) 
  
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*
Local oView
Local oModel   := FWLoadModel('GTHDC007')
Local oStruZ10 := FWFormStruct( 2, 'Z10') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ10',oStruZ10,'Z10MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ10","TELA")

Return oView

