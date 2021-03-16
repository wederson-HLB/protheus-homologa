#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
Funcao      : GTGEN038()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera Copia dos Dados CT2, CTK, SE1, SE2, SE5, SF1, SF2 e SFT.
Autor       : EMS SOLUCOES
RevisЦo		: Anderson Arrais
Cliente		:   
Data	    : 14/11/2016
*/    

*-----------------------*
User Function GTGEN038()
*-----------------------* 
Private __Diretorio := "" 
Private oProcess

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajusta Perguntas                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AjustaSX1()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega os parБmetros de PerМodo Desejado, vinda do SX1         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( Pergunte("GTGEN038",.T.) )
//GTGENDBF()	
// Processa( {|| GTGENDBF() }, "Aguarde...", "Exportando tabelas no banco de dados para .DBF",.F.)
	oProcess := MsNewProcess():New( { || GTGENDBF() } , "Exportando tabelas no banco de dados para .DBF" , "Aguarde..." , .F. )
 	oProcess:Activate()	
Endif

Return()

/*
Funcao      : GTGENDBF()
Objetivos   : Gera Copia dos Dados 
Autor       : EMS SOLUCOES
Data	    : 14/11/2016
*/    

*-------------------------*
Static Function GTGENDBF()
*-------------------------*  
__cDiretorio := Alltrim(MV_PAR02)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa depuracao dos arquivos                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do SE1                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR03 = 1
	cAliasSE1 	:= GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) SE1RECNO  "
	cQuery 		+= "FROM "+RetSQLName("SE1")+" SE1 "
	cQuery 		+= "WHERE SE1.D_E_L_E_T_ <> '*' AND E1_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND E1_EMIS1 >= '" + DTOS(MV_PAR01) + "' "
	cQuery 		:= ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
	
	TCSetField(cAliasSE1,"SE1RECNO","C",17,0)
	
	_aStru := SE1->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'SE1RECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasSE1), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasSE1') > 0 
 		(cAliasSE1)->(DbCloseArea()) 
    Endif 

	dbSelectArea(cAliasSE1)
    oProcess:SetRegua1( (cAliasSE1)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE1")
	_cArqDBF	:= Alltrim( RetSQLName("SE1") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSE1)->(DbCloseArea()) 

Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do SE2                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR04 = 1
	cAliasSE2 := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) SE2RECNO  "
	cQuery += "FROM "+RetSQLName("SE2")+" SE2 "
	cQuery += "WHERE SE2.D_E_L_E_T_ <> '*' AND E2_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND E2_EMIS1 >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
	
	TCSetField(cAliasSE2,"SE2RECNO","C",17,0)
	
	_aStru := SE2->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'SE2RECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasSE2), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasSE2') > 0 
 		(cAliasSE2)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasSE2)
    oProcess:SetRegua1( (cAliasSE2)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE2")
	_cArqDBF	:= Alltrim( RetSQLName("SE2") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSE2)->(DbCloseArea()) 

Endif
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do SE5                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR05 = 1
	cAliasSE5 := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) SE5RECNO  "
	cQuery += "FROM "+RetSQLName("SE5")+" SE5 "
	cQuery += "WHERE SE5.D_E_L_E_T_ <> '*' AND E5_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND E5_DATA >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.T.,.T.)
	
	TCSetField(cAliasSE5,"SE5RECNO","C",17,0)
	
	_aStru := SE5->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'SE5RECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasSE5), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasSE5') > 0 
		(cAliasSE5)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasSE5)
	
    oProcess:SetRegua1( (cAliasSE5)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SE5")
	_cArqDBF	:= Alltrim( RetSQLName("SE5") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSE5)->(DbCloseArea()) 

Endif
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do SF1                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR06 = 1
	cAliasSF1 := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) SF1RECNO  "
	cQuery += "FROM "+RetSQLName("SF1")+" SF1 "
	cQuery += "WHERE SF1.D_E_L_E_T_ <> '*' AND F1_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND F1_DTDIGIT >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.T.,.T.)
	
	TCSetField(cAliasSF1,"SF1RECNO","C",17,0)
	
	_aStru := SF1->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'SF1RECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasSF1), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasSF1') > 0 
		(cAliasSF1)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasSF1)

    oProcess:SetRegua1( (cAliasSF1)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SF1")
	_cArqDBF	:= Alltrim( RetSQLName("SF1") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSF1)->(DbCloseArea()) 

Endif
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do SF2                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR07 = 1
	cAliasSF2 := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) SF2RECNO  "
	cQuery += "FROM "+RetSQLName("SF2")+" SF2 "
	cQuery += "WHERE SF2.D_E_L_E_T_ <> '*' AND F2_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND F2_EMISSAO >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)
	
	TCSetField(cAliasSF2,"SF2RECNO","C",17,0)
	
	_aStru := SF2->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'SF2RECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasSF2), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasSF2') > 0 
		(cAliasSF2)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasSF2)
	
    oProcess:SetRegua1( (cAliasSF2)->(RecCount()) )
	oProcess:IncRegua1("Exportando arquivo SF2")
	_cArqDBF	:= Alltrim( RetSQLName("SF2") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSF2)->(DbCloseArea()) 

Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do SFT                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR08 = 1
	cAliasSFT := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) SFTRECNO  "
	cQuery += "FROM "+RetSQLName("SFT")+" SFT "
	cQuery += "WHERE SFT.D_E_L_E_T_ <> '*' AND FT_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND FT_ENTRADA >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT,.T.,.T.)
	
	TCSetField(cAliasSFT,"SFTRECNO","C",17,0)
	
	_aStru := SFT->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'SFTRECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasSFT), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasSFT') > 0 
		(cAliasSFT)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasSFT)
    
    oProcess:SetRegua1( (cAliasSFT)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo SFT")
	_cArqDBF	:= Alltrim( RetSQLName("SFT") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasSFT)->(DbCloseArea()) 

Endif
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do CT2                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR09 = 1

	cAliasCT2 := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) CT2RECNO  "
	cQuery += "FROM "+RetSQLName("CT2")+" CT2 "
	cQuery += "WHERE CT2.D_E_L_E_T_ <> '*' AND CT2_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND CT2_DATA >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.T.)

	TCSetField(cAliasCT2,"CT2RECNO","C",17,0)
	
	_aStru := CT2->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'CT2RECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasCT2), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasCT2') > 0 
		(cAliasCT2)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasCT2)
	
    oProcess:SetRegua1( (cAliasCT2)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo CT2")
	_cArqDBF	:= Alltrim( RetSQLName("CT2") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasCT2)->(DbCloseArea()) 

Endif
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Copia registros do CTK                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MV_PAR10 = 1
	cAliasCTK := GetNextAlias()                         
	cQuery := "SELECT *, CAST(R_E_C_N_O_ AS VARCHAR(17)) CTKRECNO "
	cQuery += "FROM "+RetSQLName("CTK")+" CTK "
	cQuery += "WHERE CTK.D_E_L_E_T_ <> '*' AND CTK_FILIAL BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND CTK_DATA >= '" + DTOS(MV_PAR01) + "' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTK,.T.,.T.)

	TCSetField(cAliasCTK,"CTKRECNO","C",17,0)
	
	_aStru := CTK->(DbStruct())
	nT := Len(_aStru)
	For nI := 1 to nT   
		If ( _aStru[nI][2] $ 'DNL') .And. ( Alltrim(_aStru[nI,1]) <> 'CTKRECNO' ) .And. ( Alltrim(_aStru[nI,1]) <> 'R_E_C_N_O_' )      
			TCSetField((cAliasCTK), _aStru[nI,1], _aStru[nI,2], _aStru[nI,3], _aStru[nI,4])   
		Endif
	Next

	If Select('cAliasCTK') > 0 
		(cAliasCTK)->(DbCloseArea()) 
    Endif 
	
	dbSelectArea(cAliasCTK)
	
    oProcess:SetRegua1( (cAliasCTK)->(RecCount()) )
    oProcess:IncRegua1("Exportando arquivo CTK")
	_cArqDBF	:= Alltrim( RetSQLName("CTK") )+"_CONCIL.DBF"
	_cDirLocal	:= __cDiretorio + _cArqDBF 
	Copy To &(_cArqDBF)
	__CopyFile( (_cArqDBF), (_cDirLocal) ) // Copia arquivos do servidor para o local especificado
	(cAliasCTK)->(DbCloseArea()) 

Endif
	
MsgAlert("ExportaГЦo de arquivos concluМda !")

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

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'01' , ;        	                            //-- 02 - X1_ORDEM
		'Data Inicial p/Copia', ;          				//-- 03 - X1_PERGUNT
		'Data Inicial p/Copia', ;      					//-- 04 - X1_PERSPA
		'Data Inicial p/Copia', ;       				//-- 05 - X1_PERENG
		'mv_ch1', ;                                     //-- 06 - X1_VARIAVL
		'D', ;                                          //-- 07 - X1_TIPO
		8, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		0, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par01', ;                                   //-- 16 - X1_VAR01
		'', ;                            				//-- 17 - X1_DEF01
		'', ;	                            			//-- 18 - X1_DEFSPA1
		'', ;                            				//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'', ;                            				//-- 21 - X1_DEF02
		'', ; 	                           				//-- 22 - X1_DEFSPA2
		'', ;     	                       				//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Informe a data inicial para a cСpia', ; 		//-- 33 - HelpPor1#3
		'das tabelas para a conciliaГЦo.', ;  			//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{' ', ;											//-- 34 - HelpPor1#3
		' ', ;											//--      HelpPor2#3
		' '}, ;											//--      HelpPor3#3
		{' ', ;  										//-- 35 - HelpPor1#3
		' ', ; 											//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

// x1_valid tem 60 caracteres !
//	__cDiretorio := cGetFile ( '*.DBF' , 'Salvar arquivo em: ', 1, 'C:\', .F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY) 
// cGetFile('Arquivo *|*.*|Arquivo JPG|*.Jpg','Retorna Diretorio',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
// '!Vazio().or.(Mv_Par02:=cGetFile('Arquivos |*.*','',,,,176))', ;  //-- 12 - X1_VALID

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'02' , ;        	                            //-- 02 - X1_ORDEM
		'Diretorio p/salvar DBF <ENTER>', ;   			//-- 03 - X1_PERGUNT
		'Diretorio p/salvar DBF <ENTER>', ;    			//-- 04 - X1_PERSPA
		'Diretorio p/salvar DBF <ENTER>', ;       		//-- 05 - X1_PERENG
		'mv_ch2', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		99, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		0, ;                                            //-- 10 - X1_PRESEL
		'G', ;                                          //-- 11 - X1_GSC
		"!Vazio().or.(Mv_Par02:=cGetFile('Arquivos |*.*','',,,,176))", ;  //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par02', ;                                   //-- 16 - X1_VAR01
		'', ;                            				//-- 17 - X1_DEF01
		'', ;	                            			//-- 18 - X1_DEFSPA1
		'', ;                            				//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'', ;                            				//-- 21 - X1_DEF02
		'', ; 	                           				//-- 22 - X1_DEFSPA2
		'', ;     	                       				//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Informe o diretorio para a cСpia', ; 			//-- 33 - HelpPor1#3
		'das tabelas para a conciliaГЦo.', ;  			//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{' ', ;											//-- 34 - HelpPor1#3
		' ', ;											//--      HelpPor2#3
		' '}, ;											//--      HelpPor3#3
		{' ', ;  										//-- 35 - HelpPor1#3
		' ', ; 											//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'03' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela SE1', ;          						//-- 03 - X1_PERGUNT
		'Tabela SE1', ;      							//-- 04 - X1_PERSPA
		'Tabela SE1', ;       							//-- 05 - X1_PERENG
		'mv_ch3', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par03', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'04' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela SE2', ;          						//-- 03 - X1_PERGUNT
		'Tabela SE2', ;      							//-- 04 - X1_PERSPA
		'Tabela SE2', ;       							//-- 05 - X1_PERENG
		'mv_ch4', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par04', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'05' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela SE5', ;          						//-- 03 - X1_PERGUNT
		'Tabela SE5', ;      							//-- 04 - X1_PERSPA
		'Tabela SE5', ;       							//-- 05 - X1_PERENG
		'mv_ch5', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par05', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'06' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela SF1', ;          						//-- 03 - X1_PERGUNT
		'Tabela SF1', ;      							//-- 04 - X1_PERSPA
		'Tabela SF1', ;       							//-- 05 - X1_PERENG
		'mv_ch6', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par06', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'07' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela SF2', ;          						//-- 03 - X1_PERGUNT
		'Tabela SF2', ;      							//-- 04 - X1_PERSPA
		'Tabela SF2', ;       							//-- 05 - X1_PERENG
		'mv_ch7', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par07', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'08' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela SFT', ;          						//-- 03 - X1_PERGUNT
		'Tabela SFT', ;      							//-- 04 - X1_PERSPA
		'Tabela SFT', ;       							//-- 05 - X1_PERENG
		'mv_ch8', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par08', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')


