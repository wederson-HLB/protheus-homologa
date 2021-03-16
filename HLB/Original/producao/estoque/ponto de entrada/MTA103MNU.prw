#Include 'Protheus.ch'
#Include 'topconn.ch'
/*
Funcao      : MTA103MNU
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada Documento de Entrada.
Autor       : Jean Victor Rocha
Data/Hora   : 11/09/2012
*/
*-----------------------*
User Function MTA103MNU()
*-----------------------*         
Local lRet := .T.
//INICIO - CENTRAL XML
Local	aInParamIxb	:= aClone(ParamIxb)
//FIM - CENTRAL XML

//Projeto doTerra
Local aParam := {} 
Local _aArea := GetArea() 

//AOA - 08/02/2018 - Projeto doTerra (customizado por William Souza)
IF cEmpAnt $ "N6" .AND. cFilAnt == "02" 
	AAdd(aRotina,{ "Nfe FedEX","u_N6WS001(3,1,SF1->(RECNO()))", 0 , 2, 0, .F.})
Endif 

RESTAREA(_aArea) 

If cEmpAnt $ "HB|99"
	AADD(aRotina,{"Qualidade" ,"U_HBEST002",0,5})
	
//RRP - 26/08/2014 - Inclusão da empresa Exeltis. Chamado 020789
ElseIf cEmpAnt $ "SU"//Exeltis
	aAdd(aRotina,{"Impr. Etiquetas", "U_SUGEN003", 0 , 6, 0, nil})
EndIf

//INICIO - CENTRAL XML
If SUPERGETMV("MV_P_00118", .F. , .F. )	//Valida se está habilitado para uso da central XML
	// Ponto de entrada para verificar se o mesmo deve ser executado
	// 21/01/2018 
	If ExistBlock( "ZEXPEXML" )
		lRet := ExecBlock( "ZEXPEXML", .F., .F.,{"MTA103MNU",aInParamIxb} )
		If Type("lRet") == "L"
			If !lRet
				Return 
			Endif
		Endif
	EndIf
	
	Aadd(aRotina,{ "Danfe/Dacte", "StaticCall(XMLDCONDOR,stViewNfe,1,SF1->F1_CHVNFE)", 0 , 2, 0, .F.})
	Aadd(aRotina,{ "Existe XML?", "U_MT103XCH()", 0 , 1, 0, .F.})
	Aadd(aRotina,{ "Consulta Sefaz", "StaticCall(XMLDCONDOR,stConSefaz,SF1->F1_CHVNFE,.T.,,)", 0 , 2, 0, .F.})
	Aadd(aRotina,{ "Lacto Contábil" ,"StaticCall(XMLDCONDOR,sfConCT2)", 0 , 2 , 0, .F.})
	Aadd(aRotina,{ "Conf.Cega"      ,"U_GMCOMR04(SF1->F1_CHVNFE)", 0 , 2, 0, .F.})
	// Chamada para Ponto de entrada nativo do Cliente - Padrão adição da letra "X" ao nome do Ponto de entrada
	//
	If ExistBlock("XMTA103MNU")
		ExecBlock("XMTA103MNU",.F.,.F.)
	EndIf
EndIf
//FIM - CENTRAL XML

Return lRet


/*/{Protheus.doc} MT103XCH
(Função para consultar a chave eletrônica na Central se existe ou não)

@author MarceloLauschner
@since 04/10/2014
@version 1.0
@return ${return}, ${return_descript
ion}
@example
(example 
s)
@see (links_or_references)
/*/
User Function MT103XCH()

//INICIO - CENTRAL XML	
Local		lRet		:= .F.
Local		aAreaOld	:= GetArea()
Local		oChvNfe
Local		cChvNfe		:= SF1->F1_CHVNFE	//Space(TamSX3("F1_CHVNFE")[1])
Local		oDlgCTE
// Somente notas de CTE e NFe em que o lançamento não vem da Central
	
If SUPERGETMV("MV_P_00118", .F. , .F. )	//Valida se está habilitado para uso da central XML	
	DEFINE MSDIALOG oDlgCTE Title OemToAnsi("Consulta XML existente na Central XML") FROM 001,001 TO 140,490 PIXEL
	@ 022,010 Say "Chave Eletrônica" Pixel of oDlgCTE
	@ 022,070 MsGet oChvNfe Var cChvNfe Size 160,10  Pixel Of oDlgCTE
	
	@ 050,070 BUTTON "Confirma" Size 50,10 Action (lRet := .T.,oDlgCTE:End() ) Pixel Of oDlgCTE
	@ 050,130 BUTTON "Cancela" Size 50,10 Action (oDlgCTE:End())	Pixel Of oDlgCTE
	
	ACTIVATE MsDialog oDlgCTE Centered
	
	If lRet
		
		cQry := "SELECT COUNT(*) EXISTXML "
		cQry += "  FROM TOP_FIELD "
		cQry += " WHERE FIELD_TABLE LIKE '%CONDORXML%' "
		
		TCQUERY cQry NEW ALIAS "QSXML"
		// Existir a tabela CONDORXML,irá validar a existencia da Chave na Base de dados
		If QSXML->EXISTXML > 0
			cQry := ""
			cQry += "SELECT XML_NOMEDT,XML_NUMNF,XML_KEYF1 "
			cQry += "  FROM CONDORXML "
			cQry += " WHERE  XML_CHAVE = '"+cChvNfe+"' "
			
			TCQUERY cQry NEW ALIAS "QSPED"
			
			If Eof()
				MsgInfo("Não há arquivo XML desta chave eletrônica na base de dados da Central XML.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem arquivo XML")
			Else				
				If !Empty(QSPED->XML_KEYF1)
					
					DbSelectArea("SF1")
					DbSetOrder(1)
					If DbSeek(QSPED->XML_KEYF1)
						MsgInfo("Arquivo XML encontrado na Central XML e documento já lançado.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" XML Ok!")
					Else
						MsgInfo("Arquivo XML encontrado na Central XML.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" XML Ok!")
					Endif
					QSPED->(DbCloseArea())
					QSXML->(DbCloseArea())
					Return 
				Else
					MsgInfo("Arquivo XML encontrado na Central XML.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" XML Ok!")
				Endif
			Endif
			QSPED->(DbCloseArea())
		Endif
		QSXML->(DbCloseArea())
	Endif
	
	RestArea(aAreaOld)
EndIf
//FIM - CENTRAL XML
	
Return
