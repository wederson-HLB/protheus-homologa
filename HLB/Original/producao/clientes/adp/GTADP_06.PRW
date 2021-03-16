#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GTADP_06 ³Autor  ³ Cesar Chena           ³ Data ³19/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rel. HLB BRASIL ADP - GL File						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ Gera somente em excel.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico HLB BRASIL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GTADP_06(cPath,cPeriodo)

PRIVATE _oWindow

Processa( {|| GTADP06Go(cPath,cPeriodo) }, "Gerando Planilha..." )

Return( .F. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ GTADP06Go³ Autor ³ Cesar Chena           ³ Data ³28/01/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processamento do Arquivo.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GTADP06Go(cPath,cPeriodo)

LOCAL _cQry := ""
LOCAL dDataInc, dDataAlt                  
LOCAL _aTitles  := { "Report Date","Pay Cycle","Country Code","Company Name","Entity ID","Entity Name","Currency","GL Account","GL Description","Cost Center Code","Cost Center Description","Amount Debit","Amount Credit" }
LOCAL _aDetails := {}
LOCAL _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
LOCAL _cPer2ini := ""
LOCAL _cPer2fin := ""
LOCAL nYear := VAL(subs(cPeriodo,4,4))
LOCAL cNomArq := ""

PRIVATE _cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer1fin := ""
Private _cDataCont := substr(_cDtContab,7,4)+substr(_cDtContab,4,2)+substr(_cDtContab,1,2)

PRIVATE _cTitulo  := "GL File"

Private _cPer3ini := ""
Private nYear3 := VAL(subs(cPeriodo,4,4))
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


//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
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

//// francisco neto 27/09/16
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


_cQry := "SELECT CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ORIGEM, CT2_VALOR "
_cQry += "FROM " + RetSqlName("CT2")+" CT2 "
_cQry += "WHERE CT2.D_E_L_E_T_=' ' AND CT2_ROTINA='GPEM110' AND CT2_MOEDLC<>'04' "
if cCodemp = "40"
	_cQry += "AND CT2.CT2_DATA = '" + _cDataCont +"' "
else
	_cQry += "AND CT2.CT2_DATA BETWEEN '" + _cPer1ini +"' AND '" + _cPer1fin +"' "     //francisco neto 21/10/2016
endif

_cQry += " AND CT2_FILORI BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
_cQry += "ORDER BY CT2.CT2_DATA"
_cQry := ChangeQuery( _cQry ) 

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "SQL", .F., .T.)

dbSelectArea("SQL")
ProcRegua(RecCount())
dbGoTop()

Do While !Eof()
	IncProc( "Preparando dados para Planilha..." )

	If SQL->CT2_DC="1" .or. SQL->CT2_DC="3"

		cConta := SQL->CT2_DEBITO
		cCusto := SQL->CT2_CCD
		aAdd( _aDetails, {} )
		aAdd( _aDetails[Len(_aDetails)], Subs(DTOS(DDATABASE),1,4)+"/"+Subs(DTOS(DDATABASE),5,2)+"/"+Subs(DTOS(DDATABASE),7,2) ) 
		aAdd( _aDetails[Len(_aDetails)], Subs(_cPer1fin,1,4)+"/"+Subs(_cPer1fin,5,2)+"/"+Subs(_cPer1fin,7,2) ) 
		aAdd( _aDetails[Len(_aDetails)], "BR" ) 
		aAdd( _aDetails[Len(_aDetails)], SM0->M0_NOME )
		aAdd( _aDetails[Len(_aDetails)], cLid )  
		aAdd( _aDetails[Len(_aDetails)], cENTITY ) 
		aAdd( _aDetails[Len(_aDetails)], "BRL" ) 
		aAdd( _aDetails[Len(_aDetails)], cConta )
		if UPPER(cCodemp) = "NX"
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CT1",1,XFILIAL("CT1")+cConta,"CT1_DESC02") )		
		else
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CT1",1,XFILIAL("CT1")+cConta,"CT1_DESC01") )
		endif
		aAdd( _aDetails[Len(_aDetails)], cCusto )
		if UPPER(cCodemp) = "NX"
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CTT",1,XFILIAL("CTT")+cCusto,"CTT_DESC02") )		
		else
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CTT",1,XFILIAL("CTT")+cCusto,"CTT_DESC01") )
		endif
		aAdd( _aDetails[Len(_aDetails)], Transform(SQL->CT2_VALOR,"@E 999,999,999.99"))
		aAdd( _aDetails[Len(_aDetails)], "0,00")
	
	Endif
	
	If SQL->CT2_DC="2" .or. SQL->CT2_DC="3"
	
		cConta := SQL->CT2_CREDITO
		cCusto := SQL->CT2_CCC
		aAdd( _aDetails, {} )
		aAdd( _aDetails[Len(_aDetails)], Subs(DTOS(DDATABASE),1,4)+"/"+Subs(DTOS(DDATABASE),5,2)+"/"+Subs(DTOS(DDATABASE),7,2) ) 
		aAdd( _aDetails[Len(_aDetails)], Subs(_cPer1fin,1,4)+"/"+Subs(_cPer1fin,5,2)+"/"+Subs(_cPer1fin,7,2) ) 
		aAdd( _aDetails[Len(_aDetails)], "BR" ) 
		aAdd( _aDetails[Len(_aDetails)], SM0->M0_NOME )
		aAdd( _aDetails[Len(_aDetails)], cLid )  
		aAdd( _aDetails[Len(_aDetails)], cENTITY ) 
		aAdd( _aDetails[Len(_aDetails)], "BRL" ) 
		aAdd( _aDetails[Len(_aDetails)], cConta )
		if UPPER(cCodemp) = "NX"
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CT1",1,XFILIAL("CT1")+cConta,"CT1_DESC02") )		
		else
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CT1",1,XFILIAL("CT1")+cConta,"CT1_DESC01") )
		endif
		aAdd( _aDetails[Len(_aDetails)], cCusto )
		if UPPER(cCodemp) = "NX"
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CTT",1,XFILIAL("CTT")+cCusto,"CTT_DESC02") )		
		else
			aAdd( _aDetails[Len(_aDetails)], POSICIONE("CTT",1,XFILIAL("CTT")+cCusto,"CTT_DESC01") )
		endif
		aAdd( _aDetails[Len(_aDetails)], "0,00")
		aAdd( _aDetails[Len(_aDetails)], Transform(SQL->CT2_VALOR,"@E 999,999,999.99"))
	
	Endif
	
	dbSelectArea("SQL")
	dbSkip()

EndDo

dbCloseArea()

cNomArq := "P_SGL"+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_NOE_"+cNomeEmp+"-GLFILE.CSV"

U_ExpToCSV(_aTitles,_aDetails,cNomArq )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

