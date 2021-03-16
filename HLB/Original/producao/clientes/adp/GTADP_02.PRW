#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ GTADP_02 ≥Autor  ≥ Cesar Chena           ≥ Data ≥22/07/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Rel. HLB BRASIL ADP - Employee Variance Report         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Obs:      ≥ Gera somente em excel.                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico HLB BRASIL                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function GTADP_02(cPath,cPeriodo)

PRIVATE _oWindow

Processa( {|| GTADP02Go(cPath,cPeriodo) }, "Gerando Planilha..." )

cPerg := "GTADP002"

/*
AjustaSX1( cPerg ) // Cria os parametros adicionados
If ! Pergunte( cPerg, .T. )
	Return( .F. )
EndIf
*/

/*
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Monta a Janela principal do Programa                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DEFINE MSDIALOG _oWindow TITLE "Summary Variance Report" FROM C(105),C(074) TO C(304),C(700) PIXEL
@ C(010),C(015) Say OemToAnsi("Esta rotina gera o relatÛrio conforme os par‚metros preenchidos.")
@ C(022),C(015) Say OemToAnsi("")
@ C(034),C(015) Say OemToAnsi("")
@ C(046),C(015) Say OemToAnsi("")
@ C(002),C(003) To C(080),C(315)
@ C(085),C(160) BmpButton Type 1 Action( Processa( {|| GTADP01Go(cPath,cPeriodo) }, "Gerando Planilha..." ), Close(_oWindow) )
@ C(085),C(195) BmpButton Type 2 Action Close(_oWindow)
@ C(085),C(230) BmpButton Type 5 Action Pergunte( cPerg, .T. )
Activate Dialog _oWindow Centered
*/

Return( .F. )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥ GTADP02Go≥ Autor ≥ Cesar Chena           ≥ Data ≥28/01/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Processamento do Arquivo.                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function GTADP02Go(cPath,cPeriodo)
Local i
LOCAL _cQry := ""
LOCAL dDataInc, dDataAlt                  
LOCAL _aTitles  := { "Employee ID", "Employee Name", "Hire Date", "Termination Date", "Pay Code", "Pay Elements" , "Current Month" , "Previous Month" , "Variance" , "% Variance" }
LOCAL _aDetails := {}
LOCAL _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
LOCAL _cPer2ini := ""
LOCAL _cPer2fin := ""
LOCAL _cPer3ini := ""
LOCAL nYear3 := VAL(subs(cPeriodo,4,4))
LOCAL nYear := Val(subs(cPeriodo,4,4))
LOCAL aHeader := {}
LOCAL cNomArq := ""
//RSB - 09/01/2017 - Customizado
LOCAL cMatCli := ""
LOCAL cSigla  := ""
LOCAL bMatProprio := .F.

PRIVATE _cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer1fin := ""
PRIVATE _cTitulo  := "Variance Report per Employee"

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

//RSB - 09/01/2017 - AdiÁ„o do campo de matricula do funcionario no Cliente
//Quando existir o campo RA_P_CDEMP serÅEpreenchido os titulos dos campos
If SRA->(FieldPos("RA_P_CDEMP")) > 0 //EXISTCPO("SX3","RA_P_CDEMP",2)
	bMatProprio := .T.
	cSigla := "HLB"
	cMatCli := "Employee ID " + SM0->M0_NOME	
Endif

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

