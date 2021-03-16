#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : UATUWIP
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 15/07/2013    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*---------------------*
User Function UATUWIP()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {"Z58","Z57","Z56","SA1","SUS","Z55","Z54","Z53","Z52","Z51","Z50","Z49","Z48","Z41","Z42","Z46","Z47","Z45","Z44","Z43","Z40","Z39","Z38","Z37","Z35"}
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
				 
				 If !TCCanOpen(aArqUpd[nx])
				 	CHKFILE(aArqUpd[nx]) //Crio a tabela caso ela n exista
				 Endif
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
Local cTexto:=""
    
    //Criar a tabela Z58 (Cadastro de divisões) - utilizado na proposta. 
	TabZ58(@cTexto)

    //Criar a tabela Z57 (Cadastro de natureza de serviço) - utilizado na proposta
    TabZ57(@cTexto)
    
    //Criar a tabela Z56 (Cadastro de tipos de despesas) - utilizado na proposta
    TabZ56(@cTexto)
    
    //Criar a tabela Z37 (Integração de Expense Report)
    TabZ37(@cTexto)

    //Cria o campo de sócio responsável no cadastro de clientes
    AltSA1(@cTexto)
                                      
    //Cria o campo de sócio responsável no cadastro de clientes
    AltSUS(@cTexto)
    
    //Cria a consulta padrão ALLSRA para consulta de socios no cadastro de funcionários
    SXBSRA(@cTexto)
    
    //Cria as tabelas de proposta
    AtuProp(@cTexto)
	
Return(cTexto)

