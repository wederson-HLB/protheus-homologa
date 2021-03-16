#Include "Protheus.ch"                      
#Include "FWBROWSE.CH"
#INCLUDE "TBICONN.CH" 

/*
Autor       : Wederson L. Santana
Data/Hora   : 29/09/2020    
Revisão		: MRP / DPE
Data/Hora   : 
Módulo      : Estoque -  PCP - Compras

*/

*---------------------*
User function U6GEN002
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
Private nMetSGG:= 0
Private oMetSGG
Private oSaySGG

Private lChkSB1:= .F.
Private lChkSGG:= .F.

Private aFiles 		:= {}
Private lEnvEmail	:= .T. //Parametro que define se envia e-mail na integração de arquivos

Private xPreSel		:= ""
Private cLocalArq   := ""
Private cCodSb1     := Space(TamSx3("B1_COD")[1])

Private aLogErros   := {}
Private aCpObg      := {"B1_DESC","B1_TIPO","B1_UM","B1_GRUPO","B1_CONTA","B1_LOCPAD","B1_POSIPI","B1_ORIGEM","B1_P_TIP"}

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
		
		AADD(aPanel,CriaPain(oWinDU,"Parâmetro","PMSTASK3",1,3))
		AADD(aPanel,CriaPain(oWinDU,"Prod-DPE" ,"PMSTASK3",1,3))
		AADD(aPanel,CriaPain(oWinDU,"Estr-DPE" ,"PMSTASK3",1,3))
						
		CriaTemp()
				
		TlParame(aPanel[1])
		TlProd(aPanel[2])
		TlEstr(aPanel[3])
		//TlClie(aPanel[4])
		//TlPedi(aPanel[5])
	
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

//tabela temporária de estrutura de produtos
if select("TRBSGG")>0
	TRBSGG->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSGG",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("TRBSGG",cIndex,"ID",,,"Selecionando Registro...")  

dbSelectArea("TRBSGG")
dbSetIndex(cIndex+OrdBagExt())
dbSetOrder(1)

Return

//Tela para seleção dos arquivos, são os parâmetros para processamento
*------------------------------*
Static Function TlParame(oLocal)
*------------------------------*
Local oGetSB1
Local oChkSB1
Local cLocaSB1 :=""

Local oGetProd
Local oChkProc
Local cLocaSGG :=""
 
oFontBtn:= TFont():New('Arial',,-16,.T.,.F.)

oGroup1:= tGroup():New(010,03,210,330,'Selecione os arquivos para integração - DPE:',oLocal,,,.T.)

oGroup3:= tGroup():New(250,03,350,730,'',oLocal,,,.T.)

oGroup4:= tGroup():New(010,360,210,730,'Iniciar o processo:',oLocal,,,.T.)

oTButton := TButton():New( 050, 400, " Integrar ",oLocal,{|| Controle(cLocaSB1,cLocaSGG,cCodSb1) },55,20,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )

oTButton :cTooltip = "Integrar"

