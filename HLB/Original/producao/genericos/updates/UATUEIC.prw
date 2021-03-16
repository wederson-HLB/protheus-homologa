#INCLUDE "Protheus.ch"
//#INCLUDE "Average.ch"

/*
Funcao      : UATUEIC
Objetivos   : Atualizar integração EIC
Autor       : Tiago Luiz Mendonça
Data/Hora   : 15/07/10
*/
     
*-------------------------*
  User Function UATUEIC()    
*-------------------------*

cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

Private cMessage
Private aArqUpd	 := {"SB2","SB6","SC5","SC6","SC7","SC9","SD1","SD2","SW1","SW3","SW5","SW7","SW8","SWN","SC1","SA2"}
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
                                         .F.) , oMainWnd:End()/*, Final("Atualização efetuada.")*/),;
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
Local aChamados := {	{04, {|| AtuEIC()}}}

Private NL 		:= CHR(13) + CHR(10)
Private cMvEasy	:= "N"

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
		//RRP - 17/12/2015 - Habilitar o EIC junto com o Update	  
	  	If Len(aRecnoSM0) > 0
	  		If ApMsgNoYes("Habilitar o parâmetro MV_EASY?", "HLB BRASIL")
				cMvEasy:="S"
			Else
				cMvEasy:="N"		
			EndIf 
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
        EndIf
		 
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

*--------------------------*
  Static Function AtuEIC()
*--------------------------*

Local cTexto  := ''
Local cReserv := '' 
Local aEstrut :={}
Local aSX3    :={}
Local aCpoPuni:={}
Local aSX3C5  :={}
Local aCpoObr :={"W6_DTREG_D","W6_DI_NUM","W6_DT","W6_DT_DESE","W6_DT_EMB","W9_TX_FOB","W8_ADICAO","W8_SEQ_ADI","W0_MOEDA"}
Local cAlias  := '' 

