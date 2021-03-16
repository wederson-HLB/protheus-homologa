#include "TOPCONN.CH"
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ ImportRH        บAutorณ MRW                        บ Data ณ 04/08/2015 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ - Rotina de importacao de tabelas de RH.                               บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Atualiza็ใo das tabelas pelo cliente.                                  บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/                  
*----------------------*
User Function GTRHA001()
*----------------------*
Private aHeaderL := {}
Private aColsLog := {}
Private aLegenda := {	{"BR_BRANCO"	,"Sem informa็๕es do registro."},;
						{"BR_VERMELHO"	,"Registro nใo foi integrado."},;
						{"BR_AMARELO"	,"Registro integrado, mas possui alertas."},;
		   		  		{"BR_VERDE"		,"Registro integrado com sucesso."}} 

Private oBR_VERMELHO	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oBR_VERDE 		:= LoadBitmap( GetResources(), "BR_VERDE" )
Private oBR_AMARELO		:= LoadBitmap( GetResources(), "BR_AMARELO" )
Private oBR_BRANCO		:= LoadBitmap( GetResources(), "BR_BRANCO" )
                
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da tela de processamento.                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 000, 000 TO 120, 430 DIALOG oLeTxt TITLE "Importa็ใo de informa็๕es dos Funcionแrios."
@ 005, 005 TO 058, 213

@ 010,010 BUTTON "Deseja escolher um arquivo? "           SIZE 198, 015 ACTION (GTRhGetFile(),ShowLog())
@ 025,010 BUTTON "Deseja escolher um grupo de arquivos? " SIZE 198, 015 ACTION (GTRhGetDir(),ShowLog())
@ 040,010 BUTTON "Abandona processamento"                 SIZE 198, 015 ACTION Close(oLeTxt)

ACTIVATE DIALOG oLeTxt CENTERED

Return

/* 
Funcao      : ShowLog
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Apresenta็ใo do Log de processamento.
Autor     	: Jean Victor Rocha
Data     	: 15/09/2015                     
*/
*-----------------------*
Static Function ShowLog()
*-----------------------*
Local aButtons := {}

//Tela de Lof Apos o processamento
oDlg := MSDIALOG():New(000,000,400,600, "Log de Processamento",,,,,,,,,.T.)
                                  
//Tela de log de processamento                                        ณ
aHeaderL := {}                                                                                                   
AADD(aHeaderL,{ TRIM("Status")	 ,"STATUS"	,"@BMP"	,002,0,"","","C","",""})
AADD(aHeaderL,{ TRIM("Arquivo")	 ,"FILE"	,"@!  " ,040,0,"","","C","",""})
AADD(aHeaderL,{ TRIM("Linha")	 ,"LINE"	,"@!  "	,003,0,"","","N","",""})
AADD(aHeaderL,{ TRIM("Matricula"),"MATR"	,"@!  "	,006,0,"","","C","",""})
AADD(aHeaderL,{ TRIM("Nome")	 ,"NAME"	,"@!  "	,080,0,"","","C","",""})
AADD(aHeaderL,{ TRIM("Mensagem") ,"MSG"	    ,"@!  "	,250,0,"","","C","",""})

oGetLog:= MsNewGetDados():New(010,010,165,292,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
                                "",{"STATUS"},,9999999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()",oDlg,aHeaderL, aColsLog, {|| })
oGetLog:AddAction("STATUS", {|| BrwLegenda("Status do Registro", "Legenda", aLegenda) })

oDlg:bInit	:= {|| EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()},,aButtons)}
oDlg:lCentered := .T.
oDlg:Activate()


Return .T.                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ GTRhGetFile     บAutorณ MRW                        บ Data ณ 04/08/2015 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ - Le arquivo individual.                                               บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Atualiza็ใo das tabelas pelo cliente.                                  บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function GTRhGetFile()

Local nOpc		 := 0

Local cCadastro:= "Importa็ใo de informa็๕es"
Local aSay 	   := {}
Local aButton  := {}

Private oLeTxt    := {}
Private cArqTxt   := ''
Private cFileExcel:= ""

aAdd( aSay, "Importa็ใo de informa็๕es dos Funcionแrios." )

aAdd( aButton, { 5, .T., { || cFileExcel := cGetFile( "(*.xls) |*.XLS| (*.xlsx) |*.XLSX|", "Selecione o arquivo Excel", 1, cFileExcel, .T. ) } } )
aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
aAdd( aButton, { 2, .T., { || FechaBatch() } } )

FormBatch( cCadastro, aSay, aButton )

If nOpc == 1                                                                 
	Processa( {|| GTProc001( cFileExcel ) }, "Iniciando Importa็ใo!...." )
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ GTRhGetFile     บAutorณ MRW                        บ Data ณ 04/08/2015 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ - Le arquivo individual.                                               บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Atualiza็ใo das tabelas pelo cliente.                                  บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function GTRhGetDir()

Local nOpc		:= 0

Local cCadastro:= "Importa็ใo de informa็๕es"
Local aSay 	   := {}
Local aButton  := {}

Local cPath     := ""
Local aArqs     := {}

Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ""
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

Private oLeTxt    := {}
Private cArqTxt   := ''
Private cFileExcel:= ""

aAdd( aSay, "Importa็ใo de informa็๕es dos Funcionแrios." )

