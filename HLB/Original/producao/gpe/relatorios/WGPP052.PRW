#include "rwmake.ch"        
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
#INCLUDE "RECIBO.CH" 
/*
Funcao      : WGPP052
Parametros  : Nenhum
Retorno     : cBar
Objetivos   : Folha de Pagamento - Impressão do Holerite de meses fechados
Autor    	: Customizado pela RASS CONSULTORIA para uso exclusio da PRYOR CONSULTING 
Data     	: 17/05/2010.
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 20/02/2014
Módulo      : Gestão de Pessoal.
*/ 
*---------------------*
User Function WGPP052()
*---------------------*
Local aAreaSRV	:= SRV->(GETAREA())      
Local _cTpVb	:= ""

SetPrvt("CBTXT,CSTRING,AORD,CDESC1,CDESC2,CDESC3")
SetPrvt("LEND,NLASTKEY,ALINHA,NOMEPROG,AReturn")
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
SetPrvt("aFilial,xGTotProv,xGTotDesc,xGTotLiq,lTemDados")

Private cArqTxt := ""
Private nHdl    := 0

lTemDados := .F.

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
cPerg     := "WGPP052"
nomeprog  := "WGPP052"
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

ajustaSX1()

Pergunte(cPerg,.F.)

SRA->(DbSetOrder(1))
If SRA->(FieldPos("RA_CODLOC")) == 0 .and. MV_PAR23 <> 1
	Alert("Empresa não possui o campo 'RA_CODLOC - Locacao', foi selecionado automaticamente como 'CC'.")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WnRel := nomeprog 
WnRel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,,,.F.)

dbSelectArea("SX1")
SX1->(dbSetOrder(1))
SX1->(dbSeek(cPERG+"22"))
SX1->(RecLock("SX1",.F.))
SX1->X1_CNT01 := SPACE(60)
MsUnlock()

If nLastKey == 27
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return Nil
Endif

RptStatus({|| fRC_Imp()})  //-- Chamada do Relatorio.

Return Nil

*-----------------------*
Static Function fRC_Imp()
*-----------------------*
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

//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
cMesAno	  := MV_PAR01
Esc       := MV_PAR02
Semana    := MV_PAR03
FilialDe  := MV_PAR04
FilialAte := MV_PAR05
CcDe      := MV_PAR06
CcAte     := MV_PAR07
MatDe     := MV_PAR08
MatAte    := MV_PAR09
NomDe     := MV_PAR10
NomAte    := MV_PAR11
ChapaDe   := MV_PAR12
ChapaAte  := MV_PAR13
Mensag1   := MV_PAR14
Mensag2   := MV_PAR15
Mensag3   := MV_PAR16
cSituacao := MV_PAR17
cCategoria:= MV_PAR18
cBaseAux  := If(MV_PAR19 == 1,"S","N")
cDiaPagto := MV_PAR20
mVar      := MV_PAR21    
lEnviaCC  := MV_PAR22==1
lTpMat    := MV_PAR23==1
lTpLoc    := MV_PAR24==1
nModoImp  := MV_PAR25
cEmail    := MV_PAR26


If EMPTY(FilialDe)
	FilialDe := "0"
EndIf
If EMPTY(CcDe)
	CcDe := "0"
EndIf
If EMPTY(MatDe)
	MatDe := "0"
EndIf
If EMPTY(NomDe)
	NomDe := "0"
EndIf

If nModoImp <> 1 .and. EMPTY(ALLTRIM(cEmail))
	Alert("Necessario informar o email para o modo de impressão selecionado!")
	Return
EndIf

//³ Selecionando a Ordem de impressao escolhida no parametro.    ³
dbSelectArea('SRA')
If nOrdem == 1 .or. nOrdem == 2 .or. nOrdem == 3
	SRA->(dbSetOrder(nOrdem))
ElseIf nOrdem == 4
	cArqNtx  := CriaTrab(NIL,.f.)
	cIndCond := 'RA_Filial + RA_Chapa + RA_Mat'
	IndRegua('SRA',cArqNtx,cIndCond,,,"Selecionando Registros...")
ElseIf nOrdem == 5
	SRA->(dbSetOrder(8))
EndIf
SRA->(dbGoTop())

If Esc==1
	cDescFol := "ADTO. MENSAL"
ElseIf Esc==2
	cDescFol := "FOLHA MENSAL"
ElseIf Esc==3
	cDescFol := "ADTO.13o.SAL."
ElseIf Esc==4
	cDescFol := "13o.SALARIO"
ElseIf Esc==5
	cDescFol := "PART.RESULT."
EndIf

// Seta posicao para 0,0
SetPrc(0,0)

If nTipRel == 2
	aDriver := LEDriver()
	cCompac := aDriver[1]
	cNormal := aDriver[2]
	@ 00,00 PSAY &cCompac
Endif   

//³ Carrega Regua Processamento
SetRegua(RecCount()) //-- Total de elementos da regua.

If nModoImp <> 1
	mVar := "\Spool"
EndIf
mVar := ALLTRIM(mVar)
If Right(mVar,1) == "\"
	mVar := Left(mVar,Len(mVar)-1)
EndIf
If !ExistDir(mVar)
	MakeDir(mVar)
