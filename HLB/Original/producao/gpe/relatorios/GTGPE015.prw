#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.Ch"
#Include "rwmake.ch"        
#INCLUDE "IMPIRPF.CH"
#define  CRLF chr(13)+chr(10)
#define DMPAPER_A4 

Static lUsaRRA := If(FindFunction( "fUsaRRA" ),fUsaRRA(),.F.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa()≥   Autor   ∫ Francisco F S Neto        ∫ Data ≥ 31/10/2016  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Envio de Informes de Rendimentos com senhas                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/


*/
*----------------------*
User Function GTGPE015()
*----------------------*
	Local nSp			:= 2
	Local aFilesDel		:= {}
	Local nErro			:= 0

	Local cCodFunc		:= ""		
	Local cDescFunc		:= ""			
	Local aAux			:= {}        
	
	Private cDescEmp 		:= ""
	Private cDesEmp 		:= ""

	private cReferencia	    := ""
	private cmailconta	    := ""	
	private cmailsenha	    := ""	
	private cmailserver	    := getmv("MV_RELSERV")  
	private lEnvioOK 		:= .T.
	private cAno 		:= mv_par08
	private cEmail		:= ""
	Private cCodPLR   	:= "3562"

	Private cDirGer		:= GetTempPath()+"Informe\"

	//Private cDirGer		:= "C:\INFORME\"
	
	Private lSenha := GetMv("MV_P_00034",,.F.)	//Define se compacta o arquivo e usa senha ou nao.
	Private lCompl := GetMv("MV_P_00052",,.F.)	//Define se email com senha deve ser com complexidade elevada.
	Private cCompl := ""

	//Objetos p/ Impresssao Grafica 
	Private oFont07
	Private oFont08
	Private oFont10
	Private oFont10n
	Private oFont12
	Private oFont12n
	Private oFont13
	Private oFont13n
	Private oFont14
	Private oFont15
	Private oFont16
	Private oFont21

	Private lFirst	:= .F. 
	
	// Qtde de Letras:	 1	  2		3	  4		5	  6		7	   8	 9	  10
	Private aLetra := {	"A", "B" , "M" , "C" , "T" , "D" , "E" , "F" , "G" , "H" 	,;
						"P", "U" , "I" , "J" , "K" , "L" , "O" , "R" , "V" , "W" 	,;
						"X", "Y" , "Z" , "1" , "2" , "3" , "4" , "5" , "6" , "7" 	,;
						"8", "9" , "B1", "C1", "M1", "T1", "61", "71", "81", "91"	,;
						"0", "H1", "F1", "S" , "S1", "Q" 							}
	Private aLetraPLR := { "O1", "Q1", "C3"}
	Private aLetraRRA := { "A1", "B2", "B3", "C2", "D2", "I1" }
	
	Private aTotLetra[46]
	Private aTotPLR[3]
	Private aTotRRA		:= {}
	Private cCgc
	Private nLiq13o 	:= 0.00
	Private nTotOutros	:= 0.00
	Private nTotRend	:= 0.00
	Private nTotRetido 	:= 0.00
	Private cDescRet    := ""
	Private cDescRRA	:= ""
	Private nItem		:= 0
	Private nLinhas		:= 0
	Private aComplem	:= {}
	Private cDescOred	:= ""            		
	Private cFil_Mat	:= ""
	Private _Mat		:= ""
	Private _cpfcgc     := ""
	Private _benefic     := ""
	Private _codret     := ""
	Private cChave      := ""
	Private cChaveZ21   := ""
  	Private cSubject	:= ""
	Private cCpf        := ""
	Private	nCNPJFOR := ""
	Private	nNOMEFOR := ""
    Private  nCODFOR := ""
   	Private  nPRIORIDAD := ""

	Private lGCHPortal := .F.
	Private lPortal := .F.	

	private lCentra := .T.
	private l1Vez   := .T.
	PRIVATE cCNPJoLD 	:= ""
	PRIVATE cSr4Filial 	:= ""


	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]

	Afill( aTotLetra , 0 )
	Afill( aTotPLR   , 0 )

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

	Private cPerg     := "GPM580    "

	If Pergunte(cPerg,.T.)
		If SimNao("Envia Informes de Rendimentos ?") == "S"
			Processa({ |lEnd| gerainf(@lEnd),OemToAnsi("Criando cabeÁalho, aguarde...")}, OemToAnsi("Aguarde..."))
		Else
			Return
		EndIf
	Else
		Return
	EndIf
	
RETURN

