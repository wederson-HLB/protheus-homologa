#include "topconn.ch"
#include "rwmake.ch"  

/*
Funcao      : MT416FIM 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada chamado após a manutenção do orçamento
Autor     	: Tiago Luiz Mendonça
Data     	: 27/06/2014
Obs         : 
TDN         : Após o termino da efetivação do Orçamento de Venda.
Revisão     :
Data/Hora   :    
Módulo      : Faturamento.    
Cliente     : Victaulic
*/


*------------------------*
User Function MT416FIM()
*------------------------*    

Local aOrd	:= SaveOrd({"SCK","SA1","SCJ"})
  
If cEmpAnt $ "TM"

	aHeader := {}
	aDetail := {}
	        
	
	aAdd(aHeader,{"CJ_NUM"		,SCJ->CJ_NUM})
	aAdd(aHeader,{"CJ_USERLGI"	,SCJ->CJ_USERLGI})
	aAdd(aHeader,{"CJ_CLIENTE"	,SCJ->CJ_CLIENTE})
	
	SCK->(DbSetorder(1))
	If SCK->(DbSeek(xFilial("SCK")+SCJ->CJ_NUM))
		While SCK->(!Eof()) .And. SCK->CK_FILIAL==xFilial("SCK") .And.;
				SCK->CK_NUM == SCJ->CJ_NUM
		    aAux := {}
		    aAdd(aAux,{"CK_PRODUTO"	,SCK->CK_PRODUTO})
		    aAdd(aAux,{"CK_DESCRI"	,SCK->CK_DESCRI})
		    aAdd(aAux,{"CK_QTDVEN"	,SCK->CK_QTDVEN})
		    aAdd(aAux,{"CK_PRCVEN"	,SCK->CK_PRCVEN})
		    aAdd(aAux,{"CK_VALOR"	,SCK->CK_VALOR})
		    aAdd(aAux,{"CK_NUMPV"	,SCK->CK_NUMPV})
		    aAdd(aDetail,aAux)
		    
			SCK->(dbSkip())
		EndDo
	EndIf
	
	SendWorkFlow(aHeader,aDetail)            
	
EndIf
	
Restord(aOrd)

Return .T.      

/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Tiago Luiz Mendonça
Data    : 27/06/2014
*/
*-------------------------------------------*
Static Function SendWorkFlow(aHeader,aDetail)
*-------------------------------------------* 

Local nPosNum	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_NUM" })
Local cEmail	:= Email(aHeader,aDetail)
  

If !Empty(Alltrim(SCK->CK_NUMPV))
	oEmail          := DEmail():New()
	oEmail:cFrom   	:= "totvs@hlb.com.br"
	oEmail:cTo		:= PADR(ALLTRIM(GetMv("MV_P_EMAI4",,"")),400)
	oEmail:cSubject	:= padr("Orcamento'"+ALLTRIM(aHeader[nPosNum][2])+"' efetivado.",200)
	oEmail:cBody   	:= cEmail
	oEmail:Envia()
EndIf


Return .T.  

/*
Função  : Email
Objetivo: Monta o email a ser enviado no workflow.
Autor   : Tiago Luiz Mendonça
Data    : 27/06/2014
*/
*------------------------------------*
Static Function Email(aHeader,aDetail)
*------------------------------------*  
Local cAux := ""
Local cHtml := ""

Local nPosNum	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_NUM" })
Local nPosCol	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_USERLGI" })
Local nPosCli	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_CLIENTE" })

SA1->(DbSetorder(1))
SA1->(DbSeek(xFilial("SA1")+aHeader[nPosCli][2])) 

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
cHtml+= TipoString(10.0,2)
cHtml+="										Solicitação "+ALLTRIM(aHeader[nPosNum][2])+" efeitvada"
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
cHtml+= TipoString(8.5,1)
cHtml+="									Numero:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosNum][2])
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Colaborador:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(cUserName)
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Cliente:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosCli][2])+" - "+ALLTRIM(SA1->A1_NOME)
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"



cHtml+="					</table>" 
cHtml+="				</Div>"
cHtml+="			</td>"  
cHtml+="		</tr>"						
cHtml+="   	</table>"
cHtml+="</div>"	
cHtml+="<tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>"
cHtml+="	<H1>"
cHtml+="	<td style='padding:0cm 0cm 0cm 0cm'>"
cHtml+="		<div align=center>"
cHtml+="			<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=679 style='width:509.25pt;mso-cellspacing:0cm;border:outset #CCCCCC 1.0pt;"
cHtml+="			mso-border-alt:outset #CCCCCC .75pt;mso-yfti-tbllook:1184;mso-padding-alt:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="				<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="					<td width='4%' style='width:4.0%;order:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Produto/Serviço<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Descrição<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Quantidade<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Unitário<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Total<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="								Ped. Venda<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"

For i:=1 to Len(aDetail)
	cHtml+="				<tr style='mso-yfti-irow:1'>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)                                             
	cHtml+="					"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_PRODUTO" })][2])+"<o:p></o:p>"	
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="				"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_DESCRI" })][2])+"<o:p></o:p>"
 	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(STR(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_QTDVEN" })][2]))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(Transform(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_PRCVEN" })][2],"@E 99,999,999.9999"))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(Transform(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_VALOR" })][2],"@E 99,999,999.9999"))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="				"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_NUMPV" })][2])+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="				</tr>"

Next i

cHtml+="			</table>"
cHtml+="		</div>"
cHtml+="		<p class=MsoNormal>&nbsp;</p>"
cHtml+="    </td>" 
cHtml+="</tr>"	
cHtml+="<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="	<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="		<p class=MsoNormal align=center style='text-align:center'>"
cHtml+="			<span class=tituloatencao1>"
cHtml+="				<span style='font-size:9.5pt;mso-fareast-font-family:"
cHtml+='				"Times New Roman"'
cHtml+="				;color:red'>"
cHtml+="						HLB BRASIL - Mensagem automática, favor não responder este e-mail."
cHtml+="				</span>"
cHtml+="			</span>"
cHtml+="		</p>"
cHtml+="    </td>"
cHtml+="</tr>"
cHtml+="</body>"
cHtml+="</html>"                       

Return cHtml

/*
Funcao      : TipoString
Objetivos   : 
Autor       : 
Data/Hora   : 
*/            
*----------------------------------------*
 Static Function TipoString(nTam,nColor)
*-----------------------------------------*
                               
Local cAux:=""
      			     			
cAux:="<span style='font-size:"+Alltrim(Str(nTam))+"pt;font-family:"
cAux+='"Verdana","sans-serif"'
cAux+=";mso-fareast-font-family:"
cAux+='"Times New Roman"'
cAux+=";color:"+IIf(nColor==1,"Black","white")+"'>"
               
Return cAux