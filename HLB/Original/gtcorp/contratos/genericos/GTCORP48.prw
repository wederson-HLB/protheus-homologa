#INCLUDE "Protheus.ch"

/*
Funcao      : GTCORP48
Parametros  : cCampo
Retorno     : cRet
Objetivos   : Fonte utilizado para retornar informações de alguns campos do contrato(CN9), na planilha(CNA),
            : Foi criado este fonte para utilizar o RestArea(), pois o posicione colocado direto no campo no X3_RELACAO da tabela CNA 
            : disposicionava um contrato quando a pessoa atualizava, gerando error log. (chamado interno:006939, chamado TOTVS: TFRSHN )
Autor       : Matheus Massarotto
Data/Hora   : 15/10/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*-----------------------------*
User Function GTCORP48(cCampo)
*-----------------------------*
Local cRet		:= ""
Local aArea		:= GETAREA()
Local nRecCN9	:= CN9->(RECNO())

 if INCLUI 
	cRet := ""
 else
   	if UPPER(ALLTRIM(cCampo))=="CNA_P_NOME"
	 	cRet:=Posicione( "CN9", 1, xFilial("CN9") + CNA->CNA_CONTRA, "CN9_P_NOME" )
 	elseif UPPER(ALLTRIM(cCampo))=="CNA_P_REVI"
 		cRet:=Posicione( "CN9", 1, xFilial("CN9") + CNA->CNA_CONTRA, "CN9_DTREV" )
 	endif
 endif

CN9->(DbGoTo(nRecCN9))	//Volta RECNO da CN9
RESTAREA(aArea)	//Volta RECNO da CNA
Return(cRet)