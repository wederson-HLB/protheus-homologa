#Include "Protheus.ch"

/*
Funcao      : MA020TDOK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada utilizado na rotina cadastro de fornecedores.
TDN			: Localiza��o: Est� localizado na fun��o A020TudoOk,rotina que faz consistencias apos a digitacao da telaQuando: O Ponto de Entrada � chamado no final da rotina para efetuar customiza��es do usu�rio para valida��oFinalidade: Validar a Fun��o A020TudoOk
Autor       : Renato Rezende
Data/Hora   : 22/08/2012
*/

*-----------------------*
User Function MA020TDOK()
*-----------------------*         
Local lRet 	:= .T.
Local cTitulo	:= ""
Local cDescrFol	:= ""

//MSM - 26/09/2013 - Incluido tratamento de campos obrigat�rios, dependendo do preenchimento no ARRAY
//Campos para validar na inlcus�o
Local aCamposINC	:= {"A2_CONTA","A2_CGC"} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposINC	:= ""

//Campos para validar na exclus�o
Local aCamposALT	:= {"A2_CGC"} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposALT	:= ""

//IF M->A2_EST != "EX"
//	IF Empty(M->A2_CGC)
//		ALERT("Necess�rio informar o campo CNPJ")
//		lRet := .F.
//	ENDIF
//ENDIF

If IsBlind()
	Return lRet
EndIf
#ifdef ENGLISH
	cSTRAba:="Folder"
	cSTRCpo:="Field"
#else
	cSTRAba:="Aba"
	cSTRCpo:="Campo"
#endif
	
if INCLUI
    for i:=1 to len(aCamposINC)
		if empty(M->&(aCamposINC[i]))
		
			DbSelectArea("SX3")
			DbSetOrder(2)
			if DbSeek(aCamposINC[i])
   				
   				//RRP - Obrigar o preenchimento do campo CNPJ se o cliente for diferente de EX
   				if "A2_CGC" $ aCamposINC[i] 
   					IF M->A2_EST == "EX"	
   						loop
   					ENDIF
   				endif
   				
   				//Nome do campo
				cTitulo:=X3Titulo()
                
				//Busco a pasta do campo
			    DbSelectArea("SXA")
			    DbSetOrder(1)
			    if DbSeek( SX3->X3_ARQUIVO+SX3->X3_FOLDER ) //alias do folder + numero do folder   
			    	cDescrFol := XADescric()
			    endif

		    	cCamposINC+=cSTRAba+": "+Alltrim(cDescrFol)+" - "+cSTRCpo+": " +  alltrim(cTitulo)+" ("+aCamposINC[i]+")"+CRLF
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
				
				//RRP - Obrigar o preenchimento do campo CNPJ se o cliente for diferente de EX
   				if "A2_CGC" $ aCamposALT[i] 
   					IF M->A2_EST == "EX"	
   						loop
   					ENDIF
   				endif
				
				 //Nome do campo
				cTitulo:=X3Titulo()

				//Busco a pasta do campo
				DbSelectArea("SXA")
			    DbSetOrder(1)
			    if DbSeek( SX3->X3_ARQUIVO+SX3->X3_FOLDER ) //alias do folder + numero do folder   
			    	cDescrFol := XADescric()
			    endif

	    	cCamposALT+=cSTRAba+": "+Alltrim(cDescrFol)+" - "+cSTRCpo+": " +  alltrim(cTitulo)+" ("+aCamposALT[i]+")"+CRLF
	    	lRet:=.F.
				
			endif

		endif
	next
endif

if !lRet

	#ifdef ENGLISH
		MsgStop("It is mandatory to fill out field below:"+CRLF+cCamposINC+cCamposALT,"Attention")
	#else
		MsgStop("� obrigat�rio o preenchimento do(s) campo(s) abaixo:"+CRLF+cCamposINC+cCamposALT,"Aviso")
	#endif
endif


Return lRet