//ECR - 26/08/2015 - GravaÁ„o do cabeÁalho
aAdd(aHeader,{"Variance Report per Employee",""})
aAdd(aHeader,{"Report Data and Time"   ,Subs(DtoS(dDataBase),1,4)+"/"+Subs(DtoS(dDataBase),5,2)+"/"+Subs(DtoS(dDataBase),7,2)+"  "+Subs(Time(),1,5)})
aAdd(aHeader,{"Country Code"           ,"BR"})
aAdd(aHeader,{"Company Name"           ,AllTrim(SM0->M0_NOME)}) 
aAdd(aHeader,{"Entity Id"              ,AllTrim(cLid)}) 
aAdd(aHeader,{"Entity Name"            ,Alltrim(cEntity)}) 
aAdd(aHeader,{"Currency"               ,"BRL"}) 
aAdd(aHeader,{"Pay Cycle"              ,Subs(_cPer1ini,1,4)+"/"+Subs(_cPer1ini,5,2)+"/"+Subs(_cPer1ini,7,2) + " - " +;
                                        Subs(_cPer1fin,1,4)+"/"+Subs(_cPer1fin,5,2)+"/"+Subs(_cPer1fin,7,2)}) 
aAdd(aHeader,{""              ,""})
aAdd(aHeader,{""              ,""})
aAdd(aHeader,{"breakdown per employee",""}) 



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
		Aviso("ATEN«√O","Filial / Matricula: "+left(MOV->_FILMAT,1)+" / "+right(MOV->_FILMAT,6)+ "Movimento sem cadastro!. Verifique!", {"Ok"} )
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
		Aviso("ATEN«√O","Filial / Matricula: "+left(FIC->_FILMAT,1)+" / "+right(FIC->_FILMAT,6)+ "Acumulados sem cadastro!. Verifique!", {"Ok"} )
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
	_cQry := "WITH TABATU AS( " +CRLF
	_cQry += "SELECT  RC_FILIAL AS FILIAL, " +CRLF
	_cQry += "        RC_MAT AS MATRICULA, " +CRLF  
	_cQry += "        RC_PD AS VERBA, " +CRLF
	_cQry += "        RC_VALOR AS VALOR " +CRLF       
	_cQry += " FROM " + RetSqlName("SRC") + " " +CRLF
	_cQry += " WHERE D_E_L_E_T_ <> '*'" +CRLF
	_cQry += "   AND left(RC_DATA,6) > ' ' "      /// francisco neto  21/10/2016
	_cQry += "   AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
	_cQry += "), " +CRLF

Else
	//Query para retornar as informaÁıes no per˙ådo atual (MÍs fechado)
	_cQry := "WITH TABATU AS( " +CRLF
	_cQry += "SELECT  RD_FILIAL AS FILIAL, " +CRLF
	_cQry += "        RD_MAT AS MATRICULA, " +CRLF
	_cQry += "        RD_PD AS VERBA, " +CRLF
	_cQry += "        RD_VALOR AS VALOR " +CRLF
	_cQry += " FROM " + RetSqlName("SRD") + " " +CRLF
	_cQry += " WHERE D_E_L_E_T_ <> '*'" +CRLF
	_cQry += "   AND RD_DATARQ = '"+SUBSTR(_cPer1ini,1,6)+"'  " +CRLF
	_cQry += "   AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " +CRLF	//francisco neto 19/09/2016
	_cQry += "), " +CRLF
EndIf

//Query para retornar as informaÁıes do per˙ådo anterior
_cQry += "TABANT AS ( " +CRLF
_cQry += "SELECT  RD_FILIAL AS FILIAL, " +CRLF
_cQry += "        RD_MAT AS MATRICULA, " +CRLF
_cQry += "        RD_PD AS VERBA, "  +CRLF
_cQry += "        RD_VALOR AS VALOR " +CRLF
_cQry += " FROM " + RetSqlName("SRD") + " " +CRLF
_cQry += " WHERE D_E_L_E_T_ <> '*' " +CRLF
_cQry += "   AND RD_DATARQ = '"+_cPer2ini+"'  " +CRLF
_cQry += "   AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " +CRLF	//francisco neto 19/09/2016
_cQry += ") "+CRLF
    
//Query final para apresentaÁ„o dos dados.
_cQry += "SELECT FILIAL,MATRICULA, " +CRLF
_cQry += "       SRA.RA_NOME AS NOME, " +CRLF
_cQry += "       SRA.RA_ADMISSA AS DTADAMISSA, " +CRLF
_cQry += "       SRA.RA_DEMISSA AS DTDEMISSA, " +CRLF     
If bMatProprio
	_cQry += "       SRA.RA_P_CDEMP AS CODMATEMP, " +CRLF
