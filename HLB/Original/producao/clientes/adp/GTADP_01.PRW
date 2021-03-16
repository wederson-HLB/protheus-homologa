#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FILEIO.CH"    

#DEFINE ENTER CHR(13)+CHR(10)   
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ GTADP_01 ≥Autor  ≥ Cesar Chena           ≥ Data ≥22/07/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Rel. HLB BRASIL ADP - Summary Variance Report          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Obs:      ≥ Gera somente em excel.                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico HLB BRASIL                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function GTADP_01(cPath,cPeriodo)

PRIVATE _oWindow

Processa( {|| GTADP01Go(cPath,cPeriodo) }, "Gerando Planilha..." )

cPerg := "GTADP001"

Return( .F. )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥ GTADP01Go≥ Autor ≥ Cesar Chena           ≥ Data ≥28/01/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Processamento do Arquivo.                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function GTADP01Go(cPath,cPeriodo)

LOCAL _cQry := ""
LOCAL dDataInc, dDataAlt
LOCAL _aDetails := {}
LOCAL _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
LOCAL _cPer2ini := ""
LOCAL _cPer2fin := ""
LOCAL _cPer3ini := ""
LOCAL nYear3 := VAL(subs(cPeriodo,4,4))
LOCAL nYear := VAL(subs(cPeriodo,4,4))
LOCAL aHeader := {}
LOCAL cNomArq := ""

PRIVATE _cTitulo  := "Variance Report Summary"
PRIVATE _cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer1fin := ""

PRIVATE cCodemp := upper(ALLTRIM(SM0->M0_CODIGO))

Private cNomeEmx := ""
Private cNomeEmp := STRTRAN(ALLTRIM(SM0->M0_NOME),".","-")

for x = 1 to len(cNomeEmp)
	if substr(cNomeEmp,x,1) <> " "
		cNomeEmx := cNomeEmx + substr(cNomeEmp,x,1)	
	endif
next x

cNomeEmp := alltrim(cNomeEmx)


Private cCC := ' '
Private	_lver := .t.

//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"X0"+"CID")
	cCID := X5_DESCRI
Else
	Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} ) 
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
	cENTITY := X5_DESCRI
Else
	Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"LID")
	cLID := X5_DESCRI
Else
	Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif

//// francisco neto  19/09/2016
DbSelectArea("SX2") //verifica compartilhamento de centro de custos
DbSetOrder(1)

If DbSeek("CTT")
	cCC := X2_MODO
Endif


// monta periodo 1 final 
If subs(cPeriodo,1,2) $ "04/06/09/11"
	_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
	_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
Elseif subs(cPeriodo,1,2) $ "02"
	If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
		_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
	Else
		_cPer1fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
	Endif
Endif

// retrocede periodo inicial para montar periodo final
If subs(cPeriodo,1,2) = "01"
	_cMesfin := "12"
	//WFA - 17/01/2017 - 038506 - AlteraÁ„o no tipo de dado retornado a variavel _cAnofin 
	_cAnofin := alltrim(str(val(subs(cPeriodo,4,4))-1))
Else
	_cMesfin := strzero(val(subs(cPeriodo,1,2))-1,2)
	_cAnofin := subs(cPeriodo,4,4)
Endif 

//_cPer2ini := _cAnofin+_cMesfin+"01"
_cPer2ini := _cAnofin+_cMesfin
nYear := _cAnofin

//// francisco neto 23/09/16
IF UPPER(ALLTRIM(_cRegime)) == "S"

	// adianta periodo inicial para regime de caixa
	If subs(cPeriodo,1,2) = "12"
		_cMesfin := "01"
		_cAnofin := strzero(val(subs(cPeriodo,4,4))+1,2)
	Else
		_cMesfin := strzero(val(subs(cPeriodo,1,2))+1,2)
		_cAnofin := subs(cPeriodo,4,4)
	Endif 
	
	_cPer3ini := _cAnofin+_cMesfin
	nYear3 := _cAnofin
	
ENDIF


