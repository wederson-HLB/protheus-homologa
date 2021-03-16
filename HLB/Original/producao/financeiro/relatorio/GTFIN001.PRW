#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : GTFIN001
Cliente     : 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de Contas a Pagar por Ambiente.
Autor       : Jean Victor Rocha
Data/Hora   : 15/03/2012
Revisao     :
Obs.        : 
*/
*----------------------*
User Function GTFIN001()
*----------------------* 

Private cEmpresa:= ""  
        
        /*   
		cEmpresa := "/HM/FN/GB/GC/1C/U2/3I/BF/K2/2C/GR/JO/NE/HV/IW/FQ/RG/TK/GV/3Q/MR/SI"//Renata Deroldo/Thiago
		cEmpresa += "/NH/DQ/GN/2G/HN/KI/KA/XJ/SO/IX/XP/XS/FK/E8/UN/VE/WA/62/CY/13/R9"//Edineia/Angela   
		// Edineia - RRP - 16/05/2013 - Inclusão de empresas, chamado 012009.
		// Edineia - RRP - 28/05/2013 - Inclusão de empresas, chamado 012464.
		// Edineia - RRP - 13/06/2013 - Inclusão de empresas, chamado 012819.
		cEmpresa += "/5F/JZ/PF/JY/H8/TX/9F/4Y/5L/ZJ/0A/4V/40/JL/PB/9B/TN/TR/TP/TM/9I/JX/TQ/JM/ZH/2N/VL/VK/ZD/UW/1K/MX/H1/4R/ZO/V4/PY"
		cEmpresa += "/H9/TF/3T/GT/HI/2A/I7/3Z/CM/DO/2Y/BD/LN/42/1F/EE/2V/SK/VH/SL/SW/HE/2Z/45/57/L3"//Luciana/Izabelle
		cEmpresa += "/VN/AY/QS/LF/DX/XG/HS/60/HU/HP/ID/KC/LI/S4/B8/73/PA/FB/JE/IZ/3Y/HK/XR/VC/OS/ER/FB/XC"//Wanessa/Lucimar
		cEmpresa += "/4B/78/I2/I1/FM/2X/IF/3X/3W/GX/RT/UI/KY/3S/D6/79/80/I3"//Marlene
		cEmpresa += "/RW/2O/D5/B0/X0/CZ/6H/KO/38/2S/ZE/F4/NP/JU/3R/RS/E5/R2/L2/1D/KS/VT/94"//Selma/Tatiane
		cEmpresa += "/46/49"//Joel/Iara 
		cEmpresa += "/99"//TESTE
		//Solicitação Thiago, chamado 006013
		cEmpresa += "/Y7/YA/YB/Y1/3D/YP/Y2/YL/3M/YE/YG/YS/YC/Y3/Y0/Y5/YM/YO/1J/1G/1H"
		cEmpresa += "/UM/UZ/9X/9N/VW/DP/4N/9C/G0/XL/67/2U/XU/XM"//21-11-2013 - Solicitação Edimeia, chamado 015409  */
	 
	//TLM - 20140812 - CHAMADO 020680		
		     
	
	If Select("EMP") > 0

 		EMP->(DbCloseArea())	               

   	EndIf  
    
    BeginSql Alias 'EMP'
    
		SELECT   		
			 M0_CODIGO AS [EMPRESA]	
		FROM
			SIGAMAT
		WHERE
			D_E_L_E_T_<>'*'
		GROUP BY
			M0_CODIGO
								
	EndSql 		
		        
	EMP->(DbGoTop())
	While EMP->(!EOF())		
		                  
		cEmpresa+=EMP->EMPRESA+"/" 
		
		EMP->(DbSkip())	 
				
	EndDo		
                     


Return Processa({|| GTFIN() })
 
*----------------------*
Static Function GTFIN()          
*----------------------*
Local i
Local aOrd := {} 
Local cEmpr:= ""
Private cNome := ""
Private cAlias:= "Work"
Private cAliasWork := "DET"
Private aRetCrw    := {}
Private aCampos := {}

