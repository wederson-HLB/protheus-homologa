#INCLUDE "rwmake.ch"

/*
Funcao      : PADTES
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Padronizar TES para todas as empresas
Autor       : 
Data/Hora   : 22/11/2002
Obs         : 
Revisão     : Matheus Massarotto
Data/Hora   : 06/09/2012
Obs         : 
Módulo      : Generico.
*/

*------------------*
User Function PADTES
*------------------*

//@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "Padroniza TES para todas as Empresas"
//@ 001,005 TO 058,195
//@ 005,020 SAY oemtoansi("Padronização de Empresas para compartilhamento de TES !!!")
//@ 015,100 BUTTON "OK" SIZE 70,20 ACTION   Processa({|| _processa() },"Processando...")
// @ 015,020 SAY eNAO
//@ 035,100 BUTTON "SAIR" SIZE 70,20 ACTION CLOSE(oDlg2)
//ACTIVATE DIALOG oDlg2 CENTER
cEmpresas:=space(75)
lSX2:=lSX3:=lSXB:=lSX5:=.F.
@ 0,0 TO 240,600 DIALOG oDlg TITLE "Padronizacao Arquivos TES - CUIDADO!!!"

@ 05,10 TO 100,280

@ 15,040 SAY "Codigo Empresas"
@ 55,040 CHECKBOX "PROCESSA Arquivo SX2" var lSX2
@ 65,040 CHECKBOX "PROCESSA Arquivo SX3" var lSX3
@ 75,040 CHECKBOX "PROCESSA Arquivo SXb" var lSXB
@ 85,040 CHECKBOX "PROCESSA Arquivo SX5" var lSX5

@ 15,100 GET cEmpresas PICTURE "!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/!!/" size 150,150 //Valid Execute(Existe)

@ 65,250 BMPBUTTON TYPE 01 ACTION 	Processa({|| proctudo() },"Processando ...")
//U_PROCESSA()
@ 80,250 BMPBUTTON TYPE 02 ACTION Close(oDlg)

ACTIVATE DIALOG oDlg  CENTERED


Return


//////////////////////////////////////////////////////////
Static Function proctudo()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cString

//cEMPRESAS := "AR/19/69/I7/L9/AU/BN/F9/CG/I8/CM/BU/51/N7/U8/U7/12/H5/AT/E9/21/C8/AF/H3/64/H4/23/95/C6/86/A9/CE/R8/BX/33"
//cEMPRESAS := "BP/16/K3/BT/84/R2/AL/V7/BC/24/BE/X1/A2/AV/AI/V8/S2/Q7/J8/Q2/O6/CA/82/AE/28/X2/20/I4/94/"
//cEMPRESAS := "DA/DB/DC/DD/DI/DJ/DH/DE/DF/DG/"   // CAMPINAS
//cEMPRESAS := ALLTRIM(cEMPRESAS)
cTAM := (LEN(cEMPRESAS)/2)
cTAM1 := cTAM
cTAM2 := cTAM
cAREA := SPACE(6)
cDADOS := SPACE(10)
cNOVO := SPACE(35)
cPARA := SPACE(35)
cCOMP := STRZERO(MONTH(DDATABASE),2) + RIGHT(STRZERO(YEAR(DDATABASE),4),2)
aSTRUCT := {}
cARQARJ := SPACE(30)
cARQX2 := " "
cARQRM1 := " "
cARQRM2 := " "
_cIND_XI := " "
_cIND_XI1 := " "
_cIND_X2 := " "
_cKEY_XI := " "
_cKEY_XI1 := " "
_cKEY_X2 := " "
cCB := 0
cCN := 0
eNAO := {}

cEMPAT := SM0->M0_CODIGO

DBSELECTAREA("SM0")
dbSetOrder(1)
DBGOTOP()

// se nao digitar nada pergunta se processa todas
lTudo:=.f.
IF EMPTY(cEmpresas)
	If !(MsgYesNo("Não há Codigo Empresas Digitado!!!"+chr(13)+"PROCESSA TODAS EMPRESAS?",OemToAnsi("Pad. TES...")))  //hfp
		return
	endif
	lTudo:=.t.
endif

//dbgoto(39)

PROCREGUA(LASTREC())

WHILE .NOT. EOF()
 //	IF SM0->M0_CODIGO <= "E8"
