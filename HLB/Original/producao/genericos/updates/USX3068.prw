#INCLUDE "Protheus.ch"

/*
Funcao      : USX3068
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação do campo C5_P_CCUST. Alteração para usado do campo E2_BASEINS. Aumentar os campos para tamanho 400: CT5_DEBITO,CT5_CREDITO,CT5_CCD
              ,CT5_CCC,CT5_ITEMD,CT5_ITEMC,CT5_CLVLDB,CT5_CLVLCR,CT5_VLR01,CT5_VLR02,CT5_VLR03,CT5_VLR04,CT5_VLR05,CT5_HIST,CT5_HAGLUT,CT5_AT01DB,
              CT5_AT01CR,CT5_AT02DB,CT5_AT02CR,CT5_AT03DB,CT5_AT03CR,CT5_AT04DB,CT5_AT04CR
              Alteração do parâmetro: MV_1DUPNAT
Autor       : Renato Rezende
Chamado		: 
Data/Hora   : 02/12/2016
*/
*---------------------*
User Function USX3068()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"SC5","CT5"}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário?"+;
                            "Faça um backup dos dicionários e da Base de Dados antes da atualização.",;
                            "Atenção")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) ,oMainWnd:End()/*, Final("Atualização efetuada.")*/),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/
*---------------------------*
Static Function UPDProc(lEnd)
*---------------------------*
Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0
Local aChamados := {	{04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )
	lCheck := .F.    
	aAux := {}
	If !Tela()
		Return .T.
	EndIf

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
		If lCheck
			If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		Else
			If Ascan(aAux,{ |x| LEFT(x,2)  == M0_CODIGO}) <> 0 .and.;
				Ascan(aAux,{ |x| RIGHT(x,2) == M0_CODFIL}) <> 0 .and.;
				Ascan(aRecnoSM0,{ |x| x[2]  == M0_CODIGO}) == 0 
				
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		EndIf
		dbSkip()
	EndDo
    
	RpcClearEnv()

	  If lOpen := MyOpenSm0Ex()
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

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
*/
*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) //Exclusivo
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas!.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

/*
Funcao      : ATUSX3
Autor  		: Renato Rezende
Data     	: 10/12/2015
Objetivos   : Atualização do Dicionario SX3.
*/
*----------------------------*
Static Function AtuSX3()
*----------------------------*
Local cTexto:=""

    //Cria as tabelas
    AtuTab(@cTexto)    
    
Return(cTexto)

//Campos de log
*------------------------------*
Static Function AtuTab(cTexto)
*------------------------------*
Local lIncSX3	:= .F.
Local cOrdem  	:= ""

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_DEBITO"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_DEBITO no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_CREDITO"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_CREDITO no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_CCD"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_CCD no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_CCC"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_CCC no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_ITEMD"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_ITEMD no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_ITEMC"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_ITEMC no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_CLVLDB"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_CLVLDB no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_CLVLCR"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_CLVLCR no SX3 da tabela CT5 para tamanho 400"+NL
endif  

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_VLR01"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_VLR01 no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_VLR02"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_VLR02 no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_VLR03"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_VLR03 no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_VLR04"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_VLR04 no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_VLR05"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_VLR05 no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_HIST"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_HIST no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_HAGLUT"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_HAGLUT no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT01DB"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT01DB no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT01CR"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT01CR no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT02DB"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT02DB no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT02CR"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT02CR no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT03DB"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT03DB no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT03CR"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT03CR no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT04DB"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT04DB no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("CT5_AT04CR"))
	Reclock("SX3",.F.)
		SX3->X3_TAMANHO:=400
	SX3->(MsUnlock())
	cTexto += "Alterado o campo CT5_AT04CR no SX3 da tabela CT5 para tamanho 400"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("E2_BASEINS"))
	Reclock("SX3",.F.)
		SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->(MsUnlock())
	cTexto += "Alterado o campo E2_BASEINS no SX3 da tabela SE2 como usado"+NL
endif

SX3->(DbSetOrder(2))
SX3->(DbGotop())
if SX3->(DbSeek("E5_CCC"))
	Reclock("SX3",.F.)
		SX3->X3_USADO:="€€€€€€€€€€€€€€ "
	SX3->(MsUnlock())
	cTexto += "Alterado o campo E5_CCC no SX3 da tabela SE5 como usado"+NL
endif

