#include "rwmake.ch"        
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
#INCLUDE "RECIBO.CH" 

/*
Funcao      : WGPP051
Parametros  : Nenhum
Retorno     : cBar
Objetivos   : Folha de Pagamento 
Autor    	: Customizado pela RASS CONSULTORIA para uso exclusio da PRYOR CONSULTING 
Data     	: 17/05/2010.
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Gestão de Pessoal.
*/ 

*-----------------------*
 User Function WGPP051()
*-----------------------*

LOCAL AAREASRV	:= SRV->(GETAREA())      
local _cTpVb	:= ""

SetPrvt("CBTXT,CSTRING,AORD,CDESC1,CDESC2,CDESC3")
SetPrvt("LEND,NLASTKEY,ALINHA,NOMEPROG,ARETURN")
SetPrvt("CPERG,NEXTRA,NATELIM,NBASEFGTS,NFGTS,NBASEIR,NBASEIRFE")
SetPrvt("CINDCOND,ALANCA,AINFO,ACODFOL,BASEAUX,CSEM_DE,CSEM_ATE,CDIAPGTO")
SetPrvt("NTOTREGS,NORDEM,ESC,SEMANA,FILIALDE,FILIALATE,CCDE,CCATE,MATDE")
SetPrvt("MATATE,NOMDE,NOMATE,CHAPADE,CHAPAATE,MENSAG1,MENSAG2,MENSAG3,CSITUACAO")
SetPrvt("CCATEGORIA,CBASEAUX,CDIAPAGTO,CARQNTX,CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1")
SetPrvt("CINICIO,CFIM,TOTVENC,TOTDESC,DESC_FIL,DESC_END,DESC_CID,DESC_UF,DESC_CEP")
SetPrvt("DESC_CC,DESC_MSG1,DESC_MSG2,DESC_MSG3,CFILIALANT,CFUNCAOANT,CCCANT")
SetPrvt("VEZ,ADESCO,ABASES,NPOS,DESC_CGC,CTIPO,CPD,NHORAS,NVALOR,nTamLin")
SetPrvt("NCONTA,CFILIAL,CCC,CDESCCC,CDET,CDESCBCO,CBCOAG,NLIQUIDO,CALIAS,CCHAVESEM")
SetPrvt("DESC_PAGA,xDesBasIR,xDesBasIN,xDesAniv,xDesFgts,xDesBasFg,aMes,nElem,xMesExt")
SetPrvt("LI,ADRIVER,CCOMPAC,CNORMAL,TAMANHO,LIMITE,NORDEM,NTIPREL")
SetPrvt("aFilial,xGTotProv,xGTotDesc,xGTotLiq")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Basicas Genericas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbTxt     := ""
cString   := "SRA" 
aOrd      := {"Matricula","C.Custo","Nome","Chapa","C.Custo + Nome"}
cDesc1    := "Geracao de Recibos de Pagamento em Arquivo Texto"
cDesc2    := "Sera' impresso de acordo com os parametros solicitados pelo"
cDesc3    := "usuario."
nLastKey  := 0
aLinha    := {}
aFilial   := {}
xGTotProv := 0
xGTotDesc := 0
xGTotLiq  := 0
lEnd      := .F.
mVAR      := SPACE(40)
nLastKey  := 0
cPerg     := "WGPP50"
nomeprog  := "WGPP050"
aReturn   := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }       
nExtra    := 0
nAteLim   := 0
nBaseFgts := 0
nFgts     := 0
nBaseIr   := 0
nBaseIrFe := 0
Li        := 0
cIndCond  := ""
aLanca    := {}
aInfo     := {}
aCodFol   := {}
Baseaux   := "S"
cDemit    := "N"
cSem_De   := "  /  /  "
cSem_Ate  := "  /  /  "
cDiaPgto  := "01/02"
Titulo    := "GERACAO DE RECIBOS DE PAGAMENTOS EM ARQUIVO TEXTO"

ajustasx1()

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WnRel := "WGPP050" 
WnRel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

dbSelectArea("SX1")
dbSetOrder(1)
dbSeek(cPERG+"22")
RecLock("SX1",.F.)
SX1->X1_CNT01 := SPACE(60)
MsUnlock()

If nLastKey == 27
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return Nil
Endif

#IFDEF WINDOWS
	RptStatus({|| fRC_Imp()})  //-- Chamada do Relatorio.
	Return Nil
Static Function fRC_Imp()
#ENDIF

nTotregs := 0 //-- Regua.
nMult    := 0
nPosAnt  := 0
nPosAtu  := 0
nPosCnt  := 0
cSav20   := ""
cSav7    := ""
Tamanho  := "P"
Limite   := 80

nOrdem    := aReturn[8]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Emitir Recibos(Adto/Folha/1¦/2¦)         ³
//³ mv_par02        //  Numero da Semana                         ³
//³ mv_par03        //  Filial De                                ³
//³ mv_par04        //  Filial Ate                               ³
//³ mv_par05        //  Centro de Custo De                       ³
//³ mv_par06        //  Centro de Custo Ate                      ³
//³ mv_par07        //  Matricula De                             ³
//³ mv_par08        //  Matricula Ate                            ³
//³ mv_par09        //  Nome De                                  ³
//³ mv_par10        //  Nome Ate                                 ³
//³ mv_par11        //  Chapa De                                 ³
//³ mv_par12        //  Chapa Ate                                ³
//³ mv_par13        //  Mensagem 1                               ³
//³ mv_par14        //  Mensagem 2                               ³
//³ mv_par15        //  Mensagem 3                               ³
//³ mv_par16        //  Situacoes a Imprimir                     ³
//³ mv_par17        //  Categorias a Imprimir                    ³
//³ mv_par18        //  Imprimir Bases                           ³
//³ mv_par19        //  Dias/Mes Pagamento                       ³
//³ mv_par20        //  Caminho do Arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Esc       := mv_par01
Semana    := mv_par02
FilialDe  := mv_par03
FilialAte := mv_par04
CcDe      := mv_par05
CcAte     := mv_par06
MatDe     := mv_par07
MatAte    := mv_par08
NomDe     := mv_par09
NomAte    := mv_par10
ChapaDe   := mv_par11
ChapaAte  := mv_par12
Mensag1   := mv_par13
Mensag2   := mv_par14
Mensag3   := mv_par15
cSituacao := mv_par16
cCategoria:= mv_par17
cBaseAux  := If(mv_par18 == 1,"S","N")
cDiaPagto := mv_par19
mVar      := mv_par20

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando a Ordem de impressao escolhida no parametro.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SRA')
If nOrdem == 1
	dbSetOrder(1)
ElseIf nOrdem == 2
	dbSetOrder(2)
ElseIf nOrdem == 3
	dbSetOrder(3)
Elseif nOrdem == 4
	cArqNtx  := CriaTrab(NIL,.f.)
	cIndCond := 'RA_Filial + RA_Chapa + RA_Mat'
	IndRegua('SRA',cArqNtx,cIndCond,,,"Selecionando Registros...")
