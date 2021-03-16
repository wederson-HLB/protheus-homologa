#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

User Function Lp56201d()        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02           

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

_rec    := recno()
_cAlias := Alias()
_Index  := Indexord()
_cHist := " "       
_cHist2:= " "

_cDebito := " "
// Posiciona SED  p/leitura
DbSelectArea("SED")
dbSetOrder(1)
DbSeek(xfilial()+SE5->E5_NATUREZ)

//TLM 20140228 -  Chamado 017474 
If cEmpAnt $ "LW/LX/LY"    
	If Alltrim(SE5->E5_NATUREZ)=="3705" 
		_CDEBITO:="21118004"
	Else 
		If !Eof()
    		_CDEBITO:=SED->ED_CONTA
    	EndIf
	EndIf
Else	
	If !Eof()
    	_CDEBITO:=SED->ED_CONTA
    EndIf	
EndIf

// Volta a posicao anterior
DbSelectArea(_cAlias)
DbSetOrder(_Index)
DbGoto(_rec)
// Substituido pelo assistente de conversao do AP5 IDE em 02/07/02 ==> __return(_cDebito)
Return(_cDebito)        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

