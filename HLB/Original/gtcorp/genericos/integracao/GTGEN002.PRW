#Include "Protheus.ch"
#INCLUDE "ap5mail.ch"

/*
Funcao      : GTGEN002
Parametros  : cDest,aErros,nOpc,nEntSai
Retorno     : Nil
Objetivos   : Função utilizada para enviar e-mail para os gestores da área Financeira/Contabilidade com as informações do documento de entrada inserido no cliente.
Autor       : Matheus Massarotto
Data/Hora   : 25/04/2012    15:41
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*-----------------------------------------------*
User Function GTGEN002(cDest,aErros,nOpc,nEntSai)
*-----------------------------------------------*
CONOUT("Entrou no sendmail")
Private cSrv := GetMV("MV_RELSERV")  //ENDEREÇO DO SERVIDOR SMTP smtp.ig.com.br
Private cMail := GetMV("MV_RELACNT") //EMAIL                     meuemail@ig.com.br
Private cPass := GetMV("MV_RELPSW")  //SENHA DO EMAIL            123abc
Private lAuth := GetMv("MV_RELAUTH") //Requer Autenticação?
Private cPswA := GetMV("MV_RELAPSW") //SENHA DA AUTENTICAÇÃO     123abc
Private lResult := .T.

Private cHtmlAux:=""
Private cHtml:=""
Private lEntrou:=.F.

/*
for nCont:=1 to len(aErros)
	cHtmlAux+=" <tr>
	cHtmlAux+="   <td>"+IIF(empty(aErros[nCont][1]),"Ok","Erro")+"</td>
	cHtmlAux+="   <td>"+aErros[nCont][18]+"</td>
	cHtmlAux+="   <td>"+aErros[nCont][19]+"</td>
	cHtmlAux+="   <td>"+aErros[nCont][4]+"</td>
	cHtmlAux+="   <td>"+aErros[nCont][5]+"</td>
	cHtmlAux+="   <td>"+DTOC(aErros[nCont][11])+"</td>
	cHtmlAux+="   <td><div style='width:203px; overflow: auto;'>"+aErros[nCont][10]+"</div></td>
	cHtmlAux+="   <td>"+aErros[nCont][20]+"</td>
	cHtmlAux+="   <td>"+aErros[nCont][21]+"</td>        
	cHtmlAux+=" </tr>
next

cHtml+=" <table width='991' border='1' cellpadding='1' bordercolor='#000000'>
cHtml+="   <tr bgcolor='#CCCCCC'>
cHtml+="   <th width='68' scope='col'>Status</th>
cHtml+="   <th width='96' scope='col'>Empresa</th>
cHtml+="   <th width='55' scope='col'>Filial</th>
cHtml+="   <th width='122' scope='col'>Documento</th>
cHtml+="   <th width='58' scope='col'>Serie</th>
cHtml+="   <th width='91' scope='col'>Emissao</th>
cHtml+="   <th width='203' scope='col'>Descrição</th>
cHtml+="   <th width='120' scope='col'>Empresa Destino</th>
cHtml+="   <th width='120' scope='col'>Filial Destino</th>
cHtml+="  </tr>
cHtml+=cHtmlAux 
cHtml+=" </table>


*/


if nOpc==5
	SET DELETED OFF
endif


cHtml+=" <style type='text/css'>.MsgBody-text, .MsgBody-text * { font: 10pt monospace; }</style>
cHtml+=" <html xmlns='http://www.w3.org/TR/REC-html40'><head><title>Gt mail Notify</title><style><!--

