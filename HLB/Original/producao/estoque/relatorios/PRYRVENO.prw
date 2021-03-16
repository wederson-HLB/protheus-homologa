#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �	  � Autor �  Matheus       � Data � 17/02/2011		      ���
�������������������������������������������������������������������������͹��
���Descricao � Fonte para gerar relat�rio em excel, Posi��o dos produtos  ���
���Descricao � vendidos   												  ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

Funcao      : PRYRVENO 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Fonte para gerar relat�rio em excel, Posi��o dos produtos vendidos 
Autor     	: Matheus Massarotto  	 	
Data     	: 17/02/2011
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/03/2012
M�dulo      : Gest�o Pessoal.
Cliente     : Todos.
*/

*-----------------------*
 User Function PRYRVENO
*-----------------------*

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Relat�rio de Vendas"
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
Private cPlanImp := "SD2"
Private cTitPlan := 'Relatorio'
//Private cArquivo   := "C:\temp\"+titulo
Private cArquivo   := GetTempPath()+titulo

if !cEmpAnt $ "ED"
	Alert("Relat�rio n�o dispon�vel para esta empresa!")
	return
endif
//Defini��o das perguntas.

U_PUTSX1( "RVOKUMA_P", "01", "Produto De:", "Produto De:", "Produto De:", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR01")
U_PUTSX1( "RVOKUMA_P", "02", "Produto Ate:", "Produto Ate:", "Produto Ate:", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR02")
U_PUTSX1( "RVOKUMA_P", "03", "Filial De:", "Filial De:", "Filial De:", "", "C",2,00,00,"G","" , "","","","MV_PAR03")
U_PUTSX1( "RVOKUMA_P", "04", "Filial Ate:", "Filial Ate:", "Filial Ate:", "", "C",2,00,00,"G","" , "","","","MV_PAR04")
U_PUTSX1( "RVOKUMA_P", "05", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","U_ValRVEOku(MV_PAR05)" , "","","","MV_PAR05")
U_PUTSX1( "RVOKUMA_P", "06", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","U_ValRVEOku(MV_PAR06)" , "","","","MV_PAR06")
U_PUTSX1( "RVOKUMA_P", "07", "Grupo De:", "Grupo De:", "Grupo De:", "", "C",4,00,00,"G","" , "SBM","","","MV_PAR07")
U_PUTSX1( "RVOKUMA_P", "08", "Grupo Ate:", "Grupo Ate:", "Grupo Ate:", "", "C",4,00,00,"G","" , "SBM","","","MV_PAR08")
U_PUTSX1( "RVOKUMA_P", "09", "Gera Excel?:", "Gera Excel?", "Gera Excel?", "", "N",1,00,00,"C","" , "","","","MV_PAR09","Sim","","","","N�o") 
U_PUTSX1( "RVOKUMA_P", "10", "Cons. Param. Abaixo?:", "Cons. Param. Abaixo?", "Cons. Param. Abaixo?", "", "N",1,00,00,"C","" , "","","","MV_PAR10","Sim","","","","N�o") 
U_PUTSX1( "RVOKUMA_P", "11", "Cons. Tes Duplicata?:", "Cons. Tes Duplicata?", "Cons. Tes Duplicata?", "", "N",1,00,00,"C","" , "","","","MV_PAR11","Sim","","","","N�o") 

Private cPerg := "RVOKUMA_P"
Private cString:="SD2"

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������



If !Pergunte(cPerg,.T.)
	Return()
EndIf   
/*

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
	
	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �       
	//�����������������������������������������������������������������������
	
	RptStatus({|| RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Else
	RptStatus({|| RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
EndIf
*/
	RptStatus({|| RUNREPORT() },Titulo)
	Return

Static Function RUNREPORT()
                                                         
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
//Jun��o dos dois Selects A e B 
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
//Select que tr�s todas as notas que n�o s�o de complemento ICMS D2_TIPO = I
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
/*
If tcsqlexec(cQry1)<0
	Alert("Ocorreu um problema na busca das informa��es!!")
	return
EndIf
*/

//memowrite("C:\Grant Thorntom\Querys\cQry2.sql",cQry1)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TSD2",.T.,.T.)                                                         

				//#################### REGUA CABE�ALHO ###################\\ 
				
		//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230
		//	 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890					
		//   XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXX       XXXXXXXXXX     XXXXXXXXXX  XXXXXXXXXX     XXXXXXXXXX  XXXXXXXXXX  XXXX
                                        
//Cabec1 := 	"PRODUTO          DESCRICAO                                           QUANTIDADE     TOTAL       VLR.ICMS    VLR.IPI     VL.TOTAL VENDAS  VL.PIS/COFINS  CUSTO       VENDA LIQUIDA  MARGEM      MARGEM %    GRUPO

                                                                                                     
Private aDadTemp:={}

//Cria��o dos campos da tabela tempor�ria

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

//Vitor EZ4 -> chamado 22371 (alterando tipo de relatorio de DBF para XML EXCEL)
//Vitor EZ4 -> chamado 22371 (Deste ponto em diante alteramos a criação de tabela temporaria)
//Vitor EZ4 -> chamado 22371 (até a linha 471)
//Criando nome temporario
//cNome := CriaTrab(Nil,.F.)//CriaTrab(aDadTemp,.t.)


DbSelectArea("TSD2")
TSD2->(DBGotop())
SetRegua(TSD2->(RecCount()))
SetRegua(RecCount())


oTempTable := FWTemporaryTable():New( "EZ4" )

oTemptable:SetFields( aDadTemp )
oTempTable:AddIndex("cIndex", {"Produto"} )


oTempTable:Create()

TSD2->(DBGotop())
SetRegua(TSD2->(RecCount()))


While TSD2->(!EOF())  //carrega tabela tempor�ria para, abrir arquivo no excel.

	Reclock("EZ4",.T.)

	EZ4->Produto:=ALLTRIM(TSD2->D2_COD)
	EZ4->Descricao:=ALLTRIM(TSD2->B1_DESC)
	EZ4->Quantidade:=TSD2->QTDE
	EZ4->Vl_Total:=ROUND(TSD2->TOTAL,2)
	EZ4->Vl_ICMS:=ROUND(TSD2->ICMS,2)
	EZ4->Vl_ST:=ROUND(TSD2->ST,2)
	EZ4->Vl_IPI:=ROUND(TSD2->IPI,2)
	EZ4->Vl_Tot_Ven:=ROUND(TSD2->VALTOTAL_VENDAS,2)
	EZ4->PIS_COFINS:=ROUND(TSD2->PIS_COFINS,2)
	EZ4->Custo:=ROUND(TSD2->D2_CUSTO1,2)
	EZ4->Venda_Liq:=ROUND(TSD2->VENDLIQ,2)
	EZ4->Margem:=STRTRAN(ALLTRIM( IIF(ROUND(TSD2->MARGEN,2)<0,"("+ALLTRIM(STR(ABS(ROUND(TSD2->MARGEN,2))))+")",STR(ROUND(TSD2->MARGEN,2)) ) ),".",",")
	EZ4->Margem_Por:=STRTRAN(ALLTRIM(STR(ROUND(TSD2->MARGEMPORC,2)))+"%",".",",")
	EZ4->Grupo:=ALLTRIM(TSD2->B1_GRUPO)
  
	EZ4->(MsUnlock())
	TSD2->(dbSkip()) // Avanca o ponteiro do registro no arquivo

EndDo


//TOTAIS

//Impress�o em arquivo do siga
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

 //carrega tabela tempor�ria para, abrir arquivo no excel.
/*
Reclock("EZ4",.T.)

EZ4->Quantidade:=nTotQtde
EZ4->Vl_Total:=ROUND(nTotTotal,2)
EZ4->Vl_ICMS:=ROUND(nTotICMS,2)
EZ4->Vl_ST:=ROUND(nTotST,2)
EZ4->Vl_IPI:=ROUND(nTotIPI,2)
EZ4->Vl_Tot_Ven:=ROUND(nTotVendas,2)
EZ4->PIS_COFINS:=ROUND(nTotPC,2)
EZ4->Custo:=ROUND(nTotCusto,2)
EZ4->Venda_Liq:=ROUND(nTotVLiq,2)
EZ4->Margem:=STRTRAN(ALLTRIM( IIF(ROUND(nTotMargem,2)<0,"("+ALLTRIM(STR(ABS(ROUND(nTotMargem,2))))+")",STR(ROUND(nTotMargem,2)) ) ),".",",")
EZ4->Margem_Por:=STRTRAN(ALLTRIM(STR(ROUND((nTotMargem/nTotVLiq)*100,2)))+"%",".",",")

EZ4->(MsUnlock())
*/


//EZ4->(DbCloseArea())

If MV_PAR09==2
	//���������������������������������������������������������������������Ŀ
	//� Finaliza a execucao do relatorio...                                 �
	//�����������������������������������������������������������������������
	
	SET DEVICE TO SCREEN
	
	//���������������������������������������������������������������������Ŀ
	//� Se impressao em disco, chama o gerenciador de impressao...          �
	//�����������������������������������������������������������������������
	
	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif
	
	
	MS_FLUSH()
EndIf

//TSD2->(DBCloseArea())

//Se for para imprimir no excel
//If MV_PAR09==1
	//If !ApOleClient("MsExcel")
	    // MsgStop("Microsoft Excel nao instalado.")
	    // Return
	//EndIf 
		
	//	cArqOrig := "\"+CURDIR()+cNome+".DBF"
	//   	cPath     := AllTrim(GetTempPath())                                                   
	   	
		//IF CpyS2T( cArqOrig , cPath, .T. )
			//oExcelApp:=MsExcel():New()
			//oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
			//oExcelApp:SetVisible(.T.)   
		//ELSE
			//MSGALERT("ERRO AO TENTAR REALIZAR A C�PIA DA TABELA TEMPORARIA (FERROR):"+STR(FERROR(),4),"ERRO FERROR -> CPYS2T")
		//ENDIF
	
	//sleep(05)	
//EndIf 

//Criando o objeto que irá gerar o conteúdo do Excel
oFWMsExcel := FWMSExcel():New()     

oFWMsExcel:AddworkSheet(cPlanImp) //Não utilizar número junto com sinal de menos. Ex.: 1-   
//Criando a Tabela                                                                          
oFWMsExcel:AddTable(cPlanImp,cTitPlan)                                                      
//Criando Colunas                                                                           
                              
//Saida                                                                                     
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Produto" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Descricao" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Quantidade" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Vl_Total" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Vl_ICMS" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Vl_ST" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Vl_IPI" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Vl_Tot_Ven" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"PIS_COFINS" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Custo" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Venda_Liq" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Margem" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Margem_Por" ,1) 
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Grupo" ,1) 

                                                                                            
EZ4->(dbGoTop())     

Do while EZ4->(!Eof())                                                      
                                                                                
            //Criando as Linhas                                                 
                                                                                
            oFWMsExcel:AddRow(cPlanImp,cTitPlan,{;                            
												EZ4->Produto	,;
												EZ4->Descricao	,;
												EZ4->Quantidade	,;
												EZ4->Vl_Total	,;
												EZ4->Vl_ICMS	,;
												EZ4->Vl_ST		,;
												EZ4->Vl_IPI		,;
												EZ4->Vl_Tot_Ven	,;
												EZ4->PIS_COFINS	,;
												EZ4->Custo		,;
												EZ4->Venda_Liq	,;
												EZ4->Margem		,;
												EZ4->Margem_Por	,;
												EZ4->Grupo		} )		     
        EZ4->(dbskip())                                      
                                                                                
EndDo      

EZ4->(dbGoTop()) 

//Ativando o arquivo e gerando o xml                                            
oFWMsExcel:Activate()                                                           
oFWMsExcel:GetXMLFile(cArquivo)                                                 
                                                                                
//Abrindo o excel e abrindo o arquivo xml                                       
oExcel := MsExcel():New()                 //Abre uma nova conexão com Excel     
oExcel:WorkBooks:Open(cArquivo)           //Abre uma planilha                   
oExcel:SetVisible(.T.)                    //Visualiza a planilha                
oExcel:Destroy()     	                                                          

EZ4->(DbCloseArea())
TSD2->(DBCloseArea())


//Apaga tabela tempor�ria
//Erase &cNome+".DBF"            

Return

/*
 ----------------------------------------------------
|	Fun��o para validar se a data da                 |
|   Pergunta est� vazia. Obs: � permite Data Vazia.  |
 ----------------------------------------------------
*/

User function ValRVEOku(cData)
local lRet:=.T.

If Empty(cData)
	msginfo("Campo Data Vazio!!")
	lRet:=.F. 
EndIf

Return(lRet)
