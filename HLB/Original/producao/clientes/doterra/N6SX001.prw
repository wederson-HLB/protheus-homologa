#INCLUDE "Protheus.ch"
#include 'average.ch'

/*
Funcao      : N6SX001
Parametros  : Nenhum
Retorno     : Nil 
Objetivos   : atualizacao de campos, indices, tabelas
Autor       : Leandro Brito
Chamado		: 
Data/Hora   : 15/01/2018
*/
*---------------------*
User Function N6SX001()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"SF2","SC5","SF1","ZX1","ZX2","SE1","ZX3","ZX4","ZX5","ZX6","ZX7"}
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
Local aChamados := {	{05, {|| AtuSX2()}},;
						{05, {|| AtuSX3()}},;
						{05, {|| AtuSIX()}},;
						{05, {|| AtuSX6()}},;
						{05, {|| AtuSX1()}},;
						{05, {|| AtuSXB()}} }
Local aExec     := {}

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
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario SIX.
*/
*----------------------*
Static Function AtuSIX()
*----------------------*
Local aArea := getArea()
Local cTexto  := ''
Local cAlias  := '' 
Local aEstrut := {}
Local aSIX    := {}
Local cOrdem  := ''
Local i := 0
Local j := 0

DbSelectArea("SIX")

aEstrut:= {   "INDICE","ORDEM","CHAVE"                                                                                 ,"DESCRICAO"                                                              ,"DESCSPA"                                                                , "DESCENG"                                                                  ,"PROPRI","F3" ,"NICKNAME"  ,"SHOWPESQ" }	 
Aadd( aSix ,{ "ZX1"   ,"1"   ,"ZX1_FILIAL+ZX1_COD+ZX1_DATA"                                                           ,"ZX1_FILIAL+ZX1_COD+ZX1_DATA"                                            ,"ZX1_FILIAL+ZX1_COD+ZX1_DATA"                                            , "ZX1_FILIAL+ZX1_COD+ZX1_DATA "                                             ,"U"     ,     , ""         , "S"       } )  
Aadd( aSix ,{ "ZX2"   ,"1"   ,"ZX2_FILIAL+ZX2_CHAVE"                                                                  ,"ZX2_FILIAL+ZX2_CHAVE "                                                  ,"ZX2_FILIAL+ZX2_CHAVE "                                                  ,"ZX2_FILIAL+ZX2_CHAVE "                                                     ,"U"     ,     , ""         , "S"       } )  
aAdd( aSIX, { 'ZX3'   ,'1'   ,'ZX3_FILIAL+DTOS(ZX3_DTCRED)+ZX3_WLDPA+ZX3_PARCEL'                                      ,'Dt Crédito + Worldpay ID + Parcela'                                     ,'Fc Credito + Worldpay ID + Cuota'                                       ,'Credit Date + Worldpay ID + Installment'                                   ,'S'     ,''   ,''          , 'S'       } )
aAdd( aSIX, { 'ZX3'   ,'2'   ,'ZX3_FILIAL+DTOS(ZX3_DTCRED)+ZX3_NUCOMP+ZX3_PARCEL'                                     ,'Dt Crédito + Comprovante + Parcela'                                     ,'Fc Credito + Comprobante + Cuota'                                       ,'Credit Date + Receipt + Installment'                                       ,'S'     ,''   ,''          , 'S'       } )
aAdd( aSIX, { 'ZX3'   ,'3'   ,'ZX3_FILIAL+ZX3_PREFIX+ZX3_NUM+ZX3_PARC+ZX3_TIPO'                                       ,'Prefixo + No Titulo + ZX3_PARC+Tipo'                                    ,'Prefijo + No Titulo + ZX3_PARC+Tipo'                                    ,'Prefix + Bill Number + ZX3_PARC+Type'                                      ,'S'     ,''   ,''          , 'S'       } )
aAdd( aSIX, { 'ZX3'	  ,'4'   ,'ZX3_FILIAL+DTOS(ZX3_DTCRED)+ZX3_WLDPA+ZX3_PARCEL+ZX3_CODEST+ZX3_CODRED'                ,'Dt Crédito + Worldpay ID + Parcela + Cod Estab + Ident. Rede'           ,'Fc Credito + Worldpay ID + Cuota + Cod Estab + Ident. Red'              ,'Credit Date + Worldpay ID + Installment + Estab Code + Network ID'         ,'S'     ,''   ,'ZX3_TITULO', 'S'       } )
aAdd( aSIX, { 'ZX3'   ,'5'   ,'ZX3_FILIAL+DTOS(ZX3_DTTEF)+ZX3_WLDPA+ZX3_PARCEL+ZX3_CODLOJ+DTOS(ZX3_DTCRED)+ZX3_SEQZX3','Data Venda + Worldpay + Parcela + Loja Worldpay + Dt Crédito + Seq. Tab','Fch. Venta + Worldpay + Cuota + Tienda Worldpay + Fc Credito + Sec. Tab','Sale Date + Worldpay ID + Installment + Worldpay Store + Credit Date + ZX3','S'     ,''   ,''          , 'S'       } )
aAdd( aSIX, { 'ZX3'	  ,'6'   ,'ZX3_FILIAL+ZX3_WLDPA+ZX3_PARCEL'                									   ,'Wordpay ID + Parcela'                                                   ,'Wordpay ID + Parcela'                                                   ,'Wordpay ID + Parcela'                                                      ,'S'     ,''   ,''          , 'S'       } )
aAdd( aSIX, { 'ZX4'	  ,'1'   ,'ZX4_FILIAL+ZX4_CODCLI+ZX4_LOJA+ZX4_CODEND'         									   ,'Filial + Cod. Cliente + Cod. Endereço'                                  ,'Filial + Cod. Cliente + Cod. Endereço'                                  ,'Filial + Cod. Cliente + Cod. Endereço'                                     ,'S'     ,''   ,''          , 'S'       } )
aAdd( aSIX, { 'ZX4'	  ,'2'   ,'ZX4_FILIAL+ZX4_CODEND'  					       									   ,'Filial + Cod. Endereço'                                                 ,'Filial + Cod. Endereço'                                                 ,'Filial + Cod. Endereço'                                                    ,'S'     ,''   ,''          , 'S'       } )

//Cadastro de Produtos Substitutos - OMJ 01.08.2018
Aadd( aSix ,{ "ZX5"   ,"1"   ,"ZX5_FILIAL+ZX5_COD+ZX5_ORDEM"                                                          ,"Produto Principal + Ordem     "                                          ,"Producto Principal + Orden     "                                       ,"Main Material + Order        "                                             ,"U"     ,     , ""         , "S"       } )  
Aadd( aSix ,{ "ZX5"   ,"2"   ,"ZX5_FILIAL+ZX5_PRODSU"                                                                 ,"Produto Substituto            "                                          ,"Producto sustituto             "                                       ,"Replace Material             "                                             ,"U"     ,     , ""         , "S"       } )  

Aadd( aSix ,{ "ZX6"   ,"1"   ,"ZX6_FILIAL+ZX6_DTRAX"                                                         		  ,"Filial + Datatrax    "                                                   ,"Filial + Datatrax    "                                                 ,"Filial + Datatrax    "	                                                   ,"U"     ,     , ""         , "S"       } )  
Aadd( aSix ,{ "ZX7"   ,"1"   ,"ZX7_FILIAL+ZX7_DTRAX+ZX7_SEQ"                                                          ,"Filial + Datatrax + Sequencia"                                           ,"Filial + Datatrax + Sequencia"                                         ,"Filial + Datatrax + Sequencia"                                             ,"U"     ,     , ""         , "S"       } )  

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
Funcao      : ATUSX2
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario SX2.
*/
*----------------------*
Static Function AtuSX2()
*----------------------*
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

