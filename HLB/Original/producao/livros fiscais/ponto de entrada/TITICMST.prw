#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  MA900TOK     ºAutor  ATiago Luiz Mendonçaº   Data ³ 18/09/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada localizado após a gravação das informaçõesº±±
±±º			   padrões do tributo para título a ser gerado no financeiro  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

Funcao      : TITICMST 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. localizado após a gravação das informações padrões do tributo para título a ser gerado no financeiro
Autor     	: Tiago Luiz Mendonça
Data     	: 18/09/2013
Obs         : 
TDN         : Ponto de Entrada localizado após a gravação das informações padrões do tributo para título a ser gerado no financeiro, isso vale para todos os impostos processados na função GravaTit(). Deve ser utilizado para complementar ou alterar os valores padrões já gravados no título gerado pelos programas MATA461 (Nota Fiscal de Saída) ou MATA103 (Nota Fiscal de Entrada) através da configuração via F12 para gerar títulos de ICMS-ST.O registro da tabela SE2 está posicionado
Revisão     :  
Data/Hora   : 
Módulo      : Livros Fiscais.    
Cliente     : Todos.
*/
          
*----------------------*
 User Function TITICMST 
*----------------------*


Local	cOrigem		:=	PARAMIXB[1]
//Local	cTipoImp	:=  PARAMIXB[2]           

If AllTrim(cOrigem)='MATA952'   //Apuracao de IPI
       
	If !Empty(cCodRetIPI)
		SE2->E2_DIRF		:= '1'	      //SIM   
   		SE2->E2_CODRET      := cCodRetIPI //Codigo de retenção
	EndIf
		
EndIf    

Return {SE2->E2_NUM,SE2->E2_VENCTO}
	