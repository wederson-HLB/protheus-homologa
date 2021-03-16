#Include "Protheus.Ch" 
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : GTMIG12
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Migrador da Versão 12
Autor       : Renato Rezende 
Cliente		: Todos
Data/Hora   : 10/08/2017
*/
*-------------------------*
 User Function GTMIG12()
*-------------------------*

//Função principal da migração.
Processa({|lEnd| MAIN()},"Processando...")

Return

/*
Funcao      : MAIN
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função principal
Autor       : Renato Rezende
Data/Hora   : 01/11/2017
*/
*------------------------*
Static Function MAIN()
*------------------------*
Local cTexto	:= "" 
Local cFile 	:= ""
Local cMask 	:= "Arquivos Texto (*.TXT) |*.txt|"
Local lOpen		:= .F.
Local i			:= 0
Local aRecnoSM0 := {}
Local nPos		:= 0

Private lCheck	:= lCheck1 := lCheck2 := lCheck4 := lCheck7 := lCheck8 := lCheck9 := lCheck10 := lCheck11 := .F.
Private lCheck3 := lCheck5 := lCheck6 := .F.
Private cGet1	:= "20"
//Private cGetSPED:= "SPED_P10"+Space(4)
Private aAux :={}
Private aEmps:={}
Private aSx3 :={}


If ( lOpen := MyOpenSm0Ex() )

	If !Tela()
		Return .T.
	EndIf
    
	SM0->(dbSelectArea("SM0"))
	SM0->(dbGotop())
	While SM0->(!Eof())
		If Len(aAux) > 0 .or. lCheck1
			If	lCheck1 .and.;
				Ascan(aRecnoSM0,{ |x| x[2] 		== SM0->M0_CODIGO}) == 0				

				Aadd(aRecnoSM0,	{SM0->(Recno()),SM0->M0_CODIGO})
			ElseIf	!lCheck1 .and.;
					Ascan(aAux,		{ |x| LEFT(x,2) == SM0->M0_CODIGO}) <> 0 .and.;
					Ascan(aAux,		{ |x| RIGHT(x,2)== SM0->M0_CODFIL}) <> 0 .and.;
					Ascan(aRecnoSM0,{ |x| x[2] 		== SM0->M0_CODIGO}) == 0
				
				Aadd(aRecnoSM0,{SM0->(Recno()),SM0->M0_CODIGO})
			EndIf
		EndIf
		SM0->(dbSkip())
	EndDo
	RpcClearEnv()

	If lOpen := MyOpenSm0Ex()
		For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
			lMsFinalAuto := .F.
			
			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

			cTexto += If(lCheck8 , " - .T. - ", " - .F. -")+" Gerar Arq Sigamat com empresas."+CHR(13)+CHR(10)
			cTexto += If(lCheck2 , " - .T. - ", " - .F. -")+" Copia arquivos pasta system."+CHR(13)+CHR(10)
			cTexto += If(lCheck10, " - .T. - ", " - .F. -")+" Converte DBF para Ctree."+CHR(13)+CHR(10)
			cTexto += If(lCheck3 , " - .T. - ", " - .F. -")+" Download da Base de dados."+CHR(13)+CHR(10)
			cTexto += If(lCheck4 , " - .T. - ", " - .F. -")+" Download de tabelas YY."+CHR(13)+CHR(10)
			cTexto += If(lCheck5 , " - .T. - ", " - .F. -")+" Download das tabelas SPED."+CHR(13)+CHR(10)
			cTexto += If(lCheck6 , " - .T. - ", " - .F. -")+" Download das tabelas RC e RI."+CHR(13)+CHR(10)
			cTexto += If(lCheck7 , " - .T. - ", " - .F. -")+" Deletar Emp do Sigamat."+CHR(13)+CHR(10)
			cTexto += If(lCheck11, " - .T. - ", " - .F. -")+" Ajustar DBF para migracao."+CHR(13)+CHR(10)
		
			//Função principal da migração.
			cTexto+= MAIN_MIG() 
			//Erro ao criar diretorio ou copiar os dicionarios
			If (Select("SX3") <= 0)
				If !( lOpen := MyOpenSm0Ex() )
					Exit 
				EndIf
				Loop
			Else
				
				If lCheck3
					//Download Base
					cTexto += ExportTb(1)
				EndIF
				
				If lCheck6
					//Download RC
				    cTexto += ExportTb(2)
				    //Download RI
				    cTexto += ExportTb(3)
				EndIf
	
				/*If lCheck5 //.and. ALLTRIM(cUserLog) $ ADMIN
					cTexto += SPED(cGetSPED,SM0->M0_CODIGO, SM0->M0_FILIAL)
				EndIf*/
			    
				//Gera arquivo com o Sigamat selecionado
				If lCheck8 .and. !FILE("\migracao\SIGAMAT.EMP")
					GERASIGAMAT(aRecnoSM0)
				EndIf
	            
	            //Deleta empresa do Sigamat na system
				If lCheck7
					cEmpAtu := SM0->M0_CODIGO
					While cEmpAtu == SM0->M0_CODIGO
						SM0->(RecLock("SM0",.F.))
						SM0->(DBDelete())
						SM0->(MsUnlock())
						SM0->(DBSkip())
					EndDo
					
				EndIF
				
				If lCheck9
					aAdd(aEmps, SM0->M0_CODIGO)
				EndIf
	
				RpcClearEnv()
				If !( lOpen := MyOpenSm0Ex() )
					Exit 
				EndIf
			EndIf
		Next nI

		//Validação para que aguarde terminar todos os Jobs.
		nCount := 2
		nTime  := 200
		While nCount >= 1
			aThread := GetUserInfoArray()
			nCount := 0
			For i := 1 to len(aThread)
				If (nPOs := aScan(aThread, {|x| RIGHT(ALLTRIM(x[1]),1) == "_" })) <> 0
					nCount++
				EndIf            	
			Next i
		    Sleep(nTime)//Para não ficar um processamento muito alto.
			If nTime <= 3000
				nTime := nTime + 100
			EndIf
		EndDo
	EndIf

	//Apresenta o LOG na tela.
	If lOpen
		cTexto := "Log da geração dos arquivos para migração. "+CHR(13)+CHR(10)+cTexto
		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
		
		Define FONT oFont NAME "Mono AS" Size 5,12
		Define MsDialog oDlg Title "Log do processamento" From 3,0 to 340,417 Pixel

		@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont

		Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel
		Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		Activate MsDialog oDlg Center
	 EndIf
EndIf

MSQUIT()

Return .F.

/*
Funcao      : ExportTb
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Exporta os Arquivos/Registros Marcados
Autor       : Renato Rezende
Data/Hora   : 
*/
*-------------------------------*
 Static Function ExportTb(nOpc)
