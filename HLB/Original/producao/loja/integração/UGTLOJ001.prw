#INCLUDE "Protheus.ch"
/*
Funcao      : UGTLOJ001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Update para interface de loja.
Autor       : Jean Victor Rocha
Revisão		:
Data/Hora   : 06/08/2016
Módulo      : UPDATE
*/
*-----------------------*
User Function UGTLOJ001()
*-----------------------*
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
						{04, {|| UPDSAE()}} }

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
    
    //AOA - 15/09/2016 - Criar tabela Z99
	Aadd(aSX2,{"Z99","","Z99"+SM0->M0_CODIGO+"0","Log de Integracao XML Cupons","Log de Integracao XML Cupons","Log de Integracao XML Cupons","","C","","","S",7})

	SX2->(DbSetOrder(1))	
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

	aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
				"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
				"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
				"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

	//Capa Manut. Int. Beneficios
	aAdd(aSX3,{"SB1","","B1_P_CFTES"	,"C",03,0,"TES Cupom F.","TES Cupom F.","TES Cupom F.","TES Cupom F.","TES Cupom F.","TES Cupom F.","@!",'','€€€€€€€€€€€€€€ ',"" ,"SZ2",0,'þA',"","","U","N","A","R",'',"","","","","","","","","","N"})
	
	//AOA - 15/09/2016 - Criar tabela Z99
	aAdd(aSX3,{"Z99","","Z99_FILIAL","C",02,0,"Filial","Filial","Filial","Filial","Filial","Filial","@!",'','€€€€€€€€€€€€€€€',"" 	,""      ,1,'þA',"","","U","S","","",'',"","","","","","","","","",""})
	aAdd(aSX3,{"Z99","","Z99_DATA","D",08,0,"Data","Data","Data","Data","Data","Data","",'','€€€€€€€€€€€€€€ ',"" 	,""      ,0,'þA',"","","U","S","A","R",'',"","","","","","","","","",""})
	aAdd(aSX3,{"Z99","","Z99_LOG","C",200,0,"Log Retorno","Log Retorno","Log Retorno","Log Retorno","Log Retorno","Log Retorno","",'','€€€€€€€€€€€€€€ ',"" 	,""      ,0,'þA',"","","U","N","A","R",'',"","","","","","","","","",""})
	aAdd(aSX3,{"Z99","","Z99_ARQ","C",100,0,"Arquivo","Arquivo","Arquivo","Arquivo","Arquivo","Arquivo","@!",'','€€€€€€€€€€€€€€ ',"" 	,""      ,0,'þA',"","","U","N","A","R",'',"","","","","","","","","",""})
	aAdd(aSX3,{"Z99","","Z99_XML","M",10,0,"XML","XML","XML","XML","XML","XML","",'','€€€€€€€€€€€€€€ ',"" 	,""      ,0,'þA',"","","U","N","A","R",'',"","","","","","","","","",""})
	aAdd(aSX3,{"Z99","","Z99_IDINT","C",10,0,"Id. Integr","Id. Integr","Id. Integr","Id. Integr","Id. Integr","Id. Integr","",'','€€€€€€€€€€€€€€ ',"" 	,""      ,0,'þA',"","","U","N","A","R",'',"","","","","","","","","",""})

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

	ProcRegua(Len(aSX3))
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

	//Atualiza os campos de Log para que possam exibir no Browse da consulta de log.
	SX3->(DbSetOrder(2)) 
	If SX3->(DbSeek("Z99_DATA"))
		SX3->(RecLock("SX3",.F.))
		SX3->X3_BROWSE := "S"
		SX3->(MsUnlock())
	EndIf
	If SX3->(DbSeek("Z99_ARQ"))
		SX3->(RecLock("SX3",.F.))
		SX3->X3_BROWSE := "S"
		SX3->(MsUnlock())
	EndIf


	//Forca a atualização das tabelas que afetam a Loja.
	aTables := {"SA1","SL1","SL2","SL4","SFI","SB1","SAE","SLG","Z99"}
	for i:=1 to Len(aTables)
		ChkFile(aTables[i])
		aAdd(aArqUpd,aTables[i])
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
	aSIXEstrut:= {"INDICE","ORDEM","CHAVE"	   						,"DESCRICAO"				,"DESCSPA"		   			,"DESCENG"		  			,"PROPRI","F3","NICKNAME","SHOWPESQ"}
	
	//AOA - 15/09/2016 - Criar tabela Z99
	aadd(aSIX,	 {"Z99"   ,"1"    ,"Z99_FILIAL+Z99_IDINT"  			,"Filial + Id.Integr. "	  	,"Filial + Id.Integr. "		,"Filial + Id.Integr. "		,"U"     ,""  ,""		 ,"N"       })

	ProcRegua(Len(aSIX))
	dbSelectArea("SIX")
	SIX->(DbSetOrder(1))	
	For i:= 1 To Len(aSIX)
		RecLock("SIX", !SIX->(DbSeek(aSIX[i,1])) )
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
Funcao      : UPDSAE
Autor  		: Jean Victor Rocha
Data     	: 08/08/2016
Objetivos   : Atualização da tabela SAE
*/
*----------------------*
Static Function UPDSAE()
*----------------------*
Local aUpd := ""
       