EndIf

cArqTxt := UPPER(ALLTRIM(mVAR)+"\CONDUCTO.TXT")

If File(cArqTxt)
    If FErase(cArqTxt) <> 0
	    MsgAlert("Não foi possivel criar o arquivo '"+ALLTRIM(cArqTxt)+"', verifique se não esta em uso por outro programa!","Atencao!")
    	Return
    EndIf
EndIf

If (nHdl := fCreate(cArqTxt)) == -1
    MsgAlert("Não foi possivel encontrar o Caminho '"+ALLTRIM(mVAR)+"'! Verifique os parametros.","Atencao!")
    Return
Endif

aMes    := {"JANEIRO  ","FEVEREIRO","MARCO   ","ABRIL    ","MAIO     ","JUNHO    ","JULHO    ","AGOSTO   ","SETEMBRO ","OUTUBRO ","NOVEMBRO ","DEZEMBRO "}
nElem   := VAL(SUBSTR(DTOS(dDataBase),5,2))
xMesExt := aMes[nElem]

// Grava o registro Header referente a empresa
nTamLin := 171
cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
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
   
FWrite(nHdl,cLin,Len(cLin))

//³ Inicializa a regua de processamento
Processa({|| RunCont() },"Processando...")

Return

*-----------------------*
Static Function RunCont()
*-----------------------*
Local cLin, cCpo
Local aSRD := {}
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
While SRA->(!EOF()) .And. &cInicio <= cFim
	IncRegua()  //-- Move a regua.

	//³ Cancela ImpresÆo ao se pressionar <ALT> + <A>                ³
	Inkey()
	If Lastkey() == 286
		lEnd := .T.
	EndIf   

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	EndIF                   

	//³ Consiste Parametrizacao do Intervalo de Geracao              ³
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
		FazSRD(@aSRD,Esc,aCodFol,Semana)
		dbSelectArea('SRD')
		If Len(aSRD) > 0
			For nCnt := 1 to Len(aSRD)
				SRD->(DBGOTO(aSRD[nCnt,3]))
				If SRD->RD_SEMANA #Semana
					Loop
				Endif

				If (Esc == 1) .And. (Src->Rc_Pd == aCodFol[7,1]) //-- Desconto de Adto.
					cTipo  := 'P'
					cPD    := aCodFol[6,1]
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotVenc := TotVenc + SRD->RD_VALOR
				ElseIf (Esc == 1) .And. (SRD->RD_PD == aCodFol[12,1])
					cTipo  := 'D'
					cPD    := aCodFol[9,1]
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotDesc := TotDesc + SRD->RD_VALOR
				ElseIf (Esc == 1) .And. (SRD->RD_PD == aCodFol[8,1])
					cTipo  := 'P'
					cPD    := aCodFol[8,1]
					nHoras := SRD->RD_Horas
					nValor := SRD->RD_Valor
					fRC_SomaPD()
					TotVenc := TotVenc + SRD->RD_VALOR
				Else
					_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRD->RD_PD,"RV_TIPOCOD")
					If _cTpVb = "1"
						If (Esc #1) .Or. (Esc == 1 .And. PosSrv(SRD->RD_PD,Sra->Ra_Filial,'RV_ADIANTA') == 'S')
							cTipo  := 'P'
							cPD    := SRD->RD_Pd
							nHoras := SRD->RD_Horas
							nValor := SRD->RD_Valor                                 
							fRC_SomaPD()
							TotVenc := TotVenc + SRD->RD_VALOR
						Endif
					ElseIf _cTpVb = "2"
						If (Esc #1) .Or. (Esc == 1 .And. PosSrv(SRD->RD_PD,Sra->Ra_Filial,'RV_ADIANTA') == 'S')
							cTipo  := 'D'
							cPD    := SRD->RD_PD
							nHoras := SRD->RD_HORAS
							nValor := SRD->RD_VALOR
							fRC_SomaPD()
							TotDesc := TotDesc + SRD->RD_VALOR
						Endif
					ElseIf _cTpVb = "3"
						If (Esc #1 .AND. SFPD1(SRD->RD_PD)) .Or. (Esc == 1 .And. PosSrv(SRD->RD_PD,Sra->Ra_Filial,'RV_ADIANTA') == 'S') .AND. SFPD1(SRD->RD_PD)
							cTipo  := 'B'
							cPD    := SFPD2(SRD->RD_PD)
							nHoras := SRD->RD_HORAS
							nValor := SRD->RD_VALOR
							fRC_SomaPD()
						Endif
					Endif
				Endif
				If ESC == 1
					If SRD->RD_PD == aCodFol[10,1]
						nBaseIr := SRD->RD_VALOR
					Endif
				ElseIf SRD->RD_PD == aCodFol[13,1]
					nAteLim := nAteLim + SRD->RD_VALOR
				ElseIf SRD->RD_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]
					nBaseFgts := nBaseFgts + SRD->RD_VALOR
				ElseIf SRD->RD_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]
					nFgts := nFgts + SRD->RD_VALOR
				ElseIf SRD->RD_PD == aCodFol[15,1]
					nBaseIr := nBaseIr + SRD->RD_VALOR
				ElseIf SRD->RD_PD == aCodFol[16,1]
					 nBaseIrFe := nBaseIrFe + SRD->RD_VALOR
				Endif
			NEXT
		Endif
	ElseIf Esc == 3
		FazSRD(@aSRD,Esc,aCodFol,Semana)
		dbSelectArea('SRD')
		IF Len(aSRD) > 0
		     // Monta matriz com valores
			For nCnt := 1 to Len(aSRD)
				SRC->(DBGOTO(aSRD[nCnt,3]))
				If SRD->RD_PD == aCodFol[22,1]
					cTipo  := 'P'
					cPD    := SRD->RD_PD
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotVenc := TotVenc + SRD->RD_VALOR
				ElseIf SRD->RD_PD == aCodFol[172,1]
					cTipo  := 'D'
					cPD    := SRD->RD_PD
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotDesc := TotDesc + SRD->RD_VALOR
				ElseIf SRD->RD_PD == aCodFol[108,1] .Or. SRD->RD_PD == aCodFol[109,1] .Or. SRD->RD_PD == aCodFol[173,1]
					cTipo  := 'B'
					cPD    := SRD->RD_PD
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
				Endif
				If SRD->RD_PD == aCodFol[108,1]
					nBaseFgts := SRD->RD_VALOR
				ElseIf SRD->RD_PD == aCodFol[109,1]
					nFgts     := SRD->RD_VALOR
				Endif
			Next
		Endif
	ElseIf Esc == 4
		FazSRD(@aSRD,Esc,aCodFol,Semana)
		dbSelectArea('SRD')
		SRD->(dbSetOrder(2))
		IF Len(aSRD) > 0
			For nCnt := 1 to len(aSRD)
				SRD->(DBGOTO(aSRD[nCnt,3]))
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRD->RD_PD,"RV_TIPOCOD")
				If _cTpVb = "1"
					cTipo  := 'P'
					cPD    := SRD->RD_Pd
					nHoras := SRD->RD_Horas
					nValor := SRD->RD_Valor
					fRC_SomaPD()
					TotVenc := TotVenc + SRD->RD_VALOR
				ElseIf _cTpVb = "2"
					cTipo  := 'D'
					cPD    := SRD->RD_PD
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotDesc := TotDesc + SRD->RD_VALOR
				ElseIf _cTpVb = "3" .AND. SFPD1(SRD->RD_PD)
					cTipo  := 'B'
					cPD    := SFPD2(SRD->RD_PD)
					nHoras := SRD->RD_Horas
					nValor := SRD->RD_Valor
					fRC_SomaPD()
				Endif
				
				If SRD->RD_PD == aCodFol[19,1]
					nAteLim := nAteLim + SRD->RD_VALOR
				ElseIf SRD->RD_PD$ aCodFol[108,1]
					nBaseFgts := nBaseFgts + SRD->RD_VALOR
				ElseIf SRD->RD_PD$ aCodFol[109,1]
					nFgts := nFgts + SRD->RD_VALOR
				ElseIf SRD->RD_PD == aCodFol[27,1]
					nBaseIr := nBaseIr + SRD->RD_VALOR
				Endif
			NEXT
		Endif
	ElseIf Esc == 5
		FazSRD(@aSRD,Esc,aCodFol,Semana)
		dbSelectArea('SRD')
		SRD->(dbSetOrder(1))
		If Len(aSRD) > 0
			for nCnt := 1 to Len(aSRD)
				SRD->(DBGOTO(aSRD[nCnt,3]))
				If Semana #'99'
					If SRD->RD_SEMANA #Semana
						Loop
					Endif
				Endif
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRD->RD_PD,"RV_TIPOCOD")
				If _cTpVb = "1"
					cTipo  := 'P'
					cPD    := SRD->RD_PD
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotVenc := TotVenc + SRD->RD_VALOR
				ElseIf _cTpVB = "2"
					cTipo  := 'D'
					cPD    := SRD->RD_PD
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
					TotDesc := TotDesc + SRD->RD_VALOR
				ElseIf _cTpVb = "3" .AND. SFPD1(SRD->RD_PD)
					cTipo  := 'B'
					cPD    := SFPD2(SRD->RD_PD)
					nHoras := SRD->RD_HORAS
					nValor := SRD->RD_VALOR
					fRC_SomaPD()
				Endif
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
	Endif

	GRV_WImpress()   // Impressao do Recibo de Pagamento

	dbSelectArea('SRA')
	dbSkip()
	TotDesc := 0
	TotVenc := 0
