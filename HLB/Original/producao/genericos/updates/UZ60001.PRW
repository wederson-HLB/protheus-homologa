#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : UZ60001
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Update para criar a tabela Z60 e a consulta padrão SA6Z60,SE2014
			: Adiciona os campos E2_P_IDOFX,E1_P_IDOFX,E5_P_IDOFX
Autor       : Matheus Massarotto
Data/Hora   : 18/06/2013    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*---------------------*
User Function UZ60001()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {"Z60","SE1","SE2","SE5"}
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

Local cTexto    := '' 
Local lIncSX3	:= .F.
Local lIncSX2	:= .F.
Local lIncSIX	:= .F.
Local lIncSXB	:= .F.


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

//{SX3} - Campos

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
if SX3->(!DbSeek("Z60_FILIAL"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z60_FILIAL"
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
		SX3->X3_DESCRIC:="Filial"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Filial"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Filial"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
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

//----- próximo campo

if SX3->(!DbSeek("Z60_TIPO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z60_TIPO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Tipo"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Tipo"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Tipo"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Tipo"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Tipo"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Tipo"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:="1=Tarifa;2=Rendimento"//;3=Transferência"
	SX3->X3_CBOXSPA:="1=Tarifa;2=Rendimento"//;3=Transferência"
	SX3->X3_CBOXENG:="1=Tarifa;2=Rendimento"//;3=Transferência"
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

//----- próximo campo

if SX3->(!DbSeek("Z60_BANCO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z60_BANCO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=3
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Banco"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Banco"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Banco"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Banco"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Banco"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Banco"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="SA6Z60"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SA6',M->Z60_BANCO,1)  "
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

//----- próximo campo

if SX3->(!DbSeek("Z60_DESCBC"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="04"
	SX3->X3_CAMPO:="Z60_DESCBC"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=50
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Tarifa Banco"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Tarifa Banco"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Tarifa Banco"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao tarifa banco"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descricao tarifa banco"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Descricao tarifa banco"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

//----- próximo campo

if SX3->(!DbSeek("Z60_DESCGT"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="05"
	SX3->X3_CAMPO:="Z60_DESCGT"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=50
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Nossa Tarifa"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Nossa Tarifa"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Nossa Tarifa"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao nossa tarifa"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descricao nossa tarifa"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Descricao nossa tarifa"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

//----- próximo campo

if SX3->(!DbSeek("Z60_NATURE"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="06"
	SX3->X3_CAMPO:="Z60_NATURE"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=10
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Natureza"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Natureza"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Natureza"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Natureza"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Natureza"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Natureza"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="SED"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SED',M->Z60_NATURE,1)"
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

cTexto += "Incluido/alterados os campos no SX3 da tabela Z60 "+NL 

//----- próximo campo

if SX3->(!DbSeek("Z60_CONTID"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z60"
	SX3->X3_ORDEM:="07"
	SX3->X3_CAMPO:="Z60_CONTID"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=10
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Contido"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Contido"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Contido"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Contido"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Contido"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Contido"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:="'2'"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:="1=Sim;2=Nao"
	SX3->X3_CBOXSPA:="1=Sim;2=Nao"
	SX3->X3_CBOXENG:="1=Yes;2=No"
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

cTexto += "Incluido/alterados os campos no SX3 da tabela Z60 "+NL 

//{SX2} - tabela

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z60"))
	lIncSX2:=.T.
else
	lIncSX2:=.F.
endif  

Reclock("SX2",lIncSX2)
	SX2->X2_CHAVE:="Z60"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z60"+alltrim(SM0->M0_CODIGO)+"0"
	SX2->X2_NOME:="De para taxas arquivo ofx"
	SX2->X2_NOMESPA:="De para taxas arquivo ofx"
	SX2->X2_NOMEENG:="De para taxas arquivo ofx"
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:="S"
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido/alterado no SX2 a tabela Z60 "+NL 

//{SIX} - Índice

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z60"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z60"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z60_FILIAL+Z60_TIPO+Z60_BANCO+Z60_DESCBC"
	SIX->DESCRICAO:="Tipo+Banco+Desc Banco"
	SIX->DESCSPA:="Tipo+Banco+Desc Banco"
	SIX->DESCENG:="Tipo+Banco+Desc Banco"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z60 "+NL


//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Banco"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Banco"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Bank"
	endif
	SXB->XB_CONTEM:="SA6"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
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

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Nome"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Nombre"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Name"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Conta"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Cuenta"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Account"
	endif
	SXB->XB_CONTEM:="A6_NUMCON"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Nome"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Nombre"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Name"
	endif
	SXB->XB_CONTEM:="A6_NOME"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="A6_COD"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Agencia"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Agencia"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Agency"
	endif
	SXB->XB_CONTEM:="A6_AGENCIA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"02"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Conta"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Cuenta"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Account"
	endif
	SXB->XB_CONTEM:="A6_NUMCON"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"02"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Nome"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Nombre"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Name"
	endif
	SXB->XB_CONTEM:="A6_NOME"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"02"+"07"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="07"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="A6_COD"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"4"+"02"+"08"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="08"
	SXB->XB_DESCRI:="Agencia"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Agencia"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Agency"
	endif
	SXB->XB_CONTEM:="A6_AGENCIA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SA6Z60"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SA6Z60"
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
	SXB->XB_CONTEM:="SA6->A6_COD"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta SA6Z60 para bancos "+NL 


//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Titulos a pagar"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Titulos a pagar"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Accounts Payable"
	endif
	SXB->XB_CONTEM:="SE2"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="PrefixoNumPrcTipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="PrefixoNumPrcTipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="PrefixNumPrcTipo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock()) 

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Numero"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Numero"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Numero"
	endif
	SXB->XB_CONTEM:="SE2->E2_NUM"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Parc."
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Cuota"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Installment"
	endif
	SXB->XB_CONTEM:="SE2->E2_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Type"
	endif
	SXB->XB_CONTEM:="SE2->E2_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Valor"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Valor"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Amount"
	endif
	SXB->XB_CONTEM:="Transform(SE2->E2_VALOR,PesqPict('SE2', 'E2_VALOR'))"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"4"+"01"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Prefixo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Prefijo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Prefix"
	endif
	SXB->XB_CONTEM:="SE2->E2_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE2->E2_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE2->E2_NUM"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"5"+"03"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="03"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE2->E2_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"5"+"04"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="04"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE2->E2_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE2014"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE2014"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE2->E2_SALDO>0 .AND. Alltrim(SE2->E2_TIPO) $ 'NF/BOL'"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


cTexto += "Incluido/alterado no SXB consulta SE2014 para títulos a pagar "+NL 


//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Titulos a Receber"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Titulos por cobrar"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Bills receivable"
	endif
	SXB->XB_CONTEM:="SE1"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="PrefixoNumPrcTipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="PrefixoNumPrcTipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="PrefixNumPrcTipo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock()) 

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Numero"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Numero"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Numero"
	endif
	SXB->XB_CONTEM:="SE1->E1_NUM"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Parc."
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Cuota"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Installment"
	endif
	SXB->XB_CONTEM:="SE1->E1_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Type"
	endif
	SXB->XB_CONTEM:="SE1->E1_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Valor"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Valor"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Amount"
	endif
	SXB->XB_CONTEM:="Transform(SE1->E1_VALOR,PesqPict('SE1', 'E1_VALOR'))"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"4"+"01"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Prefixo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Prefijo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Prefix"
	endif
	SXB->XB_CONTEM:="SE1->E1_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE1->E1_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE1->E1_NUM"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"5"+"03"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="03"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE1->E1_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"5"+"04"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="04"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE1->E1_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE1014"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE1014"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE1->E1_SALDO>0 .AND. Alltrim(SE1->E1_TIPO) $ 'NF/FAT'"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta SE1014 para títulos a receber "+NL 


//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Moviment bancaria"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Moviment bancaria"
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Moviment bancaria"
	endif
	SXB->XB_CONTEM:="SE5"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Tipo do doc. + Prefi"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo do doc. + Prefi"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="PrefixNumPrcTipo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock()) 


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Numero"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Numero"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Numero"
	endif
	SXB->XB_CONTEM:="SE5->E5_NUMERO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Parc."
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Cuota"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Installment"
	endif
	SXB->XB_CONTEM:="SE5->E5_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Type"
	endif
	SXB->XB_CONTEM:="SE5->E5_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Valor"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Valor"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Amount"
	endif
	SXB->XB_CONTEM:="Transform(SE5->E5_VALOR,PesqPict('SE5', 'E5_VALOR'))"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"4"+"01"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Prefixo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Prefijo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Prefix"
	endif
	SXB->XB_CONTEM:="SE5->E5_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_NUMERO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"5"+"03"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="03"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"5"+"04"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="04"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5R14"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5R14"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_RECPAG=='R' .AND. E5_RECONC==''"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta SE5R14 para mov. bancaria "+NL 


//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Moviment bancaria"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Moviment bancaria"
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Moviment bancaria"
	endif
	SXB->XB_CONTEM:="SE5"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Tipo do doc. + Prefi"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo do doc. + Prefi"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="PrefixNumPrcTipo"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock()) 


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Numero"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Numero"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Numero"
	endif
	SXB->XB_CONTEM:="SE5->E5_NUMERO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Parc."
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Cuota"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Installment"
	endif
	SXB->XB_CONTEM:="SE5->E5_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Type"
	endif
	SXB->XB_CONTEM:="SE5->E5_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Valor"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Valor"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Amount"
	endif
	SXB->XB_CONTEM:="Transform(SE5->E5_VALOR,PesqPict('SE5', 'E5_VALOR'))"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"4"+"01"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Prefixo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Prefijo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Prefix"
	endif
	SXB->XB_CONTEM:="SE5->E5_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_PREFIXO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_NUMERO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"5"+"03"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="03"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_PARCELA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"5"+"04"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="04"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("SE5P14"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="SE5P14"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="  "
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="SE5->E5_RECPAG=='P' .AND. E5_RECONC==''"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta SE5P14 para mov. bancaria "+NL 

//{SX3} -- Adição de campo para o SE2, SE1 e SE5 - no qual armazenará o id da transação do banco 

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SE1"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SE1'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("E1_P_IDOFX"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="SE1"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="E1_P_IDOFX"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=20
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Id transacao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Id transacao"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Id transacao"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Id transacao no banco"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Id transacao no banco"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Id transacao no banco"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo E1_P_IDOFX no SX3 da tabela SE1 "+NL 

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SE2"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SE2'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("E2_P_IDOFX"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="SE2"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
    endif
	SX3->X3_CAMPO:="E2_P_IDOFX"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=20
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Id transacao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Id transacao"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Id transacao"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Id transacao no banco"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Id transacao no banco"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Id transacao no banco"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo E2_P_IDOFX no SX3 da tabela SE2 "+NL

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SE5"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SE5'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("E5_P_IDOFX"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="SE5"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="E5_P_IDOFX"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=20
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Id transacao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Id transacao"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Id transacao"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Id transacao no banco"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Id transacao no banco"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Id transacao no banco"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€€"
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo E5_P_IDOFX no SX3 da tabela SE5 "+NL


***************************************
//{SX6} - Parametros
//AADD(aSX6,{X6_FIL,X6_VAR,X6_TIPO,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1,X6_DESC2,X6_DSCSPA2,X6_DSCENG2,X6_CONTEUD,X6_CONTSPA,X6_CONTENG,X6_PROPRI,X6_PYME,X6_VALID,X6_INIT,X6_DEFPOR,X6_DEFSPA,X6_DEFENG})
aSX6:={}

AADD(aSX6,{'','MV_P_OFXB','L','Controla se o programa OFX, fará somente conci','','','liação(.F.) busca do SE5 ou baixa(.T.) busca ','','','do SE1/SE2 e depois SE5','','','F','F','F','U','','','','','',''})



//função para criação
CriaSx6(aSX6,@cTexto)

***************************************

Return cTexto


*-----------------------------------*
Static Function CriaSx6(aSX6,cTexto)
*-----------------------------------*

Local lIncSX6	:= .F.

For i:=1 to len(aSX6)

	DbSelectArea("SXB")
	SX6->(DbSetOrder(1))
	if SX6->(!DbSeek(PADR(alltrim(aSX6[i][1]),2)+PADR(alltrim(aSX6[i][2]),10)))
		lIncSX6:=.T.
	else
		lIncSX6:=.F.
	endif
	
	Reclock("SX6",lIncSX6)

		SX6->X6_FIL		:=aSX6[i][1]
		SX6->X6_VAR		:=aSX6[i][2]
		SX6->X6_TIPO	:=aSX6[i][3]
		SX6->X6_DESCRIC	:=aSX6[i][4]
		if FieldPos("X6_DSCSPA")>0
			SX6->X6_DSCSPA	:=aSX6[i][5]
		endif
		if FieldPos("X6_DSCENG")>0
			SX6->X6_DSCENG	:=aSX6[i][6]
		endif
		SX6->X6_DESC1	:=aSX6[i][7]
		if FieldPos("X6_DSCSPA1")>0
			SX6->X6_DSCSPA1	:=aSX6[i][8]
		endif
		if FieldPos("X6_DSCENG1")>0
			SX6->X6_DSCENG1	:=aSX6[i][9]
		endif
		SX6->X6_DESC2	:=aSX6[i][10]
		if FieldPos("X6_DSCSPA2")>0
			SX6->X6_DSCSPA2	:=aSX6[i][11]
		endif
		if FieldPos("X6_DSCENG2")>0
			SX6->X6_DSCENG2	:=aSX6[i][12]
		endif
		SX6->X6_CONTEUD	:=aSX6[i][13]
		SX6->X6_CONTSPA	:=aSX6[i][14]
		SX6->X6_CONTENG	:=aSX6[i][15]
		SX6->X6_PROPRI	:=aSX6[i][16]
		SX6->X6_PYME	:=aSX6[i][17]
		SX6->X6_VALID	:=aSX6[i][18]
		SX6->X6_INIT	:=aSX6[i][19]
		SX6->X6_DEFPOR	:=aSX6[i][20]
		SX6->X6_DEFSPA	:=aSX6[i][21]
		SX6->X6_DEFENG	:=aSX6[i][22]

	SX6->(MsUnlock())	
	
	if lIncSX6
		cTexto += "Incluido no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL
	else
		cTexto += "Alterado no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL
	endif
	
Next

Return