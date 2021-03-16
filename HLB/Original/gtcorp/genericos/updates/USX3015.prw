#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
/*
Funcao      : USX3015
Objetivos   : Alteração de tamanho de decimais.
Autor       : Jean Victor Rocha
Data/Hora   : 26/03/2012
*/
*----------------------*
User Function USX3015(o)
*----------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo."+;
                            "Faça um backup dos dicionários e da Base de Dados antes da atualização.",;
                            "Atenção")                  
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) , Final("Atualização efetuada.")),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/

Static Function UPDProc(lEnd)

Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0


Local aChamados := { {04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence

   ProcRegua(1)

   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )

      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof()
  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 EndIf
		 dbSkip()
	  EndDo

	  If lOpen
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
Obs.        :
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

*-----------------------*
Static Function AtuSX3()
*-----------------------*
Local cTexto := ""
Local nDec   := 2//Fixo com 2 decimais.
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
	If SX3->(Dbseek(aCampos[i][2])) .and. SX3->X3_DECIMAL <> 2
		SX3->(RecLock("SX3", .F.))
		SX3->X3_TAMANHO	:=	SX3->X3_TAMANHO+ (2 - SX3->X3_DECIMAL)//aumenta considerando somente o decimal.
		SX3->X3_DECIMAL	:=	2
		SX3->X3_PICTURE	:=	GetPic(SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE)
		SX3->(MsUnlock())
		cTexto += "- Atualizado o campo '"+aCampos[i][2]+"' tam:"+ALLTRIM(STR(SX3->X3_TAMANHO))+" dec:2 pic:'"+SX3->X3_PICTURE+"'"+CHR(13)+CHR(10)
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