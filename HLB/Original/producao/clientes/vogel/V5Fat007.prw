#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função.................: V5Fat007
Objetivo...............: Faturar Pedidos de venda de acordo com o tipo de produto
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 11/08/2016
Observações............:
*/
*------------------------*
User Function V5Fat007
*------------------------*    

Local aArea      	:= GetArea()
Local chTitle    	:= "Grant Thorthon"

Local chMsg      	:= "Vogel - Faturamento"
Local cTitle

Local cText     	:= "Este programa tem como objetivo faturar os pedidos de venda de acordo com os parametros selecionados."
Local bFinish    	:= { || .T. }

Local cResHead

Local lNoFirst
Local aCoord

Private oWizard
Private oGetResult

Private dDtIni	    := dDataBase
Private dDtFim  	:= dDataBase

Private aTpProd     := { "SF-Fatura" , "SR-Serviço" , "ST-Telecom Modelo 22" , "RV-Mercantil Danfe" , "SC-Comunicação Modelo 21", "ME-Movimentações Danfe" }
Private cTpProd     := aTpProd[ 1 ]

Private cResult     := ""
Private cTes        := Space( Len( SF4->F4_CODIGO ) )

Private cTipoPed    := ""
Private aDados     

Private aDadosLog  
Private dIniFat := FirstDay( GetNewPar( 'MV_P_00081' , CtoD( '' ) ) )


If !( cEmpAnt $ u_EmpVogel() )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf

If !AliasInDic( 'ZX3' )
	MsgStop( 'Tabela ZX3 nao encontrada. Favor entrar em contato com a TI .' ) 
	Return
EndIf    

If Empty( dIniFat )
	MsgStop( 'Parametro MV_P_00081 ( Data de Inicio de Faturamento ) nao configurado. Favor entrar em contato com a TI .' ) 
	Return
EndIf    

oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord ) 

oWizard:NewPanel ( "Filtros"               , "Preencher todos os parametros abaixo" , { || .T. }/*bBack*/ , { || ValidaFiltro() }  ,bFinish ,, { || TelaFiltro() } /*bExecute*/  ) 
oWizard:NewPanel ( "Pedidos"               , "" , { || .T. }/*bBack*/ , { || If( MsgYesNo( 'Confirma faturamentos do pedidos ?' ) , (  Processa( { || GeraNf() , 'Gerando notas fiscais...' } )  , .T. )   , .F. ) }  ,bFinish ,, { || TelaPedido() } /*bExecute*/  ) 
oWizard:NewPanel ( "Resultado do Processamento"       , "" , { || .F. }/*bBack*/ , /*{ || .T. }*/  , bFinish ,.F., { || ExibeLog() } )

oWizard:Activate( .T. )      

RestArea( aArea )                                

Return

/*
Função...............: TelaFiltro
Objetivo.............: Tela de Seleção de Nota de Entrada
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 11/08/2016
*/
*-----------------------------------------------*
Static Function TelaFiltro
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel ) 
Local oCombo

@10,10 Say "Data Inicial" Size 80,10 Of oPanel Pixel
@10,100 MSGet dDtIni    Size 50,10  Of oPanel Pixel

@25,10 Say "Data Final" Size 80,10 Of oPanel Pixel
@25,100 MSGet dDtFim   Size 50,10  Of oPanel Pixel

@40,10 Say "Tipo de Produto" Size 80,10 Of oPanel Pixel
oCombo := TComboBox():New(40,100,{|u|if(PCount()>0,cTpProd:=u,cTpProd)},aTpProd,100,20,oPanel,,{|| .T. },,,,.T.,,,,,,,,,'cTpProd')

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
Local oLbx
 
