#INCLUDE 'TOTVS.CH'
#include "PROTHEUS.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include "TbiCode.ch"

/*
Funcao      : USZZ001
Objetivos   : Update para criação da tabela SZZ - Relacionamento de verbas com a ADP
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Módulo      : 07 - SigaGPE - Gestão de Pessoal
*/
*---------------------*
User Function USZZ001()
*---------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {}
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
                                         .F.) ,oMainWnd:End()/* Final("Atualização efetuada.")*/),;
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

Local aAtuDic := { {07, {|| AtuSIX()}},;
				   {07, {|| AtuSX2()}},;
                   {07, {|| AtuSX3()}},;
                   {07, {|| AtuSXB()}}}
Local aAtuTab := {}

Private NL := CHR(13) + CHR(10)
   

If MsgYesNo("Deseja executar as atualizações de Implantação?")
	aAtuTab := { {07, {|| AtuSZZ()}},;
                 {07, {|| AtuSRV()}}}
EndIf

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

	  If lOpen  := MyOpenSm0Ex()
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aAtuDic para cada 
	  		    módulo. */
	  		 For i := 1 To Len(aAtuDic)
  	  		    nModulo := aAtuDic[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aAtuDic[i,2] )
			 Next

             /* Neste ponto o sistema atualizará a 
                estrutura das tabelas informadas no
                array aArqUpd. */
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
			 
			 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aAtuTab para cada 
	  		    módulo. */
	  		 For i := 1 To Len(aAtuTab)
  	  		    nModulo := aAtuTab[i,1]
  	  		    ProcRegua(1)
			    IncProc("Atualizado dados das tabelas...")
			    cTexto += EVAL( aAtuTab[i,2] )
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
Objetivos   : Efetua a abertura do SM0 exclusivo
Obs.        :
*/
*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. )//Compartilhado
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
Funcao      : AtuSIX
Objetivos   : Atualizar o dicionário de dados SIX - Índices
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSIX()
*----------------------*
Local cTexto := ""

Local nI := 0
Local nJ := 0

Local lSIX := .F.

Local aEstrut := {}
Local aSIX    := {}

