#include "rwmake.ch"        
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF  

/*
Funcao      : REDEST04
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Posicao Final de Estoque
Autor     	: 
Data     	: 
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Estoque
Cliente     : Okuma
*/ 

*-------------------------*
 User Function REDEST04()        
*-------------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AC_QINI,AC_VINI1,AC_VINI2,CBTXT,CBCONT,NORDEM")
SetPrvt("LIMITE,TAMANHO,NTIPO,M_PAG,LIN,TITULO")
SetPrvt("CDESC1,CDESC2,CDESC3,AORD,NCNTIMPR,CRODATXT")
SetPrvt("ARETURN,ALINHA,NOMEPROG,NLASTKEY,CPERG,NPAGINA")
SetPrvt("NIVEL,CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1")
SetPrvt("CSTRING,CABEC1,CABEC2,WNREL,TREGS,M_MULT")
SetPrvt("P_ANT,P_ATU,P_CNT,M_SAV20,M_SAV7,_CINDB9")
SetPrvt("_DATAFIM,_ALMOINI,_ALMOFIM,_PRODINI,_PRODFIM,UNIV")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³REDEST04  ³ Autor ³ XIS INFORMATICA       ³ Data ³ 17.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Emiss„o do Relatorio Saldos Finais do Estoque, ap¢s fechto. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OKUMA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFNDEF WINDOWS
//      #DEFINE PSAY SAY
#ENDIF

ac_QINI    := 0
ac_VINI1   := 0
ac_VINI2   := 0
CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=132
tamanho:="M"
nTipo  := 0
m_pag  := 1
lin    := 100
titulo :="Posi‡ao Final de Estoque"
cDesc1 :="Relatorio da posi‡ao final de estoque  ap¢s o fechamento mensal,"
cDesc2 :="demonstrando a quantidade, valor e custo m‚dio, em reais e d¢la-"
cDesc3 :="res.                                   "
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis padrao de todos os relatorios                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aReturn:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

aLinha   := {}
nomeprog :="REDEST04"
nLastKey := 0
cPerg    :="RED004    "
nPagina  := 1
nivel    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos dados de Entrada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFNDEF WINDOWS
   cSavScr1 := SaveScreen(3,0,24,79)
   cSavCur1 := SetCursor(0)
   cSavRow1 := ROW()
   cSavCol1 := COL()
   cSavCor1 := SetColor("bg+/b,,,")
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString  :="SB9"
cabec1   := "C¢digo                    Lc    Quantidade Estoque Reais C.M.Reais   Estoque US$  C.M. US$"
cabec2   := ""
*            0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*                      1         2         3         4         5         6         7         8         9
//           1234567890123456789012345


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VALIDPERG()