Begin Sequence


   aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
           	   "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
        	   "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
        	   "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" , "X3_PYME"}

   DbSelectArea("SX3") // Pega o X3_RESERV e X3_USADO de um campo Usado
   SX3->(DbSetOrder(2))     
   If SX3->(MsSeek("W6_HAWB"))
      For nI := 1 To SX3->(FCount())
	      If "X3_RESERV" $ SX3->(FieldName(nI))
		     cReserv := SX3->(FieldGet(FieldPos(FieldName(nI))))
		  EndIf
	      If "X3_USADO"  $ SX3->(FieldName(nI))
		     cUsado  := SX3->(FieldGet(FieldPos(FieldName(nI))))
	      EndIf
      Next
   EndIf

   //Criação do campo W6_P_REF na tabela SW6
   aAdd(aSX3,{"SW6",;	            				//Arquivo
              "10",;								//Ordem
			  "W6_P_REF",;					    	//Campo
			  "C",;			        				//Tipo
		       50,;	                				//Tamanho
			   0,;				  					//Decimal
			  "Ref. HLB",;							//Titulo - RRP - 04/03/2013 - Alteração do nome do campo para GT antiga Pryor.
			  "Ref. HLB",;							//Titulo SPA
			  "Ref. HLB",;							//Titulo ENG
			  "Referecia HLB",;						//Descrição
			  "Referecia HLB",;						//Descrição SPA
			  "Referecia HLB",;					    //Descrição ENG
  			  "",;								    //Picture
  		      '',;              		            //Valid
			  cUsado,;				             	//Usado
			  '',;				     	            //Relação
			  "",;						            //F3
			  1,;						            //Nível
			  cReserv,;				             	//Reserv
			  "",;					            	//Check
			  "",;						            //Trigger
			  "U",;						            //Proprietário
			  "N",;						            //Browse
			  "A",;						            //Visual
			  "R",;						            //Context
			  "",;						            //Obrigat
			  "",;						            //VldUser
			  "",; 	                             	//cBox
			  "",;						            //cBox SPA
			  "",;						            //cBox ENG
			  "",;						            //PictVar
			  "",;						            //When
			  "",;						            //IniBrw
			  "",;						            //Sxg
			  "1",;						            //Folder
			  "N"})						            //Pyme
                    
 
   
   ProcRegua(Len(aSX3))

   For i:= 1 To Len(aSX3)
       If !Empty(aSX3[i][1])
		  If !DbSeek(aSX3[i,3])
		     lSX3	:= .T.
			 If !(aSX3[i,1]$cAlias)
				cAlias += aSX3[i,1]+"/"
				aAdd(aArqUpd,aSX3[i,1])
			 EndIf
			 RecLock("SX3",.T.)
			 For j:=1 To Len(aSX3[i])
				 If FieldPos(aEstrut[j])>0 .And. aSX3[i,j] != Nil
					FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
				 EndIf
			 Next j
			 DbCommit()
			 MsUnlock()
		 	 IncProc("Atualizando Dicionario de Dados...") //
		  EndIf
	   EndIf
   Next i

   cTexto += 'Campos W6_P_REF criados com sucesso. '+ NL
   
   DbSelectArea("SX2")
   SX2->(DbSetOrder(1))
	//RRP - 25/06/2013 - Retirada a empresa ED do tratamento abaixo.
	If SM0->M0_CODIGO <> "ED"
		If SX2->(DbSeek("SWX"))
      	RecLock("SX2",.F.)
      	SX2->X2_ARQUIVO := "SWXYY0"                                                      
      	SX2->(MsUnlock())
      	cTexto += "Tabela SWX foi atualizada com sucesso." +NL
		Else
			cTexto += "ATENÇÃO: A Tabela SWX não foi encontrado no SX2" +NL
		EndIf
   
		If SX2->(DbSeek("SWZ"))
			RecLock("SX2",.F.)
			SX2->X2_ARQUIVO := "SWZYY0"                                                      
 			SX2->(MsUnlock())
			cTexto += "Tabela SWZ foi atualizada com sucesso." +NL
		Else
			cTexto += "ATENÇÃO: A Tabela SWZ não foi encontrado no SX2" +NL
		EndIf
	EndIf  
   
   If SX2->(DbSeek("SYF"))
      RecLock("SX2",.F.)
      SX2->X2_ARQUIVO := "SYFYY0"                                                      
      SX2->(MsUnlock())
      cTexto += "Tabela SYF foi atualizada com sucesso." +NL
   Else
      cTexto += "ATENÇÃO: A Tabela SYF não foi encontrado no SX2" +NL
   EndIf   
   
   If SX2->(DbSeek("SYA"))
      RecLock("SX2",.F.)
      SX2->X2_ARQUIVO := "SYAYY0"                                                      
      SX2->(MsUnlock())
      cTexto += "Tabela SYA foi atualizada com sucesso." +NL
   Else
      cTexto += "ATENÇÃO: A Tabela SYA não foi encontrado no SX2" +NL
   EndIf  
   
   DbSelectArea("SX3")
   SX3->(DbSetOrder(2)) 
   
   SX3->(DbSeek("WX_COD"))   
   cReserv:=SX3->X3_RESERV  
   
   IF SX3->(DbSeek("W6_FREMOED")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "20"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_FREMOED foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("W6_VLFREPP")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "21"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_VLFREPP foi atualizado." + NL 
   EndIF 
   
   IF SX3->(DbSeek("W6_VL_FRET")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "21"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_VL_FRET foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("W6_VLFRECC")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "22"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_SEGMOED foi atualizado." + NL 
   EndIF
   
   IF SX3->(DbSeek("W6_TX_FRET")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "21"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_TX_FRET foi atualizado." + NL 
   EndIF 
   

   IF SX3->(DbSeek("W6_VL_USSE")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "23"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_VL_USSE foi atualizado." + NL 
   EndIF
   
   IF SX3->(DbSeek("W6_SEGMOED")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "22"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_SEGMOED foi atualizado." + NL 
   EndIF      
   
   IF SX3->(DbSeek("W6_TX_SEG ")) 
      RecLock("SX3", .F.)
      SX3->X3_ORDEM:= "23"
      SX3->(MsUnlock())
      cTexto += "O ordem do campo W6_TX_SEG  foi atualizado." + NL 
   EndIF   
   
   
   IF SX3->(DbSeek("W6_PO_NUM")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_PO_NUM foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("D1_CONHEC")) 
      RecLock("SX3", .F.)
      SX3->X3_VLDUSER:='U_VldCpo("D1_TES")'
      SX3->(MsUnlock())
      cTexto += "O campo D1_CONHEC foi atualizado." + NL 
   EndIF        
                                                                                                               
   IF SX3->(DbSeek("W6_DTREG_D")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_DTREG_D foi atualizado." + NL 
   EndIF   
   
   IF SX3->(DbSeek("W6_DI_NUM")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_DI_NUM foi atualizado." + NL 
   EndIF   
   
   IF SX3->(DbSeek("W6_DT")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_DT foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("W6_DT_DESE")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_DT_DESE foi atualizado." + NL 
   EndIF   
   
   IF SX3->(DbSeek("W6_DT_EMB")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_DT_EMB foi atualizado." + NL 
   EndIF   
   
   IF SX3->(DbSeek("W2_DESP")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W2_DESP foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("W2_DESP")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W2_DESP foi atualizado." + NL 
   EndIF    
   
   IF SX3->(DbSeek("B1_IMPORT")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo B1_IMPORT foi atualizado." + NL 
   EndIF    
   
      IF SX3->(DbSeek("W6_REC_ALF")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_REC_ALF foi atualizado." + NL 
   EndIF    
   
      IF SX3->(DbSeek("W2_DESP")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W2_DESP foi atualizado." + NL 
   EndIF    
   
   IF SX3->(DbSeek("W6_LOCAL")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_LOCAL foi atualizado." + NL 
   EndIF 
   
   IF SX3->(DbSeek("W6_MODAL_D")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_MODAL_D foi atualizado." + NL 
   EndIF 
   
   IF SX3->(DbSeek("W6_URF_DES")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W6_URF_DES foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("W9_TX_FOB")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo W9_TX_FOB foi atualizado." + NL 
   EndIF  
   
   IF SX3->(DbSeek("A5_FABR")) 
      RecLock("SX3", .F.)
      SX3->X3_RESERV:= cReserv
      SX3->(MsUnlock())
      cTexto += "O campo A5_FABR foi atualizado." + NL 
   EndIF

	//RRP - 16/11/2016 - Campos Obrigatórios
	For nR := 1 To Len(aCpoObr)
		IF SX3->(DbSeek(aCpoObr[nR])) 
			RecLock("SX3", .F.)
				SX3->X3_OBRIGAT := "€"
			SX3->(MsUnlock())
			cTexto += "Campo atualizado: "+SX3->X3_CAMPO+ NL
		EndIF
	Next nR
	
	IF SX3->(DbSeek("W1_DT_EMB")) 
		RecLock("SX3", .F.)
			SX3->X3_RELACAO := "dDataBase"
		SX3->(MsUnlock())
		cTexto += "Campo atualizado: "+SX3->X3_CAMPO+ NL
	EndIF
	IF SX3->(DbSeek("W1_DTENTR_")) 
		RecLock("SX3", .F.)
			SX3->X3_RELACAO := "dDataBase"
		SX3->(MsUnlock())
		cTexto += "Campo atualizado: "+SX3->X3_CAMPO+ NL
	EndIF
            
   
   DbSelectArea("SX6")
   SX6->(DbSetOrder(1))
   
   IF SX6->(DbSeek(xFilial()+"MV_EASY"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := cMvEasy
      SX6->(MsUnlock()) 
      cTexto += "Parametro MV_EASY  foi atualizado." + NL
   EndIf	
	
   IF SX6->(DbSeek(xFilial()+"MV_EASYFIN"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := "N"
      SX6->(MsUnlock())
      cTexto += "Parametro MV_EASYFIN  foi atualizado." + NL
   EndIf
   
   IF SX6->(DbSeek(xFilial()+"MV_EASYFPO"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := "N"
      SX6->(MsUnlock())
      cTexto += "Parametro MV_EASYFPO  foi atualizado." + NL
   EndIf	
  
   IF SX6->(DbSeek(xFilial()+"MV_ESPEIC"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := "SPED"
      SX6->(MsUnlock())
      cTexto += "Parametro MV_ESPEIC  foi atualizado." + NL
   Else
   	  RecLock("SX6",.T.)
      SX6->X6_VAR     := "MV_ESPEIC"  
      SX6->X6_TIPO    := "C"
      SX6->X6_DESCRIC := "Especie gerada a partir do EIC"
      SX6->X6_CONTEUD := "SPED"     
      SX6->(MsUnlock()) 
      cTexto += "Parametro MV_ESPEIC  foi atualizado." + NL 
   EndIf 
   
   IF SX6->(DbSeek(xFilial()+"MV_TXSIRAT"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := "T"
      SX6->(MsUnlock())
      cTexto += "Parametro MV_TXSIRAT  foi atualizado." + NL
   EndIf

   IF SX6->(DbSeek(xFilial()+"MV_UTILEIB"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := "T"
      SX6->(MsUnlock())
      cTexto += "Parametro MV_UTILEIB foi atualizado." + NL
   EndIf
   
   //RRP - 15/07/2016 - Solicitação Aline.
   IF SX6->(DbSeek(xFilial()+"MV_EIC0028"))
      RecLock("SX6",.F.)
      SX6->X6_CONTEUD := ".F."
      SX6->(MsUnlock())
      cTexto += "Parametro MV_EIC0028 foi atualizado." + NL
   EndIf   
	
	DbSelectArea("SX2")
	DbSetOrder(1)
	If SX2->(DbSeek("SF1"))
		cModo:=SX2->X2_MODO
	
		If SX2->(DbSeek("SW"))
		
			while SX2->(!EOF()) .AND. "SW" $ SX2->X2_CHAVE 
			if !SUBSTR(SX2->X2_ARQUIVO,4,2)=='YY'
			      RecLock("SX2",.F.)
			      	SX2->X2_MODO := cModo
			      SX2->(MsUnlock())
			cTexto += "Alterado modo da tabela: "+SX2->X2_CHAVE+ NL
			endif
			SX2->(DbSkip())
			enddo
		
		Endif
	
		If SX2->(DbSeek("SY"))
		
			while SX2->(!EOF()) .AND. "SY" $ SX2->X2_CHAVE 
			if !SUBSTR(SX2->X2_ARQUIVO,4,2)=='YY'
			      RecLock("SX2",.F.)
			      	SX2->X2_MODO := cModo
			      SX2->(MsUnlock())
			cTexto += "Alterado modo da tabela: "+SX2->X2_CHAVE+ NL
			endif
			SX2->(DbSkip())
			enddo
		
		Endif
		
		If SX2->(DbSeek("EI"))
		
			while SX2->(!EOF()) .AND. "EI" $ SX2->X2_CHAVE 
			if !SUBSTR(SX2->X2_ARQUIVO,4,2)=='YY'
			      RecLock("SX2",.F.)
			      	SX2->X2_MODO := cModo
			      SX2->(MsUnlock())
			cTexto += "Alterado modo da tabela: "+SX2->X2_CHAVE+ NL
			endif
			SX2->(DbSkip())
			enddo
		Endif
	
	Endif
    //RRP - 03/09/2013 - Inclusão da customização de atualizar Adição.
	DbSelectArea("SIX")
	DbSetOrder(1)
	IF UPPER(Alltrim(SubStr(GetEnvServer(),1,3))) = "P11"

	If !(SIX->(DbSeek("SW1"+"5")))
		RecLock("SIX",.T.)
		SIX->INDICE := "SW1"
		SIX->ORDEM := "5"
		SIX->CHAVE := "W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I+STR(W1_QTDE,13,3)"
		SIX->DESCRICAO := "Cod. do Bem + Item"
		SIX->DESCSPA := "Bien + Item"
		SIX->DESCENG := "Goods Code + Item"
		SIX->PROPRI := "S"
		SIX->SHOWPESQ:= "S"
		SIX->(MsUnlock())
		cTexto += "Indice Criado: "+SIX->INDICE+ NL
	Else
	cTexto += "Indice já Existente: "+SIX->INDICE+ NL
	EndIf

	ELSE

	If !(SIX->(DbSeek("SW1"+"6")))
		RecLock("SIX",.T.)
		SIX->INDICE := "SW1"
		SIX->ORDEM := "6"
		SIX->CHAVE := "W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I+STR(W1_QTDE,13,3)"
		SIX->DESCRICAO := "Cod. do Bem + Item"
		SIX->DESCSPA := "Bien + Item"
		SIX->DESCENG := "Goods Code + Item"
		SIX->PROPRI := "S"
		SIX->SHOWPESQ:= "S"
		SIX->NICKNAME:= "SW1CUST"
		SIX->(MsUnlock())
		cTexto += "Indice Criado: "+SIX->INDICE+ NL
	Else
	cTexto += "Indice já Existente: "+SIX->INDICE+ NL
	EndIf

	ENDIF
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If !(SX3->(DbSeek("W1_P_ADI")))
		RecLock("SX3",.T.)
		SX3->X3_ARQUIVO		:= "SW1"
		SX3->X3_ORDEM		:= "11"
		SX3->X3_CAMPO		:= "W1_P_ADI"
		SX3->X3_TIPO		:= "C"
		SX3->X3_TAMANHO		:= 3
		SX3->X3_DECIMAL		:= 0
		SX3->X3_TITULO		:= "Adicao"
		SX3->X3_TITSPA		:= "Adicao"
		SX3->X3_TITENG		:= "Adicao"
		SX3->X3_DESCRIC		:= "Adicao"
		SX3->X3_DESCSPA		:= "Adicao"
		SX3->X3_DESCENG		:= "Adicao"
		SX3->X3_USADO		:= "€€€€€€€€€€€€€€°"
		SX3->X3_NIVEL		:= 1
		SX3->X3_RESERV		:= "€"
		SX3->X3_PROPRI		:= "U"
		SX3->X3_BROWSE		:= "N"
		SX3->X3_VISUAL		:= "A"
		SX3->X3_CONTEXT		:= "R"
		SX3->X3_FOLDER		:= "1"
		SX3->X3_PYME		:= "N"
		SX3->(MsUnlock())
		cTexto += "Campo Criado: "+SX3->X3_CAMPO+ NL
	Else
		cTexto += "Campo já Existente: "+SX3->X3_CAMPO+ NL
	EndIf
	
	If !(SX3->(DbSeek("W1_P_SEQAD")))
		RecLock("SX3",.T.)
		SX3->X3_ARQUIVO		:= "SW1"
		SX3->X3_ORDEM		:= "12"
		SX3->X3_CAMPO		:= "W1_P_SEQAD"
		SX3->X3_TIPO		:= "C"
		SX3->X3_TAMANHO		:= 3
		SX3->X3_DECIMAL		:= 0
		SX3->X3_TITULO		:= "Seq Adicao"
		SX3->X3_TITSPA		:= "Seq Adicao"
		SX3->X3_TITENG		:= "Seq Adicao"
		SX3->X3_DESCRIC		:= "Seq Adicao"
		SX3->X3_DESCSPA		:= "Seq Adicao"
		SX3->X3_DESCENG		:= "Seq Adicao"
		SX3->X3_USADO		:= "€€€€€€€€€€€€€€°"
		SX3->X3_NIVEL		:= 1
		SX3->X3_RESERV		:= "€"
		SX3->X3_PROPRI		:= "U"
		SX3->X3_BROWSE		:= "N"
		SX3->X3_VISUAL		:= "A"
		SX3->X3_CONTEXT		:= "R"
		SX3->X3_FOLDER		:= "1"
		SX3->X3_PYME		:= "N"
		SX3->(MsUnlock())
		cTexto += "Campo Criado: "+SX3->X3_CAMPO+ NL
	Else
		cTexto += "Campo já Existente: "+SX3->X3_CAMPO+ NL
	EndIf
    //RRP - 04/09/2013 - Incluindo Municipio EX
    DbSelectArea("CC2")
	CC2->(DbSetOrder(1))
	If !(CC2->(DbSeek(xFilial("CC2")+"EX"+"9999")))
		RecLock("CC2",.T.)
		CC2->CC2_EST		:= "EX"
		CC2->CC2_CODMUN		:= "99999"
		CC2->CC2_MUN		:= "EX"
		CC2->(MsUnlock())
		cTexto += "Código criado: "+CC2->CC2_CODMUN+ NL
	Else
		cTexto += "Código já Existente: "+CC2->CC2_CODMUN+ NL
	EndIf
    //RRP - 15/07/2016 - Ajuste nos impostos de Pis e Cofins
    DbSelectArea("SYB")
	SYB->(DbSetOrder(1))
	If SYB->(DbSeek(xFilial("SYB")+"412"))
		If Alltrim(SYB->YB_DESCR)=="COFINS" 
			RecLock("SYB",.F.)
				SYB->YB_DESP := "205"
			SYB->(MsUnlock())
			cTexto += "Código COFINS Atualizado: "+SYB->YB_DESP+ NL
		Else
			cTexto += "Código 412 não é PIS!"+ NL	
		EndIf
	Else
		cTexto += "Código 412 não encontrado!"+ NL
	EndIf
	If SYB->(DbSeek(xFilial("SYB")+"413"))
		If Alltrim(SYB->YB_DESCR)=="PIS" 
			RecLock("SYB",.F.)
				SYB->YB_DESP := "204"
			SYB->(MsUnlock())
			cTexto += "Código PIS Atualizado: "+SYB->YB_DESP+ NL
		Else
			cTexto += "Código 413 não é PIS!"+ NL	
		EndIf
	Else
		cTexto += "Código 413 não encontrado!"+ NL
	EndIf

	//RRP - 04/09/2013 - Altera o conteudo do campo X3_OBRIGAT para obrigatório e X3_USADO com o módulo estoque incluso.
	SX3->(DbSetOrder(2))
	If SX3->(DBSeek("A2_PAIS"))
		RecLock("SX3", .F.)
		SX3->X3_OBRIGAT := '€'
		SX3->X3_USADO	:= 'ˆ€‘‚ð€€A€€€€€€€'
		SX3->(MsUnlock())
		cTexto += "Campo atualizado: "+SX3->X3_CAMPO+ NL
	EndIf
	If SX3->(DBSeek("A2_ID_FBFN"))
		RecLock("SX3", .F.)
		SX3->X3_OBRIGAT := '€'
		SX3->X3_USADO := '€€€€€€€€€€€€€€'
		SX3->(MsUnlock())
		cTexto += "Campo atualizado: "+SX3->X3_CAMPO+ NL
	EndIf
	If SX3->(DBSeek("A2_FABRICA"))
		RecLock("SX3", .F.)
		SX3->X3_OBRIGAT := '€'
		SX3->X3_USADO := '€€€€€€€€€€€€€€'
		SX3->(MsUnlock())
		cTexto += "Campo atualizado: "+SX3->X3_CAMPO+ NL	  
	EndIf
	//RRP - 06/09/2013 - Alterar as casas decimais do preço unitário para 5 padrão do EIC.
	aCpoPuni := {"B2_CM1","B6_PRUNIT","C6_PRCVEN","C6_PRUNIT","C7_PRECO","C9_PRCVEN","D1_VUNIT","D2_PRCVEN","D2_PRUNIT","W3_PRECO";
				 ,"W5_PRECO","W7_PRECO","W7_PRECO_R","W8_PRECO","W8_PRECO_R","WN_PRECO","WN_PRUNI","C1_VUNIT","C1_PRECO","W1_PRECO"}
				 
	For k := 1 To Len(aCpoPuni)
		If SX3->(DBSeek(aCpoPuni[k])) .And. SX3->X3_DECIMAL < 5
			SX3->(RecLock("SX3", .F.))
	   		SX3->X3_TAMANHO	:=	15
			SX3->X3_DECIMAL	:=	5
	   		SX3->X3_PICTURE	:=	"@E 999,999,999.99999"
	   		SX3->(MsUnlock())
			cTexto += "Campo atualizado: "+aCpoPuni[k]+ NL
		EndIf		
	Next k 
	//RRP - 17/12/2015 - Inclusão dos campos customizados realizar a inclusão do pedido de armazengem automático.
	cOrdem := NextOrdem( 'SC5' )
	
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_NOTA"	,"C",Len(SF1->F1_DOC)	,0,"NF.Forn"	,"NF.Forn"		,"NF.Forn"		,"Nota Fiscal Fornecedor"	,"Nota Fiscal Fornecedor"	,"Nota Fiscal Fornecedor"	,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","N","V","R",'',"","","","","","","","","","N"})
	cOrdem := Soma1( cOrdem )
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_SERIE"	,"C",Len(SF1->F1_SERIE)	,0,"Serie"		,"Serie"		,"Serie"		,"Serie NF.Forn."			,"Serie NF.Forn."			,"Serie NF.Forn."			,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","N","V","R",'',"","","","","","","","","","N"})
	cOrdem := Soma1( cOrdem )
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_FORN"	,"C",Len(SA2->A2_COD)	,0,"Cod.Forn."	,"Cod.Forn."	,"Cod.Forn."	,"Codigo do fornecedor"		,"Codigo do fornecedor"		,"Codigo do fornecedor"		,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","N","V","R",'',"","","","","","","","","","N"})
	cOrdem := Soma1( cOrdem )
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_LOJA"	,"C",Len(SA2->A2_LOJA)	,0,"Loja Forn."	,"Loja Forn."	,"Loja Forn."	,"Loja do fornecedor"		,"Loja do fornecedor"		,"Loja do fornecedor"		,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","N","V","R",'',"","","","","","","","","","N"})
	cOrdem := Soma1( cOrdem )
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_FNOME"	,"C",Len(SA2->A2_NREDUZ),0,"Nome Forn."	,"Nome Forn."	,"Loja Forn."	,"Loja do fornecedor"		,"Loja do fornecedor"		,"Loja do fornecedor"		,"@!",'','€€€€€€€€€€€€€€€',"IF(INCLUI,'',POSICIONE('SA2',1,XFILIAL('SA2')+M->C5_P_FORN+M->C5_P_LOJA,'A2_NREDUZ'))" ,"",0,'',"","","U","N","V","V",'',"","","","","","","","","","N"})
	cOrdem := Soma1( cOrdem )
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_IMP"	,"C",Len(SF1->F1_HAWB)	,0,"Processo"	,"Processo"		,"Processo"		,"Processo Importacao"		,"Processo Importacao"		,"Processo Importacao"		,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","N","V","R",'',"","","","","","","","","","N"})
	cOrdem := Soma1( cOrdem )
	aAdd(aSX3C5,{"SC5",cOrdem,"C5_P_EMISS"	,"D",8					,0,"Emissao NF"	,"Emissao NF"	,"Emissao NF"	,"Data Emissao NF Forn."	,"Data Emissao NF Forn."	,"Data Emissao NF Forn."	,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","N","V","R",'',"","","","","","","","","","N"})   
	//RSB - 23/05/2017 - Solicitação Aline.
	aAdd(aSX3C5,{"SD1","T7"  ,"D1_OBS"		,"C",80					,0,"OBSERVACAO"	,"OBSERVACAO"	,"OBSERVACAO"	,"OBSERVACAO"				,"OBSERVACAO"				,"OBSERVACAO"				,"@!",'','€€€€€€€€€€€€€€€',"" ,"",0,'',"","","U","S","A","R",'',"","","","","","","","","","N"})                                                                      	
	
	//RRP - 28/03/2017 - Estava duplicando os campos.
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))  
	For i:= 1 To Len(aSX3C5)
		If !Empty(aSX3C5[i][1])
			If !(SX3->(DbSeek(aSX3C5[i][3])))
				RecLock("SX3",.T.)
				For j:=1 To Len(aSX3C5[i])
					If FieldPos(aEstrut[j])>0 .And. aSX3C5[i,j] != Nil
						FieldPut(FieldPos(aEstrut[j]),aSX3C5[i,j])
					EndIf
				Next j
				cTexto += "Campo Criado. '"+aSX3C5[i,3]+"'"+ NL
				DbCommit()
				MsUnlock()
			Else
		   		cTexto += "Campo já existe. '"+aSX3C5[i,3]+"'"+ NL
			EndIf		
		EndIf
	Next i

End Sequence

Return cTexto

//RRP - 17/12/2015 - Inclusão do selecionador de empresa.
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

/*
Função.....: NextOrdem
Objetivo...: Retorna proxima ordem do sx3
Autor......: Renato Rezende
Data.......: 17/12/2015
*/
*--------------------------------------*
Static Function NextOrdem( cAlias )
*--------------------------------------* 
Local cRet 

SX3->(DbSetOrder(1)) 

If SX3->(!DbSeek(cAlias))
   cRet := '01'   
   
ElseIf SX3->(DbSeek(cAlias + 'ZZ' , .T. ))
   cRet := 'ZZ'

Else
   SX3->(DbSkip( -1 ))
   cRet := Soma1(SX3->X3_ORDEM)
EndIf  

Return(cRet)