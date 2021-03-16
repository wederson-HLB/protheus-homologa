#include "protheus.ch"
/*
Funcao      : GPE10BTN
Parametros  : 
Retorno     : 
Objetivos   : PE para inclusão de Botão na EnchoiceBar da manutenção de cadastro de Funcionarios.
TDN			: 
Autor       : Jean Victor Rocha
Data/Hora   : 25/02/2013
Revisão		: 
Data/Hora   : 
Módulo      : Gestão de Pessoal
Cliente		:
*/
*----------------------*
User Function GPE10BTN() 
*----------------------*
Local i
Local aRet := {}
Local aAux := {}


aRet:={"CADEADO",{|| U_GTGPE004() },"Supervisor","Supervisor" }


//Tratamento para campos a serem exibidos na tela do ponto eletronico.
If cModulo == "PON"
	SX3->(DbSetOrder(2))

	aAux := {}
	For i:=1 to Len(aSraFields)
		If SX3->(DbSeek(aSraFields[i]))
			If SX3->X3_FOLDER == "5" .or.;//Controle de ponto
				ALLTRIM(SX3->X3_CAMPO) $ "RA_NOME/RA_CC/RA_MAT/RA_PIS"
				aAdd(aAux,aSraFields[i])		
			EndIf
		EndIf
	Next i
	aSraFields := aAux 
	
	aAux := {}
	For i:=1 to Len(aSraAltera)
		If SX3->(DbSeek(aSraAltera[i]))
			If SX3->X3_FOLDER == "5" .or.;//Controle de ponto
				ALLTRIM(SX3->X3_CAMPO) $ "RA_NOME/RA_CC/RA_MAT/RA_PIS"
				aAdd(aAux,aSraAltera[i])		
			EndIf
		EndIf
	Next i
	aSraAltera := aAux
EndIf
	
Return aRet