ElseIf nOrdem == 5
	dbSetOrder(8)
Endif
dbGoTop()


if Esc==1
   cDescFol := "ADTO. MENSAL"
elseif Esc==2
   cDescFol := "FOLHA MENSAL"
elseif Esc==3
   cDescFol := "ADTO.13o.SAL."
elseif Esc==4
   cDescFol := "13o.SALARIO"
elseif Esc==5
   cDescFol := "PART.RESULT."
endif


// Seta posicao para 0,0
SetPrc(0,0)

If nTipRel == 2
	aDriver   := LEDriver()
	cCompac := aDriver[1]
	cNormal := aDriver[2]
	@ 00,00 PSAY &cCompac
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount()) //-- Total de elementos da regua.

Private cArqTxt := ALLTRIM(mVAR)+"CONDUCTO.TXT"
Private nHdl    := fCreate(cArqTxt)
Private cEOL    := "CHR(13)+CHR(10)"
If Empty(cEOL)
    cEOL := CHR(13)+CHR(10)
Else
    cEOL := Trim(cEOL)
    cEOL := &cEOL
Endif

If nHdl == -1
    MsgAlert("O Caminho "+ALLTRIM(mVAR)+" nao pode ser executado! Verifique os parametros.","Atencao!")
    Return
Endif

aMes    := {"JANEIRO  ","FEVEREIRO","MARCO   ","ABRIL    ","MAIO     ","JUNHO    ","JULHO    ","AGOSTO   ","SETEMBRO ","OUTUBRO ","NOVEMBRO ","DEZEMBRO "}
nElem   := VAL(SUBSTR(DTOS(dDataBase),5,2))
xMesExt := aMes[nElem]

// Grava o registro Header referente a empresa
nTamLin := 171
cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
cCpo    := "0"
cLin    := Stuff(cLin,01,01,cCpo)
cCpo    := PADR(SM0->M0_NOMECOM,30)
cLin    := Stuff(cLin,02,30,cCpo)
cCpo    := PADR(SM0->M0_CODFIL,2)
cLin    := Stuff(cLin,42,2,cCpo)
cCpo    := PADR(SM0->M0_CGC,14)
cLin    := Stuff(cLin,44,14,cCpo)
cCpo    := PADR(xMesExt+"/"+SUBSTR(DTOS(dDataBase),1,4),14)
cLin    := Stuff(cLin,58,14,cCpo)
cCpo    := PADR(SUBSTR(cDescFol,1,20),20)
cLin    := Stuff(cLin,72,20,cCpo)
cCpo    := PADR(cDiaPagto+"/"+SUBSTR(DTOS(dDataBase),1,4),10)   // linha incluida em 8/3/02
cLin    := Stuff(cLin,92,10,cCpo)         // linha incluida em 8/3/02
   
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
   If !MsgAlert("Ocorreu um erro na gravacao do arquivo.") 
    Return
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Processa({|| RunCont() },"Processando...")
Return

Static Function RunCont

Local cLin, cCpo
Local aSrc := {}
Local nCnt := 0 // contador // jj em 21/05/2010

nTotregs := 0 //-- Regua.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando o Primeiro Registro e montando Filtro.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	dbSeek(FilialDe + MatDe,.T.)
	cInicio := 'SRA->RA_FILIAL + SRA->RA_MAT'
	cFim    := FilialAte + MatAte
ElseIf nOrdem == 2
	dbSeek(FilialDe + CcDe + MatDe,.T.)
	cInicio  := 'SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT'
	cFim     := FilialAte + CcAte + MatAte
ElseIf nOrdem == 3
	dbSeek(FilialDe + NomDe + MatDe,.T.)
	cInicio := 'SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT'
	cFim    := FilialAte + NomAte + MatAte
ElseIf nOrdem == 4
	dbSeek(FilialDe + ChapaDe + MatDe,.T.)
	cInicio := 'SRA->RA_FILIAL + SRA->RA_CHAPA + SRA->RA_MAT'
	cFim    := FilialAte + ChapaAte + MatAte
ElseIf nOrdem == 5
	dbSeek(FilialDe + CcDe + NomDe,.T.)
	cInicio  := 'SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME'
	cFim     := FilialAte + CcAte + NomAte
Endif

TotVenc := 0
TotDesc := 0
Desc_Fil  := ''
Desc_End  := ''
Desc_Cid  := ''
Desc_UF   := ''
Desc_Cep  := ''
Desc_CC   := ''
Desc_Msg1 := Space(1)
Desc_Msg2 := Space(1)
Desc_Msg3 := Space(1)

cFilialAnt := Space(2)
cFuncaoAnt := Space(4)
cCcAnt     := Space(9)
Vez        := 0

