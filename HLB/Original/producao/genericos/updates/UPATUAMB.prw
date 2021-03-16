#INCLUDE "Protheus.ch"
/*
Funcao      : UPATUAMB
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizações de Dicionário
Autor       : Eduardo C. Romanini
Data/Hora   : 30/05/2011 - 11:15
Obs.        : Uso especifico HLB BRASIL.
*/
*----------------------*
User Function UPATUAMB()
*----------------------*

cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 

Begin Sequence
   Set Dele On

   lHistorico 	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faca um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")
   lEmpenho	:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| AtuProc(@lEnd)},"Processando","Aguarde , processando preparação dos arquivos",.F.) , Final("Atualização efetuada!")),oMainWnd:End())

End Sequence
	   
Return

*---------------------------*
Static Function AtuProc(lEnd)
*---------------------------*
Local cTexto    := ''
Local cFile     :=""
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    := 0
Local nI        := 0
Local nX        :=0
Local aRecnoSM0 := {}     
Local lOpen     := .F. 

Begin Sequence
   ProcRegua(1)
   IncProc("Verificando integridade dos dicionários....")
   If ( lOpen := MyOpenSm0Ex() )

      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof() 
  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 EndIf			
		 dbSkip()
	  EndDo	
		
	  If lOpen
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2) 
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 nModulo := 05 //SigaFAT
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)
	  		 ProcRegua(1)
       		 // Atualiza o dicionario de dados.³
			 IncProc("Analisando Dicionario de Dados...")
			 cTexto += AtuDic()
			
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
					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
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

*----------------------*
Static Function AtuDic()
*----------------------*
Local lSX3 := .F.
Local lSX6 := .F.

Local cTexto  := ""
Local cCampos := ""

Local i := 0
Local j := 0

Local aSX3       := {}
Local aSX3Estrut := {}
Local aSX6       := {}
Local aSX6Estrut := {}

//Parametros
aSX6Estrut:= { "X6_FILIAL" ,"X6_VAR"     ,"X6_TIPO"    ,"X6_DESCRIC" ,"X6_DSCSPA"  ,"X6_DSCENG"  ,"X6_DESC1"  ,"X6_DSCSPA1" ,"X6_DSCENG1" ,;
               "X6_DESC2"  ,"X6_DSCSPA2" ,"X6_DSCENG2" ,"X6_CONTEUD" ,"X6_CONTSPA" ,"X6_CONTENG" ,"X6_PROPRI" ,"X6_PYME"}  


//         "X6_FILIAL" ,"X6_VAR"     ,"X6_TIPO" ,"X6_DESCRIC"                                        ,"X6_DSCSPA"                                         ,"X6_DSCENG"                                         ,"X6_DESC1"                                          ,"X6_DSCSPA1"                                        ,"X6_DSCENG1"                                        ,"X6_DESC2"                                       ,"X6_DSCSPA2"                                      ,"X6_DSCENG2"                                ,"X6_CONTEUD" ,"X6_CONTSPA" ,"X6_CONTENG" ,"X6_PROPRI" ,"X6_PYME"
Aadd(aSX6,{ "  "       ,"MV_GRBLOCM" ,"L"       ,"Define se  na geracao do SPED PIS COFINS o bloco  ","Define se  na geracao do SPED PIS COFINS o bloco  ","Define se  na geracao do SPED PIS COFINS o bloco  ","M sera calculado pelo ERP ou nao. T o bloco M sera","M sera calculado pelo ERP ou nao. T o bloco M sera","M sera calculado pelo ERP ou nao. T o bloco M sera","calculado, F o bloco M nao sera calculado."     ,"calculado, F o bloco M nao sera calculado."      ,"calculado, F o bloco M nao sera calculado.",".T."        ,".T."        ,".T."          ,"S"       ,"S"      })
Aadd(aSX6,{ "  "       ,"MV_ASSIMED" ,"C"       ,"Informe 2 para calcular assistencia medica pelo no","Informe 2 para calcular assistencia medica pelo no","Informe 2 para calcular assistencia medica pelo no","vo modelo                                         ","vo modelo                                         ","vo modelo                                         ",""                                               ,""                                                ,""                                          ,"2"          ,"2"          ,"2"            ,"S"       ,"S"      })
Aadd(aSX6,{ "  "       ,"MV_CODREG " ,"C"       ,"Codigo de regime tributario do emitente           ","Codigo de regime tributario do emitente           ","Codigo de regime tributario do emitente           ","1 - Simples Nacional 2 - Simples Nacional - excess","1 - Simples Nacional 2 - Simples Nacional - excess","1 - Simples Nacional 2 - Simples Nacional - excess","de sublimite da receita bruta 3 - Regime Normal","de sublimite da receita bruta 3 - Regime Normal" ,""                                          ,"3"          ,"3"          ,"3"            ,"S"       ,"S"      })

//Campos
aSX3Estrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
               "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
               "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
               "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"}

 SX3->(DbSetOrder(1)) 
 SX3->(DbGoTop())  
 SX3->(DbSeek("SRW")) 
 SX3->(DbSkip(-1))    
         
