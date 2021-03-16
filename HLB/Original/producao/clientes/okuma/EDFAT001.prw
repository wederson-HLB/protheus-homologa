#include "TOTVS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDFAT001  ºAutor  Tiago Luiz Mendonça  º Data ³  21/18/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as NCMs com base de redução                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : EDFAT001
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Valida as NCMs com base de redução.
Autor     	: Tiago Luiz Mendonça
Data     	: 28/11/2011 
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Faturamento
Cliente     : Okuma
*/
             
*------------------------*
 User Function EDFAT001()
*------------------------*

Local nPos1   := 0 

Local lRet    := .T.

Local aArea   := SF4->(GetArea())             
  
nPos1  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_P_NCM' }) 

If Inclui  
	 
	If Alltrim(aCols[n][nPos1]) $ "84669320/84669330/84834090/84663000/84195021"   
	
		If !Empty(M->C6_TES)	
			SF4->(DbSetOrder(1)) 
			If SF4->(DbSeek(xFilial("SF4")+M->C6_TES))	
				If SF4->F4_BASEICM == 0
					MsgSTOP("ATENCAO: TES informada não possui redução, corrigir.","Okuma")					
				EndIf
			EndIf	
	    EndIf
	        
	EndIf    
	
Else  
       	
	If aCols[n][nPos1] $ "84669320/84669330/84834090/84663000/84195021"   
	
		If !Empty(M->C6_TES)	
			SF4->(DbSetOrder(1)) 
			If SF4->(DbSeek(xFilial("SF4")+M->C6_TES))	
				If SF4->F4_BASEICM == 0
					MsgInfo("ATENCAO: TES informada não possui redução, corrigir.","Okuma")					
				EndIf
			EndIf	
	    EndIf
	        
	EndIf  

EndIf               

RestArea(aArea)

Return lRet  