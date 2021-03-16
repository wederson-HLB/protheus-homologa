#Include "APWEBEX.CH"
#include "tbiconn.ch"

*-------------------------*
  User Function GTHDNEWS()
*-------------------------*    

Local cHtml := ""   
Local cDescri

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" USER "administrador" PASSWORD 'hdgt@23' MODULO "FAT"  
  
WEB EXTENDED INIT  cHtml 

HTTPSESSION->SESSIONID := nil //Iniciando a declaraçao da variavel de Sessao.
   
cHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"'
cHtml += '"http://www.w3.org/TR/html4/loose.dtd">'
cHtml += '<html> '
cHtml += '<head> '
cHtml += '<title>News GT</title> '
cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">   '
cHtml += '<style type="text/css"> '


cHtml += '<!--'
cHtml += 'body,td,th {'
cHtml += '	font-family: verdana;'
cHtml += '	font-size: 10px;  '
cHtml += '}'
cHtml += 'body { '
cHtml += '	background-color: #FFFFFF;'
cHtml += '	margin-left: 0px; '
cHtml += '	margin-top: 0px;'
cHtml += '}   '
cHtml += '.text1 {  '
cHtml += '	font-family: verdana; '
cHtml += '	font-size: 10px; '
cHtml += '	font-weight: normal;'
cHtml += '	color: #000000;'
cHtml += '}  '
cHtml += '.text2 {  '
cHtml += '	font-family: verdana;'
cHtml += '	font-size: 10px;  '
cHtml += '	font-weight: normal; '
cHtml += '	color: #000000;'
cHtml += '}'
cHtml += '.text3 {'
cHtml += '	font-family: verdana;'
cHtml += '	font-size: 10px;'
cHtml += '	font-weight: bold;'
cHtml += '	color: #010101;'
cHtml += '}  '
cHtml += '.text4 {'
cHtml += '	font-family: verdana;'
cHtml += '	font-size: 10px;'
cHtml += '	font-weight: bold; '
cHtml += '	color: #FFFFFF;'
cHtml += '} '
cHtml += '.text5 { '
cHtml += '	font-family: verdana;'
cHtml += '	font-size: 10px; '
cHtml += '	font-weight: normal; '
cHtml += '	color: #666666;'
cHtml += '}  '
cHtml += '.text6 {'
cHtml += '	font-family: verdana; '
cHtml += '	font-size: 10px;'
cHtml += '	font-weight: normal;'
cHtml += '	color: #FFFFFF; '
cHtml += '}  '
cHtml += '.brder {  '
cHtml += '	border: thin solid #A5A1A0;'
cHtml += '  border-width:1px;'
 cHtml += '} '
cHtml += '-->'
cHtml += '</style>'
cHtml += '</head>'
cHtml += '<body>'

cHtml += '<td width="15">    '     

cHtml += '<tr> '
cHtml += '<td width="15" align="left" > '
cHtml += '<a href="javascript:history.go(-1)"><<</a>'
cHtml += '</a>'
cHtml += '</td>'
cHtml += '</td>'  
                     

cHtml += '<center>'
cHtml += '<table width="570" border="0" cellpadding="5" cellspacing="1" class="brder">'
 
cHtml += '	<tr align="left" bgcolor="#FFFFFF"> '
cHtml += '		<td colspan="4" valign="top" bgcolor="#FFFFFF"><div align="left"><img src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" width="554" height="90"></div></td>  '
cHtml += '	</tr>'  

Z06->(DbGobottom()) 
Z06->(DbSetOrder(1))


While Z06->(!BOF())
                                                             
  
	cHtml += '  <!--Linha da noticia--> '
	cHtml += '	<tr> '
	cHtml += '		<td colspan="4">'
	cHtml += '			<hr> '
	cHtml += '		</td> '	
	cHtml += '	</tr> '		
		
	cHtml += '	<tr>  '
			
	cHtml += '		<td align="left" >'
				
	cHtml += '			<span class="text3">   '
	
	cHtml += '				<td>'                   
	
	If Z06->Z06_TIPO == "1"
		cHtml += '<img src="imagens/documentacao.jpg" width="160" height="40"> '
	ElseIf  Z06->Z06_TIPO == "2"
		cHtml += '<img src="imagens/atualizacao.jpg" width="160" height="40"> '
	ElseIf Z06->Z06_TIPO == "3"
		cHtml += '<img src="imagens/melhoria.jpg" width="160" height="40"> '					
	EndIf
	
	
	cHtml += '				</td>'
	cHtml += '				<td align="left" >  '
	cHtml += '					<Strong>'
   	cHtml += DTOC(Z06->Z06_DATA)+" - "+Alltrim(Z06->Z06_TITULO)				
	cHtml += '					</strong> '
	cHtml += '				</td> '
	cHtml += '			</span>  '
	cHtml += '		</td>  '
	  
	cHtml += '	</tr>    '
		
	cHtml += '	<tr align="left" bgcolor="#FFFFFF" class="brder">'
	cHtml += '		<td colspan="4" align="Left" valign="top" bgcolor="#FFFFFF"> '
	cHtml += '			<span class="text5">  '
	cHtml += '				<br>   '   
	
	cDescri:=Z06->Z06_DESCRI
	
	nPos:=At(chr(13)+chr(10),Alltrim(cDescri))   
	While 0 < nPos                          
   		cDescri:=Stuff(cDescri,nPos,4,"<BR><BR>")
   		nPos:=At(chr(13)+chr(10),Alltrim(cDescri))   
	EndDo 
  
   	cHtml +=Alltrim(cDescri)

	cHtml += '				<br> '
	cHtml += '				<br> ' 
	cHtml += '				<br> '
	cHtml +='Posted at '+Alltrim(Z06->Z06_HORA) 
	cHtml += '				<br> '
	cHtml += '			</span>'
	cHtml += '		</td>  '
	cHtml += '    </tr> '   
	
 	Z06->(DbSkip(-1))


EndDo
	
	
cHtml += '</table> '
cHtml += '</body>   '
cHtml += '</center> '
cHtml += '</html>  ' 
   

WEB EXTENDED END     

HttpLeaveSession()

RpcClearEnv()
   
Return cHtml  


 


