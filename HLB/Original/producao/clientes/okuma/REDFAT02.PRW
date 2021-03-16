#INCLUDE "MATR780.CH"
#INCLUDE "FIVEWIN.CH"
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ REDFAT02  ≥ Autor ≥ XIS INFORMATICA      ≥ Data ≥ 19.04.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Relacao de Vendas por Cliente, quantidade de cada Produto  ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ REDFAT02(void)                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ50ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

/*
Funcao      : REDFAT02
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Relacao de Vendas por Cliente, quantidade de cada Produto
Autor     	: XIS INFORMATICA
Data     	: 16/04/04  
Obs         : 
TDN         :
Revis„o     : Tiago Luiz MendonÁa 
Data/Hora   : 17/07/2012
MÛdulo      : Faturamento
Cliente     : Okuma
*/ 

*------------------------*
 USER FUNCTION REDFAT02()
*------------------------*

LOCAL wnrel
LOCAL tamanho:= "M"
LOCAL titulo := OemToAnsi(STR0001)	//"Estatisticas de Vendas (Cliente x Produto)"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"totalizando por produto e escolhendo a moeda forte para os Valores."
LOCAL cDesc3 := ""
LOCAL cString:= "SD2"

PRIVATE aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="REDFAT02"
PRIVATE nLastKey := 0
PRIVATE cPerg   :="REDF02    "

SF1->(dbsetorder(1))       // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA 
SF2->(dbsetorder(1))       // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica as perguntas selecionadas                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

VALIDPERG()
pergunte(cPerg,.T.)


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis utilizadas para parametros                         ≥
//≥ mv_par01             // De Cliente                           ≥
//≥ mv_par02             // Ate Cliente                          ≥
//≥ mv_par03             // De Data                              ≥
//≥ mv_par04             // Ate a Data                           ≥
//≥ mv_par05             // De Produto                           ≥
//≥ mv_par06             // Ate o Produto                        ≥
//≥ mv_par07             // Do Vendedor                          ≥
//≥ mv_par08             // Ate Vendedor                         ≥
//≥ mv_par09             // Moeda                                ≥
//≥ mv_par10             // Inclui DevoluáÑo                     ≥
//≥ mv_par11             // Mascara do Produto                   ≥
//≥ mv_par12             // Aglutina Grade                       ≥
//≥ mv_par13	// Quanto a Estoque Movimenta/Nao Movta/Ambos     ≥
//≥ mv_par14	// Quanto a Duplicata Gera/Nao Gera/Ambos         ≥
//≥ mv_par15   // Quanto a Devolucao NF Original/NF Devolucao    ≥
//≥ mv_par16   // Quanto a Descricao  Produto  Prod x Cli.       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Envia controle para a funcao SETPRINT                        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta o Cabecalho de acordo com o tipo de emissao            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//MUDAN«AS JOSE

//titulo := STR0006	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
//Cabec1 := STR0007	//"CLIENTE   RAZAO SOCIAL"
//Cabec2 := STR0008	//"PRODUTO             DESCRICAO                  NOTA FISCAL EMISSAO     QUANTIDADE   PRECO UNITARIO            TOTAL VENDEDOR"
                    // 123456789012345 123456789012345678901234567890 123456/123 12/12/1234 123456789012 1234567890123456 1234567890123456 123456/123456/123456/123456/123456
					// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
					//           1         2         3         4         5         6         7         8         9        10        11

titulo := STR0006	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
Cabec1 := "CLIENTE   RAZAO SOCIAL"
Cabec2 := "PRODUTO                       DESCRICAO                  NOTA FISCAL      EMISSAO     QUANTIDADE   PRECO UNITARIO            TOTAL VENDEDOR"
       // 1234567890123456789012345 123456789012345678901234567890  123456/123       12/12/1234 123456789012 1234567890123456 1234567890123456 123456/123456/123456/123456/123456
	   // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
	   //           1         2         3         4         5         6         7         8         9        10        11        11        12        13        14        15



wnrel:="REDFAT02"

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.T.)

If nLastKey==27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C780Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ C780IMP  ≥ Autor ≥ XIS INFORMATICA       ≥ Data ≥ 19.04.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chamada do Relatorio                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ REDFAT02                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function C780Imp(lEnd,WnRel,cString)

