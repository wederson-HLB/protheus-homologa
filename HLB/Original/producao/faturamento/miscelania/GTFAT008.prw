#include "Protheus.ch"

/*
Funcao      : GTFAT008
Parametros  : nVlrTotItem,nQuant,nVlUnit
Retorno     : Array{nBasIPI,nAlqIPI,nValIPI,nBaseIcm,nAliqIcm,nValIcm,nValSol}
Objetivos   : Calcular impostos do orçamento
Autor     	: Renato Rezende
Data     	: 25/06/2014 
TDN         : 
Módulo      : Faturamento.
Empresa		: Todas
*/   
                                       
*-------------------------* 
 User Function GTFAT008(nVlrTotItem,nQuant,nVlUnit)
*-------------------------*  
Local aArea 		:= GetArea()
Local cTipoCli		:= ""
Local cTipoNF 		:= "N"
Local nBasIPI 		:= 0
Local nAlqIPI 		:= 0
Local nValIPI 		:= 0
Local nAliqIcm 		:= 0
Local nValIcm		:= 0
Local nBaseIcm 		:= 0
Local nValSol 		:= 0

Local nBaseCof  	:= 0
Local nAliqCof 		:= 0
Local nValCof		:= 0
Local nBasePis    	:= 0
Local nAliqPis 		:= 0
Local nValPis		:= 0
Local nAliqIss    	:= 0
Local nBaseIss    	:= 0
Local nValIss 		:= 0 
Local nBseSol	 	:= 0
Local nAliqSol 		:= 0    

Local nTotIpi	:= 0
Local nTotIcms	:= 0
Local nTotDesp	:= 0
Local nTotFrete	:= 0
Local nTotalNF	:= 0
Local nTotSeguro:= 0
Local aValIVA   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifico o tipo da nota para efetuar o calculo |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
If cTipoNF $ "DB" 
	cTipoCli := IIf( Empty( cTipoCli ), SA2->A2_TIPO, cTipoCli ) 
	
	// Inicializa a funcao fiscal para poder simular os valores dos impostos 
	MaFisIni(SA2->A2_COD,SA2->A2_LOJA,"F",cTipoNF,cTipoCli,,,.F.,"SB1") 
Else
	cTipoCli := IIf( Empty( cTipoCli ), SA1->A1_TIPO, cTipoCli )
	
	// Inicializa a funcao fiscal para poder simular os valores dos impostos
	MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", cTipoCli,,, .F., "SB1")
EndIf
 
//Como no caso do orçamento não se tem nada de impostos e nem referências cadastradas nos valids dos campos
//(como temos no pedido de compras e vendas), é necessário inicializar a função fiscal com o MaFisIni e
//utilizar o MaFisAdd com os valores dos itens de cada uma das linhas do aCols.
 
MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQuant,nVlUnit, 0, "", "",, 0, 0, 0, 0, nVlrTotItem, 0, SB1->(RecNo()))
 
// Calcula os valores do IPI
nBasIPI 	:= MaFisRet(1,'IT_BASEIPI') //[1]Base di calculo do IPI
nAlqIPI 	:= MaFisRet(1,'IT_ALIQIPI') //[2]Aliquota de calculo IPI
nValIPI 	:= MaFisRet(1,'IT_VALIPI')  //[3]Valor de IPI

nBaseIcm 	:= MaFisRet(1,"IT_BASEICM") //[4]Valor da Base de ICMS
nAliqIcm 	:= MaFisRet(1,"IT_ALIQICM") //[5]/Base di calculo do ICMS
nValIcm		:= MaFisRet(1,"IT_VALICM" ) //[6]Valor de ICMS

//JSS - Add os impostos restantes para utilizar em outros fontes.
nValSol 	:= MaFisRet(1,"IT_VALSOL" ) //[7]Valor de ST
nBaseCof    := MaFisRet(1,"IT_BASECF2") //[8]Base de Calculo do ISS
nAliqCof 	:= MaFisRet(1,"IT_ALIQCF2") //[9]Aliquota de calculo do COFINS
nValCof		:= MaFisRet(1,"IT_VALCF2")  //[10]Valor do COFINS

nBasePis    := MaFisRet(1,"IT_BASEPS2") //[11]Base de Calculo do ISS
nAliqPis 	:= MaFisRet(1,"IT_ALIQPS2") //[12]Aliquota de calculo do PIS
nValPis		:= MaFisRet(1,"IT_VALPS2")  //[13]Valor do PIS  

nAliqIss    := MaFisRet(1,"IT_ALIQISS") //[14]Aliquota de ISS do item
nBaseIss    := MaFisRet(1,"IT_BASEISS") //[15]Base de Calculo do ISS
nValIss 	:= MaFisRet(1,"IT_VALISS")  //[16]Valor do ISS do item    

nBseSol 	:= MaFisRet(1,"IT_BASESOL" ) //[17]Base do ICMS Solidario
nAliqSol 	:= MaFisRet(1,"IT_ALIQSOL" ) //[18]Aliquota do ICMS Solidario 

// Encerra a funcao fiscal
MaFisEnd()
 
RestArea(aArea)
 
Return ({nBasIPI,nAlqIPI,nValIPI,nBaseIcm,nAliqIcm,nValIcm,nValSol,nBaseCof,nAliqCof,nValCof,nBasePis,nAliqPis,nValPis,nAliqIss,nBaseIss,nValIss,nBseSol,nAliqSol })