#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DVCNABITAU � Autor � Microsiga        � Data �  24/11/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Verifica a existencia do campo A6_DVCC (customizado)       ���
���          � Retorna o digito verificador do Banco Itau                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DVCNABITAU()
_Ret := " "
_Area := GetArea()

If Type("SA6->A6_DVCC")<>"U"
	If !empty(SA6->A6_DVCC)
		_Ret := Substr(SA6->A6_DVCC,1,1)
	Else
		If Len(alltrim(SA6->A6_NUMCON)) > 5
			_Ret := right(alltrim(SA6->A6_NUMCON),1)
		Endif
	Endif
Else
	_Ret := right(alltrim(SA6->A6_NUMCON),1)
Endif

RestArea(_Area)
Return(_Ret)
