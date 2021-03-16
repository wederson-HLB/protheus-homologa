/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUNCAO    � F470ALLF  �Autor  � Thomas Moraes	                      ���
�������������������������������������������������������������������������Ĵ��
���DESCRICAO � Este ponto de entrada permite a sinaliza��o de que deve ser
 feito o  tratamento do extrato utilizando o filtro da filial corrente.
 A rotina de Extrato Bancario disp�e de tratamentos para que a filial do
 SE5 n�o seja filtrada caso quando 'SA6 exclusivo' e 'SE5 compartilhado'.
 Esse controle � feito garantir a integridade do Extrato Banc�rio.No
 entanto,  o cliente pode utilizar suas tabelas nessa configura��o e 
 ainda assim ter somente 1 filial ou todos os movimentos banc�rios na 
 mesma filial. Para tal, foi disponibilizado um Ponto de Entrada para 
 que possa ser sinalizado que quer o tratamento do extrato utilizando 
 o filtro da filial corrente.
 
 O PE � chamado antes de montar as querys da rotina FINR470.
Eventos    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#include "rwmake.ch"
#include "protheus.ch"

User Function F470ALLF
Local lAllFil := ParamIxb[1]

Return .T.