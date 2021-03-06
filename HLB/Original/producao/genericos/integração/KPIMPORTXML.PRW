#Include "Protheus.Ch"
#Include "Tbiconn.Ch"                
#Include "topconn.Ch"                
#Include "Shell.Ch"  
#Include "Ap5Mail.ch"

Static aLog	:= {}

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    � KPImpXML   � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Rotina de Importa��o de XML para notas de servi�o.          ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � KpImpXml()		                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
User Function KPIMPNFS(cEmp,cFil)
Local cDirOrigXml 	:= ""
Local lAuto       	:= .F.
Local nOpc			:= 0

Private _cCnpjKeep	:= ""

Default cEmp		:= ""
Default cFil		:= ""

If !(Type("aArqXml")) == "U" 
	Default aArqXml		:= {}
EndIf

If !Empty(cEmp) .And. !Empty(cFil)
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
	lAuto       := .T.
	cDirOrigXml 	:= GetNewPar( "KP_PASTXML" , "C:\TEMP\KEEPTRUE\XML" )
	aArqXml := ExtraiArq(3,@cDirOrigXml)
Else
	cDirOrigXml 	:= GetNewPar( "KP_PASTXML" , "C:\TEMP\KEEPTRUE\XML" )
	nOpc := Aviso( 'Importa��o Xml para notas de servi�o.' , 'O que deseja processar?' , { '&Arquivo' , '&Diret�rio' , '&Cancelar' } , 2 )
    If nOpc==1
    	aArqXml := ExtraiArq(1,@cDirOrigXml)
    ElseIf nOpc==2
    	aArqXml := ExtraiArq(2,@cDirOrigXml)
    ElseIf nOpc==3
    	Return
    EndIf
EndIf

_cCnpjKeep := SM0->M0_CGC

If Len(aArqXml)>0
	//->> Importa��o dos XMLs
	ImportarXml(lAuto,aArqXml,cDirOrigXml)
EndIf

//->> Gravacao do log de erro                             
GeraLogErro()

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    � KPImpXML   � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Adquire os arquivos.							            ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � 1 = Um Unico, 2 - Varios                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function ExtraiArq(nTipo,cDirOrigXml)
Local aArquivos := {} 
Local aArqTemp	:= {}
Local cArquivo	:= ""   
Local cPasta	:= "" 
Local nX		:= 0

