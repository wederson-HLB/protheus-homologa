#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX3073
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação dos campos das informações Complementares - Calculo de caixas e tamanhos.
Autor       : Richard S Busso
Chamado		: 
Empresa		: JG - RENESOLA
Data/Hora   : 04/05/2017
*/                                                             
*---------------------*
User Function USX3073()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"SB1"}
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
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas de forma exclusiva!.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)

/*
Funcao      : ATUSX3
Autor  		: Richard S Busso 
Data     	: 04/05/2017
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
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_TITSPA,X3_TITENG,X3_DESCRIC,X3_DESCSPA,X3_DESCENG,X3_PICTURE,X3_USADO,X3_RELACAO,X3_RESERV,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_VLDUSER,X3_FOLDER,X3_ORTOGRA,X3_IDXFLD})

AADD(aSX3,{	'SB1','S6','B1_P_UNQTD','N','5','','Uni. Quantid','Uni. Quantid','Uni. Quantid','Unidade Quantidade','Unidade Quantidade','Unidade Quantidade','@E 99999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','S7','B1_P_MUQTD','N','5','','Mult.Quantid','Mult.Quantid','Mult.Quantid','Multipla Quantidade','Multipla Quantidade','Multipla Quantidade','@E 99999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','S8','B1_P_MAQTD','N','5','','Mast.Quantid','Mast.Quantid','Mast.Quantid','Master Quantidade','Master Quantidade','Master Quantidade','@E 99999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','S9','B1_P_PAQTD','N','5','','Pallet Quant','Pallet Quant','Pallet Quant','Pallet Quantidade','Pallet Quantidade','Pallet Quantidade','@E 99999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T0','B1_P_UNCB','C','20','','Uni.Cod.Bar.','Uni.Cod.Bar.','Uni.Cod.Bar.','Unidade Codigo de Barras','Unidade Codigo de Barras','Unidade Codigo de Barras','@!','', '' })
AADD(aSX3,{	'SB1','T1','B1_P_MUCB','C','20','','Mult.Cod.Bar','Mult.Cod.Bar','Mult.Cod.Bar','Multiplos Codigo de Barra','Multiplos Codigo de Barra','Multiplos Codigo de Barra','@!','', '' })
AADD(aSX3,{	'SB1','T2','B1_P_MACB','C','20','','Mast.Cod.Bar','Mast.Cod.Bar','Mast.Cod.Bar','Master Codigo de Barras','Master Codigo de Barras','Master Codigo de Barras','@!','', '' })
AADD(aSX3,{	'SB1','T3','B1_P_UNPL','N','6','2','Uni.Peso Liq','Uni.Peso Liq','Uni.Peso Liq','Unidade peso liquido','Unidade peso liquido','Unidade peso liquido','@E 999.99','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T4','B1_P_MUPL','N','6','2','Mult.Pes.Liq','Mult.Pes.Liq','Mult.Pes.Liq','Multiplos Peso Liquido','Multiplos Peso Liquido','Multiplos Peso Liquido','@E 999.99','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T5','B1_P_MAPL','N','6','2','Mast.Pes.Liq','Mast.Pes.Liq','Mast.Pes.Liq','Master Peso Liquido','Master Peso Liquido','Master Peso Liquido','@E 999.99','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T6','B1_P_UNPB','N','6','2','Uni.Peso Bru','Uni.Peso Bru','Uni.Peso Bru','Unitario Peso Bruto','Unitario Peso Bruto','Unitario Peso Bruto','@E 999.99','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T7','B1_P_MUPB','N','6','2','Mult.Pes.bru','Mult.Pes.bru','Mult.Pes.bru','Multiplo Peso Bruto','Multiplo Peso Bruto','Multiplo Peso Bruto','@E 999.99','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T8','B1_P_MAPB','N','6','2','Mast.Pes.bru','Mast.Pes.bru','Mast.Pes.bru','Master Peso Bruto','Master Peso Bruto','Master Peso Bruto','@E 999.99','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','T9','B1_P_UNDIC','N','9','3','Uni.Comprim','Uni.Comprim','Uni.Comprim','Unitario Dimensao Comprim','Unitario Dimensao Comprim','Unitario Dimensao Comprim','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U0','B1_P_UNDIL','N','9','3','Uni.Largura.','Uni.Largura','Uni.Largura','Unitario Dimensao Largura','Unitario Dimensao Largura','Unitario Dimensao Largura','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U1','B1_P_UNDIA','N','9','3','Uni.Altura','Uni.Altura','Uni.Altura','Unitario Dimensao Altura','Unitario Dimensao Altura','Unitario Dimensao Altura','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U2','B1_P_MUDIC','N','9','3','Mult.Compri','Mult.Compri','Mult.Compri','Multiplo Dimensao Comprim','Multiplo Dimensao Comprim','Multiplo Dimensao Comprim','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U3','B1_P_MUDIL','N','9','3','Mult.Largur','Mult.Largur','Mult.Largur','Multiplo Dimensao Largura','Multiplo Dimensao Largura','Multiplo Dimensao Largura','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U4','B1_P_MUDIA','N','9','3','Mult.Altura','Mult.Altura','Mult.Altura','Multiplo Dimensao Altura','Multiplo Dimensao Altura','Multiplo Dimensao Altura','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U5','B1_P_MADIC','N','9','3','Mast.Compri','Mast.Compri','Mast.Compri','Master Dimensao Comprimen','Master Dimensao Comprimen','Master Dimensao Comprimen','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U6','B1_P_MADIL','N','9','3','Mast.Largur','Mast.Largur','Mast.Largur','Master Dimensao Largura','Master Dimensao Largura','Master Dimensao Largura','@E 99,999.999','0', '!VAZIO()' })
AADD(aSX3,{	'SB1','U7','B1_P_MADIA','N','9','3','Mast.Altura','Mast.Altura','Mast.Altura','Master Dimensao Altura','Master Dimensao Altura','Master Dimensao Altura','@E 99,999.999','0', '!VAZIO()' })

CriaSx3(aSX3,@cTexto)

Return(cTexto)

*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*
Local lIncSX3	:= .F.

DbSelectArea("SXA")
SXA->(DbSetOrder(1))

If SXA->(!dbSeek("SB1" + "9"))
	SXA->(Reclock("SXA",.T.))
		SXA->XA_ALIAS	:= "SB1"
		SXA->XA_ORDEM   := "9"          
		SXA->XA_DESCRIC := "Informacoes Logistica"
		SXA->XA_DESCSPA := "Informacion Logistica"
		SXA->XA_DESCENG := "Information Logistica"
		SXA->XA_PROPRI	:= "U"
	SXA->(MsUnlock())   
	
	cTexto += "Incluido no SXA - a aba : Informacoes Embalagem "+NL
Else
	cTexto += "Já existe a aba : Informacoes Embalagem"+NL
Endif

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For i:=1 to len(aSX3)
	If SX3->(!DbSeek(aSX3[i][3]))
		lIncSX3 := .T.
    Endif
	
	SX3->(Reclock("SX3",lIncSX3))
		SX3->X3_ARQUIVO	:= aSX3[i][1]
		SX3->X3_ORDEM	:= aSX3[i][2]
		SX3->X3_CAMPO	:= aSX3[i][3]
		SX3->X3_TIPO	:= aSX3[i][4] 
		SX3->X3_TAMANHO	:= val(aSX3[i][5])
		SX3->X3_DECIMAL	:= val(aSX3[i][6])
		SX3->X3_TITULO	:= aSX3[i][7]
		SX3->X3_TITSPA	:= aSX3[i][8]
		SX3->X3_TITENG	:= aSX3[i][9]
		SX3->X3_DESCRIC	:= aSX3[i][10]
		SX3->X3_DESCSPA	:= aSX3[i][11]
		SX3->X3_DESCENG	:= aSX3[i][12]
		SX3->X3_PICTURE	:= aSX3[i][13]
		SX3->X3_USADO	:= "€€€€€€€€€€€€€€ "
		SX3->X3_NIVEL	:= 0
		SX3->X3_RELACAO	:= aSX3[i][14]
		SX3->X3_RESERV	:= "þA"
		SX3->X3_PROPRI	:= "U"
		SX3->X3_BROWSE	:= "N"
		SX3->X3_VISUAL	:= "A"
		SX3->X3_CONTEXT	:= "R"
		SX3->X3_VLDUSER	:= aSX3[i][15]
		SX3->X3_FOLDER	:= "9"
		SX3->X3_ORTOGRA	:= "N"
		SX3->X3_IDXFLD	:= "N"
	SX3->(MsUnlock())

	If !lIncSX3
	   	cTexto += "Atualizado no SX3 - o campo :"+aSX3[i][3]+NL
    Else
		cTexto += "Incluido no SX3 - o campo :"+aSX3[i][3]+NL
	Endif

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