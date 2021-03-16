#include "Protheus.ch"
#include "rwmake.ch"
#include "SHELL.CH"

/*
Funcao      : GTGPE006
Parametros  : 
Retorno     : 
Objetivos   : Relatorio de Historico Salarial
Autor       : Jean Victor Rocha
Data/Hora   : 14/03/2013
TDN         : 
*/
*----------------------*
User Function GTGPE006()
*----------------------* 
Local cPerg := "GTGPE006"

//Ajusta os Perguntes da Rotina.
PutSx1( cPerg, "01", "Filial De?"		,"Filial De?"		,"Filial De?"		, "mv_ch01"	, "C",02,00,00,"G",""			, "XM0"	,"","","MV_PAR01","","","","","","","","","","","","","","","","",{"Informe a Filial Inicial."})
PutSx1( cPerg, "02", "Filial Ate?"		,"Filial Ate"		,"Filial Ate?"		, "mv_ch02"	, "C",02,00,00,"G","" 			, "XM0"	,"","","MV_PAR02","","","","","","","","","","","","","","","","",{"Informe a Filial Final."})
PutSx1( cPerg, "03", "CC De?"			,"CC De?"			,"CC De?"			, "mv_ch03"	, "C",09,00,00,"G",""			, "CTT"	,"","","MV_PAR03","","","","","","","","","","","","","","","","",{"Informe o Centro de Custo Inicial."})
PutSx1( cPerg, "04", "CC Ate?"   		,"CC Ate?"			,"CC Ate?"			, "mv_ch04"	, "C",09,00,00,"G",""			, "CTT"	,"","","MV_PAR04","","","","","","","","","","","","","","","","",{"Informe o Centro de Custo Final."})
PutSx1( cPerg, "05", "Matricula De?"	,"Matricula De?"	,"Matricula De?"	, "mv_ch05"	, "C",06,00,00,"G","" 			, "SRA"	,"","","MV_PAR05","","","","","","","","","","","","","","","","",{"Informe a MAtricula inicial."})
PutSx1( cPerg, "06", "Matricula Ate?" 	,"Matricula Ate?"	,"Matricula Ate?"	, "mv_ch06"	, "C",06,00,00,"G","" 			, "SRA"	,"","","MV_PAR06","","","","","","","","","","","","","","","","",{"Informe a Matricula Final."})
PutSx1( cPerg, "07", "Periodo De?"		,"Periodo De?"		,"Periodo De?"		, "mv_ch07"	, "D",08,00,00,"G","" 			, ""	,"","","MV_PAR07","","","","","","","","","","","","","","","","",{"Informe a Data de alterações Salariais de inicio."})
PutSx1( cPerg, "08", "Periodo Ate?"		,"Periodo Ate?"		,"Periodo Ate?"		, "mv_ch08"	, "D",08,00,00,"G","" 			, ""	,"","","MV_PAR08","","","","","","","","","","","","","","","","",{"Informe a Data de alterações Salariais Final."})

//Chamada do Pergunte.
If !pergunte(cPerg,.T.)
	return()
Endif

//Carrega os parametros do pergunte.
cFilIni := MV_PAR01
cFilFim := MV_PAR02
cCcIni	:= MV_PAR03
cCcFim	:= MV_PAR04
cMatIni	:= MV_PAR05
cMatFim	:= MV_PAR06
cDtIni	:= DTOS(MV_PAR07)
cDtFim	:= DTOS(MV_PAR08)

//Busca os dados.
BuscaInfos()

//Imprime Excel.
Processa({|| Montaxls()})

Return .T.               

/*
Funcao      : BuscaInfos
Parametros  : 
Retorno     : 
Objetivos   : Busca os dados para impressão.
Autor       : Jean Victor Rocha
Data/Hora   : 14/03/2013
TDN         : 
*/
*------------------------*
Static Function BuscaInfos()
*------------------------*      

If select("TRB")>0
	TRB->(DbCloseArea())
endif 

//Default caso os parametros estejam em branco.
cFilFim := If(EMPTY(cFilFim),"ZZ"			,cFilFim)
cCcFim  := If(EMPTY(cCcFim)	,"ZZZZZZZZZ"	,cCcFim)
cMatFim := If(EMPTY(cMatFim),"ZZZZZZ"		,cMatFim)
cDtFim  := If(EMPTY(cDtFim)	,DTOS(DATE())	,cDtFim)

