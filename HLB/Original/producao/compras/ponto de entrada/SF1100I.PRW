#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SF1100I  � Autor � Hamilton           � Data �  08/07/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada usado apos a gravaco da nota entrada      ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICA CLIENTES Pryor                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/   

/*
Funcao      : SF1100I 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. usado apos a gravaco da nota entrada  
Autor       : Hamilton 
Data/Hora   :   	
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 13/07/2012
Obs         : 
M�dulo      : Compras.
Cliente     : Todos
*/

*-----------------------*
 User Function SF1100I   
*-----------------------*

Local   _aArea

_aArea  := GetArea()  //DALVA A AREA ATUAL

// TRATAMENTO PARA GRAVAR O USUARIO NO SF1 - PARA SER USADO COMO FILTRO NA INTERFACE PRY/LINX
If SM0->M0_CODIGO $ "DU"   //SOMENTE A OAKLEY E EMPRESA TESTE

	dbselectarea("SF1")
	RecLock("SF1",.f.)
	field->F1_P_DIGPR:= substr(cusuario,7,15)
	MsUnlock()

ENDIF

//RRP - 23/01/2017 - Empresa desativada.       
/*If cEmpAnt $ "HZ"
   If SF1->F1_FORMUL $ "S,"               // Alterar Dados Adicionais da NFE
      U_AxAltSF1()
   Endif
EndIf 
*/
//RRP - 26/08/2014 - Inclus�o da empresa Exeltis. Chamado 020789
If cEmpAnt $ "SU/LG"
	SD1->(dbSetOrder(1))
	ZX1->(dbSetOrder(2))
	SD1->(dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	While !SD1->(EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		If ZX1->(dbSeek(xFilial()+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)))
			RecLock("ZX1",.F.)
			ZX1->ZX1_LOTECT := SD1->D1_LOTECTL
			ZX1->(MsUnLock())
		EndIf
		SD1->(dbSkip())
	EndDo
EndIf

RestArea(_aArea)  //RESTAURA A AREA 

Return
