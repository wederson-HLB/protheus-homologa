#Include 'Protheus.Ch'

/*
Funcao      : M460NUM 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada na Preparação Documento Saida ( Controle de Numeracao da Nota ) 
Autor       : Leandro Diniz de Brito ( BRL Consulting )
Data/Hora   : 13/03/2015   
Obs         : 
TDN         : O ponto de entrada é executado após a seleção da série na rotina de documento de saída.Seu objetivo é permitir a troca da série e do número do documento através de customização local.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 16/03/2015 
Obs         : 
Módulo      : Faturamento.
Cliente     : Todos.
*/

*--------------------------------*
User Function M460NUM
*--------------------------------*

/*
	**	A variavel cGtNumNf está declarada no fonte GTJOB002.Prw , serve para controlar a numeracao das notas 
	   de prestação de serviços onde o numero da mesma vem do arquivo.
*/   

If Type( 'cGtNumNF' ) <> 'U' 
	cNumero := cGtNumNf
EndIf

Return