//CODIGO = Codigo + Tipo cartão
//DESCR = Descrição
//TIPO = Tipo cartão

aAdd(aUpd,{'01C','Administradora de Cartões Sicr'	,'CC'})
aAdd(aUpd,{'02C','Administradora de Cartões Sicr'	,'CC'})
aAdd(aUpd,{'03C','Banco American Express S/A - A'	,'CC'})
aAdd(aUpd,{'04C','BANCO GE - CAPITAL '				,'CC'})
aAdd(aUpd,{'05C','BANCO SAFRA S/A '					,'CC'})
aAdd(aUpd,{'06C','BANCO TOPÁZIO S/A '				,'CC'})
aAdd(aUpd,{'07C','BANCO TRIANGULO S/A '				,'CC'})
aAdd(aUpd,{'08C','BIGCARD Adm. de Convenios e Se'	,'CC'})
aAdd(aUpd,{'09C','BOURBON Adm. de Cartões de Cré'	,'CC'})
aAdd(aUpd,{'10C','CABAL Brasil Ltda.'				,'CC'})
aAdd(aUpd,{'11C','CETELEM Brasil S/A - CFI '		,'CC'})
aAdd(aUpd,{'12C','CIELO S/A '						,'CC'})
aAdd(aUpd,{'13C','CREDI 21 Participações Ltda.'		,'CC'})
aAdd(aUpd,{'14C','ECX CARD Adm. e Processadora d'	,'CC'})
aAdd(aUpd,{'15C','Empresa Bras. Tec. Adm. Conv. '	,'CC'})
aAdd(aUpd,{'16C','EMPÓRIO CARD LTDA '				,'CC'})
aAdd(aUpd,{'17C','FREEDDOM e Tecnologia e Serviç'	,'CC'})
aAdd(aUpd,{'18C','FUNCIONAL CARD LTDA.'	   			,'CC'})
aAdd(aUpd,{'19C','HIPERCARD Banco Multiplo S/A '	,'CC'})
aAdd(aUpd,{'20C','MAPA Admin. Conv. e Cartões Lt'	,'CC'})
aAdd(aUpd,{'21C','Novo Pag Adm. e Proc. de Meios'	,'CC'})
aAdd(aUpd,{'22C','PERNAMBUCANAS Financiadora S/A'	,'CC'})
aAdd(aUpd,{'23C','POLICARD Systems e Serviços Lt'	,'CC'})
aAdd(aUpd,{'24C','PROVAR Negócios de Varejo Ltda'	,'CC'})
aAdd(aUpd,{'25C','REDECARD S/A'						,'CC'})
aAdd(aUpd,{'26C','RENNER Adm. Cartões de Crédito'	,'CC'})
aAdd(aUpd,{'27C','RP Administração de Convênios '	,'CC'})
aAdd(aUpd,{'28C','SANTINVEST S/A Crédito'			,'CC'})
aAdd(aUpd,{'29C','SODEXHO Pass do Brasil Serviço'	,'CC'})
aAdd(aUpd,{'30C','SOROCRED Meios de Pagamentos L'	,'CC'})
aAdd(aUpd,{'31C','Tecnologia Bancária S/A - TECB'	,'CC'})
aAdd(aUpd,{'32C','TICKET Serviços S/A'	   			,'CC'})
aAdd(aUpd,{'33C','TRIVALE Administração Ltda. '		,'CC'})
aAdd(aUpd,{'34C','Unicard Banco Múltiplo S/A - T'	,'CC'})
aAdd(aUpd,{'01D','Administradora de Cartões Sicr'	,'CD'})
aAdd(aUpd,{'02D','Administradora de Cartões Sicr'	,'CD'})
aAdd(aUpd,{'03D','Banco American Express S/A - A'	,'CD'})
aAdd(aUpd,{'04D','BANCO GE - CAPITAL '				,'CD'})
aAdd(aUpd,{'05D','BANCO SAFRA S/A '					,'CD'})
aAdd(aUpd,{'06D','BANCO TOPÁZIO S/A '				,'CD'})
aAdd(aUpd,{'07D','BANCO TRIANGULO S/A '				,'CD'})
aAdd(aUpd,{'08D','BIGCARD Adm. de Convenios e Se'	,'CD'})
aAdd(aUpd,{'09D','BOURBON Adm. de Cartões de Cré'	,'CD'})
aAdd(aUpd,{'10D','CABAL Brasil Ltda.'				,'CD'})
aAdd(aUpd,{'11D','CETELEM Brasil S/A - CFI '		,'CD'})
aAdd(aUpd,{'12D','CIELO S/A '						,'CD'})
aAdd(aUpd,{'13D','CREDI 21 Participações Ltda.'		,'CD'})
aAdd(aUpd,{'14D','ECX CARD Adm. e Processadora d'	,'CD'})
aAdd(aUpd,{'15D','Empresa Bras. Tec. Adm. Conv. '	,'CD'})
aAdd(aUpd,{'16D','EMPÓRIO CARD LTDA '				,'CD'})
aAdd(aUpd,{'17D','FREEDDOM e Tecnologia e Serviç'	,'CD'})
aAdd(aUpd,{'18D','FUNCIONAL CARD LTDA.'				,'CD'})
aAdd(aUpd,{'19D','HIPERCARD Banco Multiplo S/A '	,'CD'})
aAdd(aUpd,{'20D','MAPA Admin. Conv. e Cartões Lt'	,'CD'})
aAdd(aUpd,{'21D','Novo Pag Adm. e Proc. de Meios'	,'CD'})
aAdd(aUpd,{'22D','PERNAMBUCANAS Financiadora S/A'	,'CD'})
aAdd(aUpd,{'23D','POLICARD Systems e Serviços Lt'	,'CD'})
aAdd(aUpd,{'24D','PROVAR Negócios de Varejo Ltda'	,'CD'})
aAdd(aUpd,{'25D','REDECARD S/A'						,'CD'})
aAdd(aUpd,{'26D','RENNER Adm. Cartões de Crédito'	,'CD'})
aAdd(aUpd,{'27D','RP Administração de Convênios '	,'CD'})
aAdd(aUpd,{'28D','SANTINVEST S/A Crédito'			,'CD'})
aAdd(aUpd,{'29D','SODEXHO Pass do Brasil Serviço'	,'CD'})
aAdd(aUpd,{'30D','SOROCRED Meios de Pagamentos L'	,'CD'})
aAdd(aUpd,{'31D','Tecnologia Bancária S/A - TECB'	,'CD'})
aAdd(aUpd,{'32D','TICKET Serviços S/A'				,'CD'})
aAdd(aUpd,{'33D','TRIVALE Administração Ltda. '		,'CD'})
aAdd(aUpd,{'001','CHEQUE'							,'CH'})
aAdd(aUpd,{'002','CREDITO'							,'CC'})
aAdd(aUpd,{'003','DEBITO'							,'CD'})

SAE->(DbSetOrder(1))
For i:=1 to Len(aUpd)
	lSeek := SAE->(DbSeek(xFilial("SAE")+aUpd[i][1]))
	SAE->(RecLock("SAE",!lSeek))
	SAE->AE_FILIAL	:= xFilial("SAE")
	SAE->AE_COD		:= aUpd[i][1]
	SAE->AE_DESC	:= aUpd[i][2]
	SAE->AE_TIPO	:= aUpd[i][3]
	SAE->(MsUnlock())
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