/* Font Definitions */
cHtml+=" @font-face
cHtml+=" 	{font-family:Calibri;
cHtml+=" 	panose-1:2 15 5 2 2 2 4 3 2 4;}
cHtml+=" @font-face
cHtml+=" 	{font-family:Tahoma;
cHtml+=" 	panose-1:2 11 6 4 3 5 4 4 2 4;}
cHtml+=" @font-face
cHtml+=" 	{font-family:'Segoe UI';
cHtml+=" 	panose-1:2 11 5 2 4 2 4 2 2 3;}
cHtml+=" /* Style Definitions */
cHtml+=" p.MsoNormal, li.MsoNormal, div.MsoNormal
cHtml+=" 	{margin:0cm;
cHtml+=" 	margin-bottom:.0001pt;
cHtml+=" 	font-size:12.0pt;
cHtml+=" 	font-family:'Times New Roman','serif';}
cHtml+=" a:link, span.MsoHyperlink
cHtml+=" 	{mso-style-priority:99;
cHtml+=" 	color:blue;
cHtml+=" 	text-decoration:underline;}
cHtml+=" a:visited, span.MsoHyperlinkFollowed
cHtml+=" 	{mso-style-priority:99;
cHtml+=" 	color:purple;
cHtml+=" 	text-decoration:underline;}
cHtml+=" p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
cHtml+=" 	{mso-style-priority:99;
cHtml+=" 	mso-style-link:'Texto de balco Char';
cHtml+=" 	margin:0cm;
cHtml+=" 	margin-bottom:.0001pt;
cHtml+=" 	font-size:8.0pt;
cHtml+=" 	font-family:'Tahoma','sans-serif';}
cHtml+=" p.style1, li.style1, div.style1
cHtml+=" 	{mso-style-name:style1;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:12.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';}
cHtml+=" p.style2, li.style2, div.style2
cHtml+=" 	{mso-style-name:style2;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:12.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';
cHtml+=" 	color:red;}
cHtml+=" p.style21, li.style21, div.style21
cHtml+=" 	{mso-style-name:style2;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:12.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';
cHtml+=" 	color:black;}
cHtml+=" p.style3, li.style3, div.style3
cHtml+=" 	{mso-style-name:style3;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:10.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';
cHtml+=" 	color:#254061;}
cHtml+=" p.style31, li.style3, div.style3
cHtml+=" 	{mso-style-name:style3;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:10.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';
cHtml+=" 	font-weight: bold;
cHtml+=" 	color:red;}
cHtml+=" p.style32, li.style32, div.style32
cHtml+=" 	{mso-style-name:style32;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:10.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';
cHtml+=" 	font-weight: bold;
cHtml+=" 	color: #FFF;}
cHtml+=" p.style4, li.style4, div.style4
cHtml+=" 	{mso-style-name:style4;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:8.0pt;
cHtml+=" 	font-family:'Segoe UI','sans-serif';
cHtml+=" 	color:#254061;}
cHtml+=" p.style5, li.style5, div.style5
cHtml+=" 	{mso-style-name:style5;
cHtml+=" 	mso-margin-top-alt:auto;
cHtml+=" 	margin-right:0cm;
cHtml+=" 	mso-margin-bottom-alt:auto;
cHtml+=" 	margin-left:0cm;
cHtml+=" 	font-size:10.0pt;
cHtml+=" 	font-family:'Times New Roman','serif';}
cHtml+=" span.EstiloDeEmail22
cHtml+=" 	{mso-style-type:personal-reply;
cHtml+=" 	font-family:'Calibri','sans-serif';
cHtml+=" 	color:#1F497D;}
cHtml+=" span.TextodebaloChar
cHtml+=" 	{mso-style-name:'Texto de balco Char';
cHtml+=" 	mso-style-priority:99;
cHtml+=" 	mso-style-link:'Texto de balco';
cHtml+=" 	font-family:'Tahoma','sans-serif';}
cHtml+=" .MsoChpDefault
cHtml+=" 	{mso-style-type:export-only;
cHtml+=" 	font-size:10.0pt;}
cHtml+=" @page WordSection1
cHtml+=" 	{size:612.0pt 792.0pt;
cHtml+=" 	margin:70.85pt 3.0cm 70.85pt 3.0cm;}
cHtml+=" div.WordSection1
cHtml+=" 	{page:WordSection1;}
cHtml+=" --></style>
cHtml+=" </head>

cHtml+=" <body lang='PT-BR'>
cHtml+=" <div class='WordSection1'>

nHora:=VAL(SUBSTR(TIME(),1,2))
         
cHtml+="<p class='style21' style='text-align:justify'>"+IIF(nHora<6,"Boa noite!",IIF(nHora<12,"Bom dia!",IIF(nHora<18,"Boa tarde!","Boa noite!")))+"</p>"
cHtml+="<br><p class='style21' style='text-align:justify'>"+IIF(empty(aErros[1][1]),"Foi(ram) "+IIF(nOpc==3,"incluída","excluída")+"(s) automaticamente a(s) nota(s)/nd(s) abaixo, por favor verifique.","Ocorreu um erro na "+IIF(nOpc==3,"inclusão","exclusão")+" automática de nota/nd, favor verificar o campo observações, caso necessário abrir chamado!")+"</p>"
 
