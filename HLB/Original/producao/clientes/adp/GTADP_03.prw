#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"
#include "TbiCode.ch"

User Function GTADP_03(cPath,cPeriodo)

	Processa( {|| GTADP03Go(cPath,cPeriodo) }, "Gerando Planilha..." )

Return( .t. )

Static Function GTADP03Go(cPath,cPeriodo)

LOCAL _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
LOCAL _cQry := ""
LOCAL _HCol1 := {}
LOCAL _HCol2 := {}
LOCAL _aDetails := {}
LOCAL _aDetAux := {}  
LOCAL _aTotVerba := {}
LOCAL _cMatricula := ""
LOCAL _cCentroCusto := ""
LOCAL _cPer2ini := ""
LOCAL _cPer2fin := ""
LOCAL _cPer3ini := ""
LOCAL nYear3 := VAL(subs(cPeriodo,4,4))
LOCAL nYear := VAL(subs(cPeriodo,4,4))
LOCAL aHeader := {}
LOCAL cNomArq := ""
LOCAL cOldVerba := ""
LOCAL cOldTipo := ""    // Francisco Neto 24/08/16

LOCAL nQtdeVerba := 0
LOCAL nPos := 0
LOCAL nPosPro := 0
LOCAL nPosDes := 0
LOCAL nPosBas := 0
LOCAL nTotPro := 0
LOCAL nTotDes := 0
LOCAL nTotBas := 0
LOCAL nTotCPro := 0
LOCAL nTotCDes := 0
LOCAL nTotCBas := 0
LOCAL nTotal  := 0

//RSB - 09/01/2017 - Adicionar o campo de matricula do funcionario cliente.
LOCAL bMatEmp := .F.
LOCAL cSigla := ""

LOCAL cUltPosVerba := ""
LOCAL LPulaLinha := .T.
LOCAL nFor := 0
//RSB - 23/08/2017 - Parametro com as verbas que compoe o "Total employer contribution"
LOCAL cVerbasTot := SuperGetMv("MV_P_00105",.F.,"980|981|982")
PRIVATE _cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer1fin := ""
PRIVATE _cTitulo  := "Gross To Net Report"
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
Private cRV := ' '

//RSB - 09/01/2017 - Adição do campo de matricula do funcionario no Cliente
//Quando existir o campo RA_P_CDEMP será preenchido os titulos dos campos
If SRA->(FieldPos("RA_P_CDEMP")) > 0 //EXISTCPO("SX3","RA_P_CDEMP",2)
	bMatEmp := .T.
	cSigla := "HLB"
Endif

_cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"

DbSelectArea("SX5") //Armazena os dados da tabela X0 do SX5
DbSetOrder(1)

If DbSeek(xFilial("SX5")+"X0"+"CID")
	cCID := X5_DESCRI
