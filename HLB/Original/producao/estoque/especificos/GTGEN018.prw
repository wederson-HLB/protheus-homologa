#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGTGEN018  บAutor  ณTiago Luiz Mendon็a บ Data ณ  06/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de descri็ใo de armaz้m                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HLB BRASIL                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     


/*
Funcao      : GTGEN018 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastrar descri็ใo de armaz้m
Autor       : Tiago Luiz Mendon็a
Data        : 06/09/2013
TDN         : 
M๓dulo      : Estoque.
Clientes    : Todos
*/
   
*---------------------------------------*
User Function GTGEN018(xRotAuto,nOpcAuto)
*---------------------------------------*

/*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z36')
	oBrowse:SetDescription('Armazens')
	oBrowse:Activate()
Else  
	MsgInfo("Essa rotina nใo possui suporte para ExecAuto.")
Endif
 */ 
 
 aXcadastro("Z36","Cadastro de armaz้ns")
 
Return Nil  

//-------------------------------------------------------------------
// Menu Funcional
//-------------------------------------------------------------------
*-----------------------*
Static Function MenuDef()
*-----------------------*   

Return FWMVCMenu( "GTGEN018" )


//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan็amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*

Local oStruZ36 := FWFormStruct( 1, 'Z36') 
Local oModel

//Monta o modelo do formulแrio
oModel:= MPFormModel():New('GEN018')

// Adiciona ao modelo um componente de formulแrio
oModel:AddFields('Z36MASTER',,oStruZ36) 

oModel:SetPrimaryKey({})

// Adiciona a descri็ใo do Modelo de Dados
oModel:SetDescription( 'Modelo de dados dos Armazens')

// Adiciona a descri็ใo do Componente do Modelo de Dados
oModel:GetModel( 'Z36MASTER' ):SetDescription( 'Armazens' )

Return(oModel) 
  
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*

Local oView
Local oModel   := FWLoadModel('GTGEN018')
Local oStruZ36 := FWFormStruct( 2, 'Z36') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ36',oStruZ36,'Z36MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ36","TELA")

Return oView