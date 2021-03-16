#INCLUDE "Protheus.ch"
/*
Funcao      : USX3063
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Cria��o de campo no SRA de conta para RDV e ajuste de pastas.
Autor       : Jean Victor Rocha
Chamado		: 
Data/Hora   : 26/01/2016
*/
*---------------------*
User Function USX3063()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicion�rio?"+;
                            "Fa�a um backup dos dicion�rios e da Base de Dados antes da atualiza��o.",;
                            "Aten��o")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualiza��o do Dicion�rio"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Prepara��o dos Arquivos",;
                                         .F.) ,oMainWnd:End()/*, Final("Atualiza��o efetuada.")*/),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Fun��o de processamento da grava��o dos arquivos.
*/
*---------------------------*
Static Function UPDProc(lEnd)
*---------------------------*
Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0
Local aChamados := {	{04, {|| AtuSXA()}},;
						{04, {|| AtuSX3()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicion�rios...")

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
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas autom�ticas
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
      Aviso( "Atencao", "Nao foi poss�vel a abertura da tabela de empresas!.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

/*
Funcao      : ATUSX3
Autor  		:
Data     	:
Objetivos   : Atualiza��o do Dicionario SX3.
*/
*----------------------*
Static Function ATUSX3()
*----------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}
Local aAtuSX3 := {"RA_P_WIPFD","RA_P_WIPFU","RA_P_CTARD","RA_P_BCORD"}

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

//Capa Manut. Int. Beneficios
aAdd(aSX3,{"SRA","","RA_P_BCORD","C",008,0,"Bco.Ag.D.RDV"	,"Bco.Ag.D.RDV"	,"Bco.Ag.D.RDV"	,"Banco Ag. Dep. de RDV"	,"Banco Ag. Dep. de RDV","Banco Ag. Dep. de RDV","@R 999/99999" ,'Vazio() .Or. ExistCpo("SA6",Subs(M->RA_P_BCORD,1,3)+Subs(M->RA_P_BCORD,4,5))'	,'���������������',""	,"BA1" ,0,'ƀ' ,"","","U","S","A","R",'',"","","","","","","","","","N"})
aAdd(aSX3,{"SRA","","RA_P_CTARD","C",012,0,"Cta.Dep.RDV"	,"Cta.Dep.RDV"	,"Cta.Dep.RDV"	,"Conta Deposito de RDV"	,"Conta Deposito de RDV","Conta Deposito de RDV","@!"     ,''	,'���������������',""	,""      ,0,'ƀ' ,"","","U","S","A","R",'',"","","","","","","","","","N"})
                   
cAliasAux := ""
cMaxOrder := ""
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
For i:=1 to len(aSX3)
	If EMPTY(aSX3[i][2])
 		If EMPTY(cAliasAux) .or. cAliasAux <> aSX3[i][1]
			cMaxOrder := ""
			cAliasAux := aSX3[i][1]
		EndIf
		If EMPTY(cMaxOrder)
			If SX3->(DbSeek(aSX3[i,1]))
				While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == aSX3[i][1]
					cMaxOrder := SX3->X3_ORDEM
					SX3->(DbSkip())
				EndDo
			Else
				cMaxOrder := "00"
			EndIf
			aSX3[i][2] := Soma1(cMaxOrder)
			cMaxOrder := Soma1(cMaxOrder)
		Else
			aSX3[i][2] := Soma1(cMaxOrder)
			cMaxOrder := Soma1(cMaxOrder)
		EndIf
	EndIf		
Next i

ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))
For i:= 1 To Len(aSX3)
	If !Empty(aSX3[i][1])
		lSX3	:= SX3->(!DbSeek(aSX3[i,3]))
		If !(aSX3[i,1]$cAlias)
			cAlias += aSX3[i,1]+"/"
			aAdd(aArqUpd,aSX3[i,1])
		EndIf
		SX3->(RecLock("SX3",lSX3))
		For j:=1 To Len(aSX3[i])
			If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
			EndIf
		Next j
		cTexto += "- SX3 Atualizado com sucesso. '"+aSX3[i,3]+"'"+ CHR(10) + CHR(13)
		SX3->(DbCommit())
		SX3->(MsUnlock())
		IncProc("Atualizando Dicionario de Dados...") //
	EndIf
Next i                      

DbSelectArea("SXA")
SXA->(DbSetOrder(1))
If SXA->(DbSeek("SRA"))
	While SXA->(!EOF()) .and. SXA->XA_ALIAS == "SRA"
		If UPPER(Alltrim(SXA->XA_DESCRIC)) == "TIMESHEET"
			For i:= 1 To Len(aAtuSX3)
				If SX3->(DbSeek(aAtuSX3[i]))
					SX3->(RecLock("SX3",.F.))
					SX3->X3_FOLDER := SXA->XA_ORDEM
					SX3->(MsUnlock())
				EndIf
			Next i

			Exit
		EndIf
		SXA->(DbSkip())
	EndDo
EndIf
	
Return cTexto          

*----------------------*
Static Function ATUSXA()
*----------------------*
Local cTexto :=""
Local cMaxOrder := ""
Local nRecWIP	:= 0
Local lIncSXA	:= .T.

DbSelectArea("SXA")
SXA->(DbSetOrder(1))
If SXA->(DbSeek("SRA"))
	While SXA->(!EOF()) .and. SXA->XA_ALIAS == "SRA"
		If UPPER(Alltrim(SXA->XA_DESCRIC)) == "TIMESHEET"
			If nRecWIP <> 0
				SXA->(Reclock("SXA",.F.))
				SXA->(DbDelete())
				SXA->(MsUnLock())
			EndIf
			nRecWIP := SXA->(RECNO())
		Else
	   		cMaxOrder := SXA->XA_ORDEM		
		EndIf
		SXA->(DbSkip())
	EndDo
EndIf

cMaxOrder	:= Soma1(cMaxOrder)
lIncSXA		:= nRecWIP == 0
If nRecWIP <> 0
	SXA->(DbGoTo(nRecWIP))
EndIf

Reclock("SXA",lIncSXA)
SXA->XA_ALIAS	:= "SRA"
SXA->XA_ORDEM	:= cMaxOrder
SXA->XA_DESCRIC	:= "TimeSheet"
If FieldPos("XA_DESCSPA")>0
	SXA->XA_DESCSPA := "TimeSheet"
EndIf	
If FieldPos("XA_DESCENG")>0
	SXA->XA_DESCENG := "TimeSheet"
EndIf	
SXA->XA_PROPRI	:= "U"
SXA->(MsUnLock())

cTexto += "Atualizado a pasta no Cadastro de Funcionarios. (SXA table: SRA)"+NL

Return cTexto


*--------------------------------------*
Static Function GetPic(nTam, nDec, cPic)
*--------------------------------------*
Local cRet := ""
Local lDecOK := .F.
Local nCont := 0
For i:=1 to nTam
	If i == nDec+1
		cRet := "."+cRet
		lDecOK := .T.
	Else
		cRet := "9"+cRet
		If lDecOK 
			nCont++
			If nCont == 3 .and. at(",",cPic) <> 0
				cRet := ","+cRet
				nCont := 0
			EndIf
		EndIf
	EndIf         
Next i
cRet := LEFT(cPic, 3)+IF(LEFT(cRet,1)==",",RIGHT(cRet,LEN(cRet)-1),cRet)
Return cRet

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

oDlg1      := MSDialog():New( 091,232,401,612,"Equipe TI da GRANT THORNTON BRASIL",,,.F.,,,,,,.T.,,,.T. )
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

*---------------------*
Static Function cMark()
*---------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))

RecLock(cAliasWork, .F.)
if lDesmarca
   (cAliasWork)->MARCA := "  "
else
   (cAliasWork)->MARCA := cMarca
endif

(cAliasWork)->(MsUnlock())

return 

*---------------------*
Static Function Dados()
*---------------------*
dbSelectArea(cAliasWork)
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If (cAliasWork)->MARCA <> " "
		aAdd(aAux, (cAliasWork)->M0_CODIGO+(cAliasWork)->M0_CODFIL)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo
Return .t.
