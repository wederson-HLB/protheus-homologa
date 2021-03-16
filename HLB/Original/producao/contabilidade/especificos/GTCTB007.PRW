#Include 'Protheus.Ch'
#Include 'TopConn.Ch'


/*
Função............: GTCTB007
Objetivo..........: Criar o plano referencial a partir do plano modelo
Autor.............: BRL Consulting ( leandro.brito@brlconsulting.com.br )
Data..............: Junho/2015
*/
*----------------------------------------*
User Function GTCTB007
*----------------------------------------*
Local aArea      := GetArea()
Local oWizard 
Local chTitle    := "HLB BRASIL"

Local chMsg      := "Criação plano referencial."
Local cTitle

Local cText      := "Este programa tem como objetivo criar o plano referencial a partir do plano modelo. O plano referencial atual será sobreposto pelo plano modelo ."
Local bNext      := { || Processa( { || AtualizaCVN() } ) , .T. }

Local bFinish    := { || .T. }
Local lPanel

Local cResHead
Local bExecute   := { || .T. }

Local lNoFirst
Local aCoord

Local oGetResult

Private cResult


oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , bNext , /*bFinish*/ , lPanel , cResHead , /*bExecute*/ , lNoFirst , aCoord ) 

oWizard:NewPanel ( "Resultado" , "" , { || .T. }/*bBack*/ , /*{ || .T. }*/  , bFinish )    

@05,05 Get oGetResult Var cResult MEMO READONLY Size 295,145 Of oWizard:oMPanel[ 2 ] Pixel

oWizard:Activate( .T. )      

RestArea( aArea )                                

Return

/*
/*
Função..............: AtualizaCVN() 
Objetivo............: Appendar registros na tabela CVN a partir do arquivo modelo
*/
*------------------------------------------------------------------------*
Static Function AtualizaCVN
*------------------------------------------------------------------------*
Local nCount := 0
Local cArqModelo := 'GTCVNMOD.DBF'

Local cSql


If !MsgYesNo( 'Confirma operação?' )
	Return
EndIf


If !File( cArqModelo )
	cResult := 'Erro na abertura do arquivo modelo ( ' + cArqModelo + ' ).'
	Return		
EndIf
	
dbUseArea( .T. ,, AllTrim( GetSrvProfString( "StartPath" , "" ) ) + cArqModelo , '__TRB' , .T. , .F. )

If !Used()
	cResult := 'Erro na abertura do arquivo modelo ( ' + cArqModelo + ' ).' 
	Return		
EndIf

If __TRB->( Eof() )     
	cResult := 'Erro - Arquivo modelo vazio ( ' + cArqModelo + ' ).' 
	__TRB->( DbCloseArea() )     	
	Return		
EndIf

__TRB->( DbGoTop() )
cTpCod := ''
While __TRB->( !Eof() )

   IncProc()                                                
   If At( __TRB->CVN_CODPLA , cTpCod ) == 0
		cTpCod += "\" + __TRB->CVN_CODPLA 
   EndIf
   __TRB->( DbSkip() )

EndDo

cTpCod := FormatIn( cTpCod , "\" )             
cSql := "UPDATE " + RetSqlName( 'CVN' ) + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_  WHERE CVN_FILIAL = '" + xFilial( 'CVN' ) + "' AND CVN_CODPLA IN " + cTpCod 

If TcSqlExec( cSql ) < 0
	cResult := 'Erro na tentativa de apagar tabela CVN. ' + Chr( 13 ) + Chr( 10 ) + TCSqlError() 
	Return		
EndIf

ProcRegua( __TRB->( LastRec() ) )
__TRB->( DbGoTop() )
While __TRB->( !Eof() )

   IncProc()                                                
   
   CVN->( RecLock( 'CVN' , .T. ) )
   AvReplace( '__TRB' , 'CVN' )
   CVN->CVN_FILIAL := xFilial( 'CVN' ) 
   CVN->( MSUnLock() )                 
   
   nCount ++
   __TRB->( DbSkip() )

EndDo

cResult := "Termino do Processamento. Registros Atualizados : " + AllTrim( Str( nCount , 10 , 0 ) )

__TRB->( DbCloseArea() )     	

Return