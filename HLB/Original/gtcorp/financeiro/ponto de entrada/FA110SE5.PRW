#include "Protheus.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
 ±±ºPrograma  ³FA110SE5  ºAutor  ³Gestao Dinamica     º Data ³  01/31/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para alimentar o historico da baixa       º±±
 ±±º          ³ Numero da Fatura + Razao Social                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
 ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 */


/*
Funcao      : FA110SE5 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de Entrada para alimentar o historico da baixa numero da Fatura + Razao Social
Autor       : Gestao Dinamica
Data/Hora   : 01/31/12 
TDN         : O ponto de entrada FA110SE5 será utilizado na gravação de dados complementares na baixa a receber automática. Será executado após gravar o SE5.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/02/12 
Módulo      : Financeiro.
*/

*------------------------*
  User Function FA110SE5
*------------------------*

Local aArea := GetArea()
Local cHistor

DbselectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA)
cHistor :="Cliente: "+SA1->A1_NOME+" Fatura nº "+SE5->E5_NUMERO
 
If Alltrim(SE5->E5_RECPAG)='R'
 
	RecLock("SE5",.F.)
	Replace E5_HISTOR With cHistor     

	MsUnlock()
EndIf

RestArea(aArea) 
Return (cHistor)