oChkSB1 := TCheckBox():New(27,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSB1:bSetGet := {|| lChkSB1 }
oChkSB1:bLClicked := {|| lChkSB1:=!lChkSB1 }

@ 27,25 SAY "Arquivo de Produtos: " SIZE 100,10 OF oLocal PIXEL
oGetSB1:= TGet():New(25,100,{|u| if(PCount()>0,cLocaSB1:=u,cLocaSB1)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSB1')
oTButton := TButton():New( 25, 295, "...",oLocal,{||fAbreCSV(@cLocaSB1,oGetSB1)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

oGetSB1:Disable()

@ 60,10 Say "Project" SIZE 150,10 OF oLocal PIXEL
 oGetProd := TGet():New( 58, 030, { | u | If( PCount() == 0, cCodSb1, cCodSb1 := u ) },oLocal, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,"SB1","cCodSb1",,,,  )
//oGet1 := TGet():New( 028,076,bSetGet(_cProd),oDlg1,060,008,'@!',{||If(PCount()>0,U_XVERIF(_cProd,1),"")},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SB1","_cProd",,)	 

//----------------------------------------

oChkProc := TCheckBox():New(77,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkProc:bSetGet := {|| lChkSGG }
oChkProc:bLClicked := {|| lChkSGG:=!lChkSGG }

@ 77,25 SAY "Arquivo BOM: " SIZE 100,10 OF oLocal PIXEL
oChkProc:= TGet():New(75,120,{|u| if(PCount()>0,cLocaSGG:=u,cLocaSGG)}, oLocal,170,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSGG')
oTButton := TButton():New( 75, 295, "...",oLocal,{||fAbreCSV(@cLocaSGG,oGetProd)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
                 
oChkProc:Disable()

nMetSB1 := 0
oSaySB1 := tSay():New(300,30,{||'Processando produtos ...'},oLocal,,,,,,.T.,,,100,20)
oMetSB1 := TMeter():New(310,25,{|u|if(Pcount()>0,nMetSB1:=u,nMetSB1)},100,oLocal,650,26,,.T.)

oMetSB1:Hide()
oSaySB1:Hide()

nMetSGG := 0
oSaySGG := tSay():New(300,30,{||'Processando estrutura ...'},oLocal,,,,,,.T.,,,100,20)
oMetSGG := TMeter():New(310,25,{|u|if(Pcount()>0,nMetSGG:=u,nMetSGG)},100,oLocal,650,26,,.T.)

oMetSGG:Hide()
oSaySGG:Hide()

Return

//Função para controle do processamento, o que está marcado para ser executado
*-------------------------------------------------------------*
Static function Controle(cLocaSB1,cLocaSGG)
*-------------------------------------------------------------*
Local lRet		:= .F.
Local lTemMak   := .F.

aFiles:={} //Limpa o array que fica os arquivos para anexo

If lChkSB1
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
   
   If! Empty(cCodSb1)
   		SB1->(dbSetOrder(1))
   		If SB1->(dbseek(xFilial("SB1")+cCodSb1))

			oMetSGG:Show()
			oSaySGG:Show()
		
			If !LeArqDPE(cLocalArq,"SGG")
				oMetSGG:Hide()
				oSaySGG:Hide()
			Else
				lRet:=.T.
				AADD(aFiles,cLocalArq)
			EndIf

		Else
        	MsgInfo("Verifique cadastro para o produto: "+AllTrim(cCodSb1)+".","A t e n ç ã o")
		EndIf
    Else
        MsgInfo("Informe um cadastro válido.","A t e n ç ã o")
	EndIf     
	oBrowE:ExecuteFilter(.T.)
	oBrowE:Refresh()		
		
	lTemMak:=.T.
EndIf
	
if !lTemMak
	AVISO("Atenção", "Nenhuma opção selecionada", { "OK"}, 1)	
endif

if lRet
	
	//SEndMail(,,,aFiles)	


	AVISO("Concluído", "Fim do processamento do(s) arquivo(s), verifique os log(s)", { "OK"}, 1)	 
	oDlg:end()	
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


//Tela de visualização de log de estrutura de produtos
*------------------------------*
Static Function TlEstr(oLocal)
*------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowE DATA TABLE ALIAS "TRBSGG" OF oLocal			

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

oBrowE:SetFilterDefault('TAB == "SGG"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowE

Return

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
Local nPos		:= 0
Local lCpoFal	:=.F.
Local aCpoObrigat	:= {} 
Local cCpoFaltantes :=""
Local nHdle		:= 0
Local aColunas  :={}
Local aDadosCSV :={}
Local aDadosItem:={}
Local nAtual    :=0
Local nProx     :=0
Local nColunas  :=0
Local lSair     := .F.
Local lRet      := .F.
Local nI        := 1
Local lCampos   := .T.

DEFAULT cTab2	:= ""  

nHandle := FT_FUse(cArq)

If! nHandle = -1
    
    FT_FGoTop()

    nLast := FT_FLastRec()
    While !FT_FEOF()
           cLine  := FT_FReadLn()

           If FT_FRecno() == 1
                nAtual:=1
				nProx:=0
				While! lSair
				      nProx:= at(";",cLine,nAtual)
  					  If nProx == 0
					     lSair :=.T.
						 nProx := Len(cLine)+1
					  EndIf
				      aadd(aColunas,{SubStr(cLine,nAtual,(nProx - nAtual))})
					  nAtual := nProx+1
					  nColunas ++
				End
	       Else
			    lSair    :=.F.
                nAtual   :=1
				nProx    :=0
				nColunas :=0
				While! lSair 
				      nProx:= at(";",cLine,nAtual)
					  If nProx == 0
					     lSair :=.T.
						 nProx := Len(cLine)+1
					  EndIf
				      aadd(aDadosCSV,{SubStr(cLine,nAtual,(nProx - nAtual))})
					  nAtual := nProx+1
					  nColunas ++
				End
                aadd(aDadosItem,aDadosCSV)
				aDadosCSV :={}
			EndIf 

	         FT_FSKIP()
      End

EndIf

Do Case
	Case cTab == "SGG"

		lRet:=ExecASGG(aColunas,aDadosItem,cArq)//Chamada da função de execauto.
    
    Case cTab == "SB1"

    	For nI:=1 To Len(aCpObg)

	   		If AsCan(aColunas, {|x| AllTrim(x[1]) == AllTrim(aCpObg[nI]) }) == 0
               
			   lCampos:= .F.
			   
			   AAdd(aLogErros,{"Produto",AllTrim(aCpObg[nI]),FWSX3Util():GetDescription( AllTrim(aCpObg[nI]) )+" Campo obrigatório não informado.Verifique os dados no arquivo.",cArq})
               
	   		EndIf

		Next   

		If lCampos 

			lRet:=ExecDpe(aColunas,aDadosItem,cArq)//Chamada da função de execauto.

        Else
		    MsgInfo("Existem campos obrigatórios não informados."," A t e n ç ã o")
		EndIf
EndCase

If! lCampos
	If Len(aLogErros)>0 

   		fImprime(cArq)

	EndIf
EndIf

FT_FUSE()
	
Return(lRet)


//----------------------------------------------------------------------------------

Static Function ExecDpe(aColunas,aDadosItem,cArq)  

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
Local nX
Local nY
Local cCodProd := ""

//Campos comuns aos 2, Produtos e clientes
Local nPosCod	:= 1
Local nTotLin   := Len(aDadosItem)
Local nAumenta  := (100/(nTotLin-2)) 
Local cMens     := ""
Local lAltera   := .F.

Local nPosQE    := 0
Local nQtdQE    := 0
Local nPosLE    := 0
Local nQtdLE    := 0

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

nCurrent:=0 //Inicial o controle da régua

For nX:=1 To Len(aDadosItem)
	xAutoCab := {}
	
	nCurrent+=Round(nAumenta,2) // atualiza régua
	If nCurrent>100
	   nCurrent:=100
	EndIf
	oMetSB1:Set(nCurrent)
			
	nPosCod	 := aScan( aColunas, { |x| alltrim(x[1]) == "B1_COD"} )
    cCodProd := AllTrim(aDadosItem[nX][1][nPosCod])

	nPosQE	 := aScan( aColunas, { |x| alltrim(x[1]) == "B1_QE"} )
	nPosLE	 := aScan( aColunas, { |x| alltrim(x[1]) == "B1_LE"} )
		
	//SB1->(dbSetOrder(1))
	//If SB1->(dbSeek(xFilial("SB1")+cCodProd))
       //If SB1->B1_QE >0 .And. SB1->B1_LE >0

          //If nPosQE > 0 .And. nPosLE >0 
	      	//If Val(aDadosItem[nX][nPosQE][1])>0 .And. Val(aDadosItem[nX][nPosLE][1])>0
             	//nQtdQE := SB1->B1_QE
			 	//nQtdLE := SB1->B1_LE
			 	//Reclock("SB1",.F.)
			 	//SB1->B1_QE := 0
			 	//SB1->B1_LE := 0
			 	//mSunLock()
			//EndIf	 
		  //EndIf

	   //EndIf
	   //lAltera:= .T.
	//EndIf

	For nY:=1 to Len(aColunas)
		
		If SB1->(FieldPos(aColunas[nY][1])) > 0

           If lAltera 
		      If (AsCan(aCpObg, {|x| AllTrim(x) == AllTrim(aColunas[nY][1]) })) == 0

			  		If TAMSX3(aColunas[nY][1])[3]=="C"
						AADD(xAutoCab,{aColunas[nY][1] , UPPER(alltrim(aDadosItem[nX][nY][1]))	,nil})
					ElseIf TAMSX3(aColunas[nY][1])[3]=="N"
			       			If Val(StrTran(aDadosItem[nX][nY][1],",",".")) > 0
            	       			AADD(xAutoCab,{aColunas[nY][1] , Val(StrTran(aDadosItem[nX][nY][1],",","."))	, nil})
				   			EndIf	   
					Else
						AADD(xAutoCab,{aColunas[nY][1] , aDadosItem[nX][nY][1]	, nil})
					EndIf

			  EndIf

		   Else

				If TAMSX3(aColunas[nY][1])[3]=="C"
					AADD(xAutoCab,{aColunas[nY][1] , UPPER(alltrim(NoAcento(aDadosItem[nX][nY][1])))	,nil})
				ElseIf TAMSX3(aColunas[nY][1])[3]=="N"
			       		If Val(StrTran(aDadosItem[nX][nY][1],",",".")) > 0
            	       		AADD(xAutoCab,{aColunas[nY][1] , Val(StrTran(aDadosItem[nX][nY][1],",","."))	, nil})
				   		EndIf	   
				Else
					AADD(xAutoCab,{aColunas[nY][1] , aDadosItem[nX][nY][1]	, nil})
				EndIf

			EndIf

		EndIf	

	Next nY
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	If! dbSeek(xFilial("SB1")+cCodProd)

	   //MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,4)

	   //cMens:= "Alterado"

       //If lMsErroAuto
	      //If SB1->B1_QE >0 .And. SB1->B1_LE >0
	    	 //Reclock("SB1",.F.)
			 //SB1->B1_QE := nQtdQE
			 //SB1->B1_LE := nQtdLE
			 //mSunLock()
		  //EndIf	 
       //EndIf 

	   //Else

       MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,3)

	   cMens:= "Inclusão"

	   If lMsErroAuto

			cErroCon	:= ""
			aAutoErro 	:= GETAUTOGRLOG()
	    	cErroCon	:= SubStr(XLOG(aAutoErro),1,100 )
	   
			AAdd(aLogErros,{"Produto",cCodProd,cMens+"-"+Iif(Empty(cErroCon),"erro não identificado",cErroCon),cArq})
	    	
	    	lErro:=.T.
	    	DisarmTransaction()

		Else
	    
         	AAdd(aLogErros,{"Produto",cCodProd,cMens+" com sucesso",cArq})

		 	lErro:=.F.
		
		EndIF
	
	EndIf    
	
Next nX

If Len(aLogErros)>0 

   fImprime(cArq)

EndIf

Return(.T.)

//--------------------------------------------

Static Function ExecASGG(aColunas,aDadosItem,cArq)  
Local nI
Local nPosCod	:= 1
Local nTotLin   := Len(aDadosItem)
Local nAumenta  := (100/(nTotLin-2)) 

Local nPosItem	 := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "ITEM"} )
Local nPosQty	 := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "QTY"} )
Local nPosPartN  := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "PART NUMBER"} )
Local nPosStokN  := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "STOCK NUMBER"} )	
Local nPosObserv := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "MATERIAL"} )		

