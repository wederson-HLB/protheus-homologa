#Include "Protheus.ch"                      
#Include "FWBROWSE.CH"
#INCLUDE "TBICONN.CH" 

/*
Funcao      : U6GEN001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Importação de produtos, pedidos, estrutura (BOM)
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2016    14:26
Revisão		:
Data/Hora   : 
Módulo      : Estoque
-------------------------------------------------------------
Autor       : Wederson L. Santana
Data/Hora   : 29/09/2020    
Revisão		: IMportação de clientes com código de 10 posições.
Data/Hora   : 
Módulo      : Faturamento

*/

*---------------------*
User function U6GEN001
*---------------------*

Local aSize     := {}
Local aObjects	:= {}

Local oLayer 	:= FWLayer():New()

Private aPanel	:= {}
Private oDlg
Private oTButton2

Private oBrowP  
Private oBrowC
Private oBrowE
Private oBrowV
		
Private nMetSB1:= 0
Private oMetSB1
Private oSaySB1
Private nMetSA1:= 0
Private oMetSA1
Private oSaySA1
Private nMetSG1:= 0
Private oMetSG1
Private oSaySG1
Private nMetSC5:= 0
Private oMetSC5
Private oSaySC5

Private nMetSB12:= 0
Private oMetSB12
Private oSaySB12
Private nMetSGG:= 0
Private oMetSGG
Private oSaySGG

Private lChkSB1:= .T.
Private lChkSA1:= .F.
Private lChkSG1:= .T.
Private lChkSC5:= .T.

Private lChkSB12:= .T.
Private lChkSGG:= .T.

Private aFiles 		:= {}
Private lEnvEmail	:= .T. //Parametro que define se envia e-mail na integração de arquivos

Private xPreSel		:= ""
Private cLocalArq   := ""
// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()

AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)


    DEFINE DIALOG oDlg TITLE "Integracao " FROM aSize[7],0 To aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

		oFont:= TFont():New('Arial',,-14,,.f.)
        
		oLayer:init(oDlg,.F.,.T.)              

        oLayer:addCollumn('ESQ',15,.F.)
		oLayer:addCollumn('DIR',85,.F.)
        
        oLayer:addWindow('ESQ','WinEC','',20,.F.,.F.,{||  },,{||  })
		oLayer:addWindow('ESQ','WinEB','Opções',80,.F.,.F.,{||  },,{||  })
		
		oLayer:addWindow('DIR','WinDU','',100,.F.,.T.,{||  },,{|| })
        
		oWinEC := oLayer:getWinPanel('ESQ','WinEC')
		oWinEB := oLayer:getWinPanel('ESQ','WinEB')
		
		//oWinEU := oLayer:getWinPanel('ESQ','WinEU','UNICO')
		oWinDU := oLayer:getWinPanel('DIR','WinDU')
        
		oLayer:setColSplit('ESQ',CONTROL_ALIGN_RIGHT)
				
		//Botões
		oBtn1 := TBtnBmp2():New( 01,02,26,26,'FINAL',,,,{||oDlg:end()},oWinEC,,,.T. )
		oBtn1:cTooltip:="Sair"
        
		oTree := DbTree():New(01,0,360,260,oWinEB,{|| ShowItem(oTree:GetCargo()) },,.T.)
		
		//AADD(aPanel,CriaPain(oWinDU,"Integração","BMPPARAM",1))
		AADD(aPanel,CriaPain(oWinDU,"Parâmetros","ENGRENAGEM",1,3))
		AADD(aPanel,CriaPain(oWinDU,"Produtos","PMSTASK3",1,3))
		AADD(aPanel,CriaPain(oWinDU,"Estruturas","PMSTASK3",1,3))
		AADD(aPanel,CriaPain(oWinDU,"Clientes","PMSTASK3",1,3))
		AADD(aPanel,CriaPain(oWinDU,"Pedidos","PMSTASK3",1,3))

        // Início - Wederson L. Santana - 08/10/2020
		//AADD(aPanel,CriaPain(oWinDU,"Prod-DPE","PMSTASK3",1,3))
		//AADD(aPanel,CriaPain(oWinDU,"Estrut-DPE","PMSTASK3",1,3))
		// Fim - Wederson L. Santana - 08/10/2020
						
		CriaTemp()
				
		TlParame(aPanel[1])
		TlProd(aPanel[2])
		TlEstr(aPanel[3])
		TlClie(aPanel[4])
		TlPedi(aPanel[5])
				
		//TRBLOG->(DBCLEARFILTER())
		
    ACTIVATE DIALOG oDlg CENTERED ON INIT( ) 


Return

/*
Função para criar a árvore(tree) vinculado a um painel da direita
oBjt	: Objeto onde será criado o painel
cNome	: Descrição do item da árvore
cImg	: Imagem do item da árvore
nTipo	: Indica o nível que o item ou subitem será adicionado, sendo: 1=No mesmo nível ou 2=Abaixo
*/
*-------------------------------------------------------*
Static Function CriaPain(oBjt,cNome,cImg,nTipo,nQualTree)
*-------------------------------------------------------*
Local cPanel:= "o"+CriaTrab(NIL, .F.)

//Cria o painel com o mesmo nome do item da Tree
&(cPanel):= tPanel():New(01,01,"",oBjt,,,,,,100,100)
&(cPanel):align:= CONTROL_ALIGN_ALLCLIENT
&(cPanel):cReadVar:=cPanel

if nQualTree==1
	//Cria um item da tree com o nome do painel
	//oTree:AddItem(cNome,cPanel, cImg ,,,,nTipo) 

	oTree:AddTree(cNome,.T.,cImg,cImg,,,cPanel)
elseif nQualTree==2
	oTree:AddTreeItem(cNome,cImg,,cPanel)
else
	oTree:AddItem(cNome,cPanel, cImg ,,,,nTipo) 
endif

//oTree:AddTreeItem(cNome,cImg,,cPanel)

if len(aPanel)<>0
	&(cPanel):Hide()
endif

Return&(cPanel)


//Função para tornar visível o painel de acordo com o item da árvore posicionado
*------------------------------*
Static Function ShowItem(cItem)
*------------------------------*
Local nPos	:= 0 

for i:=1 to len(aPanel)
	
	if aPanel[i]:cReadVar==cItem
		aPanel[i]:Show()
	else
		aPanel[i]:Hide()
	endif
next

Return

//Cria as tabelas temporárias
*--------------------------*
Static function CriaTemp()
*--------------------------*
//-->INICIO - Tabela temporária 
Local aDadTemp	:= {}

AADD(aDadTemp,{"LSTATUS"	,"L",1,0})
AADD(aDadTemp,{"ID"			,"C",6,0})
AADD(aDadTemp,{"TAB"		,"C",3,0})
AADD(aDadTemp,{"USUARIO"	,"C",20,0})
AADD(aDadTemp,{"DATAGE"		,"D",8,0})
AADD(aDadTemp,{"HORA"		,"C",10,0})
AADD(aDadTemp,{"ARQUIVO"	,"C",40,0})
AADD(aDadTemp,{"LINHA"		,"C",20,0})
AADD(aDadTemp,{"LOG"		,"C",200,0})

//tabela temporária de produtos
if select("TRBSB1")>0
	TRBSB1->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSB1",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
IndRegua("TRBSB1",cIndex,"ID",,,"Selecionando Registro...")  