BeginSQL alias 'TRB'
	Select RA_FILIAL,RA_MAT,RA_NOME,SRA.RA_SALARIO,SRA.RA_ADMISSA,SR7.R7_DATA,SR7.R7_SEQ,SR3.R3_VALOR,SR7.R7_TIPO,SX5.X5_DESCRI,SR7.R7_FUNCAO,
			SR7.R7_DESCFUN,SRA.RA_CC
	From %table:SRA% SRA 	 Join (Select * 
										From %table:SR7%
										Where D_E_L_E_T_ <> '*') as SR7 on SRA.RA_FILIAL+SRA.RA_MAT=SR7.R7_FILIAL+SR7.R7_MAT
							 Join (Select *
										From %table:SR3%
										Where D_E_L_E_T_ <> '*') as SR3 on SR7.R7_FILIAL+SR7.R7_MAT=SR3.R3_FILIAL+SR3.R3_MAT AND
																		SR7.R7_DATA=SR3.R3_DATA AND
																		SR7.R7_SEQ=SR3.R3_SEQ
							 Join (Select *
										From %table:SX5%
										Where D_E_L_E_T_ <> '*' 
										AND X5_TABELA = '41') as SX5 on SX5.X5_CHAVE=SR7.R7_TIPO
	Where SRA.D_E_L_E_T_ <> '*'
			AND SRA.RA_FILIAL	>= %exp:cFilIni%
			AND SRA.RA_FILIAL	<= %exp:cFilFim%
			AND SRA.RA_CC		>= %exp:cCcIni%
			AND SRA.RA_CC 		<= %exp:cCcFim%
			AND SRA.RA_MAT		>= %exp:cMatIni%
			AND SRA.RA_MAT		<= %exp:cMatFim%
			AND SR3.R3_DATA		>= %exp:cDtIni%
			AND SR3.R3_DATA		<= %exp:cDtFim%
			AND SRA.RA_DEMISSA   = ' '
	Order By SRA.RA_FILIAL,SRA.RA_MAT,SR7.R7_DATA,SR7.R7_SEQ
EndSql

Return .T.

/*
Funcao      : Montaxls
Parametros  : 
Retorno     : 
Objetivos   : Gera o Relatorio em Excel.
Autor       : Jean Victor Rocha
Data/Hora   : 14/03/2013
TDN         : 
*/
*------------------------*
Static Function Montaxls()
*------------------------*
Local cMsg := ""
Local cAliasWork := "TRB"

Private nBytesSalvo:=0
Private cDest	:=  GetTempPath()
Private cArq	:= "HIST_SAL_"+cEmpAnt+DTOS(date())+".xls"

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cMsg ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			<td colspan='2'>Data de Consulta:</td><td>"+Dtoc(DATE())+" - "+TIME()+"</td>"
cMsg += "		<tr>"
cMsg += "		</tr>
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> Historico Salarial </b></font></td>"
cMsg += "		<tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> "+SM0->M0_NOME+" </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		<tr>"
cMsg += "	</table>"

cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Filial </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> C.Custo </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Matricula </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Nome </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Salario </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Dt.Admissao </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Dt.Alteração </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Seq. </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Valor </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Tipo </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Descrição </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Função </b></font>"
cMsg += "			</td>"
cMsg += "			<td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				<font face='times' color='black' size='3'> <b> Desc.Função </b></font>"
cMsg += "			</td>"
cMsg += "		</tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

cKey := cCor := "#ffffff"
     
ProcRegua((cAliasWork)->(RecCount()))
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If cKey <> (cAliasWork)->RA_FILIAL+(cAliasWork)->RA_MAT
		Do Case
			Case cCor == "#D3D3D3"
				cCor := "#ffffff"
			Case cCor == "#ffffff"
				cCor := "#D3D3D3"
		EndCase
		cKey := (cAliasWork)->RA_FILIAL+(cAliasWork)->RA_MAT
	EndIf

	cMsg += "		 <tr>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> =TEXTO("+ALLTRIM(STR(VAL((cAliasWork)->RA_FILIAL)))+';"00")'
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->RA_CC
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> =TEXTO("+ALLTRIM(STR(VAL((cAliasWork)->RA_MAT)))+';"000000")'
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->RA_NOME
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> "+NumtoExcel((cAliasWork)->RA_SALARIO)
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +DTOC(STOD((cAliasWork)->RA_ADMISSA))
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +DTOC(STOD((cAliasWork)->R7_DATA ))
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->R7_SEQ
	cMsg += "			 </td>"                                                                 
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> "+NumtoExcel((cAliasWork)->R3_VALOR)
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->R7_TIPO
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->X5_DESCRI
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->R7_FUNCAO
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='"+cCor+"' border='1' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='2'> " +(cAliasWork)->R7_DESCFUN
	cMsg += "			 </td>"
	cMsg += "		 </tr>"

	cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
	IncProc("Gerando arquivo Excel...")	
	(cAliasWork)->(DbSkip())
EndDo
cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	If ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    Endif
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
Endif

Sleep(8000)
FErase(cDest+cArq)

Return cMsg

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

*-------------------------------*
Static Function NumtoExcel(nCont)
*-------------------------------*
Local cRet := ""
Local nValor:= nCont
Local cValor:= TRANSFORM(nValor, "@R 99999999999.99")
Local nLen := LEN(ALLTRIM(cValor))

cRet := SUBSTR(ALLTRIM(cValor),0,nLen-3)+","+RIGHT(ALLTRIM(cValor),2)

Return cRet