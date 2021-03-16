#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³	  º Autor ³  Matheus       º Data ³ 17/02/2011		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fonte para gerar relatório em excel, Posição dos produtos  º±±
±±ºDescricao ³ vendidos   												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Funcao      : PRYRVENO 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Fonte para gerar relatório em excel, Posição dos produtos vendidos 
Autor     	: Matheus Massarotto  	 	
Data     	: 17/02/2011
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Gestão Pessoal.
Cliente     : Todos.
*/

*-----------------------*
 User Function PRYRVENO
*-----------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Relatório de Vendas"
Local cPict          := ""                                                                                                                
Local titulo       := "RELATORIO DE VENDAS" //- DATA DE "+mv_par01+" ATE "+mv_par02+" / RESPONSAVEL "+mv_par03+" Ate "+mv_par04+""
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
Private nomeprog         := "PRYRVENO" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "PRYRVENO" // Coloque aqui o nome do arquivo usado para impressao em disco


if !cEmpAnt $ "ED"
	Alert("Relatório não disponível para esta empresa!")
	return
endif
//Definição das perguntas.

U_PUTSX1( "RVOKUMA_P", "01", "Produto De:", "Produto De:", "Produto De:", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR01")
U_PUTSX1( "RVOKUMA_P", "02", "Produto Ate:", "Produto Ate:", "Produto Ate:", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR02")
U_PUTSX1( "RVOKUMA_P", "03", "Filial De:", "Filial De:", "Filial De:", "", "C",2,00,00,"G","" , "","","","MV_PAR03")
U_PUTSX1( "RVOKUMA_P", "04", "Filial Ate:", "Filial Ate:", "Filial Ate:", "", "C",2,00,00,"G","" , "","","","MV_PAR04")
U_PUTSX1( "RVOKUMA_P", "05", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","U_ValRVEOku(MV_PAR05)" , "","","","MV_PAR05")
U_PUTSX1( "RVOKUMA_P", "06", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","U_ValRVEOku(MV_PAR06)" , "","","","MV_PAR06")
U_PUTSX1( "RVOKUMA_P", "07", "Grupo De:", "Grupo De:", "Grupo De:", "", "C",4,00,00,"G","" , "SBM","","","MV_PAR07")
U_PUTSX1( "RVOKUMA_P", "08", "Grupo Ate:", "Grupo Ate:", "Grupo Ate:", "", "C",4,00,00,"G","" , "SBM","","","MV_PAR08")
U_PUTSX1( "RVOKUMA_P", "09", "Gera Excel?:", "Gera Excel?", "Gera Excel?", "", "N",1,00,00,"C","" , "","","","MV_PAR09","Sim","","","","Não") 
U_PUTSX1( "RVOKUMA_P", "10", "Cons. Param. Abaixo?:", "Cons. Param. Abaixo?", "Cons. Param. Abaixo?", "", "N",1,00,00,"C","" , "","","","MV_PAR10","Sim","","","","Não") 
U_PUTSX1( "RVOKUMA_P", "11", "Cons. Tes Duplicata?:", "Cons. Tes Duplicata?", "Cons. Tes Duplicata?", "", "N",1,00,00,"C","" , "","","","MV_PAR11","Sim","","","","Não") 

Private cPerg := "RVOKUMA_P"
Private cString:="SD2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



If !Pergunte(cPerg,.T.)
	Return()
EndIf   

If MV_PAR09==2
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
Local nTotQtde:=0
Local nTotTotal:=0 
Local nTotICMS:=0
Local nTotST:=0
Local nTotIPI:=0
Local nTotVendas:=0
Local nTotPC:=0
Local nTotCusto:=0
Local nTotVLiq:=0
Local nTotMargem:=0
Local nTotMarPorc:=0

//RRP - 23/10/2013 - Ajuste no select para efetuar um calculo diferente para as notas complementares de ICMS. Chamado 014227.
//Junção dos dois Selects A e B 
cQry1 :=" SELECT A.D2_COD "+CRLF 
cQry1 +=" ,A.B1_DESC "+CRLF
cQry1 +=" ,A.QTDE AS QTDE "+CRLF 
cQry1 +=" ,A.TOTAL AS TOTAL "+CRLF 
cQry1 +=" ,A.ICMS AS ICMS "+CRLF
cQry1 +=" ,A.ST+ISNULL(B.ST,0) AS ST "+CRLF
cQry1 +=" ,A.IPI AS IPI "+CRLF
cQry1 +=" ,(A.TOTAL+ISNULL(B.TOTAL,0))+ A.IPI + A.ST  AS VALTOTAL_VENDAS "+CRLF 
cQry1 +=" ,A.D2_VALIMP5+A.D2_VALIMP6 AS PIS_COFINS "+CRLF 
cQry1 +=" ,A.D2_CUSTO1 AS D2_CUSTO1 "+CRLF 
cQry1 +=" ,(A.TOTAL+A.IPI+ISNULL(B.TOTAL,0)+ A.ST)- A.ICMS - (A.ST+ISNULL(B.ST,0)) - A.IPI - (A.D2_VALIMP5+A.D2_VALIMP6) AS VENDLIQ "+CRLF 
cQry1 +=" ,((A.TOTAL+A.IPI+ISNULL(B.TOTAL,0)+ A.ST)- A.ICMS - (A.ST+ISNULL(B.ST,0)) - A.IPI - (A.D2_VALIMP5+A.D2_VALIMP6))- A.D2_CUSTO1 AS MARGEN "+CRLF
cQry1 +=" ,(((A.TOTAL+A.IPI+ISNULL(B.TOTAL,0)+ A.ST)- A.ICMS - (A.ST+ISNULL(B.ST,0)) - A.IPI - (A.D2_VALIMP5+A.D2_VALIMP6))- A.D2_CUSTO1 )/ ((A.TOTAL+A.IPI+ISNULL(B.TOTAL,0)+ A.ST)- A.ICMS - (A.ST+ISNULL(B.ST,0)) - A.IPI - (A.D2_VALIMP5+A.D2_VALIMP6))*100 AS MARGEMPORC "+CRLF
cQry1 +=" ,A.B1_GRUPO "+CRLF 
 
cQry1 +=" FROM "+CRLF

cQry1 +="( "+CRLF
//Select que trás todas as notas que não são de complemento ICMS D2_TIPO = I
cQry1 +=" SELECT D2_COD "+CRLF
cQry1 +=" ,B1_DESC "+CRLF 
cQry1 +=" ,SUM(D2_QUANT) AS QTDE "+CRLF 
cQry1 +=" ,SUM(D2_TOTAL) AS TOTAL "+CRLF 
cQry1 +=" ,SUM(D2_VALICM) AS ICMS "+CRLF 
cQry1 +=" ,SUM(D2_ICMSRET) AS ST "+CRLF 
cQry1 +=" ,SUM(D2_VALIPI) AS IPI "+CRLF
cQry1 +=" ,SUM(D2_CUSTO1)AS D2_CUSTO1 "+CRLF 
cQry1 +=" ,SUM(D2_VALIMP5) AS D2_VALIMP5 "+CRLF
cQry1 +=" ,SUM(D2_VALIMP6) AS D2_VALIMP6 "+CRLF
cQry1 +=" ,B1_GRUPO "+CRLF
cQry1 +=" FROM "+RETSQLNAME("SD2")+" D2 "+CRLF
cQry1 +=" JOIN "+RETSQLNAME("SB1")+" B1 ON B1_COD=D2_COD AND B1_FILIAL=D2_FILIAL "+CRLF 
cQry1 +=" JOIN "+RETSQLNAME("SF4")+" F4 ON F4_CODIGO=D2_TES "+CRLF 
cQry1 +=" WHERE D2.D_E_L_E_T_='' AND B1.D_E_L_E_T_=''  AND F4.D_E_L_E_T_='' "+CRLF 
cQry1 +=" AND (D2_COD BETWEEN '"+ALLTRIM(MV_PAR01)+"' AND '"+ALLTRIM(MV_PAR02)+"') AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"') AND (D2_FILIAL BETWEEN '"+ALLTRIM(MV_PAR03)+"' AND '"+ALLTRIM(MV_PAR04)+"') AND (B1_GRUPO BETWEEN '"+ALLTRIM(MV_PAR07)+"' AND '"+ALLTRIM(MV_PAR08)+"') "+CRLF
cQry1 +=" AND B1_P_TIP<>'2'  AND D2.D2_LOCAL <> '99' "+CRLF

if MV_PAR10==1

	if MV_PAR11==1	
		cQry1 +=" AND F4.F4_DUPLIC='S'"+CRLF
    else
		cQry1 +=" AND F4.F4_DUPLIC='N'"+CRLF
	endif
endif

cQry1 +=" AND B1.B1_FILIAL='"+xFilial("SB1")+"' AND D2.D2_FILIAL='"+xFilial("SD2")+"' "+CRLF
cQry1 +=" AND D2_TIPO <>'I' "+CRLF
cQry1 +=" GROUP BY D2_COD,B1_DESC,B1_GRUPO "+CRLF

cQry1 +=" ) AS A "+CRLF
 
cQry1 +=" LEFT JOIN ( "+CRLF
cQry1 +=" SELECT D2_COD "+CRLF
cQry1 +=" ,B1_DESC "+CRLF 
cQry1 +=" ,SUM(D2_QUANT) AS QTDE "+CRLF 
cQry1 +=" ,SUM(D2_TOTAL) AS TOTAL "+CRLF 
cQry1 +=" ,SUM(D2_VALICM) AS ICMS "+CRLF 
cQry1 +=" ,SUM(D2_ICMSRET) AS ST "+CRLF 
cQry1 +=" ,SUM(D2_VALIPI) AS IPI "+CRLF
cQry1 +=" ,SUM(D2_CUSTO1)AS D2_CUSTO1 "+CRLF 
cQry1 +=" ,SUM(D2_VALIMP5) AS D2_VALIMP5 "+CRLF
cQry1 +=" ,SUM(D2_VALIMP6) AS D2_VALIMP6 "+CRLF
cQry1 +=" ,B1_GRUPO "+CRLF
cQry1 +=" FROM "+RETSQLNAME("SD2")+" D2 "+CRLF
cQry1 +=" JOIN "+RETSQLNAME("SB1")+" B1 ON B1_COD=D2_COD AND B1_FILIAL=D2_FILIAL "+CRLF 
cQry1 +=" JOIN "+RETSQLNAME("SF4")+" F4 ON F4_CODIGO=D2_TES "+CRLF 
cQry1 +=" WHERE D2.D_E_L_E_T_='' AND B1.D_E_L_E_T_=''  AND F4.D_E_L_E_T_='' "+CRLF 
cQry1 +=" AND (D2_COD BETWEEN '"+ALLTRIM(MV_PAR01)+"' AND '"+ALLTRIM(MV_PAR02)+"') AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"') AND (D2_FILIAL BETWEEN '"+ALLTRIM(MV_PAR03)+"' AND '"+ALLTRIM(MV_PAR04)+"') AND (B1_GRUPO BETWEEN '"+ALLTRIM(MV_PAR07)+"' AND '"+ALLTRIM(MV_PAR08)+"') "+CRLF
cQry1 +=" AND B1_P_TIP<>'2'  AND D2.D2_LOCAL <> '99' "+CRLF

if MV_PAR10==1

	if MV_PAR11==1	
		cQry1 +=" AND F4.F4_DUPLIC='S'"+CRLF
    else
		cQry1 +=" AND F4.F4_DUPLIC='N'"+CRLF
	endif
endif

cQry1 +=" AND B1.B1_FILIAL='"+xFilial("SB1")+"' AND D2.D2_FILIAL='"+xFilial("SD2")+"' "+CRLF
cQry1 +=" AND D2_TIPO ='I' "+CRLF
cQry1 +=" GROUP BY D2_COD,B1_DESC,B1_GRUPO "+CRLF
cQry1 +=" ) AS B ON A.D2_COD=B.D2_COD "+CRLF
 
cQry1 +=" ORDER BY D2_COD "

If tcsqlexec(cQry1)<0
	Alert("Ocorreu um problema na busca das informações!!")
	return
EndIf

//memowrite("C:\Grant Thorntom\Querys\cQry2.sql",cQry1)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TSD2",.T.,.T.)                                                         

				//#################### REGUA CABEÇALHO ###################\\ 
				
		//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230
		//	 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890					
		//   XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX       XXXXXXXXXX     XXXXXXXXXX  XXXXXXXXXX     XXXXXXXXXX  XXXXXXXXXX  XXXX
                                        
Cabec1 := 	"PRODUTO          DESCRICAO                                           QUANTIDADE     TOTAL       VLR.ICMS    VLR.IPI     VL.TOTAL VENDAS  VL.PIS/COFINS  CUSTO       VENDA LIQUIDA  MARGEM      MARGEM %    GRUPO

                                                                                                     
Private aDadTemp:={}
Private nDad:=0

//Criação dos campos da tabela temporária

AADD(aDadTemp,{"Produto","C",15,0})
AADD(aDadTemp,{"Descricao","C",30,0})
AADD(aDadTemp,{"Quantidade","N",11,2})
AADD(aDadTemp,{"Vl_Total","N",14,2})
AADD(aDadTemp,{"Vl_ICMS","N",14,2})
AADD(aDadTemp,{"Vl_ST","N",14,2})
AADD(aDadTemp,{"Vl_IPI","N",14,2})
AADD(aDadTemp,{"Vl_Tot_Ven","N",14,2})
AADD(aDadTemp,{"PIS_COFINS","N",14,2})
AADD(aDadTemp,{"Custo","N",14,2})
AADD(aDadTemp,{"Venda_Liq","N",14,2})
AADD(aDadTemp,{"Margem","C",14,0})
AADD(aDadTemp,{"Margem_Por","C",14,0})
AADD(aDadTemp,{"Grupo","C",4,0})

//Criando nome temporario
cNome := CriaTrab(Nil,.F.)//CriaTrab(aDadTemp,.t.)
dbCreate(cNome,aDadTemp,"DBFCDXADS")
dbUseArea(.T.,"DBFCDXADS",cNome,"DADXLS1",.F.,.F.)
 
cIndex:=CriaTrab(Nil,.F.)
IndRegua("DADXLS1",cIndex,"Produto",,,"Selecionando Registro...")

DbSelectArea("DADXLS1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

DbSelectArea("TSD2")
TSD2->(DBGotop())
//SetRegua(TSD2->(RecCount()))
SetRegua(RecCount())

While TSD2->(!EOF())

If MV_PAR09==2
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
EndIf
  
//Impressão em arquivo do siga
If MV_PAR09==2

   @nLin,01  PSAY ALLTRIM(TSD2->D2_COD)
   @nLin,17  PSAY ALLTRIM(TSD2->B1_DESC)
   @nLin,70  PSAY ALLTRIM(STR(TSD2->QTDE))   
   @nLin,85  PSAY ALLTRIM(STR(ROUND(TSD2->TOTAL,2)))
   @nLin,97  PSAY ALLTRIM(STR(ROUND(TSD2->ICMS,2)))
   @nLin,109  PSAY ALLTRIM(STR(ROUND(TSD2->IPI,2)))
   @nLin,121 PSAY ALLTRIM(STR(ROUND(TSD2->VALTOTAL_VENDAS,2)))            
   @nLin,138 PSAY ALLTRIM(STR(ROUND(TSD2->PIS_COFINS,2)))
   @nLin,153 PSAY ALLTRIM(STR(ROUND(TSD2->D2_CUSTO1,2)))
   @nLin,165 PSAY ALLTRIM(STR(ROUND(TSD2->VENDLIQ,2)))   
   @nLin,180 PSAY ALLTRIM( IIF(ROUND(TSD2->MARGEN,2)<0,"("+ALLTRIM(STR(ABS(ROUND(TSD2->MARGEN,2))))+")",STR(ROUND(TSD2->MARGEN,2)) ) )
   @nLin,192 PSAY ALLTRIM(STR(ROUND(TSD2->MARGEMPORC,2)))+"%"
   @nLin,204 PSAY ALLTRIM(TSD2->B1_GRUPO)        
             
EndIf 

//Totalizadores
nTotQtde+=TSD2->QTDE
nTotTotal+=TSD2->TOTAL
nTotICMS+=TSD2->ICMS
nTotST+=TSD2->ST
nTotIPI+=TSD2->IPI
nTotVendas+=TSD2->VALTOTAL_VENDAS
nTotPC+=TSD2->PIS_COFINS
nTotCusto+=TSD2->D2_CUSTO1
nTotVLiq+=TSD2->VENDLIQ
nTotMargem+=TSD2->MARGEN


//carrega tabela temporária para, abrir arquivo no excel.
Reclock("DADXLS1",.T.)

DADXLS1->Produto:=ALLTRIM(TSD2->D2_COD)
DADXLS1->Descricao:=ALLTRIM(TSD2->B1_DESC)
DADXLS1->Quantidade:=TSD2->QTDE
DADXLS1->Vl_Total:=ROUND(TSD2->TOTAL,2)
DADXLS1->Vl_ICMS:=ROUND(TSD2->ICMS,2)
DADXLS1->Vl_ST:=ROUND(TSD2->ST,2)
DADXLS1->Vl_IPI:=ROUND(TSD2->IPI,2)
DADXLS1->Vl_Tot_Ven:=ROUND(TSD2->VALTOTAL_VENDAS,2)
DADXLS1->PIS_COFINS:=ROUND(TSD2->PIS_COFINS,2)
DADXLS1->Custo:=ROUND(TSD2->D2_CUSTO1,2)
DADXLS1->Venda_Liq:=ROUND(TSD2->VENDLIQ,2)
DADXLS1->Margem:=STRTRAN(ALLTRIM( IIF(ROUND(TSD2->MARGEN,2)<0,"("+ALLTRIM(STR(ABS(ROUND(TSD2->MARGEN,2))))+")",STR(ROUND(TSD2->MARGEN,2)) ) ),".",",")
DADXLS1->Margem_Por:=STRTRAN(ALLTRIM(STR(ROUND(TSD2->MARGEMPORC,2)))+"%",".",",")
DADXLS1->Grupo:=ALLTRIM(TSD2->B1_GRUPO)
  
   nLin := nLin + 1 // Avanca a linha de impressao     

  
DADXLS1->(MsUnlock())
   TSD2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

//TOTAIS

//Impressão em arquivo do siga
If MV_PAR09==2


   @nLin,70  PSAY ALLTRIM(STR(nTotQtde))   
   @nLin,85  PSAY ALLTRIM(STR(ROUND(nTotTotal,2)))
   @nLin,97  PSAY ALLTRIM(STR(ROUND(nTotICMS,2)))
   @nLin,109  PSAY ALLTRIM(STR(ROUND(nTotIPI,2)))
   @nLin,121 PSAY ALLTRIM(STR(ROUND(nTotVendas,2)))            
   @nLin,138 PSAY ALLTRIM(STR(ROUND(nTotPC,2)))
   @nLin,153 PSAY ALLTRIM(STR(ROUND(nTotCusto,2)))
   @nLin,165 PSAY ALLTRIM(STR(ROUND(nTotVLiq,2)))   
   @nLin,180 PSAY ALLTRIM( IIF(ROUND(nTotMargem,2)<0,"("+ALLTRIM(STR(ABS(ROUND(nTotMargem,2))))+")",STR(ROUND(nTotMargem,2)) ) )
   @nLin,192 PSAY ALLTRIM(STR(ROUND((nTotMargem/nTotVLiq)*100,2)))+"%"

             
EndIf 

//carrega tabela temporária para, abrir arquivo no excel.
Reclock("DADXLS1",.T.)

DADXLS1->Quantidade:=nTotQtde
DADXLS1->Vl_Total:=ROUND(nTotTotal,2)
DADXLS1->Vl_ICMS:=ROUND(nTotICMS,2)
DADXLS1->Vl_ST:=ROUND(nTotST,2)
DADXLS1->Vl_IPI:=ROUND(nTotIPI,2)
DADXLS1->Vl_Tot_Ven:=ROUND(nTotVendas,2)
DADXLS1->PIS_COFINS:=ROUND(nTotPC,2)
DADXLS1->Custo:=ROUND(nTotCusto,2)
DADXLS1->Venda_Liq:=ROUND(nTotVLiq,2)
DADXLS1->Margem:=STRTRAN(ALLTRIM( IIF(ROUND(nTotMargem,2)<0,"("+ALLTRIM(STR(ABS(ROUND(nTotMargem,2))))+")",STR(ROUND(nTotMargem,2)) ) ),".",",")
DADXLS1->Margem_Por:=STRTRAN(ALLTRIM(STR(ROUND((nTotMargem/nTotVLiq)*100,2)))+"%",".",",")

DADXLS1->(MsUnlock())


DADXLS1->(DbCloseArea())

If MV_PAR09==2
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
EndIf

TSD2->(DBCloseArea())

//Se for para imprimir no excel
If MV_PAR09==1
	If !ApOleClient("MsExcel")
	     MsgStop("Microsoft Excel nao instalado.")
	     Return
	EndIf 
		
		cArqOrig := "\"+CURDIR()+cNome+".DBF"
	   	cPath     := AllTrim(GetTempPath())                                                   
	   	
		IF CpyS2T( cArqOrig , cPath, .T. )
			oExcelApp:=MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
			oExcelApp:SetVisible(.T.)   
		ELSE
			MSGALERT("ERRO AO TENTAR REALIZAR A CÓPIA DA TABELA TEMPORARIA (FERROR):"+STR(FERROR(),4),"ERRO FERROR -> CPYS2T")
		ENDIF
	
	sleep(05)	
EndIf 

//Apaga tabela temporária
Erase &cNome+".DBF"            

Return

/*
 ----------------------------------------------------
|	Função para validar se a data da                 |
|   Pergunta está vazia. Obs: Ñ permite Data Vazia.  |
 ----------------------------------------------------
*/

User function ValRVEOku(cData)
local lRet:=.T.

If Empty(cData)
	msginfo("Campo Data Vazio!!")
	lRet:=.F. 
EndIf

Return(lRet)
