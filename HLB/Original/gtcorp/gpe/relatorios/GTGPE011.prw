#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"

/*
Funcao      : GTGPE011
Parametros  : 
Retorno     : 
Objetivos   : Relatorio de Funcionarios demitidos
Autor       : Jean Victor Rocha
Data/Hora   : 11/08/2015
TDN         : 
*/
*----------------------*
User Function GTGPE011()
*----------------------*
Private cDest := GetTempPath()+"\"
Private cArq := "Demitidos.XLS"

Private cXML := ""

Private nHdl := 0

IF FILE(cDest+cArq)
	If FERASE(cDest+cArq) < 0
		MsgInfo("Falha ao apagar arquivo 'Demitidos.xls', verifique se não está em uso por outra aplicação!")
		Return .F.
	EndIf
ENDIF

nHdl := FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
FWRITE(nHdl, ""  ) 		// Gravação do seu Conteudo.
fclose(nHdl) 


WizardRel()

Return .T. 

/*
Funcao      : WizardRel()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard para geração do Relatorio.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function WizardRel()
*-------------------------*
Local lWizArq
Local lInverte := .F.

Private cMarca  := GetMark()
Private oWizArq
Private cArqTxt := ""
Private ocDirArq
Private oMeter
Private nMeter := 0
Private oMeter2    
Private nMeter2 := 0
Private oSayTxt

oWizArq := APWizard():New("Relatorio de Demitidos", ""/*<chMsg>*/, "Geração de Arquivo.",;
										"Geração de Relatorio de Demitidos.",;
										 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/)

//Painel 2
oWizArq:NewPanel( "Empresas", "Selecione as empresas que serão impressas!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//Msselect da Empresas
aCpEmp := {	{"WKMARCA"  ,"C",01,0},;
			{"M0_CODIGO","C",02,0},;
	    	{"M0_CODFIL","C",02,0},;
			{"M0_FILIAL","C",15,0},;
			{"M0_NOME"  ,"C",15,0},;
			{"M0_CGC"   ,"C",14,0}}

If Select("TMPEMP") > 0
	TMPEMP->(DbClosearea())
Endif     	      

cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)
 
SM0->(DbGoTop())
While SM0->(!EOF())
	TMPEMP->(DbAppend())
	TMPEMP->WKMARCA   := "1"//cMarca
	TMPEMP->M0_CODIGO := SM0->M0_CODIGO
	TMPEMP->M0_CODFIL := SM0->M0_CODFIL
	TMPEMP->M0_FILIAL := SM0->M0_FILIAL
	TMPEMP->M0_NOME   := SM0->M0_NOME	        
    TMPEMP->M0_CGC    := SM0->M0_CGC
	
	SM0->(DbSkip())	
EndDo

oGrp := TGroup():New( 004,004,134,296,"Marque as empresas/filiais",oWizArq:oMPanel[2],,,.T.,.F. )

DEFINE FWBROWSE oBrowEmp DATA TABLE ALIAS "TMPEMP" OF oGrp

ADD MARKCOLUMN oColumn DATA {|| If(WKMARCA=="1",'LBOK',IIF(WKMARCA=="2",'LBNO',)) } DOUBLECLICK { |oBrowEmp| MarcBroEmp()} HEADERCLICK { |oBrowEmp| MarcBroAll("TMPEMP")} OF oBrowEmp		
ADD COLUMN oColumn DATA {|| M0_CODIGO	} TITLE "Cod.Emp."  							DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA {|| M0_NOME		} TITLE "Empresa"  								DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA {|| M0_FILIAL 	} TITLE "Filial"  							  	DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA {|| M0_CGC 		} TITLE "CNPJ" PICTURE "@R 99.999.999/9999-99"	DOUBLECLICK  {||  }  SIZE 14 OF oBrowEmp 

oBrowEmp:LOPTIONCONFIG := .F.
oBrowEmp:LOPTIONREPORT := .F.
oBrowEmp:LLOCATE := .F.
oBrowEmp:DisableConfig()
oBrowEmp:DisableReport()

ACTIVATE FWBROWSE oBrowEmp
                                
