#Include "Protheus.ch"

/*
Funcao      : MA030BUT
Parametros  : Nil
Retorno     : Nil
Objetivos   : Ponto de entrada para adi��o de bot�es
TDN			: Este ponto de entrada pertence � rotina de cadastro de clientes  para a op��o �Refer�ncias�, MATA030(). Ele permite ao usu�rio adicionar bot�es � barra no topo da tela
Autor       : Matheus Massarotto
Data/Hora   : 28/08/2013    15:14
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gest�o de Contratos/Faturamento
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