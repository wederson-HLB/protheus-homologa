/*
Funcao      : PBFIN001
Parametros  : Nenhum
Retorno     : cReturno
Objetivos   : Fonte criado para facilitar o get das informações do sistemae para realizar o subtração dos impos do valor total do titulo antes de enviar o cnab para o banco.  f
Autor     	: João Silva
Data     	: 29/07/2014
Obs         : 
Módulo      : Financeiro.
*/
   
*------------------------------------*
 User Function I0FIN001(nOpc)
*-----------------------------------*

Local xRet
Local nOpc := PARAMIXB[1] 
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Verifica qual o banco e valor para informar se é um DOC, TED,BOLETO, ou transferencia     ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == '1'
	If cEmpAnt $ "I0" 
		If !EMPTY (SE2->E2_CODBAR)
		    xRet:= "081"
		ElseIf SUBSTR(SA2->A2_BANCO,1,3)='745'
			xRet:= "072"
		ElseIf (SE2->E2_SALDO)<1000.00
			xRet:= "071"
		Else
			xRet:= "083"
		EndIf
	EndIf
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o banco do fornecedor é citi se não for retorna o numero da agencia.  	    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == '2'
	If cEmpAnt $ "I0" 
		If SUBSTR(SA2->A2_BANCO,1,3)='745'
			xRet:= Replicate("0",4)	
		Else
			xRet:= StrZero(Val(AllTrim(SA2->A2_AGENCIA)),4)
		EndIf
	EndIf
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o banco do fornecedor é citi se não for retorna o numero da conta. 	 	    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == '3'
	If cEmpAnt $ "I0" 
		If SUBSTR(SA2->A2_BANCO,1,3)='745'
			xRet:= Replicate("0",15)	
		Else
			xRet:= StrZero(Val(AllTrim(SA2->A2_NUMCON)),15)
		EndIf
	EndIf
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conta do cliente	  	    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

If nOpc == '4'
	If cEmpAnt $ "I0" 
		If SUBSTR(SA2->A2_BANCO,1,3)='745'
			xRet:= StrZero(Val(AllTrim(SA2->A2_NUMCON)),15)
		Else    
			xRet:= Replicate("0",15)
					
		EndIf
	EndIf
EndIf       


Return(xRet)