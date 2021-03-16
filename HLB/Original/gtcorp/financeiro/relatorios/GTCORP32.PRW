#include "TOTVS.CH"
#include "SHELL.CH"
#Include "Ap5mail.ch"

/*
Funcao      : GTCORP32     
Parametros  : aCols,aAuxAcols
Retorno     : 
Objetivos   : Rotina auxiliar a rotina BOLITAU.prw para gerar tela com os boletos em html, com opção de selecionar as NFSe e enviar automaticamente para os clientes
Autor       : Matheus Massarotto
Data/Hora   : 01/08/2012 - 11:07
Revisão     : 
Data/Hora   : 
Módulo      : Financeiro.
*/
*-------------------------------------*
User Function GTCORP32(aCols,aAuxAcols)  
*-------------------------------------*
Local cDrive, cDir, cNome, cExt
	
Private _oDlg,oListBox
Private aListBox	:={}
Private cNick 		:="Envio de e-mail com boletos e notas fiscais para clientes."   
Private aHeader		:={}
Private aAlter		:={"M_OK","M_EMAIL","M_NFSE","M_BOLETO"}
Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
Private nUsado		:=0

Private oCC
Private cCC			:= "nfe@br.gt.com" +SPACE(200)//"gtbr.contasreceber@br.gt.com"+SPACE(200)  // GFP - 03/02/2017 - Chamado 039160

Private cImg		:="\Imagens\GTCORP32\topo4.bmp"

Private lCheckBox1	:=.T.
Private oCheckBox1

Private cMemo:="[NOME_CLIENTE],<br>"+CRLF
		cMemo+="Segue anexo NFe para vossa programação de pagamentos."+CRLF
		cMemo+="Caso encontre alguma divergência, solicitamos que nos informe para que o pagamento da mesma não seja comprometido."+CRLF
		cMemo+="Favor confirmar o recebimento.<br>"+CRLF
		//RRP - 18/11/2013 - Icnlusão do texto em inglês - Chamado 015565.
		cMemo+="Please find attached the nf-e (electronic local invoice) for payment."+CRLF
		cMemo+="If you have any question please let us know so that the payment of the invoice is done within it´s due date."+CRLF
		cMemo+="Please confirm receipt of this message."
Private oMemo

