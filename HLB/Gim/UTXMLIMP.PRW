#Include "Protheus.Ch"
#Include "Tbiconn.Ch"
#Include "Shell.Ch"
#Include "Ap5Mail.ch"

Static aLog	:= {}

//-------------------------------------------------------------------------------------------------------------//
//Wederson L. Santana - HLB BRASIL - 19/02/2020
//Específico - Fiscal - G.I.M. 
//-------------------------------------------------------------------------------------------------------------//
//Importação XML
//-------------------------------------------------------------------------------------------------------------//

User Function UTXmlImp(cTes)
Local cPerg  		:= "UTXMLIMP1"+Space(01)
Local cFunction		:= "UTMLIMP"
Local cTitle		:= "Importação de XML"
Local bProcess		:= { |oSelf| ImportarNf(oSelf) }                   
Local cDescription	:= "Testa rotina irá gerar notas de saida de produtos com base na importação de XML. G.I.M GIOVANNONI "
Local cArqNtx 		:= CriaTrab( NIL, .F. )

Private lVldTes		:= .F.
Private lMsg		:= .T.           
Private cEspecieDoc := "SPED"

Default cTes := ""
If !EMPTY(cTes)
	Return VldTES(cTes,lMsg)
EndIf

Private nServ   := 0
Private nProd   := 0
Private aLogXml := {}

Private aLogErro := {}

Private cDirXmlUT:=""
Private cArqXmlUT:=""

Private cNumNF   :=""
Private cSerieNF :=""

Private oNFe

If cEmpAnt == "UT" 

//->> Criacao do Indice Temporario
IndRegua( "SA5", cArqNtx, "A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF", , , "Selec.registros..." )

fCriaPerg(cPerg)

tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg)

//->> Exclusao do Indice Temporario
DbSelectArea( "SA5" )
SA5->(DbSetOrder( 1 ))
fErase( cArqNtx + OrdBagExt() )
Else 
    MsgInfo("Específico para uso da empresa - G.I.M GIOVANNONI ","A T E N ? ? O")
EndIf

If Len(aLogErro)>0
    If MSGYESNO("Deseja imprimir detalhes da importação ?"," Importação XML - G.I.M.")
	   //MsgInfo("Em desenvolvimento.","A t e n ç ã o")
	   fImpLog()
	EndIf
EndIf

Return

Static Function fCriaPerg(_cPerg)
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}

