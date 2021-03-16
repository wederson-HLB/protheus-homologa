#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"

#DEFINE ADMIN UPPER("Jean|Tiago|Matheus|Eduardo|Sayuri|Joao|Rezende|Aline|Arrais|Weden|Leonardo|Bernardes|Rodrigo|Bastos")

/*
Funcao      : UGTMIG11
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Start do Migrador para versão 11.
Autor       : Jean Victor Rocha.
Data/Hora   : 24/07/2012
*/
*----------------------*
User Function UGTMIG11()
*----------------------*

Private cUserLog := Space(40)

//Controle de acesso
If !U_Login_MIG11()[1]
	Return .F.
EndIf

//Função principal da migração.
Processa({|lEnd| MAIN()},"Processando...")

Return .F.


/*
Funcao      : MAIN
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função principal
Autor       : Jean Victor Rocha.
Data/Hora   : 24/07/2012
*/
*------------------------*
Static Function MAIN()
*------------------------*
Local cTexto	:= "" 
Local cFile 	:= ""
Local cRet		:= ""
Local cMask 	:= "Arquivos Texto (*.TXT) |*.txt|"
Local lOpen		:= .F.
Local i			:= 0
Local aRecnoSM0 := {}

Private lCheck	:= lCheck1 := lCheck2 := lCheck4 := lCheck7 := lCheck8 := lCheck9 := .F.    
Private lCheck3 := lCheck5 := lCheck6 := .F.
Private cGet1	:= "50"
Private cGetSPED:= "SPED_P10"+Space(4)
Private aAux := {}
Private aEmps:={}


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

			cTexto += If(lCheck , " - .T. - ", " - .F. -")+" Gera TXT de LPs na pasta MIGRACAO."+CHR(13)+CHR(10)
			cTexto += If(lCheck8, " - .T. - ", " - .F. -")+" Gerar Arq Sigamat com empresas."+CHR(13)+CHR(10)
			cTexto += If(lCheck9, " - .T. - ", " - .F. -")+" Gerar Relatorio de usuarios (Z05)."+CHR(13)+CHR(10)
			If ALLTRIM(cUserLog) $ ADMIN
				cTexto += If(lCheck2, " - .T. - ", " - .F. -")+" Copia arquivos pasta system."+CHR(13)+CHR(10)
				cTexto += If(lCheck3, " - .T. - ", " - .F. -")+" Download da Base de dados P10."+CHR(13)+CHR(10)
				cTexto += If(lCheck4, " - .T. - ", " - .F. -")+" Download de tabelas YY."+CHR(13)+CHR(10)
				cTexto += If(lCheck5, " - .T. - ", " - .F. -")+" Download das tabelas SPED."+CHR(13)+CHR(10)
				cTexto += If(lCheck6, " - .T. - ", " - .F. -")+" Download das tabelas RC e RI."+CHR(13)+CHR(10)
				cTexto += If(lCheck7, " - .T. - ", " - .F. -")+" Deletar Emp do Sigamat."+CHR(13)+CHR(10)
			EndIf
		
			//Função principal da migração.
			cTexto += MAIN_MIG()
			If lCheck
				BuscaLPS()
				cTexto += "- Relatorio CT5 gerado com sucesso."+CHR(13)+CHR(10)
			EndIf

			If lCheck3 .and. ALLTRIM(cUserLog) $ ADMIN
				MIG112DBF()
				cTexto += "- Download da Base Concluido."+CHR(13)+CHR(10)
			EndIF

			If lCheck5 .and. ALLTRIM(cUserLog) $ ADMIN
				cTexto += SPED(cGetSPED,SM0->M0_CODIGO, SM0->M0_FILIAL)
			EndIf
		
			If lCheck8 .and. !FILE("\migracao\SIGAMAT.EMP")
				GERASIGAMAT(aRecnoSM0)
			EndIf

			If lCheck7 .and. ALLTRIM(cUserLog) $ ADMIN
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
		Next nI

		If lCheck9
			GeraRelUser()
		EndIf

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
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0.
Autor       : Jean Victor Rocha.
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
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
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
While SM0->(!EOF()) .AND. SM0->(DELETED())
	SM0->(DbSkip())
EndDo

RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)

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

Private cMarca := GetMark()

SetPrvt("oDlg1","oSay1","oBrw1","oCBox1","oSBtn1","oSBtn2","oCBox2","oCBox3","oCBox4","oGet1","oSay2","oCBox5","oCBox6")

