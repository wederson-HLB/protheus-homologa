#INCLUDE "Protheus.ch"

/*
Funcao      : USX3053
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Alterar tamanho dos campos quantidade. Novo Layout
Autor       : Renato Rezende
Chamado		: 
Data/Hora   : 05/05/2015
*/
*---------------------*
User Function USX3053()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário?"+;
                            "Faça um backup dos dicionários e da Base de Dados antes da atualização.",;
                            "Atenção")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) ,oMainWnd:End()/*, Final("Atualização efetuada.")*/),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/
*---------------------------*
Static Function UPDProc(lEnd)
*---------------------------*
Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0
Local aChamados := {	{04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )
	lCheck := .F.    
	aAux := {}
	If !Tela()
		Return .T.
	EndIf

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
		If lCheck
			If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		Else
			If Ascan(aAux,{ |x| LEFT(x,2)  == M0_CODIGO}) <> 0 .and.;
				Ascan(aAux,{ |x| RIGHT(x,2) == M0_CODFIL}) <> 0 .and.;
				Ascan(aRecnoSM0,{ |x| x[2]  == M0_CODIGO}) == 0 
				
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		EndIf
		dbSkip()
	EndDo
    
	RpcClearEnv()

	  If lOpen := MyOpenSm0Ex()
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next

			 __SetX31Mode(.F.)
			 For nX := 1 To Len(aArqUpd)
			     IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				 If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				 EndIf
				 X31UpdTable(aArqUpd[nx])
				 If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+;
					      aArqUpd[nx] +;
					      ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2) 

					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				 EndIf
			 Next nX
			 RpcClearEnv()
			 If !( lOpen := MyOpenSm0Ex() )
				Exit 
			 EndIf 
		 Next nI 

		 If lOpen
			cTexto := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

			Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
			Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

			@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
			Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			Activate MsDialog oDlg Center
		 EndIf
	  EndIf
   EndIf
End Sequence

Return(.T.)

/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 exclusivo
*/
*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) //Exclusivo
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas!.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

