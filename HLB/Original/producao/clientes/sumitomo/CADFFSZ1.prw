#INCLUDE "rwmake.ch"    

/*
Funcao      : CADFFSZ1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : AxCadastro da tabela SZ1 - Taxa selic
Autor     	: 	
Data     	:
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Financeiro.
*/

*-----------------------*
 User Function CADFFSZ1
*-----------------------*

private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

if !u_versm0("FF")    // VERIFICA EMPRESA
   return
endif

Private cString := "SZ1"

dbSelectArea("SZ1")
dbSetOrder(1)

AxCadastro("SZ1"," TAXA SELIC ",cVldAlt,cVldExc)

Return
