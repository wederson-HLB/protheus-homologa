#INCLUDE "Protheus.ch" 
#INCLUDE "Topconn.ch"


/*
Função..........: TPFin007
Objetivo........: Integração baixas a receber 
Autor...........: Leandro Diniz de Brito 
Data............: 16/09/2016
*/                          

*---------------------------------------*
User Function TPFin007
*---------------------------------------*  
Local aArea      	:= GetArea()
Local chTitle    	:= "HLB BRASIL"

Local chMsg      	:= "Twitter - Baixa Contas a Receber - via planilha"
Local cTitle

Local cText     	:= "Este programa tem como objetivo importar planilha excel, no formato .csv e efetuar a baixa dos titulos a receber . O titulo sera baixado atraves do campo 'Credit Card Transact ID' ."
Local bFinish    	:= { || .T. }

Local cResHead

Local lNoFirst
Local aCoord   

Local dDtBkp 	:= dDataBase

Local oProcesss
Local nTpCtb 	

Private oWizard
Private oGetResult

Private cPlanilha   := Space( 200 )
Private cBanco		:= CriaVar( 'A6_COD' , .F. )  
Private dDtBaixa	:= CtoD("//")

Private cAgencia	:= CriaVar( 'A6_AGENCIA' , .F. )
Private cConta		:= CriaVar( 'A6_NUMCON' , .F. )

Private oLbx , aDadosLog := {}
Private oBrwPlan

Private cResult     := ""

Pergunte( 'FIN070' , .F. )
nTpCtb := MV_PAR04  

GrvProfSX1("FIN070","04",2)

oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord )

oWizard:NewPanel ( "Selecao de Arquivo"  , "Informe o local da planilha " , { || .T. }/*bBack*/ , { || ValidaTela() .And. MsgYesNo( 'Confirma importação da planilha ?' ) .And. ( Processa( { || Import() } , 'Importando Planilha...' ) , .T. ) } ,bFinish ,, { || TelaArq() } /*bExecute*/  )
oWizard:NewPanel ( "Resultado"           , "Resultado do Processamento" , { || .T. }/*bBack*/ , { ||  .T.}  ,bFinish , .T. , { || ExibeLog() } /*bExecute*/  )

oWizard:Activate( .T. )

RestArea( aArea )
                     
GrvProfSX1("FIN070","04",nTpCtb)
dDataBase	:= dDtBkp 

Return

