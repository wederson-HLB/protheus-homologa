#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP66
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relatório de PROPOSTAS Outsourcing. 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 15/04/2013    10:28
Módulo      : Gestão de Contratos
*/

/*
Funcao      : GTCORP66()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da rotina principal do relatório
Autor       : Matheus Massarotto
Data/Hora   : 15/04/2013
*/
*----------------------------*
User Function GTCORP66()
*----------------------------*
Private cEmpr		:=""
Private cFili		:=""
Private cTipo		:="1"
Private cPerg   	:="GTCORP66_P"
Private cAssunto	:=""
Private cEmpTitulo	:=""

if !cEmpAnt $ "Z4/CH"

		Alert("Rotina não disponível para esta empresa!")
		return()

endif

if cEmpAnt=="Z4"
	cEmpTitulo:= "Grant Thornton Outsourcing"
elseif cEmpAnt=="CH"
	cEmpTitulo:= "Grant Thornton Technology"
else
	cEmpTitulo:= ""
endif

	
	//Definição das perguntas.
	PutSx1( cPerg, "01", "Data De:"			, "Data De:"		, "Data De:"		, "", "D",08,00,00,"G","" , "","","","MV_PAR01")
	PutSx1( cPerg, "02", "Data Ate:"		, "Data Ate:"		, "Data Ate:"		, "", "D",08,00,00,"G","" , "","","","MV_PAR02")
	PutSx1( cPerg, "03", "Exibe Em aberto?"	, "Exibe Em aberto?", "Exibe Em aberto?", "", "N",1 ,00,00,"C","" , "","","","MV_PAR03","Sim","","","","Não")
	PutSx1( cPerg, "04", "Exibe Pendente?"	, "Exibe Pendente?"	, "Exibe Pendente?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR04","Sim","","","","Não")
	PutSx1( cPerg, "05", "Exibe Aprovado?"	, "Exibe Aprovado?"	, "Exibe Aprovado?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR05","Sim","","","","Não")
	PutSx1( cPerg, "06", "Exibe Recusado?"	, "Exibe Recusado?"	, "Exibe Recusado?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR06","Sim","","","","Não")
	PutSx1( cPerg, "07", "Exibe Revisado?"	, "Exibe Revisado?"	, "Exibe Revisado?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR07","Sim","","","","Não")
		
	If !Pergunte(cPerg,.T.)
		Return()
	EndIf

Private cQry1:=""
Private cHtml:=""
Private nICor:=0


	cContStatus:=""
	
	if MV_PAR03==1
		cContStatus+="'','1',"
	endif                    
	if MV_PAR04==1
		cContStatus+="'3','6',"
	endif
	if MV_PAR05==1
		cContStatus+="'5','8','9',"
	endif
	if MV_PAR06==1
		cContStatus+="'4','7',"
	endif
	if MV_PAR07==1
		cContStatus+="'2',"
	endif
	
	cContStatus:=SUBSTR(cContStatus,1,len(cContStatus)-1)


