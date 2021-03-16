/*
Funcao      : IBGEMUN
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de Municipios no IBGE - uso SPED   
Autor     	: Adriane Sayuri Kamiya
Data     	: 23/01/2009
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 13/03/2012
M�dulo      : Faturamento.
*/
     
*-------------------------*
  User Function IBGEMUN()
*-------------------------*

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.



Private cString := "CC2"

dbSelectArea("CC2")
dbSetOrder(1)

AxCadastro(cString," CADASTRO IBGE ",cVldAlt,cVldExc)

Return