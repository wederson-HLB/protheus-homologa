#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USX5004
Parametros  : Nil                      
Objetivos   : Atualiza códigos de serviços da Prefeitura da tabela generica 60 da SX5
Autor       : Anderson Arrais
Data/Hora   : 07/02/2018    
*/

*---------------------*
User Function USX5004()
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
                                         .F.) , oMainWnd:End()),;
                                         oMainWnd:End())
End Sequence

Return

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/
*----------------------------*
Static Function UPDProc(lEnd)
*----------------------------*

Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0


Local aChamados := { {05, {|| AtuSX5()}} } //05 - SIGAFAT

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
		 
		 	dbCloseArea()
		 EndIf
	  EndIf
   EndIf
End Sequence

Return(.T.)

/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 
Obs.        :
*/
*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Compartilhada
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

/*
Funcao      : AtuSX5
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua atualicao da tabela generica 60 da SX5
Obs.        :
*/
*------------------------------*
Static Function AtuSX5(oProcess)
*------------------------------*
Local cTexto := "" 
Local aInfo	:= {} 

	AAdd(aInfo, {"60","02660","ANÁLISE E DESENVOLVIMENTO DE SISTEMAS                  "})                    
	AAdd(aInfo, {"60","02668","PROGRAMAÇÃO.                                           "})  
	AAdd(aInfo, {"60","02684","PROCESSAMENTO, ARMAZENAMENTO OU HOSPEDAGEM DE DADOS, TE"})  
	AAdd(aInfo, {"60","02692","ELABORAÇÃO DE PROGRAMAS DE COMPUTADORES (SOFTWARE), INC"})  
	AAdd(aInfo, {"60","02800","LICENCIAMENTO OU CESSÃO DE DIREITO DE USO DE PROGRAMAS "})  
	AAdd(aInfo, {"60","02881","ASSESSORIA E CONSULTORIA EM INFORMÁTICA                "})  
	AAdd(aInfo, {"60","02919","SUPORTE TÉCNICO EM INFORMÁTICA, INCLUSIVE INSTALAÇÃO, C"})  
	AAdd(aInfo, {"60","02935","PLANEJAMENTO, CONFECÇÃO, MANUTENÇÃO E ATUALIZAÇÃO DE PÁ"})  
	AAdd(aInfo, {"60","02962","DISPONIBILIZAÇÃO, SEM CESSÃO DEFINITIVA, DE CONTEÚDOS D"})  
	AAdd(aInfo, {"60","02963","DISPONIBILIZAÇÃO, SEM CESSÃO DEFINITIVA, DE CONTEÚDOS D"})  
	AAdd(aInfo, {"60","02961","DISPONIBILIZAÇÃO, SEM CESSÃO DEFINITIVA, DE CONTEÚDOS D"})  
	AAdd(aInfo, {"60","08658","APLICAÇÃO DE TATUAGENS, PIERCINGS E CONGÊNERES         "})  
	AAdd(aInfo, {"60","01741","FLORESTAMENTO, REFLORESTAMENTO, SEMEADURA, ADUBAÇÃO, RE"})  
	AAdd(aInfo, {"60","06940","COMPOSIÇÃO GRÁFICA, INCLUSIVE COMPOSIÇÃO DE IMPRESSOS G"})  
	AAdd(aInfo, {"60","07324","GUINCHO INTRAMUNICIPAL, GUINDASTE E IÇAMENTO.          "})  
	AAdd(aInfo, {"60","02498","INSERÇÃO DE TEXTOS, DESENHOS E OUTROS MATERIAIS DE PROP"})  
	AAdd(aInfo, {"60","06581","TRASLADO INTRAMUNICIPAL DE CORPOS E PARTES DE CORPOS CA"})  
	AAdd(aInfo, {"60","06613","CESSÃO DE USO DE ESPAÇOS EM CEMITÉRIOS PARA SEPULTAMENT"})  
	AAdd(aInfo, {"60","03210","ADMINISTRAÇÃO DE BENEFÍCIOS RELATIVOS A PLANOS DE ASSIS"})  
	
SX5->(DbSetOrder(1))
For i:= 1 to Len(aInfo)
	// Busca o registro para atualicao
	lRec := !SX5->(DbSeek(xFilial("SX5")+aInfo[i][1]+aInfo[i][2]))
	SX5->(RecLock('SX5', lRec))
	SX5->X5_TABELA 	:= aInfo[i][1]
	SX5->X5_CHAVE 	:= aInfo[i][2]
	SX5->X5_DESCRI 	:= aInfo[i][3]
	SX5->X5_DESCSPA := aInfo[i][3]
	SX5->X5_DESCENG := aInfo[i][3]
	SX5->(MSUnlock())
	cTexto += "Atualizado SX5: " + aInfo[i][1] +" - "+ aInfo[i][2] + " com sucesso." + CRLF
Next i

Return cTexto

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