//Montagem da Query  
	cQry1 :=" SELECT "+CRLF
	cQry1 +=" Z79_FILORI , "+CRLF
	cQry1 +=" CASE Z79_STATUS WHEN '' THEN 'EM ABERTO' ELSE "+CRLF
	cQry1 +=" 	CASE Z79_STATUS WHEN '1' THEN 'EM ABERTO' ELSE "+CRLF
	cQry1 +=" 		CASE Z79_STATUS WHEN '2' THEN 'REVISADO' ELSE "+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '3' THEN 'PENDENTE APROVACAO GT' ELSE"+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '4' THEN 'RECUSADO GT' ELSE"+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '5' THEN 'APROVADO GT' ELSE"+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '6' THEN 'PENDENTE APROVACAO CLIENTE' ELSE"+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '7' THEN 'RECUSADO CLIENTE' ELSE"+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '8' THEN 'APROVADO SEM ASSINATURA CLIENTE' ELSE"+CRLF
	cQry1 +=" 			CASE Z79_STATUS WHEN '9' THEN 'APROVADO COM ASSINATURA CLIENTE' "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 		END "+CRLF
	cQry1 +=" 	END "+CRLF
	cQry1 +=" END AS 'Z79_STATUS', "+CRLF
	cQry1 +=" Z79_NUM, "+CRLF
	cQry1 +=" Z79_REVISA, "+CRLF
	cQry1 +=" CONVERT(VARCHAR(10),CONVERT(DateTime, Z79_DTINC, 103),103) as Z79_DTINC , "+CRLF
	cQry1 +=" Z79_RESPON,  "+CRLF
	cQry1 +=" Z79_NOMERE, "+CRLF
	cQry1 +=" Z79_CLIENT, "+CRLF
	cQry1 +=" Z79_NOME, "+CRLF	
	cQry1 +=" Z79_PROSPE, "+CRLF
	cQry1 +=" Z79_PNOME, "+CRLF
	cQry1 +=" Z79_REFERE, "+CRLF
	cQry1 +=" Z79_MOEDA, "+CRLF
	cQry1 +=" Z79_VLRINI, "+CRLF
	cQry1 +=" Z79_VALOR, "+CRLF
	cQry1 +=" Z79_DESCON, "+CRLF
	cQry1 +=" Z79_VLRTOT, "+CRLF

	//Preenche o tipo da proposta
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(DbSeek("Z79_TIPOCT"))
		aTipos:=SEPARA(SX3->X3_CBOX,";")
		
		for i:=1 to len(aTipos)
			cQry1 +=" CASE Z79_TIPOCT WHEN '"+SUBSTR(aTipos[i],1,1)+"' THEN '"+SUBSTR(alltrim(aTipos[i]),3,len(aTipos[i]))+"' ELSE"
			if i==len(aTipos)
				cQry1 +=" ''"
			endif
		next
		for i:=1 to len(aTipos)		
			cQry1 +=" END"
		next
	endif

	cQry1 +=" AS 'Z79_TIPOCT', "+CRLF

	cQry1 +=" Z79_VLREXT, "+CRLF
	cQry1 +=" Z79_VLDIPJ, "+CRLF
	cQry1 +=" Z79_VLRANO, "+CRLF
	cQry1 +=" Z79_VLRIMP, "+CRLF
	cQry1 +=" Z79_VLDPFI, "+CRLF
	
		//Preenche o advogado
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(DbSeek("Z79_ADVOGA"))
		aTipos:=SEPARA(SX3->X3_CBOX,";")
		
		for i:=1 to len(aTipos)
			cQry1 +=" CASE Z79_ADVOGA WHEN '"+SUBSTR(aTipos[i],1,1)+"' THEN '"+SUBSTR(alltrim(aTipos[i]),3,len(aTipos[i]))+"' ELSE"
			if i==len(aTipos)
				cQry1 +=" '' "
			endif
		next
		for i:=1 to len(aTipos)		
			cQry1 +=" END"
			
		next
	endif
	
	cQry1 +=" AS 'Z79_ADVOGA', "+CRLF

		//Preenche despesa reembolsavel
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(DbSeek("Z79_DREEMB"))
		aTipos:=SEPARA(SX3->X3_CBOX,";")
		
		for i:=1 to len(aTipos)
			cQry1 +=" CASE Z79_DREEMB WHEN '"+SUBSTR(aTipos[i],1,1)+"' THEN '"+SUBSTR(alltrim(aTipos[i]),3,len(aTipos[i]))+"' ELSE"
			if i==len(aTipos)
				cQry1 +=" '' "
			endif
		next
		for i:=1 to len(aTipos)		
			cQry1 +=" END"
			
		next
	endif
	
	cQry1 +=" AS 'Z79_DREEMB', "+CRLF
	cQry1 +=" Z79_TIME, "+CRLF
	cQry1 +=" Z79_TIMEUS, "+CRLF
	
		//Preenche o idioma
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(DbSeek("Z79_IDIOMA"))
		aTipos:=SEPARA(SX3->X3_CBOX,";")
		
		for i:=1 to len(aTipos)
			cQry1 +=" CASE Z79_IDIOMA WHEN '"+SUBSTR(aTipos[i],1,1)+"' THEN '"+SUBSTR(alltrim(aTipos[i]),3,len(aTipos[i]))+"' ELSE"
			if i==len(aTipos)
				cQry1 +=" '' "
			endif
		next
		for i:=1 to len(aTipos)		
			cQry1 +=" END"
			
		next
	endif
	
	cQry1 +=" AS 'Z79_IDIOMA', "+CRLF
	cQry1 +=" Z79_USERNO ,"+CRLF
	cQry1 +=" Z70_MOTIVO = (SELECT TOP 1 Z70_PORCEN + '% -' +Z70_MOTIVO from "+ RETSQLNAME("Z70") +" where D_E_L_E_T_ <> '*' AND Z70_FILIAL = Z79_FILIAL AND Z70_PROPOS = Z79_NUM AND Z70_REVISA = Z79_REVISA ORDER BY R_E_C_N_O_ DESC), "+CRLF
	cQry1 +=" Case Z79_MOTREC "+CRLF	
	cQry1 +=" 	When '1' then 'Preco' "+CRLF	
	cQry1 +=" 	When '2' then 'Concorrente' "+CRLF	
	cQry1 +=" 	When '3' then 'Conflito' "+CRLF	
	cQry1 +=" 	When '4' then 'Declinou' "+CRLF		
	cQry1 +=" 	when '5' then 'Outros' "+CRLF	
	cQry1 +=" 	else Z79_MOTREC "+CRLF	
	cQry1 +=" 	End as 'Z79_MPTREC', Z79_OBSREC, "+CRLF	
	cQry1 +=" 	Z92_NOMEMP = (select TOP 1 Z92_NOMEMP from "+RETSQLNAME("Z92") +" where D_E_L_E_T_ <> '*' and Z92_NOME = Z79_REFERE)"+CRLF	

			
	cQry1 +=" FROM   "+RETSQLNAME("Z79")
	cQry1 +=" WHERE D_E_L_E_T_ = '' "

	cQry1 +=" AND Z79_DTINC BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
	cQry1 +=" AND Z79_STATUS IN ("+cContStatus+") 

	
	cQry1 +=" ORDER BY Z79_NUM

	If tcsqlexec(cQry1)<0
		Alert("Ocorreu um problema na busca das informações!!")
		return
	EndIf

