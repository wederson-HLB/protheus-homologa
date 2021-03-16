#Include "Protheus.Ch"
#Include "Shell.Ch" 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Empresa  ³ AKRON Projetos e Sistemas                                  ³±±
±±³          ³ Av. Celso Garcia, 3977 - Tatuape - Sao Paulo - SP - Brasil ³±±
±±³          ³ Fone: +55 11 3853-6470                                     ³±±
±±³          ³ Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ KPIMPXML  ³ Autor ³ Marcio Martins       ³ Data ³12/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao do XML para o Documento de Entrada ou Saida     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ KPIMPXML(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
Funcao      : KPIMPXML
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importacao do XML para o Documento de Entrada ou Saida
Autor       : AKRON Projetos e Sistemas
Data/Hora   : 12/12/2011
Revisão		: Renato Rezende
Data/Hora   : 16/04/2014
*/ 
*--------------------------*
 User Function KPIMPXML()    
*--------------------------*

Local nZ		 := 1
Local aArea      := GetArea()
Local aSize		 := MsAdvSize()
Local aArquivos  := {}
Local aObjects	 := {}
Local aPosObj	 := {}
Local _aParBox   := {}
Local _aCombo1   := {"Normal","Devolucao","Beneficiamento","Compl. ICMS","Compl. IPI","Compl. Preço/Frete"}
Local _aCombo2   := {"Entrada","Saida"}
Local _aCombo3   := {"Sim","Nao"}
Local aInfo		 := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local lProc      := .F.
Local lRet		 := .T.
Local cPerg      := 'KPIMP112'
Local cNomeArq   := ''
Local n

Private aArqTxt   := {}
Private cTpNota	  := ''
Private cCaminho  := ''
Private cTes      := ''
Private cCon      := ''
Private cNumPC    := ''
Private cNumero	  := ''
Private cSerie 	  := ''
Private	cNFORIG   := ''
Private cOri      := ''
Private nClass
Private nFPropr
Private cFornec
Private cTpNota
Private nOpc
Private oDlg

cTipoNf  := SuperGetMv("MV_TPNRNFS")

AADD(_aParBox,{2,"Entrada/Saida"		,1							,_aCombo2,50,"",.F.})
AADD(_aParBox,{1,"TES"					,Space(3)					,"","","SF4","",0,.F.})
AADD(_aParBox,{1,"Cond. Pagto"			,Space(3)					,"","","SE4","",0,.F.})
AADD(_aParBox,{2,"Nota Classificada"	,1							,_aCombo3,50,"",.F.})
AADD(_aParBox,{2,"Formulario Proprio"	,1							,_aCombo3,50,"",.F.})
AADD(_aParBox,{1,"Fornec. p/ Import."	,Space(Len(SA2->A2_COD))	,"","","SA2","",0,.F.})
AADD(_aParBox,{1,"Cliente p/ Export."	,Space(Len(SA1->A1_COD))	,"","","SA1","",0,.F.})
AADD(_aParBox,{2,"Tipo de Nota"			,1							,_aCombo1,50,"",.F.})
AADD(_aParBox,{1,"Vr. Despesas"			,Space(15)					,"@E999,999,999.99","","","",0,.F.})//Colocar aqui o ParamBox para Valor de despesa
AADD(_aParBox,{1,"Nota de Origem"		,Space(9)					,"","","","",0,.F.})
AADD(_aParBox,{1,"Serie NF Origem"		,Space(3)					,"","","","",0,.F.})
AADD(_aParBox,{1,"DIRF - Cód.Retenção"	,Space(Len(SE2->E2_CODRET)),"","","37","",0,.F.})

If ParamBox(_aParBox,"Importação de XML - Akron Projetos e Sistemas Ltda.")
	
	If !ValType(MV_PAR01) == 'N'
		If MV_PAR01 == "Entrada"
			cEntrSai := 1
		Else
			cEntrSai := 2
		EndIf
	Else
		cEntrSai := MV_PAR01
	EndIf
	
	cCaminho := U_KPLocXML()
	cTes     := MV_PAR02
	cCon     := MV_PAR03
	If !ValType(MV_PAR04) == 'N'
		If MV_PAR04 == "Sim"
			nClass	 := 1
		Else
			nClass	 := 2
		EndIf
	Else
		nClass	 := MV_PAR04
	EndIf
	If !ValType(MV_PAR05) == 'N'
		If MV_PAR05 == "Sim"
			nFPropr	 := 1
		Else
			nFPropr	 := 2
		EndIf
	Else
		nFPropr	 := MV_PAR05
	EndIf
	cFornec  := MV_PAR06
	cCliente := MV_PAR07
	nVrDesp	 := Val(MV_PAR09)
	cNFORIG  := MV_PAR10
	cOri     := MV_PAR11
	
	If !ValType(MV_PAR08) = 'N'
		Do Case
			Case MV_PAR08 == "Normal" .Or. Alltrim(MV_PAR08) == "01"
				cTpNota:="N"
			Case MV_PAR08 == "Devolucao" .Or. Alltrim(MV_PAR08) == "02"
				cTpNota:="D"
			Case MV_PAR08 == "Beneficiamento" .Or. Alltrim(MV_PAR08) == "03"
				cTpNota:="B"
			Case MV_PAR08 == "Compl. ICMS" .Or. Alltrim(MV_PAR08) == "04"
				cTpNota:="I"
			Case MV_PAR08 == "Compl. IPI" .Or. Alltrim(MV_PAR08) == "05"
				cTpNota:="P"
			Case MV_PAR08 == "Compl. Preço/Frete" .Or. Alltrim(MV_PAR08) == "06"
				cTpNota:="C"
		EndCase		
	Else
		Do Case
			Case MV_PAR08 == 1
				cTpNota:="N"
			Case MV_PAR08 == 2
				cTpNota:="D"
			Case MV_PAR08 == 3
				cTpNota:="B"
			Case MV_PAR08 == 4
				cTpNota:="I"
			Case MV_PAR08 == 5
				cTpNota:="P"
			Case MV_PAR08 == 6
				cTpNota:="C"
		EndCase
	EndIf
	
	//-->> Carrego os arquivos no Array
	aArquivos := Directory(cCaminho+'\*.xml')
	For n := 1 To Len(aArquivos)
		aAdd( aArqTxt , { aArquivos[n,1] , Transform(aArquivos[n,2]/1024,'999,999.99')+'KB' , DtoC(aArquivos[n,3])+' '+aArquivos[n,4] } )
	Next n
	
	If Len(aArqTxt) == 0
		Aviso( 'Ateção' , 'Não foram encontrados arquivos para serem importados na pasta especificada:' + CRLF + CRLF + cCaminho , { 'Ok' } , 2 , 'Erro' )
		Return
	EndIf
	
	ASort( aArqTxt ,,, { | x,y |  x[1] < y[1] })
	
	AADD(aObjects,{100,200,.T.,.F.,.F.})
	
	aPosObj:=MsObjSize(aInfo,aObjects)
	
	Define MsDialog oDlg Title "Importar Itens da NF´s" Of oMainWnd Pixel From 0,0 To 400,600
	
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oLbx VAR cVar Fields HEADER "Nome do Arquivo","Tamanho","Dt Modificação" Size 295,180 Of oDlg Pixel On ;
	DblClick ( cNomeArq:=aArqTxt[oLbx:nAt][1] , lProc:=.T. , oDlg:End() )
	
	
	oLbx:SetArray(aArqTxt)
	oLbx:bLine   := { || {	aArqTxt[oLbx:nAt][1] , aArqTxt[oLbx:nAt][2] , aArqTxt[oLbx:nAt][3] }}
	
	Activate MsDialog oDlg Center On Init EnchoiceBar( oDlg , { ||  lProc:=.T. , oDlg:End() } , { || oDlg:End() } )
	
	If lProc
		//-->> Realiza o processamento de todos os XML´s encontrados na pasta
		For nZ := 1 to Len(aArqTxt)
			
			If cEntrSai == 1

				cArqNtx := CriaTrab( NIL, .F. )
				nIndex  := RetIndex("SE5")

				//->> Criacao do Indice Temporario
				IndRegua( "SA5", cArqNtx, "A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF", , , "Selec.Registros..." ) 
				#IFNDEF TOP
					dbSetIndex(cArqNtx+OrdBagExt())
				#ENDIF
				dbSetOrder(nIndex+1)
				dbGoTop()

				lRet := .F.
				//-->> Apenas Entrada
				//If nClass==2 .And. nFPropr==1
				If nFPropr==1
					lRetorno:= Sx5NumNota(@cSerie,cTipoNf)
				Else
					lRetorno := .T.
				Endif
				If lRetorno					
					MsgRun(  "Importando NF de Entrada... " + StrZero(nZ,3) + "/" + StrZero(Len(aArqTxt),3) , "Aguarde" , {|| lRet := KPIMPPROC( cCaminho+aArqTxt[nZ][1] )} )
				Endif
				
				/*
				If lRet .And. nFPropr==1
					nTam := Len(cNumero)
					dbSelectArea("SX5")
					dbSeek(cFilial+"01"+cSerie)
					SX5->(RecLock("SX5",.F.))
					SX5->X5_DESCRI  := StrZero(Val(cNumero)+1,nTam)
					SX5->X5_DESCSPA := StrZero(Val(cNumero)+1,nTam)
					SX5->X5_DESCENG := StrZero(Val(cNumero)+1,nTam)
					SX5->(MsUnlock())
				Endif
                */
                
				//--> Apaga o Indice Temporario
				dbSelectArea( "SA5" ) 
				dbSetOrder(1) 
				fErase(cArqNtx + OrdBagExt())

			Else
				lRet := .F.
				//-->> Apenas Saida
				//lRetorno:= Sx5NumNota(@cSerie,cTipoNf)
				MsgRun("Importando NF de Saída... " + StrZero(nZ,3) + "/" + StrZero(Len(aArqTxt),3) , "Aguarde" , {|| lRet := KPIMPPROC( cCaminho+aArqTxt[nZ][1] )} )
				//If lRet
				//	nTam := Len(cNumero)
				//	dbSelectArea("SX5")
				//	dbSeek(cFilial+"01"+cSerie)
				//	SX5->(RecLock("SX5",.F.))
				//	SX5->X5_DESCRI  := StrZero(Val(cNumero)+1,nTam)
				//	SX5->X5_DESCSPA := StrZero(Val(cNumero)+1,nTam)
				//	SX5->X5_DESCENG := StrZero(Val(cNumero)+1,nTam)
				//	SX5->(MsUnlock())
				//Endif
			Endif
		Next nZ
		
		SX1->(dbSetOrder(1))
		If SX1->(dbSeek(cPerg))
			While !SX1->(Eof()) .And. cPerg == alltrim(SX1->X1_GRUPO)
				RecLock("SX1",.F.)
				SX1->X1_CNT01 := Space(60)
				MsUnlock()
				SX1->(dbSkip())
			Enddo
		Endif
		
	EndIf
Else
	MsgAlert("Processo Abortado!")
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ KPIMPXML  ³ Autor ³ Marcio Martins       ³ Data ³12/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao do XML para o Documento de Entrada ou Saida     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ KPIMPPROC(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Arquivo XML                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------------*
 Static Function KPIMPPROC(cArquivo)
*-----------------------------------*

Local oXml
Local oNFe
Local oFat

Local aDados     := {}
Local aCabec     := {}
Local aItemNF    := {}
Local aItens     := {}
Local aSaldos    := {}

Local cError     := ""
Local cXML       := ""
Local cWarning   := ""
Local cArqTmpXml := CriaTrab(,.F.)+".xml"
Local cStrXml    := ''
Local StartPath  := GetSrvProfString("StartPath","")

Local nIndex     := 0
Local nTerHdl    := 0
Local nTamArq    := 0

Local lItemPC    := .F.
Local lRestNfe   := (GetMV('MV_RESTNFE')=='S')
Local aTitulos	 := {}
Local _cChNFEnt  := ""
Local _cChNFSai  := ""

Local xBuffer
Local lRetorno   := .T.
Local cCFOP      := " "
Local cAUTOISS   := GetMv( "MV_AUTOISS"  )

Local dDataEmis  := dDatabase
Local dDataAnt	 := dDatabase
    
Local nAditiv    := 1

Private cPCNum      := ''
Private cPCItem     := ''

Private lMSErroAuto := .F.

Default cTes   := ''
Default cNumPC := ''

nTerHdl := fOpen(cArquivo,2+64)
If nTerHdl <= 0
	Aviso( "Atenção" , "O arquivo não pode ser encontrado em: " + CRLF + CRLF + ;
	cArquivo + CRLF + CRLF + "Dica:" + CRLF + ;
	"Verifique se o arquivo expecificado existe ou se o caminho do arquivo não é muito extenso.", ;
	{"Ok"} , 3 , "Arquivo Inválido" )
	lContinua := .F.
	Return
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

oXml := XmlParserFile( StartPath+"\"+cArqTmpXml , "_" , @cError , @cWarning )

fClose(cArqTmpXml)

If !Empty(cError)
	Aviso( "Atenção" , cError , { "Ok" } , 3 , "Não Foi Possível Abrir o Arquivo" )
	Return
EndIf

oNFe := IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)
                                            
dDataEmis := StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-",""))
dDatabase := dDataEmis

If cEntrSai == 1

	cF1_COD := ""
	cF1_LOJA := ""
	
	If Empty(cFornec)
		If cTpNota $ "DB"
			//-->> Posiciona no Cliente pelo Codigo do Cliente
			SA1->(dbSetOrder(3))
			If !SA1->(dbSeek(xFilial("SA1")+oNFe:_EMIT:_CNPJ:TEXT))
				MsgStop('Não existe Cliente cadastrado com este CNPJ ' + oNFe:_EMIT:_CNPJ:TEXT)
				Return
			EndIf
			cF1_COD  := SA1->A1_COD
			cF1_LOJA := SA1->A1_LOJA
		Else
			//-->> Posiciona no Fornecedor pelo Codigo do Fornecedor
			SA2->(dbSetOrder(3))
			If !SA2->(dbSeek(xFilial("SA2")+oNFe:_EMIT:_CNPJ:TEXT))
				MsgStop('Não existe Fornecedor cadastrado com este CNPJ ' + oNFe:_EMIT:_CNPJ:TEXT)
				Return
			EndIf
			cF1_COD  := SA2->A2_COD
			cF1_LOJA := SA2->A2_LOJA
		EndIf	
	Else
		If cTpNota $ "DB"
			SA1->(dbSetOrder(1))
			If !SA1->(dbSeek(xFilial("SA1")+cFornec))
				MsgStop('Cliente Não Encontrado, Verifique ' + cFornec)
				Return
			EndIf
			cF1_COD  := SA1->A1_COD
			cF1_LOJA := SA1->A1_LOJA
		Else
			SA2->(dbSetOrder(1))
			If !SA2->(dbSeek(xFilial("SA2")+cFornec))
				MsgStop('Fornecedor Não Encontrado, Verifique ' + cFornec)
				Return
			EndIf
			cF1_COD  := SA2->A2_COD
			cF1_LOJA := SA2->A2_LOJA
		EndIf	
	Endif
	
	If cTpNota $ "DB"
		If Empty(SA1->A1_NATUREZ)
			Aviso( 'Ateção' , 'Não há natureza cadastrada para este cliente: ' + SA1->A1_COD + CRLF + CRLF , { 'Ok' } , 2 , 'Natureza Não Cadastrada!' )
			lRetorno := .F.
			Return(lRetorno)
		EndIf	Else
		If Empty(SA2->A2_NATUREZ)
			Aviso( 'Ateção' , 'Não há natureza cadastrada para este fornecedor: ' + SA2->A2_COD + CRLF + CRLF , { 'Ok' } , 2 , 'Natureza Não Cadastrada!' )
			lRetorno := .F.
			Return(lRetorno)
		EndIf
	EndIf	
	
	//-->> Valida existencia do Doc. de Entrada
	SF1->(dbSetOrder(1))
	If SF1->(dbSeek(xFilial('SF1')+StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+PadR(oNFe:_IDE:_SERIE:TEXT,3)+cF1_COD+cF1_LOJA))
		Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo já foi cadastrado!' + CRLF + CRLF + ;
		If(cTpNota $ "DB",'Cliente: ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME),'Fornecedor: ' + SA2->(A2_COD+'/'+A2_LOJA+' '+A2_NOME)) + CRLF + ;
		'Doc./Serie: ' + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+' / '+oNFe:_IDE:_SERIE:TEXT , { 'Ok' } , 2 , 'Documento já cadastrado!' )
		Return
	Else
		_cChNFEnt := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT	
	EndIf
	
	//--> Larson
	If cTpNota == "N" .And. Posicione("SED",1,xFilial("SED")+SA2->A2_NATUREZ,"ED_CALCIRF") == "S" .And. Empty(mv_par12)
		Aviso( 'Ateção' , 'O Código da Retenção do I.R. (DIRF) Não foi preenchido corretamente.' + cF1_COD + CRLF + CRLF , { 'Ok' } , 2 , 'DIRF - Cód. Retenção!' )
		lRetorno := .F.
		Return(lRetorno)
	EndIf
	
	PutMV( "MV_AUTOISS", '{"'+cF1_COD+'","'+cF1_LOJA+'","1","'+mv_par12+'"}' )
	//--> EOL

	If nFPropr==1
	Else
		cNumero := StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)
		cSerie	:= oNFe:_IDE:_SERIE:TEXT
	Endif
	
	//-->> Monta o cabecalho do Doc. de Entrada
	aAdd(aCabec,{"F1_FILIAL"  ,xFilial('SF1')							  ,Nil})
	aAdd(aCabec,{"F1_TIPO"    ,cTpNota									  ,Nil})
	aAdd(aCabec,{"F1_FORMUL"  ,If(nFPropr==1,"S","N")					  ,Nil})
	aAdd(aCabec,{"F1_DOC"     ,cNumero									  ,Nil})
	aAdd(aCabec,{"F1_SERIE"   ,cSerie									  ,Nil})
	aAdd(aCabec,{"F1_FORNECE" ,cF1_COD 									  ,Nil})
	aAdd(aCabec,{"F1_LOJA"    ,cF1_LOJA									  ,Nil})
	aAdd(aCabec,{"F1_EMISSAO" ,StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-","")),Nil})
	aAdd(aCabec,{"F1_ESPECIE" ,"SPED"									  ,Nil})
	aAdd(aCabec,{"F1_COND"    ,cCon										  ,Nil})
	aAdd(aCabec,{"F1_FRETE"   ,Val(oNFe:_Total:_ICMSTot:_vFrete:TEXT)	  ,Nil})
	aAdd(aCabec,{"F1_DESCONT" ,Val(oNFe:_Total:_ICMSTot:_vDesc:TEXT)	  ,Nil})
	aAdd(aCabec,{"F1_SEGURO"  ,Val(oNFe:_Total:_ICMSTot:_vSeg:TEXT)	  ,Nil})
	aAdd(aCabec,{"F1_VALBRUT" ,Val(oNFe:_Total:_ICMSTot:_vNF:TEXT)		  ,Nil})
	aAdd(aCabec,{"F1_DESPESA" ,nVrDesp									  ,Nil})
	aAdd(aCabec,{"F1_NFORIG"  ,cNFORIG									  ,Nil})
	aAdd(aCabec,{"F1_SERORIG" ,cOri										  ,Nil})
	aAdd(aCabec,{"E2_NATUREZ" ,SA2->A2_NATUREZ                           ,Nil})
	//aAdd(aCabec,{"F1_CHVNFE" ,_cChNFEnt				                  ,Nil})
	
	//-->> Monta o aDados para Importar os itens da NF-e
	If ValType(oNFe:_DET) == "A"
		For nX := 1 To Len(oNFe:_DET)
			aAdd( aDados , { 	oNFe:_DET[nX]:_NITEM:TEXT				,;	// 01 - Item
			oNFe:_DET[nX]:_PROD:_CPROD:TEXT			,;	// 02 - Codigo do Produto no Fornec
			oNFe:_DET[nX]:_PROD:_UCOM:TEXT			,;	// 03 - Unidade de Medida
			Val(oNFe:_DET[nX]:_PROD:_QCOM:TEXT)	,;	// 04 - Quantidade
			Val(oNFe:_DET[nX]:_PROD:_VUNCOM:TEXT)	,;	// 05 - Valor Unitario
			Val(oNFe:_DET[nX]:_PROD:_VPROD:TEXT)	,;	// 06 - Valor Total do Total
			oNFe:_DET[nX]:_PROD:_XPROD:TEXT			,;	// 07 - Descricao do Produto
			oNFe:_DET[nX]:_PROD:_CFOP:TEXT			})	// 08 - CFOP			
		Next nX
	Else
		aAdd( aDados , { 	oNFe:_DET:_NITEM:TEXT						,;	// 01 - Item
		oNFe:_DET:_PROD:_CPROD:TEXT					,;	// 02 - Codigo do Produto no Fornec
		oNFe:_DET:_PROD:_UCOM:TEXT					,;	// 03 - Unidade de Medida
		Val(oNFe:_DET:_PROD:_QCOM:TEXT)				,;	// 04 - Quantidade
		Val(oNFe:_DET:_PROD:_VUNCOM:TEXT)			,;	// 05 - Valor Unitario
		Val(oNFe:_DET:_PROD:_VPROD:TEXT)			,;	// 06 - Valor Total do Total
		oNFe:_DET:_PROD:_XPROD:TEXT					,;	// 07 - Descricao do Produto
		oNFe:_DET:_PROD:_CFOP:TEXT			   		})	// 08 - CFOP			
	EndIf
	
	SB1->(dbSetOrder(1))
	nAditiv := 1
	For nx := 1 To Len(aDados)
		
		//-->> Posiciona na amarracao Produto
		If cTpNota $ "DB"
			If !SB1->(dbSeek(xFilial('SB1')+aDados[Nx,2]))
				Loop
			EndIf	
		Else
			If !(SA5->(dbSeek(xFilial("SA5")+cF1_COD+cF1_LOJA+aDados[Nx,2])) .And. SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO)))
				If !SB1->(dbSeek(xFilial('SB1')+aDados[Nx,2]))
					Loop
				EndIf	
			EndIf
		EndIf
		
		//-->> Define a TES caso digitado 000 utiliza TE Padr
		cTesE := IIf(Empty(cTes),SB1->B1_TE,cTes)
		cCFOP := Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")
		
		//-->> Verifica se existe TE cadastrado para o Produto
		If Empty(cTesE)
			MsgStop('Tipo de Entrada padrão não cadastrado para o produto ' + SB1->B1_COD + '!')
			Return
		EndIf
		
		//-->> Monta o array com os itens do Doc. de Entrada
		If     Left(aDados[nx,08],1) == "5"
			cCFOP := "1"+Right(aDados[nX,8],3)
		ElseIf Left(aDados[nx,08],1) == "6"
			cCFOP := "2"+Right(aDados[nX,8],3)
		ElseIf Left(aDados[nx,08],1) == "7"
			cCFOP := "3"+Right(aDados[nX,8],3)
		EndIf	

		aItens := {}
		aAdd( aItens , {"D1_FILIAL"  ,xFilial('SD1')										,Nil} )
		aAdd( aItens , {"D1_DOC"     ,cNumero												,Nil} )
		aAdd( aItens , {"D1_SERIE"   ,cSerie												,Nil} )
		aAdd( aItens , {"D1_FORNECE" ,cF1_COD									 			,Nil} )
		aAdd( aItens , {"D1_LOJA"    ,cF1_LOJA												,Nil} )
		aAdd( aItens , {"D1_COD"     ,SB1->B1_COD											,Nil} )
		aAdd( aItens , {"D1_UM"      ,SB1->B1_UM											,Nil} )
		If lItemPC
			aAdd( aItens , {"D1_PEDIDO"  ,SC7->C7_NUM	,Nil} )
			aAdd( aItens , {"D1_ITEMPC"    ,SC7->C7_ITEM	,Nil} )
		EndIf
		aAdd( aItens , {"D1_QUANT"   ,If(aDados[nx,04]>0,aDados[nX,04],1)					,Nil} )
		aAdd( aItens , {"D1_VUNIT"   ,If(aDados[nx,05]>0,aDados[nX,05],1)					,Nil} )
		aAdd( aItens , {"D1_TOTAL"   ,aDados[nx,06]											,Nil} )
		aAdd( aItens , {"D1_TES"     ,cTesE													,Nil} )
		aAdd( aItens , {"D1_CF"      ,cCFOP				    								,Nil} )
		aAdd( aItens , {"D1_LOCAL"   ,If(!Empty(SB1->B1_LOCPAD),SB1->B1_LOCPAD,"01")		,Nil} )
		aAdd( aItens , {"D1_ITEM"    ,StrZero(Val(aDados[nx,01]),Len(CriaVar("D1_ITEM"))),Nil} )
		
		// solicitado pela Camila
		If SD1->(FieldPos("D1_X_ADIC")) > 0
			aAdd( aItens , {"D1_X_ADIC"     ,"001"											,Nil} )
		EndIf
		
		If SD1->(FieldPos("D1_X_SQADI")) > 0
			aAdd( aItens , {"D1_X_SQADI"     ,StrZero(nAditiv,3)							,Nil} )
		EndIf
		
		If SD1->(FieldPos("D1_X_FABR")) > 0
			aAdd( aItens , {"D1_X_FABR"     ,cF1_COD									,Nil} )
		EndIf		
		//
		
		nAditiv++
		
		aAdd( aItemNF, aItens )
		IF cTpNota =="CIPI" .and. aDados[NX,05] == aDados[NX,06] .and. !EMPTY(cNFORIG)
			aAdd( aItens , {"D1_NFORIG"    	,cNFORIG										,Nil} )
			aAdd( aItens , {"D1_SERIORI"   	,cORI											,Nil} )
			aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
			aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
			IF cTpNota =="CIPI" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
				MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
				Return
			EndIF
		Else
			IF cTpNota =="CICM" .and. aDados[NX,05] == aDados[NX,06] .and. !EMPTY(cNFORIG)
				aAdd( aItens , {"D1_NFORIG"    	,cNFORIG										,Nil} )
				aAdd( aItens , {"D1_SERIORI"   	,cORI											,Nil} )
				aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
				aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
				IF cTpNota =="CICM" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
					MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
					Return
				ENDIF
			ELse
				
				IF cTpNota =="D" .and. !EMPTY(cNFORIG)
					aAdd( aItens , {"D1_NFORIG"    	,cNFORIG										,Nil} )
					aAdd( aItens , {"D1_SERIORI"   	,cORI											,Nil} )
					aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
					aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
					IF cTpNota =="D" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
						MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
						Return
					Endif
				Else
					
					IF cTpNota =="B" .and. !EMPTY(cNFORIG)
						aAdd( aItens , {"D1_NFORIG"    	,cNFORIG										,Nil} )
						aAdd( aItens , {"D1_SERIORI"   	,cORI											,Nil} )
						aAdd( aItens , {"D1_TES"     	,cTes											,Nil} )
						aAdd( aItens , {"D1_CF"     	,cCFOP				    						,Nil} )
						IF cTpNota =="B" .and. aDados[NX,05]<>aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
							MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
							Return
						Endif
					Endif
				Endif
			Endif
		Endif
	Next nx
	
	
	If nClass == 1
		//-->> Processa a rotina automatica MATA103
		MsExecAuto( { |x,y,z,a| Mata103(x,y,z,a) }, aCabec, aItemNF, 3 )
	Else
		//-->> Processa a rotina automatica MATA140
		MSExecAuto( { |x,y,z  | Mata140(x,y,z)} , aCabec , aItemNF , 3 )
		//MSExecAuto( { |x,y,z  | U_ak140(x,y,z)} , aCabec , aItemNF , 3 )
	Endif
	
	If lMsErroAuto
		MostraErro()
		lRetorno := .F.
	Else
		__CopyFile(cArquivo, cArquivo+".OK")
		FERASE(cArquivo)
		lRetorno := .T.
		
		  DbselectArea("SF1")
		  DBSetOrder(1)
		  If dbSeek(xFilial('SF1') + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) + PadR(oNFe:_IDE:_SERIE:TEXT,3) + cF1_COD+cF1_LOJA)		  
			  RecLock("SF1",.F.)
			  SF1->F1_CHVNFE := _cChNFEnt
			  SF1->(MSUnlock())
		  EndIf
		  
		  DbselectArea("SF3")
		  DBSetOrder(5)
		  If DbSeek(xFilial('SF3') + PadR(oNFe:_IDE:_SERIE:TEXT,3) + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) + cF1_COD+cF1_LOJA)
			  While !SF3->(Eof()) .AND. F3_NFISCAL == StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) .AND. F3_SERIE == PadR(oNFe:_IDE:_SERIE:TEXT,3)
				  If F3_CF0 ==  Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")
					  RecLock("SF3",.F.)
					  F3_CHVNFE := _cChNFEnt
					  MSUnlock()
				  EndIf  		  
			  EndDo  
		  EndIf
		  
		  DbselectArea("SFT")
		  DBSetOrder()
		  If DbSeek(xFilial('SFT') + 'E' + PadR(oNFe:_IDE:_SERIE:TEXT,3) + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) + cF1_COD+cF1_LOJA)
			  RecLock("SFT",.F.)
			  FT_CHVNFE := _cChNFEnt
			  MSUnlock()		  		  
		  EndIf		  		  		  

		
	Endif
	
	SA2->(dbCloseArea())
	SE2->(dbCloseArea())
	SF1->(dbCloseArea())
	SD1->(dbCloseArea())
	
