#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP88
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para gerar relatório com o faturamento por cliente
Autor       : Jean Victor Rocha
Revisão		:
Data/Hora   : 04/03/2014
Módulo      : Faturamento
*/
*----------------------*
User Function GTCORP88()
*----------------------*
Local nPos		:= 0
Local aAllGroup	:= {} //FWAllGrpCompany() //Empresas

Local nLinha	:= 01	//linha inicial para apresentação do checkbox
Local lMacTd	:= .F.
Local oMacTd 


/*
	* Leandro Brito - Carrega todas empresas que o usuario tem acesso
*/
AEval( FWEmpLoad() , { | x | If( Ascan( aAllGroup , x[ 1 ] ) == 0 , Aadd( aAllGroup , x[ 1 ] ) , ) } )  



//Tira a empresa modelo.
If (nPos := aScan(aAllGroup, {|x| x == "YY"})) <> 0
	aDel(aAllGroup,nPos)
	ASize(aAllGroup,Len(aAllGroup)-1)
EndIf

oDlg := MSDialog():New(180,180,650,500,"Parâmetros",,,.F.,,,,,,.T.,,,.T. )                                  

oMacTd := TCheckBox():New( 02,03,"Marca todos" ,,oDlg,50, 10,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oMacTd:bSetGet		:= {|| lMacTd }
oMacTd:bLClicked	:= {|| lMacTd:=!lMacTd,MarcTodo(aAllGroup,lMacTd)}
oMacTd:bWhen		:= {|| .T. }

oSay1 := TSay():New(02,60,{|| "Selecione a(s) empresa(s):" },oDlg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,10)

// Scroll da parte superior
oScr1 := TScrollBox():New(oDlg,11,01,92,160,.T.,.F.,.T.)
// Cria painel 
@ 000,000 MSPANEL oPanel OF oScr1 SIZE 200,len(aAllGroup)*10 COLOR CLR_HRED
For i:=1 to len(aAllGroup)
	cVar:="lCheck"+aAllGroup[i]
	cObj:="oCheck"+aAllGroup[i]
	&(cVar)	:= .F.
	&(cObj)	:= TCheckBox():New(nLinha,01,aAllGroup[i]+" - "+FWGrpName(aAllGroup[i]),,oPanel,100,210,,,,,,,,.T.,,,)
	&(cObj):bSetGet		:= &("{|| "+&("cVar")+"}")// Seta Eventos do Check
	&(cObj):bLClicked	:= &("{|| "+&("cVar")+":= !"+&("cVar")+"}")
	nLinha+=10
Next i

oScr2 := TScrollBox():Create(oDlg,109,01,122,160,.T.,.T.,.T.)
aItens	:= {'Sim','Nao'}
aQuebra	:= {'Mensal','Diario'}
cGetBox1:= aItens[1]
cGetBox2:= aQuebra[1]
cGet	:= space(100)
cGet1	:= STOD("        ")
cGet2	:= STOD("        ")

oSay2 := TSay():New(07,05,{|| "Salvar em? " },oScr2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,10)
oGet:= TGet():New(05,35,{|u| If(PCount()>0,cGet:=u,cGet)}, oScr2,90,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet')
oTButton2 := TButton():New(05,125, "...",oScr2,{||AbreArq(@cGet,oGet)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
oGet:Disable()

oSay3 := TSay():New(27,05,{|| "Dt. De: " },oScr2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,10)
oGet1:= TGet():New(25,35,{|u| If(PCount()>0,cGet1:=u,cGet1)}, oScr2,60,05,'@D',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')

oSay4 := TSay():New(47,05,{|| "Dt. Ate: " },oScr2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,10)
oGet2:= TGet():New(45,35,{|u| If(PCount()>0,cGet2:=u,cGet2)}, oScr2,60,05,'@D',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')

oSay5 := TSay():New(67,05,{|| "Tp. Quebra? " },oScr2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,10)
oCBox2 := tComboBox():New(065,35,{|u|if(PCount()>0,cGetBox2:=u,cGetBox2)},aQuebra,100,10,oScr2,,,,,,.T.,,,,,,,,,"cGetBox2")

//oSay6 := TSay():New(87,05,{|| "Detalhado? " },oScr2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,10)
//oCBox1 := tComboBox():New(085,35,{|u|if(PCount()>0,cGetBox1:=u,cGetBox1)},aItens,100,10,oScr2,,,,,,.T.,,,,,,,,,"cGetBox1")

oTButton1 := TButton():New( 107, 100, "Gerar",oScr2,{|| CarrBar(Len(aAllGroup),aAllGroup,cGet1,cGet2,oDlg,cGet) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

oDlg:Activate(,,,.T.)

Return
               
/*
Funcao      : CarrPlan()
Parametros  : 
Retorno     : 
Objetivos   : Função para criar a barra de processamento
*/
*-------------------------------------------------------------*
Static Function CarrBar(nTotal,aAllGroup,cGet1,cGet2,oDlg,cGet)
*-------------------------------------------------------------*
Private oDlg1
Private nMeter	:= 0
Private oMeter

Default nTotal := 100

DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL

oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg1,150,14,,.T.)
    
ACTIVATE DIALOG oDlg1 CENTERED ON INIT(Precarre(aAllGroup,DTOS(cGet1),DTOS(cGet2),oDlg,cGet))

Return .T.

/*
Funcao      : Precarre()
Parametros  : 
Retorno     : 
Objetivos   : Validação e Start das demais rotinas.
*/
*--------------------------------------------------------------*
Static Function Precarre(aAllGroup,cDtDePar,cDtAtePar,oDlg,cDir)
*--------------------------------------------------------------*
Local i
Local cOpc		:= ""
Local cEmp		:= ""
Local lRet		:= .T.

Private cDest	:= cDir
Private cArq 	:= "Faturamento.XLS"
Private nBytesSalvo := 0 
Private nHdl

Private cDtDe := cDtDePar
Private cDtAte := cDtAtePar

If EMPTY(cDtDe) .or. EMPTY(cDtAte)
	Alert("Campos datas devem ser informados!")
	oDlg1:end()
	Return
EndIf

If cDtAte < cDtDe
	Alert("'Data Ate' deve ser maior ou igual a 'Data De'!")
	oDlg1:end()
	Return
EndIf


If (STOD(cDtAte) - STOD(cDtDe)) >= 365
	Alert("Periodo Maximo Permitido é de 365 dias!")
	oDlg1:end()
	Return
EndIf

If empty(cDir)
	Alert("Informe o diretório onde os relatórios serão salvos!")
	oDlg1:end()
	Return	
EndIf

lTemMarc := .F.
For i:=1 to len(aAllGroup)
	cVar	:= "lCheck"+aAllGroup[i]
	If &(cVar)
		lTemMarc := .T.
		Exit	
	EndIf
Next i
If !lTemMarc
	Alert("Selecionar ao menos uma empresa para geração!")
	oDlg1:end()
	Return
EndIf


For i:=1 to len(aAllGroup)
	If VALTYPE(oMeter) == "O"
		oMeter:Set(i)
	EndIf
	
	cVar	:= "lCheck"+aAllGroup[i]
	If &(cVar)
		cEmp := aAllGroup[i]
	Else
		loop	
	EndIf

	cArq := "Faturamento-"+alltrim(FWGrpName(cEmp))+"-"+DTOS(Date())+".xls"
	cXml := ""
	//Gera arquivo fisico. 
	If FILE(cDest+cArq)
		FERASE (cDest+cArq)
	EndIf
	nHdl 		:= FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
	nBytesSalvo := FWRITE(nHdl, cXML ) 		// Gravação do seu Conteudo.
	fclose(nHdl) 							// Fecha o Arquivo que foi Gerado	

	aFils := FWAllFilial(,,aAllGroup[i])

	//Busca as informações do Relatorio	
	GetInfo("NUMREG",cEmp,aFils)
    
	//Monta o XML
	QRY->(DbGoTop())
	If QRY->COUNT <> 0
		WriteXML(cEmp,aFils)
	Else
		FERASE(cDest+cArq)
	EndIf
	//Fecha tabela Temporaria.
	If select("QRY")>0
		QRY->(DbCloseArea())
	Endif
Next

If lRet
	msginfo("Processo finalizado, verifique o local indicado nos parâmetros!")
	oDlg:End()
EndIf

oDlg1:end()

Return

/*
Funcao      : GetInfo()
Parametros  : 
Retorno     : 
Objetivos   : Função que executara a query na busca dos dados a serem impressos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static Function GetInfo(cTipo,cEmp,aFil)
*--------------------------------*
Local i
Local cQry := ""
Local cFil := ""

//Fecha tabela Temporaria.
If select("QRY")>0
	QRY->(DbCloseArea())
Endif

//Monta string de busca por todas as filiais.
For i:=1 to Len(aFil)
	cFil += "'"+aFil[i]+"',"
Next i
cFil := Left(cFil,Len(cFil)-1)//Retira o Ultimo caracter ','

Do Case
	Case cTipo == "NUMREG"
		cQry := "SELECT COUNT(*) AS COUNT 
		cQry +=" From SF2"+cEmp+"0 F2
		cQry +=" 		LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA
		cQry +=" WHERE F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' 
		cQry +="	AND F2.F2_SERIE <> 'ND'
		cQry +=" 	AND F2.F2_EMISSAO >= "+cDtDe
		cQry +=" 	AND F2.F2_EMISSAO <= "+cDtAte
		cQry +="	AND F2.F2_FILIAL in ("+cFil+")
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)	 

	Case cTipo == "DADOS"
		If cGetBox2 == aQuebra[1]//Quebra Mensal.
			cQry := "SELECT F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,Substring(F2.F2_EMISSAO,1,6) AS F2_EMISSAO,SUM(F2.F2_VALBRUT) AS F2_VALBRUT
			cQry +=" From SF2"+cEmp+"0 F2
			cQry +=" 		LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA
			cQry +=" WHERE F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' 
			cQry +="	AND F2.F2_SERIE <> 'ND'
			cQry +=" 	AND F2.F2_EMISSAO >= "+cDtDe
			cQry +=" 	AND F2.F2_EMISSAO <= "+cDtAte
			cQry +="	AND F2.F2_FILIAL in ("+cFil+")
			cQry +=" Group By F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,Substring(F2.F2_EMISSAO,1,6)
			cQry +=" Order By F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,Substring(F2.F2_EMISSAO,1,6)
		Else
			cQry := "SELECT F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,F2.F2_EMISSAO AS F2_EMISSAO,SUM(F2.F2_VALBRUT) AS F2_VALBRUT
			cQry +=" From SF2"+cEmp+"0 F2
			cQry +=" 		LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA
			cQry +=" WHERE F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' 
			cQry +="	AND F2.F2_SERIE <> 'ND'
			cQry +=" 	AND F2.F2_EMISSAO >= "+cDtDe
			cQry +=" 	AND F2.F2_EMISSAO <= "+cDtAte
			cQry +="	AND F2.F2_FILIAL in ("+cFil+")
			cQry +=" Group By F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,F2.F2_EMISSAO
			cQry +=" Order By F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,F2.F2_EMISSAO
		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)

		aReferencia := MontaRef()
		
		QRY->(DbGoTop())
		While QRY->(!EOF())
			If (npos:=aScan(aInfos,{ |x| x[1]==QRY->F2_CLIENTE .and. x[2]==QRY->F2_LOJA .and. x[3]==QRY->A1_NOME})) == 0
				aAdd(aInfos,Array(LEN(aReferencia)) )
				aInfos[Len(aInfos)][1] := QRY->F2_CLIENTE
				aInfos[Len(aInfos)][2] := QRY->F2_LOJA
				aInfos[Len(aInfos)][3] := QRY->A1_NOME
				aInfos[Len(aInfos)][LEN(aInfos[Len(aInfos)])] := 0//Zera Totalizador
				//Zera todos as posições.
				For i:=1 to Len(aReferencia)
					If !EMPTY(aReferencia[i])
						aInfos[Len(aInfos)][i] := 0
					EndIf
				Next i
			EndIf                               

			If (nPosData := aScan(aReferencia,{ |x| x == QRY->F2_EMISSAO})) <> 0
				aInfos[Len(aInfos)][nPosData] := QRY->F2_VALBRUT
				aInfos[Len(aInfos)][LEN(aInfos[Len(aInfos)])] += QRY->F2_VALBRUT //Total			
			EndIf
			QRY->(DbSkip())
		EndDo
EndCase

Return .T.

/*
Funcao      : WriteXML()
Parametros  : 
Retorno     : 
Objetivos   : Função que irá gerar o XML.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------*
Static Function WriteXML(cEmp,aFils)
*----------------------------------*
Local i,j
Local cXml := ""

Private aInfos := {}

cXML += WorkXML("OPEN")
cXML += DefStyle() 
cXML := GrvXML(cXML)//Limpa variavel.

For i:=1 to len(aFils)
	cXML += WorkSheet("OPEN",LEFT(aFils[i]+" - "+FWFilialName(cEmp,aFils[i],1),30) )
	cXML += TableSheet("OPEN")
	cXML += RowTable("TITULO","Faturamento "+Capital(Alltrim(FWGrpName(cEmp))))
	cXML += RowTable("TITCOLUNA")
    
    cXML := GrvXML(cXML)//Limpa variavel.

	aInfos := {}
	GetInfo("DADOS",cEmp,{aFils[i]})
	lTpLinha := .T.	
	For j:=1 to Len(aInfos)
		cXML += RowTable("DADOS",aInfos[j],lTpLinha)
		cXML := GrvXML(cXML)//Limpa variavel.
		lTpLinha := !lTpLinha
	Next j
		
	cXML += TableSheet("CLOSE")
	cXML += WorkSheet("CLOSE")
Next i

cXML += WorkXML("CLOSE")

cXML := GrvXML(cXML)//Gravação Final

Return .T.

/*
Funcao      : MarcTodo()
Parametros  : aAllGroup,lMacTd
Retorno     : 
Objetivos   : Função para marcar todas as empresas
*/
*----------------------------------------*
Static Function MarcTodo(aAllGroup,lMacTd)
*----------------------------------------*
for j:=1 to len(aAllGroup)
	&("lCheck"+aAllGroup[j]) := lMacTd
	&("oCheck"+aAllGroup[j]):Refresh()
next

Return

/*
Funcao      : AbreArq()
Parametros  : aAllGroup,lMacTd
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde será salvo
*/
*----------------------------------*
Static Function AbreArq(cGet,oGet2)
*----------------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY

//Exibe tela para gravar o arquivo.
cGet := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

oGet2:Refresh()

Return

/*
Funcao      : GrvXML()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GrvXML(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

/*
Funcao      : WorkXML()
Parametros  : cOpc
Retorno     : 
Objetivos   : Criação de uma nova estrutura de XML.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------* 
Static Function WorkXML(cOpc)
*---------------------------* 
Local cXML := "" 

If cOpc = "OPEN" 
	cXML += '  <?xml version="1.0"?>
	cXML += '  <?mso-application progid="Excel.Sheet"?>
	cXML += '  <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += '   xmlns:o="urn:schemas-microsoft-com:office:office"
	cXML += '   xmlns:x="urn:schemas-microsoft-com:office:excel"
	cXML += '   xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += '   xmlns:html="http://www.w3.org/TR/REC-html40">

ElseIf cOpc = "CLOSE" 
	cXML += ' </Workbook>  
	
EndIf

Return cXML

/*
Funcao      : DefStyle()
Parametros  : cOpc
Retorno     : 
Objetivos   : Definição dos stilos que sera utilizado no XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function DefStyle()
*----------------------------------------* 
Local cXML := "" 

cXML += '  <Styles>
cXML += '  <Style ss:ID="Default" ss:Name="Normal">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#AA92C7"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#AA92C7"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#AA92C7" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s66">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#C2C2DC"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#C2C2DC"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s67">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#C2C2DC"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#C2C2DC"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s68">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E6E6FA"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E6E6FA"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s69">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E6E6FA"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E6E6FA"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s70">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="3" ss:Color="#FFFFFF"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#333399" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += ' </Styles>

Return cXML

/*
Funcao      : WorkSheet()
Parametros  : cOpc
Retorno     : 
Objetivos   : Criação de uma novo WorkSheet.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function WorkSheet(cOpc,cNameSheet)
*----------------------------------------* 
Local cXML := "" 

Default cNameSheet := STRTRAN(TIME(),"",":")

If cOpc = "OPEN" 
	cXML += '   <Worksheet ss:Name="'+ALLTRIM(cNameSheet)+'">

ElseIf cOpc = "CLOSE" 
	cXML += '  </Worksheet>

EndIf

Return cXML

/*
Funcao      : TableSheet()
Parametros  : 
Retorno     : 
Objetivos   : Criação da Tabela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function TableSheet(cOpc)
*-----------------------------* 
Local cXML := ""

If cOpc = "OPEN" 
	cXML += '    <Table ss:ExpandedColumnCount="500" ss:ExpandedRowCount="20000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">

ElseIf cOpc = "CLOSE" 
	cXML += '   </Table>
	
EndIf

Return cXML

/*
Funcao      : RowTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação de um novo registro no excel.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------*
Static Function RowTable(cTipo,xAux1,xAux2)
*-----------------------------------*
Local i, j
Local cXML := ""        

Do Case
	Case cTipo == "TITULO"                
		aMeses := GetMes(cDtDe,cDtAte)
		cXML += '	<Row ss:AutoFitHeight="0">
		cXML += '    <Cell ss:StyleID="s70"><Data ss:Type="String">'+ALLTRIM(xAux1)+'</Data></Cell>
		cXML += '	 <Cell ss:StyleID="s70"/>
		cXML += '	 <Cell ss:StyleID="s70"/>
		If cGetBox2 == aQuebra[1]//Quebra Mensal.
			For i:=1 to Len(aMeses)
				cXML += '	 <Cell ss:StyleID="s70"/>
			Next i
		Else
			For i:=1 to len(aMeses)
				For j:=1 to aMeses[i][2]
					cXML += '	 <Cell ss:StyleID="s70"/>
				Next j
			Next i
		EndIf
		cXML += '	 <Cell ss:StyleID="s70"/>
		cXML += '   </Row>
	
	Case cTipo == "TITCOLUNA"
		If cGetBox2 == aQuebra[1]//Quebra Mensal.
			aMeses := GetMes(cDtDe,cDtAte)
			cXML += '	<Row ss:AutoFitHeight="0">
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Cliente</Data></Cell>
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cliente</Data></Cell>
			For i:=1 to len(aMeses)
				cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">'+aMeses[i][1]+'</Data></Cell>
			Next i
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Total Geral</Data></Cell>
			cXML += '   </Row>

		Else
			aMeses := GetMes(cDtDe,cDtAte)
			cXML += '	<Row ss:AutoFitHeight="0">
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cod. Cliente</Data></Cell>
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Cliente</Data></Cell>
			For i:=1 to len(aMeses)
				nQtdDias := 0
				For j:=1 to aMeses[i][2]
					If STOD(CDtDe) <= STOD(aMeses[i][3]+STRZERO(j,2)) .and. STOD(aMeses[i][3]+STRZERO(j,2)) <= STOD(CDtAte)
						nQtdDias ++
					EndIf
				Next i
				cXML += '    <Cell ss:MergeAcross="'+ALLTRIM(STR(nQtdDias-1))+'" ss:StyleID="s65"><Data ss:Type="String">'+aMeses[i][1]+'</Data></Cell>
			Next i
			cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Total Geral</Data></Cell>
			cXML += '   </Row>
            //Linha dos Dias.
			cXML += '	<Row ss:AutoFitHeight="0">
			cXML += '    <Cell ss:StyleID="s65"/>
			cXML += '    <Cell ss:StyleID="s65"/>
			cXML += '    <Cell ss:StyleID="s65"/>
			For i:=1 to len(aMeses)
				For j:=1 to aMeses[i][2]
					If STOD(CDtDe) <= STOD(aMeses[i][3]+STRZERO(j,2)) .and. STOD(aMeses[i][3]+STRZERO(j,2)) <= STOD(CDtAte)
						cXML += '    <Cell ss:StyleID="s65"><Data ss:Type="Number">'+ALLTRIM(STR(j))+'</Data></Cell>
					EndIf
				Next j
			Next i
			cXML += '    <Cell ss:StyleID="s65"/>
			cXML += '   </Row>
		EndIf

	Case cTipo == "DADOS"
		cXML += '	<Row ss:AutoFitHeight="0">
		For i:=1 to Len(xAux1)
			If VALTYPE(xAux1[i]) == "N"
				cInfo := ALLTRIM(STRTRAN(Transform(xAux1[i],"999999999999999.99"),",","."))
			Else 
				cInfo := ALLTRIM(xAux1[i])
			EndIf
			If xAux2
				cXML += '	<Cell ss:StyleID="s67"><Data ss:Type="String">'+cInfo+'</Data></Cell>
			Else 
				cXML += '	<Cell ss:StyleID="s69"><Data ss:Type="String">'+cInfo+'</Data></Cell>
			Endif
		Next i
		cXML += '   </Row>
EndCase

Return cXml

/*
Funcao      : GetMes()
Parametros  : 
Retorno     : 
Objetivos   : Retorna os nomes dos meses com base em uma data de inicio e data fim, quantidade de dias do mes e o ANo/MES
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------*
Static Function GetMes(cDtDe,cDtAte) 
*-----------------------------------*
Local i
Local aRet := {}
Local cMesDe := 0
Local cMesAte := 0

nMesDe	:= Month(STOD(cDtDe))
nMesAte := Month(STOD(cDtAte))
nYear	:= Year(STOD(cDtDe))

If nMesDe > nMesAte
	nMesAte += 12
EndIf

For i:=nMesDe to nMesAte
	If i > 12
		aAdd(aRet,{MesExtenso(i-12)+"/"+STRZERO(nYear+1,4), Last_Day(STOD(STRZERO(nYear+1,4)+STRZERO(i-12,2)+"01")),STRZERO(nYear+1,4)+STRZERO(i-12,2) })
	Else
		aAdd(aRet,{MesExtenso(i   )+"/"+STRZERO(nYear  ,4), Last_Day(STOD(STRZERO(nYear  ,4)+STRZERO(i   ,2)+"01")),STRZERO(nYear  ,4)+STRZERO(i   ,2)})
	Endif
Next i

Return aRet

/*
Funcao      : MontaRef()
Parametros  : 
Retorno     : 
Objetivos   : Retorna Um array de referencia para o aInfo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function MontaRef()          
*-------------------------*
Local i,j
Local aRet := {}
Local aMeses := GetMes(cDtDe,cDtAte) 


If cGetBox2 == aQuebra[1]//Quebra por Mes.
	aAdd(aRet,"")//Cod. Cliente
	aAdd(aRet,"")//Filial
	aAdd(aRet,"")//Cliente
	For i:=1 to Len(aMeses)
		aAdd(aRet,aMeses[i][3])
	Next i             
	aAdd(aRet,"")//Total Geral
Else
	aAdd(aRet,"")//Cod. Cliente
	aAdd(aRet,"")//Filial
	aAdd(aRet,"")//Cliente
	For i:=1 to Len(aMeses)
		For j:=1 to aMeses[i][2]
	   		If STOD(CDtDe) <= STOD(aMeses[i][3]+STRZERO(j,2)) .and. STOD(aMeses[i][3]+STRZERO(j,2)) <= STOD(CDtAte)
				aAdd(aRet,aMeses[i][3]+STRZERO(j,2) )
			EndIf
	 	Next j
	Next i             
	aAdd(aRet,"")//Total Geral
EndIf

Return aRet