Local cItemAnt := ""
Local nTamAnt  := 0

Local cItem    := ""
Local nTamItem := 0
Local cCodComp := ""
Local nSequen  := 0
Local nQuant   := 0
Local cCodStok := ""
Local cObserv  := ""
Local cCodSup  := ""

nCurrent:=0 //Inicial o controle da régua

For nI:=1 To Len(aDadosItem)

	nCurrent+=Round(nAumenta,2) // atualiza régua
	If nCurrent>100
		nCurrent:=100
	EndIf
	oMetSGG:Set(nCurrent)

    cCodComp:= SubStr(aDadosItem[nI][nPosPartN][1],1,TamSx3("GG_COD")[1])
	nQuant  := Val(aDadosItem[nI][nPosQty][1])
	cCodStok:= SubStr(aDadosItem[nI][nPosStokN][1],1,TamSx3("GG_COD")[1])
	cObserv := SubStr(aDadosItem[nI][nPosObserv][1],1,TamSx3("GG_OBSERV")[1])

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cCodComp))

       If SB1->B1_MSBLQL <> "1"

          cItem    := StrTran(AllTrim(aDadosItem[nI][nPosItem][1]),".","")
	      nTamItem := Len(StrTran(AllTrim(aDadosItem[nI][nPosItem][1]),".",""))

		  If nTamItem == 1
            
			 dbSelectArea("SGG")
			 dbSetOrder(1)
			 If! dbSeek(xFilial("SGG")+cCodSb1+cCodComp)

             	 nSequen := Val(SGG->GG_TRT)+1

			     Reclock("SGG",.T.)
                 SGG->GG_FILIAL  := xFilial("SGG")
			     SGG->GG_COD     := cCodSb1
	             SGG->GG_COMP    := cCodComp
			     SGG->GG_QUANT   := nQuant
			 	 SGG->GG_PERDA   := 0
			 	 SGG->GG_TRT     := StrZero(nSequen,TamSx3("GG_OBSERV")[1])
			 	 SGG->GG_INI     := dDataBase
			 	 SGG->GG_FIM     := dDataBase
			 	 SGG->GG_FIXVAR  := "V"
			 	 SGG->GG_POTENCI := 0
			 	 SGG->GG_STATUS  := ""
			 	 SGG->GG_USUARIO := ""
			 	 SGG->GG_REVFIM  := "ZZZ"
	         	 SGG->GG_OBSERV  := SubStr(cObserv,1,TamSx3("GG_OBSERV")[1])
			     MsunLock()

				 AAdd(aLogErros,{"Estrutura",cCodComp,"Componente incluído com sucesso.",cArq})

			 EndIf	 

          Else

		      If Empty(cCodStok) 
                 
				 If SubStr(cItemAnt,1,nTamAnt) == SubStr(cItem,1,nTamAnt)

				    SB1->(dbSetOrder(1))
	                If SB1->(dbSeek(xFilial("SB1")+cCodSup))

                        If SB1->B1_MSBLQL <> "1"

				 			dbSelectArea("SGG")
			 				dbSetOrder(1)
			 				If! dbSeek(xFilial("SGG")+cCodSup+cCodComp)

             					nSequen := Val(SGG->GG_TRT)+1

                    			Reclock("SGG",.T.)
                    			SGG->GG_FILIAL  := xFilial("SGG")
			        			SGG->GG_COD     := cCodSup
	                			SGG->GG_COMP    := cCodComp
			        			SGG->GG_QUANT   := nQuant
			        			SGG->GG_PERDA   := 0
								SGG->GG_TRT     := StrZero(nSequen,TamSx3("GG_OBSERV")[1])
			        			SGG->GG_INI     := dDataBase
			        			SGG->GG_FIM     := dDataBase
			        			SGG->GG_FIXVAR  := "V"
			        			SGG->GG_POTENCI := 0
			        			SGG->GG_STATUS  := ""
			 					SGG->GG_USUARIO := ""
			 					SGG->GG_REVFIM  := "ZZZ"
	         					SGG->GG_OBSERV  := SubStr(cObserv,1,TamSx3("GG_OBSERV")[1])
			 					MsunLock()

								AAdd(aLogErros,{"Estrutura",cCodComp,"Componente incluído com sucesso.",cArq})

							EndIf	 

						 Else

                             //GravaLog(.F.,cCodSup+" - PRODUTO BLOQUEADO","SB1",cArq)		  
							 AAdd(aLogErros,{"Estrutura",cCodSup,"Componente com bloqueio no cadastro.",cArq})

					     EndIf 
  
					Else
                        
						//GravaLog(.F.,cCodSup+" - PRODUTO NAO CADASTRADO","SB1",cArq)		  
						AAdd(aLogErros,{"Estrutura",cCodSup,"Componente não cadastrado.",cArq})

					EndIf 	 
				 
				 EndIf

			  Else

			      SB1->(dbSetOrder(1))
	              If SB1->(dbSeek(xFilial("SB1")+cCodStok))

				     If SB1->B1_MSBLQL <> "1"

	 						dbSelectArea("SGG")
			 				dbSetOrder(1)
			 				If! dbSeek(xFilial("SGG")+cCodComp+cCodStok)

             					nSequen := Val(SGG->GG_TRT)+1

                    			Reclock("SGG",.T.)
                    			SGG->GG_FILIAL  := xFilial("SGG")
			        			SGG->GG_COD     := cCodComp
	                			SGG->GG_COMP    := cCodStok
			        			SGG->GG_QUANT   := nQuant
			        			SGG->GG_PERDA   := 0
								SGG->GG_TRT     := StrZero(nSequen,TamSx3("GG_OBSERV")[1])
			        			SGG->GG_INI     := dDataBase
			        			SGG->GG_FIM     := dDataBase
			        			SGG->GG_FIXVAR  := "V"
			        			SGG->GG_POTENCI := 0
			        			SGG->GG_STATUS  := ""
			 					SGG->GG_USUARIO := ""
			 					SGG->GG_REVFIM  := "ZZZ"
	         					SGG->GG_OBSERV  := SubStr(cObserv,1,TamSx3("GG_OBSERV")[1])
			 					MsunLock()

								AAdd(aLogErros,{"Estrutura",cCodStok,"Componente incluído com sucesso.",cArq}) 

					        EndIf
					 Else

					     AAdd(aLogErros,{"Estrutura",cCodStok,"Componente com bloqueio no cadastro.",cArq})

					 EndIf 
  
                  Else

		              //GravaLog(.F.,cCodStok+" - PRODUTO NAO CADASTRADO","SB1",cArq)		  
 				      AAdd(aLogErros,{"Estrutura",cCodStok,"Componente não cadastrado.",cArq})

                  EndIf

			  EndIf

          EndIf
    
	   Else

           //GravaLog(.F.,cCodComp+" - PRODUTO BLOQUEADO","SB1",cArq)
	       AAdd(aLogErros,{"Estrutura",cCodComp,"Produto com bloqueio no cadastro.",cArq})

	   EndIf

    Else
        //GravaLog(.F.,cCodComp+" - PRODUTO NAO CADASTRADO","SB1",cArq)
		AAdd(aLogErros,{"Estrutura",cCodComp,"Produto não cadastro.",cArq})
	EndIf
    cItemAnt := StrTran(AllTrim(aDadosItem[nI][nPosItem][1]),".","")
    nTamAnt  := Len(StrTran(AllTrim(aDadosItem[nI][nPosItem][1]),".",""))
	cCodSup  := cCodComp
