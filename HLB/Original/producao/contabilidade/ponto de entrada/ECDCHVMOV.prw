#INCLUDE "Protheus.ch"

/*
Funcao      : ECDCHVMOV                    
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : O ponto de entrada ECDCHVMOV permite a manipulação da Chave durante a exportação de movimentos da Tabela CT2 para a ECD.
Autor       : Jean Victor Rocha	
Data/Hora   : 18/06/2015
*/
*-----------------------*
User Function ECDCHVMOV()
*-----------------------*
Local cRet := ""
Local cAliasCT2 := Alias() 

If CS0->CS0_ECDREV = 'FCO'
    cRet := cFilMov + DTOS( dData ) + cLote + cSbLote + (cAliasCT2)->CT2_TPSALD
Else
	cRet += (cAliasCT2)->CT2_FILIAL 
	cRet += DTOS( (cAliasCT2)->CT2_DATA ) 
	cRet += (cAliasCT2)->CT2_LOTE 
	cRet += (cAliasCT2)->CT2_SBLOTE 
	cRet += (cAliasCT2)->CT2_DOC
EndIf

Return cRet