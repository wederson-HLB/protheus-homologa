#Include "Protheus.ch"
#Include "Ap5mail.ch"
#Include "Topconn.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTCORP30
Parametros  : 
Retorno     : Nil
Objetivos   : Fonte utilizado por schedules ou via menu, para envio de e-mail para os sócios responsáveis por seus contratos, com a informação analitica das Notas Fiscais
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012    16:16
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/
*----------------------------*
User Function GTCORP30(aParam)
*----------------------------*
Private cTipo:=""

if Select("SX3")<=0
	cEmp	:=aParam[1]//Empresa que deverá ser executada a função
	cFil	:=aParam[2]//Filial que sera executada a função

	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cEmp Filial cFil
	cTipo:="1"
else
	cTipo:="2"
endif

Private aArea		:=GETAREA()
Private cNomeEmp	:=""
Private aSocios:={}

Private dGet1	:=CTOD("//")
Private dGet2	:=CTOD("//")
Private lEnviEma:=.F.

if !cEmpAnt $ "ZB"
	if cTipo=="1"
		CONOUT("Função não disponível para a empresa!")
	else
		Alert("Função não disponível para a empresa!")
	endif
	Return()
endif
                                                                                     
SET DATE FORMAT "dd/mm/yyyy"

aSocios:=QuerySocio(cTipo)

if cTipo=="2"
	if !OPCSOC(aSocios)
		return()
	endif
endif

Private oDlg

if cTipo=="2"
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},len(aSocios),oDlg,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg CENTERED ON INIT(GeraEmail(oMeter,oDlg))
	  
	//*************************************
else
	GeraEmail()
endif

RestArea(aArea)
Return

Static function GeraEmail(oMeter,oDlg)
    
if cTipo=="2"	
	//Inicia a régua
	oMeter:Set(0)
endif

For nSeq:=1 to len(aSocios)

	if cTipo=="2"	
	    //Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=1 // atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua
	endif

	_cTo:=""	
	//Monta o corpo do e-mail
	cMsg:=MontaEm1(cTipo,aSocios[nSeq][1],dGet1,dGet2)

	if empty(cMsg) .AND. cTipo=="2"	
		Alert("Não existem dados no periodo selecionado para o sócio:"+alltrim(aSocios[nSeq][1])+" - "+alltrim(aSocios[nSeq][2])+CRLF+"Portanto não será enviado e-mail para o mesmo!")
		loop
	endif
		
		DBSelectArea("SM0")
		DbSetOrder(1)
		DbSeek(cEmpAnt)
		if cEmpAnt $ "ZB"
			cNomeEmp:="Grant Thornton Auditores"
		endif	
		cAssunto:="Faturamento "+cNomeEmp
		
		if empty(aSocios[nSeq][1])
			//_cTo:="matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com"
			_cTo:="henrique.marques@br.gt.com"
			cAssunto:="Faturamento "+cNomeEmp+", sem socio responsavel."
		else
			//_cTo:="matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com"
			_cTo:=aSocios[nSeq][2]
			//conout(aSocios[nSeq][2])
			
		endif
		
		//Envia o e-mail
		ENVIA_EMAIL("","Faturamento",cAssunto,cMsg,_cTo,"")
		lEnviEma:=.T.
Next

if cTipo=="2"	
	if lEnviEma
		MsgInfo("E-mails enviados!")
	endif
	oDlg:end()
endif

Return 

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cArquivo,cTitulo,cSubject,cBody,cTo,cCC
Retorno     : .T.
Objetivos   : Função para envio do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012
*/

*-----------------------------------------------------------------------------------------*
Static Function ENVIA_EMAIL(cArquivo,cTitulo,cSubject,cBody,cTo,cCC)
*-----------------------------------------------------------------------------------------*
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg
Local cBody1:=""
Local cCC      := "henrique.marques@br.gt.com"

DEFAULT cArquivo := ""
DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT cTo      := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   

cFrom:=cAccount

