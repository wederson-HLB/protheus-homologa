#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTFIS001  �Autor  �Eduardo C. Romanini � Data �  23/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de lancamentos para o bloco F100 do sped Pis Cofins���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GT                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------*
User Function GTFIS001(xRotAuto,nOpcAuto)
*---------------------------------------*
Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z95')
	oBrowse:SetDescription('Lan�amentos manuais dos registros F100 - Sped Pis Cofins')
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
Return FWMVCMenu("GTFIS001")

//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan�amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*
Local oStruZ95 := FWFormStruct( 1, 'Z95') 
Local oModel

//Monta o modelo do formul�rio
oModel:= MPFormModel():New('FIS001M')

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields('Z95MASTER',,oStruZ95) 

oModel:SetPrimaryKey({})

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( 'Modelo de dados dos Lan�amentos do bloco F100')

// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'Z95MASTER' ):SetDescription( 'Dados dos Lan�amentos do bloco F100' )

//Valida��o para ativa��o do modelo.
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
Fun��o  : PreFis001
Objetivo: Reaizar a pr� valida��o do cadastro
Autor   : Eduardo C. Romanini
Data    : 27/03/2012 14:30
*/
*-------------------------------*
Static Function PreFis001(oModel)
*-------------------------------*
Local lRet    := .T.
Local lVldDel := GetNewPar("MV_GT_F100",.F.)

Local nOper := oModel:GetOperation()

//Valida��o para 
If nOper == MODEL_OPERATION_DELETE .or. nOper == MODEL_OPERATION_UPDATE

	//Verifica se os registros podem ser alterados ap�s o periodo de entrega.	
	If !lVldDel
			
		If DateDiffMonth( DaySum(dDataBase,7), Z95->Z95_DATA ) > 2
			Help( ,, 'Help',, 'A data de entrega desse registro expirou. Ele n�o poder� ser editado.', 1, 0 )	
			lRet := .F.
		EndIf
			
    EndIf
	
EndIf

Return lRet