Next

If Len(aLogErros)>0 

   fImprime(cArq)

EndIf


Return(.T.)

//------------------------------------------------
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

//------------------------------------------------

Static Function GravaLog(lStatus,cLog,cTab,cArq)
Local cTabela:="TRB"+cTab
             
RecLock(cTabela,.T.)
	(cTabela)->LSTATUS	:= lStatus
	(cTabela)->TAB		:= cTab
	(cTabela)->USUARIO	:= UsrFullName(__cUserID)
	(cTabela)->DATAGE	:= ddatabase
	(cTabela)->HORA		:= TIME()
	(cTabela)->ARQUIVO	:= alltrim(cArq)
	(cTabela)->LOG		:= alltrim(cLog)
MsUnlock()                        

RecLock("ZX0",.T.)
	ZX0->ZX0_STATUS	:= iif(lStatus,"OK","ERRO")
	ZX0->ZX0_TAB	:= cTab
	ZX0->ZX0_USER	:= UsrFullName(__cUserID)
	ZX0->ZX0_DATA	:= ddatabase
	ZX0->ZX0_HORA	:= TIME()
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

//----------------------------

Static Function fImprime(cArq)
	
SetPrvt("cString,cDesc1,cDesc2,cDesc3,cTamanho,aReturn")
SetPrvt("aOrd,cNomeProg,aLinha,nLastKey,nOrdem,cTitulo")
SetPrvt("cCabec,cCabec2,cCancel,m_pag,wNrel,cPerg")
SetPrvt("nLin,cIni,cFim,cArqTRB,_nCont,_aDetail,_aCabec")
	
