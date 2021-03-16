#INCLUDE "MATR460.CH" 
#define TT	Chr(254)+Chr(254)			// Substituido p/ "TT" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ REDEST08  ³ Autor ³ XIS INFORMATICA       ³ Data ³ 22.04.04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio do Inventario, Registro Modelo P7                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : REDEST08
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Relatorio do Inventario, Registro Modelo P7
Autor     	: XIS INFORMATICA
Data     	: 22/04/04  
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Estoque
Cliente     : Okuma
*/ 

*------------------------*
 USER Function REDEST08()
*------------------------*  

Local	wnrel
Local	titulo:=STR0001,;	//"Registro de Invent rio - Modelo P7"
cDesc1:=STR0002,;	//"Emiss„o do Registro de Invent rio.Os Valores Totais serao impressos conforme Modelo Legal"
cDesc2:=STR0003,;	//"Nota:  Saldo em Poder de Terceiros somente em posi‡„o atual,"
cDesc3:=STR0004	//"       Saldo em Processo somente em requisi‡”es manuais."
Local cString:="SB1",;
NomeProg:="REDEST08"
Local aSave:={Alias(),IndexOrd(),Recno()}
Local Tamanho:="G"
Local cArqTrc2
Local cCondicao1

Private aReturn:={STR0005,1,STR0006,2,2,1,"",1}	//"Zebrado"###"Administra‡„o"
//Private nLastKey:=0,cPerg:="MTR460",nTipo:=0
Private nLastKey:=0,cPerg:="REDE08",nTipo:=0
Private nDecVal := 2

VALIDPERG()
Pergunte(cPerg,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)


If nLastKey==27
	Return .T.
Endif
SetDefault(aReturn,cString)
If nLastKey==27
	Return .T.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Saldo em Processo (Sim) (Nao)                ³
//³ mv_par02     // Saldo em Poder 3§ (Sim) (Nao)                ³
//³ mv_par03     // Almox. de                                    ³
//³ mv_par04     // Almox. ate                                   ³
//³ mv_par05     // Produto de                                   ³
//³ mv_par06     // Produto ate                                  ³
//³ mv_par07     // Lista Produtos sem Movimentacao   (Sim)(Nao) ³
//³ mv_par08     // Lista Produtos com Saldo Negativo (Sim)(Nao) ³
//³ mv_par09     // Lista Produtos com Saldo Zerado   (Sim)(Nao) ³
//³ mv_par10     // Pagina Inicial                               ³
//³ mv_par11     // Quantidade de Paginas                        ³
//³ mv_par12     // Numero do Livro                              ³
//³ mv_par13     // Livro/Termos                                 ³
//³ mv_par14     // Data de Fechamento do Relatorio              ³
//³ mv_par15     // Quanto a Descricao (Normal) (Inclui Codigo)  ³
//³ mv_par16     // Lista Produtos com Custo Zero ?   (Sim)(Nao) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//VALIDPERG()
//Pergunte(cPerg,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe paramentros das perguntas                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lSaldProcess:=(mv_par01==1)
lSaldTerceir:=(mv_par02==1)
cAlmoxIni	:=mv_par03
cAlmoxFim	:=mv_par04
cProdIni		:=mv_par05
cProdFim		:=mv_par06
lListProdMov:=(mv_par07==1)
lListProdNeg:=(mv_par08==1)
lListProdZer:=(mv_par09==1)
nPagIni		:=mv_par10
nQtdPag		:=mv_par11
cNrLivro		:=mv_par12
lLivro		:=(mv_par13!=2)
dDtFech		:=mv_par14
lDescrNormal:=(mv_par15==1)
lListCustZer:=(mv_par16==1)

If lLivro
	RptStatus({|lEnd| R460Imp(@lEnd,wnRel,cString,Tamanho)},titulo)
Else
	RptStatus({|lEnd| R460Term(@lEnd,wnRel,cString,Tamanho)},titulo)
Endif

If aReturn[5]==1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(aSave[1])
dbSetOrder(aSave[2])
dbGoto(aSave[3])

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460LayOut³ Autor ³ XIS INFORMATICA       ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lay-Out do Modelo P7                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460LayOut()

Local aL:=Array(16)

aL[01]:=				  "+----------------------------------------------------------------------------------------------------------------------------------+"
aL[02]:=STR0007	//"|                                                     REGISTRO DE INVENTARIO                                                       |"
aL[03]:=				  "|                                                                                                                                  |"
aL[04]:=STR0008	//"| FIRMA:#########################################                                                                                  |"
aL[05]:=				  "|                                                                                                                                  |"
If cPaisLoc == "CHI"
	aL[06]:=STR0029	//"| INSC.EST.: ################   C.G.C.(MF): ################################                                                       |"
Else
	aL[06]:=STR0009	//"| INSC.EST.: ################   C.G.C.(MF): ################################                                                       |"
Endif
aL[07]:=				  "|                                                                                                                                  |"
aL[08]:=STR0010	//"| FOLHA: #######                ESTOQUES EXISTENTES EM: ##########                                                                 |"
aL[09]:=				  "|                                                                                                                                  |"
aL[10]:=				  "|----------------------------------------------------------------------------------------------------------------------------------|"
If ( cPaisLoc=="BRA" )
	aL[11]:=STR0025	//"|             |                                      |    |              |                        VALORES                          |"
	aL[12]:=STR0011	//"|CLASSIFICACAO|                                      |    |              |-------------------------------------+-------------------|"
	aL[13]:=STR0012	//"|    FISCAL   |     D I S C R I M I N A C A O        |UNID|  QUANTIDADE  |     UNITARIO     |     PARCIAL      |      TOTAL        |"
	aL[14]:=				  "|-------------+--------------------------------------+----+--------------+------------------+------------------+-------------------|"
	aL[15]:=				  "|#############| #####################################| ## |##############|##################|##################|###################|"
