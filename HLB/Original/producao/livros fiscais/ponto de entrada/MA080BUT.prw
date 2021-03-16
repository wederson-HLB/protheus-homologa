#INCLUDE "rwmake.ch" 
#INCLUDE "PROTHEUS.CH"

/*
Funcao      : MA080BUT
Parametros  : nOpcao 2 - Visualização / 3 - inclusão / 4 - Alteração / 5 - Exclusão
Retorno     : aBotao = “Array” com as definições dos botôes. aBotao[1]="ICONE" aBotao[2]=bBloco aBotao[3]=AjudaaBotao
Objetivos   : Ponto de entrada pertence à rotina de cadastro de tipos de entrada e saída, MATA080(). Ele permite ao usuário adicionar botões à barra de ações relacionadaso.
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
