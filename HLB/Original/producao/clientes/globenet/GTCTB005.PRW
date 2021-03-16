#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função.................: GTCTB005
Objetivo...............: Cadastro de Taxas Moeda Funcional
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 22/05/2015
Observações............:
*/
*----------------------------------*
User Function GTCTB005
*----------------------------------*
Local oBrowse
Private aRotina := MenuDef() 
Private cCadastro := 'Taxas Moeda Funcional'

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'Z26' )
oBrowse:SetDescription( cCadastro )
oBrowse:Activate()

Return NIL


/*
Função........: MenuDef
Objetivo......: Criação do menu funcional
Autor.........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data..........: 22/05/2015
*/
*----------------------------------*
Static Function MenuDef()
*----------------------------------*
Local aRotina := {}

aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
               { "Visualizar"   ,"AxVisual" , 0, 2},;
               { "Incluir"      ,"AxInclui" , 0, 3},;
               { "Alterar"      ,"AxAltera" , 0, 4},;
               { "Excluir"      ,"AxDeleta" , 0, 5},;
               { "Copia"        ,"u_GtTxCop" , 0, 6} }               
               
Return aRotina


/*
Função........: GtTxCop
Objetivo......: Copiar dados de um mes para outro
Autor.........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data..........: 22/05/2015
*/                  
*----------------------------------------------*
User Function GtTxCop( cAlias , nReg , nOpc )
*----------------------------------------------* 
Local oDlg         
Local nOption  := 0

Local cDataIni := Space( 6 )
Local cDataFim := Space( 6 )     
Local nTaxa    := 0

Local bOk      := { || If( Empty( cDataIni ) .Or. Empty( cDataFim ) , MsgStop( 'Mes/Ano de origem e destino devem ser preenchidos.' ) , ( nOption := 1 , oDlg:End() ) ) }
Local bCancel  := { || nOption := 0 , oDlg:End() }

Define MsDialog oDlg Title 'Copia de Taxas' From 1,1 To 180,350 Of oMainWnd Pixel

@ 05,05 Say 'Data Origem' Size 50,10 Of oDlg Pixel
@ 20,05 Say 'Data Destino' Size 50,10 Of oDlg Pixel
@ 35,05 Say 'Taxa' Size 50,10 Of oDlg Pixel

@ 05,55 Get cDataIni Picture '@R 99/9999' Valid u_GT005Dt( cDataIni ) Size 50,10 Of oDlg Pixel
@ 20,55 Get cDataFim Picture '@R 99/9999' Valid u_GT005Dt( cDataFim ) Size 50,10 Of oDlg Pixel
@ 35,55 Get nTaxa Picture '@E 999.9999' Valid ( Positivo( nTaxa ) ) Size 50,10 Of oDlg Pixel


Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered

If ( nOption == 1 ) .And. MsgYesNo( 'Confirma Cópia' )
	MsgRun( 'Aguarde, copiando taxas...' , '' , { || CopyCad( cDataIni , cDataFim , nTaxa ) } )
EndIf

Return                                           

/*
Função........: GT005Dt
Objetivo......: Validar Formato da Data Digitada
Autor.........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data..........: 22/05/2015
*/                  
*----------------------------------------------*
User Function GT005Dt( cGet )
*----------------------------------------------* 
Local cMes       

If ( cGet == Nil )
	cGet := &( ReadVar() )
EndIf

If Len( AllTrim( cGet ) ) <> 6
	MsgStop( 'Formato de data invalido ( MMAAAA )' )
	Return( .F. )
EndIf                         

cMes := Left( cGet , 2 ) 

If Val( cMes ) < 1 .Or. Val( cMes ) > 12 
	MsgStop( 'Mes Invalido.' )
	Return( .F. )
EndIf  
       
Return( .T. )                                    

/*
Função........: CopyCad
Objetivo......: Copiar Cadastro de Taxas de um mes para outro                      
Autor.........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data..........: 22/05/2015
*/                  
*---------------------------------------------------*
Static Function CopyCad( cDtOri , cDtDest , nTaxa )
*---------------------------------------------------*             
Local cQuery                           
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()

cQuery := "SELECT * FROM " + RetSqlName( 'Z26' ) 
cQuery += " WHERE Z26_FILIAL = '" + xFilial( 'Z26' ) + "' AND "
cQuery += "D_E_L_E_T_ = '' AND Z26_DATA = '" + cDtOri + "' " 

TCQuery ( cQuery ) ALIAS ( cAlias ) NEW

If ( cAlias )->( !Eof() )
    
	Z26->( DbSetOrder( 1 ) )
    While ( cAlias )->( !Eof() )  
    	   
		If Z26->( !DbSeek( xFilial() + ( cAlias )->Z26_CONTA + cDtDest ) )
        	Z26->( Reclock( 'Z26' , .T. ) )
		    Z26->Z26_FILIAL := xFilial( 'Z26' )
		    Z26->Z26_CONTA  := ( cAlias )->Z26_CONTA
		    Z26->Z26_DATA   := cDtDest
       	Else
            Z26->( Reclock( 'Z26' , .F. ) )
       	EndIf 
       
		If ( nTaxa > 0 )
			Z26->Z26_TAXA := nTaxa 
       	Else
       		Z26->Z26_TAXA := ( cAlias )->Z26_TAXA
       	EndIf
       
       	Z26->( MSUnlock() )      
       	( cAlias )->( DbSkip() )
    
    EndDo

Else
	MsgSTop( 'Nao existem dados para o periodo de origem informado.' )

EndIf

( cAlias )->( DbCloseArea() )
RestArea( aArea )	

Return