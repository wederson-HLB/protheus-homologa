//--------------------------------------------------------------------------------------------------------------------------------------------//
// Wederson L. Santana - HLB - 15/03/2020
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Espec�fico Akamai                                                                                                                          //          
// Faturamento / Compras                                                                                                                      //
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Importa��o do faturamento/compras, gera��o de movimenta��o no estoque, gera��o do financeiro e escritura��o fiscal do documento.           //
//--------------------------------------------------------------------------------------------------------------------------------------------//

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE VALMERC		1 // Valor total do mercadoria liquido
#DEFINE VALDESC		2 // Valor total do desconto
#DEFINE FRETE		3 // Valor total do Frete
#DEFINE VALDESP		4 // Valor total da despesa
#DEFINE TOTF1		5 // Total de Despesas Folder 1
#DEFINE TOTPED		6 // Total do Pedido
#DEFINE SEGURO		7 // Valor total do seguro
#DEFINE TOTF3		8 // Total utilizado no Folder 3
#DEFINE VALMERCB	9 // Valor total do mercadoria bruto
#DEFINE NTRIB		10// Valor das despesas nao tributadas 
#DEFINE TARA		11// Valor da Tara 
#DEFINE TPFRETE     12// Tipo de Frete.

User Function 50FIS001(xAutoCab,xAutoItens,nOpcAuto,lLoteAux)
Local lSped      := .F.
Local cFiltraSD2 := ""
Local aFixe      :={ { "Numero da NF","D2_DOC    " },; //"Numero da NF"
	                 { "Serie da NF ","D2_SERIE  " },; //"Serie da NF "
	                 { "Cliente     ","D2_CLIENTE" } } //"Cliente     "

Local aCores    := { 	{'D2_TIPO=="N"'		,'DISABLE'   	},;	// NF Normal
						{'D2_TIPO=="P"'		,'BR_AZUL'   	},;	// NF de Compl. IPI
						{'D2_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
						{'D2_TIPO=="C"'		,'BR_PINK'   	},;	// NF de Compl. Preco/Frete
						{'D2_TIPO=="B"'		,'BR_CINZA'  	},;	// NF de Beneficiamento
						{'D2_TIPO=="D"'		,'BR_AMARELO'	} }	// NF de Devolucao

Default nOpcAuto     := 3
Default lLoteAux     := .F.

PRIVATE cEstNeg      := AllTrim(GetMv("MV_ESTNEG"))
    
PRIVATE l920Auto     := ValType(xAutoCab) == "A" .and. ValType(xAutoItens) == "A"
PRIVATE aAutoItens   := {}
PRIVATE aAutoCab     := {}
PRIVATE aRotina  	 := UTMenu()
PRIVATE lLoteAuto	 := lLoteAux

PRIVATE lGeraNum     := .F.
PRIVATE cTES         := ""
Private cDirLog      := ""
Private cArqLog      := ""
Private cTpTes       := ""
Private lMSErroAuto  := .F.
Private nSaldo       := 0
Private aLogXml      := {}
Private lVldTes		:= .F.
Private lMsg		:= .T.           
Private cEspecieDoc := "SPED"

Private nServ   := 0
Private nProd   := 0

Private aLogErro := {}

Private cDirXmlUT:=""
Private cArqXmlUT:=""

Private cNumNF   :=""
Private cSerieNF :=""

Private oNFe
Private lFin     :=.T.
Private lCanc    :=.F.

STATIC aNFItem
STATIC cSX6FilAnt  := cFilAnt
STATIC aItemRef
STATIC aCabRef
STATIC aResRef
STATIC aLFIS
STATIC aPE
STATIC aSX6
STATIC aDic
STATIC aPos
STATIC aRefSX3
STATIC lHistorico  := .F.
STATIC NMAXIV := 3
STATIC NMAXUF := 3
STATIC cDedBsPC := ""
STATIC aDic 
STATIC NF_UFXUF := 1
STATIC nPICMS
STATIC nICMSTRIB  := 0
STATIC nICMSISEN  := 0
STATIC nICMSOUT   := 0
STATIC nICMSOBS   := 0
STATIC nIPITRIB   := 0
STATIC nIPIISEN   := 0
STATIC nIPIOUT    := 0
STATIC nIPIOBS    := 0
STATIC aSF3       := {}
STATIC aSFT       := {}

lSped	:=	cPaisLoc == "BRA"

mv_par01	:=	2
mv_par02	:=	2
mv_par03	:=	2

If cEmpAnt == "UT".Or.cEmpAnt == "99"

If l920Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"SF2")
Else
    PRIVATE cCadastro	:= OemToAnsi("Importador Notas Fiscais de Saida - G.I.M Amazzoni") 

	cFiltraSD2 := "	R_E_C_N_O_ IN ( "
	cFiltraSD2 += "				SELECT R_E_C_N_O_ "
	cFiltraSD2 += "				FROM  "
	cFiltraSD2 += "					" + RetSqlName("SD2") "
	cFiltraSD2 += "				WHERE D_E_L_E_T_ = ' ' AND D2_ORIGLAN = 'HB')"

    MBrowse( 6, 1,22,75,"SD2",aFixe,"D2_TES",,,,aCores,,,,,,,,cFiltraSD2) 
EndIf
else
    MsgINfo("Espec�fico G.I.M.","A t e n � � o")
EndIf	
Return

//-------------------------------------------------------------------
//Wederson

User Function UTXmlExc()
Local aArea  :=GetArea()
Local aVetor :={}
Local aSB2   :={}
Local lSe1   :=.T.
Local lSft   :=.F.
Local lSf3   :=.F.
Local lSf2   :=.F.
Local lSd2   :=.F.
Local cD2_DOC     := SD2->D2_DOC
Local cD2_SERIE   := SD2->D2_SERIE
Local cD2_CLIENTE := SD2->D2_CLIENTE
Local cD2_LOJA    := SD2->D2_LOJA

If MsgYesNo("Deseja excluir os dados importados do documento: "+Chr(10)+Chr(13)+SD2->D2_DOC+"-"+SD2->D2_SERIE, "A T E N � � O")

   dbSelectArea("SE1")
   dbSetOrder(1) 
   If dbSeek(xFilial("SE1")+cD2_SERIE+cD2_DOC)  
      While! Eof().And.xFilial("SE1")+cD2_SERIE+cD2_DOC == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM 
             aVetor	:= {}

             aVetor  := {	{"E1_PREFIXO"	,SE1->E1_PREFIXO	,Nil},;
						    {"E1_NUM"		,SE1->E1_NUM		,Nil},;
						    {"E1_PARCELA"	,SE1->E1_PARCELA	,Nil},;
						    {"E1_TIPO"		,SE1->E1_TIPO		,Nil},;
						    {"E1_NATUREZ"	,SE1->E1_NATUREZ    ,Nil},;
						    {"E1_CLIENTE"	,SE1->E1_CLIENTE	,Nil},;
						    {"E1_LOJA"		,SE1->E1_LOJA   	,Nil},;
						    {"E1_EMISSAO"	,SE1->E1_EMISSAO    ,Nil},;
						    {"E1_VENCTO"	,SE1->E1_VENCTO     ,Nil},;
						    {"E1_VENCREA"	,SE1->E1_VENCREA	,Nil},;
						    {"E1_VALOR"		,SE1->E1_VALOR		,Nil},;
						    {"E1_VEND1"		,SE1->E1_VEND1		,Nil},;
						    {"E1_BASCOM1"	,SE1->E1_BASCOM1	,Nil},;
						    {"E1_ORIGEM"    ,SE1->E1_ORIGEM		,Nil},;
						    {"E1_COMIS1"	,SE1->E1_COMIS1		,Nil}}

		    MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
   
            If lMsErroAuto
			   DisarmTransaction()
			   MostraErro()
			   lSe1 :=.F.
			   Exit
		    EndIf
			dbSelectArea("SE1")
			dbSkip()
      End
   EndIf

   If lSe1 
      dbSelectArea("SFT")
	  dbSetOrder(1)
	  If dbSeek(xFilial("SFT")+"S"+cD2_SERIE+cD2_DOC+cD2_CLIENTE+cD2_LOJA)
         While! Eof().And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+cD2_SERIE+cD2_DOC+cD2_CLIENTE+cD2_LOJA
               lSft:=.T.
			   Reclock("SFT",.F.)
			   dbDelete()
			   MsunLock()
               dbSkip()
         End 
	  EndIf

      If lSft
	     dbSelectArea("SF3")
	     dbSetOrder(5)
	     If dbSeek(xFilial("SF3")+cD2_SERIE+cD2_DOC+cD2_CLIENTE+cD2_LOJA)
            While! Eof().And. SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA == xFilial("SF3")+cD2_SERIE+cD2_DOC+cD2_CLIENTE+cD2_LOJA
                   lSf3:=.T.
			       Reclock("SF3",.F.)
			       dbDelete()
			       MsunLock()
                   dbSkip()
            End 
	     EndIf

		 If lSf3
            dbSelectArea("SF2")
	        dbSetOrder(1)
	        If dbSeek(xFilial("SF2")+cD2_DOC+cD2_SERIE+cD2_CLIENTE+cD2_LOJA)
               lSf2:=.T.
			   Reclock("SF2",.F.)
			   dbDelete()
			   MsunLock()
 	        EndIf
	      
		    If lSf2
               dbSelectArea("SD2")
	           dbSetOrder(3)
	           If dbSeek(xFilial("SD2")+cD2_DOC+cD2_SERIE+cD2_CLIENTE+cD2_LOJA)
                   While! Eof().And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cD2_DOC+cD2_SERIE+cD2_CLIENTE+cD2_LOJA
                          aadd(aSB2,{SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_QUANT,SD2->D2_ESTOQUE})
						  lSd2:=.T.
			              Reclock("SD2",.F.)
			              dbDelete()
			              MsunLock()
                          dbSkip()
                   End
                  
				   For nX:=1 To Len(aSB2)
				       If aSB2[nX,4] == "S"
				  	      SB2->(dbSetOrder(1))
	                      If SB2->(dbSeek(xFilial("SB2")+aSB2[nX,1]+aSB2[nX,2]))
		                     Reclock("SB2",.F.)
	                         SB2->B2_QATU := SB2->B2_QATU+aSB2[nX,3]
		                     MsUnlock()
						  EndIf	 
				       EndIf	
				   Next   

	            EndIf
			EndIf
	 	 EndIf 
	  EndIf
   EndIf

   If lSe1.And.lSft.And.lSf3.And.lSf2.And.lSd2   
      MsgInfo("Dados exclu�dos com sucesso !!"," E X C L U S � O")
   EndIf
EndIf

RestArea(aArea)
Return(Nil)
//-------------------------------------------------------------------

User Function UTNFSAI(cAlias,nReg,nOpcx)
Local lMA920AQISS := .F.
Local aArea		  := GetArea()

Local aTitles	:= { OemToAnsi("Totais"),; //
	                 OemToAnsi("Inf. Cliente"),; //
	                 OemToAnsi("Descontos/Frete/Despesas"),; //
	                 OemToAnsi("Impostos"),; //
	                 OemToAnsi("Livros Fiscais")}  //
Local a920Var	:= Iif(cPaisLoc<>"PTG",{0,0,0,0,0,0,0,0,0,0,0,""},{0,0,0,0,0,0,0,0,0,0,0})
Local aRecSF3	:= {}
Local aRecSE1	:= {}
Local aRecSE2	:= {}
Local aPedidos	:= {}
Local aObj		:= Iif(cPaisLoc <> "PTG",Array(19),Array(22))
Local aNFEletr	:= {}
Local aDANFE	:= {}

Local c920SClie

Local nOpc		:= 0

Local dDtDigit  := dDataBase

Local l920Inclui:= .F.
Local l920Deleta:= .F.
Local l920Altera:= .F.
Local lContinua	:= .T.
Local oGetDados


Local aHeadAGH	:= {}
Local aColsAGH  := {}

Private l920Visual:= .F.

l920Inclui	:= .T.

cCadastro := IIf( Type("cCadastro") == "U" , "STR0053" , cCadastro )

lInclui := l920Inclui
lLote   := ( Type("lLoteAuto") == "L" .AND.  lLoteAuto ) 


PRIVATE aGetCpo := {"D2_COD"		,"D2_UM"		,"D2_QUANT"		,"D2_PRCVEN"	,;
	                "D2_TOTAL"	,"D2_VALIPI","D2_VALICM"	,"D2_TES"		,;
	                "D2_CF"		,"D2_PICM"	,"D2_IPI"		,"D2_PESO"		,;
	                "D2_CONTA"	,"D2_DESC"	,"D2_NFORI"		,"D2_SERIORI"	,;
	                "D2_BASEICM","D2_LOCAL"	,"D2_DESCON"	,"D2_ICMSRET"	,;
	                "D2_BRICMS"	,"D2_SEGUM" ,"D2_DTVALID"	,"D2_QTSEGUM"   ,;
	                "D2_ITEM"   ,"D2_CLASFIS","D2_CODISS"   ,"D2_LOTECTL"   ,;
	                "D2_NUMLOTE","D2_PRUNIT","D2_BASEIPI"   ,"D2_PROJPMS"   ,;
	                "D2_EDTPMS" ,"D2_TASKPMS","D2_CUSTO1","D2_CUSTO2"       ,;
	                "D2_CUSTO3" ,"D2_CUSTO4" ,"D2_CUSTO5","D2_CCUSTO","D2_ITEMORI",;
	                "D2_ITEMCC" , "D2_CLVL", "D2_BASEDES", "D2_ICMSCOM", "D2_DIFAL", "D2_ALFCCMP", "D2_VFCPDIF"}

Private bFolderRefresh	:= {|| (UTFRefresh(aObj))}
Private bGDRefresh
Private bRefresh		:= {|| (UTRefresh(@a920Var,l920Inclui)),(Eval(bFolderRefresh))}
Private bListRefresh	:= {|| (UTFisToaCols()),Eval(bRefresh),Eval(bGdRefresh)}
Private aRemito			:= {}	//Array com os remitos de cada item do acols

If SD2->(ColumnPos("D2_TPREPAS")) > 0
	aAdd(aGetCpo,"D2_TPREPAS")
EndIf

If IsInCallStack('UTFIS001')
	bGDRefresh := If (Type("l920Auto") != "L" .or. !l920Auto,{|| (oGetDados:oBrowse:Refresh()) },{|| nil })
Else
	bGDRefresh := {|| nil }
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo de codigo de lancamento cat 83 ³
//³deve estar visivel no acols                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_CAT8309",,.F.)
	aAdd(aGetCpo,"D2_CODLAN")
EndIf

If l920Inclui .And. lMA920AQISS
	aAdd(aGetCpo,"D2_ALIQISS")
EndIf

If Type("l920Auto") != "L" .or. !l920Auto
	dbSelectArea("SF2")
	dbSetOrder(1)
	MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
Else
	dbSelectArea("SD2")
	dbSetOrder(3)
	MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
Endif

Private	cTipo  		:= If(l920Inclui,CriaVar("F2_TIPO")	,SF2->F2_TIPO)		,;
	    c920Nota 	:= If(l920Inclui,CriaVar("F2_DOC")		,SF2->F2_DOC)		,;
	    c920Serie	:= If(l920Inclui,CriaVar("F2_SERIE")	,SF2->F2_SERIE)	,;
	    d920Emis	:= If(l920Inclui,CriaVar("F2_EMISSAO")	,SF2->F2_EMISSAO)	,;
	    c920Client	:= If(l920Inclui,CriaVar("F2_CLIENTE")	,SF2->F2_CLIENTE)	,;
	    c920Loja	:= If(l920Inclui,CriaVar("F2_LOJA")	,SF2->F2_LOJA)		,;
	    c920Especi	:= If(l920Inclui,CriaVar("F2_ESPECIE")	,SF2->F2_ESPECIE)	,;
	    c920NFIni	:= If(l920Inclui,CriaVar("F2_DOC")		,SF2->F2_DOC)		,;
	    c920Vend	:= If(l920Inclui,CriaVar("F2_VEND1")	,SF2->F2_VEND1)		,;
	    c920DecExp	:= Iif(cPaisLoc=="PTG",If(l920Inclui,CriaVar("F2_DECLEXP")	,SF2->F2_DECLEXP),"")

Private c920Moeda	:= If(l920Inclui,CriaVar("F2_MOEDA"),SF2->F2_MOEDA),; 
	    c920Taxa	:= If(l920Inclui,CriaVar("F2_TXMOEDA"),SF2->F2_TXMOEDA),; 
	    c920Modal	:= If( !(cPaisLoc $ 'BRA|TRI'),If(l920Inclui,CriaVar("F2_NATUREZ"),SF2->F2_NATUREZ),""),; 
	    c920NFFim	:= If(l920Inclui,CriaVar("F2_DOC"),SF2->F2_NFORI)



PRIVATE aCols		:= {},;
	    aHeader 	:= {},;
	    N 			:= 1
PRIVATE oLancApICMS
PRIVATE aColsD2		:=	aCols
PRIVATE aHeadD2		:=	aHeader

cTipo  		:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_TIPO"})][2]	 ,SF2->F2_TIPO)		
c920Nota 	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_DOC"})][2]	 ,SF2->F2_DOC)		
c920Serie	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_SERIE"})][2]	 ,SF2->F2_SERIE)	
d920Emis	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_EMISSAO"})][2],SF2->F2_EMISSAO)	
c920Client	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_CLIENTE"})][2],SF2->F2_CLIENTE)	
c920Loja	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_LOJA"})][2]	 ,SF2->F2_LOJA)		
c920Especi	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_ESPECIE"})][2],SF2->F2_ESPECIE)	
c920NFIni	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_DOC"})][2]	 ,SF2->F2_DOC)		
c920Vend	:= If(l920Inclui,aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_VEND1"})][2]	 ,SF2->F2_VEND1)		

//wederson
SetKey(VK_F4,{||UTNfOri()})

c920SClie := If(cTipo$"DB",OemToAnsi("Fornecedor"),OemToAnsi("Cliente")) //###
dDtdigit  := IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)

If cPaisLoc == "BRA"
	If l920Inclui
		aNFEletr := {CriaVar("F2_NFELETR"),CriaVar("F2_CODNFE"),CriaVar("F2_EMINFE"),CriaVar("F2_HORNFE"),CriaVar("F2_CREDNFE")}
		aDANFE := {CriaVar("F2_CHVNFE")}
	Else 
		aNFEletr := {SF2->F2_NFELETR,SF2->F2_CODNFE,SF2->F2_EMINFE,SF2->F2_HORNFE,SF2->F2_CREDNFE}
		aDANFE := {SF2->F2_CHVNFE}
	Endif
Endif

aAdd(aGetCpo,"D2_VLIMPOR")

FillGetDados(nOpcx,"SD2",1,/*cSeek*/,/*cWhile*/,/*uSeekFor*/,/*aNoFields*/,aGetCpo,/*lOnlyYes*/,/*cQuery*/,{|| MaCols920(l920Inclui,l920Altera,l920Deleta,@lContinua,@aPedidos,@aRecSE1,@aRecSE2,@aRecSF3,@a920Var,@aTitles) },l920Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,.T.)

UTFRat(@aHeadAGH,@aColsAGH)

nOpc := 1

	If l920Inclui
	
		If cPaisLoc == "BRA"
			If ProcH("F2_NFELETR") > 0
				Aadd(aValidGet,{"aNFeAut[01]",aAutoCab[ProcH("F2_NFELETR"),2],"CheckSX3('F2_NFELETR',aNFeAut[01])",.f.}) 	 	
				aNFEletr[01] := aAutoCab[ProcH("F2_NFELETR"),2]
			Endif
			If ProcH("F2_CODNFE") > 0
				Aadd(aValidGet,{"aNFeAut[02]",aAutoCab[ProcH("F2_CODNFE"),2],"CheckSX3('F2_CODNFE',aNFeAut[02])",.f.}) 	 	
				aNFEletr[02] := aAutoCab[ProcH("F2_CODNFE"),2]
			Endif
			If ProcH("F2_EMINFE") > 0
				Aadd(aValidGet,{"aNFeAut[03]",aAutoCab[ProcH("F2_EMINFE"),2],"UTNFe('EMINFE',aNFeAut) .And. CheckSX3('F2_EMINFE',aNFeAut[03])",.f.}) 	 	
				aNFEletr[03] := aAutoCab[ProcH("F2_EMINFE"),2]
			Endif
			If ProcH("F2_HORNFE") > 0
				Aadd(aValidGet,{"aNFeAut[04]",aAutoCab[ProcH("F2_HORNFE"),2],"CheckSX3('F2_HORNFE',aNFeAut[04])",.f.}) 	 	
				aNFEletr[04] := aAutoCab[ProcH("F2_HORNFE"),2]
			Endif
			If ProcH("F2_CREDNFE") > 0
				Aadd(aValidGet,{"aNFeAut[05]",aAutoCab[ProcH("F2_CREDNFE"),2],"UTNFe('CREDNFE',aNFeAut) .And. CheckSX3('F2_CREDNFE',aNFeAut[05])",.f.}) 	 	
				aNFEletr[05] := aAutoCab[ProcH("F2_CREDNFE"),2]
			Endif

			If ProcH("F2_CHVNFE") > 0
				Aadd(aValidGet,{"aDANAut[01]",aAutoCab[ProcH("F2_CHVNFE"),2],"CheckSX3('F2_CHVNFE',aDANAut[01])",.f.}) 	 	
				aDANFE[01] := aAutoCab[ProcH("F2_CHVNFE"),2]
			Endif
			If ProcH("F2_TPFRETE") > 0
				Aadd(aValidGet,{"a920VarAut["+str(TPFRETE)+"]",aAutoCab[ProcH("F2_TPFRETE"),2],"U_UTVFold('NF_TPFRETE',a920VarAut["+str(TPFRETE)+"])",.f.})
			EndIf
		Endif
		
	EndIf

If nOpc == 1
	Begin Transaction
		If l920Inclui .Or. l920Altera .Or. l920Deleta

    		If Type("l920Auto") == "L" .or. l920Auto
				UTGrava(l920Deleta,aNFEletr,aDANFE,l920Inclui)
			EndIf

			EvalTrigger()

		EndIf
	End Transaction	
	
EndIf

If Type("lGeraNum") == "L"
	lGeraNum := .F.
EndIf

MsUnlockAll()

MaFisEnd()
//RestArea(aAreaSE1)
RestArea(aArea)

SetKey(VK_F4,NIL)

Return nOpc

//-------------------------------------------------------------------

Static Function UTFRefresh(aObj)
Local nx
If Type("l920Auto") !="L" .or. !l920Auto
	For nx := 1 to Len(aObj)
		aObj[nx]:Refresh()
	Next
EndIf
Return .T.

//-------------------------------------------------------------------

Static Function UTRefresh(a920Var,l920Inclui)
Local aArea		:= GetArea()			// Guarda a area do SF2
Local aAreaSD2	:= SD2->(GetArea())	// Guarda a area do SD2
Local aAreaSF4	:= SF4->(GetArea())
Local lLoja		:= .F.					// Indica se a nota fiscal foi gerada no sigaloja
Local cChaveSD2	:= ""					// Chave de localizacao do SD2
Local lAgregSol := .F.					// Agrega Solidario ao Total da Nota
Local nFrete	:= 0
Local cAliasSD2 := ""
Local aStruSD2 := {}
Local nX := 0
Local nItem := 0
Local cChave := ""
Local nValAcresc := 0					// Valor do Acrescimo

If l920Inclui

	a920Var[VALMERCB]	:= MaFisRet(,"NF_VALMERC") + Iif(l920Inclui,0,MaFisRet(,"NF_DESCONTO"))					// Valor da Mercadoria (Bruto)
	a920Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO") 								// Descontos
	a920Var[TOTPED]		:= MaFisRet(,"NF_TOTAL") 									// Total da Nota
	a920Var[VALMERC]	:= MaFisRet(,"NF_VALMERC") - Iif(l920Inclui,MaFisRet(,"NF_DESCONTO"),0)		// Valor da Mercadoria (Liquido)

	a920Var[FRETE]		:= MaFisRet(,"NF_FRETE")
	a920Var[SEGURO]		:= MaFisRet(,"NF_SEGURO")
	a920Var[VALDESP]	:= MaFisRet(,"NF_DESPESA")

	a920Var[TOTF1]		:= a920Var[VALDESP]	+ a920Var[SEGURO] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)
	a920Var[TOTF3]		:= a920Var[FRETE] + a920Var[SEGURO] + a920Var[VALDESP] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)

Else

	If TcSrvType() <> "AS/400"

		cAliasSD2 := "QRYSD2"
		aStruSD2 := SD2->(dbStruct())

		cQuery := "SELECT SD2.*,SD2.R_E_C_N_O_ RECSD2 FROM "
		cQuery += RetSqlName("SD2") + " SD2 "
		cQuery += " WHERE "
		cQuery += "D2_FILIAL = '"+xFilial("SD2")+"' AND "
		cQuery += "D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND "
		cQuery += "D2_LOJA = '"+SF2->F2_LOJA+"' AND "
		cQuery += "D2_DOC = '"+SF2->F2_DOC+"' AND "
		cQuery += "D2_SERIE = '"+SF2->F2_SERIE+"' AND "
		cQuery += "SD2.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.F.,.T.)

		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2]!="C"
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX

	EndIf

	While !(cAliasSD2)->(Eof ())
		nItem ++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a nota/cupom fiscal foi gerado no Sigaloja ou pelo Venda Direta do Faturamento  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim((cAliasSD2)->D2_ORIGLAN) == "LO" .Or. AllTrim((cAliasSD2)->D2_ORIGLAN) == "VD"
			lLoja := .T.
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
			lAgregSol := (SF4->F4_INCSOL == 'S')
		EndIf

			a920Var[FRETE]		:= MaFisRet(,"NF_FRETE")
			a920Var[SEGURO]		:= MaFisRet(,"NF_SEGURO")
			a920Var[VALDESP]	:= MaFisRet(,"NF_DESPESA")

			If lLoja
				// Grava o valor do acrescimo desconsiderando os valores de frete, seguro e despesa pois já são gravados nos respectivos campos
				nValAcresc := SF2->F2_VALACRS - (a920Var[FRETE] + a920Var[SEGURO] + a920Var[VALDESP])
				// O LOJA grava o valor do acrescimo separado do valor da mercadoria
				// Deve-se somar o acrescimo para a correta exebicao dos totais
				a920Var[VALMERCB]	:= MaFisRet(,"NF_VALMERC") + nValAcresc										// Valor da Mercadoria (Bruto)
				cChaveSD2 			:= xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
				a920Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO")						// Descontos
				//Incluído o valor do ICMS Solidário, ao Valor Total da Nota
				a920Var[TOTPED]		:= MaFisRet(,"NF_VALMERC") - a920Var[VALDESC] + nValAcresc + MaFisRet(,"NF_VALIPI") // Total da Nota
				If lAgregSol
					a920Var[TOTPED] += MaFisRet(nItem,"IT_VALSOL")	// Total da Nota
				EndIf
				a920Var[VALMERC]	:= MaFisRet(,"NF_VALMERC") - a920Var[VALDESC] + nValAcresc					// Valor da Mercadoria (Liquido)
				a920Var[TOTPED]		:= MaFisRet(,"NF_TOTAL") 									// Total da Nota
			Else
				a920Var[VALMERCB]	:= MaFisRet(,"NF_VALMERC") + Iif(l920Inclui,0,MaFisRet(,"NF_DESCONTO"))					// Valor da Mercadoria (Bruto)
				a920Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO") 								// Descontos
				a920Var[TOTPED]		:= MaFisRet(,"NF_TOTAL") 									// Total da Nota
				a920Var[VALMERC]	:= MaFisRet(,"NF_VALMERC") - Iif(l920Inclui,MaFisRet(,"NF_DESCONTO"),0)		// Valor da Mercadoria (Liquido)
			EndIf

			If cPaisLoc == "PTG"
				a920Var[NTRIB] 		:= MaFisRet(,"NF_DESNTRB")
				a920Var[TARA]		:= MaFisRet(,"NF_TARA")
			Endif

			a920Var[TOTF1]		:= a920Var[VALDESP]	+ a920Var[SEGURO] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)
			a920Var[TOTF3]		:= a920Var[FRETE] + a920Var[SEGURO] + a920Var[VALDESP] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)

			(cAliasSD2)->(DbSkip())
		EndDo
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		RestArea(aAreaSF4)
		RestArea(aAreaSD2)
		RestArea(aArea)