// monta periodo 2 final 
/*If _cMesfin $ "04/06/09/11"
	_cPer2fin := _cAnofin+_cMesfin+"30"
Elseif _cMesfin $ "01/03/05/07/08/10/12"
	_cPer2fin := _cAnofin+_cMesfin+"31"
Elseif _cMesfin $ "02"
	If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
		_cPer2fin := _cAnofin+_cMesfin+"29"
	Else
		_cPer2fin := _cAnofin+_cMesfin+"28"
	Endif
Endif
*/  

//ECR - 26/08/2015 - GravaÁ„o do cabeÁalho
aAdd(aHeader,{"Variance Report Summary",""})
aAdd(aHeader,{"Report Data and Time"   ,Subs(DtoS(dDataBase),1,4)+"/"+Subs(DtoS(dDataBase),5,2)+"/"+Subs(DtoS(dDataBase),7,2)+"  "+Subs(Time(),1,5)})
aAdd(aHeader,{"Country Code"           ,"BR"})
aAdd(aHeader,{"Company Name"           ,AllTrim(SM0->M0_NOME)}) 
aAdd(aHeader,{"Entity Id"              ,AllTrim(cLid)}) 
aAdd(aHeader,{"Entity Name"            ,Alltrim(cEntity)}) 
aAdd(aHeader,{"Currency"               ,"BRL"}) 
aAdd(aHeader,{"Pay Cycle"              ,Subs(_cPer1ini,1,4)+"/"+Subs(_cPer1ini,5,2)+"/"+Subs(_cPer1ini,7,2) + " - " +;
                                        Subs(_cPer1fin,1,4)+"/"+Subs(_cPer1fin,5,2)+"/"+Subs(_cPer1fin,7,2)}) 


///////------ VERIFICA SE EXISTE MOVIMENTO DE FOLHA PARA MATRICULAS N√O CADASTRADAS  /// francisco neto  22/09/2016
	_cQry := "SELECT DISTINCT RC_FILIAL+RC_MAT AS FILMAT " + " " +CRLF 
	_cQry += " FROM " + RetSqlName("SRC") + " " +CRLF
	_cQry += "WHERE D_E_L_E_T_ = ' ' " + " " +CRLF 
	_cQry += "AND RC_FILIAL+RC_MAT NOT IN(SELECT RA_FILIAL+RA_MAT " + " " +CRLF 
	_cQry += "FROM " + RetSqlName("SRA") + " " +CRLF 
	_cQry += "WHERE D_E_L_E_T_ = ' ')" + " " +CRLF 
	_cQry += "ORDER BY RC_FILIAL+RC_MAT" + " " +CRLF 

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "MOV", .F., .T.)

	dbSelectArea("MOV")
	ProcRegua(RecCount())
	dbGoTop()
	_lver := .t.
	Do While !Eof()
		_lver := .f.
		Aviso("ATEN«√O","Filial / Matricula: "+left(MOV->FILMAT,1)+" / "+right(MOV->FILMAT,6)+ "Movimento sem cadastro!. Verifique!", {"Ok"} )
		dbSkip()
	EndDo	
	if _lver == .f.
		IF SELECT("MOV") > 0
			MOV->(DBCLOSEAREA())
		ENDIF
		Return	
	endif

	IF SELECT("MOV") > 0
		MOV->(DBCLOSEAREA())
	ENDIF


///////------ VERIFICA SE EXISTE FICHA FINANCEIRA PARA MATRICULAS N√O CADASTRADAS  /// francisco neto  22/09/2016
	_cQry := "SELECT DISTINCT RD_FILIAL+RD_MAT AS FILMAT " + " " +CRLF 
	_cQry += " FROM " + RetSqlName("SRD") + " " +CRLF
	_cQry += "WHERE D_E_L_E_T_ = ' ' " + " " +CRLF 
	_cQry += "AND RD_FILIAL+RD_MAT NOT IN(SELECT RA_FILIAL+RA_MAT " + " " +CRLF 
	_cQry += "FROM " + RetSqlName("SRA") + " " +CRLF 
	_cQry += "WHERE D_E_L_E_T_ = ' ')" + " " +CRLF 
	_cQry += "ORDER BY RD_FILIAL+RD_MAT" + " " +CRLF 

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "FIC", .F., .T.)

	dbSelectArea("FIC")
	ProcRegua(RecCount())
	dbGoTop()
	_lver := .t.
	Do While !Eof()
		_lver := .f.
		Aviso("ATEN«√O","Filial / Matricula: "+left(FIC->FILMAT,1)+" / "+right(FIC->FILMAT,6)+ "Acumulados sem cadastro!. Verifique!", {"Ok"} )
		dbSkip()
	EndDo	
	if _lver == .f.
		IF SELECT("FIC") > 0
			FIC->(DBCLOSEAREA())
		ENDIF
		Return
	endif

	IF SELECT("FIC") > 0
		FIC->(DBCLOSEAREA())
	ENDIF


