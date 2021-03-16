#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SQL2DBF   ºAutor  ³Marcos S. Lobo      º Data ³  01/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exporta o arquivo/registros selecionados de SQL para DBF.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Para a atualizacao dos arquivos das lojas - Dental Gaucho  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ\ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

/*
Funcao      : SQL2DBF
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exporta o arquivo/registros selecionados de SQL para DBF.
Autor       : Marcos S. Lobo 
Data/Hora   : 01/05/01     
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Obs         : 
Módulo      : Generico. 
Cliente     : Todos
*/
       

*---------------------*
User Function SQL2DBF()
*----------------------*

SetPrvt ("_aTMPSTRU,_cArq,_aTIT,_lTodos,_oBrw,_nFiles,_RecAtu")   //VARIAVEIS DO BROWSE DE ARQUIVOS
SetPrvt ("_ArqSel,_CampoOk,_oBrwRegs,_lRegTodos,oDlgRegs") //VARIAVEIS DO BROWSE DE REGISTROS
SetPrvt ("_nExpFiles,_cPath,_cArqSQL,_cIndSQL,_cArqDBF,_cAlias,_nRegsWWW") //VARIAVEIS DA EXPORTACAO DE ARQUIVOS
SetPrvt ("_WAlias")
_cPath := "\DADOSADV\"+SM0->M0_CODIGO+"\" + SPACE(47)
_lTodos := .F. // Todos os arquivos desmarcados
IF SELECT("WWW") > 0
   dbSelectArea("WWW")
   dbCloseArea("WWW")
ENDIF
//DbUseArea(.t.,,"SX2YY0","TRB",.T.)
dbSelectArea("SX2")
dbGoTop()
_aTMPSTRU := {}
AADD(_aTMPSTRU,{ "OK"         ,"C",02,0})
AADD(_aTMPSTRU,{ "X2_CHAVE"   ,"C",03,0})
AADD(_aTMPSTRU,{ "X2_ARQUIVO" ,"C",08,0})
AADD(_aTMPSTRU,{ "X2_NOME"    ,"C",30,0})
AADD(_aTMPSTRU,{ "TMP"        ,"L",01,0})

_aCampos := {}
AADD(_aCampos,{"OK"        ,"",""})
AADD(_aCampos,{"X2_CHAVE"  ,"CHAVE",""})
AADD(_aCampos,{"X2_ARQUIVO","ARQUIVO",""})
AADD(_aCampos,{"X2_NOME"   ,"DESCRICAO",""})

_cArq := Criatrab(_aTMPSTRU,.T.)
dbUseArea( .T.,,_cArq, "WWW", If(.F. .OR. .F., !.F., NIL), .F. )

dbSelectArea("SX2")
dbClearFilter(NIL)
dbSetOrder(1)
dbGoTop()
_nFiles := 0
Processa({|| BuscaSX2()},"Estrutura de arquivos...")
dbSelectArea("WWW")
dbGoTop()
_RecAtu := Recno()
TELAUNMARK() // MONTA A TELA DESMARCADOS

dbSelectArea("WWW")
dbCloseArea("WWW")
FERASE(_cArq+OrdBagExt())

Return

//************************************************
//Função que Monta o arquivo temporário
//************************************************
Static Function BuscaSX2()
ProcRegua(LastRec()) 
WHILE !EOF()
	IncProc()
	If UPPER(Alltrim(Substring(SX2->X2_CHAVE,1,1)))<>"Q" .and. UPPER(Alltrim(Substring(SX2->X2_CHAVE,1,2)))<>"SX"
		DbSelectArea("WWW")
		_nCampos := FCOUNT()
		RecLock("WWW",.T.)
		FOR _n:= 1 TO _nCampos
			dbSelectArea("SX2")
			xCampo := FIELDGET(_n)
			cNomeCpo := FIELDNAME(_n)
			dbSelectArea("WWW")
			FIELDPUT(FIELDPOS(cNomeCpo),xCampo)
		NEXT
		Field->TMP := .F.
		_nFiles := _nFiles + 1
		MsUnlock()
	Endif
	dbSelectArea("SX2")
	dbSkip()
