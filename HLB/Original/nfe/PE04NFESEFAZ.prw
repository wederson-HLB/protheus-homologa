#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE04NFESEFAZ �Autor �Tiago Luiz Mendon�a�  Data �  07/06/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada do fonte NfeSefaz, responsavel pela        ���
���          �transmiss�o de Notas Fiscais Eletronicas.                   ���
�������������������������������������������������������������������������͹��
���Uso       � HLB BRASIL                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/         

/*
Funcao      : PE04NFESEFAZ 
Parametros  : {cNota,cSerie,cClieFor,cLoja}
Retorno     : lRet
Objetivos   : P.E. para interromper o 
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 07/06/2013       	
Obs         : 
TDN         : 
Revis�o     : 
Data/Hora   : 
Obs         : 
M�dulo      : Faturamento.
Cliente     : Ducati
*/

*--------------------------*
User Function PE04NFESEFAZ()
*--------------------------*

Local cTipo       := ParamIXB[01] 
Local cNota	      := ParamIXB[02]
Local cSerie      := ParamIXB[03]
Local cClieFor    := ParamIXB[04] 
Local cLoja       := ParamIXB[05] 
   
Local lRet        := .F.

Local aArea1      := {}
Local aArea2      := {}
Local aArea3      := {}
Local aArea4      := {}

If cEmpAnt $ "PF/5K"  

	aArea1 := CD9->(GetArea())     
	aArea2 := SD2->(GetArea())     
	aArea3 := SF4->(GetArea())   
	aArea4 := SD1->(GetArea())   


	If 	cTipo == "1"  //SAIDA  

		SD2->(DbSetOrder(3)) 
		If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+cClieFor+cLoja))    
		
			SF4->(DbSetOrder(1))	
			If SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
			    
			 	If SF4->F4_ESTOQUE $ "S"
			  
					CD9->(DbSetOrder(1)) 
					//CD9_FILIAL, CD9_TPMOV, CD9_SERIE, CD9_DOC, CD9_CLIFOR, CD9_LOJA, CD9_ITEM, CD9_COD
					If CD9->(DbSeek(xFilial("CD9")+"S"+cSerie+cNota+cClieFor+cLoja))
				    	lRet:=.F.
				    Else
				    	If !(MsgYesNo("Essa nota n�o possui informa��es do ve��ulo, como por exemplo chassi, deseja continuar assim mesmo ?","HLB BRASIL"))	
				    		lRet:=.T.
				    	EndIf	
				   	EndIf 	
		        
		        EndIf
		        
	 		EndIf
    
       	EndIf
	
	Else       
		
		SD1->(DbSetOrder(1)) 
		If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+cClieFor+cLoja))    
		
			SF4->(DbSetOrder(1))	
			If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
			    
			 	If SF4->F4_ESTOQUE $ "S"
			  
					CD9->(DbSetOrder(1)) 
  					//CD9_FILIAL, CD9_TPMOV, CD9_SERIE, CD9_DOC, CD9_CLIFOR, CD9_LOJA, CD9_ITEM, CD9_COD
					If CD9->(DbSeek(xFilial("CD9")+"E"+cSerie+cNota+cClieFor+cLoja))			
	  				  	lRet:=.F.
	 				Else
	    				If !(MsgYesNo("Essa nota n�o possui informa��es do ve��ulo, como por exemplo chassi, deseja continuar assim mesmo ?","HLB BRASIL"))	
	    	   				lRet:=.T.
	    				EndIf	
	   				EndIf
	    	
	    		EndIf
	    		
	    	EndIf
 		
 		EndIf
 	
 	EndIf

	RestArea(aArea1)
	RestArea(aArea2)	
	RestArea(aArea3)
	RestArea(aArea4)

EndIf  


Return lRet
