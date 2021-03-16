#INCLUDE "Protheus.ch"
/*
Funcao      : UFG1001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação de tabela ZX1 para armazenar log de integração de cupom fiscal SAT (integração GTFAT022).
Autor       : Anderson Arrais
Data/Hora   : 19/12/2018
*/
*---------------------*
User Function UFG1001()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"ZX1"}
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
Local aChamados := {	{04, {|| AtuMain()}}}

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Compartilhada
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

//----------------------------------Atualização-----------------------------------
/*
Funcao      : ATUMAIN
Autor  		: 
Data     	: 
Objetivos   : Chamada principal para as atualizações
*/
*-----------------------*
Static Function ATUMAIN()
*-----------------------*
Local cRet := ""

cRet += ATUSX2()
cRet += ATUSX3()
cRet += ATUSIX()

Return cRet

/*
Funcao      : ATUSX2
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario SX2.
*/
*----------------------*
Static Function ATUSX2()
*----------------------*
Local aSX2       := {}
Local aSX2Estrut := {}
Local lSX2	     := .F.
Local cTexto     := ""
Local cAlias     := "" 

	aSX2Estrut := 	{"X2_CHAVE","X2_PATH","X2_ARQUIVO","X2_NOME","X2_NOMESPA","X2_NOMEENG","X2_ROTINA","X2_MODO","X2_TTS","X2_UNICO","X2_PYME","X2_MODULO"}

	Aadd(aSX2,{"ZX1","\SYSTEM\","ZX1"+SM0->M0_CODIGO+"0","Integracao SAT"			,"Integracao SAT"			,"Integracao SAT"			,"","C","","","S",7})
	
	SX2->(DbSetOrder(1))	
	For i:= 1 To Len(aSX2)
		If !Empty(aSX2[i][1])
			lSX2	:= !SX2->(DbSeek(aSX2[i,1]))
			If !(aSX2[i,1]$cAlias)
				cAlias += aSX2[i,1]+"/"
				cTexto += "- SX2 Atualizado com sucesso. '"+ALLTRIM(aSX2[i,1])+"'"+ cAlias + CHR(10) + CHR(13)
			EndIf
			RecLock("SX2",lSX2)
			For j:=1 To Len(aSX2[i])
				If FieldPos(aSX2Estrut[j])>0 .And. aSX2[i,j] != Nil
					FieldPut(FieldPos(aSX2Estrut[j]),aSX2[i,j])
				EndIf
		    Next j
		    DbCommit()
		    MsUnlock()
		EndIf
	Next i
	
Return cTexto               


/*
Funcao      : ATUSX3
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario
*/
*----------------------*
Static Function ATUSX3()
*----------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}


DbSelectArea("SX3")

	aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
				"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
				"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
				"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

	aAdd(aSX3,{"ZX1","01","ZX1_FILIAL" 		,"C",002,0,"Filial"		,"Filial"	   	,"Filial"	  	,"Filial"					,"Filial"					,"Filial"	   				,""  ,'','€€€€€€€€€€€€€€€',"" ,"",0,'€€',"","","U","N","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","02","ZX1_CFEID"  		,"C",060,0,"CFE ID"		,"CFE ID"		,"CFE ID"		,"CFE ID"					,"CFE ID"					,"CFE ID"					,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'€' ,"","","U","S","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","03","ZX1_SERSAT" 		,"N",009,0,"Serie SAT"	,"Serie SAT"	,"Serie SAT"	,"Serie SAT"		 		,"Serie SAT"		  		,"Serie SAT"	  			,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'€' ,"","","U","S","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","04","ZX1_NCFE"  		,"N",006,0,"Num Cupom SAT","Num Cupom SAT","Num Cupom SAT","Num Cupom SAT"			,"Num Cupom SAT"			,"Num Cupom SAT"			,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'€' ,"","","U","S","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","05","ZX1_NUMSL1"		,"C",006,0,"Num SL1"	,"Num SL1"		,"Num SL1"		,"Num SL1"	   	   			,"Num SL1"					,"Num SL1"	   				,"@!",'','€€€€€€€€€€€€€€ ',"" ,"",0,'þA',"","","U","N","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","06","ZX1_DTEMI"   	,"D",008,0,"DT Emi SAT" ,"DT Emi SAT"	,"DT Emi SAT"	,"DT Emi SAT"			  	,"DT Emi SAT"				,"DT Emi SAT"			 	,"@!",'','€€€€€€€€€€€€€€ ',"" ,"",0,'þA',"","","U","N","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","07","ZX1_CGCEMI"		,"C",014,0,"CGC Emitente","CGC Emitente","CGC Emitente"	,"CGC Emitente"				,"CGC Emitente"				,"CGC Emitente"				,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'€' ,"","","U","S","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","08","ZX1_DATA"		,"D",008,0,"DT Integra"	,"DT Integra"	,"DT Integra"	,"DT Integra"				,"DT Integra"				,"DT Integra"				,"@!",'','€€€€€€€€€€€€€€ ',"" ,"",0,'†A',"","","U","N","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","09","ZX1_HORA"  		,"C",010,0,"Hora Integra","Hora Integra","Hora Integra"	,"Hora Integra"				,"Hora Integra"				,"Hora Integra"				,"@!",'','€€€€€€€€€€€€€€ ',"" ,"",0,'†A',"","","U","N","A","R",'',"","","","","","","","","","N"})
	aAdd(aSX3,{"ZX1","10","ZX1_ERRO"  		,"M",010,0,"ERRO" 		,"ERRO"			,"ERRO"			,"ERRO"	 					,"ERRO"	 					,"ERRO"						,"@!",'','€€€€€€€€€€€€€€ ',"" ,"",0,'†A',"","","U","N","A","R",'',"","","","","","","","","","N"})

	cAliasAux := ""
	cMaxOrder := ""
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
			lSX3	:= !SX3->(DbSeek(aSX3[i,3]))
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

/*
Funcao      : ATUSIX
Autor  		: Jean Victor Rocha
Data     	: 20/09/2012
Objetivos   : Atualização do Dicionario SIX.
*/
*----------------------*
Static Function ATUSIX()
*----------------------*
Local cTexto    := ''
Local aSIXEstrut:= {}
Local aSIX      := {}
Local i, j
Local cAlias    := ''

	// Atualização dos indices na tabela SIX
	aSIXEstrut:= {"INDICE","ORDEM","CHAVE"	   						,"DESCRICAO"	,"DESCSPA"		,"DESCENG"		,"PROPRI","F3","NICKNAME","SHOWPESQ"}
	aadd(aSIX,	 {"ZX1"   ,"1"    ,"ZX1_FILIAL+ZX1_CFEID+ZX1_DATA+ZX1_HORA"  	,"Filial + CFE ID. + Data + Hora"	,"Filial + CFE ID. + Data + Hora"	,"Filial + CFE ID. + Data + Hora"	,"U"     ,""  ,""		 ,"S"       })

	For i:= 1 To Len(aSIX)
		If SIX->(DbSeek(aSIX[i,1]))
			While SIX->(!EOF()) .and. SIX->INDICE == aSIX[i,1]
				RecLock("SIX",.F.)
				SIX->(DbDelete())
				SIX->(MsUnlock())
				SIX->(DbSkip())				
			EndDo
		EndIf
	Next i

	ProcRegua(Len(aSIX))
	dbSelectArea("SIX")
	SIX->(DbSetOrder(1))	
	For i:= 1 To Len(aSIX)
		RecLock("SIX",.T.)
		If UPPER(AllTrim(CHAVE)) != UPPER(Alltrim(aSIX[i,3]))
			aAdd(aArqUpd,aSIX[i,1])
			If !(aSIX[i,1]$cAlias)
				cAlias += aSIX[i,1]+"/"
			EndIf
			For j:=1 To Len(aSIX[i])
				If FieldPos(aSIXEstrut[j])>0
					FieldPut(FieldPos(aSIXEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			MsUnLock()
			cTexto  += "- SIX atualizado com sucesso. '"+aSix[i][1]+"-"+aSix[i][3]+"'"+CHR(13)+CHR(10)
		EndIf
		IncProc("Atualizando índices...")
	Next i

Return cTexto