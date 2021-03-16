#include "Protheus.ch"

/*
Funcao      : GTGEN043
Parametros  : cPedido,cTipo
Retorno     : Array com impostos baseados na capa ou nos itens
Objetivos   : Calcular impostos com base no pedido de venda
Autor     	: Anderson Arrais
Data     	: 16/03/2018 
TDN         : http://tdn.totvs.com/display/public/PROT/FIS0002_MaFisIni_MATXFIS  
 			  http://tdn.totvs.com/display/public/PROT/FIS0001_MaFisRet_Retornos_MATXFIS
Link Externo: https://www.smartsiga.com.br/download/57/advpl/470/guia-de-utilizacao-matxfis.pdf
			  http://ventura.pro.br/analista/?p=19
Módulo      : Faturamento
Empresa		: Todas
*/   
                                       
*-------------------------------------* 
 User Function GTGEN043(cPedido,cTipo)
*-------------------------------------*  
Local aArea 			:= GetArea()
Local aRet				:= {}

Local nBASEICM,nVALICM	:= 0
Local nBASESOL,nVALSOL	:= 0
Local nVALCMP			:= 0
Local nBASEIPI,nVALIPI	:= 0
Local nBASEISS,nVALISS	:= 0
Local nBASEIRR,nVALIRR	:= 0
Local nBASEINS,nVALINS	:= 0
Local nBASECOF,nVALCOF	:= 0
Local nBASECSL,nVALCSL	:= 0
Local nBASEPIS,nVALPIS	:= 0
Local nBASECF2,nVALCF2	:= 0
Local nBASEPS2,nVALPS2	:= 0
Local nALIQICM,nALIQSOL,nALIQCMP,nALIQIPI,nALIQISS,nALIQIRR,nALIQINS,nALIQCOF,nALIQCSL,nALIQPIS,nALIQCF2,nALIQPS2 := 0
Local cPRODUTO			:= ""

DbSelectArea("SC5")
SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5")+cPedido))//C5_FILIAL+C5_NUM

DbSelectArea("SC6")
SC6->(DbSetOrder(1))
SC6->(DbSeek(xFilial("SC6")+cPedido))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

DbSelectArea("SA1")
SA1->(DbSetOrder(1))  
SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))//A1_FILIAL+A1_COD+A1_LOJA                    

//Verifica se vai pegar os impostos baseado na capa(NF) ou nos itens (IT).
If cTipo $ "NF" //CAPA
	//A função MaFisIni() é responsável por iniciar todo o processo da MATXFIS
	MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,If(SC5->C5_TIPO$'DB',"F","C"),SC5->C5_TIPO,;
		SC5->C5_TIPOCLI,,,.F.,"SB1",,,,,,,,,,,,SC5->C5_NUM ,SC5->C5_CLIENTE,SC5->C5_LOJACLI)
	
	While SC6->(!EOF()) .AND. ALLTRIM(SC6->C6_NUM) == ALLTRIM(cPedido)
		//MaFisAdd() Inclui um novo item no array aNFItem da MATXFIS
		MaFisAdd(SC6->C6_PRODUTO, SC6->C6_TES, SC6->C6_QTDVEN,SC6->C6_PRCVEN, SC6->C6_DESCONT, "", "",, 0, 0, 0, 0, SC6->C6_VALOR, 0 )
		SC6->(DbSkip())   
	EndDo    
	
	//MaFisRet() Retorna o conteúdo (no caso de valores de impostos, os valores já calculados) da referência fiscal informada
	nBASEICM	:= MaFisRet(,"NF_BASEICM" ) 	//[1]Valor base de ICMS
	nVALICM		:= MaFisRet(,"NF_VALICM" )      //[2]Valor do ICMS normal
	nBASESOL	:= MaFisRet(,"NF_BASESOL" )     //[3]Base ICMS solidario
	nVALSOL		:= MaFisRet(,"NF_VALSOL" )      //[4]Valor ICMS solidario
	nVALCMP		:= MaFisRet(,"NF_VALCMP" )      //[5]Valor ICMS complementar
	nBASEIPI	:= MaFisRet(,"NF_BASEIPI" )     //[6]Valor base do IPI
	nVALIPI		:= MaFisRet(,"NF_VALIPI" )      //[7]Valor do IPI
	nBASEISS	:= MaFisRet(,"NF_BASEISS" )		//[8]Base de calculo do ISS
	nVALISS		:= MaFisRet(,"NF_VALISS" )		//[9]Valor do ISS
	nBASEIRR	:= MaFisRet(,"NF_BASEIRR" )		//[10]Base do imposto de renda
	nVALIRR		:= MaFisRet(,"NF_VALIRR" )		//[11]Valor do IR
	nBASEINS	:= MaFisRet(,"NF_BASEINS" )		//[12]Base de calculo do INSS
	nVALINS		:= MaFisRet(,"NF_VALINS" )		//[13]Valor do INSS
	nBASECOF	:= MaFisRet(,"NF_BASECOF" )		//[14]Base de calculo do COFINS (RET)
	nVALCOF		:= MaFisRet(,"NF_VALCOF" )		//[15]Valor do COFINS (RET)
	nBASECSL	:= MaFisRet(,"NF_BASECSL" )		//[16]Base de calculo do CSLL (RET)
	nVALCSL		:= MaFisRet(,"NF_VALCSL" )		//[17]Valor do CSLL (RET)
	nBASEPIS	:= MaFisRet(,"NF_BASEPIS" )		//[18]Base de calculo do PIS (RET)
	nVALPIS		:= MaFisRet(,"NF_VALPIS" )		//[19]Valor do PIS (RET)
	nBASECF2	:= MaFisRet(,"NF_BASECF2" )		//[20]Base de calculo do COFINS (APUR)
	nVALCF2		:= MaFisRet(,"NF_VALCF2" )		//[21]Valor do COFINS (APUR)
	nBASEPS2	:= MaFisRet(,"NF_BASEPS2" )		//[22]Base de calculo do PIS (APUR)
	nVALPS2		:= MaFisRet(,"NF_VALPS2" )		//[23]Valor do PIS (APUR)
	
	// Encerra a funcao fiscal
	MaFisEnd()
	RestArea(aArea)
	 
	aRet := {	{"NF_BASEICM",nBASEICM},{"NF_VALICM",nVALICM},{"NF_BASESOL",nBASESOL},{"NF_VALSOL",nVALSOL},{"NF_VALCMP",nVALCMP},{"NF_BASEIPI",nBASEIPI},{"NF_VALIPI",nVALIPI},;
				{"NF_BASEISS",nBASEISS},{"NF_VALISS",nVALISS},{"NF_BASEIRR",nBASEIRR},{"NF_VALIRR",nVALIRR},{"NF_BASEINS",nBASEINS},{"NF_VALINS",nVALINS},{"NF_BASECOF",nBASECOF},;
				{"NF_VALCOF",nVALCOF},{"NF_BASECSL",nBASECSL},{"NF_VALCSL",nVALCSL},{"NF_BASEPIS",nBASEPIS},{"NF_VALPIS",nVALPIS},{"NF_BASECF2",nBASECF2},{"NF_VALCF2",nVALCF2},;
				{"NF_BASEPS2",nBASEPS2},{"NF_VALPS2",nVALPS2}}
			