//          "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"    ,"X3_DESCRIC"               ,"X3_DESCSPA"               ,"X3_DESCENG"               ,"X3_PICTURE" ,"X3_VALID"                                                                                       ,"X3_USADO"      ,"X3_RELACAO","X3_F3" ,"X3_NIVEL" ,"X3_RESERV","X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR" ,"X3_WHEN" ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"
cOrdem := Soma1(SX3->X3_ORDEM)                    
Aadd(aSX3,{ "SRV"        ,cOrdem     ,"RV_CODDSR "  ,"C"       ,3            ,0            ,"Verba DSR   " ,"Verba DSR   " ,"Verba DSR   " ,"Verba p pagamento do DSR ","Verba p pagamento do DSR ","Verba p pagamento do DSR ", "999"       ,"Vazio() .Or. (EXISTCPO('SRV',,1) .And. M->RV_COD # M->RV_CODDSR) .and. fCodDsrVld(M->RV_CODDSR)","€€€€€€€€€€€€€€",""          ,"SRV"   ,1          ,"þA"       ,""         ,""           ,""          ,"S"         ,""          ,"R"         ,""          ,""          ,""       ,""          ,""          ,""           ,""        ,""          ,""          ,"1"         ,"S"      })
cOrdem := Soma1(cOrdem)                    
Aadd(aSX3,{ "SRV"        ,cOrdem     ,"RV_PAYROLL " ,"L"       ,1            ,0            ,"Imp.Payroll?" ,"Imp.Payroll?" ,"Imp.Payroll?" ,"Imprime Payroll?         ","Imprime Payroll?         ","Imprime Payroll?         ", ""          ,""                                                                                               ,"€€€€€€€€€€€€€€",""          ,"   "   ,1          ,"þA"       ,""         ,""           ,""          ,"S"         ,""          ,"R"         ,""          ,""          ,""       ,""          ,""          ,""           ,""        ,""          ,""          ,""          ,"S"      })
cOrdem := Soma1(cOrdem)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
Aadd(aSX3,{ "SRV"        ,cOrdem     ,"RV_DPAYROL " ,"C"       ,15           ,0            ,"Col. Payroll" ,"Col. Payroll" ,"Col. Payroll" ,"Descricao Coluna Payroll ","Descricao Coluna Payroll ","Descricao Coluna Payroll ", "@!"        ,""                                                                                               ,"€€€€€€€€€€€€€€",""          ,"   "   ,1          ,"þA"       ,""         ,""           ,""          ,"S"         ,""          ,"R"         ,""          ,""          ,""       ,""          ,""          ,""           ,""        ,""          ,""          ,""          ,"S"      })


////////////////////////////////////
//Inicio da Gravação de Parametros//
////////////////////////////////////

cAlias := ""   
   
ProcRegua(Len(aSX6))

DbSelectArea("SX6")
SX6->(DbSetOrder(1))

For i:= 1 To Len(aSX6)
	If !dbSeek(aSX6[i,1]+aSX6[i,2])
		If !(aSX6[i,2]$cAlias)
			lSX6	:= .T.
			cAlias  += aSX6[i,2]+"/"
		EndIf
		RecLock("SX6",.T.)
		For j:=1 To Len(aSX6[i])
			If FieldPos(aSX6Estrut[j])>0 .And. aSX6[i,j] != NIL
				FieldPut(FieldPos(aSX6Estrut[j]),aSX6[i,j])
			EndIf
		Next j                                                    
		dbCommit()
		MsUnLock()
		IncProc("Atualizando Dicionario de Dados...") //

	Else
		If Alltrim(SX6->X6_CONTEUD) <> aSX6[i,13]
			If !(aSX6[i,2]$cAlias)
				lSX6	:= .T.
				cAlias  += AllTrim(aSX6[i,2])+"/"
			EndIf
			RecLock("SX6",.F.)
			For j:=13 To 15
				If FieldPos(aSX6Estrut[j])>0 .And. aSX6[i,j] != NIL
					FieldPut(FieldPos(aSX6Estrut[j]),aSX6[i,j])
				EndIf
			Next j                                                    
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Dicionario de Dados...") //
		EndIf
	Endif
Next i

If lSX6
	cTexto += 'Foram atualizados os seguintes parâmetros : ' + cAlias + CHR(13) + CHR(10)
EndIf

////////////////////////////////
//Inicio da Gravação de Campos//
////////////////////////////////
cCampos := ""   
   
ProcRegua(Len(aSX3))

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For i:= 1 To Len(aSX3)
	If !dbSeek(aSX3[i,3])
		If !(aSX3[i,3]$cCampos)
			lSX3	:= .T.
			cCampos  += aSX3[i,3]+"/"
			aAdd(aArqUpd,aSX3[i,1])
		EndIf
		RecLock("SX3",.T.)
		For j:=1 To Len(aSX3[i])
			If FieldPos(aSX3Estrut[j])>0 .And. aSX3[i,j] != NIL
				FieldPut(FieldPos(aSX3Estrut[j]),aSX3[i,j])
			EndIf
		Next j
      
		dbCommit()
		MsUnLock()
		IncProc("Atualizando Dicionario de Dados...") //
	Endif
Next i

If lSX3
	cTexto += 'Foram incluídos os seguintes campos : ' + cCampos + CHR(13) + CHR(10)
EndIf


///////////
//Tabelas//
///////////   
DbSelectArea("SX2")
SX2->(DbSetOrder(1))

If SX2->(DbSeek("SYA"))
	If AllTrim(SX2->X2_ARQUIVO) <> "SYAYY0"
		RecLock("SX2",.F.)
		SX2->X2_ARQUIVO := "SYAYY0"                                                      
		SX2->(MsUnlock())
		cTexto += "Tabela SYA foi atualizada com sucesso." + CHR(13) + CHR(10)
	EndIf
Else
	cTexto += "ATENÇÃO: A Tabela SYA não foi encontrado no SX2" + CHR(13) + CHR(10)
EndIf  

If Empty(cTexto)
	cTexto := "Nenhuma atualização foi necessária" + CHR(13) + CHR(10)
EndIf

Return cTexto

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
      Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen ) 