EndIf

Return .T.

//-------------------------------------------------------------------

Static Function UTCabOk(oTipo,oNota,oEmis,oClie,oLoja)
Local lRet 	:= .F.

Do Case
	Case Empty(cTipo)
		oTipo:SetFocus()
	Case Empty(c920Nota) .And. !lGeraNum
		oNota:SetFocus()
	Case Empty(d920Emis)
		oEmis:SetFocus()
	Case Empty(c920Client)
		oClie:SetFocus()
	Case Empty(c920Loja)
		oLoja:SetFocus()
	OtherWise
		If !MaFisFound("NF")
			MaFisIni(c920Client,c920Loja,If(cTipo$'DB',"F","C"),cTipo,IIf(cTipo$'DB', Nil ,SA1->A1_TIPO ),MaFisRelImp("MT100",{"SF2","SD2"}),,.T.,,,,,,,,,,,,,,,,,d920Emis)
		Else
			If !l920Visual
				MaFisAlt("NF_DTEMISS",d920Emis)
			EndIf
		EndIf
		lRet := .T.
EndCase

Return lRet

//-------------------------------------------------------------------

User Function UTVFold(cReferencia,xValor,lRefre)
Local aArea	:= GetArea()

If lRefre==Nil
	lRefre := .T.
EndIf

If MaFisFound("NF").And.!(MaFisRet(,cReferencia)==xValor)
	MaFisAlt(cReferencia,xValor)
	a920FisToaCols()
	If lRefre
		Eval(bRefresh)
		Eval(bGDRefresh)
	EndIf
EndIf

RestArea(aArea)
Return .T.

//-------------------------------------------------------------------

Static Function UTFieldOk()
Eval(bRefresh)
Return .T.

//-------------------------------------------------------------------

Static Function UTDel(o)
Local nPosItD2	:= 	aScan(aHeader,{|aX| aX[2]==PadR("D2_ITEM",Len(SX3->X3_CAMPO))})
Local nI		:=	0
Local nPosCalc	:=	0
Local nPosIt	:=	0

if !l920Visual	
	MaFisDel(n,aCols[n][Len(aCols[n])])
	Eval(bRefresh)
	
	If Type("oLancApICMS")<>"U" .And. oLancApICMS<>Nil .And. nPosItD2>0
		nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
		nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
		For nI := 1 To Len(oLancApICMS:aCols)
			If aCols[n,nPosItD2]==AllTrim(oLancApICMS:aCols[nI,nPosIt])
				oLancApICMS:aCols[nI,Len(oLancApICMS:aCols[nI])]	:=	aCols[n,Len(aCols[n])]
			EndIf
		Next nI
		oLancApICMS:Refresh()
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------

Static Function UTLinOk()
Local lRet 		:= .T.
Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_COD" })
Local nPosQuant:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_QUANT"})
Local nPosUnit	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_PRCVEN"})
Local nPosTotal:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_TOTAL"})
Local nPosTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_TES"})
Local nPosCF	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_CF"})
Local nPosOri	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_NFORI"})
Local lF4VlZero     := SF4->(ColumnPos("F4_VLRZERO")) > 0
Local lF4QTDZERO    := SF4->(ColumnPos("F4_QTDZERO")) > 0	
Local lPermite		:= .F.

IF cPaisLoc == "BRA" .And. lF4VlZero .And. lF4QTDZERO .And. SF4->(MsSeek(xFilial("SF4")+aCols[n][nPosTES]))
	IF SF4->F4_VLRZERO == "1" .And. SF4->F4_QTDZERO == "1"
		lPermite := .T.
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a linha nao esta em branco e os itens nao Deletados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CheckCols(n,aCols) .And. !aCols[n][Len(aHeader)+1]
	Do Case
	Case 	Empty(aCols[n][nPosCod]) 	.Or. ;
			(	Empty(aCols[n][nPosQuant]).And. cTipo$"NDB" .And. !lPermite).Or. ;
			(Empty(aCols[n][nPosUnit]) .And. !lPermite) .Or. ;
			(Empty(aCols[n][nPosTotal]) .And. !lPermite).Or. ;
			Empty(aCols[n][nPosCF]) 	.Or. ;
			Empty(aCols[n][nPosTES])
		Help("  ",1,"A100VZ")			 	
		lRet := .F.
	Case cTipo $"CPI" .And. Empty(aCols[n][nPosOri])
		HELP(" ",1,"A910COMPIP")
		lRet := .F.
	Case cTipo=="D" .And.Empty(aCols[n][nPosOri])
		HELP(" ",1,"A910NFORI")
		lRet := .F.
	Case cTipo$'NDB' .And. (aCols[n][nPosTotal]>(aCols[n][nPosUnit]*aCols[n][nPosQuant]+0.09);
			.Or. aCols[n][nPosTotal]<(aCols[n][nPosUnit]*aCols[n][nPosQuant]-0.09))
		Help("  ",1,'A12003')
		lRet := .F.
	EndCase
ElseIf !CheckCols(n,aCols)		
	lRet := .F.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entrada 							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("MT920LOK"))
	lRet := ExecBlock("MT920LOK",.F.,.F.,{lRet})
EndIf
            

Return lRet 

//-------------------------------------------------------------------

Static Function UTTudok()
Local lRet   := .T.
Local nItens := 0
Local nx     := 0

If Empty(c920Client) .Or. Empty(d920Emis) .Or. If(!lLote, Empty(cTipo),.F.) .Or. (Empty(c920Nota) .And. !lLote .And. !lGeraNum)
	Help(" ",1,"A100FALTA")
	lRet := .F.
EndIf	          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impede a inclusao de documentos sem nenhum item ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx:=1 to len(aCols)
	If !aCols[nx][Len(aCols[nx])]   
		nItens ++
	Endif
Next

If nItens == 0
	Help("  ",1,"A100VZ")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
//³             MV_SIGAGSP - 0-Nao / 1-Integra                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
If GetNewPar("MV_SIGAGSP","0") == "1" .And. FindFunction('GSPF030')
	lRet:= GSPF030()
EndIf

If nModulo == 72
	lRet := KEXF870(lRet)
EndIf

If (ExistBlock("MT100TOK"))
	lRet := ExecBlock("MT100TOK",.F.,.F.,{lRet})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Registro esta Bloqueado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If cTipo$"DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+c920Client+c920Loja)
			If !RegistroOk("SA2")
				lRet := .F.
			EndIf
		Endif		
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+c920Client+c920Loja)
			If !RegistroOk("SA1")
				lRet := .F.
			EndIf
		Endif
	Endif
Endif

If lRet .And. !lLote 
	lRet := A920Nota(c920Nota,c920Serie,c920Especi,d920Emis)
EndIf

Return lRet

//-------------------------------------------------------------------

Static Function UTFisToaCols()

Local nx
Local ny
Local cValid
Local nPosRef

For ny := 1 to Len(aCols)
	For nx	:= 1 to Len(aHeader)
		cValid	:= AllTrim(UPPER(aHeader[nx][6]))
		If "UTFISREF"$cValid
			nPosRef := 	AT('UTFISREF("',cValid) + 10
			cRefCols:=	Substr(cValid,nPosRef,AT('","MT100",',cValid)-nPosRef )
			If MaFisFound("IT",ny)
				aCols[ny][nx]:= MaFisRet(ny,cRefCols)
			EndIf
		EndIf
	Next
Next

Return .T.

//-------------------------------------------------------------------

User Function UTTipo(cTipo,oSClie,cSClie,oGClie,cCliente,cLoja,oLoja)
Local nPosTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_TES"})
Local nx
Local nY

If cTipo$'DB'
	If Type("l920Auto") != "L" .or. !l920Auto
		oGClie:cF3 	:= 'FOR'
	EndIf
	cSClie		:= OemToAnsi("Fornecedor") //Fornecedor
	If MaFisFound("NF").And.MaFisRet(,"NF_TIPONF") != cTipo
		cCliente		:= CriaVar("F2_CLIENTE")
		cLoja			:= CriaVar("F2_LOJA")
	EndIf
Else
	If Type("l920Auto") != "L" .or. !l920Auto
		oGClie:cF3 	:= 'SA1'
	EndIf
	cSClie		:= OemToAnsi("Cliente")     //Cliente
	If MaFisFound("NF").And.MaFisRet(,"NF_TIPONF") != cTipo
		cCliente		:= CriaVar("F2_CLIENTE")
		cLoja			:= CriaVar("F2_LOJA")
	EndIf
EndIf

If MaFisFound("NF") .And. cTipo!= MafisRet(,"NF_TIPONF")
	aCols			:= {}
	aADD(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		If Trim(aHeader[ny][2]) == "D1_ITEM"
			aCols[1][ny] 	:= "01"
		ElseIf ( aHeader[ny][10] != "V")
			aCols[1][ny] := CriaVar(aHeader[ny][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
	MaFisAlt("NF_CLIFOR",If(cTipo$"DB","F","C"))
	MaFisAlt("NF_TIPONF",cTipo)
	MaFisClear()
	If oSClie <> Nil
		oSClie:Refresh()
	EndIf
	If oGClie <> Nil
		oGClie:Refresh()
	EndIf
	If oLoja <> Nil
		oLoja:Refresh()
	EndIf
	Eval(bGDRefresh)
	Eval(bRefresh)
EndIf


Return .T.

//-------------------------------------------------------------------

User Function UTNota(cNota,cSerie,cEspecie,dDataEmis)

Local lRet := .T.
Local cSerId := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Id da serie para compor as chaves das funcoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
If SerieNfId("SF2",3,"F2_SERIE") == "F2_SDOC"
	cSerId := Substr(cSerie,1,3) +  StrZero(Month(dDataEmis),2) + Str(Year(dDataEmis),4) + AllTrim(cEspecie)
Else
	cSerId := Substr(cSerie,1,3)
EndIf

If Empty(cNota) .And. !lGeraNum
	lRet	:= .F.
	HELP("  ",1,"F2_DOC")
EndIf

If lRet
	If SF2->( MsSeek(xFilial()+cNota+cSerId) )
		lRet := .F.
		HELP(" ",1,"A920EXIST")
	Endif

EndIf

Return lRet

//-------------------------------------------------------------------

User Function UTEmissao(dEmissao)
Local lRet	:= .T.

If dEmissao > dDataBase
	lRet := .F.
	HELP("  ",1,"A100DATAM")
Else
	lRet := FisChkDt(dEmissao)
EndIf

Return lRet

//-------------------------------------------------------------------

User Function UTClient(cCliente,cLoja,aInfClie,cTipo,l920Inclui)
Local lRet   := .T.
Local cAlias := ""

IF !Empty(cCliente)
    cAlias := "SF2"
	If cTipo$"DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		IF !Empty(cLoja)
			lRet := SA2->(MsSeek(xFilial("SA2")+cCliente+cLoja))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o array que contem os dados do Fornecedor      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				aInfClie[1]	:= SA2->A2_NOME						// Nome
				aInfClie[2]	:= SA2->A2_TEL 						// Telefone
				aInfClie[3]	:= SA2->A2_PRICOM	    				//Primeira Compra do Cliente
				aInfClie[4]	:= SA2->A2_ULTCOM      				//Ultima Compra do Cliente
				aInfClie[5]	:= SA2->A2_END+" - "+SA2->A2_MUN		//Endereco
				aInfClie[6]	:= SA2->A2_EST         				//Estado			
			EndIf
		Else
			lRet 	:= SA2->(MsSeek(xFilial("SA2")+cCliente))
			If lRet
				c920Loja := SA2->A2_LOJA
			Endif				
		EndIf
	Else
        cAlias := "SF1"
		dbSelectArea("SA1")
		dbSetOrder(1)
		IF !Empty(cLoja)
			lRet := SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
			If lRet
				aInfClie[1]	:= SA1->A1_NOME						// Nome
				aInfClie[2]	:= SA1->A1_TEL 						// Telefone
				aInfClie[3]	:= SA1->A1_PRICOM	    				//Primeira Compra
				aInfClie[4]	:= SA1->A1_ULTCOM      				//Ultima Compra
//				If Empty(SA1->A1_ENDCOB)
					aInfClie[5]	:= SA1->A1_END+" - "+SA1->A1_MUN //Endereco
					aInfClie[6]	:= SA1->A1_EST         			  //Estado
//				Else
//					aInfClie[5]	:= SA1->A1_ENDCOB+" - "+SA1->A1_MUNC //Endereco de Cobranca
//					aInfClie[6]	:= SA1->A1_ESTC        				  //Estado de Cobranca
//				EndIf
			EndIf
		Else			
			lRet := SA1->(MsSeek(xFilial("SA1")+cCliente))
			If lRet
				c920Loja := SA1->A1_LOJA
			Endif				
		Endif
	EndIf
EndIF

Return lRet

//-------------------------------------------------------------------

Static Function UTGrava(lDeleta,aNFEletr,aDANFE,l920Inclui)
LOCAL nx
LOCAL ny
Local lMvAtuComp:= SuperGetMV("MV_ATUCOMP",,.F.)
Local aHorario	:= {}
Local cHoraRMT	:= SuperGetMv("MV_HORARMT",.F.,"2")	//Horário gravado nos campos F1_HORA/F2_HORA.
													//1=Horario do SmartClient; 2=Horario do servidor;
													//3=Fuso horário da filial corrente;
Default aNfEletr := {}
Default aDANFE   := {}
If cTipo$"DB"
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial()+c920Client+c920Loja)
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial()+c920Client+c920Loja)
EndIf

If Type("l920Auto") != "L" .or. !l920Auto
	ProcRegua(Len(aCols)+1)
EndIf
//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
dbSelectArea("SF2")
dbSetOrder(1)
If! dbSeek(xFilial("SF2")+c920Nota+c920Serie+c920Client+c920Loja)
    //wederson
	dbSelectArea("SF2")
	dbSetOrder(1)
	RecLock("SF2",.T.)
	SF2->F2_TIPO	:= cTipo
	SF2->F2_DOC		:= c920Nota
	SF2->F2_SERIE	:= c920Serie
	SF2->F2_EMISSAO	:= d920Emis
	SF2->F2_LOJA	:= c920Loja
	SF2->F2_CLIENTE	:= c920Client
	SF2->F2_EST		:= IIF(cTipo$"DB",SA2->A2_EST,SA1->A1_EST)
	SF2->F2_DESCONT	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_DESCONT"})][2]
	SF2->F2_VALMERC	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_VALMERC"})][2]
	SF2->F2_VALICM	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_VALICM"})][2]
	SF2->F2_VALIPI	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_VALIPI"})][2]
	SF2->F2_VALBRUT	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_VALBRUT"})][2]
	SF2->F2_FRETE	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_FRETE"})][2]
	SF2->F2_BASEIPI	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_BASEIPI"})][2]
	SF2->F2_BASEICM	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_BASEICM"})][2]
	SF2->F2_DESPESA	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_DESPESA"})][2]
	SF2->F2_FILIAL 	:= xFilial("SF2")
	SF2->F2_BRICMS 	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_BRICMS"})][2]
	SF2->F2_ICMSRET	:= aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_ICMSRET"})][2]
	SF2->F2_ESPECIE	:= c920Especi
	SF2->F2_NFORI	:= if(lLote, c920NFFim,"")
	SF2->F2_LOTE	:= if(lLote,"S","")
	SF2->F2_MOEDA   := 1
	SF2->F2_UFDEST  := aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_UFDEST"})][2]
    SF2->F2_UFORIG  := aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_UFORIG"})][2]
    SF2->F2_BSFCPST := aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_BSFCPST"})][2]
	SF2->F2_BASFECP := aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_BASFECP"})][2]
	SF2->F2_DESCONT := aAUTOCAB[AScan(aAUTOCAB, {|x| AllTrim(x[1]) == "F2_DESCONT"})][2]
		
	If SuperGetMv("MV_HORANFE",.F.,.F.) .And. Empty(SF2->F2_HORA)
		//Parametro MV_HORARMT habilitado pega a hora do smartclient, caso contrario a hora do servidor
		If cHoraRMT == '1' //Horario do SmartClient
			SF2->F2_HORA := GetRmtTime()
		ElseIf cHoraRMT == '2' //Horario do servidor
			SF2->F2_HORA := Time()
		ElseIf cHoraRMT =='3' //Horario de acordo com o estado da filial corrente			
			aHorario := A103HORA()
			If !Empty(aHorario[2])
				SF2->F2_HORA := aHorario[2]
			EndIf
		Endif
	EndIf

	If cPaisLoc == "BRA"
		SF2->F2_NFELETR	:= aNFEletr[01]
		SF2->F2_CODNFE	:= aNFEletr[02]
		SF2->F2_EMINFE	:= aNFEletr[03]
		SF2->F2_HORNFE	:= aNFEletr[04]
		SF2->F2_CREDNFE	:= aNFEletr[05]
		SF2->F2_CHVNFE	:= aDANFE[01]
	EndIf
    MsUnlock()
	
	dbSelectArea("SD2")
	dbSetOrder(1)
	If Type("l920Auto") != "L" .or. !l920Auto
		IncProc()
	EndIf
	For nX := 1 to Len(aAUTOITENS)
			RecLock("SD2",.T.)
			SD2->D2_FILIAL := xFilial("SD2")
			SD2->D2_NUMSEQ := ProxNum()
			For nY := 1 to Len(aAUTOITENS[nX])
		        Var := Trim(Alltrim(aAUTOITENS[nX][nY][1]))
				Replace &Var. With aAUTOITENS[nX][nY][2]
			Next nY
	Next		
	If Len(aAUTOITENS)>0
	   MsUnlock()	
	EndIf
	If lMvAtuComp .And. l920Inclui
		AtuComp(c920Nota,SF2->F2_SERIE,c920Especi,c920Client,c920Loja,"S",cTipo)
	EndIf

    UTFisAtuSF3(1,"S",SF2->(RecNo()))
	
EndIf 
Return .T.

//-------------------------------------------------------------------

Static Function UTFisAtuSF3(nCaso, cTpOper, nRecNF)
Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())
Local aLivro	:= {}
Local aRecSF3	:= {}
Local aRecSFT   := {}
Local aWriteSFT := {}
Local aNFEletr	:= {"",cTod(""),"","",0,""}
Local cCtaCont	:= ""
Local cCliFor	:= ""
Local cLoja		:= ""
Local cNumNF	:= ""
Local cSerie	:= ""
Local dDEmissao	:= ""
Local cEspecie	:= ""
Local cFormul	:= ""
Local cQuery    := ""
Local cTpVent	:= ""
Local cCAE		:= ""
Local cAliasSF3 := "SF3"
Local cAliasSFT := "SFT"
Local cAliasCD2 := "CD2"
Local dEntrada	:= Ctod("")
Local dDtCAE	:= Ctod("")
Local nY        := 0
Local nX        := 0
Local nZ        := 0
Local nA        := 0
Local nPautaPis := 0
Local nPautaCof := 0
Local lQuery    := .F.
Local lIsenEP	:= .F.
Local lNFEletr	:= .F.
Local lNFEArg	:= .F.
Local lSped		:= cPaisLoc == "BRA" 
Local lChvNfe	:= .F.
Local cItemNF	:= StrZero(0,TamSx3("D2_ITEM")[1],0)			// Item da NF
Local lIcmSTTran:= .F.
Local aAreaSL1    := {}
Local lLegislacao := ""
Local cAliasReproc:= ""
Local cLjEspecie  := ""
Local lGrvSF3     := .F.

Private aNFCab :={}
Private cALiasProd

