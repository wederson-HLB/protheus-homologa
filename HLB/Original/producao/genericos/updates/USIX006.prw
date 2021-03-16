#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Funcao      : USIX006
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Criação do indice N2_FILIAL+N2_CBASE+N2_ITEM+N2_TIPO+N2_SEQ na tabela SN2
Autor       : Anderson Arrais
Data	    : 03/12/2018
Revisão		:                    
*/

*---------------------*
User Function USIX006()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {"SN2"}
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
                                         .F.) ,oMainWnd:End()/*, Final("Atualização efetuada.")*/),;
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


Local aChamados := { {04, {|| AtuSX3()}}}

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )//exclusivo 
	   //dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .T. )//compartilhado
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

*----------------------------*
Static Function AtuSX3()
*----------------------------*
Local cTexto:=""

    //Cria as tabelas
    AtuTab(@cTexto)    
    
Return(cTexto)


//proposta
*------------------------------*
Static Function AtuTab(cTexto)
*------------------------------*
Local aSX7:= {}
Local aSX3:= {}
Local aSX2:= {}
Local aSIX:= {}
Local aSXB:= {}
Local aSX6:= {}

Local aDelSX7:={}

************************************************************************************************************************************
//{SIX} - Índice
//AADD(aSix,{INDICE,ORDEM,CHAVE,DESCRICAO,DESCSPA,DESCENG,PROPRI,F3,NICKNAME,SHOWPESQ})
 

AADD(aSix,{'SN2','2','N2_FILIAL+N2_CBASE+N2_ITEM+N2_TIPO+N2_SEQ','Cod Base Bem + Codigo Item + Tipo Ativo + Seq Aquisic','Cod Base Bem + Codigo Item + Tipo Ativo + Seq Aquisic','Cod Base Bem + Codigo Item + Tipo Ativo + Seq Aquisic','S','','','S'})


************************************************************************************************************************************
//{SX2} - Tabela
//AADD(aSX2,{X2_CHAVE,X2_PATH,X2_ARQUIVO,X2_NOME,X2_NOMESPA,X2_NOMEENG,X2_ROTINA,X2_MODO,X2_MODOUN,X2_MODOEMP,X2_DELET,X2_TTS,X2_UNICO,X2_PYME,X2_MODULO,X2_DISPLAY,X2_SYSOBJ,X2_USROBJ})



************************************************************************************************************************************
//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_TITSPA,X3_TITENG,X3_DESCRIC,X3_DESCSPA,X3_DESCENG,X3_PICTURE,X3_VALID,X3_USADO,X3_RELACAO,X3_F3,X3_NIVEL,X3_RESERV,X3_CHECK,X3_TRIGGER,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_OBRIGAT,X3_VLDUSER,X3_CBOX,X3_CBOXSPA,X3_CBOXENG,X3_PICTVAR,X3_WHEN,X3_INIBRW,X3_GRPSXG,X3_FOLDER,X3_PYME,X3_CONDSQL,X3_CHKSQL,X3_IDXSRV,X3_ORTOGRA,X3_IDXFLD,X3_TELA,X3_AGRUP})


****************************************************************************************************************************************** 
//{SX7} - Gatilhos
//AADD(aSX7,{X7_CAMPO,X7_SEQUENC,X7_REGRA,X7_CDOMIN,X7_TIPO,X7_SEEK,X7_ALIAS,X7_ORDEM,X7_CHAVE,X7_CONDIC,X7_PROPRI})

***************************************************************************************************************************************** 
//{SXB} - Consulta Padrão
//AADD(aSXB,{XB_ALIAS,XB_TIPO,XB_SEQ,XB_COLUNA,XB_DESCRI,XB_DESCSPA,XB_DESCENG,XB_CONTEM,XB_WCONTEM})

****************************************************************************************************************************************** 
//{SX6} - Parametros
//AADD(aSX6,{X6_FIL,X6_VAR,X6_TIPO,X6_DESCRIC,X6_DSCSPA,X6_DSCENG,X6_DESC1,X6_DSCSPA1,X6_DSCENG1,X6_DESC2,X6_DSCSPA2,X6_DSCENG2,X6_CONTEUD,X6_CONTSPA,X6_CONTENG,X6_PROPRI,X6_PYME,X6_VALID,X6_INIT,X6_DEFPOR,X6_DEFSPA,X6_DEFENG})

****************************************************************************************************************************************** 
//<Chamada das funções para a deleção dos dicionários -- **NÃO MEXER** >
DeletSx7(aDelSX7,cTexto)
//<FIM - Chamada das funções para a deleção dos dicionários >

//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx3(aSX3,@cTexto)

CriaSx2(aSX2,@cTexto)

CriaSix(aSIX,@cTexto) 

CriaSx7(aSX7,@cTexto)

CriaSxb(aSXB,@cTexto)

CriaSx6(aSX6,@cTexto)
//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*

Local lIncSX3	:= .F.

