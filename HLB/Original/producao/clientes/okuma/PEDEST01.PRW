/*
Funcao      : PEDEST01
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : N�o permite que o usu�rio informe o almoxarifado fora da m�scara. 99    
Autor     	: Wederson
Data     	: 09/02/2007 
Obs         : 
TDN         :
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 17/07/2012
M�dulo      : Estoque
Cliente     : Okuma
*/ 

*------------------------*
 User Function PEDEST01()
*------------------------*  

 	M->B1_LOCPAD := StrZero(Val(M->B1_LOCPAD),2)

Return .T.