DEFAULT cPDV    := ""
DEFAULT cCNAE   := ""
DEFAULT cFunOrig:= ""
DEFAULT nCD2	:= 0
DEFAULT cSerSat := ""
DEFAULT cNfisCanc := ""

	cCliFor	 := c920Client
	cLoja	 := c920Loja
	cNumNF	 := c920Nota
	cSerie	 := c920Serie
	dDEmissao:= d920Emis
	cEspecie := c920Especi
	cFormul	 := ""
	dEntrada := d920Emis

	//Campos da NFe Argentina
	lNFEArg	:= .F.
	
	If (cPaisLoc=="BRA")
		//Tratamento de recuperacao de registros deletados do CD2
		dbSelectArea("CD2")
		dbSetOrder(2)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				cAliasCD2 := "MaFisAtuCD2"
				lQuery    := .T.
				cQuery := "SELECT CD2_FILIAL,CD2_TPMOV,CD2_DOC,CD2_SERIE,CD2_CODCLI,CD2_LOJCLI,CD2_CODFOR,CD2_LOJFOR,R_E_C_N_O_ CD2RECNO "
				cQuery += "FROM "+RetSqlName("CD2")+" CD2 "
				cQuery += "WHERE CD2.CD2_FILIAL='"+xFilial("CD2")+"' AND "
				cQuery += "CD2.CD2_SERIE='"+cSerie+"' AND "
				cQuery += "CD2.CD2_DOC='"+cNumNF+"' AND "
				cQuery += "CD2.CD2_TPMOV='"+cTpOper+"' AND "
				If (cTpOper=="E" .And. !aNfCab[NF_TIPONF]$"DB")
					If !cFormul=="S"
					cQuery += "CD2.CD2_CODFOR='"+cCliFor+"' AND "
					cQuery += "CD2.CD2_LOJFOR='"+cLoja+"' AND "
					EndIf
				EndIf
				If cFormul=="S"
					cQuery += "CD2.CD2_FORMU='S' AND "
				EndIf
				cQuery += "CD2.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY "+SqlOrder(CD2->(IndexKey()))
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCD2)
			Else
		#ENDIF
				MsSeek(xFilial("CD2")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".Or.cFormul=="S"),cCliFor+cLoja,""))
		#IFDEF TOP
			EndIf
		#ENDIF
		While (!Eof() .And.;
			(cAliasCD2)->CD2_FILIAL == xFilial("CD2") .And.;
			(cAliasCD2)->CD2_TPMOV  == cTpOper	.And.;
			(cAliasCD2)->CD2_DOC    == cNumNF  .And.;
			(cAliasCD2)->CD2_SERIE  == cSerie  .And.;
			IIf(cTpOper=="S" .Or. (cTpOper=="E" .And. aNfCab[NF_TIPONF]$"DB") .Or. cFormul=="S",.T.,(cAliasCD2)->CD2_CODFOR == cCliFor .And. (cAliasCD2)->CD2_LOJFOR == cLoja))

			If lQuery
				CD2->(dbGoto((cAliasCD2)->CD2RECNO))
			EndIf

			RecLock("CD2")
			dbdelete()
			MsUnLock()

			dbSelectArea(cAliasCD2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasCD2)
			dbCloseArea()
			dbSelectArea("CD2")
		EndIf
	EndIf
		
    //WEDERSON
    For nX:=1 To Len(aSF3)
	    lGrvSF3:= .F.                 //F3_FILIAL, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE, R_E_C_N_O_, D_E_L_E_T_
		dbSelectArea("SF3")				 
        dbSetOrder(4)
		dbSeek(xFilial("SF3")+aSF3[nX][03]+aSF3[nX][04]+aSF3[nX][01]+aSF3[nX][02])
	    While! Eof().And.SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE == xFilial("SF3")+aSF3[nX][03]+aSF3[nX][04]+aSF3[nX][01]+aSF3[nX][02]     
		       If SF3->F3_CFO == aSF3[nX][29]
                  lGrvSF3:=.T.
			   EndIf
		       dbSkip()
		End
		If! lGrvSF3
		   Reclock("SF3",.T.)
           SF3->F3_FILIAL	:= xFilial("SF3")
		   SF3->F3_ENTRADA	:= dDataBase
		   SF3->F3_NFISCAL	:= aSF3[nX][01]
		   SF3->F3_SERIE    := aSF3[nX][02]
		   SF3->F3_CLIEFOR	:= aSF3[nX][03]
		   SF3->F3_LOJA	    := aSF3[nX][04]
	       SF3->F3_CODRSEF  := aSF3[nX][10]
           SF3->F3_ESTADO   := aSF3[nX][07]
           SF3->F3_EMISSAO	:= aSF3[nX][06]
		   SF3->F3_FORMUL	:= ""
		   SF3->F3_ESPECIE	:= cEspecie
		   SF3->F3_DTCANC	:= CTOD("")
           SF3->F3_CHVNFE   := aSF3[nX][09]
           SF3->F3_TIPO     := aSF3[nX][05]
		   SF3->F3_ALIQICM  := aSF3[nX][30]
		   SF3->F3_BASEICM  := aSF3[nX][27]
		   SF3->F3_VALICM   := aSF3[nX][28]
		   SF3->F3_ISENICM  := IIf(aSF3[nX][49]==0,aSF3[nX][26],aSF3[nX][26]+(aSF3[nX][47]-aSF3[nX][27])) //aSF3[nX][26] 
		   SF3->F3_OUTRICM  := IIf(aSF3[nX][27]==0.And.aSF3[nX][49]==0,aSF3[nX][47],IIf(aSF3[nX][27]<aSF3[nX][47].And.aSF3[nX][49]==0,aSF3[nX][47]-aSF3[nX][27],aSF3[nX][25]))
		   SF3->F3_OBSICM   := aSF3[nX][24]
		   SF3->F3_BASEIPI  := aSF3[nX][21]
		   SF3->F3_VALIPI   := aSF3[nX][23]
		   SF3->F3_ISENIPI  := aSF3[nX][32]
		   SF3->F3_OUTRIPI  := aSF3[nX][22]
	       SF3->F3_CFO      := aSF3[nX][29]
           SF3->F3_VALCONT	:= aSF3[nX][20]
		   SF3->F3_ICMSRET  := aSF3[nX][34]
		   SF3->F3_ICMSCOM	:= aSF3[nX][17]
		   SF3->F3_IPIOBS	:= aSF3[nX][19]
		   SF3->F3_NRLIVRO  := aSF3[nX][08]
		   SF3->F3_DESPESA  := aSF3[nX][35]
           SF3->F3_VALFECP  := aSF3[nX][16]
           SF3->F3_DIFAL    := aSF3[nX][15]
           SF3->F3_BSICMOR  := aSF3[nX][14]
           SF3->F3_ALIQCPB  := aSF3[nX][13]
		   SF3->F3_IDENTFT  := "000001"
		   SF3->F3_BSFCPST  := aSF3[nX][36]
		   SF3->F3_VFECPST  := aSF3[nX][37]
		   SF3->F3_BASERET  := aSF3[nX][38]

		   SF3->F3_BASIMP5  := aSF3[nX][39]
		   SF3->F3_ALQIMP5  := aSF3[nX][40]
		   SF3->F3_VALIMP5  := aSF3[nX][41]
		   SF3->F3_BASIMP6  := aSF3[nX][42]
		   SF3->F3_ALQIMP6  := aSF3[nX][43]
		   SF3->F3_VALIMP6  := aSF3[nX][44]
		   SF3->F3_OBSSOL   := aSF3[nX][34]
		   SF3->F3_BASFECP  := aSF3[nX][27]
		   SF3->F3_VALFECP  := aSF3[nX][46]
		   SF3->F3_VALOBSE  := aSF3[nX][48]
		   MSunLock()
		EndIf
	Next   
    //wederson
    
       
	For nX:=1 To Len(aSFT)
	   
	    dbSelectArea("SFT")
	    dbSetOrder(1)
		If! dbSeek(xFilial("SFT")+cTpOper+aSFT[nX][02]+aSFT[nX][01]+aSFT[nX][03]+aSFT[nX][04]+aSFT[nX][08]+Space(TamSx3("FT_ITEM")[1]-Len(aSFT[nX][08]))+aSFT[nX][09])
		   
            SF4->(dbSetOrder(1))			
		    SF4->(dbSeek(xFilial("SF4")+AllTrim(aSFT[nX][17])))
	        
			  RecLock("SFT",.T.)
			  SFT->FT_FILIAL	:= xFilial("SFT")
			  SFT->FT_TIPOMOV   := cTpOper
			  SFT->FT_EMISSAO	:= aSFT[nX][06]
			  SFT->FT_ENTRADA	:= dDataBase
			  SFT->FT_NFISCAL	:= aSFT[nX][01]
			  SFT->FT_SERIE     := aSFT[nX][02] 
			  SFT->FT_CLIEFOR	:= aSFT[nX][03]
			  SFT->FT_LOJA	    := aSFT[nX][04]
			  SFT->FT_PDV       := ""
			  SFT->FT_IDENTF3	:= "000001"
			  SFT->FT_ESTADO	:= aSFT[nX][07]
			  SFT->FT_FORMUL	:= ""	
			  SFT->FT_ESPECIE	:= cEspecie
			  SFT->FT_DTCANC	:= CTOD("")
			  SFT->FT_TIPO	    := aSFT[nX][05]
			  SFT->FT_POSIPI	:= aSFT[nX][38]	
			  SFT->FT_CLASFIS	:= aSFT[nX][36]	
			  SFT->FT_ESTOQUE	:= aSFT[nX][37]	
			  SFT->FT_SEGURO	:= aSFT[nX][35]	
			  SFT->FT_FRETE	    := aSFT[nX][18]	
			  SFT->FT_PRODUTO	:= aSFT[nX][09]	
			  SFT->FT_ITEM	    := aSFT[nX][08]	
			  SFT->FT_QUANT	    := aSFT[nX][14]	
			  SFT->FT_PRCUNIT	:= aSFT[nX][15]	
			  SFT->FT_TOTAL	    := aSFT[nX][16]	
			  SFT->FT_DESCONT	:= aSFT[nX][19]	
			  SFT->FT_NRLIVRO   := SF4->F4_NRLIVRO
			  SFT->FT_CFOP      := aSFT[nX][29]	
		      SFT->FT_VALCONT   := aSFT[nX][20]
			  SFT->FT_TES       := aSFT[nX][17]
			  SFT->FT_DESPESA   := aSFT[nX][40]
              SFT->FT_DESCONT   := aSFT[nX][51]

			  SFT->FT_PESO	    := 0	
			  SFT->FT_MARGEM    := 0 

              If SF4->F4_PISCOF == '3'.And.SF4->F4_PISCRED =='2'  
			     //PIS/PASEP Apuracao
			     SFT->FT_BASEPIS   := aSFT[nX][31]
			     SFT->FT_ALIQPIS   := aSFT[nX][32]
			     SFT->FT_VALPIS	   := aSFT[nX][33]
			     //COFINS Apuracao
			     SFT->FT_BASECOF   := aSFT[nX][24]
			     SFT->FT_ALIQCOF   := aSFT[nX][25]
			     SFT->FT_VALCOF	   := aSFT[nX][26]
			     //CSLL Apuracao
			     SFT->FT_BASECSL   := 0
			     SFT->FT_ALIQCSL   := 0
			     SFT->FT_VALCSL	   := 0

			  Else	 
                  SFT->FT_BASIMP5  := aSFT[nX][31]
		          SFT->FT_ALQIMP5  := aSFT[nX][32]
		          SFT->FT_VALIMP5  := aSFT[nX][33]
		          SFT->FT_BASIMP6  := aSFT[nX][24]
			      SFT->FT_ALQIMP6  := aSFT[nX][25]
		          SFT->FT_VALIMP6  := aSFT[nX][26]
			  EndIf 
		
			  SFT->FT_CSTPIS    := aSFT[nX][44]
			  SFT->FT_CSTCOF    := aSFT[nX][45]
			  SFT->FT_CODBCC    := ""
			  SFT->FT_CHVNFE    := aSFT[nX][39]
			  //Valor do FECP
			  SFT->FT_BASFECP   := aSFT[nX][48]
			  SFT->FT_ALQFECP   := aSFT[nX][49]
			  SFT->FT_VALFECP   := aSFT[nX][50]

			  //Valor do FECOP RN
			  SFT->FT_ALFECRN	:= 0
			  SFT->FT_VFECPRN	:= 0
			  SFT->FT_VFESTRN	:= 0
			  //Valor do FECP-MG
			  SFT->FT_ALFECMG	:= 0
			  SFT->FT_VFECPMG	:= 0
			  SFT->FT_VFESTMG	:= 0
			  //Valor do FECP-MT
			  SFT->FT_ALFECMT	:= 0
			  SFT->FT_VFECPMT	:= 0
			  SFT->FT_VFESTMT	:= 0
			  
			  //Aliquota Majorada da COFINS
			  SFT->FT_MVALCOF   := 0
			  SFT->FT_MALQCOF   := 0
			  //Aliquota Majorada da PIS
			  SFT->FT_MVALPIS   := 0
			  SFT->FT_MALQPIS   := 0							
			  //CPRB
			  SFT->FT_ATIVCPB	:= ""
			  SFT->FT_BASECPB   := 0 
			  SFT->FT_VALCPB    := 0 
			  SFT->FT_ALIQCPB   := 0 
			
			  SFT->FT_DIFAL	    := 0 
			  SFT->FT_PDORI	    := 0 
			  SFT->FT_PDDES	    := 0

              //ICMS 		
			  SFT->FT_BASERET   := aSFT[nX][46]	
			  SFT->FT_ICMSRET	:= aSFT[nX][34]	
			  SFT->FT_BASEICM   := aSFT[nX][27]
			  SFT->FT_ALIQICM   := aSFT[nX][30]
			  SFT->FT_OBSSOL    := aSFT[nX][34]
			  //Valor da aliquota de ICMS Solidario
			   SFT->FT_ALIQSOL   := aSFT[nX][47]
			  
 			  Do CASE
 		             CASE SF4->F4_LFICM == "T"
				          SFT->FT_VALICM := aSFT[nX][28]
                     CASE SF4->F4_LFICM == "I"
			              SFT->FT_ISENICM := IIf(aSFT[nX][53]==0,aSFT[nX][28],aSFT[nX][16]-aSFT[nX][27])
			         CASE SF4->F4_LFICM == "O"
			              SFT->FT_OUTRICM := IIf(aSFT[nX][27]==0.And.aSFT[nX][53],aSFT[nX][16],IIf(aSFT[nX][27]<aSFT[nX][16].And.aSFT[nX][53],aSFT[nX][16]-aSFT[nX][27],aSFT[nX][28]))
					 CASE SF4->F4_LFICM == "B"	
					      SFT->FT_OBSICM := aSFT[nX][28]
		      EndCASE

              //FECP ST
			  SFT->FT_BSFCPST := aSFT[nX][41]	
			  SFT->FT_ALFCPST := aSFT[nX][42]	
			  SFT->FT_VFECPST := aSFT[nX][43]	
              
			  //IPI
			  SFT->FT_BASEIPI	:= aSFT[nX][21]	
			  SFT->FT_ALIQIPI	:= aSFT[nX][22]	
			  SFT->FT_CTIPI     := aSFT[nX][52]
			  Do CASE
 		             CASE SF4->F4_LFIPI == "T"
				          SFT->FT_VALIPI := aSFT[nX][23]
                     CASE SF4->F4_LFIPI == "I"
			              SFT->FT_ISENIPI := aSFT[nX][23]
			         CASE SF4->F4_LFIPI == "O"
			              SFT->FT_OUTRIPI := aSFT[nX][23]
					 CASE SF4->F4_LFIPI == "P"
			              SFT->FT_IPIOBS := aSFT[nX][23]	  
		      EndCASE
			  
			  MsUnlock()
			
		      //Wederson - Atualiza o estoque
			  If aSFT[nX][37] == "S"
			     SB1->(dbSetOrder(1))
			     If SB1->(dbSeek(xFilial("SB1")+aSFT[nX][09]))
	                SB2->(dbSetOrder(1))
	                If SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
		               Reclock("SB2",.F.)
	                   SB2->B2_QATU := SB2->B2_QATU-aSFT[nX][14]
		               MsUnlock()
					EndIf   
				 EndIf	
	          EndIf
	
		EndIf

        If aSFT[nX][28]>0
		   dbSelectArea("CD2")
	       dbSetOrder(1)
           If! dbSeek(xFilial("CD2")+cTpOper+aSFT[nX][02]+aSFT[nX][01]+aSFT[nX][03]+aSFT[nX][04]+aSFT[nX][08]+aSFT[nX][09]+"ICM" )
				RecLock("CD2",.T.)
				CD2->CD2_FILIAL := xFilial("CD2")
				CD2->CD2_TPMOV  := cTpOper
				CD2->CD2_SERIE  := aSFT[nX][02] 
				CD2->CD2_DOC    := aSFT[nX][01]
				CD2->CD2_CODCLI := aSFT[nX][03]
				CD2->CD2_LOJCLI := aSFT[nX][04]
				CD2->CD2_CODFOR := aSFT[nX][03]
				CD2->CD2_LOJFOR := aSFT[nX][04]
				CD2->CD2_ITEM   := aSFT[nX][08]
				CD2->CD2_CODPRO := aSFT[nX][09]
				CD2->CD2_IMP    := "ICM"
				CD2->CD2_ORIGEM := ""
				CD2->CD2_CST    := ""
				CD2->CD2_MODBC  := "3"
				CD2->CD2_MVA    := 0
				CD2->CD2_PREDBC := 0
				CD2->CD2_BC     := aSFT[nX][27]
				CD2->CD2_ALIQ   := aSFT[nX][30]
				CD2->CD2_VLTRIB := aSFT[nX][28]
				CD2->CD2_QTRIB  := aSFT[nX][14]
				CD2->CD2_PAUTA  := 0
				CD2->CD2_PARTIC := ""
				CD2->CD2_FORMU  := ""
				CD2->CD2_DESCZF := 0
				CD2->CD2_GRPCST := ""
				CD2->CD2_CEST   := ""
				CD2->CD2_PICMDF := 0
				CD2->CD2_VDDES  := 0
				CD2->CD2_PDDES  := 0
				CD2->CD2_PDORI  := 0
				CD2->CD2_ADIF   := 0
				CD2->CD2_DESONE := 0
				CD2->CD2_PDEVOL := 0
				CD2->CD2_BFCP   := aSFT[nX][41]	
				CD2->CD2_PFCP   := aSFT[nX][42]	
				CD2->CD2_VFCP   := aSFT[nX][43]	
				MsUnLock()
	        EndIf
		EndIf

        If aSFT[nX][23]>0
	       dbSelectArea("CD2")
		   dbSetOrder(1)
            If! dbSeek(xFilial("CD2")+cTpOper+aSFT[nX][02]+aSFT[nX][01]+aSFT[nX][03]+aSFT[nX][04]+aSFT[nX][08]+aSFT[nX][09]+"IPI" )
				RecLock("CD2",.T.)
				CD2->CD2_FILIAL := xFilial("CD2")
				CD2->CD2_TPMOV  := cTpOper
				CD2->CD2_SERIE  := aSFT[nX][02] 
				CD2->CD2_DOC    := aSFT[nX][01]
				CD2->CD2_CODCLI := aSFT[nX][03]
				CD2->CD2_LOJCLI := aSFT[nX][04]
				CD2->CD2_CODFOR := aSFT[nX][03]
				CD2->CD2_LOJFOR := aSFT[nX][04]
				CD2->CD2_ITEM   := aSFT[nX][08]
				CD2->CD2_CODPRO := aSFT[nX][09]
				CD2->CD2_IMP    := "IPI"
				CD2->CD2_ORIGEM := ""
				CD2->CD2_CST    := ""
				CD2->CD2_MODBC  := ""
				CD2->CD2_MVA    := 0
				CD2->CD2_PREDBC := 0
				CD2->CD2_BC     := aSFT[nX][21]
				CD2->CD2_ALIQ   := aSFT[nX][22]
				CD2->CD2_VLTRIB := aSFT[nX][23]
				CD2->CD2_QTRIB  := aSFT[nX][14]
				CD2->CD2_PAUTA  := 0
				CD2->CD2_PARTIC := ""
				CD2->CD2_FORMU  := ""
				CD2->CD2_DESCZF := 0
				CD2->CD2_GRPCST := ""
				CD2->CD2_CEST   := ""
				CD2->CD2_PICMDF := 0
				CD2->CD2_VDDES  := 0
				CD2->CD2_PDDES  := 0
				CD2->CD2_PDORI  := 0
				CD2->CD2_ADIF   := 0
				CD2->CD2_PFCP   := 0
				CD2->CD2_VFCP   := 0
				CD2->CD2_DESONE := 0
				CD2->CD2_PDEVOL := 0
				MsUnLock()
	        EndIf
		EndIf
	Next 	
	aSF3 :={}						
    aSFT :={}
RestArea(aAreaSF1)
RestArea(aAreaSF2)
RestArea(aArea)

Return(.T.)


//-------------------------------------------------------------------

Static FUNCTION UTVlNfLote(cSerie,cNtIni,cNtFim,cEspecie,dDataEmis)

Local lRet		:=	.t.
Local cSavAlias:=	Alias()
Local nSavOrd	:=	IndexOrd()
Local nSavRec	:=	Recno()
Local cNFiscal	:=	''
Local nNota
Local cNotaSeek
Local cSerId		:= ""

cNfiscal	:=	IIf(Empty(cNtFim),cNtIni,cNtFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Id da serie para compor as chaves ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
If SerieNfID("SF3",3,"F3_SERIE") == "F3_SDOC"
	cSerId := Substr(cSerie,1,3) + StrZero(Month(dDataEmis),2) + Str(Year(dDataEmis),4) + AllTrim(cEspecie)
Else
	cSerId := Substr(cSerie,1,3)
EndIf

dbSelectArea('SF3')
dbSetOrder(5)
Set Filter to substr(F3_CFO,1,1)>='5'
MsSeek(xFilial()+cSerId+cNFiscal,.T.)

While lRet
	If xFilial()+cSerId+cNFiscal==F3_FILIAL+F3_SERIE+F3_NFISCAL .And. Empty(F3_DTCANC)
		HELP(" ",1,"A920NFLOTE")
		lRet:=.f.
		Loop
	Endif
	If F3_TIPO=='L' .and. F3_SERIE==cSerId .and. ;
			Val(F3_NFISCAL)<=Val(cNfiscal) .and. Val(F3_DOCOR)>=Val(cNfiscal)  .And. Empty(F3_DTCANC)
		HELP(" ",1,"A920NFLOTE")		
		lRet:=.f.
		Loop
	Endif
	dbSkip(-1)
	If F3_TIPO=='L' .and. F3_SERIE==cSerId .and. ;
			Val(F3_NFISCAL)<=Val(cNfiscal) .and. Val(F3_DOCOR)>=Val(cNfiscal)  .And. Empty(F3_DTCANC)
		HELP(" ",1,"A920NFLOTE")
		lRet:=.f.
		Loop
	Endif
	If !Empty(cNtFim)
		cNotaSeek:=cNFiscal
		For nNota:=Val(cNtIni) to Val(cNtFim)
			cNotaSeek:=StrTran(cNFiscal,Alltrim(Str(Val(cNFiscal))),Alltrim(Str(nNota)))
			cNotaSeek:=Padr(cNotaSeek,6)
			If MsSeek(xFilial()+cSerId+cNotaSeek,.F.)
				If Empty(F3_DTCANC)
					HELP(" ",1,"A920NFLOTE")
					lRet:=.f.
					Exit
				Endif	
			Endif
		Next
	Endif
	Exit
End

dbClearFilter()
dbSelectArea(cSavAlias)
dbSetOrder(nSavOrd)
dbGoto(nSavRec)

Return (lRet)

//-------------------------------------------------------------------


Static Function UTCbLot(oNFIni,oNFFim,oEmis,oClie,oLoja)
Local lRet 	:= .F.

Do Case
Case Empty(c920NFIni)
	oNFIni:SetFocus()
Case Empty(c920NFFim)
	oNFFim:SetFocus()
Case Empty(d920Emis)
	oEmis:SetFocus()
Case Empty(c920Client)
	oClie:SetFocus()
Case Empty(c920Loja)
	oLoja:SetFocus()
OtherWise
	If !MaFisFound("NF")
		MaFisIni(c920Client,c920Loja,"C","N",SA1->A1_TIPO,MaFisRelImp("MT100",{"SF2","SD2"}),,.T.)
	EndIf
	lRet := .T.

EndCase

Return lRet

//-------------------------------------------------------------------


Static Function UTTotal(nTotal)

Local aArea		:= GetArea()
Local nQuant	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})]
Local nPreco	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
Local cTes		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"})]
Local nDesc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_DESC"})
Local lRet 		:= .T.
Local nDif		:= NoRound(nQuant*nPreco,2)-nTotal
Local cReadVar  := ReadVar()
Local nx

If MaTesSel(cTes)	.And.	nQuant == 0
	If nPreco <> nTotal
		Help(" ",1,"A12003")
		lRet := .F.
	Endif
Else
	If nDif < 0
		nDif := -(nDif)
	EndIf
    
	If cPaisLoc=="BRA"
		If cTipo$'NDB' .And.nDif > 0.09
			Help(" ",1,"A12003")
			lRet := .F.
		EndIf
	Else
		If "D2_TOTAL"$cReadVar
			If nTotal <> a410Arred(nQuant*nPreco,"D2_TOTAL")
				Help(" ",1,"TOTAL")
				lRet := .F.
			EndIf			
		EndIf
	Endif 
Endif

If lRet .And. cPaisLoc<>"BRA"
	If nDesc>0
		aCols[n][nDesc]:=0
		MaFisAlt("IT_DESCONTO",0,n)
	Endif
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------


Static Function UTCombo(cVariavel,aCombo,cCombo,aReferencia)

Local nPos	:= aScan(aCombo,cCombo)

If nPos > 0
	cVariavel	:= aReferencia[nPos]
EndIf


Return (nPos>0)

//-------------------------------------------------------------------


Static Function UTIniCpo(lDo)

Local aArea		:= GetArea()
Local nPosCod 		:= aScan(aHeader,{|x| Trim(x[2])=='D2_COD'} )
Local nPosUM		:= aScan(aHeader,{|x| Trim(x[2])=='D2_UM'} )
Local nPosSegUM		:= aScan(aHeader,{|x| Trim(x[2])=='D2_SEGUM'} )
Local nPosQTSegum	:= aScan(aHeader,{|x| Trim(x[2])=='D2_QTSEGUM'} )
Local nPosConta 	:= aScan(aHeader,{|x| Trim(x[2])=='D2_CONTA'} )
Local nPosDtValid	:= aScan(aHeader,{|x| Trim(x[2])=='D2_DTVALID'} )
Local nPosLocal		:= aScan(aHeader,{|x| Trim(x[2])=='D2_LOCAL'} )
Local nPosTes		:= aScan(aHeader,{|x| Trim(x[2])=='D2_TES'} )
Local nPCodISS		:= aScan(aHeader,{|x| Trim(x[2])=='D2_CODISS'} )
Local nPPrcVen		:= aScan(aHeader,{|x| Trim(x[2])=='D2_PRCVEN' } )
Local nPPrcTab		:= aScan(aHeader,{|x| Trim(x[2])=='D2_PRUNIT' } )
Local nPQtdVen			:= aScan(aHeader,{|x| Trim(x[2])=='D2_QUANT' } )

Default lDo := .T.

