#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX3014
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação da tabela Z91 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 22/03/2012    14:20
Módulo      : UPDATE
*/

User Function USX3014()

cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"Z91","SA1"}
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
if SX3->(!DbSeek("Z91"))
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z91_FILIAL"
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z91_CODIGO"
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
	SX3->X3_VISUAL:="V"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=''
	SX3->X3_RELACAO:='GETSXENUM("Z91","Z91_CODIGO")'
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z91_OCORRE"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=10
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Ocorrencia"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Ocorrencia"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Ocorrencia"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Ocorrencia"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Ocorrencia"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Ocorrencia"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="04"
	SX3->X3_CAMPO:="Z91_MODULO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=20
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Modulo"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Modulo"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Modulo"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Modulo"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Modulo"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Modulo"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="05"
	SX3->X3_CAMPO:="Z91_X_FIL"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Fil NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Fil NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Fil NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Fil NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Fil NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Fil NF"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="06"
	SX3->X3_CAMPO:="Z91_X_DOC"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=9
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Doc NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Doc NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Doc NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Doc NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Doc NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Doc NF"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="07"
	SX3->X3_CAMPO:="Z91_X_SERI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=3
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Serie NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Serie NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Serie NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Serie NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Serie NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Serie NF"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="08"
	SX3->X3_CAMPO:="Z91_X_FORN"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Forn NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Forn NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Forn NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Forn NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Forn NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Forn NF"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="09"
	SX3->X3_CAMPO:="Z91_X_LOJA"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Loja NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Loja NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Loja NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Loja NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Loja NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Loja NF"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="10"
	SX3->X3_CAMPO:="Z91_X_TIPO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Tipo NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Tipo NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Tipo NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Tipo NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Tipo NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Tipo NF"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="11"
	SX3->X3_CAMPO:="Z91_X_RECN"
	SX3->X3_TIPO:="N"
	SX3->X3_TAMANHO:=16
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Recno NF"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Recno NF"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Recno NF"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Recno NF"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Recno NF"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Recno NF"    
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="12"
	SX3->X3_CAMPO:="Z91_DESCRI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=500
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
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="13"
	SX3->X3_CAMPO:="Z91_DATA"
	SX3->X3_TIPO:="D"
	SX3->X3_TAMANHO:=8
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Data Cpu"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Data Cpu"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Data Cpu"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Data Cpu"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Data Cpu"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Data Cpu"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="14"
	SX3->X3_CAMPO:="Z91_DATASI"
	SX3->X3_TIPO:="D"
	SX3->X3_TAMANHO:=8
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Data Sistema"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Data Sistema"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Data Sistema"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Data Sistema"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Data Sistema"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Data Sistema"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="15"
	SX3->X3_CAMPO:="Z91_HORA"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=10
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Hora"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Hora"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Hora"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Hora"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Hora"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Hora"
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="16"
	SX3->X3_CAMPO:="Z91_CODUSE"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Cod Usuario"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Cod Usuario"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Cod Usuario"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Cod Usuario"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Cod Usuario"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Cod Usuario"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="17"
	SX3->X3_CAMPO:="Z91_USER"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=20
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Usuario"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Usuario"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Usuario"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Usuario"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Usuario"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Usuario"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="18"
	SX3->X3_CAMPO:="Z91_AMBIEN"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=10
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Ambiente"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Ambiente"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Ambiente"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Ambiente"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Ambiente"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Ambiente"    
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="19"
	SX3->X3_CAMPO:="Z91_COMPUT"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=20
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Computador"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Computador"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Computador"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Computador"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Computador"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Computador"
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="20"
	SX3->X3_CAMPO:="Z91_EMPORI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Emp Origem"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Emp Origem"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Emp Origem"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Emp Origem"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Emp Origem"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Emp Origem"
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="21"
	SX3->X3_CAMPO:="Z91_FILORI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Filial Orige"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Filial Orige"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Filial Orige"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Filial Origem"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Filial Origem"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Filial Origem"
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="22"
	SX3->X3_CAMPO:="Z91_EMPDES"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Emp Destino"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Emp Destino"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Emp Destino"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Emp Destino"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Emp Destino"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Emp Destino"
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
	SX3->X3_OBRIGAT:=""
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
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="23"
	SX3->X3_CAMPO:="Z91_FILDES"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Filial Desti"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Filial Desti"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Filial Desti"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Filial Desti"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Filial Desti"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Filial Desti"
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
	SX3->X3_OBRIGAT:=""
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


