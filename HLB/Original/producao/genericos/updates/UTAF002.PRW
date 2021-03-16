#Include "Protheus.ch" 
#Include "TBICONN.ch"

/*
Funcao      : UTAF002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Update que cria e inserir nas tabelas de acordo com uma empresa modelo
Autor       : Anderson Arrais
Data/Hora   : 19/12/2017 
*/

*--------------------*
User Function UTAF002
*--------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd
Private NL := CHR(13) + CHR(10)
		
Begin Sequence
   Set Dele On
   
   lHistorico	:= MsgYesNo("Deseja efetuar a atualização das tabelas autocontidas","Atenção")
                            
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização de tabelas autocontidas"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) , oMainWnd:End()),;
                                         oMainWnd:End())
End Sequence

Return
*----------------------*
Static Function UPDProc
*----------------------*
Local aRecnoSM0 := {}
Local cTexto 	:= ""
Local lOpen  	:= .F.

Private cBancoOri	:="P11_TESTE"
Private cEmpOri		:="YY"

	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa "YY" Filial "01"

If LEN(SUPERGETMV("MV_P_00113", .F. , '' )) < 1
	AtuSX6()
EndIf
	
	cLisTab := SUPERGETMV("MV_P_00113", .F. , '' )
	
	Reset Environment 
	
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
				
			 ProcTAF(@cTexto,cLisTab)

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

Return

*--------------------------------------*
Static Function ProcTAF(cTexto,cLisTab)
*--------------------------------------*

Local aTabs 	:= Separa(cvaltochar(cLisTab),',',.F.) 
Local cTbelas 	:= ""

For i:=1 to len(aTabs)

IncProc("Atualizando estruturas. Aguarde... ["+aTabs[i]+"]")

	//Chama o Job
	StartJob( "U__UTAF021      "+aTabs[i], GetEnvServer() , .F.,cEmpAnt,cFilAnt,aTabs[i])
   	sleep(400)
    
    //Chama o Job de atualização da tabela
	StartJob( "U__UTAF022       "+aTabs[i], GetEnvServer() , .F.,cEmpAnt,cFilAnt,aTabs[i],cBancoOri,cEmpOri)
    sleep(100)

	//Para evitar sobrecarga no serviço
	if ThreadCount()>50
		sleep(1000)	
	endif
	cTbelas += aTabs[i]+", "
	
Next
cTexto+="Tabelas atualizadas: "+cTbelas+" "+NL


Return

//Função para criar a tabela na empresa
*----------------------------------------*
User Function _UTAF021(cEmp,cFilEmp,cTab)
*----------------------------------------*

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

	for nSeq:=1 to 5
		if CHKFILE(cTab)
			exit	
		endif
    next
    
RpcClearEnv()

Return

//Função para criar a tabela na empresa
*--------------------------------------------------------------------*
User Function _UTAF022(cEmp,cFilEmp,cTab,cBancoOri,cEmpOri)
*--------------------------------------------------------------------*
Local cQry		:= ""
Local cPasta	:= "\BKP"
Local cPasta1	:= "\TAF"
Local aStruc	:= {}
Local nErro		:= 0
Local lExcl		:= .F.
Local aFilial 	:= {}

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

aFilial := FWAllFilial()
//ConOut(cEmp)

DbSelectArea("SX2")
SX2->(DbGoTop())
SX2->(DbSetOrder(1))
SX2->(DbSeek(cTab))
If SX2->X2_MODO $ "E"
	lExcl := .T.
EndIf