If MaFisFound("IT",n)
	If ( cPaisLoc <> "BRA" ) .And. FunName() == "MATA467N" .And. ( !Empty(M->F2_TABELA) )
    	dbSelectArea("SB1")
		dbSetOrder(1)		
		MsSeek(xFilial()+aCols[n][nPosCod])
	
		aCols[n][nPosUM]		:= SB1->B1_UM
		aCols[n][nPosSegUM]		:= SB1->B1_SEGUM
		aCols[n][nPosConta]		:= SB1->B1_CONTA
		aCols[n][nPosLocal]		:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		aCols[n][nPosQtSegum]	:= 0
		If ( nPosTes > 0 )
			aCols[n][nPosTes]	:= If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),aCols[n][nPosTes])
			MaFisAlt("IT_TES",aCols[n][nPosTes],n)
			Eval(bListRefresh)
		EndIf
		If Rastro(aCols[n][nPosCod]) .And. ( nPosDtValid > 0 )
			aCols[n][nPosDtValid]	:= dDataBase + SB1->B1_PRVALID
		EndIf
    	
    	#IFDEF TOP    	
	    	cAliasDA1 := GetNextAlias()
	
	    	dbSelectArea("DA1")
			dbSetOrder(1)
			cQuery    := ""
			cQuery += "SELECT " 
			cQuery += " * "
			cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
			cQuery += "WHERE "
			cQuery += "( DA1.DA1_DATVIG <= '"+ DtoS(M->F2_EMISSAO) + "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) "
			cQuery += "AND DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
			cQuery +=     "DA1.DA1_CODTAB = '"+M->F2_TABELA+"' AND "
			cQuery +=     "DA1.DA1_CODPRO = '"+aCols[n][nPosCod]+"' AND "
			cQuery +=     "DA1.DA1_QTDLOT >= "+Str(aCols[n][nPQtdVen],18,8)+" AND "
			cQuery +=     "DA1.DA1_ATIVO = '1' AND  "
			cQuery +=     "DA1.D_E_L_E_T_ = ' ' "
			
			cQuery += "ORDER BY DA1.DA1_QTDLOT DESC ,DA1.DA1_DATVIG DESC ,"+SqlOrder(DA1->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)
			
		   	If ( nPPrcVen > 0 )
				aCols[n][nPPrcVen]	:= xMoeda((cAliasDA1)->DA1_PRCVEN,(cAliasDA1)->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			Endif
			If ( nPPrcTab > 0 )
			  	aCols[n][nPPrcTab]	:= xMoeda((cAliasDA1)->DA1_PRCVEN,(cAliasDA1)->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			  	MaFisAlt("IT_PRCUNI",aCols[n][nPPrcTab],n)
			Endif
		#ELSE			
    	
	    	dbSelectArea("DA1")
			dbSetOrder(1)
			If ( MsSeek(xFilial("DA1")+M->F2_TABELA+aCols[n][nPosCod]) )
		        If ( nPPrcVen > 0 )
					aCols[n][nPPrcVen]	:= xMoeda(DA1->DA1_PRCVEN,DA1->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			    Endif
			    If ( nPPrcTab > 0 )
			    	aCols[n][nPPrcTab]	:= xMoeda(DA1->DA1_PRCVEN,DA1->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			    Endif
			Endif
		#ENDIF
	Else
		dbSelectArea("SB1") 
		
		dbSetOrder(1)
		MsSeek(xFilial()+aCols[n][nPosCod])	
	
		aCols[n][nPosUM]	:= SB1->B1_UM
		
 		If nPosSegUM <> 0
		aCols[n][nPosSegUM]	:= SB1->B1_SEGUM
		EndIF             
		
		If nPosConta <> 0
		aCols[n][nPosConta]	:= SB1->B1_CONTA    
		EndIF           
			
		aCols[n][nPosLocal]	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		aCols[n][nPosQtSegum]	:= 0
		aCols[n][nPPrcTab] := SB1->B1_PRV1
		If nPCodISS <> 0
			aCols[n][nPCodISS] :=  MaSBCampo("CODISS") 
			MaFisAlt("IT_CODISS", MaSBCampo("CODISS"),N)
		EndIf
		a100SegUM()

		If nPosTes > 0
			aCols[n][nPosTes]	:= If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),aCols[n][nPosTes])
			If  !(cPaisLoc == "ARG" .and. Type("lLocxAuto") <> "U" .and. lLocxAuto)
				MaFisAlt("IT_TES",aCols[n][nPosTes],n)
				Eval(bListRefresh)
			EndIf
		EndIf
		If Rastro(aCols[n][nPosCod])
			aCols[n][nPosDtValid]	:= dDataBase + SB1->B1_PRVALID
		EndIf
	Endif	
EndIf	

If ( cPaisLoc <> "BRA" )
	If ( Type("oGetDados")<>"U" )
		oGetDados:oBrowse:NAT := N
		oGetDados:oBrowse:Refresh()
	Endif
	if lDo
		MaColsToFis(aHeader,aCols,n,"MT100",.T.,.F.,.T.)
		Eval(bDoRefresh)
	EndIf
Endif

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------


Static Function UTItDev(cItemOri)


Local nx
Local cCampo
Local nPosCod	:= 0
Local nPosNfOri	:= 0
Local nPosSerOri:= 0
Local nPosQtd	:= 0
Local nPosPreco	:= 0
Local nPosValor	:= 0
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())

For nx := 1 to Len(aHeader)
	cCampo:=Trim(aHeader[nx,2])
	Do Case
	Case cCampo=="D2_COD"
		nPosCod		:= nX
	Case cCampo=="D2_NFORI"
		nPosNfOri	:= nX
	Case cCampo=="D2_SERIORI"
		nPosSerOri	:= nX
	Case cCampo=="D2_QUANT"
		nPosQtd		:= nX
	Case cCampo=="D2_PRCVEN"
		nPosPreco	:= nX
	Case cCampo=="D2_TOTAL"
		nPosValor	:= nX
	EndCase
Next nx

If !Empty(cItemOri)
	If cTipo$"CPI"
		dbSelectArea("SD2")
		dbSetOrder(3)
		If !MsSeek(xFilial('SD2')+aCols[n][nPosNfOri]+aCols[n][nPosSerOri]+cA100For+cLoja+aCols[n][nPosCod]+cItemOri)
			HELP(" ",1,"A100ITDEV")
			lRet := .F.
		Else
			A103SD2toaCols(SD2->(RecNo()),n)
		EndIf
	ElseIf cTipo == "D"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Notas de Credito e Debito...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetOrder(1)
		If !MsSeek(xFilial('SD1')+aCols[n][nPosNfOri]+aCols[n][nPosSerOri]+cA100For+cLoja+aCols[n][nPosCod]+cItemOri)
			HELP(" ",1,"A100ITDEV")
			lRet := .F.
		Else
			If Empty(Acols[n][nPosPreco])   .And.;
					Empty(Acols[n][nPosQtd])    .And.;
					Empty(aCols[n][nPosValor])
				Acols[n][nPosQtd]    := SD1->D1_QUANT
				Acols[n][nPosPreco]  := SD1->D1_VUNIT
				ACols[n][nPosValor]  := SD1->D1_TOTAL
			Endif
			A103SD1toaCols(SD1->(RecNo()),n)
		EndIf
	EndIf
EndIf


RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------


Static Function UTFinanc(cCondicao,oDlg,aRecSE1,aRecSE2,nPosX)

Local aMoeda	 := {}
Local aTemp		 := {{"","","",CTOD("  /  /  "),0}} 
Local cMoeda     := ""
Local cDescri 	 := CriaVar("E4_DESCRI")
Local cNatureza	 := CriaVar("E1_NATUREZ")
Local dDatCont	 := dDataBase
Local nX         := 0
Local nBaseDup   := 0
Local nMoedaCor  := 0
Local oList
Local oMoeda
Local oNatu
Local oDescri
Local oCond
Local lDoVisual	 := .F.
Local A920SE1ADC := ExistBlock("A920SE1ADC") //Ponto de Entrada para incluir campos na consulta de duplicatas
Local aA920SE1ADC    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array com as duplicatas qdo. for visual      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE4")
dbSetOrder(1)
If MsSeek(xFilial()+cCondicao)
	cDescri := SE4->E4_DESCRI
EndIf
dbSelectArea("SE1")
If !Empty(aRecSE1)
	aTemp := {}
	For nx := 1 to Len(aRecSE1)
		dbGoto(aRecSE1[nx])          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera os titulos tambem quando forem do SIGALOJA:	³
		//³ LOJA701 - LOJA010 - FATA701 						 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_TIPO $ MVNOTAFIS .OR. "LOJA" $ E1_ORIGEM .OR. "FATA701" $ E1_ORIGEM .OR. !Empty(SE1->E1_PREFORI)
			cNatureza := SE1->E1_NATUREZ
			nMoedaCor := SE1->E1_MOEDA                                         
            If A920SE1ADC
   			   aA920SE1ADC := AClone(ExecBlock("A920SE1ADC",.F.,.F.,{"SE1"})) 
   			   aAdd(aTemp,aA920SE1ADC[3]) 
   			Else   
  			   aAdd(aTemp,{E1_NUM,E1_PREFIXO,E1_PARCELA,E1_VENCTO,E1_VALOR}) 
            Endif							
		EndIf
	Next nX
	If Empty(aTemp)
		aTemp := {{"","","",CTOD("  /  /  "),0}}
	EndIf
EndIf
dbSelectArea("SE2")
If !Empty(aRecSE2)
	aTemp := {}
	For nx	:= 1 to Len(aRecSE2)
		dbGoto(aRecSE2[nx])          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera os titulos tambem quando forem do SIGALOJA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE2->E2_TIPO $ MV_CPNEG
			cNatureza    := SE2->E2_NATUREZ
			nMoedaCor	:= SE2->E2_MOEDA
			aAdd(aTemp,{E2_NUM,E2_PREFIXO,E2_PARCELA,E2_VENCTO,E2_VALOR})
		EndIf
	Next nX
	If Empty(aTemp)
		aTemp	:= {{"","","",CTOD("  /  /  "),0}}
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array contendo as moedas do sistema          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 to ContaMoeda()
	aADD(aMoeda,Alltrim(STR(nx,3))+":"+GetMv("MV_MOEDA"+Alltrim(STR(nx,3))))
	If nx == nMoedaCor
		cMoeda	:= aMoeda[nMoedaCor]
	EndIf
Next

@ 5,4     SAY "Condicao" Of oDlg PIXEL SIZE 39 ,9 //"Condicao"
@ 4,31    MSGET oCond VAR cCondicao  Picture PesqPict('SF2','F2_COND') When .F.	OF oDlg PIXEL SIZE 22 ,9

@ 19 ,4   SAY "Descr." Of oDlg PIXEL SIZE 19 ,9  //"Descr."
@ 18 ,31  MSGET oDescri VAR cDescri  Picture PesqPict('SE4','E4_DESCRI') When .F. OF oDlg PIXEL SIZE 54 ,9

@ 33 ,4   SAY "Natureza" Of oDlg PIXEL SIZE 41 ,9 //"Natureza"
@ 33 ,31  MSGET oNatu VAR cNatureza  Picture PesqPict('SE2','E2_NATUREZ') When .F. OF oDlg PIXEL SIZE 54,9

@ 48 ,4   SAY "Moeda" Of oDlg PIXEL SIZE 30 ,9  //"Moeda"
@ 47 ,31  MSCOMBOBOX oMoeda VAR cMoeda ITEMS aMoeda  When .F. SIZE 54 ,50 OF oDlg PIXEL

If A920SE1ADC
   oList:= TWBrowse():New( 5,89,nPosX,53,,aA920SE1ADC[1],aA920SE1ADC[2],oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
   oList:SetArray(aTemp)
   oList:bLine := {|| UTLine(oList,aTemp,aA920SE1ADC[4])}
Else
   oList:= TWBrowse():New( 5,89,nPosX,53,,{"Número","Prefixo","Parc.","Vencto","Valor"},{35,35,20,35,60},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Parc."###"Vencto"###"Valor"
   oList:SetArray(aTemp)
   oList:bLine := {|| UTLine(oList,aTemp,{"E1_NUM","E1_PREFIXO","E1_PARCELA","E1_VENCTO","E1_VALOR"})}
Endif

Return oList

//-------------------------------------------------------------------


Static Function UTLine(oList,aTemp,aCpos)
Local i    := 1
Local aRet := {}
for i:=1 to len(aTemp[1])
    aadd(aRet,TransForm(aTemp[oList:nAt][i],PesqPict("SE1",aCpos[i])))
end   
Return aRet

//-------------------------------------------------------------------


Static Function UTPedido(nTipo,aPedido,cTexto)

Local aArea      := GetArea()
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local aRecNo     := {}
Local nSavN      := N
Local nUsado     := 0
Local nX         := 0
Local nY         := 0
Local oDlg
Local oGetDad
Local oBtn

Private aHeader := {}
Private aCols   := {}
Private N		:= 1

Do Case
Case ( nTipo == 1 )
	If ( Len(aPedido) > 1 )
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SC5")
		While ( !Eof() .And. SX3->X3_ARQUIVO=="SC5" )
			If ( SX3->X3_BROWSE=="S" )
				Aadd(aHeader,{ AllTrim(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_ARQUIVO,;
					SX3->X3_CONTEXT} )
				nUsado++
			EndIf
			dbSelectArea("SX3")		
			dbSkip()
		End
		For nX := 1 To Len(aPedido)
			dbSelectArea("SC5")
			dbSetOrder(1)
			MsSeek(xFilial("SC5")+aPedido[nX])
			aadd(aRecNo,RecNo())
			aadd(aCols,Array(nUsado))
			For nY := 1 To Len(aHeader)
				If ( aHeader[nY][10] != "V" )
					aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
				Else
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2],.T.)
				EndIf
			Next nY
		Next nX
		DEFINE MSDIALOG oDlg FROM	09,0 TO 28,80 TITLE "Pedidos" OF oMainWnd  //"Pedidos"
		@ 001,002 TO 031,267 OF oDlg	PIXEL
		@ 015,005 SAY "N.Fiscal :" SIZE 020,009 OF oDlg PIXEL  //"N.Fiscal :"
		@ 015,030 SAY cTexto             SIZE 150,009 OF oDlg PIXEL
		oGetDad := MsGetDados():New(035,002,135,315,2)
		DEFINE SBUTTON 		FROM 005,280 TYPE 1  ENABLE OF oDlg ACTION ( oDlg:End() )
		DEFINE SBUTTON oBtn FROM 020,280 TYPE 15 ENABLE OF oDlg ACTION ( oGetDad:oBrowse:lDisablePaint:=.T.,UTMostra(1,aRecNo[N]),oGetDad:oBrowse:lDisablePaint:=.F. )
		oBtn:lAutDisable := .F.
		ACTIVATE MSDIALOG oDlg
	Else
		dbSelectArea("SC5")
		dbSetOrder(1)
		MsSeek(xFilial("SC5")+aPedido[1])
		UTMostra(1,RecNo())
	EndIf
Otherwise
	Alert("Opcao nao disponivel")	 //"Opcao nao disponivel"
EndCase

N       := nSavN
aCols   := aClone(aSavCols)
aHeader := aClone(aSavHead)

RestArea(aArea)
Return(.T.)

//-------------------------------------------------------------------


Static Function UTMostra(nTipo,nRecNo)

Local aArea := GetArea()
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local nSavN      := N
Private N        := 1
Do Case
Case ( nTipo == 1 )
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsGoto(nRecNo)	
	A410Visual("SC5",nRecNo,2)
EndCase
N       := nSavN
aCols   := aClone(aSavCols)
aHeader := aClone(aSavHead)
RestArea(aArea)
Return(.T.)

//-------------------------------------------------------------------


Static Function UTTrack()

Local aEnt     := {}
Local cKey     := c920Nota + c920Serie + c920Client + c920Loja
Local nPosItem := GDFieldPos( "D2_ITEM" )
Local nPosCod  := GDFieldPos( "D2_COD"  )
Local nLoop    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := 1 To Len( aCols )
	If !Empty(aRemito[nLoop][1])
		AAdd( aEnt, { "SD2", aRemito[nLoop][1]+aRemito[nLoop][2]+ c920Client + c920Loja + aCols[ nLoop, nPosCod ] + aRemito[ nLoop, 3 ] } )
	Else
		AAdd( aEnt, { "SD2", cKey + aCols[ nLoop, nPosCod ] + aCols[ nLoop, nPosItem ] } )
	Endif
Next nLoop

MaTrkShow( aEnt )

Return( .T. )

//-------------------------------------------------------------------


Static Function ProcH(cCampo)
Return aScan(aAutoCab,{|x|Trim(x[1])== cCampo })  

//-------------------------------------------------------------------

Static Function UTConhec() 

Local aRotBack := AClone( aRotina ) 
Local nBack    := N

Private aRotina := {}

Aadd(aRotina,{"Banco de Conhecimento","MsDocument", 0 , 2,0,NIL}) //"Banco de Conhecimento"

MsDocument( "SF2", SF2->( Recno() ), 1 ) 

aRotina := AClone( aRotBack ) 
N := nBack 

Return( .t. ) 

//--------------------------------------

Static Function UTDocume( cAlias, nRec, nOpc ) 

Local aArea    := GetArea() 
Local xRet   

SD2->( MsGoto( nRec ) ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posiciona no SF2 a partir do SD2                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF2->( dbSetOrder( 1 ) )    

If SF2->( MsSeek( xFilial( "SF2" ) + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_FORMUL ) ) 
	xRet := MsDocument( "SF2", SF2->( Recno() ), nOpc ) 
EndIf	             

RestArea( aArea )
	
Return( xRet ) 

//-----------------------------------------

Static Function UTNFe(cCampo,aNFEletr)

Local lRet := .T.

If cPaisLoc == "BRA"
	If cCampo == "EMINFE"    
		If !Empty(aNFEletr[03]) .And. aNFEletr[03] < d920Emis
			Help("",1,"A100NFEDT")	
			lRet := .F.
		Endif
	ElseIf cCampo == "CREDNFE"
		If aNFEletr[05] < 0
			Help("",1,"A100NFECR")	
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

//---------------------------------------------------------------

Static Function UTMenu()
     
Private aRotina := {	{ "Pesquisar"	 ,"AxPesqui"     , 0 , 1 , 0 ,.F.}}	
						
If l920Auto
 
   aAdd(aRotina,{ "Incluir"	,"U_UTNFSAI()", 0 , 3 , 0 ,NIL}) // Legenda

Else
   aAdd(aRotina,{ "Visualizar"   ,"a920NFSAI"    , 0 , 2 , 0 ,NIL})	//"Visualizar"
   aAdd(aRotina,{ "Importar XML" ,"U_UTXmlFAT()" , 0 , 3 , 0 ,NIL}) // Importar
   aAdd(aRotina,{ "Cancelamento" ,"U_UTXmlCan()" , 0 , 3 , 0 ,NIL}) // Cancelamento
   aAdd(aRotina,{ "Exluir"	     ,"U_UTXmlExc()" , 0 , 5 , 0 ,NIL}) // Excluir
EndIf

Return(aRotina)

//------------------------------------------------------------

User Function UTXmlFAT()
Local cPerg  		:= "UTXMLIMP1"+Space(01)
Local cFunction		:= "UTXMLIMP"
Local cTitle		:= "Importa��o de XML"
Local bProcess		:= { |oSelf| ImportarNf(oSelf) }                   
Local cDescription	:= "Rotina ir� gerar notas de saida de produtos atrav�s da importa��o do XML. G.I.M GIOVANNONI "
Local cArqNtx 		:= CriaTrab( NIL, .F. )

fCriaPerg(cPerg)

tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg)

If Len(aLogErro)>0
    If MSGYESNO("Deseja imprimir detalhes da importa��o ?"," Importa��o XML - G.I.M.")
	   MsgInfo("Em desenvolvimento.","A t e n � � o")
	   //fImpLog()
	EndIf
EndIf

Return

//------------------------------------------------------------

User Function UTXmlCan()
Local cFunction		:= "UTCANXML"
Local cTitle		:= "Importa��o de XML - Cancelamento"
Local bProcess		:= { |oSelf| fCancNf(oSelf) }                   
Local cDescription	:= "Rotina ir� importar a nota de saida e o seu cancelamento atrav�s da importa��o do XML. G.I.M GIOVANNONI "

Private oNFeCan

tNewProcess():New(cFunction,cTitle,bProcess,cDescription,Nil)

Return

//------------------------------------------------------------

Static Function fCancNf(oRegua)
Local oXml
Local oDest
Local aNFS		  := {}
Local aNF		  := {}
Local lAuto 	  := .F.
Local lExibErro   := .F.
Local lNfe        := .F.
Local nX
Local cNF         := ""
Local cSerie      := ""
Local cCliente    := ""
Local cLoja       := ""
Local dDtCanc     := dDataBase
Local cStat       := ""
Local nNotas      := 0
Local cMotivo     := ""

Private _cMeuCnpj := IIf(cEMpAnt == "99","24990900000191",SM0->M0_CGC)
Private aNewClie  := {}
Private aNewForn  := {}

Private cPessoa   := "" 
Private nParam01  := 0//MV_PAR02
Private lDev      := .T.

Private lLancPad10	:= .F.//VerPadrao( "610" )
Private lLancPad20	:= .F.//VerPadrao( "620" )    
Private lContOnLine := .F.                       
Private nTotal      := 0
Private cLoteFat    := If( SX5->( DbSeek( xFilial() + '09FAT' ) ) , AllTrim( SX5->X5_DESCRI ) , "FAT " ) 
Private nHdlPrv     := 0
Private cArquivo   
Private lMostraLanc := .F.
Private _cFuncao    :=  "MATA460"

Private aCanXml

lFin  :=.F.
lSF3  :=.F.
lSF2  :=.F.
lSD2  :=.F.
lSE1  :=.F.
lCanc :=.T.
					
cDirXml     := Alltrim(mv_par01)
aCanXml     := ExtraiArq(2,@cDirXml)

aSort(aCanXml,,,{|x,y| x[1] < y[1]})

oRegua:SetRegua1(4)
If Len(aCanXml)>0
	oRegua:IncRegua1("Importando XML de Produtos - Cancelamento")
	oRegua:SetRegua2(Len(aCanXml))
	For nX := 1 to Len(aCanXml)
    	If Ascan(aCanXml, { |X| Upper(X[1]) == SubStr(aCanXml[nX,01],1,44)+"_110111-PROCEVENTONFE.XML"})
          
		    If Ascan(aCanXml, { |X| Upper(X[1]) == SubStr(aCanXml[nX,01],1,44)+"-PROCNFE.XML"})
		 
				oRegua:IncRegua2("Iniciando processo de importa��o XML "+AllTrim(Str(nX))+"/"+AllTrim(Str(Len(aCanXml)))+". CANCELAMENTO.")
		
				lNfe := .F.
				oXml := OpenXml(cDirXml+aCanXml[nX,01])
				If ValType(oXML)<> "O"
					Loop
				EndIf
		
				//--> Produto
				If XmlChildEx(oXML, "_NFEPROC")  <> Nil
					oNFe := IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)   
					oDest:=oXml:_nfeProc:_NFe:_infNFe:_DEST  
					cNF:= StrZero(Val(oNFe:_IDE:_NNF:TEXT),TamSx3("F2_DOC")[1])		//->> 02 - Numero da Nota
                    cSerie:= oNFe:_IDE:_SERIE:TEXT	     
			        cSerie:= cSerie+Space(TamSx3("F2_SERIE")[1]-Len(cSerie))

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
						If XmlChildEx(oXml:_NFEPROC, "_PROTNFE") <> NIL
  			       	        dbSelectArea("SF3")
	        	   	        dbSetOrder(6)
	        	   	        If! dbSeek(xFilial("SF2")+cNF+cSerie)
					    		ExtrNfProd(oXml,@aNF ,cDirXml+aCanXml[nX,01])

								If Len(aNFS)+Len(aNF) > 0
	                               oRegua:IncRegua1("Gerando os dados fiscais - C a n c e l a m e n t o")
	                               ClassNf(@aNF,@aNFS,@oRegua)
	                               If Len(aNFS)+Len(aNF) == 0
	 	                              Return
	                               EndIf
                                Else
	                               MsgAlert("N�o foram encontrados arquivos XML para importa��o !")
	                               Return
                                EndIf
                                If Len(aNFS)+Len(aNF) > 0 .And. MsgYesNo("Confirma a gera��o das notas fiscais importadas pela leitura dos XMLs ?")
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
	
	                               //->> Notas de Produto
	                               If Len(aNF)>0
		                              ProcXmlProd(lAuto,aNF,@oRegua,lExibErro)
	                               EndIf
	
                                EndIf
						    EndIf
						EndIf
					Else
						aAdd( aLogXML , { "PRODUTO","NF-e n�o pertence a este cliente",cDirXml+aCanXml[nX,01],.F.} )
						AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"NF-e n�o pertence a este cliente"})
					EndIf
			    ElseIf  XmlChildEx(oXML, "_PROCEVENTONFE")  <> Nil		
				 
				        If  XmlChildEx(oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO, "_DHREGEVENTO")  <> Nil
						    dDtCanc:= StoD(StrTran(oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT,"-",""))
                        EndIf 
                        
                        dbSelectArea("SE1")
                        dbSetOrder(1) 
                        If dbSeek(xFilial("SE1")+xFilial("SF2")+Alltrim(cSerie)+cNF)  
                           While! Eof().And.xFilial("SE1")+xFilial("SF2")+Alltrim(cSerie)+cNF == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM 
                                  aVetor	:= {}

                                  aVetor  := {	{"E1_PREFIXO"	,SE1->E1_PREFIXO	,Nil},;
						                        {"E1_NUM"		,SE1->E1_NUM		,Nil},;
						                        {"E1_PARCELA"	,SE1->E1_PARCELA	,Nil},;
						                        {"E1_TIPO"		,SE1->E1_TIPO		,Nil},;
						                        {"E1_NATUREZ"	,SE1->E1_NATUREZ    ,Nil},;
						                        {"E1_CLIENTE"	,SE1->E1_CLIENTE	,Nil},;
						                        {"E1_LOJA"		,SE1->E1_LOJA   	,Nil},;
						                        {"E1_EMISSAO"	,SE1->E1_EMISSAO    ,Nil},;
						                        {"E1_VENCTO"	,SE1->E1_VENCTO     ,Nil},;
						                        {"E1_VENCREA"	,SE1->E1_VENCREA	,Nil},;
						                        {"E1_VALOR"		,SE1->E1_VALOR		,Nil},;
						                        {"E1_VEND1"		,SE1->E1_VEND1		,Nil},;
						                        {"E1_BASCOM1"	,SE1->E1_BASCOM1	,Nil},;
						                        {"E1_ORIGEM"    ,SE1->E1_ORIGEM		,Nil},;
						                        {"E1_COMIS1"	,SE1->E1_COMIS1		,Nil}}

		                           MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) //Exclusao
   
                                   If lMsErroAuto
			                          DisarmTransaction()
			                          MostraErro()
			                          Exit
								   else
									   lSe1:=.T.	  
		                           EndIf
			                       dbSelectArea("SE1")
			                       dbSkip()
                           End
                        Else
						    lSe1:=.T.	
						EndIf

                        If lSe1
				      		dbSelectArea("SF2")
	        				dbSetOrder(1)
	        				If dbSeek(xFilial("SF2")+cNF+cSerie)
						   		cCliente:= SF2->F2_CLIENTE
						   		cLoja:= SF2->F2_LOJA
               					lSf2:=.T.
			   					Reclock("SF2",.F.)
			   					dbDelete()
			   					MsunLock()
							EndIf
	                    EndIf

		    			If lSf2
               				dbSelectArea("SD2")
	           				dbSetOrder(3)
	           				If dbSeek(xFilial("SD2")+cNF+cSerie)
                   				While! Eof().And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == xFilial("SD2")+cNF+cSerie
                          				lSd2:=.T.
			              				Reclock("SD2",.F.)
			              				dbDelete()
			              				MsunLock()
                          				dbSkip()
                   				End 
	           				EndIf
						EndIf

                        If lSf2.And.lSd2

							dbSelectArea("SFT")
	  						dbSetOrder(1)
	  						If dbSeek(xFilial("SFT")+"S"+cSerie+cNF+cCliente+cLoja)
         						While! Eof().And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+cSerie+cNF+cCliente+cLoja
                                	  lSft:=.T.
			   					  	Reclock("SFT",.F.)
			                      	FT_OBSERV:="NF CANCELADA"
									FT_DTCANC:=dDtCanc
									MsunLock()
                                  	dbSkip()
         						End 
	  						EndIf

      						If lSft
							   If  XmlChildEx(oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO, "_CSTAT")  <> Nil
	                               cStat:=Alltrim(oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT)					 
						       EndIf
							   If  XmlChildEx(oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO, "_XMOTIVO")  <> Nil
	                               cMotivo:=SubStr(Alltrim(oXML:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT),1,TamSx3("F3_DESCRET")[1])					 
						       EndIf
	     					   
	     					   dbSelectArea("SF3")
	     					   dbSetOrder(5)
	     					   If dbSeek(xFilial("SF3")+cSerie+cNF+cCliente+cLoja)
            						While! Eof().And. SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA == xFilial("SF3")+cSerie+cNF+cCliente+cLoja
                   							lSf3:=.T.
											nNotas ++
			       							Reclock("SF3",.F.)
											F3_REPROC  :="N"
			       							F3_OBSERV  :="NF CANCELADA"
											F3_DTCANC  :=dDtCanc
											F3_CODRSERF:="101" //If(cStat == "135","101",cStat)    Solicita��o PAulo Ez4 - 12/06
											F3_DESCRET :=UPPER(cMotivo)
											F3_CODRET  :="M"                     
			       							MsunLock()
                   							dbSkip()
            						End 
	     						EndIf
							EndIf
						EndIf
				EndIf		
			Else
                MsgInfo("N�o encontrado o XML com os dados da nota para a chave "+SubStr(aCanXml[nX,01],1,44)+".","A t e n � � o")	 
			EndIf		
	    Else
		    MsgInfo("N�o encontrado o XML de cancelamento para a chave "+SubStr(aCanXml[nX,01],1,44)+".","A t e n � � o")	 
		EndIf 		
	Next nX

   If lSf3
       Aviso( "Processo conclu�do !!" , "Cancelamento importado -  "+Alltrim(Str(nNotas))+" nota(s) de produtos com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "G.I.M. - Processo espec�fico para importa��o de XML." )
   EndIf
		 
EndIf
Return


//------------------------------------------------------------


Static Function ImportarNf(oRegua)
Local oXml
Local oDest
Local aNFS		  := {}
Local lAuto 	  := .F.
Local lExibErro   := .F.
Local lNfe        := .F.
Local nX
Local aNF         := {}

Private _cMeuCnpj := IIf(cEMpAnt == "99","24990900000191",SM0->M0_CGC)
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

cDirXML   := Alltrim(mv_par01)
aArqXml   := ExtraiArq(2,@cDirXml)

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
				aAdd( aLogXML , { "PRODUTO","NF-e n�o pertence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
				AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"NF-e n�o pertence a este cliente"})
			EndIf
			
		EndIf
		
	Next nX
	
EndIf

If Len(aNFS)+Len(aNF) > 0
	oRegua:IncRegua1("Montando os Dados Para Classifica��o das NF's...")
	ClassNf(@aNF,@aNFS,@oRegua)
	If Len(aNFS)+Len(aNF) == 0
		Return
	EndIf
Else
	MsgAlert("N�o foram encontrados arquivos XML para importa��o !")
	Return
EndIf

If Len(aNFS)+Len(aNF) > 0 .And. MsgYesNo("Confirma a gera��o das notas fiscais importadas pela leitura dos XMLs ?")
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
	
	//->> Notas de Produto
	If Len(aNF)>0
		ProcXmlProd(lAuto,aNF,@oRegua,lExibErro)
	EndIf
	
	If Len(aNFS)+Len(aNF) <> nServ+nProd
		//Aviso( "Aten??o" , "Foram submetidas a importa??o "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de servi?os, contudo foram importadas "+Alltrim(Str(nProd))+" de produtos e "+Alltrim(Str(nServ))+" de servi?os."+CRLF+"Vide Log de Eventos.", { 'Ok' } , 2 , "Importa??es de XML" )
	   Aviso( "Processo conclu�do !!" , "Foram submetidas a importa��o "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos contudo foram importadas "+Alltrim(Str(nProd))+" de produtos."+CRLF+"Vide Log de Eventos.", { 'Ok' } , 2 , "G.I.M. - Processo espec�fico para importa��o de XML." )
	Else
		//Aviso( "Aten??o" , "Foram submetidas a importa??o "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de servi?os, com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "Importa??es de XML" )
		Aviso( "Processo conclu�do !!" , "Foram submetidas a importa��o "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "G.I.M. - Processo espec�fico para importa��o de XML." )
	EndIf
	
EndIf

Return

//---------------------------------------------------------

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
	MsgStop('O arquivo n�o pode ser encontrado no local indicado.'+CRLF+'"'+cArquivo+'"'+CRLF)
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

//----------------------------------------------------------
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
		cPasta := cGetFile(cDirTmp,"Selecione a pasta para importa��o dos XMLs...",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
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


//-----------------------------------------------------------

Static Function ExtrNfProd(oXml,aDados,cArquivo)

Local oNFe 	:= IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)
Local aItens:= {}
Local aNF	:= {}
Local aRet  := {}
Local cCFOP := ""
Local nX	:= 1
Local nPIPI := 0

Local cCGC  := ""   

Local dDtEmiss	:= CTOD("//")

Local cVrICMSST :=""
Local cBsICMSST :=""
Local cPICMS    :=""
Local cCpoIPI    :=""
Local cCpoICMS   :=""
Local CpoCOFINS :=""
Local cCpoPIS    :=""
Local cCpoBcIPI :=""
Local cTag11IPI  :=""
Local cTag12IPI  :=""
Local cTag13IPI  :=""
Local cTag14COF  :=""
Local cTag15COF  :=""
Local cTag16COF  :=""
Local cTag17PIS  :=""
Local cTag18PIS  :=""
Local cTag19PIS  :=""
Local cTag20ICM  :=""
Local cTag21ICM  :=""
Local cTag22ICM  :=""
Local cTag23ICM  :=""
Local cTag24ICM  :=""
Local cTag25ICM  :=""
Local cTag26ICM  :=""
Local cTag27ICM  :=""
Local cTag28ICM  :=""
Local cTag29ICM  :=""
Local cTag30ICM  :=""
Local cTag31ICM  :=""
Local cTag34ICM  :=""
Local cTag35ICM  :=""
Local cTag36ICM  :=""
Local cTag37PIS  :=""
Local cTag38COF  :=""
Local cTag39ICM  :=""
Local cTag40ICM  :=""
Local cTag41ICM  :=""
Local cTag42ICM  :=""
Local cTag43ICM  :=""
Local cTag44IPI  :=""
Local cTag45ICM  :=""

Local nVrMerc   := 0
Local nBsIPI    := 0
Local nVrICMSST := 0
Local nBsICMSST := 0
Local nContIcm  := 1
Local nContIpi  := 1
Local nContPis  := 1
Local nContCof  := 1
Local aSitICMS  := {"_ICMS00","_ICMS10","_ICMS20","_ICMS30","_ICMS40","_ICMS41","_ICMS51","_ICMS60","_ICMS70","_ICMS90"}
Local aSitIPI   := {"_IPITRIB","_IPINT"}
Local aSitPIS   := {"_PISALIQ","_PISNT","_PISOUTR"}
Local aSitCofins:= {"_COFINSALIQ","_COFINSNT","_COFINSOUTR"}

Local lICMS     := .F.
Local lIPI      := .F.
Local lPIS      := .F.
Local lCOFINS   := .F.

Private cTpOper := ""

Private lMsErroAuto := .F.

//-->> 01 Tipo da geracao da NF
//If Alltrim(oNFe:_EMIT:_CNPJ:TEXT) == Alltrim(_cMeuCnpj) //.And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
If !(lDev)
	aAdd(aNF,"SAIDA")                                               //01
	cTpOper := "S"   
Else	
   aAdd(aNF,"SAIDA")
EndIF
	           
aAdd(aNF,StrZero(Val(oNFe:_IDE:_NNF:TEXT),TamSx3("F2_DOC")[1]))			//->> 02 - Numero da Nota
aAdd(aNF,oNFe:_IDE:_SERIE:TEXT)											//->> 03 - Serie

If cPessoa == "J"
    If XmlChildEx(oNFe:_DEST,"_CNPJ" )<>Nil
	   aAdd(aNF,oNFe:_DEST:_CNPJ:TEXT)										//->> 04 - CNPJ CLIENTE
	   cCGC:=oNFe:_DEST:_CNPJ:TEXT
	else
       aAdd(aNF,"")
	EndIf	   
ElseIf cPessoa == "F"
	aAdd(aNF,oNFe:_DEST:_CPF:TEXT)										//->> 04 - CPF	CLIENTE
	cCGC:=oNFe:_DEST:_CPF:TEXT
Else
	aAdd(aNF,"")														//->> 04 - CPF ou CPNJ n?o encontrado no XML 
EndIf

If cTpOper == "S"
    
    //Tratamento para Exportador sem CNPJ ou CPF
	If cPessoa <> ""	
	    SA1->(dbSetOrder(3))
		If! SA1->(dbSeek(xFilial("SA1")+cCGC))
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
	    cCFOP     := oNFe:_DET[nX]:_PROD:_CFOP:TEXT
		nVrMerc   += Val(oNFe:_DET[nX]:_PROD:_VPROD:TEXT)
		
		SB1->(dbSetOrder(1))
		If! SB1->(dbSeek(xFilial("SB1")+ALLTRIM(UPPER(oNFe:_DET[nX]:_PROD:_CPROD:TEXT))))

		    nPIPI :=0
           If XmlChildEx(oNFe:_DET[nX]:_IMPOSTO:_IPI ,"_IPITRIB") <> Nil
		      If XmlChildEx(oNFe:_DET[nX]:_IMPOSTO:_IPI:_IPITRIB ,"_PIPI") <> Nil
                 nPIPI:=Val(oNFe:_DET[nX]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
              EndIf
		   EndIf	

		    aProduto:= { {"B1_COD"     ,ALLTRIM(UPPER(oNFe:_DET[nX]:_PROD:_CPROD:TEXT)) ,NIL},; 
                         {"B1_DESC"    ,SubStr(ALLTRIM(UPPER(oNFe:_DET[nX]:_PROD:_XPROD:TEXT)),1,TamSX3("B1_DESC")[1]) ,NIL},; 
                         {"B1_TIPO"    ,"PA" ,Nil},; 
                         {"B1_UM"      ,ALLTRIM(oNFe:_DET[nX]:_PROD:_UCOM:TEXT) ,Nil},; 
                         {"B1_LOCPAD"  ,"01" ,Nil},; 
                         {"B1_PICM"    ,0 ,Nil},; 
                         {"B1_IPI"     ,nPIPI ,Nil},; 
                         {"B1_CONTRAT" ,"N" ,Nil},; 
					     {"B1_CODGTIN" ,ALLTRIM(oNFe:_DET[nX]:_PROD:_CEAN:TEXT),Nil},;
                         {"B1_POSIPI"  ,UPPER(oNFe:_DET[nX]:_PROD:_NCM:TEXT) ,Nil}} 
  
            MSExecAuto({|x,y| Mata010(x,y)},aProduto,3)

		    If lMsErroAuto
               MostraErro()
		       If MsgYesNo("Produto "+ALLTRIM(UPPER(oNFe:_DET[nX]:_PROD:_CPROD:TEXT))+" n�o cadastrado. Cancela processo de importa��o?","A t e n � � o")
		          Return(Nil)
		       EndIf
            Endif
        EndIf
		
        //------------------------------------------------------------------------
		// Wederson L. Santana 02/04/2020
		// Leitura din�mica dos itens do XML - IMPOSTOS
		//------------------------------------------------------------------------

	    For nContCof:=1 To Len(aSitCofins)
            If XmlChildEx(oNFe:_DET[nX]:_IMPOSTO:_COFINS,aSitCofins[nContCof]) <> NIL
			   lCOFINS := .T.
			
			   For nContPis:=1 To Len(aSitCofins)
			       If XmlChildEx(oNFe:_DET[nX]:_IMPOSTO:_PIS,aSitPIS[nContPis]) <> NIL
                      lPIS := .T.

                      For nContIpi:=1 To Len(aSitIPI)
		                  If XmlChildEx(oNFe:_DET[nX]:_IMPOSTO:_IPI ,aSitIPI[nContIpi]) <> Nil
	                         lIPI := .T.

	                         For nContIcm:=1 To Len(aSitICMS) 

                                 If XmlChildEx(oNFe:_DET[nX]:_IMPOSTO:_ICMS ,aSitICMS[nContICM]) <> Nil
                                    lICMS     := .T.

	                                cCpoIPI    :="oNFe:_DET[nX]:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]
					                cCpoICMS   :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]
							        cCpoCOFINS :="oNFe:_DET[nX]:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]
							        cCpoPIS    :="oNFe:_DET[nX]:_IMPOSTO:_PIS:"+aSitPIS[nContPis]
							 
	                                cTag11IPI  :="oNFe:_DET[nX]:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_PIPI:TEXT"
							        cTag12IPI  :="oNFe:_DET[nX]:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_VBC:TEXT"
							        cTag13IPI  :="oNFe:_DET[nX]:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_VIPI:TEXT"

							        cTag14COF  :="oNFe:_DET[nX]:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_VBC:TEXT"
							        cTag15COF  :="oNFe:_DET[nX]:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_PCOFINS:TEXT"
							        cTag16COF  :="oNFe:_DET[nX]:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_VCOFINS:TEXT"

							        cTag17PIS  :="oNFe:_DET[nX]:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_VBC:TEXT"
							        cTag18PIS  :="oNFe:_DET[nX]:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_PPIS:TEXT"
							        cTag19PIS  :="oNFe:_DET[nX]:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_VPIS:TEXT"
							 
							        cTag20ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCP:TEXT"
                                    cTag21ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCPST:TEXT"
							        cTag22ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PICMS:TEXT"
                                    cTag23ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PICMSST:TEXT"
							        cTag24ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PMVAST:TEXT"
                                    cTag25ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBC:TEXT"
							        cTag26ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCFCP:TEXT"
							        cTag27ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCST:TEXT"
							        cTag28ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCP:TEXT"
							        cTag29ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCPST:TEXT"
                                    cTag30ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VICMS:TEXT"
							        cTag31ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VICMSST:TEXT"
							        cTag34ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCFCPST:TEXT"
							        cTag35ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCPST:TEXT"
							 		cTag36ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCPST:TEXT"

							 		cTag37PIS  :="oNFe:_DET[nX]:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_CST:TEXT"

							 		cTag38COF  :="oNFe:_DET[nX]:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_CST:TEXT"

                             		cTag39ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_ORIG:TEXT"
							 		cTag40ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_CST:TEXT"
							 		cTag41ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCFCP:TEXT"
							 		cTag42ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCP:TEXT"
							 		cTag43ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCP:TEXT"

							 		cTag44IPI  :="oNFe:_DET[nX]:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_CST:TEXT"

							 		cTag45ICM  :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PREDBC:TEXT"

                             		If XmlChildEx(&cCpoICMS ,"_VICMSST") <> Nil
							    		cVrICMSST :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VICMSST:TEXT"
							    		nVrICMSST +=Val(&cVrICMSST)
							 		EndIf
							 		If XmlChildEx(&cCpoICMS ,"_VBCST") <> Nil
                                		cBsICMSST :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCST:TEXT"
                                		nBsICMSST +=Val(&cBsICMSST)
							 		EndIf
							 		If XmlChildEx(&cCpoICMS ,"_PICMS") <> Nil
							    		cPICMS    :="oNFe:_DET[nX]:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PICMS:TEXT"
                                		nPICMS    :=Val(&cPICMS)
							 		EndIf

                             		If XmlChildEx(&cCpoIPI ,"_VBC") <> Nil
							    		cCpoBcIPI :="oNFe:_DET[nX]:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_VBC:TEXT"
                                		nBsIPI    +=Val(&cCpoBcIPI)
							 		EndIf

		                     		aAdd( aItens , { oNFe:_DET[nX]:_NITEM:TEXT	   												                                                               ,; //->> 01 - Item
		                     		UPPER(oNFe:_DET[nX]:_PROD:_CPROD:TEXT)		   	   												                                           ,; //->> 02 - Codigo do Produto no Fornec
		                     		oNFe:_DET[nX]:_PROD:_UCOM:TEXT				   													                                           ,; //->> 03 - Unidade de Medida
		                     		Val(oNFe:_DET[nX]:_PROD:_QCOM:TEXT)			   													                                           ,; //->> 04 - Quantidade
		                     		Val(oNFe:_DET[nX]:_PROD:_VUNCOM:TEXT)															                                           ,; //->> 05 - Valor Unitario
		                     		Val(oNFe:_DET[nX]:_PROD:_VPROD:TEXT)			  												                                           ,; //->> 06 - Valor Total do Total
		                     		oNFe:_DET[nX]:_PROD:_XPROD:TEXT					  												                                           ,; //->> 07 - Descricao do Produto
		                     		oNFe:_DET[nX]:_PROD:_CFOP:TEXT					   												                                           ,; //->> 08 - CFOP
		                     		IIF(XmlChildEx(oNFe:_DET[nX]:_PROD   ,"_VDESC")  <>Nil,Val(oNFe:_DET[nX]:_PROD:_VDESC:TEXT), 0) ,; //->> 09 - Desconto
		                     		IIF(XmlChildEx(oNFe:_DET[nX]:_PROD   ,"_VFRETE") <>Nil,Val(oNFe:_DET[nX]:_PROD:_VFRETE:TEXT), 0),; //->> 10 - Frete
	                         		IIF(XmlChildEx(&cCpoIPI          ,"_PIPI")       <>Nil,Val(&cTag11IPI),0)                       ,; //->> 11 - Percentual IPI                      
	                         		IIF(XmlChildEx(&cCpoIPI          ,"_VBC")        <>Nil,Val(&cTag12IPI),0)                       ,; //->> 12 - Base C�lculo do IPI
	                         		IIF(XmlChildEx(&cCpoIPI          ,"_VIPI")       <>Nil,Val(&cTag13IPI),0)                       ,; //->> 13 - Valor do IPI
	                         		IIF(XmlChildEx(&cCpoCOFINS       ,"_VBC")        <>Nil,Val(&cTag14COF),0)                       ,; //->> 14 - Base C�lculo Cofins
	                         		IIF(XmlChildEx(&cCpoCOFINS       ,"_PCOFINS")    <>Nil,Val(&cTag15COF),0)                       ,; //->> 15 - Percentual Cofins
	                         		IIF(XmlChildEx(&cCpoCOFINS       ,"_VCOFINS")    <>Nil,Val(&cTag16COF),0)                       ,; //->> 16 - Valor do Cofins
	                         		IIF(XmlChildEx(&cCpoPIS          ,"_VBC")        <>Nil,Val(&cTag17PIS),0)                       ,; //->> 17 - Base C�lculo PIS
	                         		IIF(XmlChildEx(&cCpoPIS          ,"_PPIS")       <>Nil,Val(&cTag18PIS),0)                       ,; //->> 18 - Percentual PIS
	                         		IIF(XmlChildEx(&cCpoPIS          ,"_VPIS")       <>Nil,Val(&cTag19PIS),0)                       ,; //->> 19 - Valor do PIS
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_PFCP")       <>Nil,Val(&cTag20ICM),0)                       ,; //->> 20 - Percentual FCP 
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_PFCPST")     <>Nil,Val(&cTag21ICM),0)                       ,; //->> 21 - Percentual FCPST
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_PICMS")      <>Nil,Val(&cTag22ICM),0)                       ,; //->> 22 - Percentual ICMS
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_PICMSST")    <>Nil,Val(&cTag23ICM),0)                       ,; //->> 23 - Percentual ICMS ST
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_PMVAST")     <>Nil,Val(&cTag24ICM),0)                       ,; //->> 24 - Percentual MVA
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VBC")        <>Nil,Val(&cTag25ICM),0)                       ,; //->> 25 - Valor Base 
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VBCFCP")     <>Nil,Val(&cTag26ICM),0)                       ,; //->> 26 - Valor Base FCP
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VBCST")      <>Nil,Val(&cTag27ICM),0)                       ,; //->> 27 - Valor Base CST
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VFCP")       <>Nil,Val(&cTag28ICM),0)                       ,; //->> 28 - Valor FCP
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VFCPST")     <>Nil,Val(&cTag29ICM),0)                       ,; //->> 29 - Valor FCP ST 
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VICMS")      <>Nil,Val(&cTag30ICM),0)                       ,; //->> 30 - Valor ICMS 
	                         		IIF(XmlChildEx(&cCpoICMS         ,"_VICMSST")    <>Nil,Val(&cTag31ICM),0)                       ,; //->> 31 - Valor ICMS ST
		                     		IIF(XmlChildEx(oNFe:_DET[nX]:_PROD   ,"_VSEG")   <>Nil,Val(oNFe:_DET[nX]:_PROD:_VSEG:TEXT), 0)  ,; //->> 32 - Seguro
		                     		IIF(XmlChildEx(oNFe:_DET[nX]:_PROD   ,"_VOUTRO") <>Nil,Val(oNFe:_DET[nX]:_PROD:_VOUTRO:TEXT),0) ,; //->> 33 - Outras Despesas
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_VBCFCPST")   <>Nil,Val(&cTag34ICM),0)                       ,; //->> 34 - BASE FECP ST                                                                                     
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_PFCPST")     <>Nil,Val(&cTag35ICM),0)                       ,; //->> 35 - Aliquota FECP ST
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_VFCPST")     <>Nil,Val(&cTag36ICM),0)                       ,; //->> 36 - Valor FECP ST
		                     		IIF(XmlChildEx(&cCpoPIS          ,"_CST")        <>Nil,AllTrim(&cTag37PIS),'')                  ,; //->> 37 - CST PIS
		                     		IIF(XmlChildEx(&cCpoCOFINS       ,"_CST")        <>Nil,AllTrim(&cTag38COF),'')                  ,; //->> 38 - CST COFINS
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_ORIG")       <>Nil,ALLTRIM(&cTag39ICM),'')                  ,; //->> 39 - Origem
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_CST")        <>Nil,ALLTRIM(&cTag40ICM),'')                  ,; //->> 40 - CST
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_VBCFCP")     <>Nil,Val(&cTag41ICM),0)                       ,; //->> 41 - BASE FECP                                                                                      
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_PFCP")       <>Nil,Val(&cTag42ICM),0)                       ,; //->> 42 - Aliquota FECP 
		                     		IIF(XmlChildEx(&cCpoICMS         ,"_VFCP")       <>Nil,Val(&cTag43ICM),0)                       ,; //->> 43 - Valor FECP
		                     		IIF(XmlChildEx(&cCpoIPI          ,"_CST")        <>Nil,alltrim(&cTag44IPI),"")                  ,; //->> 44 - CST IPI
							 		IIF(XmlChildEx(&cCpoICMS         ,"_PREDBC")     <>Nil,Val(&cTag45ICM),0)})                        //->> 45 - Redu��o Base ICMS
                          	   EndIf                      
					        Next
				        EndIf 
			        Next   
				EndIf 
			Next		
          EndIf
		Next
    Next

Else
	cCFOP := oNFe:_DET:_PROD:_CFOP:TEXT
    nVrMerc +=Val(oNFe:_DET:_PROD:_VPROD:TEXT)		

    SB1->(dbSetOrder(1))
	If! SB1->(dbSeek(xFilial("SB1")+ALLTRIM(UPPER(oNFe:_DET:_PROD:_CPROD:TEXT))))
        nPIPI :=0
        If XmlChildEx(oNFe:_DET:_IMPOSTO:_IPI ,"_IPITRIB") <> Nil
		   If XmlChildEx(oNFe:_DET:_IMPOSTO:_IPI:_IPITRIB ,"_PIPI") <> Nil
              nPIPI:=Val(oNFe:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
           EndIf
		EndIf	
        aProduto:= { {"B1_COD"     ,UPPER(oNFe:_DET:_PROD:_CPROD:TEXT) ,NIL},; 
                     {"B1_DESC"    ,SubStr(ALLTRIM(UPPER(oNFe:_DET:_PROD:_XPROD:TEXT)),1,TamSX3("B1_DESC")[1]) ,NIL},; 
                     {"B1_TIPO"    ,"PA" ,Nil},; 
                     {"B1_UM"      ,ALLTRIM(oNFe:_DET:_PROD:_UCOM:TEXT) ,Nil},; 
                     {"B1_LOCPAD"  ,"01" ,Nil},; 
                     {"B1_PICM"    ,0 ,Nil},; 
                     {"B1_IPI"     ,nPIPI ,Nil},; 
                     {"B1_CONTRAT" ,"N" ,Nil},; 
			         {"B1_CODGTIN" ,ALLTRIM(oNFe:_DET:_PROD:_CEAN:TEXT),Nil},;
                     {"B1_POSIPI"  ,UPPER(oNFe:_DET:_PROD:_NCM:TEXT) ,Nil}}
		
        MSExecAuto({|x,y| Mata010(x,y)},aProduto,3)

	    If lMsErroAuto
           MostraErro()
	        If MsgYesNo("Produto "+ALLTRIM(UPPER(oNFe:_DET:_PROD:_CPROD:TEXT))+" n�o cadastrado. Cancela processo de importa��o?","A t e n � � o")
		          Return(Nil)
		    EndIf
        Endif
    EndIf 

    //------------------------------------------------------------------------
	// Wederson L. Santana 02/04/2020
	// Leitura din�mica dos itens do XML - IMPOSTOS
	//------------------------------------------------------------------------

    For nContCof:=1 To Len(aSitCofins)
        If XmlChildEx(oNFe:_DET:_IMPOSTO:_COFINS,aSitCofins[nContCof]) <> NIL
		   lCOfins     := .T.

           For nContPis:=1 To Len(aSitPIS)
		       If XmlChildEx(oNFe:_DET:_IMPOSTO:_PIS,aSitPIS[nContPis]) <> NIL
                  lPis     := .T.

                  For nContIpi:=1 To Len(aSitIPI)
		              If XmlChildEx(oNFe:_DET:_IMPOSTO:_IPI ,aSitIPI[nContIpi]) <> Nil
			             lIPI := .T.
	
	                     For nContIcm:=1 To Len(aSitICMS) 
                            If XmlChildEx(oNFe:_DET:_IMPOSTO:_ICMS ,aSitICMS[nContICM]) <> Nil
        		                 lICMS := .T.

							     cCpoIPI    :="oNFe:_DET:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]
					    		 cCpoICMS   :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]
					    		 cCpoCOFINS :="oNFe:_DET:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]
						 		cCpoPIS    :="oNFe:_DET:_IMPOSTO:_PIS:"+aSitPIS[nContPis]

	                     		cTag11IPI  :="oNFe:_DET:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_PIPI:TEXT"
						 		cTag12IPI  :="oNFe:_DET:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_VBC:TEXT"
						 		cTag13IPI  :="oNFe:_DET:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_VIPI:TEXT"

						 		cTag14COF  :="oNFe:_DET:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_VBC:TEXT"
						 		cTag15COF  :="oNFe:_DET:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_PCOFINS:TEXT"
						 		cTag16COF  :="oNFe:_DET:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_VCOFINS:TEXT"

						 		cTag17PIS  :="oNFe:_DET:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_VBC:TEXT"
						 		cTag18PIS  :="oNFe:_DET:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_PPIS:TEXT"
						 		cTag19PIS  :="oNFe:_DET:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_VPIS:TEXT"
							 
						 		cTag20ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCP:TEXT"
                         		cTag21ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCPST:TEXT"
						 		cTag22ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PICMS:TEXT"
                         		cTag23ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PICMSST:TEXT"
						 		cTag24ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PMVAST:TEXT"
                         		cTag25ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBC:TEXT"
						 		cTag26ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCFCP:TEXT"
						 		cTag27ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCST:TEXT"
						 		cTag28ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCP:TEXT"
						 		cTag29ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCPST:TEXT"
                         		cTag30ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VICMS:TEXT"
						 		cTag31ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VICMSST:TEXT"
						 		cTag34ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCFCPST:TEXT"
						 		cTag35ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCPST:TEXT"
						 		cTag36ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCPST:TEXT"

						 		cTag37PIS  :="oNFe:_DET:_IMPOSTO:_PIS:"+aSitPIS[nContPis]+":_CST:TEXT"

						 		cTag38COF  :="oNFe:_DET:_IMPOSTO:_COFINS:"+aSitCofins[nContCof]+":_CST:TEXT"

                         		cTag39ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_ORIG:TEXT"
						 		cTag40ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_CST:TEXT"
						 		cTag41ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCFCP:TEXT"
						 		cTag42ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PFCP:TEXT"
						 		cTag43ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VFCP:TEXT"

						 		cTag44IPI  :="oNFe:_DET:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_CST:TEXT"

                         		cTag45ICM  :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PREDBC:TEXT"

                         		If XmlChildEx(&cCpoICMS ,"_VICMSST") <> Nil
						    		cVrICMSST :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VICMSST:TEXT"
						    		nVrICMSST +=Val(&cVrICMSST)
						 		EndIf
						 		If XmlChildEx(&cCpoICMS ,"_VBCST") <> Nil
                            		cBsICMSST :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_VBCST:TEXT"
                            		nBsICMSST +=Val(&cBsICMSST)
					     		EndIf
						 		If XmlChildEx(&cCpoICMS ,"_PICMS") <> Nil
						    		cPICMS    :="oNFe:_DET:_IMPOSTO:_ICMS:"+aSitICMS[nContIcm]+":_PICMS:TEXT"
                            		nPICMS    :=Val(&cPICMS)
						 		EndIf

                         		If XmlChildEx(&cCpoIPI ,"_VBC") <> Nil
									cCpoBcIPI :="oNFe:_DET:_IMPOSTO:_IPI:"+aSitIPI[nContIpi]+":_VBC:TEXT"
                            		nBsIPI    +=Val(&cCpoBcIPI)
						 		EndIf
                         
		                 		aAdd( aItens , { oNFe:_DET:_NITEM:TEXT	   												                                                               ,; //->> 01 - Item
		                     	UPPER(oNFe:_DET:_PROD:_CPROD:TEXT)		   	   												                                           ,; //->> 02 - Codigo do Produto no Fornec
		                     	oNFe:_DET:_PROD:_UCOM:TEXT				   													                                           ,; //->> 03 - Unidade de Medida
		                     	Val(oNFe:_DET:_PROD:_QCOM:TEXT)			   													                                           ,; //->> 04 - Quantidade
		                     	Val(oNFe:_DET:_PROD:_VUNCOM:TEXT)															                                           ,; //->> 05 - Valor Unitario
		                     	Val(oNFe:_DET:_PROD:_VPROD:TEXT)			  												                                           ,; //->> 06 - Valor Total do Total
		                     	oNFe:_DET:_PROD:_XPROD:TEXT					  												                                           ,; //->> 07 - Descricao do Produto
		                     	oNFe:_DET:_PROD:_CFOP:TEXT					   												                                           ,; //->> 08 - CFOP
		                     	IIF(XmlChildEx(oNFe:_DET:_PROD   ,"_VDESC")   <>Nil,Val(oNFe:_DET:_PROD:_VDESC:TEXT), 0)  ,; //->> 09 - Desconto
		                     	IIF(XmlChildEx(oNFe:_DET:_PROD   ,"_VFRETE")  <>Nil,Val(oNFe:_DET:_PROD:_VFRETE:TEXT), 0) ,; //->> 10 - Frete
	                         	IIF(XmlChildEx(&cCpoIPI          ,"_PIPI")    <>Nil,Val(&cTag11IPI),0)                    ,; //->> 11 - Percentual IPI                      
	                         	IIF(XmlChildEx(&cCpoIPI          ,"_VBC")     <>Nil,Val(&cTag12IPI),0)                    ,; //->> 12 - Base C�lculo do IPI
	                         	IIF(XmlChildEx(&cCpoIPI          ,"_VIPI")    <>Nil,Val(&cTag13IPI),0)                    ,; //->> 13 - Valor do IPI
	                         	IIF(XmlChildEx(&cCpoCOFINS       ,"_VBC")     <>Nil,Val(&cTag14COF),0)                    ,; //->> 14 - Base C�lculo Cofins
	                         	IIF(XmlChildEx(&cCpoCOFINS       ,"_PCOFINS") <>Nil,Val(&cTag15COF),0)                    ,; //->> 15 - Percentual Cofins
	                         	IIF(XmlChildEx(&cCpoCOFINS       ,"_VCOFINS") <>Nil,Val(&cTag16COF),0)                    ,; //->> 16 - Valor do Cofins
	                         	IIF(XmlChildEx(&cCpoPIS          ,"_VBC")     <>Nil,Val(&cTag17PIS),0)                    ,; //->> 17 - Base C�lculo PIS
	                         	IIF(XmlChildEx(&cCpoPIS          ,"_PPIS")    <>Nil,Val(&cTag18PIS),0)                    ,; //->> 18 - Percentual PIS
	                         	IIF(XmlChildEx(&cCpoPIS          ,"_VPIS")    <>Nil,Val(&cTag19PIS),0)                    ,; //->> 19 - Valor do PIS
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_PFCP")    <>Nil,Val(&cTag20ICM),0)                    ,; //->> 20 - Percentual FCP 
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_PFCPST")  <>Nil,Val(&cTag21ICM),0)                    ,; //->> 21 - Percentual FCPST
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_PICMS")   <>Nil,Val(&cTag22ICM),0)                    ,; //->> 22 - Percentual ICMS
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_PICMSST") <>Nil,Val(&cTag23ICM),0)                    ,; //->> 23 - Percentual ICMS ST
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_PMVAST")  <>Nil,Val(&cTag24ICM),0)                    ,; //->> 24 - Percentual MVA
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VBC")     <>Nil,Val(&cTag25ICM),0)                    ,; //->> 25 - Valor Base 
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VBCFCP")  <>Nil,Val(&cTag26ICM),0)                    ,; //->> 26 - Valor Base FCP
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VBCST")   <>Nil,Val(&cTag27ICM),0)                    ,; //->> 27 - Valor Base CST
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VFCP")    <>Nil,Val(&cTag28ICM),0)                    ,; //->> 28 - Valor FCP
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VFCPST")  <>Nil,Val(&cTag29ICM),0)                    ,; //->> 29 - Valor FCP ST 
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VICMS")   <>Nil,Val(&cTag30ICM),0)                    ,; //->> 30 - Valor ICMS 
	                         	IIF(XmlChildEx(&cCpoICMS         ,"_VICMSST") <>Nil,Val(&cTag31ICM),0)                    ,; //->> 31 - Valor ICMS ST
		                     	IIF(XmlChildEx(oNFe:_DET:_PROD   ,"_VSEG")    <>Nil,Val(oNFe:_DET:_PROD:_VSEG:TEXT), 0)   ,; //->> 32 - Seguro
		                     	IIF(XmlChildEx(oNFe:_DET:_PROD   ,"_VOUTRO")  <>Nil,Val(oNFe:_DET:_PROD:_VOUTRO:TEXT),0)  ,; //->> 33 - Outras Despesas
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_VBCFCPST")<>Nil,Val(&cTag34ICM),0)                    ,; //->> 34 - BASE FECP ST                                                                                     
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_PFCPST")  <>Nil,Val(&cTag35ICM),0)                    ,; //->> 35 - Aliquota FECP ST
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_VFCPST")  <>Nil,Val(&cTag36ICM),0)                    ,; //->> 36 - Valor FECP ST
		                     	IIF(XmlChildEx(&cCpoPIS          ,"_CST")     <>Nil,AllTrim(&cTag37PIS),'')               ,; //->> 37 - CST PIS
		                     	IIF(XmlChildEx(&cCpoCOFINS       ,"_CST")     <>Nil,AllTrim(&cTag38COF),'')               ,; //->> 38 - CST COFINS
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_ORIG")    <>Nil,ALLTRIM(&cTag39ICM),'')               ,; //->> 39 - Origem
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_CST")     <>Nil,ALLTRIM(&cTag40ICM),'')               ,; //->> 40 - CST
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_VBCFCP")  <>Nil,Val(&cTag41ICM),0)                    ,; //->> 41 - BASE FECP                                                                                      
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_PFCP")    <>Nil,Val(&cTag42ICM),0)                    ,; //->> 42 - Aliquota FECP 
		                     	IIF(XmlChildEx(&cCpoICMS         ,"_VFCP")    <>Nil,Val(&cTag43ICM),0)                    ,; //->> 43 - Valor FECP
		                     	IIF(XmlChildEx(&cCpoIPI          ,"_CST")     <>Nil,alltrim(&cTag44IPI),"")               ,; //->> 44 - CST IPI
							 	IIF(XmlChildEx(&cCpoICMS         ,"_PREDBC")     <>Nil,Val(&cTag45ICM),0)})                  //->> 45 - Redu��o Base ICMS
                          
					    	EndIf                      
						Next
					EndIf 
				Next		
	        EndIf 
		Next   
     EndIf 
  Next

EndIf

If! lICMS     
    If! MsgYesNo("N�o encontrada configura��o para o ICMS."+Chr(10)+Chr(13)+"Deseja continuar?"," A T E N � � O")
        Return(Nil)
    EndIf
EndIf
If! lIPI     
    If! MsgYesNo("N�o encontrada configura��o para o IPI."+Chr(10)+Chr(13)+"Deseja continuar?"," A T E N � � O")
	    Return(Nil)
    EndIf
EndIf
If! lPis     
    If! MsgYesNo("N�o encontrada configura��o para o PIS."+Chr(10)+Chr(13)+"Deseja continuar?"," A T E N � � O")
	    Return(Nil)
    EndIf
EndIf
If! lCofins     
    If! MsgYesNo("N�o encontrada configura��o para o COFINS."+Chr(10)+Chr(13)+"Deseja continuar?"," A T E N � � O")
	    Return(Nil)
    EndIf
EndIf


aAdd(aNF,aItens)														//->> 11 - Itens da Nota Fiscal    
aAdd(aNF,Criavar("D1_TES")) 	   							 		    //->> 12 - TES

If! lFin
    SE4->(dbSetOrder(1))
	If SE4->(dbSeek(xFilial("SE4")+SA1->A1_COND))
       aAdd(aNF,SE4->E4_CODIGO)                                            //->> 13 - COND
	else
	   SE4->(dbGotop())
       aAdd(aNF,SE4->E4_CODIGO)                                            //->> 13 - COND
	EndIf

	SED->(dbSetOrder(1))
	If SED->(dbSeek(xFilial("SED")+SA1->A1_NATUREZ))
       aAdd(aNF,SED->ED_CODIGO) 							                //->> 14 - NATUREZA
	else
      SED->(dbGotop())
	  aAdd(aNF,SED->ED_CODIGO) 							                //->> 14 - NATUREZA
	EndIf	   

    dbSelectArea("SA1")
	dbSetOrder(3)
	If dbSeek(xFilial("SA1")+cCGC)
	   Reclock("SA1",.F.)
       SA1->A1_COND:=SE4->E4_CODIGO                                            //->> 13 - COND
	   SA1->A1_NATUREZ:=SED->ED_CODIGO 							                //->> 14 - NATUREZA
 	   MsUnlock()
	EndIf		   

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

If cTpOper == "E" .And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
	cCFOP := If( Left(cCFOP,1) == "5", "1", "2" ) + Right(cCFOP,3)
EndIf

aAdd(aNF,cCFOP)															//->> 24 - CFOP
aAdd(aNF,oNFe:_IDE:_NATOP:TEXT)											//->> 25 - Natureza de Operacao

//--> Valida a Chave da NFe
aRet := ValNfeSef(oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
aAdd(aNF,aRet[1])														//->> 26 - .T. Chave Valida / .F. Chave Invalida
aAdd(aNF,aRet[2])														//->> 27 - Mensagem da Validacao da Chave da NFe
//aAdd(aNF,.t.)														    //->> 26 - .T. Chave Valida / .F. Chave Invalida
//aAdd(aNF,"validado anteriormente")														//->> 27 - Mensagem da Validacao da Chave da NFe

aAdd(aNF,oNFe:_DEST:_ENDERDEST:_UF:TEXT)								//->> 28 - UF do Destinatario (importante para NF de Importacao)
aAdd(aNF,nVrMerc)								                        //->> 29 - Valor mercadoria

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VICMS")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VICMS:TEXT))					   //->> 30 - Valor ICMS
else
    aAdd(aNF,0)								                           //->> 30 - Valor ICMS
endIf	

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VIPI")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VIPI:TEXT))					   //->> 31 - Valor IPI
else
    aAdd(aNF,0)								                           //->> 31 - Valor IPI
endIf	

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VNF")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VNF:TEXT))					   //->> 32 - Valor BRUTO
else
    aAdd(aNF,0)								                           //->> 32 - Valor BRUTO
endIf	

aAdd(aNF,nBsIPI)    						                           //->> 33 - Base IPI

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VBC")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VBC:TEXT))					   //->> 34 - Base ICMS
else
    aAdd(aNF,0)								                           //->> 34 - Base ICMS
endIf	

aAdd(aNF,nBsICMSST)								                      //->> 35 - Base ICMS Retido
aAdd(aNF,nVrICMSST)								                      //->> 36 - ICMS Retido
aAdd(aNF,oNFe:_EMIT:_ENDEREMIT:_UF:TEXT)							  //->> 37 - UF ORIGEM
aAdd(aNF,oXml:_NFEPROC:_PROTNFE:_INFPROT:_CSTAT:TEXT) 				  //->> 38 - Status

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VFCPST")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VFCPST:TEXT))					  //->> 39 - FECP ST
else
    aAdd(aNF,0)								                          //->> 39 - FECP ST
endIf	

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VPIS")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VPIS:TEXT))					   //->> 40 - Valor PIS
else
    aAdd(aNF,0)								                           //->> 40 - Valor PIS
endIf

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VCOFINS")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VCOFINS:TEXT))				   //->> 41 - Valor COFINS
else
    aAdd(aNF,0)								                           //->> 41 - Valor COFINS
endIf

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VBCST")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VBCST:TEXT))				      //->> 42 - Base ICMS ST
else
    aAdd(aNF,0)								                           //->> 42 - Base ICMS ST
endIf

if XmlChildEx(oNFe:_Total:_ICMSTot,"_VDESC")<>Nil
	aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_VDESC:TEXT))				      //->> 43 - Valor desconto
else
    aAdd(aNF,0)								                           //->> 43 - Valor desconto
endIf

//wederson

aAdd(aDados,aNF)

Return

//-----------------------------------------------------------

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

aNF    := {}
aNFS   := {}

cBox1 := "N=Normal;D=Devolucao;B=Beneficiamento;I=Compl. ICMS;P=Compl. IPI;C=Compl. Pre�o/Frete"

aAdd(aHeaderNF,{ "TipoTES"				,"TPNOTA"	,"@!"							,10				  			,0							,""							   							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ ""						,"ENABLE"	,"@BMP"							,2							,0							,														/*VALIDACAO*/,		,"C",		,"V",	,,,"V"} )
aAdd(aHeaderNF,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "S�rie"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Conta Cont�bil"		,"CONTA"	,"@!"							,Tamsx3("A1_CONTA")		[1]	,0							,"Vazio().or. Ctb105Cta()"	 							/*VALIDACAO*/,""	,"C","CT1"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_UTXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"			   							/*VALIDACAO*/,""	,"C","SE4"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Natureza"				,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')" 							/*VALIDACAO*/,""	,"C","SED"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Fornec. p/ Import."	,"FORNECIMP",PesqPict("SA2","A2_COD")		,Tamsx3("A2_COD")		[1]	,Tamsx3("A2_COD")		[2]	,"Vazio().or.Existcpo('SA2')" 							/*VALIDACAO*/,""	,"C","SA2"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Cliente p/ Export."	,"CLIENTIMP",PesqPict("SA1","A1_COD")		,Tamsx3("A1_COD")		[1]	,Tamsx3("A1_COD")		[2]	,"Vazio().or.Existcpo('SA1')" 							/*VALIDACAO*/,""	,"C","SA1"	,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Tipo Nota"			,"TIPO"		,"@!"							,1							,0							,""                 		 							/*VALIDACAO*/,""	,"C",""		,"R",cBox1	,,,"A"} )
aAdd(aHeaderNF,{ "Vr. Despesas"			,"VLDESP"	,PesqPict("SD1","D1_TOTAL")		,Tamsx3("D1_TOTAL")		[1]	,Tamsx3("D1_TOTAL")		[2]	,""														/*VALIDACAO*/,""	,"N",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Nota Origem"			,"NFORIG"	,PesqPict("SD1","D1_NFORI")		,Tamsx3("D1_NFORI")		[1]	,Tamsx3("D1_NFORI")		[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Serie Origem"			,"SERIORI"	,PesqPict("SD1","D1_SERIORI")	,Tamsx3("D1_SERIORI")	[1]	,Tamsx3("D1_SERIORI")	[2]	,""						   								/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "DIRF - C�d.Reten��o"	,"CODRET"	,PesqPict("SE2","E2_CODRET")	,Tamsx3("E2_CODRET")	[1]	,Tamsx3("E2_CODRET")	[2]	,""						   								/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
aAdd(aHeaderNF,{ "Data da Emiss�o"    	,"DATEMI"	,PesqPict("SF1","F1_EMISSAO")	,Tamsx3("F1_EMISSAO")	[1]	,Tamsx3("F1_EMISSAO")	[2]	,""							 							/*VALIDACAO*/,""	,"C",""		,"R",	,,,"V"} )
aAdd(aHeaderNF,{ "Data da Digita��o"   	,"DATDIG"	,PesqPict("SF1","F1_DTDIGIT")	,Tamsx3("F1_DTDIGIT")	[1]	,Tamsx3("F1_DTDIGIT")	[2]	,""														/*VALIDACAO*/,""	,"C",""		,"R",	,,,"A"} )
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
	                                          //(aNF    ,aLogs   ,nTipo,lChv          ,cMsgChv       ,cUF)
	aAdd(aColsNF,{aNFOrig[nX,01], StatusNFe(@aNFOrig[nX],@aColsLG,1    ,aNFOrig[nX,26],aNFOrig[nX,27],aNFOrig[nX,28])  , aNFOrig[nX,02], aNFOrig[nX,03], aNFOrig[nX,04],IIF(EMPTY(cConta),MV_PAR05,cConta), IIF(EMPTY(aNFOrig[nX,12]),MV_PAR02,aNFOrig[nX,12]), IIF(EMPTY(aNFOrig[nX,13]),MV_PAR03,aNFOrig[nX,13]), IIF(EMPTY(aNFOrig[nX,14]),MV_PAR04,aNFOrig[nX,14]), aNFOrig[nX,15], aNFOrig[nX,16], aNFOrig[nX,17], aNFOrig[nX,18], aNFOrig[nX,19], aNFOrig[nX,20], aNFOrig[nX,21], aNFOrig[nX,05], aNFOrig[nX,23], aNFOrig[nX,24], aNFOrig[nX,25], aNFOrig[nX,22], .F.})
Next nX
SA1->(DbCloseArea())

aAdd(aHeaderNFS,{ "Tipo"				,"TPNOTA"	,"@!"							,10							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ ""					,"ENABLE"	,"@BMP"							,2							,0							,								/*VALIDACAO*/,		,"C",		,"V",		,,,"V"} )
aAdd(aHeaderNFS,{ "Nota Fiscal"	  		,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "S�rie"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "Cliente/Fornec"		,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )
aAdd(aHeaderNFS,{ "TES"					,"TES"		,PesqPict("SD1","D1_TES")		,Tamsx3("D1_TES")		[1]	,Tamsx3("D1_TES")		[2]	,"(Vazio().or.Existcpo('SF4')).AND.U_UTXmlImp(M->TES)"	/*VALIDACAO*/,""	,"C","SF4"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Cond.Pgto"			,"COND"		,PesqPict("SF1","F1_COND")		,Tamsx3("F1_COND")		[1]	,Tamsx3("F1_COND")		[2]	,"Existcpo('SE4')"				/*VALIDACAO*/,""	,"C","SE4"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Natureza"			,"NATUREZA"	,PesqPict("SE2","E2_NATUREZ")	,Tamsx3("E2_NATUREZ")	[1]	,Tamsx3("E2_NATUREZ")	[2]	,"Vazio().or.Existcpo('SED')"	/*VALIDACAO*/,""	,"C","SED"	,"R",,,,"A"} )
aAdd(aHeaderNFS,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )

For nX:= 1 To Len(aNFSOrig)
    //(aNF,aLogs,nTipo,lChv,cMsgChv,cUF)
	aAdd(aColsnfs,{aNFSOrig[nX,01],StatusNFe(@aNFsOrig[nX],@aColsLG,2),aNFSOrig[nX,02],aNFSOrig[nX,03],aNFSOrig[nX,12,11,1],aNFSOrig[nX,20],aNFSOrig[nX,21],aNFSOrig[nX,22],aNFSOrig[nX,24],.F.})
Next nX


//??????????????????????
//? Log de Ocorrencias ?
//??????????????????????
aAdd(aHeaderLG,{ "Nota Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "S�rie"				,"SERIE"	,PesqPict("SF1","F1_SERIE")		,Tamsx3("F1_SERIE")		[1]	,Tamsx3("F1_SERIE")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Fornecedor/Cliente"	,"CLIFOR"	,"@!"							,30							,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLG,{ "Ocorr�ncia"			,"OCORR"	,"@!"							,100              		   	,0               		    ,""								/*VALIDACAO*/,""	,"C",""   	,"R",		,,,"V"} )

//??????????????????????
//? Log de Arquivo     ?
//??????????????????????
aAdd(aHeaderLGX,{ "Tipo Fiscal"			,"NF" 		,PesqPict("SF1","F1_DOC")		,Tamsx3("F1_DOC")		[1]	,Tamsx3("F1_DOC")		[2]	,""								/*VALIDACAO*/,""	,"C",""		,"R",		,,,"V"} )
aAdd(aHeaderLGX,{ "Ocorr�ncia"			,"OCORR"	,"  "							,40               		   	,0               		    ,""								/*VALIDACAO*/,""	,"C",""   	,"R",		,,,"V"} )
aAdd(aHeaderLGX,{ "Arquivo"				,"ARQUIVO"	,"@!"							,100						,0							,""								/*VALIDACAO*/,""	,"C",""		,"R",,,,"V"} )

DEFINE MSDIALOG oDlg TITLE "Classifica��o das notas fiscais" FROM 0,0 To 500,900 PIXEL Style 1 Color CLR_BLACK,CLR_WHITE

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.,.T.)

oFWLayer:addLine("L1",100,.F.)
oFWLayer:AddCollumn("C1"	,100,.T.,"L1")
oFWLayer:AddWindow("C1"		,"oPanel","Classifica��o das Notas Fiscais"	,100,.F.,.T.,,"L1",{ || })
oPanel := oFWLayer:GetWinPanel("C1","oPanel","L1")

oPanel1 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,35,35,.F.,.F. )
oPanel1:Align := CONTROL_ALIGN_TOP

oPanel2 := TPanel():New(0,0,'',oPanel, oDlg:oFont, .T., .T.,,,115,115,.F.,.F. )
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

@ 02,02 TO (oPanel1:NCLIENTHEIGHT/2)-2,(oPanel1:NCLIENTWIDTH/2)-2 OF oPanel1 PIXEL

@ 06,05	Say "Classifique as notas abaixo conforme suas caracteristicas originais."	OF oPanel1 PIXEL
@ 18,05 Say "Obs: Os documentos de entrada sem TES ser�o geradas como Pr�-Notas."	OF oPanel1 PIXEL

@ 06,330 BitMap ResName "ENABLE"   				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 06,342 Say "XML V�lido para Importar"			Size 120,10 OF oPanel1 PIXEL
@ 15,330 BitMap ResName "DISABLE"  				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 15,342 Say "Cliente/Forncedor N�o Cadastrado"	Size 120,10 OF oPanel1 PIXEL
@ 24,330 BitMap ResName "BR_PRETO" 				Size  10,10 OF oPanel1 PIXEL NOBORDER
@ 24,342 Say "XML com Chave/N.Fiscal Inv�lida"	Size 120,10 OF oPanel1 PIXEL

oFolder := TFolder():New(0,0,{ "NF de Produtos","","Log de Ocorr�ncias","Log de Arquivos"},{},oPanel2,,,, .T., .F.,(oPanel2:NCLIENTWIDTH/2)-2,(oPanel2:NCLIENTHEIGHT/2)-2,,.T.)

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
		oRegua:IncRegua2("Gravando Informa��es das notas de produtos...")
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

//-----------------------------------------------------------

Static Function SelTpLanc
*--------------------------------*
Local oDlg                                                                 
Local oRadio

Local bOk     := { || lOk := .T. , oDlg :End() }
Local bCancel := { || lOk := .F. , oDlg :End() }              

Local lOk    := .F.                                                           
Local cTpLanc := Space( 10 )

Local nItem := 2

Define MSDialog oDlg Title "Selecione o tipo de contabiliza��o" From 1,1 To 200,350 Of oMainWnd Pixel

@050,10 Say "Contabiliza" Size 70,10 Of oDlg Pixel
@050,90 COMBOBOX cTpLanc ITEMS { "On-Line" , "Off-Line" }   Size 80,10  Of oDlg Pixel
                                                   
@070,10 Say "Mostra Lcto.?" Size 70,10 Of oDlg Pixel
@070,90 RADIO oRadio VAR nItem SIZE 100,09 PROMPT 'Sim', 'Nao' OF oDlg

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered

If ( lOk  )

	lContOnLine := ( AllTrim( cTpLanc ) == "On-Line" )
	lMostraLanc := ( nItem == 1 ) .And. lContOnLine

EndIf

Return( lOk )

//-------------------------------------------------------------

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

//-----------------------------------------------------------

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

//-----------------------------------------------------------

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

//------------------------------------------------------------

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
		oRegua:IncRegua1("Importa��o de XML de Produto...")
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

//-----------------------------------------------------------

Static Function GeraNFP(aNF,lAuto,lExibErro,oRegua)
Local nX		:= 1
Local aCabec    := {}
Local aItemNF   := {}
Local aItens    := {}
Local lRetorno  := .T.
Local cItem     := "00"
Local dDataEmis := dDatabase
Local dDataAnt	:= dDatabase
Local cEstoque  := ""
Local dDataEmis := aNF[05]
Local dDatabase := aNF[23]
Local cCFOP     := ""
Local nValCont  := 0
Local nValFrete := 0
Local nValSeg   := 0
Local nValIPI   := 0
Local nBaseICMS := 0
Local nBaseIPI  := 0
Local nICMSRet  := 0
Local nValBruto := 0 
Local cLivro    := ""
Local cSitTrib  := ""
Local nDESPESA  := 0  	
Local nBSFCPST  := 0
Local nALFCPST  := 0
Local nVFECPST  := 0
Local nBsICMSRet := 0
Local nBASIMP5  := 0
Local nALQIMP5  := 0
Local nVALIMP5  := 0
Local nBASIMP6  := 0
Local nALQIMP6  := 0
Local nVALIMP6  := 0
Local nVALFECP  := 0

Default lExibErro := .F.

If aNF[1]=="SAIDA"
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
					MsgStop('N�o existe Fornecedor cadastrado com este CNPJ ' + aNF[04])
				EndIf
				If Valtype(oRegua)=="O"
					oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" n�o importada."+" "+"N�o existe Fornecedor cadastrado com este CNPJ")
				EndIf
				Return .F.
			EndIf
		Else
			SA1->(dbSetOrder(3))
			If !SA1->(dbSeek(xFilial("SA1")+aNF[04]))
			    AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"N�o existe Cliente cadastrado com este CNPJ " + aNF[04]+"."})

				If lExibErro
					MsgStop('N�o existe cliente cadastrado com este CNPJ ' + aNF[04])
				EndIf
				If Valtype(oRegua)=="O"
					oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" n�o importada."+" "+"N�o encontrado cliente cadastrado com este CNPJ")
				EndIf
				Return .F.
			EndIf
		EndIf
	Else
		//--> Cliente Exportacao
		SA1->(dbSetOrder(1))
		If !SA1->(dbSeek(xFilial("SA1")+aNF[15]))
			If lExibErro
				MsgStop('Fornecedor n�o Encontrado, Verifique ' + aNF[15])
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" n�o importada."+" "+"Fornecedor N�o Encontrado.")
			EndIf
			Return .F.
		EndIf
	Endif
	
	//-->> Valida existencia do Doc. de Saida
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(xFilial('SF2')+cNumero+PadR(cSerie,3)))
       AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"Documento j� cadastrado."})

		If lExibErro
			Aviso( 'Aten��o' , 'Impossivel importar o Documento, pois o mesmo j� foi cadastrado!' + CRLF + CRLF + ;
			'Cliente:    ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME) + CRLF + ;
			'Doc./Serie: ' + cNumero+' / '+cSerie , { 'Ok' } , 2 , 'Documento j� cadastrado!' )
		EndIf
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" j� cadastrada.")
		EndIf
		Return .F.
	EndIf
	
	//If aNF[11,nX,04] > nSaldo
		//-->> Monta o cabecalho do Doc. de Saida
		aAdd(aCabec,{"F2_TIPO"    ,aNF[17]									  ,Nil})
		aAdd(aCabec,{"F2_DOC"     ,cNumero	   								  ,Nil})
		aAdd(aCabec,{"F2_SERIE"   ,cSerie	  								  ,Nil})
		aAdd(aCabec,{"F2_CLIENTE" ,IIF(aNF[17]=="B",SA2->A2_COD,SA1->A1_COD)  ,Nil})
		aAdd(aCabec,{"F2_LOJA"    ,IIF(aNF[17]=="B",SA2->A2_lOJA,SA1->A1_LOJA),Nil})
		aAdd(aCabec,{"F2_EMISSAO" ,aNF[05]									  ,Nil})
		aAdd(aCabec,{"F2_ESPECIE" ,"SPED"									  ,Nil})
		aAdd(aCabec,{"F2_COND"    ,aNF[13]									  ,Nil})
		aAdd(aCabec,{"F2_FRETE"   ,aNF[06]									  ,Nil})
		aAdd(aCabec,{"F2_DESCONT" ,aNF[07]									  ,Nil})
		aAdd(aCabec,{"F2_SEGURO"  ,0			 							  ,Nil})
		aAdd(aCabec,{"F2_DESPESA" ,aNF[18]		   							  ,Nil})
		aAdd(aCabec,{"F2_VEND1"   ,""		   							      ,Nil})
		aAdd(aCabec,{"F2_EST"     ,aNF[28]	   							      ,Nil})
		aAdd(aCabec,{"F2_VALMERC" ,aNF[29]	   							      ,Nil})
		aAdd(aCabec,{"F2_VALICM"  ,aNF[30]		   							  ,Nil})
		aAdd(aCabec,{"F2_VALIPI"  ,aNF[31]		   							  ,Nil})
		aAdd(aCabec,{"F2_VALBRUT" ,aNF[32]		   							  ,Nil})
		aAdd(aCabec,{"F2_BASEIPI" ,aNF[33]	   							      ,Nil})
		aAdd(aCabec,{"F2_BASEICM" ,aNF[34]		   							  ,Nil})
		aAdd(aCabec,{"F2_BRICMS"  ,aNF[42]		   							  ,Nil})
		aAdd(aCabec,{"F2_ICMSRET" ,aNF[36]	   							      ,Nil})
        aAdd(aCabec,{"F2_UFORIG"  ,aNF[37]	   							      ,Nil})
        aAdd(aCabec,{"F2_UFDEST"  ,aNF[28]	   							      ,Nil})
        aAdd(aCabec,{"F2_BSFCPST" ,aNF[39]	   							      ,Nil})
		//PIS
		aAdd(aCabec,{"F2_VALIMP5" ,aNF[40]		   							  ,Nil})
        //COFINS
		aAdd(aCabec,{"F2_VALIMP6" ,aNF[41]		   							  ,Nil})	
		//Base FECP
		aAdd(aCabec,{"F2_BASFECP" ,aNF[34]		   							  ,Nil})
		//Valor desconto
		aAdd(aCabec,{"F2_DESCONT" ,aNF[43]		   							  ,Nil})		

	//wederson	
	//EndIf	
		
	   dbSelectArea("SB1")	
	   dbSetOrder(1)
	   For nX := 1 To Len(aNF[11])
		
		   cCFOP := AllTrim(aNF[11,nX,08])
		   Do Case
		      Case Alltrim(cCFOP) $ '5101/6101'  
		           cTpTes:="7X4"
              Case Alltrim(cCFOP) $ '5102/6102' 
		           cTpTes:="7X5"
		      Case Alltrim(cCFOP) $ '5401/6401'  
		           cTpTes:="7WH"
		      Case Alltrim(cCFOP) $ '5901/6901'   
		           cTpTes:="7XB"
		      Case Alltrim(cCFOP) $ '5905'   
		           cTpTes:="51H"
		      Case Alltrim(cCFOP) $ '5910/6910'   
		           cTpTes:="7P2"
		      Case Alltrim(cCFOP) $ '5917/6917'   
		           cTpTes:="7Y5"
		      Case Alltrim(cCFOP) $ '5949/6949'   
		           cTpTes:="7X7"
		      Case Alltrim(cCFOP) $ '5105/6105'   
		           cTpTes:="7Y1"
		      Case Alltrim(cCFOP) $ '5113/6113'   
		           cTpTes:="7YT"
		      Case Alltrim(cCFOP) $ '6107'   
		           cTpTes:="7X4"
		      Case Alltrim(cCFOP) $ '6108'   
		           cTpTes:="7X5"
		      Case Alltrim(cCFOP) $ '5201/6201'   
		           cTpTes:="7BW"
		      Case Alltrim(cCFOP) $ '6404'   
		           cTpTes:="7Y4"
		      Case Alltrim(cCFOP) $ '7101'   
		           cTpTes:="8A5"	   
			  Case Alltrim(cCFOP) $ '7949'   
		           cTpTes:="8A8"	  
			  Case Alltrim(cCFOP) $ '6905'   
		           cTpTes:="8AI"	 
		    End Case
		
		    dbSelectArea("SF4")
            dbSetOrder(1)			
		    If dbSeek(xFilial("SF4")+cTpTes)
		       cTES := cTpTes
		    Else
               MsgInfo("TES ("+cTpTes+") CFOP ("+cCFOP+") n�o encontrada.","A T E N � � O")
		    EndIf	   
		
		    dbSelectArea("SB1")
		    If dbSeek(xFilial("SB1")+aNF[11,nX,02])
		       Reclock("SB1",.F.)
		       SB1->B1_TS := cTES
		       MsUnlock()
            EndIf
		
		    aItens := {}
		    cItem := Soma1(cItem)

		    //Valor Bruto
			
		    nValBruto := If(aNF[11,nX,06]>0,aNF[11,nX,06],0)
		    //If SubStr(cCFOP,2,3) == "105".Or. SubStr(cCFOP,2,3) == "401"
		                //Outras Despesas + IPI + ST + ST FECP
            nValBruto += (If(aNF[11,nX,33]>0,aNF[11,nX,33],0)+If(aNF[11,nX,36]>0,aNF[11,nX,36],0)+If(aNF[11,nX,13]>0,aNF[11,nX,13],0)+If(aNF[11,nX,31]>0,aNF[11,nX,31],0))
		    //EndIf
		    If aNF[11,nX,09]>0
               nValBruto -= aNF[11,nX,09]
		    EndIf   

			//-->> Monta o array com os itens do Doc. de Saida
			aAdd( aItens , {"D2_DOC"      ,cNumero					                            ,Nil} ) //1
			aAdd( aItens , {"D2_SERIE"    ,cSerie		    			                        ,Nil} ) //2
			aAdd( aItens , {"D2_CLIENTE"  ,IIF(aNF[17]=="B",SA2->A2_COD,SA1->A1_COD)	        ,Nil} ) //3
			aAdd( aItens , {"D2_LOJA"     ,IIF(aNF[17]=="B",SA2->A2_LOJA,SA1->A1_LOJA)	        ,Nil} ) //4
			aAdd( aItens , {"D2_TIPO"     ,aNF[17]	                                            ,Nil} ) //5
			aAdd( aItens , {"D2_EMISSAO"  ,aNF[05]	                                            ,Nil} ) //6
			aAdd( aItens , {"D2_EST"      ,aNF[28]                                              ,Nil} ) //7
			aAdd( aItens,  {"D2_ITEM"    ,cItem                                  				,Nil} ) //8
			aAdd( aItens , {"D2_COD"     ,SB1->B1_COD											,Nil} ) //9
			aAdd( aItens , {"D2_UM"      ,SB1->B1_UM											,Nil} ) //10
			aAdd( aItens , {"D2_GRUPO"   ,SB1->B1_GRUPO											,Nil} ) //11
			aAdd( aItens , {"D2_TP"      ,SB1->B1_TIPO											,Nil} ) //12
			aAdd( aItens , {"D2_LOCAL"   ,SB1->B1_LOCPAD	   								    ,Nil} ) //13
			aAdd( aItens , {"D2_QUANT"   ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)					,Nil} ) //14
			aAdd( aItens , {"D2_PRCVEN"  ,If(aNF[11,nX,05]>0,aNF[11,nX,05],1)					,Nil} ) //15
			aAdd( aItens , {"D2_TOTAL"   ,aNF[11,nX,06]									  		,Nil} ) //16
			aAdd( aItens , {"D2_TES"     ,cTES													,Nil} ) //17
			aAdd( aItens , {"D2_VALFRE"  ,If(aNF[11,nX,10]>0,aNF[11,nX,10],0)					,Nil} ) //18
			aAdd( aItens , {"D2_DESCON"  ,If(aNF[11,nX,09]>0,aNF[11,nX,09],0)					,Nil} ) //19
            aAdd( aItens , {"D2_VALBRUT"  ,nValBruto	                            			,Nil} ) //20
			aAdd( aItens , {"D2_BASEIPI"  ,If(aNF[11,nX,12]>0,aNF[11,nX,12],0)					,Nil} ) //21
			aAdd( aItens , {"D2_IPI"      ,If(aNF[11,nX,11]>0,aNF[11,nX,11],0)					,Nil} ) //22
			aAdd( aItens , {"D2_VALIPI"   ,If(aNF[11,nX,13]>0,aNF[11,nX,13],0)					,Nil} ) //23
			aAdd( aItens , {"D2_BASECOF"  ,If(aNF[11,nX,14]>0,aNF[11,nX,14],0)					,Nil} ) //24
			aAdd( aItens , {"D2_ALQCOF"   ,If(aNF[11,nX,15]>0,aNF[11,nX,15],0)					,Nil} ) //25
			aAdd( aItens , {"D2_VALCOF"   ,If(aNF[11,nX,16]>0,aNF[11,nX,16],0)					,Nil} ) //26
		    aAdd( aItens , {"D2_BASEICM"  ,If(aNF[11,nX,25]>0,aNF[11,nX,25],0)					,Nil} ) //27
			aAdd( aItens , {"D2_VALICM"  ,If(aNF[11,nX,30]>0,aNF[11,nX,30],0)					,Nil} ) //28
	        aAdd( aItens , {"D2_CF"      ,AllTrim(aNF[11,nX,08])     					        ,Nil} ) //29
			aAdd( aItens , {"D2_PICM"    ,If(aNF[11,nX,22]>0,aNF[11,nX,22],0)					,Nil} ) //30
			aAdd( aItens , {"D2_BASEPIS"  ,If(aNF[11,nX,17]>0,aNF[11,nX,17],0)					,Nil} ) //31
	        aAdd( aItens , {"D2_ALQPIS"   ,If(aNF[11,nX,18]>0,aNF[11,nX,18],0)					,Nil} ) //32
	        aAdd( aItens , {"D2_VALPIS"   ,If(aNF[11,nX,19]>0,aNF[11,nX,19],0)					,Nil} ) //33
	        aAdd( aItens , {"D2_ORIGLAN"  ,"HB"					                                ,Nil} ) 
			aAdd( aItens , {"D2_ICMSRET"  ,If(aNF[11,nX,31]>0,aNF[11,nX,31],0)					,Nil} ) //34
			aAdd( aItens , {"D2_SEGURO"   ,If(aNF[11,nX,32]>0,aNF[11,nX,32],0)					,Nil} ) //35
			aAdd( aItens , {"D2_CLASFIS"  ,Alltrim(aNF[11,nX,39])+Alltrim(aNF[11,nX,40])	    ,Nil} ) //36	
			aAdd( aItens , {"D2_ESTOQUE"  ,SF4->F4_ESTOQUE 			                            ,Nil} ) //37
			aAdd( aItens , {"D2_DESPESA"  ,If(aNF[11,nX,33]>0,aNF[11,nX,33],0)					,Nil} ) //38	
			
			//FECP ST
			aAdd( aItens , {"D2_BSFCPST",If(aNF[11,nX,34]>0,aNF[11,nX,34],0)					,Nil} ) //39	
			aAdd( aItens , {"D2_ALFCPST",If(aNF[11,nX,35]>0,aNF[11,nX,35],0)					,Nil} ) //40	
			aAdd( aItens , {"D2_VFECPST",If(aNF[11,nX,36]>0,aNF[11,nX,36],0)					,Nil} ) //41	

			//PIS
            aAdd( aItens , {"D2_BASIMP5",If(aNF[11,nX,17]>0,aNF[11,nX,17],0)					,Nil} ) //42	
			aAdd( aItens , {"D2_ALQIMP5",If(aNF[11,nX,18]>0,aNF[11,nX,18],0)					,Nil} ) //43	
			aAdd( aItens , {"D2_VALIMP5",If(aNF[11,nX,19]>0,aNF[11,nX,19],0)					,Nil} ) //44	
			
			//COFINS
            aAdd( aItens , {"D2_BASIMP6",If(aNF[11,nX,14]>0,aNF[11,nX,14],0)					,Nil} ) //45	
			aAdd( aItens , {"D2_ALQIMP6",If(aNF[11,nX,15]>0,aNF[11,nX,15],0)					,Nil} ) //46	
			aAdd( aItens , {"D2_VALIMP6",If(aNF[11,nX,16]>0,aNF[11,nX,16],0)					,Nil} ) //47	

			aAdd( aItens , {"D2_BRICMS",If(aNF[11,nX,27]>0,aNF[11,nX,27],0)					    ,Nil} ) //48
			aAdd( aItens , {"D2_ALIQSOL",If(aNF[11,nX,23]>0,aNF[11,nX,23],0)				    ,Nil} ) //49

		    aAdd( aItens , {"D2_BASFECP",If(aNF[11,nX,41]>0,aNF[11,nX,41],0)				    ,Nil} ) //50
            aAdd( aItens , {"D2_ALQFECP",If(aNF[11,nX,42]>0,aNF[11,nX,42],0)				    ,Nil} ) //51
            aAdd( aItens , {"D2_VALFECP",If(aNF[11,nX,43]>0,aNF[11,nX,43],0)				    ,Nil} ) //52

			aAdd( aItemNF, aItens )
         
		    aaDD(aSFT,{ cNumero,;
			            cSerie,;
						SA1->A1_COD,;
						SA1->A1_LOJA,;
						aNF[17],;
						aNF[05],;
						aNF[28],;
						cItem,;
						SB1->B1_COD,;
						SB1->B1_UM,;
						SB1->B1_GRUPO,;
						SB1->B1_TIPO,;
						SB1->B1_LOCPAD,;
						aNF[11,nX,04],;
					    aNF[11,nX,05],;
					    aNF[11,nX,06],; //16
					    cTes,;
					    aNF[11,nX,10],;
					    aNF[11,nX,09],;
					    nValBruto,;
					    aNF[11,nX,12],;
					    aNF[11,nX,11],;
					    aNF[11,nX,13],; //23
					    aNF[11,nX,14],;
					    aNF[11,nX,15],;
					    aNF[11,nX,16],;
					    aNF[11,nX,25],; //27
					    aNF[11,nX,30],;
					    AllTrim(aNF[11,nX,08]),;
					    aNF[11,nX,22],;
					    aNF[11,nX,17],;
					    aNF[11,nX,18],;
					    aNF[11,nX,19],;
					    aNF[11,nX,31],; //34
					    aNF[11,nX,32],;
					    Alltrim(aNF[11,nX,39])+Alltrim(aNF[11,nX,40]),;
					    SF4->F4_ESTOQUE,;
					    SB1->B1_POSIPI,;
					    aNF[10],;
					    aNF[11,nX,33],;   //40
					    aNF[11,nX,34],;
					    aNF[11,nX,35],;
					    aNF[11,nX,36],;   //43
						aNF[11,nX,37],;   //44 CST - PIS
						aNF[11,nX,38],;   //45  CST - COFINS
						aNF[11,nX,27],;   //46 Base ICMS RET
						aNF[11,nX,23],;   //47 % ICMS RET
						aNF[11,nX,41],;   //48 Base FECP
						aNF[11,nX,42],;   //49 % FECP
						aNF[11,nX,43],;  //50 Vr FECP
						aNF[11,nX,09],;  //51 vR DESCONTO
						aNF[11,nX,44],;  //52 cst IPI
						aNF[11,nX,45] })  //53 Redu��o Base ICMS   
						
	    Next nX                  

        //WEDERSON
        ASORT(aSFT,,, { |x, y| x[29] > y[29] } )
        nX :=1
        While nX <= Len(aSFT)
              cCFOP      := aSFT[nX][29]
		      nICMSTRIB  := 0
              nICMSISEN  := 0
              nICMSOUT   := 0
              nICMSOBS   := 0
              nIPITRIB   := 0
              nIPIISEN   := 0
              nIPIOUT    := 0
              nIPIOBS    := 0
		      nValCont   := 0
   	          nValFrete  := 0
		      nValSeg    := 0
	          nValIPI    := 0
              nBaseICMS  := 0
              nBaseIPI   := 0
              nICMSRet   := 0
		      nDESPESA   := 0  	
              nBSFCPST   := 0
              nVFECPST   := 0
		      nBsICMSRet := 0
              nBASIMP5   := 0
              nALQIMP5   := 0
              nVALIMP5   := 0
              nBASIMP6   := 0
              nALQIMP6   := 0
              nNVALIMP6  := 0
              nVALFECP   := 0
		      nTotMerc   := 0
		      nVrDesc    := 0            
             
              While cCFOP == aSFT[nX][29].And. nX <= Len(aSFT)

                    dbSelectArea("SF4")
                    dbSetOrder(1)			
		            If dbSeek(xFilial("SF4")+AllTrim(aSFT[nX][17]))
	                   Do CASE
 		                  CASE SF4->F4_LFICM == "T"
				          nICMSTRIB += aSFT[nX][28]
                          CASE SF4->F4_LFICM == "I"
			              nICMSISEN += aSFT[nX][28]
			              CASE SF4->F4_LFICM == "O"
			              nICMSOUT += aSFT[nX][28]
					      CASE SF4->F4_LFICM == "B"	
					      nICMSOBS += aSFT[nX][28]
		               EndCASE

                       Do CASE
 		                  CASE SF4->F4_LFIPI == "T"
				          nIPITRIB += aSFT[nX][23]
                          CASE SF4->F4_LFIPI == "I"
			              nIPIISEN += aSFT[nX][23]
			              CASE SF4->F4_LFIPI == "O"
			              nIPIOUT += aSFT[nX][23]
					      CASE SF4->F4_LFIPI == "P"
			              nIPIOBS += aSFT[nX][23]	  
		               EndCASE
				       cLivro := SF4->F4_NRLIVRO
		            EndIf
					
				    nValCont += aSFT[nX][16]
				    nValCont += (aSFT[nX][40] + aSFT[nX][43] + aSFT[nX][23] + aSFT[nX][34])
                    nValCont -= aSFT[nX][19]
                   
				    nValFrete += aSFT[nX][18]
			        nValSeg   += aSFT[nX][35]
			        nBaseICMS += aSFT[nX][27]
                    nBaseIPI  += aSFT[nX][21]
                    nICMSRet  += aSFT[nX][34]
                    nDESPESA  += aSFT[nX][40]  	
                    nBSFCPST  += aSFT[nX][41]
                    nVFECPST  += aSFT[nX][43]
			        nBsICMSRet += aSFT[nX][46]
                    nBASIMP5   += aSFT[nX][31]
                    nALQIMP5   := aSFT[nX][32]
                    nVALIMP5   += aSFT[nX][33]
                    nBASIMP6   += aSFT[nX][24]
                    nALQIMP6   := aSFT[nX][25]
                    nNVALIMP6  += aSFT[nX][26]
			        nVALFECP   += aSFT[nX][50]
			        nTotMerc   += aSFT[nX][16]
			        nVrDesc    += aSFT[nX][51]

			        nX ++
	   		        If nX > Len(aSFT)
		               Exit
		            EndIf
		      End
		         
		      nX --
		      aaDD(aSF3,{aSFT[nX][01],;
		      aSFT[nX][02],;
		      aSFT[nX][03],;
		      aSFT[nX][04],;
		      aSFT[nX][05],;
		      aSFT[nX][06],;
		      aSFT[nX][07],;
		      cLivro,;
		      aNF[10],;
		      aNF[38],;
		      aSFT[nX][22],;
		 	  0,;
			  0,;                      
			  0,;
			  0,;
			  0,;
			  0,;
			  (nValFrete+nValSeg),;
			  nIPIOBS,;
			  nValCont,;
			  nBaseIPI,;
			  nIPIOUT,;
			  nIPITRIB,;
			  nICMSOBS,;
			  nICMSOUT,;
			  nICMSISEN,;
			  nBaseICMS,; //27
			  nICMSTRIB,;
			  aSFT[nX][29],;          //F3_CFO     - D2_CF       --29
			  aSFT[nX][30],;
			  0,;
			  nIPIISEN,;
			  0,;
			  nICMSRet,;
			  nDESPESA,;  //35
			  nBSFCPST,;
			  nVFECPST,;
			  nBsICMSRet,;
			  nBASIMP5  ,;
              nALQIMP5  ,;
              nVALIMP5  ,;
              nBASIMP6  ,;
              nALQIMP6  ,;
              nNVALIMP6 ,;
			  aSFT[nX][47],;//45
			  nVALFECP,; //46
			  nTotMerc,; //47
			  nVrDesc ,; //48
			  aSFT[nX][53]}) //49

		      nX ++
		      If nX > Len(aSFT)
		         Exit
		      EndIf
       End
    
	   If! Empty(cTES)
	
		  MsExecAuto( {|x,y,z| U_UTFIS001(x,y,z)}, aCabec, aItemNF , 3 )
		
		  If lMsErroAuto
		     DisarmTransaction()
			 If lExibErro
				MostraErro()
			 EndIf
			 lRetorno := .F.
		  Else
		 	 nProd++
			 lRetorno := .T.
		     GeraTitulo(cTes,aNF[09],aNF[13],cNumero,cSerie,aNF[14],SA1->(A1_COD+A1_LOJA))
			
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
					If cEstoque == "S"
					   RecLock("SD2",.F.)
					   SD2->D2_ORIGLAN := 'HB'
					   SD2->D2_CUSTO1  := Posicione("SB2",1,xFilial("SB2")+SD2->D2_COD,"B2_CM1") * SD2->D2_QUANT
					   SD2->(MsUnLock())
					EndIf
					
					/*
						Contabilizacao On Line - Itens da nota de Saida
					*/                                               
					If lContOnLine .And. lLancPad10                                            
				   		nTotal += DetProva( nHdlPrv , "610" , _cFuncao , cLoteFat )
					EndIf					
	
					If Posicione("SF4",1,xFilial("SF4")+cTes,"F4_PODER3")<>"N"
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
					If F3_CFO ==  Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")
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
			
			 SA1->(dbCloseArea())
			 SE1->(dbCloseArea())
			 SF2->(dbCloseArea())
			 SD2->(dbCloseArea())
			
		 Endif
	 Else
		MsgInfo("N�o encontrada TES  ("+cTES+") para o documento "+cNumero+" s�rie "+cSerie+" com CFOP ("+cCFOP+") .","A t e n � � o")
		Return(Nil) 
	 EndIf
	//Else
	//	MsgInfo("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+". Saldo dispon�vel insuficiente. "+Transform(nSaldo,"@E 999999,999"),"A t e n � � o")
	//	Return(Nil)
	//EndIf		