LOCAL CbTxt
LOCAL CbCont,cabec1,cabec2,cabec3
LOCAL nTotCli1:= 0,nTotCli2:=0,nTotGer1 := 0,nTotGer2 := 0
LOCAL nOrdem
LOCAL tamanho:= "M"
LOCAL limite := 156
LOCAL titulo := OemToAnsi(STR0006)	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"totalizando por produto e escolhendo a moeda forte para os Valores."
LOCAL cDesc3 := ""
LOCAL cMoeda
LOCAL nAcN1  := 0, nAcN2 := 0, nV := 0
LOCAL cClieAnt := "", cProdAnt := "", cLojaAnt := ""
LOCAL lContinua := .T. , lProcessou := .F. , lNewProd := .T.
LOCAL cMascara :=GetMv("MV_MASCGRD")
LOCAL nTamRef  :=Val(Substr(cMascara,1,2))
LOCAL nTamLin  :=Val(Substr(cMascara,4,2))
LOCAL nTamCol  :=Val(Substr(cMascara,7,2))
LOCAL cProdRef :=""
LOCAL nTotQuant:=0
LOCAL nReg     :=0
LOCAL cFiltro  := ""
Local cEstoq := If( (mv_par13 == 1),"S",If( (mv_par13 == 2),"N","SN" ))
Local cDupli := If( (mv_par14 == 1),"S",If( (mv_par14 == 2),"N","SN" ))
Local cArqTrab,cArqTrd2, cArqTrb1, cArqTrab1, cArqTra71,cArqTra72
Local cCondicao1, cCondicao2, cCondicao3, cCondicao4, cCondicao5
Local aDevImpr := {}
Local cVends   := ""
Local nVend    := FA440CntVend()
Local nDevQtd 	:=0
Local nDevVal 	:=0
Local aDev		:={}
Local nIndD2    :=0

Private nIndD1  :=0

Private nDecs:=msdecimais(mv_par09)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta o Cabecalho de acordo com o tipo de emissao            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//titulo := STR0006	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
//Cabec1 := STR0009	//"CLIENTE  RAZAO SOCIAL"
//Cabec2 := STR0008	//"PRODUTO             DESCRICAO                       NOTA FISCAL      EMISSAO    QUANTIDADE    PRECO UNITARIO          TOTAL"
                    // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                    //           1         2         3         4         5         6         7         8         9        10        11        12           
                    
titulo := STR0006	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
Cabec1 := "CLIENTE  RAZAO SOCIAL"
Cabec2 := "PRODUTO                       DESCRICAO                  NOTA FISCAL      EMISSAO     QUANTIDADE   PRECO UNITARIO            TOTAL"
        // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
        //           1         2         3         4         5         6         7         8         9        10        11        12           

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cMoeda := STR0010+GetMV("MV_SIMB"+Str(mv_par09,1))		//"Valores em "
titulo := titulo+" "+cMoeda

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria filtro para impressao das devolucoes                    ≥
//≥ *** este filtro possui 208 posicoes  ***                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cCondicao1 := 'D1_FILIAL=="' + xFilial("SD1") + '".And.'
cCondicao1 += 'D1_FORNECE>="' + mv_par01 + '".And.'
cCondicao1 += 'D1_FORNECE<="' + mv_par02 + '".And.'
cCondicao1 += 'DtoS(D1_DTDIGIT)>="' + DtoS(mv_par03) + '".And.'
cCondicao1 += 'DtoS(D1_DTDIGIT)<="' + DtoS(mv_par04) + '".And.'
cCondicao1 += 'D1_P_COD>="' + mv_par05 + '".And.'
cCondicao1 += 'D1_P_COD<="' + mv_par06 + '".And.'
cCondicao1 += 'D1_TIPO=="D"'
cArqTrab1 := CriaTrab("",.F.)
#IFDEF TOP
	IndRegua("SD1",cArqTrab1,"D1_FILIAL+D1_FORNECE+D1_LOJA+D1_P_COD",,cCondicao1,STR0011)		//"Selecionando Registros..."
#ELSE
	IndRegua("SD1",cArqTrab1,"D1_FILIAL+D1_FORNECE+D1_LOJA+D1_P_COD",,cCondicao1,STR0011)		//"Selecionando Registros..."
#ENDIF
nIndD1 := RetIndex()
#IFNDEF TOP
	dbSetIndex(cArqTrab1+ordBagExt())
#ENDIF
dbSetOrder(nIndD1+1)
dbSeek(xFilial("SD1"))

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta filtro para processar as vendas por cliente            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cFiltro := SD2->(dbFilter())
If Empty(cFiltro)
	bFiltro := { || .T. }
Else
	cFiltro := "{ || " + cFiltro + " }"
	bFiltro := &(cFiltro)