AADD(aRegistros,{_cPerg,"01","Pasta Origem dos XML Prod/Serv      ?","","","mv_ch1","C",99,00,00,"G",""                          ,"Mv_Par01","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"02","TES                                 ?","","","mv_ch2","C",03,00,00,"G","Vazio().or.Existcpo('SF4')","Mv_Par02","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SF4","","","","",""})
AADD(aRegistros,{_cPerg,"03","Condição Pagamento                  ?","","","mv_ch3","C",03,00,00,"G","Existcpo('SE4')"           ,"Mv_Par03","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SE4","","","","",""})
AADD(aRegistros,{_cPerg,"04","Natureza                            ?","","","mv_ch4","C",10,00,00,"G","Vazio().or.Existcpo('SED')","Mv_Par04","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SED","","","","",""})
AADD(aRegistros,{_cPerg,"05","Conta Contábil                      ?","","","mv_ch5","C",20,00,00,"G","Vazio().or. Ctb105Cta()"   ,"Mv_Par05","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","CT1","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1)
For i := 1 to Len(aRegistros)
	If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
		While !RecLock("SX1",.T.)
		End
		For j:=1 to FCount()
			FieldPut(j,aRegistros[i,j])
		Next
		MsUnlock()
	Endif
Next i
dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])
Return(Nil)

Static Function ImportarNf(oRegua)
Local oXml
Local oDest
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
Private nParam01  := 0//MV_PAR02
Private lDev      := .F.

Private lLancPad10	:= VerPadrao( "610" )
Private lLancPad20	:= VerPadrao( "620" )    
Private lContOnLine := .F.                       
Private nTotal      := 0
Private cLoteFat    := If( SX5->( DbSeek( xFilial() + '09FAT' ) ) , AllTrim( SX5->X5_DESCRI ) , "FAT " ) 
Private nHdlPrv     := 0
Private cArquivo   
Private lMostraLanc := .F.
Private _cFuncao    :=  "MATA460"

cDirXML     := Alltrim(mv_par01)
aArqXml     := ExtraiArq(2,@cDirXml)

//If mv_par03 == 1
lExibErro := .F.
//EndIf

oRegua:SetRegua1(4)
If Len(aArqXml)>0
	oRegua:IncRegua1("Importando XML de Produtos ...")
	oRegua:SetRegua2(Len(aArqXml))
	For nX := 1 to Len(aArqXml)
		oRegua:IncRegua2("Lendo e Importando XML "+AllTrim(Str(nX))+"/"+AllTrim(Str(Len(aArqXml)))+"...")
		
		lNfe := .F.
		oXml := OpenXml(cDirXml+aArqXml[nX,01])
		If ValType(oXML)<> "O"
			Loop
		EndIf
		
		//--> Servico
		If XmlChildEx(oXML, "_COMPNFSE") <> Nil
			If oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT == SM0->M0_CGC
				ExtrNfServ(oXml,@aNFS,cDirXml+aArqXml[nX,01])
			Else
				aAdd( aLogXML , { "SERVIÇO","NFS-e não pertence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
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
					cNumNF:=StrZero(Val(oNFe:_IDE:_NNF:TEXT),Len(SF1->F1_DOC))
					cSerieNF:=oNFe:_IDE:_SERIE:TEXT
				endif
			Else
				aAdd( aLogXML , { "PRODUTO","NF-e não pertence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
				AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"NF-e não pertence a este cliente"})
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
	MsgAlert("Não foram encontrados arquivos XML para importação !")
	Return
EndIf

If Len(aNFS)+Len(aNF) > 0 .And. MsgYesNo("Confirma a geração das notas fiscais importadas pela leitura dos XMLs ?")
	oRegua:SetRegua1(Len(aNFS)+Len(aNF))
	
	If lLancPad10 .Or. lLancPad20
		If ( Ascan( aNFS , { | x | AllTrim( x[ 1 ] ) == "SAIDA" } ) > 0 ) .Or. ;
			( Ascan( aNF , { | x | AllTrim( x[ 1 ] ) == "SAIDA" } ) > 0 ) 	
			
			If !SelTpLanc()
				MsgStop( 'Operacao cancelada pelo usuario.' )
				Return
			EndIf	
			
		EndIf
	EndIf 
	
	//->> Notas de Servi?o
	If Len(aNFS)>0
		ProcXmlServ(lAuto,aNFS,@oRegua,lExibErro)
	EndIf
	
	//->> Notas de Produto
	If Len(aNF)>0
		ProcXmlProd(lAuto,aNF,@oRegua,lExibErro)
	EndIf
	
	If Len(aNFS)+Len(aNF) <> nServ+nProd
		//Aviso( "Aten??o" , "Foram submetidas a importa??o "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de servi?os, contudo foram importadas "+Alltrim(Str(nProd))+" de produtos e "+Alltrim(Str(nServ))+" de servi?os."+CRLF+"Vide Log de Eventos.", { 'Ok' } , 2 , "Importa??es de XML" )
	   Aviso( "Atenção" , "Foram submetidas a importação "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos contudo foram importadas "+Alltrim(Str(nProd))+" de produtos."+CRLF+"Vide Log de Eventos.", { 'Ok' } , 2 , "Importações de XML" )
	Else
		//Aviso( "Aten??o" , "Foram submetidas a importa??o "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de servi?os, com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "Importa??es de XML" )
		Aviso( "Atenção" , "Foram submetidas a importação "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "Importações de XML" )
	EndIf
	
EndIf

Return

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
		cPasta := cGetFile(cDirTmp,"Selecione a pasta para importação dos XMLs...",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
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
cDirXmlUT:=cDirOrigXml
cArqXmlUT:=cArquivo
Return aArquivos

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
			oRegua:IncRegua2("Gerando notas de serviço...")
			lOK:=GeraNFS(aNF[nX],lAuto,lExibErro,oRegua)
		Else
			Processa( { || lOK:=GeraNFS(aNF[nX],lAuto,lExibErro,oRegua) } , 'Aguarde...' , 'Gerando notas de serviço' )
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

Static Function GeraNFS(aNF,lAuto,lExibErro,oRegua)
Local aAutoCab  := {}
Local aItem		:= {}
Local aAutoItens:= {}
Local lRet		:= .F.
Local cNewArq	:= ""

Private lMsErroAuto := .F.

If Len(aNF)>0 .And. aNF[1]=="SAIDA"
	If	Empty(aNF[20]) .Or. !SF4->(dbSeek(xFilial("SF4")+aNF[20])) .Or. SF4->F4_MSBLQL=="1"
		AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Tipo de Entrada/Saida não informada, não localizada ou bloqueada."})

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
	AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Condição de Pagamento não informada ou não localizada."})

	If lExibErro
		MsgStop("Condição de Pagamento não informada ou não localizada.  Operação de importação descontinuada.")
	EndIf
	If Valtype(oRegua)=="O"
		oRegua:SaveLog("Nota fiscal de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Condição de Pagamento não informada ou não localizada.")
	EndIf
	Return lRet
EndIf
If	aNF[1]=="SAIDA" .And. (Empty(aNF[22]) .Or. !SED->(dbSeek(xFilial("SED")+aNF[22])))
    AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Natureza não informada ou não localizada."})

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
       AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Documento somente pode ser gerado na filial do cnpj "+aNF[19]+"."})

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
				    AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Documento não pode ser gerado para esta TES."})

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
										Contabilizacao On Line - Cabe?alho nota de Saida
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
										**	Contabilizacao On Line - Itens da nota de Saida
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
							MsgStop('Pré-nota ja cadastrada:'+CRLF+'"'+aNF[02]+'"')
						EndIf
						If Valtype(oRegua)=="O"
							oRegua:SaveLog("Pré-nota de serviço:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" ja cadastrada.")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

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
	/*04*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_ITEMLISTASERVICO:TEXT) 								// 04 Codigo Servi?o
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

Static Function GetCliente(aCliente)
Local lRet 		:= .T.
Local cCodigo 	:= ""
Local cPess		:= ""
Local cMunic	:= ""

//integra??o com cliente pessoa fisica.
If Len(Alltrim(aCliente[1,11]))<=11
	cPess:= "F"
Else
	cPess:= "J"
EndIf

//nome do Municipio
CC2->(DbSetOrder(3)) //CC2_FILIAL+CC2_CODMUN
IF CC2->(DbSeek(xFilial("CC2")+SubStr(aCliente[1,05],3)))
	cMunic := Alltrim(CC2->CC2_MUN)
EndIf


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
		SA1->A1_CODPAIS	:= StrZero(Val(aCliente[1,06]),5)// Adicionar 0 a esquerda caso precise, c?digo do pais possui 5 caracteres.
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

Static Function GetFornece(aFornecedor)
Local lRet 		:= .T.
Local cCodigo 	:= ""

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
		SA2->A2_CODPAIS	:= StrZero(Val(aFornecedor[1,06]),5)// Adicionar 0 a esquerda caso precise, c?digo do pais possui 5 caracteres.
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

Static Function ComplemNF(aNF,nTipo)
Local aNFOrig 	:= aClone(aNF)
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
	aAdd(aHeader,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND. U_UTXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",		,,,"A"} )
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
	
	DEFINE MSDIALOG oDlg TITLE "Classificação das notas de produtos" FROM 0,0 To 400,800 PIXEL
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	
	oFWLayer:addLine("L1",100,.F.)
	oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
	oFWLayer:AddWindow("C1"		,"oPanel","Classificação das notas"	,100,.F.,.T.,,"L1",{ || })
	oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")
	
	oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL
	
	@ 06,05	Say "Classifique as notas abaixo conforme suas caracteristicas originais."	OF oPanel1 PIXEL
	@ 18,05 Say "Obs: Os documentos de saida sem TES serão geradas pré-notas."			OF oPanel1 PIXEL
	
	
	oGets:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oPanel2,aHeader,aCols)
	oGets:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGets:OBROWSE:NFREEZE := 1
	
	
	ACTIVATE MSDIALOG oDlg ON INIT UTBarMnu(oDlg,		{|| (nOpcA:=1,oDlg:End())},;
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
	
	aAdd(aHeader,{ "Tipo"				,"TPNOTA"	,"@!"							,10							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "Nota Fiscal"		,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	aAdd(aHeader,{ "TES"				,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_UTXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",,,,"A"} )
	aAdd(aHeader,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"				/*VALIDACAO*/,""	,"C","SE4"	,"R",,,,"A"} )
	aAdd(aHeader,{ "Natureza"			,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')"	/*VALIDACAO*/,""	,"C","SED"	,"R",,,,"A"} )
	aAdd(aHeader,{ "Arquivo"			,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
	
	For nX:= 1 To Len(aNFOrig)
		aAdd(aCols,{aNFOrig[nX,01],aNFOrig[nX,02],aNFOrig[nX,03],aNFOrig[nX,23],aNFOrig[nX,20],aNFOrig[nX,21],aNFOrig[nX,22],aNFOrig[nX,24],.F.})
	Next nX
	
	DEFINE MSDIALOG oDlg TITLE "Classificação das notas de serviço" FROM 0,0 To 400,800 PIXEL
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	
	oFWLayer:addLine("L1",100,.F.)
	oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
	oFWLayer:AddWindow("C1"		,"oPanel","Classificação das notas"	,100,.F.,.T.,,"L1",{ || })
	oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")
	
	oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL
	
	@ 06,05	Say "Classifique as notas abaixo conforme suas caracteristicas originais."	OF oPanel1 PIXEL
	@ 18,05 Say "Obs: Os documentos de saida sem TES serão geradas pré-notas."			OF oPanel1 PIXEL
	
	oGets:=MSNewGetDados():New(34,5,128,315,2,.T.,.T.,,,,,,,,oPanel2,aHeader,aCols)
	oGets:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGets:OBROWSE:NFREEZE := 1
	
	
	ACTIVATE MSDIALOG oDlg ON INIT UTBarMnu(oDlg,		{|| (nOpcA:=1,oDlg:End())},;
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


Static Function GeraTitulo(cTes,nTotal,cCon,cTitulo,cPrefixo,cNatureza,cCliente)

Local cParcela  := "1"
Local aVetor	:= {}

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

Static Function ExtrNfProd(oXml,aDados,cArquivo)

Local oNFe 	:= IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)
Local aItens:= {}
Local aNF	:= {}
Local aRet  := {}
Local cCFOP := ""
Local nX	:= 1

Local cCGC  := ""   

Local cTpTes := ""

Local dDtEmiss	:= CTOD("//")

Private cTipo := ""


//-->> 01 Tipo da geracao da NF
If Alltrim(oNFe:_EMIT:_CNPJ:TEXT) == Alltrim(_cMeuCnpj) //.And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
	If !(lDev)
		aAdd(aNF,"SAIDA")
		cTipo := "S"   
	Else
	    //não importará neste momento
		//aAdd(aNF,"ENTRADA")
		//cTipo := "E"	
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
	aAdd(aNF,"")														//->> 04 - CPF ou CPNJ n?o encontrado no XML 
EndIf

If cTipo == "S"
    
    //Tratamento para Exportador sem CNPJ ou CPF
	If cPessoa <> ""	
		SA1->(dbSetOrder(3))
		If !SA1->(dbSeek(xFilial("SA1")+cCGC))
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
				aNF[4]:=SA2->A2_CGC	//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
			EndIf 
			
		EndIf	
	EndIf	
EndIf

// tratamento para o atributo data de emiss?o
if XmlChildEx(oNFe:_IDE,"_DEMI"  )<>Nil
	dDtEmiss:=StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-",""))
elseif XmlChildEx(oNFe:_IDE,"_DHEMI"  )<>Nil
	dDtEmiss:=StoD(StrTran(oNFe:_IDE:_DHEMI:TEXT,"-",""))
endif

aAdd(aNF,dDtEmiss)  												//->> 05 - Data de Emiss?o
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vFrete:TEXT))					//->> 06 - Frete
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vDesc:TEXT))						//->> 07 - Desconto
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vSeg:TEXT))						//->> 08 - Seguro
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vNF:TEXT))						//->> 09 - Valor Bruto
aAdd(aNF,oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT) 				//->> 10 - Chave da Nota Fiscal

//-->> Monta o aDados para Importar os itens da NF-e
//Tratamento para Frete e Desconto no XML. Chamado 025295
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
	cTpTes:=SB1->B1_TS
        Do Case
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5101/6101'
		cTpTes:="7X4"
        Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5102/6102'
		cTpTes:="7X5"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5401/6401'
		cTpTes:="7WH"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5901/6901'
		cTpTes:="7XB"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5905/6905'
		cTpTes:="58W"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5910/6910'
		cTpTes:="7XA"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5917/6917'
		cTpTes:="7X8"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5949/6949'
		cTpTes:="7X7"
		Case oNFe:_DET:_PROD:_CFOP:TEXT $ '5917/6917'
		End Case

		aAdd(aNF,cTpTes)  											//->> 12 - TES
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
									
// Tratamento para Exportador sem CNPJ ou CPF					
If oNFe:_DEST:_ENDERDEST:_UF:TEXT == "EX" .AND. lDev
	aAdd(aNF,SA2->A2_COD)												//->> 15 - FORNECEDOR IMPORT
ElseIf oNFe:_DEST:_ENDERDEST:_UF:TEXT == "EX" .AND. !lDev
	aAdd(aNF,SA1->A1_COD)												//->> 15 - CLIENTE EXPORTA??O
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
aRet := ValNfeSef(oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
aAdd(aNF,aRet[1])														//->> 26 - .T. Chave Valida / .F. Chave Invalida
aAdd(aNF,aRet[2])														//->> 27 - Mensagem da Validacao da Chave da NFe
//aAdd(aNF,.t.)														//->> 26 - .T. Chave Valida / .F. Chave Invalida
//aAdd(aNF,"validado anteriormente")														//->> 27 - Mensagem da Validacao da Chave da NFe

aAdd(aNF,oNFe:_DEST:_ENDERDEST:_UF:TEXT)								//->> 28 - UF do Destinatario (importante para NF de Importacao)

aAdd(aDados,aNF)

Return

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
			Processa( { || lOK:=GeraNFP(aNF[nX],lAuto,lExibErro,@oRegua) } , 'Aguarde...' , 'Gerando notas de produtos' )
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
				Aviso( 'Atenção' , 'Não há natureza cadastrada para este fornecedor: ' + SA2->A2_COD + CRLF + CRLF , { 'Ok' } , 2 , 'Natureza Não Cadastrada!' )
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"N?o h? natureza cadastrada para este fornecedor")
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
			Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo já foi cadastrado!' + CRLF + CRLF + ;
			'Fornecedor: ' + SA2->(A2_COD+'/'+A2_LOJA+' '+A2_NOME) + CRLF + ;
			'Doc./Serie: ' + cNumero+' / '+cSerie , { 'Ok' } , 2 , 'Documento já cadastrado!' )
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" já existe.")
		EndIf
		Return .F.
	EndIf
	
	//--> Larson
	If aNF[17] == "N" .And. Posicione("SED",1,xFilial("SED")+SA2->A2_NATUREZ,"ED_CALCIRF") == "S" .And. Empty(aNF[21])
		If lExibErro
			Aviso( 'Atenção' , 'O Código da Retenção do I.R. (DIRF) Não foi preenchido corretamente.' + SA2->A2_COD + CRLF + CRLF , { 'Ok' } , 2 , 'DIRF - Cód. Retenção!' )
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
					//->> Devolu??o
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
		//Tratamento para Beneficiamento.
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
			    AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Não existe Cliente cadastrado com este CNPJ " + aNF[04]+"."})

				If lExibErro
					MsgStop('Não existe cliente cadastrado com este CNPJ ' + aNF[04])
				EndIf
				If Valtype(oRegua)=="O"
					oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Não encontrado cliente cadastrado com este CNPJ")
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
       AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Documento já cadastrado."})

		If lExibErro
			Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo já foi cadastrado!' + CRLF + CRLF + ;
			'Cliente:    ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME) + CRLF + ;
			'Doc./Serie: ' + cNumero+' / '+cSerie , { 'Ok' } , 2 , 'Documento já cadastrado!' )
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" já cadastrada.")
		EndIf
		Return .F.
	EndIf
	cTes	:= aNF[12]
	
	If !EMPTY(cTes)
		VldTES(cTes,.F.)
	EndIf
	
	If Empty(aNF[12]).OR.lVldTes 
	    
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
							oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" n?o importada."+" "+"Verificar se nota de origem foi informado e se o valor unitario esta igual ao total do item.")
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
	
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItemNF,3)
	
		If lMsErroAuto
			DisarmTransaction()
			AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,MostraErro()})

			If lExibErro
				MostraErro()
			EndIf
			lRetorno := .F.
		Else	
			nProd++
			lRetorno := .T.
            
			UT410PvNfs()

		EndIf
	Else
		
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
						Contabilizacao On Line - Itens da nota de Saida
					*/                                               
					If lContOnLine .And. lLancPad10                                            
				   		nTotal += DetProva( nHdlPrv , "610" , _cFuncao , cLoteFat )
					EndIf					
					//????????????????????????????????????????????????
					//?Observacao: Mata920 nao trata poder 3.		  ?
					//?Atualiza Poder de Terceiro apos chamada		  ?
					//? da rot. automatica. 						  ?
					//?????????????????????????????????????????????????
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
			
			//????????????????????????????????????????????????
			//?Observacao: Mata920 nao trata estoque.		  ?
			//?Baixa estoque apos chamada da rot. automatica. ?
			//?????????????????????????????????????????????????
			
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