For i:=1 to len(aSX3)
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(!DbSeek(aSX3[i][3]))
		lIncSX3:=.T.
	else
		lIncSX3:=.F.
	endif
	
	Reclock("SX3",lIncSX3)
	
		SX3->X3_ARQUIVO	:= aSX3[i][1]
		SX3->X3_ORDEM	:= aSX3[i][2]
		SX3->X3_CAMPO	:= aSX3[i][3]
		SX3->X3_TIPO    := aSX3[i][4]
		SX3->X3_TAMANHO := val(aSX3[i][5])
		SX3->X3_DECIMAL := val(aSX3[i][6])
	
		if FieldPos("X3_TITULO")>0
			SX3->X3_TITULO:= aSX3[i][7]
		endif
		if FieldPos("X3_TITSPA")>0
			SX3->X3_TITSPA:= aSX3[i][8]
		endif
		if FieldPos("X3_TITENG")>0
			SX3->X3_TITENG:= aSX3[i][9]
		endif
		if FieldPos("X3_DESCRIC")>0
			SX3->X3_DESCRIC:= aSX3[i][10]
		endif
		if FieldPos("X3_DESCSPA")>0
			SX3->X3_DESCSPA:= aSX3[i][11]
		endif
		if FieldPos("X3_DESCENG")>0
			SX3->X3_DESCENG:= aSX3[i][12]
		endif
	
		SX3->X3_PICTURE := aSX3[i][13]
		SX3->X3_VALID   := aSX3[i][14]
		SX3->X3_USADO   := aSX3[i][15]
		SX3->X3_RELACAO := aSX3[i][16]
		SX3->X3_F3      := aSX3[i][17]
		SX3->X3_NIVEL   := val(aSX3[i][18])
		SX3->X3_RESERV  := aSX3[i][19]
		SX3->X3_CHECK   := aSX3[i][20]
		SX3->X3_TRIGGER := aSX3[i][21]
		SX3->X3_PROPRI  := aSX3[i][22]
		SX3->X3_BROWSE  := aSX3[i][23]
		SX3->X3_VISUAL  := aSX3[i][24]
		SX3->X3_CONTEXT := aSX3[i][25]
		SX3->X3_OBRIGAT := aSX3[i][26]
		SX3->X3_VLDUSER := aSX3[i][27]
		SX3->X3_CBOX    := aSX3[i][28]
		SX3->X3_CBOXSPA := aSX3[i][29]
		SX3->X3_CBOXENG := aSX3[i][30]
		SX3->X3_PICTVAR := aSX3[i][31]
		SX3->X3_WHEN    := aSX3[i][32]
		SX3->X3_INIBRW  := aSX3[i][33]
		SX3->X3_GRPSXG  := aSX3[i][34]
		SX3->X3_FOLDER  := aSX3[i][35]
		SX3->X3_PYME    := aSX3[i][36]
		SX3->X3_CONDSQL := aSX3[i][37]
		SX3->X3_CHKSQL  := aSX3[i][38]
		SX3->X3_IDXSRV  := aSX3[i][39]
		SX3->X3_ORTOGRA := aSX3[i][40]
		SX3->X3_IDXFLD  := aSX3[i][41]
		SX3->X3_TELA    := aSX3[i][42]
		SX3->X3_AGRUP   := aSX3[i][43]
	
	SX3->(MsUnlock())

	if lIncSX3
		cTexto += "Incluido no SX3 - o campo:"+aSX3[i][3]+NL
	else
		cTexto += "Alterado no SX3 - o campo:"+aSX3[i][3]+NL
	endif
	
Next	

Return


*-----------------------------------*
Static Function CriaSx2(aSX2,cTexto)
*-----------------------------------*

Local lIncSX2	:= .F.

For i:=1 to len(aSX2)
	
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	if SX2->(!DbSeek(aSX2[i][1]))
		lIncSX2:=.T.
	else
		lIncSX2:=.F.
	endif  
	
	Reclock("SX2",lIncSX2)

		SX2->X2_CHAVE	:= aSX2[i][1]
		SX2->X2_PATH	:= aSX2[i][2]
		SX2->X2_ARQUIVO	:= aSX2[i][3]
		SX2->X2_NOME	:= aSX2[i][4]
		if FieldPos("X2_NOMESPA")>0
			SX2->X2_NOMESPA	:= aSX2[i][5]
		endif
		
		if FieldPos("X2_NOMEENG")>0
			SX2->X2_NOMEENG	:= aSX2[i][6]
		endif
		SX2->X2_ROTINA	:= aSX2[i][7]
		SX2->X2_MODO	:= aSX2[i][8]
		SX2->X2_MODOUN	:= aSX2[i][9]
		SX2->X2_MODOEMP	:= aSX2[i][10]
		SX2->X2_DELET	:= val(aSX2[i][11])
		SX2->X2_TTS		:= aSX2[i][12]
		SX2->X2_UNICO	:= aSX2[i][13]
		SX2->X2_PYME	:= aSX2[i][14]
		SX2->X2_MODULO	:= val(aSX2[i][15])
		SX2->X2_DISPLAY	:= aSX2[i][16]
		SX2->X2_SYSOBJ	:= aSX2[i][17]
		SX2->X2_USROBJ	:= aSX2[i][18]
	
	SX2->(MsUnlock())

	if lIncSX2
		cTexto += "Incluido no SX2 - a tabela:"+aSX2[i][1]+NL
	else
		cTexto += "Alterado no SX2 - a tabela:"+aSX2[i][1]+NL
	endif
	