dbSelectArea('SRA')
Do While !EOF() .And. &cInicio <= cFim

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua Processamento                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncRegua()  //-- Move a regua.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cancela ImpresÆo ao se pressionar <ALT> + <A>                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF WINDOWS
		Inkey()
		If Lastkey() == 286
			lEnd := .T.
		EndIf   
	#ENDIF
		
	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	EndIF                   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Geracao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_CHAPA < ChapaDe) .Or. (SRA->Ra_CHAPa > ChapaAte) .Or. ;
			(SRA->RA_NOME < NomDe)    .Or. (SRA->Ra_NOME > NomAte)    .Or. ;
			(SRA->RA_MAT < MatDe)     .Or. (SRA->Ra_MAT > MatAte)     .Or. ;
			(SRA->RA_CC < CcDe)       .Or. (SRA->Ra_CC > CcAte)
		SRA->(dbSkip(1))
		Loop
	EndIf

	aLanca := {} //-- Zera Lancamentos.
	aDesco := {}
	aBases := {}
	npos   := 0
	nAteLim   := 0.00
	nBaseFgts := 0.00
	nFgts     := 0.00
	nBaseIr   := 0.00
	nBaseIrFe := 0.00
	
	Ordem_rel := 1 //-- Ordem dos Recibos
	
	//-- Despreza registros conforme situacao e categoria dos funcionarios.
	If !( SRA->RA_SITFOLH $ cSituacao ) .Or.  !( SRA->RA_CATFUNC $ cCategoria )
		dbSkip()
		Loop
	Endif
	
	If SRA->RA_SITFOLH $'D' .And. Mesano(SRA->RA_DEMISSA) #Mesano(dDataBase)
		dbSkip()
		Loop
	Endif
	
	If SRA->RA_CODFUNC #cFuncaoAnt //-- Descricao da Funcao.
		DescFun(Sra->Ra_Codfunc,Sra->Ra_Filial)
		cFuncaoAnt := Sra->Ra_CodFunc
	Endif
	
	If SRA->RA_CC #cCcAnt //-- Centro de Custo.
		DescCC(Sra->Ra_Cc,Sra->Ra_Filial)
		cCcAnt := SRA->RA_CC
	Endif
	
	If SRA->RA_Filial #cFilialAnt
		If !Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. !fInfo(@aInfo,Sra->Ra_Filial)
			Exit
		Endif
		Desc_Fil := aInfo[3] //- Dados da Filial
		Desc_End := aInfo[4]
		Desc_Cid := aInfo[5]
		Desc_UF  := aInfo[6]
		Desc_Cep := aInfo[7]
		Desc_CGC := aInfo[8]
		
		DESC_MSG1:= Space(01) //-- Mensagens.
		DESC_MSG2:= Space(01)
		DESC_MSG3:= Space(01)
	 
		If MENSAG1 #SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,'06',SRA->RA_FILIAL+MENSAG1)
				DESC_MSG1 := Left(SRX->RX_TXT,60)
			ElseIf FPHIST82(SRA->RA_FILIAL,'06','  '+MENSAG1)
				DESC_MSG1 := Left(SRX->RX_TXT,60)
			Endif
		Endif
	 
		If MENSAG2 #SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,'06',SRA->RA_FILIAL+MENSAG2)
				DESC_MSG2 := Left(SRX->RX_TXT,60)
			ElseIf FPHIST82(SRA->RA_FILIAL,'06','  '+MENSAG2)
				DESC_MSG2 := Left(SRX->RX_TXT,60)
			Endif
		Endif
	 
		If MENSAG3 #SPACE(1)
			If FPHIST82(SRA->RA_FILIAL,'06',SRA->RA_FILIAL+MENSAG3)
				DESC_MSG3 := Left(SRX->RX_TXT,60)
			ElseIf FPHIST82(SRA->RA_FILIAL,'06','  '+MENSAG3)
				DESC_MSG3 := Left(SRX->RX_TXT,60)
			Endif
		Endif
		dbSelectArea('SRA')
		cFilialAnt := SRA->RA_FILIAL
	Endif

	TotVenc := 0
	TotDesc := 0

	If Esc == 1 .Or. Esc == 2
		FazSRC(@aSrc,Esc,aCodFol,Semana)
		dbSelectArea('SRC')
		//If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
		if Len(aSrc) > 0
			//Do While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
			For nCnt := 1 to Len(aSrc)
				SRC->(DBGOTO(aSrc[nCnt,3]))

				If SRC->RC_SEMANA #Semana
					//dbSkip()
					Loop
				Endif

				If (Esc == 1) .And. (Src->Rc_Pd == aCodFol[7,1]) //-- Desconto de Adto.
					//                                      
					cTipo  := 'P'
					cPD    := aCodFol[6,1]
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + Src->Rc_Valor
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[12,1])
					//
					cTipo  := 'D'
					cPD    := aCodFol[9,1]
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SRC->RC_VALOR
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[8,1])
					//
					cTipo  := 'P'
					cPD    := aCodFol[8,1]
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SRC->RC_VALOR
				Else
					_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRC->RC_PD,"RV_TIPOCOD")
					//If Src->Rc_Pd > ' .And. Src->Rc_Pd < '400'
					If _cTpVb = "1"
						If (Esc #1) .Or. (Esc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,'RV_ADIANTA') == 'S')
							//
							cTipo  := 'P'
							cPD    := SRC->RC_Pd
							nHoras := SRC->RC_Horas
							nValor := SRC->RC_Valor                                 
							fRC_SomaPD()
							//
							TotVenc := TotVenc + Src->Rc_Valor
						Endif
					//Elseif Src->Rc_Pd > '400' .And. Src->Rc_Pd < '700'
					ElseIf _cTpVb = "2"
						If (Esc #1) .Or. (Esc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,'RV_ADIANTA') == 'S')
							//
							cTipo  := 'D'
							cPD    := SRC->RC_Pd
							nHoras := SRC->RC_Horas
							nValor := SRC->RC_Valor
							fRC_SomaPD()
							//
							TotDesc := TotDesc + Src->Rc_Valor
						Endif
					//Elseif Src->Rc_Pd > '700'
					ElseIf _cTpVb = "3"
						If (Esc #1 .AND. SFPD1(SRC->RC_PD)) .Or. (Esc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,'RV_ADIANTA') == 'S') .AND. SFPD1(SRC->RC_PD)
							//
							cTipo  := 'B'
							cPD    := SFPD2(SRC->RC_Pd)
							nHoras := SRC->RC_Horas
							nValor := SRC->RC_Valor
							fRC_SomaPD()
							//
						Endif
					Endif
				Endif
				If ESC == 1
					If SRC->RC_PD == aCodFol[10,1]
						nBaseIr := SRC->RC_VALOR
					Endif
				ElseIf SRC->RC_PD == aCodFol[13,1]
					nAteLim := nAteLim + SRC->RC_VALOR
				Elseif SRC->RC_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]
					nBaseFgts := nBaseFgts + SRC->RC_VALOR
				Elseif SRC->RC_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]
					nFgts := nFgts + SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[15,1]
					nBaseIr := nBaseIr + SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[16,1]
					 nBaseIrFe := nBaseIrFe + SRC->RC_VALOR
				Endif
				//dbSelectArea('SRC')
				//dbSkip()
			//Enddo
			NEXT
		Endif
	Elseif Esc == 3
		FazSRC(@aSrc,Esc,aCodFol,Semana)
		dbSelectArea('SRC')
		//If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
		IF Len(aSrc) > 0
		     // Monta matriz com valores
			//While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
			For nCnt := 1 to Len(aSrc)
				SRC->(DBGOTO(aSrc[nCnt,3]))
				
				If SRC->RC_PD == aCodFol[22,1]
					//
					cTipo  := 'P'
					cPD    := SRC->RC_Pd
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[172,1]
					//
					cTipo  := 'D'
					cPD    := SRC->RC_Pd
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[108,1] .Or. SRC->RC_PD == aCodFol[109,1] .Or. SRC->RC_PD == aCodFol[173,1]
					//
					cTipo  := 'B'
					cPD    := SRC->RC_Pd
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
				Endif
				
				If SRC->RC_PD == aCodFol[108,1]
					nBaseFgts := SRC->RC_VALOR
				Elseif SRC->RC_PD == aCodFol[109,1]
					nFgts     := SRC->RC_VALOR
				Endif
				//dbSelectArea('SRC')
				//dbSkip()
			//Enddo
			Next
		Endif
	Elseif Esc == 4
		FazSRC(@aSrc,Esc,aCodFol,Semana)
		dbSelectArea('SRI')
		dbSetOrder(2)
		//If dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT)
		IF Len(aSrc) > 0
			//Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRI->RI_FILIAL + SRI->RI_CC + SRI->RI_MAT
			For nCnt := 1 to len(aSrc)
				SRI->(DBGOTO(aSrc[nCnt,3]))
				
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRI->RI_PD,"RV_TIPOCOD")
				//IF SRI->RI_PD > '100' .And. SRI->RI_PD < '400'
				If _cTpVb = "1"
					//
					cTipo  := 'P'
					cPD    := SRI->RI_Pd
					nHoras := SRI->RI_Horas
					nValor := SRI->RI_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SRI->RI_VALOR
				//Elseif SRI->RI_PD > '400' .And. SRI->RI_PD < '700'
				ElseIf _cTpVb = "2"
					//
					cTipo  := 'D'
					cPD    := SRI->RI_Pd
					nHoras := SRI->RI_Horas
					nValor := SRI->RI_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SRI->RI_VALOR
				//Elseif SRI->RI_PD > '700'
				ElseIf _cTpVb = "3" .AND. SFPD1(SRI->RI_PD)
					//
					cTipo  := 'B'
					cPD    := SFPD2(SRI->RI_Pd)
					nHoras := SRI->RI_Horas
					nValor := SRI->RI_Valor
					fRC_SomaPD()
					//
				Endif
				
				If SRI->RI_PD == aCodFol[19,1]
					nAteLim := nAteLim + SRI->RI_VALOR
				Elseif SRI->RI_PD$ aCodFol[108,1]
					nBaseFgts := nBaseFgts + SRI->RI_VALOR
				Elseif SRI->RI_PD$ aCodFol[109,1]
					nFgts := nFgts + SRI->RI_VALOR
				Elseif SRI->RI_PD == aCodFol[27,1]
					nBaseIr := nBaseIr + SRI->RI_VALOR
				Endif
				//dbSkip()
			//Enddo
			NEXT
		Endif
	Elseif Esc == 5
		FazSRC(@aSrc,Esc,aCodFol,Semana)
		dbSelectArea('SR1')
		dbSetOrder(1)
		//If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		IF Len(aSrc) > 0
			//While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==      SR1->R1_FILIAL + SR1->R1_MAT
			for nCnt := 1 to Len(aSrc)
				SR1->(DBGOTO(aSrc[nCnt,3]))
				
				If Semana #'99'
					If SR1->R1_SEMANA #Semana
						//dbSkip()
						Loop
					Endif
				Endif
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRC->RC_PD,"RV_TIPOCOD")
				//If SR1->R1_PD > '100' .And. SR1->R1_PD < '400'
				If _cTpVb = "1"
					//
					cTipo  := 'P'
					cPD    := SR1->R1_Pd
					nHoras := SR1->R1_Horas
					nValor := SR1->R1_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SR1->R1_VALOR
				//Elseif SR1->R1_PD > '400' .And. SR1->R1_PD < '700'
				ElseIf _cTpVB = "2"
					//
					cTipo  := 'D'
					cPD    := SR1->R1_Pd
					nHoras := SR1->R1_Horas
					nValor := SR1->R1_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SR1->R1_VALOR
				//Elseif SR1->R1_PD > '700'
				ElseIf _cTpVb = "3" .AND. SFPD1(SR1->R1_PD)
					//
					cTipo  := 'B'
					cPD    := SFPD2(SR1->R1_Pd)
					nHoras := SR1->R1_Horas
					nValor := SR1->R1_Valor
					fRC_SomaPD()
					//
				Endif
				//dbskip()
			//Enddo
			NEXT
		Endif
	Endif
	
	dbSelectArea('SRA')
	
	If TotVenc == 0 .And. TotDesc == 0
		dbSkip()
		Loop
	Endif
	
	// acumular em totalizadores por filial
	nPos := aScan(aFilial,{ |X| X[1] == SRA->RA_FILIAL })
	If nPos == 0   
	   Aadd(aFilial,{SRA->RA_FILIAL,TotVenc,TotDesc})
	Else
	   aFilial[nPos,2] := aFilial[nPos,2] + TotVenc
	   aFilial[nPos,3] := aFilial[nPos,3] + TotDesc
	Endif

	If Vez == 0
		fRC_PerSemana() //-- Carrega Datas referentes a Semana.
		Vez := 1
	EndIf
	
	GRV_WImpress()   // Impressao do Recibo de Pagamento
	
	dbSelectArea('SRA')
	dbSkip()
	TotDesc := 0
	TotVenc := 0
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino da geracao do arquivo texto                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
frc_WImpress()

