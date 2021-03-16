#INCLUDE "Protheus.ch"
/*
Funcao      : USX5003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ajuste no SX5 nas tabelas 30 e 37.
Autor       : Renato Rezende     	
Data/Hora   : 17/09/2013
Revisao     :
Obs.        :
*/  
*--------------------------------*
User Function USX5003()
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 

Begin Sequence
   Set Dele On

   lHistorico := MsgYesNo("Deseja efetuar a atualiza��o do Dicion�rio? Esta rotina deve ser utilizada em modo exclusivo ! Fa�a um backup dos dicion�rios e da Base de Dados antes da atualiza��o para eventuais falhas de atualiza��o !", "Aten��o")
   lEmpenho	  := .F.
   lAtuMnu	  := .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualiza��o do Dicion�rio"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},"Processando","Aguarde, processando prepara��o dos arquivos...",.F.) , Final("Atualiza��o efetuada!")),oMainWnd:End())

End Sequence
	   
Return     

/*
Funcao      : UPDProc
Objetivos   : Fun��o de processamento da grava��o dos arquivos.
*/
Static Function UPDProc(lEnd)

Local cTexto := "" , cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0


Local aChamados := { {05, {|| AtuSX5()}} } //05 - SIGAFAT

Private NL := CHR(13) + CHR(10)

Begin Sequence

	ProcRegua(1)
	IncProc("Verificando integridade dos dicion�rios...")

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
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas autom�ticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparar� as fun��es
	  		    contidas no array aChamados para cada m�dulo. */

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
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Compartilhada 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao !", "N�o foi poss�vel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen )              



*------------------------------*
Static Function AtuSX5(oProcess)
*------------------------------*
Local cTexto := "" 
Local i		 := 0
Local aSX5 :={}

//          "X5_FILIAL" ,"X5_TABELA" ,"X5_CHAVE" ,"X5_DESCRI"                                       		,"X5_DESCSPA"      							 		   		,"X5_DESCENG"
aAdd(aSX5,{xFilial("SX5")    ,"30"		 , "01"		 ,"AFASTAMENTO TEMPORARIO DOENCA INFERIOR 15 DIAS"  		,"LICENCIA TEMPORARIA POR ENFERMEDAD INFERIOR A 15 DIAS"	,"TEMPORARY LEAVE DUE TO ILLNESS - LESS THAN 15 DAYS"})
aAdd(aSX5,{xFilial("SX5")    ,"37"		 , "5979"	 ,"Pis - Retencao Pagamentos de PJ a PJ Direito Privado"  	,""															,""})
aAdd(aSX5,{xFilial("SX5")    ,"37"		 , "5987"	 ,"CSLL - Retencao Pagamentos de PJ a PJ Direito Privado" 	,""															,""})

DbSelectArea("SX5")
SX5->(DbSetOrder(1))
//Inclus�o do novo CODIGO DE AFASTAMENTO FGTS
If !DbSeek(aSX5[1,1]+aSX5[1,2]+aSX5[1,3])
	RecLock("SX5",.T.)
	SX5->X5_FILIAL	:= aSX5[1,1]
	SX5->X5_TABELA	:= aSX5[1,2]
	SX5->X5_CHAVE	:= aSX5[1,3]
	SX5->X5_DESCRI	:= aSX5[1,4]
	SX5->X5_DESCSPA := aSX5[1,5] 
	SX5->X5_DESCENG := aSX5[1,6]
	MsUnLock()
	cTexto += 'Foi possivel cadastrar o registro da tabela SX5 30 :'+aSX5[1,3]+ CHR(13) + CHR(10)
Else
	cTexto += 'N�o foi possivel cadastrar o registro da tabela SX5 30 '+aSX5[1,3]+ CHR(13) + CHR(10)	
EndIf

//Atualizar descri��o dos c�digos de reten��o 5979, 5987 
For i := 2 to 3
	If DbSeek(aSX5[i,1]+aSX5[i,2]+aSX5[i,3])
		RecLock("SX5",.F.)
		SX5->X5_FILIAL	:= aSX5[i,1]
		SX5->X5_TABELA	:= aSX5[i,2]
		SX5->X5_CHAVE	:= aSX5[i,3]
		SX5->X5_DESCRI	:= aSX5[i,4]
		MsUnLock()
		cTexto += 'Foi possivel atualizar o c�digo de reten��o no SX5 37 :'+aSX5[i,3]+ CHR(13) + CHR(10)
	Else
		cTexto += 'N�o foi possivel atualizar o c�digo de reten��o no SX5 37 :'+aSX5[i,3] + CHR(13) + CHR(10)	
	EndIf
Next i

Return cTexto