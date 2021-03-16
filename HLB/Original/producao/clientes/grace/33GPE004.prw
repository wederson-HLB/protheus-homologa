#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : 33GPE004
Cliente     : GRACE
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio baseado na SRC
Autor       : Jean Victor Rocha
Data/Hora   : 14/06/2012
Revisao     :
Obs.        : 
*/  
*----------------------*
User Function 33GPE004()          
*----------------------*
Private cNome := ""
Private cAlias:= "Work"

Private cMatricula	:= ""
Private cNome		:= ""
Private nValorQuebra:= 0

AjustaSX1()
If !Pergunte("33GPE004",.T.)
	Return .T.
EndIf
  
cArqMV		:= mv_par01
nTipoRel	:= mv_par02
 

//TRATAMENTO PARA GARANTIR A HOMOLOGAÇÃO DE TODOS.APOS APROVADO....RETIRAR>>..........................................................................
If ntipoRel == 3
	ALERT("Tipo de relatorio ainda não homologado para utilização!")
	Return .F.
EndIf
//....................................................................................................................................................

GeraWork()
Processa({|| GeraXLS() })

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
Local aStru	:= {}    
Local cData:= "'"+Alltrim(GetMv("MV_FOLMES"))+"%'"

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
	aStru:= {SRC->(DbStruct())}
	
	cQry += " Select	RC.RC_FILIAL,RC.RC_MAT,RA.RA_NOME,RC.RC_PD,RV.RV_DESC,RC.RC_HORAS,RC.RC_VALOR,"
	cQry += "		RC.RC_DATA,RC.RC_SEMANA,RA.RA_CC,RC.RC_PARCELA,RC.RC_TIPO2,RC.RC_SEQ"
EndIf

cQry += " From "+RetSQLname("SRC")+" RC LEFT OUTER JOIN (SELECT RA_NOME, RA_MAT,RA_CC,RA_FILIAL"
cQry += "								FROM "+RetSQLname("SRA")
//cQry += "								WHERE D_E_L_E_T_ <> '*' AND RA_DEMISSA = '') AS RA ON RA.RA_MAT = RC.RC_MAT AND RA.RA_FILIAL = RC.RC_FILIAL"  //JSS - 25/06/2014 - Foi adicionao o campo AND RA_DEMISSA = '' para identificar os casos duplicados devido transferencias. 
cQry += "								WHERE D_E_L_E_T_ <> '*' ) AS RA ON RA.RA_MAT = RC.RC_MAT AND RA.RA_FILIAL = RC.RC_FILIAL"  //TLM - 27/08/2014 - Retirado RA_DEMISSA
cQry += "				LEFT OUTER JOIN (SELECT RV_COD, RV_DESC"
cQry += "								FROM "+RetSQLname("SRV")
cQry += "								WHERE D_E_L_E_T_ <> '*') AS RV ON RV.RV_COD = RC.RC_PD"
cQry += " Where D_E_L_E_T_ <> '*' AND RC_DATA like "+cData   // TLM 27/08/2014 - Adicionado parametro da folha atual

If nTipoRel == 2
	cQry += " AND ( RC.RC_PD = '007' OR RC.RC_PD =  '07' OR RC.RC_PD =   '7' OR "
	cQry +=	" 		RC.RC_PD = '010' OR RC.RC_PD =  '10' OR RC.RC_PD = '161' OR RC.RC_PD = '163' OR RC.RC_PD = '197' OR "
	cQry +=	" 		RC.RC_PD = '198' OR RC.RC_PD = '392' OR RC.RC_PD = '396'  "
	cQry +=	" 	   )"
ElseIf nTipoRel > 2
  	cQry += " AND ( RC.RC_PD = '007' OR RC.RC_PD =  '07' OR RC.RC_PD =   '7' OR RC.RC_PD = '009' OR RC.RC_PD =  '09' OR RC.RC_PD =   '9' OR "
	cQry +=	" 		RC.RC_PD = '010' OR RC.RC_PD =  '10' OR RC.RC_PD = '161' OR RC.RC_PD = '163' OR RC.RC_PD = '190' OR RC.RC_PD = '197' OR "
	cQry +=	" 		RC.RC_PD = '198' OR RC.RC_PD = '233' OR RC.RC_PD = '292' OR RC.RC_PD = '396' OR RC.RC_PD = '651' OR RC.RC_PD = '652' OR "
	cQry +=	" 		RC.RC_PD = '700' )"
