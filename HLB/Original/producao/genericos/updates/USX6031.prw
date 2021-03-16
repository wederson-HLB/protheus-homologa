#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX6031
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Configuração dos parâmetros para o modulo de contratos da Vogel
Autor       : Matheus Massarotto
Data/Hora   : 04/03/2017    15:10
Revisão		:                    
Data/Hora   : 
Módulo      : GPE
*/

*---------------------*
User Function USX6031()
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


Local aChamados := { {04, {|| AtuSX6()}}}

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

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aChamados para cada 
	  		    módulo. */

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

//proposta
*------------------------------*
Static Function AtuSX6()
*------------------------------*
Local aSX6:= {}
Local cTexto:=""

****************************************************************************************************************************************** 
//{SX6} - Parametros
//AADD(aSX6,{X6_FIL,X6_VAR,X6_CONTEUD,X6_CONTSPA,X6_CONTENG})
AADD(aSX6,{xFilial("SX6"),"MV_CAUCPRF","CPX","CPX","CPX"})
AADD(aSX6,{xFilial("SX6"),"MV_CAUCNAT","","",""})
AADD(aSX6,{xFilial("SX6"),"MV_CNADIA","N","N","N"})
AADD(aSX6,{xFilial("SX6"),"MV_CNDOCBC","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNDPLIM","1","1","1"})
AADD(aSX6,{xFilial("SX6"),"MV_CNDTP3","F","F","F"})
AADD(aSX6,{xFilial("SX6"),"MV_CNEXCOP","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNEXPMS","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNFVIGE","N","N","N"})
AADD(aSX6,{xFilial("SX6"),"MV_CNMDALC","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNMOEDA","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNNATAD","","",""})
AADD(aSX6,{xFilial("SX6"),"MV_CNNATCL","","",""})
AADD(aSX6,{xFilial("SX6"),"MV_CNPREAD","ADT","ADT","ADT"})
AADD(aSX6,{xFilial("SX6"),"MV_CNPRECL","CTR","CTR","CTR"})
AADD(aSX6,{xFilial("SX6"),"MV_CNPRECO","T","T","T"})

AADD(aSX6,{xFilial("SX6"),"MV_CNPREF","GCT","GCT","GCT"})
AADD(aSX6,{xFilial("SX6"),"MV_CNPROCP","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNPROVI","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNRATE","1","1","1"})
AADD(aSX6,{xFilial("SX6"),"MV_CNREAJM","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNREALM","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNREDUP","T","T","T"})
AADD(aSX6,{xFilial("SX6"),"MV_CNRETNA","","",""})
AADD(aSX6,{xFilial("SX6"),"MV_CNRETNF","N","N","N"})
AADD(aSX6,{xFilial("SX6"),"MV_CNRETPR","CRE","CRE","CRE"})
AADD(aSX6,{xFilial("SX6"),"MV_CNRETTC","NDF","NDF","NDF"})
AADD(aSX6,{xFilial("SX6"),"MV_CNREVMD","T","T","T"})
AADD(aSX6,{xFilial("SX6"),"MV_CNSITAL","N","N","N"})
AADD(aSX6,{xFilial("SX6"),"MV_CNSUGME","1","1","1"})
AADD(aSX6,{xFilial("SX6"),"MV_CNTTEMP","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNTVFOR","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNVCAUC","S","S","S"})
AADD(aSX6,{xFilial("SX6"),"MV_CNVGFIN","N","N","N"})
AADD(aSX6,{xFilial("SX6"),"MV_CNVERNF","N","N","N"})
AADD(aSX6,{xFilial("SX6"),"MV_CNVLAMR","N","N","N"})

AADD(aSX6,{xFilial("SX6"),"MV_CNVGFIN",".F.",".F.",".F."})
AADD(aSX6,{xFilial("SX6"),"MV_MEDDIAS","15","15","15"})
AADD(aSX6,{xFilial("SX6"),"MV_MEDPEND","1","1","1"})


****************************************************************************************************************************************** 
//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx6(aSX6,@cTexto)
//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------------*
Static Function CriaSx6(aSX6,cTexto)
*-----------------------------------*

Local lIncSX6	:= .F.

For i:=1 to len(aSX6)

	DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	if SX6->(!DbSeek(PADR(alltrim(aSX6[i][1]),2)+PADR(alltrim(aSX6[i][2]),10)))
		cTexto += "O parametro "+aSX6[i][1]+aSX6[i][2]+" não existe para a empresa :"+SM0->M0_CODIGO+SM0->M0_NOME+NL
	else
		Reclock("SX6",.F.)
	
			SX6->X6_CONTEUD	:= aSX6[i][3]
			SX6->X6_CONTSPA	:= aSX6[i][4]
			SX6->X6_CONTENG	:= aSX6[i][5]
	
		SX6->(MsUnlock()) 
		
		cTexto += "Alterado no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL	
	endif

Next

Return

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