#Include 'Totvs.ch'
#Include 'TopConn.ch'

/*
Funcao      : GTFAT012
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar pedido de remessa para armazenagem
Chamado     : 
Autor       : Leandro Brito ( BRL Consulting )
Data/Hora   : 16/03/2015     
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 04/09/2015
Obs         : 
Módulo      : Faturamento.
Cliente     : Todos
*/

*------------------------*
User Function GTFAT012
*------------------------*    

Local aArea      	:= GetArea()
Local chTitle    	:= "Grant Thorthon"

Local chMsg      	:= "Geração de Pedido de Remessa de Armazenagem"
Local cTitle

Local cText     	:= "Este programa tem como objetivo criar automaticamente o pedido de remessa de armazenagem a partir da nota de entrada de importacao. Para notas com os CFOPS "+GetNewPar('MV_P_0050','3101;3102')+" o valor do ICMS será adicionado no valor unitário de cada item."
Local bFinish    	:= { || .T. }

Local cResHead

Local lNoFirst
Local aCoord

Local aCamposVld	:= { 'C5_P_NOTA' , 'C5_P_SERIE' , 'C5_P_FORN' , 'C5_P_LOJA' , 'C5_P_IMP' , 'C5_P_EMISS' }
Local lDicOk		:= .T.         

Private oWizard
Private oGetResult

Private cNotaEnt    := Space( Len( SF1->F1_DOC ) )
Private cSerieEnt   := Space( Len( SF1->F1_SERIE ) )

Private cForn       := Space( Len( SA2->A2_COD ) )
Private cLoja       := Space( Len( SA2->A2_LOJA ) )

Private cResult     := ""
Private cTes        := Space( Len( SF4->F4_CODIGO ) )

Private cTipoPed    := ""

/*
	** Verifica se os campos customizados estão criados no ambiente
*/
AEVal( aCamposVld , { | x | If( lDicOk , lDicOk := SC5->( FieldPos( x ) ) > 0 , ) } )

If !lDicOk
	MsgAlert( 'A rotina não será executada, será necessario rodar compatibilizador. Favor entrar em contato com depto de TI.' )
	Return( .T. )			
EndIf

oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord ) 

oWizard:NewPanel ( "Filtros"               , "Preencher todos os parametros abaixo" , { || .T. }/*bBack*/ , { || ValidaFiltro() .And. TelaNF() }  ,bFinish ,, { || TelaFiltro() } /*bExecute*/  ) 
oWizard:NewPanel ( "Log da Operaçãoo"       , "" , { || .F. }/*bBack*/ , /*{ || .T. }*/  , bFinish ,.F., { || ExibeLog() } )

oWizard:Activate( .T. )      

RestArea( aArea )                                

Return

/*
Função...............: TelaFiltro
Objetivo.............: Tela de Seleção de Nota de Entrada
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 16/03/2015
*/
*-----------------------------------------------*
Static Function TelaFiltro
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel ) 

@10,10 Say "Nota Fiscal" Size 80,10 Of oPanel Pixel
@10,100 MSGet cNotaEnt   Size 50,10  Of oPanel Pixel

@25,10 Say "Serie" Size 40,10 Of oPanel Pixel
@25,100 MSGet cSerieEnt   Size 20,10  Of oPanel Pixel

@40,10 Say "Fornecedor" Size 50,10 Of oPanel Pixel
@40,100 MSGet cForn   Size 70,10 F3( 'SA2A' )  Of oPanel Pixel

@55,10 Say "Loja" Size 40,10 Of oPanel Pixel
@55,100 MSGet cLoja   Size 20,10  Of oPanel Pixel

@70,10 Say "TES" Size 40,10 Of oPanel Pixel
@70,100 MSGet cTes   F3( 'SF4' ) Valid CheckTES() Size 20,10  Of oPanel Pixel    