Static Function ClassNf(aNF,aNFS,oRegua)
Local aNFOrig 		:= aClone(aNF)
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

aAdd(aHeaderNF,{ "TipoTES"				,"TPNOTA"	,"@!"							,10				  			,0							,""							   							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ ""						,"ENABLE"	,"@BMP"							,2							,0							,														/*VALIDACAO*/,		,"C",		,"V",	,,,"V"} )
aAdd(aHeaderNF,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Conta Contábil"		,"CONTA"	,"@!"							,Tamsx3("A1_CONTA")		[1]	,0							,"Vazio().or. Ctb105Cta()"	 							/*VALIDACAO*/,""	,"C","CT1"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_UTXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",	,,,"A"} )
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
	aAdd(aColsNF,{aNFOrig[nX,01], StatusNFe(@aNFOrig[nX],@aColsLG,1,aNFOrig[nX,26],aNFOrig[nX,27],aNFOrig[nX,28]), aNFOrig[nX,02], aNFOrig[nX,03], aNFOrig[nX,04],IIF(EMPTY(cConta),MV_PAR05,cConta), IIF(EMPTY(aNFOrig[nX,12]),MV_PAR02,aNFOrig[nX,12]), IIF(EMPTY(aNFOrig[nX,13]),MV_PAR03,aNFOrig[nX,13]), IIF(EMPTY(aNFOrig[nX,14]),MV_PAR04,aNFOrig[nX,14]), aNFOrig[nX,15], aNFOrig[nX,16], aNFOrig[nX,17], aNFOrig[nX,18], aNFOrig[nX,19], aNFOrig[nX,20], aNFOrig[nX,21], aNFOrig[nX,05], aNFOrig[nX,23], aNFOrig[nX,24], aNFOrig[nX,25], aNFOrig[nX,22], .F.})