cAttachment:=cArquivo
/***********************GERANDO DO ARQUIVO EXCEL, Para anexo************************************/
Private cDest :=  "\"+CURDIR()//Retorna o diretório corrente do servidor   //GetTempPath()

	cArq := alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cBody ) // Gravação do seu Conteudo.
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		CONOUT("Erro de gravação do Destino. ROTINA: GTCORP16 . Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado	
		cAttachment:=cDest+cArq
	endif
/***********************FIM DA GERAÇÃO DO ARQUIVO EXCEL, Para anexo************************************/

cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      BCC "matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com";
      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com";
      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
   ConOut("E-mail enviado com sucesso.")
ENDIF   

FERASE (cDest+cArq)

RETURN .T.

/*
Funcao      : MontaEm1()
Parametros  : cTipo,cSocio
Retorno     : _cHtml
Objetivos   : Monta a estrutura do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012	16:41
*/

*-----------------------------------*
Static Function MontaEm1(cTipo,cSocio,dGet1,dGet2)
*-----------------------------------*
Local _cSubject	:= ""
Local _cTo		:= ""
Local cHtml	:= ""        
LOCAL _ccopia  	:= ""
Local _cENVIA  	:= ""
Local _cArqD   	:= ""                                                      	
Local _cNomeCli :=''


Local cHtmlAux1:=""
Local cHtmlAux2:=""
Local aDados:=Query(cTipo,cSocio,dGet1,dGet2)
Local cDado:=""

if empty(aDados)
	Return(cHtml)
endif

cHtml+='   <html xmlns="http://www.w3.org/1999/xhtml">'
cHtml+='   <head>'
cHtml+='   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'

cHtml+='   <style type="text/css">
cHtml+='   .CorTopo{
cHtml+='   		background-color:#7A59A5;
cHtml+='   	 	color:#FFFFFF;
cHtml+='   }
cHtml+='   .CorLinha{'
cHtml+='   		background-color:#AA92C7;
cHtml+='   }  
cHtml+='   .Borda{'
cHtml+='		border-top-style:solid;'
cHtml+='		border-right-style:solid;'
cHtml+='		border-bottom-style:solid;'
cHtml+='		border-left-style:solid;'
cHtml+='  		border-width: 0.5px;'
cHtml+=' 		border-color:#000000;'
cHtml+=' 		border-collapse:collapse;'
cHtml+='   }' 
cHtml+='   .CorTopoBorda{'
cHtml+='   		background-color:#7A59A5;'

cHtml+='		filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#CCCCCC", endColorstr="#7A59A5"); /* IE */'
cHtml+='		background: -webkit-gradient(linear, left top, left bottom, from(#CCCCCC), to(#7A59A5)); /* webkit browsers */'
cHtml+='		background: -moz-linear-gradient(top,  #CCCCCC,  #7A59A5); /* Firefox 3.6+ */'

cHtml+='   	 	color:#FFFFFF;'
cHtml+=' 		font-weight:bold;'
cHtml+='		border-top-style:solid;'
cHtml+='		border-right-style:solid;'
cHtml+='		border-bottom-style:solid;'
cHtml+='		border-left-style:solid;'
cHtml+='  		border-width: 0.5px;'
cHtml+=' 		border-color:#000000;'
cHtml+=' 		border-collapse:collapse;'
cHtml+='   }' 
cHtml+='   .CorLinhaBorda{'
cHtml+='   		background-color:#AA92C7;'
cHtml+='		border-top-style:solid;'
cHtml+='		border-right-style:solid;'
cHtml+='		border-bottom-style:solid;'
cHtml+='		border-left-style:solid;'
cHtml+='  		border-width: 0.5px;'
cHtml+=' 		border-color:#000000;'
cHtml+=' 		border-collapse:collapse;'
cHtml+='   }'  
cHtml+='   </style>

cHtml+='   </head>'
cHtml+='   <body marginheight="0" marginwidth="0" style="margin:0">'

cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">'


//Pega a Posição da data no array
nPosData:=aScan(aDados[1],{|x| Alltrim(x) == "Emissao"})
//Pega a Posição do valor original no array
nPosValor:=aScan(aDados[1],{|x| Alltrim(x) == "Valor Original"})

For i:=1 to len(aDados)

	cHtml+='   <tr>'
		
		For j:=1 to len(aDados[i])-3	

			if ValType(aDados[i][j])=="N"
				cDado:=alltrim(TRANS(aDados[i][j],"@E 999,999,999,999.99"))
			else
				cDado:=alltrim(aDados[i][j])
			endif

			if i==1
				cHtml+='   <td align="center" class="CorTopoBorda">'+cDado+'</td>'
			else
				if i%2<>0
					if j==nPosData
						cHtml+='   <td class="CorLinhaBorda" align="center">'+DTOC(STOD(cDado))+'</td>'
					elseif j==nPosValor
						cHtml+='   <td align="right" class="CorLinhaBorda">'+cDado+'</td>'
					else
						cHtml+='   <td class="CorLinhaBorda">'+cDado+'</td>'
					endif
				else
					if j==nPosData
						cHtml+='   <td class="Borda" align="center">'+DTOC(STOD(cDado))+'</td>'
					elseif j==nPosValor
						cHtml+='   <td align="right" class="Borda">'+cDado+'</td>'
					else
						cHtml+='   <td class="Borda">'+cDado+'</td>'
					endif				
				endif
				
			endif
		Next
		
	cHtml+='   </tr>'	
Next

cHtml+='   </table>'
cHtml+='   <br>'
cHtml+='   Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.'

cHtml+=' </body>'
cHtml+=' </html>'
	
Return(cHtml)

/*
Funcao      : Query()
Parametros  : cTipo,cSocio
Retorno     : aDados
Objetivos   : Cria a query e retorna um array com as informações |Nº Contrato|Cliente|Título|Vencimento|Valor Original|Saldo|Dias Vencidos|Cod Sócio|Nome Socio|E-mail Socio
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012	09:41
*/

*-----------------------------*
Static Function Query(cTipo,cSocio)
*-----------------------------*
Local cQry		:=""
Local aDados	:={}
Local nTotQtde	:=0	//Variavel para total
Local nTotValor	:=0	//Variavel para total
Local nTotSaldo	:=0	//Variavel para total

conout("SOcio:"+valtype(cSocio))
cQry+=" SELECT CN9.CN9_P_NUM,
cQry+=" CN9.CN9_NUMERO, 
cQry+=" SA1.A1_COD+' - '+SA1.A1_NOME AS CLIENTE,
cQry+=" SF2.F2_SERIE+' '+SF2.F2_DOC AS NF,
cQry+=" SF2.F2_EMISSAO AS EMISSAO,
cQry+=" SF2.F2_VALBRUT AS VALOR,
cQry+=" CN9.CN9_P_GER,
cQry+=" ISNULL(SA3.A3_NOME,'') AS A3_NOME,
cQry+=" ISNULL(SA3.A3_EMAIL,'') A3_EMAIL
cQry+=" FROM "+RETSQLNAME("SF2")+" SF2
cQry+=" JOIN "+RETSQLNAME("SD2")+" SD2 ON SD2.D2_DOC=SF2.F2_DOC
cQry+=" JOIN "+RETSQLNAME("SC5")+" SC5 ON SD2.D2_PEDIDO=SC5.C5_NUM
cQry+=" JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9.CN9_NUMERO=SC5.C5_MDCONTR
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA
cQry+=" LEFT JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD=CN9.CN9_P_GER
cQry+=" WHERE C5_MDCONTR<>'' AND SC5.D_E_L_E_T_='' AND SF2.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
cQry+=" AND SD2.D2_CLIENTE NOT IN ('001721','001015')" //MSM - Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
cQry+=" AND SD2.D2_SERIE<>'ND' AND SF2.F2_SERIE<>'ND'"
cQry+=" AND CN9.CN9_P_GER='"+cSocio+"'"

if cTipo=="2"
	cQry+=" AND SF2.F2_EMISSAO BETWEEN '"+DTOS(dGet1)+"' AND '"+DTOS(dGet2)+"'"
endif

cQry+=" GROUP BY CN9_P_NUM,CN9.CN9_NUMERO,SA1.A1_COD+' - '+SA1.A1_NOME,SF2.F2_SERIE+' '+SF2.F2_DOC,SF2.F2_EMISSAO,SF2.F2_VALBRUT,CN9.CN9_P_GER, A3_NOME, A3_EMAIL
cQry+=" ORDER BY CN9_P_GER,EMISSAO

/*
SELECT CN9.CN9_P_NUM,
CN9.CN9_NUMERO, 
SA1.A1_COD+' - '+SA1.A1_NOME AS CLIENTE,
SF2.F2_SERIE+' '+SF2.F2_DOC AS NF,
SF2.F2_EMISSAO AS EMISSAO,
SF2.F2_VALBRUT AS VALOR,
CN9.CN9_P_GER,
ISNULL(SA3.A3_NOME,'') AS A3_NOME,
ISNULL(SA3.A3_EMAIL,'') A3_EMAIL
FROM SF2ZB0 SF2
JOIN SD2ZB0 SD2 ON SD2.D2_DOC=SF2.F2_DOC
JOIN SC5ZB0 SC5 ON SD2.D2_PEDIDO=SC5.C5_NUM
JOIN CN9ZB0 CN9 ON CN9.CN9_NUMERO=SC5.C5_MDCONTR
JOIN SA1ZB0 SA1 ON SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA
LEFT JOIN SA3ZB0 SA3 ON SA3.A3_COD=CN9.CN9_P_GER
WHERE C5_MDCONTR<>'' AND SC5.D_E_L_E_T_='' AND SF2.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
AND SD2.D2_CLIENTE NOT IN ('001721','001015')" --//MSM - Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
AND SD2.D2_SERIE<>'ND'"
--AND CN9.CN9_P_GER='"+cSocio+"'
GROUP BY CN9_P_NUM,CN9.CN9_NUMERO,SA1.A1_COD+' - '+SA1.A1_NOME,SF2.F2_SERIE+' '+SF2.F2_DOC,SF2.F2_EMISSAO,SF2.F2_VALBRUT,CN9.CN9_P_GER, A3_NOME, A3_EMAIL
ORDER BY CN9_P_GER,EMISSAO
*/    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0

			AADD(aDados,{"Proposta","Nº Contrato","Cliente","Nota Fiscal","Emissao","Valor Original","","",""})
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())

				AADD(aDados,{QRYTEMP->CN9_P_NUM,QRYTEMP->CN9_NUMERO,QRYTEMP->CLIENTE,QRYTEMP->NF,QRYTEMP->EMISSAO,QRYTEMP->VALOR,QRYTEMP->CN9_P_GER,QRYTEMP->A3_NOME,QRYTEMP->A3_EMAIL})
				nTotValor+=QRYTEMP->VALOR
				nTotQtde++
				QRYTEMP->(DbSkip())
			Enddo
				AADD(aDados,{"<b><center>TOTAIS</center></b>","&nbsp;","&nbsp;","<center>"+cvaltochar(nTotQtde)+" notas</center>","",nTotValor,"","",""})
		endif
