#INCLUDE "Protheus.ch"
/*
Funcao      : USX6016
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ajuste de parâmetros para DCTF
Autor       : Renato Rezende
Data/Hora   : 13/08/2013
Revisao     :
Obs.        :
*/  
*--------------------------------*
User Function USX6016()
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 

Begin Sequence
   Set Dele On

   lHistorico := MsgYesNo("Deseja efetuar a atualização do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faça um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")
   lEmpenho	  := .F.
   lAtuMnu	  := .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},"Processando","Aguarde, processando preparação dos arquivos...",.F.) , Final("Atualização efetuada!")),oMainWnd:End())

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


Local aChamados := { {05, {|| AtuSX6()}} } //05 - SIGAFAT

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
	  		    contidas no array aChamados para cada módulo. */

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
Revisao     :
Obs.        :
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
      Aviso( "Atencao !", "Não foi possível a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen )              



*------------------------------*
Static Function AtuSX6(oProcess)
*------------------------------*
Local cTexto := "" 
Local i
Local aMvSX6:= {}

IncProc("Atualizando Parametros!")

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     	  X6_DSCSPA											  X6_DSCENG                               		   X6_DESC1   									X6_DSCSPA1   								  X6_DSCENG1   									  X6_DESC2   		X6_DSCSPA2   	   X6_DSCENG2      X6_CONTEUD   																																																					X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_DCTF000", "C"		,"Referencia de codigos de retencäo do sistema para", "Referencia de cod. de retencion del sistema para", "Reference of the system withholding codes for", "os adotados pela DCTF com a periodicidade", "los adoptados por DCTF con la periodicidad", "those adopted by DCTF with the corresponding", "correspondente", "correspondiente", "periodicity.", "0561=056107M;0588=058806M;0676=067602M;0691=069101M;0776=077601M;1150=115002M;1708=170806M;2089=208901T;2172=217201M;2362=236201M;2372=237201T;2484=248401M;2985=298501M;3208=320806M;3280=328006M;3373=337301T;8741=874101M;", "S"		 , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     	  X6_DSCSPA											  X6_DSCENG                               		   X6_DESC1   									X6_DSCSPA1   								  X6_DSCENG1   									  X6_DESC2   		X6_DSCSPA2   	   X6_DSCENG2      X6_CONTEUD   																																																					X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_DCTF001", "C"		,"Referencia de codigos de retencäo do sistema para", "Referencia de cod. de retencion del sistema para", "Reference of the system withholding codes for", "os adotados pela DCTF com a periodicidade", "los adoptados por DCTF con la periodicidad", "those adopted by DCTF with the corresponding", "correspondente", "correspondiente", "periodicity.", "4574=457401M;5123=512301M;5434=543401M;5442=544201M;5856=585601M;5952=595202Q;5960=596004Q;5979=597904Q;5987=598704Q;6012=601201T;6912=691201M;7987=798701M;8045=804506M;8109=810902M;8496=849601M;8645=864501M;9385=938502X;", "S"		 , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     	  X6_DSCSPA											  X6_DSCENG                               			 X6_DESC1   		  X6_DSCSPA1   			 X6_DSCENG1   	   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_M978CSR", "C"		,"Determina o codigo de receita que devera compor o", "Determina el codigo de ingreso que debe componer", "Determines the revenue code to compose the CSRF", "grupo CSRF"       , "grupo CSRF"         , "group"         , ""       , ""         , ""			, "4211"   , "S"		, "S"	  })

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_CIDE", 	"C"		,"Naturezas para impostos manuais CIDE - DCTF" , "Naturalezas para impuestos manuales CIDE - DCTF", "Classes for manual taxes CIDE - DCTF", ""       , ""         , ""         , ""       , ""         , ""			, "4210"	 , "S"		  , "S"		}) 

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_COFINS2", "C"		,"Naturezas para COFINS - DCFT"				   , "Naturalezas para COFINS - DCFT"				  , "Classes for COFINS _DCTF"			  , ""       , ""         , ""         , ""       , ""         , ""			, "3103/4212", "S"		  , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_CSLL2", 	"C"		,"Naturezas para titulos de CSLL"			   , "Naturalezas para titulos de CSLL"				  , "Classes for CSLL bills"			  , ""       , ""         , ""         , ""       , ""         , ""			, "6702/4213", "S"		  , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_IOF", 	"C"		,"Naturezas para impostos manuais IOF - DCTF"  , "Naturalezas para impuestos manuales IOF - DCTF" , "Classes for manual taxes IOF - DCTF" , ""       , ""         , ""         , ""       , ""         , ""			, "3004"	 , "S"		  , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_IPI2", 	"C"		,"Naturezas para impostos manuais IPI - DCTF"  , "Naturalezas para impuestos manuales IPI - DCTF" , "Class for manual taxes IPI - DCTF"	  , ""       , ""         , ""         , ""       , ""         , ""			, "3105"	 , "S"		  , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_IRF2", 	"C"		,"Naturezas para Imposto de Renda"			   , "Naturalezas para Impuesto de Renta"			  , "Classes for Income Tax"			  , ""       , ""         , ""         , ""       , ""         , ""			, "4202/2105", "S"		  , "S"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_IRPJ", 	"C"		, "Naturezas para impostos manuais IRPJ - DCTF", "Naturalezas para impuestos manuales IRPJ - DCTF", "Classes for manual taxes IRPJ - DCTF", ""       , ""         , ""         , ""       , ""         , ""			, "6701"	 , "S"		  , "N"		})

