#INCLUDE "Protheus.ch"
/*
Funcao      : UPDGTHDV2
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Update para atualização do GTHD para a Versão 2.
Autor       : Jean Victor Rocha
Data/Hora   : 12/02/2014
Revisao     : 
Obs.        :
*/  

*--------------------------------*
User Function UPDGTHDV2(lAmbiente)
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


Local aChamados := { 	{09, {|| AtuSXA()}},;
						{09, {|| AtuSX3()}},;
						{09, {|| AtuSXB()}},;
						{09, {|| AtuSX7()}} }

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

/*
Funcao      : AtuSX3
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizações no SX3.
Revisao     :
Obs.        :
*/ 
*------------------------------*
Static Function AtuSX3(oProcess)
*------------------------------*
Local cTexto := ""                                    
Local cAlias  := ''
Local aSX3    :={}
Local aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" 	,;
	           	   "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  	,;
	        	   "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER"	,;
	        	   "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" , "X3_PYME"	,;
	        	   "X3_CONDSQL","X3_CHKSQL"	,"X3_IDXSRV" ,"X3_ORTOGRA","X3_IDXFLD" ,"X3_TELA"   }


SX3->(DbSetOrder(2))
If SX3->(DBSeek("Z03_TIPO")) .and. ALLTRIM(SX3->X3_CBOX) <> "L=Lider N1;M=Lider N2;A=Atendente N1;B=Atendente N2"
	RecLock("SX3", .F.)
	SX3->X3_VALID   := 'Vazio() .or. Pertence("LMAB")'
	SX3->X3_CBOX	:= 'L=Lider N1;M=Lider N2;A=Atendente N1;B=Atendente N2'
	SX3->X3_CBOXSPA	:= 'L=Lider N1;M=Lider N2;A=Atendente N1;B=Atendente N2'
	SX3->X3_CBOXENG	:= 'L=Lider N1;M=Lider N2;A=Atendente N1;B=Atendente N2;'
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If SX3->(DBSeek("Z01_CODATE")) .and. ALLTRIM(SX3->X3_TITULO) <> "Cd.Atend.N1"
	RecLock("SX3", .F.)
	SX3->X3_TITULO  := 'Cd.Atend.N1'
	SX3->X3_TITSPA	:= 'Cd.Atend.N1'
	SX3->X3_TITENG	:= 'Cd.Atend.N1'
	SX3->X3_DESCRIC	:= 'Codigo do Atendente N1'
	SX3->X3_DESCSPA	:= 'Codigo do Atendente N1'
	SX3->X3_DESCENG	:= 'Codigo do Atendente N1'
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If !SX3->(DBSeek("Z01_CODAT2"))
	aAdd(aSx3, {"Z01","23","Z01_CODAT2","C",06,0,"Cd.Atend.N2","Cd.Atend.N2","Cd.Atend.N2","Codigo do Atendente N2","Codigo do Atendente N2","Codigo do Atendente N2","999999","","€€€€€€€€€€€€€€ ","","Z03N2",0,"þA","","S","U","N","A","R","","","","","","","","","","1","N","","","N","N","N",""})
Else
	RecLock("SX3", .F.)
	SX3->X3_ORDEM	:= "23"
	SX3->X3_F3		:= "Z03N2"
	SX3->X3_BROWSE  := "N"
	SX3->(MsUnlock()) 
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf                          

If SX3->(DBSeek("Z01_CODATE"))
	RecLock("SX3", .F.)
	SX3->X3_F3  := "Z03N1"
	SX3->X3_BROWSE := "N"
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If SX3->(DBSeek("Z01_PARECE"))
	RecLock("SX3", .F.)
	SX3->X3_FOLDER  := "4"
	SX3->X3_TITULO	:= "Solução"
	SX3->X3_TITSPA	:= "Solução"
	SX3->X3_TITENG	:= "Solução"
	SX3->X3_DESCRIC := "Solução do Chamado"
	SX3->X3_DESCSPA := "Solução do Chamado"
	SX3->X3_DESCENG := "Solução do Chamado"
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If SX3->(DBSeek("Z01_PRIORI"))
	RecLock("SX3", .F.)
	SX3->X3_RELACAO  := "'3'"
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If SX3->(DBSeek("Z01_TIPO"))
	RecLock("SX3", .F.)
	SX3->X3_RELACAO  := "'G'"
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If SX3->(DBSeek("Z01_TPSOLI"))
	RecLock("SX3", .F.)
	SX3->X3_RELACAO  := "'I'"
	SX3->(MsUnlock())
	cTexto += " - Campo '"+ALLTRIM(SX3->X3_CAMPO)+"' atualizado."+CHR(13)+CHR(10)
