#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar o valor da Mercadoria.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 03/07/08
*/

User Function LP9506VAL()       

Local nResult:=0
Local cCfoP,cTes,cWFilial
     
//cTes := "1B6/1B7/1B8/1C1/1C2/1C3/1C4/1C5/1C6/1C7/1C8/1C9"             
cCfoP:= "3101/3102/3551/3949"

IF alltrim(SD1->D1_CF) $ (cCfoP) 
   SWN->(DbSetOrder(2))
   If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))  

	  //CAS - 08/02/2017, ajustado o filtro no while com a variável cFilial, devido a tabela SWN ser compartilhada e a SD1 ser exclusiva - chamado:036760   
      cWFilial := If(!empty(xFilial("SWN")),xFilial("SWN"),xFilial("SD1"))
      While SWN->(!EOF()) .And. cWFilial+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE
         nResult+=SWN->WN_FOB_R //+SWN->WN_FRETE+SWN->WN_SEGURO+SWN->WN_DESPICM
         SWN->(DbSkip())
      EndDo           
   EndIf
   	//RRP - 06/12/2013 - Ajuste quando for preenchido outras despesas na invoice. Chamado 015544. 
	SW9->(DbSetOrder(3))
	If SW9->(DbSeek(xFilial("SW9")+SD1->D1_CONHEC))
		If SW9->W9_OUTDESP <> 0
			nResult-=SW9->W9_OUTDESP*SW9->W9_TX_FOB
		EndIf		
	EndIf
EndIf


Return(nResult)

