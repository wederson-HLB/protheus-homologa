#Include "Protheus.ch"

/*
Funcao      : MT103CWH    - PONTO DE ENTRADA
Parametros  : cCampo,cConteudo,lClassif
Retorno     : .T.
Objetivos   : Alterar a espécio do documento para SPED quando for informado formulário próprio SIM
TDN			: Localização:Function A103ChWhen - Checa when dos campos de cabeçalho da Pré-Nota e Nota Fiscal de Entrada
			: Finalidade:Ponto de Entrada que permite alterar o WHEN dos campos de cabeçalho da Pré-Nota e Nota
Autor       : Matheus Massarotto
Data/Hora   : 24/05/2012    14:02
Revisão		:                    
Data/Hora   : 
Módulo      : Estoque
*/
*---------------------*
User Function MT103CWH
*---------------------*	
	if FUNNAME() =="MATA103"
		//Se for formulário próprio SIM, altera a espécie do documento
		if UPPER(ALLTRIM(PARAMIXB[1]))=="F1_FORMUL"
			if UPPER(ALLTRIM(PARAMIXB[2]))=="SIM"
				cEspecie:="SPED"
			endif
		endif
	endif
	
Return(.T.)