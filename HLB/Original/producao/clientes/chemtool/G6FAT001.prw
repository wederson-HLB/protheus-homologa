#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : G6FAT001
Cliente     : CHEMTOOL
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de Comissoes geradas a partir do faturamento
Autor       : Jean Victor Rocha
Data/Hora   : 06/03/2012
Revisao     :
Obs.        : 
*/  
*----------------------*
User Function G6FAT001()          
*----------------------*
Private cNome := ""
Private cAlias:= "Work"
Private cAliasWork := "DET"
Private aRetCrw    := {}

AjustaSX1()
If !Pergunte("G6FAT001",.T.)
	Return .T.
EndIf

dInicial	:= mv_par01
dFinal		:= mv_par02   
nTipoFiltro := mv_par03
lExcel		:= mv_par04==1

GeraWork()
Imprime()

If lExcel
	GeraXLS()
EndIf

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

Return .t.    

*------------------------*
Static Function GeraWork()
*------------------------*
Local i, j 
Local cQry	:= ""
Local aStru	:= {}
local cCampo := ""
Local nPorcComiss := 0.15

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

aStru:= {SE1->(DbStruct()),SF2->(DbStruct())}

cQry := "SELECT E1.E1_CLIENTE,E1.E1_BAIXA,F2.F2_DOC,E1.E1_VLCRUZ,F2.F2_VALICM,F2.F2_ICMSRET,F2.F2_VALIPI,F2.F2_VALIMP5,"
cQry += " 		F2.F2_VALIMP6"
cQry += " FROM "+RetSqlName("SE1")+" E1"
cQry += "  LEFT JOIN "+RetSqlName("SF2")+" F2"
cQry += "  ON F2.F2_DUPL=E1.E1_NUM AND F2.F2_PREFIXO=E1.E1_PREFIXO AND F2.F2_CLIENTE+F2.F2_LOJA=E1.E1_CLIENTE+E1.E1_LOJA"
cQry += " WHERE E1.D_E_L_E_T_ <> '*' AND E1.E1_TIPO = 'NF' AND E1.E1_ORIGEM = 'MATA460'"

DbSelectArea("SF2")
If SF2->(FieldPos(" F2_P_SCODE")) <> 0
	cQry+=" AND F2.F2_P_SCODE <> ''"
EndIf     

If nTipoFiltro == 1    
	cQry+= " AND E1.E1_BAIXA = ''"
ElseIf nTipoFiltro == 2      
	If !Empty(dInicial)
		cQry+=" AND E1.E1_BAIXA >='"+DTOS(dInicial)+"'"
	EndIf
	If !Empty(dFinal)
		cQry+=" AND E1.E1_BAIXA <='"+DTOS(dFinal)+"'"
	EndIf 
	cQry+=" AND E1.E1_BAIXA <> ''"	
	cQry+=" AND E1.E1_NUM+E1_PREFIXO+E1.E1_CLIENTE+E1.E1_LOJA not in(Select E1_VIEW.E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA"
	cQry+=" 														 from "+RetSqlName("SE1")+" E1_VIEW"
	cQry+=" 														 where E1_VIEW.D_E_L_E_T_ <> '*' AND E1_VIEW.E1_BAIXA = '' AND E1_VIEW.E1_NUM=F2.F2_DUPL)"
EndIf

DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAlias,.F.,.T.)

For i := 1 To Len(aStru)
	For j := 1 To Len(aStru[i])
		If aStru[i][j][2] <> "C" .and.  FieldPos(aStru[i][j][1]) > 0
			TcSetField(cAlias,aStru[i][j][1],aStru[i][j][2],aStru[i][j][3],aStru[i][j][4])
		EndIf
	Next j
Next i

Return .t.

*-----------------------*
Static Function Imprime()
*-----------------------*
Local cIndex1 := ""
Local cIndex2 := ""
Local cIndex3 := ""