//	   DBSKIP()
//	   LOOP
//	ENDIF   
	IncProc( 'EMPRESA: ' + SM0->M0_CODIGO + SM0->M0_NOME )
	
	if lTudo // processa todas empresas
		cEMPRESAS:=	SM0->M0_CODIGO
	endif
	IF SM0->M0_CODIGO <> cEMPAT .AND. (SM0->M0_CODIGO $ cEMPRESAS )   //cEMPAT //.AND. SM0->M0_CODIGO$"B5" //cEMPRESAS
		
		if lSX2
			cARQX2 := 'SX2' + SM0->M0_CODIGO + '0.DBF'
			
			IF xAbreAX2()   /// atualiza sx2
				Processa({|| _AtuSX2() },"Processando SX2 - "+SM0->M0_NOME+"...")
			ENDIF
		endif
		if lSX3
			cARQX3 := 'SX3' + SM0->M0_CODIGO + '0.DBF'
			IF xAbreAX3()
				// ATU. SX3
				Processa({|| _AtuSX3() },"Processando SX3 - "+SM0->M0_NOME+"...")
			ENDIF
		endif
		
		if lSXB
			cARQXB := 'SXB' + SM0->M0_CODIGO + '0.DBF'
			IF xAbreAXB()
				// ATU. SXB
				Processa({|| _AtuSXB() },"Processando SXB - "+SM0->M0_NOME+"...")
			ENDIF
		endif
		/////////////////******************************
		if lSX5
			cARQX5 := 'SX5' + SM0->M0_CODIGO + '0'    /// SEM O .DBF  É TOP SEU ORELHUDO
			IF xAbreAX5()
				// ATU. SXB
				Processa({|| _AtuSX5() },"Processando SX5 - "+ SM0->M0_CODIGO + SM0->M0_NOME)
			ENDIF
		endif
		
		/////////////////******************************
		
		//cARQX7 := 'SX7' + SM0->M0_CODIGO + '0.DBF'
		//IF xAbreAX7()
		//	_AtuSX7()   // ATU. SX7
		//ENDIF
		//else
		//	   alert ("nao processando  arquivo igual ao empfat")
	ENDIF
	DBSELECTAREA("SM0")
	DBSKIP()
ENDDO

Alert("Processo Finalizado!!!")
CLOSE(oDlg)
Return

/*
Static Function _fAbreArq()

dbUseArea(.T.,"TOPCONN",cARQRM,"COP",.T.,.F.)
lflag:=.f.

if select("COP")!=0
lflag:=.T.
ENDIF
return LFLAG

Static Function _fAbreArq1()

dbUseArea(.T.,,cARQRM1,"DIC",.T.,.F.)
lflag1:=.f.

if select("DIC")!=0
lflag1:=.T.
ENDIF
return LFLAG1
*/
Static Function xAbreAX2()

dbUseArea(.T.,,cARQX2,"AX2",.T.,.F.)
lflag2:=.f.

if select("AX2")!=0
	lflag2:=.T.
ENDIF
return(LFLAG2)

Static Function xAbreAX3()

dbUseArea(.T.,,cARQX3,"AX3",.T.,.F.)
lflag3:=.f.

if select("AX3")!=0
	lflag3:=.T.
ENDIF
return(LFLAG3)
////////////***************************************************
Static Function xAbreAXB()

dbUseArea(.T.,,cARQXB,"AXB",.T.,.F.)
lflagB:=.f.

if select("AXB")!=0
	lflagB:=.T.
ENDIF
return(LFLAGB)
////////////***************************************************
Static Function xAbreAX5()

dbUseArea(.T.,"TOPCONN",cARQX5,"AX5",.T.,.F.)

lflagB:=.f.

if select("AX5")!=0
	lflagB:=.T.
ENDIF
return(LFLAGB)
////////////***************************************************

Static Function xAbreAX7()

dbUseArea(.T.,,cARQX7,"AX7",.T.,.F.)
lflag7:=.f.

if select("AX7")!=0
	lflag7:=.T.
ENDIF
return(LFLAG7)

