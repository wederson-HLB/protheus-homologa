#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE NAO_USADO ''
#DEFINE USADO_NOBRIGAT ''
#DEFINE USADO_OBRIG  ''		// Campo obrigatorio, que permite alterao

#DEFINE OBRIGAT ''

#DEFINE RSV_NUSADO ''
#DEFINE RSV_NOBRIGAT 'A'
#DEFINE RSV_OBRIG  ''		// Campo obrigatorio, que permite alterao


/*/{Protheus.doc} USX6032
@author Guilherme Fernandes Pilan - GFP
@since 27/07/2017 :: 09:00
@version P11
@type function
@description Cria??o de parametro para controle de destinatario de email para atualiza??o de taxas (WSBACEN)
/*/
*---------------------*
User Function USX6032()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd

Begin Sequence
   Set Dele On

   lHistorico	:= MsgYesNo("Deseja efetuar a atualizacao do Dicion?rio? Esta rotina deve ser utilizada em modo exclusivo."+;
                            "Fa?a um backup dos dicion?rios e da Base de Dados antes da atualiza??o.",;
                            "Aten??o")
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualiza??o do Dicion?rio"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Prepara??o dos Arquivos",;
                                         .F.) ,oMainWnd:End()),;
                                         oMainWnd:End())
End Sequence

Return

*---------------------------*
Static Function UPDProc(lEnd)
*---------------------------*
Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0
Local aChamados := { 	{04, {|| AtuSX6()}}}						

Private NL := CHR(13) + CHR(10)

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicion?rios...")

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
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automticas
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

*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
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
      Aviso( "Aten??o", "Nao foi poss?vel a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

//********************************//
//******* SX6 - PARAMETROS *******//
//********************************//
*----------------------*
Static Function ATUSX6()
*----------------------*
Local aSX6       := {}
Local aSX6Estrut := {}
Local lSX6	     := .F.
Local cTexto     := ""
Local cAlias     := "" 

	aSX6Estrut:= {"X6_FIL","X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                            ,"X6_DSCSPA"                                             ,"X6_DSCENG"                                             ,"X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD"                                                                ,"X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}
	Aadd(aSX6,	 {"  "    ,"MV_P_00104" ,"C"      ,"Destinatario email para atualiza??o de taxas (WSBACEN)","Destinatario email para atualiza??o de taxas (WSBACEN)","Destinatario email para atualiza??o de taxas (WSBACEN)",""        ,""          ,""          ,""        ,""          ,""          ,"rogerio.silva@hlb.com.br,samuel.campbel@hlb.com.br" ,""          ,""          ,"U"        ,"S"      })

//<Chamada das fun??es para a cria??o dos dicion?rios -- **N?O MEXER** >
CriaSx6(aSX6,@cTexto)
//<FIM - Chamada das fun??es para a cria??o dos dicion?rios >

	
Return cTexto               
             

*-----------------------------------*
Static Function CriaSx6(aSX6,cTexto)
*-----------------------------------*
Local lIncSX6 := .F.

For i:=1 to len(aSX6)

	DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	If SX6->(!DbSeek(aSX6[i][1]+aSX6[i][2]))
		lIncSX6 := .T.
	Else
   		lIncSX6 := .F.		
	Endif
		
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
		
		SX6->(MsUnlock())	
     
  	If lIncSX6 
		cTexto += "Incluido no SX6 - o par?metro:"+aSX6[i][1]+aSX6[i][2]+NL
	else
		cTexto += "Alterado no SX6 - o par?metro:"+aSX6[i][1]+aSX6[i][2]+NL
	endif	
		
Next

Return

//------------- INTERFACE ---------------------------------------------------
*--------------------*
Static Function Tela()
*--------------------*
Local lRet := .F.
Private cAliasWork := "Work"
private aCpos :=  {		{"MARCA"	,,""} ,;
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