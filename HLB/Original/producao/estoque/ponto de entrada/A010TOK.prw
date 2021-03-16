#include "rwmake.ch"
#include "protheus.ch"                      
                   

/*
Funcao      : A010TOK
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. gravação do produto para validar o campo B1_P_TIP , solicitado pelo Depto. Fiscal. /Função para validar se determinado campo deve ser obrigatório, no OK do cadastro de produtos.  
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/02/2009     
Obs         : 
TDN         : Function A010TudoOK - Função de Validação para inclusão ou alteração do Produto. No início das validações após a confirmação da inclusão ou alteração, antes da gravação do Produto; deve ser utilizado para validações adicionais para a INCLUSÃO ou ALTERAÇÃO do Produto.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : 
Módulo      : Estoque.
Cliente     : Todos   
*/

*--------------------------*     
  User Function A010TOK()
*--------------------------*     
         
Local lret:=.T. 
Local cTitulo		:= ""
Local cDescrFol		:= ""

//Campos para validar na inlcusão
Local aCamposINC	:= {"B1_CONTA"} //Coloque aqui os campos que você queira que sejam obrigatórios
Local cCamposINC	:= ""

//Campos para validar na exclusão
Local aCamposALT	:= {} //Coloque aqui os campos que você queira que sejam obrigatórios
Local cCamposALT	:= ""

If FieldPos("B1_P_TIP") > 0
   If M->B1_P_TIP="1" .And. EmpTy(M->B1_POSIPI)
      MsgStop("Para Tip Produto = '1-Produto' será necessário informar a NCM na segunda pasta","HLB")         
      lRet:=.F.
   EndIf 
EndIf  

//Validação de TES para cupom no cadastro de produto   
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

//MSM - 26/09/2013 - 17:10 Para validar se determinado campo está preenchido
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

Return lRet

