#include "topconn.ch"
#include "rwmake.ch"  


/*
Funcao      : GTCORP25 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Altera o paramtro MV_MOEDTIT pelo menu do usuário
Autor       : Tiago Luiz Mendonça
Data/Hora   : 07/02/2012     
Obs         : 
*/
   
*------------------------*
 USER FUNCTION GTCORP25()
*------------------------*   

Local aItens    := {"SIM","NAO"}
Local cCombo    := "NAO"  
Local cMoeTit   := GetMV("MV_MOEDTIT",,.F.)                  


	@ 150,10 to 420,580 Dialog JanelaNF Title "Defina a moeda do título para o financeiro"
     
	If cMoeTit == "S"
    	@ 012,010 SAY "Titulo será gerado na moeda do pedido " size 150,10
 	Else
   		@ 012,010 SAY "Titulo será gerado em reias" size 120,10
   	EndIf	 

   @ 052,010 SAY "Deseja alterar alterar o parametro  ?"
   @ 052,115 ComboBox cCombo  Items aItens  Size 50,50

   @ 112,230 BMPBUTTON TYPE 1 ACTION Close(JanelaNF)
   
   ACTIVATE DIALOG JanelaNF CENTERED
	
	If cCombo == "SIM" 
		SX6->(DbSetOrder(1))
		IF SX6->(DbSeek(xFilial("SX6")+"MV_MOEDTIT"))
			SX6->(RecLock("SX6",.F.)) 
			If cMoeTit == "S"	
				 SX6->X6_CONTEUD:="N"
		 	Else
		 		SX6->X6_CONTEUD:="S"
		 	EndIF 
		 	SX6->(MsUnlock())		        
		EndIf     

    EndIf 
    
 Return   