@85,10 Say "Tipo Pedido" Size 40,10 Of oPanel Pixel
@85,100 COMBOBOX cTipoPed ITEMS { "N=Normal" , "D=Devolucao" , "B=Utiliza Fornecedor" }   Size 80,10  Of oPanel Pixel

Return

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 16/03/2015
*/
*-----------------------------------------------*
Static Function ExibeLog
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
 
@05,05 Get oGetResult Var cResult MEMO READONLY Size 295,145 Of oPanel Pixel

Return

/*
Função...............: ValidaFiltro
Objetivo.............: Validação da Tela de Seleção de Filtro
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 23/03/2015
*/
*-----------------------------------------------*
Static Function ValidaFiltro
*-----------------------------------------------*
Local cQuery 
Local cAliasQ    

Local aArea    := GetArea()

/*
	**	Todos os parametros devem ser preenchidos
*/
If Empty( cNotaEnt ) .Or. Empty( cSerieEnt ) .Or. Empty( cForn ) .Or. Empty( cLoja ) .Or. Empty( cTes )
	MsgStop( 'Preencher todos os parametros.' )
	Return( .F. )
EndIf

/*
	** 	Valida Fornecedor 
*/
SA2->( DbSetOrder( 1 ) )
If SA2->( !DbSeek( xFilial() + cForn + cLoja ) )
	MsgStop( 'Fornecedor Invalido.' )
	Return( .F. )
EndIf

/*
	** 	Valida Nota Fiscal de Entrada 
*/
SF1->( DbSetOrder( 1 ) )
If SF1->( !DbSeek( xFilial() + cNotaEnt + cSerieEnt + cForn + cLoja ) )
	MsgStop( 'Nota Fiscal nao encontrada para este fornecedor.' )
	Return( .F. )
EndIf  

/*
	** 	Valida TES 
*/
SF4->( DbSetOrder( 1 ) )
If SF4->( !DbSeek( xFilial() + cTes ) )
	MsgStop( 'TES Invalida.' )
	Return( .F. )
ElseIf SF4->F4_TIPO <> 'S' 
	MsgStop( 'A TES informada nao ï¿½ de saida.' )
	Return( .F. )
EndIf  

/*
	** Nao permite gerar novo pedido para notas fiscais de entrada que ja tenham sido integradas.
*/     

cQuery :=  "SELECT C5_NUM FROM " + RetSqlName( 'SC5' )
cQuery +=  " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = '" + xFilial( 'SC5' ) + "' AND C5_P_NOTA = '" + cNotaEnt + "' AND "
cQuery +=  " C5_P_SERIE = '" + cSerieEnt + "' AND "
cQuery +=  " C5_P_FORN = '" + cForn + "' AND "
cQuery +=  " C5_P_LOJA = '" + cLoja + "'"

cAliasQ := GetNextAlias()

TCQuery cQuery ALIAS ( cAliasQ ) New

If ( cAliasQ )->( !Eof() ) 
	MsgStop( 'Nota Fiscal de entrada ja possui pedido de venda gerado.( Numero ' + ( cAliasQ )->C5_NUM + ")" )
	( cAliasQ )->( DbCloseArea() )
	RestArea( aArea )	
	Return( .F. )
EndIf

( cAliasQ )->( DbCloseArea() )
RestArea( aArea )

Return( .T. )

/*
Função...............: TelaNF
Objetivo.............: Manutençãoo dos dados para geraçãoo do pedido de remessa
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 23/03/2015
*/
*-----------------------------------------------*
Static Function TelaNF
*-----------------------------------------------*
Local oPanel		:= oWizard:GetPanel( oWizard:nPanel )
Local aSizeDlg		:= MsAdvSize()

Local bOk			:= { || If( Obrigatorio( oEnch:aGets , oEnch:aTela ) .And. oGetDad:TudoOk() .And. MsgYesNo( 'Confirma Gravacao ?' ) , ( lRet := .T. , oDlg:End() ) , ) }
Local bCancel		:= { || lRet := .F. , oDlg:End() }