///////-----------------------------------------------------------------------------------------------------------
Static Function gerainf()

	MakeDir(cDirGer) 	//Cria diretorio no temporario
	
	//Zera o conteudo da pasta Temporaria.
	nTimeRef := Time()
	aFilesDel := Directory(cDirGer+"*.*", "D")
	While Len(aFilesDel) > 0
		If aScan(aFilesDel, { |x| x[1] == "." }) <> 0
			aDel(aFilesDel,aScan(aFilesDel, { |x| x[1] == "." }))
			aSize(aFilesDel,Len(aFilesDel)-1)
		EndIf
		If aScan(aFilesDel, { |x| x[1] == ".." }) <> 0
			aDel(aFilesDel,aScan(aFilesDel, { |x| x[1] == ".." }))
			aSize(aFilesDel,Len(aFilesDel)-1)
		EndIf
		
		If len(aFilesDel) == 0
			Exit
		EndIf
		
		For i := 1 to len(aFilesDel)
			If Ferase(cDirGer+ aFilesDel[i][1]) <> 0
				If VAL(STRTRAN(ElapTime(nTimeRef, Time()),":","")) > 30 //Se passar de 30 segundos avisa a demora.
					If MsgYesNo("Apagar o Arquivo '"+ALLTRIM(aFilesDel[i][1])+"' estÅEdemorando! Deseja abortar?")
						lEnvioOK := .T.
						Return .T.
					Else
						nTimeRef := Time()
					EndIf
				EndIf
			EndIf
		Next i
		aFilesDel := Directory(cDirGer+"*.*", "D")
	EndDo

	//RRP - 02/03/2018 - Ajuste	
	cQuery1:= ""
	cQuery1+= "SELECT RA_MAT FROM "+RetSQLName("SRA")+" WHERE D_E_L_E_T_ <> '*' " 
	cQuery1+= "	  AND RA_MAT BETWEEN '"+MV_PAR05+"' AND '" +MV_PAR06+"' AND D_E_L_E_T_ <> '*' GROUP BY RA_MAT "
	
	If SELECT("TEMP1") > 0
		TEMP1->(DBCLOSEAREA())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TEMP1",.F.,.F.)

	TEMP1->(DBGOTOP())
	
	If TEMP1->(EOF())
		If SELECT("REN") > 0
			TEMP1->(DBCLOSEAREA())
		EndIf
		Aviso("ATEN«√O", "Execute rotina Gerar Arquivo da DIRF para esse exercicio!", {"Ok"} )
		Return	
	EndIf
	TEMP1->(DBGOTOP()) 
	
	cMatTemp:= TEMP1->RA_MAT 	
	
	WHILE TEMP1->(!EOF())

	cQuery := CRLF +" SELECT  "  
 	cQuery += CRLF +" RL_FILIAL,RL_MAT,RL_TIPOFJ,RL_CPFCGC,RL_CODRET,RL_BENEFIC,RL_ENDBENE,RL_UFBENEF,RL_CGCFONT,RL_NOMFONT,RL_CC, "
 	cQuery += CRLF +" R4_TIPOREN,X5_DESCRI,R4_MES,R4_ANO,R4_IDCMPL,R4_MESES,R4_VALOR "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRL")+" A," + RETSQLNAME("SR4")+" B,"  + RETSQLNAME("SX5")+" C " 
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND RL_CODRET = '0561' "
 	cQuery += CRLF +" AND R4_ANO = '"+MV_PAR08+"' AND R4_TIPOREN = X5_CHAVE AND X5_TABELA = '36' "
 	cQuery += CRLF +" AND RL_FILIAL = R4_FILIAL AND RL_MAT = R4_MAT AND RL_CPFCGC = R4_CPFCGC "
 	cQuery += CRLF +" AND RL_FILIAL BETWEEN '"+MV_PAR01+"' AND '" +MV_PAR02+"' "
 	cQuery += CRLF +" AND RL_CGCFONT BETWEEN '"+MV_PAR03+"' AND '" +MV_PAR04+"' "
 	//cQuery += CRLF +" AND RL_MAT    BETWEEN '"+MV_PAR05+"' AND '" +MV_PAR06+"' " 	
 	cQuery += CRLF +" AND RL_MAT    BETWEEN '"+cMatTemp+"' AND '" +cMatTemp+"' " 	
 	cQuery += CRLF +" AND RL_CC     BETWEEN '"+MV_PAR10+"' AND '" +MV_PAR11+"' " 	
 	//cQuery += CRLF +" ORDER BY RL_FILIAL,RL_MAT,RL_TIPOFJ,RL_CPFCGC,RL_CODRET,R4_TIPOREN "
 	cQuery += CRLF +" ORDER BY RL_MAT,RL_FILIAL,RL_TIPOFJ,RL_CPFCGC,RL_CODRET,R4_TIPOREN "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("REN") > 0
		REN->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"REN",.F.,.F.)

	REN->(DBGOTOP())
	
	If REN->(EOF())
		IF SELECT("REN") > 0
			REN->(DBCLOSEAREA())
		ENDIF
		//Aviso("ATEN«√O", "Execute rotina Gerar Arquivo da DIRF para esse exercicio!", {"Ok"} )
		//Return
		//RRP - 02/03/2017 - Final do Ajuste
		TEMP1->(DbSkip())
		cMatTemp:= TEMP1->RA_MAT
		Loop	
	Endif

	aStruFim := REN->(DbStruct())
	ProcRegua(REN->(RecCount()))
	REN->(DBGOTOP())
	_cChave := "" 
	_cChave2 := ""	
	lEntra:=.F.
	cResponsa := MV_PAR09	

	WHILE REN->(!EOF()) 

		IncProc( "PROCESSANDO FUNCIONARIO:"+cChave+" Aguarde!!!" )
                                                 
		cTpInsc := REN->RL_TIPOFJ
		//IF _cChave # REN->RL_FILIAL+REN->RL_MAT  /// quebra de funcion·rio
		IF _cChave # REN->RL_MAT  /// quebra de funcion·rio
			aComplem:={}   
			lEntra:=.t.
			  
			IF !Empty(_cChave)
				If mv_par08 >= "2013"
					nOrdem := RetOrder( "SR4" , "R4_ANO+R4_CPFCGC+R4_CODRET+R4_MES" , .T. )
					SR4->( dbSetOrder( nOrdem )	)
					SR4->( dbSeek ( mv_par08 + _CPFCGC + cCodPLR ) )
					
					While SR4->(! Eof() ) .AND. SR4->R4_ANO == mv_par08 .AND. SR4->R4_CPFCGC == _CPFCGC .AND. SR4->R4_CODRET == cCodPLR
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ Consiste controle de acessos                                 ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				
							If !(SR4->R4_FILIAL $ fValidFil()) ////.Or. !Eval(cAcessaSR4)
								SR4->(dbSkip())
								Loop
							EndIf 
						    If l1Vez
						    	chkAtivo(@cFil_MAT)
						    	l1Vez := .F.
						    EndIf	      
							nLetra := Ascan(aLetraPLR, Alltrim(SR4->R4_TIPOREN))
						
						   	If nLetra > 0
						       aTotPLR[nLetra] += NoRound(SR4->R4_VALOR,2)
						   	Endif
						
						   	dbSelectArea("SR4")
							SR4->( dbSkip())
					Enddo
				EndIf
				
				////// PENSAO ALIMENTICIA
								
				nOrdem := RetOrder( "SM8" , "M8_FILIAL+M8_MAT+M8_CODFOR+M8_CODRET+M8_ANO+M8_MES+M8_TIPOREN" , .T. )
				//SM8->( dbSetOrder( nOrdem )	)
				//SM8->( dbSeek ( xFilial("SM8")+_MAT+"01"+ "0561" + mv_par08 ) )

				SM8->( dbSetOrder( 2 )	)
				SM8->( dbSeek ( xFilial("SM8")+_MAT+"0561"+ mv_par08 ) )

				
				While SM8->(! Eof() ) .AND. SM8->M8_MAT == _MAT .AND. SM8->M8_ANO == mv_par08 .AND. SM8->M8_CODRET == "0561"
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Consiste controle de acessos                                 ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If !(SM8->M8_FILIAL $ fValidFil()) ///.Or. !Eval(cAcessaSR4)
						SR4->(dbSkip())
						Loop
					EndIf 
				    If l1Vez
				    	chkAtivo(@cFil_MAT)
				    	l1Vez := .F.
				    EndIf	      
					nLetra := Ascan(aLetra, Alltrim(SM8->M8_TIPOREN))
				   	If nLetra > 0
				       aTotLetra[nLetra] += NoRound(SM8->M8_VALOR,2)
				   	Endif
					nCODFOR := SM8->M8_CODFOR
				   	dbSelectArea("SM8")
					SM8->( dbSkip())
				Enddo

				////////BENEFICIARIO
				nOrdem := RetOrder( "SRQ" , "RQ_FILIAL+RQ_MAT+RQ_ORDEM+RQ_SEQUENC" , .T. )
				SRQ->( dbSetOrder( nOrdem )	)
				IF SRQ->( dbSeek ( xFilial("SRQ")+_MAT+"01"+ "01" ) )
					nCNPJFOR :=	SRQ->RQ_CIC
					nNOMEFOR := SRQ->RQ_NOME
			       	CDESC := ALLTRIM(nNOMEFOR)+" PENS√O ALIMENTICIA JUDICIAL "+" CPF: "+ALLTRIM(NCNPJFOR)
			       	CDESC := ALLTRIM(CDESC)     	
					aAdd(aComplem,{ cDesc, aTotLetra[nLetra], cChave, nPrioridad }) 
				ENDIF
				///PREVIDENCIA PRIVADA

				nOrdem := RetOrder( "SM9" , "M9_FILIAL+M9_MAT+M9_CODFOR+M9_CODRET+M9_ANO+M9_MES+M9_TIPOREN" , .T. )
				SM9->( dbSetOrder( nOrdem )	)
				SM9->( dbSeek ( xFilial("SM9")+_MAT+"01"+ "0561" + mv_par08 ) )
				
				While SM9->(! Eof() ) .AND. SM9->M9_MAT == _MAT .AND. SM9->M9_ANO == mv_par08 .AND. SM9->M9_CODRET == "0561"
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Consiste controle de acessos                                 ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If !(SM9->M9_FILIAL $ fValidFil()) ///.Or. !Eval(cAcessaSR4)
						SR4->(dbSkip())
						Loop
					EndIf 
				    If l1Vez
				    	chkAtivo(@cFil_MAT)
				    	l1Vez := .F.
				    EndIf	      
					nLetra := Ascan(aLetra, Alltrim(SM9->M9_TIPOREN))
				   	If nLetra > 0
				       aTotLetra[nLetra] += NoRound(SM9->M9_VALOR,2)
				   	Endif
					nCODFOR := SM9->M9_CODFOR
				   	dbSelectArea("SM9")
					SM9->( dbSkip())
				Enddo
				
				nLINHA := FPOSTAB("S073",nCODFOR,"==",4)
				IF nLINHA > 0
					nCNPJFOR := FTABELA("S073",NLINHA,5)
					nNOMEFOR := FTABELA("S073",NLINHA,6)
			       	CDESC := ALLTRIM(nNOMEFOR)+" CONTRIBUI«√O ¿ PREVIDENCIA PRIVADA "+" CNPJ: "+ALLTRIM(NCNPJFOR)
			       	CDESC := ALLTRIM(CDESC)     	
					aAdd(aComplem,{ cDesc, aTotLetra[nLetra], cChave, nPrioridad }) 
			    ENDIF 

				dbSelectArea("RCS")
					
				////RCS->( dbSeek( REN->RL_FILIAL+REN->RL_MAT+REN->RL_TIPOFJ+REN->RL_CPFCGC+REN->RL_CODRET+mv_par08 ) )

				IF RCS->( dbSeek( xFilial("SRL")+_MAT+cTpInsc+_CPFCGC+"0561"+mv_par08 ) )

		
				cCNPJoLD 	:= ""
				cRCSFilial 	:= Replicate("!", FwGetTamFilial)
			
				While RCS->(! Eof() ) .AND. RCS->RCS_ANO == mv_par08 .AND. RCS->RCS_CPFBEN == _CPFCGC .and. lEntra 
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ Consiste controle de acessos                                 ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		
					If !(RCS->RCS_FILIAL $ fValidFil()) 
						RCS->(dbSkip())
						Loop
					EndIf 
						
					/*If (RCS->RCS_FILIAL # REN->RL_FILIAL ) 
						If cRCSFilial # RCS->RCS_FILIAL
							dbSelectArea("SRL")
							aArea	:= GetArea() 
							//cIndex:=CriaTrab(Nil,.F.)
							//DbSetIndex(cIndex+OrdBagExt()) 							      
							REN->( dbSetOrder(1) )
							cCNPJoLD 	:= REN->RL_CGCFONT
							cRCSFilial 	:= RCS->RCS_FILIAL
							REN->(dbSeek(RCS->RCS_FILIAL+RCS->RCS_MAT))
							If REN->RL_CGCFONT # cCNPJoLD
								lCentra := .F.
								RCS->( dbSkip() )
								RestArea(aArea)
								Loop
							EndIf   	
								RestArea(aArea)
						ElseIf !lCentra
							RCS->( dbSkip() )
							Loop
						EndIf
					EndIf*/	
						
					nLinhas++    
					If !empty(RCS->RCS_NOME) .and. ( EMPTY(RCS->RCS_OUTROS) .OR. AllTrim(RCS->RCS_TIPORE) == "R")
						If RCS->RCS_VALOR # 0                                                                 
					
							cChave := RCS->RCS_CPFCGC+RCS->RCS_TIPORE+RCS->RCS_OUTROS+RCS->RCS_VERBA
							nPos := Ascan( aComplem,{ |X| X[3]==cChave .and. X[2]> 0 })                                                         
					
							If nPos > 0
								aComplem[nPos,2] += RCS->RCS_VALOR
								RCS->(dbSkip())   
								LOOP
							EndIf	 
					
							cDesc := AllTrim( RCS->RCS_DESCRI )
					
							// Define a prioridade de impressao das informacoes complementares dependendo do tipo de retencao da verba
							If Alltrim( RCS->RCS_TIPORES ) $ "W#2"
								nPrioridad := 1
							ElseIf Alltrim( RCS->RCS_TIPORES ) $ "C#C1"
								nPrioridad := 2
								cDesc += Space(2) + Transform( RCS->RCS_CPFCGC, If( Len(AllTrim(RCS->RCS_CPFCGC)) == 11, "@R 999.999.999-99", "@R 99.999.999/9999-99" ) )
							ElseIf Alltrim( RCS->RCS_TIPORES ) $ "R" .And. ! "REEMBOLSO" $ RCS->RCS_OUTROS 
								nPrioridad := 3
							ElseIf Alltrim( RCS->RCS_TIPORES ) $ "R" .And. "REEMBOLSO" $ RCS->RCS_OUTROS 
								nPrioridad := 4
							Else
								nPrioridad := 5
							EndIf
					        if len(alltrim(cDesc)) > 0
								aAdd(aComplem,{ cDesc, RCS->RCS_VALOR, cChave, nPrioridad })
					        endif
							nItem++
						ElseIf Alltrim(RCS->RCS_TIPORE) # "R"
							aAdd( aComplem, { SPACE(04) + RCS->RCS_NOME +space(23), 0, "", 9 } )
						Endif               
					EndIf
							
					If !EMPTY(RCS->RCS_OUTROS) .and. AllTrim(RCS->RCS_TIPORE) <> "R"
						cDescOred += If(!empty(alltrim(cDescOred)),", ","")+ alltrim(RCS->RCS_OUTROS)
					EndIf
					RCS->(dbSkip()	)
				EndDo
				          
				lEntra:=.f.

				ENDIF        
		
		
				IF Len(aComplem) > 0
					lEntra:=.f.
				ENDIF                              
		

				nTotRend 	:= aTotLetra[01]
				nTotRetido	:= aTotLetra[06] + aTotLetra[23] + aTotLetra[19] + aTotLetra[44]
				nLiq13o 	:= (aTotLetra[14] - aTotLetra[15] - aTotLetra[16]) - aTotLetra[24] - aTotLetra[28]
				nLiq13o 	:= nLiq13o - aTotLetra[33] - aTotLetra[34] - aTotLetra[35] - aTotLetra[36] - aTotLetra[45]
				nTotOutros	:= ( aTotLetra[17] - aTotLetra[46] ) + ( aTotPLR[1] - aTotPLR[2] - aTotPLR[3] )

				fIrpfGraX()  //impress„o arquivos .pdf 
			   	ENVIO()
					  
				nTotRend 	:= 0.00
				nTotRetido	:= 0.00
				nLiq13o 	:= 0.00
				nTotOutros	:= 0.00
					
				for i = 1 to len(aTotLetra)
		 			aTotLetra[i] := 0.00
		 		next i	
		
				for i = 1 to len(aTotPLR)
		 			aTotPLR[i] := 0.00
		 		next i	
			ENDIF
			//_cChave := REN->RL_FILIAL+REN->RL_MAT
			cChave := REN->RL_MAT
			_cChave2:= REN->RL_FILIAL+REN->RL_MAT
		ENDIF           /// fim da quebra