*-------------------------------*
Local cLog 		:= ""
Local cQuery	:= ""
Local cPatch	:= ""
Local cWAlias	:= ""

Local nCount 	:= 0
Local nTime  	:= 0
Local nPOs		:= 0

Local aThread	:= {}

cPath := "\MIGRACAO\"+SM0->M0_CODIGO+"\DADOS\"

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

If nOpc == 1 
	//cQuery:= "SELECT distinct SubString(name,1,6) AS TABELA FROM sysobjects WHERE SubString(NAME,4,3) = '"+SM0->M0_CODIGO+"0' AND Len(NAME)=6"
	BuscaSX2()
ElseIf nOpc == 2
	cQuery:= "SELECT distinct SubString(name,1,8) AS TABELA FROM sysobjects WHERE SubString(NAME,1,4) = 'RC"+SM0->M0_CODIGO+"' AND Len(NAME)=8"
ElseIf nOpc == 3
	cQuery:= "SELECT distinct SubString(name,1,8) AS TABELA FROM sysobjects WHERE SubString(NAME,1,4) = 'RI"+SM0->M0_CODIGO+"' AND Len(NAME)=8"
EndIf

If nOpc <> 1
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
EndIf

//Verifica quantos registros retornaram na consulta
Count to nRecCount

QRY->(DbGoTop())

If nRecCount > 0 
	If nOpc == 1 
		cLog:= "- Download da Base Concluido."+CHR(13)+CHR(10)
	ElseIf nOpc == 2
		cLog:= "- Download da Base RC Concluido."+CHR(13)+CHR(10)
	ElseIf nOpc == 3
		cLog:= "- Download da Base RI Concluido."+CHR(13)+CHR(10)
	EndIf
	While QRY->(!Eof())
			If TCCANOPEN(QRY->TABELA) // É UM ARQUIVO DO SQL
				nCount := VAL(cGet1) + 10
				nTime  := 100
				If nOpc == 1
					cWAlias:= SubStr(QRY->TABELA,1,3)//Alias
				Else
					cWAlias:= Alltrim(QRY->TABELA)//Alias
				EndIf
				While nCount >= VAL(cGet1)
					aThread := GetUserInfoArray()
					nCount := 0
					For i := 1 to len(aThread)
						If (nPOs := aScan(aThread, {|x| RIGHT(ALLTRIM(x[1]),1) == "_" })) <> 0
							nCount++
						EndIf            	
					Next i
					If nCount >= VAL(cGet1) .and. nTime <= 2000
						Sleep(nTime)//Para não ficar um processamento muito alto.
						nTime := nTime + 100
					EndIf
				EndDo
				//Baixar Base
				StartJob( "U_GTMIGCPY        _"+QRY->TABELA , GetEnvServer() , .F., QRY->TABELA,cPath,cWAlias,cEmpAnt,cFilAnt,aSX3,lCheck11)
            EndIf
		QRY->(DbSkip())
	EndDo
Else
	If nOpc == 1 
		cLog:= "- Download da Base Não Possui Dados."+CHR(13)+CHR(10)
	ElseIf nOpc == 2
		cLog:= "- Download da Base RC Não Possui Dados."+CHR(13)+CHR(10)
	ElseIf nOpc == 3
		cLog:= "- Download da Base RI Não Possui Dados."+CHR(13)+CHR(10)
	EndIf
EndIf

Return cLog

/*
Funcao      : MAIN_MIG
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função principal para execução da migração.
Autor       : Renato Rezende
*/
*---------------------------*
 Static Function MAIN_MIG()
*---------------------------*
Local cLog := ""
Local cRet := ""
	//Carrega Regua Processamento
	ProcRegua(6)
	//tratamento para pasta de migração;
	IncProc("Aguarde...")
	cLog += cRet := DIR_MIG()
	If LEFT(cRet,4) == "ERRO"
		RpcClearEnv()
		Return cLog
	EndIf

	If lCHeck2
		//Copia dos dicionarios;
		cLog += cRet := DIC_MIG(1)
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog
		EndIf
		//Acertos de dicionarios definidos pelos administradores;
		If lCheck11
			IncProc("Ajustes definidos manualmente...")
			cLog += cRet := AJUSTE_M_MIG()
			If LEFT(cRet,4) == "ERRO"
				RpcClearEnv()
				Return cLog 
			EndIf
		EndIf
		//Executa o pack em todos os dicionarios.
		cLog += cRet :=	PACK_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog
		EndIf
		//Converte DBF para Ctree
		If lCHeck10
			cLog += cRet :=	CONV_MIG()
			If LEFT(cRet,4) == "ERRO"
				RpcClearEnv()
				Return cLog
			EndIf
			//Tirar da pasta os arquivos migracao\sx e jogar na pasta do ctree.
			cLog += cRet := DIC_MIG(2)
			If LEFT(cRet,4) == "ERRO"
				RpcClearEnv()
				Return cLog
			EndIf
		EndIf
		//Apagar os arquivos CDX. utilizados...
		cLog += cRet := DELCDX_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog
		EndIf
	EndIf

Return cLog

/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 exclusivo
Autor       : Renato Rezende
Data/Hora   : 
*/
*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Abre Compartilhado.
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

	If !lOpen
		Aviso( "Atencao", "Nao foi possível a abertura de empresas de forma exclusiva.", { "Ok" }, 2 )
	EndIf
End Sequence

Return(lOpen)

/*
Funcao      : Tela
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para seleção das empresas e os procedimentos.
Autor       : Renato Rezende
Data/Hora   : 
*/
*------------------------*
 Static Function Tela()
*------------------------*
Local lRet 			:= .F.
Private cAliasWork	:= "Work"
Private cMarca 		:= ""
Private aCpos :=  {	{"MARCA"	,,""} ,;
					{"M0_CODIGO",,"Cod.Empresa"	},;
					{"M0_CODFIL",,"Filial" 		},;
		   			{"M0_NOME"	,,"Nome Empresa"}}
		   				
Private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"M0_CODIGO","C",2 ,0},;
						{"M0_CODFIL","C",2 ,0},;
		   				{"M0_NOME"	,"C",30,0}}

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf     

dbSelectArea("SM0")
SM0->(DbGoTop())
While SM0->(!EOF()) .AND. SM0->(DELETED())
	SM0->(DbSkip())
EndDo
//Conecta no ambiente
RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)

//Cria area temporaria para alimentar o sigamat
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

cCodAux := ""
While SM0->(!EOF())
	If cCodAux <> SM0->M0_CODIGO
		cCodAux := SM0->M0_CODIGO
		(cAliasWork)->(RecLock(cAliasWork,.T.))
		(cAliasWork)->MARCA		:= ""
		(cAliasWork)->M0_CODIGO	:= SM0->M0_CODIGO
		(cAliasWork)->M0_CODFIL	:= SM0->M0_CODFIL
		(cAliasWork)->M0_NOME	:= SM0->M0_NOME
		(cAliasWork)->(MsUnlock())
	EndIf
	SM0->(DbSkip())
