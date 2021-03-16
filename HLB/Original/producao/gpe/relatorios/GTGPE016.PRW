#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.Ch"
#Include "rwmake.ch"        
#INCLUDE "FILEIO.CH"
#INCLUDE "IMPIRPF.CH"
#define  CRLF chr(13)+chr(10)
#define DMPAPER_A4 


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 19/10/2016  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Emiss„o de Etiquetas de Funcionarios admitidos             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/    

USER FUNCTION GTGPE016()   


	Private _i 			:= 1
	Private _cList
	Private _oList
	Private _oDlg
	Private _aEstrut 	:= {}
	Private _aEstItem	:= {}
	Private _aDir    	:= {}
	Private _aDados 	:= {}

	Private aLinha   := {" "," "," "}
	Private aVetor := {}  
	Private nAlin := 0
	Private aInfo := {}
	
	Private oNoMarked	:= LoadBitmap(GetResources(),'LBNO')
	Private oMarked	    := LoadBitmap(GetResources(),'LBOK')

	private cCodigo  := SM0->M0_CODIGO

	AADD(_aDados,{.t.," 01 ","Admiss„o    ","  "})
	AADD(_aDados,{.t.," 02 ","F.G.T.S.    ","  "})		
	AADD(_aDados,{.t.," 03 ","ExperiÍncia ","  "})		
	AADD(_aDados,{.t.," 04 ","C.ConfianÁa ","  "})		
	AADD(_aDados,{.t.," 05 ","Ativ.Externa","  "})		
	AADD(_aDados,{.t.," 06 ","Estagi·rio  ","  "})		

	Private cPerg     := "GTGPE016  "
	private cAliqicms := "  "  
	private aDes := {}
	private aDescop := {}
	private cTotal := 0
	private cTES := {}
	private cNOMECOM := space(40)
	private cCGC     := space(20)
	private cCNPJ    := space(20)
	private cCodigo  := space(2)
	private cEnd	 := space(50)
	private cCid	 := space(30)
	private cBairro	 := space(50)
	private cEst	 := space(2)
	private cCep	 := space(10)
	private cArq	 := space(30)

	Private cPath		:= "c:\Relatorios\                                  "
	Private cPeriodo    := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
	Private cDirGer		:= "c:\Relatorios\"
	  
	//Cria o diretorio caso nao exista
	If MAKEDIR(cDirGer) == 0
		Aviso( "Importante", "O DiretÛrio '" +cDirGer+ "' foi criado",{"Ok"})
	EndIf    
	
	cNOMECOM := SM0->M0_NOMECOM
	cCGC     := SM0->M0_CGC
	cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
	cCodigo  := SM0->M0_CODIGO
	cEnd	 := SM0->M0_ENDCOB
	cCid	 := SM0->M0_CIDCOB
	cBairro  := SM0->M0_BAIRCOB
	cEst	 := SM0->M0_ESTCOB
	cCep	 := SM0->M0_CEPCOB
	
	CriaSX1(cPerg)

	Pergunte(cPerg,.T.)

	DEFINE MSDIALOG _oDlg FROM 100,150 TO 450,800 PIXEL TITLE "Menu de Emiss„o de etiquetas"
	@ 05, 5  SAY "Marque as etiquetas que deseja imprimir e clique no bot„o <Processa>"
	@ 20, 5  LISTBOX _oList VAR _cList FIELDS HEADER "","Codigo","Etiqueta"," " ;
	FIELDSIZES 15,25,150,30 SIZE 310,095 OF _oDlg PIXEL ON DBLCLICK Marca(_oList,_aDados)
	_oList:SetArray(_aDados)
	_oList:bLine := { || {Iif(_aDados[_oList:nAT,01],oMarked,oNoMarked),_aDados[_oList:nAt,2],_aDados[_oList:nAt,3],_aDados[_oList:nAt,4]}}
	_oDlg:Refresh()
	
	@ 160,010 BUTTON OemToAnsi("Inverter SeleÁ„o") SIZE 080,11 ACTION Processa( {|| MTodos(_oList,_aDados) }) OF _oDlg PIXEL
	
	//@ 160,240 BUTTON OemToAnsi("Processa") 	   		   SIZE 050,11 ACTION Processa( {|| ProcRel(_oList,_aDados,ALLTRIM(cPath),cPeriodo) }) OF _oDlg PIXEL
	@ 160,240 BUTTON OemToAnsi("Processa") 	   		   SIZE 050,11 ACTION Processa( {|| geraeti(_oList,_aDados,ALLTRIM(cPath),cPeriodo) }) OF _oDlg PIXEL
	@ 160,290 BUTTON OemToAnsi("Sair")  	   		   SIZE 030,11 ACTION Processa( {|| Val_Sai() }) OF _oDlg PIXEL
	ACTIVATE DIALOG _oDlg CENTERED

	MsgInfo("Fim do processamento.","AtenÁ„o")
		
	//Close(_oDlg)
	
