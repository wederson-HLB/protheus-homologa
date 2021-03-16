#INCLUDE "PROTHEUS.CH"

/*
Funcao      : 49COM001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Programa chamado na aprovação do compras para visualizar arquivos anexos aos pedidos.
Autor       : Renato Rezende
Data/Hora   : 26/05/17     
Obs         : 
Módulo      : Compras.
Cliente     : Discovery
*/
*-------------------------------*
 User Function 49COM001()
*-------------------------------*
Local aAreaSC7	:= SC7->(GetArea())

//RRP - 21/11/2017 - Ajuste para posicionar no Pedido correto.
SC7->(DbSeek(xFilial("SC7")+Alltrim(SCR->CR_NUM)+Space(TamSx3("C7_NUM")[01]-Len(Alltrim(SCR->CR_NUM)))))

MsDocument("SC7", SC7->(RECNO()), 2)

RestArea(aAreaSC7)

Return nil
