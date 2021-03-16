#include 'totvs.ch'

/*
Funcao      : 1DREL001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Relatorio 'Sample Invoice Brazil' / Especifico para Trading.
Autor       : Eduardo C. Romanini
Data/Hora   : 26/09/2011    14:14
Revisão		: Matheus Massarotto
Data/Hora   : 18/04/2012    11:50
Módulo      : Contabilidade
*/

*---------------------*
User Function 1DREL001()
*---------------------*
Local cPerg := "1DR001"

If SM0->M0_CODIGO <> "1D"
	MsgInfo("Esse relatório é especifico para a empresa Trading.","Atenção")
	Return Nil
EndIf

AjustaSx1(cPerg)

If Pergunte(cPerg,.T.)
	GeraDados()
EndIf

Return Nil

/*
Funcao      : GeraDados()
Parametros  : 
Retorno     : Nil
Objetivos   : 
Autor       : Eduardo Romanini
Data/Hora   : 26/09/2011
*/

*-------------------------*
Static Function GeraDados()
*-------------------------*
Local cTipo    := ""
Local cDtIni   := ""
Local cDtFim   := ""
Local cConta   := ""
Local cStr     := ""
Local cNovaStr := ""
Local cFornece := "" 
Local cLoja    := ""
Local cDoc     := ""

Local nVlDeb  := 0
Local nVlCred := 0
Local nDias   := 0

Local dData 
Local dEmissao

Local aDados  := {}
Local aCampos := {}

If mv_par01 == 1  //Invoices
	cTipo := "002200"
	
	aCampos := {{"VendorNum"      ,"C",006,0},;
				{"InvoiceDate"    ,"D",008,0},;
				{"InvoiceDueDate" ,"D",008,0},;
				{"TransactionDate","D",008,0},;
				{"InvoiceNum"     ,"C",009,0},;
				{"CurrencyCod"    ,"C",003,0},;
				{"AmountCurCredit","C",020,0},;
				{"AmountCurDebit" ,"C",020,0},;
				{"Company"        ,"C",004,0},;
				{"Department"     ,"C",006,0},;
				{"CostCenter"     ,"C",006,0},;
				{"Location"       ,"C",006,0},;
				{"OffSetAccount"  ,"C",020,0},;
				{"Txt"            ,"C",100,0},;
				{"Taxes"          ,"C",009,0},;
				{"TEMSVoucherNum" ,"C",015,0}} //MSM - 18/04/2012 - Adição de campo TEMS Voucher Number para exibição.

ElseIf mv_par01 == 2 //Pagamentos
	cTipo := "001100"

	aCampos := {{"VendorNum"      ,"C",006,0},;
  			    {"Paid Date"      ,"D",008,0},;
				{"InvoiceDate"    ,"D",008,0},;
				{"InvoiceDueDate" ,"D",008,0},;
				{"InvoiceNum"     ,"C",009,0},;
				{"CurrencyCod"    ,"C",003,0},;
				{"AmountCurCredit","C",020,0},;
				{"AmountCurDebit" ,"C",020,0},;
				{"Company"        ,"C",004,0},;
				{"OffSetAccount"  ,"C",020,0},;
				{"Txt"            ,"C",100,0},;
				{"Taxes"          ,"C",009,0}}
EndIf

If Empty(mv_par04)
	MsgInfo("O diretório e o nome do arquivo de gravação não foram informados","Atenção")
	Return Nil
EndIf

cDtIni := DtoS(mv_par02)
cDtFim := DtoS(mv_par03)

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

BeginSql Alias 'QRY'
	SELECT CT2_DEBITO,CT2_CREDIT,CT2_VALOR,CT2_KEY 
	FROM %table:CT2% 
	WHERE %notDel%
      AND CT2_LOTE = %exp:cTipo%
      AND CT2_MOEDLC = '01'
      AND CT2_DC <> '4'
      AND CT2_DATA >= %exp:cDtIni%
      AND CT2_DATA <= %exp:cDtFim%
      AND CT2_KEY <> ' '
	ORDER BY CT2_DATA,CT2_DOC,CT2_LINHA
EndSql

QRY->(DbGoTop())
If QRY->(BOF() .or. EOF())
	MsgInfo("Não há dados para impressão.","Atenção")
	Return
EndIf

ProcRegua(0)

