#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : TMFAT006
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Adicionar informações ao picking list 
Autor       : Tiago Luiz Mendonça
Data        : 16/09/2014
Revisão     :        
Data        : 
Módulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function TMFAT006()   
*----------------------* 

Local cMsg     
Local Omain
     

If Empty(SCJ->CJ_P_REV)
   
	If SCJ->CJ_STATUS == "A"

		If MsgYesNo("Deseja realmente marcar esse orçamento como REVISADO ?","Victaulic")
                                                                            
			RecLock("SCJ",.F.)          
   			SCJ->CJ_P_REV := "S"
	   		SCJ->CJ_P_USER:= alltrim(cUserName)
   	   		SCJ->CJ_P_DATA:= dDataBase
			SCJ->(MsUnlock()) 
			
			EnviaEmail()            
    	
	  	EndIf
	
	Else
	    
		If SCJ->CJ_STATUS =="C"
			cMsg:="Orçamento "+alltrim(SCJ->CJ_NUM)+" cancelado"
		ElseIf  SCJ->CJ_STATUS =="B"
			cMsg:="Orçamento "+alltrim(SCJ->CJ_NUM)+" baixado"
		EndIF
		
		MsgAlert(cMsg,"Victaulic")
	
	EndIF 
	  	

Else
	
	DEFINE MSDIALOG oDlg TITLE "VICTAULIC" From 1,3 To 10,60 OF oMain     
   
   		@ 008,008 SAY "ORCAMENTO "+Alltrim(SCJ->CJ_NUM)+" REVISADO"  COLOR CLR_HBLUE

		@ 022,008 SAY "USER      :"+Alltrim(SCJ->CJ_P_USER) 
  		@ 032,008 SAY "DATA      :"+DTOC(SCJ->CJ_P_DATA)   		

	ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())
	

EndIf

Return
                       
/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Tiago Luiz Mendonça
Data    : 27/06/2014
*/
*----------------------------*
Static Function EnviaEmail()
*---------------------------* 


Local cHtml := ""  

cHtml+='<html xmlns:v="urn:schemas-microsoft-com:vml"'
cHtml+='xmlns:o="urn:schemas-microsoft-com:office:office"'
cHtml+='xmlns:w="urn:schemas-microsoft-com:office:word" '
cHtml+='xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"'
cHtml+='xmlns="http://www.w3.org/TR/REC-html40">'

cHtml+='<head>
cHtml+='	<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
cHtml+='	<meta name=ProgId content=Word.Document> '
cHtml+='	<meta name=Generator content="Microsoft Word 12"> '
cHtml+='	<meta name=Originator content="Microsoft Word 12">'
cHtml+='</head>
cHtml+='<body bgcolor="#FFFFFF" lang=PT-BR link=blue vlink=purple style="tab-interval:35.4pt">'
cHtml+='<div class=WordSection1>'
cHtml+="	<p class=MsoNormal  align=center style='text-align:center'> "
cHtml+='		<a href="http://www.grantthornton.com.br/">'
cHtml+="			<span style='text-decoration:none; text-underline:none'>"
//cHtml+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
cHtml+="			</span>"
cHtml+="		</a>"  
cHtml+="    </p>"
cHtml+="</div>"
cHtml+="<h1>"
cHtml+="<div align=center>"
cHtml+="	<table class=MsoNormalTable border=0 cellpadding=0 width=800 style='width:525.0pt;mso-cellspacing:1.5pt;background:white;mso-yfti-tbllook:1184'>"
cHtml+="		<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="			<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="				<div align=center>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+="						<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="							<td style='background:#4D1174;padding:0cm 0cm 0cm 0cm'>"
cHtml+="								<p class=MsoNormal align=center style='text-align:center'><b> "  
cHtml+="								<span style='font-size:8 pt;font-family:Verdana,sans-serif mso-fareast-font-family:Times New Roman ;color:white>"            
cHtml+="										ORCAMENTO "+ALLTRIM(SCJ->CJ_NUM)+" REVISADO"
cHtml+="									</span></b>"
cHtml+="								</p>"
cHtml+="							</td>"
cHtml+="						</tr>"
cHtml+="					</table>"
cHtml+="				</div>"
cHtml+="				<div align=center>"
cHtml+="					<Br>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+='						<tr bgcolor="#FCFCFC">'
cHtml+="							<td>" 
cHtml+="									Numero:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+="									"+ALLTRIM(ALLTRIM(SCJ->CJ_NUM))
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+="									Colaborador:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+="									"+ALLTRIM(cUserName)
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+="					</table>" 
cHtml+="				</Div>"
cHtml+="			</td>"  
cHtml+="		</tr>"						
cHtml+="   	</table>"
cHtml+="</div>"	
      
      



oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(ALLTRIM(GetMv("MV_P_EMAI3",,"")),400)
oEmail:cSubject	:= padr("Orcamento"+SCJ->CJ_NUM+" revisado.",200)
oEmail:cBody   	:= cHtml
oEmail:Envia()


      
Return



