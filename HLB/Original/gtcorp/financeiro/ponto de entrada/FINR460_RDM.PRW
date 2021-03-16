#include "rwmake.ch"

/*
Funcao      : FINR460 
Parametros  : 
Retorno     : .T.
Objetivos   : Ponto de entrada na impressão do cheque especial, para imprimir no verso do cheque.
Autor       : 
Data/Hora   : 17/04/2001
TDN         :   O ponto de entrada FINR460 será executado após imprimir a frente do cheque. 
			:	Poderá ser utilizado para imprimir o verso do cheque.
			:	Cada modelo de impressora espera que para imprimir o verso do cheque, seja enviado um script diferenciado. 
			:	Verifique no manual de referência de comandos da impressora, os dados para impressão do verso e envie-os para serem interpretados de maneira correta. 
			:	As impressoras Bematech utilizam outro ponto de entrada para a impressão do Verso. (DP10VERS).
Revisão     : Matheus Massarotto
Data/Hora   : 31/08/2012
Módulo      : Financeiro.
*/

*---------------------*
User Function FINR460()
*---------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSAVALIA,CSAVIND,CCOR,_NHDLL,NOPC,CVALOR")

cSavAlia := Alias()              // Salva Alias
cSavInd  := IndexOrd()           // Salva Indices

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento das Notas Fiscais Canceladas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cCor  := "B/BG"

// _nHdll := PARAMIXB

_nHdll :=0 //alterado no dia 01/02/00
IF MsgYesNo("Imprime Verso do Cheque ? ")
	nOpc := 1
Else
	nOpc := 2
Endif

If nOpc==1
	
	//
	
	cBco  := ""
	cAge  := ""
	cCon  := ""
	cFav  := ""
	cHist := ""
	cDoct := ""
	cCc   := ""
	
	dbSelectArea("SE5")
	dbSetOrder(1)
	DbSeek(SEF->(EF_FILIAL+DTOS(EF_DATA)+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM),.F.)
	
	nRec := Recno()
	
	DbSelectArea("SEF")
	otitulo := SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)
	
	DbSelectArea("SA2")
	DbSetorder(1)
	
	// Procura pela filial em branco mais o codigo do forn. e loja
	if .not. EMPTY(SE5->E5_CLIFOR)
		SA2->(DbSeek(xfilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,.F.))
	else
		SA2->(DbSeek(xfilial("SA2")+SEF->EF_FORNECE+SEF->EF_LOJA,.F.))
	endif
	
	DbSelectArea("SE2")
	DbSetorder(1)
	DbSeek(xfilial('SE2')+otitulo,.T.)
	cBco  := SEF->EF_BANCO
	cAge  := SEF->EF_AGENCIA
	cCon  := SEF->EF_CONTA
	cDoct := 'Pref: '+SE2->E2_PREFIXO+' Tit '+SE2->E2_NUM+' Parc '+SE2->E2_PARCELA+' Tipo '+SE2->E2_TIPO
	cHist := SEF->EF_HIST
	cFav  := SEF->EF_BENEF
	//	if .not. empty(SE5->E5_CLIFOR)
	cCc  := 'Bco: '+left(SA2->A2_BANCO,3) + ' Ag.: '+SA2->A2_AGENCIA+' Conta: '+SA2->A2_NUMCON
	//	endif
	dbGoto(nRec)
	
	MsWrite(_nHdll,"                       "+Replic(CHR(10)+CHR(13),5))
	//		MsWrite(_nHdll,"                       "+Replic" "(CHR(10)+CHR(13),5))
	//		MsWrite(_nHdll,"                       "+"   Banco: "+cBco+"   Agencia: "+cAge+"    Conta: "+cCon+Replic(CHR(10)+CHR(13),2))
	MsWrite(_nHdll,"                       "+"   Favorecido   : "+cFav+CHR(10)+CHR(13))
	MsWrite(_nHdll,"                       "+Replic(CHR(10)+CHR(13),1))
	MsWrite(_nHdll,"                       "+"   Historico    : "+cHist+CHR(10)+CHR(13))
	MsWrite(_nHdll,"                       "+Replic(CHR(10)+CHR(13),1))
	MsWrite(_nHdll,"                       "+"   Documento    : "+cDoct+CHR(10)+CHR(13))
	MsWrite(_nHdll,"                       "+Replic(CHR(10)+CHR(13),1))
	MsWrite(_nHdll,"                       "+"   Bco.Deposito : "+cCc+CHR(10)+CHR(13))
	MsWrite(_nHdll,CHR(12)+CHR(26)) // DESCARREGA O BUFFER E EJETA O CHEQUE
	//		MsClosePort(_nHdll) // Fecha a porta
	//	#ENDIF
	
	
	
	/*/
	cValor:= ALLTRIM(STR(SEF->EF_VALOR,17,2))
	MsWrite(_nHdll,"                    "+Replic(CHR(10)+CHR(13),5))
	MsWrite(_nHdll,"                    "+"ESTE CHEQUE DESTINA-SE A:"+CHR(10)+CHR(13))
	MsWrite(_nHdll,"                    "+SEF->EF_HIST+CHR(10)+CHR(13))
	MsWrite(_nHdll,"                    "+"NO VALOR DE R$ "+cValor+CHR(10)+CHR(13))
	MsWrite(_nHdll,"                    "+"A: "+SEF->EF_BENEF+Replic(CHR(10)+CHR(13),7))
	//    MsWrite(_nHdll,"                    "+Replic("_",42) +CHR(10)+CHR(13))
	//    MsWrite(_nHdll,"                     "+ALLTRIM(SUBSTR(SM0->M0_NOMECOM,1,40))+Replic(CHR(10)+CHR(13),2))
	MsWrite(_nHdll,CHR(12)+CHR(26)) //  descarrega o buffers e libera da impressora
	MsClosePort(_nHdll)  // fecha a porta
	/*/
	
Endif

Set Device to Screen
dbSelectArea(cSavAlia)
dbSetOrder(cSavInd)
// Substituido pelo assistente de conversao do AP5 IDE em 17/04/01 ==> __Return(.T.)
Return(.T.)
