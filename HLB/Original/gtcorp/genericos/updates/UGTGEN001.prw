#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*
Funcao      : UGTGEN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Update para implantação da Rotina customizada de beneficios.
Autor       : Jean Victor Rocha.
Data/Hora   : 28/09/2012
*/
*----------------------*
User Function UGTGEN001()
*----------------------*
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
Local aChamados := { 	{04, {|| AtuSX2()}},;
						{04, {|| AtuSX3()}},;
						{04, {|| AtuSIX()}},;
						{04, {|| AtuSXB()}}}

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
  	     If !lCheck .and.;
  	     	Ascan(aAux,{ |x| LEFT(x,2)  == M0_CODIGO}) <> 0 .and.;
  	     	Ascan(aAux,{ |x| RIGHT(x,2) == M0_CODFIL}) <> 0 .and.;
  	     	Ascan(aRecnoSM0,{ |x| x[2]  == M0_CODIGO}) == 0 
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 ElseIf Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
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

/*
Funcao      : ATUSX2
Autor  		: Jean Victor Rocha
Data     	: 20/09/2012
Objetivos   : Atualização do Dicionario SX2.
*/
*----------------------*
Static Function ATUSX2()
*----------------------*
Local aSX2       := {}
Local aSX2Estrut := {}
Local lSX2	     := .F.
Local cTexto     := ""
Local cAlias     := "" 

	aSX2Estrut := 	{"X2_CHAVE","X2_PATH","X2_ARQUIVO","X2_NOME","X2_NOMESPA","X2_NOMEENG","X2_ROTINA","X2_MODO","X2_TTS","X2_UNICO","X2_PYME","X2_MODULO"}

	Aadd(aSX2,{"Z64","","Z64YY0"				,"Tabela Generica Beneficios"		,"Tabela Generica Beneficios"		,"Tabela Generica Beneficios"		,"","C","","","S",7})
	Aadd(aSX2,{"Z71","","Z71"+SM0->M0_CODIGO+"0","Funcionarios x Beneficios/Forn."	,"Funcionarios x Beneficios/Forn."	,"Funcionarios x Beneficios/Forn."	,"","E","","","S",7})

	SX2->(DbSetOrder(1))	
	If SX2->(DbSeek("ZX5"))
		RecLock("SX2",.F.)
		SX2->(DbDelete())		
		SX2->(MsUnlock())
	EndIf
	For i:= 1 To Len(aSX2)
		If !Empty(aSX2[i][1])
			lSX2	:= !SX2->(DbSeek(aSX2[i,1]))
			If !(aSX2[i,1]$cAlias)
				cAlias += aSX2[i,1]+"/"
				cTexto += "- SX2 Atualizado com sucesso. '"+ALLTRIM(aSX2[i,1])+"'"+ cAlias + CHR(10) + CHR(13)
			EndIf
			RecLock("SX2",lSX2)
			For j:=1 To Len(aSX2[i])
				If FieldPos(aSX2Estrut[j])>0 .And. aSX2[i,j] != Nil
					FieldPut(FieldPos(aSX2Estrut[j]),aSX2[i,j])
				EndIf
		    Next j
		    DbCommit()
		    MsUnlock()
		EndIf
	Next i
	
Return cTexto               

/*
Funcao      : ATUSX3
Autor  		: Jean Victor Rocha
Data     	: 20/09/2012
Objetivos   : Atualização do Dicionario SX3.
*/
*-----------------------*
Static Function ATUSX3()
*-----------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}

