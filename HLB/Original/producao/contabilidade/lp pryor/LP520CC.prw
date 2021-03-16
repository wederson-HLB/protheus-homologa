#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

User Function LP520CC()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("cRet,")


cRet := " "
   

IF SM0->M0_CODIGO $"HO" //ALPUNTO

	cRet:= '1101'

ELSEIF SM0->M0_CODIGO $"02/VB/CH/"  .OR. (SM0->M0_CODIGO$"Z4" .AND. SM0->M0_CODFIL$"05")   /// EMPRESAS DO GRUPO PRYOR

	cRet:= '1100'
	

ELSEIF(SM0->M0_CODIGO$"Z4" .AND. SM0->M0_CODFIL$"01" )    

	cRet:= '3210' 
	

ELSEIF(SM0->M0_CODIGO$"07" )//ENGECORPS

	cRet:= '5010'     
	
ELSEIF(SM0->M0_CODIGO$"Z8" )//CONSULTORES

	cRet:= '8100'

ELSE

	cRet:= '1000' 
	

ENDIF

//RRP - 22/08/2014 - Empresa Bottega
If cEmpAnt $ "46"
	//Dinheiro
	If Alltrim(SE1->E1_TIPO) == "R$"
		cRet:= "11112034"
	//Cartão
	ElseIf Alltrim(SE1->E1_TIPO) == "CC"
		If Alltrim(SE1->E1_NOMCLI) == "AMEX"  
			cRet:= "11313004"
		//Cielo
		Else		    				   
			cRet:= "11313001"	
		EndIf
	//Cheque
	ElseIf Alltrim(SE1->E1_TIPO) == "CH"
		cRet:= "11313008"
	EndIf
EndIf
	
Return(cRet)