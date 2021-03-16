#Include "Protheus.Ch" 
#Include "Topconn.Ch"
#Include "TbiConn.Ch"
 

/*
Função.............: GYFAT003
Autor..............: Renato Rezende
Objetivo...........: Importar Xml e Txt de Notas de Prestação de Serviço SP
Cliente HLB........: Uber
Data...............: 23/09/2017                                             
*/                                                  
*--------------------------------------* 
User Function GYFAT003( aParam )
*--------------------------------------*                                     

Local aArea      	:= {}   	
                                                                
Local nRecSM0Bak	:= 0
Local cFilBak  	 	:= ""

Local cTitle

Local cResHead
Local oProcess

Local lNoFirst
Local aCoord   

Local dDtBkp 	:= cToD("//")

Local oProcesss
Local nTpCtb 	

Local lConecta 

Private cTime := ""

Private aArqInt		:= {}
Private aLog   		:= {}

Private lJob 		:= (Select("SX3") <= 0)   

Private cProduto  	:= ""
Private cNatureza 	:= ""

Private oWizard
Private oGetResult

Private oLbx , aDadosLog := {}
Private oBrwPlan

Private cResult     := ""

Private aFolderUF   := {}
Private aFilEmp := {}

Private cIdInt
Private lProcessou := .F.

Private cDirSrv 

Begin Sequence

If !lJob .And. ( !cEmpAnt $ 'GY,99' )
	MsgStop( 'Empresa nao autorizada.' )
	Break
Else
	RpcClearEnv()
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "GY" FILIAL "01" TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"
EndIf                          

aArea      	:= GetArea()
nRecSM0Bak	:= SM0->( Recno() )    
cFilBak  	:= cFilAnt
dDtBkp 		:= dDataBase
cTime 		:= Time()
cNatureza 	:= PadR( GetMV( 'MV_P_00087' ,, '' )  , Len( SED->ED_CODIGO ) )

SM0->( DbSeek( cEmpAnt ) )
While SM0->( !Eof() .And. SM0->M0_CODIGO == cEmpAnt ) 

	Aadd( aFilEmp , { SM0->M0_CGC , SM0->M0_CODFIL , SM0->( Recno() ) } )
	
	SM0->( DbSkip() )
EndDo 

SM0->(DbGoTo(nRecSM0Bak))

If !ExistDir( "\FTP\GY" )
	MakeDir( "\FTP\GY"  )
EndIf

conout("GYFAT003 - Apos buscar as pastas das filiais "+ElapTime ( cTime, time() ))

SM0->( DbGoTo( nRecSM0Bak ) )

cDirSrv := 	"\FTP\GY\TXT\NOVO"
aArqServer := Directory(cDirSrv+"\*.*" ,)    

For j := 1 To Len( aArqServer )
	Aadd( aArqInt , {  aArqServer[ j ][ 1 ] ,  "TXT\NOVO" } )  
Next

//aArqInt := ASort( aArqInt ,,, { | x , y | x[ 2 ] + x[ 1 ] < y[ 2 ] + y[ 1 ] } ) 

conout("GYFAT003 - Apos buscar os arquivos por estado "+ElapTime ( cTime, time() ))

Import()

End Sequence

If ( cFilAnt <> cFilBak )
	cFilAnt	:= cFilBak
	SM0->( DbGoTo( nRecSM0Bak ) )
EndIf


RestArea( aArea )

conout("GYFAT003 - FIM DO PROCESSAMENTO "+ElapTime ( cTime, time() ))
                                                      
Return

/*
Função...............: TelaParam                                      
Objetivo.............: Tela de Parametros
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/
*-----------------------------------------------*
Static Function TelaParam
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel ) 
Local oFont   := TFont():New( 'Arial' )    
Local i 
                                           
oFont:nHeight 	:= 16
oFont:Bold		:= .T. 


@10,10 Say "Total de Arquivos encontrados : " + AllTrim( Str( Len( aArqInt ) ) ) Font oFont COLOR CLR_BLUE Size 200,10 Of oPanel Pixel  

//@130,10 Button 'Parametros' Size 50,12 Action( TelaSx6() ) Of oPanel Pixel

Return

/*
Função...............: Import
Objetivo.............: Leitura e Importação das notas fiscais XML\TXT Prestação de Serviços 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Outubro/2016
*/
*----------------------*
Static Function Import()
*----------------------*      
Local nMaxArq 	:= 1//10
Local nLidos	:= 0	

