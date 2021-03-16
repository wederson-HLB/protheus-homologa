#Include "Protheus.ch"

/*
Funcao      : A010TOK
Parametros  : 
Retorno     : lRet
Objetivos   : Fun��o para validar se determinado campo deve ser obrigat�rio, no OK do cadastro de produtos.
TDN			: LOCALIZA��O : Function A010TudoOK - Fun��o de Valida��o para inclus�o ou altera��o do Produto.
			: EM QUE PONTO: No in�cio das valida��es ap�s a confirma��o da inclus�o ou altera��o, antes da grava��o do Produto; deve ser utilizado para valida��es adicionais para a INCLUS�O ou ALTERA��O do Produto.
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 26/09/2013    17:10
M�dulo      : Faturamento
*/

*------------------------*
User function A010TOK
*------------------------*
Local lRet			:= .T.
Local cTitulo		:= ""
Local cDescrFol		:= ""


//Campos para validar na inlcus�o
Local aCamposINC	:= {"B1_CONTA"} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposINC	:= ""

//Campos para validar na exclus�o
Local aCamposALT	:= {} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposALT	:= ""

if INCLUI
    for i:=1 to len(aCamposINC)
		if empty(M->&(aCamposINC[i]))
		
			DbSelectArea("SX3")
			DbSetOrder(2)
			if DbSeek(aCamposINC[i])
                //Nome do campo
				cTitulo:=X3Titulo()
                
				//Busco a pasta do campo
			    DbSelectArea("SXA")
			    DbSetOrder(1)
			    if DbSeek( SX3->X3_ARQUIVO+SX3->X3_FOLDER ) //alias do folder + numero do folder   
			    	cDescrFol := XADescric()
			    endif

		    	cCamposINC+="Aba: "+Alltrim(cDescrFol)+" - Campo: " +  alltrim(cTitulo)+" ("+aCamposINC[i]+")"+CRLF
		    	lRet:=.F.

			endif
		
		endif
	next
endif

if ALTERA
    for i:=1 to len(aCamposALT)
		if empty(M->&(aCamposALT[i]))
		
			DbSelectArea("SX3")
			DbSetOrder(2)
			if DbSeek(aCamposALT[i])
				 //Nome do campo
				cTitulo:=X3Titulo()

				//Busco a pasta do campo
				DbSelectArea("SXA")
			    DbSetOrder(1)
			    if DbSeek( SX3->X3_ARQUIVO+SX3->X3_FOLDER ) //alias do folder + numero do folder   
			    	cDescrFol := XADescric()
			    endif

	    		cCamposALT+="Aba: "+Alltrim(cDescrFol)+" - Campo: " +  alltrim(cTitulo)+" ("+aCamposALT[i]+")"+CRLF
	    		lRet:=.F.
				
			endif

		endif
	next
endif

if !lRet
	MsgStop("� obrigat�rio o preenchimento do(s) campo(s) abaixo:"+CRLF+cCamposINC+cCamposALT,"Aviso")
endif

Return(lRet)