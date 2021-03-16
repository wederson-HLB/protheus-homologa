#INCLUDE "Protheus.ch"
/*
Funcao      : USX3032
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização do Cadastro de Clientes. SA1
Autor       : Jean Victor Rocha
Data/Hora   : 13/11/2013
Revisao     : 
Obs.        :
*/  

*--------------------------------*
User Function USX3032(lAmbiente)
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


Local aChamados := { {05, {|| AtuSXA()}},;
					 {05, {|| AtuSX3()}}}

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) // RRP - Abrir o Sigamat compartilhado.
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
Static Function AtuSX3(oProcess)
*------------------------------*
Local cTexto := ""

//Campos a serem deletados do Dicionario e base
Local aDel := {"A1_BAICORR","A1_CEPCORR","A1_ENDCORR","A1_ESTCORR","A1_FLAGCOR","A1_MUNCORR","A1_SALTEMP","A1_P_EECPC","A1_P_EEMPC","A1_P_EMAIP"}
   
//Campos que não serão mais usados, porem estarão na base.
Local aNUsado := {"A1_BAICOB","A1_P_EMACO","A1_P_RECCO","A1_P_DTCOB","A1_USERLGA","A1_USERLGI"}

//Campos de proposta, serão apresentados apenas no grupo de empresas outsourcing
Local aNUsadoAUD := {"A1_P_GER","A1_P_VEND","A1_P_SOCIO","A1_P_CONFL"}
                                                                                
//Ajuste de pastas
Local aNewFol := {	{"A1_P_GER"  ,2},{"A1_P_VEND" ,2},{"A1_P_SOCIO",2},{"A1_P_CONFL",2},;
					{"A1_P_COBND",2},{"A1_CC_CUST",2},{"A1_P_INTER",2},{"A1_P_EMAIC",2},;
					{"A1_P_CLVL" ,2},{"A1_P_STATU",1},{"A1_CONTAND",2},;
					{"A1_CEPCOB" ,2},{"A1_ENDCOB" ,2},{"A1_ESTCOB" ,2},{"A1_MUNCOB" ,2},{"A1_BAIRROC",2},;//Padrão
					{"A1_ENDNOT" ,1},{"A1_TIPPRFL",1},{"A1_PRF_VLD",1},{"A1_PRF_OBS",1},{"A1_FILTRF" ,1},;//Padrão
					{"A1_CODFID" ,1},{"A1_HRTRANS",1},{"A1_UNIDVEN",2},{"A1_ALIFIXA",3},{"A1_CODSIAF",3}}//Padrão

SX3->(DbSetOrder(2))//X3_CAMPO

For i:=1 to Len(aDel)
	If SX3->(DBSeek(aDel[i]))
		SX3->(RecLock("SX3", .F.))
		SX3->(DbDelete())
		SX3->(MsUnlock())
		cTexto += " - Campo '"+aDel[i]+"' apagado com sucesso!."+CHR(13)+CHR(10)
	EndIf
Next i

For i:=1 to Len(aNewFol)
	If SX3->(DBSeek(aNewFol[i][1]))
		SX3->(RecLock("SX3", .F.))
		SX3->X3_FOLDER := ALLTRIM(STR(aNewFol[i][2] ))
		SX3->(MsUnlock())
		cTexto += " - Campo '"+aNewFol[i][1]+"' Atualizado com sucesso!."+CHR(13)+CHR(10)
	EndIf
Next i          

For i:=1 to Len(aNUsado)
	If SX3->(DBSeek(aNUsado[i]))
		SX3->(RecLock("SX3", .F.))
		SX3->X3_USADO := "€€€€€€€€€€€€€€€"
		SX3->X3_BROWSE := "N" 
		SX3->(MsUnlock())
		cTexto += " - Campo '"+aNUsado[i]+"' Atualizado com sucesso!."+CHR(13)+CHR(10)
	EndIf
Next i

If cEmpAnt $ "ZB/ZF"
	For i:=1 to Len(aNUsadoAUD)
		If SX3->(DBSeek(aNUsadoAUD[i]))
			SX3->(RecLock("SX3", .F.))
			SX3->X3_USADO := "€€€€€€€€€€€€€€€"
			SX3->X3_BROWSE := "N" 
			SX3->(MsUnlock())
			cTexto += " - Campo '"+aNUsadoAUD[i]+"' Atualizado com sucesso!."+CHR(13)+CHR(10)
		EndIf
	Next i
EndIf        

//Atualiza a Tabela na Base
aAdd(aArqUpd,"SA1")

	
Return cTexto  

*------------------------------*
Static Function AtuSXA(oProcess)
*------------------------------*
Local cTexto := ""

SXA->(DbSetOrder(1))//XA_ALIAS+XA_ORDEM  

If SXA->(DBSeek("SA1"+"6"))
	If ALLTRIM(UPPER(SXA->XA_DESCRIC)) == ALLTRIM(UPPER("Impressao Invoice"))
		SXA->(RecLock("SXA", .F.))
		SXA->XA_DESCRIC := "Imp. Invoice"
		SXA->XA_DESCSPA := "Imp. Invoice"
		SXA->XA_DESCENG := "Imp. Invoice"
		SXA->(MsUnlock())
		cTexto := " - Folder 'Imp. Invoice' atualizado com sucesso!."+CHR(13)+CHR(10)
	EndIf
EndIf

Return cTexto