/*
Funcao      : ATUSX3
Autor  		: Renato Rezende
Data     	: 19/12/2014 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
 Static Function ATUSX3()
*-------------------------*
Local cTexto := ""
Local nDec   := 4//Fixo com 4 decimais.
Local aCampos:= {}
Local i

aAdd(aArqUpd,"SD1")

aAdd(aCampos, {"SC1","C1_QUJE"})
aAdd(aCampos, {"SC1","C1_QUJE2"})
aAdd(aCampos, {"SC1","C1_QTDORIG"})
aAdd(aCampos, {"SC2","C2_QUANT"})
aAdd(aCampos, {"SC2","C2_QUJE"})
aAdd(aCampos, {"SC2","C2_QTSEGUM"})
aAdd(aCampos, {"SC3","C3_QUANT"})
aAdd(aCampos, {"SC3","C3_QUJE"})
aAdd(aCampos, {"SC3","C3_QTSEGUM"})
aAdd(aCampos, {"SC3","C3_QTIMP"})
aAdd(aCampos, {"SC4","C4_QUANT"})
aAdd(aCampos, {"SC6","C6_QTDVEN"})
aAdd(aCampos, {"SC6","C6_QTDLIB"})
aAdd(aCampos, {"SC6","C6_QTDLIB2"})
aAdd(aCampos, {"SC6","C6_QTDENT"})
aAdd(aCampos, {"SC6","C6_QTDENT2"})
aAdd(aCampos, {"SC6","C6_QTDEMP"})
aAdd(aCampos, {"SC6","C6_QTDEMP2"})
aAdd(aCampos, {"SC6","C6_QTDRESE"})
aAdd(aCampos, {"SC7","C7_QUANT"})
aAdd(aCampos, {"SC7","C7_QTSEGUN"})
aAdd(aCampos, {"SC7","C7_QUJE"})
aAdd(aCampos, {"SC7","C7_QTDACLA"})
aAdd(aCampos, {"SC7","C7_QTDSOL"})
aAdd(aCampos, {"SC8","C8_QUANT"})
aAdd(aCampos, {"SC8","C8_QTSEGUM"})
aAdd(aCampos, {"SC9","C9_QTDLIB"})
aAdd(aCampos, {"SC9","C9_QTDRESE"})
aAdd(aCampos, {"SC9","C9_QTDLIB2"})
aAdd(aCampos, {"SD1","D1_QUANT"})
aAdd(aCampos, {"SD1","D1_QTDEDEV"})
aAdd(aCampos, {"SD1","D1_QTDPEDI"})
aAdd(aCampos, {"SD1","D1_SLDDEP"})
aAdd(aCampos, {"SD2","D2_QUANT"})
aAdd(aCampos, {"SD2","D2_QTDEDEV"})
aAdd(aCampos, {"SD2","D2_QTDEFAT"})
aAdd(aCampos, {"SD2","D2_QTDAFAT"})
aAdd(aCampos, {"SD3","D3_QUANT"})
aAdd(aCampos, {"SD3","D3_QTSEGUM"})
aAdd(aCampos, {"SD4","D4_QSUSP"})
aAdd(aCampos, {"SD4","D4_QTDEORI"})
aAdd(aCampos, {"SD4","D4_QUANT"})
aAdd(aCampos, {"SD4","D4_QTSEGUM"})
aAdd(aCampos, {"SD5","D5_QUANT"})
aAdd(aCampos, {"SD5","D5_QTSEGUM"})
aAdd(aCampos, {"SD6","D6_QUANT"})
aAdd(aCampos, {"SD7","D7_QTDE"})
aAdd(aCampos, {"SD7","D7_SALDO"})
aAdd(aCampos, {"SD7","D7_QTSEGUM"})
aAdd(aCampos, {"SD7","D7_SALDO2"})
aAdd(aCampos, {"SD8","D8_QUANT"})
aAdd(aCampos, {"SD8","D8_QT2UM"})
aAdd(aCampos, {"SD8","D8_QTDDEV"})
aAdd(aCampos, {"SD8","D8_QFIMDEV"})
aAdd(aCampos, {"SD8","D8_SD1DEV"})
aAdd(aCampos, {"SB2","B2_QFIM"})
aAdd(aCampos, {"SB2","B2_QATU"})
aAdd(aCampos, {"SB2","B2_VATU"})
aAdd(aCampos, {"SB2","B2_VATU2"})
aAdd(aCampos, {"SB2","B2_VATU3"})
aAdd(aCampos, {"SB2","B2_VATU4"})
aAdd(aCampos, {"SB2","B2_VATU5"})
aAdd(aCampos, {"SB2","B2_QEMP"})
aAdd(aCampos, {"SB2","B2_QEMPN"})
aAdd(aCampos, {"SB2","B2_QTSEGUM"})
aAdd(aCampos, {"SB2","B2_RESERVA"})
aAdd(aCampos, {"SB2","B2_QPEDVEN"})
aAdd(aCampos, {"SB2","B2_NAOCLAS"})
aAdd(aCampos, {"SB2","B2_SALPEDI"})
aAdd(aCampos, {"SB2","B2_QTNP"})
aAdd(aCampos, {"SB2","B2_QNPT"})
aAdd(aCampos, {"SB2","B2_QTER"})
aAdd(aCampos, {"SB2","B2_QFIM2"})
aAdd(aCampos, {"SB2","B2_QACLASS"})
aAdd(aCampos, {"SB2","B2_QEMPSA"})
aAdd(aCampos, {"SB2","B2_QEMPPRE"})
aAdd(aCampos, {"SB2","B2_SALPPRE"})
aAdd(aCampos, {"SB2","B2_QEMP2"})
aAdd(aCampos, {"SB2","B2_QEMPN2"})
aAdd(aCampos, {"SB2","B2_RESERV2"})
aAdd(aCampos, {"SB2","B2_QPEDVE2"})
aAdd(aCampos, {"SB2","B2_QEPRE2"})
aAdd(aCampos, {"SB2","B2_QFIMFF"})
aAdd(aCampos, {"SB2","B2_SALPED2"})
aAdd(aCampos, {"SB2","B2_QEMPPRJ"})
aAdd(aCampos, {"SB2","B2_QEMPPR2"})
aAdd(aCampos, {"SB6","B6_QUANT"})
aAdd(aCampos, {"SB6","B6_QTSEGUM"})
aAdd(aCampos, {"SB6","B6_QULIB"})
aAdd(aCampos, {"SB6","B6_SALDO"})
aAdd(aCampos, {"SB7","B7_QUANT"})
aAdd(aCampos, {"SB7","B7_QTSEGUM"})
aAdd(aCampos, {"SB8","B8_QTDORI"})
aAdd(aCampos, {"SB8","B8_SALDO"})
aAdd(aCampos, {"SB8","B8_EMPENHO"})
aAdd(aCampos, {"SB8","B8_QEMPPRE"})
aAdd(aCampos, {"SB8","B8_QACLASS"})
aAdd(aCampos, {"SB8","B8_SALDO2"})
aAdd(aCampos, {"SB8","B8_QTDORI2"})
aAdd(aCampos, {"SB8","B8_QEPRE2"})
aAdd(aCampos, {"SB8","B8_QACLAS2"})
aAdd(aCampos, {"SB9","B9_QINI"})
aAdd(aCampos, {"SB9","B9_QISEGUM"})
aAdd(aCampos, {"SB9","B9_VINI1"})
aAdd(aCampos, {"SB9","B9_VINI2"})
aAdd(aCampos, {"SB9","B9_VINI3"})
aAdd(aCampos, {"SB9","B9_VINI4"})
aAdd(aCampos, {"SB9","B9_VINI5"})
aAdd(aCampos, {"SB9","B9_VINIFF1"})
aAdd(aCampos, {"SB9","B9_VINIFF2"})
aAdd(aCampos, {"SB9","B9_VINIFF3"})
aAdd(aCampos, {"SB9","B9_VINIFF4"})
aAdd(aCampos, {"SB9","B9_VINIFF5"})
aAdd(aCampos, {"SBJ","BJ_QINI"})
aAdd(aCampos, {"SBJ","BJ_QISEGUM"})
aAdd(aCampos, {"SBK","BK_QINI"})
aAdd(aCampos, {"SBK","BK_QSEGUM"})

SX3->(DbSetOrder(2))
For i:=1 to Len(aCampos)
	If aScan(aArqUpd, {|x| x == aCampos[i][1] }) == 0
		aAdd(aArqUpd, aCampos[i][1])
	EndIf                           
	If SX3->(Dbseek(aCampos[i][2])) .and. SX3->X3_DECIMAL <> 4
		SX3->(RecLock("SX3", .F.))
		SX3->X3_TAMANHO	:=	IIF(SX3->X3_TAMANHO < 11, 11 + (4 - SX3->X3_DECIMAL),SX3->X3_TAMANHO + (4 - SX3->X3_DECIMAL))//aumenta considerando somente o decimal.
		SX3->X3_DECIMAL	:=	4
		SX3->X3_PICTURE	:=	GetPic(SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE)
		SX3->(MsUnlock())
		cTexto += "- Atualizado o campo '"+aCampos[i][2]+"' tam:"+ALLTRIM(STR(SX3->X3_TAMANHO))+" dec:4 pic:'"+SX3->X3_PICTURE+"'"+CHR(13)+CHR(10)
	EndIf
Next i

Return cTexto  

*--------------------------------------*
Static Function GetPic(nTam, nDec, cPic)
*--------------------------------------*
Local cRet := ""
Local lDecOK := .F.
Local nCont := 0
For i:=1 to nTam
	If i == nDec+1
		cRet := "."+cRet
		lDecOK := .T.
	Else
		cRet := "9"+cRet
		If lDecOK 
			nCont++
			If nCont == 3 .and. at(",",cPic) <> 0
				cRet := ","+cRet
				nCont := 0
			EndIf
		EndIf
	EndIf         
Next i
cRet := LEFT(cPic, 3)+IF(LEFT(cRet,1)==",",RIGHT(cRet,LEN(cRet)-1),cRet)
Return cRet

//------------- INTERFACE ---------------------------------------------------
*--------------------*
Static Function Tela()
*--------------------*
Local lRet := .F.
Private cAliasWork := "Work"
private aCpos :=  {	{"MARCA"	,,""} ,;
						{"M0_CODIGO",,"Cod.Empresa"	},;
						{"M0_CODFIL",,"Filial" 		},;
		   				{"M0_NOME"	,,"Nome Empresa"}}
		   				
private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"M0_CODIGO","C",2 ,0},;
						{"M0_CODFIL","C",2 ,0},;
		   				{"M0_NOME"	,"C",30,0}}

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf     

dbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSetOrder(1))
RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)


cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)
cAux:= ""
While SM0->(!EOF())
	If cAux <> SM0->M0_CODIGO
		(cAliasWork)->(RecLock(cAliasWork,.T.))           
		(cAliasWork)->MARCA		:= ""
		(cAliasWork)->M0_CODIGO	:= SM0->M0_CODIGO
		(cAliasWork)->M0_CODFIL	:= SM0->M0_CODFIL
		(cAliasWork)->M0_NOME	:= SM0->M0_NOME
		(cAliasWork)->(MsUnlock())
		cAux := SM0->M0_CODIGO
	EndIf
	SM0->(DbSkip())
EndDo

(cAliasWork)->(DbGoTop())

Private cMarca := GetMark()

SetPrvt("oDlg1","oSay1","oBrw1","oCBox1","oSBtn1","oSBtn2")

oDlg1      := MSDialog():New( 091,232,401,612,"Equipe TI da HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione as empresas a serem atualizadas."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{016,004,124,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.
oCBox1     := TCheckBox():New( 128,004,"Todas empresas.",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oSBtn1     := SButton():New( 132,116,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 132,152,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

// Seta Eventos do primeiro Check
oCBox1:bSetGet := {|| lCheck }
oCBox1:bLClicked := {|| lCheck:=!lCheck }
oCBox1:bWhen := {|| .T. }

oDlg1:Activate(,,,.T.)

Return lRet

*-----------------------*
Static Function cMark()
*-----------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))

RecLock(cAliasWork, .F.)
if lDesmarca
   (cAliasWork)->MARCA := "  "
else
   (cAliasWork)->MARCA := cMarca
endif

(cAliasWork)->(MsUnlock())

return 

*-----------------------*
Static Function Dados()
*-----------------------*
dbSelectArea(cAliasWork)
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If (cAliasWork)->MARCA <> " "
		aAdd(aAux, (cAliasWork)->M0_CODIGO+(cAliasWork)->M0_CODFIL)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo
Return .t.