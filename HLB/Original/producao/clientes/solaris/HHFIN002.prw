#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
Funcao      : HHFIN002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera Copia dos Dados SE1,SE2 e SE5.
Autor       : Cesar Alves dos Santos
Revisao		: 
Cliente		: Solaris  
Data	    : 16/12/2016
*/    

*-----------------------*
User Function HHFIN002()
	*-----------------------*
	Private __Diretorio := ""
	Private oProcess

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Perguntas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega os parâmetros de Período Desejado, vinda do SX1         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Pergunte("HHFIN002",.T.) )
		//GTGENDBF()	
		// Processa( {|| GTGENDBF() }, "Aguarde...", "Exportando tabelas no banco de dados para .DBF",.F.)
		oProcess := MsNewProcess():New( { || HHFINDBF() } , "Exportando tabelas no banco de dados para Excel" , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif

Return()

/*
Funcao      : HHFINDBF()
Objetivos   : Gera Copia dos Dados SE1,SE2 e SE5 
Autor       : EMS SOLUCOES
Data	    : 14/11/2016
*/    

*-------------------------*
Static Function HHFINDBF()
*-------------------------*
	Local cCampos:= ""
	Local cQueCpo:= ""
	//TMS - 25/02/2020
	Local aArea        := GetArea()
	Local cQuery        := ""
	Local oFWMsExcel
	Local oExcel
	Local cArquivo
	Local cPlanImp
	Local cTitPlan
	__cDiretorio := Alltrim(MV_PAR03)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa depuracao dos arquivos                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia registros do SE1                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR04 = 1
		// TMS - 25/02/2020 - Incluido como private para considerar o bloco de registros da SE1
		cArquivo    := GetTempPath()+Alltrim( RetSQLName("SE1") )+"_RECEBER_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".xml"
		cPlanImp :="SE1"
		cTitPlan :=""
		cCampos:= ""
		cQueCpo:= ""

		/*	RRP - 02/03/2017 - Retirada dos campos de Log.
		cCampos:= "" 
		cQueCpo:= ""
	
		If Select('CPOSE1') > 0
 		CPOSE1->(DbCloseArea())
		Endif

	cQueCpo:= "SELECT 'SE1.'+COLUNA.name AS NOME" + CRLF
	cQueCpo+= "  FROM syscolumns COLUNA" + CRLF
	cQueCpo+= " INNER JOIN sysobjects TABELA on COLUNA.id = TABELA.id" + CRLF
	cQueCpo+= " WHERE TABELA.name = '"+RetSqlName("SE1")+"'" + CRLF
	cQueCpo+= "   AND COLUNA.name NOT IN ('E1_USERLGI', 'E1_USERLGA')" + CRLF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueCpo),"CPOSE1",.T.,.T.) 
	
	CPOSE1->(DbGoTop())
		While CPOSE1->(!Eof())
		cCampos+= ","+Alltrim(CPOSE1->NOME)
		CPOSE1->(DbSkip()) 
		EndDo*/
			
			
		If Select('SE1TRB') > 0
			CPOSE1->(DbCloseArea())
		EndIf


		If Select('SE1TRB') > 0
			(SE1TRB)->(DbCloseArea())
		Endif

		//CAS - 29/03/2017 - Imputacao dos campos manualemnte.
		cCampos := ",E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_PORTADO,E1_AGEDEP,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_EMISSAO,E1_VENCTO,E1_VENCREA,E1_VENCORI" + CRLF
		cCampos += ",E1_VALOR,E1_SALDO,E1_VALLIQ,E1_NUMBCO,E1_BAIXA,E1_NUMBOR,E1_DATABOR,E1_EMIS1,E1_HIST,E1_MOVIMEN,E1_DESCONT,E1_SABTPIS,E1_SABTCOF" + CRLF
		cCampos += ",E1_SABTCSL,E1_SABTIRF,E1_MULTA,E1_JUROS,E1_ACRESC,E1_DECRESC,E1_MOEDA,E1_FATURA,E1_OK,E1_OCORREN, E1_PEDIDO,E1_SERIE,E1_STATUS" + CRLF
		cCampos += ",E1_FILORIG,E1_CSLL,E1_COFINS,E1_PIS,E1_MSFIL,E1_MSEMP,E1_IDCNAB,E1_CODBAR,E1_CODDIG,E1_P_RETBA,E1_P_COBEX,E1_P_DATEX,E1_P_BOL " + CRLF
		cCampos += ",SE1.D_E_L_E_T_ WDELETE, SE1.R_E_C_N_O_ WRECNO " + CRLF

		//SE1TRB 	:= GetNextAlias() - TMS - 25/02/2020
		cQuery 		:= "SELECT SA1.A1_NOME AS 'CLIENTE', SA1.A1_CGC  AS 'CNPJ_CPF', " + CRLF
		cQuery		+= "(Case when SA1.A1_PESSOA = 'F' THEN SA1.A1_CGC else SubString(SA1.A1_CGC,1,8) End) AS 'R_CNPJ_CPF' " + CRLF
		cQuery		+= " "+cCampos+" "  + CRLF
		cQuery 		+= "FROM "+RetSQLName("SE1")+" SE1 " + " INNER JOIN " +RetSQLName("SA1")+" SA1 ON "  + CRLF
		cQuery 		+= "SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_FILIAL = SA1.A1_FILIAL AND SE1.E1_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ <> '*' " + CRLF
		cQuery 		+= "WHERE "+ CRLF
		cQuery 		+= "     SE1.E1_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + CRLF
		cQuery 		+= " AND SE1.E1_EMIS1  BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + CRLF
		cQuery 		+= " AND SE1.E1_PORTADO BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "' " + CRLF
		cQuery 		+= " AND SE1.E1_AGEDEP  BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "' " + CRLF
		cQuery 		+= " AND SE1.E1_CONTA   BETWEEN '" + mv_par15 + "' AND '" + mv_par16 + "' " + CRLF
		cQuery 		+= " AND SE1.E1_NUMBOR  BETWEEN '" + mv_par17 + "' AND '" + mv_par18 + "' " + CRLF
		TCQuery cQuery New Alias "SE1TRB"
		//cQuery 		:= ChangeQuery(cQuery) TMS - retirado em 25/02/2020
		TCSetField("SE1TRB","E1_EMISSAO","D",8,0)
		TCSetField("SE1TRB","E1_VENCTO","D",8,0)
		TCSetField("SE1TRB","E1_VENCREA","D",8,0)
		TCSetField("SE1TRB","E1_VENCORI","D",8,0)
		TCSetField("SE1TRB","E1_BAIXA","D",8,0)
		TCSetField("SE1TRB","E1_DATABOR","D",8,0)
		TCSetField("SE1TRB","E1_EMIS1","D",8,0)
		TCSetField("SE1TRB","E1_MOVIMEN","D",8,0)
		TCSetField("SE1TRB","E1_MOVIMEN","D",8,0)

		

	/*dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),SE1TRB,.T.,.T.)
	
	DbSelectArea(SE1TRB)
	DbGotop()         
   	
   	SX3->(DbSetOrder(2))
   	
	_aStru := (SE1TRB)->(DbStruct())
	nQ := Len(_aStru)
	nI := 1
		For nI := 1 to nQ
			If SX3->(DbSeek(_aStru[nI][1],.F.))
				If SX3->X3_TIPO == "D"
	    		_aStru[nI][2] := "D"
				Endif
			Endif
		_aRet := TamSX3(_aStru[nI,1])
			If Len(_aRet) > 0
 			_aStru[nI,3] := _aRet[01]
			_aStru[nI,4] := _aRet[02]
			Endif
		AADD(aArqDbf,{_aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4]})
		Next
    
	cArqDBF := CriaTrab(NIL,.F.)
	dbCreate(cArqDBF,aArqDBF,"DBFCDXADS")
	dbUseArea(.T.,"DBFCDXADS",cArqDBF,"TRB",.T.,.F.) 
	DbSelectArea("TRB")
                                
	dbSelectArea(SE1TRB)
		While !Eof()
		aRegTRB := {}
			For i := 1 To FCount()
			Aadd( aRegTRB , (FieldGet( i ))) 
			Next i
			
		DbSelectArea("TRB")
		RecLock('TRB',.T.)
			For i := 1 To Len( aRegTRB )
				If aArqDbf[i][2] == "D"
				FieldPut( i , Stod(aRegTRB[ i ]) )
				Elseif aArqDbf[i][2] == "N"
				FieldPut( i , NoRound(aRegTRB[ i ],2) )
				Else
				FieldPut( i , aRegTRB[ i ] )
				Endif
			Next
		MSUnlock() 

		dbSelectArea(SE1TRB)
		DbSkip()
		End

		If Select('SE1TRB') > 0
 		(SE1TRB)->(DbCloseArea()) 
		Endif

	dbSelectArea(SE1TRB)
    oProcess:SetRegua1( (SE1TRB)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE1")
	_cArqDBF	:= Alltrim( RetSQLName("SE1") )+"_RECEBER_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF

	DbSelectArea("TRB")
	DbCloseArea()
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) )  Copia arquivos do servidor para o local especificado
	(SE1TRB)->(DbCloseArea())
	FErase(_cArqDBF)Excluir arquivo 
	FErase(cArqDBF)  Excluir arquivo
	
  		 TMS - retirado em 25/02/2020 porque não gera mais em DBF apos release 25*/

		//Criando o objeto que ira gerar o conteudo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba 01
		oFWMsExcel:AddworkSheet(cPlanImp) //Nao utilizar numero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable(cPlanImp,cTitPlan)
		
		
		//Criando Colunas
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"CLIENTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R_CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_PREFIXO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_NUM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_PARCELA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_TIPO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_NATUREZ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_PORTADO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_AGEDEP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_CLIENTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_LOJA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_NOMCLI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_EMISSAO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_VENCTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_VENCREA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_VENCORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_VALOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_SALDO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_VALLIQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_NUMBCO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_BAIXA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_NUMBOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_DATABOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_EMIS1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_HIST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_MOVIMEN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_DESCONT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_SABTPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_SABTCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_SABTCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_SABTIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_MULTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_JUROS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_ACRESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_DECRESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_MOEDA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_FATURA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_OK",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_OCORREN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_PEDIDO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_SERIE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_STATUS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_FILORIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_CSLL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_COFINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_PIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_MSFIL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_MSEMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_IDCNAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_CODBAR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_CODDIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_P_RETBA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_P_COBEX",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_P_DATEX",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E1_P_BOL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WDELETE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WRECNO",1)

		SE1TRB->(dbGoTop())
		Do while SE1TRB->(!Eof())

			oFWMsExcel:AddRow(cPlanImp,cTitPlan,{;			
				Alltrim(SE1TRB->CLIENTE),;
				Alltrim(SE1TRB->CNPJ_CPF),;
				SE1TRB->R_CNPJ_CPF,;
				SE1TRB->E1_PREFIXO,;
				SE1TRB->E1_NUM,;
				SE1TRB->E1_PARCELA,;
				SE1TRB->E1_TIPO,;
				SE1TRB->E1_NATUREZ,;
				SE1TRB->E1_PORTADO,;
				SE1TRB->E1_AGEDEP,;
				SE1TRB->E1_CLIENTE,;
				SE1TRB->E1_LOJA,;
				SE1TRB->E1_NOMCLI ,;
				SE1TRB->E1_EMISSAO,;
				SE1TRB->E1_VENCTO,;
				SE1TRB->E1_VENCREA,;
				SE1TRB->E1_VENCORI,;
				TRANSFORM(SE1TRB->E1_VALOR,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_SALDO,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_VALLIQ,"@E 9,999,999.99"),;
				SE1TRB->E1_NUMBCO,;
				SE1TRB->E1_BAIXA,;
				SE1TRB->E1_NUMBOR,;
				SE1TRB->E1_DATABOR,;
				SE1TRB->E1_EMIS1,;
				SE1TRB->E1_HIST,;
				SE1TRB->E1_MOVIMEN,;
				TRANSFORM(SE1TRB->E1_DESCONT,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_SABTPIS,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_SABTCOF,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_SABTCSL,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_SABTIRF,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_MULTA,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_JUROS,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_ACRESC,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_DECRESC,"@E 9,999,999.99"),;
				SE1TRB->E1_MOEDA,;
				SE1TRB->E1_FATURA,;
				SE1TRB->E1_OK,;
				SE1TRB->E1_OCORREN,;
				SE1TRB->E1_PEDIDO,;
				SE1TRB->E1_SERIE,;
				SE1TRB->E1_STATUS,;
				SE1TRB->E1_FILORIG,;
				TRANSFORM(SE1TRB->E1_CSLL,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_COFINS,"@E 9,999,999.99"),;
				TRANSFORM(SE1TRB->E1_PIS,"@E 9,999,999.99"),;
				SE1TRB->E1_MSFIL,;
				SE1TRB->E1_MSEMP,;
				SE1TRB->E1_IDCNAB,;
				SE1TRB->E1_CODBAR,;
				SE1TRB->E1_CODDIG,;
				SE1TRB->E1_P_RETBA,;
				SE1TRB->E1_P_COBEX,;
				SE1TRB->E1_P_DATEX,;
				SE1TRB->E1_P_BOL,;
				SE1TRB->WDELETE,;
				SE1TRB->WRECNO;
				})
				

			SE1TRB->(dbskip())
		EndDo
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexao com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()

		//TMS - 25/02/2020
		SE1TRB->(DbCloseArea())
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SE2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR05 = 1
		//RRP - 02/03/2017 - Retirada dos campos de Log.
		// TMS - 25/02/2020 - Incluido como private para considerar o bloco de registros da SE2
		cArquivo    := GetTempPath()+Alltrim( RetSQLName("SE2") )+"_PAGAR_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".xml"
		cPlanImp :="SE2"
		cTitPlan :="Registros do SE2"
		cCampos:= ""
		cQueCpo:= ""

		If Select('SE2TRB') > 0
			(SE2TRB)->(DbCloseArea())
		Endif

		If Select('CPOSE2') > 0
			CPOSE2->(DbCloseArea())
		Endif

		cQueCpo:= "SELECT 'SE2.'+COLUNA.name AS NOME" + CRLF
		cQueCpo+= "  FROM syscolumns COLUNA" + CRLF
		cQueCpo+= " INNER JOIN sysobjects TABELA on COLUNA.id = TABELA.id" + CRLF
		cQueCpo+= " WHERE TABELA.name = '"+RetSqlName("SE2")+"'" + CRLF
		cQueCpo+= "   AND COLUNA.name NOT IN ('E2_USERLGI', 'E2_USERLGA')" + CRLF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueCpo),"CPOSE2",.T.,.T.)

		CPOSE2->(DbGoTop())
		While CPOSE2->(!Eof())
			If !Alltrim(CPOSE2->NOME) $ "SE2.E2_P_MODEL/SE2.E2_P_FOPAG"
				cCampos+= ","+Alltrim(CPOSE2->NOME)
				CPOSE2->(DbSkip())
			Else
				CPOSE2->(DbSkip())
			EndIf
		EndDo
		//CAS - 06/06/2017 - Inclusao da Linha do "CONVERT/E2_USERLGI/AS 'DT_USERLGI'" para pegar a data do LOG.
		//AOA - 04/09/2017 - Solaris inclusao do campo modelo de pagamento
		cCampos += ",(SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_TABELA='HH' AND X5_CHAVE=E2_P_FOPAG) AS PAGAMENTO"
		cCampos += ",(SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_TABELA='58' AND X5_CHAVE=E2_P_MODEL) AS MODELO"
		cCampos += ",CONVERT(     DATE,DATEADD(DAY,((ASCII(SUBSTRING(E2_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(E2_USERLGI,16,1)) - 50)),'19960101')) AS 'E2_DATALOG' "
		cCampos += ",SE2.D_E_L_E_T_ WDELETE, SE2.R_E_C_N_O_ WRECNO "

		If Select('SE2TRB') > 0
			CPOSE2->(DbCloseArea())
		EndIf

		//cAliasSE2 := GetNextAlias() - TMS - 25/02/2020
		cQuery 		:= "SELECT SA2.A2_NOME  AS 'FORNECEDOR', SA2.A2_CGC  AS 'CNPJ_CPF', " + CRLF
		cQuery		+= "(Case when SA2.A2_TIPO = 'F' THEN SA2.A2_CGC else SubString(SA2.A2_CGC,1,8) End) AS 'R_CNPJ_CPF' " + CRLF
		cQuery		+= " "+cCampos+" "  + CRLF
		cQuery 		+= "FROM "+RetSQLName("SE2")+" SE2 " + " INNER JOIN " +RetSQLName("SA2")+" SA2 ON " + CRLF
		cQuery 		+= "SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_FILIAL = SA2.A2_FILIAL AND SE2.E2_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*' " + CRLF
		cQuery 		+= "WHERE " + CRLF
		cQuery 		+= "     SE2.E2_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + CRLF
		cQuery 		+= " AND SE2.E2_EMIS1  BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + CRLF
		TCQuery cQuery New Alias "SE2TRB"
		//cQuery 		:= ChangeQuery(cQuery)

		TCSetField("SE2TRB","E2_BAIXA","D",8,0)
		TCSetField("SE2TRB","E2_DATAAGE","D",8,0)
		TCSetField("SE2TRB","E2_DATACAN","D",8,0)
		TCSetField("SE2TRB","E2_DATALIB","D",8,0)
		TCSetField("SE2TRB","E2_DATASUS","D",8,0)
		TCSetField("SE2TRB","E2_DTAPUR","D",8,0)
		TCSetField("SE2TRB","E2_DTBORDE","D",8,0)
		TCSetField("SE2TRB","E2_DTDIRF","D",8,0)
		TCSetField("SE2TRB","E2_DTFATUR","D",8,0)
		TCSetField("SE2TRB","E2_DTVARIA","D",8,0)
		TCSetField("SE2TRB","E2_EMIS1","D",8,0)
		TCSetField("SE2TRB","E2_EMISSAO","D",8,0)
		TCSetField("SE2TRB","E2_LIMCAN","D",8,0)
		TCSetField("SE2TRB","E2_MOVIMEN","D",8,0)
		TCSetField("SE2TRB","E2_VENCISS","D",8,0)
		TCSetField("SE2TRB","E2_VENCORI","D",8,0)
		TCSetField("SE2TRB","E2_VENCREA","D",8,0)
		TCSetField("SE2TRB","E2_VENCTO","D",8,0)
		TCSetField("SE2TRB","E2_DATALOG","D",8,0)

	/*dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
	
	DbSelectArea(cAliasSE2)
	DbGotop()         
   	
   	SX3->(DbSetOrder(2))
   	
	_aStru := (cAliasSE2)->(DbStruct())
	nQ := Len(_aStru)
	nI := 1
		For nI := 1 to nQ
			If SX3->(DbSeek(_aStru[nI][1],.F.))
				If SX3->X3_TIPO == "D"
	    		_aStru[nI][2] := "D"
				Endif
			Endif
		_aRet := TamSX3(_aStru[nI,1])
			If Len(_aRet) > 0
 			_aStru[nI,3] := _aRet[01]
			_aStru[nI,4] := _aRet[02]
			Endif
		AADD(aArqDbf,{_aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4]})
		Next
    
	cArqDBF := CriaTrab(NIL,.F.)
	dbCreate(cArqDBF,aArqDBF,"DBFCDXADS")
	dbUseArea(.T.,"DBFCDXADS",cArqDBF,"TRB",.T.,.F.) 
	DbSelectArea("TRB")
                                
	dbSelectArea(cAliasSE2)
		While !Eof()
		aRegTRB := {}
			For i := 1 To FCount()
			Aadd( aRegTRB , (FieldGet( i ))) 
			Next i
			
		DbSelectArea("TRB")
		RecLock('TRB',.T.)
			For i := 1 To Len( aRegTRB )
				If aArqDbf[i][2] == "D" .and. Alltrim(aArqDbf[i][1]) <> "E2_DATALOG"
				FieldPut( i , Stod(aRegTRB[ i ]) )
				Elseif aArqDbf[i][2] == "N"
				FieldPut( i , NoRound(aRegTRB[ i ],2) )
				Else
				FieldPut( i , aRegTRB[ i ] )
				Endif
			Next
		MSUnlock() 

		dbSelectArea(cAliasSE2)
		DbSkip()
		End

		If Select('cAliasSE2') > 0
 		(cAliasSE2)->(DbCloseArea()) 
		Endif
	
	dbSelectArea(cAliasSE2)
    oProcess:SetRegua1( (cAliasSE2)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE2")
	_cArqDBF	:= Alltrim( RetSQLName("SE2") )+"_PAGAR_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF

	DbSelectArea("TRB")
	DbCloseArea()
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSE2)->(DbCloseArea())
	FErase(_cArqDBF)Excluir arquivo  
	FErase(cArqDBF)  Excluir arquivo
  	
	   TMS - retirado em 25/02/2020*/

		//Criando o objeto que ira gerar o conteudo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba 01
		oFWMsExcel:AddworkSheet(cPlanImp) //Nao utilizar numero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable(cPlanImp,cTitPlan)
		//Criando Colunas
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"FORNECEDOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R_CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ACRESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_AGECHQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_AGLIMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ANOBASE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_APLVLMN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_APROVA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ARQRAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BAIXA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BASECOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BASECSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BASEINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BASEIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BASEISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BASEPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BCOCHQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BCOPAG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_BTRISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CCC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CCD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CCREDIT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CCUSTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CIDE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CLASCON",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CLEARIN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CLVL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CLVLCR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CLVLDB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CNO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CNPJRET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODAGL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODAPRO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODBAR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODOPE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODORCA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODRCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODRCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODRDA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODRET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODRPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CODSERV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_COFINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CONTAD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CORREC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CREDIT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CSLL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_CTACHQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DATACAN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DATALIB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DATASUS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DEBITO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DECRESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DESCONT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DESDOBR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DIACTB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DOCHAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DTAPUR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DTBORDE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DTDIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DTFATUR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DTVARIA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_EMIS1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_EMISSAO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FABOV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FACS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FAGEDV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FAMAD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FASEMT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FATFOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FATLOJ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FATPREF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FATURA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FCTADV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FETHAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FILDEB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FILIAL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FILORIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FIMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FLAGFAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FLUXO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FMPEQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORAGE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORBCO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORCTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORMPAG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORNECE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORNISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORNPAI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FORORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FRETISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_FUNDESA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_HIST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_HORASPB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IDCNAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IDDARF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IDENTEE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IDMOV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IMAMT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IMPCHEQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_INDICE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_INDPRO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_INSS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_INSSRET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_IRRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ITEMC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ITEMCTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ITEMD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_JUROS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LIMCAN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LINDIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LOJA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LOJAISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LOJORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_LOTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDBONI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDCONTR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDCRON",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDDESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDMULT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDPARCE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDPLANI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDREVIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MDRTISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MESBASE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MODSPB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MOEDA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MOTIVO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MOVIMEN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MSIDENT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MULTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_MULTNAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NATUREZ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NFELETR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NODIA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NOMERET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NOMFOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NROREF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUMBCO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUMBOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUMLIQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUMPRO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUMSOL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_NUMTIT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_OCORREN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_OK",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_OP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ORDPAGO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_ORIGEM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCAGL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCCID",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCCSS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCELA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCFAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCFAC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCFAM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCFET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCFMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCIR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCSES",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARCSLL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARFASE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARFUND",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMP1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMP2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMP2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMP3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMP4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PARIMP5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PERIOD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PLLOTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PLOPELT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PORCJUR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PORTADO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PREFIXO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PREOP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRETCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRETCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRETINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRETIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRETPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRINSS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PRISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PROCPCC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PROJETO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_PROJPMS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_P_IDPRO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_P_NDOC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_P_NUMFL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_RATEIO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_RATFIN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_RETCNTR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_RETENC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_RETINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_SALDO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_SDACRES",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_SDDECRE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_SEFIP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_SEQBX",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_SEST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_STATLIB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_STATUS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TEMDOCS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TIPO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TIPOFAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TIPOLIQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITADT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITORIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITPAI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TITPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TPDESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TPESOC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TPINSC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TRETISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TXMDCOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_TXMOEDA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_USUACAN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_USUALIB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_USUASUS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VALJUR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VALLIQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VALOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VARIAC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VARURV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VBASISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VENCISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VENCORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VENCREA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VENCTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VLCRUZ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETBIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_VRETPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R_E_C_D_E_",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R_E_C_N_O_",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"PAGAMENTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"MODELO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E2_DATALOG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WDELETE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WRECNO",1)


		SE2TRB->(dbGoTop())
		Do while SE2TRB->(!Eof())

			oFWMsExcel:AddRow(cPlanImp,cTitPlan,{;
				Alltrim(SE2TRB->FORNECEDOR),;
				Alltrim(SE2TRB->CNPJ_CPF),;
				SE2TRB->R_CNPJ_CPF,;
				TRANSFORM(SE2TRB->E2_ACRESC,"@E 9,999,999.99"),;
				SE2TRB->E2_AGECHQ,;
				SE2TRB->E2_AGLIMP,;
				SE2TRB->E2_ANOBASE,;
				SE2TRB->E2_APLVLMN,;
				SE2TRB->E2_APROVA,;
				SE2TRB->E2_ARQRAT,;
				SE2TRB->E2_BAIXA,;
				TRANSFORM(SE2TRB->E2_BASECOF,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_BASECSL,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_BASEINS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_BASEIRF,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_BASEISS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_BASEPIS,"@E 9,999,999.99"),;
				SE2TRB->E2_BCOCHQ,;
				SE2TRB->E2_BCOPAG,;
				TRANSFORM(SE2TRB->E2_BTRISS,"@E 9,999,999.99"),;
				SE2TRB->E2_CCC,;
				SE2TRB->E2_CCD,;
				SE2TRB->E2_CCREDIT,;
				SE2TRB->E2_CCUSTO,;
				TRANSFORM(SE2TRB->E2_CIDE,"@E 9,999,999.99"),;
				SE2TRB->E2_CLASCON,;
				SE2TRB->E2_CLEARIN,;
				SE2TRB->E2_CLVL,;
				SE2TRB->E2_CLVLCR,;
				SE2TRB->E2_CLVLDB,;
				SE2TRB->E2_CNO,;
				SE2TRB->E2_CNPJRET,;
				SE2TRB->E2_CODAGL,;
				SE2TRB->E2_CODAPRO,;
				SE2TRB->E2_CODBAR,;
				SE2TRB->E2_CODINS,;
				SE2TRB->E2_CODISS,;
				SE2TRB->E2_CODOPE,;
				SE2TRB->E2_CODORCA,;
				SE2TRB->E2_CODRCOF,;
				SE2TRB->E2_CODRCSL,;
				SE2TRB->E2_CODRDA,;
				SE2TRB->E2_CODRET,;
				SE2TRB->E2_CODRPIS,;
				SE2TRB->E2_CODSERV,;
				TRANSFORM(SE2TRB->E2_COFINS,"@E 9,999,999.99"),;
				SE2TRB->E2_CONTAD,;
				TRANSFORM(SE2TRB->E2_CORREC,"@E 9,999,999.99"),;
				SE2TRB->E2_CREDIT,;
				TRANSFORM(SE2TRB->E2_CSLL,"@E 9,999,999.99"),;
				SE2TRB->E2_CTACHQ,;
				SE2TRB->E2_DATACAN,;
				SE2TRB->E2_DATALIB,;
				SE2TRB->E2_DATASUS,;
				SE2TRB->E2_DEBITO,;
				TRANSFORM(SE2TRB->E2_DECRESC,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_DESCONT,"@E 9,999,999.99"),;
				SE2TRB->E2_DESDOBR,;
				SE2TRB->E2_DIACTB,;
				SE2TRB->E2_DIRF,;
				SE2TRB->E2_DOCHAB,;
				SE2TRB->E2_DTAPUR,;
				SE2TRB->E2_DTBORDE,;
				SE2TRB->E2_DTDIRF,;
				SE2TRB->E2_DTFATUR,;
				SE2TRB->E2_DTVARIA,;
				SE2TRB->E2_EMIS1,;
				SE2TRB->E2_EMISSAO,;
				TRANSFORM(SE2TRB->E2_FABOV,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_FACS,"@E 9,999,999.99"),;
				SE2TRB->E2_FAGEDV,;
				TRANSFORM(SE2TRB->E2_FAMAD,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_FASEMT,"@E 9,999,999.99"),;
				SE2TRB->E2_FATFOR,;
				SE2TRB->E2_FATLOJ,;
				SE2TRB->E2_FATPREF,;
				SE2TRB->E2_FATURA,;
				SE2TRB->E2_FCTADV,;
				TRANSFORM(SE2TRB->E2_FETHAB,"@E 9,999,999.99"),;
				SE2TRB->E2_FILDEB,;
				SE2TRB->E2_FILIAL,;
				SE2TRB->E2_FILORIG,;
				SE2TRB->E2_FIMP,;
				SE2TRB->E2_FLAGFAT,;
				SE2TRB->E2_FLUXO,;
				TRANSFORM(SE2TRB->E2_FMPEQ,"@E 9,999,999.99"),;
				SE2TRB->E2_FORAGE,;
				SE2TRB->E2_FORBCO,;
				SE2TRB->E2_FORCTA,;
				SE2TRB->E2_FORMPAG,;
				SE2TRB->E2_FORNECE,;
				SE2TRB->E2_FORNISS,;
				SE2TRB->E2_FORNPAI,;
				SE2TRB->E2_FORORI,;
				SE2TRB->E2_FRETISS,;
				TRANSFORM(SE2TRB->E2_FUNDESA,"@E 9,999,999.99"),;
				SE2TRB->E2_HIST,;
				SE2TRB->E2_HORASPB,;
				SE2TRB->E2_IDCNAB,;
				SE2TRB->E2_IDDARF,;
				SE2TRB->E2_IDENTEE,;
				SE2TRB->E2_IDMOV,;
				TRANSFORM(SE2TRB->E2_IMAMT,"@E 9,999,999.99"),;
				SE2TRB->E2_IMPCHEQ,;
				SE2TRB->E2_INDICE,;
				SE2TRB->E2_INDPRO,;
				TRANSFORM(SE2TRB->E2_INSS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_INSSRET,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_IRRF,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_ISS,"@E 9,999,999.99"),;
				SE2TRB->E2_ITEMC,;
				SE2TRB->E2_ITEMCTA,;
				SE2TRB->E2_ITEMD,;
				TRANSFORM(SE2TRB->E2_JUROS,"@E 9,999,999.99"),;
				SE2TRB->E2_LA,;
				SE2TRB->E2_LIMCAN,;
				SE2TRB->E2_LINDIG,;
				SE2TRB->E2_LOJA,;
				SE2TRB->E2_LOJAISS,;
				SE2TRB->E2_LOJORI,;
				SE2TRB->E2_LOTE,;
				SE2TRB->E2_MDBONI,;
				SE2TRB->E2_MDCONTR,;
				SE2TRB->E2_MDCRON,;
				TRANSFORM(SE2TRB->E2_MDDESC,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_MDMULT,"@E 9,999,999.99"),;
				SE2TRB->E2_MDPARCE,;
				SE2TRB->E2_MDPLANI,;
				SE2TRB->E2_MDREVIS,;
				SE2TRB->E2_MDRTISS,;
				SE2TRB->E2_MESBASE,;
				SE2TRB->E2_MODSPB,;
				SE2TRB->E2_MOEDA,;
				SE2TRB->E2_MOTIVO,;
				SE2TRB->E2_MOVIMEN,;
				SE2TRB->E2_MSIDENT,;
				TRANSFORM(SE2TRB->E2_MULTA,"@E 9,999,999.99"),;
				SE2TRB->E2_MULTNAT,;
				SE2TRB->E2_NATUREZ,;
				SE2TRB->E2_NFELETR,;
				SE2TRB->E2_NODIA,;
				SE2TRB->E2_NOMERET,;
				SE2TRB->E2_NOMFOR,;
				SE2TRB->E2_NROREF,;
				SE2TRB->E2_NUM,;
				SE2TRB->E2_NUMBCO,;
				SE2TRB->E2_NUMBOR,;
				SE2TRB->E2_NUMLIQ,;
				SE2TRB->E2_NUMPRO,;
				SE2TRB->E2_NUMSOL,;
				SE2TRB->E2_NUMTIT,;
				SE2TRB->E2_OCORREN,;
				SE2TRB->E2_OK,;
				SE2TRB->E2_OP,;
				SE2TRB->E2_ORDPAGO,;
				SE2TRB->E2_ORIGEM,;
				SE2TRB->E2_PARCAGL,;
				SE2TRB->E2_PARCCID,;
				SE2TRB->E2_PARCCOF,;
				SE2TRB->E2_PARCCSS,;
				SE2TRB->E2_PARCELA,;
				SE2TRB->E2_PARCFAB,;
				SE2TRB->E2_PARCFAC,;
				SE2TRB->E2_PARCFAM,;
				SE2TRB->E2_PARCFET,;
				SE2TRB->E2_PARCFMP,;
				SE2TRB->E2_PARCINS,;
				SE2TRB->E2_PARCIR,;
				SE2TRB->E2_PARCISS,;
				SE2TRB->E2_PARCPIS,;
				SE2TRB->E2_PARCSES,;
				SE2TRB->E2_PARCSLL,;
				SE2TRB->E2_PARFASE,;
				SE2TRB->E2_PARFUND,;
				SE2TRB->E2_PARIMA,;
				SE2TRB->E2_PARIMP1,;
				SE2TRB->E2_PARIMP2,;
				SE2TRB->E2_PARIMP2,;
				SE2TRB->E2_PARIMP3,;
				SE2TRB->E2_PARIMP4,;
				SE2TRB->E2_PARIMP5,;
				SE2TRB->E2_PERIOD,;
				TRANSFORM(SE2TRB->E2_PIS,"@E 9,999,999.99"),;
				SE2TRB->E2_PLLOTE,;
				SE2TRB->E2_PLOPELT,;
				TRANSFORM(SE2TRB->E2_PORCJUR,"@E 9,999,999.99"),;
				SE2TRB->E2_PORTADO,;
				SE2TRB->E2_PREFIXO,;
				SE2TRB->E2_PREOP,;
				SE2TRB->E2_PRETCOF,;
				SE2TRB->E2_PRETCSL,;
				SE2TRB->E2_PRETINS,;
				SE2TRB->E2_PRETIRF,;
				SE2TRB->E2_PRETPIS,;
				TRANSFORM(SE2TRB->E2_PRINSS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_PRISS,"@E 9,999,999.99"),;
				SE2TRB->E2_PROCPCC,;
				SE2TRB->E2_PROJETO,;
				SE2TRB->E2_PROJPMS,;
				SE2TRB->E2_P_IDPRO,;
				SE2TRB->E2_P_NDOC,;
				SE2TRB->E2_P_NUMFL,;
				SE2TRB->E2_RATEIO,;
				SE2TRB->E2_RATFIN,;
				TRANSFORM(SE2TRB->E2_RETCNTR,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_RETENC,"@E 9,999,999.99"),;
				SE2TRB->E2_RETINS,;
				TRANSFORM(SE2TRB->E2_SALDO,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_SDACRES,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_SDDECRE,"@E 9,999,999.99"),;
				SE2TRB->E2_SEFIP,;
				SE2TRB->E2_SEQBX,;
				TRANSFORM(SE2TRB->E2_SEST,"@E 9,999,999.99"),;
				SE2TRB->E2_STATLIB,;
				SE2TRB->E2_STATUS,;
				SE2TRB->E2_TEMDOCS,;
				SE2TRB->E2_TIPO,;
				SE2TRB->E2_TIPOFAT,;
				SE2TRB->E2_TIPOLIQ,;
				SE2TRB->E2_TITADT,;
				SE2TRB->E2_TITCOF,;
				SE2TRB->E2_TITCSL,;
				SE2TRB->E2_TITINS,;
				SE2TRB->E2_TITORIG,;
				SE2TRB->E2_TITPAI,;
				SE2TRB->E2_TITPIS,;
				SE2TRB->E2_TPDESC,;
				SE2TRB->E2_TPESOC,;
				SE2TRB->E2_TPINSC,;
				SE2TRB->E2_TRETISS,;
				TRANSFORM(SE2TRB->E2_TXMDCOR,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_TXMOEDA,"@E 9,999,999.99"),;
				SE2TRB->E2_USUACAN,;
				SE2TRB->E2_USUALIB,;
				SE2TRB->E2_USUASUS,;
				TRANSFORM(SE2TRB->E2_VALJUR,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VALLIQ,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VALOR,"@E 9,999,999.99"),;
				SE2TRB->E2_VARIAC,;
				TRANSFORM(SE2TRB->E2_VARURV,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VBASISS,"@E 9,999,999.99"),;
				SE2TRB->E2_VENCISS,;
				SE2TRB->E2_VENCORI,;
				SE2TRB->E2_VENCREA,;
				SE2TRB->E2_VENCTO,;
				TRANSFORM(SE2TRB->E2_VLCRUZ,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETBIS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETCOF,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETCSL,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETINS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETIRF,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETISS,"@E 9,999,999.99"),;
				TRANSFORM(SE2TRB->E2_VRETPIS,"@E 9,999,999.99"),;
				SE2TRB->R_E_C_D_E_,;
				SE2TRB->R_E_C_N_O_,;
				SE2TRB->PAGAMENTO,;
				SE2TRB->MODELO,;
				SE2TRB->E2_DATALOG,;
				SE2TRB->WDELETE,;
				SE2TRB->WRECNO;
				})

			SE2TRB->(dbskip())
		EndDo
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexao com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()

		//TMS - 25/02/2020
		SE2TRB->(DbCloseArea())
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SE5                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR06 = 1
		// TMS - 25/02/2020 - Incluido como private para considerar o bloco de registros da SE5
		cArquivo    := GetTempPath()+Alltrim( RetSQLName("SE5") )+"_EXTRATO_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".xml"
		cPlanImp :="SE5"
		cTitPlan :="Registros do SE5"
		//RRP - 02/03/2017 - Retirada dos campos de Log.
		cCampos:= ""
		cQueCpo:= ""

		If Select('SE5TRB') > 0
			(SE5TRB)->(DbCloseArea())
		Endif

		If Select('CPOSE5') > 0
			CPOSE5->(DbCloseArea())
		Endif

		cQueCpo:= "SELECT 'SE5.'+COLUNA.name AS NOME" + CRLF
		cQueCpo+= "  FROM syscolumns COLUNA" + CRLF
		cQueCpo+= " INNER JOIN sysobjects TABELA on COLUNA.id = TABELA.id" + CRLF
		cQueCpo+= " WHERE TABELA.name = '"+RetSqlName("SE5")+"'" + CRLF
		cQueCpo+= "   AND COLUNA.name NOT IN ('E5_USERLGI', 'E5_USERLGA')" + CRLF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueCpo),"CPOSE5",.T.,.T.)

		CPOSE5->(DbGoTop())
		While CPOSE5->(!Eof())
			cCampos+= ","+Alltrim(CPOSE5->NOME)
			CPOSE5->(DbSkip())
		EndDo

		cCampos += ",SE5.D_E_L_E_T_ WDELETE, SE5.R_E_C_N_O_ WRECNO "

		If Select('SE5TRB') > 0
			CPOSE5->(DbCloseArea())
		EndIf

		//cAliasSE5 := GetNextAlias()
		cQuery 		:= "SELECT SA1.A1_NOME AS 'CLIENTE', SA1.A1_CGC  AS 'A1CNPJ_CPF', "  + CRLF
		cQuery		+= " (Case when SA1.A1_PESSOA = 'F' THEN SA1.A1_CGC else SubString(SA1.A1_CGC,1,8) End) AS 'R1CNPJ_CPF', "  + CRLF
		cQuery		+= " SA2.A2_NOME AS 'FORNECEDOR', SA2.A2_CGC  AS 'A2CNPJ_CPF', "  + CRLF
		cQuery		+= " (Case when SA2.A2_TIPO = 'F' THEN SA2.A2_CGC else SubString(SA2.A2_CGC,1,8) End) AS 'R2CNPJ_CPF' "  + CRLF
		cQuery		+= " "+cCampos+" "  + CRLF
		cQuery 		+= "FROM "+RetSQLName("SE5")+" SE5 " + " LEFT JOIN " +RetSQLName("SA1")+" SA1 ON "  + CRLF
		cQuery 		+= "SE5.E5_CLIENTE = SA1.A1_COD AND SE5.E5_FILIAL = SA1.A1_FILIAL AND SE5.E5_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ <> '*' "  + CRLF
		cQuery 		+= "LEFT JOIN " +RetSQLName("SA2")+" SA2 ON "  + CRLF
		cQuery 		+= "SE5.E5_FORNECE = SA2.A2_COD AND SE5.E5_FILIAL = SA2.A2_FILIAL AND SE5.E5_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*' "  + CRLF
		cQuery 		+= "WHERE "   + CRLF
		cQuery 		+= "     SE5.E5_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "  + CRLF
		cQuery 		+= " AND SE5.E5_DATA  BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "  + CRLF

		//cQuery 		:= ChangeQuery(cQuery)
		TCQuery cQuery New Alias "SE5TRB" //TMS - 25/02/2020

		TCSetField("SE5TRB","E5_DATA","D",8,0)
		TCSetField("SE5TRB","E5_DTCANBX","D",8,0)
		TCSetField("SE5TRB","E5_DTDIGIT","D",8,0)
		TCSetField("SE5TRB","E5_DTDISPO","D",8,0)
		TCSetField("SE5TRB","E5_VENCTO","D",8,0)
		
	/*dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.T.,.T.)

	DbSelectArea(cAliasSE5)
	DbGotop()         
   	
   	SX3->(DbSetOrder(2))
   	
	_aStru := (cAliasSE5)->(DbStruct())
	nQ := Len(_aStru)
	nI := 1
		For nI := 1 to nQ
			If SX3->(DbSeek(_aStru[nI][1],.F.))
				If SX3->X3_TIPO == "D"
	    		_aStru[nI][2] := "D"
				Endif
			Endif
		_aRet := TamSX3(_aStru[nI,1])
			If Len(_aRet) > 0
 			_aStru[nI,3] := _aRet[01]
			_aStru[nI,4] := _aRet[02]
			Endif
		AADD(aArqDbf,{_aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4]})
		Next
    
	cArqDBF := CriaTrab(NIL,.F.)
	dbCreate(cArqDBF,aArqDBF,"DBFCDXADS")
	dbUseArea(.T.,"DBFCDXADS",cArqDBF,"TRB",.T.,.F.) 
	DbSelectArea("TRB")
                                
	dbSelectArea(cAliasSE5)
		While !Eof()
		aRegTRB := {}
			For i := 1 To FCount()
			Aadd( aRegTRB , (FieldGet( i ))) 
			Next i
			
		DbSelectArea("TRB")
		RecLock('TRB',.T.)
			For i := 1 To Len( aRegTRB )
				If aArqDbf[i][2] == "D"
				FieldPut( i , Stod(aRegTRB[ i ]) )
				Elseif aArqDbf[i][2] == "N"
				FieldPut( i , NoRound(aRegTRB[ i ],2) )
				Else
				FieldPut( i , aRegTRB[ i ] )
				Endif
			Next
		MSUnlock() 

		dbSelectArea(cAliasSE5)
		DbSkip()
		End

		If Select('cAliasSE5') > 0
		(cAliasSE5)->(DbCloseArea()) 
		Endif
	
	dbSelectArea(cAliasSE5)

    oProcess:SetRegua1( (cAliasSE5)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE5")
	_cArqDBF	:= Alltrim( RetSQLName("SE5") )+"_EXTRATO_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF

	DbSelectArea("TRB")
	DbCloseArea()
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) )  Copia arquivos do servidor para o local especificado
	(cAliasSE5)->(DbCloseArea())
	FErase(_cArqDBF) Excluir arquivo
	FErase(cArqDBF)  Excluir arquivo*/

		//Criando o objeto que ira gerar o conteudo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba 01
		oFWMsExcel:AddworkSheet(cPlanImp) //Nao utilizar numero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable(cPlanImp,cTitPlan)
		//Criando Colunas
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"CLIENTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"A1CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R1CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"FORNECEDOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"A2CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R2CNPJ_CPF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_AGENCIA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_AGLIMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_ARQCNAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_ARQRAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_AUTBCO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_BANCO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_BASEIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_BENEF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CCC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CCD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CCUSTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CGC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CLIENTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CLIFOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CLVLCR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CLVLDB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CNABOC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CODORCA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CONTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_CREDITO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DATA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DEBITO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DIACTB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DOCUMEN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DTCANBX",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DTDIGIT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_DTDISPO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_EDTPMS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FATPREF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FATURA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FILIAL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FILORIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FLDMED",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FORMAPG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FORNADT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_FORNECE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_HISTOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_IDENTEE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_IDMOVI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_IDORIG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_ITEMC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_ITEMD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_KEY",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_LA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_LOGALT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_LOJA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_LOJAADT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_LOTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_MODSPB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_MOEDA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_MOTBX",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_MOVCX",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_MOVFKS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_MULTNAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_NATUREZ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_NODIA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_NUMCHEQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_NUMERO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_NUMMOV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_OK",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_OPERAD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_ORDREC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_ORIGEM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PARCELA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PREFIXO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRETCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRETCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRETINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRETIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRETPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRINSS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PRISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PROCTRA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_PROJPMS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_RATEIO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_RECONC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_RECPAG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SDOCREC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SEQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SEQCON",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SERREC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SITCOB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SITUA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_SITUACA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TABORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TASKPMS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TIPO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TIPODOC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TIPOLAN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TPDESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_TXMOEDA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VALOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VENCTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLACRES",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLCORRE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLDECRE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLDESCO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLJUROS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLMOED2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VLMULTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VRETCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VRETCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VRETINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VRETIRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VRETISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"E5_VRETPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R_E_C_D_E_",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"R_E_C_N_O_",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WDELETE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WRECNO",1)


		SE5TRB->(dbGoTop())
		Do while SE5TRB->(!Eof())

			oFWMsExcel:AddRow(cPlanImp,cTitPlan,{;
				Alltrim(SE5TRB->CLIENTE),;
				Alltrim(SE5TRB->A1CNPJ_CPF),;
				SE5TRB->R1CNPJ_CPF,;
				SE5TRB->FORNECEDOR,;
				SE5TRB->A2CNPJ_CPF,;
				SE5TRB->R2CNPJ_CPF,;
				SE5TRB->E5_AGENCIA,;
				SE5TRB->E5_AGLIMP,;
				SE5TRB->E5_ARQCNAB,;
				SE5TRB->E5_ARQRAT,;
				SE5TRB->E5_AUTBCO,;
				SE5TRB->E5_BANCO,;
				TRANSFORM(SE5TRB->E5_BASEIRF,"@E 9,999,999.99"),;
				SE5TRB->E5_BENEF,;
				SE5TRB->E5_CCC,;
				SE5TRB->E5_CCD,;
				SE5TRB->E5_CCUSTO,;
				SE5TRB->E5_CGC,;
				SE5TRB->E5_CLIENTE,;
				SE5TRB->E5_CLIFOR,;
				SE5TRB->E5_CLVLCR,;
				SE5TRB->E5_CLVLDB,;
				SE5TRB->E5_CNABOC,;
				SE5TRB->E5_CODORCA,;
				SE5TRB->E5_CONTA,;
				SE5TRB->E5_CREDITO,;
				SE5TRB->E5_DATA,;
				SE5TRB->E5_DEBITO,;
				SE5TRB->E5_DIACTB,;
				SE5TRB->E5_DOCUMEN,;
				SE5TRB->E5_DTCANBX,;
				SE5TRB->E5_DTDIGIT,;
				SE5TRB->E5_DTDISPO,;
				SE5TRB->E5_EDTPMS,;
				SE5TRB->E5_FATPREF,;
				SE5TRB->E5_FATURA,;
				SE5TRB->E5_FILIAL,;
				SE5TRB->E5_FILORIG,;
				SE5TRB->E5_FLDMED,;
				SE5TRB->E5_FORMAPG,;
				SE5TRB->E5_FORNADT,;
				SE5TRB->E5_FORNECE,;
				SE5TRB->E5_HISTOR,;
				SE5TRB->E5_IDENTEE,;
				SE5TRB->E5_IDMOVI,;
				SE5TRB->E5_IDORIG,;
				SE5TRB->E5_ITEMC,;
				SE5TRB->E5_ITEMD,;
				SE5TRB->E5_KEY,;
				SE5TRB->E5_LA,;
				SE5TRB->E5_LOGALT,;
				SE5TRB->E5_LOJA,;
				SE5TRB->E5_LOJAADT,;
				SE5TRB->E5_LOTE,;
				SE5TRB->E5_MODSPB,;
				SE5TRB->E5_MOEDA,;
				SE5TRB->E5_MOTBX,;
				SE5TRB->E5_MOVCX,;
				SE5TRB->E5_MOVFKS,;
				SE5TRB->E5_MULTNAT,;
				SE5TRB->E5_NATUREZ,;
				SE5TRB->E5_NODIA,;
				SE5TRB->E5_NUMCHEQ,;
				SE5TRB->E5_NUMERO,;
				SE5TRB->E5_NUMMOV,;
				SE5TRB->E5_OK,;
				SE5TRB->E5_OPERAD,;
				SE5TRB->E5_ORDREC,;
				SE5TRB->E5_ORIGEM,;
				SE5TRB->E5_PARCELA,;
				SE5TRB->E5_PREFIXO,;
				SE5TRB->E5_PRETCOF,;
				SE5TRB->E5_PRETCSL,;
				SE5TRB->E5_PRETINS,;
				SE5TRB->E5_PRETIRF,;
				SE5TRB->E5_PRETPIS,;
				TRANSFORM(SE5TRB->E5_PRINSS,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_PRISS,"@E 9,999,999.99"),;
				SE5TRB->E5_PROCTRA,;
				SE5TRB->E5_PROJPMS,;
				SE5TRB->E5_RATEIO,;
				SE5TRB->E5_RECONC,;
				SE5TRB->E5_RECPAG,;
				SE5TRB->E5_SDOCREC,;
				SE5TRB->E5_SEQ,;
				SE5TRB->E5_SEQCON,;
				SE5TRB->E5_SERREC,;
				SE5TRB->E5_SITCOB,;
				SE5TRB->E5_SITUA,;
				SE5TRB->E5_SITUACA,;
				SE5TRB->E5_TABORI,;
				SE5TRB->E5_TASKPMS,;
				SE5TRB->E5_TIPO,;
				SE5TRB->E5_TIPODOC,;
				SE5TRB->E5_TIPOLAN,;
				SE5TRB->E5_TPDESC,;
				SE5TRB->E5_TXMOEDA,;
				TRANSFORM(SE5TRB->E5_VALOR,"@E 9,999,999.99"),;
				SE5TRB->E5_VENCTO,;
				TRANSFORM(SE5TRB->E5_VLACRES,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VLCORRE,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VLDECRE,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VLDESCO,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VLJUROS,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VLMOED2,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VLMULTA,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VRETCOF,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VRETCSL,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VRETINS,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VRETIRF,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VRETISS,"@E 9,999,999.99"),;
				TRANSFORM(SE5TRB->E5_VRETPIS,"@E 9,999,999.99"),;
				SE5TRB->R_E_C_D_E_,;
				SE5TRB->R_E_C_N_O_,;
				SE5TRB->WDELETE,;
				SE5TRB->WRECNO;
				})

			SE5TRB->(dbskip())
		EndDo
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexao com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()

		//TMS - 25/02/2020
		SE5TRB->(DbCloseArea())

	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SD1                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If mv_par07 = 1
		// TMS - 25/02/2020 - Incluido como private para considerar o bloco de registros da SE5
		cArquivo    := GetTempPath()+Alltrim( RetSQLName("SD1") )+"_ENTRADAS_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".xml"
		cPlanImp :="SD1"
		cTitPlan :="Registros do SD1"
		//RRP - 16/03/2017 - Exportar Tabela SD1
		cCampos:= ""
		cQueCpo:= ""

		/*If Select('CPOSD1') > 0
 		CPOSD1->(DbCloseArea())
		Endif

		cQueCpo:= "SELECT 'SD1.'+COLUNA.name AS NOME" + CRLF
		cQueCpo+= "  FROM syscolumns COLUNA" + CRLF
		cQueCpo+= " INNER JOIN sysobjects TABELA on COLUNA.id = TABELA.id" + CRLF
		cQueCpo+= " WHERE TABELA.name = '"+RetSqlName("SD1")+"'" + CRLF
		cQueCpo+= "   AND COLUNA.name NOT IN ('D1_USERLGI', 'D1_USERLGA')" + CRLF
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueCpo),"CPOSD1",.T.,.T.) 
	
		CPOSD1->(DbGoTop())
		cCampos:= Alltrim(CPOSD1->NOME)
		CPOSD1->(DbSkip()) 
		While CPOSD1->(!Eof())
		cCampos+= ","+Alltrim(CPOSD1->NOME)
		CPOSD1->(DbSkip()) 
		EndDo		

		If Select('SD1TRB') > 0
			CPOSD1->(DbCloseArea())
		EndIf*/

		If Select('SD1TRB') > 0
			(SD1TRB)->(DbCloseArea())
		Endif

		//CAS - 29/03/2017 - Imputacao dos campos manualemnte.
		cCampos := " D1_FILIAL,D1_ITEM,D1_COD,D1_UM,D1_SEGUM,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALIPI,D1_VALICM,D1_TES,D1_CF,D1_DESC,D1_IPI,D1_PICM,D1_PESO,D1_CONTA" + CRLF
		cCampos += ",D1_ITEMCTA,D1_CC,D1_OP,D1_PEDIDO,D1_ITEMPC,D1_FORNECE,D1_LOJA,D1_LOCAL,D1_DOC,D1_EMISSAO,D1_DTDIGIT,D1_GRUPO,D1_TIPO,D1_SERIE,D1_CUSTO2" + CRLF
		cCampos += ",D1_CUSTO3,D1_CUSTO4,D1_CUSTO5,D1_TP,D1_QTSEGUM,D1_NUMSEQ,D1_DATACUS,D1_NFORI,D1_SERIORI,D1_ITEMORI,D1_QTDEDEV,D1_VALDEV,D1_ORIGLAN,D1_ICMSRET" + CRLF
		cCampos += ",D1_BRICMS,D1_NUMCQ,D1_DATORI,D1_BASEICM,D1_VALDESC,D1_LOTEFOR,D1_BASEIPI,D1_SEQCALC,D1_DTVALID,D1_NUMPV,D1_ITEMPV,D1_CODCIAP,D1_CLASFIS" + CRLF
		cCampos += ",D1_BASIMP1,D1_REMITO,D1_SERIREM,D1_CUSTO,D1_BASIMP3,D1_BASIMP4,D1_BASIMP5,D1_BASIMP6,D1_VALIMP1,D1_VALIMP2,D1_VALIMP3,D1_VALIMP4,D1_VALIMP5" + CRLF
		cCampos += ",D1_VALIMP6,D1_CBASEAF,D1_ICMSCOM,D1_CIF,D1_ITEMREM,D1_BASIMP2,D1_TIPO_NF,D1_ALQIMP1,D1_ALQIMP2,D1_ALQIMP3,D1_ALQIMP4,D1_ALQIMP5,D1_ALQIMP6" + CRLF
		cCampos += ",D1_QTDPEDI,D1_VALFRE,D1_RATEIO,D1_SEGURO,D1_DESPESA,D1_BASEIRR,D1_ALIQIRR,D1_VALIRR,D1_BASEISS,D1_ALIQISS,D1_VALISS,D1_BASEINS,D1_ALIQINS" + CRLF
		cCampos += ",D1_VALINS,D1_CUSORI,D1_CLVL,D1_ORDEM,D1_SERVIC,D1_STSERV,D1_ENDER,D1_TPESTR,D1_LOCPAD,D1_TIPODOC,D1_POTENCI,D1_TRT,D1_VALCSLL,D1_CODISS" + CRLF
		cCampos += ",D1_DESCICM,D1_BASEPS3,D1_ALIQPS3,D1_VALPS3,D1_BASECF3,D1_ALIQCF3,D1_VALCF3,D1_NUMDESP,D1_ORIGEM,D1_ITEMGRD,D1_PRUNDA,D1_CFPS,D1_BASESES" + CRLF
		cCampos += ",D1_VALSES,D1_ALIQSES,D1_RGESPST,D1_ABATISS,D1_ABATMAT,D1_VALFDS,D1_PRFDSUL,D1_UFERMS,D1_ESTCRED,D1_CRPRSIM,D1_VALANTI,D1_ICMSDIF,D1_GARANTI" + CRLF
		cCampos += ",D1_ALIQSOL,D1_CRPRESC,D1_ICMNDES,D1_BASNDES,D1_ALIQII,D1_NFVINC,D1_SERVINC,D1_ITMVINC,D1_MARGEM,D1_SLDDEP,D1_DIM,D1_DFABRIC,D1_BASEFAB" + CRLF
		cCampos += ",D1_ALIQFAB,D1_VALFAB,D1_BASEFAC,D1_ALIQFAC,D1_VALFAC,D1_BASEFET,D1_ALIQFET,D1_VALFET,D1_ABATINS,D1_CODLAN,D1_AVLINSS,D1_BASEFUN,D1_ALIQFUN" + CRLF
		cCampos += ",D1_VALFUN,D1_VALINA,D1_BASEINA,D1_ALIQINA,D1_VLINCMG,D1_PRINCMG,D1_CRPREPR,D1_CODBAIX,D1_TNATREC,D1_CNATREC,D1_GRUPONC,D1_DTFIMNT,D1_VALCSL" + CRLF
		cCampos += ",D1_ALQPIS,D1_ALQCOF,D1_ALQCSL,D1_OKISS,D1_VALCOF,D1_BASECOF,D1_BASECSL,D1_QTDCONF,D1_BASEPIS,D1_CONBAR,D1_CUSRP4,D1_VALPIS,D1_BASECID" + CRLF
		cCampos += ",D1_ALQCIDE,D1_VALCPM,D1_BASECPM,D1_ALQCPM,D1_CODFIS,D1_FILORI,D1_DESCZFR,D1_DESCZFP,D1_DESCZFC,D1_GRPCST,D1_BASECPB,D1_VALCPB,D1_ALIQCPB" + CRLF
		cCampos += ",D1_DIFAL,D1_PDORI,D1_PDDES,D1_ALFCCMP,D1_ALIQCMP,D1_BASEDES,D1_VFCPDIF,D1_P_NUMFL,D1_P_FORPG,D1_P_DTPRO,D1_P_TPDOC,D1_P_NDOC,D1_P_CCONT" + CRLF
		cCampos += ",D1_P_TPTRA,D1_P_IDPRO,D1_FTRICMS,D1_VRDICMS,D1_VALFUND,D1_BASFUND,D1_ALIFUND,D1_VALFASE,D1_BASFASE,D1_ALIFASE,D1_VLSLXML,D1_CSOSN,D1_BASEINP " + CRLF
		cCampos += ",D1_PERCINP,D1_VALINP,D1_ALQFECP,D1_VALFECP,D1_VFECPST "

		//cAliasSD1 := GetNextAlias()
		cQuery 		:= "SELECT "+cCampos+" "  + CRLF
		cQuery 		+= "FROM "+RetSQLName("SD1")+" SD1 " + CRLF
		cQuery 		+= "WHERE SD1.D_E_L_E_T_ <> '*' "   + CRLF
		If !Empty(mv_par09).OR.!Empty(mv_par10)
			cQuery 		+= " AND SD1.D1_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "  + CRLF
		EndIf
		If !Empty(MV_PAR01).OR.!Empty(MV_PAR02)
			cQuery 		+= " AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "  + CRLF
		EndIf

		TCQuery cQuery New Alias "SD1TRB" //TMS - 25/02/2020
		TCSetField("SD1TRB","D1_EMISSAO","D",8,0)
		TCSetField("SD1TRB","D1_DTDIGIT","D",8,0)
		TCSetField("SD1TRB","D1_DATACUS","D",8,0)
		TCSetField("SD1TRB","D1_DATORI","D",8,0)
		TCSetField("SD1TRB","D1_DTVALID","D",8,0)
		TCSetField("SD1TRB","D1_DFABRIC","D",8,0)
		TCSetField("SD1TRB","D1_DTFIMNT","D",8,0)
		TCSetField("SD1TRB","D1_P_DTPRO","D",8,0)

		/*dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
	
		DbSelectArea(cAliasSD1)
		DbGotop()         
   	
   		SX3->(DbSetOrder(2))
   	
		_aStru := (cAliasSD1)->(DbStruct())
		nQ := Len(_aStru)
		nI := 1
	For nI := 1 to nQ
		If SX3->(DbSeek(_aStru[nI][1],.F.))
			If SX3->X3_TIPO == "D"
	    		_aStru[nI][2] := "D"
			Endif
		Endif
		_aRet := TamSX3(_aStru[nI,1])
		If Len(_aRet) > 0
 			_aStru[nI,3] := _aRet[01]
			_aStru[nI,4] := _aRet[02]
		Endif
		AADD(aArqDbf,{_aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4]})
	Next
    
		cArqDBF := CriaTrab(NIL,.F.)
		dbCreate(cArqDBF,aArqDBF,"DBFCDXADS")
		dbUseArea(.T.,"DBFCDXADS",cArqDBF,"TRB",.T.,.F.) 
		DbSelectArea("TRB")
                                
		dbSelectArea(cAliasSD1)
	While !Eof()
		aRegTRB := {}
		For i := 1 To FCount()
			Aadd( aRegTRB , (FieldGet( i ))) 
		Next i
			
		DbSelectArea("TRB")
		RecLock('TRB',.T.)
		For i := 1 To Len( aRegTRB )
			If aArqDbf[i][2] == "D"
				FieldPut( i , Stod(aRegTRB[ i ]) )
			Elseif aArqDbf[i][2] == "N"
				FieldPut( i , NoRound(aRegTRB[ i ],2) )
			Else
				FieldPut( i , aRegTRB[ i ] )
			Endif
		Next
		MSUnlock() 

		dbSelectArea(cAliasSD1)
		DbSkip()
	End

	If Select('cAliasSD1') > 0
		(cAliasSD1)->(DbCloseArea()) 
	Endif
	
		dbSelectArea(cAliasSD1)
	
    	oProcess:SetRegua1( (cAliasSD1)->(RecCount()) )
    	oProcess:IncRegua1("Exportando arquivo SD1")
		_cArqDBF	:= Alltrim( RetSQLName("SD1") )+"_ENTRADAS_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
		_cDirLocal	:= __cDiretorio + _cArqDBF

		DbSelectArea("TRB")
		DbCloseArea()
		__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
		(cAliasSD1)->(DbCloseArea())
		FErase(_cArqDBF)Excluir arquivo
		FErase(cArqDBF)  Excluir arquivo*/

		//Criando o objeto que ira gerar o conteudo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba 01
		oFWMsExcel:AddworkSheet(cPlanImp) //Nao utilizar numero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
			oFWMsExcel:AddTable(cPlanImp,cTitPlan)
		//Criando Colunas
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_FILIAL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_COD",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_UM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SEGUM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_QUANT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VUNIT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TOTAL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIPI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALICM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DESC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_IPI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PICM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PESO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CONTA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEMCTA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_OP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PEDIDO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEMPC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_FORNECE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_LOJA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_LOCAL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DOC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_EMISSAO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DTDIGIT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_GRUPO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TIPO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SERIE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSTO2",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSTO3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSTO4",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSTO5",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_QTSEGUM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_NUMSEQ",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DATACUS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_NFORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SERIORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEMORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_QTDEDEV",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALDEV",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ORIGLAN",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ICMSRET",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BRICMS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_NUMCQ",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DATORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEICM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALDESC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_LOTEFOR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEIPI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SEQCALC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DTVALID",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_NUMPV",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEMPV",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CODCIAP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CLASFIS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASIMP1",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_REMITO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SERIREM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSTO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASIMP3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASIMP4",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASIMP5",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASIMP6",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIMP1",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIMP2",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIMP3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIMP4",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIMP5",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIMP6",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CBASEAF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ICMSCOM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CIF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEMREM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASIMP2",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TIPO_NF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQIMP1",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQIMP2",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQIMP3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQIMP4",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQIMP5",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQIMP6",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_QTDPEDI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFRE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_RATEIO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SEGURO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DESPESA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEIRR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQIRR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALIRR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEISS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQISS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALISS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEINS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQINS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALINS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CLVL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ORDEM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SERVIC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_STSERV",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ENDER",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TPESTR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_LOCPAD",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TIPODOC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_POTENCI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TRT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALCSLL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CODISS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DESCICM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEPS3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQPS3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALPS3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASECF3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQCF3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALCF3",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_NUMDESP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ORIGEM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITEMGRD",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PRUNDA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CFPS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASESES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALSES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQSES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_RGESPST",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ABATISS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ABATMAT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFDS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PRFDSUL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_UFERMS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ESTCRED",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CRPRSIM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALANTI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ICMSDIF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_GARANTI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQSOL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CRPRESC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ICMNDES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASNDES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQII",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_NFVINC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SERVINC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ITMVINC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_MARGEM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_SLDDEP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DIM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DFABRIC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEFAB",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQFAB",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFAB",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEFAC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQFAC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFAC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEFET",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQFET",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFET",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ABATINS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CODLAN",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_AVLINSS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEFUN",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQFUN",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFUN",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALINA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEINA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQINA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VLINCMG",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PRINCMG",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CRPREPR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CODBAIX",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_TNATREC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CNATREC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_GRUPONC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DTFIMNT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALCSL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQPIS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQCOF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQCSL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_OKISS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALCOF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASECOF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASECSL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_QTDCONF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEPIS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CONBAR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CUSRP4",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALPIS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASECID",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQCIDE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALCPM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASECPM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQCPM",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CODFIS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_FILORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DESCZFR",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DESCZFP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DESCZFC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_GRPCST",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASECPB",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALCPB",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQCPB",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_DIFAL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PDORI",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PDDES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALFCCMP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIQCMP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEDES",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VFCPDIF",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_NUMFL",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_FORPG",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_DTPRO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_TPDOC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_NDOC",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_CCONT",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_TPTRA",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_P_IDPRO",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_FTRICMS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VRDICMS",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFUND",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASFUND",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIFUND",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFASE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASFASE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALIFASE",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VLSLXML",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_CSOSN",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_BASEINP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_PERCINP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALINP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_ALQFECP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VALFECP",1)
			oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D1_VFECPST",1)

			SD1TRB->(dbGoTop())
			Do while SD1TRB->(!Eof())

			oFWMsExcel:AddRow(cPlanImp,cTitPlan,{SD1TRB->D1_FILIAL,;
				SD1TRB->D1_ITEM,;
				SD1TRB->D1_COD,;
				SD1TRB->D1_UM,;
				SD1TRB->D1_SEGUM,;
				SD1TRB->D1_QUANT,;				
				TRANSFORM(SD1TRB->D1_VUNIT,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_TOTAL,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIPI,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALICM,"@E 9,999,999.99"),;
				SD1TRB->D1_TES,;
				SD1TRB->D1_CF,;
				TRANSFORM(SD1TRB->D1_DESC,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_IPI,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_PICM,"@E 9,999,999.99"),;
				SD1TRB->D1_PESO,;
				SD1TRB->D1_CONTA,;
				SD1TRB->D1_ITEMCTA,;
				SD1TRB->D1_CC,;
				SD1TRB->D1_OP ,;
				SD1TRB->D1_PEDIDO,;
				SD1TRB->D1_ITEMPC,;
				SD1TRB->D1_FORNECE,;
				SD1TRB->D1_LOJA,;
				SD1TRB->D1_LOCAL,;
				SD1TRB->D1_DOC,;
				SD1TRB->D1_EMISSAO,;
				SD1TRB->D1_DTDIGIT,;
				SD1TRB->D1_GRUPO,;
				SD1TRB->D1_TIPO,;
				SD1TRB->D1_SERIE,;
				TRANSFORM(SD1TRB->D1_CUSTO2,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CUSTO3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CUSTO4,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CUSTO5,"@E 9,999,999.99"),;
				SD1TRB->D1_TP,;
				TRANSFORM(SD1TRB->D1_QTSEGUM,"@E 9,999,999.99"),;
				SD1TRB->D1_NUMSEQ,;
				SD1TRB->D1_DATACUS,;
				SD1TRB->D1_NFORI,;
				SD1TRB->D1_SERIORI,;
				SD1TRB->D1_ITEMORI,;
				SD1TRB->D1_QTDEDEV,;
				TRANSFORM(SD1TRB->D1_VALDEV,"@E 9,999,999.99"),;
				SD1TRB->D1_ORIGLAN,;
				TRANSFORM(SD1TRB->D1_ICMSRET,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BRICMS,"@E 9,999,999.99"),;
				SD1TRB->D1_NUMCQ,;
				SD1TRB->D1_DATORI,;
				TRANSFORM(SD1TRB->D1_BASEICM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALDESC,"@E 9,999,999.99"),;
				SD1TRB->D1_LOTEFOR,;
				TRANSFORM(SD1TRB->D1_BASEIPI,"@E 9,999,999.99"),;
				SD1TRB->D1_SEQCALC,;
				SD1TRB->D1_DTVALID,;
				SD1TRB->D1_NUMPV,;
				SD1TRB->D1_ITEMPV,;
				SD1TRB->D1_CODCIAP,;
				SD1TRB->D1_CLASFIS,;
				TRANSFORM(SD1TRB->D1_BASIMP1,"@E 9,999,999.99"),;
				SD1TRB->D1_REMITO,;
				SD1TRB->D1_SERIREM,;
				TRANSFORM(SD1TRB->D1_CUSTO,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASIMP3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASIMP4,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASIMP5,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASIMP6,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIMP1,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIMP2,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIMP3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIMP4,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIMP5,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIMP6,"@E 9,999,999.99"),;
				SD1TRB->D1_CBASEAF,;
				TRANSFORM(SD1TRB->D1_ICMSCOM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CIF,"@E 9,999,999.99"),;
				SD1TRB->D1_ITEMREM,;
				TRANSFORM(SD1TRB->D1_BASIMP2,"@E 9,999,999.99"),;
				SD1TRB->D1_TIPO_NF,;
				TRANSFORM(SD1TRB->D1_ALQIMP1,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQIMP2,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQIMP3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQIMP4,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQIMP5,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQIMP6,"@E 9,999,999.99"),;
				SD1TRB->D1_QTDPEDI,;
				TRANSFORM(SD1TRB->D1_VALFRE,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_RATEIO,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_SEGURO,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_DESPESA,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEIRR,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQIRR,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALIRR,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEISS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQISS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALISS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEINS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQINS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALINS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CUSORI,"@E 9,999,999.99"),;
				SD1TRB->D1_CLVL,;
				SD1TRB->D1_ORDEM,;
				SD1TRB->D1_SERVIC,;
				SD1TRB->D1_STSERV,;
				SD1TRB->D1_ENDER,;
				SD1TRB->D1_TPESTR,;
				SD1TRB->D1_LOCPAD,;
				SD1TRB->D1_TIPODOC,;
				TRANSFORM(SD1TRB->D1_POTENCI,"@E 9,999,999.99"),;
				SD1TRB->D1_TRT,;
				TRANSFORM(SD1TRB->D1_VALCSLL,"@E 9,999,999.99"),;
				SD1TRB->D1_CODISS,;
				TRANSFORM(SD1TRB->D1_DESCICM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEPS3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQPS3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALPS3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASECF3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQCF3,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALCF3,"@E 9,999,999.99"),;
				SD1TRB->D1_NUMDESP,;
				SD1TRB->D1_ORIGEM,;
				SD1TRB->D1_ITEMGRD,;
				TRANSFORM(SD1TRB->D1_PRUNDA,"@E 9,999,999.99"),;
				SD1TRB->D1_CFPS,;
				TRANSFORM(SD1TRB->D1_BASESES,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALSES,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQSES,"@E 9,999,999.99"),;
				SD1TRB->D1_RGESPST,;
				TRANSFORM(SD1TRB->D1_ABATISS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ABATMAT,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFDS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_PRFDSUL,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_UFERMS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ESTCRED,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CRPRSIM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALANTI,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ICMSDIF,"@E 9,999,999.99"),;
				SD1TRB->D1_GARANTI,;
				SD1TRB->D1_ALIQSOL,;
				TRANSFORM(SD1TRB->D1_CRPRESC,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ICMNDES,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASNDES,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQII,"@E 9,999,999.99"),;
				SD1TRB->D1_NFVINC,;
				SD1TRB->D1_SERVINC,;
				SD1TRB->D1_ITMVINC,;
				TRANSFORM(SD1TRB->D1_MARGEM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_SLDDEP,"@E 9,999,999.99"),;
				SD1TRB->D1_DIM,;
				SD1TRB->D1_DFABRIC,;
				TRANSFORM(SD1TRB->D1_BASEFAB,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQFAB,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFAB,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEFAC,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQFAC,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFAC,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEFET,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQFET,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFET,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ABATINS,"@E 9,999,999.99"),;
				SD1TRB->D1_CODLAN,;
				TRANSFORM(SD1TRB->D1_AVLINSS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEFUN,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQFUN,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFUN,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALINA,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASEINA,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQINA,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VLINCMG,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_PRINCMG,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_CRPREPR,"@E 9,999,999.99"),;
				SD1TRB->D1_CODBAIX,;
				SD1TRB->D1_TNATREC,;
				SD1TRB->D1_CNATREC,;
				SD1TRB->D1_GRUPONC,;
				SD1TRB->D1_DTFIMNT,;
				TRANSFORM(SD1TRB->D1_VALCSL,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQPIS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQCOF,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQCSL,"@E 9,999,999.99"),;
				SD1TRB->D1_OKISS,;
				TRANSFORM(SD1TRB->D1_VALCOF,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASECOF,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASECSL,"@E 9,999,999.99"),;
				SD1TRB->D1_QTDCONF,;
				TRANSFORM(SD1TRB->D1_BASEPIS,"@E 9,999,999.99"),;
				SD1TRB->D1_CONBAR,;
				TRANSFORM(SD1TRB->D1_CUSRP4,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALPIS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASECID,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQCIDE,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALCPM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASECPM,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQCPM,"@E 9,999,999.99"),;
				SD1TRB->D1_CODFIS,;
				SD1TRB->D1_FILORI,;
				TRANSFORM(SD1TRB->D1_DESCZFR,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_DESCZFP,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_DESCZFC,"@E 9,999,999.99"),;
				SD1TRB->D1_GRPCST,;
				SD1TRB->D1_BASECPB,;
				TRANSFORM(SD1TRB->D1_VALCPB,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIQCPB,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_DIFAL,"@E 9,999,999.99"),;
				SD1TRB->D1_PDORI,;
				SD1TRB->D1_PDDES,;
				SD1TRB->D1_ALFCCMP,;
				SD1TRB->D1_ALIQCMP,;
				TRANSFORM(SD1TRB->D1_BASEDES,"@E 9,999,999.99"),;
				SD1TRB->D1_VFCPDIF,;
				SD1TRB->D1_P_NUMFL,;
				SD1TRB->D1_P_FORPG,;
				SD1TRB->D1_P_DTPRO,;
				SD1TRB->D1_P_TPDOC,;
				SD1TRB->D1_P_NDOC,;
				SD1TRB->D1_P_CCONT,;
				SD1TRB->D1_P_TPTRA,;
				SD1TRB->D1_P_IDPRO,;
				TRANSFORM(SD1TRB->D1_FTRICMS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VRDICMS,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFUND,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASFUND,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIFUND,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFASE,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_BASFASE,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALIFASE,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VLSLXML,"@E 9,999,999.99"),;
				SD1TRB->D1_CSOSN,;
				TRANSFORM(SD1TRB->D1_BASEINP,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_PERCINP,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALINP,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_ALQFECP,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VALFECP,"@E 9,999,999.99"),;
				TRANSFORM(SD1TRB->D1_VFECPST,"@E 9,999,999.99");
				})

			SD1TRB->(dbskip())
		EndDo
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexao com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()

		//TMS - 25/02/2020
		SD1TRB->(DbCloseArea())

	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SD2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If mv_par08 = 1
		cArquivo    := GetTempPath()+Alltrim( RetSQLName("SD2") )+"_SAIDAS_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".xml"
		cPlanImp :="SD2"
		cTitPlan :="Registros do SD2"
		//RRP - 16/03/2017 - Exportar Tabela SD1
		cCampos:= ""
		cQueCpo:= ""
		

		//RRP - 17/03/2017 - Exportar Tabela SD2

	/*
	If Select('CPOSD2') > 0
 		CPOSD2->(DbCloseArea())
	Endif

	cQueCpo:= "SELECT 'SD2.'+COLUNA.name AS NOME" + CRLF
	cQueCpo+= "  FROM syscolumns COLUNA" + CRLF
	cQueCpo+= " INNER JOIN sysobjects TABELA on COLUNA.id = TABELA.id" + CRLF
	cQueCpo+= " WHERE TABELA.name = '"+RetSqlName("SD2")+"'" + CRLF
	cQueCpo+= "   AND COLUNA.name NOT IN ('D2_USERLGI', 'D2_USERLGA')" + CRLF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueCpo),"CPOSD2",.T.,.T.) 
	
	CPOSD2->(DbGoTop())
	cCampos:= Alltrim(CPOSD2->NOME)
	CPOSD2->(DbSkip()) 
	While CPOSD2->(!Eof())
		cCampos+= ","+Alltrim(CPOSD2->NOME)
		CPOSD2->(DbSkip()) 
	EndDo*/

		If Select('SD2TRB') > 0
		(SD2TRB)->(DbCloseArea())
		Endif

		If Select('SD2TRB') > 0
		SD2TRB->(DbCloseArea())
		EndIf

		//CAS - 29/03/2017 - Imputacao dos campos manualemnte.
		cCampos := " D2_FILIAL,D2_ITEM,D2_COD,D2_UM,D2_SEGUM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_VALIPI,D2_VALICM,D2_TES,D2_CF,D2_DESC,D2_IPI,D2_PICM,D2_PESO,D2_CONTA" + CRLF
		cCampos += ",D2_OP,D2_PEDIDO,D2_ITEMPV,D2_CLIENTE,D2_LOJA,D2_LOCAL,D2_DOC,D2_SERIE,D2_GRUPO,D2_TP,D2_EMISSAO,D2_CUSTO1,D2_CUSTO2,D2_CUSTO3,D2_CUSTO4" + CRLF
		cCampos += ",D2_CUSTO5,D2_PRUNIT,D2_QTSEGUM,D2_NUMSEQ,D2_EST,D2_DESCON,D2_TIPO,D2_NFORI,D2_SERIORI,D2_QTDEDEV,D2_VALDEV,D2_ORIGLAN,D2_BRICMS,D2_BASEORI" + CRLF
		cCampos += ",D2_BASEICM,D2_VALACRS,D2_IDENTB6,D2_CODISS,D2_GRADE,D2_SEQCALC,D2_ICMSRET,D2_LOTECTL,D2_NUMLOTE,D2_DTVALID,D2_CUSFF1,D2_CUSFF2,D2_CUSFF3" + CRLF
		cCampos += ",D2_CUSFF4,D2_CUSFF5,D2_CLASFIS,D2_BASIMP1,D2_SERIREM,D2_BASIMP2,D2_BASIMP3,D2_ITEMREM,D2_BASIMP4,D2_BASIMP5,D2_BASIMP6,D2_VALIMP1,D2_VALIMP2" + CRLF
		cCampos += ",D2_VALIMP3,D2_VALIMP4,D2_VALIMP5,D2_VALIMP6,D2_ITEMORI,D2_ALQIMP1,D2_ALQIMP2,D2_ALQIMP3,D2_ALQIMP4,D2_ALQIMP5,D2_ALQIMP6,D2_CCUSTO,D2_ITEMCC" + CRLF
		cCampos += ",D2_ENVCNAB,D2_ALIQINS,D2_PREEMB,D2_ALIQISS,D2_BASEIPI,D2_BASEISS,D2_VALISS,D2_VALFRE,D2_TPDCENV,D2_DESPESA,D2_OK,D2_ENDER,D2_CLVL,D2_BASEINS" + CRLF
		cCampos += ",D2_ICMFRET,D2_SERVIC,D2_STSERV,D2_VALINS,D2_VARPRUN,D2_TIPODOC,D2_VAC,D2_TIPOREM,D2_QTDEFAT,D2_QTDAFAT,D2_SEQUEN,D2_POTENCI,D2_DESCICM" + CRLF
		cCampos += ",D2_BASEPS3,D2_ALIQPS3,D2_VALPS3,D2_BASECF3,D2_ALIQCF3,D2_VALCF3,D2_ABSCINS,D2_VALBRUT,D2_DTDIGIT,D2_NUMCP,D2_ESTCRED,D2_BASEIRR,D2_BASETST" + CRLF
		cCampos += ",D2_ALIQTST,D2_VALTST,D2_CODROM,D2_ALIQSOL,D2_ALSENAR,D2_VALINA,D2_BASEINA,D2_ALIQINA,D2_VLINCMG,D2_PRINCMG,D2_TNATREC,D2_CNATREC,D2_GRUPONC" + CRLF
		cCampos += ",D2_DTFIMNT,D2_BASEPIS,D2_BASECOF,D2_BASECSL,D2_VALPIS,D2_VALCOF,D2_VALCSL,D2_ALQPIS,D2_ALQCOF,D2_ALQCSL,D2_CBASEAF,D2_VREINT,D2_BSREIN" + CRLF
		cCampos += ",D2_CUSRP1,D2_CUSRP2,D2_CUSRP3,D2_CUSRP4,D2_CUSRP5,D2_VALIRRF,D2_ALQIRRF,D2_ORDSEP,D2_RATEIO,D2_CODLPRE,D2_ITLPRE,D2_OKISS,D2_VCAT156" + CRLF
		cCampos += ",D2_VLIMPOR,D2_FCICOD,D2_09CAT17,D2_16CAT17,D2_TOTIMP,D2_IDCFC,D2_TOTFED,D2_TOTEST,D2_TOTMUN,D2_VALCPM,D2_BASECPM,D2_ALQCPM,D2_VALFMP" + CRLF
		cCampos += ",D2_BASEFMP,D2_ALQFMP,D2_BASEFMD,D2_ALQFMD,D2_VALFMD,D2_ESPECIE,D2_SITTRIB,D2_NFCUP,D2_ESTOQUE,D2_REVISAO,D2_GRPCST,D2_BASECPB,D2_VALCPB" + CRLF
		cCampos += ",D2_ALIQCPB,D2_ICMSCOM,D2_DIFAL,D2_PDORI,D2_PDDES,D2_ALFCCMP,D2_ALIQCMP,D2_BASEDES,D2_VFCPDIF" + CRLF
		cCampos += ",D_E_L_E_T_ WDELETE, R_E_C_N_O_ WRECNO "

		//cAliasSD2 := GetNextAlias()
		cQuery 		:= "SELECT "+cCampos+" "  + CRLF
		cQuery 		+= "FROM "+RetSQLName("SD2")+" SD2 "  + CRLF
		cQuery 		+= "WHERE "   + CRLF
		If !Empty(mv_par09).OR.!Empty(mv_par10)
		cQuery 		+= "     SD2.D2_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "  + CRLF
		EndIf
		If !Empty(MV_PAR01).OR.!Empty(MV_PAR02)
		cQuery 		+= " AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "  + CRLF
		EndIf

		TCQuery cQuery New Alias "SD2TRB" //TMS - 25/02/2020

		TCSetField("SD2TRB","D2_EMISSAO","D",8,0)
		TCSetField("SD2TRB","D2_DTVALID","D",8,0)
		TCSetField("SD2TRB","D2_ENVCNAB","D",8,0)
		TCSetField("SD2TRB","D2_DTDIGIT","D",8,0)
		TCSetField("SD2TRB","D2_DTFIMNT","D",8,0)

	/*dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
	DbSelectArea(cAliasSD2)
	DbGotop()         
   	
   	SX3->(DbSetOrder(2))
   	
	_aStru := (cAliasSD2)->(DbStruct())
	nQ := Len(_aStru)
	nI := 1
	For nI := 1 to nQ
		If SX3->(DbSeek(_aStru[nI][1],.F.))
			If SX3->X3_TIPO == "D"
	    		_aStru[nI][2] := "D"
			Endif
		Endif
		_aRet := TamSX3(_aStru[nI,1])
		If Len(_aRet) > 0
 			_aStru[nI,3] := _aRet[01]
			_aStru[nI,4] := _aRet[02]
		Endif
		AADD(aArqDbf,{_aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4]})
	Next
    
	cArqDBF := CriaTrab(NIL,.F.)
	dbCreate(cArqDBF,aArqDBF,"DBFCDXADS")
	dbUseArea(.T.,"DBFCDXADS",cArqDBF,"TRB",.T.,.F.) 
	DbSelectArea("TRB")
                                
	dbSelectArea(cAliasSD2)
	While !Eof()
		aRegTRB := {}
		For i := 1 To FCount()
			Aadd( aRegTRB , (FieldGet( i ))) 
		Next i
			
		DbSelectArea("TRB")
		RecLock('TRB',.T.)
		For i := 1 To Len( aRegTRB )
			If aArqDbf[i][2] == "D"
				FieldPut( i , Stod(aRegTRB[ i ]) )
			Elseif aArqDbf[i][2] == "N"
				FieldPut( i , NoRound(aRegTRB[ i ],2) )
			Else
				FieldPut( i , aRegTRB[ i ] )
			Endif
		Next
		MSUnlock() 

		dbSelectArea(cAliasSD2)
		DbSkip()
	End

	If Select('cAliasSD2') > 0
		(cAliasSD2)->(DbCloseArea()) 
	Endif
	
	dbSelectArea(cAliasSD2)
	
    oProcess:SetRegua1( (cAliasSD2)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SD2")
	_cArqDBF	:= Alltrim( RetSQLName("SD2") )+"_SAIDAS_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF

	DbSelectArea("TRB")
	DbCloseArea()
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) )  Copia arquivos do servidor para o local especificado
	(cAliasSD2)->(DbCloseArea())
	FErase(_cArqDBF   Excluir arquivo 	 
	FErase(cArqDBF)  Excluir arquivo*/

		//Criando o objeto que ira gerar o conteudo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba 01
		oFWMsExcel:AddworkSheet(cPlanImp) //Nao utilizar numero junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable(cPlanImp,cTitPlan)
		//Criando Colunas
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_FILIAL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ITEM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_COD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_UM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SEGUM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_QUANT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PRCVEN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TOTAL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIPI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALICM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TES",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DESC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_IPI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PICM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PESO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CONTA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_OP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PEDIDO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ITEMPV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CLIENTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_LOJA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_LOCAL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DOC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SERIE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_GRUPO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_EMISSAO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSTO1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSTO2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSTO3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSTO4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSTO5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PRUNIT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_QTSEGUM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_NUMSEQ",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_EST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DESCON",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TIPO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_NFORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SERIORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_QTDEDEV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALDEV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ORIGLAN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BRICMS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEICM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALACRS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_IDENTB6",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CODISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_GRADE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SEQCALC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ICMSRET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_LOTECTL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_NUMLOTE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DTVALID",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSFF1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSFF2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSFF3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSFF4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSFF5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CLASFIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASIMP1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SERIREM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASIMP2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASIMP3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ITEMREM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASIMP4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASIMP5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASIMP6",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIMP1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIMP2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIMP3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIMP4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIMP5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIMP6",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ITEMORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIMP1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIMP2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIMP3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIMP4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIMP5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIMP6",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CCUSTO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ITEMCC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ENVCNAB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PREEMB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEIPI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALFRE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TPDCENV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DESPESA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_OK",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ENDER",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CLVL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ICMFRET",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SERVIC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_STSERV",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VARPRUN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TIPODOC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VAC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TIPOREM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_QTDEFAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_QTDAFAT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SEQUEN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_POTENCI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DESCICM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEPS3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQPS3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALPS3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASECF3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQCF3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALCF3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ABSCINS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALBRUT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DTDIGIT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_NUMCP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ESTCRED",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEIRR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASETST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQTST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALTST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CODROM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQSOL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALSENAR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALINA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEINA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQINA",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VLINCMG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PRINCMG",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TNATREC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CNATREC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_GRUPONC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DTFIMNT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASECOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASECSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQPIS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQCOF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQCSL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CBASEAF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VREINT",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BSREIN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSRP1",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSRP2",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSRP3",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSRP4",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CUSRP5",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALIRRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQIRRF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ORDSEP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_RATEIO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_CODLPRE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ITLPRE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_OKISS",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VCAT156",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VLIMPOR",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_FCICOD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_09CAT17",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_16CAT17",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TOTIMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_IDCFC",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TOTFED",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TOTEST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_TOTMUN",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALCPM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASECPM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQCPM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALFMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEFMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQFMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEFMD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALQFMD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALFMD",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ESPECIE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_SITTRIB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_NFCUP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ESTOQUE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_REVISAO",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_GRPCST",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASECPB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VALCPB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQCPB",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ICMSCOM",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_DIFAL",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PDORI",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_PDDES",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALFCCMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_ALIQCMP",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_BASEDES",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"D2_VFCPDIF",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WDELETE",1)
		oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"WRECNO",1)

		SD2TRB->(dbGoTop())
		Do while SD2TRB->(!Eof())

		oFWMsExcel:AddRow(cPlanImp,cTitPlan,{;
			SD2TRB->D2_FILIAL,;
			SD2TRB->D2_ITEM,;
			SD2TRB->D2_COD,;
			SD2TRB->D2_UM,;
			SD2TRB->D2_SEGUM,;
			SD2TRB->D2_QUANT,;
			TRANSFORM(SD2TRB->D2_PRCVEN,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_TOTAL,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIPI,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALICM,"@E 9,999,999.99"),;
			SD2TRB->D2_TES,;
			SD2TRB->D2_CF,;
			TRANSFORM(SD2TRB->D2_DESC,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_IPI,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_PICM,"@E 9,999,999.99"),;
			SD2TRB->D2_PESO,;
			SD2TRB->D2_CONTA,;
			SD2TRB->D2_OP,;
			SD2TRB->D2_PEDIDO,;
			SD2TRB->D2_ITEMPV,;
			SD2TRB->D2_CLIENTE,;
			SD2TRB->D2_LOJA,;
			SD2TRB->D2_LOCAL,;
			SD2TRB->D2_DOC,;
			SD2TRB->D2_SERIE,;
			SD2TRB->D2_GRUPO,;
			SD2TRB->D2_TP,;
			SD2TRB->D2_EMISSAO,;
			TRANSFORM(SD2TRB->D2_CUSTO1,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSTO2,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSTO3,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSTO4,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSTO5,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_PRUNIT,"@E 9,999,999.99"),;
			SD2TRB->D2_QTSEGUM,;
			SD2TRB->D2_NUMSEQ,;
			SD2TRB->D2_EST,;
			SD2TRB->D2_DESCON,;
			SD2TRB->D2_TIPO,;
			SD2TRB->D2_NFORI,;
			SD2TRB->D2_SERIORI,;
			SD2TRB->D2_QTDEDEV,;
			TRANSFORM(SD2TRB->D2_VALDEV,"@E 9,999,999.99"),;
			SD2TRB->D2_ORIGLAN,;
			TRANSFORM(SD2TRB->D2_BRICMS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASEORI,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASEICM,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALACRS,"@E 9,999,999.99"),;
			SD2TRB->D2_IDENTB6,;
			SD2TRB->D2_CODISS,;
			SD2TRB->D2_GRADE,;
			SD2TRB->D2_SEQCALC,;
			TRANSFORM(SD2TRB->D2_ICMSRET,"@E 9,999,999.99"),;
			SD2TRB->D2_LOTECTL,;
			SD2TRB->D2_NUMLOTE,;
			SD2TRB->D2_DTVALID,;
			TRANSFORM(SD2TRB->D2_CUSFF1,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSFF2,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSFF3,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSFF4,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSFF5,"@E 9,999,999.99"),;
			SD2TRB->D2_CLASFIS,;
			TRANSFORM(SD2TRB->D2_BASIMP1,"@E 9,999,999.99"),;
			SD2TRB->D2_SERIREM,;
			TRANSFORM(SD2TRB->D2_BASIMP2,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASIMP3,"@E 9,999,999.99"),;
			SD2TRB->D2_ITEMREM,;
			TRANSFORM(SD2TRB->D2_BASIMP4,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASIMP5,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASIMP6,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIMP1,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIMP2,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIMP3,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIMP4,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIMP5,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIMP6,"@E 9,999,999.99"),;
			SD2TRB->D2_ITEMORI,;
			SD2TRB->D2_ALQIMP1,;
			SD2TRB->D2_ALQIMP2,;
			SD2TRB->D2_ALQIMP3,;
			SD2TRB->D2_ALQIMP4,;
			SD2TRB->D2_ALQIMP5,;
			SD2TRB->D2_ALQIMP6,;
			SD2TRB->D2_CCUSTO,;
			SD2TRB->D2_ITEMCC,;
			SD2TRB->D2_ENVCNAB,;
			SD2TRB->D2_ALIQINS,;
			SD2TRB->D2_PREEMB,;
			SD2TRB->D2_ALIQISS,;
			TRANSFORM(SD2TRB->D2_BASEIPI,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASEISS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALISS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALFRE,"@E 9,999,999.99"),;
			SD2TRB->D2_TPDCENV,;
			TRANSFORM(SD2TRB->D2_DESPESA,"@E 9,999,999.99"),;
			SD2TRB->D2_OK,;
			SD2TRB->D2_ENDER,;
			SD2TRB->D2_CLVL,;
			TRANSFORM(SD2TRB->D2_BASEINS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_ICMFRET,"@E 9,999,999.99"),;
			SD2TRB->D2_SERVIC,;
			SD2TRB->D2_STSERV,;
			TRANSFORM(SD2TRB->D2_VALINS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VARPRUN,"@E 9,999,999.99"),;
			SD2TRB->D2_TIPODOC,;
			TRANSFORM(SD2TRB->D2_VAC,"@E 9,999,999.99"),;
			SD2TRB->D2_TIPOREM,;
			SD2TRB->D2_QTDEFAT,;
			SD2TRB->D2_QTDAFAT,;
			SD2TRB->D2_SEQUEN,;
			SD2TRB->D2_POTENCI,;
			TRANSFORM(SD2TRB->D2_DESCICM,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASEPS3,"@E 9,999,999.99"),;
			SD2TRB->D2_ALIQPS3,;
			TRANSFORM(SD2TRB->D2_VALPS3,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASECF3,"@E 9,999,999.99"),;
			SD2TRB->D2_ALIQCF3,;
			TRANSFORM(SD2TRB->D2_VALCF3,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_ABSCINS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALBRUT,"@E 9,999,999.99"),;
			SD2TRB->D2_DTDIGIT,;
			SD2TRB->D2_NUMCP,;
			SD2TRB->D2_ESTCRED,;
			SD2TRB->D2_BASEIRR,;
			TRANSFORM(SD2TRB->D2_BASETST,"@E 9,999,999.99"),;
			SD2TRB->D2_ALIQTST,;
			TRANSFORM(SD2TRB->D2_VALTST,"@E 9,999,999.99"),;
			SD2TRB->D2_CODROM,;
			SD2TRB->D2_ALIQSOL,;
			SD2TRB->D2_ALSENAR,;
			SD2TRB->D2_VALINA,;
			SD2TRB->D2_BASEINA,;
			SD2TRB->D2_ALIQINA,;
			SD2TRB->D2_VLINCMG,;
			SD2TRB->D2_PRINCMG,;
			SD2TRB->D2_TNATREC,;
			SD2TRB->D2_CNATREC,;
			SD2TRB->D2_GRUPONC,;
			SD2TRB->D2_DTFIMNT,;
			TRANSFORM(SD2TRB->D2_BASEPIS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASECOF,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASECSL,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALPIS,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALCOF,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALCSL,"@E 9,999,999.99"),;
			SD2TRB->D2_ALQPIS,;
			SD2TRB->D2_ALQCOF,;
			SD2TRB->D2_ALQCSL,;
			TRANSFORM(SD2TRB->D2_CBASEAF,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VREINT,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BSREIN,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSRP1,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSRP2,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSRP3,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSRP4,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_CUSRP5,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALIRRF,"@E 9,999,999.99"),;
			SD2TRB->D2_ALQIRRF,;
			SD2TRB->D2_ORDSEP,;
			SD2TRB->D2_RATEIO,;
			SD2TRB->D2_CODLPRE,;
			SD2TRB->D2_ITLPRE,;
			SD2TRB->D2_OKISS,;
			TRANSFORM(SD2TRB->D2_VCAT156,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VLIMPOR,"@E 9,999,999.99"),;
			SD2TRB->D2_FCICOD,;
			SD2TRB->D2_09CAT17,;
			SD2TRB->D2_16CAT17,;
			TRANSFORM(SD2TRB->D2_TOTIMP,"@E 9,999,999.99"),;
			SD2TRB->D2_IDCFC,;
			TRANSFORM(SD2TRB->D2_TOTFED,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_TOTEST,"@E 9,999,999.99"),;
			SD2TRB->D2_TOTMUN,;
			TRANSFORM(SD2TRB->D2_VALCPM,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASECPM,"@E 9,999,999.99"),;
			SD2TRB->D2_ALQCPM,;
			TRANSFORM(SD2TRB->D2_VALFMP,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_BASEFMP,"@E 9,999,999.99"),;
			SD2TRB->D2_ALQFMP,;
			TRANSFORM(SD2TRB->D2_BASEFMD,"@E 9,999,999.99"),;
			SD2TRB->D2_ALQFMD,;
			TRANSFORM(SD2TRB->D2_VALFMD,"@E 9,999,999.99"),;
			SD2TRB->D2_ESPECIE,;
			SD2TRB->D2_SITTRIB,;
			SD2TRB->D2_NFCUP,;
			SD2TRB->D2_ESTOQUE,;
			SD2TRB->D2_REVISAO,;
			SD2TRB->D2_GRPCST,;
			TRANSFORM(SD2TRB->D2_BASECPB,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VALCPB,"@E 9,999,999.99"),;
			SD2TRB->D2_ALIQCPB,;
			SD2TRB->D2_ICMSCOM,;
			SD2TRB->D2_DIFAL,;
			SD2TRB->D2_PDORI,;
			SD2TRB->D2_PDDES,;
			SD2TRB->D2_ALFCCMP,;
			SD2TRB->D2_ALIQCMP,;
			TRANSFORM(SD2TRB->D2_BASEDES,"@E 9,999,999.99"),;
			TRANSFORM(SD2TRB->D2_VFCPDIF,"@E 9,999,999.99"),;
			SD2TRB->WDELETE,;
			SD2TRB->WRECNO;
			})
			SD2TRB->(dbskip())
		EndDo
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexao com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()

		//TMS - 25/02/2020
		SD2TRB->(DbCloseArea())

	Endif

	RestArea(aArea)

	MsgAlert("Exportacao de arquivos concluida !")