If nTipo == 1 // Selecionando um unico arquivo
	cArquivo := UPPER(cGetFile("Arquivo XML (*.xml)|*.xml" , "Selecione o arquivo...",,cDirOrigXml,,GETF_LOCALHARD+GETF_NETWORKDRIVE))
	If !Empty(cArquivo)
		cDirOrigXml := Left(cArquivo,Rat('\',cArquivo))
		cArquivo    := SubStr(cArquivo,Rat('\',cArquivo)+1)
		aAdd(aArquivos,{cArquivo})
	EndIf	
ElseIf nTipo == 2 // Automatico selecionando a pasta
	cPasta := cGetFile(cDirOrigXml,"Selecione a pasta para sele��o autom�tica dos XMLs...",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	aArqTemp := Directory(cPasta+'\*.xml')
	ASort( aArqTemp ,,, {|x,y| x[1] < y[1]} )	
	For nX:=1 to Len(aArqTemp) 
		aAdd(aArquivos,{aArqTemp[nX,01]})	
	Next nX
	cDirOrigXml:=cPasta
ElseIf nTipo == 3 // Automatico via schedulle
	aArqTemp := Directory(cDirOrigXml+'\*.xml')
	ASort( aArqTemp ,,, {|x,y| x[1] < y[1]} )	
	For nX:=1 to Len(aArqTemp) 
		aAdd(aArquivos,{aArqTemp[nX,01]})	
	Next nX            
	cDirOrigXml:=cPasta
EndIf

Return aArquivos
                              
/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �ImportarXml � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Processamento da Importacao.					            ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � KpImpXml()		                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function ImportarXml(lAuto,aArqXml,cDirOrigXml)
Local nX:= 0

Default lAuto := .F.

For nX:=1 to Len(aArqXml)
	If !lAuto
		Processa( { || GeraNFS(cDirOrigXml+aArqXml[nX,01],lAuto) } , 'Aguarde...' , 'Gerando Notas de Servi�o' )
	Else	
		GeraNFS(cDirOrigXml+aArqXml[nX,01],lAuto)
	EndIf	
Next nX

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �GeraNFS     � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Geracao da NFS.									            ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � GeraNFS()		                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function GeraNFS(cArquivo,lAuto)
Local oXml 		:= OpenXml(cArquivo)
Local aNF		:= ExtraiNf(oXml)
Local aAutoCab  := {}           
Local aItem		:= {} 
Local aAutoItens:= {}         
Local lRet		:= .F.
Local cNewArq	:= ""    

Private lMsErroAuto := .F.
               
If Len(aNF)>0  	
	If GetProduto(aNF[04],aNF[07],aNF[11])
		If aNF[1]=="SAIDA"			
	    	If GetCliente(aNF[13])
	    		SF2->(dbSetOrder(1))
	    		IF !SF2->(dbSeek(xFilial("SF2")+PadR(aNF[2],Tamsx3("F2_DOC")[1])+PadR(aNF[3],Tamsx3("F2_SERIE")[1])+SA1->(A1_COD+A1_LOJA)+"N"))    	
					aAdd( aAutoCab , { "F2_FILIAL"  , xFilial('SF2')								, Nil } ) 
					aAdd( aAutoCab , { "F2_TIPO"    , "N"											, Nil } )
					aAdd( aAutoCab , { "F2_DOC"     , aNF[02]									   	, Nil } )
					aAdd( aAutoCab , { "F2_SERIE"   , aNF[03]										, Nil } )
					aAdd( aAutoCab , { "F2_CLIENTE" , SA1->A1_COD									, Nil } )
					aAdd( aAutoCab , { "F2_LOJA"    , SA1->A1_LOJA									, Nil } )
					aAdd( aAutoCab , { "F2_EMISSAO" , aNF[05]										, Nil } )
					aAdd( aAutoCab , { "F2_ESPECIE" , "NFS"											, Nil } )
	    	                                                                                    
	    			aItem := {}
					cCFOP := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TS,"F4_CF")
					
					aAdd( aItem , { "D2_FILIAL"  , xFilial('SD2')				, Nil } )
					aAdd( aItem , { "D2_DOC"     , aNF[02]						, Nil } )
					aAdd( aItem , { "D2_SERIE"   , aNF[03]						, Nil } )
					aAdd( aItem , { "D2_CLIENTE" , SA1->A1_COD					, Nil } )
					aAdd( aItem , { "D2_LOJA"    , SA1->A1_LOJA					, Nil } )
					aAdd( aItem , { "D2_COD"     , SB1->B1_COD					, Nil } )
					aAdd( aItem , { "D2_UM"      , SB1->B1_UM					, Nil } )
					aAdd( aItem , { "D2_QUANT"   , 1							, Nil } )
					aAdd( aItem , { "D2_VUNIT"   , aNF[06]						, Nil } )
					aAdd( aItem , { "D2_TOTAL"   , aNF[10]						, Nil } )
					aAdd( aItem , { "D2_TES"     , SB1->B1_TS					, Nil } )
					aAdd( aItem , { "D2_CF"      , cCFOP						, Nil } )
					aAdd( aItem , { "D2_LOCAL"   , SB1->B1_LOCPAD				, Nil } )
					aAdd( aItem , { "D2_ITEM"    , "01"							, Nil } ) 
					aAdd( aItem , { "D2_BASEISS" , aNF[08]						, Nil } ) 
					aAdd( aItem , { "D2_ALIQISS" , aNF[07]						, Nil } ) 
					aAdd( aItem , { "D2_VALISS"  , aNF[09]						, Nil } )
				
					aAdd( aAutoItens, aItem )
			    	                                                                  
			    	MsExecAuto( {|x,y,z| Mata920(x,y,z)}, aAutoCab, aAutoItens, 3)
					If  lMsErroAuto		
					   	aAdd(aLog,{"SF2",'Nota n�o importada:'+CRLF+'"'+aNF[02]+'"'+CRLF})
					   	DisarmTransaction()
					   	MostraErro()
					Else
					   	lRet := .T.				
					EndIf
			    Else
			    	aAdd(aLog,{"SF2",'Nota ja cadastrada:'+CRLF+'"'+aNF[02]+'"'+CRLF})
	            EndIf	
	        EndIf
	    ElseIf aNF[1]=="ENTRADA"
	    	If GetFornece(aNF[12]) 
	    		SF1->(dbSetOrder(1))
	    		IF !SF1->(dbSeek(xFilial("SF1")+PadR(aNF[2],Tamsx3("F1_DOC")[1])+PadR(aNF[3],Tamsx3("F1_SERIE")[1])+SA2->(A2_COD+A2_LOJA)+"N"))    	
					aAdd( aAutoCab , { "F1_FILIAL"  , xFilial('SF1')								, Nil } ) 
					aAdd( aAutoCab , { "F1_TIPO"    , "N"											, Nil } )
					aAdd( aAutoCab , { "F1_DOC"     , aNF[02]									   	, Nil } )
					aAdd( aAutoCab , { "F1_SERIE"   , aNF[03]										, Nil } )
					aAdd( aAutoCab , { "F1_FORNECE" , SA2->A2_COD									, Nil } )
					aAdd( aAutoCab , { "F1_LOJA"    , SA2->A2_LOJA									, Nil } )
					aAdd( aAutoCab , { "F1_EMISSAO" , aNF[05]										, Nil } )
					aAdd( aAutoCab , { "F1_ESPECIE" , ""											, Nil } )
					aAdd( aAutoCab , { "F1_DTDIGIT" , aNF[05]										, Nil } )
	    	                                                                                    
	    			aItem := {}
					cCFOP := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TE,"F4_CF")
					
					aAdd( aItem , { "D1_FILIAL"  , xFilial('SD1')				, Nil } )
					aAdd( aItem , { "D1_DOC"     , aNF[02]						, Nil } )
					aAdd( aItem , { "D1_SERIE"   , aNF[03]						, Nil } )
					aAdd( aItem , { "D1_FORNECE" , SA2->A2_COD					, Nil } )
					aAdd( aItem , { "D1_LOJA"    , SA2->A2_LOJA					, Nil } )
					aAdd( aItem , { "D1_COD"     , SB1->B1_COD					, Nil } )
					aAdd( aItem , { "D1_UM"      , SB1->B1_UM					, Nil } )
					aAdd( aItem , { "D1_QUANT"   , 1							, Nil } )
					aAdd( aItem , { "D1_VUNIT"   , aNF[06]						, Nil } )
					aAdd( aItem , { "D1_TOTAL"   , aNF[06]						, Nil } )
					aAdd( aItem , { "D1_TES"     , SB1->B1_TE					, Nil } )
					aAdd( aItem , { "D1_CF"      , cCFOP						, Nil } )
					aAdd( aItem , { "D1_LOCAL"   , SB1->B1_LOCPAD				, Nil } )
					aAdd( aItem , { "D1_ITEM"    , "01"							, Nil } ) 
					aAdd( aItem , { "D1_BASEISS" , aNF[08]						, Nil } ) 
					aAdd( aItem , { "D1_ALIQISS" , aNF[07]						, Nil } ) 
					aAdd( aItem , { "D1_VALISS"  , aNF[09]						, Nil } )
				
					aAdd( aAutoItens, aItem )
			    	
			    	MSExecAuto( {|x,y,z| MATA140(x,y,z)} , aAutoCab , aAutoItens , 3 )
					If  lMsErroAuto		
						aAdd(aLog,{"SF1",'Nota n�o importada:'+CRLF+'"'+aNF[02]+'"'+CRLF})
					   	DisarmTransaction()
					   	MostraErro()
					Else
					   	lRet := .T.				
					EndIf
			    Else
			    	aAdd(aLog,{"SF1",'Nota ja cadastrada:'+CRLF+'"'+aNF[02]+'"'+CRLF})
	            EndIf
	        EndIf
	    EndIf
	EndIf	    
EndIf

If lRet
	cNewArq := SubStr(cArquivo,1,Len(cArquivo)-3)+"PROC"
	FRename(cArquivo,cNewArq)
EndIf

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �OpenXml     � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Abertura do arquivo XML.						            ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � OpenXml()		                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function OpenXml(cArquivo)
Local oXml

Local nTerHdl    := 0
Local nTamArq    := 0

Local xBuffer

Local cStrXml    := ''
Local cArqTmpXml := CriaTrab(,.F.)+".xml"
Local cStartPath := Alltrim(GetSrvProfString("StartPath",""))
Local cError     := ""
Local cWarning   := ""

Local aXml
                                                       
cStartPath:=cStartPath+If(Right(cStartPath,1)=="\","","\")


nTerHdl := fOpen(cArquivo,2+64)
If nTerHdl <= 0
	aAdd(aLog,{"ARQ",'O arquivo n�o pode ser encontrado no local indicado.'+CRLF+'"'+cArquivo+'"'+CRLF})
	Return(.F.)
EndIf

nTamArq := fSeek(nTerHdl,0,2)
xBuffer := Space(nTamArq)

fSeek(nTerHdl,0,0)
fRead(nTerHdl,@xBuffer,nTamArq)

cStrXml := xBuffer

fClose(nTerHdl)
        
nTerHdl := FCreate(cArqTmpXml)
fWrite(nTerHdl,cStrXml)
fClose(nTerHdl)

oXml := XmlParserFile( cStartPath+cArqTmpXml , "_" , @cError , @cWarning )

fClose(cArqTmpXml)

Return(oXml)

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �ExtraiNf    � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Extrai dados da NF do XML.						            ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � ExtraiNf()		                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/          
Static Function ExtraiNf(oXml)
Local aDados 		:= {}
Local aPrestador 	:= {}
Local aTomador 		:= {}

If Valtype(oXml)=="O" .And. !Empty(oXml:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT)

	//->> Dados do Prestador de Servico
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_CONTATO:_EMAIL:TEXT})  																			// 01 Email
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_CONTATO:_TELEFONE:TEXT})																			// 02 Telefone
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_BAIRRO:TEXT})																			// 03 Bairro
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CEP:TEXT})																				// 04 CEP
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CODIGOMUNICIPIO:TEXT})																	// 05 Codigo Municipio
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CODIGOPAIS:TEXT})																		// 06 Codigo Pais
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_COMPLEMENTO:TEXT})																		// 07 Complemento Endereco
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_ENDERECO:TEXT})																			// 08 Endereco
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_NUMERO:TEXT}) 																			// 09 Numero
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT})																				// 10 UF				
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT})																// 11 Cnpj
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_INSCRICAOMUNICIPAL:TEXT})													// 12 Insc. Municipal	
    aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT})																				// 13 Razao Social
                                  
    //->> Dados do Tomador de Servico  
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_EMAIL:TEXT}) 							// 01 Email 
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_TELEFONE:TEXT}) 							// 02 Telefone
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_BAIRRO:TEXT}) 							// 03 Bairro
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CEP:TEXT}) 								// 04 CEP
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOMUNICIPIO:TEXT}) 					// 05 Codigo Municipio
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOPAIS:TEXT}) 						// 06 Codigo Pais
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_COMPLEMENTO:TEXT}) 						// 07 Complemento
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_ENDERECO:TEXT}) 						// 08 Endereco 
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_NUMERO:TEXT}) 							// 09 Numero
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:TEXT}) 									// 10 UF
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT}) 				// 11 CNPJ
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT}) 	// 12 Insc Municipal
    aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT}) 								// 13 Razao Social
    
    //->> Dados da Nota de Servico
    If Alltrim(oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT)==Alltrim(_cCnpjKeep)
    	aAdd(aDados,"SAIDA")	// 01 Tipo da geracao da NFS
    Else
   		aAdd(aDados,"ENTRADA") 	// 01 Tipo da geracao da NFS
    EndIf
    aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT)  																				   							// 02 Numero da Nota 
    aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_IDENTIFICACAORPS:_SERIE:TEXT) 							// 03 Serie
    aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_ITEMLISTASERVICO:TEXT) 								// 04 Codigo Servi�o
    //aAdd(aDados,Stod(StrTran(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO:TEXT,"-","")) )  																				// 05 Emissao
    aAdd(aDados,CtoD(Left(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO:TEXT,10)) ) //--> Larson 08/08/13  																						// 05 Emissao
    aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORSERVICOS:TEXT)) 					// 06 Valor Total da Nota
    aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_ALIQUOTA:TEXT))		 															   						// 07 Aliquota ISS
    aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_BASECALCULO:TEXT))																   						// 08 Base Calculo
    aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_VALORISS:TEXT))																	   						// 09 Valor ISS
    aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_VALORLIQUIDONFSE:TEXT))																					// 10 Valor Liquido 
    aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_CODIGOCNAE:TEXT)										// 11 cNae
       
        
    //->> Montagem Geral do Array de Nota 
    aAdd(aDados,aPrestador) 	// Dados do Prestador 
    aAdd(aDados,aTomador)		// Dados do Tomador   

