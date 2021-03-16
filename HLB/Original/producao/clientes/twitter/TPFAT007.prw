#Include "TOTVS.ch" 
#Include "tbiconn.ch"
#Include "topconn.ch"


/*
Funcao      : TPFAT007
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : AxCadastro para desconto incondicional na Fatura Twitter.
Autor       : Renato Rezende
Data/Hora   : 29/08/2017
*/
*--------------------------*
 User Function TPFAT007()
*--------------------------*
Private cCadastro	:= "Cadastro de Desconto Incondicional X IO"
Private aRotina		:= {}
 
AxCadastro("ZX5", OemToAnsi(cCadastro),'U_TPFAT7Ex()')
 
Return Nil

/*
Funcao      : TPFAT7Ex()
Retorno     : lRet 
Objetivos   : Valida a exclusao do registro
Autor       : Renato Rezende
*/
*--------------------------*
User Function TPFAT7Ex() 
*--------------------------*
Local lRet		:= .T.
Local cQuery	:= ""
Local nRecCount	:= 0

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

cQuery:= " SELECT C5_P_NUM,C5_NUM FROM "+RetSQLName("SC5")+" " +CRLF
cQuery+= "  WHERE C5_P_NUM = '"+ZX5->ZX5_NUM+"' AND D_E_L_E_T_ <> '*' " +CRLF

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

Count to nRecCount

//Retornou resultado no select
If nRecCount > 0
	lRet:= .F.
	MsgInfo("IO Number não pode ser excluido, já utilizado no pedido!","HLB BRASIL")
EndIf

QRY->(DbCloseArea())

Return lRet