If !Empty( aDadosLog )

	oLbx := TWBrowse():New( ,,,,,,,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )	
	oLbx:Align := CONTROL_ALIGN_ALLCLIENT
	
	oLbx:SetArray( aDadosLog )    
	
	oLbx:AddColumn( TCColumn():New('Pedido'    ,{ || aDadosLog[oLbx:nAt,01] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oLbx:AddColumn( TCColumn():New('Mensagem'    ,{ || aDadosLog[oLbx:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )  
	oLbx:Refresh()

EndIf

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

If Empty( dDtIni ) .Or. Empty( dDtFim )
	MsgStop( 'Preencher datas inicial e final' )
	Return( .F. )
EndIf

Return( .T. )           

/*
Função...............: TelaPedido
Objetivo.............: Exibir pedidos de venda a Faturar
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 11/08/2016
*/
*-----------------------------------------------*
Static Function TelaPedido
*-----------------------------------------------*
Local oPanel  	:= oWizard:GetPanel( oWizard:nPanel )    
Local aArea		:= GetArea()
Local cSql  	:= ''

Local bOk			:= { || lRet := .T. , oDlg:End() }
Local bCancel		:= { || lRet := .F. , oDlg:End() }

Local oDlg 
Local lRet			:= .T. 

Local cAliasTemp   
Local oLbx


cAliasTemp := GetNextAlias()

Begin Sequence

cSql := "SELECT C6_NUM,C5_EMISSAO,C5_CLIENTE,C5_LOJACLI,C6_ITEM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_TES,C6_VALOR,C5.R_E_C_N_O_ RECSC5,C5_P_REF "
cSql += "FROM " + RetSqlName( 'SC6' ) + " C6 INNER JOIN " + RetSqlName( 'SC5' ) + " C5 "
cSql += "ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "
cSql += "INNER JOIN " + RetSqlName( 'SB1' ) + " B1 ON B1_COD = C6_PRODUTO "
cSql += "WHERE C6.D_E_L_E_T_ = '' AND C5.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' "
cSql += "AND B1_FILIAL = '" + xFilial( 'SB1' ) + "' AND C5_FILIAL = '" + xFilial( 'SC5' ) + "' AND C6_FILIAL = '" + xFilial( 'SC6' ) + "' "
cSql += "AND B1_TIPO = '" + Left( cTpProd , 2 )  + "' AND C6_QTDVEN > C6_QTDENT AND C6_BLQ NOT IN ( 'R' , 'S' ) "                                                                                                                        
cSql += "AND C5_EMISSAO BETWEEN '" + DtoS( dDtIni ) + "' AND '"  + DtoS( dDtFim ) + "' "
cSql += "AND C5_P_REF <> '' "
cSql += "ORDER BY C5_NUM,C6_ITEM "

TCQuery cSql ALIAS ( cAliasTemp ) NEW  

TCSetField( cAliasTemp , 'C6_QTDVEN' , 'N' , TamSx3( 'C6_QTDVEN' )[ 1 ] , TamSx3( 'C6_QTDVEN' )[ 2 ] )
TCSetField( cAliasTemp , 'C6_PRCVEN' , 'N' , TamSx3( 'C6_PRCVEN' )[ 1 ] , TamSx3( 'C6_PRCVEN' )[ 2 ] )
TCSetField( cAliasTemp , 'C6_VALOR'  , 'N' , TamSx3( 'C6_VALOR' )[ 1 ] , TamSx3( 'C6_VALOR' )[ 2 ] ) 
TCSetField( cAliasTemp , 'C5_EMISSAO' , 'D' , 8 )

aDados		:= {}
( cAliasTemp )->( DbEval( { || Aadd( aDados , { C6_NUM,C5_EMISSAO,C5_CLIENTE,C5_LOJACLI,C6_ITEM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_VALOR,RECSC5,C5_P_REF,C6_TES } ) } ) )

DbSelectArea( 'SC6' )

If Len( aDados ) == 0
	MsgStop( 'Nao existem dados para exibição.' )
	lRet := .F.
	Break
EndIf

oLbx := TWBrowse():New( ,,,,,,,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )	
oLbx:Align := CONTROL_ALIGN_ALLCLIENT

oLbx:SetArray( aDados )    

oLbx:AddColumn( TCColumn():New('Pedido'    ,{ || aDados[oLbx:nAt,01] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Emissao'    ,{ || aDados[oLbx:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oLbx:AddColumn( TCColumn():New('Ped.Sistech'    ,{ || aDados[oLbx:nAt,12] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )  
oLbx:AddColumn( TCColumn():New('Cliente'    ,{ || aDados[oLbx:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Loja'    ,{ || aDados[oLbx:nAt,04] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Item'    ,{ || aDados[oLbx:nAt,05] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Produto'    ,{ || aDados[oLbx:nAt,06] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Descrição'    ,{ || aDados[oLbx:nAt,07] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Qtde'    ,{ || aDados[oLbx:nAt,08] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Prc.Unit.'    ,{ || aDados[oLbx:nAt,09] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
oLbx:AddColumn( TCColumn():New('Total'    ,{ || aDados[oLbx:nAt,10] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 

oLbx:GoTop()
oLbx:Refresh()

End Sequence

If Select ( cAliasTemp ) > 0 
	( cAliasTemp )->( DbCloseArea() )
EndIf 

RestArea( aArea )

Return( lRet )

/*
Função...............: GeraNF
Objetivo.............: Gerar Nota Fiscal 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 12/08/2016
*/
*-----------------------------------------------*
Static Function GeraNF
*-----------------------------------------------*
Local i,j
Local cPedido := '' 

Local cSerieNF

Local cRet   
Local oLbx    
                                             
Local cTipoPrd :=  Left( cTpProd , 2 )
Local cEspecie 

Local aNotPed := {}

Begin Sequence

ZX3->( DbSetOrder( 1 ) )

aDadosLog := {}
VerSerieNf( @cSerieNf , cTipoPrd )  
			
If Empty( cSerieNf )
	Aadd( aDadosLog , { '' , 'Serie nao parametrizada para o tipo de produto ' + cTipoPrd + '. Contatar a TI.' } ) 
	Break
EndIf 

cSerieNf := PadR( cSerieNf , 3 )

/*
	* Tratamento parametro MV_ESPECIE
*/    
/*
If ( cTipoPrd  == 'RV' )  
	cEspecie := 'SPED' 
ElseIf ( cTipoPrd  == 'SF' )  
	cEspecie := 'FAT' 
ElseIf ( cTipoPrd  == 'SR' )  
	cEspecie := 'NFPS' 
ElseIf ( cTipoPrd  == 'SC' )  
	cEspecie := 'NFSC' 
Else
	cEspecie := 'NTST' 
EndIf 

cEspecie := cSerieNf  + '=' + cEspecie + ";"
*/

cEspecie :=  ''
ZX3->( DbSeek( xFilial('ZX3') + cEmpAnt + cFilAnt ) )
While ZX3->( !Eof() .And. ZX3_FILIAL + ZX3_EMPFIL == xFilial( 'ZX3' ) + cEmpAnt + cFilAnt )
	
	If ZX3->ZX3_TIPO $ 'RV,SF,SR,ME'
		cEspecie += Alltrim(ZX3->ZX3_SERIE) + "=" + RetEspecie( ZX3->ZX3_TIPO ) + ";"  			
	EndIf
	ZX3->( DbSkip() )

EndDo

If ( cTipoPrd $ 'ST,SC' )
	cEspecie += cSerieNf  + '=' + RetEspecie( cTipoPrd ) + ";"  
EndIf 
	
SX6->( DbSetorder( 1 ) )
If SX6->( !DbSeek( cFilAnt + 'MV_ESPECIE' ) )
	SX6->( RecLock( 'SX6' , .T. ) )
	SX6->X6_FIL := cFilAnt
	SX6->X6_VAR := 'MV_ESPECIE'
	SX6->X6_TIPO := 'C'
	SX6->X6_DESCRIC := 'Contem tipos de documentos fiscais utilizados na'
	SX6->X6_DESC1	:= 'emissao de notas fiscais' 
	SX6->X6_CONTEUD := cEspecie  
	SX6->( MSUnlock() ) 		                      

ElseIf At( cEspecie , SX6->X6_CONTEUD ) == 0 
	SX6->( RecLock( 'SX6' , .F. ) )
	SX6->X6_CONTEUD := cEspecie    
	SX6->( MSUnlock() ) 

EndIf              

/*
	* Tratamento parametro MV_SER79
*/ 

If cTipoPrd == 'ST'                                
	If SX6->( !DbSeek( cFilAnt + 'MV_SER79' ) )
		SX6->( RecLock( 'SX6' , .T. ) )
		SX6->X6_FIL := cFilAnt
		SX6->X6_VAR := 'MV_SER79'
		SX6->X6_TIPO := 'C'
		SX6->X6_DESCRIC := 'Series que devem ser consideradas para as Notas'
		SX6->X6_DESC1	:= 'Fiscais Modelo 01 da CAT79.'   
		SX6->X6_CONTEUD := cSerieNf   
		SX6->( MSUnlock() )		                  

	ElseIf At( cSerieNf , SX6->X6_CONTEUD ) == 0 
		SX6->( RecLock( 'SX6' , .F. ) )
		aSeries := Separa( AllTrim( SX6->X6_CONTEUD ) , "/" )

		If Len( aSeries ) > 23
			ADel( aSeries , 1 )
			aSeries[ Len( aSeries ) ] := cSerieNf 
		Else
			Aadd( aSeries , cSerieNf )
		EndIf 

		cSer79 :=  ""
		For nx := 1 To Len( aSeries )
			If !Empty( cSer79 )
				cSer79 += "/"  			
			EndIf
			cSer79 += PadR( aSeries[ nx ] , 3 ) 
		Next

		SX6->X6_CONTEUD := cSer79
		SX6->( MSUnlock() )		            		

	EndIf              
EndIf


ProcRegua( Len( aDados ) )
For i := 1 To Len( aDados )
	
	IncProc()
	
	If cPedido <> aDados[ i ][ 1 ]
		
		cPedido := aDados[ i ][ 1 ]
		
		SC5->( DbSetOrder( 1 ) )
		SC5->( DbSeek( xFilial() + cPedido ) )
		
		If Ascan( aDados , { | x | x[ 1 ] == cPedido .And. x[ 13 ] == '999' } ) > 0 
			Aadd( aDadosLog , { cPedido , 	'Ped.Ref ' + SC5->C5_P_REF + ' nao faturado. Tributação nao parametrizada.' } )
			Loop
		EndIf 
		
		/*
		** Liberacao do Pedido de Venda
		*/
		
		aPvlNfs:={} ;aBloqueio:={}
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
		If !Empty( aBloqueio )
			
			/*
			** Se houve algum bloqueio nao gera NF e guarda no Log 
			*/
			For j := 1 To Len( aBloqueio )
				Aadd( aDadosLog , { aBloqueio[ j ][ 1 ] , 'Produto ' + aBloqueio[ j ][ 4 ] + ' : ' + If ( !Empty( aBloqueio[ j ][ 6 ] ) , 'Bloqueio credito.' , '' ) + ;
								If( !Empty( aBloqueio[ j ][ 7 ] ) , 'Bloqueio Estoque.' , '' ) } ) 
			Next
			
		Else
			
			/*
			** Gera Nota Fiscal de Saida
			*/
			
			cRet := MaPvlNfs( aPvlNfs ,;
							cSerieNf ,;
							.F. ,; //** Mostra Lancamentos Contabeis
							.F. ,; //** Aglutina Lanuamentos
							.F. ,; //** Cont. On Line ?
							.F. ,; //** Cont. Custo On-line ?
							.F. ,; //** Reaj. na mesma N.F.?
							3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
							1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
							.F.,;  //** Atualiza Cli.X Prod?
							.F. ,,,,,,; //** Ecf ?
							dDataBase )   
			
			If Empty( cRet )
				Aadd( aDadosLog , { cPedido , 	'Pedido nao faturado.' } )

			Else
				Aadd( aDadosLog , { cPedido , 	'Faturado com sucesso. Ped.Ref ' + SC5->C5_P_REF + ' - NF ' + cRet + ' Serie ' + cSerieNf } )			


				/*
					* Atualiza campo F2_P_REF 
				*/				              
				TcSqlExec( "UPDATE " + RetSqlName( "SF2" ) + " SET F2_P_REF = '" + SC5->C5_P_REF + "' WHERE F2_FILIAL = '" + xFilial( 'SF2' ) + "' AND " +;
							"F2_DOC = '" + cRet + "' AND F2_SERIE = '" + cSerieNf + "' AND F2_CLIENTE = '" + SC5->C5_CLIENTE + "' AND F2_LOJA = '" + SC5->C5_LOJACLI + "' " )	
							
				/*
					* Atualiza campo D2_P_REF 
				*/				              
				TcSqlExec( "UPDATE " + RetSqlName( "SD2" ) + " SET D2_P_REF = '" + SC5->C5_P_REF + "' WHERE D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND " +;
							"D2_DOC = '" + cRet + "' AND D2_SERIE = '" + cSerieNf + "' AND D2_CLIENTE = '" + SC5->C5_CLIENTE + "' AND D2_LOJA = '" + SC5->C5_LOJACLI + "' " )	
							
				/*
					* Atualiza campo E1_P_REF 
				*/				              
				TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_P_REF = '" + SC5->C5_P_REF + "',E1_P_BOL = '"+SC5->C5_P_BOL+"' WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
							"E1_NUM = '" + cRet + "' AND E1_SERIE = '" + cSerieNf + "' AND E1_CLIENTE = '" + SC5->C5_CLIENTE + "' AND E1_LOJA = '" + SC5->C5_LOJACLI + "' " )														
							
			EndIf
	
		EndIf
		
	EndIf
Next

End Sequence

Return

/*
Função...............: VerSerieNf
Objetivo.............: Retornar serie da nota de acordo com tipo de produto
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 12/08/2016
*/
*---------------------------------------------------------------*
Static Function VerSerieNf( cSerieNf , cTipoPrd )
*---------------------------------------------------------------*
Local dMesAtu := FirstDay( dDataBase ) 
Local cFilSX5 := xFilial("SX5")
	
If ZX3->( DbSeek( xFilial('ZX3') + cEmpAnt + cFilAnt + cTipoPrd ) )
	If !( cTipoPrd $ 'SC,ST' )
		cSerieNF := ZX3->ZX3_SERIE
	Else
	 	/*
	 		* Busca serie para o mes de Faturamento
	 	*/
	 	cSerieNf 	:= Left( ZX3->ZX3_SERIE , 1 ) + '01'
	 	dDtAux 		:= dIniFat
	 	While dDtAux < dMesAtu
	 		cSerieNf := Soma1( cSerieNf )		
	 	    dDtAux := LastDay( dDtAux ) + 1 
	 	EndDo 
		
	EndIf 
	//Verificar se precisa colocar filial no SX5
	If ZX3->ZX3_EXCLU
		cFilSX5 := cFilAnt	
	EndIf  
 	/*
 		* Insere serie na SX5 caso nao encontre
 	*/                                         
	If SX5->( DbSetOrder( 1 ), !DbSeek( cFilSX5 + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerieNF , Len( SX5->X5_CHAVE ) ) ) )
		SX5->( RecLock( "SX5" , .T. ) )
		SX5->X5_FILIAL := cFilSX5
		SX5->X5_TABELA := '01'
		SX5->X5_CHAVE  := cSerieNF
		SX5->X5_DESCRI := PadL( '1' , Len( SF2->F2_DOC ) , '0' )
		SX5->( MSUnlock() )
	EndIf		 		
EndIf

Return   

/*
Função...............: RetEspecie
Objetivo.............: Retornar especie para um determinado tipo de produto
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 12/08/2016
*/
*---------------------------------------------------------------*
Static Function RetEspecie( cTpPrd )
*---------------------------------------------------------------*       
Local aEspecie := { { 'RV' , 'SPED' } , { 'SF' , 'FAT' } , { 'SR' , 'NFPS' } , { 'SC' , 'NFSC' } , { 'ST' , 'NTST' }, { 'ME' , 'SPED' } }
Local nPos 
Local cEspecie := ''

If ( nPos := Ascan( aEspecie , { | x | x[ 1 ] == cTpPrd } ) ) > 0
	cEspecie := aEspecie[ nPos ][ 2 ] 
EndIf

Return( cEspecie )