Return(Nil)

/*
Funcao      : AjustaSX1()
Objetivos   : Montar o Arquivo de Perguntas no SX1 
Autor       : EMS SOLUCOES
Data	    : 14/11/2016
*/    

*--------------------------*
Static Function AjustaSX1()
	*--------------------------*
	Local aArea	:= GetArea()

	U_PUTSX1(	'HHFIN002','01','Data Inicial p/Copia','Data Inicial p/Copia','Data Inicial p/Copia','mv_ch1','D',8,0,0,'C','','','','','mv_par01','','','','','','','','','','','','','','','','',	{'Informe a data inicial para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''}, '')
	U_PUTSX1(	'HHFIN002','02','Data Final p/Copia','Data Final p/Copia','Data Final p/Copia','mv_ch2','D',8,0,0,'C','','','','','mv_par02','','','','','','','','','','','','','','','','',{'Informe a data final para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','03','Diretorio p/salvar DBF <ENTER>','Diretorio p/salvar DBF <ENTER>','Diretorio p/salvar DBF <ENTER>','mv_ch3','C',99,0,0,'G',"!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,176))",'','','','mv_par03','','','','','','','','','','','','','','','','',{'Informe o diretorio para a copia','das tabelas para a conciliacao.',	''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','04','Tabela SE1(Receber)','Tabela SE1(Receber)','Tabela SE1(Receber)','mv_ch4','C',1,0,1,'C','','','','','mv_par04','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
	U_PUTSX1(	'HHFIN002','05','Tabela SE2(Pagar)','Tabela SE2(Pagar)','Tabela SE2(Pagar)','mv_ch5','C',1,0,1,'C','','','','','mv_par05','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
	U_PUTSX1(	'HHFIN002','06','Tabela SE5(Extrato)','Tabela SE5(Extrato)','Tabela SE5(Extrato)','mv_ch6','C',1,0,1,'C','','','','','mv_par06','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
	U_PUTSX1(	'HHFIN002','07','Doc. Entrada(SD1)','Doc. Entrada(SD1)','Doc. Entrada(SD1)','mv_ch7','C',1,0,1,'C','','','','','mv_par07','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
	U_PUTSX1(	'HHFIN002','08','Doc. Saida(SD2)','Doc. Saida(SD2)','Doc. Saida(SD2)','mv_ch8','C',1,0,1,'C','','','','','mv_par08','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
	U_PUTSX1(	'HHFIN002','09','Filial DE','Filial DE','Filial DE','mv_ch9','C',TamSX3("E2_FILIAL")[1],0,0,'C','','SM0_01','033','','mv_par09','','','','','','','','','','','','','','','','',{'Informe a Filial DE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','10','Filial ATE','Filial ATE','Filial ATE','mv_ch10','C',TamSX3("E2_FILIAL")[1],0,0,'C','','SM0_01','033','','mv_par10','','','','','','','','','','','','','','','','',{'Informe a Filial ATE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','11','Banco DE','Banco DE','Banco DE','mv_ch11','C',TamSX3("E1_PORTADO")[1],0,0,'C','','BCO','033','','mv_par11','','','','','','','','','','','','','','','','',{'Informe o Banco DE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','12','Banco ATE','Banco ATE','Banco ATE','mv_ch12','C',TamSX3("E1_PORTADO")[1],0,0,'C','','BCO','033','','mv_par12','','','','','','','','','','','','','','','','',{'Informe o Banco ATE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','13','Agencia DE','Agencia DE','Agencia DE','mv_ch13','C',TamSX3("E1_AGEDEP")[1],0,0,'C','','','033','','mv_par13','','','','','','','','','','','','','','','','',{'Informe a Agencia DE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','14','Agencia ATE','Agencia ATE','Agencia ATE','mv_ch14','C',TamSX3("E1_AGEDEP")[1],0,0,'C','','','033','','mv_par14','','','','','','','','','','','','','','','','',{'Informe a Agencia ATE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},	'')
	U_PUTSX1(	'HHFIN002','15','Conta DE','Conta DE','Conta DE','mv_ch15','C',TamSX3("E1_CONTA")[1],0,0,'C','','','033','','mv_par15','','','','','','','','','','','','','','','','',{'Informe a Conta DE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','16','Conta ATE','Conta ATE','Conta ATE','mv_ch16','C',TamSX3("E1_CONTA")[1],0,0,'C','','','033','','mv_par16','','','','','','','','','','','','','','','','',{'Informe a Conta ATE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','17','Bordero DE','Bordero DE','Bordero DE','mv_ch17','C',TamSX3("E1_NUMBOR")[1],0,0,'C','','','033','','mv_par17','','','','','','','','','','','','','','','','',{'Informe o Border0 DE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')
	U_PUTSX1(	'HHFIN002','18','Bordero ATE','Bordero ATE','Bordero ATE','mv_ch18','C',TamSX3("E1_NUMBOR")[1],0,0,'C','','','033','','mv_par18','','','','','','','','','','','','','','',	'','',{'Informe o Border0 ATE para a copia','das tabelas para a conciliacao.',''},{'','',''},{'','',''},'')

	RestArea(aArea)

Return()