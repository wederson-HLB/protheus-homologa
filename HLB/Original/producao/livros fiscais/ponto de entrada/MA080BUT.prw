#INCLUDE "rwmake.ch" 
#INCLUDE "PROTHEUS.CH"

/*
Funcao      : MA080BUT
Parametros  : nOpcao 2 - Visualiza��o / 3 - inclus�o / 4 - Altera��o / 5 - Exclus�o
Retorno     : aBotao = �Array� com as defini��es dos bot�es. aBotao[1]="ICONE" aBotao[2]=bBloco aBotao[3]=AjudaaBotao
Objetivos   : Ponto de entrada pertence � rotina de cadastro de tipos de entrada e sa�da, MATA080(). Ele permite ao usu�rio adicionar bot�es � barra de a��es relacionadaso.
Autor       : Richard Steinhauser Busso
Data/Hora   : 24/05/2017
*/

User Function MA080BUT()
Local nOpcao := PARAMIXB[1]	
Local aBotao := {}
	
	If nOpcao == 3
		aBotao :={{"Copia",{|| U_GTGEN039()},"Copiar Inf."}}    
    Endif
    
Return aBotao
