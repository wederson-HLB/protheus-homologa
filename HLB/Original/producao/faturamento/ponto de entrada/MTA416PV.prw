
/*
Funcao      : MTA416PV 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetivação do pedido
Autor       : Wederson L. Santana
Data/Hora   : 09/05/05     
Obs         : 
TDN         : P.E. Executado apos o preenchimento do aCols na Baixa do Orcamento de Vendas.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : 
Módulo      : Faturamento.
Cliente     : Tellabs
*/

*-------------------------*
 User Function MTA416PV()
*-------------------------*

If cEmpAnt $ "D1"
   M->C5_P_PEDCL := SCJ->CJ_P_PEDCL
   M->C5_P_DTPCL := SCJ->CJ_P_DTPCL
   M->C5_P_OCORR := SCJ->CJ_P_OCORR
   M->C5_P_SITE  := SCJ->CJ_P_SITE
//RRP - 24/06/2014 - Empresa Victaulic
ElseIf cEmpAnt $ "TM"
	M->C5_P_PARC 	:= SCJ->CJ_P_PARC 
	M->C5_P_SALES	:= SCJ->CJ_P_SALES
	M->C5_P_ENDUS	:= SCJ->CJ_P_ENDUS
	M->C5_P_SPF		:= SCJ->CJ_P_SPF
	M->C5_VEND1		:= SCJ->CJ_P_VEND1	
Endif   

Return(Nil)