cString  := ""
cDesc1   := "Este programa tem como objetivo emitir os "
cDesc2   := ""
cDesc3   := ""
cTamanho := "G"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
aOrd     := {}
cNomeProg:= "fImpLog"
aLinha   := {}
nLastKey := 0
nOrdem   := 0
cCabec 	:= "Cadastro            Código"
//           123456789D123456789V123456789T123456789Q123456789C123456789S123456789S123456789O123456789N123456789*123456789d123456789v123456789t123456789q123456789c123456789s123456789s123456789o123456789n123456789*123456789d123456789v
cCabec2  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
wnrel    := "fImpLog"            //Nome Default do relatorio em Disco
cPerg    := ""
m_pag    := 1
_aDetail := {}
_aCabec  := {}
cTitulo  := "Log processamento arquivo "+cArq

SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

If nLastKey == 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus( {|| fImpLog()} )
	
If aReturn[5] == 1
	Set Printer To
	Commit
	OurSpool(wnRel)
Endif

MS_FLUSH()
	
Return
	
//-------------------------------------------------------
	
Static Function fImpLog()
nLin:=100
	
For i:=1 To Len(aLogErros)
	If nLin >= 055
		Cabec(cTitulo,cCabec,cCabec2,cNomeProg,cTamanho,GetMv("MV_COMP"))
		nLin := 008
	Endif
		
	@ nLin,001 Psay aLogErros[i,1]
	@ nLin,010 Psay aLogErros[i,2]
	@ nLin,030 Psay aLogErros[i,3]
	@ nLin,130 Psay aLogErros[i,4]
	
	nLin++
Next
nLin++
roda(0,Space(10),cTamanho)
nLin++
	
Return                  

Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
cString := StrTran(cString,'"','')
Return cString
