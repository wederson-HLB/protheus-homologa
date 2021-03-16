#Include "Protheus.ch"

/*
Funcao      : MAT070OK
Parametros  : 
Retorno     : lRet
Objetivos   : Função para validar se determinado campo deve ser obrigatório, no OK do cadastro de Bancos
TDN			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 26/09/2013    17:10
Módulo      : Financeiro
*/

*------------------------*
User function MAT070OK
*------------------------*
Local lRet			:= .T.
Local cTitulo		:= ""
Local cDescrFol		:= ""


//Campos para validar na inlcusão
Local aCamposINC	:= {} //Coloque aqui os campos que você queira que sejam obrigatórios
Local cCamposINC	:= ""

//Campos para validar na exclusão
Local aCamposALT	:= {} //Coloque aqui os campos que você queira que sejam obrigatórios
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
	MsgStop("É obrigatório o preenchimento do(s) campo(s) abaixo:"+CRLF+cCamposINC+cCamposALT,"Aviso")
endif

Return(lRet)