EndIf

dDatabase := dDataAnt

Return(lRetorno)

//------------------------------------------------------------

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

        SE1->(dbSetOrder(1))
		If! SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNumero))
		    MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao
        EndIf

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

//------------------------------------------------------------

Static Function fCriaPerg(_cPerg)
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}

AADD(aRegistros,{_cPerg,"01","Pasta Origem dos XML Prod/Serv      ?","","","mv_ch1","C",99,00,00,"G",""                          ,"Mv_Par01","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"02","TES                                 ?","","","mv_ch2","C",03,00,00,"G","Vazio().or.Existcpo('SF4')","Mv_Par02","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SF4","","","","",""})
AADD(aRegistros,{_cPerg,"03","Condi��o Pagamento                  ?","","","mv_ch3","C",03,00,00,"G","Existcpo('SE4')"           ,"Mv_Par03","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SE4","","","","",""})
AADD(aRegistros,{_cPerg,"04","Natureza                            ?","","","mv_ch4","C",10,00,00,"G","Vazio().or.Existcpo('SED')","Mv_Par04","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","SED","","","","",""})
AADD(aRegistros,{_cPerg,"05","Conta Cont�bil                      ?","","","mv_ch5","C",20,00,00,"G","Vazio().or. Ctb105Cta()"   ,"Mv_Par05","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","CT1","","","","",""})

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

//-----------------------------------------------------------

 Static Function VldTES(cTes,lMsg)
*--------------------------------*

Local lRet 		:= .T. 

ChkFile("SF4")
SF4->(DbSetOrder(1))
If SF4->(DbSeek(xFilial("SF4")+cTes))
	If SF4->F4_ESTOQUE == "S"         
 		lVldTes := .T.
 	Else                
 		lVldTes := .F.	
 	EndIf
EndIf

Return lRet


//-----------------------------------------------------------

Static Function StatusNFe(aNF,aLogs,nTipo,lChv,cMsgChv,cUF)
Local oCor
Local aRet      := {}
Local nX
Default lChv    := .T.
Default cMsgChv := ""
Default cUF     := ""

If nTipo == 1
	If !lChv
	    oCor := LoadBitmap( GetResources(), "ENABLE" )
		
		//--> Chave Invalida
		//oCor := LoadBitmap( GetResources(), "BR_PRETO" )
		//aAdd( aLogs , { aNF[2], aNF[3], aNF[4], cMsgChv, .F. })
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
					If ! SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
						oCor := LoadBitmap( GetResources(), "BR_PRETO" )
						aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Produto Nao Cadastrado", .F. })
					EndIf
				NEXT

				For nX := 1 To Len(aNF[11])
					//Wederson MV_ESTNEG
					SB1->(dbSeek(xFilial("SB1")+PadR(aNF[11,nX,02],Len(SB1->B1_COD)) ))
	                nSaldo:=0
				    SB2->(dbSetOrder(1))
	                If SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
	                   nSaldo := (SB2->B2_QATU - SB2->B2_RESERVA-SB2->B2_QEMP - SB2->B2_QACLASS - SB2->B2_QEMPSA - SB2->B2_QEMPPRJ - SB2->B2_QTNP - SB2->B2_QEMPPRE - SB2->B2_QEMPSA)//+SB2->B2_QNTP 
	                EndIf
					
	                If aNF[11,nX,04] > nSaldo.And.cEstNeg == "N"
                       oCor := LoadBitmap( GetResources(), "BR_PRETO" )
					   aAdd( aLogs , { aNF[2], aNF[3], aNF[4], "Saldo insuficiente."+Transform(nSaldo,"@E 999999,999"), .F. })
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
					cMsgErro := "A chave digitada n�o foi encontrada na Sefaz, favor verificar"
					AAdd(aLogErro , {cDirXmlUT+cArqXmlUT,cNumNF+" "+cSerieNF,"A chave digitada n�o foi encontrada na Sefaz, favor verificar."})
					//If lMsg
					//	MsgAlert("A chave digitada n�o foi encontrada na Sefaz, favor verificar")
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
							If lCanc 
						       lRet := .T.
						    Else
							   lRet := .F.	
						    EndIf
						EndIf
					Else
					    If lCanc 
						    lRet := .T.
						Else
							lRet := .F.	
						EndIf	
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
					cMsgErro := "A chave informada � menor que o permitido e impossibilita a consulta na Sefaz."
					If lMsg
						If MsgNoYes("A chave informada � menor que o permitido e impossibilita a consulta na Sefaz."+CRLF+CRLF+"Deseja APAGAR o conte�do do campo para inserir uma nova chave?")
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

//-----------------------------------------------------

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

//-----------------------------------------------------

Static Function UTLAICMS(oDlg,aPos,aHeadCDA,aColsCDA,lVisual,lInclui)
Local	oLancApICMS
Local	bCond		:=	{||.T.}
Local	bSkip		:=	{|| CDA->CDA_TPREG == "NA" }
Local	cVisual		:=	Iif(lVisual,"'1'","'2'")

aMHead("CDA","CDA_TPMOVI/CDA_ESPECI/CDA_FORMUL/CDA_NUMERO/CDA_SERIE/CDA_CLIFOR/CDA_LOJA/",@aHeadCDA)
If lVisual
	dbSelectArea("CDA")
	CDA->(dbSetOrder(1))
	CDA->(MsSeek(xFilial("CDA")+"S"+c920Especi+"S"+c920Nota+c920Serie+c920Client+c920Loja))
	bCond	:=	{||xFilial("CDA")+"S"+c920Especi+"S"+c920Nota+c920Serie+c920Client+c920Loja==CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA)}
EndIf
aMAcols(lVisual,"CDA",@aColsCDA,aHeadCDA,bCond,bSkip)

oLancApICMS	:=	MsNewGetDados():New(aPos[1],aPos[2],aPos[4],aPos[3],Iif(lVisual,0,GD_UPDATE+GD_INSERT+GD_DELETE),"UTLOk","UTLOk","+CDA_SEQ",{"CDA_NUMITE","CDA_CODLAN","CDA_BASE","CDA_ALIQ","CDA_VALOR","CDA_IFCOMP"},/*freeze*/,990,/*fieldok*/,/*superdel*/,"LDel("+cVisual+")",oDlg,@aHeadCDA,@aColsCDA)

Return oLancApICMS

//--------------------------------------------------------

Static Function aMHead(cAlias,cNCmps,aH)
Local	lRet	:=	.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !Eof() .And. (X3_ARQUIVO==cAlias)
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO)+"/"$cNCmps)
		AADD(aH,{ Trim(X3Titulo()), ;
			AllTrim(X3_CAMPO),;
			X3_PICTURE,;
			X3_TAMANHO,;
			X3_DECIMAL,;
			Iif(AllTrim(X3_CAMPO)=="CDA_NUMITE","UTLCpIt().And.","")+"UTLCps()",;
			X3_USADO,;
			X3_TIPO,;
			X3_F3,;
			X3_CONTEXT,;
			X3_CBOX,;
			X3_RELACAO})
	Endif
	dbSkip()
