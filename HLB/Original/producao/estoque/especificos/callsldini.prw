/*
Funcao      : CALLSLDINI 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Chamada da rotina mata220 para n�o permitir rodar quem tem custo fifo (ex. Monavie) 
Autor       : Adriane Sayuri Kamiya
Data/Hora   : 25/08/08     
Obs         : Tratamento para custo FIFO.
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/02/2012
Obs         : Empresas do grupo GT foram tiradas do fonte assim como os n�o clientes - F2/Creata, etc.
M�dulo      : Estoque.
Cliente     : Todos
*/
   
*----------------------------*
 User Function CallSldIni()
*----------------------------*

DbSelectArea("SX6")
SX6->(DbSetOrder(1))
SX6->(DbSeek(xFilial("SX6")+"MV_CUSFIFO"))

If GetMV("MV_CUSFIFO")
   MsgStop("Esta rotina n�o poder� ser usada pois trabalha com Custo FIFO!","MV_CUSFIFO")
Else
   IF FindFunction("MATA220")
      MATA220()
   EndIF
Endif   

Return(Nil)