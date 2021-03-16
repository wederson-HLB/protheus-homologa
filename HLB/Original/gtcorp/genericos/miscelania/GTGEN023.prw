/*
Fun��o  : GTGEN023
Objetivo: Retorna as informa��es do parametro MV_P_00008, produtos que podem ser utilizados.
          Fun��o auxiliar para o portal, faturamento GT.
Autor   : Jean Victor Rocha
Data    : 02/12/13
*/
*-----------------------*
User Function GTGEN023()
*-----------------------*
Local cRet := ""
Local cAux := ""

cAux := GetMv( "MV_P_00008" ,,"''") 

While Len(cAux) <> 0 
	If AT(";",cAux) <> 0
		cRet += "'"+	SUBSTR(cAux,1,AT(";",cAux)-1)	+"',"
		cAux := SUBSTR(cAux,AT(";",cAux)+1,LEN(cAux))
	Else
		cRet += "'"+	cAux	+"',"
		cAux := ""
	EndIf		
EndDo             

cRet := LEFT(cRet,LEN(cRet)-1)

Return cRet

/*
Fun��o  : GEN023A
Objetivo: Retorna as informa��es do parametro passado como parametro. Fun��o auxiliar para o portal, faturamento GT.
Autor   : Jean Victor Rocha
Data    : 10/12/13
*/
*-----------------------*
User Function GEN023A(cMv)
*-----------------------*
Return GetMv(ALLTRIM(cMv),,"") 