Local cReserv := cUsado := cNaoUsado := cRrvNUsado	:= 	cObrgNUsado	:=	""

	aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
				"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
				"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
				"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

	DbSelectArea("SX3") //X3_RESERV e X3_USADO de um campo Usado
	SX3->(DbSetOrder(2))     
	If SX3->(DBSEEK("RA_NOME" ))
		cReserv := SX3->X3_RESERV
		cUsado  := SX3->X3_USADO
		cObrg	:= SX3->X3_OBRIGAT
	EndIf
	IF SX3->(DBSEEK("W6_FILIAL"))//X3_USADO de um campo nao Usado.
		cNaoUsado	:=	SX3->X3_USADO
		cRrvNUsado	:=	SX3->X3_RESERV
		cObrgNUsado	:=	SX3->X3_OBRIGAT
	EndIf
	IF SX3->(DBSEEK("RA_DEMISSA"))//X3_USADO de um campo nao Usado.
		cNReserv := SX3->X3_RESERV
		cNUsado  := SX3->X3_USADO
		cNObrg	 :=	SX3->X3_OBRIGAT
	EndIf

	//Capa Manut. Int. Beneficios
	aAdd(aSX3,{"Z64","01","Z64_FILIAL" ,"C",02,0,"Filial"    ,"Filial"    ,"Filial"    ,"Filial"       ,"Filial"       ,"Filial"       ,""       ,'',cNaoUsado,""       ,""      ,1,cRrvNUsado,"","","U","S","A","R",cObrgNUsado,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z64","02","Z64_TABELA" ,"C",03,0,"Tabela"    ,"Tabela"    ,"Tabela"    ,"Tabela"       ,"Tabela"       ,"Tabela"       ,"@!"     ,'',cUsado   ,"" 		,""      ,1,cReserv   ,"","","U","S","A","R",cObrg         ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z64","03","Z64_CHAVE"  ,"C",10,0,"Chave"     ,"Chave"     ,"Chave"     ,"Chave"        ,"Chave"        ,"Chave"        ,"@!"     ,'',cUsado   ,""       ,""      ,1,cReserv   ,"","","U","S","A","R",cObrg         ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z64","04","Z64_DESCRI" ,"C",35,0,"Descrição" ,"Descrição" ,"Descrição" ,"Descrição"    ,"Descrição"    ,"Descrição"    ,"@!"     ,'',cUsado   ,""       ,""      ,1,cReserv   ,"","","U","S","A","R",cObrg         ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z64","05","Z64_CONT1"  ,"C",60,0,"Conteudo 1","Conteudo 1","Conteudo 1","Conteudo 1"   ,"Conteudo 1"   ,"Conteudo 1"   ,"@!"     ,'',cUsado   ,""       ,""      ,1,cReserv   ,"","","U","S","A","R",cObrg         ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z64","06","Z64_CONT2"  ,"C",60,0,"Conteudo 2","Conteudo 2","Conteudo 2","Conteudo 2"   ,"Conteudo 2"   ,"Conteudo 2"   ,"@!"     ,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z64","07","Z64_CONT3"  ,"C",60,0,"Conteudo 3","Conteudo 3","Conteudo 3","Conteudo 3"   ,"Conteudo 3"   ,"Conteudo 3"   ,"@!"     ,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z64","08","Z64_CONT4"  ,"C",60,0,"Conteudo 4","Conteudo 4","Conteudo 4","Conteudo 4"   ,"Conteudo 4"   ,"Conteudo 4"   ,"@!"     ,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z64","09","Z64_CONT5"  ,"C",60,0,"Conteudo 5","Conteudo 5","Conteudo 5","Conteudo 5"   ,"Conteudo 5"   ,"Conteudo 5"   ,"@!"     ,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   

	aAdd(aSX3,{"Z71","01","Z71_FILIAL","C",02,0,"Filial"    ,"Filial"    ,"Filial"    ,"Filial"       ,"Filial"       ,"Filial"       ,""			,'',cNaoUsado,""       ,""      ,1,cRrvNUsado,"","","U","S","A","R",cObrgNUsado,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z71","02","Z71_FORN"  ,"C",03,0,"Forn.Benef","Forn.Benef","Forn.Benef","Forn.Benef"   ,"Forn.Benef"   ,"Forn.Benef"   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z71","03","Z71_COD"   ,"C",10,0,"Cod.Benef.","Cod.Benef.","Cod.Benef.","Cod.Benef."   ,"Cod.Benef."   ,"Cod.Benef."   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z71","04","Z71_DESCR" ,"C",35,0,"Desc.Benef","Desc.Benef","Desc.Benef","Desc.Benef"   ,"Desc.Benef"   ,"Desc.Benef"   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z71","05","Z71_QTDE"  ,"N",02,0,"Qtde.Benef","Qtde.Benef","Qtde.Benef","Qtde.Benef"   ,"Qtde.Benef"   ,"Qtde.Benef"   ,"@E 99"		,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z71","06","Z71_VALOR" ,"N",06,2,"Valor B."  ,"Valor B."  ,"Valor B."  ,"Valor B."     ,"Valor B."     ,"Valor B."     ,"@E 999.99"	,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z71","07","Z71_MAT"   ,"C",06,0,"Matricula" ,"Matricula" ,"Matricula" ,"Matricula"    ,"Matricula"    ,"Matricula"    ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	
	ProcRegua(Len(aSX3))
	SX3->(DbSetOrder(1))
	If SX3->(DbSeek("ZX5"))
		While SX3->X3_ARQUIVO == "ZX5"
			RecLock("SX3",.F.)
			SX3->(DbDelete())		
			SX3->(MsUnlock())
			SX3->(DbSkip())
		EndDo
	EndIf

	SX3->(DbSetOrder(2))
	For i:= 1 To Len(aSX3)
		If !Empty(aSX3[i][1])
			lSX3	:= !DbSeek(aSX3[i,3])
			If !(aSX3[i,1]$cAlias)
				cAlias += aSX3[i,1]+"/"
				aAdd(aArqUpd,aSX3[i,1])
			EndIf
			RecLock("SX3",lSX3)
			For j:=1 To Len(aSX3[i])
				If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
				EndIf
			Next j
			cTexto += "- SX3 Atualizado com sucesso. '"+aSX3[i,3]+"'"+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
			IncProc("Atualizando Dicionario de Dados...") //
		EndIf
	Next i

Return cTexto

/*
Funcao      : ATUSIX
Autor  		: Jean Victor Rocha
Data     	: 20/09/2012
Objetivos   : Atualização do Dicionario SIX.
*/
*----------------------*
Static Function ATUSIX()
*----------------------*
Local cTexto    := ''
Local aSIXEstrut:= {}
Local aSIX      := {}
Local i, j
Local cAlias    := ''

	// Atualização dos indices na tabela SIX
	aSIXEstrut:= {"INDICE","ORDEM","CHAVE"							   			,"DESCRICAO"				 			,"DESCSPA"					   			,"DESCENG"					  			,"PROPRI","F3","NICKNAME","SHOWPESQ"}
	aadd(aSIX,	 {"Z64"   ,"1"    ,"Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_DESCRI"	,"Filial + Tabela + Chave + Descr"	  	,"Filial + Tabela + Chave + Descr"		,"Filial + Tabela + Chave + Descr"		,"U"     ,""  ,""		 ,"S"       })
	aadd(aSIX,	 {"Z64"   ,"2"    ,"Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_CONT1"	,"Filial + Tabela + Chave + Cont1"	  	,"Filial + Tabela + Chave + Cont1"		,"Filial + Tabela + Chave + Cont1"		,"U"     ,""  ,""		 ,"S"       })
	aadd(aSIX,	 {"Z64"   ,"3"    ,"Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_CONT2"	,"Filial + Tabela + Chave + Cont2"	  	,"Filial + Tabela + Chave + Cont2"		,"Filial + Tabela + Chave + Cont2"		,"U"     ,""  ,""		 ,"S"       })
	aadd(aSIX,	 {"Z64"   ,"4"    ,"Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_CONT3"	,"Filial + Tabela + Chave + Cont3"	  	,"Filial + Tabela + Chave + Cont3"		,"Filial + Tabela + Chave + Cont3"		,"U"     ,""  ,""		 ,"S"       })	

	aadd(aSIX,	 {"Z71"   ,"1"    ,"Z71_FILIAL+Z71_FORN+Z71_COD+Z71_MAT"		,"Filial +Forn.Benef + Cod.Benef. +MAT"	,"Filial + Forn.Benef + Cod.Benef. +MAT","Filial + Forn.Benef + Cod.Benef. +MAT","U"     ,""  ,""		 ,"S"       })
	aadd(aSIX,	 {"Z71"   ,"2"    ,"Z71_FILIAL+Z71_MAT+Z71_FORN+Z71_COD"		,"Filial +Maricula +Cod.Benef. + C.Forn","Filial +Maricula +Cod.Benef. + C.Forn","Filial +Maricula +Cod.Benef. + C.Forn","U"     ,""  ,""		 ,"S"       })
    
	SIX->(DbSetOrder(1))
	If SIX->(DbSeek("ZX5"))
		While SIX->INDICE == "ZX5"
			RecLock("SIX",.F.)
			SIX->(DbDelete())		
			SIX->(MsUnlock())
			SIX->(DbSkip())
		EndDo
	EndIf

	For i:= 1 To Len(aSIX)
		If SIX->(DbSeek(aSIX[i,1]))
			While SIX->(!EOF()) .and. SIX->INDICE == aSIX[i,1]
				RecLock("SIX",.F.)
				SIX->(DbDelete())
				SIX->(MsUnlock())
				SIX->(DbSkip())				
			EndDo
		EndIf
	Next i

	ProcRegua(Len(aSIX))
	dbSelectArea("SIX")
	SIX->(DbSetOrder(1))	
	For i:= 1 To Len(aSIX)
		RecLock("SIX",.T.)
		If UPPER(AllTrim(CHAVE)) != UPPER(Alltrim(aSIX[i,3]))
			aAdd(aArqUpd,aSIX[i,1])
			If !(aSIX[i,1]$cAlias)
				cAlias += aSIX[i,1]+"/"
			EndIf
			For j:=1 To Len(aSIX[i])
				If FieldPos(aSIXEstrut[j])>0
					FieldPut(FieldPos(aSIXEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			MsUnLock()
			cTexto  += "- SIX atualizado com sucesso. '"+aSix[i][1]+"-"+aSix[i][3]+"'"+CHR(13)+CHR(10)
		EndIf
		IncProc("Atualizando índices...")
	Next i

Return cTexto

/*
Funcao      : ATUSXB
Autor  		: Jean Victor Rocha
Data     	: 23/01/2013
Objetivos   : Atualização do Dicionario SXB.
*/
*----------------------*
Static Function ATUSXB()
*----------------------*
Local cTexto    := ''
Local aSXBEstrut:= {}
Local aSXB      := {}


aSXBEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ"	,"XB_COLUNA"	,"XB_DESCRI"	,"XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM"}

aAdd(aSXB, {"BENEFF","1","01","DB"	,"Codigo de fornecedor ","Codigo de fornecedor ","Codigo de fornecedor ","Z64"})
aAdd(aSXB, {"BENEFF","2","01","01"	,"Filial + Tabela + Ch ","Filial + Tabela + Ch ","Filial + Tabela + Ch ",""})
aAdd(aSXB, {"BENEFF","4","01","01"	,"Fornecedor "			,"Fornecedor "	   		,"Fornecedor "			,"Z64_CHAVE"})
aAdd(aSXB, {"BENEFF","4","01","02"	,"Descrição "			,"Descrição "	   		,"Descrição "			,"Z64_DESCRI"})
aAdd(aSXB, {"BENEFF","5","01",""	,""		  				,""		  				,""	  					,"Z64->Z64_CHAVE"})
aAdd(aSXB, {"BENEFF","6","01",""	,""						,""		 				,""	 					,"Z64->Z64_TABELA == 'COD'"})
aAdd(aSXB, {"BENEFB","1","01","DB"	,"Codigo do Beneficio "	,"Codigo do Beneficio "	,"Codigo do Beneficio "	,"Z64"})
aAdd(aSXB, {"BENEFB","2","01","01"	,"Filial + Tabela + Ch ","Filial + Tabela + Ch ","Filial + Tabela + Ch ",""})
aAdd(aSXB, {"BENEFB","4","01","01"	,"Beneficio "			,"Beneficio "	   		,"Beneficio "			,"Z64_DESCRI"})
aAdd(aSXB, {"BENEFB","4","01","02"	,"Descrição "			,"Descrição "			,"Descrição "			,"Z64_CONT1"})
aAdd(aSXB, {"BENEFB","5","01",""	,""	   					,""	  					,""	  					,"Z64->Z64_DESCRI"})
aAdd(aSXB, {"BENEFB","6","01",""	,""		 				,""	  					,""	 					,"U_SXBGEN004()"})

	ProcRegua(Len(aSXB))
	dbSelectArea("SXB")
	SXB->(DbSetOrder(1))//XB_ALIAS+XB_TIPO_XB_SEQ_XB_COLUNA	
	For i:= 1 To Len(aSXB)
		lSXB	:= !DbSeek(aSXB[i,1]+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
		RecLock("SXB",lSXB)
		For j:=1 To Len(aSXB[i])
			If FieldPos(aSXBEstrut[j])>0
				FieldPut(FieldPos(aSXBEstrut[j]),aSXB[i,j])
			EndIf
		Next j
		MsUnLock()
		cTexto  += "- SXB atualizado com sucesso. '"+aSXB[i][1]+"-"+aSXB[i][2]+"'"+CHR(13)+CHR(10)
		IncProc("Atualizando Consulta padrão...")
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