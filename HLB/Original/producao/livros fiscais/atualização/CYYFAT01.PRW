#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 22/11/01
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �          � Autor �                       � Data �22/11/01   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � 															  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*

/*
Funcao      : CYYFAT01 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Vinculo de TES x Empresas  
Autor       : 
Data/Hora   : 22/11/01 
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 18/07/2012
Obs         :
M�dulo      : Livros Fiscais.
Cliente     : Todas	
*/
     
*-------------------------*
 User Function CYYFAT01()
*-------------------------* 

PRIVATE aRotina := { { "Pesquisar" ,	"AxPesqui"  , 0 , 1},;	
                     { "Visualizar",	"AxVisual"  , 0 , 2},;		
                     { "Empresas"  ,    "U_CYYFATY1", 0 , 5, 16} }	

PRIVATE cCadastro := OemtoAnsi("Atualiza��o de TES")		

mBrowse( 6, 1,22,75,"SF4")

Return

*------------------------*                      
 User FUNCTION  CYYFATY1
*------------------------* 
  
_cTES:= SF4->F4_CODIGO
_aRotBkp:=aRotina 

u_CYYFAT02(_cTES)
             
aRotina:=_aRotBkp

RETURN