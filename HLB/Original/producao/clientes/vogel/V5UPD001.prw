#INCLUDE "Protheus.ch"

/*
Funcao      : V5UPD001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criação do Update : Projeto Vogel 
Autor       : Leandro Brito
Chamado		: 
Data/Hora   : 06/11/2015
*/
*---------------------*
User Function V5UPD001
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := { "SC5" , "SC6" , "SA1" , "SB1" , 'ZX2' , 'ZX3' , 'SF2' , 'SF1' , 'SE2' , 'SE1', 'SE5' , 'SD2' , 'SC7' , 'SA2' , 'ZX0' , 'ZX1' }
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
Local aChamados := {	{05, {|| AtuSX2()}} , {05, {|| AtuSX3()}} , {05, {|| AtuSix()}} ,{05, {|| AtuSX6()}} , {05, {|| AtuSX5()}}}

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Exclusivo
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
Funcao      : ATUSX2
Autor  		: Leandro Brito
Data     	: 06/11/2015 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
 Static Function ATUSX2()
*-------------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX2    := {}
Local cOrdem  := ''

DbSelectArea("SX2")

aEstrut:= { "X2_CHAVE","X2_PATH"  ,"X2_ARQUIVO"  ,"X2_NOME"   ,"X2_NOMESPA","X2_NOMEENG","X2_ROTINA" ,"X2_MODO" ,"X2_MODOUN" ,;
			"X2_MODOEMP","X2_DELET","X2_TTS","X2_UNICO","X2_PYME"  ,"X2_MODULO"  ,"X2_DISPLAY","X2_SYSOBJ"     ,"X2_USROBJ"  ,;
			"X2_POSLGT" ,"X2_CLOB"  ,"X2_AUTREC","X2_TAMFIL" ,"X2_TAMUN" ,"X2_TAMEMP" }
	

aAdd(aSX2,{"ZX0",'\SYSTEM\','ZX0'+cEmpAnt+'0' ,'Recebimento','Recebimento','Recebimento',""	,;
"E"	,"E"	,"E",0,"","","S",5,"" ,"","","1","1","1",0,0,0 } ) 

aAdd(aSX2,{"ZX1",'\SYSTEM\','ZX1'+cEmpAnt+'0' ,'Requisicoes','Requisicoes','Requisicoes',""	,;
"E"	,"E"	,"E",0,"","","S",5,"" ,"","","1","1","1",0,0,0 } ) 

aAdd(aSX2,{"ZX2",'\SYSTEM\','ZX2'+cEmpAnt+'0' ,'Log.Integracao                ','Log.Integracao              ','Log.Integracao                ',""	,;
"C"	,"C"	,"C",0,"","","S",5,"" ,"","","1","1","1",0,0,0 } ) 

aAdd(aSX2,{"ZX3",'\SYSTEM\','ZX3V50' ,'Amarracao Empresa x Serie','Amarracao Empresa x Serie','Amarracao Empresa x Serie',""	,;
"C"	,"C"	,"C",0,"","","S",5,"" ,"","","1","1","1",0,0,0 } )


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

Return cTexto 