Endif
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta filtro para processar as vendas por cliente            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DbSelectArea("SD2")
cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
cCondicao += 'D2_CLIENTE >= "' + mv_par01 + '" .And. '
cCondicao += 'D2_CLIENTE <= "' + mv_par02 + '" .And. '
cCondicao += 'DTOS(D2_EMISSAO) >= "' + DTOS(mv_par03) + '" .And. '
cCondicao += 'DTOS(D2_EMISSAO) <= "' + DTOS(mv_par04) + '" .And. '
cCondicao += 'D2_P_COD >= "' + mv_par05 + '" .And. '
cCondicao += 'D2_P_COD <= "' + mv_par06 + '" .And. '
cCondicao += '!(D2_TIPO $ "BD")'
cArqTrab := Subs(cArqTrab1,1,7)+"A"
#IFDEF TOP
	IndRegua(cString,cArqTrab,"D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_P_COD+D2_SERIE+D2_DOC+D2_ITEM",,cCondicao,STR0011)		//"Selecionando Registros..."
#ELSE
	IndRegua(cString,cArqTrab,"D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_P_COD+D2_SERIE+D2_DOC+D2_ITEM",,cCondicao,STR0011)		//"Selecionando Registros..."
#ENDIF
nIndD2 := RetIndex()
#IFNDEF TOP
	dbSetIndex(cArqTrab+ordBagExt())
#ENDIF
dbSetOrder(nIndD2+1)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se aglutinara produtos de Grade                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
SetRegua(RecCount())		// Total de Elementos da regua

If ( SD2->D2_GRADE=="S" .And. MV_PAR12 == 1)
	lGrade := .T.
	bGrade := { || Substr(D2_P_COD, 1, nTamref) }
Else
	lGrade := .F.
	bGrade := { || D2_P_COD }
Endif
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Procura pelo 1o. cliente valido                              ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea("SA1")
dbSetOrder(1)            // A1_FILIAL + A1_COD + A1_LOJA
dbSeek(xFilial()+mv_par01, .t.)

