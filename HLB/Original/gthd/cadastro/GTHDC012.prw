#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : GTHDC012
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Controle de Acesso aos Repositorios de emergencia.
Autor       : Jean Victor Rocha	
Data/Hora   : 14/01/2014
*/
*----------------------*
User Function GTHDC012()
*----------------------*                                                                  
Local cRegraVerd := "(Z14->Z14_DTINI <= dDataBase .and. dDataBase <= Z14->Z14_DTFIM) .or. (Z14->Z14_DTINI <= dDataBase .and. EMPTY(Z14->Z14_DTFIM))"
Local cRegraVerm := "Z14->Z14_DTFIM < dDataBase"
Local cRegraBran := "(Z14->Z14_DTINI > dDataBase)"
Local aCores    := {{cRegraVerd,"BR_VERDE"   },; //Disponivel
					{cRegraVerm,"BR_VERMELHO"},;//Experirado
					{cRegraBran,"BR_BRANCO"}}//Pendente

Private cCadastro  := "Controle de Acesso Emergencial"
Private aIndexZ14 := {}
Private aRotina	  := {}

aAdd(aRotina, { "Pesquisar"		,"AxPesqui"  , 0, 1})
aAdd(aRotina, { "Visualizar"	,"AxVisual"  , 0, 2})
aAdd(aRotina, { "Incluir"		,"U_HDC012I" , 0, 3})
aAdd(aRotina, { "Finalizar"		,"U_HDC012F" , 0, 4})
aAdd(aRotina, { "Legenda"		,"U_HDC012L" , 0, 6})

//Filtro para exibição dos chamados.
U_HDC012Fil(.F.,"Z14",@aIndexZ14)

//Define a tecla F12 para chamar a tela de filtro.
SetKey(VK_F12,{|| U_HDC012Fil(.T.,"Z14",@aIndexZ14)} )

//Exibe o browse.
mBrowse( 6,1,22,75,"Z14",,,,,,aCores)

Return .T.

/*
Funcao      : HDC012I
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Nova Solicitação.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*--------------------------------------*
USer Function HDC012I(cAlias,nReg,nOpc)
*---------------------------------------*
Local nOpca := 0

Local aCpos     := {}
Local aCposEdit := {}
Local aCposNot  := {}
Local aButtons	:= {}
Local aParam    := {}

//Define os campos que não serão exibidos na tela
aCposNot := {}

//Carrega os campos que serão exibidos na tela (capa).
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If !(SX3->X3_CAMPO $ Right(cAlias,2)+"_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		If aScan(aCposNot,AllTrim(SX3->X3_CAMPO)) == 0
			aAdd(aCpos,SX3->X3_CAMPO)
		EndIf
	EndIf		 
	SX3->(DbSkip())
EndDo

aAdd(aCpos,"NOUSER")

//Define os campos que serão editaveis
aCposEdit := aClone(aCpos)

//Exibe a tela de inclusão
nOpca := AxInclui(cAlias,,3,aCpos,,aCposEdit,,,,aButtons,aParam,,,.T.)
               
If nOpca == 1 .and. MsgYesNo("Deseja Receber e-mail com o código de acesso?","Grant Thornton Brasil")
	cHtml := Email()
	oEmail          := DEmail():New()
	oEmail:cFrom   	:= "totvs@br.gt.com"
	oEmail:cTo		:= PADR(ALLTRIM(UsrRetMail(RetCodUsr())),400)
	oEmail:cSubject	:= padr("Autorizacao Ambiente Emergencial",200)
	oEmail:cBody   	:= cHtml
	oEmail:Envia()
EndIf

Return Nil      

/*                                                                    
Funcao      : HDC012F
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Cancelar atividade.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-------------------------------------*
USer Function HDC012F(cAlias,nReg,nOpc) 
*-------------------------------------*            
(cAlias)->(DbGoTo(nReg))              

If !EMPTY((cAlias)->Z14_DTFIM) .and. (cAlias)->Z14_DTFIM < dDataBase
	MsgInfo("Status não permite alteração","Grant Thornton Brasil.")
	Return .T.
EndIf

If MsgYesNo("Deseja Realmente Finalizar a Autorização selecionada?","Grant Thornton Brasil.")
	(cAlias)->(RecLock(cAlias,.F.))
	(cAlias)->Z14_DTFIM := dDataBase -1
	(cAlias)->(MsUnlock())
EndIf

Return .T.          


/*                                                                    
Funcao      : HDC012L
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Legenda
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------*
USer Function HDC012L() 
*---------------------*  
Local aLegenda := {	{"BR_VERDE"   ,"Disponivel"},;
		   			{"BR_VERMELHO","Expirado"},;
					{"BR_BRANCO"  ,"Pendente"}} 
				 	
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return .T.

/*
Funcao      : HDC012Fil
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Jean Victor Rocha
Data/Hora   :
*/
*------------------------------------------------*
User Function HDC012Fil(lExibe,cAlias,aIndexZ12)
*------------------------------------------------*

//Sem Filtro ate o momento

Return Nil


*---------------------*
Static Function Email()
*---------------------*
Local cHtml := ""

Z14->(DbGoTo(LastRec()))

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
cHtml+="										Autorizacao Ambiente Emergencial"
cHtml+="									</span></b>"
cHtml+="								</p>"
cHtml+="							</td>"
cHtml+="						</tr>"
cHtml+="					</table>"
cHtml+="				</div>"
cHtml+="				<div align=center>"
cHtml+="					<Br>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+="				   	</table>"
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
cHtml+="									Coldigo<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Dt.Inicial<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Dt.Final<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Motivo<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Ambiente / Repositorio<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Solicitante<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Cod.Acesso <o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"
	cHtml+="				<tr style='mso-yfti-irow:1'>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)                                             
	cHtml+="								"+ALLTRIM(Z14->Z14_CODIGO)+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)                 
	cHtml+="								"+Alltrim(DTOC(Z14->Z14_DTINI))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(DTOC(Z14->Z14_DTFIM))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(Z14->Z14_MOTIVO)+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	If Z14->Z14_AMB == "1"//1=P11       
		cHtml+="								P11_XX"+Alltrim(Z14->Z14_EMERG)+"<o:p></o:p>"
	ElseIf Z14->Z14_AMB == "2"//1=GTCORP
		cHtml+="								GTCORP11"+Alltrim(Z14->Z14_EMERG)+"<o:p></o:p>"
	EndIf
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(Z14->Z14_ATEND)+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(Z14->Z14_PASS)+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="				</tr>"
	Z12->(DbSkip())
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