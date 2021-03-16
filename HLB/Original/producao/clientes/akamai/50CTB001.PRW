#Include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³50CTB001  ºAutor  ³João Silva			 º Data ³  22/02/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de Razão Contábil Customizado."	Modelo GL "       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Sumario
Função	: GeraRel () Objetivo: Gera o relatório.
Função	: TabTemp () Objetivo: Cria a tabela temporária que serEutilizada para a impressão.  
Função	: GravaTab() Objetivo: Realiza a gravação dos dados na tabela temporária. 
Funcao	: ImpRel  () Objetivo: Imprime o relatório          
Funcao	: AbriXML () Objetivo: Função para abrir o excel
Função	: CriaPerg() Objetivo: Verificar se os parametros estão criados corretamente.  
Funcão  : MaxXML  ()	Objetivo: Função responsavel pela manutenção do arquivo para evitar que estoure.   
Funcão	: LogExec () Objetivo: Log de execuções.
*/

*-----------------------*
User Function 50CTB001() 
*-----------------------*
Local lOk := .F.
Local cPerg := "50CTB001"

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

If cEmpAnt <> "50"//Verifica se Ea empresa Akamai 
	MsgInfo("Este relatorio não esta disponivel para essa empresa!","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
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
	
	//Gera o Relatório
	Processa({|| lOk := GeraRel()},"Gerando o relatório...")

	If !lOk
		MsgInfo("Não foram encontrados registros para os parâmetros informados.","Atenção")
		Return Nil
	EndIf

EndIf

Return Nil                           

/*
Função  : GeraRel
Objetivo: Gera o relatório
Autor   : João Silva
Data    : 17/11/2015
*/
*-----------------------*
Static Function GeraRel()
*-----------------------*
Local lGrvDados := .F.

Local cArqTrab := ""

//Cria a tabela temporária para impressão dos registros.
cArqTrab :=  TabTemp()
//Grava os Dados na tabela temporária
If !Empty(cArqTrab)
	lGrvDados := GravaTab()
EndIf  

//Criação do Arquivo HTML.
nHdl		:= FCREATE(cNomeArq,0 ) 

// Gravação do seu Conteudo.
nBytesSalvo	:= FWRITE(nHdl, "" ) 

// Fecha o Arquivo que foi Gerado
fclose(nHdl) 

If lGrvDados
	//Imprime o relatório
    ImpRel()
EndIf

//Abre excel
AbriXML() 

Return lGrvDados

/*
Função  : TabTemp
Objetivo: Cria a tabela temporária que serEutilizada para a impressão.
Autor   : João Silva
Data    : 17/11/2015
*/
*--------------------------*
Static Function TabTemp()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela temporária 
aAdd(aStru,{"ID          ","C",050,0})
aAdd(aStru,{"JE          ","C",010,0})	//MSM - 12/05/2016 - Chamado: 033864
aAdd(aStru,{"ENTITY      ","C",003,0})
aAdd(aStru,{"LOCATION    ","C",003,0})
aAdd(aStru,{"DEP         ","C",006,0})
aAdd(aStru,{"ACC         ","C",010,0})
aAdd(aStru,{"PRODUCT	 ","C",004,0})
aAdd(aStru,{"ICO         ","C",040,0})
aAdd(aStru,{"FUT1        ","C",004,0})
aAdd(aStru,{"FUT2        ","C",004,0})
aAdd(aStru,{"DT          ","N",014,2})
aAdd(aStru,{"CT          ","N",014,2})
aAdd(aStru,{"DESCRIPT 	 ","C",040,0})

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o ú‹dice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->DEP",,,"Selecionando Registro...")


DbSelectArea("REL")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

Return cArqTrab

/*
Função  : GravaTab
Objetivo: Realiza a gravação dos dados na tabela temporária.
Autor   : João Silva
Data    : 17/11/2015
*/
*--------------------------*
Static Function GravaTab()
*--------------------------*
Local lRet := .F.
Local ID          := ""
Local JE          := ""	//MSM - 12/05/2016 - Chamado: 033864
Local ENTITY      := ""
Local LOCATION    := ""
Local DEP         := ""
Local ACC         := ""
Local PRODUCT	  := ""
Local ICO         := ""
Local FUT1        := ""
Local FUT2        := ""
Local DT          := ""
Local CT          := ""
Local DESCRIPT	  := ""

Local cQryDebit	:= ""
Local cQryCredit:= ""  

Local nCont		:= 0
Local cChaveAnt	:= ""
/*
//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf
*/
//Imprime as contas sem movimentação.
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

/*
	BeginSql Alias 'TMPCT1'
	
		SELECT CT1_FILIAL, CT1_CONTA, CT1_DESC01,CT1_DESC02,CT1_DESC03,CT1_DESC04,CT1_P_CONT,CT1_P_DESC
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
*/	
EndIf

//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT2") > 0
	TMPCT2->(DbCloseArea())
EndIf

//Busca as movimentações de acordo com os parâmetros
BeginSql Alias 'TMPCT2'

	SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, CT2_TPSALD, CT2_EMPORI, 
		   CT2_FILORI, CT2_MOEDLC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_CCD, CT2_CCC ,       
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

	While TMPCT2->(!EOF())
		
		if cChaveAnt<>TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
			nCont++
		endif
		
		If AllTrim(TMPCT2->CT2_DC) == "1" //Debito

			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
				            //INDICE 1 = CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC       
			//REL->ID          := TMPCT2->(CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
			REL->ID          := TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
			REL->JE			 := cvaltochar(nCont)
			REL->ENTITY      := "114"
			REL->LOCATION    := "140"
			REL->DEP         := TMPCT2->CT2_CCD  
			
			//Busca a conta akamai
	       	CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+ALLTRIM(TMPCT2->CT2_DEBITO)))
				If	!Empty(CT1->CT1_P_CONT)
					  REL->ACC := AllTrim(CT1->CT1_P_CONT)
				Else
					MsgInfo("A conta Akamai não esta preenchida no cadastro da conta "+AllTrim(TMPCT2->CT2_DEBITO)+" !","HLB BRASIL")
						REL->ACC := TMPCT2->CT2_DEBITO					
		    	EndIf
		    EndIf		    
			REL->PRODUCT	 := TMPCT2->CT2_CLVLDB
			REL->ICO         := TMPCT2->CT2_ITEMD
			REL->FUT1        := "0000"
			REL->FUT2        := "0000"
			REL->DT          := TMPCT2->CT2_VALOR
			REL->DESCRIPT    := TMPCT2->CT2_HIST
				
			REL->(MSUnlock())

		ElseIf AllTrim(TMPCT2->CT2_DC) == "2" //Credito		   
                
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.)) 
			                       
				            //INDICE 1 = CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC       
			//REL->ID          := TMPCT2->(CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
			REL->ID          := TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
			REL->JE			 := cvaltochar(nCont)
			REL->ENTITY      := "114"
			REL->LOCATION    := "140"
			REL->DEP         := TMPCT2->CT2_CCC
			//Busca a conta akamai
	       	CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+ALLTRIM(TMPCT2->CT2_CREDIT)))
				If	!Empty(CT1->CT1_P_CONT)
					  REL->ACC := AllTrim(CT1->CT1_P_CONT)
				Else
					MsgInfo("A conta Akamai não esta preenchida no cadastro da conta "+AllTrim(TMPCT2->CT2_CREDIT)+" !","HLB BRASIL")
					REL->ACC := TMPCT2->CT2_CREDIT					
			    EndIf  
			EndIf
			REL->PRODUCT     := TMPCT2->CT2_CLVLCR
			REL->ICO         := TMPCT2->CT2_ITEMC
			REL->FUT1        := "0000"
			REL->FUT2        := "0000"
			REL->CT          := TMPCT2->CT2_VALOR
			REL->DESCRIPT    := TMPCT2->CT2_HIST
			
			REL->(MSUnlock())

		ElseIf AllTrim(TMPCT2->CT2_DC) == "3" //Partida Dobrada
		   
			///////////////////////////////
			//Inicia a gravação do debito//
			///////////////////////////////

			If AllTrim(TMPCT2->CT2_DEBITO) >= AllTrim(cContaDe) .and. AllTrim(TMPCT2->CT2_DEBITO) <= AllTrim(cContaAte)

				//Grava o arquivo temporário.
				REL->(RecLock("REL",.T.))
					
				            	//INDICE 1 = CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC       
				//REL->ID          := TMPCT2->(CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
				REL->ID          := TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
				REL->JE			 := cvaltochar(nCont)
				REL->ENTITY      := "114"
				REL->LOCATION    := "140"
				REL->DEP         := TMPCT2->CT2_CCD
				//Busca a conta akamai
		       	CT1->(DbSetOrder(1))
				If CT1->(DbSeek(xFilial("CT1")+ALLTRIM(TMPCT2->CT2_DEBITO)))
					If	!Empty(CT1->CT1_P_CONT)
					  	REL->ACC := AllTrim(CT1->CT1_P_CONT)
					Else
						MsgInfo("A conta Akamai não esta preenchida no cadastro da conta "+AllTrim(TMPCT2->CT2_DEBITO)+" !","HLB BRASIL")
						REL->ACC := TMPCT2->CT2_DEBITO					
		    		EndIf  
		    	EndIf
				REL->PRODUCT	 := TMPCT2->CT2_CLVLDB
				REL->ICO         := TMPCT2->CT2_ITEMD
				REL->FUT1        := "0000"
				REL->FUT2        := "0000"
				REL->DT          := TMPCT2->CT2_VALOR
				REL->DESCRIPT    := TMPCT2->CT2_HIST
							
				REL->(MSUnlock())
			EndIf             

			////////////////////////////////
			//Inicia a gravação do crédito//
			////////////////////////////////

			If AllTrim(TMPCT2->CT2_CREDIT) >= AllTrim(cContaDe) .and. AllTrim(TMPCT2->CT2_CREDIT) <= AllTrim(cContaAte)
		   
				//Grava o arquivo temporário.
				REL->(RecLock("REL",.T.)) 

								//INDICE 1 = CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC       
				//REL->ID          := TMPCT2->(CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)
				REL->ID          := TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
				REL->JE			 := cvaltochar(nCont)
				REL->ENTITY      := "114"
		 		REL->LOCATION    := "140"
	  			REL->DEP         := TMPCT2->CT2_CCC        
	  			//Busca a conta akamai
		       	CT1->(DbSetOrder(1))
				If CT1->(DbSeek(xFilial("CT1")+ALLTRIM(TMPCT2->CT2_CREDIT)))
					If	!Empty(CT1->CT1_P_CONT)
						  REL->ACC := AllTrim(CT1->CT1_P_CONT)
					Else
						MsgInfo("A conta Akamai não esta preenchida no cadastro da conta "+AllTrim(TMPCT2->CT2_CREDIT)+" !","HLB BRASIL")
						REL->ACC := TMPCT2->CT2_CREDIT					
				    EndIf  
				EndIf
				REL->PRODUCT     := TMPCT2->CT2_CLVLCR
				REL->ICO         := TMPCT2->CT2_ITEMC
				REL->FUT1        := "0000"
				REL->FUT2        := "0000"
				REL->CT          := TMPCT2->CT2_VALOR
				REL->DESCRIPT    := TMPCT2->CT2_HIST

				REL->(MSUnlock())
			EndIf	   
		EndIf
        
		cChaveAnt:=TMPCT2->(CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC)

		TMPCT2->(DbSkip())	
	EndDo