dbSelectArea('SRC')
dbSetOrder(1)
dbSelectArea('SRI')
dbSetOrder(1)
dbSelectArea('SRA')
Set Filter To
RetIndex('SRA')

If !(Type('ArqNtx') == 'U')
	fErase(cArqNtx)
Endif

#IFNDEF WINDOWS
	Set Device To Screen
#ENDIF

If aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(WnRel)
Endif

MS_FLUSH()

fClose(nHdl)
If xGTotProv != 0
   MSGBOX("Enviar o Arquivo Texto gerado no diretorio "+ALLTRIM(mVar)+" para a InfoDigitus")
Else
   MSGBOX("Nao havia informacoes para gerar o Arquivo Texto, verifique parametros ")
EndIf   

Return

Static Function GRV_WImpress()
nConta  := 0
GRV_Cabec()

For nConta := 1 To Len(aLanca)
    If aLanca[nConta,1] == 'P' 
	  // Grava o registro com os proventos do funcionario
	  nTamLin := 191
	  cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	  cCpo    := "2"
	  cLin    := Stuff(cLin,01,1,cCpo)
	  cCpo    := PADR(aLanca[nConta,2],3)
	  cLin    := Stuff(cLin,2,3,cCpo)
	  cCpo    := PADR(aLanca[nConta,3],20)
	  cLin    := Stuff(cLin,5,20,cCpo)
	  cCpo    := PADR(STRZERO(aLanca[nConta,4]*100,6),6)
	  cLin    := Stuff(cLin,25,6,cCpo)
	  cCpo    := PADR(STRZERO(aLanca[nConta,5]*100,12),12)
	  cLin    := Stuff(cLin,31,12,cCpo)
	  If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	     If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Exit
	  Endif
	  Endif
    ElseIf aLanca[nConta,1] == 'D' 
	  // Grava o registro com os descontos do funcionario
	  nTamLin := 191
	  cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	  cCpo    := "3"
	  cLin    := Stuff(cLin,01,1,cCpo)
	  cCpo    := PADR(aLanca[nConta,2],3)
	  cLin    := Stuff(cLin,2,3,cCpo)
	  cCpo    := PADR(aLanca[nConta,3],20)
	  cLin    := Stuff(cLin,5,20,cCpo)
	  cCpo    := PADR(STRZERO(aLanca[nConta,4]*100,6),6)
	  cLin    := Stuff(cLin,25,6,cCpo)
	  cCpo    := PADR(STRZERO(aLanca[nConta,5]*100,12),12)
	  cLin    := Stuff(cLin,31,12,cCpo)
	  If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	     If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Exit
	     Endif
	  Endif
    ElseIf aLanca[nConta,1] == 'B'
	  // Grava o registro com as bases do funcionario
	  nTamLin := 191
	  cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	  cCpo    := "4"
	  cLin    := Stuff(cLin,01,1,cCpo)
	  cCpo    := PADR(aLanca[nConta,2],3)
	  cLin    := Stuff(cLin,2,3,cCpo)
	  cCpo    := PADR(aLanca[nConta,3],20)
	  cLin    := Stuff(cLin,5,20,cCpo)
	  cCpo    := PADR(STRZERO(aLanca[nConta,4]*100,6),6)
	  cLin    := Stuff(cLin,25,6,cCpo)
	  cCpo    := PADR(STRZERO(aLanca[nConta,5]*100,12),12)
	  cLin    := Stuff(cLin,31,12,cCpo)
	  If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	     If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Exit
	     Endif
	  Endif
    Endif
