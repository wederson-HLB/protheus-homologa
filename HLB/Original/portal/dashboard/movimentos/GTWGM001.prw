#include "apwebex.ch"
#include "totvs.ch"
#include 'tbiconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWGM001 ºAutor  ³Tiago Luiz Mendonça  º  Data ³  08/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Movimentação por empresa - Dashboard.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

/*
Funcao      : GTWGM001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX de grafico de movimentação.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/08/12 20:00
*/
                

*-----------------------*
User Function GTWGM001()
*-----------------------*

Local cHtml	:= ""

Local nCon  

WEB EXTENDED INIT cHtml

	If Select("SX2") == 0
		PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'FIN'
	EndIf

	//Verifica se a sessão expirou.
	If  ValType(HttpSession->cLogin)<> "C" .or. Empty(HttpSession->cLogin);
	.or. ValType(HttpSession->cEmpresa)<> "C" .or. Empty(HttpSession->cEmpresa)
		cHtml := ExecInPage("GTWP007") //Pagina de sessão expirada.
	Else     
		cHtml := U_GTWGM002()  //Pagina do grafico movimentação 001.
	EndIf
	
WEB EXTENDED END
	 
Return cHtml