ENDDO
Return

//************************************************
//Função que Monta a tela COM ARQUIVOS DESMARCADOS
//************************************************
Static Function TELAUNMARK()
@ 109,056 To 500,644 Dialog oDlg Title OemToAnsi("Conversao SQL p/ DBF")
@ 005,008 SAY "Selecione os arquivos a serem exportados:"
@ 015,008 TO 190,230 BROWSE "WWW" MARK "OK" FIELDS _aCampos Object _oBrw
_oBrw:bMark := { || _RotMark()}
@ 015,240 BmpButton Type 1 Action TelaExporta()
@ 030,240 BmpButton Type 2 Action Close(oDlg)
@ 045,240 Button "_Todos" Action MarkAll() Object _oBtodos
@ 183,240 Say "Arquivos: "+ALLTRIM(STR(_nFiles))
// DESMARCA OS ARQUIVOS
While !Eof()
	RecLock("WWW",.F.)
	Field->OK := ThisMark()
	dbSkip()
	MsUnlock()
Enddo
_lTodos := .F. // TODOS ARQUIVOS DESMARCADOS
dbGoto(_RecAtu)
Activate Dialog oDlg Centered //ATIVA A CAIXA DE DIALOGO
Return

//************************************************
//Função que Monta a tela COM ARQUIVOS MARCADOS
//************************************************
Static Function TELAMARK()

// MARCA OS ARQUIVOS
dbGoTop()
While !Eof()
	RecLock("WWW",.F.)
	Field->OK := ""
	dbSkip()
	MsUnlock()
Enddo
_lTodos := .T. // TODOS ARQUIVOS MARCADOS
@ 109,056 To 500,640 Dialog oDlg Title OemToAnsi("Conversao SQL para DBF")
@ 005,008 SAY "Selecione os arquivos a serem exportados:"
@ 015,008 TO 190,230 BROWSE "WWW" MARK "OK" FIELDS _aCampos Object _oBrw
_oBrw:bMark := { || _RotMark()}
@ 015,240 BmpButton Type 1 Action TelaExporta()
@ 030,240 BmpButton Type 2 Action Close(oDlg)
@ 045,240 Button "_Todos" Action MarkAll()
@ 183,240 Say "Arquivos: "+ALLTRIM(STR(_nFiles))
dbGoto(_RecAtu)
Activate Dialog oDlg Centered //ATIVA A CAIXA DE DIALOGO
Return

//*****************************************
//Função que marca/desmarca todos os arquivos
//*****************************************
Static Function MarkAll()
IF MSGBOX("Esta acao ira marcar/desmarcar todos os Arquivos !"+CHR(13)+CHR(10)+"Confirma ?","Confirmação Marca Arquivos","YESNO")
	Close(oDlg)// FECHA A CAIXA DE DIALOGO PRINCIPAL
	dbSelectArea("WWW")
	dbGoTop()
	IF _lTodos == .F.
		dbGoTop()
		TELAMARK()
	ELSE
		dbGoTop()
		TELAUNMARK()
	ENDIF
ENDIF
Return

//*****************************************
//Função disparada na selecao de Arquivos
//*****************************************
Static Function TELAREMARK()
         
dbSelectArea("WWW")
@ 109,056 To 500,640 Dialog oDlg Title OemToAnsi("Conversao SQL para DBF")
@ 005,008 SAY "Selecione os arquivos a serem exportados:"
@ 015,008 TO 190,230 BROWSE "WWW" MARK "OK" FIELDS _aCampos Object _oBrw
_oBrw:bMark := { || _RotMark()}
@ 015,240 BmpButton Type 1 Action TelaExporta()
@ 030,240 BmpButton Type 2 Action Close(oDlg)
@ 045,240 Button "_Todos" Action MarkAll()
@ 183,240 Say "Arquivos: "+ALLTRIM(STR(_nFiles))
dbGotop()
While !Eof()
	If !Empty(OK)
		RecLock("WWW",.F.)
		Field->OK := ThisMark()
		MsUnlock()
	Endif
	dbSkip()
