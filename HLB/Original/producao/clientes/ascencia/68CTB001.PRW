#Include 'Totvs.ch'
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥68CTB001  ∫Autor  ≥Jo„o Silva			 ∫ Data ≥  17/11/2015 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥RelatÛrio de Raz„o Cont·bil Customizado."	Modelo GL "       ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

Sumario
FunÁ„o	: Funcao1() Objetivo: Gera o relatÛrio.
FunÁ„o	: Funcao2() Objetivo: Cria a tabela tempor·ria que serÅEutilizada para a impress„o.  
FunÁ„o	: Funcao3() Objetivo: Realiza a gravaÁ„o dos dados na tabela tempor·ria. 
Funcao	: Funcao4() Objetivo: Imprime o relatÛrio          
Funcao	: Funcao5() Objetivo: FunÁ„o para abrir o excel
FunÁ„o	: Funcao6() Objetivo: Verificar se os parametros est„o criados corretamente.  
Func„o  : Funcao7()	Objetivo: FunÁ„o responsavel pela manutenÁ„o do arquivo para evitar que estoure.   
Func„o	: Funcao8() Objetivo: Log de execuÁıes.

*/

*-----------------------*
User Function 68CTB001() 
*-----------------------*
Local lOk := .F.
Local cPerg := "68CTB001"

Private cDataDe    := ""
Private cDataAte   := ""
Private cContaDe   := ""
Private cContaAte  := ""
Private cNomeArq   := ""
Private lAbreExcel := .F.
Private cMoeda     := ""
Private lSemMov    := .F.
Private lImpSld    := .F.
Private lCCusto    := .F.
Private cCCDe      := ""
Private cCCAte     := ""
Private lItCont    := .F.
Private cItemDe    := ""
Private cItemAte   := ""
Private cDescMoe   := ""
Private cClasseDe  := ""
Private cClasseAte := ""  
Private cDtCont	   := "" 

