#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL DADOSUSER DESCRIPTION "Serviço REST para integrações com protheus"
	WSMETHOD GET DESCRIPTION "Retorna Dados do Funcionário" WSSYNTAX "/DADOSUSER/"
END WSRESTFUL

WSMETHOD GET WSSERVICE DADOSUSER

	::SetContentType("application/json")
	//If !Empty(oJson["nome"])
	cJson := "{'codigo':'"+RetCodUsr()+"'}"
	
	::SetResponse(cJson)

Return .T.
