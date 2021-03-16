#include "Protheus.ch"
#include "rwmake.ch"
#include "SHELL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RWCTB001  ºAutor  Matheus Massarottoº     Data ³  02/02/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório Balance para a A100 ROW                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³Chamado: 002872											  º±±
±±º          ³															  º±±
±±º          ³Dados da solicitação:Por conta,                             º±±
±±º          ³Com centro de custo, classe de valor, item contábil.		  º±±
±±º          ³Com valores acumulados de cada conta.						  º±±
±±º          ³Crédito entre parenteses - toda parte passivos, receitas.   º±±
±±º          ³Parâmetro por mês. 						  	   			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : RWCTB001()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : .
Autor       : Jean Victor Rocha - Matheus Massarotto
Data/Hora   : 27/04/2012        - 02/02/2012

*/
*----------------------*
User function RWCTB001()
*----------------------*
Local cPerg:="RWCTB001"	//Pergunta

Private nRecCount := 0
Private cDest	:=  GetTempPath()
Private cArq	:= "balancerw_"+DTOS(date())+".xls"
Private nBytesSalvo:=0
if !cEmpAnt $ 'RW|99'
	Alert("Função não está disponível para esta empresa!")
	return()
endif

U_PUTSX1( cPerg, "01", "Data Inicial?"	, "Data Inicial?", "Data Inicial", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Final?"	, "Data Final?"	, "Data Final"	, "", "D",08,00,00,"G","" , "","","","MV_PAR02")

If select("TRBCT71")>0
	TRBCT71->(DbCloseArea())
endif 

If !pergunte(cPerg,.T.)
	return()
endif

If EMPTY(MV_PAR01) .or. EMPTY(MV_PAR02) .or. MV_PAR01 > MV_PAR02
	Alert("Data inserida no filtro invalida.")
	Return()
Endif

cDataIni := DTOS(MV_PAR01)
cDataFim := DTOS(MV_PAR02)
cMoeda   := '04'
cVazio   := ''

BeginSQL alias 'TRBCT71'
SELECT
	CT2.CT2_CONTA,
	CT2.CC		,
	CT2.ITEMC	,
	CT2.CLVL	,
	CT1.CT1_DESC01,
	SUM(CT2.SALDO)	AS [SALDO],
	SUM(CT2.MVTD)	AS [MVTD],
	SUM(CT2.MVTC)	AS [MVTC],
	SUM(CT2.MVT)	AS [MVT],
	SUM(MVTSLD)		AS [MVTSLD]
	FROM (SELECT	CT2_DEBITO 	   		AS CT2_CONTA, 
					CT2_CCD 	   		AS CC,
					CT2_ITEMD 	   		AS ITEMC,
					CT2_CLVLDB 	   		AS CLVL,
					0 			   		AS SALDO, 
					SUM(CT2_VALOR) AS MVTD,
					0 					AS MVTC,
					SUM(CT2_VALOR) as MVT,
					SUM(CT2_VALOR) AS MVTSLD
			FROM %table:CT2%
			WHERE 	%notDel%
					AND CT2_DATA 	>= %exp:cDataIni%
			   		AND CT2_DATA 	<= %exp:cDataFim%
			 		AND CT2_MOEDLC 	=  %exp:cMoeda% 
					AND CT2_DEBITO 	<> %exp:cVazio%
					AND (LEFT(CT2_DEBITO,1) NOT IN ('1')) 
		   			AND (LEFT(CT2_DEBITO,1) NOT IN ('2'))
			GROUP BY CT2_DEBITO,CT2_CCD,CT2_ITEMD,CT2_CLVLDB
		UNION ALL
			SELECT	CT2_CREDIT 		AS CT2_CONTA,
					CT2_CCC 		AS CC,
					CT2_ITEMC  		AS ITEMC,
					CT2_CLVLCR 		AS CLVL,
					0 				AS SALDO,
					0 				AS MVTD,
					SUM(CT2_VALOR*(-1))	AS MVTC,
					SUM(CT2_VALOR*(-1)) 	AS MVT,
					SUM(CT2_VALOR*(-1)) 	AS MVTSLD
			FROM %table:CT2%
			WHERE 	%notDel% 
			   		AND CT2_DATA 	>= %exp:cDataIni%
			   		AND CT2_DATA 	<= %exp:cDataFim%
			   		AND CT2_MOEDLC 	=  %exp:cMoeda%
			  		AND CT2_CREDIT 	<> %exp:cVazio%
			  		AND (LEFT(CT2_CREDIT,1) NOT IN ('1')) 
			   		AND (LEFT(CT2_CREDIT,1) NOT IN ('2'))
			GROUP BY CT2_CREDIT,CT2_CCC,CT2_ITEMC,CT2_CLVLCR
		UNION ALL
			SELECT	CT2_DEBITO 			AS CT2_CONTA,
					CT2_CCD 	   		AS CC,
					CT2_ITEMD 	   		AS ITEMC,
					CT2_CLVLDB	   		AS CLVL,
					SUM(CT2_VALOR) AS SALDO,
					' '   		AS MVTD,
					' '   		AS MVTC,
					' ' 		AS MVT,
					SUM(CT2_VALOR*(-1)) AS MVTSLD
			FROM %table:CT2%
			WHERE	%notDel% 
					AND	CT2_DATA 	< %exp:cDataIni%
					AND CT2_MOEDLC 	= %exp:cMoeda% 
					AND CT2_DEBITO 	<> %exp:cVazio%
					AND (LEFT(CT2_DEBITO,1) NOT IN ('1')) 
					AND (LEFT(CT2_DEBITO,1) NOT IN ('2'))
			GROUP BY CT2_DEBITO,CT2_CCD,CT2_ITEMD,CT2_CLVLDB
		UNION ALL
			SELECT  CT2_CREDIT 		AS CT2_CONTA,
					CT2_CCC    		AS CC,
					CT2_ITEMC  		AS ITEMC,
					CT2_CLVLCR 		AS CLVL,
					SUM(CT2_VALOR*(-1)) 	AS SALDO,
					' ' 	AS MVTD,
					' ' 	AS MVTC,
					' ' 	AS MVT,
					SUM(CT2_VALOR) 	AS MVTSLD
			FROM %table:CT2%
			WHERE	%notDel%
					AND	CT2_DATA 	< %exp:cDataIni%
					AND CT2_MOEDLC 	= %exp:cMoeda% 
					AND CT2_CREDIT 	<> %exp:cVazio%
					AND (LEFT(CT2_CREDIT,1) NOT IN ('1')) 
					AND (LEFT(CT2_CREDIT,1) NOT IN ('2'))
			GROUP BY CT2_CREDIT,CT2_CCC,CT2_ITEMC,CT2_CLVLCR
		UNION ALL
			SELECT	CT7_CONTA  			AS CT2_CONTA,
				' ' 			   		AS CC,
				' '				   		AS ITEMC,
				' ' 			  		AS CLVL,
				' '						AS SALDO,
				SUM(CT7_DEBITO)			AS MVTD,
				-SUM(CT7_CREDIT)			AS MVTC,
				-SUM(CT7_CREDIT-CT7_DEBITO) AS MVT,
				0 							AS MVTSLD
			FROM %table:CT7%
			WHERE	LEN (CT7_CONTA)	= 9 
					AND CT7_DATA	>= %exp:cDataIni%
					AND CT7_DATA	<= %exp:cDataFim%
					AND CT7_MOEDA	=  %exp:cMoeda% 
					AND %notDel%
					AND LEFT(CT7_CONTA,1) < 3
			GROUP BY CT7_CONTA	
		UNION ALL	
			SELECT	CT7_CONTA 		AS CT2_CONTA,
				' '					AS CC,
				' '					AS ITEMC,
				' '					AS CLVL,
				-SUM(CT7_CREDIT - CT7_DEBITO)	AS SALDO,
				' '					AS MVTD,
				' '					AS MVTC,
				' '					AS MVT,
				0								AS MVTSLD
			FROM %table:CT7%
			WHERE	LEN (CT7_CONTA)	= 9 
					AND CT7_DATA	<= %exp:cDataIni%
					AND CT7_MOEDA	=  %exp:cMoeda%
					AND LEFT(CT7_CONTA,1) < 3
					AND %notDel%
			GROUP BY CT7_CONTA
		UNION ALL	
			SELECT	CT7_CONTA 			AS CT2_CONTA,
					' '			   		AS CC,
					' '		  			AS ITEMC,
					' '					AS CLVL,
					' '					AS SALDO,
					' '					AS MVTD,
					' ' 					AS MVTC,
					0  								AS MVT,
					-SUM(CT7_CREDIT - CT7_DEBITO)	AS MVTSLD
			FROM %table:CT7%
			WHERE	LEN (CT7_CONTA)	= 9 
					AND CT7_DATA	<= %exp:cDataFim%
					AND CT7_MOEDA	= %exp:cMoeda% 
					AND LEFT(CT7_CONTA,1) < 3
					AND %notDel%
			GROUP BY CT7_CONTA) AS CT2 
		LEFT OUTER JOIN (SELECT CT1_DESC01,CT1_CONTA
						FROM %table:CT1%
						WHERE %notDel%) AS CT1 ON CT1.CT1_CONTA = CT2.CT2_CONTA
	WHERE CT2.CC <> '9999'
	GROUP BY CT2.CT2_CONTA,CT2.CC,CT2.ITEMC,CT2.CLVL,CT1.CT1_DESC01
EndSql

Count to nRecCount

If nRecCount<=0
	alert("Não existe informações para este filtro!")
	TRBCT71->(DbCloseArea())
	return()
Endif

Processa({|| Montaxls()})

Return  

//Foi quebrado em etapas para não causar estouro de variavel.
*----------------------------*
Static Function Montaxls()
*----------------------------*
Local cMsg := ""
Local cAliasWork := "TRBCT71"

IF FILE(cDest+cArq)
//	FERASE(cDest+cArq) TLM 04/12/2012
ENDIF 

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cMsg ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td colspan='2'>Data extraction:</td><td>"+Dtoc(DATE())+" - "+TIME()+"</td>"
cMsg += "		<tr></tr><tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> "+SM0->M0_NOME+" </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr><tr>"
cMsg += "			<td colspan='2'>Period:</td><td>"+DTOC(MV_PAR01)+" - "+DTOC(MV_PAR02)+"</td>"
cMsg += "		</tr>"
cMsg += "	<tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Account </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='250' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Cost Center </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Item Accounting </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Class Value </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Description </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> previous balance </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Debit </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Credit </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Balance period </b></font>"
cMsg += "			 </td>"
cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
cMsg += "				 <font face='times' color='black' size='3'> <b> Current Balance </b></font>"
cMsg += "			 </td>"
cMsg += "		 </tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
     
ProcRegua((cAliasWork)->(RecCount()))
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	cMsg += "		 <tr>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> " +(cAliasWork)->CT2_CONTA
	cMsg += "			 </td>"
	cMsg += "			 <td width='250' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+(cAliasWork)->CC
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+(cAliasWork)->ITEMC
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+(cAliasWork)->CLVL
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> " +(cAliasWork)->CT1_DESC01
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+NumtoExcel((cAliasWork)->SALDO)
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+NumtoExcel((cAliasWork)->MVTD)
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+NumtoExcel((cAliasWork)->MVTC)
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+NumtoExcel((cAliasWork)->MVT)
	cMsg += "			 </td>"
	cMsg += "			 <td width='150' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "				 <font face='times' color='black' size='3'> "+NumtoExcel((cAliasWork)->MVTSLD)
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
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    endif
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	
	sleep(8000) //MSM - 19/12/2012 - Para dar tempo de gerar o arquivo
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif

	sleep(8000) //MSM - 19/12/2012 - Para dar tempo de gerar o arquivo         

FErase(cDest+cArq) //TLM 04/12/2012

If select("TRBCT71")>0
	TRBCT71->(DbCloseArea())
Endif 


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