//ECR - 14/08/2015 - ElaboraÁ„o da query.
If cPeriodo = _cFolMes
	//Query para retornar as informaÁıes no per˙ådo atual (MÍs em aberto)
	_cQry := "WITH TABATU AS( "
	_cQry += "SELECT  RC_FILIAL AS FILIAL, "
	_cQry += "        RC_PD AS VERBA, " 
	_cQry += "        SUM(RC_VALOR) AS VALOR "       
	_cQry += " FROM " + RetSqlName("SRC") + " "
	_cQry += " WHERE D_E_L_E_T_ <> '*' "
	_cQry += "   AND left(RC_DATA,6) > ' ' "     /// francisco neto 21/10/2016
/*
	IF UPPER(ALLTRIM(_cRegime)) == "S"                      //// francisco neto 23/09/16
		_cQry += "   AND LEFT(RC_DATA,6) = '" + _cPer3ini + "' "  
	ELSE
		_cQry += "   AND RC_DATA BETWEEN '" + _cPer1ini +"' AND '" + _cPer1fin +"' "	
	ENDIF
*/	
	_cQry += "   AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
	_cQry += " GROUP BY RC_FILIAL,RC_PD "
	_cQry += "),

Else
   	//Query para retornar as informaÁıes no per˙ådo atual (MÍs fechado)
	_cQry := "WITH TABATU AS( "
	_cQry += "SELECT  RD_FILIAL AS FILIAL, "
	_cQry += "        RD_PD AS VERBA, " 
	_cQry += "        SUM(RD_VALOR) AS VALOR "       
	_cQry += " FROM " + RetSqlName("SRD") + " "
	_cQry += " WHERE D_E_L_E_T_ <> '*' "
	_cQry += "   AND LEFT(RD_DATARQ,6) = '"+SUBSTR(_cPer1ini,1,6)+"'  " 
	_cQry += "   AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016	
	_cQry += " GROUP BY RD_FILIAL,RD_PD "
	_cQry += "),

EndIf

//Query para retornar as informaÁıes do per˙ådo anterior
_cQry += "TABANT AS ( "
_cQry += "SELECT  RD_FILIAL AS FILIAL, "        
_cQry += "        RD_PD AS VERBA, "        
_cQry += "        SUM(RD_VALOR) AS VALOR "
_cQry += " FROM " + RetSqlName("SRD") + " "
_cQry += " WHERE D_E_L_E_T_ <> '*' "   
_cQry += "   AND RD_DATARQ = '"+_cPer2ini+"'  " 
_cQry += "   AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
_cQry += "   GROUP BY RD_FILIAL,RD_PD "
_cQry += ") "

//Query final para apresentaÁ„o dos dados.
_cQry += "SELECT VERBA, "
_cQry += "       (CASE  " +CRLF
_cQry += " 				WHEN SRV.RV_P_ADP IS NULL THEN '9'" +CRLF
_cQry += " 				WHEN SRV.RV_P_ADP = ''  THEN '9'" +CRLF
_cQry += " 				Else SRV.RV_P_ADP" +CRLF
_cQry += " 		  END) AS GRP, " +CRLF
if UPPER(cCodemp) = "NX"
	_cQry += "       SRV.RV_XDESCIN AS DESCVERBA, "
else
_cQry += "       SRV.RV_DESC AS DESCVERBA, "
endif
_cQry += "       VLMESATU, "
_cQry += "       VLMESANT "
_cQry += "FROM ( "