/////////////////////////////////////////////
//////////////////////////////////////
/////////////////////////////
/////////////////
static function _AtuSx2
_cKey_x2 := "X2_CHAVE"
_cInd_x2 := CriaTrab(Nil,.f.)
INDREGUA("AX2",_cInd_X2,_cKey_X2,,,"ARQUIVOS  " + cARQX2)
dbGotop()
// IncProc( 'Processando: ' + cARQX2 + SM0->M0_NOME )
dbSelectArea("AX2")
dbSetOrder(1)
dbgotop()

// COMPARTILHA sf4
IF DBSEEK("SF4")
	reclock("AX2",.F.)
	X2_PATH := "\DADOSADV\YY\"
	X2_ARQUIVO := "SF4YY0"
	X2_MODO := "C"
	MSUNLOCK()
ELSE
	reclock("AX2",.T.)
	X2_PATH := "\DADOSADV\YY\"
	X2_ARQUIVO := "SF4YY0"
	X2_MODO := "C"
	MSUNLOCK()
ENDIF
// COMPARTILHA sm4
IF DBSEEK("SM4")
	reclock("AX2",.F.)
	X2_PATH := "\DADOSADV\YY\"
	X2_ARQUIVO := "SM4YY0"
	X2_MODO := "C"
	MSUNLOCK()
ELSE
	reclock("AX2",.T.)
	X2_PATH := "\DADOSADV\YY\"
	X2_ARQUIVO := "SM4YY0"
	X2_MODO := "C"
	MSUNLOCK()
ENDIF


// INCLUI SZ2    Arquivo para compartilhamento de TES
IF DBSEEK("SZ2")
	
	//TIRAR
	//DBSELECTAREA("AX2")
	//Ferase(_cInd_X2+OrdBagExt())
	//dbCloseArea()
	//return
	
	reclock("AX2",.F.)
	X2_CHAVE := "SZ2"
	X2_PATH := "\DADOSADV\YY\"
	X2_ARQUIVO := "SZ2YY0"
	X2_MODO := "C"
	X2_TTS := "N"
	MSUNLOCK()
ELSE
	reclock("AX2",.T.)
	X2_CHAVE := "SZ2"
	X2_PATH := "\DADOSADV\YY\"
	X2_ARQUIVO := "SZ2YY0"
	X2_MODO := "C"
	X2_TTS := "N"
	MSUNLOCK()
ENDIF
DBSELECTAREA("AX2")
Ferase(_cInd_X2+OrdBagExt())
dbCloseArea()

return

/////////////////
///////////////////
//////////////////////
//********************************************
//**************************************
STATIC FUNCTION _AtuSX3()
_cKey_x3 := "X3_ARQUIVO+X3_ORDEM"
_cInd_x3 := CriaTrab(Nil,.f.)
//INDREGUA("AX3",_cInd_X3,_cKey_X3,,,"DICIONARIO " + cARQX3)
dbGotop()
// IncProc( 'Processando: ' + cARQX3 + SM0->M0_NOME )
dbSelectArea("AX3")
dbSetOrder(1)
//PROCREGUA(LASTREC())
//	dbgotop()
//dbseek("SZ200",.t.)

/*WHILE .NOT. EOF()
IncProc( SX3->X3_ARQUIVO )
IF AX3->X3_ARQUIVO == "SZ2"


//TIRAR
DBSELECTAREA("AX3")
Ferase(_cInd_X3+OrdBagExt())
dbCloseArea()
return



RecLock("AX3",.F.)
dbDelete()
MsUnlock()
ENDIF
// colocar a saida quando for sd2
IF SX3->X3_ARQUIVO > "SZ2"
EXIT
ENDIF
DBSKIP()
ENDDO
dbgotop()
dbSelectArea("SX3")
dbSetOrder(1)
dbgotop()
//dbseek("SC600",.t.) //dbgotop()
y := fcount()
PROCREGUA(LASTREC())
while .not. eof()
IncProc( SX3->X3_ARQUIVO )
IF SX3->X3_ARQUIVO == "SZ2"
fCONTE := {}
FOR Z := 1 TO Y                           // LEITURA
AADD(fCONTE ,FIELDGET(Z))
NEXT Z

DBSELECTAREA("AX3")                       // GRAVACAO
IF .NOT. DBSEEK(SX3->X3_ARQUIVO + SX3->X3_ORDEM) .and. substr(SX3->X3_ARQUIVO,1,1)<>" "
LFLAG3 := .T.
ELSE
LFLAG3 := .F.
ENDIF
reclock("AX3",LFLAG3)
for z := 1 to y
fNAME := FIELD(Z)
&fNAME := fCONTE[Z]
next z
MSUNLOCK()
ENDIF
//IF SX3->X3_ARQUIVO == "SD2"
//	EXIT
//ENDIF
DBSELECTAREA("SX3")
DBSKIP()
enddo
*/
///////////////////
_cKey_x3 := "X3_ARQUIVO+X3_CAMPO"
_cInd_x3 := CriaTrab(Nil,.f.)
INDREGUA("AX3",_cInd_X3,_cKey_X3,,,"DICIONARIO " + cARQX3)


