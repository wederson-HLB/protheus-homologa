#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GSXMTSZ7  � Autor � AP6 IDE            � Data �  16/04/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 

/*
Funcao      : GSXMTSZ7
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Axcadastro SZ7 - CADASTRO PROJECOES
Autor     	:                                
Data     	: 16/04/04                     
Obs         :  
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Generico. 
Cliente     : Shiseido
*/

*-----------------------*
 User Function GSXMTSZ7
*-----------------------*

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

Private cString := "SZ7"

dbSelectArea("SZ7")
dbSetOrder(1)

AxCadastro(cString," CADASTRO PROJECOES ",cVldAlt,cVldExc)

Return
