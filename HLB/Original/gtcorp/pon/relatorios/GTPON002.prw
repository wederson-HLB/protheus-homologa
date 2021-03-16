#include "totvs.ch"   
#INCLUDE "rwmake.ch"
#include 'topconn.ch'    
#include 'colors.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTPON002  ºAutor  Tiago Luiz Mendonça  º Data ³  30/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de marcações                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*                                                     	
Funcao      : GTPON002()
Objetivos   : Relatório de marcações
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/
*-------------------------*
  User Function GTPON002()
*--------------------------*    

  
  Local oDlg 
  Local oMain
  Local aPeriodo 
  Local aAno 
  Local cDias:= GetMv("MV_PAPONTA")
  
  
  aPeriodo := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"} 
  aAno:={Alltrim(str(Year(dDatabase))),Alltrim(str(Year(dDatabase)-1)),  Alltrim(str(Year(dDatabase)+1))}       
  
   
  Private cPeriodo              
  Private cAno     
                                                             
  DEFINE MSDIALOG oDlg TITLE  "Selecione o periodo para visualizar a quantidade de marcações "  From 1,10 To 15,50 OF oMain
       
   	@ 015,30 Say "Periodo?" 
  	@ 015,60 COMBOBOX cPeriodo ITEMS aPeriodo PIXEL SIZE 60,6 OF oDlg
   	@ 030,30 Say "Ano ?"    
   	@ 030,60 COMBOBOX cAno ITEMS aAno PIXEL SIZE 60,6 OF oDlg
    
    @ 055,20 Say "Exemplo: caso seja selecionado periodo de outubro"  COLOR CLR_HBLUE  
    @ 065,25 Say "   o range de datas será : "+substr(alltrim(cDias),1,2)+"/09  até "+substr(alltrim(cDias),4,2)+"/10... " COLOR CLR_HBLUE  
    
	@ 85,30 BUTTON "CANCELA" size 50,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel  
 	@ 85,80 BUTTON "GERAR" size 50,15 ACTION Processa({|| MontaTemp()}) of oDlg Pixel

  ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Return 
                                                                                 

/*
Funcao      : MontaRel()
Objetivos   : Monta temporario com os dados que serão impressos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 11/04/2013
*/    

*----------------------------*
  Static Function MontaTemp() 
*----------------------------*    


Private cDataIni
Private cDataFin

	cDataIni:= Alltrim(cAno)+Mes("I")+'16'
	cDataFim:= Alltrim(cAno)+Mes("F")+'15'

	                                                                         
	If Select("QRYRFE") > 0

   		QRYRFE->(DbCloseArea())	               

   	EndIf
   	     

	    BeginSql Alias 'QRYRFE'
	
			SELECT  B.RFE_EMPORG,B.RFE_FILORG,A.RA_MAT,A.RA_NOME,A.RA_DESFUNC,B.RFE_PIS,A.RA_SITFOLH AS OBS, COUNT(*) AS MARCACOES 

   				FROM %Table:RFE%  B 

					LEFT JOIN  %Table:SRA%  A 
	   				ON A.RA_FILIAL+'0'+A.RA_PIS = B.RFE_FILORG+B.RFE_PIS

		   			WHERE 
		   				
		   				B.D_E_L_E_T_ <> '*' AND A.RA_NOME <> ' ' AND ( A.RA_SITFOLH =' ' OR A.RA_SITFOLH ='F' ) AND A.RA_DEMISSA = ' ' AND B.RFE_DATA > %exp:cDataIni%  AND B.RFE_DATA < %exp:cDataFim% 
		
					GROUP BY B.RFE_EMPORG,B.RFE_FILORG,A.RA_MAT,B.RFE_PIS,A.RA_NOME,A.RA_DESFUNC,A.RA_SITFOLH ORDER BY MARCACOES 		
		EndSql  	
	     
	
		If QRYRFE->(EOF())  
			MsgStop("Não foi encontrado dados para esse periodo, verifique o se periodo encontra-se aberto")     
		Else
			Montaxls()				                                   
        EndIf
