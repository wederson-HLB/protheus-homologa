#Include "Protheus.Ch"
#Include "Tbiconn.Ch"
#Include "topconn.Ch"
#Include "Shell.Ch"
#Include "Ap5Mail.ch"

Static aLog	:= {}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ KPXmlImp   ³ Autor ³ Larson Zordan        ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Rotina de Importação de XML para notas de produto e serviço.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ KPXmlImp()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ KPMG	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function KPXmlImp(cTes)
Local cPerg  		:= "KPXMLIMP1"
Local cFunction		:= "KXMLIMP"
Local cTitle		:= "Importação de XML"
Local bProcess		:= { |oSelf| ImportarNf(oSelf) }                   
Local cDescription	:= "Esta rotina irEgerar notas de entrada/saida de produtos e serviços com base na importação de XML."
Local cArqNtx 		:= CriaTrab( NIL, .F. )

Private lVldTes		:= .F.
Private lMsg		:= .T.           
Private cEspecieDoc := "SPED"

//RRP - 15/08/2014 - Para chamar a Static Function no MsNewGetDados
Default cTes := ""
If !EMPTY(cTes)
	Return VldTES(cTes,lMsg)
EndIf


Private nServ   := 0
Private nProd   := 0
Private aLogXml := {}

//->> Criacao do Indice Temporario
IndRegua( "SA5", cArqNtx, "A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF", , , "Selec.registros..." )

PutSx1(cPerg,"01","Pasta Origem dos XML Prod/Serv","","","mv_ch1","C",99,0,1,"G",""								,""	 ,"","S","mv_par01",""			,"","","",""				,"","",""		,"","","","","","","","",{"Informe a pasta de origem dos"	,"arquivos de XML de Produtos "	,"e Serviços."},{},{})
PutSx1(cPerg,"02","Buscar Produtos nas NF Entrada","","","mv_ch2","N",01,0,2,"C",""								,""	 ,"","" ,"mv_par02","Produtos" ,"","","","Prod. X Fornec."	,"","","Ambos"	,"","","","","","","","",{"Informe como serEa busca dos"	,"produtos nas NF de Entrada: "	,"- Cadastro de Produtos (SB1)","- Produto X Fornecedor (SA5)","- Ambos (SB1 e depois SA5)  "},{},{})
PutSx1(cPerg,"03","Mostra Erro?"				  ,"","","mv_ch3","N",01,0,2,"C",""								,""	 ,"","" ,"mv_par03","Sim"		,"","","",""				,"","",""		,"","","","","","","","",{"Na Integração serEexibido o "	,"erro por Nota Fiscal"	,"","",""},{},{})
PutSx1(cPerg,"04","TES?"				  		  ,"","","mv_ch4","C",03,0,0,"C","Vazio().or.Existcpo('SF4')"	,"SF4","","" ,"mv_par04",""	  		,"","","",""				,"","",""		,"","","","","","","","",{"TES utilizada na NF."			,""						,"","",""},{},{})
PutSx1(cPerg,"05","Condição Pagamento?"			  ,"","","mv_ch5","C",03,0,0,"C","Existcpo('SE4')"				,"SE4","","" ,"mv_par05",""	  		,"","","",""				,"","",""		,"","","","","","","","",{"Cond. Pag. utilizada na NF."		,""						,"","",""},{},{})
PutSx1(cPerg,"06","Natureza?"					  ,"","","mv_ch6","C",10,0,0,"C","Vazio().or.Existcpo('SED')"	,"SED","","" ,"mv_par06",""	  		,"","","",""				,"","",""		,"","","","","","","","",{"Natureza utilizada na NF."		,""			 			,"","",""},{},{}) 
PutSx1(cPerg,"07","Conta Contábil?"				  ,"","","mv_ch7","C",20,0,0,"C","Vazio().or. Ctb105Cta()"		,"CT1","","" ,"mv_par07",""	  		,"","","",""				,"","",""		,"","","","","","","","",{"Conta Contábil para incl."		,"do Cliente/Fornecedor","","",""},{},{})

tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg)

//->> Exclusao do Indice Temporario
DbSelectArea( "SA5" )
SA5->(DbSetOrder( 1 ))
fErase( cArqNtx + OrdBagExt() )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ ImportarNf ³ Autor ³ Larson Zordan        ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Rotina de acionamento das devidas rotinas de importacao.	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ ImportarNf()	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ KPMG	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImportarNf(oRegua)

Local oNFe
Local oXml
Local oDest
Local cDirXML     := Alltrim(mv_par01)
Local aArqXml     := ExtraiArq(2,@cDirXml)
Local aNFS		  := {}
Local aNF		  := {}
Local lAuto 	  := .F.
Local lExibErro   := .F.
Local lNfe        := .F.
Local nX

Private _cMeuCnpj := SM0->M0_CGC
Private aNewClie  := {}
Private aNewForn  := {}

Private cPessoa   := "" 
Private nParam01  := MV_PAR02
Private lDev      := .F.

/*
	** LDB - ( Leandro Brito )
	** Inclusao da contabilizacao On Line para as notas de saida 
*/     
Private lLancPad10	:= VerPadrao( "610" )
Private lLancPad20	:= VerPadrao( "620" )    
Private lContOnLine := .F.                       
Private nTotal      := 0
Private cLoteFat    := If( SX5->( DbSeek( xFilial() + '09FAT' ) ) , AllTrim( SX5->X5_DESCRI ) , "FAT " ) 
Private nHdlPrv     := 0
Private cArquivo   
Private lMostraLanc := .F.
Private _cFuncao    :=  "MATA460"
/**/
//RRP - 23/02/2015 - Mostrar erro no momento da integração.
If mv_par03 == 1
	lExibErro := .T.
EndIf