Else
	_cQry += "       '' AS CODMATEMP, " +CRLF
Endif
_cQry += "       (CASE  " +CRLF
_cQry += " 				WHEN SRV.RV_P_ADP IS NULL THEN '9'" +CRLF
_cQry += " 				WHEN SRV.RV_P_ADP = ''  THEN '9'" +CRLF
_cQry += " 				Else SRV.RV_P_ADP" +CRLF
_cQry += " 		  END) AS GRP, " +CRLF
_cQry += "       VERBA, " +CRLF
if UPPER(cCodemp) = "NX"
	_cQry += "       SRV.RV_XDESCIN AS DESCVERBA, " +CRLF
else
_cQry += "       SRV.RV_DESC AS DESCVERBA, " +CRLF
endif
_cQry += "       VLMESATU, " +CRLF
_cQry += "       VLMESANT " +CRLF
_cQry += "FROM ( " +CRLF

//Query para juntar os campos em apenas uma coluna
_cQry += "	SELECT CASE " +CRLF
_cQry += "				WHEN FILATU IS NOT NULL THEN FILATU " +CRLF
_cQry += "				WHEN FILANT IS NOT NULL THEN FILANT " +CRLF
_cQry += "		   END AS FILIAL, " +CRLF
_cQry += "		   CASE  " +CRLF
_cQry += "				WHEN MATATU IS NOT NULL THEN MATATU " +CRLF
_cQry += "				WHEN MATANT IS NOT NULL THEN MATANT " +CRLF
_cQry += "		   END AS MATRICULA, " +CRLF
_cQry += "		   CASE  " +CRLF
_cQry += "				WHEN VERBAATU IS NOT NULL THEN VERBAATU " +CRLF
_cQry += "				WHEN VERBAANT IS NOT NULL THEN VERBAANT " +CRLF
_cQry += "		   END AS VERBA, " +CRLF
_cQry += "		   ISNULL(VLATU,0) AS VLMESATU, " +CRLF
_cQry += "		   ISNULL(VLANT,0) AS VLMESANT  " +CRLF
_cQry += "	FROM ( " +CRLF

//Query para juntar o per˙ådo atual e o anterior.
_cQry += "			SELECT TABATU.FILIAL AS FILATU, " +CRLF
_cQry += "				   TABANT.FILIAL AS FILANT, " +CRLF
_cQry += "				   TABATU.MATRICULA AS MATATU, " +CRLF
_cQry += "				   TABANT.MATRICULA AS MATANT, " +CRLF
_cQry += "				   TABATU.VERBA AS VERBAATU, " +CRLF
_cQry += "				   TABANT.VERBA AS VERBAANT, " +CRLF
_cQry += "				   TABATU.VALOR AS VLATU, " +CRLF
_cQry += "				   TABANT.VALOR AS VLANT " +CRLF
_cQry += "			FROM TABATU " +CRLF
_cQry += "			FULL OUTER JOIN TABANT ON TABANT.FILIAL = TABATU.FILIAL " +CRLF
_cQry += "   AND TABANT.FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " +CRLF	//francisco neto 19/09/2016
_cQry += "								  AND TABANT.MATRICULA = TABATU.MATRICULA " +CRLF
_cQry += "								  AND TABANT.VERBA = TABATU.VERBA " +CRLF
_cQry += "		  ) AS TABAUX2 " +CRLF

//Join nas tabelas auxiliares
_cQry += ") AS TABFINAL " +CRLF
_cQry += "LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = TABFINAL.FILIAL "  +CRLF
_cQry += "                    AND SRA.RA_MAT = TABFINAL.MATRICULA "  +CRLF
_cQry += "   AND SRA.RA_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " +CRLF	//francisco neto 19/09/2016
_cQry += "LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = TABFINAL.VERBA "  +CRLF