RETURN


//////------------------------------------------------------
STATIC FUNCTION geraeti()
	
	Local cQuery := ' '
	Local lLoop  := .T.
	Local cOrdm  := "01"
	Local nArq   := Nil
	//Local cPath  := AllTrim(GetTempPath())
	Local nCont  := 01
	Local cHtml  := ' '
	Local nRegua := 0
	Local nContArq := 0

	Farol:=.f.
	for x := 1 to len(_aDados)
	    if _aDados[ x , 1 ]
	       Farol:=.t.
	    endif
	next
	if !Farol
		alert('Nenhuma etiqueta foi selecionada')
	endif

	nCol1 := 0	
	nCol2 := 0	
	nCol3 := 0	
	nCol4 := 0	
	nCol5 := 0	
	nCol6 := 0					

	nOpt1 := .f.	
	nOpt2 := .f.	
	nOpt3 := .f.	
	nOpt4 := .f.	
	nOpt5 := .f.	
	nOpt6 := .f.

	nEtiq := 0

	if Farol
		
		cNomeRel := _aDados[ _oList:nAT, 1 ]
		For i:=1 to len(_aDados)
			cMark    := _aDados[ i , 1 ]
			cNomeRel := _aDados[ i , 3 ]     
			
			If cMark
				If i=1
					nCol1 := 5
					nEtiq := nEtiq + 1
					nOpt1 := .t.
				Elseif i=2 
					nCol2 := 215
					nEtiq := nEtiq + 1
					nOpt2 := .t.					
				Elseif i=3 
					nCol3 := 415
					nEtiq := nEtiq + 1
					nOpt3 := .t.					
				Elseif i=4 
					nCol4 := 5
					nEtiq := nEtiq + 1
					nOpt4 := .t.										
				Elseif i=5 
					nCol5 := 215
					nEtiq := nEtiq + 1
					nOpt5 := .t.										
				Elseif i=6 
					nCol6 := 415
					nEtiq := nEtiq + 1
					nOpt6 := .t.										
				Endif
			Endif
		Next
	
	endif
/*
////// tratamento para posicionamento das etiquetas
	if nPos1 = 0 .and. nPos2 > 0
		nPos2 := 5
	endif
	
	if nPos1 = 0 .and. nPos3 > 0
		nPos3 := 215
	endif
	
*/

	
	cTotal := 0
		
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	cQuery := CRLF +" SELECT  "
 	cQuery += CRLF +" RA_FILIAL,RA_MAT,RA_CC,RA_NOME,RA_ADMISSA,RA_CODFUNC,RJ_DESC,RA_SALARIO, RA_CIC, RA_PIS, RA_OPCAO,RA_BCDPFGT,RA_CTDPFGT,RA_CATFUNC "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRA")+" A,"+ RETSQLNAME("SRJ")+" B " 
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' '
 	cQuery += CRLF +" AND RA_CODFUNC = RJ_FUNCAO "
 	cQuery += CRLF +" AND RA_ADMISSA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"' " 
 	cQuery += CRLF +" AND RA_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"' " 
 	cQuery += CRLF +" AND RA_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06 +"' " 

 	cQuery += CRLF +" ORDER BY RA_FILIAL,RA_MAT,RA_CC "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("FUN") > 0
		FUN->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FUN",.F.,.F.)
	
	FUN->(DBGOTOP())
	
	If FUN->(EOF())
		IF SELECT("FUN") > 0
			FUN->(DBCLOSEAREA())
		ENDIF
		Aviso("ATEN«√O", "Funcion·rio n„o encontrado!!!", {"Ok"} )
		Return	
	Endif


	aStruFim := FUN->(DbStruct())

	WHILE FUN->(!EOF()) 

		IncProc( "PROCESSANDO FUNCIONARIO:"+substr(FUN->RA_NOME,1,20)+" Aguarde!!!" ) 

		fImpEti1()  /// Imprime etiquetas

		FUN->(DBSKIP())  
    
	ENDDO

	Aviso( "Importante", "Gravado na pasta '" +cDirGer+ " "+cArq,{"Ok"})
	
	IF SELECT("FUN") > 0
		FUN->(DBCLOSEAREA())
	ENDIF

RETURN


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥19/10/2016   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Insere novas perguntas ao sx1                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function CriaSX1(cPerg)

	Local aRegs := {}