EndIf
If nTipoRel == 4
	cQry +=	" AND ( RA.RA_CC = '5040406' OR RA.RA_CC = '5040422')"
Endif

If !lCount
	If nTipoRel == 1 .or. nTipoRel == 3
		cQry += "Order By RA.RA_NOME"
	Else
		cQry += "Order By RA.RA_CC,RA.RA_NOME"
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
U_PUTSX1("33GPE004","01" ,"Nome arquivo"		,"" ,"" ,"mv_ch1","C"	,20, 0 , ,"G",""		,"","","","mv_par01","","","" 							,"SRC" 			,"","",""			  			   		,"","",""	,"","","","","","",{"Nome do arquivo a ser","gerado."} 				  			  							,{},{})
U_PUTSX1("33GPE004","02" ,"Tipo Rel. ?"		,"" ,"" ,"mv_ch2","N"	,01, 0 , ,"C",""		,"","","","mv_par02","SRC","SRC","SRC"		        	,"1"			,"EHS","EHS","EHS"	,"Ver.2","Ver.2","Ver.2"	,"Manutenção","Manutenção","Manutenção","","","",{"Informe o tipo de formação do Relatorio","de relação de horas a ser impresso."  }									  						,{},{})

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

//Verificação de qual layout sera utilizado
If ntipoRel == 1
	cHtml := Montaxls_1()
ElseIf ntipoRel == 2     
	cHtml := Montaxls_2()
ElseIf ntipoRel == 3     
	cHtml := Montaxls_3()
ElseIf ntipoRel == 4     
	cHtml := Montaxls_4()
EndIf

If nBytesSalvo <= 0	// Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl)	// Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)// Gera o arquivo em Excel
endif
          
//FErase(cDest+cArq)

Return .T.    

//SRC sem formatação e ou filtro.
*-------------------------*
Static Function Montaxls_1()
*-------------------------*
Local cTitulo	:= "SRC"
Local cMsg 		:= ""
Local i,j  

(cAlias)->(DbGoTop())
cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>"+cTitulo+"</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
For i:=1 to (cAlias)->(FCount())
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> "+ RETSX3((cAlias)->(Fieldname(i)), "TIT") +"</b></font>"
	cMsg += "		</td>"
Next i
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

ProcRegua(nCount:=GeraWork(.T.))
k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	cMsg += "		 <tr>"
	For i:=1 to (cAlias)->(FCount((cAlias)->(&((cAlias)->(Fieldname(i))))))
		If (cAlias)->(Fieldname(i)) == "RA_NOME" .OR. (cAlias)->(Fieldname(i)) == "RV_DESC"
			cCont := (cAlias)->(&((cAlias)->(Fieldname(i))))
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
cMsg += Total()
cMsg += "	<BR?>"
cMsg += "</html> "
cMsg := GrvXLS(cMsg)

Return cMsg

//Relação de Horas EHS.
*-------------------------*
Static Function Montaxls_2()
*-------------------------*
Local cTitulo			:= "Relação de Horas EHS"
Local cCorCell 			:= "#6600CC'"
Local cLetra   			:= "White"
Local cMsg 				:= ""

Private cCentro 		:= ""
Private cDescrCC 		:= ""
Private nValorQuebra 	:= 0

(cAlias)->(DbGoTop())
cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>"+cTitulo+"</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_MAT", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='800' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RA_NOME", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ "C.R." +"</b></font>"
cMsg += "		</td>"				
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_HORAS", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ "OBS" +"</b></font>"
cMsg += "		</td>"
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

