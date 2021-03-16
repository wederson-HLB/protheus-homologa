#INCLUDE "rwmake.ch"

/*
Funcao      : CADS9ZZ1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de Aeroporto  
Autor     	: Adriane Sayuri Kamiya
Data     	: 15/04/2009 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*-----------------------*
 User Function CADS9ZZ3
*-----------------------*

private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

IF !SM0->M0_CODIGO $ "S8/S9/"   // VERIFICA EMPRESA
   return
endif

Private cString := "ZZ3"

dbSelectArea("ZZ3")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Aeroporto",cVldAlt,cVldExc)

Return