Return(aDados)

/*
Funcao      : QuerySocio()
Parametros  : cTipo
Retorno     : aSocios
Objetivos   : Cria a query e retorna um array com as informações |Cod Sócio|E-mail Socio|
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012	09:41
*/
*-------------------------------*
Static Function QuerySocio(cTipo)
*-------------------------------*
Local cQry:=""
Local aSocios:={}

cQry+=" SELECT CN9.CN9_P_GER,SA3.A3_EMAIL
cQry+=" FROM "+RETSQLNAME("SF2")+" SF2
cQry+=" JOIN "+RETSQLNAME("SD2")+" SD2 ON SD2.D2_DOC=SF2.F2_DOC
cQry+=" JOIN "+RETSQLNAME("SC5")+" SC5 ON SD2.D2_PEDIDO=SC5.C5_NUM
cQry+=" JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9.CN9_NUMERO=SC5.C5_MDCONTR
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA
cQry+=" LEFT JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD=CN9.CN9_P_GER
cQry+=" WHERE C5_MDCONTR<>'' AND SC5.D_E_L_E_T_='' AND SF2.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
cQry+=" AND SD2.D2_CLIENTE NOT IN ('001721','001015')" //MSM - Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
cQry+=" AND SD2.D2_SERIE<>'ND' AND SF2.F2_SERIE<>'ND'"
cQry+=" GROUP BY CN9.CN9_P_GER,SA3.A3_EMAIL
cQry+=" ORDER BY CN9_P_GER