EndIf 

/*
If Select("TMPCT1") > 0
	TMPCT1->(DbCloseArea())
EndIf  
*/
TMPCT2->(DbCloseArea())

Return lRet  
/*
Funcao  : ImpRel()
Objetivo: Imprime o relatório
Autor   : João Silva
Data    : 17/11/2015
*/                 
*-----------------------*
Static Function ImpRel()
*-----------------------*
Local cXml := "" 
Local lColor := .T.
Local cConta := ""  

cXml+='<?xml version="1.0"?>
cXml+='<?mso-application progid="Excel.Sheet"?>
cXml+='<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXml+=' xmlns:o="urn:schemas-microsoft-com:office:office"
cXml+=' xmlns:x="urn:schemas-microsoft-com:office:excel"
cXml+=' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXml+=' xmlns:html="http://www.w3.org/TR/REC-html40">
cXml+=' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
cXml+='  <Version>15.00</Version>
cXml+=' </DocumentProperties>
cXml+=' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
cXml+='  <AllowPNG/>
cXml+=' </OfficeDocumentSettings>
cXml+=' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
cXml+='  <WindowHeight>8340</WindowHeight>
cXml+='  <WindowWidth>19530</WindowWidth>
cXml+='  <WindowTopX>0</WindowTopX>
cXml+='  <WindowTopY>0</WindowTopY>
cXml+='  <ProtectStructure>False</ProtectStructure>
cXml+='  <ProtectWindows>False</ProtectWindows>
cXml+=' </ExcelWorkbook>
cXml+=' <Styles>
cXml+='  <Style ss:ID="Default" ss:Name="Normal">
cXml+='   <Alignment ss:Vertical="Bottom"/>
cXml+='   <Borders/>
cXml+='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+='   <Interior/>
cXml+='   <NumberFormat/>
cXml+='   <Protection/>
cXml+='  </Style>
cXml+='  <Style ss:ID="s62">
cXml+='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXml+='    ss:Bold="1"/>
cXml+='   <Interior ss:Color="#4472C4" ss:Pattern="Solid"/>
cXml+='  </Style>
cXml+='  <Style ss:ID="s63">
cXml+='   <NumberFormat ss:Format="@"/>
cXml+='  </Style>
cXml+='  <Style ss:ID="s64">
cXml+='   <NumberFormat ss:Format="Fixed"/>
cXml+='  </Style>
cXml+='  <Style ss:ID="s65">
cXml+='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXml+='    ss:Bold="1"/>
cXml+='   <Interior ss:Color="#4472C4" ss:Pattern="Solid"/>
cXml+='   <NumberFormat ss:Format="Fixed"/>
cXml+='  </Style>
cXml+='  <Style ss:ID="s68">
cXml+='	<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	<Borders>
cXml+='	<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXml+='	ss:Color="#DCE6F1"/>
cXml+='	<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXml+='	ss:Color="#DCE6F1"/>
cXml+='	</Borders>
cXml+='	<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+='	<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	<NumberFormat ss:Format="0000000000"/>
cXml+='	</Style>
cXml+=' </Styles>
cXml+=' <Worksheet ss:Name="Jornal Entry">
cXml+='  <Table ss:ExpandedColumnCount="13" ss:ExpandedRowCount="1048576" x:FullColumns="1"
cXml+='   x:FullRows="1" ss:DefaultRowHeight="15">
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="204"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="64"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="60.75"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="64.5"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="53.25"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="81.75"/>
cXml+='   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>
cXml+='   <Column ss:Index="11" ss:StyleID="s64" ss:AutoFitWidth="0" ss:Span="1"/>
cXml+='   <Column ss:Index="13" ss:Width="242.25"/>
cXml+='   <Row ss:AutoFitHeight="0">
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">ID 		</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">JE 		</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">ENTITY 	</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">LOCATION	</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">DEP		</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">ACC		</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">PRODUCT LINE</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">ICO		</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">FUT1		</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">FUT2		</Data></Cell>
cXml+='    <Cell ss:StyleID="s65"><Data ss:Type="String">DT			</Data></Cell>
cXml+='    <Cell ss:StyleID="s65"><Data ss:Type="String">CT			</Data></Cell>
cXml+='    <Cell ss:StyleID="s62"><Data ss:Type="String">DESCRIPTION</Data></Cell>
cXml+='   </Row>