// MODIFICA OS CAMPOS NO SX3
// BLOQ AQUI
dbSelectArea("SX3")
dbSetOrder(1)
PROCREGUA(LASTREC())
dbseek("SB100",.t.)
WHILE .NOT. EOF()
	IncProc( SX3->X3_ARQUIVO )
	if  SX3->X3_ARQUIVO $ "SC6/SC7/SD1/SB1" .AND. ;
		(ALLTRIM(SX3->X3_CAMPO) == SUBST(SX3->X3_ARQUIVO,2,LEN(SX3->X3_ARQUIVO))+"_TES" .OR. ;
		ALLTRIM(SX3->X3_CAMPO) == SUBST(SX3->X3_ARQUIVO,2,LEN(SX3->X3_ARQUIVO))+"_TE" .OR.;
		ALLTRIM(SX3->X3_CAMPO) == SUBST(SX3->X3_ARQUIVO,2,LEN(SX3->X3_ARQUIVO))+"_TS")
		
		DBSELECTAREA("AX3")
		//while !eof()
		IF DBSEEK(SX3->X3_ARQUIVO + SX3->X3_CAMPO) .and. substr(SX3->X3_ARQUIVO,1,1)<>" "
			//	_cCampo:="ax3->X3_F3"
			reclock("AX3",.f.)
			//	&_cCAMPO:=Sx3->X3_f3
			ax3->x3_f3:=sx3->x3_f3
			ax3->x3_vlduser:=sx3->x3_vlduser
			MSUNLOCK()
		ENDIF
	endif
	if SX3->X3_ARQUIVO > "SD1"
		EXIT
	endif
	DBSELECTAREA("SX3")
	DBSKIP()
enddo

DBSELECTAREA("AX3")
Ferase(_cInd_X3+OrdBagExt())
dbCloseArea()

RETURN

/////////////////
//////////////////
/////////////////
STATIC FUNCTION _AtuSXB
cARQXB := 'SXB' + SM0->M0_CODIGO + '0.DBF'
_cKey_xB := "XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA"
_cInd_xB := CriaTrab(Nil,.f.)
INDREGUA("AXB",_cInd_XB,_cKey_XB,,,"CONSULTAS " + cARQXB)
dbGotop()
// IncProc( 'Processando: ' + cARQXB + SM0->M0_NOME )
dbSelectArea("AXB")
dbSetOrder(1)
//dbgotop()
PROCREGUA(LASTREC())
dbseek("SZ2",.T.)
WHILE .NOT. EOF()
	IncProc( SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ )
	IF AXB->XB_ALIAS == "SZ2"
		
		// TIRAR
		//DBSELECTAREA("AXB")
		//Ferase(_cInd_XB+OrdBagExt())
		//dbCloseArea()
		//RETURN
		
		RecLock("AXB",.F.)
		dbDelete()
		MsUnlock()
	ENDIF
	DBSKIP()
ENDDO
dbgotop()
dbSelectArea("SXB")
dbSetOrder(1)
dbgotop()
y := fcount()
PROCREGUA(LASTREC())
while .not. eof()
	IncProc( SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ )
	IF SXB->XB_ALIAS == "SZ2"
		fCONTE := {}
		FOR Z := 1 TO Y                           // LEITURA
			AADD(fCONTE ,FIELDGET(Z))
		NEXT Z
		
		DBSELECTAREA("AXB")                       // GRAVACAO
		//IF .NOT. DBSEEK(SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ + XB_COLUNA) .and. substr(SXB->XB_ALIAS,1,1)<>" "
		LFLAGB := .T.
		//ELSE
		//	LFLAGB := .F.
		//ENDIF
		reclock("AXB",LFLAGB)
		for z := 1 to y
			fNAME := FIELD(Z)
			&fNAME := fCONTE[Z]
		next z
		MSUNLOCK()
	ENDIF
	DBSELECTAREA("SXB")
	DBSKIP()