cOrdem := NextOrdem('SC5')
SX3->(DbSetOrder(2))
SX3->(DbGotop())
if !SX3->(DbSeek("C5_P_CCUST"))
	Reclock("SX3",.T.)
	SX3->X3_ARQUIVO		:= "SC5"
	SX3->X3_ORDEM		:= cOrdem
	SX3->X3_CAMPO		:= "C5_P_CCUST"
	SX3->X3_TIPO		:= "C"
	SX3->X3_TAMANHO		:= 9
	SX3->X3_DECIMAL		:= 0
	SX3->X3_TITULO		:= "C Custo"
	SX3->X3_TITSPA		:= "C.Costo"
	SX3->X3_TITENG		:= "C.Center"
	SX3->X3_DESCRIC		:= "Centro de Custo"
	SX3->X3_DESCSPA		:= "Centro de Costo"
	SX3->X3_DESCENG		:= "Cost Center"
	SX3->X3_PICTURE		:= "@!"
	SX3->X3_USADO		:= "€€€€€€€€€€€€€€ "
	SX3->X3_F3			:= "CTT"
	SX3->X3_NIVEL		:= 1
	SX3->X3_RESERV		:= "€"
	SX3->X3_PROPRI		:= "U"
	SX3->X3_BROWSE		:= "S"
	SX3->X3_VISUAL		:= "A"
	SX3->X3_CONTEXT		:= "R"
	SX3->X3_OBRIGAT		:= ""
	SX3->X3_VLDUSER		:= "Vazio() .or. CTB105CC()"
	SX3->X3_PYME		:= "N"
	SX3->(MsUnlock())
	cTexto += "Campo criado: "+SX3->X3_CAMPO+NL
Else
	cTexto += "Campo já existe: "+SX3->X3_CAMPO+NL
endif

DbSelectArea("SX6")
SX6->(DbSetOrder(1))
IF SX6->(DbSeek(xFilial()+"MV_1DUPNAT"))
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := 'IF( FieldPos("C5_NATUREZ") > 0 .AND. ! EMPTY(SC5->C5_NATUREZ), SC5->C5_NATUREZ, SA1->A1_NATUREZ)'
	SX6->(MsUnlock()) 
	cTexto += "Parametro MV_1DUPNAT  foi atualizado." + NL
EndIf


Return(cTexto)

//------------- INTERFACE ---------------------------------------------------
*--------------------*
Static Function Tela()
*--------------------*
Local lRet := .F.
Private cAliasWork := "Work"
private aCpos :=  {	{"MARCA"	,,""} ,;
						{"M0_CODIGO",,"Cod.Empresa"	},;
						{"M0_CODFIL",,"Filial" 		},;
		   				{"M0_NOME"	,,"Nome Empresa"}}
		   				
private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"M0_CODIGO","C",2 ,0},;
						{"M0_CODFIL","C",2 ,0},;
		   				{"M0_NOME"	,"C",30,0}}

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf     

dbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSetOrder(1))
RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)


cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)
cAux:= ""
While SM0->(!EOF())
	If cAux <> SM0->M0_CODIGO
		(cAliasWork)->(RecLock(cAliasWork,.T.))           
		(cAliasWork)->MARCA		:= ""
		(cAliasWork)->M0_CODIGO	:= SM0->M0_CODIGO
		(cAliasWork)->M0_CODFIL	:= SM0->M0_CODFIL
		(cAliasWork)->M0_NOME	:= SM0->M0_NOME
		(cAliasWork)->(MsUnlock())
		cAux := SM0->M0_CODIGO
	EndIf
	SM0->(DbSkip())
EndDo

(cAliasWork)->(DbGoTop())

Private cMarca := GetMark()

SetPrvt("oDlg1","oSay1","oBrw1","oCBox1","oSBtn1","oSBtn2")

oDlg1      := MSDialog():New( 091,232,401,612,"Equipe TI da HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione as empresas a serem atualizadas."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{016,004,124,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.
oCBox1     := TCheckBox():New( 128,004,"Todas empresas.",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oSBtn1     := SButton():New( 132,116,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 132,152,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

// Seta Eventos do primeiro Check
oCBox1:bSetGet := {|| lCheck }
oCBox1:bLClicked := {|| lCheck:=!lCheck }
oCBox1:bWhen := {|| .T. }

oDlg1:Activate(,,,.T.)

Return lRet

*-----------------------*
Static Function cMark()
*-----------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))

RecLock(cAliasWork, .F.)
if lDesmarca
   (cAliasWork)->MARCA := "  "
else
   (cAliasWork)->MARCA := cMarca
endif

(cAliasWork)->(MsUnlock())

return 

*-----------------------*
Static Function Dados()
*-----------------------*
dbSelectArea(cAliasWork)
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If (cAliasWork)->MARCA <> " "
		aAdd(aAux, (cAliasWork)->M0_CODIGO+(cAliasWork)->M0_CODFIL)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo
Return .t.

/*
Função.....: NextOrdem
Objetivo...: Retorna proxima ordem do sx3
Autor......: Renato Rezende
Data.......: 02/12/2016
*/
*--------------------------------------*
Static Function NextOrdem( cAlias )
*--------------------------------------* 
Local cRet 

SX3->( DbSetOrder( 1 ) ) 

If SX3->( !DbSeek( cAlias ) )
   cRet := '01'   
   
ElseIf SX3->( DbSeek( cAlias + 'ZZ' , .T. ) )
   cRet := 'ZZ'

Else
   SX3->( DbSkip( -1 ) )
   cRet := Soma1( SX3->X3_ORDEM )

EndIf  

Return( cRet )