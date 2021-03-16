#Include 'Protheus.ch'

/*
Funcao      : MT103FIN()
Objetivos   : Ultima validação do folder financerio na nota de Entrada.
Autor       : Anderson Arrais
Data/Hora   : 28/08/2017
*/       

*----------------------*
User Function MT103FIN()
*----------------------*
Local aLocHead := PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
Local aLocCols := PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.
Local lLocRet  := PARAMIXB[3]      // Flag de validações anteriores padrões do sistema.  

Local nPos	   := 0

//INICIO - CENTRAL XML
Local	aInParamIxb	:= aClone(ParamIxb)
Local	aAreaOld	:= GetArea()
Local	lRetorno	:= .T. 
Local	aInHeader	:= ParamIxb[1]
Local	aInCols		:= ParamIxb[2]
Local	lInRetorno	:= ParamIxb[3]
Local	nR	
Local 	nPE2Valor  	:= aScan(aInHeader,{|x| AllTrim(x[2])=="E2_VALOR"})
Local 	nPE2Venc   	:= aScan(aInHeader,{|x| AllTrim(x[2])=="E2_VENCTO"})
//FIM - CENTRAL XML

If cEmpAnt $ "HH/HJ"
	nPos := Ascan(aLocHead,{|x| Alltrim(x[2]) == 'E2_P_FOPAG'})
	If EMPTY(aLocCols[1][nPos])
		Alert('O campo "Forma de pag" na aba duplicata deve ser preenchido.')   
		lLocRet := .F.
	EndIf	
EndIf

//INICIO - CENTRAL XML
If SUPERGETMV("MV_P_00118", .F. , .F. )	//Valida se está habilitado para uso da central XML	
	// Ponto de entrada para verificar se o mesmo deve ser executado
	// 21/01/2018 
	If ExistBlock( "ZEXPEXML" )
		lRet := ExecBlock( "ZEXPEXML", .F., .F.,{"MT103FIN",aInParamIxb} )
		If Type("lRet") == "L"
			If !lRet
				Return 
			Endif
		Endif
	EndIf
	
	If Type("aDupAxSE2") == "A"
		aDupAxSE2	:= {}	
		For nR	:= 1 To Len(aInCols)
			Aadd(aDupAxSE2,{aInCols[nR,nPE2Venc],aInCols[nR,nPE2Valor]})
		Next nR
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Pontos de Entrada 													|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("XMT103FIN"))
		lLocRet := ExecBlock("XMT103FIN",.F.,.F.,{aInHeader,aInCols,lInRetorno})	
	EndIf
	
	RestArea(aAreaOld)
EndIf
//FIM - CENTRAL XML

Return(lLocRet)