EndDo

(cAliasWork)->(DbGoTop())

cMarca := GetMark()

SetPrvt("oDlg1","oSay1","oBrw1","oCBox1","oSBtn1","oSBtn2","oCBox2","oCBox3","oCBox4","oGet1","oSay2","oCBox5","oCBox6","oCBox7","oCBox8","oCBox10","oCBox11")

oDlg1      := MSDialog():New( 091,232,411,832,"Equipe TI da HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione as empresas."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)

DbSelectArea(cAliasWork)

cGet2 := "  "
cGet3 := Space(100)

oSay9	   := TSay():New( 016,006,{|| "Buscar:"}	,oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oGet2	   := TGet():New( 015,026,{|u| IF(PCount()>0,cGet2:=u,cGet2)},oDlg1,030,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oSBtn3     := SButton():New( 014,058,1,{|| Busca() },oDlg1,,"", )

oSay10	   := TSay():New( 016,092,{|| "Incl. Rapida:"}	,oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oGet3	   := TGet():New( 015,122,{|u| IF(PCount()>0,cGet3:=u,cGet3)},oDlg1,030,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oSBtn4     := SButton():New( 014,153,1,{|| INCLRAPIDA() },oDlg1,,"", )

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{030,004,155,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.

oSay2	   := TSay():New( 020,190,{|| "Qtde de Jobs:"}	,oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oGet1	   := TGet():New( 020,230,{|u| IF(PCount()>0,cGet1:=u,cGet1)},oDlg1,030,008,"@E 99",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
//If ALLTRIM(cUserLog) $ ADMIN
	oCBox2     := TCheckBox():New( 040,190,"Copiar Infos da System."	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox3     := TCheckBox():New( 050,190,"Download da Base."		   	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox4     := TCheckBox():New( 060,190,"Download de tabelas YY."   	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox5     := TCheckBox():New( 070,190,"Download das tabelas SPED."				,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox6     := TCheckBox():New( 080,190,"Download das tabelas RC e RI."			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox7     := TCheckBox():New( 090,190,"Deletar Emp do Sigamat."	    		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox8     := TCheckBox():New( 100,190,"Gerar Arq Sigamat com empresas."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox10    := TCheckBox():New( 110,190,"Converter DBF em Ctree."	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox11    := TCheckBox():New( 120,190,"Ajustar DBF para migracao."	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
//EndIf

oSBtn1     := SButton():New( 142,226,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 142,262,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

oCBox2:bSetGet := {|| lCheck2 }
oCBox2:bLClicked := {|| lCheck2:=!lCheck2 }
oCBox2:bWhen := {|| .T. }
oCBox3:bSetGet := {|| lCheck3 }
oCBox3:bLClicked := {|| IF(lCheck3,(lCheck3:=lCheck6:=.F.),lCheck3:=.T.) }
oCBox3:bWhen := {|| .T. }
oCBox4:bSetGet := {|| lCheck4 }
oCBox4:bLClicked := {|| lCheck4:=!lCheck4 }
oCBox4:bWhen := {|| .T. }
oCBox5:bSetGet := {|| lCheck5 }
oCBox5:bLClicked := {|| lCheck5:=!lCheck5 }
oCBox5:bWhen := {|| .F. }
oCBox6:bSetGet := {|| lCheck6 }
oCBox6:bLClicked := {|| lCheck6:=!lCheck6 }
oCBox6:bWhen := {|| .T. }
oCBox7:bSetGet := {|| lCheck7 }
oCBox7:bLClicked := {|| lCheck7:=!lCheck7 }
oCBox7:bWhen := {|| .F. }
oCBox8:bSetGet := {|| lCheck8 }
oCBox8:bLClicked := {|| lCheck8:=!lCheck8 }
oCBox8:bWhen := {|| .T. }
oCBox10:bSetGet := {|| lCheck10 }
oCBox10:bLClicked := {|| IF(lCheck2,lCheck10:=!lCheck10,.F.) }//so seleciona se o download da system estiver ativo.
oCBox10:bWhen := {|| .T. }
oCBox11:bSetGet := {|| lCheck11 }
oCBox11:bLClicked := {|| IF(lCheck2,lCheck11:=!lCheck11,.F.) }//so seleciona se o download da system estiver ativo.
oCBox11:bWhen := {|| .T. }

oDlg1:Activate(,,,.T.)

Return lRet

/*
Funcao      : DIR_MIG
Retorno		: cRet
Objetivos   : Tratamento para pasta de migração;
Autor       : Renato Rezende
*/
*---------------------------*
Static Function DIR_MIG()
*---------------------------*
Local i 	:= 0
Local j 	:= 0
Local cRet 	:= ""
Local cDir 	:= ""
Local cPastaRaiz := "\MIGRACAO"
Local cPastaEmpr := "\"+SM0->M0_CODIGO
Local cPastaDado := "\Dados"
Local cPastaCtre := "\Ctree"
Local cPastaDics := "\SX"

Local aDir := {	cPastaRaiz,;//Acerto do diretorio raiz.
				cPastaEmpr,;//Diretorio da Empresa.
				{cPastaDado,;//Diretorio dos Dicionarios.
				 cPastaDics,;//Diretorio dos Dados.
				 cPastaCtre};//Diretorio dos Dados.
				}

For i:=1 to Len(aDir)
	If VALTYPE(aDir[i]) == "C"
		cDir += aDir[i]
		If !File(cDir)
			If (nErro:=MakeDir(cDir)) <> 0
				cRet += "- Não foi possivel criação do diretorio '" + cDir + "' - Erro: " + ALLTRIM(STR(nErro)) + CHR(10)+CHR(13)
				Return "ERRO" + cRet
			EndIf
			cRet += "- Diretorio '"+cDir+"' criado com sucesso!"+CHR(13)+CHR(10)
		EndIf
	ElseIf ValType(aDir[i]) == "A"
		For j:=1 to Len(aDir[i])
			If !File(cDir+aDir[i][j])
				If (nErro:=MakeDir(cDir+aDir[i][j])) <> 0
					cRet += "- Não foi possivel criação do diretorio '" + cDir+aDir[i][j] + "' - Erro: " + ALLTRIM(STR(nErro)) + CHR(10)+CHR(13)
					Return "ERRO" + cRet
				EndIf
				cRet += "- Diretorio '"+cDir+aDir[i][j]+"' criado com sucesso!"+CHR(13)+CHR(10)
			EndIf
  		Next j
	EndIf
Next i
  
Return cRet

/*
Funcao      : GTMIGCPY
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para execução das threads de download da base de dados.
Autor       : Renato Rezende
Data/Hora   : 
*/
*--------------------------------------------------------------------------*
 User Function GTMIGCPY(cArqSQL,cPath,cWAlias,cEmp,cFilEmp,aSX3,lCheck11)
*--------------------------------------------------------------------------*
Local nQuant 	:= 0
Local cArqDBF	:= ""
Local aStru 	:= ""
Local cTabIg	:= "CUZ" //Tabelas que serão ignoradas
Local nPos		:= 0

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

//Momento que da um erro no sistema é enviado para ErrorBlock
bError := ErrorBlock( { |oError| MyError( oError ) } )
//bError := SysErrorBlock ( { |oError|  MyError( oError ) } )

// É UM ARQUIVO DO SQL
IF TCCANOPEN(cArqSQL) .AND. !cArqSQL $ cTabIg
	cArqDBF := AllTrim(cPath)+cArqSQL+".DBF"
	//Verifica se a area esta aberta
	If Select(cWAlias) > 0
		(cWAlias)->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",cArqSQL, cWAlias, .T., .T.) //Somente leitura
	
	//Copiando as tabelas para um diretório do ambiente	caso tenha registro
	count to nRecCount
	If nRecCount > 0
		BEGIN SEQUENCE
			(cWAlias)->(DbGoTop())
			//Excluir arquivo se existir
			FErase(cArqDBF)
		    //Carrega Estrutura da Area Aberta    
			aStru := dbStruct()
			
			//Compara estrutura da tabela com o grupo de campo
			//Apenas se estiver marcado para ajustar dados
			If lCheck11
				CONOUT(aSX3[1][6])
				nPos := aScan(aSx3, { |aTab| Alltrim(aTab[6]) == Alltrim(cWAlias)} )
				//Achando o campo na estrutura
				If nPos > 0
					aStru:= AjustSXG(2,aSx3,aStru,cWAlias)
				EndIf
			EndIf
				
			DbCreate(cArqDBF,aStru)     
	
			//Verifica se a area esta aberta
			If Select("XXX") > 0
				XXX->(DbCloseArea())
			EndIf
			DbUseArea(.T., "DBFCDX",cArqDBF,"XXX", .T., .F.)		
			
			MsAppEnd(cArqDBF,cWAlias)
			XXX->(DbCommit())
			//Desbloqueia todos os registros bloqueados na área de trabalho
			XXX->(DbUnlockAll())
					
			//Copy To &(cArqDBF)
		RECOVER
			(cWAlias)->(DbCloseArea())
			XXX->(DbCloseArea())
		END SEQUENCE
				
	Else
		(cWAlias)->(DbCloseArea())
	EndIf
EndIf

//Restaurando bloco de erro do sistema
ErrorBlock( bError )

RpcClearEnv()

Return nil

/*
Funcao      : MyError
Parametros  : oError
Retorno     : Nenhum
Objetivos   : Trata erro no StartJob
Autor       : Renato Rezende
*/
*--------------------------------------*
 Static Function MyError(oError)
*--------------------------------------*
Local cLog	   		:= ""
Local nHdl			:= 0
Local nBytesSalvo	:= 0
Local cArqLogEr		:= "\MIGRACAO\"+SM0->M0_CODIGO+"\ERRO_BASE_"+DtoS(dDataBase)+".txt"

//Verifica se o arquivo existe
If !File(cArqLogEr)
	nHdl		:= FCREATE(cArqLogEr,0 )  //Criação do Arquivo Log.
Else
	nHdl		:= Fopen(cArqLogEr,2) //Abre o arquivo para leitura ou gravação
EndIf

cLog:= oError:Description + " Deu Erro" + CHR(10)+CHR(13)

FSeek(nHdl,0,2)
nBytesSalvo	:= FWRITE(nHdl, cLog ) // Gravação do seu Conteudo.
Fclose(nHdl) // Fecha o Arquivo que foi Gerado

BREAK

Return NIL 

/*
Funcao      : Busca
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Posicionar na empresa informada
Autor       : Renato Rezende
*/
*--------------------------*
 Static Function Busca()
*--------------------------*
Local aOrd := {}

aOrd := SaveOrd(cAliasWork)

If !Empty(cGet2)
	(cAliasWork)->(DBGOTOP())
	While (cAliasWork)->(!EOF())
		If (cAliasWork)->M0_CODIGO == cGet2
			cGet2 := "  "
			Return .T.
		EndIf
		(cAliasWork)->(DBSkip())
	EndDo
EndIf
RestOrd(aOrd)

Return .T.

/*
Funcao      : INCLRAPIDA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Seleção rapida das empresas, separados por |.
Autor       : Renato Rezende
*/
*-----------------------------*
 Static Function INCLRAPIDA()
*-----------------------------*
Local i
Local cMsg := ""
Local aEmp	:= {}
Local aEmpEnc	:= {}
Local cDelimitador := " "


Do Case
	Case AT("|",cGet3)  <> 0
		cDelimitador := "|"
	Case AT("\",cGet3)  <> 0
		cDelimitador := "\"
	Case AT("/",cGet3)  <> 0
		cDelimitador := "/" 
	Case AT(";",cGet3)  <> 0
		cDelimitador := ";"
EndCase

If !EMPTY(cGet3)
	cGet3 := ALLTRIM(cGet3)
	While !EMPTY(cGet3)
		cAux := SUBSTR(cGet3,1,AT(cDelimitador,cGet3)-1)
		If EMPTY(cAux)
			cAux := cGet3
			cGet3:= Space(100)
		Else
			cGet3:= SUBSTR(cGet3,AT(cDelimitador,cGet3)+1,LEN(cGet3))
		EndIf
		aAdd(aEmp, cAux)
	EndDo

	cMsg := "Empresas que serão selecionadas:"+CHR(13)+CHR(10)
	For i:=1 to Len(aEmp)
		(cAliasWork)->(DBGOTOP())
		While (cAliasWork)->(!EOF())
			If (cAliasWork)->M0_CODIGO == aEmp[i]
				cMsg += (cAliasWork)->M0_CODIGO + " - " + (cAliasWork)->M0_NOME+CHR(13)+CHR(10)
				aAdd(aEmpEnc , {(cAliasWork)->M0_CODIGO,(cAliasWork)->M0_NOME,(cAliasWork)->(RECNO())})
				Exit
			EndIf
			(cAliasWork)->(DBSkip())
		EndDo
	Next i
	
	If MSGYESNO(cMsg)
		For i:=1 to Len(aEmpEnc)
			(cAliasWork)->(DBGOTO(aEmpEnc[i][3]))
			(cAliasWork)->MARCA := "  "
			cMark()
		Next i
	EndIf
	
EndIf
(cAliasWork)->(DBGOTOP())

Return .T.

/*
Funcao      : cMark
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : cMark para tela.
*/
*-------------------------*
 Static Function cMark()
*-------------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))

RecLock(cAliasWork, .F.)
If lDesmarca
   (cAliasWork)->MARCA := "  "
Else
   (cAliasWork)->MARCA := cMarca
Endif
(cAliasWork)->(MsUnlock())

Return

/*
Funcao      : GERASIGAMAT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Geração do Arquivo SIGAMAT.
Autor       : Renato Rezende
*/
*--------------------------------*
Static Function GERASIGAMAT(aRecs)
*--------------------------------*
Local cEmps := ""
__CopyFile( "\SYSTEM\SIGAMAT.EMP", "\migracao\SIGAMAT.EMP" )
__CopyFile( "\SYSTEM\SIGAMAT.IND", "\migracao\SIGAMAT.IND" )


dbUseArea( .T.,"dbfcdxads", "\migracao\SIGAMAT.EMP","SM0MIG", .F., .F. )//exclusivo
DBSETINDEX("\migracao\SIGAMAT.IND")

For i:=1 to Len(aRecs)
	cEmps += aRecs[i][2] + "|"
Next i

//Tira as empresas não selecionadas do sigamat
SM0MIG->(DbGoTop())
While SM0MIG->(!EOF())
    SM0MIG->(RECNO())
    If aScan(aRecs, {|x| x[1] == SM0MIG->(RECNO())}) == 0 .and. !(SM0MIG->M0_CODIGO $ cEmps)
		SM0MIG->(RecLock("SM0MIG",.F.))
		SM0MIG->(DbDelete())
		SM0MIG->(MsUnlock())
    EndIf
	SM0MIG->(DbSkip())
EndDo
SM0MIG->(__DBPACK())//Retirando as deletadas
SM0MIG->(dbCloseArea()) 
FERASE("\migracao\SIGAMAT.IND")

Return .T.

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna os dados para a Tela
*/
*------------------------*
 Static Function Dados()
*------------------------*
dbSelectArea(cAliasWork)
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If (cAliasWork)->MARCA <> " "
		aAdd(aAux, (cAliasWork)->M0_CODIGO+(cAliasWork)->M0_CODFIL)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo
Return .T.

/*
Funcao      : DIC_MIG
Retorno     : cRet
Objetivos   : Copia dos dicionarios;
Autor       : Renato Rezende
Data/Hora   : 
*/
*-------------------------------*
 Static Function DIC_MIG(nSeq)
*-------------------------------*
Local i
local cRet := ""

//Download SX
If nSeq == 1
	aArq := Directory("\System\*.*")
//Transformado dbf em Ctree
ElseIf nSeq == 2 
	aArq := Directory("\migracao\"+SM0->M0_CODIGO+"\sx\*.*")
EndIf
For i:=1 to len(aArq)

	If nSeq == 1
		If	(UPPER(LEFT(aArq[i][1],2)) 		== "SX"   	.and.;
			UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.DBF"));//Copia dos Dicionarios, arquivos DBF.
			.or.;
			(UPPER(LEFT(aArq[i][1],2)) 		== "SX"   	.and.;
			UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.CDX"));//Copia dos Dicionarios, arquivos CDX.
			.or.;
			(UPPER(LEFT(aArq[i][1],3)) 		== "SIX"   	.and.;
			UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.DBF"));//Copia dos indices, arquivos DBF.
			.or.;
			(UPPER(LEFT(aArq[i][1],3)) 		== "SIX"   	.and.;
			UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.CDX"));//Apenas para ser utilizado no tratamento de ajustes.
			.or.;
			(UPPER(Substr(aArq[i][1],4,2))	== UPPER(SM0->M0_CODIGO) .and.;
			UPPER(RIGHT(aArq[i][1],4)) 		== ".FPT"					   );//Copia dos arquivos FPT, arquivos DBF.
			.or.;
			(UPPER(LEFT(aArq[i][1],2)) 		== "XX"   	.and.;
			UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.DBF"));//Copia dos Dicionarios XX, arquivos DBF.

			//Copia do arquivo para pasta migracao
			__CopyFile( "\SYSTEM\"+aArq[i][1], "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1] )

		EndIf
	EndIf
	
	If (UPPER(Substr(aArq[i][1],5,2)+Substr(aArq[i][1],9,4))	== UPPER(SM0->M0_CODIGO+".IC0"));//Copia dos arquivos de ICMS.
		.or.;
		(UPPER(Substr(aArq[i][1],5,2)+Substr(aArq[i][1],9,4))	== UPPER(SM0->M0_CODIGO+".IP0"));//Copia dos arquivos de IPI.
		.or.;
		(UPPER(Substr(aArq[i][1],5,2)+Substr(aArq[i][1],9,4))	== UPPER(SM0->M0_CODIGO+".ST0"));//Copia dos arquivos de ICMS ST.
		.or.;
		(UPPER(Substr(aArq[i][1],5,2)+Substr(aArq[i][1],9,4))	== UPPER(SM0->M0_CODIGO+".PS0"));//Copia dos arquivos de PIS.
		.or.;
		(UPPER(Substr(aArq[i][1],5,2)+Substr(aArq[i][1],9,4))	== UPPER(SM0->M0_CODIGO+".CF0"));//Copia dos arquivos de COFINS.
		.or.;
		(UPPER(aArq[i][1]) 				== UPPER("LGRL"+SM0->M0_CODIGO+".BMP"));//Copia Logo da empresa.
		
		If nSeq == 1
			__CopyFile( "\SYSTEM\"+aArq[i][1], "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1] )
			//cRet += "- Copiado arquivo '"+aArq[i][1]+"'!"+CHR(13)+CHR(10)
		ElseIf nSeq == 2
			__CopyFile( "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1], "\migracao\"+SM0->M0_CODIGO+"\Ctree\"+aArq[i][1] )
		EndIf
	EndIf
Next i

cRet := "- Todos arquivos copiados para a pasta Sx."+CHR(13)+CHR(10)

If nSeq == 1
	cRet := "- Todos arquivos copiados para a pasta Sx."+CHR(13)+CHR(10)
ElseIf nSeq == 2
	cRet := "- Todos arquivos copiados para a pasta Ctree."+CHR(13)+CHR(10)
EndIf

Return cRet

/*
Funcao      : DELCDX_MIG
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Apagar os arquivos CDX.
Autor       : Renato Rezende
Data/Hora   : 
*/
*----------------------------*
Static Function DELCDX_MIG()
*----------------------------*
Local i
Local cRet := ""
Local aArq := {}

aArq := Directory("\migracao\"+SM0->M0_CODIGO+"\sx\*.cdx")
For i:=1 to len(aArq)
	FERASE( "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1])
Next i 
cRet := "- Apagado todos CDX da pasta de Sx."+CHR(10)+CHR(13)

Return cRet

/*
Funcao      : PACK_MIG
Retorno     : cRet
Objetivos   : Executa Pack nos dicionarios.
Autor       : Renato Rezende
*/
*----------------------------*
 Static Function PACK_MIG()
*----------------------------*
Local cRet := ""

//Executa o Pack em todos os dicionarios.
aArq := Directory("\migracao\"+SM0->M0_CODIGO+"\sx\*"+SM0->M0_CODIGO+"0.dbf")
For i:=1 to len(aArq)
	dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1],"XXX", .F., .F. )//exclusivo 
	XXX->(__DBPACK())
	XXX->(dbCloseArea())
	//cRet += "- Pack executado '"+ALLTRIM(aArq[i][1])+"'."+CHR(10)+CHR(13)
Next i

cRet := "- Pack executado em todos DBF da pasta Sx."+CHR(10)+CHR(13)

Return cRet

/*
Funcao      : CONV_MIG
Retorno     : cRet
Objetivos   : Converte DBF para Ctree
Autor       : Renato Rezende
*/
*----------------------------*
 Static Function CONV_MIG()
*----------------------------*
Local cRet 		:= ""
Local cDestino	:= "\migracao\"+SM0->M0_CODIGO+"\Ctree\"
Local cArqDTC	:= ""
Local cDirLocal	:= ""
Local aArq		:= {}
Local i			:= 0

If Select("XXX") > 0
	XXX->(DbCloseArea())
EndIf

//Converte os dicionários DBFs para Ctree
aArq := Directory("\migracao\"+SM0->M0_CODIGO+"\sx\*"+SM0->M0_CODIGO+"0.dbf")
For i:=1 to len(aArq)
	dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1],"XXX", .F., .F. )//exclusivo

	DbSelectArea("XXX")
	cArqDTC	:= cDestino+Substr(aArq[i][1],1,At(".",aArq[i][1])-1)+".dtc "
	
	//Convertendo o DBF para Ctree e enviando para o diretório Ctree
	FErase(cArqDTC)//Excluir arquivo
	Copy To &(cArqDTC) Via  "CTREECDX"

	XXX->(DbCloseArea())

Next i

//Apagando pasta ctree
DirRemove(cDestino+"ctreeint\")

cRet := "- Todos DBF da pasta Sx foram convertido para Ctree."+CHR(10)+CHR(13)

Return cRet

/*
Funcao      : BuscaSX2
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta o arquivo das tabelas que serão baixadas
Autor       : Renato Rezende
*/
*---------------------------*
 Static Function BuscaSX2()   
*---------------------------*
Local aTMPSTRU	:= {}
Local cArq		:= ""

DbSelectArea("SX2")
SX2->(DbClearFilter(NIL))
SX2->(DbSetOrder(1))
SX2->(DbGoTop())

aTMPSTRU := {}
AADD(aTMPSTRU,{ "X2_CHAVE"   	,"C",03,0})
AADD(aTMPSTRU,{ "TABELA"  		,"C",06,0})
AADD(aTMPSTRU,{ "X2_NOME"    	,"C",30,0})

cArq := Criatrab(aTMPSTRU,.T.)
dbUseArea( .T.,,cArq, "QRY", .T., .F. )

While SX2->(!EOF())
	If (SM0->M0_CODIGO == "YY" .or. lCheck4 .or. !("YY0" $ SX2->X2_ARQUIVO))// .AND. ("CVDYY0" == ALLTRIM(SX2->X2_ARQUIVO)) //.AND.  ("CUZXR0" == ALLTRIM(SX2->X2_ARQUIVO))
		RecLock("QRY",.T.)
			QRY->X2_CHAVE	:= SX2->X2_CHAVE
			QRY->TABELA		:= SX2->X2_ARQUIVO
			QRY->X2_NOME	:= SX2->X2_NOME
		QRY->(DbCommit())
		QRY->(DbUnlock())
	Endif
	SX2->(DbSkip())
EndDo

DbSelectArea("QRY")
QRY->(DbGoTop())

Return nil

/*
Funcao      : AJUSTE_M_MIG
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Acertos de dicionarios definidos pelos administradores;
Autor       : Renato Rezende
*/
*-------------------------------*
 Static Function AJUSTE_M_MIG()
*-------------------------------*
local cRet		:= ""
Local cChaveAnt	:= "" 
Local aSx1		:= {}
Local aSx6		:= {}
Local aAux		:= {} 
Local aSx7		:= {}
Local aSIX		:= {}
Local aChave	:= {}

//Acerto do SX3

dbUseArea( .T.,, "\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.dbf","SX3MIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.cdx")
SX3MIG->(DbGoTop())
SX3MIG->(DbSetOrder(2))
		//CAMPO			,GRUPO	 ,TAMANHO ,PICTURE					,ORDEM	 ,TABELA
aSx3 := {{"CKY_DTEMIS"	,""		 ,"MANTEM","MANTEM"  				,"MANTEM","CKY"},;
		 {"CLY_GRUPO"	,""		 ,"MANTEM","MANTEM"	 				,"MANTEM","CLY"},;
		 {"F02_VLTOTN"	,""		 ,"MANTEM","MANTEM"	 				,"MANTEM","F02"},;
		 {"F02_VLDEDU"	,""		 ,"MANTEM","MANTEM"	 				,"MANTEM","F02"},;
		 {"F0M_CONTA"	,"003"	 ,"MANTEM","MANTEM"	  				,"MANTEM","F0M"},;
		 {"FIF_PARCEL"	,"MANTEM","SXG"	  ,"MANTEM"	  				,"MANTEM","FIF"},;
		 {"EJZ_REGIST"	,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","EJZ"},;
		 {"ELB_TPPROC"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","ELB"},;
		 {"TJG_LAUDO"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","TJG"},;
		 {"TJG_CODPLA"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","TJG"},;
		 {"UI_DESC"		,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","SUI"},;
		 {"UJ_DESC"		,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","SUJ"},;
		 {"Z3_FILIAL"	,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","SZ3"},;
		 {"Z3_CODIGO"	,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","SZ3"},;
		 {"Z4_FILIAL"	,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","SZ4"},;
		 {"Z4_TES"		,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","SZ4"},;
		 {"Z5_CODE"		,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZ5"},;
		 {"Z6_CODE"		,"MANTEM","MANTEM","MANTEM"					,"MANTEM","SZ6"},;
		 {"Z7_FILIAL"	,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","SZ7"},;
		 {"Z7_CODE"		,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZ7"},;
		 {"Z7_ANO"		,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZ7"},;
		 {"Z8_FILIAL"	,"MANTEM","MANTEM","MANTEM"	  				,"MANTEM","SZ8"},;
		 {"Z8_CODE"		,"MANTEM","MANTEM","MANTEM"					,"MANTEM","SZ8"},;
		 {"Z8_ANO"		,"MANTEM","MANTEM","MANTEM"					,"MANTEM","SZ8"},;
		 {"ZA_FILIAL"	,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZA"},;
		 {"ZA_NUM"		,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZA"},;
		 {"ZA_ITEM"		,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZA"},;
		 {"ZA_SQUEN"	,"MANTEM","MANTEM","MANTEM"	 				,"MANTEM","SZA"},;
		 {"ZB_FILIAL"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","SZB"},;
		 {"ZB_OP"	 	,"MANTEM","MANTEM","MANTEM"					,"MANTEM","SZB"},;
		 {"FRF_FILIAL"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"FRF_BRANCO"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"FRF_AGENCI"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"FRF_CONTA"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"FRF_PREFIX"	,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"FRF_NUM"		,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"FRF_SEQ"		,"MANTEM","MANTEM","MANTEM"	   				,"MANTEM","FRF"},;
		 {"CL1_CODCTA"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CL1"},;
		 {"CL2_CTA"		,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CL2"},;
		 {"CL4_CODCTA"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CL4"},;
		 {"CL6_CONTA"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CL6"},;
		 {"F0M_CONTA"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","F0M"},;
		 {"CL7_CODCTA"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CL7"},;
		 {"CVD_CTAREF"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CVD"},;
		 {"CL2_CCUS"	,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","CL2"},;
		 {"EJW_TPPROC"	,""		 ,"MANTEM","MANTEM"					,"MANTEM","EJW"},;
		 {"ED_CCD"		,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","SED"},;
		 {"ED_CCC"		,"MANTEM","SXG"	  ,"MANTEM"					,"MANTEM","SED"},;
		 {"EA_ORIGEM"	,"DELETA","MANTEM","MANTEM"					,"MANTEM","SEA"}}

For i:=1 to Len(aSx3)
	If SX3MIG->(DbSeek(PadR(aSx3[i][1],10)))
		SX3MIG->(RecLock("SX3MIG", .F.))
			If aSx3[i][2]<>"DELETA"
				SX3MIG->X3_GRPSXG 	:= IIF(aSx3[i][2]=="MANTEM",SX3MIG->X3_GRPSXG,aSx3[i][2])
				//Ajuste diversos no tamanho do campo conforme array
				If aSx3[i][3]=="MANTEM"
					SX3MIG->X3_TAMANHO	:= SX3MIG->X3_TAMANHO
				ElseIf aSx3[i][3]=="SXG"
			   		SX3MIG->X3_TAMANHO	:= AjustSXG(1,aSx3[i])
				Else
			   		SX3MIG->X3_TAMANHO	:= Val(aSx3[i][3])
				EndIf 
				
				SX3MIG->X3_PICTURE	:= IIF(aSx3[i][4]=="MANTEM",SX3MIG->X3_PICTURE,aSx3[i][4])
				SX3MIG->X3_ORDEM	:= IIF(aSx3[i][5]=="MANTEM",IIF(Empty(SX3MIG->X3_ORDEM),GetOrdem(aSx3[i][6]),SX3MIG->X3_ORDEM),SX3MIG->X3_ORDEM)
			Else
				SX3MIG->(DbDelete())	
			EndIf
		SX3MIG->(MsUnlock())
		cRet += "- SX3 Ajustado - '"+aSx3[i][1]+"'."+CHR(10)+CHR(13)
	Else
		//Procurar campo que não existe e se existe chave.
		Aadd(aSIX,aSx3[i][1]) 
	EndIf
Next i 
SX3MIG->(dbCloseArea())

//Acerto do SX7, gatilho duplicado.
aSx7:= {"B1_POSIPI"}
dbUseArea( .T.,, "\migracao\"+SM0->M0_CODIGO+"\sx\SX7"+SM0->M0_CODIGO+"0.dbf","SX7MIG", .F., .F. )//exclusivo
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX7"+SM0->M0_CODIGO+"0.cdx")
SX7MIG->(DbGoTop())
For i:=1 to len(aSx7)
	If SX7MIG->(DbSeek(aSx7[i]))
		aAux:={}
		While SX7MIG->(!EOF()) .and. ALLTRIM(SX7MIG->X7_CAMPO) == aSx7[i]
			If Ascan(aAux,{ |x| ALLTRIM(x) == ALLTRIM(SX7MIG->X7_REGRA)}) == 0
				aAdd(aAux,SX7MIG->X7_REGRA)
			Else
				cRet += "- SX7 deletado '"+ALLTRIM(SX7MIG->X7_CAMPO + " - " + SX7MIG->X7_REGRA)+"'."+CHR(10)+CHR(13)
				RecLock("SX7MIG", .F.)
		    	SX7MIG->(DbDelete())
		    	SX7MIG->(MsUnlock())
			EndIf
			SX7MIG->(DbSkip())
		EndDo	
	EndIf
Next i
SX7MIG->(dbCloseArea())

//Tratamento para o Dicionario SIX.
dbUseArea( .T.,, "\migracao\"+SM0->M0_CODIGO+"\sx\SIX"+SM0->M0_CODIGO+"0.dbf","SIXMIG", .F., .F. )//exclusivo
ORDCREATE("\migracao\"+SM0->M0_CODIGO+"\sx\SIX"+SM0->M0_CODIGO+"1.cdx",, "CHAVE", {|| CHAVE })
SIXMIG->(DbGoTop())
While SIXMIG->(!EOF())
	//Valida se existe indice com campo não encontrado na validação do SX3 acima
	aChave:= {}
	aChave:= Separa(UPPER(STRTRAN(SIXMIG->CHAVE," ")),"+",.F.)
	For nR:= 1 to Len(aChave)
		If ( nPos := Ascan( aSIX , { | x | x == aChave[ nR ] } ) ) > 0 
			cRet += "- Del indice '"+ALLTRIM(SIXMIG->CHAVE)+"'."+CHR(10)+CHR(13)
			RecLock("SIXMIG", .F.)
				SIXMIG->(DbDelete())
			SIXMIG->(MsUnlock()) 	
		EndIf
	Next nR
    
	//Deletar indice duplicado
	If STRTRAN(SIXMIG->CHAVE," ") == STRTRAN(cChaveAnt," ")
		cRet += "- Del indice '"+ALLTRIM(SIXMIG->CHAVE)+"'."+CHR(10)+CHR(13)
		RecLock("SIXMIG", .F.)
			SIXMIG->(DbDelete())
		SIXMIG->(MsUnlock())
	EndIf
	cChaveAnt := SIXMIG->CHAVE
	SIXMIG->(DbSkip())
EndDo
SIXMIG->(dbCloseArea()) 

//Acerto Tamanho do SX1
aSx1:= {{"AFI381    03", 2 },{"AFI381    04", 2 },{"AFI381    10", 2 }}

dbUseArea( .T.,, "\migracao\"+SM0->M0_CODIGO+"\sx\SX1"+SM0->M0_CODIGO+"0.dbf","SX1MIG", .F., .F. )//exclusivo
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX1"+SM0->M0_CODIGO+"0.cdx")
SX1MIG->(DbGoTop())
For i:=1 to len(aSx1)
	If SX1MIG->(DbSeek(aSx1[i][1]))
		cRet += "- SX1 Alterado - '"+aSx1[i][1]+"'."+CHR(10)+CHR(13)
		RecLock("SX1MIG", .F.)
			SX1MIG->X1_TAMANHO := aSx1[i][2]
		SX1MIG->(MsUnlock())
	EndIf
Next i
SX1MIG->(dbCloseArea())

//Acerto SX6
aSx6:= {{"MV_TTS", "S" }}

dbUseArea( .T.,, "\migracao\"+SM0->M0_CODIGO+"\sx\SX6"+SM0->M0_CODIGO+"0.dbf","SX6MIG", .F., .F. )//exclusivo
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX6"+SM0->M0_CODIGO+"0.cdx")
SX6MIG->(DbGoTop())
For i:=1 to len(aSx6)
	If SX6MIG->(DbSeek(xFilial("SX6")+aSx6[i][1]))
		cRet += "- SX6 Alterado - '"+aSx6[i][1]+"'."+CHR(10)+CHR(13)
		RecLock("SX6MIG", .F.)
			SX6MIG->X6_CONTEUD := aSx6[i][2]
		SX6MIG->(MsUnlock())
	EndIf
Next i
SX6MIG->(dbCloseArea())

Return cRet

/*
Funcao      : GetOrdem
Parametros  : cTabela
Retorno     : cOrdem
Objetivos   : Pega a próxima ordem no SX3 do campo no dicionário
Autor       : Renato Rezende
*/
*-----------------------------------*
 Static Function GetOrdem(cTabela)
*-----------------------------------* 
Local cOrdem 	:= ""
Local aArea 	:= GetArea()
Local aAreaX3 	:= SX3->(GetArea())


SX3->(DbSetOrder(1)) 
//Se conseguir posicionar na tabela
If SX3->(DBSeek(cTabela))
	//Enquanto houver registros e for a mesma tabela
	While !SX3->(EoF()) .AND. SX3->X3_ARQUIVO == cTabela
		cOrdem := SX3->X3_ORDEM
		SX3->(DBSkip())
	EndDo
Else
	cOrdem := "00"
EndIf
cOrdem := Soma1(cOrdem)

RestArea(aAreaX3)
RestArea(aArea)

Return cOrdem

/*
Funcao      : AjustSXG
Parametros  : nSeq,aSx3,aStruct,cTabel aAjustSXG(2,aSx3,aStru,cWAlias)
Retorno     : aStruct
Objetivos   : Ajusta estrutura da tabela que será criada
Autor       : Renato Rezende
*/
*------------------------------------------------------*
 Static Function AjustSXG(nSeq,aSx3,aStruct,cTabela)
*------------------------------------------------------* 
Local aArea 	:= GetArea()
Local aAreaX3 	:= SX3->(GetArea())
Local aAreaXG 	:= SXG->(GetArea())
Local nPos		:= 0
Local nRet		:= 0

If nSeq == 1
	DbSelectArea("SXG")
	SXG->(DbSetOrder(1))//XG_GRUPO
	
	SX3->(DbSetOrder(2))//X3_CAMPO
	SX3->(DbGotop())
	
	//Teoricamente sempre conseguirá posicionar no campo
	If SX3->(DbSeek(aSX3[1]))
		If SX3->X3_GRPSXG <> '' 
		
			//Se conseguir posicionar no grupo de campso
			SXG->(DbGoTop())
			If SXG->(DbSeek(SX3->X3_GRPSXG))
					//Verificando se é igual ou diferente
					If SXG->XG_SIZE <> SX3->X3_TAMANHO
						nRet:= SXG->XG_SIZE
						conout("SEQ 1 CAMPO ALTERADO: "+aSX3[1])
					Else
			    		//SXG não é diferente do SX3
			    		nRet:= SX3->X3_TAMANHO
			    		conout("SEQ 1 Entrou SXG mas não alterou: "+aSX3[1])							
					EndIf
    		Else
	    		//Não posicionou no SXG
	    		nRet:= SX3->X3_TAMANHO
	    		conout("SEQ 1 Entrou SXG mas não alterou: "+aSX3[1])
    		EndIf
    	Else
    		//SXG está em branco manter tamanho do campo
    		nRet:= SX3->X3_TAMANHO
    		conout("SEQ 1 Entrou SXG mas não alterou: "+aSX3[1])	
    	EndIf
	EndIf

	RestArea(aAreaX3)
	RestArea(aAreaXG)
	RestArea(aArea)

	//Return chamado na Sequencia 1. Ajuste do SX3    
	Return nRet

ElseIf nSeq == 2
	DbSelectArea("SXG")
	SXG->(DbSetOrder(1))//XG_GRUPO
	
	SX3->(DbSetOrder(2))
	SX3->(DbGotop())
	

	For nR:=1 to len(aSX3)
		If aSX3[nR][3] == "SXG"
			//Se conseguir posicionar na tabela
			If SX3->(DBSeek(aSX3[nR][1]))//X3_CAMPO

				If SX3->X3_GRPSXG <> '' 
				
					//Se conseguir posicionar no grupo de campo
					SXG->(DbGoTop())
					If SXG->(DbSeek(SX3->X3_GRPSXG))
			
						//Verificando se é igual ou diferente
						If SXG->XG_SIZE <> SX3->X3_TAMANHO
					 
							nPos := aScan(aStruct,{|x| Alltrim(x[1]) == Alltrim(SX3->X3_CAMPO)})
							//Achando o campo na estrutura
							If nPos > 0
								aStruct[nPos][3]:= SXG->XG_SIZE
								conout("SEQ 2 CAMPO ALTERADO ESTRUTURA: "+aStruct[nPos][1])
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
    Next nR
	
	RestArea(aAreaX3)
	RestArea(aAreaXG)
	RestArea(aArea)
	
	Return aStruct

EndIf

RestArea(aAreaX3)
RestArea(aAreaXG)
RestArea(aArea)

Return Nil