//Query para juntar os campos em apenas uma coluna
_cQry += "	SELECT CASE " 			   
_cQry += "				WHEN FILATU IS NOT NULL THEN FILATU "			   
_cQry += "				WHEN FILANT IS NOT NULL THEN FILANT " 		   
_cQry += "		   END AS FILIAL, " 		   
_cQry += "	   	   CASE "  			   
_cQry += "				WHEN VERBAATU IS NOT NULL THEN VERBAATU " 			   
_cQry += "		   		WHEN VERBAANT IS NOT NULL THEN VERBAANT " 		   
_cQry += "	   	   END AS VERBA, " 		   
_cQry += "	   	   ISNULL(VLATU,0) AS VLMESATU, " 		   
_cQry += "	       ISNULL(VLANT,0) AS VLMESANT " 	
_cQry += "	FROM ( "

//Query para juntar o per˙ådo atual e o anterior.
_cQry += "			SELECT TABATU.FILIAL AS FILATU, "
_cQry += "			  	   TABANT.FILIAL AS FILANT, "
_cQry += "			       TABATU.VERBA AS VERBAATU, "
_cQry += "			       TABANT.VERBA AS VERBAANT, "
_cQry += "			       TABATU.VALOR AS VLATU, "
_cQry += "			       TABANT.VALOR AS VLANT "
_cQry += "		    FROM TABATU "
_cQry += "		    FULL OUTER JOIN TABANT ON TABANT.FILIAL = TABATU.FILIAL "
_cQry += "					   		      AND TABANT.VERBA = TABATU.VERBA "
_cQry += "		  ) AS TABELA "

//Join nas tabelas auxiliares
_cQry += ") AS TABFINAL "
_cQry += "LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = TABFINAL.VERBA " 

//OrdenaÁ„o dos dados
_cQry += "ORDER BY FILIAL,GRP,VERBA " 

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "SQL", .F., .T.)

dbSelectArea("SRV")

dbSelectArea("SQL")
ProcRegua(RecCount())
dbGoTop()

//ECR - 26/08/2015 - Grava uma linha em branco
aAdd( _aDetails,{"","","","","",""} )

//ECR - 26/08/2015 - Grava os t˙ëulos das colunas
aAdd( _aDetails, { "Pay Code", "Pay Elements" , "Current Month" , "Previous Month" , "Variance" , "% Variance" } )

aAuxTot := {"","",0,0,0,0}