AjustaSX1()
If !Pergunte("GTFIN001",.T.)
	Return .T.
EndIf

dInicial	:= mv_par01
dFinal		:= mv_par02   
lExcel		:= mv_par03==1

//MSM - 10/11/2016 - Readequação da estrutura do array para tratar o campo customizado E2_P_NUMFL
aCampos:= {}
AADD(aCampos,{"M0_CODIGO"	,"C"	,2	,0	})
AADD(aCampos,{"M0_NOME"		,"C"	,30	,0	})
AADD(aCampos,{"E2_FILIAL"	,GTSX3("E2_FILIAL","TIP")	,GTSX3("E2_FILIAL","TAM")	,GTSX3("E2_FILIAL","DEC")	})
AADD(aCampos,{"E2_EMIS1"	,GTSX3("E2_EMIS1","TIP")	,GTSX3("E2_EMIS1","TAM")	,GTSX3("E2_EMIS1","DEC")	})
AADD(aCampos,{"E2_PREFIXO"	,GTSX3("E2_PREFIXO","TIP")	,GTSX3("E2_PREFIXO","TAM")	,GTSX3("E2_PREFIXO","DEC")	})
AADD(aCampos,{"E2_NUM"		,GTSX3("E2_NUM","TIP")		,GTSX3("E2_NUM","TAM") 		,GTSX3("E2_NUM","DEC")		})
AADD(aCampos,{"E2_PARCELA"	,GTSX3("E2_PARCELA","TIP")	,GTSX3("E2_PARCELA","TAM")	,GTSX3("E2_PARCELA","DEC")	})
AADD(aCampos,{"E2_FORNECE"	,GTSX3("E2_FORNECE","TIP")	,GTSX3("E2_FORNECE","TAM")	,GTSX3("E2_FORNECE","DEC")	})
AADD(aCampos,{"E2_NOMFOR"	,GTSX3("E2_NOMFOR","TIP")	,GTSX3("E2_NOMFOR","TAM")	,GTSX3("E2_NOMFOR","DEC")	})
AADD(aCampos,{"E2_TIPO"		,GTSX3("E2_TIPO","TIP")		,GTSX3("E2_TIPO","TAM")		,GTSX3("E2_TIPO","DEC")		})
AADD(aCampos,{"E2_NATUREZ"	,GTSX3("E2_NATUREZ","TIP")	,GTSX3("E2_NATUREZ","TAM")	,GTSX3("E2_NATUREZ","DEC")	})
AADD(aCampos,{"E2_EMISSAO"	,GTSX3("E2_EMISSAO","TIP")	,GTSX3("E2_EMISSAO","TAM")	,GTSX3("E2_EMISSAO","DEC")	})
AADD(aCampos,{"E2_VENCTO"	,GTSX3("E2_VENCTO","TIP")	,GTSX3("E2_VENCTO","TAM")	,GTSX3("E2_VENCTO","DEC")	})
AADD(aCampos,{"E2_VALOR"	,GTSX3("E2_VALOR","TIP")	,GTSX3("E2_VALOR","TAM")	,GTSX3("E2_VALOR","DEC")	})
AADD(aCampos,{"E2_ISS"  	,GTSX3("E2_ISS","TIP") 		,GTSX3("E2_ISS","TAM")		,GTSX3("E2_ISS","DEC")		})
AADD(aCampos,{"E2_IRRF"		,GTSX3("E2_IRRF","TIP")		,GTSX3("E2_IRRF","TAM")		,GTSX3("E2_IRRF","DEC")		})
AADD(aCampos,{"E2_BAIXA"	,GTSX3("E2_BAIXA","TIP")	,GTSX3("E2_BAIXA","TAM")	,GTSX3("E2_BAIXA","DEC")	})
AADD(aCampos,{"E2_SALDO"	,GTSX3("E2_SALDO","TIP")	,GTSX3("E2_SALDO","TAM")	,GTSX3("E2_SALDO","DEC")	})
AADD(aCampos,{"E2_VALLIQ"	,GTSX3("E2_VALLIQ","TIP")	,GTSX3("E2_VALLIQ","TAM")	,GTSX3("E2_VALLIQ","DEC")	})
AADD(aCampos,{"E2_NUMBOR"	,GTSX3("E2_NUMBOR","TIP")	,GTSX3("E2_NUMBOR","TAM")	,GTSX3("E2_NUMBOR","DEC")	})
if SE2->(FieldPos("E2_P_NUMFL")) > 0
	AADD(aCampos,{"E2_P_NUMFL"	,GTSX3("E2_P_NUMFL","TIP")	,GTSX3("E2_P_NUMFL","TAM")	,GTSX3("E2_P_NUMFL","DEC")	})
