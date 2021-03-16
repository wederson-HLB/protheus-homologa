#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX6007
Objetivos   : Atualizar Parametros
Parametros  : MV_EMCONTA,MV_RELSERV,MV_EMSENHA,MV_RELAUTH,MV_RELPSW,MV_RELAUSR,MV_RELAPSW,MV_RELACNT

Autor       : Matheus
Data/Hora   : 22/05/2012
*/

User Function USX6007()

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


Local aChamados := { {04, {|| AtuSX1()}}}

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

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aChamados para cada 
	  		    módulo. */

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //JSS - ALTERADO PARA RODAR MESMO SEM ESTAR EXCLUSICO, solicitado por TIAGO MENDONÇA
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

*----------------------------*
  Static Function AtuSX1()
*----------------------------*

Local cTexto     := '' 

DbSelectArea("SX6")
SX6->(DbSetOrder(1))


if SX6->(DbSeek(xFilial("SX6")+"MV_EMCONTA"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := 'workflow@br.gt.com'
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := 'workflow@br.gt.com'
		endif
			SX6->X6_CONTEUD := 'workflow@br.gt.com'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_EMCONTA "+NL	
endif

if SX6->(DbSeek(xFilial("SX6")+"MV_RELSERV"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := 'smtplw.com.br:587'
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := 'smtplw.com.br:587'
		endif
			SX6->X6_CONTEUD := 'smtplw.com.br:587'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELSERV "+NL	
endif
if SX6->(DbSeek(xFilial("SX6")+"MV_EMSENHA"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			//SX6->X6_CONTSPA := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTSPA := 'yhTaFEcE6823'
		endif
		if FieldPos("X6_CONTENG")>0
			//SX6->X6_CONTENG := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTENG := 'yhTaFEcE6823'
		endif
			//SX6->X6_CONTEUD := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTEUD := 'yhTaFEcE6823'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_EMSENHA "+NL	
endif
if SX6->(DbSeek(xFilial("SX6")+"MV_RELAUTH"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := '.T.'
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := '.T.'
		endif
			SX6->X6_CONTEUD := '.T.'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELAUTH "+NL	
endif
if SX6->(DbSeek(xFilial("SX6")+"MV_RELPSW"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			//SX6->X6_CONTSPA := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTSPA := 'yhTaFEcE6823'
		endif
		if FieldPos("X6_CONTENG")>0
			//SX6->X6_CONTENG := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTENG := 'yhTaFEcE6823'
		endif
			//SX6->X6_CONTEUD := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
		    SX6->X6_CONTEUD := 'yhTaFEcE6823'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELPSW "+NL	
endif
if SX6->(DbSeek(xFilial("SX6")+"MV_RELAUSR"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := 'smtpgrant'
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := 'smtpgrant'
		endif
			SX6->X6_CONTEUD := 'smtpgrant'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELAUSR "+NL	
endif
if SX6->(DbSeek(xFilial("SX6")+"MV_RELAPSW"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			//SX6->X6_CONTSPA := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça. 
			SX6->X6_CONTSPA := 'yhTaFEcE6823'
		endif
		if FieldPos("X6_CONTENG")>0
			//SX6->X6_CONTENG := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTENG := 'yhTaFEcE6823'
		endif
			//SX6->X6_CONTEUD := 'Protheus@2010'//JSS - 20150609 - Solicitado via e-mail por Tiago Mendonça.
			SX6->X6_CONTEUD := 'yhTaFEcE6823'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELAPSW "+NL	
endif  
if SX6->(DbSeek(xFilial("SX6")+"MV_RELACNT"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := 'smtpgrant'
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := 'smtpgrant'
		endif
			SX6->X6_CONTEUD := 'smtpgrant'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELACNT "+NL	
endif  
if SX6->(DbSeek(xFilial("SX6")+"MV_RELSSL"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := '.T.'
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := '.T.'
		endif
			SX6->X6_CONTEUD := '.T.'
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_RELSSL "+NL	
endif
Return cTexto