//Verifica os par‚metros do relatÛrio
Funcao6(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os par‚metros
	cDataDe   := DtoS(mv_par01)
	cDataAte  := DtoS(mv_par02)
	cContaDe  := mv_par03
	cContaAte := mv_par04
	cNomeArq  := mv_par05
	lAbreExcel:= If(mv_par06==2,.F.,.T.)
	cMoeda    := mv_par07
	lSemMov   := If(mv_par08==2,.F.,.T.)
	lImpSld   := If(mv_par08==3,.T.,.F.)
	lCCusto   := If(mv_par09==2,.F.,.T.)
	cCCDe     := mv_par10
	cCCAte    := mv_par11
	lItCont   := If(mv_par12==2,.F.,.T.)
	cItemDe   := mv_par13
	cItemAte  := mv_par14
	cDescMoe  := mv_par15
	cClasseDe := mv_par16
	cClasseAte := mv_par17
	
	//Gera o RelatÛrio
	Processa({|| lOk := Funcao1()},"Gerando o relatÛrio...")

	If !lOk
		MsgInfo("N„o foram encontrados registros para os par‚metros informados.","AtenÁ„o")
		Return Nil
	EndIf

EndIf

Return Nil                           

/*
FunÁ„o  : Funcao1
Objetivo: Gera o relatÛrio
Autor   : Jo„o Silva
Data    : 17/11/2015
*/
*-----------------------*
Static Function Funcao1()
*-----------------------*
Local lGrvDados := .F.

Local cArqTrab := ""

//Cria a tabela tempor·ria para impress„o dos registros.
cArqTrab :=  Funcao2()
//Grava os Dados na tabela tempor·ria
If !Empty(cArqTrab)
	lGrvDados := Funcao3()
EndIf  

//CriaÁ„o do Arquivo HTML.
nHdl		:= FCREATE(cNomeArq,0 ) 

// GravaÁ„o do seu Conteudo.
nBytesSalvo	:= FWRITE(nHdl, "" ) 

// Fecha o Arquivo que foi Gerado
fclose(nHdl) 

If lGrvDados
	//Imprime o relatÛrio
    Funcao4()
EndIf

//Abre excel
Funcao5() 

// Log de execuÁıes.
Funcao8() 


Return lGrvDados

/*
FunÁ„o  : Funcao2
Objetivo: Cria a tabela tempor·ria que serÅEutilizada para a impress„o.
Autor   : Jo„o Silva
Data    : 17/11/2015
*/
*--------------------------*
Static Function Funcao2()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela tempor·ria 
aAdd(aStru,{"BKZ  ","C",001,0})
aAdd(aStru,{"BUKRS","C",004,0})
aAdd(aStru,{"BLDAT","C",010,0})
aAdd(aStru,{"BLART","C",002,0})
aAdd(aStru,{"XBLNR","C",013,0})
aAdd(aStru,{"BKTXT","C",007,0})
aAdd(aStru,{"WAERS","C",003,0})
aAdd(aStru,{"WWERT","C",001,0})
aAdd(aStru,{"KURSF","C",001,0})
aAdd(aStru,{"NEWBS","C",002,0})
aAdd(aStru,{"NEWKO","C",010,0})
aAdd(aStru,{"DMBTR","C",001,0})
aAdd(aStru,{"WRBTR","N",014,2})
aAdd(aStru,{"MWSKZ","C",002,0})
aAdd(aStru,{"XMWST","C",010,0})
aAdd(aStru,{"ZFBDT","C",001,0})
aAdd(aStru,{"VALUT","C",001,0})
aAdd(aStru,{"PERNR","C",001,0})
aAdd(aStru,{"VBUND","C",001,0})
aAdd(aStru,{"XREF1","C",001,0})
aAdd(aStru,{"XREF2","C",001,0})
aAdd(aStru,{"XREF3","C",001,0})
aAdd(aStru,{"ZUONR","C",010,0})
aAdd(aStru,{"SGTXT","C",007,0})

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o ˙ãdice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->NEWKO",,,"Selecionando Registro...")


DbSelectArea("REL")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

Return cArqTrab

/*
FunÁ„o  : Funcao3
Objetivo: Realiza a gravaÁ„o dos dados na tabela tempor·ria.
Autor   : Jo„o Silva
Data    : 17/11/2015
*/
*--------------------------*
Static Function Funcao3()
*--------------------------*
Local lRet := .F.
Local cBKZ   := ""
Local cBUKRS := ""
Local cBLDAT := ""
Local cBLART := ""
Local cXBLNR := ""
Local cBKTXT := ""
Local cWAERS := ""
Local cWWERT := ""
Local cKURSF := ""
Local nNEWBS := ""
Local nNEWKO := ""
Local cDMBTR := ""
Local nWRBTR := 0
Local cMWSKZ := ""
Local cXMWST := ""
Local cZFBDT := ""
Local cVALUT := ""
Local cPERNR := ""
Local cVBUND := ""
Local cXREF1 := ""
Local cXREF2 := ""
Local cXREF3 := ""
Local cZUONR := ""
Local cSGTXT := ""

Local cQryDebit	:= ""
Local cQryCredit:= ""  

//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf

//Imprime as contas sem movimentaÁ„o.
If lSemMov

	cQryDebit := "% ( SELECT CT2_DEBITO" 
	cQryDebit += "	  FROM " +RetSqlName("CT2")
	cQryDebit += "	  WHERE D_E_L_E_T_ <> '*'"
	cQryDebit += "	    AND CT2_FILIAL = '"+xFilial("CT2")+"'"
	cQryDebit += "		AND CT2_MOEDLC = '"+cMoeda+"'"
	cQryDebit += "		AND CT2_DATA >= '"+cDataDe+"'"
	cQryDebit += "		AND CT2_DATA <= '"+cDataAte+"'"
	cQryDebit += "		AND CT2_DEBITO >= '"+cContaDe+"'"
	cQryDebit += "		AND CT2_DEBITO <= '"+cContaAte+"'"
	cQryDebit += "		AND CT2_DEBITO <> ''"
	cQryDebit += "	  GROUP BY CT2_DEBITO) %"
    
	cQryCredit := "% ( SELECT CT2_CREDIT" 
	cQryCredit += "	  FROM " +RetSqlName("CT2")
	cQryCredit += "	  WHERE D_E_L_E_T_ <> '*'"
	cQryCredit += "	    AND CT2_FILIAL = '"+xFilial("CT2")+"'"
	cQryCredit += "		AND CT2_MOEDLC = '"+cMoeda+"'"
	cQryCredit += "		AND CT2_DATA >= '"+cDataDe+"'"
	cQryCredit += "		AND CT2_DATA <= '"+cDataAte+"'"
	cQryCredit += "		AND CT2_CREDIT >= '"+cContaDe+"'"
	cQryCredit += "		AND CT2_CREDIT <= '"+cContaAte+"'"
	cQryCredit += "		AND CT2_CREDIT <> ''"
	cQryCredit += "	  GROUP BY CT2_CREDIT) %"


	BeginSql Alias 'TMPCT1'
	
		SELECT CT1_CONTA, CT1_DESC01,CT1_DESC02,CT1_DESC03,CT1_DESC04
		FROM %table:CT1% 
		WHERE %notDel%
		  AND CT1_FILIAL = %xFilial:CT1%
		  AND CT1_CLASSE = '2'
		  AND CT1_CONTA >= %exp:cContaDe%
		  AND CT1_CONTA <= %exp:cContaAte%
		  AND CT1_CONTA NOT IN %exp:cQryDebit%
		  AND CT1_CONTA NOT IN %exp:cQryCredit% 
	 	ORDER BY CT1_CONTA
	 	
	EndSql
EndIf

//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT2") > 0
	TMPCT2->(DbCloseArea())
EndIf

//Busca as movimentaÁıes de acordo com os par‚metros
BeginSql Alias 'TMPCT2'

	SELECT CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, 
           CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_CCD, CT2_CCC ,
           CT2_ITEMC, CT2_ITEMD, CT2_SEQUEN, CT2_SEQLAN, CT2_CLVLDB, CT2_CLVLCR
	FROM %table:CT2%
	WHERE %notDel%
	  AND CT2_DC <> '4'
	  AND CT2_FILIAL = %xFilial:CT2%
	  AND CT2_DATA >= %exp:cDataDe%
	  AND CT2_DATA <= %exp:cDataAte%
	  AND CT2_MOEDLC = %exp:cMoeda%
	  AND ((CT2_DEBITO between %exp:cContaDe% and %exp:cContaAte%) or (CT2_CREDIT between %exp:cContaDe% and %exp:cContaAte%))           
      AND ((CT2_CCD between %exp:cCCDe% and %exp:cCCAte%)or (CT2_CCC between %exp:cCCDe% and %exp:cCCAte%))
      AND ((CT2_ITEMD between %exp:cITemDe% and %exp:cITemAte%) or (CT2_ITEMC between %exp:cITemDe% and %exp:cITemAte%))
      AND ((CT2_ITEMD between %exp:cITemDe% and %exp:cITemAte%) or (CT2_ITEMC between %exp:cITemDe% and %exp:cITemAte%))      
      AND ((CT2_CLVLDB between %exp:cClasseDe% and %exp:cClasseAte%) or (CT2_CLVLCR between %exp:cClasseDe% and %exp:cClasseAte%))            
	ORDER BY CT2_DATA,CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA
EndSql

//Looping nos registros
TMPCT2->(DbGoTop())
If TMPCT2->(!EOF())
                           
	lRet  := .T.          
	cDtCont:= SubStr(TMPCT2->CT2_DATA,7,2)+"."+SubStr(TMPCT2->CT2_DATA,5,2)+"."+SubStr(TMPCT2->CT2_DATA,1,4)

	While TMPCT2->(!EOF())
		
		If AllTrim(TMPCT2->CT2_DC) == "1" //Debito

			//Grava o arquivo tempor·rio.
			REL->(RecLock("REL",.T.))
				
			REL->NEWBS := "40"
			REL->NEWKO := PADL(AllTrim(TMPCT2->CT2_DEBITO),10,"0")
			REL->DMBTR := ""
			REL->WRBTR := TMPCT2->CT2_VALOR
			REL->MWSKZ := "98"
			REL->XMWST := ""
			REL->ZFBDT := ""
			REL->VALUT := ""
			REL->PERNR := ""
			REL->VBUND := ""
			REL->XREF1 := ""
			REL->XREF2 := ""
			REL->XREF3 := ""
			REL->ZUONR := TMPCT2->CT2_CCD
			REL->SGTXT := "payroll"
			
			REL->(MSUnlock())

		ElseIf AllTrim(TMPCT2->CT2_DC) == "2" //Credito		   
                
			//Grava o arquivo tempor·rio.
			REL->(RecLock("REL",.T.)) 
			
			REL->NEWBS := "50"
			REL->NEWKO := PADL(AllTrim(TMPCT2->CT2_CREDIT),10,"0")
			REL->DMBTR := ""
			REL->WRBTR := TMPCT2->CT2_VALOR
			REL->MWSKZ := "98"
			REL->XMWST := ""
			REL->ZFBDT := ""
			REL->VALUT := ""
			REL->PERNR := ""
			REL->VBUND := ""
			REL->XREF1 := ""
			REL->XREF2 := ""
			REL->XREF3 := ""
			REL->ZUONR := "DT_"+AllTrim(Str(YEAR(DATE())))+AllTrim(Str(MONTH(DATE())))
			REL->SGTXT := "payroll"		
			
			REL->(MSUnlock())

		ElseIf AllTrim(TMPCT2->CT2_DC) == "3" //Partida Dobrada
		   
			///////////////////////////////
			//Inicia a gravaÁ„o do debito//
			///////////////////////////////

			If AllTrim(TMPCT2->CT2_DEBITO) >= AllTrim(cContaDe) .and. AllTrim(TMPCT2->CT2_DEBITO) <= AllTrim(cContaAte)

				//Grava o arquivo tempor·rio.
				REL->(RecLock("REL",.T.))
					
				REL->NEWBS := "40"
				REL->NEWKO := PADL(AllTrim(TMPCT2->CT2_DEBITO),10,"0")
				REL->DMBTR := ""
				REL->WRBTR := TMPCT2->CT2_VALOR
				REL->MWSKZ := "98"
				REL->XMWST := ""
				REL->ZFBDT := ""
				REL->VALUT := ""
				REL->PERNR := ""
				REL->VBUND := ""
				REL->XREF1 := ""
				REL->XREF2 := ""
				REL->XREF3 := ""
				REL->ZUONR := TMPCT2->CT2_CCD
				REL->SGTXT := "payroll"
			
				REL->(MSUnlock())
			EndIf             

			////////////////////////////////
			//Inicia a gravaÁ„o do crÈdito//
			////////////////////////////////

			If AllTrim(TMPCT2->CT2_CREDIT) >= AllTrim(cContaDe) .and. AllTrim(TMPCT2->CT2_CREDIT) <= AllTrim(cContaAte)
		   
				//Grava o arquivo tempor·rio.
				REL->(RecLock("REL",.T.)) 
				
				REL->NEWBS := "50"
				REL->NEWKO := PADL(AllTrim(TMPCT2->CT2_CREDIT),10,"0")
				REL->DMBTR := ""
				REL->WRBTR := TMPCT2->CT2_VALOR
				REL->MWSKZ := "98"
				REL->XMWST := ""
				REL->ZFBDT := ""
				REL->VALUT := ""
				REL->PERNR := "" 
				REL->VBUND := ""
				REL->XREF1 := ""
				REL->XREF2 := ""
				REL->XREF3 := ""
				REL->ZUONR := "DT_"+AllTrim(Str(YEAR(DATE())))+AllTrim(Str(MONTH(DATE()))) 
				REL->SGTXT := "payroll"	 

				REL->(MSUnlock())
			EndIf	   
		EndIf

		TMPCT2->(DbSkip())	
	EndDo
EndIf 


If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf
TMPCT2->(DbCloseArea())

Return lRet  
/*
Funcao  : Funcao4()
Objetivo: Imprime o relatÛrio
Autor   : Jo„o Silva
Data    : 17/11/2015
*/                 
*-----------------------*
Static Function Funcao4()
*-----------------------*
Local cXml := "" 
Local lColor := .T.

cXml+= '<?xml version="1.0"?>
cXml+= '<?mso-application progid="Excel.Sheet"?>
cXml+= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXml+= ' xmlns:o="urn:schemas-microsoft-com:office:office"
cXml+= ' xmlns:x="urn:schemas-microsoft-com:office:excel"
cXml+= ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXml+= ' xmlns:html="http://www.w3.org/TR/REC-html40">
cXml+= ' <Styles>
cXml+= '  <Style ss:ID="Default" ss:Name="Normal">
cXml+= '   <Alignment ss:Vertical="Bottom"/>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s62">
cXml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#4F81BD"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#4F81BD"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXml+= '    ss:Bold="1"/>
cXml+= '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s63">
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s67">
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s68">
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+= '  <NumberFormat ss:Format="0000000000"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s69">
cXml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s71">
cXml+= '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>
cXml+= '   <NumberFormat ss:Format="Fixed"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s72">
cXml+= '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#FFFFFF"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>
cXml+= '   <NumberFormat ss:Format="Fixed"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s73">
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>
cXml+= '   <NumberFormat ss:Format="Fixed"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s74">
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#DCE6F1"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+= '   <NumberFormat ss:Format="Fixed"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s75">
cXml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>
cXml+= '   <NumberFormat ss:Format="[$-F800]dddd\,\ mmmm\ dd\,\ yyyy"/>
cXml+= '  </Style>
cXml+= '  <Style ss:ID="s76">
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+= '   <Borders>
cXml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+= '     ss:Color="#B8CCE4"/>
cXml+= '   </Borders>
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+= '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>
cXml+= '   <NumberFormat/>
cXml+= '  </Style>
cXml+= ' </Styles>
cXml+= ' <Worksheet ss:Name="Bayer GL">
cXml+= '  <Table ss:ExpandedColumnCount="24" ss:ExpandedRowCount="1048576" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
cXml+= '   <Column ss:Width="39.75" ss:Span="1"/>
cXml+= '   <Column ss:Index="3" ss:Width="66"/>
cXml+= '   <Column ss:Width="39.75"/>
cXml+= '   <Column ss:Width="85.5"/>
cXml+= '   <Column ss:Width="46.5"/>
cXml+= '   <Column ss:Width="39.75" ss:Span="3"/>
cXml+= '   <Column ss:Index="11" ss:Width="52.5"/>
cXml+= '   <Column ss:Width="39.75"/>
cXml+= '   <Column ss:Width="118.5"/>
cXml+= '   <Column ss:Width="39.75" ss:Span="8"/>
cXml+= '   <Column ss:Index="23" ss:Width="59.25"/>
cXml+= '   <Column ss:Width="46.5"/>
cXml+= '   <Row ss:AutoFitHeight="0">
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">BKZ   </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">BUKRS </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">BLDAT </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">BLART </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">XBLNR </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">BKTXT </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">WAERS </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">WWERT </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">KURSF </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">NEWBS </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">NEWKO </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">DMBTR </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">WRBTR </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">MWSKZ </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">XMWST </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">ZFBDT </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">VALUT </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">PERNR </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">VBUND </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">XREF1 </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">XREF2 </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">XREF3 </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">ZUONR </Data></Cell>
cXml+= '    <Cell ss:StyleID="s62"><Data ss:Type="String">SGTXT </Data></Cell>
cXml+= '   </Row>

cXml := Funcao7(cXml) //Grava e limpa memoria da variavel.

REL->(DbSetOrder(1))
REL->(DbGoTop())
nLin := 1
While REL->(!EOF())
   	If nLin == 1  

	   	REL->(RecLock("REL",.F.))				
		
		REL->BKZ   := "x"
		REL->BUKRS := "9078"
		REL->BLDAT := cDtCont//DtoC(DATE())$
		REL->BLART := "SA"
		REL->XBLNR := "EMP_"+SubStr(cDtCont,7,4)+""+SubStr(cDtCont,4,2)+"_01"//"EMP_"+AllTrim(Str(YEAR(DATE())))+AllTrim(Str(MONTH(DATE())))+"_01"
		REL->BKTXT := "payroll"
		REL->WAERS := "BRL"
		REL->WWERT := "" 
		REL->KURSF := "" 
		
		REL->(MSUnlock())   
		
		cXml+= '   <Row ss:AutoFitHeight="0">
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BKZ   		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BUKRS		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BLDAT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BLART		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XBLNR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BKTXT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->WAERS		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->WWERT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->KURSF		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->NEWBS		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s68"><Data ss:Type="Number">'+REL->NEWKO		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->DMBTR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(Transform(REL->WRBTR,"9999999999.99"))+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->MWSKZ		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XMWST		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->ZFBDT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->VALUT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->PERNR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->VBUND		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XREF1		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XREF2		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XREF3		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->ZUONR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->SGTXT		+'</Data></Cell>
		cXml+= '   </Row>
		nLin+=1 
		REL->(RecLock("REL",.F.))     
		
		REL->BKZ   := ""
		REL->BUKRS := ""
		REL->BLDAT := ""
		REL->BLART := ""
		REL->XBLNR := ""
		REL->BKTXT := ""
		REL->WAERS := ""
		REL->WWERT := "" 
		REL->KURSF := "" 

		REL->(MSUnlock()) 
		
		REL->(DbSkip())
		
	Else    
		
		cXml+= '   <Row ss:AutoFitHeight="0">
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BKZ		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BUKRS		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BLDAT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BLART		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XBLNR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->BKTXT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->WAERS		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->WWERT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->KURSF		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->NEWBS		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s68"><Data ss:Type="Number">'+REL->NEWKO		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->DMBTR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(Transform(REL->WRBTR,"9999999999.99"))+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->MWSKZ		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XMWST		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->ZFBDT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->VALUT		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->PERNR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->VBUND		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XREF1		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XREF2		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->XREF3		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->ZUONR		+'</Data></Cell>
		cXml+= '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+REL->SGTXT		+'</Data></Cell>
		cXml+= '   </Row>
		
		If Len(cXml) >= 30000
			cXml := Funcao7(cXml) //Grava e limpa memoria da variavel.
		EndIf  
		
		REL->(DbSkip())
	EndIf
EndDo		
   
cXml+= '  </Table>
cXml+= '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXml+= '   <PageSetup>
cXml+= '    <Header x:Margin="0.31496062000000002"/>
cXml+= '    <Footer x:Margin="0.31496062000000002"/>
cXml+= '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"
cXml+= '     x:Right="0.511811024" x:Top="0.78740157499999996"/>
cXml+= '   </PageSetup>
cXml+= '   <Unsynced/>
cXml+= '   <Print>
cXml+= '    <ValidPrinterInfo/>
cXml+= '    <PaperSizeIndex>9</PaperSizeIndex>
cXml+= '    <HorizontalResolution>600</HorizontalResolution>
cXml+= '    <VerticalResolution>600</VerticalResolution>
cXml+= '   </Print>
cXml+= '   <Selected/>
cXml+= '   <Panes>
cXml+= '	<Pane>
cXml+= '     <Number>3</Number>
cXml+= '     <ActiveRow>2</ActiveRow>
cXml+= '     <ActiveCol>10</ActiveCol>
cXml+= '    </Pane>
cXml+= '   </Panes>
cXml+= '   <ProtectObjects>False</ProtectObjects>
cXml+= '   <ProtectScenarios>False</ProtectScenarios>
cXml+= '  </WorksheetOptions>
cXml+= ' </Worksheet>
cXml+= '</Workbook>		    

cXml := Funcao7(cXml) //Grava e limpa memoria da variavel.

Return .T.	



/*
Funcao  : Funcao5()
Objetivo: FunÁ„o para abrir o excel
Autor   : Jo„o Silva
Data    : 17/11/2015
*/                   
*-------------------------------*
Static Function Funcao5()
*-------------------------------*
Local cArq:= AllTrim(cNomeArq)
	
If lAbreExcel	
	SHELLEXECUTE("open",(cArq),"","",5)   // Abre o arquivo em Excel	
Else
	MsgInfo("O relatÛrio foi gerado com sucesso.","AtenÁ„o")
EndIf

Return

/*
FunÁ„o  : Funcao6
Objetivo: Verificar se os parametros est„o criados corretamente.
Autor   : Jo„o Silva
Data    : 17/11/2015
*/
*------------------------------*
Static Function Funcao6(cPerg)
*------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Data De ?"            },;
  					{"02","Data Ate ?"           },;
  					{"03","Da Conta ?"           },;
  					{"04","Ate Conta ?"          },;
  					{"05","Arquivo?"             },;
  					{"06","Abre Excel ?"         },;
  					{"07","Moeda ?"              },;
  					{"08","Impr. Cta S/ Movim ?" },;
  					{"09","Imprime C. Custo ?"   },;
  					{"10","Do Centro Custo ?"    },;
  					{"11","Ate Centro Custo ?"   },;
  					{"12","Imprime Item Contab ?"},;
  					{"13","Do Item Contabil ?"   },;
  					{"14","Ate Item Contabil ?"  },;
  					{"15","DescriÁ„o na Moeda ?" },;
  					{"16","Da Classe Valor ?"    },;
  					{"17","Ate Classe Valor ?"   }}
