#INCLUDE "Protheus.ch"
#Include "rwmake.ch"
/*
Funcao      : UGEN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Manuten��o de filtros salvos de tabelas.
Autor       : Jean Victor Rocha
Data/Hora   : 10/06/2013
Revisao     : 
Obs.        : 
*/ 

*--------------------------------*
User Function UGEN001(lAmbiente)
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 

Begin Sequence
   Set Dele On

   lHistorico := MsgYesNo("Deseja efetuar a atualiza��o da Tabela de Filtros Salvos? Fa�a um backup dos dicion�rios e da Base de Dados antes da atualiza��o para eventuais falhas de atualiza��o !", "Aten��o")
   lEmpenho	  := .F.
   lAtuMnu	  := .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualiza��o do Dicion�rio"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},"Processando","Aguarde, processando prepara��o dos arquivos...",.F.) , Final("Atualiza��o efetuada!")),oMainWnd:End())

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


Local aChamados := { {05, {|| Atu()}} } //05 - SIGAFAT

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

	cTabela := GetTab()                             
	If EMPTY(cTabela)
		MsgInfo("Processo abortado, tabela n�o informada!")
		lopen := .F.
	ElseIf !MSGNOYES("Deseja continuar a manuten��o para a tabela '"+cTabela+"'?")
		lopen := .F.
	EndIf

	  If lOpen
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas autom�ticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparar� as fun��es
	  		    contidas no array aChamados para cada m�dulo. */

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
Revisao     :
Obs.        :
*/ 
*---------------------------*
Static Function MyOpenSM0Ex()                 	
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Compartilhada
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao !", "N�o foi poss�vel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen )              



*------------------------------*
Static Function Atu(oProcess)
*------------------------------*
Local cTexto := "" 
If Select( "SXR" ) == 0
	For nLoop := 1 To 20

		If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
			dbUseArea( .T.,, "SXR"+cEmpAnt+"0.DBF", "SXR", .T., .F. )
		Else
			dbUseArea( .T.,, "SXR"+cEmpAnt+"0.DTC", "SXR", .T., .F. )
		Endif		

		If !Empty( Select( "SXR" ) ) 
			dbSetIndex("SXR"+cEmpAnt+"0.CDX") 
			Exit	
		EndIf
			
		Sleep( 500 ) 
	Next nLoop
EndIf

If Select( "SXR" ) == 0   
	For nLoop := 1 To 20
		If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
			dbUseArea( .T.,, "SXQ"+cEmpAnt+"0.DBF", "SXQ", .T., .F. )
		Else
			dbUseArea( .T.,, "SXQ"+cEmpAnt+"0.DTC", "SXQ", .T., .F. )
		Endif			
		If !Empty( Select( "SXQ" ) ) 
			dbSetIndex("SXQ"+cEmpAnt+"0.CDX") 
			Exit	
		EndIf
		Sleep( 500 ) 
	Next nLoop
EndIf

SXR->(DbSetOrder(1))
SXQ->(DbSetOrder(1))
If SXR->(DbSeek(cTabela))
	While SXR->(!EOF()) .and. SXR->XR_ALIAS == cTabela
        SXR->(RecLock("SXR",.F.))
        SXR->(DbDelete())
        SXR->(MSUnlock())
		SXR->(DbSkip())	
	EndDo              
	cTexto += "Encontrado ocorrencias na Tabela SXR para alias '"+cTabela+"'e apagado."+ CRLF
EndIf
If SXQ->(DbSeek(cTabela))
	While SXQ->(!EOF()) .and. SXQ->XQ_ALIAS == cTabela
        SXQ->(RecLock("SXQ",.F.))
        SXQ->(DbDelete())
        SXQ->(MSUnlock())
		SXQ->(DbSkip())	
	EndDo 
	cTexto += "Encontrado ocorrencias na Tabela SXQ para alias '"+cTabela+"'e apagado."+ CRLF
EndIf

Return cTexto


*------------------------------*
Static Function GetTab() 
*------------------------------*  
Local cTab := "" 

Private oDlg
Private cArquivo := SPACE(3)

@ 200,001 To 380,420 Dialog oDlg Title "Manuten��o de filtros..."
@ 001,002 To 089,209
@ 015,020 Say "Informe a tabela a ser retirado o filtro. " COLOR CLR_HRED, CLR_WHITE
@ 055,005 Say "Tabela " COLOR CLR_HBLUE, CLR_WHITE
@ 055,025 Get cArquivo Size 150,150
@ 070,128 BmpButton Type 01 Action ((cTab := cArquivo),Close(oDlg))
@ 070,158 BmpButton Type 02 Action Close(oDlg)
                  
ACTIVATE DIALOG oDlg  CENTERED


Return cTab