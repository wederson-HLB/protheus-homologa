#include "protheus.ch"                      
#include "fwbrowse.ch"
#include "tbiconn.ch" 

User Function X2COM001()
Local aColsNFS		:= {}
Local aHeaderNFS	:= {}
Local oDlg
Local nOpcA			:= 0
Local oGetNFS
Local cNumPc        := SC7->C7_NUM
Local nValorBx      := 0
Local cItem         := ""
Local cItOrig       := ""
Local nPosDtf       := 0

aAdd(aHeaderNFS,{ ""				,"ENABLE"	 ,"@BMP"						,2						 ,0							,								/*VALIDACAO*/,		,"C",		,"V",,,,"V"} )
aAdd(aHeaderNFS,{ "Item"			,"C7_ITEM"	 ,PesqPict("SC7","C7_ITEM")		,Tamsx3("C7_ITEM")[1]	 ,Tamsx3("C7_ITEM")[2]		,""								/*VALIDACAO*/,""	,"C",""		,"V",,,,"V"} )
aAdd(aHeaderNFS,{ "Produto"	  		,"C7_PRODUTO",PesqPict("SC7","C7_PRODUTO")	,Tamsx3("C7_PRODUTO")[1] ,Tamsx3("C7_PRODUTO")[2]	,""								/*VALIDACAO*/,""	,"C",""		,"V",,,,"V"} )
aAdd(aHeaderNFS,{ "Descrição"		,"C7_DESCRI" ,PesqPict("SC7","C7_DESCRI")	,Tamsx3("C7_DESCRI")[1]	 ,Tamsx3("C7_DESCRI")[2]	,""								/*VALIDACAO*/,""	,"C",""		,"V",,,,"V"} )
aAdd(aHeaderNFS,{ "Quantidade"		,"C7_QUANT"	 ,PesqPict("SC7","C7_QUANT")	,Tamsx3("C7_QUANT")[1]	 ,Tamsx3("C7_QUANT")[2]		,""								/*VALIDACAO*/,""	,"N",""		,"V",,,,"V"} )
aAdd(aHeaderNFS,{ "Total"		    ,"C7_PRECO"	 ,PesqPict("SC7","C7_PRECO")	,Tamsx3("C7_PRECO")	[1]	 ,Tamsx3("C7_PRECO")[2]	    ,""	                            /*VALIDACAO*/,""	,"N",""	    ,"V",,,,"V"} )
aAdd(aHeaderNFS,{ "Saldo"		    ,"C7_TOTAL"	 ,PesqPict("SC7","C7_TOTAL")	,Tamsx3("C7_TOTAL")	[1]	 ,Tamsx3("C7_TOTAL")[2]		,""				                /*VALIDACAO*/,""	,"N",""	    ,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Entrega"			,"C7_DATPRF" ,PesqPict("SC7","C7_DATPRF")   ,Tamsx3("C7_DATPRF")[1]	 ,Tamsx3("C7_DATPRF")[2]	,""	                            /*VALIDACAO*/,""	,"D",""  	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "C.Custo"			,"C7_CC"	 ,PesqPict("SC7","C7_CC")	    ,Tamsx3("C7_CC")[1]	     ,Tamsx3("C7_CC")[2]		,"Vazio().or.Existcpo('CTT')"	/*VALIDACAO*/,""	,"C","CTT"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Observação"		,"C7_OBSM"	 ,PesqPict("SC7","C7_OBSM")		,Tamsx3("C7_OBSM")[1]	 ,0							,""								/*VALIDACAO*/,""	,"C",""		,"V",,,,"V"} )

SC7->(dbSetOrder(1))
If SC7->(dbSeek(xFilial("SC7")+cNumPc))

   While! SC7->(Eof()).And.cNumPc == SC7->C7_NUM
		 If SC7->C7_P_CTRCT == "N"
            nValorBx += SC7->C7_TOTAL
		 EndIf
         SC7->(dbSkip())
		 cItem:= Iif(SC7->C7_ITEM>cItem,SC7->C7_ITEM,cItem)
   EndDo
   