Enddo
dbGoto(_RecAtu)
Activate Dialog oDlg Centered //ATIVA A CAIXA DE DIALOGO
Return

//*****************************************
//Função disparada na selecao de Arquivos
//*****************************************
Static Function _RotMark()
_RecAtu := Recno()
If Empty(WWW->OK)
	IF WWW->TMP == .T.
		IF MSGBOX("Arquivo Inteiro ?","Selecionando dados....","YESNO") .and. LASTKEY() <> 27
			_WAlias := "W"+ALLTRIM(WWW->X2_CHAVE)  //Alias do arquivo selecionado
			_TMPArqSel := ALLTRIM(WWW->X2_ARQUIVO) // NOME DO ARQUIVO TEMPORARIO
			dbSelectArea(_WAlias)
			dbCloseArea(_WAlias)
			FERASE(_TMPArqSel+OrdBagExt())
			dbSelectArea("WWW")
			RecLock("WWW",.F.)
			Field->X2_ARQUIVO := ALLTRIM(WWW->X2_CHAVE)+cEmpAnt+"0"
			Field->TMP := .F.
			MsUnlock()
			Close(oDlg)// FECHA A CAIXA DE DIALOGO PRINCIPAL
			TELAREMARK()
		ELSE
			_ArqSel := ALLTRIM(WWW->X2_CHAVE)  //Alias do arquivo selecionado
			_TMPArqSel := ALLTRIM(WWW->X2_ARQUIVO) // NOME DO ARQUIVO TEMPORARIO
			_WAlias := "W"+_ArqSel // Alias do Arquivo Temporário a criar
			dbSelectArea(_ArqSel)
			_StruArqSel := dbStruct()
			_aRegCampos := {}
			_nCpoArqSel := Len(_StruArqSel) - 1
			AADD(_aRegCampos,{"OKREG" ,"",""})
			FOR _nReg := 1 TO _nCpoArqSel
				AADD(_aRegCampos,{_StruArqSel[_nReg,1] ,_StruArqSel[_nReg,1],""})
			NEXT
			dbSelectArea(_WAlias)
			dbGoTop()
			_lRegTodos := .T.
			REMARKREGS() // FUNCAO QUE MONTA A TELA DE SELECAO DE REGISTROS
		ENDIF
	ELSE
		IF !MSGBOX("Arquivo Inteiro ?","Selecionando dados...","YESNO")
			_ArqSel := ALLTRIM(WWW->X2_CHAVE)	//Alias do arquivo selecionado
			_WAlias := "W"+_ArqSel 				// Alias do Arquivo Temporário a criar
			dbSelectArea(_ArqSel)				// Usa arquivo selecionado
			
			_StruArqSel := dbStruct()  			// Copia estrutura do arquivo selecionado
			AADD(_StruArqSel,{ "OKREG" ,"C",02,0}) // Adiciona o Campo Ok no arquivo
			_TMPArqSel := Criatrab(_StruArqSel, .T.) // Cria o arquivo temporário
			dbUseArea( .T.,,_TMPArqSel, _Walias, If(.F. .OR. .F., !.F., NIL), .F. ) // Monta a area de trabalho
			
			_aRegCampos := {}
			_nCpoArqSel := Len(_StruArqSel) - 1
			AADD(_aRegCampos,{"OKREG" ,"",""})
			FOR _nReg := 1 TO _nCpoArqSel
				AADD(_aRegCampos,{_StruArqSel[_nReg,1] ,_StruArqSel[_nReg,1],""})
			NEXT
			
			dbSelectArea(_ArqSel)
			_nRegs := RecCount()
			dbSetOrder(1)
			dbGoTop()
            
            Close(oDlg)// FECHA A CAIXA DE DIALOGO PRINCIPAL
			If _nRegs > 1500
				If MSGBOX("Deseja realmente selecionar os registros ?","Encontrados "+ALLTRIM(STR(_nRegs))+" registros","YESNO") .and. LASTKEY() <> 27
						Processa( {||BUSCATMP()} )
						MARKREGS() // FUNCAO QUE MONTA A TELA DE SELECAO DE REGISTROS
				Else
					TELAREMARK()
				Endif
			Else
				Processa( {||BUSCATMP()} )
				MARKREGS() // FUNCAO QUE MONTA A TELA DE SELECAO DE REGISTROS
			Endif
		ENDIF
	ENDIF
