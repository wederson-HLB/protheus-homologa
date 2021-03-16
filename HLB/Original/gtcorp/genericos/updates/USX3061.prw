#INCLUDE "Protheus.ch"

/*
Funcao      : USX3061
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Cria��o dos Campos de _USERLGA/_USERLGI
Autor       : Renato Rezende
Chamado		: 
Data/Hora   : 10/12/2015
*/
*---------------------*
User Function USX3061()
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
Local aChamados := {	{04, {|| AtuSX3()}}}

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
Autor  		: Renato Rezende
Data     	: 10/12/2015
Objetivos   : Atualiza��o do Dicionario SX3.
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

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
SX2->(DbGoTop())

//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_DESCRIC,X3_USADO,X3_NIVEL,X3_RESERV,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT})
SX2->(DbSeek("CV"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "CV" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),1,3)+'_USERGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','N','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),1,3)+'_USERGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','N','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo

SX2->(DbSeek("CT"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "CT" .And. !SX2->(EOF())
	If Alltrim(SX2->X2_CHAVE)  <> "CTP"
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),1,3)+'_USERGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','N','V','R'})
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),1,3)+'_USERGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','N','V','R'})
		AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3)) 
	EndIf
SX2->(dbSkip())
EndDo

SX2->(DbSeek("CN"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "CN" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),1,3)+'_USERGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','N','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),1,3)+'_USERGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','N','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo

SX2->(DbSeek("SN"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SN" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo 

SX2->(DbSeek("SM"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SM" .And. !SX2->(EOF())
	If Alltrim(SX2->X2_CHAVE)  <> "SM2" .AND. Alltrim(SX2->X2_CHAVE)  <> "SM4"
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
		AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
	EndIf
SX2->(dbSkip())
EndDo

SX2->(DbSeek("SF"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SF" .And. !SX2->(EOF())
	If Alltrim(SX2->X2_CHAVE)  <> "SF4"
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
		AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
	EndIf
SX2->(dbSkip())
EndDo  

SX2->(DbSeek("SD"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SD" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo 

SX2->(DbSeek("SR"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SR" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo

SX2->(DbSeek("SA1"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,3) >= "SA1" .AND. SubStr(Alltrim(SX2->X2_CHAVE),1,3) <= "SA9" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo

SX2->(DbSeek("SY"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SY" .And. !SX2->(EOF())
	If Alltrim(SX2->X2_CHAVE)  <> "SYD"
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
		AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
		AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
	EndIf
SX2->(dbSkip())
EndDo 

SX2->(DbSeek("SW"))
While SubStr(Alltrim(SX2->X2_CHAVE),1,2) == "SW" .And. !SX2->(EOF())
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})
	AADD(aSX3,{SubStr(Alltrim(SX2->X2_CHAVE),1,3),'',SubStr(Alltrim(SX2->X2_CHAVE),2,2)+'_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
	AADD(aArqUpd,SubStr(Alltrim(SX2->X2_CHAVE),1,3))
SX2->(dbSkip())
EndDo 

AADD(aSX3,{'SB1','','B1_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})     
AADD(aSX3,{'SB1','','B1_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})     
AADD(aArqUpd,'SB1')

AADD(aSX3,{'SE1','','E1_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})     
AADD(aSX3,{'SE1','','E1_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
AADD(aArqUpd,'SE1')

AADD(aSX3,{'SE2','','E2_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})     
AADD(aSX3,{'SE2','','E2_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
AADD(aArqUpd,'SE2')

AADD(aSX3,{'SE5','','E5_USERLGI','C','17','0','Log de Inclu','Log de Inclusao','���������������','9','�A','L','S','V','R'})     
AADD(aSX3,{'SE5','','E5_USERLGA','C','17','0','Log de Alter','Log de Alteracao','���������������','9','�A','L','S','V','R'})
AADD(aArqUpd,'SE5')

//Incluindo a �ltima ordem no campo de log.
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

//<Chamada das fun��es para a cria��o dos dicion�rios -- **N�O MEXER** >
CriaSx3(aSX3,@cTexto)


Return(cTexto)


*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*
Local lIncSX3	:= .F.

For i:=1 to len(aSX3)
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(!DbSeek(aSX3[i][3]))
		SX3->(Reclock("SX3",.T.))
		
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
		
		SX3->(MsUnlock())
		cTexto += "Incluido no SX3 - o campo:"+aSX3[i][3]+NL
	Else
		cTexto += "J� existe no SX3 - o campo:"+aSX3[i][3]+NL
	EndIf
	
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