Else //ITENS
	//A função MaFisIni() é responsável por iniciar todo o processo da MATXFIS
	MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,If(SC5->C5_TIPO$'DB',"F","C"),SC5->C5_TIPO,;
		SC5->C5_TIPOCLI,,,.F.,"SB1",,,,,,,,,,,,SC5->C5_NUM ,SC5->C5_CLIENTE,SC5->C5_LOJACLI)
	
	While SC6->(!EOF()) .AND. ALLTRIM(SC6->C6_NUM) == ALLTRIM(cPedido)
		//MaFisAdd() Inclui um novo item no array aNFItem da MATXFIS
		MaFisAdd(SC6->C6_PRODUTO, SC6->C6_TES, SC6->C6_QTDVEN,SC6->C6_PRCVEN, SC6->C6_DESCONT, "", "",, 0, 0, 0, 0, SC6->C6_VALOR, 0 )
		
		//MaFisRet() Retorna os valores de impostos
		cPRODUTO	:= MaFisRet(1,"IT_PRODUTO" ) 	 //[1]Código do produto
		
		nBASEICM	:= MaFisRet(1,"IT_BASEICM" ) 	 //[2]Valor base de ICMS
		nALIQICM	:= MaFisRet(1,"IT_ALIQICM" )     //[3]Aliquota de ICMS
		nVALICM		:= MaFisRet(1,"IT_VALICM" )      //[4]Valor do ICMS normal
		nBASESOL	:= MaFisRet(1,"IT_BASESOL" )     //[5]Base ICMS solidario
		nALIQSOL	:= MaFisRet(1,"IT_ALIQSOL" )     //[6]Aliquota ICMS solidario
		nVALSOL		:= MaFisRet(1,"IT_VALSOL" )      //[7]Valor ICMS solidario
		nALIQCMP	:= MaFisRet(1,"IT_ALIQCMP" )     //[8]Aliquota ICMS complementar
		nVALCMP		:= MaFisRet(1,"IT_VALCMP" )      //[9]Valor ICMS complementar
		nBASEIPI	:= MaFisRet(1,"IT_BASEIPI" )     //[10]Valor base do IPI
		nALIQIPI	:= MaFisRet(1,"IT_ALIQIPI" )     //[11]Aliquota base do IPI
		nVALIPI		:= MaFisRet(1,"IT_VALIPI" )      //[12]Valor do IPI
		nBASEISS	:= MaFisRet(1,"IT_BASEISS" )	 //[13]Base de calculo do ISS
		nALIQISS	:= MaFisRet(1,"IT_ALIQISS" )     //[14]Aliquota do ISS
		nVALISS		:= MaFisRet(1,"IT_VALISS" )		 //[15]Valor do ISS
		nBASEIRR	:= MaFisRet(1,"IT_BASEIRR" )	 //[16]Base do imposto de renda
		nALIQIRR	:= MaFisRet(1,"IT_ALIQIRR" )     //[17]Aliquota do IR
		nVALIRR		:= MaFisRet(1,"IT_VALIRR" )		 //[18]Valor do IR
		nBASEINS	:= MaFisRet(1,"IT_BASEINS" )	 //[19]Base de calculo do INSS
		nALIQINS	:= MaFisRet(1,"IT_ALIQINS" )     //[20]Aliquota do INSS
		nVALINS		:= MaFisRet(1,"IT_VALINS" )	     //[21]Valor do INSS
		nBASECOF	:= MaFisRet(1,"IT_BASECOF" )	 //[22]Base de calculo do COFINS (RET)
		nALIQCOF	:= MaFisRet(1,"IT_ALIQCOF" )     //[23]Aliquota do COFINS (RET)
		nVALCOF		:= MaFisRet(1,"IT_VALCOF" )		 //[24]Valor do COFINS (RET)
		nBASECSL	:= MaFisRet(1,"IT_BASECSL" )	 //[25]Base de calculo do CSLL (RET)
		nALIQCSL	:= MaFisRet(1,"IT_ALIQCSL" )     //[26]Aliquota do CSLL (RET)
		nVALCSL		:= MaFisRet(1,"IT_VALCSL" )		 //[27]Valor do CSLL (RET)
		nBASEPIS	:= MaFisRet(1,"IT_BASEPIS" )	 //[28]Base de calculo do PIS (RET)
		nALIQPIS	:= MaFisRet(1,"IT_ALIQPIS" )     //[29]Aliquota do PIS (RET)
		nVALPIS		:= MaFisRet(1,"IT_VALPIS" )		 //[30]Valor do PIS (RET)
		nBASECF2	:= MaFisRet(1,"IT_BASECF2" )	 //[31]Base de calculo do COFINS (APUR)
		nALIQCF2	:= MaFisRet(1,"IT_ALIQCF2" )     //[32]Aliquota do COFINS (APUR)
		nVALCF2		:= MaFisRet(1,"IT_VALCF2" )		 //[33]Valor do COFINS (APUR)
		nBASEPS2	:= MaFisRet(1,"IT_BASEPS2" )	 //[34]Base de calculo do PIS (APUR)
		nALIQPS2	:= MaFisRet(1,"IT_ALIQPS2" )     //[35]Aliquota do PIS (APUR)
		nVALPS2		:= MaFisRet(1,"IT_VALPS2" )		 //[36]Valor do PIS (APUR)
				
		aAdd(aRet,{{"IT_PRODUTO",cPRODUTO},{"IT_BASEICM",nBASEICM},{"IT_ALIQICM",nALIQICM},{"IT_VALICM",nVALICM},{"IT_BASESOL",nBASESOL},{"IT_ALIQSOL",nALIQSOL},{"IT_VALSOL",nVALSOL},;
					{"IT_ALIQCMP",nALIQCMP},{"IT_VALCMP",nVALCMP},{"IT_BASEIPI",nBASEIPI},{"IT_ALIQIPI",nALIQIPI},{"IT_VALIPI",nVALIPI},{"IT_BASEISS",nBASEISS},{"IT_ALIQISS",nALIQISS},{"IT_VALISS",nVALISS},;
					{"IT_BASEIRR",nBASEIRR},{"IT_ALIQIRR",nALIQIRR},{"IT_VALIRR",nVALIRR},{"IT_BASEINS",nBASEINS},{"IT_ALIQINS",nALIQINS},{"IT_VALINS",nVALINS},;
					{"IT_BASECOF",nBASECOF},{"IT_ALIQCOF",nALIQCOF},{"IT_VALCOF",nVALCOF},{"IT_BASECSL",nBASECSL},{"IT_ALIQCSL",nALIQCSL},{"IT_VALCSL",nVALCSL},;
					{"IT_BASEPIS",nBASEPIS},{"IT_ALIQPIS",nALIQPIS},{"IT_VALPIS",nVALPIS},{"IT_BASECF2",nBASECF2},{"IT_ALIQCF2",nALIQCF2},{"IT_VALCF2",nVALCF2},;
					{"IT_BASEPS2",nBASEPS2},{"IT_ALIQPS2",nALIQPS2},{"IT_VALPS2",nVALPS2}})
		
		//Limpa array de intens do MATXFIS, assim não acumulando os valores quando pedido tiver mais de um item e sempre terei um item 
		MaFisClear()
		SC6->(DbSkip())   
	EndDo    

	// Encerra a funcao fiscal
	MaFisEnd()
	RestArea(aArea)
EndIf

Return(aRet)