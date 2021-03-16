#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : GTHDC008
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de controle de Atualização noturna.
Autor       : Jean Victor Rocha	
Data/Hora   : 02/09/2013
Z11_TIPO = 
		C - Cadastro
		R - Registro
		M - Emails, separados por virgula
*/
*----------------------*
User Function GTHDC008()
*----------------------*
Private lLider	  := ValLogin()
Private dDataAtu  := dDataBase
Private aEstruBut := {  ;
						{2,"SEGUNDA"	,{1,08,15,22,29,36}},;
						{3,"TERCA" 		,{2,09,16,23,30,37}},; 
						{4,"QUARTA"		,{3,10,17,24,31,38}},;
						{5,"QUINTA"		,{4,11,18,25,32,39}},;
						{6,"SEXTA" 		,{5,12,19,26,33,40}},;
						{7,"SABADO"		,{6,13,20,27,34,41}},;
						{1,"DOMINGO"	,{7,14,21,28,35,42}},;
						{9,"ANALISTAS"	,{46,47,48,49,50,51,52}};
						}
  
SetPrvt("oDlg1","oSay1","oGrp1","oBtn1","oBtn8","oBtn15","oBtn22","oBtn29","oBtn36","oGrp2","oBtn2","oBtn9")
SetPrvt("oBtn23","oBtn30","oBtn37","oGrp3","oBtn3","oBtn10","oBtn17","oBtn24","oBtn31","oBtn38","oGrp4")
SetPrvt("oBtn11","oBtn18","oBtn25","oBtn32","oBtn39","oGrp5","oBtn5","oBtn12","oBtn19","oBtn26","oBtn33")
SetPrvt("oGrp6","oBtn6","oBtn13","oBtn20","oBtn27","oBtn34","oBtn41","oGrp7","oBtn7","oBtn14","oBtn21")
SetPrvt("oBtn35","oBtn42","oGrp8","oSay2","oBtn46","oBtn47","oBtn48","oBtn49","oBtn50","oBtn51","oBtn52")
SetPrvt("oSBtn1","oBtn45","oBtn44","oBtn43")

cMes := UPPER(MES(dDataBase))
cAno := UPPER(ALLTRIM(STR(YEAR(dDataBase))))

aAnalistas := {"","","","","","","","","",""}//posições, conforme quantidade de espaços na tela para exibição.      
Z03->(DbGoTop())
While Z03->(!EOF())
	If Z03->Z03_ATUNOT <> "0"
		If !EMPTY(aAnalistas[Val(Z03->Z03_ATUNOT)])
			MsgInfo("Existe mais de um analista na Ordem '"+Z03->Z03_ATUNOT+"', Favor verificar!","Grant Thornton")
			Return .T.
		EndIf
		aAnalistas[Val(Z03->Z03_ATUNOT)] := Z03->Z03_ATUNOT+"-"+Z03->Z03_INICIA+"-"+LEFT(Z03->Z03_NOME,10)
	EndIf
	Z03->(DbSkip())
EndDo 

oDlg1      := MSDialog():New( 135,302,576,1049,"Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Calendario de Atualização"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)

oSBtn1     := SButton():New( 004,336,1,{|| oDlg1:End()},oDlg1,,"", )
oBtn43     := TButton():New( 004,112,"<<",oDlg1,{|| CriaMesAtu(MonthSub( dDataAtu , 1 ))},037,012,,,,.T.,,"",,,,.F. )
oBtn45     := TButton():New( 004,164,cMes,oDlg1,,036,012,,,,.T.,,"",,,,.F. )
oBtn44     := TButton():New( 004,216,">>",oDlg1,{|| CriaMesAtu(MonthSum( dDataAtu , 1 ))},037,012,,,,.T.,,"",,,,.F. )
oBtnANO	   := TButton():New( 004,268,cAno,oDlg1,,037,012,,,,.T.,,"",,,,.F. )