EndIf
cItem:= StrZero(Val(cItem)+1,4)

SC7->(dbSetOrder(1))
If SC7->(dbSeek(xFilial("SC7")+cNumPc))

   While! SC7->(Eof()).And.cNumPc == SC7->C7_NUM
		 If SC7->C7_P_CTRCT == "S"
		    //                            1                  2          3              4            5               6                   7                8          9                      
			aAdd(aColsnfs,{fStatus(SC7->C7_TOTAL-nValorBx),cItem,SC7->C7_PRODUTO,SC7->C7_DESCRI,SC7->C7_QUANT,SC7->C7_TOTAL,SC7->C7_TOTAL-nValorBx,sc7->C7_DATPRF,SC7->C7_CC,SC7->C7_OBSM,.F.})
			cItOrig := SC7->C7_ITEM
		 EndIf
         SC7->(dbSkip())
   EndDo

EndIf

DEFINE MSDIALOG oDlg TITLE "Controle do saldo do pedido pelo valor" FROM 0,0 To 500,900 PIXEL Style 1 Color CLR_BLACK,CLR_WHITE

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.,.T.)

oFWLayer:addLine("L1",100,.F.)
oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
oFWLayer:AddWindow("C1"		,"oPanel","Específico - Marici"	,100,.F.,.T.,,"L1",{ || })
oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")

oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
oPanel1:Align := CONTROL_ALIGN_TOP

oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL

@ 06,05	Say "Verifique a disponibilidade de saldo para utilização."	OF oPanel1 PIXEL
@ 18,05 Say "Obs: O saldo principal do pedido não poderá ser alterado após movimentação."	OF oPanel1 PIXEL

@ 06,330 BitMap ResName "ENABLE"   				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 06,342 Say "Saldo disponível"			        Size 120,10 OF oPanel1 PIXEL
@ 15,330 BitMap ResName "DISABLE"  				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 15,342 Say "Saldo indisponível"	            Size 120,10 OF oPanel1 PIXEL
//@ 24,330 BitMap ResName "BR_PRETO" 				Size  10,10 OF oPanel1 PIXEL NOBORDER
//@ 24,342 Say "XML com Chave/N.Fiscal Inválida"	Size 120,10 OF oPanel1 PIXEL

oFolder := TFolder():New(0,0,{ "Pedido de compras: "+cNumPc},{},oPanel2,,,, .T., .F.,(oPanel2:NCLIENTWIDTH/2)-2,(oPanel2:NCLIENTHEIGHT/2)-2,,.T.)

oGetNFS:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oFolder:aDialogs[1],aHeaderNFS,aColsNFS)
oGetNFS:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetNFS:OBROWSE:NFREEZE := 1

ACTIVATE MSDIALOG oDlg ON INIT UTBarMnu(oDlg,	{|| (nOpcA:=1,oDlg:End())}, {|| (nOpcA:=0,oDlg:End())}, {},{},.F.,.F.,.F.,0,.T.) CENTER

If nOpcA==1
  
   nPosItem := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_ITEM"})
   nPosProd := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_PRODUTO"})
   nPosDesc := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_DESCRI"}) 
   nPosQtd  := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_QUANT"})	
   nPosPrc  := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_PRECO"})
   nPosTot  := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_TOTAL"})
   nPosCc   := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_CC"})	
   nPosObs  := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_OBSM"})	
   nPosDtf  := aScan(aHeader,{|a| AllTrim(a[2]) == "C7_DATPRF"})	

   aAdd(aCols, Array(Len(aHeader)+1))

   For nI := 1 To Len(aHeader)
      aCols[Val(cItem),nI] := aCols[Val(cItOrig),nI]
   Next 

   aCols[Val(cItem),nPosItem] :=aColsnfs[1,2]
   aCols[Val(cItem),nPosPrc]  :=aColsnfs[1,7]
   aCols[Val(cItem),nPosTot]  :=aColsnfs[1,7]
   aCols[Val(cItem),nPosDtf]  :=aColsnfs[1,8]
   aCols[Val(cItem),nPosCc]   :=aColsnfs[1,9]
   
   aCols[Val(cItem),Len(aHeader)+1] := .F.

