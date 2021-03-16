#include "TOTVS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDFAT001  �Autor  Tiago Luiz Mendon�a  � Data �  21/18/11    ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida as NCMs com base de redu��o                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � 			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
Funcao      : EDFAT001
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Valida as NCMs com base de redu��o.
Autor     	: Tiago Luiz Mendon�a
Data     	: 28/11/2011 
Obs         : 
TDN         :
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 17/07/2012
M�dulo      : Faturamento
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
					MsgSTOP("ATENCAO: TES informada n�o possui redu��o, corrigir.","Okuma")					
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
					MsgInfo("ATENCAO: TES informada n�o possui redu��o, corrigir.","Okuma")					
				EndIf
			EndIf	
	    EndIf
	        
	EndIf  

EndIf               

RestArea(aArea)

Return lRet  