#Include 'Protheus.Ch'

/*
Funcao      : M460NUM 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada na Prepara��o Documento Saida ( Controle de Numeracao da Nota ) 
Autor       : Leandro Diniz de Brito ( BRL Consulting )
Data/Hora   : 13/03/2015   
Obs         : 
TDN         : O ponto de entrada � executado ap�s a sele��o da s�rie na rotina de documento de sa�da.Seu objetivo � permitir a troca da s�rie e do n�mero do documento atrav�s de customiza��o local.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 16/03/2015 
Obs         : 
M�dulo      : Faturamento.
Cliente     : Todos.
*/

*--------------------------------*
User Function M460NUM
*--------------------------------*

/*
	**	A variavel cGtNumNf est� declarada no fonte GTJOB002.Prw , serve para controlar a numeracao das notas 
	   de presta��o de servi�os onde o numero da mesma vem do arquivo.
*/   

If Type( 'cGtNumNF' ) <> 'U' 
	cNumero := cGtNumNf
EndIf

Return
