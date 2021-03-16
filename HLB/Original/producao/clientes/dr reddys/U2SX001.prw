#INCLUDE "Protheus.ch"

/*
Funcao      : U2SX001
Parametros  : Nenhum
Retorno     : Nil 
Objetivos   : atualizacao de campos, indices, tabelas
Autor       : Leandro Brito
Chamado		: 
Data/Hora   : 15/01/2018
*/                                                                                                

*---------------------*
User Function U2SX001()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"NNR"}
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
Local aChamados := {	{05, {|| AtuSX2()}} , {05, {|| AtuSX3()}} , {05, {|| AtuSix()}} , {05, {|| AtuSX6()}} }
Local aExec     := { { { ||  AtuNNR() } , "Atualização tabela NNR" } }

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
			 
			 //** Efetua atualizações após execução do update
			 ProcRegua( Len( aExec ) ) 
			 For nX := 1 To Len( aExec )
			 	IncProc( aExec[ nX ][ 2 ] )
				cTexto += Eval( aExec[ nX ][ 1 ] )  
			 Next
			 
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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .t., .F. ) //Exclusivo
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
Funcao      : ATUSIX
Autor  		: Ramon Prado
Data     	: 09/01/2016
Objetivos   : Atualização do Dicionario SIX.
*/
*----------------------------*
Static Function AtuSIX()
*----------------------------*
Local aArea := getArea()
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSIX    := {}
Local cOrdem  := ''
Local i := 0
Local j := 0

DbSelectArea("SIX")

aEstrut:= { "INDICE","ORDEM"  ,"CHAVE"  ,"DESCRICAO"   ,"DESCSPA","DESCENG","PROPRI" ,"F3" ,"NICKNAME" ,"SHOWPESQ" }
	
//Aadd( aSix ,{ "Z21" , "1" , "Z21_FILIAL+Z21_DATA" , "Data" , "Data" , "Data" , "U" , , "" , "S" } )  
//Aadd( aSix ,{ "Z21" , "2" , "Z21_FILIAL+Z21_USER+Z21_DATA" , "User+Data" , "User+Data" , "User+Data" , "U" , , "" , "S" } )  
//Aadd( aSix ,{ "Z21" , "3" , "Z21_FILIAL+Z21_ID" , "Id" , "Id" , "Id" , "U" , , "" , "S" } )  

ProcRegua(Len(aSIX))
SIX->(DbSetOrder(1))
For i:= 1 To Len(aSIX)
	If !Empty(aSIX[i][1])
		If !(SIX->(DbSeek(aSIX[i][1]+aSIX[i][2])))
			RecLock("SIX",.T.)
			For j:=1 To Len(aSIX[i])
				If FieldPos(aEstrut[j])>0 .And. aSIX[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			cTexto += "- Indice " + aSIX[i][1] +" ordem " + aSIX[i][2] + " criado ."+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
		Else
			cTexto += "- Indice " + aSIX[i][1] +" ordem " + aSIX[i][2] + " ja existe ."+ CHR(10) + CHR(13)
		EndIf		
	EndIf
Next i

RestArea(aArea)
Return cTexto

/*
/*
Funcao      : ATUSX2
Autor  		: Ramon Prado
Data     	: 19/12/2016
Objetivos   : Atualização do Dicionario SX2.
*/
*----------------------------*
Static Function AtuSX2()
*----------------------------*
Local aArea := getArea()
Local cTexto:=""    
Local cAlias  := '' 
Local aEstrut := {}
Local aSX2	  := {}
Local nI := 0   
Local i := 0 
Local j := 0 

SX2->(DbGoTop())
SX2->(DbSetOrder(1)) //X2_CHAVE

//Cria a tabela PI0 no SX2 caso não exista
DbSelectArea("SX2")

aEstrut:= { "X2_CHAVE","X2_PATH"  ,"X2_ARQUIVO"  ,"X2_NOME"   ,"X2_NOMESPA","X2_NOMEENG","X2_ROTINA" ,"X2_MODO" ,"X2_MODOUN" ,;
			"X2_MODOEMP","X2_DELET","X2_TTS","X2_UNICO","X2_PYME"  ,"X2_MODULO"  ,"X2_DISPLAY","X2_SYSOBJ"     ,"X2_USROBJ"  ,;
			"X2_POSLGT" ,"X2_CLOB"  ,"X2_AUTREC","X2_TAMFIL" ,"X2_TAMUN" ,"X2_TAMEMP" }	 	

//aAdd(aSX2,{"Z21",'\','Z21'+cEmpAnt+'0' ,'Tabela de log','Tabela de log','Tabela de log',""	,;
//"C"	,"C"	,"C",0,"","","S",0,"" ,"","","","","",0,0,0 } ) 

ProcRegua(Len(aSX2))
SX2->(DbSetOrder(1))
For i:= 1 To Len(aSX2)
	If !Empty(aSX2[i][1])
		If !(SX2->(DbSeek(aSX2[i][1])))
			RecLock("SX2",.T.)
			For j:=1 To Len(aSX2[i])
				If FieldPos(aEstrut[j])>0 .And. aSX2[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX2[i,j])
				EndIf
			Next j
			cTexto += "- Tabela " + aSx2[i][1] +" criada ."+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
		Else
			RecLock("SX2",.F.)
			For j:=1 To Len(aSX2[i])
				If FieldPos(aEstrut[j])>0 .And. aSX2[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX2[i,j])
				EndIf
			Next j
			cTexto += "- Tabela " + aSx2[i][1] +" atualizada ."+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
		EndIf		
	EndIf
Next i   

RestArea(aArea)
Return cTexto        

/*
Funcao      : ATUSX3
Autor  		: Ramon Prado
Data     	: 20/12/2016
Objetivos   : Atualização do Dicionario SX3.
*/
*----------------------------*
Static Function AtuSX3()
*----------------------------* 
Local aArea := getArea()
Local cTexto := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}
Local cOrdem  := NextOrdem('SA5')              
Local nLenCampo := Len( SX3->X3_CAMPO )
Local i := 0
Local j := 0