cXml := MaxXML(cXml) //Grava e limpa memoria da variavel.

REL->(DbSetOrder(1))
REL->(DbGoTop())
nLin := 1
While REL->(!EOF())

		cXml+='   <Row ss:AutoFitHeight="0">
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->ID		+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->JE		+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->ENTITY	+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->LOCATION+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->DEP 	+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->ACC		+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->PRODUCT	+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->ICO		+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->FUT1	+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->FUT2	+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="Number">'+ALLTRIM(Transform(REL->DT,"99999999999.99"))		+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="Number">'+ALLTRIM(Transform(REL->CT,"99999999999.99"))		+'</Data></Cell>
		cXml+='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+REL->DESCRIPT+'</Data></Cell>
		cXml+='   </Row>   

		LogExec() // Log de execuções.
		
		nLin+=1 
		
		REL->(MSUnlock()) 
		
		REL->(DbSkip())
		
		If Len(cXml) >= 30000
			cXml := MaxXML(cXml) //Grava e limpa memoria da variavel.
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

cXml := MaxXML(cXml) //Grava e limpa memoria da variavel.

Return .T.	

/*
Funcao  : AbriXML()
Objetivo: Função para abrir o excel
Autor   : João Silva
Data    : 17/11/2015
*/                   
*-------------------------------*
Static Function AbriXML()
*-------------------------------*
Local cArq:= AllTrim(cNomeArq)
	
