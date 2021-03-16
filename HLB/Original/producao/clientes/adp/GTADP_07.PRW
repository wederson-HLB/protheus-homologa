#INCLUDE "GPER030.CH"       
#INCLUDE "PROTHEUS.CH" 
#Include "TopConn.ch"
#Include "TBICONN.CH"
#Include "AvPrint.ch" 
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Define DMPAPER_A4          9           // A4 210 X 297 MM

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GTADP_07 ³Autor  ³ Cesar Chena           ³ Data ³11/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rel. HLB BRASIL ADP - Pay Slip                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ Gera somente em excel.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico HLB BRASIL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*------------------------------------*
User Function GTADP_07(cPath,cPeriodo)
*------------------------------------*
//³ Define Variaveis Locais (Basicas)                            ³
Local cString:="SRA"        // alias do arquivo principal (Base)
Local aOrd   := {STR0001,STR0002,STR0003,STR0004,STR0005} //"Matricula"###"C.Custo"###"Nome"###"Chapa"###"C.Custo + Nome"
Local cDesc1 := STR0006		//"Emiss„o de Recibos de Pagamento."
Local cDesc2 := STR0007		//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 := STR0008		//"usu rio."
Local aDriver:= ReadDriver()
//³ Define Variaveis Locais (Programa)                           ³
Local nExtra,cIndCond,cIndRc
Local Baseaux := "S", cDemit := "N"
Local cHtml := ""
//³ Define o numero da linha de impressão como 0                 ³
SetPrc(0,0)

//³ Define Variaveis Private(Basicas)                            ³
Private aLinha   := { },nLastKey := 0
Private cSem_De  := "  /  /    "
Private cSem_Ate := "  /  /    "
Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe

Private cCompac := aDriver[1]
Private cNormal := aDriver[2]

//³ Define Variaveis Private(Programa)                           ³
Private aLanca := {}
Private aProve := {}
Private aDesco := {}
Private aBases := {}
Private aInfo  := {}
Private aCodFol:= {}
Private li     := _PROW()
Private Titulo := STR0011		//"EMISSO DE RECIBOS DE PAGAMENTOS"
Private lEnvioOk := .F.
Private lRetCanc	:= .t.
Private cMesAnoRef := cPeriodo //"062015"
Private nRecTipo := 2
Private cSemanaTerminal:= 0
Private cFilTerminal := xFilial()
Private cMatTerminal := "000001"
PRIVATE lAdjustToLegacy := .T.
PRIVATE lDisableSetup  := .T.
private _nnumrec := 1                 
private _ntotrec := 0                 
Private cPath
Private cPeriodo

Private cCID    := ""
Private cENTITT := ""
Private cLID    := ""
PRIVATE cCodemp := upper(ALLTRIM(SM0->M0_CODIGO))
                                
Private cNomeEmx := ""
Private cNomeEmp := STRTRAN(ALLTRIM(SM0->M0_NOME),".","-")

for x = 1 to len(cNomeEmp)
	if substr(cNomeEmp,x,1) <> " "
		cNomeEmx := cNomeEmx + substr(cNomeEmp,x,1)	
	endif
next x

cNomeEmp := alltrim(cNomeEmx)

Private cCC := ' '


//³ Envia controle para a funcao SETPRINT                        ³
wnrel:="GPER030"            //Nome Default do relatorio em Disco

//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
cSemanaTerminal := IF( Empty( cSemanaTerminal ), Space( Len( SRC->RC_SEMANA ) ), cSemanaTerminal )
dDataRef   		:= Stod(Substr(cMesAnoRef,-4)+SubStr(cMesAnoRef,1,2)+"01") //Data de Referencia para a impressao
nTipRel    		:= 4 //Tipo de Recibo (Pre/Zebrado/EMail)
Esc        		:= nRecTipo 	//Emitir Recibos(Adto/Folha/1¦/2¦/V.Extra)
Semana     		:= cSemanaTerminal 	//Numero da Semana
//cFilDe     		:= "" //Filial De
//cFilAte    		:= "99"	//Filial Ate
cFilDe     		:= _cFilialI //Filial De       // francisco neto 19/09/2016
cFilAte    		:= _cFilialF	//Filial Ate   // francisco neto 19/09/2016

cCcDe      		:= "" //Centro de Custo De
cCcAte     		:= "ZZZZZZZZZ" 	//Centro de Custo Ate
cMatDe     		:= "" //Matricula Des
cMatAte    		:= "ZZZZZZ"	//Matricula Ate
cNomDe     		:= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"//Nome De
cNomAte    		:= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"//Nome Ate
ChapaDe    		:= ""	//Chapa De
ChapaAte   		:= "ZZZZZ"	//Chapa Ate
Mensag1    		:= "" //Mensagem 1
Mensag2    		:= "" //Mensagem 2
Mensag3    		:= "" //Mensagem 3
cSituacao  		:= " ADFT" 	//Situacoes a Imprimir
cCategoria 		:= "ACDEGHIJMPST" //Categorias a Imprimir
cBaseAux   		:= "N" 	//Imprimir Bases
nDuas      		:= 1  //quantas vezes é para imprimir o mesmo contra-Cheque

//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"X0"+"CID")
	cCID := X5_DESCRI
