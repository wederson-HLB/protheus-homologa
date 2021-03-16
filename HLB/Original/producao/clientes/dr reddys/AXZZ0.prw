
/*
Funcao      : ZZ0SPED
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de Plano de Contas Referencial - SPED / Browse para Cadastro
Autor     	: Adriane Sayuri Kamiya
Data     	: 
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Livros Fiscais.
*/



#Include "Rwmake.ch"

*-----------------------*
 User Function ZZ0SPED() 
*-----------------------*  
                                                    
DbSelectArea("ZZ0")                                                      
DbSetOrder(1)

AxCadastro("ZZ0","Pl de Contas Ref",".T.",".T.")
 
Return Nil