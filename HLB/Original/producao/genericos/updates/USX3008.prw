#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : USX3008
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização do Dicionario de dados
Autor       : Jean Victor Rocha
Data/Hora   : 15/02/2012
*/

User Function USX3008()

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
                                         .F.) , Final("Atualização efetuada.")),;
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

      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof()
  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		 EndIf
		 dbSkip()
	  EndDo

	  If lOpen
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

*-----------------------*
 Static Function AtuSX3()
*-----------------------*
Local cTexto  := ''
Local cReserv := '' 
Local aEstrut :={}
Local aSX3    :={}
Local cAlias  := '' 

Begin Sequence

   aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
           	   "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
        	   "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
        	   "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" , "X3_PYME"}

   DbSelectArea("SX3") // Pega o X3_RESERV e X3_USADO de um campo Usado
   SX3->(DbSetOrder(2))     
   If SX3->(MsSeek("W1_COD_I"))
      For nI := 1 To SX3->(FCount())
	      If "X3_RESERV" $ SX3->(FieldName(nI))
		     cReserv := SX3->(FieldGet(FieldPos(FieldName(nI))))
		  EndIf
	      If "X3_USADO"  $ SX3->(FieldName(nI))
		     cUsado  := SX3->(FieldGet(FieldPos(FieldName(nI))))
	      EndIf
      Next
   EndIf

   aAdd(aSX3,{"SRR",;	            				//Arquivo
              "15",;								//Ordem
			  "RR_PERIODO",;					    	//Campo
			  "C",;			        				//Tipo
		       6,;	                				//Tamanho
			   0,;				  					//Decimal
			  "Periodo",;          		    //Titulo
			  "Periodo",;  			        //Titulo SPA
			  "Period",;	    	  			//Titulo ENG
			  "Periodo",;             //Descrição
			  "Periodo",;             //Descrição SPA
			  "Period",;	            //Descrição ENG
  			  "@!",;							    //Picture
  		      "ExistCpo('RCH')",;              		            //Valid
			  cUsado,;				             	//Usado
			  '',;				     	            //Relação
			  "",;						            //F3
			  1,;						            //Nível
			  cReserv,;				             	//Reserv
			  "",;					            	//Check
			  "",;						            //Trigger
			  "",;						            //Proprietário
			  "N",;						            //Browse
			  "V",;						            //Visual
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
			  "",;						            //Folder
			  ""})						            //Pyme

     aAdd(aSX3,{"SRR",;	            				//Arquivo
              "16",;								//Ordem
			  "RR_ROTEIR",;					    	//Campo
			  "C",;			        				//Tipo
		       3,;	                				//Tamanho
			   0,;				  					//Decimal
			  "Roteiro",;          		    //Titulo
			  "Procedimient",;  			        //Titulo SPA
			  "Route",;	    	  			//Titulo ENG
			  "Roteiro de Calculo",;             //Descrição
			  "Procedimiento de Calculo",;             //Descrição SPA
			  "Calculation Route",;	            //Descrição ENG
  			  "@!",;							    //Picture
  		      "Vazio() .or. ExistCpo('SRY')",;              		            //Valid
			  cUsado,;				             	//Usado
			  '',;				     	            //Relação
			  "",;						            //F3
			  1,;						            //Nível
			  cReserv,;				             	//Reserv
			  "",;					            	//Check
			  "",;						            //Trigger
			  "",;						            //Proprietário
			  "N",;						            //Browse
			  "V",;						            //Visual
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
			  "",;						            //Folder
			  ""})						            //Pyme
     
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
		 	 IncProc("Atualizando Dicionario de Dados...")
		 	 cTexto += 'Campos '+aSX3[i][3]+' criados com sucesso. '+ NL
		  EndIf
	   EndIf
   Next i

End Sequence

Return cTexto