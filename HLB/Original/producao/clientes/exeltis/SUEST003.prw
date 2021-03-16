#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*
Funcao      : SUEST003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio Manifesto de Entrega
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/

*-------------------------*
 User Function SUEST003()
*-------------------------*
	Local oSay1
	Local oSButton1
	Local oSButton2
	Local oTransp
	Local cPerg := FunName()+"1"
	Local nOpc := 0
	Private cTransp := ""
	Private aLstNF := {}
	Static oDlg
	
	U_PUTSX1(cPerg,"01","Transportadora  ?" ,"" ,"" ,"mv_ch1","C",06,0,0,"G","","SA4","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"02","Da Dt Entrega   ?" ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","   ","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"03","Ate a Dt Entrega?" ,"" ,"" ,"mv_ch3","D",08,0,0,"G","","   ","","","MV_PAR03","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"04","De Emissao      ?" ,"" ,"" ,"mv_ch4","D",08,0,0,"G","","   ","","","MV_PAR04","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"05","Ate Emissao     ?" ,"" ,"" ,"mv_ch5","D",08,0,0,"G","","   ","","","MV_PAR05","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"06","Do Municipio    ?" ,"" ,"" ,"mv_ch6","C",06,0,0,"G","","CC2","","","MV_PAR06","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"07","Ate o Municipio ?" ,"" ,"" ,"mv_ch7","C",06,0,0,"G","","CC2","","","MV_PAR07","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"08","Do Cliente      ?" ,"" ,"" ,"mv_ch8","C",06,0,0,"G","","CLI","","","MV_PAR08","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"09","Ate o Cliente   ?" ,"" ,"" ,"mv_ch9","C",06,0,0,"G","","CLI","","","MV_PAR09","","","","","","","","","","","","","","","","")
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	
	DEFINE MSDIALOG oDlg TITLE "Manifesto de Transporte" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
	If !fLstNF()
		MsgStop("O filtro nao retornou resultados.")
		Return
	EndIf
	If Len(AllTrim(cTransp)) > 0
		@ 005, 005 SAY oSay1 PROMPT "Transportadora" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 012, 005 MSGET oTransp VAR cTransp SIZE 200, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	EndIf
	DEFINE SBUTTON oSButton1 FROM 230, 150 TYPE 06 OF oDlg ENABLE ACTION (nOpc := 1,oDlg:End())
	DEFINE SBUTTON oSButton2 FROM 230, 235 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTERED
	If nOpc == 1
		bImprime()
	EndIf
Return

Static Function fLstNF()
	Local oOk := LoadBitmap( GetResources(), "LBOK")
	Local oNo := LoadBitmap( GetResources(), "LBNO")
	Local oLstNF
	
	
	_cQry := " SELECT EMISSAO, MIN(ENTREGA) ENTREGA, PEDIDO, NOTA, CLIENTE, MUNIC, SUM(TOTAL) TOTAL, VOLUME"
	_cQry += " FROM ("
	_cQry += " 	SELECT D2_EMISSAO EMISSAO, C6_ENTREG ENTREGA, D2_PEDIDO PEDIDO"
	_cQry += " 	, D2_DOC+'/'+D2_SERIE NOTA, A1_NOME CLIENTE, RTRIM(SubString(CC2_MUN,1,20))+'-'+CC2_EST MUNIC, D2_TOTAL TOTAL"
	_cQry += " 	, F2_VOLUME1 VOLUME"
	_cQry += " 	FROM "+RetSQLName("SD2")+" D2"
	_cQry += " 	INNER JOIN "+RetSQLName("SC6")+" C6 ON C6.D_E_L_E_T_ = ' ' AND C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEMPV"
	_cQry += " 	INNER JOIN "+RetSQLName("SA1")+" A1 ON A1.D_E_L_E_T_ = ' ' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA"
	_cQry += " 	INNER JOIN "+RetSQLName("CC2")+" CC2 ON CC2_EST = A1_EST AND CC2_CODMUN = A1_COD_MUN"
	_cQry += " 	INNER JOIN "+RetSQLName("SF2")+" F2 ON F2.D_E_L_E_T_ = ' ' AND F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE"
	_cQry += " 	WHERE D2.D_E_L_E_T_ = ' '"
	_cQry += " 	AND D2_FILIAL = '"+xFilial("SD2")+"'"
	SA4->(dbSetOrder(1))
	If Len(AllTrim(MV_PAR01)) > 0
		If SA4->(dbSeek(xFilial()+MV_PAR01))
			cTransp := SA4->A4_NOME
			_cQry += " 	AND F2_TRANSP = '"+MV_PAR01+"'"
		Else
			MsgStop("Transportadora Inválida.")
			Return(.F.)
		EndIf
	EndIf
	_cQry += " 	AND F2_EMISSAO BETWEEN '"+DToS(MV_PAR02)+"' AND '"+DToS(MV_PAR03)+"'"
	_cQry += " 	AND C6_ENTREG BETWEEN '"+DToS(MV_PAR04)+"' AND '"+DToS(MV_PAR05)+"'"
	_cQry += " 	AND F2_CLIENTE BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"
	_cQry += " 	AND CC2_CODMUN BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'"
	_cQry += " ) A"
	_cQry += " GROUP BY EMISSAO, PEDIDO, NOTA, CLIENTE, MUNIC, VOLUME"
	_cQry += " ORDER BY NOTA	"
	_cQry := ChangeQuery(_cQry)
	TcQuery _cQry New Alias "QRY"
	
	While !QRY->(EOF())
		aAdd(aLstNF,{.F.,DToC(SToD(EMISSAO)),DToC(SToD(ENTREGA)),PEDIDO,NOTA,CLIENTE,MUNIC,TOTAL,VOLUME})
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())
	If Len(aLstNF) <= 0
		Return(.F.)
	EndIf
	
	@ 027, 005 LISTBOX oLstNF Fields HEADER "","Emissao","Entrega","Pedido","Nota","Cliente","Municipio","Valor","Qtde.Vol." SIZE 390, 200 OF oDlg PIXEL ColSizes 50,50
	oLstNF:SetArray(aLstNF)
	oLstNF:bLine := {|| {;
		If(aLstNF[oLstNF:nAT,1],oOk,oNo),;
		aLstNF[oLstNF:nAt,2],;
		aLstNF[oLstNF:nAt,3],;
		aLstNF[oLstNF:nAt,4],;
		aLstNF[oLstNF:nAt,5],;
		aLstNF[oLstNF:nAt,6],;
		aLstNF[oLstNF:nAt,7],;
		aLstNF[oLstNF:nAt,8],;
		aLstNF[oLstNF:nAt,9];
		}}
	oLstNF:bLDblClick := {|| aLstNF[oLstNF:nAt,1] := !aLstNF[oLstNF:nAt,1],;
		oLstNF:DrawSelect()}
	
