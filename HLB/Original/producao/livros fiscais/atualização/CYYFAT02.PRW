#include "rwmake.ch"        

/*
Funcao      : CYYFAT02 
Parametros  : _cTES
Retorno     : Nenhum
Objetivos   : Vinculo de TES x Empresas  
Autor       : 
Data/Hora   : 22/11/01 
Obs         : mBrowse da tabela SZ2
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 18/07/2012
Obs         :
M�dulo      : Livros Fiscais.
Cliente     : Todas	
*/
  
*------------------------------*    
 User Function CYYFAT02(_cTES)       
*------------------------------*  

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_CALIAS,_NORDER,_AROTANT,AROTINA,ASTRU,_CARQTRB")
SetPrvt("CCADASTRO,_NRECNOS,CMARCA,_CARQSX3,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� ExecBlock�   � Autor �   � Data �  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�          ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  �                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

//������������������������������������������������������Ŀ
//� Salvando Integridade do Sistema.                     �
//��������������������������������������������������������
_cArea:=GetArea()

//������������������������������������������������������Ŀ
//� Criando Opcoes do Menu.                              �
//��������������������������������������������������������
                  
Private aRotina :={}           
Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
					 {"Manutencao","U_CYYFAT03",0,3}}
//             {"Relatorio","U_RYYFAT02",0,5} }
//             {"Visualizar","AxVisual",0,2} ,;
//             {"Incluir","AxInclui",0,3} ,;
//             {"Excluir","AxDeleta",0,5} }
            
//hfpok            
dbSelectArea("SZ2")
dbGoTop()

cFiltro := "Z2_TES = '" + _cTes + "'"

mBrowse( 6,1,22,75,"SZ2",,,,,,,,,,,,,,cFiltro)

dbSelectArea("SZ2")

restarea(_cArea)   

Return