cTexto += "Incluido no SX3 campos da tabela Z91 "+NL 
endif


DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z91"))
Reclock("SX2",.T.)
	SX2->X2_CHAVE:="Z91"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z91"+alltrim(SM0->M0_CODIGO)+"0"
	SX2->X2_NOME:="EXCECOES NOTAS CLIENTES GT"
	if FieldPos("X2_NOMESPA")>0
	SX2->X2_NOMESPA:="EXCECOES NOTAS CLIENTES GT"
	endif
	if FieldPos("X2_NOMEENG")>0
	SX2->X2_NOMEENG:="EXCECOES NOTAS CLIENTES GT"
	endif
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:=""
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido no SX2 a tabela Z91 "+NL 
endif

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z91"))
Reclock("SIX",.T.)
	SIX->INDICE:="Z91"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z91_FILIAL+Z91_CODIGO"
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
cTexto += "Incluido no SIX indice da tabela Z91 "+NL 
endif

//-- CRIAR CAMPOS NO SA1

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("A1_P_GERA"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="SA1"
	SX3->X3_ORDEM:="P2"
	SX3->X3_CAMPO:="A1_P_GERA"
	SX3->X3_TIPO:="L"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Gera Nf Auto"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Gera Nf Auto"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Gera Nf Auto"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Gera Nf Automaticamente"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Gera Nf Automaticamente"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Gera Nf Automaticamente"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
cTexto += "Incluido no SX3 campo A1_P_GERA"+NL 
endif
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("A1_P_BANCO"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="SA1"
	SX3->X3_ORDEM:="P3"
	SX3->X3_CAMPO:="A1_P_BANCO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=15
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Bco.Dados"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Bco.Dados"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Bco.Dados"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Banco de Dados"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Banco de Dados"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Banco de Dados"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
cTexto += "Incluido no SX3 campo A1_P_BANCO"+NL 
endif
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("A1_P_CODIG"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="SA1"
	SX3->X3_ORDEM:="P4"
	SX3->X3_CAMPO:="A1_P_CODIG"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Cod.Empresa"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Cod.Empresa"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Cod.Empresa"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Codigo da Empresa"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Codigo da Empresa"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Codigo da Empresa"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
cTexto += "Incluido no SX3 campo A1_P_CODIG"+NL 
endif
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("A1_P_CODFI"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="SA1"
	SX3->X3_ORDEM:="P5"
	SX3->X3_CAMPO:="A1_P_CODFI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=2
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Cod.Filial"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Cod.Filial"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Cod.Filial"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Codigo da Filial"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Codigo da Filial"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Codigo da Filial"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="N"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
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
cTexto += "Incluido no SX3 campo A1_P_CODFI"+NL 
endif
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("Z91_INCEXC"))
Reclock("SX3",.T.)
	SX3->X3_ARQUIVO:="Z91"
	SX3->X3_ORDEM:="24"
	SX3->X3_CAMPO:="Z91_INCEXC"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=10
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
	SX3->X3_TITULO:="Inc ou Exc"
	endif
	if FieldPos("X3_TITSPA")>0
	SX3->X3_TITSPA:="Inc ou Exc"
	endif
	if FieldPos("X3_TITENG")>0
	SX3->X3_TITENG:="Inc ou Exc"
	endif
	if FieldPos("X3_DESCRIC")>0
	SX3->X3_DESCRIC:="Inc ou Exc"
	endif
	if FieldPos("X3_DESCSPA")>0
	SX3->X3_DESCSPA:="Inc ou Exc"
	endif
	if FieldPos("X3_DESCENG")>0
	SX3->X3_DESCENG:="Inc ou Exc"
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
	SX3->X3_OBRIGAT:=""
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
cTexto += "Incluido no SX3 campo Z91_INCEXC"+NL 
endif
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(DbSeek("Z91_OCORRE"))
Reclock("SX3",.F.)
	SX3->X3_TAMANHO:=10
SX3->(MsUnlock())
cTexto += "Alterado no SX3 campo Z91_OCORRE"+NL 
endif

Return cTexto