U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'09' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela CT2', ;          						//-- 03 - X1_PERGUNT
		'Tabela CT2', ;      							//-- 04 - X1_PERSPA
		'Tabela CT2', ;       							//-- 05 - X1_PERENG
		'mv_ch9', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par09', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'10' , ;        	                            //-- 02 - X1_ORDEM
		'Tabela CTK', ;          						//-- 03 - X1_PERGUNT
		'Tabela CTK', ;      							//-- 04 - X1_PERSPA
		'Tabela CTK', ;       							//-- 05 - X1_PERENG
		'mv_cha', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		1, ;                                            //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		1, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'', ;                                           //-- 13 - X1_F3
		'', ;                                           //-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par10', ;                                   //-- 16 - X1_VAR01
		'Sim', ;                            			//-- 17 - X1_DEF01
		'Si', ;	                            			//-- 18 - X1_DEFSPA1
		'Yes', ;                            			//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'Nao', ;                            			//-- 21 - X1_DEF02
		'No', ; 	                           			//-- 22 - X1_DEFSPA2
		'No', ;     	                       			//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Exporta esta tabela ?', ; 					//-- 33 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 34 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{'Exporta esta tabela ?', ; 					//-- 35 - HelpPor1#3
		' ', ;  										//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'11' , ;        	                            //-- 02 - X1_ORDEM
		'Filial DE', ;          						//-- 03 - X1_PERGUNT
		'Filial DE', ;      							//-- 04 - X1_PERSPA
		'Filial DE', ;       							//-- 05 - X1_PERENG
		'mv_chb', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		TamSX3("E2_FILIAL")[1], ;                       //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		0, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'SM0_01', ;                                     //-- 13 - X1_F3
		'033', ;                                  		//-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par11', ;                                   //-- 16 - X1_VAR01
		'', ;                            				//-- 17 - X1_DEF01
		'', ;	                            			//-- 18 - X1_DEFSPA1
		'', ;                            				//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'', ;                            				//-- 21 - X1_DEF02
		'', ; 	                           				//-- 22 - X1_DEFSPA2
		'', ;     	                       				//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Informe a Filial DE para a cСpia', ; 			//-- 33 - HelpPor1#3
		'das tabelas para a conciliaГЦo.', ;  			//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{' ', ;											//-- 34 - HelpPor1#3
		' ', ;											//--      HelpPor2#3
		' '}, ;											//--      HelpPor3#3
		{' ', ;  										//-- 35 - HelpPor1#3
		' ', ; 											//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

U_PUTSX1(	'GTGEN038', ;  	                          		//-- 01 - X1_GRUPO
		'12' , ;        	                            //-- 02 - X1_ORDEM
		'Filial ATE', ;          						//-- 03 - X1_PERGUNT
		'Filial ATE', ;      							//-- 04 - X1_PERSPA
		'Filial ATE', ;       							//-- 05 - X1_PERENG
		'mv_chc', ;                                     //-- 06 - X1_VARIAVL
		'C', ;                                          //-- 07 - X1_TIPO
		TamSX3("E2_FILIAL")[1], ;                       //-- 08 - X1_TAMANHO
		0, ;                                            //-- 09 - X1_DECIMAL
		0, ;                                            //-- 10 - X1_PRESEL
		'C', ;                                          //-- 11 - X1_GSC
		'', ;                                           //-- 12 - X1_VALID
		'SM0_01', ;                                     //-- 13 - X1_F3
		'033', ;                                  		//-- 14 - X1_GRPSXG
		'', ;                                           //-- 15 - X1_PYME
		'mv_par12', ;                                   //-- 16 - X1_VAR01
		'', ;                            				//-- 17 - X1_DEF01
		'', ;	                            			//-- 18 - X1_DEFSPA1
		'', ;                            				//-- 19 - X1_DEFENG1
		'', ;                                           //-- 20 - X1_CNT01
		'', ;                            				//-- 21 - X1_DEF02
		'', ; 	                           				//-- 22 - X1_DEFSPA2
		'', ;     	                       				//-- 23 - X1_DEFENG2
		'', ;                             				//-- 24 - X1_DEF03
		'', ;                             				//-- 25 - X1_DEFSPA3
		'', ;                             				//-- 26 - X1_DEFENG3
		'', ;                                           //-- 27 - X1_DEF04
		'', ;                                           //-- 28 - X1_DEFSPA4
		'', ;                                           //-- 29 - X1_DEFENG4
		'', ;                                           //-- 30 - X1_DEF05
		'', ;                                           //-- 31 - X1_DEFSPA5
		'', ;                                           //-- 32 - X1_DEFENG5
		{'Informe a Filial ATE para a cСpia', ; 		//-- 33 - HelpPor1#3
		'das tabelas para a conciliaГЦo.', ;  			//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		{' ', ;											//-- 34 - HelpPor1#3
		' ', ;											//--      HelpPor2#3
		' '}, ;											//--      HelpPor3#3
		{' ', ;  										//-- 35 - HelpPor1#3
		' ', ; 											//--      HelpPor2#3
		' '}, ; 										//--      HelpPor3#3
		'')

RestArea(aArea)

Return()
