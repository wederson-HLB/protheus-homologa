#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : USIG001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização do Dicionario de indices. SIX.
Autor       : Jean Victor Rocha
Data/Hora   : 22/02/12
*/                            

User Function USIG001()

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


Local aChamados := { {04, {|| AtuSIG()}}}

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

*----------------------*
Static Function AtuSIG()
*----------------------*
Local aSIG 		:= {}
Local aFilial	:= {}
Local aSIGEstrut:= {}
Local cAlias	:= "SR5"
Local cTexto	:= ""
Local nPos 		:= 0
Local i, j, k

Begin Sequence       

aSIGEstrut := {"R5_FILIAL","R5_ARQUIVO","R5_CAMPO","R5_ORDEM","R5_POSICAO","R5_TIPO","R5_TAMANHO","R5_DECIMAL","R5_REG","R5_DEONDE","R5_DE","R5_QUANTOS","R5_TITULO","R5_DESCRIC","R5_PICTURE","R5_VALID","R5_USADO","R5_RELACAO","R5_F3","R5_NIVEL","R5_RESERV","R5_CHECK","R5_CHAVE"}

	aadd(aSIG,{ "","X14","14","00","","A",			3,0,"00","",	   		0,0,"","Encargos Empresa","","","","1","","0","","",""})
	aadd(aSIG,{ "","X14","X14_TIP","01","","C",		2,0,"00","",			0,0,"Tipo","Tipo do Registro","99","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_FILIAL","02","","C",	2,0,"00","RX_FILIAL",	1,2,"Filial","Filial","@!","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_EMPRE1","03","01","C",2,0,"01","RX_CODCHAVE",	1,2,"Filial","Filial","@!","","X","","","0","","","S"})
	aadd(aSIG,{ "","X14","X14_AA1","04","03","C",	4,0,"01","RX_CODCHAVE",	3,4,"Ano","Ano","9999","","X","","","0","","","S"})
	aadd(aSIG,{ "","X14","X14_MM1","05","02","C",	2,0,"01","RX_CODCHAVE",	7,2,"Mes","Mes","99","","X","","","0","","","S"})
	aadd(aSIG,{ "","X14","X14_TIPOC1","06","04","C",1,0,"01","RX_CODCHAVE",	9,1,"Tipo Contrat","Tipo de Contrato","@!","NaoVazio() .AND. Pertence('12')","X","","","0","","","S"})
	aadd(aSIG,{ "","X14","X14_COD1","07","","F",	1,0,"01","RX_COD",		10,1,"Fixo","Numero do Registro","9","","","1","","0","","",""})
	aadd(aSIG,{ "","X14","X14_PEREMP","08","05","N",8,4,"01","RX_TXT",		1,8,"% Empresa","% Empresa sem Limite","@E 999.9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_PERTER","09","06","N",8,4,"01","RX_TXT",		9,8,"% Terceiros","% Terceiros","@E 999.9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_PERACT","10","07","N",8,4,"01","RX_TXT",		17,8,"% Acid.Trab.","% Acidente de Trabalho","@E 999.9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_FGTS","11","08","N",	7,3,"01","RX_TXT",		25,7,"% FGTS","% FGTS","@E 999.999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_PRO13","12","09","N",	8,4,"01","RX_TXT",		32,8,"% Prov. 13§","% Provisao 13§","@E 999.9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_PROFER","13","10","N",8,4,"01","RX_TXT",	   	40,8,"% Prov. Fer.","% Provisao Ferias","@E 999.9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_EMPRE2","14","","C",	2,0,"02","RX_CODCHAVE",	1,2,"Filial","Filial","@!","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_AA2","15","","C",		4,0,"02","RX_CODCHAVE",	3,4,"Ano","Ano","9999","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_MM2","16","","C",		2,0,"02","RX_CODCHAVE",	7,2,"Mes","Mes","99","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_TIPOC2","17","","C",	1,0,"02","RX_CODCHAVE",	9,1,"Tipo Contrat","Tipo de Contrato","@!","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_COD2","18","","F",	1,0,"02","RX_COD",		10,1,"Fixo","Numero do Registro","9","","","2","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SALEDU","19","11","N",5,2,"02","RX_TXT",		1,5,"% Sal. Educ.","% Salario Educacao","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_INCRA","20","12","N",	5,2,"02","RX_TXT",		6,5,"% INCRA","% INCRA","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SENAI","21","13","N",	5,2,"02","RX_TXT",		11,5,"% SENAI","% SENAI","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SESI","22","14","N",	5,2,"02","RX_TXT",		16,5,"% SESI","% SESI","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SENAC","23","15","N",	5,2,"02","RX_TXT",		21,5,"% SENAC","% SENAC","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SESC","24","16","N",	5,2,"02","RX_TXT",		26,5,"% SESC","% SESC","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SEBRAE","25","17","N",5,2,"02","RX_TXT",		31,5,"% SEBRAE","% SEBRAE","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_DPC","26","18","N",	5,2,"02","RX_TXT",		36,5,"% DPC","% DPC","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_FAER","27","19","N",	5,2,"02","RX_TXT",		41,5,"% F. AER.","F. AER.","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SENAR","28","20","N",	5,2,"02","RX_TXT",		46,5,"% SENAR","% SENAR","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SECONC","29","21","N",5,2,"02","RX_TXT",		51,5,"% SECONC","% SECONC","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_TERCEI","30","22","C",4,2,"02","RX_TXT",		56,4,"Cod.Terceiro","Codigo Terceiros","@!","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_EMPRE3","31","","C",	2,0,"03","RX_CODCHAVE",	1,2,"Filial","Filial","@!","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_AA3","32","","C",		4,0,"03","RX_CODCHAVE",	3,4,"Ano","Ano","9999","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_MM3","33","","C",		2,0,"03","RX_CODCHAVE",	7,2,"Mes","Mes","99","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_TIPOC3","34","","C",	1,0,"03","RX_CODCHAVE",	9,1,"Tipo Contrat","Tipo de Contrato","@!","","","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_COD3","35","","F",	1,0,"03","RX_COD",		10,1,"Fixo","Numero do Registro","9","","","3","","0","","",""})
	aadd(aSIG,{ "","X14","X14_CODEMP","36","23","C",13,0,"03","RX_TXT",		1,13,"Cod.Emp.FGTS","Codigo da Empr. no FGTS","","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_PROVRE","37","24","N",8,4,"03","RX_TXT",		14,8,"% Prov.Resc.","% Prov. Rescisao","@E 999.9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SEST","38","25","N",	5,2,"03","RX_TXT",		22,5,"% SEST","% SEST","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SENAT","39","26","N",	5,2,"03","RX_TXT",		27,5,"% SENAT","% SENAT","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SIMPLE","40","27","C",1,0,"03","RX_TXT",		32,1,"Opt. Simples","Optante pelo Simples","9","Pertence('12')","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_CODGPS","41","28","C",4,0,"03","RX_TXT",		33,4,"Cod.Pgto GPS","Codigo de Pagto da GPS","9999","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_SESCOO","42","29","N",5,2,"03","RX_TXT",		37,5,"% SESCOOP","% SESCOOP","@E 99.99","","X","","","0","","",""})
	aadd(aSIG,{ "","X14","X14_RECFAT","43","30","C",1,0,"03","RX_TXT",		42,1,"Rec.Fatur.","Recolhe s/ faturamento","@!","Pertence('SN')","X","","","0","","",""})


	ProcRegua(Len(aSIG))
	DbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))
    (cAlias)->(DbGoTop())
    While (cAlias)->(!EOF())
		If (cAlias)->R5_ARQUIVO == "X14"
			If (nPos:= aScan(aFilial, {|x| x==(cAlias)->R5_FILIAL})) == 0
				aAdd(aFilial, (cAlias)->R5_FILIAL)
			EndIf
		    (cAlias)->(RecLock(cAlias, .F.))
		    (cAlias)->(DbDelete())
		    (cAlias)->(Msunlock())
		EndIf
	    (cAlias)->(DbSkip())
    EndDo
    
	If Len(aFilial) == 0
		aAdd(aFilial, "")
	EndIf

    For k:=1 To Len(aFilial)
	    For i:=1 To Len(aSIG)
			(cAlias)->(RecLock(cAlias,.T.))
			For j:=1 To Len(aSIG[i])
				If FieldPos(aSIGEstrut[j])>0
					FieldPut(FieldPos(aSIGEstrut[j]),aSIG[i,j])
				EndIf
			Next j
			(cAlias)->(MsUnLock())
			cTexto += "Atualização do Parametro '"+aSig[i][2]+"' - '"+aSig[i][3]+"!"+CHR(10)+CHR(13)
	    Next i
    Next k

End Sequence

Return cTexto