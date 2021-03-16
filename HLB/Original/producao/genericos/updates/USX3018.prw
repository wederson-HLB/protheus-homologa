#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"

/*
Funcao      : USX3016
Objetivos   : Acerto da Folder do SF4
Autor       : Jean Victor Rocha
Data/Hora   : 19/06/2012
*/
*----------------------*
User Function USX3018(o)
*----------------------*
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
		IF M0_CODIGO $ "YY|99"//Apenas empresas modelos.
	  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			 EndIf
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
Local aCampos := {}
Local cTexto := ""
Local i

aAdd(aArqUpd,"SA2")

aCampos := CAMPOSUPD()

SX3->(DbSetOrder(2))
For i:=1 to len(acampos)
	If SX3->(DBSeek(aCampos[i][1]))
		SX3->(RecLock("SX3", .F.))
		If acampos[i][2] == "0"
			SX3->X3_FOLDER := ""
		Else
			SX3->X3_FOLDER := aCampos[i][2]
		EndIf
		SX3->(Msunlock())
		cTexto += "- Campo '"+aCampos[i][1]+"' atualizado para Folder "+aCampos[i][2]+"."+CHR(10)+CHR(13)
	Else
		cTexto += "- Campo '"+aCampos[i][1]+"' não encontrado."+CHR(10)+CHR(13)
	EndIf
next i

Return cTexto         


*-----------------------*
 Static Function CAMPOSUPD()
*-----------------------*
Local aCampos := {}

