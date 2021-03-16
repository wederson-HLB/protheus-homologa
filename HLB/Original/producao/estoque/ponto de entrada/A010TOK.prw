#include "rwmake.ch"
#include "protheus.ch"                      
                   

/*
Funcao      : A010TOK
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. grava��o do produto para validar o campo B1_P_TIP , solicitado pelo Depto. Fiscal. /Fun��o para validar se determinado campo deve ser obrigat�rio, no OK do cadastro de produtos.  
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 08/02/2009     
Obs         : 
TDN         : Function A010TudoOK - Fun��o de Valida��o para inclus�o ou altera��o do Produto. No in�cio das valida��es ap�s a confirma��o da inclus�o ou altera��o, antes da grava��o do Produto; deve ser utilizado para valida��es adicionais para a INCLUS�O ou ALTERA��O do Produto.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/02/2012
Obs         : 
M�dulo      : Estoque.
Cliente     : Todos   
*/

*--------------------------*     
  User Function A010TOK()
*--------------------------*     
         
Local lret:=.T. 
Local cTitulo		:= ""
Local cDescrFol		:= ""

//Campos para validar na inlcus�o
Local aCamposINC	:= {"B1_CONTA"} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposINC	:= ""

//Campos para validar na exclus�o
Local aCamposALT	:= {} //Coloque aqui os campos que voc� queira que sejam obrigat�rios
Local cCamposALT	:= ""

If FieldPos("B1_P_TIP") > 0
   If M->B1_P_TIP="1" .And. EmpTy(M->B1_POSIPI)
      MsgStop("Para Tip Produto = '1-Produto' ser� necess�rio informar a NCM na segunda pasta","HLB")         
      lRet:=.F.
   EndIf 
EndIf  

//Valida��o de TES para cupom no cadastro de produto   
If cEmpAnt $ "R7/VJ"
	If FieldPos("B1_P_CFTES") > 0 
		If M->B1_P_MULTB == "064" .Or. Alltrim(Substr(M->B1_DESC,1,2)) == "BM"	
			If Empty(M->B1_P_CFTES)  
				MsgStop("Campo TES Cupom F. deve ser informado para esse tipo de produto ","Shiseido")         
      			lRet:=.F.
			EndIf	     
		EndIf
  	EndIf
EndIf  

//MSM - 26/09/2013 - 17:10 Para validar se determinado campo est� preenchido
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

Return lRet

