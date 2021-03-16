#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"                                  

/*
Funcao      : HHFIN002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera Copia dos Dados SE1,SE2 e SE5.
Autor       : Cesar Alves dos Santos
Revisão		: 
Cliente		: Solaris  
Data	    : 16/12/2016
*/    

*-----------------------*
User Function HHFIN002()
*-----------------------* 
Private __Diretorio := ""                                        
Private oProcess
Private aArqDbf := {}

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
	oProcess := MsNewProcess():New( { || HHFINDBF() } , "Exportando tabelas no banco de dados para .DBF" , "Aguarde..." , .F. )
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

__cDiretorio := Alltrim(MV_PAR03)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa depuracao dos arquivos                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SE1                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR04 = 1           

/*	//RRP - 02/03/2017 - Retirada dos campos de Log.
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
	EndDo
*/
	
	If Select('cAliasSE1') > 0 
 		(cAliasSE1)->(DbCloseArea()) 
    Endif 

	If Select('cAliasSE1') > 0 
 		CPOSE1->(DbCloseArea())
    EndIf

	//CAS - 29/03/2017 - Imputação dos campos manualemnte.
	cCampos := ",E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_PORTADO,E1_AGEDEP,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_EMISSAO,E1_VENCTO,E1_VENCREA,E1_VENCORI" + CRLF
	cCampos += ",E1_VALOR,E1_SALDO,E1_VALLIQ,E1_NUMBCO,E1_BAIXA,E1_NUMBOR,E1_DATABOR,E1_EMIS1,E1_HIST,E1_MOVIMEN,E1_DESCONT,E1_SABTPIS,E1_SABTCOF" + CRLF
	cCampos += ",E1_SABTCSL,E1_SABTIRF,E1_MULTA,E1_JUROS,E1_ACRESC,E1_DECRESC,E1_MOEDA,E1_FATURA,E1_OK,E1_OCORREN, E1_PEDIDO,E1_SERIE,E1_STATUS" + CRLF
	cCampos += ",E1_FILORIG,E1_CSLL,E1_COFINS,E1_PIS,E1_MSFIL,E1_MSEMP,E1_IDCNAB,E1_CODBAR,E1_CODDIG,E1_P_RETBA,E1_P_COBEX,E1_P_DATEX,E1_P_BOL " + CRLF
	cCampos += ",SE1.D_E_L_E_T_ WDELETE, SE1.R_E_C_N_O_ WRECNO " + CRLF
		
	cAliasSE1 	:= GetNextAlias()                   	
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
	
	//cQuery 		:= ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
	
	DbSelectArea(cAliasSE1)
	DbGotop()         
   	
   	SX3->(DbSetOrder(2))
   	
	_aStru := (cAliasSE1)->(DbStruct())
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
                                
	dbSelectArea(cAliasSE1)
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

		dbSelectArea(cAliasSE1)
		DbSkip()
	End

	If Select('cAliasSE1') > 0 
 		(cAliasSE1)->(DbCloseArea()) 
    Endif 

	dbSelectArea(cAliasSE1)
    oProcess:SetRegua1( (cAliasSE1)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE1")
	_cArqDBF	:= Alltrim( RetSQLName("SE1") )+"_RECEBER_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF

	DbSelectArea("TRB")
	DbCloseArea()
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSE1)->(DbCloseArea())
	FErase(_cArqDBF)//Excluir arquivo 
	FErase(cArqDBF)  //Excluir arquivo

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SE2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR05 = 1
	//RRP - 02/03/2017 - Retirada dos campos de Log.
	cCampos:= "" 
	cQueCpo:= ""
	aArqDbf := {}	
	
	If Select('cAliasSE2') > 0 
 		(cAliasSE2)->(DbCloseArea()) 
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
	//CAS - 06/06/2017 - Inclusão da Linha do "CONVERT/E2_USERLGI/AS 'DT_USERLGI'" para pegar a data do LOG.
	//AOA - 04/09/2017 - Solaris inclusão do campo modelo de pagamento	
	cCampos += ",(SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_TABELA='HH' AND X5_CHAVE=E2_P_FOPAG) AS PAGAMENTO"
	cCampos += ",(SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_TABELA='58' AND X5_CHAVE=E2_P_MODEL) AS MODELO"
	cCampos += ",CONVERT(     DATE,DATEADD(DAY,((ASCII(SUBSTRING(E2_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(E2_USERLGI,16,1)) - 50)),'19960101')) AS 'E2_DATALOG' "
	cCampos += ",SE2.D_E_L_E_T_ WDELETE, SE2.R_E_C_N_O_ WRECNO "
	
	If Select('cAliasSE2') > 0 
 		CPOSE2->(DbCloseArea())
    EndIf

	cAliasSE2 := GetNextAlias()                         
	cQuery 		:= "SELECT SA2.A2_NOME  AS 'FORNECEDOR', SA2.A2_CGC  AS 'CNPJ_CPF', " + CRLF
	cQuery		+= "(Case when SA2.A2_TIPO = 'F' THEN SA2.A2_CGC else SubString(SA2.A2_CGC,1,8) End) AS 'R_CNPJ_CPF' " + CRLF
	cQuery		+= " "+cCampos+" "  + CRLF               	
	cQuery 		+= "FROM "+RetSQLName("SE2")+" SE2 " + " INNER JOIN " +RetSQLName("SA2")+" SA2 ON " + CRLF
	cQuery 		+= "SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_FILIAL = SA2.A2_FILIAL AND SE2.E2_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*' " + CRLF
	cQuery 		+= "WHERE " + CRLF
	cQuery 		+= "     SE2.E2_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + CRLF
	cQuery 		+= " AND SE2.E2_EMIS1  BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + CRLF

	//cQuery 		:= ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
	
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
	FErase(_cArqDBF)//Excluir arquivo  
	FErase(cArqDBF)  //Excluir arquivo

Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SE5                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR06 = 1

	//RRP - 02/03/2017 - Retirada dos campos de Log.
	cCampos:= "" 
	cQueCpo:= ""
	aArqDbf := {}
	
	If Select('cAliasSE5') > 0 
 		(cAliasSE5)->(DbCloseArea()) 
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
	
	If Select('cAliasSE5') > 0 
 		CPOSE5->(DbCloseArea())
    EndIf

	cAliasSE5 := GetNextAlias()                         
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
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.T.,.T.)

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
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSE5)->(DbCloseArea())
	FErase(_cArqDBF) //Excluir arquivo
	FErase(cArqDBF)  //Excluir arquivo

