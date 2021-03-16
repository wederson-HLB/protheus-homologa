#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"

/*
Funcao      : GTCORP04
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relatório de clientes incluídos com suas datas. Parametros data de/ data ate
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 07/03/2012    10:28
Módulo      : Faturamento
*/

/*
Funcao      : GTCORP04()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da rotina principal do relatório
Autor       : Matheus Massarotto
Data/Hora   : 07/03/2012
*/

User Function GTCORP04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Relatório de Clientes"
Local cPict          := ""
Local titulo       := "RELATORIO DE CLIENTES"
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "GTCORP04" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "GTCORP04" // Coloque aqui o nome do arquivo usado para impressao em disco

//Definição das perguntas.

PutSx1( "GTCORP04_P", "01", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
PutSx1( "GTCORP04_P", "02", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","" , "","","","MV_PAR02")
PutSx1( "GTCORP04_P", "03", "Gera Excel?:", "Gera Excel?", "Gera Excel?", "", "N",1,00,00,"C","" , "","","","MV_PAR03","Sim","","","","Não")

Private cPerg := "GTCORP04_P"
Private cString:="SA1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



If !Pergunte(cPerg,.T.)
	Return()
EndIf

If MV_PAR03==2
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	RptStatus({|| ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Else
	RptStatus({|| ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
EndIf

Return

Static Function ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin)

Local cQry1:=""
Local aDadTemp:={}
Local aDadTemp1:={}
Local aTotAno:=ARRAY(1,2)

cQry1 :=" SELECT A1_COD,A1_NOME,A1_CGC,A1_USERLGI FROM "+RETSQLNAME("SA1")+CRLF
cQry1 +=" WHERE D_E_L_E_T_='' AND A1_FILIAL='"+xFilial("SA1")+"'

If tcsqlexec(cQry1)<0
	Alert("Ocorreu um problema na busca das informações!!")
	return
EndIf

if select("TRBA1")>0
	TRBA1->(DbCloseArea())
endif

//memowrite("C:\Grant Thorntom\Querys\cQry2.sql",cQry1)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBA1",.T.,.T.)

//#################### REGUA CABEÇALHO ###################\\

//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230
//	  12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//    XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXX   XXXXXXXXXX

Cabec1 := 	" CODIGO   NOME                                       CPF/CNPJ         DATA       "


AADD(aDadTemp,{"Codigo","C",6,0})
AADD(aDadTemp,{"Nome","C",40,0})
AADD(aDadTemp,{"Cgc","C",14,0})
AADD(aDadTemp,{"DData","D",10,0})

AADD(aDadTemp1,{"Codigo","C",6,0})
AADD(aDadTemp1,{"Nome","C",40,0})
AADD(aDadTemp1,{"Cgc","C",14,0})
AADD(aDadTemp1,{"DData","D",10,0})

//Criando nome temporario
cNome := CriaTrab(aDadTemp,.t.)
dbUseArea(.T.,,cNome,"DADXLS1",.F.,.F.)

cIndex:=CriaTrab(Nil,.F.)
IndRegua("DADXLS1",cIndex,"DData",,,"Selecionando Registro...")

DbSelectArea("DADXLS1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


//Criando nome temporario1
cNome1 := CriaTrab(aDadTemp1,.t.)
dbUseArea(.T.,,cNome1,"DADXLS2",.F.,.F.)

cIndex1:=CriaTrab(Nil,.F.)
IndRegua("DADXLS2",cIndex1,"DData",,,"Selecionando Registro...")

DbSelectArea("DADXLS2")
DbSetIndex(cIndex1+OrdBagExt())
DbSetOrder(1)

While TRBA1->(!EOF())
	
	Reclock("DADXLS1",.T.)
	DADXLS1->Codigo:=TRBA1->A1_COD
	DADXLS1->Nome:=TRBA1->A1_Nome
	DADXLS1->Cgc:=TRBA1->A1_CGC
	DADXLS1->DData:=CtoD("01/01/96","DDMMYY")+Load2in4(SubStr( EMBARALHA(TRBA1->A1_USERLGI,1),16))
	MsUnlock()
	
	
	if aScan( aTotAno, { |x| x[1] == YEAR(CtoD("01/01/96","DDMMYY")+Load2in4(SubStr( EMBARALHA(TRBA1->A1_USERLGI,1) ,16))) } ) > 0
		aTotAno[aScan( aTotAno, { |x| x[1] == YEAR(CtoD("01/01/96","DDMMYY")+Load2in4(SubStr( EMBARALHA(TRBA1->A1_USERLGI,1) ,16))) } )][2]+=1
	else
		AADD(aTotAno,{YEAR(CtoD("01/01/96","DDMMYY")+Load2in4(SubStr( EMBARALHA(TRBA1->A1_USERLGI,1) ,16))),1})
	endif
	
	TRBA1->(DbSkip())
Enddo

DbSelectArea("DADXLS1")
DADXLS1->(DBGotop())

SetRegua(RecCount())

/*   cStr     := TRBA1->A1_USERLGI
cNovaStr := Embaralha(cStr, 1)
nDias    := Load2in4(SubStr(cNovaStr,16))
dData    := CtoD("01/01/96","DDMMYY") + nDias
dData    := DtoS(dData)

DtoS( CtoD("01/01/96","DDMMYY")+Load2in4(SubStr( EMBARALHA(TRBA1->A1_USERLGI,1) ,16)) )
*/

While DADXLS1->(!EOF())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR03==2
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
	endif
	if !(DADXLS1->DData >= MV_PAR01 .AND. DADXLS1->DData <= MV_PAR02)
		DADXLS1->(DbSkip())
		Loop
	endif
	
	if MV_PAR03==2//não gerar excel
		
		@nLin,01  PSAY DADXLS1->Codigo
		@nLin,10  PSAY DADXLS1->Nome
		@nLin,53  PSAY DADXLS1->Cgc
		@nLin,70  PSAY DTOC(DADXLS1->DData)
		
		nLin := nLin + 1 // Avanca a linha de impressao
	else
		Reclock("DADXLS2",.T.)
		DADXLS2->Codigo:=DADXLS1->Codigo
		DADXLS2->Nome:=DADXLS1->Nome
		DADXLS2->Cgc:=DADXLS1->Cgc
		DADXLS2->DData:=DADXLS1->DData
		MsUnlock()
	endif
	
	DADXLS1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

ntotGeral:=0
//nContA:=0
//nFimJ:=len(aTotAno)

ADEL(aTotAno,1)
ASIZE(aTotAno,Len(aTotAno)-1)
/*
for j:=1 to nFimJ
if aTotAno[j][1]==nil
ADEL(aTotAno,j)
ASIZE(aTotAno,Len(aTotAno)-1)
nFimJ-=1
endif
next
*/
aTotAnoAux:=aSort(aTotAno,,,{|x,y| x[1] < y[1] })

if MV_PAR03==2
	
	nLin := nLin + 1
	@nLin,01 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	
	nLin := nLin + 1
	@nLin,01  PSAY "Ano"
	@nLin,12  PSAY "Total"
	@nLin,24  PSAY "Total Acumulado"
	
	for i:=1 to len(aTotAnoAux)
		
		if empty(aTotAnoAux[i][1])
			loop
		endif
		
		nLin := nLin + 1
		
		//Acumula total
		ntotGeral+=aTotAnoAux[i][2]
		
		@nLin,01  PSAY alltrim(cvaltochar(aTotAnoAux[i][1]))
		@nLin,12  PSAY alltrim(cvaltochar(aTotAnoAux[i][2]))
		@nLin,24  PSAY alltrim(cvaltochar(ntotGeral))
		
	next
	
	nLin := nLin + 1
	@nLin,01  PSAY "Total"
	@nLin,12  PSAY alltrim(cvaltochar(ntotGeral))
	@nLin,24  PSAY alltrim(cvaltochar(ntotGeral))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	
	MS_FLUSH()
else
	Reclock("DADXLS2",.T.)
	MSUnlock()
	
	ntotGeral:=0
	Reclock("DADXLS2",.T.)
	DADXLS2->Codigo:="Ano"
	DADXLS2->Nome:="Total"
	DADXLS2->Cgc:="Total Acumulado"
	MsUnlock()
	
	for i:=1 to len(aTotAnoAux)
		
		if empty(aTotAnoAux[i][1])
			loop
		endif
		
		//Acumula total
		ntotGeral+=aTotAnoAux[i][2]
		
		Reclock("DADXLS2",.T.)
		DADXLS2->Codigo:=alltrim(cvaltochar(aTotAnoAux[i][1]))
		DADXLS2->Nome:=alltrim(cvaltochar(aTotAnoAux[i][2]))
		DADXLS2->Cgc:=alltrim(cvaltochar(ntotGeral))
		MsUnlock()
		
	next
	
	Reclock("DADXLS2",.T.)
	DADXLS2->Codigo:="Total"
	DADXLS2->Nome:=alltrim(cvaltochar(ntotGeral))
	DADXLS2->Cgc:=alltrim(cvaltochar(ntotGeral))
	MsUnlock()
	
endif
DADXLS1->(DbCloseArea())
DADXLS2->(DbCloseArea())
TRBA1->(DBCloseArea())


//Se for para imprimir no excel
If MV_PAR03==1
	If !ApOleClient("MsExcel")
		MsgStop("Microsoft Excel nao instalado.")
		Return
	EndIf
	
	cArqOrig := "\"+CURDIR()+cNome1+".DBF"
	cPath     := AllTrim(GetTempPath())
	CpyS2T( cArqOrig , cPath, .T. )
	
	oExcelApp:=MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+cNome1+".DBF")
	oExcelApp:SetVisible(.T.)
	
	sleep(05)
EndIf

//Apaga tabela temporária
Erase &cNome+".DBF"
Erase &cNome1+".DBF"

Return
