#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTFIN007() ºAutor  ³Anderson Arrais   º Data ³  28/10/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte código de barras de concessionaria com 48 dígitos  º±±
±±º          ³e boleto bancário de 47 dígitos para o padrão febraban      º±±
±±º          ³de 44 dígitos                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 							                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------*
User Function GTFIN007()
*--------------------------*        
Local cCodBar:= ""
Local cA:=""
Local cB:=""
Local cC:=""
Local cD:=""
    
	If LEN(ALLTRIM(SE2->E2_CODBAR))== 48 //Código de barras Concessionária
		
		cCodBar:= SUBSTR(SE2->E2_CODBAR,1,11)+SUBSTR(SE2->E2_CODBAR,13,11)+SUBSTR(SE2->E2_CODBAR,25,11)+SUBSTR(SE2->E2_CODBAR,37,11)
		
	ElseIf LEN(ALLTRIM(SE2->E2_CODBAR))== 47 //Código de barras Boleto Bancário

		cA:=SUBSTR(SE2->E2_CODBAR,1,4)
		cB:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)	
		cC:=SUBSTR(SE2->E2_CODBAR,33,1)
		cD:=SUBSTR(SE2->E2_CODBAR,34,14)
		//Tratamento da ordem
		cCodBar:=cA+cC+cD+cB
	
	Else
	
		cCodBar:= ALLTRIM(SE2->E2_CODBAR)
	
	EndIf
		
Return(cCodBar)