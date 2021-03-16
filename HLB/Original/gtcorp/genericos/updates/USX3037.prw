#INCLUDE "Protheus.ch"

/*
Funcao      : USX3037
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Inclus�o de Campos para DIPJ.
Autor       : Jean Victor Rocha
Revis�o		:
Data/Hora   : 20/03/2014
*/
*---------------------*
User Function USX3037()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicion�rio? Esta rotina deve ser utilizada em modo exclusivo."+;
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
Local aChamados := {	{04, {|| AtuSX7()}},;
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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi poss�vel a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

/*
Funcao      : ATUSX7
Autor  		: Jean Victor Rocha
Data     	: 
Objetivos   : Atualiza��o do Dicionario SX3.
*/
*-----------------------*
Static Function ATUSX7()
*-----------------------*
Local cTexto	:= ''
Local cOrdem	:= ""
Local aSXA		:= {}
Local aEstrut	:= {}
Local aOrdemDic	:= {}

aEstrut := {"XA_ALIAS"	,"XA_ORDEM"	,"XA_DESCRIC"		,"XA_DESCSPA"		,"XA_DESCENG"		,"XA_PROPRI"}

aAdd(aSXA,{"CN9"		,"9"		,"DIPJ / Anuidade"	,"DIPJ / Anuidade"	,"DIPJ / Anuidade"	,"U"}) 

//Busca a Ordem
SXA->(DbSetOrder(1))

For i:=1 to Len(aSXA)
	If (nPos := aScan(aOrdemDic, {|x| x[1] == aSXA[i][1] }) ) <> 0
		aSXA[i][2] := (aOrdemDic[nPos][2]:= Soma1(aOrdemDic[nPos][2]))
	Else
		cOrdem := "0"
		SXA->(DbSeek(aSXA[i][1]))
		While SXA->(!EOF()) .and. SXA->XA_ALIAS == aSXA[i][1]
			If aScan(aSXA, {|x| UPPER(ALLTRIM(x[3]))==UPPER(ALLTRIM(SXA->XA_DESCRIC)) }) <> 0
				SXA->(RecLock("SXA",.F.))
				SXA->(DbDelete())
				SXA->(MsUnLock())
			Else
				If cOrdem < SXA->XA_ORDEM
					cOrdem := SXA->XA_ORDEM
				EndIf
			EndIf
			SXA->(DbSkip())
		EndDo
		aAdd(aOrdemDic, {aSXA[i][1], Soma1(cOrdem)})
		aSXA[i][2] := Soma1(cOrdem)
	Endif
Next i

SXA->(DBPACK())

ProcRegua(Len(aSXA))
For i:= 1 To Len(aSXA)
	If !Empty(aSXA[i][1])
		RecLock("SXA",.T.)
		For j:=1 To Len(aSXA[i])
			If FieldPos(aEstrut[j])>0 .And. aSXA[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSXA[i,j])
			EndIf
		Next j
		cTexto += "- SXA Atualizado com sucesso. '"+aSXA[i,1]+"'"+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Dados...") //
	EndIf
Next i

Return cTexto

/*
Funcao      : ATUSX3
Autor  		: Jean Victor Rocha
Data     	: 
Objetivos   : Atualiza��o do Dicionario SX3.
*/
*-----------------------*
Static Function ATUSX3()
*-----------------------*
Local cTexto	:= ''
Local cAlias	:= '' 
Local cFolder	:= "3"
Local cOrdem	:= "00"
Local cReserv	:= ""
Local cUsado	:= ""
Local cObrg		:= ""
Local cComboCN9P:= "1=Inativo;2=Fixo;3=Negociado;4=Media Trimestral"
Local cComboCN9E:= "1=Off;2=Fixed;3=Negotiated;4=Quarterly average"
Local cComboCN9S:= "1=Off;2=Fijo;3=Negociado;4=Trimestral Medios"
Local cComboSCJP:= "1=Anuidade;2=DIPJ"
Local cComboSCJS:= "1=Anualidad;2=DIPJ"
Local cComboSCJE:= "1=Annuity;2=DIPJ"
Local aEstrut	:= {}
Local aSX3		:= {}
Local aOrdemDic := {}

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

DbSelectArea("SX3") //X3_RESERV e X3_USADO de um campo Usado
SX3->(DbSetOrder(2))     
If SX3->(DBSEEK("RA_NOME" ))
	cReserv := SX3->X3_RESERV
	cUsado  := SX3->X3_USADO
	cObrg	:= SX3->X3_OBRIGAT
EndIf

//Busca a Pasta na tabelas de contratos.
SXA->(DbSetOrder(1))
SXA->(DbSeek("CN9"))
While SX3->(!EOF()) .and. SXA->XA_ALIAS == "CN9"
	If LEFT(SXA->XA_DESCRIC,4) == "DIPJ"
		cFolder := SXA->XA_ORDEM
	EndIf
	SXA->(DbSkip())
EndDo

//Capa Manut. Int. Beneficios
aAdd(aSX3,{"CN9","99","CN9_P_ANUI" ,"C",01,0,"Anuidade"    ,"Anuidade"    ,"Anuidade"    ,"Anuidade"			,"Anuidade"     		,"Anuidade"     		,"@!" 						,''																	   					,cUsado,"'1'"   ,""      ,1,"��","","","U","S","A","R",cObrg,"",cComboCN9P,cComboCN9S,cComboCN9E,"",""					,"","",cFolder	,"N"})
aAdd(aSX3,{"CN9","99","CN9_P_CPAN" ,"C",03,0,"C.Pagto.Anui","C.Pagto.Anui","C.Pagto.Anui","Cond.Pagto Anuidade"	,"Cond.Pagto Anuidade"	,"Cond.Pagto Anuidade"	,"@!" 						,"IIF(M->CN9_P_ANUI<>'1',NaoVazio(),.T.)"							  					,cUsado,""      ,"SE4"   ,1,"��","","","U","S","A","R",cObrg,"",""	      ,""	     ,""        ,"","M->CN9_P_ANUI<>'1'","","",cFolder	,"N"})
aAdd(aSX3,{"CN9","99","CN9_P_VLAN" ,"N",16,2,"Vlr.Anuidade","Vlr.Anuidade","Vlr.Anuidade","Valor Anuidade"		,"Valor Anuidade"		,"Valor Anuidade"		,"@E 9,999,999,999,999.99" 	,"IIF(M->CN9_P_ANUI<>'1'.and.M->CN9_P_ANUI<>'4',M->CN9_P_VLAN>0.and.POsitivo(),.T.)"	,cUsado,""      ,""      ,1,"��","","","U","S","A","R",cObrg,"",""	      ,""	     ,""	    ,"","M->CN9_P_ANUI<>'1'","","",cFolder	,"N"})
aAdd(aSX3,{"CN9","99","CN9_P_DIPJ" ,"C",01,0,"DIPJ"        ,"DIPJ"        ,"DIPJ"        ,"DIPJ"       		  	,"DIPJ"         		,"DIPJ"         		,"@!" 						,''																	   					,cUsado,"'1'"   ,""      ,1,"��","","","U","S","A","R",cObrg,"",cComboCN9P,cComboCN9S,cComboCN9E,"",""					,"","",cFolder	,"N"})
aAdd(aSX3,{"CN9","99","CN9_P_CPDI" ,"C",03,0,"C.Pagto.DIPJ","C.Pagto.DIPJ","C.Pagto.DIPJ","Cond.Pagto DIPJ"		,"Cond.Pagto DIPJ"		,"Cond.Pagto DIPJ"		,"@!"					 	,"IIF(M->CN9_P_ANUI<>'1',NaoVazio(),.T.)"							   					,cUsado,""      ,"SE4"   ,1,"��","","","U","S","A","R",cObrg,"",""	      ,""	     ,""        ,"","M->CN9_P_DIPJ<>'1'","","",cFolder	,"N"})
aAdd(aSX3,{"CN9","99","CN9_P_VLDI" ,"N",16,2,"Vlr. DIPJ"   ,"Vlr. DIPJ"   ,"Vlr. DIPJ"   ,"Valor DIPJ"			,"Valor DIPJ"			,"Valor DIPJ"			,"@E 9,999,999,999,999.99" 	,"IIF(M->CN9_P_ANUI<>'1'.and.M->CN9_P_ANUI<>'4',M->CN9_P_VLDI>0.and.POsitivo(),.T.)"	,cUsado,""      ,""      ,1,"��","","","U","S","A","R",cObrg,"",""	      ,""	     ,""	    ,"","M->CN9_P_DIPJ<>'1'","","",cFolder	,"N"})

aAdd(aSX3,{"SCJ","99","CJ_P_CONTR" ,"C",15,0,"Contrato"    ,"Contrato"    ,"Contrato"    ,"Contrato"			,"Contrato"		   		,"Contrato"		  		,"@!"					 	,''																	   					,cUsado,""      ,""      ,1,"��","","","U","S","A","R",cObrg,"",""	      ,""	     ,""	    ,"",".F."				,"","",""		,"N"})
aAdd(aSX3,{"SCJ","99","CJ_P_TPORC" ,"C",01,0,"Tp. Orcam."  ,"Tp. Orcam."  ,"Tp. Orcam."  ,"Tp. Orcam."			,"Tp. Orcam."			,"Tp. Orcam."			,"@!"					 	,''																	   					,cUsado,""      ,""      ,1,"��","","","U","S","A","R",cObrg,"",cComboSCJP,cComboSCJS,cComboSCJE,"",".F."				,"","",""		,"N"})

//Busca a Ordem
SX3->(DbSetOrder(1))
For i:=1 to Len(aSX3)
	If (nPos := aScan(aOrdemDic, {|x| x[1] == aSX3[i][1] }) ) <> 0
		aSX3[i][2] := (aOrdemDic[nPos][2]:= Soma1(aOrdemDic[nPos][2]))
	Else
		cOrdem := "00"
		SX3->(DbSeek(aSX3[i][1]))
		While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == aSX3[i][1]
			If cOrdem < SX3->X3_ORDEM
				cOrdem := SX3->X3_ORDEM
			EndIf
			//Retira os campos que n�o pertecem a pasta.
			If SX3->X3_FOLDER == cFolder .and. aScan(aSX3, {|x| x[3]==SX3->X3_CAMPO}) == 0
				SX3->(RecLock("SX3",.F.))
				SX3->X3_FOLDER := ""
				SX3->(MsUnlock())
			EndIf
			SX3->(DbSkip())
		EndDo
		aAdd(aOrdemDic, {aSX3[i][1], Soma1(cOrdem)})
		aSX3[i][2] := Soma1(cOrdem)
	Endif
Next i

ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))
For i:= 1 To Len(aSX3)
	If !Empty(aSX3[i][1])
		lSX3	:= !DbSeek(aSX3[i,3])
		If !(aSX3[i,1]$cAlias)
			cAlias += aSX3[i,1]+"/"
			aAdd(aArqUpd,aSX3[i,1])
		EndIf
		RecLock("SX3",lSX3)
		For j:=1 To Len(aSX3[i])
			If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
			EndIf
		Next j
		cTexto += "- SX3 Atualizado com sucesso. '"+aSX3[i,3]+"'"+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Dados...") //
	EndIf
Next i


Return cTexto

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