/*
Função...............: TelaArq
Objetivo.............: Tela de Seleção da planilha e layout
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/
*-----------------------------------------------*
Static Function TelaArq
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )

@10,10 Say "Arquivo:" Size 60,10 Of oPanel Pixel
@10,35 MSGet cPlanilha   Size 230,10  When .F. Of oPanel Pixel 

@10,270 Button '...' Size 20,10 Action( cPlanilha := ChooseFile() ) Of oPanel Pixel

@25,10 Say "Banco:" Size 60,10 Of oPanel Pixel
@25,35 MSGet cBanco  F3( "SA6" ) Size 40,10  Of oPanel Pixel 

@25,80 Say "Agencia:" Size 60,10 Of oPanel Pixel
@25,115 MSGet cAgencia   Size 40,10  Of oPanel Pixel

@25,160 Say "Conta:" Size 60,10 Of oPanel Pixel
@25,185 MSGet cConta   Size 40,10  Of oPanel Pixel

@40,10 Say "Dt. da Baixa:" Size 60,10 Of oPanel Pixel
@40,45 MSGet dDtBaixa  Size 40,10  Of oPanel Pixel

Return

/*
Funcao.........: ChooseFile
Objetivo.......: Selecionar arquivo .csv a ser importado
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ChooseFile
*-----------------------------------------*
Local cTitle        := "Selecione o arquivo"
Local cMask         := "Arquivos XLS (*.csv) |*.csv"
Local nDefaultMask  := 0
Local cDefaultDir   := "C:\"
Local nOptions      := GETF_LOCALHARD+GETF_NETWORKDRIVE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna caminho e arquivo selecionado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( PadR( cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions ) , 300 ) )


/*
Função...............: Import
Objetivo.............: Importação Planilha 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/
*-----------------------------------------------*
Static Function Import
*-----------------------------------------------*       
Local nFile
Local nLinha 
               
Local aLog                                          
Local aLogAux 

Local aLinha
Local aCab                                

Local aCab,aDet    
Local nLenCard	:= Len( SC5->C5_P_IDC )  

Local aDadosTit
Local dDtPagto

Local cSql
Local cAliasQ 	:= GetNextAlias()

Private lMsErroAuto


Ft_Fuse( cPlanilha ) 

ProcRegua( Ft_FLastRec() )

Ft_FGoTop()
Ft_FSkip() //** Pula o header

aDadosLog := {}  

nLinha := 0
While !Ft_FEof()
			
	IncProc()
			
	nLinha ++
	aLinha := Separa( Ft_FReadLn() , "," )
	cIdCard := PadR( aLinha[ 4 ] , nLenCard )
	//dDtPagto  := aLinha[ 6 ] 
	dDtPagto := dDtBaixa
	
	If Empty( cIdCard )
		Aadd( aDadosLog , { .F. , nLinha , "" , "" , "" , "" , "" , "" , "" , "ID Card nao informado." } )
		Ft_FSkip()
		Loop	
	EndIf      
	
	If Empty( dDtPagto )
		Aadd( aDadosLog , { .F. , nLinha , cIdCard , "" , "" , "" , "" , "" , "" , "Data de Pagamento nao informado." } )
		Ft_FSkip()
		Loop	
	EndIf 
	
	//dDtPagto  := StoD( StrTran( Left( aLinha[ 6 ] , 10 ) , "-" , "" ) )
	
	/*
		* Busca o Titulo na Base de Dados pelo ID Card
	*/
	aDadosTit := {}
	cSql := "SELECT E1_NUM,E1_PREFIXO,E1_NOMCLI,E1_VALOR,E1_VENCREA,E1_BAIXA,E1_TIPO,E1_PARCELA,R_E_C_N_O_ RECSE1,E1_EMISSAO "
	cSql += "FROM " + RetSqlName( 'SE1' ) + " WHERE D_E_L_E_T_ = '' AND E1_P_IDC = '" + cIdCard + "' AND E1_FILIAL = '" + xFilial( 'SE1' ) + "' "    	
	
	TCQuery cSql ALIAS ( cAliasQ ) NEW
	
	If ( cAliasQ )->( !Eof() )
		aDadosTit :=  { ( cAliasQ )->E1_NUM , ( cAliasQ )->E1_PREFIXO , ( cAliasQ )->E1_PARCELA , ( cAliasQ )->E1_TIPO , ( cAliasQ )->E1_NOMCLI , ( cAliasQ )->E1_VALOR , StoD( ( cAliasQ )->E1_VENCREA ) , dDtPagto , StoD( ( cAliasQ )->E1_BAIXA ) , ( cAliasQ )->RECSE1 , StoD( ( cAliasQ )->E1_EMISSAO ) }
	EndIf
	
	If ( Select( cAliasQ ) > 0  )
		( cAliasQ )->( DbCloseArea() )
	EndIf    
	
	If ( Len( aDadosTit ) == 0 )
		Aadd( aDadosLog , { .F. , nLinha , cIdCard , "" , "" , "" , "" , "" , "" , "Titulo nao encontrado." } )
		Ft_FSkip()
		Loop		
	EndIf   
	
	If !Empty( aDadosTit[ 9 ] )
		Aadd( aDadosLog , { .F. , nLinha , cIdCard , aDadosTit[ 1 ] , aDadosTit[ 2 ] , aDadosTit[ 5 ] , aDadosTit[ 6 ] , aDadosTit[ 7 ] , aDadosTit[ 8 ] , "Titulo Baixado Anteriormente." } )		
		Ft_FSkip()
		Loop		
	EndIf  	     
	
	If ( dDtPagto < aDadosTit[ 11 ] )
		Aadd( aDadosLog , { .F. , nLinha , cIdCard , aDadosTit[ 1 ] , aDadosTit[ 2 ] , aDadosTit[ 5 ] , aDadosTit[ 6 ] , aDadosTit[ 7 ] , aDadosTit[ 8 ] , "Data Pagamento anterior emissao do titulo." } )		
		Ft_FSkip()
		Loop		
	EndIf  		
	
	/*
		* Efetua baixa do Titulo ( FINA070 )
	*/ 
	dDataBase := aDadosTit[ 8 ]  
	SE1->( DbGoto( aDadosTit[ 10 ] ) )  
	aTit := {}
	AADD( aTit, { "E1_PREFIXO" 	, aDadosTit[ 2 ]	, Nil } )
	AADD( aTit, { "E1_NUM"     	, aDadosTit[ 1 ]	, Nil } )	
	AADD( aTit, { "E1_PARCELA" 	, aDadosTit[ 3 ]	, Nil } )
	AADD( aTit, { "E1_TIPO"    	, aDadosTit[ 4 ]	, Nil } )
	AADD( aTit, { "AUTBANCO"  	, cBanco			, Nil } )
	AADD( aTit, { "AUTAGENCIA"  , cAgencia			, Nil } )
	AADD( aTit, { "AUTCONTA"  	, cConta			, Nil } )
	AADD( aTit, { "AUTMOTBX"  	, "NOR"				, Nil } )
	AADD( aTit, { "AUTDTBAIXA"	, aDadosTit[ 8 ]	, Nil } )
	AADD( aTit, { "AUTDTCREDITO", aDadosTit[ 8 ]	, Nil } )
	AADD( aTit, { "AUTHIST"   	, 'Baixa Automatica TPFIN006'		   	, Nil } )
	AADD( aTit, { "AUTVALREC"  	, aDadosTit[ 6 ]	, Nil } )
	
	lMsErroAuto := .F. 
	MSExecAuto( { |x, y| FINA070( x, y ) } , aTit, 3 )
					
	If  lMsErroAuto
		MostraErro()
		DisarmTransaction()
		Aadd( aDadosLog , { .F. , nLinha , cIdCard , aDadosTit[ 1 ] , aDadosTit[ 2 ] , aDadosTit[ 5 ] , aDadosTit[ 6 ] , aDadosTit[ 7 ] , aDadosTit[ 8 ] , "Nao foi possivel baixar titulo ." } )		
	Else  
		SE1->( DbGoto( aDadosTit[ 10 ] ) )  
		SE1->( RecLock( 'SE1' , .F. ) )
		SE1->E1_P_OBS := If( At( "\" , cPlanilha ) > 0 , AllTrim( SubStr( cPlanilha , RAt( "\" , cPlanilha ) + 1 ) ) , AllTrim( cPlanilha ) ) + ;
						cUserName + DtoS( Date() ) + StrTran( Time() , ":" , "" )	 
		SE1->( MSUnlock() )				                                                                                                      
		Aadd( aDadosLog , { .T. , nLinha , cIdCard , aDadosTit[ 1 ] , aDadosTit[ 2 ] , aDadosTit[ 5 ] , aDadosTit[ 6 ] , aDadosTit[ 7 ] , aDadosTit[ 8 ] , "Titulo OK - Baixado." } )		
	EndIf			                                                     
			
	Ft_FSkip()
			
EndDo

Ft_Fuse( cPlanilha )

Return

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/
*-----------------------------------------------*
Static Function ExibeLog
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local oOK      := LoadBitmap( GetResources() , 'BR_VERDE' )
Local oNO      := LoadBitmap( GetResources() , 'BR_VERMELHO' )

@04,05 Button 'Exportar Log' Size 50,10 Action( Exporta() ) Of oPanel Pixel
oBrwPlan := TWBrowse():New( 15, 05, 295, 142,,,, oPanel ,,,,,,,,,,,, .F. ,, .T. )
	
oBrwPlan:SetArray( aDadosLog )
	
oBrwPlan:AddColumn( TCColumn():New( 'Status'       , { || If( aDadosLog[oBrwPlan:nAt,01],  oOK , oNO )  },,,,"CENTER"  ,,.T.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Linha'    , { || aDadosLog[oBrwPlan:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'ID.Card'       , { || aDadosLog[oBrwPlan:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Titulo'       , { || aDadosLog[oBrwPlan:nAt,04] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Prefixo'    , { || aDadosLog[oBrwPlan:nAt,05] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Cliente'       , { || aDadosLog[oBrwPlan:nAt,06] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Valor'    , { || aDadosLog[oBrwPlan:nAt,07] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Vencimento'       , { || aDadosLog[oBrwPlan:nAt,08] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Data Pagamento'       , { || aDadosLog[oBrwPlan:nAt,09] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )	
oBrwPlan:AddColumn( TCColumn():New( 'Observacao'    , { || aDadosLog[oBrwPlan:nAt,10] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )	
	
oBrwPlan:GoTop()
oBrwPlan:Refresh()
oBrwPlan:bLDblClick := { || .T. }

Return


/*
Função...............: Exporta
Objetivo.............: Exportar Log de processamento para Excel
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/        
*-----------------------------------* 
Static Function Exporta
*-----------------------------------*
Local oExcel, aAux     
Local cFile := GetTempPath() + 'Log_Baixa_Receber_Twitter_' + DtoS( dDatabase ) + '.xml'
Local i

oExcel := FWMSEXCEL():New()
oExcel:AddWorkSheet("Log")
oExcel:AddTable ("Log","Log da Operacao")   

oExcel:AddColumn("Log","Log da Operacao","Linha",1,1,.F.)
oExcel:AddColumn("Log","Log da Operacao","Id.Card",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Titulo",1,1,.F.)   
oExcel:AddColumn("Log","Log da Operacao","Prefixo",1,1,.F.)   
oExcel:AddColumn("Log","Log da Operacao","Cliente",1,1,.F.)   
oExcel:AddColumn("Log","Log da Operacao","Valor",1,1,.F.)   
oExcel:AddColumn("Log","Log da Operacao","Vencimento",1,1,.F.)   
oExcel:AddColumn("Log","Log da Operacao","Data Pagamento",1,1,.F.)   
oExcel:AddColumn("Log","Log da Operacao","Observacao",1,1,.F.)   


For i := 1 To Len( aDadosLog )
	oExcel:AddRow("Log","Log da Operacao",{ cValToChar( aDadosLog[ i ][ 2 ] ),;
											aDadosLog[ i ][ 3 ] ,;
											aDadosLog[ i ][ 5 ] ,;
											aDadosLog[ i ][ 5 ] ,;
											aDadosLog[ i ][ 6 ] ,;
											cValToChar( aDadosLog[ i ][ 7 ] ) ,;
											cValToChar( aDadosLog[ i ][ 8 ] ) ,;
											cValToChar( aDadosLog[ i ][ 9 ] ) ,;
											aDadosLog[ i ][ 10 ] } )

Next   

oExcel:Activate()                                                                                                    

If File( cFile )
	FErase( cFile )
EndIf

oExcel:GetXMLFile( cFile )	

oExcel1:=MsExcel():New()
oExcel1:WorkBooks:Open( cFile )  
oExcel1:SetVisible(.T.)

Return

/*
Funcao.........: ValidaTela
Objetivo.......: Validar tela de parametros
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ValidaTela
*-----------------------------------------*  
  
If Empty( cPlanilha ) .Or. ;
	Empty( cBanco ) .Or. ;
	Empty( cAgencia ) .Or. ;
	Empty( cConta ) .Or. ;
	Empty( dDtBaixa ) 		

	MsgStop( 'Favor preencher todos os parametros.' )
	Return( .F. )

EndIf

If SA6->( DbSetOrder( 1 ) , !DbSeek( xFilial() + cBanco + cAgencia + cConta ) )
	MsgStop( 'Banco\Agencia\Conta Invalidos.' )
	Return( .F. )
EndIf

Return( .T. )

/*
Função  : GrvProfSX1()
Objetivo: Altera o valor do pergunte no SX1
Autor   : Renato Rezende
Data    : 04/09/2014
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

Return Nil