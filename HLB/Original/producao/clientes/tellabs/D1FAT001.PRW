
/*
Funcao      : D1FAT001
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Mensagem para informar ao usu�rio quantidade liberada anteriormente.
Autor     	: Wederson Lourenco Santana
Data     	: 10/06/05   
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/03/2012
M�dulo      : Faturamento
Cliente     : Tellabs
*/
  
*------------------------*
 User Function D1FAT001()
*------------------------*

	MsgInfo("Quantidade a ser liberada "+Transform(SC6->C6_QTDEMP,"@E 999,999,999")+".","T E L L A B S")

Return(.T.)