aAdd( aButton, { 5, .T., { || cPath:= cGetFile( cFile, cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.) } } )
aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
aAdd( aButton, { 2, .T., { || FechaBatch() } } )

FormBatch( cCadastro, aSay, aButton )

cPath:= AllTrim( cPath )

// Se houve a digita็ใo da tabela, pelo operador, a mesma deverแ ser retirada
If "XLS" $ cPath .Or. "xls" $ cPath
	cPath:= Subs( cPath, 1, rAt( "\", cPath ) - 1 )
EndIf

// O array esta por ordem de arquivo e data da cria็ใo
cPath+= "\"
aArqs:= Directory( cPath + "*.XLS?" )

If nOpc == 1
	For nI:= 1 To Len( aArqs )
		cFileExcel:= cPath + AllTrim( aArqs[nI][1] )
		Processa( {|| GTProc001() }, "Iniciando Importa็ใo!...." )
	Next		
Else
	MsgInfo( "Processamento encerrado!...", "Nenhma informa็ใo foi importada!..." )
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ GTProc001       บAutorณ MRW                        บ Data ณ 06/08/2015 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ - Rotina para leitura do arquivo (.XLS) e chamada das rotinas de       บฑฑ
ฑฑบ         ณ importacao.                                                            บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Atualiza็ใo da base de dados.                                          บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function GTProc001()

Local cRenamExec:= {}

Private aLogErr := {}

If File( cFileExcel )
	RH001Process()

	cRenamExec:= Substr( cFileExcel, 1, At( ".XLS", UPPER(cFileExcel)  ) ) 
	cRenamExec+= "PROC"

	If FRename( cFileExcel, cRenamExec ) == -1
		MsgInfo("Erro ao renomear a planilha. " + cFileExcel)
	EndIf		
Else
	MsgInfo("Arquivo origem Excel nao localizado. " + cFileExcel)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ  RH001Process   บAutorณ MRW                        บ Data ณ 06/08/2015 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ  - L๊ planilhas, o nome do campos e as linhas de informa๕es seram      บฑฑ
ฑฑบ         ณ armazenadas em um array para uso na rotina automแtica.                 บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Generico                                                               บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                 บฑฑ
ฑฑฬอออออออออออออออัอออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Programador  ณ  Data   ณ Motivo da Alteracao                                    บฑฑ
ฑฑฬอออออออออออออออุอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  ECR          ณ 03/09/15ณ Altera็ใo na l๓gica de leitura dos arquivos            บฑฑ
ฑฑศอออออออออออออออฯอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RH001Process()

Local oFile		:= {}

Local cFileVbs 	:= CriaTrab( .F., .F. )
Local cPathTemp	:= GetTempPath()
Local cLn		:= Chr( 13 ) + Chr( 10 )

Local aCabec	:= {}
Local aItens	:= {}
Local aLinha    := {}

Local nLastKey  := 0
Local nCont		:= 0
Local nPosQbr   := 0
Local nPosCpo   := 0
Local nHl       := 0
Local nTamArq   := 0

Local lOk		:= .t.

Local cCampo	:= ""
Local cBuffer	:= ""
Local cLinha    := ""
  
Private oFT

// Eliminando arquivos antes de iniciar qualquer opera็ใo
FErase( cPathTemp + "\" + cFileVbs + ".vbs" )
FErase( cPathTemp + "\" + cFileVbs + ".txt" )

// Leitura do arquivo (XLS) e cria็ใo do arquivo (TXT).
oFile:= FCreate( cPathTemp + "\" + cFileVbs + ".vbs" )

If !oFile < 0
	//Variaveis 'Globais'
	FWrite( oFile, 'dim ft, fs'					  												+ cLn )
	FWrite( oFile, 'dim sFileOk'				  												+ cLn )
	FWrite( oFile, 'dim sChar'					  												+ cLn )
	FWrite( oFile, 'lCountCols = True'															+ cLn )
	FWrite( oFile, 'lCountRows = True'													   		+ cLn )
	FWrite( oFile, 'I = 0'																   		+ cLn )
	FWrite( oFile, 'nRows = 0'															   		+ cLn )
	FWrite( oFile, 'nCols = 0'															   		+ cLn )
	FWrite( oFile, 'WS_Count = 0'														   		+ cLn )
	FWrite( oFile, 'sFile = ""'																	+ cLn )
	FWrite( oFile, 'sstr = ""'																	+ cLn )
	//Inicio
	FWrite( oFile, 'Set objExcel = CreateObject("Excel.Application")'			   				+ cLn )
	FWrite( oFile, 'Set objWorkbook = objExcel.Workbooks.Open("' + cFileExcel + '")'			+ cLn )
	FWrite( oFile, 'WS_Count = objWorkbook.Worksheets.Count'					   				+ cLn )    
	//Abre os novos arquivos TXT
	FWrite( oFile, 'Set fs = CreateObject("Scripting.FileSystemObject")'			   			+ cLn )
	FWrite( oFile, 'Set ft = fs.CreateTextFile("' + cPathTemp + cFileVbs + '.txt", True)'		+ cLn )
	//Processa todas as planilhas do excel
	FWrite( oFile, 'For I = 1 To WS_Count'														+ cLn )
	//Restart das variaveis
 	FWrite( oFile, '	lCountCols = True'														+ cLn )
	FWrite( oFile, '    lCountRows = True'														+ cLn )
	FWrite( oFile, '    nRows = 0'																+ cLn )
	FWrite( oFile, '    nCols = 0'												  				+ cLn )
	FWrite( oFile, '	sstr = ""'																+ cLn )
	FWrite( oFile, '    sFile = ""'												  	   			+ cLn )
	FWrite( oFile, '    nameSheet = objWorkbook.Worksheets(I).Name'					   			+ cLn )
    //Valida linha
	FWrite( oFile, '    While lCountCols' 														+ cLn )
	FWrite( oFile, '       nCols = nCols + 1'													+ cLn )
	FWrite( oFile, '       If objWorkbook.Sheets(nameSheet).Cells(1, nCols).Value = "" Then'	+ cLn )
	FWrite( oFile, '          nCols = nCols - 1' 												+ cLn )
	FWrite( oFile, '          lCountCols = False' 												+ cLn )
	FWrite( oFile, '       End If' 																+ cLn )
	FWrite( oFile, '    Wend' 																	+ cLn )
    //Processa linhas
	FWrite( oFile, '    While lCountRows'													 	+ cLn )
	FWrite( oFile, '        nRows = nRows + 1' 													+ cLn )
	FWrite( oFile, '        If (objWorkbook.Sheets(nameSheet).Cells(nRows, 1).Value &'+;
								' objWorkbook.Sheets(nameSheet).Cells(nRows, 2).Value &'+;
								' objWorkbook.Sheets(nameSheet).Cells(nRows, 3).Value) = "" Then' 		+ cLn )
	FWrite( oFile, '            lCountRows = False' 										  			+ cLn )
	FWrite( oFile, '        Else' 															 			+ cLn )
	FWrite( oFile, '            sStr = "' + Chr( 39 ) + '"' 								   			+ cLn )
	FWrite( oFile, '            For x = 1 To nCols'  								   		 	   		+ cLn )
	FWrite( oFile, '               sstr = sstr & objWorkbook.Sheets(nameSheet).Cells(nRows, x).Value' 	+ cLn )
	FWrite( oFile, '               If x = nCols Then'  								   			+ cLn )
	FWrite( oFile, '                  sStr = sStr + "' + Chr( 39 ) + '"+chr(13)+chr(10)' 		+ cLn )
	FWrite( oFile, '               Else'  									 					+ cLn )
	FWrite( oFile, '                  sStr = sStr + "' + Chr(39) + "," + Chr( 39 ) + '"' 		+ cLn )
	FWrite( oFile, '               End If'  													+ cLn )
	FWrite( oFile, '            Next' + cLn )
	FWrite( oFile, '            If sstr <> "" Then'  											+ cLn )
	FWrite( oFile, '                sFile = sFile & "" & sstr & ""'  							+ cLn )
	FWrite( oFile, '            End If'  								   						+ cLn )
	FWrite( oFile, '        End If'  								  							+ cLn )
	FWrite( oFile, '    Wend'  								 									+ cLn )
	FWrite( oFile, '    sFile = Mid(sFile, 1, Len(sFile) - 1)' 									+ cLn )
	
	//ECR - 22/10/2015 - Tratamento para caracteres especiais
	FWrite( oFile, '    For n=1 To Len(sFile)' 													+ cLn )	
	FWrite( oFile, '		sChar = Mid(sFile,n,n)' 											+ cLn )	
	FWrite( oFile, '		ascchar = Asc(sChar)'	 											+ cLn )	
	FWrite( oFile, '		If ascchar < 192 Then'	 											+ cLn )	
	FWrite( oFile, '			sChar = Chr(ascchar)'	 										+ cLn )	
	FWrite( oFile, '		Else'					 											+ cLn )	
	FWrite( oFile, '			If ascchar >= 240 And ascchar <= 255 Then'						+ cLn )
	FWrite( oFile, '				sChar = Chr(ascchar - 16)'									+ cLn )
	FWrite( oFile, '			ElseIf ascchar >= 192 and ascchar <= 239 Then'					+ cLn )
	FWrite( oFile, '				sChar = Chr(ascchar - 64)'									+ cLn )
	FWrite( oFile, '			End If'															+ cLn )
	FWrite( oFile, '		End If'																+ cLn )
	FWrite( oFile, '		sFileOk = sFileOk & sChar'											+ cLn )
	FWrite( oFile, '	Next	'																+ cLn )
	FWrite( oFile, '    ft.WriteLine(sFileOk)' 													+ cLn )

	FWrite( oFile, 'Next'  								   										+ cLn )
	FWrite( oFile, 'ft.Close'  								  									+ cLn )
	FWrite( oFile, 'objExcel.Quit'  								   							+ cLn )
	FWrite( oFile, 'fs.GetFile("'+cFileVbs+'.txt").Name = "OK_'+cFileVbs+'.txt"')
	FClose( oFile)

	MsgRun("Executando vbs de Import" + ".",,{|| shellExecute("Open",cPathTemp + cFileVbs + ".vbs","",cPathTemp,1)} )

	// Pode-se interromper o processo neste ponto, at้ a cri็ใo do arquivo (vbs).
	While !File( cPathTemp + "\" + cFileVbs + ".txt" )
		If nLastKey == 27
			lOk := .f.
		Endif
	EndDo

	// Nใo houve interrup็ใo do processo.
	If !lOk
	   	MsgAlert("Opera็ใo cancelada pelo usuแrio.","Aten็ใo")
       	Return
	Endif
	     
	//Pausa para o processamento do VBA.
	While FILE(cPathTemp + "\" + cFileVbs + ".txt")
		Sleep(1000)
	EndDo	     
	     	
	//Define a variavel de tratamento de arquivo
	oFT   := fT():New()//FUNCAO GENERICA
	oFT:FT_FUse(cPathTemp + "\OK_" + cFileVbs + ".txt") // Abre o arquivo
	oFT:FT_FGOTOP()      // Posiciona no inicio do arquivo                                  
	While !oFT:FT_FEof()
		cLinha := oFT:FT_FReadln()        // Le a linha		
		If !EMPTY(cLinha)
			aLinha := separa(UPPER(cLinha),",")  // Sepera para vetor

			//Tratamento de cabecalho.
			If aScan(aLinha,{|X| UPPER(ALLTRIM(X)) == "'KEY_DATA.EMPLOYEE_ID'"}) <> 0
		   		//Caso ainda nใo tenha tratado cabe็alho, atribui, senใo despreza.
		   		If Len(aCabec) == 0
			   		aCabec := aClone(aLinha)
			   	EndIf
			ElseIf aScan(aLinha,{|X| UPPER(ALLTRIM(X)) == "'(KEY_DATA.EMPLOYEE_ID)'"}) == 0
		  		aAdd(aItens,aLinha)
			EndIf
		EndIf
		oFT:FT_FSkip() // Proxima linha
	Enddo
	oFT:FT_FUse()

	////////////////////////////////////////////
	//      Chamada da rotina de gera็ใo      //
	////////////////////////////////////////////
	If Len(aCabec) <> 0 .and. Len(aItens) <> 0
   		FnRtGerar( aCabec, aItens)
 	Else
 	   	MsgAlert("Nใo foi possํvel efetuar a leitura do arquivo.","Aten็ใo")
		Return   	
 	EndIf

	// Eliminando arquivos criados
	FErase( cPathTemp + "\" + cFileVbs + ".vbs" )
	FErase( cPathTemp + "\OK_" + cFileVbs + ".txt" )

Else    
  	MsgAlert("Nใo foi possํvel gerar script de leitura.","Aten็ใo")
	Return
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FnArrayCab บ Autor บ MRW              บ Data ณ  06/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ - Monta o array com as informa็๕es da rotina de grava็ใo.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
Static Function FnRtGerar( aCabec, aItens )

Local aRetInfo := {}

Local aEstSRA  := {}
Local aAuxSRA  := {}
Local aAuxSRB  := {}
Local aTabSRA  := {}
Local aTabSRB  := {}
Local aEvento  := {}

Local cCampo   := ""
Local cCpoExc  := ""
Local cMatAnt  := ""
Local cMatAtu  := ""
Local cOperac  := ""

Local nI       := 0
Local nY 	   := 0
Local i		   := 0
Local j		   := 0
Local nOper    := 3
Local nPEnd1   := 0   
Local nPEnd2   := 0
Local nPEnd3   := 0
Local nPEnd4   := 0
Local nPMat    := 0
Local nPOper   := 0
Local nPAlter  := 0
Local nItens   := Len(aItens)

Local xValor
Local xAuxValor

Private aCont:= Array(6)

Private cConvCpo := ""
Private cConvItem:= ""
Private cMensagem:= ""
Private cZeros   := "0000000000"
Private nPaisExt := ""
Private nZ       := 0

Private dAdmissa  := CtoD( "  /  /  " )

Private nPDocumen:= 0

Private lMsErroAuto:= .f.

//Pesquisa a tabela SRA para retornar a estrutura dos campos
aTabStru := {"SRA","SRB"}

aEstSRA := {}
aEstSRB := {}

SX3->(DbSetOrder(1))    
If !(SX3->(DbSeek("SRA")))
  	MsgAlert("A tabela SRA nใo foi ecnontrada na base de dados.","Aten็ใo")
	Return
EndIf
While SX3->(!EOF()) .and. AllTrim(SX3->X3_ARQUIVO) == "SRA"
    If X3Uso(SX3->X3_USADO) .and. AllTrim(SX3->X3_CONTEXT) <> "V"
		aAdd(aEstSRA,{AllTrim(SX3->X3_CAMPO),;                 //[1]:Campo
		              AllTrim(SX3->X3_TIPO ),;                 //[2]:Tipo
		              SX3->X3_TAMANHO,;                        //[3]:Tamanho
		              SX3->X3_DECIMAL,;                        //[4]:Decimal
		              If(X3Obrigat(SX3->X3_CAMPO),.T.,.F.)})   //[5]:Obrigat๓rio
	EndIf
	SX3->(DbSkip())
EndDo
If !(SX3->(DbSeek("SRB")))
  	MsgAlert("A tabela SRB nใo foi ecnontrada na base de dados.","Aten็ใo")
	Return
EndIf
While SX3->(!EOF()) .and. AllTrim(SX3->X3_ARQUIVO) == "SRB"
    If X3Uso(SX3->X3_USADO) .and. AllTrim(SX3->X3_CONTEXT) <> "V"
		aAdd(aEstSRB,{AllTrim(SX3->X3_CAMPO),;                 //[1]:Campo
		              AllTrim(SX3->X3_TIPO ),;                 //[2]:Tipo
		              SX3->X3_TAMANHO,;                        //[3]:Tamanho
		              SX3->X3_DECIMAL,;                        //[4]:Decimal
		              If(X3Obrigat(SX3->X3_CAMPO),.T.,.F.)})   //[5]:Obrigat๓rio
	EndIf
	SX3->(DbSkip())
EndDo

// Identifica a posi็ใo da opera็ใo a ser realizada.
nPOper		:= aScan( aCabec, "'KEY_DATA.EVENT_TYPE'" )
//Identifica a posi็ใo da matricula e nome
nPMatCab	:= aScan( aCabec, "'KEY_DATA.PAYROLL_PAYEE_ID'" )
nPNomeCab	:= aScan( aCabec, "'PERSONAL_DATA_NAME.FULL_NAME'" )
//Identifica a posi็ใo do tipo de documento
nPTipoDoc	:= aScan( aCabec, "'PERSONAL_DATA_IDENTIFICATION.IDENTITY_TYPE'" )
//Identifica a posi็ใo do tipo de relacionamento (PM=Mae;PF=Pai)
nPTipoRela	:= aScan( aCabec, "'FAMILY.TYPE_OF_RELATIONSHIP'" )
//Identifica a posi็ใo da matricula na estrutura.
nPMatSRA	:= aScan(aEstSRA,{|a| AllTrim(a[1])=="RA_MAT"})
nPMatSRB	:= aScan(aEstSRB,{|a| AllTrim(a[1])=="RB_MAT"})

////////////////////////////////////////////
//Prepara็ใo das informa็๕es para grava็ใo//
////////////////////////////////////////////
aSort(aItens,,,{|x,y| X[nPMatCab]<Y[nPMatCab]})
//Loop nas linhas do arquivo
For nI:=1 To Len(aItens)
	//Insere no Array de Log, para identifica็ใo de Linha.
	aAdd(aColsLog, {oBR_BRANCO,cFileExcel,nI,aItens[nI][nPMatCab],aItens[nI][nPNomeCab],"",.F.})
	
	//Identifica se trata-se de um novo funcionแrio...
    If AllTrim(aItens[nI][nPMatCab]) <> AllTrim(cMatAnt)
    	lNewLine := .T.
        aAuxSRA := Array(Len(aEstSRA))
		aFill(aAuxSRA,"")
    //...ou de informa็๕es complementares do mesmo funcionแrio.
    Else
    	lNewLine := .F.   
    	nLinMat := aScan(aTabSRA,{|a| AllTrim(a[nPMatSRA]) == AllTrim(StrTran(aItens[nI][nPMatCab],"'",""))})
    	If aColsLog[nI][1] == oBR_BRANCO
	    	aColsLog[nI][1] := oBR_AMARELO
	    EndIf
    	aColsLog[nI][6] += "> Registro Agrupado com outro jแ existente!"+CHR(13)+CHR(10)
    EndIf                             
    
    aAuxSRB := Array(Len(aEstSRB))
    
    //Retorna a matricula    
  	cMatAnt:= aItens[nI][nPMatCab]
    
    //Retorna o tipo de documento
    cTipoDoc:= AllTrim(aItens[nI][nPTipoDoc])
    
    //Retorna o tipo de Relacionamento
    cTipoRela:= AllTrim(aItens[nI][nPTipoRela])
    
    //Loop nos campos de cada linha
   	For nY:=1 To Len(aItens[nI])
	    aTabxCpo := {}
	    
	    //Retorna o nome do campo do arquivo
		cCampo := aCabec[nY]
		cCampo := AllTrim(StrTran(cCampo,"'",""))
	    
	    //Retorna o valor do campo do arquivo    
		cValor := SUBSTR(AllTrim(aItens[nI][nY]),2,LEN(AllTrim(aItens[nI][nY]))-2)//remove o primeiro e ultimo caracter.
		
		//Pula a linha se o campo estiver em branco ou se for chave para informa็ใo complementar do mesmo funcionแrio.	    
	    If Empty(cValor) .or. (!lNewLine .and. Left(cCampo,3) == "KEY")
	    	Loop
	    EndIf
	    
	    //Tratamento de campos especiais
	    If cCampo == "PERSONAL_DATA_IDENTIFICATION.IDENTITY_NUMBER"
	    	If cTipoDoc == "'CPF'"
	    		aTabxCpo := {{"SRA","RA_CIC"}}
	    	ElseIf cTipoDoc == "'PIS'"
	    		aTabxCpo := {{"SRA","RA_PIS"}}
	    	ElseIf cTipoDoc == "'RG'"
	       		aTabxCpo := {{"SRA","RA_RG"}}
	    	ElseIf cTipoDoc == "'CTPS'"
		    	aTabxCpo := {{"SRA","RA_NUMCP"}}
	    	ElseIf cTipoDoc == "'CNH'"
		    	aTabxCpo := {{"SRA","RA_HABILIT"}}
	    	ElseIf cTipoDoc == "'CRE'"
		    	aTabxCpo := {{"SRA","RA_RESERVI"}}
	    	ElseIf cTipoDoc == "'TE'"
		    	aTabxCpo := {{"SRA","RA_TITULOE"}}
	    	ElseIf cTipoDoc == "'PRO'"
		    	aTabxCpo := {{"SRA","RA_CODIGO"}}
	    	ElseIf cTipoDoc == "'RNE'"
		    	aTabxCpo := {{"SRA","RA_RNE"}}
	    	ElseIf cTipoDoc == "'NAT'"
		    	aTabxCpo := {{"SRA","RA_NUMNATU"}}
			EndIf    	
	    	
	    ElseIf cCampo == "PERSONAL_DATA_IDENTIFICATION.IDENTITY_NUMBER_DATE_OF_ISSUE""
	    	If cTipoDoc == "'RG'"
	       		aTabxCpo := {{"SRA","RA_DTRGEXP"}}
	    	ElseIf cTipoDoc == "'CTPS'"
		    	aTabxCpo := {{"SRA","RA_DTCPEXP"}}
	    	ElseIf cTipoDoc == "'CNH'"
		    	aTabxCpo := {{"SRA","RA_DTEMCNH"}}
	    	ElseIf cTipoDoc == "'PRO'"
		    	aTabxCpo := {{"SRA","RA_OCDTEXP"}}    	
	    	ElseIf cTipoDoc == "'RNE'"
		    	aTabxCpo := {{"SRA","RA_RNEDEXP"}}	    	
			EndIf 
		
		ElseIf cCampo == "PERSONAL_DATA_IDENTIFICATION.IDENTITY_NUMBER_EXPIRY_DATE""
	    	If cTipoDoc == "'CNH'"
		    	aTabxCpo := {{"SRA","RA_DTVCCNH"}}
	    	ElseIf cTipoDoc == "'PRO'"
	    		aTabxCpo := {{"SRA","RA_OCDTVAL"}}
	    	EndIf

		ElseIf cCampo == "PERSONAL_DATA_IDENTIFICATION.IDENTITY_NUMBER_ISSUING_AUTHORITY"
         	If cTipoDoc == "'RG'"
		    	aTabxCpo := {{"SRA","RA_RGEXP"}}
	    	ElseIf cTipoDoc == "'CNH'"
	    		aTabxCpo := {{"SRA","RA_CNHORG"}}
	    	EndIf
         
        ElseIf cCampo == "PERSONAL_DATA_IDENTIFICATION.IDENTITY_NUMBER_ISSUING_AUTHORITY"
         	If cTipoDoc == "'RG'"
		    	aTabxCpo := {{"SRA","RA_UFRIC"}}
	    	ElseIf cTipoDoc == "'CTPS'"
	    		aTabxCpo := {{"SRA","RA_UFCP"}}
	    	ElseIf cTipoDoc == "'RNE'"
	    		aTabxCpo := {{"SRA","RA_RNEORG"}}
	    	ElseIf cTipoDoc == "'PSS'"
	    		aTabxCpo := {{"SRA","RA_UFPAS"}}
	    	EndIf
        
        ElseIf cCampo == "FAMILY.FIRST_NAME"
        	If cTipoRela == "'PM'"
		    	aTabxCpo := {{"SRA","RA_MAE+"}}
	    	ElseIf cTipoRela == "'PF'"
	    		aTabxCpo := {{"SRA","RA_PAI+"}}
	    	ElseIf !EMPTY(cTipoRela)
	    		aTabxCpo := {{"SRB","RB_NOME+"}}
	    	EndIf

        ElseIf cCampo == "FAMILY.LAST_NAME"
        	If cTipoRela == "'PM'"
		    	aTabxCpo := {{"SRA","+RA_MAE"}}
	    	ElseIf cTipoRela == "'PF'"
	    		aTabxCpo := {{"SRA","+RA_PAI"}}
	    	ElseIf !EMPTY(cTipoRela)
	    		aTabxCpo := {{"SRB","+RB_NOME"}}
	    	EndIf
		
	    Else
			//Pesquisa na tabela o campo relacionado no dicionแrio de dados    
			SZA->(DbSetOrder(1))
			If SZA->(DbSeek(xFilial("SZA")+AllTrim(cCampo)))
				While SZA->(!EOF()) .and. SZA->ZA_FILIAL = xFilial("SZA") .and. ALLTRIM(SZA->ZA_CPOEXCE) = AllTrim(cCampo)
					//SRA - cadastro de funcionแrios
					//SRA - cadastro de Dependentes
					If AllTrim(SZA->ZA_ALIAS) == "SRA" .or.;
						 (AllTrim(SZA->ZA_ALIAS) == "SRB" .and. !EMPTY(cTipoRela) .and. cTipoRela <> "'PM'" .and. cTipoRela <> "'PF'")
						If aScan(aTabxCpo,{|x| ALLTRIM(x[1]) == AllTrim(SZA->ZA_ALIAS) .AND. ALLTRIM(x[2]) == AllTrim(SZA->ZA_CPOSX3)}) == 0
							aAdd(aTabxCpo,{AllTrim(SZA->ZA_ALIAS),AllTrim(SZA->ZA_CPOSX3)})
						EndIf
			 		EndIf
			 		SZA->(DbSkip())
			 	EndDo     
		 	EndIf
		EndIf

		For i:=1 to Len(aTabxCpo)
			//A=Grava campo todo;E=Grava a esquerda do conteudo ja existente;D=Grava a direita do conteudo Existente
			cTpGrv := "A" 
			If AT("+",aTabxCpo[i][2]) <> 0
				cTpGrv := IIF(AT("+",aTabxCpo[i][2])==1,"E","D")
				aTabxCpo[i][2] := STRTRAN(aTabxCpo[i][2],"+","")
			EndIf

			//caso tenha encontrado a estrutura/campo
			Do Case
				Case aTabxCpo[i][1] == "SRA"
					//Busca o campo na estrutura da Tabela
					nPos := 0
					If !Empty(aTabxCpo[i][2])
						nPos := aScan(aEstSRA,{|a| AllTrim(a[1]) == aTabxCpo[i][2]})
					EndIf
					If nPos > 0
						xValor := RH001Dados(AllTrim(cValor),aEstSRA[nPos])
						If ValType(xValor) == "C" .and. xValor == "|ERRO|"
							xValor := ""
						EndIf
						If lNewLine
					   		xAuxValor := aAuxSRA[nPos]
						Else
					 		xAuxValor := aTabSRA[nLinMat][nPos]
						EndIf
						If ValType(xAuxValor) == "C" .and. cTpGrv <> "A"
							If cTpGrv == "E"
						   		xAuxValor := xAuxValor+" "+xValor
							ElseIf cTpGrv == "D"
						   		xAuxValor += " "+xValor
							EndIf
						Else
					   		xAuxValor := xValor
						EndIf
						If lNewLine
					   		aAuxSRA[nPos] := xAuxValor
						Else
					 		aTabSRA[nLinMat][nPos] := xAuxValor
						EndIf
					EndIf
				
				Case aTabxCpo[i][1] == "SRB"
					//Busca o campo na estrutura da Tabela
					nPos := 0
					If !Empty(aTabxCpo[i][2]) .and. aTabxCpo[i][2] <> "RB_MAT"
						nPos := aScan(aEstSRB,{|a| AllTrim(a[1]) == aTabxCpo[i][2]})
					EndIf
					If nPos > 0
						xValor := RH001Dados(AllTrim(cValor),aEstSRB[nPos])
						If ValType(xValor) == "C" .and. xValor == "|ERRO|"
							xValor := ""
						EndIf
						If ValType(aAuxSRB[nPos]) == "C" .and. cTpGrv <> "A"
							If cTpGrv == "E"
						   		aAuxSRB[nPos] := aAuxSRB[nPos]+" "+xValor
							ElseIf cTpGrv == "D"
						   		aAuxSRB[nPos] += " "+xValor
							EndIf
						Else
					   		aAuxSRB[nPos] := xValor
						EndIf
						If !EMPTY(xValor) .and. EMPTY(aAuxSRB[nPMatSRB])
							If lNewLine
						   		aAuxSRB[nPMatSRB] := aAuxSRA[nPMatSRA]
							Else
						  		aAuxSRB[nPMatSRB] := aTabSRA[nLinMat][nPMatSRA]
							EndIf
						EndIf
					EndIf
			EndCase
		Next i
	Next nY
	
	If lNewLine
		//Adiciona a linha no array com os registros de grava็ใo
		aAdd(aTabSRA,aAuxSRA)
		//Reotorna o evento da atualiza็ใo		
		cValor := AllTrim(StrTran(aItens[nI][nPOper],"'",""))
		//Adiciona a linha no array de eventos
		aAdd(aEvento,cValor)
	EndIf
    
	If !EMPTY(aAuxSRB[nPMatSRB])
		aAdd(aTabSRB,aAuxSRB)
	EndIf
	
   	If aColsLog[nI][1] == oBR_BRANCO
    	aColsLog[nI][1] := oBR_VERDE
    EndIf
Next

////////////////////////////////
//Inicio da grava็ใo dos dados//
////////////////////////////////
SRA->(DbSetOrder(1))
For nI:=1 To Len(aTabSRA)
	If aEvento[nI] == "HIR"
		If SRA->(DbSeek(xFilial("SRA")+ALLTRIM(aTabSRA[nI][nPMatSRA])))
			While (nPos:=aScan(aColsLog,{|X| X[1] <> oBR_VERMELHO .and. ALLTRIM(X[4])==ALLTRIM("'"+aTabSRA[nI][nPMatSRA]+"'") }) ) <> 0
		    	aColsLog[nPos][1] := oBR_VERMELHO
		    	aColsLog[nPos][6] += "> Registro enviado como 'HIR', mas jแ possui informa็๕es na Base, serแ aceito apenas 'UPD'."+CHR(13)+CHR(10)
			EndDo
			Loop
		EndIf
		SRA->(RecLock("SRA",.T.))		
	ElseIf aEvento[nI] == "UPD"
        SRA->(DbSeek(xFilial("SRA")+StrTran(aTabSRA[nI][nPMatCab])))
        SRA->(RecLock("SRA",.F.))		
	EndIf
			
	For nY:=1 To Len(aTabSRA[nI])
		//Tratamento para campos especiais
		If AllTrim(aEstSRA[nY][1]) == "RA_ADTPOSE"
			SRA->(&(aEstSRA[nY][1])) :=  "A****"
		ElseIf AllTrim(aEstSRA[nY][1]) =="RA_VIEMRAI"
			SRA->(&(aEstSRA[nY][1])) :=  "10"
		ElseIf AllTrim(aEstSRA[nY][1]) =="RA_CODLOC"
			SRA->(&(aEstSRA[nY][1])) :=  "9999999999"
		ElseIf AllTrim(aEstSRA[nY][1]) =="RA_CODLOC"
			If !EMPTY(SRA->(&(aEstSRA[nY][1])))
				Do Case
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "1"//Illiterate
						SRA->(&(aEstSRA[nY][1])) :=  "10"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "2"//Incomplete Elementary School
						SRA->(&(aEstSRA[nY][1])) :=  "20"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "3"//Complete Elementary School
						SRA->(&(aEstSRA[nY][1])) :=  "25"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "4"//Complete Primary School
						SRA->(&(aEstSRA[nY][1])) :=  "35"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "5"//Complete Middle School
						SRA->(&(aEstSRA[nY][1])) :=  "35"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "6"//Incomplete High School
						SRA->(&(aEstSRA[nY][1])) :=  "40"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "7"//Complete High School
						SRA->(&(aEstSRA[nY][1])) :=  "45"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "8"//Incomplete Degree
						SRA->(&(aEstSRA[nY][1])) :=  "50"
					Case ALLTRIM(SRA->(&(aEstSRA[nY][1]))) == "9"//Complete Degree
						SRA->(&(aEstSRA[nY][1])) :=  "55"
				EndCase
			EndIf
		Else
			If (VALTYPE(aTabSRA[nI][nY]) == "C" .and. !EMPTY(aTabSRA[nI][nY]) ) .or.;
				(VALTYPE(aTabSRA[nI][nY]) == "N" .and. aTabSRA[nI][nY] <> 0 ) .or.;
				(VALTYPE(aTabSRA[nI][nY]) == "D" .and. !EMPTY(DTOS(aTabSRA[nI][nY])) )
		  		SRA->(&(aEstSRA[nY][1])) :=  aTabSRA[nI][nY]
		 	EndIf
		EndIf
	Next
	//Valores Fixados.
	If EMPTY(SRA->RA_FILIAL)
		SRA->RA_FILIAL := xFilial("SRA")
	EndIf
	SRA->(MsUnlock())		
Next nI

SRB->(DbSetOrder(1))//RB_FILIAL+RB_MAT
For nI:=1 To Len(aTabSRB)
	If aScan(aColsLog,{|x| (x[1] == oBR_VERMELHO .or. x[1] == oBR_BRANCO) .and. x[4] == "'"+ALLTRIM(aTabSRB[nI][nPMatSRB])+"'"}) == 0
		lSeek := !SRB->(DbSeek(xFilial("SRB")+ALLTRIM(aTabSRB[nI][nPMatSRB])))
		SRB->(RecLock("SRB",lSeek))
		For nY:=1 To Len(aTabSRB[nI])
			If (VALTYPE(aTabSRB[nI][nY]) == "C" .and. !EMPTY(aTabSRB[nI][nY]) ) .or.;
				(VALTYPE(aTabSRB[nI][nY]) == "N" .and. aTabSRB[nI][nY] <> 0 ) .or.;
				(VALTYPE(aTabSRB[nI][nY]) == "D" .and. !EMPTY(DTOS(aTabSRB[nI][nY])) )
		  		SRB->(&(aEstSRB[nY][1])) :=  aTabSRB[nI][nY]
		 	EndIf
		Next nY
		//Valores Fixados.
		If EMPTY(SRB->RB_FILIAL)
			SRB->RB_FILIAL := xFilial("SRB")
		EndIf
		SRB->(MsUnLock())
		//Atualiza็ใo do campo Codigo, caso esteja vazio
		If EMPTY(SRB->RB_COD)
	   		TcSQLExec("Update SRB"+RetSQLName("SRB")+"0 Set RB_COD = (Select Case When (MAX(RB_COD)+1)<10 Then '0'+Cast((MAX(RB_COD)+1) as varchar(10)) "+;
					"Else Cast((MAX(RB_COD)+1) as varchar(10)) End From SRB"+RetSQLName("SRB")+"0 Where D_E_L_E_T_ <> '*' AND RB_MAT = '"+SRB->RB_FILIAL+"')"+; 
					"Where RB_COD = '' AND RB_MAT = '"+SRB->RB_FILIAL+"'")
		EndIf
	EndIf
Next nI			

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GTRh001Dadosบ Autor บ MRW             บ Data ณ  06/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ - Tratamento das informa็๕es.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
*------------------------------------------*
Static Function RH001Dados( cValor, aCampo )  
*------------------------------------------*
Local xRet := ""

Local cMat     := ""
Local cMens    := ""
Local cIdCampo := ""
Local cPCodMun := ""

Local cNomeCpo := aCampo[1]
Local cTipoCpo := aCampo[2]
Local nTamCpo  := aCampo[3]
Local nDecCpo  := aCampo[4]
Local lObrigat := aCampo[5]

Local aRetCar := {"RA_CEP","RA_CIC","RA_RG","RA_PIS","RA_RG","RA_NUMCP","RA_HABILIT","RA_RESERVI","RH_TITULOE","RB_CIC"}

//Verifica se o campo ้ obrigat๓rio
If lObrigat .and. Empty(cValor)
	cTxtErro += "Campo "+cNomeCpo+"้ obrigat๓rio, mas nใo possui valor informado."
	Return "|ERRO|"
EndIf

If !Empty(cValor)
	If aScan(aRetCar, {|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(cNomeCpo)) }) <> 0
		xRet := cValor
		xRet := StrTran(xRet,"-","")
		xRet := StrTran(xRet,".","")
	Else
		//Tratamento para o tipo do campo
		If cTipoCpo == "D"
			xRet := StoD(cValor)
		ElseIf cTipoCpo == "N"
			xRet := Round(Val(cValor),nDecCpo)
		Else
			xRet := cValor	
		EndIf
	EndIf
EndIf
	
Return xRet