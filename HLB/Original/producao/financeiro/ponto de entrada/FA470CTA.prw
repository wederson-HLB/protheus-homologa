#Include "rwmake.ch"   

/*
Funcao      : FA470CTA
Retorno     : Nenhum   
Objetivos   : O ponto de entrada FA470CTA será executado na leitura do saldo inicial, sendo possível alterar os dados do banco.
TDN        	: http://tdn.totvs.com/display/public/mp/FA470CTA+-+Leitura+de+saldo+inicial+--+12006
Autor     	: Anderson Arrais
Data     	: 02/03/2017  
Obs         : 
Módulo      : Financeiro
*/

*---------------------*
User Function FA470CTA
*---------------------*

cBanco   := PARAMIXB[1]
cAgencia := PARAMIXB[2]
cConta	 := PARAMIXB[3]

If cEmpAnt $ "HH"
	
	If cBanco ="341" .AND. cAgencia ="0912"
		cConta   := "024445"	
    EndIf

ElseIf cEmpAnt $ "HJ"
	
	If cBanco ="341" .AND. cAgencia ="0912"
		cConta   := "024296"	
    EndIf 

//AOA - 25/09/17 - Inclusão de tratamento de conta para empresa AVL
ElseIf cEmpAnt $ "G2"
	
	If cBanco ="341" .AND. cAgencia ="8499"
		cConta   := "247909"+Space(TamSX3("EE_CONTA")[1]-Len(cConta))
		cAgencia := "8499"+Space(TamSX3("EE_AGENCIA")[1]-Len(cAgencia))	
    EndIf

//AOA - 11/10/17 - Inclusão de tratamento de conta para empresa JDSU
ElseIf cEmpAnt $ "41"
	
	If cBanco ="341" .AND. cAgencia ="0262"
		cConta   := "061096"	
    EndIf 
//AOA - 17/10/17 - Inclusão de tratamento de conta para empresa MONSTER
ElseIf cEmpAnt $ "JO"
	
	If cBanco ="237" .AND. cAgencia ="3381"
		cConta   := "29173"+Space(TamSX3("EE_CONTA")[1]-Len(cConta))
		cAgencia := "3381"+Space(TamSX3("EE_AGENCIA")[1]-Len(cAgencia))		
    EndIf 
        
EndIf

Return {cBanco, cAgencia, cConta} 