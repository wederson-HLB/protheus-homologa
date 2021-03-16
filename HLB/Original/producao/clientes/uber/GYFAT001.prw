#Include "Protheus.Ch" 
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Função.............: GYFAT001
Autor..............: Leandro Diniz de Brito
		 23/10/2017: Renato Rezende
Objetivo...........: Importar Xml e Txt de Notas de Prestação de Serviço
		 23/10/2017: Ajuste parar ler arquivos da tabela ZX1 
Cliente HLB........: Uber
Data...............: 23/09/2016
*/                             
*--------------------------------------* 
User Function GYFAT001( aParam )
*--------------------------------------*
Local aArea      	:= {}

Local nRecSM0Bak	:= 0
Local cFilBak  	 	:= ""

Local lZX1			:= .F.

Local dDtBkp 		:= CtoD("//")

Private cTime 		:= ""

Private aLog   		:= {}

Private cProduto  	//:= PadR( GetMV( 'MV_P_00086' ,, '' )  , Len( SB1->B1_COD ) )
Private cNatureza 	:= ""

Private lJob 		:= (Select("SX3") <= 0)    

Private aFolderUF   := {}
Private aFilEmp 	:= {}

Private cIdInt
Private lProcessou	:= .F.

Private nTotArq 	:= 0


If !lJob
	If ( !cEmpAnt $ 'GY,99' )
		MsgStop( 'Empresa nao autorizada.' )
		Break
	EndIf
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

//Processa XML da tabela ZX1
lZX1:= Import()


If lZX1
	//Validação para que aguarde terminar todos os Jobs.
	nCount := 2
	nTime  := 200
	While nCount >= 1
		aThread := GetUserInfoArray()
		nCount := 0
		For i := 1 to len(aThread)
			If (nPOs := aScan(aThread, {|x| RIGHT(ALLTRIM(x[1]),1) == "_" })) <> 0
				nCount++
			EndIf            	
		Next i
	    Sleep(nTime)//Para não ficar um processamento muito alto.
		If nTime <= 3000
			nTime := nTime + 100
		EndIf
	EndDo
	
	//Apaga os arquivos do servidor FTP e move para pasta processados ( [cEmpAnt]\[UF]\Processados )
	If lProcessou
		
		//RRP - 10/07/2017 - Envio de email do processamento.
		MailLog()
		
	EndIf
EndIf

If ( cFilAnt <> cFilBak )
	cFilAnt	:= cFilBak
	SM0->( DbGoTo( nRecSM0Bak ) )
EndIf

RestArea( aArea ) 

If lJob
	RpcClearEnv()
EndIf
                     
Return

/*
Função...............: Import
Objetivo.............: Leitura e Importação das notas fiscais XML\TXT Prestação de Serviços 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Outubro/2016
*/
*-----------------------------------------------*
Static Function Import
*-----------------------------------------------*        
Local nMaxArq 	:= 10
Local nLidos	:= 0	

Local nFim 		:= 0   

Local nInicio	:= 0
Local i

Local cQuery	:= ""

Local lRet		:= .T.

cIdInt := GetSxeNum( 'ZX0' , 'ZX0_IDINT' ) 
ConfirmSX8()

If Select("TempZX1") > 0
	TempZX1->(DbCloseArea())
EndIf

cQuery := "SELECT R_E_C_N_O_ FROM "+RetSqlName("ZX1")+" WHERE D_E_L_E_T_ <> '*' ORDER BY ZX1_ARQ "

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TempZX1",.F.,.T.)

//Verifica quantos registros retornaram na consulta
Count to nTotArq

//Volta primeiro registro
TempZX1->(DbGoTop())

