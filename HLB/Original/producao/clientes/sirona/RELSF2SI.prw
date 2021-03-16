#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥RELSF2SI     ∫ Autor ≥  Matheus       ∫ Data ≥ 08/08/2011   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ FunÁ„o para gerar relatÛrio do SF2
±±∫com os parametros: 
±±∫doc de ate
±±∫cliente de ate
±±∫data de ate
±±∫cfpo: separados por /
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/   
                                                                       
/*
Funcao      : RELSF2SI
Parametros  : 
Retorno     : 
Objetivos   : FunÁ„o para gerar relatÛrio do SF2 com os parametros:  doc de ate /cliente de ate / data de ate separados por /
Autor       : Matheus Massarotto
Data/Hora   : 08/08/2011
TDN         : 
Revis„o     : Tiago Luiz MendonÁa 
Data/Hora   : 06/02/2012
MÛdulo      : Faturamento.
*/ 

*--------------------------*
  User Function RELSF2SI()
*--------------------------*

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Declaracao de Variaveis                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Nota Fiscal de Sa˙Åa"
Local cPict          := ""                                                                                                                
Local titulo       := "Relatorio de Nota Fiscal de Sa˙Åa" 
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
Private nomeprog         := "RELSF2SI" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RELSF2SI" // Coloque aqui o nome do arquivo usado para impressao em disco
Private lExibPro:=.F.

if !cEmpAnt $ "SI" //Sirona
	Alert("RelatÛrio n„o dispon˙ìel para a empresa!")
	return()
endif  
//Tratamento para exibir o cÛdigo do produto no relatÛrio
//JVR - 24/08/2012 - Considera sempre a exibiÁ„o do codigo do produto.
//if cEmpAnt $ "IS"
	lExibPro:=.T.
//endif

//DefiniÁ„o das perguntas.