EndDo

//³ Termino da geracao do arquivo texto
frc_WImpress()

dbSelectArea('SRD')
SRD->(dbSetOrder(1))
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
If lTemDados
	If nModoImp == 1
		MSGBOX("Arquivo salvo no diretorio '"+ALLTRIM(mVar)+"'!")
	Else
		lCript := nModoImp == 3
		SendMail(cArqTxt,cEmail,lCript)
	Endif
Else
	MSGBOX("Sem dados para geração do arquivo texto, verifique parametros!")
EndIf   

Return

*----------------------------*
Static Function GRV_WImpress()
*----------------------------*
nConta  := 0
GRV_Cabec()

For nConta := 1 To Len(aLanca)
    If aLanca[nConta,1] == 'P' 
		// Grava o registro com os proventos do funcionario
		nTamLin := 191
		cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
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
		FWrite(nHdl,cLin,Len(cLin))
    ElseIf aLanca[nConta,1] == 'D' 
		// Grava o registro com os descontos do funcionario
		nTamLin := 191
		cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
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
		FWrite(nHdl,cLin,Len(cLin))
    ElseIf aLanca[nConta,1] == 'B'
		// Grava o registro com as bases do funcionario
		nTamLin := 191
		cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
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
		fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	Endif
Next

GRV_Rodape()

