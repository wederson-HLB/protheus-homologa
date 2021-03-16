#include "protheus.ch"


/*
Funcao      : P_RQTDLOTE
Parametros  : nOpcao
Retorno     : nParam
Objetivos   : Função para tratamento de quantidade, de lotes no CNAB de pagamento de fornecedor. O parametro armazena qtd como contador para retornar o total
Autor     	: Matheus Massaroto
Data     	: 19/04/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 


/*
nOpcao 1 = retorna 1.
nOpcao 2 = retorna o total.
nOpcao 3 = retorna o total das linhas e zera o parametro.

*/

*--------------------------------*
 User function P_RQTDLOTE(nOpcao)  
*--------------------------------*

Local lAchou:=.T.    
Local lAchou2:=.T.
Local nParam:=0
Local nSomaP:=0
Local nQtdTot:=0

//Verifica e cria o parametro 
	lAchou := SX6->( dbSeek( xFilial( "SX6" ) + "MV_P_RQTL_" ) )
	If !lAchou 
		RecLock( "SX6" , .T. )
			X6_VAR     := "MV_P_RQTL_"
			X6_TIPO    := "N"
			X6_CONTEUD := "0"
			X6_DESCRIC := "Usado para armazenar qtd lote (cnab)"  // espaço max. de 50 caracteres
		SX6->(MsUnLock())
	EndIf
//--------------------------- 

//Verifica e cria o parametro 
	lAchou2 := SX6->( dbSeek( xFilial( "SX6" ) + "MV_P_RQTT_" ) )
	If !lAchou2 
		RecLock( "SX6" , .T. )
			X6_VAR     := "MV_P_RQTT_"
			X6_TIPO    := "N"
			X6_CONTEUD := "0"
			X6_DESCRIC := "Usado para armazenar qtd tot de linhas (cnab)"  // espaço max. de 50 caracteres
		SX6->(MsUnLock())
	EndIf
//---------------------------


If nOpcao == 2

	nParam:=GETMV("MV_P_RQTL_")

	nQtdTot:=GETMV("MV_P_RQTT_")
	nQtdTot:=nQtdTot+1
	PUTMV("MV_P_RQTT_",nQtdTot)
	
ElseIf nOpcao == 1

	nParam:=1
	nSomaP:=GETMV("MV_P_RQTL_")
	nSomaP:=nSomaP+nParam
	PUTMV("MV_P_RQTL_",nSomaP) 
	
	nQtdTot:=GETMV("MV_P_RQTT_")
	nQtdTot:=nQtdTot+1
	PUTMV("MV_P_RQTT_",nQtdTot)
	
Else
	nParam:=GETMV("MV_P_RQTT_")
	PUTMV("MV_P_RQTL_", 0)
	PUTMV("MV_P_RQTT_",0)    
Endif 
                               

Return nParam