/*
Funcao      : PEDEST01
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Não permite que o usuário informe o almoxarifado fora da máscara. 99    
Autor     	: Wederson
Data     	: 09/02/2007 
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Estoque
Cliente     : Okuma
*/ 

*------------------------*
 User Function PEDEST01()
*------------------------*  

 	M->B1_LOCPAD := StrZero(Val(M->B1_LOCPAD),2)

Return .T.