EndIf

Return()

//---------------------

Static Function fStatus(nValor)
Local oCor

If nValor > 0
	oCor := LoadBitmap( GetResources(), "ENABLE" )
Else
    oCor := LoadBitmap( GetResources(), "DISABLE" )
EndIf

Return(oCor)

//---------------------

Static Function UTBarMnu(oDlg,bOk,bCancel,aButtons,aButText,lIsEnchoice,lSplitBar,lLegenda,nDirecao,lBGround)
Local nX 		:= 0

DEFAULT aButtons	:= {}
DEFAULT aButText	:= {}
DEFAULT lIsEnchoice := .T.
DEFAULT lSplitBar 	:= .T.
DEFAULT lLegenda  	:= .F.
DEFAULT nDirecao	:= 0
DEFAULT lBGround	:= .T.

If nDirecao == 0
	xDirecao := CONTROL_ALIGN_BOTTOM
ElseIf nDirecao == 1
	xDirecao := CONTROL_ALIGN_TOP
ElseIf nDirecao == 2
	xDirecao := CONTROL_ALIGN_RIGHT
Else
	xDirecao := CONTROL_ALIGN_LEFT
EndIf

nTam := 15

oButtonBar := FWButtonBar():new()
oButtonBar:Init(oDlg,nTam,15,xDirecao,.T.,lIsEnchoice)

If lIsEnchoice
	oButtonBar:setEnchBar( bOk, bCancel,,,,.T.)
Else
	//Criacao dos botoes de Texto OK e Cancela quando nao for enchoicebar
	If !Empty(bCancel)
		oButtonBar:addBtnText( "Cancela"	, "Cancela"	, bCancel,,,CONTROL_ALIGN_RIGHT, .T.)
		SetKEY(24,{||Eval(bCancel)})
	Endif
	
	If !Empty(bOk)
		oButtonBar:addBtnText( "OK"		, "Confirma", bOk,,,CONTROL_ALIGN_RIGHT)
		SetKEY(15,{||Eval(bOk)})
	Endif
Endif

//Criacao dos botoes de texto do usuario ou complementares
If Len(aButText) > 0
	For Nx := 1 to Len(aButText)
		oButtonBar:addBtnText( aButText[nX,1], aButText[nX,2],aButText[nX,3],,, CONTROL_ALIGN_RIGHT)
	Next
Endif

//Se a FAMYBAR esta sendo montada num browse e este tiver legenda alguns botoes padrao sao criados (botao imagem)
If lLegenda
	oButtonBar:addBtnImage( "PMSCOLOR"  , "Legenda"		, {|| FLegenda(FinWindow:cAliasFile, (FinWindow:cAliasFile)->(RECNO()))},, .T., CONTROL_ALIGN_LEFT)
Endif

// criacao dos botoes de imagem do usuario ou complementares
If Len(aButtons) > 0
	For Nx := 1 To Len(aButtons)
		oButtonBar:addBtnImage( aButtons[nX,1], aButtons[nX,3],aButtons[nX,2],,.T., CONTROL_ALIGN_LEFT)
	Next
EndIf

//altera o fundo da buttonbar
If lBGround
	oButtonBar:setBackGround( "toolbar_mdi.png", 000, 000, .T. )
EndIf

If lIsEnchoice
	oButtonBar:AITEMS[1]:LVISIBLECONTROL := .F.
	oButtonBar:AITEMS[2]:LVISIBLECONTROL := .F.
	oButtonBar:AITEMS[3]:LVISIBLECONTROL := .F.
	oButtonBar:AITEMS[4]:LVISIBLECONTROL := .F.
EndIf

Return Nil