//OrdenaÁ„o dos dados
_cQry += "ORDER BY FILIAL,MATRICULA,GRP,VERBA "

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "SQL", .F., .T.)

dbSelectArea("SRV")

dbSelectArea("SQL")
ProcRegua(RecCount())
dbGoTop()
          

//RSB - 09/01/2017 - Adicionado o decimo primeiro campo do Array.
  
//ECR - 26/08/2015 - Grava uma linha em branco
aAdd( _aDetails,{"","","","","","","","","","",""} ) //11

//ECR - 26/08/2015 - Grava os t˙ëulos das colunas
aAdd( _aDetails, {"Employee ID "+ cSigla +"", "Employee Name", "Hire Date", "Termination Date", "Pay Code", "Pay Elements" , "Current Month" , "Previous Month" , "Variance" , "% Variance" , ""+ cMatCli +""} ) //11

aAuxTot := {"","","","","","",0,0,0,0,""}

Do While !Eof()
	IncProc( "Preparando dados para Planilha..." )

	//JVR - 29/09/2015
	If !EMPTY(aAuxTot[1]) .and. ALLTRIM(aAuxTot[6]) <> ALLTRIM(SQL->GRP) 
		aAdd( _aDetails,{"","","","","","",0,0,0,0,""} )
		_aDetails[Len(_aDetails)][1]:= aAuxTot[1]
		_aDetails[Len(_aDetails)][2]:= aAuxTot[2]
		_aDetails[Len(_aDetails)][3]:= aAuxTot[3]
		If !Empty(SQL->DTDEMISSA)
	   		_aDetails[Len(_aDetails)][4]:= aAuxTot[4]
		Endif
		_aDetails[Len(_aDetails)][5]:= aAuxTot[5]
		If aAuxTot[6] == '9'
			_aDetails[Len(_aDetails)][6]:= "Not used"
		Else
			_aDetails[Len(_aDetails)][6]:= IIF(!EMPTY(aAuxTot[6]),RetSX3Box(GetSX3Cache("RV_P_ADP","X3_CBOX"),,,1)[VAL(aAuxTot[6])][3],"")
		EndIf
		_aDetails[Len(_aDetails)][7]:= aAuxTot[7]
		_aDetails[Len(_aDetails)][8]:= aAuxTot[8]
		_aDetails[Len(_aDetails)][9]:= aAuxTot[9]
		_aDetails[Len(_aDetails)][10]:= aAuxTot[10]
		If _aDetails[Len(_aDetails)][7] == 0 .and. _aDetails[Len(_aDetails)][8] == 0
			_aDetails[Len(_aDetails)][10]:= 0
		ElseIf _aDetails[Len(_aDetails)][8] == 0
			_aDetails[Len(_aDetails)][10] := 100
		ElseIf _aDetails[Len(_aDetails)][7] == 0
			_aDetails[Len(_aDetails)][10] := -100
		Else
			_aDetails[Len(_aDetails)][10] := ((_aDetails[Len(_aDetails)][7] - _aDetails[Len(_aDetails)][8]) / _aDetails[Len(_aDetails)][8]) * 100
		EndIf
		
		_aDetails[Len(_aDetails)][11]:= aAuxTot[11] //RSB - 09/01/2017 - Customizado 
		
		aAuxTot := {"","","","","","",0,0,0,0,""}
	EndIf

    //ECR - 14/08/2015 - AdequaÁ„o dos campos com a query.
	aAdd( _aDetails,{"","","","","","",0,0,0,0,""} )

	_aDetails[Len(_aDetails)][1]:= alltrim(SQL->FILIAL)+ALLTRIM(SQL->MATRICULA)
	_aDetails[Len(_aDetails)][2]:= SQL->NOME
	_aDetails[Len(_aDetails)][3]:= Subs(SQL->DTADAMISSA,1,4)+"/"+Subs(SQL->DTADAMISSA,5,2)+"/"+Subs(SQL->DTADAMISSA,7,2)
	If !Empty(SQL->DTDEMISSA)
   		_aDetails[Len(_aDetails)][4]:= Subs(SQL->DTDEMISSA,1,4)+"/"+Subs(SQL->DTDEMISSA,5,2)+"/"+Subs(SQL->DTDEMISSA,7,2)
	Endif
	_aDetails[Len(_aDetails)][5]:= SQL->VERBA
	_aDetails[Len(_aDetails)][6]:= SQL->DESCVERBA   ////SQL->GRP 
	_aDetails[Len(_aDetails)][7]:= SQL->VLMESATU
	_aDetails[Len(_aDetails)][8]:= SQL->VLMESANT
	_aDetails[Len(_aDetails)][9]:= SQL->VLMESATU - SQL->VLMESANT

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
	
	_aDetails[Len(_aDetails)][10]:= PVARIANCE
	
	_aDetails[Len(_aDetails)][11]:= SQL->CODMATEMP //RSB - 09/01/2017 - Customizado

	//JVR   
	For i:=1 to 4
		aAuxTot[i]:= _aDetails[Len(_aDetails)][i]
	Next i               
	aAuxTot[5]:= ""
	aAuxTot[6]:= SQL->GRP
	aAuxTot[7] += _aDetails[Len(_aDetails)][7]
	aAuxTot[8] += _aDetails[Len(_aDetails)][8]
	aAuxTot[9] += _aDetails[Len(_aDetails)][9]

	dbSelectArea("SQL")
	dbSkip()
