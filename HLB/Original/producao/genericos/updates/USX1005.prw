#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX1005                     
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Acerto do SX1 para impressão de livros de apuração de ICMS. MTR941.
Autor       : Anderson Arrais
Data/Hora   : 20/05/2015
*/
User Function USX1005()

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

Local aChamados := { {05, {|| AtuSX1()}}}

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
Obs.        :
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) 
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

*----------------------*
Static Function AtuSX1()
*----------------------*
Local nCont		:= 0
Local cTexto	:= "" 
Local aSx1		:= {}
Local cPerg 	:= "MTR941    "
Local aSX1Estrut:= { "X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA" ,"X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL",;
	               "X1_PRESEL" ,"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01"  ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02",;
	               "X1_DEF02"  ,"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03"  ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
	               "X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05"  ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5",;
	               "X1_CNT05"  ,"X1_F3"     ,"X1_PYME"   ,"X1_GRPSXG" ,"X1_HELP"   ,"X1_PICTURE","X1_IDFIL" }

SX1->(DbSetOrder(1))
If SX1->(DbSeek(cPerg+"25"))
	While SX1->(!EOF()) .and. ALLTRIM(SX1->X1_GRUPO) == Alltrim(cPerg)
		SX1->(RecLock("SX1",.F.))
		SX1->(DbDelete())
		SX1->(MsUnlock())
		SX1->(DbSkip())
		nCont++
	EndDo
	cTexto += "Foram deletados "+ALLTRIM(STR(nCont))+"registros para o grupo '"+cPerg+"."+CHR(13)+CHR(10)
EndIf

aAdd(aSX1, {cPerg   ,"25","Seleciona Filiais ?"   ,"¿Selecciona Sucursales ?"    ,"Select Branches ?"   ,"MV_CHP","C",1,0,0,"C","","mv_par25","Sim","Si","Yes","","","Nao","No","No" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"","" ,"" , "S"  ,"" ,"","",""})
aAdd(aSX1, {cPerg	,"26", "Serie no Termo ?"		, "Serie no Termo  ?"	, "Serie no Termo ?"		,"mv_chp","N",1,0,2,"C","","mv_par26","Sim","Si","Yes","","","Nao","No","No" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"","" ,"" , ""  ,"" ,"","",""})
aAdd(aSX1, {cPerg	,"27", "Serie/SubSerie ?"		, "Serie/SubSerie ?"	, "Serie/SubSerie ?"		,"mv_chx","C",5,0,0,"G","","mv_par27","","","","","","","","" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"","" ,"" , ""  ,"" ,"","",""})
aAdd(aSX1, {cPerg	,"28", "Aglutina por CNPJ+IE ?"		, "aglutinados  CNPJ+IE ?"	, "agglutinated CNPJ+IE ?"		,"mv_cho","N",1,0,2,"C","","mv_par28","Sim","Si","Yes","","","Nao","No","No" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"","" ,"" , ""  ,"" ,"","",""})
aAdd(aSX1, {cPerg	,"29", "Admin 1 ?"		, "Admin 1 ?"	, "Admin 1 ?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par45",""		,""	,""	,"JOSÉ TAVARES DE LUCENA       .","","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
aAdd(aSX1, {cPerg	,"30", "Admin 2 ?"		, "Admin 2 ?"	, "Admin 2 ?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par46",""		,""	,""	,"CPF: 918.938.528-49          .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
aAdd(aSX1, {cPerg	,"31", "Contador 1?"	, "Contador 1?"	, "Contador 1?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par47",""		,""	,""	,"JOBELINO VITORIANO LOCATELI  .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
aAdd(aSX1, {cPerg	,"32", "Contador 2?"	, "Contador 2?"	, "Contador 2?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par48",""		,""	,""	,"CPF: 035.964.518-68          .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
aAdd(aSX1, {cPerg	,"33", "Contador 3?"	, "Contador 3?"	, "Contador 3?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par49",""		,""	,""	,"CRC: 1SP073639/0-0           .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})

DbSelectArea("SX1")
SX1->(DbSetOrder(1))
For i:= 1 To Len(aSX1)
	RecLock("SX1",.T.)
	For j:=1 To Len(aSX1[i])
		If FieldPos(aSX1Estrut[j])>0 .And. aSX1[i,j] != NIL
			FieldPut(FieldPos(aSX1Estrut[j]),aSX1[i,j])
		EndIf
	Next j
	dbCommit()
	MsUnLock()
	cTexto += "Pergunte atualizado: "+aSX1[i][1]+aSX1[i][2]+CHR(13)+CHR(10)
Next i
	
Return cTexto