Endif
Return


//**********************************************
//Função que ALIMENTA O ARQUIVO TMP CRIADO
//**********************************************
STATIC FUNCTION BUSCATMP()

ProcRegua(_nRegs)
WHILE !EOF()
	IncProc()
	DbSelectArea(_WAlias)
	_nCampos := FCOUNT()
	RecLock(_WAlias,.T.)
	FOR _n:= 1 TO _nCampos
		dbSelectArea(_ArqSel)
		xCampo := FIELDGET(_n)
		cNomeCpo := FIELDNAME(_n)
		dbSelectArea(_WAlias)
		FIELDPUT(FIELDPOS(cNomeCpo),xCampo)
	NEXT
	MsUnlock()
	dbSelectArea(_ArqSel)
	dbSkip()
ENDDO

dbSelectArea("WWW")
RecLock("WWW",.F.)
Field->X2_ARQUIVO := ALLTRIM(WWW->X2_CHAVE)+cEmpAnt+"0"
Field->TMP := .T.
MsUnlock()

dbSelectArea(_WAlias)
dbGoTop()
_lRegTodos := .T.

RETURN

//**********************************************
//Função que Monta a tela COM REGISTROS MARCADOS
//**********************************************
Static Function MARKREGS()

// MARCA OS ARQUIVOS
dbGoTop()
While !Eof()
	RecLock(_WAlias,.F.)
	Field->OKREG := ""
	dbSkip()
	MsUnlock()
Enddo
_lRegTodos := .T.
@ 109,056 To 500,640 Dialog oDlgRegs Title OemToAnsi("Selecionando Registros...")
@ 005,008 SAY "Arquivo: " + ALLTRIM(WWW->X2_CHAVE) + " (" + ALLTRIM(_TMPArqSel) + ") -> " + STRTRAN(ALLTRIM(WWW->X2_NOME),"'","")
@ 015,008 TO 190,230 BROWSE _Walias MARK "OKREG" FIELDS _aRegCampos Object _oBrwRegs
_oBrwRegs:bMark := { || _RotMarkReg()}
@ 015,240 BmpButton Type 1 Action _GravaTMPRegs()
@ 030,240 BmpButton Type 2 Action FechaRegs()
@ 045,240 Button "_Todos" Action MarkAllRegs()
dbGoTop()
Activate Dialog oDlgRegs Centered // Ativa o Browse de Registros
Return

//**********************************************
//Função que Monta a tela COM REGISTROS MARCADOS
//**********************************************
Static Function REMARKREGS() // FUNCAO QUE REMONTA A TELA COM OS REGISTROS MARCADOS

dbSelectArea(_WAlias)
@ 109,056 To 500,640 Dialog oDlgRegs Title OemToAnsi("Selecionando Registros...")
@ 005,008 SAY "Arquivo: " + ALLTRIM(WWW->X2_CHAVE) + " (" + ALLTRIM(WWW->X2_ARQUIVO) + ") -> " + ALLTRIM(WWW->X2_NOME)
@ 015,008 TO 190,230 BROWSE _Walias MARK "OKREG" FIELDS _aRegCampos Object _oBrwRegs
_oBrwRegs:bMark := { || _RotMarkReg()}
@ 015,240 BmpButton Type 1 Action _GravaTMPRegs()
@ 030,240 BmpButton Type 2 Action FechaRegs()
@ 045,240 Button "_Todos" Action MarkAllRegs()
dbGoTop()
While !Eof()
	If !Empty(OKREG)
		RecLock(_WAlias,.F.)
		Field->OKREG := ThisMark()
		MsUnlock()
	Endif
	dbSkip()
Enddo
dbGotop()
Activate Dialog oDlgRegs Centered  // Ativa o Browse de Registros
Return