For nR:=1 to len(aFilial)
	cQry:=""
	cQry+=" Declare @COLS  VARCHAR(400)
	cQry+=" Declare @COLS2 VARCHAR(400)
	cQry+=" Declare @COLS3 VARCHAR(400)
	cQry+=" Declare @QRY   VARCHAR(1000)
	
	cQry+=" SET @COLS =(SELECT
	cQry+=" STUFF(( SELECT ','+name FROM sys.columns
	cQry+=" WHERE is_identity=0 and name not in('R_E_C_N_O_','R_E_C_D_E_L_') and system_type_id not in(34,35,99,241) and object_id =
	cQry+=" (SELECT object_id FROM sys.tables WHERE name = '"+cTab+cEmp+"0' )FOR XML PATH('') ),1,1,''))
	
	cQry+=" SET @COLS2 =(SELECT
	cQry+=" STUFF(( SELECT ','+name FROM sys.columns
	cQry+=" WHERE is_identity=0 and (name not in('R_E_C_N_O_','R_E_C_D_E_L_') and name not like '%FILIAL') and system_type_id not in(34,35,99,241) and object_id =
	cQry+=" (SELECT object_id FROM sys.tables WHERE name = '"+cTab+cEmp+"0' )FOR XML PATH('') ),1,1,''))
	
	cQry+=" SET @COLS3 =(SELECT
	cQry+=" STUFF(( SELECT ','+name FROM sys.columns
	cQry+=" WHERE is_identity=0 and name like '%FILIAL' and system_type_id not in(34,35,99,241) and object_id =
	cQry+=" (SELECT object_id FROM sys.tables WHERE name = '"+cTab+cEmp+"0' )FOR XML PATH('') ),1,1,''))
	
	cQry+=" BEGIN
	cQry+=" SET @QRY='INSERT INTO "+cTab+cEmp+"0 ('+@COLS+',R_E_C_N_O_) SELECT *,(SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM "+cTab+cEmp+"0)+ROW_NUMBER() OVER(ORDER BY D_E_L_E_T_ ASC) 
	If lExcl
		//TABELA ECLUSIVA
		cQry+=" FROM (SELECT ''"+aFilial[nR]+"'' AS '+@COLS3+','+@COLS2+' FROM "+cBancoOri+".dbo."+cTab+cEmpOri+"0 WHERE '+@COLS3+'=01 EXCEPT SELECT '+@COLS+' FROM "+cTab+cEmp+"0 WHERE '+@COLS3+'=''"+aFilial[nR]+"'' ) TEMP'
	Else
		//TABELA COMPARTILHADA
		cQry+=" FROM (SELECT '+@COLS+' FROM "+cBancoOri+".dbo."+cTab+cEmpOri+"0 EXCEPT SELECT '+@COLS+' FROM "+cTab+cEmp+"0) TEMP'
	EndIf
	cQry+=" END
	//ConOut(aFilial[nR])
    //ConOut(cQry)
	cQry+=" exec(@QRY)
	
	TcSqlExec(cQry)

	If !lExcl	
		EXIT
	EndIf
Next nR

RpcClearEnv()

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

oDlg1      := MSDialog():New( 091,232,451,612,"Equipe TI da HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oGroup	   := tGroup():New(004,002,28,190,'Dados de Origem',oDlg1,,,.T.)

oSay3      := TSay():New( 016,004,{||"Banco:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet1	   := TGet():New(  14,25,{|u| if(PCount()>0,cBancoOri:=u,cBancoOri)}, oDlg1,30,8,'@!',,,,,,,.T.,,,,,,,,,,'cBancoOri')

oSay4      := TSay():New( 016,60,{||"Empresa:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet2	   := TGet():New(  14,85,{|u| if(PCount()>0,cEmpOri:=u,cEmpOri)}, oDlg1,20,8,'@!',,,,,,,.T.,,,,,,,,,,'cEmpOri')

oGroup	   := tGroup():New(032,002,163,190,'Selecione as empresas a serem atualizadas',oDlg1,,,.T.)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{041,004,149,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.
oCBox1     := TCheckBox():New( 153,004,"Todas empresas.",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oSBtn1     := SButton():New( 167,116,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 167,152,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

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
	   //dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .T. ) //abre compartilhado 
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

*------------------------------*
Static Function AtuSX6()
*------------------------------*
Local aSX6:= {}
Local cTexto:=""

****************************************************************************************************************************************** 
//{SX6} - Parametros
//AADD(aSX6,{X6_FIL,X6_VAR,X6_TIPO,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1,X6_DESC2,X6_DSCSPA2,X6_DSCENG2,X6_CONTEUD,X6_CONTSPA,X6_CONTENG,X6_PROPRI,X6_PYME,X6_VALID,X6_INIT,X6_DEFPOR,X6_DEFSPA,X6_DEFENG})
aadd(aSX6,{xFilial("SX6"),"MV_P_00113","C","Lista de tabelas","Lista de tabelas","Lista de tabelas","","","","","","","CC4,CC5,CC9,CCA,CCB,CCC,CCD,CCH,CC2,CDY,F08,CC6,CDO,CCK,CE7","CC4,CC5,CC9,CCA,CCB,CCC,CCD,CCH,CC2,CDY,F08,CC6,CDO,CCK,CE7","CC4,CC5,CC9,CCA,CCB,CCC,CCD,CCH,CC2,CDY,F08,CC6,CDO,CCK,CE7","U"})
****************************************************************************************************************************************** 
//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx6(aSX6,@cTexto)
//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------------*
Static Function CriaSx6(aSX6,cTexto)
*-----------------------------------*
Local lIncSX6 := .F.
Local i := 1

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
	cTexto += "Incluido no SX6 - o parâmetro:"+aSX6[i][1]+aSX6[i][2]+NL
else
	cTexto += "Alterado no SX6 - o parâmetro:"+aSX6[i][1]+aSX6[i][2]+NL
endif	
	
Return