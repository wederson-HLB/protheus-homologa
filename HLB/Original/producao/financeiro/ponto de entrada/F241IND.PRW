#Include "rwmake.ch"    

/*
Funcao      : F241IND
Parametros  : 
Retorno     : aIndTemp
Objetivos   : Ponto de entrada tem como principal finalidade permitir ao usuario fazer alteração do indice para apresentação dos titulos 
			  para a geração do borderô de impostos.
TDN         : http://tdn.totvs.com/pages/releaseview.action?pageId=6071623
Autor       : Anderson Arrais
Data/Hora   : 31/10/2016
Módulo      : Financeiro.
*/                      

*----------------------*
 User Function F241IND()   
*----------------------*   
Local aIndTemp      

If cEmpAnt $ "V5/FA/FC"
	SE2->(DbOrderNickName("ORDEMBORD ")) //Indice criado para atender a Vogel (E2_FILIAL + E2_VALOR + E2_FORNECE)
	
//	aIndTemp := {CriaTrab(,.F.)}
//	IndRegua(cAliasSE2,aIndTemp[1],SE2->(IndexKey()),,,"")
	                                                             
EndIf

//AOA - 12/12/2017 - atender a customização de condição de pagamento ID 42	
If cEmpAnt $ "HH/HJ"
	SE2->(DbOrderNickName("ORDEMBORD ")) //Indice criado para atender a Vogel (E2_FILIAL + E2_NOMFOR + E2_VALOR)

//	aIndTemp := {CriaTrab(,.F.)}
//	IndRegua(cAliasSE2,aIndTemp[1],SE2->(IndexKey()),,,,.F.)
	                                                             
EndIf

Return aIndTemp