EndIf
	     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SD1                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If mv_par07 == 1

	aArqDbf := {}

/*	//RRP - 16/03/2017 - Exportar Tabela SD1
	cCampos:= "" 
	cQueCpo:= ""

	If Select('CPOSD1') > 0 
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
*/        

	If Select('cAliasSD1') > 0 
 		(cAliasSD1)->(DbCloseArea()) 
    Endif 

	If Select('cAliasSD1') > 0 
 		CPOSD1->(DbCloseArea())
    EndIf

	//CAS - 29/03/2017 - Imputação dos campos manualemnte.
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
	
	cAliasSD1 := GetNextAlias()   
	cQuery 		:= "SELECT "+cCampos+" "  + CRLF                                                                                 	
	cQuery 		+= "FROM "+RetSQLName("SD1")+" SD1 " + CRLF		
	cQuery 		+= "WHERE SD1.D_E_L_E_T_ <> '*' "   + CRLF   
	If !Empty(mv_par09).OR.!Empty(mv_par10)
		cQuery 		+= " AND SD1.D1_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "  + CRLF
	EndIf
	If !Empty(MV_PAR01).OR.!Empty(MV_PAR02)
		cQuery 		+= " AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "  + CRLF
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
	
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
	FErase(_cArqDBF)//Excluir arquivo
	FErase(cArqDBF)  //Excluir arquivo

Endif
             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia registros do SD2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If mv_par08 == 1
	
	aArqDbf := {}

/*	//RRP - 17/03/2017 - Exportar Tabela SD2
	cCampos:= "" 
	cQueCpo:= ""
	
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
	EndDo
*/

	If Select('cAliasSD2') > 0 
 		(cAliasSD2)->(DbCloseArea()) 
    Endif 
	
	If Select('cAliasSD2') > 0 
 		CPOSD2->(DbCloseArea())
    EndIf

	//CAS - 29/03/2017 - Imputação dos campos manualemnte.
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

	cAliasSD2 := GetNextAlias()    	
	cQuery 		:= "SELECT "+cCampos+" "  + CRLF                                                                                 	
	cQuery 		+= "FROM "+RetSQLName("SD2")+" SD2 "  + CRLF	
	cQuery 		+= "WHERE "   + CRLF
	If !Empty(mv_par09).OR.!Empty(mv_par10)
		cQuery 		+= "     SD2.D2_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "  + CRLF
	EndIf
	If !Empty(MV_PAR01).OR.!Empty(MV_PAR02)
		cQuery 		+= " AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "  + CRLF
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
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
	__CopyFile( (cArqDBF+".DBF"), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSD2)->(DbCloseArea())
	FErase(_cArqDBF)//Excluir arquivo 	 
	FErase(cArqDBF)  //Excluir arquivo

Endif
	
MsgAlert("Exportação de arquivos concluída !")

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

