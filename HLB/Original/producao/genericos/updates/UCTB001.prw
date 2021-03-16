#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : UCTB001
Parametros  :
Retorno     : Nenhum
Objetivos   : Criação da tabela FIA.
Autor       : Jean Victor Rocha	
Data/Hora   : 30/05/2012
Revisao     : 
Obs.        : 
*/ 
User Function UCTB001()

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


Local aChamados := { 	{04, {|| AtuSX2()}},;
						{04, {|| AtuSX3()}},;
						{04, {|| AtuSIX()}}}

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
Static Function AtuSIX()
*----------------------*
Local cTexto    := ''
Local aSIXEstrut:= {}
Local aSIX      := {}
Local i, j
Local cAlias    := ''

Local nI
Local hFile, hFile2                                                
Local cBuffer    := ""
Local nSize      := 0
Local nInc 
Local cLine      := ""
Local aMenu      := {}
Local nLidos     := 0 
Local nSizeCodX3 := AvSx3("W3_COD_I",3)

Begin Sequence       

	// Atualização dos indices na tabela SIX
	aSIXEstrut:= {"INDICE","ORDEM","CHAVE"																	,"DESCRICAO"																,"DESCSPA"																	,"DESCENG"																	,"PROPRI","F3","NICKNAME","SHOWPESQ"}
	aadd(aSIX,{"FIA","1","FIA_FILIAL+FIA_CLIENT+FIA_LOJA+FIA_PREFIX+FIA_NUM+FIA_PARCEL+FIA_TIPO+FIA_SEQ","Cliente + Loja + Prefixo + Numero + Parcela + Tipo + Sequencia","Cliente + Tienda + Prefijo + Numero + Cuota + Tipo + Secuencia","Customer + Unit + Prefix + Number + Installment + Type + Sequence","S","","","S"})
	aadd(aSIX,{"FIA","2","FIA_FILIAL+FIA_DTPROV+FIA_CLIENT+FIA_LOJA+FIA_PREFIX+FIA_NUM+FIA_PARCEL+FIA_TIPO+FIA_SEQ","Data Provis. + Cliente + Loja + Prefixo + Numero + Parcela + Tipo + Se","Fecha Prov. + Cliente + Tienda + Prefijo + Numero + Cuota + Tipo + Sec","Allow. Date + Customer + Unit + Prefix + Number + Installment + Type +","S","","","S"})
	aadd(aSIX,{"FIA","3","FIA_FILIAL+FIA_NODIA","Seq. Diário","Sec. Diario","Tax Rec. Seq","S","","","N"})
	For i:= 1 To Len(aSIX)
		If SIX->(DbSeek(aSIX[i,1]))
			While SIX->(!EOF()) .and. SIX->INDICE == aSIX[i,1]
				RecLock("SIX",.F.)
				SIX->(DbDelete())
				SIX->(MsUnlock())
				SIX->(DbSkip())				
			EndDo
		EndIf
	Next i

	ProcRegua(Len(aSIX))
	dbSelectArea("SIX")
	SIX->(DbSetOrder(1))	
	For i:= 1 To Len(aSIX)
		RecLock("SIX",.T.)
		If UPPER(AllTrim(CHAVE)) != UPPER(Alltrim(aSIX[i,3]))
			aAdd(aArqUpd,aSIX[i,1])
			If !(aSIX[i,1]$cAlias)
				cAlias += aSIX[i,1]+"/"
			EndIf
			For j:=1 To Len(aSIX[i])
				If FieldPos(aSIXEstrut[j])>0
					FieldPut(FieldPos(aSIXEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			MsUnLock()
			cTexto  += (aSix[i][1]+" - "+aSix[i][3]+CHR(13)+CHR(10) )
		EndIf
		IncProc("Atualizando índices...")
	Next i
End Sequence

Return cTexto

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

	Aadd(aSX3,{"FIA","01","FIA_FILIAL"	,"C",2,0,"Filial","Sucursal","Branch","Filial","Sucursal","Branch","","",cUsado,"","",1,cReserv,"","","S","N","V","R","","","","","","","","","","",""})
	Aadd(aSX3,{"FIA","02","FIA_CLIENT"	,"C",6,0,"Cliente","Cliente","Customer","Cliente","Cliente","Customer","@!","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","001","","S"})
	Aadd(aSX3,{"FIA","03","FIA_LOJA"	,"C",2,0,"Loja","Tienda","Unit","Loja","Tienda","Unit","@!","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","002","","S"})
	Aadd(aSX3,{"FIA","04","FIA_PREFIX"	,"C",2,0,"Prefixo","Prefijo","Prefix","Prefixo","Prefijo","Prefix","","",cUsado,"","",1,cReserv,"","","","S","V","","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","05","FIA_NUM"		,"C",9,0,"Numero","Numero","Number","Numro","Numero","Number","@!","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","018","","S"})
	Aadd(aSX3,{"FIA","06","FIA_DTPROV"	,"D",8,0,"Data Provis.","Fecha Prov.","Allow. Date","Data Provisao","Fecha Provision","Allowance Date","","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","07","FIA_PARCEL"	,"C",1,0,"Parcela","Cuota","Installment","Parcela","Cuota","Installment","@!","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","011","","S"})
	Aadd(aSX3,{"FIA","08","FIA_TIPO"	,"C",3,0,"Tipo","Tipo","Type","Tipo","Tipo","Type","","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","09","FIA_VALOR"	,"N",14,2,"Valor","Valor","Value","Valor","Valor","Value","@E 999,999,999.99","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","10","FIA_MOEDA"	,"N",2,0,"Moeda","Moneda","Currency","Moeda","Moneda","Currency","","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","11","FIA_VLLOC"	,"N",14,2,"Vl. M. Local","Vl. M. Local","Loc.Curr.Vl.","Valor moeda local","Valor moneda local","Local Currency Value","@E 999,999,999.99","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","12","FIA_SEQ"		,"C",3,0,"Sequencia","Secuencia","Sequence","Sequencia provisao","Secuencia provision","Allowance sequence","","",cUsado,"","",1,cReserv,"","","","S","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","13","FIA_DIACTB"	,"C",2,0,"Cod Diario","Cod Diario","Tax Rec. Cd.","Cod Diario Contabilidade","Cod Diario Contabilidad","Accounting Tax Rec. Code"," @!","IIF( FindFunction('VldCodSeq') , VldCodSeq() , .T. )",cUsado,"IIF( FindFunction('CtbRDia') , CtbRDia() , '' )","CVL",1,cReserv,"","","","","R","","","","","","","","IIF( FindFunction('CtbWDia') , CtbWDia() , .F. )","","","","S"})
	Aadd(aSX3,{"FIA","14","FIA_LA"		,"C",1,0,"Flag Contab","Flag Contab","Acc. Flag","Flag Contabil","Flag Contable","Accounting Flag","","",cUsado,"","",1,cReserv,"","","","N","V","R","","","","","","","","","","","S"})
	Aadd(aSX3,{"FIA","15","FIA_NODIA"	,"C",10,0," Seq. Diario"," Sec. Diario"," Tax Rec. Se"," Seq. Diario Contabilidad"," Sec. diario Contabilidad"," Acc. Tax Rec. Sequence"," @!","",cUsado,"","",1,cReserv,"","","","","V","","","","","","","","","","","","S"})
 

     
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
		 	 cTexto += 'Campos '+aSX3[i][3]+' criados com sucesso. '+ CHR(10) + CHR(13)
		  EndIf
	   EndIf
   Next i

End Sequence

Return cTexto

*----------------------*
Static Function ATUSX2()
*----------------------*
Local aSX2       := {}
Local aSX2Estrut := {}
Local lSX2	     := .F.
Local cTexto     := ""
Local cAlias     := "" 

	Aadd(aSX2,{"FIA","","FIA" + SM0->M0_CODIGO + "0","Provisao para cobrança duvidos","Provision cuentas cobranza dud","Provision for collection due","","E","","FIA_FILIAL+FIA_CLIENT+FIA_LOJA+FIA_PREFIX+FIA_NUM+FIA_PARCEL+FIA_TIPO+FIA_SEQ","S",6})
	
   aSX2Estrut:= {"X2_CHAVE","X2_PATH","X2_ARQUIVO","X2_NOME","X2_NOMESPA","X2_NOMEENG","X2_ROTINA","X2_MODO",;
                 "X2_TTS","X2_UNICO","X2_PYME","X2_MODULO"}

   SX2->(DbSetOrder(1))	

   For i:= 1 To Len(aSX2)
      If !Empty(aSX2[i][1])
	     If !SX2->(DbSeek(aSX2[i,1]))
		    lSX2	:= .T.
			If !(aSX2[i,1]$cAlias)
			   cAlias += aSX2[i,1]+"/"
		    EndIf
		    RecLock("SX2",.T.)
			For j:=1 To Len(aSX2[i])
			   If FieldPos(aSX2Estrut[j])>0 .And. aSX2[i,j] != Nil
			      FieldPut(FieldPos(aSX2Estrut[j]),aSX2[i,j])
			   EndIf
		    Next j
		    DbCommit()
		    MsUnlock()
         EndIf
      EndIf
   Next i

   If lSX2
      cTexto += 'Foram alteradas as estruturas das seguintes tabelas : '+ cAlias + CHR(10) + CHR(13)
   EndIf    
	
Return cTexto               