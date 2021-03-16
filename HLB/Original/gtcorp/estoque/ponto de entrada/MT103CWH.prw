#Include "Protheus.ch"

/*
Funcao      : MT103CWH    - PONTO DE ENTRADA
Parametros  : cCampo,cConteudo,lClassif
Retorno     : .T.
Objetivos   : Alterar a esp�cio do documento para SPED quando for informado formul�rio pr�prio SIM
TDN			: Localiza��o:Function A103ChWhen - Checa when dos campos de cabe�alho da Pr�-Nota e Nota Fiscal de Entrada
			: Finalidade:Ponto de Entrada que permite alterar o WHEN dos campos de cabe�alho da Pr�-Nota e Nota
Autor       : Matheus Massarotto
Data/Hora   : 24/05/2012    14:02
Revis�o		:                    
Data/Hora   : 
M�dulo      : Estoque
*/
*---------------------*
User Function MT103CWH
*---------------------*	
	if FUNNAME() =="MATA103"
		//Se for formul�rio pr�prio SIM, altera a esp�cie do documento
		if UPPER(ALLTRIM(PARAMIXB[1]))=="F1_FORMUL"
			if UPPER(ALLTRIM(PARAMIXB[2]))=="SIM"
				cEspecie:="SPED"
			endif
		endif
	endif
	
Return(.T.)