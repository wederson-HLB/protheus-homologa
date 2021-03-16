#include "rwmake.ch"
#include "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "totvs.ch"   

#define STATUS_ABERTON1 "1"
#define STATUS_CONCLUIDO "2"
#define STATUS_CANCELADO "3"
#define STATUS_ATENDIMENTO "4"
#define STATUS_RETORNO "5"  
#define STATUS_ABERTON2 "7"

#define MOV_ABERTURA "A"
#define MOV_COMPLEMENTO "C"
#define MOV_CANCELAMENTO "N"
#define MOV_CHECKINN1 "I"
#define MOV_CHECKINN2 "J"
#define MOV_RETORNO "R"
#define MOV_SOLUCAO "S"
#define MOV_REABERTURA "E" 
#define MOV_TRANSFERENCIA "X"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDW001  ºAutor  Tiago Luiz Mendonça  º Data ³  20/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de cadastro de atendentes                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDW001()
Objetivos   : Rotina de workflow
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/
*--------------------------------*
User Function GTHDW001(cNum,cTipo)
*--------------------------------*
Local cHtml     := ""
Local cOcorre   := ""
Local cNomeEmp  := ""

Local aUsers    := AllUsers()
Local bFilZ01   := {|| }
Local cFilZ01   := Z01->(DbFilter())

Private cEmail    := ""    
Private lReenvio  := .F. 
Private lCheckIn  := .F.
             
//Tipo de reenvio
If cTipo=="#"
	lReenvio := .T.
    cTipo := Z01->Z01_TIPO
EndIf

//Retira o filtro da tabela Z01.
If !Empty(cFilZ01)
	bFilZ01 := {|| &(cFilZ01)}
	Z01->(dbClearFilter())
EndIf      
 
//Não será enviado e-mail de Check IN
If cTipo == MOV_CHECKINN1 .or. cTipo == MOV_CHECKINN2 .or. cTipo == MOV_TRANSFERENCIA
	lCheckIn :=.T.
EndIf
	
Z01->(DbSetOrder(1))
If !(Z01->(DbSeek(xFilial("Z01")+cNum)))
	MsgInfo("Problema no envio do e-mail, entrar em contato com TI.(erro:Z01_CODIGO)","Grant Thornton")
	BeforeRet(bFilZ01,cFilZ01)
    Return .F.
EndIF 

SX5->(DbSetOrder(1))
If !SX5->(DbSeek(xFilial("SX5")+"Z1"+Z01->Z01_OCORRE)) 
	MsgInfo("Problema no envio do e-mail, entrar em contato com TI.(erro:Z01_OCORRE)","Grant Thornton")
	BeforeRet(bFilZ01,cFilZ01)
	Return .F.			
Else
	cOcorre:=AllTrim(SX5->X5_DESCRI)
EndIf   

If Z01->Z01_TIPO == "C"
	Z04->(DbSetOrder(1))
	If !(Z04->(DbSeek(xFilial("Z04")+Z01->Z01_CODEMP+Z01->Z01_FILEMP)) )
		MsgInfo("Problema no envio do e-mail, entrar em contato com TI.(erro:Z01_CODEMP)","Grant Thornton")
		BeforeRet(bFilZ01,cFilZ01)
		Return .F.			
	Else
		cNomeEmp:= AllTrim(Z04->Z04_NOME)+" / "+AllTrim(Z04->Z04_NOMFIL)
	EndIf       	
Else
	cNomeEmp:= "TODAS AS EMPRESAS"
