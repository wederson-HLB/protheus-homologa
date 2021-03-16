#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : 33GPE003
Cliente     : GRACE
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio SRT
Autor       : Jean Victor Rocha
Data/Hora   : 12/06/2012
Revisao     :
Obs.        : 
*/  
*----------------------*
User Function 33GPE003()          
*----------------------*
Private cNome := ""
Private cAlias:= "Work"

Private cMatricula	:= ""
Private cNome		:= ""
Private nValorQuebra:= 0

AjustaSX1()
If !Pergunte("33GPE003",.T.)
	Return .T.
EndIf
  
cArqMV		:= mv_par01
lTotal		:= mv_par02 == 1
nTipoFiltro := mv_par03
nTipoInfo	:= mv_par04

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
	aStru:= {SRT->(DbStruct())}
	
	cQry += "Select RT.RT_FILIAL,RT.RT_MAT,RA.RA_NOME,RA.RA_CC,RT.RT_DATACAL,RT.RT_TIPPROV,RT.RT_VERBA,RV.RV_DESC,RT.RT_VALOR,RT.RT_DATABAS,RT.RT_DFERVEN,RT.RT_DFERPRO"
	cQry += "		,RT.RT_DFERANT,RT.RT_DFALVEN,RT.RT_DFALPRO,RT.RT_TIPMOVI,RT.RT_SALARIO,RT.RT_AVOS13S"
EndIf

cQry += "From "+RetSQLname("SRT")+" RT 	LEFT OUTER JOIN (SELECT RA_NOME, RA_MAT,RA_CC"
cQry += "						FROM "+RetSQLname("SRA")
cQry += "						WHERE D_E_L_E_T_ <> '*') AS RA ON RA.RA_MAT = RT.RT_MAT"
cQry += "				LEFT OUTER JOIN (SELECT RV_COD, RV_DESC"
cQry += "						FROM "+RetSQLname("SRV")
cQry += "						WHERE D_E_L_E_T_ <> '*') AS RV ON RV.RV_COD = RT.RT_VERBA"
cQry += "						
cQry += "Where	RT.D_E_L_E_T_ <> '*' "
cQry += "		AND RT_DATACAL = (Select MAX(RT_DATACAL) FROM "+RetSQLname("SRT")+" RT2 Where D_E_L_E_T_ = '' AND RT.RT_MAT = RT2.RT_MAT)"
If ntipoInfo == 1
	cQry += "		AND RT.RT_VERBA <> 'C01' AND RT.RT_VERBA <> 'C02' AND RT.RT_VERBA <> 'C03' AND RT.RT_VERBA <> 'C04'"
	cQry += "		AND RT.RT_VERBA <> 'C22' AND RT.RT_VERBA <> 'C27' AND RT.RT_VERBA <> 'C34' AND RT.RT_VERBA <> 'C41'"
ElseIf ntipoInfo == 2
	cQry += "		AND (RT.RT_VERBA = 'C01' OR RT.RT_VERBA = 'C02' OR RT.RT_VERBA = 'C03' OR RT.RT_VERBA = 'C04'"
	cQry += "	      OR RT.RT_VERBA = 'C22' OR RT.RT_VERBA = 'C27' OR RT.RT_VERBA = 'C34' OR RT.RT_VERBA = 'C41')"
EndIf
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

*-------------------------*
Static Function AjustaSX1()
*-------------------------*
U_PUTSX1("33GPE003","01" ,"Nome arquivo"		,"" ,"" ,"mv_ch1","C"	,20, 0 , ,"G",""		,"","","","mv_par01","","","" 							,"SRT" 			,"","",""			  			   		,"","",""	,"","","","","","",{"Nome do arquivo a ser","gerado."} 				  			  							,{},{})
U_PUTSX1("33GPE003","02" ,"Exibe total Final?","" ,"" ,"mv_ch2","N"	,01, 0 , ,"C",""		,"","","","mv_par02","Sim","Sim","Sim"					,"2"			,"Nao","Nao","Nao"				   		,"","",""	,"","","","","","",{"Informe se ao final do"  ,"Relatorio sera exibido Total."}									  						,{},{})
U_PUTSX1("33GPE003","03" ,"Agrupamento ?"		,"" ,"" ,"mv_ch3","N"	,01, 0 , ,"C",""		,"","","","mv_par03","Nenhum","Nenhum","Nenhum"			,"1"			,"Matricula","Matricula","Matricula"	,"","",""	,"","","","","","",{"Informe se havera agrupamento"  }									  						,{},{})
U_PUTSX1("33GPE003","04" ,"Tipo Rel. ?"		,"" ,"" ,"mv_ch4","N"	,01, 0 , ,"C",""		,"","","","mv_par04","Ferias","Ferias","Ferias"			,"1"			,"13º Sal.","13º Sal.","13º Sal."	,"","",""	,"","","","","","",{"Informe o tipo de informação a","ser impressa."  }									  						,{},{})
Return .t.

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
 
cArq := ALLTRIM(cArqMV)+".xls"
	
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