//Painel 3
oWizArq:NewPanel( "Configurações", "Selecione os Filtros a serem considerados para a Impressão!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtInicial	:= STOD("")
dDtFinal	:= STOD("")

@ 010, 010 TO 125,280 OF oWizArq:oMPanel[3] PIXEL
oSBox1 := TScrollBox():New( oWizArq:oMPanel[3],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Inicial? " SIZE 100,10 OF oSBox1 PIXEL
odDtInicial:= TGet():New(20,85,{|u| if(PCount()>0,dDtInicial:=u,dDtInicial)},oSBox1,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtInicial')

@ 41,20 SAY oSay0 VAR "Dt. Final? " SIZE 100,10 OF oSBox1 PIXEL
oDtFinal:= TGet():New(40,85,{|u| if(PCount()>0,dDtFinal:=u,dDtFinal)},oSBox1,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtFinal')


//Painel 4               
oWizArq:NewPanel( "Processamento", "",{ || .F.}/*<bBack>*/, /*<bNext>*/, {|| lWizArq := .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| ProcArq()}/*<bExecute>*/ )

@ 21,20 SAY oSayTxt VAR ""  SIZE 280,10 OF oWizArq:oMPanel[4] PIXEL
nMeter := 0
oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizArq:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 

//Ativa o Wizard
oWizArq:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return .T.

/*
Funcao      : MarcBroEmp()  
Parametros  : 
Retorno     : 
Objetivos   : Marca tela de Empresas.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static function MarcBroEmp()
*--------------------------------*
Local cRec	:= TMPEMP->(RECNO())

TMPEMP->(DbGoTo(cRec))

RecLock("TMPEMP",.F.)
	TMPEMP->WKMARCA:=IIF(TMPEMP->WKMARCA=="1","2","1") 
TMPEMP->(MsUnlock())

Return .T.

/*
Funcao      : MarcBroAll()  
Parametros  : 
Retorno     : 
Objetivos   : Marca /Desmarca Todos FwBrowse
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static function MarcBroAll(cAlias)
*--------------------------------*
Local cAux := ""
(cAlias)->(DbGoTop())

cAux := IIF((cAlias)->WKMARCA=="1","2","1")

While (cAlias)->(!EOF())
	(cAlias)->(RecLock(cAlias,.F.))
	(cAlias)->WKMARCA := cAux 
	(cAlias)->(MsUnlock())

	(cAlias)->(DbSkip())
EndDo

If Type("oBrowAux") == "O"
	oBrowAux:Refresh(.T.)
EndIf                    
If Type("oBrowEmp") == "O"
	oBrowEmp:Refresh(.T.)
EndIf

Return .T.

/*
Funcao     : ProcArq
Parametros : Nenhum
Retorno    : 
Objetivos  : Cria o Arquivo.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
Static Function ProcArq()
*-----------------------*
Local cXML := ""
Local i, j
Local lZebra := .T.
Local cQry 		:= ""
Local cQryCount := ""
Local cQryWhere := ""

Local aAux := {}
Local nPos := 0
Local cFiliais := ""

oWizArq:OBACK:LVISIBLECONTROL	:= .F.
oWizArq:OCANCEL:LVISIBLECONTROL	:= .F.
oWizArq:ONEXT:LVISIBLECONTROL	:= .F.
oWizArq:OFINISH:LVISIBLECONTROL	:= .F.

If !EMPTY(dDtInicial)
	cQryWhere += " AND SRA.RA_DEMISSA >= '"+ALLTRIM(DTOS(dDtInicial))+"'
Else
	cQryWhere += " AND SRA.RA_DEMISSA >= '19700101'
EndIf
If !EMPTY(dDtFinal)
	cQryWhere += " AND SRA.RA_DEMISSA <= '"+ALLTRIM(DTOS(dDtFinal))+"'
Else
	cQryWhere += " AND SRA.RA_DEMISSA <= '22001231'
EndIf
cQryWhere += " AND SRA.D_E_L_E_T_ = '' AND SRA.RA_SITFOLH = 'D'  

//Tratamento para empresas selecionadas.
aAux := {}
nPos := 0
TMPEMP->(DbGoTop())
While TMPEMP->(!EOF())
	If TMPEMP->WKMARCA == "1"
		If (nPos:=aScan(aAux,{|x| x[1] == TMPEMP->M0_CODIGO})) <> 0
			aAdd(aAux[npos][2],TMPEMP->M0_CODFIL)
		Else
			aAdd(aAux,{TMPEMP->M0_CODIGO,{TMPEMP->M0_CODFIL}} )
		EndIf
	EndIf
	TMPEMP->(DbSkip())
EndDo

For i:=1 to len(aAux)
	//Tratamento para a seleção de varias filiais da mesma empresa
	cFiliais := "("
	For j:=1 to len(aAux[i][2])
		cFiliais += "'"+aAux[i][2][j]+"',"
	Next j
	cFiliais := Left(cFiliais,Len(cFiliais)-1)+")"
	
	cQry += " SELECT SM0.M0_CODIGO,SM0.M0_CODFIL,SM0.M0_CGC,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_RESCRAI,SX5.X5_DESCRI,SRA.RA_DEMISSA,SRA.RA_ADMISSA"
	cQry += " FROM SRA"+aAux[i][1]+"0 AS SRA"
	cQry += 	" LEFT OUTER JOIN SIGAMAT AS SM0 ON SM0.M0_CODIGO = '"+aAux[i][1]+"' AND SM0.M0_CODFIL = SRA.RA_FILIAL"
	cQry += 	" LEFT OUTER JOIN SX5YY0 AS SX5 ON SX5.X5_TABELA = '27' AND SX5.D_E_L_E_T_ = '' AND SX5.X5_CHAVE = SRA.RA_RESCRAI"
	cQry += " WHERE SRA.RA_FILIAL in "+cFiliais+" "+cQryWhere
	        
	cQryCount += " SELECT Count(*) as ROWS 
	cQryCount += " FROM dbo.SRA"+aAux[i][1]+"0 AS SRA
	cQryCount += " WHERE SRA.RA_FILIAL in "+cFiliais+" "+cQryWhere
	If i <> Len(aAux)
		cQry += " UNION
		cQryCount += " UNION ALL
	EndIf
	
	cQryCount += CHR(13)+CHR(10)
	cQry += CHR(13)+CHR(10)
Next i
cQry += " Order By SRA.RA_DEMISSA 

//Contador
cQryCount := "Select Sum(ROWS) as COUNT From("+cQryCount+") AS VALORES
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     	       
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryCount),"QRY",.F.,.T.)

oMeter:LVISIBLE := .T.
oMeter:NTOTAL	:= QRY->COUNT

//Executa query dos Demitidos
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     	     
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

QRY->(DbGoTop())
If  QRY->(!EOF())
	cXML += '<?xml version="1.0"?>
	cXML += '<?mso-application progid="Excel.Sheet"?>
	cXML += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += ' xmlns:o="urn:schemas-microsoft-com:office:office"
	cXML += ' xmlns:x="urn:schemas-microsoft-com:office:excel"
	cXML += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += ' xmlns:html="http://www.w3.org/TR/REC-html40">
	cXML += CHR(13)+CHR(10)
	cXML += ' <Styles>
	cXML += '  <Style ss:ID="Default" ss:Name="Normal">
	cXML += '   <Alignment ss:Vertical="Bottom"/>
	cXML += '   <Borders/>
	cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
	cXML += '   <Interior/>
	cXML += '   <NumberFormat/>
	cXML += '   <Protection/>
	cXML += '  </Style>
	cXML += '  <Style ss:ID="s93">
	cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
	cXML += '   <Interior ss:Color="#4472C4" ss:Pattern="Solid"/>
	cXML += '  </Style>
	cXML += '  <Style ss:ID="s123">
	cXML += '   <Borders>
	cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#4472C4"/>
	cXML += '   </Borders>
	cXML += '   <Interior ss:Color="#DDEBF7" ss:Pattern="Solid"/>
	cXML += '  </Style>
	cXML += '  <Style ss:ID="s124">
	cXML += '   <Borders>
	cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#4472C4"/>
	cXML += '   </Borders>
	cXML += '   <Interior ss:Color="#DDEBF7" ss:Pattern="Solid"/>
	cXML += '   <NumberFormat ss:Format="Short Date"/>
	cXML += '  </Style>
	cXML += '  <Style ss:ID="s125">
	cXML += '   <Borders>
	cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#4472C4"/>
	cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#4472C4"/>
	cXML += '   </Borders>
	cXML += '   <Interior ss:Color="#BDD7EE" ss:Pattern="Solid"/>
	cXML += '  </Style>
	cXML += '  <Style ss:ID="s126">
	cXML += '   <Borders>
	cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#4472C4"/>
	cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#4472C4"/>
	cXML += '   </Borders>
	cXML += '   <Interior ss:Color="#BDD7EE" ss:Pattern="Solid"/>
	cXML += '   <NumberFormat ss:Format="Short Date"/>
	cXML += '  </Style>
	cXML += ' </Styles>
	cXML += CHR(13)+CHR(10)
	cXML += ' <Worksheet ss:Name="DEMITIDOS">
	cXML += '  <Names><NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=DEMITIDOS!R1C1:R1C11" ss:Hidden="1"/></Names>
	cXML += CHR(13)+CHR(10)
	cXML += '  <Table ss:ExpandedColumnCount="11" ss:ExpandedRowCount="99999999" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
	cXML += '   <Column ss:Width="60.75"/>
	cXML += '   <Column ss:Width="44.25"/>
	cXML += '   <Column ss:Width="79.5"/>
	cXML += '   <Column ss:Width="135.75"/>
	cXML += '   <Column ss:Width="120.75"/>
	cXML += '   <Column ss:Width="72.75"/>
	cXML += '   <Column ss:Width="129.75"/>
	cXML += '   <Column ss:Width="83.25" ss:Span="1"/>
	cXML += '   <Column ss:Index="10" ss:Width="79.5"/>
	cXML += '   <Column ss:Width="280.5"/>
	cXML += CHR(13)+CHR(10)
	cXML += '   <Row>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">COD EMP</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">FILIAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">CNPJ</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">NOME EMPRESA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">NOME FILIAL</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">MATRICULA</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">NOME</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">ADMISSAO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">DEMISSAO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">COD RECISAO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '    <Cell ss:StyleID="s93"><Data ss:Type="String">RECISAO</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
	cXML += '   </Row>
	While QRY->(!EOF())
		oSayTxt:CCAPTION := "Processando registro "+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(oMeter:NTOTAL))+"..."
		oMeter:Set(i)
		cXML += CHR(13)+CHR(10)
		cXML += '   <Row>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+ALLTRIM(QRY->M0_CODIGO)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+ALLTRIM(QRY->M0_CODFIL)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+ALLTRIM(QRY->M0_CGC)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+FWEmpName(QRY->M0_CODIGO)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+FWFilialName(ALLTRIM(QRY->M0_CODIGO),;
																											ALLTRIM(QRY->M0_CODFIL),2)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+ALLTRIM(QRY->RA_MAT)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+ALLTRIM(QRY->RA_NOME)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s124','s126')+'"><Data ss:Type="DateTime">'+LEFT(	QRY->RA_ADMISSA,4)+'-'+;
																								SubStr(	QRY->RA_ADMISSA,5,2)+'-'+;
																								RIGHT(	QRY->RA_ADMISSA,2)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s124','s126')+'"><Data ss:Type="DateTime">'+LEFT(	QRY->RA_DEMISSA,4)+'-'+;
																								SubStr(	QRY->RA_DEMISSA,5,2)+'-'+;
																								RIGHT(	QRY->RA_DEMISSA,2)+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+IIF(!EMPTY(QRY->RA_RESCRAI),;
																										ALLTRIM(QRY->RA_RESCRAI),;
																										"Nao Informado")+'</Data></Cell>
		cXML += '    <Cell ss:StyleID="'+IIF(lZebra,'s123','s125')+'"><Data ss:Type="String">'+ALLTRIM(QRY->X5_DESCRI)+'</Data></Cell>
		cXML += '   </Row>		
		                   
		If LEN(cXML) >= 50000
			cXml := GrvInfo(cXml)
		EndIf
		i++
		QRY->(DbSkip())
	EndDo
	cXML += CHR(13)+CHR(10)
	cXML += '  </Table>
	cXML += CHR(13)+CHR(10)
	cXML += '  <AutoFilter x:Range="R1C1:R1C11" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>
	cXML += CHR(13)+CHR(10)
	cXML += ' </Worksheet>
	cXML += '</Workbook>
	
	cXml := GrvInfo(cXml)
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)
	
	oMeter:LVISIBLE := .F.
	oSayTxt:CCAPTION := "Processamento Finalizado! Excel será aberto automaticamente."
Else                  
	oMeter:LVISIBLE := .F.
	oSayTxt:CCAPTION := "Sem Dados para serem exibidos."
EndIf                 
oWizArq:OFINISH:LVISIBLECONTROL	:= .T.

Return .T.

/*
Funcao      : GrvInfo()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function GrvInfo(cMsg)
*---------------------------*
Local nHdl	:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""