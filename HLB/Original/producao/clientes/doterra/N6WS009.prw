#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS009   º Autor ³ William Souza      º Data ³  04/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reenviar os pedidos de venda com erro de envio             º±±
±±º          ³ de picking WS                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra Brasil                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------*
User Function N6WS009(aParam) 
*---------------------------*
Local lJob		:= Type( 'oMainWnd' ) != 'O'
Local cEmp		:= ""
Local cFil		:= ""
Local cQry		:= ""
Local cAlias	:= "SC5N6WS009"//GetNextAlias()

If lJob 
	If (Valtype( aParam ) != 'A')
		cEmp := 'N6'
		cFil := '01'
	Else            
		cEmp := aParam[ 01 ]
		cFil := aParam[ 02 ]	
	EndIf

	RPCSetType(3)	
	RpcSetEnv( cEmp , cFil , "" , "" , 'FAT' )
EndIf   

If Select(cAlias)>0
	(cAlias)->(DbCloseArea())
EndIf

cQry := "SELECT C5_P_CHAVE
cQry += " FROM "+RetSqlName("SC5")
cQry += " WHERE C5_P_STFED in ('05','01')
cQry += " 	AND C5_FILIAL = '"+cfil+"'" 

DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), cAlias, .F., .T.) 

While !(cAlias)->(Eof())
 	u_N6WS004((cAlias)->C5_P_CHAVE)
 	(cAlias)->(dbSkip())	 
Enddo

If Select(cAlias)>0
	(cAlias)->(DbCloseArea())
EndIf

Return