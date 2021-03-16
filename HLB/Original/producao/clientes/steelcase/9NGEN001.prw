#INCLUDE "PROTHEUS.CH"
#INCLUDE "ap5mail.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"

/*
Funcao      : 9NGEN001
Parametros  : 
Retorno     : 
Objetivos   : Relatorio de poder de terceiros, considerando a Z97(PRAZOS POR CFO)
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------*
User Function 9NGEN001()     
*----------------------*
Private cPathSrv := Main()

Private cDirRmt  := AllTrim(GetTempPath())
Private cFile    := STRTRAN(UPPER(cPathSrv),"\ANEXOS\","")

If Empty(cPathSrv)
	MsgInfo("Falha na execução","HLB BRASIL")
	Return .F.
EndIf

LJMsgRun( "Processando arquivo...", NIL, {|| ProcHTM()} )
FERASE(cPathSrv)      

Return .T.

/*
Funcao      : Main
Parametros  : 
Retorno     : 
Objetivos   : Função principal
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------*
Static Function Main()
*--------------------*
Private nMin		:= 10 // maximo de dias para ser apresentado
Private cMail		:= ""
Private nRegs		:= 0
Private cQry		:= ""                     // VARIAVEL PARA QUERY
Private cData		:= DTOS(date())           // DATA ATUAL
Private lCarga		:= .f.                    // GEROU HTML
Private cMsg		:= ""                     // CORPO DO E-MAIL
Private lCor		:= .T.                    // SEMAFARO DE COR
Private aCor		:= {'rgb(244, 244,244)',' rgb(255, 204, 255)'} // COR DAS LINHAS
Private cCor		:= ""
Private nDias		:= 0
Private lCorpo		:= .T.
Private nArq, cArq	:= ""
Private cLin		:= ""
Private cQrw		:= ""

SX6->(DbSetOrder(1))
If !SX6->(DbSeek(xFilial("SX6")+"MV_P_00012") )
	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "MV_P_00012"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Emails de destino para envio Poder 3º"
	SX6->X6_CONTEUD := "monalisa.martins@hlb.com.br;priscila.santos@hlb.com.br;carla.oliveira@hlb.com.br;jefferson.bernardino@hlb.com.br;renata.melloni@hlb.com.br;diogo.braga@hlb.com.br"
	SX6->X6_PROPRI  := "U"
	SX6->(MsUnlock())
EndIf
cMail := GetMV("MV_P_00012")

cPerg:="9NGEN001"

PutSx1( cPerg, "01", "Produto De?" 		, "Produto De?", "Produto De?", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR01")
PutSx1( cPerg, "02", "Produto Ate?"		, "Produto Ate?", "Produto Ate?", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR02")
PutSx1( cPerg, "03", "Nota Fiscal de?"	, "Nota Fiscal de?", "Nota Fiscal de?", "", "C",09,00,00,"G","" , "SF2","","","MV_PAR03")
PutSx1( cPerg, "04", "Nota Fiscal Ate?"	, "Nota Fiscal Ate?", "Nota Fiscal Ate?", "", "C",09,00,00,"G","" , "SF2","","","MV_PAR04")
PutSx1( cPerg, "05", "Serie de?"   		, "Serie de?", "Serie de?", "", "C",03,00,00,"G","" , "","","","MV_PAR05")
PutSx1( cPerg, "06", "Serie Ate?"  		, "Serie Ate?", "Serie Ate?", "", "C",03,00,00,"G","" , "","","","MV_PAR06")
PutSx1( cPerg, "07", "Armazem de?" 		, "Armazem de?", "Armazem de?", "", "C",02,00,00,"G","" , "","","","MV_PAR07")
PutSx1( cPerg, "08", "Armazem Ate?"		, "Armazem Ate?", "Armazem Ate?", "", "C",02,00,00,"G","" , "","","","MV_PAR08")
PutSx1( cPerg, "09", "Cfop?"	  		, "Cfop?", "Cfop?", "", "C",99,00,00,"G","U_VaGTM002(MV_PAR09)" , "","","","MV_PAR09","","","","","","","","","","","","","","","","",{"Informe o codigo separado por ;","exemplo:","5912;6912"})
PutSx1( cPerg, "10", "Cliente de?" 		, "Cliente de?", "Cliente de?", "", "C",06,00,00,"G","" , "SA1","","","MV_PAR10")
PutSx1( cPerg, "11", "Cliente Ate?"		, "Cliente Ate?", "Cliente Ate?", "", "C",06,00,00,"G","" , "SA1","","","MV_PAR11")
PutSx1( cPerg, "12", "Fornecedor de?"	, "Fornecedor de?", "Fornecedor de?", "", "C",06,00,00,"G","" , "SA2","","","MV_PAR12")
PutSx1( cPerg, "13", "Fornecedor Ate?"	, "Fornecedor Ate?", "Fornecedor Ate?", "", "C",06,00,00,"G","" , "SA2","","","MV_PAR13")
PutSx1( cPerg, "14", "Prazo?"	  		, "Prazo?", "Prazo?", "", "C",50,00,00,"G","U_VaGTM002(MV_PAR14)" , "","","","MV_PAR14","","","","","","","","","","","","","","","","",{"Informe o codigo separado por ;","exemplo:","60;30"})
PutSx1( cPerg, "15", "Arquivo ?"  		, "Arquivo ?", "Arquivo ?", "", "N",01,00,00,"C","" , "","","","MV_PAR15","HTML","","","","EXCEL")
PutSx1( cPerg, "16", "Imp.Dev.Remessa?"	, "Imp.Dev.Remessa?", "Imp.Dev.Remessa?", "", "N",01,00,00,"C","" , "","","","MV_PAR16","Sim","","","","Nao")
Set Key VK_F7 TO U_GTM001()//Utiliza função de cadastro do fonte GTJ001.PRW

If !pergunte(cPerg,.T.,"Parâmetros                  <F7>")
	Return ""
EndIf

cProdDe		:= MV_PAR01
cProdAte	:= MV_PAR02
cNfDe		:= MV_PAR03
cNfAte		:= MV_PAR04
cSerieDe	:= MV_PAR05
cSerieAte	:= MV_PAR06
cArmDe		:= MV_PAR07
cArmAte		:= MV_PAR08
cCFO		:= MV_PAR09
cCliDe		:= MV_PAR10
cCliAte		:= MV_PAR11
cFornDe		:= MV_PAR12
cFornDAte	:= MV_PAR13
cPrazo		:= MV_PAR14
cArq		:= MV_PAR15
nImpDev		:= MV_PAR16



If EMPTY(cArq) .or. cArq==1
	cArq := LOWER("\ANEXOS\"+CRIATRAB(,.F.)+".HTML")
Else 
	cArq := LOWER("\ANEXOS\"+CRIATRAB(,.F.)+".XLS")
EndIf

MontaDIR("\ANEXOS")

If select("TRB") <> 0
	DbSelectArea("TRB")
	DbCloseArea("TRB")
EndIf
If select("TRD") <> 0
	DbSelectArea("TRD")
	DbCloseArea("TRD")
EndIf
If select("ITE") <> 0
	DbSelectArea("ITE")
	DbCloseArea("ITE")
EndIf                          

//Quantidade de itens, verifica se será necessario anexo.
cItens := " SELECT COUNT(*) QTD FROM "+RETSQLNAME("SB6")+" WHERE D_E_L_E_T_ = '' AND B6_SALDO > 0 "
DbUseArea( .T., "TOPCONN", TcGenqry( , , cItens), "ITE", .F., .F. )
TCSETFIELD("ITE","QTD","N",17,0)

If ITE->QTD > 0
	lCorpo	:= .F.
	nArq	:= fcreate(cArq,1)
Else
	lCorpo := .T.
EndIf

//Ajusta o conteúdo dos parametros para manter padrao '','',''
aContAux:=STRTOKARR(cPrazo,";")
cPrazo := ""
for j:=1 to len(aContAux)
	If !EMPTY(alltrim(aContAux[j]))
		cPrazo+="'"+alltrim(aContAux[j])+"',"
	EndIf
next        
cPrazo := LEFT(cPrazo,LEN(cPrazo)-1)

aContAux:={}
aContAux:=STRTOKARR(cCFO,";")
cCFO := ""
for j:=1 to len(aContAux)
	If !EMPTY(alltrim(aContAux[j]))
		cCFO+="'"+alltrim(aContAux[j])+"',"
	EndIf
next
cCFO := LEFT(cCFO,LEN(cCFO)-1)

//Carrega os parametros  
PODER3PR()

aTTT1 := GETLastQuery()
Memowrite("C:\RETORNO\sql1.txt",aTTT1[2])

PODER3PRD()

aTTT := GETLastQuery()
Memowrite("C:\RETORNO\sql.txt",aTTT[2])

lCarga := .F.


//Cabeçalho do HTML
cMsg := e_cab(lCorpo)

//Montagem de temporario para auxiliar na impressao por tipo nota
If select("TRBSTRU")>0
	TRBSTRU->(DbCloseArea())
EndIf
aStru:={}
AADD(aStru,{"ORIGEM"	,"C",10,0})
AADD(aStru,{"B6_DOC"	,"C",9,0})
AADD(aStru,{"B6_SERIE"	,"C",3,0})
AADD(aStru,{"B6_EMISSAO","D",8,0})
AADD(aStru,{"B6_SALDO"	,"N",12,2})
AADD(aStru,{"B6_QUANT"	,"N",11,2})
AADD(aStru,{"Z97_PRAZO"	,"N",4,0})
AADD(aStru,{"D2_COD"	,"C",15,0})
AADD(aStru,{"D2_QUANT"	,"N",11,2})
AADD(aStru,{"D2_LOCAL"	,"C",2,0})
AADD(aStru,{"D2_VALICM"	,"N",14,2})
AADD(aStru,{"D2_VALIPI"	,"N",14,2})
AADD(aStru,{"D2_CF"		,"C",6,0})
AADD(aStru,{"D2_TES"	,"C",3,0})
AADD(aStru,{"B1_COD"	,"C",15,0})
AADD(aStru,{"B1_DESC"	,"C",50,0})
AADD(aStru,{"F2_VALBRUT","N",14,2})
AADD(aStru,{"B6_IDENT"	,"C",6,0})
AADD(aStru,{"A1_CGC"	,"C",14,0})
AADD(aStru,{"A1_NREDUZ"	,"C",20,0})
AADD(aStru,{"B6_PRODUTO","C",15,0})
AADD(aStru,{"B6_LOCAL"	,"C",2,0})
AADD(aStru,{"D2_LOTECTL","C",10,0})
AADD(aStru,{"D2_DTVALID","D",8,0})
AADD(aStru,{"R_E_C_N_O_","N",20,0})
AADD(aStru,{"B6_PODER3"	,"C",1,0})
AADD(aStru,{"D2_TOTAL"	,"N",14,2})
AADD(aStru,{"F2_CLIENTE","C",06,0})
AADD(aStru,{"B6_CUSTO1" ,"N",14,2})

cArqTrb := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArqTrb,"TRBSTRU",.F.,.F.)
cArqInd := CriaTrab(Nil,.F.)
cChave := "R_E_C_N_O_"
IndRegua("TRBSTRU",cArqInd,cChave,,,"Indexando Registros...")

DbSelectArea("TRB")
TRB->(DbGotop())
While TRB->(!EOF())
	Reclock("TRBSTRU",.T.)
	TRBSTRU->ORIGEM		:= TRB->ORIGEM
	TRBSTRU->B6_DOC		:= TRB->B6_DOC
	TRBSTRU->B6_SERIE	:= TRB->B6_SERIE
	TRBSTRU->B6_EMISSAO	:= TRB->B6_EMISSAO
	TRBSTRU->B6_SALDO	:= TRB->B6_SALDO
	TRBSTRU->B6_QUANT	:= TRB->B6_QUANT
	TRBSTRU->Z97_PRAZO	:= TRB->Z97_PRAZO
	TRBSTRU->D2_COD		:= TRB->D2_COD
	TRBSTRU->D2_QUANT	:= TRB->D2_QUANT
	TRBSTRU->D2_LOCAL	:= TRB->D2_LOCAL
	TRBSTRU->D2_VALICM	:= TRB->D2_VALICM
	TRBSTRU->D2_VALIPI	:= TRB->D2_VALIPI
	TRBSTRU->D2_CF		:= TRB->D2_CF
	TRBSTRU->D2_TES		:= TRB->D2_TES
	TRBSTRU->B1_COD		:= TRB->B1_COD
	TRBSTRU->B1_DESC	:= TRB->B1_DESC
	TRBSTRU->F2_VALBRUT	:= TRB->F2_VALBRUT
	TRBSTRU->B6_IDENT	:= TRB->B6_IDENT
	TRBSTRU->A1_CGC		:= TRB->A1_CGC
	TRBSTRU->A1_NREDUZ	:= TRB->A1_NREDUZ
	TRBSTRU->B6_PRODUTO	:= TRB->B6_PRODUTO
	TRBSTRU->B6_LOCAL	:= TRB->B6_LOCAL 
	TRBSTRU->D2_LOTECTL	:= TRB->D2_LOTECTL
	TRBSTRU->D2_DTVALID	:= TRB->D2_DTVALID
	TRBSTRU->R_E_C_N_O_	:= TRB->R_E_C_N_O_
	TRBSTRU->B6_PODER3	:= TRB->B6_PODER3
	TRBSTRU->D2_TOTAL	:= TRB->D2_TOTAL
	TRBSTRU->F2_CLIENTE := TRB->F2_CLIENTE
	TRBSTRU->B6_CUSTO1  := TRB->B6_CUSTO1
	TRBSTRU->(MsUnlock())
	TRB->(DbSkip())      
EndDo

//FIM Montagem de temporario para auxiliar na impressao por tipo:nota
DbSelectArea("TRBSTRU")
TRBSTRU->(DbGotop())

//PERCORRE ARQUIVO DE TRABALHO DA QUERY DA ROTINA
If TRBSTRU->(!EOF())

	//Estilo para tipo texto
	cLin += '   <style>
	cLin += '	.xText
	cLin += '	{mso-style-parent:style0;
	cLin += '	color:black;
	cLin += '	font-size:7.5pt;
	cLin += '	mso-number-format:"\@";
	cLin += '	text-align:left;
	cLin += '	mso-pattern:black none;
	cLin += '	white-space:normal;}
	cLin += '   </style> 
	
	cLin += '<br>
	cLin += ' 	<table border="1">
	cLin += ' 	<tr> <td>'
	cLin += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
//	cLin += '     <tbody> '
	cLin += '<tr>  '		
	CorLin := 'style="font-weight: bold; color: black; background-color: rgb(168,168,168); text-align: left;" '
	cLin += '<th '+CorLin+'><small>NF</small></th>
	cLin += '<th '+CorLin+'><small>SERIE</small></th>
	cLin += '<th '+CorLin+'><small>CLI/FOR</small></th>
	cLin += '<th '+CorLin+'><small>Data</small></th>
	cLin += '<th '+CorLin+'><small>Produto</small></th>
	cLin += '<th '+CorLin+'><small>Descricao</small></th>
	cLin += '<th '+CorLin+'><small>SALDO</small></th>
	cLin += '<th '+CorLin+'><small>Qtdade</small></th>
	cLin += '<th '+CorLin+'><small>Lote</small></th>
	cLin += '<th '+CorLin+'><small>Local</small></th>
	cLin += '<th '+CorLin+'><small>Dt.Lote</small></th>
	cLin += '<th '+CorLin+'><small>CUSTO DO SALDO</small></th>
	cLin += '<th '+CorLin+'><small>PRAZO</small></th>
	cLin += '<th '+CorLin+'><small>DIAS A EXPIRAR</small></th>
	cLin += '<th '+CorLin+'><small>TEXTO TES</small></th>
	cLin += '<th '+CorLin+'><small>CFO</small></th>

	While TRBSTRU->(!EOF())
		nRegs++
		lCarga	:= .T.
		cCor	:= aCor[IIF(lCor,1,2)]
		lCor	:= !lCor
		nDias	:= (date() - TRBSTRU->B6_EMISSAO)
		cCorX	:= ""
		cFlag	:= GetFlag(NDIAS,TRBSTRU->Z97_PRAZO)
		nContDias := nDias - TRBSTRU->Z97_PRAZO  

		cIdentfic:=""
		cLin +=	CARGNOTR(TRBSTRU->B6_IDENT,TRBSTRU->B6_DOC,TRBSTRU->B6_SERIE,@cIdentfic,nContDias)//Remessa
		cLin +=	CARGNOTD(TRBSTRU->B6_IDENT,TRBSTRU->B6_DOC,TRBSTRU->B6_SERIE,TRBSTRU->B6_PRODUTO,cIdentfic,cFlag,nContDias)//Devolução

		If !lCorpo
			fWrite(nArq, cLin+CRLF)
			cLin := ""
		Else
			cMsg += cLin
		EndIf		
		TRBSTRU->(dbskip())
	EndDo
	cLin += ' 	</td></tr> '
	cLin += ' 	</table> '			
EndIf	

//FECHA ARQUIVO HTML
cMsg += '</body></html>'

If !lCorpo
	fWrite(nArq, '</body></html>' +CRLF)
	cLin := ""
EndIf

fClose(nArq)

//If MsgYesNo("Deseja enviar e-mail?"+CHR(13)+CHR(10)+"Para:"+ALLTRIM(cMail))
//	PUTMAIL(cMail,cMsg,!lCorpo)
//EndIf

Return (cArq)

/*
Funcao      : PROCHTM
Parametros  : 
Retorno     : 
Objetivos   : funcao acessoria de processamento da funcao GTM002()
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------*
Static Function PROCHTM()
*-----------------------*
cpys2t(cPathSrv,cDirRmt,.t.)
cExt	:= '.xls'
cOpen	:= cDirrmt+cFile
SHELLEXECUTE("open",cOpen,"","",5)

MsgInfo("Arquivo Processado, o visualizador padrao apresentara o relatorio!")

Return .T.

/*
Funcao      : E_CAB
Parametros  : 
Retorno     : 
Objetivos   : CABECARIO HTML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function E_CAB(lPar) 
*--------------------------*
Private cRet := ""

cRet := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
cRet += '<html>
cRet += '	<head>
cRet += '		<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
cRet += '		<title>HLB BRASIL - Poder de Terceiros</title>
cRet += '   </head>
cRet += '   <body>
cRet += '		<span style="font-weight: bold;">Relacao de Poder de Terceiros</span> (emissao - '+DTOC(DATE())+' &nbsp;'+TIME()+')<br>
cRet += '		<br>

If !lPar
	fWrite(nArq, cRet+CRLF)
	cRet := ""
	cRet+='<html xmlns:v="urn:schemas-microsoft-com:vml"'
	cRet+='xmlns:o="urn:schemas-microsoft-com:office:office"'
	cRet+='xmlns:w="urn:schemas-microsoft-com:office:word" '
	cRet+='xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"'
	cRet+='xmlns="http://www.w3.org/TR/REC-html40">'
	cRet+='<head>
	cRet+='	<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
	cRet+='	<meta name=ProgId content=Word.Document> '
	cRet+='	<meta name=Generator content="Microsoft Word 12"> '
	cRet+='	<meta name=Originator content="Microsoft Word 12">'
	cRet+='</head>
	cRet+='<body bgcolor="#FFFFFF" lang=PT-BR link=blue vlink=purple style="tab-interval:35.4pt">'
	cRet+='<div class=WordSection1>'
	cRet+="	<p class=MsoNormal  align=center style='text-align:center'> "
	cRet+='		<a href="http://www.grantthornton.com.br/">'
	cRet+="			<span style='text-decoration:none; text-underline:none'>"
	cRet+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
	cRet+="			</span>"
	cRet+="		</a>"  
	cRet+="    </p>"
	cRet+="</div>"
	cRet+="<h1>"
	cRet+="<div align=center>"
	cRet+="	<table class=MsoNormalTable border=0 cellpadding=0 width=800 style='width:525.0pt;mso-cellspacing:1.5pt;background:white;mso-yfti-tbllook:1184'>"
	cRet+="		<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
	cRet+="			<td style='padding:.75pt .75pt .75pt .75pt'>"
	cRet+="				<div align=center>"
	cRet+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
	cRet+="						<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
	cRet+="							<td style='background:#4D1174;padding:0cm 0cm 0cm 0cm'>"
	cRet+="								<p class=MsoNormal align=left style='text-align:center'><b> "
	cRet+="<span style='font-size:10pt;font-family:"
	cRet+='"Verdana","sans-serif"'
	cRet+=";mso-fareast-font-family:"
	cRet+='"Times New Roman"'
	cRet+=";color:white'>"
	cRet+="										Relatório Anexo!"
	cRet+="									</span></b>"
	cRet+="								</p>"
	cRet+="							</td>"
	cRet+="						</tr>"
	cRet+="					</table>"
	cRet+="				</div>"
	cRet+="			</td>"  
	cRet+="		</tr>"						
	cRet+="   	</table>"
	cRet+="</div>"	
	cRet+="<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
	cRet+="	<td style='padding:.75pt .75pt .75pt .75pt'>"
	cRet+="		<p class=MsoNormal align=center style='text-align:center'>"
	cRet+="			<span class=tituloatencao1>"
	cRet+="				<span style='font-size:9.5pt;mso-fareast-font-family:"
	cRet+='				"Times New Roman"'
	cRet+="				;color:red'>"
	cRet+="						HLB BRASIL - Mensagem automática, favor não responder este e-mail."
	cRet+="				</span>"
	cRet+="			</span>"
	cRet+="		</p>"
	cRet+="    </td>"
	cRet+="</tr>"
EndIf

Return (cRet)

/*
Funcao      : GetFlag
Parametros  : 
Retorno     : 
Objetivos   : Retorna a cor do alerta
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GetFlag(nD1,nD2)
*------------------------------*
Private cRet := ""
Private nP := 0

If nD2 == 0
	Return ("")
EndIf

If nD1 >= nD2
	cRet := "Critico"		// VERMELHO
Else
	nP := (nD1/nD2) * 100
	If nP > 75
		cRet := "Atencao"	// VERMELHO		
	ElseIf nP > 50
		cRet := "Normal"	// AMARELO		
	ElseIf nP > 25
		cRet := ""			// AZUL		
	Else
		cRet := ""			// BRANCO		
	EndIf
EndIf

Return (cRet)

/*
Funcao      : PUTMAIL
Parametros  : 
Retorno     : 
Objetivos   : Rotina de envio de email
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------------*
Static Function PUTMAIL(cDest,cBody,lAnexo) 
*-----------------------------------------*
Private cSrv := GetMV("MV_RElseRV")  //ENDEREÇO DO SERVIDOR SMTP smtp.ig.com.br
Private cMail := GetMV("MV_RELACNT") //EMAIL                     meuemail@ig.com.br
Private cPass := GetMV("MV_RELPSW")  //SENHA DO EMAIL            123abc
Private lAuth := GetMv("MV_RELAUTH") //Requer Autenticacao?
Private cPswA := GetMV("MV_RELAPSW") //SENHA DA AUTENTICAÇÃO     123abc 
Private cFrom := GetMV("MV_RELFROM")
Private lResult := .T.

CONNECT SMTP SERVER cSrv;     //Nome do servidor SMTP
ACCOUNT cMail;   //Conta de Email
PASSWORD cPass;  //Senha de conexao
RESULT lResul    //Resultado da Conexao

If lResult
	If !lAnexo
		SEND MAIL FROM cFrom ;
		TO cDest;
		SUBJECT "PODER 3. "+DTOC(DATE())+" - "+TIME()+" - "+FWEmpName(cEmpAnt) ;
		BODY cBody;
		RESULT lResult := .t.
	Else  
	    If UPPER(RIGHT(cArq,4)) == "HTML"
			__CopyFile( cArq, LEFT(ALLTRIM(cArq),LEN(ALLTRIM(cArq))-4)+"XLS" )
			cArqMail := LEFT(ALLTRIM(cArq),LEN(ALLTRIM(cArq))-4)+"XLS"
		Else                
			cArqMail := SUBSTR(cArq,1,RAT(".",cArq)-1)+"A.XLS"
			__CopyFile( cArq, cArqMail )
	    EndIf
	                   
		//Tratamento para zipar quando maior que 4 Mb.
 		If ( Directory(cArqMail,"D")[1][2]/(1024^2) ) >= 4
			//SUBSTR(cArqMail,1,RAT(".",cArqMail))+"zip"
			compacta(cArqMail,SUBSTR(cArqMail,1,RAT(".",cArqMail))+"zip")
			cArqMail := SUBSTR(cArqMail,1,RAT(".",cArqMail))+"zip"
		EndIf
	
		SEND MAIL FROM cMail ;
		TO cDest;
		SUBJECT "PODER 3. "+DTOC(DATE())+" - "+TIME()+" - "+cEmpresa ;
		BODY cBody;
		ATTACHMENT cArqMail ;
		RESULT lResult
		
		Sleep(500)
		
		If File(cArqMail)
			FErase(cArqMail)
		EndIf
	EndIf

	If !lResult
		GET MAIL ERROR cError
		Conout("9NGEN001.PRW -> FALHA NO ENVIO DE EMAIL: "+cError)
	EndIf
Else
	GET MAIL ERROR cError
	Conout("9NGEN001.PRW -> FALHA NO ENVIO DE EMAIL: "+cError)
EndIf

//Desconecta do servidor
DISCONNECT SMTP SERVER

Return .T.

/*
Funcao      : PODER3PR
Parametros  : 
Retorno     : 
Objetivos   : Query para remessas.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function PODER3PR()
*------------------------*
Local cWhereA := ""
Local cWhereB := ""

cWhereA := "% B6.B6_SALDO > 0 AND B6.B6_TPCF = 'C' "
cWhereA += " AND B6.B6_PRODUTO BETWEEN '"+ALLTRIM(cProdDe)+"' AND '"+ALLTRIM(cProdAte)+"'
cWhereA += " AND B6.B6_DOC     BETWEEN '"+ALLTRIM(cNfDe)+"' AND '"+ALLTRIM(cNfAte)+"'
cWhereA += " AND B6.B6_SERIE   BETWEEN '"+ALLTRIM(cSerieDe)+"' AND '"+ALLTRIM(cSerieAte)+"'
cWhereA += " AND B6.B6_LOCAL   BETWEEN '"+ALLTRIM(cArmDe)+"' AND '"+ALLTRIM(cArmAte)+"'
cWhereA += " AND D2.D2_CF IN ("+ALLTRIM(cCFO)+")
cWhereA += " AND (   B6.B6_CLIFOR BETWEEN '"+ALLTRIM(cCliDe)+"' AND '"+ALLTRIM(cCliAte)+"' 
cWhereA += "	  OR B6.B6_CLIFOR BETWEEN '"+ALLTRIM(cFornDe)+"' AND '"+ALLTRIM(cFornDAte)+"')
cWhereA += " AND ZH.Z97_PRAZO IN ("+ALLTRIM(cPrazo)+")
cWhereA += " %"

cWhereB := "% B6.B6_SALDO > 0 AND B6.B6_TPCF = 'F'
cWhereB += " AND B6.B6_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'
cWhereB += " AND B6.B6_DOC     BETWEEN '"+cNfDe+"' AND '"+cNfAte+"'
cWhereB += " AND B6.B6_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"'
cWhereB += " AND B6.B6_LOCAL   BETWEEN '"+cArmDe+"' AND '"+cArmAte+"'
cWhereB += " AND D2.D2_CF IN ("+cCFO+")
cWhereB += " AND (B6.B6_CLIFOR BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' OR B6.B6_CLIFOR BETWEEN '"+cFornDe+"' AND '"+cFornDAte+"')
cWhereB += " AND ZH.Z97_PRAZO IN ("+cPrazo+")
cWhereB += " %"

BEGINSQL ALIAS "TRB"
	COLUMN B6_EMISSAO AS DATE
	COLUMN B6_SALDO   AS NUMERIC(17,2)
	COLUMN B6_QUANT   AS NUMERIC(17,2)
	COLUMN Z97_PRAZO  AS NUMERIC(17,2)
	COLUMN D2_QUANT   AS NUMERIC(17,2)
	COLUMN D2_VALICM  AS NUMERIC(17,2)
	COLUMN D2_VALIPI  AS NUMERIC(17,2)
	COLUMN F2_VALBRUT AS NUMERIC(17,2)  
	COLUMN D2_DTVALID AS DATE
	
	SELECT 'CLIENTE' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D2.D2_COD, D2.D2_QUANT, D2.D2_LOTECTL, D2.D2_DTVALID, D2.D2_LOCAL, D2.D2_VALICM, D2.D2_VALIPI, D2.D2_CF, D2.D2_TES
			, B1.B1_COD, B1.B1_DESC
			, F2.F2_VALBRUT, B6.B6_IDENT
			, A1.A1_CGC , A1.A1_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL, B6.R_E_C_N_O_,B6.B6_PODER3,D2.D2_TOTAL,F2.F2_CLIENTE,B6.B6_CUSTO1
	FROM %table:SB6% B6 (NOLOCK)
			LEFT	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA1% A1 (NOLOCK) ON A1.%NotDel% AND A1.A1_FILIAL = %xfilial:SA1% AND A1.A1_COD = B6.B6_CLIFOR AND A1.A1_LOJA = B6.B6_LOJA
			INNER 	JOIN %table:SD2% D2 (NOLOCK) ON D2.%NotDel% AND D2.D2_FILIAL = %xfilial:SD2% AND D2.D2_DOC = B6.B6_DOC 
																AND D2.D2_SERIE = B6.B6_SERIE AND D2.D2_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND ZH.Z97_CFO = D2.D2_CF
			INNER 	JOIN %table:SF2% F2 (NOLOCK) ON F2.%NotDel% AND F2.F2_FILIAL = %xfilial:SF2% AND F2.F2_DOC = B6.B6_DOC AND F2.F2_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereA%
	
	UNION ALL
	SELECT 'FORNECEDOR' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D2.D2_COD, D2.D2_QUANT, D2.D2_LOTECTL, D2.D2_DTVALID, D2.D2_LOCAL, D2.D2_VALICM, D2.D2_VALIPI, D2.D2_CF, D2.D2_TES
			, B1.B1_COD, B1.B1_DESC
			, F2.F2_VALBRUT, B6.B6_IDENT
			, A2.A2_CGC , A2.A2_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL,B6.R_E_C_N_O_,B6.B6_PODER3,D2.D2_TOTAL,F2.F2_CLIENTE,B6.B6_CUSTO1
	FROM %table:SB6% B6 (NOLOCK)
			LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA2% A2 (NOLOCK) ON A2.%NotDel% AND A2.A2_FILIAL = %xfilial:SA2% AND A2.A2_COD = B6.B6_CLIFOR AND A2.A2_LOJA = B6.B6_LOJA
			INNER 	JOIN %table:SD2% D2 (NOLOCK) ON D2.%NotDel% AND D2.D2_FILIAL = %xfilial:SD2% AND D2.D2_DOC = B6.B6_DOC 
																AND D2.D2_SERIE = B6.B6_SERIE AND D2.D2_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND Z97_CFO = D2.D2_CF
			INNER 	JOIN %table:SF2% F2 (NOLOCK) ON F2.%NotDel% AND F2.F2_FILIAL = %xfilial:SF2% AND F2.F2_DOC = B6.B6_DOC AND F2.F2_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%        
			AND %exp:cWhereB%
    ORDER BY B1_COD
ENDSQL

Return .T.  

/*
Funcao      : PODER3PRD
Parametros  : 
Retorno     : 
Objetivos   : Query para devoluções
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function PODER3PRD()
*-------------------------*
Local cWhereA := ""
Local cWhereB := ""

cWhereA := "% B6.B6_PODER3 = 'D' AND B6.B6_SALDO > 0 AND B6.B6_TPCF = 'C'
cWhereA += " AND B6.B6_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'
cWhereA += " AND B6.B6_DOC     BETWEEN '"+cNfDe+"' AND '"+cNfAte+"'
cWhereA += " AND B6.B6_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"'
cWhereA += " AND B6.B6_LOCAL   BETWEEN '"+cArmDe+"' AND '"+cArmAte+"'
cWhereA += " AND (B6.B6_CLIFOR BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' OR B6.B6_CLIFOR BETWEEN '"+cFornDe+"' AND '"+cFornDAte+"')
cWhereA += " AND D1.D1_CF IN ("+cCFO+")
cWhereA += " AND ZH.Z97_PRAZO IN ("+cPrazo+")"
If nImpDev == 2
	cWhereA += " AND D1.D1_NFORI = ' ' AND D1.D1_SERIORI = ' ' AND D1.D1_ITEMORI = ' ' "
EndIf
cWhereA += " %"  

cWhereB := "% B6.B6_PODER3='D' AND B6.B6_SALDO > 0 AND B6.B6_TPCF = 'F'
cWhereB += " AND B6.B6_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"'
cWhereB += " AND B6.B6_DOC     BETWEEN '"+cNfDe+"' AND '"+cNfAte+"'
cWhereB += " AND B6.B6_SERIE   BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"'
cWhereB += " AND B6.B6_LOCAL   BETWEEN '"+cArmDe+"' AND '"+cArmAte+"'
cWhereB += " AND (B6.B6_CLIFOR BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' OR B6.B6_CLIFOR BETWEEN '"+cFornDe+"' AND '"+cFornDAte+"')
cWhereB += " AND D1.D1_CF IN ("+cCFO+")
cWhereB += " AND ZH.Z97_PRAZO IN ("+cPrazo+")"
If nImpDev == 2
	cWhereB += " AND D1.D1_NFORI = ' ' AND D1.D1_SERIORI = ' ' AND D1.D1_ITEMORI = ' ' "
EndIf
cWhereB += " %"  

BEGINSQL ALIAS "TRD"
	
	COLUMN B6_EMISSAO AS DATE
	COLUMN B6_SALDO   AS NUMERIC(17,2)
	COLUMN B6_QUANT   AS NUMERIC(17,2)
	COLUMN Z97_PRAZO  AS NUMERIC(17,2)
	COLUMN D1_QUANT   AS NUMERIC(17,2)
	COLUMN D1_VALICM  AS NUMERIC(17,2)
	COLUMN D1_VALIPI  AS NUMERIC(17,2)
	COLUMN F1_VALBRUT AS NUMERIC(17,2)
	COLUMN D1_DTVALID AS DATE
	
	SELECT 'CLIENTE' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D1.D1_COD, D1.D1_QUANT, D1.D1_LOTECTL, D1.D1_DTVALID, D1.D1_LOCAL, D1.D1_VALICM, D1.D1_VALIPI, D1.D1_CF, D1.D1_TES
			, B1.B1_COD, B1.B1_DESC
			, F1.F1_VALBRUT, B6.B6_IDENT
			, A1.A1_CGC , A1.A1_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL, B6.R_E_C_N_O_,B6.B6_PODER3,D1.D1_TOTAL,B6.B6_CUSTO1
	FROM %table:SB6% B6 (NOLOCK)
			LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA1% A1 (NOLOCK) ON A1.%NotDel% AND A1.A1_FILIAL = %xfilial:SA1% AND A1.A1_COD = B6.B6_CLIFOR AND A1.A1_LOJA = B6.B6_LOJA
			INNER 	JOIN %table:SD1% D1 (NOLOCK) ON D1.%NotDel% AND D1.D1_FILIAL = %xfilial:SD1% AND D1.D1_DOC = B6.B6_DOC 
																AND D1.D1_SERIE = B6.B6_SERIE AND D1.D1_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND ZH.Z97_CFO = D1.D1_CF
			INNER 	JOIN %table:SF1% F1 (NOLOCK) ON F1.%NotDel% AND F1.F1_FILIAL = %xfilial:SF1% AND F1.F1_DOC = B6.B6_DOC AND F1.F1_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereA%
	
	UNION ALL
	SELECT 'FORNECEDOR' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D1.D1_COD, D1.D1_QUANT, D1.D1_LOTECTL, D1.D1_DTVALID, D1.D1_LOCAL, D1.D1_VALICM, D1.D1_VALIPI, D1.D1_CF, D1.D1_TES
			, B1.B1_COD, B1.B1_DESC
			, F1.F1_VALBRUT, B6.B6_IDENT
			, A2.A2_CGC , A2.A2_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL,B6.R_E_C_N_O_,B6.B6_PODER3,D1.D1_TOTAL,B6.B6_CUSTO1
	FROM %table:SB6% B6 (NOLOCK)
			LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA2% A2 (NOLOCK) ON A2.%NotDel% AND A2.A2_FILIAL = %xfilial:SA2% AND A2.A2_COD = B6.B6_CLIFOR AND A2.A2_LOJA = B6.B6_LOJA
			INNER	JOIN %table:SD1% D1 (NOLOCK) ON D1.%NotDel% AND D1.D1_FILIAL = %xfilial:SD1% AND D1.D1_DOC = B6.B6_DOC 
																AND D1.D1_SERIE = B6.B6_SERIE AND D1.D1_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND Z97_CFO = D1.D1_CF
			INNER 	JOIN %table:SF1% F1 (NOLOCK) ON F1.%NotDel% AND F1.F1_FILIAL = %xfilial:SF1% AND F1.F1_DOC = B6.B6_DOC AND F1.F1_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereB%
    ORDER BY B1_COD
	
ENDSQL

Return .T.

/*
Funcao      : cargNOTR
Parametros  : 
Retorno     : 
Objetivos   : Carrega item quando for por nota remessa
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------------------*
Static Function cargNOTR(cIdent,cDoc,cSerie,cIdentfic,nContDias)
*--------------------------------------------------------------*
Local cRetCompl	 :=	""		
Local cRecno:=0
Local cSaldoCusto:=0

//cRetCompl += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
//cRetCompl += '     <tbody> '

While TRBSTRU->B6_DOC==cDoc .AND. TRBSTRU->B6_SERIE==cSerie .AND. TRBSTRU->B6_PODER3=='R'
	cIdentfic += "'"+ TRBSTRU->B6_IDENT +"',"
	//Carrega o saldo da tabela SB6
/*	cQrw := " SELECT SUM(B6_SALDO) AS B6_SALDO FROM "+RETSQLNAME("SB6")+CRLF
	cQrw += " WHERE B6_FILIAL='"+xFilial("SB6")+"' AND B6_PRODUTO='"+TRBSTRU->D2_COD+"' AND B6_DOC='"+TRBSTRU->B6_DOC+"' 
	cQrw += " 		AND B6_SERIE='"+TRBSTRU->B6_SERIE+"' AND D_E_L_E_T_=''"
	If SELECT('SALDO')>0
		SALDO->(DBCLOSEAREA())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQrw),"SALDO",.F.,.F.)
	SALDO->(DBGOTOP())	
*/               
	//AOA - 15/04/2016 - Ajuste de calculo para trazer o valor do custo apenas do saldo
	cSaldoCusto :=  (TRBSTRU->B6_CUSTO1 / TRBSTRU->D2_QUANT) * TRBSTRU->B6_SALDO
	
 	cRetCompl += '      <tr>  '                      
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->B6_DOC+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->B6_SERIE+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->F2_CLIENTE+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(TRBSTRU->B6_EMISSAO)+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->B1_COD+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->B1_DESC+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRANSFORM(TRBSTRU->B6_SALDO,"@E 999,999.9999")+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRBSTRU->D2_QUANT,PesqPict("SD2","D2_QUANT"))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->D2_LOTECTL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+TRBSTRU->B6_LOCAL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(TRBSTRU->D2_DTVALID)+'</small></td> '
// 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRBSTRU->B6_CUSTO1,PesqPict("SD2","D2_TOTAL"))+'</small></td> '
	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(cSaldoCusto,PesqPict("SD2","D2_TOTAL"))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+cvaltochar(TRBSTRU->Z97_PRAZO)+'</small></td> '
 	If nContDias < 0
 		cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+cvaltochar(ABS(nContDias))+'</small></td> '
	Else
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+cvaltochar(nContDias)+'</small></td> '
	EndIf
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->D2_TES+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->D2_CF+'</small></td> '
 	cRetCompl += '      </tr>  '

	cRecno:=TRBSTRU->R_E_C_N_O_

	TRBSTRU->(DbSkip())