Enddo
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³aMAcols   ³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem do ACOLS do GETDADOS                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc -> Opcao do AROTINA                                    ³±±
±±³          ³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³aC -> array no qual o ACOLS serah montado                   ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±³          ³bCond -> Condicao de loop do while                          ³±±
±±³          ³bSkip -> Condicao para ignorar um registro isolado          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aMAcols(lVisual,cAlias,aC,aH,bCond,bSkip)
Local	lRet	:=	.T.
Local	nI		:=	0

DEFAULT bSkip 	:= {|| .F. }

dbSelectArea(cAlias)
dbSetOrder(1)
If lVisual 
	If !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o array aCols com os itens                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aC	:=	{}
		While !Eof() .And. Eval(bCond)
			IF Eval(bSkip)
				dbSkip()
				Loop
			EndIf
			aAdd(aC,Array(Len(aH)+1))
			For nI := 1 To Len(aH)
				aC[Len(aC),nI] := FieldGet(FieldPos(aH[nI,2]))
			Next
			aC[Len(aC),Len(aH)+1] := .F.
			dbSkip()
		End	
	ElseIf  Len(aColsD2)>1
		For nI := 1 To Len(aColsD2)
			
		Next nI
	EndIf
Else
	aC				:=	{Array(Len(aH)+1)}
	aC[1,Len(aH)+1]	:=	.F.
	For nI := 1 To Len(aH)
		If aH[nI,10]#"V"
			aC[1,nI]	:=	CriaVar(aH[nI,2])
		EndIf

		If "_SEQ"$aH[nI,2]
			aC[1,nI]	:=	StrZero(1,aH[nI,4])
		EndIf
	Next	
