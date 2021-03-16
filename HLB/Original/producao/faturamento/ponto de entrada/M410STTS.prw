#Include "rwmake.ch"
#include "PROTHEUS.CH"

/*
Funcao      : M4100STTS
Objetivos   : PE após alteração,inclusão,copua ou exclusão de pedido de venda
Autor       : João Silva
Obs.        :
Data        : 24/12/2014
*/

*------------------------------------*
User Function M410STTS()
*------------------------------------*
Local cSubject		:= ""
Local cAnexo		:= ""
Local cEmail		:= ""
Local cDestinatario	:= ""
Local nItem 		:= 0

If cEmpAnt $ "LG"
	//Atualiza antes da exclusão para tratamento no envio do status para IMS
	If IsInCallStack("A410Deleta")
		If SC5->(FieldPos("C5_P_ENV1")) <> 0
			If SC5->C5_P_ENV1 $ '3' .AND. SC5->C5_NOTA = ' ' .AND. SC5->C5_P_REF <> ' '
				SC5->(RecLock("SC5",.F.))
					SC5->C5_P_ENV1 := '4'
				SC5->(MsUnlock())
			EndIf
		EndIf
	EndIf
EndIf

If cEmpAnt $ "P3"//PRONOKAL
	//Inclusão
	If IsInCallStack("A410Inclui")
		//	MsgInfo( "INCLUI M410STTS" )
		SendWorkFlow()
		
		//Copiar
	ElseIf IsInCallStack("A410Copia ")
		//	MsgInfo( " Copia M410STTS" )
		SendWorkFlow()
		
		//Alteração
	ElseIf IsInCallStack("A410Altera")
		//	MsgInfo("ALTERACAO M410STTS")
		
		SendWorkFlow()
		
		//Deletar
	ElseIf IsInCallStack("A410Deleta")
		//	MsgInfo("DELETA M410STTS")
		
		SendWorkFlow()
		
	EndIF
EndIf
Return(Nil)

/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Tiago Luiz Mendonça
Data    : 30/06/2014
*/
*----------------------------*
Static Function SendWorkFlow()
*----------------------------*


Local cEmail	:= Email()


oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(ALLTRIM(GetMv("MV_P_00039",,"")),400)
oEmail:cSubject	:= 'Pedido :  '+ M->C5_NUM
oEmail:cBody   	:= cEmail
oEmail:Envia()

Return .T.

/*
Função  : Email
Objetivo: Monta o email a ser enviado no workflow.
Autor   : Tiago Luiz Mendonça
Data    : 30/06/2014
*/
*------------------------------------*
Static Function Email(aHeader,aDetail)
*------------------------------------*

Local cAux := ""
Local cHtml := ""

SA1->(DbSetorder(1))
SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

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
cHtml+="										Pedido "+ALLTRIM(M->C5_NUM)+" "
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
cHtml+="									"+ALLTRIM(M->C5_NUM)
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
cHtml+="									"+ALLTRIM(SA1->A1_COD)+" - "+ALLTRIM(SA1->A1_NOME)
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
cHtml+="									Produto<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
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

cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
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
cHtml+="								Status<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"

DbSelectArea('SC6')
SC6->(DbGoTop())
SC6->(DbSetOrder(1))
If IsInCallStack("A410Deleta")
	Set Deleted OFF
Else
	Set Deleted ON
EndIf

If SC6->(DbSeek(xFilial("SC6")+M->C5_NUM))
	
	While SC6->C6_NUM == M->C5_NUM
		
		cHtml+="					<tr style='mso-yfti-irow:1'>"
		cHtml+="						<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
		cHtml+="							<p class=MsoNormal>"
		cHtml+= TipoString(8.5,1)
		cHtml+="					"+ALLTRIM(SC6->C6_PRODUTO)+"<o:p></o:p>"
		cHtml+="								</span>"
		cHtml+="							</p>"
		cHtml+="						</td>"
		cHtml+="						<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
		cHtml+="							<p class=MsoNormal>"
		cHtml+= TipoString(8.5,1)
		cHtml+="				"+ALLTRIM(SC6->C6_DESCRI)+"<o:p></o:p>"
		cHtml+="							</span>"
		cHtml+="						</p>"
		cHtml+="					</td>"
		cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
		cHtml+="						<p class=MsoNormal>"
		cHtml+= TipoString(8.5,1)
		cHtml+="					"+ALLTRIM(cValToChar(SC6->C6_QTDVEN))+"<o:p></o:p>"
		cHtml+="							</span>"
		cHtml+="						</p>"
		cHtml+="					</td>"
		cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
		cHtml+="						<p class=MsoNormal>"
		cHtml+= TipoString(8.5,1)
		cHtml+="					"+ALLTRIM(Transform(SC6->C6_PRCVEN,"@E 99,999,999.99"))+"<o:p></o:p>"
		cHtml+="							</span>"
		cHtml+="						</p>"
		cHtml+="					</td>"
		cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
		cHtml+="						<p class=MsoNormal>"
		cHtml+= TipoString(8.5,1)
		cHtml+="					"+ALLTRIM(Transform(SC6->C6_VALOR,"@E 99,999,999.99"))+"<o:p></o:p>"
		cHtml+="							</span>"
		cHtml+="						</p>"
		cHtml+="					</td>"
		cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt';color:red>"
		cHtml+="						<p class=MsoNormal>"
		
		If IsInCallStack("A410Inclui")
			cHtml+= TipoString(8.5,4)
			cHtml+=" Incluido <o:p></o:p>"
		ElseIf IsInCallStack("A410Copia ")
			cHtml+= TipoString(8.5,4)
			cHtml+="Incluido <o:p></o:p>"
		ElseIf IsInCallStack("A410Altera")
			cHtml+= TipoString(8.5,4)
			cHtml+="Alterado <o:p></o:p>"
		ElseIf IsInCallStack("A410Deleta")
			cHtml+= TipoString(8.5,3)
			cHtml+="Deletado <o:p></o:p>"
		EndIf
		
		cHtml+="								</span>"
		cHtml+="							</p>"
		cHtml+="						</td>"
		cHtml+="					</tr>
		
		SC6->(DbSkip())
		
	EndDo
	
EndIf

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

Set Deleted ON

Return cHtml

/*
Funcao      : TipoString
Objetivos   :
Autor       : Tiago Luiz Mendonça
Data/Hora   : 30/06/2014
*/
*----------------------------------------*
Static Function TipoString(nTam,nColor)
*-----------------------------------------*

Local cAux:=""

cAux:="<span style='font-size:"+Alltrim(Str(nTam))+"pt;font-family:"
cAux+='"Verdana","sans-serif"'
cAux+=";mso-fareast-font-family:"
cAux+='"Times New Roman"'
cAux+=";color:"
If nColor==1
	cAux+=";color:Black'>"
ElseIf  nColor==2
	cAux+=";color:White'>"
ElseIf  nColor==3
	cAux+=";color:Red'>"
ElseIf  nColor==4
	cAux+=";color:Green'>"
EndIf


Return cAux