While QRY->(!EOF())

	IncProc()
		
	If cTipo == "002200" //Invoices
		SD1->(DbSetOrder(1))
		If !SD1->(DbSeek(QRY->CT2_KEY))
        	QRY->(DbSkip())
        	Loop
		EndIf

		cFornece := SD1->D1_FORNECE
		cLoja    := SD1->D1_LOJA
		
		SE2->(DbSetOrder(6))
		SE2->(DbSeek(xFilial("SE2")+SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)))

	ElseIf cTipo == "001100" //Pagamentos
		
		SE2->(DbSetOrder(1))
		If !SE2->(DbSeek(QRY->CT2_KEY))
        	QRY->(DbSkip())
        	Loop
        EndIf
 		
 		/*
 		If SE2->E2_TIPO <> "NF"
        	QRY->(DbSkip())
        	Loop
 		EndIf
        */
        If !(AllTrim(SE2->E2_TIPO) $ "NF|FT|BOL|TX|RED|FOL|FIS")
        	QRY->(DbSkip())
        	Loop
 		EndIf
        
		If AllTrim(SE2->E2_TIPO) == "NF"
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xFilial("SD1")+SE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA)))
			
			dEmissao := SD1->D1_EMISSAO
			cFornece := SD1->D1_FORNECE
			cLoja    := SD1->D1_LOJA
			cDoc     := SD1->D1_DOC
		Else
			dEmissao := SE2->E2_EMISSAO
			cFornece := SE2->E2_FORNECE
			cLoja    := SE2->E2_LOJA
			cDoc     := SE2->E2_NUM
		EndIf        

	EndIf

	cConta  := ""
	nVlDeb  := 0
	nVlCred := 0

	If !Empty(QRY->CT2_DEBITO)
		nVlDeb := QRY->CT2_VALOR
		cConta := QRY->CT2_DEBITO
	EndIf

	If !Empty(QRY->CT2_CREDIT)
		nVlCred := QRY->CT2_VALOR
		cConta  := QRY->CT2_CREDIT
	EndIf

	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+cFornece+cLoja))
    
    //Apresenta apenas os registros onde o Vendor Num está preenchido.
	If Empty(SA2->A2_P_COD)
		QRY->(DbSkip())
	   	Loop
	EndIf

	CT1->(DbSetOrder(1))
	CT1->(DbSeek(xFilial("CT1")+cConta))

	If cTipo == "002200" //Invoices

		If !Empty(SD1->D1_USERLGI)	
			cStr     := SD1->D1_USERLGI
			cNovaStr := Embaralha(cStr, 1)
			nDias    := Load2in4(SubStr(cNovaStr,16))
			dData    := CtoD("01/01/96","DDMMYY") + nDias
			dData    := DtoS(dData)				
		Else
			dData := ""
		EndIf
			
		aAdd(aDados,{AllTrim(SA2->A2_P_COD),;      //Vendor Num
		             SD1->D1_EMISSAO,;       	   //Invoice Date
		             SE2->E2_VENCREA,;      	   //Invoice Due Date
					 dData,;	                   //Transaction Date
		             AllTrim(SD1->D1_DOC),;        //Incoice Num
		             "BRL",;                       //Currency Cod
		             nVlCred,;                     //Amount Cur Credit
		             nVlDeb,;                      //Amount Cur Debit
		             "TTBR",;                      //Company  
		             AllTrim(SD1->D1_ITEMCTA),;    //Departament
		             AllTrim(SD1->D1_CC),;         //Cost Center
		             AllTrim(SD1->D1_CLVL),;       //Location
		             AllTrim(CT1->CT1_P_CONT),;    //OffSetAcconunt
		             AllTrim(SA2->A2_NOME)+AllTrim(SA2->A2_P_COD),; //Txt
		             "",;                          //Taxes
                     AllTrim(SD1->D1_P_TEMS)})     //TEMS Voucher Number //MSM - 18/04/2012 - Adição de campo TEMS Voucher Number para exibição
    ElseIf cTipo == "001100" //Pagamentos

		aAdd(aDados,{AllTrim(SA2->A2_P_COD),;      //Vendor Num
					 SE2->E2_BAIXA  ,;             //Paid Date
		             dEmissao,;			       	   //Invoice Date
		             SE2->E2_VENCREA,;      	   //Invoice Due Date
		             AllTrim(cDoc),;        	   //Incoice Num
		             "BRL",;                       //Currency Cod
		             nVlCred,;                     //Amount Cur Credit
		             nVlDeb,;                      //Amount Cur Debit
		             "TTBR",;                      //Company  
		             AllTrim(CT1->CT1_P_CONT),;    //OffSetAcconunt
		             AllTrim(SA2->A2_NOME)+AllTrim(SA2->A2_P_COD),; //Txt
		             ""})                          //Taxes
    EndIf
	
	QRY->(DbSkip())	
EndDo

//Grava arquivo em excel.
FtToExcel(aCampos,aDados)

QRY->(DbCloseArea())

Return Nil