Else

	cNumero := StrZero(Val(oNFe:_IDE:_NNF:TEXT),Tamsx3("F2_DOC")[1])
	cSerie	:= Padr(oNFe:_IDE:_SERIE:TEXT,Tamsx3("F2_SERIE")[1])    
	_cChNFEnt := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT	
	
	//-->> Posiciona no Cliente pelo CNPJ
	If Empty(cCliente)
		SA1->(dbSetOrder(3))
		If !SA1->(dbSeek(xFilial("SA1")+oNFe:_DEST:_CNPJ:TEXT))
			MsgStop('Não existe Cliente cadastrado com este CNPJ ' + oNFe:_DEST:_CNPJ:TEXT)
			lRetorno := .F.
			Return(lRetorno)
		EndIf
	Else
		SA1->(dbSetOrder(1))
		If !SA1->(dbSeek(xFilial("SA1")+cCliente))
			MsgStop('Fornecedor Não Encontrado, Verifique ' + cCliente)
			lRetorno := .F.
			Return(lRetorno)
		EndIf
	Endif
	
	//-->> Valida existencia do Doc. de Saida
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(xFilial('SF2')+StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+PadR(oNFe:_IDE:_SERIE:TEXT,3)+SA1->(A1_COD+A1_LOJA)))
		Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo já foi cadastrado!' + CRLF + CRLF + ;
		'Cliente:    ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME) + CRLF + ;
		'Doc./Serie: ' + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+' / '+oNFe:_IDE:_SERIE:TEXT , { 'Ok' } , 2 , 'Documento já cadastrado!' )
		Return
	Else
		_cChNFSai := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT		
	EndIf
	
	//-->> Monta o cabecalho do Doc. de Saida
	aAdd(aCabec,{"F2_FILIAL"  ,xFilial('SF2')								,Nil})
	aAdd(aCabec,{"F2_TIPO"    ,cTpNota										,Nil})
	aAdd(aCabec,{"F2_FORMUL"  ,"S"            								,Nil})
	aAdd(aCabec,{"F2_DOC"     ,cNumero										,Nil})
	aAdd(aCabec,{"F2_SERIE"   ,cSerie										,Nil})
	aAdd(aCabec,{"F2_CLIENTE" ,SA1->A1_COD									,Nil})
	aAdd(aCabec,{"F2_LOJA"    ,SA1->A1_LOJA									,Nil})
	aAdd(aCabec,{"F2_EMISSAO" ,StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-",""))	,Nil})
	aAdd(aCabec,{"F2_ESPECIE" ,"SPED"										,Nil})
	aAdd(aCabec,{"F2_COND"    ,cCon											,Nil})
	aAdd(aCabec,{"F2_FRETE"   ,Val(oNFe:_Total:_ICMSTot:_vFrete:TEXT)		,Nil})
	aAdd(aCabec,{"F2_DESCONT" ,Val(oNFe:_Total:_ICMSTot:_vDesc:TEXT)		,Nil})
	aAdd(aCabec,{"F2_SEGURO"  ,Val(oNFe:_Total:_ICMSTot:_vSeg:TEXT)		,Nil})
	aAdd(aCabec,{"F2_DESPESA" ,nVrDesp										,Nil})
	aAdd(aCabec,{"F2_VALBRUT" ,Val(oNFe:_Total:_ICMSTot:_vNF:TEXT)			,Nil})
	aAdd(aCabec,{"F2_NFORI" ,CNFORIG										,Nil})
	aAdd(aCabec,{"F2_NFORI" ,cOri    										,Nil})
	aAdd(aCabec,{"F2_CHVNFE" ,_cChNFSai					,Nil})
	
	//-->> Monta o aDados para Importar os itens da NF-e
	If ValType(oNFe:_DET) == "A"
		For nX := 1 To Len(oNFe:_DET)
			aAdd( aDados , { 	oNFe:_DET[nX]:_NITEM:TEXT	,;	// 01 - Item
			oNFe:_DET[nX]:_PROD:_CPROD:TEXT	   				,;	// 02 - Codigo do Produto no Fornec
			oNFe:_DET[nX]:_PROD:_UCOM:TEXT					,;	// 03 - Unidade de Medida
			Val(oNFe:_DET[nX]:_PROD:_QCOM:TEXT)				,;	// 04 - Quantidade
			Val(oNFe:_DET[nX]:_PROD:_VUNCOM:TEXT)			,;	// 05 - Valor Unitario
			Val(oNFe:_DET[nX]:_PROD:_VPROD:TEXT)			,;	// 06 - Valor Total do Total
			oNFe:_DET[nX]:_PROD:_XPROD:TEXT			,;			// 07 - Descricao do Produto
			oNFe:_DET[nX]:_PROD:_CFOP:TEXT			})	// 08 - CFOP			
		Next nX
	Else
		aAdd( aDados , { 	oNFe:_DET:_NITEM:TEXT			,;	// 01 - Item
		oNFe:_DET:_PROD:_CPROD:TEXT							,;	// 02 - Codigo do Produto no Fornec
		oNFe:_DET:_PROD:_UCOM:TEXT							,;	// 03 - Unidade de Medida
		Val(oNFe:_DET:_PROD:_QCOM:TEXT)						,;	// 04 - Quantidade
		Val(oNFe:_DET:_PROD:_VUNCOM:TEXT)					,;	// 05 - Valor Unitario
		Val(oNFe:_DET:_PROD:_VPROD:TEXT)					,;	// 06 - Valor Total do Total
			oNFe:_DET[nX]:_PROD:_XPROD:TEXT			,;			// 07 - Descricao do Produto
			oNFe:_DET[nX]:_PROD:_CFOP:TEXT			})	// 08 - CFOP			
	EndIf
	
	SB1->(dbSetOrder(1))
	For nx := 1 To Len(aDados)
		
		SB1->(dbSeek(xFilial("SB1")+aDados[nX,2]))
		
		//-->> Define a TES caso digitado 000 utiliza TE Padrao
		cTesE := IIf(Empty(cTes),SB1->B1_TS,cTes)
		
		//-->> Verifica se existe TE cadastrado para o Produto
		If Empty(cTesE)
			MsgStop('Tipo de Entrada padrão não cadastrado para o produto ' + SB1->B1_COD + '!')
			Return
		EndIf

		//-->> Monta o array com os itens do Doc. de Saida
		aItens := {}
		aAdd( aItens , {"D2_FILIAL"  ,xFilial('SD2')										,Nil} )
		aAdd( aItens , {"D2_DOC"     ,StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)					,Nil} )
		aAdd( aItens , {"D2_SERIE"   ,oNFe:_IDE:_SERIE:TEXT								,Nil} )
		aAdd( aItens , {"D2_CLIENTE" ,SA1->A1_COD											,Nil} )
		aAdd( aItens , {"D2_LOJA"    ,SA1->A1_LOJA											,Nil} )
		aAdd( aItens , {"D2_COD"     ,SB1->B1_COD											,Nil} )
		aAdd( aItens , {"D2_UM"      ,SB1->B1_UM											,Nil} )
		aAdd( aItens , {"D2_QUANT"   ,If(aDados[nx,04]>0,aDados[nX,04],1)					,Nil} )
		aAdd( aItens , {"D2_PRCVEN"  ,If(aDados[nx,05]>0,aDados[nX,05],1)					,Nil} )
		aAdd( aItens , {"D2_TOTAL"   ,aDados[nx][06]										,Nil} )
		aAdd( aItens , {"D2_TES"     ,cTesE													,Nil} )
		aAdd( aItens , {"D2_CF"      ,aDados[nX,8]										    ,Nil} )
		aAdd( aItens , {"D2_LOCAL"   ,If(!Empty(SB1->B1_LOCPAD),SB1->B1_LOCPAD,"01")		,Nil} )
		aAdd( aItens , {"D2_ORIGLAN" ,"  " 													,Nil} )
		aAdd( aItens , {"D2_CUSTO1"  ,Posicione("SB2",1,xFilial("SB2")+SB1->B1_COD,"B2_CM1") * SD2->D2_QUANT	,Nil} )
		aAdd( aItens , {"D2_ITEM"    ,StrZero(Val(aDados[nx][01]),Len(CriaVar("D2_ITEM"))),Nil} )
		
		aAdd( aItemNF, aItens )
		IF cTpNota =="CICM" .and. aDados[NX,05] == aDados[NX,06] .and. !EMPTY(cNFORIG)
			aAdd( aItens , {"F1_NFORI"     ,cNFORIG											,Nil} )
			aAdd( aItens , {"F1_SERIORI"     ,cORI												,Nil} )
			aAdd( aItens , {"F1_TES"     ,cTes												,Nil} )
			aAdd( aItens , {"F1_CF"     ,Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")		,Nil} )
			
			IF cTpNota =="CIPI" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
				MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
			EndIF
		Else
			IF cTpNota =="CICM" .and. aDados[NX,05] == aDados[NX,06] .and. !EMPTY(cNFORIG)
				aAdd( aItens , {"F1_NFORI"     ,cNFORIG											,Nil} )
				aAdd( aItens , {"F1_SERIORI"     ,cORI												,Nil} )
				aAdd( aItens , {"F1_TES"     ,cTes												,Nil} )
				aAdd( aItens , {"F1_CF"     ,Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")		,Nil} )
				IF cTpNota =="CICM" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
					MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
				ENDIF
			ELse
				
				IF cTpNota =="D" .and. !EMPTY(cNFORIG)
					aAdd( aItens , {"F1_NFORI"     ,cNFORIG											,Nil} )
					aAdd( aItens , {"F1_SERIORI"     ,cORI												,Nil} )
					aAdd( aItens , {"F1_TES"     ,cTes												,Nil} )
					aAdd( aItens , {"F1_CF"     ,Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")		,Nil} )
					IF cTpNota =="D" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
						MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
					Endif
					
				Else
					
					IF cTpNota =="B" .and. !EMPTY(cNFORIG)
						aAdd( aItens , {"F1_NFORI"     ,cNFORIG											,Nil} )
						aAdd( aItens , {"F1_SERIORI"     ,cORI												,Nil} )
						aAdd( aItens , {"F1_TES"     ,cTes												,Nil} )
						aAdd( aItens , {"F1_CF"     ,Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")		,Nil} )
						IF cTpNota =="B" .and. aDados[NX,05] > aDados[NX,06] .and. !EMPTY(cNFORIG) .OR. EMPTY(cNFORIG)
							MSGSTOP("Verificar se nota de origem foi informado e se o valor unitario" + CRLF + "esta igual ao total do item. Nota "+cnumero)
						Endif
						
					Endif
				Endif
			Endif
		Endif
	Next nx
	
	//-->> Processa a rotina automatica MATA920
	MsExecAuto( { |x,y,z,a| Mata920(x,y,z) }, aCabec, aItemNF , 3 )
	
	If lMsErroAuto                           
		MostraErro()
	Else
		//-->> Param 01 -> Tes
		//-->> Param 02 -> F2_VALBRUT
		//-->> Param 03 -> Condicao de Pagamento
		//-->> Param 04 -> Numero da Nota
		//-->> Param 05 -> Serie da Nota
		GeraTitulo(cTesE,Val(oNFe:_Total:_ICMSTot:_vNF:TEXT),cCon,cNumero,cSerie)
		__CopyFile(cArquivo, cArquivo+".OK")
		FERASE(cArquivo)
		
      	DbselectArea("SF2")
	  	DBSetOrder(1)
	  	
	  	If dbSeek(xFilial('SF2')+cNumero+cSerie+SA1->(A1_COD+A1_LOJA))
	  	//If dbSeek(xFilial('SF2')+StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+PadR(oNFe:_IDE:_SERIE:TEXT,3)+SA1->(A1_COD+A1_LOJA))		  
	  		RecLock("SF2",.F.)
	  		F2_CHVNFE := _cChNFEnt
	  		MSUnlock()		  
	  	EndIf
	  
	  	SD2->(dbSetOrder(3)) 
		//If SD2->(dbSeek(xFilial("SD2")+StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+PadR(oNFe:_IDE:_SERIE:TEXT,3)))
		//  While !SD2->(Eof()) .And. xFilial("SD2")+StrZero(Val(oNFe:_IDE:_NNF:TEXT),9)+PadR(oNFe:_IDE:_SERIE:TEXT,3) == SD2->(D2_FILIAL+D2_DOC+D2_SERIE)
		If SD2->(dbSeek(xFilial("SD2")+cNumero+cSerie))
		  While !SD2->(Eof()) .And. xFilial("SD2")+cNumero+cSerie == SD2->(D2_FILIAL+D2_DOC+D2_SERIE)
			  RecLock("SD2",.F.)
			  SD2->D2_ORIGLAN := "  "
			  SD2->D2_CUSTO1  := Posicione("SB2",1,xFilial("SB2")+SD2->D2_COD,"B2_CM1") * SD2->D2_QUANT
			  SD2->(MsUnLock())	  	       
		  	  
		  	  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ajuste realizado por Marcelo Celi - Akron      ³
				//³no dia 26/03/2013 *****************************³
				//³Observacao: Mata920 nao trata poder 3.		  ³
				//³Atualiza Poder de Terceiro apos chamada		  ³
				//³ da rot. automatica. 						  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_PODER3")<>"N" 
					RecLock("SD2")
					MaAtuSB6("SD2",3)
				EndIf
				
		  	  SD2->(dbSkip())
		  EndDo
		EndIf
		  
	  DbselectArea("SF3")
	  DBSetOrder(5)
	  //If DbSeek(xFilial('SF3') + PadR(oNFe:_IDE:_SERIE:TEXT,3) + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) + SA2->(A2_COD+A2_LOJA))
	  //  While !SF3->(Eof()) .AND. F3_NFISCAL == StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) .AND. F3_SERIE == PadR(oNFe:_IDE:_SERIE:TEXT,3)
	  If DbSeek(xFilial('SF3') + cSerie + cNumero + SA1->(A1_COD+A1_LOJA))
		  While !SF3->(Eof()) .AND. F3_NFISCAL == cNumero .AND. F3_SERIE == cSerie
			  If F3_CFO ==  Posicione("SF4",1,xFilial("SF4")+cTesE,"F4_CF")
				  RecLock("SF3",.F.)
				  F3_CHVNFE := _cChNFEnt
				  MSUnlock()
			  EndIf  		  
			  SF3->(dbSkip())
		  EndDo  
	  EndIf
	  
	  DbselectArea("SFT")
	  DBSetOrder()                                                                                                                 
	  //If DbSeek(xFilial('SFT') + 'S' + PadR(oNFe:_IDE:_SERIE:TEXT,3) + StrZero(Val(oNFe:_IDE:_NNF:TEXT),9) + SA1->(A1_COD+A1_LOJA))
	  If DbSeek(xFilial('SFT') + 'S' + cSerie + cNumero + SA1->(A1_COD+A1_LOJA))
		  RecLock("SFT",.F.)
		  FT_CHVNFE := _cChNFEnt
		  MSUnlock()		  		  
	  EndIf	 		 

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajuste realizado por Marcelo Celi - Akron      ³
		//³no dia 02/02/2012 *****************************³
		//³Observacao: Mata920 nao trata estoque.		  ³
		//³Baixa estoque apos chamada da rot. automatica. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IIf(FindFunction("u_KPMEsDSai"),u_KPMEsDSai(),.T.)
				
		SA1->(dbCloseArea())
		SE1->(dbCloseArea())
		SF2->(dbCloseArea())
		SD2->(dbCloseArea())
		
	Endif
EndIf

PutMv( "MV_AUTOISS", cAUTOISS )
dDatabase := dDataAnt

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Empresa  ³ AKRON Projetos e Sistemas                                  ³±±
±±³          ³ Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ KPLocXML  ³ Autor ³ Marcio Martins       ³ Data ³12/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Permite o usuario selecionar o local de gravacao do arquivo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------------*
 User Function KPLocXML()
*-----------------------------------*

Local cFile

//If Empty(MV_PAR02)
cFile 		:= UPPER(cGetFile("C:\","Selecione o diretório do Arq. XML...",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE))
//	MV_PAR02 	:= cFile
//Endif

Return(cFile)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ STNFSX5  ³ Autor ³ Larson Zordan         ³ Data ³25/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o numero da NF automaticamente                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Serie da NF (por referencia)                        ³±±
±±³          ³ ExpC2: conteudo do parametro MV_TPNRNFS                    ³±±
±±³          ³ ExpC3: Numero da NF do Legado                              ³±±
±±³          ³ ExpC4: Serie da NF do Legado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 : .T. Continua      .F. Aborta o Processo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SANTANA TEXTILES                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*--------------------------------------------------------*
 Static Function STNFSX5(cSerie,cTpNrNFS,cNFS,cSerieS)
*--------------------------------------------------------*

Local cFilSx5   := xFilial("SX5")
Local cSerNF 	:= cSerieS
Local lRet      := .T.
Local nVezes    := 0

SX5->(dbSetOrder(1))
If SX5->(dbSeek(cFilSX5+"01"+cSerNF))
	If !Empty(cNFS)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cNFS
		SX5->(MsUnLock())
	Else
		cNFs := AllTrim(SX5->X5_DESCRI)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava os registro do SX5                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX5->(MsRUnLock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava o parametro                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( GetMv("MV_NUMITEN",.T.) )
	SX6->(MsRUnLock())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Compatibilizacao com versoes antigas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerie  := cSerieS
cNumero := cNFs

Return(lRet)



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
±±³          ³       cPar04 -> Numero do Título/Nota                      ³±±
±±³          ³       cPar05 -> Prefixo/Serie                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTitulo(cTes,nTotal,cCon,cTitulo,cPrefixo)

Local cParcela  := "1"
Local aVetor	:= {}

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
		
		aVetor  := {	{"E1_PREFIXO"	,cPrefixo			,Nil},;
		{"E1_NUM"		,cTitulo			,Nil},;
		{"E1_PARCELA"	,cParcela			,Nil},;
		{"E1_TIPO"		,"NF "				,Nil},;
		{"E1_NATUREZ"	,SA1->A1_NATUREZ	,Nil},;
		{"E1_CLIENTE"	,SA1->A1_COD		,Nil},;
		{"E1_LOJA"		,SA1->A1_LOJA   	,Nil},;
		{"E1_EMISSAO"	,dDataBase       	,Nil},;
		{"E1_VENCTO"	,aDiaPag[nX,1]     	,Nil},;
		{"E1_VENCREA"	,aDiaPag[nX,1]		,Nil},;
		{"E1_VALOR"		,aDiaPag[nX,2]		,Nil},;
		{"E1_VEND1"		,SA1->A1_VEND		,Nil},;
		{"E1_BASCOM1"	,aDiaPag[nX,2]		,Nil},;
		{"E1_COMIS1"	,SA1->A1_COMIS		,Nil}}
		
		MsgRun("Gerando Titulo a Receber: Parc. " + Str(nX,2) + "/" + Str(Len(aDiaPag),2),"Aguarde", {|| MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) }) //Inclusao
		
		If lMsErroAuto
			MostraErro()
			Return
		EndIf
		
	Next nX
	
Endif

Return