aEstrut:= { "X2_CHAVE","X2_PATH","X2_ARQUIVO"      ,"X2_NOME"                     ,"X2_NOMESPA"                   ,"X2_NOMEENG"                 ,"X2_ROTINA" ,"X2_MODO" ,"X2_MODOUN" ,"X2_MODOEMP","X2_DELET","X2_TTS","X2_UNICO"                                                                               ,"X2_PYME","X2_MODULO"  ,"X2_DISPLAY","X2_SYSOBJ", "X2_USROBJ"  ,"X2_POSLGT" ,"X2_CLOB"  ,"X2_AUTREC","X2_TAMFIL" ,"X2_TAMUN" ,"X2_TAMEMP" }	 	
aAdd(aSX2,{ "ZX1"     ,'\'      ,'ZX1'+cEmpAnt+'0' ,'SALDO FISICO FEDEX'          ,'SALDO FISICO FEDEX'           ,'SALDO FISICO FEDEX'         ,""          ,"E"       ,"E"         ,"E"         ,0         ,""      ,""                                                                                       ,"S"      ,0            ,""          ,""         ,""            ,""          ,""         ,""         ,0           ,0          ,0           } ) 
aAdd(aSX2,{ "ZX2"     ,'\'      ,'ZX2'+cEmpAnt+'0' ,'LOG TRANSACAO WS'            ,'LOG TRANSACAO WS'             ,'LOG TRANSACAO WS'           ,""          ,"E"       ,"E"         ,"E"         ,0         ,""      ,""                                                                                       ,"S"      ,0            ,""          ,""         ,""            ,""          ,""         ,""         ,0           ,0          ,0           } ) 
aAdd(aSX2,{ 'ZX3'     ,'\'      ,'ZX3'+cEmpAnt+'0' ,'ARQUIVO CONCILIACAO WORLDPAY','ARCHIVO CONCILIACION WORLDPAY','Worldpay CONCILIATION WORLDPAY',""          ,'E'       ,'E'         ,'E'         ,0         ,''      ,'ZX3_FILIAL+DTOS(ZX3_DTTEF)+ZX3_WLDPA+ZX3_PARCEL+ZX3_CODLOJ+DTOS(ZX3_DTCRED)+ZX3_SEQZX3','S'      ,6            ,''          ,'E'        ,""            ,"1"         ,""         ,""         ,0           ,0          ,0           } )
aAdd(aSX2,{ 'ZX4'     ,'\'      ,'ZX4'+cEmpAnt+'0' ,'Endereço de entrega Cliente ','Endereço de entrega Cliente ' ,'Endereço de entrega Cliente ',""          ,'C'       ,'C'         ,'C'         ,0         ,''      ,                                                                                        ,'S'      ,6            ,''          ,''         ,""            ,""          ,""         ,""         ,0           ,0          ,0           } )
//Cadastro de Produtos Substitutos - OMJ 01.08.2018
aAdd(aSX2,{ "ZX5"     ,'\'      ,'ZX5'+cEmpAnt+'0' ,'Cadastro Produtos Substituto','Registro Productos Sustituto' ,'Substitutes for Materials'  ,""          ,'C'       ,'C'         ,'C'         ,0         ,""      ,""                                                                                       ,"S"      ,0            ,""          ,""         ,""            ,""          ,""         ,""         ,0           ,0          ,0           } ) 

aAdd(aSX2,{ "ZX6"     ,'\'      ,"ZX6"+cEmpAnt+'0' ,'Tabela de Rastreio' ,'Tabela de Rastreio' ,'Tabela de Rastreio' ,""          ,'E'       ,'C'         ,'C'         ,0         ,""      ,""                                                                                       ,"S"      ,0            ,""          ,""         ,""            ,""          ,""         ,""         ,0           ,0          ,0           } ) 
aAdd(aSX2,{ "ZX7"     ,'\'      ,"ZX7"+cEmpAnt+'0' ,'Log Tabela Rastreio','Log Tabela Rastreio','Log Tabela Rastreio',""          ,'E'       ,'C'         ,'C'         ,0         ,""      ,""                                                                                       ,"S"      ,0            ,""          ,""         ,""            ,""          ,""         ,""         ,0           ,0          ,0           } ) 

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
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario SX3.
*/
*----------------------*
Static Function AtuSX3()
*----------------------* 
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

cOrdem  := NextOrdem('SF2')  
aEstrut:= { "X3_ARQUIVO","X3_ORDEM"   ,"X3_CAMPO"   ,"X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"    ,"X3_DESCRIC"            	,"X3_DESCSPA"				,"X3_DESCENG"               ,"X3_PICTURE"     ,"X3_VALID"  ,"X3_USADO"                                          																											  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL","X3_RESERV"        ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"                                                                                                                        ,"X3_CBOXSPA"																													  ,"X3_CBOXENG"																													    ,"X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_TELA","X3_POSLGT","X3_IDXFLD","X3_AGRUP","X3_PYME"}            
aAdd(aSX3,{ "SF2"       ,cOrdem       ,"F2_P_ENVD"  ,"C"      ,1           ,0           ,"Env.Pdf"	    ,"Env.Pdf"      ,"Env.Pdf"      ,"Env.Pdf"	             	,"Env.Pdf"	 				,"Env.Pdf"                  ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,"€"         ,""          ,""      																														    ,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"      })

aAdd(aSX3,{ "ZX1"       ,"01"      	  ,"ZX1_FILIAL" ,"C"      ,2           ,0           ,"Filial"	    ,"Filial"	    ,"Filial"       ,"Filial do Sistema"	 	,"Filial do Sistema"	 	,"Filial do Sistema"        ,"@!"             ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"02"      	  ,"ZX1_DEP"    ,"C"      ,10          ,0           ,"Cod.Dep"	    ,"Cod.Dep"      ,"Cod.Dep"      ,"Codigo do depositante" 	,"Codigo do depositante" 	,"Codigo do depositante"    ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""      																														    ,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"03"      	  ,"ZX1_ARM"    ,"C"      ,10          ,0           ,"Cod.Armaz"	,"Cod.Armaz"    ,"Cod.Armaz"    ,"Env.Pdf"	                ,"Env.Pdf"	 	            ,"Env.Pdf"                  ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"04"         ,"ZX1_COD"    ,"C"      ,15          ,0           ,"Cod.SKU"	    ,"Cod.SKU"      ,"Cod.SKU"      ,"Codigo SKU"	         	,"Codigo SKU"	 			,"Codigo SKU"               ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"05"         ,"ZX1_LOTE"   ,"C"      ,10          ,0           ,"Cod.Lote"	    ,"Cod.Lote"     ,"Cod.Lote"     ,"Cod.Lote"	                ,"Cod.Lote"	 	            ,"Cod.Lote"                 ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"06"         ,"ZX1_DTVAL"  ,"D"      ,8           ,0           ,"Dt.Validade"  ,"Dt.Validade"  ,"Dt.Validade"  ,"Data de Validade"      	,"Data de Validade"			,"Data de Validade"         ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""      																														    ,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"07"         ,"ZX1_SALDO"  ,"N"      ,10          ,2           ,"Saldo"	    ,"Saldo"	    ,"Saldo"        ,"Saldo"					,"Saldo"	 				,"Saldo"                    ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"08"         ,"ZX1_SLDPED" ,"N"      ,10          ,2           ,"Saldo.Pedido" ,"Saldo.Pedido" ,"Saldo.Pedido" ,"Saldo disp p/pedido"	 	,"Saldo disp p/pedido"		,"Saldo disp p/pedido"      ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"09"         ,"ZX1_SLDPIC" ,"N"      ,10          ,2           ,"Qtd.Separada" ,"Qtd.Separada" ,"Qtd.Separada" ,"Qtd.Separada"	         	,"Qtd.Separada"				,"Qtd.Separada"             ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"10"      	  ,"ZX1_SLDRES" ,"N"      ,10          ,2           ,"Qtd.Reserva"  ,"Qtd.Reserva"  ,"Qtd.Reserva"  ,"Quantidade Reservada"	 	,"Quantidade Reservada"		,"Quantidade Reservada"     ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""      																														    ,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"11"         ,"ZX1_SDLBLO" ,"N"      ,10          ,2           ,"Qtd.Bloqueada","Qtd.Bloqueada","Qtd.Bloqueada","Qtd Bloqueada"	     	,"Qtd Bloqueada"			,"Qtd Bloqueada"            ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"12"         ,"ZX1_SDLDIS" ,"N"      ,10          ,2           ,"Qtd.Disp."	,"Qtd.Disp."	,"Qtd.Disp."    ,"Quantidade Disponivel" 	,"Quantidade Disponivel"    ,"Quantidade Disponivel"    ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"13"         ,"ZX1_SLDSB2" ,"N"      ,10          ,2           ,"Saldo. SB2"   ,"Saldo. SB2"	,"Saldo. SB2"   ,"Saldo SB2"	         	,"Saldo SB2"	            ,"Saldo SB2"                ,"@E 9,999,999.99",''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX1"       ,"14"         ,"ZX1_DATA"   ,"D"      ,8           ,0           ,"Dt.Transacao" ,"Dt.Transacao" ,"Dt.Transacao" ,"Data da Transacao"	    ,"Data da Transacao"	    ,"Data da Transacao"        ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"}) 
aAdd(aSX3,{ "ZX2"       ,"01"      	  ,"ZX2_FILIAL" ,"C"      ,2           ,0           ,"Filial"	    ,"Filial"	    ,"Filial"       ,"Filial do Sistema"	    ,"Filial do Sistema"		,"Filial do Sistema"        ,"@!"             ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"02"      	  ,"ZX2_ALIAS"  ,"C"      ,3           ,0           ,"Alias Imp"	,"Alias Imp"    ,"Alias Imp"    ,"Alias da Importacao"	    ,"Alias da Importacao"		,"Alias da Importacao"      ,"@!"             ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"03"      	  ,"ZX2_TIPO"   ,"C"      ,1           ,0           ,"Tipo Int."	,"Tipo Int."    ,"Tipo Int."    ,"Tipo da Integracao"	    ,"Tipo da Integracao"		,"Tipo da Integracao"       ,"@!"             ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"04"         ,"ZX2_CHAVE"  ,"C"      ,30          ,0           ,"Chave Int."   ,"Chave Int."   ,"Chave Int."   ,"Chave da Integracao"	    ,"Chave da Integracao"		,"Chave da Integracao"      ,"@!"             ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"05"         ,"ZX2_DATA"   ,"D"      ,8           ,0           ,"Data Int"	    ,"Data Int"     ,"Data Int"     ,"Data Integracao"	        ,"Data Integracao"			,"Data Integracao"          ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"06"         ,"ZX2_HORA"   ,"C"      ,10          ,0           ,"Hora Int."    ,"Hora Int."    ,"Hora Int."    ,"Hora da Integracao"       ,"Hora da Integracao"		,"Hora da Integracao"       ,""               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"07"         ,"ZX2_CONTEU" ,"M"      ,10          ,0           ,"Conteudo Env" ,"Conteudo Env" ,"Conteudo Env" ,"Conteudo Enviado na Integ","Conteudo Enviado na Integ","Conteudo Enviado na Integ","@!"             ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"08"         ,"ZX2_ERRO"   ,"M"      ,10          ,0           ,"Mostra Erro"  ,"Mostra Erro"  ,"Mostra Erro"  ,"Saldo disp p/pedido"	    ,"Saldo disp p/pedido"	    ,"Saldo disp p/pedido"      ,""			      ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"09"         ,"ZX2_SERWS"  ,"C"      ,25          ,0           ,"Servico.Ws"   ,"Servico.Ws"   ,"Servico.Ws"   ,"Servico.Ws"	            ,"Servico.Ws"	            ,"Servico.Ws"               ,"@!"			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"10"      	  ,"ZX2_FROM"   ,"C"      ,15          ,0           ,"De"           ,"De"           ,"De"           ,"De"	                    ,"De"	                    ,"De"                       ,"@!"			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX2"       ,"11"         ,"ZX2_TO"     ,"C"      ,15          ,0           ,"Para"         ,"Para"         ,"Para"         ,"Para"	                    ,"Para"	                    ,"Para"                     ,"@!"			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0		   ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})

cOrdem  := NextOrdem('SF1') 
aAdd(aSX3,{ "SF1"       ,soma1(cOrdem),"F1_P_STFED" ,"C"      ,2           ,0           ,"Status FAT "  ,"Status FAT "  ,"Status FAT"   ,"Envio NFE FEDEX"	        ,"Envio NFE FEDEX"	        ,"Envio NFE FEDEX"          ,""   			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,"1=NFe enviada FEDEX;2=NFe Registrada FEDEX;3=Entrada Fisica Conf./Fin.;4=Divergencia Entrada Fisica vs NFe;5=Erro Proc.WS/XML"  ,"1=NFe enviada FEDEX;2=NFe Registrada FEDEX;3=Entrada Fisica Conf./Fin.;4=Divergencia Entrada Fisica vs NFe;5=Erro Proc.WS/XML"  ,"1=NFe enviada FEDEX;2=NFe Registrada FEDEX;3=Entrada Fisica Conf./Fin.;4=Divergencia Entrada Fisica vs NFe;5=Erro Proc.WS/XML"  ,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SF1"       ,soma1(cOrdem),"F1_P_DTFED" ,"D"      ,8           ,0           ,"Dt Ws Fedex"  ,"Dt Ws Fedex"  ,"Dt Ws Fedex"  ,"DT. de transacao ws FEDEX","DT. de transacao ws FEDEX","DT. de transacao ws FEDEX",""				  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SF1"       ,soma1(cOrdem),"F1_P_CHAVE" ,"C"      ,10          ,0           ,"Chave Fedex " ,"Chave Fedex " ,"Chave Fedex"  ,"ID Registro WS FedEX"     ,"ID Registro WS FedEX "    ,"ID Registro WS FedEX   "  ,""   			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																		                                                ,""          																													  ,""          																													    ,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})

cOrdem  := NextOrdem('SC5') 
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_STFED" ,"C"      ,2           ,0           ,"Status FAT "  ,"Status FAT "  ,"Status FAT " ,"Status de Faturamento"    ,"Status de Faturamento"	   ,"Status de Faturamento"     ,""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,"01=Pic Env;02=Pic Rec;03=Pic OK;04=Pic n/Ok;05=ErrWS;06=ErrWsPic;07=PV Fat;08=PV n/Fat;09=NF Env;10=NF Erro;11=NF Ok;12=NF n/OK","01=Pic Env;02=Pic Rec;03=Pic OK;04=Pic n/Ok;05=ErrWS;06=ErrWsPic;07=PV Fat;08=PV n/Fat;09=NF Env;10=NF Erro;11=NF Ok;12=NF n/OK","01=Pic Env;02=Pic Rec;03=Pic OK;04=Pic n/Ok;05=ErrWS;06=ErrWsPic;07=PV Fat;08=PV n/Fat;09=NF Env;10=NF Erro;11=NF Ok;12=NF n/OK",""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_DTFED" ,"D"      ,8           ,0           ,"Dt Ws Fedex"  ,"Dt Ws Fedex"  ,"Dt Ws Fedex" ,"DT. de transacao ws FEDEX","DT. de transacao ws FEDEX","DT. de transacao ws FEDEX" ,""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_CHAVE" ,"C"      ,10          ,0           ,"Chave Fedex"  ,"Chave Fedex"  ,"Chave Fedex" ,"ID Registro WS FedEX","ID Registro WS FedEX "         ,"ID Registro WS FedEX   "   ,""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_DTRAX" ,"C"      ,10          ,0           ,"Datatrax ID"  ,"Datatrax ID " ,"Datatrax ID" ,"Codigo PV. Datatrax      ","Codigo PV. Datatrax "     ,"Codigo PV. Datatrax   "    ,""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_WLDPAY","C"      ,64          ,0           ,"Worldpay ID"  ,"Worldpay ID " ,"WorldPay ID" ,"Codigo Transacao Worldpay","Codigo Transacao Worldpay","Codigo Transacao Worldpay ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TIPAG" ,"C"      ,2           ,0           ,"TIPO PAG.  "  ,"TIPO PAG.   " ,"TIPO PAG.  " ,"Tipo de pagamento        ","Tipo de pagamento        ","Tipo de pagamento         ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"CC=Cartao de Credito;DC=Cartao de Debito"                                                                                       ,"CC=Cartao de Credito;DC=Cartao de Debito"																						  ,"CC=Cartao de Credito;DC=Cartao de Debito"       																				,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_BAND " ,"C"      ,2           ,0           ,"BANDEIRA   "  ,"BANDEIRA    " ,"BANDEIRA   " ,"Bandeira cart. de credito","Bandeira cart. de credito","Bandeira cart. de credito ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"01=Visa;02=MasterCard;03=ELO"                                                                                                   ,"01=Visa;02=MasterCard;03=ELO"																									  ,"01=Visa;02=MasterCard;03=ELO"       																							,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TIPG1" ,"C"      ,2           ,0           ,"TIPO PAG 1"   ,"TIPO PAG 1 "  ,"TIPO PAG 1"  ,"Tipo de pagamento 1      ","Tipo de pagamento 1      ","Tipo de pagamento 1       ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"CC=Cartao de Credito;DC=Cartao de Debito"                                                                                       ,"CC=Cartao de Credito;DC=Cartao de Debito"																						  ,"CC=Cartao de Credito;DC=Cartao de Debito"       																				,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_BAND1" ,"C"      ,2           ,0           ,"BANDEIRA 1"   ,"BANDEIRA 1 "  ,"BANDEIRA 1"  ,"Band. cart. de credito 1 ","Band. cart. de credito 1 ","Band. cart. de credito 1  ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"01=Visa;02=MasterCard;03=ELO"                                                                                                   ,"01=Visa;02=MasterCard;03=ELO"																									  ,"01=Visa;02=MasterCard;03=ELO"       																							,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TIPG2" ,"C"      ,2           ,0           ,"TIPO PAG 2"   ,"TIPO PAG 2 "  ,"TIPO PAG 2"  ,"Tipo de pagamento 2      ","Tipo de pagamento 2      ","Tipo de pagamento 2       ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"CC=Cartao de Credito;DC=Cartao de Debito"																					    ,"CC=Cartao de Credito;DC=Cartao de Debito"																						  ,"CC=Cartao de Credito;DC=Cartao de Debito"       																				,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_BAND2" ,"C"      ,2           ,0           ,"BANDEIRA 2"   ,"BANDEIRA 2 "  ,"BANDEIRA 2"  ,"Band. cart. de credito 2 ","Band. cart. de credito 2 ","Band. cart. de credito 2  ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"01=Visa;02=MasterCard;03=ELO"                 																				  	,"01=Visa;02=MasterCard;03=ELO"																									  ,"01=Visa;02=MasterCard;03=ELO"       																							,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TIPG3" ,"C"      ,2           ,0           ,"TIPO PAG 3"   ,"TIPO PAG 3 "  ,"TIPO PAG 3"  ,"Tipo de pagamento 3      ","Tipo de pagamento 3      ","Tipo de pagamento 3       ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"CC=Cartao de Credito;DC=Cartao de Debito"																					    ,"CC=Cartao de Credito;DC=Cartao de Debito"																						  ,"CC=Cartao de Credito;DC=Cartao de Debito"       																				,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_BAND3" ,"C"      ,2           ,0           ,"BANDEIRA 3"   ,"BANDEIR  3 "  ,"BANDEIRA 3"  ,"Band. cart. de credito 3 ","Band. cart. de credito 3 ","Band. cart. de credito 3  ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"01=Visa;02=MasterCard;03=ELO"																								    ,"01=Visa;02=MasterCard;03=ELO"																									  ,"01=Visa;02=MasterCard;03=ELO"       																							,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TIPG4" ,"C"      ,2           ,0           ,"TIPO PAG 4"   ,"TIPO PAG 4 "  ,"TIPO PAG 4"  ,"Tipo de pagamento 4      ","Tipo de pagamento 4      ","Tipo de pagamento 4       ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"CC=Cartao de Credito;DC=Cartao de Debito"																					    ,"CC=Cartao de Credito;DC=Cartao de Debito"																						  ,"CC=Cartao de Credito;DC=Cartao de Debito"       																				,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_BAND4" ,"C"      ,2           ,0           ,"BANDEIRA 4"   ,"BANDEIR  4 "  ,"BANDEIRA 4"  ,"Band. cart. de credito 4 ","Band. cart. de credito 4 ","Band. cart. de credito 4  ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,"01=Visa;02=MasterCard;03=ELO"																								    ,"01=Visa;02=MasterCard;03=ELO"																									  ,"01=Visa;02=MasterCard;03=ELO"       																							,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TRAN2" ,"C"      ,2           ,0           ,"Transp.2  "   ,"Transp.2   "  ,"Transp.2  "  ,"Transportadora 2         ","Transportadora 2         ","Transportadora 2          ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_FRET2" ,"N"      ,12          ,2           ,"Frete.2   "   ,"Frete.2    "  ,"Frete.2   "  ,"Valor do Frete 2         ","Valor do Frete 2         ","Valor do Frete 2          ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TRAN3" ,"C"      ,2           ,0           ,"Transp.3  "   ,"Transp.3   "  ,"Transp.2  "  ,"Transportadora 3         ","Transportadora 3         ","Transportadora 3          ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_FRET3" ,"N"      ,12          ,2           ,"Frete.3   "   ,"Frete.3    "  ,"Frete.2   "  ,"Valor do Frete 3         ","Valor do Frete 3         ","Valor do Frete 3          ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_NSHIP" ,"C"      ,13          ,0           ,"Shipment ID"  ,"Shipment ID"  ,"Shipment ID" ,"Shipment number	      ","Shipment Number          ","Shipment Number           ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_ENDEN" ,"C"      ,06          ,0           ,"End.Entrega"  ,"End.Entrega"  ,"End.Entrega" ,"Endereço de entrega      ","Endereço de entrega      ","Endereço de entrega       ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,"ZX4"       ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SC5"       ,soma1(cOrdem),"C5_P_TPPV " ,"C"      ,03          ,0           ,"Tipo Pedido"  ,"Tipo Pedido"  ,"Tipo Pedido" ,"Tipo Pedido              ","Tipo Pedido              ","Tipo Pedido               ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"N"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})


cOrdem  := NextOrdem('SE1') 
aAdd(aSX3,{ "SE1"       ,soma1(cOrdem),"E1_P_WLDPA" ,"C"      ,64          ,0           ,"Worldpay ID"  ,"Worldpay ID " ,"WorldPay ID" ,"Codigo Transacao Worldpay","Codigo Transacao Worldpay","Codigo Transacao Worldpay ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""      ,""          ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SE1"       ,soma1(cOrdem),"E1_P_DTRAX" ,"C"      ,10          ,0           ,"Datatrax ID"  ,"Datatrax ID " ,"Datatrax ID" ,"Codigo PV. Datatrax      ","Codigo PV. Datatrax "     ,"Codigo PV. Datatrax   "    ,""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""      ,""          ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SE1"       ,soma1(cOrdem),"E1_P_BAND " ,"C"      ,2           ,0           ,"Bandeira   "  ,"Bandeira    " ,"Bandeira   " ,"Bandeira cart. de credito","Bandeira cart. de credito","Bandeira cart. de credito ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,""          ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,"01=Visa Credito;02=MasterCard Credito;03=ELO;04=Visa Debito;05=Mastercard Debito"											    ,"01=Visa;02=MasterCard;03=ELO;04=Visa Debito;05=Mastercard Debito"																  ,"01=Visa;02=MasterCard;03=ELO;04=Visa Debito;05=Mastercard Debito"       														,""          ,""      ,""          ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "SE1"       ,soma1(cOrdem),"E1_P_TIPAG" ,"C"      ,2           ,0           ,"Pagamento  "  ,"Pagamento   " ,"Pagamento  " ,"Tipo de pagamento        ","Tipo de pagamento        ","Tipo de pagamento         ",""  			  ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,"" 		   ,""  		,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,"CC=Cartao de Credito;DC=Cartao de Debito"  																					    ,"CC=Cartao de Credito;DC=Cartao de Debito"																						  ,"CC=Cartao de Credito;DC=Cartao de Debito"       																				,""          ,""      ,""          ,""         ,""         ,""          ,""         ,""         ,""         ,""        ,""         ,""         ,""        ,"N"})

aAdd(aSX3,{ 'ZX3'	,'01' ,'ZX3_FILIAL'	,'C',2    ,0 ,'Filial'		,'Sucursal'		,'Branch'		,'Filial do Sistema'	   ,'Sucursal del Sistema'     ,'System Branch'             ,''               ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),''		   ,''		  	,		   ,Chr(133) + Chr(128),''		  ,''          ,''         ,'N'        ,'A'        ,'R'         ,''         ,''           ,''                                                                                                                               ,''                                                                                                                               ,''                                                                                                                               ,''          ,''      ,''          ,'033'      ,''		   ,''          ,''         ,'N'        ,'N'        ,''        ,'1'        ,'N'        ,''        ,'S'})
aAdd(aSX3,{ 'ZX3'	,'02' ,'ZX3_TPREG'  ,'C',2    ,0 ,'Tp Registro','Tp Registro','Record Type','Tiipo do registro','Tiipo do registro','Record Type','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'03' ,'ZX3_INTRAN' ,'C',30   ,0 ,'Ind. Trans.','Ind. Trans.','Trans. Ind.','Indicador de transação','Indicador de transaccion','Transaction Indicator','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'04' ,'ZX3_CODEST' ,'C',15   ,0 ,'Cod Estab','Cod Estab','Estab Code','Código do estabelecimento','Codigo de establecimiento','Establishment Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'05' ,'ZX3_DTTEF'  ,'D',8    ,0 ,'Data Venda','Fch. Venta','Sale Date','Data da Venda','Fecha de la venta','Sale Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',,Chr(199) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'06' ,'ZX3_NURESU' ,'C',10   ,0 ,'Nr Resumo','Nr Resumen','Summary No','Número do resumo','Numero de resumen','Summary Number','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(199) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'07' ,'ZX3_NUCOMP' ,'C',12   ,0 ,'Comprovante','Comprobante','Receipt','Número do comprovante','Numero de comprobante','Receipt Number','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'08' ,'ZX3_WLDPA ' ,'C',64   ,0 ,'Worldpay ID','Worldpay ID','Worldpay ID','Worldpay ID','Worldpay ID','Worldpay ID','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'09' ,'ZX3_NUCART' ,'C',19   ,0 ,'Nro Cartão','Nro tarjeta','Card Nmb','Número do cartão','Numero de tarjeta','Card Number','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'	,'10' ,'ZX3_VLBRUT' ,'N',16   ,2 ,'Vlr Venda','Vlr Venta','Sales Vl','Valor da venda (Bruto)','Valor de venta (Bruto)','Sales Value (Gross)','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'11' ,'ZX3_TOTPAR' ,'C',2    ,0 ,'Tot.Parcelas','Tot.Cuotas','Tot.Installm','Total de parcelas','Total de cuotas','Total of Installments','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'12' ,'ZX3_VLLIQ'  ,'N',16   ,2 ,'Vlr Liquido','Val. Neto','Net Value','Valor Líquido','Valor neto','Net Value','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'13' ,'ZX3_DTCRED' ,'D',8    ,0 ,'Dt Crédito','Fc Credito','Credit Date','Data de Crédito','Fecha de Credito','Credit Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(199) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'14' ,'ZX3_PARCEL' ,'C',2    ,0 ,'Parcela','Cuota','Installment','Parcela Worldpay','Cuota Worldpay','Worldpay Installment','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'15' ,'ZX3_TPPROD' ,'C',1    ,0 ,'Tipo Produto','Tipo Product','Product Type','Tipo do produto','Tipo de producto','Product Type','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'16' ,'ZX3_CAPTUR' ,'C',1    ,0 ,'Captura','Captura','Capture','Captura','Captura','Capture','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'17' ,'ZX3_CODRED' ,'C',6    ,0 ,'Ident. Rede','Ident. Red','Network ID','Código ident. rede','Codigo Ident rede','Network Ident. Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'18' ,'ZX3_CODBCO' ,'C',3    ,0 ,'Código banco','Codigo banco','Bank Code','Código do banco','Codigo del banco','Bank Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','007','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'19' ,'ZX3_CODAGE' ,'C',5    ,0 ,'Agência','Agencia','Branch','Código da agência','Codigo de la agencia','Branch Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','008','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'20' ,'ZX3_NUMCC'  ,'C',10   ,0 ,'Conta Corren','Cuenta Corri','Check. Acc.','Conta corrente','Cuenta corriente','Checking Account','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','009','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'21' ,'ZX3_VLCOM'  ,'N',16   ,2 ,'Vlr Comissão','Val Comision','Commis. Vl','Valor da Comissão','Valor de la comision','Commission Value','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'22' ,'ZX3_TXSERV' ,'N',5    ,2 ,'Taxa Serv','Tasa Serv','Serv. Fee','Valor da taxa de serviço','Valor de tasa de servicio','Service Fee Value','@E 99.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'23' ,'ZX3_CODLOJ' ,'C',8    ,0 ,'Loja Worldpay','Tienda Worldpay','Worldpay Store','Código da loja Worldpay','Codigo de tienda Worldpay','Worldpay Store Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'24' ,'ZX3_CODAUT' ,'C',12   ,0 ,'Autorização','Autorizacion','Authoriz.','Código de autorização','Codigo de autorizacion','Authorization Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'25' ,'ZX3_CUPOM'  ,'C',20   ,0 ,'Cupom Fiscal','Cupon Fiscal','Receipt','Cupom Fiscal','Cupon Fiscal','Receipt','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'26' ,'ZX3_SEQREG' ,'C',6    ,0 ,'Seq. Registr','Sec. Registr','Record Seq.','Seq. Registro no Arquivo','Sec Registro en Archivo','Record Sequence in File','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'27' ,'ZX3_DTAJST' ,'D',8    ,0 ,'Data Ajuste','Fecha Ajuste','Adjust. Date','Data do Ajuste','Fecha de Ajuste','Adjustment Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'28' ,'ZX3_CODMAJ' ,'C',15   ,0 ,'Motivo Ajust','Motivo Ajust','Adj. Reason','Cód. Motivo Ajuste','Cod Motivo Ajuste','Adjustment Reason Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'29' ,'ZX3_DSCMAJ' ,'C',64   ,0 ,'Desc Ajuste','Desc Ajuste','Adjust. Desc','Descrição do ajuste','Descripcion de ajuste','Adjustment Description','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'30' ,'ZX3_STATUS' ,'C',1    ,0 ,'Status','Estatus','Status','Status do Título','Estatus de Titulo','Bill Status','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','S','A','R','','','1=Não processado;2=Baixado;3=Divergente','1=No procesado;2=Bajado;3=Divergente','1=Not processed;2=Written Off;3=Divergent','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'31' ,'ZX3_DTBAIX' ,'D',8    ,0 ,'Data Baixa','Fecha Baja','Write-off Dt','Data da Baixa','Fecha de Baja','Write-off Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(198) + Chr(192),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'32' ,'ZX3_DTIMP'  ,'D',8    ,0 ,'Data Import','Fecha Import','Import Date','Data da importação','Fecha de la importacion','Import Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',,Chr(198) + Chr(192),'','','','N','','','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'33' ,'ZX3_USERGA' ,'C',17   ,0 ,'Log de Alter','Log de Mod.','Change log','Log de Alteracao','Log de Modificacion','Chang. Log','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'34' ,'ZX3_MSIMP'  ,'C',8    ,0 ,'Ident. Impor','Ident. Impor','Ident. Impor','Ident. Imp. Dados','Ident. Imp. Datos','Identif. Data Import','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'35' ,'ZX3_PREFIX' ,'C',3    ,0 ,'Prefixo','Prefijo','Prefix','Rastro Prefixo SE1','Rastro Prefijo SE1','SE1 Prefix Trace','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'36' ,'ZX3_NUM'    ,'C',9    ,0 ,'No Titulo','No Titulo','Bill Number','Rastro Titulo SE1','Rastro Titulo SE1','SE1 Bill Trace','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','018','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'37' ,'ZX3_PARC'   ,'C',1    ,0 ,'Rastro Parc.','Rastro Cuota','Inst. Trace','Rastro Parcela SE1','Rastro Cuota SE1','SE1 Installment Trace','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','011','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'38' ,'ZX3_TIPO'   ,'C',3    ,0 ,'Tipo','Tipo','Type','Rastro Tipo SE1','Rastro Tipo SE1','SE1 Type Trace','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'39' ,'ZX3_PARALF' ,'C',1    ,0 ,'Parc.Alfanum','Cuota Alf','Alf Instal.','Parcela Alfanumerica','Cuota Alf','Alf Installment','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','011','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'40' ,'ZX3_CODFIL' ,'C',2    ,0 ,'Filial','Sucursal','Branch','Filial Estab','Sucursal Estab','Estab Branch','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','033','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'41' ,'ZX3_CODBAN' ,'C',4    ,0 ,'Cod. Bandeir','Cod. Bander','Brand Code','Codigo Bandeira','Codigo Bandera','Brand Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )
aAdd(aSX3,{ 'ZX3'   ,'42' ,'ZX3_SEQZX3' ,'C',6    ,0 ,'Seq. Tab ZX3','Sec. Tab ZX3','ZX3 Tb Seq.','Sequencial','Secuencial','Sequence','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',,Chr(132) + Chr(128),'','','','S','A','R','','','','','','','','','','','','','N','N','','1','N','','S'} )

//          "X3_ARQUIVO","X3_ORDEM"   ,"X3_CAMPO"   ,"X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"    ,"X3_DESCRIC"            	,"X3_DESCSPA"				,"X3_DESCENG"               ,"X3_PICTURE"     ,"X3_VALID"  ,"X3_USADO"                                          																	      ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL","X3_RESERV"        ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"                                                                                                                        ,"X3_CBOXSPA"																													  ,"X3_CBOXENG"																													    ,"X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_TELA","X3_POSLGT","X3_IDXFLD","X3_AGRUP","X3_PYME"} 
aAdd(aSX3,{ "ZX4"       ,"01"      	  ,"ZX4_FILIAL" ,"C"      ,2           ,0           ,"Filial"	    ,"Filial"	    ,"Filial"       ,"Filial do Sistema"	    ,"Filial do Sistema"		,"Filial do Sistema"        ,"@!"             ,''          ,'€€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'€€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"02"      	  ,"ZX4_CODCLI" ,"C"      ,6           ,0           ,"Cod. Cliente"	,"Cod. Cliente" ,"Cod. Cliente" ,"Cod. Cliente"	            ,"Cod. Cliente"		        ,"Cod. Cliente"             ,"@!"             ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,"SA1"       ,0         ,'ƒ€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,"INCLUI" ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"03"      	  ,"ZX4_LOJA"   ,"C"      ,2           ,0           ,"Loja"         ,"Loja"         ,"Loja"         ,"Loja"   	                ,"Loja"         		    ,"Loja"                     ,"@!"             ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'ƒ€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,"INCLUI" ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"04"      	  ,"ZX4_CODEND" ,"C"      ,6           ,0           ,"Cod. Endereço","Cod. Endereço","Cod. Endereço","Cod. Endereço"	        ,"Cod. Endereço"		    ,"Cod. Endereço"            ,"@!"             ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'ƒ€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,"INCLUI" ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"05"         ,"ZX4_NOME"   ,"C"      ,40          ,0           ,"Nome Cliente" ,"Nome Cliente" ,"Nome Cliente" ,"Nome Cliente"	            ,"Nome Cliente"      	 	,"Nome Cliente"             ,"@!"             ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'“€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"06"         ,"ZX4_END"    ,"C"      ,60          ,0           ,"Endereço"	    ,"Endereço"     ,"Endereço"     ,"Endereço"     	        ,"Endereço"      			,"Endereço"                 ,""               ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'“€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"07"         ,"ZX4_BAIRRO" ,"C"      ,40          ,0           ,"Bairro"       ,"Bairro"       ,"Bairro"       ,"Bairro"                   ,"Bairro"            		,"Bairro"                   ,"@S15"           ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'’A'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"08"         ,"ZX4_EST"    ,"C"      ,2           ,0           ,"Estado"       ,"Estado"       ,"Estado"       ,"Estado"                   ,"Estado"                   ,"Estado"                   ,"@!"             ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,"12"        ,0         ,'‚A'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"09"         ,"ZX4_CEP"    ,"C"      ,8           ,0           ,"Cep"          ,"Cep"          ,"Cep"          ,"Cep"              	    ,"Cep"               	    ,"Cep"                      ,"@R 99999-999"   ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0         ,'’A'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"10"         ,"ZX4_CODMUN" ,"C"      ,5           ,0           ,"Cod. Mun."    ,"Cod. Mun."    ,"Cod. Mun."    ,"Cod. Mun."	            ,"Cod. Mun."	            ,"Cod. Mun."                ,""		     	  ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,"ZX4CC2"    ,0		   ,'šA'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"11"      	  ,"ZX4_MUN"    ,"C"      ,60          ,0           ,"Municipio"    ,"Municipio"    ,"Municipio"    ,"Municipio"                ,"Municipio"                ,"Municipio"                ,"@!"			  ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0		   ,'“€'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"12"         ,"ZX4_PAIS"   ,"C"      ,3           ,0           ,"Cod. País"    ,"Cod. País"    ,"Cod. País"    ,"Cod. País"                ,"Cod. País"                ,"Cod. País"                ,"@!"			  ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,"SYA"       ,0		   ,'”A'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ "ZX4"       ,"13"         ,"ZX4_COMPLE" ,"C"      ,50          ,0           ,"Complemento"  ,"Complemento"  ,"Complemento"  ,"Complemento"              ,"Complemento"              ,"Complemento"              ,"@!"			  ,''          ,'€€€€€€€€€€€€€€'																											  ,""          ,""          ,0		   ,'–A'               ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""         ,""           ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})

//Cadastro de Produtos Substitutos - OMJ 01.08.2018
//"X3_ARQUIVO"          ,"X3_ORDEM"   ,"X3_CAMPO"   ,"X3_TIPO","X3_TAMANHO"       ,"X3_DECIMAL","X3_TITULO"      ,"X3_TITSPA"      ,"X3_TITENG"     ,"X3_DESCRIC"            	,"X3_DESCSPA"				,"X3_DESCENG"               ,"X3_PICTURE"     ,"X3_VALID"                 ,"X3_USADO"                                          																											  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL","X3_RESERV"        ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"                                                                                                                        ,"X3_CBOXSPA"																													  ,"X3_CBOXENG"																													    ,"X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_TELA","X3_POSLGT","X3_IDXFLD","X3_AGRUP","X3_PYME"}            
aAdd(aSX3,{ 'ZX5'		,'01'		  ,'ZX5_FILIAL'	,'C'	  ,Len(SB1->B1_FILIAL),0           ,'Filial'         ,'Sucursal'       ,'Branch'		,'Filial do Sistema'        ,'Sucursal del Sistema'     ,'System Branch'            ,'@!'             ,''                         ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX5'		,'02'		  ,'ZX5_COD'    ,'C'      ,Len(SB1->B1_COD)   ,0           ,'Prod.Principal' ,'Prod.Principal' ,'Main Material' ,'Produto Principal'        ,'Producto Principal'       ,'Producto Principal'       ,'@!'             ,''                         ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX5'		,'03'         ,'ZX5_ORDEM'  ,'C'      ,02                 ,0           ,'Ordem'          ,'Orden'          ,'Order        ' ,'Ordem'                    ,'Orden'                    ,'Order'                    ,'@!'             ,''                         ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX5'		,'04'         ,'ZX5_PRODSU' ,'C'      ,Len(SB1->B1_COD)   ,0           ,'Prod. Subst.'   ,'Prod. Subst.'   ,'Replace Mat.'  ,'Produto Substituto'       ,'Producto Substituto'      ,'Replace Material'         ,'@!'             ,"U_N6FT5VAL('ZX5_PRODSU')" ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)																											  ,"" 	       ,"SB1"       ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       																														,""          																													  ,""       																														,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})

//"X3_ARQUIVO"          ,"X3_ORDEM"   ,"X3_CAMPO"   ,"X3_TIPO","X3_TAMANHO"       	,"X3_DECIMAL","X3_TITULO"      ,"X3_TITSPA"      ,"X3_TITENG"     ,"X3_DESCRIC"            	   ,"X3_DESCSPA"				,"X3_DESCENG"               ,"X3_PICTURE","X3_VALID"  ,"X3_USADO"                                          	,"X3_RELACAO","X3_F3"     ,"X3_NIVEL","X3_RESERV"        ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"     ,"X3_CBOXSPA" ,"X3_CBOXENG"    ,"X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_TELA","X3_POSLGT","X3_IDXFLD","X3_AGRUP","X3_PYME"}            
aAdd(aSX3,{ 'ZX6'		,'01'		  ,'ZX6_FILIAL'	,'C'	  ,Len(SC5->C5_FILIAL)	,0           ,'Filial'         ,'Filial'         ,'Filial'         ,'Filial                   '	,'Filial                   ','Filial                   ','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'02'		  ,'ZX6_DTRAX'	,'C'	  ,Len(SC5->C5_P_DTRAX)	,0       	 ,'Datatrax'       ,'Datatrax'       ,'Datatrax'       ,'Numero Datatrax'			,'Numero Datatrax'			,'Numero Datatrax'			,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'03'		  ,'ZX6_EMISSA'	,'C'	  ,08					,0           ,'Dt. Emissão'    ,'Dt. Emissão'    ,'Dt. Emissão'    ,'Data de emissão pedido'	,'Data de emissão pedido'	,'Data de emissão pedido'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'04'		  ,'ZX6_NUM'	,'C'	  ,Len(SC5->C5_NUM)		,0           ,'Num. Pedido'    ,'Num. Pedido'    ,'Num. Pedido'    ,'Numero Pedido de vendas'	,'Numero Pedido de vendas'	,'Numero Pedido de vendas'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'05'		  ,'ZX6_DOC'	,'C'	  ,09					,0           ,'Num. NF'        ,'Num. NF'        ,'Num. NF'        ,'Numero Nota Fiscal'		,'Numero Nota Fiscal'		,'Numero Nota Fiscal'		,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'06'		  ,'ZX6_SERIE'	,'C'	  ,03					,0           ,'Serie NF'       ,'Serie NF'       ,'Serie NF'       ,'Serie Nota Fiscal'			,'Serie Nota Fiscal'		,'Serie Nota Fiscal'		,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'07'		  ,'ZX6_FILE'	,'C'	  ,70					,0           ,'Nome Arquivo'   ,'Nome Arquivo'   ,'Nome Arquivo'   ,'Nome Arquivo enviado'		,'Nome Arquivo enviado'		,'Nome Arquivo enviado'		,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'08'		  ,'ZX6_DTENT'	,'C'	  ,08					,0           ,'Dt.Ent.Dtx '    ,'Dt.Ent.Dtx '    ,'Dt.Ent.Dtx '    ,'Data Entrada Pedido no DT'	,'Data Entrada Pedido no DT','Data Entrada Pedido no DT','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'09'		  ,'ZX6_HRENT'	,'C'	  ,08					,0           ,'Hr.Ent.Dtx '    ,'Hr.Ent.Dtx '    ,'Hr.Ent.Dtx '    ,'Hora Entrada Pedido no DT'	,'Hora Entrada Pedido no DT','Hora Entrada Pedido no DT','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'10'		  ,'ZX6_DTINI'	,'C'	  ,08					,0           ,'Dt.Aut.Dtx '    ,'Dt.Aut.Dtx '    ,'Dt.Aut.Dtx '    ,'Data Autoriz Pedido no DT'	,'Data Autoriz Pedido no DT','Data Autoriz Pedido no DT','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'11'		  ,'ZX6_HRINI'	,'C'	  ,08					,0           ,'Hr.Aut.Dtx '    ,'Hr.Aut.Dtx '    ,'Hr.Aut.Dtx '    ,'Hora Autoriz Pedido no DT'	,'Hora Autoriz Pedido no DT','Hora Autoriz Pedido no DT','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'12'		  ,'ZX6_DTDTX'	,'C'	  ,08					,0           ,'Dt.Datatrax'    ,'Dt.Datatrax'    ,'Dt.Datatrax'    ,'Data Entrada Pedido do DT'	,'Data Entrada Pedido do DT','Data Entrada Pedido do DT','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'13'		  ,'ZX6_HRDTX'	,'C'	  ,08					,0           ,'Hr.Datatrax'    ,'Hr.Datatrax'    ,'Hr.Datatrax'    ,'Hora Entrada Pedido do DT'	,'Hora Entrada Pedido do DT','Hora Entrada Pedido do DT','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'14'		  ,'ZX6_DTENPK' ,'C'	  ,08					,0           ,'Dt.Env.Pick'    ,'Dt.Env.Pick'    ,'Dt.Env.Pick'    ,'Data Envio Picking no WS'	,'Data Envio Picking no WS'	,'Data Envio Picking no WS'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'15'		  ,'ZX6_HRENPK' ,'C'	  ,08					,0           ,'Hr.Env.Pick'    ,'Hr.Env.Pick'    ,'Hr.Env.Pick'    ,'Hora Envio Picking no WS'	,'Hora Envio Picking no WS'	,'Hora Envio Picking no WS'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'16'		  ,'ZX6_DTREPK' ,'C'	  ,08					,0           ,'Dt.Ret.Pick'    ,'Dt.Ret.Pick'    ,'Dt.Ret.Pick'    ,'Data Retorno Picking WS'	,'Data Retorno Picking WS'	,'Data Retorno Picking WS'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'17'		  ,'ZX6_HRREPK' ,'C'	  ,08					,0           ,'Hr.Ret.Pick'    ,'Hr.Ret.Pick'    ,'Hr.Ret.Pick'    ,'Hora Retorno Picking WS'	,'Hora Retorno Picking WS'	,'Hora Retorno Picking WS'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'18'		  ,'ZX6_DTFAT'	,'C'	  ,08					,0           ,'Dt.Faturam.'    ,'Dt.Faturam.'    ,'Dt.Faturam.'    ,'Data Faturamento'			,'Data Faturamento'			,'Data Faturamento'			,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'19'		  ,'ZX6_HRFAT'	,'C'	  ,08					,0           ,'Hr.Faturam.'    ,'Hr.Faturam.'    ,'Hr.Faturam.'    ,'Hora Faturamento'			,'Hora Faturamento'			,'Hora Faturamento'			,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'20'		  ,'ZX6_DTCOSF' ,'C'	  ,08					,0           ,'Dt.Con.SEFAZ'   ,'Dt.Con.SEFAZ'   ,'Dt.Con.SEFAZ'   ,'Data Consulta Sts SEFAZ'	,'Data Consulta Sts SEFAZ'	,'Data Consulta Sts SEFAZ'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'21'		  ,'ZX6_HRCOSF' ,'C'	  ,08					,0           ,'Hr.Con.SEFAZ'   ,'Hr.Con.SEFAZ'   ,'Hr.Con.SEFAZ'   ,'Hora Consulta Sts SEFAZ'	,'Hora Consulta Sts SEFAZ'	,'Hora Consulta Sts SEFAZ'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'22'		  ,'ZX6_DTATSF' ,'C'	  ,08					,0     		 ,'Dt.Aut.SEFAZ'   ,'Dt.Aut.SEFAZ'   ,'Dt.Aut.SEFAZ'   ,'Data Autorização SEFAZ'	,'Data Autorização SEFAZ'	,'Data Autorização SEFAZ'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'23'		  ,'ZX6_HRATSF' ,'C'	  ,08					,0      	 ,'Hr.Aut.SEFAZ'   ,'Hr.Aut.SEFAZ'   ,'Hr.Aut.SEFAZ'   ,'Hora Autorização SEFAZ'	,'Hora Autorização SEFAZ'	,'Hora Autorização SEFAZ'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'24'		  ,'ZX6_DTFILE'	,'C'	  ,08					,0      	 ,'Dt.Arquivo'     ,'Dt.Arquivo'     ,'Dt.Arquivo'     ,'Data geração arq. DANFE'	,'Data geração arq. DANFE'	,'Data geração arq. DANFE'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'25'		  ,'ZX6_HRFILE'	,'C'	  ,08					,0      	 ,'Hr.Arquivo'     ,'Hr.Arquivo'     ,'Hr.Arquivo'     ,'Hora geração arq. DANFE'	,'Hora geração arq. DANFE'	,'Hora geração arq. DANFE'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'26'		  ,'ZX6_DTFLOK'	,'C'	  ,08					,0      	 ,'Dt.Conf.Arq.'   ,'Dt.Conf.Arq.'   ,'Dt.Conf.Arq.'   ,'Data Confirmado geração'	,'Data Confirmado geração'	,'Data Confirmado geração'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'27'		  ,'ZX6_HRFLOK'	,'C'	  ,08					,0   		 ,'Hr.Conf.Arq.'   ,'Hr.Conf.Arq.'   ,'Hr.Conf.Arq.'   ,'Hora Confirmado geração'	,'Hora Confirmado geração'	,'Hora Confirmado geração'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'28'		  ,'ZX6_DTZPOK'	,'C'	  ,08					,0      	 ,'Dt.ZIP.Arq.'    ,'Dt.ZIP.Arq.'    ,'Dt.ZIP.Arq.'    ,'Data Compressão arquivos'	,'Data Compressão arquivos'	,'Data Compressão arquivos'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'29'		  ,'ZX6_HRZPOK'	,'C'	  ,08					,0   		 ,'Hr.ZIP.Arq.'    ,'Hr.ZIP.Arq.'    ,'Hr.ZIP.Arq.'    ,'Hora Compressão arquivos'	,'Hora Compressão arquivos'	,'Hora Compressão arquivos'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'30'		  ,'ZX6_DTENFL'	,'C'	  ,08					,0   		 ,'Dt.Env.Arq.'    ,'Dt.Env.Arq.'    ,'Dt.Env.Arq.'    ,'Data Envio Arquivo'		,'Data Envio Arquivo'		,'Data Envio Arquivo'		,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'31'		  ,'ZX6_HRENFL'	,'C'	  ,08					,0			 ,'Hr.Env.Arq.'    ,'Hr.Env.Arq.'    ,'Hr.Env.Arq.'    ,'Hora Envio Arquivo'		,'Hora Envio Arquivo'		,'Hora Envio Arquivo'		,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'32'		  ,'ZX6_DTINFL' ,'C'	  ,08					,0     		 ,'Dt.Conf.In.'    ,'Dt.Conf.In.'    ,'Dt.Conf.In.'    ,'Data Confirmado Incoming'	,'Data Confirmado Incoming' ,'Data Confirmado Incoming' ,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'33'		  ,'ZX6_HRINFL' ,'C'	  ,08					,0           ,'Hr.Conf.in.'    ,'Hr.Conf.In.'    ,'Hr.Conf.In.'    ,'Hora Confirmado Incoming'	,'Hora Confirmado Incoming' ,'Hora Confirmado Incoming' ,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'34'		  ,'ZX6_DTOUFL' ,'C'	  ,08					,0     		 ,'Dt.Conf.Out.'   ,'Dt.Conf.Out.'   ,'Dt.Conf.Out.'   ,'Data Confirmado Outcoming'	,'Data Confirmado Outcoming','Data Confirmado Outcoming','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'35'		  ,'ZX6_HROUFL' ,'C'	  ,08					,0           ,'Hr.Conf.Out.'   ,'Hr.Conf.Out.'   ,'Hr.Conf.Out.'   ,'Hora Confirmado Outcoming'	,'Hora Confirmado Outcoming','Hora Confirmado Outcoming','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'36'		  ,'ZX6_DTFLCL'	,'C'	  ,08					,0      	 ,'Dt.Arq.Cli.'    ,'Dt.Arq.Cli.'    ,'Dt.Arq.Cli.'    ,'Data arq. Env. Cliente'	,'Data arq. Env. Cliente'	,'Data arq. Env. Cliente'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'37'		  ,'ZX6_HRFLCL'	,'C'	  ,08					,0      	 ,'Hr.Arq.Cli.'    ,'Hr.Arq.Cli.'    ,'Hr.Arq.Cli.'    ,'Hora arq. Env. Cliente'	,'Hora arq. Env. Cliente'	,'Hora arq. Env. Cliente'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'38'		  ,'ZX6_DTENCL'	,'C'	  ,08					,0      	 ,'Dt.Env.Cli.'    ,'Dt.Env.Cli.'    ,'Dt.Env.Cli.'    ,'Data Envio arquivo cli.'   ,'Data Envio arquivo cli.'  ,'Data Envio arquivo cli.'  ,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'39'		  ,'ZX6_HRENCL'	,'C'	  ,08					,0   		 ,'Hr.Env.Cli.'    ,'Hr.Env.Cli.'    ,'Hr.Env.Cli.'    ,'Hora Envio arquivo cli.'   ,'Hora Envio arquivo cli.'  ,'Hora Envio arquivo cli.'  ,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'40'		  ,'ZX6_DTOKCL'	,'C'	  ,08					,0      	 ,'Dt.Conf.Cli.'   ,'Dt.Conf.Cli.'   ,'Dt.Conf.Cli.'   ,'Data Confirmado Cliente'	,'Data Confirmado Cliente'	,'Data Confirmado Cliente'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'41'		  ,'ZX6_HROKCL'	,'C'	  ,08					,0   		 ,'Hr.Conf.Cli.'   ,'Hr.Conf.Cli.'   ,'Hr.Conf.Cli.'   ,'Hora Confirmado Cliente'	,'Hora Confirmado Cliente'	,'Hora Confirmado Cliente'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'42'		  ,'ZX6_DTSPOK'	,'C'	  ,08					,0      	 ,'Dt.Ship.OK  '   ,'Dt.Ship.OK  '   ,'Dt.Ship.OK  '   ,'Data shipping OK Fedex'	,'Data shipping OK Fedex'	,'Data shipping OK Fedex'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'43'		  ,'ZX6_HRSPOK'	,'C'	  ,08					,0   		 ,'Hr.Ship.OK  '   ,'Hr.Ship.OK  '   ,'Hr.Ship.OK  '   ,'Hora shipping OK Fedex'	,'Hora shipping OK Fedex'	,'Hora shipping OK Fedex'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'44'		  ,'ZX6_FILECS'	,'C'	  ,70					,0           ,'Nome Arq.CSV'   ,'Nome Arq.CSV'   ,'Nome Arq.CSV'   ,'Nome Arquivo Arq.CSV'		,'Nome Arquivo Arq.CSV'		,'Nome Arquivo Arq.CSV'		,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'45'		  ,'ZX6_DTFLCS'	,'C'	  ,08					,0      	 ,'Dt.Arq.CSV.'    ,'Dt.Arq.CSV.'    ,'Dt.Arq.CSV.'    ,'Data arq. Env. CSV    '	,'Data arq. Env. CSV   '	,'Data arq. Env. CSV   '	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'46'		  ,'ZX6_HRFLCS'	,'C'	  ,08					,0      	 ,'Hr.Arq.CSV.'    ,'Hr.Arq.CSV.'    ,'Hr.Arq.CSV.'    ,'Hora arq. Env. CSV    '	,'Hora arq. Env. CSV   '	,'Hora arq. Env. CSV   '	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'47'		  ,'ZX6_DTENCS'	,'C'	  ,08					,0      	 ,'Dt.Env.CSV.'    ,'Dt.Env.CSV.'    ,'Dt.Env.CSV.'    ,'Data Envio arquivo CSV '   ,'Data Envio arquivo cli.'  ,'Data Envio arquivo CSV '  ,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'48'		  ,'ZX6_HRENCS'	,'C'	  ,08					,0   		 ,'Hr.Env.CSV.'    ,'Hr.Env.CSV.'    ,'Hr.Env.CSV.'    ,'Hora Envio arquivo CSV '   ,'Hora Envio arquivo cli.'  ,'Hora Envio arquivo CSV '  ,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'49'		  ,'ZX6_DTOKCS'	,'C'	  ,08					,0      	 ,'Dt.Conf.CSV.'   ,'Dt.Conf.CSV.'   ,'Dt.Conf.CSV.'   ,'Data Confirmado CSV   '	,'Data Confirmado CSV   '	,'Data Confirmado CSV   '	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'50'		  ,'ZX6_HROKCS'	,'C'	  ,08					,0   		 ,'Hr.Conf.CSV.'   ,'Hr.Conf.CSV.'   ,'Hr.Conf.CSV.'   ,'Hora Confirmado CSV   '	,'Hora Confirmado CSV   '	,'Hora Confirmado CSV   '	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX6'		,'51'		  ,'ZX6_SITUA'	,'C'	  ,08					,0   		 ,'Situacao PV '   ,'Situacao PV '   ,'Situacao PV '   ,'Situacao PV           '	,'Situacao PV           '	,'Situacao PV           '	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})

aAdd(aSX3,{ 'ZX7'		,'01'		  ,'ZX7_FILIAL'	,'C'	  ,Len(SC5->C5_FILIAL)	,0           ,'Filial'         ,'Filial'         ,'Filial'         ,'Filial                   '	,'Filial                   ','Filial                   ','@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'02'		  ,'ZX7_DTRAX'	,'C'	  ,Len(SC5->C5_P_DTRAX)	,0       	 ,'Datatrax'       ,'Datatrax'       ,'Datatrax'       ,'Numero Datatrax'			,'Numero Datatrax'			,'Numero Datatrax'			,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'03'		  ,'ZX7_NUM'	,'C'	  ,Len(SC5->C5_NUM)		,0           ,'Num. Pedido'    ,'Num. Pedido'    ,'Num. Pedido'    ,'Numero Pedido de vendas'	,'Numero Pedido de vendas'	,'Numero Pedido de vendas'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'04'		  ,'ZX7_SEQ'	,'N'	  ,03					,0           ,'Seq. Log'	   ,'Seq. Log'		 ,'Seq. Log'	   ,'Sequencia Log'				,'Sequencia Log'			,'Sequencia Log'			,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'05'		  ,'ZX7_DATA'	,'C'	  ,08					,0           ,'Dt. Log'		   ,'Dt. Log'		 ,'Dt. Log'		   ,'Data do Log'				,'Data do Log'				,'Data do Log'				,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'06'		  ,'ZX7_HORA'	,'C'	  ,08					,0           ,'Dt. Log'		   ,'Dt. Log'		 ,'Dt. Log'		   ,'Data do Log'				,'Data do Log'				,'Data do Log'				,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'07'		  ,'ZX7_OCORR'	,'C'	  ,100					,0           ,'Ocorrencia'	   ,'Ocorrencia'	 ,'Ocorrencia'	   ,'Detalhes da Ocorrencia'	,'Detalhes da Ocorrencia'	,'Detalhes da Ocorrencia'	,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})
aAdd(aSX3,{ 'ZX7'		,'08'		  ,'ZX7_ETAPA'	,'C'	  ,30					,0           ,'Etapa'		   ,'Etapa'			 ,'Etapa'		   ,'Etapa do Log'				,'Etapa do Log'				,'Etapa do Log'				,'@!'        ,''          ,Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,"" 	       ,""          ,0         ,Chr(254) + Chr(192),""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""       	,""           ,""       	,""          ,""       ,""         ,""         ,""         ,""          ,""         ,""         ,""          ,""       ,""         ,""         ,""        ,"N"})

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
Autor......: 
Data.......: 
*/
*--------------------------------------*
Static Function NextOrdem( cAlias )
*--------------------------------------* 
Local cRet 

SX3->( DbSetOrder( 1 ) ) 

If SX3->( !DbSeek( cAlias ) )
   cRet := '01'    
Else
   SX3->( DbSkip( -1 ) )
   cRet := Soma1( SX3->X3_ORDEM )

EndIf  

Return( cRet ) 
/*
Funcao      : ATUSX6
Autor  		: 
Data     	: 
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

aEstrut:= {"X6_FIL","X6_VAR"    ,"X6_TIPO","X6_DESCRIC"                               ,"X6_DSCSPA"                                 ,"X6_DSCENG"                                ,"X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_CONTEUD"															    ,"X6_CONTSPA"																,"X6_CONTENG"															    ,"X6_PROPRI"  ,"X6_PYME","X6_VALID","X6_INIT" }
aAdd(aSX6,{""      ,"MV_P_00114","C"      ,'Email do Responsavel Faturamento Entrada' ,'Email do Responsavel Faturamento Entrad'   ,'Email do Responsavel Faturamento Entrada' ,""	      ,""	       ,""			,"flau.oliveira@hlb.com.br"			 										,"flau.oliveira@hlb.com.br"		  								            ,"flau.oliveira@hlb.com.br"		   										  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00115","C"      ,'Email do Responsavel Faturamento Saida'   ,'Email do Responsavel Faturamento Saida  '  ,'Email do Responsavel Faturamento Saida  ' ,""	      ,""	       ,""			,"jojensen@doterra.com;faturamentodoterra@hlb.com.br"			 			,"jojensen@doterra.com;faturamentodoterra@hlb.com.br"		  				,"jojensen@doterra.com;faturamentodoterra@hlb.com.br"					  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00116","C"      ,'Url do webservice da FEDEX'				  ,'Url do webservice da FEDEX'                ,'Url do webservice da FEDEX'               ,""	      ,""	       ,""			,"https://celular.rapidaocometa.com.br:51040/soap-new?service=WMS10_GENERIC","https://celular.rapidaocometa.com.br:51040/soap-new?service=WMS10_GENERIC","https://celular.rapidaocometa.com.br:51040/soap-new?service=WMS10_GENERIC","U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00117","C"      ,'Array user/pass ws Fedex'                 ,'Array user/pass ws Fedex'                  ,'Array user/pass ws Fedex'                 ,""	      ,""	       ,""			,"{'WS_DOTERRA','6DNs7SRm'}"									   			,"{'WS_DOTERRA','6DNs7SRm'}"		   								 	 	,"{'WS_DOTERRA','6DNs7SRm'}"                                                ,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00119","C"      ,'Diretorio de importacao arquivos datatrax','Diretorio de importacao arquivos datatrax' ,'Diretorio de importacao arquivos datatrax',""	      ,""	       ,""			,"\datatrax"			 													,"\datatrax"		  														,"\datatrax"	   														  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00120","C"      ,'Email receb. de erros Ret/Env Picking'    ,'Email receb. de erros Ret/Env Picking'     ,'Email receb. de erros Ret/Env Picking'    ,""	      ,""	       ,""			,"slongo@doterra.com"			 											,"slongo@doterra.com"		  												,"slongo@doterra.com"	   												  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00121","L"      ,'Ativa geração de Prod. Substituto AUTO'   ,'Ativa geração de Prod. Substituto AUTO'    ,'Ativa geração de Prod. Substituto AUTO'   ,""	      ,""	       ,""			,".T."																		,".T."		  																,".T."	   														 			,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00123","C"      ,'Endereço SFTP FEDEX'					  ,'Endereço SFTP FEDEX'					   ,'Endereço SFTP FEDEX'					   ,""	      ,""	       ,""			,"sftp1.rapidaocometa.com.br"			 									,"sftp1.rapidaocometa.com.br"		  										,"sftp1.rapidaocometa.com.br"	   										  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00124","C"      ,'Usuario SFTP FEDEX'					  	  ,'Usuario SFTP FEDEX'					  	   ,'Usuario SFTP FEDEX'					   ,""	      ,""	       ,""			,"doterra"			 										   				,"doterra"		  															,"doterra"	   															  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00125","L"      ,'Senha SFTP FEDEX'					  	  ,'Senha SFTP FEDEX'					  	   ,'Senha SFTP FEDEX'						   ,""	      ,""	       ,""			,"DOter22092"																,"DOter22092"		  														,"DOter22092"	   															,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00126","C"      ,'Endereço SFTP Cliente'					  ,'Endereço SFTP Cliente'					   ,'Endereço SFTP Cliente'					   ,""	      ,""	       ,""			,"upload.doterra.com"			 					 						,"upload.doterra.com"		  									   			,"upload.doterra.com"	   												  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00127","C"      ,'Usuario SFTP Cliente'					  ,'Usuario SFTP Cliente'				  	   ,'Usuario SFTP Cliente'					   ,""	      ,""	       ,""			,"bra_totvs"			 									   				,"bra_totvs"		  														,"bra_totvs"   															  	,"U"          ,""       ,""        ,""        })
aAdd(aSX6,{""      ,"MV_P_00128","L"      ,'Senha SFTP Cliente'					  	  ,'Senha SFTP Cliente'					  	   ,'Senha SFTP Cliente'					   ,""	      ,""	       ,""			,"aM%%40ELc7C"																,"aM%%40ELc7C"		  														,"aM%%40ELc7C"	   															,"U"          ,""       ,""        ,""        })


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
			If FieldPos(aEstrut[j])>0 .And. aSX6[i,j] != Nil .And. !(aEstrut[j] $ "X6_CONTEUD|X6_CONTSPA|X6_CONTENG")
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
Funcao      : ATUSX6
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario SX3.
*/
*-------------------------*
Static Function AtuSX1()
*-------------------------*
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )
Local cTexto  := ''

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

aAdd( aDados, {'N6FIN002','01','De Filial ?','¿De Sucursal ?','From Branch ?','MV_CH1','C',2,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','S','033','.FINA910A01.','',''} )
aAdd( aDados, {'N6FIN002','02','Ate Filial ?','¿A Sucursal ?','To Branch ?','MV_CH2','C',2,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','S','033','.FINA910A02.','',''} )
aAdd( aDados, {'N6FIN002','03','Data Crédito de ?','¿De Fecha Credito ?','Credit Date of ?','MV_CH3','D',8,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','S','','.FINA910A03.','',''} )
aAdd( aDados, {'N6FIN002','04','Data de Credito até ?','¿A Fecha de Credito ?','Credit Date until ?','MV_CH4','D',8,0,1,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','.FINA910A04.','',''} )
aAdd( aDados, {'N6FIN002','05','Do Num NSU ?','¿De Num NSU ?','From NSU Nr. ?','MV_CH5','C',9,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','S','','.FINA910A04.','',''} )
aAdd( aDados, {'N6FIN002','06','Ate Num NSU ?','¿A Num NSU ?','To NSU Nr. ?','MV_CH6','C',9,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','S','','.FINA910A05.','',''} )
aAdd( aDados, {'N6FIN002','07','Geração ?','¿Generacion ?','Generation ?','MV_CH7','N',1,0,1,'C','','MV_PAR07','Geração','Generacion','Generation','','','Individual','Individual','Individual','','','Por Lote','Por Lote','By Lot','','','','','','','','','','','','','S','','.FINA910A06.','',''} )
aAdd( aDados, {'N6FIN002','08','Tipo ?','¿Tipo ?','Type ?','MV_CH8','N',1,0,1,'C','','MV_PAR08','Débito','Debito','Debt','','','Crédito','Credito','Credit','','','','','','','','','','','','','','','','','','S','','.FINA910A08.','',''} )
aAdd( aDados, {'N6FIN002','09','Pesq Dias Ant ?','¿Busq Dias Ant ?','Prv Day Search ?','MV_CH9','N',3,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','','S','','.FINA910A09.','999',''} )
aAdd( aDados, {'N6FIN002','10','Tolerância em % ?','¿Tolerancia en % ?','Tolerance in % ?','MV_CHA','N',2,0,0,'G','','MV_PAR10','','Debito','Debt','','','','Credito','Credit','','','','','','','','','','','','','','','','','','S','','.FINA910A10.','99',''} )
aAdd( aDados, {'N6FIN002','11','De Financeira ?','¿De Financiera ?','From Finantial ?','MV_CHB','C',3,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','G3','S','','.FINA910A11.','',''} )
aAdd( aDados, {'N6FIN002','12','Ate Financeira ?','¿A Financiera ?','To Financial ?','MV_CHC','C',3,0,0,'G','','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','G3','S','','.FINA910A12.','',''} )
aAdd( aDados, {'N6FIN002','13','Data Baixa ?','¿Fecha Baja ?','Issue Date ?','MV_CHD','N',1,0,1,'C','','MV_PAR13','Database','Database','Database','','','Credito SITEF','Credito SITEF','SITEF Credit','','','','','','','','','','','','','','','','','','S','','.FINA910A13.','9',''} )
aAdd( aDados, {'N6FIN002','14','Valida NSU p/ não Conc. ?','¿Selecciona Sucursales ?','Select Branches ?','MV_CHE','N',1,0,1,'C','','MV_PAR14','Sim','Si','Yes','','','Não','No','No','','','','','','','','','','','','','','','','','','S','','.FINA910A14.','9',''} )

ProcRegua(Len(aDados))

//// Atualizando dicionário//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		cTexto += "- Pergunta " + aDados[nI][1] +" - "+ aDados[nI][3] +" criado ."+ CHR(10) + CHR(13)
		DbCommit()
		MsUnLock()
	ElseIf !empty(aDados[nI][1])
		RecLock( "SX1", .F. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		cTexto += "- Pergunta " + aDados[nI][1] +" - "+ aDados[nI][3] +" alterada ."+ CHR(10) + CHR(13)
	Else
		cTexto += "- Pergunta " + aDados[nI][1] +" - "+ aDados[nI][3] +" ja existe ."+ CHR(10) + CHR(13)
	EndIf
Next nI

RestArea( aAreaDic )
RestArea( aArea )

Return cTexto

/*
Funcao      : AtuSXB
Autor  		: 
Data     	: 
Objetivos   : Atualização do Dicionario SXB.
*/
*----------------------*
Static Function AtuSXB()
*----------------------*
Local aArea		:= GetArea()
Local cTexto	:= ''
Local aSXB		:= {}

aAdd(aSXB,{"ZX4   ","1","01","DB","Município Entidade"	,"Municipio Entidad"	,"Entity City"			,"ZX4"})
aAdd(aSXB,{"ZX4   ","2","01","01","Cod.Endereco"		,"Cod.Endereco"			,"Cod.Endereco"			,""})
aAdd(aSXB,{"ZX4   ","4","01","01","Cod.Endereco"		,"Est/Prov/Reg"			,"State"				,"ZX4_CODEND"})
aAdd(aSXB,{"ZX4   ","4","01","02","Nome"				,"Nome"					,"Nome"					,"ZX4_NOME"})
aAdd(aSXB,{"ZX4   ","4","01","03","Endereço"		   	,"Endereço"		   		,"Endereço"		   		,"ZX4_END"})
aAdd(aSXB,{"ZX4   ","4","01","04","CEP"		   			,"CEP"		   			,"CEP"		   			,"ZX4_CEP"})
aAdd(aSXB,{"ZX4   ","4","01","05","Estado"		   		,"Estado"		   		,"Estado"		   		,"ZX4_EST"})
aAdd(aSXB,{"ZX4   ","4","01","06","Município"			,"Município"			,"Município"			,"ZX4_MUN"})
aAdd(aSXB,{"ZX4   ","4","01","07","Bairro"		   		,"Bairro"		   		,"Bairro"		   		,"ZX4_BAIRRO"})
aAdd(aSXB,{"ZX4   ","5","01",""	,""						,""						,""						,"ZX4_CODEND"})
aAdd(aSXB,{"ZX4   ","6","01",""	,""						,""						,""						,"ZX4_CODCLI==M->C5_CLIENTE"})

aAdd(aSXB,{"ZX4CC2","1","01","DB","Município Entidade"		,"Municipio Entidad"	,"Entity City"		,"CC2"})
aAdd(aSXB,{"ZX4CC2","2","01","01","Estado + Codigo IBGE"	,"Es/Pr/Reg + Codigo I"	,"State + IBGE Code",""})
aAdd(aSXB,{"ZX4CC2","2","02","02","Município"				,"Municipio"			,"City"				,""})
aAdd(aSXB,{"ZX4CC2","4","01","01","Estado"					,"Est/Prov/Reg"			,"State"			,"CC2_EST"})
aAdd(aSXB,{"ZX4CC2","4","01","02","Codigo IBGE"				,"Codigo IBGE"			,"IBGE Code"		,"CC2_CODMUN"})
aAdd(aSXB,{"ZX4CC2","4","01","03","Município"				,"Municipio"			,"City"				,"CC2_MUN"})
aAdd(aSXB,{"ZX4CC2","4","02","01","Estado"					,"Estado"				,"State"			,"CC2_EST"})
aAdd(aSXB,{"ZX4CC2","4","02","02","Codigo IBGE"				,"Codigo IBGE"			,"IBGE Code"		,"CC2_CODMUN"})
aAdd(aSXB,{"ZX4CC2","4","02","03","Município"				,"Municipio"			,"City"				,"CC2_MUN"})
aAdd(aSXB,{"ZX4CC2","5","01",""	 ,""						,""						,""					,"CC2->CC2_CODMUN"})
aAdd(aSXB,{"ZX4CC2","5","02",""	 ,""						,""						,""					,"CC2->CC2_MUN"})
aAdd(aSXB,{"ZX4CC2","6","01",""	 ,""						,""						,""					,"CC2->CC2_EST==M->A1_EST"})

ProcRegua(Len(aSXB))

For i:=1 to Len(aSXB)
	lReclock := !SXB->(DbSeek(aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]))
	SXB->(RecLock("SXB",lReclock))
	SXB->XB_ALIAS	:= aSXB[i][1]
	SXB->XB_TIPO	:= aSXB[i][2]
	SXB->XB_SEQ		:= aSXB[i][3]
	SXB->XB_COLUNA	:= aSXB[i][4]
	SXB->XB_DESCRI	:= aSXB[i][5]
	SXB->XB_DESCSPA	:= aSXB[i][6]
	SXB->XB_DESCENG	:= aSXB[i][7]
	SXB->XB_CONTEM	:= aSXB[i][8]
	SXB->(MsUnLock())
	
	cTexto += "- Consulta generica "+aSXB[i][1]+"-"+aSXB[i][2]+"-"+aSXB[i][3]+IIF(lReclock," incluida"," alterada")+" com sucesso."+CHR(10)+CHR(13)
Next i

RestArea( aArea )

Return cTexto