EndIf
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a920LDel  ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar a delecao do lancamento fiscal do docu- ³±±
±±³          ³ mento criado pelo sistema.                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVisual -> indica se a nota esta sendo visualizada. 1=Sim,  ³±±
±±³          ³ 2=Nao                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTLDel(cVisual)
Local	lRet	:=	.T.
Local	nPosCalc:=	0
Local	nPosIt	:=	0
Local 	nPosItD2:= 	0
Local	nPos	:=	0

If Type("oLancApICMS")=="O" .And. cVisual=="2"
	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
	nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
	
	If nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="1"
		//Registros calculados pelo sistema não poderão ser excluídos, pois serão utilizados como log da rotina.
		//Caso seja necessário alterar este cálculo, basta inserir novos itens nesta opção de ajuste ou utitlizar a funcionalidade de Gerenciamento dos Lançamentos Fiscais de ICMS. Vale ressaltar que na Apuração de ICMS será considerada a sequência maior de cada lançamento fiscal do documento.
		Help("  ",1,"LAICMSDEL1")	
		lRet	:=	.F.
	
	ElseIf nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="2" .And. Type("aColsD2")=="A" .And. Type("aHeadD2")="A"
		nPosItD2:= 	aScan(aHeadD2,{|aX| aX[2]==PadR("D2_ITEM",Len(SX3->X3_CAMPO))})

		If nPosItD2>0 .And. nPosIt>0
			nPos	:=	aScan(aColsD2,{|aX|PadR(aX[nPosItD2],TamSx3("CDA_NUMITE")[1])==oLancApICMS:aCols[oLancApICMS:nAT,nPosIt].And.!aX[Len(aColsD2[1])]})
			If nPos==0 .And. !Empty(oLancApICMS:aCols[oLancApICMS:nAT,nPosIt])
				//Este registro não pode ser recuperado, pois o mesmo encontra-se excluído juntamente com seu respectivo item do documento fiscal.
				//Para se recuperar este registro é necessário que se tenha o respectivo item deste documento fiscal ativado.
				Help("  ",1,"LAICMSDEL2")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a920LCpIt ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar o item digitado no lancamento fiscal com³±±
