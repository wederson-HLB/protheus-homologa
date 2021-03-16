#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : GTGPE002
Cliente     : Todos(uso interno)
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de dependentes.
Autor       : Jean Victor Rocha
Data/Hora   : 15/08/2012
Revisao     :
Obs.        : 
*/  
*----------------------*
User Function GTGPE002()          
*----------------------*
Private cNome := ""
Private cAlias:= "Work"

AjustaSX1()
If !Pergunte("GTGPE002",.T.)
	Return .T.
EndIf

cArqMV		:= mv_par01
cFilde		:= mv_par02//Filial De ?
cFilATE		:= mv_par03//Filial Ate ?
nOrdem		:= mv_par04//1= MAT+NOME; 2= NOME+NOME.DEP
cSitFol		:= mv_par05

GeraWork()
(cAlias)->(DbGoTop())
If (cAlias)->(EOF())
	Alert("Sem dados para impressão!","HLB BRASIL.")
	Return .t.
Else
	Processa({|| GeraXLS() })
EndIf

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

Return .t.    

//lCount = defini se ira apenar retornar a quantidade de registros encontrados.
*------------------------------*
Static Function GeraWork(lCount)
*------------------------------*
Local i, j 
Local cQry := ""
Local cCondFol := ""
Local aStru	:= {}

Default lCount := .F.

If lCount
	If Select("COUNT") > 0
		COUNT->(DbCloseArea())
	EndIf
	cQry += " select COUNT(*) as NCOUNT "

Else
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	aStru:= {SRA->(DbStruct()),SRB->(DbStruct())}

	cQry += " select RA.RA_FILIAL,RA.RA_MAT, RA.RA_NOME, RB.RB_COD,RB.RB_NOME,RB.RB_DTNASC,RB.RB_SEXO,RB.RB_GRAUPAR,RB.RB_TIPIR,RB.RB_TIPSF,RB.RB_CIC"
EndIf

cCondFol := ""
For i:=1 to Len(cSitFol)
	If (cAux := SubStr(cSitFol,i,1)) <> '*'
		If EMPTY(cCondFol)
			cCondFol += " AND ("
		Else
			cCondFol += " OR "
		EndIf
		cCondFol += " RA_SITFOLH = '"+cAux+"'"
	EndIf
Next i
If !EMPTY(cCondFol)
	cCondFol += ") "
EndIf

cQry += " from "+RetSQLname("SRB")+" RB LEFT OUTER JOIN (SELECT RA_FILIAL,RA_MAT, RA_NOME,RA_SITFOLH"
cQry += " 												FROM "+RetSQLname("SRA")
cQry += " 												WHERE D_E_L_E_T_ <> '*' "+cCondFol+") AS RA ON RA.RA_MAT = RB.RB_MAT AND RA.RA_FILIAL = RB.RB_FILIAL"
cQry += " Where RB.D_E_L_E_T_ <> '*' "

If !EMPTY(cFilde)
	cQry += " AND RA.RA_FILIAL >= '"+cFilde+"'"
EndIf
If !EMPTY(cFilAte)
	cQry += " AND RA.RA_FILIAL <= '"+cFilate+"'"
EndIf

If !lCount
	cQry += " Order by RA.RA_FILIAL"
	If nOrdem == 1
		cQry += " ,RA.RA_MAT,RA.RA_NOME"
	ElseIf nOrdem == 1
		cQry += " ,RA.RA_NOME,RB.RB_NOME"
	EndIf

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

U_PUTSX1("GTGPE002","01" ,"Nome arquivo","" ,"" ,"mv_ch1","C"	,20, 0 , ,"G",""		,""   ,"","","mv_par01","","","" 						 ,"dependentes"	,"","",""			  			   		,"","",""	,"","","","","","",{"Nome do arquivo a ser","gerado."} 				  		,{},{})
U_PUTSX1("GTGPE002","02" ,"Filial De ?" ,"" ,"" ,"mv_ch2","C"	,02, 0 , ,"G",""		,"XM0","","","mv_par02","","","","01"			,"","",""	,"","",""	,"","","","","","",{"Informe filial inicial","campo não obrigatorio"  }	,{},{})
U_PUTSX1("GTGPE002","03" ,"Filial Ate ?","" ,"" ,"mv_ch3","C"	,02, 0 , ,"G",""		,"XM0","","","mv_par03","","","","01"			,"","",""	,"","",""	,"","","","","","",{"Informe filial Final","campo não obrigatorio"  }	,{},{})
U_PUTSX1("GTGPE002","04" ,"Ordem ?"	  ,"" ,"" ,"mv_ch4","N"	,01, 0 , ,"C",""	    ,""   ,"","","mv_par04","1=MAT+NOME.COL","1=MAT+NOME.COL","1=MAT+NOME.COL","1","2=NOME.COL.+NOME.DEP","2=NOME.COL.+NOME.DEP","2=NOME.COL.+NOME.DEP"	,"","",""	,"","","","","","",{"Informe a ordem do relatorio","1=Matricula + Nome Colaborador","2=Nome Colaborador + Nome Dependente"  }	,{},{})
U_PUTSX1("GTGPE002","05" ,"Sit.Folha ?" ,"" ,"" ,"mv_ch5","C"	,05, 0 , ,"G","fSituacao",""   ,"","","mv_par05","","","","","","",""	,"","",""	,"","","","","","",{"Informe ou selecione a situação dos","funcionarios para filtro dos dados.",""  }	,{},{})

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

