#Include "Protheus.Ch"
#Include "TopConn.ch"
#Include "TBICONN.CH"
#Include "AvPrint.ch" 
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Define DMPAPER_A4          9           // A4 210 X 297 MM
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GTADP_04 ³Autor  ³ Cesar Chena           ³ Data ³11/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rel. HLB BRASIL ADP - Pay Report                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ Gera somente em excel.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico HLB BRASIL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GTADP_04(cPath,cPeriodo)

Private cCID    := ""
Private cENTITT := ""
Private cLID    := ""
Private cChave    := ""

               
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


DbSelectArea("SX2") //verifica compartilhamento de centro de custos
DbSetOrder(1)

If DbSeek("CTT")
	cCC := X2_MODO
Endif

Processa( {|| GTADP04Go(cPath,cPeriodo)}, "Aguarde...","Gerando relatório... !!!")

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ GTADP04Go³ Autor ³ Cesar Chena           ³ Data ³28/01/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processamento do Arquivo.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GTADP04Go(cPath,cPeriodo)

LOCAL nYear := VAL(subs(cPeriodo,4,4))

Private cImp		:= ""
Private lPage		:= .T.
Private lQuebra		:= .T.
Private oPrint		:= Nil
Private oFont07		:= TFont():New("Arial",07,10,,.F.,,,,.T.,.F.)
Private oFont09		:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont11n	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Private oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont12n	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont15		:= TFont():New("Arial",15,15,,.F.,,,,.T.,.F.)
Private oFont15n	:= TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
Private oFont20n	:= TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)
Private oFont25n	:= TFont():New("Arial",25,25,,.T.,,,,.T.,.F.)
Private oFont30n	:= TFont():New("Arial",30,30,,.T.,,,,.T.,.F.)
Private oFont50n	:= TFont():New("Arial",50,50,,.T.,,,,.T.,.F.)
Private oFont60n	:= TFont():New("Arial",60,60,,.T.,,,,.T.,.F.)
Private nMakeDir	:= 0
Private nLin		:= 0 //100
Private nCol		:= 010                 
Private nCol2		:= 150                 
Private nS			:= 0
PRIVATE _cPer1ini 	:= subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer1fin 	:= ""
Private cArquivo    := ""
Private _cPer3ini := ""
Private nYear3 := VAL(subs(cPeriodo,4,4))
PRIVATE _cNomArq  	:= "SEP"
PRIVATE nTotValor   := 0
PRIVATE lAdjustToLegacy := .F.
PRIVATE lDisableSetup  := .T.
PRIVATE _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
PRIVATE cPERELA   := cPERIODO
       
Private cPasta		:= "\TempPDFs\"//cPath

MakeDir(cPasta)
//Limpeza da pasta temporaria.
aArquivos := Directory(cPasta+"*.*")
For i:=1 to len(aArquivos)
	FErase(cPasta+aArquivos[i][1])
Next i

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
nYear := val(_cAnofin)

// monta periodo 2 final 
If _cMesfin $ "04/06/09/11"
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
	

//Cria o diretorio caso nao exista
cArquivo := "P_"+_cNomArq+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_NOE_"+ALLTRIM(cNomeEmp)+"-PAYMENTREPORT.PDF"

oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, lAdjustToLegacy, cPasta, lDisableSetup, , , , , , , .F., , .F. )
 
oPrint:SetLandscape()//Paisagem
oPrint:SetPaperSize(9) // DMPAPER_A4
oPrint:cPathPDF :=ALLTRIM(cPasta)

cFilePrint := ALLTRIM(cPasta)+cArquivo

//////////////////////////////////////
//Rotina para impressão do cabecalho//
//////////////////////////////////////
GT04CABEC(_cPer1ini,_cPer1fin)

//////////////////////////////////////
//Rotina para impressão do corpo    //
//////////////////////////////////////
GT04CORPO(_cPer1ini,_cPer1fin)

//////////////////////////////////////
//Rotina para impressão do rodape   //
//////////////////////////////////////
GT04RODAPE(nTotValor)

//File2Printer( cFilePrint, "PDF" )
//oPrint:Preview()
	
oPrint:EndPage()
oPrint:Print()
FreeObj(oPrint)
oPrint := Nil

cFolderGS := "C:\Program Files (x86)\GPLGS\"
cRoot := GetSrvProfString("rootpath","")

	cCMD := cFolderGS+'gswin64c.exe -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -o "'+cRoot+cPasta+'1.4'+cArquivo+'" "'+cRoot+cPasta+cArquivo+'"'
	WaitRunSrv(cCMD, .T., cFolderGS )
	
	Sleep(1000)
	
	//Apaga o arquivo da versão anterior
	FErase(cPasta+cArquivo)

	//Renomeia o arquivo para retirar a versão do nome
	FRename(cPasta+"1.4"+cArquivo,cPasta+cArquivo)


