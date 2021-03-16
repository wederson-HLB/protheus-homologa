#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX3011
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação da tabela Z94, Z93, Z92 e criação do campo ED_P_FLUXO com f3 na tabela Z94; e campo CN9_P_INDI com f3 no Z92
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 15/03/2012    15:54
Módulo      : UPDATE
*/

User Function USX3011()

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

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aChamados para cada 
	  		    módulo. */

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next
			/*             
			//Atualizando uma tabela sem derrubar o sistema:
			__SetX31Mode(.F.) //opcional - para não permitir alterar o SX3
			
			X31UpdTable(cAlias) //Atualiza o cAlias baseado no SX3
			
			If __GetX31Error() //Verifica se ocorreu erro
				Alert(__GetX31Trace()) //Mostra os erros
			Endif
			*/

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

*----------------------------*
  Static Function AtuSX3()
*----------------------------*

Local cTexto     := '' 

DbSelectArea("SX3")
SX3->(DbSetOrder(1))
if SX3->(!DbSeek("Z94"))
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
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z94"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z94_FILIAL"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Filial"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Filial"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Filial"  
	endif	
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Filial do Sistema"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Filial do Sistema"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Filial do Sistema"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=1
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:=""
	SX3->X3_CONTEXT:=""
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:="033"
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z94"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z94_CODIGO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Codigo"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Codigo"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Codigo"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Codigo"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Codigo"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Codigo"    
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:='ExistChav("Z94",M->Z94_CODIGO,1)'
	SX3->X3_WHEN:="IIF(INCLUI,.T.,.F.)"
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z94"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z94_DESCRI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=50
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Descricao"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Descricao"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Descricao"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Descricao"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Descricao"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Descricao"    
	endif
	SX3->X3_PICTURE:="@X"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_WHEN:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())

cTexto += "Incluido no SX3 campos da tabela Z94 "+NL 
endif