EndIf

Return aDados

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �GetProduto  � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Busca o produto por codigo servico e caso nao haja cadastra.��� 
��� 		  � e retornando true mantem posicionado na SB1.				���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � ExtraiNf()		                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/          
Static Function GetProduto(cCodigoServ,nAliqIss,cCnae)
Local lRet := .T.
Local cProduto := "SERV-"

If !Empty(cCodigoServ)
	cProduto += Alltrim(cCodigoServ)           
    SB1->(dbSetOrder(1))
    If !SB1->(dbSeek(xFilial("SB1")+cProduto))
    	Reclock("SB1",.T.)
    	SB1->B1_FILIAL 	:= xFilial("SB1")
    	SB1->B1_COD		:= cProduto
    	SB1->B1_DESC	:= "SERVICO SOB CODIGO "+Alltrim(cCodigoServ)
    	SB1->B1_TIPO	:= "PA"
    	SB1->B1_UM		:= "UN"
    	SB1->B1_LOCPAD	:= "01"
    	SB1->B1_CODISS	:= Alltrim(cCodigoServ)
    	SB1->B1_ALIQISS := nAliqIss
    	SB1->B1_CNAE	:= cCnae
    	SB1->B1_TE  	:= GetNewPar("KP_TE_NFS","001") 
    	SB1->B1_TS  	:= GetNewPar("KP_TE_NFS","501")    	
        SB1->(MsUnlock())
    EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �GetCliente  � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Busca o cliente pelo cnpj e caso nao haja cadastra.			��� 