Next

GRV_Rodape()

Return

Static Function GRV_Cabec()
dbSelectArea('SI3')
dbSetOrder(1)
dbSeek(xFilial('SI3')+SRA->RA_CC)
IF !EOF() .and. SI3->I3_FILIAL==xFilial('SI3') .and. SI3->I3_CUSTO==SRA->RA_CC
   cDescCC := SI3->I3_DESC
ELSE
   cDescCC := "*** NAO CADASTRADO ***"
ENDIF

// Grava o registro com dados do cadastro do funcionario
nTamLin := 227
cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
cCpo    := "1"                    
cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(SRA->(IF(MV_PAR22=1,RA_MAT,RA_CRACHA)),10)
cLin    := Stuff(cLin,02,10,cCpo)
cCpo    := PADR(LEFT(SRA->RA_NOME,27),27)
cLin    := Stuff(cLin,11,27,cCpo)
cCpo    := PADR(STRZERO(SRA->RA_SALARIO*100,12),12)
cLin    := Stuff(cLin,38,12,cCpo)
cCpo    := PADR(SRA->RA_DEPSF,2)
cLin    := Stuff(cLin,50,2,cCpo)
cCpo    := PADR(SRA->RA_DEPIR,2)
cLin    := Stuff(cLin,52,2,cCpo)
cCpo    := PADR(SRA->(IF(MV_PAR23=1,RA_CC,RA_CODLOC)),10)
cLin    := Stuff(cLin,54,10,cCpo)
cCpo    := PADR(IF(MV_PAR21=1,cDescCC,""),24)
cLin    := Stuff(cLin,64,24,cCpo)
cCpo    := PADR(DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL),20)
cLin    := Stuff(cLin,88,20,cCpo)
cCpo    := PADR(SRA->RA_BCDEPSA,8)
cLin    := Stuff(cLin,108,8,cCpo)
cCpo    := PADR(SRA->RA_CTDEPSA,12)
cLin    := Stuff(cLin,116,12,cCpo)

/*cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(SRA->RA_MAT,6)
cLin    := Stuff(cLin,02,6,cCpo)
cCpo    := PADR(LEFT(SRA->RA_NOME,30),30)
cLin    := Stuff(cLin,08,30,cCpo)
cCpo    := PADR(STRZERO(SRA->RA_SALARIO*100,12),12)
cLin    := Stuff(cLin,38,12,cCpo)
cCpo    := PADR(SRA->RA_DEPSF,2)
cLin    := Stuff(cLin,50,2,cCpo)
cCpo    := PADR(SRA->RA_DEPIR,2)
cLin    := Stuff(cLin,52,2,cCpo)
cCpo    := PADR(SRA->RA_CC,9)
cLin    := Stuff(cLin,54,9,cCpo)
cCpo    := PADR(cDescCC,25)
cLin    := Stuff(cLin,63,25,cCpo)
cCpo    := PADR(DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL),20)
cLin    := Stuff(cLin,88,20,cCpo)
cCpo    := PADR(SRA->RA_BCDEPSA,8)
cLin    := Stuff(cLin,108,8,cCpo)
cCpo    := PADR(SRA->RA_CTDEPSA,12)
cLin    := Stuff(cLin,116,12,cCpo)   // JJ*/ 
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
   If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
    Return
   Endif
Endif

Return

Static Function GRV_Rodape()

xDesBasIR := " "
xDesBasIN := " " 
xDesAniv  := " " 
xDesBasFg := " " 
xDesFgts  := " " 
If Esc == 1  //-- Bases de Adiantamento.
	     // Base Ir
	If cBaseAux == 'S' .And. nBaseIr #0
		xDesBasIR := "Base de I.R."
	EndIf
ElseIf Esc == 2 .Or. Esc == 4 //-- Bases de Folha e 13o. 2o.Parc.
	If cBaseAux == 'S'
	     // Base Inss
		If nAteLim #0
		   xDesBasIN := "Base de INSS"     
		Endif
	     // Base Ir
		If nBaseIr #0
		   xDesBasIR := "Base de I.R."     
		Endif
	Endif
EndIf

// Grava o registro com mensagens para o funcionario
nTamLin := 221
cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
cCpo    := "5"
cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(left(Desc_Msg1,40),40)
cLin    := Stuff(cLin,2,40,cCpo)
cCpo    := PADR(left(Desc_Msg2,40),40)
cLin    := Stuff(cLin,42,40,cCpo)
cCpo    := PADR(left(Desc_Msg3,40),40)
cLin    := Stuff(cLin,82,40,cCpo)
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
   If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
   Return
   Endif
Endif

nLiquido := TotVenc - TotDesc

// Grava o registro com totais de Proventos e de Descontos
nTamLin := 187
cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
cCpo    := "6" 
cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(STRZERO(TotVenc*100,12),12)
cLin    := Stuff(cLin,02,12,cCpo)
cCpo    := PADR(STRZERO(TotDesc*100,12),12)
cLin    := Stuff(cLin,14,12,cCpo)
cCpo    := PADR(STRZERO(nLiquido*100,12),12)
cLin    := Stuff(cLin,26,12,cCpo)
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
   If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
     // Exit
   Endif
Endif

//cDescBco := ''
//dbSelectArea("SA6")
//dbSetOrder(1)
//dbSeek(xFilial("SA6")+SRA->RA_BCDEPSAL)
//if !EOF()
//   cBcoAg := SA6->A6_COD + SA6->A6_AGENCIA
//   if cBcoAg == SRA->RA_BCDEPSAL
//      cDescBco := SA6->A6_NREDUZ
//   endif
//endif
//@ Li,08 PSAY cDescBco

//cDet := SUBSTR(SRA->RA_BCDEPSAL,4,5)
//if cDet != "88888"
//   @ Li,27 PSAY SubStr(cDet,1,5)
//   cDet := SUBSTR(SRA->RA_CTDEPSA,5,8)
//   @ Li,34 PSAY SubStr(cDet,1,8)
//endif

Return


Static Function fRC_PerSemana()
cAlias := Alias()
dbSelectArea('SRX')