/////////////////////////////////////////////////////////////////////			
		_aArea := getarea()
	
		nLetra := Ascan(aLetra,Alltrim(REN->R4_TIPOREN))
		
		If nLetra > 0
			aTotLetra[nLetra] += NoRound(REN->R4_VALOR,2) 
		ElseIf lUsaRRA
		   	nLetra := aScan(aLetraRRA,AllTrim(REN->R4_TIPOREN))
		   	//Rendimento Recebido Acumuladamente
		   	If nLetra > 0
		   		nPos := Ascan( aTotRRA,{ |X| X[1] == REN->R4_IDCMPL })
		   		If nPos > 0
		   			aTotRRA[nPos,5,nLetra] += NoRound(REN->R4_VALOR,2)
		   		Else
		    		DbSelectArea("RFI")
		    		If DbSeek(REN->RL_FILIAL+REN->RL_MAT+REN->R4_IDCMPL)
						aAdd(aTotRRA,{RFI->RFI_IDCMPL,RFI->RFI_NUMPRO, AllTrim(RFI->RFI_RETRRA), REN->R4_MESES, {0,0,0,0,0,0} } )
						aTotRRA[Len(aTotRRA),5,nLetra] += NoRound(REN->R4_VALOR,2)
		    		EndIf
		    	EndIf
		   	EndIf
		Endif

		cCgc := If(cTpInsc="2",Transform(SubStr(REN->RL_CGCFONT,1,14),"@R ##.###.###/####-##"),If(cTpInsc="3",Transform(SubStr(REN->RL_CGCFONT,1,11),"@R ###.###.###-##")+Space(4),REN->RL_CGCFONT))
		cDesemp := REN->RL_NOMFONT
	    cDescEmp := cDesemp
		cReferencia := mv_par08
		_benefic := REN->RL_BENEFIC
		_codret  := REN->RL_CODRET
		_cpfcgc  := REN->RL_CPFCGC
		_MAT	 := REN->RL_MAT
		_filia := REN->RL_FILIAL
		    
		If REN->(FieldPos("RL_CC"))== 0
			cFil_Mat:= REN->RL_FILIAL+"-"+REN->RL_MAT
		Else
			cFil_Mat:= REN->RL_FILIAL+"-"+REN->RL_MAT+"-"+REN->RL_CC
		EndIf
	
		dbSelectArea("SX5")
		If dbSeek(cFilial+"37"+REN->RL_CODRET)
		    cDescRet := X5Descri()
		Else
		    cDescRet := STR0009 //"Codigo nao Cadastrado Tabela 37                       "
		Endif
			
		If lUsaRRA
			If DbSeek(cFilial+"37"+"1889")
				cDescRRA := X5Descri()
			Else
				cDescRRA := STR0009
			EndIf
		EndIf

		restarea ( _aArea ) 

		REN->(DBSKIP())  
	ENDDO

	// final da leitura de movimentos

	//A partir do ano 2013, o PLR e' recolhido separadamente, sob o codigo de retencao 3562
	If mv_par08 >= "2013"
		nOrdem := RetOrder( "SR4" , "R4_ANO+R4_CPFCGC+R4_CODRET+R4_MES" , .T. )
		SR4->( dbSetOrder( nOrdem )	)
		SR4->( dbSeek ( mv_par08 + _CPFCGC + cCodPLR ) )
		While SR4->(! Eof() ) .AND. SR4->R4_ANO == mv_par08 .AND. SR4->R4_CPFCGC == _CPFCGC .AND. SR4->R4_CODRET == cCodPLR
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Consiste controle de acessos                                 ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If !(SR4->R4_FILIAL $ fValidFil()) ////.Or. !Eval(cAcessaSR4)
				SR4->(dbSkip())
				Loop
			EndIf 
			If l1Vez
				chkAtivo(@cFil_MAT)
			   	l1Vez := .F.
			EndIf	      
			nLetra := Ascan(aLetraPLR, Alltrim(SR4->R4_TIPOREN))
			If nLetra > 0
				aTotPLR[nLetra] += NoRound(SR4->R4_VALOR,2)
			Endif
			dbSelectArea("SR4")
			SR4->( dbSkip())
		Enddo
	EndIf
		
	////// PENSAO ALIMENTICIA
					
	nOrdem := RetOrder( "SM8" , "M8_FILIAL+M8_MAT+M8_CODFOR+M8_CODRET+M8_ANO+M8_MES+M8_TIPOREN" , .T. )
	//SM8->( dbSetOrder( nOrdem )	)
	SM8->( dbSetOrder( 2 )	)
	SM8->( dbSeek ( xFilial("SM8")+_MAT+"0561"+ mv_par08 ) )
	
	While SM8->(! Eof() ) .AND. SM8->M8_MAT == _MAT .AND. SM8->M8_ANO == mv_par08 .AND. SM8->M8_CODRET == "0561"
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Consiste controle de acessos                                 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If !(SM8->M8_FILIAL $ fValidFil()) ///.Or. !Eval(cAcessaSR4)
			SR4->(dbSkip())
			Loop
		EndIf 
	    If l1Vez
	    	chkAtivo(@cFil_MAT)
	    	l1Vez := .F.
	    EndIf	      
		nLetra := Ascan(aLetra, Alltrim(SM8->M8_TIPOREN))
	   	If nLetra > 0
	       aTotLetra[nLetra] += NoRound(SM8->M8_VALOR,2)
	   	Endif
		nCODFOR := SM8->M8_CPFBEN
	   	dbSelectArea("SM8")
		SM8->( dbSkip())
	Enddo

	////////BENEFICIARIO
	nOrdem := RetOrder( "SRQ" , "RQ_FILIAL+RQ_MAT+RQ_ORDEM+RQ_SEQUENC" , .T. )
	SRQ->( dbSetOrder( nOrdem )	)
	IF SRQ->( dbSeek ( xFilial("SRQ")+_MAT+"01"+ "01" ) )
		nCNPJFOR :=	SRQ->RQ_CIC
		nNOMEFOR := SRQ->RQ_NOME
       	CDESC := ALLTRIM(nNOMEFOR)+" PENS√O ALIMENTICIA JUDICIAL "+" CPF: "+ALLTRIM(NCNPJFOR)
       	CDESC := ALLTRIM(CDESC)     	
		aAdd(aComplem,{ cDesc, aTotLetra[nLetra], cChave, nPrioridad }) 
	ENDIF
	///PREVIDENCIA PRIVADA
	nOrdem := RetOrder( "SM9" , "M9_FILIAL+M9_MAT+M9_CODFOR+M9_CODRET+M9_ANO+M9_MES+M9_TIPOREN" , .T. )
	SM9->( dbSetOrder( nOrdem )	)
	SM9->( dbSeek ( xFilial("SM9")+_MAT+"01"+ "0561" + mv_par08 ) )
	While SM9->(! Eof() ) .AND. SM9->M9_MAT == _MAT .AND. SM9->M9_ANO == mv_par08 .AND. SM9->M9_CODRET == "0561"
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Consiste controle de acessos                                 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If !(SM9->M9_FILIAL $ fValidFil()) ///.Or. !Eval(cAcessaSR4)
			SR4->(dbSkip())
			Loop
		EndIf 
		If l1Vez
		   	chkAtivo(@cFil_MAT)
		   	l1Vez := .F.
		EndIf	      
		nLetra := Ascan(aLetra, Alltrim(SM9->M9_TIPOREN))
		If nLetra > 0
			aTotLetra[nLetra] += NoRound(SM9->M9_VALOR,2)
		Endif
		nCODFOR := SM9->M9_CODFOR
		dbSelectArea("SM9")
		SM9->( dbSkip())
	Enddo
	nLINHA := FPOSTAB("S073",nCODFOR,"==",4)
	IF nLINHA > 0
		nCNPJFOR := FTABELA("S073",NLINHA,5)
		nNOMEFOR := FTABELA("S073",NLINHA,6)
	   	CDESC := ALLTRIM(nNOMEFOR)+" CONTRIBUI«√O ¿ PREVIDENCIA PRIVADA "+" CNPJ: "+ALLTRIM(NCNPJFOR)
	   	CDESC := ALLTRIM(CDESC)     	
		aAdd(aComplem,{ cDesc, aTotLetra[nLetra], cChave, nPrioridad }) 
	ENDIF 
