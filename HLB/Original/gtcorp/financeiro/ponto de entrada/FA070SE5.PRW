#include "Protheus.ch"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
 ���Programa  �FA070SE5  �Autor  �Gestao Dinamica     � Data �  01/31/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para alimentar o historico da baixa       ���
 ���          � Numero da Fatura + Razao Social                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
 �������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
 */


/*
Funcao      : FA070SE5 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de Entrada para alimentar o historico da baixa numero da Fatura + Razao Social
Autor       : Gestao Dinamica
Data/Hora   : 01/31/12 
TDN         : N�o disponivel
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/02/12 
M�dulo      : Financeiro.
*/

*------------------------*
  User Function FA070SE5
*------------------------*

Local aArea := GetArea()
Local cHistor

DbselectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA)
cHistor :="Cliente: "+SA1->A1_NOME+" Fatura n� "+SE5->E5_NUMERO
 
If Alltrim(SE5->E5_RECPAG)='R'
 
	RecLock("SE5",.F.)
	Replace E5_HISTOR With cHistor     

	MsUnlock()
EndIf

RestArea(aArea) 
Return (cHistor)