Do While !Eof()
	IncProc( "Preparando dados para Planilha..." )
                                      
	//JVR - 29/09/2015
	If !EMPTY(aAuxTot[2]) .and. ALLTRIM(aAuxTot[2]) <> ALLTRIM(SQL->GRP) ////.and. aAuxTot[2] <> '9'
		aAdd( _aDetails,{"","","","","","","","","",""} )
		_aDetails[Len(_aDetails)][1]:= aAuxTot[1]
		If aAuxTot[2] == '9'
			_aDetails[Len(_aDetails)][2]:= "Not used"
		Else
			_aDetails[Len(_aDetails)][2]:= IIF(!EMPTY(aAuxTot[2]),RetSX3Box(GetSX3Cache("RV_P_ADP","X3_CBOX"),,,1)[VAL(aAuxTot[2])][3],"")
		EndIf
		////_aDetails[Len(_aDetails)][2]:= IIF(!EMPTY(aAuxTot[2]),RetSX3Box(GetSX3Cache("RV_P_ADP","X3_CBOX"),,,1)[VAL(aAuxTot[2])][3],"")
		_aDetails[Len(_aDetails)][3]:= aAuxTot[3]
		_aDetails[Len(_aDetails)][4]:= aAuxTot[4]
		_aDetails[Len(_aDetails)][5]:= aAuxTot[5]     
		If _aDetails[Len(_aDetails)][3] == 0 .and. _aDetails[Len(_aDetails)][4] == 0
			_aDetails[Len(_aDetails)][6]:= 0
		ElseIf _aDetails[Len(_aDetails)][4] == 0
			_aDetails[Len(_aDetails)][6] := 100
		ElseIf _aDetails[Len(_aDetails)][3] == 0
			_aDetails[Len(_aDetails)][6] := -100
		Else
			_aDetails[Len(_aDetails)][6] := ((_aDetails[Len(_aDetails)][3] - _aDetails[Len(_aDetails)][4]) / _aDetails[Len(_aDetails)][4]) * 100
		EndIf
		aAuxTot := {"","",0,0,0,0}
	EndIf

	//Grava a Linha
	aAdd( _aDetails,{"","","","","",""} )

	_aDetails[Len(_aDetails)][1]:= SQL->VERBA  
	_aDetails[Len(_aDetails)][2]:= SQL->DESCVERBA
	_aDetails[Len(_aDetails)][3]:= SQL->VLMESATU
	_aDetails[Len(_aDetails)][4]:= SQL->VLMESANT
	_aDetails[Len(_aDetails)][5]:= SQL->VLMESATU - SQL->VLMESANT
    
    //ECR - 14/08/2015 - AlteraÁ„o no c·lculo da variaÁ„o.
	If SQL->VLMESATU == 0 .and. SQL->VLMESANT == 0
		PVARIANCE := 0
	ElseIf SQL->VLMESANT == 0
		PVARIANCE := 100
	ElseIf SQL->VLMESATU == 0
		PVARIANCE := -100
	Else
		PVARIANCE := ((SQL->VLMESATU - SQL->VLMESANT) / SQL->VLMESANT) * 100
	EndIf
	
	_aDetails[Len(_aDetails)][6]:= PVARIANCE
	                  
	//JVR   
	aAuxTot[1]:= ""
	aAuxTot[2]:= SQL->GRP
	aAuxTot[3] += _aDetails[Len(_aDetails)][3]
	aAuxTot[4] += _aDetails[Len(_aDetails)][4]
	aAuxTot[5] += _aDetails[Len(_aDetails)][5]

	dbSelectArea("SQL")
	dbSkip()
EndDo       

////If !EMPTY(aAuxTot[1]) .and. Len(_aDetails) > 2 ////.and. aAuxTot[2] <> '9'
	aAdd( _aDetails,{"","","","","","","","","",""} )
	_aDetails[Len(_aDetails)][1]:= aAuxTot[1]
		If aAuxTot[2] == '9'
			_aDetails[Len(_aDetails)][2]:= "Not used"
		Else
			_aDetails[Len(_aDetails)][2]:= IIF(!EMPTY(aAuxTot[2]),RetSX3Box(GetSX3Cache("RV_P_ADP","X3_CBOX"),,,1)[VAL(aAuxTot[2])][3],"")
		EndIf
	////_aDetails[Len(_aDetails)][2]:= IIF(!EMPTY(aAuxTot[2]),RetSX3Box(GetSX3Cache("RV_P_ADP","X3_CBOX"),,,1)[VAL(aAuxTot[2])][3],"")
	_aDetails[Len(_aDetails)][3]:= aAuxTot[3]
	_aDetails[Len(_aDetails)][4]:= aAuxTot[4]
	_aDetails[Len(_aDetails)][5]:= aAuxTot[5]     
	If _aDetails[Len(_aDetails)][3] == 0 .and. _aDetails[Len(_aDetails)][4] == 0
		_aDetails[Len(_aDetails)][6]:= 0
	ElseIf _aDetails[Len(_aDetails)][4] == 0
		_aDetails[Len(_aDetails)][6] := 100
	ElseIf _aDetails[Len(_aDetails)][3] == 0
		_aDetails[Len(_aDetails)][6] := -100
	Else
		_aDetails[Len(_aDetails)][6] := ((_aDetails[Len(_aDetails)][3] - _aDetails[Len(_aDetails)][4]) / _aDetails[Len(_aDetails)][4]) * 100
	EndIf
////EndIf

dbCloseArea()

cNomArq := "P_SVR"+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_NOE_"+cNomeEmp+"-VARIANCEREPORTSUMMARY.XLS"

U_ExpToExcel( aHeader,_aDetails,cNomArq)

Return( Nil )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa   ≥   C()   ≥ Autores ≥ Norbert/Ernani/Mansano ≥ Data ≥10/05/2005≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao  ≥ Funcao responsavel por manter o Layout independente da       ≥±±
±±≥           ≥ resolucao horizontal do Monitor do Usuario.                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Tratamento para tema "Flat"≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf

