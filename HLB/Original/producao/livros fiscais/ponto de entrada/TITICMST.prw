#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  MA900TOK     �Autor  ATiago Luiz Mendon�a�   Data � 18/09/13 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada localizado ap�s a grava��o das informa��es���
���			   padr�es do tributo para t�tulo a ser gerado no financeiro  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������  

Funcao      : TITICMST 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. localizado ap�s a grava��o das informa��es padr�es do tributo para t�tulo a ser gerado no financeiro
Autor     	: Tiago Luiz Mendon�a
Data     	: 18/09/2013
Obs         : 
TDN         : Ponto de Entrada localizado ap�s a grava��o das informa��es padr�es do tributo para t�tulo a ser gerado no financeiro, isso vale para todos os impostos processados na fun��o GravaTit(). Deve ser utilizado para complementar ou alterar os valores padr�es j� gravados no t�tulo gerado pelos programas MATA461 (Nota Fiscal de Sa�da) ou MATA103 (Nota Fiscal de Entrada) atrav�s da configura��o via F12 para gerar t�tulos de ICMS-ST.O registro da tabela SE2 est� posicionado
Revis�o     :  
Data/Hora   : 
M�dulo      : Livros Fiscais.    
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
   		SE2->E2_CODRET      := cCodRetIPI //Codigo de reten��o
	EndIf
		
EndIf    

Return {SE2->E2_NUM,SE2->E2_VENCTO}
	