#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

User Function Lp5101d()        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_REC,_CALIAS,_INDEX,_CHIST,_CHIST2,_CDEBITO")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LP5620D  � Autor � Claudio S.Oliveira    � Data � 02/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Objetivo  � Posicionar o Nr. da conta d�bito no SED  - Arq.Natureza    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � no Lan�amento Padronizado nr. 562 - Movimenta��o Banc�ria  ���
��� Uso      �                                     a Pagar                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/    

//JSS 19/11/2014 -  Alterado para solucionar caso 022701
//Inicio-
If cEmpAnt $ "40" 
	If AllTrim(FUNNAME())$ "FINA370"  
		_cDebito:= '21101001'
		Return(_cDebito) 
	EndIf
EndIf		
//Fim
_rec    := recno()
_cAlias := Alias()
_Index  := Indexord()
_cHist := " "       
_cHist2:= " "

_cDebito := " "
// Posiciona SED  p/leitura
DbSelectArea("SED")
dbSetOrder(1)
DbSeek(xfilial()+SE2->E2_NATUREZ)
If !Eof()
    _CDEBITO:=SED->ED_CONTA
    
EndIf

// Volta a posicao anterior
DbSelectArea(_cAlias)
DbSetOrder(_Index)
DbGoto(_rec)
// Substituido pelo assistente de conversao do AP5
// IDE em 02/07/02 ==> __return(_cDebito)
Return(_cDebito)        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