Local nFim 		:= 0   
Local nTotArq 	:= Len( aArqInt )  

Local nInicio	:= 0
Local i

cIdInt := GetSxeNum( 'ZX0' , 'ZX0_IDINT' ) 
ConfirmSX8()

If !lJob
	ProcRegua( Abs( Int( nTotArq/nMaxArq ) ) )
EndIf

conout("GYFAT003 - Antes while do inicio das threads "+ElapTime ( cTime, time() ))
While nLidos < nTotArq
	conout("GYFAT003 - While["+ALLTRIM(STR(nLidos))+"] das threads "+ElapTime ( cTime, time() ))
	lProcessou := .T.
	IncProc()

	//Tratamento para quantidade maxima de thread para o processamento
	Waitthread()

	nInicio := nLidos + 1 
	nFim 	:= nInicio + nMaxArq - 1 
	If nFim > nTotArq
		nFim := nTotArq
	EndIf
	
   	StartJob('u_GYImpArq' , GetEnvServer() , .F. , aArqInt , nInicio , nFim , aFilEmp , cEmpAnt , cFilAnt , cUserName , cIdInt ,cTime)  

	nLidos += nMaxArq 
EndDo

conout("GYFAT003 - Apos while do inicio das threads "+ElapTime ( cTime, time() ))

Return

