/*
Funcao      : CALLSLDINI 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Chamada da rotina mata220 para não permitir rodar quem tem custo fifo (ex. Monavie) 
Autor       : Adriane Sayuri Kamiya
Data/Hora   : 25/08/08     
Obs         : Tratamento para custo FIFO.
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : Empresas do grupo GT foram tiradas do fonte assim como os não clientes - F2/Creata, etc.
Módulo      : Estoque.
Cliente     : Todos
*/
   
*----------------------------*
 User Function CallSldIni()
*----------------------------*

DbSelectArea("SX6")
SX6->(DbSetOrder(1))
SX6->(DbSeek(xFilial("SX6")+"MV_CUSFIFO"))

If GetMV("MV_CUSFIFO")
   MsgStop("Esta rotina não poderá ser usada pois trabalha com Custo FIFO!","MV_CUSFIFO")
Else
   IF FindFunction("MATA220")
      MATA220()
   EndIF
Endif   

Return(Nil)