//*****************************************
//Função que marca/desmarca todos os registros
//*****************************************
Static Function MarkAllRegs()

IF MSGBOX("Esta acao ira marcar/desmarcar todos os registros !"+CHR(13)+CHR(10)+"Confirma ?","Confirmação Marca Registros","YESNO")
	IF _lRegTodos == .F.
		Close(oDlgRegs)// FECHA A CAIXA DE DIALOGO
		dbGoTop()
		MARKREGS()
		_lRegTodos := .T.
	ELSE
		Close(oDlgRegs)// FECHA A CAIXA DE DIALOGO
		@ 109,056 To 500,640 Dialog oDlgRegs Title OemToAnsi("Selecinando Registros...")
		@ 005,008 SAY "Arquivo: " + ALLTRIM(WWW->X2_CHAVE) + " (" + ALLTRIM(WWW->X2_ARQUIVO) + ") -> " + ALLTRIM(WWW->X2_NOME)
		@ 015,008 TO 190,230 BROWSE _Walias MARK "OKREG" FIELDS _aRegCampos Object _oBrwRegs
		_oBrwRegs:bMark := { || _RotMarkReg()}
		@ 015,240 BmpButton Type 1 Action _GravaTMPRegs()
		@ 030,240 BmpButton Type 2 Action FechaRegs()
		@ 045,240 Button "_Todos" Action MarkAllRegs()
		
		dbGoTop()
		While !Eof()
			RecLock(_WAlias,.F.)
			Field->OKREG := ThisMark()
			MsUnlock()
			dbSkip()
		Enddo
		_lRegTodos := .F.
		dbGoTop()
		Activate Dialog oDlgRegs Centered// Ativa o Browse de Registros
	ENDIF
ENDIF
Return


//************************************************************************
//Função Executada quando um registro é selecionado no Browse de Registros
//************************************************************************
Static Function _RotMarkReg()
If Empty(OKREG)
	RecLock(_WAlias,.F.)
	Field->OKREG := ThisMark()
	MsUnLock()
Endif
Return

//************************************************************************
//Função que Grava o Novo nome do Arquivo quando selecionados os registros
//************************************************************************
Static Function _GravaTMPRegs()

dbSelectArea("WWW")
RecLock("WWW",.F.)
Field->X2_ARQUIVO := SUBSTR(ALLTRIM(_TMPArqSel),1,8)
Field->TMP := .T.
MsUnlock()
Close(oDlgRegs)

dbGoTop()
While !Eof()
	If !Empty(WWW->OK)
		RecLock("WWW",.F.)
		Field->OK := ThisMark()
		MsUnlock()
	Endif
	dbSkip()
Enddo
TELAREMARK()

Return

//***************************************************
//Função que Monta a Tela com o Path para os arquivos
//***************************************************
Static Function TelaExporta()

_RecAtu := Recno()
// Inicializa a Regua de Processamento
dbSelectArea("WWW")
DbGoTop()
_nRegsWWW := 0
While !Eof()
	If ALLTRIM(WWW->OK) == ""
		_nRegsWWW := _nRegsWWW + 1
	Endif
	dbSkip()
Enddo

dbGoto(_RecAtu)