If !Empty(Semana)
	cChaveSem := Right(StrZero(Year(dDatabase),4),2) + StrZero(Month(dDataBase),2) + SRA->RA_TNOTRAB
	If !dbSeek( '  ' + '01' + cChaveSem + Semana , .T. ) .And. ;
			!dbSeek( SRA->RA_FILIAL + '01' + cChaveSem + Semana , .T. ) .And. ;
			!dbSeek( '  ' + '01' + Left(cChaveSem,4)+'999'+ Semana , .T. ) .And. ;
			!dbSeek( SRA->RA_FILIAL + '01' + Left(cChaveSem,4)+'999'+Semana , .T. )
		HELP( ' ',1,'SEMNAOCAD' )
		dbSelectArea(cAlias)
		Return Nil
	Endif
	cSem_De  := Left(Srx->Rx_Txt,8)
	cSem_Ate := Subs(Srx->Rx_Txt,10,8)
EndIf
dbSelectArea(cAlias)

Return
                                          
/* -->> JJ*/
STATIC FUNCTION SFPD1(cPD) /* jj retorna somente os que tem base verbas passadas */
Local lRet		:= .f.                                                                 
Local _codfol	:= POSICIONE("SRV",1,XFILIAL("SRV")+cPD,"RV_CODFOL")