Return
        
*-------------------------*
Static Function GRV_Cabec()
*-------------------------*
dbSelectArea('SI3')
SI3->(dbSetOrder(1))
SI3->(dbSeek(xFilial('SI3')+SRA->RA_CC))
If SI3->(!EOF()) .and. SI3->I3_FILIAL==xFilial('SI3') .and. SI3->I3_CUSTO==SRA->RA_CC
   cDescCC := SI3->I3_DESC
ELSE
   cDescCC := "*** NAO CADASTRADO ***"
Endif

// Grava o registro com dados do cadastro do funcionario
nTamLin := 227
cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
cCpo    := "1"                    
cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(SRA->(IF(lTpMat,RA_MAT,RA_CRACHA)),10)
cLin    := Stuff(cLin,02,10,cCpo)
cCpo    := PADR(LEFT(SRA->RA_NOME,27),27)
cLin    := Stuff(cLin,11,27,cCpo)
cCpo    := PADR(STRZERO(SRA->RA_SALARIO*100,12),12)
cLin    := Stuff(cLin,38,12,cCpo)
cCpo    := PADR(SRA->RA_DEPSF,2)
cLin    := Stuff(cLin,50,2,cCpo)
cCpo    := PADR(SRA->RA_DEPIR,2)
cLin    := Stuff(cLin,52,2,cCpo)
If SRA->(FieldPos("RA_CODLOC")) <> 0
	cCpo    := PADR(SRA->(IF(lTpLoc,RA_CC,RA_CODLOC)),10)
Else
	cCpo    := PADR(SRA->RA_CC,10)
Endif
cLin    := Stuff(cLin,54,10,cCpo)
cCpo    := PADR(IF(lEnviaCC,cDescCC,""),24)
cLin    := Stuff(cLin,64,24,cCpo)
cCpo    := PADR(DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL),20)
cLin    := Stuff(cLin,88,20,cCpo)
cCpo    := PADR(SRA->RA_BCDEPSA,8)
cLin    := Stuff(cLin,108,8,cCpo)
cCpo    := PADR(SRA->RA_CTDEPSA,12)
cLin    := Stuff(cLin,116,12,cCpo)

fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)

Return

*--------------------------*
Static Function GRV_Rodape()
*--------------------------*
xDesBasIR := " "
xDesBasIN := " " 
xDesAniv  := " " 
xDesBasFg := " " 
xDesFgts  := " " 
If Esc == 1  //-- Bases de Adiantamento.
	// Base Ir
	If cBaseAux == 'S' .And. nBaseIr #0
		xDesBasIR := "Base de I.R."
	Endif
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
Endif

// Grava o registro com mensagens para o funcionario
nTamLin := 221
cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
cCpo    := "5"
cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(left(Desc_Msg1,40),40)
cLin    := Stuff(cLin,2,40,cCpo)
cCpo    := PADR(left(Desc_Msg2,40),40)
cLin    := Stuff(cLin,42,40,cCpo)
cCpo    := PADR(left(Desc_Msg3,40),40)
cLin    := Stuff(cLin,82,40,cCpo)
fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)

nLiquido := TotVenc - TotDesc

// Grava o registro com totais de Proventos e de Descontos
nTamLin := 187
cLin    := Space(nTamLin)+CHR(13)+CHR(10) // Variavel para criacao da linha do registros para gravacao
cCpo    := "6" 
cLin    := Stuff(cLin,01,1,cCpo)
cCpo    := PADR(STRZERO(TotVenc*100,12),12)
cLin    := Stuff(cLin,02,12,cCpo)
cCpo    := PADR(STRZERO(TotDesc*100,12),12)
cLin    := Stuff(cLin,14,12,cCpo)
cCpo    := PADR(STRZERO(nLiquido*100,12),12)
cLin    := Stuff(cLin,26,12,cCpo)
fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)

Return

*-----------------------------*
Static Function fRC_PerSemana()
*-----------------------------*
cAlias := Alias()
dbSelectArea('SRX')

If !Empty(Semana)
	cChaveSem := Right(StrZero(Year(dDatabase),4),2) + StrZero(Month(dDataBase),2) + SRA->RA_TNOTRAB
	If  !SRX->(dbSeek('  ' 			+'01'+cChaveSem			+Semana			,.T.)) .And. ;
		!SRX->(dbSeek(SRA->RA_FILIAL+'01'+cChaveSem			+Semana			,.T.)) .And. ;
		!SRX->(dbSeek('  ' 			+'01'+Left(cChaveSem,4)	+'999'+Semana	,.T.)) .And. ;
		!SRX->(dbSeek(SRA->RA_FILIAL+'01'+Left(cChaveSem,4)	+'999'+Semana	,.T.))
		HELP( ' ',1,'SEMNAOCAD' )
		dbSelectArea(cAlias)
		Return Nil
	Endif
	cSem_De  := Left(Srx->Rx_Txt,8)
	cSem_Ate := Subs(Srx->Rx_Txt,10,8)