ProcRegua(nCount:=GeraWork(.T.))
k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
If (cAlias)->(!EOF())
	cMat  	:= (cAlias)->RC_MAT
	cNome 	:= (cAlias)->RA_NOME
	nHoras	:= 0
	cObs	:= ""
	CTT->(DbSetOrder(1))
	CTT->(DbSeek(xFilial("CTT")+(cAlias)->RA_CC))
	cCr 	:= ALLTRIM((cAlias)->RA_CC)+" - "+ ALLTRIM(CTT->CTT_DESC01)

	SR8->(DbSetOrder(1))
	If SR8->(DbSeek(xFilial("SR8")+ALLTRIM((cAlias)->RC_MAT)))
		While SR8->(!EOF()) .and. ALLTRIM((cAlias)->RC_MAT) == SR8->R8_MAT
			If DATE() >= SR8->R8_DATAINI .and. DATE() <= SR8->R8_DATAFIM
				SX5->(DbSetOrder(1))
				If SX5->(DbSeek(xFilial("SX5")+'30'+SR8->R8_TIPO))
					cObs := SX5->X5_DESCRI
				Else
					cObs := SR8->R8_TIPO
				EndIf
			EndIf
			SR8->(DbSkip())
		EndDo		
	EndIf
EndIf

While (cAlias)->(!EOF())

	If cMat == (cAlias)->RC_MAT
   		If (cAlias)->RC_PD == "010"
	   		nHoras +=  ROUND((cAlias)->RC_HORAS*7.3333,2)
   		Else
	   		nHoras += ROUND((cAlias)->RC_HORAS,2)
   		EndIf
	Else
		cMsg += "		 <tr>"
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+'=TEXTO('+ALLTRIM(STR(VAL(cMat)))+';"'+STRZERO(0,LEN(cMat))+'")'
		cMsg += "			</td>"
		cMsg += "			 <td width='800' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+cNome
		cMsg += "			</td>"
		cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+cCr
		cMsg += "			</td>"
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'> ="+NumtoExcel(nHoras,.T.)
		cMsg += "			</td>"
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='red' size='2'>"+cObs
		cMsg += "			</td>"
		cMsg += "		 </tr>"
		If EMPTY(cCentro)
			cCentro := (cAlias)->RA_CC
			cDescrCC := ALLTRIM(CTT->CTT_DESC01)
		EndIf
		If cCentro <> (cAlias)->RA_CC
	   	    nValorQuebra    += nHoras
	   		cMsg 			+= Quebra_2()
			cCentro 		:= (cAlias)->RA_CC       
			CTT->(DbSetOrder(1))
			CTT->(DbSeek(xFilial("CTT")+(cAlias)->RA_CC))
			cDescrCC := ALLTRIM(CTT->CTT_DESC01)
			nValorQuebra 	:= 0
		Else
			nValorQuebra 	+= nHoras
		EndIf			

		cMat  	:= (cAlias)->RC_MAT
		cNome 	:= (cAlias)->RA_NOME
	   	If (cAlias)->RC_PD == "010"
	   		nHoras := ROUND((cAlias)->RC_HORAS*7.3333,2)
   		Else
	   		nHoras := ROUND((cAlias)->RC_HORAS,2)
   		EndIf
		cObs 	:= ""
		CTT->(DbSetOrder(1))
		CTT->(DbSeek(xFilial("CTT")+(cAlias)->RA_CC))
		cCr 	:= ALLTRIM((cAlias)->RA_CC)+" - "+ ALLTRIM(CTT->CTT_DESC01)
		SR8->(DbSetOrder(1))
		If SR8->(DbSeek(xFilial("SR8")+ALLTRIM((cAlias)->RC_MAT)))
			While SR8->(!EOF()) .and. ALLTRIM((cAlias)->RC_MAT) == SR8->R8_MAT
				If DATE() >= SR8->R8_DATAINI .and. DATE() <= SR8->R8_DATAFIM
					SX5->(DbSetOrder(1))
					If SX5->(DbSeek(xFilial("SX5")+'30'+SR8->R8_TIPO))
						cObs := SX5->X5_DESCRI
					Else
						cObs := SR8->R8_TIPO
					EndIf
				EndIf
				SR8->(DbSkip())
			EndDo		
		EndIf
		EndIf
	(cAlias)->(DbSkip())  
			                            
//cMat  	:= (cAlias)->RC_MAT
//cNome 	:= (cAlias)->RA_NOME			

	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gravação)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf
	nIncTempo++
	k++ 	
	IncProc("Reg:"+ALLTRIM(STR(k))+"/"+ALLTRIM(STR(nCount))+" - Gerando arquivo Excel...")	