aEstrut:= {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"}

aAdd(aSIX,{"SZZ",;               	//INDICE
           "1",;                    //ORDEM
           "ZZ_FILIAL+ZZ_COD",;     //CHAVE
           "FILIAL + CODIGO" ,;     //DESCRICAO
           "FILIAL + CODIGO" ,;     //DESCSPA
           "FILIAL + CODIGO" ,;     //DESCENG
           "S",;                    //PROPRI
           "",;   	                //F3
           "",;   	                //NICKNAME
           "S"})                    //SHOWPESQ

dbSelectArea("SIX")
ProcRegua(Len(aSIX))
SIX->(DbSetOrder(1))
For nI:= 1 To Len(aSIX)
	If !Empty(aSIX[nI][1])
		lSIX := !DbSeek(aSIX[nI,1])
		SIX->(RecLock("SIX",lSIX))
		For nJ:=1 To Len(aSIX[nI])
			If FieldPos(aEstrut[nJ])>0 .And. aSIX[nI,nJ] != Nil
				FieldPut(FieldPos(aEstrut[nJ]),aSIX[nI,nJ])
			EndIf
		Next
		cTexto += "- SIX Atualizado com sucesso. '"+aSIX[nI,1]+"-"+aSIX[nI,2]+"'"+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Índices...")
	EndIf
Next

Return cTexto

/*
Funcao      : AtuSX2
Objetivos   : Atualizar o dicionário de dados SX2 - Tabelas
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSX2()
*----------------------*
Local cTexto := ""

Local nI := 0
Local nJ := 0

Local lSX2 := .F.

Local aEstrut := {}
Local aSX2    := {}


aEstrut:= { "X2_CHAVE"  ,"X2_PATH" ,"X2_ARQUIVO","X2_NOME" ,"X2_NOMESPA","X2_NOMEENG","X2_ROTINA" ,"X2_MODO" ,"X2_MODOUN" ,;
			"X2_MODOEMP","X2_DELET","X2_TTS"    ,"X2_UNICO","X2_PYME"   ,"X2_MODULO" ,"X2_DISPLAY"}


aAdd(aSX2,{"SZZ",; 						//X2_CHAVE
           "\SYSTEM\",;         	    //X2_PATH
           "SZZYY0",;					//X2_ARQUIVO
           "Relacionamento Verba ADP",;	//X2_NOME
           "Relacionamento Verba ADP",;	//X2_NOMESPA
           "Relacionamento Verba ADP",;	//X2_NOMEENG
           "",;							//X2_ROTINA
           "C",;						//X2_MODO
           "C",;						//X2_MODOUN
           "C",;						//X2_MODOEMP
           0,;							//X2_DELET
           "",;							//X2_TTS
           "ZZ_FILIAL+ZZ_COD",;	   		//X2_UNICO
           "N",;						//X2_PYME
           7,;							//X2_MODULO
           ""})							//X2_DISPLAY           

dbSelectArea("SX2")
ProcRegua(Len(aSX2))
SX2->(DbSetOrder(1))
For nI:= 1 To Len(aSX2)
	If !Empty(aSX2[nI][1])
		lSX2 := !DbSeek(aSX2[nI,1])
		SX2->(RecLock("SX2",lSX2))
		For nJ:=1 To Len(aSX2[nI])
			If FieldPos(aEstrut[nJ])>0 .And. aSX2[nI,nJ] != Nil
				FieldPut(FieldPos(aEstrut[nJ]),aSX2[nI,nJ])
			EndIf
		Next
		cTexto += "- SX2 Atualizado com sucesso. '"+aSX2[nI,1]+"'"+ CHR(10) + CHR(13)
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Tabelas...") //
	EndIf
Next

Return cTexto


/*
Funcao      : AtuSX3
Objetivos   : Atualizar o dicionário de dados SIX - Campos
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSX3()
*----------------------*
Local cTexto := ""
Local cAlias := ""

Local nI := 0
Local nJ := 0

Local lSX3 := .F.

Local aEstrut := {}
Local aSX3    := {}

X3_RESERV     := "þÀ"
X3_RE_FILIAL  := "€€"
X3_OBRIGAT    := "€"
X3_USADO      := "€€€€€€€€€€€€€€ "
X3_NAOUSADO   := "€€€€€€€€€€€€€€€"

aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
			"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
			"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
			"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}

aAdd(aSX3,{"SZZ",;            			//X3_ARQUIVO
           "01",;						//X3_ORDEM
           "ZZ_FILIAL",; 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           2,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Filial",;                   //X3_TITULO
           "Sucursal",;                 //X3_TITSPA
           "Branch",;                   //X3_TITENG
           "Filial",;                   //X3_DESCRIC
           "Sucursal",;                 //X3_DESCSPA
           "Branch",;                   //X3_DESCENG
           "",;                         //X3_PICTURE
           "",;                         //X3_VALID
           X3_NAOUSADO,; 		        //X3_USADO
           "",;                         //X3_RELACAO
           "",;                         //X3_F3
           1,;                          //X3_NIVEL
           X3_RE_FILIAL,;               //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "A",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           "",;	                        //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "033",;                      //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

aAdd(aSX3,{"SZZ",;            			//X3_ARQUIVO
           "02",;						//X3_ORDEM
           "ZZ_COD",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           9,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Codigo",;                   //X3_TITULO
           "Codigo",;	                //X3_TITSPA
           "Codigo",;                   //X3_TITENG
           "Codigo",;                   //X3_DESCRIC
           "Codigo",;                   //X3_DESCSPA
           "Codigo",;	                //X3_DESCENG
           "@!",;                       //X3_PICTURE
           "",;                         //X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           "",;                         //X3_RELACAO
           "",;                         //X3_F3
           1,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "V",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           X3_OBRIGAT,;                 //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "",;                         //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

aAdd(aSX3,{"SZZ",;            			//X3_ARQUIVO
           "03",;						//X3_ORDEM
           "ZZ_DESCR",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           60,;                         //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Descricao",;                //X3_TITULO
           "Descricao",;                //X3_TITSPA
           "Descricao",;                //X3_TITENG
           "Descricao",;                //X3_DESCRIC
           "Descricao",;                //X3_DESCSPA
           "Descricao",;                //X3_DESCENG
           "@!",;                       //X3_PICTURE
           "",;                         //X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           "",;                         //X3_RELACAO
           "",;                         //X3_F3
           1,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           "",;                         //X3_CHECK
           "",;                         //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "V",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           X3_OBRIGAT,;                 //X3_OBRIGAT
           "",;                         //X3_VLDUSER
           "",;                         //X3_CBOX
           "",;                         //X3_CBOXSPA
           "",;                         //X3_CBOXENG
           "",;                         //X3_PICTVAR
           "",;                         //X3_WHEN
           "",;                         //X3_INIBRW
           "",;                         //X3_GRPSXG
           "",;                         //X3_FOLDER
           "N"})                        //X3_PYME

aAdd(aSX3,{"SRV",;            			//X3_ARQUIVO
           "G8",;	 						//X3_ORDEM
           "RV_XGRP",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           9,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
	       "Grp Verba",;              	//X3_TITULO
           "Grp Verba",;                //X3_TITSPA
           "Grp Verba",;                //X3_TITENG
           "Grp Verba   para arq SRF ",;//X3_DESCRIC
           "Grp Verba   para arq SRF ",;//X3_DESCSPA
           "Grp Verba   para arq SRF ",;//X3_DESCENG
           "@!",;                       //X3_PICTURE
           ,;                         	//X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           ,;                         	//X3_RELACAO
           "SZZ",;                     	//X3_F3
           ,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           ,;                         	//X3_CHECK
           "S",;                        //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "A",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           'VAZIO() .OR. EXISTCPO("SZZ",M->RV_XGRP,1)';	//X3_VLDUSER
           ,;                         	//X3_CBOX
           ,;                         	//X3_CBOXSPA
           ,;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           })                        	//X3_PYME

aAdd(aSX3,{"SRV",;            			//X3_ARQUIVO
           ,;	 						//X3_ORDEM
           "RV_XGPDESC",;	            //X3_CAMPO
           ,;                           //X3_TIPO
           ,;                           //X3_TAMANHO
           ,;                           //X3_DECIMAL
           ,;              				//X3_TITULO
           ,;                			//X3_TITSPA
           ,;                			//X3_TITENG
           ,;                			//X3_DESCRIC
           ,;                			//X3_DESCSPA
           ,;                			//X3_DESCENG
           ,;                       	//X3_PICTURE
           ,;                         	//X3_VALID
           ,; 	    	        		//X3_USADO
           'PADR(IF(!INCLUI,POSICIONE("SZZ",1,XFILIAL("SZZ")+  SRV->RV_XGRP ,"ZZ_DESCR"),""),30)',;//X3_RELACAO
           ,; 	                    	//X3_F3
           ,;                          	//X3_NIVEL
           ,;                  			//X3_RESERV
           ,;                         	//X3_CHECK
           ,;                         	//X3_TRIGGER
           ,;                        	//X3_PROPRI
           ,;                        	//X3_BROWSE
           ,;                        	//X3_VISUAL
           ,;                        	//X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           ,;							//X3_VLDUSER
           ,;                         	//X3_CBOX
           ,;                         	//X3_CBOXSPA
           ,;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           })                        	//X3_PYME

aAdd(aSX3,{"SRV",;            			//X3_ARQUIVO
           ,;	 						//X3_ORDEM
           "RV_XSINAL",;	            //X3_CAMPO
           ,;                           //X3_TIPO
           ,;                           //X3_TAMANHO
           ,;                           //X3_DECIMAL
           ,;              				//X3_TITULO
           ,;                			//X3_TITSPA
           ,;                			//X3_TITENG
           ,;                			//X3_DESCRIC
           ,;                			//X3_DESCSPA
           ,;                			//X3_DESCENG
           ,;                       	//X3_PICTURE
           ,;                         	//X3_VALID
           X3_NAOUSADO,;        		//X3_USADO
           ,;                           //X3_RELACAO
           ,; 	                    	//X3_F3
           ,;                          	//X3_NIVEL
           ,;                  			//X3_RESERV
           ,;                         	//X3_CHECK
           ,;                         	//X3_TRIGGER
           ,;                        	//X3_PROPRI
           ,;                        	//X3_BROWSE
           ,;                        	//X3_VISUAL
           ,;                        	//X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           ,;							//X3_VLDUSER
           ,;                         	//X3_CBOX
           ,;                         	//X3_CBOXSPA
           ,;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           })                        	//X3_PYME

aAdd(aSX3,{"SRV",;            			//X3_ARQUIVO
           "68",;	 						//X3_ORDEM
           "RV_P_ADP",;		            //X3_CAMPO
           "C",;                        //X3_TIPO
           1,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
           "Grp. ADP",;              	//X3_TITULO
           "Grp. ADP",;                	//X3_TITSPA
           "Grp. ADP",;                 //X3_TITENG
           "Grupo ADP",;               	//X3_DESCRIC
           "Grupo ADP",;                //X3_DESCSPA
           "Grupo ADP",;              	//X3_DESCENG
           "@!",;                      	//X3_PICTURE
           "",;                        	//X3_VALID
           "€€€€€€€€€€€€€€ ",;       	//X3_USADO
           ,;                           //X3_RELACAO
           ,; 	                    	//X3_F3
           ,;                          	//X3_NIVEL
           "þA",;                  		//X3_RESERV
           ,;                         	//X3_CHECK
           ,;                         	//X3_TRIGGER
           "U",;                       	//X3_PROPRI
           "N",;                       	//X3_BROWSE
           "A",;                       	//X3_VISUAL
           "R",;                       	//X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           ,;							//X3_VLDUSER
           "1=Gross Pay;2=Employee deductions;3=Net Pay;4=Employer contributions",;                         	//X3_CBOX
           "1=Gross Pay;2=Employee deductions;3=Net Pay;4=Employer contributions",;                         	//X3_CBOXSPA
           "1=Gross Pay;2=Employee deductions;3=Net Pay;4=Employer contributions",;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           "N"})                       	//X3_PYME

aAdd(aSX3,{"SRA",;            			//X3_ARQUIVO
           "P5",;	 						//X3_ORDEM
           "RA_XNACION",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           2,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
	       "Nacionalid. ",;              	//X3_TITULO
           "Nacionalid. ",;                //X3_TITSPA
           "Nacionalid. ",;                //X3_TITENG
           "Nacionalidade - Cidadania ",;//X3_DESCRIC
           "Nacionalidade - Cidadania ",;//X3_DESCSPA
           "Nacionalidade - Cidadania ",;//X3_DESCENG
           "@!",;                       //X3_PICTURE
           ,;                         	//X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           'IF(INCLUI,"BR",SRA->RA_XNACION)',;                         	//X3_RELACAO
           "ZZZ06",;                     	//X3_F3
           ,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           ,;                         	//X3_CHECK
           "S",;                        //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "A",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           'EXISTCPO("ZZZ","06"+PADR(M->RA_XNACION,LEN(CRIAVAR("RA_XNACION"))))';	//X3_VLDUSER
           ,;                         	//X3_CBOX
           ,;                         	//X3_CBOXSPA
           ,;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           })                        	//X3_PYME
           
aAdd(aSX3,{"SRA",;            			//X3_ARQUIVO
           "P6",;	 						//X3_ORDEM
           "RA_XCONTRB",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           2,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
	       "Pais Nascim.",;              	//X3_TITULO
           "Pais Nascim.",;                //X3_TITSPA
           "Pais Nascim.",;                //X3_TITENG
           "Pais de Nascimento        ",;//X3_DESCRIC
           "Pais de Nascimento        ",;//X3_DESCSPA
           "Pais de Nascimento        ",;//X3_DESCENG
           "@!",;                       //X3_PICTURE
           ,;                         	//X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           'IF(INCLUI,"BR",SRA->RA_XCONTRB)',;                         	//X3_RELACAO
           "ZZZ06_",;                     	//X3_F3
           ,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           ,;                         	//X3_CHECK
           "S",;                        //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "A",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           'EXISTCPO("ZZZ","06"+PADR(M->RA_XCONTRB,LEN(CRIAVAR("RA_XCONTRB"))))';	//X3_VLDUSER
           ,;                         	//X3_CBOX
           ,;                         	//X3_CBOXSPA
           ,;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           })                        	//X3_PYME

aAdd(aSX3,{"SRA",;            			//X3_ARQUIVO
           "P7",;	 						//X3_ORDEM
           "RA_XJOBCL",;	 	            //X3_CAMPO
           "C",;                        //X3_TIPO
           1,;                          //X3_TAMANHO
           0,;                          //X3_DECIMAL
	       "Job Classif.",;              	//X3_TITULO
           "Job Classif.",;                //X3_TITSPA
           "Job Classif.",;                //X3_TITENG
           "Job Classification        ",;//X3_DESCRIC
           "Job Classification        ",;//X3_DESCSPA
           "Job Classification        ",;//X3_DESCENG
           "@!",;                       //X3_PICTURE
           ,;                         	//X3_VALID
           X3_USADO,; 	    	        //X3_USADO
           "2",;                         	//X3_RELACAO
           ,;                     	//X3_F3
           ,;                          //X3_NIVEL
           X3_RESERV,;                  //X3_RESERV
           ,;                         	//X3_CHECK
           "S",;                        //X3_TRIGGER
           "U",;                        //X3_PROPRI
           "N",;                        //X3_BROWSE
           "A",;                        //X3_VISUAL
           "R",;                        //X3_CONTEXT
           ,;                 			//X3_OBRIGAT
           'Pertence("12345")',;	//X3_VLDUSER
           "1=Apprentice;2=Employee;3=Worker;4=Supervisor;5=Director",;                         	//X3_CBOX
           "1=Apprentice;2=Employee;3=Worker;4=Supervisor;5=Director",;                         	//X3_CBOXSPA
           "1=Apprentice;2=Employee;3=Worker;4=Supervisor;5=Director",;                         	//X3_CBOXENG
           ,;                         	//X3_PICTVAR
           ,;                         	//X3_WHEN
           ,;                         	//X3_INIBRW
           ,;                         	//X3_GRPSXG
           ,;                         	//X3_FOLDER
           })                        	//X3_PYME

dbSelectArea("SX3")
ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))
For nI:= 1 To Len(aSX3)
	If !Empty(aSX3[nI][1])
		lSX3:= !DbSeek(AllTrim(aSX3[nI,3]))
		If !(lSX3 .and. aSX3[nI,2] == Nil)
			If !(aSX3[nI,1]$cAlias)
				cAlias += aSX3[nI,1]+"/"
				aAdd(aArqUpd,aSX3[nI,1])
			EndIf
			RecLock("SX3",lSX3)
			For nJ:=1 To Len(aSX3[nI])
				If FieldPos(aEstrut[nJ])>0 .And. aSX3[nI,nJ] != Nil
					FieldPut(FieldPos(aEstrut[nJ]),aSX3[nI,nJ])
				EndIf
			Next
			DbCommit()
			MsUnlock()
			IncProc("Atualizando Dicionario de Campos...")
		EndIf
	EndIf
Next

If !Empty(cAlias)
	cTexto += "- SX3 Atualizado com sucesso. '"+cAlias+"'"+ CHR(10) + CHR(13)
EndIf

Return cTexto

/*
Funcao      : AtuSXB
Objetivos   : Atualizar o dicionário de dados SXB - Consultas
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSXB()
*----------------------*
Local cTexto := ""
Local cAlias := ""

Local nI := 0
Local nJ := 0

Local lSXB := .F.

Local aEstrut := {}
Local aSXB    := {}

aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM"}

aADD(aSXB,{"SZZ   ",;  	 //"XB_ALIAS"
           "1",;         //XB_TIPO
           "01",;        //XB_SEQ
           "DB",;        //XB_COLUNA
           "VERBA ADP",; //XB_DESCRI
           "VERBA ADP",; //XB_DESCSPA
           "VERBA ADP",; //XB_DESCENG
           "SZZ",;       //XB_CONTEM
           ""})          //XB_WCONTEM

aADD(aSXB,{"SZZ   ",;    		//"XB_ALIAS"
           "2",;        		//XB_TIPO
           "01",;       		//XB_SEQ
           "01",;        		//XB_COLUNA
           "Filial+Codigo",;    //XB_DESCRI
           "Filial+Codigo",;    //XB_DESCSPA
           "Filial+Codigo",;    //XB_DESCENG
           "",;        		    //XB_CONTEM
           ""})        		    //XB_WCONTEM

aADD(aSXB,{"SZZ   ",;  	 //"XB_ALIAS"
           "3",;         //XB_TIPO
           "01",;        //XB_SEQ
           "01",;        //XB_COLUNA
           "Novo",;      //XB_DESCRI
           "Nuevo",;     //XB_DESCSPA
           "New",;       //XB_DESCENG
           "01",;        //XB_CONTEM
           ""})          //XB_WCONTEM

aADD(aSXB,{"SZZ   ",;  	 	//"XB_ALIAS"
           "4",;         	//XB_TIPO
           "01",;        	//XB_SEQ
           "01",;        	//XB_COLUNA
           "Codigo",;      	//XB_DESCRI
           "Codigo",;     	//XB_DESCSPA
           "Codigo",;       //XB_DESCENG
           "SZZ->ZZ_COD",;	//XB_CONTEM
           ""})          	//XB_WCONTEM
           
aADD(aSXB,{"SZZ   ",;  	 	//"XB_ALIAS"
           "4",;         	//XB_TIPO
           "01",;        	//XB_SEQ
           "02",;        	//XB_COLUNA
           "Descricao",;   	//XB_DESCRI
           "Descricao",;   	//XB_DESCSPA
           "Descricao",;    //XB_DESCENG
           "SZZ->ZZ_DESCR",;//XB_CONTEM
           ""})          	//XB_WCONTEM

aADD(aSXB,{"SZZ   ",;  	 	//"XB_ALIAS"
           "5",;         	//XB_TIPO
           "01",;        	//XB_SEQ
           "  ",;        	//XB_COLUNA
           "",;   			//XB_DESCRI
           "",;   			//XB_DESCSPA
           "",;    			//XB_DESCENG
           "SZZ->ZZ_COD",;	//XB_CONTEM
           ""})          	//XB_WCONTEM

dbSelectArea("SXB")                      
ProcRegua(Len(aSXB))
SXB->(DbSetOrder(1))
For nI:= 1 To Len(aSXB)
	If !Empty(aSXB[nI][1])
		lSXB := !DbSeek(aSXB[nI,1]+aSXB[nI,2]+aSXB[nI,3]+aSXB[nI,4])
		If !(aSXB[nI,1]$cAlias)
			cAlias += aSXB[nI,1]+"/"
		EndIf
		SXB->(RecLock("SXB",lSXB))
		For nJ:=1 To Len(aSXB[nI])
			If FieldPos(aEstrut[nJ])>0 .And. aSXB[nI,nJ] != Nil
				FieldPut(FieldPos(aEstrut[nJ]),aSXB[nI,nJ])
			EndIf
		Next
		DbCommit()
		MsUnlock()
		IncProc("Atualizando Dicionario de Consultas...")
	EndIf
Next

If !Empty(cAlias)
	cTexto += "- SXB Atualizado com sucesso. '"+cAlias+"'"+ CHR(10) + CHR(13)
EndIf

Return cTexto   

/*
Funcao      : AtuSZZ
Objetivos   : Atualizar a tabela SZZ
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSZZ()
*----------------------*
Local cTexto := ""

Local nI := 0

Local aSZZ   := {{"GSL_BSS","Basic salary"},;
                 {"GSL_SMS","Supplementary month salary"},;                      
                 {"GSL_SBC","Stand by period compensation"},;                       
                 {"GSL_OTC","Overtime compensation"},;                               
                 {"GSL_BNS","Bonus"},;                                               
                 {"GSL_COM","Commission"},;                                         
                 {"GSL_OVS","Other variable salary"},;                               
                 {"GSL_LEAV","Leaver s payments"},;                                  
                 {"GSL_HSD","Holidays salary deduction"},;                           
                 {"GSL_HSC","Holidays compensation"},;                               
                 {"GSL_LSD","Other leaves salary deduction"},;                       
                 {"GSL_LSC","Other leaves compensation"},;                           
                 {"GSL_NTHC","Not taken holidays compensation"},;                     
                 {"GSL_CCYN","Company Car Benefit in Kind (Y/N)"},;                   
                 {"GSL_CCBIK","Company Car Benefit in Kind (amount)"},;                
                 {"GSL_OBIK","Other benefits in kind"},;                              
                 {"GSL_HALW","Housing allowance"},;                                   
                 {"GSL_MALW","Meal allowance"},;                                     
                 {"GSL_TALW","Travel allowance"},;                                    
                 {"GSL_CALW","Car allowance"},;
                 {"GSL_OALW","Other allowances"},;                                    
                 {"GSL_FEX","Fixed expenses"},;                                      
                 {"GSL_TPP","Third Party payments (gross)"},;                        
                 {"EED_WTX","Employee s wage tax (withheld by the employer)"},;      
                 {"EED_CSS","Employee s compulsory Social Security deduction"},;     
                 {"EED_CRT","Employee s compulsory retirement deduction"},;          
                 {"EED_CUN","Employee s compulsory unemployment deduction"},;        
                 {"EED_CMC","Employee s additional medical care deduction"},;        
                 {"EED_COTH","Other compulsory or additional employee s deductions"},;
                 {"EED_VRT","Employee s voluntary retirement deduction"},;           
                 {"EED_VMC","Employee s voluntary medical care deduction"},;         
                 {"EED_VOTH","Other Employee s voluntary deductions"},;               
                 {"NTP_SPPD","Stock purchase plan deduction"},;                       
                 {"NTP_EXRF","Expenses refund and advances"},;                        
                 {"NTP_EXPA","Expatriate expenses refund"},;                          
                 {"NTP_BIK","Benefits in Kind deduction"},;                          
                 {"NTP_ONAD","Other Net adjustments"},;                               
                 {"NTP_SAA","Salary Advance Adjustments"},;                          
                 {"NTP_TPP","Third Party payments (net)"},;                          
                 {"ERC_WTX","Employer s wage tax (surrogate)"},;                     
                 {"ERC_CSS","Employer s compulsory Social Security Contribution"},;  
                 {"ERC_CRT","Employer s compulsory retirement contribution"},;       
                 {"ERC_CUN","Employer s compulsory unemployment contribution"},;     
                 {"ERC_CMC","Employer s additional medical care contribution"},;     
                 {"ERC_MCC","Employer s miscellaneous compulsory contributions"},;   
                 {"ERC_AWI","Employer s compulsory accident at work insurance"},;    
                 {"ERC_MCI","Employer s miscellaneous compulsory insurances"},;      
                 {"ERC_MTX","Employer s miscellaneous taxes"},;                      
                 {"ERC_VOTH","Employer s miscellaneous voluntary contribution"},;     
                 {"ACR_HLS","Holidays accrual"},;                                    
                 {"ACR_HLC","Contributions accrual on holidays accrual"},;           
                 {"ACR_BNS","Bonus accrual"},;                                       
                 {"ACR_BNC","Contributions accrual on bonus accrual"},;              
                 {"ACR_SMS","Supplementary month accrual"},;                         
                 {"ACR_SMC","Contributions accrual on month accrual"},;              
                 {"EXT_CCBIK","Company Car Benefit in Kind (not in gross)"},;          
                 {"EXT_OBIK","Other benefits in kind (not in gross)"},;
                 {"NOT_USED","Not used in SRF file"}}


For nI:=1 To Len(aSZZ)
	
	IncProc("Atualizando Tabela SZZ...")

	SZZ->(DbSetOrder(1))
	If SZZ->(DbSeek(xFilial("SZZ")+aSZZ[nI][1]))
		SZZ->(RecLock("SZZ",.F.))
		SZZ->ZZ_DESCR := AllTrim(aSZZ[nI][2])
		SZZ->(MsUnlock())
	Else
		SZZ->(RecLock("SZZ",.T.))
		SZZ->ZZ_FILIAL := xFilial("SZZ")
		SZZ->ZZ_COD    := AllTrim(aSZZ[nI][1])		
		SZZ->ZZ_DESCR  := AllTrim(aSZZ[nI][2])
		SZZ->(MsUnlock())
	EndIf
Next

cTexto += "- SZZ Atualizado com sucesso."+ CHR(10) + CHR(13)

Return cTexto

/*
Funcao      : AtuSRV
Objetivos   : Atualizar a tabela SZZ
Autor       : Eduardo C. Romanini
Data/Hora   : 01/09/2015 16:30
Obs         :
*/
*----------------------*
Static Function AtuSRV()
*----------------------*
Local cTexto := ""

Local nI := 0

Local aSRV := {{"001","GSL_BSS"},;
               {"002","NTP_SAA"},;
               {"003","GSL_SMS"},;
               {"005","GSL_BSS"},;
               {"006","GSL_BSS"},;
               {"007","GSL_BSS"},;
               {"008","GSL_BSS"},;
               {"009","GSL_BSS"},;
               {"010","GSL_BSS"},;
               {"011","GSL_SMS"},;
               {"012","GSL_SMS"},;
               {"013","GSL_SMS"},;
               {"014","GSL_SMS"},;
               {"015","GSL_SMS"},;
               {"016","GSL_SMS"},;
               {"017","GSL_SMS"},;
               {"020","GSL_TPP"},;
               {"021","GSL_BSS"},;
               {"022","GSL_BSS"},;
               {"023","GSL_BSS"},;
               {"024","GSL_BSS"},;
               {"026","GSL_TPP"},;
               {"028","GSL_OALW"},;
               {"030","GSL_TPP"},;
               {"031","GSL_TPP"},;
               {"032","GSL_BSS"},;
               {"041","GSL_HSC"},;
               {"042","GSL_HSC"},;
               {"044","GSL_HSC"},;
               {"045","GSL_HSC"},;
               {"046","GSL_HSC"},;
               {"047","GSL_HSC"},;
               {"048","GSL_HSC"},;
               {"049","GSL_HSC"},;
               {"051","GSL_NTHC"},;
               {"052","GSL_NTHC"},;
               {"054","GSL_NTHC"},;
               {"055","GSL_NTHC"},;
               {"056","GSL_SMS"},;
               {"057","GSL_SMS"},;
               {"058","GSL_HSC"},;
               {"059","GSL_TPP"},;
               {"060","GSL_LEAV"},;
               {"061","GSL_LEAV"},;
               {"062","GSL_NTHC"},;
               {"063","GSL_NTHC"},;
               {"064","GSL_NTHC"},;
               {"065","GSL_NTHC"},;
               {"066","GSL_NTHC"},;
               {"067","GSL_NTHC"},;
               {"068","GSL_SMS"},;
               {"069","GSL_SMS"},;
               {"070","GSL_LEAV"},;
               {"071","ERC_CUN"},;
               {"072","ERC_CUN"},;
               {"073","ERC_CUN"},;
               {"074","ERC_CUN"},;
               {"080","GSL_OVS"},;
               {"081","GSL_OVS"},;
               {"082","GSL_OVS"},;
               {"083","GSL_SMS"},;
               {"084","GSL_SMS"},;
               {"085","GSL_SMS"},;
               {"086","GSL_OVS"},;
               {"087","GSL_OVS"},;
               {"088","GSL_OVS"},;
               {"089","GSL_OVS"},;
               {"090","GSL_OVS"},;
               {"091","ERC_CUN"},;
               {"093","ERC_CUN"},;
               {"095","GSL_HSC"},;
               {"096","GSL_HSC"},;
               {"097","GSL_BSS"},;
               {"098","GSL_HSC"},;
               {"099","GSL_HSC"},;
               {"100","GSL_OVS"},;
               {"101","GSL_HSC"},;
               {"105","GSL_NTHC"},;
               {"110","GSL_BSS"},;
               {"111","GSL_BSS"},;
               {"112","NTP_SAA"},;
               {"113","GSL_SMS"},;
               {"114","GSL_SMS"},;
               {"115","GSL_SMS"},;
               {"122","ERC_CUN"},;
               {"123","ERC_CUN"},;
               {"129","GSL_HSC"},;
               {"130","GSL_HSC"},;
               {"131","GSL_HSC"},;
               {"132","GSL_OVS"},;
               {"133","GSL_MALW"},;
               {"149","NTP_SAA"},;
               {"150","NTP_SAA"},;
               {"151","GSL_HSC"},;
               {"152","GSL_MALW"},;
               {"153","GSL_OALW"},;
               {"154","GSL_OTC"},;
               {"157","GSL_HSC"},;
               {"158","GSL_HSC"},;
               {"159","GSL_HSC"},;
               {"160","GSL_OTC"},;
               {"161","GSL_OTC"},;
               {"162","GSL_OTC"},;
               {"163","GSL_OTC"},;
               {"164","NTP_SAA"},;
               {"165","NTP_SAA"},;
               {"166","NTP_SAA"},;
               {"170","GSL_OTC"},;
               {"171","GSL_OALW"},;
               {"172","GSL_OTC"},;
               {"173","GSL_OALW"},;
               {"174","GSL_OALW"},;
               {"176","GSL_OTC"},;
               {"177","GSL_OTC"},;
               {"178","GSL_HSC"},;
               {"179","GSL_OTC"},;
               {"180","GSL_COM"},;
               {"181","GSL_OTC"},;
               {"183","GSL_OVS"},;
               {"184","GSL_HSC"},;
               {"185","GSL_HSC"},;
               {"186","GSL_HSC"},;
               {"187","GSL_OVS"},;
               {"188","GSL_OVS"},;
               {"189","GSL_BNS"},;
               {"190","GSL_OTC"},;
               {"191","GSL_COM"},;
               {"192","GSL_OTC"},;
               {"193","GSL_OVS"},;
               {"194","GSL_OALW"},;
               {"195","GSL_OTC"},;
               {"196","GSL_OTC"},;
               {"197","GSL_BSS"},;
               {"198","GSL_OTC"},;
               {"199","NTP_SAA"},;
               {"200","GSL_OBIK"},;
               {"201","GSL_OBIK"},;
               {"202","GSL_LEAV"},;
               {"203","GSL_MALW"},;
               {"204","GSL_BNS"},;
               {"208","GSL_NTHC"},;
               {"209","GSL_NTHC"},;
               {"210","GSL_BSS"},;
               {"211","GSL_BNS"},;
               {"213","GSL_NTHC"},;
               {"214","GSL_BSS"},;
               {"215","GSL_HSC"},;
               {"216","GSL_BNS"},;
               {"220","GSL_BSS"},;
               {"221","GSL_BSS"},;
               {"223","GSL_HSC"},;
               {"224","GSL_HSC"},;
               {"225","GSL_OBIK"},;
               {"227","GSL_OALW"},;
               {"229","GSL_OBIK"},;
               {"230","GSL_BNS"},;
               {"231","GSL_OVS"},;
               {"233","GSL_OTC"},;
               {"234","GSL_OALW"},;
               {"235","GSL_OTC"},;
               {"238","GSL_BNS"},;
               {"242","GSL_TPP"},;
               {"243","GSL_COM"},;
               {"244","GSL_OALW"},;
               {"245","GSL_COM"},;
               {"250","GSL_OVS"},;
               {"251","GSL_OVS"},;
               {"252","GSL_BNS"},;
               {"253","GSL_COM"},;
               {"254","GSL_OTC"},;
               {"255","GSL_OVS"},;
               {"256","GSL_OTC"},;
               {"257","GSL_OTC"},;
               {"258","GSL_SMS"},;
               {"259","GSL_SMS"},;
               {"261","GSL_OALW"},;
               {"262","GSL_OALW"},;
               {"263","GSL_SMS"},;
               {"264","NTP_SAA"},;
               {"265","GSL_BNS"},;
               {"266","GSL_OALW"},;
               {"267","GSL_SMS"},;
               {"268","GSL_BNS"},;
               {"269","GSL_OVS"},;
               {"270","GSL_BSS"},;
               {"271","GSL_COM"},;
               {"272","GSL_OTC"},;
               {"273","GSL_HSC"},;
               {"275","GSL_COM"},;
               {"276","GSL_OTC"},;
               {"277","GSL_OTC"},;
               {"279","GSL_OVS"},;
               {"283","GSL_OBIK"},;
               {"286","GSL_OTC"},;
               {"288","GSL_OTC"},;
               {"290","GSL_SMS"},;
               {"291","GSL_COM"},;
               {"292","GSL_OVS"},;
               {"293","GSL_OVS"},;
               {"294","GSL_MALW"},;
               {"295","GSL_OTC"},;
               {"299","GSL_OVS"},;
               {"300","GSL_OVS"},;
               {"301","GSL_COM"},;
               {"303","GSL_LEAV"},;
               {"305","GSL_COM"},;
               {"308","GSL_OTC"},;
               {"310","GSL_OBIK"},;
               {"311","GSL_OVS"},;
               {"312","GSL_OVS"},;
               {"313","GSL_OVS"},;
               {"314","GSL_OVS"},;
               {"315","GSL_LEAV"},;
               {"316","GSL_BNS"},;
               {"318","NTP_SAA"},;
               {"319","GSL_OVS"},;
               {"321","GSL_OTC"},;
               {"323","GSL_OBIK"},;
               {"325","GSL_BNS"},;
               {"326","GSL_BNS"},;
               {"327","GSL_OVS"},;
               {"329","GSL_OTC"},;
               {"330","GSL_BSS"},;
               {"331","GSL_OVS"},;
               {"332","GSL_OTC"},;
               {"334","GSL_SBC"},;
               {"335","GSL_COM"},;
               {"338","GSL_OTC"},;
               {"339","GSL_BNS"},;
               {"340","GSL_BSS"},;
               {"341","GSL_OVS"},;
               {"345","GSL_BNS"},;
               {"346","GSL_COM"},;
               {"347","GSL_LEAV"},;
               {"349","GSL_SBC"},;
               {"350","NTP_SAA"},;
               {"351","NTP_SAA"},;
               {"353","GSL_OVS"},;
               {"358","GSL_OTC"},;
               {"361","GSL_OVS"},;
               {"364","GSL_SMS"},;
               {"365","GSL_LEAV"},;
               {"367","GSL_SMS"},;
               {"368","GSL_OTC"},;
               {"369","GSL_SMS"},;
               {"370","GSL_OBIK"},;
               {"371","GSL_OTC"},;
               {"372","GSL_OTC"},;
               {"374","GSL_COM"},;
               {"375","GSL_OTC"},;
               {"376","GSL_OTC"},;
               {"377","GSL_OTC"},;
               {"378","GSL_OTC"},;
               {"379","GSL_OTC"},;
               {"380","GSL_OTC"},;
               {"381","NTP_SAA"},;
               {"382","GSL_NTHC"},;
               {"383","GSL_LEAV"},;
               {"385","NTP_SAA"},;
               {"386","GSL_OBIK"},;
               {"387","GSL_OTC"},;
               {"388","NTP_SAA"},;
               {"389","GSL_LEAV"},;
               {"390","GSL_OTC"},;
               {"391","GSL_OTC"},;
               {"392","GSL_OTC"},;
               {"393","GSL_SBC"},;
               {"394","GSL_OTC"},;
               {"395","GSL_COM"},;
               {"396","GSL_OTC"},;
               {"397","GSL_OTC"},;
               {"398","GSL_OTC"},;
               {"399","GSL_OTC"},;
               {"400","GSL_COM"},;
               {"403","GSL_HSC"},;
               {"404","NTP_SAA"},;
               {"405","GSL_NTHC"},;
               {"408","GSL_CALW"},;
               {"409","GSL_COM"},;
               {"410","GSL_COM"},;
               {"411","GSL_HSC"},;
               {"412","GSL_HSC"},;
               {"413","GSL_SMS"},;
               {"414","NTP_SAA"},;
               {"417","GSL_SMS"},;
               {"419","GSL_SMS"},;
               {"421","GSL_SMS"},;
               {"422","GSL_SMS"},;
               {"426","GSL_OVS"},;
               {"428","NTP_SAA"},;
               {"429","GSL_OTC"},;
               {"431","GSL_NTHC"},;
               {"435","GSL_OTC"},;
               {"436","GSL_OALW"},;
               {"438","GSL_HALW"},;
               {"439","GSL_HALW"},;
               {"449","GSL_OVS"},;
               {"453","GSL_OALW"},;
               {"454","GSL_OALW"},;
               {"459","GSL_OALW"},;
               {"460","GSL_OVS"},;
               {"461","GSL_HSC"},;
               {"468","GSL_OVS"},;
               {"471","GSL_OTC"},;
               {"472","GSL_OTC"},;
               {"475","GSL_OTC"},;
               {"476","GSL_OALW"},;
               {"478","GSL_NTHC"},;
               {"479","GSL_HSC"},;
               {"481","NTP_SAA"},;
               {"483","GSL_LEAV"},;
               {"484","GSL_LEAV"},;
               {"485","GSL_OTC"},;
               {"486","GSL_BNS"},;
               {"487","GSL_BNS"},;
               {"490","GSL_LEAV"},;
               {"493","GSL_LEAV"},;
               {"494","GSL_BSS"},;
               {"495","GSL_LEAV"},;
               {"496","GSL_OBIK"},;
               {"497","GSL_BNS"},;
               {"498","GSL_OALW"},;
               {"499","GSL_OTC"},;
               {"500","EED_CSS"},;
               {"501","EED_CSS"},;
               {"502","EED_CSS"},;
               {"505","EED_CSS"},;
               {"513","EED_WTX"},;
               {"520","EED_WTX"},;
               {"521","EED_WTX"},;
               {"522","EED_VOTH"},;
               {"523","EED_WTX"},;
               {"524","EED_WTX"},;
               {"525","EED_WTX"},;
               {"526","EED_WTX"},;
               {"528","EED_WTX"},;
               {"529","EED_WTX"},;
               {"530","EED_COTH"},;
               {"531","EED_COTH"},;
               {"532","EED_COTH"},;
               {"533","EED_COTH"},;
               {"534","EED_COTH"},;
               {"535","EED_COTH"},;
               {"536","EED_COTH"},;
               {"537","NTP_SAA"},;
               {"538","EED_WTX"},;
               {"539","EED_COTH"},;
               {"540","NTP_SAA"},;
               {"541","NTP_SAA"},;
               {"542","NTP_SAA"},;
               {"544","NTP_SAA"},;
               {"546","NTP_SAA"},;
               {"548","NTP_SAA"},;
               {"604","EED_VOTH"},;
               {"606","NTP_SAA"},;
               {"610","EED_VOTH"},;
               {"647","NTP_SAA"},;
               {"650","NTP_SAA"},;
               {"651","GSL_LSD"},;
               {"652","GSL_LSD"},;
               {"653","EED_VOTH"},;
               {"654","GSL_LSD"},;
               {"656","NTP_SAA"},;
               {"658","EED_COTH"},;
               {"659","NTP_SAA"},;
               {"660","NTP_SAA"},;
               {"662","NTP_SAA"},;
               {"663","NTP_SAA"},;
               {"664","NTP_SAA"},;
               {"665","NTP_SPPD"},;
               {"666","NTP_SAA"},;
               {"668","EED_CMC"},;
               {"669","EED_CMC"},;
               {"670","EED_CMC"},;
               {"672","EED_VOTH"},;
               {"674","NTP_SAA"},;
               {"675","NTP_BIK"},;
               {"676","EED_VOTH"},;
               {"677","NTP_SAA"},;
               {"678","NTP_SAA"},;
               {"679","NTP_SAA"},;
               {"680","NTP_SAA"},;
               {"681","NTP_SAA"},;
               {"682","GSL_LSD"},;
               {"683","NTP_SAA"},;
               {"684","GSL_LSD"},;
               {"685","NTP_SAA"},;
               {"687","GSL_LSD"},;
               {"690","NTP_SAA"},;
               {"692","EED_COTH"},;
               {"693","EED_COTH"},;
               {"694","NTP_SPPD"},;
               {"696","EED_VOTH"},;
               {"697","NTP_SAA"},;
               {"698","NTP_SAA"},;
               {"700","GSL_LSD"},;
               {"701","EED_CMC"},;
               {"702","NTP_BIK"},;
               {"703","NTP_SAA"},;
               {"704","NTP_BIK"},;
               {"705","EED_CSS"},;
               {"706","NTP_BIK"},;
               {"707","NTP_BIK"},;
               {"708","NTP_SAA"},;
               {"709","NTP_SAA"},;
               {"711","EED_WTX"},;
               {"712","EED_CSS"},;
               {"713","EED_CSS"},;
               {"714","EED_WTX"},;
               {"715","EED_WTX"},;
               {"719","NTP_BIK"},;
               {"720","EED_WTX"},;
               {"721","NTP_SAA"},;
               {"722","NTP_BIK"},;
               {"723","EED_CMC"},;
               {"728","NTP_SAA"},;
               {"729","NTP_SAA"},;
               {"730","NTP_SAA"},;
               {"731","NTP_SAA"},;
               {"732","NTP_SAA"},;
               {"733","NTP_SAA"},;
               {"735","NTP_SAA"},;
               {"736","NTP_SAA"},;
               {"745","NTP_SAA"},;
               {"750","EED_CRT"},;
               {"751","NTP_SAA"},;
               {"752","EED_COTH"},;
               {"753","NTP_SAA"},;
               {"755","NTP_SPPD"},;
               {"757","NTP_SPPD"},;
               {"758","NTP_SAA"},;
               {"759","EED_COTH"},;
               {"764","NTP_SAA"},;
               {"765","NTP_SAA"},;
               {"777","NTP_SAA"},;
               {"778","NTP_SAA"},;
               {"779","NTP_SAA"},;
               {"780","EED_WTX"},;
               {"781","EED_VOTH"},;
               {"783","NTP_BIK"},;
               {"784","NTP_BIK"},;
               {"785","NTP_BIK"},;
               {"789","GSL_LSD"},;
               {"790","NTP_SAA"},;
               {"791","NTP_SAA"},;
               {"793","NTP_SAA"},;
               {"795","NTP_SAA"},;
               {"796","EED_CRT"},;
               {"797","NTP_SAA"},;
               {"799","GSL_LSD"},;
               {"805","EED_CMC"},;
               {"806","NTP_SAA"},;
               {"807","EED_COTH"},;
               {"820","EED_CRT"},;
               {"821","NTP_SAA"},;
               {"841","GSL_LSD"},;
               {"850","NTP_SPPD"},;
               {"851","NTP_SPPD"},;
               {"855","NTP_SAA"},;
               {"856","NTP_SAA"},;
               {"857","NTP_SAA"},;
               {"859","NTP_SAA"},;
               {"868","EED_CMC"},;
               {"877","EED_COTH"},;
               {"878","NTP_SAA"},;
               {"882","EED_COTH"},;
               {"884","NTP_SAA"},;
               {"888","EED_WTX"},;
               {"905","EED_VOTH"},;
               {"922","ERC_CUN"},;
               {"925","ERC_CUN"},;
               {"927","ERC_CUN"},;
               {"980","ERC_CSS"},;
               {"981","ERC_CSS"},;
               {"982","ERC_CSS"},;
               {"983","ERC_CSS"},;
               {"984","ERC_CSS"},;
               {"985","ERC_CSS"},;
               {"998","NTP_SAA"},;
               {"C01","ACR_SMS"},;
               {"C02","ACR_SMS"},;
               {"C03","ACR_SMC"},;
               {"C04","ACR_SMC"},;
               {"C11","ACR_HLS"},;
               {"C12","ACR_BNS"},;
               {"C13","ACR_BNS"},;
               {"C14","ACR_HLC"},;
               {"C15","ACR_HLC"}}

If FieldPos("RV_XGRP") > 0
	For nI:=1 To Len(aSRV)
	
		IncProc("Atualizando Tabela SZZ...")

		SRV->(DbSetOrder(1))
		If SRV->(DbSeek(xFilial("SRV")+aSRV[nI][1]))
			SRV->(RecLock("SRV",.F.))
			SRV->RV_XGRP := AllTrim(aSRV[nI][2])
			SRV->(MsUnlock())
		EndIf
	Next
EndIf                 

           
TcSQLExec("Update SRV"+SM0->M0_CODIGO+"0 set RV_P_ADP = '1' where RV_COD >= '000' AND RV_COD <= '499'")
TcSQLExec("Update SRV"+SM0->M0_CODIGO+"0 set RV_P_ADP = '2' where RV_COD >= '500' AND RV_COD <= '905'")
TcSQLExec("Update SRV"+SM0->M0_CODIGO+"0 set RV_P_ADP = '4' where RV_COD >= '906'")
TcSQLExec("Update SRV"+SM0->M0_CODIGO+"0 set RV_P_ADP = '3' where RV_COD = '999'")
TcSQLExec("update SRV"+SM0->M0_CODIGO+"0 set RV_P_ADP = '' where RV_COD in ('900','920','950','960','970')")

cTexto += "- SRV Atualizado com sucesso."+ CHR(10) + CHR(13)

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