endif

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf

cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

aOrd := SaveOrd({"SM0"})

ProcRegua(SM0->(RECCOUNT()))
SM0->(DbSetOrder(1))
SM0->(DbGoTop())
While SM0->(!EOF())
	If	cEmpr <> SM0->M0_CODIGO .and.;//Verifica se ja não foi feito a query para a empresa(filiais diferentes.)
		SM0->M0_CODIGO $ cEmpresa .and.;//Verifica se faz parte da carteira de clientes.
		TCCANOPEN("SE2"+SM0->M0_CODIGO+"0")//verifica se existe a tabela no Banco.

		cEmpr := SM0->M0_CODIGO
		if GeraQry(SM0->M0_CODIGO)
			Carrega()
		endif
	EndIf
	IncProc("Buscando dados...")
	SM0->(DbSkip())
EndDo
RestOrd(aOrd)

If (cAliasWork)->(EOF()) .and. (cAliasWork)->(BOF())
	MsgInfo("Não foram encontrados dados para esta seleção!")
	Return .F.
EndIf

oReport := ReportDef()
oReport:PrintDialog()
CrwCloseFile(aRetCrw,.T.)

If lExcel
	GeraXLS()
EndIf

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

Return .t.    

*-------------------------------*
Static Function GeraQry(cEmpresa)
*-------------------------------*
Local j 
Local cQry	:= ""
Local aStru	:= {}
local cCampos := ""

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

aStru:= SE2->(DbStruct())

cCampos += " E2_FILIAL,E2_EMIS1,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_FORNECE,E2_NOMFOR,E2_TIPO,E2_NATUREZ,"
cCampos += " E2_EMISSAO,E2_VENCTO,E2_VALOR,E2_ISS,E2_IRRF,E2_BAIXA,"
cCampos += " E2_SALDO,E2_VALLIQ,E2_NUMBOR"

//AOA - 24/11/2016 - Busca campo customizado na estrutura, caso não encontre não leva para o relatório.
If !AScan(aStru,{|x| x[1] == "E2_P_NUMFL"}) == 0
	cCampos += " ,E2_P_NUMFL"
EndIf

cQry := "SELECT " + cCampos
cQry += " FROM SE2"+cEmpresa+"0"
cQry += " WHERE D_E_L_E_T_ <> '*' and E2_SALDO <> '0'"

If !Empty(dInicial)
	cQry +=" AND E2_VENCTO >='"+DTOS(dInicial)+"'"
EndIf
If !Empty(dFinal)
	cQry +=" AND E2_VENCTO <='"+DTOS(dFinal)+"'"
EndIf 
//MSM - 10/10/2016 - Tratamento para verificar se não apresentará erro na Query, devido ao novo campo E2_P_NUMFL
if TcSqlExec(cQry)>=0

	DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAlias,.F.,.T.)
	
	For j := 1 To Len(aStru)
		If aStru[j][2] <> "C" .and.  FieldPos(aStru[j][1]) > 0
			TcSetField(cAlias,aStru[j][1],aStru[j][2],aStru[j][3],aStru[j][4])
		EndIf
	Next j
	
