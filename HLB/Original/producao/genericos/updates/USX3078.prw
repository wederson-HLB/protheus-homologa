#INCLUDE "Protheus.ch"

/*
Funcao      : USX3078
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação do Update : Projeto REINF
Autor       : César Alves
Chamado		: 
Data/Hora   : 05/06/2015
*/
*---------------------*
User Function USX3078()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"SD1" , "SF4" , "SB1", "CCF" }
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
Local aChamados := {	{05, {|| AtuSX3()}} ,{05, {|| AtuSX6()}} }

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
Autor  		: César Alves
Data     	: 05/06/2018 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
 Static Function ATUSX3()
*-------------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}
Local cOrdem  := ''              
Local nLenCampo := Len( SX3->X3_CAMPO )

DbSelectArea("SX3")

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}
	
cOrdem := NextOrdem( 'SD1' )
aAdd(aSX3,{"SD1",cOrdem,"D1_CNO"		   		,"C",14,0,"Numero CNO"	,"Numero CNO"	,"Numero CNO"	,"Numero CNO"			,"Numero CNO"	,"Numero CNO","",'','€€€€€€€€€€€€€€',"" ,"",0,'þA',"","","S","N","A","R",'',"","","","","","","","","",""}) 

cOrdem := NextOrdem( 'SF4' )
aAdd(aSX3,{"SF4",cOrdem,"F4_CALCCPB"	   		,"C",1,0,"Calc.CPRB"	,"Calc.CPRB"	,"Calc.CPRB"	,"Calc.CPRB"			,"Calc.CPRB"	,"Calc.CPRB","@!",'Pertence(" 12")','€€€€€€€€€€€€€€',"" ,"",1,'þA',"","","S","N","A","R",'',"","1=Sim;2=Nao","1=Sim;2=Nao","1=Sim;2=Nao","","","","","2","S"}) 

cOrdem := NextOrdem( 'SB1' )
aAdd(aSX3,{"SB1",cOrdem,"B1_CEST"	   			,"C",9,0,"CEST"	,"CEST"	,"CEST"	,"Cod. Especificador ST" ,"Cod. Especificador ST","Cod. Especificador ST","@R 99.999.99","Vazio() .Or. ExistCpo('F0G')",'€€€€€€€€€€€€€€',"" ,"F0G",1,'þA',"","","S","S","A","R",'',"","","","","","","","","2","S"})

cOrdem := NextOrdem( 'CCF' )
aAdd(aSX3,{"CCF",cOrdem,"CCF_MOTSUS"	   		,"C",2,0,"M.Suspensao"	,"M.Suspensao"	,"M.Suspensao"	,"M.Suspensao"			,"M.Suspensao"	,"M.Suspensao","@!",'A967MOTSUS(0)','€€€€€€€€€€€€€€',"" ,"",1,'þA',"","","S","S","A","R",'',"","#A967MOTSUS(1)","#A967MOTSUS(1)","#A967MOTSUS(1)","","","","","","S"})


ProcRegua(Len(aSX3))

SX3->(DbSetOrder(2)) 
For i:= 1 To Len(aSX3)
	If !Empty(aSX3[i][1])
		If !(SX3->(DbSeek(aSX3[i][3])))
		//If !(SX3->(DbSeek(PadR(aSX3[i][3],nLenCampo))))
			RecLock("SX3",.T.)
			For j:=1 To Len(aSX3[i])
				If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
				EndIf
			Next j
			cTexto += "- Campo Criado. '"+aSX3[i,3]+"'"+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
		Else
	   		cTexto += "- Campo já existe. '"+aSX3[i,3]+"'"+ CHR(10) + CHR(13)
		EndIf		
	EndIf
Next i

Return cTexto

/*
Funcao      : ATUSX6
Autor  		: César Alves
Data     	: 05/06/2018 
Objetivos   : Atualização do Dicionario SX6.
*/
*-------------------------*
 Static Function ATUSX6()
*-------------------------*
Local cTexto  := ''
Local aEstrut := {}
Local aSX6    := {}

DbSelectArea("SX6")

aEstrut:= { "X6_FIL","X6_VAR"  ,"X6_TIPO"  ,"X6_DESCRIC"   ,"X6_DSCSPA","X6_DSCENG","X6_DESC1" ,"X6_DSCSPA1" ,"X6_DSCENG1" ,;
			"X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"  ,"X6_VALID"  ,"X6_INIT" }
	

aAdd(aSX6,{"","MV_CPRBNF","L" ,'Define se a CPRB devera ser calculada atraves do ','Define se a CPRB devera ser calculada atraves do ','Define se a CPRB devera ser calculada atraves do ',"Documento Fiscal. (.T. calcula .F. nao calcula)"	,;
"Documento Fiscal. (.T. calcula .F. nao calcula)","Documento Fiscal. (.T. calcula .F. nao calcula)"	,"","","","S","S","",""})  

aAdd(aSX6,{"","MV_CPRBATV","C" ,'Indica qual o codigo de Atividade da CPRB devera ','Indica qual o codigo de Atividade da CPRB devera ','Indica qual o codigo de Atividade da CPRB devera ',"ser utilizado no hipotese da desoneracao por CNAE."	,;
"ser utilizado no hipotese da desoneracao por CNAE.","ser utilizado no hipotese da desoneracao por CNAE.","","","","S","S","",""}) 


ProcRegua(Len(aSX6))
SX6->(DbSetOrder(1))
For i:= 1 To Len(aSX6)
	If !(SX6->(DbSeek(FWxFilial("SX6")+aSX6[i][2])))
	//If !(SX6->(DbSeek(PadR(aSX6[i][1],nLenFil)+PadR(aSX6[i][2],nLenVar))))
		RecLock("SX6",.T.)
		For j:=1 To Len(aSX6[i])
			If FieldPos(aEstrut[j])>0 .And. aSX6[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
			EndIf
		Next j
		cTexto += "- Parametro " + aSx6[i][2] +" criado ."+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
	Else
		cTexto += "- Parametro " + aSx6[i][2] +" já existe. "+ CHR(10) + CHR(13)
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
dbUseArea(.T.,,cNome,cAliasWork,.T.,.F.)
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
Autor......: Leandro Brito
Data.......: 30/03/2015
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