//Verifica se o SX1 estÅEcorreto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja o relatÛrio.") 
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatÛrio.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final atÅEa qual")
	Aadd( aHlpPor, "se desejÅEimprimir o relatÛrio.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"serÅEserÅEgerado.")
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\68CTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo serÅEaberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatÛrio.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir ou n„o as")
	Aadd( aHlpPor, "contas sem movimento.")      
	Aadd( aHlpPor, "'Sim' - Imprime contas mesmo sem saldo ")
	Aadd( aHlpPor, "ou movimento.")   
	Aadd( aHlpPor, "'Nao' - Imprime somente contas com ")
	Aadd( aHlpPor, "movimento no periodo.   ")   
	Aadd( aHlpPor, "'Nao c/ Sld.Ant.' - Imprime somente  ")
	Aadd( aHlpPor, "contas com movimento ou com saldo")   
	Aadd( aHlpPor, "anterior.")   
	
	U_PUTSX1(cPerg,"08","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","mv_ch8","N",01,0,1,"C","","","","S","mv_par08","Sim","Sim","Sim","","Nao","Nao","Nao","Nao c/Sld Ant.","Nao c/Sld Ant.","Nao c/Sld Ant.","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Centros")
	Aadd( aHlpPor, "de Custo.")      
	
	U_PUTSX1(cPerg,"09","Imprime C. Custo ?","Imprime C. Custo ?","Imprime C. Custo ?","mv_ch9","N",01,0,1,"C","","","","S","mv_par09","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Centros")
	Aadd( aHlpPor, "de Custo, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime C. Custo?'")      
	
	U_PUTSX1(cPerg,"10","Do Centro Custo ?","Do Centro Custo ?","Do Centro Custo ?","mv_cha","C",09,0,0,"G","","CTT","","S","mv_par10","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo final atÅEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Centros ")    
	Aadd( aHlpPor, "de Custo, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime C. Custo?'")          
	
	U_PUTSX1(cPerg,"11","Ate Centro Custo ?","Ate Centro Custo ?","Ate Centro Custo ?","mv_chb","C",09,0,0,"G","","CTT","","S","mv_par11","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Itens")
	Aadd( aHlpPor, "Cont·beis.")      
	
	U_PUTSX1(cPerg,"12","Imprime Item Contab ?","Imprime Item Contab ?","Imprime Item Contab ?","mv_chc","N",01,0,1,"C","","","","S","mv_par12","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Itens")
	Aadd( aHlpPor, "Cont·beis, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime Item Contab?'")      
	
	U_PUTSX1(cPerg,"13","Do Item Contabil ?","Do Item Contabil ?","Do Item Contabil ?","mv_chd","C",09,0,0,"G","","CTD","","S","mv_par13","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil final atÅEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")          
	
	U_PUTSX1(cPerg,"14","Ate Item Contabil ?","Ate Item Contabil ?","Ate Item Contabil ?","mv_che","C",09,0,0,"G","","CTD","","S","mv_par14","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	
	U_PUTSX1(cPerg,"15","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","mv_chf","C",02,0,0,"G","","CTO","","S","mv_par15","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	aHlpPor := {}
	U_PUTSX1(cPerg,"16","Da Classe de Valor ?","Da Classe de Valor ?","Da Classe de Valor ?","mv_chg","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par16","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	Aadd( aHlpPor, "Informe o Item Cont·bil final atÅEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")     
   
	U_PUTSX1(cPerg,"17","Ate Classe de Valor ?","Ate Classe de Valor ?","Ate Classe de Valor ?","mv_chh","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par17","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
EndIf

/*
Funcao	: Funcao7
Objetivo: FunÁ„o responsavel pela manutenÁ„o do arquivo para evitar que estoure.
Autor	: Jo„o Silva	
Data	: 17/11/2014
*/
*---------------------------*
Static Function Funcao7(cMsg)
*---------------------------*
Local nHdl	:= Fopen(cNomeArq)
FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)
Return "" 

/*
Funcao      : Funcao8
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : FunÁ„o cria linha de alteraÁ„o na ZXD
Autor       : Joao Silva
Data/Hora   : 08/10/2015
*/
*-------------------------------------------------*
Static Function Funcao8()
*-------------------------------------------------*  
Local nVersao	:= 0
Local dAtu 		:=Date()

If Select("ZXD") > 0
	ZXD->(dBCloseArea())
EndIf
DbSelectArea("ZXD")
ZXD->(DbSetOrder(1))
ZXD->(DbGoBottom()) 

nVersao := ZXD->ZXD_VERSAO

If 	Month(ZXD->ZXD_DATE)+Year(ZXD->ZXD_DATE) == Month(dAtu)+Year(ZXD->ZXD_DATE)
		nVersao += 1
Else
	Month(ZXD->ZXD_DATE)+Year(ZXD->ZXD_DATE) < Month(dAtu)+Year(ZXD->ZXD_DATE)
		nVersao := 	1
EndIf
  
RecLock("ZXD",.T.)
ZXD->ZXD_FILIAL:="01"
ZXD->ZXD_ID:=AllTrim(RetCodUsr())
ZXD->ZXD_USR:=AllTrim(cUserName)
ZXD->ZXD_HOUR:=TIME()
ZXD->ZXD_DATE:=DATE()
ZXD->ZXD_VERSAO:=nVersao
MsUnLock()

Return .T.      
	

Return Nil