//Caso Retorne Arquivo começar o processamento
If nTotArq > 0	
	
	conout("GYFAT001 - Antes while do inicio das threads "+ElapTime ( cTime, time() ))
	While TempZX1->(!EOF())
		conout("GYFAT001 - While["+ALLTRIM(STR(nLidos))+"] das threads "+ElapTime ( cTime, time() ))
		lProcessou	:= .T. 
		nLidos++
        /*nFim		:= nTotArq - nLidos
		
		If nFim < nMaxArq
			nMaxArq:= nFim
		EndIf*/
				
		//Tratamento para quantidade maxima de thread para o processamento
		Waitthread()
		
		StartJob('u_TTImpArq' , GetEnvServer() , .F. , TempZX1->R_E_C_N_O_ , nMaxArq , aFilEmp , cEmpAnt , cFilAnt , cUserName , cIdInt ,cTime)
		
		TempZX1->(DbSkip(nMaxArq))
	EndDo
Else
	lRet:= .F.	
	conout("GYFAT001 - Tabela ZX1 nao possui dados para processamento! "+ElapTime ( cTime, time() ))		
EndIf

conout("GYFAT001 - Apos while do inicio das threads "+ElapTime ( cTime, time() ))
TempZX1->(DbCloseArea())

Return lRet

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

*-----------------------------------------------------------------------------------------------*
 User Function TTImpArq( cRecBkp , nFim , aFilEmp , cEmp , cFil , cUser , cId, cTime)
*-----------------------------------------------------------------------------------------------*
Local oXml

Local i   

Local lXml

Local nTamArq
Local nLidos 
Local nHFile   
Local nItem

Local aDadosCli
Local aDadosNF             
Local aItensXml  

Local cError
Local cWarning	
Local cMun
Local cCodMun
Local cUF
Local cDirSrv 	           


Private cArquivo 
Private cCNPJ
Private cXml 		:= ""
Private cPastXML	:= ""
Private nRECNOBkp	:= 0
Private cIdInt		:= cId

RpcClearEnv()
RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"

ChkFile( 'SA1' , .F. )
ChkFile( 'SF2' , .F. )
ChkFile( 'SD2' , .F. )
ChkFile( 'SB1' , .F. )
ChkFile( 'SF3' , .F. )
ChkFile( 'SFT' , .F. )


DbSelectArea("ZX1") 
ZX1->(DbSetOrder(1))
ZX1->(DbGoTop())
ZX1->(DbGoTo(cRecBkp))

conout("GYFAT001 - Antes inicio for dos Registros "+ElapTime ( cTime, time() ))