While SA1->( ! EOF() .AND. A1_COD <= MV_PAR02 ) .And. lContinua .And. SA1->A1_FILIAL == xFilial("SA1")

	If lEnd
		@Prow()+1,001 Psay STR0012	//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIf

	lNewCli := .T.

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Procura pelas saidas daquele cliente                     ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	DbSelectArea("SD2")
    dbSetOrder(nIndD2+1)
    If DbSeek(xFilial("SD2")+SA1->A1_COD+SA1->A1_LOJA)
		lRet:=ValidMasc(SD2->D2_P_COD,MV_PAR11)

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Montagem da quebra do relatorio por  Cliente             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		cClieAnt := SA1->A1_COD
		cLojaAnt := SA1->A1_LOJA
		lNewProd := .T.
		lNewCli  := .T.
		nTotCli1 := 0
		nTotCli2 := 0
		While !Eof() .and. ;
            (D2_FILIAL+D2_CLIENTE+D2_LOJA) == (xFilial("SD2")+cClieAnt+cLojaAnt)

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Verifica Se eh uma tipo de nota valida                   ≥
			//≥ Verifica intervalo de Codigos de Vendedor                ≥
			//≥ Valida o produto conforme a mascara                      ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If	! Eval(bFiltro) .Or. !A780Vend(@cVends,nVend) .Or. !lRet .or. SD2->D2_TIPO$"BD"
				dbSkip()
				Loop
			EndIf

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Impressao do Cabecalho.                                  ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If Li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				lProcessou := .T.
			EndIf

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Impressao  dos dados do Cliente                          ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If lNewCli

				If Li > 51
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					lProcessou := .T.
				EndIf

				@ Li,000 Psay Repli('-',132)
				Li++
				@ Li,000 Psay SD2->D2_CLIENTE+"   "+SA1->A1_NOME
				If !Empty(SA1->A1_OBSERV)
					Li++
					@ Li,000 Psay STR0013+SA1->A1_OBSERV		//"Obs.: "
				EndIf
				Li++
				lNewCli := .F.
			Endif

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Impressao da quebra por produto e NF                     ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			cProdAnt := Eval(bGrade)
			lNewProd := .T.

			While ! Eof() .And. ;
				( D2_FILIAL + D2_CLIENTE + D2_LOJA  + EVAL(bGrade) ) == ;
                ( xFilial("SD2") + cClieAnt   + cLojaAnt + cProdAnt )
				IncRegua()

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Avalia TES                                               ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If !AvalTes(SD2->D2_TES,cEstoq,cDupli) .Or. !Eval(bFiltro)
					dbSkip()
					Loop
				Endif

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Impressao do Cabecalho.                                  ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					@ Li,000 Psay Repli('-',132)
					Li++
					@ Li,000 Psay SD2->D2_CLIENTE+"   "+SA1->A1_NOME
					If !Empty(SA1->A1_OBSERV)
						Li++
						@ Li,000 Psay STR0013+SA1->A1_OBSERV		//"Obs.: "
					EndIf
					Li+=2
				EndIf

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Faz Impressao de Codigo e Descricao Do Produto.          ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If lNewProd
					lNewProd := .F.
					Li+=2
					@Li ,  0 Psay Eval(bGrade)
					///dbSelectArea("SB1")
                    ///dbSetOrder(1)             /// B1_FILIAL + B1_COD
                    _CREINDB1()
                    dbSeek(xFilial("SB1")+SD2->D2_P_COD)
					If mv_par16 = 1
						dbSelectArea("SD2")
						@li , 26 Psay Substr(SB1->B1_DESC,1,30)
					Else
						//dbSelectArea("SA7")
						//dbSetOrder(2)            /// A7_FILIAL + A7_PRODUTO + A7_CLIENTE + A7_LOJA
                        _CREINDA72()
                        If dbSeek(xFilial("SA7")+SD2->(D2_P_COD+D2_CLIENTE+D2_LOJA))
							@li , 26 Psay Substr(SA7->A7_DESCCLI,1,30)
						Else
							@li , 26 Psay Substr(SB1->B1_DESC,1,30)
						Endif
						dbSelectArea("SD2")
					EndIf
				EndIf

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Caso seja grade aglutina todos produtos do mesmo Pedido  ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If lGrade  // Aglutina Grade
					cProdRef:= Substr(SD2->D2_P_COD,1,nTamRef)
					cNumPed := D2_PEDIDO
					nReg    := 0
					nDevQtd :=0
					nDevVal :=0

					While !Eof() .And. cProdRef == Eval(bGrade) .And.;
                        SD2->D2_GRADE == "S" .And. cNumPed == D2_PEDIDO .And.;
                        SD2->D2_FILIAL == xFilial("SD2")

						nReg := Recno()
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ Valida o produto conforme a mascara         ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						lRet:=ValidMasc(SD2->D2_P_COD,MV_PAR11)
						If !lRet .Or. !Eval(bFiltro)
							dbSkip()
							Loop
						EndIf

						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ Tratamento das Devoluáoes   ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						If mv_par10 == 1 //inclui Devolucoes
							SomaDev(@nDevQtd, @nDevVal , @aDev)
						EndIf

						nTotQuant += SD2->D2_QUANT
						dbSkip()

					EndDo

					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Verifica se processou algum registro        ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If nReg > 0
						dbGoto(nReg)
						nReg:=0
					EndIf

				Else
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Tratamento das devolucoes   ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					nDevQtd :=0
					nDevVal :=0

					If mv_par10 == 1 //inclui Devolucoes
						SomaDev(@nDevQtd, @nDevVal , @aDev)
					EndIf

					nTotQuant := D2_QUANT

				EndIf

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Imprime os dados da NF                                   ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 				SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
				
				@Li , 58 Psay D2_DOC+'/'+D2_SERIE
                @Li , 75 Psay D2_EMISSAO
                @Li , 86 Psay nTotQuant          PICTURE PesqPictqt("D2_QUANT",12)
				nAcN1 += nTotQuant

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Faz Verificacao da Moeda Escolhida e Imprime os Valores  ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				nVlrUnit := xMoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,MV_PAR09,SD2->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                @Li , 99 Psay nVlrUnit           PICTURE PesqPict("SD2","D2_PRCVEN",16,mv_par09)

				If SD2->D2_TIPO $ "CIP"
                    @Li ,116 Psay nVlrUnit        PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					nAcN2 += nVlrUnit
				Else
					If SD2->D2_GRADE == "S" .And. MV_PAR12 == 1 // Aglutina Grade
						nVlrTot:= nVlrUnit * nTotQuant
                        @Li ,116 Psay nVlrTot         PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					Else