//cHtml+=" <table class='MsoNormalTable' border='0' cellpadding='0' style='background:#CCCCFF'>
cHtml+=" <table class='MsoNormalTable' border='0' cellpadding='0' >
cHtml+=" <tr>
cHtml+=" <td style='padding:.75pt .75pt .75pt .75pt'>

for nCont:=1 to len(aErros)
conout("Len aErros: "+cvaltochar(len(aErros)))

if nEntSai==1

DbSelectArea("SF1")
DbSetOrder(1)
CONOUT("Posicao3-"+valtype(aErros[nCont][3])+", posicao4-"+valtype(aErros[nCont][4])+", posicao5-"+valtype(aErros[nCont][5])+",posicao22-"+valtype(aErros[nCont][22])+",posicao23-"+valtype(aErros[nCont][23]) )
DbSeek(aErros[nCont][3]+aErros[nCont][4]+aErros[nCont][5]+aErros[nCont][26]+aErros[nCont][27])

While SF1->(!EOF()) .AND. SF1->F1_FILIAL==aErros[nCont][3] .AND. SF1->F1_DOC==aErros[nCont][4] .AND. SF1->F1_SERIE==aErros[nCont][5] .AND. SF1->F1_FORNECE==aErros[nCont][26] .AND. SF1->F1_LOJA==aErros[nCont][27] .AND. !lEntrou
lEntrou:=.T.
//cHtml+="         <table width='1200' height='49' border='1' cellpadding='1'>
//cHtml+="           <tr>
//cHtml+="             <td width='560'><p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'></p>

cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Status:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+IIF(empty(aErros[nCont][1]),IIF(nOpc==3,"Inserido","Excluido"),"Erro")+"</p>
cHtml+="     </tr>
cHtml+="     </table>
cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Empresa Origem:</p>
cHtml+="     </td>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+aErros[nCont][18]+" - "+aErros[nCont][24]+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Empresa Destino:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+aErros[nCont][20]+" - "+aErros[nCont][25]+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     </table>

cHtml+="     <br>

cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Nota:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SF1->F1_DOC+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Série:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SF1->F1_SERIE+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Espécie:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SF1->F1_ESPECIE+"</p>
cHtml+="     </td>
cHtml+="     </tr>    
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Emissão:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+DTOC(SF1->F1_EMISSAO)+"</p>
cHtml+="     </td>
cHtml+="     </tr>    
cHtml+="     </table>

cHtml+="     <br>

cHtml+="     <div style='overflow: auto; height: 100; width: 550pt'>
cHtml+="    	<table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="    	<tr>
cHtml+="    	<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Produto</p>
cHtml+="    	</td>
cHtml+="    	<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Descrição</p>
cHtml+="    	</td>
cHtml+="		<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Quantidade</p>
cHtml+="    	</td>
cHtml+="		<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Valor Unitário</p>
cHtml+="    	</td>
cHtml+="		<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Valor Total</p>
cHtml+="    	</td>
cHtml+="    	</tr>

cHtmlAux:=""
DbSelectArea("SD1")
DbSetOrder(1)
DbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
CONOUT("--->>D1: "+SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA )
While SD1->(!EOF()) .AND. SD1->D1_FILIAL==SF1->F1_FILIAL .and. SD1->D1_DOC==SF1->F1_DOC .and. SD1->D1_SERIE==SF1->F1_SERIE .and. SD1->D1_FORNECE==SF1->F1_FORNECE .and. SD1->D1_LOJA==SF1->F1_LOJA
	cHtmlAux+="    	<tr>
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+SD1->D1_COD+"</p>

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD1->D1_COD)
	
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+alltrim(SB1->B1_DESC)+"</p>
	
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+CVALTOCHAR(SD1->D1_QUANT)+"</p>
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+CVALTOCHAR(SD1->D1_VUNIT)+"</p>
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+CVALTOCHAR(SD1->D1_TOTAL)+"</p>                
	cHtmlAux+= "   	</tr>
	SD1->(DbSkip())
enddo
cHtml+=cHtmlAux
cHtml+="    	</table>
cHtml+="    </div>

cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td colspan='2' width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Cliente/Fornecedor:</p>
cHtml+="     </td>

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)

cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>Código:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA2->A2_COD+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>Loja:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA2->A2_LOJA+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'' style='text-align:justify'>Razão Social:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA2->A2_NOME+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>CNPJ/CPF:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA2->A2_CGC+"</p>
cHtml+="     </td>
cHtml+="     </tr>

cHtml+="     </table>

cHtml+="     <br>
cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='550' style='width:550.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Observações:</p>
cHtml+="     </td>
cHtml+="     </tr>
for nI:=1 to len(aErros)
	cHtml+="     <tr>
	cHtml+="     <td width='550' style='width:550.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3"+IIF(!empty(alltrim(aErros[nI][1])),"1","")+"' style='text-align:justify'>"+STRTRAN(aErros[nI][10],CRLF," ")+"</p>
	cHtml+="     </td>
	cHtml+="     </tr>
next

//cHtml+="     </td>

//cHtml+="     </tr>

//cHtml+="     </table>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     </table><p class='MsoNormal'>&nbsp;</p>


	SF1->(DbSkip())
enddo
//Se for nOpc==5
else

DbSelectArea("SF2")
DbSetOrder(1)
CONOUT("Posicao3-"+valtype(aErros[nCont][3])+", posicao4-"+valtype(aErros[nCont][4])+", posicao5-"+valtype(aErros[nCont][5])+",posicao22-"+valtype(aErros[nCont][22])+",posicao23-"+valtype(aErros[nCont][23]) )
DbSeek(aErros[nCont][3]+aErros[nCont][4]+aErros[nCont][5]+aErros[nCont][22]+aErros[nCont][23])

While SF2->(!EOF()) .AND. SF2->F2_FILIAL==aErros[nCont][3] .AND. SF2->F2_DOC==aErros[nCont][4] .AND. SF2->F2_SERIE==aErros[nCont][5] .AND. SF2->F2_CLIENTE==aErros[nCont][22] .AND. SF2->F2_LOJA==aErros[nCont][23] .AND. !lEntrou
lEntrou:=.T.

//cHtml+="         <table width='1200' height='49' border='1' cellpadding='1'>
//cHtml+="           <tr>
//cHtml+="             <td width='560'><p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'></p>

cHtml+="     <p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'>&nbsp;</p>
cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Status:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+IIF(empty(aErros[nCont][1]),IIF(nOpc==3,"Inserido","Excluido"),"Erro")+"</p>
cHtml+="     </tr>
cHtml+="     </table>
cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Empresa Origem:</p>
cHtml+="     </td>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+aErros[nCont][18]+" - "+aErros[nCont][24]+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Empresa Destino:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+aErros[nCont][20]+" - "+aErros[nCont][25]+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     </table>
cHtml+="     <p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'>&nbsp;</p>

cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Nota:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SF2->F2_DOC+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Série:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SF2->F2_SERIE+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Espécie:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SF2->F2_ESPECIE+"</p>
cHtml+="     </td>
cHtml+="     </tr>    
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Emissão:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+DTOC(SF2->F2_EMISSAO)+"</p>
cHtml+="     </td>
cHtml+="     </tr>    
cHtml+="     </table>
cHtml+="     <p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'>&nbsp;</p>
cHtml+="     <div style='overflow: auto; height: 100; width: 550pt'>
cHtml+="    	<table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="    	<tr>
cHtml+="    	<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Produto</p>
cHtml+="    	</td>
cHtml+="    	<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Descrição</p>
cHtml+="    	</td>
cHtml+="		<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Quantidade</p>
cHtml+="    	</td>
cHtml+="		<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Valor Unitário</p>
cHtml+="    	</td>
cHtml+="		<td width='110.0' style='width:110.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32'>Valor Total</p>
cHtml+="    	</td>
cHtml+="    	</tr>

cHtmlAux:=""
DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

While SD2->(!EOF()) .AND. SD2->D2_FILIAL==SF2->F2_FILIAL .and. SD2->D2_DOC==SF2->F2_DOC .and. SD2->D2_SERIE==SF2->F2_SERIE .and. SD2->D2_CLIENTE==SF2->F2_CLIENTE .and. SD2->D2_LOJA==SF2->F2_LOJA
	cHtmlAux+="    	<tr>
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+SD2->D2_COD+"</p>

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD2->D2_COD)
	
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+alltrim(SB1->B1_DESC)+"</p>
	
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+CVALTOCHAR(SD2->D2_QUANT)+"</p>
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+CVALTOCHAR(SD2->D2_PRCVEN)+"</p>
	cHtmlAux+="    	<td width='110.0' style='width:110.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'>"+CVALTOCHAR(SD2->D2_TOTAL)+"</p>
	cHtmlAux+= "   	</tr>
	SD2->(DbSkip())
