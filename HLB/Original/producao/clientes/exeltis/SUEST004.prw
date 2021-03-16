#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*
Funcao      : SUEST004
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de Separacao
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/

*-------------------------*
 User Function SUEST004
*-------------------------*
	
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Lista de Separação"
	Local cPict          := ""
	Local titulo       := "Lista de Separação"
	Local nLin         := 80
	Local Cabec1       := "c1"
	Local Cabec2       := "c2"
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "RELSEP"
	Private nTipo            := 15
	Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := "RELSEP"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "RELSEP"
	
	Private cString := "SC9"
	
	U_PUTSX1(cPerg,"01","Da Dt Entrega   ?" ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","   ","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"02","Ate a Dt Entrega?" ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","   ","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"03","Do Pedido       ?" ,"" ,"" ,"mv_ch3","C",06,0,0,"G","","   ","","","MV_PAR03","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"04","Ate o Pedido    ?" ,"" ,"" ,"mv_ch4","C",06,0,0,"G","","   ","","","MV_PAR04","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"05","Do Cliente      ?" ,"" ,"" ,"mv_ch5","C",06,0,0,"G","","CLI","","","MV_PAR05","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"06","Ate o Cliente   ?" ,"" ,"" ,"mv_ch6","C",06,0,0,"G","","CLI","","","MV_PAR06","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"07","De Emissao      ?" ,"" ,"" ,"mv_ch7","D",08,0,0,"G","","   ","","","MV_PAR07","","","","","","","","","","","","","","","","")
	U_PUTSX1(cPerg,"08","Ate Emissao     ?" ,"" ,"" ,"mv_ch8","D",08,0,0,"G","","   ","","","MV_PAR08","","","","","","","","","","","","","","","","")
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
	
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
	
	_cQry := " SELECT C9_PEDIDO PEDIDO, C9_CLIENTE+'-'+C9_LOJA+'-'+A1_NOME CLIENTE"
	_cQry += " , C6_ENTREG ENTREGA, C5_EMISSAO EMISSAO, B1_DESC PRODUTO"
	_cQry += " , DC_LOCAL LOCAL, DC_LOCALIZ ENDERECO, DC_QUANT QUANT1, B1_UM UM1"
	_cQry += " , CASE WHEN DC_LOCAL = '02' THEN 0 ELSE DC_QTSEGUM END QUANT2"
	_cQry += " , CASE WHEN DC_LOCAL = '02' THEN '' ELSE B1.B1_SEGUM END UM2"
	_cQry += " , B8_LOTEFOR LOTEFOR"
	_cQry += " , B8_LOTECTL LOTEINT"
	_cQry += " FROM "+RetSQlName("SC9")+" C9"
	_cQry += " INNER JOIN "+RetSQlName("SC5")+" C5 ON C5.D_E_L_E_T_ = ' ' AND C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO"
	_cQry += " INNER JOIN "+RetSQlName("SC6")+" C6 ON C6.D_E_L_E_T_ = ' ' AND C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM"
	_cQry += " INNER JOIN "+RetSQlName("SB1")+" B1 ON B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C9_PRODUTO"
	_cQry += " INNER JOIN "+RetSQlName("SA1")+" A1 ON A1.D_E_L_E_T_ = ' ' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI"
	_cQry += " INNER JOIN "+RetSQlName("SDC")+" DC ON DC.D_E_L_E_T_ = ' ' AND DC_FILIAL = C9_FILIAL AND DC_ORIGEM = 'SC6' AND DC_PEDIDO = C9_PEDIDO AND DC_ITEM = C9_ITEM AND DC_SEQ = C9_SEQUEN AND DC_LOTECTL = C9_LOTECTL"
	_cQry += " INNER JOIN ("
	_cQry += " 	SELECT B8_FILIAL, B8_LOCAL, B8_LOTEFOR, B8_LOTECTL, B8_PRODUTO"
	_cQry += " 	FROM "+RetSQlName("SB8")
	_cQry += " 	WHERE D_E_L_E_T_ = ' '"
	_cQry += " 	AND B8_SALDO > 0"
	_cQry += " 	GROUP BY B8_FILIAL, B8_LOCAL, B8_LOTEFOR, B8_LOTECTL, B8_PRODUTO"
	_cQry += " ) B8 ON B8_FILIAL = DC_FILIAL AND B8_LOCAL = DC_LOCAL AND B8_PRODUTO = DC_PRODUTO AND B8_LOTECTL = DC_LOTECTL"
	_cQry += " WHERE C9.D_E_L_E_T_ = ' '"
	_cQry += " AND C9_FILIAL = '"+xFilial("SC9")+"'"
	_cQry += " AND C6_ENTREG BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " AND C9_PEDIDO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	_cQry += " AND C5_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " AND C5_EMISSAO BETWEEN '"+DToS(MV_PAR07)+"' AND '"+DToS(MV_PAR08)+"'"
	_cQry += " ORDER BY DC_LOCAL, DC_LOCALIZ, B1_COD"
	TcQuery _cQry New Alias "QRY"
	
	SetRegua(RecCount())
	
	QRY->(dbGoTop())
	_cPedAnt := ""
	_cArm := ""
	While !QRY->(EOF())
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		If nLin > 70 .OR. _cPedAnt <> QRY->PEDIDO
			_cPedAnt := QRY->PEDIDO
			_cArm := QRY->LOCAL
			Cabec1       := "Pedido.: "+QRY->PEDIDO+" Emissão.: "+DToC(SToD(QRY->EMISSAO))+" Dt.Entrega.: "+DToC(SToD(QRY->ENTREGA))+" Cliente.: "+QRY->CLIENTE
			Cabec2       := "Arm Endereco          Qtde.Fra.     Qtde.Emb.  Lote Fornecedor    Lote Interno Produto"
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		
		@nLin,000 PSAY QRY->LOCAL
		@nLin,004 PSAY QRY->ENDERECO
		@nLin,022 PSAY QRY->QUANT1 Picture "@E 9999999"
		@nLin,030 PSAY QRY->UM1
		If QRY->QUANT2 > 0
			@nLin,035 PSAY QRY->QUANT2 Picture "@E 9999999"
			@nLin,043 PSAY QRY->UM2
		EndIf
		@nLin,047 PSAY QRY->LOTEFOR
		@nLin,066 PSAY QRY->LOTEINT
		@nLin,079 PSAY QRY->PRODUTO
		
		nLin++
		
		QRY->(dbSkip())
		
		If _cArm <> QRY->LOCAL
			_cArm := QRY->LOCAL
			nLin++
		EndIf
		
	EndDo
	QRY->(dbCloseArea())
	
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
Pedido.: XXXXXX Emissão.: 99/99/9999 Dt.Entrega.: 99/99/9999 Cliente.: XXXXXX/XX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Arm Endereco          Qtde.Fra.     Qtde.Emb.  Lote Fornecedor    Lote Interno Produto
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXXXXXXX   9999999 XX   9999999 XX  XXXXXXXXXXXXXXXXXX XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

*/
