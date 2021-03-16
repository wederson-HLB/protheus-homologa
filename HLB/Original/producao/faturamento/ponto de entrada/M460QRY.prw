#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : M460QRY
Parametros  : Nenhum
Retorno     : _cQry
Objetivos   : 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : Antes da montagem da Markbrowse. Deve-se utilizar este ponto de entrada junto com o M460FIL, 
			  pois possuem a mesma funcionalidade.Apesar de poder alterar a query passada como par�metro, isto 
			  n�o deve ser efetuado sob nenhuma hip�tese, deve-se apenas adicionar elementos � cl�usula 'Where' tal 
			  como � feito no MT460FIL.Este ponto de entrada somente ser� executado para a vers�o TOTVS DbAcces (TopConnect).
Revis�o     : Renato Rezende
Data/Hora   : 26/08/2014
M�dulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function M460QRY
*-------------------------*
Local _cQry 	:= PAramIXB[1]
Local _lConfFis := .F.

If cEmpAnt $ "SU/LG"
	// MSM - 06/01/2015 - Adicionado tratamento da consultoria da totvs - Chamado: 023393
	_lConfFis := GetMv("MV_CONFFIS") == "S"
	
	If _lConfFis
		_cQry += " AND C9_PEDIDO IN (SELECT C5_NUM FROM "+RetSqlName("SC5")+" WHERE D_E_L_E_T_ = ' ' AND C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO AND C5_P_STACO IN ('','3'))"
	EndIf

EndIf

Return(_cQry)