EndIf

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
cHtml+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
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
cHtml+="										CHAMADO: "+Alltrim(cNum)+"&nbsp;&nbsp;&nbsp;&nbsp;POSIÇÃO: "+Alltrim(RetStatus(Z01->Z01_STATUS))        //%cStatus%<o:p></o:p>
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
cHtml+="									Empresa:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+Alltrim(cNomeEmp)	//%cNomeEmp% 
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Código:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+Alltrim(Z01->Z01_CODEMP) 	//%cNomeEmp% 
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									E-mail:"
cHtml+="								</span>	"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)   
cHtml+="									"+Alltrim(Z01->Z01_EMAIL) //%cEmail%" 
cEmail:=Alltrim(Z01->Z01_EMAIL)
cHtml+="								</span>"
cHtml+="							</td>" 
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									Telefone: "
cHtml+="								</span>"	
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+Substr(Alltrim(Z01->Z01_TEL),1,4)+"-"+Substr(Alltrim(Z01->Z01_TEL),5,4) //%cTel%"
cHtml+="								</span>" 
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									Ramal: "
cHtml+="								</span>"	
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="								   "+Alltrim(Z01->Z01_RAMAL) //	%cRamal%"
cHtml+="								</span>" 
cHtml+="							</td>"
cHtml+="						</tr>"  
cHtml+='						<tr bgcolor="#FCFCFC">' 
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									Tipo Problema: "
cHtml+="								</span>"	
cHtml+="							</td> "
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									"+Alltrim(cOcorre) //%cProblema%"
cHtml+="								</span>"	
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									Módulo: "
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)                                        
If Alltrim(Z01->Z01_MODULO)=="SPE"
	cHtml+="SPED"			   
ElseIf Alltrim(Z01->Z01_MODULO)=="999"
	cHtml+="Específico"							   
Else
	cHtml+="								   "+Alltrim(Z01->Z01_MODULO)   //	%cModulo%"
EndIf
cHtml+="								</span>	"
cHtml+="							</td>"
cHtml+="						</tr>"
cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="						</tr>"      
					 
cHtml+='						<tr bgcolor="#FCFCFC">' 
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									Contato:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+Alltrim(USRRETNAME(Z01->Z01_CODUSR))  //%cContato% 
cHtml+="								</span>"
cHtml+="							</td>" 
cHtml+="						</tr>"   
cHtml+="						<tr>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									<Br><B>Resumo"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									<Br>"+Z01->Z01_RESUMO                    //%cResumo%
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="						</tr>"

cHtml+="						<tr>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									<Br><B>Incidente"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									<Br>"+Z01->Z01_SOLICI                    //%cIcidente%
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
cHtml+="									It.<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Anexo<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Ocorr.<o:p></o:p>"
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
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Contato<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									An. Alocado <o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Dt. Ocorr. <o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"
                                                         
Z02->(DbGoTop())  
Z02->(DbSetOrder(1))
If !(Z02->(DbSeek(xFilial("Z02")+cNum)))
	MsgInfo("Problema no envio do e-mail, entrar em contato com TI.(Z02)","Grant Thornton")
	BeforeRet(bFilZ01,cFilZ01)
    Return .F.
EndIf

While Z02->(!EOF()) .And. cNum == Z02->Z02_CODIGO     
	If (Alltrim(Z02->Z02_TIPO) == MOV_CHECKINN1 .or. Alltrim(Z02->Z02_TIPO) == MOV_CHECKINN2 .or. Alltrim(Z02->Z02_TIPO) == MOV_TRANSFERENCIA) ;
		.and. !lCheckIn
		Z02->(DbSkip())
		Loop
	EndIf

	cHtml+="				<tr style='mso-yfti-irow:1'>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(Z02->Z02_ITEM)+"<o:p></o:p>"	 //%a.cItem%
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	If Empty(Alltrim(Z02->Z02_ARQUIV))
		cHtml+="								"+"Nao"+"<o:p></o:p>"    //%a.cArea%
	Else
   		cHtml+="								"+"Sim"+"<o:p></o:p>"    //%a.cArea%
	EndIf	
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(RetMovim(Z02->Z02_TIPO))+"<o:p></o:p>"      //%a.cOcorrencia%
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(Z02->Z02_DESCRI)+"<o:p></o:p>"   //%a.cDescricao%
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(USRRETNAME(Z02->Z02_CODUSR))+"<o:p></o:p>"     //%a.cContato%
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(USRRETNAME(Z02->Z02_CODUSR))+"<o:p></o:p>"   //%a.cAnaAlocado%<o:p></o:p>
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(DTOC(Z02->Z02_DATA))+" "+Alltrim(Z02->Z02_HORA)+"<o:p></o:p>"  //%a.cData%<o:p></o:p>
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="				</tr>"
	Z02->(DbSkip())