Return Int(nTam)

Static Function RetSE2Data( _cChave, _cRetorno )

LOCAL _xRet

_cAliasAtu := Alias()
dbSelectArea("SE2")
dbSetOrder(6)

dbSeek( _cChave, .T. )

If SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == _cChave
	_xRet := &_cRetorno
Else
	_xRet := ""
EndIf

Return( _xRet )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥AjustaSX1 ∫ Autor ≥Fernando Radu       ∫ Data ≥  19/12/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao que ajusta o alias do Sx1                     	  ∫±±
±±∫          ≥     										                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ MP8                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function AjustaSX1(cPerg)

Local aAreaAnt := GetArea()
Local aPerg    := {}
Local nX       := 0
Local nY       := 0
Local aCpoPerg := {}

aAdd( aPerg, {'01' ,'Da Data              ' , 'Da Data             ' , 'Da Data              ', 'mv_ch1' , 'D', 8, 0, 0,'G', '','mv_par01','','','','','','','','','','','','','','','','','','S',''})
aAdd( aPerg, {'02' ,'Ate a Data           ' , 'Ate a Data          ' , 'Ate a Data           ', 'mv_ch2' , 'D', 8, 0, 0,'G', '','mv_par02','','','','','','','','','','','','','','','','','','S',''})
aAdd( aPerg, {'03' ,'Tipo Lancto          ' , 'Tipo Lancto         ' , 'Tipo Lancto          ', 'mv_ch3' , 'C', 1, 0, 0,'C', '','mv_par03','1-Manual','','','','2-Automatico','','','','','','','','','','','','','S',''})

aAdd( aCpoPerg, 'X1_ORDEM'   ) // 01
aAdd( aCpoPerg, 'X1_PERGUNT' ) // 02
aAdd( aCpoPerg, 'X1_PERSPA'  ) // 03
aAdd( aCpoPerg, 'X1_PERENG'  ) // 04
aAdd( aCpoPerg, 'X1_VARIAVL' ) // 05
aAdd( aCpoPerg, 'X1_TIPO'    ) // 06
aAdd( aCpoPerg, 'X1_TAMANHO' ) // 07
aAdd( aCpoPerg, 'X1_DECIMAL' ) // 08
aAdd( aCpoPerg, 'X1_PRESEL'  ) // 09
aAdd( aCpoPerg, 'X1_GSC'     ) // 10
aAdd( aCpoPerg, 'X1_VALID'   ) // 11
aAdd( aCpoPerg, 'X1_VAR01'   ) // 12
aAdd( aCpoPerg, 'X1_DEF01'   ) // 13
aAdd( aCpoPerg, 'X1_DEFSPA1' ) // 14
aAdd( aCpoPerg, 'X1_DEFENG1' ) // 15
aAdd( aCpoPerg, 'X1_CNT01'   ) // 16
aAdd( aCpoPerg, 'X1_DEF02'   ) // 17
aAdd( aCpoPerg, 'X1_DEFSPA2' ) // 18
aAdd( aCpoPerg, 'X1_DEFENG2' ) // 19
aAdd( aCpoPerg, 'X1_DEF03'   ) // 20
aAdd( aCpoPerg, 'X1_DEFSPA3' ) // 21
aAdd( aCpoPerg, 'X1_DEFENG3' ) // 22
aAdd( aCpoPerg, 'X1_DEF04'   ) // 23
aAdd( aCpoPerg, 'X1_DEFSPA4' ) // 24
aAdd( aCpoPerg, 'X1_DEFENG4' ) // 25
aAdd( aCpoPerg, 'X1_DEF05'   ) // 26
aAdd( aCpoPerg, 'X1_DEFSPA5' ) // 27
aAdd( aCpoPerg, 'X1_DEFENG5' ) // 28
aAdd( aCpoPerg, 'X1_F3'      ) // 29
aAdd( aCpoPerg, 'X1_PYME'    ) // 30
aAdd( aCpoPerg, 'X1_GRPSXG'  ) // 31
aAdd( aCpoPerg, 'X1_HELP'    ) // 32
aAdd( aCpoPerg, 'X1_PICTURE' ) // 33