Pergunte(cPerg,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Data do Fechamento                   ³
//³ mv_par02             // Do  Almoxarifado                     ³
//³ mv_par03             // At‚ Almoxarifado                     ³
//³ mv_par04             // Do  Produto                          ³
//³ mv_par05             // At‚ Produto                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString := "SB9"
wnrel:="REDEST04"   // nome default do relatorio em disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey()== 27 .Or. nLastKey==27
   #IFNDEF WINDOWS
      RestScreen(3,0,24,79,cSavScr1)
   #ENDIF
   Return
Endif

SetDefault(aReturn,cString)

If LastKey()==27 .or. nLastKey==27
   #IFNDEF WINDOWS
      RestScreen(3,0,24,79,cSavScr1)
   #ENDIF
   Return
Endif

#IFDEF WINDOWS
     RptStatus({|| ADV015Imp()},titulo) //     RptStatus({|| Execute(ADV015Imp)},titulo)
     Return
//  ==>      Function ADV015Imp
Static Function ADV015Imp()
#ENDIF

titulo := titulo + " "+dtoc(mv_par01)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na regua de processamento               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
tregs 	:= RecCount()
m_mult 	:= IIf(tregs>0,70/tregs,1)
p_ant	:= 4
p_atu	:= 4
p_cnt	:= 0
#IFNDEF WINDOWS
   m_sav20 := dCursor(3)
   m_sav7  := SaveScreen(23,0,24,79)
#ENDIF

_cIndB9 := CriaTrab("",.f.)

DbSelectArea("SB9")
//_cIndex:=CriaTrab(Nil,.F.)
//IndRegua("SB9",_cIndex,"B9_FILIAL+dtos(B9_DATA)+B9_P_COD+B9_LOCAL",,,"Selecionando Registro...")
//DbSetIndex(_cIndex+OrdBagExt())
DbSetOrder(2)
DbGoTop()

//index on SB9->B9_FILIAL+dtos(SB9->B9_DATA)+SB9->B9_P_COD+SB9->B9_LOCAL to &_cIndB9

_fSELECTREC()

DbSelectArea("TRB")
DBGOTOP()
do while !Eof()
//   if SB9->B9_P_COD >=_prodini .and. SB9->B9_P_COD <= _prodfim .and. SB9->B9_DATA ==_datafim
//      if SB9->B9_LOCAL >= _almoini .and. SB9->B9_LOCAL == _almofim
         nCntImpr := nCntImpr + 1
         Imprime()
//      endif
//   endif
   TRB->(DbSkip())
enddo
Final()
Roda(nCntImpr,cRodaTxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Device To Screen
///SetPgEject(.F.)
If aReturn[5] == 1
     Set Printer TO
     dbcommitAll()
     ourspool(wnrel)
Endif
Return

//  ==> Function Somalin
Static Function Somalin()
lin := lin + 1
if lin > 58
   cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   lin := 8
endif
Return

// ==> Function Imprime
Static Function Imprime()
SomaLin()
@ lin,000 Psay TRB->B9_P_COD               // codigo
@ lin,026 Psay TRB->B9_LOCAL               // lc
@ lin,032 Psay TRB->B9_QINI              picture    "@E 99,999,999" // quantidade
@ lin,043 Psay TRB->B9_VINI1             picture "@E 99,999,999.99" // estoque
@ lin,057 Psay (TRB->B9_VINI1/TRB->B9_QINI)   picture     "@E 99,999.99" // c.m.reais
@ lin,067 Psay TRB->B9_VINI2             picture "@E 99,999,999.99" // estoque
@ lin,081 Psay (TRB->B9_VINI2/TRB->B9_QINI)   picture     "@E 99,999.99" // c.m
ac_QINI    := ac_QINI    + TRB->B9_QINI
ac_VINI1   := ac_VINI1   + TRB->B9_VINI1
ac_VINI2   := ac_VINI2   + TRB->B9_VINI2

Return

// ==> Function Final
Static Function Final()
SomaLin()
@ lin,000 Psay replicate("-",limite)
SomaLin()
@ lin,000 Psay "Totais"
@ lin,032 Psay ac_QINI    picture     "@E 99,999,999" // quantidade
@ lin,043 Psay ac_VINI1   picture  "@E 99,999,999.99" // estoque
@ lin,067 Psay ac_VINI2   picture  "@E 99,999,999.99" // estoque 
DBCLOSEAREA()
Return



STATIC FUNCTION _fSELECTREC()           

	_datafim := mv_par01
	_almoini := mv_par02
	_almofim := mv_par03
	_prodini := mv_par04
	_prodfim := mv_par05
	IF LEN(_PRODINI) < 1
		_prodini := " "
	ENDIF	
	univ := 0

	DbSelectArea("SB9")                  // CONTAS A RECEBER
	_xAliasSiga := "SB9"	
	//PROCREGUA(7)
	//INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(2)
	DbGoTop()
	///_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	cQUERY := "SELECT B9_P_COD,B9_LOCAL,B9_QINI,B9_VINI1,B9_VINI2 "
	cQUERY := cQUERY + "FROM SB9ED0 "
	cQUERY := cQUERY + "WHERE B9_DATA = " + _DataAte 
    cQUERY := cQUERY + " AND (B9_LOCAL >= '"+ _almoini + "' AND B9_LOCAL <= '" + _almofim + "') " 	
    cQUERY := cQUERY + " AND (B9_P_COD >= '"+ _prodini + "' AND B9_P_COD <= '" + _prodfim + "') " 
    cQUERY := cQUERY + " ORDER BY  B9_FILIAL+B9_P_COD+B9_LOCAL+B9_DATA "
	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
RETURN


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

///             X1_ORDEM	X1_PERGUNT        	  X1_PERSPA	                X1_PERENG            	VARIAVL	  TIP	TAM  DEC PRE GSC VL	X1_VAR01 X1_DEF01	 X1_DEFSPA1     X1_DEFENG1     X1_CNT01         X1_VAR02	   X1_DEF02	         X1_DEFSPA2	      X1_DEFENG2	      X1_CNT02       	X1_VAR03	         X1_DEF03	         X1_DEFSPA3	      X1_DEFENG3        X1_CNT03	 X1_VAR04	X1_DEF04  X1_DEFSPA4  X1_DEFENG4	  X1_CNT04	   X1_VAR05	    X1_DEF05	X1_DEFSPA5	X1_DEFENG5	X1_CNT05	  X1_F3	    X1_PYME	  X1_GRPSXG	 X1_HELP
AAdd( aRegs, { cPerg, "01","Data do Fechamento ?  ","Data do Fechamento ?","Data do Fechamento ?  ","mv_ch1","D",8,0,0,"G","","MV_PAR01","		     ","					","				 ","'30/03/04'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","       ","       ","        ","        "} )		
AAdd( aRegs, { cPerg, "02","Do  Almoxarifado   ?  ","Do  Almoxarifado   ?","Do  Almoxarifado   ?  ","mv_ch2","C",2,0,0,"G","","MV_PAR02","		     ","	            ","             ","01             ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","       ","       ","        ","        "} )		
AAdd( aRegs, { cPerg, "03","Até Almoxarifado   ?  ","Até Almoxarifado   ?","Até Almoxarifado   ?  ","mv_ch3","C",2,0,0,"G","","MV_PAR03","		     ","	            ","             ","99             ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","       ","       ","        ","        "} )		
AAdd( aRegs, { cPerg, "04","Do  Produto        ?  ","Do  Produto        ?","Do  Produto        ?  ","mv_ch4","C",25,0,0,"G","","MV_PAR04","		     ","	            ","             ","               ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1    ","       ","        ","        "} )		
AAdd( aRegs, { cPerg, "05","Até Produto        ?  ","Até Produto        ?","Até Produto        ?  ","mv_ch5","C",25,0,0,"G","","MV_PAR05","			  ","					","				 ","ZZZZZZZZZZZZZZZ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","SB1    ","       ","        ","        "} )		

For i:=1 to Len(aRegs)
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