oRegua:SetRegua1(4)
If Len(aArqXml)>0
	oRegua:IncRegua1("Importando XML de Produtos e Serviços...")
	oRegua:SetRegua2(Len(aArqXml))
	For nX := 1 to Len(aArqXml)
		oRegua:IncRegua2("Lendo e Importando XML "+AllTrim(Str(nX))+"/"+AllTrim(Str(Len(aArqXml)))+"...")
		
		lNfe := .F.
		oXml := OpenXml(cDirXml+aArqXml[nX,01])
		//RRP - 16/11/2016 - Ajuste para não estourar erro na tela ao apertar o botão cancelar.
		If ValType(oXML)<> "O"
			Loop
		EndIf
		
		//--> Servico
		If XmlChildEx(oXML, "_COMPNFSE") <> Nil
			If oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT == SM0->M0_CGC
				ExtrNfServ(oXml,@aNFS,cDirXml+aArqXml[nX,01])
			Else
				aAdd( aLogXML , { "SERVIÇO","NFS-e não petrence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
			EndIf
		EndIf
		
		//--> Produto
		If XmlChildEx(oXML, "_NFEPROC")  <> Nil
			
			oNFe := IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)   
			oDest:=oXml:_nfeProc:_NFe:_infNFe:_DEST       
			
			If alltrim(oXml:_nfeProc:_NFe:_infNFe:_IDE:_TPNF:TEXT) =="0"  .And. Alltrim(oNFe:_EMIT:_CNPJ:TEXT) == Alltrim(_cMeuCnpj)
				lDev:=.T.
			Else
				lDev:=.F.
			EndIf 
			
			       
			//Caso o destinario seja pessoa fisica - TLM 20141017
			IF XmlChildEx(oDest, "_CNPJ") <> NIL
		   		
		   		cPessoa := "J"
		   	
		   		If Alltrim(oNFe:_EMIT:_CNPJ:TEXT)<>Alltrim(_cMeuCnpj) .And. Alltrim(oNFe:_DEST:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
			   		lNfe := .T.
		   		EndIf              
		   		
		   	ElseIf XmlChildEx(oDest, "_CPF") <> NIL
		   	 		   		
		   		cPessoa := "F"
		   	
		   	EndIf	         
		   	                                 
			If Alltrim(oNFe:_EMIT:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
				lNfe := .T.
			EndIf
			
			If lNfe
				
				if XmlChildEx(oXml:_NFEPROC, "_PROTNFE") <> NIL
					ExtrNfProd(oXml,@aNF ,cDirXml+aArqXml[nX,01])
				endif
			Else
				aAdd( aLogXML , { "PRODUTO","NF-e não petrence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
			EndIf
			
		EndIf
		
	Next nX
EndIf

If Len(aNFS)+Len(aNF) > 0
	oRegua:IncRegua1("Montando os Dados Para Classificação das NF's...")
	ClassNf(@aNF,@aNFS,@oRegua)
	If Len(aNFS)+Len(aNF) == 0
		Return
	EndIf
Else
	MsgAlert("Não HEDocumentos XML para Importar !")
	Return
EndIf

If Len(aNFS)+Len(aNF) > 0 .And. MsgYesNo("Confirma a geração das notas fiscais importadas pela leitura dos XMLs ?")
	oRegua:SetRegua1(Len(aNFS)+Len(aNF))
	
	/*
		** Leandro Brito 
		** Caso tenha nota de saida, pergunta se deve contabilizar On Line
	*/                                                                    
	If lLancPad10 .Or. lLancPad20
		If ( Ascan( aNFS , { | x | AllTrim( x[ 1 ] ) == "SAIDA" } ) > 0 ) .Or. ;
			( Ascan( aNF , { | x | AllTrim( x[ 1 ] ) == "SAIDA" } ) > 0 ) 	
			
			If !SelTpLanc()
				MsgStop( 'Operacao cancelada pelo usuario.' )
				Return
			EndIf	
			
		EndIf
	EndIf 
	
/*
	If lContOnLine
		nHdlPrv := HeadProva( cLoteFat , _cFuncao , cUserName , @cArquivo )	
	EndIf	
*/
	//->> Notas de Serviço
	If Len(aNFS)>0
		ProcXmlServ(lAuto,aNFS,@oRegua,lExibErro)
	EndIf
	
	//->> Notas de Produto
	If Len(aNF)>0
		ProcXmlProd(lAuto,aNF,@oRegua,lExibErro)
	EndIf
	
//	If lContOnLine
//		RodaProva( nHdlPrv , nTotal )
//		cA100Incl( cArquivo , nHdlPrv , 3, cLoteFat , lMostraLanc , .F. /*lAglutina*/ )		
//	Endif
	
	If Len(aNFS)+Len(aNF) <> nServ+nProd
		Aviso( "Atenção" , "Foram submetidas a importação "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de serviços, contudo foram importadas "+Alltrim(Str(nProd))+" de produtos e "+Alltrim(Str(nServ))+" de serviços."+CRLF+"Vide Log de Eventos.", { 'Ok' } , 2 , "Importações de XML" )
	Else
		Aviso( "Atenção" , "Foram submetidas a importação "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de serviços, com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "Importações de XML" )
	EndIf
	
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ KPImpXML   ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Adquire os arquivos.							            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ 1 = Um Unico, 2 - Varios                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExtraiArq(nTipo,cDirOrigXml)
Local aArquivos := {}
Local aArqTemp	:= {}
Local cArquivo	:= ""
Local cPasta	:= ""
Local nX		:= 0
Local cDirTmp 	:= ""

If nTipo == 1 // Selecionando um unico arquivo
	cArquivo := UPPER(cGetFile("Arquivo XML (*.xml)|*.xml" , "Selecione o arquivo...",,cDirOrigXml,,GETF_LOCALHARD+GETF_NETWORKDRIVE))
	If !Empty(cArquivo)
		cDirOrigXml := Left(cArquivo,Rat('\',cArquivo))
		cArquivo    := SubStr(cArquivo,Rat('\',cArquivo)+1)
		aAdd(aArquivos,{cArquivo})
	EndIf
ElseIf nTipo == 2 // Automatico selecionando a pasta
	cDirTmp := Alltrim(cDirOrigXml)
	If Right(cDirTmp,1)=="\"
		cDirTmp:=SubStr(cDirTmp,1,Len(cDirTmp)-1)
	EndIf
	If !File(cDirTmp)
		cPasta := cGetFile(cDirTmp,"Selecione a pasta para seleção automática dos XMLs...",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	Else
		cPasta := cDirOrigXml
	EndIf
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ProcXmlServ ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Processamento da Importacao.					            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ KpImpXml()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcXmlServ(lAuto,aNF,oRegua,lExibErro)
Local nX	:= 0
Local lOK	:= .T.
Local cNewArq := ""

Default lAuto := .F.
Default oRegua:= ""

If !lAuto .And. Valtype(oRegua)=="O"
	oRegua:SetRegua2(Len(aNF))
EndIf
For nX:=1 to Len(aNF)
	If lContOnLine
		nHdlPrv := HeadProva( cLoteFat , _cFuncao , cUserName , @cArquivo )	
		nTotal := 0
	EndIf
	If !lAuto
		If Valtype(oRegua)=="O"
			If oRegua:lEnd
				lEnd := .T.
				Exit
			EndIf
			oRegua:IncRegua1("Importação de XML...")
			oRegua:IncRegua2("Gerando notas de Serviço...")
			lOK:=GeraNFS(aNF[nX],lAuto,lExibErro,oRegua)
		Else
			Processa( { || lOK:=GeraNFS(aNF[nX],lAuto,lExibErro,oRegua) } , 'Aguarde...' , 'Gerando Notas de Serviço' )
		EndIf
	Else
		lOK:=GeraNFS(aNF[nX],lAuto,.F.,oRegua)
	EndIf 
	
	If lOk
		If lContOnLine
			RodaProva( nHdlPrv , nTotal )
			cA100Incl( cArquivo , nHdlPrv , 3, cLoteFat , lMostraLanc , .F. /*lAglutina*/ )		
		Endif
	Endif				    
	
	If lOK
		cNewArq := SubStr(aNF[nX,24],1,Len(aNF[nX,24])-3)+"PROC"
		FRename(aNF[nX,24],cNewArq)
	EndIf
Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³GeraNFS     ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Geracao da NFS.									            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ GeraNFS()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraNFS(aNF,lAuto,lExibErro,oRegua)
Local aAutoCab  := {}
Local aItem		:= {}
Local aAutoItens:= {}
Local lRet		:= .F.
Local cNewArq	:= ""

Private lMsErroAuto := .F.

If Len(aNF)>0 .And. aNF[1]=="SAIDA"
	If	Empty(aNF[20]) .Or. !SF4->(dbSeek(xFilial("SF4")+aNF[20])) .Or. SF4->F4_MSBLQL=="1"
		If lExibErro
			MsgStop("Tipo de Entrada/Saida não informada, não localizada ou bloqueada.  Operação de importação descontinuada.")
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Tipo de Entrada/Saida não informada, não localizada ou bloqueada.")
		EndIf
		Return lRet
	EndIf
EndIf

If	Empty(aNF[21]) .Or. !SE4->(dbSeek(xFilial("SE4")+aNF[21]))
	If lExibErro
		MsgStop("Condição de Pagamento não informada ou não localizada.  Operação de importação descontinuada.")
	EndIf
	If Valtype(oRegua)=="O"
		oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Condição de Pagamento não informada ou não localizada.")
	EndIf
	Return lRet
EndIf
If	aNF[1]=="SAIDA" .And. (Empty(aNF[22]) .Or. !SED->(dbSeek(xFilial("SED")+aNF[22])))
	If lExibErro
		MsgStop("Natureza não informada ou não localizada.  Operação de importação descontinuada.")
	EndIf
	If Valtype(oRegua)=="O"
		oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Natureza não informada ou não localizada.")
	EndIf
	Return lRet
EndIf

If Len(aNF)>0
	If _cMeuCnpj <> aNF[19]
		If lExibErro
			MsgStop("Documento: "+aNF[02]+" somente pode ser gerado na filial do cnpj "+aNF[19]+".")
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"somente pode ser gerado na filial do cnpj "+aNF[19]+".")
		EndIf
	ElseIf Empty(aNF[04])
		If lExibErro
			MsgStop('Produto sem Código de Serviço para o Documento:'+CRLF+'"'+aNF[02]+'"')
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Produto sem Código de Serviço")
		EndIf
	Else
		If GetProduto(aNF[04],aNF[07],aNF[11])
			If aNF[1]=="SAIDA"
				If Val(aNF[20])<500
					If lExibErro
						MsgStop("Documento: "+aNF[02]+" não pode ser gerado para esta TES."+aNF[19]+".")
					EndIf
					If Valtype(oRegua)=="O"
						oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"TES incorreta.")
					EndIf
				Else
					If GetCliente(aNF[13])
						SF2->(dbSetOrder(1))
						IF !SF2->(dbSeek(xFilial("SF2")+PadR(aNF[2],Tamsx3("F2_DOC")[1])+PadR(aNF[3],Tamsx3("F2_SERIE")[1])+SA1->(A1_COD+A1_LOJA)+"N"))
							aAdd( aAutoCab , { "F2_FILIAL"  , xFilial('SF2')									, Nil } )
							aAdd( aAutoCab , { "F2_TIPO"    , "N"												, Nil } )
							aAdd( aAutoCab , { "F2_DOC"     , StrZero(Val(aNF[02]),9)						   	, Nil } )
							aAdd( aAutoCab , { "F2_SERIE"   , aNF[03]											, Nil } )
							aAdd( aAutoCab , { "F2_CLIENTE" , SA1->A1_COD										, Nil } )
							aAdd( aAutoCab , { "F2_LOJA"    , SA1->A1_LOJA										, Nil } )
							aAdd( aAutoCab , { "F2_EMISSAO" , aNF[05]											, Nil } )
							aAdd( aAutoCab , { "F2_ESPECIE" , "NFS"												, Nil } )
							
							aItem := {}
							cCFOP := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TS,"F4_CF")
							
							aAdd( aItem , { "D2_FILIAL"  , xFilial('SD2')										, Nil } )
							aAdd( aItem , { "D2_DOC"     , StrZero(Val(aNF[02]),9)								, Nil } )
							aAdd( aItem , { "D2_SERIE"   , aNF[03]												, Nil } )
							aAdd( aItem , { "D2_CLIENTE" , SA1->A1_COD											, Nil } )
							aAdd( aItem , { "D2_LOJA"    , SA1->A1_LOJA											, Nil } )
							aAdd( aItem , { "D2_COD"     , SB1->B1_COD											, Nil } )
							aAdd( aItem , { "D2_UM"      , SB1->B1_UM											, Nil } )
							aAdd( aItem , { "D2_QUANT"   , 1													, Nil } )
							aAdd( aItem , { "D2_VUNIT"   , aNF[06]												, Nil } )
							aAdd( aItem , { "D2_TOTAL"   , aNF[10]												, Nil } )
							aAdd( aItem , { "D2_TES"     , aNF[20]												, Nil } )
							aAdd( aItem , { "D2_CF"      , cCFOP												, Nil } )
							aAdd( aItem , { "D2_LOCAL"   , SB1->B1_LOCPAD										, Nil } )
							aAdd( aItem , { "D2_ITEM"    , "01"													, Nil } )
							aAdd( aItem , { "D2_BASEISS" , aNF[08]												, Nil } )
							aAdd( aItem , { "D2_ALIQISS" , aNF[07]												, Nil } )
							aAdd( aItem , { "D2_VALISS"  , aNF[09]												, Nil } )
							
							//->> Impostos -> ISS
							aAdd( aItem , { "D2_BASEISS" , aNF[08]												, Nil } )
							aAdd( aItem , { "D2_ALIQISS" , aNF[07]												, Nil } )
							aAdd( aItem , { "D2_VALISS"  , aNF[09]												, Nil } )
							//->> Impostos -> IRR
							aAdd( aItem , { "D2_BASEIRR" , aNF[08]			 									, Nil } )
							aAdd( aItem , { "D2_ALIQIRR" , Round(100*aNF[18]/aNF[08],Tamsx3("D2_ALIQIRR")[2])	, Nil } )
							aAdd( aItem , { "D2_VALIRR"  , aNF[18]												, Nil } )
							//->> Impostos -> INSS
							aAdd( aItem , { "D2_BASEINS" , aNF[08]												, Nil } )
							aAdd( aItem , { "D2_ALIQINS" , Round(100*aNF[17]/aNF[08],Tamsx3("D2_ALIQINS")[2])	, Nil } )
							aAdd( aItem , { "D2_VALINS"  , aNF[17]												, Nil } )
							
							aAdd( aAutoItens, aItem )
							
							MsExecAuto( {|x,y,z| Mata920(x,y,z)}, aAutoCab, aAutoItens, 3)
							If  lMsErroAuto
								DisarmTransaction()
								If lExibErro
									MostraErro()
								EndIf
							Else
								lRet := .T.

								lRetorno := .T.
								GeraTitulo(cTesS,aNF[09],aNF[13],StrZero(Val(aNF[02]),9),aNF[03],aNF[14],SA1->(A1_COD+A1_LOJA))
								DbselectArea("SF2")
								DBSetOrder(1)
								
								//--> Grava a Chave da NFe
								If dbSeek(xFilial('SF2')+cNumero+cSerie+SA1->(A1_COD+A1_LOJA))
									RecLock("SF2",.F.)
									F2_CHVNFE := aNF[10]
									F2_COND   := aNF[14]
									F2_DUPL   := StrZero(Val(aNF[02]),9)
									MSUnlock()
									/*
										**	LDB - 13/04/2015 - Contabilizacao On Line - Cabeçalho nota de Saida
									*/                                               
									If lContOnLine .And. lLancPad20                                            
									   nTotal += DetProva( nHdlPrv , "620" , _cFuncao , cLoteFat )
									EndIf
								EndIf
								
								//-> Grava Custo Medio do Produto
								SD2->(dbSetOrder(3))
								If SD2->(dbSeek(xFilial("SD2")+cNumero+cSerie))
									While !SD2->(Eof()) .And. xFilial("SD2")+cNumero+cSerie == SD2->(D2_FILIAL+D2_DOC+D2_SERIE)
										RecLock("SD2",.F.)
										SD2->D2_ORIGLAN := "  "
										SD2->D2_CUSTO1  := Posicione("SB2",1,xFilial("SB2")+SD2->D2_COD,"B2_CM1") * SD2->D2_QUANT
										SD2->(MsUnLock())
										/*
										**	LDB - 13/04/2015 - Contabilizacao On Line - Itens da nota de Saida
										*/                                               
										If lContOnLine .And. lLancPad10                                            
									   		nTotal += DetProva( nHdlPrv , "610" , _cFuncao , cLoteFat )
										EndIf
										SD2->(dbSkip())
									EndDo
								EndIf
						
							EndIf
						Else
							If lExibErro
								MsgStop('Nota ja cadastrada:'+CRLF+'"'+aNF[02]+'"')
							EndIf
							If Valtype(oRegua)=="O"
								oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" ja cadastrada.")
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf aNF[1]=="ENTRADA"
				If GetFornece(aNF[12])
					cTesE 	:= IIf(Empty(aNF[20]),SB1->B1_TE,aNF[20])
					cSerie 	:= If(!Empty(aNF[03]),aNF[03],"1")
					SF1->(dbSetOrder(1))
					IF !SF1->(dbSeek(xFilial("SF1")+PadR(aNF[2],Tamsx3("F1_DOC")[1])+PadR(cSerie,Tamsx3("F1_SERIE")[1])+SA2->(A2_COD+A2_LOJA)+"N"))
						aAdd( aAutoCab , { "F1_FILIAL"  , xFilial('SF1')								, Nil } )
						aAdd( aAutoCab , { "F1_TIPO"    , "N"											, Nil } )
						aAdd( aAutoCab , { "F1_DOC"     , aNF[02]									   	, Nil } )
						aAdd( aAutoCab , { "F1_SERIE"   , cSerie										, Nil } )
						aAdd( aAutoCab , { "F1_FORNECE" , SA2->A2_COD									, Nil } )
						aAdd( aAutoCab , { "F1_LOJA"    , SA2->A2_LOJA									, Nil } )
						aAdd( aAutoCab , { "F1_EMISSAO" , aNF[05]										, Nil } )
						aAdd( aAutoCab , { "F1_DTDIGIT" , aNF[05]										, Nil } )
						aAdd( aAutoCab , { "F1_ESPECIE" , "NFS"											, Nil } )
						aAdd( aAutoCab , { "F1_EST" 	, SA2->A2_EST									, Nil } )
						aAdd( aAutoCab , { "F1_COND" 	, aNF[21]										, Nil } )
						aAdd( aAutoCab , { "F1_FORMUL"  , "N"											, Nil } )
						aAdd( aAutoCab , { "E2_NATUREZ" , aNF[22]										, Nil } )
						
						aItem := {}
						cCFOP := Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")
						
						aAdd( aItem , { "D1_FILIAL"  , xFilial('SD1')										, Nil } )
						aAdd( aItem , { "D1_DOC"     , aNF[02]												, Nil } )
						aAdd( aItem , { "D1_SERIE"   , cSerie												, Nil } )
						aAdd( aItem , { "D1_FORNECE" , SA2->A2_COD											, Nil } )
						aAdd( aItem , { "D1_LOJA"    , SA2->A2_LOJA											, Nil } )
						aAdd( aItem , { "D1_COD"     , SB1->B1_COD											, Nil } )
						aAdd( aItem , { "D1_UM"      , SB1->B1_UM											, Nil } )
						aAdd( aItem , { "D1_QUANT"   , 1													, Nil } )
						aAdd( aItem , { "D1_VUNIT"   , aNF[06]												, Nil } )
						aAdd( aItem , { "D1_TOTAL"   , aNF[06]												, Nil } )
						aAdd( aItem , { "D1_TES"    , cTesE													, Nil } )
						aAdd( aItem , { "D1_CF"      , cCFOP												, Nil } )
						aAdd( aItem , { "D1_LOCAL"   , SB1->B1_LOCPAD										, Nil } )
						aAdd( aItem , { "D1_ITEM"    , "01"													, Nil } )
						aAdd( aItem , { "D1_FORMUL"  , "N"													, Nil } )
						aAdd( aItem , { "D1_TIPO"    , "N"													, Nil } )
						
						//->> Impostos -> ISS
						aAdd( aItem , { "D1_BASEISS" , aNF[08]												, Nil } )
						aAdd( aItem , { "D1_ALIQISS" , aNF[07]												, Nil } )
						aAdd( aItem , { "D1_VALISS"  , aNF[09]												, Nil } )
						//->> Impostos -> IRR
						aAdd( aItem , { "D1_BASEIRR" , aNF[08]			 									, Nil } )
						aAdd( aItem , { "D1_ALIQIRR" , Round(100*aNF[18]/aNF[08],Tamsx3("D1_ALIQIRR")[2])	, Nil } )
						aAdd( aItem , { "D1_VALIRR"  , aNF[18]												, Nil } )
						//->> Impostos -> INSS
						aAdd( aItem , { "D1_BASEINS" , aNF[08]												, Nil } )
						aAdd( aItem , { "D1_ALIQINS" , Round(100*aNF[17]/aNF[08],Tamsx3("D1_ALIQINS")[2])	, Nil } )
						aAdd( aItem , { "D1_VALINS"  , aNF[17]												, Nil } )
						
						aAdd( aAutoItens, aItem )
						
						If !Empty(cTesE) .And. SF4->(dbSeek(xFilial("SF4")+cTesE))
							//-->> Processa a rotina automatica MATA103
							MsExecAuto( { |x,y,z,a| Mata103(x,y,z,a) }, aAutoCab, aAutoItens, 3 )
						Else
							//-->> Processa a rotina automatica MATA140
							MSExecAuto( { |x,y,z  | Mata140(x,y,z)} , aAutoCab , aAutoItens , 3 )
						Endif
						
						If  lMsErroAuto
							DisarmTransaction()
							If lExibErro
								MostraErro()
							EndIf
						Else                            
							RecLock("SF1",.F.)
							SF1->F1_FORMUL := If(SA2->A2_EST=="EX","S","N")
							SF1->(MsUnLock())
							nServ++
							lRet := .T.
						EndIf
					Else
						If lExibErro
							MsgStop('PrEnota ja cadastrada:'+CRLF+'"'+aNF[02]+'"')
						EndIf
						If Valtype(oRegua)=="O"
							oRegua:SaveLog("PrEnota de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" ja cadastrada.")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³OpenXml     ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Abertura do arquivo XML.						            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ OpenXml()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	MsgStop('O arquivo não pode ser encontrado no local indicado.'+CRLF+'"'+cArquivo+'"'+CRLF)
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ExtrNfServ  ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Extrai dados da NF do XML de serviços.			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ ExtrNfServ()	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExtrNfServ(oXml,aNFS,cArquivo)
Local aPrestador 	:= {}
Local aTomador 		:= {}
Local aDados		:= {}

If Valtype(oXml)=="O" .And. !Empty(oXml:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT)
	
	//->> Dados do Prestador de Servico
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_CONTATO:_EMAIL:TEXT})  																					// 01 Email
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_CONTATO:_TELEFONE:TEXT}) 																				// 02 Telefone
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_BAIRRO:TEXT})																					// 03 Bairro
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CEP:TEXT})																						// 04 CEP
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CODIGOMUNICIPIO:TEXT})																			// 05 Codigo Municipio
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CODIGOPAIS:TEXT})																				// 06 Codigo Pais
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_COMPLEMENTO:TEXT})																				// 07 Complemento Endereco
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_ENDERECO:TEXT})																				// 08 Endereco
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_NUMERO:TEXT}) 																					// 09 Numero
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT})																						// 10 UF
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT})																		// 11 Cnpj
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_INSCRICAOMUNICIPAL:TEXT})														// 12 Insc. Municipal
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT})																						// 13 Razao Social
	
	//->> Dados do Tomador de Servico
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_EMAIL:TEXT}) 									// 01 Email
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_TELEFONE:TEXT}) 								// 02 Telefone
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_BAIRRO:TEXT}) 								// 03 Bairro
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CEP:TEXT}) 									// 04 CEP
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOMUNICIPIO:TEXT}) 						// 05 Codigo Municipio
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOPAIS:TEXT}) 							// 06 Codigo Pais
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_COMPLEMENTO:TEXT}) 							// 07 Complemento
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_ENDERECO:TEXT}) 								// 08 Endereco
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_NUMERO:TEXT}) 								// 09 Numero
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:TEXT}) 											// 10 UF
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT}) 						// 11 CNPJ
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT}) 		// 12 Insc Municipal
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT}) 										// 13 Razao Social
	
	//->> Dados da Nota de Servico
	If Alltrim(oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
		/*01*/ aAdd(aDados,"SAIDA")	// 01 Tipo da geracao da NFS
	Else
		/*01*/ aAdd(aDados,"ENTRADA") 	// 01 Tipo da geracao da NFS
	EndIf
	/*02*/ aAdd(aDados, StrZero(Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT), Len(SF1->F1_DOC) ) ) 																		// 02 Numero da Nota
	/*03*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_IDENTIFICACAORPS:_SERIE:TEXT) 							// 03 Serie
	/*04*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_ITEMLISTASERVICO:TEXT) 								// 04 Codigo Serviço
	/*05*/ aAdd(aDados,CtoD(Left(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO:TEXT,10)) )					 																	// 05 Emissao
	/*06*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORSERVICOS:TEXT)) 					// 06 Valor Total da Nota
	/*07*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_ALIQUOTA:TEXT))		 															   						// 07 Aliquota ISS
	/*08*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_BASECALCULO:TEXT))																   						// 08 Base Calculo
	/*09*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_VALORISS:TEXT))																	   						// 09 Valor ISS
	/*10*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_VALORLIQUIDONFSE:TEXT))																					// 10 Valor Liquido
	/*11*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_CODIGOCNAE:TEXT)										// 11 cNae
	
	//->> Montagem Geral do Array de Nota
	/*12*/ aAdd(aDados,aPrestador) 		// Dados do Prestador
	/*13*/ aAdd(aDados,aTomador)		// Dados do Tomador
	
	/*14*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORPIS:TEXT))							// 14 Valor do PIS
	/*15*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCOFINS:TEXT))						// 15 Valor do Cofins
	/*16*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCSLL:TEXT))							// 16 Valor do CSLL
	/*17*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORINSS:TEXT))							// 17 Valor do INSS
	/*18*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORIR:TEXT))							// 18 Valor do IR
	
	/*19*/ aAdd(aDados,If(aDados[1]=="ENTRADA",	oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT,;
	oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_PRESTADOR:_CNPJ:TEXT)) 				//19 Cnpj da Filial pertencente a nota na Keeptrue
	
	/*20*/ aAdd(aDados,Criavar("D1_TES"))							// 20 TES
	/*21*/ aAdd(aDados,Criavar("F1_COND"))							// 21 Cond. Pgto
	/*22*/ aAdd(aDados,Criavar("E2_NATUREZ"))						// 22 Natureza
	
	
	/*23*/
	If Alltrim(oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
		aAdd(aDados,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT})
	Else
		aAdd(aDados,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT})
	EndIf
	/*Nota pertence a*/
	
	/*24*/ aAdd(aDados,cArquivo)									// 24 Arquivo
	
	aAdd(aNFS,aDados)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³GetProduto  ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Busca o produto por codigo servico e caso nao haja cadastra.³±±
±±³ 		  ³ e retornando true mantem posicionado na SB1.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ ExtraiNf()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
		SB1->B1_TS  	:= GetNewPar("KP_TS_NFS","501")
		SB1->(MsUnlock())
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³GetCliente  ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Busca o cliente pelo cnpj e caso nao haja cadastra.			³±±
±±³ 		  ³ e retornando true mantem posicionado na SA1.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ GetCliente()	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 01 Email																³±±
±±³ 02 Telefone																³±±
±±³ 03 Bairro																³±±
±±³ 04 CEP																	³±±
±±³ 05 Codigo Municipio														³±±
±±³ 06 Codigo Pais															³±±
±±³ 07 Complemento Endereco													³±±
±±³ 08 Endereco																³±±
±±³ 09 Numero																³±±
±±³ 10 UF																	³±±
±±³ 11 Cnpj																	³±±
±±³ 12 Insc. Municipal														³±±
±±³ 13 Razao Social															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetCliente(aCliente)
Local lRet 		:= .T.
Local cCodigo 	:= ""
Local cPess		:= ""
Local cMunic	:= ""

//RRP - 17/03/2015 - Ajuste para integração com cliente pessoa fisica.
If Len(Alltrim(aCliente[1,11]))<=11
	cPess:= "F"
Else
	cPess:= "J"
EndIf

//RRP - 19/03/2015 - Buscando nome do Municipio
CC2->(DbSetOrder(3)) //CC2_FILIAL+CC2_CODMUN
IF CC2->(DbSeek(xFilial("CC2")+SubStr(aCliente[1,05],3)))
	cMunic := Alltrim(CC2->CC2_MUN)
EndIf