EndDo
//cRetCompl += '      </tbody>  '
//cRetCompl += '      </table>  '

TRBSTRU->(DbSeek(cRecno))

Return (cRetCompl)

/*
Funcao      : cargNOTD
Parametros  : 
Retorno     : 
Objetivos   : Carrega item quando for por nota devolucao
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------------------------------*
Static Function cargNOTD(cIdent,cDoc,cSerie,cProd,cIdentfic,cFlag,nContDias)
*--------------------------------------------------------------------------*
Local cRet   := ""
Local cRetCompl	 :=	""		
Local cRecno:=0
Local cQry:=""
Local cSaldoCusto:=0

cIdentfic:=SUBSTR(cIdentfic,1,RAT(",",cIdentfic)-1)

cQry+=" SELECT SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO,B1_COD,Left(B1_DESC,50) as B1_DESC,B6_LOCAL, B6_EMISSAO, SUM(SD1.D1_QUANT) AS D1_QUANT,
cQry+="			SD1.D1_TES,SD1.D1_CF,SD1.D1_LOTECTL,SD1.D1_DTVALID,SF1.F1_FORNECE,
cQry+="			SUM(SF1.F1_VALICM) AS F1_VALICM,SUM(SF1.F1_VALIPI) AS F1_VALIPI,
cQry+="			SUM(SD1.D1_TOTAL) AS D1_TOTAL,SUM(SF1.F1_VALBRUT) AS F1_VALBRUT,SUM(SB6.B6_SALDO) AS B6_SALDO "+CRLF
cQry+=" FROM "+RETSQLNAME("SB6")+" SB6 "+CRLF
cQry+=" JOIN "+RETSQLNAME("SF1")+" SF1 ON SF1.F1_FILIAL = '"+XFILIAL("SF1")+"' AND SF1.F1_DOC = SB6.B6_DOC 
cQry+="																			AND SF1.F1_SERIE = SB6.B6_SERIE 
cQry+="																			AND SB6.B6_CLIFOR = SF1.F1_FORNECE 
cQry+="																			AND SB6.B6_LOJA=SF1.F1_LOJA "+CRLF
cQry+=" JOIN "+RETSQLNAME("SD1")+" SD1 ON SD1.D1_FILIAL = '"+XFILIAL("SD1")+"' AND SD1.D1_DOC = SB6.B6_DOC 
cQry+="																			AND SD1.D1_SERIE = SB6.B6_SERIE 
cQry+="																			AND SB6.B6_CLIFOR = SD1.D1_FORNECE 
cQry+="																			AND SB6.B6_LOJA=SD1.D1_LOJA 
cQry+="																			AND SB6.B6_PRODUTO=SD1.D1_COD 
cQry+="																			AND SD1.D1_QUANT=SB6.B6_QUANT "+CRLF
cQry+=" JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' AND SB1.B1_COD = SD1.D1_COD"+CRLF
cQry+=" WHERE SB6.B6_IDENT IN ("+cIdentfic+") AND SB6.B6_PRODUTO = '"+cProd+"' AND SB6.B6_PODER3 = 'D' 
cQry+="		AND SB6.B6_DOC <> '"+TRB->B6_DOC+"' AND SD1.D1_IDENTB6 IN ("+cIdentfic+") "+CRLF
cQry+=" AND SF1.D_E_L_E_T_='' AND SB6.D_E_L_E_T_='' AND SD1.D_E_L_E_T_='' "+CRLF
If nImpDev == 2
	cQry += " AND SD1.D1_NFORI = ' ' AND SD1.D1_SERIORI = ' ' AND SD1.D1_ITEMORI = ' ' "
EndIf
cQry+=" GROUP BY F1_DOC, F1_SERIE, F1_EMISSAO,B1_COD ,B1_DESC , B6_LOCAL, B6_EMISSAO, D1_TES, D1_CF,F1_VALBRUT,D1_LOTECTL,D1_DTVALID,F1_FORNECE "+CRLF
cQry+=" ORDER BY SF1.F1_EMISSAO "

dbselectarea("SB6")
SB6->(dbsetorder(3))
dbgotop()  

If SELECT('DEV_')>0
	DEV_->(DBCLOSEAREA())
EndIf							
DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "DEV_", .F., .F. )

Private nControle	:=1
Private nContro2	:=1
Private cSer_DOC	:=""

DEV_->(DBGOTOP())
While DEV_->(!EOF())
	//Carrega o saldo da tabela SB6
/*	cQrw := " SELECT SUM(B6_SALDO) AS B6_SALDO FROM "+RETSQLNAME("SB6")+CRLF
	cQrw += " WHERE B6_FILIAL='"+xFilial("SB6")+"' AND B6_PRODUTO='"+TRBSTRU->D2_COD+"' AND B6_DOC='"+TRBSTRU->B6_DOC+"' 
	cQrw += " 		AND B6_SERIE='"+TRBSTRU->B6_SERIE+"' AND D_E_L_E_T_=''"
	If SELECT('SALDO')>0
		SALDO->(DBCLOSEAREA())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQrw),"SALDO",.F.,.F.)
	SALDO->(DBGOTOP())	
*/
	cSer_DOC := DEV_->F1_SERIE+DEV_->F1_DOC   