Return(.T.)

Static Function bImprime
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Manifesto de Transporte"
	Local cPict          := ""
	Local titulo       := "Manifesto de Transporte"
	Local nLin         := 80
	Local Cabec1       := "Emissao: "+DToC(MV_PAR04)+" a "+DToC(MV_PAR04)
	Local Cabec2       := "Emissao    Pedido Nota Fiscal   Cidade                           Valor Qtd.Vol."
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := FunName()
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := FunName()
	Private cString := "SD2"
	
	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _I := 0
	Local _aTot := {0,0}
	
	SetRegua(Len(aLstNF))
	
	For _I := 1 To Len(aLstNF)
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif


		@nLin,00 PSAY aLstNF[_I,2]
		@nLin,11 PSAY aLstNF[_I,4]
		@nLin,18 PSAY aLstNF[_I,5]
		@nLin,32 PSAY aLstNF[_I,7]
		@nLin,56 PSAY aLstNF[_I,8] Picture "@E 999,999,999.99"
		@nLin,73 PSAY aLstNF[_I,9] Picture "@E 999999"
		_aTot[1] += aLstNF[_I,8]
		_aTot[2] += aLstNF[_I,9]
		nLin++
	Next _I
	nLin++
	@nLin,00 PSAY "Total--->"
	@nLin,56 PSAY _aTot[1] Picture "@E 999,999,999.99"
	@nLin,73 PSAY _aTot[2] Picture "@E 999999"
	nLin+=4
	
	@nLin,00 PSAY "_______________________________     _______________________________"
	nLin++
	@nLin,00 PSAY "        Ass. Motorista                      Placa Veiculo"
	
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
	
Return
/*
0         1         2         3         4         5         6         7         8         9         10        11        12        13
*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*1
Emissao: 99/99/9999 a 99/99/9999
Emissao    Pedido Nota Fiscal   Cidade                           Valor Qtd.Vol.
99/99/9999 XXXXXX XXXXXXXXX/XXX XXXXXXXXXXXXXXXXXXXX-XX 999,999,999.99   999999
99/99/9999 XXXXXX XXXXXXXXX/XXX XXXXXXXXXXXXXXXXXXXX-XX 999,999,999.99   999999
99/99/9999 XXXXXX XXXXXXXXX/XXX XXXXXXXXXXXXXXXXXXXX-XX 999,999,999.99   999999
Total-->                                                999,999,999.99   999999

_______________________________     _______________________________
.       Ass. Motorista                      Placa Veiculo
*/