Private oAssunto
Private cAssunto:="[NOME_CLIENTE] # NF GT [NUMERO_NF] – ([MES] / [ANO])"


Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
					{"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}}
					
			AADD(aHeader,{ TRIM(""),;
								 "M_OK",;
								 "@BMP",;
								 2,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("PREFIXO"),;
								 "M_PREF",;
								 "@X  ",;
								 3,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("NUMERO"),;
								 "M_NUM",;
								 "@X  ",;
								 9,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
/*			AADD(aHeader,{ TRIM("PARCELA"),;
								 "M_PARCELA",;
								 "@X  ",;
								 1,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("TIPO"),;
								 "M_TIPO",;
								 "@X  ",;
								 3,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
*/			
			AADD(aHeader,{ TRIM("VALOR"),;
								 "M_VALOR",;
								 "@X  ",;
								 14,;
			 					 2,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "N",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("CODIGO_CLIENTE"),;
								 "M_CODCLI",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
/*			AADD(aHeader,{ TRIM("LOJA"),;
								 "M_LOJA",;
								 "@X  ",;
								 2,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
*/			
			AADD(aHeader,{ TRIM("NOME"),;
								 "M_NOME",;
								 "@X  ",;
								 40,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("EMAIL"),;
								 "M_EMAIL",;
								 "@X  ",;
								 40,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("BOLETO"),;
								 "M_BOLETO",;
								 "@X  ",;
								 40,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("NOTA_FISCAL"),;
								 "M_NFSE",;
								 "@X  ",;
								 40,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
		

for nI:=1 to len(aCols)
	//cArqOrig := SUBSTR(aCols[nI][8],RAT("\",aCols[nI][8]),len(aCols[nI][8]))

	SplitPath( aCols[nI][8], @cDrive, @cDir, @cNome, @cExt )
	cArqOrig:= cNome+cExt
	
	//compacta o arquivo para .rar
	If right(Alltrim(cArqOrig),4)=="html"//AOA - 22/12/2016 - verifica se o arquivo é PDF ou html
		cArqRar	:=SUBSTR(aCols[nI][8],1,RAT(".",aCols[nI][8]))+"zip" //troca o .html para o .zip
		compacta(aCols[nI][8],cArqRar)
  		AADD(aAuxAcols[nI],cArqRar)	
			
			if !FILE(cArqRar)
				Alert("Falha na criação do arquivo zip, arquivo:"+alltrim(cArqRar))
				return()
			endif
     Else
    	    AADD(aAuxAcols[nI],aCols[nI][8]) 
     EndIf	 
			cPath    := AllTrim(GetTempPath())
			CpyS2T( aCols[nI][8] , cPath, .T. )
			aCols[nI][8]:=cPath+cArqOrig

next

// Cria font para uso
oFont:= TFont():New('Arial',,-14,.T.,.T.)

//DEFINE MSDIALOG _oDlg TITLE cNick FROM C(178),C(180) TO C(665),C(966) PIXEL
DEFINE MSDIALOG _oDlg TITLE cNick FROM C(138),C(110) TO C(665),C(966) PIXEL

  	// Cria as grupo no e-mail,CC
  	@ C(01),C(003) TO C(015),C(425) LABEL "" PIXEL OF _oDlg

	// Apresenta o tSay com a fonte Courier New
	oSay := TSay():New( C(05),C(05), {|| 'E-mails em cópia:'},_oDlg,, oFont,,,, .T.,CLR_BLACK,CLR_BLACK )

	@ C(03),C(55) MsGet oCC Var cCC Size C(256),C(008) COLOR CLR_BLACK Picture "@&" PIXEL OF _oDlg

  	// Cria as grupo no envia todos
  	@ C(16),C(003) TO C(25),C(50) LABEL "" PIXEL OF _oDlg
	@ C(17),C(005) CheckBox oCheckBox1 Var lCheckBox1 Prompt "Marca Todos" Size C(048),C(009) PIXEL OF _oDlg
	oCheckBox1:bLClicked := {|| marcatudo() }

  	// Cria as grupo no assunto
  	@ C(16),C(083) TO C(25),C(250) LABEL "" PIXEL OF _oDlg
	@ C(18),C(088) Say "Assunto:" Size C(044),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(17),C(110) MsGet oAssunto Var cAssunto Size C(120),C(005) COLOR CLR_BLACK Picture "@&" PIXEL OF _oDlg
	  
//  oGetDados := MsGetDados():New(15, 05, 250, 500, 4, "AllwaysTrue()", "AllwaysTrue()",;
oGetDados := MsGetDados():New(35, 05, 270, 545, 4, "AllwaysTrue()", "AllwaysTrue()",;
"", .T., aAlter, , .F., 999, "AllwaysTrue()", "AllwaysTrue()",,;
"AllwaysTrue()", _oDlg)

  	// Cria as grupo na imagem
  	@ C(215),C(003) TO C(265),C(425) LABEL "" PIXEL OF _oDlg
	
	oBmp:= TBitmap():New( C(220),C(10),192,28,,"",.F.,,,,.F.,.T.,,"",.T.,,.T.,,.F. )
	oBmp:cBmpFile	:= cImg
	oBmp:lAutoSize	:= .T.
	oBmp:lStretch	:= .F.  

  	// Cria as grupo na mensagem do e-mail
  	@ C(218),C(230) TO C(246),C(422) LABEL "Mensagem do e-mail" PIXEL OF _oDlg
	@ C(224),C(234) GET oMemo Var cMemo MEMO Size C(185),C(020) PIXEL OF _oDlg
                                                  //comp //altura
  	// Cria as grupo nos botões
  	@ C(248),C(230) TO C(264),C(422) LABEL "" PIXEL OF _oDlg

	@ C(250),C(250) Button "&Legenda" Size C(037),C(012) PIXEL OF _oDlg action(Legenda())  	
	@ C(250),C(300) Button "&Enviar" Size C(037),C(012) PIXEL OF _oDlg action(envia(cCC,aCols,aAuxAcols,cAssunto,cMemo))
	@ C(250),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())
	
	oGetDados :AddAction ( "M_NFSE"		, {||CarregaNFSE()	})
	oGetDados :AddAction ( "M_BOLETO"	, {||ExibeBoleto()	})
	oGetDados :AddAction ( "M_OK"		, {||MudaStatus()	})

	oGetDados :ForceRefresh()
ACTIVATE MSDIALOG _oDlg CENTERED 

Return

/*
Funcao      : CarregaNFSE()
Parametros  : 
Retorno     : 
Objetivos   : Função para selecionar o arquivo com a Nota Fiscal
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/

*-----------------------------*
Static Function CarregaNFSE()
*-----------------------------*
Local cArquivo 	:=""
Local cNomBol	:=""
Local cNomNf	:=""

//oGetDados:Obrowse:nAt //pega a linha
//oGetDados:Obrowse:ColPos //Pega a Coluna

cArquivo := cGetFile("Nota Fiscal|*.*","Selecione a Nota Fiscal",1,'C:\',.T.,( GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE ) ,.F.)

cNomBol	 := SUBSTR(aCols[oGetDados:Obrowse:nAt][8],RAT("_",aCols[oGetDados:Obrowse:nAt][8])+1,len(aCols[oGetDados:Obrowse:nAt][8]))
cNomBol	 := alltrim(SUBSTR(cNomBol,1,RAT(".",cNomBol)-1 ))
//RAT(".",aCols[oGetDados:Obrowse:nAt][8])-1

cNomNf	 := SUBSTR(cArquivo,RAT("\",cArquivo)+1,len(cArquivo))
cNomNf	 := alltrim(SUBSTR(cNomNf,1,RAT(".",cNomNf)-1))

if ! empty(cArquivo)
	if Upper(cNomNf)<>Upper(cNomBol)
		Alert("O nome do arquivo deve ser: "+cNomBol)
		aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]:=""
	else
	
		aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]:=cArquivo
	
	endif
endif

Return

/*
Funcao      : ExibeBoleto()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para exibir o boleto gerado
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/

*-----------------------------*
Static Function ExibeBoleto()
*-----------------------------*
Local cArqConte:=aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]
SHELLEXECUTE("open",(aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]),"","",5)

Return(cArqConte)

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/
*-----------------------------*
Static Function MudaStatus()
*-----------------------------*
Local cArqConte:=aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]

if oOk==cArqConte
	cArqConte:=oNo
else 
	cArqConte:=oOk
endif

Return(cArqConte)  

/*
Funcao      : marcatudo
Parametros  : 
Retorno     : 
Objetivos   : Função para mudar a imagem do primeiro campo, para tudo marcado ou tudo desmarcado
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/

*-----------------------------*
Static Function marcatudo
*-----------------------------*

for nSeq:=1 to len(aCols)
	aCols[nSeq][1]:=iif(lCheckBox1,oOk,oNo)
next
	
Return

/*
Funcao      : Legenda
Parametros  : 
Retorno     : 
Objetivos   : Função para exibir tela com a descrição dos conteúdos que serão alterados
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/

*-----------------------*
Static Function Legenda()
*-----------------------*
Private oDlg				// Dialog Principal

// Privates das ListBoxes
Private aListBox1 := {}
Private oListBox1

DEFINE MSDIALOG oDlg TITLE "Variáveis utilizadas" FROM C(206),C(222) TO C(450),C(465) PIXEL

	// Cria as Groups do Sistema
	@ C(003),C(003) TO C(105),C(120) LABEL "Conteúdo que será substituído:" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(110),C(045) Button "Sair" action(oDlg:end()) Size C(037),C(012) PIXEL OF oDlg

	// Carrege aqui sua array da Listbox
	Aadd(aListBox1,{"[NOME_CLIENTE]","Nome do cliente"})
	Aadd(aListBox1,{"[NUMERO_NF]"	,"Número da Nota Fiscal"})
	Aadd(aListBox1,{"[MES]"			,"Mês"})
	Aadd(aListBox1,{"[ANO]"			,"Ano"})
	Aadd(aListBox1,{"<br>"			,"Pular linha"})

	@ C(011),C(008) ListBox oListBox1 Fields HEADER "Variável","Descrição" Size C(106),C(087) Of oDlg Pixel ColSizes 50
	
	oListBox1:SetArray(aListBox1)

	// Cria ExecBlocks das ListBoxes
	oListBox1:bLine 		:= {|| {aListBox1[oListBox1:nAT,1],aListBox1[oListBox1:nAT,2] }}

ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

/*
Funcao      : envia
Parametros  : 
Retorno     : 
Objetivos   : Função para para enviar, carregando a regua de processamento
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/

*-------------------------------------------------------*
Static Function envia(cCC,aCols,aAuxAcols,cAssunto,cMemo)
*-------------------------------------------------------*
Private oDlgMeter
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlgMeter TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},len(aCols),oDlgMeter,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlgMeter CENTERED ON INIT(processsend(cCC,aCols,aAuxAcols,cAssunto,cMemo,oMeter))

Return

/*
Funcao      : processsend
Parametros  : 
Retorno     : 
Objetivos   : Função para para enviar
Autor       : Matheus Massarotto
Data/Hora   : 31/07/2012
*/

*--------------------------------------------------------------*
Static Function processsend(cCC,aCols,aAuxAcols,cAssunto,cMemo,oMeter)
*--------------------------------------------------------------*
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg
Local cBody1	:=""
Local cCC2      :=""
Local cNomArq	:=""
Local lFalha	:=.F.

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF


IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   


//Inicia a régua
oMeter:Set(0)

for nIte:=1 to len(aCols)
	if aCols[nIte][1]:cName==oOk:cName
		if !empty(aCols[nIte][9])
			CpyT2S( aCols[nIte][9] , "\Arquivos\nf\", .T. )
			cNomArq:=SUBSTR(aCols[nIte][9],RAT("\",aCols[nIte][9]),len(aCols[nIte][9]))
			AADD(aAuxAcols[nIte],"\Arquivos\nf\"+Alltrim(cNomArq))
        else
        	oDlgMeter:end()
        	Alert("Nenhum e-mail foi enviado!"+CRLF+"Existe(m) linha(s) para envio sem Nota Fiscal selecionada!"+CRLF+"Realize a correção!")
        	Return
        endif
	endif
next

cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email

cFrom:="workflow@br.gt.com" //cAccount
//cFrom:="nfe@br.gt.com"

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK1

If !lOK1
   Alert("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      //If !MailAuth(cUserAut,cPassAut)
      If !MailAuth(cAccount,cPassword)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 

	for nSeqAc:=1 to len(aCols)
	
		//Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=1 // atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua
		
	   if aCols[nSeqAc][1]:cName==oOk:cName
		   
		   cCC2	:=""
		   cAssunto:="[NOME_CLIENTE] # NF GT [NUMERO_NF] – ([MES] / [ANO])"
		   
		   cMemo2:='<style type="text/css">.MsgBody-text, .MsgBody-text * { font: 10pt monospace; }</style><html xmlns="http://www.w3.org/TR/REC-html40"><head><style><!--'
		   cMemo2+='/* Font Definitions */'
		   cMemo2+='@font-face'
		   cMemo2+='	{font-family:Calibri;'
		   cMemo2+='	panose-1:2 15 5 2 2 2 4 3 2 4;}'
		   cMemo2+='@font-face'
		   cMemo2+='	{font-family:Tahoma;'
		   cMemo2+='	panose-1:2 11 6 4 3 5 4 4 2 4;}'
		   cMemo2+='/* Style Definitions */'
		   cMemo2+='p.MsoNormal, li.MsoNormal, div.MsoNormal'
		   cMemo2+='	{margin:0cm;'
		   cMemo2+='	margin-bottom:.0001pt;'
		   cMemo2+='	font-size:11.0pt;'
		   cMemo2+='	font-family:"Calibri","sans-serif";'
		   cMemo2+='	mso-fareast-language:EN-US;}'
		   cMemo2+='--></style></head><body>'
		   cMemo2+=cMemo
		   /*cMemo2+="Prezado [NOME_CLIENTE],<br>"+CRLF
	       cMemo2+="Segue anexo NFe para vossa programação de pagamentos."+CRLF
		   cMemo2+="Caso encontre alguma divergência, solicitamos que nos informe para que o pagamento da mesma não seja comprometido."+CRLF
		   cMemo2+="Favor confirmar o recebimento deste através do e-mail gtbr.contasreceber@br.gt.com"
		     */
		   cMemo2+='<br><br><br><br><br>'
		   cMemo2+='<p class="MsoNormal">'
		   cMemo2+='<b><span style="color:#4C2D7F">BILLING | GRANT THORNTON BRASIL</span></b>'
		   cMemo2+='<span style="font-size:12.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;;color:black"></span>'
		   cMemo2+='</p>'
		   cMemo2+='<p class="MsoNormal">'
		   cMemo2+='<span style="font-size:10.0pt;color:black">Av Bernardino de Campos, 98 | Paraiso | Sao Paulo | 04004-040 | BR<br></span>'
		   cMemo2+='<b><span style="font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#4C2D7F">T </span></b>'
		   cMemo2+='<b><span style="font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#663366">(office)</span></b>'
		   cMemo2+='<b><span style="font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:black"> </span></b>'
		   cMemo2+='<span style="color:black">'
		   cMemo2+='<a href="about:blank" target="_blank">'
		   cMemo2+='<span style="font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:darkblue">+55 11 3886-4800</span>'
		   cMemo2+='</a></span>'
		   cMemo2+='</p>'
		   cMemo2+='<p class="MsoNormal"><b><span lang="EN-US" style="font-size:10.0pt;font-family:&quot;Calibri&quot;,&quot;sans-serif&quot;;color:#4C2D7F">W</span></b>'
		   cMemo2+='<span lang="EN-US" style="font-size:10.0pt;font-family:&quot;Calibri&quot;,&quot;sans-serif&quot;;color:black"> </span>'
		   cMemo2+='<span style="font-size:11.0pt;font-family:&quot;Calibri&quot;,&quot;sans-serif&quot;;color:black">'
		   cMemo2+='<a href="http://www.grantthornton.com.br/" target="_blank" title="http://www.grantthornton.com.br/">'
		   cMemo2+='<span lang="EN-US" style="font-size:10.0pt;color:purple">www.grantthornton.com.br</span></a></span>'
		   cMemo2+='<span style="font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:black"></span>'
		   cMemo2+='</p>'
		   cMemo2+='<p><span style="font-size:9.0pt;color:black">'
		   //RRP - 18/11/2013 - Ajuste no logo - Chamado 015565.
		   cMemo2+='<img border="0" width="436" height="77" id="Imagem_x0020_2" alt="Grant Thornton" src="http://www.grantthornton.com.br/REMOTE/logo_gt_nfe.jpg">'
		   cMemo2+='</span>'
		   cMemo2+='<span style="font-size:10.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:black"></span>'
		   cMemo2+='</p>'
		   cMemo2+='<p class="MsoNormal">'
		   cMemo2+='<span lang="EN-US" style="font-size:8.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#009B76">Please consider the environment before printing this email </span>'
		   cMemo2+='</p>'
		   cMemo2+='</body>'
		   cTo		:=aCols[nSeqAc][7]
		   
			IF EMPTY(cTo)
				cTo	:="nfe@br.gt.com" //"gtbr.contasreceber@br.gt.com" // GFP - 03/02/2017 - Chamado 039160
				cAssunto+=", sem destinatario definido!"
			ENDIF   
		   
		   cCC2		:=Alltrim(cCC)+";"+Alltrim(aAuxAcols[nSeqAc][1])                                               
		   cAssunto	:=STRTRAN(cAssunto,"[NOME_CLIENTE]"	,alltrim(aCols[nSeqAc][6]))
	       cAssunto	:=STRTRAN(cAssunto,"[NUMERO_NF]"		,alltrim(aCols[nSeqAc][2]+aCols[nSeqAc][3]))
	       cAssunto	:=STRTRAN(cAssunto,"[MES]"			,STRZERO(Month(aAuxAcols[nSeqAc][2]),2) )
	       cAssunto	:=STRTRAN(cAssunto,"[ANO]"			,cValToChar(YEAR(aAuxAcols[nSeqAc][2])) )       
		   cMemo2	:=STRTRAN(cMemo2,"[NOME_CLIENTE]",alltrim(aCols[nSeqAc][6]))
		   cSubject:= cAssunto
		   cBody:=cMemo2
		   
		   cAttachment:= IIF(len(aAuxAcols[nSeqAc])>=3,alltrim(aAuxAcols[nSeqAc][3]),"" )+","+ IIF(len(aAuxAcols[nSeqAc])>=4,alltrim(aAuxAcols[nSeqAc][4]),"" )
		   
		   IF !EMPTY(cCC2)
		      SEND MAIL FROM cFrom TO cTo CC cCC2;
		      SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
		   ELSE
		      SEND MAIL FROM cFrom TO cTo;
		      SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
		   ENDIF   
		   If !lOK 
		      Alert("Falha no Envio do E-Mail: "+ALLTRIM(cTo)+"  - Cliente:"+alltrim(aCols[nSeqAc][6]) )
		      lFalha:=.T.
		   ENDIF
	   
	   endif
	next
ENDIF

DISCONNECT SMTP SERVER

//Deleta os arquivos da pasta temporária do usuário que está executando a rotina
for nDel:=1 to len(aCols)
	FERASE(aCols[nDel][8])
next

if lOK1
	Msginfo("Finalizado envio do(s) e-mail(s)!")
	if !lFalha
		_oDlg:end()
	endif
endif

oDlgMeter:end()

Return .T.
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
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
//Local cArqRar	:=SUBSTR(cArquivo,1,RAT(".",cArquivo))+"rar"
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet:=WaitRunSrv( cCommand , lWait , cPath )
/* COMANDOS RAR
    a       Adicionar arquivos ao arquivo.

            Exemplo:

            criar ou atualizar o arquivo existente myarch, adicionado todos os
            arquivos no diretório atual

            rar a myarch
   -ep1    Excluir diretório base dos nomes. Não salvar o caminho fornecido na
            linha de comandos.

            Exemplo:

            todos os arquivos e diretórios do diretório tmp serão adicionados
            ao arquivo 'pasta', mas o caminho não incluirá 'tmp\'

            rar a -ep1 -r pasta 'tmp\*'

            Isto é equivalente aos comandos:

            cd tmp
            rar a -r pasta
            cd ..
    -o+     Substituir arquivos existentes.
    m[f]    Mover para o arquivo [apenas arquivos]. Ao mover arquivos e
            diretórios irá resultar numa eliminação dos arquivos e
            diretórios após uma operação de compressão bem sucedida.
            Os diretórios não serão removidos se o modificador 'f' for
            utilizado e/ou o comando adicional '-ed' for aplicado.    
*/

Return(lRet)