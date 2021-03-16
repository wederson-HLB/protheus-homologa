#include "Protheus.ch"
#include "rwmake.ch"
#include "SHELL.CH"
/*
Funcao      : RWATF001  
Parametros  :
Retorno     :
Objetivos   : Validar se o Bem ja foi cadastrado na empresa, tratamento para filial exclusiva.
Autor       : Jean Victor Rocha
Data/Hora   : 05/06/2015 

Incluir no X3_VLDUSER (SX3):
N1_CBASE = IIF(!U_RWATF001() ,(ALERT("Bem ja cadastrado"),.F.),.T.) .And. FreeForUse("SN1",M->N1_CBASE)
N1_ITEM  = IIF(!U_RWATF001() ,(ALERT("Bem ja cadastrado"),.F.),.T.)
*/
*----------------------*
User function RWATF001()
*----------------------*
Local lRet := .T.
Local cQry := ""

cQry := " Select COUNT(*) as COUNT"
cQry += " From "+RETSQLNAME("SN1")
cQry += " Where D_E_L_E_T_ <> '*' "
cQry += " 	AND N1_CBASE = '"+M->N1_CBASE+"'
cQry += " 	AND N1_ITEM = '"+M->N1_ITEM+"'

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     	             	
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

lRet := QRY->COUNT == 0

QRY->(DbClosearea())

Return lRet