Local oDlg 
Local lRet			:= .F.

Local nOpc			:= 0 

Local aHeader
Local aCols

Local oLayer

Local oPanelCapa
Local oPanelItens

Local aFolder   	:= { "Nota de Entrada" , "Pedido de Venda" }
Local aAlter     	:= { "CLIEFOR" , "LOJA" , "CONDPAG" , "MENNOTA" , "MENPAD" , "TRANSP" , "PLIQUI" , "PBRUTO" , "VOLUME1" , "ESPECI1" , "TPFRETE" }

Local aCposEnc  	:= {}

Local cDINum
Local cProcesso
Local cObs			

Local nValItem 
Local nTotalNF

Local cCFOIcm 		:= GetNewPar( 'MV_P_0050' , '3101;3102' )

Local nDecPrcUnit 	:= TamSX3( 'D1_VUNIT' )[ 2 ]

Private oEnch		
Private oGetDad 	 


cTipoPed := Left( cTipoPed , 1 ) 

/*
	**	Pasta Nota de Entrada
*/
aAdd(aCposEnc,{"Nota Fiscal"    ,"NF"         ,"C" ,Len( SF1->F1_DOC ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Serie"          ,"SERIE"      ,"C" ,Len( SF1->F1_SERIE ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Emissao"        ,"EMISSAO"    ,"D" ,008,0,"@D"  ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Fornecedor"     ,"FORNECEDOR" ,"C" ,Len( SA2->A2_COD ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Loja"           ,"LOJAFOR"    ,"C" ,Len( SA2->A2_LOJA ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Nome"           ,"NOMEFOR"    ,"C" ,Len( SA2->A2_NREDUZ ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Processo"       ,"PROCESSO"   ,"C" ,Len( SW6->W6_HAWB ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"DI"             ,"DI"         ,"C" ,Len( SW6->W6_DI_NUM ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Total da Nota"	,"TOTNF"    , "N" , 15 , 2 , X3Picture( 'F1_VALMERC' )    ,"",.F.,1,"","","",.F.,.F.,"",1,.F.,"",""})

/*
	**	Pasta Pedido de Venda
*/
If ( cTipoPed == 'N' )
	aAdd(aCposEnc,{"Cliente"        	,"CLIEFOR"   ,"C" ,Len( SA1->A1_COD ),0,""    ,"",.T.,1,"","SA1","",.F.,.F.,"",2,.F.,"",""})
	aAdd(aCposEnc,{"Loja"           	,"LOJA"   ,"C" ,Len( SA1->A1_LOJA ),0,""    ,"",.T.,1,"","","",.F.,.F.,"",2,.F.,"",""})
Else
	aAdd(aCposEnc,{"Fornecedor"        	,"CLIEFOR"   ,"C" ,Len( SA2->A2_COD ),0,""    ,"",.T.,1,"","SA2","",.F.,.F.,"",2,.F.,"",""})
	aAdd(aCposEnc,{"Loja"           	,"LOJA"   ,"C" ,Len( SA2->A2_LOJA ),0,""    ,"",.T.,1,"","","",.F.,.F.,"",2,.F.,"",""})
EndIf

aAdd(aCposEnc,{"Cond.Pagto"     	,"CONDPAG"   ,"C" ,Len( SC5->C5_CONDPAG ),0,""    ,"",.T.,1,"","SE4","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Mens. p/nota"   	,"MENNOTA"   ,"C" ,Len( SC5->C5_MENNOTA ),0,""    ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Mens.Padrao"    	,"MENPAD"    ,"C" ,Len( SC5->C5_MENPAD ),0,""    ,"",.F.,1,"","SM4","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Transportadora" 	,"TRANSP"    ,"C" ,Len( SC5->C5_TRANSP ),0,""    ,"",.F.,1,"","SA4","",.F.,.F.,"",2,.F.,"",""})

//RSB - 28/08/2017 - Inclusão do centro de custo.
If SC5->(FieldPos("C5_CCUSTO")) > 0 
	Aadd(aAlter,"CCUSTO")
	aAdd(aCposEnc,{"Centro de Custo" 	,"CCUSTO"    ,"C" ,Len( SC5->C5_CCUSTO ),0,""    ,"",.T.,1,"","CTT","",.F.,.F.,"",2,.F.,"",""}) 
Endif

aAdd(aCposEnc,{"Peso Liquido"   ,"PLIQUI"    , "N" , 11 , 4 , X3Picture( 'F1_PLIQUI' )    ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Peso Bruto"     ,"PBRUTO"  , "N" , 11 , 4 , X3Picture( 'F1_PBRUTO' )    ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Volume"         ,"VOLUME1"    , "N" , 06 , 0 ,X3Picture( 'F1_VOLUME1' )    ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Especie"        ,"ESPECI1"    , "C" , 10 , 0 ,X3Picture( 'F1_ESPECI1' )    ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Tipo Frete"     ,"TPFRETE"    , "C" , 01 , 0 ,X3Picture( 'F1_TPFRETE' )    ,"",.T.,1,"","","",.F.,.F.,"C=CIF;F=FOB;T=Terceiros;S=Sem Frete",2,.F.,"",""})

/*
	**	Inicializa variaveis de memoria 
*/                                      
SF1->( DbSetOrder( 1 ) )
SA2->( DbSetOrder( 1 ) )
SF1->( DbSeek( xFilial() + cNotaEnt + cSerieEnt + cForn + cLoja ) )
SA2->( DbSeek( xFilial() + SF1->F1_FORNECE + SF1->F1_LOJA ) )


M->NF 			:= cNotaEnt
M->SERIE 		:= cSerieEnt
M->EMISSAO 		:= SF1->F1_EMISSAO
M->FORNECEDOR 	:= cForn
M->LOJAFOR 		:= cLoja
M->NOMEFOR 		:= SA2->A2_NREDUZ
M->PLIQUI   	:= SF1->F1_PLIQUI
M->PBRUTO		:= SF1->F1_PBRUTO
M->VOLUME1		:= SF1->F1_VOLUME1
M->ESPECI1		:= SF1->F1_ESPECI1
M->TPFRETE  	:= SF1->F1_TPFRETE


aHeader := {}
aAdd(aHeader,{"Item"        ,"ITEM"  ,"@9" 					    , Len( SD1->D1_ITEM )		,0							,".T."								,,"C" ,		,,"","",""  })
aAdd(aHeader,{"Codigo"      ,"CODIGO","@!"              		, Len( SB1->B1_COD )		,0							,".T."								,,"C" ,"ALT",,"","",""  })
aAdd(aHeader,{"Quant."      ,"QUANT" ,X3Picture( 'D1_QUANT' )   ,TamSX3( 'D1_QUANT' )[ 1 ]	,TamSX3( 'D1_QUANT' )[ 2 ]	,".T."								,,"N" ,		,,"","",""  })
aAdd(aHeader,{"Valor Unit." ,"VUNIT" ,X3Picture( 'D1_VUNIT' )	,TamSX3( 'D1_VUNIT' )[ 1 ]	,nDecPrcUnit				,".T."								,,"N" ,		,,"","",""  })
aAdd(aHeader,{"Valor Total" ,"TOTAL" ,X3Picture( 'D1_TOTAL' )	,TamSx3( 'D1_TOTAL' )[ 1 ]	,TamSx3( 'D1_TOTAL' )[ 2 ]	,".T." 								,,"N" ,		,,"","",""  })      
aAdd(aHeader,{"Tipo Saida","TES"   ,"@9"               			,Len( SF4->F4_CODIGO )		,0							,"ExistCpo( 'SF4' , M->TES , 1 )"	,,"C" ,"SF4",,"","",""  })

/*                                                
	** Carrega grade de itens
*/
cObs 		:= ''
aCols 		:= {}
nTotalNF 	:= 0
SD1->( DbSetOrder( 1 ) )
SD1->( DbSeek( xFilial() + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )                           
While SD1->( !Eof() .And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial() + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) 
    
	If Empty( cObs ) .And. ( "DI" $ SD1->D1_OBS ) 
		cObs := Alltrim( SD1->D1_OBS )	
	EndIf
	
	nValItem := SD1->( D1_TOTAL + D1_ICMSRET + D1_VALIPI + D1_VALIMP5 + D1_VALIMP6 + D1_DESPESA )
	
	If ( AllTrim( SD1->D1_CF ) $ cCFOIcm )
		nValItem +=  SD1->D1_VALICM
	EndIf                          
	Aadd( aCols , Array( Len( aHeader ) + 1 ) )
	ATail( aCols )[ 1 ] := SD1->D1_ITEM
	ATail( aCols )[ 2 ] := SD1->D1_COD
	ATail( aCols )[ 3 ] := SD1->D1_QUANT
	ATail( aCols )[ 4 ] := Round( nValItem / SD1->D1_QUANT , nDecPrcUnit )
	ATail( aCols )[ 5 ] := nValItem			
	ATail( aCols )[ 6 ] := cTes
	Atail( aCols )[ Len( aHeader ) + 1 ] := .F.
	
	nTotalNF += nValItem
		
	SD1->( DbSkip() )
EndDo

M->TOTNF := nTotalNF

cDINum := ""
cProcesso := ""

If ( cTipoPed == 'N' )
	M->CLIEFOR 	:= CriaVar( "A1_COD" , .F. )
	M->LOJA 	:= CriaVar( "A1_LOJA" , .F. )
Else
	M->CLIEFOR 	:= CriaVar( "A2_COD" , .F. )
	M->LOJA 	:= CriaVar( "A2_LOJA" , .F. )
EndIf	

M->CONDPAG := CriaVar( "C5_CONDPAG" , .F. )                                   

M->MENPAD   := CriaVar( "C5_MENPAD" , .F. )                                   
M->TRANSP   := CriaVar( "C5_TRANSP" , .F. ) 

//RSB - 28/08/2017 - Inclusão do centro de custo.
If SC5->(FieldPos("C5_CCUSTO")) > 0 
	M->CCUSTO	:= CriaVar( "C5_CCUSTO" , .F. )                                  
Endif

If !Empty( SF1->F1_HAWB )                                                                   

	/*
		**	Busca Numero da DI no Sigaeic
	*/         
	If SW6->( DbSetOrder( 1 ) , DbSeek( xFilial() + PadR( SF1->F1_HAWB , Len( SW6->W6_HAWB ) ) ) )
		cDINum := SW6->W6_DI_NUM
	EndIf
	
	cProcesso := SF1->F1_HAWB
	
Else
 
	/*
		**	Busca Numero do Processo e DI na CD5 ( Complementos de Importacao )
	*/
	CD5->( DbSetOrder( 4 ) ) 
	If CD5->( DbSeek( xFilial( "CD5" ) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
		cDINum 		:= CD5->CD5_NDI
		cProcesso 	:= CD5->CD5_DOCIMP	
	EndIf

EndIf	

M->PROCESSO 	:= cProcesso
M->DI 			:= cDINum


M->MENNOTA	:= ""

If Empty( cObs )   //** Se a observação nao estiver informada no item da nota, monta mensagem atraves do numero do processo e DI .

	If !Empty( M->PROCESSO )
		M->MENNOTA := "Processo " + AllTrim( M->PROCESSO )
	EndIf
     
	If !Empty( M->DI )
		M->MENNOTA += If( !Empty( M->PROCESSO ) , " - " , "" ) + "DI" + Alltrim( M->DI ) 
	EndIf
	
Else
	M->MENNOTA := cObs 
	
EndIf

M->MENNOTA 	:= PadR( M->MENNOTA , Len( SC5->C5_MENNOTA  ) )

aSort( aCols ,,, { |x,y| x[ 1 ] < y[ 1 ] } )

Define MsDialog oDlg Title 'Gerar Pedido Remessa de Armazenagem' From aSizeDlg[ 7 ] , aSizeDlg[ 1 ] TO aSizeDlg[ 6 ] , aSizeDlg[ 5 ] Of oMainWnd Pixel

oLayer := FWLayer():New()
oLayer:Init( oDlg , .T. )

oLayer:addLine( 'Linha1' , 50 , .F. )
oLayer:addLine( 'Linha2' , 50 , .F. )

oLayer:addCollumn( 'Col_1' , 100 , .F. , 'Linha1' )
oLayer:addCollumn( 'Col_2' , 100  , .F. , 'Linha2' )

oLayer:addWindow( 'Col_1' , 'Janela1' , 'Cabeçalho' , 100, .T. , .F. , { || } , 'Linha1' , { || } ) 
oLayer:addWindow( 'Col_2' , 'Janela2' , 'Itens da Nota' , 100, .T. , .F. ,{ || } , 'Linha2' , { || } )


oPanelCapa := oLayer:getWinPanel( 'Col_1' , 'Janela1' , 'Linha1' )
oPanelItens := oLayer:getWinPanel( 'Col_2' , 'Janela2' , 'Linha2' )

oEnch := MsMGet():New(,,3,,,,,{000,000,400,600},aAlter,,,,,oPanelCapa,.F.,.T.,,,,,aCposEnc,aFolder,.T.)
oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT                            

oGetDad := MsNewGetDados():New(0,0,0,0,GD_UPDATE,/*cLinOk*/,"u_TudoOkGt",,{"TES"}/*aCpoGDa*/,1,,/*cFieldOk*/,,,oPanelItens,aHeader,aCols)    
oGetDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel )

If ( lRet )

	/*
		** Gera pedido de venda
	*/
	MsgRun( 'Aguarde...' , 'Gerando Pedido de Venda...' , { || GeraPV() } )

EndIf  

Return( lRet  )

/*
Função...............: TudoOkGt
Objetivo.............: Validacao GetDados
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 23/03/2015
*/
*-----------------------------------------------*
User Function TudoOkGt
*-----------------------------------------------*

If ( cTipoPed == 'N' )
	SA1->( DbSetOrder( 1 ) )
	If SA1->( !DbSeek( xFilial() + M->CLIEFOR + M->LOJA ) )
		MsgStop( 'Cliente+Loja invalido.' )
		Return( .F. )
	EndIf  

Else
	SA2->( DbSetOrder( 1 ) )
	If SA2->( !DbSeek( xFilial() + M->CLIEFOR + M->LOJA ) )
		MsgStop( 'Fornecedor+Loja invalido.' )
		Return( .F. )
	EndIf  

EndIf	

SE4->( DbSetOrder( 1 ) )
If SE4->( !DbSeek( xFilial() + M->CONDPAG ) )
	MsgStop( 'Condicao de pagamento invalida.' )
	Return( .F. )
EndIf  

If !Empty( M->TRANSP )
	SA4->( DbSetOrder( 1 ) )
	If SA4->( !DbSeek( xFilial() + M->TRANSP ) )
		MsgStop( 'Transportadora invalida.' )
		Return( .F. )
	EndIf
EndIf 

If !Empty( M->MENPAD )
	SM4->( DbSetOrder( 1 ) )
	If SM4->( !DbSeek( xFilial() + M->MENPAD ) )
		MsgStop( 'Mensagem padrao da nota invalida.' )
		Return( .F. )
	EndIf
EndIf 

Return( .T. )


/*
Função...............: GeraPV
Objetivo.............: Gravar Pedido de Venda 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 23/03/2015
*/
*-----------------------------------------------*
Static Function GeraPv
*-----------------------------------------------*
Local i     

Local aCab
Local aItem , aItens                                              

Local nPosItem  := GDFieldPos( "ITEM" , oGetDad:aHeader )        
Local nPosProd  := GDFieldPos( "CODIGO" , oGetDad:aHeader )        

Local nPosPrUn  := GDFieldPos( "VUNIT" , oGetDad:aHeader )        
Local nPosPrTot := GDFieldPos( "TOTAL" , oGetDad:aHeader )       
 
Local nPosTes   := GDFieldPos( "TES" , oGetDad:aHeader )        
Local nPosQuant := GDFieldPos( "QUANT" , oGetDad:aHeader )        

Local nLenItem  := Len( SC6->C6_ITEM )       

Private lMsErroAuto

  
If cEmpAnt $ "TM"
   
		aCab := { ;
        	{ 'C5_TIPO' , cTipoPed , Nil } ,;
        	{ 'C5_CLIENTE' , M->CLIEFOR , Nil } ,;
			{ 'C5_LOJACLI' , M->LOJA , Nil } ,;
        	{ 'C5_CONDPAG' , M->CONDPAG , Nil } ,;
        	{ 'C5_EMISSAO' , dDataBase , Nil },;
        	{ 'C5_MENNOTA' , M->MENNOTA , Nil },;
        	{ 'C5_MENPAD' , M->MENPAD , Nil },;
        	{ 'C5_TRANSP' , M->TRANSP , Nil },;
        	{ 'C5_PESOL' , M->PLIQUI , Nil },;        	
        	{ 'C5_PBRUTO' , M->PBRUTO , Nil },;        	
        	{ 'C5_VOLUME1' , M->VOLUME1 , Nil },;        	
        	{ 'C5_ESPECI1' , M->ESPECI1 , Nil },;        	
        	{ 'C5_TPFRETE' , M->TPFRETE , Nil },;        	        	        	        	        	
        	{ 'C5_P_NOTA' , cNotaEnt , Nil },;
        	{ 'C5_P_SERIE' , cSerieEnt , Nil },;
        	{ 'C5_P_FORN' , cForn , Nil },;
        	{ 'C5_P_LOJA' , cLoja , Nil },;
        	{ 'C5_P_IMP' , M->PROCESSO , Nil },;
        	{ 'C5_P_EMISS' , M->EMISSAO , Nil },;        	        	        	        	        	        	
			{ 'C5_P_PARC' , "N", Nil },;
			{ 'C5_OBRA' , "NAO POSSUI", Nil },; 
			{ 'C5_VEND1'  , "000001", Nil },; 
			{ 'C5_P_SALES' , "IMP" , Nil },;
			{ 'C5_P_ENDUS' , "00", Nil };
			}  
			
		//RSB - 28/08/2017 - Inclusão do centro de custo.	 
		If SC5->(fieldPos("C5_CCUSTO")) > 0       	
			Aadd(aCab,{ 'C5_CCUSTO' , M->CCUSTO , Nil }) 
		Endif	                 

Else

	aCab := { ;
        	{ 'C5_TIPO' , cTipoPed , Nil } ,;
        	{ 'C5_CLIENTE' , M->CLIEFOR , Nil } ,;
			{ 'C5_LOJACLI' , M->LOJA , Nil } ,;
        	{ 'C5_CONDPAG' , M->CONDPAG , Nil } ,;
        	{ 'C5_EMISSAO' , dDataBase , Nil },;
        	{ 'C5_MENNOTA' , M->MENNOTA , Nil },;
        	{ 'C5_MENPAD' , M->MENPAD , Nil },;
        	{ 'C5_TRANSP' , M->TRANSP , Nil },;
        	{ 'C5_PESOL' , M->PLIQUI , Nil },;        	
        	{ 'C5_PBRUTO' , M->PBRUTO , Nil },;        	
        	{ 'C5_VOLUME1' , M->VOLUME1 , Nil },;        	
        	{ 'C5_ESPECI1' , M->ESPECI1 , Nil },;        	
        	{ 'C5_TPFRETE' , M->TPFRETE , Nil },;        	        	        	        	        	
        	{ 'C5_P_NOTA' , cNotaEnt , Nil },;
        	{ 'C5_P_SERIE' , cSerieEnt , Nil },;
        	{ 'C5_P_FORN' , cForn , Nil },;
        	{ 'C5_P_LOJA' , cLoja , Nil },;
        	{ 'C5_P_IMP' , M->PROCESSO , Nil },;
        	{ 'C5_P_EMISS' , M->EMISSAO , Nil };
			}                   
	//RSB - 28/08/2017 - Inclusão do centro de custo.	 
	If SC5->(fieldPos("C5_CCUSTO")) > 0       	
		Aadd(aCab,{ 'C5_CCUSTO' , M->CCUSTO , Nil }) 
	Endif	
			 
EndIf			                                                 

	 
aItens := {}                                 
For i := 1 To Len( oGetDad:aCols )
		
	aItem := { 	{ "C6_ITEM" 	, Right( oGetDad:aCols[ i ][ nPosItem ] , nLenItem ) 	, Nil} ,;
				{ "C6_PRODUTO"  , oGetDad:aCols[ i ][ nPosProd ] 	, Nil},;
				{ "C6_QTDVEN" 	, oGetDad:aCols[ i ][ nPosQuant ]	, Nil},;
				{ "C6_PRCVEN" 	, oGetDad:aCols[ i ][ nPosPrUn ]	, Nil},; 		
				{ "C6_VALOR" 	, Round( oGetDad:aCols[ i ][ nPosQuant ] * oGetDad:aCols[ i ][ nPosPrUn ] ,2 )	, Nil},;
				{ "C6_TES"  	, oGetDad:aCols[ i ][ nPosTes ]		, Nil}} 
				
    If ( cTipoPed == 'D' )
       Aadd( aItem , { 'C6_NFORI' , cNotaEnt , Nil } )
       Aadd( aItem , { 'C6_SERIORI' , cSerieEnt , Nil } )       
       Aadd( aItem , { 'C6_ITEMORI' , oGetDad:aCols[ i ][ nPosItem ]   , Nil } )              
    EndIf				
			
	Aadd( aItens , aItem ) 		
Next
		
Begin Transaction

	lMsErroAuto := .F.
	        
	/*
		** Integra Pedido de Venda
	*/
   	MsExecAuto( { |x,y,z| Mata410( x,y,z ) } , aCab , aItens , 3 )
	
	If lMsErroAuto
		cResult := "Ocorreram erros na geracao do pedido de venda. " + Chr( 13 ) + Chr( 10 ) +  MemoRead( NomeAutoLog() )
   		DisarmTransaction()
	   		
	Else
		cResult := "Pedido de Venda " + SC5->C5_NUM  + " gerado com sucesso."+CRLF

	EndIf                           
/*	
		If __lSx8
			SC5->( ConfirmSx8() )
		Else
			SC5->( RollBackSX8() )		
	    EndIf
    EndIf
*/
    
End Transaction	

Return


/*
Função...............: CheckTES
Objetivo.............: Valida TES
Autor................: Tiago Luiz Mendonça
Data.................: 09/04/2015
*/
*------------------------*
Static Function CheckTES
*------------------------*
     
lRet:=.T.

If !Empty(cTes)
	SZ2->(DbSetOrder(3))
	If !(SZ2->(DbSeek(xFilial("SZ2")+cEmpAnt+cFilAnt+cTes)))
		MsgStop("TES não liberada para essa empresa","Grant Thornton")
		lRet:=.F.
	EndIf	
EndIf           
                                
Return lRet