//						nVlrTot:=iif(mv_par09 # 1,( D2_TOTAL / RecMoeda(D2_EMISSAO,MV_PAR09) ), D2_TOTAL )
					    nVlrTot:=xmoeda(D2_TOTAL,SF2->F2_MOEDA,mv_par09,D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
                        @Li ,116 Psay nVlrTot         PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					EndIf
					nAcN2 += nVlrTot
				EndIf
				A780Vend(@cVends,nVend)
                @Li, 133 Psay Subs(cVends,1,13)
				For nV := 15 to Len(cVends)
					li ++
					@Li, 123 Psay Subs(cVends,nV,20)
					nV += 20
				Next
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Imprime as devolucoes do produto selecionado             ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If nDevQtd!=0
					Li++
					@Li,063 Psay STR0017 // "DEV"
					nVlrTot:= nDevVal
                    @Li,086 Psay nDevQtd          PICTURE "@)"+PesqPictqt("D2_QUANT",12)
                    @Li,116 Psay nVlrTot          PICTURE "@)"+PesqPict("SD2","D2_TOTAL",16,mv_par09)
					nAcN1+= nDevQtd
					nAcN2+= nVlrTot
				EndIf
				Li++
				nTotQuant := 0
				dbSkip()

			EndDo

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Acumula o total geral do relatorio                       ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			nTotGer1 += nAcN1
			nTotGer2 += nAcN2

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Acumula o total por cliente                              ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			nTotCli1 += nAcN1
			nTotCli2 += nAcN2

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Imprime o total do produto selecionado                   ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If nAcN1#0 .Or. nAcN2#0	.Or. nDevQtd#0
				Li++
				@Li ,  17 Psay STR0014+cProdAnt	//"TOTAL DO PRODUTO - "
				@Li ,  62 Psay "---->"
                @Li ,  86 Psay nAcN1 PICTURE PesqPictqt("D2_QUANT",12)
                @Li , 116 Psay nAcN2 PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
				nAcN1 := 0
				nAcN2 := 0
				cProdAnt := D2_P_COD
			EndIf

		EndDo
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Ocorreu quebra por cliente                               ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If !(lNewCli)
			LI+=2
			@Li , 17 Psay STR0015+cClieAnt+'/'+cLojaAnt	//"TOTAL DO CLIENTE - "
			@Li , 62 Psay "---->"
            @Li , 86 Psay nTotCli1 PICTURE PesqPictqt("D2_QUANT",16)
            @Li ,114 Psay nTotCli2 PICTURE PesqPict("SD2","D2_TOTAL",18,mv_par09)
			LI++
		EndIf
		cClieAnt := ""
		cLojaAnt := ""
		nTotCli1 := 0
		nTotCli2 := 0

	Else
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Procura pelas devolucoes dos clientes que nao tem NF SAIDA  ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		nTotCli1 := 0
		nTotCli2 := 0
		DbSelectArea("SD1")
        dbSetOrder(nIndD1+1)
        If DbSeek(xFilial("SD1")+SA1->A1_COD+SA1->A1_LOJA)
			lRet:=ValidMasc(SD1->D1_P_COD,MV_PAR11)
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Procura as devolucoes do periodo, mas que nao pertencem  ≥
			//≥ as NFS ja impressas do cliente selecionado               ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If mv_par10 == 1  // Inclui Devolucao

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Soma Devolucoes          ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				While ( D1_FILIAL + D1_FORNECE + D1_LOJA ) == ;
                    ( xFilial("SD1") + SA1->A1_COD+ SA1->A1_LOJA)  .AND. ! Eof()

					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Verifica Vendedores da N.F.Original ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

                    dbSelectArea("SD2")
                    nSavOrd := IndexOrd()
                    //dbSetOrder(3)        // D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM

                    _CREINDD2()
                    
                    CtrlVndDev := .F.

                    dbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_P_COD)

                    While !Eof() .And. (xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_P_COD) == ;
                          D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_P_COD

						If !Empty(SD1->D1_ITEMORI) .AND. SD1->D1_ITEMORI != D2_ITEM

                        	dbSkip()
                            Loop

                        Else

                        	CtrlVndDev := A780Vend(@cVends,nVend)

						Endif

							dbSkip()

					End

					dbSelectArea("SD2")
					dbSetOrder(nSavOrd)

					dbSelectArea("SD1")

					If !(CtrlVndDev)
						dbSkip()
						Loop
					EndIf

					lProcessou := .t.

					If li > 55
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					EndIf

					If lNewCli

						If li > 51
							cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
						EndIf

						@ Li,000 Psay Repli('-',132)

						Li++
						@ Li,000 Psay SA1->A1_COD
						@ Li,019 Psay SA1->A1_NOME
						If !Empty(SA1->A1_OBSERV)
							Li++
							@ Li,000 Psay STR0013+SA1->A1_OBSERV		//"Obs.: "
						EndIf

						Li+=2

						lNewCli := .F.

					EndIf

					LI++
					SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
					@Li ,  0 Psay SD1->D1_P_COD
					@li , 26 Psay STR0017 //"DEV"
					@Li , 58 Psay D1_DOC+'/'+D1_SERIE // VERIFICAR PORQUE -
					nVlrTot:=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,mv_par09,SD1->D1_EMISSAO,nDecs,SF1->F1_TXMOEDA)
               @Li,086 Psay -D1_QUANT        PICTURE "@)"+PesqPictqt("D1_QUANT",12)
               @Li,116 Psay -nVlrTot         PICTURE "@)"+PesqPict("SD1","D1_TOTAL",16,mv_par09)
					nTotCli1 -= D1_QUANT
					nTotCli2 -= nVlrTot
					nTotGer1 -= D1_QUANT
					nTotGer2 -= nVlrTot

					dbSkip()
				EndDo

				If (nTotCli1 != 0) .or. (nTotCli2 != 0)
					LI+=2
					@Li , 17 Psay STR0015+SA1->A1_COD	//"TOTAL DO CLIENTE - "
					@Li , 62 Psay "---->"
                    @Li , 86 Psay nTotCli1 PICTURE "@)"+PesqPictqt("D2_QUANT",16)
                    @Li ,114 Psay nTotCli2 PICTURE "@)"+PesqPict("SD2","D2_TOTAL",18,mv_par09)
				EndIf

			EndIf

		Endif

	Endif
	DbSelectArea("SA1")
	DbSkip()