EndIf

If !SX3->(DBSeek("Z01_KNOW"))
	aAdd(aSx3, {"Z01","37","Z01_KNOW","M",10,0,"Parecer Tec.","Parecer Tec.","Parecer Tec.","Parecer Tecnico","Parecer Tecnico","Parecer Tecnico","","","€€€€€€€€€€€€€€ ","","",0,"þA","","","U","S","A","R","","","","","","","","","","4","N","","","N","N","N",""})
EndIf

//Tratamento quando é inclusão de campo.
SX3->(DbSetOrder(2))
For i:=1 to Len(aSx3)
	If !Empty(aSX3[i][1])
		lSX3 := SX3->(DbSeek(aSX3[i,3]))
		If !(aSX3[i,1]$cAlias)
			cAlias += aSX3[i,1]+"/"
			aAdd(aArqUpd,aSX3[i,1])
		EndIf
		RecLock("SX3",!lSX3)
		For j:=1 To Len(aSX3[i])
			If FieldPos(aEstrut[j]) > 0 .And. aSX3[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
			EndIf
		Next j
		DbCommit()
		MsUnlock()
		cTexto += 'Campo '+aSX3[i][3]+' Atualizado com sucesso. '+ NL
	EndIf
Next i

Return cTexto

/*
Funcao      : AtuSXB
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizações no SXB.
Revisao     :
Obs.        :
*/ 
*------------------------------*
Static Function AtuSXB(oProcess)
*------------------------------*
Local cTexto := ""
Local aEstrut:= { "XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM"}
Local aSXB := {}

aAdd(aSxb, {"Z03N1 ","1","01","DB","Atendentes Help-Desk"	,"Atendentes Help-Desk"	,"Atendentes Help-Desk"	,"Z03"								   			,""})
aAdd(aSxb, {"Z03N1 ","2","01","01","Codigo"			   		,"Codigo"				,"Codigo"				,""									   			,""})
aAdd(aSxb, {"Z03N1 ","4","01","01","Codigo"			  		,"Codigo"				,"Codigo"				,"Z03_CODIGO"						   			,""})
aAdd(aSxb, {"Z03N1 ","4","01","02","Nome"			  		,"Nome"					,"Nome"					,"Z03_NOME"							   			,""})
aAdd(aSxb, {"Z03N1 ","4","01","03","Tp.Atendente"			,"Tp.Atendente"			,"Tp.Atendente"			,"Z03_TIPO"	   						   			,""})
aAdd(aSxb, {"Z03N1 ","5","01",""  ,""						,""						,""						,"Z03->Z03_CODIGO" 					   			,""})
aAdd(aSxb, {"Z03N1 ","5","02",""  ,""						,""						,""						,"Z03->Z03_NOME"	   					   		,""})
aAdd(aSxb, {"Z03N1 ","6","01",""  ,""						,""						,""						,"Z03->Z03_ATIVO='S' .AND. Z03->Z03_TIPO$'A/L'"	,""})

aAdd(aSxb, {"Z03N2 ","1","01","DB","Atendentes Help-Desk"	,"Atendentes Help-Desk"	,"Atendentes Help-Desk"	,"Z03"								   			,""})
aAdd(aSxb, {"Z03N2 ","2","01","01","Codigo"			   		,"Codigo"				,"Codigo"				,""									   			,""})
aAdd(aSxb, {"Z03N2 ","4","01","01","Codigo"			  		,"Codigo"				,"Codigo"				,"Z03_CODIGO"						   			,""})
aAdd(aSxb, {"Z03N2 ","4","01","02","Nome"			  		,"Nome"					,"Nome"					,"Z03_NOME"							   			,""})
aAdd(aSxb, {"Z03N2 ","4","01","03","Tp.Atendente"			,"Tp.Atendente"			,"Tp.Atendente"			,"Z03_TIPO"	   						   			,""})
aAdd(aSxb, {"Z03N2 ","5","01",""  ,""						,""						,""						,"Z03->Z03_CODIGO" 					   			,""})
aAdd(aSxb, {"Z03N2 ","5","02",""  ,""						,""						,""						,"Z03->Z03_NOME"					   			,""})
aAdd(aSxb, {"Z03N2 ","6","01",""  ,""						,""						,""						,"Z03->Z03_ATIVO='S' .AND. Z03->Z03_TIPO$'B/M'"	,""})

SXB->(DbSetOrder(1))//XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA

For i:=1 to Len(aSxb)
	If !Empty(aSxb[i][1]) .And. !Empty(aSxb[i][2])
		lSXB := SXB->(DbSeek(aSxb[i,1]+aSxb[i,2]+aSxb[i,3]+aSxb[i,4]))
		RecLock("SXB",!lSXB)
		For j:=1 To Len(aSxb[i])
			If FieldPos(aEstrut[j]) > 0 .And. aSxb[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSxb[i,j])
			EndIf
		Next j
		DbCommit()
		MsUnlock()
		cTexto += 'Consulta Padrão '+aSxb[i,1]+aSxb[i,2]+aSxb[i,3]+aSxb[i,4]+' Atualizada com sucesso. '+ NL
	Endif
Next i

Return cTexto

/*
Funcao      : AtuSXA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizações no SXA.
Revisao     :
Obs.        :
*/ 
*------------------------------*
Static Function AtuSXA(oProcess)
*------------------------------*
Local cTexto := ""    
Local aEstrut:= { "XA_ALIAS","XA_ORDEM","XA_DESCRIC","XA_DESCSPA","XA_DESCENG","XA_PROPRI"}
Local aSXA := {}
Local lSXA := .T.

aAdd(aSXA, {"Z01","4","Soluções","Soluções","Soluçõe","U"})

SXA->(DbSetOrder(1))
For i:=1 to Len(aSXA)
	If !Empty(aSXA[i][1]) .And. !Empty(aSXA[i][2])
		lSXA := SXA->(DbSeek(aSXA[i,1]+aSXA[i,2]))
		RecLock("SXA",!lSXA)
		For j:=1 To Len(aSXA[i])
			If FieldPos(aEstrut[j]) > 0 .And. aSXA[i,j] != Nil
				FieldPut(FieldPos(aEstrut[j]),aSXA[i,j])
			EndIf
		Next j
		DbCommit()
		MsUnlock()
		cTexto += 'Folder '+aSXA[i,1]+aSXA[i,2]+' Atualizada com sucesso. '+ NL
	Endif
Next i

Return cTexto

/*
Funcao      : AtuSXA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizações no SX7.
Revisao     :
Obs.        :
*/ 
*------------------------------*
Static Function AtuSX7(oProcess)
*------------------------------*
Local cTexto := ""    
Local cZ01_DEPTO	:= "POSICIONE('SX5',1,xFilial('SX5')+'Z2'+M->Z01_DEPTO,'X5_DESCRI')"
Local cZ01_CODEMP	:= 'U_HDA001Dic("Z01_EMPRES","GATILHO")'

SX7->(DbSetOrder(1))
If SX7->(DbSeek("Z01_DEPTO001")) .and. ALLTRIM(SX7->X7_REGRA) <> cZ01_DEPTO
	RecLock("SX7", .F.)
	SX7->X7_REGRA	:= cZ01_DEPTO
	SX7->(MsUnlock())
	cTexto += 'Gatilho '+ALLTRIM(SX7->X7_CAMPO)+' Atualizado com sucesso. '+ NL
EndIf

If SX7->(DbSeek("Z01_CODEMP002"))
	RecLock("SX7", .F.)
	SX7->X7_REGRA	:= cZ01_CODEMP
	SX7->(MsUnlock())
	cTexto += 'Gatilho '+ALLTRIM(SX7->X7_CAMPO)+' Atualizado com sucesso. '+ NL
EndIf

SX7->(DbSetOrder(1))
If !SX7->(DbSeek("Z01_CODAT2"))
	RecLock("SX7", .T.)
	SX7->X7_CAMPO	:= "Z01_CODAT2"
	SX7->X7_SEQUENC	:= "001"
	SX7->X7_REGRA	:= "Z03->Z03_NOME"
	SX7->X7_CDOMIN	:= "Z01_NOMATE"
	SX7->X7_TIPO	:= "P"
	SX7->X7_SEEK	:= "S"
	SX7->X7_ALIAS	:= "Z03"
	SX7->X7_ORDEM	:= 1
	SX7->X7_CHAVE	:= "xFilial('Z03')+M->Z01_CODAT2"
	SX7->X7_PROPRI	:= "S"
	SX7->(MsUnlock())
	cTexto += 'Gatilho '+ALLTRIM(SX7->X7_CAMPO)+' Incluido com sucesso. '+ NL
EndIf

Return cTexto