oDlg1      := MSDialog():New( 091,232,411,832,"Equipe TI da GRANT THORNTON BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione as empresas a serem Migradas."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
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

//oCBox1     := TCheckBox():New( 128,004,"Todas empresas.",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oSay2	   := TSay():New( 020,190,{|| "Qtde de Jobs:"}	,oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oGet1	   := TGet():New( 020,230,{|u| IF(PCount()>0,cGet1:=u,cGet1)},oDlg1,030,008,"@E 99",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
If ALLTRIM(cUserLog) $ ADMIN
	oCBox      := TCheckBox():New( 030,190,"Gera TXT de LPs na pasta MIGRACAO."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox2     := TCheckBox():New( 040,190,"Copiar Infos da System."	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox3     := TCheckBox():New( 050,190,"Download da Base P10."	   	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox4     := TCheckBox():New( 060,190,"Download de tabelas YY."   	   			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox5     := TCheckBox():New( 070,190,"Download das tabelas SPED."				,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox6     := TCheckBox():New( 080,190,"Download das tabelas RC e RI."			,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox7     := TCheckBox():New( 090,190,"Deletar Emp do Sigamat."	    		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox8     := TCheckBox():New( 100,190,"Gerar Arq SIgamat com empresas."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox9     := TCheckBox():New( 110,190,"Gerar Relatorio de Usuarios(Z05)."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )	
Else
	oCBox      := TCheckBox():New( 030,190,"Gera TXT de LPs na pasta MIGRACAO."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox8     := TCheckBox():New( 040,190,"Gerar Arq Sigamat com empresas."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oCBox9     := TCheckBox():New( 050,190,"Gerar Relatorio de Usuarios(Z05)."		,,oDlg1,120,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )	
EndIf

oSay3	   := TSay():New( 155,250,{|| "Make a Difference!"}	,oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay4	   := TSay():New( 155,005,{|| "Ver. 13.0130"}	,oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)

oSBtn1     := SButton():New( 142,226,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 142,262,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

oCBox:bSetGet := {|| lCheck }
oCBox:bLClicked := {|| lCheck:=!lCheck }
oCBox:bWhen := {|| .F. }
oCBox8:bSetGet := {|| lCheck8 }
oCBox8:bLClicked := {|| lCheck8:=!lCheck8 }
oCBox8:bWhen := {|| .T. }   
oCBox9:bSetGet := {|| lCheck9 }
oCBox9:bLClicked := {|| lCheck9:=!lCheck9 }
oCBox9:bWhen := {|| .T. }
If ALLTRIM(cUserLog) $ ADMIN
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
	oCBox6:bLClicked := {|| IF(lCheck3,lCheck6:=!lCheck6,.F.) }//so seleciona se o download da base estiver ativo.
	oCBox6:bWhen := {|| .T. }
	oCBox7:bSetGet := {|| lCheck7 }
	oCBox7:bLClicked := {|| lCheck7:=!lCheck7 }
	oCBox7:bWhen := {|| .F. }
EndIf

oDlg1:Activate(,,,.T.)

Return lRet

/*
Funcao      : Busca
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Posicionar na empresa informada
Autor       : Jean Victor Rocha.
Data/Hora   : 09/01/2013
*/
*---------------------*
Static Function Busca()
*---------------------*

aOrd := SaveOrd(cAliasWork)
If !EMPTY(cGet2)
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
Autor       : Jean Victor Rocha.
Data/Hora   : 09/01/2013
*/
*---------------------*
Static Function INCLRAPIDA()
*---------------------*
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
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------*
Static Function cMark()
*---------------------*
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
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna os dados para a Tela
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------*
Static Function Dados()
*---------------------*
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
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função principal para execução da migração.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*------------------------*
Static Function MAIN_MIG()
*------------------------*
Local cLog := ""
	//Carrega Regua Processamento
	ProcRegua(6)
	//tratamento para pasta de migração;
	IncProc("Analise de diretorios...")
	cLog += cRet := DIR_MIG()
	If LEFT(cRet,4) == "ERRO"
		RpcClearEnv()
		Return cLog
	EndIf

	If lCHeck2  .and. ALLTRIM(cUserLog) $ ADMIN
		//Copia dos dicionarios;
		IncProc("Copia de dicionarios...")
		cLog += cRet := DIC_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog
		EndIf
		//Acerto de valores repetidos;
		IncProc("Ajustes Automaticos...")
		cLog += cRet := AJUSTE_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
	   		Return cLog
		EndIf
		//Acertos de dicionarios definidos pelos administradores;
		IncProc("Ajustes definidos manualmente...")
		cLog += cRet := AJUSTE_M_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog 
		EndIf
		//Executa o pack em todos os dicionarios.
		IncProc("Execução do Pack...")	
		cLog += cRet :=	PACK_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog
		EndIf    
		//Apagar os arquivos CDX. utilizados...
		IncProc("Apagando CDX da pasta destino...")
		cLog += cRet := DELCDX_MIG()
		If LEFT(cRet,4) == "ERRO"
			RpcClearEnv()
			Return cLog
		EndIf
	EndIf

Return cLog

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : tratamento para pasta de migração;
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function DIR_MIG()
*-----------------------*
Local i
Local j
Local cRet := ""
Local cDir := ""
Local cPastaRaiz := "\MIGRACAO"
Local cPastaEmpr := "\"+SM0->M0_CODIGO
Local cPastaDado := "\Dados"
Local cPastaDics := "\SX"

Local aDir := {	cPastaRaiz,;//Acerto do diretorio raiz.
				cPastaEmpr,;//Diretorio da Empresa.
					{cPastaDado,;//Diretorio dos Dicionarios.
					cPastaDics};
				}//Diretorio dos Dados.

For i:=1 to Len(aDir)
	If VALTYPE(aDir[i]) == "C"
		cDir += aDir[i]
		If !file(cDir)
			If (nErro:=MakeDir(cDir)) <> 0
				cRet += "- Não foi possivel criação do diretorio '" + cDir + "' - Erro: " + ALLTRIM(STR(nErro)) + CHR(10)+CHR(13)
				Return "ERRO" + cRet
			EndIf
			cRet += "- Diretorio '"+cDir+"' criado com sucesso!"+CHR(13)+CHR(10)
		EndIf
	ElseIF VALTYPE(aDir[i]) == "A"
		For j:=1 to Len(aDir[i])
			If !file(cDir+aDir[i][j])
				If (nErro:=MakeDir(cDir+aDir[i][j])) <> 0
					cRet += "- Não foi possivel criação do diretorio '" + cDir+aDir[i][j] + "' - Erro: " + ALLTRIM(STR(nErro)) + CHR(10)+CHR(13)
					Return "ERRO" + cRet
				EndIf
				cRet += "- Diretorio '"+cDir+aDir[i][j]+"' criado com sucesso!"+CHR(13)+CHR(10)
			EndIf
  		Next i
	EndIf
Next i
  
Return cRet

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Copia dos dicionarios;
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function DIC_MIG()
*-----------------------*
Local i
local cRet := ""

aArq := Directory("\System\*.*")

For i:=1 to len(aArq)
	If	(UPPER(LEFT(aArq[i][1],2)) 		== "SX"   	.and.;
		UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.DBF"));//Copia dos Dicionarios, arquivos DBF.
		.or.;
		(UPPER(LEFT(aArq[i][1],2)) 		== "SX"   	.and.;
		UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.CDX"));//Copia dos Dicionarios, arquivos DBF.
		.or.;
		(UPPER(LEFT(aArq[i][1],3)) 		== "SIX"   	.and.;
		UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.DBF"));//Copia dos indices, arquivos DBF.
		.or.;
		(UPPER(LEFT(aArq[i][1],3)) 		== "SIX"   	.and.;
		UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.CDX"));//Apenas para ser utilizado no tratamento de ajustes.
		.or.;
		(UPPER(Substr(aArq[i][1],5,2)+Substr(aArq[i][1],9,4))	== UPPER(SM0->M0_CODIGO+".IC0"));//Copia dos arquivos de ICMS.
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
		.or.;
		(UPPER(Substr(aArq[i][1],4,2))	== UPPER(SM0->M0_CODIGO) .and.;
		UPPER(RIGHT(aArq[i][1],4)) 		== ".FPT"					   );//Copia dos arquivos FPT, arquivos DBF.
		.or.;
		(UPPER(LEFT(aArq[i][1],2)) 		== "XX"   	.and.;
		UPPER(Substr(aArq[i][1],4))		== UPPER(SM0->M0_CODIGO+"0.DBF"));//Copia dos Dicionarios XX, arquivos DBF.
		
		__CopyFile( "\SYSTEM\"+aArq[i][1], "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1] )
		cRet += "- Copiado arquivo '"+aArq[i][1]+"'!"+CHR(13)+CHR(10)
	EndIf
Next i

Return cRet 

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Acerto de valores automaticos;
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
Static Function AJUSTE_MIG()
*--------------------------*
local cRet 		:= ""
Local cChaveAnt := ""
Local aArq 		:= {}

//Tratamento para o Dicionario SIX.
dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SIX"+SM0->M0_CODIGO+"0.dbf","SIXMIG", .F., .F. )//exclusivo
ORDCREATE("\migracao\"+SM0->M0_CODIGO+"\sx\SIX"+SM0->M0_CODIGO+"1.cdx",, "CHAVE", {|| CHAVE })
SIXMIG->(DbGoTop())
While SIXMIG->(!EOF())
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

//Tratamento para o Dicionario SX2.
aSx2 := {"CVG"}

dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX2"+SM0->M0_CODIGO+"0.dbf","SX2MIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX2"+SM0->M0_CODIGO+"0.cdx")
SX2MIG->(DbSetOrder(1))
SX2MIG->(DbGoTop())
cChaveAnt := ""
For i:=1 to Len(aSX2)
	If SX2MIG->(DbSeek(aSx2[i]))
		While SX2MIG->(!EOF())
			If cChaveAnt == SX2MIG->X2_CHAVE
		    	cRet += "- Del SX2 '"+ALLTRIM(SX2MIG->X2_CHAVE)+"'."+CHR(10)+CHR(13)
		    	RecLock("SX2MIG", .F.)
		    	SX2MIG->(DbDelete())
		    	SX2MIG->(MsUnlock())
			EndIf
			cChaveAnt := SX2MIG->X2_CHAVE
			SX2MIG->(DbSkip())
		EndDo
	EndIf
Next i
SX2MIG->(DBPACK())
SX2MIG->(dbCloseArea())

//Tratamento para o Dicionario SX3.
aSx3 := {"CVG_"}
dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.dbf","SX3MIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.cdx")
SX3MIG->(DbSetOrder(2))
SX3MIG->(DbGoTop())
cChaveAnt := ""
For i:=1 to Len(aSX3)
	If SX3MIG->(DbSeek(aSx3[i]))
		While SX3MIG->(!EOF()) .and. LEFT(SX3MIG->X3_CAMPO,LEN(aSx3[i])) == aSx3[i]
			If cChaveAnt == SX3MIG->X3_ARQUIVO
		    	cRet += "- Del SX3 '"+ALLTRIM(SX3MIG->X3_CHAVE)+"'."+CHR(10)+CHR(13)
		    	RecLock("SX3MIG", .F.)
		    	SX3MIG->(DbDelete())
		    	SX3MIG->(MsUnlock())
			EndIf
			cChaveAnt := SX3MIG->X3_CAMPO
			SX3MIG->(DbSkip())
		EndDo
	EndIf
Next i
SX3MIG->(DBPACK())
SX3MIG->(dbCloseArea())

Return cRet  

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Acertos de dicionarios definidos pelos administradores;
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------------*
Static Function AJUSTE_M_MIG()
*----------------------------*
local cRet := ""
Local aSx3 := {}
Local aSx7 := {}
Local aAux := {}

//Acerto do SXG, Ajuste de tamanho do grupo
aSxg := {{"023","B1_CODISS"}}

dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SXG"+SM0->M0_CODIGO+"0.dbf","SXGMIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SXG"+SM0->M0_CODIGO+"0.cdx")
SXGMIG->(DbGoTop())
SXGMIG->(DbSetOrder(1))

dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.dbf","SX3MIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.cdx")
SX3MIG->(DbGoTop())
SX3MIG->(DbSetOrder(2))

For i:=1 to Len(aSxg)
	If SXGMIG->(DbSeek(aSxg[i][1]))
		
		if SX3MIG->(DbSeek(aSxg[i][2]))
		
			SXGMIG->(RecLock("SXGMIG", .F.))
			SXGMIG->XG_SIZE:=SX3MIG->X3_TAMANHO
			SXGMIG->(MsUnlock())
			cRet += "- SXG TAM do grupo atualizado'"+aSxg[i][1]+"' = '"+ALLTRIM(STR(SX3MIG->X3_TAMANHO))+"'."+CHR(10)+CHR(13)
		
		endif
		
	EndIf
Next i

SXGMIG->(DbCloseArea())
SX3MIG->(DbCloseArea())

//Acerto do SX3, acerto do tamanho do SXG.
aSx3 := {"CNX_NUMTIT","EK_NUM","EK_NUMOPER","DT8_NUMAWB","EE9_NF";
,"CL2_PARTI";
,"W8_CC";
,"CDQ_CLIENT";
,"CDV_LIVRO";
,"CCQ_CODIGO";
,"CGA_CODISS";
,"CGB_CODISS";
,"B4_CODISS";
,"C6_CODISS";
,"C9_CODISS";
,"D1_CODISS";
,"D2_CODISS";
,"F3_CODISS";
,"FT_CODISS";
,"FIM_CODISS";
,"FIM_CDISSM";
,"BZ_CODISS";
,"E1_CODISS";
,"E2_CODISS";
,"RK_POSTO";
,"CTB_FILORI";
,"EF_NUM";
,"E1_LOTE";
,"E2_LOTE";
,"E5_LOTE";
,"EE_LOTE";
,"EE_LOTECP";
,"GU2_CDEMIT";
,"GU3_CDEMIT";
,"GU3_CDEMFT";
,"GU8_CDPROP";
,"GUC_CDEMIT";
,"GUC_EMICOM";
,"GUU_CDTRP";
,"GUY_CDEMIT";
,"GUZ_CDEMIT";
,"GV1_CDEMIT";
,"GV6_CDEMIT";
,"GV7_CDEMIT";
,"GV8_CDEMIT";
,"GV8_CDREM";
,"GV8_CDDEST";
,"GV9_CDEMIT";
,"GVA_CDEMIT";
,"GVA_EMIVIN";
,"GVB_CDEMIT";
,"GVL_CDEMIT";
,"GVM_CDEMIT";
,"GW1_EMISDC";
,"GW1_CDREM";
,"GW1_CDDEST";
,"GW2_CDPROP";
,"GW3_EMISDF";
,"GW3_CDREM";
,"GW3_CDDEST";
,"GW3_EMIFAT";
,"GW3_CDCONS";
,"GW4_EMISDF";
,"GW4_EMISDC";
,"GW6_EMIFAT";
,"GW8_EMISDC";
,"GWA_CDEMIT";
,"GWB_EMISDC";
,"GWF_EMIREM";
,"GWF_EMIDES";
,"GWF_EMIRED";
,"GWF_EMIPAG";
,"GWF_TRANSP";
,"GWG_CDEMIT";
,"GWH_EMISDC";
,"GWJ_CDTRP";
,"GWJ_EMIFAT";
,"GWL_EMITDC";
,"GWM_CDTRP";
,"GWM_EMISDC";
,"GWN_CDTRP";
,"GWU_EMISDC";
,"GWU_CDTRP";
,"GWV_CDEMIT";
,"GWW_EMISDC";
,"GX3_CDEMIT";
,"GXA_EMISDC";
,"GXG_EMISDF";
,"GXG_CDREM";
,"GXH_EMISDC";
,"GXI_EMIFAT";
,"GXJ_EMISDF";
,"GXL_CDTRP";
,"GXL_EMISDC";
,"RHH_CC";
,"ED_ITEMD";
,"ED_ITEMC";
,"RHH_CLVL";
,"CLJ_COD"}

dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SXG"+SM0->M0_CODIGO+"0.dbf","SXGMIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SXG"+SM0->M0_CODIGO+"0.cdx")
SXGMIG->(DbGoTop())
SXGMIG->(DbSetOrder(1))

dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.dbf","SX3MIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.cdx")
SX3MIG->(DbGoTop())
SX3MIG->(DbSetOrder(2))
For i:=1 to Len(aSx3)
	If SX3MIG->(DbSeek(aSx3[i]))
		If !EMPTY(SX3MIG->X3_GRPSXG) .and. SXGMIG->(DbSeek(SX3MIG->X3_GRPSXG))
			SX3MIG->(RecLock("SX3MIG", .F.))
			SX3MIG->X3_TAMANHO := SXGMIG->XG_SIZE
			SX3MIG->(MsUnlock())
			cRet += "- SX3 TAM 'SXG' Atualizado '"+aSx3[i]+"' = '"+ALLTRIM(STR(SXGMIG->XG_SIZE))+"'."+CHR(10)+CHR(13)
		Else
			SX3MIG->(RecLock("SX3MIG", .F.))
			SX3MIG->X3_GRPSXG := ""
			SX3MIG->(MsUnlock())
			cRet += "- SX3 GSC apagado '"+aSx3[i]+"'."+CHR(10)+CHR(13)
		EndIf

	EndIf
Next i
SX3MIG->(DBPACK())
SX3MIG->(dbCloseArea())


//Acerto do SX3, apagar SXG.
aSx3 := {"GDX_CODCPG ","FIM_CODMUN ","LC9_IOFF ","LC9_ADIOF ","LC9_IOFSIM","LC9_LIMIOF","RCZ_CONTA","TW_CCUSTO","SC3_CONTA",;
		"CS4_CONTA","CS6_CONTA","CSB_CODCTA","CSC_CONTA","CSG_CONTA","CSJ_CONTA","CS4_CUSTO","CS5_CUSTO","CS6_CUSTO","CSB_CUSTO",;
		"CSB_CUSTO","SCG_CUSTO","DTC_CTRDPC","CS6_CODREV","JMM_NUMTIT","QAC_FUNCAO","CF6_TIPONF","JA1_DESCPR","JA6_DESC","JA7_DCODIG",;
		"JA8_DCODIG","JAA_DESC","JAC_DCODIG","JAI_DCODIG","JAV_DPROCE","JB7_DPROSE","E5_AGLIMP","ED_CCD","ED_CCC","ED_CLVLDB",;
		"ED_CLVLCR","E2_AGLIMP","ED_ITEMD","ED_ITEMC","E2_CODISS","E1_CODISS","CDV_LIVRO","BZ_CODISS","CTB_FILORI","RK_POSTO","W8_CC",;
		"PZ_CODISS","CDU_PRODUT","CE1_PROISS","B1_CODISS"}

dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.dbf","SX3MIG", .T., .F. )
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.cdx")
SX3MIG->(DbGoTop())
SX3MIG->(DbSetOrder(2))
For i:=1 to Len(aSx3)
	If SX3MIG->(DbSeek(aSx3[i]))
		SX3MIG->(RecLock("SX3MIG", .F.))
		SX3MIG->X3_GRPSXG := ""
		SX3MIG->(MsUnlock())
		cRet += "- SX3 GSC apagado '"+aSx3[i]+"'."+CHR(10)+CHR(13)
	EndIf
Next i
SX3MIG->(DBPACK())
SX3MIG->(dbCloseArea())

//Acerto do SX7.
aSx7:= {"CNE_PDESC","EE_CODIGO","EE_CONTA","FR9_DOCUM","FRD_DOCUM","RGX_TPREG","RGY_TPREG","ED_TABCCZ","ACX_GRUPO","D1_VUNIT"}
dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX7"+SM0->M0_CODIGO+"0.dbf","SX7MIG", .F., .F. )//exclusivo
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

//Acerto do SX1.
aSx1:= {"MTA996    07","MTA996    10"}
dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX1"+SM0->M0_CODIGO+"0.dbf","SX1MIG", .F., .F. )//exclusivo
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX1"+SM0->M0_CODIGO+"0.cdx")
SX1MIG->(DbGoTop())
For i:=1 to len(aSx1)
	If SX1MIG->(DbSeek(aSx1[i]))
		cRet += "- SX1 GSC apagado '"+aSx1[i]+"'."+CHR(10)+CHR(13)
		RecLock("SX1MIG", .F.)
    	SX1MIG->X1_GRPSXG := ""
    	SX1MIG->(MsUnlock())
	EndIf
Next i
SX1MIG->(dbCloseArea()) 

//Acerto Tamanho do SX1 - CNAB
aSx1:= {"AFI150    09",;
		"AFI151    03",;
		"AFI200    05",;
		"AFI420    03",;
		"AFI430    04",;
		"AFI300    05",;
		"GPM410    21",;		
		"GPM450    21"}
dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX1"+SM0->M0_CODIGO+"0.dbf","SX1MIG", .F., .F. )//exclusivo
DBSETINDEX("\migracao\"+SM0->M0_CODIGO+"\sx\SX1"+SM0->M0_CODIGO+"0.cdx")
SX1MIG->(DbGoTop())
For i:=1 to len(aSx1)
	If SX1MIG->(DbSeek(aSx1[i]))
		cRet += "- SX1 Alterado tamanho para 30 - '"+aSx1[i]+"'."+CHR(10)+CHR(13)
		RecLock("SX1MIG", .F.)
    	SX1MIG->X1_TAMANHO := 30
    	SX1MIG->(MsUnlock())
	EndIf
Next i
SX1MIG->(dbCloseArea()) 

Return cRet

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Executa Pack nos dicionarios.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------------*
Static Function PACK_MIG()
*----------------------------*
Local cRet := ""

//Executa o Pack em todos os dicionarios.
aArq := Directory("\migracao\"+SM0->M0_CODIGO+"\sx\*990.dbf")
For i:=1 to len(aArq)
	dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\"+aArq[i][1],"XXX", .F., .F. )//exclusivo 
	XXX->(__DBPACK())
	XXX->(dbCloseArea())
   	cRet += "- Pack executado '"+ALLTRIM(aArq[i][1])+"'."+CHR(10)+CHR(13)
Next i

Return cRet

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Apagar os arquivos CDX.
Autor       : Jean Victor Rocha.
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
cRet += "- Apagado todos CDX da pasta de Destino!"+CHR(10)+CHR(13)

Return cRet

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de LPs utilizados, baseado nos execblock do CT5.
Autor       : Jean Victor Rocha.
Data/Hora   : 19/12/2012
*/
*-------------------------*
Static Function BuscaLPS()
*-------------------------*
Local i
Local cTxt := ""
Local cAspas := cFonte := cAux := "" 
Local cDir := "\MIGRACAO\"
Local cArq := "CT5"+SM0->M0_CODIGO+SM0->M0_FILIAL

Private nHandle := 0

While File(cDir+cArq+".TXT")
	n++
	If AT("(",cArq) <> 0
		cArq := SUBSTR(cArq,1,AT("(",cArq))+ALLTRIM(STR(n))+")"
	Else
		cArq += "("+ALLTRIM(STR(n))+")"
	EndIf
EndDo
cArq := LEFT(cArq,6)+".TXT"

If (nHandle:=FCreate(cDir+cArq, FC_NORMAL)) == -1
	cTxt += " Erro na criação do arquivo TXT para CT5."+CHR(13)+CHR(10)
EndIf

SX2->(DbSetOrder(1))
If !SX2->(DbSeek("CT5")) .or. !EMPTY(cTxt)
	cTxt += "- CT5 não encontrado no SX2."+CHR(13)+CHR(10)
Else
	cTxt += "- " +SX2->X2_ARQUIVO+"."+CHR(13)+CHR(10)
	
	CT5->(DbSetOrder(1))
	CT5->(DbGoTop())
	While CT5->(!EOF())
		for i:=1 to CT5->(fCount())
			If AT("EXECBLOCK",&("CT5->"+CT5->(Fieldname(i)))) <> 0
				cAux := ALLTRIM(&("CT5->"+CT5->(Fieldname(i))))
		        While AT("EXECBLOCK",cAux) <> 0
				    cAspas	:= SUBSTR(cAux,AT("EXECBLOCK(",cAux)+10,1)
			   		cFonte	:= SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,AT(cAspas,SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,50))-1)
		   			cTxt	+= SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,AT(cAspas,SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,50))-1)+CHR(13)+CHR(10)
			        cAux	:= SUBSTR(cAux,AT(SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,AT(cAspas,SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,50))-1),cAux)+LEN(SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,AT(cAspas,SUBSTR(cAux,AT("EXECBLOCK(",cAux)+11,50))-1)),50)
		      	EndDo
			EndIf
		Next i
		CT5->(DbSKip())
	EndDo
EndIf

FWrite(nHandle,cTxt)
FClose(nHandle)

Return .T.

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Geração do Arquivo SIGAMAT.
Autor       : Jean Victor Rocha.
Data/Hora   : 19/12/2012
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
SM0MIG->(__DBPACK())
SM0MIG->(dbCloseArea()) 
FERASE("\migracao\SIGAMAT.IND")

Return .T.

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Controle de acesso ao migrador.
Autor       : Jean Victor Rocha.
Data/Hora   : 04/01/2013
*/
*----------------------*
User Function Login_MIG11()
*----------------------*
Local oFont
Local oDlg
Local oPanel
Local oBmp
Local oUsuario
Local cTmsUsu	:= Space(40)
Local oSenha
Local cSenhardm := Space(15)
Local oMainWnd
Local oOk
Local oCancel
Local lEndDlg     := .T.
Local lRet        := .F.

DEFINE FONT oFont NAME 'Arial' SIZE 0, -12 BOLD

DEFINE MSDIALOG oDlg FROM 040,030 TO 190,310 TITLE "Migrador - Grant Thornton Brasil" PIXEL OF oMainWnd
     @ 000,000 MSPANEL oPanel OF oDlg FONT oFont SIZE 200,200 LOWERED
     @ -95,000 BITMAP oBmp RESNAME 'LOGIN' oF oPanel SIZE 045,170 NOBORDER WHEN .F. PIXEL ADJUST

     @ 005,070 SAY "Usuario" SIZE 60,07 OF oPanel PIXEL FONT oFont
     @ 015,070 MSGET oUsuario VAR cTmsUsu SIZE 60,10 OF oPanel PIXEL FONT oFont

     @ 030,070 SAY "Senha" SIZE 53,07 OF oPanel PIXEL FONT oFont 
     @ 040,070 MSGET oSenha VAR cSenhardm SIZE 60,10 PASSWORD OF oPanel PIXEL FONT oFont

     DEFINE SBUTTON oOk FROM 60,70 TYPE 1 ENABLE OF oPanel PIXEL ACTION (lEndDlg := TmsVldSenh(cTmsUsu,cSenhardm), lRet := lEndDlg, Iif(lRet,oDlg:End(),.F.))
     DEFINE SBUTTON oCancel FROM 60,100 TYPE 2 ENABLE OF oPanel PIXEL ACTION (lEndDlg := .T.,lRet := .F.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED VALID lEndDlg

Return({lRet,cTmsUsu,cSenhardm})

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Validaçõs do controle de acesso ao migrador.
Autor       : Jean Victor Rocha.
Data/Hora   : 04/01/2013
*/
*-------------------------------------------*
Static Function TmsVldSenh(cTmsUsu,cSenhardm)
*-------------------------------------------*
Local cUsers := ADMIN
Local lRet          := .F.

cTmsUsu := AllTrim(cTmsUsu)
cSenhardm     := AllTrim(cSenhardm)

cUserLog := UPPER(cTmsUsu)

PswOrder(2)
If PswSeek(cTmsUsu)
//	If UPPER(cTmsUsu) $ UPPER(cUsers)
		If !PswName(cSenhardm)
			Alert("Senha Invalida!")
			lRet := .F.
		Else
			lRet := .T.
		EndIf
  /*	Else
		Alert("Usuario não autorizado!")
		lRet := .F.
	EndIf*/
Else
	Alert("Codigo de usuario nao existe")
	lRet := .F.
EndIf
Return(lRet)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Funcao      : MIG112DBF
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exporta o arquivo/registros selecionados de SQL para DBF.
Autor       : Jean Victor Rocha	
Data/Hora   : 18/10/2012
Obs         : 
TDN         : 
Obs         : Rotinas criadas com base no SQL2DBF e adaptada para utilização na migração da 11.

ATENÇÃO, FONTE ADAPTADO...
*/
*-------------------------*
Static Function MIG112DBF()
*-------------------------*

SetPrvt ("_aTMPSTRU,_cArq,_aTIT,_lTodos,_oBrw,_nFiles,_RecAtu")   //VARIAVEIS DO BROWSE DE ARQUIVOS
SetPrvt ("_ArqSel,_CampoOk,_oBrwRegs,_lRegTodos,oDlgRegs") //VARIAVEIS DO BROWSE DE REGISTROS
SetPrvt ("_nExpFiles,_cPath,_cArqSQL,_cIndSQL,_cArqDBF,_cAlias,_nRegsWWW") //VARIAVEIS DA EXPORTACAO DE ARQUIVOS
SetPrvt ("_WAlias")
_cPath := "\MIGRACAO\"+SM0->M0_CODIGO+"\DADOS\" + SPACE(45)
_lTodos := .F. // Todos os arquivos desmarcados
IF SELECT("WWW") > 0
   dbSelectArea("WWW")
   dbCloseArea("WWW")
ENDIF
//DbUseArea(.t.,,"SX2YY0","TRB",.T.)
dbSelectArea("SX2")
dbGoTop()
_aTMPSTRU := {}
AADD(_aTMPSTRU,{ "OK"         ,"C",02,0})
AADD(_aTMPSTRU,{ "X2_CHAVE"   ,"C",03,0})
AADD(_aTMPSTRU,{ "X2_ARQUIVO" ,"C",08,0})
AADD(_aTMPSTRU,{ "X2_NOME"    ,"C",30,0})
AADD(_aTMPSTRU,{ "TMP"        ,"L",01,0})

_aCampos := {}
AADD(_aCampos,{"OK"        ,"",""})
AADD(_aCampos,{"X2_CHAVE"  ,"CHAVE",""})
AADD(_aCampos,{"X2_ARQUIVO","ARQUIVO",""})
AADD(_aCampos,{"X2_NOME"   ,"DESCRICAO",""})

_cArq := Criatrab(_aTMPSTRU,.T.)
dbUseArea( .T.,,_cArq, "WWW", If(.F. .OR. .F., !.F., NIL), .F. )

dbSelectArea("SX2")
dbClearFilter(NIL)
dbSetOrder(1)
dbGoTop()
_nFiles := 0
Processa({|| BuscaSX2()},"Estrutura de arquivos...")
dbSelectArea("WWW")
dbGoTop()
_RecAtu := Recno()
//TELAUNMARK() // MONTA A TELA DESMARCADOS
TELAMARK()

dbSelectArea("WWW")
dbCloseArea("WWW")
FERASE(_cArq+OrdBagExt())

Return

/*
Funcao      : BuscaSX2
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta o arquivo temporário
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function BuscaSX2()   
*---------------------------*
ProcRegua(LastRec()) 
WHILE !EOF()
	IncProc()
	If SM0->M0_CODIGO == "YY" .or. lCheck4 .or. !("YY0" $ SX2->X2_ARQUIVO)
		DbSelectArea("WWW")
		_nCampos := FCOUNT()
		RecLock("WWW",.T.)
		FOR _n:= 1 TO _nCampos
			dbSelectArea("SX2")
			xCampo := FIELDGET(_n)
			cNomeCpo := FIELDNAME(_n)
			dbSelectArea("WWW")
			FIELDPUT(FIELDPOS(cNomeCpo),xCampo)
		NEXT
		Field->TMP := .F.
		_nFiles := _nFiles + 1
		MsUnlock()
	Endif
	dbSelectArea("SX2")
	dbSkip()
ENDDO

If lCheck6
	TABFECHAGPE()
EndIf

Return

/*
Funcao      : TELAUNMARK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta a tela COM ARQUIVOS DESMARCADOS
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function TELAUNMARK() 
*---------------------------*
@ 109,056 To 500,644 Dialog oDlg Title OemToAnsi("Conversao SQL p/ DBF")
@ 005,008 SAY "Selecione os arquivos a serem exportados:"
@ 015,008 TO 190,230 BROWSE "WWW" MARK "OK" FIELDS _aCampos Object _oBrw
_oBrw:bMark := { || _RotMark()}
@ 015,240 BmpButton Type 1 Action TelaExporta()
@ 030,240 BmpButton Type 2 Action Close(oDlg)
@ 045,240 Button "_Todos" Action MarkAll() Object _oBtodos
@ 183,240 Say "Arquivos: "+ALLTRIM(STR(_nFiles))
// DESMARCA OS ARQUIVOS
While !Eof()
	RecLock("WWW",.F.)
	Field->OK := ThisMark()
	dbSkip()
	MsUnlock()
Enddo
_lTodos := .F. // TODOS ARQUIVOS DESMARCADOS
dbGoto(_RecAtu)
Activate Dialog oDlg Centered //ATIVA A CAIXA DE DIALOGO
Return

/*
Funcao      : TELAMARK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta a tela COM ARQUIVOS MARCADOS
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function TELAMARK()   
*---------------------------*

// MARCA OS ARQUIVOS
WWW->(dbGoTop())
While WWW->(!Eof())
	RecLock("WWW",.F.)
		WWW->OK := ""
	WWW->(MsUnlock())
	WWW->(dbSkip())
Enddo
_lTodos := .T. // TODOS ARQUIVOS MARCADOS
@ 109,056 To 500,640 Dialog oDlg Title OemToAnsi("Conversao SQL para DBF")
@ 005,008 SAY "Selecione os arquivos a serem exportados:"
@ 015,008 TO 190,230 BROWSE "WWW" MARK "OK" FIELDS _aCampos Object _oBrw
_oBrw:bMark := { || _RotMark()}
@ 015,240 BmpButton Type 1 Action TelaExporta()
@ 030,240 BmpButton Type 2 Action Close(oDlg)
@ 045,240 Button "_Todos" Action MarkAll()
@ 183,240 Say "Arquivos: "+ALLTRIM(STR(_nFiles))
dbGoto(_RecAtu)
//Activate Dialog oDlg Centered //ATIVA A CAIXA DE DIALOGO

TelaExporta()

Return


/*
Funcao      : MarkAll
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que marca/desmarca todos os arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------*
Static Function MarkAll()    
*-----------------------*
IF MSGBOX("Esta acao ira marcar/desmarcar todos os Arquivos !"+CHR(13)+CHR(10)+"Confirma ?","Confirmação Marca Arquivos","YESNO")
	Close(oDlg)// FECHA A CAIXA DE DIALOGO PRINCIPAL
	dbSelectArea("WWW")
	dbGoTop()
	IF _lTodos == .F.
		dbGoTop()
		TELAMARK()
	ELSE
		dbGoTop()
		TELAUNMARK()
	ENDIF
ENDIF
Return

/*
Funcao      : TELAREMARK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função disparada na selecao de Arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function TELAREMARK() 
*---------------------------*
         
dbSelectArea("WWW")
@ 109,056 To 500,640 Dialog oDlg Title OemToAnsi("Conversao SQL para DBF")
@ 005,008 SAY "Selecione os arquivos a serem exportados:"
@ 015,008 TO 190,230 BROWSE "WWW" MARK "OK" FIELDS _aCampos Object _oBrw
_oBrw:bMark := { || _RotMark()}
@ 015,240 BmpButton Type 1 Action TelaExporta()
@ 030,240 BmpButton Type 2 Action Close(oDlg)
@ 045,240 Button "_Todos" Action MarkAll()
@ 183,240 Say "Arquivos: "+ALLTRIM(STR(_nFiles))
dbGotop()
While !Eof()
	If !Empty(OK)
		RecLock("WWW",.F.)
		Field->OK := ThisMark()
		MsUnlock()
	Endif
	dbSkip()
Enddo
dbGoto(_RecAtu)
Activate Dialog oDlg Centered //ATIVA A CAIXA DE DIALOGO
Return

/*
Funcao      : _RotMark
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função disparada na selecao de Arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function _RotMark()   
*---------------------------*
_RecAtu := Recno()
If Empty(WWW->OK)
	IF WWW->TMP == .T.
		IF MSGBOX("Arquivo Inteiro ?","Selecionando dados....","YESNO") .and. LASTKEY() <> 27
			_WAlias := "W"+ALLTRIM(WWW->X2_CHAVE)  //Alias do arquivo selecionado
			_TMPArqSel := ALLTRIM(WWW->X2_ARQUIVO) // NOME DO ARQUIVO TEMPORARIO
			dbSelectArea(_WAlias)
			dbCloseArea(_WAlias)
			FERASE(_TMPArqSel+OrdBagExt())
			dbSelectArea("WWW")
			RecLock("WWW",.F.)
			Field->X2_ARQUIVO := ALLTRIM(WWW->X2_CHAVE)+cEmpAnt+"0"
			Field->TMP := .F.
			MsUnlock()
			Close(oDlg)// FECHA A CAIXA DE DIALOGO PRINCIPAL
			TELAREMARK()
		ELSE
			_ArqSel := ALLTRIM(WWW->X2_CHAVE)  //Alias do arquivo selecionado
			_TMPArqSel := ALLTRIM(WWW->X2_ARQUIVO) // NOME DO ARQUIVO TEMPORARIO
			_WAlias := "W"+_ArqSel // Alias do Arquivo Temporário a criar
			dbSelectArea(_ArqSel)
			_StruArqSel := dbStruct()
			_aRegCampos := {}
			_nCpoArqSel := Len(_StruArqSel) - 1
			AADD(_aRegCampos,{"OKREG" ,"",""})
			FOR _nReg := 1 TO _nCpoArqSel
				AADD(_aRegCampos,{_StruArqSel[_nReg,1] ,_StruArqSel[_nReg,1],""})
			NEXT
			dbSelectArea(_WAlias)
			dbGoTop()
			_lRegTodos := .T.
			REMARKREGS() // FUNCAO QUE MONTA A TELA DE SELECAO DE REGISTROS
		ENDIF
	ELSE
		IF !MSGBOX("Arquivo Inteiro ?","Selecionando dados...","YESNO")
			_ArqSel := ALLTRIM(WWW->X2_CHAVE)	//Alias do arquivo selecionado
			_WAlias := "W"+_ArqSel 				// Alias do Arquivo Temporário a criar
			dbSelectArea(_ArqSel)				// Usa arquivo selecionado
			
			_StruArqSel := dbStruct()  			// Copia estrutura do arquivo selecionado
			AADD(_StruArqSel,{ "OKREG" ,"C",02,0}) // Adiciona o Campo Ok no arquivo
			_TMPArqSel := Criatrab(_StruArqSel, .T.) // Cria o arquivo temporário
			dbUseArea( .T.,,_TMPArqSel, _Walias, If(.F. .OR. .F., !.F., NIL), .F. ) // Monta a area de trabalho
			
			_aRegCampos := {}
			_nCpoArqSel := Len(_StruArqSel) - 1
			AADD(_aRegCampos,{"OKREG" ,"",""})
			FOR _nReg := 1 TO _nCpoArqSel
				AADD(_aRegCampos,{_StruArqSel[_nReg,1] ,_StruArqSel[_nReg,1],""})
			NEXT
			
			dbSelectArea(_ArqSel)
			_nRegs := RecCount()
			dbSetOrder(1)
			dbGoTop()
            
            Close(oDlg)// FECHA A CAIXA DE DIALOGO PRINCIPAL
			If _nRegs > 1500
				If MSGBOX("Deseja realmente selecionar os registros ?","Encontrados "+ALLTRIM(STR(_nRegs))+" registros","YESNO") .and. LASTKEY() <> 27
						Processa( {||BUSCATMP()} )
						MARKREGS() // FUNCAO QUE MONTA A TELA DE SELECAO DE REGISTROS
				Else
					TELAREMARK()
				Endif
			Else
				Processa( {||BUSCATMP()} )
				MARKREGS() // FUNCAO QUE MONTA A TELA DE SELECAO DE REGISTROS
			Endif
		ENDIF
	ENDIF
Endif
Return

/*
Funcao      : BUSCATMP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que ALIMENTA O ARQUIVO TMP CRIADO
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
STATIC FUNCTION BUSCATMP()   
*---------------------------*

ProcRegua(_nRegs)
WHILE !EOF()
	IncProc()
	DbSelectArea(_WAlias)
	_nCampos := FCOUNT()
	RecLock(_WAlias,.T.)
	FOR _n:= 1 TO _nCampos
		dbSelectArea(_ArqSel)
		xCampo := FIELDGET(_n)
		cNomeCpo := FIELDNAME(_n)
		dbSelectArea(_WAlias)
		FIELDPUT(FIELDPOS(cNomeCpo),xCampo)
	NEXT
	MsUnlock()
	dbSelectArea(_ArqSel)
	dbSkip()
ENDDO

dbSelectArea("WWW")
RecLock("WWW",.F.)
Field->X2_ARQUIVO := ALLTRIM(WWW->X2_CHAVE)+cEmpAnt+"0"
Field->TMP := .T.
MsUnlock()

dbSelectArea(_WAlias)
dbGoTop()
_lRegTodos := .T.

RETURN

/*
Funcao      : MARKREGS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta a tela COM REGISTROS MARCADOS
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function MARKREGS()   
*---------------------------*

// MARCA OS ARQUIVOS
dbGoTop()
While !Eof()
	RecLock(_WAlias,.F.)
	Field->OKREG := ""
	dbSkip()
	MsUnlock()
Enddo
_lRegTodos := .T.
@ 109,056 To 500,640 Dialog oDlgRegs Title OemToAnsi("Selecionando Registros...")
@ 005,008 SAY "Arquivo: " + ALLTRIM(WWW->X2_CHAVE) + " (" + ALLTRIM(_TMPArqSel) + ") -> " + STRTRAN(ALLTRIM(WWW->X2_NOME),"'","")
@ 015,008 TO 190,230 BROWSE _Walias MARK "OKREG" FIELDS _aRegCampos Object _oBrwRegs
_oBrwRegs:bMark := { || _RotMarkReg()}
@ 015,240 BmpButton Type 1 Action _GravaTMPRegs()
@ 030,240 BmpButton Type 2 Action FechaRegs()
@ 045,240 Button "_Todos" Action MarkAllRegs()
dbGoTop()
Activate Dialog oDlgRegs Centered // Ativa o Browse de Registros
Return

/*
Funcao      : REMARKREGS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta a tela COM REGISTROS MARCADOS
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function REMARKREGS()
*---------------------------*
dbSelectArea(_WAlias)
@ 109,056 To 500,640 Dialog oDlgRegs Title OemToAnsi("Selecionando Registros...")
@ 005,008 SAY "Arquivo: " + ALLTRIM(WWW->X2_CHAVE) + " (" + ALLTRIM(WWW->X2_ARQUIVO) + ") -> " + ALLTRIM(WWW->X2_NOME)
@ 015,008 TO 190,230 BROWSE _Walias MARK "OKREG" FIELDS _aRegCampos Object _oBrwRegs
_oBrwRegs:bMark := { || _RotMarkReg()}
@ 015,240 BmpButton Type 1 Action _GravaTMPRegs()
@ 030,240 BmpButton Type 2 Action FechaRegs()
@ 045,240 Button "_Todos" Action MarkAllRegs()
dbGoTop()
While !Eof()
	If !Empty(OKREG)
		RecLock(_WAlias,.F.)
		Field->OKREG := ThisMark()
		MsUnlock()
	Endif
	dbSkip()
Enddo
dbGotop()
Activate Dialog oDlgRegs Centered  // Ativa o Browse de Registros
Return

/*
Funcao      : MarkAllRegs
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que marca/desmarca todos os registros
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function MarkAllRegs()
*---------------------------*
IF MSGBOX("Esta acao ira marcar/desmarcar todos os registros !"+CHR(13)+CHR(10)+"Confirma ?","Confirmação Marca Registros","YESNO")
	IF _lRegTodos == .F.
		Close(oDlgRegs)// FECHA A CAIXA DE DIALOGO
		dbGoTop()
		MARKREGS()
		_lRegTodos := .T.
	ELSE
		Close(oDlgRegs)// FECHA A CAIXA DE DIALOGO
		@ 109,056 To 500,640 Dialog oDlgRegs Title OemToAnsi("Selecinando Registros...")
		@ 005,008 SAY "Arquivo: " + ALLTRIM(WWW->X2_CHAVE) + " (" + ALLTRIM(WWW->X2_ARQUIVO) + ") -> " + ALLTRIM(WWW->X2_NOME)
		@ 015,008 TO 190,230 BROWSE _Walias MARK "OKREG" FIELDS _aRegCampos Object _oBrwRegs
		_oBrwRegs:bMark := { || _RotMarkReg()}
		@ 015,240 BmpButton Type 1 Action _GravaTMPRegs()
		@ 030,240 BmpButton Type 2 Action FechaRegs()
		@ 045,240 Button "_Todos" Action MarkAllRegs()
		
		dbGoTop()
		While !Eof()
			RecLock(_WAlias,.F.)
			Field->OKREG := ThisMark()
			MsUnlock()
			dbSkip()
		Enddo
		_lRegTodos := .F.
		dbGoTop()
		Activate Dialog oDlgRegs Centered// Ativa o Browse de Registros
	ENDIF
ENDIF
Return

/*
Funcao      : _RotMarkReg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função Executada quando um registro é selecionado no Browse de Registros
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function _RotMarkReg()
*---------------------------*
If Empty(OKREG)
	RecLock(_WAlias,.F.)
	Field->OKREG := ThisMark()
	MsUnLock()
Endif
Return

/*
Funcao      : _GravaTMPRegs
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Grava o Novo nome do Arquivo quando selecionados os registros
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------------*
Static Function _GravaTMPRegs()
*-----------------------------*
dbSelectArea("WWW")
RecLock("WWW",.F.)
Field->X2_ARQUIVO := SUBSTR(ALLTRIM(_TMPArqSel),1,8)
Field->TMP := .T.
MsUnlock()
Close(oDlgRegs)

dbGoTop()
While !Eof()
	If !Empty(WWW->OK)
		RecLock("WWW",.F.)
		Field->OK := ThisMark()
		MsUnlock()
	Endif
	dbSkip()
Enddo
TELAREMARK()

Return

/*
Funcao      : TelaExporta
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Monta a Tela com o Path para os arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function TelaExporta()
*---------------------------*

_RecAtu := Recno()
// Inicializa a Regua de Processamento
dbSelectArea("WWW")
DbGoTop()
_nRegsWWW := 0
While !Eof()
	If ALLTRIM(WWW->OK) == ""
		_nRegsWWW := _nRegsWWW + 1
	Endif
	dbSkip()
Enddo

dbGoto(_RecAtu)

If _nRegsWWW == 0
	MSGBOX("Nao ha arquivos selecionados"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Selecione 01 ou mais arquivos...", "Selecionando Arquivos", "INFO")
	oDlg:Refresh()
Else
	// Exibe a tela para selecao do caminho onde serao gravados os arquivos
	@ 150,050 To 250,400 Dialog _oDlgPath Title OemToAnsi("Destino...")
	@ 005,010 SAY "Digite o diretorio destino:"
	@ 015,020 Get _cPath Size 140,010 Object _oGetPath
	@ 035,010 SAY ALLTRIM(STR(_nRegsWWW)) + " arquivo(s) selecionado(s)."
	@ 030,110 BmpButton Type 1 Action ValidaPath()
	@ 030,140 BmpButton Type 2 Action FechaPath()
	//Activate Dialog _oDlgPath Centered
Endif

Processa({|| ValidaPath() })

Return

/*
Funcao      : _Exporta
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Verifica se o Path indicado existe
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
Static Function ValidaPath()
*--------------------------*
If !lIsDir(ALLTRIM(_cPath))
	Close(_oDlgPath)
	MSGBOX("O diretorio: " + ALLTRIM(_cPath) + " nao existe !","Erro - Selecione outro diretorio")
	TelaExporta()
Else
	Close(_oDlgPath)
	//Processa({|| _Exporta()})
	_Exporta()
	//TELAREMARK()
Endif
Return

/*
Funcao      : _Exporta
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Exporta os Arquivos/Registros Marcados
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*------------------------*
Static Function _Exporta()
*------------------------*
local _NQUANT
Local cTabAjuste := "SW8/FIM/SBZ/SE1/SE2/SRK/SED"  //tabelas que deverão ser ajustadas de acordo com o SX3 e apendado os dados, separe por /

Close(oDlg)     

dbSelectArea("WWW")
ProcRegua(_nRegsWWW) // INICIALIZA A REGUA DE PROCESSAMENTO
DbGoTop()
_nExpFiles := 0
While !Eof()
	IncProc()
	If WWW->OK <> ThisMark()
		_cAlias  := AllTrim(WWW->X2_CHAVE)
		_WAlias := "W"+_cAlias
		_cArqSQL := AllTrim(WWW->X2_ARQUIVO)
		_cIndSQL := AllTrim(WWW->X2_ARQUIVO)+"1"
		
		IF TCCANOPEN(_cArqSQL) // É UM ARQUIVO DO SQL
            nCount := VAL(cGet1) + 10
            nTime  := 100
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
			_nExpFiles := _nExpFiles + 1
			
			if !_cAlias $ cTabAjuste
				StartJob( "U_Thread        "+_cArqSQL , GetEnvServer() , .F., _cArqSQL,_cPath,_WAlias,_cIndSQL,cEmpAnt,cFilAnt)
			else
				StartJob( "U_ThreadAj      "+_cArqSQL , GetEnvServer() , .F., _cArqSQL,_cPath,_WAlias,_cIndSQL,cEmpAnt,cFilAnt,_cAlias)
			endif
			
		EndIf
	Endif
	DbSelectArea("WWW")
	DbSkip()
EndDo

RETURN    

/*
Funcao      : Thread
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para execução das threads de download da base de dados.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------------------------------------------------*
User Function Thread(_cArqSQL,_cPath,_WAlias,_cIndSQL,cEmp,cFilEmp)
*-----------------------------------------------------------------*
Local _nQuant
Local _cArqDBF


RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

IF TCCANOPEN(_cArqSQL) // É UM ARQUIVO DO SQL			
	_cArqDBF := AllTrim(_cPath)+_cArqSQL+".DBF"
	dbUseArea( .T., "TOPCONN", (_cArqSQL), (_WAlias), if(.T. .OR. .F., !.F., NIL), .F. )
	IF TCCANOPEN(_cArqSQL,_cIndSQL) 
		DbSetIndex(_cIndSQL)
		_nQuant := RecCount()
	ElseIf TCCANOPEN(_cArqSQL)
		_nQuant := RecCount()
	ENDIF			  
	IF _nQuant > 0
		__dbCopy((_cArqDBF),{ },,,,,.F.,"DBFCDX")
		(_WAlias)->(MSUNLOCK())
	END IF          
	(_WAlias)->(dbCloseArea())
ENDIF
RpcClearEnv()

Return .T.

/*
Funcao      : Thread
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para execução das threads de criação do sx com base no sx3 e apend da base de dados.
Autor       : Matheus.
Data/Hora   : 
*/
*-----------------------------------------------------------------------------*
User Function ThreadAj(_cArqSQL,_cPath,_WAlias,_cIndSQL,cEmp,cFilEmp,_cAlias)
*-----------------------------------------------------------------------------*
Local _nQuant
Local _cArqDBF
Local aStruc:={}

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

IF TCCANOPEN(_cArqSQL) // É UM ARQUIVO DO SQL			
	
	dbUseArea( .T.,"dbfcdxads", "\migracao\"+SM0->M0_CODIGO+"\sx\SX3"+SM0->M0_CODIGO+"0.dbf","SX3MIG", .T., .F. )
	DBSETINDEX("\system\SX3"+SM0->M0_CODIGO+"0.cdx")
	SX3MIG->(DbSetOrder(1))
	SX3MIG->(DbGoTop())          
	
	SX3MIG->(DbSeek(_cAlias))
	While SX3MIG->(!EOF()) .AND. SX3MIG->X3_ARQUIVO == _cAlias
		AADD(aStruc,{SX3MIG->X3_CAMPO,SX3MIG->X3_TIPO,SX3MIG->X3_TAMANHO,SX3MIG->X3_DECIMAL})
		SX3MIG->(DbSkip())
	Enddo
 
	_cArqDBF := AllTrim(_cPath)+_cArqSQL+".DBF"

	dbCreate(_cArqDBF,aStruc)
	dbUseArea( .T.,"dbfcdxads", _cArqDBF,"TRBAUX", .T., .F. )

   //	dbUseArea( .F., "TOPCONN", (_cArqSQL), (_WAlias), if(.T. .OR. .F., !.F., NIL), .F. )

    dbSelectArea(_cAlias)
	dbSelectArea("TRBAUX")
	MsAppend(,_cAlias)

	TRBAUX->(DbCloseArea())
	SX3MIG->(DbCloseArea())

	(_WAlias)->(dbCloseArea())
ENDIF
RpcClearEnv()

Return .T.

/*                     		
Funcao      : FechaPath
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que Fecha a tela de Selecao de Registros e volta a tela de arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-------------------------*
STATIC FUNCTION FechaRegs()
*-------------------------*
Close(oDlgRegs)
dbSelectArea(_WAlias)
dbCloseArea(_WAlias)
dbSelectArea("WWW")
TELAREMARK()
RETURN

/*
Funcao      : FechaPath
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que fecha a tela do PATH e retorna a tela de arquivos
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/ 
*-------------------------*
STATIC FUNCTION FechaPath()
*-------------------------*
Close(_oDlgPath)
Close(oDlg)
TELAREMARK()
RETURN

/*
Funcao      : TABFECHAGPE
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que retorna os nomes das tabelas de fechamentos do GPE, RC???? e RI????.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
STATIC FUNCTION TABFECHAGPE()
*---------------------------*
Local cQry := ""

cQry:="	SELECT name as FNAME FROM sysobjects "
cQry+="	WHERE sysstat & 0xf in (3) "
cQry+="	and name not like '#%' and name not like '%FK' "
cQry+="	and (name like 'RC"+cEmpAnt+"%' or name like 'RI"+cEmpAnt+"%')
cQry+="	ORDER BY name "

If Select("TMPGPE") > 0
	TMPGPE->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQry),"TMPGPE",.F.,.T.)

TMPGPE->(DBGOTOP())
While TMPGPE->(!EOF())
	DbSelectArea("WWW")
	_nCampos := FCOUNT()
	RecLock("WWW",.T.)
	WWW->OK 		:= ""
	WWW->X2_CHAVE	:= TMPGPE->FNAME
	WWW->X2_ARQUIVO	:= TMPGPE->FNAME
	WWW->X2_NOME 	:= TMPGPE->FNAME
	WWW->TMP 		:= .F.
	MsUnlock()

	TMPGPE->(DBSKIP())
EndDo
If Select("TMPGPE") > 0
	TMPGPE->(DbCloseArea())
EndIf

RETURN

/*
Funcao      : Dados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para download dos arquivos SPED.
Autor       : Jean Victor Rocha.
Data/Hora   : 21/12/12
*/
*---------------------------------------------*
Static Function SPED(cBaseSPED,cEmpAtu,cFilAtu)
*---------------------------------------------*
Local i
Local lOk := .F.
Local cLog := ""
Local cPasta 	:= "\MIGRACAO\"+cEmpAtu+"\TEMP"
Local aBancos 	:= {"SPED_P10","SPED1_P10","SPED2_P10","SPED3_P10","SPED3A_P10","SPED3B_P10","SPEDBH_P10","SPEDGT_P10","SPEDGT03_P10","SPEDMN_P10"}
Local aTabs 	:= {"SPED070","SPED056","SPED054","SPED052","SPED050","SPED001B","SPED001A","SPED001","SPED000","SPED150","SPED154"}
Private nHandle := 0


cLog += "======================================================================="+ CHR(10)+CHR(13)
cLog += "=========================== SPED  ====================================="+ CHR(10)+CHR(13)
cLog += "======================================================================="+ CHR(10)+CHR(13)
              

//Tratamento para pasta TEMP
If !file(cPasta)
	If (nErro:=MakeDir(cPasta)) <> 0
		cLog += "- Não foi possivel criação do diretorio '" +cPasta + "' - Erro: " + ALLTRIM(STR(nErro)) + CHR(10)+CHR(13)
	Else
		cLog += "- Foi criado o diretorio '" +cPasta + "' com sucesso" + CHR(10)+CHR(13)
	EndIf
EndIf

//Dispara uma thread para cada banco.
For i:=1 to Len(aBancos)
	StartJob( "U_BUSCASPED" , GetEnvServer() , .F., i, aBancos[i], cEmpAnt, cFilAnt, SM0->M0_CGC)
Next i

//Aguarda execução dos JOBS para todos os bancos informados.
lOk := .F.
While !lOk
	lOk := .T.
	For i:=1 to Len(aBancos)
		If !FILE("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"OK.TXT")
			lOk := .F.
		EndIf
	Next i
	Sleep(500)//0.5 segundos.
EndDo

//Geração do Log Completo.
For i:=1 to Len(aBancos)
	cLog += ALLTRIM(STR(i))+" -----------------------------------------------------"+ CHR(10)+CHR(13)
	cLog += aBancos[1]+ CHR(10)+CHR(13)	
	If FILE("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"LOG.TXT")
		nHandle		:= Fopen("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"LOG.TXT")
		nTam := fSeek(nHandle,FS_SET,FS_END)
		FSeek(nHandle,0,0)
		cLog += fReadStr(nHandle,nTam)
		fclose(nHandle)
		FErase("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"LOG.TXT")
		FErase("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"OK.TXT")
	Else
		cLog += " Arquivo de Log Não encontrado"+ CHR(10)+CHR(13)	
	EndIf	
Next i
cLog += "-------------------------------------------------------"+CHR(10)+CHR(13)

//Verifica o Banco.
aLocBanco := {}
For i:=1 to Len(aBancos)
	If (nHandle	:= Fopen("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"BANCOxENT.TXT")) > 0
		nTam := fSeek(nHandle,FS_SET,FS_END)
		FSeek(nHandle,0,0)
		aAdd(aLocBanco, ALLTRIM(fReadStr(nHandle,nTam)))
		fclose(nHandle)
		FErase("\MIGRACAO\"+cEmpAtu+"\TEMP\"+ALLTRIM(STR(i))+"BANCOxENT.TXT")
	EndIF
Next i

If Len(aLocBanco) == 0
	cBanco:= ""
ElseIf Len(aLocBanco) == 1
	cBanco := SUBSTR(aLocBanco[1],1,AT("|",aLocBanco[1])-1)
Else
	cBanco := TelaBancos(aLocBanco)
Endif 

//Apaga a pasta TEMP
DIRREMOVE("\MIGRACAO\"+cEmpAtu+"\TEMP")

If EMPTY(cBanco)
	cLog += "Não encontrado BANCO SPED para esta empresa."+CHR(10)+CHR(13)
	Return cLog
EndIf

cLog += "+++++++++++++++++++++++++++++++++++++++++++++++++"+CHR(10)+CHR(13)
cLog += "BANCO :"+cBanco+ CHR(10)+CHR(13)

//Busca  as identidades.

nConWall := TCLink("MSSQL7/"+ALLTRIM(cBanco),"10.0.30.05",7890) //Abre conexão com banco do SPED
If nConWall < 0//Testa conexão
	cLog += "Erro ao conectar com o banco de dados 'MSSQL7/"+ALLTRIM(cBanco)+"' para busca de dados do SPED."+CHR(13)+CHR(10)
Else
	cLog += "Conectado no Banco 'MSSQL7/"+ALLTRIM(cBanco)+"'..."+CHR(13)+CHR(10)
EndIf

//Busca informações no SPED001
cQuery:=" SELECT *"
cQuery+=" FROM SPED001"
cQuery+=" WHERE D_E_L_E_T_ <> '*' AND CNPJ = '"+ALLTRIM(SM0->M0_CGC)+"'  "

If Select("TMP") > 0
	TMP->(DbCloseArea())	               
EndIf
 
TCQuery cQuery ALIAS "TMP" NEW

//Leitura do conteudo do SPED001
cEnt := ""
TMP->(DbGoTop())
While TMP->(!EOF())
	cEnt += ALLTRIM(TMP->ID_ENT)+"|"
	TMP->(DbSkip())
EndDo
cLog += "Entidade = "+cEnt+CHR(13)+CHR(10)

If Select("TMP") > 0
	TMP->(DbCloseArea())	               
EndIf

//Cria a Pasta SPED caso não existe.
cPasta := "\MIGRACAO\"+cEmpAtu+"\SPED"
If !file(cPasta)
	If (nErro:=MakeDir(cPasta)) <> 0
		cLog += "- Não foi possivel criação do diretorio '" +cPasta + "' - Erro: " + ALLTRIM(STR(nErro)) + CHR(10)+CHR(13)
	Else
		cLog += "- Foi criado o diretorio '" +cPasta + "' com sucesso" + CHR(10)+CHR(13)
	EndIf
EndIf

//Busca os dados na base e grava.
For i:=1 to Len(aTabs)
	StartJob( "U_ThreadSPED    "+aTabs[i] , GetEnvServer() , .F., aTabs[i],cEnt, cPasta, cEmpAnt, cFilAnt,cBanco)
Next i

Return cLog


/*
Funcao      : TelaBancos
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : caso exista mais de 1 banco para seleção, sera mostrado uma tela com a seleção do banco.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------------------*
Static Function TelaBancos(aLocBanco)
*-----------------------------------*
Local cRet := ""
Local cGetSPED := ""

SetPrvt("oDlgBc","oSay1","oSay2","oCBox1","oSBtn1")

aLocBanco

aItens := {}
For i:=1 to Len(aLocBanco)
	aAdd(aItens,SUBSTR(aLocBanco[i],1,AT("|",aLocBanco[i])-1))
Next i

oDlgBc      := MSDialog():New( 220,459,331,794,"Grant Thornton Brasil.",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 008,004,{||"Foi encontrado mais de um banco SPED para esta empresa!"},oDlgBc,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)
oSay2      := TSay():New( 020,004,{||"Informe qual devera ser utilizado:"},oDlgBc,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,084,008)
oCBox1     := tComboBox():New(032,004,{|u|if(PCount()>0,cGetSPED:=u,cGetSPED)},aItens,072,010,oDlgBc,,/*{||"Mudou item"}*/,,,,.T.,,,,,,,,,"cGetSPED")
oSBtn1     := SButton():New( 032,124,1,{|| oDlgBc:END()},oDlgBc,,"", )
oDlgBc:Activate(,,,.T.)

cRet := cGetSPED

Return cRet

/*
Funcao      : ThreadSPED
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para execução das threads de download das tabelas SPED.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------------------------------------------------*
User Function ThreadSPED(cTab,cEnt,cPasta, cEmp,cFilEmp,cBanco)
*-----------------------------------------------------------------*
Local cCondicao := ""
Local bCondicao := ""

cAux := ""
While AT("|",cEnt) <> 0
	cAux := SUBSTR(cEnt,1,AT("|",cEnt)-1)
	cCondicao += " ID_ENT = '"+cAux+"' .OR."
	cEnt := SUBSTR(cEnt,AT("|",cEnt)+1,LEN(cEnt))
EndDo

cCondicao := LEFT(cCondicao,Len(cCondicao)-5)
bCondicao := &("{|| "+cCondicao+" }")

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

nConWall := TCLink("MSSQL7/"+ALLTRIM(cBanco),"10.0.30.05",7890) 

IF TCCANOPEN(cTab) // É UM ARQUIVO DO SQL			
	If Select(cTab) > 0
		(cTab)->(DbCloseArea())
	EndIf

	Use &(cTab) Alias &(cTab) NEW Via "TOPCONN"

	(cTab)->(DbSetFilter(bCondicao,cCondicao))

	If Select("ARQ_SPED") > 0
		ARQ_SPED->(DbCloseArea())	               
	EndIf  
	__dbCopy( cPasta+"\"+cTab+".DBF", { },,,,, .F., "DBFCDX" )

	If Select(cTab) > 0
		(cTab)->(DbCloseArea())	               
	EndIf
ENDIF
RpcClearEnv()

Return .T.

/*
Funcao      : BUSCASPED
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca a localização do banco do SPED e retorna o codigo da entidade deste cliente.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-----------------------------------------------------*
User Function BUSCASPED(nJob,cBanco,cEmp,cFilEmp,cCNPJ)
*-----------------------------------------------------*
Local lAborta := .F.
Local cLog := ""
Local cTxt := ""
Local cArqOK := "BANCOxENT.TXT"
Local cPasta := "\MIGRACAO\"+cEmp+"\TEMP"
Local nConWall := 0
Local nErro := 0
                             '
Private nHandle := 0

cPasta += "\"

//Abre empresa.
RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

cLog += "Parametros: "+ALLTRIM(STR(nJOB))+"|"+cBanco+"|"+cEmp+"|"+cFilEmp+"|"+cCNPJ+CHR(13)+CHR(10)

//Abre conexão com banco do SPED
nConWall := TCLink("MSSQL7/"+ALLTRIM(cBanco),"10.0.30.05",7890) 
//Testa conexão
If nConWall < 0
	cLog += "Erro ao conectar com o banco de dados 'MSSQL7/"+ALLTRIM(cBanco)+"' para busca de dados do SPED."+CHR(13)+CHR(10)
Else
	cLog += "Conectado no Banco 'MSSQL7/"+ALLTRIM(cBanco)+"'..."+CHR(13)+CHR(10)
EndIf

//Busca informações no SPED001
cQuery:=" SELECT *"
cQuery+=" FROM SPED001"
cQuery+=" WHERE D_E_L_E_T_ <> '*' AND CNPJ = '"+ALLTRIM(cCNPJ)+"'  "

cLog += "Query = '"+cQuery+"'"+CHR(13)+CHR(10)

If Select("TMP") > 0
	TMP->(DbCloseArea())	               
EndIf
 
TCQuery cQuery ALIAS "TMP" NEW

//Leitura do conteudo do SPED001
TMP->(DbGoTop())
While TMP->(!EOF())
	cLog += "Banco|Entidade = "+cBanco+"|"+ALLTRIM(TMP->ID_ENT)+CHR(13)+CHR(10)
	cTXT += cBanco+"|"+ALLTRIM(TMP->ID_ENT)+CHR(13)+CHR(10)
	TMP->(DbSkip())
EndDo

If Select("TMP") > 0
	TMP->(DbCloseArea())	               
EndIf

//Geração do arquivo com informações do banco/ entidade.
If !EMPTY(cTxt)
	If FILE(cPasta+ALLTRIM(STR(nJOB))+cArqOK)
		cLog += "Arquivo da Localização do banco ja criado/ Duplicidade! '"+cPasta+ALLTRIM(STR(nJOB))+cArqOK+"'"+CHR(13)+CHR(10)
	Else
		If (nHandle:=FCreate(cPasta+ALLTRIM(STR(nJOB))+cArqOK, FC_NORMAL)) == -1
			cLog += "Não foi possivel criar Arquivo da Localização do banco!"+CHR(13)+CHR(10)
			cLog += "Conteudo:"+cLog+CHR(13)+CHR(10)
		EndIf
		FWrite(nHandle,cTxt)
		FClose(nHandle)
		cLog += "Arquivo da Localização do banco criado com sucesso!"+CHR(13)+CHR(10)
	EndIf
EndIf

RpcClearEnv()

//Geração do arquivo de LOG, LOG.TXT;
nHandle:=FCreate(cPasta+ALLTRIM(STR(nJOB))+"LOG.TXT", FC_NORMAL)
FWrite(nHandle,cLog)
FClose(nHandle)

//Finalização com a criação do arquivo de Job executado OK.TXT.
nHandle:=FCreate(cPasta+ALLTRIM(STR(nJOB))+"OK.TXT", FC_NORMAL)
FClose(nHandle)

Return .T.


/*
Funcao      : LoadDicSped
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tipo de campo das tabelas SPED, retirado de fonte padrão totvs.
Autor       : Jean Victor Rocha.
Data/Hora   : 
Objetivo	: NAO ESTA SENDO UTILIZADO. APENAS INFORMATIVO.
*/
*---------------------------------*
Static Function LoadDicSped(cTable)                    
*---------------------------------*
Local cUnique := ""
Local aCampos := {}
Local aIndices:= {}

Do Case
	Case cTable == "SPED000"
		cUnique := "ID_ENT+PARAMETRO"

		aadd(aCampos,{"ID_ENT"    ,"C",006,0})
		aadd(aCampos,{"PARAMETRO" ,"C",010,0})
		aadd(aCampos,{"CONTEUDO"  ,"C",250,0})
		
		aadd(aIndices,{cUnique,"PK"})

	Case cTable == "SPED001"
		cUnique := "ID_ENT"
		
		aadd(aCampos,{"ID_ENT"    ,"C",06,0})
		aadd(aCampos,{"ID_MATRIZ" ,"C",06,0})
		aadd(aCampos,{"CNPJ"      ,"C",14,0})
		aadd(aCampos,{"CPF"       ,"C",11,0})
		aadd(aCampos,{"IE"        ,"C",18,0})
		aadd(aCampos,{"UF"        ,"C",02,0})
		aadd(aCampos,{"INDSITESP" ,"C",01,0})
		aadd(aCampos,{"PASSCERT"  ,"C",250,0})
		aadd(aCampos,{"ENTATIV"   ,"C",01,0})
		aadd(aCampos,{"CTRL_NFE"  ,"C",10,0})
		aadd(aCampos,{"PASSENT"   ,"C",50,0})		
		
		aadd(aIndices,{cUnique,"PK"})
		aadd(aIndices,{"CNPJ+CPF+IE+UF","UNQ"})
		aadd(aIndices,{"ID_MATRIZ","03"})
		
	Case cTable == "SPED001A"
		cUnique := "ID_ENT+DTOS(DTULTALT)"
		
		aadd(aCampos,{"ID_ENT"    ,"C",006,0})
		aadd(aCampos,{"DTULTALT"  ,"D",008,0})
		aadd(aCampos,{"COD_MUN"   ,"C",007,0})
		aadd(aCampos,{"COD_PAIS"  ,"C",005,0})
		aadd(aCampos,{"IM"        ,"C",018,0})
		aadd(aCampos,{"SUFRAMA"   ,"C",018,0})
		aadd(aCampos,{"NIT"       ,"C",011,0})
		aadd(aCampos,{"NIRE"      ,"C",011,0})
		aadd(aCampos,{"DTRE"      ,"D",008,0})
		aadd(aCampos,{"NOME"      ,"C",250,0})
		aadd(aCampos,{"FANTASIA"  ,"C",250,0})
		aadd(aCampos,{"CEP"       ,"C",008,0})
		aadd(aCampos,{"ENDER"     ,"C",250,0})
		aadd(aCampos,{"NUM"       ,"C",006,0})
		aadd(aCampos,{"COMPL"     ,"C",250,0})
		aadd(aCampos,{"BAIRRO"    ,"C",250,0})
		aadd(aCampos,{"MUN"       ,"C",250,0})
		aadd(aCampos,{"CEP_CP"    ,"C",008,0})
		aadd(aCampos,{"CP"        ,"C",250,0})
		aadd(aCampos,{"DDD"       ,"C",003,0})
		aadd(aCampos,{"FONE"      ,"C",015,0})
		aadd(aCampos,{"FAX"       ,"C",015,0})
		aadd(aCampos,{"EMAIL"     ,"C",250,0})
		aadd(aCampos,{"CNAE"      ,"C",007,0})
						
		aadd(aIndices,{cUnique,"PK"})

	Case cTable == "SPED001B"
		cUnique := "ID_ENT+ENT_REF"
		
		aadd(aCampos,{"ID_ENT"    ,"C",006,0})
		aadd(aCampos,{"ENT_REF"   ,"C",002,0})
		aadd(aCampos,{"INSCR"     ,"C",250,0})
		
		aadd(aIndices,{cUnique,"PK"})

	Case cTable == "SPED050"
		cUnique := "ID_ENT+NFE_ID"
		
		aadd(aCampos,{"ID_ENT    ","C",006,0})
		aadd(aCampos,{"NFE_ID    ","C",250,0})
		aadd(aCampos,{"DATE_NFE  ","D",008,0})	//DATA QUE O TSS RECEBEU A NOTA DO ERP
		aadd(aCampos,{"TIME_NFE  ","C",008,0})	//HORA QUE O TSS RECEBEU A NOTA DO ERP
		aadd(aCampos,{"XML_ERP   ","M",010,0})
		aadd(aCampos,{"XML_SIG   ","M",010,0})
		aadd(aCampos,{"XML_SIGCAN","M",010,0})	
		aadd(aCampos,{"AMBIENTE  ","N",001,0})
		aadd(aCampos,{"MODALIDADE","N",001,0})
		aadd(aCampos,{"STATUS    ","N",001,0})
		aadd(aCampos,{"STATUSCANC","N",001,0})		
		aadd(aCampos,{"STATUSMAIL","N",001,0})		
		aadd(aCampos,{"NFE_PROT  ","C",015,0})
		aadd(aCampos,{"DELETEDATE","D",008,0})
		aadd(aCampos,{"EMAIL"     ,"C",250,0})
		aadd(aCampos,{"MODELO"    ,"C",002,0})
		aadd(aCampos,{"XML_DPEC  ","M",010,0})
		aadd(aCampos,{"CNPJDEST"  ,"C",014,0})
		aadd(aCampos,{"REG_DPEC  ","C",015,0})
		aadd(aCampos,{"STATUSDPEC","N",001,0})
		aadd(aCampos,{"XML_NSE   ","M",010,0})
		aadd(aCampos,{"NUM_NSE   ","C",015,0})
		aadd(aCampos,{"PRINT_DOC" ,"N",001,0})
		aadd(aCampos,{"PED_NFE"   ,"C",010,0})
		aadd(aCampos,{"PED_DPEC"  ,"C",010,0})
		aadd(aCampos,{"DATE_ENFE ","D",008,0})	//DATA QUE O TSS ENVIOU A NOTA PARA O ERP
		aadd(aCampos,{"TIME_ENFE ","C",008,0})	//HORA QUE O TSS ENVIOU A NOTA PARA O ERP
		aadd(aCampos,{"DATE_GXML ","D",008,0})	//DATA QUE O XML FOI GERADO PELO CLIENTE
		aadd(aCampos,{"TIME_GXML ","C",008,0})	//HORA QUE O XML FOI GERADO PELO CLIENTE
		aadd(aCampos,{"RESP_GXML ","C",060,0})	//RESPONSAVEL PELO PELA GERACAO DO XML NA DATA E HORA ACIMA 
				
		aadd(aIndices,{cUnique,"PK"})
		aadd(aIndices,{"ID_ENT+DTOS(DATE_NFE)+TIME_NFE","01"})

Case cTable == "SPED052"
		cUnique := "ID_ENT+STR(LOTE,15)"
		
		aadd(aCampos,{"ID_ENT    ","C",006,0})
		aadd(aCampos,{"LOTE      ","N",015,0})
		aadd(aCampos,{"AMBIENTE  ","N",001,0})
		aadd(aCampos,{"MODALIDADE","N",001,0})
		aadd(aCampos,{"DATE_LOTE ","D",008,0})	//DATA QUE O TSS MONTOU O LOTE
		aadd(aCampos,{"TIME_LOTE ","C",008,0})	//HORA QUE O TSS MONTOU O LOTE
		aadd(aCampos,{"CSTAT_SEF" ,"C",003,0})
		aadd(aCampos,{"XMOT_SEF"  ,"C",250,0})	
		aadd(aCampos,{"RECIBO_SEF","N",015,0})	//RECIBO DA SEFAZ
		aadd(aCampos,{"DTREC_SEF" ,"D",008,0})	//DATA RECEBIMENTO SEFAZ
		aadd(aCampos,{"HRREC_SEF" ,"C",008,0})	//HORA RECEBIMENTO SEFAZ
		aadd(aCampos,{"TEMPO_SEF" ,"N",004,0})
		aadd(aCampos,{"CSTAT_SEFR","C",003,0})
		aadd(aCampos,{"XMOT_SEFR ","C",250,0})
		aadd(aCampos,{"STATUS    ","N",001,0})
		aadd(aCampos,{"XML_LOTE  ","M",010,0})
		aadd(aCampos,{"NRCNS_SEFR","N",005,0})
		aadd(aCampos,{"MODELO"    ,"C",002,0})
		aadd(aCampos,{"DPEC      ","M",010,0})
		aadd(aCampos,{"HRREC_DPEC","C",008,0})
		aadd(aCampos,{"DTREC_DPEC","D",008,0})			                         
		aadd(aCampos,{"RECIBO_NSE","C",050,0})		
		aadd(aCampos,{"XML_ERROS ","M",010,0})
		aadd(aIndices,{cUnique,"PK"})
				
	Case cTable == "SPED054"
		cUnique := "ID_ENT+STR(LOTE,15)+NFE_ID"
		
		aadd(aCampos,{"ID_ENT    ","C",006,0})
		aadd(aCampos,{"LOTE      ","N",015,0})
		aadd(aCampos,{"NFE_ID    ","C",250,0})
		aadd(aCampos,{"NFE_CHV   ","C",044,0})
		aadd(aCampos,{"CSTAT_SEFR","C",003,0})	//STATUS PROCESSAMENTO SEFAZ
		aadd(aCampos,{"XMOT_SEFR ","C",250,0})	//DESCRICAO DO RESULTADO DE PROCESSAMENTO
		aadd(aCampos,{"DTREC_SEFR","D",008,0})	//DATA PROCESSAMENTO SEFAZ
		aadd(aCampos,{"HRREC_SEFR","C",008,0})	//HORA PROCESSAMENTO SEFAZ
		aadd(aCampos,{"NFE_PROT  ","C",015,0})
		aadd(aCampos,{"XML_PROT  ","M",010,0})	
		aadd(aCampos,{"DTVER_LOTP","D",008,0})	//DATA QUE O TSS VERIFICA OS LOTES PENDENTES
		aadd(aCampos,{"HRVER_LOTP","C",008,0})	//HORA QUE O TSS VERIFICA OS LOTES PENDENTES
		aadd(aCampos,{"TSMJOBEXP ","C",001,0})
				
		aadd(aIndices,{cUnique,"PK"})
		aadd(aIndices,{"ID_ENT+STR(LOTE,15)+NFE_CHV","02"})
		aadd(aIndices,{"ID_ENT+NFE_ID+CSTAT_SEFR","03"})

	Case cTable == "SPED056"
		cUnique := "ID_ENT+CODCONT"
		
		aadd(aCampos,{"ID_ENT    ","C",006,0})
		aadd(aCampos,{"CODCONT   ","N",015,0})
		aadd(aCampos,{"DATE_INI  ","D",008,0})	//DATA DE ENTRADA EM CONTIGENCIA
		aadd(aCampos,{"TIME_INI  ","C",008,0})	//HORA DE ENTRADA EM CONTIGENCIA
		aadd(aCampos,{"DATE_FIM  ","D",008,0})	//DATA DE SAIDA DA CONTIGUENCIA
		aadd(aCampos,{"TIME_FIM  ","C",008,0})	//HORA DE SAIDA DA CONTIGUENCIA
		aadd(aCampos,{"MOTIVO"    ,"C",255,0})	
		
		aadd(aCampos,{"TOTVSCOLAB","C",003,0}) //Flag TOTVS Colaboracao
		aadd(aIndices,{cUnique,"PK"})

	Case cTable == "SPED070"
		cUnique := "ID_ENT+TOTVSCOLAB+VERSAO+MODELO+AMBIENTE"
		
		aadd(aCampos,{"ID_ENT"		,"C",006,0})
		aadd(aCampos,{"XML_STATUS"	,"M",010,0})
		aadd(aCampos,{"TIMESTATUS"	,"C",012,0})
		aadd(aCampos,{"TOTVSCOLAB"	,"C",002,0})  
		aadd(aCampos,{"VERSAO"      ,"C",006,0})
		aadd(aCampos,{"MODELO"      ,"C",002,0})
		aadd(aCampos,{"AMBIENTE"	,"N",001,0})
		aadd(aIndices,{cUnique,"PK"})

	Case cTable == "SPED150"
		cUnique := "ID_ENT+STR(TPEVENTO,6)+STR(LOTE,15)+NFE_CHV+STR(SEQEVENTO,2)"

		aadd(aCampos,{"ID_ENT"		,"C",006,0})
		aadd(aCampos,{"ID_EVENTO"	,"C",054,0})		//ID DO EVENTO: ID + TPEVENTO + NFE_CHV + SEQEVENTO
		aadd(aCampos,{"LOTE"		,"N",015,0})
		aadd(aCampos,{"TPEVENTO"	,"N",006,0})
		aadd(aCampos,{"SEQEVENTO"	,"N",002,0})		
		aadd(aCampos,{"NFE_CHV"		,"C",044,0})
		aadd(aCampos,{"AMBIENTE"	,"N",001,0})
		aadd(aCampos,{"DATE_EVEN"	,"D",008,0})		//DATA QUE O TSS RECEBEU O EVENTO
		aadd(aCampos,{"TIME_EVEN"	,"C",008,0})		//HORA QUE O TSS RECEBEU O EVENTO
		aadd(aCampos,{"STATUS"		,"N",001,0})
		aadd(aCampos,{"DATE_TRANS"	,"D",008,0})		//DATA DA TRANSMISSAO DO EVENTO
		aadd(aCampos,{"TIME_TRANS"	,"C",008,0})		//HORA DA TRANSMISSAO DO EVENTO
		aadd(aCampos,{"DHREGEVEN"	,"C",030,0})		//DATA E HORA DO REGISTRO DO EVENTO
		aadd(aCampos,{"VERSAO"	 	,"N",004,2})		//VERSAO DO LEIAUTE
		aadd(aCampos,{"VEREVENTO" 	,"N",004,2})		//VERSAO DO EVENTO
		aadd(aCampos,{"VERTPEVEN" 	,"N",004,2})		//VERSAO DO TIPO DO EVENTO
		aadd(aCampos,{"VERAPLIC" 	,"C",020,0})		//VERSAO DA APLICACAO
		aadd(aCampos,{"CORGAO"	  	,"N",002,0})		//CODIGO DA UF QUE REGISTROU O EVENTO. 
		aadd(aCampos,{"CSTATENV"	,"N",003,0}) 		//CODIGO DO STATUS DA RESPOSTA DO ENVIO DO LOTE
		aadd(aCampos,{"CMOTENV"		,"C",MAXINDEX,0})	//DESCRICAO DO MOTIVO DO STATUS DA RESPOSTA DO ENVIO DO LOTE
		aadd(aCampos,{"CSTATEVEN"	,"N",003,0}) 		//CODIGO DO STATUS DA RESPOSTA DO EVENTO
		aadd(aCampos,{"CMOTEVEN"	,"C",MAXINDEX,0})	//DESCRICAO DO MOTIVO DO STATUS DA RESPOSTA DO EVENTO
		aadd(aCampos,{"XML_ERP"		,"M",010,0})		//XML ERP
		aadd(aCampos,{"XML_SIG"		,"M",010,0})		//XML ASSINADO
		aadd(aCampos,{"XML_RET"		,"M",010,0})		//XML RETORNO
		aadd(aCampos,{"PROTOCOLO"	,"N",015,0})		//NUMERO DO PROTOCOLO
				
		aadd(aIndices,{cUnique,"PK"})
		aadd(aIndices,{"ID_ENT+ID_EVENTO","02"})

	// Tabela de Historico de Eventos
	Case cTable == "SPED154"
		
		aadd(aCampos,{"ID_ENT"		,"C",006,0})
		aadd(aCampos,{"ID_EVENTO"	,"C",054,0})		//ID DO EVENTO: ID + TPEVENTO + NFE_CHV + SEQEVENTO
		aadd(aCampos,{"LOTE"		,"N",015,0})
		aadd(aCampos,{"TPEVENTO"	,"N",006,0})
		aadd(aCampos,{"SEQEVENTO"	,"N",002,0})		
		aadd(aCampos,{"NFE_CHV"		,"C",044,0})
		aadd(aCampos,{"AMBIENTE"	,"N",001,0})
		aadd(aCampos,{"DATE_EVEN"	,"D",008,0})		//DATA QUE O TSS RECEBEU O EVENTO
		aadd(aCampos,{"TIME_EVEN"	,"C",008,0})		//HORA QUE O TSS RECEBEU O EVENTO
		aadd(aCampos,{"STATUS"		,"N",001,0})
		aadd(aCampos,{"DATE_TRANS"	,"D",008,0})		//DATA DA TRANSMISSAO DO EVENTO
		aadd(aCampos,{"TIME_TRANS"	,"C",008,0})		//HORA DA TRANSMISSAO DO EVENTO
		aadd(aCampos,{"DHREGEVEN"	,"C",030,0})		//DATA E HORA DO REGISTRO DO EVENTO
		aadd(aCampos,{"VERSAO"	 	,"N",004,2})		//VERSAO DO LEIAUTE
		aadd(aCampos,{"VEREVENTO" 	,"N",004,2})		//VERSAO DO EVENTO
		aadd(aCampos,{"VERTPEVEN" 	,"N",004,2})		//VERSAO DO TIPO DO EVENTO
		aadd(aCampos,{"VERAPLIC" 	,"C",020,0})		//VERSAO DA APLICACAO
		aadd(aCampos,{"CORGAO"	  	,"N",002,0})		//CODIGO DA UF QUE REGISTROU O EVENTO. 
		aadd(aCampos,{"CSTATENV"	,"N",003,0}) 		//CODIGO DO STATUS DA RESPOSTA DO ENVIO DO LOTE
		aadd(aCampos,{"CMOTENV"		,"C",MAXINDEX,0})	//DESCRICAO DO MOTIVO DO STATUS DA RESPOSTA DO ENVIO DO LOTE
		aadd(aCampos,{"CSTATEVEN"	,"N",003,0}) 		//CODIGO DO STATUS DA RESPOSTA DO EVENTO
		aadd(aCampos,{"CMOTEVEN"	,"C",MAXINDEX,0})	//DESCRICAO DO MOTIVO DO STATUS DA RESPOSTA DO EVENTO
		aadd(aCampos,{"XML_ERP"		,"M",010,0})		//XML ERP
		aadd(aCampos,{"XML_SIG"		,"M",010,0})		//XML ASSINADO
		aadd(aCampos,{"XML_RET"		,"M",010,0})		//XML RETORNO
		aadd(aCampos,{"PROTOCOLO"	,"N",015,0})		//NUMERO DO PROTOCOLO				

		aadd(aIndices,{"ID_ENT+ID_EVENTO","01"})

EndCase

Return {aCampos,aIndices}


/*
Funcao      : GeraRelUser
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar em TXT um relatorio de usuarios baseado no HD, Z05.
Autor       : Jean Victor Rocha.
Data/Hora   : 
Objetivo	: 
*/
*---------------------------------*
Static Function GeraRelUser()
*---------------------------------*
If FILE("\MIGRACAO\USERS.TXT")
	FErase("\MIGRACAO\USERS.TXT")
EndIF

If Select("TMP_USER") > 0
	TMP_USER->(DbCloseArea())	               
EndIf
cQry:=""
cQry+="	SELECT Z05.Z05_EMAIL,"
cQry+="		CASE Z05.Z05_CARGO WHEN '01' THEN 'PRESIDENTE' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '02' THEN 'VICE PRESIDENTE' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '03' THEN 'DIRETOR' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '04' THEN 'GERENTE' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '05' THEN 'SUPERVISOR' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '06' THEN 'COORDENADOR' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '07' THEN 'ANALISTA' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '08' THEN 'ASSISTENTE'ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '09' THEN 'ESTAGIARIO' ELSE"
cQry+="		CASE Z05.Z05_CARGO WHEN '11' THEN 'TRAINEE'"
//cQry+="	CASE Z05.Z05_CARGO WHEN '10' THEN 'RECEPCIONISTA' ELSE"
cQry+="		ELSE Z05.Z05_CARGO"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END"
cQry+="		END AS 'CARGO',Z05.Z05_DEPTO,X5_DESCRI"
cQry+="		FROM Z05010 Z05 LEFT JOIN Z08010 Z08 ON Z08.Z08_FUNC = Z05.Z05_EMAIL"
cQry+="		JOIN"
cQry+="		("
cQry+="		SELECT X5_CHAVE,X5_DESCRI FROM SX5010 WHERE X5_TABELA = 'Z2' AND D_E_L_E_T_ <> '*'"
cQry+="		) SX5 ON Z05.Z05_DEPTO=SX5.X5_CHAVE"
cQry+="		WHERE Z05.D_E_L_E_T_ = ''"
cQry+="		AND Z08.D_E_L_E_T_ = ''"
cQry+="		AND Z08.Z08_EMP IN ("

For i:=1 to len(aEmps)
	cQry += "'"+aEmps[i]+"',"
Next i

cQry := LEFT(cQry,LEN(cQry)-1)

cQry+="		)"
cQry+="		GROUP BY Z05.Z05_EMAIL, Z05.Z05_CARGO,Z05.Z05_DEPTO,SX5.X5_DESCRI"
cQry+="		ORDER BY Z05.Z05_EMAIL"

nConWall := TCLink("MSSQL7/GTHD","10.0.30.05",7890) 

TCQuery cQry ALIAS "TMP_USER" NEW

cTxt := ""
TMP_USER->(DbGoTop())
While TMP_USER->(!EOF())
	cTxt += ALLTRIM(TMP_USER->Z05_EMAIL)+";"+;
			ALLTRIM(TMP_USER->CARGO)+";"+;
			ALLTRIM(TMP_USER->Z05_DEPTO)+";"+;
			ALLTRIM(TMP_USER->X5_DESCRI)+CHR(13)+CHR(10)
	TMP_USER->(DbSkip())
EndDo

If !EMPTY(cTxt)
	cTxt := "EMAIL;CARGO;DEPTO;DESCRI"+CHR(13)+CHR(10) + cTxt
	nHandle:=FCreate("\MIGRACAO\USERS.TXT", FC_NORMAL)
	FWrite(nHandle,cTxt)
	FClose(nHandle)
EndIF

Return .T.