/*
SELECT CN9.CN9_P_GER,SA3.A3_EMAIL
FROM SF2ZB0 SF2
JOIN SD2ZB0 SD2 ON SD2.D2_DOC=SF2.F2_DOC
JOIN SC5ZB0 SC5 ON SD2.D2_PEDIDO=SC5.C5_NUM
JOIN CN9ZB0 CN9 ON CN9.CN9_NUMERO=SC5.C5_MDCONTR
JOIN SA1ZB0 SA1 ON SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA
LEFT JOIN SA3ZB0 SA3 ON SA3.A3_COD=CN9.CN9_P_GER
WHERE C5_MDCONTR<>'' AND SC5.D_E_L_E_T_='' AND SF2.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
AND SD2.D2_CLIENTE NOT IN ('001721','001015')" --MSM - Adicionado a pedido da Haidee - 17/05/2012 - AND D2_CLIENTE<>'001721'
AND SD2.D2_SERIE<>'ND'"
GROUP BY CN9.CN9_P_GER,SA3.A3_EMAIL
ORDER BY CN9_P_GER
*/

		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0

			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())

				AADD(aSocios,{QRYTEMP->CN9_P_GER,QRYTEMP->A3_EMAIL})
				QRYTEMP->(DbSkip())
			Enddo
		
		endif

Return(aSocios)


/*
Funcao      : OPCGER
Parametros  : 
Retorno     : 
Objetivos   : Função para gerar tela para seleção do socio
Autor       : Matheus Massarotto
Data/Hora   : 18/07/2012
*/
*----------------------------*
Static Function OPCSOC(aSocio)
*----------------------------*
Private oOk := LoadBitmap( GetResources(), "LBOK")
Private oNo := LoadBitmap( GetResources(), "LBNO")
Private oChkQual,lQual,oQual,cVarQ,oDlg2,oGet1,oGet2
Private aParam:=aSocio
Private aListBox1:={}
Private lSair:=.F.