U_PUTSX1( "RELSF2SITM", "01", "Documento De:", "Documento De:", "Documento De:", "", "C",9,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( "RELSF2SITM", "02", "Documento Ate:", "Documento Ate:", "Documento Ate:", "", "C",9,00,00,"G","" , "","","","MV_PAR02")
U_PUTSX1( "RELSF2SITM", "03", "Cliente De:", "Cliente De:", "Cliente De:", "", "C",6,00,00,"G","" , "SA1","","","MV_PAR03")
U_PUTSX1( "RELSF2SITM", "04", "Cliente Ate:", "Cliente Ate:", "Cliente Ate:", "", "C",6,00,00,"G","" , "SA1","","","MV_PAR04")
U_PUTSX1( "RELSF2SITM", "05", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","U_ValSF2SI(MV_PAR05)" , "","","","MV_PAR05")
U_PUTSX1( "RELSF2SITM", "06", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","U_ValSF2SI(MV_PAR06)" , "","","","MV_PAR06")
U_PUTSX1( "RELSF2SITM", "07", "CFOP:", "CFOP:", "CFOP:", "", "C",50,00,00,"G","U_ValSF2CF(MV_PAR07)" , "","","","MV_PAR07",,,,,,,,,,,,,,,,,{"Coloque o CFOP separado por /","exemplo: 5102/6102/6108"})
U_PUTSX1( "RELSF2SITM", "08", "Por Centro Custo?", "Por Centro Custo?", "Por Centro Custo?", "", "N",1,00,00,"C","" , "","","","MV_PAR08","Sim","","","","N„o") 
U_PUTSX1( "RELSF2SITM", "09", "Gera Excel?", "Gera Excel?", "Gera Excel?", "", "N",1,00,00,"C","" , "","","","MV_PAR09","Sim","","","","N„o")

Private cString := "SF2" 
Private cPerg := "RELSF2SITM"

dbSelectArea(cString)
dbSetOrder(1)  


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a interface padrao com o usuario...                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

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

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Processamento. RPTSTATUS monta janela com a regua de processamento. ≥       
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

RptStatus({|| ≥RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Else
RptStatus({|| ≥RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥RUNREPORT ∫ Autor ≥ AP6 IDE            ∫ Data ≥  04/01/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ∫±±
±±∫          ≥ monta a janela com a regua de processamento.               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ≥RUNREPORT(Cabec1,Cabec2,Titulo,nLin)
                                                         
Local cQry1:=""
Local cCFOPS:=MV_PAR07
Local cQrCFOP:=""
Local lCt:=.F. 

Local nVlBrut:=0
Local nVlICM:=0
Local nVlIPI:=0
Local nVlISS:=0
Local nVlCOFINS:=0
Local nVlPIS:=0
Local nVlLiq:=0 
Local nTotIcms:=0

Local nCCVlBrut:=0
Local nCCVlICM:=0
Local nCCVlIPI:=0
Local nCCVlISS:=0
Local nCCVlCOFINS:=0
Local nCCVlPIS:=0
Local nCCVlLiq:=0
Local nCCImcs:=0

Local aPorCCusto:={}
Local nII:=0
Local lRecLo:=.F.
Local nAliquota:=0
Local nValICMS:=0


if !empty(cCFOPS)
	while !lCt
		nAt:=AT("/",cCFOPS)
	
		if nAt==0
			cQrCFOP+="'"+alltrim(cCFOPS)+"'"
			lCt:=.T.
			exit
		else
			cQrCFOP+="'"+alltrim(substr(cCFOPS,1,nAt-1))+"',"
		    
		    cCFOPS:=substr(cCFOPS,nAt+1,len(cCFOPS)-nAt+1)
		endif
	enddo
else
	cQrCFOP:="'ZZZZ'"
endif

/*
cQry1 :=" SELECT F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,A1_NOME,F2_VALBRUT,F2_VALICM,F2_VALIPI,F2_VALISS,F2_VALIMP5,F2_VALIMP6,F2_VALIRRF, F2_VALBRUT-(F2_VALICM+F2_VALIPI+F2_VALISS+F2_VALIMP5+F2_VALIMP6+F2_VALIRRF) AS F2_VALLIQ
cQry1 +=" FROM "+RETSQLNAME("SF2")+" SF2 
cQry1 +=" JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
cQry1 +=" WHERE  SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = ''
cQry1 +=" AND F2_DOC BETWEEN UPPER('"+MV_PAR01+"') AND UPPER('"+MV_PAR02+"')
cQry1 +=" AND F2_CLIENTE BETWEEN UPPER('"+MV_PAR03+"') AND UPPER('"+MV_PAR04+"')
cQry1 +=" AND F2_EMISSAO BETWEEN UPPER('"+DTOS(MV_PAR05)+"') AND UPPER('"+DTOS(MV_PAR06)+"') 
cQry1 +=" ORDER BY F2_EMISSAO 
*/

/*
cQry1 :=" SELECT F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,A1_NOME,D2_CF,F2_VALBRUT,F2_VALICM,F2_VALIPI,F2_VALISS,F2_VALIMP5,F2_VALIMP6,F2_VALIRRF, F2_VALBRUT-(F2_VALICM+F2_VALIPI+F2_VALISS+F2_VALIMP5+F2_VALIMP6+F2_VALIRRF) AS 'F2_VALLIQ'
cQry1 +=" FROM "+RETSQLNAME("SF2")+" SF2 
cQry1 +=" JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
cQry1 +=" JOIN "+RETSQLNAME("SD2")+" SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE
cQry1 +=" WHERE  SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_=''
cQry1 +=" AND F2_DOC BETWEEN UPPER('"+MV_PAR01+"') AND UPPER('"+MV_PAR02+"')
cQry1 +=" AND F2_CLIENTE BETWEEN UPPER('"+MV_PAR03+"') AND UPPER('"+MV_PAR04+"')
cQry1 +=" AND F2_EMISSAO BETWEEN UPPER('"+DTOS(MV_PAR05)+"') AND UPPER('"+DTOS(MV_PAR06)+"') 
cQry1 +=" AND D2_CF IN ("+cQrCFOP+")
cQry1 +=" GROUP BY F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,A1_NOME,D2_CF,F2_VALBRUT,F2_VALICM,F2_VALIPI,F2_VALISS,F2_VALIMP5,F2_VALIMP6,F2_VALIRRF,F2_VALBRUT-(F2_VALICM+F2_VALIPI+F2_VALISS+F2_VALIMP5+F2_VALIMP6+F2_VALIRRF) 
cQry1 +=" ORDER BY F2_DOC,F2_SERIE,D2_CF

*/

if MV_PAR08==2

	cQry1 :=" SELECT F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,B1_COD,B1_DESC,D2_QUANT,D2_CF,D2_VALBRUT,D2_VALICM,D2_VALIPI,D2_VALISS,D2_VALIMP5,D2_VALIMP6, D2_VALBRUT-(D2_VALICM+D2_VALIPI+D2_VALISS+D2_VALIMP5+D2_VALIMP6) AS 'D2_VALLIQ', A1_EST,F4_CRDPRES, SD2.R_E_C_N_O_ 	
	cQry1 +=" FROM "+RETSQLNAME("SF2")+" SF2 
	cQry1 +=" JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
	cQry1 +=" JOIN "+RETSQLNAME("SD2")+" SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE
	cQry1 +=" JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_COD = D2_COD
	cQry1 +=" JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_CODIGO = D2_TES
	cQry1 +=" WHERE  SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_='' AND SB1.D_E_L_E_T_='' AND SF4.D_E_L_E_T_=''
	cQry1 +=" AND F2_DOC BETWEEN UPPER('"+MV_PAR01+"') AND UPPER('"+MV_PAR02+"')
	cQry1 +=" AND F2_CLIENTE BETWEEN UPPER('"+MV_PAR03+"') AND UPPER('"+MV_PAR04+"')
	cQry1 +=" AND F2_EMISSAO BETWEEN UPPER('"+DTOS(MV_PAR05)+"') AND UPPER('"+DTOS(MV_PAR06)+"') 
	cQry1 +=" AND D2_CF IN ("+cQrCFOP+")
	cQry1 +=" GROUP BY F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,B1_COD,B1_DESC,D2_QUANT,D2_CF,D2_VALBRUT,D2_VALICM,D2_VALIPI,D2_VALISS,D2_VALIMP5,D2_VALIMP6, D2_VALBRUT-(D2_VALICM+D2_VALIPI+D2_VALISS+D2_VALIMP5+D2_VALIMP6), A1_EST,F4_CRDPRES, SD2.R_E_C_N_O_
	cQry1 +=" ORDER BY F2_DOC,F2_SERIE,D2_CF

else

	cQry1 :=" SELECT D2_CCUSTO,F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,B1_COD,B1_DESC,D2_QUANT,D2_CF,D2_VALBRUT,D2_VALICM,D2_VALIPI,D2_VALISS,D2_VALIMP5,D2_VALIMP6, D2_VALBRUT-(D2_VALICM+D2_VALIPI+D2_VALISS+D2_VALIMP5+D2_VALIMP6) AS 'D2_VALLIQ',A1_EST ,F4_CRDPRES, SD2.R_E_C_N_O_
	cQry1 +=" FROM "+RETSQLNAME("SF2")+" SF2 
	cQry1 +=" JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA
	cQry1 +=" JOIN "+RETSQLNAME("SD2")+" SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE
	cQry1 +=" JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_COD = D2_COD
	cQry1 +=" JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_CODIGO = D2_TES
	cQry1 +=" WHERE  SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_='' AND SB1.D_E_L_E_T_='' AND SF4.D_E_L_E_T_=''
	cQry1 +=" AND F2_DOC BETWEEN UPPER('"+MV_PAR01+"') AND UPPER('"+MV_PAR02+"')
	cQry1 +=" AND F2_CLIENTE BETWEEN UPPER('"+MV_PAR03+"') AND UPPER('"+MV_PAR04+"')
	cQry1 +=" AND F2_EMISSAO BETWEEN UPPER('"+DTOS(MV_PAR05)+"') AND UPPER('"+DTOS(MV_PAR06)+"') 
	cQry1 +=" AND D2_CF IN ("+cQrCFOP+")
	cQry1 +=" GROUP BY D2_CCUSTO,F2_SERIE,F2_DOC,F2_EMISSAO,F2_CLIENTE,B1_COD,B1_DESC,D2_QUANT,D2_CF,D2_VALBRUT,D2_VALICM,D2_VALIPI,D2_VALISS,D2_VALIMP5,D2_VALIMP6, D2_VALBRUT-(D2_VALICM+D2_VALIPI+D2_VALISS+D2_VALIMP5+D2_VALIMP6),A1_EST,F4_CRDPRES, SD2.R_E_C_N_O_
	cQry1 +=" ORDER BY D2_CCUSTO,F2_DOC,F2_SERIE,D2_CF
	
endif

if select("TRBSF2")>0
	TRBSF2->(DbCloseArea())
endif 

//memowrite("C:\HLB BRASIL\Querys\RELSF2SI.txt",cQry1)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBSF2",.T.,.T.)                                                         

if MV_PAR08==2		                                        
				//#################### REGUA CABE«ALHO ###################\\ 
				
			//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210
			//	 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345					
			//   XXX    XXXXXXXXX  XXXXXXXXXX  XXXXXX   XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXX   XXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX
	if !lExibPro
	Cabec1 := 	"SERIE  DOCUMENTO  EMISSAO     CLIENTE  PRODUTO                         QTDE    CFPO   VLR.BRUTO       VLR.ICMS        VLR.IPI         VLR.ISS         VLR.COFINS      VLR.PIS         VLR.LIQUIDO     VLR.ICMS PRES"
	else
	Cabec1 := 	"SERIE  DOCUMENTO  EMISSAO     CLIENTE  COD PROD         PRODUTO                         QTDE    CFPO   VLR.BRUTO       VLR.ICMS        VLR.IPI         VLR.ISS         VLR.COFINS      VLR.PIS         VLR.LIQUIDO     VLR.ICMS PRES"
	endif


else

				//#################### REGUA CABE«ALHO ###################\\ 
				
			//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210
			//	 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345					
			//   XXXXXXXXX      XXX    XXXXXXXXX  XXXXXXXXXX  XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXX   XXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX  XXXXXXXXXXXXXX
	if !lExibPro
	Cabec1 := 	"CENTRO CUSTO   SERIE  DOCUMENTO  EMISSAO     CLIENTE  PRODUTO                         QTDE    CFPO   VLR.BRUTO       VLR.ICMS        VLR.IPI         VLR.ISS         VLR.COFINS      VLR.PIS         VLR.LIQUIDO     VLR.ICMS PRES"
	else
	Cabec1 := 	"CENTRO CUSTO   SERIE  DOCUMENTO  EMISSAO     CLIENTE  COD PROD         PRODUTO                         QTDE    CFPO   VLR.BRUTO       VLR.ICMS        VLR.IPI         VLR.ISS         VLR.COFINS      VLR.PIS         VLR.LIQUIDO     VLR.ICMS PRES"
	endif
	

endif

Private aDadTemp:={}
Private nTotal:=0

if MV_PAR08==2
	if !lExibPro
		AADD(aDadTemp,{"SERIE","C",3,0})
		AADD(aDadTemp,{"DOCUMENTO","C",9,0})
		AADD(aDadTemp,{"EMISSAO","D",8,0})
		AADD(aDadTemp,{"CLIENTE","C",6,0})
		AADD(aDadTemp,{"PRODUTO","C",30,0})
		AADD(aDadTemp,{"QTDE","N",14,2})
		AADD(aDadTemp,{"CFOP","C",5,0})
		AADD(aDadTemp,{"VLR_BRUTO","N",14,2})
		AADD(aDadTemp,{"VLR_ICMS","N",14,2})
		AADD(aDadTemp,{"VLR_IPI","N",14,2})
		AADD(aDadTemp,{"VLR_ISS","N",14,2})
		AADD(aDadTemp,{"VLR_COFINS","N",14,2})
		AADD(aDadTemp,{"VLR_PIS","N",14,2})
		AADD(aDadTemp,{"VLR_LIQUID","N",14,2})
		AADD(aDadTemp,{"VLR_ICMSPR","N",14,2})
	else 
		AADD(aDadTemp,{"SERIE","C",3,0})
		AADD(aDadTemp,{"DOCUMENTO","C",9,0})
		AADD(aDadTemp,{"EMISSAO","D",8,0})
		AADD(aDadTemp,{"CLIENTE","C",6,0})
		AADD(aDadTemp,{"CODPROD","C",15,0})		
		AADD(aDadTemp,{"PRODUTO","C",30,0})
		AADD(aDadTemp,{"QTDE","N",14,2})
		AADD(aDadTemp,{"CFOP","C",5,0})
		AADD(aDadTemp,{"VLR_BRUTO","N",14,2})
		AADD(aDadTemp,{"VLR_ICMS","N",14,2})
		AADD(aDadTemp,{"VLR_IPI","N",14,2})
		AADD(aDadTemp,{"VLR_ISS","N",14,2})
		AADD(aDadTemp,{"VLR_COFINS","N",14,2})
		AADD(aDadTemp,{"VLR_PIS","N",14,2})
		AADD(aDadTemp,{"VLR_LIQUID","N",14,2})
		AADD(aDadTemp,{"VLR_ICMSPR","N",14,2})	
	endif
else
	if !lExibPro
		AADD(aDadTemp,{"CEN_CUSTO","C",9,0})
		AADD(aDadTemp,{"SERIE","C",3,0})
		AADD(aDadTemp,{"DOCUMENTO","C",9,0})
		AADD(aDadTemp,{"EMISSAO","D",8,0})
		AADD(aDadTemp,{"CLIENTE","C",6,0})
		AADD(aDadTemp,{"PRODUTO","C",30,0})
		AADD(aDadTemp,{"QTDE","N",14,2})
		AADD(aDadTemp,{"CFOP","C",5,0})
		AADD(aDadTemp,{"VLR_BRUTO","N",14,2})
		AADD(aDadTemp,{"VLR_ICMS","N",14,2})
		AADD(aDadTemp,{"VLR_IPI","N",14,2})
		AADD(aDadTemp,{"VLR_ISS","N",14,2})
		AADD(aDadTemp,{"VLR_COFINS","N",14,2})
		AADD(aDadTemp,{"VLR_PIS","N",14,2})
		AADD(aDadTemp,{"VLR_LIQUID","N",14,2})
		AADD(aDadTemp,{"VLR_ICMSPR","N",14,2})
	else 
		AADD(aDadTemp,{"CEN_CUSTO","C",9,0})
		AADD(aDadTemp,{"SERIE","C",3,0})
		AADD(aDadTemp,{"DOCUMENTO","C",9,0})
		AADD(aDadTemp,{"EMISSAO","D",8,0})
		AADD(aDadTemp,{"CLIENTE","C",6,0})
		AADD(aDadTemp,{"CODPROD","C",15,0})		
		AADD(aDadTemp,{"PRODUTO","C",30,0})
		AADD(aDadTemp,{"QTDE","N",14,2})
		AADD(aDadTemp,{"CFOP","C",5,0})
		AADD(aDadTemp,{"VLR_BRUTO","N",14,2})
		AADD(aDadTemp,{"VLR_ICMS","N",14,2})
		AADD(aDadTemp,{"VLR_IPI","N",14,2})
		AADD(aDadTemp,{"VLR_ISS","N",14,2})
		AADD(aDadTemp,{"VLR_COFINS","N",14,2})
		AADD(aDadTemp,{"VLR_PIS","N",14,2})
		AADD(aDadTemp,{"VLR_LIQUID","N",14,2})
		AADD(aDadTemp,{"VLR_ICMSPR","N",14,2})
	
	endif
endif	

cNome := CriaTrab(aDadTemp,.t.)
dbUseArea(.T.,,cNome,"DADXLS",.F.,.F.)
 
cIndex:=CriaTrab(Nil,.F.)                                               

if MV_PAR08==2
	IndRegua("DADXLS",cIndex,"SERIE+DOCUMENTO",,,"Selecionando Registro...")
else
	IndRegua("DADXLS",cIndex,"CEN_CUSTO+SERIE+DOCUMENTO",,,"Selecionando Registro...")
endif
DbSelectArea("DADXLS")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


TRBSF2->(DBGotop())
SetRegua(TRBSF2->(RecCount()))

While TRBSF2->(!EOF())    

if !empty(TRBSF2->F4_CRDPRES)
	//aliquota do icms				
	/*
	if alltrim(GETMV("MV_ESTADO"))==alltrim(TRBSF2->A1_EST)
		nAliquota:=VAL(SUBSTR(GETMV("MV_ESTICM"),AT(ALLTRIM(GETMV("MV_ESTADO")),ALLTRIM(GETMV("MV_ESTICM")))+2,2))	
	else //Tratamento para aliquota interestadual, com verificaÁ„o dos estados do norte					
		If ( alltrim(GETMV("MV_ESTADO")) $ ALLTRIM(GETMV("MV_NORTE")) )
			nAliquota := 12 //MV_ICMTRF
		Else
			nAliquota := IIf( alltrim(TRBSF2->A1_EST) $ ALLTRIM(GETMV("MV_NORTE")) , 7 , 12 ) 
		EndIf						
	endif
	
	nValICMS:= (TRBSF2->D2_VALBRUT*(nAliquota/100))-((TRBSF2->D2_VALBRUT*(nAliquota/100))*(TRBSF2->F4_CRDPRES/100) )
	*/
	//nValICMS:=TRBSF2->D2_VALICM-(TRBSF2->D2_VALICM*(TRBSF2->F4_CRDPRES/100))
	nValICMS:=TRBSF2->D2_VALICM*(TRBSF2->F4_CRDPRES/100)
else
	nValICMS:=0
endif

If MV_PAR09==2
   //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
   //≥ Verifica o cancelamento pelo usuario...                             ≥
   //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
   //≥ Impressao do cabecalho do relatorio. . .                            ≥
   //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

   If nLin > 55 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif                              
EndIf

//Adiciona os resultados para tratar totais por centro de custo

if MV_PAR08==1 
               //       1               2             3          4          5           6           7             8
               //Centro de custo , Valor Bruto , Valor ICMS, Valor IPI, Valor ISS, Valor Cofins, Valor PIS, Valor liquido 
AADD(aPorCCusto,{ALLTRIM(TRBSF2->D2_CCUSTO),TRBSF2->D2_VALBRUT,TRBSF2->D2_VALICM,TRBSF2->D2_VALIPI,TRBSF2->D2_VALISS,TRBSF2->D2_VALIMP5,TRBSF2->D2_VALIMP6,TRBSF2->D2_VALLIQ})
nII++

if nII<>1

	if aPorCCusto[nII-1][1]==ALLTRIM(TRBSF2->D2_CCUSTO)
		nCCVlBrut+=TRBSF2->D2_VALBRUT
		nCCVlICM+=TRBSF2->D2_VALICM
		nCCVlIPI+=TRBSF2->D2_VALIPI
		nCCVlISS+=TRBSF2->D2_VALISS
		nCCVlCOFINS+=TRBSF2->D2_VALIMP5
		nCCVlPIS+=TRBSF2->D2_VALIMP6
		nCCVlLiq+=TRBSF2->D2_VALLIQ	
		nCCImcs+=nValICMS		
	endif
else
	nCCVlBrut+=TRBSF2->D2_VALBRUT
	nCCVlICM+=TRBSF2->D2_VALICM
	nCCVlIPI+=TRBSF2->D2_VALIPI
	nCCVlISS+=TRBSF2->D2_VALISS
	nCCVlCOFINS+=TRBSF2->D2_VALIMP5
	nCCVlPIS+=TRBSF2->D2_VALIMP6
	nCCVlLiq+=TRBSF2->D2_VALLIQ
	nCCImcs+=nValICMS
	
endif


endif

If MV_PAR09==2
   
   if MV_PAR08==2
	   // Coloque aqui a logica da impressao do seu programa...
	   // Utilize PSAY para saida na impressora. Por exemplo:
	   
	   if !lExibPro
		   @nLin,01 PSAY ALLTRIM(TRBSF2->F2_SERIE)
		   @nLin,08 PSAY ALLTRIM(TRBSF2->F2_DOC)
		   @nLin,19 PSAY DTOC(STOD(ALLTRIM(TRBSF2->F2_EMISSAO)))
		   @nLin,31 PSAY ALLTRIM(TRBSF2->F2_CLIENTE)
		   @nLin,40 PSAY SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
		   @nLin,72 PSAY ALLTRIM(cvaltochar(TRBSF2->D2_QUANT))
		   @nLin,80 PSAY ALLTRIM(TRBSF2->D2_CF)
		   @nLin,87 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALBRUT , "@E 99999999999.99" )) 
		   @nLin,103 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALICM , "@E 99999999999.99" )) 
		   @nLin,119 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIPI , "@E 99999999999.99" )) 
		   @nLin,135 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALISS , "@E 99999999999.99" ))
		   @nLin,151 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP5 , "@E 99999999999.99" ))
		   @nLin,167 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP6 , "@E 99999999999.99" ))
		   @nLin,183 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALLIQ , "@E 99999999999.99" ))   
	   	   @nLin,199 PSAY alltrim(TRANSFORM( nValICMS , "@E 99999999999.99" ))   
	   else 
		   @nLin,01 PSAY ALLTRIM(TRBSF2->F2_SERIE)
		   @nLin,08 PSAY ALLTRIM(TRBSF2->F2_DOC)
		   @nLin,19 PSAY DTOC(STOD(ALLTRIM(TRBSF2->F2_EMISSAO)))
		   @nLin,31 PSAY ALLTRIM(TRBSF2->F2_CLIENTE)
		   @nLin,40 PSAY SUBSTR(ALLTRIM(TRBSF2->B1_COD),1,15)
		   @nLin,57 PSAY SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
		   @nLin,89 PSAY ALLTRIM(cvaltochar(TRBSF2->D2_QUANT))
		   @nLin,97 PSAY ALLTRIM(TRBSF2->D2_CF)
		   @nLin,104 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALBRUT , "@E 99999999999.99" )) 
		   @nLin,120 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALICM , "@E 99999999999.99" )) 
		   @nLin,136 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIPI , "@E 99999999999.99" )) 
		   @nLin,152 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALISS , "@E 99999999999.99" ))
		   @nLin,168 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP5 , "@E 99999999999.99" ))
		   @nLin,184 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP6 , "@E 99999999999.99" ))
		   @nLin,200 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALLIQ , "@E 99999999999.99" ))   
	   	   @nLin,216 PSAY alltrim(TRANSFORM( nValICMS , "@E 99999999999.99" ))   	   
	   endif
   else
	   // Coloque aqui a logica da impressao do seu programa...
	   // Utilize PSAY para saida na impressora. Por exemplo:
	   if nII<>1
	   		if aPorCCusto[nII-1][1]<>ALLTRIM(TRBSF2->D2_CCUSTO)
            
            //sem cod produto
			if !lExibPro
				@nLin,01 PSAY "TOTAL "
				@nLin,102 PSAY alltrim(TRANSFORM( nCCVlBrut, "@E 99999999999.99" )) 
				@nLin,118 PSAY alltrim(TRANSFORM( nCCVlICM , "@E 99999999999.99" )) 
				@nLin,134 PSAY alltrim(TRANSFORM( nCCVlIPI , "@E 99999999999.99" )) 
				@nLin,150 PSAY alltrim(TRANSFORM( nCCVlISS , "@E 99999999999.99" ))
				@nLin,166 PSAY alltrim(TRANSFORM( nCCVlCOFINS , "@E 99999999999.99" ))
				@nLin,182 PSAY alltrim(TRANSFORM( nCCVlPIS , "@E 99999999999.99" ))
				@nLin,198 PSAY alltrim(TRANSFORM( nCCVlLiq , "@E 99999999999.99" ))   
				@nLin,214 PSAY alltrim(TRANSFORM( nCCImcs , "@E 99999999999.99" ))
			else 
				@nLin,01 PSAY "TOTAL "
				@nLin,119 PSAY alltrim(TRANSFORM( nCCVlBrut, "@E 99999999999.99" )) 
				@nLin,135 PSAY alltrim(TRANSFORM( nCCVlICM , "@E 99999999999.99" )) 
				@nLin,151 PSAY alltrim(TRANSFORM( nCCVlIPI , "@E 99999999999.99" )) 
				@nLin,167 PSAY alltrim(TRANSFORM( nCCVlISS , "@E 99999999999.99" ))
				@nLin,183 PSAY alltrim(TRANSFORM( nCCVlCOFINS , "@E 99999999999.99" ))
				@nLin,199 PSAY alltrim(TRANSFORM( nCCVlPIS , "@E 99999999999.99" ))
				@nLin,215 PSAY alltrim(TRANSFORM( nCCVlLiq , "@E 99999999999.99" ))   
				@nLin,231 PSAY alltrim(TRANSFORM( nCCImcs , "@E 99999999999.99" ))			
			endif	
					
	  		nCCVlBrut:=TRBSF2->D2_VALBRUT
			nCCVlICM:=TRBSF2->D2_VALICM
			nCCVlIPI:=TRBSF2->D2_VALIPI
			nCCVlISS:=TRBSF2->D2_VALISS
			nCCVlCOFINS:=TRBSF2->D2_VALIMP5
			nCCVlPIS:=TRBSF2->D2_VALIMP6
			nCCVlLiq:=TRBSF2->D2_VALLIQ	
			nCCImcs:=nValICMS
	
				nLin := nLin + 2 // Avanca a linha de impressao  
				@nLin,01 PSAY ALLTRIM(TRBSF2->D2_CCUSTO)	   		
	   		endif
	   else
		   @nLin,01 PSAY TRBSF2->D2_CCUSTO
	   endif
		
	   //sem cod produto	
	   if  !lExibPro
		   @nLin,16 PSAY ALLTRIM(TRBSF2->F2_SERIE)
		   @nLin,23 PSAY ALLTRIM(TRBSF2->F2_DOC)
		   @nLin,34 PSAY DTOC(STOD(ALLTRIM(TRBSF2->F2_EMISSAO)))
		   @nLin,46 PSAY ALLTRIM(TRBSF2->F2_CLIENTE)
		   @nLin,55 PSAY SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
		   @nLin,87 PSAY ALLTRIM(cvaltochar(TRBSF2->D2_QUANT))
		   @nLin,95 PSAY ALLTRIM(TRBSF2->D2_CF)
		   @nLin,102 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALBRUT , "@E 99999999999.99" )) 
		   @nLin,118 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALICM , "@E 99999999999.99" )) 
		   @nLin,134 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIPI , "@E 99999999999.99" )) 
		   @nLin,150 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALISS , "@E 99999999999.99" ))
		   @nLin,166 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP5 , "@E 99999999999.99" ))
		   @nLin,182 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP6 , "@E 99999999999.99" ))
		   @nLin,198 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALLIQ , "@E 99999999999.99" ))   
		   @nLin,214 PSAY alltrim(TRANSFORM( nValICMS , "@E 99999999999.99" ))   
	   else 
		   @nLin,16 PSAY ALLTRIM(TRBSF2->F2_SERIE)
		   @nLin,23 PSAY ALLTRIM(TRBSF2->F2_DOC)
		   @nLin,34 PSAY DTOC(STOD(ALLTRIM(TRBSF2->F2_EMISSAO)))
		   @nLin,46 PSAY ALLTRIM(TRBSF2->F2_CLIENTE)
		   @nLin,55 PSAY SUBSTR(ALLTRIM(TRBSF2->B1_COD),1,15)
		   @nLin,72 PSAY SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
		   @nLin,104 PSAY ALLTRIM(cvaltochar(TRBSF2->D2_QUANT))
		   @nLin,112 PSAY ALLTRIM(TRBSF2->D2_CF)
		   @nLin,119 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALBRUT , "@E 99999999999.99" )) 
		   @nLin,135 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALICM , "@E 99999999999.99" )) 
		   @nLin,151 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIPI , "@E 99999999999.99" )) 
		   @nLin,167 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALISS , "@E 99999999999.99" ))
		   @nLin,183 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP5 , "@E 99999999999.99" ))
		   @nLin,199 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALIMP6 , "@E 99999999999.99" ))
		   @nLin,215 PSAY alltrim(TRANSFORM( TRBSF2->D2_VALLIQ , "@E 99999999999.99" ))   
	   	   @nLin,231 PSAY alltrim(TRANSFORM( nValICMS , "@E 99999999999.99" ))   	              
	   endif
   endif
            