Next nX
SA1->(DbCloseArea())


aAdd(aHeaderNFS,{ "Tipo"				,"TPNOTA"	,"@!"							,10							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ ""					,"ENABLE"	,"@BMP"							,2							,0							,								/*VALIDACAO*/,		,"C",		,"V",		,,,"V"} )
aAdd(aHeaderNFS,{ "Nota Fiscal"	  		,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_UTXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"				/*VALIDACAO*/,""	,"C","SE4"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Natureza"			,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')"	/*VALIDACAO*/,""	,"C","SED"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )

For nX:= 1 To Len(aNFSOrig)
	aAdd(aColsnfs,{aNFSOrig[nX,01],StatusNFe(@aNFsOrig[nX],@aColsLG,2),aNFSOrig[nX,02],aNFSOrig[nX,03],aNFSOrig[nX,12,11,1],aNFSOrig[nX,20],aNFSOrig[nX,21],aNFSOrig[nX,22],aNFSOrig[nX,24],.F.})
Next nX


//??????????????????????
//? Log de Ocorrencias ?
//??????????????????????
aAdd(aHeaderLG,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Série"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Fornecedor/Cliente"	,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Ocorrência"			,"OCORR"	,"@!"							,100              		   	,0               		    ,""								/*VALIDACAO*/,""	,"C",""   	,"R",		,,,"V"} )

//??????????????????????
//? Log de Arquivo     ?
//??????????????????????
aAdd(aHeaderLGX,{ "Tipo Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLGX,{ "Ocorrência"			,"OCORR"	,"  "							,40               		   	,0               		    ,""								/*VALIDACAO*/,""	,"C",""   	,"R",		,,,"V"} )
aAdd(aHeaderLGX,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )

DEFINE MSDIALOG oDlg TITLE "Classificação das notas fiscais" FROM 0,0 To 500,900 PIXEL Style 1 Color CLR_BLACK,CLR_WHITE

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
@ 18,05 Say "Obs: Os documentos de entrada sem TES serão geradas como Pré-Notas."	OF oPanel1 PIXEL

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

ACTIVATE MSDIALOG oDlg ON INIT UTBarMnu(oDlg,	{|| (nOpcA:=1,oDlg:End())}, {|| (nOpcA:=0,oDlg:End())}, {},{},.F.,.F.,.F.,0,.T.) CENTER

If nOpcA==1
	lRet := .T.
	
	//--> Notas de Produtos
	oRegua:SetRegua2(Len(oGetNf:aCols))
	For nX:=1 to Len(oGetNf:aCols)
		oRegua:IncRegua2("Gravando Informações das notas de produtos...")
		If !oGetNf:aCols[nX,Len(oGetNf:aCols[nX])] .And. !Empty(oGetNf:aCols[nX,1]) //.And. oGetNf:aCols[nX,2]:cNAME <> "BR_PRETO"
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
			
			If Len(aNewClie)>0
				//Comparando o CPF ou CNPJ
				nPosiCli := aScan( aNewClie, { |x| alltrim(x[11]) == Alltrim(oGetNf:aCols[nX,5])})
				If nPosiCli>0
					aAdd(aNewClie[nPosiCli],oGetNf:aCols[nX,06]) //posi??o 14 do array aNewClie com a Conta Cont?bil
					aAdd(aNewClie[nPosiCli],oGetNf:aCols[nX,09]) //posi??o 15 do array aNewClie com a Natureza
				EndIf				
			EndIf
			
		EndIf
	Next nX 
	
	//--> Notas de Servico
	oRegua:SetRegua2(Len(oGetNFS:aCols))
	For nX:=1 to Len(oGetNFS:aCols)
		oRegua:IncRegua2("Gravando Informações das Notas de Serviços...")
		If !oGetNFS:aCols[nX,Len(oGetNFS:aCols[nX])] .And. !Empty(oGetNFS:aCols[nX,1]) //.And. oGetNFS:aCols[nX,2]:cNAME <> "BR_PRETO"
			aAdd(aNFS,aNFSOrig[nX])
			nY := Len(aNFS)
			aNFS[nY,20] := oGetNFS:aCols[nX,05]
			aNFS[nY,21] := oGetNFS:aCols[nX,06]
			aNFS[nY,22] := oGetNFS:aCols[nX,07]
		EndIf
	Next nX
	
	//--> Grava Novos Clientes
	oRegua:SetRegua2(Len(aNewClie))
	For nX := 1 To Len(aNewClie)
		aNewAux:={}
		oRegua:IncRegua2("Criando Novos Clientes...")
		AADD(aNewAux,aNewClie[nX])
		GetCliente(aNewAux)
	Next nX
	
	//--> Grava Novos Fornecedores
	oRegua:SetRegua2(Len(aNewForn))
	For nX := 1 To Len(aNewForn)
		aNewAux:={}
		oRegua:IncRegua2("Criando Novos Fornecedores...")
		AADD(aNewAux,aNewForn[nX])
		GetFornece(aNewAux)
	Next nX
	
EndIf

Return

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
					If .F.//mv_par02 == 1
						//--> Busca so no Cad. Produto SB1
						For nX := 1 To Len(aNF[11])
							If !SB1->(dbSeek( xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
								oCor := LoadBitmap( GetResources(), "BR_PRETO" )
								aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto Nao Cadastrado", .F. })
								Exit
							EndIf
						Next nX	

					ElseIf .F.//mv_par02 == 2
						//--> Busca so no Cad. Produto X Fornecedor (SA5)
						For nX := 1 To Len(aNF[11])
							If !(SA5->(dbSeek(xFilial("SA5")+SA2->(A2_COD+A2_LOJA)+aNF[11,nX,02])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO)))
								oCor := LoadBitmap( GetResources(), "BR_PRETO" )
								aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto X Fornecedor Nao Cadastrado", .F. })
								Exit
							EndIf
						Next nX	

					ElseIf .F.//mv_par02 == 3
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


Static Function UTBarMnu(oDlg,bOk,bCancel,aButtons,aButText,lIsEnchoice,lSplitBar,lLegenda,nDirecao,lBGround)
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

STATIC Function ValNfeSef(cChave,cFormul,cEspecie,lMsg)
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
				AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,cMsgErro})

			EndIf
			
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT      := cIdEnt
			ows:cCHVNFE		 := cChaveNFe
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
			
			If oWs:ConsultaChaveNFE()
				If Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMsgErro := "A chave digitada não foi encontrada na Sefaz, favor verificar"
					AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"A chave digitada não foi encontrada na Sefaz, favor verificar."})
					//If lMsg
					//	MsgAlert("A chave digitada não foi encontrada na Sefaz, favor verificar")
					//EndIf
					lRet := .F.
				ElseIf AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
					cMsgErro := cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE + "; " + cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE + "; " + cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
					If lMsg
						If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
							cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
							cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF+CRLF+CRLF+;
							"Deseja inserir a chave mesmo assim?")
							lRet := .T.
						Else
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					EndIf
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
					cMsgErro := "A chave informada é menor que o permitido e impossibilita a consulta na Sefaz."
					If lMsg
						If MsgNoYes("A chave informada é menor que o permitido e impossibilita a consulta na Sefaz."+CRLF+CRLF+"Deseja APAGAR o conteúdo do campo para inserir uma nova chave?")
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
//?????????????????????????????????????????????????????????????????????????
//?Verifica se o servidor da Totvs esta no ar                              ?
//??????????????????????????????????????????????????????????????????????????
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
Objetivos   : Valida se a TES atualiza estoque ou n?o.
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
 			MsgInfo("Essa TES atualiza estoque. Será gerado documento "+Chr(13)+Chr(10)+" para ajustar o estoque!","HLB Brasil")
 		EndIf
 		lVldTes := .T.
 	Else                
 		lVldTes := .F.	
 	EndIf
EndIf

Return lRet

/*
Fun??o.........: SelTpLanc
Objetivo.......: Selecionar lan?amento On Line ou Off Line na contabiliza??o das notas de saida
*/
*--------------------------------*
Static Function SelTpLanc
*--------------------------------*
Local oDlg                                                                 
Local oRadio

Local bOk     := { || lOk := .T. , oDlg :End() }
Local bCancel := { || lOk := .F. , oDlg :End() }              

Local lOk    := .F.                                                           
Local cTpLanc := Space( 10 )

Local nItem := 2

Define MSDialog oDlg Title "Selecione o tipo de contabilizacao" From 1,1 To 150,350 Of oMainWnd Pixel

@05,10 Say "Contabiliza" Size 70,10 Of oDlg Pixel
@05,90 COMBOBOX cTpLanc ITEMS { "On-Line" , "Off-Line" }   Size 80,10  Of oDlg Pixel
                                                   
@20,10 Say "Mostra Lcto.?" Size 70,10 Of oDlg Pixel
@20,90 RADIO oRadio VAR nItem SIZE 100,09 PROMPT 'Sim', 'Nao' OF oDlg

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered

If ( lOk  )

	lContOnLine := ( AllTrim( cTpLanc ) == "On-Line" )
	lMostraLanc := ( nItem == 1 ) .And. lContOnLine

EndIf

Return( lOk )

Static Function UT410PvNfs(cAlias,nReg,nOpc)

Local aArea     := GetArea()
Local aPvlNfs   := {}
Local aRegistros:= {}
Local aTexto    := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local lQuery    := .F.
Local cAliasSC9 := "SC9"
Local cAliasSC6 := "SC6"
Local nPrcVen   := 0
Local nQtdLib   := 0
Local nItemNf   := 0
Local nX        := 0
Local cSerie    := ""
Local lOk       := .F.
Local oWizard
Local oListBox
Local lContinua := .T.
Local lCond9  	:= GetNewPar("MV_DATAINF",.F.)	//Caso existam diferentes códigos de serviço no Pedido de Vendas, deverá ser gerada uma nota fiscal para cada código.
Local cFunName  := FunName()
Local lTxMoeda := .F.
#IFDEF TOP
	Local cQuery    := ""
#ENDIF 

Local dDataMoe  := dDataBase  
Local lConfirma := .T.
Local lDataFin	:= .F.
Local lNfeQueb	:= GetNewPar("MV_NFEQUEB",.F.) .And. cPaisLoc == "BRA"
Local lBlqISS	:= .T.
Local bCondExec := {||}
Local nY		:= 0
Local lReajuste:= .F.
Local aTotsNF :={}
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local cSerieId  := IIf( lUsaNewKey , SerieNfId("SF2",4,"F2_SERIE",dDataBase,A460Especie(cSerie),cSerie) , cSerie )
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local lM410ALDT	:=ExistBlock("M410ALDT")
Local lM461DINF	:=ExistBlock("M461DINF")
Local lAGRUBS   := SuperGetMV("MV_AGRUBS",.F.,.F.)
Local cTrcNum   := ""
Local lTrcNum	:= IIf(lAGRUBS,SC5->(ColumnPos("C5_TRCNUM"))>0,.F.)	//Campo da Agroindustria
Local lAgrMoeda	:= .F.
Local aAgrArea  := {}

// Se lMudouNum for .T. significa que o usuario alterou o numero da nota em MV_TPNRNFS == "3"
// e o sistema deve respeitar o novo numero contido em cNumero
Private lMudouNum := .F.
//Private cNumero   := ""

Private cIdPV := ""
Private cPV410 := ""

// variaveis criadas para chamada da funcao A460AcumIt() no fonte MATA460 - calcular o total da nota e bloquear se total inferior ao valor minimo a faturar (parametro 12 do pergunte MT460A)
Private nAcresFin	:= SC5->C5_ACRSFIN
Private cMVARREFAT :=SuperGetMv("MV_ARREFAT")
Private aTamSX3:=TamSX3("F2_VALBRUT")
Private	nBaseFIcm:=0,nBaseFIpi:=0,nBaseISS:=0  
Private	nBaseIRF:=0,nBItemInss:=0,nBaseInss:=0
Private nDecimal := TamSx3("F2_VALBRUT")[2]

lCond9   := IIf(ValType(lCond9)<>"L",.F.,lCond9)

SetFunName("MATA461")

If lContinua
	
	If !lNfeQueb
		//bCondExec := {|| UT410LbNfs(1,@aPvlNfs,@aBloqueio),;
		//				 oWizard:SetPanel(IIf(!Empty(aPvlNfs).Or.!Empty(aBloqueio),1,2))}	
		UT410LbNfs(2,@aPvlNfs,@aBloqueio)
		UT410LbNfs(1,@aPvlNfs,@aBloqueio)//,oWizard:SetPanel(IIf(!Empty(aPvlNfs).Or.!Empty(aBloqueio),1,2))	

	Else
		//Verifica se existem itens com códigos de serviço diferentes quando o parâmetro MV_NFEQUEB estiver ativo.
		lBlqISS := A410BloqIss(SC5->C5_NUM)
		
		If !lBlqISS
			bCondExec := {|| oWizard:SetPanel(7)}	
		Else
			bCondExec := {|| UT410LbNfs(1,@aPvlNfs,@aBloqueio),;
							 oWizard:SetPanel(IIf(!Empty(aPvlNfs).Or.!Empty(aBloqueio),1,2))}	
		EndIF
	EndIf
	
	If !Empty(aPvlNfs) 
				nItemNf  := a460NumIt(cSerie)
				
						aadd(aNotas,{})		
					   	For nX := 1 To Len(aPvlNfs)
							lConfirma:= .T.
					    	If Len(aNotas[Len(aNotas)])>=nItemNf
					    		aadd(aNotas,{})
					    	EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						    //³ Se o item gerar duplicata, verifica se a data do movimento n?o ?³
							//³ menor que data limite de movimentacao no financeiro configurada ³
							//³ no parametro MV_DATAFIN.									    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If aPvlNfs[nX][18] .And. !DtMovFin(,.F.)
								lDataFin := .T.
								lConfirma:= .F.
							EndIf
	                        If lConfirma
						    	aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
							EndIf
						Next nX         
						
						If lM410ALDT			
	   						dDataBase := If(ValType(dDataPE := ExecBlock("M410ALDT", .F., .F.))=='D', dDataPE , dDataBase) 
		   				Endif
						
						For nX := 1 To Len(aNotas)
								// Verifica se o total da nota é menor que o parametro de valor minimo de faturamento
							lReajuste:= .F.//IIF(mv_par05==1,.T.,.F.)
							nTotalNF:=0  
							aTotsNF:={}
							nBaseFIcm:=0 
							nBaseFIpi:=0 
							nBaseISS:=0  
							nBaseIRF:=0  
							nBItemInss:=0
							nBaseInss:=0
							For nY := 1 To Len(aNotas[nX])
								// posiciona no item da SC9 - FILIAL + PEDIDO + ITEM + SEQUEN + PRODUTO
								SC9->(dbSeek(xFilial("SC9")+aNotas[nX][nY][1]+aNotas[nX][nY][2]+aNotas[nX][nY][3]+aNotas[nX][nY][6]))
								// posiciona no item da SC6   - FILIAL + PEDIDO + ITEM + PRODUTO
								SC6->(dbSeek(xFilial("SC6")+aNotas[nX][nY][1]+aNotas[nX][nY][2]+aNotas[nX][nY][6])) 
								A460AcumIt(@aTotsNF,SC9->C9_QTDLIB,lReajuste,0)
								nTotalNF += aTotsNF[ Len(aTotsNF ) ][4]
							Next nY
							If nTotalNF >= 0
									// Verifica se bloqueia faturamento quando o 1o vencto < emissao da NF na cond.pgto tipo 9 (T = Bloqueia , F = Fatura)
									// Bloqueia faturamento se a moeda nao estiver cadastrada
									// Neste momento o SC5 esta posicionado no item que irá gerar a nota fiscal.
									If !(( lCond9 .And. SC5->C5_DATA1 < dDataBase .And. !Empty(SC5->C5_DATA1) );
											.Or. ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) = 0 ))
										dDataMoe := dDataBase//MV_PAR21								
										If !Empty(aNotas[nX])
											MaPvlNfs(aNotas[nX],cSerie,.T.,.T.,.T.,.T.,.T.,nHdlPrv,.F.,.T.,.T.,,,,,,dDataMoe)
										EndIf
									Else
										If ( xMoeda( 1, SC5->C5_MOEDA, 1, dDataBase ) = 0 )
											lTxMoeda := .T.
										EndIf
									EndIf
								
							Endif
						Next nX
					
				
	Else
		AAdd(aLogErro,{cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Erro na liberação do pedido."})
	EndIf
EndIf              
                                                         
SetFunName(cFunName)
	
//Mensagem para o usuário em caso de existirem notas com datas onde não foram encontrados valores de moeda cadastrados
If lTxMoeda
   AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Alguns pedidos nao foram gerados pois nao existe taxa para a moeda na data."})

	//Aviso(STR0295,STR0303,{STR0304}) //"Mensagens"###"Alguns pedidos nao foram gerados pois nao existe taxa para a moeda na data!"
EndIf
If lDataFin
   AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"não são permitidas movimentações financeiras com datas menores que a data limite de movimentações no Financeiro."})

	//Aviso(STR0295,STR0305,{STR0304})	//"Alguns itens não foram gerados, pois não são permitidas movimentações financeiras com datas menores que a data limite de movimentações no Financeiro. Verificar o parâmetro MV_DATAFIN."