enddo
cHtml+=cHtmlAux
cHtml+="    	</table>
cHtml+="    </div>
cHtml+="     <p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'>&nbsp;</p>
cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td colspan='2' width='200' style='width:200.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Cliente/Fornecedor:</p>
cHtml+="     </td>

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>Código:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA1->A1_COD+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>Loja:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA1->A1_LOJA+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3'' style='text-align:justify'>Razão Social:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA1->A1_NOME+"</p>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     <tr>
cHtml+="     <td width='200' style='width:200.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>CNPJ/CPF:</p>
cHtml+="     </td>
cHtml+="     <td width='350' style='width:350.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3' style='text-align:justify'>"+SA1->A1_CGC+"</p>
cHtml+="     </td>
cHtml+="     </tr>

cHtml+="     </table>

cHtml+="     <p class='MsoNormal' style='margin-bottom:12.0pt;text-align:justify'>&nbsp;</p>
cHtml+="     <table class='MsoNormalTable' border='0' cellpadding='0' id='total'>
cHtml+="     <tr>
cHtml+="     <td width='550' style='width:550.0pt;background:#A895CC;padding:.75pt .75pt .75pt .75pt'><p class='style32' style='text-align:justify'>Observações:</p>
cHtml+="     </td>
cHtml+="     </tr>

for nI:=1 to len(aErros)
	cHtml+="     <tr>
	cHtml+="     <td width='550' style='width:550.0pt;background:#D4BBFD;padding:.75pt .75pt .75pt .75pt'><p class='style3"+IIF(!empty(alltrim(aErros[nI][1])),"1","")+"' style='text-align:justify'>"+STRTRAN(aErros[nI][10],CRLF," ")+"</p>
	cHtml+="     </td>
	cHtml+="     </tr>
next
//cHtml+="     </td>

//cHtml+="     </tr>

//cHtml+="     </table>
cHtml+="     </td>
cHtml+="     </tr>
cHtml+="     </table><p class='MsoNormal'>&nbsp;</p>



	SF2->(DbSkip())
enddo

endif

next

//cHtml+=" <p class='MsoNormal'>&nbsp;</p>
//cHtml+="	<table class='MsoNormalTable' border='0' cellpadding='0' style='background:#E6E6E6'>
//cHtml+=" 		<tr>
//cHtml+=" 			<td width='550' style='width:550.0pt;padding:9.0pt 9.0pt 9.0pt 9.0pt'><p class='style2' style='text-align:justify'>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.</p>
//cHtml+="    		</td>
//cHtml+="    	</tr>

cHtml+=" 	</table>
cHtml+="<p class='style21' style='text-align:justify'>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.</p>
cHtml+="     </div>
cHtml+=" </body>
cHtml+=" </html>


if nOpc==5
	SET DELETED ON
endif


CONNECT SMTP SERVER cSrv;     //Nome do servidor SMTP
ACCOUNT cMail;   //Conta de Email
PASSWORD cPass;  //Senha de conexão
RESULT lResul    //Resultado da Conexão

if !lResult
	GET MAIL ERROR cError
	Conout("=====> FALHA NA CONEXAO SMTP: "+cError)
ENDIF

lResult := .t.
if lAuth
	lResult := MailAuth(cmail,cPass)
endif

if !lResult
	GET MAIL ERROR cError
	Conout("=====> FALHA NA AUTENTICACAO: "+cError)
ENDIF

lResult := .t.

	SEND MAIL FROM cMail ;
	TO cDest;
	BCC "matheus.massarotto@br.gt.com";
	SUBJECT IIF(nOpc==3,"Inclusao","Exclusao")+" automatica de "+"fatura"+" Grant Thornton, Cliente: "+alltrim(aErros[1][25])+IIF(empty(aErros[1][1]),""," - (ERRO)")  ;
	BODY cHtml;
	RESULT lResult := .t.

if !lResult
	GET MAIL ERROR cError
	Conout("=====> FALHA NO ENVIO: "+cError)
ENDIF

//Desconecta do servidor
DISCONNECT SMTP SERVER

RETURN