Else
	aL[11]:=STR0028//"|                                                    |    |              |                        VALORES                          |"
	aL[12]:=STR0026//"|                                                    |    |              |-------------------------------------+-------------------|"
	aL[13]:=STR0027//"|                   DESCRICAO                        |UNID|  QUANTIDADE  |     UNITARIO     |     PARCIAL      |      TOTAL        |"
	aL[14]:=			  "|----------------------------------------------------+----+--------------+------------------+------------------+-------------------|"
	aL[15]:=			  "| # ################################################ | ## |##############|##################|##################|###################|"
EndIf
aL[16]:=				  "+----------------------------------------------------------------------------------------------------------------------------------+"

//		 			      123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123
//    	            1         2         3         4         5         6         7         8         9         10        11        12        13
Return (aL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R460Imp  ³ Autor ³ XIS INFORMATICA       ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Modelo P7                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Imp(lEnd,wnRel,cString,Tamanho)
STATIC lCalcUni := NIL
Local cArqTemp,cIndTemp1,cIndTemp2,aArqTemp:={},aL:=R460LayOut()
Local nLin:=80,nPagina:=nPagIni,aTotal:={},lEmBranco:=.F.
Local nPos, lImpSit, lImpTipo, lImpResumo:=.F.
Local cPosIpi:="",aImp:={},nTotIpi:=0
Local cQuery := ''
Local cChave := ''
Private cIndSB6,nIndSB6

lCalcUni := If(lCalcUni == NIL, ExistBlock("A460UNIT"),lCalcUni)

If lSaldTerceir
	dbSelectArea("SB6")
	cIndSB6:=Substr(CriaTrab(NIL,.F.),1,7)+"T"
	#IFDEF TOP
		cChave := "B6_FILIAL+B6_PRODUTO+B6_LOCAL+B6_TIPO+B6_DTDIGIT"
		cQuery := 'DtoS(B6_DTDIGIT)<="'+DtoS(mv_par14)+'".And.B6_PRODUTO>="'+mv_par05+'".And.B6_PRODUTO<="'+mv_par06+'".And.B6_LOCAL>="'+ mv_par03+'".And.B6_LOCAL<="'+mv_par04+'"'
	#ELSE
		cChave := "B6_FILIAL+B6_PRODUTO+B6_LOCAL+B6_TIPO+DTOS(B6_DTDIGIT)"
		cQuery := 'DtoS(B6_DTDIGIT)<="'+DtoS(mv_par14)+'".And.B6_PRODUTO>="'+mv_par05+'".And.B6_PRODUTO<="'+mv_par06+'".And.B6_LOCAL>="'+ mv_par03+'".And.B6_LOCAL<="'+mv_par04+'"'
	#ENDIF
	IndRegua("SB6",cIndSB6,cChave,,cQuery,STR0013)		//"Selecionando Poder Terceiros..."
	nIndSB6:=RetIndex("SB6")
	#IFNDEF TOP
		dbSetIndex(cIndSB6+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndSB6 + 1)
	dbGoTop()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario                                                    ³
//³ SITUACAO:1=ESTOQUE,2=PROCESSO,3=SEM SALDO,4=DE TERCEIROS,5=EM TERCEIROS    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aArqTemp,{"SITUACAO"	,"C",1,0})
AADD(aArqTemp,{"TIPO"		,"C",2,0})
AADD(aArqTemp,{"POSIPI"		,"C",10,0})
AADD(aArqTemp,{"PRODUTO"	,"C",15,0})
AADD(aArqTemp,{"DESCRICAO"	,"C",35,0})
AADD(aArqTemp,{"UM"			,"C",2,0})
// Pega o numero de decimais usado no SX3
aTam:=TamSX3("B2_QFIM")
AADD(aArqTemp,{"QUANTIDADE","N",14,aTam[2]})
aTam:=TamSX3("B2_CM1")
nDecVal := aTam[2]
AADD(aArqTemp,{"VALOR_UNIT","N",21,aTam[2]})
AADD(aArqTemp,{"TOTAL"		,"N",21,2})
cArqTemp:=CriaTrab(aArqTemp)
cIndTemp1:=Substr(CriaTrab(NIL,.F.),1,7)+"1"
cIndTemp2:=Substr(CriaTrab(NIL,.F.),1,7)+"2"
dbUseArea(.T.,,cArqTemp,cArqTemp,.T.,.F.)
IndRegua(cArqTemp,cIndTemp1,"SITUACAO+TIPO+POSIPI+PRODUTO",,,STR0014)		//"Indice Tempor rio..."
IndRegua(cArqTemp,cIndTemp2,"PRODUTO+SITUACAO",,,STR0014)			//"Indice Tempor rio..."
Set Cursor Off
DbClearIndex()
DbSetIndex(cIndTemp1+OrdBagExt())
DbSetIndex(cIndTemp2+OrdBagExt())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta Arquivo de Trabalho                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSeek(xFilial() + mv_par05, .T.)
SetRegua(LastRec())

While !lEnd.and.!eof().And.xFilial()==B1_FILIAL
	IncRegua()
	If ! Empty(mv_par06) .And. SB1->B1_P_COD > mv_par06
		Exit
	Endif
	If Interrupcao(@lEnd)
		Exit
	Endif
	If !R460AvalProd(SB1->B1_P_COD)
		dbSkip()
		Loop
	Endif
	R460EmEstoque(@lEnd,cArqTemp)		// Saldos em Estoque
	R460Terceiros(@lEnd,cArqTemp,"4") // Saldos de Terceiros
	R460Terceiros(@lEnd,cArqTemp,"5") // Saldos em Terceiros
	If lEnd
		Exit
	Endif
	dbSelectArea("SB1")
	dbSkip()
End

R460EmProcesso(@lEnd,cArqTemp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Modelo P7                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTemp)
dbSetOrder(1)
dbGotop()
SetRegua(LastRec())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Flags de Impressao                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSitAnt	:="X"
aSituacao:={STR0015,STR0016,STR0017,STR0018,STR0019}		//" EM ESTOQUE "###" EM PROCESSO "###" SEM MOVIMENTACAO "###" DE TERCEIROS "###" EM TERCEIROS "
cTipoAnt:="XX"

While !Eof()
	
	nLin := 80
	cSitAnt := SITUACAO
	lImpSit := .T.
	
	While !Eof() .And. cSitAnt == SITUACAO
		
		cTipoAnt := TIPO
		lImpTipo := .T.
		
		While !Eof() .And. cSitAnt+cTipoAnt == SITUACAO+TIPO
			
			cPosIpi:=POSIPI
			nTotIpi:=0
			
			While !Eof() .And. cSitAnt+cTipoAnt+cPosIpi==SITUACAO+TIPO+POSIPI
				IncRegua()
				If Interrupcao(@lEnd)
					Exit
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Controla impressao de Produtos com saldo negativo ou zerado  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (!lListProdNeg.and.QUANTIDADE<0).or.(!lListProdZer.and.QUANTIDADE==0).Or.(!lListCustZer.And.TOTAL==0)
					dbSkip()
					Loop
				Else
					nTotIpi+=TOTAL
					R460Acumula(aTotal)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa array com itens de impressao de acordo com MV_PAR15  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If lDescrNormal
					aImp:={Alltrim(POSIPI),;
					DESCRICAO,;
					UM,;
					Transform(QUANTIDADE,PesqPict("SB2", "B2_QFIM",14)),;
					Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18)),;
					Transform(TOTAL,"@E 999,999,999,999.99" ),;
					Nil}
				Else
					aImp:={Alltrim(POSIPI),;
					Padr(Alltrim(PRODUTO)+" - "+DESCRICAO,35),;
					UM,;
					Transform(QUANTIDADE,PesqPict("SB2", "B2_QFIM",14)),;
	                Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18)),;
					Transform(TOTAL,"@E 999,999,999,999.99"),;
					Nil}
				Endif
				dbSelectArea(cArqTemp)
				dbSkip()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Salta registros Zerados ou Negativos Conforme Parametros        ³
				//³ Necessario Ajustar Posicao p/ Totalizacao de Grupos (POSIPI)    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While !Eof() .And. ((!lListProdNeg.and.QUANTIDADE<0).or.(!lListProdZer.and.QUANTIDADE==0).Or.(!lListCustZer.And.TOTAL==0))
					dbSkip()
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se imprime total por POSIPI.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cSitAnt+cTipoAnt+cPosIpi==SITUACAO+TIPO+POSIPI)
					aImp[07] := Transform(nTotIPI,"@E 999,999,999,999.99")
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime cabecalho                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nLin>55
					R460Cabec(@nLin,@nPagina)
				Endif
				
				If lImpSit
					FmtLin({"",Padc(aSituacao[Val(cSitAnt)],35,"*"),"","","","",""},aL[15],,,@nLin)
					lImpSit := .F.
				Endif
				
				If lImpTipo
					SX5->(dbSeek(xFilial()+"02"+cTipoAnt))
					FmtLin(Array(7),aL[15],,,@nLin)
					FmtLin({"",Padc(" "+Trim(X5Descri())+" ",35,"*"),"","","","",""},aL[15],,,@nLin)
					FmtLin(Array(7),aL[15],,,@nLin)
					lImpTipo := .F.
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime linhas de detalhe de acordo com parametro (mv_par15) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FmtLin(aImp,aL[15],,,@nLin)
				
				If nLin>=55
					R460EmBranco(@nLin)
				Endif
			End
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao de Totais                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := Ascan(aTotal,{|x|x[1]==cSitAnt.and.x[2]==cTipoAnt})
		If nPos # 0
			R460Total(@nLin,aTotal,cSitAnt,cTipoAnt,aSituacao)
		Endif
	End
	nPos := Ascan(aTotal,{|x|x[1]==cSitAnt.and.x[2]==TT})			// Eh um #define
	If nPos # 0
		R460Total(@nLin,aTotal,cSitAnt,TT,aSituacao)
		R460EmBranco(@nLin)
		lImpResumo:=.T.
	Endif