(cAlias)->(DbGoTop())

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>               </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
	For i:=1 to (cAlias)->(FCount())
		cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
		cMsg += "		<font face='times' color='black' size='3'> <b> "+ RETSX3((cAlias)->(Fieldname(i)), "TIT") +"</b></font>"
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
		If (cAlias)->(Fieldname(i)) == "RA_NOME" .OR. (cAlias)->(Fieldname(i)) == "RV_DESC"
			cCont := (cAlias)->(&((cAlias)->(Fieldname(i))))
		ElseIf (cAlias)->(Fieldname(i)) == "RT_TIPPROV"
			Do Case //tratamento de campo combobox.
				Case (cAlias)->(&((cAlias)->(Fieldname(i)))) == "1"
					cCont := "Fer.Venc."
				Case (cAlias)->(&((cAlias)->(Fieldname(i)))) == "2"
					cCont := "Fer.Prop."
				Case (cAlias)->(&((cAlias)->(Fieldname(i)))) == "3"
					cCont := "13o.Sal."
				Case (cAlias)->(&((cAlias)->(Fieldname(i)))) == "4"
					cCont := "14o.Sal."
                Otherwise
                	cCont := ""
			EndCase		
		ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "D"
			cCont := DtoC((cAlias)->(&((cAlias)->(Fieldname(i)))))
		ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "N"
			cCont := NumtoExcel(i)			
		ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "C"
			cCont := '=TEXTO('+ALLTRIM(STR(VAL((cAlias)->(&((cAlias)->(Fieldname(i)))))))+';"'+STRZERO(0,LEN((cAlias)->(&((cAlias)->(Fieldname(i))))))+'")'//quando for numero
		EndIf                                                                                                                          
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='3'>"+cCont
		cMsg += "			</td>"
	Next i
	cMsg += "		 </tr>"
	IF nTipoFiltro == 2 .And. nValorQuebra == 0//pega o valor do 1º registro.
		nValorQuebra 	:= (cAlias)->RT_VALOR
	EndIf
	(cAlias)->(DbSkip())
	If nTipoFiltro == 2//agrupamento por matricula
		If EMPTY(cMatricula)
			cMatricula := (cAlias)->RT_MAT
		EndIf
		If cMatricula <> (cAlias)->RT_MAT
	   		cMsg 			+=	QuebraGrupo()
			cMatricula 		:= (cAlias)->RT_MAT
			nValorQuebra 	:= (cAlias)->RT_VALOR
		Else
			nValorQuebra 	+= (cAlias)->RT_VALOR
		EndIf
		cNome	:= (cAlias)->RA_NOME 
	EndIf
	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gracação)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf
	IncProc("Reg:"+ALLTRIM(STR(k))+"/"+ALLTRIM(STR(nCount))+" - Gerando arquivo Excel...")	
	nIncTempo++
	k++
EndDo

cMsg += "	</table>"
If lTotal
	cMsg += Total()
EndIf
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

*-------------------------*
Static Function Total()              
*-------------------------*
Local nTOT1:= nTOT2:=0
Local cRet := "" 

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	nTOT1 += (cAlias)->RT_VALOR
	nTOT2 += (cAlias)->RT_SALARIO 
	(cAlias)->(DbSkip())
EndDo

cRet += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cRet += "		<tr></tr>"
cRet += "		<tr></tr>"
cRet += "		<tr>"
cRet += "			<td><font face='times' color='black' size='4'><b> Totais </b></font></td>"
cRet += "		</tr>"
cRet += "	</Table> "

(cAlias)->(DbGoTO(LastRec()))

cRet += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cRet += "		 <tr>"
For i:=1 to (cAlias)->(FCount())
	If (cAlias)->(Fieldname(i)) == "RT_VALOR"
		cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cRet += "				<font face='times' color='black' size='3'>"+NumtoExcel(nTOT1,.T.)
		cRet += "			</td>"
		i++
	ElseIf (cAlias)->(Fieldname(i)) == "RT_SALARIO"
		cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cRet += "				<font face='times' color='black' size='3'>"+NumtoExcel(nTOT2,.T.)
		cRet += "			</td>"
		i++
	EndIf
	cRet += "		<td></td>"	
Next i
cRet += "		 </tr>"
cRet += "	</Table> "

Return cRet

*-------------------------*
Static Function QuebraGrupo()              
*-------------------------*
Local cRet := "" 
Local i

cRet += "		 <tr>"
For i:=1 to (cAlias)->(FCount())
	If (cAlias)->(Fieldname(i)) == "RA_NOME"
		cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cRet += "					<td><font face='times' color='black' size='3'><b> "+cNome+" </b></font></td>"
		cRet += "			</td>"
		
	ElseIf (cAlias)->(Fieldname(i)) == "RT_VALOR"
		cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cRet += "				<font face='times' color='black' size='3'><b> "+NumtoExcel(nValorQuebra,.T.)+" </b></font></td>"
		cRet += "			</td>"
	ElseIf i <> (cAlias)->(FCount()) .and. i <> 1
		cRet += "		<td></td>"
	EndIf
Next i
cRet += "		 </tr>"

Return cRet