EndIf

//Pergunte("MTA410",.F.)
RestArea(aArea)
Return

Static Function UT410LbNfs(nTipo,aPvlNfs,aBloqueio)

Local aArea     := GetArea()
Local aRegistros:= {}
Local lQuery    := .F.
Local cAliasSC9 := "SC9"
Local cAliasSC6 := "SC6"
Local nPrcVen   := 0
Local nQtdLib   := 0
#IFDEF TOP
	Local cQuery    := ""
#ENDIF
DEFAULT aPvlNfs    := {}
aBloqueio  := {}

Do Case
	Case nTipo == 1
		#IFDEF TOP
			cAliasSC9 := "MA410PVNFS"
			lQuery := .T.
			cQuery    := "SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_QTDLIB,SC9.C9_QTDLIB2,SC9.C9_PRCVEN,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_BLCRED,SC9.C9_BLEST,SC9.C9_BLWMS,SC9.R_E_C_N_O_ SC9RECNO "
			cQuery    += "FROM "+RetSqlName("SC9")+" SC9 "
			cQuery    += "WHERE "
			cQuery    += "SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
			cQuery    += "SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' AND "
			cQuery    += "SC9.D_E_L_E_T_=' ' "
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9)
			
		#ELSE
			dbSelectArea("SC9")
			dbSetOrder(1)
			MsSeek(xFilial("SC9")+SC5->C5_NUM)
		#ENDIF
		While !Eof() .And. xFilial("SC9") == (cAliasSC9)->C9_FILIAL .And. 	SC5->C5_NUM == (cAliasSC9)->C9_PEDIDO
			If Empty((cAliasSC9)->C9_BLCRED+(cAliasSC9)->C9_BLEST) .And. (Empty((cAliasSC9)->C9_BLWMS) .Or. (cAliasSC9)->C9_BLWMS == "05" .Or. (cAliasSC9)->C9_BLWMS == "07" ) 
		
				SC6->(DbSetOrder(1))
				SC6->(MsSeek(xFilial("SC6")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_PRODUTO))
				
				SE4->(DbSetOrder(1))
				SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )
		
				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		
				SB2->(DbSetOrder(1))
				SB2->(MsSeek(xFilial("SB2")+(cAliasSC9)->C9_PRODUTO+(cAliasSC9)->C9_LOCAL))
		
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o produto est  sendo inventariado  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_ESTOQUE == 'S' .And. BlqInvent((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_LOCAL)
					Help(" ",1,"BLQINVENT",,(cAliasSC9)->C9_PRODUTO+" Almox: "+(cAliasSC9)->C9_LOCAL,1,11)
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula o preco de venda                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					nPrcVen := (cAliasSC9)->C9_PRCVEN
					If ( SC5->C5_MOEDA <> 1 )
						nPrcVen := a410Arred(xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8),"D2_PRCVEN")
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta array para geracao da NF                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aadd(aPvlNfs,{ (cAliasSC9)->C9_PEDIDO,;
									(cAliasSC9)->C9_ITEM,;
									(cAliasSC9)->C9_SEQUEN,;
									(cAliasSC9)->C9_QTDLIB,;
									nPrcVen,;
									(cAliasSC9)->C9_PRODUTO,;
									SF4->F4_ISS=="S",;
									If(lQuery,(cAliasSC9)->SC9RECNO,SC9->(RecNo())),;
									SC5->(RecNo()),;
									SC6->(RecNo()),;
									SE4->(RecNo()),;
									SB1->(RecNo()),;
									SB2->(RecNo()),;
									SF4->(RecNo()),;
									(cAliasSC9)->C9_LOCAL,;
									0,;
									(cAliasSC9)->C9_QTDLIB2,;
									SF4->F4_DUPLIC=="S"})
				EndIf
			ElseIf (cAliasSC9)->C9_BLCRED<>"10" .And. (cAliasSC9)->C9_BLEST <>"10"
				aadd(aBloqueio,{(cAliasSC9)->C9_PEDIDO,(cAliasSC9)->C9_ITEM,(cAliasSC9)->C9_SEQUEN,(cAliasSC9)->C9_PRODUTO,TransForm((cAliasSC9)->C9_QTDLIB,X3Picture("C9_QTDLIB")),(cAliasSC9)->C9_BLCRED,(cAliasSC9)->C9_BLEST,(cAliasSC9)->C9_BLWMS})
			EndIf
			dbSelectArea(cAliasSC9)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSC9)
			dbCloseArea()
			dbSelectArea("SC9")
		EndIf
	Case nTipo == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se não há itens liberados, libera!                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aPvlNfs)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega perguntas do MATA440                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Pergunte("MTA440",.F.)
		lLiber := .T.//MV_PAR02 == 1
		lTransf:= .T.//MV_PAR01 == 1  
		#IFDEF TOP
			lQuery := .T.
			cAliasSC6 := "Ma410PvlNfs"
			
			cQuery := "SELECT SC6.R_E_C_N_O_ C6RECNO,SC5.R_E_C_N_O_ C5RECNO,"
			cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_ITEM,SC6.C6_QTDVEN,SC6.C6_QTDEMP,SC6.C6_QTDENT,"
			cQuery += "SC6.C6_ENTREG,SC6.C6_BLQ "
			cQuery += " FROM "+RetSqlName("SC6")+" SC6,"
			cQuery += RetSqlName("SC5")+" SC5 "
			cQuery += " WHERE SC6.C6_FILIAL = '"+xFilial('SC6')+"' AND "
			cQuery += " SC6.C6_NUM ='"+SC5->C5_NUM+"' AND "
			cQuery += " SC6.C6_BLQ NOT IN ('S ','R ') AND "
			cQuery += " (SC6.C6_QTDVEN-SC6.C6_QTDEMP-SC6.C6_QTDENT)>0 AND "
			cQuery += " SC6.D_E_L_E_T_ = ' ' AND "
			cQuery += " SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
			cQuery += " SC5.C5_NUM=SC6.C6_NUM AND "
			cQuery += " SC5.D_E_L_E_T_ = ' ' "
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasSC6)
		
			TcSetField(cAliasSC6,"C6_ENTREG","D",8,0)
			
		#ELSE
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+SC5->C5_NUM)
		#ENDIF
		While !Eof() .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And.;
			(cAliasSC6)->C6_NUM == SC5->C5_NUM 
			
			aRegistros := {}
		
			While !Eof() .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And. 	(cAliasSC6)->C6_NUM == SC5->C5_NUM
				If !AllTrim((cAliasSC6)->C6_BLQ) $ "SR"		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula a Quantidade Liberada                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nQtdLib := ( (cAliasSC6)->C6_QTDVEN - ( (cAliasSC6)->C6_QTDEMP + (cAliasSC6)->C6_QTDENT ) )
					If nQtdLib > 0
						If RecLock("SC5")
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Posiciona item do pedido de venda                                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
							If ( lQuery )
								SC6->(MsGoto((cAliasSC6)->C6RECNO))
							Else
								SC6->(MsGoto((cAliasSC6)->(RecNo())))
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Recalcula a Quantidade Liberada                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RecLock("SC6")
							nQtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )
							If nQtdLib > 0
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica o tipo de Liberacao                                            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If ( SC5->C5_TIPLIB == "1" )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Libera por Item de Pedido                                               ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Begin Transaction
										MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.F.,.T.,.T.,lLiber,lTransf)
									End Transaction
								Else
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Libera por Pedido                                                       ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
									Begin Transaction
										RecLock("SC6")
										SC6->C6_QTDLIB := nQtdLib
										MsUnLock()
										aadd(aRegistros,SC6->(RecNo()))
									End Transaction
								EndIf
							EndIf
							SC6->(MsUnLock())
						EndIf
					EndIf
				EndIf
				dbSelectArea(cAliasSC6)
				dbSkip()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Libera por Total de Pedido                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Len(aRegistros) > 0 )
				Begin Transaction
					SC6->(MaAvLibPed(SC5->C5_NUM,lLiber,lTransf,.F.,aRegistros,Nil,Nil,Nil,Nil))
				End Transaction
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o Flag do Pedido de Venda                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Begin Transaction
				SC6->(MaLiberOk({SC5->C5_NUM},.F.))
			End Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle de cancelamento por solicitacao do usuario                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSC6)
		EndDo
		If lQuery
			dbSelectArea(cAliasSC6)
			dbCloseArea()
			dbSelectArea("SC6")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega perguntas do MATA410                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Pergunte("MTA410",.F.)
	EndIf
