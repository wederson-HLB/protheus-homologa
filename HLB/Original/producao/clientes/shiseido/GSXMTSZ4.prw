#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GSXMTSZ4  � Autor: Francisco F. S. Neto� Data �  20/10/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Sehiseido do Brasil.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  

/*
Funcao      : GSXMTSZ4
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Axcadastro SZ4 - Cadastro Global Master
Autor     	: Francisco F. S. Neto                               
Data     	: 20/10/03                     
Obs         :  
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Generico. 
Cliente     : Shiseido
*/

*----------------------*
 User Function GSXMTSZ4
*----------------------*

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

PRIVATE cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
PRIVATE cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
   
if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

Private cString := "SZ4"

dbSelectArea("SZ4")
dbSetOrder(1)

AxCadastro(cString," Cadastro Global Master ",cVldAlt,cVldExc)

Return


