#INCLUDE "Protheus.ch"
/*
Funcao      : USX6012
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizar parametros para a DCTF
Autor       : Daniel Fonseca de Lira
Data/Hora   : 28/09/2012
Revisao     : 30/01/2013
Obs.        : 
*/  
*--------------------------------*
User Function USX6012(lAmbiente)
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 

Begin Sequence
   Set Dele On

   lHistorico := MsgYesNo("Deseja efetuar a atualização do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faça um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")
   lEmpenho	  := .F.
   lAtuMnu	  := .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},"Processando","Aguarde, processando preparação dos arquivos...",.F.) , Final("Atualização efetuada!")),oMainWnd:End())

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


Local aChamados := { {05, {|| AtuSX6()}} } //05 - SIGAFAT

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
	  		    contidas no array aChamados para cada módulo. */

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao !", "Não foi possível a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen )              



*------------------------------*
Static Function AtuSX6(oProcess)
*------------------------------*
	Local cTexto := "" 
	Local aDefine:= {}
	Local nI
	Local lLock
	
	IncProc("Atualizando Parametros!")
	
	// Parametro para atualizar
	aAdd(aDefine, {"MV_DCTF000" ,"0588=058806M;1150=115002M;1708=170806M;2089=208901T;2089=208901T;2089=208901T;2172=217201M;2362=236201M;2372=237201T;2372=237201T;2372=237201T;2484=248401M;3373=337301T;5952=595202Q;6012=601201T;8109=810902M;5856=585601M;1150=115002D;3208=320806M;"})
	aAdd(aDefine, {"MV_DCTF001" ,"3280=328006M;8045=804506M;9385=938502D;0561=056107M;2985=298501M;5979=597904Q;5960=596004Q;5987=598704Q;5123=512301M;"})
	aAdd(aDefine, {"MV_TPTITU"  ,"'IRF','TX','FIS','FOL','DP','NF'"})
	aAdd(aDefine, {"MV_USAFI9"  ,".T."})
	aAdd(aDefine, {"MV_PISNAT2" ,"6912/8109/4211/3102"})
	aAdd(aDefine, {"MV_COFINS2" ,"3103/4212"})
	aAdd(aDefine, {"MV_CSLL2"   ,"6702/4213"})
	aAdd(aDefine, {"MV_IRF2"    ,"4202/2105/6105"}) // Arrumar
	aAdd(aDefine, {"MV_IOF"     ,"3004"})
	aAdd(aDefine, {"MV_IRPJ"    ,"6701"})
	aAdd(aDefine, {"MV_IPI2"    ,"3105"})
	
	SX6->(DbSetOrder(1))
	
	For nI := 1 to Len(aDefine)
		// Busca o registro para atualização
		lLock := SX6->(DbSeek(xFilial("SX6") + aDefine[nI][1]))
		// Se encontrou altera, se não encontrou cria
		SX6->(RecLock("SX6", !lLock))
		
		If lLock
			// Se encontrou atualiza
			SX6->X6_CONTEUD := aDefine[nI][2]
			SX6->X6_CONTSPA := aDefine[nI][2]
			SX6->X6_CONTENG := aDefine[nI][2]
			cTexto += "Parametro " + aDefine[nI][1] + " atualizado com sucesso." + CRLF
		Else
			// Se nao encontrou tenta criar
			cTexto += "Parametro " + aDefine[nI][1] + " nao existe"
			
			If 'MV_DCTF' $ aDefine[nI][1]
				// Se for um campo 'MV_DCTFxxx' cria o campo
				cTexto += ", criando!" + CRLF
				SX6->X6_VAR      := aDefine[nI][1]
				SX6->X6_TIPO     := 'C'
				SX6->X6_DESCRIC  := 'Referencia de codigos de retencäo do sistema para '
				SX6->X6_DESC1    := 'os adotados pela DCTF com a periodicidade         '
				SX6->X6_DESC2    := 'correspondente                                    '
				SX6->X6_DSCSPA   := 'Referencia de cod. de retencion del sistema para  '
				SX6->X6_DSCSPA1  := 'los adoptados por DCTF con la periodicidad        '
				SX6->X6_DSCSPA2  := 'correspondiente                                   '
				SX6->X6_DSCENG   := 'Reference of the system withholding codes for     '
				SX6->X6_DSCENG1  := 'those adopted by DCTF with the corresponding      '
				SX6->X6_DSCENG2  := 'periodicity.                                      '
				SX6->X6_CONTEUD  := aDefine[nI][2]
				SX6->X6_CONTSPA  := aDefine[nI][2]
				SX6->X6_CONTENG  := aDefine[nI][2]
				SX6->X6_PROPRI   := 'U'
				SX6->X6_PYME     := 'S'
			Else
				// O campo ja deveria ter sido criado por update
				cTexto += ", Favor verificar!" + CRLF
			EndIf
		EndIf
		
		// Libera o registro
		SX6->(MSUNLOCK())
	Next nI
Return cTexto