Static Function TabZ58(cTexto)

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
if SX3->(!DbSeek("Z58_FILIAL"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z58"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z58_FILIAL"
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

if SX3->(!DbSeek("Z58_CODIGO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z58"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z58_CODIGO"
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
		SX3->X3_TITENG:="Code"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo de identificação"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo de identificacion"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Identification code"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:='GetSx8Num("Z58","Z58_CODIGO")'
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z58_DESCRI"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z58"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z58_DESCRI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Descricao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Descripcion"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Description"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description"
	endif
	SX3->X3_PICTURE:=""
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

if SX3->(!DbSeek("Z58_TIPO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z58"
	SX3->X3_ORDEM:="04"
	SX3->X3_CAMPO:="Z58_TIPO"
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
		SX3->X3_TITENG:="Type"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Tipo"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Tipo"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Type"
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
	SX3->X3_CBOX:="1=AUDITING;2=TAX;3=ADVISORY"
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

cTexto += "Incluido/alterados os campos no SX3 da tabela Z58 "+NL 

//{SX2} - tabela

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z58"))
	lIncSX2:=.T.
else
	lIncSX2:=.F.
endif  

Reclock("SX2",lIncSX2)
	SX2->X2_CHAVE:="Z58"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z58"+alltrim(SM0->M0_CODIGO)+"0"
	SX2->X2_NOME:="Cadastro de divisões"
	SX2->X2_NOMESPA:="Divisiones de registro"
	SX2->X2_NOMEENG:="Registration divisions"
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:="S"
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido/alterado no SX2 a tabela Z58 "+NL 

//{SIX} - Índice

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z581"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z58"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z58_FILIAL+Z58_CODIGO+Z58_TIPO"
	SIX->DESCRICAO:="Codigo+Tipo"
	SIX->DESCSPA:="Codigo+Tipo""
	SIX->DESCENG:="Code+Type"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z58 ordem 1 "+NL


DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z582"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z58"
	SIX->ORDEM:="2"
	SIX->CHAVE:="Z58_FILIAL+Z58_DESCRI"
	SIX->DESCRICAO:="Descricao"
	SIX->DESCSPA:="Descripcion"
	SIX->DESCENG:="Description"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z58 ordem 2 "+NL

//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Divisoes"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Divisiones"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Divisions"
	endif
	SXB->XB_CONTEM:="Z58"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo+Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo+Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code+type"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
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
	SXB->XB_CONTEM:="Z58_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"4"+"02"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"4"+"02"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
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
	SXB->XB_CONTEM:="Z58->Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z58->Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58   "+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta Z58 para divisões "+NL 

//Consulta com filtro para divisões

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Divisoes"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Divisiones"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Divisions"
	endif
	SXB->XB_CONTEM:="Z58"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo+Tipo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo+Tipo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code+type"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
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
	SXB->XB_CONTEM:="Z58_TIPO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"4"+"02"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"4"+"02"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
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
	SXB->XB_CONTEM:="Z58->Z58_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z58->Z58_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z58Z55"+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z58Z55"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="M->Z55_TPCTR==Z58->Z58_TIPO "
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta Z58Z55 para divisões "+NL 


Return cTexto

*-----------------------------*
Static Function TabZ57(cTexto)
*-----------------------------*
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
if SX3->(!DbSeek("Z57_FILIAL"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z57_FILIAL"
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

if SX3->(!DbSeek("Z57_CODIGO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z57_CODIGO"
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
		SX3->X3_TITENG:="Code"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo de identificação"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo de identificacion"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Identification code"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:='GetSx8Num("Z57","Z57_CODIGO")'
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z57_DESCRI"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z57_DESCRI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Descricao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Descripcion"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Description"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description"
	endif
	SX3->X3_PICTURE:=""
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

if SX3->(!DbSeek("Z57_CODDIV"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="04"
	SX3->X3_CAMPO:="Z57_CODDIV"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=6
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Divisao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Division"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Division"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo da divisão"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo da division"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Division code"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:=''
	SX3->X3_F3:="Z58"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('Z58',M->Z57_CODDIV,1)"
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

if SX3->(!DbSeek("Z57_DESCDI"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="05"
	SX3->X3_CAMPO:="Z57_DESCDI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Desc divisao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Desc divisio"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Desc divisio"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao da divisão"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion da division"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Division description"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z57_CODPRO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="06"
	SX3->X3_CAMPO:="Z57_CODPRO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("B1_COD")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Produto"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Producto"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Product"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo do produto"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo do producto"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Product code"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:=''
	SX3->X3_F3:="SB1"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SB1',M->Z57_CODPRO,1)"
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

if SX3->(!DbSeek("Z57_DESCPR"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="07"
	SX3->X3_CAMPO:="Z57_DESCPR"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Desc produto"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Desc product"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Desc product"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao do produto"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion del producto"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description product"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z57_INVPRO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="08"
	SX3->X3_CAMPO:="Z57_INVPRO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("B1_COD")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Invoice Prod"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Invoice Prod"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Invoice Prod"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Produto invoice"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Producto invoice"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Product invoice"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:=''
	SX3->X3_F3:="SB1"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SB1',M->Z57_INVPRO,1)"
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

if SX3->(!DbSeek("Z57_DESINV"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z57"
	SX3->X3_ORDEM:="09"
	SX3->X3_CAMPO:="Z57_DESINV"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Desc pro inv"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Desc pro inv"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Desc pro inv"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao invoice do produto"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion invoice del producto"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description invoice product"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

cTexto += "Incluido/alterados os campos no SX3 da tabela Z57 "+NL 

//{SX2} - tabela

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z57"))
	lIncSX2:=.T.
else
	lIncSX2:=.F.
endif  

Reclock("SX2",lIncSX2)
	SX2->X2_CHAVE:="Z57"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z57"+alltrim(SM0->M0_CODIGO)+"0"
	SX2->X2_NOME:="Cadastro de natureza servico"
	SX2->X2_NOMESPA:="Serv naturaleza de registro"
	SX2->X2_NOMEENG:="Cadastro de natureza servico"
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:="S"
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido/alterado no SX2 a tabela Z57 "+NL 

//{SIX} - Índice

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z571"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z57"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z57_FILIAL+Z57_CODIGO+Z57_DESCRI"
	SIX->DESCRICAO:="Codigo+Descricao"
	SIX->DESCSPA:="Codigo+Descripcion""
	SIX->DESCENG:="Code+Description"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z57 ordem 1 "+NL


DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z572"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z57"
	SIX->ORDEM:="2"
	SIX->CHAVE:="Z57_FILIAL+Z57_DESCRI"
	SIX->DESCRICAO:="Descricao"
	SIX->DESCSPA:="Descripcion"
	SIX->DESCENG:="Description"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z57 ordem 2 "+NL

//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Natureza de servico"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Natureza de servico"
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Natureza de servico"
	endif
	SXB->XB_CONTEM:="Z57"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo+Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo+Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code+description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z57_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z57_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Division"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Division"
	endif
	SXB->XB_CONTEM:="Z57_CODDIV"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Desc Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Divisio"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Divisio"
	endif
	SXB->XB_CONTEM:="Z57_DESCDI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"01"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Producto"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Product"
	endif
	SXB->XB_CONTEM:="Z57_CODPRO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"01"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Desc Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Product"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Product"
	endif
	SXB->XB_CONTEM:="Z57_DESCPR"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"02"+"07"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="07"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z57_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"02"+"08"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="08"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z57_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"02"+"09"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="09"
	SXB->XB_DESCRI:="Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Division"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Division"
	endif
	SXB->XB_CONTEM:="Z57_CODDIV"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"02"+"10"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="10"
	SXB->XB_DESCRI:="Desc Divisao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Divisio"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Divisio"
	endif
	SXB->XB_CONTEM:="Z57_DESCDI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"02"+"11"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="11"
	SXB->XB_DESCRI:="Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Producto"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Product"
	endif
	SXB->XB_CONTEM:="Z57_CODPRO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"4"+"02"+"12"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="12"
	SXB->XB_DESCRI:="Desc Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Product"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Product"
	endif
	SXB->XB_CONTEM:="Z57_DESCPR"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
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
	SXB->XB_CONTEM:="Z57->Z57_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z57->Z57_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z57   "+"6"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z57"
	SXB->XB_TIPO:="6"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="oGetDados:aCols[oGetDados:oBrowse:nAt][Ascan(aHeader,{|x| alltrim(x[2]) = 'Z54_CODDIV'})]==Z57->Z57_CODDIV"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


cTexto += "Incluido/alterado no SXB consulta Z57 para natureza de serviço "+NL   


//{SX7} - Gatilhos

DbSelectArea("SX7")
SX7->(DbSetOrder(1))
if SX7->(!DbSeek("Z57_CODPRO"+"001"))
	lIncSX7:=.T.
else
	lIncSX7:=.F.
endif

Reclock("SX7",lIncSX7)
	SX7->X7_CAMPO	:="Z57_CODPRO" 
	SX7->X7_SEQUENC	:="001"
	SX7->X7_REGRA	:='POSICIONE("SB1",1,xFilial("SB1")+M->Z57_CODPRO,"B1_DESC")'
	SX7->X7_CDOMIN	:="Z57_DESCPR"
	SX7->X7_TIPO	:="P"
	SX7->X7_SEEK	:="N"
	SX7->X7_ORDEM	:=0
	SX7->X7_PROPRI	:="P"
SX7->(MsUnlock())

cTexto += "Incluido/alterado no SX7 o gatilho do campo Z57_CODPRO"+NL   

DbSelectArea("SX7")
SX7->(DbSetOrder(1))
if SX7->(!DbSeek("Z57_INVPRO"+"001"))
	lIncSX7:=.T.
else
	lIncSX7:=.F.
endif

Reclock("SX7",lIncSX7)
	SX7->X7_CAMPO	:="Z57_INVPRO" 
	SX7->X7_SEQUENC	:="001"
	SX7->X7_REGRA	:='POSICIONE("SB1",1,xFilial("SB1")+M->Z57_INVPRO,"B1_DESC")'
	SX7->X7_CDOMIN	:="Z57_DESINV"
	SX7->X7_TIPO	:="P"
	SX7->X7_SEEK	:="N"
	SX7->X7_ORDEM	:=0
	SX7->X7_PROPRI	:="P"
SX7->(MsUnlock())

cTexto += "Incluido/alterado no SX7 o gatilho do campo Z57_INVPRO"+NL   

DbSelectArea("SX7")
SX7->(DbSetOrder(1))
if SX7->(!DbSeek("Z57_CODDIV"+"001"))
	lIncSX7:=.T.
else
	lIncSX7:=.F.
endif

Reclock("SX7",lIncSX7)
	SX7->X7_CAMPO	:="Z57_CODDIV" 
	SX7->X7_SEQUENC	:="001"
	SX7->X7_REGRA	:='POSICIONE("Z58",1,xFilial("Z58")+M->Z57_CODDIV,"Z58_DESCRI")'
	SX7->X7_CDOMIN	:="Z57_DESCDI"
	SX7->X7_TIPO	:="P"
	SX7->X7_SEEK	:="N"
	SX7->X7_ORDEM	:=0
	SX7->X7_PROPRI	:="P"
SX7->(MsUnlock())

cTexto += "Incluido/alterado no SX7 o gatilho do campo Z57_CODDIV"+NL   

Return cTexto

*-----------------------------*
Static Function TabZ56(cTexto)
*-----------------------------*
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
if SX3->(!DbSeek("Z56_FILIAL"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="01"
	SX3->X3_CAMPO:="Z56_FILIAL"
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

if SX3->(!DbSeek("Z56_CODIGO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="02"
	SX3->X3_CAMPO:="Z56_CODIGO"
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
		SX3->X3_TITENG:="Code"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo de identificação"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo de identificacion"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Identification code"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:='GetSx8Num("Z56","Z56_CODIGO")'
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z56_DESCRI"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="03"
	SX3->X3_CAMPO:="Z56_DESCRI"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Descricao"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Descripcion"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Description"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description"
	endif
	SX3->X3_PICTURE:=""
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

if SX3->(!DbSeek("Z56_CODPRO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="04"
	SX3->X3_CAMPO:="Z56_CODPRO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("B1_COD")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Produto"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Producto"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Product"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Codigo do produto"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Codigo do producto"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Product code"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:=''
	SX3->X3_F3:="SB1"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SB1',M->Z56_CODPRO,1)"
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

if SX3->(!DbSeek("Z56_DESCPR"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="05"
	SX3->X3_CAMPO:="Z56_DESCPR"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=100
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Desc produto"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Desc product"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Desc product"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descricao do produto"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion del producto"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Description product"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z56_NATSIM"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="06"
	SX3->X3_CAMPO:="Z56_NATSIM"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("ED_CODIGO")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Nat Reembols"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Nat Reembols"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Nat Reembols"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Natureza Reembolsavel"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Naturaleza Reembolsable"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Nature Refundable"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:=''
	SX3->X3_F3:="SED"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SED',M->Z56_NATSIM,1)"
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

if SX3->(!DbSeek("Z56_DESCNS"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="07"
	SX3->X3_CAMPO:="Z56_DESCNS"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("ED_DESCRIC")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Desc naturez"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Desc naturez"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Desc naturez"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descrição da natureza"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion del naturaleza"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Nature Description"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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

if SX3->(!DbSeek("Z56_NATNAO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="08"
	SX3->X3_CAMPO:="Z56_NATNAO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("ED_CODIGO")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Nat Nao Reem"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Nat Nao Reem"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Nat Nao Reem"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Natureza nao Reembolsavel"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="No Reembolsable"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Non Refundable"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_RELACAO:=''
	SX3->X3_F3:="SED"
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:="S"
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="A"
	SX3->X3_CONTEXT:="R"
	SX3->X3_OBRIGAT:="€"
	SX3->X3_VLDUSER:="ExistCpo('SED',M->Z56_NATNAO,1)"
	SX3->X3_CBOX:=""
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

if SX3->(!DbSeek("Z56_DESCNN"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="09"
	SX3->X3_CAMPO:="Z56_DESCNN"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("ED_DESCRIC")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Desc naturez"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Desc naturez"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Desc naturez"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Descrição da natureza"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Descripcion del naturaleza"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Nature Description"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:=""
	SX3->X3_NIVEL:=0
	SX3->X3_RESERV:="þA"
	SX3->X3_TRIGGER:=""
	SX3->X3_PROPRI:="U"
	SX3->X3_BROWSE:="S"
	SX3->X3_VISUAL:="V"
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


if SX3->(!DbSeek("Z56_TRANSP"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="10"
	SX3->X3_CAMPO:="Z56_TRANSP"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Utiliza Km?"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Utiliza Km?"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Utiliza Km?"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Transporte"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Transporte"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Transport"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
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
	SX3->X3_CBOX:="1=Sim;2=Nao"
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())

if SX3->(!DbSeek("Z56_VLRFIX"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="11"
	SX3->X3_CAMPO:="Z56_VLRFIX"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Vl.Fixo Km?"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Vl.Fixo Km?"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Vl.Fixo Km?"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Valor Fixo"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Valor Fixo"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Fixed Value"
	endif
	SX3->X3_PICTURE:=""
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
	SX3->X3_OBRIGAT:=""
	SX3->X3_VLDUSER:=""
	SX3->X3_CBOX:="1=Sim;2=Nao"
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_WHEN:="IIF( M->Z56_TRANSP<>'1',.F.,.T.)"
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())


if SX3->(!DbSeek("Z56_CARAUT"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="Z56"
	SX3->X3_ORDEM:="12"
	SX3->X3_CAMPO:="Z56_CARAUT"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=1
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Carrega Auto"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Carrega Auto"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Loads Auto"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Carrega Automaticamente"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Carrega Automaticamente"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Loads Automatically"
	endif
	SX3->X3_PICTURE:=""
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
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
	SX3->X3_CBOX:="1=Sim;2=Nao"
	SX3->X3_CBOXSPA:=""
	SX3->X3_CBOXENG:=""
	SX3->X3_INIBRW:=""
	SX3->X3_GRPSXG:=""
	SX3->X3_PYME:="N"
	SX3->X3_ORTOGRA:=""
	SX3->X3_IDXFLD:=""
SX3->(MsUnlock())


//AADD(aSX3,{'Z52','10','Z52_CARAUT','C','1','','Carrega Auto','Carrega Auto','Loads Auto','Carrega Automaticamente','Carrega Automaticamente','Loads Automatically','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','1=Sim;2=Nao','','','','','','','2','','','','','N','N','',''})
//AADD(aSX3,{'Z52','08','Z52_TRANSP','C','1','','Transporte','Transporte','Transport','Transporte','Transporte','Transport','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','1=Sim;2=Nao','','','','','','','2','','','','','N','N','',''})
//AADD(aSX3,{'Z52','09','Z52_VLRFIX','C','1','','Valor Fixo','Valor Fixo','Fixed Value','Valor Fixo','Valor Fixo','Fixed Value','','','€€€€€€€€€€€€€€ ','"2"','','','þA','','','U','N','A','R','','','1=Sim;2=Nao','','','','IIF( aCols[oGetDadDes:Obrowse:nAt][5]<>"1",.F.,.T.)','','','2','','','','','N','N','',''})


cTexto += "Incluido/alterados os campos no SX3 da tabela Z56 "+NL 

//{SX2} - tabela

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
if SX2->(!DbSeek("Z56"))
	lIncSX2:=.T.
else
	lIncSX2:=.F.
endif  

Reclock("SX2",lIncSX2)
	SX2->X2_CHAVE:="Z56"
	SX2->X2_PATH:="\SYSTEM\"
	SX2->X2_ARQUIVO:="Z56"+alltrim(SM0->M0_CODIGO)+"0"
	SX2->X2_NOME:="Cadastro de tipo de despesa"
	SX2->X2_NOMESPA:="Registro tipo de gasto"
	SX2->X2_NOMEENG:="Type of expenditure"
	SX2->X2_MODO:="C"
	SX2->X2_DELET:=0
	SX2->X2_PYME:="S"
	SX2->X2_MODULO:=0 
SX2->(MsUnlock())
cTexto += "Incluido/alterado no SX2 a tabela Z56 "+NL 

//{SIX} - Índice

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z561"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z56"
	SIX->ORDEM:="1"
	SIX->CHAVE:="Z56_FILIAL+Z56_CODIGO+Z56_DESCRI"
	SIX->DESCRICAO:="Codigo+Descricao"
	SIX->DESCSPA:="Codigo+Descripcion""
	SIX->DESCENG:="Code+Description"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z56 ordem 1 "+NL


DbSelectArea("SIX")
SIX->(DbSetOrder(1))
if SIX->(!DbSeek("Z562"))
	lIncSIX:=.T.
else
	lIncSIX:=.F.
endif

Reclock("SIX",lIncSIX)
	SIX->INDICE:="Z56"
	SIX->ORDEM:="2"
	SIX->CHAVE:="Z56_FILIAL+Z56_DESCRI"
	SIX->DESCRICAO:="Descricao"
	SIX->DESCSPA:="Descripcion"
	SIX->DESCENG:="Description"
	SIX->PROPRI:="U"
	SIX->SHOWPESQ:="S"
SIX->(MsUnlock())	
cTexto += "Incluido/alterado no SIX indice da tabela Z56 ordem 2 "+NL

//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"1"+"01"+"DB"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="DB"
	SXB->XB_DESCRI:="Tipo de despesa"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Tipo de despesa"
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Tipo de despesa"
	endif
	SXB->XB_CONTEM:="Z56"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo+Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo+Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code+description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"2"+"02"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:=""
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z56_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"01"+"02"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="02"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z56_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"01"+"03"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="03"
	SXB->XB_DESCRI:="Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Producto"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Product"
	endif
	SXB->XB_CONTEM:="Z56_CODPRO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"01"+"04"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="04"
	SXB->XB_DESCRI:="Desc Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Product"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Product"
	endif
	SXB->XB_CONTEM:="Z56_DESCPR"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"02"+"05"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="05"
	SXB->XB_DESCRI:="Descricao"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Descripcion"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Description"
	endif
	SXB->XB_CONTEM:="Z56_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"02"+"06"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="06"
	SXB->XB_DESCRI:="Codigo"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Codigo"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Code"
	endif
	SXB->XB_CONTEM:="Z56_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"02"+"07"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="07"
	SXB->XB_DESCRI:="Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Producto"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Product"
	endif
	SXB->XB_CONTEM:="Z56_CODPRO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"4"+"02"+"08"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="4"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:="08"
	SXB->XB_DESCRI:="Desc Produto"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Desc Product"       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Desc Product"
	endif
	SXB->XB_CONTEM:="Z56_DESCPR"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
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
	SXB->XB_CONTEM:="Z56->Z56_CODIGO"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("Z56   "+"5"+"02"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="Z56"
	SXB->XB_TIPO:="5"
	SXB->XB_SEQ:="02"
	SXB->XB_COLUNA:=""
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""       
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="Z56->Z56_DESCRI"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())

cTexto += "Incluido/alterado no SXB consulta Z56 para tipo de despesa "+NL   


//{SX7} - Gatilhos

DbSelectArea("SX7")
SX7->(DbSetOrder(1))
if SX7->(!DbSeek("Z56_CODPRO"+"001"))
	lIncSX7:=.T.
else
	lIncSX7:=.F.
endif

Reclock("SX7",lIncSX7)
	SX7->X7_CAMPO	:="Z56_CODPRO" 
	SX7->X7_SEQUENC	:="001"
	SX7->X7_REGRA	:='POSICIONE("SB1",1,xFilial("SB1")+M->Z56_CODPRO,"B1_DESC")'
	SX7->X7_CDOMIN	:="Z56_DESCPR"
	SX7->X7_TIPO	:="P"
	SX7->X7_SEEK	:="N"
	SX7->X7_ORDEM	:=0
	SX7->X7_PROPRI	:="P"
SX7->(MsUnlock())

cTexto += "Incluido/alterado no SX7 o gatilho do campo Z56_CODPRO"+NL   

DbSelectArea("SX7")
SX7->(DbSetOrder(1))
if SX7->(!DbSeek("Z56_NATSIM"+"001"))
	lIncSX7:=.T.
else
	lIncSX7:=.F.
endif

Reclock("SX7",lIncSX7)
	SX7->X7_CAMPO	:="Z56_NATSIM" 
	SX7->X7_SEQUENC	:="001"
	SX7->X7_REGRA	:='POSICIONE("SED",1,xFilial("SED")+M->Z56_NATSIM,"ED_DESCRIC")'
	SX7->X7_CDOMIN	:="Z56_DESCNS"
	SX7->X7_TIPO	:="P"
	SX7->X7_SEEK	:="N"
	SX7->X7_ORDEM	:=0
	SX7->X7_PROPRI	:="P"
SX7->(MsUnlock())

cTexto += "Incluido/alterado no SX7 o gatilho do campo Z56_NATSIM"+NL   

DbSelectArea("SX7")
SX7->(DbSetOrder(1))
if SX7->(!DbSeek("Z56_NATNAO"+"001"))
	lIncSX7:=.T.
else
	lIncSX7:=.F.
endif

Reclock("SX7",lIncSX7)
	SX7->X7_CAMPO	:="Z56_NATNAO" 
	SX7->X7_SEQUENC	:="001"
	SX7->X7_REGRA	:='POSICIONE("SED",1,xFilial("SED")+M->Z56_NATNAO,"ED_DESCRIC")'
	SX7->X7_CDOMIN	:="Z56_DESCNN"
	SX7->X7_TIPO	:="P"
	SX7->X7_SEEK	:="N"
	SX7->X7_ORDEM	:=0
	SX7->X7_PROPRI	:="P"
SX7->(MsUnlock())

cTexto += "Incluido/alterado no SX7 o gatilho do campo Z56_NATNAO"+NL   

Return cTexto 

*----------------------------*
Static Function TabZ37(cTexto)
*----------------------------*
Local aSIX:= {}
Local aSX2:= {}
Local aSX3:= {}

//{SIX} - Índice
//AADD(aSix,{INDICE,ORDEM,CHAVE,DESCRICAO,DESCSPA,DESCENG,PROPRI,F3,NICKNAME,SHOWPESQ})
AADD(aSix,{'Z37','1','Z37_FILIAL+Z37_ID','ID','ID','ID','U','','','S'})


//{SX2} - Tabela
//AADD(aSX2,{X2_CHAVE,X2_PATH       ,X2_ARQUIVO,X2_NOME,X2_NOMESPA,X2_NOMEENG,X2_ROTINA,X2_MODO,X2_MODOUN,X2_MODOEMP,X2_DELET,X2_TTS,X2_UNICO,X2_PYME,X2_MODULO,X2_DISPLAY,X2_SYSOBJ,X2_USROBJ})
AADD(aSX2,{'Z37','\SYSTEM\',"Z37"+alltrim(SM0->M0_CODIGO)+"0",'Int. Expense Report','Int. Expense Report','Int. Expense Report','','C','C','C','','','','S','','','',''})

//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO    ,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO     ,X3_TITSPA     ,X3_TITENG     ,X3_DESCRIC           ,X3_DESCSPA           ,X3_DESCENG         ,X3_PICTURE,X3_VALID,X3_USADO         ,X3_RELACAO                                                             ,X3_F3,X3_NIVEL,X3_RESERV,X3_CHECK,X3_TRIGGER,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_OBRIGAT,X3_VLDUSER,X3_CBOX,X3_CBOXSPA,X3_CBOXENG,X3_PICTVAR,X3_WHEN,X3_INIBRW                                                                  ,X3_GRPSXG,X3_FOLDER,X3_PYME,X3_CONDSQL,X3_CHKSQL,X3_IDXSRV,X3_ORTOGRA,X3_IDXFLD,X3_TELA,X3_AGRUP})
AADD(aSX3  ,{'Z37'     ,'01'    ,'Z37_FILIAL','C'    ,'2'       ,''        ,'Filial'      ,'Filial'      ,'Filial'      ,'Filial'             ,'Filial'             ,'Filial'           ,''        ,''      ,'€€€€€€€€€€€€€€€',''                                                                     ,''   ,''      ,'™€'     ,''      ,''        ,'U'      ,'N'      ,''       ,''        ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,'033'    ,''       ,''     ,''        ,''       ,''       ,''        ,''       ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'02'    ,'Z37_ID'    ,'C'    ,'12'      ,''        ,'ID'          ,'ID'          ,'ID'          ,'ID'                 ,'ID'                 ,'ID'               ,''        ,''      ,'€€€€€€€€€€€€€€ ',''                                                                     ,''   ,''      ,'›€'     ,''      ,''        ,'U'      ,'S'      ,'V'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,''        ,''       ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'03'    ,'Z37_USERRE','C'    ,'11'      ,''        ,'Usuario resp','Usuario resp','User resp'   ,'Usuario responsavel','Usuario responsavel','User responsible' ,''        ,''      ,'€€€€€€€€€€€€€€ ',''                                                                     ,''   ,''      ,'š€'     ,''      ,'S'       ,'U'      ,'N'      ,'V'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,''        ,''       ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'04'    ,'Z37_USERNO','C'    ,'50'      ,''        ,'Usuario nome','Usuario nome','User name'   ,'Usuario nome'       ,'Usuario nome'       ,'User name'        ,''        ,''      ,'€€€€€€€€€€€€€€ ',''                                                                     ,''   ,''      ,'š€'     ,''      ,'S'       ,'U'      ,'S'      ,'V'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,''        ,''       ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'05'    ,'Z37_CLIENT','C'    ,'6'       ,''        ,'Codigo Cli'  ,'Cod.Cliente' ,'Cod.Cliente' ,'Codigo do Cliente'  ,'Codigo do Cliente'  ,'Codigo do Cliente',''        ,''      ,'€€€€€€€€€€€€€€ ',''                                                                     ,''   ,''      ,'þÀ'     ,''      ,''        ,'U'      ,'N'      ,'A'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,'N'       ,'N'      ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'06'    ,'Z37_LOJA'  ,'C'    ,'2'       ,''        ,'Loja Cli'    ,'Loja Cli'    ,'Loja Cli'    ,'Loja do Cliente'    ,'Loja do Cliente'    ,'Loja do Cliente'  ,''        ,''      ,'€€€€€€€€€€€€€€ ',''                                                                     ,''   ,''      ,'þÀ'     ,''      ,''        ,'U'      ,'N'      ,'A'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,'N'       ,'N'      ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'07'    ,'Z37_NOMCLI','C'    ,'60'      ,''        ,'Cliente'     ,'Cliente'     ,'Cliente'     ,'Nome do Cliente'    ,'Nome do Cliente'    ,'Nome do Cliente'  ,'@!'      ,''      ,'€€€€€€€€€€€€€€ ','Posicione("SA1",1,xFilial("SA1")+M->Z37_CLIENT+M->Z37_LOJA,"A1_NOME")',''   ,''      ,'þÀ'     ,''      ,''        ,'U'      ,'S'      ,'A'      ,'V'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,'Posicione("SA1",1,xFilial("SA1")+Z37->Z37_CLIENT+Z37->Z37_LOJA,"A1_NOME")',''       ,''       ,''     ,''        ,''       ,''       ,'N'       ,'N'      ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'08'    ,'Z37_DATA'  ,'D'    ,'8'       ,''        ,'Data Inc'    ,'Data Inc'    ,'Data Inc'    ,'Data Inclusao'      ,'Data Inclusao'      ,'Data Inclusao'    ,''        ,''      ,'€€€€€€€€€€€€€€€','dDataBase'                                                            ,''   ,''      ,'š€'     ,''      ,'S'       ,'U'      ,'S'      ,'A'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,''        ,''       ,''     ,''      })
AADD(aSX3  ,{'Z37'     ,'09'    ,'Z37_HORA'  ,'C'    ,'8'       ,''        ,'Hora'        ,'Tiempo'      ,'Time'        ,'Hora'               ,'Tiempo'             ,'Time'             ,'@!'      ,''      ,'€€€€€€€€€€€€€€ ','Time()'                                                               ,''   ,''      ,'þÀ'     ,''      ,''        ,'U'      ,'S'      ,'A'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,'N'       ,'N'      ,''     ,''      })
AADD(aSX3,  {'Z37'     ,'10'    ,'Z37_USERGI','C'    ,'17'      ,''        ,'Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao'    ,'Log de Inclusao'    ,'Log de Inclusao'  ,''        ,''      ,'€€€€€€€€€€€€€€€',''                                                                     ,''   ,'9'     ,'þÀ'     ,''      ,''        ,'L'      ,'N'      ,'V'      ,'R'       ,''        ,''        ,''     ,''        ,''        ,''        ,''     ,''                                                                         ,''       ,''       ,''     ,''        ,''       ,''       ,'N'       ,'N'      ,''     ,''      })

//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx3(aSX3,@cTexto)

CriaSx2(aSX2,@cTexto)

CriaSix(aSIX,@cTexto) 

Return cTexto

*-----------------------------*
Static Function AltSA1(cTexto)
*-----------------------------*
Local lIncSX3	:= .F.

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SA1"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SA1'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("A1_P_SOCIO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="SA1"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="A1_P_SOCIO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("RA_CIC")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Socio Respo"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Contributivo"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Contributory"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Socio Responsavel"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Contributivo"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Contributory"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="Z42SOC"
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
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo A1_P_SOCIO no SX3 da tabela SA1 "+NL


Return

*-----------------------------*
Static Function AltSUS(cTexto)
*-----------------------------*
Local lIncSX3	:= .F.

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SUS"}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SUS'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(!DbSeek("US_P_SOCIO"))
	lIncSX3:=.T.
else
	lIncSX3:=.F.
endif

Reclock("SX3",lIncSX3)
	SX3->X3_ARQUIVO:="SUS"
	if lIncSX3
		SX3->X3_ORDEM:=cUltOrdem
	endif
	SX3->X3_CAMPO:="US_P_SOCIO"
	SX3->X3_TIPO:="C"
	SX3->X3_TAMANHO:=TamSX3("RA_CIC")[1]
	SX3->X3_DECIMAL:=0
	if FieldPos("X3_TITULO")>0
		SX3->X3_TITULO:="Socio Respo"
	endif
	if FieldPos("X3_TITSPA")>0
		SX3->X3_TITSPA:="Contributivo"
	endif
	if FieldPos("X3_TITENG")>0
		SX3->X3_TITENG:="Contributory"
	endif
	if FieldPos("X3_DESCRIC")>0
		SX3->X3_DESCRIC:="Socio Responsavel"
	endif
	if FieldPos("X3_DESCSPA")>0
		SX3->X3_DESCSPA:="Contributivo"
	endif
	if FieldPos("X3_DESCENG")>0
		SX3->X3_DESCENG:="Contributory"
	endif
	SX3->X3_PICTURE:="@!"
	SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->X3_F3:="Z42SOC"
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
	SX3->X3_FOLDER:="1"
SX3->(MsUnlock())

cTexto += "Incluido/alterados o campo US_P_SOCIO no SX3 da tabela SUS "+NL


Return


*------------------------------*
Static Function	SXBSRA(cTexto)
*------------------------------*
Local lIncSXB	:= .F.

//{SXB}  - Consulta padrão
//indice - XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("ALLSRA"+"1"+"01"+"RE"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="ALLSRA"
	SXB->XB_TIPO:="1"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="RE"
	SXB->XB_DESCRI:="Consulta Socios"
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:="Consulta Socios"
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:="Consulta Socios"
	endif
	SXB->XB_CONTEM:="SRA"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("ALLSRA"+"2"+"01"+"01"))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="ALLSRA"
	SXB->XB_TIPO:="2"
	SXB->XB_SEQ:="01"
	SXB->XB_COLUNA:="01"
	SXB->XB_DESCRI:=""
	if FieldPos("XB_DESCSPA")>0
	SXB->XB_DESCSPA:=""
	endif	
	if FieldPos("XB_DESCENG")>0
	SXB->XB_DESCENG:=""
	endif
	SXB->XB_CONTEM:="U_GTSXB001()"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))
if SXB->(!DbSeek("ALLSRA"+"5"+"01"+"  "))
	lIncSXB:=.T.
else
	lIncSXB:=.F.
endif          
Reclock("SXB",lIncSXB)
	SXB->XB_ALIAS:="ALLSRA"
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
	SXB->XB_CONTEM:="DADTRB->CPF"
	SXB->XB_WCONTEM:=""
SXB->(MsUnlock())


cTexto += "Incluido/alterado no SXB consulta ALLSRA para pesquisa do sócio "+NL   

Return

//proposta
*------------------------------*
Static Function AtuProp(cTexto)
*------------------------------*
Local aSX7:= {}
Local aSX3:= {}
Local aSX2:= {}
Local aSIX:= {}
Local aSXB:= {}
Local aSX6:= {}

Local aDelSX7:={}

************************************************************************************************************************************
//{SIX} - Índice
//AADD(aSix,{INDICE,ORDEM,CHAVE,DESCRICAO,DESCSPA,DESCENG,PROPRI,F3,NICKNAME,SHOWPESQ})

AADD(aSix,{'Z55','1','Z55_FILIAL+Z55_TPCTR+Z55_NUM+Z55_REVISA','Tipo+Num+Revisao','Tipo+Num+Revisao','Tipo+Num+Revisao','U','','','S'})
AADD(aSix,{'Z55','2','Z55_FILIAL+Z55_NUM','Num','Num','Num','U','','','S'})

AADD(aSix,{'Z54','1','Z54_FILIAL+Z54_CODIGO','Codigo','Codigo','Codigo','U','','','S'})
AADD(aSix,{'Z54','2','Z54_FILIAL+Z54_NUMPRO+Z54_REVISA+Z54_CODIGO','Proposta+Revisao+Codigo','Proposta+Revisao+Codigo','Proposta+Revisao+Codigo','U','','','S'})

AADD(aSix,{'Z53','1','Z53_FILIAL+Z53_CODIGO','Codigo','Codigo','Codigo','U','','','S'})

AADD(aSix,{'Z52','1','Z52_FILIAL+Z52_NUMPRO+Z52_REVISA+Z52_ITEM+Z52_CODIGO','Proposta+Revisao+Item+Cod Despesa','Proposta+Revisao+Item+Cod Despesa','Proposta+Revisao+Item+Cod Despesa','U','','','S'})

AADD(aSix,{'Z51','1','Z51_FILIAL+Z51_NUM','Num proposta','Num proposta','Num proposta','U','','','S'})

AADD(aSix,{'Z50','1','Z50_FILIAL+Z50_ID+Z50_PROPOS+Z50_REVISA','Codigo+Proposta+Revisao','Codigo+Propuesta+Revision','Code+Propuesta+Revision','U','','','S'})
AADD(aSix,{'Z50','2','Z50_FILIAL+Z50_PROPOS+Z50_REVISA','Proposta+Revisao','Propuesta+Revision','Proposal+Revision','U','','','S'})

AADD(aSix,{'Z49','1','Z49_FILIAL+Z49_PROPOS+Z49_REVISA+Z49_TIPO+Z49_PARCEL','Proposta+Revisao+Tipo+Parcela','Propuesta+Revision+Tipo+Parte','Proposal+Revision+Tipo+Parte','U','','','S',''})

AADD(aSix,{'Z48','1','Z48_FILIAL+Z48_PROPOS+Z48_REVISA+Z48_ITEM','Proposta+Revisao+Item','Proposta+Revisao+Item','Proposta+Revisao+Item','U','','','S'})

AADD(aSix,{'Z41','1','Z41_FILIAL+Z41_IDUSER+Z41_IDDEPE','Id Usuario+Id Dependent','Id Usuario+Id Dependien','Id User+Id Dependien','U','','','S'})
AADD(aSix,{'Z41','2','Z41_FILIAL+Z41_ITEM+Z41_IDUSER+Z41_IDDEPE','Item+Id Usuario+Id Dependent','Item+Id Usuario+Id Dependent','Item+Id Usuario+Id Dependent','U','','','S'})
AADD(aSix,{'Z41','3','Z41_FILIAL+Z41_IDUSER+Z41_NOUSER','Id Usuario+Nome Usuario','Id Usuario+Nome Usuario','Id Usuario+Nome Usuario','U','','','S'})

AADD(aSix,{'Z42','1','Z42_FILIAL+Z42_IDUSER','Id Usuario'	,'Id Usuario' ,'Id User','U','','','S'})
AADD(aSix,{'Z42','2','Z42_FILIAL+Z42_CPF'	,'Cpf'			,'Cpf'		  ,'Cpf','U','','','S'})
AADD(aSix,{'Z42','3','Z42_FILIAL+Z42_NOMEFU','Nome funcio'	,'Nome funcio','Nome funcio','U','','','S'})

AADD(aSix,{'Z47','1','Z47_FILIAL+Z47_CODIGO','Codigo','Codigo','Code','U','','','S'})

AADD(aSix,{'Z46','1','Z46_FILIAL+Z46_CODACA+Z46_ITEM+Z46_CODLEG','Codigo acao+Sequencia+Cod Legenda','Codigo acao+Sequencia+Cod Legenda','Codigo acao+Sequencia+Cod Legenda','U','','','S'})

AADD(aSix,{'Z45','1','Z45_FILIAL+Z45_CODIGO','Codigo','Codigo','Code','U','','','S'})

AADD(aSix,{'Z44','1','Z44_FILIAL+Z44_CODLEG+Z44_ITEM+Z44_CODACA','Cod Legenda+Sequencia+Codigo acao','Cod Legenda+Sequencia+Codigo acao','Cod Legenda+Sequencia+Codigo acao','U','','','S'})

AADD(aSix,{'Z43','1','Z43_FILIAL+Z43_PROPOS+Z43_REVISA+Z43_SEQ+Z43_CODLEG','Proposta+Revisao+Sequencia+Cod Legenda','Proposta+Revisao+Sequencia+Cod Legenda','Proposta+Revisao+Sequencia+Cod Legenda','U','','','S'})

AADD(aSix,{'Z40','1','Z40_FILIAL+Z40_PROSPE+Z40_PLOJA+Z40_ITEM','Prospect+Prosp Loja+Item','Prospect+Prosp Loja+Item','Prospect+Prosp Loja+Item','U','','','S'})
AADD(aSix,{'Z40','2','Z40_FILIAL+Z40_CGC','CGC','CGC','CGC','U','','','S'})
                                      
AADD(aSix,{'Z39','1','Z39_FILIAL+Z39_CODIGO','Codigo','Codigo','Code','U','','','S'})

AADD(aSix,{'Z38','1','Z38_FILIAL+Z38_CLIENT+Z38_CLOJA+Z38_ITEM','Cliente+Cliente Loja+Item','Cliente+Cliente Loja+Item','Cliente+Cliente Loja+Item','U','','','S'})

AADD(aSix,{'Z35','1','Z35_FILIAL+Z35_PROPOS+Z35_REVISA+Z35_ITEM','Proposta+Revisao+Item','Proposta+Revisao+Item','Proposta+Revisao+Item','U','','','S'})

//AADD(aSix,{'Z45','1','Z45_FILIAL+Z45_CODACA+Z45_ITEM+Z45_CAMPO','Codigo acao+Item+Campo','Codigo acao+Item+Campo','Codigo acao+Item+Campo','U','','','S'})

************************************************************************************************************************************
//{SX2} - Tabela
//AADD(aSX2,{X2_CHAVE,X2_PATH,X2_ARQUIVO,X2_NOME,X2_NOMESPA,X2_NOMEENG,X2_ROTINA,X2_MODO,X2_MODOUN,X2_MODOEMP,X2_DELET,X2_TTS,X2_UNICO,X2_PYME,X2_MODULO,X2_DISPLAY,X2_SYSOBJ,X2_USROBJ})

AADD(aSX2,{'Z55','\SYSTEM\','Z55'+alltrim(SM0->M0_CODIGO)+'0','Capa Novo Contr Proposta','Capa Novo Contr Proposta','Capa Cad Controle Proposta','','E','E','E','','','','S','','','',''})

AADD(aSX2,{'Z54','\SYSTEM\','Z54'+alltrim(SM0->M0_CODIGO)+'0','Serv Novo Contr Proposta','Serv Novo Contr Proposta','Serv Novo Contr Proposta','','E','E','E','','','','S','','','',''})

AADD(aSX2,{'Z53','\SYSTEM\','Z53'+alltrim(SM0->M0_CODIGO)+'0','Proj Novo Contr Proposta','Proj Novo Contr Proposta','Proj Novo Contr Proposta','','E','E','E','','','','S','','','',''})

AADD(aSX2,{'Z52','\SYSTEM\','Z52'+alltrim(SM0->M0_CODIGO)+'0','Despesa x Nova proposta' ,'Despesa x Nova proposta' ,'Despesa x Nova proposta' ,'','E','E','E','','','','S','','','',''})

AADD(aSX2,{'Z51','\SYSTEM\','Z51YY0','Sequencia Nova Proposta' ,'Sequencia Nova Proposta' ,'Sequencia Nova Proposta' ,'','C','C','C','','','','S','','','',''})

AADD(aSX2,{'Z50','\SYSTEM\','Z50'+alltrim(SM0->M0_CODIGO)+'0','% Andamento Nova Proposta','% Progreso Nueva Propuesta','% Progress New Proposal','','E','E','E','','','','','','','',''})

AADD(aSX2,{'Z49','\SYSTEM\','Z49'+alltrim(SM0->M0_CODIGO)+'0','Pagtos Nova Proposta','Pagos Nueva Propuesta','New Proposal Payments','','E','E','E','','','','','','','',''})

AADD(aSX2,{'Z48','\SYSTEM\','Z48'+alltrim(SM0->M0_CODIGO)+'0','Anexos Nova Proposta','Anexos Nueva Proposta','Annex New Proposal','','E','E','E','','','','','','','',''})

AADD(aSX2,{'Z41','\SYSTEM\','Z41'+alltrim(SM0->M0_CODIGO)+'0','Itens controle alcada proposta','Itens controle alcada proposta','Itens controle alcada proposta','','C','','','','','','','','','',''})

AADD(aSX2,{'Z42','\SYSTEM\','Z42'+alltrim(SM0->M0_CODIGO)+'0','Capa controle alcada proposta','Capa controle alcada proposta','Capa controle alcada proposta','','C','','','','','','','','','',''})

AADD(aSX2,{'Z47','\SYSTEM\','Z47'+alltrim(SM0->M0_CODIGO)+'0','Capa controle acoes proposta','Capa controle acoes proposta','Capa controle acoes proposta','','C','','','','','','','','','',''})

AADD(aSX2,{'Z46','\SYSTEM\','Z46'+alltrim(SM0->M0_CODIGO)+'0','Itens controle acoes proposta','Itens controle acoes proposta','Itens controle acoes proposta','','C','','','','','','','','','',''})

AADD(aSX2,{'Z45','\SYSTEM\','Z45'+alltrim(SM0->M0_CODIGO)+'0','Capa controle legenda proposta','Capa controle legenda proposta','Capa controle legenda proposta','','C','','','','','','','','','',''})

AADD(aSX2,{'Z44','\SYSTEM\','Z44'+alltrim(SM0->M0_CODIGO)+'0','Itens controle legenda proposta','Itens controle legenda proposta','Itens controle legenda proposta','','C','','','','','','','','','',''})
                                                     
AADD(aSX2,{'Z43','\SYSTEM\','Z43'+alltrim(SM0->M0_CODIGO)+'0','Log de movimentacao proposta','Log de movimentacao proposta','Log de movimentacao proposta','','C','','','','','','','','','',''})

AADD(aSX2,{'Z40','\SYSTEM\','Z40'+alltrim(SM0->M0_CODIGO)+'0','Empresas vinculadas ao prospect','Empresas vinculadas ao prospect','Empresas vinculadas ao prospect','','C','','','','','','','','','',''})

AADD(aSX2,{'Z39','\SYSTEM\','Z39YY0','Km padrao empresa' ,'Km padrao empresa' ,'Km padrao empresa' ,'','C','C','C','','','','S','','','',''})

AADD(aSX2,{'Z38','\SYSTEM\','Z38'+alltrim(SM0->M0_CODIGO)+'0','Km e Unidade de clientes','Km e Unidade de clientes','Km e Unidade de clientes','','C','','','','','','','','','',''})

AADD(aSX2,{'Z35','\SYSTEM\','Z35'+alltrim(SM0->M0_CODIGO)+'0','Grupo de Empresas na Proposta','Grupo de Empresas na Proposta','Grupo de Empresas na Proposta','','E','E','E','','','','','','','',''})

//AADD(aSX2,{'Z45','\SYSTEM\','Z45'+alltrim(SM0->M0_CODIGO)+'0','Campos controle acoes proposta','Campos controle acoes proposta','Campos controle acoes proposta','','C','','','','','','','','','',''})

************************************************************************************************************************************
//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_TITSPA,X3_TITENG,X3_DESCRIC,X3_DESCSPA,X3_DESCENG,X3_PICTURE,X3_VALID,X3_USADO,X3_RELACAO,X3_F3,X3_NIVEL,X3_RESERV,X3_CHECK,X3_TRIGGER,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_OBRIGAT,X3_VLDUSER,X3_CBOX,X3_CBOXSPA,X3_CBOXENG,X3_PICTVAR,X3_WHEN,X3_INIBRW,X3_GRPSXG,X3_FOLDER,X3_PYME,X3_CONDSQL,X3_CHKSQL,X3_IDXSRV,X3_ORTOGRA,X3_IDXFLD,X3_TELA,X3_AGRUP})

//capa da proposta
AADD(aSX3,{'Z55','01','Z55_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z55','02','Z55_DRAFT','C','12','','Draft','Draft','Draft','Numero Draft','Numero Draft','Numero Draft','','','€€€€€€€€€€€€€€€','','Z74','','š€','','S','U','N','A','R','','ExistCpo("Z74", M->Z55_DRAFT, 2)','','','','','','','','1','','','','','','','',''})

AADD(aSX3,{'Z55','03','Z55_DESCST','C','30','','Status','Status','Status','Status','Status','Status','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})

AADD(aSX3,{'Z55','04','Z55_TPCTR','C','1','','Tipo','Tipo','Tipo','Tipo Contrato','Tipo Contrato','Tipo Contrato','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','1=AUDITING;2=TAX;3=ADVISORY','','','','IIF(!empty(M->Z55_DRAFT),.F.,.T.)','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','05','Z55_NUM','C','12','','Numero','Numero','Numero','Numero','Numero','Numero','','','€€€€€€€€€€€€€€ ','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','06','Z55_REVISA','C','3','','Revisao','Revisar','Review','Revisao','Revisar','Review','','','€€€€€€€€€€€€€€ ','IIF(INCLUI,"000","")','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','07','Z55_REVATU','C','3','','Rev. Atual','Rev. Corrien','Rev. Current','Reviao Atual','Revisar Corriente','Review Current','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','08','Z55_RESPON','C','6','','Responsavel','Responsavel','Responsavel','Responsavel','Responsavel','Responsavel','','','€€€€€€€€€€€€€€€','','Z41RES','','š€','','S','U','N','A','R','','IIF(!empty(M->Z55_RESPON),ExistCpo("Z41",M->Z55_RESPON, 1) .AND. U_GTCORP58("RESPONSAVEL","MSG"),.T.)','','','','','IIF(!empty(M->Z55_DRAFT),.F.,.T.)','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','09','Z55_NOMERE','C','100','','Nome Respon','Nome Respon','Nome Respon','Nome Responsavel','Nome Responsavel','Nome Responsavel','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})

AADD(aSX3,{'Z55','10','Z55_GLOBAL','C','1','','Referenciado','Referenciado','Referenciado','Referenciado','Referenciado','Referenciado','','Vazio() .or. Pertence("12")','€€€€€€€€€€€€€€ ','"2"','','','þA','','S','U','N','A','R','','','1=Sim;2=Nao','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','11','Z55_GLOCOB','C','1','','Tp. Cobrança','Tp. Cobrança','Tp. Cobrança','Tipo de Cobrança','Tipo de Cobrança','Tipo de Cobrança','','Vazio() .or. Pertence("12")','€€€€€€€€€€€€€€ ','','','','þA','','S','U','N','A','R','','','1=Local;2=Global','','','','IIF(M->Z55_GLOBAL<>"1",.F.,.T.)','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','12','Z55_CLIGLO','C','50','','Referencia','Referencia','Referencia','Nome Referencia','Nome Referencia','Nome Referencia','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','A','R','','','','','','','IIF(M->Z55_GLOBAL<>"1",.F.,.T.)','','','1','','','','','','','',''})

AADD(aSX3,{'Z55','13','Z55_TIPCLI','C','1','','Tipo Cliente','Tipo Cliente','Tipo Cliente','Tipo Cliente','Tipo Cliente','Tipo Cliente','','Pertence("12")','€€€€€€€€€€€€€€ ','"1"','','','š€','','S','U','S','A','R','','','1=Novo;2=Recorrente','1=Novo;2=Recorrente','1=Novo;2=Recorrente','','!M->Z55_GLOCOB == "2"','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','14','Z55_PROSPE','C','6','','Prospect','Prospect','Prospect','Prospect','Prospect','Prospect','','','€€€€€€€€€€€€€€ ','','SUSZ86','','š€','','S','U','S','A','R','','IIF(!empty(M->Z55_PROSPE),ExistCpo("SUS", M->Z55_PROSPE+M->Z55_PLOJA,1) .and. U_Z55_PROS() ,.T.)','','','','','M->Z55_TIPCLI == "1"','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','15','Z55_PLOJA','C','2','','Prosp Loja','Prosp Loja','Prosp Loja','Prospect Loja','Prospect Loja','Prospect Loja','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','IIF(!empty(M->Z55_PLOJA),ExistCpo("SUS", M->Z55_PROSPE+M->Z55_PLOJA,1),.T.) .and. U_Z55_PROS()','','','','','M->Z55_TIPCLI == "1"','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','16','Z55_PNOME','C','100','','Nome Prosp','Nome Prosp','Nome Prosp','Nome Prospect','Nome Prospect','Nome Prospect','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','17','Z55_CLIENT','C','6','','Cliente','Cliente','Cliente','Cliente','Cliente','Cliente','','','€€€€€€€€€€€€€€ ','','SA1','','š€','','S','U','S','A','R','','IIF(!empty(M->Z55_CLIENT),(If(ExistCpo("SA1", M->Z55_CLIENT+M->Z55_LOJA, 1),U_CarregaZ35(),.F.)),.T. )','','','','','M->Z55_TIPCLI == "2"','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','18','Z55_LOJA','C','2','','Loja','Loja','Loja','Loja Cliente','Loja Cliente','Loja Cliente','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','IIF(!empty(M->Z55_LOJA),(If(ExistCpo("SA1", M->Z55_CLIENT+M->Z55_LOJA, 1),U_CarregaZ35(),.F.)),.T. )','','','','','M->Z55_TIPCLI == "2"','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','19','Z55_NOME','C','100','','Nome Cli','Nome Cli','Nome Cli','Nome Cliente','Nome Cliente','Nome Cliente','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})

AADD(aSX3,{'Z55','20','Z55_REFERE','C','50','','Referencia','Referencia','Referencia','Referencia','Referencia','Referencia','','','€€€€€€€€€€€€€€€','','Z92Z55','','š€','','S','U','N','A','R','','ExistCpo("Z92", M->Z55_REFERE, 3)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','21','Z55_DESCRE','C','100','','Nome Refere','Nome Refere','Nome Refere','Nome Referencia','Nome Referencia','Nome Referencia','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','22','Z55_SOCIO','C',cvaltochar(TamSX3("RA_CIC")[1]),'','Socio','Socio','Partner','Socio','Socio','Partner','@!','','€€€€€€€€€€€€€€ ','','Z42SOC','','þA','','S','U','N','A','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','23','Z55_NOMESO','C','100','','Nome Socio','Nome Socio','Partner Name','Nome Socio','Nome Socio','Partner Name','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','24','Z55_GERENT','C',cvaltochar(TamSX3("RA_CIC")[1]),'','Gerente','Gerente','Manager','Gerente','Gerente','Manager','@!','','€€€€€€€€€€€€€€ ','','Z42SOC','','þA','','S','U','N','A','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','25','Z55_NOMEGE','C','100','','Nome Gerente','Nome Gerente','Manager Name','Nome Gerente','Nome Gerente','Manager Name','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','26','Z55_MOEDA','C','2','','Moeda','Moneda','Currency','Moeda','Moneda','Currency','@!','','€€€€€€€€€€€€€€ ','"01"','CTO','','›€','','S','U','S','A','R','','ExistCpo("CTO", M->Z55_MOEDA, 1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','27','Z55_VALOR','N','14','2','Vlr Venda','Vlr Venda','Vlr Venda','Valor Venda','Valor Venda','Valor Venda','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','À€','','S','U','N','A','R','','','','','','','IIF(M->Z55_TPVLR=="2",.F.,.T.)','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','28','Z55_DESPER','N','6','2','% Desconto','% Desconto','% Desconto','% Desconto','% Desconto','% Desconto','@E 999.99','','€€€€€€€€€€€€€€€','','','','À€','','S','U','N','A','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','29','Z55_DESCON','N','14','2','Desconto','Desconto','Desconto','Desconto','Desconto','Desconto','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','À€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','30','Z55_TPVLR','C','1','','Utiliza Vlr','Utiliza Vlr','Uses Value','Utiliza Vlr','Utiliza Vlr','Uses Value','','','€€€€€€€€€€€€€€€','"1"','','','š€','','S','U','N','V','R','','','1=Valor Venda;2=Valor c/ Imposto','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','31','Z55_VLRINI','N','14','2','Vlr Inicial','Vlr Inicial','Vlr Inicial','Vlr Inicial','Vlr Inicial','Vlr Inicial','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})

AADD(aSX3,{'Z55','32','Z55_VLRCAL','N','14','2','Vlr calcul','Vlr calcul','Vlr calcul','Valor calculado','Valor calculado','Valor calculado','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','33','Z55_VLRLIQ','N','14','2','Vlr liquid','Vlr liquid','Vlr liquid','Valor liquido','Valor liquido','Valor liquido','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','34','Z55_SURCHA','N','6','2' ,'% Surcharge','% Surcharge','% Surcharge','Surcharge','Surcharge','Surcharge','@E 999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','35','Z55_VLRLIS','N','14','2','Vlr liq+sur','Vlr liq+sur','Vlr liq+sur','Valor liquido + surcharge','Valor liquido + surcharge','Valor liquido + surcharge','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','36','Z55_IMPOST','N','6','2' ,'% Imposto','% Imposto','% Imposto','% Imposto','% Imposto','% Imposto','@E 999.99','','€€€€€€€€€€€€€€ ','val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})

AADD(aSX3,{'Z55','37','Z55_VLRTOT','N','14','2','Vlr Bruto','Vlr Bruto','Vlr Bruto','Vlr Bruto','Valor bruto','Valor bruto','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})

AADD(aSX3,{'Z55','38','Z55_TIPOCT','C','1','','Tipo CT','Tipo CT','Type CT','Tipo Contrato','Tipo Contrato','Type Contract','','','€€€€€€€€€€€€€€€','','','','›€','','S','U','N','A','R','','','1=Fixo;2=Hora;3=Flex','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','39','Z55_VLREXT','N','14','2','Vlr H Extra','Vlr H Extra','Vlr H Extra','Valor Hora Extra','Valor Hora Extra','Valor Hora Extra','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','40','Z55_VLDIPJ','N','14','2','Vlr DIPJ','Vlr DIPJ','Vlr DIPJ','Valor DIPJ','Valor DIPJ','Valor DIPJ','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','41','Z55_VLRANO','N','14','2','Vlr Anuidade','Vlr Anuidade','Vlr Anuidade','Valor Anuidade','Valor Anuidade','Valor Anuidade','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','42','Z55_VLRIMP','N','14','2','Vlr Implant','Vlr Implant','Vlr Implant','Valor Implantacao','Valor Implantacao','Valor Implantacao','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','43','Z55_VLDPFI','N','14','2','Vlr Desp fix','Vlr Desp fix','Vlr Desp fix','Valor Despesas fixas','Valor Despesas fixas','Value Fixed expenses','@E 99,999,999,999.99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','44','Z55_TIME','C','8','','Horas Calcul','Horas Calcul','Hours Calcul','Horas Calculadas','Horas Calculadas','Hours Calculated','','','€€€€€€€€€€€€€€€','','','','À€','','S','U','N','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z55','45','Z55_ADVOGA','C','1','','Advogado','Advogado','Advogado','Advogado','Advogado','Advogado','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','1=SIM;2=NAO','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','46','Z55_DREEMB','C','1','','Despesa Reem','Despesa Reem','Despesa Reem','Despesa Reembolsavel','Despesa Reembolsavel','Despesa Reembolsavel','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','S=SIM;N=NAO','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','47','Z55_TIMEUS','C','8','','Horas Estima','Horas Estima','Hours Estima','Horas Estimadas','Horas Estimadas','Hours Estimated','99999:99','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','48','Z55_IDIOMA','C','1','','Idioma','Idioma','Language','Idioma','Idioma','Language','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','P=Portugues;I=Ingles;E=Espanhol','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','49','Z55_STATUS','C','1','','Status','Status','Status','Status','Status','Status','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','50','Z55_MOTIVO','C','100','','Motivo','Motivo','Motivo','Motivo','Motivo','Motivo','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','51','Z55_MOTALT','C','100','','Motivo Alter','Motivo Alter','Motivo Alter','Motivo Altereracao','Motivo Altereracao','Motivo Altereracao','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','52','Z55_DTINC','D','8','','Data Inc','Data Inc','Data Inc','Data Inclusao','Data Inclusao','Data Inclusao','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','53','Z55_DTAPRO','D','8','','Data Apro','Data Apro','Data Apro','Data Aprovacao','Data Aprovacao','Data Aprovacao','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','54','Z55_DTRECU','D','8','','Data Recu','Data Recu','Data Recu','Data Recusa','Data Recusa','Data Recusa','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','55','Z55_APROVA','C','6','','Aprovador','Aprovador','Aprovador','Aprovador','Aprovador','Aprovador','','','€€€€€€€€€€€€€€ ','','Z41APR','','š€','','S','U','N','A','R','','IIF(!empty(M->Z55_APROVA),ExistCpo("Z41",M->Z55_APROVA, 1) .AND. U_GTCORP58("APROVADOR","MSG"),.T.)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','56','Z55_NOMEAP','C','100','','Nome Aprovad','Nome Aprovad','Nome Aprovad','Nome Aprovador','Nome Aprovador','Nome Aprovador','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','57','Z55_OBSGT','C','100','','Obs GT','Obs GT','Obs GT','Observacao GT','Observacao GT','Observacao GT','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','58','Z55_DTAPGT','D','8','','Data Apro GT','Data Apro GT','Data Apro GT','Data Aprovacao GT','Data Aprovacao GT','Data Aprovacao GT','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','59','Z55_DTREGT','D','8','','Data Recu GT','Data Recu GT','Data Recu GT','Data Recusa GT','Data Recusa GT','Data Recusa GT','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','60','Z55_FILORI','C','2','','Fil Origem','Fil Origem','Fil Origem','Filial Origem','Filial Origem','Filial Origem','','','€€€€€€€€€€€€€€€','cFilAnt','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','61','Z55_MOTREC','C','1','','Motivo Recus','Motivo Recus','Reason Refus','Motivo Recusa','Motivo Recusa','Reason Refusal','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','1=Preco;2=Concorrente;3=Conflito;4=Declinou do Projeto;5=Outros','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','62','Z55_OBSREC','C','100','','Obs Recusa','Obs Recusa','Obs Refusal','Obs Recusa','Obs Recusa','Obs Refusal','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','63','Z55_DTREMC','D','8','','Dt Envio Cli','Dt Envio Cli','Dt Envio Cli','Dt Envio p Cliente','Dt Envio p Cliente','Dt Envio p Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','64','Z55_DTREMG','D','8','','Dt Envio GT','Dt Envio GT','Dt Envio GT','Dt Envio p GT','Dt Envio p GT','Dt Envio p GT','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','65','Z55_HRREMC','C','8','','Hora Env Cli','Hora Env Cli','Hora Env Cli','Hora Envio p Cliente','Hora Envio p Cliente','Hora Envio p Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','66','Z55_HRREMG','C','8','','Hora Env GT','Hora Env GT','Hora Env GT','Hora Envio p GT','Hora Envio p GT','Hora Envio p GT','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','67','Z55_HRAPGT','C','8','','Hora Apro GT','Hora Apro GT','Hora Apro GT','Hora Aprovacao GT','Hora Aprovacao GT','Hora Aprovacao GT','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','68','Z55_HRREGT','C','8','','Hora Recu GT','Hora Recu GT','Hora Recu GT','Hora Recusa GT','Hora Recusa GT','Hora Recusa GT','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','69','Z55_HRAPCL','C','8','','Hora Apr CLI','Hora Apr CLI','Hora Apr CLI','Hora Aprovacao Cliente','Hora Aprovacao Cliente','Hora Aprovacao Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','70','Z55_HRRECL','C','8','','Hora Rec CLI','Hora Rec CLI','Hora Rec CLI','Hora Recusa Cliente','Hora Recusa Cliente','Hora Recusa Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','71','Z55_ANEXO','C','150','','Propos Anexa','Propos Anexa','Propos Anexa','Proposta Anexa','Proposta Anexa','Proposta Anexa','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','72','Z55_INFCLI','C','50','','Inf Env Cli','Inf Env Cli','Inf Env Cli','Informacoes envio cliente','Informacoes envio cliente','Informacoes envio cliente','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','73','Z55_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z55','74','Z55_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z55','75','Z55_USERRE','C','6','','Usuario resp','Usuario resp','User resp','Usuario responsavel','Usuario responsavel','User responsible','','','€€€€€€€€€€€€€€ ','__cUserID','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','76','Z55_USERNO','C','50','','Usuario nome','Usuario nome','User name','Usuario nome','Usuario nome','User name','','','€€€€€€€€€€€€€€ ','UsrFullName(__cUserID)','','','š€','','S','U','N','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','77','Z55_OBSERV','M','8','','Observacoes','Observacoes','Comments','Observacoes','Observacoes','Comments','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','N','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','78','Z55_COBTIP','C','1','','Tipo Cobranc','Tipo Cobranc','Type collect','Tipo Cobranca','Tipo Cobranca','Type collection','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','1=Local;2=Invoice','','','','IIF(!empty(M->Z55_GLOCOB),.F.,.T.)','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','79','Z55_COBHON','C','1','','Horonarios','Horonarios','Fees','Horonarios','Horonarios','Fees','','','€€€€€€€€€€€€€€€','','','','þA','','','U','N','A','R','','','1=Timesheet;2=Timesheet Limitado;3=Fixo','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','80','Z55_COBRES','C','50','','Responsavel','Responsavel','Responsible','Responsavel','Responsavel','Responsible','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','81','Z55_COBTEL','C','14','','Telefone','Telefone','Phone','Telefone','Telefone','Phone','(999)9999-9999','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','82','Z55_COBEND','C','100','','Endereco','Endereco','Address','Endereco','Endereco','Address','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','83','Z55_COBEMA','C','150','','E-mail','E-mail','E-mail','E-mail','E-mail','E-mail','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','84','Z55_COBBAI','C','80','','Bairro','Bairro','District','Bairro','Bairro','District','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','85','Z55_COBMUN','C','80','','Municipio','Municipio','City','Municipio','Municipio','City','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','86','Z55_COBCEP','C','9','','CEP','CEP','Zip Code','CEP','CEP','Zip Code','99999-999','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z55','87','Z55_POOLAC','C','1','','Aceitacao','Aceitacao','Acceptance','Aceitacao','Aceitacao','Acceptance','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','1=Sim;2=Nao','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','88','Z55_POOLIN','C','1','','Independenci','Independenci','Independenc','Independencia','Independencia','Independence','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','1=Sim;2=Nao','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z55','89','Z55_CC'    ,'C','14','','C.C.','C.C.','C.C.','Centro de Custo','Centro de Custo','Centro de Custo','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})

//item(serviço) da proposta
AADD(aSX3,{'Z54','01','Z54_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z54','02','Z54_CODIGO','C','15','','Codigo','Codigo','Code','Codigo Servico','Codigo Servico','Service Code','','','€€€€€€€€€€€€€€ ','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','03','Z54_NUMPRO','C','12','','Proposta','Proposta','Proposta','Proposta','Proposta','Proposta','','','€€€€€€€€€€€€€€€','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','04','Z54_REVISA','C','3','','Revisao','Revisar','Review','Revisao','Revisar','Review','','','€€€€€€€€€€€€€€€','IIF(INCLUI,"000","")','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','05','Z54_CODDIV','C','6','','Divisao','Divisao','Divisao','Codigo Divisao','Codigo Divisao','Division code','','','€€€€€€€€€€€€€€ ','','Z58Z55','','þA','','S','U','S','A','R','','ExistCpo("Z58",M->Z54_CODDIV,1) .AND. M->Z55_TPCTR==Z58->Z58_TIPO','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','06','Z54_DESCDI','C','100','','Desc divisao','Desc divisio','Desc divisio','Descricao da divisão','Descripcion da division','Division description','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','07','Z54_CODNAT','C','6','','Natureza','Natureza','Natureza','Codigo Natureza','Codigo Natureza','Division Natureza','','','€€€€€€€€€€€€€€ ','','Z57','','þA','','S','U','S','A','R','','ExistCpo("Z57",M->Z54_CODNAT,1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','08','Z54_DESCNA','C','100','','Desc Naturez','Desc Naturez','Desc Naturez','Descricao da Natureza','Descripcion da Natureza','Natureza description','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','09','Z54_HORAPR','N','9','1','Horas Previs','Horas Previs','Hours Previs','Horas Previstas','Horas Previstas','Hours Previstas','@E 9999999.9','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','10','Z54_CUSTOT','N','14','2','Valor Bruto','Valor Bruto','Valor Bruto','Valor Total Bruto','Valor Total Bruto','Valor Total Bruto','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','11','Z54_PRECOL','N','14','2','Preco Liq','Preco Liq','Preco Liq','Preço Liquido','Preço Liquido','Preço Liquido','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','12','Z54_PRELSU','N','14','2','Pr Liq+Sur','Pr Liq+Sur','Pr Liq+Sur','Preço Liq.+Sur','Preço Liq.+Sur','Preço Liq.+Sur','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','13','Z54_TAXAME','N','8','2','Tx.Media Liq','Tx.Media Liq','Tx.Media Liq','Taxa Media Liquida','Taxa Media Liquida','Taxa Media Liquida','@E 9,999.99','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z54','14','Z54_TXMESU','N','8','2','Tx.Media+Sur','Tx.Media+Sur','Tx.Media+Sur','Tx.Media Liq.+Sur','Tx.Media Liq.+Sur','Tx.Media Liq.+Sur','@E 9,999.99','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z54','15','Z54_RECUPE','N','6','2','% Recuperaca','% Recuperaca','% Recuperaca','% Recuperacao','% Recuperacao','% Recuperacao','@E 999.99','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','V','R','','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z54','16','Z54_DTAINI','D','8','','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','17','Z54_DTAFIM','D','8','','Data Final','Data Final','Data Final','Data Final','Data Final','Data Final','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','18','Z54_RECORR','C','1','','Recorrente','Recurrente','Recurrent','Recorrente','Recurrente','Recurrent','','','€€€€€€€€€€€€€€ ','"N"','','','þA','','S','U','N','A','R','','','S=Sim;N=Nao','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z54','19','Z54_RECQTD','C','3','','Qtd (Anos)','Qtd (Anos)','Qtd (Anos)','Recorrencia','Reaparicion','Recurrence','999','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','IIF(aCols[oGetDados:Obrowse:nAt][15]<>"S",.F.,.T.)','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z54','20','Z54_ANOINI','C','4','','Inicio Exerc','Inicio Exerc','Work begin','Inicio Exercicio','Inicio Exercicio','Work begin','9999','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','IIF(aCols[oGetDados:Obrowse:nAt][15]<>"S",.F.,.T.)','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z54','21','Z54_FILORI','C','2','','Fil Origem','Fil Origem','Fil Origem','Filial Origem','Filial Origem','Filial Origem','','','€€€€€€€€€€€€€€€','cFilAnt','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z54','22','Z54_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z54','23','Z54_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})

                                                                                                                                                                                                                          //aCols[oGetDados:Obrowse:nAt][4]
//Projeto da proposta
AADD(aSX3,{'Z53','01','Z53_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z53','02','Z53_CODIGO','C','18','','Codigo','Codigo','Code','Codigo Projeto','Codigo Projeto','Project Code','','','€€€€€€€€€€€€€€ ','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','03','Z53_CODSER','C','15','','Servico','Servico','Service','Codigo Servico','Codigo Servico','Service Code','','','€€€€€€€€€€€€€€ ','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','04','Z53_NUMPRO','C','12','','Proposta','Proposta','Proposta','Proposta','Proposta','Proposta','','','€€€€€€€€€€€€€€ ','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','05','Z53_REVISA','C','3','','Revisao','Revisar','Review','Revisao','Revisar','Review','','','€€€€€€€€€€€€€€€','IIF(INCLUI,"000","")','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','06','Z53_DTAINI','D','8','','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','07','Z53_DTAFIM','D','8','','Data Final','Data Final','Data Final','Data Final','Data Final','Data Final','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','08','Z53_STATUS','C','1','','Status','Status','Status','Status','Status','Status','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z53','09','Z53_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z53','10','Z53_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})

//Despesa x Proposta
AADD(aSX3,{'Z52','01','Z52_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z52','02','Z52_NUMPRO','C','12','','Proposta','Proposta','Proposta','Proposta','Proposta','Proposta','','','€€€€€€€€€€€€€€€','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z52','03','Z52_REVISA','C','3','','Revisao','Revisar','Review','Revisao','Revisar','Review','','','€€€€€€€€€€€€€€€','IIF(INCLUI,"000","")','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z52','04','Z52_ITEM','C','2','','Item','Item','Item','Item','Item','Item','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z52','05','Z52_CODIGO','C','6','','Cod Despesa','Cod Despesa','Expense Code','Codigo Despesa','Codigo Despesa','Expense Code','','','€€€€€€€€€€€€€€ ','','Z56','','›€','','S','U','S','A','R','','ExistCpo("Z56", M->Z52_CODIGO,1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z52','06','Z52_DESCDE','C','100','','Desc Despesa','Desc Despesa','Desc Expense','Descricao da Despesa','Descripcion da Despesa','Expense description','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z52','07','Z52_DEREEM','C','1','','Reembolsavel','Reembolsavel','Refundable','Despesa Reembolsavel','Despesa Reembolsavel','Refundable Expense','','','€€€€€€€€€€€€€€ ','"1"','','','þA','','','U','N','A','R','','','1=Sim;2=Nao','','','','','','','2','','','','','N','N','',''})
//AADD(aSX3,{'Z52','08','Z52_TRANSP','C','1','','Transporte','Transporte','Transport','Transporte','Transporte','Transport','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','1=Sim;2=Nao','','','','','','','2','','','','','N','N','',''})
//AADD(aSX3,{'Z52','09','Z52_VLRFIX','C','1','','Valor Fixo','Valor Fixo','Fixed Value','Valor Fixo','Valor Fixo','Fixed Value','','','€€€€€€€€€€€€€€ ','"2"','','','þA','','','U','N','A','R','','','1=Sim;2=Nao','','','','IIF( aCols[oGetDadDes:Obrowse:nAt][5]<>"1",.F.,.T.)','','','2','','','','','N','N','',''})
AADD(aSX3,{'Z52','08','Z52_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z52','09','Z52_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})

//Sequência de propostas
AADD(aSX3,{'Z51','01','Z51_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z51','02','Z51_NUM','C','12','','Num Proposta','Num Proposta','Num Proposta','Numero Proposta','Numero Proposta','Numero Proposta','','','€€€€€€€€€€€€€€€','"."','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z51','03','Z51_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z51','04','Z51_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Altercao','Log de Altercao','Log de Altercao','','','€€€€€€€€€€€€€€€','','','9','øA','','','','N','V','','','','','','','','','','','','','','','','','','',''})

//Posicionamento da proposta
AADD(aSX3,{'Z50','01','Z50_FILIAL','C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z50','02','Z50_ID','C','6','','Codigo','Codigo','Code','Codigo','Codigo','Code','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','03','Z50_PROPOS','C','12','','Proposta','Propuesta','Proposal','Proposta','Propuesta','Proposal','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','04','Z50_REVISA','C','3','','Revisao','Revision','Revision','Revisao','Revision','Revision','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','05','Z50_DATA','D','8','','Data','Data','Date','Data','Data','Date','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','06','Z50_HORA','C','8','','Hora','Tiempo','Time','Hora','Tiempo','Time','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','07','Z50_PORCEN','C','3','','% Andamento','% Progresso','% Progress','% Andamento','% Progresso','% Progress','999','','€€€€€€€€€€€€€€€','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','08','Z50_MOTIVO','C','200','','Motivo','Razon','Reason','Motivo','Razon','Reason','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z50','09','Z50_USER','C','20','','Usuario','Usuario','User','Usuario','Usuario','User','@!','','€€€€€€€€€€€€€€ ','LOGUSERNAME ()','','','þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Pagamentos da proposta
AADD(aSX3,{'Z49','01','Z49_FILIAL','C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z49','02','Z49_PROPOS','C','12','','Proposta','Propuesta','Proposal','Proposta','Propuesta','Proposal','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','03','Z49_REVISA','C','3','','Revisao','Revision','Revision','Revisao','Revision','Revision','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','04','Z49_TIPO','C','12','','Tipo','Tipo','Type','Tipo','Tipo','Type','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','05','Z49_PARCEL','C','3','','Parcela','Parte','Portion','Parcela','Parte','Portion','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','06','Z49_VENCTO','D','8','','Vencimento','Vencimiento','Maturity Dt.','Vencimiento','Vencimiento','Bill Matutrity Date','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','07','Z49_VALOR','N','17','2','Valor','Valor','Value','Value','Value','Value','@E 99,999,999,999,999.99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','10','Z49_DTINC','D','8','','Dt Inclusao','Dt Inclusion','Dt Inclusion','Data Inclusao','Inclusion Fecha','Inclusion Date','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','12','Z49_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','13','Z49_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','08','Z49_INCDIP','C','1','','Inclui DIPJ','Incluye DIPJ','Inc. DIPJ','Inclui DIPJ','Incluye DIPJ','Includes DIPJ','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','S=Sim;N=Nao','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','09','Z49_INCANO','C','1','','Inclui Anual','Inc. Anual','Inc. Yearly','Inclui Anual','Inc. Anual','Inc. Yearly','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','S=Sim;N=Nao','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z49','11','Z49_DIAVEN','D','8','','Dt Inicial','Dt Inicial','Start Date','Data Inicial','Data Inicial','Start Date','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Anexos da proposta
AADD(aSX3,{'Z48','01','Z48_FILIAL','C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z48','02','Z48_PROPOS','C','12','','Proposta','Propuesta','Proposal','Proposta','Propuesta','Proposal','@!','','€€€€€€€€€€€€€€€','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','03','Z48_REVISA','C','3','','Revisao','Revision','Revision','Revisao','Revision','Revision','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','S','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','04','Z48_ITEM','C','2','','Item','Item','Item','Item','Item','Item','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','05','Z48_DATA','D','8','','Data','Data','Data','Data da Movimentacao','Data da Movimentacao','Data da Movimentacao','@D','','€€€€€€€€€€€€€€ ','DDATABASE','','','þÀ','','','U','S','A','R','€','','','','','','.F.','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','06','Z48_HORA','C','5','','Hora','Hora','Hora','Hora da Movimentacao','Hora da Movimentacao','Hora da Movimentacao','99:99','','€€€€€€€€€€€€€€ ','TIME()','','','þÀ','','','U','S','A','R','€','','','','','','.F.','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','07','Z48_TIPO','C','1','','Tipo','Tipo','Tipo','Tipo da Movimentacao','Tipo da Movimentacao','Tipo da Movimentacao','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','08','Z48_MOVIME','M','10','','Movimentacao','Movimentacao','Movimentacao','Movimentacao','Movimentacao','Movimentacao','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','09','Z48_CODUSR','C','6','','Cod. Usuario','Cod. Usuario','Cod. Usuario','Codigo Usuario','Codigo Usuario','Codigo Usuario','','','€€€€€€€€€€€€€€€','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','10','Z48_NOMEUS','C','25','','Nome','Nome','Name','Nome Usuario','Nome Usuario','Name Usuario','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','11','Z48_ARQUIV','C','120','','Arq. Anexo','Arq. Anexo','Arq. Anexo','Arquivo Anexo','Arquivo Anexo','Arquivo Anexo','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','12','Z48_DESCRI','C','150','','Descricao','Descricao','Descricao','Descricao da Movimentacao','Descricao da Movimentacao','Descricao da Movimentacao','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','13','Z48_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z48','14','Z48_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Capa do controle de ações
AADD(aSX3,{'Z47','01','Z47_FILIAL'	,'C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z47','02','Z47_CODIGO'	,'C','1','','Codigo','Codigo','Code','Codigo Acao','Codigo Acao','Service Acao','','','€€€€€€€€€€€€€€ ','GetSx8Num("Z47","Z47_CODIGO")','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
//AADD(aSX3,{'Z47','03','Z47_LEGEND'	,'C','100','','Legenda','Legenda','Legenda','Legenda','Legenda','Legenda','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
//AADD(aSX3,{'Z47','03','Z47_PASSO'	,'C','100','','Acao','Acao','Acao','Acao','Acao','Acao','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z47','03','Z47_ACAO'	,'C','100','','Acao','Acao','Acao','Acao','Acao','Acao','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z47','04','Z47_NOPC'	,'C','1','','Tipo','Tipo','Type','Tipo','Tipo','Type','@!','','€€€€€€€€€€€€€€ ','','','','›€','','','U','S','A','R','','U_VLD_NO47()','2=Visualizar;3=Incluir;4=Alterar;5=Excluir;6=Revisar;7=Aprovar/Recusar;8=Enviar Aprovacao;9=Pool;B=Encerrar;E=Finalizar','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z47','05','Z47_USERGI'	,'C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z47','06','Z47_USERGA'	,'C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
                                     
//Itens do controle de ações (Ações x Legendas)
AADD(aSX3,{'Z46','01','Z46_FILIAL'	,'C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z46','02','Z46_CODACA'	,'C','1','','Cod Acao','Cod Acao','Action Code','Codigo Acao','Codigo Acao','Action Code','','','€€€€€€€€€€€€€€€','','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z46','03','Z46_ITEM'	,'C','2','','Sequencia','Sequencia','Sequencia','Sequencia','Sequencia','Sequence','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z46','04','Z46_CODLEG'	,'C','1','','Cod Legenda','Cod Legenda','Cod Legend','Cod Legenda','Cod Legenda','Cod Legend','','','€€€€€€€€€€€€€€ ','','Z45','','›€','','S','U','S','A','R','','ExistCpo("Z45", M->Z46_CODLEG,1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z46','05','Z46_DESCRI'	,'C','100','','Descricao','Descricao','Descricao','Descricao','Descripcion','Description','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z46','06','Z46_USERGI'	,'C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z46','07','Z46_USERGA'	,'C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Capa do controle de Legendas
AADD(aSX3,{'Z45','01','Z45_FILIAL'	,'C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z45','02','Z45_CODIGO'	,'C','1','','Codigo','Codigo','Code','Codigo Acao','Codigo Acao','Service Acao','','','€€€€€€€€€€€€€€ ','GetSx8Num("Z45","Z45_CODIGO")','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z45','03','Z45_LEGEND'	,'C','100','','Legenda','Legenda','Legenda','Legenda','Legenda','Legenda','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z45','04','Z45_USERGI'	,'C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z45','05','Z45_USERGA'	,'C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Itens do controle de Legendas (Legendas x ações)
AADD(aSX3,{'Z44','01','Z44_FILIAL'	,'C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z44','02','Z44_CODLEG'	,'C','1','','Cod Legenda','Cod Legenda','Cod Legend','Cod Legenda','Cod Legenda','Cod Legend','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z44','03','Z44_ITEM'	,'C','2','','Sequencia','Sequencia','Sequencia','Sequencia','Sequencia','Sequence','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z44','04','Z44_CODACA'	,'C','1','','Cod Acao','Cod Acao','Action Code','Codigo Acao','Codigo Acao','Action Code','','','€€€€€€€€€€€€€€€','','Z47','','›€','','S','U','S','V','R','','ExistCpo("Z47", M->Z44_CODACA,1)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z44','05','Z44_DESCRI'	,'C','100','','Descricao','Descricao','Descricao','Descricao','Descripcion','Description','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z44','06','Z44_USERGI'	,'C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z44','07','Z44_USERGA'	,'C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Log de movimentação da proposta
AADD(aSX3,{'Z43','01','Z43_FILIAL'	,'C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z43','02','Z43_PROPOS'	,'C','12','','Proposta','Propuesta','Proposal','Proposta','Propuesta','Proposal','@!','','€€€€€€€€€€€€€€€','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','03','Z43_REVISA'	,'C','3','','Revisao','Revision','Revision','Revisao','Revision','Revision','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','S','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','04','Z43_SEQ'		,'C','3','','Sequencia','Sequencia','Sequencia','Sequencia','Sequencia','Sequencia','999','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','05','Z43_CODLEG'	,'C','1','','Cod Legenda','Cod Legenda','Cod Legend','Cod Legenda','Cod Legenda','Cod Legend','','','€€€€€€€€€€€€€€ ','','Z45','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z43','06','Z43_LEGEND'	,'C','100','','Legenda','Legenda','Legenda','Legenda','Legenda','Legenda','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z43','07','Z43_DATA'	,'D','8','','Data','Data','Data','Data da Movimentacao','Data da Movimentacao','Data da Movimentacao','@D','','€€€€€€€€€€€€€€ ','DDATABASE','','','þÀ','','','U','S','A','R','€','','','','','','.F.','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','08','Z43_HORA'	,'C','5','','Hora','Hora','Hora','Hora da Movimentacao','Hora da Movimentacao','Hora da Movimentacao','99:99','','€€€€€€€€€€€€€€ ','TIME()','','','þÀ','','','U','S','A','R','€','','','','','','.F.','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','09','Z43_CODUSR'	,'C','6','','Cod. Usuario','Cod. Usuario','Cod. Usuario','Codigo Usuario','Codigo Usuario','Codigo Usuario','','','€€€€€€€€€€€€€€€','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','10','Z43_NOMEUS'	,'C','25','','Nome','Nome','Name','Nome Usuario','Nome Usuario','Name Usuario','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','11','Z43_USERGI'	,'C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z43','12','Z43_USERGA'	,'C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Capa do controle de alçada
AADD(aSX3,{'Z42','01','Z42_FILIAL','C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z42','02','Z42_IDUSER','C','9','','Id Usuario','Id Usuario','Id User','Id Usuario','Id Usuario','Id User','@!','','€€€€€€€€€€€€€€ ','','Z42USR','','þÀ','','S','U','S','A','R','€','ExistChav("Z42", M->Z42_IDUSER,1)','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','03','Z42_NOUSER','C','30','','Nome Usuario','Nombre Usuar','Name User','Nome Usuario','Nombre Usuario','Name User','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','04','Z42_CPF','C',cvaltochar(TamSX3("RA_CIC")[1]),'','Cpf','Cpf','Cpf','Cpf','Cpf','Cpf','@!','','€€€€€€€€€€€€€€ ','','ALLSRA','','þÀ','','S','U','N','A','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z42','05','Z42_NOMEFU','C','100','','Nome funcio','Nome funcio','Employee Nam','Nome funcionario','Nome funcionario','Employee Name','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','V','R','','','','','','','','','','1','','','','','N','N','',''})

AADD(aSX3,{'Z42','06','Z42_TIPOFU','C','1','','Tipo Funcio','Tipo Funcio','Tipo Funcio','Tipo funcionario','Tipo funcionario','Employee Type','','Vazio() .or. Pertence("123")','€€€€€€€€€€€€€€ ','','','','þA','','','U','S','A','R','€','','1=Socio;2=Gerente;3=Outros','1=Socio;2=Gerente;3=Outros','1=Socio;2=Gerente;3=Outros','','','','','1','','','','','N','N','',''})

AADD(aSX3,{'Z42','07','Z42_LADMIN','L','1','','Admin','Admin','Admin','Administrador','Administrador','Administrator','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','08','Z42_LAPROV','L','1','','Aprovador','Aprobar','Approving','Aprovador','Aprobar','Approving','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','',''})
//AADD(aSX3,{'Z42','06','Z42_LRESPO','L','1','','Responsavel','Responsable','Responsible','Responsavel','Responsable','Responsible','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','U_VLD_Z42("Z42_LRESPO")','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','09','Z42_LVISP','L','1','','Ver Todas Pr','Ver Todas Pr','See All Pr','Ver Todas Propostas','Ver Todas Propuestas','See all Proposals','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','10','Z42_LINCP','L','1','','Incluir prop','Incluya prop','Include prop','Incluir proprosta','Incluya propuesta','Include proposal','','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','11','Z42_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z42','12','Z42_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Itens do controle de alçada
AADD(aSX3,{'Z41','01','Z41_FILIAL','C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z41','02','Z41_ITEM'  ,'C','2','','Item','Item','Item','Item','Item','Item','','','€€€€€€€€€€€€€€ ','','','','þA','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z41','03','Z41_IDUSER','C','9','','Id Usuario','Id Usuario','Id User','Id Usuario','Id Usuario','Id User','@!','','€€€€€€€€€€€€€€ ','','Z42USR','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z41','04','Z41_NOUSER','C','30','','Nome Usuario','Nombre Usuar','Name User','Nome Usuario','Nombre Usuario','Name User','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z41','05','Z41_IDDEPE','C','9','','Id Dependent','Id Dependien','Id Dependent','Id Dependente','Id Dependiente','Id Dependent','@!','','€€€€€€€€€€€€€€ ','','Z42USR','','þÀ','','S','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z41','06','Z41_NODEPE','C','30','','Nome Depende','Nome Dependi','Name Depende','Nome Depende','Nome Dependiente','Name Dependent','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z41','07','Z41_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z41','08','Z41_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Empresas vinculadas ao prospect
AADD(aSX3,{'Z40','01','Z40_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z40','02','Z40_PROSPE','C',cValToChar(TamSX3("US_COD")[1]),'','Prospect','Prospect','Prospect','Prospect','Prospect','Prospect','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','ExistCpo("SUS", M->Z40_PROSPE+M->Z40_PLOJA,1)','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z40','03','Z40_PLOJA ','C',cValToChar(TamSX3("US_LOJA")[1]),'','Prosp Loja','Prosp Loja','Prosp Loja','Prospect Loja','Prospect Loja','Prospect Loja','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','ExistCpo("SUS", M->Z40_PROSPE+M->Z40_PLOJA,1)','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z40','04','Z40_ITEM'  ,'C','2','','Item','Item','Item','Item','Item','Item','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z40','05','Z40_NOME'  ,'C',cValToChar(TamSX3("US_NOME")[1]),'','Nome Empresa','Nome Empresa','Business nam','Nome Empresa','Nome Empresa','Business name','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','06','Z40_END'   ,'C',cValToChar(TamSX3("US_END")[1]),'','Endereco','Endereco','Address','Endereco','Endereco','Address','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','07','Z40_MUN'   ,'C',cValToChar(TamSX3("US_MUN")[1]),'','Municipio','Municipio','City','Municipio','Municipio','City','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','08','Z40_EST'   ,'C',cValToChar(TamSX3("US_EST")[1]),'','Estado','Estado','State','Estado','Estado','State','','','€€€€€€€€€€€€€€ ','','12','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','09','Z40_DDD'   ,'C',cValToChar(TamSX3("US_DDD")[1]),'','DDD','DDD','DDD','DDD','DDD','DDD','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','10','Z40_TEL'   ,'C',cValToChar(TamSX3("US_TEL")[1]),'','Telefone','Telefone','Phone','Telefone','Telefone','Phone','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','11','Z40_CGC'   ,'C',cValToChar(TamSX3("US_CGC")[1]),'','CNPJ','CNPJ','CNPJ','CNPJ','CNPJ','CNPJ','@R 99.999.999/9999-99  ','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','U_ValidZ40(M->Z40_CGC)','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','12','Z40_ECLI'  ,'C','1','','Cliente','Cliente','Cliente','Cliente','Cliente','Cliente','','','€€€€€€€€€€€€€€€','"2"','','','š€','','S','U','S','V','R','','','1=Sim;2=Nao','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','13','Z40_CODCLI','C',cValToChar(TamSX3("US_COD")[1]),'','Cod Cliente','Cod Cliente','Cod Cliente','Cod Cliente','Cod Cliente','Cod Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','14','Z40_LOJCLI','C',cValToChar(TamSX3("US_LOJA")[1]),'','Loja Cliente','Loja Cliente','Loja Cliente','Loja Cliente','Loja Cliente','Loja Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','15','Z40_DTCONV','D','8','','Dt Conversao','Dt Conversao','Dt Conversao','Dt Conversao','Dt Conversao','Dt Conversao','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z40','16','Z40_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z40','17','Z40_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Km padrão da empresa
AADD(aSX3,{'Z39','01','Z39_FILIAL','C','2','','Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','','1','þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','',''})
AADD(aSX3,{'Z39','02','Z39_CODIGO','C','6','','Codigo','Codigo','Code','Codigo','Codigo','Code','','','€€€€€€€€€€€€€€ ','GetSx8Num("Z39","Z39_CODIGO")','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z39','03','Z39_KM','N','10','2','Km','Km','Km','Quilometro','Quilometro','Kilometer','@E 9999999.99','','€€€€€€€€€€€€€€€','','','','À€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z39','04','Z39_DTAINI','D','8','','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','Data Inicial','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z39','05','Z39_DTAFIM','D','8','','Data Final','Data Final','Data Final','Data Final','Data Final','Data Final','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','€','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z39','06','Z39_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z39','07','Z39_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Km e Unidades do cliente
AADD(aSX3,{'Z38','01','Z38_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z38','02','Z38_CLIENT','C',cValToChar(TamSX3("A1_COD")[1]),'','Cliente','Cliente','Customer','Cliente','Cliente','Costumer','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','ExistCpo("SA1", M->Z38_CLIENT+M->Z38_CLOJA,1)','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z38','03','Z38_CLOJA ','C',cValToChar(TamSX3("A1_LOJA")[1]),'','Cliente Loja','Cliente Loja','Customer Loj','Cliente Loja','Cliente Loja','Costumer Loja','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','A','R','','ExistCpo("SA1", M->Z38_CLIENT+M->Z38_CLOJA,1)','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z38','04','Z38_ITEM'  ,'C','2','','Item','Item','Item','Item','Item','Item','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z38','05','Z38_UNIDAD'  ,'C','100','','Unidade','Unidade','Unity','Unidade','Unidade','Unity','','','€€€€€€€€€€€€€€ ','','','','›€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z38','06','Z38_KM'    ,'N','10','1','Km','Km','Km','Quilometro','Quilometro','Kilometer','@E 99999999.9','','€€€€€€€€€€€€€€ ','','','','À€','','S','U','S','A','R','','','','','','','','','','1','','','','','','','',''})
AADD(aSX3,{'Z38','07','Z38_USERGI','C','17','','Log de Inclu','Log de Inclu','Log de Inclu','Log de Inclusao','Log de Inclusao','Log de Inclusao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z38','08','Z38_USERGA','C','17','','Log de Alter','Log de Alter','Log de Alter','Log de Alteracao','Log de Alteracao','Log de Alteracao','','','€€€€€€€€€€€€€€€','','','9','þÀ','','','L','N','V','R','','','','','','','','','','','','','','','N','N','',''})

//Empresas de grupo na proposta
AADD(aSX3,{'Z35','01','Z35_FILIAL','C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z35','02','Z35_PROPOS','C','12','','Proposta','Propuesta','Proposal','Proposta','Propuesta','Proposal','@!','','€€€€€€€€€€€€€€€','','','','þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z35','03','Z35_REVISA','C','3','','Revisao','Revision','Revision','Revisao','Revision','Revision','@!','','€€€€€€€€€€€€€€ ','','','','þÀ','','S','U','S','V','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z35','04','Z35_ITEM'  ,'C','2','','Item','Item','Item','Item','Item','Item','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z35','05','Z35_NOME'  ,'C',cValToChar(TamSX3("US_NOME")[1]),'','Nome Empresa','Nome Empresa','Business nam','Nome Empresa','Nome Empresa','Business name','','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','€','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z35','06','Z35_CGC'   ,'C',cValToChar(TamSX3("US_CGC")[1]),'','CNPJ','CNPJ','CNPJ','CNPJ','CNPJ','CNPJ','@R 99.999.999/9999-99  ','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z35','07','Z35_PERCEN','N','6','2','%Faturamento','%Faturamento','%Faturamento','% de Faturamento','% de Faturamento','% de Faturamento','@E 999.99','','€€€€€€€€€€€€€€ ','','','','š€','','S','U','S','A','R','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z35','08','Z35_CODCLI','C',cValToChar(TamSX3("US_COD")[1]),'','Cod Cliente','Cod Cliente','Cod Cliente','Cod Cliente','Cod Cliente','Cod Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','','','','','','','','','','','','','','','','','',''})
AADD(aSX3,{'Z35','09','Z35_LOJCLI','C',cValToChar(TamSX3("US_LOJA")[1]),'','Loja Cliente','Loja Cliente','Loja Cliente','Loja Cliente','Loja Cliente','Loja Cliente','','','€€€€€€€€€€€€€€€','','','','š€','','S','U','S','V','R','','','','','','','','','','','','','','','','','',''})

//Campos do controle de ações
//AADD(aSX3,{'Z45','01','Z45_FILIAL'	,'C','2','','Filial','Filial','Filial do Si','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
//AADD(aSX3,{'Z45','02','Z45_CODACA'	,'C','15','','Cod Acao','Cod Acao','Action Code','Codigo Acao','Codigo Acao','Action Code','','','€€€€€€€€€€€€€€€','','','','›€','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})
//AADD(aSX3,{'Z45','03','Z45_ITEM'	,'C','2','','Item','Item','Item','Item','Item','Item','99','','€€€€€€€€€€€€€€ ','','','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
//AADD(aSX3,{'Z45','04','Z45_CAMPO'	,'C','10','','Campo','Campo','Campo','Campo','Campo','Campo','','','€€€€€€€€€€€€€€ ','','SX3Z47','','þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','',''})
//AADD(aSX3,{'Z45','05','Z45_DESCRI'	,'C','100','','Descricao','Descricao','Descricao','Descricao','Descripcion','Description','','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','S','V','R','','','','','','','','','','1','','','','','','','',''})

****************************************************************************************************************************************** 
//{SX7} - Gatilhos
//AADD(aSX7,{X7_CAMPO,X7_SEQUENC,X7_REGRA,X7_CDOMIN,X7_TIPO,X7_SEEK,X7_ALIAS,X7_ORDEM,X7_CHAVE,X7_CONDIC,X7_PROPRI})

AADD(aSX7,{'Z55_CLIENT','001','POSICIONE("SA1",1,xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA,"A1_NOME")','Z55_NOME','P','N','','','','','U',''})
AADD(aSX7,{'Z55_CLIENT','002','IIF(empty(M->Z55_CLIENT),"",M->Z55_LOJA)','Z55_LOJA','P','N','','','','','U',''})
AADD(aSX7,{'Z55_LOJA  ','001','POSICIONE("SA1",1,xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA,"A1_NOME")','Z55_NOME','P','N','','','','','U',''})
AADD(aSX7,{'Z55_LOJA  ','002','IIF(empty(M->Z55_LOJA),"",M->Z55_CLIENT)','Z55_CLIENT','P','N','','','','','U',''})
AADD(aSX7,{'Z55_PROSPE','001','POSICIONE("SUS",1,xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA,"US_NOME")','Z55_PNOME','P','N','','','','','U',''})
AADD(aSX7,{'Z55_PROSPE','002','IIF(empty(M->Z55_PROSPE),"",M->Z55_PLOJA)','Z55_PLOJA','P','N','','','','','U',''})
AADD(aSX7,{'Z55_PLOJA ','001','POSICIONE("SUS",1,xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA,"US_NOME")','Z55_PNOME','P','N','','','','','U',''})
AADD(aSX7,{'Z55_PLOJA ','002','IIF(empty(M->Z55_PLOJA),"",M->Z55_PROSPE)','Z55_PROSPE','P','N','','','','','U',''})

//AADD(aSX7,{'Z55_VALOR ','001','ROUND(((M->Z55_VALOR-M->Z55_DESCON)),2)','Z55_VLRTOT','P','N','','','','M->Z55_TPVLR=="1"','U',''})
//AADD(aSX7,{'Z55_DESCON','001','ROUND(((M->Z55_VALOR-M->Z55_DESCON)),2)','Z55_VLRTOT','P','N','','','','M->Z55_TPVLR=="1"','U',''})
//AADD(aSX7,{'Z55_VALOR ','002','ROUND(((M->Z55_VALOR-(M->Z55_VALOR *((M->Z55_DESPER)/100) ) )),2)','Z55_VLRTOT','P','N','','','','M->Z55_TPVLR=="1"','U',''})
//AADD(aSX7,{'Z55_DESPER','001','ROUND(((M->Z55_VALOR-(M->Z55_VALOR *((M->Z55_DESPER)/100) ) )),2)','Z55_VLRTOT','P','N','','','','M->Z55_TPVLR=="1"','U',''})
//AADD(aSX7,{'Z55_DESPER','003','ROUND((M->Z55_VALOR *((M->Z55_DESPER)/100) ),2)','Z55_DESCON','P','N','','','','M->Z55_TPVLR=="1"','U',''})
//AADD(aSX7,{'Z55_DESPER','004','ROUND((M->Z55_VLRTOT *((M->Z55_DESPER)/100) ),2)','Z55_DESCON','P','N','','','','M->Z55_TPVLR=="2"','U',''})
//AADD(aSX7,{'Z55_DESCON','003','ROUND(( (M->Z55_DESCON/M->Z55_VALOR)*100 ),2)','Z55_DESPER','P','N','','','','M->Z55_TPVLR=="1"','U',''})
//AADD(aSX7,{'Z55_DESCON','004','ROUND(( (M->Z55_DESCON/M->Z55_VLRTOT)*100 ),2)','Z55_DESPER','P','N','','','','M->Z55_TPVLR=="2"','U',''})
//AADD(aSX7,{'Z55_VLRTOT','001','ROUND(((M->Z55_VLRTOT-M->Z55_DESCON)*0.8575),2)','Z55_VALOR','P','N','','','','M->Z55_TPVLR=="2"','U',''})
//AADD(aSX7,{'Z55_DESCON','002','ROUND(((M->Z55_VLRTOT-M->Z55_DESCON)),2)','Z55_VALOR','P','N','','','','M->Z55_TPVLR=="2"','U',''})
//AADD(aSX7,{'Z55_VLRTOT','002','ROUND(((M->Z55_VLRTOT-(M->Z55_VLRTOT *((M->Z55_DESPER)/100) ))*0.8575),2)','Z55_VALOR','P','N','','','','M->Z55_TPVLR=="2"','U',''})
//AADD(aSX7,{'Z55_DESPER','002','ROUND(((M->Z55_VLRTOT-(M->Z55_VLRTOT *((M->Z55_DESPER)/100) ))),2)','Z55_VALOR','P','N','','','','M->Z55_TPVLR=="2"','U',''})
AADD(aSX7,{'Z55_RESPON','001','UsrFullName(M->Z55_RESPON)','Z55_NOMERE','P','N','','','','','U',''})
AADD(aSX7,{'Z55_APROVA','001','UsrFullName(M->Z55_APROVA)','Z55_NOMEAP','P','N','','','','','U',''})
AADD(aSX7,{'Z55_TIMEUS','001','STRZERO(val(SUBSTR(M->Z55_TIMEUS,1,5)),5)+":"+STRZERO(val(SUBSTR(M->Z55_TIMEUS,7,2)),2)','Z55_TIMEUS','P','N','','','','','U',''})
AADD(aSX7,{'Z55_CUSTOM','001','POSICIONE("SA3",1,xFilial("SA3")+M->Z55_CUSTOM,"A3_NOME")','Z55_NOMECU','P','N','','','','','U',''})
AADD(aSX7,{'Z55_SOCIO ','001','U_GTSXB002(M->Z55_SOCIO)','Z55_NOMESO','P','N','','','','','U',''})
AADD(aSX7,{'Z55_GERENT','001','U_GTSXB002(M->Z55_GERENT)','Z55_NOMEGE','P','N','','','','','U',''})
AADD(aSX7,{'Z55_TPCTR ','001','U_GTSXB003()','Z55_TPCTR','P','N','','','','','U',''})

//AADD(aSX7,{'Z55_GLOBAL','001','IIF(M->Z55_GLOBAL=="1" .and. M->Z55_GLOCOB=="1","2","")','Z55_COBTIP','P','N','','','','','U',''})
AADD(aSX7,{'Z55_GLOBAL','002','""','Z55_GLOCOB','P','N','','','','M->Z55_GLOBAL == "2"','U',''})
AADD(aSX7,{'Z55_GLOBAL','003','""','Z55_CLIGLO','P','N','','','','M->Z55_GLOBAL == "2"','U',''})

AADD(aSX7,{'Z55_GLOCOB','004','"2"','Z55_TIPCLI','P','N','','','','M->Z55_GLOCOB == "2"','U',''})
AADD(aSX7,{'Z55_GLOCOB','005','""','Z55_PROSPE','P','N','','','','M->Z55_GLOCOB == "2"','U',''})
AADD(aSX7,{'Z55_GLOCOB','006','""','Z55_PLOJA','P','N','','','','M->Z55_GLOCOB == "2"','U',''})
AADD(aSX7,{'Z55_GLOCOB','007','""','Z55_PNOME','P','N','','','','M->Z55_GLOCOB == "2"','U',''})
AADD(aSX7,{'Z55_GLOCOB','008','M->Z55_GLOCOB','Z55_COBTIP','P','N','','','','','U',''})

//AADD(aSX7,{'Z55_VLRLIQ','001','ROUND(( M->Z55_VLRLIQ + (M->Z55_VLRLIQ*(M->Z55_SURCHA/100))),2)','Z55_VLRLIS','P','N','','','','','U',''})
//AADD(aSX7,{'Z55_VLRLIQ','002','U_GTSX7001()','Z55_VLRTOT','P','N','','','','','U',''})
AADD(aSX7,{'Z55_SURCHA','001','ROUND(( M->Z55_VLRLIQ + (M->Z55_VLRLIQ*(M->Z55_SURCHA/100))),2)','Z55_VLRLIS','P','N','','','','','U',''})
AADD(aSX7,{'Z55_SURCHA','002','U_GTSX7001()','Z55_VLRTOT','P','N','','','','','U',''})

AADD(aSX7,{'Z55_TIPCLI','001','""','Z55_PROSPE','P','N','','','','M->Z55_TIPCLI == "2"','U',''})
AADD(aSX7,{'Z55_TIPCLI','002','""','Z55_PLOJA','P','N','','','','M->Z55_TIPCLI == "2"','U',''})
AADD(aSX7,{'Z55_TIPCLI','003','""','Z55_PNOME','P','N','','','','M->Z55_TIPCLI == "2"','U',''})
AADD(aSX7,{'Z55_TIPCLI','004','""','Z55_CLIENT','P','N','','','','M->Z55_TIPCLI == "1"','U',''})
AADD(aSX7,{'Z55_TIPCLI','005','""','Z55_LOJA','P','N','','','','M->Z55_TIPCLI == "1"','U',''})
AADD(aSX7,{'Z55_TIPCLI','006','""','Z55_NOME','P','N','','','','M->Z55_TIPCLI == "1"','U',''})

AADD(aSX7,{'Z55_MOEDA','001','5','Z55_IMPOST','P','N','','','','M->Z55_MOEDA <> "01"','U',''})
AADD(aSX7,{'Z55_MOEDA','002','val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))','Z55_IMPOST','P','N','','','','M->Z55_MOEDA == "01"','U',''})
AADD(aSX7,{'Z55_MOEDA','003','M->Z55_VLRLIS + (M->Z55_VLRLIS * (M->Z55_IMPOST/100))','Z55_VLRTOT','P','N','','','','','U',''})

AADD(aSX7,{'Z54_CODDIV','001','POSICIONE("Z58",1,xFilial("SED")+M->Z54_CODDIV,"Z58_DESCRI")','Z54_DESCDI','P','N','','','','','U',''})
AADD(aSX7,{'Z54_CODDIV','002','SPACE(TamSX3("Z54_CODNAT")[1])','Z54_CODNAT','P','N','','','','','U',''})
AADD(aSX7,{'Z54_CODDIV','003','SPACE(TamSX3("Z54_DESCNA")[1])','Z54_DESCNA','P','N','','','','','U',''})
AADD(aSX7,{'Z54_CODNAT','001','POSICIONE("Z57",1,xFilial("Z57")+M->Z54_CODNAT,"Z57_DESCRI")','Z54_DESCNA','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_HORAPR','001','STRZERO(val(SUBSTR(M->Z54_HORAPR,1,5)),5)+":"+STRZERO(val(SUBSTR(M->Z54_HORAPR,7,2)),2)','Z54_HORAPR','P','N','','','','','U',''})

//AADD(aSX7,{'Z54_CUSTOT','001','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_HORAPR','001',' M->Z54_HORAPR * M->Z54_TAXAME ','Z54_CUSTOT','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_HORAPR','002','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aSX7,{'Z54_HORAPR','001','M->Z54_PRECOL/M->Z54_HORAPR','Z54_TAXAME','P','N','','','','','U',''})
AADD(aSX7,{'Z54_HORAPR','002','M->Z54_PRELSU/M->Z54_HORAPR','Z54_TXMESU','P','N','','','','','U',''})

//AADD(aSX7,{'Z54_TAXAME','001',' M->Z54_HORAPR * M->Z54_TAXAME ','Z54_CUSTOT','P','N','','','','','U',''})
//AADD(aSX7,{'Z54_TAXAME','002','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aSX7,{'Z54_PRECOL','001','M->Z54_PRECOL + (M->Z54_PRECOL * (M->Z55_SURCHA / 100))','Z54_PRELSU','P','N','','','','','U',''})
AADD(aSX7,{'Z54_PRECOL','002','(M->Z54_PRELSU * 100)/M->Z54_CUSTOT','Z54_RECUPE','P','N','','','','','U',''})
AADD(aSX7,{'Z54_PRECOL','003','M->Z54_PRECOL/M->Z54_HORAPR','Z54_TAXAME','P','N','','','','','U',''})
AADD(aSX7,{'Z54_PRECOL','004','M->Z54_PRELSU/M->Z54_HORAPR','Z54_TXMESU','P','N','','','','','U',''})
AADD(aSX7,{'Z54_PRECOL','005','U_Z54CUSTO()','Z55_VLRLIQ','P','N','','','','','U',''})

AADD(aSX7,{'Z54_CUSTOT','001','(M->Z54_PRELSU * 100)/M->Z54_CUSTOT','Z54_RECUPE','P','N','','','','','U',''})

AADD(aSX7,{'Z54_RECORR','001','Space(3)','Z54_RECQTD','P','N','','','','M->Z54_RECORR == "N"','U',''})
AADD(aSX7,{'Z54_RECORR','002','Space(4)','Z54_ANOINI','P','N','','','','M->Z54_RECORR == "N"','U',''})

AADD(aSX7,{'Z52_CODIGO','001','POSICIONE("Z56",1,xFilial("Z56")+M->Z52_CODIGO,"Z56_DESCRI")','Z52_DESCDE','P','N','','','','','U',''})

AADD(aSX7,{'Z41_IDDEPE','001','UsrFullName(M->Z41_IDDEPE)','Z41_NODEPE','P','N','','','','','U'})

AADD(aSX7,{'Z42_IDUSER','001','UsrFullName(M->Z42_IDUSER)','Z42_NOUSER','P','N','','','','','U'})
AADD(aSX7,{'Z42_CPF ','001','U_GTSXB002(M->Z42_CPF)','Z42_NOMEFU','P','N','','','','','U',''})

AADD(aSX7,{'Z46_CODLEG','001','POSICIONE("Z45",1,xFilial("Z45")+M->Z46_CODLEG,"Z45_LEGEND")','Z46_DESCRI','P','N','','','','','U',''})

AADD(aSX7,{'Z44_CODACA','001','POSICIONE("Z47",1,xFilial("Z47")+M->Z44_CODACA,"Z47_ACAO")','Z44_DESCRI','P','N','','','','','U',''})

//INCLUIDO PARA DELETAR
AADD(aDelSX7,{'Z54_CUSTOT','001','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aDelSX7,{'Z54_HORAPR','001',' M->Z54_HORAPR * M->Z54_TAXAME ','Z54_CUSTOT','P','N','','','','','U',''})
AADD(aDelSX7,{'Z54_HORAPR','002','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aDelSX7,{'Z54_TAXAME','001',' M->Z54_HORAPR * M->Z54_TAXAME ','Z54_CUSTOT','P','N','','','','','U',''})
AADD(aDelSX7,{'Z54_TAXAME','002','U_Z54CUSTO()','Z55_VLRCAL','P','N','','','','','U',''})

AADD(aDelSX7,{'Z55_VLRLIQ','001','ROUND(( M->Z55_VLRLIQ + (M->Z55_VLRLIQ*(M->Z55_SURCHA/100))),2)','Z55_VLRLIS','P','N','','','','','U',''})
AADD(aDelSX7,{'Z55_VLRLIQ','002','U_GTSX7001()','Z55_VLRTOT','P','N','','','','','U',''})

AADD(aDelSX7,{'Z55_GLOBAL','001','IIF(M->Z55_GLOBAL=="1" .and. M->Z55_GLOCOB=="1","2","")','Z55_COBTIP','P','N','','','','','U',''})

***************************************************************************************************************************************** 
//{SXB} - Consulta Padrão
//AADD(aSXB,{XB_ALIAS,XB_TIPO,XB_SEQ,XB_COLUNA,XB_DESCRI,XB_DESCSPA,XB_DESCENG,XB_CONTEM,XB_WCONTEM})

//Consulta para a referência da proposta
AADD(aSXB,{'Z92Z55','1','01','DB','Indicadores Proposta','Indicadores Proposta','Indicadores Proposta','Z92',''})
AADD(aSXB,{'Z92Z55','2','01','03','Nome','Nome','Nome','',''})
AADD(aSXB,{'Z92Z55','2','02','01','Codigo Empresa+ Nome','Codigo Empresa+ Nome','Codigo Empresa+ Nome','',''})
AADD(aSXB,{'Z92Z55','4','01','01','Nome','Nome','Nome','Z92_NOME',''})
AADD(aSXB,{'Z92Z55','4','01','02','Empresa','Empresa','Empresa','Z92_CODEMP',''})
AADD(aSXB,{'Z92Z55','4','01','03','Nome Empresa','Nome Empresa','Nome Empresa','Z92_NOMEMP',''})
AADD(aSXB,{'Z92Z55','4','01','04','CGC','CGC','CGC','Z92_CGCEMP',''})
AADD(aSXB,{'Z92Z55','4','02','01','Empresa','Empresa','Empresa','Z92_CODEMP',''})
AADD(aSXB,{'Z92Z55','4','02','02','Nome Empresa','Nome Empresa','Nome Empresa','Z92_NOMEMP',''})
AADD(aSXB,{'Z92Z55','4','02','03','CGC','CGC','CGC','Z92_CGCEMP',''})
AADD(aSXB,{'Z92Z55','4','02','04','Nome','Nome','Nome','Z92_NOME',''})
AADD(aSXB,{'Z92Z55','5','01','','','','','Z92->Z92_NOME',''}) 

AADD(aSXB,{'Z41RES','1','01','DB','Alcaca propostas Res','Alcaca propostas Res','Alcaca propostas Res','Z41',''})
AADD(aSXB,{'Z41RES','2','01','03','Id Usuario+nome Usua','Id Usuario+nome Usua','Id Usuario+nome Usua','',''})
AADD(aSXB,{'Z41RES','4','01','01','Id Usuario','Id Usuario','Id User','Z41_IDUSER',''})
AADD(aSXB,{'Z41RES','4','01','02','Nome Usuario','Nombre Usuar','Name User','Z41_NOUSER',''})
AADD(aSXB,{'Z41RES','5','01','','','','','Z41->Z41_IDUSER',''})
AADD(aSXB,{'Z41RES','5','02','','','','','Z41->Z41_NOUSER',''})
AADD(aSXB,{'Z41RES','6','01','','','','','U_GTCORP58("RESPONSAVEL")',''})

AADD(aSXB,{'Z41APR','1','01','DB','Alcada propostas Apr','Alcada propostas Apr','Alcada propostas Apr','Z41',''})
AADD(aSXB,{'Z41APR','2','01','03','Id Usuario+nome Usua','Id Usuario+nome Usua','Id Usuario+nome Usua','',''})
AADD(aSXB,{'Z41APR','4','01','01','Id Usuario','Id Usuario','Id User','Z41_IDUSER',''})
AADD(aSXB,{'Z41APR','4','01','02','Nome Usuario','Nombre Usuar','Name User','Z41_NOUSER',''})
AADD(aSXB,{'Z41APR','5','01','','','','','Z41->Z41_IDUSER',''})
AADD(aSXB,{'Z41APR','5','02','','','','','Z41->Z41_NOUSER',''})
AADD(aSXB,{'Z41APR','6','01','','','','','U_GTCORP58("APROVADOR")',''})

AADD(aSXB,{'Z42USR','1','01','US','Consulta Usuarios','Consulta Usuarios','Consulta Usuarios','',''})
AADD(aSXB,{'Z42USR','5','01','','','','','ID',''})
AADD(aSXB,{'Z42USR','5','02','','','','','FULLNAME',''})

AADD(aSXB,{'Z47   ','1','01','DB','Controle acoes proposta','Controle acoes proposta','Controle acoes proposta','Z47',''})
AADD(aSXB,{'Z47   ','2','01','01','Codigo+Acao','Codigo+Acao','Codigo+Acao','',''})
AADD(aSXB,{'Z47   ','4','01','01','Codigo','Codigo','Codigo','Z47_CODIGO',''})
AADD(aSXB,{'Z47   ','4','01','02','Descricao','Descricao','Description','Z47_ACAO',''})
AADD(aSXB,{'Z47   ','5','01','','','','','Z47->Z47_CODIGO',''})
AADD(aSXB,{'Z47   ','5','02','','','','','Z47->Z47_ACAO',''})

AADD(aSXB,{'Z45   ','1','01','DB','Controle legenda proposta','Controle legenda proposta','Controle legenda proposta','Z45',''})
AADD(aSXB,{'Z45   ','2','01','01','Codigo+Legenda','Codigo+Legenda','Codigo+Legenda','',''})
AADD(aSXB,{'Z45   ','4','01','01','Codigo','Codigo','Codigo','Z45_CODIGO',''})
AADD(aSXB,{'Z45   ','4','01','02','Descricao','Descricao','Description','Z45_LEGEND',''})
AADD(aSXB,{'Z45   ','5','01','','','','','Z45->Z45_CODIGO',''})
AADD(aSXB,{'Z45   ','5','02','','','','','Z45->Z45_LEGEND',''})

AADD(aSXB,{'Z42SOC','1','01','DB','Socio responsavel','Socio responsavel','Socio responsavel','Z42',''})
AADD(aSXB,{'Z42SOC','2','01','02','Cpf','Cpf','Cpf','',''})
AADD(aSXB,{'Z42SOC','2','02','03','Nome Funcio','Nome Funcio','Nome Funcio','',''})
AADD(aSXB,{'Z42SOC','4','01','01','Cpf','Cpf','Cpf','Z42_CPF',''})
AADD(aSXB,{'Z42SOC','4','01','02','Nome funcio','Nome funcio','Employee Nam','Z42_NOMEFU',''})
AADD(aSXB,{'Z42SOC','4','02','01','Nome funcio','Nome funcio','Employee Nam','Z42_NOMEFU',''})
AADD(aSXB,{'Z42SOC','4','02','02','Cpf','Cpf','Cpf','Z42_CPF',''})
AADD(aSXB,{'Z42SOC','5','01','','','','','Z42->Z42_CPF',''})


****************************************************************************************************************************************** 
//{SX6} - Parametros
//AADD(aSX6,{X6_FIL,X6_VAR,X6_TIPO,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1,X6_DESC2,X6_DSCSPA2,X6_DSCENG2,X6_CONTEUD,X6_CONTSPA,X6_CONTENG,X6_PROPRI,X6_PYME,X6_VALID,X6_INIT,X6_DEFPOR,X6_DEFSPA,X6_DEFENG})

AADD(aSX6,{'','MV_P_IMPOS','C','Imposto em porcentagem utilizado nas propostas,','','','utilizar a mascara 99,99 (2 casas decimais)','','','','','','14,25','14,25','14,25','U','','','','','',''})

****************************************************************************************************************************************** 
//<Chamada das funções para a deleção dos dicionários -- **NÃO MEXER** >
DeletSx7(aDelSX7,cTexto)
//<FIM - Chamada das funções para a deleção dos dicionários >

//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx3(aSX3,@cTexto)

CriaSx2(aSX2,@cTexto)

CriaSix(aSIX,@cTexto) 

CriaSx7(aSX7,@cTexto)

CriaSxb(aSXB,@cTexto)

CriaSx6(aSX6,@cTexto)
//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*

Local lIncSX3	:= .F.

For i:=1 to len(aSX3)
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(!DbSeek(aSX3[i][3]))
		lIncSX3:=.T.
	else
		lIncSX3:=.F.
	endif
	
	Reclock("SX3",lIncSX3)
	
		SX3->X3_ARQUIVO	:= aSX3[i][1]
		SX3->X3_ORDEM	:= aSX3[i][2]
		SX3->X3_CAMPO	:= aSX3[i][3]
		SX3->X3_TIPO    := aSX3[i][4]
		SX3->X3_TAMANHO := val(aSX3[i][5])
		SX3->X3_DECIMAL := val(aSX3[i][6])
	
		if FieldPos("X3_TITULO")>0
			SX3->X3_TITULO:= aSX3[i][7]
		endif
		if FieldPos("X3_TITSPA")>0
			SX3->X3_TITSPA:= aSX3[i][8]
		endif
		if FieldPos("X3_TITENG")>0
			SX3->X3_TITENG:= aSX3[i][9]
		endif
		if FieldPos("X3_DESCRIC")>0
			SX3->X3_DESCRIC:= aSX3[i][10]
		endif
		if FieldPos("X3_DESCSPA")>0
			SX3->X3_DESCSPA:= aSX3[i][11]
		endif
		if FieldPos("X3_DESCENG")>0
			SX3->X3_DESCENG:= aSX3[i][12]
		endif
	
		SX3->X3_PICTURE := aSX3[i][13]
		SX3->X3_VALID   := aSX3[i][14]
		SX3->X3_USADO   := aSX3[i][15]
		SX3->X3_RELACAO := aSX3[i][16]
		SX3->X3_F3      := aSX3[i][17]
		SX3->X3_NIVEL   := val(aSX3[i][18])
		SX3->X3_RESERV  := aSX3[i][19]
		SX3->X3_CHECK   := aSX3[i][20]
		SX3->X3_TRIGGER := aSX3[i][21]
		SX3->X3_PROPRI  := aSX3[i][22]
		SX3->X3_BROWSE  := aSX3[i][23]
		SX3->X3_VISUAL  := aSX3[i][24]
		SX3->X3_CONTEXT := aSX3[i][25]
		SX3->X3_OBRIGAT := aSX3[i][26]
		SX3->X3_VLDUSER := aSX3[i][27]
		SX3->X3_CBOX    := aSX3[i][28]
		SX3->X3_CBOXSPA := aSX3[i][29]
		SX3->X3_CBOXENG := aSX3[i][30]
		SX3->X3_PICTVAR := aSX3[i][31]
		SX3->X3_WHEN    := aSX3[i][32]
		SX3->X3_INIBRW  := aSX3[i][33]
		SX3->X3_GRPSXG  := aSX3[i][34]
		SX3->X3_FOLDER  := aSX3[i][35]
		SX3->X3_PYME    := aSX3[i][36]
		SX3->X3_CONDSQL := aSX3[i][37]
		SX3->X3_CHKSQL  := aSX3[i][38]
		SX3->X3_IDXSRV  := aSX3[i][39]
		SX3->X3_ORTOGRA := aSX3[i][40]
		SX3->X3_IDXFLD  := aSX3[i][41]
		SX3->X3_TELA    := aSX3[i][42]
		SX3->X3_AGRUP   := aSX3[i][43]
	
	SX3->(MsUnlock())

	if lIncSX3
		cTexto += "Incluido no SX3 - o campo:"+aSX3[i][3]+NL
	else
		cTexto += "Alterado no SX3 - o campo:"+aSX3[i][3]+NL
	endif
	
Next	

Return


*-----------------------------------*
Static Function CriaSx2(aSX2,cTexto)
*-----------------------------------*

Local lIncSX2	:= .F.

For i:=1 to len(aSX2)
	
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	if SX2->(!DbSeek(aSX2[i][1]))
		lIncSX2:=.T.
	else
		lIncSX2:=.F.
	endif  
	
	Reclock("SX2",lIncSX2)

		SX2->X2_CHAVE	:= aSX2[i][1]
		SX2->X2_PATH	:= aSX2[i][2]
		SX2->X2_ARQUIVO	:= aSX2[i][3]
		SX2->X2_NOME	:= aSX2[i][4]
		if FieldPos("X2_NOMESPA")>0
			SX2->X2_NOMESPA	:= aSX2[i][5]
		endif
		
		if FieldPos("X2_NOMEENG")>0
			SX2->X2_NOMEENG	:= aSX2[i][6]
		endif
		SX2->X2_ROTINA	:= aSX2[i][7]
		SX2->X2_MODO	:= aSX2[i][8]
		SX2->X2_MODOUN	:= aSX2[i][9]
		SX2->X2_MODOEMP	:= aSX2[i][10]
		SX2->X2_DELET	:= val(aSX2[i][11])
		SX2->X2_TTS		:= aSX2[i][12]
		SX2->X2_UNICO	:= aSX2[i][13]
		SX2->X2_PYME	:= aSX2[i][14]
		SX2->X2_MODULO	:= val(aSX2[i][15])
		SX2->X2_DISPLAY	:= aSX2[i][16]
		SX2->X2_SYSOBJ	:= aSX2[i][17]
		SX2->X2_USROBJ	:= aSX2[i][18]
	
	SX2->(MsUnlock())

	if lIncSX2
		cTexto += "Incluido no SX2 - a tabela:"+aSX2[i][1]+NL
	else
		cTexto += "Alterado no SX2 - a tabela:"+aSX2[i][1]+NL
	endif
	
Next	

Return

*-----------------------------------*
Static Function CriaSix(aSix,cTexto)
*-----------------------------------*

Local lIncSix	:= .F.

For i:=1 to len(aSix)

	DbSelectArea("SIX")
	SIX->(DbSetOrder(1))
	if SIX->(!DbSeek(PADR(aSix[i][1],3)+aSix[i][2]))
		lIncSIX:=.T.
	else
		lIncSIX:=.F.
	endif
	
	Reclock("SIX",lIncSIX)
		
		SIX->INDICE		:= aSix[i][1]
		SIX->ORDEM		:= aSix[i][2]
		SIX->CHAVE  	:= aSix[i][3]
		SIX->DESCRICAO  := aSix[i][4]
		SIX->DESCSPA	:= aSix[i][5]
		SIX->DESCENG	:= aSix[i][6]
		SIX->PROPRI		:= aSix[i][7]
		SIX->&('F3')	:= aSix[i][8]
		SIX->NICKNAME	:= aSix[i][9]
		SIX->SHOWPESQ	:= aSix[i][10]

	SIX->(MsUnlock())	
	
	if lIncSix
		cTexto += "Incluido no SIX - o indice:"+aSix[i][1]+aSix[i][2]+NL
	else
		cTexto += "Alterado no SIX - o indice:"+aSix[i][1]+aSix[i][2]+NL
	endif
	
Next

Return

*-----------------------------------*
Static Function CriaSx7(aSX7,cTexto)
*-----------------------------------*

Local lIncSX7	:= .F.

For i:=1 to len(aSX7)

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	if SX7->(!DbSeek(PADR(aSX7[i][1],10)+aSX7[i][2]))
		lIncSX7:=.T.
	else
		lIncSX7:=.F.
	endif
	
	Reclock("SX7",lIncSX7)
	
		SX7->X7_CAMPO	:= aSX7[i][1]
		SX7->X7_SEQUENC	:= aSX7[i][2]
		SX7->X7_REGRA	:= aSX7[i][3]
		SX7->X7_CDOMIN	:= aSX7[i][4]
		SX7->X7_TIPO	:= aSX7[i][5]
		SX7->X7_SEEK	:= aSX7[i][6]
		SX7->X7_ALIAS	:= aSX7[i][7]
		SX7->X7_ORDEM	:= val(aSX7[i][8])
		SX7->X7_CHAVE	:= aSX7[i][9]
		SX7->X7_CONDIC	:= aSX7[i][10]
		SX7->X7_PROPRI	:= aSX7[i][11]

	SX7->(MsUnlock())	
	
	if lIncSX7
		cTexto += "Incluido no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	else
		cTexto += "Alterado no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	endif
	
Next 

Return

*-----------------------------------*
Static Function CriaSxb(aSXB,cTexto)
*-----------------------------------*

Local lIncSXB	:= .F.

For i:=1 to len(aSXB)

	DbSelectArea("SXB")
	SXB->(DbSetOrder(1))
	if SXB->(!DbSeek(PADR(alltrim(aSXB[i][1]),6)+PADR(alltrim(aSXB[i][2]),1)+PADR(alltrim(aSXB[i][3]),2)+aSXB[i][4]))
		lIncSXB:=.T.
	else
		lIncSXB:=.F.
	endif
	
	Reclock("SXB",lIncSXB)
	
		SXB->XB_ALIAS	:= aSXB[i][1]
		SXB->XB_TIPO	:= aSXB[i][2]
		SXB->XB_SEQ		:= aSXB[i][3]
		SXB->XB_COLUNA	:= aSXB[i][4]
		SXB->XB_DESCRI	:= aSXB[i][5]
		SXB->XB_DESCSPA	:= aSXB[i][6]
		SXB->XB_DESCENG	:= aSXB[i][7]
		SXB->XB_CONTEM	:= aSXB[i][8]
		SXB->XB_WCONTEM	:= aSXB[i][9]

	SXB->(MsUnlock())	
	
	if lIncSXB
		cTexto += "Incluido no SXB - a consulta:"+aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]+NL
	else
		cTexto += "Alterado no SXB - a consulta:"+aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]+NL
	endif
	
Next

Return 

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

*-----------------------------------*
Static Function DeletSx7(aSX7,cTexto)
*-----------------------------------*
Local lIncSX7	:= .F.

For i:=1 to len(aSX7)

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	if SX7->(DbSeek(PADR(aSX7[i][1],10)+aSX7[i][2]))

		Reclock("SX7",.F.)
	    	SX7->(DbDelete())
		SX7->(MsUnlock())	
		
		cTexto += "Deletado no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	endif
	
Next 

Return