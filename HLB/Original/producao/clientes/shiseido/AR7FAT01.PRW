#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AR7FAT01  � Autor � HAMILTON           � Data �  19/02/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Manutencao arquivo SZ3 - grupos de clientes shiseido       ���
�������������������������������������������������������������������������͹��
���Uso       � especifico shiseido                                        ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/   

/*
Funcao      : AR7FAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Manutencao arquivo SZ3 - grupos de clientes shiseido
Autor     	: Hamilton
Data     	: 19/02/03                       '
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a
Data/Hora   : 17/07/2012
M�dulo      : Faturamento. 
Cliente     : Shiseido
*/

*----------------------*
 User Function AR7FAT01
*----------------------*

Private cString
Private cCadastro := "Cadastro de Grupo Clientes"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Incluir","AxInclui",0,3} ,;
             {"Alterar","AxAltera",0,4} ,;
             {"Excluir","AxDeleta",0,5} }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SZ3"

dbSelectArea("SZ3")
dbSetOrder(1)


dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return