// GRUPO/ORDEM/PERGUNT/PERSPA/PERENG/VARIAV/TIPO/TAM/DEC/PRESEL/GSC/VALID/VAR01/DEF01/DEFSPA1/DEFENG1/CNT01/VAR02/DEF02/DEFSPA2/DEFENG2/CNT02/VAR03/DEF03/DEFSPA3/DEFENG3/CNT03/VAR04/DEF04/DEFSPA4/DEFENG4/CNT04/VAR05/DEF05/DEFSPA5/DEFENG5/CNT05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL

	Aadd(aRegs,{cPerg,'01','Data Adm. de :  ','','','MV_CH1','D',08,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','   ','','','','',''})
	Aadd(aRegs,{cPerg,'02','Data Adm.AtÅE:  ','','','MV_CH2','D',08,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','   ','','','','',''})
	Aadd(aRegs,{cPerg,'03','Da Filial    :  ','','','MV_CH3','C',02,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','',''})
	Aadd(aRegs,{cPerg,'04','AtÅEa Filial :  ','','','MV_CH4','C',02,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','',''})
	Aadd(aRegs,{cPerg,'05','Da Matricula :  ','','','MV_CH5','C',06,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','','','',''})
	Aadd(aRegs,{cPerg,'06','AtÅEMatricula:  ','','','MV_CH6','C',06,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return



//Inicia a Impress„o do Arquivo PDF.
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fImpEti1  ∫Autor  ≥Microsiga           ∫ Data ≥  19/10/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Impressao de Etiquetas em pdf                               ∫±±
±±∫          ≥Fonte - Formulario Grafico                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico                                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function  fImpEti1()       

 	mDtadmis	:=	CTOD(substr(FUN->RA_ADMISSA,7,2)+"/"+substr(FUN->RA_ADMISSA,5,2)+"/"+substr(FUN->RA_ADMISSA,1,4))
 	cDatabs		:=  CTOD(DTOC(ddatabase))
	cRegistro	:=	FUN->RA_MAT
	cSalario	:=  FUN->RA_SALARIO		
	cFuncao		:=  FUN->RJ_DESC
	cDtopcao := CTOD(substr(FUN->RA_OPCAO,7,2)+"/"+substr(FUN->RA_OPCAO,5,2)+"/"+substr(FUN->RA_OPCAO,1,4))
	cDtretra := SPACE(10)
	cBcoDep  := SUBSTR(FUN->RA_BCDPFGT,1,3)
	cAgDep   := SUBSTR(FUN->RA_BCDPFGT,4,5)
	cPraca   :=	ALLTRIM(SM0->M0_CIDCOB)
	cEst     := ALLTRIM(SM0->M0_ESTCOB)
	cBairro  :=	ALLTRIM(SM0->M0_BAIRCOB)

	_BCOFGTS := Posicione("SA6",1,xFilial("SA6")+ALLTRIM(FUN->RA_BCDPFGT),"A6_NOME")
	_AGEFGTS := Posicione("SA6",1,xFilial("SA6")+ALLTRIM(FUN->RA_BCDPFGT),"A6_NOMEAGE")

	Private cStartPath:= GetSrvProfString("Startpath","")
	Private N 		:= 0     
	Private lExigi	:= .F.
	Private nx		:= 1
	Private nTamImp	:= 80

	Private oMessage

	cArq	 :=  "Etiqueta_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(cRegistro)+".PDF"

	PRIVATE lAdjustToLegacy := .F.
	PRIVATE lDisableSetup  := .T.
	Private oEtique

	oEtique:=FWMSPrinter():New("Etiqueta_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(cRegistro),IMP_PDF,lAdjustToLegacy,,lDisableSetup,,,,,,,.F.)
	oEtique:SetResolution(72)
	oEtique:SetPortrait()

	oEtique:SetPaperSize(9) 
	oEtique:SetMargin(05,05,05,05) 			 
	oEtique:cPathPDF := cDirGer
	oEtique:StartPage()
	
	oFont06	:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)		
	oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont10n:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)		
	oFont12n:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)		
	oFont13 := TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)		
	oFont13n:= TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)		
	oFont14	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont15	:= TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
	oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
	oFont21 := TFont():New("Arial",21,21,,.T.,,,,.T.,.T.)

/*

	if nEtiq = 6

		nLin := 35 
		oEtique:Say(nLin,0005,"Empregador:",oFont10)	  // Admiss„o										
		oEtique:Say(nLin,0050,ALLTRIM(cNOMECOM),oFont06)
		oEtique:Say(nLin,0215,"OP«√O:",oFont10)			  // FGTS								
		oEtique:Say(nLin,0260,"RETRATA«√O:",oFont10)											
		oEtique:Say(nLin,0415,"O empregado foi admitido em car·ter de",oFont10)	 // Experiencia	
		
		nLin += 10 
		oEtique:Say(nLin,0005,"CNPJ:",oFont10)	// Admiss„o										
		oEtique:Say(nLin,0045,ALLTRIM(SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)),oFont10)
		oEtique:Say(nLin,0215,substr(dtos(cDtopcao),7,2)+"/"+substr(dtos(cDtopcao),5,2)+"/"+substr(dtos(cDtopcao),1,4),oFont10) // FGTS
		oEtique:Say(nLin,0270,"   /      /   ",oFont10)
		oEtique:Say(nLin,0415,"experiÍncia conforme a letra C ß 2∫ do artigo",oFont10)  	// Experiencia
	
		nLin += 10 
		oEtique:Say(nLin,0005,"EndereÁo:",oFont10)	// Admiss„o										
		oEtique:Say(nLin,0045,ALLTRIM(cEnd),oFont06)
		oEtique:Say(nLin,0215,"Banco Depositario:",oFont10)// FGTS
		oEtique:Say(nLin,0280,ALLTRIM(cBcoDep)+" "+ALLTRIM(_BCOFGTS),oFont06)	
		oEtique:Say(nLin,0415,"443 da C.L.T. por 45 dias do registro",oFont10) 	// Experiencia
		
		nLin += 10 
		oEtique:Say(nLin,0005,"Cidade / Estado:",oFont10)		// Admiss„o									
		oEtique:Say(nLin,0065,ALLTRIM(cCid)+" - "+ALLTRIM(cEst),oFont06)
		oEtique:Say(nLin,0215,"Agencia:",oFont10)	// FGTS										
		oEtique:Say(nLin,0250,ALLTRIM(cAgDep)+" "+ALLTRIM(_AGEFGTS),oFont06)	
		oEtique:Say(nLin,0415,"podendo ser prorrogado por mais 45 dias",oFont10) 	// Experiencia
	
		nLin += 10 
		oEtique:Say(nLin,0005,"CEP:",oFont10)	// Admiss„o										
		oEtique:Say(nLin,0045,substr(ALLTRIM(cCep),1,5)+" - "+substr(ALLTRIM(cCep),6,3),oFont10)
		oEtique:Say(nLin,0215,"PraÁa / Estado:",oFont10)	// FGTS										
		oEtique:Say(nLin,0275,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst),oFont06)
		oEtique:Say(nLin,0415,"exercendo a funÁ„o de: ",oFont10) 	// Experiencia
		oEtique:Say(nLin,0497,ALLTRIM(cFuncao),oFont06)
			
		nLin += 15
		oEtique:Say(nLin,0005,"Cargo:",oFont10)   // Admiss„o											
		oEtique:Say(nLin,0045,ALLTRIM(cFuncao),oFont10)
		oEtique:Say(nLin,0415,"Obedecido o disposto ß ˙nico do artigo 445",oFont10) 	// Experiencia
		
		nLin += 15
		oEtique:Say(nLin,0005,"Admiss„o:",oFont10)	// Admiss„o										
		oEtique:Say(nLin,0045,substr(dtos(mDtadmis),7,2)+"/"+substr(dtos(mDtadmis),5,2)+"/"+substr(dtos(mDtadmis),1,4),oFont10)
		oEtique:Say(nLin,0415,"445 da C.L.T.",oFont10) 	// Experiencia
	
		nLin += 15
		oEtique:Say(nLin,0005,"Registro:",oFont10)	// Admiss„o										
		oEtique:Say(nLin,0045,ALLTRIM(cRegistro),oFont10)
		nLin += 15
		oEtique:Say(nLin,0005,"Sal·rio:",oFont10)	// Admiss„o										
		oEtique:Say(nLin,0045,Transform(cSalario,"@E 99,999,999.99"),oFont08)
		cExtenso := Extenso(cSalario,.F.,1)
		nLin += 15
		oEtique:Say(nLin,0005,SUBSTR(ALLTRIM(cExtenso),1,45),oFont08)	// Admiss„o	
		oEtique:Say(nLin,0215,"Empresa:",oFont10)		// FGTS
		oEtique:Say(nLin,0250,ALLTRIM(cNOMECOM),oFont06)
		oEtique:Say(nLin,0415,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) // Experiencia
		if len(ALLTRIM(cExtenso)) > 45         // Admiss„o
			nLin += 10
			oEtique:Say(nLin,0005,SUBSTR(ALLTRIM(cExtenso),46,len(ALLTRIM(cExtenso))-45),oFont08)
			nLin += 35	
		Else
			nLin += 35	
		Endif
		oEtique:Line(nLin,0005,nLin,180)    // Admiss„o
		oEtique:Line(nLin,0215,nLin,380)	// FGTS
		oEtique:Line(nLin,0415,nLin,580)    // Experiencia
			
		nLin += 15
		oEtique:Say(nLin,0005,ALLTRIM(cNOMECOM),oFont08)    // Admiss„o
		oEtique:Say(nLin,0215,ALLTRIM(cNOMECOM),oFont08)	// FGTS
		oEtique:Say(nLin,0415,ALLTRIM(cNOMECOM),oFont08)	// Experiencia
	
	    ///// segunda
		nLin += 65 
		oEtique:Say(nLin,0005,"O empregado n„o terÅEqualquer controle ",oFont10)											
		oEtique:Say(nLin,0215,"O empregado exerce atividade externa",oFont10)
		oEtique:Say(nLin,0415,"Empregador:",oFont10)											
		oEtique:Say(nLin,0465,ALLTRIM(cNOMECOM),oFont06)
	
		nLin += 15
		oEtique:Say(nLin,0005,"e/ou fiscalizaÁ„o de hor·rio ou marcaÁ„o de ",oFont10)											
		oEtique:Say(nLin,0215,"incompat˙ìel com a fixaÁ„o de hor·rio de ",oFont10)	
		oEtique:Say(nLin,0415,"CNPJ:",oFont10)											
		oEtique:Say(nLin,0460,ALLTRIM(SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)),oFont10)
	
		nLin += 15 
		oEtique:Say(nLin,0005,"ponto, pelo exerc˙Äio de cargo de confianÁa,",oFont10)											
		oEtique:Say(nLin,0215,"trabalho. (AplicaÁ„o Artigo  62.I-CLT)",oFont10)
		oEtique:Say(nLin,0415,"EndereÁo:",oFont10)											
		oEtique:Say(nLin,0460,ALLTRIM(cEnd),oFont06)
	
		nLin += 15 
		oEtique:Say(nLin,0005,"de acordo com o artigo 62, item II. Da CLT.",oFont10)	
		oEtique:Say(nLin,0415,"Bairro /Est:",oFont10)											
		oEtique:Say(nLin,0470,ALLTRIM(cBairro)+" - "+ALLTRIM(cEst),oFont06)
		nLin += 10
		oEtique:Say(nLin,0415,"CEP / Cidade:",oFont10)											
		oEtique:Say(nLin,0470,substr(ALLTRIM(cCep),1,5)+" - "+substr(ALLTRIM(cCep),6,3)+" "+ALLTRIM(cCid),oFont06)
		nLin += 10
		oEtique:Say(nLin,0415,"Inicio do Est·gio:",oFont10)
		oEtique:Say(nLin,0500,"   /      /   ",oFont10)
		nLin += 15
		oEtique:Line(nLin,0415,nLin,600)
		nLin += 10
		oEtique:Say(nLin,0415,ALLTRIM(cNOMECOM),oFont06)
	
		nLin += 20 
		oEtique:Say(nLin,0005,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) 
		oEtique:Say(nLin,0215,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) 
		oEtique:Say(nLin,0415,"Fim do Est·gio:",oFont10)
		oEtique:Say(nLin,0500,"   /      /   ",oFont10)
		nLin += 35
		oEtique:Line(nLin,0005,nLin,180)
		oEtique:Line(nLin,0215,nLin,380)
		oEtique:Line(nLin,0415,nLin,580)
		nLin += 10
		oEtique:Say(nLin,0005,ALLTRIM(cNOMECOM),oFont08)
		oEtique:Say(nLin,0215,ALLTRIM(cNOMECOM),oFont08)
		oEtique:Say(nLin,0415,ALLTRIM(cNOMECOM),oFont08)
  
	endif

*/


	if nOpt1 = .t.                     // Admiss„o
		nCol1 := 5
		nLin := 35 
		oEtique:Say(nLin,nCol1,"Empregador:",oFont10)	  										
		oEtique:Say(nLin,nCol1+45,ALLTRIM(cNOMECOM),oFont06)
		nLin += 10 
		oEtique:Say(nLin,nCol1,"CNPJ:",oFont10)											
		oEtique:Say(nLin,nCol1+50,ALLTRIM(SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)),oFont10)
		nLin += 10 
		oEtique:Say(nLin,nCol1,"EndereÁo:",oFont10)									
		oEtique:Say(nLin,nCol1+40,ALLTRIM(cEnd),oFont06)
		nLin += 10 
		oEtique:Say(nLin,nCol1,"Cidade / Estado:",oFont10)									
		oEtique:Say(nLin,nCol1+60,ALLTRIM(cCid)+" - "+ALLTRIM(cEst),oFont06)
		nLin += 10 
		oEtique:Say(nLin,nCol1,"CEP:",oFont10)									
		oEtique:Say(nLin,nCol1+40,substr(ALLTRIM(cCep),1,5)+" - "+substr(ALLTRIM(cCep),6,3),oFont10)
		nLin += 15
		oEtique:Say(nLin,nCol1,"Cargo:",oFont10)   											
		oEtique:Say(nLin,nCol1+40,ALLTRIM(cFuncao),oFont10)
		nLin += 15
		oEtique:Say(nLin,nCol1,"Admiss„o:",oFont10)										
		oEtique:Say(nLin,nCol1+40,substr(dtos(mDtadmis),7,2)+"/"+substr(dtos(mDtadmis),5,2)+"/"+substr(dtos(mDtadmis),1,4),oFont10)
		nLin += 15
		oEtique:Say(nLin,nCol1,"Registro:",oFont10)											
		oEtique:Say(nLin,nCol1+40,ALLTRIM(cRegistro),oFont10)
		nLin += 15
		oEtique:Say(nLin,nCol1,"Sal·rio:",oFont10)									
		oEtique:Say(nLin,nCol1+40,Transform(cSalario,"@E 99,999,999.99"),oFont08)
		cExtenso := Extenso(cSalario,.F.,1)
		nLin += 15
		oEtique:Say(nLin,nCol1,SUBSTR(ALLTRIM(cExtenso),1,45),oFont08)
		if len(ALLTRIM(cExtenso)) > 45         
			nLin += 10
			oEtique:Say(nLin,nCol1,SUBSTR(ALLTRIM(cExtenso),46,len(ALLTRIM(cExtenso))-45),oFont08)
			nLin += 35	
		Else
			nLin += 35	
		Endif
		oEtique:Line(nLin,nCol1,nLin,nCol1+175)    
		nLin += 15
		oEtique:Say(nLin,nCol1,ALLTRIM(cNOMECOM),oFont08)    
	endif	

	if nOpt2 = .t.          // FGTS
		if nOpt1 = .f.
			nCol2 := 5
		else
			nCol2 := 215		
		endif	
		nLin := 35 
		oEtique:Say(nLin,nCol2,"OP«√O:",oFont10)			  								
		oEtique:Say(nLin,nCol2+45,"RETRATA«√O:",oFont10)											
		nLin += 10 
		oEtique:Say(nLin,nCol2,substr(dtos(cDtopcao),7,2)+"/"+substr(dtos(cDtopcao),5,2)+"/"+substr(dtos(cDtopcao),1,4),oFont10) 
		oEtique:Say(nLin,nCol2+55,"   /      /   ",oFont10)
		nLin += 10 
		oEtique:Say(nLin,nCol2,"Banco Depositario:",oFont10)
		oEtique:Say(nLin,nCol2+65,ALLTRIM(cBcoDep)+" "+ALLTRIM(_BCOFGTS),oFont06)
		nLin += 10 
		oEtique:Say(nLin,nCol2,"Agencia:",oFont10)										
		oEtique:Say(nLin,nCol2+35,ALLTRIM(cAgDep)+" "+ALLTRIM(_AGEFGTS),oFont06)
		nLin += 10 
		oEtique:Say(nLin,nCol2,"PraÁa / Estado:",oFont10)										
		oEtique:Say(nLin,nCol2+60,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst),oFont06)
		nLin += 15
		nLin += 15
		nLin += 15
		nLin += 15
		nLin += 15
		nLin += 10
		oEtique:Say(nLin,nCol2,"Empresa:",oFont10)		
		oEtique:Say(nLin,nCol2+35,ALLTRIM(cNOMECOM),oFont06)
		nLin += 35	
		oEtique:Line(nLin,nCol2,nLin,nCol2+165)	
		nLin += 15
		oEtique:Say(nLin,nCol2,ALLTRIM(cNOMECOM),oFont08)
	endif
	
	if nOpt3 = .t.         //Experiencia
		if nOpt1 = .f. .and. nOpt2 = .f.
			nCol3 := 5
		elseif nOpt1 = .t. .and. nOpt2 = .f.
			nCol3 := 215
		elseif nOpt1 = .f. .and. nOpt2 = .t.
			nCol3 := 215							
		elseif nOpt1 = .t. .and. nOpt2 = .t.
			nCol3 := 415		
		endif	

		if upper(cCodigo) <> "GY" 
			nLin := 35 
			oEtique:Say(nLin,nCol3,"O empregado foi admitido em car·ter de",oFont10)	 	
			nLin += 10 
			oEtique:Say(nLin,nCol3,"experiÍncia conforme a letra C ß 2∫ do artigo",oFont10)  	
			nLin += 10 
			oEtique:Say(nLin,nCol3,"443 da C.L.T. por 45 dias do registro",oFont10) 
			nLin += 10 
			oEtique:Say(nLin,nCol3,"podendo ser prorrogado por mais 45 dias",oFont10) 	
			nLin += 10 
			oEtique:Say(nLin,nCol3,"exercendo a funÁ„o de: ",oFont10) 
			oEtique:Say(nLin,nCol3+82,ALLTRIM(cFuncao),oFont06)
			nLin += 15
			oEtique:Say(nLin,nCol3,"Obedecido o disposto ß ˙nico do artigo 445",oFont10) 
			nLin += 15
			oEtique:Say(nLin,nCol3," da C.L.T.",oFont10) 	
			nLin += 15
			nLin += 15
			nLin += 15
			oEtique:Say(nLin,nCol3,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) 
			nLin += 10
			nLin += 35	
			oEtique:Line(nLin,nCol3,nLin,nCol3+165)    
			nLin += 15
			oEtique:Say(nLin,nCol3,ALLTRIM(cNOMECOM),oFont08)
		else
			nLin := 35 
			oEtique:Say(nLin,nCol3,"O empregado foi admitido em car·ter de",oFont10)	 	
			nLin += 10 
			oEtique:Say(nLin,nCol3,"experiÍncia conf. a letra C ß 2∫ do art.",oFont10)  	
			nLin += 10 
			oEtique:Say(nLin,nCol3,"443 da C.L.T. por 45 dias do registro",oFont10) 
			nLin += 10 
			oEtique:Say(nLin,nCol3,"exercendo a funÁ„o de:",oFont10) 
			oEtique:Say(nLin,nCol3+82,ALLTRIM(cFuncao),oFont06)
			nLin += 10 
			oEtique:Say(nLin,nCol3,"sendo prorrogado automaticmente por",oFont10) 	
			nLin += 10 
			oEtique:Say(nLin,nCol3,"igual periodo.",oFont10) 

			nLin += 20
			nLin += 15
			nLin += 15
			//nLin += 15
			nLin += 15
			oEtique:Say(nLin,nCol3,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) 
			nLin += 10
			nLin += 35	
			oEtique:Line(nLin,nCol3,nLin,nCol3+165)    
			nLin += 15
			oEtique:Say(nLin,nCol3,ALLTRIM(cNOMECOM),oFont08)
		endif
		
	endif
 
	if nOpt4 = .t.         //cargo de confianÁa

		if nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f.
			nCol4 := 5
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .f.
			nCol4 := 215
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .t.
			nCol4 := 415
 			nLin := 35	
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .t.
			nCol4 := 215
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .f.
			nCol4 := 215
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .f.
			nCol4 := 415
 			nLin := 35
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .t.
			nCol4 := 415
 			nLin := 35	 														
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t.
			nCol4 := 5
			//nLin += 65
			nLin := 275									
		endif	

		oEtique:Say(nLin,nCol4,"O empregado n„o terÅEqualquer controle ",oFont10)											
		nLin += 15
		oEtique:Say(nLin,nCol4,"e/ou fiscalizaÁ„o de hor·rio ou marcaÁ„o de ",oFont10)											
		nLin += 15 
		oEtique:Say(nLin,nCol4,"ponto, pelo exerc˙Äio de cargo de confianÁa,",oFont10)											
		nLin += 15 
		oEtique:Say(nLin,nCol4,"de acordo com o artigo 62, item II. Da CLT.",oFont10)	
		nLin += 10
		nLin += 10
		nLin += 15
		nLin += 10
		nLin += 20 
		oEtique:Say(nLin,nCol4,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) 
		nLin += 35
		oEtique:Line(nLin,nCol4,nLin,nCol4+175)
		nLin += 10
		oEtique:Say(nLin,nCol4,ALLTRIM(cNOMECOM),oFont08)
	
	endif

	if nOpt5 = .t.         //atividade externa

		if nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .f.
			nCol5 := 5
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .f.
			nCol5 := 215
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .f.
			nCol5 := 415
 			nLin := 35	
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .t.
			nCol5 := 5
 			//nLin += 65
			nLin := 275	 				
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .t. .and. nOpt4 = .f.
			nCol5 := 215
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .f.
			nCol5 := 215
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .f.
			nCol5 := 415
 			nLin := 35
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .t. .and. nOpt4 = .f.
			nCol5 := 415
 			nLin := 35	 														
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .f.
			nCol5 := 5
			nLin := 275					
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .t.
			nCol5 := 215
			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .t. .and. nOpt4 = .t.
			nCol5 := 415
			nLin := 35			
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .t.
			nCol5 := 415
			nLin := 35			
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .t.
			nCol5 := 215
			//nLin += 65
			nLin := 275								
		endif	


		oEtique:Say(nLin,nCol5,"O empregado exerce atividade externa",oFont10)
		nLin += 15
		oEtique:Say(nLin,nCol5,"incompat˙ìel com a fixaÁ„o de hor·rio de ",oFont10)	
		nLin += 15 
		oEtique:Say(nLin,nCol5,"trabalho. (AplicaÁ„o Artigo  62.I-CLT)",oFont10)
		nLin += 15 
		nLin += 10
		nLin += 10
		nLin += 15
		nLin += 10
		nLin += 20 
		oEtique:Say(nLin,nCol5,ALLTRIM(cPraca)+" - "+ALLTRIM(cEst)+"  "+substr(dtos(cDatabs),7,2)+"/"+substr(dtos(cDatabs),5,2)+"/"+substr(dtos(cDatabs),1,4),oFont10) 
		nLin += 35
		oEtique:Line(nLin,nCol5,nLin,nCol5+165)
		nLin += 10
		oEtique:Say(nLin,nCol5,ALLTRIM(cNOMECOM),oFont08)
	endif
				
	if nOpt6 = .t.         //Estagiarios

		if nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .f. .and. nOpt5 = .f.
			nCol6 := 5
 			nLin := 35					
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .f. .and. nOpt5 = .f.
			nCol6 := 215
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .f. .and. nOpt5 = .f.
			nCol6 := 215
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .t. .and. nOpt4 = .f. .and. nOpt5 = .f.
			nCol6 := 215
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .t. .and. nOpt5 = .f.
			nCol6 := 215
 			nLin := 35					
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .f. .and. nOpt5 = .t.
			nCol6 := 215
 			nLin := 35		
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .f.  .and. nOpt5 = .f.
			nCol6 := 415
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .t. .and. nOpt4 = .f.  .and. nOpt5 = .f.
			nCol6 := 415
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .t.  .and. nOpt5 = .f.
			nCol6 := 415
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .f.  .and. nOpt5 = .t.
			nCol6 := 415
 			nLin := 35	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .f.  .and. nOpt5 = .f.
			nCol6 := 5
			nLin := 275	 				
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .t.  .and. nOpt5 = .f.
			nCol6 := 5
			nLin := 275	 	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .f. .and. nOpt4 = .f.  .and. nOpt5 = .t.
			nCol6 := 5
			nLin := 275	 	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .t.  .and. nOpt5 = .f.
			nCol6 := 215
 			nLin := 275	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .f.  .and. nOpt5 = .t.
			nCol6 := 215
 			nLin := 275	
		elseif nOpt1 = .t. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .t.  .and. nOpt5 = .t.
			nCol6 := 415
 			nLin := 275
		elseif nOpt1 = .f. .and. nOpt2 = .t. .and. nOpt3 = .t. .and. nOpt4 = .t.  .and. nOpt5 = .t.
			nCol6 := 215
 			nLin := 275
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .t. .and. nOpt4 = .t.  .and. nOpt5 = .t.
			nCol6 := 5
 			nLin := 275 			
		elseif nOpt1 = .f. .and. nOpt2 = .f. .and. nOpt3 = .f. .and. nOpt4 = .t.  .and. nOpt5 = .t.
			nCol6 := 415
 			nLin := 35 			
		endif	


		oEtique:Say(nLin,nCol6,"Empregador:",oFont10)											
		oEtique:Say(nLin,nCol6+50,ALLTRIM(cNOMECOM),oFont06)
		nLin += 15
		oEtique:Say(nLin,nCol6,"CNPJ:",oFont10)											
		oEtique:Say(nLin,nCol6+45,ALLTRIM(SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)),oFont10)
		nLin += 15 
		oEtique:Say(nLin,nCol6,"EndereÁo:",oFont10)											
		oEtique:Say(nLin,nCol6+45,ALLTRIM(cEnd),oFont06)
		nLin += 15 
		oEtique:Say(nLin,nCol6,"Bairro /Est:",oFont10)											
		oEtique:Say(nLin,nCol6+55,ALLTRIM(cBairro)+" - "+ALLTRIM(cEst),oFont06)
		nLin += 10
		oEtique:Say(nLin,nCol6,"CEP / Cidade:",oFont10)											
		oEtique:Say(nLin,nCol6+55,substr(ALLTRIM(cCep),1,5)+" - "+substr(ALLTRIM(cCep),6,3)+" "+ALLTRIM(cCid),oFont06)
		nLin += 10
		oEtique:Say(nLin,nCol6,"Inicio do Est·gio:",oFont10)
		oEtique:Say(nLin,nCol6+85,"   /      /   ",oFont10)
		nLin += 15
		oEtique:Line(nLin,nCol6,nLin,nCol6+185)
		nLin += 10
		oEtique:Say(nLin,nCol6,ALLTRIM(cNOMECOM),oFont06)
		nLin += 20 
		oEtique:Say(nLin,nCol6,"Fim do Est·gio:",oFont10)
		oEtique:Say(nLin,nCol6+85,"   /      /   ",oFont10)
		nLin += 35
		oEtique:Line(nLin,nCol6,nLin,nCol6+165)
		nLin += 10
		oEtique:Say(nLin,nCol6,ALLTRIM(cNOMECOM),oFont08)

	endif
	

	oEtique:EndPage() 		// Finaliza a pagina
	
	oEtique:Print()
	
Return

Static Function Mtodos(_oList,_aDados)

	Local _i 	:= 1
	Local _nPos := _oList:nAT
	
	For _i := 1 TO Len(_aDados)
		_oList:nAT	 := _i
		_aDados[ _oList:nAT, 1 ] := !_aDados[ _oList:nAT, 1 ]
	Next
	
	_oList:nAT	 := 1
	_oList:Refresh()
	
Return

Static Function Val_Sai

	//If MsgYesNo("Deseja realmente abandonar a rotina ?")
		Close(_oDlg)
	//Endif
	
Return

Static Function Marca(_oList,_aDados)

	Local _i 	:= 1
	Local _nPos := _oList:nAT
	
	_aDados[ _oList:nAT, 1 ] := !_aDados[ _oList:nAT, 1 ]
	
	_oList:Refresh()
	
Return