conout("Depois da query")
if select("TRB79")>0
	TRB79->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRB79",.T.,.T.)

Count to nRecCount
conout("nRecCount: "+cvaltochar(nRecCount))
cHtml+=" <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
cHtml+=" <html xmlns='http://www.w3.org/1999/xhtml'>"
cHtml+=" <head>"
cHtml+=" <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
cHtml+=" <title>Propostas</title>"

cHtml+=" <style type='text/css'>"
cHtml+=" .corLinHead {"
cHtml+=" 	background-color: #AA92C7;"
cHtml+="	font-weight:bold;"
cHtml+="	font-size:16px;"
cHtml+="	text-align:center;"
cHtml+=" }"

cHtml+=" .corLinBody {"
cHtml+=" 	background-color: #C2C2DC;"
cHtml+=" }"

cHtml+=" </style>"
cHtml+=" </head>"

cHtml+=" <body>"
cHtml+=" <table border='1'>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead' colspan='29'><font color='#FFFFFF'>"+cEmpTitulo+"</font></td>"
cHtml+=" </tr>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead'>FILIAL</td>"
cHtml+="    <td class='corLinHead'>STATUS</td>"
cHtml+="    <td class='corLinHead'>Nº PROPOSTA</td>"
cHtml+="    <td class='corLinHead'>REVISAO</td>"
cHtml+="    <td class='corLinHead'>DATA INCLUSAO</td>"
cHtml+="    <td class='corLinHead'>COD. RESPONSAVEL</td>"
cHtml+="    <td class='corLinHead' width='200'>RESPONSAVEL</td>"
cHtml+="    <td class='corLinHead'>COD. CLIENTE</td>"
cHtml+="    <td class='corLinHead' width='400'>NOME DO CLIENTE</td>"
cHtml+="    <td class='corLinHead'>COD. DO PROSPECT</td>"
cHtml+="    <td class='corLinHead' width='400'>NOME DO PROSPECT</td>"
cHtml+="    <td class='corLinHead' width='300'>REFERENCIA</td>"
cHtml+="    <td class='corLinHead' width='300'>EMPRESA DE REF.</td>"
cHtml+="    <td class='corLinHead'>MOEDA</td>"
cHtml+="    <td class='corLinHead'>VALOR INICIAL</td>"
cHtml+="    <td class='corLinHead'>VALOR</td>"
cHtml+="    <td class='corLinHead'>DESCONTO</td>"
cHtml+="    <td class='corLinHead'>VALOR TOTAL</td>"
cHtml+="    <td class='corLinHead'>TIPO CONTRATO</td>"
cHtml+="    <td class='corLinHead'>VALOR EXTRA</td>"
cHtml+="    <td class='corLinHead'>VALOR DIPJ</td>"
cHtml+="    <td class='corLinHead'>VALOR ANUAL</td>"
cHtml+="    <td class='corLinHead'>VALOR IMPLANTACAO</td>"
cHtml+="    <td class='corLinHead'>VALOR DESPESA FIXA</td>"
cHtml+="    <td class='corLinHead'>ADVOGADO</td>"
cHtml+="    <td class='corLinHead'>DESPESA REEMBOLSAVEL</td>"
cHtml+="    <td class='corLinHead'>HORAS CALCULADAS</td>"
cHtml+="    <td class='corLinHead'>HORAS ESTIMADAS</td>"
cHtml+="    <td class='corLinHead'>IDIOMA</td>"
cHtml+="    <td class='corLinHead' width='200'>USUARIO RESPONSAVEL</td>"
cHtml+="    <td class='corLinHead' width='400'>POSICIONAMENTO</td>"
cHtml+="    <td class='corLinHead'>MOTIVO RECUSA</td>"
cHtml+="    <td class='corLinHead' width='400'>OBS RECUSA</td>"
cHtml+=" </tr>"

