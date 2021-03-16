
/*
Funcao      : EICDI154 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. mensagem de aviso de lote e grava��o de peso 
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 25/04/2011     
Obs         : 
TDN         : Disponibilizado no programa EICDI154.PRW, o ponto de entrada EICDI154 com par�metro "GRAVACAO_SF1" para que seja poss�vel incluir novos campos no envio para o Compras.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/02/2012
Obs         : 
M�dulo      : Importa��o.
Cliente     : Todos
*/

*--------------------------*
  User Function EICDI154()
*--------------------------*
 
Local aOrd:= SaveOrd({"SW7","SWV","SF1","SB1"})
                     
//Mensagem de lote - Especifico Promega                         
If PARAMIXB == "NFE_INICIO"
	If cEmpAnt $ ("IS/IJ")
		SW7->(DbSetOrder(1)) 
		If SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB)) 
			SWV->(DbSetOrder(1))   
			If !(SWV->(DbSeek(xFilial("SWV")+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I))) 
				MsgAlert("Esse processo n�o possui lote, n�o gerar a nota antes de atualizar o lote. ","Promega")	
			EndIf    	  		
   		EndIf	 
    EndIf
EndIf         
                                                
//Tratamento de peso bruto - Todas empresas
If PARAMIXB == "GRV_SF1"
	If SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
		SB1->(DbSetOrder(1))    
		If SB1->(DbSeek(xFilial("SB1")+SW7->W7_COD_I))
			If Empty(SB1->B1_PESBRU) // Tratamento do padr�o
				If !Empty(nNfe)           
    				SF1->(DbSetOrder(1))    
    				If SF1->(DbSeek(xFilial("SF1")+nNfe+nSerie))
    					RecLock("SF1",.F.)
    					SF1->F1_PBRUTO:=SW6->W6_PESO_BR
    		    		SF1->(MsUnlock()) 
    		    	EndIf
    			EndIf    		
    		EndIf	
    	EndIf	 
    EndIf
EndIf
  
RestOrd(aOrd,.T.)

Return   