else
	Return .F.
endif

Return .T.

*-----------------------*
Static Function Carrega()
*-----------------------*
Local nCont := 0
(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	(cAliasWork)->(RecLock(cAliasWork,.T.))           
	nCont:=0
	For i:= 1 to (cAliasWork)->(Fcount())
		If (cAliasWork)->(FieldName(i)) == "M0_CODIGO" .or. (cAliasWork)->(FieldName(i)) == "M0_NOME"
			nCont ++
			If (cAliasWork)->(FieldName(i)) == "M0_CODIGO"
				(cAliasWork)->&((cAliasWork)->(FieldName(i))):= SM0->M0_CODIGO
			Else
				(cAliasWork)->&((cAliasWork)->(FieldName(i))):= SM0->M0_NOME
			EndIf
		Else
			(cAliasWork)->&((cAliasWork)->(FieldName(i))):= (cAlias)->&((cAlias)->(FieldName(i-nCont)))
		EndIf
	Next i
	(cAliasWork)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo


Return .t.

***************************
Static Function ReportDef()
***************************
Local i
local cTitRpt := "Relação de Títulos do Contas a Pagar em aberto."
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"DET"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("Consolidado", cTitRpt ,""         , {|oReport| ReportPrint(oReport)}, cTitRpt)

//Inicia o relatório como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait  := .F.

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)
	
//Definição das colunas de impressão da seção 1
DbSelectArea(cAliasWork)
For i:= 1 to (cAliasWork)->(Fcount())
	If FieldName(i) == "M0_CODIGO" .or. FieldName(i) == "M0_NOME"
		If FieldName(i) == "M0_NOME"
			TRCell():New(oSecao1, (cAliasWork)->(FieldName(i)), "DET", "Nome Empresa", "", 20, /*lPixel*/, /*{|| code-block de impressao }*/)
		EndIf
	ElseIF (cAliasWork)->(FieldName(i)) <> "E2_ISS" .and. (cAliasWork)->(FieldName(i)) <> "E2_IRRF"  .and. (cAliasWork)->(FieldName(i)) <> "E2_CORREC"
		TRCell():New(oSecao1, FieldName(i), "DET", GTSX3(FieldName(i),"TIT"), GTSX3(FieldName(i),"PIC"), GTSX3(FieldName(i),"TAM"), /*lPixel*/, /*{|| code-block de impressao }*/)
	EndIf
Next i

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
U_PUTSX1("GTFIN001","01" ,"Data Inicial"	,"" ,"" ,"mv_ch1","D",08, 0 , ,"G",""	,"","","","mv_par01","","","" 			,"01/01/2012"	,"","",""		  ,"","",""	,"","","","","","",{"Inserir a data Inicial","de vencimento do titulo."},{},{})
U_PUTSX1("GTFIN001","02" ,"Data Final"	,"" ,"" ,"mv_ch2","D",08, 0 , ,"G",""	,"","","","mv_par02","","",""	 		,"01/01/2013"	,"","",""		  ,"","",""	,"","","","","","",{"Inserir a data Final"  ,"dos titulos."}   			,{},{})
U_PUTSX1("GTFIN001","03" ,"Exporta Excel?","" ,"" ,"mv_ch3","N",01, 0 , ,"C",""	,"","","","mv_par03","Sim","Sim","Sim"	,"2"			,"Nao","Nao","Nao","","",""	,"","","","","","",{"Exportar o Relatorio"  ,"para excel."}				,{},{})
Return .t.

*------------------------------------*
Static Function GTSX3(cCampo, cFuncao)
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
		Case cFuncao == "TIT" 
			xRet := SX3->X3_TITULO
	EndCase
EndIf
RestOrd(aOrd)
Return xRet    

