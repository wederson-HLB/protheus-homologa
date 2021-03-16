#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDC003  ºAutor  ³Tiago Luiz Mendonça º Data ³  20/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de colaboradores x superior                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Help Desk                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	MsgInfo("Essa rotina não possui suporte para ExecAuto.")
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
// ModelDef - Modelo de dados do lançamento dos registros
//-------------------------------------------------------------------
*------------------------*
Static Function ModelDef()
*------------------------*

Local oStruZ05 := FWFormStruct( 1, 'Z05') 

Local oModel                        

Local bOK:={|| ValUser("Z05") }

//Monta o modelo do formulário
oModel:= MPFormModel():New('HDC003M',,bOk)

// Adiciona ao modelo um componente de formulário
oModel:AddFields('Z05MASTER',,oStruZ05) 

oModel:SetPrimaryKey({})

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Modelo de dados de colaboradores')

// Adiciona a descrição do Componente do Modelo de Dados
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
Objetivos   : Valida usuário na gravação do usuário
Autor       : Tiago Luiz Mendonça
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
                      
    //Carrega todos usuários.
    aUsers := AllUsers() 
            
	//Busca a posição do usuário no array
	nPos := ASCAN(aUsers,{|X| X[1,1] == __cUserId})
	If nPos > 0
		cEmail := aUsers[nPos,1,14]
	EndIf    
          
 	//Verifica se o usuário está alterando, incluindo ou deletando seu proprio usuário.
	If Alltrim(Z05->Z05_EMAIL) <> Alltrim(UPPER	(cEmail)) 
		//Se não for supervisor não pode alterar                   	
    	Z05->(DbSetOrder(1))
    	IF Z05->(DbSeek(xFilial("Z05")+Alltrim(UPPER(cEmail))))	
	    	If Alltrim(Z05->Z05_CARGO) <> "05" .And. Alltrim(Z05->Z05_CARGO) <> "04" 
	    		MsgStop("Acesso não permetido","Grant Thornton")                          
	        	lRet:=.F.   
	    	EndIf    	
		EndIf
	EndIf


EndIf

Return  lRet


	