/////////
			dbSelectArea("RCS")
					
			////RCS->( dbSeek( REN->RL_FILIAL+REN->RL_MAT+REN->RL_TIPOFJ+REN->RL_CPFCGC+REN->RL_CODRET+mv_par08 ) )

			IF RCS->( dbSeek( xFilial("SRL")+_MAT+cTpInsc+_CPFCGC+"0561"+mv_par08 ) )

		
				cCNPJoLD 	:= ""
				cRCSFilial 	:= Replicate("!", FwGetTamFilial)
			
				While RCS->(! Eof() ) .AND. RCS->RCS_ANO == mv_par08 .AND. RCS->RCS_CPFBEN == _CPFCGC .and. lEntra 
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ Consiste controle de acessos                                 ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		
					If !(RCS->RCS_FILIAL $ fValidFil()) 
						RCS->(dbSkip())
						Loop
					EndIf 
						
					/*If (RCS->RCS_FILIAL # _filia ) 
						If cRCSFilial # RCS->RCS_FILIAL
							dbSelectArea("SRL")
							aArea	:= GetArea()       
							//REN->( dbSetOrder(1) )
							cCNPJoLD 	:= _CPFCGC   ////REN->RL_CGCFONT
							cRCSFilial 	:= RCS->RCS_FILIAL
							REN->(dbSeek(RCS->RCS_FILIAL+RCS->RCS_MAT))
							//If REN->RL_CGCFONT # cCNPJoLD
							If _CPFCGC # cCNPJoLD
								lCentra := .F.
								RCS->( dbSkip() )
								RestArea(aArea)
								Loop
							EndIf   	
								RestArea(aArea)
						ElseIf !lCentra
							RCS->( dbSkip() )
							Loop
						EndIf
					EndIf*/	
						
					nLinhas++    
					If !empty(RCS->RCS_NOME) .and. ( EMPTY(RCS->RCS_OUTROS) .OR. AllTrim(RCS->RCS_TIPORE) == "R")
						If RCS->RCS_VALOR # 0                                                                 
					
							cChave := RCS->RCS_CPFCGC+RCS->RCS_TIPORE+RCS->RCS_OUTROS+RCS->RCS_VERBA
							nPos := Ascan( aComplem,{ |X| X[3]==cChave .and. X[2]> 0 })                                                         
					
							If nPos > 0
								aComplem[nPos,2] += RCS->RCS_VALOR
								RCS->(dbSkip())   
								LOOP
							EndIf	 
					
							cDesc := AllTrim( RCS->RCS_DESCRI )
					
							// Define a prioridade de impressao das informacoes complementares dependendo do tipo de retencao da verba
							If Alltrim( RCS->RCS_TIPORES ) $ "W#2"
								nPrioridad := 1
							ElseIf Alltrim( RCS->RCS_TIPORES ) $ "C#C1"
								nPrioridad := 2
								cDesc += Space(2) + Transform( RCS->RCS_CPFCGC, If( Len(AllTrim(RCS->RCS_CPFCGC)) == 11, "@R 999.999.999-99", "@R 99.999.999/9999-99" ) )
							ElseIf Alltrim( RCS->RCS_TIPORES ) $ "R" .And. ! "REEMBOLSO" $ RCS->RCS_OUTROS 
								nPrioridad := 3
							ElseIf Alltrim( RCS->RCS_TIPORES ) $ "R" .And. "REEMBOLSO" $ RCS->RCS_OUTROS 
								nPrioridad := 4
							Else
								nPrioridad := 5
							EndIf
					        if len(alltrim(cDesc)) > 0
								aAdd(aComplem,{ cDesc, RCS->RCS_VALOR, cChave, nPrioridad })
					        endif
							nItem++
						ElseIf Alltrim(RCS->RCS_TIPORE) # "R"
							aAdd( aComplem, { SPACE(04) + RCS->RCS_NOME +space(23), 0, "", 9 } )
						Endif               
					EndIf
							
					If !EMPTY(RCS->RCS_OUTROS) .and. AllTrim(RCS->RCS_TIPORE) <> "R"
						cDescOred += If(!empty(alltrim(cDescOred)),", ","")+ alltrim(RCS->RCS_OUTROS)
					EndIf
					RCS->(dbSkip()	)
				EndDo
            ENDIF

////////
	nTotRend 	:= aTotLetra[01]
	nTotRetido	:= aTotLetra[06] + aTotLetra[23] + aTotLetra[19] + aTotLetra[44]
	nLiq13o 	:= (aTotLetra[14] - aTotLetra[15] - aTotLetra[16]) - aTotLetra[24] - aTotLetra[28]
	nLiq13o 	:= nLiq13o - aTotLetra[33] - aTotLetra[34] - aTotLetra[35] - aTotLetra[36] - aTotLetra[45]
	nTotOutros	:= ( aTotLetra[17] - aTotLetra[46] ) + ( aTotPLR[1] - aTotPLR[2] - aTotPLR[3] )

	fIrpfGraX()  //impress„o arquivos .pdf

   	ENVIO()      // envia arquivo

	nTotRend 	:= 0
	nTotRetido	:= 0
	nLiq13o 	:= 0
	nLiq13o 	:= 0
	nTotOutros	:= 0
 	Afill( aTotLetra , 0 )
	Afill( aTotPLR   , 0 )

	for i = 1 to len(aTotLetra)
		aTotLetra[i] := 0.00
	next i	

	for i = 1 to len(aTotPLR)
		aTotPLR[i] := 0.00
	next i	
    
		//RRP - 02/03/2017 - Final do Ajuste
		TEMP1->(DbSkip())
		cMatTemp:= TEMP1->RA_MAT
	EndDo


Return .T.


