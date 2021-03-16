#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MA410DEL
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Na chamada da Função de Exclusão dos registros no SC5(Pedidos de vendas). Após deletar o registro no SC5.   
Obs         : 
Revisão     : Weden Alves
Data/Hora   : 17/12/2018
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function MA410DEL
*-------------------------*
Local _lRet 	:=	.T.       
Local cQuery 	:=	""
Local cAliasZX4	:=	"QRYZX4"
Local cUpdate 	:=	""                                                  

//Alteração na tabela ZX4 para que seja enviado o status de cancelamento para a IMS.
If cEmpAnt == "LG"
	              
	cQuery := "SELECT * FROM "+RetSqlName('ZX4')+" WHERE D_E_L_E_T_ <> '*' AND ZX4_P_REF = '"+SC5->C5_P_REF+"' AND ZX4_INTEGR = 'S' AND ZX4_NUM = '"+SC5->C5_NUM+"'
	cQuery += " ORDER BY ZX4_PRYKEY "
	
	If Select(cAliasZX4)>0
   		(cAliasZX4)->(DbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQuery), cAliasZX4, .F., .F. )
	
	While (cAliasZX4)->(!EOF())
		If !(cAliasZX4)->(EoF()) 
			
			cUpdate:= " UPDATE "+RetSqlName("ZX4")+" SET ZX4_ENVIMS = 'N', ZX4_PEDCAN = 'T'"
			cUpdate+= "  WHERE ZX4_FILIAL = '"+(cAliasZX4)->ZX4_FILIAL+"' AND D_E_L_E_T_ <> '*' AND ZX4_PRYKEY = '"+(cAliasZX4)->ZX4_PRYKEY+"' " 
			cUpdate+= "	   AND ZX4_P_REF = '"+(cAliasZX4)->ZX4_P_REF+"' AND ZX4_DATA = '"+(cAliasZX4)->ZX4_DATA+"' AND ZX4_NUM = '"+(cAliasZX4)->ZX4_NUM+"' "
			TcSqlExec(cUpdate)
		
		EndIf
		(cAliasZX4)->( DbSkip() )
	EndDo	
	                           
EndIf

Return(_lRet)