Else
	Aviso("ATENÇÃO", "Não encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
	cENTITY := X5_DESCRI
Else
	Aviso("ATENÇÃO", "Não encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"LID")
	cLID := X5_DESCRI
Else
	Aviso("ATENÇÃO", "Não encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif

//// francisco neto  19/09/2016
DbSelectArea("SX2") //verifica compartilhamento de centro de custos
DbSetOrder(1)

If DbSeek("CTT")
	cCC := X2_MODO
Endif

RptStatus({|lEnd| R030Imp(@lEnd,wnRel,cString,cMesAnoRef,.f.,cPath,cPeriodo)},Titulo)  // Chamada do Relatorio

Return(cHtml)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R030IMP  ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento Para emissao do Recibo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------------------------------------------------------*
Static Function R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal,cPath,cPeriodo)
*-----------------------------------------------------------------------------*
//³ Define Variaveis Locais (Basicas)                            ³
Local lIgual                 //Vari vel de retorno na compara‡ao do SRC
Local cArqNew                //Vari vel de retorno caso SRC # SX3
Local aOrdBag     := {}
Local cMesArqRef  := If(Esc == 4,"13"+Right(cMesAnoRef,4),cMesAnoRef)
Local cArqMov     := ""
Local aCodBenef   := {}
Local cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
Local cAcessaSRA  := &("{ || " + ChkRH("GPER030 ","SRA","2") + "}")
Local cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
Local cAcessaSRI  := &("{ || " + ChkRH("GPER030","SRI","2") + "}")
Local cNroHoras   := &("{ || If(SRC->RC_QTDSEM > 0, SRC->RC_QTDSEM, SRC->RC_HORAS) }")
Local cHtml		  := ""
Local nHoras      := 0
Local nMes, nAno
Local nX
Local cMesCorrente:= getmv("MV_FOLMES")
Local dDataLibRh
Local nTcfDadt		:= if(lTerminal,getmv("MV_TCFDADT"),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF 
Local nTcfDfol		:= if(lTerminal,getmv("MV_TCFDFOL"),0)		// indica a quantidade de dias a somar ou diminuir no ultimo dia do mes corrente para liberar a consulta do TCF
Local nTcfD131		:= if(lTerminal,getmv("MV_TCFD131"),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
Local nTcfD132		:= if(lTerminal,getmv("MV_TCFD132"),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
Local nTcfDext		:= if(lTerminal,getmv("MV_TCFDEXT"),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
Local aDriver := LEDriver()
Local nContr  := 0
Local nContrT := 0
Local aArquivos := {}              

LOCAL nYear := VAL(subs(cPeriodo,4,4))

//Fontes utilizadas
Private _oFont8   := TFont():New("Arial", 09, 08,   ,.F., ,   , ,    , .F.)
Private _oFont8b  := TFont():New("Arial", 09, 08,.t.,.t., ,   , ,    , .F.)
Private _oFont10  := TFont():New("Arial", 09, 10,.T.,.F., 5,.T., 5, .T., .F.)
Private _oFont10b := TFont():New("Arial", 09, 10,.T.,.t., 5,.T., 5, .T., .F.)
Private _oFont12  := TFont():New("Arial", 09, 12,.T.,.F., 5,.T., 5, .T., .F.)
Private _oFont12b := TFont():New("Arial", 09, 12,.T.,.t., 5,.T., 5, .T., .F.)
Private _oFont14  := TFont():New("Arial", 09, 14,.T.,.T., 5,.T., 5, .T., .F.)
Private _oFont16  := TFont():New("Arial", 09, 16,.T.,.F., 5,.T., 5, .T., .F.)
Private _oBrush   := TBrush():New("",4)
Private _cont     := 0 //3500
Private  lFirst   := .t.
Private _pag      := 0
Private _cFig     := "\system\logo.bmp"   // logotipo da empresa
Private nLinhas   := 16          // Numero de Linhas do Miolo do Recibo
	
Private tamanho     := "M"
Private limite		:= 132
Private cAliasMov 	:= ""
Private cDtPago     := ""
Private cPict1		:= "@E 999,999,999.99"
Private cPict2 		:= "@E 99,999,999.99"
Private cPict3 		:= "@E 999,999.99"
Private cPict4 		:= "@E 99999999.99"
PRIVATE _cNomArq  	:= "SLP"
PRIVATE _cPer1ini 	:= subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
Private _cPer1fin   := ""
Private cPasta		:= "\TempPDFs\"//cPath

MakeDir(cPasta)
//Limpeza da pasta temporaria.
aArquivos := Directory(cPasta+"*.*")
For i:=1 to len(aArquivos)
	FErase(cPasta+aArquivos[i][1])
Next i

// monta periodo 1 final 
If subs(cPeriodo,1,2) $ "04/06/09/11"
	_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
	_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
Elseif subs(cPeriodo,1,2) $ "02"
	If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
		_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
	Else
		_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
	Endif
Endif

If MsDecimais(1) == 0
	cPict1	:=	"@E 99,999,999,999"
	cPict2 	:=	"@E 9,999,999,999"
	cPict3 	:=	"@E 99,999,999"
Endif

cMesArqRef := cMesAnoRef

//| Verifica se existe o arquivo de fechamento do mes informado  |
If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, @dDataRef , NIL ,lTerminal )
	Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
Endif

//³ Selecionando a Ordem de impressao escolhida no parametro.    ³
dbSelectArea( "SRA")
dbSetOrder(1)
dbGoTop()

//³ Selecionando o Primeiro Registro e montando Filtro.          ³
cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
dbSeek(cFilDe + cMatDe,.T.)
cFim    := cFilAte + cMatAte

dbSelectArea("SRA")
//³ Carrega Regua Processamento                                  ³
SetRegua(RecCount())	// Total de elementos da regua

TOTVENC:= TOTDESC:= FLAG:= CHAVE := 0

Desc_Fil := Desc_End := DESC_CC:= DESC_FUNC:= ""
Desc_Comp:= Desc_Est := Desc_Cid:= ""
DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space(01)
cFilialAnt := "  "
Vez        := 0
OrdemZ     := 0

While SRA->( !Eof() .And. &cInicio <= cFim )
	//³ Movimenta Regua Processamento                                ³
	IncRegua()  // Anda a regua

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif

	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	If (SRA->RA_CHAPA < ChapaDe) .Or. (SRA->Ra_CHAPa > ChapaAte) .Or. ;
		(SRA->RA_NOME < cNomDe)    .Or. (SRA->Ra_NOME > cNomAte)    .Or. ;
		(SRA->RA_MAT < cMatDe)     .Or. (SRA->Ra_MAT > cMatAte)     .Or. ;
		(SRA->RA_CC < cCcDe)       .Or. (SRA->Ra_CC > cCcAte)
		SRA->(dbSkip(1))
		Loop
	EndIf

	aLanca:={}         // Zera Lancamentos
	aProve:={}         // Zera Lancamentos
	aDesco:={}         // Zera Lancamentos
	aBases:={}         // Zera Lancamentos
	nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00

	Ordem_rel := 1     // Ordem dos Recibos

	//³ Verifica Data Demissao         ³
	cSitFunc := SRA->RA_SITFOLH
	dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")
	If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
		cSitFunc := " "
	Endif

	//³ Consiste situacao e categoria dos funcionarios			     |
	If !( cSitFunc $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )
		dbSkip()
		Loop
	Endif
	If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
		dbSkip()
		Loop
	Endif

	//³ Consiste controle de acessos e filiais validas				 |
	If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
		dbSkip()
		Loop
	EndIf

	If SRA->RA_FILIAL # cFilialAnt
		If ! Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. ! fInfo(@aInfo,Sra->Ra_Filial)
			Exit
		Endif
		Desc_Fil := aInfo[3]
		Desc_End := Alltrim(aInfo[4])                // Dados da Filial
		Desc_CGC := "CNPJ: " + Transform(aInfo[8], "@R 99.999.999/9999-99") //CGC aInfo[8]
		Desc_IE :=  "I.E.: " + Transform(ainfo[9], "@R 999.999.999.999") // IE
		DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space(01)
		Desc_Est := Alltrim(Substr(fDesc("SX5","12"+aInfo[6],"X5DESCRI()"),1,12))
		Desc_Comp:= Alltrim(aInfo[14])        			// Complemento Cobranca
		Desc_Cid := Alltrim(aInfo[05])
		Desc_CEP := "CEP: " + Transform(ainfo[7], "@R 99999-999") // CEP 
		Desc_Bairro := Alltrim(aInfo[13])

		// MENSAGENS
		If MENSAG1 # SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG1)
				DESC_MSG1 := Left(SRX->RX_TXT,30)
			ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG1)
				DESC_MSG1 := Left(SRX->RX_TXT,30)
			Endif
		Endif

		If MENSAG2 # SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG2)
				DESC_MSG2 := Left(SRX->RX_TXT,30)
			ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG2)
				DESC_MSG2 := Left(SRX->RX_TXT,30)
			Endif
		Endif

		If MENSAG3 # SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG3)
				DESC_MSG3 := Left(SRX->RX_TXT,30)
			ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG3)
				DESC_MSG3 := Left(SRX->RX_TXT,30)
			Endif
		Endif
		dbSelectArea("SRA")
		cFilialAnt := SRA->RA_FILIAL
	Endif

	Totvenc := Totdesc := 0

	If Esc == 1 .OR. Esc == 2
		dbSelectArea("SRC")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
				If SRC->RC_SEMANA # Semana
					dbSkip()
					Loop
				Endif
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
				If (Esc == 1) .And. (Src->Rc_Pd == aCodFol[7,1])      // Desconto de Adto
					fSomaPdRec("P",aCodFol[6,1],Eval(cNroHoras),SRC->RC_VALOR)
					TOTVENC += Src->Rc_Valor
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[12,1])
					fSomaPdRec("D",aCodFol[9,1],Eval(cNroHoras),SRC->RC_VALOR)
					TOTDESC += SRC->RC_VALOR
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[8,1])
					fSomaPdRec("P",aCodFol[8,1],Eval(cNroHoras),SRC->RC_VALOR)
					TOTVENC += SRC->RC_VALOR
				Else
					If PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
							If cPaisLoc == "PAR" .and. Eval(cNroHoras) == 30
								LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataRef),4)), Ctod(StrZero(F_ULTDIA(dDataRef),2)+"/"+Strzero(Month(dDataRef),2)+"/"+right(str(Year(dDataRef)),2),"ddmmyy"),@nHoras)
							Else
								nHoras := Eval(cNroHoras)
							Endif
							fSomaPdRec("P",SRC->RC_PD,nHoras,SRC->RC_VALOR)
							TOTVENC += Src->Rc_Valor
						Endif
					Elseif SRV->RV_TIPOCOD == "2"
						If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
							fSomaPdRec("D",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
							TOTDESC += Src->Rc_Valor
						Endif
					Elseif SRV->RV_TIPOCOD == "3"
						If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
							fSomaPdRec("B",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
						Endif
					Endif
				Endif
				If ESC = 1
					If SRC->RC_PD == aCodFol[10,1]
						nBaseIr := SRC->RC_VALOR
					Endif
				ElseIf SRC->RC_PD == aCodFol[13,1]
					nAteLim += SRC->RC_VALOR
				Elseif SRC->RC_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]
					nBaseFgts += SRC->RC_VALOR
				Elseif SRC->RC_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]
					nFgts += SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[15,1]
					nBaseIr += SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[16,1]
					nBaseIrFe += SRC->RC_VALOR
				Endif
				dbSelectArea("SRC")
				dbSkip()
			Enddo
		Endif
	Elseif Esc == 3 .And. !(cPaisLoc $ "URU|ARG")
		//³ Busca os codigos de pensao definidos no cadastro beneficiario³
		fBusCadBenef(@aCodBenef, "131",{aCodfol[172,1]})
		dbSelectArea("SRC")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
				If SRC->RC_PD == aCodFol[22,1]
					fSomaPdRec("P",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
					TOTVENC += SRC->RC_VALOR
				Elseif Ascan(aCodBenef, { |x| x[1] == SRC->RC_PD }) > 0
					fSomaPdRec("D",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
					TOTDESC += SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[108,1] .Or. SRC->RC_PD == aCodFol[109,1] .Or. SRC->RC_PD == aCodFol[173,1]
					fSomaPdRec("B",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR)
				Endif

				If SRC->RC_PD == aCodFol[108,1]
					nBaseFgts := SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[109,1]
					nFgts     := SRC->RC_VALOR
				Endif
				dbSelectArea("SRC")
				dbSkip()
			Enddo
		Endif
	Elseif Esc == 4 .or. If(cPaisLoc $ "URU|ARG", Esc ==3,.F.)
		dbSelectArea("SRI")
		dbSetOrder(2)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT)
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRI->RI_FILIAL + SRI->RI_CC + SRI->RI_MAT
				If !Eval(cAcessaSRI)
					dbSkip()
					Loop
				EndIf
				If PosSrv( SRI->RI_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					fSomaPdRec("P",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
					TOTVENC = TOTVENC + SRI->RI_VALOR
				Elseif SRV->RV_TIPOCOD == "2"
					fSomaPdRec("D",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
					TOTDESC = TOTDESC + SRI->RI_VALOR
				Elseif SRV->RV_TIPOCOD == "3"
					fSomaPdRec("B",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
				Endif

				If SRI->RI_PD == aCodFol[19,1]
					nAteLim += SRI->RI_VALOR
				Elseif SRI->RI_PD$ aCodFol[108,1]
					nBaseFgts += SRI->RI_VALOR
				Elseif SRI->RI_PD$ aCodFol[109,1]
					nFgts += SRI->RI_VALOR
				Elseif SRI->RI_PD == aCodFol[27,1]
					nBaseIr += SRI->RI_VALOR
				Endif
				dbSkip()
			Enddo
		Endif
	Elseif Esc == 5
		dbSelectArea("SR1")
		dbSetOrder(1)
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
				If Semana # "99"
					If SR1->R1_SEMANA # Semana
						dbSkip()
						Loop
					Endif
				Endif
				If !Eval(cAcessaSR1)
					dbSkip()
					Loop
				EndIf
				If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					fSomaPdRec("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					TOTVENC = TOTVENC + SR1->R1_VALOR
				Elseif SRV->RV_TIPOCOD == "2"
					fSomaPdRec("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					TOTDESC = TOTDESC + SR1->R1_VALOR
				Elseif SRV->RV_TIPOCOD == "3"
					fSomaPdRec("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
				Endif
				dbskip()
			Enddo
		Endif
	Endif

	dbSelectArea("SRA")

	If TOTVENC = 0 .And. TOTDESC = 0
		dbSkip()
		Loop
	Endif

	If Vez == 0  .And.  Esc == 2 //--> Verifica se for FOLHA.
		PerSemana() // Carrega Datas referentes a Semana.
	EndIf

	If nTipRel == 1 .and. !( lTerminal )
		fImpressao()   // Impressao do Recibo de Pagamento
		 IF !( lTerminal )
			If Vez = 0  .and. nTipRel # 3  .and. aReturn[5] # 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Descarrega teste de impressao                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fImpTeste(cString)
				If !lRetCanc
					Exit
				Endif
				TotDesc := TotVenc := 0
				If mv_par01 = 2
					Loop
				Endif
				
			ENDIF
		EndIF 
	ElseIf nTipRel == 2 .and. !( lTerminal )
		For nX := 1 to If(cPaisLoc <> "ARG",2,2)
			// Salta linha e espaço para cortar 
			if nx == 2 
				Li += 2 
				@ LI,00 PSAY "*"+REPLICATE("-",130)+"*"
				Li += 2 
			EndIf
			fImpreZebr()
		Next nX          

		ASize(AProve,0)
		ASize(ADesco,0)
		ASize(aBases,0)
	ElseIf nTipRel == 3 .or. lTerminal
		cHtml := fSendDPgto(lTerminal)   //Monta o corpo do e-mail e envia-o
	ElseIf nTipRel == 4
		For nx := 1 to nDuas // quantas vezes será impresso o mesmo funcionário

			cArquivo := "P_"+_cNomArq+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_"+;
								AllTrim(SRA->RA_MAT)+"_"+cNomeEmp+"-PAYSLIP.PDF"

			_oPrint   := FWMSPrinter():New(cArquivo, IMP_PDF, lAdjustToLegacy, cPasta, lDisableSetup, , , , , , , .F., , .F. )

			fImpGrf() // Imprime Holerit Grafico                                     
		Next
	Endif
	_oPrint:EndPage()     // Finaliza a página
	_oPrint:SetPortrait(.T.)
	_oPrint:SetPortrait()//Retrato
	_oPrint:SetPaperSize(9) // DMPAPER_A4
	_oPrint:cPathPDF := AllTrim(cPasta)

	_oPrint:Print()
	FreeObj(_oPrint)
	_oPrint := Nil

	cFolderGS := "C:\Program Files (x86)\GPLGS\"
	cRoot := GetSrvProfString("rootpath","")
	//If !File(cFolderGS+"gsdll64.dll") .or.;
	//	!File(cFolderGS+"gsdll64.lib") .or.;
	//	!File(cFolderGS+"gswin64c.exe")
		//Conversão para PDF 1.4
		cCMD := cFolderGS+'gswin64c.exe -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -o "'+cRoot+cPasta+'1.4'+cArquivo+'" "'+cRoot+cPasta+cArquivo+'"'
		WaitRunSrv(cCMD, .T., cFolderGS )
		
		Sleep(1000)
		
		//Apaga o arquivo da versão anterior
		FErase(cPasta+cArquivo)
	
		//Renomeia o arquivo para retirar a versão do nome
		FRename(cPasta+"1.4"+cArquivo,cPasta+cArquivo)
	//EndIf                                        	

	//Copia o arquivo para o terminal client.
	CpyS2T(cPasta+cArquivo, cPath,.F.)

	//Apaga o arquivo no server.
	FErase(cPasta+cArquivo)

	//ECR - 27/08/2015 - Altera o nome do arquivo para maisculo.
	//ShellExecute("Open","C:\Windows\System32\cmd.exe", ' /C "REN '+AllTrim(cPasta)+Lower(cArquivo)+ ' ' + Upper(cArquivo)+'" ', "C:\", 0 )
	//ShellExecute("Open","C:\Windows\System32\cmd.exe", ' /C REN "'+cPasta+Lower(cArquivo)+ '" "' + Upper(cArquivo)+'" ', "C:\", 0 )
	ShellExecute("Open","C:\Windows\System32\cmd.exe", ' /C REN "'+cPath+Lower(cArquivo)+ '" "' + Upper(cArquivo)+'" ', "C:\", 0 )

	dbSelectArea("SRA")
	SRA->( dbSkip() )
	TOTDESC := TOTVENC := 0
EndDo

//³ Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      ³
If !Empty( cAliasMov )
	fFimArqMov( cAliasMov , aOrdBag , cArqMov )
EndIf
//RRP - 30/06/2016 - Ajuste para compactar o arquivo dependendo do programa executado
If nTipRel == 4 .and. !lfirst
	cArqZip := "P_"+_cNomArq+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_XZIP_NOE_"+cNomeEmp+"-PAYSLIP.ZIP"
	// compacta os relatórios
	cPrZip	:= "winrar"
	cLocalZIP := "C:\Program Files (x86)\WinRar\rar.exe"
	If !File(cLocalZIP)                                                
   		cLocalZIP := "C:\Program Files\WinRAR\Rar.exe"
   		If !File(cLocalZIP)
	   		cLocalZIP	:= "C:\Program Files\7-Zip\7zG.exe"   
	   		cPrZip		:= "7zip"                                                                            
   			If !File(cLocalZIP)
	   			cLocalZIP := "C:\Program Files (x86)\7-Zip\7zG.exe" 
   		   		If !File(cLocalZIP)
   					cLocalZIP	:= ""
   					cPrZip		:= ""
   					MsgInfo("Não foi possível compactar os arquivos do relatório PaySlip. Entrar em contato com o Suporte(instalação ZIP).","Atenção")
   				EndIf
   			EndIf	
  		EndIf
	EndIf
	If !EMPTY(cLocalZIP)
		If cPrZip == "winrar"
	   		ShellExecute("Open",cLocalZIP,'a -inul -df -c- "'+cPath+cArqZip+'" "P_'+_cNomArq+'_'+AllTrim(cLID)+'_'+_cPer1ini+'_'+_cPer1fin+'*.pdf"',cPath,1)
	 	ElseIf cPrZip == "7zip"
	   		ShellExecute("Open",cLocalZIP,"a -tzip -sdel "   +cPath+cArqZip+"   P_"+_cNomArq+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"*.pdf",cPath,1)
	 	EndIf
	EndIf
EndIf

IF !( lTerminal ) .and. nTipRel <> 4
	//Termino do relatorio
	dbSelectArea("SRC")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRI")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRA")
	SET FILTER TO
	RetIndex("SRA")

	If !(Type("cArqNtx") == "U")
		fErase(cArqNtx + OrdBagExt())
	Endif

	Set Device To Screen

	If lEnvioOK
		APMSGINFO(STR0042)
	ElseIf nTipRel== 3
		APMSGINFO(STR0043)
	EndIf
	SeTPgEject(.F.)
	nlin:= 0	
	MS_FLUSH()
EndIF

Return( cHtml )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PerSemana³ Autor ³ R.H. - Mauro          ³ Data ³ 24.09.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa datas referentes a semana                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-------------------------*
Static Function PerSemana() 
*-------------------------*
Local cChaveSem	:= ""

dbSelectArea( "RCF" )

If !Empty(Semana)
	cChaveSem := StrZero(Year(dDataRef),4)+StrZero(Month(dDataRef),2)+SRA->RA_TNOTRAB
	If !dbSeek(xFilial("RCF") + cChaveSem + Semana, .T. )
		cChaveSem := StrZero(Year(dDataRef),4)+StrZero(Month(dDataRef),2)+"   "
		If !dbSeek(xFilial("RCF") + cChaveSem + Semana  )
			HELP( " ",1,"GPCALEND",  )						//--Nao existe periodo cadastrado
			Return(NIL)
		Endif
	Endif
	cSem_De  := DtoC(RCF->RCF_DTINI,'DDMMYY')
	cSem_Ate := DtoC(RCF->RCF_DTFIM,'DDMMYY')
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSomaPdRec³ Autor ³ R.H. - Mauro          ³ Data ³ 24.09.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Somar as Verbas no Array                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSomaPdRec(Tipo,Verba,Horas,Valor)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-------------------------------------------------*
Static Function fSomaPdRec(cTipo,cPd,nHoras,nValor)
*-------------------------------------------------*
Local Desc_paga

cCodemp := upper(ALLTRIM(SM0->M0_CODIGO))

if UPPER(cCodemp) = "NX"
	Desc_paga := U_DescVb(cPd,Sra->Ra_Filial)  
else
	Desc_paga := DescPd(cPd,Sra->Ra_Filial)  
endif

If cTipo # 'B'
	//--Array para Recibo Pre-Impresso
	nPos := Ascan(aLanca,{ |X| X[2] = cPd })
	If nPos == 0
		Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor})
	Else
		aLanca[nPos,4] += nHoras
		aLanca[nPos,5] += nValor
	Endif
Endif

//--Array para o Recibo Pre-Impresso
If cTipo = 'P'
	cArray := "aProve"
Elseif cTipo = 'D'
	cArray := "aDesco"
Elseif cTipo = 'B'
	cArray := "aBases"
Endif

nPos := Ascan(&cArray,{ |X| X[1] = cPd })
If nPos == 0
	Aadd(&cArray,{cPd+" "+Desc_Paga,nHoras,nValor })
Else
	&cArray[nPos,2] += nHoras
	&cArray[nPos,3] += nValor
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpTeste ºAutor  ³R.H. - Natie        º Data ³  11/29/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Testa impressao de Formulario Teste                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                 
*-----------------------------------------*
Static function fImpTeste(cString,nTipoRel)
*-----------------------------------------*
//--Comando para nao saltar folha apos o MsFlush.
SetPgEject(.F.)

@ PROW(),PCOL() PSAY ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descarrega teste de impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MS_Flush()
fInicia(cString,nTipoRel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Li com a a linha de impressão correten para não saltar linhas no teste  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li := _Prow()

If nTipoRel == 2
	@ LI,00 PSAY AvalImp(Limite)
Endif

lRetCanc	:= Pergunte("GPR30A",.T.)
Vez := If(mv_par01 = 1,1,0)

Return Vez

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fInicia   ºAutor  ³Natie               º Data ³  04/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa parametros para impressao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                       
*---------------------------------------*
Static Function fInicia(cString,nTipoRel)
*---------------------------------------*
If LastKey() = 27 .Or. nLastKey = 27
	Return  .F.
Endif

Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fMontaDtTcf 	³Autor³Ricardo Duarte     ³ Data ³13/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna a data valida para a consulta do Terminal Consulta  ³
³          ³do Funcionario                                         		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³cHtml  														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso	   ³GPER030       										    	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
*----------------------------------*
Static Function fMontaDtTcf(cMesAno)
*----------------------------------*
Local dDataValida
Local nDia := getmv("MV_TCFDFOL")

dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+"01")
dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+strzero(f_UltDia(dDataValida),2))+5 //nDia

return(dDataValida)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpGrf   ³ Autor ³ Lúcia Valéria         ³ Data ³ 27.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMRESSAO DO RECIBO FORMULARIO Grafico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpGrf()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------*
Static Function fImpGrf()
*-----------------------*
Local nConta  := 0
Local nContr  := 0
Local nContrT := 0
nLinhas       := 16         // Numero de Linhas do Miolo do Recibo

If lFirst 
		_oPrint:SetPortrait() // ou SetLandscape()
		lFirst  := .f.
endIf

If _cont >= 2500
		_oPrint:EndPage()     // Finaliza a página
		_cont:= 0
		_oPrint:StartPage()   // Inicia uma nova página
Endif
	
// Imprime Cabecalho                         

fCabecGrf()
nLin := 1030
	
For nConta = 1 To Len(aLanca)
	fLanGrf(nConta)
	nContr ++
	nContrT ++
	If nContr = nLinhas .And. nContrT < Len(aLanca)
		nContr:=0
		_oPrint:Say(_cont+1500, 0600," *** CONTINUA *** ",_oFont14) 
		_cont := 50
		fCabecGrf()
		nLin := 1030
	Endif
Next nConta
	
// Imprime o rodapé 
fRodaGrf()
//_cont += 1730

If _cont  > 2300 
	_oPrint:EndPage()     // Finaliza a página
EndIf
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCabecGrf ³ Autor ³ Lúcia Valéria         ³ Data ³ 27.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabecGrf()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Função para impressão do Cabeçalho                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-------------------------*
Static Function fCabecGrf()
*-------------------------*
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
Local cMatEmpGT		:= ""

_oPrint:SetPortrait() // ou SetLandscape()
_oPrint:StartPage()   // Inicia uma nova página
_cont:= 0

// calcula total de recibos
_ntotrec := int(len(aLanca)/nLinhas)  
If _ntotrec = 0
	_ntotrec++	
Else
	If (_ntotrec * nLinhas) <> Len(aLanca) 
		_ntotrec++	
	Endif
Endif

//³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc)

//Cabeçalho do holerite dados da empresa
_cont+=50                                                    //Margem Para Cabecalho

//Controle de numeracao de paginas
_oPrint:Say(_cont+010, 2000, strzero(_nnumrec,2)+"/"+strzero(_ntotrec,2), _oFont10) //Numero de pagina  

// Dados da Empresa
_oPrint:Say(_cont+0100, 0100,"Sender", _oFont8)
_oPrint:Say(_cont+0150, 0150,Desc_Fil, _oFont10b)

    // Dados do funcionario 
_oPrint:Say(_cont+0250, 0100,"Recipient", _oFont8)
_oPrint:Say(_cont+0300, 0150,SRA->RA_NOME, _oFont10b)
_oPrint:Say(_cont+0340, 0150,RTRIM(SRA->RA_ENDEREC)+", "+RTRIM(SRA->RA_NUMENDE)+" "+;
								IIF(EMPTY(SRA->RA_COMPLEM),"",RTRIM(SRA->RA_COMPLEM))+" "+RTRIM(SRA->RA_BAIRRO), _oFont10b)
_oPrint:Say(_cont+0380, 0150,SUBS(SRA->RA_CEP,1,5)+"-"+SUBS(SRA->RA_CEP,6,3), _oFont10b)
_oPrint:Say(_cont+0420, 0150,RTRIM(SRA->RA_MUNICIP)+" - "+SRA->RA_ESTADO, _oFont10b)

//Box Superior 
_oPrint:Box(_cont+0050, 1201, _cont+0950, 2300)

//Linhas Horizontais
_oPrint:Line(_cont+0200, 1201, _cont+0200, 2300)
_oPrint:Line(_cont+0350, 1201, _cont+0350, 2300)
_oPrint:Line(_cont+0500, 1568, _cont+0500, 2300)
_oPrint:Line(_cont+0650, 1201, _cont+0650, 2300)
_oPrint:Line(_cont+0800, 1201, _cont+0800, 2300)

//Linhas Verticais
_oPrint:Line(_cont+0050, 1568, _cont+0950, 1568)
_oPrint:Line(_cont+0050, 1935, _cont+0200, 1935)
_oPrint:Line(_cont+0650, 1935, _cont+0950, 1935)

//Textos Fixos
_oPrint:Say(_cont+0080, 1211,"Pay period", _oFont8)
_oPrint:Say(_cont+0080, 1578,"Period", _oFont8)
_oPrint:Say(_cont+0080, 1945,"Employment", _oFont8)
    
_oPrint:Say(_cont+0230, 1211,"Person", _oFont8)
_oPrint:Say(_cont+0230, 1578,"Wg/Cc", _oFont8)

_oPrint:Say(_cont+0380, 1211,"Tax card", _oFont8)
_oPrint:Say(_cont+0380, 1578,"Identity number", _oFont8)

//_oPrint:Say(_cont+0490, 1598,"Accountant", _oFont10)
_oPrint:Say(_cont+0530, 1578,"Cumulative tax information", _oFont8)

//Box No Meio 
_oPrint:Box(_cont+0950, 0100, _cont+1700, 2300)

//Linhas Verticais
_oPrint:Line(_cont+0950, 1201, _cont+1700, 1201)
_oPrint:Line(_cont+0950, 1568, _cont+1700, 1568)
_oPrint:Line(_cont+0950, 1935, _cont+1700, 1935)

//Textos Fixos
_oPrint:Say(_cont+0980, 0110,"Form of wages", _oFont8)
_oPrint:Say(_cont+0980, 1211,"Time/Units", _oFont8)
_oPrint:Say(_cont+0980, 1578,"A-rate", _oFont8)
_oPrint:Say(_cont+0980, 1945,"BRL", _oFont8)

// Box Inferior 
_oPrint:Box(_cont+1700, 0100, _cont+2900, 2300)

//Linhas Horizontais
_oPrint:Line(_cont+1850, 0100, _cont+1850, 2300)
_oPrint:Line(_cont+2000, 0100, _cont+2000, 2300)
_oPrint:Line(_cont+2150, 0100, _cont+2150, 2300)
_oPrint:Line(_cont+2300, 0100, _cont+2300, 2300)
_oPrint:Line(_cont+2450, 0100, _cont+2450, 2300)
_oPrint:Line(_cont+2600, 0100, _cont+2600, 2300)
_oPrint:Line(_cont+2750, 0100, _cont+2750, 2300)

//Linhas Verticais
_oPrint:Line(_cont+1700, 0467, _cont+2900, 0467)
_oPrint:Line(_cont+1700, 0834, _cont+2900, 0834)
_oPrint:Line(_cont+1700, 1201, _cont+2900, 1201)
_oPrint:Line(_cont+1700, 1568, _cont+2900, 1568)
_oPrint:Line(_cont+1700, 1935, _cont+2900, 1935)

//Textos Fixos
_oPrint:Say(_cont+1730, 0110,"Period", _oFont12b)
_oPrint:Say(_cont+1730, 0477,"Special payment incl wht", _oFont8)

_oPrint:Say(_cont+2030, 0110,"Wages in money", _oFont8)
_oPrint:Say(_cont+2030, 0477,"Taxable income", _oFont8)
_oPrint:Say(_cont+2030, 0844,"Total income", _oFont8)
_oPrint:Say(_cont+2030, 1211,"Taxes withheld", _oFont8)
_oPrint:Say(_cont+2030, 1578,"Deductions total", _oFont8)
_oPrint:Say(_cont+2030, 1945,"Payable", _oFont8)

_oPrint:Say(_cont+2220, 0110,"Beginning", _oFont12b)
_oPrint:Say(_cont+2260, 0110,"of the year", _oFont12b)
_oPrint:Say(_cont+2180, 0844,"Vacation bonus", _oFont8)
_oPrint:Say(_cont+2180, 1211,"Vacation compensation", _oFont8)

_oPrint:Say(_cont+2480, 1945,"Pension/unempl.deduction", _oFont8)

_oPrint:Say(_cont+2630, 0110,"Wages in money", _oFont8)
_oPrint:Say(_cont+2630, 0477,"Taxable income", _oFont8)
_oPrint:Say(_cont+2630, 0844,"Total income", _oFont8)
_oPrint:Say(_cont+2630, 1211,"Taxes withheld", _oFont8)
_oPrint:Say(_cont+2630, 1578,"Deductions total", _oFont8)

_oPrint:Say(_cont+2820, 0110,"Previous", _oFont12b)
_oPrint:Say(_cont+2860, 0110,"year", _oFont12b)
_oPrint:Say(_cont+2780, 0477,"Taxable income", _oFont8)
_oPrint:Say(_cont+2780, 0844,"Vacation bonus", _oFont8)

//Data Base de Pagamento
_oPrint:Say(_cont+0140, 1291,strzero(month(dDataRef),2)+"/"+str(YEAR(dDataRef),4)+"/"+strzero(day(dDataRef),2), _oFont10)
_oPrint:Say(_cont+0180, 1291,StrZero(F_ULTDIA(dDataRef),2)+"."+strzero(month(dDataRef),2)+"."+str(YEAR(dDataRef),4), _oFont10)

//Periodo
_oPrint:Say(_cont+0140, 1658,strzero(day(dDataRef),2)+"."+strzero(month(dDataRef),2)+"."+str(YEAR(dDataRef),4), _oFont10)
_oPrint:Say(_cont+0180, 1658,"--   "+StrZero(F_ULTDIA(dDataRef),2)+"."+strzero(month(dDataRef),2)+"."+str(YEAR(dDataRef),4), _oFont10)

//Employment
_oPrint:Say(_cont+0140, 2035,strzero(day(SRA->RA_ADMISSA),2)+"."+strzero(month(SRA->RA_ADMISSA),2)+"."+str(YEAR(SRA->RA_ADMISSA),4),_oFont10)
If Empty(SRA->RA_DEMISSA)
	_oPrint:Say(_cont+0180, 2035,"--   ", _oFont10)
Else
	_oPrint:Say(_cont+0180, 2035,"--   "+strzero(day(SRA->RA_DEMISSA),2)+"."+strzero(month(SRA->RA_DEMISSA),2)+"."+str(YEAR(SRA->RA_DEMISSA),4),_oFont10)
Endif

//Person 
//RSB - 09/01/2017  - Customizado
If SRA->(FieldPos("RA_P_CDEMP")) > 0 //EXISTCPO("SX3","RA_P_CDEMP",2)
	cMatEmpGT := SRA->RA_MAT +" / "+ posicione("SRA",1,xFilial("SRA") + SRA->RA_MAT,"RA_P_CDEMP")
Else	
	cMatEmpGT := SRA->RA_MAT
Endif
_oPrint:Say(_cont+0290, 1301, cMatEmpGT, _oFont10)  //codigo
_oPrint:Say(_cont+0290, 1638, Alltrim(SRA->RA_CC), _oFont10)  //cto Custo
if UPPER(cCodemp) = "NX"
	_oPrint:Say(_cont+0320, 1638, Alltrim(Posicione("CTT",1,xFilial("CTT") + SRA->RA_CC,"CTT_DESC02")), _oFont10)    //cto custo
else
_oPrint:Say(_cont+0320, 1638, Alltrim(Posicione("CTT",1,xFilial("CTT") + SRA->RA_CC,"CTT_DESC01")), _oFont10)//cto custo
endif

//Identity number e cargo
_oPrint:Say(_cont+0440, 1638, SRA->RA_CIC, _oFont10)  //CPF
_oPrint:Say(_cont+0470, 1638, cDescFunc, _oFont10) //funcao
//_oPrint:Say(_cont+0345,0235, Alltrim(cCodFunc) +" - "+ cDescFunc, _oFont8)//Campo Codigo da Funcao
//_oPrint:Say(_cont+0345,0650,"C.B.O.: "+Alltrim(Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_CODCBO")),_oFont8)//descricao da Funcao

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fLanGrf   ³ Autor ³ Lúcia Valéria         ³ Data ³ 27.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLanGrf()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Função para impressão do Detalhe                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------*
Static Function fLanGrf(nConta)
*-----------------------------*
Local	cString
Local   nValLanc
//Local 	nCol    := If(aLanca[nConta,1]="P",1600,If(aLanca[nConta,1]="D",2000,27))

nValLanc := 0

// transforma descontos em negativo
If aLanca[nConta,1]="D"
	nValLanc := aLanca[nConta,5] * -1
Else
	nValLanc := aLanca[nConta,5]
Endif 
cString := alltrim(Transform(nValLanc,cPict4))

// Textos Variaveis
_oPrint:Say(_cont+nLin, 0130, aLanca[nConta,2], _oFont10,,,,1) // cod verba 
_oPrint:Say(_cont+nLin, 0240, aLanca[nConta,3], _oFont10,,,,0) // desc verba

If aLanca[nConta,1] # "B"        // So Imprime se nao for base
	If aLanca[nConta,4] <= 9.99
		_oPrint:Say(_cont+nLin, 1420, TRANSFORM(aLanca[nConta,4],"@e 999.99"), _oFont10,,,,1)  // unidades 
	Endif
	If aLanca[nConta,4] <= 99.99 .and. aLanca[nConta,4] > 9.99
		_oPrint:Say(_cont+nLin, 1410, TRANSFORM(aLanca[nConta,4],"@e 999.99"), _oFont10,,,,1)  // unidades 
	Endif
	If aLanca[nConta,4] <= 999.99 .and. aLanca[nConta,4] > 99.99
		_oPrint:Say(_cont+nLin, 1400, TRANSFORM(aLanca[nConta,4],"@e 999.99"), _oFont10,,,,1)  // unidades 
	Endif
Endif

// alinha valores a direita
nCol := 490 + ((100-len(cString))*17.5)

_oPrint:Say(_cont+nLin, nCol+iif(nValLanc<0,10,0), cString, _oFont10)  // valores

nLin += 40

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fRodaGrf  ³ Autor ³ Lúcia Valéria         ³ Data ³ 27.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRodaGrf()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Função para impressão do Rodapé do Holerit                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*------------------------*
Static Function fRodaGrf()
*------------------------*
Local nValSal := 0
Local nPos := 0

//Impressao dos Totais Do campo Vencimentos
nPos := 1004 - LEN(ALLTRIM(STR(INT(TOTVENC)))) * 10
_oPrint:Say(_cont+2100, nPos,TRANSFORM(TOTVENC,cPict4), _oFont10)
	
//Impressao dos Totais Do campo Descontos
nPos := 1738 - LEN(ALLTRIM(STR(INT(TOTDESC)))) * 10                 
_oPrint:Say(_cont+2100, nPos,TRANSFORM(TOTDESC,cPict4), _oFont10)

//Impressao dos Totais do Campo Valor Liquido
nPos := 2105 - LEN(ALLTRIM(STR(INT((TOTVENC-TOTDESC))))) * 10                 
_oPrint:Say(_cont+2100, nPos,TRANSFORM((TOTVENC-TOTDESC),cPict4), _oFont10)
	
//Imprime Salario Base
If !Empty(cAliasMov)
	nValSal := fBuscaSal(dDataRef)
	If nValSal == 0
		nValSal := SRA->RA_SALARIO 
	EndIf
Else
	nValSal := SRA->RA_SALARIO 
EndIf
_oPrint:Say(_cont+2100, 0220, Transform(nValSal,cPict4) , _oFont10)

_oPrint:EndPage()     // Finaliza a página

Return()


User Function DescVb(cCodigo,cFil,nBytes)
	Local cAlias := Alias()
	Local nOrdem := IndexOrd()
	
	If nBytes = NIL
		nBytes := 20
	Endif
	If nBytes > 20
		nBytes := 20
	Endif
	
	dbSelectArea( "SRV" )
	dbSetOrder(1)
	If (cFil # Nil .And. Empty(cFilial)) .Or. cFil == Nil .Or. (cFil # Nil .And. Len(Alltrim(cFilial)) < FwGetTamFilial)
		cFil := cFilial
	Endif
	If dbSeek( cFil + cCodigo )
		cRet := Left(RV_XDESCIN+Space(nBytes),nBytes)
	Else
		cRet := Left(STR0010+Space(nBytes),nBytes)  //"** Nao Cadastrado **"
	Endif
	dbSelectArea( cAlias )
	dbSetOrder(nOrdem)
Return( cRet )