aCampos := {{"F4_ATUATF", "1"},;
{"F4_ATUTEC", "1"},;
{"F4_BENSATF", "1"},;
{"F4_CODIGO", "1"},;
{"F4_CODOBSE", "1"},;
{"F4_CONSIND", "1"},;
{"F4_DUPLIC", "1"},;
{"F4_FINALID", "1"},;
{"F4_MOVPRJ", "1"},;
{"F4_MSBLQL", "1"},;
{"F4_TESDV", "1"},;
{"F4_TESE3", "1"},;
{"F4_TESENV", "1"},;
{"F4_TESP3", "1"},;
{"F4_TIPO", "1"},;
{"F4_TIPOPER", "1"},;
{"F4_TPMOV", "1"},;
{"F4_TRANFIL", "1"},;
{"F4_UPRC", "1"},;
{"F4_AFRMM", "2"},;
{"F4_AGREGCP", "2"},;
{"F4_ALSENAR", "2"},;
{"F4_APSCFST", "2"},;
{"F4_BSRURAL", "2"},;
{"F4_CALCFET", "2"},;
{"F4_CF", "2"},;
{"F4_CFABOV", "2"},;
{"F4_CFACS", "2"},;
{"F4_CLFDSUL", "2"},;
{"F4_CONSUMO", "2"},;
{"F4_CONTSOC", "2"},;
{"F4_COP", "2"},;
{"F4_CPPRODE", "2"},;
{"F4_CPRECTR", "2"},;
{"F4_CRDEST", "2"},;
{"F4_CRDTRAN", "2"},;
{"F4_CRPRSIM", "2"},;
{"F4_FORMULA", "2"},;
{"F4_FRETAUT", "2"},;
{"F4_LIVRO", "2"},;
{"F4_NORESP", "2"},;
{"F4_PERCMED", "2"},;
{"F4_PR35701", "2"},;
{"F4_SELO", "2"},;
{"F4_TEXTO", "2"},;
{"F4_TPPRODE", "2"},;
{"F4_AGRDRED", "4"},;
{"F4_AJUSTE", "4"},;
{"F4_ANTICMS", "4"},;
{"F4_BASEICM", "4"},;
{"F4_BENDUB", "4"},;
{"F4_BSRDICM", "4"},;
{"F4_CIAP", "4"},;
{"F4_COMPL", "4"},;
{"F4_CPRESPR", "4"},;
{"F4_CRDPRES", "4"},;
{"F4_CREDACU", "4"},;
{"F4_CREDPRE", "4"},;
{"F4_CRICMS", "4"},;
{"F4_CRLEIT", "4"},;
{"F4_CROUTGO", "4"},;
{"F4_CROUTSP", "4"},;
{"F4_CRPRELE", "4"},;
{"F4_CRPREPE", "4"},;
{"F4_CRPRERO", "4"},;
{"F4_CRPRESP", "4"},;
{"F4_CSOSN", "4"},;
{"F4_DESCOND", "4"},;
{"F4_DESPICM", "4"},;
{"F4_DSPRDIC", "4"},;
{"F4_ESTCRED", "4"},;
{"F4_ICM", "4"},;
{"F4_ICMSDIF", "4"},;
{"F4_LFICM", "4"},;
{"F4_NUMDUB", "4"},;
{"F4_OBSICM", "4"},;
{"F4_PAUTICM", "4"},;
{"F4_PCREDAC", "4"},;
{"F4_PICMDIF", "4"},;
{"F4_REDANT", "4"},;
{"F4_REDBCCE", "4"},;
{"F4_SITTRIB", "4"},;
{"F4_TIPODUB", "4"},;
{"F4_TRFICM", "4"},;
{"F4_VARATAC", "4"},;
{"F4_VDASOFT", "4"},;
{"F4_BASEIPI", "5"},;
{"F4_CTIPI", "5"},;
{"F4_DESPIPI", "5"},;
{"F4_DESTACA", "5"},;
{"F4_INCIDE", "5"},;
{"F4_IPI", "5"},;
{"F4_IPIFRET", "5"},;
{"F4_IPILICM", "5"},;
{"F4_IPIOBS", "5"},;
{"F4_IPIPC", "5"},;
{"F4_LFIPI", "5"},;
{"F4_REGDSTA", "5"},;
{"F4_SOMAIPI", "5"},;
{"F4_TPIPI", "5"},;
{"F4_AGREG", "6"},;
{"F4_AGRRETC", "6"},;
{"F4_APLIIVA", "6"},;
{"F4_APLIRED", "6"},;
{"F4_APLREDP", "6"},;
{"F4_ART274", "6"},;
{"F4_ATACVAR", "6"},;
{"F4_BSICMST", "6"},;
{"F4_CREDST", "6"},;
{"F4_CRICMST", "6"},;
{"F4_CRPRST", "6"},;
{"F4_DBSTCSL", "6"},;
{"F4_DBSTIRR", "6"},;
{"F4_DUPLIST", "6"},;
{"F4_ICMSST", "6"},;
{"F4_ICMSTMT", "6"},;
{"F4_INCSOL", "6"},;
{"F4_INTBSIC", "6"},;
{"F4_IVAUTIL", "6"},;
{"F4_LFICMST", "6"},;
{"F4_MKPCMP", "6"},;
{"F4_MKPSOL", "6"},;
{"F4_OBSSOL", "6"},;
{"F4_RGESPST", "6"},;
{"F4_STCONF", "6"},;
{"F4_STDESC", "6"},;
{"F4_BASEISS", "7"},;
{"F4_CSTISS", "7"},;
{"F4_FRETISS", "7"},;
{"F4_ISS", "7"},;
{"F4_ISSST", "7"},;
{"F4_LFISS", "7"},;
{"F4_NRLIVRO", "7"},;
{"F4_REFATAN", "7"},;
{"F4_RETISS", "7"},;
{"F4_VLAGREG", "7"},;
{"F4_AGRCOF", "8"},;
{"F4_AGRPIS", "8"},;
{"F4_BASECOF", "8"},;
{"F4_BASEPIS", "8"},;
{"F4_BCPCST", "8"},;
{"F4_BCRDCOF", "8"},;
{"F4_BCRDPIS", "8"},;
{"F4_CNATREC", "8"},;
{"F4_CODBCC", "8"},;
{"F4_COFBRUT", "8"},;
{"F4_COFDSZF", "8"},;
{"F4_CSTCOF", "8"},;
{"F4_CSTPIS", "8"},;
{"F4_GRPNATR", "8"},;
{"F4_PISBRUT", "8"},;
{"F4_PISCOF", "8"},;
{"F4_PISCRED", "8"},;
{"F4_PISDSZF", "8"},;
{"F4_PSCFST", "8"},;
{"F4_TNATREC", "8"},;
{"F4_TPREG", "8"},;
{"F4_CREDICM", "9"},;
{"F4_CREDIPI", "9"},;
{"F4_DEVZERO", "9"},;
{"F4_ESTOQUE", "9"},;
{"F4_MOVFIS", "9"},;
{"F4_PISFISC", "9"},;
{"F4_PODER3", "9"},;
{"F4_QTDZERO", "9"},;
{"F4_RECDAC", "9"},;
{"F4_SLDNPT", "9"},;
{"F4_PRZESP", "0"}}

Return aCampos
