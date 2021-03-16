#INCLUDE "Protheus.ch"
/*
Funcao      : USX3024
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Alterar o tamanho do campo email do cadastro do cliente e do prospect para 150 caracteres.
			  Inluir no X3_RELACAO das empresas o tratamento do preenchimento histórico na baixa. 
Autor       : Renato Rezende
Data/Hora   : 07/03/2013
Revisao     :
Obs.        :
*/  

*--------------------------------*
User Function USX3024(lAmbiente)
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {"SA1","SUS"}
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


Local aChamados := { {05, {|| AtuSX3()}} } //05 - SIGAFAT

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
Static Function AtuSX3(oProcess)
*------------------------------*
Local cTexto := ""
Local cX3Rel := ""

cX3Rel	:= 'If( AllTrim(FunName()) == "FINA100","",SE2->E2_NUM+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC"))'
cX3Rel2 := 'SE2->E2_NUM+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC")'     

SX3->(DbSetOrder(2))
//Alterar tamanho do campo email no cadastro do cliente para 150 caracteres.
If SX3->(DBSeek("A1_EMAIL"))
	RecLock("SX3", .F.)
	SX3->X3_TAMANHO := 150
	SX3->(MsUnlock())
	cTexto := " - Campo A1_EMAIL atualizado." 
EndIf

//Alterar tamanho do campo email do prospect para 150 caracteres.
If SX3->(DBSeek("US_EMAIL"))
     RecLock("SX3",.F.)
     SX3->X3_TAMANHO := 150
     SX3->(MsUnlock())
     cTexto += " - Campo US_EMAIL atualizado."
EndIf

//RRP - 08/03/2013 - Incluir caso não exista conteudo no campo X3_RELACAO
//RRP - 18/03/2013 - Alterando tratamento do E5_HISTOR para não preencher na rotina FINA100
//RRP - 19/03/2013 - Alterado tratamento através de Execblock.
If SX3->(DBSeek("E5_HISTOR"))
	If Alltrim(UPPER(SX3->X3_RELACAO)) == UPPER(cX3Rel) .OR. Alltrim(UPPER(SX3->X3_RELACAO)) == UPPER(cX3Rel2) .OR. Empty(SX3->X3_RELACAO)
		RecLock("SX3",.F.)
		//Tratamento para preencher o campo E5_HISTOR no momento da baixa.
		SX3->X3_RELACAO = 'EXECBLOCK("GTFIN002")'
		SX3->(MsUnlock())
		cTexto += " - Campo E5_HISTOR atualizado."
	EndIf
EndIf

Return cTexto