If lAbreExcel	
	SHELLEXECUTE("open",(cArq),"","",5)   // Abre o arquivo em Excel	
Else
	MsgInfo("O relatório foi gerado com sucesso.","Atenção")
EndIf

Return

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : João Silva
Data    : 17/11/2015
*/
*------------------------------*
Static Function CriaPerg(cPerg)
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
  					{"15","Descrição na Moeda ?" },;
  					{"16","Da Classe Valor ?"    },;
  					{"17","Ate Classe Valor ?"   }}
//Verifica se o SX1 estEcorreto
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
	Aadd( aHlpPor, "se deseja o relatório.") 
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatório.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final atEa qual")
	Aadd( aHlpPor, "se desejEimprimir o relatório.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"serEserEgerado.")
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\50CTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo serEaberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatório.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir ou não as")
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
	Aadd( aHlpPor, "do qual se deseja imprimir o relatório.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Centros")
	Aadd( aHlpPor, "de Custo, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime C. Custo?'")      
	
	U_PUTSX1(cPerg,"10","Do Centro Custo ?","Do Centro Custo ?","Do Centro Custo ?","mv_cha","C",09,0,0,"G","","CTT","","S","mv_par10","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo final atEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Centros ")    
	Aadd( aHlpPor, "de Custo, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime C. Custo?'")          
	
	U_PUTSX1(cPerg,"11","Ate Centro Custo ?","Ate Centro Custo ?","Ate Centro Custo ?","mv_chb","C",09,0,0,"G","","CTT","","S","mv_par11","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Itens")
	Aadd( aHlpPor, "Contábeis.")      
	
	U_PUTSX1(cPerg,"12","Imprime Item Contab ?","Imprime Item Contab ?","Imprime Item Contab ?","mv_chc","N",01,0,1,"C","","","","S","mv_par12","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Contábil inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatório.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Itens")
	Aadd( aHlpPor, "Contábeis, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime Item Contab?'")      
	
	U_PUTSX1(cPerg,"13","Do Item Contabil ?","Do Item Contabil ?","Do Item Contabil ?","mv_chd","C",09,0,0,"G","","CTD","","S","mv_par13","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Contábil final atEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Contábeis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")          
	
	U_PUTSX1(cPerg,"14","Ate Item Contabil ?","Ate Item Contabil ?","Ate Item Contabil ?","mv_che","C",09,0,0,"G","","CTD","","S","mv_par14","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	
	U_PUTSX1(cPerg,"15","Descrição na Moeda ?","Descrição na Moeda ?","Descrição na Moeda ?","mv_chf","C",02,0,0,"G","","CTO","","S","mv_par15","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	aHlpPor := {}
	U_PUTSX1(cPerg,"16","Da Classe de Valor ?","Da Classe de Valor ?","Da Classe de Valor ?","mv_chg","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par16","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	Aadd( aHlpPor, "Informe o Item Contábil final atEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Contábeis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")     
   
	U_PUTSX1(cPerg,"17","Ate Classe de Valor ?","Ate Classe de Valor ?","Ate Classe de Valor ?","mv_chh","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par17","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
EndIf

/*
Funcao	: MaxXML
Objetivo: Função responsavel pela manutenção do arquivo para evitar que estoure.
Autor	: João Silva	
Data	: 17/11/2014
*/
*---------------------------*
Static Function MaxXML(cMsg)
*---------------------------*
Local nHdl	:= Fopen(cNomeArq,2)
FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)
Return "" 

/*
Funcao      : LogExec
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função cria linha de alteração na ZXF
Autor       : Joao Silva
Data/Hora   : 08/10/2015
*/
*-------------------------------------------------*
Static Function LogExec()
*-------------------------------------------------*  
Local dAtu 		:=Date()

If Select("ZXF") > 0
	ZXF->(dBCloseArea())
EndIf
DbSelectArea("ZXF")
ZXF->(DbSetOrder(1))
ZXF->(DbGoBottom()) 

RecLock("ZXF",.T.)
ZXF->ZXF_FILIAL:="01"
ZXF->ZXF_ID:=AllTrim(RetCodUsr())
ZXF->ZXF_USR:=AllTrim(cUserName)
ZXF->ZXF_HOUR:=TIME()
ZXF->ZXF_DATE:=DATE()
ZXF->ZXF_KEYCTB:=REL->ID 

MsUnLock()

Return .T.      
	

Return Nil