EndDo

If !EMPTY(aAuxTot[1]) .and. Len(_aDetails) > 2 
	aAdd( _aDetails,{"","","","","","",0,0,0,0,""} )
	_aDetails[Len(_aDetails)][1]:= aAuxTot[1]
	_aDetails[Len(_aDetails)][2]:= aAuxTot[2]
	_aDetails[Len(_aDetails)][3]:= aAuxTot[3]
	If !Empty(SQL->DTDEMISSA)
   		_aDetails[Len(_aDetails)][4]:= aAuxTot[4]
	Endif
	_aDetails[Len(_aDetails)][5]:= aAuxTot[5]
	If aAuxTot[6] == '9'
		_aDetails[Len(_aDetails)][6]:= "Not used"
	Else
		_aDetails[Len(_aDetails)][6]:= IIF(!EMPTY(aAuxTot[6]),RetSX3Box(GetSX3Cache("RV_P_ADP","X3_CBOX"),,,1)[VAL(aAuxTot[6])][3],"")
	EndIf
	_aDetails[Len(_aDetails)][7]:= aAuxTot[7]
	_aDetails[Len(_aDetails)][8]:= aAuxTot[8]
	_aDetails[Len(_aDetails)][9]:= aAuxTot[9]
	_aDetails[Len(_aDetails)][10]:= aAuxTot[10]
	If _aDetails[Len(_aDetails)][7] == 0 .and. _aDetails[Len(_aDetails)][8] == 0
		_aDetails[Len(_aDetails)][10]:= 0
	ElseIf _aDetails[Len(_aDetails)][8] == 0
		_aDetails[Len(_aDetails)][10] := 100
	ElseIf _aDetails[Len(_aDetails)][7] == 0
		_aDetails[Len(_aDetails)][10] := -100
	Else
		_aDetails[Len(_aDetails)][10] := ((_aDetails[Len(_aDetails)][7] - _aDetails[Len(_aDetails)][8]) / _aDetails[Len(_aDetails)][8]) * 100
	EndIf 
	
	_aDetails[Len(_aDetails)][11]:= aAuxTot[11]
EndIf

dbCloseArea()

cNomArq := "P_SVE"+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_NOE_"+cNomeEmp+"-EMPLOYEEVARIANCEREPORT.XLS"

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