oGrp1      := TGroup():New( 024,004,156,052,"SEGUNDA",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn1      := TButton():New( 036,008,"",oGrp1,{|| ManuData(1)},037,012,,,,.T.,,"",,,,.F. )
oBtn8      := TButton():New( 056,008,"",oGrp1,{|| ManuData(8)},037,012,,,,.T.,,"",,,,.F. )
oBtn15     := TButton():New( 076,008,"",oGrp1,{|| ManuData(15)},037,012,,,,.T.,,"",,,,.F. )
oBtn22     := TButton():New( 096,008,"",oGrp1,{|| ManuData(22)},037,012,,,,.T.,,"",,,,.F. )
oBtn29     := TButton():New( 116,008,"",oGrp1,{|| ManuData(29)},037,012,,,,.T.,,"",,,,.F. )
oBtn36     := TButton():New( 136,008,"",oGrp1,{|| ManuData(36)},037,012,,,,.T.,,"",,,,.F. )

oGrp2      := TGroup():New( 024,056,156,104,"TERÇA",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn2      := TButton():New( 036,060,"",oGrp2,{|| ManuData(2)},037,012,,,,.T.,,"",,,,.F. )
oBtn9      := TButton():New( 056,060,"",oGrp2,{|| ManuData(9)},037,012,,,,.T.,,"",,,,.F. )
oBtn16     := TButton():New( 076,060,"",oGrp2,{|| ManuData(16)},037,012,,,,.T.,,"",,,,.F. )
oBtn23     := TButton():New( 096,060,"",oGrp2,{|| ManuData(23)},037,012,,,,.T.,,"",,,,.F. )
oBtn30     := TButton():New( 116,060,"",oGrp2,{|| ManuData(30)},037,012,,,,.T.,,"",,,,.F. )
oBtn37     := TButton():New( 136,060,"",oGrp2,{|| ManuData(37)},037,012,,,,.T.,,"",,,,.F. )

oGrp3      := TGroup():New( 024,108,156,156,"QUARTA",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn3      := TButton():New( 036,112,"",oGrp3,{|| ManuData(3)},037,012,,,,.T.,,"",,,,.F. )
oBtn10     := TButton():New( 056,112,"",oGrp3,{|| ManuData(10)},037,012,,,,.T.,,"",,,,.F. )
oBtn17     := TButton():New( 076,112,"",oGrp3,{|| ManuData(17)},037,012,,,,.T.,,"",,,,.F. )
oBtn24     := TButton():New( 096,112,"",oGrp3,{|| ManuData(24)},037,012,,,,.T.,,"",,,,.F. )
oBtn31     := TButton():New( 116,112,"",oGrp3,{|| ManuData(31)},037,012,,,,.T.,,"",,,,.F. )
oBtn38     := TButton():New( 136,112,"",oGrp3,{|| ManuData(38)},037,012,,,,.T.,,"",,,,.F. )

oGrp4      := TGroup():New( 024,160,156,208,"QUINTA",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn4      := TButton():New( 036,164,"",oGrp4,{|| ManuData(4)},037,012,,,,.T.,,"",,,,.F. )
oBtn11     := TButton():New( 056,164,"",oGrp4,{|| ManuData(11)},037,012,,,,.T.,,"",,,,.F. )
oBtn18     := TButton():New( 076,164,"",oGrp4,{|| ManuData(18)},037,012,,,,.T.,,"",,,,.F. )
oBtn25     := TButton():New( 096,164,"",oGrp4,{|| ManuData(25)},037,012,,,,.T.,,"",,,,.F. )
oBtn32     := TButton():New( 116,164,"",oGrp4,{|| ManuData(32)},037,012,,,,.T.,,"",,,,.F. )
oBtn39     := TButton():New( 136,164,"",oGrp4,{|| ManuData(39)},037,012,,,,.T.,,"",,,,.F. )

oGrp5      := TGroup():New( 024,212,156,260,"SEXTA",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn5      := TButton():New( 036,216,"",oGrp5,{|| ManuData(5)},037,012,,,,.T.,,"",,,,.F. )
oBtn12     := TButton():New( 056,216,"",oGrp5,{|| ManuData(12)},037,012,,,,.T.,,"",,,,.F. )
oBtn19     := TButton():New( 076,216,"",oGrp5,{|| ManuData(19)},037,012,,,,.T.,,"",,,,.F. )
oBtn26     := TButton():New( 096,216,"",oGrp5,{|| ManuData(26)},037,012,,,,.T.,,"",,,,.F. )
oBtn33     := TButton():New( 116,216,"",oGrp5,{|| ManuData(33)},037,012,,,,.T.,,"",,,,.F. )
oBtn40     := TButton():New( 136,216,"",oGrp5,{|| ManuData(40)},037,012,,,,.T.,,"",,,,.F. )

oGrp6      := TGroup():New( 024,264,156,312,"SABADO",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn6      := TButton():New( 036,268,"",oGrp6,{|| ManuData(6)},037,012,,,,.T.,,"",,,,.F. )
oBtn13     := TButton():New( 056,268,"",oGrp6,{|| ManuData(13)},037,012,,,,.T.,,"",,,,.F. )
oBtn20     := TButton():New( 076,268,"",oGrp6,{|| ManuData(20)},037,012,,,,.T.,,"",,,,.F. )
oBtn27     := TButton():New( 096,268,"",oGrp6,{|| ManuData(27)},037,012,,,,.T.,,"",,,,.F. )
oBtn34     := TButton():New( 116,268,"",oGrp6,{|| ManuData(34)},037,012,,,,.T.,,"",,,,.F. )
oBtn41     := TButton():New( 136,268,"",oGrp6,{|| ManuData(41)},037,012,,,,.T.,,"",,,,.F. )

oGrp7      := TGroup():New( 024,316,156,364,"DOMINGO",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn7      := TButton():New( 036,320,"",oGrp7,{|| ManuData(7)},037,012,,,,.T.,,"",,,,.F. )
oBtn14     := TButton():New( 056,320,"",oGrp7,{|| ManuData(14)},037,012,,,,.T.,,"",,,,.F. )
oBtn21     := TButton():New( 076,320,"",oGrp7,{|| ManuData(21)},037,012,,,,.T.,,"",,,,.F. )
oBtn28     := TButton():New( 096,320,"",oGrp7,{|| ManuData(28)},037,012,,,,.T.,,"",,,,.F. )
oBtn35     := TButton():New( 116,320,"",oGrp7,{|| ManuData(35)},037,012,,,,.T.,,"",,,,.F. )
oBtn42     := TButton():New( 136,320,"",oGrp7,{|| ManuData(42)},037,012,,,,.T.,,"",,,,.F. )
      
oGrp8     := TGroup():New( 160,004,214,364,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayAna1  := TSay():New( 164,008,{|| aAnalistas[1] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna2  := TSay():New( 174,008,{|| aAnalistas[2] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna3  := TSay():New( 184,008,{|| aAnalistas[3] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna4  := TSay():New( 194,008,{|| aAnalistas[4] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna5  := TSay():New( 204,008,{|| aAnalistas[5] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)

oSayAna6  := TSay():New( 164,080,{|| aAnalistas[6] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna7  := TSay():New( 174,080,{|| aAnalistas[7] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna8  := TSay():New( 184,080,{|| aAnalistas[8] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna9  := TSay():New( 194,080,{|| aAnalistas[9] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
oSayAna9  := TSay():New( 204,080,{|| aAnalistas[10] },oGrp8,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)

//Verifica se possui o mes Selecionado e carrega os dados, caso não, cria o mes em branco.
CriaMesAtu(dDataBase)

oDlg1:Activate(,,,.T.)


Return .T.

/*
Funcao      : ManuData
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Manutenção de Dias individualmente.
Autor       : Jean Victor Rocha	
Data/Hora   : 02/09/2013
*/
*-------------------------------*
Static Function ManuData(nButton)
*-------------------------------*
Local lOk	:= .F.              
Local cButton := ALLTRIM(STR(nButton))
Local aItens := {}
Private cDia := ""
Private cGetRecur := "----"
            
Private cMGetNew := ""

SetPrvt("oDlg1","oSay1","oSay2","oSay3","oSBtn1","oCBox1")
   
Z03->(DbGoTop())
While Z03->(!EOF())
	If Z03->Z03_ATUNOT <> "0"
		aAdd(aItens,Z03->Z03_INICIA)     	
	EndIf
	Z03->(DbSkip())
EndDo 

aAdd(aItens,"----")//Adiciona um 'especial'

If AT("-",&("oBtn"+cButton):CCAPTION) <> 0                                                                                 
	cDia	:= ALLTRIM(LEFT(&("oBtn"+cButton):CCAPTION,AT("-",&("oBtn"+cButton):CCAPTION)-1))
Else 
	cDia := &("oBtn"+cButton):CCAPTION
EndIf

Z11->(DbSetOrder(1))
If Z11->(DbSeek(xFilial("Z11")+"R"+STRZERO(YEAR(dDataAtu),4)+STRZERO(MONTH(dDataAtu),2)+STRZERO(VAL(cDia),2)+cButton))
	cMGetNew := Z11->Z11_EMAIL
	If AT("-",Z11->Z11_CONT) <> 0                                                                                 
		cGetRecur	:= ALLTRIM(RIGHT(Z11->Z11_CONT,LEN(Z11->Z11_CONT)-AT("-",Z11->Z11_CONT)))
	Else 
		cGetRecur := "----"
	EndIf 
EndIf

oDlg3      := MSDialog():New( 177,476,600,827,"Grant Thornton Brasil",,,.F.,,,,,,.T.,,,.T. )
oSayMan1      := TSay():New( 004,004,{||"Seleção de Recurso para a Data:"},oDlg3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,108,008)
oSayMan2      := TSay():New( 024,004,{||"Data: "+DTOC(STOD(STRZERO(YEAR(dDataAtu),4)+STRZERO(MONTH(dDataAtu),2)+STRZERO(VAL(cDia),2)))};
																						,oDlg3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
oSayMan3      := TSay():New( 036,004,{||"Recurso:"},oDlg3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBoxMan1     := TComboBox():New( 034,036,{|u|if(PCount()>0,cGetRecur:=u,cGetRecur)},aItens,072,010,oDlg3,,,,,,.T.,,,,,,,,,"cGetRecur")
oSBtnMan1     := SButton():New( 004,140,1,{|| (lOk := .T.,oDlg3:end())},oDlg3,,"", )

oBtnSend      := TButton():New( 034,130,"Envia Email",oDlg3,{|| cMGetNew:=EnviaAtuMail(STOD(STRZERO(YEAR(dDataAtu),4)+STRZERO(MONTH(dDataAtu),2)+STRZERO(VAL(cDia),2)))},037,012,,,,.T.,,"",,,,.F. )

oMManGetNew := TMultiGet():New(050,004,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oDlg3,168,160,,.F.,,,,.T.,,,,,,.T.)
oMManGetNew:EnableVScroll(.T.)

oDlg3:Activate(,,,.T.)

If !EMPTY(cMGetNew) .and. Z11->(DbSeek(xFilial("Z11")+"R"+STRZERO(YEAR(dDataAtu),4)+STRZERO(MONTH(dDataAtu),2)+STRZERO(VAL(cDia),2)+cButton))
	Z11->(RecLock("Z11",.F.))
	Z11->Z11_EMAIL:= cMGetNew
	Z11->(MsUnlock())
EndIf

If lOk
	Z11->(DbSetOrder(1))
	If Z11->(DbSeek(xFilial("Z11")+"R"+STRZERO(YEAR(dDataAtu),4)+STRZERO(MONTH(dDataAtu),2)+STRZERO(VAL(cDia),2)+cButton))
		Z11->(RecLock("Z11",.F.))
		Z11->Z11_CONT := cDia+" - "+cGetRecur
		Z11->(MsUnlock())
	EndIf
	&("oBtn"+cButton):CCAPTION := cDia+" - "+cGetRecur
EndIF

Return .T. 

/*
Funcao      : CriaMesAtu
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Manutenção Basica dos dias do mes atual.
Autor       : Jean Victor Rocha	
Data/Hora   : 02/09/2013
*/
*--------------------------------*
Static Function CriaMesAtu(dDataMes)
*--------------------------------* 
Local aDias:={}
Local dFirstDay := STOD(STRZERO(YEAR(dDataMes),4)+STRZERO(MONTH(dDataMes),2)+"01") 
Local dLastDay  := LastDay(dFirstDay) 
          
For i:=1 to 42//Numeros de botoes na tela para dias.
	&("oBtn"+ALLTRIM(STR(i))):CCAPTION := ""
	&("oBtn"+ALLTRIM(STR(i))):LVISIBLE := .T.
Next i
          
oBtn45:CCAPTION := UPPER(MES(dDataMes))
oBtnANO:CCAPTION := UPPER(ALLTRIM(STR(YEAR(dDataMes))))
        
dDataAtu := dDataMes

Z11->(DbSetOrder(1))
If !Z11->(DbSeek(xFilial("Z11")+"R"+DTOS(dFirstDay)))
	nFirstDayW := aEstruBut[aScan(aEstruBut,{|x| x[1] == DOW(dFirstDay)})][3][1]
    For i:=1 to Day(dLastDay)
		Z11->(RecLock("Z11",.T.))
		Z11->Z11_FILIAL := xFilial("Z11")
		Z11->Z11_TIPO 	:= "R"
		Z11->Z11_BUTTON := ALLTRIM(STR(i+nFirstDayW-1))
		Z11->Z11_CONT 	:= ALLTRIM(STR(i))
		Z11->Z11_DATA 	:= STOD(STRZERO(YEAR(dDataMes),4)+STRZERO(MONTH(dDataMes),2)+STRZERO(i,2) ) 
		Z11->(MsUnLock())
    Next i
EndIf

If Z11->(DbSeek(xFilial("Z11")+"R"+DTOS(dFirstDay)))
    While Z11->(!EOF()) .And. Z11->Z11_TIPO == "R" .And. YEAR(dDataMes) == YEAR(Z11->Z11_DATA) .And. MONTH(dDataMes) == MONTH(Z11->Z11_DATA)
    	&("oBtn"+ALLTRIM(Z11->Z11_BUTTON)):CCAPTION := ALLTRIM(Z11->Z11_CONT)
    	Z11->(DbSkip())
    EndDo 
EndIf

For i:=1 to 42//Numeros de botoes na tela para dias.
	If EMPTY(&("oBtn"+ALLTRIM(STR(i))):CCAPTION)
		&("oBtn"+ALLTRIM(STR(i))):LVISIBLE := .F.	
	EndIf
Next i

Return .T.

/*
Funcao      : EnviaAtuMail
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Envio de email
Autor       : Jean Victor Rocha	
Data/Hora   : 02/09/2013
*/
*--------------------------------*
Static Function EnviaAtuMail(dDtParam) 
*--------------------------------*
Default dDtParam := dDataBaase

Private DDATAAN := dDtParam

If dDataBase <> dDATAAN
	MsgInfo("Não é possivel enviar email fora do dia Atual!","Grant Thornton Brasil.")
	Return ""
EndIf

If !lLider
	MsgInfo("Sem permissão para envio de Email!","Grant Thornton Brasil.")
	Return ""
EndIF

cHtml := Email()//monta e-mail

If EMPTY(cHtml)
	MsgInfo("Não encontradas atualizações a serem enviadas!","Grant Thornton Brasil.")
	Return ""
EndIf

If !MsgYesNo("Confirma o Envio de Email para a Equipe?","Grant Thornton Brasil.")
	Return ""
EndIf  

oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@br.gt.com"
oEmail:cBcc		:= PADR(GetEmailAtu(),400)
oEmail:cSubject	:= padr("Atualizacao Noturna",200)
oEmail:cBody   	:= cHtml
oEmail:Envia()

Return cHtml   

*---------------------*
Static Function Email()
*---------------------*
Local cAux := ""
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
cHtml+="										Atualizações Noturnas"
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
cHtml+="									Recurso Alocado:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+Alltrim(cGetRecur)
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Data:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+DTOC(dDATAAN)
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"
cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>	"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)   
cHtml+="									"
cEmail:=Alltrim(Z01->Z01_EMAIL)
cHtml+="								</span>"
cHtml+="							</td>" 
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
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"	
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="								   "
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
cHtml+="									Atividade<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Repositorio<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Amb.<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Observação<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Empresa<o:p></o:p>"
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
cHtml+="									Dt. Solic. <o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"

Z12->(DbSetOrder(2))
If !Z12->(DbSeek(xFilial("Z12")+"4"))
	Return ""
EndIf
While Z12->(!EOF()) .and. Z12->Z12_STATUS == '4'
	cHtml+="				<tr style='mso-yfti-irow:1'>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)                                             
	If Z12->Z12_ATIV == "1"//1=Compilar
		cHtml+="								Compilar<o:p></o:p>"
	ElseIf Z12->Z12_ATIV == "2"//;2=Update                               
  		cHtml+="								Update<o:p></o:p>"
	ElseIf Z12->Z12_ATIV == "3"//;3=Configurador
   		cHtml+="								Configurador<o:p></o:p>"
	ElseIf Z12->Z12_ATIV == "4"//;4=Patch                            
   		cHtml+="								Patch<o:p></o:p>"
	ElseIf Z12->Z12_ATIV == "5"//;5=Outros                           
		cHtml+="								Outros<o:p></o:p>"	
	EndIf
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
    If Z12->Z12_REPOS == "1"//1=POR
		cHtml+="								POR<o:p></o:p>"
	ElseIf Z12->Z12_REPOS == "2"//;2=ENG                               
  		cHtml+="								ENG<o:p></o:p>"
	ElseIf Z12->Z12_REPOS == "3"//;3=SPA                          
   		cHtml+="								SPA<o:p></o:p>"
 	EndIf   		
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+IIF(EMPTY(Alltrim(Z12->Z12_AMB)),"&nbsp;",Alltrim(Z12->Z12_AMB))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+IIF(EMPTY(Alltrim(Z12->Z12_OBS)),"&nbsp;",Alltrim(Z12->Z12_OBS))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+IIF(EMPTY(Alltrim(Z12->Z12_EMP)),"&nbsp;",Alltrim(Z12->Z12_EMP))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(Z12->Z12_USER)+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="								"+Alltrim(DTOC(Z12->Z12_DTUSER))+" "+LEFT(Z12->Z12_HRUSER,2)+":"+RIGHT(Z12->Z12_HRUSER,2)+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="				</tr>"
	Z12->(DbSkip())
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

Return cHtml   

/*
Funcao      : ValLogin
Parametros  : Nenhum
Retorno     : 
Objetivos   : Verifica se o usuário logado possui permissão para acessar a rotina.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function ValLogin()
*------------------------*  
Local lRet := .F.

Local cCodUsr := RetCodUsr()

Z03->(DbSetOrder(2))
If Z03->(DbSeek(xFilial("Z03")+cCodUsr))
	If Z03->Z03_TIPO == "L" //Líder
		lRet := .T.	
	EndIf		
EndIf

Return lRet

/*
Funcao      : OPCOESEXB
Parametros  : Nenhum
Retorno     : 
Objetivos   : Exibe Opções Ou nao.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function OPCOESEXB()
*------------------------*     
If !lLider
	MsgInfo("Sem Permissão para a ação!","Grant Thornton Brasil.")
	Return .F.
EndIf

If oBtnExb:CCAPTION == "Opções OFF"
	oBtnExb:CCAPTION := "Opções ON"
	oSay2:LVISIBLE := .T.
	oBtn46:LVISIBLE := .T.
	oBtn47:LVISIBLE := .T.
	oBtn48:LVISIBLE := .T.
	oBtn49:LVISIBLE := .T.
	oBtn50:LVISIBLE := .T.
	oBtn51:LVISIBLE := .T.
	oBtn52:LVISIBLE := .T.
	oBtn53:LVISIBLE := .T.
Else
	oBtnExb:CCAPTION := "Opções OFF"
	oSay2:LVISIBLE := .F.
	oBtn46:LVISIBLE := .F.
	oBtn47:LVISIBLE := .F.
	oBtn48:LVISIBLE := .F.
	oBtn49:LVISIBLE := .F.
	oBtn50:LVISIBLE := .F.
	oBtn51:LVISIBLE := .F.
	oBtn52:LVISIBLE := .F.
	oBtn53:LVISIBLE := .F.
EndIf

Return .T.

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


/*
Funcao      : GetEmailAtu
Objetivos   : Ret		orna os Emails dos Atendentes.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/            
*---------------------------*
Static Function GetEmailAtu()            
*---------------------------*
Local cRet := ""

Z03->(DbGoTop())
While Z03->(!EOF())
	If Z03->Z03_ATIVO == "S"
		If !EMPTY(UsrRetMail(Z03->Z03_ID_PSS ))
			cRet += ALLTRIM(UsrRetMail(Z03->Z03_ID_PSS ))+","
		EndIf
	EndIf
	Z03->(DbSkip())
EndDo           

cRet:= LEFT(cRet,LEN(cRet)-1)
 
Return cRet

*------------------------*
Static Function MarcPesq()
*------------------------*
Local nRec := TABPESQ->(RecNo())

TABPESQ->(DbGoTop())
While TABPESQ->(!EOF())
	
	If TABPESQ->(RecNo()) <> nRec
	
		If !Empty(TABPESQ->MARCA)
			TABPESQ->(RecLock("TABPESQ"),.F.)
	 		TABPESQ->MARCA := Space(2)
			TABPESQ->(MsUnlock())
		EndIf
	Else
		If Empty(TABPESQ->MARCA)
			TABPESQ->(RecLock("TABPESQ"),.F.)
	 		TABPESQ->MARCA := cMarca
			TABPESQ->(MsUnlock())
		EndIf
	EndIf
	TABPESQ->(DbSkip())
EndDo

TABPESQ->(DbSetOrder(1))
TABPESQ->(DbGoTo(nRec))               

Return