EndIf 


if MV_PAR08==2
RecLock("DADXLS",.T.)
	if !lExibPro
		DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
		DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
		DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
		DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
		DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
		DADXLS->QTDE:=TRBSF2->D2_QUANT
		DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
		DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
		DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
		DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
		DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
		DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
		DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
		DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
		DADXLS->VLR_ICMSPR:=nValICMS
	else 
		DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
		DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
		DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
		DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
		DADXLS->CODPROD:=SUBSTR(ALLTRIM(TRBSF2->B1_COD),1,15)
		DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
		DADXLS->QTDE:=TRBSF2->D2_QUANT
		DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
		DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
		DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
		DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
		DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
		DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
		DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
		DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
		DADXLS->VLR_ICMSPR:=nValICMS

	endif	
DADXLS->(MsUnlock())
else

	if nII<>1
		if aPorCCusto[nII-1][1]<>ALLTRIM(TRBSF2->D2_CCUSTO)
            
            RecLock("DADXLS",.T.)
            
        	DADXLS->CEN_CUSTO:="TOTAL"
            DADXLS->VLR_BRUTO:=nCCVlBrut
			DADXLS->VLR_ICMS:=nCCVlICM
			DADXLS->VLR_IPI:=nCCVlIPI
			DADXLS->VLR_ISS:=nCCVlISS
			DADXLS->VLR_COFINS:=nCCVlCOFINS
			DADXLS->VLR_PIS:=nCCVlPIS
			DADXLS->VLR_LIQUID:=nCCVlLiq
			DADXLS->VLR_ICMSPR:=nCCImcs
			
			DADXLS->(MsUnlock())
            
   	  		
   	  		nCCVlBrut:=TRBSF2->D2_VALBRUT
			nCCVlICM:=TRBSF2->D2_VALICM
			nCCVlIPI:=TRBSF2->D2_VALIPI
			nCCVlISS:=TRBSF2->D2_VALISS
			nCCVlCOFINS:=TRBSF2->D2_VALIMP5
			nCCVlPIS:=TRBSF2->D2_VALIMP6
			nCCVlLiq:=TRBSF2->D2_VALLIQ	
			nCCImcs:=nValICMS
        
			
            RecLock("DADXLS",.T.)			
			if !lExibPro
				DADXLS->CEN_CUSTO:=ALLTRIM(TRBSF2->D2_CCUSTO)
				DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
				DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
				DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
				DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
				DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
				DADXLS->QTDE:=TRBSF2->D2_QUANT
				DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
				DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
				DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
				DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
				DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
				DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
				DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
				DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
				DADXLS->VLR_ICMSPR:=nValICMS
			else
				DADXLS->CEN_CUSTO:=ALLTRIM(TRBSF2->D2_CCUSTO)
				DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
				DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
				DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
				DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
				DADXLS->CODPROD:=SUBSTR(ALLTRIM(TRBSF2->B1_COD),1,15)
				DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
				DADXLS->QTDE:=TRBSF2->D2_QUANT
				DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
				DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
				DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
				DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
				DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
				DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
				DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
				DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
				DADXLS->VLR_ICMSPR:=nValICMS			
			endif
		    DADXLS->(MsUnlock())            
		    lRecLo:=.T.
        endif
	else
        RecLock("DADXLS",.T.)
		if !lExibPro
			DADXLS->CEN_CUSTO:=ALLTRIM(TRBSF2->D2_CCUSTO)
			DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
			DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
			DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
			DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
			DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
			DADXLS->QTDE:=TRBSF2->D2_QUANT
			DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
			DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
			DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
			DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
			DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
			DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
			DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
			DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
			DADXLS->VLR_ICMSPR:=nValICMS
		else 
			DADXLS->CEN_CUSTO:=ALLTRIM(TRBSF2->D2_CCUSTO)
			DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
			DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
			DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
			DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
			DADXLS->CODPROD:=SUBSTR(ALLTRIM(TRBSF2->B1_COD),1,15)			
			DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
			DADXLS->QTDE:=TRBSF2->D2_QUANT
			DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
			DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
			DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
			DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
			DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
			DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
			DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
			DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
			DADXLS->VLR_ICMSPR:=nValICMS		
		endif	
		DADXLS->(MsUnlock())
		lRecLo:=.T.
	endif
	    
		if !lRecLo
		    RecLock("DADXLS",.T.)
			if !lExibPro
				DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
				DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
				DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
				DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
				DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
				DADXLS->QTDE:=TRBSF2->D2_QUANT
				DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
				DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
				DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
				DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
				DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
				DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
				DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
				DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
				DADXLS->VLR_ICMSPR:=nValICMS
			else
				DADXLS->SERIE:=ALLTRIM(TRBSF2->F2_SERIE)
				DADXLS->DOCUMENTO:=ALLTRIM(TRBSF2->F2_DOC)
				DADXLS->EMISSAO:=STOD(TRBSF2->F2_EMISSAO)
				DADXLS->CLIENTE:=ALLTRIM(TRBSF2->F2_CLIENTE)
				DADXLS->CODPROD:=SUBSTR(ALLTRIM(TRBSF2->B1_COD),1,15)							
				DADXLS->PRODUTO:=SUBSTR(ALLTRIM(TRBSF2->B1_DESC),1,30)
				DADXLS->QTDE:=TRBSF2->D2_QUANT
				DADXLS->CFOP:=ALLTRIM(TRBSF2->D2_CF)
				DADXLS->VLR_BRUTO:=TRBSF2->D2_VALBRUT
				DADXLS->VLR_ICMS:=TRBSF2->D2_VALICM
				DADXLS->VLR_IPI:=TRBSF2->D2_VALIPI
				DADXLS->VLR_ISS:=TRBSF2->D2_VALISS
				DADXLS->VLR_COFINS:=TRBSF2->D2_VALIMP5
				DADXLS->VLR_PIS:=TRBSF2->D2_VALIMP6
				DADXLS->VLR_LIQUID:=TRBSF2->D2_VALLIQ
				DADXLS->VLR_ICMSPR:=nValICMS			
			endif	
			DADXLS->(MsUnlock())
	    	
	    endif
	    lRecLo:=.F.