Return   

//Foi quebrado em etapas para não causar estouro de variavel.
*----------------------------*
Static Function Montaxls()
*----------------------------*

Local cMsg   := ""   
Local cLinha := ""

Private cDest	:=  GetTempPath()
Private cArq	:= "RH_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"

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
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='Arial' color='black' size='4'> "+SM0->M0_NOME+"</font></td>"
cMsg += "		</tr>"
cMsg += "		<tr>
cMsg += "		</tr>
cMsg += "		<tr>"  
cMsg += '			<td class="Titulo" colspan="6">'
cMsg += "				Periodo : "+Alltrim(cPeriodo)+"/"+cAno+"  intervalo de ( "+DTOC(STOD(cDataIni))+" )  até  ( "+DTOC(STOD(cDataFim))+" )</td>"
cMsg += "		</tr>"
cMsg += "	<tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Empresa"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Filial"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Matricula"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Nome"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Função"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Pis"  
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Obs"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			  Marcacoes"
cMsg += "			 </td>"
cMsg += "		 </tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
       
QRYRFE->(DbGoTop())
While QRYRFE->(!EOF())  
    
	If alltrim(cLinha) <> '<td class="DataLinhaImpar" />'
    	cLinha:='<td class="DataLinhaImpar" />'
	Else
    	cLinha:='<td class="DataLinhaPar" />'	
	EndIf    


	cMsg += "<tr>"
	cMsg += cLinha
	cMsg += '="     '+QRYRFE->RFE_EMPORG+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="'+QRYRFE->RFE_FILORG+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="'+QRYRFE->RA_MAT+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="'+QRYRFE->RA_NOME+'"'	
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="'+QRYRFE->RA_DESFUNC+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="     '+QRYRFE->RFE_PIS+'"'
	cMsg += "	</td>"	
	cMsg += cLinha
	cMsg += '="     '+QRYRFE->OBS+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="     '+Alltrim(Str(QRYRFE->MARCACOES))+'"'
	cMsg += "	</td>"
	cMsg += "</tr>"    
	
	cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
	QRYRFE->(DbSkip())

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

If select("QRYRFE")>0
	QRYRFE->(DbCloseArea())
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

*-------------------------*
Static Function Mes(cTipo)
*-------------------------*

Local nMes:=0      
Local cMes:=""
    
	If cPeriodo == "Janeiro"   
		nMes:=1
	ElseIf cPeriodo == "Fevereiro"  	
		nMes:=2
	ElseIf cPeriodo == "Março"  	
		nMes:=3
	ElseIf cPeriodo == "Abril"  	
		nMes:=4
	ElseIf cPeriodo == "Maio"  	
		nMes:=5
	ElseIf cPeriodo == "Junho"  
		nMes:=6
	ElseIf cPeriodo == "Julho"  
		nMes:=7
	ElseIf cPeriodo == "Agosto"  
		nMes:=8
	ElseIf cPeriodo == "Setembro"  
		nMes:=9
	ElseIf cPeriodo == "Outubro"  	
		nMes:=10
	ElseIf cPeriodo == "Novembro"  
		nMes:=11
	ElseIf cPeriodo == "Dezembro"  	
		nMes:=12
	EndIf
              
//Mes inicial                          
If cTipo == "I" 
	
	nMes--
	If nMes==0
		nMes:=12
	EndIf	
	
	If Len(alltrim(str(nMes))) == 1
		cMes:="0"+Alltrim(str(nMes)) 
	Else
		cMes:= Alltrim(str(nMes))		
	EndIf  
	                                 
EndIf
              
//Mês final
If cTipo == "F"	
	If Len(alltrim(str(nMes))) == 1
		cMes:= "0"+Alltrim(str(nMes))
	Else
		cMes:= Alltrim(str(nMes))			
	EndIf  

EndIf

Return cMes