aCampos:= {	{"E1_CLIENTE"	,G6SX3("E1_CLIENTE","TIP")	,G6SX3("E1_CLIENTE","TAM")	,G6SX3("E1_CLIENTE","DEC")	} ,;//"Costumer Service"
			{"E1_BAIXA"		,G6SX3("E1_BAIXA","TIP")	,G6SX3("E1_BAIXA","TAM")	,G6SX3("E1_BAIXA","DEC")	} ,;//"Received Date"
			{"F2_DOC"		,G6SX3("F2_DOC","TIP")		,G6SX3("F2_DOC","TAM")		,G6SX3("F2_DOC","DEC")		} ,;//"Invoice Number"
			{"E1_VLCRUZ"	,G6SX3("E1_VLCRUZ","TIP")	,G6SX3("E1_VLCRUZ","TAM")	,G6SX3("E1_VLCRUZ","DEC")	} ,;//"Gross Sales in BRL"
			{"F2_VALICM"	,G6SX3("F2_VALICM","TIP")	,G6SX3("F2_VALICM","TAM")	,G6SX3("F2_VALICM","DEC")	} ,;//"ICMS"
			{"F2_ICMSRET"	,G6SX3("F2_ICMSRET","TIP")	,G6SX3("F2_ICMSRET","TAM")	,G6SX3("F2_ICMSRET","DEC")	} ,;//"ICMS Retido"
			{"F2_VALIPI"	,G6SX3("F2_VALIPI","TIP")	,G6SX3("F2_VALIPI","TAM")	,G6SX3("F2_VALIPI","DEC")	} ,;//"IPI"
			{"F2_VALIMP5"	,G6SX3("F2_VALIMP5","TIP")	,G6SX3("F2_VALIMP5","TAM")	,G6SX3("F2_VALIMP5","DEC")	} ,;//"PIS/COFINS"F2_VALIMP5=COFINS, F2_VALIMP6=PIS
			{"F2_VALIMP6"	,G6SX3("F2_VALIMP6","TIP")	,G6SX3("F2_VALIMP6","TAM")	,G6SX3("F2_VALIMP6","DEC")	} ,;//"PIS/COFINS"F2_VALIMP5=COFINS, F2_VALIMP6=PIS			
			{"E1_VALOR"		,G6SX3("E1_VALOR","TIP")	,G6SX3("E1_VALOR","TAM")	,G6SX3("E1_VALOR","DEC")	} ,;//"Net Sales"
			{"COMISSAO"		,G6SX3("E1_VALOR","TIP")	,G6SX3("E1_VALOR","TAM")	,G6SX3("E1_VALOR","DEC")	}}  //"Commission 15% of Net Sales"

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf

cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	(cAliasWork)->(RecLock(cAliasWork,.T.))
	(cAliasWork)->E1_CLIENTE:= (cAlias)->E1_CLIENTE
	(cAliasWork)->E1_BAIXA 	:= (cAlias)->E1_BAIXA
	(cAliasWork)->F2_DOC  	:= (cAlias)->F2_DOC
	(cAliasWork)->E1_VLCRUZ := (cAlias)->E1_VLCRUZ
	(cAliasWork)->F2_VALICM := (cAlias)->F2_VALICM
	(cAliasWork)->F2_ICMSRET:= (cAlias)->F2_ICMSRET
	(cAliasWork)->F2_VALIPI := (cAlias)->F2_VALIPI
	(cAliasWork)->F2_VALIMP5:= (cAlias)->F2_VALIMP5
	(cAliasWork)->F2_VALIMP6:= (cAlias)->F2_VALIMP6
	//(cAliasWork)->E1_VALOR	:= (cAlias)->E1_VALOR
	(cAliasWork)->E1_VALOR	:= (cAlias)->E1_VLCRUZ - (cAlias)->(F2_VALICM+F2_ICMSRET+F2_VALIPI+F2_VALIMP5+F2_VALIMP6)
	(cAliasWork)->COMISSAO 	:= (cAliasWork)->E1_VALOR * 0.15
	(cAliasWork)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo

IndRegua(cAliasWork,cNome+OrdBagExt(),"E1_CLIENTE")
cNome1 := E_Create(nil,.F.)
IndRegua(cAliasWork,cNome1+OrdBagExt(),"F2_DOC")
SET INDEX TO (cNome+OrdBagExt()),(cNome1+OrdBagExt())

oReport := ReportDef()
oReport:PrintDialog()
CrwCloseFile(aRetCrw,.T.)
Return .t.

***************************
Static Function ReportDef()
***************************
local cTitRpt := "Relatorio de Comissões"
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"DET"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {"E1_CLIENTE",;
		     "F2_DOC"}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("G6FAT001", cTitRpt ,""         , {|oReport| ReportPrint(oReport)}, cTitRpt)