/*
Funcao      : ATUSX2
Autor  		: Leandro Brito
Data     	: 06/11/2015 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
 Static Function ATUSIX()
*-------------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSIX    := {}
Local cOrdem  := ''

DbSelectArea("SIX")

aEstrut:= { "INDICE","ORDEM"  ,"CHAVE"  ,"DESCRICAO"   ,"DESCSPA","DESCENG","PROPRI" ,"F3" ,"NICKNAME" ,"SHOWPESQ" }

	
Aadd( aSix ,{ "ZX0" , "1" , "ZX0_FILIAL+ZX0_P_REF+ZX0_ITEM" , "Filial + Ref.Vogel+Item" , "Filial + Ref.Vogel+Item" , "Filial + Ref.Vogel+Item" , "U" , , "" , "S" } )  
Aadd( aSix ,{ "ZX1" , "1" , "ZX1_FILIAL+ZX1_P_REF+ZX1_ITEM" , "Filial + Ref.Vogel+Item" , "Filial + Ref.Vogel+Item" , "Filial + Ref.Vogel+Item" , "U" , , "" , "S" } ) 
Aadd( aSix ,{ "ZX2" , "1" , "ZX2_FILIAL+ZX2_COD" , "Filial + Cod" , "Filial + Cod" , "Filial + Cod" , "U" , , "" , "S" } ) 
Aadd( aSix ,{ "ZX2" , "2" , "ZX2_FILIAL+ZX2_ARQ" , "Filial + Arq" , "Filial + Arq" , "Filial + Arq" , "U" , , "" , "S" } ) 

Aadd( aSix ,{ "ZX3" , "1" , "ZX3_FILIAL+ZX3_EMPFIL+ZX3_TIPO" , "Filial + EmpFil + Tipo Prod" , "Filial + EmpFil + Tipo Prod" , "Filial + EmpFil + Tipo Prod" , "U" , , "" , "S" } ) 

Aadd( aSix ,{ "SC5" , "6" , "C5_FILIAL+C5_P_REF" , "Pedido Sistech" , "Pedido Sistech" , "Pedido Sistech" , "U" , , "SISTECH" , "S" } ) 


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

Return cTexto 

/*
Funcao      : ATUSX5
Autor  		: Leandro Brito
Data     	: 06/11/2015 
Objetivos   : Atualização do Dicionario SX5.
*/
*-------------------------*
 Static Function ATUSX5()
*-------------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX5    := {}
Local cOrdem  := '' 
Local cFilSx5 := xFilial( 'SX5' )

DbSelectArea("SX5")

aEstrut:= { "X5_FILIAL","X5_TABELA"  ,"X5_CHAVE"  ,"X5_DESCRI"   ,"X5_DESCSPA","X5_DESCENG" }

	
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "SF" , Len( SX5->X5_CHAVE ) ) , "FATURA" , "FATURA" , "FATURA" } ) 
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "SR" , Len( SX5->X5_CHAVE ) ) , "SERVICO" , "SERVICO" , "SERVICO" } ) 
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "ST" , Len( SX5->X5_CHAVE ) ) , "TELECOM" , "TELECOM" , "TELECOM" } ) 
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "RV" , Len( SX5->X5_CHAVE ) ) , "REVENDA" , "REVENDA" , "REVENDA" } ) 
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "JR" , Len( SX5->X5_CHAVE ) ) , "JUROS" , "JUROS" , "JUROS" } ) 
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "MT" , Len( SX5->X5_CHAVE ) ) , "MULTA" , "MULTA" , "MULTA" } )  
Aadd( aSX5 ,{ cFilSx5 , "02" , PadR( "SC" , Len( SX5->X5_CHAVE ) ) , "COMUNICACAO" , "COMUNICACAO" , "COMUNICACAO" } ) 
Aadd( aSX5 ,{ cFilSx5 , "42" , PadR( "NFSC" , Len( SX5->X5_CHAVE ) ) , "NOTA FISCAL DE SERVICO DE COMUNICACAO" , "NOTA FISCAL DE SERVICO DE COMUNICACAO" , "NOTA FISCAL DE SERVICO DE COMUNICACAO" } ) 
Aadd( aSX5 ,{ cFilSx5 , "42" , PadR( "NTST" , Len( SX5->X5_CHAVE ) ) , "NOTA FISCAL DE SERVICO DE TELECOMUNICACOES" , "NOTA FISCAL DE SERVICO DE TELECOMUNICACOES" , "NOTA FISCAL DE SERVICO DE TELECOMUNICACOES" } ) 


ProcRegua(Len(aSX5))
SX5->(DbSetOrder(1))
For i:= 1 To Len(aSX5)
	If !Empty(aSX5[i][2])
		If !(SX5->(DbSeek(aSX5[i][1]+aSX5[i][2]+aSX5[i][3])))
			RecLock("SX5",.T.)
			For j:=1 To Len(aSX5[i])
				If FieldPos(aEstrut[j])>0 .And. aSX5[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX5[i,j])
				EndIf
			Next j
			cTexto += "- Tabela SX5 " + aSX5[i][2] +" Chave " + aSX5[i][3] + " criado ."+ CHR(10) + CHR(13)
			DbCommit()
			MsUnlock()
		Else
			cTexto += "- Tabela SX5 " + aSX5[i][2] +" Chave " + aSX5[i][3] + " ja existe ."+ CHR(10) + CHR(13)
		EndIf		
	EndIf