EndDo

If lProcessou
	Li+=2
	@Li , 17 Psay STR0016		//"T O T A L   G E R A L                        ---->"
    @Li , 86 Psay nTotGer1 PICTURE "@)"+PesqPictqt("D2_QUANT",16)
    @Li ,114 Psay nTotGer2 PICTURE "@)"+PesqPict("SD2","D2_TOTAL",18,mv_par09)
	roda(cbcont,cbtxt,tamanho)
Endif

dbSelectArea("SD1")
Set Filter To
RetIndex("SD1")

//dbSelectArea("SA7")
//dbSetOrder(1)          /// A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_PRODUTO
_CREINDA71()

dbSelectArea("SD2")
Set Filter To
RetIndex("SD2")

fErase(cArqTrab+OrdBagExt())
fErase(cArqTrab1+OrdBagExt())

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()

Return .T.

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ A780Vend ≥ Autor ≥ XIS INFORMATICA       ≥ Data ≥ 19.04.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Verifica Intervalo de Vendedores                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ REDFAT02			                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
STATIC Function A780Vend(cVends,nVend)
Local sAlias:=Alias(),sVend,sCampo
Local lVend:=.F., cVend
Local nx
cVends := ""

dbSelectArea("SF2")
dbSetOrder(1)             // F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
if dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
	cVend := "1"
	For nx := 1 to nVend
		sCampo := "F2_VEND" + cVend
		sVend := FieldGet(FieldPos(sCampo))
		If !Empty(sVend)
			cVends += If(Len(cVends)>0,"/","") + sVend
		EndIf
		cVend := Soma1(cVend, 1)
	Next
	cVend := "1"
	For nx := 1 to nVend
		sCampo := "F2_VEND" + cVend
		sVend := FieldGet(FieldPos(sCampo))
		if sVend < mv_par07 .or. sVend > mv_par08
			lVend:=.F.
		Else
			lVend:=.T.
			Exit
		Endif
		cVend := Soma1(cVend, 1)
	Next
endif

dbSelectArea(sAlias)

return(lVend)


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ SomaDev  ≥ Autor ≥ XIS INFORMATICA       ≥ Data ≥ 19.04.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Soma devolucoes de Vendas                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ REDFAT02			                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function SomaDev(nDevQtd, nDevVal, aDev )
dbSelectArea("SD1")
dbSetOrder(nIndD1+1)
If dbSeek(xFilial("SD1")+SD2->(D2_CLIENTE + D2_LOJA + D2_P_COD ))
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Soma Devolucoes          ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	While ( D1_FILIAL 		+ D1_FORNECE + D1_LOJA + D1_P_COD ) == ;
        ( SD2->( xFilial("SD2")+ D2_CLIENTE + D2_LOJA + D2_P_COD ) ) .AND. ;
		! Eof()                   
		SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
		If SD1->( D1_NFORI + D1_SERIORI + D1_ITEMORI) == ;
			SD2->( D2_DOC   + D2_SERIE   + D2_ITEM )
			Aadd(aDev, D1_FORNECE + D1_LOJA + D1_P_COD + D1_NFORI + D1_SERIORI + D1_ITEMORI)
			nDevQtd -= D1_QUANT
			nDevVal -=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,mv_par09,SD1->D1_EMISSAO,nDecs+1,SF1->F1_TXMOEDA)
		ElseIf mv_par15 == 2 .And. D1_DTDIGIT < SD2->D2_EMISSAO .And.;
		SD1->( D1_NFORI + D1_SERIORI + D1_ITEMORI) < ;
		SD2->( D2_DOC   + D2_SERIE   + D2_ITEM ) .And.;
		Ascan(aDev, D1_FORNECE + D1_LOJA + D1_P_COD + D1_NFORI + D1_SERIORI + D1_ITEMORI) == 0
			Aadd(aDev, D1_FORNECE + D1_LOJA + D1_P_COD + D1_NFORI + D1_SERIORI + D1_ITEMORI)
			nDevQtd -= D1_QUANT
			nDevVal -=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,mv_par09,SD1->D1_EMISSAO,nDecs+1,SF1->F1_MOEDA)
			dbSelectArea("SD1")
		EndIf
		dbSkip()
	EndDo
