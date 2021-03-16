#Include 'Protheus.ch'

/*
Funcao      : DTGPE001
Parametros  : Nehum
Retorno     : Nil
Objetivos   : Relatório da DUN para criação de CSV com proventos, desonctos e base dos funcionarios.
Autor       : Daniel Fonseca de Lira
Revisão     :
Data/Hora   : 16/11/2012 14:08
Módulo      : Gestão de pessoal
Clientes    : DUN
TDN         :
*/

#Define RV_TIPOCOD_PROV '1'
#Define RV_TIPOCOD_DESC '2'
#Define RV_TIPOCOD_BASE '3'

User Function DTGPE001()
	Local oDlg      := Nil
	Local cArquivo  := Space(1024)
	Local dDataBase := Date() 
	Local dDataFin  := Date()
	
	If ! cEmpAnt $ 'DT/99'
		MsgInfo('Rotina desenvolvida para a empresa Dun Bradstreet')
		Return 1
	EndIf
	
	DEFINE MSDIALOG oDlg FROM 264,182 TO 380,613 TITLE "Gerar arquivo" OF oDlg PIXEL
	@ 004,010 TO 055,157 LABEL "" OF oDlg PIXEL
	
	@ 025,038 SAY "Da Data: " OF oDlg PIXEL Size 150,010 COLOR CLR_HBLUE
	@ 025,075 MsGet oEdit1 Var dDataBase Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
	
	@ 012,167 BUTTON "&Gerar"   SIZE 036,012 ACTION (RptStatus({|| , GerarTxt(dDataBase)}, 'Aguarde', 'Gerando arquivo')) OF oDlg PIXEL
	@ 030,167 BUTTON "&Sair" SIZE 036,012 ACTION (oDlg:End())   OF oDlg PIXEL    
	
		oEdit1:bValid     := {|| IIF(EMPTY(dDataBase),Vazio(dDataBase),.T.) }
	
	ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function GerarTxt(dDataBase)
	Local cAno       := SubString(AllTrim(Str(Year(dDataBase))), 3, 4)
	Local cMes       := AllTrim(StrZero(Month(dDataBase), 2, 0))
	Local cArquivo   := ''
	
	Local cTabela    := '%RC' + cEmpAnt + cAno + cMes + '%'
	Local aMat       := {}
	Local aProv      := {}
	Local aDesc      := {}
	Local aBase      := {}
	
	Local aCabecalho := {'Nome'          , 'Matricula'       , 'Salario'        , 'CPF'                   , 'Admissao'       , 'Demissao'         , ;
							'Funcao'        , 'Conta corrente'  , 'Banco'          , 'Endereco'              , 'Cidade'         , 'Estado'           , ;
							'Cep'           , 'Pais'            , 'Cod. proventos' , 'Descr. proventos'      , 'Valor proventos', 'Parcela proventos', ;
							'Cod. descontos', 'Descr. descontos', 'Valor descontos', 'Parcela descontos'     , 'Cod. base'      , 'Desc. base'       , ;
							'Valor base'    , 'Parcela base'    , 'Pay Group'      , 'Payroll Transaction ID', 'Check Number'   }
	
	Local nMaior     := 0
	Local nLenProv   := 0
	Local nLenBase   := 0
	Local nLenDesc   := 0
	Local cLinha     := ''
	Local nHndl      := -1
	
	
	// O mes esta fechado ?
	SX6->(DBSetOrder(1))
	If ! SX6->(DBSeek(xFilial('SX6')+'MV_FOLMES'))
		MsgInfo('Empresa aparentemente sem folha configurada, verificar parametro MV_FOLMES')
		Return 1
	EndIf
	
	If Year(dDataBase) >= Val(SubString(SX6->X6_CONTEUD, 1, 4)) .And. Month(dDataBase) >= Val(SubString(SX6->X6_CONTEUD, 5, 2))
		MsgInfo('O mes precisa estar fechado para executar a rotina' + CRLF + 'MV_FOLMES: ' + AllTrim(SX6->X6_CONTEUD))
		Return 1
	EndIf
	
	
	// Lendo o arquivo
	cArquivo := cGetFile('', 'Salvar', 1,'C:\\', .T., ,.F.)
	
	
	// Arquivo de saida do relatorio pode ser aberto ?
	nHndl := FOpen(cArquivo, 1)
	If nHndl == -1
		nHndl := FCreate(cArquivo, 1)
		If nHndl == -1
			MsgInfo('Nao foi possivel criar o arquivo')
			Return 1
		EndIf
	EndIf
	
	// Escreve o cabecalho do arquivo
	FWrite(nHndl, ArrayToString(aCabecalho, ';') + CRLF)
	
	// Listando funcionarios
	SetRegua(0)
	BeginSQL Alias 'SQL1'
		SELECT
			RA_NOME,RA_MAT,RA_SALARIO,RA_CIC,RA_ADMISSA,RA_DEMISSA,
			RJ_DESC,RA_CTDEPSA,RA_BCDEPSA,RA_ENDEREC,RA_MUNICIP,
			RA_ESTADO,RA_CEP,RA_NACIONA
		FROM %Table:SRA% AS SRA
			INNER JOIN %Table:SRJ% AS SRJ ON RJ_FUNCAO = RA_CODFUNC
		WHERE
			SRA.%NotDel% AND SRJ.%NotDel%
	EndSQL
	
	
	// Para cada funcionario
	While !SQL1->(Eof())
		aMat := {SQL1->RA_NOME   , SQL1->RA_MAT    , SQL1->RA_SALARIO, SQL1->RA_CIC    , SQL1->RA_ADMISSA, ;
				  SQL1->RA_DEMISSA, SQL1->RJ_DESC   , SQL1->RA_CTDEPSA, SQL1->RA_BCDEPSA, SQL1->RA_ENDEREC, ;
				  SQL1->RA_MUNICIP, SQL1->RA_ESTADO , SQL1->RA_CEP    , SQL1->RA_NACIONA}
				  
		aProv := {}
		aDesc := {}
		aBase := {}
		
		
		// Verifica lancamentos do funcionario
		BeginSQL Alias 'SQL2'
			SELECT
				RV_TIPOCOD,RV_COD,RV_DESC,RC_VALOR,RC_PARCELA
			FROM %Exp:cTabela% AS SRC
				INNER JOIN %Table:SRV% AS SRV ON RV_COD = RC_PD
			WHERE
				SRC.%NotDel% AND SRV.%NotDel%
				AND RC_MAT = %Exp:SQL1->RA_MAT%
			ORDER BY RV_TIPOCOD, RV_COD
		EndSQL
		
		
		// Cada tipo de lancamento vai para um array diferente (separado em provento, base e descontos)
		While !SQL2->(Eof())
			aLanc := {SQL2->RV_COD, SQL2->RV_DESC, SQL2->RC_VALOR, SQL2->RC_PARCELA}
			
			If SQL2->RV_TIPOCOD == RV_TIPOCOD_PROV
				AAdd(aProv, aLanc)
			ElseIf SQL2->RV_TIPOCOD == RV_TIPOCOD_DESC
				AAdd(aDesc, aLanc)
			ElseIf SQL2->RV_TIPOCOD == RV_TIPOCOD_BASE
				AAdd(aBase, aLanc)
			EndIf
			
			SQL2->(DbSkip())
		EndDo
		DbCloseArea('SQL2')
		
		
		// Qual array tem mais lancamentos?
		nLenProv := Len(aProv)
		nLenBase := Len(aBase)
		nLenDesc := Len(aDesc)
		
		If nLenProv > nLenBase .And. nLenProv > nLenDesc
			nMaior := nLenProv
		ElseIf nLenBase > nLenDesc
			nMaior := nLenBase
		Else
			nMaior := nLenDesc
		EndIf
		
		// Para a quantidade maxima de registros, lê os vetores, se tem registro imprime senao zera.
		For nI := 1 To nMaior
			// Zerando a linha
			cLinha := ''
			
			// Dados iniciais
			cLinha += ArrayToString(aMat, ';')
			
			// Ainda tem proventos?
			If nI <= nLenProv
				cLinha += ArrayToString(aProv[nI], ';')
			Else
				cLinha += ArrayToString({'','','',''}, ';')
			EndIf
			
			// Ainda tem descontos?
			If nI <= nLenDesc
				cLinha += ArrayToString(aDesc[nI], ';')
			Else
				cLinha += ArrayToString({'','','',''}, ';')
			EndIf
			
			// Ainda tem bases?
			If nI <= nLenBase
				cLinha += ArrayToString(aBase[nI], ';')
			Else
				cLinha += ArrayToString({'','','',''}, ';')
			EndIf
			
			/*
			Campos que nao existem no siga devem ser nulos, e no final da linha
			Pay Group
			Payroll Transaction ID
			Check Number
			Pais Empregado
			*/
			cLinha += ';;;'
			
			// Escreve a linha no arquivo
			FWrite(nHndl, cLinha + CRLF)
			IncRegua()
		Next nI
		
		// Proximo usuario
		SQL1->(DbSkip())
	EndDo
	DbCloseArea('SQL1')
	
	FClose(nHndl)
	MsgInfo('O arquivo foi gerado com sucesso em ' + cArquivo)
Return


// Varre o array e tranforma em String
Static Function ArrayToString(aArray, cSep)
	Local cRet := ''
	Local nI   := 1
	
	If cSep == Nil
		cSep := ''
	EndIf
	
	For nI := 1 To Len(aArray)
		// Se for numero converte para caracteres
		If ValType(aArray[nI]) $ 'N/F'
			cRet += AllTrim(Str(aArray[nI])) + cSep
		Else
			cRet += AllTrim(aArray[nI]) + cSep
		EndIf
	Next nI
Return cRet