endif

   nLin := nLin + 1 // Avanca a linha de impressao     

//armazena os totais gerais dos valores.
nVlBrut+=TRBSF2->D2_VALBRUT
nVlICM+=TRBSF2->D2_VALICM
nVlIPI+=TRBSF2->D2_VALIPI
nVlISS+=TRBSF2->D2_VALISS
nVlCOFINS+=TRBSF2->D2_VALIMP5
nVlPIS+=TRBSF2->D2_VALIMP6
nVlLiq+=TRBSF2->D2_VALLIQ
nTotIcms+=nValICMS

   TRBSF2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo                    

//*********************TOTAIS*************************
	if MV_PAR08==2
	   // Coloque aqui a logica da impressao do seu programa...
	   // Utilize PSAY para saida na impressora. Por exemplo:
	   if !lExibPro
	   
		   @nLin,01 PSAY "TOTAIS"
		   
		   @nLin,87 PSAY alltrim(TRANSFORM( nVlBrut , "@E 99999999999.99" )) 
		   @nLin,103 PSAY alltrim(TRANSFORM( nVlICM , "@E 99999999999.99" )) 
		   @nLin,119 PSAY alltrim(TRANSFORM( nVlIPI , "@E 99999999999.99" )) 
		   @nLin,135 PSAY alltrim(TRANSFORM( nVlISS , "@E 99999999999.99" ))
		   @nLin,151 PSAY alltrim(TRANSFORM( nVlCOFINS , "@E 99999999999.99" ))
		   @nLin,167 PSAY alltrim(TRANSFORM( nVlPIS , "@E 99999999999.99" ))
		   @nLin,183 PSAY alltrim(TRANSFORM( nVlLiq , "@E 99999999999.99" ))  	
		   @nLin,199 PSAY alltrim(TRANSFORM( nTotIcms , "@E 99999999999.99" ))
	   else
		   @nLin,01 PSAY "TOTAIS"
		   
		   @nLin,104 PSAY alltrim(TRANSFORM( nVlBrut , "@E 99999999999.99" )) 
		   @nLin,120 PSAY alltrim(TRANSFORM( nVlICM , "@E 99999999999.99" )) 
		   @nLin,136 PSAY alltrim(TRANSFORM( nVlIPI , "@E 99999999999.99" )) 
		   @nLin,152 PSAY alltrim(TRANSFORM( nVlISS , "@E 99999999999.99" ))
		   @nLin,168 PSAY alltrim(TRANSFORM( nVlCOFINS , "@E 99999999999.99" ))
		   @nLin,184 PSAY alltrim(TRANSFORM( nVlPIS , "@E 99999999999.99" ))
		   @nLin,200 PSAY alltrim(TRANSFORM( nVlLiq , "@E 99999999999.99" ))  	
		   @nLin,216 PSAY alltrim(TRANSFORM( nTotIcms , "@E 99999999999.99" ))	   
	   
	   endif
		nLin := nLin + 1
		
		RecLock("DADXLS",.T.)
			
		DADXLS->DOCUMENTO:="TOTAIS"
		DADXLS->VLR_BRUTO:=nVlBrut
		DADXLS->VLR_ICMS:=nVlICM
		DADXLS->VLR_IPI:=nVlIPI
		DADXLS->VLR_ISS:=nVlISS
		DADXLS->VLR_COFINS:=nVlCOFINS
		DADXLS->VLR_PIS:=nVlPIS
		DADXLS->VLR_LIQUID:=nVlLiq
		DADXLS->VLR_ICMSPR:=nTotIcms	
		
		DADXLS->(MsUnlock())	
    else
    //AJUSTAR AKI PRECISA FAZER TOTAIS POR CENTRO DE CUSTO*********************
        if !lExibPro
	        //Total do ultimo centro de custo
			@nLin,01 PSAY "TOTAL "
			@nLin,102 PSAY alltrim(TRANSFORM( nCCVlBrut, "@E 99999999999.99" )) 
			@nLin,118 PSAY alltrim(TRANSFORM( nCCVlICM , "@E 99999999999.99" )) 
			@nLin,134 PSAY alltrim(TRANSFORM( nCCVlIPI , "@E 99999999999.99" )) 
			@nLin,150 PSAY alltrim(TRANSFORM( nCCVlISS , "@E 99999999999.99" ))
			@nLin,166 PSAY alltrim(TRANSFORM( nCCVlCOFINS , "@E 99999999999.99" ))
			@nLin,182 PSAY alltrim(TRANSFORM( nCCVlPIS , "@E 99999999999.99" ))
			@nLin,198 PSAY alltrim(TRANSFORM( nCCVlLiq , "@E 99999999999.99" )) 
			@nLin,214 PSAY alltrim(TRANSFORM( nCCImcs , "@E 99999999999.99" ))
			
			nLin := nLin + 1    
			//total geral de todos os centro de custos
			@nLin,01 PSAY "TOTAIS "
			@nLin,102 PSAY alltrim(TRANSFORM( nVlBrut, "@E 99999999999.99" )) 
			@nLin,118 PSAY alltrim(TRANSFORM( nVlICM , "@E 99999999999.99" )) 
			@nLin,134 PSAY alltrim(TRANSFORM( nVlIPI , "@E 99999999999.99" )) 
			@nLin,150 PSAY alltrim(TRANSFORM( nVlISS , "@E 99999999999.99" ))
			@nLin,166 PSAY alltrim(TRANSFORM( nVlCOFINS , "@E 99999999999.99" ))
			@nLin,182 PSAY alltrim(TRANSFORM( nVlPIS , "@E 99999999999.99" ))
			@nLin,198 PSAY alltrim(TRANSFORM( nVlLiq , "@E 99999999999.99" ))
			@nLin,214 PSAY alltrim(TRANSFORM( nTotIcms , "@E 99999999999.99" ))	
        else
	        //Total do ultimo centro de custo
			@nLin,01 PSAY "TOTAL "
			@nLin,119 PSAY alltrim(TRANSFORM( nCCVlBrut, "@E 99999999999.99" )) 
			@nLin,135 PSAY alltrim(TRANSFORM( nCCVlICM , "@E 99999999999.99" )) 
			@nLin,151 PSAY alltrim(TRANSFORM( nCCVlIPI , "@E 99999999999.99" )) 
			@nLin,167 PSAY alltrim(TRANSFORM( nCCVlISS , "@E 99999999999.99" ))
			@nLin,183 PSAY alltrim(TRANSFORM( nCCVlCOFINS , "@E 99999999999.99" ))
			@nLin,199 PSAY alltrim(TRANSFORM( nCCVlPIS , "@E 99999999999.99" ))
			@nLin,215 PSAY alltrim(TRANSFORM( nCCVlLiq , "@E 99999999999.99" )) 
			@nLin,231 PSAY alltrim(TRANSFORM( nCCImcs , "@E 99999999999.99" ))
			
			nLin := nLin + 1    
			//total geral de todos os centro de custos
			@nLin,01 PSAY "TOTAIS "
			@nLin,119 PSAY alltrim(TRANSFORM( nVlBrut, "@E 99999999999.99" )) 
			@nLin,135 PSAY alltrim(TRANSFORM( nVlICM , "@E 99999999999.99" )) 
			@nLin,151 PSAY alltrim(TRANSFORM( nVlIPI , "@E 99999999999.99" )) 
			@nLin,167 PSAY alltrim(TRANSFORM( nVlISS , "@E 99999999999.99" ))
			@nLin,183 PSAY alltrim(TRANSFORM( nVlCOFINS , "@E 99999999999.99" ))
			@nLin,199 PSAY alltrim(TRANSFORM( nVlPIS , "@E 99999999999.99" ))
			@nLin,215 PSAY alltrim(TRANSFORM( nVlLiq , "@E 99999999999.99" ))
			@nLin,231 PSAY alltrim(TRANSFORM( nTotIcms , "@E 99999999999.99" ))	        
        endif

        RecLock("DADXLS",.T.)
        //Total do ultimo centro de custo
       	DADXLS->CEN_CUSTO:="TOTAL"
        DADXLS->VLR_BRUTO:=nCCVlBrut
		DADXLS->VLR_ICMS:=nCCVlICM
		DADXLS->VLR_IPI:=nCCVlIPI
		DADXLS->VLR_ISS:=nCCVlISS
		DADXLS->VLR_COFINS:=nCCVlCOFINS
		DADXLS->VLR_PIS:=nCCVlPIS
		DADXLS->VLR_LIQUID:=nCCVlLiq
		DADXLS->VLR_ICMSPR:=nCCImcs		
			
		DADXLS->(MsUnlock())	
        

		RecLock("DADXLS",.T.)
		//total geral dos centros de custos
		DADXLS->CEN_CUSTO:="TOTAIS"
		DADXLS->VLR_BRUTO:=nVlBrut
		DADXLS->VLR_ICMS:=nVlICM
		DADXLS->VLR_IPI:=nVlIPI
		DADXLS->VLR_ISS:=nVlISS
		DADXLS->VLR_COFINS:=nVlCOFINS
		DADXLS->VLR_PIS:=nVlPIS
		DADXLS->VLR_LIQUID:=nVlLiq
		DADXLS->VLR_ICMSPR:=nTotIcms
	
		DADXLS->(MsUnlock())
    
    
    endif