DbSelectArea("TRBSB1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//tabela temporária de clientes
if select("TRBSA1")>0
	TRBSA1->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSA1",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("TRBSA1",cIndex,"ID",,,"Selecionando Registro...")  

DbSelectArea("TRBSA1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//tabela temporária de estrutura de produtos
if select("TRBSG1")>0
	TRBSG1->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSG1",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("TRBSG1",cIndex,"ID",,,"Selecionando Registro...")  

DbSelectArea("TRBSG1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//tabela temporária de pedidos de venda
if select("TRBSC5")>0
	TRBSC5->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSC5",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("TRBSC5",cIndex,"ID",,,"Selecionando Registro...")  

DbSelectArea("TRBSC5")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

Return

//Tela para seleção dos arquivos, são os parâmetros para processamento
*------------------------------*
Static Function TlParame(oLocal)
*------------------------------*
Local cLocaSB1:="V:\Team\EBS Shared Prod\receivables\Brasil\PRODUCTS\PRODUCTS.TXT"
Local oGetSB1
Local oChkSB1

Local cLocaSA1:="V:\Team\EBS Shared Prod\receivables\Brasil\CUSTOMERS\CUSTOMERS.TXT"
Local oGetSA1
Local oChkSA1

Local cLocaSG1:="V:\Team\EBS Shared Prod\receivables\Brasil\BOM\BOM.TXT"
Local oGetSG1
Local oChkSG1

Local cLocaSC5:="V:\Team\EBS Shared Prod\receivables\Brasil\ORDERS\ORDERS.TXT"
Local oGetSC5
Local oChkSC5

Local oGetSB12
Local oChkSB12
Local cLocaSB12:=""

Local oGetSGG
Local oChkSGG
Local cLocaSGG:=""

oFontBtn:= TFont():New('Arial',,-16,.T.,.F.)

oGroup1:= tGroup():New(010,03,110,330,'Selecione os arquivos para integração - Esteiras:',oLocal,,,.T.)

oGroup3:= tGroup():New(130,03,250,730,'',oLocal,,,.T.)

oChkSB1 := TCheckBox():New(27,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSB1:bSetGet := {|| lChkSB1 }
oChkSB1:bLClicked := {|| lChkSB1:=!lChkSB1 }

@ 27,25 SAY "Arquivo de Produtos: " SIZE 100,10 OF oLocal PIXEL
oGetSB1:= TGet():New(25,100,{|u| if(PCount()>0,cLocaSB1:=u,cLocaSB1)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSB1')
oTButton := TButton():New( 25, 295, "...",oLocal,{||AbreArq(@cLocaSB1,oGetSB1)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

oGetSB1:Disable()

oChkSG1 := TCheckBox():New(47,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSG1:bSetGet := {|| lChkSG1 }
oChkSG1:bLClicked := {|| lChkSG1:=!lChkSG1 }

@ 47,25 SAY "Arquivo de Estrutura(BOM): " SIZE 100,10 OF oLocal PIXEL
oGetSG1:= TGet():New(45,100,{|u| if(PCount()>0,cLocaSG1:=u,cLocaSG1)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSG1')
oTButton := TButton():New( 45, 295, "...",oLocal,{||AbreArq(@cLocaSG1,oGetSG1)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
                 
oGetSG1:Disable()

oChkSA1 := TCheckBox():New(67,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSA1:bSetGet := {|| lChkSA1 }
oChkSA1:bLClicked := {|| lChkSA1:=!lChkSA1 }
oChkSA1:Disable()

@ 67,25 SAY "Arquivo de Clientes: " SIZE 100,10 OF oLocal PIXEL
oGetSA1:= TGet():New(65,100,{|u| if(PCount()>0,cLocaSA1:=u,cLocaSA1)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSA1')
oTButtonA1 := TButton():New( 65, 295, "...",oLocal,{||AbreArq(@cLocaSA1,oGetSA1)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
oTButtonA1:Disable()

oGetSA1:Disable()
                                            
oChkSC5 := TCheckBox():New(87,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSC5:bSetGet := {|| lChkSC5 }
oChkSC5:bLClicked := {|| lChkSC5:=!lChkSC5 }

@ 87,25 SAY "Arquivo de Pedido de Venda: " SIZE 100,10 OF oLocal PIXEL
oGetSC5:= TGet():New(85,100,{|u| if(PCount()>0,cLocaSC5:=u,cLocaSC5)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSC5')
oTButton := TButton():New( 85, 295, "...",oLocal,{||AbreArq(@cLocaSC5,oGetSC5)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

oGetSC5:Disable()

//--------------------------------Wederson 07/10
/*
oGroup2:= tGroup():New(12,360,110,730,'Selecione os arquivos para integração - DPE:',oLocal,,,.T.)

oChkSB12 := TCheckBox():New(27,370,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSB12:bSetGet := {|| lChkSB12 }
oChkSB12:bLClicked := {|| lChkSB12:=!lChkSB12 }

@ 27,400 SAY "Arquivo de Produtos: " SIZE 100,10 OF oLocal PIXEL
oGetSB12:= TGet():New(25,500,{|u| if(PCount()>0,cLocaSB12:=u,cLocaSB12)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSB12')
oTButton := TButton():New( 25, 700, "...",oLocal,{||AbreCSV(@cLocaSB12,oGetSB12)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

oGetSB12:Disable()

oChkSGG := TCheckBox():New(47,370,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSGG:bSetGet := {|| lChkSGG }
oChkSGG:bLClicked := {|| lChkSGG:=!lChkSGG }

@ 47,400 SAY "Arquivo de Estrutura(BOM): " SIZE 100,10 OF oLocal PIXEL
oGetSGG:= TGet():New(45,500,{|u| if(PCount()>0,cLocaSGG:=u,cLocaSGG)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSGG')
oTButton := TButton():New( 45, 700, "...",oLocal,{||fAbreCSV(@cLocaSGG,oGetSGG)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
                 
oGetSGG:Disable()

--------------- Fim

*/

oGroup4:= tGroup():New(270,360,330,730,'Iniciar o processo:',oLocal,,,.T.)

oTButton := TButton():New( 290, 650, " Integrar ",oLocal,{|| Controle(cLocaSB1,cLocaSA1,cLocaSG1,cLocaSC5) },55,20,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )

// O CSS abaixo irá inserir uma imagem posicionada à esquerda/superior do botão,     
//oTButton:SetCss("QPushButton{ background-image: url(rpo:SDUORDER.png);background-size: 80px 60px;"+; //Pasta
//                " background-repeat: none; margin: 1px;}")
oTButton :cTooltip = "Integrar"

nMetSB1 := 0
oSaySB1 := tSay():New(140,30,{||'Processando produtos ...'},oLocal,,,,,,.T.,,,100,20)
oMetSB1 := TMeter():New(150,25,{|u|if(Pcount()>0,nMetSB1:=u,nMetSB1)},100,oLocal,450,26,,.T.)

oMetSB1:Hide()
oSaySB1:Hide()

nMetSA1 := 0
oSaySA1 := tSay():New(165,30,{||'Processando clientes ...'},oLocal,,,,,,.T.,,,100,20)
oMetSA1 := TMeter():New(175,25,{|u|if(Pcount()>0,nMetSA1:=u,nMetSA1)},100,oLocal,450,26,,.T.)

oMetSA1:Hide()
oSaySA1:Hide()

nMetSG1 := 0
oSaySG1 := tSay():New(190,30,{||'Processando estrutura de produtos(BOM)...'},oLocal,,,,,,.T.,,,150,20)
oMetSG1 := TMeter():New(200,25,{|u|if(Pcount()>0,nMetSG1:=u,nMetSG1)},100,oLocal,450,26,,.T.)

oMetSG1:Hide()
oSaySG1:Hide()

nMetSC5 := 0
oSaySC5 := tSay():New(200,30,{||'Processando pedidos de venda...'},oLocal,,,,,,.T.,,,150,20)
oMetSC5 := TMeter():New(210,25,{|u|if(Pcount()>0,nMetSC5:=u,nMetSC5)},100,oLocal,450,26,,.T.)

oMetSC5:Hide()
oSaySC5:Hide()

/* Wederson

nMetSB12 := 0
oSaySB12 := tSay():New(140,30,{||'Processando produtos - DPE...'},oLocal,,,,,,.T.,,,100,20)
oMetSB12 := TMeter():New(150,25,{|u|if(Pcount()>0,nMetSB12:=u,nMetSB12)},100,oLocal,450,26,,.T.)

oMetSB12:Hide()
oSaySB12:Hide()

nMetSGG := 0
oSaySGG := tSay():New(190,30,{||'Processando estrutura de produtos - DPE...'},oLocal,,,,,,.T.,,,150,20)
oMetSGG := TMeter():New(200,25,{|u|if(Pcount()>0,nMetSGG:=u,nMetSGG)},100,oLocal,450,26,,.T.)

oMetSGG:Hide()
oSaySGG:Hide()

Wederson
*/

Return

//Função para controle do processamento, o que está marcado para ser executado
*-------------------------------------------------------------*
Static function Controle(cLocaSB1,cLocaSA1,cLocaSG1,cLocaSC5)
*-------------------------------------------------------------*
Local lRet		:= .F.
Local lTemMak   := .F.

aFiles:={} //Limpa o array que fica os arquivos para anexo

	if lChkSB1
		oMetSB1:Show()
		oSaySB1:Show()
		
		if !LeArquiv(cLocaSB1,"SB1")
			oMetSB1:Hide()
			oSaySB1:Hide()
		else
			lRet:=.T.
			AADD(aFiles,cLocaSB1)
		endif
		
		oBrowP:ExecuteFilter(.T.)
		oBrowP:Refresh()
		
		lTemMak:=.T.
	endif
	
	if lChkSA1

		oMetSA1:Show()
		oSaySA1:Show()
		
		if !LeArquiv(cLocaSA1,"SA1")
			oMetSA1:Hide()
			oSaySA1:Hide()
		else
			lRet:=.T.
			AADD(aFiles,cLocaSA1)
		endif
        
		oBrowC:ExecuteFilter(.T.)
		oBrowC:Refresh()		
	
		lTemMak:=.T.
	endif

	if lChkSG1

		oMetSG1:Show()
		oSaySG1:Show()
		
		if !LeArquiv(cLocaSG1,"SG1")
			oMetSG1:Hide()
			oSaySG1:Hide()
		else
			lRet:=.T.
			AADD(aFiles,cLocaSG1)
		endif
        
		oBrowE:ExecuteFilter(.T.)
		oBrowE:Refresh()		
		
		lTemMak:=.T.
	endif

	if lChkSC5

		oMetSC5:Show()
		oSaySC5:Show()
		
		if !LeArquiv(cLocaSC5,"SC5","SC6")
			oMetSC5:Hide()
			oSaySC5:Hide()
		else
			lRet:=.T.
			AADD(aFiles,cLocaSC5)
		endif
        
		oBrowV:ExecuteFilter(.T.)
		oBrowV:Refresh()		
		
		lTemMak:=.T.
	endif

    /*
	If lChkSB12
		oMetSB1:Show()
		oSaySB1:Show()
		
		If !LeArqDPE(cLocalArq,"SB1")
			oMetSB1:Hide()
			oSaySB1:Hide()
		Else
			lRet:=.T.
			AADD(aFiles,cLocalArq)
		Endif
		
		oBrowP:ExecuteFilter(.T.)
		oBrowP:Refresh()
		
		lTemMak:=.T.
	EndIf

	If lChkSGG

		oMetSGG:Show()
		oSaySGG:Show()
		
		If !LeArqDPE(cLocalArq,"SGG")
			oMetSGG:Hide()
			oSaySGG:Hide()
		Else
			lRet:=.T.
			AADD(aFiles,cLocalArq)
		EndIf
        
		oBrowE:ExecuteFilter(.T.)
		oBrowE:Refresh()		
		
		lTemMak:=.T.
	EndIf
	*/

if !lTemMak
	AVISO("Atenção", "Nenhuma opção selecionada", { "OK"}, 1)	
endif

if lRet

	
	SEndMail(,,,aFiles)	


	AVISO("Concluído", "Fim do processamento do(s) arquivo(s), verifique os log(s)", { "OK"}, 1)	 
		
	//oBrowC:Refresh(.T.)    
	//oBrowP:Refresh(.T.)
	
endif

Return

//------------------------------

Static Function fAbreCsv(cGet,oGet)

Local cTitle		:= "Salvar arquivo"
Local cFile 		:= "Arq.csv  | *.csv"
Local cPastaTo    	:= ""
Local nDefaultMask 	:= 1
Local cDefaultDir  	:= "C:\"
Local nOptions		:= GETF_LOCALHARD + GETF_LOCALFLOPPY
Local cRet			:= ""

//Exibe tela para gravar o arquivo.
cRet := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

if !Empty(cRet)
	cGet:=cRet
endif

oGet:Refresh()
cLocalArq:=cRet
Return


/*
Funcao      : AbreArq()
Parametros  : aAllGroup
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde encontra-se os arquivos
Autor       : Matheus Massarotto
Data/Hora   : 22/10/2015	11:10
*/
*----------------------------------*
Static Function AbreArq(cGet,oGet)
*----------------------------------*
Local cTitle		:= "Salvar arquivo"
Local cFile 		:= "Arq.txt  | *.txt"
Local cPastaTo    	:= ""
Local nDefaultMask 	:= 1
Local cDefaultDir  	:= "C:\"
Local nOptions		:= GETF_LOCALHARD + GETF_LOCALFLOPPY
Local cRet			:= ""

//Exibe tela para gravar o arquivo.
cRet := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

if !Empty(cRet)
	cGet:=cRet
endif

oGet:Refresh()

Return


/*
Funcao      : AbreCSV()
Parametros  : aAllGroup
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde encontra-se os arquivos
Autor       : Wederson L. Santana
Data/Hora   : 29/09/2020	
*/
*----------------------------------*
Static Function AbreCSV(cGet,oGet)
*----------------------------------*
Local cTitle		:= "Salvar arquivo"
Local cFile 		:= "Arq.csv  | *.csv"
Local cPastaTo    	:= ""
Local nDefaultMask 	:= 1
Local cDefaultDir  	:= "C:\"
Local nOptions		:= GETF_LOCALHARD + GETF_LOCALFLOPPY
Local cRet			:= ""

//Exibe tela para gravar o arquivo.
cRet := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

if !Empty(cRet)
	cGet:=cRet
endif

oGet:Refresh()

Return


//Tela de visualização de log de produtos
*------------------------------*
Static Function TlProd(oLocal)
*------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowP DATA TABLE ALIAS "TRBSB1" OF oLocal			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowP| /* Função que atualiza a regra*/ }  OF oBrowP

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || ID			} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowP		
//ADD COLUMN oColumn DATA { || TAB	   	} TITLE "Tabela"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 3 OF oBrowP		
ADD COLUMN oColumn DATA { || USUARIO   	} TITLE "Usuário"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowP		
ADD COLUMN oColumn DATA { || DATAGE    	} TITLE "Data"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 08 OF oBrowP	
ADD COLUMN oColumn DATA { || HORA    	} TITLE "Hora"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 10 OF oBrowP	
ADD COLUMN oColumn DATA { || ARQUIVO   	} TITLE "Arquivo"			DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 40 OF oBrowP	
ADD COLUMN oColumn DATA { || LINHA  	} TITLE "Linha"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 20 OF oBrowP	
ADD COLUMN oColumn DATA { || LOG    	} TITLE "Log"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 200 OF oBrowP	

oBrowP:SetFilterDefault('TAB == "SB1"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowP

Return


//Tela de visualização de log de clientes
*------------------------------*
Static Function TlClie(oLocal)
*------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowC DATA TABLE ALIAS "TRBSA1" OF oLocal			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowC| /* Função que atualiza a regra*/ }  OF oBrowC

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || ID			} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowC		
//ADD COLUMN oColumn DATA { || TAB	   	} TITLE "Tabela"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 3 OF oBrowC		
ADD COLUMN oColumn DATA { || USUARIO   	} TITLE "Usuário"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowC		
ADD COLUMN oColumn DATA { || DATAGE    	} TITLE "Data"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 08 OF oBrowC	
ADD COLUMN oColumn DATA { || HORA    	} TITLE "Hora"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 10 OF oBrowC	
ADD COLUMN oColumn DATA { || ARQUIVO   	} TITLE "Arquivo"			DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 40 OF oBrowC	
ADD COLUMN oColumn DATA { || LINHA  	} TITLE "Linha"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 20	OF oBrowC	
ADD COLUMN oColumn DATA { || LOG    	} TITLE "Log"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 200 OF oBrowC	

oBrowC:SetFilterDefault('TAB == "SA1"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowC

Return

//Tela de visualização de log de estrutura de produtos
*------------------------------*
Static Function TlEstr(oLocal)
*------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowE DATA TABLE ALIAS "TRBSG1" OF oLocal			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowE| /* Função que atualiza a regra*/ }  OF oBrowE

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || ID			} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowE		
//ADD COLUMN oColumn DATA { || TAB	   	} TITLE "Tabela"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 3 OF oBrowE		
ADD COLUMN oColumn DATA { || USUARIO   	} TITLE "Usuário"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowE		
ADD COLUMN oColumn DATA { || DATAGE    	} TITLE "Data"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 08 OF oBrowE	
ADD COLUMN oColumn DATA { || HORA    	} TITLE "Hora"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 10 OF oBrowE	
ADD COLUMN oColumn DATA { || ARQUIVO   	} TITLE "Arquivo"			DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 40 OF oBrowE	
ADD COLUMN oColumn DATA { || LINHA  	} TITLE "Linha"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 20	OF oBrowE	
ADD COLUMN oColumn DATA { || LOG    	} TITLE "Log"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 200 OF oBrowE	

oBrowE:SetFilterDefault('TAB == "SG1"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowE

Return


//Tela de visualização de log de estrutura de produtos
*------------------------------*
Static Function TlPedi(oLocal)
*------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowV DATA TABLE ALIAS "TRBSC5" OF oLocal			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowV| /* Função que atualiza a regra*/ }  OF oBrowV

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || ID			} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowV		
//ADD COLUMN oColumn DATA { || TAB	   	} TITLE "Tabela"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 3 OF oBrowV		
ADD COLUMN oColumn DATA { || USUARIO   	} TITLE "Usuário"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowV		
ADD COLUMN oColumn DATA { || DATAGE    	} TITLE "Data"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 08 OF oBrowV	
ADD COLUMN oColumn DATA { || HORA    	} TITLE "Hora"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 10 OF oBrowV	
ADD COLUMN oColumn DATA { || ARQUIVO   	} TITLE "Arquivo"			DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 40 OF oBrowV	
ADD COLUMN oColumn DATA { || LINHA  	} TITLE "Linha"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 20	OF oBrowV	
ADD COLUMN oColumn DATA { || LOG    	} TITLE "Log"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 200 OF oBrowV	

oBrowV:SetFilterDefault('TAB == "SC5"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowV

Return

//Função genérica para abertura e leitura dos arquivos
*----------------------------------------*
Static Function LeArquiv(cArq,cTab,cTab2)
*----------------------------------------*
Local oFT   	:= FT():New()
Local cLinha	:= ""
Local cToken	:= ";"
Local aLinha	:= {}
Local nTotLin	:= 0
Local lErro		:= .F.
Local lCrt		:= .F.
Local lTemDup   := .F.   
Local cTemDup   := "" 
Local aCampos	:= {}
Local aCampos1	:= {}
Local nPos		:= 0
Local lCpoFal	:=.F.
Local aCpoObrigat	:= {} 
Local cCpoFaltantes :=""
Local nHdle		:= 0
Local nTamCli   := TamSX3("A1_COD")[1]

DEFAULT cTab2	:= ""  

//Posiciona no sx2 da tabela
DbSelectArea("SX2")
DbSetOrder(1)
DbSeek(cTab)

//Busca do SX3 os campos Obrigatórios
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cTab)

if select("XXX")>0
	XXX->(DbCloseArea())
endif

//Os campos são fixos pois o arquivo é posicional e não dinâmico
DO CASE
	CASE cTab=="SB1" 
		aCampos:= {{"B1_COD"	,"C"	,30	,0},;
					{"B1_UM"	,"C"	,2	,0},;
					{"B1_POSIPI","C"	,10	,0},;
					{"B1_IPI"	,"N"	,5	,0},;
					{"B1_CONTA"	,"C"	,10	,0},;
					{"B1_DESC"	,"C"	,120,0},;
					{"B5_CEME"	,"C"	,500,0}} 

	CASE cTab=="SA1" 		
   		aCampos:= {{"A1_COD"     ,"C",  nTamCli, 0},;
	                {"A1_NOME"   ,"C",   40, 0},;
	                {"A1_CGC"    ,"C",   14, 0},;
	                {"A1_INSCR"  ,"C",   18, 0},;
	                {"A1_END"    ,"C",   40, 0},;
	                {"A1_ENDFAT1","C",   40, 0},;
	                {"A1_BAIRRO" ,"C",   40, 0},;
	                {"A1_ENDCOB" ,"C",   40, 0},;
	                {"A1_ENDCOB1","C",   40, 0},;
	                {"A1_BAICOB" ,"C",   40, 0},;
	                {"A1_ENDENT" ,"C",   40, 0},;
	                {"A1_ENDENT1","C",   40, 0},;
	                {"A1_BAIENT" ,"C",  100, 0},;
	                {"A1_CEP"    ,"C",    8, 0},;
	                {"A1_CEPCOB" ,"C",    8, 0},;
	                {"A1_CEPENT" ,"C",    8, 0},;
	                {"A1_MUN"    ,"C",   15, 0},;
	                {"A1_CIDCOB" ,"C",   15, 0},;
	                {"A1_CIDENT" ,"C",   15, 0},;
	                {"A1_EST"    ,"C",    2, 0},;
	                {"A1_ESTCOB" ,"C",    2, 0},;
	                {"A1_ESTENT" ,"C",    2, 0},;
	                {"A1_CONTATO","C",   40, 0},;
	                {"A1_TIPO"   ,"C",    1, 0},;
	                {"A1_MENS"   ,"C",  100, 0}}

	CASE cTab=="SG1"
		aCampos:= {{"C2_NUM"	,"C",    6, 0},;
	                {"G1_P_SEQ"	,"C",    3, 0},;
					{"G1_COD"	,"C",   30, 0},;
					{"G1_QUANT"	,"N",   10, 0},;
					{"G1_COMP"	,"C",   30, 0}}					
	
	
	CASE cTab=="SC5"
		aCampos:= {{"C5_CLIENT"	 ,"C", nTamCli,0},;
					{"C5_CLIENTE" ,"C",nTamCli,0},;
             		{"A1_NOME"	 ,"C", 40,0},;
             		{"C6_PEDCLI" ,"C", 20,0},;
                    {"C6_P_ITCLI","C", 06,0},;
		   			{"C6_ENTREG" ,"C",  8,0},;
		      		{"C5_CONDPAG","C",  3,0},;
		        	{"C5_NUM" 	 ,"C",  6,0},;
		         	{"C5_EMISSAO","C",  8,0},;
		          	{"C6_LINE"	 ,"C",  3,0},;
		           	{"C6_PRODUTO","C", 30,0},;		          	
		            {"C6_QTDVEN" ,"N", 10,2},;
		            {"C6_PRCVEN" ,"N", 14,2},;
		            {"B1_PICM"   ,"N",  5,2},;
		            {"B1_IPI"    ,"N",  5,2},;
		            {"C5_VOLUME1","N",  5,0},;
		            {"C5_PESOL"	 ,"N",  9,2},;
		            {"C5_PBRUTO" ,"N",  9,2},;
		            {"C6_DESCR01","C",150,0},;
		            {"80"	 ,"C", 10,0}}
						
ENDCASE

	//Cria o temporário
	cArqTrab := CriaTrab(aCampos,.t.)   
	dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
	cArqTemp := CriaTrab(nil,.F.)
	IndRegua("XXX", cArqTemp, (aCampos[1][1]),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário
	
	append from (cArq) SDF

//V2_Prod(cArq)

nTotLin:= XXX->(RecCount())
nAumenta:= (100/(nTotLin-2)) //( 100/(nTotLin-2) / 2)


DO CASE
	CASE cTab == "SG1"

		lRet:=ExecASG1(aCampos,cArq,cTab)//Chamada da função de execauto.
	
    CASE cTab == "SC5"
	
	    lRet:=ExecASC5(aCampos,cArq,cTab)//Chamada da função de execauto.
    
    OTHERWISE
		
		lRet:=ExecAut(aCampos,cArq,cTab)//Chamada da função de execauto.
ENDCASE

	
Return(lRet)

// Wederson L. Santana
//Função genérica para abertura e leitura dos arquivos
*----------------------------------------*
Static Function LeArqDPE(cArq,cTab,cTab2)
*----------------------------------------*
Local oFT   	:= FT():New()
Local cLinha	:= ""
Local cToken	:= ";"
Local aLinha	:= {}
Local nTotLin	:= 0
Local lErro		:= .F.
Local lCrt		:= .F.
Local lTemDup   := .F.   
Local cTemDup   := "" 
Local aCampos	:= {}
Local aCampos1	:= {}
Local nPos		:= 0
Local lCpoFal	:=.F.
Local aCpoObrigat	:= {} 
Local cCpoFaltantes :=""
Local nHdle		:= 0
Local aColunas  :={}
Local nAtual    :=0
Local nProx     :=0
Local nColunas  :=0


DEFAULT cTab2	:= ""  

//Posiciona no sx2 da tabela
dbSelectArea("SX2")
dbSetOrder(1)
dbSeek(cTab)

//Busca do SX3 os campos Obrigatórios
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cTab)

If select("XXX")>0
	XXX->(DbCloseArea())
Endif

//Os campos são fixos pois o arquivo é posicional e não dinâmico
DO CASE
	CASE cTab=="SB1" 
		  aCampos:= {{"B1_COD"    ,TamSX3("B1_COD")[3],TamSX3("B1_COD")[1],TamSX3("B1_COD")[2]},;    
					 {"B1_DESC"   ,TamSX3("B1_DESC")[3],TamSX3("B1_DESC")[1],TamSX3("B1_DESC")[2]},;   
					 {"B1_TIPO"   ,TamSX3("B1_TIPO")[3],TamSX3("B1_TIPO")[1],TamSX3("B1_TIPO")[2]},;
					 {"B1_UM"     ,TamSX3("B1_UM")[3],TamSX3("B1_UM")[1],TamSX3("B1_UM")[2]},;
					 {"B1_LOCPAD" ,TamSX3("B1_LOCPAD")[3],TamSX3("B1_LOCPAD")[1],TamSX3("B1_LOCPAD")[2]},;
					 {"B1_GRUPO"  ,TamSX3("B1_GRUPO")[3],TamSX3("B1_GRUPO")[1],TamSX3("B1_GRUPO")[2]},;  
					 {"B1_ALTER"  ,TamSX3("B1_ALTER")[3],TamSX3("B1_ALTER")[1],TamSX3("B1_ALTER")[2]},;  
					 {"B1_PESO"   ,TamSX3("B1_PESO")[3],TamSX3("B1_PESO")[1],TamSX3("B1_PESO")[2]},;   
					 {"B1_CONTA"  ,TamSX3("B1_CONTA")[3],TamSX3("B1_CONTA")[1],TamSX3("B1_CONTA")[2]},;  
					 {"B1_CC"     ,TamSX3("B1_CC")[3],TamSX3("B1_CC")[1],TamSX3("B1_CC")[2]},;     
					 {"B1_ITEMCC" ,TamSX3("B1_ITEMCC")[3],TamSX3("B1_ITEMCC")[1],TamSX3("B1_ITEMCC")[2]},; 
					 {"B1_FAMILIA",TamSX3("B1_FAMILIA")[3],TamSX3("B1_FAMILIA")[1],TamSX3("B1_FAMILIA")[2]},;
					 {"B1_PROC"   ,TamSX3("B1_PROC")[3],TamSX3("B1_PROC")[1],TamSX3("B1_PROC")[2]},;   
					 {"B1_LOJPROC",TamSX3("B1_LOJPROC")[3],TamSX3("B1_LOJPROC")[1],TamSX3("B1_LOJPROC")[2]},;
					 {"B1_APROPRI",TamSX3("B1_APROPRI")[3],TamSX3("B1_APROPRI")[1],TamSX3("B1_APROPRI")[2]},;
				 	 {"B1_FANTASM",TamSX3("B1_FANTASM")[3],TamSX3("B1_FANTASM")[1],TamSX3("B1_FANTASM")[2]},;
					 {"B1_RASTRO" ,TamSX3("B1_RASTRO")[3],TamSX3("B1_RASTRO")[1],TamSX3("B1_RASTRO")[2]},; 
					 {"B1_CODBAR" ,TamSX3("B1_CODBAR")[3],TamSX3("B1_CODBAR")[1],TamSX3("B1_CODBAR")[2]},; 
					 {"B1_CODGTIN",TamSX3("B1_CODGTIN")[3],TamSX3("B1_CODGTIN")[1],TamSX3("B1_CODGTIN")[2]},;
					 {"B1_FPCOD"  ,TamSX3("B1_FPCOD")[3],TamSX3("B1_FPCOD")[1],TamSX3("B1_FPCOD")[2]},;  
					 {"B1_LOCALIZ",TamSX3("B1_LOCALIZ")[3],TamSX3("B1_LOCALIZ")[1],TamSX3("B1_LOCALIZ")[2]},;
					 {"B1_IMPORT" ,TamSX3("B1_IMPORT")[3],TamSX3("B1_IMPORT")[1],TamSX3("B1_IMPORT")[2]},; 
					 {"B1_CLVL"   ,TamSX3("B1_CLVL")[3],TamSX3("B1_CLVL")[1],TamSX3("B1_CLVL")[2]},;   
					 {"B1_CPOTENC",TamSX3("B1_CPOTENC")[3],TamSX3("B1_CPOTENC")[1],TamSX3("B1_CPOTENC")[2]},;
					 {"B1_MSBLQL" ,TamSX3("B1_MSBLQL")[3],TamSX3("B1_MSBLQL")[1],TamSX3("B1_MSBLQL")[2]},; 
					 {"B1_IPI"    ,TamSX3("B1_IPI")[3],TamSX3("B1_IPI")[1],TamSX3("B1_IPI")[2]},;    
					 {"B1_POSIPI" ,TamSX3("B1_POSIPI")[3],TamSX3("B1_POSIPI")[1],TamSX3("B1_POSIPI")[2]},; 
					 {"B1_ORIGEM" ,TamSX3("B1_ORIGEM")[3],TamSX3("B1_ORIGEM")[1],TamSX3("B1_ORIGEM")[2]},; 
					 {"B1_QE"     ,TamSX3("B1_QE")[3],TamSX3("B1_QE")[1],TamSX3("B1_QE")[2]},;     
					 {"B1_EMIN"   ,TamSX3("B1_EMIN")[3],TamSX3("B1_EMIN")[1],TamSX3("B1_EMIN")[2]},;   
					 {"B1_ESTSEG" ,TamSX3("B1_ESTSEG")[3],TamSX3("B1_ESTSEG")[1],TamSX3("B1_ESTSEG")[2]},; 
					 {"B1_ESTFOR" ,TamSX3("B1_ESTFOR")[3],TamSX3("B1_ESTFOR")[1],TamSX3("B1_ESTFOR")[2]},; 
					 {"B1_FORPRZ" ,TamSX3("B1_FORPRZ")[3],TamSX3("B1_FORPRZ")[1],TamSX3("B1_FORPRZ")[2]},; 
					 {"B1_PE"     ,TamSX3("B1_PE")[3],TamSX3("B1_PE")[1],TamSX3("B1_PE")[2]},;     
					 {"B1_TIPE"   ,TamSX3("B1_TIPE")[3],TamSX3("B1_TIPE")[1],TamSX3("B1_TIPE")[2]},;   
					 {"B1_LE"     ,TamSX3("B1_LE")[3],TamSX3("B1_LE")[1],TamSX3("B1_LE")[2]},;     
					 {"B1_LM"     ,TamSX3("B1_LM")[3],TamSX3("B1_LM")[1],TamSX3("B1_LM")[2]},;     
					 {"B1_TOLER"  ,TamSX3("B1_TOLER")[3],TamSX3("B1_TOLER")[1],TamSX3("B1_TOLER")[2]},;  
					 {"B1_TIPODEC",TamSX3("B1_TIPODEC")[3],TamSX3("B1_TIPODEC")[1],TamSX3("B1_TIPODEC")[2]},;
					 {"B1_MRP"    ,TamSX3("B1_MRP")[3],TamSX3("B1_MRP")[1],TamSX3("B1_MRP")[2]},;    
					 {"B1_EMAX"   ,TamSX3("B1_EMAX")[3],TamSX3("B1_EMAX")[1],TamSX3("B1_EMAX")[2]},;   
					 {"B1_PRODSBP",TamSX3("B1_PRODSBP")[3],TamSX3("B1_PRODSBP")[1],TamSX3("B1_PRODSBP")[2]}}

	CASE cTab=="SGG"
		aCampos:= {{"GG_COD"	,TamSX3("GG_COD")[3],TamSX3("GG_COD")[1],TamSX3("GG_COD")[2]},;
	               {"GG_COMP"	,TamSX3("GG_COMP")[3],TamSX3("GG_COMP")[1],TamSX3("GG_COMP")[2]},;
				   {"GG_QUANT"	,TamSX3("GG_QUANT")[3],TamSX3("GG_QUANT")[1],TamSX3("GG_QUANT")[2]}}
	
ENDCASE


  nHandle := FT_FUse(cArq)

  If! nHandle = -1
    
      FT_FGoTop()

  	  nLast := FT_FLastRec()
   	  While !FT_FEOF()
             cLine  := FT_FReadLn()

	         If FT_FRecno() == 1
                nAtual:=1
				nProx:=0
				While nColunas < 15
				      nProx:= at(";",cLine,nAtual)
				      aadd(aColunas,{SubStr(cLine,nAtual,((nProx-nAtual)))})
					  nAtual := nProx+1
					  nColunas ++
				End

	         EndIf

	         FT_FSKIP()
      End

EndIf

nTotLin:= XXX->(RecCount())
nAumenta:= (100/(nTotLin-2)) //( 100/(nTotLin-2) / 2)

DO CASE
	CASE cTab == "SGG"

		lRet:=ExecASGG(aCampos,cArq,cTab)//Chamada da função de execauto.
    
    OTHERWISE
		
		lRet:=ExecDpe(aCampos,cArq,cTab)//Chamada da função de execauto.
ENDCASE

 FT_FUSE()
	
Return(lRet)


//----------------------------------------------------------------------------------

Static Function ExecDpe(aCampos,cArq,cTab)  

Local xAutoCab 	:= {}
Local xAutoCAux	:= {}
Local aErros	:= {}
Local aGravado	:= {}
Local lErro		:= .F.
Local lOk		:= .F.
Local nLin		:= 0 //Começa no 0 pois não tem linhas de cabeçalho
Local cLin		:= ""

Local nPosEst	:= 0
Local cEstado	:= ""
Local nPosMun	:= 0
Local cMunicip	:= ""
Local cChave	:= ""

//Campos do SB1 - Produtos
Local nPosLoc	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_LOCPAD"} )
Local nPosTip	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_P_TIP"} )
Local nPosTp	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_TIPO"} )
Local nPosGrp	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_GRUPO"} )
Local nPosTCo	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_TIPCONV"} )
Local nPosPIc	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_PICM"} )
Local nPosCon	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_CONTRAT"} )
Local nPosLoc	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_LOCALIZ"} )
Local nPosOri	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_ORIGEM"} )
Local nPosCont	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_CONTA"} )
Local nPosGar	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_GARANT"} )

Local nPosB5Cem	:=  aScan( aCampos, { |x| alltrim(x[1]) == "B5_CEME"} )


//Campos comuns aos 2, Produtos e clientes
Local nPosCod	:= 1
Local nPosFil	:= 0

Local lInc		:= .T. //Se é inclusão .T., se for alteração .F.

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

nCurrent:=0 //Inicial o controle da régua

DbSelectArea("XXX")
XXX->(DbGotop())

While XXX->(!EOF()) 
	xAutoCab := {}
	
	xAutoCAux:= {}
	nLin+=1
	
	lInc		:= .T.
	
	cLin+=iif(!empty(cLin),",","")+cvaltochar(nLin)
	
    DO CASE
		CASE cTab == "SB1"
			//nCurrent:= Eval(oMetSB1:bSetGet) // pega valor corrente da régua
			nCurrent+=Round(nAumenta,2) // atualiza régua
			if nCurrent>100
				nCurrent:=100
			endif
			oMetSB1:Set(nCurrent)
			
			nPosCod	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_COD"} )
			nPosFil	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_FILIAL"} )
			
		CASE cTab == "SG1"
			//nCurrent:= Eval(oMetSA1:bSetGet) // pega valor corrente da régua
			nCurrent+=Round(nAumenta,2) // atualiza régua
			if nCurrent>100
				nCurrent:=100
			endif
			oMetSA1:Set(nCurrent)
			
			nPosCod	:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_COD"} )
			nPosFil	:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_FILIAL"} )

    ENDCASE


	if cTab == "SB1"
    
		            
	EndIf 

	XXX->(DbSkip())
End


Return(.T.)



/*
Funcao      : ExecAut()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função genérica de execauto dos cadastros
Autor       : Matheus Massarotto
Data/Hora   : 29/10/15 18:15
*/                          
*-------------------------------------------*
Static Function ExecAut(aCampos,cArq,cTab)  
*-------------------------------------------*
Local xAutoCab 	:= {}
Local xAutoCAux	:= {}
Local aErros	:= {}
Local aGravado	:= {}
Local lErro		:= .F.
Local lOk		:= .F.
Local nLin		:= 0 //Começa no 0 pois não tem linhas de cabeçalho
Local cLin		:= ""

Local nPosEst	:= 0
Local cEstado	:= ""
Local nPosMun	:= 0
Local cMunicip	:= ""
Local cChave	:= ""

//Campos do SB1 - Produtos
Local nPosLoc	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_LOCPAD"} )
Local nPosTip	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_P_TIP"} )
Local nPosTp	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_TIPO"} )
Local nPosGrp	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_GRUPO"} )
Local nPosTCo	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_TIPCONV"} )
Local nPosPIc	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_PICM"} )
Local nPosCon	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_CONTRAT"} )
Local nPosLoc	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_LOCALIZ"} )
Local nPosOri	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_ORIGEM"} )
Local nPosCont	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_CONTA"} )
Local nPosGar	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_GARANT"} )

Local nPosB5Cem	:=  aScan( aCampos, { |x| alltrim(x[1]) == "B5_CEME"} )

//Campos do SA1 - Clientes
Local nPosLoj	:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_LOJA"} )
Local nPosEndEnt:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_ENDENT"} )
Local nPosCodMun:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_COD_MUN"} )
Local nPosCodPai:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_CODPAIS"} )

Local nA1_EndEnt1:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_ENDENT1"} )
Local nA1_EndFat1:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_ENDFAT1"} )
Local nA1_EndCob1:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_ENDCOB1"} )
Local nA1_BaiCob := aScan( aCampos, { |x| alltrim(x[1]) == "A1_BAICOB"} )
Local nA1_BaiEnt := aScan( aCampos, { |x| alltrim(x[1]) == "A1_BAIENT"} )
Local nA1_CepCob := aScan( aCampos, { |x| alltrim(x[1]) == "A1_CEPCOB"} )
Local nA1_CepEnt := aScan( aCampos, { |x| alltrim(x[1]) == "A1_CEPENT"} )
Local nA1_CidCob := aScan( aCampos, { |x| alltrim(x[1]) == "A1_CIDCOB"} )
Local nA1_CidEnt := aScan( aCampos, { |x| alltrim(x[1]) == "A1_CIDENT"} )
Local nA1_EstCob := aScan( aCampos, { |x| alltrim(x[1]) == "A1_ESTCOB"} )
Local nA1_EstEnt := aScan( aCampos, { |x| alltrim(x[1]) == "A1_ESTENT"} )
Local nA1_Mens 	 := aScan( aCampos, { |x| alltrim(x[1]) == "A1_MENS"} )

//Campos comuns aos 2, Produtos e clientes
Local nPosCod	:= 1
Local nPosFil	:= 0

Local lInc		:= .T. //Se é inclusão .T., se for alteração .F.

nCurrent:=0 //Inicial o controle da régua

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 
	xAutoCab := {}
	
	xAutoCAux:= {}
	nLin+=1
	
	lInc		:= .T.
	
	cLin+=iif(!empty(cLin),",","")+cvaltochar(nLin)
	
    DO CASE
		CASE cTab == "SB1"
			//nCurrent:= Eval(oMetSB1:bSetGet) // pega valor corrente da régua
			nCurrent+=Round(nAumenta,2) // atualiza régua
			if nCurrent>100
				nCurrent:=100
			endif
			oMetSB1:Set(nCurrent)
			
			nPosCod	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_COD"} )
			nPosFil	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_FILIAL"} )
			
		CASE cTab == "SA1"
			//nCurrent:= Eval(oMetSA1:bSetGet) // pega valor corrente da régua
			nCurrent+=Round(nAumenta,2) // atualiza régua
			if nCurrent>100
				nCurrent:=100
			endif
			oMetSA1:Set(nCurrent)
			
			nPosCod	:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_COD"} )
			nPosFil	:= aScan( aCampos, { |x| alltrim(x[1]) == "A1_FILIAL"} )

    ENDCASE


	if cTab == "SB1"
    
		DbSelectArea("SB1")
		DbSetOrder(1)
		if SB1->(DbSeek(xFilial("SB1")+XXX->&(aCampos[nPosCod][1])))
        	lInc:=.F.
  		//RRP - 24/03/2017 - Ajuste após atualização do sistema. Execauto Mata010 parou de incluir produtos.
  		Else
  			SB1->(DbGoTop())
		Endif
		
		//Montagem do array com campos e dados
		For nl:=1 to len(aCampos)
			if "B1_" $ aCampos[nl][1]
				
				if aCampos[nl][2]=="C"
					AADD(xAutoCab,{aCampos[nl][1] ,UPPER(alltrim(XXX->&(aCampos[nl][1])))	,nil})
				else 
					AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
				endif
				
			endif
		Next 
		
		if nPosFil<=0
			AADD(xAutoCab,{"B1_FILIAL"	,xFilial("SB1")	,nil})
		endif
		
		if nPosCont>0
		    if CT1->(FieldPos("CT1_P_CONT"))>0
				
				if !Empty(xAutoCab[nPosCont][2])
				
					cQry:=" SELECT CT1_CONTA FROM "+RETSQLNAME("CT1")+CRLF
					cQry+=" WHERE D_E_L_E_T_='' AND CT1_P_CONT='"+xAutoCab[nPosCont][2]+"'
                    
     				if select("QRYTEMP")>0
						QRYTEMP->(DbCloseArea())
					endif
					DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
				
					Count to nRecCount
				        
					if nRecCount >0
						QRYTEMP->(DbGoTop())
						xAutoCab[nPosCont][2]:=	alltrim(QRYTEMP->CT1_CONTA)
    	            endif
		        
		        endif
		        
		    endif

		endif
		
		if lInc //Se for incluir

			if nPosLoc<=0
				AADD(xAutoCab,{"B1_LOCPAD"	,"01"	,nil})
			endif
			if nPosTip<=0
				AADD(xAutoCab,{"B1_P_TIP"	,"1"	,nil})
			endif	                   
			if nPosTp<=0
				AADD(xAutoCab,{"B1_TIPO"	,TipoPro(XXX->&(aCampos[nPosCod][1]))	,nil})
			endif
			if nPosTCo<=0
				AADD(xAutoCab,{"B1_TIPCONV" ,"M"	,nil})
			endif
			if nPosPIc<=0
				AADD(xAutoCab,{"B1_PICM"	,0		,Nil})
			endif
			if nPosCon<=0
				AADD(xAutoCab,{"B1_CONTRAT"	,"N"	,Nil})
			endif		
			if nPosLoc<=0
				AADD(xAutoCab,{"B1_LOCALIZ"	,"N"	,Nil})
			endif		
            if nPosOri<=0
	            AADD(xAutoCab,{"B1_ORIGEM"	,"1"	,Nil})
            endif
			if nPosGrp<=0
				AADD(xAutoCab,{"B1_GRUPO"	,"PV"	,Nil})
			endif		        
			if nPosGar<=0
				AADD(xAutoCab,{"B1_GARANT"	,"2"	,Nil})
			endif

        endif

        if nPosB5Cem>0
       		if !empty(XXX->&(aCampos[nPosB5Cem][1]))
	       		AADD(xAutoCAux,{"B5_FILIAL"	,xFilial("SB5")					,Nil})
	   			AADD(xAutoCAux,{"B5_COD"	,XXX->&(aCampos[nPosCod][1])	,Nil})
	   			AADD(xAutoCAux,{"B5_CEME"	,XXX->&(aCampos[nPosB5Cem][1])	,Nil})
        	endif
        endif

        cChave:= xFilial("SB1")+XXX->&(aCampos[nPosCod][1])
        
	elseif cTab == "SA1"
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		if SA1->(DbSeek(xFilial("SA1")+XXX->&(aCampos[nPosCod][1])))
        	lInc:=.F.
		endif
		
		//Montagem do array com campos e dados
		For nl:=1 to len(aCampos)
			if "A1_" $ aCampos[nl][1]
				
				if SA1->(FieldPos(aCampos[nl][1]))>0

					if alltrim(aCampos[nl][1])=="A1_NOME"
						AADD(xAutoCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})				
						AADD(xAutoCab,{"A1_NREDUZ" ,LEFT(XXX->&(aCampos[nl][1]),20)	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_END"
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim( iif(empty(XXX->&(aCampos[nl][1])),XXX->&(aCampos[nPosEndEnt][1]),XXX->&(aCampos[nl][1])) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_MUN"
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim( iif(empty(XXX->&(aCampos[nl][1])),XXX->&(aCampos[nA1_CidEnt][1]),XXX->&(aCampos[nl][1])) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_EST"
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim( iif(empty(XXX->&(aCampos[nl][1])),XXX->&(aCampos[nA1_EstEnt][1]),XXX->&(aCampos[nl][1])) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_TIPO"
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim( iif(ALLTRIM(UPPER(XXX->&(aCampos[nl][1])))=="C","F",XXX->&(aCampos[nl][1]))	),nil})
					elseif alltrim(aCampos[nl][1])=="A1_BAIRRO"
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim( iif(empty(XXX->&(aCampos[nl][1])), iif( empty(XXX->&(aCampos[nA1_BaiCob][1])),XXX->&(aCampos[nA1_BaiEnt][1]),XXX->&(aCampos[nA1_BaiCob][1]) ) , XXX->&(aCampos[nl][1]) ) ),nil})
					elseif alltrim(aCampos[nl][1])=="A1_CEP"
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim( iif(empty(XXX->&(aCampos[nl][1])),XXX->&(aCampos[nA1_CepEnt][1]),XXX->&(aCampos[nl][1])) )	,nil})
					else
						AADD(xAutoCab,{aCampos[nl][1] ,alltrim(XXX->&(aCampos[nl][1]))	,nil})
				    endif
    
                else

                	if alltrim(aCampos[nl][1])=="A1_ENDFAT1"
						AADD(xAutoCab,{"A1_ENDCFAT" ,alltrim( iif(empty(XXX->&(aCampos[nl][1])),XXX->&(aCampos[nA1_EndEnt1][1]),XXX->&(aCampos[nl][1])) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_ENDCOB1"
						//AADD(xAutoCab,{"A1_ENDCCOB" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
						AADD(xAutoCab,{"A1_ENDCCOB" ,"TESTE"	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_BAICOB"
						AADD(xAutoCab,{"A1_BAIRROC" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_CEPCOB"
						AADD(xAutoCab,{"A1_CEPC" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_CIDCOB"
						AADD(xAutoCab,{"A1_MUNC" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_ESTCOB"
						AADD(xAutoCab,{"A1_ESTC" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_BAIENT"
						AADD(xAutoCab,{"A1_BAIRROE" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_CEPENT"
						AADD(xAutoCab,{"A1_CEPE" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_CIDENT"
						AADD(xAutoCab,{"A1_MUNE" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					elseif alltrim(aCampos[nl][1])=="A1_ESTENT"
						AADD(xAutoCab,{"A1_ESTE" ,alltrim( XXX->&(aCampos[nl][1]) )	,nil})
					endif
					
                endif
			    
			endif
		Next

		if nPosFil<=0
			AADD(xAutoCab,{"A1_FILIAL"	,xFilial("SA1")	,nil})
		endif

		if nPosCodMun<=0

			nPosEst:= aScan( xAutoCab, { |x| alltrim(x[1]) == "A1_EST"} )
			nPosMun:= aScan( xAutoCab, { |x| alltrim(x[1]) == "A1_MUN"} )

                if nPosEst>0
                	cEstado:=xAutoCab[nPosEst][2]
                endif
			if nPosMun>0
				cMunicip:=xAutoCab[nPosEst][2]
			endif                

			DbselectArea("CC2")
			CC2->(DbGoTop())
			CC2->(DbSetOrder(4))
			if !CC2->(DbSeek(xFilial("CC2")+cEstado+upper(alltrim(cMunicip))))
                	CC2->(DbSeek(xFilial("CC2")+cEstado))
                endif
                
			AADD(xAutoCab,{"A1_COD_MUN"	,alltrim(CC2->CC2_CODMUN),Nil})
              
            CC2->(DbCloseArea())
		endif

		if nPosCodPai<=0
			AADD(xAutoCab,{"A1_CODPAIS"	,"01058",Nil}) //Fixo Brasil
		endif

 		if lInc //Se for incluir
			if nPosLoj<=0
				AADD(xAutoCab,{"A1_LOJA"	,"01"	,Nil})
			endif
	        cChave:= xFilial("SA1")+XXX->&(aCampos[nPosCod][1])+"01"
		else
			if nPosLoj<=0
				AADD(xAutoCab,{"A1_LOJA"	,SA1->A1_LOJA	,Nil})
			endif
		endif

	endif
	
	xAutoCab:= aSortX3(xAutoCab)

	Private lMsErroAuto:= .F.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	BEGIN Transaction
        //verifica qual execauto deve ser chamado
	    DO CASE
			CASE cTab == "SB1"
				MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,IIF(lInc,3,4)) //Se for lInc, 3- Inclusao de produto se não 4- Alteração de produto
			CASE cTab == "SA1"
	    		MsExecAuto({|x,y| MATA030(x,y)},xAutoCab,IIF(lInc,3,4)) //Se for lInc, 3- Inclusao de cliente se não 4- Alteração de cliente
	    ENDCASE
	    
		If lMsErroAuto

			cErroCon	:= ""
			aAutoErro 	:= GETAUTOGRLOG()
		    cErroCon	:= XLOG(aAutoErro) 
			//msginfo(cErroCon) 
	    	//mostraerro()
	    	
	    	GravaLog(.F.,cArq,cLin,cErroCon,cTab)
	    	
		    lErro:=.T.
		    DisarmTransaction()
			cLin:=""
		Else

			
	    	if lInc
	    	    DbSelectArea(cTab)
	    	    &(cTab)->(DbSetOrder(1))
	    	    if &(cTab)->(DbSeek(cChave))
					lOk:=.T.
	    			GravaLog(.T.,cArq,cLin,"Incluído com sucesso",cTab)
			    else
                   	GravaLog(.F.,cArq,cLin,"Problema na inclusão, um dos motivos é a falta de preenchimento de campos obrigatórios",cTab)
			    endif
			else
				lOk:=.T.
				GravaLog(.T.,cArq,cLin,"Alterado com sucesso",cTab)
			endif

			if lOk
				//Verifico se é produto e houve inclusão
				if cTab == "SB1"
	   				if !empty(xAutoCAux)
						MSExecAuto({|x,y| Mata180(x,y)},xAutoCAux,IIF(lInc,3,4)) //Se for lInc, 3- Inclusao de compl. produto se não 4- Alteração de compl. produto
	    			endif
				endif
			endif
			
			cLin:=""
		EndIF
		            
	END Transaction


	XXX->(DbSkip())
enddo


Return(.T.)


//--------------------------------------------

Static Function ExecASGG(aCampos,cArq,cTab)  
*-------------------------------------------*
Local aErros	:= {}
Local aGravado	:= {}
Local nLin		:= 0 //Começa no 0 pois não tem cabeçalho
Local cLin		:= ""

Local aEstCab	:= {}
Local aEstIte	:= {}
Local aEstIAx	:= {}
Local aOrdPro	:= {}

Local cCodAnt	:= ""

Local nPosCOD	:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_COD"} )
Local nPosTRT	:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_TRT"} )
Local nPosPER	:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_PERDA"} )
Local nPosINI	:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_INI"} )
Local nPosFIM	:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_FIM"} )
Local nPosQtd	:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_QUANT"} )
Local nPosComTMP:= aScan( aCampos, { |x| alltrim(x[1]) == "GG_COMP"} )

Local nJaTemComp:= 0

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

nCurrent:=0 //Inicial o controle da régua

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 
	nLin+=1
	cLin+=iif(!empty(cLin),",","")+cvaltochar(nLin)
	
	//nCurrent:= Eval(oMetSG1:bSetGet) // pega valor corrente da régua
	nCurrent+=Round(nAumenta,2) // atualiza régua
	if nCurrent>100
		nCurrent:=100
	endif
	oMetSG1:Set(nCurrent)
    
    if empty(XXX->&(aCampos[nPosQtd][1]))  //Despresa quantidades zeradas, conforme combinado com o Matheus(Intralox) no dia 14/03/2016
		XXX->(DbSkip())
		Loop    		
    endif
    
	if alltrim(cCodAnt) <> alltrim(XXX->&(aCampos[nPosCOD][1]) )
		aEstCab := {}
		aEstIte	:= {}
	    
		//aOrdPro := {}

		AADD(aEstCab,{aCampos[nPosCOD][1] ,XXX->&(aCampos[nPosCOD][1])	,nil})
		AADD(aEstCab,{"GG_QUANT" 		  ,1							,nil})
		AADD(aEstCab,{"NIVALT" 			  ,"S"							,nil})

	endif
	   
	aEstIAx:={}
    nJaTemComp:=0
    
    //Tratamento para agrupar componentes da estrutura que sejam iguais.
    if len(aEstIte)>0
		nPosComIte	:= aScan( aEstIte[1], { |x| alltrim(x[1]) == "GG_COMP"} )
		nPosQtdIte	:= aScan( aEstIte[1], { |x| alltrim(x[1]) == "GG_QUANT"} )
		
		if nPosComIte>0 .and. nPosQtdIte>0
	   
			nJaTemComp:=aScan( aEstIte, { |x| alltrim(x[nPosComIte][2]) == alltrim( XXX->&(aCampos[nPosComTMP][1]) ) } )
			
			if nJaTemComp>0
		   	
		   		aEstIte[nJaTemComp][nPosQtdIte][2]+=XXX->&(aCampos[nPosQtd][1])
	
			endif 
	
		endif
	endif
	
	if nJaTemComp==0
						
		//Montagem do array com campos e dados
		For nl:=1 to len(aCampos)
			if "G1_" $ aCampos[nl][1]
				
				AADD(aEstIAx,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	
			endif
		Next
		
		if nPosTRT<=0
			AADD(aEstIAx,{"GG_TRT"	,space(3)	,nil})
		endif
		if nPosPER<=0
			AADD(aEstIAx,{"GG_PERDA",0			,nil})
		endif
		if nPosINI<=0
			AADD(aEstIAx,{"GG_INI"	,CTOD("01/01/01")	,nil})
		endif
		if nPosFIM<=0
			AADD(aEstIAx,{"GG_FIM"	,CTOD("31/12/49")	,nil})
		endif
		
		AADD(aEstIte,aEstIAx)
	
	endif
	
	//Armazena o código anterior
	cCodAnt:=XXX->&(aCampos[nPosCOD][1])
	
	XXX->(DbSkip())

	if alltrim(cCodAnt) <> alltrim(XXX->&(aCampos[nPosCOD][1]) )

		DbSelectArea("SGG")
		SGG->(DbSetOrder(1))
		if !SGG->(DbSeek(xFilial("SGG")+alltrim(cCodAnt)) )    

			BEGIN Transaction
		        
				//execauto de estrutura de produto
				MSExecAuto({|x,y,z| mata202(x,y,z)},aEstCab,aEstIte,3) 
			    
				If lMsErroAuto
		
					cErroCon	:= ""
					aAutoErro 	:= GETAUTOGRLOG()
				    cErroCon	:= XLOG(aAutoErro) 
			    	
			    	GravaLog(.F.,cArq,cLin,cErroCon,cTab)
			    	
				    DisarmTransaction()
					cLin:=""
				Else
	                
	                GravaLog(.T.,cArq,cLin,"Incluído com sucesso",cTab)
	                
					cLin:=""			    
				EndIF
				            
			END Transaction
        else

			GravaLog(.F.,cArq,cLin,"Pré - Estrutura já cadastrada "+cCodAnt,cTab)      

        endif
        
    endif

enddo
 
Return(.T.)



/*
Funcao      : ExecASG1()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função de execauto da estrutura de produtos (SG1)
Autor       : Matheus Massarotto
Data/Hora   : 30/10/15 18:15
*/                          
*-------------------------------------------*
Static Function ExecASG1(aCampos,cArq,cTab)  
*-------------------------------------------*
Local aErros	:= {}
Local aGravado	:= {}
Local nLin		:= 0 //Começa no 0 pois não tem cabeçalho
Local cLin		:= ""

Local aEstCab	:= {}
Local aEstIte	:= {}
Local aEstIAx	:= {}
Local aOrdPro	:= {}

Local cCodAnt	:= ""

Local nPosCOD	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_COD"} )
Local nPosTRT	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_TRT"} )
Local nPosPER	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_PERDA"} )
Local nPosINI	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_INI"} )
Local nPosFIM	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_FIM"} )
Local nPosQtd	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_QUANT"} )
Local nPosComTMP:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_COMP"} )

Local nPosSeq	:= aScan( aCampos, { |x| alltrim(x[1]) == "G1_P_SEQ"} )

Local nPosOp	:= aScan( aCampos, { |x| alltrim(x[1]) == "C2_NUM"} )

Local nJaTemComp:= 0

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

nCurrent:=0 //Inicial o controle da régua

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 
	nLin+=1
	cLin+=iif(!empty(cLin),",","")+cvaltochar(nLin)
	
	//nCurrent:= Eval(oMetSG1:bSetGet) // pega valor corrente da régua
	nCurrent+=Round(nAumenta,2) // atualiza régua
	if nCurrent>100
		nCurrent:=100
	endif
	oMetSG1:Set(nCurrent)
    
    if empty(XXX->&(aCampos[nPosQtd][1]))  //Despresa quantidades zeradas, conforme combinado com o Matheus(Intralox) no dia 14/03/2016
		XXX->(DbSkip())
		Loop    		
    endif
    
	if alltrim(cCodAnt) <> alltrim(XXX->&(aCampos[nPosCOD][1]) )
		aEstCab := {}
		aEstIte	:= {}
	    
		//aOrdPro := {}

		AADD(aEstCab,{aCampos[nPosCOD][1] ,XXX->&(aCampos[nPosCOD][1])	,nil})
		AADD(aEstCab,{"G1_QUANT" 		  ,1							,nil})
		AADD(aEstCab,{"NIVALT" 			  ,"S"							,nil})

	endif
	   
	aEstIAx:={}
    nJaTemComp:=0
    
    //Tratamento para agrupar componentes da estrutura que sejam iguais.
    if len(aEstIte)>0
		nPosComIte	:= aScan( aEstIte[1], { |x| alltrim(x[1]) == "G1_COMP"} )
		nPosQtdIte	:= aScan( aEstIte[1], { |x| alltrim(x[1]) == "G1_QUANT"} )
		
		if nPosComIte>0 .and. nPosQtdIte>0
	   
			nJaTemComp:=aScan( aEstIte, { |x| alltrim(x[nPosComIte][2]) == alltrim( XXX->&(aCampos[nPosComTMP][1]) ) } )
			
			if nJaTemComp>0
		   	
		   		aEstIte[nJaTemComp][nPosQtdIte][2]+=XXX->&(aCampos[nPosQtd][1])
	
			endif 
	
		endif
	endif
	
	if nJaTemComp==0
						
		//Montagem do array com campos e dados
		For nl:=1 to len(aCampos)
			if "G1_" $ aCampos[nl][1]
				
				AADD(aEstIAx,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
	
			endif
		Next
		
		if nPosTRT<=0
			AADD(aEstIAx,{"G1_TRT"	,space(3)	,nil})
		endif
		if nPosPER<=0
			AADD(aEstIAx,{"G1_PERDA",0			,nil})
		endif
		if nPosINI<=0
			AADD(aEstIAx,{"G1_INI"	,CTOD("01/01/01")	,nil})
		endif
		if nPosFIM<=0
			AADD(aEstIAx,{"G1_FIM"	,CTOD("31/12/49")	,nil})
		endif
		
		AADD(aEstIte,aEstIAx)
	
	endif
	
	//Armazena o código anterior
	cCodAnt:=XXX->&(aCampos[nPosCOD][1])
	
	XXX->(DbSkip())

	if alltrim(cCodAnt) <> alltrim(XXX->&(aCampos[nPosCOD][1]) )

		DbSelectArea("SG1")
		SG1->(DbSetOrder(1))
		if !SG1->(DbSeek(xFilial("SG1")+alltrim(cCodAnt)) )    

			BEGIN Transaction
		        
				//execauto de estrutura de produto
				MSExecAuto({|x,y,z| mata200(x,y,z)},aEstCab,aEstIte,3) 
			    
				If lMsErroAuto
		
					cErroCon	:= ""
					aAutoErro 	:= GETAUTOGRLOG()
				    cErroCon	:= XLOG(aAutoErro) 
			    	
			    	GravaLog(.F.,cArq,cLin,cErroCon,cTab)
			    	
				    DisarmTransaction()
					cLin:=""
				Else
	                
	                GravaLog(.T.,cArq,cLin,"Incluído com sucesso",cTab)
	                
					cLin:=""			    
				EndIF
				            
			END Transaction
        else

			GravaLog(.F.,cArq,cLin,"Estrutura já cadastrada "+cCodAnt,cTab)      

        endif
        
    endif

enddo
 
Return(.T.)


/*
Funcao      : ExecASC5()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função de execauto do pedido de venda (SC5)
Autor       : Matheus Massarotto
Data/Hora   : 30/10/15 18:15
*/                          
*-------------------------------------------*
Static Function ExecASC5(aCampos,cArq,cTab)  
*-------------------------------------------*
Local aErros	:= {}
Local aGravado	:= {}
Local nLin		:= 0 //Começa no 0 pois não tem cabeçalho
Local cLin		:= ""

Local aEstCab	:= {}
Local aEstIte	:= {}
Local aEstIAx	:= {}

Local aOrdPro	:= {}
Local aOrdPAx   := {}

Local cCodAnt	:= ""

Local nPosNUM	:= aScan( aCampos, { |x| alltrim(x[1]) == "C5_NUM"} )
//Local nPosICM	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_ICMS"} )
Local nPosIPI	:= aScan( aCampos, { |x| alltrim(x[1]) == "B1_IPI"} )
Local nPosC6PRO	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_PRODUTO"} )
Local nPosC6UM  := aScan( aCampos, { |x| alltrim(x[1]) == "C6_UM"} )
//Local nPosC6SEG := aScan( aCampos, { |x| alltrim(x[1]) == "C6_SEGUM"} )
Local nPosC6PRC	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_PRCVEN"} )
Local nPosC6QTD	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_QTDVEN"} )
Local nPosC6LJ	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_LOJA"} )
Local nPosC6LOC	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_LOCAL"} )
Local nPosC6DES	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_DESCRI"} )
Local nPosC6TES	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_TES"} )
//Local nPosC6CF	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_CF"} )
Local nPosC6Ent	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_ENTREG"} )
Local nPosC6PUn	:= aScan( aCampos, { |x| alltrim(x[1]) == "C6_PRUNIT"} )

Local nPosC5CLI	:= aScan( aCampos, { |x| alltrim(x[1]) == "C5_CLIENT"} )
Local nPosC5TIP	:= aScan( aCampos, { |x| alltrim(x[1]) == "C5_TIPO"} )
Local nPosC5TCL	:= aScan( aCampos, { |x| alltrim(x[1]) == "C5_TIPOCLI"} )
Local nPosC5LEN := aScan( aCampos, { |x| alltrim(x[1]) == "C5_LOJAENT"} )
Local nPosC5LCL := aScan( aCampos, { |x| alltrim(x[1]) == "C5_LOJACLI"} )
//Local nPosC5TAB := aScan( aCampos, { |x| alltrim(x[1]) == "C5_TABELA"} )
Local nPosC5MOE := aScan( aCampos, { |x| alltrim(x[1]) == "C5_MOEDA"} )
Local nPosC5Emi := aScan( aCampos, { |x| alltrim(x[1]) == "C5_EMISSAO"} )
Local nPosC5Fat := aScan( aCampos, { |x| alltrim(x[1]) == "C5_FATURA"} )

Local lTemPro	:= .F.
Local lTemCli	:= .F.
Local lTemEstr	:= .T.

Local lGerouOp	:= .F.

Local cTES		:= ""

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

Private cErroCon	:= ""
Private lG1Alter	:= .F.

nCurrent:=0 //Inicial o controle da régua

DbSelectArea("XXX")
XXX->(DbGotop())

while XXX->(!EOF()) 
	nLin+=1
	cLin+=iif(!empty(cLin),",","")+cvaltochar(nLin)
	
	//nCurrent:= Eval(oMetSC5:bSetGet) // pega valor corrente da régua
	nCurrent+=Round(nAumenta,2) // atualiza régua
	if nCurrent>100
		nCurrent:=100
	endif
	oMetSC5:Set(nCurrent)
	
    If Len(alltrim(XXX->&(aCampos[nPosC5CLI][1])))== 10
	   
	   If SA1->(FieldPos("A1_P_COD"))>0
          SA1->(dbSetOrder(1))
		  If! SA1->(DbSeek(xFilial("SA1")+alltrim(XXX->&(aCampos[nPosC5CLI][1]))) )

	   		If Select("TMP") <> 0
	  	  		TMP->(DbCloseArea())
   	   		EndIf     

       		cQry := " SELECT A1_COD,A1_LOJA "
   	   		cQry += " From "+RetSqlName("SA1")
   	   		cQry += " WHERE A1_P_COD = '"+alltrim(XXX->&(aCampos[nPosC5CLI][1]))+"' AND A1_MSBLQL <> '1' And D_E_L_E_T_ = '' "
   
   			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)
           
			SA1->(dbSetOrder(1))
			lTemCli:=SA1->(DbSeek(xFilial("SA1")+TMP->A1_COD+TMP->A1_LOJA ))

			If Select("TMP") <> 0
	  	  		TMP->(DbCloseArea())
   	   		EndIf
		  EndIf 		  
        
		Else
            MsgInfo("Não encontrado campo específico 'Cód. Oracle' no cadastro do cliente. ","A T E N Ç Ã O")
		EndIf 
	Else   

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		lTemCli:=SA1->(DbSeek(xFilial("SA1")+alltrim(XXX->&(aCampos[nPosC5CLI][1]))) )

	EndIf 
    
	if alltrim(cCodAnt) <> alltrim(XXX->&(aCampos[nPosNUM][1]) )
		aEstCab := {}
		aEstIte	:= {}
		
		aOrdPro	:= {}
		
		AADD(aEstCab,{"C5_FILIAL",xFilial("SC5")	,nil})
		
		For nl:=1 to len(aCampos)
			if "C5_" == SUBSTR(aCampos[nl][1],1,3) 
				if SC5->(FieldPos(aCampos[nl][1]))>0 //Se o campo existir no dicionário
					if nPosC5Emi == nl
						AADD(aEstCab,{aCampos[nl][1] ,CTOD(XXX->&(aCampos[nl][1]))	,nil})
					else
					     Do Case
                            Case aCampos[nl][1] == "C5_CLIENTE"					
                                 AADD(aEstCab,{aCampos[nl][1] , SA1->A1_COD ,nil})
							Case aCampos[nl][1] == "C5_CLIENT"					
                                 AADD(aEstCab,{aCampos[nl][1] , SA1->A1_COD ,nil})						    	 
							Case aCampos[nl][1] == "C5_FATURA"					
                                 AADD(aEstCab,{aCampos[nl][1] , SA1->A1_COD ,nil})
						    Case aCampos[nl][1] == "C5_LOJACLI"					
                                 AADD(aEstCab,{aCampos[nl][1] , SA1->A1_LOJA,nil})
							Case aCampos[nl][1] == "C5_LOJAENT"					
                                 AADD(aEstCab,{aCampos[nl][1] , SA1->A1_LOJA,nil})	 
						    OtherWise 						
							     AADD(aEstCab,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
					     EndCase 		
		            endif
		        endif
			endif
		Next
	
	    if nPosC5TIP<=0
	    	AADD(aEstCab,{"C5_TIPO" 	,"N"			,nil})
	    endif
	    if nPosC5TCL<=0 .AND. lTemCli
	    	AADD(aEstCab,{"C5_TIPOCLI" 	,SA1->A1_TIPO	,nil})
	    endif
	    if nPosC5LEN<=0
	    	nCabCli:=aScan( aEstCab, { |x| alltrim(x[1]) == "C5_CLIENT"} )
	    	AADD(aEstCab,{})
	    	AINS(aEstCab,nCabCli+1)
	    	aEstCab[nCabCli+1]:={"C5_LOJAENT" 	,SA1->A1_LOJA	,nil}
	    	//AADD(aEstCab,{"C5_LOJAENT" 	,"01"	,nil})
	    endif
	    if nPosC5LCL<=0
	    	nCabCli:=aScan( aEstCab, { |x| alltrim(x[1]) == "C5_CLIENT"} )
	    	AADD(aEstCab,{})
	    	AINS(aEstCab,nCabCli+1)
	    	aEstCab[nCabCli+1]:={"C5_LOJACLI" 	,SA1->A1_LOJA	,nil}
	    	//AADD(aEstCab,{"C5_LOJACLI" 	,"01"	,nil})
	    endif
	    //if nPosC5TAB<=0
		//    AADD(aEstCab,{"C5_TABELA" 	,"1"	,nil})
	    //endif
	    if nPosC5MOE<=0
		    AADD(aEstCab,{"C5_MOEDA" 	,1		,nil})
	    endif
	    //if nPosC5Fat>0
	    //	AADD(aEstCab,{"C5_FATURA",SA1->A1_COD,nil})//AOA - 20/10/2016 - Alterado o campo onde pega a informação
	    	//nPosClie := aScan( aEstCab, { |x| alltrim(x[1]) == "C5_CLIENTE"} )
	    	//aEstCab[ nPosClie ][ 2 ]:=XXX->C5_CLIENT
	    //endif
	endif
	
	aEstCab:= aSortX3(aEstCab) //Chamo rotina para ordenar o array de cabeçalho de acordo com o SX3
	   
	aEstIAx:={}
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	lTemPro:=SB1->(DbSeek(xFilial("SB1")+alltrim(XXX->&(aCampos[nPosC6PRO][1]) )))
    
	if lTemPro
    	if UPPER(alltrim(SB1->B1_TIPO)) = "PA" //somente verificar estrutura de produto acabado
			
			lG1Alter:=.F.
			
			DbSelectArea("SG1")
			SG1->(DbSetOrder(1))
			lTemEsAx:=SG1->(DbSeek(xFilial("SG1")+alltrim(XXX->&(aCampos[nPosC6PRO][1]))) )

		    if !lTemEsAx
		    	lTemEstr:=.F.
		    else
		    	DbSelectArea("SC5")
		    	SC5->(DbSetOrder(1))
		    	if !SC5->(DbSeek(xFilial("SC5")+ alltrim(XXX->&(aCampos[nPosNUM][1]))) )
		    		if SG1->(FieldPos("G1_P_AJUST"))>0
		    			if SG1->G1_P_AJUST
		    				lG1Alter:=.T.
		    			endif
		    		endif
		    		
		    		if !lG1Alter
			    		While SG1->(!EOF()) .AND. alltrim(SG1->G1_COD)==alltrim(XXX->&(aCampos[nPosC6PRO][1]))
	
			    		    RecLock("SG1",.F.)
			    		    	SG1->G1_QUANT := SG1->G1_QUANT / XXX->&(aCampos[nPosC6QTD][1])
			    		    	
			    		    	if SG1->(FieldPos("G1_P_AJUST"))>0
			    		    		SG1->G1_P_AJUST:=.T.	
			    		    	endif
			    		    MsUnlock()
			    			SG1->(DbSkip())
	
			    		Enddo
		    		endif
		    	endif

		    endif
        endif
    endif
	
	AADD(aEstIAx,{"C6_FILIAL"	,xFilial("SC6")	,nil})
	AADD(aEstIAx,{"C6_ITEM"		,STRZERO(len(aEstIte)+1,TamSx3("C6_ITEM")[1]),nil})
	AADD(aEstIAx,{"C6_NUM"		,XXX->&(aCampos[nPosNUM][1]),nil})
			
	//Montagem do array com campos e dados
	For nl:=1 to len(aCampos)
		if "C6_" == SUBSTR(aCampos[nl][1],1,3) .AND. alltrim(aCampos[nl][1])<>"C6_VALOR";
											   .AND. alltrim(aCampos[nl][1])<>"C6_NUM"
			if SC6->(FieldPos(aCampos[nl][1]))>0 //Se o campo existir no dicionário
				if nPosC6Ent == nl //Data de entrega
					AADD(aEstIAx,{aCampos[nl][1] ,CTOD(XXX->&(aCampos[nl][1]))	,nil})
				elseif nPosC6PRC == nl //Preço unitário
					
					if XXX->&(aCampos[nl][1]) == 0
						RecLock("XXX",.F.)	
							XXX->&(aCampos[nl][1]):= 1
					    XXX->(MsUnlock())
				    endif
				    
				    AADD(aEstIAx,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
				else
					AADD(aEstIAx,{aCampos[nl][1] ,XXX->&(aCampos[nl][1])	,nil})
				endif
			endif
	    endif
	Next
	
	if nPosC6UM<=0 .AND. lTemPro 
		AADD(aEstIAx,{"C6_UM"	,SB1->B1_UM	,nil})
	endif
	//if nPosC6SEG<=0 .AND. lTemPro 
	//	AADD(aEstIAx,{"C6_SEGUM"	,SB1->B1_SEGUM	,nil})
	//endif
	if nPosC6PRC>0 .AND. nPosC6QTD>0
		AADD(aEstIAx,{"C6_VALOR"	,(XXX->&(aCampos[nPosC6PRC][1]) ) * (XXX->&(aCampos[nPosC6QTD][1]) )	,nil})
	endif
	if nPosC6LJ<=0
		AADD(aEstIAx,{"C6_LOJA"	,"01"	,nil})
	endif
	if nPosC6LOC<=0 .AND. lTemPro 
		AADD(aEstIAx,{"C6_LOCAL"	,SB1->B1_LOCPAD	,nil})
	endif
	if nPosC6DES<=0 .AND. lTemPro 
		AADD(aEstIAx,{"C6_DESCRI"	,SB1->B1_DESC	,nil})
	endif    
	if nPosC6PUn<=0
		AADD(aEstIAx,{"C6_PRUNIT"	,XXX->&(aCampos[nPosC6PRC][1])	,nil})
	endif
		
	if nPosC6TES<=0
		cTES:=fDefTes()
	
		AADD(aEstIAx,{"C6_TES"		,cTES			,nil}) //51A
	endif
	
	//if nPosC6CF<=0 .AND. lTemCli
	//	AADD(aEstIAx,{"C6_CF"		,If(SA1->A1_EST='SP','5949','6949')			,nil})
	//endif
    //PRECISA TRATAR A TES

	aEstIAx:= aSortX3(aEstIAx) //Chamo rotina para ordenar o array de itens de acordo com o SX3

	if lTemPro
    	if UPPER(alltrim(SB1->B1_TIPO)) = "PA" //somente verificar estrutura de produto acabado

		//Criação da ordem de produção
		aOrdPAx:={}

		AADD(aOrdPAx,{"AUTEXPLODE"	,"S"							,nil})
		AADD(aOrdPAx,{"C2_FILIAL"	,xFilial("SC2")					,nil})
		AADD(aOrdPAx,{"C2_NUM"		,XXX->&(aCampos[nPosNUM][1])	,nil})
		AADD(aOrdPAx,{"C2_ITEM"		,STRZERO(len(aOrdPro)+1,TamSx3("C2_ITEM")[1])	,nil})
		AADD(aOrdPAx,{"C2_SEQUEN"	,"001"							,nil})
		AADD(aOrdPAx,{"C2_PRODUTO"	,XXX->&(aCampos[nPosC6PRO][1])	,nil})
		AADD(aOrdPAx,{"C2_QUANT"	,XXX->&(aCampos[nPosC6QTD][1])	,nil})
		AADD(aOrdPAx,{"C2_LOCAL"	,"01"							,nil})
		AADD(aOrdPAx,{"C2_DATPRI"	,dDataBase						,nil})
		AADD(aOrdPAx,{"C2_DATPRF"	,dDataBase						,nil})
		AADD(aOrdPAx,{"C2_EMISSAO"	,dDataBase						,nil})	 
		AADD(aOrdPAx,{"C2_BATCH"	,""								,nil})	
	
		nPosC2Ite:= aScan( aOrdPAx, { |x| alltrim(x[1]) == "C2_ITEM"} )	
		nPosC2Pro:= aScan( aOrdPAx, { |x| alltrim(x[1]) == "C2_PRODUTO"} )
		
	   	AADD(aOrdPro,aOrdPAx)
	    //Fim da criação da ordem de produção
	
        endif
 	endif
	
	AADD(aEstIte,aEstIAx)
		 	
	//Armazena o código anterior
	cCodAnt:=XXX->&(aCampos[nPosNUM][1])
	
	XXX->(DbSkip())

	if alltrim(cCodAnt) <> alltrim(XXX->&(aCampos[nPosNUM][1]) )

		BEGIN Transaction
	        
	        if lTemEstr
			    cErroAux:= ""
			    lMsErroAuto:=.F.
			    
			    //Altera o parametro para não gerar pedido liberado
			    GrvProfSX1("MTA410","01","2")
			    
				//execauto do pedido de venda
				MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aEstCab, aEstIte, 3)

			    //Volta o parametro para o que era
			    GrvProfSX1("MTA410","01",xPreSel)
			    
				If lMsErroAuto
		
					cErroCon	:= ""
					aAutoErro 	:= GETAUTOGRLOG()
				    cErroCon	:= XLOG(aAutoErro) 
			    	
			    	GravaLog(.F.,cArq,cLin,cErroCon,cTab)
			    	
				    DisarmTransaction()
					cLin:=""
				Else
		        	SC2->(DbSetOrder(9)) //C2_NUM+C2_ITEM+C2_PRODUTO
	
	        		For nOp:=len(aOrdPro) to 1 STEP -1
			        	if !SC2->(DbSeek(xFilial("SC2")+PADR(ALLTRIM(cCodAnt),TamSx3("C2_NUM")[1])+ aOrdPro[nOp][nPosC2Ite][2]+ aOrdPro[nOp][nPosC2Pro][2]))
		        	   		
		        	   		lMsErroAuto:=.F.
		        	   		
		        	   		//Execauto da ordem de produção
		        	   		MsExecAuto({|x,Y| Mata650(x,Y)},aOrdPro[nOp],3) //Incluir Ordem de Produção	
		        	   		
		        	   		if lMsErroAuto
								cErroCon	:= ""
								aAutoErro 	:= GETAUTOGRLOG()
							    cErroCon	:= XLOG(aAutoErro)
		        	   		else
		        	   			lGerouOp:= .T.
		        	   		endif
			            endif
		        	Next
		        	
		        	if !empty(cErroCon)
		        		cErroAux:=" ,Erro na geração da Ordem de Produção: "+cErroCon
		        	endif
		        	
		        	if lGerouOp
		        		SC2->(DbSetOrder(1))
		        		if SC2->(DbSeek(xFilial("SC2")+alltrim(cCodAnt)))
                        	While SC2->(!EOF()) .and. SC2->C2_NUM==cCodAnt .and. SC2->C2_FILIAL==xFilial("SC2")

			        	   		lMsErroAuto:=.F.
                        		
                        		aVetor := { {"D3_OP"		,SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN  	,NIL},;
											{"D3_TM"		,"100"										,NIL}}
                        		
                        		//Execauto da Produção
                        		MSExecAuto({|x, y| mata250(x, y)},aVetor, 3 )  

			        	   		if lMsErroAuto
									cErroCon	:= ""
									aAutoErro 	:= GETAUTOGRLOG()
								    cErroCon	:= XLOG(aAutoErro)
			        	   		
			        	   			cErroAux+=" , Erro na execução de Produção: "+cErroCon
			        	   		endif

                        		SC2->(DbSkip())
                        	Enddo
		        		endif
		        	endif
		        	 				    	
			    	GravaLog(.T.,cArq,cLin,"Incluído com sucesso "+alltrim(cErroAux),cTab)
					cLin:=""
				
				EndIF
			
			else
				GravaLog(.F.,cArq,cLin,"Produto sem estrutura cadastrada",cTab)
				lTemEstr:=.F.
			endif
			            
		END Transaction

    endif

enddo
 
Return(.T.)


/*
Funcao      : RetCharInv()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Trata caracteres invalidos na integração.
Autor       : 
Data/Hora   :
*/                                 
*--------------------------------*
Static Function RetCharInv(cTexto)
*--------------------------------*
Local aCar := {"CHR(141)"}

For i:=1 to Len(aCar)
	If AT(IIF(LEFT(aCar[i],3) == "CHR",&(aCar[i]),aCar[i]),cTexto)>0
		If LEFT(aCar[i],3) == "CHR"
			cTexto:= STRTRAN(cTexto,&(aCar[i]),"")
		Else 
			cTexto:= STRTRAN(cTexto,aCar[i],"")
		EndIf
	EndIf
Next i

Return cTexto

/*
Funcao      : Xlog()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*-------------------------------*
Static Function XLOG(aAutoErro)  
*-------------------------------*     
LOCAL cRet := ""
LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=alltrim(substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; ")
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet

//Função para gravar o log no temporário
*------------------------------------------*
Static Function GravaLog(lStatus,cArq,cLin,cLog,cTab)
*------------------------------------------*
Local cTabela:="TRB"+cTab
             
RecLock(cTabela,.T.)
	(cTabela)->LSTATUS	:= lStatus
	(cTabela)->ID		:= alltrim(cvaltochar((cTabela)->(RECNO())))
	(cTabela)->TAB		:= cTab
	(cTabela)->USUARIO	:= UsrFullName(__cUserID)
	(cTabela)->DATAGE	:= ddatabase
	(cTabela)->HORA		:= TIME()
	(cTabela)->ARQUIVO	:= alltrim(cArq)
	(cTabela)->LINHA	:= alltrim(cLin)
	(cTabela)->LOG		:= alltrim(cLog)
MsUnlock()                        

RecLock("ZX0",.T.)
	ZX0->ZX0_STATUS	:= iif(lStatus,"OK","ERRO")
	ZX0->ZX0_TAB	:= cTab
	ZX0->ZX0_USER	:= UsrFullName(__cUserID)
	ZX0->ZX0_DATA	:= ddatabase
	ZX0->ZX0_HORA	:= TIME()
	ZX0->ZX0_ARQ	:= alltrim(cArq)
	ZX0->ZX0_LIN	:= alltrim(cLin)
	ZX0->ZX0_LOG	:= alltrim(cLog)
MsUnlock() 

Return()


//Rotina para ordenar o array com campos, de acordo com o X3
*---------------------------------*
Static Function aSortX3(aArray)
*---------------------------------*
Local aNewArray := {}
Local aOrdens	:= {}

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
aEval(aArray,{|x| SX3->(dbSeek(x[1])),IIF(Found(), AADD(aOrdens,SX3->X3_ORDEM), ) })

	for i:=1 to len(aArray)

		for j:=i to len(aArray)
			
			if aOrdens[j]<aOrdens[i]
				uTmp		:= aArray[i]
                aArray[i]	:= aArray[j]
                aArray[j]	:= uTmp
                
                uOrd		:= aOrdens[i]
                aOrdens[i]	:= aOrdens[j]
                aOrdens[j]	:= uOrd
			endif
			
		next
			    
	next

Return(aArray)


/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 04/11/2015 16:40
*/

*-------------------------------------------*
Static Function EnviaEma(cHtml,cSubject,cTo)
*-------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""
//Local cTo			:= "matheus.massarotto@hlb.com.br" //alterar aqui remover aqui

Default cTo		 := ""
Default cSubject := ""

if cEmpAnt $ "99" .OR. "TESTE" $ alltrim(UPPER(GetEnvServer()))
	cTo := ""
	
	if cEmpAnt $ "99"
		cTo := ""
	endif
	
endif

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   


cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)


cFrom			:= '"Integração"<'+cAccount+'>'


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      BCC "log.sistemas@hlb.com.br";
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "log.sistemas@hlb.com.br";
      SUBJECT cSubject BODY cHtml ATTACHMENT cAttachment RESULT lOK
      //SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
	//conout("--->>> E-mail enviado com sucesso, para o aprovador da proposta")
ELSE
	//conout("--->>> Falha no envio do e-mail, para o aprovador da proposta")
ENDIF

RETURN .T.


*---------------------------------------------------------------------*
Static Function SEndMail(cPara,cAssunto,cTexto,aFiles)
*---------------------------------------------------------------------*
Local lRetMail 		:= .T.
Local oMessage
Local oMail
Local cSMTPServer	:= GetMV("MV_RELSERV")
Local cSMTPUser		:= GetMV("MV_RELACNT")
Local cSMTPPass		:= GetMV("MV_RELPSW" )
Local cMailFrom		:= GetMV("MV_RELFROM")
Local lUseAuth		:= GetMv("MV_RELAUTH")
Local nPort			:= 587
Local cDirMail		:= "\anexoemail\"

MakeDir(cDirMail)//Cria diretorio \anexoemail\ ROOTPATH

cAssunto := "Integracao de arquivos "

cTexto := ' <table class="MsoNormalTable" style="WIDTH: 450pt" cellspacing="0" cellpadding="0" width="600" border="0">
cTexto += ' <tbody>
cTexto += ' <tr>
cTexto += ' <td style="PADDING-BOTTOM: 15pt; PADDING-TOP: 15pt; PADDING-LEFT: 15pt; PADDING-RIGHT: 15pt" valign="top">
cTexto += ' <div style="MARGIN-BOTTOM: 5pt; MARGIN-TOP: 5pt">
cTexto += ' <p class="MsoNormal" style="mso-margin-top-alt: auto; mso-margin-bottom-alt: auto"><span style="font-family: Georgia, serif;"><span style="color: rgb(153, 0, 153); font-size: 30pt;"></span><font color="#990099" style="font-size: 30pt;">Integração</font><br><font size="5">Arquivos</font></span></p>
cTexto += ' <div class="MsoNormal" style="TEXT-ALIGN: center; mso-margin-top-alt: auto; mso-margin-bottom-alt: auto" align="center">
cTexto += ' <hr style="COLOR: black" align="center" size="1" width="100%" noshade="">
cTexto += ' </div></div>
cTexto += ' <p class="MsoNormal" style="mso-margin-top-alt: auto; mso-margin-bottom-alt: auto"></p>
cTexto += ' <p class="margin"><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif; COLOR: black"><br></span></b></p><p class="margin"><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif; COLOR: black">Prezados(as)</span></b><b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif">,</span></b><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif"></span></p>
cTexto += ' <p class="MsoNormal"><font face="Calibri, sans-serif"><span style="font-size: 14.6667px; line-height: 16.8667px;">O(s) arquivo(s) foi(ram) processado(s).&nbsp;</span></font></p><font face="Calibri, sans-serif"><span style="font-size: 11pt;"><strong></strong></span></font>
cTexto += ' <p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"></p><p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><br></p>
cTexto += ' <p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><b><span style="FONT-SIZE: 9pt; COLOR: black">&nbsp;</span></b></p>
cTexto += ' <p class="MsoNormal"><font face="Arial, sans-serif" size="2" color="#ff0000"><b>E-mail informativo enviado automaticamente.</b></font></p><p class="MsoNormal" style="font-family: Calibri, sans-serif; font-size: 11pt;"><b style="font-size: 14.6667px;"><span style="font-size: 6.5pt; font-family: Arial, sans-serif; color: rgb(116, 118, 120);"><br></span></b></p><span style="FONT-SIZE: 11pt; FONT-FAMILY: '+"'"+'Calibri'+"'"+',sans-serif">
cTexto += ' <p class="MsoNormal"><b><span style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">©2015 HLB BRASIL -&nbsp; Todos os direitos reservados</span></b></p>
cTexto += ' <p class="MsoNormal"><b><span style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678"><a href="http://www.grantthornton.com.br/" target="_blank"><span lang="EN-US">www.GrantThornton.com.br</span></a></span></b><b><span lang="EN-US" style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678"><br></span></b><b><span lang="EN-GB" style="FONT-SIZE: 6.5pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">Member of HLB BRASIL International Ltd</span></b><b><span lang="EN-US" style="FONT-SIZE: 8pt; FONT-FAMILY: '+"'"+'Arial'+"'"+',sans-serif; COLOR: #747678">.</span></b><span lang="EN-US"></span></p></span>
cTexto += ' </td>
cTexto += ' </tr>
cTexto += ' </tbody>
cTexto += ' </table>

// Somente homologação
//cPara	:= "wederson.santana.ext@hlb.com.br"//UsrRetMail( __cUserID ) //email do usuário logado

oMail := TMailManager():New()
oMail:SetUseSSL(.T.)
oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort )
oMail:SetSmtpTimeOut( 120 )
nErro := oMail:SmtpConnect()
	
If lUseAuth
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
	      
		If nErro <> 0
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			//MsgAlert("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')',"AKRON")
			lRetMail := .F.
		EndIf
EndIf
	
If nErro <> 0
	      
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		//MsgAlert(cMAilError+CRLF+"Erro de Conexão SMTP "+str(nErro,4)+CRLF+'Desconectando do SMTP',"AKRON")
		oMail:SMTPDisconnect()
		lRetMail := .F.
	      
EndIf

If lRetMail
	
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := "Integracao "+capital(alltrim(FWEmpName(cEmpAnt)))+"<"+cMailFrom+">"
	oMessage:cTo      := alltrim(cPara) 
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cTexto
	oMessage:MsgBodyType( "text/html" )
	
	For i := 1 to len(aFiles)	
		CpyT2S( aFiles[i], cDirMail, .F. )
	Next i
	
	compacta(cDirMail)
	sleep(4000)
	
	For i := 1 to Len(aFiles)
		//oMessage:AttachFile ( cDirMail + substring(aFiles[i],RAT("\",aFiles[i])+1,len(aFiles[i])) )
		oMessage:AttachFile ( cDirMail + "arquivos.rar" )
	Next i
	
	Processa( {|| nErro := oMessage:Send( oMail ) }, "Aguarde...", "Processando envio de emails...",.F.)
           
	If nErro <> 0
		xError := oMail:GetErrorString(nErro)
		MsgAlert("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")","HLB")
		lRetMail := .F.
	Else
		//cLog += "Email enviado para " + Alltrim(cPara) + " ref. NF " + CRLF
	Endif
	
	oMail:SMTPDisconnect()           
	
	//Exclui os arquivos existentes nos diretórios
	aFilesDel := Directory(cDirMail+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirMail+ aFilesDel[i][1])
	Next i
	
EndIf

Return(lRetMail)

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar o arquivo(boleto html)
Autor       : Matheus Massarotto
Data/Hora   : 01/08/2012
*/
*----------------------------------------*
Static Function compacta(cLocRar)
*----------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
//Local cArqRar	:=SUBSTR(cArquivo,1,RAT(".",cArquivo))+"rar"
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ '+cRootPath+cLocRar+'arquivos.rar '+cRootPath+cLocRar+'*'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet:=WaitRunSrv( cCommand , lWait , cPath )


Return(lRet)


Static Function V2_Prod(cArq)

Local aCampos:= {{"B1_COD"	,"C"	,25	,0},;
				{"B1_UM"	,"C"	,2	,0},;
				{"B1_POSIPI","C"	,10	,0},;
				{"B1_IPI"	,"C"	,5	,0},;
				{"B1_CONTA"	,"C"	,10	,0},;
				{"B1_DESC"	,"C"	,120,0},;
				{"B5_CEME"	,"C"	,500,0}}

 
//Cria o temporário
cArqTrab := CriaTrab(aCampos,.t.)   
dbUseArea(.t.,,cArqTrab,"XXX",.F.,.F.) 
cArqTemp := CriaTrab(nil,.F.)
IndRegua("XXX", cArqTemp, (aCampos[1][1]),,,"Selecionando Registros ...",.T.)// Criando Índice Temporário

append from (cArq) SDF



Return 
/*
*------------------------------------*
Static Function GeraOP(aMATA650,nOpc)
*------------------------------------*-
Local nPosNum	:= aScan( aMATA650, { |x| alltrim(x[1]) == "C2_NUM"} )
Local nPosIte	:= aScan( aMATA650, { |x| alltrim(x[1]) == "C2_ITEM"} )
Local nPosSeq	:= aScan( aMATA650, { |x| alltrim(x[1]) == "C2_SEQUEN"} )

Local nOpc		:= 3

Private lMsErroAuto	:= .F.
 
DbselectArea("SC2")
SC2->(DbSetOrder(1))  // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
if SC2->(DbSeek(xFilial("SC2")+aMata650[nPosNum][2]+aMata650[nPosIte][2]+aMata650[nPosSeq][2]))
	nOpc:= 4 
	
	//Se não encontrou, é alteração
endif
     
MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

If lMsErroAuto
	cErroCon	:= ""
	aAutoErro 	:= GETAUTOGRLOG()
    cErroCon	:= XLOG(aAutoErro) 
    	
    DisarmTransaction()

Else
	cErroCon:=""    
EndIf
 

Return(cErroCon)


*--------------------------*
Static Function GeraOP2()
*--------------------------*
Local aArea			:= GetArea()
Local cNum			:= SC5->C5_NUM
Local lMsErroAuto	:= .F.

DbSelectArea("SC6")
SC6->(DbSetOrder(1))
if SC6->(DbSeek(xFilial("SC6")+cNum+StrZero(1,TamSx3("C6_ITEM")[1] )))
	
	DbselectArea("SC2")
	SC2->(DbSetOrder(1))  // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
			
	While SC6->(!EOF()) .AND. SC6->C6_NUM == cNum

		if SC2->(DbSeek(xFilial("SC2")+cNum ))
			aOrdPro := {}

			AADD(aOrdPro,{"C2_FILIAL"	,xFilial("SC2")				,nil})
			AADD(aOrdPro,{"C2_PRODUTO"	,SC6->C6_PRODUTO			,nil})
			AADD(aOrdPro,{"C2_NUM"		,cNum						,nil})
			AADD(aOrdPro,{"C2_ITEM"		,"01"						,nil})
			AADD(aOrdPro,{"C2_SEQUEN"	,"001"						,nil})
			AADD(aOrdPro,{"C2_QUANT"	,SC6->C6_QTDVEN				,nil})
			AADD(aOrdPro,{"C2_LOCAL"	,"01"						,nil})
			AADD(aOrdPro,{"C2_DATPRI"	,dDataBase					,nil})
			AADD(aOrdPro,{"C2_DATPRF"	,dDataBase					,nil})
			AADD(aOrdPro,{"C2_EMISSAO"	,dDataBase					,nil})				

			MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,4) //Alterar Ordem de Produção

			if lMsErroAuto
				MostraErro()
			else
				Reclock("SC6",.F.)
					SC6->C6_ITEMOP	:= "01"
					SC6->C6_OP		:= "S"
					SC6->C6_NUMOP	:= cNum
				MsUnlock()	
			endif

		endif

		SC6->(DbSkip())	
	Enddo

endif

RestArea(aArea)
Return
*/


/*
Função  : GrvProfSX1()
Objetivo: Altera o valor do pergunte no SX1
Autor   : 
Data    : 
*/
*-------------------------------------------------*
 Static Function GrvProfSX1(cGrupo,cPerg,xValor)
*-------------------------------------------------*
Local cUserName := ""
Local cMemoProf := ""
Local cLinha    := ""

Local nLin := 0

Local aLinhas := {}

cGrupo := PadR(cGrupo,Len(SX1->X1_GRUPO)," ")

SX1->(DbSetOrder(1))
If SX1->(DbSeek(cGrupo+cPerg,.F.))

	If Type("__cUserId") == "C" .and. !Empty(__cUserId)
		PswOrder(1)
  		PswSeek(__cUserID)
		cUserName := cEmpAnt+PswRet(1)[1,2]
	    
		//Pesquisa o pergunte no Profile
		If FindProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")
            
			//Armazena o memo de parametros do pergunte
			cMemoProf := RetProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")

			//Gera array com todas as linhas dos parametros	        
			For nLin:=1 To MlCount(cMemoProf)
				aAdd(aLinhas,AllTrim(MemoLine(cMemoProf,,nLin))+ CHR(13) + CHR(10))
			Next
			
			//Guarda o back-up do valor do parâmetro selecionado
			xPreSel := Substr(aLinhas[Val(cPerg)],5,1) 
			
			//Monta uma linha com o novo conteudo do parametro atual.
			// Pos 1 = tipo (numerico/data/caracter...)
			// Pos 2 = '#'
			// Pos 3 = GSC
			// Pos 4 = '#'
			// Pos 5 em diante = conteudo.
            cLinha = SX1->X1_TIPO + "#" + SX1->X1_GSC + "#" + If(SX1->X1_GSC == "C", cValToChar(xValor),AllTrim(Str(xValor)))+ CHR(13) + CHR(10)
			
			//Grava a linha no array
			aLinhas[Val(cPerg)] = cLinha
			
			//Monta o memo atualizado
			cMemoProf := ""
			For nLin:=1 To Len(aLinhas)
   				cMemoProf += aLinhas[nLin]
       		Next
            
			//Grava o profile com o novo memo
			WriteProfDef(cUserName,cGrupo,"PERGUNTE", "MV_PAR", ; 	// Chave antiga
                    	 cUserName,cGrupo, "PERGUNTE", "MV_PAR", ; 	// Chave nova
     					 cMemoProf) 								// Novo conteudo do memo.
			
		//Caso não exista Profile alterar o SX1
		Else
			//Gravando conteudo antigo
			xPresel:= SX1->X1_PRESEL
			Do Case
				Case SX1->X1_GSC == "C"
					Reclock ("SX1",.F.)
					SX1->X1_PRESEL := Val(cValToChar(xValor))
					SX1->(MsUnlock())
			EndCase
		EndIf
	EndIf
EndIf

Return

/*
Função  : fDefTes()
Objetivo: Função de seleção de TES copiada de antiga função:
			Wederson L. Santana - Pryor Tecnology - 14/07/05
			Cria Parametros utilizados pela rotina se não existir
			29/08/05 --> Carrega as TES conforme condições infomadas por
			pela Roseli/Rosana
Autor   : 
Data    : 
*/
*------------------------------*
Static Function fDefTes()
*------------------------------*
Local _cRet:=""

DbSelectArea("SX6")
//--------------------------------------------------ESTADOS
If! DbSeek("  MV_FATUF01")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATUF01"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Estados Red. BC 73,34%" 
	X6_CONTEUD  := "RS/SC/PR/SP/MG/RJ"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATUF02")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATUF02"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Estados Red. BC 73,43%" 
	X6_CONTEUD  := "ES/BA/GO/MS/MT/TO/AC/AM/PA/RR/RN/SE/CE/RO/PB/AL/AP/PI/PE/MA"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------C1P01
If! DbSeek("  MV_FATES01")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES01"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS com IPI" 
	X6_DESC1    := "/Red BC 73,34%)"
	X6_CONTEUD  := "85A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES02")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES02"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS sem IPI" 
   X6_DESC1    := "/Red BC 73,34%)"
	X6_CONTEUD  := "70A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES03")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES03"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS com IPI" 
	X6_DESC1    := "/Red BC 73,43%)"
	X6_CONTEUD  := "93F"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES04")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES04"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS sem IPI" 
	X6_DESC1    := "/Red BC 73,43%)"
	X6_CONTEUD  := "71A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------BELT
If! DbSeek("  MV_FATES05")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES05"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-BELT(Importado,ICMS com IPI) " 
	X6_CONTEUD  := "74A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES06")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES06"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-BELT(Importado,ICMS sem IPI)" 
	X6_CONTEUD  := "73A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------99999
If! DbSeek("  MV_FATES07")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES07"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-99999(Importado,ICMS com IPI) " 
	X6_CONTEUD  := "51A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES08")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES08"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-99999(Importado,ICMS sem IPI)" 
	X6_CONTEUD  := "50A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------Nacional
If! DbSeek("  MV_FATES09")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES09"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Nacional,ICMS com IPI " 
	X6_CONTEUD  := "51A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES10")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES10"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Nacional,ICMS sem IPI" 
	X6_CONTEUD  := "50A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------Importado
If! DbSeek("  MV_FATES11")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES11"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Importado,ICMS com IPI " 
	X6_CONTEUD  := "74A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES12")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES12"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Importado,ICMS sem IPI" 
	X6_CONTEUD  := "73A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
//--------------------------------------------------------------------------------Serviços
If! DbSeek("  MV_FATES13")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES13"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Faturamento servicos" 
	X6_CONTEUD  := "91X"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
//--------------------------------------------------------------------------------Revenda
If! DbSeek("  MV_FATES14")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES14"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Revenda" 
	X6_CONTEUD  := "73N"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
//--------------------------------------------------------------------------------Demais Produtos
If SubStr(SB1->B1_ORIGEM,1,1)$ "0"     //-----------------------------------------Nacional
   _cRet:=If(AllTrim(SA1->A1_TIPO)$"R",GetMv("MV_FATES10"),GetMv("MV_FATES09"))
Endif   
If SubStr(SB1->B1_ORIGEM,1,1)$ "1" //-----------------------------------------Importado  
   _cRet:=If(AllTrim(SA1->A1_TIPO)$"R",GetMv("MV_FATES12"),GetMv("MV_FATES11"))
Endif

If "CIP01" $ SB1->B1_COD
   cParam1 :=GetMv("MV_FATUF01")     //Estados do Sul/Sudeste,exceto ES.
   cParam2 :=GetMv("MV_FATUF02")     //Estados do Norte/Nordeste e ES.
   If AllTrim(SA1->A1_EST) $ cParam1 
      _cRet := GetMv("MV_FATES01")   //ICMS com IPI na base.
      If AllTrim(SA1->A1_TIPO) $ "R" 
         _cRet :=GetMv("MV_FATES02") //ICMS sem IPI na base.
      EndIf
   Endif   
   If AllTrim(SA1->A1_EST) $ cParam2 
      _cRet := GetMv("MV_FATES03")   //ICMS com IPI na base.       
      If AllTrim(SA1->A1_TIPO) $ "R" 
         _cRet :=GetMv("MV_FATES04") //ICMS sem IPI na base.
      EndIf
   Endif
Endif
   
If "99999" == SUBSTR(SB1->B1_COD,1,5) .OR. "BELT" == SUBSTR(SB1->B1_COD,1,4) .OR. "TD BELT" == SUBSTR(SB1->B1_COD,1,7)//AOA - Inclusão de BELT e TD BELT
       _cRet := GetMv("MV_FATES07")   //ICMS com IPI na base.
       If AllTrim(SA1->A1_TIPO) $ "R" 
          _cRet :=GetMv("MV_FATES08") //ICMS sem IPI na base.
       EndIf
Endif

If "88888" $ SB1->B1_COD
   _cRet := GetMv("MV_FATES13")
Endif

If "BELT US" == SUBSTR(SB1->B1_COD,1,7) .OR. "TD BELT US" == SUBSTR(SB1->B1_COD,1,10) //AOA - Alterado de BELT para BELT US
       _cRet := GetMv("MV_FATES05")   //ICMS com IPI na base.
       If AllTrim(SA1->A1_TIPO) $ "R" 
          _cRet :=GetMv("MV_FATES06") //ICMS sem IPI na base.
       EndIf
Endif  
//Solicitação do matheus.rossi(intralox) em e-mail enviado no dia 11/02/2016 as 15:42
if UPPER(SUBSTR(SB1->B1_COD,1,1))=="S"
	_cRet := GetMv("MV_FATES14")
endif

Return(_cRet)

//Função para retornar o tipo do produto
*-----------------------------*
Static Function TipoPro(cCod)
*-----------------------------*
Local cRet	:= ""    

Do Case

	Case Substr(cCod,1,1)=="B"
	
		if Substr(cCod,1,5)=="BELT*"
			cRet:="PA"
		else   //BELT US*
			cRet:="ME"
		endif
	
	Case Substr(cCod,1,1)=="T"

		if Substr(cCod,1,7)=="TDBELT*"
			cRet:="PA"
		elseif Substr(cCod,1,8)=="TD BELT*"
			cRet:="PA"
		else	//TD BELT US*
			cRet:="ME"
		endif
	
	Case Substr(cCod,1,1)=="E"

		if Substr(cCod,1,2)=="E2"
			cRet:="MP"
		else
			cRet:="ME"
		endif
			
	Case Substr(cCod,1,1)=="D"

		if Substr(cCod,1,3) $ "D2C/D2E/D2F/D2G/D9F"
			cRet:="MP"
		else
			cRet:="ME"
		endif
	
	//AOA - 20/10/2016 - Inclusão 1MOD e ZTR para tipo PA
	Case Substr(cCod,1,4)=="1MOD"
		cRet:="PA"
	
	Case Substr(cCod,1,3)=="ZTR"
		cRet:="PA"
							
	Case Substr(cCod,1,1)=="A"
		cRet:="ME"
	Case Substr(cCod,1,1)=="C"
		cRet:="ME"
	Case Substr(cCod,1,1)=="M"
		cRet:="ME" 
	Otherwise	//M/R/F/G
		cRet:="MP" 
		
End Case

Return(cRet)