*-------------------------*
Static Function GeraXLS()
*-------------------------* 
Local nHdl
Local cHtml		:= ""
Private cDest	:=  GetTempPath()
Private cArq	:= "Consolidado_"+DTOS(date())+".xls"
Private nBytesSalvo:=0
	
IF FILE(cDest+cArq)
	FERASE(cDest+cArq)
ENDIF

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

Montaxls()
	
If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
          
FErase(cDest+cArq)

Return .T.    

*------------------------------*
Static Function GrvTempXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

*----------------------------*
Static Function Montaxls(cOpc)
*----------------------------*
Local cMsg := ""
Local i, j 
Local lChar := .F. 

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td colspan='2'>Relatorio emitido em:</td><td colspan='3'>"+Dtoc(DATE())+" - "+TIME()+"</td>"
cMsg += "		<tr></tr><tr>"
cMsg += "			<td colspan='10' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> Relação de Títulos do Contas a Pagar em aberto. </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"

cMsg := GrvTempXLS(cMsg) //Grava e limpa memoria da variavel.

cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
For i:=2 to len(aCampos)//Considera inicio no 2 para nao exibir o Codigo da empresa
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	If aCampos[i][1] == "M0_CODIGO" .or. aCampos[i][1] == "M0_NOME"
		If aCampos[i][1] == "M0_CODIGO
			cMsg += "				 <font face='times' color='black' size='3'> <b> Cod.Empresa </b></font>"	
		Else
			cMsg += "				 <font face='times' color='black' size='3'> <b> Nome Empresa </b></font>"
		EndIf
	Else
		cMsg += "				 <font face='times' color='black' size='3'> <b> "+GTSX3(aCampos[i][1],"TIT")+" </b></font>"
	EndIf
	cMsg += "			 </td>"
Next i
cMsg += "		 </tr>"

cMsg := GrvTempXLS(cMsg) //Grava e limpa memoria da variavel.

ProcRegua((cAliasWork)->(RecCount()))
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	cMsg += "		 <tr>"
	For i:=2 to (cAliasWork)->(FCount())//Considera inicio no 2 para nao exibir o Codigo da empresa
		If ValType((cAliasWork)->(&((cAliasWork)->(Fieldname(i))))) == "D"
			cCont := DtoC((cAliasWork)->(&((cAliasWork)->(Fieldname(i)))))
		ElseIf ValType((cAliasWork)->(&((cAliasWork)->(Fieldname(i))))) == "N"
			cCont := NumtoExcel(i)			
		Else
			cCont := ALLTRIM((cAliasWork)->(&((cAliasWork)->(Fieldname(i)))))
			lChar := .F.
			For j:=1 to len(cCont)
				If !(ASC( SUBSTR(cCont,j,1) ) >= 48 .and. ASC( SUBSTR(cCont,j,1) ) <= 57)
					lChar := .T.
					Exit
				EndIf
			Next j
			If lChar .or. len(cCont) == 0 .or. (cAliasWork)->(Fieldname(i)) == "E2_NATUREZ"
				cCont := (cAliasWork)->(&((cAliasWork)->(Fieldname(i))))
			Else
				cCont := '=TEXTO('+ALLTRIM(STR(VAL((cAliasWork)->(&((cAliasWork)->(Fieldname(i)))))))+';"'+STRZERO(0,LEN(ALLTRIM((cAliasWork)->(&((cAliasWork)->(Fieldname(i)))))))+'")'
			EndIf
		EndIf
		cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='3'>"+cCont
		cMsg += "			</td>"
	Next i
	cMsg += "		 </tr>"                                  

	cMsg := GrvTempXLS(cMsg) //Grava e limpa memoria da variavel.

	IncProc("Montando estrutura dos itens para excel...")
	(cAliasWork)->(DbSkip())
EndDo  

cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "

cMsg := GrvTempXLS(cMsg) //Grava e limpa memoria da variavel.

Return cMsg

//Foi criada esta função para adequação dos valores na a forma em que o excel entende.
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