EndIf
dbSelectArea("SD2")
Return .t.     


STATIC FUNCTION _CREINDB1()
	dbSelectArea("SB1")
	cCondicao2 := ""
    /// dbSetOrder(1)             /// B1_FILIAL + B1_COD
	cArqTrb1 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SB1",cArqTrb1,"B1_FILIAL+B1_P_COD",,cCondicao2,STR0011)		//"Selecionando Registros..."
	#ELSE
		IndRegua("SB1",cArqTrb1,"B1_FILIAL+B1_P_COD",,cCondicao2,STR0011)		//"Selecionando Registros..."
	#ENDIF
	nIndD1 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrb1+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD1+1)
RETURN


STATIC FUNCTION _CREINDD2()
	dbSelectArea("SD2")
	cCondicao3 := ""
    /// dbSetOrder(3)             /// D2_filial + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
	cArqTrd2 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SD2",cArqTrd2,"D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_P_COD + D2_ITEM",,cCondicao3,STR0011)		//"Selecionando Registros..."
	#ELSE
		IndRegua("SD2",cArqTrd2,"D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_P_COD + D2_ITEM",,cCondicao3,STR0011)		//"Selecionando Registros..."
	#ENDIF
	nIndD1 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrd2+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD1+1)
RETURN


STATIC FUNCTION _CREINDA71()
	dbSelectArea("SA7")
	cCondicao4 := ""
    /// dbSetOrder(1)             /// A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_PRODUTO
	cArqTra71 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SA7",cArqTra71,"A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_P_PROD",,cCondicao4,STR0011)		//"Selecionando Registros..."
	#ELSE
		IndRegua("SA7",cArqTra71,"A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_P_PROD",,cCondicao4,STR0011)		//"Selecionando Registros..."
	#ENDIF
	nIndD1 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTra71+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD1+1)
RETURN


STATIC FUNCTION _CREINDA72()
	dbSelectArea("SA7")
	cCondicao5 := ""
    /// dbSetOrder(2)             /// A7_FILIAL + A7_PRODUTO + A7_CLIENTE + A7_LOJA 
	cArqTra72 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SA7",cArqTra72,"A7_FILIAL + A7_P_PROD + A7_CLIENTE + A7_LOJA",,cCondicao5,STR0011)		//"Selecionando Registros..."
	#ELSE
		IndRegua("SA7",cArqTra72,"A7_FILIAL + A7_P_PROD + A7_CLIENTE + A7_LOJA",,cCondicao5,STR0011)		//"Selecionando Registros..."
	#ENDIF
	nIndD1 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTra72+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD1+1)
RETURN

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥VALIDPERG ∫ Autor ≥ AP5 IDE            ∫ Data ≥  21/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Verifica a existencia das perguntas criando-as caso seja   ∫±±
±±∫          ≥ necessario (caso nao existam).                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

