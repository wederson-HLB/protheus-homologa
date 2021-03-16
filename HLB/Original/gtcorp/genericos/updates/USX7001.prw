#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX7001
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Criar gatilho para quando o Cliente for Pessoa Juridica e o tipo for igual a F,L,R,S preenche os campos com sim e quando o tipo for X preencher com não, os casos se aplicam para pessoa fisica.
Autor       : Richard Busso
Data/Hora   : 05/01/2017 08:00
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*---------------------*
User Function USX7001()
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


Local aChamados := { {04, {|| FuncSX7()}}}

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
			
			/*             
			//Atualizando uma tabela sem derrubar o sistema:
			__SetX31Mode(.F.) //opcional - para não permitir alterar o SX3
			
			X31UpdTable(cAlias) //Atualiza o cAlias baseado no SX3
			
			If __GetX31Error() //Verifica se ocorreu erro
				Alert(__GetX31Trace()) //Mostra os erros
			Endif
			*/
			
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

*-----------------------------*
Static Function FuncSX7()
*-----------------------------*
Local cTexto:=""

    //Altera o campo na A1_TIGGER para "S" para que o gatilho funcione.
	AltSA1(@cTexto) 
	
	//Cria os gatilhos.
	IncSX7(@cTexto)

Return(cTexto)

*-----------------------------*
Static Function AltSA1(cTexto)
*-----------------------------*
//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SA1"}
DbSelectArea("SX3")
SX3->(DbSetOrder())
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SA1'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem
SX3->(DbSetOrder(2))
SX3->(DbGotop()) 
SX3->(DbSeek("A1_PESSOA"))

Reclock("SX3",.F.)
	SX3->X3_TRIGGER:="S"
SX3->(MsUnlock())

cTexto += "Alterado os campos A1_PESSOA no SX3 da tabela SA1 "+NL

//<Inicio>Tratamento para buscar a ultima ordem
bCondicao := {|| X3_ARQUIVO == "SA1"}
DbSelectArea("SX3")
SX3->(DbSetOrder())
SX3->(DbSetFilter(bCondicao,"X3_ARQUIVO == 'SA1'"))
SX3->(DbGoBottom())
cUltOrdem:=SOMA1(SX3->X3_ORDEM)
SX3->(DBCLEARALLFILTER())
//<Inicio>Tratamento para buscar a ultima ordem
SX3->(DbSetOrder(2))
SX3->(DbGotop()) 
SX3->(DbSeek("A1_TIPO"))

Reclock("SX3",.F.)
	SX3->X3_TRIGGER:="S"
SX3->(MsUnlock())

cTexto += "Alterado os campos A1_TIPO no SX3 da tabela SA1 "+NL

Return(cTexto)

//proposta
*------------------------------*
Static Function IncSX7(cTexto)
*------------------------------*
Local aSX7:= {}

****************************************************************************************************************************************** 
//{SX7} - Gatilhos
//AADD(aSX7,{X7_CAMPO,X7_SEQUENC,X7_REGRA,X7_CDOMIN,X7_TIPO,X7_SEEK,X7_ALIAS,X7_ORDEM,X7_CHAVE,X7_CONDIC,X7_PROPRI})
//Gatilhos para quando for selecionado o Tipo do Cliente.
AADD(aSX7,{"A1_TIPO","001","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECCOFI","P","N","","","","","U"})
AADD(aSX7,{"A1_TIPO","002","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECCSLL","P","N","","","","","U"})
AADD(aSX7,{"A1_TIPO","003","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECPIS","P","N","","","","","U"})
AADD(aSX7,{"A1_TIPO","004","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECINSS","P","N","","","","","U"})
AADD(aSX7,{"A1_TIPO","005","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','3','1'),'3')","A1_ABATIMP","P","N","","","","","U"})
//Gatilhos para quando for selecionado se o cliente é Pessoa Fisica ou Juridica.
AADD(aSX7,{"A1_PESSOA","001","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECCOFI","P","N","","","","","U"})
AADD(aSX7,{"A1_PESSOA","002","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECCSLL","P","N","","","","","U"})
AADD(aSX7,{"A1_PESSOA","003","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECPIS","P","N","","","","","U"})
AADD(aSX7,{"A1_PESSOA","004","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','N','S'),'N')","A1_RECINSS","P","N","","","","","U"})
AADD(aSX7,{"A1_PESSOA","005","IIF(M->A1_PESSOA == 'J',IIF(M->A1_TIPO == 'X','3','1'),'3')","A1_ABATIMP","P","N","","","","","U"})

****************************************************************************************************************************************** 
//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx7(aSX7,@cTexto)
//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------------*
Static Function CriaSx7(aSX7,cTexto)
*-----------------------------------*           

Local lIncSX7	:= .F.

For i:=1 to len(aSX7)

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	if SX7->(!DbSeek(PADR(aSX7[i][1],10)+aSX7[i][2]))
		lIncSX7:=.T.
	else
		lIncSX7:=.F.
	endif
	
	Reclock("SX7",lIncSX7)
	
		SX7->X7_CAMPO	:= aSX7[i][1]
		SX7->X7_SEQUENC	:= aSX7[i][2]
		SX7->X7_REGRA	:= aSX7[i][3]
		SX7->X7_CDOMIN	:= aSX7[i][4]
		SX7->X7_TIPO	:= aSX7[i][5]
		SX7->X7_SEEK	:= aSX7[i][6]
		SX7->X7_ALIAS	:= aSX7[i][7]
		SX7->X7_ORDEM	:= val(aSX7[i][8])
		SX7->X7_CHAVE	:= aSX7[i][9]
		SX7->X7_CONDIC	:= aSX7[i][10]
		SX7->X7_PROPRI	:= aSX7[i][11]

	SX7->(MsUnlock())	
	
	if lIncSX7
		cTexto += "Incluido no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
	else
		cTexto += "Alterado no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
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