End

If lImpResumo
	R460Cabec(@nLin,@nPagina)
	R460Total(@nLin,aTotal,"T",TT,aSituacao)
	R460EmBranco(@nLin)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga Arquivos Temporarios                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTemp)
dbCloseArea()
Ferase(cArqTemp+".DBF")
Ferase(cIndTemp1+OrdBagExt())
Ferase(cIndTemp2+OrdBagExt())

If lSaldTerceir
	dbSelectArea("SB6")
	RetIndex("SB6")
	Set Filter to
	If File(cIndSB6 += OrdBagExt())
		fErase(cIndSB6)
	EndIf
Endif

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R460Term ³ Autor ³ XIS INFORMATICA       ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao dos Termos de Abertura e Encerramento do Modelo P7³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Term(lEnd,wnRel,cString,Tamanho)

Local aVariaveis:={}, cArqAbert, cArqEncer, i, cDriver, aDriver:=ReadDriver()

cArqAbert:=GetMv("MV_LMOD7AB")
cArqEncer:=GetMv("MV_LMOD7EN")

XFIS_IMPTERM(cArqAbert,cArqEncer,cPerg,aDriver[4])

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460EmEstoque³ Autor ³ XIS INFORMATICA    ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca movimentacoes em Estoque                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460EmEstoque(lEnd,cArqTemp)

