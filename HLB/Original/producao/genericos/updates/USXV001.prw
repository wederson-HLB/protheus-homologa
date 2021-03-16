#INCLUDE "Protheus.ch"
/*
Funcao      : USXV001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Inclusão do Mashup de CNPJ e CEP.
Autor       : Renato Rezende     	
Data/Hora   : 17/03/2014
Revisao     :
Obs.        :
*/  
*--------------------------------*
User Function USXV001()
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


Local aChamados := { {05, {|| AtuSX5()}} } //05 - SIGAFAT

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Compartilhada 
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
Static Function AtuSX5(oProcess)
*------------------------------*
Local cTexto := "" 
Local cDest  := ""
Local nValid := 0

cDest := "\system\SXVYY0.DBF"
//Verificando se o arquivo Existe
If file(cDest)
	SXV->(DbSetOrder(1))
	SXV->(DbGoTop())
	While SXV->(!EOF())
		If Alltrim(SXV->XV_MASHUP) == "Correios.PesquisaCEP" .AND. SXV->XV_ALIAS == "SA1" 
			cTexto += "Já existe Mashups"+SXV->XV_MASHUP+CHR(13)+CHR(10)
			nValid := 1
		ElseIf Alltrim(SXV->XV_MASHUP) == "Correios.PesquisaCEP" .AND. SXV->XV_ALIAS == "SA2" 
	   		cTexto += "Já existe Mashups"+SXV->XV_MASHUP+CHR(13)+CHR(10)
	   		nValid := 1
		ElseIf Alltrim(SXV->XV_MASHUP) == "Correios.PesquisaCEP" .AND. SXV->XV_ALIAS == "SRA"
			cTexto += "Já existe Mashups"+SXV->XV_MASHUP+CHR(13)+CHR(10) 
			nValid := 1
		ElseIf Alltrim(SXV->XV_MASHUP) == "ReceitaFederal.CNPJ" .AND. SXV->XV_ALIAS == "SA1" 
			cTexto += "Já existe Mashups"+SXV->XV_MASHUP+CHR(13)+CHR(10)
			nValid := 1
		ElseIf Alltrim(SXV->XV_MASHUP) == "ReceitaFederal.CNPJ" .AND. SXV->XV_ALIAS == "SA2"   
			cTexto += "Já existe Mashups"+SXV->XV_MASHUP+CHR(13)+CHR(10)
			nValid := 1
		EndIf
		SXV->(DbSkip())
	EndDo
	If nValid == 0
		DbSelectArea("SXV")
   		SXV->(DbSetOrder(1))
		//Appendando os dados na empresa que está sendo criada. 
		Append from  &cDest
		cTexto += "- Append realizado"+CHR(13)+CHR(10)
	EndIf	
Else
	cTexto += "- Arquivo não existe na system"+CHR(13)+CHR(10)	
EndIf

Return cTexto