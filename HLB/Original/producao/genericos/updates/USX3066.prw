#INCLUDE "Protheus.ch"

/*
Funcao      : USX3066
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação dos Campos de D1_P_NUMFL/E2_P_NUMFL
Autor       : Renato Rezende
Chamado		: 
Data/Hora   : 10/11/2016
*/
*---------------------*
User Function USX3066()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd    
//RSB - 16/02/2017 - Utilizados para rodas apenas uma vez a pergunta se é alteração ou inclusão.
Private nExclusivo
Private cRoda := "0"

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

//RSB - 16/02/2017 - Pergutan se rodará a alteração ou inclusão do campo. (Sim = Alteração / Não = Inclusão)
If cRoda = "0"
	nExclusivo := MsgYesNo("Esse procedimento será apenas de atualização ?","Atenção")
	cRoda := "1"
Endif

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", nExclusivo, .F. ) //Exclusivo
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
Local aSX3:= {}

//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_DESCRIC,X3_USADO,X3_NIVEL,X3_RESERV,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_PICTURE})

AADD(aSX3,{'SD1','','D1_P_NUMFL','N','8','0','Num.Fluig','Numero Fluig','€€€€€€€€€€€€€€','1','þA','U','N','A','R','@N 99999999'})        
AADD(aArqUpd,'SD1')

AADD(aSX3,{'SE2','','E2_P_NUMFL','N','8','0','Num.Fluig','Numero Fluig','€€€€€€€€€€€€€€','1','þA','U','N','A','R','@N 99999999'})     
AADD(aArqUpd,'SE2')

//Incluindo a última ordem no campo de log.
cAliasAux := ""
cOrder := ""
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
					//RSB - 16/02/2017 - A condição a beixao define, se o campo possuir "***" ou "ZZ", pega a ultima posição.
					// No "SD1" o campo ficará posicionado logo após o campo CFOP.
					If alltrim(SX3->X3_ORDEM) == "ZZ"
						Exit
					Else
						cMaxOrder := SX3->X3_ORDEM
						If SX3->X3_ARQUIVO == "SD1" .and. alltrim(SX3->X3_CAMPO) == "D1_CF" 
							cMaxOrder := SX3->X3_ORDEM
							exit
			   			Endif
					Endif
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

//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx3(aSX3,@cTexto)

Return(cTexto)

//RSB - 16/02/2017 - Altração na ordem do campo.
*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*
Local lIncSX3	:= .F.

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For i:=1 to len(aSX3)
	If SX3->(!DbSeek(aSX3[i][3]))
		//RSB - 16/02/2017 - MEnsagem se será alteração ou inclusão.
		If nExclusivo
			cTexto += "O campo "+aSX3[i][3]+" não está criado na empresa."+NL
			Loop
		Else	
			lIncSX3 := .T.
        Endif
    Endif	
	
	SX3->(Reclock("SX3",lIncSX3))
		If !lIncSX3
			//SX3->X3_ORDEM	:= aSX3[i][2]   
	    	//cTexto += "Atualizado no SX3 - o campo :"+aSX3[i][3]+NL
	    //Else
			SX3->X3_ARQUIVO	:= aSX3[i][1]
			SX3->X3_ORDEM	:= aSX3[i][2]
			SX3->X3_CAMPO	:= aSX3[i][3]
			SX3->X3_TIPO    := aSX3[i][4]
			SX3->X3_TAMANHO := val(aSX3[i][5])
			SX3->X3_DECIMAL := val(aSX3[i][6])
		
			if FieldPos("X3_TITULO")>0
				SX3->X3_TITULO:= aSX3[i][7]
			endif
			if FieldPos("X3_DESCRIC")>0
				SX3->X3_DESCRIC:= aSX3[i][8]
			endif
		
			SX3->X3_USADO   := aSX3[i][9]
			SX3->X3_NIVEL   := val(aSX3[i][10])
			SX3->X3_RESERV  := aSX3[i][11]
			SX3->X3_PROPRI  := aSX3[i][12]
			SX3->X3_BROWSE  := aSX3[i][13]
			SX3->X3_VISUAL  := aSX3[i][14]
			SX3->X3_CONTEXT := aSX3[i][15]
			SX3->X3_PICTURE := aSX3[i][16]
		
			cTexto += "Incluido no SX3 - o campo :"+aSX3[i][3]+NL
		
		Endif	
	SX3->(MsUnlock())

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