Local lFirst:=.t.,aSalAtu
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca Saldo em Estoque                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbSeek(xFilial()+SB1->B1_P_COD)

If !Found()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o almoxarifado esta entre os parametros          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SB1->B1_LOCPAD >= mv_par03 .and. SB1->B1_LOCPAD <= mv_par04
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lista produtos sem movimentacao de estoque                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lListProdMov
			dbSelectArea(cArqTemp)
			RecLock(cArqTemp,.T.)
			Replace SITUACAO   with "3"
			Replace TIPO	   with SB1->B1_TIPO
			Replace PRODUTO	   with SB1->B1_P_COD
			Replace POSIPI	   with SB1->B1_POSIPI
			Replace DESCRICAO  with SB1->B1_DESC
			Replace UM		   with SB1->B1_UM
			MsUnLock()
		Endif
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lista produtos com movimentacao de estoque                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !lEnd.and.!eof().and.SB2->B2_FILIAL==xFilial().and.;
		SB2->B2_P_COD==SB1->B1_P_COD
		
		If !R460Local(SB2->B2_LOCAL)
			dbSkip()
			Loop
		Endif
		
		If Interrupcao(@lEnd)
			Exit
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera almoxarifado de saldo em processo de mat.indiret³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB2->B2_LOCAL==GetMv("MV_LOCPROC")
			dbSkip()
			Loop
		Endif
		aSalatu:=CalcEst(SB1->B1_P_COD,SB2->B2_LOCAL,dDtFech+1)
		If lSaldTerceir
			aSaldo:=SaldoTerc(SB1->B1_P_COD,SB2->B2_LOCAL,"D",dDtFech)
		EndIf
		dbSelectArea(cArqTemp)
		dbSetOrder(2)
		If dbSeek(SB1->B1_P_COD+"1")
			RecLock(cArqTemp,.F.)
		Else
			RecLock(cArqTemp,.T.)
			lFirst:=.F.
			Replace SITUACAO	with "1"
			Replace TIPO		with SB1->B1_TIPO
			Replace POSIPI		with SB1->B1_POSIPI
			Replace PRODUTO	with SB1->B1_P_COD
			Replace DESCRICAO	with SB1->B1_DESC
			Replace UM			with SB1->B1_UM
		Endif
		Replace QUANTIDADE With QUANTIDADE+aSalAtu[01]-IIF(lSaldTerceir,aSaldo[01],0)
		Replace TOTAL		With TOTAL+aSalAtu[02]-IIF(lSaldTerceir,aSaldo[02],0)
		If aSalAtu[1]>0
			Replace VALOR_UNIT 	With NoRound(TOTAL/QUANTIDADE,nDecVal)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Este Ponto de Entrada foi criado para recalcular o Valor Unitario / Total ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If lCalcUni
		   ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_P_COD,SB2->B2_LOCAL,dDtFech,cArqTemp})
		EndIf          
		MsUnLock()				                 				
		dbSelectArea("SB2")
		dbSkip()
	End
Endif

dbSelectArea("SB1")

Return (lEnd)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460Terceiros  ³Autor³Juan Jose Pereira   ³ Data ³ 07.11.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca Saldo em poder de Terceiros (T) ou de Terceiros (D)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Terceiros(lEnd,cArqTemp,cEmDeTerc)

Local aSaldo