For nR:=1 to nFim
	cArquivo := ZX1->ZX1_ARQ

	If !(lXml:=('.XML' $ Upper(cArquivo))) .And. !('.TXT' $ Upper(cArquivo))
		//Return
		ZX1->(DbSkip())
		Loop
	EndIf
		
	cLayout := ''

	If ( lXml )
		cError		:= '' 
		cWarning	:= ''
		cXML		:= ZX1->ZX1_XML
		cPastXML	:= ZX1->ZX1_PFTP
		nRECNOBkp	:= ZX1->(Recno())
		
		oXml := XmlParser( ZX1->ZX1_XML , "_", @cError, @cWarning )
		
		If !Empty( @cError )
			GravaLog( "" , "" , cArquivo , 'Erro na leitura do arquivo.' + Chr( 13 ) + Chr( 10 ) + cError , 'R', cXML, cPastXML, nRECNOBkp )
			//Return
			ZX1->(DbSkip())
			Loop
		EndIf
		
		/*
			* Busca o Layout a ser utilizado
		*/
		If XmlChildEx( oXml , '_NFEPROC' ) <> Nil    
			cUF := oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT
			cCNPJ := oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT

			cLayout  := '1'

		ElseIf ( XmlChildEx( oXml , "_GERARNFSERESPOSTA" ) <> Nil  )  .And. ( XmlChildEx( oXml:_GERARNFSERESPOSTA , "_COMPNFSE" ) <> Nil  )  
			cUf := oXml:_GERARNFSERESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT
			cCNPJ := oXml:_GERARNFSERESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT
            oXml := oXml:_GERARNFSERESPOSTA:_COMPNFSE:_NFSE:_INFNFSE
			cLayout  := '2'  
			 
		ElseIf ( XmlChildEx( oXml , "_CONSULTARNFSERPSRESPOSTA" ) <> Nil  )  .And. ( XmlChildEx( oXml:_CONSULTARNFSERPSRESPOSTA , "_COMPNFSE" ) <> Nil  )  		
			
			cUf := oXml:_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT
			cCNPJ := oXml:_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT
			oXml := oXml:_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE
			cLayout  := '2'  
						
		ElseIf ( XmlChildEx( oXml , "_GERARNFSERESPOSTA" ) <> Nil  ) .And. ( XmlChildEx( oXml:_GERARNFSERESPOSTA , "_LISTANFSE" ) <> Nil  ) 
			cUf 	:= oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT
			cCNPJ 	:= oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT
            oXml := oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE
	            
				cLayout  := '2'			
	
		ElseIf ( XmlChildEx( oXml , "_RETORNOCONSULTA" ) <> Nil  ) .And. ( XmlChildEx( oXml:_RETORNOCONSULTA , "_CABECALHO" ) <> Nil  ) 
			cUf 	:= oXml:_RETORNOCONSULTA:_NFE:_ENDERECOPRESTADOR:_UF:TEXT
			cCNPJ 	:= oXml:_RETORNOCONSULTA:_NFE:_CPFCNPJPRESTADOR:_CNPJ:TEXT

            
			cLayout  := '4'			
			
		EndIf    
	
	Else
		nHFile := FOpen( cDirSrv + "\" + cArquivo ) 
		
		nLidos := 0
		FSeek( nHFile , 0 , 0 ) 
		nTamArq := FSeek( nHFile , 0 , 2 ) 
		FSeek( nHFile , 0 , 0 ) 
		aLinha := LerLinhaTxt( nHFile , nTamArq )
		nLidos := aLinha[ 1 ]
		
		/*
			* Le primeira linha do arquivo para buscar o cnpj do Tomador de servicos
		*/
		If ( nLidos < nTamArq )
			aLinha := LerLinhaTxt( nHFile , nTamArq )
			nLidos := aLinha[ 1 ]
			cLinha := aLinha[ 2 ]
			cCNPJ  := SubStr( cLinha , 71 , 14 )
			
			cLayout := '3'

		EndIf
		
	EndIf
	
	If Empty( cLayout )
		GravaLog( "", "" , cArquivo , 'Layout nao encontrado.' , 'R', cXML, cPastXML, nRECNOBkp )			
		//Return
		ZX1->(DbSkip())
	    Loop
	EndIf 
	
	cCNPJ := PadR( cCNPJ , Len( SM0->M0_CGC ) )
	
	If ( nPosCGC := Ascan( aFilEmp , { | x | x[ 1 ] == cCnpj } ) ) == 0 
		GravaLog( "", "" , cArquivo , 'CNPJ do Emitente (' + cCNPJ + ') nao encontrado no cadastro de empresas.' , 'R', cXML, cPastXML, nRECNOBkp )			
		//Return
		ZX1->(DbSkip())
	    Loop		
	EndIf
	
	
	If ( cFilAnt <> aFilEmp[ nPosCGC ][ 2 ] )
		cFilAnt := aFilEmp[ nPosCGC ][ 2 ] 
		SM0->( DbGoTo( aFilEmp[ nPosCGC ][ 3 ]  ) )
	EndIf
    
	aDadosCli 	:= {}
	aDadosNF	:= {} 
	
	 	
	Do Case 
		Case ( cLayout == '1' )   //** Ex. : DF

			oNodeCli := oXml:_NFEPROC:_NFE:_INFNFE:_DEST
			cProduto := RetCodProd( SM0->M0_ESTCOB , oNodeCli:_ENDERDEST:_UF:TEXT ) 
			aDadosCli := {  SubStr( oNodeCli:_ENDERDEST:_CMUN:TEXT , 3 ) ,; // Codigo Municipio
							StrZero( Val( oNodeCli:_ENDERDEST:_CPAIS:TEXT ) , 5 ) ,; // Pais
							oNodeCli:_ENDERDEST:_NRO:TEXT ,; // Numero
							oNodeCli:_ENDERDEST:_UF:TEXT ,; // UF
							NoAcento( oNodeCli:_ENDERDEST:_XBAIRRO:TEXT ) ,; // Bairro
							NoAcento( oNodeCli:_ENDERDEST:_XLGR:TEXT ) ,; // Endereço 
							NoAcento( oNodeCli:_ENDERDEST:_XMUN:TEXT ) ,; // Nome Municipio
							PadR( NoAcento( oNodeCli:_XNOME:TEXT ) , Len( SA1->A1_NOME ) ) } // Nome Cliente     
							
			If XmlChildEx( oNodeCli, "_CNPJ" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_CNPJ:TEXT )
			ElseIf XmlChildEx( oNodeCli, "_CPF" ) <> Nil 
				AAdd( aDadosCli  , oNodeCli:_CPF:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf  
			
			If XmlChildEx( oNodeCli:_ENDERDEST, "_CEP" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERDEST:_CEP:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 			 
			
			If XmlChildEx( oNodeCli, "_IDESTRANGEIRO" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_IDESTRANGEIRO:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 						
			
			If	XmlChildEx( oXml:_NFEPROC, "_PROTNFE" ) <> Nil
				cChaveNFe := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
			Else
				cChaveNFe:= ""
			EndIf
			
			//RSB - 09/06/2017 - No caso do DF trocar a data de emissão pela data de Recebmento/Autorização
			//If "DF" $ cUF .AND. XmlChildEx( oXml:_NFEPROC, "_PROTNFE" ) <> Nil
			//	cDtEmissao := StoD( Left( StrTran( oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT , "-" , "" ) , 10 ))
			//Else
				cDtEmissao := StoD( Left( StrTran( oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT , "-" , "" ) , 10 ))
			//Endif
			aItensXml := oXml:_NFEPROC:_NFE:_INFNFE:_DET
			If ValType( aItensXml ) <> 'A'			
				aItensXml := { aItensXml }
			EndIf
				
			For nItem := 1 To Len( aItensXml )
				Aadd( aDadosNF , {  StrZero( Val( aItensXml[ nItem ]:_NITEM:TEXT ) , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
									cProduto /*aItensXml[ nItem ]:_PROD:_CPROD:TEXT*/ ,; // Cod. Produto 
									NoAcento( aItensXml[ nItem ]:_PROD:_XPROD:TEXT ) ,; // Descricao
									Val( aItensXml[ nItem ]:_PROD:_QCOM:TEXT ) ,; // Quantidade  
									Val( aItensXml[ nItem ]:_PROD:_VUNCOM:TEXT ) ,; // Valor Unitario
									Val( aItensXml[ nItem ]:_PROD:_VPROD:TEXT ) ,; // Valor Total
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_ISSQN:_VALIQ:TEXT ) ,; // Aliq. ISS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_ISSQN:_VBC:TEXT ) ,; // Base Calculo ISS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_ISSQN:_VISSQN:TEXT ) ,;   // Valor ISS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_PIS:TEXT ) ,; // PIS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_COFINS:TEXT ) ,; // Cofins
			                        cChaveNFe										,;   // Chave NFE
			                        StrZero( Val( oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT ) , 9 ) ,; // Numero NF
			                        oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT ,; // Serie NF
			                        cDtEmissao,; // Emissao
			                        cDtEmissao,;
			                        oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_CNF:TEXT;
			                        } )
			Next   

			If Len( aDadosNF ) > 0
				GravaNF( aDadosCli , aDadosNF )
			EndIf				
			
		Case ( cLayout == '2' )   //** Ex. : RJ        
	
			oNodeCli := oXml:_TOMADORSERVICO
			cProduto := RetCodProd( SM0->M0_ESTCOB , oNodeCli:_ENDERECO:_UF:TEXT ) 

			aDadosCli := { SubStr( oNodeCli:_ENDERECO:_CODIGOMUNICIPIO:TEXT , 3 ) ,; // Codigo Municipio
							If( oNodeCli:_ENDERECO:_UF:TEXT <> 'EX' , '01058' , '' ) ,; // Pais
							oNodeCli:_ENDERECO:_NUMERO:TEXT ,; // Numero
							oNodeCli:_ENDERECO:_UF:TEXT ,; // UF
							NoAcento( oNodeCli:_ENDERECO:_BAIRRO:TEXT ) ,; // Bairro
							NoAcento( oNodeCli:_ENDERECO:_ENDERECO:TEXT ) ,; // Endereço 
							'' ,; // Nome Municipio
							PadR( NoAcento( oNodeCli:_RAZAOSOCIAL:TEXT ) , Len( SA1->A1_NOME ) ) } // Nome Cliente     
							
			If XmlChildEx( oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ, "_CNPJ" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT )
			ElseIf XmlChildEx( oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ, "_CPF" ) <> Nil 
				AAdd( aDadosCli  , oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf  
			
			If XmlChildEx( oNodeCli:_ENDERECO, "_CEP" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERECO:_CEP:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 			 
			
			If XmlChildEx( oNodeCli:_ENDERECO , "_IDESTRANGEIRO" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERECO:_IDESTRANGEIRO:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 						
			
			aItensXml := oXml:_SERVICO
			If ValType( aItensXml ) <> 'A'			
				aItensXml := { aItensXml }
			EndIf
			nItemNF := 0	
			For nItem := 1 To Len( aItensXml )
				nItemNF += 1
				Aadd( aDadosNF , {  StrZero( nItemNF , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
									cProduto /*aItensXml[ nItem ]:_PROD:_CPROD:TEXT*/ ,; // Cod. Produto 
									"" /* NoAcento( aItensXml[ nItem ]:_DISCRIMINACAO:TEXT ) */ ,; // Descricao
									1 ,; // Quantidade  
									Val( aItensXml[ nItem ]:_VALORES:_VALORSERVICOS:TEXT ) ,; // Valor Unitario
									Val( aItensXml[ nItem ]:_VALORES:_VALORSERVICOS:TEXT ) ,; // Valor Total
			                        Val( aItensXml[ nItem ]:_VALORES:_ALIQUOTA:TEXT )*100 ,; // Aliq. ISS
			                        Val( aItensXml[ nItem ]:_VALORES:_BASECALCULO:TEXT ) ,; // Base Calculo ISS
			                        Val( aItensXml[ nItem ]:_VALORES:_VALORISS:TEXT ) ,;   // Valor ISS
			                        0 ,; // PIS
			                        0 ,; // Cofins
			                        '' ,;   // Chave NFE
			                        StrZero( Val( oXml:_IDENTIFICACAORPS:_NUMERO:TEXT ) , 9 ) ,; // Numero NF
			                        oXml:_IDENTIFICACAORPS:_SERIE:TEXT ,; // Serie NF
			                        StoD( Left( StrTran( oXml:_DATAEMISSAO:TEXT , "-" , "" ) , 10 )),;  // Emissao
			                        StoD( Left( StrTran( oXml:_DATAEMISSAORPS:TEXT , "-" , "" ) , 10 )),; // Data RPS
			                        oXml:_NUMERO:TEXT ;
			                        } )
			Next   		

			If Len( aDadosNF ) > 0
				GravaNF( aDadosCli , aDadosNF )
			EndIf				
			
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
	
					aDadosCli := { cCodMun ,; // Codigo Municipio
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
					GravaNF( aDadosCli , aDadosNF )
				EndIf				
			
			EndDo
			
			FClose( nHFile )						

		Case ( cLayout == '4' )   //** Ex. : SP        
	
			oNodeCli := oXml:_RETORNOCONSULTA:_NFE:_ENDERECOTOMADOR
			cProduto := RetCodProd( SM0->M0_ESTCOB , oNodeCli:_UF:TEXT ) 

			aDadosCli := { SubStr( oNodeCli:_CIDADE:TEXT , 3 ) ,; // Codigo Municipio
							'01058' ,; // Pais
							oNodeCli:_NUMEROENDERECO:TEXT ,; // Numero
							oNodeCli:_UF:TEXT ,; // UF
							NoAcento( IF("N/A" $ Upper( oNodeCli:_BAIRRO:TEXT ) , "" , oNodeCli:_BAIRRO:TEXT ) ) ,; // Bairro
							NoAcento( oNodeCli:_LOGRADOURO:TEXT ) ,; // Endereço 
							'' ,; // Nome Municipio
							PadR( NoAcento( oXml:_RETORNOCONSULTA:_NFE:_RAZAOSOCIALTOMADOR:TEXT ) , Len( SA1->A1_NOME ) ) } // Nome Cliente     
							
			If XmlChildEx( oXml:_RETORNOCONSULTA:_NFE:_CPFCNPJTOMADOR , "_CNPJ" ) <> Nil	
				AAdd( aDadosCli  , oXml:_RETORNOCONSULTA:_NFE:_CPFCNPJTOMADOR:_CNPJ:TEXT )
			ElseIf XmlChildEx( oXml:_RETORNOCONSULTA:_NFE:_CPFCNPJTOMADOR, "_CPF" ) <> Nil 
				AAdd( aDadosCli  , oXml:_RETORNOCONSULTA:_NFE:_CPFCNPJTOMADOR:_CPF:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf  
			
			If XmlChildEx( oNodeCli , "_CEP" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_CEP:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 			 
			
			AAdd( aDadosCli , '' )
			
			Aadd( aDadosNF , {	StrZero( 1 , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
								cProduto /*aItensXml[ nItem ]:_PROD:_CPROD:TEXT*/ ,; // Cod. Produto 
								"" /* NoAcento( aItensXml[ nItem ]:_DISCRIMINACAO:TEXT ) */ ,; // Descricao
								1 ,; // Quantidade  
								Val( oXml:_RETORNOCONSULTA:_NFE:_VALORSERVICOS:TEXT ) ,; // Valor Unitario
								Val( oXml:_RETORNOCONSULTA:_NFE:_VALORSERVICOS:TEXT ) ,; // Valor Total
		                        Val( oXml:_RETORNOCONSULTA:_NFE:_ALIQUOTASERVICOS:TEXT )*100 ,; // Aliq. ISS
		                        Val( oXml:_RETORNOCONSULTA:_NFE:_VALORSERVICOS:TEXT ) ,; // Base Calculo ISS
		                        Val( oXml:_RETORNOCONSULTA:_NFE:_VALORISS:TEXT ) ,;   // Valor ISS
		                        0 ,; // PIS
		                        0 ,; // Cofins
		                        '' ,;   // Chave NFE
		                        StrZero( Val( oXml:_RETORNOCONSULTA:_NFE:_CHAVENFE:_NUMERONFE:TEXT ) , 9 ) ,; // Numero NF
		                        'RPS' ,; // Serie NF
		                        StoD( Left( StrTran( oXml:_RETORNOCONSULTA:_NFE:_DATAEMISSAONFE:TEXT , "-" , "" ) , 10 )),;  // Emissao
		                        StoD( Left( StrTran( oXml:_RETORNOCONSULTA:_NFE:_DATAEMISSAORPS:TEXT , "-" , "" ) , 10 )),;
		                        oXml:_RETORNOCONSULTA:_NFE:_CHAVERPS:_NUMERORPS:TEXT;
		                        } )

			If Len( aDadosNF ) > 0
				GravaNF( aDadosCli , aDadosNF )
			EndIf				
				
	EndCase
	ZX1->(DbSkip())
Next nR
conout("GYFAT001 - Apos inicio for dos arquivos "+ElapTime ( cTime, time() ))

RpcClearEnv()

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
*----------------------------------------------*
Static Function GravaNF( aDadosCli , aDadosNF )
*----------------------------------------------*
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
                 
If !ExistCli( aDadosCli )						
	AAdd( aCab , { 'A1_COD' , GETSXENUM("SA1", "A1_COD") , Nil } )
	AAdd( aCab , { 'A1_LOJA' , '01' , Nil } )						
	AAdd( aCab , { 'A1_NOME' , aDadosCli[ 8 ] , Nil } )
	AAdd( aCab , { 'A1_PESSOA' , If( Len( AllTrim( aDadosCli[ 9 ] ) ) > 11 , 'J' , 'F' ) , Nil } )
	AAdd( aCab , { 'A1_NREDUZ' , aDadosCli[ 8 ] , Nil } )
	AAdd( aCab , { 'A1_TIPO' , 'F' , Nil } )
	AAdd( aCab , { 'A1_END' , aDadosCli[ 6 ] , Nil } )
	AAdd( aCab , { 'A1_BAIRRO' , aDadosCli[ 5 ] , Nil } )  
	
	If ( Val( aDadosCli[ 10 ] ) > 0 )
		AAdd( aCab , { 'A1_CEP' , aDadosCli[ 10 ] , Nil } ) 
	EndIf
		
	
	If ( Val( aDadosCli[ 9 ] ) > 0  )
		AAdd( aCab , { 'A1_CGC' , aDadosCli[ 9 ] , Nil } )
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
		GravaLog( cNF, cSerie , cArquivo , 'Erro na inclusao do cliente.' + Chr( 13 ) + Chr( 10 ) + cLog , 'R', cXML, cPastXML, nRECNOBkp )	
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
	GravaLog( cNF, cSerie , cArquivo , 'Codigo de Produto ( ' + cProduto + ') nao cadastrado na Filial do Prestador .' , 'R', cXML, cPastXML, nRECNOBkp  )	
	Return
EndIf
              

SF2->( DbSetOrder( 1 ) )
IF SF2->( dbSeek(xFilial("SF2")+PadR(cNf,Tamsx3("F2_DOC")[1])+PadR(cSerie,Tamsx3("F2_SERIE")[1])+cCli+cLoja))
	GravaLog( cNF, cSerie , cArquivo , 'Nota Fiscal ja integrada anteriormente .' , 'A', cXML, cPastXML, nRECNOBkp  )		
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
	GravaLog( cNF, cSerie , cArquivo , 'Erro na inclusao da nota Fiscal .' + Chr( 13 ) + Chr( 10 ) + cLog , 'R', cXML, cPastXML, nRECNOBkp )	
	
Else
	GravaLog( cNF , cSerie , cArquivo , 'Nota Fiscal incluida com sucesso.' , 'S', cXML, cPastXML, nRECNOBkp  )	
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
*----------------------------------------------------------------------------------------------* 
Static Function GravaLog( cNF, cSerie , cArq , cLog , cStatus, cBkpXml, cPastFtp, nRecProc )                  
*----------------------------------------------------------------------------------------------* 
Local cQuery:= ""

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
ZX0->ZX0_XML	:= cBkpXml
ZX0->ZX0_PFTP	:= cPastFtp 
ZX0->( MSunlock() )

cQuery:= "DELETE "+RetSqlName("ZX1")+" WHERE R_E_C_N_O_ = "+Alltrim(Str(nRecProc))+" "

TcSqlExec(cQuery)

Return

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

/*
Funcao      : MailLog
Parametros  :
Retorno     :
Objetivos   : Envia email de processamento
Autor       : Renato Rezende
Data/Hora   : 
*/
*----------------------------------------*
 Static Function MailLog()
*----------------------------------------*
Local i,nR

Local cFrom			:= AllTrim(GetMv("MV_RELFROM"))
Local cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
Local lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
Local cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
Local cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
Local cTo 			:= AllTrim(SuperGetMv( "MV_P_00101" , .F. , "renato.rezende@hlb.com.br" ,  ))//Email que será enviado o log de processamento.
Local cCC			:= ""
Local cToOculto		:= "" 
Local cAttachment 	:= ""
Local cArqMail 		:= ""
Local cSubject		:= "Processamento Arquivo - UBER "+DtoC(Date())

Private cMsg  := ""
Private cDate := DtoC(Date())
Private cTime := SubStr(Time(),1,5)
Private cUser := UsrFullName(RetCodUsr())

If Empty((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	Return .F.
EndIf

If Empty((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	Return .F.
EndIf

cAttachment	:= GeraAnexo()

cMsg := Email()

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	Return .F.
Else
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			ConOut("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			Return .F.
		EndIf
	EndIf
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK
	Else
		SEND MAIL FROM cFrom TO cTo BCC cToOculto;
		SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK
	EndIf
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+Alltrim(cTo))
		DISCONNECT SMTP SERVER
		Return .F.
	EndIf
EndIf

DISCONNECT SMTP SERVER

//Apaga arquivo anexo
FErase(cAttachment)

Return .T.

/*
Funcao      : Email
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criar Email de Notificação
Autor       : Renato Rezende
Data/Hora   : 
*/
*---------------------*
Static Function Email()
*---------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>PROCESSAMENTO</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">QTD. ARQS.: '+AllTrim( Str( nTotArq ) )+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ERROS ANEXO NO EMAIL</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml


/*
Funcao      : GeraAnexo
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera arquivo de log
Autor       : Renato Rezende
Data/Hora   : 
*/
*----------------------------*
Static Function GeraAnexo()
*----------------------------*
Local cArqDBF		:= ""
Local cDiretorio	:= "\FTP\GY\GYFAT002"  
Local cDirLocal		:= ""
Local cQuery1 		:= ""

If Select("AliasZX0") > 0 
	AliasZX0->(DbCloseArea())
EndIf

cQuery1 := "SELECT cast(cast(ZX0_LOG as varbinary(249))as varchar(249))AS ZX0_LOG,ZX0_FILIAL,ZX0_DOC,ZX0_SERIE,ZX0_CGC,ZX0_USER, " 
cQuery1 += "	   ZX0_DATA,ZX0_HORA,ZX0_ARQ,ZX0_IDINT,ZX0_STATUS,ZX0_PFTP,R_E_C_N_O_ "
cQuery1 += "  FROM "+RetSqlName("ZX0")+" " 
cQuery1 += " WHERE ISNULL(CONVERT(VARCHAR(4096), CONVERT(VARBINARY(4096), ZX0_LOG)),'') NOT LIKE '%Nota Fiscal ja integrada anteriormente .%' " 
cQuery1 += " AND ZX0_STATUS = 'R' AND D_E_L_E_T_ <> '*' AND ZX0_IDINT='"+cIdInt+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"AliasZX0",.T.,.T.)

DbSelectArea("AliasZX0")
cArqDBF	:= "PROCESSAMENTO_LOG_ERRO_UBER_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
cDirLocal	:= cDiretorio +"\"+ cArqDBF
FErase(cDirLocal)//Excluir arquivo
Copy To &(cDirLocal)//Gera o arquivo na pasta com toda a estrutura da area em aberto
AliasZX0->(DbCloseArea())

Return cDirLocal