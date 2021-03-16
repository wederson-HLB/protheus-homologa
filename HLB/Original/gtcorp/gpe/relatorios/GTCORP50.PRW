#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP50
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relatorio informando os aniversariantes do mês
Autor       : João Silva
Revisão		:
Data/Hora   : 29/10/2012
Módulo      : Generico
Cliente     :
TDN         : 
*/

*----------------------------*
User Function GTCORP50()
*----------------------------*
Local 	aEmpresas 		 := {}
Local   aAniversariantes := {}
Local   cPerg    		 :="GTCORP50_P"   
Local   iCodEmp     	 := 1
Local   iNomEmp			 := 2 
Local   iNome    		 := 1
Local   iDia			 := 2
Private cQry1		 	 :=""
Private cHtml			 :="" 
                                                                                                    
	//Definição das perguntas.
	PutSx1( cPerg , "01", "Mês de Consulta?"  ,"Mês de Consulta?" ,"Mês de Consulta?" , "", "D", 08, 00, 00,"C", "", "", "", "","MV_PAR01", "", "", "", "")   
	  	  
	If !Pergunte(cPerg,.T.)
	    Return()
	EndIf 

	//Matriz com todas as empresas do sigamat
	nRecNoSigamat := SM0->(RecNo())
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())
	While SM0->(!EOF())
		If aScan(aEmpresas, {|aEmp| aEmp[iCodEmp] == SM0->M0_CODIGO}) == 0
		   aAdd(aEmpresas, {SM0->M0_CODIGO, SM0->M0_NOME})
		EndIf
		SM0->(DbSkip())
	EndDo
	SM0->(DbGoTo(nRecNoSigamat))
   
	//Estrutura da Query
	For nI = 1 To Len(aEmpresas)
		cQry1 :=" SELECT "+CRLF 
		cQry1 +=" RA_NOME AS NOME, "+CRLF
		cQry1 +=" RIGHT(RA_NASC,2)+'/'+SUBSTRING(SRA.RA_NASC,5,2)AS DIA"
		cQry1 +=" FROM   " +CRLF
		cQry1 +=" SRA"+ aEmpresas[nI][iCodemp] +"0 AS SRA"+CRLF
		cQry1 +=" WHERE SRA.D_E_L_E_T_ = '' "
		cQry1 +=" AND SRA.RA_DEMISSA = '' "
		cQry1 +=" AND SUBSTRING(SRA.RA_NASC,5,2) ='"+ SubStr(DtoS(MV_PAR01),5,2) +"'" 
		cQry1 +=" ORDER BY RIGHT(SRA.RA_NASC,2)
	
		If (TCSQLExec(cQry1) >= 0)
				
			//Fechando tabela temporaria TEMP se estiver aberta e abrindo novamente para inserir dados
			If Select ('TEMP')>0
			   TEMP->(DbCloseArea('TEMP'))
			EndIf

			DbUseArea(.T., 'TOPCONN', TcGenQry(,,cQry1),'TEMP',.F.,.T.)
			
			TEMP->(DbSetOrder(0))
			TEMP->(DbGoTop())		
			While TEMP->(!EOF())
				  aAdd(aAniversariantes, {TEMP->NOME, TEMP->DIA})			  
				  TEMP->(DbSkip())
			EndDo 
	   	EndIF		
	Next nI	
	
    aSort(aAniversariantes, , ,{|X,Y| X[2] < Y[2] } )  
	
//Cria estrutura HTML
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
cHtml+=" 	<td class='corLinHead' colspan='2'><font color='#FFFFFF'>Relatorio de aniversariantes do mes</font></td>"
cHtml+=" </tr>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead'>NOME FUNCIONARIO</td>"
cHtml+="    <td class='corLinHead'>DIA ANIVERSARIO</td>"
cHtml+=" </tr>"
    
	For nI := 1 To Len (aAniversariantes)
	    cHtml +='<tr class="nome">'
		cHtml += '<td>'+ aAniversariantes[nI][iNome] + '</td>'
		cHtml += '<td>'+ aAniversariantes[nI][iDia] + '</td>'
		cHtml +='</tr>'		
	Next nI

cHtml+=" </table>"
cHtml+=" </body>"
cHtml+=" </html>"   
    
	//Gera EXCEL
	cDest :=  GetTempPath()
	cArq := 'aniversariantes mes.xls'
		
	If File (cDest+cArq)
		Ferase (cDest+cArq)
	EndIf

	nHdl 	:= Fcreate(cDest+cArq,0 )
	nBytesSalvo := Fwrite(nHdl, cHtml)
	
	If nBytesSalvo <= 0
		MsgStop('Erro de gravação do Destino. Error = ' + Str(Ferror(), 4) + ' Erro')
	Else
		Fclose(nHdl)
		cExt := '.xls'
		ShellExecute('open', (cDest+cArq), '', '', 5)
	EndIf

Return .F.