If lSaldTerceir.and.!lEnd
	
	dbSelectArea("SB2")
	If	dbSeek(xFilial()+SB1->B1_P_COD)
		
		While !lEnd.and.!eof().and.SB2->B2_FILIAL==xFilial().and.;
			SB2->B2_P_COD==SB1->B1_P_COD
			
			If !R460Local(SB2->B2_LOCAL)
				dbSkip()
				Loop
			Endif
			
			If Interrupcao(@lEnd)
				Exit
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera almoxarifado de saldo em processo de mat.indiret³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SB2->B2_LOCAL==GetMv("MV_LOCPROC")
				dbSkip()
				Loop
			Endif
			
			aSaldo:=SaldoTerc(SB1->B1_P_COD,SB2->B2_LOCAL,If(cEmDeTerc=="4","D","T"),dDtFech)
			
			If aSaldo[1]+aSaldo[2]>0
				dbSelectArea(cArqTemp)
				dbSetOrder(2)
				If dbSeek(SB1->B1_P_COD+cEmDeTerc)
					RecLock(cArqTemp,.F.)
				Else
					RecLock(cArqTemp,.T.)
					Replace SITUACAO 	with cEmDeTerc
					Replace TIPO		with SB1->B1_TIPO
					Replace POSIPI		with SB1->B1_POSIPI
					Replace PRODUTO	with SB1->B1_P_COD
					Replace DESCRICAO	with SB1->B1_DESC
					Replace UM			with SB1->B1_UM
				Endif
				Replace QUANTIDADE	with QUANTIDADE+aSaldo[01]
				Replace TOTAL		   with TOTAL+aSaldo[02]
				If aSaldo[01]>0
					Replace VALOR_UNIT 	with NoRound(TOTAL/QUANTIDADE,nDecVal)
				Endif
				MsUnLock()
			Endif
			dbSelectArea("SB2")
			dbSkip()
			
		End
		
	Endif
	
Endif

dbSelectArea("SB2")

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460EmProcesso ³Autor³     XIS INFORMATICA³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca saldo em Processo                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460EmProcesso(lEnd,cArqTemp)

Local aCampos:={},cArqTemp2,cArqTemp3,cChave,cFiltro,nIndex,aSalAtu

