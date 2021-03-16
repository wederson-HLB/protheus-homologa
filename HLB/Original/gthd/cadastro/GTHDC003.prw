#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC003  �Autor  �Tiago Luiz Mendon�a � Data �  20/07/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de colaboradores x superior                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Help Desk                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------*
User Function GTHDC003(xRotAuto,nOpcAuto)
*---------------------------------------*

Local oBrowse

If xRotAuto == Nil
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z05')
	oBrowse:SetDescription('Colaboradores')
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

Return FWMVCMenu("GTHDC003")


//-------------------------------------------------------------------
// ModelDef - Modelo de dados do lan�amento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*

Local oStruZ05 := FWFormStruct( 1, 'Z05') 

Local oModel                        

Local bOK:={|| ValUser("Z05") }

//Monta o modelo do formul�rio
oModel:= MPFormModel():New('HDC003M',,bOk)

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields('Z05MASTER',,oStruZ05) 

oModel:SetPrimaryKey({})

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( 'Modelo de dados de colaboradores')

// Adiciona a descri��o do Componente do Modelo de Dados
oModel:GetModel( 'Z05MASTER' ):SetDescription( 'Dados Colaboradores' )

Return(oModel) 
  
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados
//-------------------------------------------------------------------
*------------------------*
Static Function ViewDef()
*------------------------*
Local oView
Local oModel   := FWLoadModel('GTHDC003')
Local oStruZ05 := FWFormStruct( 2, 'Z05') 

oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField('VIEWZ05',oStruZ05,'Z05MASTER')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEWZ05","TELA")

Return oView

                                        

/*
Funcao      : ValUser()
Objetivos   : Valida usu�rio na grava��o do usu�rio
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 05/07/2012
*/
*--------------------------------*
  Static Function ValUser(cAlias)
*--------------------------------* 
 
Local nPos   := 0     
Local cEmail := "" 
Local aUsers 
Local lRet   := .T.

If cAlias == "Z05"
                      
    //Carrega todos usu�rios.
    aUsers := AllUsers() 
            
	//Busca a posi��o do usu�rio no array
	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
		cEmail := aUsers[nPos,1,14]
	EndIf    
          
 	//Verifica se o usu�rio est� alterando, incluindo ou deletando seu proprio usu�rio.
	If Alltrim(Z05->Z05_EMAIL) <> Alltrim(UPPER	(cEmail)) 
		//Se n�o for supervisor n�o pode alterar                   	
    	Z05->(DbSetOrder(1))
    	IF Z05->(DbSeek(xFilial("Z05")+Alltrim(UPPER(cEmail))))	
	    	If Alltrim(Z05->Z05_CARGO) <> "05" .And. Alltrim(Z05->Z05_CARGO) <> "04" 
	    		MsgStop("Acesso n�o permetido","Grant Thornton")                          
	        	lRet:=.F.   
	    	EndIf    	
		EndIf
	EndIf


EndIf

Return  lRet


	