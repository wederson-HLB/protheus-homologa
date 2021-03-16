#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX3034
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criaçaõ de novos campos no cadastro de orçamentos e inclusão de Parametro para controle do portal.
Autor       : Jean Victor Rocha
Revisão		:
Data/Hora   : 03/12/2013
Módulo      : UPDATE
*/
*---------------------*
User Function USX3034()
*---------------------*
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
Local aChamados := { 	{04, {|| AtuSX3()}},;
						{04, {|| AtuSX6()}}}

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

/*
Funcao      : ATUSX3
Autor  		: Jean Victor Rocha
Data     	: 20/09/2012
Objetivos   : Atualização do Dicionario SX3.
*/
*-----------------------*
Static Function ATUSX3()
*-----------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}

Local cReserv := cUsado	:= cObrg:=	""

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

	//Capa Manut. Int. Beneficios
	aAdd(aSX3,{"SCJ","50","CJ_P_DTFAT" ,"D",08, 0,"Dt. Fatura","Dt. Fatura","Dt. Fatura","Data p/ afaturamento" ,"Data p/ afaturamento"      ,"Data p/ afaturamento"       ,""       ,'',cUsado,""      ,""      ,1,cReserv,"","","U","S","A","R",cObrg,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"SCJ","51","CJ_P_EMAIL" ,"C",30, 0,"Email Gest","Email Gest","Email Gest","Email Gestor"         ,"Email Gestor"   	         ,"Email Gestor"	           ,"@!"     ,'',cUsado,"" 		,""      ,1,cReserv,"","","U","S","A","R",cObrg,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"SCJ","52","CJ_P_EMAIU" ,"C",30, 0,"Email User","Email User","Email User","Email User"           ,"Email User"   	         ,"Email User"	               ,"@!"     ,'',cUsado,"" 		,""      ,1,cReserv,"","","U","S","A","R",cObrg,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"SCJ","53","CJ_P_OBSGT" ,"M",600,0,"Obs Portal","Obs Portal","Obs Portal","Obs Portal"           ,"Obs Portal"   	         ,"Obs Portal"	               ,""       ,'',cUsado,"" 		,""      ,1,cReserv,"","","U","S","A","R",cObrg,"",""       ,"","","","","","","","N"})

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

*----------------------*
Static Function AtuSX6()
*----------------------*
Local cTexto := "" 
Local i
Local aSX6	:= {}
Local aHSx6 := {}
Local cCont08 := "300027;300028;300032;300033;300034;300037;300041;300042;300043;300044;300046;300047;300099;400004;400007;400021;400027;400028;400029;400032;400035;400041;400045;400099"
Local cCont09 := "faturamento.gt@br.gt.com"
Local cCont10 := "faturamento.gt@br.gt.com"

aAdd(aHSx6,{"X6_VAR"	,"X6_TIPO"	,"X6_DESCRIC"									,"X6_DSCSPA"   									,"X6_DSCENG"									,"X6_DESC1"					,"X6_DSCSPA1"  					,"X6_DSCENG1"  					,"X6_DESC2"	,"X6_DSCSPA2"	,"X6_DSCENG2"	,"X6_CONTEUD"  	,"X6_CONTSPA"	 ,"X6_CONTENG"  				,"X6_PROPRI","X6_PYME"})
aAdd(aSX6, {"MV_P_00008", "C"		,"Codigos de Produtos habilitados no portal"	, "Codigos de Produtos habilitados no portal"	, "Codigos de Produtos habilitados no portal"	, "de faturamento GT."		, "de faturamento GT."			, "de faturamento GT."			, ""		, ""			, ""			, cCont08		, cCont08		 , cCont08						,"U"		,"N"		})
aAdd(aSX6, {"MV_P_00009", "C"		,"Grupo de emails para workflow de orçamentos."	, "Grupo de emails para workflow de orçamentos.", "Grupo de emails para workflow de orçamentos.", ""	 					, ""							, ""		  					, ""		, ""			, ""			, cCont09		, cCont09		 , cCont09						,"U"		,"N"		})
aAdd(aSX6, {"MV_P_00010", "C"		,"Grupo de emails para workflow de faturamento"	, "Grupo de emails para workflow de faturamento", "Grupo de emails para workflow de faturamento", ""						, ""		  					, ""		  					, ""		, ""			, ""			, cCont10		, cCont10		 , cCont10						,"U"		,"N"		})

SX6->(DbSetOrder(1))
For i:=1 to Len(aSX6)
	//Validando se o parâmetro existe
	If SX6->(DbSeek(xFilial("SX6") + aSX6[i][1]))
	   /*	If SX6->X6_CONTEUD <> aSX6[i][aScan(aHSx6[1], {|x| ALLTRIM(x) == "X6_CONTEUD"} )]
		   	SX6->(RecLock("SX6", .F.))
			SX6->X6_CONTEUD := aSX6[i][aScan(aHSx6[1], {|x| ALLTRIM(x) == "X6_CONTEUD"} )]
			SX6->X6_CONTSPA	:= aSX6[i][aScan(aHSx6[1], {|x| ALLTRIM(x) == "X6_CONTSPA"} )]
			SX6->X6_CONTENG	:= aSX6[i][aScan(aHSx6[1], {|x| ALLTRIM(x) == "X6_CONTENG"} )]
			SX6->(MSUNLOCK())
			cTexto += "Parametro ja existente na empresa: '" + aSX6[i][1] + "'. Porem foi atualizado o seu conteudo." +CHR(13)+CHR(10)
		Else*/
			cTexto += "Parametro ja existente na empresa: '" + aSX6[i][1] + "'. " +CHR(13)+CHR(10)
		//EndIf
	Else                
		SX6->(RecLock("SX6", .T.))
		For j:=1 to Len(aHSx6[1])
			SX6->(&(aHSx6[1][j])) := aSX6[i][j]
		Next j
		
		SX6->(MSUNLOCK())
		cTexto += "Foi criado o paramentro '" + aSX6[i][1] + "' com sucesso!. " +CHR(13)+CHR(10)
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