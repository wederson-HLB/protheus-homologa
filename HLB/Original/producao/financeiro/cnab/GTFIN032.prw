#Include "rwmake.ch"    

/*
Funcao      : GTFIN032
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Trata c�digo de transmiss�o para cobran�a Santander.
Autor       : 
TDN         : 
OBS			: Layout Santander de 400 posi��es contas a receber	
Revis�o     : Anderson Arrais
Data/Hora   : 02/06/2017
M�dulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN032(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      

//����������������������������������������������������Ŀ
//�C�digo de transmiss�o					   						   �
//������������������������������������������������������
If nOpc == 1
    cRet := cValToChar(&(SuperGetMv("MV_P_00103"))[1])
Endif

RestArea(aArea)
Return(cRet)