��� 		  � e retornando true mantem posicionado na SA1.				���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � GetCliente()	                                            ��� 
���������������������������������������������������������������������������Ĵ��
��� 01 Email																���
��� 02 Telefone																���
��� 03 Bairro																���
��� 04 CEP																	���
��� 05 Codigo Municipio														���
��� 06 Codigo Pais															���
��� 07 Complemento Endereco													���
��� 08 Endereco																���
��� 09 Numero																���
��� 10 UF																	���
��� 11 Cnpj																	���
��� 12 Insc. Municipal														���
��� 13 Razao Social															���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/          
Static Function GetCliente(aCliente)
Local lRet 		:= .T.
Local cCodigo 	:= ""           

If Len(aCliente)>0
	SA1->(dbSetOrder(3)) // por cnpj
    If !SA1->(dbSeek(xFilial("SA1")+Alltrim(aCliente[11,1])))    	
    	cCodigo += GetSXENum("SA1","A1_COD")
    	ConfirmSX8()    	
    	Reclock("SA1",.T.)
    	SA1->A1_FILIAL 	:= xFilial("SA1")
    	SA1->A1_COD		:= cCodigo
    	SA1->A1_LOJA	:= "01"
    	SA1->A1_NOME	:= aCliente[13,1]
    	SA1->A1_NREDUZ	:= aCliente[13,1]
    	SA1->A1_PESSOA	:= "J"
    	SA1->A1_END		:= Alltrim(aCliente[08,1])+" - "+aCliente[09,1]+" - "+aCliente[07,1]
    	SA1->A1_TIPO	:= "R"
    	SA1->A1_EST		:= aCliente[10,1]
    	SA1->A1_COD_MUN := aCliente[05,1]
    	SA1->A1_BAIRRO	:= aCliente[03,1] 
    	SA1->A1_CEP		:= aCliente[04,1]
    	SA1->A1_TEL		:= aCliente[02,1]
    	SA1->A1_CGC		:= aCliente[11,1]    	
    	SA1->A1_INSCRM	:= aCliente[12,1]    	
    	SA1->A1_CODPAIS	:= aCliente[06,1]
    	SA1->A1_EMAIL	:= aCliente[01,1]
    	SA1->(MsUnlock())
    EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �GetFornece  � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Busca o fornecedor pelo cnpj e caso nao haja cadastra.		��� 
