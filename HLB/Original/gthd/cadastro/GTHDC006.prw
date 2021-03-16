#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGTHDC006  บAutor  ณTiago Luiz Mendon็a บ Data ณ  07/11/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEmpresa x Colaboradores                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Help Desk                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
	MsgInfo("Essa rotina nใo possui suporte para ExecAuto.")
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
// ModelDef - Modelo de dados do lan็amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ08 := FWFormStruct( 1, 'Z08') 
Local oModel

//Monta o modelo do formulแrio
oModel:= MPFormModel():New('HDC006M')

// Adiciona ao modelo um componente de formulแrio
oModel:AddFields('Z08MASTER',,oStruZ08) 

oModel:SetPrimaryKey({})

// Adiciona a descri็ใo do Modelo de Dados
oModel:SetDescription( 'Modelo de dados Empresa x Colaboradores')

// Adiciona a descri็ใo do Componente do Modelo de Dados
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

