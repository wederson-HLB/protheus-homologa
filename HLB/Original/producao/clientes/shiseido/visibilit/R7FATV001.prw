#include "rwmake.ch"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa R7FATV001 � Autor � Tiago Luiz Mendon�a   � Data �  12/10/11   ���
�������������������������������������������������������������������������͹��
���Descricao � AXCADASTRO TABELA DE LINHA                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 

/*
Funcao      : R7FATV001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Axcadastro ZX1  - Tabela de linha de produtos
Autor     	: Tiago Luiz Mendon�a                             
Data     	: 12/10/11                     
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Generico
Cliente     : Shiseido
*/

*------------------------*
User Function R7FATV001()
*------------------------*
                            
If cEmpAnt $ "R7"
	Axcadastro("ZX1","Linha de Produto")
Else
    MsgInfo("Especifico Shiseido ","A T E N C A O")  
Endif   
                       


Return