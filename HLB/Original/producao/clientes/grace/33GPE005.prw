#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : 33GPE005
Cliente     : GRACE
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio Bco Micellis
Autor       : Jean Victor Rocha
Data/Hora   : 06/07/2012
Revisao     :
Obs.        : 
*/  
*----------------------*
User Function 33GPE005()          
*----------------------*
Private cNome := ""
Private cAlias:= "Work"

GeraWork()
Processa({|| GeraXLS() })

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

Return .t.    

*------------------------*
Static Function GeraWork(lCount)
*------------------------*
Local i, j 
Local cQry := ""
Local aStru	:= {}

Default lCount := .F.

If lCount
	If Select("COUNT") > 0
		COUNT->(DbCloseArea())
	EndIf
	cQry += "select COUNT(*) as NCOUNT "

Else
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	aStru:= {SRA->(DbStruct())}
	
	cQry += "SELECT RA.RA_FILIAL, RA.RA_MAT, RA.RA_NOME,RA.RA_CIC, RA.RA_CC, CTT_DESC01,RA.RA_RG, RA.RA_SEXO, "
	cQry += "		RA.RA_ESTCIVI, RA.RA_NASC, RA.RA_ADMISSA, "
	cQry += "		CASE WHEN R8.X5_DESCRI IS NULL  THEN 'NORMAL' ELSE R8.X5_DESCRI END AS X5_DESCRI, "
	cQry += "		RA.RA_CODFUNC, RJ.RJ_DESC "
EndIf

cQry += " From "+RetSQLname("SRA")+" RA"
cQry += " 	LEFT OUTER JOIN (SELECT CTT_CUSTO, CTT_DESC01"
cQry += " 						FROM "+RetSQLname("CTT")
cQry += " 						WHERE D_E_L_E_T_ <> '*') AS CTT ON CTT.CTT_CUSTO = RA.RA_CC"
cQry += " 	LEFT OUTER JOIN (SELECT RJ_FUNCAO, RJ_DESC"
cQry += " 						FROM "+RetSQLname("SRJ")
cQry += " 						WHERE D_E_L_E_T_ <> '*') AS RJ ON RJ.RJ_FUNCAO = RA.RA_CODFUNC"
cQry += " 	LEFT OUTER JOIN (SELECT R8_MAT, X5.X5_DESCRI AS X5_DESCRI"
cQry += " 						FROM "+RetSQLname("SR8")+" LEFT OUTER JOIN (SELECT X5_TABELA,X5_CHAVE, X5_DESCRI"
cQry += " 												   					FROM "+RetSQLname("SX5")
cQry += " 												   					WHERE D_E_L_E_T_ <> '*' AND"
cQry += " 												   						  X5_TABELA = '30') AS X5 ON X5.X5_CHAVE = R8_TIPO"
cQry += " 						WHERE D_E_L_E_T_ <> '*' AND"
cQry += " 						convert(varchar(12),getdate(),112) >= R8_DATAINI AND"
cQry += " 						convert(varchar(12),getdate(),112) <= R8_DATAFIM) AS R8 ON R8.R8_MAT = RA.RA_MAT"
cQry += " Where RA.D_E_L_E_T_ <> '*' AND RA_DEMISSA = ''"

If !lCount
	cQry += "Order By RA.RA_NOME"

	DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAlias,.F.,.T.)

	For i := 1 To Len(aStru)
		For j := 1 To Len(aStru[i])
			If aStru[i][j][2] <> "C" .and.  FieldPos(aStru[i][j][1]) > 0
				TcSetField(cAlias,aStru[i][j][1],aStru[i][j][2],aStru[i][j][3],aStru[i][j][4])
			EndIf
		Next j
	Next i
	xret := .T.
Else
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),"COUNT",.F.,.T.)
	xRet := COUNT->NCOUNT
	COUNT->(DbCloseArea())
EndIf

Return xRet

*------------------------------------*
Static Function RETSX3(cCampo, cFuncao)
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
Local cHtml := ""
Private cDest :=  GetTempPath()
 
cArq := "BCO_MICELLIS.xls"
	
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado	

cHtml := Montaxls()

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
          
//FErase(cDest+cArq)

Return .T.    

*-------------------------*
Static Function Montaxls()
*-------------------------*
Local cMsg := ""
Local i,j  

Local cCorCell 			:= "#6600CC'"
Local cLetra   			:= "White"

(cAlias)->(DbGoTop())

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='3'><b> BCO Micelli</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
	For i:=1 to (cAlias)->(FCount())
		cMsg += "		<td width='500' height='41' bgcolor='"+cCorCell+"' border='2' bordercolor='#000000' align = 'Left'>"
		cMsg += "		<font face='times' color='"+cLetra+"' size='2'> <b> "+ RETSX3((cAlias)->(Fieldname(i)), "TIT") +"</b></font>"
		cMsg += "		</td>"
	Next i
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

ProcRegua(nCount:=GeraWork(.T.))//apenas carrega variavel com o numero de registros.
k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	cMsg += "		 <tr>"
	For i:=1 to (cAlias)->(FCount((cAlias)->(&((cAlias)->(Fieldname(i))))))
	   	If ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "C"
			cCont := (cAlias)->(&((cAlias)->(Fieldname(i))))
		ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "D"
			cCont := DtoC((cAlias)->(&((cAlias)->(Fieldname(i)))))
		ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "N"
			cCont := NumtoExcel(i)			
		EndIf                                                                                                                          
		cMsg += "			 <td width='500' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+cCont
		cMsg += "			</td>"
	Next i
	cMsg += "		 </tr>"
	(cAlias)->(DbSkip())

	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gracação)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf
	IncProc("Reg:"+ALLTRIM(STR(k))+"/"+ALLTRIM(STR(nCount))+" - Gerando arquivo Excel...")	
	nIncTempo++
	k++
EndDo

cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "
cMsg := GrvXLS(cMsg)

Return cMsg

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

//Foi criada esta função para adequação dos valore para a forma que o excel entende.
//Permitindo nao apenas a visualização para o usuario mas tambem a edição do conteudo.
*----------------------------------*
Static Function NumtoExcel(i,lValor)
*----------------------------------*
Local cRet		:= ""
Local nValor	:= 0
Default lValor	:= .F.
If lValor
	nValor := i
Else
	nValor := (cAlias)->(&((cAlias)->(Fieldname(i))))
EndIf
If RIGHT(TRANSFORM(nValor, "@R 99999999999.99"),2) == "00"
	cRet := ALLTRIM(STR(nValor))
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.99"),1) == "0"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-2)+","+RIGHT(ALLTRIM(STR(nValor)),1)
Else
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-3)+","+RIGHT(ALLTRIM(STR(nValor)),2)
EndIf
Return cRet