// 	cRet += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">
// 	cRet += '     <tbody> '

	//AOA - 15/04/2016 - Ajuste de calculo para trazer o valor do custo apenas do saldo
	cSaldoCusto :=  (TRBSTRU->B6_CUSTO1 / TRBSTRU->D2_QUANT) * TRBSTRU->B6_SALDO

 	cRetCompl += '      <tr>  '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->F1_DOC+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->F1_SERIE+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->F1_FORNECE+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(STOD(DEV_->B6_EMISSAO))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->B1_COD+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->B1_DESC+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRANSFORM(DEV_->B6_SALDO,"@E 999,999.9999")+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->D1_QUANT,PesqPict("SD1","D1_QUANT"))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->D1_LOTECTL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" class=xText ><small>'+DEV_->B6_LOCAL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(STOD(DEV_->D1_DTVALID))+'</small></td> '
// 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRBSTRU->B6_CUSTO1,PesqPict("SF2","F2_VALBRUT"))+'</small></td> '
	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(cSaldoCusto,PesqPict("SD2","D2_TOTAL"))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+cvaltochar(TRBSTRU->Z97_PRAZO)+'</small></td> '
 	If nContDias < 0
 		cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+cvaltochar(ABS(nContDias))+'</small></td> '
	Else
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+cvaltochar(nContDias)+'</small></td> '
	EndIf
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_TES+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_CF+'</small></td> '
 	cRetCompl += '      </tr>  '

	nControle++
	nContro2++
	DEV_->(DBSKIP())                    

	If cSer_DOC <> DEV_->F1_SERIE+DEV_->F1_DOC
		nControle:=1
	 	cRet += cRetCompl
//	 	cRet += '      </tbody>  '
//	 	cRet += '      </table>  '
	 	cRetCompl:=""
	EndIf
EndDo

Return (cRet)

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar o arquivo(boleto html)
Autor       : Matheus Massarotto
Data/Hora   : 01/08/2012
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet		:= .F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)