//*********************FIM TOTAIS*************************

DADXLS->(DbCloseArea()) 

If MV_PAR09==2
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Finaliza a execucao do relatorio...                                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

SET DEVICE TO SCREEN

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Se impressao em disco, chama o gerenciador de impressao...          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif


MS_FLUSH()

EndIf

TRBSF2->(DBCloseArea())

If MV_PAR09==1

If !ApOleClient("MsExcel")
     MsgStop("Microsoft Excel nao instalado.")
     Return
EndIf 
	
	cArqOrig := "\"+CURDIR()+cNome+".DBF"
   	cPath     := AllTrim(GetTempPath())                                                   
   	CpyS2T( cArqOrig , cPath, .T. )
     //cPath:="C:\PROTHEUS\PROTHEUS_DATA\sysgt\" 
       
    oExcelApp:=MsExcel():New()
    //oExcelApp:WorkBooks:Open("Z:\AMB01\SYSTEM\"+cNome+".DBF") 
    oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
    oExcelApp:SetVisible(.T.)   

sleep(05)	
EndIf 

Erase &cNome+".DBF"            

Return

/*
 ----------------------------------------------------
|	FunÁ„o para validar se a data da                 |
|   Pergunta estÅEvazia. Obs: — permite Data Vazia.  |
 ----------------------------------------------------
*/
User function ValSF2SI(cData)
local lRet:=.T.

If Empty(cData)
	msginfo("Campo Data Vazio!!")
	lRet:=.F. 
EndIf

Return(lRet) 
/*
 ----------------------------------------------------
|	FunÁ„o para validar o conteudo digitado no CFOP  |
 ----------------------------------------------------
*/
User Function ValSF2CF(cCFs)
local lRet:=.T.

for i:=1 to len(alltrim(cCFs))
	if substr(cCFs,i,1) $ "!@#$%®&*()-+=?|{}^™∫ß¢¨',.;<>:∞\[]≤≥π¥`~£Á«‰·‡‚„ƒ¡¿¬√ÅEËÍÀ…» ÅEÅEœÕÃŒˆÛÚÙı÷”“‘’ÅE˘˚‹⁄Ÿ€abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ"
    	msginfo("Digito inv·lido: "+substr(cCFs,i,1))
		lRet:=.F.
		exit
	endif
next

return(lRet)