//Copia o arquivo para o terminal client.
CpyS2T(cPasta+cArquivo, cPath,.F.)

//Apaga o arquivo no server.
FErase(cPasta+cArquivo)

//ECR - 27/08/2015 - Altera o nome do arquivo para maisculo.
//ShellExecute("Open","C:\Windows\System32\cmd.exe", ' /C "REN '+AllTrim(cPasta)+Lower(cArquivo)+ ' ' + Upper(cArquivo)+'" ', "C:\", 0 )
ShellExecute("Open","C:\Windows\System32\cmd.exe", ' /C REN "'+cPath+Lower(cArquivo)+ '" "' + Upper(cArquivo)+'" ', "C:\", 0 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GT04CABEC ºAutor  ³Cesar Chena         º Data ³  03/24/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho do relatorio                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GT                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GT04CABEC(_cPer1ini,_cPer1fin)

LOCAL _cQry 	  := ""
LOCAL dDataInc, dDataAlt                  
LOCAL _aTitles    := { "Employee ID", "Employee Name", "Hire Date", "Termination Date", "Payment Method", "Banking Info Details" , "Net Pay", "Employee ID" }
LOCAL _aDetails   := {}
LOCAL _cTitulo    := "Payment Report"
LOCAL _cFolMes    := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
LOCAL nYear := VAL(subs(cPeriodo,4,4))

//RSB -  - Inclusão do campo Matricula do funcionario no Cliente
LOCAL lMatEmp := .F.

If SRA->(FieldPos("RA_P_CDEMP")) > 0 //EXISTCPO("SX3","RA_P_CDEMP",2)
	lMatEmp := .T.
Endif
//-------------------------------

                                            
// Monta cabecalho extendido
cTit1 := "Report Data and Time"
cTit2 := "Country Code"
cTit3 := "Company Name"
cTit4 := "Entity Id"
cTit5 := "Entity Name"
cTit6 := "Currency"
cTit7 := "Pay Cycle"
cTit1a := subs(dtos(ddatabase),1,4)+"/"+subs(dtos(ddatabase),5,2)+"/"+subs(dtos(ddatabase),7,2)+"  "+subs(time(),1,5)
cTit2a := "BR"
cTit3a := SM0->M0_NOME
cTit4a := cLID
cTit5a := cENTITY
cTit6a := "BRL"
cTit7a := subs(_cPer1ini,1,4)+"/"+subs(_cPer1ini,5,2)+"/"+subs(_cPer1ini,7,2) + " - "
cTit7a += subs(_cPer1fin,1,4)+"/"+subs(_cPer1fin,5,2)+"/"+subs(_cPer1fin,7,2)

nLin := 20
nEntreLin := 11

If lPage
	oPrint:StartPage()
	//Box---------------------------------------------------------------------------------------------------
	oPrint:SayAlign(nLin,nCol, _cTitulo			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit1			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit1a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit2			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit2a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit3			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit3a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit4			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit4a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit5			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit5a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit6			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit6a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	oPrint:SayAlign(nLin,nCol, cTit7			, oFont11n,575,22,CLR_BLACK,3,0)
	oPrint:SayAlign(nLin,nCol2, cTit7a			, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	nLin += nEntreLin
	
	//breakdown
	oPrint:SayAlign(nLin,nCol,"breakdown per employee"	, oFont11n,575,22,CLR_BLACK,3,0)
	nLin += nEntreLin
	
	If lQuebra
		oPrint:Box( nLin, 010, (nLin+nEntreLin), 830 ) 
		
		//RSB - 06/01/2017 - Inclusão do campo Matricula do funcionario no Cliente
		If !lMatEmp
			oPrint:Line( nLin, 080, (nLin+nEntreLin), 080 )	// employee name
		Else
	   		oPrint:Line( nLin, 075, (nLin+nEntreLin), 075 )	// employee id client
			oPrint:Line( nLin, 150, (nLin+nEntreLin), 150 )	// employee name
		Endif
		oPrint:Line( nLin, 345, (nLin+nEntreLin), 345 )	// hire date
		oPrint:Line( nLin, 420, (nLin+nEntreLin), 420 )	// termination date
		oPrint:Line( nLin, 515, (nLin+nEntreLin), 515 )	// payment method
		oPrint:Line( nLin, 620, (nLin+nEntreLin), 620 )	// banking info details
		oPrint:Line( nLin, 740, (nLin+nEntreLin), 740 )	// net pay

		oPrint:SayAlign(nLin,015, _aTitles[1]	,oFont11n,575,22,CLR_BLACK,3,0)     // employee id
		
		//RSB - 06/01/2017 - Inclusão do campo Matricula do funcionario no Cliente
		If !lMatEmp
	   		oPrint:SayAlign(nLin,090, _aTitles[2]	,oFont11n,575,22,CLR_BLACK,3,0)     // employee name
		Else
			oPrint:SayAlign(nLin,085, _aTitles[8]	,oFont11n,575,22,CLR_BLACK,3,0)     // employee id client
			oPrint:SayAlign(nLin,160, _aTitles[2]	,oFont11n,575,22,CLR_BLACK,3,0)     // employee name
		Endif
		
		oPrint:SayAlign(nLin,355, _aTitles[3]	,oFont11n,575,22,CLR_BLACK,3,0)     // hire date
		oPrint:SayAlign(nLin,430, _aTitles[4]	,oFont11n,575,22,CLR_BLACK,3,0)     // termination date
		oPrint:SayAlign(nLin,525, _aTitles[5]	,oFont11n,575,22,CLR_BLACK,3,0)     // payment method
		oPrint:SayAlign(nLin,630, _aTitles[6]	,oFont11n,575,22,CLR_BLACK,3,0)     // banking info details
		oPrint:SayAlign(nLin,765, _aTitles[7]	,oFont11n,575,22,CLR_BLACK,3,0)     // net pay
	EndIf
EndIf	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GT04CORPOºAutor  ³Cesar Chena         º Data ³  03/24/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Corpo do relatorio                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GT                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GT04CORPO(_cPer1ini,_cPer1fin)

LOCAL lMatEmp := .F.

Private aCodFol     := {} 
Private aValBenef   := {}
Private aCodFol     := {}          
Private dDtRef      := stod(_cPer1ini)
Private cRCName     := ""
Private cRIName 	:= ""
Private cAliasMov   := ""
Private cAliasRI    := ""
Private cAcessaSRC	:= &( " { || " + ChkRH( "GTADP_04" , "SRC" , "2" ) + " } " )
Private cAcessaSRI	:= &( " { || " + ChkRH( "GTADP_04" , "SRI" , "2" ) + " } " )
Private cAcessaSR1	:= &( " { || " + ChkRH( "GTADP_04" , "SR1" , "2" ) + " } " )
Private cAcessaSRA	:= &( " { || " + ChkRH( "GTADP_04" , "SRA" , "2" ) + " } " )
Private cAcessaSRG	:= &( " { || " + ChkRH( "GTADP_04" , "SRG" , "2" ) + " } " )
Private cAcessaSRH	:= &( " { || " + ChkRH( "GTADP_04" , "SRH" , "2" ) + " } " )
Private cAcessaSRR	:= &( " { || " + ChkRH( "GTADP_04" , "SRR" , "2" ) + " } " )

//RSB - 06/01/2017 - Inclusão do campo Matricula do funcionario no Cliente
If SRA->(FieldPos("RA_P_CDEMP")) > 0 //EXISTCPO("SX3","RA_P_CDEMP",2)
	lMatEmp := .T.
Endif

lAdianta	:= .T.	  			// Adiantamento 
lFolha		:= .T.	  			// Folha    
lPrimeira	:= .T.	  			// 1¦Parc. 13§ Sal rio
lSegunda	:= .T.	  			// 2¦Parc. 13§ Sal rio
lFerias		:= .T.				// F‚rias
lExtras		:= .T.				// Extras
lRescisao	:= .T.				// Rescisao
lImprFunci  := .T.             // Imprime funcionarios
lImprBenef  := .F.             // Imprime beneficiarios
semana      := "1"             // Semana
ddatade     := stod(_cPer1ini)
ddataate    := stod(_cPer1fin)

cRCName := If( Empty(cAliasMov), retSqlName("SRC"), cArqMov )
cRIName := If( Empty(cAliasRI), retSqlName("SRI"), cArqMovRI )

///// SRA->RA_DEMISSA: Se a data de demissão for anterior ao perúŒdo atual, inclui rescisões, caso contrfário ignora   // 14/03/17
//ECR - 27/08/2015 - Ajuste na query
//Pesquisa todas os funcionarios com movimento no perúŒdo
_cQry := "SELECT DISTINCT RC_FILIAL FILIAL," + CRLF
_cQry += "                RC_MAT MATRICULA" + CRLF
_cQry += " FROM " + RetSqlName("SRC")+ CRLF
_cQry += " WHERE D_E_L_E_T_ <> '*'" + CRLF
_cQry += "   AND left(RC_DATA,6) > ' ' " + CRLF    /// francisco neto 21/10/2016   
_cQry += "   AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " + CRLF 	//francisco neto 19/09/2016
_cQry += " ORDER BY RC_FILIAL,RC_MAT"+ CRLF 
_cQry := ChangeQuery(_cQry)


If cPeriodo != _cFolMes

	_cQry := "SELECT DISTINCT RD_FILIAL FILIAL," + CRLF
	_cQry += "                RD_MAT MATRICULA" + CRLF
	_cQry += " FROM " + RetSqlName("SRD")+ CRLF
	_cQry += " WHERE D_E_L_E_T_ <> '*'" + CRLF
	_cQry += "   AND RD_DATARQ = '"+SUBSTR(_cPer1ini,1,6)+"'  " +CRLF     /// francisco neto 21/10/2016 
	_cQry += "   AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' " + CRLF 	//francisco neto 19/09/2016
	_cQry += " ORDER BY RD_FILIAL,RD_MAT"+ CRLF 
	_cQry := ChangeQuery(_cQry)

endif

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQry), "SQL", .F., .T.)
dbSelectArea("SQL")
dbGoTop()

nLin	:= 140

cChave := SQL->FILIAL+SQL->MATRICULA

While !eof()
    SRA->(DbSetOrder(1))
    SRA->(DbSeek(SQL->FILIAL+SQL->MATRICULA))

	nValor    := 0

	aValBenef := {}

	If !Fp_CodFol(@aCodFol,SRA->RA_FILIAL)
		Exit
	Endif

	IF cPERELA=_cFolMes
		AcPer := subs(cPERELA,4,4)+subs(cPERELA,1,2)

		_cQrySrc := " SELECT DISTINCT RC_FILIAL,RC_MAT,RV_CODFOL,SUM(RC_VALOR) AS VALOR "
		_cQrySrc +=	" FROM "+RetSqlName("SRC")+" A   "		
		_cQrySrc +=	" JOIN "+RetSqlName("SRV")+" RV ON RV.RV_COD = A.RC_PD AND RV.D_E_L_E_T_='' " //MSM - 11/04/16 - Chamado: 032995 -Tratamento para considerar o identificardor de cálculo em vez do código da verba
		_cQrySrc +=	" WHERE A.D_E_L_E_T_ <> '*' AND RC_MAT = '"+SRA->RA_MAT +"' AND RC_FILIAL = '"+SRA->RA_FILIAL +"' " 
		_cQrySrc += "   AND left(RC_DATA,6) > ' ' "     /// francisco neto 21/10/2016   
		_cQrySrc += " AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
		_cQrySrc +=	" AND RV.RV_CODFOL IN ('0047','0126','0303') "               // francisco neto 18/11/2016
		_cQrySrc +=	" GROUP BY RC_FILIAL,RC_MAT,RV_CODFOL "
		_cQrySrc +=	" ORDER BY RC_FILIAL,RC_MAT,RV_CODFOL "

		_cQrySrV := ChangeQuery( _cQrySrc )	 
		
		If Select("qSRV") <> 0
			qSRV->(dbCloseArea())
		EndIf
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQrySrV), "qSRV", .F., .T.)
		dbSelectArea("qSRV")
		dbGoTop()
  		If !eof()
  		   nValor := qSRV->VALOR
  		Else
			// Busca os valores de Liquido e beneficios                     ³
			//fBuscaLiq(@nValor,@aValBenef,aCodFol,,,dDtRef, cRCName, cRIName) 
			nValor:=0
  		Endif   
	ELSE  
		AcPer:=subs(cPERELA,4,4)+subs(cPERELA,1,2)
		
		_cQrySrD := " SELECT DISTINCT RD_FILIAL,RD_MAT,RV_CODFOL,SUM(RD_VALOR) AS VALOR "
		_cQrySrD +=	" FROM "+RetSqlName("SRD")+" A   "	
		_cQrySrD +=	" JOIN "+RetSqlName("SRV")+" RV ON RV.RV_COD = A.RD_PD AND RV.D_E_L_E_T_='' " //MSM - 11/04/16 - Chamado: 032995 -Tratamento para considerar o identificardor de cálculo em vez do código da verba
		_cQrySrD +=	" WHERE A.D_E_L_E_T_ <> '*' AND RD_DATARQ = '"+AcPer+"' AND RD_MAT = '"+SRA->RA_MAT +"' AND RD_FILIAL = '"+SRA->RA_FILIAL +"' " 
		_cQrySrD += " AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016		 
		_cQrySrD +=	" AND RV.RV_CODFOL IN ('0047','0126','0303') "    // francisco neto 18/11/2016  (Liq.Fol, Liq.Resc, Liq.Resc.Compl)
		_cQrySrD +=	" GROUP BY RD_FILIAL,RD_MAT,RV_CODFOL "
		_cQrySrD +=	" ORDER BY RD_FILIAL,RD_MAT,RV_CODFOL "

		_cQrySrV := ChangeQuery( _cQrySrd )	 
		
		If Select("qSRV") <> 0
			qSRV->(dbCloseArea())
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQrySrV), "qSRV", .F., .T.)
		dbSelectArea("qSRV")
		dbGoTop()
  		If !eof()
  		   nValor:=qSRV->VALOR
  		Else
  		   nValor:=0
  		Endif   
	ENDIF
	If nValor > 0
		//Matricula
		oPrint:SayAlign(nLin,020, SRA->RA_MAT 			,oFont11,575,22,CLR_BLACK,3,0)
		
		
		//RSB - 06/01/2017 - Inclusão do campo Matricula do funcionario no Cliente
		If !lMatEmp
			//Nome do Funcionário
			oPrint:SayAlign(nLin,090, SRA->RA_NOME			,oFont11,575,22,CLR_BLACK,3,0)
		Else
			//Nome do Funcionário
			oPrint:SayAlign(nLin,085, SRA->RA_P_CDEMP		,oFont11,575,22,CLR_BLACK,3,0)
			//Nome do Funcionário
			oPrint:SayAlign(nLin,160, SRA->RA_NOME			,oFont11,575,22,CLR_BLACK,3,0)
		Endif
		
		//Data de Admissão
		oPrint:SayAlign(nLin,355, SUBS(DTOS(SRA->RA_ADMISSA),1,4)+"/"+SUBS(DTOS(SRA->RA_ADMISSA),5,2)+"/"+SUBS(DTOS(SRA->RA_ADMISSA),7,2),oFont11,575,22,CLR_BLACK,3,0)