if nRecCount>0
	TRB79->(DbGoTop())
	
	While TRB79->(!EOF())
	nICor++
		
		cHtml+=" <tr>"
		cHtml+=" 	<td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB79->Z79_FILORI)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_STATUS)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_NUM)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB79->Z79_REVISA)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_DTINC)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB79->Z79_RESPON)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_NOMERE)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB79->Z79_CLIENT)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_NOME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB79->Z79_PROSPE)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_PNOME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_REFERE)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z92_NOMEMP)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB79->Z79_MOEDA)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLRINI,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VALOR,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_DESCON,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLRTOT,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_TIPOCT)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLREXT,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLDIPJ,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLRANO,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLRIMP,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB79->Z79_VLDPFI,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_ADVOGA)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_DREEMB)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_TIME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_TIMEUS)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_IDIOMA)+"</td>"						
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_USERNO)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(FwNoAccent(TRB79->Z70_MOTIVO))+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_MPTREC)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB79->Z79_OBSREC)+"</td>"
		cHtml+=" </tr>	"
		TRB79->(DbSkip())
	Enddo
endif

cHtml+=" </table>"
cHtml+=" </body>"
cHtml+=" </html>"

TRB79->(DBCloseArea())


	GExecl(cHtml)

Return

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para gerar o excel
Autor       : Matheus Massarotto
Data/Hora   : 15/04/2013	17:17
*/
*------------------------------*
Static Function GExecl(cConteu)
*------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

	cArq := "Propostas_"+alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cConteu ) // Gravação do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
/***********************GERANDO EXCEL************************************/          
    sleep(10000)
	FERASE (cDest+cArq)

Return

/*
Funcao      : IsEmpty()
Parametros  : cConteudo
Retorno     : cRet
Objetivos   : Função para retornar &nbsp; caso o campo seja braco
Autor       : Matheus Massarotto
Data/Hora   : 15/04/2013	17:17
*/
*--------------------------------*
Static Function IsEmpty(cConteudo)
*--------------------------------*
Local cRet:="&nbsp;"

if !empty(cConteudo)
	cRet:=cConteudo
endif

Return(cRet)
