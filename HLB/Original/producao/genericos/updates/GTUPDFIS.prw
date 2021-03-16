#INCLUDE "Protheus.ch"   

/*
Funcao      : GTUPDFIS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Zap e Drop na tabela CC4
Autor       : Renato Rezende
Data/Hora   : 26/09/2013 
Revisão		: Inclusão das tabelas CCZ, CCY, CCW para dropar.
Autor		: Matheus Massarotto
Data/Hora	: 26/09/2013
*/

*-------------------------*
 User Function GTUPDFIS()
*-------------------------*
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
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função de processamento da gravação dos arquivos.
*/
*---------------------------*
Static Function UPDProc(lEnd)  
*---------------------------*
Local cTexto := '' , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0
    
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
	  		 
  		    nModulo := 17  // EIC
  		    ProcRegua(1)
            IncProc("Analisando Dicionario de Dados...")
    	    cTexto += ZapDrop()

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

*-----------------------*
Static Function ZapDrop()
*-----------------------*
Local cTexto := ""

Local nI      := 1
Local cQuery  := ""
Local cTabela := ""
Local aTabela := {}
Local cTabela1:= ""

//Zap na CC4 antes de dropar, pois gera error log ao tentar dropar com os dados. 
cTabela1 := RetSqlName("CC4")

cAlias := "TMP"

USE (cTabela1) ALIAS (cAlias) EXCLUSIVE NEW VIA "TOPCONN"

If NetErr()   
	cTexto +="Nao foi possivel abrir "+cTabela1+" em modo EXCLUSIVO."     
Else   
	ZAP   
	
	USE   
	
	cTexto +="Registros da tabela "+cTabela1+" eliminados com sucesso."
	
Endif

AADD(aTabela,"CC4")
AADD(aTabela,"CCZ")
AADD(aTabela,"CCY")
AADD(aTabela,"CCW")

For nI := 1 to Len(aTabela)
	cTabela := RetSqlName( aTabela[nI] )
	
	If TCCanOpen(cTabela)
		//dbSelectArea(aTabela[nI])
		//dbCloseArea(aTabela[nI])
		cQuery := "DROP TABLE "+cTabela
		If 	!TCDelFile(cTabela) //TCSQLEXEC(cQuery) < 0
			Alert(TCSQLError())
		EndIf
	EndIf
Next

Return cTexto