Static Function ENVIO()	

	local aAreaAnt := getArea()
	
	dbSelectArea("SRA")
	dbSetOrder(1)
	//If dbSeek(_cChave)
	If dbSeek(_cChave2)
	    cTexto		:= ALLTRIM(SRA->RA_SEXO)
	    cEmail		:= If(SRA->RA_RECMAIL=="S",SRA->RA_EMAIL,"    ")
	Else
	    cTexto		:= "" //"Codigo nao Cadastrado      "
	Endif

	//Conex„o com o Email -----------------------------------------------
	cSubject	:= "Informe de Rendimentos - "+ALLTRIM(cDescEmp)+" - "+cReferencia
	cTexto		:= ""
	cmailconta	:= AllTrim(GetMv("MV_RELFROM"))//"rh.holerites@hlb.com.br"   //// FROM
	If SRA->RA_SEXO == "M"
		cTexto := "<p>Prezado,<br>"
	ElseIf SRA->RA_SEXO == "F"
		cTexto := "<p>Prezada,<br>"
	EndIf
	cTexto += Capital(SRA->RA_NOME)+"</p>
	cTexto += "<p>Informamos a emiss„o do Informe de Rendimentos Ano calend·rio "+cReferencia+".</p>
	cTexto += "<br>"
	
	cTexto += "<p>"+ALLTRIM(GetMv("MV_P_00033",,"Em caso de d˙vidas, favor entrar em contato com o Departamento de RH."))+"</p>"
	
	cTexto += "<br>"
	cTexto += "<p>Este e-mail foi enviado automaticamente, favor n„o responder!"
	cTexto += "<br>Atenciosamente,</p>"
	
	oMessage			:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate		:= cValToChar(Date())
	oMessage:cFrom		:= cMailConta
	oMessage:cTo		:= cEmail
	oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
	oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"//responder para...
	oMessage:nXPriority := 2  //Prioridade do email(1 maxima...5 minima - 3 default)
	oMessage:cSubject	:= cSubject
	oMessage:cBody		:= cTexto
	
	CpyT2S(cDirGer+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".pdf","\SYSTEM\", .F. )
	
	//Caso seja tratado senha no arquivo
	If lSenha
		cCompl	:= STRZERO(DAY(SRA->RA_NASC),2)+RIGHT(SRA->RA_CIC,2)+STRZERO(YEAR(SRA->RA_NASC),4)
		cDica	:= ""
		If lCompl
			aAux	:= GetPass()
			cCompl	:= aAux[1]
			cDica	:= aAux[2]
		EndIf
		cArq2Zip := "\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)
		compacta(cArq2Zip+".pdf",cArq2Zip+".ZIP",.F.,cCompl)
		xRet := oMessage:AttachFile("\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".zip")
	Else
		xRet := oMessage:AttachFile("\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".pdf")
	EndIf
	
	If xRet < 0
		conout( "Could not attach file " + "Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+IIF(lSenha,".zip",".pdf") )
		lEnvioOK := .F.
	EndIf
	
	oServer				:= tMailManager():New()
	oServer:SetUseTLS( .T. )
	cUser				:= GETMV("MV_RELAUSR")
	cPass				:= GETMV("MV_RELAPSW")
	//AOA - 19/10/2017 - Alterado validaÁ„o para envio de e-mail
	If AT(":", cMailServer) > 0
		cMailServer := SUBSTR(cMailServer, 1, AT(":", cMailServer) - 1)
	EndIf   
	xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 587 )	
	If xRet != 0
		conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
		lEnvioOK := .F.
	EndIf
	xRet := oServer:SetSMTPTimeout( 60 )
	If xRet != 0
	    conout( "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout ) ) 
		lEnvioOK := .F.
	EndIf

	xRet := oServer:SMTPConnect()  
	If xRet <> 0
		conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
		lEnvioOK := .F.
	EndIf

	xRet := oServer:SmtpAuth( cUser, cPass )   
	If xRet <> 0
	    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
	    lEnvioOK := .F.
	    oServer:SMTPDisconnect()
	EndIf      
	//Envio
	xRet := oMessage:Send( oServer )   
	If xRet <> 0
	    cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
	    lEnvioOK := .F.
	EndIf
	//Encerra
	xRet := oServer:SMTPDisconnect()   
	If xRet <> 0
	    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
	    lEnvioOK := .F.
	EndIf
	//Apaga os arquivos criados
	If File("\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".pdf")
		FErase("\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".pdf")
	EndIf
	If File("\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".zip")
		FErase("\SYSTEM\"+"Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(SRA->RA_MAT)+alltrim(mv_par08)+".zip")
	EndIf
	
	//Possibilidade de impress„o do padr„o em caso de erro.
	If !lEnvioOK                      
		Return !MsgYesNo("N„o foi possivel a geraÁ„o de email customizado, deseja enviar a vers„o padr„o?","HLB BRASIL")
	ElseIf lSenha .and. lCompl
		cSubject	:= "Senha Informe - "+ALLTRIM(cDescEmp)+" - "+cReferencia
		cTexto		:= ""
		cTexto		:= ""
		If SRA->RA_SEXO == "M"
			cTexto := "<p>Prezado,<br>"
		ElseIf SRA->RA_SEXO == "F"
			cTexto := "<p>Prezada,<br>"
		EndIf
		cTexto += Capital(SRA->RA_NOME)+"</p>
		cTexto += "<p>Informamos que a emiss„o do Informe de Rendimentos "+cReferencia+" foi realizada.</p>
		cTexto += "<br>"                                                                                       
		cTexto += "<p>Abaixo segue a regra para a senha de acesso ao Informe de Rendimentos:</p>
		cTexto += cDica
		cTexto += "<p>"+ALLTRIM(GetMv("MV_P_00033",,"Em caso de d˙vidas, favor entrar em contato com o Departamento de RH."))+"</p>"
		cTexto += "<br>"
		cTexto += "<p>Este e-mail foi enviado automaticamente, favor n„o responder!"
		cTexto += "<br>Atenciosamente,</p>"
	
		oMessage			:= TMailMessage():New()
		oMessage:Clear()
		oMessage:cDate		:= cValToChar(Date())
		oMessage:cFrom		:= cMailConta
		oMessage:cTo		:= cEmail
		oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
		oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"     //responder para...
		oMessage:nXPriority := 2    //Prioridade do email(1 maxima...5 minima - 3 default)
		oMessage:cSubject	:= cSubject
		oMessage:cBody		:= cTexto	

		oServer				:= tMailManager():New()
		oServer:SetUseTLS( .T. )
		cUser				:= GETMV("MV_RELACNT")
		cPass				:= GETMV("MV_RELAPSW")   
		xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 587 )
		
		If xRet != 0
			conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
			lEnvioOK := .F.
		EndIf
		xRet := oServer:SetSMTPTimeout( 60 )
		If xRet != 0
		    conout( "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout ) ) 
			lEnvioOK := .F.
		EndIf
		xRet := oServer:SMTPConnect()
		If xRet <> 0
			conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
			lEnvioOK := .F.
		EndIf
		xRet := oServer:SmtpAuth( cUser, cPass )
		If xRet <> 0
		    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
		    lEnvioOK := .F.
		    oServer:SMTPDisconnect()
		EndIf      
		//Envio
		xRet := oMessage:Send( oServer )
		If xRet <> 0
		    cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		    lEnvioOK := .F.
		EndIf
		//Encerra
		xRet := oServer:SMTPDisconnect()
		If xRet <> 0
		    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
		    lEnvioOK := .F.
		EndIf
	ElseIf lSenha .and. !lCompl
		cSubject	:= "Senha Informe - "+ALLTRIM(cDescEmp)+" - "+cReferencia
		cTexto		:= ""
		cTexto		:= ""
		If SRA->RA_SEXO == "M"
			cTexto := "<p>Prezado,<br>"
		ElseIf SRA->RA_SEXO == "F"
			cTexto := "<p>Prezada,<br>"
		EndIf
		cTexto += Capital(SRA->RA_NOME)+"</p>
		cTexto += "<p>Informamos que a emiss„o do Informe de Rendimentos "+cReferencia+" foi realizada.</p>
		cTexto += "<br>"                                                                                       
		cTexto += "<p>Abaixo segue a regra para a senha de acesso ao Informe de Rendimentos:</p>
		cTexto += "<br>-> A senha ÅEformada pelo Dia do seu Aniversario(DD) + 2 ultimos Digito do seu CPF(NN) + Ano do Seu Aniversario(AAAA) = (DDNNAAAA)</p>"
		cTexto += "<p>"+ALLTRIM(GetMv("MV_P_00033",,"Em caso de d˙vidas, favor entrar em contato com o Departamento de RH."))+"</p>"
		cTexto += "<br>"
		cTexto += "<p>Este e-mail foi enviado automaticamente, favor n„o responder!"
		cTexto += "<br>Atenciosamente,</p>"

		oMessage			:= TMailMessage():New()
		oMessage:Clear()
		oMessage:cDate		:= cValToChar(Date())
		oMessage:cFrom		:= cMailConta
		oMessage:cTo		:= cEmail
		oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
		oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"     //responder para...
		oMessage:nXPriority := 2    //Prioridade do email(1 maxima...5 minima - 3 default)
		oMessage:cSubject	:= cSubject
		oMessage:cBody		:= cTexto	
		
		oServer				:= tMailManager():New()
		oServer:SetUseTLS( .T. )
		cUser				:= GETMV("MV_RELACNT")
		cPass				:= GETMV("MV_RELAPSW")   

		xRet := oServer:Init( "", cMailServer, cUser, cPass, 0, 587 )
		
		If xRet != 0
			conout( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
			lEnvioOK := .F.
		EndIf
		xRet := oServer:SetSMTPTimeout( 60 )
		If xRet != 0
		    conout( "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout ) ) 
			lEnvioOK := .F.
		EndIf
		xRet := oServer:SMTPConnect()
		If xRet <> 0
			conout( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
			lEnvioOK := .F.
		EndIf
		xRet := oServer:SmtpAuth( cUser, cPass )
		If xRet <> 0
		    conout( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
		    lEnvioOK := .F.
		    oServer:SMTPDisconnect()
		EndIf      
		//Envio
		xRet := oMessage:Send( oServer )
		If xRet <> 0
		    cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		    lEnvioOK := .F.
		EndIf
		//Encerra
		xRet := oServer:SMTPDisconnect()
		If xRet <> 0
		    conout("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
		    lEnvioOK := .F.
		EndIf
	
	EndIf
	
	RESTAREA(aAreaAnt)
	
RETURN	
	

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : FunÁ„o para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri,cSenha)
*---------------------------------------------------------*
	Local lRet		:=.F.
	Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
	Local cCommand 	:= ""
	Local lWait  	:= .T.
	Local cPath     := "C:\Program Files (x86)\WinRAR\"
	
	Default lApagaOri := .T.
	Default cSenha := ""
	
	If lApagaOri
		cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ '+IIF(!EMPTY(cSenha),"-hp"+cSenha,"")+' "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
	Else
		cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ '+IIF(!EMPTY(cSenha),"-hp"+cSenha,"")+' "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
	EndIf
	lRet := WaitRunSrv( cCommand , lWait , cPath )
	
Return(lRet)


/*
Funcao      : GetPass
Parametros  : 
Retorno     : aRet
				[1]	Senha
				[2] Dica da senha
Objetivos   : FunÁ„o para criaÁ„o da senha com complexidade alta e tratamento de dica.
Autor       : Jean Victor Rocha
Data/Hora   : 04/09/2015
*/

*-----------------------*
Static Function GetPass()
*-----------------------*
	Local aRet := {}
	Local i
	Local aPass := {}
	
	Local cEspecial := ""
	Local nPos		:= 0
	Local cPassRet := ""
	Local cDicaRet := ""
	
	Local aVarC := {	{SubStr(ALLTRIM(SRA->RA_NOME),1,1)	," - Primeira letra do seu primeiro nome em "			,"C"},;//1
						{SubStr(ALLTRIM(SRA->RA_PAI),1,1)	," - Primeira letra do primeiro nome do seu Pai em "	,"C"},;//2
						{SubStr(ALLTRIM(SRA->RA_MAE),1,1)	," - Primeira letra do primeiro nome da sua M„e em "	,"C"},;//3
						{SubStr(ALLTRIM(SRA->RA_NOME),2,1)	," - Segunda letra do seu primeiro nome em " 			,"C"},;//4
						{SubStr(ALLTRIM(SRA->RA_NOME),3,1)	," - Terceira letra do seu primeiro nome em "  			,"C"}} //5
	                                                                                                                  
	Local aVarN := {	{SubStr(ALLTRIM(DTOS(SRA->RA_ADMISSA)),3,2)	," - Ano de Admiss„o (AA)."			   	   		,"N"},;//1
						{RIGHT(ALLTRIM(SRA->RA_CIC),2)				," - Digito do seu CPF (dois ultimos numeros)."	,"N"},;//2
						{SubStr(ALLTRIM(DTOS(SRA->RA_NASC   )),3,2)	," - Ano de nascimento (AA)."					,"N"},;//3
						{SubStr(ALLTRIM(DTOS(SRA->RA_NASC   )),5,2)	," - Mes de nascimento (MM)." 				  	,"N"},;//4
						{SubStr(ALLTRIM(DTOS(SRA->RA_NASC   )),7,2)	," - Dia de nascimento (DD)."  					,"N"}} //5
	
	Local aVarEsp := {"!","@","#","$","%","&","(",")","-","+","="}
	
	//Retira os campos em branco
	i := 1
	While LEN(aVarC) > 0 .AND. i <= LEN(aVarC)
		If EMPTY(aVarC[i][1])
			aDel(aVarC,i)
			aSize(aVarC,Len(aVarC)-1)
			i := 0
		EndIf
		i++
	EndDo
	i := 1
	While LEN(aVarN) > 0 .AND. i <= LEN(aVarN)
		If EMPTY(aVarN[i][1])
			aDel(aVarN,i)
			aSize(aVarN,Len(aVarN)-1)
			i := 0
		EndIf
		i++
	EndDo

	If Len(aVarC) == 0 .Or. Len(aVarN) == 0
		Return {"",""}
	EndIf
	
	//Captura das variaveis que ser„o utilizadas.
	//Estava guardando a referencia das variaveis, foi necessario jogar em uma variavel e depois atribuir.
	/*aAdd(aPass,aVarC[	Randomize(1,LEN(aVarC)+1)	])
	aAdd(aPass,aVarC[	Randomize(1,LEN(aVarC)+1)	])
	aAdd(aPass,aVarN[	Randomize(1,LEN(aVarN)+1)	])
	aAdd(aPass,aVarN[	Randomize(1,LEN(aVarN)+1)	])
	aAdd(aPass,{cEspecial," - Caracter especial '"+cEspecial+"'","E"}) */
	
	cAux1 := ""
	cAux2 := ""
	cAux3 := ""      
	aPass := {}                              
	//C 1
	nPos := Randomize(1,LEN(aVarC)+1)
	cAux1 := UPPER(aVarC[nPos][1])
	cAux2 := aVarC[nPos][2] + "maiuscula."
	cAux3 := aVarC[nPos][3]
	aAdd(aPass,{cAux1,cAux2,cAux3})
	//C 2
	nPos := Randomize(1,LEN(aVarC)+1)
	cAux1 := LOWER(aVarC[nPos][1])
	cAux2 := aVarC[nPos][2] + "minuscula."
	cAux3 := aVarC[nPos][3]
	aAdd(aPass,{cAux1,cAux2,cAux3})  
	//N 3
	nPos := Randomize(1,LEN(aVarN)+1)
	cAux1 := aVarN[nPos][1]
	cAux2 := aVarN[nPos][2]
	cAux3 := aVarN[nPos][3]
	aAdd(aPass,{cAux1,cAux2,cAux3})
	//N 4
	nPos := Randomize(1,LEN(aVarN)+1)
	cAux1 := aVarN[nPos][1]
	cAux2 := aVarN[nPos][2]
	cAux3 := aVarN[nPos][3]
	aAdd(aPass,{cAux1,cAux2,cAux3})
	//E 5
	cEspecial := aVarEsp[Randomize(1,LEN(aVarEsp)+1)]
	aAdd(aPass,{cEspecial," - Caracter especial '"+cEspecial+"'","E"})
	
	//Troca da primeira posiÁ„o em Maiuscula e 2™ em minuscula.
	/*aPass[1][1] := UPPER(aPass[1][1])
	aPass[2][1] := LOWER(aPass[2][1])
	aPass[1][2] += "maiuscula."
	aPass[2][2] += "minuscula."
	*/                    
	//CriaÁ„o da senha e da Dica
	cPass := ""
	cDica := "<p>"
	
	While Len(aPass) >= 1
		nPos := Randomize(1,Len(aPass)+1)
	
		cPass += aPass[nPos][1]
		cDica += ALLTRIM(aPass[nPos][2])+"<br/>"+CHR(13)+CHR(10)
		aDel(aPass,nPos)
		aSize(aPass,Len(aPass)-1)
	EndDo
	cDica += "</p>"
	aAdd(aRet,cPass)
	aAdd(aRet,cDica)
	
Return aRet 


//Inicia a Impress„o do Arquivo PDF.
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fIrpfGraX ∫Autor  ≥Microsiga           ∫ Data ≥  02/05/02   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Impressao Comprovante de rendimentos e retencao do Imp.Renda∫±±
±±∫          ≥Fonte - Formulario Grafico                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico                                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function  fIrpfGraX()

	Private cFileFaz	:= ""
	Private cStartPath:= GetSrvProfString("Startpath","")
	//Private cStartPath := "C:\aa\"
	Private N 		:= 0     
	Private lExigi	:= .F.
	Private nx		:= 1
	Private nTamImp	:= 80
	Private nRRa		:= 0
	Private nTotRRA	:= Max(If(lUsaRRA,Len(aTotRRA),1),1)

	Private oMessage

	PRIVATE lAdjustToLegacy := .T.
	PRIVATE lDisableSetup  := .T.

	Private oInfRen

	oInfRen:=FWMSPrinter():New("Informe_"+alltrim(cEmpAnt)+alltrim(cFilAnt)+alltrim(_MAT)+alltrim(mv_par08),IMP_PDF,lAdjustToLegacy,,lDisableSetup,,,,,,,.F.)
	oInfRen:SetResolution(72)
	oInfRen:SetPortrait()
	oInfRen:SetPaperSize(9) 
	oInfRen:SetMargin(05,05,05,05) 			 
	oInfRen:cPathPDF := cDirGer
	oInfRen:StartPage()


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


	/*⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	  ≥Cabecalho                                                     ≥
	  ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ*/
	
	cFileFaz 	:= cStartPath+ "RECEITA" + ".BMP" 		// Empresa+Filial

	//cFileFaz 	:=  UPPER(cFileFaz)

	If lUsaRRA
		lImpRRA := !Empty(aTotRRA)
	Else
		lImpRRA	:= .F.
	EndIf

	nLin := 030    
	nLinI:= 030    
	//⁄ƒƒƒƒƒƒƒƒƒø
	//≥Cabecalho≥
	//¿ƒƒƒƒƒƒƒƒƒŸ
	nLin +=20    
	oInfRen:Box( nLinI,0030,nLin+255,2350)  				// box Cabecalho 
	oInfRen:Line(nLinI,1450,nLin+255,1450)				// Linha Div.Cabecalho
	If File(cFileFaz)
		oInfRen:SayBitmap(nLinI+10,050, cFileFaz,235,195) // Tem que estar abaixo do RootPath
	Endif
	nLin +=20  
	oInfRen:say(nLin,500 ,STR0036,oFont13n)				//	ministerio da fazenda 
	oInfRen:Say(nLin,1500,STR0038,oFont10)				//Comprovante de rendimento
	nLin +=50 
	oInfRen:say(nLin+10,500 ,STR0037,oFont10)			//secretaria de receita
	oInfRen:Say(nLin,1500,STR0039,oFont10)              //Retencao de rendimentos
	nLin +=50  
	oInfRen:Say(nLin,500,STR0094,oFont10n) 				//"IMPOSTO SOBRE A RENDA DA PESSOA FÕSICA"
	nLin +=50  
	oInfRen:say(nLin,650,STR0095,oFont10n)				//	" ( EXERCÕCIO " 
	oInfRen:Say(nLin,890,Soma1(mv_par08),oFont10n)    		  	//ano  calendario
	oInfRen:Say(nLin,985,")",ofont10) 
	oInfRen:Say(nLin,1560,STR0040,oFont10n) 				//ano base
	oInfRen:Say(nLin,1950,mv_par08,oFont10n)    		  	//ano  base
	oInfRen:Say(nLin,2035,")",ofont10) 
	 
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥1. Fonte pagadora≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	nLin += 160	 
	oInfRen:Say(nLin,040,STR0005,oFont12n) 			 	//"  1. - Fonte Pagadora Pessoa Juridica ou Pessoa Fisica"
	nLin +=60   
	nLinI:=nLin -10
	oInfRen:Box(nLinI ,0030,nLin + 120,2350)				//box
	oInfRen:Line(nLinI,430,nLin + 120,430)
	
	oInfRen:Say(nLIn,040,STR0042,ofont08) 				//Nome  empresarial
	oInfRen:Say(nLin,440,STR0041,oFont08)				//CPF/CNPJ
	nLin+=50  
	oInfRen:Say(nLin,050,PADR(cCgc,100),oFont10)
	oInfRen:Say(nLin,450,PADR(cDesEmp,100),oFont10)
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥2. Pessoa fisica/benefic.≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nLin+=100 
	If !empty(cFil_Mat)
		oInfRen:Say(nLin,040, STR0011+PADL((cFil_Mat),29), oFont12n) 							//"  2. - PESSOA FISICA BENEFICIARIA DOS RENDIMENTOS "
	Else
		If REN->(FieldPos("RL_CC"))== 0
			oInfRen:Say(nLin,040, STR0011+PADL((REN->RL_FILIAL+"-"+REN->RL_MAT),29), oFont12n) 							//"  2. - PESSOA FISICA BENEFICIARIA DOS RENDIMENTOS "
		Else
			oInfRen:Say(nLin,040, STR0011+PADL((REN->RL_FILIAL+"-"+REN->RL_MAT+"-"+REN->RL_CC),29), oFont12n)			     //"  2. - PESSOA FISICA BENEFICIARIA DOS RENDIMENTOS "
		EndIf
	EndIf
	
	nLin +=60  
	nLinI:=nLin - 10
	
	oInfRen:Box(nLinI,030,nLin+220,2350)						//box
	
	oInfRen:Say(nLin,040,STR0043,oFont08)								//cpf
	oInfRen:Say(nLin,440,STR0013,oFont08)        						//Nome  completo
	nLin +=50  
	oInfRen:Say(nLin,050,_CPFCGC ,oFont10)
	oInfRen:Say(nLin,450,PADR(_BENEFIC,140),oFont10)
	nLin +=50  
	oInfRen:Line(nLin,030,nLin,2350)									//Linha horizontal
	oInfRen:Line(nLinI,430,nLin,430)									//Linha vertical 
	nLin +=20   
	oInfRen:Say(nLin,040,STR0044,oFont08)								//Natureza do rendimento
	nLin +=30   
	oInfRen:Say(nLin,050,PADR(_CODRET + "-" + cDescRet,153),oFont10)
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥3. Rendimentos tributaveis/deducoes e irpf≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nLin +=100 
	oInfRen:say(nLin,0040,left(STR0015,50),oFont12n)										//"  3. - Rendimentos Tributaveis, Deducoes e Imposto Retido na Fonte"
	oInfRen:Say(nLIn,1950,STR0050,oFont10n)
	
	nLin +=60 
	nLinI:=nLin -10
	oInfRen:Box(nLinI ,0030,nLin + 400,2350)													//box
	oInfRen:Line(nLinI,1900,nLin + 400,1900)
	
	nLin +=15
	oInfRen:Say(nLin,0040,STR0045,oFont10)											//1.Total de rendimentos(+ferias)
	oInfRen:Say(nLin,2000,Transform(Round(nTotRend,2),"@E 99,999,999.99"),oFont12) 	//"| 01. Total dos Rendimentos (Inclusive Ferias)"
	nLin+=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin+=30
	oInfRen:say(nLin,0040,STR0046,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(aTotLetra[02],2),"@E 99,999,999.99"), oFont12)	//"| 02. Contribuicao Previdenciaria Oficial "
	
	nLin +=50
	oInfRen:Line(nLin,030, nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0047,oFont10)
	oInfRen:say(nLin,2000,Transform(Round(aTotLetra[03],2),"@E 99,999,999.99"),oFont12)		//"| 03. Contribuicao a Previdencia Privada"
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0048,ofont10)
	oInfRen:Say(nLin,2000,Transform(Round(aTotLetra[04],2),"@E 99,999,999.99"),oFont12)		//"| 04. Pensao Alimenticia (Informar Benefic. no Quadro 07)   "
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin+=30
	oInfRen:Say(nLin,0040,STR0049,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(nTotRetido,2),"@E 99,999,999.99"),oFont12)		//"| 05. Imposto Retido na Fonte"
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥4. Rendimentos Isentos e nao tributaveis≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nLin += 100
	oInfRen:Say(nLin,0040,left(STR0022,50),oFont12n)	   									//"  4. - Rendimentos Isentos e Nao Tributaveis"
	oInfRen:Say(nLIn,1950,STR0050,oFont10n)
	
	nLin +=60
	nLinI:=nLin -10
	oInfRen:Box(nLinI ,0030,nLin + 560,2350)
	oInfRen:Line(nLinI,1900,nLin + 560,1900)
	
	nLin +=10
	oInfRen:Say(nLin,0040,STR0052,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round((aTotLetra[08]+aTotLetra[43]),2),"@E 99,999,999.99"),oFont12)		//"| 01. Parte dos Proventos Aposentadoria,Reforma ou Pensao  "
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0053,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(aTotLetra[09],2),"@E 99,999,999.99"),oFont12)		//"| 02. Diarias e Ajudas de Custo  "
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0054,ofont10)
	oInfRen:Say(nLin,2000,Transform(Round((aTotLetra[10]+aTotLetra[42]),2),"@E 99,999,999.99"),oFont12)		//"| 03. Pensao, Prov.de Aposent.ou Reforma por Molestia Grave"
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0055,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(aTotLetra[11],2),"@E 99,999,999.99"),oFont12)		//"| 04. Lucro e Dividendo a partir de 1996 pago por PJ       "
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0056,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(aTotLetra[12],2),"@E 99,999,999.99"),oFont12)		//"| 05. Val.Pagos Tit./Soc.Micro-Emp. exceto Pro-Labore      "
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0051,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(aTotLetra[07],2),"@E 99,999,999.99"),oFont12)		//"| 06. Indenizacao por Rescisao Inc.a Tit.PDV e Acid.Trab.  "
	nLin +=50
	oInfRen:Line(nLin,030,nLin,2350)
	
	nLin +=30
	oInfRen:Say(nLin,0040,STR0057+"("+Subs(cDescOred,1,45)+")",oFont10)
	oInfRen:Say(nLin,2000,Transform(Round((aTotLetra[13]+aTotLetra[41]),2),"@E 99,999,999.99"),oFont12)		//"| 07. Outros                                               "
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥5.  Rendimentos sujeitos a tributacao exclusiva ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nLin +=100
	oInfRen:Say(nLin,0040,Left(STR0030,71),oFont12n)								  					//"  5. - Rendimentos Sujeitos a TributaÁ„o Exclusiva (rendimento l˙éuido)  R$"
	oInfRen:Say(nLIn,1950,STR0050,oFont10n)
	
	nLin +=60 
	nLinI:=nLin-10
	
	oInfRen:Box(nLinI ,0030,nLin+160,2350)
	oInfRen:Line(nLinI,1900,nLin+160,1900)
	
	nLin +=15
	oInfRen:Say(nLIn,0040,STR0058,oFont10)
	oInfRen:Say(nLin,2000,Transform(Round(nLiq13o,2),"@E 99,999,999.99") ,oFont12)			//"| 01. Decimo Terceiro Salario "
	nLin +=30
	oInfRen:Line(nLin,040,nLin,2350)

	nLin +=30
	oInfRen:Say(nLin,0040,"02. Imposto sobre a renda na fonte sobre 13∫ sal·rio",ofont10)
	oInfRen:Say(nLin,2000,Transform(Round((aTotLetra[16]),2),"@E 99,999,999.99"),oFont12)		//"| 02. Imposto sobre a renda na fonte sobre 13∫ sal·rio "	
	nLin +=30
	oInfRen:Line(nLin,040,nLin,2350)

	nLin +=30
	oInfRen:Say(nLin,0040,STR0059,ofont10)
	oInfRen:Say(nLin,2000,Transform(Round(nTotOutros,2),"@E 99,999,999.99"),oFont12)		//"| 03. Outros "
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥6. Rendimentos Recebidos Acumuladamente≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nLin += 100
	oInfRen:Say(nLin,0040,STR0068,oFont12n)		//"  6. - Rendimentos Recebidos Acumuladamente- Art. 12-A da Lei n∫7.713, de 1988 (sujeitos ÅEtributaÁ„o exclusiva)"
	
	For nRRA := 1 to nTotRRA
		If nRRA == 2
			oInfRen:EndPage() 			// Finaliza a pagina
			//-- CABECALHO 
			oInfRen:StartPage() 			// Inicia uma nova pagina
			nLin := 030
			nLinI:= 030
			nLin +=20
			
			oInfRen:Box( nLinI,0030,nLin+255,2350)  				// box Cabecalho 
			oInfRen:Line(nLinI,1450,nLin+255,1450)				// Linha Div.Cabecalho
			If File(cFileFaz)
				oInfRen:SayBitmap(nLinI+10,050, cFileFaz,235,195) // Tem que estar abaixo do RootPath
			EndIf
			
			nLin +=20
			oInfRen:say(nLin,500 ,STR0036,oFont13n)				//	ministerio da fazenda 
			oInfRen:Say(nLin,1500,STR0038,oFont10)				//Comprovante de rendimento
			nLin +=50
			oInfRen:say(nLin+10,500 ,STR0037,oFont10)			//secretaria de receita
			oInfRen:Say(nLin,1500,STR0039,oFont10)              //Retencao de rendimentos
			nLin +=50
			oInfRen:Say(nLin,500,STR0094,oFont10n) 				//"IMPOSTO SOBRE A RENDA DA PESSOA FÕSICA"
			nLin +=50
			oInfRen:say(nLin,650,STR0095,oFont10n)				//	" ( EXERCÕCIO "
			oInfRen:Say(nLin,890,Soma1(mv_par08),oFont10n)    		  	//ano  calendario
			oInfRen:Say(nLin,985,")",ofont10) 
			oInfRen:Say(nLin,1560,STR0040,oFont10n) 				//ano base
			oInfRen:Say(nLin,1950,mv_par08,oFont10n)    		  	//ano  base
			oInfRen:Say(nLin,2035,")",ofont10)
			nLin += 160 				
		Else
			If nRRA == 1
				nLin +=60
			Else
				nLin += 100
			EndIf
		EndIf
	
		nLinI:=nLin -10
		oInfRen:Box(nLinI ,0030,nLin + 140,1900)
		oInfRen:Line(nLinI,1900,nLin + 60,1900)
		oInfRen:Line(nLinI,1150,nLin + 60,1150)
		oInfRen:Line(nLinI,1550,nLin + 60,1550)
		oInfRen:Say(nLin+80,1950,STR0050,oFont10n)
	
		nLin +=10
		oInfRen:Say(nLin,0040,"6." + AllTrim(Str(nRRA)) + " " + STR0097 + If(lImpRRA,PADR(aTotRRA[nRRA,2],30),Space(30)) ,oFont10)	//"6.1 N˙mero do processo: "
		oInfRen:Say(nLin,1175,STR0081,oFont10)	//"Quantidade de meses: "
		oInfRen:Say(nLin,1650,Transform(If(lImpRRA,aTotRRA[nRRA,4],0.00),"@E 99,999,999.99"),oFont12)		
		nLin +=50
		oInfRen:Line(nLin,030,nLin,1900)
	
		nLin +=30
		oInfRen:Say(nLin,0040,STR0082 + If(lImpRRA,PADR(aTotRRA[nRRA,3]+"-"+cDescRRA,53),Space(53)) ,oFont10)//"Natureza do atendimento: "
		nLin +=50
		oInfRen:Line(nLin,030,nLin,1900)
		
		nLin +=60
		nLinI:=nLin -10
		oInfRen:Box(nLinI ,0030,nLin + 500,2350)
		oInfRen:Line(nLinI,1900,nLin + 500,1900)	
		
		nLin +=10
		oInfRen:Say(nLin,0040,STR0083,oFont10)	//"01. Total dos rendimentos tribut·veis (inclusive fÈrias e dÈcimo terceiro sal·rio)"
		oInfRen:Say(nLin,2000,Transform(If(lImpRRA,aTotRRA[nRRA,5,1],0.00),"@E 99,999,999.99"),oFont12)	
		nLin +=50
		oInfRen:Line(nLin,030,nLin,2350)
		
		nLin +=30
		oInfRen:Say(nLin,0040,STR0084,oFont10)//" 02. Exclus„o: Despesas com aÁ„o judicial"
		oInfRen:Say(nLin,2000,Transform(If(lImpRRA,aTotRRA[nRRA,5,3],0.00),"@E 99,999,999.99"),oFont12)		
		nLin +=50
		oInfRen:Line(nLin,030,nLin,2350)
		
		nLin +=30
		oInfRen:Say(nLin,0040,STR0085,ofont10)//" 03. DeduÁ„o: ContribuiÁ„o previdenci·ria oficial"
		oInfRen:Say(nLin,2000,Transform(If(lImpRRA,aTotRRA[nRRA,5,2],0.00),"@E 99,999,999.99"),oFont12)		
		nLin +=50
		oInfRen:Line(nLin,030,nLin,2350)
		
		nLin +=30
		oInfRen:Say(nLin,0040,STR0086,oFont10)//" 04. DeduÁ„o: Pens„o aliment. (preencher tambÈm quadro 7) "
		oInfRen:Say(nLin,2000,Transform(If(lImpRRA,aTotRRA[nRRA,5,4],0.00),"@E 99,999,999.99"),oFont12)		
		nLin +=50
		oInfRen:Line(nLin,030,nLin,2350)
		
		nLin +=30
		oInfRen:Say(nLin,0040,STR0087,oFont10)//" 05. Imposto sobre a renda retido na fonte                "
		oInfRen:Say(nLin,2000,Transform(If(lImpRRA,aTotRRA[nRRA,5,5],0.00),"@E 99,999,999.99"),oFont12)		
		nLin +=50
		oInfRen:Line(nLin,030,nLin,2350)
		
		nLin +=30
		oInfRen:Say(nLin,0040,STR0089,oFont10)//"06. Rendimentos isentos de pens„o, proventos de aposentadoria ou reforma por molÈstia grave ou aposentadoria"
		oInfRen:Say(nLin+30,0040,STR0090,oFont10)//"ou reforma por acidente em serviÁo" 
		oInfRen:Say(nLin,2000,Transform(If(lImpRRA,aTotRRA[nRRA,5,6],0.00),"@E 99,999,999.99"),oFont12)	
	Next nRRA
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥7. Informacoes complementares≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If nTotRRA > 1
		nLin += 100
	Else
		oInfRen:EndPage() 			// Finaliza a pagina
		//-- CABECALHO 
		oInfRen:StartPage() 			// Inicia uma nova pagina
		nLin := 030
		nLinI:= 030
		nLin +=20 
		oInfRen:Box( nLinI,0030,nLin+255,2350)  				// box Cabecalho 
		oInfRen:Line(nLinI,1450,nLin+255,1450)				// Linha Div.Cabecalho
		If File(cFileFaz)
			oInfRen:SayBitmap(nLinI+10,050, cFileFaz,235,195) // Tem que estar abaixo do RootPath
		Endif
		nLin +=20
		oInfRen:say(nLin,500 ,STR0036,oFont13n)				//	ministerio da fazenda 
		oInfRen:Say(nLin,1500,STR0038,oFont10)				//Comprovante de rendimento
		nLin +=50
		oInfRen:say(nLin+10,500 ,STR0037,oFont10)			//secretaria de receita
		oInfRen:Say(nLin,1500,STR0039,oFont10)              //Retencao de rendimentos
		nLin +=50
		oInfRen:Say(nLin,500,STR0094,oFont10n) 				//"IMPOSTO SOBRE A RENDA DA PESSOA FÕSICA"
		nLin +=50
		oInfRen:say(nLin,650,STR0095,oFont10n)				//	" ( EXERCÕCIO "
		oInfRen:Say(nLin,890,Soma1(mv_par08),oFont10n)    		  	//ano  calendario
		oInfRen:Say(nLin,985,")",ofont10) 
		oInfRen:Say(nLin,1560,STR0040,oFont10n) 				//ano base
		oInfRen:Say(nLin,1950,mv_par08,oFont10n)    		  	//ano  base
		oInfRen:Say(nLin,2035,")",ofont10) 
		nLin += 100
	EndIf

	If len( aComplem ) > 0       
		If Ascan(aComplem,{|x| Subs(x[3],15,1) == "W" .or. Subs(x[3],15,1) == "2"} ) > 0                          
			lExigi := .T.
		EndIf
		aEval(aComplem,{|| nLinhas += 110 })
	EndIF
	
	nLin += 60
	
	oInfRen:Say(nLin,0040,left(STR0033,50),oFont12n)	//"  7. - Informacoes Complementares                                        R$     "
	
	nLin   += 60
	nLinI  := nLin - 10
	nLin   += 10
	
	If Empty( aComplem )
		nLin+=230
		oInfRen:box(nLinI,0030,nLin ,2350) 
		oInfRen:line(nLinI,1900,nLin ,1900)
	Else 