/*
Funcao      : Waitthread
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para aguardar para iniciar uma thread.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
Static Function Waitthread()
*--------------------------*
Local nMaxThread:= 13
Local nCount	:= nMaxThread
Local nTime		:= 100
While nCount >= nMaxThread
	aThread := GetUserInfoArray()
	nCount := 0
	For i := 1 to len(aThread)
		If RIGHT(aThread[i][1],1) == "_"
			nCount++
		EndIf            	
	Next i
	If nCount >= nMaxThread
		If nTime > 2000
			nTime := 2000
		Endif
		Sleep(nTime)//Para não ficar um processamento muito alto.
		nTime := nTime + 100
	EndIf
EndDo
Return .T.


*--------------------------------------------------------------------------------------------*
User Function GYImpArq( aArqInt , nInicio , nFim , aFilEmp , cEmp , cFil , cUser , cId, cTime)
*--------------------------------------------------------------------------------------------*
Local cXml
Local oXml
Local aNotas
Local i   
Local cError
Local cWarning	
Local lXml
Local nTamArq
Local nLidos 
Local nHFile   
Local aDadosCli
Local aDadosNF             
Local nItem
Local aItensXml  
Local cMun
Local cCodMun
Local cUF
Local cDirSrv 	           

Private cArquivo 
Private cCNPJ
Private cIdInt 	:= cId

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"

ChkFile( 'SA1' , .F. )
ChkFile( 'SF2' , .F. )
ChkFile( 'SD2' , .F. )
ChkFile( 'SB1' , .F. )
ChkFile( 'SF3' , .F. )
ChkFile( 'SFT' , .F. )

conout("GYFAT003 - Antes inicio for dos arquivos "+ElapTime ( cTime, time() ))
conout("GYFAT003 - nInicio="+ALLTRIM(Str(nInicio))+" |nFim="+ALLTRIM(Str(nFim))+" |Len(aArqInt="+ALLTRIM(STR(Len(aArqInt)))  )
For i:= nInicio To nFim
	cArquivo := aArqInt[ i ][ 1 ] 
	cDirSrv :=  "\FTP\GY\" + aArqInt[ i ][ 2 ]

	If !('.TXT' $ Upper(cArquivo))
		Loop
	EndIf

	cLayout := ''

	nHFile := FOpen( cDirSrv + "\" + cArquivo ) 
	
	nLidos := 0
	FSeek( nHFile , 0 , 0 ) 
	nTamArq := FSeek( nHFile , 0 , 2 ) 
	FSeek( nHFile , 0 , 0 ) 
	aLinha := LerLinhaTxt( nHFile , nTamArq )
	nLidos := aLinha[ 1 ]
	
	/** Le primeira linha do arquivo para buscar o cnpj do Tomador de servicos*/
	If ( nLidos < nTamArq )
		aLinha := LerLinhaTxt( nHFile , nTamArq )
		nLidos := aLinha[ 1 ]
		cLinha := aLinha[ 2 ]
		cCNPJ  := SubStr( cLinha , 71 , 14 )
		cLayout := '3'
	EndIf
	
	If Empty(cLayout)
		GravaLog( "", "" , cArquivo , 'Layout nao encontrado.' , 'R' )			
	    Loop
	EndIf 

	cCNPJ := PadR( cCNPJ , Len( SM0->M0_CGC ) )

	If ( nPosCGC := Ascan( aFilEmp , { | x | x[ 1 ] == cCnpj } ) ) == 0 
		GravaLog( "", "" , cArquivo , 'CNPJ do Emitente (' + cCNPJ + ') nao encontrado no cadastro de empresas.' , 'R' )			
	    Loop		
	EndIf

	If ( cFilAnt <> aFilEmp[ nPosCGC ][ 2 ] )
		cFilAnt := aFilEmp[ nPosCGC ][ 2 ] 
		SM0->(DbGoTo(aFilEmp[ nPosCGC ][ 3 ]  ) )
	EndIf
    
	aDadosCli 	:= {}
	aDadosNF	:= {} 

	Do Case			
		Case ( cLayout == '3' )	  //** Ex. : SP ( TXT )	
			lPrimeiro := .T.
			While nLidos < nTamArq
				If !lPrimeiro  //* Ja leu a primeira linha anteriormente para validar o CPNJ 
					aLinha := LerLinhaTxt( nHFile , nTamArq )
					nLidos := aLinha[ 1 ]
					cLinha := aLinha[ 2 ]
				EndIf 
				
				lPrimeiro := .F.  
				
				aDadosCli := {}
				aDadosNF := {}
				
				If ( SubStr( cLinha , 1 , 1 ) == '2' )

					cUF 	:= SubStr( cLinha , 801 , 2 )
					cMun	:= NoAcento( SubStr( cLinha , 751 , 50 ) )
					cCodMun := ""
					If !Empty( cUF ) .And. cUF <> 'EX' .And. !Empty( cMun ) .And. ;
						CC2->( DbSetOrder( 4 ) , DbSeek( xFilial() + cUF + PadR( cMun , Len( CC2->CC2_MUN ) ) ) )

						cCodMun := CC2->CC2_CODMUN
					EndIf   
					
					If Empty( cUF )
						cUF := 'EX' 
					EndIf   

					cProduto := RetCodProd( SM0->M0_ESTCOB , cUF ) 					

					aDadosCli := {  cCodMun ,; // Codigo Municipio
									If( cUF <> 'EX' , '01058' , '' ) ,; // Pais
									AllTrim( SubStr( cLinha , 681 , 10 ) ) ,; // Numero
									cUF ,; // UF
									AllTrim( SubStr( cLinha , 721 , 30 ) ) ,; // Bairro
									AllTrim( SubStr( cLinha , 631 , 50 ) ) ,; // Endereço 
									cMun ,; // Nome Municipio
									AllTrim( SubStr( cLinha , 553 , 75 ) ) ,; // Nome Cliente     
									AllTrim( SubStr( cLinha , 519 , 14 ) ) ,; // CNPJ/CPF     
									AllTrim( SubStr( cLinha , 803 , 08 ) ) ,; // CEP     								
	                                ""; //** ID Estrangeiro
					               }
					               
					Aadd( aDadosNF , {  StrZero( 1 , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
										cProduto ,; // Cod. Produto 
										"" /*NoAcento( AllTrim( SubStr( cLinha , 1373 , Len( SB1->B1_DESC ) ) )*/ ,; // Descricao
										1 ,; // Quantidade  
										Val( AllTrim( SubStr( cLinha , 448 , 15 ) ) ) / 100 ,; // Valor Unitario
										Val( AllTrim( SubStr( cLinha , 448 , 15 ) ) ) / 100 ,; // Valor Total
					                    Val( AllTrim( SubStr( cLinha , 483 , 04 ) ) ) / 100 ,; // Aliq. ISS
					                    Val( AllTrim( SubStr( cLinha , 448 , 15 ) ) ) / 100 ,; // Base Calculo ISS
					                    Val( AllTrim( SubStr( cLinha , 487 , 15 ) ) ) / 100 ,;   // Valor ISS
					                    Val( AllTrim( SubStr( cLinha , 1037 , 15 ) ) ) / 100 ,; // PIS
					                    Val( AllTrim( SubStr( cLinha , 1052 , 15 ) ) ) / 100 ,; // Cofins
					                    "" ,;   // Chave NFE
					                    StrZero( Val( SubStr( cLinha , 2 , 8 ) ) , 9 ) ,; // Numero NF
					                    'RPS' ,; // Serie NF
					                    StoD( SubStr( cLinha , 10 , 8 ) ),;  // Emissao
					                    StoD( SubStr( cLinha , 10 , 8 ) ),;
					                    StrZero( Val( SubStr( cLinha , 2 , 8 ) ) , 9 );
					                   } )
				EndIf						

				If Len( aDadosNF ) > 0
					GravaNF( aDadosCli , aDadosNF)
				EndIf				
			
			EndDo
			
			FClose( nHFile )				
	EndCase
Next
conout("GYFAT003 - Apos inicio for dos arquivos "+ElapTime ( cTime, time() ))
RpcClearEnv() 

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

                   
DbSelectArea( 'ZX0' )
SET FILTER TO ZX0_IDINT = cIdInt .And. ZX0_FILIAL  = xFilial( 'ZX0' )

@04,05 Button 'Exportar Log' Size 50,10 Action( Exporta() ) Of oPanel Pixel
oBrwPlan := MsSelBr():New( 15 , 05 , 295 , 140 ,,,, oPanel ,,,,,,,,,,,,.F.,'ZX0 ' , .T.,,.F.,,, )      

oBrwPlan:AddColumn( TCColumn():New( 'Status'   , { || If( ZX0->ZX0_STATUS = 'A' ,  oOK , oNO )  },,,,"CENTER"  ,,.T.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Arquivo'  , { || ZX0->ZX0_ARQ },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Nota'     , { || ZX0->ZX0_DOC },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Serie'    , { || ZX0->ZX0_SERIE },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'CNPJ'    , { || ZX0->ZX0_CGC },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Mensagem' , { || AllTrim( MemoLine( ZX0->ZX0_LOG , 200 , 1 ) ) + If( MLCount( ZX0->ZX0_LOG , 200 ) > 1 , ' ...<< Duplo Clique >>' , "" )} ,,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )

	
oBrwPlan:GoTop()
oBrwPlan:Refresh()
oBrwPlan:BLDBLCLICK := { || EECView( ZX0->ZX0_LOG ) }
	

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
Local cFile := GetTempPath() + 'Log_NF_Xml_Ubber_' + DtoS( dDatabase ) + StrTran( Time() , ':' , '' ) + '.xml'
Local i

oExcel := FWMSEXCEL():New()
oExcel:AddWorkSheet("Log")
oExcel:AddTable ("Log","Log da Operacao")   

oExcel:AddColumn("Log","Log da Operacao","Status",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Arquivo",1,1,.F.)
oExcel:AddColumn("Log","Log da Operacao","Nota",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Serie",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","CNPJ",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Mensagem",1,1,.F.)    

ZX0->( DbGoTop() )
While ZX0->( !Eof() )
	oExcel:AddRow("Log","Log da Operacao",{ ZX0->ZX0_STATUS	 ,;
											ZX0->ZX0_ARQ ,;
											ZX0->ZX0_DOC ,;
											ZX0->ZX0_SERIE ,;
											ZX0->ZX0_CGC,;
											ZX0->ZX0_LOG } )											
	ZX0->( DbSkip() )
EndDo   
ZX0->( DbGoTop() )


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
Funcao.........: TelaSx6
Objetivo.......: Tela de parametros
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function TelaSx6
*-----------------------------------------*     
Local oDlg                       
Local nOpc 		:= 0

Local bOk		:= { || nOpc := 1 , oDlg:End() }
Local bCancel	:= { || nOpc := 0 , oDlg:End() }    

Local cProd  	:= cProduto
Local cNat 		:= cNatureza

Define MSDialog oDlg Title 'Parametros' Of oDlg Pixel From 1,1 To 150,350    

	@10,05 Say 'Produto' Size 40,10 Of oDlg Pixel
	@10,50 MSGet cProd Valid( ExistCpo( 'SB1' , cProd, 1 ) ) F3( 'SB1' ) Size 60,10 Of oDlg Pixel	
	
	@25,05 Say 'Natureza' Size 40,10 Of oDlg Pixel
	@25,50 MSGet cNat Valid( ExistCpo( 'SED' , cNat , 1 ) ) F3( 'SED' ) Size 60,10 Of oDlg Pixel		

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered  

If ( nOpc == 1 )  
	cProduto := cProd
	cNatureza := cNat
	PutMV( 'MV_P_00086' , cProduto )	
	PutMV( 'MV_P_00087' , cNatureza )		
EndIf

Return

/*
Função........: LerLinhaTxt
Objetivo......: Ler linha do arquivo texto até CRLF
Autor.........: Leandro Diniz de Brito
Data..........: 03/10/2016
*/
*-------------------------------------------*
Static Function LerLinhaTxt( nHandle , nTamArq )       
*-------------------------------------------*
Local nBytes    
Local nBloco 	:= 500
Local cBuffer  	:= ""
Local cAux 		:= ""
Local nLidos 	:= FSeek( nHandle , 0 , 1 )

While nLidos < nTamArq
	cAux := ""
	nLidos += FRead( nHandle , @cAux , nBloco )
	
	cBuffer += cAux
	If ( nPos := At( CRLF , cBuffer ) ) > 0     
		nVolta := Len( SubStr( cBuffer , nPos + 2 ) )
		FSeek( nHandle , nVolta * - 1 , 1 )	

		nLidos 	:= FSeek( nHandle , 0 , 1 )
		cBuffer := SubStr( cBuffer , 1 , nPos - 1 )
 		Exit		      
	EndIf    
	
EndDo           

Return( { nLidos , cBuffer } )

/*
Funcao      : NoAcento
Parametros  : 
Retorno     :
Objetivos   : Retira caracteres invalidos da string
Autor       : Leandro Brito
Data/Hora   : 10/10/2016
*/
*-------------------------------*
Static Function NoAcento( cInfo )
*-------------------------------* 
Return( Upper( AllTrim( FwNoAccent( cInfo ) ) ) )       

/*
Função........: GravaNF
Objetivo......: Gravar cliente e nota fiscal
Autor.........: Leandro Diniz de Brito
Data..........: 10/10/2016
*/
*--------------------------------------------*
Static Function GravaNF( aDadosCli , aDadosNF)
*--------------------------------------------*
Local i
Local aCab			:= {}
Local aItem	    	:= {} 
Local aAutoItens    := {}
Local aAutoCab		:= {}   
Local cCli
Local cLoja      
Local cUFCli := aDadosCli[ 4 ]  
Local cNF
Local cSerie
Local cLog 
Local cNatureza 	:= PadR( GetMV( 'MV_P_00087' ,, '' )  , Len( SED->ED_CODIGO ) )    

Private lMSErroAuto 
                     
/*
aDadosCli => 	
	[ 1 ] = Codigo Municipio
	[ 2 ] = Codigo Pais
	[ 3 ] = Numero
	[ 4 ] = UF
	[ 5 ] = Bairro
	[ 6 ] = Endereço
	[ 7 ] = Nome Municipio
	[ 8 ] = Nome Cliente 
	[ 9 ] = CNPJ\CGC
	[ 10 ] = CEP 
	[ 11 ] = ID Estrangeiro		

aDadosNF =>
	[ 1 ] = Seq. Item
	[ 2 ] = Cod. Produto 
	[ 3 ] = Descricao
	[ 4 ] = Quantidade
	[ 5 ] = Valor Unitario
	[ 6 ] = Valor Total
	[ 7 ] = Aliq. ISS
	[ 8 ] = Base Calculo ISS
	[ 9 ] = Valor ISS
	[ 10 ] = PIS
	[ 11 ] = Cofins 
	[ 12 ] = Chave NFE
	[ 13 ] = Nota Fiscal
	[ 14 ] = Serie   
	[ 15 ] = Emissao

*/
cNF 	:= aDadosNF[ 1 ][ 13 ] 
cSerie 	:= aDadosNF[ 1 ][ 14 ]

nCGC	:= Val(aDadosCli[9])
cCGC	:= ""

If Len(Alltrim(cValToChar(nCGC))) <= 11
	cCGC:= StrZero(nCGC,11,0)
	aDadosCli[9]:= cCGC
Else
	cCGC:= aDadosCli[9]
EndIf

If !ExistCli( aDadosCli )
	AAdd( aCab , { 'A1_COD' , GETSXENUM("SA1", "A1_COD") , Nil } )
	AAdd( aCab , { 'A1_LOJA' , '01' , Nil } )						
	AAdd( aCab , { 'A1_NOME' , aDadosCli[ 8 ] , Nil } )
	AAdd( aCab , { 'A1_PESSOA' , If( Len( AllTrim( cCGC ) ) > 11 , 'J' , 'F' ) , Nil } )
	AAdd( aCab , { 'A1_NREDUZ' , aDadosCli[ 8 ] , Nil } )
	AAdd( aCab , { 'A1_TIPO' , 'F' , Nil } )
	AAdd( aCab , { 'A1_END' , aDadosCli[ 6 ] , Nil } )
	AAdd( aCab , { 'A1_BAIRRO' , aDadosCli[ 5 ] , Nil } )  
	If ( Val( aDadosCli[ 10 ] ) > 0 )
		AAdd( aCab , { 'A1_CEP' , aDadosCli[ 10 ] , Nil } ) 
	EndIf
	If ( Val( aDadosCli[ 9 ] ) > 0  )
		AAdd( aCab , { 'A1_CGC' , cCGC , Nil } )
	EndIf
	AAdd( aCab , { 'A1_NATUREZ' , cNatureza , Nil } )
	AAdd( aCab , { 'A1_CONTA' , "11211001" , Nil } )
	AAdd( aCab , { 'A1_EST' , aDadosCli[ 4 ] , Nil } )
	If ( cUFCli <> 'EX' )                             
		AAdd( aCab , { 'A1_COD_MUN' , aDadosCli[ 1 ] , Nil } )	
		AAdd( aCab , { 'A1_CODPAIS' , aDadosCli[ 2 ] , Nil } )
	Else
		AAdd( aCab , { 'A1_MUN' , 'EXTERIOR' , Nil } )		
	EndIf         
	
	lMSErroAuto := .F.
	CC2->( DbSetOrder( 1 ) )
	MSExecAuto( { | x , y | Mata030( x , y ) } , aCab , 3 )
	
	If lMSErroAuto     
		cLog := MemoRead( NomeAutoLog() )
		DisarmTransaction()	
		GravaLog( cNF, cSerie , cArquivo , 'Erro na inclusao do cliente.' + Chr( 13 ) + Chr( 10 ) + cLog , 'R' )	
	    Return			
	EndIf                                                         
	
	SA1->(Confirmsx8())

EndIf

cCli  	:= SA1->A1_COD
cLoja	:= SA1->A1_LOJA

/* 
	* Gravação Nota Fiscal	
*/       

SB1->( DbSetOrder( 1 ) )
If SB1->( !DbSeek( xFilial() + cProduto ) )
	GravaLog( cNF, cSerie , cArquivo , 'Codigo de Produto ( ' + cProduto + ') nao cadastrado na Filial do Prestador .' , 'R'  )	
	Return
EndIf

SF2->( DbSetOrder( 1 ) )
IF SF2->( dbSeek(xFilial("SF2")+PadR(cNf,Tamsx3("F2_DOC")[1])+PadR(cSerie,Tamsx3("F2_SERIE")[1])+cCli+cLoja))
	GravaLog( cNF, cSerie , cArquivo , 'Nota Fiscal ja integrada anteriormente .' , 'R'  )		
    Return	
EndIf

cEspecie := "NFPS"
aAdd( aAutoCab , { "F2_FILIAL"  , xFilial('SF2')	, Nil } )
aAdd( aAutoCab , { "F2_TIPO"    , "N"				, Nil } )
aAdd( aAutoCab , { "F2_DOC"     , cNf			   	, Nil } )
aAdd( aAutoCab , { "F2_SERIE"   , cSerie			, Nil } )
aAdd( aAutoCab , { "F2_CLIENTE" , cCli				, Nil } )
aAdd( aAutoCab , { "F2_LOJA"    , cLoja				, Nil } )
aAdd( aAutoCab , { "F2_EMISSAO" , aDadosNf[ 1 ][ 15 ], Nil } ) 
aAdd( aAutoCab , { "F2_ESPECIE" , "NFPS"			, Nil } ) 
aAdd( aAutoCab , { "F2_CHVNFE" , aDadosNf[ 1 ][ 12 ], Nil } )
aAdd( aAutoCab , { "F2_COND" , "001"		    	, Nil } ) 
aAdd( aAutoCab , { "F2_DESCONT" , 0				, Nil } )
aAdd( aAutoCab , { "F2_FRETE" , 0				, Nil } )
aAdd( aAutoCab , { "F2_DESPESA" , 0				, Nil } )
aAdd( aAutoCab , { "F2_SEGURO" , 0				, Nil } )
If SF2->( FieldPos( 'F2_P_RPS' ) ) > 0
	aAdd( aAutoCab , { 'F2_P_RPS' , aDadosNf[ 1 ][ 17 ] , Nil } )
EndIf   
If SF2->( FieldPos( 'F2_P_DTRPS' ) ) > 0
	aAdd( aAutoCab , { 'F2_P_DTRPS' , aDadosNf[ 1 ][ 16 ] , Nil } )
EndIf

For i := 1 To Len( aDadosNF )
	aItem := {}
	cCFOP := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TS,"F4_CF")
	
	If ( cUFCli == 'EX' )	
		cCFOP := '7' + SubsTr( cCFOP , 2 )
	ElseIf ( cUFCli	<> GetMV( 'MV_ESTADO' )  ) 
		cCFOP := '6' + SubsTr( cCFOP , 2 )
	EndIf	
	
	aAdd( aItem , { "D2_FILIAL"  , xFilial('SD2')		, Nil } )
	aAdd( aItem , { "D2_DOC"     , cNf					, Nil } )
	aAdd( aItem , { "D2_SERIE"   , cSerie				, Nil } )
	aAdd( aItem , { "D2_EMISSAO" , aDadosNF[ i ][ 15 ]	, Nil } )	
	aAdd( aItem , { "D2_CLIENTE" , cCli					, Nil } )
	aAdd( aItem , { "D2_LOJA"    , cLoja				, Nil } )
	aAdd( aItem , { "D2_COD"     , SB1->B1_COD			, Nil } )
	aAdd( aItem , { "D2_UM"      , SB1->B1_UM			, Nil } )
	aAdd( aItem , { "D2_QUANT"   , aDadosNF[ i ][ 4 ]	, Nil } )
	aAdd( aItem , { "D2_VUNIT"   , aDadosNF[ i ][ 5 ]	, Nil } )  
	aAdd( aItem , { "D2_PRCVEN"   , aDadosNF[ i ][ 5 ]	, Nil } )	
	aAdd( aItem , { "D2_TOTAL"   , Round( aDadosNF[ i ][ 4 ] * aDadosNF[ i ][ 5 ] , TamSX3( 'D2_TOTAL' )[ 2 ] ) /*aDadosNF[ i ][ 6 ]*/	, Nil } )
	aAdd( aItem , { "D2_TES"     , SB1->B1_TS			, Nil } )
	aAdd( aItem , { "D2_CF"      , cCFOP				, Nil } )
	aAdd( aItem , { "D2_LOCAL"   , SB1->B1_LOCPAD		, Nil } )
	aAdd( aItem , { "D2_ITEM"    , aDadosNF[ i ][ 4 ]	, Nil } )
	
	//->> Impostos -> ISS
	aAdd( aItem , { "D2_BASEISS" , aDadosNF[ i ][ 8 ] , Nil } )
	aAdd( aItem , { "D2_ALIQISS" , aDadosNF[ i ][ 7 ] , Nil } )
	aAdd( aItem , { "D2_VALISS"  , Round( aDadosNF[ i ][ 7 ] * aDadosNF[ i ][ 8 ] /100 , TamSX3( 'D2_VALISS' )[ 2 ] )/*aDadosNF[ i ][ 9 ]*/ , Nil } )
	
	aAdd( aAutoItens, aItem )
Next

lMsErroAuto := .F.
MsExecAuto( {|x,y,z| Mata920(x,y,z)}, aAutoCab, aAutoItens, 3)

If  lMsErroAuto 
	cLog := MemoRead( NomeAutoLog() )	
	DisarmTransaction()
	GravaLog( cNF, cSerie , cArquivo , 'Erro na inclusao da nota Fiscal .' + Chr( 13 ) + Chr( 10 ) + cLog , 'R' )	

Else
	GravaLog( cNF , cSerie , cArquivo , 'Nota Fiscal incluida com sucesso.' , 'A'  )	
EndIf	

Return   

/*
Função..............: ExistCli
Objetivo............: Retornar se deve incluir o cliente
Autor...............: Leandro Diniz de Brito
Data................: 14/10/2016
*/                              
*----------------------------------------* 
Static Function ExistCli( aDadosCli )                  
*----------------------------------------* 
Local lRet  

If ( aDadosCli[ 4 ] == 'EX' )
	SA1->( DbSetOrder( 2 ) )
	lRet := SA1->( DbSeek( xFilial() + aDadosCli[ 8 ] ) ) 
Else
	SA1->( DbSetOrder( 3 ) )
	lRet := SA1->( DbSeek( xFilial() + aDadosCli[ 9 ] ) ) 
EndIf

Return( lRet )      

/*
Função..............: GravaLog
Objetivo............: Gravar Log da Integracao
Autor...............: Leandro Diniz de Brito
Data................: 21/10/2016
*/                              
*---------------------------------------------------------------* 
Static Function GravaLog( cNF, cSerie , cArq , cLog , cStatus )                  
*---------------------------------------------------------------* 
ZX0->( RecLock( 'ZX0' , .T. ) )
ZX0->ZX0_FILIAL := xFilial( 'ZX0' )
ZX0->ZX0_USER 	:= cUserName
ZX0->ZX0_DATA	:= dDatabase
ZX0->ZX0_HORA 	:= Left( Time() , 5 )
ZX0->ZX0_ARQ	:= cArq
ZX0->ZX0_DOC	:= cNF
ZX0->ZX0_SERIE	:= cSerie
ZX0->ZX0_LOG 	:= cLog
ZX0->ZX0_CGC	:= cCNPJ    
ZX0->ZX0_IDINT	:= cIdInt
ZX0->ZX0_STATUS	:= cStatus
ZX0->( MSunlock() ) 

Return

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files (x86)\WinRAR\'

cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)
   

/*
Função............: RetCodProd
Objetivo..........: Retornar código do Produto de acordo com a UF da Nota do Prestador
Parametros........: cUF => Codigo da UF do Prestador ( Tipo C )
					cUFCli => Codigo da UF do Tomador ( Tipo C )					
Retorno...........: cProd =>  Codigo do Produto ( Tipo C )
Autor.............: Leandro Diniz de Brito ( LDB )
Data..............: 28/10/2016
*/
*---------------------------------------* 
Static Function RetCodProd( cUF , cUFCli ) 
*---------------------------------------*    
Local cProd 

cProd := cUF + '00' + If( cUFCli == 'EX' , '3115' , '6157' )

Return( PadR( cProd ,Len( SB1->B1_COD ) ) )