nHdl 		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado	

cHtml := Montaxls()

If nBytesSalvo <= 0	// Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl)	// Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	sleep(8000)
	SHELLEXECUTE("open",(cDest+cArq),"","",5)// Gera o arquivo em Excel
endif
          
//FErase(cDest+cArq)

Return .T.    

*-------------------------*
Static Function Montaxls()
*-------------------------*
Local cTitulo	:= "Relatorio de Dependentes"
Local cMsg 		:= ""
Local i,j  

(cAlias)->(DbGoTop())
cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>"+cTitulo+"</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
	cMsg += "		<td width='200' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Filial </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Matricula </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='600' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Colaborador </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Seq.Dep. </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='600' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Dependente </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Dt.Nasc. </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Sexo </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Grau Parent. </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Tipo Dep.IR </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Tipo Dep.SF </b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> CPF. </b></font>"
	cMsg += "		</td>"				
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

ProcRegua(nCount:=GeraWork(.T.))
k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	cMsg += "		 <tr>"
	cMsg += "			 <td width='200' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+'=TEXTO('+ALLTRIM(STR(VAL((cAlias)->RA_FILIAL)))+';"'+STRZERO(0,LEN((cAlias)->RA_FILIAL))+'")'
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+'=TEXTO('+ALLTRIM(STR(VAL((cAlias)->RA_MAT)))+';"'+STRZERO(0,LEN((cAlias)->RA_MAT))+'")'
	cMsg += "			</td>"
	cMsg += "			 <td width='600' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RA_NOME
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+'=TEXTO('+ALLTRIM(STR(VAL((cAlias)->RB_COD)))+';"'+STRZERO(0,LEN((cAlias)->RB_COD))+'")'
	cMsg += "			</td>"
	cMsg += "			 <td width='600' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RB_NOME
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+DtoC((cAlias)->RB_DTNASC)
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RB_SEXO
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		IF UPPER((cAlias)->RB_GRAUPAR) == "C"
			cMsg += "				<font face='times' color='black' size='3'> C=Conjuge"
		ElseIf UPPER((cAlias)->RB_GRAUPAR) == "F"
			cMsg += "				<font face='times' color='black' size='3'> F=Filho"
		ElseIf UPPER((cAlias)->RB_GRAUPAR) == "E"
			cMsg += "				<font face='times' color='black' size='3'> E=Enteado"
		ElseIf UPPER((cAlias)->RB_GRAUPAR) == "P"
			cMsg += "				<font face='times' color='black' size='3'> P=Pai/Mãe"
		ElseIf UPPER((cAlias)->RB_GRAUPAR) == "O"
			cMsg += "				<font face='times' color='black' size='3'> O=Outros"	
		EndIf		
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		IF UPPER((cAlias)->RB_TIPIR) == "1"
			cMsg += "				<font face='times' color='black' size='3'> S/ Lim.Idade"
		ElseIf UPPER((cAlias)->RB_TIPIR) == "2"
			cMsg += "				<font face='times' color='black' size='3'> Até 21 anos."
		ElseIf UPPER((cAlias)->RB_TIPIR) == "3"
			cMsg += "				<font face='times' color='black' size='3'> Até 24 anos"
		Else
			cMsg += "				<font face='times' color='black' size='3'> Não é dep."		
		EndIf
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		IF UPPER((cAlias)->RB_TIPSF) == "1"
			cMsg += "				<font face='times' color='black' size='3'> S/ Lim.Idade"
		ElseIf UPPER((cAlias)->RB_TIPSF) == "2"
			cMsg += "				<font face='times' color='black' size='3'> Até 14 anos."
		Else
			cMsg += "				<font face='times' color='black' size='3'> Não é dep."		
		EndIf
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RB_CIC
	cMsg += "			</td>"
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