///             X1_ORDEM	X1_PERGUNT        	  X1_PERSPA	                X1_PERENG            	VARIAVL	  TIP TAM  DEC PRE GSC VL	X1_VAR01  X1_DEF01	    X1_DEFSPA1     	     X1_DEFENG1     	 X1_CNT01         X1_VAR02	X1_DEF02	         X1_DEFSPA2	      X1_DEFENG2	      X1_CNT02       	X1_VAR03	   X1_DEF03	         X1_DEFSPA3	      X1_DEFENG3	    X1_CNT03   X1_VAR04	X1_DEF04   X1_DEFSPA4  X1_DEFENG4	X1_CNT04	 X1_VAR05     X1_DEF05	 X1_DEFSPA5	 X1_DEFENG5	  X1_CNT05	 X1_F3	X1_PYME	 X1_GRPSXG	X1_HELP
AAdd( aRegs, { cPerg, "01","Do Cliente ?          ","?De Cliente ?       ","From Customer ?        ","mv_ch1","C",6,0,0,"G","","MV_PAR01","			  ","				   ","				 ","	           ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","CLI","S      ","001     ","        "} )		
AAdd( aRegs, { cPerg, "02","Ate Cliente ?         ","?A  Cliente ?       ","To Customer ?          ","mv_ch2","C",6,0,0,"G","","MV_PAR02","			  ","	               ","               ","ZZZZZZ         ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","CLI","S      ","001     ","        "} )		
AAdd( aRegs, { cPerg, "03","Da Data de Emissao ?  ","?De Fecha Emision ? ","From Issue Date ?      ","mv_ch3","D",8,0,0,"G","","MV_PAR03","			  ","	               ","               ","'01/01/03'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "04","Ate Data de Emissao ? ","?A Fecha Emision?   ","To Issue Date ?        ","mv_ch4","D",8,0,0,"G","","MV_PAR04","			  ","	               ","               ","'31/12/04'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "05","Do Produto?	          ","?De Producto?       ","From Product ?         ","mv_ch5","C",25,0,0,"G","","MV_PAR05","			  ","				   ","				 ","               ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "06","Ate Produto ?         ","?A Producto?        ","To Product ?           ","mv_ch6","C",25,0,0,"G","","MV_PAR06","			  ","                  ","               ","ZZZZZZZZZZZZZZZ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "07","Do Vendedor ?	      ","?De Vendedor?       ","From Sales Repres. ?   ","mv_ch7","C",6,0,0,"G","","MV_PAR07","			  ","				   ","				 ","               ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SA3","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "08","Ate Vendedor ?	      ","?A  Vendedor?       ","To Sales Repres. ?     ","mv_ch8","C",6,0,0,"G","","MV_PAR08","			  ","                  ","               ","ZZZZZZ         ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SA3","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "09","Imprime Valores Em ?  ","?Imprime Valores en?","Print Values in ?      ","mv_ch9","N",1,0,1,"C","","MV_PAR09","Moeda 1     ","Moneda 1          ","Currency 1     ","               ","        ","Moeda 2        ","Moneda 2       ","Currency 2     ","               ","               ","Moeda 3        ","Moneda 3       ","Currency 3	  ","       ","       ","Moeda 4 ","Moneda 4 ","Currency 4","          ","          ","Moeda 5 ","Moneda 5 ","Currency 5","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "10","Inclui Devolucao ?    ","?Incluye Devoluc.?  ","Include Return ?       ","mv_cha","N",1,0,1,"C","","MV_PAR10","Sim         ","Si                ","Yes            ","               ","        ","Nao            ","No             ","No             ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "11","Mascara do Produto ?  ","?Mascara Producto ? ","Product Mask  ?        ","mv_chb","C",25,0,0,"G","","MV_PAR11","            ","                  ","               ","***************","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "12","Aglutina prod.Grade ? ","?Aglom.Prod. Matriz?","Group Prod. Grid ?     ","mv_chc","N",1,0,1,"C","","MV_PAR12","Sim         ","Si                ","Yes            ","               ","        ","Nao            ","No             ","No             ","               ","               ","               ","               ","    			  ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","N      ","        ","        "} )	
AAdd( aRegs, { cPerg, "13","Quanto a Estoque ?    ","?Cuanto al Stock?   ","About Inventory ?      ","mv_chd","N",1,0,1,"C","","MV_PAR13","Movimenta   ","Crea Movimiento   ","Movement       ","               ","        ","Nao Movimenta  ","No Afecta      ","Do Not Move    ","               ","               ","Ambos          ","Ambos          ","Both			  ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "14","Quanto a Duplicata ?  ","?Cuanto a Titulo?   ","About Trade Note ?     ","mv_che","N",1,0,1,"C","","MV_PAR14","Gera        ","Genera            ","Generate       ","               ","        ","Nao Gera       ","No Genera      ","Do Not Generat ","               ","               ","Ambos          ","Ambos          ","Both           ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "15","Quanto a Devolucao ?  ","?Cuanto a Devoluc.? ","About Return ?         ","mv_chf","N",1,0,1,"C","","MV_PAR15","NF Original ","Fact. Original    ","Orig. Invoice  ","               ","        ","NF Devolucao   ","Fact.Devolucion","Return Invoice ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		
AAdd( aRegs, { cPerg, "16","Quanto a Descricao ?  ","?Descripcion ?      ","About Description ?    ","mv_chg","N",1,0,1,"C","","MV_PAR16","Produto     ","Producto          ","Product        ","               ","        ","Prod X Cliente ","Prod.vs.Client ","Prod.XCustomer ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","S      ","        ","        "} )		


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