EndDo       

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
cHtml+="						GRANT THORNTON - Mensagem automática, favor não responder este e-mail."
cHtml+="				</span>"
cHtml+="			</span>"
cHtml+="		</p>"
cHtml+="    </td>"
cHtml+="</tr>"

cHtml+="</body>"

cHtml+="</html>"

oEmail          :=  DEmail():New()
oEmail:cFrom   	:= 'totvs@br.gt.com'
oEmail:cTo		:= RetToMail(cTipo)
If cTipo == MOV_ABERTURA .or. cTipo == MOV_REABERTURA
	oEmail:cBCC	:= RetToMail("LIDER_N1")
EndIF
oEmail:cSubject	:= "Chamado "+Alltrim(cNum) + " - " + AllTrim(Capital(RetStatus(Z01->Z01_STATUS)))
oEmail:cBody   	:= 	cHtml
oEmail:Envia()
 
//Restaura o filtro
If !Empty(cFilZ01)
	Z01->(DbSetFilter(bFilZ01,cFilZ01))
EndIf

Return
 
/*
Funcao      : BeforeRet
Objetivos   : Função executada antes de uma chamada de return na funçaõ principal.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/
*--------------------------*
Static Function BeforeRet(bFilZ01,cFilZ01)
*--------------------------*

//Restaura o filtro
If !Empty(cFilZ01)
	Z01->(DbSetFilter(bFilZ01,cFilZ01))
EndIf

Return .T. 

/*
Funcao      : RetStatus
Objetivos   : Retorna o status da capa do chamado.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/
*---------------------------------*
Static Function RetStatus(cTipo)
*---------------------------------* 
Local cRet:=""  
     
If cTipo==STATUS_ABERTON1
	cRet:="ABERTURA N1"
ElseIf cTipo==STATUS_ABERTON1
	cRet:="ABERTURA N2"
ElseIf cTipo==STATUS_CONCLUIDO
	cRet:="SOLUCIONADO"
ElseIf cTipo==STATUS_CANCELADO
	cRet:="CANCELADO"
ElseIf cTipo==STATUS_ATENDIMENTO
	cRet:="EM ATENDIMENTO" 
ElseIf cTipo==STATUS_RETORNO
	cRet:="AGUARDANDO RETORNO"
EndIf		

Return cRet   

/*
Funcao      : RetMovim
Objetivos   : Retorna a movimentação dos itens do chamado.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/
*-----------------------------*
Static Function RetMovim(cTipo)
*-----------------------------* 
Local cRet:=""   
           
If cTipo==MOV_ABERTURA
	cRet:="Abertura"
ElseIf cTipo==MOV_COMPLEMENTO
	cRet:="Complemento"
ElseIf cTipo==MOV_CANCELAMENTO
	cRet:="Cancelamento"  
ElseIf cTipo==MOV_CHECKINN1
	cRet:="Check In N1"
ElseIf cTipo==MOV_CHECKINN2
	cRet:="Check In N2"
ElseIf cTipo==MOV_RETORNO
	cRet:="Retorno"	 
ElseIf cTipo==MOV_SOLUCAO
	cRet:="Solução"
ElseIf cTipo==MOV_REABERTURA
	cRet:="Reabertura"
ElseIf cTipo==MOV_TRANSFERENCIA
	cRet:="Transferencia"
EndIf  

Return cRet   
         
/*
Funcao      : TipoString
Objetivos   : Retorna o tamanho e cor da fonte do HTML
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/            
*-------------------------------------*
Static Function TipoString(nTam,nColor)
*-------------------------------------*
Local cAux:=""
      			     			
cAux:="<span style='font-size:"+Alltrim(Str(nTam))+"pt;font-family:"
cAux+='"Verdana","sans-serif"'
cAux+=";mso-fareast-font-family:"
cAux+='"Times New Roman"'
cAux+=";color:"+IIf(nColor==1,"Black","white")+"'>"
               
Return cAux

/*
Funcao      : RetToMail
Objetivos   : Retorna o email
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/      
*------------------------------*
Static Function RetToMail(cTipo)
*------------------------------*
Local nPos  
Local cRet   := ""       
Local aUsers :=AllUsers()

If cTipo == "LIDER_N1"
	//Procura todos os líderes N1
	Z03->(DbGoTop())
	While Z03->(!EOF())
		If AllTrim(Z03->Z03_TIPO) == "L"
        	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
		EndIf
		Z03->(DbSkip())	
	EndDo        
	Return cRet
EndIf


// Reenvio de email apenas para o que executa a rotina       
If lReenvio 
	nPos := ASCAN(aUsers,{|X| X[1,2] == cUserName})
	If nPos > 0
		cRet := Alltrim(aUsers[nPos,1,14]) 
	EndIf
Else
	If lCheckIn 		
		Z03->(DbSetOrder(1))
		If !Empty(Z01->Z01_CODATE)
		 	If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODATE))
		    	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
		    EndIf
		ElseIf !Empty(Z01->Z01_CODAT2)
   		 	If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODAT2))
		    	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
		    EndIf
		EndIf
	Else
		//Adiciona o e-mail do solicitante do chamado.
		cRet := Alltrim(UsrRetMail(Z01->Z01_CODUSR))
		cRet +=";"+Alltrim(cEmail)
		
		//Adiciona os endereços adicionais por movimentação.
		/*If cTipo == MOV_ABERTURA .or. cTipo == MOV_REABERTURA
			//Procura todos os líderes N1 e encaminha o e-mail
			Z03->(DbGoTop())
			While Z03->(!EOF())
				If AllTrim(Z03->Z03_TIPO) == "L"
		        	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
				EndIf
				Z03->(DbSkip())	
			EndDo
		ElseIf*/
		If 	cTipo == MOV_COMPLEMENTO 	.or.;
				cTipo == MOV_CANCELAMENTO 	.or.;
				cTipo == MOV_CHECKINN1		.or.; 
				cTipo == MOV_CHECKINN2		.or.;
				cTipo == MOV_TRANSFERENCIA
			Z03->(DbSetOrder(1))
			If !Empty(Z01->Z01_CODATE)
			 	If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODATE))
			    	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
			    EndIf
			ElseIf !Empty(Z01->Z01_CODAT2)
	   		 	If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODAT2))
			    	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
			    EndIf
			EndIf

		EndIf
	EndIf
    //Tratamento de envio de email quando for transferencia e que não teve analista responsavel ainda.
	If cTipo == MOV_TRANSFERENCIA .and. EMPTY(cRet)
		Do Case
			Case Z01->Z01_STATUS == STATUS_ABERTON1    
				//Procura todos os líderes N1 e encaminha o e-mail
				Z03->(DbGoTop())
				While Z03->(!EOF())
					If AllTrim(Z03->Z03_TIPO) == "L"
			        	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
					EndIf
					Z03->(DbSkip())	
				EndDo
	
			Case Z01->Z01_STATUS == STATUS_ABERTON2
				//Procura todos os líderes N2 e encaminha o e-mail
				Z03->(DbGoTop())
				While Z03->(!EOF())
					If AllTrim(Z03->Z03_TIPO) == "M"
			        	cRet += "; " + Alltrim(UsrRetMail(Z03->Z03_ID_PSS))
					EndIf
					Z03->(DbSkip())	
                EndDo
		End Case                              
	EndIf

EndIf

Return cRet      

/*
Funcao      : DE001Env
Objetivos   : Tratar o reenvio de email
Autor       : Tiago Luiz Mendonça
Data/Hora   : 14/07/2011
*/
*-----------------------*
User Function HDE001Env()
*-----------------------*

MsgInfo("Essa rotina envia email apenas para quem executou a rotina","Grant Thorton") 
                           
//Numero do chamado e tipo "#" para reenvio de email                               
U_GTHDW001(Z01->Z01_CODIGO,"#")

Return