If lSaldProcess .and. !lEnd
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de Trabalho para armazenar as OPs               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aCampos,{"OP","C",11,0})
	AADD(aCampos,{"DATA1","D",8,0})
	cArqTemp2:=CriaTrab(aCampos)
	dbUseArea(.T.,,cArqTemp2,cArqTemp2,.T.,.F.)
	IndRegua(cArqTemp2,cArqTemp2,"OP+DTOS(DATA1)",,,STR0020)		//"Criando Indice..."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena OPs                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC2")
	//dbSetOrder(2)         //C2_FILIAL + C2_PRODUTO + DTOS(C2_DATPRF) (2)
	_CREINDC2()
	dbSeek(xFilial()+mv_par05,.T.)	
	While !eof().and.!lEnd

		If ! Empty(mv_par06) .and. C2_PRODUTO > mv_par06
			Exit
		Endif	
		
		If Interrupcao(@lEnd)
			Exit
		Endif
		
		If (!Empty(SC2->C2_DATRF) .And. SC2->C2_DATRF <= dDtFech) .Or. ;
			!R460AvalProd(SC2->C2_PRODUTO)
			dbSkip()
			Loop
		Endif
		
		dbSelectArea(cArqTemp2)
		RecLock(cArqTemp2,.T.)
		Replace OP with SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
		MsUnLock()
		
		dbSelectArea("SC2")
		dbSkip()
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca saldo em processo                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD3")
	
	cArqTemp3:=CriaTrab(NIL,.F.)
	cChave:="D3_FILIAL+D3_P_COD+D3_LOCAL"
	cFiltro:="D3_FILIAL=='"+xFilial("SD3")+"'.and.D3_CF=='PR0'.and.DTOS(D3_EMISSAO)<='"+DTOS(dDtFech)+"'.And.!Empty(D3_OP)"
	IndRegua("SD3",cArqTemp3,cChave,,cFiltro,STR0020)		//"Criando Indice..."
	nIndex:=RetIndex("SD3")
	#IFNDEF TOP
		dbSetIndex(cArqTemp3+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbSeek(xFilial("SD3") + mv_par05, .T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena OPs e data de emissao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !eof().and.!lEnd

		If ! Empty(mv_par06) .and. SD3->D3_P_COD > mv_par06
			Exit
		Endif	

		If Interrupcao(@lEnd)
			Exit
		Endif
		If !R460AvalProd(SD3->D3_P_COD)
			dbSkip()
			Loop
		Endif
		dbSelectArea(cArqTemp2)
		If dbSeek(SD3->D3_OP)
			RecLock(cArqTemp2,.F.)
		Else
			RecLock(cArqTemp2,.T.)
			Replace OP with SD3->D3_OP
		Endif
		Replace DATA1 with Max(SD3->D3_EMISSAO,DATA1)
		MsUnlock()
		dbSelectArea("SD3")
		dbSkip()
	End
	
	dbSelectArea("SD3")
	Set Filter To
	RetIndex("SD3")
	dbSelectArea(cArqTemp2)
	dbGotop()
	While !Eof().and.!lEnd
		If Interrupcao(@lEnd)
			Exit
		Endif
		dbSelectArea("SD3")
		dbSetOrder(1)
		If dbSeek(xFilial()+(cArqTemp2)->OP)
			While !Eof().and.!lEnd.and.SD3->D3_OP==(cArqTemp2)->OP
				If Interrupcao(@lEnd)
					Exit
				Endif
				If !R460Local(D3_LOCAL).Or.!R460AvalProd(D3_P_COD).Or. ;
					D3_ESTORNO == "S" .Or. D3_EMISSAO <= (cArqTemp2)->DATA1 .Or. ;
					D3_EMISSAO > dDtFech
					dbSkip()
					Loop
				EndIf
				If SB1->B1_P_COD!=SD3->D3_P_COD
					SB1->(dbSeek(xFilial()+SD3->D3_P_COD))
				EndIf
				If SB1->B1_P_COD==SD3->D3_P_COD
					dbSelectArea(cArqTemp)
					dbSetOrder(2)
					RecLock(cArqTemp,!dbSeek(SB1->B1_P_COD+"2"))
					Replace SITUACAO 	with "2"
					Replace TIPO		with SB1->B1_TIPO
					Replace POSIPI		with SB1->B1_POSIPI
					Replace PRODUTO	with SB1->B1_P_COD
					Replace DESCRICAO	with SB1->B1_DESC
					Replace UM			with SB1->B1_UM
					Do Case
						Case Substr(SD3->D3_CF,1,2)=="RE"
							Replace QUANTIDADE 	with QUANTIDADE + SD3->D3_QUANT
							Replace TOTAL		with TOTAL + SD3->D3_CUSTO1
						Case Substr(SD3->D3_CF,1,2)=="DE"
							Replace QUANTIDADE 	with QUANTIDADE - SD3->D3_QUANT
							Replace TOTAL		with TOTAL - SD3->D3_CUSTO1
					EndCase
					If QUANTIDADE>0
						Replace VALOR_UNIT	with NoRound(TOTAL/QUANTIDADE,nDecVal)
					Endif
					
					MsUnLock()
				Endif
				dbSelectArea("SD3")
				dbSkip()
			End
		Endif
		dbSelectArea(cArqTemp2)
		dbSkip()
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga arquivos temporarios                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cArqTemp2)
	dbCloseArea()
	Ferase(cArqTemp2+".DBF")
	Ferase(cArqTemp2+OrdBagExt())
	dbSelectArea("SD3")
	RetIndex("SD3")
	Ferase(cArqTemp3+OrdBagExt())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca saldo em processo dos materiais de uso indireto        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSeek(xFilial())
	SetRegua(LastRec())
	While !eof().and.!lEnd.And.xFilial()==B1_FILIAL
		IncRegua()
		If Interrupcao(@lEnd)
			Exit
		Endif
		If !R460AvalProd(SB1->B1_P_COD)
			dbSkip()
			Loop
		Endif
		dbSelectArea("SB2")
		aSalatu:=CalcEst(SB1->B1_P_COD,GetMv("MV_LOCPROC"),dDtFech+1)
		If aSalAtu[1]+aSalAtu[2]>0
			dbSelectArea(cArqTemp)
			dbSetOrder(2)
			RecLock(cArqTemp,!dbSeek(SB1->B1_P_COD+"2"))
			Replace SITUACAO 	with "2"
			Replace TIPO				with SB1->B1_TIPO
			Replace POSIPI			with SB1->B1_POSIPI
			Replace PRODUTO	with SB1->B1_P_COD
			Replace DESCRICAO	with SB1->B1_DESC
			Replace UM			with SB1->B1_UM
			Replace QUANTIDADE with aSalAtu[1]
			Replace TOTAL		with aSalAtu[2]
			If QUANTIDADE>0
				Replace VALOR_UNIT with NoRound(TOTAL/QUANTIDADE,nDecVal)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Este Ponto de Entrada foi criado para recalcular o Valor Unitario / Total ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If lCalcUni
			   ExecBlock("A460UNIT",.F.,.F.,{SB1->B1_P_COD,GetMv("MV_LOCPROC"),dDtFech,cArqTemp})
			EndIf     
			MsUnlock()			                      					
		Endif
		dbSelectArea("SB1")
		dbSkip()
	End
Endif

Return (lEnd)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460Cabec()    Autor ³ XIS INFORMATICA    ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabecalho do Modelo P7                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Cabec(nLin,nPagina)

Local aL:=R460LayOut()
Local cPicCgc
If  cPaisLoc=="ARG"
	cPicCgc	:="@R 99-99.999.999-9"
ElseIf cPaisLoc == "CHI"
	cPicCgc	:="@R XX.999.999-X"
ElseIf cPaisLoc $ "POR|EUA"
	cPicCgc	:=PesqPict("SA2","A2_CGC")
Else
	cPicCgc	:="@R 99.999.999/9999-99"
EndIf

nLin:=1
@ 00,00 PSAY AvalImp(132)
FmtLin(,aL[01],,,@nLin)
FmtLin(,aL[02],,,@nLin)
FmtLin(,aL[03],,,@nLin)
FmtLin({SM0->M0_NOMECOM},aL[04],,,@nLin)
FmtLin(,aL[05],,,@nLin)
If cPaisLoc == "CHI"
	FmtLin({,Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@nLin)
Else
FmtLin({InscrEst(),Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@nLin)
Endif

FmtLin(,aL[07],,,@nLin)
FmtLin({Transform(StrZero(nPagina,6),"@R 999.999"),DTOC(dDtFech)},aL[08],,,@nLin)
FmtLin(,aL[09],,,@nLin)
FmtLin(,aL[10],,,@nLin)
FmtLin(,aL[11],,,@nLin)
FmtLin(,aL[12],,,@nLin)
FmtLin(,aL[13],,,@nLin)
FmtLin(,aL[14],,,@nLin)
nPagina:=nPagina+1

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460EmBranco() Autor ³ XIS INFORMATICA    ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche o resto da pagina em branco                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460EmBranco(nLin)

Local aL:=R460Layout()

While nLin<=55
	FmtLin(Array(7),aL[15],,,@nLin)
End
FmtLin(,aL[16],,,@nLin)

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460AvalProd() Autor ³ XIS INFORMATICA     ³ Data ³ 22.04.04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Avalia se produto deve ser listrado                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460AvalProd(cProduto)
Return((cProduto>=cProdIni.and.cProduto<=cProdFim) .And. !(Left(cProduto,3) == "MOD"))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460Local() Autor ³ XIS INFORMATICA       ³ Data ³ 22.04.04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Avalia se Local deve ser listrado                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Local(cLocal)
Return (cLocal>=cAlmoxIni.and.cLocal<=cAlmoxFim)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460Acumula() Autor ³ XIS INFORMATICA      ³ Data ³ 22.04.04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acumulador de totais                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Acumula(aTotal)

Local nPos:=0

nPos:=Ascan(aTotal,{|x|x[1]==SITUACAO.and.x[2]==TIPO})
If nPos==0
	AADD(aTotal,{SITUACAO,TIPO,QUANTIDADE,VALOR_UNIT,TOTAL})
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
Endif

nPos:=Ascan(aTotal,{|x|x[1]==SITUACAO.and.x[2]==TT})
If nPos==0
	AADD(aTotal,{SITUACAO,TT,QUANTIDADE,VALOR_UNIT,TOTAL})
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
Endif

nPos:=Ascan(aTotal,{|x|x[1]=="T".and.x[2]==TT})
If nPos==0
	AADD(aTotal,{"T",TT,QUANTIDADE,VALOR_UNIT,TOTAL})
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
Endif

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R460Total()   Autor ³ XIS INFORMATICA     ³ Data ³ 22.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime totais                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R460Total(nLin,aTotal,cSituacao,cTipo,aSituacao)

Local aL:=R460LayOut(),nPos:=0,i:=0,cSitAnt:="X",cSubtitulo

FmtLin(Array(7),aL[15],,,@nLin)

If cSituacao!="T"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime totais dos grupos                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipo!=TT
		nPos:=Ascan(aTotal,{|x|x[1]==cSituacao.and.x[2]==cTipo})
		SX5->(dbSeek(xFilial()+"02"+cTipo))
		FmtLin({,STR0021+TRIM(X5Descri())+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL "
	Else
		nPos:=Ascan(aTotal,{|x|x[1]==cSituacao.and.x[2]==TT})
		FmtLin({,STR0021+aSituacao[Val(cSituacao)]+" ===>",,,,,Transform(aTotal[nPos,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)	//"TOTAL "
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime resumo final                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotal:=Asort(aTotal,,,{|x,y|x[1]+x[2]<y[1]+y[2]})
	FmtLin(Array(7),aL[15],,,@nLin)
	FmtLin({,STR0022,,,,,},aL[15],,,@nLin)		//"R E S U M O"
	FmtLin({,"***********",,,,,},aL[15],,,@nLin)
	For i:=1 to Len(aTotal)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao imprime produtos sem movimentacao                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTotal[i,1]=="3"
			Loop
		Endif
		If cSitAnt!=aTotal[i,1]
			cSitAnt:=aTotal[i,1]
			If aTotal[i,1]!="T"
				FmtLin(Array(7),aL[15],,,@nLin)
				cSubTitulo:=Alltrim(aSituacao[Val(aTotal[i,1])])
				FmtLin({,cSubtitulo,,,,,},aL[15],,,@nLin)
				FmtLin({,Replic("*",Len(cSubtitulo)),,,,,},aL[15],,,@nLin)
			Else
				FmtLin(Array(7),aL[15],,,@nLin)
				FmtLin({,STR0023,,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)		//"TOTAL GERAL ====>"
			Endif
		Endif
		If aTotal[i,1]!="T"
			If aTotal[i,2]!=TT
				SX5->(dbSeek(xFilial()+"02"+aTotal[i,2]))
				FmtLin({,TRIM(X5Descri()),,,,,Transform(aTotal[i,5],"@E 999,999,999,999.99")},aL[15],,,@nLin)
			Else
				FmtLin({,STR0024,,,,,Transform(aTotal[i,5], "@E 999,999,999,999.99")},aL[15],,,@nLin)			//"TOTAL ====>"
			Endif
		Endif
	Next
Endif

Return (NIL)


 STATIC FUNCTION _CREINDC2()
	dbSelectArea("SC2")
	cCondicao1 := ""
    /// dbSetOrder(2)             /// C2_FILIAL + C2_PRODUTO + DTOS(C2_DATPRF) (2)
	cArqTrc2 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SC2",cArqTrc2,"C2_FILIAL + C2_P_PROD + DTOS(C2_DATPRF)",,cCondicao1,"Selecionando Registros...")		//"Selecionando Registros..."
	#ELSE
		IndRegua("SC2",cArqTrc2,"C2_FILIAL + C2_P_PROD + DTOS(C2_DATPRF)",,cCondicao1,"Selecionando Registros...")		//"Selecionando Registros..."
	#ENDIF
	nIndC2 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrc2+ordBagExt())
	#ENDIF
	dbSetOrder(nIndC2+1)
RETURN


Static Function ValidPerg

local _sAlias := Alias()
local aRegs := {}
local i,j

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

///             X1_ORDEM	X1_PERGUNT        	  X1_PERSPA	                X1_PERENG            	VARIAVL	  TIPTAMDECPREGSC  Val X1_VAR01	  X1_DEF01	      X1_DEFSPA1     X1_DEFENG1    X1_CNT01         X1_VAR02	 X1_DEF02	        X1_DEFSPA2	      X1_DEFENG2	X1_CNT02   X1_VAR03	    X1_DEF03	X1_DEFSPA3	 X1_DEFENG3	  X1_CNT03  X1_VAR04  X1_DEF04   X1_DEFSPA4  X1_DEFENG4	  X1_CNT04	   X1_VAR05	    X1_DEF05  X1_DEFSPA5  X1_DEFENG5   X1_CNT05	  X1_F3	 X1_PYME   X1_GRPSXG  X1_HELP
AAdd( aRegs, { cPerg, "01","Saldo em Processo ?   ","?Saldo en Proceso?   ","Balance in Process ?   ","mv_ch1","C",1,0,2, "C"," ","MV_PAR01","Sim             ","Si          ","Yes        ","               ","        ","Nao           ","No             ","No          ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "02","Saldo em 3o Poder ?   ","?Saldo en Poder 3o.? ","Bal. in 3rdP.Poss. ?   ","mv_ch2","C",1,0,2, "C"," ","MV_PAR02","Sim             ","Si          ","Yes        ","               ","        ","Nao           ","No             ","No          ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "03","Armazem Inicial ?     ","?Deposito Inicial ?  ","Initial Warehouse ?    ","mv_ch3","C",2,0,0, "G"," ","MV_PAR03","                ","            ","           ","01             ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "04","Armazem Final ?       ","?Deposito Final?     ","Final Warehouse ?      ","mv_ch4","C",2,0,0, "G"," ","MV_PAR04","                ","            ","           ","99             ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "05","Produto Inicial ?     ","?De Producto?        ","From Product?          ","mv_ch5","C",25,0,0,"G"," ","MV_PAR05","                ","            ","           ","               ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "06","Produto Final ?       ","?A Producto?         ","To Product ?           ","mv_ch6","C",25,0,0,"G"," ","MV_PAR06","                ","            ","           ","ZZZZZZZZZZZZZZ ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "07","Produto Sem Movim. ?  ","?Produtos sin Mov.?  ","Product w/ no Mov. ?   ","mv_ch7","C",1,0,1, "C"," ","MV_PAR07","Sim             ","Si          ","Yes        ","               ","        ","Nao           ","No             ","No          ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "08","Prods.c/Saldo Neg. ?  ","?Prod.con Saldo Neg ?","Prods.w/ Negat.Bal.?   ","mv_ch8","C",1,0,1, "C"," ","MV_PAR08","Sim             ","Si          ","Yes        ","               ","        ","Nao           ","No             ","No          ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "09","Prods.c/Saldo Zera. ? ","?Prod.con Saldo Cero?","Prods.w/Zeroed Bal. ?  ","mv_ch9","C",1,0,1, "C"," ","MV_PAR09","Sim             ","Si          ","Yes        ","               ","        ","Nao           ","No             ","No          ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "10","Pagina Inicial ?      ","?De Pagina?          ","Initial Page?          ","mv_cha","N",5,0,0, "G"," ","MV_PAR10","                ","            ","           ","1              ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "11","Qtd. Paginas/Feixe ?  ","?Ctd. Paginas/Resma? ","Qtty.Pages/Bundle  ?   ","mv_chb","N",5,0,0, "G"," ","MV_PAR11","                ","            ","           ","500            ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "12","Numero do Livro ?  	  ","?Numero del Libro ?  ","Book Number ?          ","mv_chc","C",2,0,0, "G"," ","MV_PAR12","                ","            ","           ","01             ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )	
AAdd( aRegs, { cPerg, "13","Imprime ?             ","?Imprime ?           ","Print ?                ","mv_chd","N",1,0,1, "C"," ","MV_PAR13","Livro           ","Libro       ","book       ","               ","        ","Termos        ","Actas          ","Terms       ","         ","          ","         ","          ","    	     ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "14","Data de Fechamento ?  ","?Fecha Cierre?       ","Closing Date ?         ","mv_che","D",8,0,0, "G"," ","MV_PAR14","                ","            ","           ","'30/03/04'     ","        ","              ","               ","            ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "15","Quanto a Descricao ?  ","?Cuanto a la Descr?  ","About Description?     ","mv_chf","C",1,0,1, "C"," ","MV_PAR15","Normal          ","Normal      ","Regular    ","               ","        ","Inclui Codigo ","Incluye codigo ","Include Code","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "16","Lista Custo Zerado ?  ","?Lista Costo Nulo?   ","Print Zeroed Cost ?    ","mv_chg","N",1,0,1, "C"," ","MV_PAR16","Sim             ","si          ","Yes        ","               ","        ","Nao           ","No             ","Calculation ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "17","Lista Custo ?         ","?Lista Costo?        ","List Cost?             ","mv_chh","N",1,0,1, "C"," ","MV_PAR17","Medio           ","Promedio    ","Average    ","               ","        ","FIFO/PEPS     ","FIFO/PEPS      ","FIFO/PEPS   ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "18","Verif Sld Processo ?  ","?Verif Sld Proceso?  ","Check Process Balance ?","mv_chg","N",1,0,1, "C"," ","MV_PAR18","Data De Eemissao","fch.emision ","Issue Date ","               ","        ","Seq Calculo CM","Seq Calculo CM ","Ac.Calc.Seq ","         ","          ","         ","          ","          ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )


For i:=1 to Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)

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

dbSelectArea(_sAlias)

Return






