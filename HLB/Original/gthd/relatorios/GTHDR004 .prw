#include "totvs.ch"   
#INCLUDE "rwmake.ch"
#include 'topconn.ch'    
#include 'colors.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDR004  ºAutor  Tiago Luiz Mendonça  º Data ³  31/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de contagem de funcionários                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDR004()
Objetivos   : Relatório de contagem de funcionários
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2013
*/
*-------------------------*
  User Function GTHDR004()
*-------------------------*    

	Processa( {|| MontaRel() }, "Aguarde...", "Executando procedure...",.F.) 
    
Return 

/*
Funcao      : MontaRel()
Objetivos   : Executa procedure
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2013
*/    

*----------------------------*
  Static Function MontaRel() 
*----------------------------*

Local cProcedure:=""
                                                                         
	If Select("QRYZ13") > 0

		QRYZ13->(DbCloseArea())	               

   	EndIf
   	     
	//Seta o banco   
	cProcedure:="use GTHD"+CHR(13)+CHR(10)
	//Monta as procedures 
	cProcedure+="exec GTHD_GPE_001"+CHR(13)+CHR(10)	
	//Executa as procedures 
	If (TCSQLExec(cProcedure) < 0)   
		Conout(" Procedure : TCSQLError() " + TCSQLError()) 
		MsgStop("Erro na execução, verifique console","Grant Thornton") 
	Else  
		conout("Procedure GTHD_GPE_001 processado com sucesso.") 	
	
		If Select("QRYZ13") > 0

			QRYZ13->(DbCloseArea())	               

   		EndIf	
		  
		BeginSql Alias 'QRYZ13'
	
			SELECT *  
			FROM
			%Table:Z13%
			WHERE 
				Z13_FILIAL = %exp:xFilial("Z13")%  AND 
				%notDel% 
	
			ORDER 
				BY Z13_AMB			
		EndSql 	

   		Processa( {|| Montaxls() }, "Aguarde...", "Montando relatório...",.F.) 	       	       
		
	EndIf 
                                                                                   
Return

/*
Funcao      : Montaxls()
Objetivos   : Gera excel
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2013
*/    

*----------------------------*
Static Function Montaxls()
*----------------------------*

Local cMsg   := ""   
Local cLinha := ""

Private cDest	:=  GetTempPath()
Private cArq	:= "HD_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cMsg ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cMsg += "<html>  
cMsg += "	<Header>"   
cMsg += "	<style>"  
cMsg +=" .DataHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal; "
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:center;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:.5pt solid #808080;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:.5pt solid #808080;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".DataLinhaImpar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:center;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=" .DataLinhaPar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:center;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	background:#E3E3E3;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"

cMsg +=".HistoricoHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:.5pt solid #808080;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:none;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".HistoricoLinhaImpar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"

cMsg +=".HistoricoLinhaPar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	background:#E3E3E3;
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"

cMsg +=".ValorHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:.5pt solid #808080;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:none;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".ValorLinhaImpar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +='    mso-number-format:"\#\,\#\#0\.00\;\[Red\]\0022-\0022\\ \#\,\#\#0\.00";'  
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".ValorLinhaPar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +='	mso-number-format:"\#\,\#\#0\.00\;\[Red\]\0022-\0022\\ \#\,\#\#0\.00";'
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	background:#E3E3E3;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"

cMsg +=".SaldoHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="    border-top:.5pt solid #808080;"
cMsg +="	border-right:.5pt solid #808080;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:none;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".Titulo"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +="	font-family:Verdana, sans-serif;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:General;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:middle;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"

cMsg += ".Dados"
cMsg += "	{padding:0px;"
cMsg += "	mso-ignore:padding;
cMsg += "	color:black;
cMsg += "	font-size:8.0pt;
cMsg += "	font-weight:190;
cMsg += "	font-style:normal;
cMsg += "	text-decoration:none;"
cMsg += '	font-family:"";'
cMsg += "	mso-generic-font-family:auto;"
cMsg += "	mso-font-charset:0;"
cMsg += "	mso-number-format:Standard;"
cMsg += "	text-align:general;"
cMsg += "	vertical-align:middle;"
cMsg += "	mso-background-source:auto; "
cMsg += "	mso-pattern:auto;"
cMsg += "	white-space:nowrap;}"
cMsg += "</style></head>"
cMsg += "<body>"
cMsg += '<img width="553" height="70" src="http://www.grantthornton.com.br/images/logo.gif" >'
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<tr><td></td></tr>"
cMsg += "		<tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='Arial' color='black' size='4'>Quanitdade de colaboradores por empresa </font></td>"
cMsg += "		</tr>"
cMsg += "		<tr>
cMsg += "		</tr>
cMsg += "		<tr>"  
cMsg += '			<td class="Titulo" colspan="6">'
cMsg += "				Dados gerados da tabela SRA, demitidos não entram na contagem  (RA_SITFOLH<>'D') </td>"
cMsg += "		</tr>"
cMsg += "	<tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			 	Código"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Nome"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Ambiente"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Quantidade"
cMsg += "			 </td>"
cMsg += "		 </tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

DbSelectArea("QRYZ13")
QRYZ13->(DbGoTop())
ProcRegua(RecCount()) 

While QRYZ13->(!EOF())  
    
	
	IncProc() 
	
	If alltrim(cLinha) <> '<td class="DataLinhaImpar" />'
    	cLinha:='<td class="DataLinhaImpar" />'
	Else
    	cLinha:='<td class="DataLinhaPar" />'	
	EndIf    


	cMsg += "<tr>"
	cMsg += cLinha
	cMsg += '="     '+QRYZ13->Z13_CODIGO+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ13->Z13_EMPRES
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ13->Z13_AMB
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="     '+Alltrim(Str(QRYZ13->Z13_QTD))+'"'
	cMsg += "	</td>"
	cMsg += "</tr>"    
	
	cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
	QRYZ13->(DbSkip())

EndDo

cMsg += "	</table>"
cMsg += "	<BR>"
cMsg += "	<BR>"
cMsg += "	<colspan='2'>Data extraction : "+Dtoc(DATE())+" - "+TIME()

cMsg += "</html> "

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	If ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	
	sleep(8000) //MSM - Para dar tempo de gerar o arquivo
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
EndIf

	sleep(8000) //MSM - Para dar tempo de gerar o arquivo         

FErase(cDest+cArq) 

If select("QRYZ13")>0
	QRYZ13->(DbCloseArea())
EndIf 


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

