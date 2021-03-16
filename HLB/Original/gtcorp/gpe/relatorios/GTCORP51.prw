#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Shell.ch"
#Include "TbiConn.ch"

/*
Funcao      : GTCORP51
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relatorios com adminições do mês organizado por empresas
Autor       : Daniel Fonseca de Lira
Revisão     :
Data/Hora   : 29/10/2012 16:37
Módulo      : Gestão de pessoal
Clientes    :
TDN         :
*/


#Define AEMPRESAS_CODE 1
#Define AEMPRESAS_NOME 2

*----------------------------*
User Function GTCORP51()
*----------------------------*
	Local cGrupoDePerguntas  := 'GTCORP51_P'
	Local aEmpresas          := {}
	Local cSql               := ''
	Local cHtml              := ''
	Local nRecNoSigamat      := -1
	
	/* Apenas para eu testar pelo Totvs developer
	If Select('SX2') == 0
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv('99', '01', , , 'GPE')
	EndIf
	*/
	
	PutSx1(cGrupoDePerguntas, '01', 'Data Consulta?', 'Data Consulta?', 'Data Consulta?', '', 'D', 08, 00, 00, 'C', '', '', '', '', 'MV_PAR01')
	If !Pergunte(cGrupoDePerguntas, .T.)
		Return .F.
	EndIf
	MV_PAR01 := SubStr(DtoS(MV_PAR01), 1, 6)
	
	// Prepara o array com codigo e nome da empresa
	nRecNoSigamat := SM0->(RecNo())
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())
	While !SM0->(Eof())
		If aScan(aEmpresas, {|aEmpresaTemp| aEmpresaTemp[AEMPRESAS_CODE] == SM0->M0_CODIGO}) == 0
			aAdd(aEmpresas, {SM0->M0_CODIGO, SM0->M0_NOME })
		EndIf
		SM0->(DbSkip())
	EndDo
	SM0->(DbGoTo(nRecNoSigamat))

	// Consulta os dados da empresa
	For nI = 1 To Len(aEmpresas)
		// Testa se a tabela SRA da empresa existe
		If TcSqlExec('SELECT TOP 1 * FROM SRA' + aEmpresas[nI][AEMPRESAS_CODE] + '0') < 0
			Loop
		EndIf
		
		// Se existe prepara a consulta e faz a consulta
		cSql := "SELECT RA_NOME 
		cSql += " FROM SRA" + aEmpresas[nI][AEMPRESAS_CODE] + "0 
		cSql += " WHERE RA_ADMISSA BETWEEN '" + MV_PAR01 + "01' AND '" + MV_PAR01 + "31'
		cSql += " 		AND D_E_L_E_T_ <> '*'
		cSql += " 		AND (RA_DEMISSA = '' OR (RA_DEMISSA NOT BETWEEN '" + MV_PAR01 + "01' AND '" + MV_PAR01 + "31'))
		cSql += " ORDER BY RA_NOME"
		DbUseArea(.T., 'TOPCONN', TcGenQry(,,cSql),'TRB99', .F., .T.)
		
		// Adiciona os nomes junto com o nome e codigo da empresa (nomes iniciam acima do indice 2)
		TRB99->(DbSetOrder(0))
		TRB99->(DbGoTop())
		While !TRB99->(Eof())
			aAdd(aEmpresas[nI], TRB99->RA_NOME)
			TRB99->(DbSkip())
		EndDo
		
		// Finaliza
		TRB99->(DbCloseArea('TRB99'))
	Next nI
	
	
	// Inicia o HTML
	cHtml := '<!DOCTYPE html><html><head><title>Relatório de contratações do mês</title>'
	cHtml += '<style type="text/css">'
	cHtml += 'table{border-collapse:collapse;}.funcionario{background: #F6F0FF;}.empresa{background: #BF94FF;}td{border: 1px solid black;}'
	cHtml += '</style>'
	cHtml += '</head><body><table>'
	
	// Para cada empresa	
	For nI := 1 To Len(aEmpresas)
		
		// Registros da empresas
		nEmpresas := Len(aEmpresas[nI])
		
		// Caso tenha mais registros que o nome e codigo adiciona
		// nome da empresa e nome do funcionario
		If nEmpresas > 2
			For nJ := 1 To nEmpresas
				If nJ == AEMPRESAS_NOME
					cHtml += '<tr><td class="empresa">' + aEmpresas[nI][AEMPRESAS_NOME] + '</tr></td>'
				ElseIf nJ > AEMPRESAS_NOME
					cHtml += '<tr><td class="funcionario">' + aEmpresas[nI][nJ] + '</tr></td>'
				EndIf
			Next nJ
		EndIf
		
	Next nI
	cHtml += '</table></body></html>'
	
	
	// Salva o arquivo no disco do usuario e abre com excel
	cDest :=  GetTempPath()
	cArq := 'contratacoesdomes_' + MV_PAR01 + '.xls'
		
	If File (cDest+cArq)
		Ferase (cDest+cArq)
	EndIf

	nHdl 	:= Fcreate(cDest+cArq,0 )
	nBytesSalvo := Fwrite(nHdl, cHtml)
	
	If nBytesSalvo <= 0
		MsgStop('Erro de gravação do Destino. Error = ' + Str(Ferror(), 4) + ' Erro')
	Else
		Fclose(nHdl)
		cExt := '.xls'
		ShellExecute('open', (cDest+cArq), '', '', 5)
	EndIf
		
Return .F.