Else
	Aviso("ATENÇÃO", "Não encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
	cENTITY := X5_DESCRI
Else
	Aviso("ATENÇÃO", "Não encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"LID")
	cLID := X5_DESCRI
Else
	Aviso("ATENÇÃO", "Não encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif

//// francisco neto  19/09/2016
DbSelectArea("SX2") //verifica compartilhamento de centro de custos
DbSetOrder(1)

If DbSeek("CTT")
	cCC := X2_MODO
Endif

If DbSeek("SRV")        // verifica compartilhamento de verbas
	cRV := X2_MODO
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
	_cAnofin := strzero(val(subs(cPeriodo,4,4))-1,2)
Else
	_cMesfin := strzero(val(subs(cPeriodo,1,2))-1,2)
	_cAnofin := subs(cPeriodo,4,4)
Endif 

_cPer2ini := _cAnofin+_cMesfin+"01"
nYear     := val(_cAnofin)	
 
If _cMesfin $ "04/06/09/11" // monta periodo 2 final
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



//ECR - 27/08/2015 - Gravação do cabeçalho
aAdd(aHeader,{"Gross To Net Report",""})
aAdd(aHeader,{"Report Data and Time"   ,Subs(DtoS(dDataBase),1,4)+"/"+Subs(DtoS(dDataBase),5,2)+"/"+Subs(DtoS(dDataBase),7,2)+"  "+Subs(Time(),1,5)})
aAdd(aHeader,{"Country Code"           ,"BR"})
aAdd(aHeader,{"Company Name"           ,AllTrim(SM0->M0_NOME)}) 
aAdd(aHeader,{"Entity Id"              ,AllTrim(cLid)}) 
aAdd(aHeader,{"Entity Name"            ,Alltrim(cEntity)}) 
aAdd(aHeader,{"Currency"               ,"BRL"}) 
aAdd(aHeader,{"Pay Cycle"              ,Subs(_cPer1ini,1,4)+"/"+Subs(_cPer1ini,5,2)+"/"+Subs(_cPer1ini,7,2) + " - " +;
                                        Subs(_cPer1fin,1,4)+"/"+Subs(_cPer1fin,5,2)+"/"+Subs(_cPer1fin,7,2)}) 
aAdd(aHeader,{"",""}) //Pula a linha
aAdd(aHeader,{"breakdown per employee, per payitem with gross amount & deductions & nett pay & employer deduction",""})

//ECR - 27/08/2015 - Ajuste na query
//Pesquisa todas as verbas presentes no período
_cQry := "SELECT DISTINCT RC_PD AS PD," + CRLF
if UPPER(cCodemp) = "NX"
	_cQry += "                RV_XDESCIN,RV_TIPOCOD,RV_CODFOL" + CRLF	
else
	_cQry += "                RV_DESC,RV_TIPOCOD,RV_CODFOL" + CRLF
endif
_cQry += " FROM " + RetSqlName("SRC")+" SRC" + CRLF
_cQry += " LEFT JOIN " + RetSqlName("SRV")+" SRV ON SRV.RV_COD = RC_PD" + CRLF
_cQry += "                                      AND SRV.D_E_L_E_T_ <> '*'" + CRLF  
_cQry += " WHERE SRC.D_E_L_E_T_ <> '*'" + CRLF 
_cQry += "   AND left(RC_DATA,6) > ' ' "     /// francisco neto 21/10/2016 
//_cQry += "   AND RC_DATA BETWEEN '" + _cPer1ini + "' AND '" + _cPer1fin + "'" + CRLF
/*
IF UPPER(ALLTRIM(_cRegime)) == "S"  .and. cPeriodo == _cFolMes                     //// francisco neto 23/09/16
	_cQry += "   AND LEFT(RC_DATA,6) = '" + LEFT(_cPer3ini,6) + "' "  + CRLF 
ELSE
	_cQry += "   AND LEFT(RC_DATA,6) = '" + LEFT(_cPer1ini,6)+"' " + CRLF 
ENDIF
*/
_cQry += "   AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " + CRLF	//francisco neto 19/09/2016
_cQry += " ORDER BY SRV.RV_TIPOCOD,SRC.RC_PD"   //Francisco Neto

_cQry := ChangeQuery(_cQry)


If cPeriodo != _cFolMes

      /// francisco neto 21/10/2016

	_cQry := "SELECT DISTINCT RD_PD AS PD," + CRLF

	if UPPER(cCodemp) = "NX"
		_cQry += "                RV_XDESCIN,RV_TIPOCOD,RV_CODFOL" + CRLF	
	else
		_cQry += "                RV_DESC,RV_TIPOCOD,RV_CODFOL" + CRLF
	endif

	_cQry += " FROM " + RetSqlName("SRD")+" SRD" + CRLF
	_cQry += " LEFT JOIN " + RetSqlName("SRV")+" SRV ON SRV.RV_COD = RD_PD" + CRLF
	_cQry += "                                      AND SRV.D_E_L_E_T_ <> '*'" + CRLF  
	_cQry += " WHERE SRD.D_E_L_E_T_ <> '*'" + CRLF 
	_cQry += "   AND RD_DATARQ = '"+SUBSTR(_cPer1ini,1,6)+"'  " +CRLF     /// francisco neto 21/10/2016 
	_cQry += "   AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " + CRLF	//francisco neto 19/09/2016
	_cQry += " ORDER BY SRV.RV_TIPOCOD,SRD.RD_PD"   //Francisco Neto
	

   ////_cQry := STRTRAN(_cQry, "RC_DATA", "RD_DATARQ")
   ////_cQry := STRTRAN(_cQry, "SRC", "SRD") 
   ////_cQry := STRTRAN(_cQry, "RC_PD", "RD_PD")
   ////_cQry := STRTRAN(_cQry, "RC_FILIAL", "RD_FILIAL")
endif


dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "SQL", .F., .T.)
dbSelectArea("SQL")
dbGoTop()

aAdd( _HCol1, "Employee ID "+cSigla+"")
aAdd( _HCol2, "Pay code")

//RSB - 09/01/2017 - Customizado
If bMatEmp 
	aAdd( _HCol1, "Employee ID "+SM0->M0_NOME+"")
	aAdd( _HCol2, "Pay code")
Endif

aAdd( _HCol1, "Employee Name")
aAdd( _HCol2, "")

aAdd( _HCol1, "Hire Date")
aAdd( _HCol2, "")

aAdd( _HCol1, "Termination Date")
aAdd( _HCol2, "")

aAdd( _HCol1, "Cost Centre ID")
aAdd( _HCol2, "")

aAdd( _HCol1, "Cost Centre Description")	
aAdd( _HCol2, "")

//Adiciona as verbas como colunas
While !Eof()
	
	//Inclui totalizador de proventos
	////If AllTrim(SQL->PD) >= "500" .and. cOldVerba < "500" 	//Francisco Neto 24/08/16
	If AllTrim(SQL->RV_TIPOCOD) = "2" .and. cOldTipo = "1"		//Francisco Neto 24/08/16	
		aAdd( _HCol1,"Total gross pay")
		aAdd( _HCol2,"")
		nPosPro := Len(_HCol1)	
	EndIf

	//Inclui totalizador de descontos	
	////If AllTrim(SQL->PD) >= "906" .and. cOldVerba < "906"	//Francisco Neto 24/08/16
	If AllTrim(SQL->RV_TIPOCOD) = "3" .and. cOldTipo = "2"		//Francisco Neto 24/08/16	
		aAdd( _HCol1,"Total employee contributions")
		aAdd( _HCol2,"")
		nPosDes := Len(_HCol1)	
	EndIf	
	
	//Adiciona a verba no cabeçalho

	if UPPER(cCodemp) = "NX"
		aAdd( _HCol1,AllTrim(SQL->RV_XDESCIN))	
	else
	aAdd( _HCol1,AllTrim(SQL->RV_DESC))
	endif

	////aAdd( _HCol1,AllTrim(SQL->RV_DESC))
	aAdd( _HCol2,AllTrim(SQL->PD))	

	//Adiciona a verba no totalizador	
	aAdd(_aTotVerba,{AllTrim(SQL->PD),0})
	
	cOldVerba := AllTrim(SQL->PD)
	cOldTipo  := ALLTrim(SQL->RV_TIPOCOD)
	
	dbSkip()
EndDo

//Inclui totalizador de bases
aAdd( _HCol1,AllTrim("Total employer contribution"))
aAdd( _HCol2,AllTrim(""))
nPosBas := Len(_HCol1)

dbCloseArea()

//Cria uma linha em branco
_aDetAux := {}
For nFor:=1 To Len(_HCol1)
	aAdd(_aDetAux,"")
Next
aAdd(_aDetails,_aDetAux)

//Cria a primeira linha de cabeçalho
_aDetAux := {}
For nFor:=1 To Len(_HCol1)
	aAdd(_aDetAux,_HCol1[nFor])
Next
aAdd(_aDetails,_aDetAux)

//Cria a segunda linha de cabeçalho
_aDetAux := {}
For nFor:=1 To Len(_HCol2)
	aAdd(_aDetAux,_HCol2[nFor])
Next
aAdd(_aDetails,_aDetAux)


//ECR - 27/08/2015 - Ajuste na query
//RSB - 24/11/2017 - Ajuste na Query para alterar o campo RC_CC para RA_CC
//Pesquisa a movimentação do período	
_cQry := "SELECT  RC_FILIAL AS FILIAL," + CRLF
_cQry += "        RC_MAT AS MATRICULA," + CRLF
_cQry += "        RA_NOME AS NOME," + CRLF
_cQry += "        RA_ADMISSA AS DTADMISSA," + CRLF
_cQry += "        RA_DEMISSA AS DTDEMISSA," + CRLF
_cQry += "        RA_CC AS CC," + CRLF
if UPPER(cCodemp) = "NX"
	_cQry += "        CTT_DESC02 AS DESCCC," + CRLF
else
_cQry += "        CTT_DESC01 AS DESCCC," + CRLF
endif
_cQry += "        RC_PD AS VERBA," + CRLF
if UPPER(cCodemp) = "NX"
	_cQry += "        RV_XDESCIN AS DESCVERBA," + CRLF
else
_cQry += "        RV_DESC AS DESCVERBA," + CRLF
endif
_cQry += "        RV_TIPOCOD AS TIPO," + CRLF    	//// Francisco neto 24/08/16
_cQry += "        RV_CODFOL AS CODFOL," + CRLF    	//// Francisco neto 24/08/16    
_cQry += "        SUM(RC_VALOR) AS VALOR" + CRLF 
_cQry += " FROM "+ RetSqlName("SRC") + " SRC"+ CRLF 
_cQry += " LEFT JOIN "+ RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = SRC.RC_FILIAL"+ CRLF
_cQry += "                     AND SRA.RA_MAT = SRC.RC_MAT"+ CRLF 
_cQry += "                     AND SRA.D_E_L_E_T_ <> '*'"+ CRLF 
_cQry += " LEFT JOIN "+ RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRC.RC_PD"+ CRLF 
if cRV = "C"
	_cQry += "                     AND SRV.D_E_L_E_T_ <> '*'"+ CRLF    // francisco neto  25/08/2016
else
	_cQry += "                     AND SRV.RV_FILIAL = SRC.RC_FILIAL AND SRV.D_E_L_E_T_ <> '*'"+ CRLF    // francisco neto  25/08/2016
endif
if cCC = "C" 
	_cQry += " LEFT JOIN "+ RetSqlName("CTT") + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC " + CRLF  // francisco neto  19/09/16
else
	_cQry += " LEFT JOIN "+ RetSqlName("CTT") + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = SRC.RC_FILIAL"+ CRLF  // francisco neto  19/09/16
endif
if cCC = "C" 
	_cQry += "                     AND CTT.D_E_L_E_T_ <> '*'"+ CRLF  // francisco neto  19/09/16
else
	_cQry += "                     AND CTT.CTT_FILIAL = SRC.RC_FILIAL AND CTT.D_E_L_E_T_ <> '*'"+ CRLF  // francisco neto  19/09/16
endif
_cQry += " WHERE SRC.D_E_L_E_T_ <> '*'"+ CRLF 
_cQry += "   AND left(RC_DATA,6) > ' ' "+ CRLF    // francisco neto  21/10/2015
////_cQry += "   AND RC_DATA BETWEEN '" + _cPer1ini + "' AND '" + _cPer1fin + "'"+ CRLF
/*
IF UPPER(ALLTRIM(_cRegime)) == "S" .and. cPeriodo == _cFolMes                      //// francisco neto 23/09/16
	_cQry += "   AND LEFT(RC_DATA,6) = '" + LEFT(_cPer3ini,6) + "' "  + CRLF 
ELSE
	_cQry += "   AND LEFT(RC_DATA,6) = '" + LEFT(_cPer1ini,6)+"' " + CRLF 
ENDIF
*/
_cQry += "   AND SRC.RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " + CRLF	//francisco neto 19/09/2016  
if UPPER(cCodemp) = "NX"
	_cQry += " GROUP BY RC_FILIAL,RC_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_CC,CTT_DESC02,RV_TIPOCOD,RC_PD,RV_XDESCIN,RV_CODFOL"+ CRLF   //francisco Neto 24/08/16
else
_cQry += " GROUP BY RC_FILIAL,RC_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_CC,CTT_DESC01,RV_TIPOCOD,RC_PD,RV_DESC,RV_CODFOL"+ CRLF   //francisco Neto 24/08/16
endif
_cQry += " ORDER BY FILIAL,MATRICULA,RA_CC,TIPO,VERBA" + CRLF	//Francisco Neto  24/08/16

If cPeriodo != _cFolMes	
//RSB - 24/11/2017 - Ajuste na Query para alterar o campo RD_CC para RA_CC.
// francisco neto  21/10/2015

	_cQry := "SELECT  RD_FILIAL AS FILIAL," + CRLF
	_cQry += "        RD_MAT AS MATRICULA," + CRLF
	_cQry += "        RA_NOME AS NOME," + CRLF
	_cQry += "        RA_ADMISSA AS DTADMISSA," + CRLF
	_cQry += "        RA_DEMISSA AS DTDEMISSA," + CRLF
	_cQry += "        RA_CC AS CC," + CRLF
	if UPPER(cCodemp) = "NX"
		_cQry += "        CTT_DESC02 AS DESCCC," + CRLF
	else
	_cQry += "        CTT_DESC01 AS DESCCC," + CRLF
	endif
	_cQry += "        RD_PD AS VERBA," + CRLF
	if UPPER(cCodemp) = "NX"
		_cQry += "        RV_XDESCIN AS DESCVERBA," + CRLF
	else
	_cQry += "        RV_DESC AS DESCVERBA," + CRLF
	endif
	_cQry += "        RV_TIPOCOD AS TIPO," + CRLF    	//// Francisco neto 24/08/16
	_cQry += "        RV_CODFOL AS CODFOL," + CRLF    	//// Francisco neto 24/08/16    
	_cQry += "        SUM(RD_VALOR) AS VALOR" + CRLF 
	_cQry += " FROM "+ RetSqlName("SRD") + " SRD"+ CRLF 
	_cQry += " LEFT JOIN "+ RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = SRD.RD_FILIAL"+ CRLF
	_cQry += "                     AND SRA.RA_MAT = SRD.RD_MAT"+ CRLF 
	_cQry += "                     AND SRA.D_E_L_E_T_ <> '*'"+ CRLF 
	_cQry += " LEFT JOIN "+ RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD"+ CRLF 
	if cRV = "C"
		_cQry += "                     AND SRV.D_E_L_E_T_ <> '*'"+ CRLF    // francisco neto  25/08/2016
	else
		_cQry += "                     AND SRV.RV_FILIAL = SRD.RD_FILIAL AND SRV.D_E_L_E_T_ <> '*'"+ CRLF    // francisco neto  25/08/2016
	endif
	if cCC = "C" 
		_cQry += " LEFT JOIN "+ RetSqlName("CTT") + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC"+ CRLF  // francisco neto  19/09/16
	else
		_cQry += " LEFT JOIN "+ RetSqlName("CTT") + " CTT ON CTT.CTT_CUSTO = SRA.RA_CC AND CTT.CTT_FILIAL = SRD.RD_FILIAL"+ CRLF  // francisco neto  19/09/16
	endif
	if cCC = "C" 
		_cQry += "                     AND CTT.D_E_L_E_T_ <> '*'"+ CRLF  // francisco neto  19/09/16
	else
		_cQry += "                     AND CTT.CTT_FILIAL = SRD.RD_FILIAL AND CTT.D_E_L_E_T_ <> '*'"+ CRLF  // francisco neto  19/09/16
	endif
	_cQry += " WHERE SRD.D_E_L_E_T_ <> '*'"+ CRLF 
	_cQry += "   AND RD_DATARQ = '"+SUBSTR(_cPer1ini,1,6)+"'  " +CRLF
	_cQry += "   AND SRD.RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " + CRLF	//francisco neto 19/09/2016  
	if UPPER(cCodemp) = "NX"
		_cQry += " GROUP BY RD_FILIAL,RD_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_CC,CTT_DESC02,RV_TIPOCOD,RD_PD,RV_XDESCIN,RV_CODFOL"+ CRLF   //francisco Neto 24/08/16
	else
	_cQry += " GROUP BY RD_FILIAL,RD_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_CC,CTT_DESC01,RV_TIPOCOD,RD_PD,RV_DESC,RV_CODFOL"+ CRLF   //francisco Neto 24/08/16
	endif
	_cQry += " ORDER BY FILIAL,MATRICULA,RA_CC,TIPO,VERBA" + CRLF	//Francisco Neto  24/08/16
	
endif

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "SQL", .F., .T.)
dbSelectArea("SQL")
dbGoTop()

While !Eof()

	IncProc( "Preparando dados para Planilha..." )
	
	if Alltrim(_cMatricula) <> Alltrim(SQL->MATRICULA) .or. AllTrim(_cCentroCusto) <> AllTrim(SQL->CC)
        
		//Imprime os totais
		If !Empty(_cMatricula)
			If nPosPro <> 0     /// francisco neto 20/10/16
				_aDetails[Len(_aDetails)][nPosPro]:= nTotPro
			EndIf
			If nPosDes <> 0
				_aDetails[Len(_aDetails)][nPosDes]:= ntotDes
			EndIf
			If nTotBas <> 0			
				_aDetails[Len(_aDetails)][nPosBas]:= nTotBas
			EndIf
		EndIf

		nTotPro := 0
		nTotDes := 0
		nTotBas := 0
        
        //RSB - 09/01/2017 -- Customizado
		If !bMatEmp
			//Cria uma posição em branco, assim como a primeira linha.		
			aAdd( _aDetails, aClone(_aDetails[1]))
			_aDetails[Len(_aDetails)][1]:= AllTrim(SQL->MATRICULA)
			_aDetails[Len(_aDetails)][2]:= AllTrim(SQL->NOME)
			_aDetails[Len(_aDetails)][3]:= Subs(SQL->DTADMISSA,1,4)+"/"+Subs(SQL->DTADMISSA,5,2)+"/"+Subs(SQL->DTADMISSA,7,2)
			If !Empty(SQL->DTDEMISSA)
	   			_aDetails[Len(_aDetails)][4]:= Subs(SQL->DTDEMISSA,1,4)+"/"+Subs(SQL->DTDEMISSA,5,2)+"/"+Subs(SQL->DTDEMISSA,7,2)
			Endif
			_aDetails[Len(_aDetails)][5]:=SQL->CC
			_aDetails[Len(_aDetails)][6]:=AllTrim(SQL->DESCCC)
		Else	
			//Cria uma posição em branco, assim como a primeira linha.		
			aAdd( _aDetails, aClone(_aDetails[1]))
			_aDetails[Len(_aDetails)][1]:= AllTrim(SQL->MATRICULA)
			_aDetails[Len(_aDetails)][2]:= posicione("SRA",1,xFilial("SRA") + AllTrim(SQL->MATRICULA),"RA_P_CDEMP")
			_aDetails[Len(_aDetails)][3]:= AllTrim(SQL->NOME)
			_aDetails[Len(_aDetails)][4]:= Subs(SQL->DTADMISSA,1,4)+"/"+Subs(SQL->DTADMISSA,5,2)+"/"+Subs(SQL->DTADMISSA,7,2)
			If !Empty(SQL->DTDEMISSA)
	   			_aDetails[Len(_aDetails)][5]:= Subs(SQL->DTDEMISSA,1,4)+"/"+Subs(SQL->DTDEMISSA,5,2)+"/"+Subs(SQL->DTDEMISSA,7,2)
			Endif
			_aDetails[Len(_aDetails)][6]:=SQL->CC
			_aDetails[Len(_aDetails)][7]:=AllTrim(SQL->DESCCC)
		Endif
	Endif
    
	//Grava o valor na coluna correspondente
	nPos := aScan( _aDetails[3],SQL->VERBA )
	
	If nPos > 0
       _aDetails[Len(_aDetails)][nPos]:= SQL->VALOR
	EndIf
    
	////If AllTrim(SQL->VERBA) < "500"	///Francisco Neto  24/08/16
	If AllTrim(SQL->TIPO) = "1"  		///Francisco Neto  24/08/16
   		nTotPro  += SQL->VALOR
   		nTotCPro += SQL->VALOR
	//ElseIf AllTrim(SQL->VERBA) < "906"	///Francisco Neto  24/08/16 
	ElseIf AllTrim(SQL->TIPO) = "2"			///Francisco Neto  24/08/16 	
		nTotDes += SQL->VALOR
		nTotCDes += SQL->VALOR
	////ElseIf AllTrim(SQL->VERBA) >= "906" .and.  AllTrim(SQL->VERBA) <> "999" 	///Francisco Neto  24/08/16
	Else
 		If AllTrim(SQL->VERBA) $ cVerbasTot
 			nTotBas += SQL->VALOR
			nTotCBas += SQL->VALOR
 		Endif
 		/*
	 		If cEmpAnt $ "QO" .and. AllTrim(SQL->VERBA) $ "732|778|779|780" //RSB - 25/07/2017 - #4913 - Somente calcular as verbas "732|778|779|780"
				nTotBas += SQL->VALOR
				nTotCBas += SQL->VALOR 
			Elseif cEmpAnt $ "KL|ET" .and. AllTrim(SQL->VERBA) $ "922|980|981|982" //RSB - 17/08/2017 - #9923 / #9918- Somente calcular as verbas "922|980|981|982"
				nTotBas += SQL->VALOR
				nTotCBas += SQL->VALOR
			Elseif cEmpAnt $ "GY" .and. AllTrim(SQL->VERBA) $ "072|074|091|123|980|981|982|B25|B35" //RSB - 23/08/2017 - #8653 Somente calcular as verbas "072|074|091|123|980|981|982|B25|B35"		 
				nTotBas += SQL->VALOR
				nTotCBas += SQL->VALOR
			//ElseIf AllTrim(SQL->TIPO) = "3" .and. AllTrim(SQL->CODFOL) <> "0047" //.and.  AllTrim(SQL->VERBA) <> "754"			///Francisco Neto  24/08/16	
			//	nTotBas += SQL->VALOR
			//	nTotCBas += SQL->VALOR
			Endif
		*/	
	EndIf

    
    //Total o valor da verba 
	nPos := aScan( _aTotVerba,{|a| AllTrim(a[1])==AllTrim(SQL->VERBA)})

	If nPos > 0
		_aTotVerba[nPos][2] += SQL->VALOR
	EndIf	

   	_cMatricula = SQL->MATRICULA
   	_cCentroCusto = SQL->CC
	dbSkip()		
EndDo	

dbCloseArea()

//Grava os totais do ultimo funcionário
//VYB - 26/08/2016 - Chamado 035814
If nPosPro <> 0
	_aDetails[Len(_aDetails)][nPosPro]:= nTotPro
EndIf
If nPosDes <> 0
	_aDetails[Len(_aDetails)][nPosDes]:= ntotDes
EndIf
_aDetails[Len(_aDetails)][nPosBas]:= nTotBas

//Grava a linha de total da empresa
aAdd( _aDetails, aClone(_aDetails[1]))

_aDetails[Len(_aDetails)][1]:= "Company Total"

For nFor:=1 To Len(_aTotVerba)
	
	nPos := aScan( _aDetails[3],_aTotVerba[nFor][1] )
	
	If nPos > 0
       _aDetails[Len(_aDetails)][nPos]:= _aTotVerba[nFor][2]
	EndIf
Next

//Grava o total dos totalizadores por tipo de verba
//VYB - 26/08/2016 - Chamado 035814
If nPosPro <> 0
	_aDetails[Len(_aDetails)][nPosPro]:= nTotCPro
EndIf
If nPosDes <> 0
	_aDetails[Len(_aDetails)][nPosDes]:= ntotCDes
EndIf
_aDetails[Len(_aDetails)][nPosBas]:= nTotCBas

cNomArq := "P_SGN"+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_NOE_"+cNomeEmp+"-GROSSTONET.XLS"

U_ExpToExcel( aHeader,_aDetails,cNomArq)

Return( Nil )