Next	

Return

*-----------------------------------*
Static Function CriaSix(aSix,cTexto)
*-----------------------------------*

Local lIncSix	:= .F.

For i:=1 to len(aSix)

	DbSelectArea("SIX")
	SIX->(DbSetOrder(1))
	if SIX->(!DbSeek(PADR(aSix[i][1],3)+aSix[i][2]))
		lIncSIX:=.T.
	else
		lIncSIX:=.F.
	endif
	
	Reclock("SIX",lIncSIX)
		
		SIX->INDICE		:= aSix[i][1]
		SIX->ORDEM		:= aSix[i][2]
		SIX->CHAVE  	:= aSix[i][3]
		SIX->DESCRICAO  := aSix[i][4]
		SIX->DESCSPA	:= aSix[i][5]
		SIX->DESCENG	:= aSix[i][6]
		SIX->PROPRI		:= aSix[i][7]
		SIX->&('F3')	:= aSix[i][8]
		SIX->NICKNAME	:= aSix[i][9]
		SIX->SHOWPESQ	:= aSix[i][10]

	SIX->(MsUnlock())	
	
	if lIncSix
		cTexto += "Incluido no SIX - o indice:"+aSix[i][1]+aSix[i][2]+NL
	else
		cTexto += "Alterado no SIX - o indice:"+aSix[i][1]+aSix[i][2]+NL
	endif
	
Next

Return

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

*-----------------------------------*
Static Function CriaSxb(aSXB,cTexto)
*-----------------------------------*

Local lIncSXB	:= .F.

For i:=1 to len(aSXB)

	DbSelectArea("SXB")
	SXB->(DbSetOrder(1))
	if SXB->(!DbSeek(PADR(alltrim(aSXB[i][1]),6)+PADR(alltrim(aSXB[i][2]),1)+PADR(alltrim(aSXB[i][3]),2)+aSXB[i][4]))
		lIncSXB:=.T.
	else
		lIncSXB:=.F.
	endif
	
	Reclock("SXB",lIncSXB)
	
		SXB->XB_ALIAS	:= aSXB[i][1]
		SXB->XB_TIPO	:= aSXB[i][2]
		SXB->XB_SEQ		:= aSXB[i][3]
		SXB->XB_COLUNA	:= aSXB[i][4]
		SXB->XB_DESCRI	:= aSXB[i][5]
		SXB->XB_DESCSPA	:= aSXB[i][6]
		SXB->XB_DESCENG	:= aSXB[i][7]
		SXB->XB_CONTEM	:= aSXB[i][8]
		SXB->XB_WCONTEM	:= aSXB[i][9]

	SXB->(MsUnlock())	
	
	if lIncSXB
		cTexto += "Incluido no SXB - a consulta:"+aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]+NL
	else
		cTexto += "Alterado no SXB - a consulta:"+aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]+NL
	endif
	
Next

Return 

*-----------------------------------*
Static Function CriaSx6(aSX6,cTexto)
*-----------------------------------*

Local lIncSX6	:= .F.

For i:=1 to len(aSX6)

	DbSelectArea("SXB")
	SX6->(DbSetOrder(1))
	if SX6->(!DbSeek(PADR(alltrim(aSX6[i][1]),2)+PADR(alltrim(aSX6[i][2]),10)))
		lIncSX6:=.T.
	else
		lIncSX6:=.F.
	endif
	
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
		SX6->X6_PYME	:=aSX6[i][17]
		SX6->X6_VALID	:=aSX6[i][18]
		SX6->X6_INIT	:=aSX6[i][19]
		SX6->X6_DEFPOR	:=aSX6[i][20]
		SX6->X6_DEFSPA	:=aSX6[i][21]
		SX6->X6_DEFENG	:=aSX6[i][22]

	SX6->(MsUnlock())	
	
	if lIncSX6
		cTexto += "Incluido no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL
	else
		cTexto += "Alterado no SX6 - o parametro:"+aSX6[i][1]+aSX6[i][2]+NL
	endif
	
Next

Return

*-----------------------------------*
Static Function DeletSx7(aSX7,cTexto)
*-----------------------------------*
Local lIncSX7	:= .F.

For i:=1 to len(aSX7)

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	if SX7->(DbSeek(PADR(aSX7[i][1],10)+aSX7[i][2]))

		Reclock("SX7",.F.)
	    	SX7->(DbDelete())
		SX7->(MsUnlock())	
		
		cTexto += "Deletado no SX7 - o gatilho:"+aSX7[i][1]+aSX7[i][2]+NL
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