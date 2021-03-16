#include 'protheus.ch'
#include 'parmtype.ch'

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北?Programa  * C200VLAT.PRW *                                              潮?
北?Autor     * Guilherme Fernandes Pilan - GFP *                           潮?
北?Data      * 20/03/2017 - 17:14 *                                        潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北?Descricao * Ponto de Entrada para permitir altera玢o de Planilhas *     潮?
北?          * quando o Contrato estiver em Revis鉶 *                      潮?
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?Uso       * GEST肙 DE CONTRATO                                          潮?
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
*------------------------*
User Function C200VLAT()
*------------------------*
Local cSituacao := Paramixb[1]
Local lRet := .F.

If cSituacao == "09"  // Revis鉶
	lRet := .T.
EndIf

Return lRet