��� 		  � e retornando true mantem posicionado na SA2.				���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � GetFornece()	                                            ��� 
���������������������������������������������������������������������������Ĵ��
��� 01 Email																���
��� 02 Telefone																���
��� 03 Bairro																���
��� 04 CEP																	���
��� 05 Codigo Municipio														���
��� 06 Codigo Pais															���
��� 07 Complemento Endereco													���
��� 08 Endereco																���
��� 09 Numero																���
��� 10 UF																	���
��� 11 Cnpj																	���
��� 12 Insc. Municipal														���
��� 13 Razao Social															���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/          
Static Function GetFornece(aFornecedor)
Local lRet 		:= .T.
Local cCodigo 	:= ""           

If Len(aFornecedor)>0
	SA2->(dbSetOrder(3)) // por cnpj
    If !SA2->(dbSeek(xFilial("SA2")+Alltrim(aFornecedor[11,1])))    	
    	cCodigo += GetSXENum("SA2","A2_COD")    	
    	ConfirmSX8()
    	Reclock("SA2",.T.)
    	SA2->A2_FILIAL 	:= xFilial("SA2")
    	SA2->A2_COD		:= cCodigo
    	SA2->A2_LOJA	:= "01"
    	SA2->A2_NOME	:= aFornecedor[13,1]
    	SA2->A2_NREDUZ	:= aFornecedor[13,1]
    	SA2->A2_TIPO	:= "J"
    	SA2->A2_END		:= Alltrim(aFornecedor[08,1])+" - "+aFornecedor[09,1]+" - "+aFornecedor[07,1]
    	SA2->A2_EST		:= aFornecedor[10,1]
    	SA2->A2_COD_MUN := aFornecedor[05,1]
    	SA2->A2_BAIRRO	:= aFornecedor[03,1] 
    	SA2->A2_CEP		:= aFornecedor[04,1]
    	SA2->A2_TEL		:= aFornecedor[02,1]
    	SA2->A2_CGC		:= aFornecedor[11,1]    	
    	SA2->A2_INSCRM	:= aFornecedor[12,1]    	
    	SA2->A2_PAIS	:= aFornecedor[06,1]
    	SA2->A2_EMAIL	:= aFornecedor[01,1]
    	SA2->(MsUnlock())
    EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao    �GeraLogErro � Autor � Marcelo Celi Marques � Data �  /  /    ���
���������������������������������������������������������������������������Ĵ��
��� Descricao � Gera o log de erro e grava na pasta.						��� 
���������������������������������������������������������������������������Ĵ��
��� Sintaxe   � GeraLogErro()	                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso       �                                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/          
Static Function GeraLogErro()
Local cLog 		:= ""
Local nX		:= 0  
Local cArquivo  := StrTran("C:\TEMP\NFS_"+dTos(dDatabase)+Time(),":","")+".TXT"       

For nX:=1 to Len(aLog)
	cLog+=aLog[nX,02]+CRLF
Next nX

If Empty(cLog)
	cLog:="N�o houveram erros na gera��o das notas."
EndIf                          

MemoWrite(cArquivo,cLog)

Return
    