DbSelectArea("SX3")

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}


cOrdem  := NextOrdem('NNR')              
aAdd(aSX3,{"NNR",cOrdem,"NNR_P_BLQE"	  		,"C",1,0,"Bloq.Entrada"	,"Bloq.Entrada"	,"Bloq.Entrada"	,"Bloq.Entrada"	,"Bloq.Entrada"	,"Bloq.Entrada","",'','€€€€€€€€€€€€€€',"" ,"",0,'þA',"","","U","S","A","R","€","","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"NNR",cOrdem,"NNR_P_BLQS"	  		,"C",1,0,"Bloq.Saida"	,"Bloq.Saida"	,"Bloq.Saida"	,"Bloq.Saida"	,"Bloq.Saida"	,"Bloq.Saida","",'','€€€€€€€€€€€€€€',"" ,"",0,'þA',"","","U","S","A","R","€","","","","","","","","","","N"})

ProcRegua(Len(aSX3))

SX3->(DbSetOrder(2)) 
For i:= 1 To Len(aSX3)
	If !Empty(aSX3[i][1])
		If !(SX3->(DbSeek(PadR(aSX3[i][3],nLenCampo))))
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
			RecLock("SX3",.F.)
			For j:=1 To Len(aSX3[i])
				If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
				EndIf
			Next j
			cTexto += "- Campo Atualizado. '"+aSX3[i,3]+"'"+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
		EndIf		
	EndIf
Next i 

RestArea(aArea)
Return(cTexto)    

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
dbUseArea(.T.,,cNome,cAliasWork,.t.,.F.)
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
/*
Funcao      : ATUSX6
Autor  		: Leandro Brito
Data     	: 06/11/2015 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
 Static Function ATUSX6()
*-------------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX6    := {}
Local cOrdem  := ''      
Local nLenFil := Len( SX6->X6_FIL )
Local nLenVar := Len( SX6->X6_VAR )

DbSelectArea("SX6")

aEstrut:= { "X6_FIL","X6_VAR"  ,"X6_TIPO"  ,"X6_DESCRIC"   ,"X6_DSCSPA","X6_DSCENG","X6_DESC1" ,"X6_DSCSPA1" ,"X6_DSCENG1" ,;
			"X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"  ,"X6_VALID"  ,"X6_INIT" }
	


aAdd(aSX6,{"","MV_P_LIBTR","C" ,'Usuario Aut. transf. estoque','Usuario Aut. transf. estoque','Usuario Aut. transf. estoque',""	,;
""	,""	,"","","","U","","",""}) 

ProcRegua(Len(aSX6))
SX6->(DbSetOrder(1))
For i:= 1 To Len(aSX6)
	If !(SX6->(DbSeek(PadR(aSX6[i][1],nLenFil)+PadR(aSX6[i][2],nLenVar))))
		RecLock("SX6",.T.)
		For j:=1 To Len(aSX6[i])
			If FieldPos(aEstrut[j])>0 .And. aSX6[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
			EndIf
		Next j
		cTexto += "- Parametro " + aSx6[i][2] +" criado ."+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
	ElseIf !Empty( aSx6[ i ][ 10 ] )   
		RecLock("SX6",.F.)
		For j:=1 To Len(aSX6[i])
			If FieldPos(aEstrut[j])>0 .And. aSX6[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
			EndIf
		Next j	
		cTexto += "- Parametro " + aSx6[i][2] +" alterado ."+ CHR(10) + CHR(13)		
	Else
		cTexto += "- Parametro " + aSx6[i][2] +" ja existe ."+ CHR(10) + CHR(13)
	EndIf
Next i


Return cTexto 

/*
Função......: AtuNNR
Objetivo....: Criar ou Atualizar armazens cadastrados na tabela NNR    
Autor.......: Leandro Diniz de Brito 
*/
*---------------------------------------------------*
Static Function AtuNNR
*---------------------------------------------------*
Local cTexto 	:= ""
Local aArm  	:= {}  

Local aEstru    := { "NNR_FILIAL" , "NNR_CODIGO" , "NNR_DESCRI" , "NNR_TIPO" , "NNR_P_BLQE" , "NNR_P_BLQS" } 
Local aDados 	:= {}

Local cFilNNR 	:= xFilial( 'NNR' )
Local i                                   
Local j    
       

AAdd( aDados , { cFilNNR  , "00" , "ENTR.MAT.NAO PROD." 	, "1" , "2" , "2" } )
AAdd( aDados , { cFilNNR  , "01" , "QUARENTENA" 			, "1" , "2" , "1" } )
AAdd( aDados , { cFilNNR  , "02" , "APROVADO" 				, "1" , "1" , "2" } )
AAdd( aDados , { cFilNNR  , "03" , "OPERADOR LOGISTICO" 	, "1" , "1" , "2" } )
AAdd( aDados , { cFilNNR  , "04" , "REJEITADO" 				, "1" , "1" , "2" } )
AAdd( aDados , { cFilNNR  , "05" , "DEVOLUCAO" 				, "1" , "2" , "1" } )
AAdd( aDados , { cFilNNR  , "06" , "CONTROLE/QUALIDADE" 	, "1" , "2" , "2" } )
AAdd( aDados , { cFilNNR  , "07" , "RETENCAO"       		, "1" , "1" , "1" } )
AAdd( aDados , { cFilNNR  , "08" , "AMOSTRA G QUARENTENA" 	, "1" , "2" , "1" } )
AAdd( aDados , { cFilNNR  , "09" , "AMOSTRA G APROVADAS " 	, "1" , "1" , "2" } )
AAdd( aDados , { cFilNNR  , "10" , "AMOSTRA G NO OP.LOGI" 	, "1" , "1" , "2" } )
AAdd( aDados , { cFilNNR  , "11" , "ESTOQUE DOACAO"	 		, "1" , "1" , "2" } )
AAdd( aDados , { cFilNNR  , "12" , "CONS.CONTR.QUALIDADE"	, "1" , "2" , "2" } )


If NNR->( FieldPos( 'NNR_P_BLQE' ) > 0 .And. FieldPos( 'NNR_P_BLQS' ) > 0 )

	cTexto += "** Inicio atualização tabela NNR" + Chr( 13 ) + Chr( 10 )
	NNR->( DbSetOrder( 1 ) )
	
	For i := 1 To Len( aDados ) 
		If NNR->( !DbSeek( aDados[ i ][ 1 ] + aDados[ i ][ 2 ] ) )
			NNR->( RecLock( "NNR" , .T. ) )
			cTexto := "Armazem " + aDados[ i ][ 2 ] + " incluido." + Chr( 13 ) + Chr( 10 )
		Else 
			NNR->( RecLock( "NNR" , .F. ) )		
			cTexto := "Armazem " + aDados[ i ][ 2 ] + " alterado." + Chr( 13 ) + Chr( 10 )			
		EndIf	   
		
		AEVal( aEstru , { | x,j | NNR->&( x ) := aDados[ i ][ j ] } )                        
		
		NNR->( MSUnlock() )
	Next
	
	cTexto += "** Fim atualização tabela NNR" + Chr( 13 ) + Chr( 10 )
EndIf




Return( cTexto )