//if cPd $ "B00/B40/B50/B20/B30/B25/B35/B75/B85/B65"
// jj em 23/04/2010 a pedido
//if _CODFOL $ "318,017,108,018,109,013,014,019,020,015,016,027,151"
if  _CODFOL == STRZERO(318,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(17 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(108,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(18 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(109,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(13 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(14 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(19 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(20 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(15 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(16 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(27 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(151,TAMSX3("RV_CODFOL")[1])
	lRet := .T.
end           
RETURN(lRET)

STATIC FUNCTION SFPD2(cPD) /* JJ RETORNA SO UMA VERBA DEPENDENDO DO GRUPO */
local cRET := ""                                                               
Local _codfol	:= POSICIONE("SRV",1,XFILIAL("SRV")+cPD,"RV_CODFOL")

cRET := cPD                 

//IF _CodFol $ "017;108"
IF  _CODFOL == STRZERO(17 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(108,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(17 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

//elseif _CodFol $ "018;109"
elseif  _CODFOL == STRZERO(18 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(109,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(18 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

//elseif _CodFol $ "013;014;019;020"
elseif  _CODFOL == STRZERO(13 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(14 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(19 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(20 ,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(13 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

//elseif _CodFol $ "015;016;027;151"
elseif  _CODFOL == STRZERO(15 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(16 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(27 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(151,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(15 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

end

/*
IF cPD $ "B40/B50"
	cRET := "B40"
ELSEIF cPD $ "B25/B35"
	CRET := "B25"
ELSEIF cPD $ "B75/B85/B65"
	CRET := "B65"
END
*/

RETURN(cRET)


Static Function fRC_SomaPd()
DESC_PAGA := DescPd(cPd,Sra->Ra_Filial)  //-- Mostra como pagto.
//--Array para Recibo Pre-Impresso.
// If cTipo #'B'  
	nPos := aScan(aLanca,{ |X| X[2] == cPd })
	If nPos == 0
		Aadd(aLanca,{cTipo,cPd,DESC_PAGA,nHoras,nValor})
	Else
		aLanca[nPos,4] := aLanca[nPos,4] + nHoras
		aLanca[nPos,5] := aLanca[nPos,5] + nValor
	Endif
// Endif

Return

Static Function Frc_WImpress()
nConta  := 0
nContr  := 0
nContrT := 0
aDriver := LEDriver()
nLinhas   := 28 
cCompac   := aDriver[1]
cNormal   := aDriver[2]
cOitavos  := CHR(27) + CHR(48)
Ordem_Rel := 1

Li := Li + 1
@ Li, 01 PSAY &cNormal
@ Li, 10 PSAY cOitavos
Li := Li + 2
// Descricao da Folha
if Esc==1
   cDescFol := "TOTAIS PARA CONFERENCIA DO ADTO. MENSAL"
elseif Esc==2
   cDescFol := "TOTAIS PARA CONFERENCIA DA FOLHA MENSAL"
elseif Esc==3
   cDescFol := "TOTAIS PARA CONFERENCIA DO ADTO.13o.SAL."
elseif Esc==4
   cDescFol := "TOTAIS PARA CONFERENCIA DO 13o.SALARIO"
elseif Esc==5
   cDescFol := "TOTAIS PARA CONFERENCIA DO PART.RESULT."
endif

@ Li,12 PSAY Titulo
Li := Li + 2
@ Li,17 PSAY cDescFol
Li := Li + 2
// Mes, Ano
@ Li,30 PSAY MesExtenso(Month(dDataBase))
Set Century On
@ Li,41 PSAY Str(Year(dDataBase),4)
Set Century Off
Li := Li + 3
@ Li,12 PSAY SM0->M0_NOMECOM
Li := Li + 1
@ Li,12 PSAY SM0->M0_ENDCOB + "      CEP: " + Substr(SM0->M0_CEPCOB,1,5)+"-"+SubStr(SM0->M0_CEPCOB,6,3)
Li := Li + 1
@ Li,12 PSAY SM0->M0_CIDCOB
@ Li,47 PSAY " CGC: " + SM0->M0_CGC
Li := Li + 2
@ Li,01 PSAY 'Filial     Proventos      Descontos       Liquidos'
Li := Li + 2

For I := 1 to Len(aFilial)
    @ Li,002 PSAY aFilial[I,1]
    @ Li,008 PSAY Trans(aFilial[I,2], '@E 99,999,999.99')
    @ Li,023 PSAY Trans(aFilial[I,3], '@E 99,999,999.99')
    @ Li,038 PSAY Trans((aFilial[I,2] - aFilial[I,3]), '@E 99,999,999.99')
    xGTotProv := xGTotProv + aFilial[I,2]
    xGTotDesc := xGTotDesc + aFilial[I,3]
    xGTotLiq  := xGTotLiq  + (aFilial[I,2] - aFilial[I,3])
Next
		
@ Li,00 PSAY Replicate('-',80)
Li := Li + 2
@ Li,001 PSAY "TOTAL " 
@ Li,008 PSAY Trans(xGTotProv,'@E 999999,999.99')
@ Li,023 PSAY Trans(xGTotDesc,'@E 999999,999.99')
@ Li,038 PSAY Trans(xGTotLiq, '@E 999999,999.99')
Li := Li + 2

Return

/*****/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 21.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta o grupo de perguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR285                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX1()
Local aRegs    := {}
Local i,j                                                                      

aadd(aRegs,{cPerg,"01","Imprimir Recibos   ?          ","mv_ch1","N",01,0,0,"C","","mv_par01","Adto.","","","Folha","","","1¦Parc.","","","2¦Parc.","","","Val.Extras","",""})
aadd(aRegs,{cPerg,"02","Numero da Semana   ?          ","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"03","Filial De          ?          ","mv_ch3","C",02,0,0,"G","naovazio","mv_par03","","01","","","","","","","","","","","","","SM0"})
aadd(aRegs,{cPerg,"04","Filial At‚         ?          ","mv_ch4","C",02,0,0,"G","naovazio","mv_par04","","zz","","","","","","","","","","","","","SM0"})
aadd(aRegs,{cPerg,"05","Centro de Custo De ?          ","mv_ch5","C",09,0,0,"G","naovazio","mv_par05","","0","","","","","","","","","","","","","SI3"})
aadd(aRegs,{cPerg,"06","Centro de Custo At‚?          ","mv_ch6","C",09,0,0,"G","naovazio","mv_par06","","999999999","","","","","","","","","","","","","SI3"})
aadd(aRegs,{cPerg,"07","Matricula De       ?          ","mv_ch7","C",06,0,0,"G","naovazio","mv_par07","","000001","","","","","","","","","","","","","SRA"})
aadd(aRegs,{cPerg,"08","Matricula At‚      ?          ","mv_ch8","C",06,0,0,"G","naovazio","mv_par08","","999999","","","","","","","","","","","","","SRA"})
aadd(aRegs,{cPerg,"09","Nome De            ?          ","mv_ch9","C",30,0,0,"G","naovazio","mv_par09","","A","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"10","Nome At‚           ?          ","mv_cha","C",30,0,0,"G","naovazio","mv_par10","","ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"11","Chapa De           ?          ","mv_chb","C",05,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"12","Chapa At‚          ?          ","mv_chc","C",05,0,0,"G","","mv_par12","","99999","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"13","Mensagem 1         ?          ","mv_chd","C",01,0,0,"G","","mv_par13","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"14","Mensagem 2         ?          ","mv_che","C",01,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"15","Mensagem 3         ?          ","mv_chf","C",01,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"16","Situa‡”es a Imp.   ?          ","mv_chg","C",05,0,0,"G","fSituacao","mv_par16","","A*FT","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"17","Categorias a Imp.  ?          ","mv_chh","C",10,0,0,"G","fCategoria","mv_par17","","ACDEGHIJMP**","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"18","Imprime Bases      ?          ","mv_chi","C",01,0,0,"C","","mv_par18","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"19","Dias/Mes Pagto                ","mv_chj","C",05,0,0,"G","","mv_par19","01/03","2901","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"20","Caminho Arq.Texto             ","mv_chk","C",30,0,0,"G","","mv_par20","C:\RELATO\","C:\holteste","","","","","","","","","","","","",""})

aadd(aRegs,{cPerg,"21","Envia Desc CC      ?          ","mv_chl","C",01,0,0,"C","","mv_par21","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"22","Tipo Matricula     ?          ","mv_chm","C",01,0,0,"C","","mv_par22","Matricula","","","Chapa","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"23","CC ou Locacao      ?          ","mv_chn","C",01,0,0,"C","","mv_par23","CC","","","Locacao","","","","","","","","","","",""})

_fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)

//pergunte(CPERG,.T.)

RETURN NIL
*------------------------------------------------------------------------------
Static function _fAtuSx1(cPerg,aRegs)
*------------------------------------------------------------------------------
local _nOrdSx1:=sx1->(indexord()),;
      _nRecSx1:=sx1->(recno()),_nVez,_lApaga:=.f.,_nPergs:=0

sx1->(dbsetorder(1))
// Verifica se o formato solicitado ainda e o mesmo, caso contrario,
// apaga e inclui tudo novamente
For _nVez:=1 to Len(aRegs)
  If sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
     _nPergs++
     if alltrim(sx1->x1_pergunt)<>alltrim(aRegs[_nVez,3])
        _lApaga:=.t.
        exit
     endif   
  endif   
next
if _nPergs<>len(aRegs).or._lApaga          
   sx1->(DbSeek(cPerg,.f.))
   do while sx1->(!eof().and.x1_grupo==aRegs[1,1])
      if sx1->(reclock(alias(),.f.))
         sx1->(dbdelete())
         sx1->(msunlock())
      endif
      sx1->(dbskip(1))
   enddo
endif

For _nVez:=1 to Len(aRegs)
  If !sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
    sx1->(RecLock(alias(),.T.))
    sx1->X1_GRUPO  :=aRegs[_nVez,01]
    sx1->X1_ORDEM  :=aRegs[_nVez,02]
    sx1->X1_PERGUNT:=aRegs[_nVez,03]
    sx1->X1_VARIAVL:=aRegs[_nVez,04]
    sx1->X1_TIPO   :=aRegs[_nVez,05]
    sx1->X1_TAMANHO:=aRegs[_nVez,06]
    sx1->X1_DECIMAL:=aRegs[_nVez,07]
    sx1->X1_PRESEL :=aRegs[_nVez,08]
    sx1->X1_GSC    :=aRegs[_nVez,09]
    sx1->X1_VALID  :=aRegs[_nVez,10]
    sx1->X1_VAR01  :=aRegs[_nVez,11]
    sx1->X1_DEF01  :=aRegs[_nVez,12]
    sx1->X1_CNT01  :=aRegs[_nVez,13]
    sx1->X1_VAR02  :=aRegs[_nVez,14]
    sx1->X1_DEF02  :=aRegs[_nVez,15]
    sx1->X1_CNT02  :=aRegs[_nVez,16]
    sx1->X1_VAR03  :=aRegs[_nVez,17]
    sx1->X1_DEF03  :=aRegs[_nVez,18]
    sx1->X1_CNT03  :=aRegs[_nVez,19]
    sx1->X1_VAR04  :=aRegs[_nVez,20]
    sx1->X1_DEF04  :=aRegs[_nVez,21]
    sx1->X1_CNT04  :=aRegs[_nVez,22]
    sx1->X1_VAR05  :=aRegs[_nVez,23]
    sx1->X1_DEF05  :=aRegs[_nVez,24]
    sx1->X1_CNT05  :=aRegs[_nVez,25]
    sx1->X1_F3     :=aRegs[_nVez,26]
    if len(aRegs[_nVez])>26
       sx1->x1_picture:=aRegs[_nVez,27]
    endif
    sx1->(MsUnlock())
  Endif
Next
sx1->(dbgoto(_nRecSx1))
sx1->(dbsetorder(_nOrdSx1))
Return                 

/* faz src 
array para ordenar na forma de provento, base , desconto  e depois como verba. pq 
nessa customizacao nao usa o padrao da siga < 400 < 700 > 700
jairo em 20/05/2010
*/                 
Static Function FazSRC(aSrc,Esc,aCodFol,Semana)
Local _cTpVb := ""

aSrc := {}       

if Esc = 1 .OR. Esc = 2
		dbSelectArea('SRC')
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			Do While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT

				If SRC->RC_SEMANA #Semana
					dbSkip()
					Loop
				Endif

				If (Esc == 1) .And. (Src->Rc_Pd == aCodFol[7,1]) //-- Desconto de Adto.
					aadd( aSrc , {'2P', aCodFol[6,1] , recno() } )
					//                  
					/*                    
					cTipo  := 'P'
					cPD    := aCodFol[6,1]
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					*/
					//
					//TotVenc := TotVenc + Src->Rc_Valor
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[12,1])
					aadd( aSrc , {'3D', aCodFol[9,1] , recno() } )
					//                          
					/*
					cTipo  := 'D'
					cPD    := aCodFol[9,1]
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SRC->RC_VALOR
					*/
				Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[8,1])
					aadd( aSrc , {'2P', aCodFol[8,1] , recno() } )
					/*
					//
					cTipo  := 'P'
					cPD    := aCodFol[8,1]
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SRC->RC_VALOR
					*/
				Else
					_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRC->RC_PD,"RV_TIPOCOD")
					//If Src->Rc_Pd > ' .And. Src->Rc_Pd < '400'
					If _cTpVb = "1"
						If (Esc #1) .Or. (Esc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,'RV_ADIANTA') == 'S')

							aadd( aSrc , {'2P', SRC->RC_PD , recno() } )
							/*
							//
							cTipo  := 'P'
							cPD    := SRC->RC_Pd
							nHoras := SRC->RC_Horas
							nValor := SRC->RC_Valor                                 
							fRC_SomaPD()
							//
							TotVenc := TotVenc + Src->Rc_Valor
							*/
						Endif
					//Elseif Src->Rc_Pd > '400' .And. Src->Rc_Pd < '700'
					ElseIf _cTpVb = "2"
						If (Esc #1) .Or. (Esc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,'RV_ADIANTA') == 'S')
							aadd( aSrc , {'3D', SRC->RC_PD , recno() } )
							/*
							//
							cTipo  := 'D'
							cPD    := SRC->RC_Pd
							nHoras := SRC->RC_Horas
							nValor := SRC->RC_Valor
							fRC_SomaPD()
							//
							TotDesc := TotDesc + Src->Rc_Valor
							*/
						Endif
					//Elseif Src->Rc_Pd > '700'
					ElseIf _cTpVb = "3"
						If (Esc #1 .AND. SFPD1(SRC->RC_PD)) .Or. (Esc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,'RV_ADIANTA') == 'S') .AND. SFPD1(SRC->RC_PD)
							aadd( aSrc , {'4B', SFPD2(SRC->RC_Pd) , recno() } )
							/*
							//
							cTipo  := 'B'
							cPD    := SFPD2(SRC->RC_Pd)
							nHoras := SRC->RC_Horas
							nValor := SRC->RC_Valor
							fRC_SomaPD()
							//*/
						Endif
					Endif
				Endif
				dbSelectArea('SRC')
				dbSkip()
			Enddo
		end
elseif Esc = 3
		dbSelectArea('SRC')
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
		     // Monta matriz com valores
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
				If SRC->RC_PD == aCodFol[22,1]
					aadd( aSrc , {'2P', SRC->RC_PD , recno() } )
					/*
					//
					cTipo  := 'P'
					cPD    := SRC->RC_Pd
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SRC->RC_VALOR */
				Elseif SRC->RC_PD == aCodFol[172,1]
					aadd( aSrc , {'3D', SRC->RC_PD , recno() } )
					/*//
					cTipo  := 'D'
					cPD    := SRC->RC_Pd
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SRC->RC_VALOR */
				Elseif SRC->RC_PD == aCodFol[108,1] .Or. SRC->RC_PD == aCodFol[109,1] .Or. SRC->RC_PD == aCodFol[173,1]
					aadd( aSrc , {'4B', SRC->RC_PD , recno() } )
					/*//
					cTipo  := 'B'
					cPD    := SRC->RC_Pd
					nHoras := SRC->RC_Horas
					nValor := SRC->RC_Valor
					fRC_SomaPD()
					//*/
				Endif
				
				dbSelectArea('SRC')
				dbSkip()
			Enddo
		end
elseif Esc = 4 //jjj
		dbSelectArea('SRI')
		dbSetOrder(2)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT)
			Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRI->RI_FILIAL + SRI->RI_CC + SRI->RI_MAT
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRI->RI_PD,"RV_TIPOCOD")
				//IF SRI->RI_PD > '100' .And. SRI->RI_PD < '400'
				If _cTpVb = "1"
					aadd( aSrc , {'2P', SRI->RI_PD , recno() } )
					/*//
					cTipo  := 'P'
					cPD    := SRI->RI_Pd
					nHoras := SRI->RI_Horas
					nValor := SRI->RI_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SRI->RI_VALOR*/
				//Elseif SRI->RI_PD > '400' .And. SRI->RI_PD < '700'
				ElseIf _cTpVb = "2"
					aadd( aSrc , {'3D', SRI->RI_PD , recno() } )
					/*//
					cTipo  := 'D'
					cPD    := SRI->RI_Pd
					nHoras := SRI->RI_Horas
					nValor := SRI->RI_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SRI->RI_VALOR*/
				//Elseif SRI->RI_PD > '700'
				ElseIf _cTpVb = "3" .AND. SFPD1(SRI->RI_PD)
					aadd( aSrc , {'4B', SFPD2(SRI->RI_Pd) , recno() } )
					/*//
					cTipo  := 'B'
					cPD    := SFPD2(SRI->RI_Pd)
					nHoras := SRI->RI_Horas
					nValor := SRI->RI_Valor
					fRC_SomaPD()
					//*/
				Endif
				
				dbSkip()
			Enddo
		Endif
elseif Esc = 5
		dbSelectArea('SR1')
		dbSetOrder(1)
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==      SR1->R1_FILIAL + SR1->R1_MAT
				If Semana #'99'
					If SR1->R1_SEMANA #Semana
						dbSkip()
						Loop
					Endif
				Endif
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRC->RC_PD,"RV_TIPOCOD")
				//If SR1->R1_PD > '100' .And. SR1->R1_PD < '400'
				If _cTpVb = "1"
					aadd( aSrc , {'2P', SR1->R1_PD , recno() } )
					/*//
					cTipo  := 'P'
					cPD    := SR1->R1_Pd
					nHoras := SR1->R1_Horas
					nValor := SR1->R1_Valor
					fRC_SomaPD()
					//
					TotVenc := TotVenc + SR1->R1_VALOR*/
				//Elseif SR1->R1_PD > '400' .And. SR1->R1_PD < '700'
				ElseIf _cTpVB = "2"
					aadd( aSrc , {'3D', SR1->R1_PD , recno() } )
					/*//
					cTipo  := 'D'
					cPD    := SR1->R1_Pd
					nHoras := SR1->R1_Horas
					nValor := SR1->R1_Valor
					fRC_SomaPD()
					//
					TotDesc := TotDesc + SR1->R1_VALOR*/
				//Elseif SR1->R1_PD > '700'
				ElseIf _cTpVb = "3" .AND. SFPD1(SR1->R1_PD)
					aadd( aSrc , {'4B', SR1->R1_PD , recno() } )
					/*//
					cTipo  := 'B'
					cPD    := SFPD2(SR1->R1_Pd)
					nHoras := SR1->R1_Horas
					nValor := SR1->R1_Valor
					fRC_SomaPD()
					//*/
				Endif
				dbskip()
			Enddo
		Endif
End
aSort(aSRC,,, { |x,y| y[1]+y[2] > x[1]+x[2]} )

Return()