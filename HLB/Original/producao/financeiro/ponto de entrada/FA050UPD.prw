#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : FA050UPD
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Alterar o Gatilho do E2_FORNECE para o cliente NTT. 
Autor       : Renato Rezende
Data/Hora   : 16/01/2015
Obs         : 
TDN         : Ponto de Entrada da Rotina FINA050 (Chamado Antes da AxAltera).
Revisão     : 
Data/Hora   : 
Módulo      : Financeiro.
Cliente     : NTT
*/                                 	
*-------------------------*
 User Function FA050UPD()
*-------------------------* 
Local aArea	:= {}
Local lRet	:= .T.

If cEmpAnt $ "0F" 
	aArea	:= GetArea()
	If Funname()=="FINA050"
		//Alterando gatilho do fornecedor para o nome completo
		DbSelectArea("SX7")
		SX7->(DbSetOrder(1))
		If SX7->(DbSeek("E2_FORNECE"+"003"))
			SX7->(RecLock("SX7",.F.))
				Replace X7_CAMPO	With "E2_FORNECE"
				Replace X7_SEQUENC	With "003"
				Replace X7_REGRA	With "SA2->A2_NOME"
				Replace X7_CDOMIN	With "E2_NOMFOR"
				Replace X7_CHAVE	With "xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA"
				Replace X7_ALIAS	With "SA2"
				Replace X7_TIPO		With "P"
				Replace X7_SEEK		With "S"
				Replace X7_PROPRI	With "U"
				Replace X7_ORDEM	With 1
			SX7->(MsUnLock())
		EndIf
	EndIf
	RestArea(aArea)
EndIf 

Return lRet