EndCase
RestArea(aArea)
Return(.T.)

Static Function fImpLog()

	SetPrvt("cString,cDesc1,cDesc2,cDesc3,cTamanho,aReturn")
	SetPrvt("aOrd,cNomeProg,aLinha,nLastKey,nOrdem,cTitulo")
	SetPrvt("cCabec,cCabec2,cCancel,m_pag,wNrel,cPerg")
	SetPrvt("nLin,cIni,cFim,cArqTRB,_nCont,_aDetail,_aCabec")

	cString  := "SRA"
	cDesc1   := "Este programa tem como objetivo emitir os "
	cDesc2   := ""
	cDesc3   := ""
	cTamanho := "G"
	aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aOrd     := {}
	cNomeProg:= "fImpLog"
	aLinha   := {}
	nLastKey := 0
	nOrdem   := 0
	cCabec 	 := "Arquivo XML                                                                                        NF/Série       Mensagem "
	//           123456789D123456789V123456789T123456789Q123456789C123456789S123456789S123456789O123456789N123456789*123456789d123456789v123456789t123456789q123456789c123456789s123456789s123456789o123456789n123456789*123456789d123456789v

	cCabec2  := ""
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	wnrel    := "fImpLog"            //Nome Default do relatorio em Disco
	cPerg    := ""
	m_pag    :=1
	_aDetail :={}
	_aCabec  :={}
	cTitulo  := "Log importação XML - G.I.M."

	SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

	If nLastKey == 27
		Set Filter To
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Set Filter To
		Return
	Endif

	RptStatus( {|| fImprime()} )

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool(wnRel)
	Endif

	MS_FLUSH()

Return

//-------------------------------------------------------

Static Function fImprime()
	nLin:=100

	For i:=1 To Len(aLogErro)
		If nLin >= 058
			Cabec(cTitulo,cCabec,cCabec2,cNomeProg,cTamanho,GetMv("MV_COMP"))
			nLin := 008
		Endif

		@ nLin,001 Psay aLogErro[i][1]
		@ nLin,100 Psay aLogErro[i][2]
		@ nLin,115 Psay aLogErro[i][3]
		
		nLin++
		

	Next
	nLin++
	roda(0,Space(10),cTamanho)
	nLin++

Return