//		aSort( aComplem,,,{ |x,y| x[4] < y[4] } )
	
		nLinhas += nLin + 40
	
		// Ajusta nLinhas dependendo da quantidade de quebra de linha por complemento
		aEval( aComplem, { |x| nLinhas += (40*(Int( Len( x[1] ) / nTamImp )+1)) } )
	
		oInfRen:box(nLinI,0030,nLinhas,2350)
		oInfRen:line(nLinI,1900,nLinhas,1900)
	
		If lExigi
		    oInfRen:say(nLin,0040,STR0064,oFont10)
	   	    nLin +=45
		    oInfRen:say(nLin,0040,STR0065,oFont10)
	   	    nLin +=45
		    oInfRen:say(nLin,0040,STR0066,oFont10)
			nLin += 45
		EndIf
	
		For n:= 1 to len( aComplem )
		    If Len( Alltrim( aComplem[n,1] ) ) > nTamImp
	
				// Quebra da informacao em mais linhas caso a descricao seja maior que nTamImp caracteres
				// Define quantidade de linhas para imprimir UMA inform. complementar
				nQtdeLin := ( Len( aComplem[n,1] ) / nTamImp )
	
				// Imprime a primeira parte com o contador de inform. complementares
			    oInfRen:say(nLin,0040,strzero(n,02)+". "+ Substr( aComplem[n,1], 1, nTamImp ), oFont10 )
	
				For nx := 1	to Int( nQtdeLin )
					if len(AllTrim( aComplem[n,1])) > 0
						nLin += 40
					    oInfRen:say(nLin,0100, Substr( aComplem[n,1], (nTamImp*nx)+1, nTamImp ), oFont10 )
				    endif
				Next nx
			Else
			    oInfRen:say(nLin,0040,strzero(n,02)+". "+ AllTrim( aComplem[n,1] ), oFont10 )
		    EndIf
	
		    oInfRen:Say(nLin,2000,TRANSFORM(aComplem[n,2],"@E 99,999,999.99"),oFont10)
		    nLin += 45
			oInfRen:line(nLinI,1900,nLin,1900)
			nLin += 25
		Next n 
	Endif
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥8. Responsavel pelas informacoes≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nLin 	:= If( Empty( aComplem ), nLin + 40, nLinhas + 40 )
	
	oInfRen:Say(nLin,0040,STR0034,ofont12n)			//"  8. - Responsavel Pelas Informacoes"
	nLin	+=50 
	oInfRen:Box(nLin,0030,nLin + 100,2350)
	oInfRen:Line(nLin,1300,nLin+ 100,1300)
	oInfRen:Line(nLin,1540,nLin+ 100,1540)
	
	nLin +=20
	oInfRen:say(nLin,0040,left(STR0041,4),oFont08)
	oInfRen:Say(nLin,1340,STR0060,oFont08)
	oInfRen:Say(nLin,1550,STR0061,oFont08)
	
	nLin += 30
	oInfRen:say(nLin,0050,cResponsa,ofont10)
	oInfRen:say(nLin,1340,DtoC(dDataBase),oFont10)
	
	nLin+=70
	oInfRen:say(nLin,0040,STR0091,oFont08)		// "Aprovado pela IN RFB n∫ 1.215, de 15 de dezembro de 2011."
	
	oInfRen:EndPage() 		// Finaliza a pagina
	
	oInfRen:Print()

	nLinhas := 0
	
Return