//RRP - 29/09/2014 - Ajuste no array aCliente, pois estava passando a posição errada.
If Len(aCliente)>0
	SA1->(dbSetOrder(3)) // por cnpj
	If !SA1->(dbSeek(xFilial("SA1")+Alltrim(aCliente[1,11])))
		cCodigo += GetSXENum("SA1","A1_COD")
		ConfirmSX8()
		Reclock("SA1",.T.)
		SA1->A1_FILIAL 	:= xFilial("SA1")
		SA1->A1_COD		:= cCodigo
		SA1->A1_LOJA	:= "01"
		SA1->A1_NOME	:= aCliente[1,13]
		SA1->A1_NREDUZ	:= aCliente[1,13]
		SA1->A1_PESSOA	:= cPess
		SA1->A1_END		:= Alltrim(aCliente[1,08])+" - "+aCliente[1,09]+" - "+aCliente[1,07]
		SA1->A1_TIPO	:= IIF(cPess == "F","F","R")
		SA1->A1_EST		:= aCliente[1,10]
		SA1->A1_COD_MUN := SubStr(aCliente[1,05],3)
		SA1->A1_MUN		:= cMunic
		SA1->A1_BAIRRO	:= aCliente[1,03]
		SA1->A1_CEP		:= aCliente[1,04]
		SA1->A1_TEL		:= aCliente[1,02]
		SA1->A1_CGC		:= aCliente[1,11]
		SA1->A1_INSCRM	:= aCliente[1,12]
		SA1->A1_CODPAIS	:= StrZero(Val(aCliente[1,06]),5)// Adicionar 0 a esquerda caso precise, código do pais possui 5 caracteres.
		SA1->A1_EMAIL	:= aCliente[1,01] 
		SA1->A1_CONTA	:= IIF(Len(aCliente[1])>=14,aCliente[1,14],"")
		SA1->A1_NATUREZ	:= IIF(Len(aCliente[1])>=15,aCliente[1,15],"")
		SA1->(MsUnlock())
	Else
		Reclock("SA1",.F.)
		SA1->A1_END		:= Alltrim(aCliente[1,08])+" - "+aCliente[1,09]+" - "+aCliente[1,07]
		SA1->A1_EST		:= aCliente[1,10]
		SA1->A1_COD_MUN := aCliente[1,05]
		SA1->A1_BAIRRO	:= aCliente[1,03]
		SA1->A1_CEP		:= aCliente[1,04]
		SA1->A1_TEL		:= aCliente[1,02]
		SA1->A1_EMAIL	:= aCliente[1,01]
		SA1->(MsUnlock())
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³GetFornece  ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Busca o fornecedor pelo cnpj e caso nao haja cadastra.		³±±
±±³ 		  ³ e retornando true mantem posicionado na SA2.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ GetFornece()	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 01 Email																³±±
±±³ 02 Telefone																³±±
±±³ 03 Bairro																³±±
±±³ 04 CEP																	³±±
±±³ 05 Codigo Municipio														³±±
±±³ 06 Codigo Pais															³±±
±±³ 07 Complemento Endereco													³±±
±±³ 08 Endereco																³±±
±±³ 09 Numero																³±±
±±³ 10 UF																	³±±
±±³ 11 Cnpj																	³±±
±±³ 12 Insc. Municipal														³±±
±±³ 13 Razao Social															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetFornece(aFornecedor)
Local lRet 		:= .T.
Local cCodigo 	:= ""
//RRP - 29/09/2014 - Ajuste no array aFornecedor, pois estava passando a posição errada.
If Len(aFornecedor)>0
	SA2->(dbSetOrder(3)) // por cnpj
	If !SA2->(dbSeek(xFilial("SA2")+Alltrim(aFornecedor[1,11])))
		cCodigo += GetSXENum("SA2","A2_COD")
		ConfirmSX8()
		Reclock("SA2",.T.)
		SA2->A2_FILIAL 	:= xFilial("SA2")
		SA2->A2_COD		:= cCodigo
		SA2->A2_LOJA	:= "01"
		SA2->A2_NOME	:= aFornecedor[1,13]
		SA2->A2_NREDUZ	:= aFornecedor[1,13]
		SA2->A2_TIPO	:= "J"
		SA2->A2_END		:= Alltrim(aFornecedor[1,08])+" - "+aFornecedor[1,09]+" - "+aFornecedor[1,07]
		SA2->A2_EST		:= aFornecedor[1,10]
		SA2->A2_COD_MUN := SubStr(aFornecedor[1,05],3)
		SA2->A2_BAIRRO	:= aFornecedor[1,03]
		SA2->A2_CEP		:= aFornecedor[1,04]
		SA2->A2_TEL		:= aFornecedor[1,02]
		SA2->A2_CGC		:= aFornecedor[1,11]
		SA2->A2_INSCRM	:= aFornecedor[1,12]
		SA2->A2_PAIS	:= SubStr(aFornecedor[1,06],1,3)
		SA2->A2_EMAIL	:= aFornecedor[1,01]
		SA2->A2_CONTA	:= ""
		SA2->A2_CODPAIS	:= StrZero(Val(aFornecedor[1,06]),5)// Adicionar 0 a esquerda caso precise, código do pais possui 5 caracteres.
		SA2->(MsUnlock())
	Else
		Reclock("SA2",.F.)
		SA2->A2_END		:= Alltrim(aFornecedor[1,08])+" - "+aFornecedor[1,09]+" - "+aFornecedor[1,07]
		SA2->A2_EST		:= aFornecedor[1,10]
		SA2->A2_COD_MUN := aFornecedor[1,05]
		SA2->A2_BAIRRO	:= aFornecedor[1,03]
		SA2->A2_CEP		:= aFornecedor[1,04]
		SA2->A2_TEL		:= aFornecedor[1,02]
		SA2->A2_EMAIL	:= aFornecedor[1,01]
		SA2->(MsUnlock())
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ComplemNF   ºAutor  ³Larson Zordan       º Data ³ 11/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Solicita a TES, a Cond Pgto e Natureza de maneira sinteticaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Keeptrue                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ComplemNF(aNF,nTipo)
Local aNFOrig 	:= aNF
Local nX		:= 1
Local aCols		:= {}
Local aHeader	:= {}
Local aNFNorm	:= {}
Local oDlg
Local oGets
Local nOpcA		:= 0
Local cBox1		:= ""

//->> nTipo == 1 = Normal, nTipo == 2 = Keeptrue
Default nTipo := 1 //->> Normal

aNF := {}

