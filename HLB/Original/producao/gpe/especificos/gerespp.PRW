
#include "topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �gerespp  �Autor  �Francisco Neto Data �  17/08/16           ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada no calculo de Folha de Pagamento para     ���
���          � geracao do ESPP                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico GT                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function gerespp()

local _cQuery 	:= ""
local _cSQL 	:= ""
local _cPref 	:= ""
                     
local _perespp 	:= 0
local nbasespp	:= 0
local bases	:= 0

If FlocaliaPd("754") > 0                                               
	_perespp := aPd[fLocaliaPd("754"),5]
else
	_perespp := 0
endif


   nbasespp	:=	0

//  aEval(aPD,{|X| SomaInc(X,1,@nbasespp, , , , , , ,aCodFol)}) 

	aEval(aPD,{|X| SomaInc(X,21,@nbasespp,21,"S" , , , , ,aCodFol)})

if _perespp > 0  .and. nbasespp > 0

	fGeraVerba("906",nbasespp, , , , , , , , ,.T.) 
	fGeraVerba("693",(nbasespp*_perespp/100), , , , , , , , ,.T.) 	

endif


return