EndDo	       

//JSS - Foi necessário repetir o boco do While, pois não estava imprimindo a ultima linha do Select. Chamado: 013167.
	If cMat == (cAlias)->RC_MAT
   		If (cAlias)->RC_PD == "010"
	   		nHoras +=  ROUND((cAlias)->RC_HORAS*7.3333,2)
   		Else
	   		nHoras += ROUND((cAlias)->RC_HORAS,2)
   		EndIf
	Else
		cMsg += "		 <tr>"
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+'=TEXTO('+ALLTRIM(STR(VAL(cMat)))+';"'+STRZERO(0,LEN(cMat))+'")'
		cMsg += "			</td>"
		cMsg += "			 <td width='800' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+cNome
		cMsg += "			</td>"
		cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'>"+cCr
		cMsg += "			</td>"
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='2'> ="+NumtoExcel(nHoras,.T.)
		cMsg += "			</td>"
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='red' size='2'>"+cObs
		cMsg += "			</td>"
		cMsg += "		 </tr>"
		If EMPTY(cCentro)
			cCentro := (cAlias)->RA_CC
			cDescrCC := ALLTRIM(CTT->CTT_DESC01)
		EndIf
		If cCentro <> (cAlias)->RA_CC
	   	    nValorQuebra    += nHoras
	   		cMsg 			+= Quebra_2()
			cCentro 		:= (cAlias)->RA_CC       
			CTT->(DbSetOrder(1))
			CTT->(DbSeek(xFilial("CTT")+(cAlias)->RA_CC))
			cDescrCC := ALLTRIM(CTT->CTT_DESC01)
			nValorQuebra 	:= 0
		Else
			nValorQuebra 	+= nHoras
		EndIf			

		cMat  	:= (cAlias)->RC_MAT
		cNome 	:= (cAlias)->RA_NOME
	   	If (cAlias)->RC_PD == "010"
	   		nHoras := ROUND((cAlias)->RC_HORAS*7.3333,2)
   		Else
	   		nHoras := ROUND((cAlias)->RC_HORAS,2)
   		EndIf
		cObs 	:= ""
		SR8->(DbSetOrder(1))
		If SR8->(DbSeek(xFilial("SR8")+ALLTRIM((cAlias)->RC_MAT)))
			While SR8->(!EOF()) .and. ALLTRIM((cAlias)->RC_MAT) == SR8->R8_MAT
				If DATE() >= SR8->R8_DATAINI .and. DATE() <= SR8->R8_DATAFIM
					SX5->(DbSetOrder(1))
					If SX5->(DbSeek(xFilial("SX5")+'30'+SR8->R8_TIPO))
						cObs := SX5->X5_DESCRI
					Else
						cObs := SR8->R8_TIPO
					EndIf
				EndIf
				SR8->(DbSkip())
			EndDo		
		EndIf
		EndIf                                                                                   ,
	cMsg := GrvXLS(cMsg)
//JSS-FIM-	
 		
cMsg += "	</table>"
cMsg += "	<BR?>"  
cMsg += "</html> "
cMsg := GrvXLS(cMsg)

Return cMsg
  
//Relação de horas Ver.2
*-------------------------*
Static Function Montaxls_3()
*-------------------------*
Local cTitulo			:= "Relação de horas"
Local cCorCell 			:= "#6600CC'"
Local cLetra   			:= "White"
Local cMsg 				:= ""

Private cMat 			:= ""
Private cDescr 			:= ""
Private nValorQuebra 	:= 0

(cAlias)->(DbGoTop())
cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>"+cTitulo+"</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_FILIAL", "TIT") +" </b></font>"
cMsg += "		</td>"
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_MAT", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+RETSX3("RA_CC", "TIT") +"</b></font>"
cMsg += "		</td>"				
cMsg += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RA_NOME", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_PD", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RV_DESC", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_TIPO2", "TIT") +"</b></font>"
cMsg += "		</td>"
cMsg += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cMsg += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_HORAS", "TIT") +"</b></font>"
cMsg += "		</td>"                  
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

