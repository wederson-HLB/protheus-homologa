#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : USIX004
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria��o de indice para a tabela FI9.
Autor       : Daniel Fonseca de Lira
Data/Hora   : 13/02/12
*/

User Function USIX004()

cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicion�rio? Esta rotina deve ser utilizada em modo exclusivo."+;
                            "Fa�a um backup dos dicion�rios e da Base de Dados antes da atualiza��o.",;
                            "Aten��o")                  
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualiza��o do Dicion�rio"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Prepara��o dos Arquivos",;
                                         .F.) , Final("Atualiza��o efetuada.")),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Fun��o de processamento da grava��o dos arquivos.
*/

Static Function UPDProc(lEnd)

Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0


Local aChamados := {{04, {|| AtuSIX()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence

   ProcRegua(1)

   IncProc("Verificando integridade dos dicion�rios...")

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
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas autom�ticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparar� as fun��es
	  		    contidas no array aChamados para cada 
	  		    m�dulo. */

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
      Aviso( "Atencao", "Nao foi poss�vel a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

*----------------------*
Static Function AtuSIX()
*----------------------*
	Local cTexto  := ''
	Local aIndice := {}
	Local nI      := 1
	
	// Adicionando a tabela para ser atuallizda
	AAdd(aArqUpd, 'FI9')
	AAdd(aArqUpd, 'SED')
	
	// Indice que vou criar
	AAdd(aIndice, {'FI9', '4', 'FI9_EMISS+FI9_CODRET', 'Data Emissao + Cod. Retencao', 'U', 'S'})
	AAdd(aIndice, {'SED', '4', 'ED_DESCRIC', 'Descricao', 'U', 'S'})
	
	// Abre a six
	If Select('SIX') == 0
		DbUseArea('SIX')
	EndIf
	
	// Preparando SIX
	SIX->(DbGoTop())
	SIX->(DbSetOrder(1))
	
	// Para cada novo indice
	For nI := 1 To Len(aIndice)
		If aIndice[nI][1] == 'SED'
			If SIX->(DbSeek(aIndice[nI][1]+'3'))
				SIX->(RecLock('SIX', .F.))
				SIX->DESCRICAO := 'Filial + Descricao'
				SIX->DESCSPA := 'Sucursal + Descripcion'
				SIX->DESCENG := 'Branch + Description'
				SIX->(MsUnlock())
				cTexto += 'Descricao do indice 3 da natureza modificada' + CRLF
			EndIf
		EndIf
		
		If ! SIX->(DbSeek(aIndice[nI][1]+aIndice[nI][2]))
			SIX->(RecLock('SIX', .T.))
			SIX->INDICE := aIndice[nI][1]
			SIX->ORDEM := aIndice[nI][2]
			SIX->CHAVE := aIndice[nI][3]
			SIX->DESCRICAO := aIndice[nI][4]
			SIX->DESCSPA := aIndice[nI][4]
			SIX->DESCENG := aIndice[nI][4]
			SIX->PROPRI := aIndice[nI][5]
			SIX->SHOWPESQ := aIndice[nI][6]
			SIX->(MsUnlock())
			cTexto += 'Indice ' + aIndice[nI][3] + ' criado com sucesso' + CRLF
		Else
			cTexto += 'Indice ' + SIX->INDICE + ' na posicao ' + SIX->ORDEM + ' ja existe' + CRLF
		EndIf
	Next nI
Return cTexto