enddo
DBSELECTAREA("AXB")
Ferase(_cInd_XB+OrdBagExt())
dbCloseArea()
return

/////////////////
///////////////////
///////////
static function _AtuSX7

_cKey_x7 := "X7_CAMPO + X7_SEQUENC"
_cInd_x7 := CriaTrab(Nil,.f.)
INDREGUA("AX7",_cInd_X7,_cKey_X7,,,"GATILHOS " + cARQX7)

/////////////
//tirar cod. abaixo qdo utiliazar
//ob.  nao testado
///////////////////
DBSELECTAREA("AX7")
Ferase(_cInd_X7+OrdBagExt())
dbCloseArea()
return

dbGotop()
// IncProc( 'Processando: ' + cARQXB + SM0->M0_NOME )
dbSelectArea("AX7")
dbSetOrder(1)
dbgotop()

WHILE .NOT. EOF()
	IF SX7->X7_ALIAS == "SZ2"
		RecLock("AX7",.F.)
		dbDelete()
		MsUnlock()
	ENDIF
	DBSKIP()
ENDDO
dbgotop()
dbSelectArea("SX7")
dbSetOrder(1)
dbgotop()
y := fcount()
while .not. eof()
	IF SUBSTR(SX7->X7_CAMPO,1,2) == "Z2"
		fCONTE := {}
		FOR Z := 1 TO Y                           // LEITURA
			AADD(fCONTE ,FIELDGET(Z))
		NEXT Z
		
		DBSELECTAREA("AX7")                       // GRAVACAO
		IF .NOT. DBSEEK(SX7->X7_CAMPO + SX7->X7_SEQUENC) .and. substr(SX7->X7_CAMPO,1,1)<>" "
			LFLAG7 := .T.
		ELSE
			LFLAG7 := .F.
		ENDIF
		reclock("AX7",LFLAG7)
		for z := 1 to y
			fNAME := FIELD(Z)
			DIC->&fNAME := fCONTE[Z]
		next z
		MSUNLOCK()
	ENDIF
	DBSELECTAREA("SX7")
	DBSKIP()
enddo
DBSELECTAREA("AX7")
Ferase(_cInd_X7+OrdBagExt())
dbCloseArea()
return


//*********************************
//*******************************
/////////////////
//////////////////
/////////////////
STATIC FUNCTION _AtuSX5
cARQX5 := 'SX5' + SM0->M0_CODIGO + '0.DBF'
//_cKey_xB := "XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA"
//_cInd_xB := CriaTrab(Nil,.f.)
//INDREGUA("AXB",_cInd_XB,_cKey_XB,,,"CONSULTAS " + cARQXB)
dbGotop()
// IncProc( 'Processando: ' + cARQXB + SM0->M0_NOME )
dbSelectArea("AX5")
//dbSetOrder(1)
PROCREGUA(LASTREC())
dbgotop()
//PROCREGUA(LASTREC())
//dbseek("SZ2",.T.)
WHILE .NOT. EOF()
	IncProc("Excluindo")
	IF AX5->X5_TABELA == "13"
		RecLock("AX5",.F.)
		dbDelete()
		MsUnlock()
	ENDIF
	DBSKIP()
ENDDO

dbgotop()
dbSelectArea("SX5")
dbgotop()
PROCREGUA(LASTREC())
y := fcount()
while .not. eof()
	IncProc("Incluindo: "+alltrim(str(recno())))
	IF SX5->X5_TABELA == "13"
		fCONTE := {}
		FOR Z := 1 TO Y                           // LEITURA
			AADD(fCONTE ,FIELDGET(Z))
		NEXT Z
		
		DBSELECTAREA("AX5")                       // GRAVACAO
		reclock("AX5",.T.)
		for z := 1 to y
			fNAME := FIELD(Z)
			&fNAME := fCONTE[Z]
		next z
		MSUNLOCK()
	ENDIF
	DBSELECTAREA("SX5")
	DBSKIP()
enddo
DBSELECTAREA("AX5")
//Ferase(_cInd_XB+OrdBagExt())
dbCloseArea()
return