DbSelectArea("SX3")
SX3->(DbSetOrder(1))
if SX3->(!DbSeek("Z93"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z93"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z93_FILIAL"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Filial"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Filial"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Filial"  
	endif	
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Filial do Sistema"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Filial do Sistema"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Filial do Sistema"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=1
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:=""
	SX3->X3_CONTEXT:=""
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:="033"
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z93"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z93_CODIGO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Codigo"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Codigo"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Codigo"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Codigo"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Codigo"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Codigo"    
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:='ExistChav("Z93",M->Z93_CODIGO,1)'
	SX3->X3_WHEN:="IIF(INCLUI,.T.,.F.)"
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z93"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z93_NOME"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=50
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Nome"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Nome"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Nome"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Nome"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Nome"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Nome"    
	endif
	SX3->X3_PICTURE:="@X"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_WHEN:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
cTexto += "Incluido no SX3 campos da tabela Z93 "+NL 
endif


DbSelectArea("SX3")
SX3->(DbSetOrder(1))
if SX3->(!DbSeek("Z92"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z92"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z92_FILIAL"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Filial"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Filial"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Filial"  
	endif	
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Filial do Sistema"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Filial do Sistema"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Filial do Sistema"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=1
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:=""
	SX3->X3_CONTEXT:=""
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:="033"
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z92"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z92_CODIGO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Codigo"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Codigo"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Codigo"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Codigo"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Codigo"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Codigo"    
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:='ExistChav("Z92",M->Z92_CODIGO,1)'
	SX3->X3_WHEN:="IIF(INCLUI,.T.,.F.)"
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z92"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z92_NOME"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=50
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Nome"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Nome"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Nome"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Nome"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Nome"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Nome"    
	endif
	SX3->X3_PICTURE:="@X"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_WHEN:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z92"
	SX3->X3_ORDEM:="04"
	SX3->X3_CAMPO:="Z92_CODEMP"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Empresa"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Empresa"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Empresa"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Empresa"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Empresa"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Empresa"    
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="Z93"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:='ExistCpo("Z93",M->Z92_CODEMP,1)'
	SX3->X3_WHEN:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())
cTexto += "Incluido no SX3 campos da tabela Z92 "+NL 
endif


DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z94"))
Reclock("SX2",.T.)
	SX2->X2_CHAVE:="Z94"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z94YY0"
	SX2->X2_NOME:="LINHA DE FLUXO"
	if FieldPos("X2_NOMESPA")>0
	SX2->X2_NOMESPA:="LINHA DE FLUXO"
	endif
	if FieldPos("X2_NOMEENG")>0
	SX2->X2_NOMEENG:="LINHA DE FLUXO"
	endif
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:=""
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido no SX2 a tabela Z94 "+NL 
endif

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z93"))
Reclock("SX2",.T.)
	SX2->X2_CHAVE:="Z93"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z93Z40"
	SX2->X2_NOME:="EMPRESAS INDICADORAS"
	if FieldPos("X2_NOMESPA")>0
	SX2->X2_NOMESPA:="EMPRESAS INDICADORAS"
	endif
	if FieldPos("X2_NOMEENG")>0
	SX2->X2_NOMEENG:="EMPRESAS INDICADORAS"
	endif
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:=""
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido no SX2 a tabela Z93 "+NL 
endif

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z92"))
Reclock("SX2",.T.)
	SX2->X2_CHAVE:="Z92"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z92Z40"
	SX2->X2_NOME:="INDICACAO"
	if FieldPos("X2_NOMESPA")>0
	SX2->X2_NOMESPA:="INDICACAO"
	endif
	if FieldPos("X2_NOMEENG")>0
	SX2->X2_NOMEENG:="INDICACAO"
	endif
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:=""
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido no SX2 a tabela Z92 "+NL 
endif
/*
if SX2->(!DbSeek("Z98"))
Reclock("SX2",.T.)
	SX2->X2_CHAVE:="Z98"
	SX2->X2_PATH:="\DATA\"
	SX2->X2_ARQUIVO:="Z98YY0"
	SX2->X2_NOME:="EMPRESA/FILIAL PARA WORKFLOW"
	if FieldPos("X2_NOMESPA")>0
	SX2->X2_NOMESPA:="EMPRESA/FILIAL PARA WORKFLOW"
	endif
	if FieldPos("X2_NOMEENG")>0
	SX2->X2_NOMEENG:="EMPRESA/FILIAL PARA WORKFLOW"
	endif
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:="S"
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido no SX2 a tabela Z98 "+NL 
endif
*/

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z94"))
Reclock("SIX",.T.)
	SIX->INDICE:="Z94"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z94_FILIAL+Z94_CODIGO"
	SIX->DESCRICAO:="Codigo"
	if FieldPos("DESCSPA")>0
	SIX->DESCSPA:="Codigo"       
	endif	
	if FieldPos("DESCENG")>0
	SIX->DESCENG:="Codigo"
	endif
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido no SIX indice da tabela Z94 "+NL 
endif

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z93"))
Reclock("SIX",.T.)
	SIX->INDICE:="Z93"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z93_FILIAL+Z93_CODIGO"
	SIX->DESCRICAO:="Codigo"
	if FieldPos("DESCSPA")>0
	SIX->DESCSPA:="Codigo"       
	endif	
	if FieldPos("DESCENG")>0
	SIX->DESCENG:="Codigo"
	endif
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido no SIX indice da tabela Z93 "+NL 
endif

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z92"))
Reclock("SIX",.T.)
	SIX->INDICE:="Z92"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z92_FILIAL+Z92_CODIGO"
	SIX->DESCRICAO:="Codigo"
	if FieldPos("DESCSPA")>0
	SIX->DESCSPA:="Codigo"       
	endif	
	if FieldPos("DESCENG")>0
	SIX->DESCENG:="Codigo"
	endif
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido no SIX indice da tabela Z92 "+NL 
endif

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z94"))

Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z94"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Linha de Fluxo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Linha de Fluxo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Linha de Fluxo"
	endif
	SXB->XB_CONTEM:="Z94"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z94"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Codigo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z94"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Codigo"
	endif
	SXB->XB_CONTEM:="Z94_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z94"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descricao"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Descricao"
	endif
	SXB->XB_CONTEM:="Z94_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z94"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z94->Z94_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido no SXB consulta da tabela Z94 "+NL 
endif

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z93"))

Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z93"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Empresas Indicadoras"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Empresas Indicadoras"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Empresas Indicadoras"
	endif
	SXB->XB_CONTEM:="Z93"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z93"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Codigo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z93"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Codigo"
	endif
	SXB->XB_CONTEM:="Z93_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z93"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Nome"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Nome"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Nome"
	endif
	SXB->XB_CONTEM:="Z93_NOME"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z93"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z93->Z93_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido no SXB consulta da tabela Z93 "+NL 
endif


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z92"))

Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z92"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Indicacao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Indicacao"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Indicacao"
	endif
	SXB->XB_CONTEM:="Z92"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z92"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Codigo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z92"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Codigo"
	endif
	SXB->XB_CONTEM:="Z92_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z92"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Nome"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Nome"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Nome"
	endif
	SXB->XB_CONTEM:="Z92_NOME"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z92"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Empresa"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Empresa"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Empresa"
	endif
	SXB->XB_CONTEM:="Z92_CODEMP"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())
Reclock("SXB",.T.)
	SXB->XB_ALIAS:="Z92"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z92->Z92_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido no SXB consulta da tabela Z92 "+NL 
endif


//incluir na tabela SED
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If !SX3->(DbSeek("ED_P_FLUXO"))
   	RecLock("SX3",.T.)
	SX3->X3_ARQUIVO:="SED"
	SX3->X3_ORDEM:="88"
	SX3->X3_CAMPO:="ED_P_FLUXO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Cod Fluxo"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Cod Fluxo"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Cod Fluxo"  
	endif	
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Cod Fluxo"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Cod Fluxo"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Cod Fluxo"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="Z94"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())	
cTexto += "Incluido no SX3 campo ED_P_FLUXO "+NL 
endif

//incluir na tabela CN9
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If !SX3->(DbSeek("CN9_P_INDI"))
   	RecLock("SX3",.T.)
	SX3->X3_ARQUIVO:="CN9"
	SX3->X3_ORDEM:="69"
	SX3->X3_CAMPO:="CN9_P_INDI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Indicador"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Indicador"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Indicador"  
	endif	
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Indicador"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Indicador"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Indicador"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="Z92"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:='ExistCpo("Z92",M->CN9_P_INDI,1)'
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:=""
	SX3->X3_ORTOGRA:="N"
	SX3->X3_IDXFLD:="N"
SX3->(MsUnlock())	
cTexto += "Incluido no SX3 campo CN9_P_INDI "+NL 
endif


//Alterar descrição da tabela SA1
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek("A1_VEND"))
   	RecLock("SX3",.F.)

	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Vendedor"
	endif

SX3->(MsUnlock())	
cTexto += "Alterado campo A1_VEND para descricao:Vendedor "+NL 
endif
//Alterar descrição da tabela SA1
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek("A1_P_VEND"))
   	RecLock("SX3",.F.)

	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Ger Conta"
	endif

SX3->(MsUnlock())	
cTexto += "Alterado campo A1_P_VEND para descricao:Ger Conta "+NL 
endif

Return cTexto