dbSelectArea( "SX1" )
dbSetOrder( 1 )
For nX := 1 To Len( aPerg )
	If !dbSeek( cPerg + aPerg[nX][1] )
		RecLock( "SX1", .T. )
		For nY := 1 To Len( aPerg[nX] )
			If aPerg[nX][nY] <> NIL .and. !Empty( aPerg[nX][nY] )
				SX1->( &( aCpoPerg[nY] ) ) := aPerg[nX][nY]
			EndIf
		Next
		SX1->X1_GRUPO := cPerg
		MsUnlock()
	EndIf
Next

RestArea( aAreaAnt )

Return( Nil )

/*
FunÁ„o  : ExpToExcel
Objetivo: Gerar os dados no excel
Autor   : Eduardo C. Romanini
Data    : 26/08/2015
*/
*----------------------------------------------*
User Function ExpToExcel(aHeader,aBody,cArquivo)
*----------------------------------------------*
Local cOpenXml  := ""
Local cSylesXml := ""
Local cBodyXml  := ""
Local cTabXml   := ""
Local cEndXml   := ""

Local nI      := 0
Local nX      := 0
Local nTamCol := 0
Local nTamLin := 0 
Local nHandle := 0

//Define a abertura do arquivo//
cOpenXml := '<?xml version="1.0"?>' + ENTER
cOpenXml += '<?mso-application progid="Excel.Sheet"?>' + ENTER
cOpenXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+ ENTER
cOpenXml += '  	       xmlns:o="urn:schemas-microsoft-com:office:office"'+ ENTER
cOpenXml += '          xmlns:x="urn:schemas-microsoft-com:office:excel"'+ ENTER
cOpenXml += '          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+ ENTER
cOpenXml += '          xmlns:html="http://www.w3.org/TR/REC-html40">'+ ENTER
//Define os estilos do arquivo//
cSylesXml := '<Styles>' + ENTER
//Estilo padr„o
cSylesXml += '<Style ss:ID="Default" ss:Name="Normal">' + ENTER
cSylesXml += '<Alignment ss:Vertical="Bottom"/>' + ENTER
cSylesXml += '<Borders/>' + ENTER
cSylesXml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + ENTER
cSylesXml += '<Interior/>' + ENTER
cSylesXml += '<NumberFormat/>' + ENTER
cSylesXml += '<Protection/>' + ENTER
cSylesXml += '</Style>' + ENTER
cSylesXml += '</Styles>' + ENTER

//CriaÁ„o do arquivo
If File(AllTrim(cPath)+cArquivo)
	FErase(AllTrim(cPath)+cArquivo)
EndIf
nHandle:= FCreate(AllTrim(cPath)+cArquivo,,,.F.) 
If nHandle == -1
	MsgStop("N„o foi possivel gravar o relatÛrio: "+AllTrim(_cTitulo),"AtenÁ„o") 
	Return
EndIf
FWrite(nHandle,cOpenXml	)
FWrite(nHandle,cSylesXml)
FClose(nHandle)

//Define o corpo do arquivo//
cBodyXml := '<Worksheet ss:Name="Plan1">' + ENTER

//Verifica o tamanho de colunas e linhas
For nI:=1 To Len(aHeader)//Define o cabeÁalho da tabela
	If nTamCol < Len(aHeader[nI])
		nTamCol := Len(aHeader[nI])
	EndIf
	nTamLin++
Next nI
For nI:=1 To Len(aBody)
	If nTamCol < Len(aBody[nI])
		nTamCol := Len(aBody[nI])
	EndIf
	nTamLin++
Next nI
cBodyXml += '<Table ss:ExpandedColumnCount="'+AllTrim(Str(nTamCol))+'" ss:ExpandedRowCount="'+AllTrim(Str(nTamLin))+'" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + ENTER

//Zera Variavel
cBodyXml := GrvInfo(cBodyXml,AllTrim(cPath),cArquivo)