ProcRegua(nCount:=GeraWork(.T.))//apenas carrega variavel com o numero de registros.
k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())

	If EMPTY(cMat)
		cMat := (cAlias)->RC_MAT
	EndIf           
	If cMat <> (cAlias)->RC_MAT
		cMsg +=	Quebra_3()
		nValorQuebra := 0
		cDescr := ""
	EndIf

	SRC->(DbSetOrder(1))
	SRC->(DbSeek(xFilial("SRC")+(cAlias)->RC_MAT+(cAlias)->RC_PD+(cAlias)->RA_CC))

	cMsg += "		 <tr>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='2'>"+(cAlias)->RC_FILIAL
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='2'>"+(cAlias)->RC_MAT
	cMsg += "			</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='2'>"+(cAlias)->RA_CC
	cMsg += "			</td>"
	cMsg += "	  		<td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "	  			<font face='times' color='black' size='2'>"+(cAlias)->RA_NOME
	cMsg += "	  		</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='2'>"+(cAlias)->RC_PD
	cMsg += "			</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='2'>"+(cAlias)->RV_DESC
	cMsg += "			</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='2'>"+IF(SRC->RC_TIPO1=="V","Valor","Horas")
	cMsg += "			</td>"				
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	If (cAlias)->RC_PD == "010"
		cMsg += "				<font face='times' color='black' size='3'> ="+NumtoExcel(ROUND((cAlias)->RC_HORAS*7.3333,2),.T.)
	Else
		cMsg += "				<font face='times' color='black' size='3'> ="+NumtoExcel(ROUND((cAlias)->RC_HORAS,2),.T.)
	EndIf
	cMsg += "			</td>"
	cMsg += "		 </tr>"
	nValorQuebra+= ROUND((cAlias)->RC_HORAS,4)
	cDescr 		:= (cAlias)->RA_CC + " Total"
	
	(cAlias)->(DbSkip())
	
	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gravação)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf
	nIncTempo++
	k++
	IncProc("Reg:"+ALLTRIM(STR(k))+"/"+ALLTRIM(STR(nCount))+" - Gerando arquivo Excel...")	
EndDo
cMsg += "	</table>"
cMsg += "	<BR?>"  
cMsg += "</html> "
cMsg := GrvXLS(cMsg)

Return cMsg

//Relação de horas Manutenção.
*-------------------------*
Static Function Montaxls_4()
*-------------------------*
Local cTitulo	:= "Relação de Horas Manutenção"
Local cMsg 		:= ""

Private cCC 	:= ""

(cAlias)->(DbGoTop())
cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>"+cTitulo+"</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"

cMsg := GrvXLS(cMsg)

ProcRegua(nCount:=GeraWork(.T.))
k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	If EMPTY(cCC)
		cCC := (cAlias)->RA_CC
		cMsg +=	Quebra_4()
	EndIf           
	If cCC <> (cAlias)->RA_CC
		cMsg += "		 <tr></tr>		 <tr></tr>"
		cMsg +=	Quebra_4()
		cCC := (cAlias)->RA_CC
	EndIf

	cMsg += "		 <tr>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RC_FILIAL
	cMsg += "			</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RA_CC
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RC_MAT
	cMsg += "			</td>"
	cMsg += "	  		<td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "	  			<font face='times' color='black' size='3'>"+(cAlias)->RA_NOME
	cMsg += "	  		</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RC_PD
	cMsg += "			</td>"
	cMsg += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				<font face='times' color='black' size='3'>"+(cAlias)->RV_DESC
	cMsg += "			</td>"
	cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
	If (cAlias)->RC_PD == "010"
		cMsg += "				<font face='times' color='black' size='3'> ="+NumtoExcel(ROUND((cAlias)->RC_HORAS*7.3333,2),.T.)
	Else
		cMsg += "				<font face='times' color='black' size='3'> ="+NumtoExcel(ROUND((cAlias)->RC_HORAS,2),.T.)
	EndIf
	cMsg += "			</td>"
	cMsg += "		 </tr>"
	(cAlias)->(DbSkip())
	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gravação)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf
	nIncTempo++
	k++
	IncProc("Reg:"+ALLTRIM(STR(k))+"/"+ALLTRIM(STR(nCount))+" - Gerando arquivo Excel...")	
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