If nTipo==1
	//->> Normal
	cBox1 := "N=Normal;D=Devolucao;B=Beneficiamento;I=Compl. ICMS;P=Compl. IPI;C=Compl. Preço/Frete"
	
	aAdd(aHeader,{ "Tipo"					,"TPNOTA"	,"@!"							,10						,0								,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
	aAdd(aHeader,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
	aAdd(aHeader,{ "Série"					,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
	aAdd(aHeader,{ "Cliente/Fornec"			,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
	aAdd(aHeader,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND. U_KPXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",		,,,"A"} )
	aAdd(aHeader,{ "Cond.Pgto"				,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"				/*VALIDACAO*/,""	,"C","SE4"	,"R",		,,,"A"} )
	aAdd(aHeader,{ "Natureza"				,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')"	/*VALIDACAO*/,""	,"C","SED"	,"R",		,,,"A"} )
	aAdd(aHeader,{ "Fornec. p/ Import."		,"FORNECIMP",PesqPict("SA2","A2_COD")		,Tamsx3("A2_COD")		[1]	,Tamsx3("A2_COD")		[2]	,"Vazio().or.Existcpo('SA2')"	/*VALIDACAO*/,""	,"C","SA2"	,"R",		,,,"A"} )
	aAdd(aHeader,{ "Cliente p/ Export."		,"CLIENTIMP",PesqPict("SA1","A1_COD")		,Tamsx3("A1_COD")		[1]	,Tamsx3("A1_COD")		[2]	,"Vazio().or.Existcpo('SA1')"	/*VALIDACAO*/,""	,"C","SA1"	,"R",		,,,"A"} )
	aAdd(aHeader,{ "Tipo Nota"				,"TIPO"		,"@!"							,1							,0							,"Pertence('NDIPC')"			/*VALIDACAO*/,""	,"C",""		,"R",cBox1	,,,"A"} )
	aAdd(aHeader,{ "Vr. Despesas"			,"VLDESP"	,PesqPict("SD1","D1_TOTAL")		,Tamsx3("D1_TOTAL")		[1]	,Tamsx3("D1_TOTAL")		[2]	,""								/*VALIDACAO*/,""	,"N",""		,"R",		,,,"A"} )
	aAdd(aHeader,{ "Nota Origem"			,"NFORIG"	,PesqPict("SD1","D1_NFORI")		,Tamsx3("D1_NFORI")		[1]	,Tamsx3("D1_NFORI")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"A"} )
	aAdd(aHeader,{ "Serie Origem"			,"SERIORI"	,PesqPict("SD1","D1_SERIORI")	,Tamsx3("D1_SERIORI")	[1]	,Tamsx3("D1_SERIORI")	[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"A"} )
	aAdd(aHeader,{ "DIRF - Cód.Retenção"	,"CODRET"	,PesqPict("SE2","E2_CODRET")	,Tamsx3("E2_CODRET")	[1]	,Tamsx3("E2_CODRET")	[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"A"} )
	aAdd(aHeader,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
	
	For nX:= 1 To Len(aNFOrig)
		aAdd(aCols,{aNFOrig[nX,01],aNFOrig[nX,02],aNFOrig[nX,03],aNFOrig[nX,04],aNFOrig[nX,12],aNFOrig[nX,13],aNFOrig[nX,14],aNFOrig[nX,15],aNFOrig[nX,16],aNFOrig[nX,17],aNFOrig[nX,18],aNFOrig[nX,19],aNFOrig[nX,20],aNFOrig[nX,21],aNFOrig[nX,22],.F.})
	Next nX
	
	DEFINE MSDIALOG oDlg TITLE "Classificação das notas de Produtos" FROM 0,0 To 400,800 PIXEL
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	
	oFWLayer:addLine("L1",100,.F.)
	oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
	oFWLayer:AddWindow("C1"		,"oPanel","Classificação das Notas"	,100,.F.,.T.,,"L1",{ || })
	oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")
	
	oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL
	
	@ 06,05	Say "Classifique as notas abaixo conforme suas caracteristicas originais."	OF oPanel1 PIXEL
	@ 18,05 Say "Obs: Os documentos de saida sem TES serão geradas prEnotas."			OF oPanel1 PIXEL
	
	
	oGets:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oPanel2,aHeader,aCols)
	oGets:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGets:OBROWSE:NFREEZE := 1
	
	
	ACTIVATE MSDIALOG oDlg ON INIT KpmgBarMnu(oDlg,		{|| (nOpcA:=1,oDlg:End())},;
	{|| (nOpcA:=0,oDlg:End())},;
	{},{},.F.,.F.,.F.,0,.T.) CENTER
	
	
	
	If nOpcA==1
		For nX:=1 to Len(oGets:aCols)
			If !oGets:aCols[nX,Len(oGets:aCols[nX])]
				aAdd(aNF,aNFOrig[nX])
				aNF[nX,12] := oGets:aCols[nX,05]
				aNF[nX,13] := oGets:aCols[nX,06]
				aNF[nX,14] := oGets:aCols[nX,07]
				aNF[nX,15] := oGets:aCols[nX,08]
				aNF[nX,16] := oGets:aCols[nX,09]
				aNF[nX,17] := oGets:aCols[nX,10]
				aNF[nX,18] := oGets:aCols[nX,11]
				aNF[nX,19] := oGets:aCols[nX,12]
				aNF[nX,20] := oGets:aCols[nX,13]
				aNF[nX,21] := oGets:aCols[nX,14]
				aNF[nX,22] := oGets:aCols[nX,15]
			EndIf
		Next nX
	EndIf
	
Else
	//->> Keeptrue
	aAdd(aHeader,{ "Tipo"				,"TPNOTA"	,"@!"							,10							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "Nota Fiscal"		,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "TES"				,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_KPXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",,,,"A"} )
	aAdd(aHeader,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"				/*VALIDACAO*/,""	,"C","SE4"	,"R",,,,"A"} )
	aAdd(aHeader,{ "Natureza"			,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')"	/*VALIDACAO*/,""	,"C","SED"	,"R",,,,"A"} )
	aAdd(aHeader,{ "Arquivo"			,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	
	For nX:= 1 To Len(aNFOrig)
		aAdd(aCols,{aNFOrig[nX,01],aNFOrig[nX,02],aNFOrig[nX,03],aNFOrig[nX,23],aNFOrig[nX,20],aNFOrig[nX,21],aNFOrig[nX,22],aNFOrig[nX,24],.F.})
	Next nX
	
	DEFINE MSDIALOG oDlg TITLE "Classificação das notas de Serviço" FROM 0,0 To 400,800 PIXEL
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	
	oFWLayer:addLine("L1",100,.F.)
	oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
	oFWLayer:AddWindow("C1"		,"oPanel","Classificação das Notas"	,100,.F.,.T.,,"L1",{ || })
	oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")
	
	oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL
	
	@ 06,05	Say "Classifique as notas abaixo conforme suas caracteristicas originais."	OF oPanel1 PIXEL
	@ 18,05 Say "Obs: Os documentos de saida sem TES serão geradas prEnotas."			OF oPanel1 PIXEL
	
	oGets:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oPanel2,aHeader,aCols)
	oGets:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGets:OBROWSE:NFREEZE := 1
	
	
	ACTIVATE MSDIALOG oDlg ON INIT KpmgBarMnu(oDlg,		{|| (nOpcA:=1,oDlg:End())},;
	{|| (nOpcA:=0,oDlg:End())},;
	{},{},.F.,.F.,.F.,0,.T.) CENTER
	
	If nOpcA==1
		For nX:=1 to Len(oGets:aCols)
			If !oGets:aCols[nX,Len(oGets:aCols[nX])]
				aAdd(aNF,aNFOrig[nX])
				aNF[nX,20] := oGets:aCols[nX,05]
				aNF[nX,21] := oGets:aCols[nX,06]
				aNF[nX,22] := oGets:aCols[nX,07]
			EndIf
		Next nX
	EndIf
EndIf

Return aNF


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ GeraTitulo³ Autor ³ Marcio Martins       ³ Data ³23/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao do XML para o Documento de Entrada ou Saida     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GeraTitulo(cPar01,nPar02,cPar03,cPar04,cPar05)             ³±±
±±³          ³ Onde: cPar01 -> Codigo da TES                              ³±±
±±³          ³       nPar02 -> Valor da Nota F2_VALBRUT                   ³±±
±±³          ³       cPar03 -> Condicao de Pagamento                      ³±±
±±³          ³       cPar04 -> Numero do Tú‘ulo/Nota                      ³±±
±±³          ³       cPar05 -> Prefixo/Serie                              ³±±
±±³          ³       cPar06 -> Natureza									  ³±±
±±³			 ³       cPar07 -> Cliente+Loja								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTitulo(cTes,nTotal,cCon,cTitulo,cPrefixo,cNatureza,cCliente)

Local cParcela  := "1"
Local aVetor	:= {}

//RRP - 06/08/2014 - Ajuste para gravar o prefixo corretamente
DbselectArea("SF2")
DBSetOrder(1)
If dbSeek(xFilial("SF2")+cNumero+cPrefixo+cCliente)
	cPrefixo := &(GetMV("MV_1DUPREF"))
EndIf


If AvalTes(cTes,,"S")
	aDiaPag := Condicao(nTotal,cCon,0,dDataBase)
	
	SX3->(dbSetOrder(2))
	SX3->(dbSeek("E1_PREFIXO"))
	cObrigat := SX3->X3_OBRIGAT
	RecLock("SX3",.F.)
	SX3->X3_OBRIGAT := " "
	SX3->(MsUnLock())
	SX3->(dbSeek("E1_CCC"))
	cObrigat := SX3->X3_OBRIGAT
	RecLock("SX3",.F.)
	SX3->X3_OBRIGAT := " "
	SX3->(MsUnLock())
	
	For nX := 1 To Len(aDiaPag)
		If Len(aDiaPag) == 1
			cParcela := " "
		Else
			If nX > 1
				cParcela := Soma1(cParcela)
			EndIf
		EndIf

		//--> Garante a Contabilizao Off-Line na Inclusao do Titulo
		If SX1->(dbSeek(PadR("FIN040",10)+"03"))
			cX1_PRESEL := SX1->X1_PRESEL
			RecLock("SX1",.F.)
			SX1->X1_PRESEL := 2
			SX1->(MsUnLock())
		EndIf
		
		aVetor  := {	{"E1_PREFIXO"	,cPrefixo			,Nil},;
						{"E1_NUM"		,cTitulo			,Nil},;
						{"E1_PARCELA"	,cParcela			,Nil},;
						{"E1_TIPO"		,"NF "				,Nil},;
						{"E1_NATUREZ"	,cNatureza      	,Nil},;
						{"E1_CLIENTE"	,SA1->A1_COD		,Nil},;
						{"E1_LOJA"		,SA1->A1_LOJA   	,Nil},;
						{"E1_EMISSAO"	,dDataBase       	,Nil},;
						{"E1_VENCTO"	,aDiaPag[nX,1]     	,Nil},;
						{"E1_VENCREA"	,aDiaPag[nX,1]		,Nil},;
						{"E1_VALOR"		,aDiaPag[nX,2]		,Nil},;
						{"E1_VEND1"		,SA1->A1_VEND		,Nil},;
						{"E1_BASCOM1"	,aDiaPag[nX,2]		,Nil},;
						{"E1_ORIGEM"    ,"MATA460"			,Nil},;
						{"E1_COMIS1"	,SA1->A1_COMIS		,Nil}}
						
		MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao

		//--> Restaura o parametro da Contabilizacao selecionado anteriormente
		If SX1->(dbSeek(PadR("FIN040",10)+"03"))
			RecLock("SX1",.F.)
			SX1->X1_PRESEL := cX1_PRESEL
			SX1->(MsUnLock())
		EndIf
			
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return
		EndIf
		
	Next nX
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ExtrNfProd  ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Extrai dados da NF do XML de produtos.			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ ExtrNfProd()	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExtrNfProd(oXml,aDados,cArquivo)

Local oNFe 	:= IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)
Local aItens:= {}
Local aNF	:= {}
Local aRet  := {}
Local cCFOP := ""
Local nX	:= 1

Local cCGC  := ""   

Local dDtEmiss	:= CTOD("//")

Private cTipo := ""

//-->> 01 Tipo da geracao da NF
If Alltrim(oNFe:_EMIT:_CNPJ:TEXT) == Alltrim(_cMeuCnpj) //.And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
	If !(lDev)
		aAdd(aNF,"SAIDA")
		cTipo := "S"   
	Else
		aAdd(aNF,"ENTRADA")
		cTipo := "E"	
	EndIF
	           
Else                                                                     
	aAdd(aNF,"ENTRADA")
	cTipo := "E"
EndIf


aAdd(aNF,StrZero(Val(oNFe:_IDE:_NNF:TEXT),Len(SF1->F1_DOC)))			//->> 02 - Numero da Nota
aAdd(aNF,oNFe:_IDE:_SERIE:TEXT)											//->> 03 - Serie

If cPessoa == "J"
	aAdd(aNF,oNFe:_DEST:_CNPJ:TEXT)										//->> 04 - CNPJ CLIENTE
	cCGC:=oNFe:_DEST:_CNPJ:TEXT
ElseIf cPessoa == "F"
	aAdd(aNF,oNFe:_DEST:_CPF:TEXT)										//->> 04 - CPF	CLIENTE
	cCGC:=oNFe:_DEST:_CPF:TEXT
Else
	aAdd(aNF,"")														//->> 04 - CPF ou CPNJ não encontrado no XML 
EndIf


If cTipo == "S"
    
    //RRP - 30/04/2015 - Tratamento para Exportador sem CNPJ ou CPF
	If cPessoa <> ""	
		SA1->(dbSetOrder(3))
		If !SA1->(dbSeek(xFilial("SA1")+cCGC))
			//RRP - 06/08/2014 - Validando se os campos do destinatário estão preenchidos. Chamado 020581. 
			//RRP - 17/03/2015 - Ajuste para integração com clinete pessoa fisica.
			aAdd( aNewClie, { 	" "									   									   							  			,;	//------> 01 - E-mail
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") 	  							  			,;	//------> 02 - Fone
			" "																							  							  			,;	//------> 03 - Bairro
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CEP")<>Nil, oNFe:_DEST:_ENDERDEST:_CEP:TEXT, " ")	  							   			,;	//------> 04 - CEP
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CMUN")<>Nil, oNFe:_DEST:_ENDERDEST:_CMUN:TEXT, " ")	  							   			,;	//------> 05 - Cod Municipio
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CPAIS")<>Nil, oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT, " ")   							   			,;	//------> 06 - Cod Pais
			" "                             						 									  							   			,;	//------> 07 - Compl Endereco
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_XLGR")<>Nil, oNFe:_DEST:_ENDERDEST:_XLGR:TEXT, " ")	   							   			,;	//------> 08 - Endereco
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_NRO")<>Nil, oNFe:_DEST:_ENDERDEST:_NRO:TEXT, " ")	   							   			,;	//------> 09 - Numero
			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_UF")<>Nil, oNFe:_DEST:_ENDERDEST:_UF:TEXT, " ")									   			,;	//------> 10 - UF 
			IIF(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil, oNFe:_DEST:_CNPJ:TEXT,IIF(XmlChildEx(oNFe:_DEST,"_CPF")<>Nil, oNFe:_DEST:_CPF:TEXT," "))	,;	//------> 11 - CNPJ
			IIF(XmlChildEx(oNFe:_DEST,"_IE")<>Nil, oNFe:_DEST:_IE:TEXT, " ")							  										,;	//------> 12 - IE
			oNFe:_DEST:_XNOME:TEXT										 								  										})	//------> 13 - Razao Social
		EndIf
	Else
		SA1->(dbSetOrder(2))
		If !SA1->(dbSeek(xFilial("SA1")+PadR(Upper(oNFe:_DEST:_XNOME:TEXT),Len(SA1->A1_NOME))))
			
			aAdd( aNewForn, { 	" "																		,;	//------> 01 - E-mail
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") 	,;	//------> 02 - Fone
			" "																							,;	//------> 03 - Bairro
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CEP" )<>Nil, oNFe:_DEST:_ENDERDEST:_CEP:TEXT , " ") 	,;	//------> 04 - CEP
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CMUN")<>Nil, oNFe:_DEST:_ENDERDEST:_CMUN:TEXT, " ") 	,;	//------> 05 - Cod Municipio
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CPAIS")<>Nil, oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT," ") 	,;	//------> 06 - Cod Pais
			" "                             															,;	//------> 07 - Compl Endereco
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_XLGR")<>Nil, oNFe:_DEST:_ENDERDEST:_XLGR:TEXT, " ") 	,;	//------> 08 - Endereco
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_NRO" )<>Nil, oNFe:_DEST:_ENDERDEST:_NRO:TEXT , " ") 	,;	//------> 09 - Numero  
			If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_UF"  )<>Nil, oNFe:_DEST:_ENDERDEST:_UF:TEXT  , " ") 	,;	//------> 10 - UF 
			If(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil, oNFe:_DEST:_CNPJ:TEXT, " ") 				   		,;	//------> 11 - CNPJ 
			If(XmlChildEx(oNFe:_DEST,"_IE"  )<>Nil, oNFe:_DEST:_IE:TEXT  , " ") 	   					,;	//------> 12 - IE 
			Upper(oNFe:_DEST:_XNOME:TEXT)																})	//------> 13 - Razao Social
		Else	
			aNF[4]:=SA1->A1_CGC	//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
		EndIf
	EndIf		 
Else
	If oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"	
			
		If lDev
				
			SA1->(dbSetOrder(3))
	
			If !SA1->(dbSeek(xFilial("SA1")+cCGC))
				//RRP - 06/08/2014 - Validando se os campos do destinatário estão preenchidos. Chamado 020581.
	   			aAdd( aNewClie, { 	" "									   										,;	//------> 01 - E-mail
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") 		,;	//------> 02 - Fone
	   			" "																								,;	//------> 03 - Bairro
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CEP")<>Nil, oNFe:_DEST:_ENDERDEST:_CEP:TEXT, " ")		,;	//------> 04 - CEP
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CMUN")<>Nil, oNFe:_DEST:_ENDERDEST:_CMUN:TEXT, " ")		,;	//------> 05 - Cod Municipio
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CPAIS")<>Nil, oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT, " ")	,;	//------> 06 - Cod Pais
	   			" "                             						 										,;	//------> 07 - Compl Endereco
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_XLGR")<>Nil, oNFe:_DEST:_ENDERDEST:_XLGR:TEXT, " ")		,;	//------> 08 - Endereco
				IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_NRO")<>Nil, oNFe:_DEST:_ENDERDEST:_NRO:TEXT, " ")		,;	//------> 09 - Numero
				IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_UF")<>Nil, oNFe:_DEST:_ENDERDEST:_UF:TEXT, " ")			,;	//------> 10 - UF 
				IIF(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil, oNFe:_DEST:_CNPJ:TEXT, " ")							,;	//------> 11 - CNPJ
	   			IIF(XmlChildEx(oNFe:_DEST,"_IE")<>Nil, oNFe:_DEST:_IE:TEXT, " ")								,;	//------> 12 - IE
	   			oNFe:_DEST:_XNOME:TEXT										 									})	//------> 13 - Razao Social
			
			EndIf
	    
	    Else  		
		
			//aAdd(aNF,oNFe:_EMIT:_CNPJ:TEXT)										//->> 04 - CNPJ FORNECEDOR
			//MSM - 26/11/14 - Alterado pois a posição 4 jEexiste
			aNF[4]:=oNFe:_EMIT:_CNPJ:TEXT	//->> 04 - CNPJ FORNECEDOR
			
			SA2->(dbSetOrder(3))
			If !SA2->(dbSeek(xFilial("SA2")+oNFe:_EMIT:_CNPJ:TEXT))
				aAdd( aNewForn, { 	" "																		,;	//------> 01 - E-mail
				If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_FONE")<>Nil, oNFe:_EMIT:_ENDEREMIT:_FONE:TEXT, " ") 	,;	//------> 02 - Fone
				" "														   									,;	//------> 03 - Bairro
				If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_CEP")<>Nil,oNFe:_EMIT:_ENDEREMIT:_CEP:TEXT," ")		,;	//------> 04 - CEP
				If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_CMUN")<>Nil,oNFe:_EMIT:_ENDEREMIT:_CMUN:TEXT," ")		,;	//------> 05 - Cod Municipio
				If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_CPAIS")<>Nil,oNFe:_EMIT:_ENDEREMIT:_CPAIS:TEXT," ")	,;	//------> 06 - Cod Pais
				" "                             						   									,;	//------> 07 - Compl Endereco
				If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_XLGR")<>Nil,oNFe:_EMIT:_ENDEREMIT:_XLGR:TEXT," ")		,;	//------> 08 - Endereco
		   		If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_NRO")<>Nil,oNFe:_EMIT:_ENDEREMIT:_NRO:TEXT," ")		,;	//------> 09 - Numero
				If(XmlChildEx(oNFe:_EMIT:_ENDEREMIT,"_UF")<>Nil,oNFe:_EMIT:_ENDEREMIT:_UF:TEXT," ")			,;	//------> 10 - UF
				If(XmlChildEx(oNFe:_EMIT,"_CNPJ")<>Nil,oNFe:_EMIT:_CNPJ:TEXT," ")							,;	//------> 11 - CNPJ
				If(XmlChildEx(oNFe:_EMIT,"_IE")<>Nil,oNFe:_EMIT:_IE:TEXT," ")								,;	//------> 12 - IE
				If(XmlChildEx(oNFe:_EMIT,"_XNOME")<>Nil,oNFe:_EMIT:_XNOME:TEXT," ")							})	//------> 13 - Razao Social
			EndIf
   		EndIF
   
	Else  
	
		If lDev 
	
			SA1->(dbSetOrder(3))
	
			If !SA1->(dbSeek(xFilial("SA1")+cCGC))
				//RRP - 06/08/2014 - Validando se os campos do destinatário estão preenchidos. Chamado 020581.
	   			aAdd( aNewClie, { 	" "									   										,;	//------> 01 - E-mail
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") 		,;	//------> 02 - Fone
	   			" "																								,;	//------> 03 - Bairro
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CEP")<>Nil, oNFe:_DEST:_ENDERDEST:_CEP:TEXT, " ")		,;	//------> 04 - CEP
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CMUN")<>Nil, oNFe:_DEST:_ENDERDEST:_CMUN:TEXT, " ")		,;	//------> 05 - Cod Municipio
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CPAIS")<>Nil, oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT, " ")	,;	//------> 06 - Cod Pais
	   			" "                             						 										,;	//------> 07 - Compl Endereco
	   			IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_XLGR")<>Nil, oNFe:_DEST:_ENDERDEST:_XLGR:TEXT, " ")		,;	//------> 08 - Endereco
				IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_NRO")<>Nil, oNFe:_DEST:_ENDERDEST:_NRO:TEXT, " ")		,;	//------> 09 - Numero
				IIF(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_UF")<>Nil, oNFe:_DEST:_ENDERDEST:_UF:TEXT, " ")			,;	//------> 10 - UF 
				IIF(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil, oNFe:_DEST:_CNPJ:TEXT, " ")							,;	//------> 11 - CNPJ
	   			IIF(XmlChildEx(oNFe:_DEST,"_IE")<>Nil, oNFe:_DEST:_IE:TEXT, " ")								,;	//------> 12 - IE
	   			oNFe:_DEST:_XNOME:TEXT										 									})	//------> 13 - Razao Social
			
			EndIf
	    
	    Else       
	    
			SA2->(dbSetOrder(2))
			If !SA2->(dbSeek(xFilial("SA2")+PadR(Upper(oNFe:_DEST:_XNOME:TEXT),Len(SA2->A2_NOME))))
				//aAdd(aNF,oNFe:_DEST:_CNPJ:TEXT)									//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
				
				//MSM - 26/11/14 - Alterado pois a posição 4 jEexiste
				aNF[4]:=oNFe:_DEST:_CNPJ:TEXT	//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
				
				aAdd( aNewForn, { 	" "																		,;	//------> 01 - E-mail
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") 	,;	//------> 02 - Fone
				" "																							,;	//------> 03 - Bairro
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CEP" )<>Nil, oNFe:_DEST:_ENDERDEST:_CEP:TEXT , " ") 	,;	//------> 04 - CEP
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CMUN")<>Nil, oNFe:_DEST:_ENDERDEST:_CMUN:TEXT, " ") 	,;	//------> 05 - Cod Municipio
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_CPAIS")<>Nil, oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT," ") 	,;	//------> 06 - Cod Pais
				" "                             															,;	//------> 07 - Compl Endereco
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_XLGR")<>Nil, oNFe:_DEST:_ENDERDEST:_XLGR:TEXT, " ") 	,;	//------> 08 - Endereco
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_NRO" )<>Nil, oNFe:_DEST:_ENDERDEST:_NRO:TEXT , " ") 	,;	//------> 09 - Numero  
				If(XmlChildEx(oNFe:_DEST:_ENDERDEST,"_UF"  )<>Nil, oNFe:_DEST:_ENDERDEST:_UF:TEXT  , " ") 	,;	//------> 10 - UF 
				If(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil, oNFe:_DEST:_CNPJ:TEXT, " ") 				   		,;	//------> 11 - CNPJ 
				If(XmlChildEx(oNFe:_DEST,"_IE"  )<>Nil, oNFe:_DEST:_IE:TEXT  , " ") 	   					,;	//------> 12 - IE 
				Upper(oNFe:_DEST:_XNOME:TEXT)																})	//------> 13 - Razao Social
			Else	
				//aAdd(aNF,SA2->A2_COD)									//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
				
				//MSM - 26/11/14 - Alterado pois a posição 4 jEexiste
				aNF[4]:=SA2->A2_CGC	//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
			EndIf 
			
		EndIf	
	EndIf	
EndIf

//MSM - 02/12/2014 - tratamento para o atributo data de emissão
if XmlChildEx(oNFe:_IDE,"_DEMI"  )<>Nil
	dDtEmiss:=StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-",""))
elseif XmlChildEx(oNFe:_IDE,"_DHEMI"  )<>Nil
	dDtEmiss:=StoD(StrTran(oNFe:_IDE:_DHEMI:TEXT,"-",""))
endif

aAdd(aNF,dDtEmiss)  												//->> 05 - Data de Emissão
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vFrete:TEXT))					//->> 06 - Frete
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vDesc:TEXT))						//->> 07 - Desconto
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vSeg:TEXT))						//->> 08 - Seguro
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vNF:TEXT))						//->> 09 - Valor Bruto
aAdd(aNF,oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT) 				//->> 10 - Chave da Nota Fiscal

//-->> Monta o aDados para Importar os itens da NF-e
//RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
If ValType(oNFe:_DET) == "A"
	For nX := 1 To Len(oNFe:_DET)
		cCFOP := oNFe:_DET[nX]:_PROD:_CFOP:TEXT
		aAdd( aItens , { 	oNFe:_DET[nX]:_NITEM:TEXT	   												,;	//->> 01 - Item
		UPPER(oNFe:_DET[nX]:_PROD:_CPROD:TEXT)		   	   												,;	//->> 02 - Codigo do Produto no Fornec
		oNFe:_DET[nX]:_PROD:_UCOM:TEXT				   													,;	//->> 03 - Unidade de Medida
		Val(oNFe:_DET[nX]:_PROD:_QCOM:TEXT)			   													,;	//->> 04 - Quantidade
		Val(oNFe:_DET[nX]:_PROD:_VUNCOM:TEXT)															,;	//->> 05 - Valor Unitario
		Val(oNFe:_DET[nX]:_PROD:_VPROD:TEXT)			  												,;	//->> 06 - Valor Total do Total
		oNFe:_DET[nX]:_PROD:_XPROD:TEXT					  												,;	//->> 07 - Descricao do Produto
		oNFe:_DET[nX]:_PROD:_CFOP:TEXT					   												,;	//->> 08 - CFOP
		IIF(XmlChildEx(oNFe:_DET[nX]:_PROD,"_VDESC")<>Nil, Val(oNFe:_DET[nX]:_PROD:_VDESC:TEXT), 0)		,; //->> 09 - Desconto
		IIF(XmlChildEx(oNFe:_DET[nX]:_PROD,"_VFRETE")<>Nil, Val(oNFe:_DET[nX]:_PROD:_VFRETE:TEXT), 0)	}) //->> 10 - Frete
		
	Next nX
Else
	cCFOP := oNFe:_DET:_PROD:_CFOP:TEXT
	aAdd( aItens , { 	oNFe:_DET:_NITEM:TEXT  															,;	//->> 01 - Item
	UPPER(oNFe:_DET:_PROD:_CPROD:TEXT)		 															,;	//->> 02 - Codigo do Produto no Fornec
	oNFe:_DET:_PROD:_UCOM:TEXT				  													   		,;	//->> 03 - Unidade de Medida
	Val(oNFe:_DET:_PROD:_QCOM:TEXT)			  													   		,;	//->> 04 - Quantidade
	Val(oNFe:_DET:_PROD:_VUNCOM:TEXT)																	,;	//->> 05 - Valor Unitario
	Val(oNFe:_DET:_PROD:_VPROD:TEXT)		  													   		,;	//->> 06 - Valor Total do Total
	oNFe:_DET:_PROD:_XPROD:TEXT				   													   		,;	//->> 07 - Descricao do Produto
	oNFe:_DET:_PROD:_CFOP:TEXT																	   		,;	//->> 08 - CFOP
	IIF(XmlChildEx(oNFe:_DET:_PROD,"_VDESC")<>Nil, Val(oNFe:_DET:_PROD:_VDESC:TEXT), 0)	   				,;  //->> 09 - Desconto
	IIF(XmlChildEx(oNFe:_DET:_PROD,"_VFRETE")<>Nil, Val(oNFe:_DET:_PROD:_VFRETE:TEXT), 0)		  		})  //->> 10 - Frete
EndIf

aAdd(aNF,aItens)														//->> 11 - Itens da Nota Fiscal    
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1")+aNF[11][1][2]))
	If aNF[1] == "ENTRADA"
   		aAdd(aNF,SB1->B1_TE)  	 										//->> 12 - TES
	Else
		aAdd(aNF,SB1->B1_TS)  											//->> 12 - TES
	EndIf
Else
	aAdd(aNF,Criavar("D1_TES")) 	   							 		//->> 12 - TES
EndIf

If aNF[1] == "ENTRADA"   
	If lDev
		aAdd(aNF,SA1->A1_COND)	   										//->> 13 - COND    
		aAdd(aNF,SA1->A1_NATUREZ) 										//->> 14 - NATUREZA
	Else                                      	
		aAdd(aNF,SA2->A2_COND)	   										//->> 13 - COND
		aAdd(aNF,SA2->A2_NATUREZ) 										//->> 14 - NATUREZA
	EndIF
Else
	aAdd(aNF,SA1->A1_COND)		  										//->> 13 - COND
	aAdd(aNF,SA1->A1_NATUREZ) 									  		//->> 14 - NATUREZA
EndIf   								
									
//RRP - 30/04/2015 - Tratamento para Exportador sem CNPJ ou CPF					
If oNFe:_DEST:_ENDERDEST:_UF:TEXT == "EX" .AND. lDev
	aAdd(aNF,SA2->A2_COD)												//->> 15 - FORNECEDOR IMPORT
ElseIf oNFe:_DEST:_ENDERDEST:_UF:TEXT == "EX" .AND. !lDev
	aAdd(aNF,SA1->A1_COD)												//->> 15 - CLIENTE EXPORTAÇÃO
Else	
	aAdd(aNF,Criavar("A2_COD",.F.))										//->> 15 - FORNECEDOR IMPORT
EndIf	
aAdd(aNF,Criavar("A1_COD",.F.))  										//->> 16 - CLIENTE IMPORT
If lDev
	aAdd(aNF,"D") 				   										//->> 17 - TIPO NOTA
Else
	aAdd(aNF,"N") 				   										//->> 17 - TIPO NOTA
EndIf

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VOUTRO")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vOutro:TEXT))					//->> 18 - DESPESAS
else
	aAdd(aNF,Criavar("D1_TOTAL"  ))    									//->> 18 - DESPESAS
endif

aAdd(aNF,Criavar("D1_NFORI"  ))    										//->> 19 - NOTA ORIGEM
aAdd(aNF,Criavar("D1_SERIORI"))    										//->> 20 - SERIE ORIGEM
aAdd(aNF,Criavar("E2_CODRET" ))    										//->> 21 - CODIGO DE RETENCAO - DIRF
aAdd(aNF,cArquivo)														//->> 22 - Arquivo de Importacao
aAdd(aNF,dDtEmiss)														//->> 23 - Data da Digitacao

If cTipo == "E" .And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
	cCFOP := If( Left(cCFOP,1) == "5", "1", "2" ) + Right(cCFOP,3)
EndIf

aAdd(aNF,cCFOP)															//->> 24 - CFOP
aAdd(aNF,oNFe:_IDE:_NATOP:TEXT)											//->> 25 - Natureza de Operacao

//--> Valida a Chave da NFe
aRet := U_ValNfeSef(oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT,,,lMsg)	//CAS 27/09/2019 - Ajuste para levar corretamente a variavel "lMsg" para a função U_ValNfeSef, e assim ela nao pegar do Default 
aAdd(aNF,aRet[1])														//->> 26 - .T. Chave Valida / .F. Chave Invalida
aAdd(aNF,aRet[2])														//->> 27 - Mensagem da Validacao da Chave da NFe
aAdd(aNF,oNFe:_DEST:_ENDERDEST:_UF:TEXT)								//->> 28 - UF do Destinatario (importante para NF de Importacao)

aAdd(aDados,aNF)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ProcXmlProd ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Processamento da Importacao de notas de produtos.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ ProcXmlProd()	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Keeptrue                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcXmlProd(lAuto,aNF,oRegua,lExibErro)
Local nX	:= 0
Local lOK	:= .T.
Local cNewArq := ""

Default lAuto := .F.
Default oRegua:= ""

If !lAuto .And. Valtype(oRegua)=="O"
	oRegua:SetRegua2(Len(aNF))
EndIf
For nX := 1 To Len(aNF)
	If lContOnLine
		nHdlPrv := HeadProva( cLoteFat , _cFuncao , cUserName , @cArquivo )	
		nTotal := 0
	EndIf
	If !lAuto
		oRegua:IncRegua1("Importação de XML de Produto...")
		oRegua:IncRegua2("Gerando N.Fiscal de "+aNF[nX,1]+" - "+aNF[nX,2]+"/"+aNF[nX,3]+"  ("+AllTrim(Str(nX))+"/"+AllTrim(Str(Len(aNF)))+")")
		If Valtype(oRegua)=="O"
			If oRegua:lEnd
				lEnd := .T.
				Exit
			EndIf
			lOK:=GeraNFP(aNF[nX],lAuto,lExibErro,@oRegua)
		Else
			Processa( { || lOK:=GeraNFP(aNF[nX],lAuto,lExibErro,@oRegua) } , 'Aguarde...' , 'Gerando Notas de Produtos' )
		EndIf
	Else
		lOK:=GeraNFP(aNF[nX],lAuto,.F.,@oRegua)
	EndIf
	
	If lOk
		If lContOnLine
			RodaProva( nHdlPrv , nTotal )
			cA100Incl( cArquivo , nHdlPrv , 3, cLoteFat , lMostraLanc , .F. /*lAglutina*/ )		
		Endif
	Endif				
	
Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³  GeraNFP   ³ Autor ³ Larson Zordan        ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Geracao da NF de Produtos.						            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ GeraNFP()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraNFP(aNF,lAuto,lExibErro,oRegua)
Local nX		:= 1
Local aCabec    := {}
Local aItemNF   := {}
Local aItens    := {}
Local lRetorno  := .T.
Local lPreNF    := .F.
Local lSB1If	:= .F.
Local cCFOP     := " "
Local cTesE     := " "
Local cTesS     := " "
Local cAUTOISS  := GetMv( "MV_AUTOISS"  )
Local cItem     := "00"
Local dDataEmis := dDatabase
Local dDataAnt	:= dDatabase
Local nAditiv := 1

Private lMSErroAuto := .F.

Default lExibErro := .F.

dDataEmis := aNF[05]
dDatabase := aNF[23]

If aNF[1]=="ENTRADA"
	//->> Documentos de Entrada
	If Empty(aNF[16])
		//-->> Posiciona no Fornecedor pelo Codigo do Fornecedor
		SA2->(dbSetOrder(3))
		If !SA2->(dbSeek(xFilial("SA2")+aNF[04]))
			If lExibErro
				MsgStop('Não existe Fornecedor cadastrado com este CNPJ ' + aNF[04])
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Não existe Fornecedor cadastrado com este CNPJ.")
			EndIf
			Return .F.
		EndIf
	Else
		//--> Fornecedor Importacao
		SA2->(dbSetOrder(1))
		If !SA2->(dbSeek(xFilial("SA2")+aNF[16]))
			If lExibErro
				MsgStop('Fornecedor Não Encontrado, Verifique ' + aNF[15])
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Fornecedor Não Encontrado.")
			EndIf
			Return .F.
		EndIf
	Endif
	
	If Empty(aNF[14])
		If Empty(SA2->A2_NATUREZ)
			If lExibErro
				Aviso( 'Ateção' , 'Não hEnatureza cadastrada para este fornecedor: ' + SA2->A2_COD + CRLF + CRLF , { 'Ok' } , 2 , 'Natureza Não Cadastrada!' )
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Não hEnatureza cadastrada para este fornecedor")
			EndIf
			Return .F.
		Else
			aNF[14]:= SA2->A2_NATUREZ
		EndIf
	EndIf
	
	//-->> Valida existencia do Doc. de Entrada
	SF1->(dbSetOrder(1))
	If SF1->(dbSeek(xFilial('SF1')+StrZero(Val(aNF[02]),9)+PadR(aNF[03],3)+SA2->(A2_COD+A2_LOJA)))
		If lExibErro
			Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo jEfoi cadastrado!' + CRLF + CRLF + ;
			'Fornecedor: ' + SA2->(A2_COD+'/'+A2_LOJA+' '+A2_NOME) + CRLF + ;
			'Doc./Serie: ' + cNumero+' / '+cSerie , { 'Ok' } , 2 , 'Documento jEcadastrado!' )
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" jEexiste.")
		EndIf
		Return .F.
	EndIf
	
	//--> Larson
	If aNF[17] == "N" .And. Posicione("SED",1,xFilial("SED")+SA2->A2_NATUREZ,"ED_CALCIRF") == "S" .And. Empty(aNF[21])
		If lExibErro
			Aviso( 'Ateção' , 'O Código da Retenção do I.R. (DIRF) Não foi preenchido corretamente.' + SA2->A2_COD + CRLF + CRLF , { 'Ok' } , 2 , 'DIRF - Cód. Retenção!' )
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"O Código da Retenção do I.R. (DIRF) Não foi preenchido corretamente.")
		EndIf
		Return .F.
	EndIf
	
	PutMV( "MV_AUTOISS", '{"'+SA2->A2_COD+'","'+SA2->A2_LOJA+'","1","'+aNF[21]+'"}' )
	//--> EOL
	
	cNumero := StrZero(Val(aNF[02]),9)
	cSerie	:= aNF[03]
	
	
	//-->> Monta o cabecalho do Doc. de Entrada
	aAdd(aCabec,{"F1_FILIAL"  ,xFilial('SF1')								,Nil})
	aAdd(aCabec,{"F1_TIPO"    ,aNF[17]										,Nil})
	aAdd(aCabec,{"F1_FORMUL"  ,"N"											,Nil})
	aAdd(aCabec,{"F1_DOC"     ,cNumero										,Nil})
	aAdd(aCabec,{"F1_SERIE"   ,cSerie										,Nil})
	aAdd(aCabec,{"F1_FORNECE" ,SA2->A2_COD									,Nil})
	aAdd(aCabec,{"F1_LOJA"    ,SA2->A2_LOJA									,Nil})
	aAdd(aCabec,{"F1_EMISSAO" ,aNF[05]										,Nil})
	//WFA - 03/04/2018 - Tratamento de especie quando a empresa for MINISO - ticket 28428
	If cEmpAnt $ "MU"
		cEspecieDoc := "NF-E"
	EndIf		
	aAdd(aCabec,{"F1_ESPECIE" ,cEspecieDoc									,Nil})
	aAdd(aCabec,{"F1_COND"    ,aNF[13]										,Nil})                                                                                                                                                                                                                  
	aAdd(aCabec,{"F1_FRETE"   ,0											,Nil})
	aAdd(aCabec,{"F1_DESCONT" ,0											,Nil})
	aAdd(aCabec,{"F1_SEGURO"  ,0											,Nil})
	aAdd(aCabec,{"F1_DESPESA" ,aNF[18]										,Nil})
	aAdd(aCabec,{"F1_NFORIG"  ,aNF[19]										,Nil})
	aAdd(aCabec,{"F1_SERORIG" ,aNF[20]										,Nil})
	aAdd(aCabec,{"F1_CHVNFE"  ,aNF[10]										,Nil})
	aAdd(aCabec,{"E2_NATUREZ" ,aNF[14] 										,Nil})
	
	SB1->(dbSetOrder(1))
	nAditiv := 1
	
	For nx := 1 To Len(aNF[11])
		//If If(aNF[28] <> "EX", SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO)) , SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) )
		//If If(aNF[28] <> "EX", IF(aNF[17]=="D",SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) ,SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))) , SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) )
		//RRP - 09/11/2016 - Ajuste no IF dependendo da seleção do MV_PAR02
		lSB1If := .F.
		If nParam01 == 1 //Produto
			lSB1If := SB1->(DbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
		ElseIf nParam01== 2 //Produto x Fornecedor
			lSB1If := IIf(aNF[28] <> "EX", IF(aNF[17]=="D",SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) ,SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))) , SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) )
		Else //Ambos
			lSB1If := SB1->(DbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))	
			If !lSB1If
				lSB1If := IIf(aNF[28] <> "EX", IF(aNF[17]=="D",SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) ,SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))) , SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) )) )
		    EndIf
		EndIf
		If lSB1If

			//-->> Define a TES caso digitado 000 utiliza TES Padrao
			cTes	:= aNF[12]
			cTesE 	:= IIf(Empty(aNF[12]),SB1->B1_TE,aNF[12])
			cCFOP 	:= Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")
			
			If Empty(cCFOP)
				cCFOP := aNF[24]
			EndIf
			
			//-->> Monta o array com os itens do Doc. de Entrada
			If     Left(aNF[11,nX,08],1) == "5"
				cCFOP := "1"+Right(aNF[11,nX,08],3)      
			ElseIf Left(aNF[11,nX,08],1) == "6"
				cCFOP := "2"+Right(aNF[11,nX,08],3)
			ElseIf Left(aNF[11,nX,08],1) == "7"
				cCFOP := "3"+Right(aNF[11,nX,08],3)
			EndIf
			
			//RRP - 06/05/2015 - Ajustado a ordem, pois não estava gravando o CD2_ITEM. Chamado 025476.
			aItens := {}
			aAdd( aItens , {"D1_FILIAL"  ,xFilial('SD1')									 													,Nil} )
			aAdd( aItens , {"D1_ITEM"    ,StrZero(Val(aNF[11,nX,01]),TamSX3("D1_ITEM")[01])	 													,Nil} )
			aAdd( aItens , {"D1_DOC"     ,cNumero										   														,Nil} )
			aAdd( aItens , {"D1_SERIE"   ,cSerie											 													,Nil} )
			aAdd( aItens , {"D1_FORNECE" ,SA2->A2_COD										  													,Nil} )
			aAdd( aItens , {"D1_LOJA"    ,SA2->A2_LOJA										   													,Nil} )
			aAdd( aItens , {"D1_COD"     ,SB1->B1_COD										   													,Nil} )
			aAdd( aItens , {"D1_UM"      ,SB1->B1_UM																							,Nil} )
			aAdd( aItens , {"D1_QUANT"   ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)				   					   								,Nil} )
			aAdd( aItens , {"D1_VUNIT"   ,Round(If(aNF[11,nX,05]>0,aNF[11,nX,05],1),TamSX3("D1_VUNIT")[01])	    								,Nil} )
			//aAdd( aItens , {"D1_TOTAL"   ,aNF[11,nX,06]									 		,Nil} )
			aAdd( aItens , {"D1_TOTAL"   ,Round(If(aNF[11,nX,05]>0,aNF[11,nX,05],1)*If(aNF[11,nX,04]>0,aNF[11,nX,04],1),TamSX3("D1_TOTAL")[01])	,Nil} )
			aAdd( aItens , {"D1_TES"     ,cTesE												   													,Nil} )
			aAdd( aItens , {"D1_CF"      ,cCFOP				    							   													,Nil} )
			aAdd( aItens , {"D1_LOCAL"   ,If(!Empty(SB1->B1_LOCPAD),SB1->B1_LOCPAD,"01")   														,Nil} )
			
			// solicitado pela Camila
			If SD1->(FieldPos("D1_X_ADIC")) > 0
				aAdd( aItens , {"D1_X_ADIC"     ,"001"											,Nil} )
			EndIf
			
			If SD1->(FieldPos("D1_X_SQADI")) > 0
				aAdd( aItens , {"D1_X_SQADI"     ,StrZero(nAditiv,3)							,Nil} )
			EndIf
			
			If SD1->(FieldPos("D1_X_FABR")) > 0
				aAdd( aItens , {"D1_X_FABR"     ,SA2->A2_COD									,Nil} )
			EndIf
			//
			nAditiv++
			
			aAdd( aItemNF, aItens )
			//->> Complemento de IPI
			IF aNF[17] =="P" .and. aNF[11,nX,05] == aNF[11,nX,06] .and. !EMPTY(aNF[19])
				aAdd( aItens , {"D1_NFORIG"    	,aNF[19]										,Nil} )
				aAdd( aItens , {"D1_SERIORI"   	,aNF[20]										,Nil} )
				aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
				aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
				IF aNF[17] =="P" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
					If lExibErro
						MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
					EndIf
					If Valtype(oRegua)=="O"
						oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
					EndIf
					Return .F.
				EndIF
			Else
				//->> Complemento de ICM
				IF aNF[17] =="I" .and. aNF[11,nX,05] == aNF[11,nX,06] .and. !EMPTY(aNF[19])
					aAdd( aItens , {"D1_NFORIG"    	,aNF[19]										,Nil} )
					aAdd( aItens , {"D1_SERIORI"   	,aNF[20]										,Nil} )
					aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
					aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
					IF aNF[17] =="I" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
						If lExibErro
							MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
						EndIf
						If Valtype(oRegua)=="O"
							oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
						EndIf
						Return .F.
					ENDIF
				ELse
					//->> Devolução
					IF aNF[17] =="D" .and. !EMPTY(aNF[19])
						aAdd( aItens , {"D1_NFORIG"    	,aNF[19]										,Nil} )
						aAdd( aItens , {"D1_SERIORI"   	,aNF[20]										,Nil} )
						aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
						aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
						IF aNF[17] =="D" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
							If lExibErro
								MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
							EndIf
							If Valtype(oRegua)=="O"
								oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
							EndIf
							Return .F.
						Endif
					Else
						//->> Beneficiamento
						IF aNF[17] =="B" .and. !EMPTY(aNF[19])
							aAdd( aItens , {"D1_NFORIG"    	,aNF[19]										,Nil} )
							aAdd( aItens , {"D1_SERIORI"   	,aNF[20]										,Nil} )
							aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
							aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
							IF aNF[17] =="B" .and. aNF[11,nX,05]<>aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
								If lExibErro
									MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
								EndIf
								If Valtype(oRegua)=="O"
									oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
								EndIf
								Return .F.
							Endif
						Endif
					Endif
				Endif
			Endif
		Else
			If lExibErro
				If nParam01 == 1
					MSGSTOP("Nota "+cNumero+" possui itens sem referencia na tabela de Produtos.")
				Else
					MSGSTOP("Nota "+cNumero+" possui itens sem referencia na tabela de Fornecedores x Produtos.")
				EndIf 
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Possui itens sem referencia na tabela de Fornecedores x Produtos.")
			EndIf
			Return .F.
		EndIf
	Next nx
	
	If !Empty(cTesE) .And. SF4->(dbSeek(xFilial("SF4")+cTesE))
		//-->> Processa a rotina automatica MATA103
		MsExecAuto( { |x,y,z| Mata103(x,y,z) }, aCabec, aItemNF, 3 )
	Else
		//-->> Processa a rotina automatica MATA140
		MSExecAuto( { |x,y,z| Mata140(x,y,z)} , aCabec, aItemNF , 3 )
		lPreNF := .T.
	Endif
	
	If lMsErroAuto
		DisarmTransaction()
		If lExibErro
			MostraErro()
		EndIf
		lRetorno := .F.
	Else
		nProd++
		lRetorno := .T.
		
		DbselectArea("SF1")
		DBSetOrder(1)
		If dbSeek(xFilial('SF1') + cNumero + PadR(cSerie,3) + SA2->(A2_COD+A2_LOJA))
			RecLock("SF1",.F.)
			SF1->F1_CHVNFE := aNF[10]
			SF1->(MSUnlock())
		EndIf
		
		DbselectArea("SF3")
		DBSetOrder(5)
		If DbSeek(xFilial('SF3') + PadR(cSerie,3) + cNumero + SA2->(A2_COD+A2_LOJA))
			While !SF3->(Eof()) .AND. SF3->F3_NFISCAL == cNumero .AND. SF3->F3_SERIE == PadR(cSerie,3)
				If SF3->F3_CFO ==  Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")
					RecLock("SF3",.F.)
					SF3->F3_CHVNFE := aNF[10]
					MSUnlock()
				EndIf
				SF3->(dbSkip())
			EndDo
		EndIf
		
		DbselectArea("SFT")
		DBSetOrder()
		If DbSeek(xFilial('SFT') + 'E' + PadR(cSerie,3) + cNumero + SA2->(A2_COD+A2_LOJA))
			RecLock("SFT",.F.)
			FT_CHVNFE := aNF[10]
			MSUnlock()
		EndIf
		                           
		//--> Cria CD5 para NF Importacao (nao executa quando for pre-nota)
		If aNF[28] == "EX" .And. !lPreNF
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
			While !SD1->(Eof()) .And. xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
				RecLock("CD5",.T.)
				CD5->CD5_FILIAL	:= xFilial('CD5')
				CD5->CD5_DOC	:= SF1->F1_DOC
				CD5->CD5_SERIE	:= SF1->F1_SERIE
				CD5->CD5_FORNEC	:= SF1->F1_FORNECE
				CD5->CD5_LOJA	:= SF1->F1_LOJA
				CD5->CD5_ESPEC	:= SF1->F1_ESPECIE
				CD5->CD5_X_DTDI	:= SF1->F1_DTDIGIT
				CD5->CD5_X_LOCD	:= SF1->F1_EST
				CD5->CD5_X_UFDE	:= SF1->F1_EST
				CD5->CD5_X_DTDE	:= SF1->F1_DTDIGIT
				CD5->CD5_CODEXP	:= SF1->F1_FORNECE
				CD5->CD5_LOJEXP	:= SF1->F1_LOJA
				CD5->CD5_CODFAB	:= SF1->F1_FORNECE
				CD5->CD5_LOJFAB	:= SF1->F1_LOJA
				CD5->CD5_BSPIS	:= SD1->D1_BASEPIS
				CD5->CD5_ALPIS	:= SD1->D1_ALQPIS
				CD5->CD5_VLPIS	:= SD1->D1_VALPIS
				CD5->CD5_BSCOF	:= SD1->D1_BASECOF
				CD5->CD5_ALCOF	:= SD1->D1_ALQCOF
				CD5->CD5_VLCOF	:= SD1->D1_VALCOF
				CD5->CD5_BCIMP	:= SD1->D1_TOTAL
				CD5->CD5_VLRII	:= (SD1->D1_TOTAL*SD1->D1_ALIQII)
				CD5->CD5_ITEM	:= SD1->D1_ITEM
				CD5->CD5_NADIC	:= "1"
				CD5->CD5_SQADIC	:= "1"
				CD5->(MsUnLock())
				SD1->(dbSkip())
			EndDo
		EndIf
	Endif
	
	SA2->(dbCloseArea())
	SE2->(dbCloseArea())
	SF1->(dbCloseArea())
	SD1->(dbCloseArea())