U_PUTSX1(	'HHFIN002','01','Data Inicial p/Copia','Data Inicial p/Copia','Data Inicial p/Copia','mv_ch1','D',8,0,0,'C','','','','','mv_par01','','','','','','','','','','','','','','','','',	{'Informe a data inicial para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''}, '')
U_PUTSX1(	'HHFIN002','02','Data Final p/Copia','Data Final p/Copia','Data Final p/Copia','mv_ch2','D',8,0,0,'C','','','','','mv_par02','','','','','','','','','','','','','','','','',{'Informe a data final para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','03','Diretorio p/salvar DBF <ENTER>','Diretorio p/salvar DBF <ENTER>','Diretorio p/salvar DBF <ENTER>','mv_ch3','C',99,0,0,'G',"!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,176))",'','','','mv_par03','','','','','','','','','','','','','','','','',{'Informe o diretorio para a cópia','das tabelas para a conciliação.',	''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','04','Tabela SE1(Receber)','Tabela SE1(Receber)','Tabela SE1(Receber)','mv_ch4','C',1,0,1,'C','','','','','mv_par04','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
U_PUTSX1(	'HHFIN002','05','Tabela SE2(Pagar)','Tabela SE2(Pagar)','Tabela SE2(Pagar)','mv_ch5','C',1,0,1,'C','','','','','mv_par05','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
U_PUTSX1(	'HHFIN002','06','Tabela SE5(Extrato)','Tabela SE5(Extrato)','Tabela SE5(Extrato)','mv_ch6','C',1,0,1,'C','','','','','mv_par06','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
U_PUTSX1(	'HHFIN002','07','Doc. Entrada(SD1)','Doc. Entrada(SD1)','Doc. Entrada(SD1)','mv_ch7','C',1,0,1,'C','','','','','mv_par07','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
U_PUTSX1(	'HHFIN002','08','Doc. Saída(SD2)','Doc. Saída(SD2)','Doc. Saída(SD2)','mv_ch8','C',1,0,1,'C','','','','','mv_par08','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')
U_PUTSX1(	'HHFIN002','09','Filial DE','Filial DE','Filial DE','mv_ch9','C',TamSX3("E2_FILIAL")[1],0,0,'C','','SM0_01','033','','mv_par09','','','','','','','','','','','','','','','','',{'Informe a Filial DE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','10','Filial ATE','Filial ATE','Filial ATE','mv_ch10','C',TamSX3("E2_FILIAL")[1],0,0,'C','','SM0_01','033','','mv_par10','','','','','','','','','','','','','','','','',{'Informe a Filial ATE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','11','Banco DE','Banco DE','Banco DE','mv_ch11','C',TamSX3("E1_PORTADO")[1],0,0,'C','','BCO','033','','mv_par11','','','','','','','','','','','','','','','','',{'Informe o Banco DE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','12','Banco ATE','Banco ATE','Banco ATE','mv_ch12','C',TamSX3("E1_PORTADO")[1],0,0,'C','','BCO','033','','mv_par12','','','','','','','','','','','','','','','','',{'Informe o Banco ATE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','13','Agência DE','Agência DE','Agência DE','mv_ch13','C',TamSX3("E1_AGEDEP")[1],0,0,'C','','','033','','mv_par13','','','','','','','','','','','','','','','','',{'Informe a Agência DE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','14','Agência ATE','Agência ATE','Agência ATE','mv_ch14','C',TamSX3("E1_AGEDEP")[1],0,0,'C','','','033','','mv_par14','','','','','','','','','','','','','','','','',{'Informe a Agência ATE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},	'')
U_PUTSX1(	'HHFIN002','15','Conta DE','Conta DE','Conta DE','mv_ch15','C',TamSX3("E1_CONTA")[1],0,0,'C','','','033','','mv_par15','','','','','','','','','','','','','','','','',{'Informe a Conta DE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','16','Conta ATE','Conta ATE','Conta ATE','mv_ch16','C',TamSX3("E1_CONTA")[1],0,0,'C','','','033','','mv_par16','','','','','','','','','','','','','','','','',{'Informe a Conta ATE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','17','Borderô DE','Borderô DE','Borderô DE','mv_ch17','C',TamSX3("E1_NUMBOR")[1],0,0,'C','','','033','','mv_par17','','','','','','','','','','','','','','','','',{'Informe o Borderô DE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN002','18','Borderô ATE','Borderô ATE','Borderô ATE','mv_ch18','C',TamSX3("E1_NUMBOR")[1],0,0,'C','','','033','','mv_par18','','','','','','','','','','','','','','',	'','',{'Informe o Borderô ATE para a cópia','das tabelas para a conciliação.',''},{'','',''},{'','',''},'') 

RestArea(aArea)

Return()