//			  X6_VAR   	 	X6_TIPO   X6_DESCRIC                                     X6_DSCSPA											X6_DSCENG                               X6_DESC1   X6_DSCSPA1   X6_DSCENG1   X6_DESC2   X6_DSCSPA2   X6_DSCENG2   X6_CONTEUD   X6_PROPRI   X6_PYME
aAdd(aMvSX6, {"MV_PISNAT2",	"C"		, "Naturezas para titulos referentes ao PIS"   , "Naturalezas para titulos referentes al PIS"	  , "Classes for bills referring to PIS"  , ""       , ""         , ""         , ""       , ""         , ""			, "3102/4211", "S"		  , "S"		})

SX6->(DbSetOrder(1))
For i:=1 to Len(aMvSX6)
	//Validando se o parâmetro existe
	If SX6->(DbSeek(xFilial("SX6") + aMvSX6[i][1]))
		If SX6->(RecLock("SX6", .F.))                       
				SX6->X6_CONTEUD := aMvSX6[i][12]
				SX6->X6_CONTSPA := aMvSX6[i][12]
				SX6->X6_CONTENG := aMvSX6[i][12]
				SX6->(MSUNLOCK())
				cTexto += "Foi atualizado o paramentro " + aMvSX6[i][1] + " " +CHR(13)+CHR(10)
		EndIf
	//Caso o parâmetro não exista, criar
	Else
		If SX6->(RecLock("SX6", .T.))
			SX6->X6_VAR      := aMvSX6[i][1]
			SX6->X6_TIPO     := aMvSX6[i][2]
			SX6->X6_DESCRIC  := aMvSX6[i][3]
			SX6->X6_DSCSPA   := aMvSX6[i][4]
			SX6->X6_DSCENG   := aMvSX6[i][5]
			SX6->X6_DESC1    := aMvSX6[i][6]
			SX6->X6_DSCSPA1  := aMvSX6[i][7]
			SX6->X6_DSCENG1  := aMvSX6[i][8]
			SX6->X6_DESC2    := aMvSX6[i][9]
			SX6->X6_DSCSPA2  := aMvSX6[i][10]
			SX6->X6_DSCENG2  := aMvSX6[i][11]
			SX6->X6_CONTEUD  := aMvSX6[i][12]
			SX6->X6_CONTSPA  := aMvSX6[i][12]
			SX6->X6_CONTENG  := aMvSX6[i][12]
			SX6->X6_PROPRI   := aMvSX6[i][13]
			SX6->X6_PYME     := aMvSX6[i][14]
			SX6->(MSUNLOCK())
			cTexto += "Foi criado o paramentro " + aMvSX6[i][1] + " " +CHR(13)+CHR(10)
		EndIf
	EndIf
			
Next i

Return cTexto