//Altera para formato excel.
//Maximo 4 casas decimais.
*----------------------------------*
Static Function NumtoExcel(nValor,lValor)
*----------------------------------*
Local cRet		:= ""

Default lValor	:= .F.
Default nValor	:= 0  

If !lValor
	nValor := (cAlias)->(&((cAlias)->(Fieldname(nValor))))
EndIf

nValor := ROUND(nValor,4)

If RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),4) == "0000"
	cRet := ALLTRIM(STR(nValor))
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),3) == "000"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-2)+","+RIGHT(ALLTRIM(STR(nValor)),1)
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),2) == "00"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-3)+","+RIGHT(ALLTRIM(STR(nValor)),2)
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.9999"),1) == "0"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-4)+","+RIGHT(ALLTRIM(STR(nValor)),3)
Else
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-5)+","+RIGHT(ALLTRIM(STR(nValor)),4)
EndIf

Return cRet

*---------------------*
Static Function Total()              
*---------------------*
Local nTOT1:= nTOT2:=0
Local cRet := "" 

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	nTOT1 += (cAlias)->RC_HORAS
	nTOT2 += (cAlias)->RC_VALOR
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
cRet += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cRet += "		 <tr>"
For i:=1 to (cAlias)->(FCount())
	If (cAlias)->(Fieldname(i)) == "RC_HORAS"
		cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cRet += "				<font face='times' color='black' size='3'>"+NumtoExcel(nTOT1,.T.)
		cRet += "			</td>"
		i++
	EndIf
	If (cAlias)->(Fieldname(i)) == "RC_VALOR"
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

*-----------------------------*
Static Function Quebra_2()              
*-----------------------------*
Local cRet := "" 

cRet += "		 <tr>"
cRet += "		 <td></td>"
cRet += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "					<td><font face='times' color='black' size='3'><b> "+cCentro+" - "+ cDescrCC+" </b></font></td>"
cRet += "			</td>"
cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "				<font face='times' color='black' size='3'><b> ="+NumtoExcel(nValorQuebra,.T.)+" </b></font></td>"
cRet += "			</td>"
cRet += "		<td></td>"
cRet += "		 </tr>"

Return cRet

*-----------------------------*
Static Function Quebra_3()
*-----------------------------*
Local cRet := "" 

cRet += "		 <tr>"
cRet += "		 <td></td>"
cRet += "			 <td width='700' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "					<td><font face='times' color='black' size='3'><b> "+cDescr+" </b></font></td>"
cRet += "			</td>"
cRet += "		<td></td>"
cRet += "		<td></td>"
cRet += "		<td></td>"
cRet += "		<td></td>"
cRet += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "				<font face='times' color='black' size='3'><b> ="+NumtoExcel(nValorQuebra,.T.)+" </b></font></td>"
cRet += "			</td>"
cRet += "		 </tr>"

Return cRet  

*-----------------------------*
Static Function Quebra_4()
*-----------------------------*
//Quebra sendo utilizada como criação do cabeçalho.
Local cRet := "" 
Local cCorCell := "#6600CC'"
Local cLetra := "White"

cRet += "	<table height='361' width='844' bgColor='#ffffff' border='1' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cRet += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_FILIAL", "TIT") +" </b></font>"
cRet += "		</td>"
cRet += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RA_CC", "TIT") +"</b></font>"
cRet += "		</td>"
cRet += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_MAT", "TIT") +"</b></font>"
cRet += "		</td>"
cRet += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RA_NOME", "TIT") +"</b></font>"
cRet += "		</td>"
cRet += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_PD", "TIT") +"</b></font>"
cRet += "		</td>"
cRet += "		<td width='700' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RV_DESC", "TIT") +"</b></font>"
cRet += "		</td>"
cRet += "		<td width='400' height='41' bgcolor='"+cCorCell+"' border='1' bordercolor='#000000' align = 'Left'>"
cRet += "		<font face='times' color='"+cLetra+"' size='3'> <b> "+ RETSX3("RC_HORAS", "TIT") +"</b></font>"
cRet += "		</td>"                  
cRet += "	</tr>"

Return cRet
