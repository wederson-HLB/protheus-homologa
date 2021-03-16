#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*
Funcao      : USX3003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Criar o campo W1_P_ADI e W1_P_SEQADI 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 13/12/11
Revisão     : Jean Victor Rocha.
Objetivos   : inclusão de atualização do indice.
Data/Hora   : 16/03/12
*/

User Function USX3003()

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
  	     If !lCheck .and.;
  	     	Ascan(aAux,{ |x| LEFT(x,2) == M0_CODIGO}) <> 0 .and.;
  	     	Ascan(aAux,{ |x| RIGHT(x,2) == M0_CODFIL}) <> 0 .and.;
  	     	Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
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

   //Criação do campo W1_P_ADI na tabela SW1
   aAdd(aSX3,{"SW1",;	            				//Arquivo
              "10",;								//Ordem
			  "W1_P_ADI",;					    	//Campo
			  "C",;			        				//Tipo
		       03,;	                				//Tamanho
			   0,;				  					//Decimal
			  "Adicao",;          				    //Titulo
			  "Adicao",;  		     		        //Titulo SPA
			  "Adicao",;	    	    			//Titulo ENG
			  "Adicao         ",;                   //Descrição
			  "Adicao         ",;                   //Descrição SPA
			  "Adicao         ",;		            //Descrição ENG
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
                    
 

   //Criação do campo W1_P_SEQADI na tabela SW1
   aAdd(aSX3,{"SW1",;	            				//Arquivo
              "10",;								//Ordem
			  "W1_P_SEQAD",;					    //Campo
			  "C",;			        				//Tipo
		       03,;	                				//Tamanho
			   0,;				  					//Decimal
			  "Seq Adicao",;          		        //Titulo
			  "Seq Adicao",;  		     	        //Titulo SPA
			  "Seq Adicao",;	    	        	//Titulo ENG
			  "Sequencia Adicao",;                   //Descrição
			  "Sequencia Adicao",;                   //Descrição SPA
			  "Sequencia Adicao",;		            //Descrição ENG
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

   cTexto += '- Campos W1_P_ADI e W1_P_SEQADI criados com sucesso. '+ NL


End Sequence

Return cTexto

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
RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)


cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

While SM0->(!EOF())
	(cAliasWork)->(RecLock(cAliasWork,.T.))           
	(cAliasWork)->MARCA		:= ""
	(cAliasWork)->M0_CODIGO	:= SM0->M0_CODIGO
	(cAliasWork)->M0_CODFIL	:= SM0->M0_CODFIL
	(cAliasWork)->M0_NOME	:= SM0->M0_NOME
	(cAliasWork)->(MsUnlock())
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