If _nRegsWWW == 0
	MSGBOX("Nao ha arquivos selecionados"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Selecione 01 ou mais arquivos...", "Selecionando Arquivos", "INFO")
	oDlg:Refresh()
Else
	// Exibe a tela para selecao do caminho onde serao gravados os arquivos
	@ 150,050 To 250,400 Dialog _oDlgPath Title OemToAnsi("Destino...")
	@ 005,010 SAY "Digite o diretorio destino:"
	@ 016,010 SAY "\AP5"
	@ 015,025 Get _cPath Size 140,010 Object _oGetPath
	@ 035,010 SAY ALLTRIM(STR(_nRegsWWW)) + " arquivo(s) selecionado(s)."
	@ 030,110 BmpButton Type 1 Action ValidaPath()
	@ 030,140 BmpButton Type 2 Action FechaPath()
	Activate Dialog _oDlgPath Centered
Endif
Return

//*************************************************
//Função que Verifica se o Path indicado existe
//*************************************************
Static Function ValidaPath()
If !lIsDir(ALLTRIM(_cPath))
	Close(_oDlgPath)
	MSGBOX("O diretorio \AP5" + ALLTRIM(_cPath) + " nao existe !","Erro - Selecione outro diretorio")
	TelaExporta()
Else
	Close(_oDlgPath)
	Processa({|| _Exporta()})
	TELAREMARK()
Endif
Return

//*************************************************
//Função que Exporta os Arquivos/Registros Marcados
//*************************************************
Static Function _Exporta()
Close(oDlg)
dbSelectArea("WWW")
ProcRegua(_nRegsWWW) // INICIALIZA A REGUA DE PROCESSAMENTO
DbGoTop()
_nExpFiles := 0
While !Eof()
	IncProc()
	If WWW->OK <> ThisMark()
		_cAlias  := AllTrim(WWW->X2_CHAVE)
		_WAlias := "W"+_cAlias
		_cArqSQL := AllTrim(WWW->X2_ARQUIVO)
		_cIndSQL := AllTrim(WWW->X2_ARQUIVO)+"1"
		IF TCCANOPEN(_cArqSQL) // É UM ARQUIVO DO SQL
			_cArqDBF := AllTrim(_cPath)+_cArqSQL+".DBF"
			dbUseArea( .T., "TOPCONN", (_cArqSQL), (_WAlias), if(.T. .OR. .F., !.F., NIL), .F. )
			IF TCCANOPEN(_cArqSQL,_cIndSQL)
				DbSetIndex(_cIndSQL)
			ENDIF
			__dbCopy((_cArqDBF),{ },,,,,.F.,)
			DbCloseArea()
			_nExpFiles := _nExpFiles + 1
		/*/
		ELSE				  // NÃO É UM ARQUIVO DO SQL (É TEMPORARIO)
			_cArqDBF := AllTrim(_cPath)+_cAlias+cEmpAnt+"0.DBF"
			//dbUseArea( .T., "DBFCDX", (_cArqSQL), _WAlias, if(.T. .OR. .F., !.F., NIL), .F. )
			dbSelectArea(_WAlias)
			**********************APAGA OS REGISTROS MARCADOS
			dbGoTop()
			While !Eof()
				If !Empty(OKREG)
					RecLock(_WAlias,.F.)
					dbDelete()
					MsUnlock()
				Endif
				dbSkip()
			Enddo
			
			//**********************CONTINUA PARA COPIAR O ARQUIVO
			
			__dbCopy((_cArqDBF),{ },,,,,.F.,)
			
			dbCloseArea(_WAlias)
			FERASE(ALLTRIM(WWW->X2_ARQUIVO)+OrdBagExt())
			_nExpFiles := _nExpFiles + 1
		/*/	
		ENDIF
	Endif
	DbSelectArea("WWW")
	DbSkip()
EndDo

dbSelectArea("WWW")
dbGoTop()
WHILE !Eof()
	RecLock("WWW",.F.)
	Field->X2_ARQUIVO := ALLTRIM(WWW->X2_CHAVE)+cEmpAnt+"0"
	Field->TMP := .F.
	MsUnlock()
	dbSkip()
ENDDO

MSGBOX (ALLTRIM(STR(_nExpFiles)) + " Arquivo(s) Exportado(s) com Sucesso !!!","Conversao efetuada...","INFO")
RETURN

//**********************************************
//Função que Fecha a tela de Selecao de Registros e volta a tela de arquivos
//**********************************************
STATIC FUNCTION FechaRegs()
Close(oDlgRegs)
dbSelectArea(_WAlias)
dbCloseArea(_WAlias)
dbSelectArea("WWW")
TELAREMARK()
RETURN

//*************************************************
//Função que fecha a tela do PATH e retorna a tela de arquivos
//*************************************************
STATIC FUNCTION FechaPath()
Close(_oDlgPath)
Close(oDlg)
TELAREMARK()
RETURN