//Inicia o relatório como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait  := .F.

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"E1_CLIENTE"	,"DET","Costumer Service"			 	,/*Picture*/               	,G6SX3("E1_CLIENTE", "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"E1_BAIXA"		,"DET","Received Date"				 	,G6SX3("E1_BAIXA"  , "PIC")	,G6SX3("E1_BAIXA"  , "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"F2_DOC"		,"DET","Invoice Number"			 		,G6SX3("F2_DOC"    , "PIC")	,G6SX3("F2_DOC"    , "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"E1_VLCRUZ"	,"DET","Gross Sales in BRL"		 		,G6SX3("E1_VLCRUZ" , "PIC")	,G6SX3("E1_VLCRUZ" , "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"F2_VALICM"	,"DET","ICMS"				 			,G6SX3("F2_VALICM" , "PIC")	,G6SX3("F2_VALICM" , "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"F2_ICMSRET"	,"DET","ICMS ST"			 			,G6SX3("F2_ICMSRET", "PIC")	,G6SX3("F2_ICMSRET", "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"F2_VALIPI"	,"DET","IPI"					 		,G6SX3("F2_VALIPI" , "PIC")	,G6SX3("F2_VALIPI" , "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"F2_VALIMP6"	,"DET","Pis"				 			,G6SX3("F2_VALIMP6", "PIC")	,G6SX3("F2_VALIMP6", "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"F2_VALIMP5"	,"DET","Cofins"				 	 		,G6SX3("F2_VALIMP5", "PIC")	,G6SX3("F2_VALIMP5", "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"E1_VALOR"		,"DET","Net Sales"				 		,G6SX3("E1_VALOR", "PIC")	,G6SX3("E1_VALOR", "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"COMISSAO"		,"DET","Commission 15% of Net Sales"	,G6SX3("COMISSAO"  , "PIC")	,G6SX3("COMISSAO"  , "TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Total:")
oTotal:= TRFunction():New(oSecao1:Cell("E1_VLCRUZ") ,NIL,"SUM",/*oBreak*/,"",G6SX3("E1_VLCRUZ" , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("F2_VALICM") ,NIL,"SUM",/*oBreak*/,"",G6SX3("F2_VALICM" , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("F2_ICMSRET"),NIL,"SUM",/*oBreak*/,"",G6SX3("F2_ICMSRET", "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("F2_VALIPI") ,NIL,"SUM",/*oBreak*/,"",G6SX3("F2_VALIPI" , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("F2_VALIMP6"),NIL,"SUM",/*oBreak*/,"",G6SX3("F2_VALIMP6", "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("F2_VALIMP5"),NIL,"SUM",/*oBreak*/,"",G6SX3("F2_VALIMP5", "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("E1_VALOR")  ,NIL,"SUM",/*oBreak*/,"",G6SX3("E1_VALOR"  , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("COMISSAO")  ,NIL,"SUM",/*oBreak*/,"",G6SX3("E1_VALOR"  , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:SetTotalInLine(.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Seção 1")

oReport:SetMeter(DET->(RecCount()))
//Inicio da impressão da seção 1.
oReport:Section("Seção 1"):Init()

//Laço principal
DET->(DbSetOrder(oReport:NORDER))
DET->(dbGoTop())
Do While DET->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Seção 1"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   DET->( dbSkip() )
EndDo
//Fim da impressão da seção 1
oReport:Section("Seção 1"):Finish()

Return .T.

*-------------------------*
Static Function AjustaSX1()
*-------------------------*
U_PUTSX1("G6FAT001","01" ,"Data Inicial"		,"" ,"" ,"mv_ch1","D"	,08, 0 , ,"G",""		,"","","","mv_par01","","","" 							,"01/01/2012"	,"","",""			  			   		,"","",""	,"","","","","","",{"Inserir a data Inicial","dos titulos."} 				  			  							,{},{})
U_PUTSX1("G6FAT001","02" ,"Data Final"		,"" ,"" ,"mv_ch2","D"	,08, 0 , ,"G",""		,"","","","mv_par02","","",""	 						,"01/01/2013"	,"","",""			  			   		,"","",""	,"","","","","","",{"Inserir a data Final"  ,"dos titulos."}   								  						,{},{})
U_PUTSX1("G6FAT001","03" ,"Tipo de titulo?"	,"" ,"" ,"mv_ch3","N"	,01, 0 , ,"C",""		,"","","","mv_par03","Em aberto","Em aberto","Em aberto","2"			,"Liquidado","Liquidado","Liquidado"	,"","",""	,"","","","","","",{"Seleciona o tipo de impressão"  ,"por status do titulo."},{},{})
U_PUTSX1("G6FAT001","04" ,"Exporta Excel?"  	,"" ,"" ,"mv_ch4","N"	,01, 0 , ,"C",""		,"","","","mv_par04","Sim","Sim","Sim"					,"2"			,"Nao","Nao","Nao"				   		,"","",""	,"","","","","","",{"Exportar o Relatorio"  ,"para excel."}									  						,{},{})
Return .t.

*------------------------------------*
Static Function G6SX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
	EndCase
EndIf
RestOrd(aOrd)
Return xRet    

*-------------------------*
Static Function GeraXLS()
*-------------------------*
Local nHdl
Local cHtml := ""
Private cDest :=  GetTempPath()
 
cHtml := Montaxls()
cArq := "Commissions.xls"
	
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
	
If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
          
FErase(cDest+cArq)

Return .T.    

*-------------------------*
Static Function Montaxls()
*-------------------------*
Local cMsg := ""
Local i  

cMsg += "<html>"
cMsg += "	<body>"

cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<tr></tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> Commission </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"

cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Costumer Service </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Received Date       </b></font>"
cMsg += "			 </td>			 "
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Invoice Number  </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Gross Sales in BRL           </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> ICMS </b></font>"
cMsg += "			</td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> IPI </b></font>"
cMsg += "			</td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Pis </b></font>"
cMsg += "			</td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Cofins </b></font>"
cMsg += "			</td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Net Sales </b></font>"
cMsg += "			</td>"
cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'><b> Commission 15% of Net Sales </b></font>"
cMsg += "			</td>"
cMsg += "		 </tr>"

(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	cMsg += "		 <tr>"
	For i:=1 to (cAliasWork)->(FCount())
		If ValType((cAliasWork)->(&((cAliasWork)->(Fieldname(i))))) == "D"
			cCont := DtoC((cAliasWork)->(&((cAliasWork)->(Fieldname(i)))))
		ElseIf ValType((cAliasWork)->(&((cAliasWork)->(Fieldname(i))))) == "N"
			cCont := NumtoExcel(i)			
		Else
			cCont := '=TEXTO('+ALLTRIM(STR(VAL((cAliasWork)->(&((cAliasWork)->(Fieldname(i)))))))+';"'+STRZERO(0,LEN((cAliasWork)->(&((cAliasWork)->(Fieldname(i))))))+'")'
		EndIf
		cMsg += "			 <td width='100' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='3'>"+cCont
		cMsg += "			</td>"
	Next i
	cMsg += "		 </tr>"
	(cAliasWork)->(DbSkip())
EndDo  
cMsg += "	</table>"

cMsg += Total()

cMsg += "	<BR?>"
cMsg += "</html> "

Return cMsg

//Foi criada esta função para adequação dos valore para a forma que o excel entende.
//Permitindo nao apenas a visualização para o usuario mas tambem a edição do conteudo.
*----------------------------*
Static Function NumtoExcel(i)
*----------------------------*
Local cRet := ""
Local nValor := 0
nValor:= (cAliasWork)->(&((cAliasWork)->(Fieldname(i))))
If RIGHT(TRANSFORM(nValor, "@R 99999999999.99"),2) == "00"
	cRet := ALLTRIM(STR(nValor))
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.99"),1) == "0"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-2)+","+RIGHT(ALLTRIM(STR(nValor)),1)
Else
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-3)+","+RIGHT(ALLTRIM(STR(nValor)),2)
EndIf
Return cRet

*-------------------------*
Static Function Total()              
*-------------------------*
Local nTOT1 := nTOT2 := nTOT3 := nTOT4 :=0
Local nTOT5 := nTOT6 := nTOT7 := 0
Local cRet := "" 

(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	nTOT1 += (cAliasWork)->E1_VLCRUZ 
	nTOT2 += (cAliasWork)->F2_VALICM 
	nTOT3 += (cAliasWork)->F2_ICMSRET
	nTOT4 += (cAliasWork)->F2_VALIPI 
	nTOT5 += (cAliasWork)->F2_VALIMP6 
	nTOT6 += (cAliasWork)->F2_VALIMP5
	nTOT7 += (cAliasWork)->E1_VALOR
	nTOT8 += (cAliasWork)->COMISSAO * 0.15
	(cAliasWork)->(DbSkip())
EndDo

(cAliasWork)->(DbAppend())
(cAliasWork)->E1_VLCRUZ := nTOT1
(cAliasWork)->F2_VALICM := nTOT2
(cAliasWork)->F2_ICMSRET:= nTOT3
(cAliasWork)->F2_VALIPI := nTOT4
(cAliasWork)->F2_VALIMP6:= nTOT5
(cAliasWork)->F2_VALIMP5:= nTOT6
(cAliasWork)->E1_VALOR  := nTOT7
(cAliasWork)->COMISSAO 	:= nTOT8
(cAliasWork)->(MsUnLock())

cRet += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cRet += "		<tr></tr>"
cRet += "		<tr></tr>"
cRet += "		<tr>"
cRet += "			<td><font face='times' color='black' size='4'><b> Totais </b></font></td>"
cRet += "		</tr>"
cRet += "	</Table> "

(cAliasWork)->(DbGoTO(LastRec()))

cRet += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cRet += "		 <tr>"
For i:=1 to (cAliasWork)->(FCount())
	cCont := ""
	If ValType((cAliasWork)->(&((cAliasWork)->(Fieldname(i))))) == "N"
		cCont := NumtoExcel(i)
	EndIf
	cRet += "			 <td width='100' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cRet += "				<font face='times' color='black' size='3'>"+cCont
	cRet += "			</td>"
Next i
cRet += "		 </tr>"
cRet += "	</Table> "

Return cRet