for i:=1 to len(aParam)
	AADD(aListBox1,{.F.,aParam[i][1],aParam[i][2]})	
next 

DEFINE MSDIALOG oDlg2 TITLE "Selecione o(s) sócio(s) para busca das Notas Fiscais" FROM C(212),C(242) TO C(548),C(583) PIXEL

	@ C(001),C(12) CHECKBOX oChkQual VAR lQual PROMPT "Inverte Seleção" SIZE 50, 10;
	OF oDlg2 PIXEL;
	ON CLICK (AEval(aListBox1, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),;
	oQual:Refresh(.F.))
 
	
	@ C(010),C(012) LISTBOX oQual VAR cVarQ Fields HEADER "","Codigo","E-mail" SIZE;
    C(145),C(125) ON DBLCLICK (aListBox1:=Troca(oQual:nAt,aListBox1),oQual:Refresh()) NoScroll OF oDlg2 PIXEL

	@ C(143),C(009) Say "Data de:" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg2
	@ C(142),C(030) MsGet oGet1 Var dGet1 Size C(040),C(007) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg2

	@ C(143),C(099) Say "Data Ate:" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg2
	@ C(142),C(120) MsGet oGet2 Var dGet2 Size C(040),C(007) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg2
	
	oQual:SetArray(aListBox1)

	oQual:bLine := { || {If(aListBox1[oQual:nAt,1],oOk,oNo),aListBox1[oQual:nAt,2],aListBox1[oQual:nAt,3]}}
			
	// Cria Componentes Padroes do Sistema
	@ C(158),C(023) Button "Ok" Size C(037),C(012) action( Ok() ) PIXEL OF oDlg2
	@ C(158),C(106) Button "Sair" Size C(037),C(012) action(oDlg2:end()) PIXEL OF oDlg2

ACTIVATE MSDIALOG oDlg2 CENTERED 

Return(lSair)

/*
Funcao      : Troca  
Parametros  : nIt,aArray
Retorno     : aArray
Objetivos   : Função para trocar a Lógica do primeiro campo, (.T. / .F.), mudando assim a imagem do check
Autor       : Matheus Massarotto
Data/Hora   : 18/07/2012
*/
*-------------------------------*
Static Function Troca(nIt,aArray)
*-------------------------------*
aArray[nIt,1] := !aArray[nIt,1]
Return aArray     

/*
Funcao      : MarcaOk()  
Parametros  : aArray
Retorno     : lRet
Objetivos   : Verifica Se existe algum CheckBox, marcado;Se não tiver nenhum marcado exibe uma msg!
Autor       : Matheus Massarotto
Data/Hora   : 18/07/2012
*/
*-----------------------------*
Static Function MarcaOk(aArray)
*-----------------------------*
Local lRet:=.F.
Local nx:=0

// Checa marcações efetuadas
For nx:=1 To Len(aArray)
	If aArray[nx,1]
		lRet:=.T.
	EndIf
Next nx

// Checa se existe algum item marcado na confirmação
If !lRet
	HELP("SELFILE",1,"HELP","Atenção","Não existem itens marcados",1,0)
EndIf
Return lRet  

/*
Funcao      : Arraytrue()  
Parametros  : aArray
Retorno     : aArray
Objetivos   : Função gera e retorna o array só com os sócios marcados, sem o campo lógico
Autor       : Matheus Massarotto
Data/Hora   : 18/07/2012
*/
*--------------------------------*
Static Function Arraytrue(aArray)
*--------------------------------*

Private aArray2:={}

For i:=1 to len(aArray)
	If aArray[i][1]
		AADD(aArray2,{})
		for j:=2 to len(aArray[i])
			AADD(aArray2[len(aArray2)],aArray[i][j])
		next
	Endif 
Next

return aArray2

/*
Funcao      : Ok()  
Parametros  : 
Retorno     : 
Objetivos   : Verificar se esta tudo correto para dar andamento a rotina
Autor       : Matheus Massarotto
Data/Hora   : 18/07/2012
*/
*-------------------*
Static Function Ok()
*-------------------*

if empty(dGet1) .OR. empty(dGet2)
	Alert("Os campos data devem ser preenchidos!")
	Return()
elseif dGet2<dGet1
	Alert("Campo Data Ate, deve ser maior ou igual ao campo Data De!")
	Return
endif

if(MarcaOk(aListBox1))
	aSocios:=Arraytrue(aListBox1)
	lSair:=.T.
	oDlg2:end()
endif

Return