//Define o cabeÁalho da tabela
For nI:=1 To Len(aHeader)
	cTabXml += '<Row>' + ENTER
	For nX:=1 To Len(aHeader[nI])
		If ValType(aHeader[nI][nX]) == "N"
			cTabXml +=  '<Cell><Data ss:Type="Number">'+AllTrim(Str(aHeader[nI][nX]))+'</Data></Cell>' + ENTER
		Else
			cTabXml +=  '<Cell><Data ss:Type="String">'+aHeader[nI][nX]+'</Data></Cell>' + ENTER
		EndIf
	Next 
	cTabXml += '</Row>' + ENTER
	//Zera Variavel
	If Len(cTabXml) >= 500000
		cTabXml := GrvInfo(cTabXml,AllTrim(cPath),cArquivo)
	EndIf 
Next
//Define o corpo da tabela
For nI:=1 To Len(aBody)
	cTabXml += '<Row>' + ENTER
	For nX:=1 To Len(aBody[nI])
		If ValType(aBody[nI][nX]) == "N"
			cTabXml +=  '<Cell><Data ss:Type="Number">'+AllTrim(Str(aBody[nI][nX]))+'</Data></Cell>' + ENTER
		Else
			cTabXml +=  '<Cell><Data ss:Type="String">'+aBody[nI][nX]+'</Data></Cell>' + ENTER
		EndIf
	Next 
	cTabXml += '</Row>' + ENTER
	//Zera Variavel
	If Len(cTabXml) >= 500000
		cTabXml := GrvInfo(cTabXml,AllTrim(cPath),cArquivo)
	EndIf 
Next  
cTabXml := GrvInfo(cTabXml,AllTrim(cPath),cArquivo)

cBodyXml += '</Table>' + ENTER
cBodyXml += '</Worksheet>' + ENTER
//Define o fechamento do arquivo//
cBodyXml += '</Workbook>'

cBodyXml := GrvInfo(cBodyXml,AllTrim(cPath),cArquivo)

Return Nil

/*
FunÁ„o  : ExpToExcel
Objetivo: Gerar os dados no excel
Autor   : Eduardo C. Romanini
Data    : 26/08/2015
*/
*----------------------------------------------------------------*
User Function ExpToCSV(aHeader,aBody,cArquivo,cSeparador,cEndLine)
*----------------------------------------------------------------*
Local cBuffer    := ""
Local nI      := 0
Local nX      := 0
Local nHandle := 0

Local aArea := GetArea()

Default cSeparador := ","
Default cEndLine   := CRLF

//Cria o arquivo
If File(AllTrim(cPath)+cArquivo)
	FErase(AllTrim(cPath)+cArquivo)
EndIf
nHandle:= FCreate(AllTrim(cPath)+cArquivo,,,.F.) 
If nHandle == -1
	MsgStop("N„o foi possivel gravar o relatÛrio: "+AllTrim(_cTitulo),"AtenÁ„o") 
	Return
EndIf
FWrite(nHandle,cBuffer )
FClose(nHandle)

//GravaÁ„o do cabeÁalho
For nI:=1 To Len(aHeader)
	cBuffer += 	ToXlsFormat(Alltrim(aHeader[nI])) 		
	If nI < Len(aHeader)
		cBuffer += cSeparador	
	Else
		cBuffer += cEndLine		
	EndIf

Next
//GravaÁ„o dos detalhes
For nI:=1 To Len(aBody)
	For nX:=1 To Len(aBody[nI])
		cBuffer += ToXlsFormat(Alltrim(aBody[nI][nX])) 		
		If nX < Len(aBody[nI])
			cBuffer += cSeparador	
        EndIf
	Next
	If nI < Len(aBody)
		cBuffer += cEndLine		
	EndIf
	//Zera Variavel
	If Len(cBuffer) >= 500000
		cBuffer := GrvInfo(cBuffer,AllTrim(cPath),cArquivo)
	EndIf 
Next
cBuffer := GrvInfo(cBuffer,AllTrim(cPath),cArquivo)

RestArea(aArea)
Return

/*
Funcao      : GrvInfo()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------*
Static Function GrvInfo(cMsg,cDest,cArq)
*--------------------------------------*
Local nHdl := Fopen(cDest+cArq)

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