////////////////////////////////////////////////////////////
		If !Empty(SRA->RA_DEMISSA) .AND. DTOS(SRA->RA_DEMISSA) < _cPer1ini ////.AND. DTOS(SRA->RA_DEMISSA) <= _cPer1fin  // Francisco Neto 14/03/17

			oPrint:SayAlign(nLin,430, SUBS(DTOS(SRA->RA_DEMISSA),1,4)+"/"+SUBS(DTOS(SRA->RA_DEMISSA),5,2)+"/"+SUBS(DTOS(SRA->RA_DEMISSA),7,2),oFont11,575,22,CLR_BLACK,3,0)
		EndIf

		oPrint:SayAlign(nLin,525, "Bank Transfer"		,oFont11,575,22,CLR_BLACK,3,0)

		If !Empty(SRA->RA_BCDEPSA)
			SA6->(DbSetOrder(1))
			If SA6->(DbSeek(xFilial("SA6")+SRA->RA_BCDEPSA))
				oPrint:SayAlign(nLin,630, AllTrim(SA6->A6_COD)+" / "+AllTrim(SA6->A6_AGENCIA)+" / "+AllTrim(SRA->RA_CTDEPSA),oFont11,575,22,CLR_BLACK,3,0)			
            EndIf
		Endif
		oPrint:SayAlign(nLin,770, transform(nValor,"@E 999,999.99") 	,oFont11,575,22,CLR_BLACK,3,0)
		nLin += 010
		nTotValor += nValor

		//Quebra de pagina//
		If nLin	> 550
			lQuebra := .T.
			oPrint:EndPage()
			nLin	:= 140
			GT04CABEC(_cPer1ini,_cPer1fin)
			nLin += 010
		EndIf
	Endif
	DbSelectArea("SQL")
	DBSkip()
End

DbSelectArea("SQL")
dbCloseArea()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GT04RODAPEºAutor  ³Cesar Chena         º Data ³  03/24/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão do rodape                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GT                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GT04RODAPE(nTotValor)
	
/////////////////////
//Imprimindo rodape//
/////////////////////     
//oPrint:Box(690,10,835,585) 
nLin += 30
If nLin	> 550
	nLin := 140
	GT04CABEC(_cPer1ini,_cPer1fin)
	nLin += 30	
EndIf
oPrint:SayAlign(nLin,020, "Company Total"	,oFont12n,575,22,CLR_BLACK,0,0)	
oPrint:SayAlign(nLin,760, transform(nTotValor,"@E 999,999,999.99") 	,oFont12,575,22,CLR_BLACK,0,0)	

Return

