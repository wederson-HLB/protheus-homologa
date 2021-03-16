#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : USIX003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização do Dicionario de indices. SIX.
Autor       : Jean Victor Rocha
Data/Hora   : 13/02/12
*/

User Function USIX003()

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


Local aChamados := { 	{04, {|| AtuSIX()}},;
						{04, {|| AtuSX3()}}}

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

	aadd(aSIX,{ "SN1","1","N1_FILIAL+N1_CBASE+N1_ITEM"														,"Cod. do Bem + Item"														,"Bien + Item"																,"Goods Code + Item"											 			,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN1","2","N1_FILIAL+N1_CHAPA"																,"Num.Plaqueta"																,"Num.Plaquita"																,"Numberplate"																,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN1","3","N1_FILIAL + N1_BASESUP + N1_ITEMSUP"												,"Codigo Base + Item Sup"											   		,"Codigo Base + Item Sup"													,"Base Code + Sup. Item"					 								,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN1","4","N1_FILIAL+N1_CODCIAP"															,"Codigo CIAP"																,"Codigo CIAP"																,"CIAP Code"																,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN1","5","N1_FILIAL+N1_APOLICE+N1_CODSEG+N1_CBASE+N1_ITEM"									,"Num. Apolice + Cod.Cia.Seg. + Cod. do Bem + Item"							,"Nro. Poliza + Cod.Cia.Seg. + Bien + Item"									,"Policy Numb. + Ins.Com.Code + Goods Code + Item"							,"S","SNB+ATFAS+SN1"		,""			,"S"})
	aadd(aSIX,{ "SN1","6","N1_FILIAL+N1_NODIA"																,"Seq. Diario"																,"Sec. Diario"																,"Tax Rec. Seq"											   					,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN1","7","N1_FILIAL+N1_TAXAPAD+N1_CBASE+N1_ITEM"											,"Cod. do Bem + Cod. Taxa Padrao + Item"									,"Cod. del Bien + Cod. Taxa Estandard + Item"								,"Asset Code + Standard Tax Code + Item"									,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN1","8","N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM"			,"Cod. Fornec. + Loja Fornec. + Espécie + Nota Fiscal + Serie N.F. + Ite"	,"Cod. Proveed + Tienda Prov. + Especie + Factura + Serie Fact. + Item"		,"Supplier Cd. + Supplier St. + Specie + Invoice + Inv.Series + Item"		,"S",""						,""			,"S"})

	aadd(aSIX,{ "SN2","1","N2_FILIAL+N2_CBASE+N2_ITEM+N2_TIPO+N2_SEQUENC"									,"Cod Base Bem + Numero Item + Tipo + Sequencia"							,"Base de Bien + Num. Item + Tipo + Secuencia"								,"Asset Bs.Cd. + Item Number + Type + Sequence"								,"S","SN1"					,""			,"S"})

	aadd(aSIX,{ "SN3","1","N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ"								,"Cod Base Bem + Codigo Item + Tipo Ativo + Ocor Baixa + Seq Aquisic"		,"Base de Bien + Codigo Item + Tipo Activo + Event.Cancel + Sec. Adquis."	,"Asset Bs.Cd. + Item Code + Asset Type + Post. Occur. + Seq. Acquis."		,"S","SN1"					,""			,"S"})
	aadd(aSIX,{ "SN3","2","N3_FILIAL+N3_CCONTAB+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA"	  						,"Conta + Cod Base Bem + Codigo Item + Tipo Ativo + Ocor Baixa"				,"Cuenta + Base de Bien + Codigo Item + Tipo Activo + Event.Cancel"			,"Account + Asset Bs.Cd. + Item Code + Asset Type + Post. Occur."			,"S","CT1+SN1"				,""			,"S"})
	aadd(aSIX,{ "SN3","3","N3_FILIAL+N3_CCUSTO+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA"							,"CC Despesa + Cod Base Bem + Codigo Item + Tipo Ativo + Ocor Baixa"		,"Cc Gasto + Base de Bien + Codigo Item + Tipo Activo + Event.Cancel"		,"Expense CC + Asset Bs.Cd. + Item Code + Asset Type + Post. Occur."		,"S","CTT+SN1"				,""			,"S"})
	aadd(aSIX,{ "SN3","4","N3_FILIAL+N3_CCONTAB+N3_CCUSTO+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA"				,"Conta + CC Despesa + Cod Base Bem + Codigo Item + Tipo Ativo + Ocor Ba"	,"Cuenta + Cc Gasto + Base de Bien + Codigo Item + Tipo Activo + Event.C"	,"Account + Expense CC + Asset Bs.Cd. + Item Code + Asset Type + Post. O"	,"S","CT1+CTT+SN1"			,""			,"S"})
	aadd(aSIX,{ "SN3","5","N3_FILIAL+N3_CCUSTO+N3_CCONTAB+N3_CBASE+N3_ITEM+N3_TIPO"							,"CC Despesa + Conta + Cod Base Bem + Codigo Item + Tipo Ativo"				,"Cc Gasto + Cuenta + Base de Bien + Codigo Item + Tipo Activo"				,"Expense CC + Account + Asset Bs.Cd. + Item Code + Asset Type"				,"S","CTT+CT1+SN1"	  		,""			,"S"})
	aadd(aSIX,{ "SN3","6","N3_FILIAL+N3_SUBCTA+N3_CCUSTO+N3_CCONTAB+N3_CBASE+N3_ITEM+N3_TIPO"				,"Item Despesa + CC Despesa + Conta + Cod Base Bem + Codigo Item + Tipo"	,"Item Gasto + Cc Gasto + Cuenta + Base de Bien + Codigo Item + Tipo Act"	,"Expense Ass. + Expense CC + Account + Asset Bs.Cd. + Item Code + Asset"	,"S","CTD+CTT+CT1+SN1"		,""			,"S"})
	aadd(aSIX,{ "SN3","7","N3_FILIAL+N3_CLVL+N3_SUBCTA+N3_CCUSTO+N3_CCONTAB+N3_CBASE+N3_ITEM+N3_TIPO"		,"ClVl Despesa + Item Despesa + CC Despesa + Conta + Cod Base Bem + Codi"	,"Cl Vl Gasto + Item Gasto + Cc Gasto + Cuenta + Base de Bien + Codigo I"	,"Expense VlCl + Expense Ass. + Expense CC + Account + Asset Bs.Cd. + It"	,"S","CTH+CTD+CTT+CT1+SN1"	,""			,"S"})
	aadd(aSIX,{ "SN3","8","N3_FILIAL+N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ"							,"Cd Bx Transf + Cod Base Bem + Codigo Item + Tipo Ativo + Seq Aquisic"		,"Cd Bj Transf + Base de Bien + Codigo Item + Tipo Activo + Sec. Adquis."	,"Transf. Code + Asset Bs.Cd. + Item Code + Asset Type + Seq. Acquis."		,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN3","9","N3_FILIAL+N3_NODIA"																,"Seq. Diario"																,"Sec. Diario"																,"Tax Rec. Seq"																,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN3","A","N3_FILIAL+N3_CODRAT"																,"Cod. Rateio"																,"Cod. Prorrat"																,"Prorat. Code"																,"S",""						,"RATEIO"	,"N"})

	aadd(aSIX,{ "SN4","1","N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ"				,"Cod Base + Cod Item + Tipo Ativo + Data Movim. + Tipo Movim. + Seq Aqu"	,"Cod. Base + Item + Tipo Activo + Fch  Movim. + Tipo Movim. + Sec. Adqu"	,"Asset Bs.Cd. + Item code + Asset Type + Movement Dt. + Movem.Type + Se"	,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","2","N4_FILIAL+N4_CONTA+DTOS(N4_DATA)"												,"Codigo Conta + Data Movim."												,"Cuenta + Fch  Movim."														,"Account Code + Movement Dt."												,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","3","N4_FILIAL+N4_CONTA+N4_SUBCTA+DTOS(N4_DATA)+N4_OCORR"								,"Codigo Conta + Item da Cont + Data Movim. + Tipo Movim."					,"Cuenta + Item Cuenta + Fch  Movim. + Tipo Movim."							,"Account Code + Account Item + Movement Dt. + Movem.Type"					,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","4","N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+DTOS(N4_DATA)"						,"Cod Base + Cod Item + Tipo Ativo + Tipo Movim. + Data Movim."				,"Cod. Base + Item + Tipo Activo + Tipo Movim. + Fch  Movim."				,"Asset Bs.Cd. + Item code + Asset Type + Movem.Type + Movement Dt."		,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","5","N4_FILIAL+N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ"							,"Cd Bx Transf + Cod Base + Cod Item + Tipo Ativo + Seq Aquisic"			,"Cd Bj Transf + Cod. Base + Item + Tipo Activo + Sec. Adquis."				,"Transfer Cd. + Asset Bs.Cd. + Item code + Asset Type + Seq. Acquis."		,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","6","N4_FILIAL+N4_IDMOV+N4_OCORR"										  				,"ID Movtos + Tipo Movim."													,"ID Movim. + Tipo Movim."													,"Mov.Ident. + Movem.Type"													,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","7","N4_FILIAL+N4_OCORR+DTOS(N4_DATA)"												,"Tipo Movim. + Data Movim."												,"Tipo Movim. + Data Movim."												,"Movem. Type + Movem. Date"												,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","8","N4_FILIAL+N4_NODIA"																,"Seq. Diario"																,"Sec. Diario"																,"Tax Rec. Seq"																,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN4","9","N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR","Cod Base+Cod Item+Tipo Ativo+Seq Aquisic+Seq Reaval+Data Movim.+Tipo M"		,"Cod. Base+Item+Tipo Activo+Sec. Adquis.+Sec.Evaluac.+Fch  Movim.+Tipo"	,"Asset Bs.Cd.+Item+Tipo Activo+Sec. Adquis.+Sec.Evaluac.+Fch  Movim.+Ti"	,"S",""						,""			,"S"})

	aadd(aSIX,{ "SN5","1","N5_FILIAL+N5_CONTA+DTOS(N5_DATA)+N5_TIPO+N5_TPBEM+N5_TPSALDO"					,"Cod Conta + Data Saldo + Tipo Registr+Tipo Bem+Tipo Saldo"				,"Cuenta + Fecha Saldo + Tipo Regist.+Tipo Bien+Tipo Saldo"					,"Account Code + Balance Date + Regist.Type+Tp Asset+Tp.Balance"			,"S",""						,""			,"S"})

	aadd(aSIX,{ "SN6","1","N6_FILIAL+N6_CONTA+N6_CCUSTO+N6_SUBCTA+DTOS(N6_DATA)+N6_TIPO+N6_TPBEM+N6_TPSALDO","Cod da Conta + Centro custo + Item Conta + Data + Tipo Movimen+Tipo Be"	,"Cuenta + Centro costo + Item Cuenta + Fecha + Tipo Movim.+Tipo Bien+Ti"	,"Account Code + Cost Center + Account Item + Date + Movem. Type+Tp Asse"	,"S",""						,""			,"S"})

	aadd(aSIX,{ "SN7","1","N7_FILIAL+N7_CBASE+N7_ITEM"														,"Codigo Base + Codigo Item"												,"Codigo Base + Codigo Item"												,"Asset Bs.Cd. + Item Code"													,"S","SN3"					,""			,"S"})

	aadd(aSIX,{ "SN8","1","N8_FILIAL+N8_CBASE+N8_ITEM+N8_TIPO+N8_SEQ+DTOS(N8_DTINV)"						,"Codigo Base + Codigo Item + Tipo + Seq Aquisic + Data Invent"				,"Codigo Base + Codigo Item + Tipo + Sec. Adquis. + Fch  Invent."			,"Base Code + Item Code + Type + Seq. Acquis. + Invent.Date"				,"S","SN3"					,""			,"S"})

	aadd(aSIX,{ "SN9","1","N9_FILIAL+N9_NROINIC+N9_NROFINA"													,"Nro Inicial + Nro Final"										   			,"Nro.Inicial + Nro. Final"													,"Initial No. + Final No."													,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN9","2","N9_FILIAL+N9_MATRIC"																,"Matricula"																,"Matricula"																,"Registration"																,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN9","3","N9_FILIAL+N9_NOMEPRO"															,"Nome Propri"																,"Nom.Propiet."																,"Owner Name"																,"S",""						,""			,"S"})
	aadd(aSIX,{ "SN9","4","N9_FILIAL+N9_TPACAO"																,"Tipo de Acao"																,"Tipo Accion"																,"Share Type"																,"S",""						,""			,"S"})

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

   aAdd(aSX3,{"SN3",;	            				//Arquivo
              "E5",;								//Ordem
			  "N3_CODRAT",;					    	//Campo
			  "C",;			        				//Tipo
		       12,;	                				//Tamanho
			   0,;				  					//Decimal
			  "Cod. Rateio ",;          		    //Titulo
			  "Cod. Prorrat",;  			        //Titulo SPA
			  "Prorat. Code",;	    	  			//Titulo ENG
			  "Codigo do rateio     ",;             //Descrição
			  "Codigo del prorrateio",;             //Descrição SPA
			  "Proration code       ",;	            //Descrição ENG
  			  "@!",;							    //Picture
  		      '',;              		            //Valid
			  cUsado,;				             	//Usado
			  '',;				     	            //Relação
			  "",;						            //F3
			  1,;						            //Nível
			  cReserv,;				             	//Reserv
			  "",;					            	//Check
			  "",;						            //Trigger
			  "S",;						            //Proprietário
			  "N",;						            //Browse
			  "V",;						            //Visual
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
			  "",;						            //Folder
			  ""})						            //Pyme
     
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
		 	 cTexto += 'Campos '+aSX3[i][3]+' criados com sucesso. '+ NL
		  EndIf
	   EndIf
   Next i

End Sequence

Return cTexto