±±³          ³ os itens do documento fiscal.                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTLCpIt()
Local	lRet	:=	.T.
Local	nPosCalc:=	0
Local	nPosItD2:=	0

If Type("oLancApICMS")=="O"

	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})

	If nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="2" .And. Type("aColsD2")=="A" .And. Type("aHeadD2")="A"
		nPosItD2:= 	aScan(aHeadD2,{|aX| aX[2]==PadR("D2_ITEM",Len(SX3->X3_CAMPO))})
		If nPosItD2>0
			nPos	:=	aScan(aColsD2,{|aX|aX[nPosItD2]==AllTrim(M->CDA_NUMITE).And.!aX[Len(aColsD2[1])]})
			If nPos==0
				//Número do item é inválido para este lançamento fiscal.
				//Deve-se informar um número de item existente no respectivo documento fiscal.
				Help("  ",1,"LAICMSCMP1")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a920LCps  ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar os campos alimentados pelo sistema que  ³±±
±±³          ³ nao poderao ser alterados.                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTLCps()
Local	lRet	:=	.T.
Local	nPosCalc:=	0

If Type("oLancApICMS")=="O"
	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
	If nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="1"
		//Registros calculados pelo sistema não poderão ser alterados, pois serão utilizados como log da rotina.
		//Caso seja necessário alterar este cálculo, basta inserir novos itens nesta opção de ajuste ou utitlizar a funcionalidade de Gerenciamento dos Lançamentos Fiscais de ICMS. Vale ressaltar que na Apuração de ICMS será considerada a sequência maior de cada lançamento fiscal do documento.
		Help("  ",1,"LAICMSCMP2")
		lRet	:=	.F.
	EndIf
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a920LOk   ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar a linha do acols de lancamentos         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTLOk()
Local	lRet	:=	.T.
Local	nPosLanc:=	0
Local	nPosVlr	:=	0
Local	nNumIte	:=	0

If Type("oLancApICMS")=="O"
	nPosLanc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CODLAN"})
	nPosVlr:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_VALOR"})
	nNumIte:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})

	If !oLancApICMS:aCols[oLancApICMS:nAT,Len(oLancApICMS:aCols[oLancApICMS:nAT])] .And.;
		!Empty(oLancApICMS:aCols[oLancApICMS:nAT,nNumIte])
		
		If nPosLanc>0 .And. Empty(oLancApICMS:aCols[oLancApICMS:nAT,nPosLanc])
			Help(1," ","OBRIGAT",,"CDA_CODLAN"+Space(30),3,0)
			lRet	:=	.F.
		EndIf
	
		If lRet .And. nPosLanc>0 .And. Empty(oLancApICMS:aCols[oLancApICMS:nAT,nPosVlr])
			Help(1," ","OBRIGAT",,"CDA_VALOR"+Space(30),3,0)
			lRet	:=	.F.
		EndIf
	EndIf
EndIf
Return lRet

//-------------------------------------------------------

Static Function UTCompl()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a especie do documento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF2->(dbSetOrder(1)) 
SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))

Mata926(SD2->D2_DOC,SD2->D2_SERIE,SF2->F2_ESPECIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"S",SD2->D2_TIPO,SD2->D2_CF,SD2->D2_ITEM)

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³a920RatCC  ºAutor  ³Microsiga           º Data ³  06/18/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UTRatCC(aHeadAGH,aColsAGH,nAt)

Local aArea       := GetArea()
Local aSavaRotina := aClone(aRotina)
Local aColsCC     := {}
Local aButtons	  := {}
Local aButtonUsr  := {}
Local aHeadSC7    := {}
Local aColsSC7    := {}
Local aNoFields   := {"AGH_CUSTO1","AGH_CUSTO2","AGH_CUSTO3","AGH_CUSTO4","AGH_CUSTO5"}
Local bSavKeyF4   := SetKey(VK_F4 ,Nil)
Local bSavKeyF5   := SetKey(VK_F5 ,Nil)
Local bSavKeyF6   := SetKey(VK_F6 ,Nil)
Local bSavKeyF7   := SetKey(VK_F7 ,Nil)
Local bSavKeyF8   := SetKey(VK_F8 ,Nil)
Local bSavKeyF9   := SetKey(VK_F9 ,Nil)
Local bSavKeyF10  := SetKey(VK_F10,Nil)
Local bSavKeyF11  := SetKey(VK_F11,Nil)
Local nPItemNF	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"} )
Local nPCC	      := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CC"} )
Local nPConta	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CONTA"} )
Local nPItemCta   := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMCTA"} )
Local nPCLVL	  := Ascan(aHeader,{|x| AllTrim(x[2]) == "D2_CLVL"} )
Local nPDECC	  := 0
Local nPDEConta	  := 0
Local nPDEItemCta := 0
Local nPDECLVL	  := 0
Local nColTotal   := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"} )
Local nItem  	   := aScan(aColsAGH,{|x| Alltrim(x[1]) == Alltrim(aCols[n][nPItemNF])})
Local nX          := 0
Local nSavN       := nAT
Local nPPercAGH   := 0
Local nTotPerc    := 0
Local nOpcA       := 0
Local nNewTam     := 0
Local lContinua   := .T.
Local lRet        := .T.
Local oDlg
Local cCampo      := ReadVar()
Local nAviso      := 0
Local ca920Num    := SF2->F2_DOC

DEFAULT aHeadAGH  := {}
DEFAULT aColsAGH  := {}

Private aOrigHeader := aClone(aHeader)
Private aOrigAcols  := aClone(aCols)
Private oGetMan
Private nOrigN      := nAT
Private nPercRat    := 0
Private nPercARat	:= 100
Private oPercRat
Private oPercARat
Private oGetDad
Private N := nAT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L" 
	lContinua := !InConPad
EndIf

If nSavN == 0 
	lContinua := .F.
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader do AGH                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aHeadAGH)
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("AGH")
		While !EOF() .And. (SX3->X3_ARQUIVO == "AGH")
			IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"AGH_CUSTO"$SX3->X3_CAMPO
				AADD(aHeadAGH,{ TRIM(x3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT } )
			EndIf
			dbSelectArea("SX3")
			dbSkip()
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols do AGH                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItem > 0
		aColsCC := aClone(aColsAGH[nItem][2])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totaliza o % ja Rateado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPercRat := 0
		For nX   := 1  To  Len(aColsCC)
			nPercRat += aColsCC[nX][aScan(aHeadAGH,{|x| AllTrim(x[2])=="AGH_PERC"})]
		Next nX
		
		nPercARat := 100 - nPercRat
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aHeader e aCols do SC7 devem ser salvos pois a FillGetDados destroe ³
		//³ ambos por serem PRIVATE, independente da construcao do aColsCC.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeadSC7 := aClone(aHeader)
		aColsSC7 := aClone(aCols)
		aHeadAGH := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FillGetDados(2,"AGH",1,,,,aNoFields,,,,,.T.,aHeadAGH,aColsCC,,,)
		aColsCC[1][aScan(aHeadAGH,{|x| Trim(x[2])=="AGH_ITEM"})] := StrZero(1,Len(AGH->AGH_ITEM))
		
		aHeader := aHeadSC7
		aCols   := aColsSC7
		
	EndIf
	If !(Type('l920Auto') <> 'U' .And. l920Auto)
		aHeadSC7 := aClone(aHeader)
		aColsSC7 := aClone(aCols)
		DEFINE MSDIALOG oDlg FROM 100,100 TO 350,600 TITLE "Rateio por Centro de Custo" Of oMainWnd PIXEL //"Rateio por Centro de Custo"
		@ 018,003 SAY RetTitle("F2_DOC")  OF oDlg PIXEL SIZE 20,09
		@ 018,026 SAY ca920Num            OF oDlg PIXEL SIZE 50,09
		@ 018,096 SAY RetTitle("F2_ITEM") OF oDlg PIXEL SIZE 20,09
		@ 018,120 SAY aCols[N][nPItemNF]  OF oDlg PIXEL SIZE 20,09
		oGetDad := MsNewGetDados():New(030,005,105,245,0 ,"UTRatLOk","UTRatTOk","+AGH_ITEM",,,999,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeadAGH,aColsCC)
		oGetMan := oGetDad
		@ 110,005 Say OemToAnsi("% Rateada: ") FONT oDlg:oFont OF oDlg PIXEL	 // "% Rateada: "
		@ 110,035 Say oPercRat VAR nPercRat Picture PesqPict("AGH","AGH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		@ 110,184 Say OemToAnsi("% A Ratear: ") FONT oDlg:oFont OF oDlg PIXEL	 // "% A Ratear: "
		@ 110,217 Say oPercARat VAR nPercARat Picture PesqPict("AGH","AGH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(oGetDad:TudoOk(),(nOpcA:=1,oDlg:End()),(nOpcA:=0))},{||oDlg:End()},,aButtons)

		aHeader := aHeadSC7
		aCols   := aColsSC7

	Else
		nOpcA := 1
	EndIf
	nPPercAGH := aScan(aHeadAGH,{|x| AllTrim(x[2])=="AGH_PERC"})
	nTotPerc := 0
	
	aColsPar :={}
	AEval( aColsCC, { |x| If( !x[ Len(aHeadAGH) + 1], AAdd( aColsPar, x ), ) } )
	aColsCC := aClone( aColsPar )
	
	For nX := 1 To Len(aColsCC)
		nTotPerc += aColsCC[nX][nPPercAGH]
	Next nX
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina	:= aClone(aSavaRotina)
N := nSavN
SetKey(VK_F4 ,bSavKeyF4)
SetKey(VK_F5 ,bSavKeyF5)
SetKey(VK_F6 ,bSavKeyF6)
SetKey(VK_F7 ,bSavKeyF7)
SetKey(VK_F8 ,bSavKeyF8)
SetKey(VK_F9 ,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)
RestArea(aArea)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a920RatLok ³ Autor ³ Eduardo Riera         ³ Data ³15.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝ��ÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao da linhaok dos itens do rateio dos itens do documen³±±
±±³          ³to de entrada                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a linha esta valida                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar a linhaok do rateio dos³±±
±±³          ³itens do documento de entrada                                ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTRatLOk()

Local nPPerc    := aScan(aHeader,{|x| AllTrim(x[2]) == "AGH_PERC"} )
Local lRetorno  := .T.
Local nX        := 0

If !aCols[N][Len(aCols[N])]
	If aCols[N][nPPerc] == 0
		Help(" ",1,"A103PERC")
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	nPercRat := 0
	nPercARat:= 0
	For nX	:= 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			nPercRat += aCols[nX][nPPerc]
		EndIf
	Next
	nPercARat := 100 - nPercRat
	If Type("oPercRat")=="O"
		oPercRat:Refresh()
		oPercARat:Refresh()
	Endif
EndIf

Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a920RatLok ³ Autor ³ Eduardo Riera         ³ Data ³15.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao da TudoOk dos itens do rateio dos itens do documen-³±±
±±³          ³to de entrada                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a todas as linhas estao validas             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar a tudook do rateio dos ³±±
±±³          ³itens do documento de entrada                                ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTRatTok()

Local nPPerc   := aScan(aHeader,{|x| AllTrim(x[2]) == "AGH_PERC"} )
Local nTotal   := 0
Local nX       := 0
Local lRetorno := .T.
Local n_SaveLin

For nX	:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		nTotal += aCols[nX][nPPerc]
	EndIf
Next
If nTotal > 0 .And. nTotal <> 100
	Help(" ",1,"A103TOTRAT")
	lRetorno := .F.
EndIf

Return(lRetorno) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³a920FRat   ºAutor  ³Microsiga           º Data ³  06/23/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³Carrega o vetor dos rateios do pedido                       º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UTFRat(aHeadAGH,aColsAGH)
Local lQuery    := .F.
Local aStruAGH  := AGH->(dbStruct())
Local cAliasAGH := "AGH" 
Local nX		:= 0
Local nY		:= 0  
Local aBackAGH    := {}
Local cItemAGH  := ""
Local nItemAGH	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array contendo as registros do AGH           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("AGH")
DbSetOrder(1) // AGH_FILIAL+AGH_NUM+AGH_SERIE+AGH_FORNEC+AGH_LOJA+AGH_ITEMPD+AGH_ITEM
cAliasAGH := "AGH"		

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery    := .T.
		aStruAGH  := AGH->(dbStruct())
		cAliasAGH := "A120NFISCAL"
		cQuery    := "SELECT AGH.*,AGH.R_E_C_N_O_ AGHRECNO "
		cQuery    += "FROM "+RetSqlName("AGH")+" AGH "
		cQuery    += "WHERE AGH.AGH_FILIAL='"+xFilial("AGH")+"' AND "
		cQuery    += "AGH.AGH_NUM='"+SF2->F2_DOC+"' AND "
		cQuery    += "AGH.AGH_SERIE='"+SF2->F2_SERIE+"' AND "
		cQuery    += "AGH.AGH_FORNEC='"+SF2->F2_CLIENTE+"' AND "
		cQuery    += "AGH.AGH_LOJA='"+SF2->F2_LOJA+"' AND "
		cQuery    += "AGH.D_E_L_E_T_=' ' "
		cQuery    += "ORDER BY "+SqlOrder(AGH->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAGH,.T.,.T.)
		For nX := 1 To Len(aStruAGH)
			If aStruAGH[nX,2]<>"C"
				TcSetField(cAliasAGH,aStruAGH[nX,1],aStruAGH[nX,2],aStruAGH[nX,3],aStruAGH[nX,4])
			EndIf
		Next nX
		
	Else
#ENDIF
		MsSeek(xFilial("AGH")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
#IFDEF TOP
	EndIf
#ENDIF

dbSelectArea(cAliasAGH)
While ( !Eof() .And. ;
		xFilial('AGH') == (cAliasAGH)->AGH_FILIAL .And.;
		SF2->F2_DOC == (cAliasAGH)->AGH_NUM .And.;
		SF2->F2_SERIE == (cAliasAGH)->AGH_SERIE .And.;
		SF2->F2_CLIENTE == (cAliasAGH)->AGH_FORNEC .And.;
		SF2->F2_LOJA == (cAliasAGH)->AGH_LOJA )
	If Empty(aBackAGH)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX3")
		DbSetOrder(1)
		MsSeek("AGH")
		While ( !EOF() .And. SX3->X3_ARQUIVO == "AGH" )
			If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"AGH_CUSTO"$SX3->X3_CAMPO
				aadd(aBackAGH,{ TRIM(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					SX3->X3_CONTEXT })
			EndIf
			DbSelectArea("SX3")
			dbSkip()
		EndDo
	EndIf
	aHeadAGH  := aBackAGH
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ADHeadRec("AGH",aHeadAGH)    

	If cItemAGH <> 	(cAliasAGH)->AGH_ITEMPD
		cItemAGH	:= (cAliasAGH)->AGH_ITEMPD
		aadd(aColsAGH,{cItemAGH,{}})
		nItemAGH++
	EndIf

	aadd(aColsAGH[nItemAGH][2],Array(Len(aHeadAGH)+1))
	For nY := 1 to Len(aHeadAGH)
		If IsHeadRec(aHeadAGH[nY][2])
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := IIf(lQuery , (cAliasAGH)->AGHRECNO , AGH->(Recno())  )
		ElseIf IsHeadAlias(aHeadAGH[nY][2])
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := "AGH"
		ElseIf ( aHeadAGH[nY][10] <> "V")
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := (cAliasAGH)->(FieldGet(FieldPos(aHeadAGH[nY][2])))
		Else
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := (cAliasAGH)->(CriaVar(aHeadAGH[nY][2]))
		EndIf
		aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][Len(aHeadAGH)+1] := .F.
	Next nY

	DbSelectArea(cAliasAGH)
	dbSkip()
EndDo

If lQuery
	DbSelectArea(cAliasAGH)
	dbCloseArea()
	DbSelectArea("AGH")
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºFuncao    ³SF3Canc ºAutor  ³Mauro Gonçalves       º Data ³   20.Jul.10 º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDescricao ³Verifica se a NF está cancelada. Usada no PE MTVALNF        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SF3Canc(cCodFil,cNroDoc,cSerDoc,cCliFor,cCodLoj)
Local aArea    := GetArea()
local cSF3Canc := "QRYSF3CANC"
local cQuery   := ""    
local lCanc    := ""    

if empty(cCodFil) .or. empty(cNroDoc) .or. empty(cSerDoc) .or. empty(cCliFor) .or. empty(cCodLoj)
   return .f.
endif
   
#IFDEF TOP
	If TcSrvType() <> "AS/400"
		cQuery := "SELECT SF3.* FROM "
		cQuery += RetSqlName("SF3") + " SF3 "
		cQuery += " WHERE "
		cQuery += "F3_FILIAL = '"+cCodFil+"' AND "
		cQuery += "F3_CLIEFOR = '"+cCliFor+"' AND "
		cQuery += "F3_LOJA = '"+cCodLoj+"' AND "
		cQuery += "F3_NFISCAL = '"+cNroDoc+"' AND "
		cQuery += "F3_SERIE = '"+cSerDoc+"' AND "
		cQuery += "F3_DTCANC <> '        '"			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSF3Canc,.F.,.T.)
	Else
#ENDIF
 		cSF3Canc := "SF3"
		dbSelectArea("SF3")
		dbSetOrder(4)
		MsSeek(xFilial()+cCliFor+cCodLoj+cNroDoc+cSerDoc)
		#IFDEF TOP
	Endif	
		#ENDIF

lCanc := !(cSF3Canc)->(EOF())
DbSelectArea("QRYSF3CANC")
dbCloseArea()
RestArea(aArea)

return lCanc
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºFuncao    ³a920TpLjTit ºAutor  ³Varejo            º Data ³   30.Dez.16 º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDescricao ³Retorna os tipos dos títulos cadastrados na tabela SX5       º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function UTTpLjTit(cSqlCons, cAdsCons)
Local nTamE1Tipo 	:= SE1->(TamSx3("E1_TIPO")[1]) //Tamanho do campo E1_TIPO
Local aAreaSx5 	:= SX5->(GetArea()) //WorkArea Sx5
Local cChave 		:= xFilial("SX5")+"24" //Chave de busca SX5
Local cExp 		:= "" //Expressão do Campo
Local cSimbCorr	:= SuperGetMv("MV_SIMB1") //Moeda corrente

Default cSqlCons := "" //Chave de busca SQL
Default cAdsCons := "" //Chave de Busca ADS

//Formas de pagamento Padroes

cAdsCons := AllTrim(cSimbCorr)+"/CC/CD/FI/VA/CO/CH/" 
cSqlCons :=  "'" + cSimbCorr  + "', 'CC', 'CD', 'FI', 'VA', 'CO', 'CH', "

If SX5->(Dbseek(cChave))
	Do While SX5->(!Eof() .AND. RTrim(X5_FILIAL + X5_TABELA) == cChave) 
		cExp := Left(AllTrim(SX5->X5_CHAVE), nTamE1Tipo)
		If !(cExp $ cAdsCons)
			If !(cExp == "BO" .OR. cExp == "BOL")
				cSqlCons += "'" + cExp  + "', "
				cAdsCons +=  cExp + "/"
			Else
				cSqlCons += "'BO', 'BOL', "
				cAdsCons +=  "BO/BOL/"
			EndIf
		EndIf
		SX5->(DbSkip(1))
	EndDo
	cSqlCons  :=  Left(cSqlCons, Len(cSqlCons) -2)
	cAdsCons := Left(cAdsCons, Len(cAdsCons)-1)
EndIf

RestArea(aAreaSX5)

Return

/*/{Protheus.doc} a920NfOri()
@description
Funcao responsavel por apresentar a Dialog para vinculo da
NF de origem.
@author joao.pellegrini
@since 13/06/2017
@version 11.80
/*/
Static Function UTNfOri()

Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="D2_COD"})
Local nPNFOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})

If nPProduto > 0 .And. n <= Len(aCols)
	
	cProduto  := aCols[n][nPProduto]

	If "D2_NFORI" $ ReadVar() .And. cTipo $ "PIC"
	
		If F4Compl(,,,c920Client,c920Loja,cProduto,"A440")
			
			If nPNFOri > 0 .And. nPSerOri > 0
				
				MaFisLoad("IT_NFORI",aCols[n][nPNFOri],n)
				MaFisLoad("IT_SERORI",aCols[n][nPSerOri],n)
								
			EndIf   
				
		EndIf
			
	EndIf
	
EndIf
	
Return .T.

/*/{Protheus.doc} a920NextDoc()
@description
Funcao responsavel por retornar o numero da proxima nota
quando o usuario nao digitar.
@author joao.pellegrini
@since 05/12/2017
@version 11.80
/*/
Static Function UTNextDoc()

Local aArea	   := GetArea()
Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
Local lRet    := .F.
Local cSerie  := ""

Private cNumero := "" // Precisa ser private com este nome - Funcao Sx5NumNota.
Private lMudouNum := .F. // Precisa ser private com este nome - Funcao Sx5NumNota.

lRet := Sx5NumNota(@cSerie, cTipoNf)

If lRet

	// Numeracao via SX5 ou SXE/SXF
	If cTipoNf $ "1|2"
				
		// Apenas via SX5 pois com XE/XF o usuario nao consegue confirmar a selecao da serie se o documento ja existir.
		If cTipoNf == "1"
			SF2->(dbSetOrder(2))
			If SF2->(MsSeek(xFilial("SF2") + c920Client + c920Loja + PADR(cNumero, TamSx3("F2_DOC")[1]) + cSerie))
				MsgAlert("Este número de documento já foi utilizado." + Chr(13) + Chr(10) + "O documento será gerado com o próximo número disponível.")
			EndIf
		EndIf
		
		// lMudouNum sera .T. quando utilizar XE/XF e o usuario alterar a numeracao na tela.
		// Neste caso devo respeitar o numero digitado. No entando a proxima numeração seguirá
		// a sequencia normal.
		If !lMudouNum
			cNumero := NxtSX5Nota(cSerie, NIL, cTipoNf)
		EndIf
		
		c920Nota  := cNumero
		c920Serie := cSerie
			
	// Numeracao via SD9
	ElseIf cTipoNf == "3" .And. AliasIndic("SD9")
	 
		c920Nota := MA461NumNf(.T., cSerie)
		c920Serie := cSerie
		
	EndIf
	
EndIf

RestArea(aArea)

Return lRet

Static Function UTVldNum(c920Nota)

Local lRet := .T.

If cPaisLoc == "BRA" .And. (Type("l920Auto") != "L" .Or. !l920Auto) .And. !lLote .And. Empty(c920Nota) 

	lRet := lGeraNum := MsgYesNo("Deixar o n�mero do documento em branco indica que ser�o solicitada uma s�rie no momento da grava��o e o n�mero ser�o sugerido pelo sistema." + Chr(13) + Chr(10) + ;								
								 "Deseja continuar?", "Numera��o Autom�tica")

EndIf

Return lRet
