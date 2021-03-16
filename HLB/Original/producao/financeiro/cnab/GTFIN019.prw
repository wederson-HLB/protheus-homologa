#Include "rwmake.ch"    

/*
Funcao      : GTFIN019
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento do endere�o para saber se leva o de cobran�a ou o principal
Autor		: Anderson Arrais
Data/Hora   : 19/08/2016
M�dulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN019(nOpc)   
*------------------------------*   
Local cRet := ""

//����������������������������������������������������Ŀ
//�Endere�o do cliente				 				   �
//������������������������������������������������������
If nOpc == 1 
	If EMPTY(SA1->A1_ENDCOB)
		cRet := SUBSTR(SA1->A1_END,1,40)
	Else
		cRet := SUBSTR(SA1->A1_ENDCOB,1,40)
	EndIf
Endif

//����������������������������������������������������Ŀ
//�Bairro do cliente								   �
//������������������������������������������������������
If nOpc == 2
	If EMPTY(SA1->A1_BAIRROC)
		cRet := SUBSTR(SA1->A1_BAIRRO,1,40)
	Else
		cRet := SUBSTR(SA1->A1_BAIRROC,1,40)
	EndIf                        
Endif

//����������������������������������������������������Ŀ
//�CEP do cliente								 	   �
//������������������������������������������������������
If nOpc == 3 
	If EMPTY(SA1->A1_CEPC)
		cRet := STRTRAN(SA1->A1_CEP,"-","")
	Else
		cRet := STRTRAN(SA1->A1_CEPC,"-","")
	EndIf   
Endif

//����������������������������������������������������Ŀ
//�Municipio do cliente							 	   �
//������������������������������������������������������
If nOpc == 4 
	If EMPTY(SA1->A1_MUNC)
		cRet := SUBSTR(SA1->A1_MUN,1,15)
	Else
		cRet := SUBSTR(SA1->A1_MUNC,1,15)
	EndIf    
EndIf
       
//����������������������������������������������������Ŀ
//�Estado do cliente							 	   �
//������������������������������������������������������
If nOpc == 5 
	If EMPTY(SA1->A1_ESTC)
		cRet := SUBSTR(SA1->A1_EST,1,2)
	Else
		cRet := SUBSTR(SA1->A1_ESTC,1,2)
	EndIf 
EndIf

Return(cRet)