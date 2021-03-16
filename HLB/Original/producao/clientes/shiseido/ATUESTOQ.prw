#include "rwmake.ch"
#include 'MsOle.ch'
#include 'PROTDEF.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATUESTOQ  º Autor ³ Fabio F Sousa      º Data ³  15/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza estoque, utilizando apenas controles logicos:     º±±
±±º          ³ entrada e saida, GERAR quantidade.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESTOQUE/CUSTOS                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   


/*
Funcao      : ATUESTOQ
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualiza estoque, utilizando apenas controles logicos, entrada e saida, GERAR quantidade
Autor     	: Fabio F Sousa                               
Data     	: 15/02/03                      
Obs         : parte comentada é para gerar relatório de sistema 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Estoque. 
Cliente     : Shiseido
*/

*-----------------------*
 User Function ATUESTOQ
*-----------------------*

//cPerg := "AEST01"

//ValidPerg()
//Pergunte(cPerg,.F.)

@ 96,012 TO 250,400 DIALOG oDlg TITLE OemToAnsi("Atualiza Estoque e saldo de produtos")
@ 08,005 TO 048,190
@ 18,010 SAY OemToAnsi("Esta rotina atualiza saldo em estoque de produtos") Size 170,008

//@ 56,100 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.T.)
// @ 56,130 BMPBUTTON TYPE 1 ACTION ATUESTPROD()
@ 56,130 BMPBUTTON TYPE 1 ACTION PROCESSA( {|| ATUESTPROD() },"Atualizando estoque B2_QATU ...")

@ 56,160 BMPBUTTON TYPE 2 ACTION Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED

//PROCESSA( {|| _fAbreArq() },"Abrindo Arquivo de Fornecedores...")
//PROCESSA( {|| _fImpSA2_DIM() },"Processando Arquivo...")
//Return()


CLOSE

Return(nil)

Static Function ATUESTPROD

Private cString := "SB2"

dDataIni   := GETMV("MV_ULMES")
dDataFim   := DDATABASE
nSaldoAtu  := 0
nSaldoSoma := 0
nSaldoTira := 0

dbSelectArea("SF4")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

dbGoTop()

ProcRegua(RecCount())

////dbSeek("01" + "11104",.t.)  // xFilial("SB2")+"11104           " + "05")    // SB2->B2_COD+SB2->B2_LOCAL)

Do While !EOF()
	
	IncProc("Calculando saldo do produto: " + SB2->B2_COD + " local: " + SB2->B2_LOCAL)
	// HFP - PEGA SALDO B9 PARA QFIM ANTES DOS CALCULOS
	DBSELECTAREA("SB9")
	DBSETORDER(1)
	IF dbSeek(xFilial("SB9")+SB2->B2_COD+SB2->B2_LOCAL+DTOS(dDATAINI)	)
		RecLock("SB2",.F.)
		SB2->B2_QFIM := SB9->B9_QINI
		MsUnlock()
	ENDIF
	///// HFP
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	
	
	nSaldoAtu := SB2->B2_QFIM
	nSaldoSoma := 0
	nSaldoTira := 0
	
	//Processar Itens de NF de Entrada...
	dbSelectArea("SD1")
	dbSetOrder(7)
	
	dbSeek(xFilial("SD1")+SB2->B2_COD+SB2->B2_LOCAL)
	
	Do While !Eof() .And. SD1->D1_COD == SB2->B2_COD .And. SD1->D1_LOCAL == SB2->B2_LOCAL
		//selecionando periodo
		If !(SD1->D1_EMISSAO > dDataIni)
			dbSkip()
			Loop
		EndIf
		
		If SF4->(dbSeek(xFilial('SF4')+SD1->D1_TES, .F.))
			IF SF4->F4_ESTOQUE == 'S'
				//Atualiaza estoque...
				If SubStr(SD1->D1_TES,1,1) > "5"
					nSaldoTira := nSaldoTira + SD1->D1_QUANT
				Else
					nSaldoSoma := nSaldoSoma + SD1->D1_QUANT
				EndIf
			EndIf
		EndIf
		
		dbSelectArea("SD1")
		dbSkip()
		
	EndDo
	
	//Processar Itens de NF de Saida...
	dbSelectArea("SD2")
	dbSetOrder(6)
	
	dbSeek(xFilial("SD2")+SB2->B2_COD+SB2->B2_LOCAL)
	
	Do While !Eof() .And. SD2->D2_COD == SB2->B2_COD .And. SD2->D2_LOCAL == SB2->B2_LOCAL
		//selecionando periodo
		If !(SD2->D2_EMISSAO > dDataIni)
			dbSkip()
			Loop
		EndIf
		
		If SF4->(dbSeek(xFilial('SF4')+SD2->D2_TES, .F.))
			IF SF4->F4_ESTOQUE == 'S'
				//Atualiaza estoque...
				If SubStr(SD2->D2_TES,1,1) > "5"
					nSaldoTira := nSaldoTira + SD2->D2_QUANT
				Else
					nSaldoSoma := nSaldoSoma + SD2->D2_QUANT
				EndIf
			EndIf
		EndIf
		
		dbSelectArea("SD2")
		dbSkip()
		
	EndDo
	
	//Processar movimentacoes internas...
	dbSelectArea("SD3")
	dbSetOrder(7)
	
	dbSeek(xFilial("SD3")+SB2->B2_COD+SB2->B2_LOCAL)
	
	Do While !Eof() .And. SD3->D3_COD == SB2->B2_COD .And. SD3->D3_LOCAL == SB2->B2_LOCAL
		//selecionando periodo
		If !(SD3->D3_EMISSAO > dDataIni)
			dbSkip()
			Loop
		EndIf
		
		//Atualiaza estoque...
		If SubStr(SD3->D3_TM,1,1) > "5"
			nSaldoTira := nSaldoTira + SD3->D3_QUANT
		Else
			nSaldoSoma := nSaldoSoma + SD3->D3_QUANT
		EndIf
		
		dbSelectArea("SD3")
		dbSkip()
		
	EndDo
	
	//gravar no arquivo processamento e efetua calculo...
	nSaldoAtu := nSaldoAtu + nSaldoSoma
	nSaldoAtu := nSaldoAtu - nSaldoTira
	
	RecLock("SB2",.F.)
	SB2->B2_QATU := nSaldoAtu
	MsUnlock()
	
	dbSelectArea("SB2")
	dbSkip()
	
EndDo

Return

/*/
//Cria parametro --> SIGAADV\SX1
Static Function ValidPerg()
Local _sAlias := GetArea(),aREGS:={}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,6)

aAdd(aRegs,{cPerg,"01","Produto inicial ?   ","","","mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"02","Produto final   ?   ","","","mv_ch2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"03","Local inicial   ?   ","","","mv_ch3","C",02,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Local final     ?   ","","","mv_ch4","C",02,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(_sAlias)

Return
/*/