Next i

Return cTexto

/*
Funcao      : ATUSX3
Autor  		: Leandro Brito
Data     	: 06/11/2015 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
 Static Function ATUSX3()
*-------------------------*
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSX3    := {}
Local aCpoWhe :={}
Local cOrdem  := ''              
Local nLenCampo := Len( SX3->X3_CAMPO )

DbSelectArea("SX3")

aCpoWhe :={ "A1_NOME","A1_PESSOA","A1_NREDUZ","A1_TIPO","A1_END","A1_COMPLEM","A1_EST","A1_BAIRRO","A1_CEP",;
			"A1_CGC","A1_NATUREZ","A1_COD_MUN","A1_MUN","A1_CONTA","A1_CODPAIS","A1_EMAIL","A1_TPESSOA"}

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}
	


cOrdem := NextOrdem( 'SA1' )
aAdd(aSX3,{"SA1",cOrdem,"A1_P_ID"	   		,"C",20,0,"Id.Cliente"	,"Id.Cliente"	,"Id.Cliente"	,"Id.Cliente"	,"Id.Cliente"	,"Id.Cliente"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})		

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SA1",cOrdem,"A1_TPESSOA"	   		,"C",02,0,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","","S","","",'',"","CI=Comercio/Industria;PF=Pessoa Fisica;OS=Prestacao de Servico;EP=Empresa Publica;CC=Comercio;AT=Ato Cotepe;ER=Emp Ret","","","","","","","","N"})		
	
cOrdem := NextOrdem( 'SB1' )
aAdd(aSX3,{"SB1",cOrdem,"B1_P_TIP"	   		,"C",01,0,"Prod.\Serv."	,"Prod.\Serv."	,"Prod.\Serv."	,"Prod.\Serv."	,"Prod.\Serv."	,"Prod.\Serv."	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","S=Sim;N=Nao","","","","","","","","N"})		

aAdd(aSX3,{"SC5",'03',"C5_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","S","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_CONSU"	   		,"C",01,0,"Consumo"	,"Consumo"	,"Consumo"	,"Consumo"	,"Consumo"	,"Consumo"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","S=Sim;N=Nao","","","","","","","","N"})		

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_BOL"	   		,"C",01,0,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","S=Sim;N=Nao","","","","","","","","N"})		

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_DTINI"	   		,"D",8,0,"Dt.Inicio"	,"Dt.Inicio"	,"Dt.Inicio"	,"Dt.Inicio"	,"Dt.Inicio"	,"Dt.Inicio"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_DTFIM"	   		,"D",8,0,"Dt.Final"	,"Dt.Final"	,"Dt.Final"	,"Dt.Final"	,"Dt.Final"	,"Dt.Final"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_AM"	   		,"C",7,0,"Ano\Mes Ref."	,"Ano\Mes Ref."	,"Ano\Mes Ref."	,"Ano\Mes Ref."	,"Ano\Mes Ref."	,"Ano\Mes Ref."	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'šA',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_CONTA"	   		,"C",15,0,"Conta Cons."	,"Conta Cons."	,"Conta Cons."	,"Conta Cons."	,"Conta Cons."	,"Conta Cons."	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_CID"	   		,"C",15,0,"Cid/Contrato"	,"Cid/Contrato"	,"Cid/Contrato"	,"Cid/Contrato"	,"Cid/Contrato"	,"Cid/Contrato"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_PROJ"	   		,"C",09,0,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_P_REG"	   		,"C",09,0,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC5",cOrdem,"C5_NATUREZ"	   		,"C",Len(SED->ED_CODIGO),0,"Natureza"	,"Natureza"	,"Natureza"	,"Natureza"			,"Natureza"	,"Natureza","@!","MaFisGet('NF_NATUREZA')",'€€€€€€€€€€€€€€',"" ,"SED",0,'þA',"","","U","N","A","R",'',"Vazio().Or.ExistCpo('SED',M->C5_NATUREZ,1)","","","","","","","","","N"})


cOrdem := NextOrdem( 'ZX2' )
aAdd(aSX3,{"ZX2",cOrdem,"ZX2_FILIAL"	   		,"C",02,0,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX2",cOrdem,"ZX2_COD"	   		,"C",09,0,"Codigo"	,"Codigo"	,"Codigo"	,"Codigo"	,"Codigo"	,"Codigo"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX2",cOrdem,"ZX2_ARQ"	   		,"C",60,0,"Arquivo"	,"Arquivo"	,"Arquivo"	,"Arquivo"	,"Arquivo"	,"Arquivo"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX2",cOrdem,"ZX2_DATA"	   		,"D",8,0,"Data"	,"Data"	,"Data"	,"Data"	,"Data"	,"Data"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX2",cOrdem,"ZX2_HORA"	   		,"C",08,0,"Hora"	,"Hora"	,"Hora"	,"Hora"	,"Hora"	,"Hora"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX2",cOrdem,"ZX2_USER"	   		,"C",15,0,"Usuario"	,"Usuario"	,"Usuario"	,"Usuario"	,"Usuario"	,"Usuario"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})


cOrdem := NextOrdem( 'ZX3' )
aAdd(aSX3,{"ZX3",cOrdem,"ZX3_FILIAL"	   		,"C",02,0,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX3",cOrdem,"ZX3_EMPFIL"	   		,"C",04,0,"EmpFil"	,"EmpFil"	,"EmpFil"	,"EmpFil"	,"EmpFil"	,"EmpFil"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX3",cOrdem,"ZX3_TIPO"	   		,"C",02,0,"Tipo Prod."	,"Tipo Prod."	,"Tipo Prod."	,"Tipo Prod."	,"Tipo Prod."	,"Tipo Prod."	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX3",cOrdem,"ZX3_SERIE"	   		,"C",03,0,"Serie"	,"Serie"	,"Serie"	,"Serie"	,"Serie"	,"Serie"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})


cOrdem := NextOrdem( 'SF2' )
aAdd(aSX3,{"SF2",cOrdem,"F2_P_SISTE"	   		,"C",01,0,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SF2",cOrdem,"F2_P_ENV"	   		,"C",01,0,"Envio Fatura"	,"Envio Fatura"	,"Envio Fatura"	,"Envio Fatura"	,"Envio Fatura"	,"Envio Fatura"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

aAdd(aSX3,{"SF2","07","F2_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","S","V","R",'',"","","","","","","","","","N"})


cOrdem := NextOrdem( 'SF1' )
aAdd(aSX3,{"SF1",cOrdem,"F1_P_SISTE"	   		,"C",01,0,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})


cOrdem := NextOrdem( 'SE1' )
aAdd(aSX3,{"SE1",cOrdem,"E1_P_SISTE"	   		,"C",01,0,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

aAdd(aSX3,{"SE1","14","E1_BAIXA"	   			,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,"S",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})

aAdd(aSX3,{"SE1","07","E1_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","S","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SE1",cOrdem,"E1_P_BOL"	   		,"C",01,0,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"Ger.Bol."	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","S=Sim;N=Nao","","","","","","","","N"})


cOrdem := NextOrdem( 'SE2' )
aAdd(aSX3,{"SE2",cOrdem,"E2_P_SISTE"	   		,"C",01,0,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

aAdd(aSX3,{"SE2","07","E2_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","S","V","R",'',"","","","","","","","","","N"})


cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SE5",cOrdem,"E5_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := NextOrdem( 'SE5' )
aAdd(aSX3,{"SE5",cOrdem,"E5_P_SISTE"	   		,"C",01,0,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"Envio Sistec"	,"@!",'','€€€€€€€€€€€€€€°',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := NextOrdem( 'SD2' )
aAdd(aSX3,{"SD2",cOrdem,"D2_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := NextOrdem( 'SC7' )
aAdd(aSX3,{"SC7",cOrdem,"C7_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC7",cOrdem,"C7_P_PROJ"	   		,"C",09,0,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SC7",cOrdem,"C7_P_REG"	   		,"C",09,0,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","A","R",'',"","","","","","","","","","N"})

cOrdem := NextOrdem( 'SA2' )
aAdd(aSX3,{"SA2",cOrdem,"A2_P_ID"	   		,"C",20,0,"Id.Forn."	,"Id.Forn."	,"Id.Forn."	,"Id.Forn."	,"Id.Forn."	,"Id.Forn."	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})		

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"SA2",cOrdem,"A2_TPESSOA"	   		,"C",02,0,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"Tipo Pessoa"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","CI=Comercio/Industria;PF=Pessoa Fisica;OS=Prestacao de Servico;EP=Empresa Publica;CC=Comercio;AT=Ato Cotepe;ER=Emp Ret","","","","","","","","N"})		


cOrdem := NextOrdem( 'ZX0' )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_FILIAL"	   		,"C",02,0,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_DOC"	   		,"C",09,0,"Nota Fiscal"	,"Nota Fiscal"	,"Nota Fiscal"	,"Nota Fiscal"	,"Nota Fiscal"	,"Nota Fiscal"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_SERIE"	   		,"C",03,0,"Serie"	,"Serie"	,"Serie"	,"Serie"	,"Serie"	,"Serie"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_EMISSA"	   		,"D",08,0,"Emissao"	,"Emissao"	,"Emissao"	,"Emissao"	,"Emissao"	,"Emissao"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_DATA"	   		,"D",08,0,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_CGC"	   		,"C",14,0,"CNPJ"	,"CNPJ"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_ITEM"	   		,"C",04,0,"Item"	,"Item"	,"Item"	,"Item"	,"Item"	,"Item"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_PRODUT"	   		,"C",15,0,"Produto"	,"Produto"	,"Produto"	,"Produto"	,"Produto"	,"Produto"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})
 	
cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_QUANT"	   		,"N",13,4,"Quantidade"	,"Quantidade"	,"Quantidade"	,"Quantidade"	,"Quantidade"	,"Quantidade"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_P_PROJ"	   		,"C",09,0,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX0",cOrdem,"ZX0_P_REG"	   		,"C",09,0,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","A","R",'',"","","","","","","","","","N"})

cOrdem := NextOrdem( 'ZX1' )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_FILIAL"	   		,"C",02,0,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"Filial"	,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_P_REF"	   		,"C",20,0,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"Ped.Vogel"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_DATA"	   		,"D",08,0,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"Dt.Movimento"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_ITEM"	   		,"C",04,0,"Item"	,"Item"	,"Item"	,"Item"	,"Item"	,"Item"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"}) 

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_PRODUT"	   		,"C",15,0,"Produto"	,"Produto"	,"Produto"	,"Produto"	,"Produto"	,"Produto"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})
 	
cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_QUANT"	   		,"N",13,4,"Quantidade"	,"Quantidade"	,"Quantidade"	,"Quantidade"	,"Quantidade"	,"Quantidade"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_P_PROJ"	   		,"C",09,0,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"Projeto"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","V","R",'',"","","","","","","","","","N"})

cOrdem := Soma1( cOrdem )
aAdd(aSX3,{"ZX1",cOrdem,"ZX1_P_REG"	   		,"C",09,0,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"Regional"	,"@!",'','€€€€€€€€€€€€€€',"" ,"",0,'†A',"","","U","N","A","R",'',"","","","","","","","","","N"})

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

//Não deixando alterar os campos que vieram de integracao no SA1
For nR:=1 to Len(aCpoWhe)
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(aCpoWhe[nR]))
   		RecLock("SX3",.F.)
	    	SX3->X3_WHEN := "IIF(!INCLUI,.F.,.T.)"
   		SX3->(MsUnlock())                         
   		cTexto += "- Campo Atualizado. '"+aCpoWhe[nR]+"'"+ CHR(10) + CHR(13)
	EndIf
Next nR

Return cTexto

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
	

aAdd(aSX6,{"","MV_P_00081","D" ,'Data Inicio Fat. Telecom','Data Inicio Fat. Telecom','Data Inicio Fat. Telecom',""	,;
""	,""	,"","","","U","","",""}) 

aAdd(aSX6,{"","MV_1DUPNAT","C" ,'Campo ou dado a ser gravado na natureza do titulo.','Campo ou dado a ser gravado na natureza do titulo.','Campo ou dado a ser gravado na natureza do titulo.',""	,;
""	,""	,"SC5->C5_NATUREZ","","","U","","",""}) 

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
dbUseArea(.T.,,cNome,cAliasWork,.T.,.F.)
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

oDlg1      := MSDialog():New( 091,232,401,612,"Projeto Voegel - TI HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
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
