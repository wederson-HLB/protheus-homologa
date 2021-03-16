#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MT140CPO
Parametros  : Nenhum
Retorno     : _aRet
Objetivos   :  
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : LOCALIZAÇÃO : Function A140NFiscal() - Responsável por controlar a interface de um pre-documento de entrada.
			  EM QUE PONTO : O ponto de entrada é chamado logo no inicio do programa, e pode ser utilizado para incluir campos na 
			  GetDados quando seu retorno for um Array Multidimencional contendo campos do D1. Se, por exemplo, o retorno do RDMake 
			  for {'D1_SERVIC','D1_ENDER','D1_TPESTR'} estes campos irão aparecer na GetDados da Pré-Nota.
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function MT140CPO
*-------------------------*
Local aRetCpo := {}
//INICIO - CENTRAL XML
Local	aInParamIxb	:= aClone(ParamIxb)
//Local	aRetCpo		:= {} //ALTERADO PARA DEFINIDO COMO PADRAO DO PE
Local	aCamposPE	:= {}
Local	cD1BRetAnt	:= ""
Local	cD1VRetAnt	:= ""
Local	nForA
//FIM - CENTRAL XML

//AOA - 16/10/2017 - Acerto do ponto de entrada que estava duplicado. 
Aadd( aRetCpo , 'D1_TESACLA' )

If cEmpAnt $ "SU/LG"
	aAdd(aRetCpo,"D1_DFABRIC")
EndIf

//INICIO - CENTRAL XML
If SUPERGETMV("MV_P_00118", .F. , .F. )	//Valida se está habilitado para uso da central XML	
	cD1BRetAnt := GetNewPar("XM_CPD1BRT","") // Campo para informar a Base do ST retido Anteriormente
	cD1VRetAnt := GetNewPar("XM_CPD1VRT","") // Campo para informar o Valor do ST retido anteriormente
	// Ponto de entrada para verificar se o mesmo deve ser executado
	// 21/01/2018 
	If ExistBlock( "ZEXPEXML" )
		lRet := ExecBlock( "ZEXPEXML", .F., .F.,{"MT140CPO",aInParamIxb} )
		If Type("lRet") == "L"
			If !lRet
				Return 
			Endif
		Endif
	EndIf
	
	Aadd(aRetCpo,"D1_OPER")
	Aadd(aRetCpo,"D1_TESACLA")
	Aadd(aRetCpo,"D1_CF")
	Aadd(aRetCpo,"D1_LOTECTL")
	Aadd(aRetCpo,"D1_NUMLOTE")
	Aadd(aRetCpo,"D1_LOTEFOR")
	Aadd(aRetCpo,"D1_DTVALID")
	Aadd(aRetCpo,"D1_DFABRIC")
	Aadd(aRetCpo,"D1_FCICOD")
	
	DbSelectArea("SD1")
	If SD1->(FieldPos(cD1BRetAnt)) > 0
		Aadd(aRetCpo,cD1BRetAnt)	
	Endif
	
	If SD1->(FieldPos(cD1VRetAnt)) > 0
		Aadd(aRetCpo,cD1VRetAnt)	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do ponto de entrada MT140CPO                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("XMT140CPO")
		aCamposPE := If(ValType(aCamposPE:=ExecBlock('XMT140CPO',.F.,.F.))=='A',aCamposPE,{})
		If Len(aCamposPE) > 0
			For nForA := 1 to Len(aCamposPE)
				If (aScan(aRetCpo, aCamposPE[nForA])) == 0
					aadd(aRetCpo, aCamposPE[nForA])
				EndIf
			Next nForA
		EndIf
	EndIf
EndIf
//FIM - CENTRAL XML

Return(aRetCpo)