/*
Funcao      : FtToExcel()
Parametros  : aStruct,aDados
Retorno     : Nil
Objetivos   : 
Autor       : Eduardo Romanini
Data/Hora   : 26/09/2011
*/
*---------------------------------------*
Static Function FtToExcel(aStruct,aDados)
*---------------------------------------*
Local aArea		:= GetArea()
Local cDirDocs  := MsDocPath() 
Local cDrive    := ""
Local cArquivo  := ""
Local cPath		:= ""
Local cExt      := ""
Local nY		:= 0      
Local nX        := 0      
Local cBuffer   := ""     
Local oExcelApp := Nil    
Local nHandle   := 0
Local xValor    := Nil    

//Tratamento para nome e diretorio de gravação.
SplitPath(mv_par04,@cDrive, @cPath, @cArquivo, @cExt)

If Empty(cDrive)
	MsgInfo("O diretório de gravação não foi informado.","Atenção")
	Return
EndIf

If Empty(cArquivo)
	MsgInfo("O nome do arquivo não foi informado.","Atenção")
	Return
EndIf

If Empty(cExt)
	cExt := ".CSV"
EndIf

cPath    := AllTrim(cDrive)+AllTrim(cPath)
cArquivo := AllTrim(cArquivo)+AllTrim(cExt) 

If File(cDirDocs + "\"+cArquivo)
	FErase(cDirDocs + "\"+cArquivo)
EndIf
		
SX3->(dbSetOrder(1))
If (nHandle := FCreate(cDirDocs + "\"+cArquivo)) > 0
	For nY := 1 To Len(aStruct)
		xValor := aStruct[nY][1]
		xValor := PadR(xValor,Max(aStruct[nY][3]+aStruct[nY][4],Len(xValor)))
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"
	Next nY
	cBuffer += CRLF
	//FWrite(nHandle, cBuffer)	
	//cBuffer	:= ""
	For nX := 1 To Len(aDados)
		//cLinha := aDados[nX][1]
		For nY := 1 To Len(aStruct)
			xValor := aDados[nX][nY]				
			Do Case
				Case aStruct[nY][2]=="C"
					If ValType(xValor) == "N"
						If xValor == 0
							xValor := ""
						Else
							xValor := AllTrim(Str(xValor))
						EndIf						
					EndIf
				Case aStruct[nY][2]=="N"
				    If ValType(xValor) <> "N"
						xValor := Val(xValor)
					EndIf
				Case aStruct[nY][2]=="D"
				    If ValType(xValor) <> "D"
						xValor := Stod(xValor)
  					EndIf
			EndCase
			cBuffer += ToXlsFormat(xValor)
			cBuffer += ";"
		Next nY
		cBuffer += CRLF
	Next nX	
	FWrite(nHandle, cBuffer)
	FClose(nHandle)
		
	If File(cPath+cArquivo)
		FErase(cPath+cArquivo)
	EndIf
		
	CpyS2T(cDirDocs + "\" + cArquivo, cPath, .T.)

	MsgInfo("Arquivo "+cArquivo+" gerado com sucesso","Atenção")		

	//Define se abrirá o excel
	If mv_par05 == 1 //Sim
		If ApOleClient("MsExcel") 
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath + cArquivo)
			oExcelApp:SetVisible(.T.)
		Else
			MsgStop("Microsoft Excel nao instalado.")
		EndIf
	EndIf

Else
	MsgStop("Erro na criacao do arquivo na estacao local. Contate o administrador do sistema")
EndIf	

RestArea(aArea)
Return
/*
Funcao      : AjustaSx1()
Parametros  : cPerg
Retorno     : Nil
Objetivos   : 
Autor       : Eduardo Romanini
Data/Hora   : 26/09/2011
*/
*------------------------------*
Static Function AjustaSx1(cPerg)
*------------------------------*

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}

aHlpPor := {}
Aadd( aHlpPor, "Define o tipo dos lançamentos contabeis.")
U_PUTSX1(cPerg,"01","Tipo ?","Tipo ?","Tipo ?","mv_ch1","N",01,0,1,"C","","","","S","mv_par01","Invoices","Invoices","Invoices","","Pagamentos","Pagamentos","Pagamentos","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Data inicial dos lançamentos contabeis.")
U_PUTSX1(cPerg,"02","Data De ?","Data De ?","Data De ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Data final dos lançamentos contabeis.")
U_PUTSX1(cPerg,"03","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch3","D",08,0,0,"G","","","","S","mv_par03","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor,"Diretorio e nome do Arquivo que será será gerado.")
U_PUTSX1(cPerg,"04","Arquivo?","Arquivo ?","Arquivo ?","mv_ch4","C",60,0,0,"G","","","","S","mv_par04","","","","D:\1DREL001.CSV","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Define se o arquivo será aberto automaticamente no excel.")
U_PUTSX1(cPerg,"05","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch5","N",01,0,1,"C","","","","S","mv_par05","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

Return Nil