Endif
dbSelectArea(cAlias)

Return
                                          
 /* jj retorna somente os que tem base verbas passadas */     
*------------------------*
STATIC FUNCTION SFPD1(cPD)
*------------------------*
Local lRet		:= .f.                                                                 
Local _codfol	:= POSICIONE("SRV",1,XFILIAL("SRV")+cPD,"RV_CODFOL")

If  _CODFOL == STRZERO(318,TAMSX3("RV_CODFOL")[1]) .or.;
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
EndIf           

Return(lRET)

 /* JJ RETORNA SO UMA VERBA DEPENDENDO DO GRUPO */
*------------------------*
STATIC FUNCTION SFPD2(cPD)
*------------------------*
Local cRET := ""                                                               
Local _codfol	:= POSICIONE("SRV",1,XFILIAL("SRV")+cPD,"RV_CODFOL")

cRET := cPD                 

If  _CODFOL == STRZERO(17 ,TAMSX3("RV_CODFOL")[1]) .or.;
	_CODFOL == STRZERO(108,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(17 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

ElseIf  _CODFOL == STRZERO(18 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(109,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(18 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

ElseIf  _CODFOL == STRZERO(13 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(14 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(19 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(20 ,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(13 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

ElseIf  _CODFOL == STRZERO(15 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(16 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(27 ,TAMSX3("RV_CODFOL")[1]) .or.;
		_CODFOL == STRZERO(151,TAMSX3("RV_CODFOL")[1])
	cret := POSICIONE("SRV",2,XFILIAL("SRV")+STRZERO(15 ,TAMSX3("RV_CODFOL")[1]),"RV_COD")

end

Return(cRET)

*--------------------------*
Static Function fRC_SomaPd()
*--------------------------*
DESC_PAGA := DescPd(cPd,Sra->Ra_Filial)  //-- Mostra como pagto.
//--Array para Recibo Pre-Impresso.

nPos := aScan(aLanca,{ |X| X[2] == cPd })
If nPos == 0
	Aadd(aLanca,{cTipo,cPd,DESC_PAGA,nHoras,nValor})
Else
	aLanca[nPos,4] := aLanca[nPos,4] + nHoras
	aLanca[nPos,5] := aLanca[nPos,5] + nValor
Endif

Return

*----------------------------*
Static Function Frc_WImpress()
*----------------------------*
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
If Esc==1
   cDescFol := "TOTAIS PARA CONFERENCIA DO ADTO. MENSAL"
ElseIf Esc==2
   cDescFol := "TOTAIS PARA CONFERENCIA DA FOLHA MENSAL"
ElseIf Esc==3
   cDescFol := "TOTAIS PARA CONFERENCIA DO ADTO.13o.SAL."
ElseIf Esc==4
   cDescFol := "TOTAIS PARA CONFERENCIA DO 13o.SALARIO"
ElseIf Esc==5
   cDescFol := "TOTAIS PARA CONFERENCIA DO PART.RESULT."
Endif

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
    lTemDados := .T.
Next I
		
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
*-------------------------*
Static Function AjustaSX1()
*-------------------------*
Local aRegs    := {}
Local i,j                                                                      

aadd(aRegs,{cPerg,"01","Ano/Mes Pagto      ?","mv_ch1","C",06,0,0,"G","","mv_par01","201601","","","201601","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"02","Imprimir Recibos   ?","mv_ch2","N",01,0,0,"C","","mv_par02","Adto.","","","Folha","","","1¦Parc.","","","2¦Parc.","","","Val.Extras","",""})
aadd(aRegs,{cPerg,"03","Numero da Semana   ?","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"04","Filial De          ?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SM0"})
aadd(aRegs,{cPerg,"05","Filial At‚         ?","mv_ch5","C",02,0,0,"G","naovazio","mv_par05","","ZZ","","","","","","","","","","","","","SM0"})
aadd(aRegs,{cPerg,"06","Centro de Custo De ?","mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SI3"})
aadd(aRegs,{cPerg,"07","Centro de Custo At‚?","mv_ch7","C",09,0,0,"G","naovazio","mv_par07","","ZZZZZZZZZ","","","","","","","","","","","","","SI3"})
aadd(aRegs,{cPerg,"08","Matricula De       ?","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","SRA"})
aadd(aRegs,{cPerg,"09","Matricula At‚      ?","mv_ch9","C",06,0,0,"G","naovazio","mv_par09","","999999","","","","","","","","","","","","","SRA"})
aadd(aRegs,{cPerg,"10","Nome De            ?","mv_cha","C",30,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"11","Nome At‚           ?","mv_chb","C",30,0,0,"G","naovazio","mv_par11","","ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"12","Chapa De           ?","mv_chc","C",05,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"13","Chapa At‚          ?","mv_chd","C",05,0,0,"G","","mv_par13","","ZZZZZ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"14","Mensagem 1         ?","mv_che","C",01,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"15","Mensagem 2         ?","mv_chf","C",01,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"16","Mensagem 3         ?","mv_chg","C",01,0,0,"G","","mv_par16","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"17","Situa‡”es a Imp.   ?","mv_chh","C",05,0,0,"G","fSituacao","mv_par17","","A*FT","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"18","Categorias a Imp.  ?","mv_chi","C",10,0,0,"G","fCategoria","mv_par18","","ACDEGHIJMP**","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"19","Imprime Bases      ?","mv_chj","C",01,0,0,"C","","mv_par19","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"20","Dias/Mes Pagto     ?","mv_chk","C",05,0,0,"G","","mv_par20","01/03","2901","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"21","Caminho Arq.Texto  ?","mv_chl","C",30,0,0,"G","","mv_par21","C:\RELATO\","C:\RELATO\","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"22","Envia Desc CC      ?","mv_chm","C",01,0,0,"C","","mv_par22","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"23","Tipo Matricula     ?","mv_chn","C",01,0,0,"C","","mv_par23","Matricula","","","Chapa","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"24","CC ou Locacao      ?","mv_cho","C",01,0,0,"C","","mv_par24","CC","","","Locacao","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"25","Modo Impressão     ?","mv_chp","N",01,0,0,"C","","mv_par25","Diretorio","","","Email","","","Email+Criptografia","","","","","","","",""})
aadd(aRegs,{cPerg,"26","email              ?","mv_chq","C",60,0,0,"G","","mv_par26","","","","","","","","","","","","","","",""})

_fAtuSX1(padr(cPerg,len(SX1->x1_grupo)),aRegs)

Return NIL                 

*-----------------------------------*
Static function _fAtuSX1(cPerg,aRegs)
*-----------------------------------*
Local _nOrdSX1:=SX1->(indexord()),;
      _nRecSX1:=SX1->(recno()),_nVez,_lApaga:=.f.,_nPergs:=0

SX1->(dbsetorder(1))
// Verifica se o formato solicitado ainda e o mesmo, caso contrario, apaga e inclui tudo novamente
For _nVez:=1 to Len(aRegs)
	If SX1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
		_nPergs++
		If alltrim(SX1->x1_pergunt)<>alltrim(aRegs[_nVez,3])
			_lApaga:=.t.
			exit
		EndIf   
	EndIf   
next _nVez
If _nPergs <> len(aRegs) .or. _lApaga          
	SX1->(DbSeek(cPerg,.f.))
	While SX1->(!eof()) .and. SX1->X1_GRUPO == aRegs[1,1]
		If SX1->(RecLock(alias(),.f.))
			SX1->(dbdelete())
			SX1->(msunlock())
		Endif
		SX1->(dbskip(1))
	EndDo
Endif

For _nVez:=1 to Len(aRegs)
	If !SX1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
		SX1->(RecLock(alias(),.T.))
		SX1->X1_GRUPO  :=aRegs[_nVez,01]
		SX1->X1_ORDEM  :=aRegs[_nVez,02]
		SX1->X1_PERGUNT:=aRegs[_nVez,03]
		SX1->X1_VARIAVL:=aRegs[_nVez,04]
		SX1->X1_TIPO   :=aRegs[_nVez,05]
		SX1->X1_TAMANHO:=aRegs[_nVez,06]
		SX1->X1_DECIMAL:=aRegs[_nVez,07]
		SX1->X1_PRESEL :=aRegs[_nVez,08]
		SX1->X1_GSC    :=aRegs[_nVez,09]
		SX1->X1_VALID  :=aRegs[_nVez,10]
		SX1->X1_VAR01  :=aRegs[_nVez,11]
		SX1->X1_DEF01  :=aRegs[_nVez,12]
		SX1->X1_CNT01  :=aRegs[_nVez,13]
		SX1->X1_VAR02  :=aRegs[_nVez,14]
		SX1->X1_DEF02  :=aRegs[_nVez,15]
		SX1->X1_CNT02  :=aRegs[_nVez,16]
		SX1->X1_VAR03  :=aRegs[_nVez,17]
		SX1->X1_DEF03  :=aRegs[_nVez,18]
		SX1->X1_CNT03  :=aRegs[_nVez,19]
		SX1->X1_VAR04  :=aRegs[_nVez,20]
		SX1->X1_DEF04  :=aRegs[_nVez,21]
		SX1->X1_CNT04  :=aRegs[_nVez,22]
		SX1->X1_VAR05  :=aRegs[_nVez,23]
		SX1->X1_DEF05  :=aRegs[_nVez,24]
		SX1->X1_CNT05  :=aRegs[_nVez,25]
		SX1->X1_F3     :=aRegs[_nVez,26]
		If len(aRegs[_nVez])>26
	   		SX1->x1_picture:=aRegs[_nVez,27]
		Endif
		SX1->(MsUnlock())
	Endif
Next _nVez
SX1->(dbgoto(_nRecSX1))
SX1->(dbsetorder(_nOrdSX1))

Return                 

/* faz src 
array para ordenar na forma de provento, base , desconto  e depois como verba. pq 
nessa customizacao nao usa o padrao da siga < 400 < 700 > 700
jairo em 20/05/2010
*/
*---------------------------------------------*
Static Function FazSRD(aSrd,Esc,aCodFol,Semana)
*---------------------------------------------*
Local _cTpVb := ""

aSRD := {}       

If Esc = 1 .OR. Esc = 2
	dbSelectArea('SRD')
	If SRD->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cMesAno))
		While SRD->(!Eof()) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ == SRA->RA_FILIAL+SRA->RA_MAT+cMesAno
			If SRD->RD_SEMANA #Semana
				dbSkip()
				Loop
			Endif
			If (Esc == 1) .And. (SRD->RD_PD == aCodFol[7,1]) //-- Desconto de Adto.
				aadd( aSRD , {'2P', aCodFol[6,1] , recno() } )
			ElseIf (Esc == 1) .And. (SRD->RD_PD == aCodFol[12,1])
				aadd( aSRD , {'3D', aCodFol[9,1] , recno() } )
			ElseIf (Esc == 1) .And. (SRD->RD_PD == aCodFol[8,1])
				aadd( aSRD , {'2P', aCodFol[8,1] , recno() } )
			Else
				_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRD->RD_PD,"RV_TIPOCOD")
				If _cTpVb = "1"
					If (Esc #1) .Or. (Esc == 1 .And. PosSrv(SRD->RD_PD,Sra->Ra_Filial,'RV_ADIANTA') == 'S')

						aadd( aSRD , {'2P', SRD->RD_PD , recno() } )
					Endif
				ElseIf _cTpVb = "2"
					If (Esc #1) .Or. (Esc == 1 .And. PosSrv(SRD->RD_PD,Sra->Ra_Filial,'RV_ADIANTA') == 'S')
						aadd( aSRD , {'3D', SRD->RD_PD , recno() } )
					Endif
				ElseIf _cTpVb = "3"
					If (Esc #1 .AND. SFPD1(SRD->RD_PD)) .Or. (Esc == 1 .And. PosSrv(SRD->RD_PD,Sra->Ra_Filial,'RV_ADIANTA') == 'S') .AND. SFPD1(SRD->RD_PD)
						aadd( aSRD , {'4B', SFPD2(SRD->RD_PD) , recno() } )
					Endif
				Endif
			Endif
			dbSelectArea('SRD')
			dbSkip()
		EndDo
	end
ElseIf Esc = 3
	dbSelectArea('SRD')
	If SRD->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT+cMesAno))
	     // Monta matriz com valores
		While SRD->(!Eof()) .And. SRA->RA_FILIAL + SRA->RA_MAT+cMesAno == SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
			If SRD->RD_PD == aCodFol[22,1]
				aadd( aSRD , {'2P', SRD->RD_PD , recno() } )
			ElseIf SRD->RD_PD == aCodFol[172,1]
				aadd( aSRD , {'3D', SRD->RD_PD , recno() } )
			ElseIf SRD->RD_PD == aCodFol[108,1] .Or. SRD->RD_PD == aCodFol[109,1] .Or. SRD->RD_PD == aCodFol[173,1]
				aadd( aSRD , {'4B', SRD->RD_PD , recno() } )
			Endif
			
			dbSelectArea('SRD')
			dbSkip()
		EndDo
	end
ElseIf Esc = 4 //jjj
	dbSelectArea('SRD')
	SRD->(dbSetOrder(2))
	If SRD->(dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT+cMesAno))
		While SRD->(!Eof()) .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT+cMesAno == SRD->RD_FILIAL+SRD->RD_CC+SRD->RD_MAT+SRD->RD_DATARQ
			_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRD->RD_PD,"RV_TIPOCOD")
			If _cTpVb = "1"
				aadd( aSRD , {'2P', SRD->RD_PD , recno() } )
			ElseIf _cTpVb = "2"
				aadd( aSRD , {'3D', SRD->RD_PD , recno() } )
			ElseIf _cTpVb = "3" .AND. SFPD1(SRD->RD_PD)
				aadd( aSRD , {'4B', SFPD2(SRD->RD_PD) , recno() } )
			Endif
			
			dbSkip()
		EndDo
	Endif
ElseIf Esc = 5
	dbSelectArea('SRD')
	SRD->(dbSetOrder(1))
	If SRD->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT+cMesAno ))
		While SRD->(!Eof()) .And. SRA->RA_FILIAL + SRA->RA_MAT+cMesAno == SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
			If Semana #'99'
				If SRD->RD_SEMANA #Semana
					dbSkip()
					Loop
				Endif
			Endif
			_cTpVb := POSICIONE("SRV",1,XFILIAL("SRV")+SRD->RD_PD,"RV_TIPOCOD")
			If _cTpVb = "1"
				aadd( aSRD , {'2P', SRD->RD_PD , recno() } )
			ElseIf _cTpVB = "2"
				aadd( aSRD , {'3D', SRD->RD_PD , recno() } )
			ElseIf _cTpVb = "3" .AND. SFPD1(SRD->RD_PD)
				aadd( aSRD , {'4B', SRD->RD_PD , recno() } )
			Endif
			dbskip()
		EndDo
	Endif
End

aSort(aSRD,,, { |x,y| y[1]+y[2] > x[1]+x[2]} )

Return()

/*
Funcao      : SendMail
Parametros  : 
Retorno     : 
Objetivos   : Função de envio de email.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------*
Static Function SendMail(cArqTxt,cEmail,lCript)
*---------------------------------------------*
Local cChave	:= ALLTRIM(DtoS(Date())+STRTRAN(TIME(),":","") )
Local cPass		:= STRZERO(Randomize(0,1000000),6)//0 a 999999
Local cSubject	:= ""
Local cTexto	:= ""

Private oMessage

cMailUser	:= GETMV("MV_RELAUSR")//Conta utilizada p/envio do email
cMailConta	:= GETMV("MV_EMCONTA")//Conta utilizada p/envio do email
cMailServer	:= GETMV("MV_RELSERV")//Server 
cMailSenha	:= GETMV("MV_EMSENHA")

//Envio do Email com a Folha de pagamento
cSubject := "Folha de pagamentos - ["+cChave+"]

cTexto := "<p>Prezados,<br>"
cTexto += "</p>
cTexto += "<p>Informamos a emissão da Folha de Pagamentos '"+cMesAno+"'(AAAAMM), referencia: "+cChave+".</p>
cTexto += "<br>
cTexto += "<p>Em caso de dúvidas, favor entrar em contato com o Departamento de RH.</p>
cTexto += "<br>
If lCript
	cTexto += "<p>Em breve será enviado um novo e-mail com a senha do arquivo anexado.</p>
Endif
cTexto += "</p>
cTexto += "<br>Atenciosamente,</p>

oMessage			:= TMailMessage():New()
oMessage:Clear()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cMailConta
oMessage:cTo		:= cEmail
oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"//responder para...
If Right(GetBuild(),8) >= '20150508'
	oMessage:nXPriority := 2//Prioridade do email(1 maxima...5 minima - 3 default)
EndIf
oMessage:cSubject	:= cSubject
oMessage:cBody		:= cTexto

If lCript       
	cArq2Zip := STRTRAN(cArqTxt,".TXT",".ZIP")
	compacta(cArqTxt,cArq2Zip,.T.,cPass)
	cArqTxt := cArq2Zip
Endif

xRet := oMessage:AttachFile(cArqTxt)
If xRet < 0
	ALERT("Could not attach file!" )
	Return
Endif
 
xRet :=SendMain()
FErase(cArqTxt)
If !xRet
	Return
Endif

If lCript       
	cSubject := "Senha de folha de pagamentos - ["+cChave+"]

	cTexto := "<p>Prezados,<br>"
	cTexto += "</p>
	cTexto += "<p>Informamos a emissão da senha do arquivo de Folha de Pagamentos '"+cMesAno+"'(AAAAMM), referencia: "+cChave+".</p>
	cTexto += "<br>
	cTexto += "<p>Senha:"+cPass+"</p>
	cTexto += "<br>
	cTexto += "<p>Em caso de dúvidas, favor entrar em contato com o Departamento de RH.</p>
	cTexto += "<br>
	cTexto += "</p>
	cTexto += "<br>Atenciosamente,</p>

	oMessage			:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate		:= cValToChar(Date())
	oMessage:cFrom		:= cMailConta
	oMessage:cTo		:= cEmail
	oMessage:cBCC 		:= "log.sistemas@hlb.com.br, rh.holerites@hlb.com.br"
	oMessage:cReplyTo	:= "rh.holerites@hlb.com.br"//responder para...
	oMessage:cSubject	:= cSubject
	oMessage:cBody		:= cTexto

	SendMain()
Endif

Return .T.

/*
Funcao      : SendMain
Parametros  : 
Retorno     : 
Objetivos   : Função principal de envio de email.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function SendMain()
*------------------------*
Local lEnvioOK := .T.

oServer	:= tMailManager():New()
oServer:SetUseTLS(.T.)
//AOA - 19/10/2017 - Alterado validação para envio de e-mail
If AT(":", cMailServer) > 0
	cMailServer := SUBSTR(cMailServer, 1, AT(":", cMailServer) - 1)
EndIf
xRet := oServer:Init( "", cMailServer, cMailUser, cMailSenha, 0, 587 )
If xRet != 0
	Alert( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
Endif
xRet := oServer:SetSMTPTimeout( 60 )
If xRet != 0
    Alert( "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout ) ) 
	lEnvioOK := .F.
Endif
xRet := oServer:SMTPConnect()
If xRet <> 0
	Alert( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
Endif
xRet := oServer:SmtpAuth( cMailUser, cMailSenha )
If xRet <> 0
    Alert( "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
    lEnvioOK := .F.
    oServer:SMTPDisconnect()
EndIf      
//Envio
xRet := oMessage:Send( oServer )
If xRet <> 0
    Alert( "Could not send message: " + oServer:GetErrorString( xRet ) )
    lEnvioOK := .F.
Endif
//Encerra
xRet := oServer:SMTPDisconnect()
If xRet <> 0
    Alert("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
Endif

Return lEnvioOk

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri,cSenha)
*---------------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

If lApagaOri
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ '+IIF(!EMPTY(cSenha),"-hp"+cSenha,"")+' "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Else
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ '+IIF(!EMPTY(cSenha),"-hp"+cSenha,"")+' "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Endif
lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)