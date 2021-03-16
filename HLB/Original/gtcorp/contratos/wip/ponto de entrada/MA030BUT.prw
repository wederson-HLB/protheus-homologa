#Include "Protheus.ch"

/*
Funcao      : MA030BUT
Parametros  : Nil
Retorno     : Nil
Objetivos   : Ponto de entrada para adição de botões
TDN			: Este ponto de entrada pertence à rotina de cadastro de clientes  para a opção “Referências”, MATA030(). Ele permite ao usuário adicionar botões à barra no topo da tela
Autor       : Matheus Massarotto
Data/Hora   : 28/08/2013    15:14
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos/Faturamento
*/

*---------------------------*
User function MA030BUT()
*---------------------------*
Local aButtons := {}

if Valtype(PARAMIXB)=="A"
	if PARAMIXB[1]<>3
		aButtons := {{"BONUS",{|| U_GTCORP81()},"Unidade e Km", "Unidade e Km" }}
    endif
endif

Return(aButtons)