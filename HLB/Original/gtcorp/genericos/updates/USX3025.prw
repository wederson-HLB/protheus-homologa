#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX3025
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Inclus?o do campo A1_P_CONFL
Autor       : Matheus Massarotto
Revis?o		:
Data/Hora   : 03/04/2012    14:20
M?dulo      : UPDATE
*/
*---------------------*
User Function USX3025()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"SA1"}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicion?rio? Esta rotina deve ser utilizada em modo exclusivo."+;
                            "Fa?a um backup dos dicion?rios e da Base de Dados antes da atualiza??o.",;
                            "Aten??o")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualiza??o do Dicion?rio"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Prepara??o dos Arquivos",;
                                         .F.) , Final("Atualiza??o efetuada.")),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Fun??o de processamento da grava??o dos arquivos.
*/

Static Function UPDProc(lEnd)

Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0


Local aChamados := { {04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence

   ProcRegua(1)

   IncProc("Verificando integridade dos dicion?rios...")

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
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas autom?ticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparar? as fun??es
	  		    contidas no array aChamados para cada 
	  		    m?dulo. */

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next
			/*             
			//Atualizando uma tabela sem derrubar o sistema:
			__SetX31Mode(.F.) //opcional - para n?o permitir alterar o SX3
			
			X31UpdTable(cAlias) //Atualiza o cAlias baseado no SX3
			
			If __GetX31Error() //Verifica se ocorreu erro
				Alert(__GetX31Trace()) //Mostra os erros
			Endif
			*/

			 __SetX31Mode(.F.)
			 For nX := 1 To Len(aArqUpd)
			     IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				 dbSelecTArea(aArqUpd[nx]) //CRIA A TABELA 
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
      Aviso( "Atencao", "Nao foi poss?vel a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

*----------------------------*
  Static Function AtuSX3()
*----------------------------*

Local cTexto     := '' 
Local cOrder

/*
	SX3->X3_ARQUIVO:=
	SX3->X3_ORDEM:=
	SX3->X3_CAMPO:=
	SX3->X3_TIPO:=
	SX3->X3_TAMANHO:=
	SX3->X3_DECIMAL:=
	SX3->X3_TITULO:=
	SX3->X3_TITSPA:=
	SX3->X3_TITENG:=
	SX3->X3_DESCRIC:=
	SX3->X3_DESCSPA:=
	SX3->X3_DESCENG:=
	SX3->X3_PICTURE:=
	SX3->X3_USADO:=
	SX3->X3_F3:=
	SX3->X3_NIVEL:=
	SX3->X3_RESERV:=
	SX3->X3_TRIGGER:=
	SX3->X3_PROPRI:=
	SX3->X3_BROWSE:=
	SX3->X3_VISUAL:=
	SX3->X3_CONTEXT:=
	SX3->X3_OBRIGAT:=
	SX3->X3_VLDUSER:=
	SX3->X3_CBOX:=
	SX3->X3_CBOXSPA:=
	SX3->X3_CBOXENG:=
	SX3->X3_INIBRW:=
	SX3->X3_GRPSXG:=
	SX3->X3_PYME:=
	SX3->X3_ORTOGRA:=
	SX3->X3_IDXFLD:=   
	

*/

//Pegando a ultima ordem
DbSelectArea("SX3")
SX3->(DBSetOrder(1))
SX3->(DbSeek("SA1"))

While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="SA1"
    cOrder:=SX3->X3_ORDEM
	SX3->(DbSkip())
Enddo

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("A1_P_CONFL"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="SA1"
	SX3->X3_ORDEM:=SOMA1(cOrder)
	SX3->X3_CAMPO:="A1_P_CONFL"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Conflito"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Conflito"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Conflict"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Conflito"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Conflito"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Conflict"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="???????????????"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="?A"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_WHEN:=""
	SX3->X3_CBOX:="1=OK;2=REJEITADO"
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_FOLDER:="1"
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
cTexto += "Incluido no SX3 campo A1_P_CONFL"+NL 
endif

Return cTexto