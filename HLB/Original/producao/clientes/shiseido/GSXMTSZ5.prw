#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GSXMTSZ4  � Autor � AP6 IDE            � Data �  20/10/03   ���
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
Funcao      : GSXMTSZ4
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Axcadastro SZ5 - Cadastro Forecast
Autor     	:                                
Data     	: 20/10/03                     
Obs         :  
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Generico. 
Cliente     : Shiseido
*/

*-----------------------*
 User Function GSXMTSZ5
*-----------------------*

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

if !u_versm0("R7/FA/CZ")    // VERIFICA EMPRESA
   return
endif

Private cString := "SZ5"

dbSelectArea("SZ5")
dbSetOrder(1)

AxCadastro(cString," Cadastro Forecast ",cVldAlt,cVldExc)

Return
