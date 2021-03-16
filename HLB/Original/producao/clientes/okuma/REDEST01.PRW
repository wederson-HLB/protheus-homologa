#INCLUDE "MATR310.CH"
#Include "FIVEWIN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ REDEST01  ³ Autor ³ XIS INFORMATICA      ³ Data ³ 14/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao dos Produtos Vendidos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
/*
Funcao      : REDEST01
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Relacao dos Produtos Vendidos
Autor     	: XIS INFORMATICA
Data     	: 14/04/04  
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Estoque
Cliente     : Okuma
*/ 

*----------------------*
 User Function REDEST01 
*----------------------* 
 
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


LOCAL Tamanho  := "G"
LOCAL titulo   := STR0001	//"Relacao dos Produtos Vendidos"
LOCAL cDesc1   := STR0002	//"Este relatorio apresenta o valor total das vendas de cada produto,"
LOCAL cDesc2   := STR0003	//"calculando sua participacao dentro do total das vendas.Mostra tam-"
LOCAL cDesc3   := STR0004	//"bem o custo de cada venda e o custo de reposicao do produto."
LOCAL cString  := "SD2"
LOCAL nTipo    := 0
LOCAL wnrel    := "REDEST01"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn:= {OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
//PRIVATE nLastKey := 0 ,cPerg := "MTR310"
PRIVATE nLastKey := 0 ,cPerg := "REDE01    "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01     // Almoxarifado inicial                         ³
//³ MV_PAR02     // Almoxarifado final                           ³
//³ MV_PAR03     // Data de emissao inicial                      ³
//³ MV_PAR04     // Data de emissao final                        ³
//³ MV_PAR05     // tipo inicial                                 ³
//³ MV_PAR06     // tipo final                                   ³
//³ MV_PAR07     // produto inicial                              ³
//³ MV_PAR08     // produto final                                ³
//³ MV_PAR09     // moeda selecionada ( 1 a 5 )                  ³
//³ MV_PAR10     // Considera Valor IPI Sim N„o                  ³
//³ MV_PAR11     // Considera Devolucao NF Orig/NF Devl/Nao Cons.³
//³ MV_PAR12     // Quanto a Estoque Movimenta/Nao Movta/Ambos   ³
//³ MV_PAR13     // Quanto a Duplicata Gera/Nao Gera/Ambos       ³
//³ MV_PAR14     // Considera Valor ICMS Sim N„o                 ³
//³ MV_PAR15     // Abate Impostos Nao Faturados ?               ³
//³ MV_PAR16     // Perc. Abatimento ?                           ³
//³ MV_PAR17     // Inclui Devolucao de Compra?                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VALIDPERG()

Pergunte(cPerg,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C310Imp(@lEnd,wnRel,cString,titulo,Tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ REDEST01  ³ Autor ³ XIS INFOMATICA       ³ Data ³ 15.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  REDEST01			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C310Imp(lEnd,WnRel,cString,titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := STR0007		//"REGISTRO(S)"
LOCAL nCntImpr := 0
LOCAL lDevolucao := .F.
LOCAL nAp1,nAp2,nAp3,nAp4,nAp5
LOCAL nAt1,nAt2,nAt3,nAt4,nAt5
LOCAL nAg1,nAg2,nAg3,nAg4,nAg5
LOCAL cCodAnt := "",cTipant := "",nTotFat:=0,nTotLuc:=0
LOCAL cMoeda ,lPassou
LOCAL cArqSD1:=cArqSD2:=cArqTrab:=cArqTrb2:=cArqTrb3:=cKeySD2:=sKeySD1:=cFilSD1:=cFilSD2:=""
Local cEstoq := If( (mv_par12 == 1),"S",If( (mv_par12 == 2),"N","SN" ) )
Local cDupli := If( (mv_par13 == 1),"S",If( (mv_par13 == 2),"N","SN" ) )
Local nValCus := 0
Local aCampos:= aTam:={}
LOCAL nIndSd1:= 0
LOCAL cTrbSD1 := CriaTrab(,.f.)
LOCAL cTrbSD2 := Subs(cTrbSD1,1,7)+"A"


Private cCampImp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas especificas deste relatorio               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lContinua := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMoeda := Str(mv_par09,1)
titulo += " - "+&("mv_simb"+cMoeda)
			  cabec1 :="TP  CODIGO                    D E S C R I C A O                              QUANTIDADE UM          CUSTO      CUSTO POR      V A L O R  IMPOSTOS NAO  VAL FATURADO -    MAR     MIX     MIX       CUSTO DE   VARIA"
			  cabec2 :="                                                                                                    TOTAL        UNIDADE       FATURADO     FATURADOS  IMP. NAO FAT.     GEM    *MAR              REPOSICAO     CAO"
*****                   12  1234567890123456789012345 1234567890123456789012345678901234567890 1,123,123,123,12 12 123,123,123.12 123,123,123.12 123,123,123.12 123,123,123.12 123,123,123.12 +1234.1 1234.1 +1234.1 111.123.123.12  1234.1
*****                   0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21 
*****                   01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

If (mv_par11 # 3)
	dbSelectArea( "SD1" )
	
	cArqSD1 := CriaTrab( NIL,.F. )
	cKeySD1 := "D1_FILIAL+D1_P_COD+D1_SERIORI+D1_NFORI+D1_ITEMORI"
	cFilSD1 := "D1_FILIAL = '"+xFilial( "SD1" )+"' .And. D1_TIPO = 'D'  .And. "+;
	"D1_P_COD >= '"+MV_PAR07+"' .And. D1_P_COD <= '"+MV_PAR08+"' .And. "+;
	"D1_LOCAL >= '"+MV_PAR01+"' .And. D1_LOCAL <= '"+MV_PAR02
	If (mv_par11 == 1)
		cFilSD1 += "'"
	Else
		cFilSD1 +="' .And. DTOS(D1_DTDIGIT) >= '"+DTOS(MV_PAR03)+"' .And. DTOS(D1_DTDIGIT) <= '"+DTOS(MV_PAR04)+"'"
	EndIf
	
	IndRegua("SD1",cArqSD1,cKeySD1,,cFilSD1,STR0010)			//"Selecionando Registros..."
	
	nIndSd1:=RetIndex("SD1")
	#IFNDEF TOP
		dbSetIndex(cArqSd1+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndSd1 + 1)
	dbGoTop()

EndIf

dbSelectArea( "SD2" )

cIndice:="D2_FILIAL+D2_TP+D2_P_COD"
INDREGUA("SD2",cTrbSD2,cIndice,,DBFilter())
nInd := RetIndex("SD2")
#IFNDEF TOP
	dbSetIndex(cTrbSD2+OrdBagExt())
#ENDIF
dbSetOrder(nInd+1)
////dbSetOrder( 10 )             //    D2_FILIAL + D2_TP + D2_COD   (2)

cKeySD2 := IndexKey()

aTam := TamSx3("D2_FILIAL")
Aadd(aCampos,{"D2_FILIAL","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_P_COD")
Aadd(aCampos,{"D2_P_COD","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_LOCAL")
Aadd(aCampos,{"D2_LOCAL","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_SERIE")
Aadd(aCampos,{"D2_SERIE","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_TES")
Aadd(aCampos,{"D2_TES","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_TP")
Aadd(aCampos,{"D2_TP","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_EMISSAO")
Aadd(aCampos,{"D2_EMISSAO","D",aTam[1],aTam[2]})
aTam := TamSx3("D2_TIPO")
Aadd(aCampos,{"D2_TIPO","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_DOC")
Aadd(aCampos,{"D2_DOC","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_QUANT")
Aadd(aCampos,{"D2_QUANT","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_TOTAL")
Aadd(aCampos,{"D2_TOTAL","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_CUSTO")
Aadd(aCampos,{"D2_CUSTO","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_VALIPI")
Aadd(aCampos,{"D2_VALIPI","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_VALICM")
Aadd(aCampos,{"D2_VALICM","N",aTam[1],aTam[2]})
aTam := TamSx3("D2_ITEM")
Aadd(aCampos,{"D2_ITEM","C",aTam[1],aTam[2]})
aTam := TamSx3("D2_ORIGLAN")
Aadd(aCampos,{"D2_ORIGLAN","C",aTam[1],aTam[2]})

cArqTrab := CriaTrab(aCampos)
Use &cArqTrab Alias TRB New Exclusive
cArqTrb2 := CriaTrab( NIL,.F. )
IndRegua("TRB",cArqTrb2,cKeySD2,,cFilSD2,"Selecionando Registros...")

cFilSD2 := IIF(!Empty(aReturn[7]),aReturn[7]+".And.","")+"D2_FILIAL = '"+xFilial( "SD2" )+"' .And. D2_TP >= '"+MV_PAR05+;
"' .And. D2_TP <= '"+MV_PAR06+"' .And. D2_P_COD >= '"+MV_PAR07+;
"' .And. D2_P_COD <= '"+MV_PAR08+"' .And. D2_LOCAL >= '"+MV_PAR01+;
"' .And. D2_LOCAL <= '"+MV_PAR02+"'"
cFilSD2 += " .And. DTOS(D2_EMISSAO) >= '"+DTOS(MV_PAR03)+"' .And. DTOS(D2_EMISSAO) <= '"+DTOS(MV_PAR04)+"'"
If mv_par17 == 2
	cFilSD2 += ' .And. D2_TIPO # "D"'
Endif

cArqSD2 := CriaTrab( NIL,.F. )
IndRegua("SD2",cArqSD2,cKeySD2,,cFilSD2,"Selecionando Registros...")

GeraTrab("SD2")

If mv_par11 != 3
	dbSelectArea("SD1")
	dbGoTop()
	GeraTrab("SD1")
EndIf

dbSelectArea("TRB")
dbGoTop()

SetRegua(RecCount())		// Total de Elementos da regua

While lContinua .And. !TRB->(Eof())
	
	If lEnd
		@Prow()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif
	
	IncRegua()
	
	If !(cCodAnt == TRB->D2_P_COD)
		cCodAnt    := TRB->D2_P_COD
		lDevolucao := .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal    ³
	//³ Despreza Itens em que a TES NAO Se Ajusta a Selecao do Usuario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(TRB->D2_ORIGLAN == "LF") .And. AvalTes(TRB->D2_TES,cEstoq,cDupli)
		If TRB->D2_TIPO != "D"
			If (mv_par09 > 1)
				nValCus := TRB->D2_CUSTO
				if nValCus > 0
					nTotLuc += nValCus
				else
					nTotLuc += ConvMoeda( TRB->D2_EMISSAO,,TRB->D2_CUSTO,cMoeda )
				endif
			Else
				nTotLuc += TRB->D2_CUSTO
			EndIf
			
			If (mv_par09 > 1)
				nTotFat += ConvMoeda( TRB->D2_EMISSAO,,ValSD2(),cMoeda )
			Else
				nTotFat += ValSD2()
			EndIf
		EndIf
		Do Case
			Case (mv_par11 == 1)
				DbSelectArea( "SD1" )
				If DbSeek( xFilial( "SD1" )+TRB->D2_P_COD+TRB->D2_SERIE+TRB->D2_DOC+TRB->D2_ITEM,.F. )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal    ³
					//³ Despreza Itens em que a TES NAO Se Ajusta a Selecao do Usuario ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(D1_ORIGLAN == "LF") .And. AvalTes(D1_TES,cEstoq,cDupli)
						
						If (mv_par09 > 1)
							nValCus :=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
							if nValCus > 0
								nTotLuc -= nValCus
							else
								nTotLuc -= ConvMoeda( D1_DTDIGIT,,D1_CUSTO,cMoeda )
							endif
						Else
							nTotLuc -=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
						EndIf
						
						If (mv_par09 > 1)
							nTotFat -= ConvMoeda( D1_DTDIGIT,,ValSD1(),cMoeda )
						Else
							nTotFat -= ValSD1()
						EndIf
					EndIf
				EndIf
			Case (mv_par11 == 2) .And. lDevolucao
				DbSelectArea( "SD1" )
				If DbSeek( xFilial( "SD1" )+TRB->D2_P_COD,.F. )
					While !SD1->(Eof()) .And. (SD1->D1_P_COD == TRB->D2_P_COD)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal    ³
						//³ Despreza Itens em que a TES NAO Se Ajusta a Selecao do Usuario ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(D1_ORIGLAN == "LF") .And. AvalTes(D1_TES,cEstoq,cDupli)
							
							If (mv_par09 > 1)
								nValCus :=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
								if nValCus > 0
									nTotLuc -= nValCus
								else
									nTotLuc -= ConvMoeda( D1_DTDIGIT,,D1_CUSTO,cMoeda )
								endif
							Else
								nTotLuc -=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
							EndIf
							
							If (mv_par09 > 1)
								nTotFat -= ConvMoeda( D1_DTDIGIT,,ValSD1(),cMoeda )
							Else
								nTotFat -= ValSD1()
							EndIf
						EndIf
						dbSelectArea('SD1')
						DbSkip( 1 )
					EndDo
				EndIf
				lDevolucao := .F.
		EndCase
	EndIf
	
	DbSelectArea( "TRB" ) ; DbSkip( 1 )
EndDo

nTotLuc := c310AbaVal(nTotFat)-nTotLuc

TRB->(DbGoTop())

nAg1 := 0
nAg2 := 0
nAg3 := 0
nAg4 := 0
nAg5 := 0
cCodAnt := ""

dbSelectArea("TRB")
While lContinua .And. !TRB->(Eof())
	
	If lEnd
		@Prow()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	nAt1 := 0
	nAt2 := 0
	nAt3 := 0
	nAt4 := 0
	nAt5 := 0
	
	lPassou := .F.
	cTipant := TRB->D2_TP
	
	While lContinua .And. !TRB->(Eof()) .And. (TRB->D2_TP == cTipant)
		
		IF lEnd
			@Prow()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Else
			
			SB1->(DbSeek( xFilial( "SB1" )+TRB->D2_P_COD,.F. ))
			
			nAp1 := 0
			nAp2 := 0
			nAp3 := 0
			nAp4 := 0
			nAp5 := 0
			
			If !(cCodAnt == TRB->D2_P_COD)
				cCodAnt    := TRB->D2_P_COD
				lDevolucao := .T.
			EndIf
			
			While lContinua .And. !TRB->(Eof()) .And. TRB->D2_TP+TRB->D2_P_COD == cTipant+cCodAnt
				
				IF lEnd
					@Prow()+1,001 PSay STR0011		//"CANCELADO PELO OPERADOR"
					lContinua := .F.
					Exit
				Else
					
					IncRegua()
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal    ³
					//³ Despreza Itens em que a TES NAO Se Ajusta a Selecao do Usuario ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(TRB->D2_ORIGLAN == "LF") .And. AvalTes(TRB->D2_TES,cEstoq,cDupli)
						If TRB->D2_TIPO != "D"
							nAp1 += TRB->D2_QUANT
							If (mv_par09 > 1)
								nValCus := TRB->D2_CUSTO
								if nValCus > 0
									nAp2 += nValCus
								else
									nAp2 += ConvMoeda(TRB->D2_EMISSAO,,TRB->D2_CUSTO,cMoeda )
								endif
							Else
								nAp2 += TRB->D2_CUSTO
							EndIf
							
							If (mv_par09 > 1)
								nAp3 += ConvMoeda(TRB->D2_EMISSAO,,ValSD2(),cMoeda )
								nAp5 += ConvMoeda(TRB->D2_EMISSAO,,TRB->D2_TOTAL+IF(mv_par10 == 1,TRB->D2_VALIPI,0),cMoeda )
							Else
								nAp3 += ValSD2()
								nAp5 += TRB->D2_TOTAL+IF(mv_par10 == 1,TRB->D2_VALIPI,0)
							EndIF
							
							If mv_par09 > 1
								nAp4 += (TRB->D2_QUANT*ConvMoeda(SB1->B1_DATREF,,SB1->B1_CUSTD,cMoeda))
							Else
								nAp4 += (TRB->D2_QUANT*SB1->B1_CUSTD)
							EndIF
						EndIf
						Do Case
							Case (mv_par11 == 1)
								DbSelectArea( "SD1" )
								If DbSeek( xFilial( "SD1" )+TRB->D2_P_COD+TRB->D2_SERIE+TRB->D2_DOC+TRB->D2_ITEM,.F. )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal    ³
									//³ Despreza Itens em que a TES NAO Se Ajusta a Selecao do Usuario ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If !(SD1->D1_ORIGLAN == "LF") .And. AvalTes(SD1->D1_TES,cEstoq,cDupli)
										
										nAp1 -= SD1->D1_QUANT
										If (mv_par09 > 1)
											nValCus :=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
											if nValCus > 0
												nAP2 -= nValCus
											else
												nAp2 -= ConvMoeda(SD1->D1_DTDIGIT,,SD1->D1_CUSTO,cMoeda )
											endif
										Else
											nAp2 -=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
										EndIf
										
										If (mv_par09 > 1)
											nAp3 -= ConvMoeda(SD1->D1_DTDIGIT,,ValSD1(),cMoeda )
											nAp5 -= ConvMoeda(SD1->D1_DTDIGIT,,SD1->D1_TOTAL+IF(mv_par10 == 1,SD1->D1_VALIPI,0),cMoeda )
										Else
											nAp3 -= ValSD1()
											nAp5 -= SD1->D1_TOTAL+IF(mv_par10 == 1,SD1->D1_VALIPI,0)
										EndIF
										
										If mv_par09 > 1
											nAp4 -= (SD1->D1_QUANT*ConvMoeda(SB1->B1_DATREF,,SB1->B1_CUSTD,cMoeda))
										Else
											nAp4 -= (SD1->D1_QUANT*SB1->B1_CUSTD)
										EndIF
									EndIf
								EndIf
							Case (mv_par11 == 2) .And. lDevolucao
								DbSelectArea( "SD1" )
								If DbSeek( xFilial( "SD1" )+TRB->D2_P_COD,.F. )
									While !SD1->(Eof()) .And. (D1_P_COD == cCodAnt)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal    ³
										//³ Despreza Itens em que a TES NAO Se Ajusta a Selecao do Usuario ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !(D1_ORIGLAN == "LF") .And. AvalTes(D1_TES,cEstoq,cDupli)
											
											nAp1 -= D1_QUANT
											If (mv_par09 > 1)
												nValCus :=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
												if nValCus > 0
													nAp2 -= nValCus
												else
													nAp2 -= ConvMoeda( D1_DTDIGIT,,D1_CUSTO,cMoeda )
												endif
											Else
												nAp2 -=  &("D1_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)) )
											EndIf
											
											If (mv_par09 > 1)
												nAp3 -= ConvMoeda( D1_DTDIGIT,,ValSD1(),cMoeda )
												nAp5 -= ConvMoeda( D1_DTDIGIT,,SD1->D1_TOTAL+IF(mv_par10 == 1,SD1->D1_VALIPI,0),cMoeda )
											Else
												nAp3 -= ValSD1()
												nAp5 -= SD1->D1_TOTAL+IF(mv_par10 == 1,SD1->D1_VALIPI,0)
											EndIF
											
											If mv_par09 > 1
												nAp4 -= (D1_QUANT*ConvMoeda(SB1->B1_DATREF,,SB1->B1_CUSTD,cMoeda))
											Else
												nAp4 -= (D1_QUANT*SB1->B1_CUSTD)
											EndIF
										EndIf
										dbSelectArea('SD1')
										DbSkip( 1 )
									EndDo
								EndIf
								lDevolucao := .F.
						EndCase
						
						DbSelectArea( "TRB" )
					EndIf
				EndIF
				DbSelectArea( "TRB" ) ; dbSkip()
			EndDo
			
			If nAp1 != 0 .Or. nAp2 != 0 .Or. nAp3 != 0 .Or. nAp4 != 0
				
				If li > 55
					Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
				EndIf

				lPassou := .T.
				nCntImpr++
				@ li,000 PSay cTipant
				@ li,004 PSay cCodAnt // CODIGO
				@ li,030 PSay Substr(SB1->B1_DESC,1,40)//DESCRIÇAO
				@ li,071 PSay nAp1 Picture PesqPictQt("D2_QUANT",16)// QUANTIDADE
				@ li,088 PSay SB1->B1_UM // UM
				@ li,091 PSay nAp2 PicTure TM(nAp2,14)// CUSTO TOTAL
				@ li,106 PSay (nAp2/nAp1) Picture TM(nAp2,14)//CUSTO POR UNIDADE
				@ li,121 PSay nAp3 PicTure TM(nAp3,14)//VALOR FATURADO
				
				If nAp3 != 0
					@ li,136 PSay nAp5-(c310AbaVal(nAp5)) PicTure TM(nAp5,12) //Impostos nao faturados
					@ li,151 PSay nAp3-(nAp5-(c310AbaVal(nAp5))) PicTure TM(nAp3,14) // Valor Faturado - impostos nao faturados
					@ li,166 PSay 100*(c310AbaVal(nAp3)-nAp2)/c310AbaVal(nAp3) PicTure "9999.9" //margem
				EndIf
				If nTotFat != 0
					@ li,174 PSay 100*c310AbaVal(nAp3)/c310AbaVal(nTotFat) PicTure "9999.9"//MIX MARGEM
				EndIf
				If nTotLuc != 0
					@ li,181 PSay IIF(nAp3-nAp2>0,"+","-")//SINAL + - MIX
					@ li,182 PSay 100*(c310AbaVal(nAp3)-nAp2)/nTotLuc PicTure "9999.9"//MIX
				EndIf
				@ li,189 PSay nAp4 PicTure TM(nAp4,14)//CUSTO DE REPOSIÇAO
				If nAp2 != 0
					@ li,205 PSay (100*nAp4/nAp2)-100 PicTure "9999.9"// VARIACAO
				EndIf
				
				li++
				nAt1 += nAp1
				nAt2 += nAp2
				nAt3 += nAp3
				nAt4 += nAp4
				nAt5 += nAp5
			Endif
		EndIF
		DbSelectArea( "TRB" )
	EndDo
	
	If lPassou
		
		@ li,00 PSay STR0012 + cTipant			//"Sub Total : "
		@ li,071 PSay nAt1 Picture PesqPictQt("D2_QUANT",16)// QUANTIDADE
		@ li,091 PSay nAt2 PicTure TM(nAt2,14)// CUSTO TOTAL
		@ li,106 PSay (nAt2/nAT1) Picture TM(nAt2,14)//CUSTO POR UNIDADE
		@ li,121 PSay nAt3 PicTure TM(nAt3,14)// VALOR FATURADO
		If nAt3#0
			@ li,136 PSay nAt5-(c310AbaVal(nAt5)) PicTure TM(nAp3,12)//IMPOSTO NAO FATURADO
			@ li,151 PSay nAt3-(nAt5-(c310AbaVal(nAt5))) PicTure TM(nAp3,14)//VALOR FATURADO
			@ li,166 PSay 100*(c310AbaVal(nAt3)-nAt2)/c310AbaVal(nAt3) PicTure "9999.9"//MARGEM
		EndIf
		@ li,174 PSay 100*(c310AbaVal(nAt3))/c310AbaVal(nTotfat) PicTure "9999.9"//MIX MAR
		If nTotLuc != 0
			@ li,181 PSay IIF(nAt3-nAt2>0,"+","-")//SINAL MIX
			@ li,182 PSay 100*(c310AbaVal(nAt3)-nAt2)/nTotLuc PicTure "9999.9"//MIX
		EndIF
		@ li,189 PSay nAt4 PicTure tm(nAt4,14)//CUSTO DE REPOSIÇAO
		If nAt2 != 0
			@ li,205 PSay (100*nAt4/nAt2)-100 PicTure "9999.9"//VARIAÇAO
		EndIF
		
		li += 2
		nAg1 += nAt1
		nAg2 += nAt2
		nAg3 += nAt3
		nAg4 += nAt4
		nAg5 += nAt5
	EndIf
	DbSelectArea( "TRB" )
EndDo

If li != 80
	
	@ li,00 PSay STR0013		//"T O T A L ---> "
	@ li,071 PSay nAg1 Picture PesqPictQt("D2_QUANT",16)
	@ li,091 PSay nAg2 PicTure TM(nAg2,14)
	@ li,0106 PSay (nAg2/nAg1) Picture TM(nAg2,14)
	@ li,121	PSay nAg3 PicTure TM(nAg3,14)
	If nAg3 != 0
		@ li,136 PSay nAg5-(c310AbaVal(nAg5)) PicTure TM(nAp3,12)
		@ li,151 PSay nAg3-(nAg5-(c310AbaVal(nAg5))) PicTure TM(nAp3,14)
		@ li,166 PSay 100*(c310AbaVal(nAg3)-nAg2)/c310AbaVal(nAg3) PicTure "9999.9"
	EndIF
	If nTotFat != 0
		@ li,174 PSay 100*c310AbaVal(nAg3)/c310AbaVal(nTotFat) PicTure "9999.9"
	EndIF
	If nTotluc != 0
		@ li,181 PSay IIF(nAg3-nAg2>0,"+","-")
		@ li,182 PSay 100*(c310AbaVal(nAg3)-nAg2)/nTotLuc PicTure "9999.9"
	EndIF
	@ li,189 PSay nAg4 PicTure tm(nAg4,14)
	If nAg2#0
		@ li,205 PSay (100*nAg4/nAg2)-100 PicTure "9999.9"
	EndIF
EndIf

If li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
Set Filter To
Set Order To 1

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

DbSelectArea( "SD1" ) ; RetIndex( "SD1" )
DbSelectArea( "SD2" ) ; RetIndex( "SD2" )

If mv_par11 <> 3
	dbSelectArea("SD1")
	IF File(cArqSD1+OrdBagExt())
		Ferase(cArqSD1+OrdBagExt())
	Endif
	cIndice:="D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_P_COD+D1_ITEM"
	INDREGUA("SD1",cTrbSD1,cIndice,,DBFilter())
	nInd := RetIndex("SD1")
	#IFNDEF TOP
		dbSetIndex(cTrbSD1+OrdBagExt())
	#ENDIF
	dbSetOrder(nInd+1)
	///dbSetOrder(12)    // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM  (1)
Endif

If File(cArqSD2+OrdBagExt())
	FErase(cArqSD2+OrdBagExt())
Endif

dbSelectArea("TRB")
dbCloseArea()
If File(cArqTrab+".DBF")
	FErase(cArqTrab+".DBF")    //arquivo de trabalho
Endif
If File(cArqTrb2+OrdBagExt())
	FErase(cArqTrb2+OrdBagExt())
Endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ REDEST01  ³ Autor ³ XIS INFOMATICA       ³ Data ³ 15.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma os valores de acordo com os parametros no arquivo SD1 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  REDEST01	m                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValSD1()
Local nValRet	:=0, nImpInc:=0,nImpNoInc:=0
Local aImpostos:={}
If ( cPaisLoc=="BRA" )
	nValRet:=D1_TOTAL+IF(mv_par10 == 1,D1_VALIPI,0)-IF(mv_par14 == 1,0,D1_VALICM)
ElseIf (mv_par10==1.Or.mv_par14<>1)
	aImpostos:=TesImpInf(SD1->D1_TES)
	For nY:=1 to Len(aImpostos)
		cCampImp:="SD1->"+(aImpostos[nY][2])
		If ( aImpostos[nY][3]=="S" )
			nImpInc  += &cCampImp
		Else
			nImpNoInc+= &cCampImp
		EndIf
	Next
	nValRet:=D1_TOTAL+IF(mv_par10 == 1,nImpInc,0)-IF(mv_par14 == 1,0,nImpNoInc)
Else
	nValRet:=D1_TOTAL
EndIf

RETURN nValRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  REDEST01  ³ Autor ³ XIS INFOMATICA      ³ Data ³ 15.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma os valores de acordo com os parametros no arquivo SD2 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  REDEST01			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValSD2()
Local nValRet	:=0, nImpInc:=0,nImpNoInc:=0
Local aImpostos:={}

If ( cPaisLoc=="BRA" )
	nValRet:=TRB->D2_TOTAL+IF(mv_par10 == 1,TRB->D2_VALIPI,0)-IF(mv_par14 == 1,0,TRB->D2_VALICM)
ElseIf (mv_par10==1.Or.mv_par14<>1)
	aImpostos:=TesImpInf(TRB->D2_TES)
	For nY:=1 to Len(aImpostos)
		cCampImp:="TRB->"+(aImpostos[nY][2])
		If ( aImpostos[nY][3]=="S" )
			nImpInc  += &cCampImp
		Else
			nImpNoInc+= &cCampImp
		EndIf
	Next
	nValRet:=TRB->D2_TOTAL+IF(mv_par10 == 1,nImpInc,0)-IF(mv_par14 == 1,0,nImpNoInc)
Else
	nValRet:=TRB->D2_TOTAL
EndIf

RETURN nValRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o   ³ REDEST01  ³ Autor ³ XIS INFOMATICA         ³ Data ³ 15.04.04³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o³Abate % dos Impostos nao Faturados do Valor da Venda         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ExpN1	: Valor Base p/ Abatimento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ REDEST01                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function c310AbaVal(nValor)
LOCAL perc := mv_par16
If mv_par15 == 2
	nValor := nValor - (nValor * perc /100)
EndIf
Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ REDEST01  ³ Autor ³ XIS INFOMATICA       ³ Data ³ 15.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta Grupo de Perguntas                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION AjustaSX1()
Local aArea:=GetArea()
Local i:=0,j:=0
Local aRegistros:={}
*Atencao Traducao                   Portugues                Espanhol                Ingles                                                                   Por             Esp                Ing                                        Por                Esp                Ing
Aadd(aRegistros, {"MTR310", "15", "Abate Imp Nao Fat  ?", "¨Desc.Imp.No Fact  ?", "Abate Imp Nao Fat  ?" , "mv_chf", "N", 1 , 0, 1, "C", "", "MV_PAR15", "Nao"         , "No"             , "No"             , ""               , "", "Sim"            , "Si"             , "Yes"           , "", "", ""             , ""            , ""            , "", "", ""        , ""         , ""          , "", "", ""        , ""         , ""          , "", ""   , ""})
Aadd(aRegistros, {"MTR310", "16", "Perc. Abatimento   ?", "¨Porc. Descuento   ?", "Perc. Abatimento   ?" , "mv_chg", "N", 5 , 2, 0, "G", "", "MV_PAR16", ""            , ""               , ""               , ""               , "", ""               , ""               , ""              , "", "", ""             , ""            , ""            , "", "", ""        , ""         , ""          , "", "", ""        , ""         , ""          , "", ""   , ""})
Aadd(aRegistros, {"MTR310", "17", "Inclui Dev. Compra ?", "¨Incluye Dev.Compra?", "Insert Purch.Return?" , "mv_chh", "N", 1 , 0, 1, "C", "", "mv_par17", "Sim", "Si", "Yes", "", "", "Nao", "No", "No", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
dbSelectArea("SX1")
For i:=1 to Len(aRegistros)
	If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegistros[i,j])
		Next j
		MsUnlock()
	EndIf
Next i
RestArea(aArea)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ REDEST01  ³ Autor ³ XIS INFOMATICA       ³ Data ³ 15.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Arquivo de Trabalho                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraTrab(cAlias)

dbSelectArea(cAlias)
dbGoTop()
While !Eof() .And. &(Subs(cAlias,2,2)+"_FILIAL") == xFilial()
	Reclock("TRB",.T.)
	Replace TRB->D2_FILIAL  With &(cAlias+"->"+Subs(cAlias,2,2)+"_FILIAL")
	Replace TRB->D2_P_COD     With &(cAlias+"->"+Subs(cAlias,2,2)+"_P_COD")
	Replace TRB->D2_LOCAL   With &(cAlias+"->"+Subs(cAlias,2,2)+"_LOCAL")
	Replace TRB->D2_SERIE   With &(cAlias+"->"+Subs(cAlias,2,2)+"_SERIE")
	Replace TRB->D2_TES     With &(cAlias+"->"+Subs(cAlias,2,2)+"_TES")
	Replace TRB->D2_TP      With &(cAlias+"->"+Subs(cAlias,2,2)+"_TP")
	Replace TRB->D2_EMISSAO With &(cAlias+"->"+Subs(cAlias,2,2)+"_EMISSAO")
	Replace TRB->D2_TIPO    With &(cAlias+"->"+Subs(cAlias,2,2)+"_TIPO")
	Replace TRB->D2_DOC     With &(cAlias+"->"+Subs(cAlias,2,2)+"_DOC")
	Replace TRB->D2_QUANT   With &(cAlias+"->"+Subs(cAlias,2,2)+"_QUANT")
	Replace TRB->D2_TOTAL   With &(cAlias+"->"+Subs(cAlias,2,2)+"_TOTAL")
	Replace TRB->D2_VALIPI  With &(cAlias+"->"+Subs(cAlias,2,2)+"_VALIPI")
	Replace TRB->D2_VALICM  With &(cAlias+"->"+Subs(cAlias,2,2)+"_VALICM")
	Replace TRB->D2_ITEM    With &(cAlias+"->"+Subs(cAlias,2,2)+"_ITEM")
	Replace TRB->D2_ORIGLAN With &(cAlias+"->"+Subs(cAlias,2,2)+"_ORIGLAN")
	If cAlias == "SD2"
		Replace TRB->D2_CUSTO With &(cAlias+"->"+Subs(cAlias,2,2)+"_CUSTO"+Str(mv_par09,1))
	Else
		Replace TRB->D2_CUSTO With &(cAlias+"->"+Subs(cAlias,2,2)+"_CUSTO"+If((mv_par09==1),"",Str(mv_par09,1)))
	EndIf
	MsUnlock()
	dbSelectArea(cAlias)
	dbSkip()
EndDo
TRB->(dbGoTop())
Return   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  21/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

///             X1_ORDEM	X1_PERGUNT        	  X1_PERSPA	                X1_PERENG            	VARIAVL	  TIP  TAM DEC PRE GSC VL  X1_VAR01	 X1_DEF01	    X1_DEFSPA1     	     X1_DEFENG1        X1_CNT01          X1_VAR02	X1_DEF02	      X1_DEFSPA2	    X1_DEFENG2	      X1_CNT02       	X1_VAR03	      X1_DEF03	        X1_DEFSPA3	      X1_DEFENG3	    X1_CNT03   X1_VAR04	X1_DEF04   X1_DEFSPA4  X1_DEFENG4	X1_CNT04	 X1_VAR05	  X1_DEF05	 X1_DEFSPA5	 X1_DEFENG5	  X1_CNT05	 X1_F3 X1_PYME	 X1_GRPSXG	X1_HELP
AAdd( aRegs, { cPerg, "01","Armazem de ?          ","?De Deposito?       ","From Warehouse ?       ","mv_ch1","C",2,0,0,"G","","MV_PAR01","			  ","				   ","				 ","	           ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "02","Armazem ate ?         ","?A  Deposito?       ","To Warehouse ?         ","mv_ch2","C",2,0,0,"G","","MV_PAR02","			  ","	               ","               ","ZZ             ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "03","Dt Digitacao De ?     ","?De Fch.Registro?   ","From Typing Date ?     ","mv_ch3","D",8,0,0,"G","","MV_PAR03","			  ","	               ","               ","'01/01/00'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "04","Dt Digitacao Ate ?    ","?A  Fch.Registro?   ","To Typing Date ?       ","mv_ch4","D",8,0,0,"G","","MV_PAR04","			  ","	               ","               ","'31/12/04'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "05","Tipo de ?	          ","?De Tipo?           ","From Type ?            ","mv_ch5","C",2,0,0,"G","","MV_PAR05","			  ","				   ","				 ","               ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","02 ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "06","Tipo ate ?	          ","?A  Tipo?           ","To Type ?              ","mv_ch6","C",2,0,0,"G","","MV_PAR06","			  ","                  ","               ","ZZ             ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","02 ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "07","Produto de ?	      ","?De Producto?       ","From Product ?         ","mv_ch7","C",25,0,0,"G","","MV_PAR07","			  ","				   ","				 ","               ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "08","Produto ate ?	      ","?A  Producto?       ","To Product ?           ","mv_ch8","C",25,0,0,"G","","MV_PAR08","			  ","                  ","               ","ZZZZZZZZZZZZZZZ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "09","Qual a moeda ?	      ","?Cual Moneda?       ","Which Currency ?       ","mv_ch9","N",1,0,1,"C","","MV_PAR09","1a moeda    ","1a Moneda         ","Currency 1     ","               ","        ","2a moeda       ","2a Moneda      ","Currency 2     ","               ","               ","3a moeda       ","3a Moneda      ","Currency 3	  ","       ","       ","4a moeda","4a Moneda","Currency 4","          ","          ","5a moeda","5a Moneda","Currency 5","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "10","Considera Vlr IPI ?   ","?Considera Vlr IPI? ","Consider IPI Value ?   ","mv_cha","N",1,0,2,"C","","MV_PAR10","Sim         ","Si                ","Yes            ","               ","        ","Nao            ","No             ","No             ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "11","Considera Devolucao ? ","?Consd. Devolucion? ","Consider Return ?      ","mv_chb","N",1,0,3,"C","","MV_PAR11","Dt.NF.Origem","Fch.Fact.Origen   ","Date Orig. Inv.","               ","        ","Dt.NF.Devolucao","Fch Fact.Devuel","Return Invoice ","               ","               ","Nao Considera  ","No Considera   ","Do Not Consider","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "12","TES Qto a Estoque ?	  ","?TES del Stock?	 ","Inventory relat.TIO ?  ","mv_chc","N",1,0,3,"C","","MV_PAR12","Movimenta   ","Afecta            ","Movement       ","               ","        ","Nao Movimenta  ","No Afecta      ","Not Movement   ","               ","               ","Ambos          ","Ambos          ","Both			  ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )	
AAdd( aRegs, { cPerg, "13","TES Qto a Duplicata ? ","?TES del Titulo?    ","T. Note relat. TIO ?   ","mv_chd","N",1,0,3,"C","","MV_PAR13","Gera        ","Genera            ","Generate       ","               ","        ","Nao Gera       ","No Genera      ","No Generate    ","               ","               ","Ambos          ","Ambos          ","Both			  ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "14","Considera Vlr ICMS ?  ","?Considera Vlr ICMS?","Consider ICMS Value ?  ","mv_che","N",1,0,1,"C","","MV_PAR14","Sim         ","Si                ","Yes            ","               ","        ","Nao            ","No             ","No             ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "15","Abate Imp Nao Fat ?	  ","?Desc.Imp.No Fact?  ","Deduc.NonBilled Tax ?  ","mv_chf","N",1,0,1,"C","","MV_PAR15","Nao         ","No                ","No             ","               ","        ","Sim            ","Si             ","Yes            ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "16","Perc. Abatimento ?	  ","?Porc. Descuento?   ","Deduction % ?          ","mv_chg","N",5,2,0,"G","","MV_PAR16","			  ","                  ","               ","           0.00","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "17","Inclui Dev. Compra ?  ","?Incluye Dev.Compra?","Insert Purch.Return ?  ","mv_chh","N",1,0,1,"C","","MV_PAR17","Sim         ","Si                ","Yes            ","               ","        ","Nao            ","No             ","No             ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
                               
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