//NF SAIDA
Else
	//->> Documentos de Saida
	cNumero := StrZero(Val(aNF[02]),Tamsx3("F2_DOC")[1])
	cSerie	:= PadR(aNF[03],Tamsx3("F2_SERIE")[1])
	
	//-->> Posiciona no Cliente pelo CNPJ
	If Empty(aNF[16])
		//RRP - 24/02/2015 - Tratamento para Beneficiamento.
		If aNF[17]=="B"
			SA2->(dbSetOrder(3))
			If !SA2->(dbSeek(xFilial("SA2")+aNF[04]))
				If lExibErro
					MsgStop('Não existe Fornecedor cadastrado com este CNPJ ' + aNF[04])
				EndIf
				If Valtype(oRegua)=="O"
					oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Não existe Fornecedor cadastrado com este CNPJ")
				EndIf
				Return .F.
			EndIf
		Else
			SA1->(dbSetOrder(3))
			If !SA1->(dbSeek(xFilial("SA1")+aNF[04]))
				If lExibErro
					MsgStop('Não existe Cliente cadastrado com este CNPJ ' + aNF[04])
				EndIf
				If Valtype(oRegua)=="O"
					oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Não existe Cliente cadastrado com este CNPJ")
				EndIf
				Return .F.
			EndIf
		EndIf
	Else
		//--> Cliente Exportacao
		SA1->(dbSetOrder(1))
		If !SA1->(dbSeek(xFilial("SA1")+aNF[15]))
			If lExibErro
				MsgStop('Fornecedor Não Encontrado, Verifique ' + aNF[15])
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Fornecedor Não Encontrado.")
			EndIf
			Return .F.
		EndIf
	Endif
	
	//-->> Valida existencia do Doc. de Saida
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(xFilial('SF2')+cNumero+PadR(cSerie,3)))
		If lExibErro
			Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo jEfoi cadastrado!' + CRLF + CRLF + ;
			'Cliente:    ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME) + CRLF + ;
			'Doc./Serie: ' + cNumero+' / '+cSerie , { 'Ok' } , 2 , 'Documento jEcadastrado!' )
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" jEcadastrada.")
		EndIf
		Return .F.
	EndIf
	//RRP - 20/08/2014 - Ajuste para validar se a TES atualiza estoque, se sim gera apenas o pedido.
	cTes	:= aNF[12]
	
	If !EMPTY(cTes)
		VldTES(cTes,.F.)
	EndIf
	
	If Empty(aNF[12]).OR.lVldTes 
	    //RRP - 24/02/2015 - Tratamento para Beneficiamento.     
		//TLM 20141024 - Tratamento de chave eletronica
		If (SC5->(FieldPos("C5_P_CHVNF")) > 0)
			//-->> Monta o cabecalho do Pedido de Vendas
	   		aCabec := {	{"C5_NUM"    ,Right(cNumero,6)							 ,Nil},; // Numero do pedido
			  			{"C5_TIPO"   ,aNF[17]									 ,Nil},; // Tipo de pedido
			 			{"C5_CLIENTE",IIF(aNF[17]=="B",SA2->A2_COD,SA1->A1_COD)  ,Nil},; // Codigo do cliente / Fornecedor
			 			{"C5_LOJACLI",IIF(aNF[17]=="B",SA2->A2_LOJA,SA1->A1_LOJA),Nil},; // Loja do cliente / Fornecedor
			   			{"C5_EMISSAO",aNF[05]	 								 ,Nil},; // Data de emissao
			  			{"C5_CONDPAG",aNF[13]	 								 ,Nil},; // Codigo da condicao de pagamanto*
				 		{"C5_DESC1"  ,0											 ,Nil},; // Percentual de Desconto
			   		 	{"C5_INCISS" ,"N"        					 			 ,Nil},; // ISS Incluso
			   			{"C5_TIPLIB" ,"2"		 								 ,Nil},; // Tipo de Liberacao (2-Lib Por Pedido)
			   			{"C5_MOEDA"  ,1			 								 ,Nil},; // Moeda
			   			{"C5_P_CHVNF",aNF[10]	 								 ,Nil},; // Chave eletronica
				  		{"C5_LIBEROK","S"			   							 ,Nil},; // Liberacao Total
				  		{"C5_FRETE"	 ,aNF[06]									 ,Nil},; // RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
				  		{"C5_TPFRETE",IIF(aNF[06]>0,"F"," ")					 ,Nil} } // RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
   		Else

			//-->> Monta o cabecalho do Pedido de Vendas
	   		aCabec := {	{"C5_NUM"    ,Right(cNumero,6)							 ,Nil},; // Numero do pedido
			  			{"C5_TIPO"   ,aNF[17]									 ,Nil},; // Tipo de pedido
			 			{"C5_CLIENTE",IIF(aNF[17]=="B",SA2->A2_COD,SA1->A1_COD)  ,Nil},; // Codigo do cliente / Fornecedor
			 			{"C5_LOJACLI",IIF(aNF[17]=="B",SA2->A2_LOJA,SA1->A1_LOJA),Nil},; // Loja do cliente / Fornecedor
			   			{"C5_EMISSAO",aNF[05]			  						 ,Nil},; // Data de emissao
			  			{"C5_CONDPAG",aNF[13]									 ,Nil},; // Codigo da condicao de pagamanto*
				 		{"C5_DESC1"  ,0					   						 ,Nil},; // Percentual de Desconto
			   		 	{"C5_INCISS" ,"N"         		   				  		 ,Nil},; // ISS Incluso
			   			{"C5_TIPLIB" ,"2"			   							 ,Nil},; // Tipo de Liberacao (2-Lib Por Pedido)
			   			{"C5_MOEDA"  ,1				   							 ,Nil},; // Moeda
				  		{"C5_LIBEROK","S"			   							 ,Nil},; // Liberacao Total
				  		{"C5_FRETE"	 ,aNF[06]									 ,Nil},; // RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
				  		{"C5_TPFRETE",IIF(aNF[06]>0,"F"," ")					 ,Nil} } // RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295		
   		
   		EndIf 
   		//WFA - 03/12/2018 - Verifica se existe o campo C5_NATUREZ para inclui-lo no array. 
   		If (SC5->(FieldPos("C5_NATUREZ")) > 0)
   			aAdd(aCabec, {"C5_NATUREZ"	,IF(!EMPTY(SA1->A1_NATUREZ), SA1->A1_NATUREZ, "1000")	,Nil})
   		EndIf
	Else       	
		//-->> Monta o cabecalho do Doc. de Saida
		aAdd(aCabec,{"F2_TIPO"    ,aNF[17]									  ,Nil})
		aAdd(aCabec,{"F2_DOC"     ,cNumero	   								  ,Nil})
		aAdd(aCabec,{"F2_SERIE"   ,cSerie	  								  ,Nil})
		aAdd(aCabec,{"F2_CLIENTE" ,IIF(aNF[17]=="B",SA2->A2_COD,SA1->A1_COD)  ,Nil})
		aAdd(aCabec,{"F2_LOJA"    ,IIF(aNF[17]=="B",SA2->A2_lOJA,SA1->A1_LOJA),Nil})
		aAdd(aCabec,{"F2_EMISSAO" ,aNF[05]									  ,Nil})
		aAdd(aCabec,{"F2_ESPECIE" ,"SPED"									  ,Nil})
		aAdd(aCabec,{"F2_COND"    ,aNF[13]									  ,Nil})
		aAdd(aCabec,{"F2_FRETE"   ,aNF[06]									  ,Nil})// RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
		aAdd(aCabec,{"F2_DESCONT" ,aNF[07]									  ,Nil})// RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
		aAdd(aCabec,{"F2_SEGURO"  ,0			 							  ,Nil})
		aAdd(aCabec,{"F2_DESPESA" ,aNF[18]		   							  ,Nil})
	EndIf	
		
	SB1->(dbSetOrder(1))
	For nX := 1 To Len(aNF[11])
		
		SB1->(dbSeek(xFilial("SB1")+aNF[11,nX,02]))
		cTes	:= aNF[12]
		cTesS := IIf(Empty(aNF[12]),SB1->B1_TS,aNF[12])
		
		//-->> Verifica se existe TE cadastrado para o Produto
		/*If Empty(cTesS)
			If lExibErro
				MsgStop('Tipo de Entrada padrão não cadastrado para o produto ' + SB1->B1_COD + '!')
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Tipo de Entrada padrão não cadastrado para o produto")
			EndIf
			Return .F.
		EndIf*/
		
		aItens := {}
		cItem := Soma1(cItem)

		If Empty(aNF[12]).OR.lVldTes
		
			//-->> Posiciona na TES conforme Operacao Fiscal
			If !lVldTes
				cTes := "501"
			SF4->(dbGoTop())
			While !SF4->(Eof())
				If AllTrim(SF4->F4_CF) == AllTrim(aNF[11,nX,08])    
					cTES := SF4->F4_CODIGO
					Exit
				EndIf
				SF4->(dbSkip())
			EndDo
			EndIf
		
			//-->> Monta o array com os itens do Pedido de Vendas
			aItens  := {	{"C6_NUM"    ,Right(cNumero,6)								,Nil},; // Numero do Pedido
			  			 	{"C6_ITEM"   ,cItem											,Nil},; // Numero do Item no Pedido
						 	{"C6_PRODUTO",SB1->B1_COD									,Nil},; // Codigo do Produto
						 	{"C6_QTDVEN" ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)			,Nil},; // Quantidade Vendida
						 	{"C6_PRUNIT" ,If(aNF[11,nX,05]>0,aNF[11,nX,05],1)			,Nil},; // Preco de Lista
						 	{"C6_PRCVEN" ,If(aNF[11,nX,05]>0,aNF[11,nX,05],1)			,Nil},; // Preco Unitario Liquido
						 	{"C6_VALOR"  ,aNF[11,nX,06]									,Nil},; // Valor Total do Item
						 	{"C6_ENTREG" ,aNF[05]										,Nil},; // Data da Entrega
						 	{"C6_UM"     ,SB1->B1_UM									,Nil},; // Unidade de Medida Primar.
						 	{"C6_TES"    ,cTes											,Nil},; // Tipo de Entrada/Saida do Item
						 	{"C6_LOCAL"  ,SB1->B1_LOCPAD								,Nil},; // Almoxarifado
						 	{"C6_DESCONT",0												,Nil},; // Percentual de Desconto
						 	{"C6_COMIS1" ,0												,Nil},; // Comissao Vendedor
						 	{"C6_CLI"    ,IIF(aNF[17]=="B",SA2->A2_COD,SA1->A1_COD) 	,Nil},; // Cliente
						 	{"C6_LOJA"   ,IIF(aNF[17]=="B",SA2->A2_LOJA,SA1->A1_LOJA)	,Nil},; // Loja do Cliente
						 	{"C6_QTDEMP" ,0												,Nil},; // Quantidade Empenhada
						 	{"C6_QTDLIB" ,0												,Nil},; // Quantidade Liberada 
						 	{"C6_VALDESC",If(aNF[11,nX,09]>0,aNF[11,nX,09],0)			,Nil} } // RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295

			aAdd( aItemNF, aItens )

		Else	
			//-->> Monta o array com os itens do Doc. de Saida
			aAdd( aItens,  {"D2_ITEM"    ,cItem                                  				,Nil})
			aAdd( aItens , {"D2_COD"     ,SB1->B1_COD											,Nil} )
			aAdd( aItens , {"D2_UM"      ,SB1->B1_UM											,Nil} )
			aAdd( aItens , {"D2_QUANT"   ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)					,Nil} )
			aAdd( aItens , {"D2_PRCVEN"  ,If(aNF[11,nX,05]>0,aNF[11,nX,05],1)					,Nil} )
			aAdd( aItens , {"D2_TOTAL"   ,aNF[11,nX,06]									  		,Nil} )
			aAdd( aItens , {"D2_TES"     ,cTesS													,Nil} )
			aAdd( aItens , {"D2_VALFRE"  ,If(aNF[11,nX,10]>0,aNF[11,nX,10],0)					,Nil} )//RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295
			aAdd( aItens , {"D2_DESCON"  ,If(aNF[11,nX,09]>0,aNF[11,nX,09],0)					,Nil} )//RRP - 30/03/2015 - Tratamento para Frete e Desconto no XML. Chamado 025295			
			
			aAdd( aItemNF, aItens )
			
			//->> Complemento de IPI
			IF aNF[17] =="P" .and. aNF[11,nX,05] == aNF[11,nX,06] .and. !EMPTY(aNF[19])
				aAdd( aItens , {"F1_NFORI"     ,aNF[19]											,Nil} )
				aAdd( aItens , {"F1_SERIORI"   ,aNF[20]											,Nil} )
				aAdd( aItens , {"F1_TES"       ,cTes											,Nil} )
				aAdd( aItens , {"F1_CF"        ,Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")  ,Nil} )
				IF aNF[17] =="P" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
					If lExibErro
						MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
					EndIf
					If Valtype(oRegua)=="O"
						oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
					EndIf
					Return .F.
				EndIF
			Else
				//->> Complemento de ICM
				IF aNF[17] =="I" .and. aNF[11,nX,05] == aNF[11,nX,06] .and. !EMPTY(aNF[19])
					aAdd( aItens , {"F1_NFORI"     ,aNF[19]												,Nil} )
					aAdd( aItens , {"F1_SERIORI"   ,aNF[20]												,Nil} )
					aAdd( aItens , {"F1_TES"       ,cTesE												,Nil} )
					aAdd( aItens , {"F1_CF"        ,Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")		,Nil} )
					IF aNF[17] =="I" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
						If lExibErro
							MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
						EndIf
						If Valtype(oRegua)=="O"
							oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
						EndIf
						Return .F.
					ENDIF
				ELse
					//->> Devolucoes
					IF aNF[17] =="D" .and. !EMPTY(aNF[19])
						aAdd( aItens , {"F1_NFORI"     ,aNF[19]											,Nil} )
						aAdd( aItens , {"F1_SERIORI"   ,aNF[20]											,Nil} )
						aAdd( aItens , {"F1_TES"       ,cTesE											,Nil} )
						aAdd( aItens , {"F1_CF"        ,Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")	,Nil} )
						IF aNF[17] =="D" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
							If lExibErro
								MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
							EndIf
							If Valtype(oRegua)=="O"
								oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
							EndIf
							Return .F.
						Endif
						
					Else
						//->> Beneficiamento
						IF aNF[17] =="B" .and. !EMPTY(aNF[19])
							aAdd( aItens , {"F1_NFORI"     ,aNF[19]												,Nil} )
							aAdd( aItens , {"F1_SERIORI"   ,aNF[20]												,Nil} )
							aAdd( aItens , {"F1_TES"       ,cTesE												,Nil} )
							aAdd( aItens , {"F1_CF"        ,Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")	,Nil} )
							IF aNF[17] =="B" .and. aNF[11,nX,05] > aNF[11,nX,06] .and. !EMPTY(aNF[19]) .OR. EMPTY(aNF[20])
								If lExibErro
									MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cNumero)
								EndIf
								If Valtype(oRegua)=="O"
									oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
								EndIf
								Return .F.
							Endif
						Endif
					Endif
				Endif
			Endif
		EndIf	
	Next nX                  
	
	If Empty(aNF[12]).OR.lVldTes 
		//-->> Processa a rotina automatica MATA410 - Pedido de Vendas
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItemNF,3)
	
		If lMsErroAuto
			DisarmTransaction()
			If lExibErro
				MostraErro()
			EndIf
			lRetorno := .F.
		Else	
			nProd++
			lRetorno := .T.
		EndIf
	Else
		//-->> Processa a rotina automatica MATA920 - Doc. Saida
		MsExecAuto( {|x,y,z| Mata920(x,y,z)}, aCabec, aItemNF , 3 )
		
		If lMsErroAuto
			DisarmTransaction()
			If lExibErro
				MostraErro()
			EndIf
			lRetorno := .F.
		Else
			nProd++
			lRetorno := .T.
			GeraTitulo(cTesS,aNF[09],aNF[13],cNumero,cSerie,aNF[14],SA1->(A1_COD+A1_LOJA))
			DbselectArea("SF2")
			DBSetOrder(1)
			
			//--> Grava a Chave da NFe
			If dbSeek(xFilial('SF2')+cNumero+cSerie+SA1->(A1_COD+A1_LOJA))
				RecLock("SF2",.F.)
				F2_CHVNFE := aNF[10]
				F2_COND   := aNF[13]
				F2_DUPL   := cNumero
				MSUnlock()
				/*
					**	LDB - 13/04/2015 - Contabilizacao On Line - Cabeçalho nota de Saida
				*/                                               
				If lContOnLine .And. lLancPad20                                            
				   nTotal += DetProva( nHdlPrv , "620" , _cFuncao , cLoteFat )
				EndIf				
			EndIf
			
			//-> Grava Custo Medio do Produto
			SD2->(dbSetOrder(3))
			If SD2->(dbSeek(xFilial("SD2")+cNumero+cSerie))
				While !SD2->(Eof()) .And. xFilial("SD2")+cNumero+cSerie == SD2->(D2_FILIAL+D2_DOC+D2_SERIE)
					RecLock("SD2",.F.)
					SD2->D2_ORIGLAN := "  "
					SD2->D2_CUSTO1  := Posicione("SB2",1,xFilial("SB2")+SD2->D2_COD,"B2_CM1") * SD2->D2_QUANT
					SD2->(MsUnLock())
					
					/*
						**	LDB - 13/04/2015 - Contabilizacao On Line - Itens da nota de Saida
					*/                                               
					If lContOnLine .And. lLancPad10                                            
				   		nTotal += DetProva( nHdlPrv , "610" , _cFuncao , cLoteFat )
					EndIf					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ajuste realizado por Marcelo Celi - Akron      ³
					//³no dia 26/03/2013 *****************************³
					//³Observacao: Mata920 nao trata poder 3.		  ³
					//³Atualiza Poder de Terceiro apos chamada		  ³
					//³ da rot. automatica. 						  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Posicione("SF4",1,xFilial("SF4")+cTesS,"F4_PODER3")<>"N"
						RecLock("SD2")
						MaAtuSB6("SD2",3)
					EndIf
					
					SD2->(dbSkip())
				EndDo
			EndIf
			
			DbselectArea("SF3")
			DBSetOrder(5)
			If DbSeek(xFilial('SF3') + cSerie + cNumero + SA1->(A1_COD+A1_LOJA))
				While !SF3->(Eof()) .AND. F3_NFISCAL == cNumero .AND. F3_SERIE == cSerie
					If F3_CFO ==  Posicione("SF4",1,xFilial("SF4")+cTesS,"F4_CF")
						RecLock("SF3",.F.)
						F3_CHVNFE := aNF[10]
						MSUnlock()
					EndIf
					SF3->(dbSkip())
				EndDo
			EndIf
			
			DbselectArea("SFT")
			DBSetOrder()
			If DbSeek(xFilial('SFT') + 'S' + PadR(cSerie,Tamsx3("F2_SERIE")[1]) + cNumero + SA1->(A1_COD+A1_LOJA))
				RecLock("SFT",.F.)
				FT_CHVNFE := aNF[10]
				MSUnlock()
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajuste realizado por Marcelo Celi - Akron      ³
			//³no dia 02/02/2012 *****************************³
			//³Observacao: Mata920 nao trata estoque.		  ³
			//³Baixa estoque apos chamada da rot. automatica. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//IIf(FindFunction("u_KPMEsDSai"),u_KPMEsDSai(),.T.)//RRP - 06/08/2014 - Aguardando alteração.
			
			SA1->(dbCloseArea())
			SE1->(dbCloseArea())
			SF2->(dbCloseArea())
			SD2->(dbCloseArea())
			
		Endif
		PutMv( "MV_AUTOISS", cAUTOISS )
	EndIf	
EndIf

dDatabase := dDataAnt

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  ClassNf   ºAutor  ³Larson Zordan       º Data ³ 11/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Solicita a TES, a Cond Pgto e Natureza de maneira sinteticaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Keeptrue                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ClassNf(aNF,aNFS,oRegua)
Local aNFOrig 		:= aNF
Local aNFSOrig 		:= aNFS

Local nX			:= 1
Local nPosiCli		:= 0
Local aColsNFS		:= {}
Local aHeaderNFS	:= {}

Local aColsNF		:= {}
Local aHeaderNF		:= {}

Local aColsLG 		:= {}
Local aHeaderLG 	:= {}

Local aColsLGX 		:= {}
Local aHeaderLGX	:= {}

Local aNFNorm		:= {}
Local oDlg
Local oGetNf, oGetNFS
Local nOpcA			:= 0
Local cBox1			:= ""
Local lRet          := .F.
Local nX, nY
Local cConta		:= ""

aNF := {}
aNFS:= {}

cBox1 := "N=Normal;D=Devolucao;B=Beneficiamento;I=Compl. ICMS;P=Compl. IPI;C=Compl. Preço/Frete"

aAdd(aHeaderNF,{ "TipoTES"					,"TPNOTA"	,"@!"							,10				  			,0							,""							   							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ ""						,"ENABLE"	,"@BMP"							,2							,0							,														/*VALIDACAO*/,		,"C",		,"V",	,,,"V"} )
aAdd(aHeaderNF,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Conta Contábil"		,"CONTA"	,"@!"							,Tamsx3("A1_CONTA")		[1]	,0							,"Vazio().or. Ctb105Cta()"	 							/*VALIDACAO*/,""	,"C","CT1"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_KPXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"			   							/*VALIDACAO*/,""	,"C","SE4"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Natureza"				,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')" 							/*VALIDACAO*/,""	,"C","SED"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Fornec. p/ Import."	,"FORNECIMP",PesqPict("SA2","A2_COD")		,Tamsx3("A2_COD")		[1]	,Tamsx3("A2_COD")		[2]	,"Vazio().or.Existcpo('SA2')" 							/*VALIDACAO*/,""	,"C","SA2"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Cliente p/ Export."	,"CLIENTIMP",PesqPict("SA1","A1_COD")		,Tamsx3("A1_COD")		[1]	,Tamsx3("A1_COD")		[2]	,"Vazio().or.Existcpo('SA1')" 							/*VALIDACAO*/,""	,"C","SA1"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Tipo Nota"			,"TIPO"		,"@!"							,1							,0							,""                 		 							/*VALIDACAO*/,""	,"C",""		,"R",cBox1	,,,"A"} )
aAdd(aHeaderNF,{ "Vr. Despesas"			,"VLDESP"	,PesqPict("SD1","D1_TOTAL")		,Tamsx3("D1_TOTAL")		[1]	,Tamsx3("D1_TOTAL")		[2]	,""														/*VALIDACAO*/,""	,"N",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Nota Origem"			,"NFORIG"	,PesqPict("SD1","D1_NFORI")		,Tamsx3("D1_NFORI")		[1]	,Tamsx3("D1_NFORI")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Serie Origem"			,"SERIORI"	,PesqPict("SD1","D1_SERIORI")	,Tamsx3("D1_SERIORI")	[1]	,Tamsx3("D1_SERIORI")	[2]	,""						   								/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "DIRF - Cód.Retenção"	,"CODRET"	,PesqPict("SE2","E2_CODRET")	,Tamsx3("E2_CODRET")	[1]	,Tamsx3("E2_CODRET")	[2]	,""						   								/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Data da Emissão"    	,"DATEMI"	,PesqPict("SF1","F1_EMISSAO")	,Tamsx3("F1_EMISSAO")	[1]	,Tamsx3("F1_EMISSAO")	[2]	,""							 							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Data da Digitação"   	,"DATDIG"	,PesqPict("SF1","F1_DTDIGIT")	,Tamsx3("F1_DTDIGIT")	[1]	,Tamsx3("F1_DTDIGIT")	[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "CFOP"           		,"CFOP"  	,"@!"							, 4							,0							,""						  								/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "NAT. OPER."     		,"NATOP" 	,"@!"							,30							,0							,""							 							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""							 							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )

SA1->(dbSetOrder(3)) // por cnpj
For nX:= 1 To Len(aNFOrig)
	//aAdd(aColsNF,{aNFOrig[nX,01], StatusNFe(@aNFOrig[nX],@aColsLG,1,aNFOrig[nX,26],aNFOrig[nX,27],aNFOrig[nX,28]), aNFOrig[nX,02], aNFOrig[nX,03], aNFOrig[nX,04], aNFOrig[nX,12], aNFOrig[nX,13], aNFOrig[nX,14], aNFOrig[nX,15], aNFOrig[nX,16], aNFOrig[nX,17], aNFOrig[nX,18], aNFOrig[nX,19], aNFOrig[nX,20], aNFOrig[nX,21], aNFOrig[nX,05], aNFOrig[nX,23], aNFOrig[nX,24], aNFOrig[nX,25], aNFOrig[nX,22], .F.})
	//RRP - 20/03/2015 - Pegando a conta contabil caso o cliente exista
	cConta:= ""
	If aNFOrig[nX,1] == 'ENTRADA'
		If SA2->(dbSeek(xFilial("SA2")+Alltrim(aNFOrig[nX,4])))
			cConta:= SA2->A2_CONTA
		EndIf	
	Else
		If SA1->(dbSeek(xFilial("SA1")+Alltrim(aNFOrig[nX,4])))
			cConta:= SA1->A1_CONTA
		EndIf
	EndIf
	aAdd(aColsNF,{aNFOrig[nX,01], StatusNFe(@aNFOrig[nX],@aColsLG,1,aNFOrig[nX,26],aNFOrig[nX,27],aNFOrig[nX,28]), aNFOrig[nX,02], aNFOrig[nX,03], aNFOrig[nX,04],IIF(EMPTY(cConta),MV_PAR07,cConta), IIF(EMPTY(aNFOrig[nX,12]),MV_PAR04,aNFOrig[nX,12]), IIF(EMPTY(aNFOrig[nX,13]),MV_PAR05,aNFOrig[nX,13]), IIF(EMPTY(aNFOrig[nX,14]),MV_PAR06,aNFOrig[nX,14]), aNFOrig[nX,15], aNFOrig[nX,16], aNFOrig[nX,17], aNFOrig[nX,18], aNFOrig[nX,19], aNFOrig[nX,20], aNFOrig[nX,21], aNFOrig[nX,05], aNFOrig[nX,23], aNFOrig[nX,24], aNFOrig[nX,25], aNFOrig[nX,22], .F.})
Next nX
SA1->(DbCloseArea())


//->> Keeptrue
aAdd(aHeaderNFS,{ "Tipo"				,"TPNOTA"	,"@!"							,10							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ ""					,"ENABLE"	,"@BMP"							,2							,0							,								/*VALIDACAO*/,		,"C",		,"V",		,,,"V"} )
aAdd(aHeaderNFS,{ "Nota Fiscal"	  		,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_KPXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"				/*VALIDACAO*/,""	,"C","SE4"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Natureza"			,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')"	/*VALIDACAO*/,""	,"C","SED"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )

For nX:= 1 To Len(aNFSOrig)
	aAdd(aColsnfs,{aNFSOrig[nX,01],StatusNFe(@aNFsOrig[nX],@aColsLG,2),aNFSOrig[nX,02],aNFSOrig[nX,03],aNFSOrig[nX,12,11,1],aNFSOrig[nX,20],aNFSOrig[nX,21],aNFSOrig[nX,22],aNFSOrig[nX,24],.F.})
Next nX


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Log de Ocorrencias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aHeaderLG,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Fornecedor/Cliente"	,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Ocorrência"			,"OCORR"	,"@!"							,100              		   	,0               		    ,""								/*VALIDACAO*/,""	,"C",""   	,"R",		,,,"V"} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Log de Arquivo     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aHeaderLGX,{ "Tipo Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLGX,{ "Ocorrência"			,"OCORR"	,"  "							,40               		   	,0               		    ,""								/*VALIDACAO*/,""	,"C",""   	,"R",		,,,"V"} )
aAdd(aHeaderLGX,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )

DEFINE MSDIALOG oDlg TITLE "Classificação das Notas Fiscais" FROM 0,0 To 500,900 PIXEL Style 1 Color CLR_BLACK,CLR_WHITE

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.,.T.)

oFWLayer:addLine("L1",100,.F.)
oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
oFWLayer:AddWindow("C1"		,"oPanel","Classificação das Notas Fiscais"	,100,.F.,.T.,,"L1",{ || })
oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")

oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
oPanel1:Align := CONTROL_ALIGN_TOP

oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL

@ 06,05	Say "Classifique as notas abaixo conforme suas caracteristicas originais."	OF oPanel1 PIXEL
@ 18,05 Say "Obs: Os documentos de entrada sem TES serão geradas como PrENotas."	OF oPanel1 PIXEL

@ 06,330 BitMap ResName "ENABLE"   				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 06,342 Say "XML Válido para Importar"			Size 120,10 OF oPanel1 PIXEL
@ 15,330 BitMap ResName "DISABLE"  				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 15,342 Say "Cliente/Forncedor Não Cadastrado"	Size 120,10 OF oPanel1 PIXEL
@ 24,330 BitMap ResName "BR_PRETO" 				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 24,342 Say "XML com Chave/N.Fiscal Inválida"	Size 120,10 OF oPanel1 PIXEL

oFolder := TFolder():New(0,0,{ "NF de Produtos","NF de Serviços","Log de Ocorrências","Log de Arquivos"},{},oPanel2,,,, .T., .F.,(oPanel2:NCLIENTWIDTH/2)-2,(oPanel2:NCLIENTHEIGHT/2)-2,,.T.)

oGetNf:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oFolder:aDialogs[1],aHeaderNF,aColsNF)
oGetNf:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetNf:OBROWSE:NFREEZE := 1


oGetNFS:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oFolder:aDialogs[2],aHeaderNFS,aColsNFS)
oGetNFS:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetNFS:OBROWSE:NFREEZE := 1

oGetLG:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oFolder:aDialogs[3],aHeaderLG,aColsLG)
oGetLG:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetLG:OBROWSE:NFREEZE := 1

oGetLGX:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oFolder:aDialogs[4],aHeaderLGX,aLogXML)
oGetLGX:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetLGX:OBROWSE:NFREEZE := 1

ACTIVATE MSDIALOG oDlg ON INIT KpmgBarMnu(oDlg,	{|| (nOpcA:=1,oDlg:End())}, {|| (nOpcA:=0,oDlg:End())}, {},{},.F.,.F.,.F.,0,.T.) CENTER

If nOpcA==1
	lRet := .T.
	
	//--> Notas de Produtos
	oRegua:SetRegua2(Len(oGetNf:aCols))
	For nX:=1 to Len(oGetNf:aCols)
		oRegua:IncRegua2("Gravando Informações das Notas de Produtos...")
		If !oGetNf:aCols[nX,Len(oGetNf:aCols[nX])] .And. !Empty(oGetNf:aCols[nX,1]) .And. oGetNf:aCols[nX,2]:cNAME <> "BR_PRETO"
			aAdd(aNF,aNFOrig[nX])
			nY := Len(aNF)                   
//			aNF[nY,12] := oGetNf:aCols[nX,05]
			aNF[nY,12] := oGetNf:aCols[nX,07]
			aNF[nY,13] := oGetNf:aCols[nX,08]
			aNF[nY,14] := oGetNf:aCols[nX,09]
			aNF[nY,15] := oGetNf:aCols[nX,10]
			aNF[nY,16] := oGetNf:aCols[nX,11]
			aNF[nY,17] := oGetNf:aCols[nX,12]
			aNF[nY,18] := oGetNf:aCols[nX,13]
			aNF[nY,19] := oGetNf:aCols[nX,14]
			aNF[nY,20] := oGetNf:aCols[nX,15]
			aNF[nY,21] := oGetNf:aCols[nX,19]
			aNF[nY,23] := oGetNf:aCols[nX,18]
			aNF[nY,22] := oGetNf:aCols[nX,21]
			
			//RRP - 19/03/2015 - Incluindo a conta contábil e natureza do cliente ou fornecedor que serEcadastrado no array aNewClie
			If Len(aNewClie)>0
				//Comparando o CPF ou CNPJ
				nPosiCli := aScan( aNewClie, { |x| alltrim(x[11]) == Alltrim(oGetNf:aCols[nX,5])})
				If nPosiCli>0
					aAdd(aNewClie[nPosiCli],oGetNf:aCols[nX,06]) //posição 14 do array aNewClie com a Conta Contábil
					aAdd(aNewClie[nPosiCli],oGetNf:aCols[nX,09]) //posição 15 do array aNewClie com a Natureza
				EndIf				
			EndIf
			
		EndIf
	Next nX 
	
	//--> Notas de Servico
	oRegua:SetRegua2(Len(oGetNFS:aCols))
	For nX:=1 to Len(oGetNFS:aCols)
		oRegua:IncRegua2("Gravando Informações das Notas de Serviços...")
		If !oGetNFS:aCols[nX,Len(oGetNFS:aCols[nX])] .And. !Empty(oGetNFS:aCols[nX,1]) .And. oGetNFS:aCols[nX,2]:cNAME <> "BR_PRETO"
			aAdd(aNFS,aNFSOrig[nX])
			nY := Len(aNFS)
			aNFS[nY,20] := oGetNFS:aCols[nX,05]
			aNFS[nY,21] := oGetNFS:aCols[nX,06]
			aNFS[nY,22] := oGetNFS:aCols[nX,07]
		EndIf
	Next nX
	
	//--> Grava Novos Clientes
	oRegua:SetRegua2(Len(aNewClie))
	//RRP - 17/03/2015 - Ajuste para gravar diversos clientes, pois estava gravando apenas o cliente 1 do array aNewClie.
	For nX := 1 To Len(aNewClie)
		aNewAux:={}
		oRegua:IncRegua2("Criando Novos Clientes...")
		AADD(aNewAux,aNewClie[nX])
		GetCliente(aNewAux)
	Next nX
	
	//--> Grava Novos Fornecedores
	oRegua:SetRegua2(Len(aNewForn))
	//RRP - 19/03/2015 - Ajuste para gravar diversos fornecedores, pois estava gravando apenas o cliente 1 do array aNewForn.
	For nX := 1 To Len(aNewForn)
		aNewAux:={}
		oRegua:IncRegua2("Criando Novos Fornecedores...")
		AADD(aNewAux,aNewForn[nX])
		GetFornece(aNewAux)
	Next nX
	
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ StatusNFe  ³ Autor ³ Larson Zordan        ³ Data ³17/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Valida algumas informcaoes dos dados dos XML                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ StatusNFe(ExpA1,ExpA2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpA1 : Dados do XML (uma nota)                             ³±±
±±³           ³ ExpA2 : Dados do Log de Ocorrencias                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ ExpO1 - Verde   : Habilatado para Importar                  ³±±
±±³           ³         Vermelho: Nao Habilatado para Importar (Log Ocorr.) ³±±
±±³           ³         Preto   : Chave NF-e invalida                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ BALASKA                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function StatusNFe(aNF,aLogs,nTipo,lChv,cMsgChv,cUF)
Local oCor
Local aRet      := {}
Local nX
Default lChv    := .T.
Default cMsgChv := ""
Default cUF     := ""

If nTipo == 1
	
	If !lChv
		//--> Chave Invalida
		oCor := LoadBitmap( GetResources(), "BR_PRETO" )
		aAdd( aLogs , { aNF[2], aNF[3], aNF[4], cMsgChv, .F. })
	Else
		oCor := LoadBitmap( GetResources(), "ENABLE" )
		
		If Left(aNF[1],1) == "E"
			//--> Valida o Fornecedor
			If cUF == "EX"	//--> NF Importacao
				SA2->(dbSetOrder(1))
			Else
				SA2->(dbSetOrder(3))
			EndIf	
			If !SA2->(dbSeek(xFilial("SA2")+aNF[4]))
				oCor := LoadBitmap( GetResources(), "DISABLE" )
				aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Fornecedor Nao Cadastrado", .F. })
			Else
				aNF[13] := SA2->A2_COND
				aNF[14] := SA2->A2_NATUREZ
				
				//--> Valida a Amarracao Produto x Fornecedor
				If cUF <> "EX"
					If mv_par02 == 1
						//--> Busca so no Cad. Produto SB1
						For nX := 1 To Len(aNF[11])
							If !SB1->(dbSeek( xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
								oCor := LoadBitmap( GetResources(), "BR_PRETO" )
								aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto Nao Cadastrado", .F. })
								Exit
							EndIf
						Next nX	

					ElseIf mv_par02 == 2
						//--> Busca so no Cad. Produto X Fornecedor (SA5)
						For nX := 1 To Len(aNF[11])
							If !(SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO)))
								oCor := LoadBitmap( GetResources(), "BR_PRETO" )
								aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto X Fornecedor Nao Cadastrado", .F. })
								Exit
							EndIf
						Next nX	

					ElseIf mv_par02 == 3
						//--> Busca em Ambos
						For nX := 1 To Len(aNF[11])
							If !SB1->(dbSeek( xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
								If !(SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO)))
									oCor := LoadBitmap( GetResources(), "BR_PRETO" )
									aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto X Fornecedor Nao Cadastrado", .F. })
									Exit
								EndIf
							EndIf	
						Next nX	
					EndIf	

				Else
					For nX := 1 To Len(aNF[11])
						If !SB1->(dbSeek( xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
							oCor := LoadBitmap( GetResources(), "BR_PRETO" )
							aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto Nao Cadastrado", .F. })
							Exit
						EndIf
					Next nX	
				EndIf
				
				//--> Valida a Nota Fiscal de Entrada
				SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(dbSeek(xFilial("SF1")+aNF[2]+PadR(aNF[3],3)+SA2->(A2_COD+A2_LOJA)))
					oCor := LoadBitmap( GetResources(), "BR_PRETO" )
					aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Nota Fiscal Ja Cadastrada", .F. })
				EndIf
			EndIf
		Else
			SA1->(dbSetOrder(3))
			If !SA1->(dbSeek(xFilial("SA1")+aNF[4]))
				oCor := LoadBitmap( GetResources(), "DISABLE" )
				aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Cliente Nao Cadastrado", .F. })
			Else
				aNF[13] := SA1->A1_COND
			   	aNF[14] := SA1->A1_NATUREZ
				
				//--> Valida a Nota Fiscal de Saida
				SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA+F2_TIPO
				If SF2->(dbSeek( xFilial("SF2")+aNF[2]+PadR(aNF[3],3) ))
					oCor := LoadBitmap( GetResources(), "BR_PRETO" )
					aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Nota Fiscal Ja Cadastrada", .F. })
				EndIf
				
				//--> Valida se o Produto Existe
				SB1->(dbSetOrder(1))
				For nX := 1 To Len(aNF[11])
					If !SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
						oCor := LoadBitmap( GetResources(), "BR_PRETO" )
						aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto Nao Cadastrado", .F. })
						Exit
					EndIf
				Next nX	
			EndIf
		EndIf
	EndIf
	
EndIf

If nTipo == 2
	//--> Chave Valida
	oCor := LoadBitmap( GetResources(), "ENABLE" )
	
	//--> Valida o Fornecedor
	If Left(aNF[1],1) == "E"
		SA2->(dbSetOrder(3))
		If !SA2->(dbSeek(xFilial("SA2")+aNF[12,11,1]))
			oCor := LoadBitmap( GetResources(), "DISABLE" )
			aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Fornecedor Nao Cadastrado", .F. })
		Else
			aNF[20] := SA2->A2_COND
			aNF[21] := SA2->A2_NATUREZ
			
			//--> Valida a Nota Fiscal de Entrada
			SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If SF1->(dbSeek(xFilial("SF1")+aNF[2]+PadR(aNF[3],3)+SA2->(A2_COD+A2_LOJA)))
				oCor := LoadBitmap( GetResources(), "DISABLE" )
				aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Nota Fiscal Ja Cadastrada", .F. })
			EndIf
			
		EndIf
	Else
		SA1->(dbSetOrder(3))
		If !SA1->(dbSeek(xFilial("SA1")+aNF[13,11,1]))
			oCor := LoadBitmap( GetResources(), "DISABLE" )
			aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Cliente Nao Cadastrado", .F. })
		Else
			aNF[20] := SA1->A1_COND
			aNF[21] := SA1->A1_NATUREZ
			
			//--> Valida a Nota Fiscal de Saida
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA+F2_TIPO
			If SF2->(dbSeek(xFilial("SF2")+aNF[2]+PadR(aNF[3],3) ))
				oCor := LoadBitmap( GetResources(), "DISABLE" )
				aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Nota Fiscal Ja Cadastrada", .F. })
			EndIf
			
		EndIf
	EndIf
EndIf

Return(oCor)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³KpmgBarMnu  ºAutor  ³Larson Zordan       º Data ³ 11/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Barra de Menu.											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Keeptrue                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function KpmgBarMnu(oDlg,bOk,bCancel,aButtons,aButText,lIsEnchoice,lSplitBar,lLegenda,nDirecao,lBGround)
Local nX 		:= 0
Local xAlinha 	:= ""

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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ ValNfeSef  ³ Autor ³ Larson Zordan        ³ Data ³15/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Valida   a chave da NFe digitada na SEFAZ                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³  ValNfeSef(ExpC1,ExpC2,ExpC3,ExpL1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 : Chave da NFe de 44 posicoes a ser validada          ³±±
±±³           ³ ExpC2 : Formulario Proprio                                  ³±±
±±³           ³ ExpC3 : Chave da NFe de 44 posicoes a ser validada          ³±±
±±³           ³ ExpL1 : .T. Exibe as mensagens dos erros   .F. Nao Exibe    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ ExpA1 : [1] .T. Chave Valida   .F. Chave Nao Valida         ³±±
±±³           ³         [2] Mensagem do retorno da consulta                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function ValNfeSef(cChave,cFormul,cEspecie,lMsg)
Local cChaveNFe  := cChave
Local cCodRet	 := "Codigo de retorno: "
Local cIdEnt   	 := ""
Local cMensRet   := "Mensagem de retorno: "
Local cProt		 := "Protocolo: "
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMsgErro   := ""

Local lConChv 	 := .T. //GetNewPar("MV_CHVNFE",.F.)
Local lDigChv 	 := .T. //GetNewPar("MV_DCHVNFE",.F.)
Local lRet	  	 := .F.

Private oWS

Default cFormul  := "N"
Default cEspecie := "SPED"
Default lMsg     := .F.

If (lDigChv .and. cFormul == "N" .and. AllTrim(cEspecie) == "SPED") .Or. (lDigChv .and. cFormul == "N" .and. AllTrim(cEspecie) == "CTE")
	
	If lConChv
		If IsReady(cURL)
			//Obtem o codigo da entidade
			oWS := WsSPEDAdm():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
			oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
			oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
			oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
			oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
			oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
			oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
			oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
			oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
			oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
			oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
			oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
			oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
			oWS:oWSEMPRESA:cCEP_CP     := Nil
			oWS:oWSEMPRESA:cCP         := Nil
			oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
			oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
			oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
			oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
			oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
			oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
			oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cINDSITESP  := ""
			oWS:oWSEMPRESA:cID_MATRIZ  := ""
			oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
			oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
			
			If oWs:ADMEMPRESAS()
				cIdEnt  := oWs:cADMEMPRESASRESULT
			Else
				If lMsg
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
				EndIf
				cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			EndIf
			
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT      := cIdEnt
			ows:cCHVNFE		 := cChaveNFe
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
			
			If oWs:ConsultaChaveNFE()
				If Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMsgErro := "A chave digitada não foi encontrada na Sefaz, favor verificar"
					If lMsg
						MsgAlert("A chave digitada não foi encontrada na Sefaz, favor verificar")
					EndIf
					lRet := MSGYESNO( "A chave digitada não foi encontrada na Sefaz."+CRLF+CRLF+"Deseja incluir a nota mesmo assim ?", "HLB BRASIL" )
				ElseIf AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "100"
					cMsgErro := cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE + "; " + cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE + "; " + cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
					//CAS 27/09/2019 - Comentário do bloco abaixo para não exibir Mensagem, já que a chave é válida
					/*If lMsg
						If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
							cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
							cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF+CRLF+CRLF+;
							"Deseja inserir a chave mesmo assim?")*/
							lRet := .T.
						/*Else
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					EndIf*/
				Else
					lRet := .T.
					cMsgErro := cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE + "; " + cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE + "; " + cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
					If lMsg
						MsgAlert(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
						cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
						cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					EndIf
				EndIf
			Else
				cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				If lMsg
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
				EndIf
				If len(Alltrim(cChaveNFE)) > 0 .and. len(Alltrim(cChaveNFE)) < 44
					cMsgErro := "A chave informada Emenor que o permitido e impossibilita a consulta na Sefaz."
					If lMsg
						If MsgNoYes("A chave informada Emenor que o permitido e impossibilita a consulta na Sefaz."+CRLF+CRLF+"Deseja APAGAR o conteúdo do campo para inserir uma nova chave?")
							lRet := .F.  //Limpa o campo caso tenha uma chave menor
						Else
							lRet := .T.
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					lRet := .T.
				EndIf
			EndIf
		Else
			cMsgErro := "TSS Inativo"
			If lMsg
				Help(" ",1,"TSSINATIVO")
			EndIf
			lRet := .F.
		EndIf
	Else
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf

Return({lRet,cMsgErro})

  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³  IsReady   ³ Autor ³ Larson Zordan        ³ Data ³15/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Verifica se a conexao com o TSS pode ser estabelecida       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ IsReady(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 : URL da SEFAZ                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IsReady(cURLTss)
Local oWS
Local lRetorno := .F.

If !Empty(cURLTss) .And. !PutMV("MV_SPEDURL",cURLTss)
	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial( "SX6" )
	SX6->X6_VAR     := "MV_SPEDURL"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "URL SPED NFe"
	MsUnLock()
	PutMV("MV_SPEDURL",cURL)
EndIf

SuperGetMv() //Limpa o cache de parametros - nao retirar

DEFAULT cURLTss  := PadR(GetNewPar("MV_SPEDURL","http://"),250)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o servidor da Totvs esta no ar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWs := WsSpedCfgNFe():New()
oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURLTss)+"/SPEDCFGNFe.apw"

If oWs:CFGCONNECT()
	lRetorno := .T.
EndIf

Return(lRetorno) 

/*
Funcao      : VldTES()
Parametros  : cTes
Retorno     : lRet
Objetivos   : Valida se a TES atualiza estoque ou não.
Autor       : Renato Rezende
Data/Hora   : 15/08/2014
*/
*--------------------------------*
 Static Function VldTES(cTes,lMsg)
*--------------------------------*

Local lRet 		:= .T. 

ChkFile("SF4")
SF4->(DbSetOrder(1))
If SF4->(DbSeek(xFilial("SF4")+cTes))
   
	If SF4->F4_ESTOQUE == "S"         
                                
 		If lMsg 
 			MsgInfo("Essa TES atualiza estoque. O Xml serEgravado como pedido!","HLB BRASIL")
 		EndIf
 
 		lVldTes := .T.
 		
 	Else                
 		
 		//TLM 20141024 - Empresa BROWN-FORMAN - Chamado 022161  
 		If cEmpAnt == "NN"
 			lVldTes := .T.  
 		Else  
 			lVldTes := .F.	
 		EndIf
 	EndIf
EndIf

Return lRet

/*
Função.........: SelTpLanc
Objetivo.......: Selecionar lançamento On Line ou Off Line na contabilização das notas de saida
Autor..........: Leandro Diniz de Brito
Data...........: 13/04/2015
*/
*--------------------------------*
Static Function SelTpLanc
*--------------------------------*
Local oDlg                                                                 
Local oRadio
Local cVersao:=""

Local bOk     := { || lOk := .T. , oDlg :End() }
Local bCancel := { || lOk := .F. , oDlg :End() }              

Local lOk    := .F.                                                           
Local cTpLanc := Space( 10 )

Local nItem := 2

//RRP - 03/12/2018 - Ajuste posição da janela na versão 12.
IF UPPER(Alltrim(SubStr(GetEnvServer(),1,3))) == "P11"
	cVersao:= '11'
Else
	cVersao:= '12'
EndIf

Define MSDialog oDlg Title "Selecione o tipo de contabilizacao" From 1,1 To 150,350 Of oMainWnd Pixel

If cVersao == '11'
	@05,10 Say "Contabiliza" Size 70,10 Of oDlg Pixel
	@05,90 COMBOBOX cTpLanc ITEMS { "On-Line" , "Off-Line" }   Size 80,10  Of oDlg Pixel
	                                                   
	@20,10 Say "Mostra Lcto.?" Size 70,10 Of oDlg Pixel
	@20,90 RADIO oRadio VAR nItem SIZE 100,09 PROMPT 'Sim', 'Nao' OF oDlg
Else
	@05+23,10 Say "Contabiliza" Size 70,10 Of oDlg Pixel
	@05+23,90 COMBOBOX cTpLanc ITEMS { "On-Line" , "Off-Line" }   Size 80,10  Of oDlg Pixel
	                                                   
	@20+23,10 Say "Mostra Lcto.?" Size 70,10 Of oDlg Pixel
	@20+23,90 RADIO oRadio VAR nItem SIZE 100,09 PROMPT 'Sim', 'Nao' OF oDlg
EndIf

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered

If ( lOk  )

	lContOnLine := ( AllTrim( cTpLanc ) == "On-Line" )
	lMostraLanc := ( nItem == 1 ) .And. lContOnLine

EndIf

Return( lOk )
