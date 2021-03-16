#Include "Protheus.ch"
#Include "Ap5mail.ch"
#Include "Topconn.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTCORP16
Parametros  : cTipo ('1')- Retorna os que estão 6 dias vencidos / ('2')- Retorna os que estão 6 dias vencidos e os a Vencer
Retorno     : Nil
Objetivos   : Fonte utilizado por schedules, para envio de e-mail para os sócios responsáveis por seus contratos, dos quais os títulos (SE1) estão vencendo.
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012    10:34
Revisão		: Jean Victor Rocha
Data/Hora   : 09/05/2013
Objetivo	: Tratamentos para execução atraves do menu e melhorias diversas.
Módulo      : Genérico
*/
*-----------------------------*
User Function GTCORP16(aParam)
*-----------------------------*
Private lJob := Select("SX3") <= 0

Default aParam := {"1","ZB","01"}

If !lJob
	aParam[2] := cEmpAnt
	aParam[3] := cFilAnt
Endif

cTipo_	:=aParam[1]//('1')- Retorna os que estão 6 dias vencidos / ('2')- Retorna os que estão 6 dias vencidos e os a Vencer
cEmp	:=aParam[2]//Empresa que deverá ser executada a função
cFil	:=aParam[3]//Filial que sera executada a função

If lJob
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cEmp Filial cFil
Else      
	cTipo_	:= "2"
	cPerg := "GTCORP16"
	AjustaSX1()
	
	If !Pergunte(cPerg)  
		Return .T.
	EndIf
	
	cCliDe	:= Mv_Par01
	cCliAte	:= Mv_Par02
	cSocDe	:= Mv_Par03
	cSocAte	:= Mv_Par04
	nTpVenc	:= Mv_par05
	cEmail	:= Mv_par06

Endif

Private aArea	:= GETAREA()
Private aSocios	:= {}

Private lUsaGeCta	:= .T.
Private lUsaGeCtb	:= .T.
Private lUsaSocio	:= .T.
    
CN9->(DbSetOrder(1))
                                                                                     
SET DATE FORMAT "dd/mm/yyyy"
                           
If cEmpAnt $ "ZB/ZF/ZG"//Novo Tratamento para ZB e ZF
	cSocio := ""

	aInfos	:= QueryAud()
	
	//Tratamento para Quando não tiver dados para impressão
	If Len(aInfos) == 0
		If !lJob
			MsgInfo("Sem dados para impressão!","Grant Thornton Brasil")
		EndIf
		Return .T.
	EndIf      
	
	aSocios := aInfos  
	
	For i:=1 to len(aSocios)//Socios
		lEnvia := .F.
		cMsgEmail := ""
		cMsgEmail += MailAud(0,aSocios[i][1])//Impressão da inicialização do Email

		//Detalhes
		If lJob .or.;//AMBOS via Job.
			nTpVenc == 3//AMBOS Titulos a Vencer e Vencidos.
			If Len(aSocios[i][2][1][2]) >= 2//Verifica se possui Dados
				cMsgEmail += MailAud(1		,aSocios[i][2][1][2])//Titulos Vencidos.
				lEnvia := .T.
			EndIf
			If Len(aSocios[i][2][2][2]) >= 2//Verifica se possui Dados
				cMsgEmail += MailAud(2		,aSocios[i][2][2][2])//Titulos a Vencer
				lEnvia := .T. 
			EndIf
		ElseIf Len(aSocios[i][2][nTpVenc][2]) >= 2//Verifica se possui Dados
			cMsgEmail += MailAud(nTpVenc,aSocios[i][2][nTpVenc][2])//Titulos Definido no Parametro do Pergunte Vencidos OU a Vencer.
			lEnvia := .T.
		EndIf
		cMsgEmail += MailAud(9)	//Encerramento

		If lEnvia
			SendSocio(aSocios[i][1],cMsgEmail)//Envio do Email para o Socio
		EndIf
	Next i                                      
Else

	if lUsaGeCta
		PrepEmai("CTA")
	endif
	if lUsaGeCtb
		PrepEmai("CTB")
	endif
	if lUsaSocio
		PrepEmai("SOC")
	endif

/*
	aSocios:=QuerySocio(cTipo_)
	For nSeq:=1 to len(aSocios)
		_cTo:=""	
	
		cMsg := MontaEm1(cTipo_,aSocios[nSeq][1],aSocios[nSeq][2])//Monta o corpo do e-mail
	
		DBSelectArea("SM0")
		DbSetOrder(1)
		DbSeek(cEmpAnt)

		cAssunto:="Posicao de Cobrancas"	

		If lJob	
			if empty(aSocios[nSeq][1])
				_cTo:="renato.oliveira@br.gt.com"
				cAssunto:="Posicao de Cobrancas "+SM0->M0_NOME+", sem socio responsavel."
			else
				_cTo:=aSocios[nSeq][2]
			endif 
		Else
			If empty(aSocios[nSeq][1]) 
				cAssunto:="Posicao de Cobrancas, sem socio responsavel."
			EndIf
			_cTo := cEmail
		EndIf
			     
		//Envia o e-mail
		If !EMPTY(cMsg)
			ENVIA_EMAIL("","Posição Cobranças",cAssunto,cMsg,_cTo,"")
		EndIf
	Next
*/
EndIf

If !lJob
	MsgInfo("Processamento Finalizado!")
EndIf

RestArea(aArea)
Return 

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cArquivo,cTitulo,cSubject,cBody,cTo,cCC
Retorno     : .T.
Objetivos   : Função para envio do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012
*/
*------------------------------------------------------------------*
Static Function ENVIA_EMAIL(cArquivo,cTitulo,cSubject,cBody,cTo,cCC)
*------------------------------------------------------------------*
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg
Local cBody1:=""
Local cCC      :=""

DEFAULT cArquivo := ""
DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT cTo      := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
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
	if nBytesSalvo > 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
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

If lOK
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   If lJob
	   IF !EMPTY(cCC)
	      SEND MAIL FROM cFrom TO cTo CC cCC;
	      BCC "log.sistemas@br.gt.com";
	      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
	   ELSE
	      SEND MAIL FROM cFrom TO cTo;
	      BCC "log.sistemas@br.gt.com";
	      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
	   ENDIF   
	Else
		IF !EMPTY(cCC)
	      SEND MAIL FROM cFrom TO cTo CC cCC;
	      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
	   ELSE
	      SEND MAIL FROM cFrom TO cTo;
	      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
	   ENDIF 
	EndIf
ENDIF

DISCONNECT SMTP SERVER

FERASE (cDest+cArq)

RETURN .T.

/*
Funcao      : MontaEm1()
Parametros  : cTipo_,cSocio
Retorno     : _cHtml
Objetivos   : Monta a estrutura do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012	16:41
*/
*--------------------------------------------------------*
Static Function MontaEm1(cTipo_,cSocio,cEmaSoc,cQualResp)
*--------------------------------------------------------*
Local _cSubject	:= ""
Local _cTo		:= ""
Local cHtml		:= ""        
LOCAL _ccopia  	:= ""
Local _cENVIA  	:= ""
Local _cArqD   	:= ""                                                      	
Local _cNomeCli := ""
Local lEmptyQry := .F.

Local cHtmlAux1	:= ""
Local cHtmlAux2	:= ""
Local cDado		:= ""
Local aDados	:= Query(cTipo_,cSocio,cQualResp)

If empty(aDados)
	lEmptyQry := .T.
Endif

cHtml+='   <html xmlns="http://www.w3.org/1999/xhtml">'
cHtml+='   <head>'
cHtml+='   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
cHtml+='   <style type="text/css">
cHtml+='   body {
cHtml+='   		font-family:"Arial";             
cHtml+='   		margin:0; 
cHtml+='   }
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
cHtml+='   <body marginheight="0" marginwidth="0" >'

if cQualResp == "SOC"
	cHtml+=' Socio: '+ cSocio + ' Email:'+cEmaSoc 
elseif cQualResp == "CTA"
	cHtml+=' Gerente Conta: '+ cSocio + ' Email:'+cEmaSoc 
elseif cQualResp == "CTB"
	cHtml+=' Gerente Contábil: '+ cSocio + ' Email:'+cEmaSoc 
endif

cHtml+='	<br>'

If (lJob .Or. nTpVenc <> 2) .And. !lEmptyQry
	nPosData	:=aScan(aDados[1],{|x| Alltrim(x) == "Vencimento"})//Pega a Posição da data no array
	nPosData2	:=aScan(aDados[1],{|x| Alltrim(x) == "Emissao"})//Pega a Posição da data no array
	nPosValor	:=aScan(aDados[1],{|x| Alltrim(x) == "Valor Original R$"})//Pega a Posição do valor original no array
	nPosSaldo	:=aScan(aDados[1],{|x| Alltrim(x) == "Saldo Liq R$"})//Pega a Posição do saldo no array
	nPosDias	:=aScan(aDados[1],{|x| Alltrim(x) == "Dias Vencidos"})	//Pega a Posição dos dias vencidos
	nPosMoeda	:=aScan(aDados[1],{|x| Alltrim(x) == "Moeda"})//Pega a Posição da Moeda
	
	cHtml+='   <p align="center"><b> Vencidos </b></p>
	cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">'
	For i:=1 to len(aDados)
		cHtml+='   <tr>'
			For j:=1 to len(aDados[i])-3	
				if ValType(aDados[i][j])=="N"
					if j==nPosDias .or. (nPosMoeda <> 0 .And. j==nPosMoeda)
						cDado:=alltrim(cvaltochar(aDados[i][j]))
					else	
						cDado:=alltrim(TRANS(aDados[i][j],"@E 999,999,999,999.99"))
					endif
					
				else
					cDado:=alltrim(aDados[i][j])
				endif

				if i==1
					cHtml+='   <td align="center" class="CorTopoBorda" >'+cDado+'</td>'
				else
					if i%2<>0
						if j==nPosData .or. (nPosData2 <> 0 .and. j==nPosData2)
							cHtml+='   <td class="CorLinhaBorda" align="center" >'+DTOC(STOD(cDado))+'</td>'
						elseif j==nPosValor .OR. j==nPosSaldo
							cHtml+='   <td align="right" class="CorLinhaBorda" >'+cDado+'</td>'
						elseif j==nPosDias .or. (nPosMoeda <> 0 .And. j==nPosMoeda) 
							cHtml+='   <td align="center" class="CorLinhaBorda" >'+cDado+'</td>'
						else
							cHtml+='   <td class="CorLinhaBorda" >'+cDado+'</td>'
						endif
					else
						if j==nPosData .or. (nPosData2 <> 0 .and. j==nPosData2)
							cHtml+='   <td class="Borda" align="center">'+DTOC(STOD(cDado))+'</td>'
						elseif j==nPosValor .OR. j==nPosSaldo
							cHtml+='   <td align="right" class="Borda">'+cDado+'</td>'
						elseif j==nPosDias .or. (nPosMoeda <> 0 .And. j==nPosMoeda)
							cHtml+='   <td align="center" class="Borda">'+cDado+'</td>'
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
EndIf
	
//if (lJob .And. cTipo_=="2") .or. (!lJob .And. nTpVenc <> 1)
if lJob .or. (!lJob .And. nTpVenc <> 1)
	cHtmlAux := MontaEm2(cTipo_,cSocio,cEmaSoc,cQualResp)
	If Empty(cHtmlAux) .and. lEmptyQry
		cHtml:=""
		Return cHtml
	EndIf
	cHtml+=cHtmlAux
	If lJob
		cHtml+='   Pagamentos realizados na sexta-feira anterior só serão excluidos deste relatório na terça-feira.'
		cHtml+='   <br>'
	EndIf
endif
cHtml+='   Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.'
cHtml+=' </body>'
cHtml+=' </html>'
	
Return(cHtml)

/*
Funcao      : MontaEm2()
Parametros  : cTipo_,cSocio
Retorno     : _cHtml
Objetivos   : Monta a estrutura do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012	16:41
*/
*---------------------------------------------*
Static Function MontaEm2(cTipo_,cSocio,cEmaSoc,cQualResp)
*---------------------------------------------*
Local _cSubject	:= ""
Local _cTo		:= ""
Local cHtml		:= ""        
LOCAL _ccopia  	:= ""
Local _cENVIA  	:= ""
Local _cArqD   	:= ""                                                      	
Local _cNomeCli :=''

Local cHtmlAux1	:=""
Local cHtmlAux2	:=""
Local aDados	:=Query2(cTipo_,cSocio,cQualResp)
Local cDado		:=""

If empty(aDados)
	return(cHtml)
Endif

cHtml+='   </br>
cHtml+='   <p align="center"><b> A vencer </b></p>
cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">'

nPosData:=aScan(aDados[1],{|x| Alltrim(x) == "Vencimento"})//Pega a Posição da data no array
nPosData2:=aScan(aDados[1],{|x| Alltrim(x) == "Emissao"})
nPosValor:=aScan(aDados[1],{|x| Alltrim(x) == "Valor Original R$"})//Pega a Posição do valor original no array
nPosSaldo:=aScan(aDados[1],{|x| Alltrim(x) == "Saldo Liq R$"})//Pega a Posição do saldo no array
nPosDias:=aScan(aDados[1],{|x| Alltrim(x) == "Dias a Vencer"})//Pega a Posição dos dias vencidos
nPosMoeda:=aScan(aDados[1],{|x| Alltrim(x) == "Moeda"})//Pega a Posição da Moeda

For i:=1 to len(aDados)
	cHtml+='   <tr>'
		For j:=1 to len(aDados[i])-3	
			if ValType(aDados[i][j])=="N"
				if j==nPosDias .or. (nPosMoeda <> 0 .And. j==nPosMoeda)
					cDado:=alltrim(cvaltochar(aDados[i][j]))
				else	
					cDado:=alltrim(TRANS(aDados[i][j],"@E 999,999,999,999.99"))
				endif
				
			else
				cDado:=alltrim(aDados[i][j])
			endif

			if i==1
				cHtml+='   <td align="center" class="CorTopoBorda">'+cDado+'</td>'
			else
				if i%2<>0
					if j==nPosData .or. (nPosData2 <> 0 .and. j==nPosData2)
						cHtml+='   <td class="CorLinhaBorda" align="center">'+DTOC(STOD(cDado))+'</td>'
					elseif j==nPosValor .OR. j==nPosSaldo
						cHtml+='   <td align="right" class="CorLinhaBorda">'+cDado+'</td>'
					elseif j==nPosDias .or. (nPosMoeda <> 0 .And. j==nPosMoeda)
						cHtml+='   <td align="center" class="CorLinhaBorda">'+cDado+'</td>'
					else
						cHtml+='   <td class="CorLinhaBorda">'+cDado+'</td>'
					endif
				else
					if j==nPosData .or. (nPosData2 <> 0 .and. j==nPosData2)
						cHtml+='   <td class="Borda" align="center">'+DTOC(STOD(cDado))+'</td>'
					elseif j==nPosValor .OR. j==nPosSaldo
						cHtml+='   <td align="right" class="Borda">'+cDado+'</td>'
					elseif j==nPosDias .or. (nPosMoeda <> 0 .And. j==nPosMoeda)
						cHtml+='   <td align="center" class="Borda">'+cDado+'</td>'
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
	
Return(cHtml)

/*
Funcao      : Query()
Parametros  : cTipo_,cSocio
Retorno     : aDados
Objetivos   : Cria a query e retorna um array com as informações (VEncidos)
				|Nº Contrato|Cliente|Titulo|Vencimento|Valor Original|Saldo|Dias Vencidos|Cod Sócio|Nome Socio|E-mail Socio
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012	09:41
*/
*----------------------------------*
Static Function Query(cTipo_,cSocio,cQualResp)
*----------------------------------*
Local cQry		:= ""
Local aDados	:= {}
Local nTotQtde	:= 0	//Variavel para total
Local nTotValor	:= 0	//Variavel para total
Local nTotSaldo	:= 0	//Variavel para total

cQry+=" SELECT '',
cQry+=" '',
cQry+=" SA1.A1_NOME AS CLIENTE,
cQry+=" SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" SE1.E1_PEDIDO AS PEDIDO,
cQry+=" SE1.E1_VENCREA AS VENCTO,
cQry+=" SE1.E1_VLCRUZ AS VALOR,
cQry+=" ROUND((SE1.E1_VLCRUZ*(SE1.E1_SALDO-SE1.E1_DECRESC))/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,

if cQualResp == "SOC"
	cQry+=" SA1.A1_P_SORES AS CPF,
elseif cQualResp == "CTA"
	cQry+=" SA1.A1_P_GECTA AS CPF,
elseif cQualResp == "CTB"
	cQry+=" SA1.A1_P_GECTB AS CPF,
endif

cQry+=" ISNULL(AUX.RA_NOME,'') AS RA_NOME,
cQry+=" ISNULL(AUX.RA_EMAIL,'') RA_EMAIL
cQry+=" ,SE1.E1_EMISSAO, SE1.E1_MOEDA, SIGAMAT.M0_NOME
cQry+=" FROM 		"+RETSQLNAME("SE1")+" SE1
cQry+=" JOIN 		"+RETSQLNAME("SC5")+" SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SE1.E1_FILORIG=SC5.C5_FILIAL
cQry+=" JOIN 		"+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA

if cQualResp == "SOC"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = A1_P_SORES
elseif cQualResp == "CTA"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = A1_P_GECTA
elseif cQualResp == "CTB"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = A1_P_GECTB
endif

cQry+=" LEFT JOIN SIGAMAT ON SIGAMAT.M0_CODIGO = '"+cEmpAnt+"' AND SIGAMAT.M0_CODFIL = SE1.E1_FILORIG
cQry+=" WHERE E1_SALDO>0 AND SC5.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_=''
cQry+=" AND SE1.E1_SITUACA<>'6'
cQry+=" AND (E1_TIPO='NF' OR E1_SERIE='ND')

if cQualResp == "SOC"
	cQry+=" AND SA1.A1_P_SORES='"+cSocio+"' 
elseif cQualResp == "CTA"
	cQry+=" AND SA1.A1_P_GECTA='"+cSocio+"' 
elseif cQualResp == "CTB"
	cQry+=" AND SA1.A1_P_GECTB='"+cSocio+"' 
endif    

If lJob
	If cTipo_=="1"
		cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate()) =6"
	ElseIf cTipo_=="2"
		cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate()) >=6"
	EndIf
Else                                                           
	cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate()) >0"
	If !Empty(cCliDe)
		cQry+=" AND SA1.A1_COD >= '"+cCliDe+"'
	EndIf
	If !Empty(cCliAte)
		cQry+=" AND SA1.A1_COD <= '"+cCliAte+"'
	EndIf
EndIf
cQry+=" GROUP BY SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SE1.E1_PEDIDO,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_VLCRUZ,SE1.E1_SALDO,SE1.E1_DECRESC,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,

if cQualResp == "SOC"
	cQry+=" SA1.A1_P_SORES,
elseif cQualResp == "CTA"
	cQry+=" SA1.A1_P_GECTA,
elseif cQualResp == "CTB"
	cQry+=" SA1.A1_P_GECTB,
endif

cQry+=" RA_NOME, RA_EMAIL
cQry+=" ,SE1.E1_EMISSAO, SE1.E1_MOEDA, SIGAMAT.M0_NOME
cQry+=" ORDER BY CPF,VALOR DESC

If select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount
        
If nRecCount >0
	AADD(aDados,{"Empresa"		,"Cliente"	,"Titulo"	,"Pedido","Emissao"		,"Vencimento"	,"Valor Original R$",;
				"Moeda"		,"Saldo Liq R$"	,"Dias Vencidos","","",""})
	QRYTEMP->(DbGotop())
    
	While QRYTEMP->(!EOF())
		AADD(aDados,{QRYTEMP->M0_NOME,QRYTEMP->CLIENTE,QRYTEMP->NF,QRYTEMP->PEDIDO,QRYTEMP->E1_EMISSAO,QRYTEMP->VENCTO,QRYTEMP->VALOR,;
					QRYTEMP->E1_MOEDA,QRYTEMP->SALDO_LIQ,QRYTEMP->DIAS,QRYTEMP->CPF,QRYTEMP->RA_NOME,QRYTEMP->RA_EMAIL})
		nTotSaldo+=QRYTEMP->SALDO_LIQ
		nTotValor+=QRYTEMP->VALOR
		nTotQtde++
		QRYTEMP->(DbSkip())
	Enddo
	AADD(aDados,{"<b><center>TOTAIS</center></b>","&nbsp;","&nbsp;","<center>"+cvaltochar(nTotQtde)+" titulos</center>",;
					"&nbsp;","",nTotValor,"&nbsp;",nTotSaldo,"&nbsp;","","",""})
EndIf

Return(aDados)

/*
Funcao      : Query2()
Parametros  : cTipo_,cSocio
Retorno     : aDados
Objetivos   : Cria a query e retorna um array com as informações (A Vencer)
				|Nº Contrato|Cliente|Titulo|Vencimento|Valor Original|Saldo|Dias Vencidos|Cod Sócio|Nome Socio|E-mail Socio
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012	09:41
*/
*---------------------------------------------*
Static Function Query2(cTipo_,cSocio,cQualResp)
*---------------------------------------------*
Local cQry		:=""
Local aDados	:={}
Local nTotQtde	:=0	//Variavel para total
Local nTotValor	:=0	//Variavel para total
Local nTotSaldo	:=0	//Variavel para total

cQry+=" SELECT '', 
cQry+=" '',
cQry+=" SA1.A1_NOME AS CLIENTE,
cQry+=" SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" SE1.E1_PEDIDO AS PEDIDO,
cQry+=" SE1.E1_VENCREA AS VENCTO,
cQry+=" SE1.E1_VLCRUZ AS VALOR,
cQry+=" ROUND((SE1.E1_VLCRUZ*(SE1.E1_SALDO-SE1.E1_DECRESC))/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" ABS(datediff(day,SE1.E1_VENCREA,getdate())) AS DIAS,

if cQualResp == "SOC"
	cQry+=" SA1.A1_P_SORES AS CPF,
elseif cQualResp == "CTA"
	cQry+=" SA1.A1_P_GECTA AS CPF,
elseif cQualResp == "CTB"
	cQry+=" SA1.A1_P_GECTB AS CPF,
endif

cQry+=" ISNULL(AUX.RA_NOME,'') AS RA_NOME,
cQry+=" ISNULL(AUX.RA_EMAIL,'') AS RA_EMAIL
cQry+=" ,SE1.E1_EMISSAO, SE1.E1_MOEDA, SIGAMAT.M0_NOME
cQry+=" FROM "+RETSQLNAME("SE1")+" SE1
cQry+=" JOIN "+RETSQLNAME("SC5")+" SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SE1.E1_FILORIG=SC5.C5_FILIAL
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA

if cQualResp == "SOC"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = SA1.A1_P_SORES
elseif cQualResp == "CTA"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = SA1.A1_P_GECTA
elseif cQualResp == "CTB"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = SA1.A1_P_GECTB
endif

cQry+=" LEFT JOIN SIGAMAT ON SIGAMAT.M0_CODIGO = '"+cEmpAnt+"' AND SIGAMAT.M0_CODFIL = SE1.E1_FILORIG
cQry+=" WHERE E1_SALDO>0 AND SC5.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' 
cQry+=" AND SE1.E1_SITUACA<>'6'                              
cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate()) <= 0"
cQry+=" AND (E1_TIPO='NF' OR E1_SERIE='ND')

if cQualResp == "SOC"
	cQry+=" AND SA1.A1_P_SORES='"+cSocio+"'
elseif cQualResp == "CTA"
	cQry+=" AND SA1.A1_P_GECTA='"+cSocio+"'
elseif cQualResp == "CTB"
	cQry+=" AND SA1.A1_P_GECTB='"+cSocio+"'
endif

If !lJob
	If !Empty(cCliDe)
		cQry+=" AND SA1.A1_COD >= '"+cCliDe+"'
	EndIf
	If !Empty(cCliAte)
		cQry+=" AND SA1.A1_COD <= '"+cCliAte+"'
	EndIf
EndIf
cQry+=" GROUP BY SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SE1.E1_PEDIDO,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_VLCRUZ,SE1.E1_SALDO,SE1.E1_DECRESC,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF

if cQualResp == "SOC"
	cQry+=" ,SA1.A1_P_SORES
elseif cQualResp == "CTA"
	cQry+=" ,SA1.A1_P_GECTA
elseif cQualResp == "CTB"
	cQry+=" ,SA1.A1_P_GECTB
endif

cQry+=" ,RA_NOME, RA_EMAIL,SE1.E1_EMISSAO, SE1.E1_MOEDA, SIGAMAT.M0_NOME

//ND
/* //So pAra ZB e ZF 
cQry+="  UNION ALL

cQry+=" SELECT E1_SERIE,
cQry+=" '',
cQry+=" SA1.A1_NOME AS CLIENTE,
cQry+=" SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" SE1.E1_PEDIDO,
cQry+=" SE1.E1_VENCREA AS VENCTO,
cQry +=" SE1.E1_VLCRUZ AS VALOR,
cQry +=" ROUND((SE1.E1_VLCRUZ*SE1.E1_SALDO)/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" ABS(datediff(day,SE1.E1_VENCREA,getdate())) AS DIAS,
cQry+=" SA1.A1_P_VEND,
cQry+=" ISNULL(SA3.A3_NOME,'') AS A3_NOME,
cQry+=" ISNULL(SA3.A3_EMAIL,'') A3_EMAIL
cQry+=" ,SE1.E1_EMISSAO, SE1.E1_MOEDA, SIGAMAT.M0_NOME  
cQry+=" FROM "+RETSQLNAME("SE1")+" SE1
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" LEFT JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD=SA1.A1_P_VEND                              
cQry+=" LEFT JOIN SIGAMAT ON SIGAMAT.M0_CODIGO = '"+cEmpAnt+"' AND SIGAMAT.M0_CODFIL = SE1.E1_FILORIG
cQry+=" WHERE E1_TIPO='NF' AND E1_SERIE='ND'
cQry+=" AND E1_SALDO>0 AND SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
cQry+=" AND SE1.E1_SITUACA<>'6' 
cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate()) <= -1"
cQry+=" AND SA1.A1_P_VEND='"+cSocio+"'
If !lJob
	If !Empty(cCliDe)
		cQry+=" AND SA1.A1_COD >= '"+cCliDe+"'
	EndIf
	If !Empty(cCliAte)
		cQry+=" AND SA1.A1_COD <= '"+cCliAte+"'
	EndIf
EndIf
cQry+=" GROUP BY E1_SERIE,SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,E1_PEDIDO,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_VLCRUZ,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,E1_SALDO,
cQry+=" SA1.A1_P_VEND,A3_NOME,A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,SIGAMAT.M0_NOME
*/
cQry+=" ORDER BY CPF,VALOR DESC  

if select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount
        
if nRecCount >0
	AADD(aDados,{"Empresa"		,"Cliente"	,"Titulo"	,"Pedido","Emissao"		,"Vencimento"			,"Valor Original R$","Moeda"		,"Saldo Liq R$"	,"Dias a Vencer","","",""})
	QRYTEMP->(DbGotop())
    
	While QRYTEMP->(!EOF())
		AADD(aDados,{QRYTEMP->M0_NOME,QRYTEMP->CLIENTE,QRYTEMP->NF,QRYTEMP->PEDIDO,QRYTEMP->E1_EMISSAO,QRYTEMP->VENCTO,QRYTEMP->VALOR,QRYTEMP->E1_MOEDA,QRYTEMP->SALDO_LIQ,QRYTEMP->DIAS,QRYTEMP->CPF,QRYTEMP->RA_NOME,QRYTEMP->RA_EMAIL})
		nTotSaldo+=QRYTEMP->SALDO_LIQ
		nTotValor+=QRYTEMP->VALOR
		nTotQtde++
		QRYTEMP->(DbSkip())
	Enddo
	AADD(aDados,{"<b><center>TOTAIS</center></b>","&nbsp;","&nbsp;","<center>"+cvaltochar(nTotQtde)+" titulos</center>","&nbsp;","",nTotValor,"&nbsp;",nTotSaldo,"&nbsp;","","",""})
Endif

Return(aDados)

/*
Funcao      : QuerySocio()
Parametros  : cTipo_
Retorno     : aSocios
Objetivos   : Cria a query e retorna um array com as informações |Cod Sócio|E-mail Socio|
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012	09:41
*/
*-------------------------------*
Static Function QuerySocio(cQualResp)
*-------------------------------*
Local cQry:=""
Local aSocios:={}

if empty(cQualResp)
	return(aSocios)
endif

if cQualResp == "SOC"
	cQry+=" SELECT SA1.A1_P_SORES AS CPF,AUX.RA_EMAIL 
elseif cQualResp == "CTA"
	cQry+=" SELECT SA1.A1_P_GECTA AS CPF,AUX.RA_EMAIL 
elseif cQualResp == "CTB"
	cQry+=" SELECT SA1.A1_P_GECTB AS CPF,AUX.RA_EMAIL 	
endif
cQry+=" FROM "+RETSQLNAME("SE1")+" SE1
cQry+=" JOIN "+RETSQLNAME("SC5")+" SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SE1.E1_FILORIG=SC5.C5_FILIAL
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA

if cQualResp == "SOC"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = A1_P_SORES
elseif cQualResp == "CTA" 
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = A1_P_GECTA
elseif cQualResp == "CTB"
	cQry+=" LEFT JOIN AUX_RESPON AUX ON RA_CIC = A1_P_GECTB
endif

cQry+=" WHERE E1_SALDO>0 AND SC5.D_E_L_E_T_='' AND SE1.D_E_L_E_T_=''
cQry+=" AND SA1.D_E_L_E_T_='' 
cQry+=" AND SE1.E1_SITUACA<>'6'

If !lJob
	If !Empty(cCliDe)
		cQry+=" AND SA1.A1_COD >= '"+cCliDe+"'
	EndIf
	If !Empty(cCliAte)
		cQry+=" AND SA1.A1_COD <= '"+cCliAte+"'
	EndIf
	If !Empty(cSocDe)
		cQry+=" AND AUX.RA_CIC >= '"+cSocDe+"'
	EndIf
	If !Empty(cSocAte)
		cQry+=" AND AUX.RA_CIC <= '"+cSocAte+"'
	EndIf
endif
	
if cQualResp == "SOC"
	cQry+=" GROUP BY SA1.A1_P_SORES,AUX.RA_EMAIL                          
elseif cQualResp == "CTA"                                                                
	cQry+=" GROUP BY SA1.A1_P_GECTA,AUX.RA_EMAIL                          
elseif cQualResp == "CTB" 
	cQry+=" GROUP BY SA1.A1_P_GECTB,AUX.RA_EMAIL                          
endif
 
if select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount
        
if nRecCount >0
	QRYTEMP->(DbGotop())
	While QRYTEMP->(!EOF())
		AADD(aSocios,{QRYTEMP->CPF,QRYTEMP->RA_EMAIL})
		QRYTEMP->(DbSkip())
	Enddo
endif

Return(aSocios)

/*
Funcao      : AjustaSX1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor     	: Jean Victor Rocha
Data     	: 
Obs         : 
*/
*-------------------------*
Static Function AjustaSX1()
*-------------------------*

PutSx1(cPerg	,"01","Cliente De?"	,"","","mv_ch1","C",06,00,00,"G","","SA1"	,"","","Mv_Par01","","","","","","","","","","","","","","","","",{"Informe um codigo de cliente inicial."})
PutSx1(cPerg	,"02","Cliente Ate?","","","mv_ch2","C",06,00,00,"G","","SA1"	,"","","Mv_Par02","","","","","","","","","","","","","","","","",{"Informe um codigo de cliente Final"})
PutSx1(cPerg	,"03","Socio De?"	,"","","mv_ch3","C",06,00,00,"G","","SA3"	,"","","Mv_Par03","","","","","","","","","","","","","","","","",{"Informe um codigo de Gerente de Conta Inicial"})
PutSx1(cPerg	,"04","Socio Ate?"	,"","","mv_ch4","C",06,00,00,"G","","SA3"	,"","","Mv_Par04","","","","","","","","","","","","","","","","",{"Informe um codigo de Gerente de Conta Final"})
PutSx1(cPerg	,"05","Tp. Venc.?"	,"","","mv_ch5","N",01,00,00,"C","",""		,"","","Mv_par05","Vencidos","Vencidos","Vencidos","1","A Vencer","A Vencer","A Vencer"	,"Ambas","Ambas","Ambas"	,"","","","","","",{"Informe o tipo de Vencimento" })
PutSx1(cPerg	,"06","Email?"		,"","","mv_ch6","C",99,00,00,"G","",""		,"","","Mv_Par07","","","","","","","","","","","","","","","","",{"Informe email para envio do relatorio."})           
               
//Acerto de Nome de Pergunte de Gerente para Socio.
SX1->(DbSetOrder(1))//X1_GRUPO+X1_ORDEM
If SX1->(DbSeek(cPerg))
	While SX1->(!EOF()) .And. ALLTRIM(SX1->X1_GRUPO) == cPerg
		Do Case
			Case ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Gerente De?")
				SX1->(RecLock("SX1",.F.))
				SX1->X1_PERGUNT	:= "Socio De?"
				SX1->(MsUnlock())
			Case ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Gerente Ate?")
				SX1->(RecLock("SX1",.F.))
				SX1->X1_PERGUNT := "Socio Ate?"
				SX1->(MsUnlock())
		    Case !(cEmpAnt $ "ZB/ZF/ZG") .AND. ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio De?") .AND. ALLTRIM(UPPER(SX1->X1_F3)) <> "SRAOUT" 
				SX1->(RecLock("SX1",.F.))
				SX1->X1_TAMANHO := 11
				SX1->X1_F3		:= "SRAOUT"
				SX1->X1_PERGUNT	:= "Responsavel De?"
				SX1->(MsUnlock())
		    Case !(cEmpAnt $ "ZB/ZF/ZG") .AND. ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio Ate?") .AND. ALLTRIM(UPPER(SX1->X1_F3)) <> "SRAOUT" 
				SX1->(RecLock("SX1",.F.))
				SX1->X1_TAMANHO := 11
				SX1->X1_F3		:= "SRAOUT"
				SX1->X1_PERGUNT	:= "Responsavel Ate?"
				SX1->(MsUnlock())
			Case !(cEmpAnt $ "ZB/ZF/ZG") .AND. ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio De?") .AND. SX1->X1_ORDEM == "03"
				SX1->(RecLock("SX1",.F.))
				SX1->X1_TAMANHO := 11
				SX1->X1_F3		:= "SRAOUT"
				SX1->X1_PERGUNT	:= "Responsavel De?"
				SX1->(MsUnlock())
			Case !(cEmpAnt $ "ZB/ZF/ZG") .AND. ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio Ate?") .AND. SX1->X1_ORDEM == "04"
				SX1->(RecLock("SX1",.F.))
				SX1->X1_TAMANHO := 11
				SX1->X1_F3		:= "SRAOUT"
				SX1->X1_PERGUNT	:= "Responsavel Ate?"
				SX1->(MsUnlock())
		EndCase
		SX1->(DbSkip())
	EndDo
EndIf

//Ajuste de consulta a Socio.
If cEmpAnt $ "ZB/ZF/ZG"
	SX1->(DbSetOrder(1))//X1_GRUPO+X1_ORDEM
	If SX1->(DbSeek(cPerg))//Ajusta consulta PAdrão
		While SX1->(!EOF()) .And. ALLTRIM(SX1->X1_GRUPO) == cPerg
			If (ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio De?") .or. ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio Ate?")) .And.;
				ALLTRIM(UPPER(SX1->X1_F3)) <> "Z42SOC"

				SX1->(RecLock("SX1",.F.))
				SX1->X1_F3 := "Z42SOC"
				SX1->(MsUnlock())
			EndIf
			SX1->(DbSkip())
		EndDo
	EndIf                        
	If SX1->(DbSeek(cPerg))//Ajusta Tamanho
		While SX1->(!EOF()) .And. ALLTRIM(SX1->X1_GRUPO) == cPerg
			If (ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio De?") .or. ALLTRIM(UPPER(SX1->X1_PERGUNT)) == UPPER("Socio Ate?")) .And.;
				SX1->X1_TAMANHO <> 11

				SX1->(RecLock("SX1",.F.))
				SX1->X1_TAMANHO := 11
				SX1->(MsUnlock())
			EndIf
			SX1->(DbSkip())
		EndDo
	EndIf                        
	
EndIf

Return .T. 

/*
Funcao      : QueryAud
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor     	: Jean Victor Rocha
Data     	: 
Obs         : 
*/
*-------------------------*
Static Function QueryAud() 
*-------------------------*
Local cQry		:= ""
Local aRetSoc	:= {}
Local aRetGer	:= {}
Local nRecCount := 0
Local aAux := {"Proposta","Contrato","Cliente","NF","Pedido","Vencimento","Valor Original R$","Saldo Liq R$",;
						"Dias Vencidos","Socio","Nome","Email","Gerente","Nome Ger.","Email","Emissao","Moeda","Projeto"}

/*
//-- Titulos COM Proposta e COM Contrato-------------------------------------------------------------------------------------------------------
cQry+=" SELECT	Z55.Z55_NUM as PROPOSTA,
cQry+=" 		CN9.CN9_NUMERO as CONTRATO,		
cQry+=" 		CASE WHEN (Z55.Z55_GLOBAL = '1' AND Z55.Z55_GLOCOB = '2') THEN RTRIM(SA1.A1_NOME)+' - '+RTRIM(Z55.Z55_CLIGLO) ELSE SA1.A1_NOME END AS CLIENTE,
cQry+=" 		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
//cQry+=" 		SE1.E1_PEDIDO AS PEDIDO,

cQry+="		cast(
cQry+="		STUFF((SELECT ';'+C5_NUM FROM "+RETSQLNAME("SC5")+" C5INTE
cQry+="		WHERE C5INTE.D_E_L_E_T_='' AND C5INTE.C5_NOTA=SC5.C5_NOTA AND C5INTE.C5_SERIE=SC5.C5_SERIE
cQry+="		FOR XML PATH('')
cQry+="		),1,1,'') 
cQry+="		 as varchar(50))
cQry+="		AS PEDIDO, 

cQry+=" 		SE1.E1_VENCREA AS VENCTO,
cQry+=" 		SE1.E1_VLCRUZ AS VALOR,
cQry+=" 		ROUND((SE1.E1_VLCRUZ*SE1.E1_SALDO)/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" 		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN Z42_SOC.Z42_IDUSER ELSE (CASE WHEN ISNULL(CN9.CN9_P_GER   ,'') <> '' THEN CN9.CN9_P_GER ELSE (CASE WHEN ISNULL(SA1.A1_P_VEND,'') <> '' THEN SA1.A1_P_VEND ELSE '' END) END) END) AS COD_SOCIO,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_NOUSER  ,'') <> '' THEN Z42_SOC.Z42_NOUSER ELSE (CASE WHEN ISNULL(SA3_CN9.A3_NOME ,'') <> '' THEN SA3_CN9.A3_NOME ELSE (CASE WHEN ISNULL(SA3_SA1.A3_NOME,'') <> '' THEN SA3_SA1.A3_NOME ELSE '' END) END) END) AS NOME,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_SOC.Z42_IDUSER)+'''' ELSE (CASE WHEN ISNULL(SA3_CN9.A3_EMAIL,'') <> '' THEN SA3_CN9.A3_EMAIL ELSE (CASE WHEN ISNULL(SA3_SA1.A3_EMAIL,'') <> '' THEN SA3_SA1.A3_EMAIL ELSE '' END) END) END) AS EMAIL,
cQry+=" 		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN Z42_GER.Z42_IDUSER ELSE ''  END) AS COD_GERENTE,
cQry+=" 		(CASE WHEN ISNULL(Z42_GER.Z42_NOUSER  ,'') <> '' THEN Z42_GER.Z42_NOUSER ELSE ''  END) AS NOME_GERENTE,
cQry+=" 		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_GER.Z42_IDUSER)+'''' ELSE ''  END) AS MAIL_GERENTE,
cQry+=" 		SE1.E1_EMISSAO AS EMISSAO,
cQry+=" 		SE1.E1_MOEDA AS MOEDA,
cQry+=" 		cast(PRO.Z53_CODIGO as varchar(10)) AS PROJETO" //MSM - 23/04/2014 - Inclusão do número do projeto solicitado pelo Renato Oliveira
cQry+=" FROM 		"+RETSQLNAME("SE1")+" SE1
cQry+=" 				JOIN 		"+RETSQLNAME("SC5")+" SC5  		ON SE1.E1_FILORIG=SC5.C5_FILIAL AND SE1.E1_PEDIDO=SC5.C5_NUM
cQry+=" 				JOIN 		"+RETSQLNAME("CN9")+" CN9  		ON CN9.CN9_FILIAL=SC5.C5_FILIAL AND CN9.CN9_NUMERO=SC5.C5_MDCONTR
cQry+=" 				JOIN 		"+RETSQLNAME("Z55")+" Z55  		ON Z55.Z55_FILIAL=SC5.C5_FILIAL AND Z55.Z55_NUM=CN9.CN9_P_NUM AND Z55_REVATU=''
cQry+=" 				LEFT JOIN	"+RETSQLNAME("Z42")+" Z42_SOC	ON Z55.Z55_SOCIO=Z42_SOC.Z42_CPF
cQry+=" 				LEFT JOIN	"+RETSQLNAME("Z42")+" Z42_GER	ON Z55.Z55_GERENT=Z42_GER.Z42_CPF
cQry+=" 				JOIN 		"+RETSQLNAME("SA1")+" SA1		ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" 				LEFT JOIN 	"+RETSQLNAME("SA3")+" SA3_CN9	ON SA3_CN9.A3_COD=CN9.CN9_P_GER
cQry+=" 				LEFT JOIN 	"+RETSQLNAME("SA3")+" SA3_SA1	ON SA3_SA1.A3_COD=SA1.A1_P_VEND
cQry+=" 				LEFT JOIN	Controle.dbo.INT_PROJETOS PRO ON SUBSTRING(PRO.Z54_CODIGO,1,charindex('.',PRO.Z54_CODIGO)-1) = Z55.Z55_NUM COLLATE Latin1_General_BIN AND PRO.M0_CODIGO='"+cEmpAnt+"'" //MSM - 23/04/2014 - Inclusão do número do projeto solicitado pelo Renato Oliveira
cQry+=" WHERE 
cQry+=" 	SE1.D_E_L_E_T_='' AND E1_SALDO > 0 AND SE1.E1_SITUACA<>'6'
cQry+=" AND SC5.D_E_L_E_T_=''
cQry+=" AND CN9.D_E_L_E_T_='' AND CN9.CN9_P_NUM <> '' AND CN9.CN9_SITUAC in ('05','08')
cQry+=" AND Z55.D_E_L_E_T_='' AND Z55.Z55_NUM <> ''
cQry+=" AND ISNULL(Z42_SOC.D_E_L_E_T_,'')=''
cQry+=" AND ISNULL(Z42_GER.D_E_L_E_T_,'')=''
cQry+=" AND SA1.D_E_L_E_T_='' 
cQry+=" AND ISNULL(SA3_CN9.D_E_L_E_T_,'')=''
cQry+=" AND ISNULL(SA3_SA1.D_E_L_E_T_,'')=''
If !lJob .and. !Empty(cCliDe)
	cQry+="  AND SA1.A1_COD >= '"+cCliDe+"'
EndIf
If !lJob .and. !Empty(cCliAte)
	cQry+="  AND SA1.A1_COD <= '"+cCliAte+"'
EndIf
cQry+=" GROUP BY Z55.Z55_NUM,CN9.CN9_NUMERO,SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SC5.C5_NOTA,SC5.C5_SERIE,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
cQry+=" 		SE1.E1_VALOR,SE1.E1_SALDO,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,Z42_SOC.Z42_IDUSER,Z42_SOC.Z42_NOUSER,SA3_CN9.A3_EMAIL, 
cQry+=" 		SA3_SA1.A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,CN9.CN9_P_GER,SA1.A1_P_VEND,Z42_SOC.Z42_CPF,SA3_CN9.A3_NOME,SA3_SA1.A3_NOME,Z42_GER.Z42_CPF,
cQry+=" 		Z42_GER.Z42_IDUSER,Z42_GER.Z42_NOUSER,PRO.Z53_CODIGO,Z55.Z55_GLOBAL, Z55.Z55_GLOCOB, Z55.Z55_CLIGLO
//-- Titulos SEM Proposta e COM Contrato-------------------------------------------------------------------------------------------------------
cQry+=" UNION All
cQry+=" SELECT	'<N/D>' as PROPOSTA,
cQry+=" 		CN9.CN9_NUMERO as CONTRATO,		
cQry+=" 		SA1.A1_NOME AS CLIENTE,
cQry+=" 		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
//cQry+=" 		SE1.E1_PEDIDO AS PEDIDO,
cQry+="			cast(
cQry+="			STUFF((SELECT ';'+C5_NUM FROM "+RETSQLNAME("SC5")+" C5INTE
cQry+="			WHERE C5INTE.D_E_L_E_T_='' AND C5INTE.C5_NOTA=SC5.C5_NOTA AND C5INTE.C5_SERIE=SC5.C5_SERIE
cQry+="			FOR XML PATH('')
cQry+="			),1,1,'') 
cQry+="		 	as varchar(50))
cQry+="			AS PEDIDO, 
cQry+=" 		SE1.E1_VENCREA AS VENCTO,
cQry+=" 		SE1.E1_VLCRUZ AS VALOR,
cQry+=" 		ROUND((SE1.E1_VLCRUZ*SE1.E1_SALDO)/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" 		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
cQry+=" 		(CASE WHEN ISNULL(CN9.CN9_P_GER   ,'') <> '' THEN CN9.CN9_P_GER   ELSE (CASE WHEN ISNULL(SA1.A1_P_VEND  ,'') <> '' THEN SA1.A1_P_VEND   ELSE '' END) END) AS COD_SOCIO,
cQry+=" 		(CASE WHEN ISNULL(SA3_CN9.A3_NOME ,'') <> '' THEN SA3_CN9.A3_NOME ELSE (CASE WHEN ISNULL(SA3_SA1.A3_NOME,'') <> '' THEN SA3_SA1.A3_NOME ELSE '' END) END) AS NOME,
cQry+=" 		(CASE WHEN ISNULL(SA3_CN9.A3_EMAIL,'') <> '' THEN SA3_CN9.A3_EMAIL ELSE (CASE WHEN ISNULL(SA3_SA1.A3_EMAIL,'') <> '' THEN SA3_SA1.A3_EMAIL ELSE ''  END) END) AS EMAIL,
cQry+=" 		'<N/D>' AS COD_GERENTE,
cQry+=" 		'<N/D>' AS NOME_GERENTE,
cQry+=" 		'<N/D>' AS MAIL_GERENTE,
cQry+=" 		SE1.E1_EMISSAO AS EMISSAO,
cQry+=" 		SE1.E1_MOEDA AS MOEDA,
cQry+="		'<N/D>' AS PROJETO
cQry+=" FROM 		"+RETSQLNAME("SE1")+" SE1
cQry+=" 				JOIN 		"+RETSQLNAME("SC5")+" SC5  		ON SE1.E1_FILORIG=SC5.C5_FILIAL AND SE1.E1_PEDIDO=SC5.C5_NUM
cQry+=" 				JOIN 		"+RETSQLNAME("CN9")+" CN9  		ON CN9.CN9_FILIAL=SC5.C5_FILIAL AND CN9.CN9_NUMERO=SC5.C5_MDCONTR
cQry+=" 				JOIN 		"+RETSQLNAME("SA1")+" SA1  		ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" 				LEFT JOIN 	"+RETSQLNAME("SA3")+" SA3_CN9	ON SA3_CN9.A3_COD=CN9.CN9_P_GER
cQry+=" 				LEFT JOIN 	"+RETSQLNAME("SA3")+" SA3_SA1	ON SA3_SA1.A3_COD=SA1.A1_P_VEND
cQry+=" WHERE 
cQry+=" 	SE1.D_E_L_E_T_='' AND E1_SALDO > 0 AND SE1.E1_SITUACA<>'6'
cQry+=" AND SC5.D_E_L_E_T_=''
cQry+=" AND CN9.D_E_L_E_T_='' AND CN9.CN9_SITUAC in ('05','08')
cQry+=" AND CN9.CN9_P_NUM NOT IN (( SELECT DISTINCT Z55_NUM FROM "+RETSQLNAME("Z55")+" WHERE D_E_L_E_T_=''))" //MSM - 25/04/2014 - Verifico se não tem proposta na tabela de de proposta para solucionar o chamado: 018228 
cQry+=" AND SA1.D_E_L_E_T_='' 
cQry+=" AND ISNULL(SA3_CN9.D_E_L_E_T_,'')=''
cQry+=" AND ISNULL(SA3_SA1.D_E_L_E_T_,'')=''
If !lJob .and. !Empty(cCliDe)
	cQry+="  AND SA1.A1_COD >= '"+cCliDe+"'
EndIf
If !lJob .and. !Empty(cCliAte)
	cQry+="  AND SA1.A1_COD <= '"+cCliAte+"'
EndIf
cQry+=" GROUP BY CN9.CN9_NUMERO,SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SC5.C5_NOTA,SC5.C5_SERIE,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
cQry+=" 		SE1.E1_VALOR,SE1.E1_SALDO,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,SA3_CN9.A3_EMAIL,
cQry+=" 		SA3_SA1.A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,CN9.CN9_P_GER,SA1.A1_P_VEND,SA3_CN9.A3_NOME,SA3_SA1.A3_NOME
cQry+=" 
//-- Titulos COM Proposta e SEM Contrato-------------------------------------------------------------------------------------------------------
cQry+=" UNION ALL
cQry+=" SELECT	Z55.Z55_NUM as PROPOSTA,
cQry+=" 		'<N/D>' as CONTRATO,		
cQry+=" 		CASE WHEN (Z55.Z55_GLOBAL = '1' AND Z55.Z55_GLOCOB = '2') THEN RTRIM(SA1.A1_NOME)+' - '+RTRIM(Z55.Z55_CLIGLO) ELSE SA1.A1_NOME END AS CLIENTE,
cQry+=" 		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
//cQry+=" 		SE1.E1_PEDIDO AS PEDIDO,
cQry+="			cast(
cQry+="			STUFF((SELECT ';'+C5_NUM FROM "+RETSQLNAME("SC5")+" C5INTE
cQry+="			WHERE C5INTE.D_E_L_E_T_='' AND C5INTE.C5_NOTA=SC5.C5_NOTA AND C5INTE.C5_SERIE=SC5.C5_SERIE
cQry+="			FOR XML PATH('')
cQry+="			),1,1,'') 
cQry+="		 	as varchar(50))
cQry+="			AS PEDIDO,
cQry+=" 		SE1.E1_VENCREA AS VENCTO,
cQry+=" 		SE1.E1_VLCRUZ AS VALOR,
cQry+=" 		ROUND((SE1.E1_VLCRUZ*SE1.E1_SALDO)/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" 		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN Z42_SOC.Z42_IDUSER              ELSE (CASE WHEN ISNULL(SA1.A1_P_VEND   ,'') <> '' THEN SA1.A1_P_VEND    ELSE '' END) END) AS COD_SOCIO,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_NOUSER  ,'') <> '' THEN Z42_SOC.Z42_NOUSER              ELSE (CASE WHEN ISNULL(SA3_SA1.A3_NOME ,'') <> '' THEN SA3_SA1.A3_NOME  ELSE '' END) END) AS NOME,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_SOC.Z42_IDUSER)+''''ELSE (CASE WHEN ISNULL(SA3_SA1.A3_EMAIL,'') <> '' THEN SA3_SA1.A3_EMAIL ELSE '' END) END) AS EMAIL,
cQry+=" 		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN Z42_GER.Z42_IDUSER ELSE ''  END) AS COD_GERENTE,
cQry+=" 		(CASE WHEN ISNULL(Z42_GER.Z42_NOUSER  ,'') <> '' THEN Z42_GER.Z42_NOUSER ELSE ''  END) AS NOME_GERENTE,
cQry+=" 		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_GER.Z42_IDUSER)+'''' ELSE ''  END) AS MAIL_GERENTE,
cQry+=" 		SE1.E1_EMISSAO AS EMISSAO,
cQry+=" 		SE1.E1_MOEDA AS MOEDA,
cQry+=" 		cast(PRO.Z53_CODIGO as varchar(10)) AS PROJETO" //MSM - 23/04/2014 - Inclusão do número do projeto solicitado pelo Renato Oliveira
cQry+=" FROM 		"+RETSQLNAME("SE1")+" SE1
cQry+=" 				JOIN 		"+RETSQLNAME("SC5")+" SC5  		ON SE1.E1_FILORIG=SC5.C5_FILIAL AND SE1.E1_PEDIDO=SC5.C5_NUM
cQry+=" 				JOIN 		"+RETSQLNAME("Z55")+" Z55		ON Z55.Z55_FILIAL=SC5.C5_FILIAL AND Z55.Z55_NUM=SC5.C5_P_NUM AND Z55_REVATU=''
cQry+=" 				LEFT JOIN	"+RETSQLNAME("Z42")+" Z42_SOC	ON Z55.Z55_SOCIO=Z42_SOC.Z42_CPF
cQry+=" 				LEFT JOIN	"+RETSQLNAME("Z42")+" Z42_GER	ON Z55.Z55_GERENT=Z42_GER.Z42_CPF
cQry+=" 				JOIN 		"+RETSQLNAME("SA1")+" SA1  		ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" 				LEFT JOIN 	"+RETSQLNAME("SA3")+" SA3_SA1	ON SA3_SA1.A3_COD=SA1.A1_P_VEND
cQry+=" 				LEFT JOIN	Controle.dbo.INT_PROJETOS PRO ON SUBSTRING(PRO.Z54_CODIGO,1,charindex('.',PRO.Z54_CODIGO)-1) = Z55.Z55_NUM COLLATE Latin1_General_BIN AND PRO.M0_CODIGO='"+cEmpAnt+"'" //MSM - 23/04/2014 - Inclusão do número do projeto solicitado pelo Renato Oliveira
cQry+=" WHERE 
cQry+=" 	SE1.D_E_L_E_T_='' AND E1_SALDO > 0 AND SE1.E1_SITUACA<>'6'
cQry+=" AND SC5.D_E_L_E_T_='' AND SC5.C5_MDCONTR = ''
cQry+=" AND SA1.D_E_L_E_T_='' 
cQry+=" AND Z55.D_E_L_E_T_='' AND Z55.Z55_NUM <> ''
cQry+=" AND ISNULL(Z42_SOC.D_E_L_E_T_,'')=''
cQry+=" AND ISNULL(Z42_GER.D_E_L_E_T_,'')=''
cQry+=" AND ISNULL(SA3_SA1.D_E_L_E_T_,'')=''
If !lJob .and. !Empty(cCliDe)
	cQry+="  AND SA1.A1_COD >= '"+cCliDe+"'
EndIf
If !lJob .and. !Empty(cCliAte)
	cQry+="  AND SA1.A1_COD <= '"+cCliAte+"'
EndIf
cQry+=" GROUP BY SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SC5.C5_NOTA,SC5.C5_SERIE,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
cQry+=" 		SE1.E1_VALOR,SE1.E1_SALDO,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,Z55.Z55_NUM,Z42_SOC.Z42_IDUSER,Z42_GER.Z42_CPF,
cQry+=" 		SA3_SA1.A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,SA1.A1_P_VEND,SA3_SA1.A3_NOME,Z42_SOC.Z42_NOUSER,Z42_SOC.Z42_CPF,Z42_GER.Z42_IDUSER,
cQry+=" 		Z42_GER.Z42_NOUSER,PRO.Z53_CODIGO,Z55.Z55_GLOBAL, Z55.Z55_GLOCOB, Z55.Z55_CLIGLO
//-- Titulos SEM Proposta e SEM Contrato-------------------------------------------------------------------------------------------------------
cQry+=" UNION ALL
cQry+=" SELECT	'<N/D>' as PROPOSTA,
cQry+=" 		'<N/D>' as CONTRATO,		
cQry+=" 		SA1.A1_NOME AS CLIENTE,
cQry+=" 		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" 		SE1.E1_PEDIDO AS PEDIDO,
cQry+=" 		SE1.E1_VENCREA AS VENCTO,
cQry+=" 		SE1.E1_VLCRUZ AS VALOR,
cQry+=" 		ROUND((SE1.E1_VLCRUZ*SE1.E1_SALDO)/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+=" 		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
//cQry+=" 		(CASE WHEN ISNULL(SA1.A1_P_VEND   ,'') <> '' THEN SA1.A1_P_VEND    ELSE '' END) AS COD_SOCIO,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN Z42_SOC.Z42_IDUSER ELSE (CASE WHEN ISNULL(SA1.A1_P_VEND   ,'') <> '' THEN SA1.A1_P_VEND    ELSE '' END) END) AS COD_SOCIO,
//cQry+=" 		(CASE WHEN ISNULL(SA3_SA1.A3_NOME ,'') <> '' THEN SA3_SA1.A3_NOME  ELSE '' END) AS NOME,
cQry+=" 		(CASE WHEN ISNULL(Z42_SOC.Z42_NOUSER  ,'') <> '' THEN Z42_SOC.Z42_NOUSER ELSE (CASE WHEN ISNULL(SA3_SA1.A3_NOME ,'') <> '' THEN SA3_SA1.A3_NOME  ELSE '' END) END) AS NOME,
cQry+=" 		(CASE WHEN ISNULL(SA3_SA1.A3_EMAIL,'') <> '' THEN SA3_SA1.A3_EMAIL ELSE '' END) AS EMAIL,
cQry+=" 		'<N/D>' AS COD_GERENTE,
cQry+=" 		'<N/D>' AS NOME_GERENTE,
cQry+=" 		'<N/D>' AS MAIL_GERENTE,
cQry+=" 		SE1.E1_EMISSAO AS EMISSAO,
cQry+=" 		SE1.E1_MOEDA AS MOEDA,
cQry+="		'<N/D>' AS PROJETO
cQry+=" FROM 		"+RETSQLNAME("SE1")+" SE1
cQry+=" 				JOIN 		"+RETSQLNAME("SC5")+" SC5  		ON SE1.E1_FILORIG=SC5.C5_FILIAL AND SE1.E1_PEDIDO=SC5.C5_NUM
cQry+=" 				JOIN 		"+RETSQLNAME("SA1")+" SA1 		ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" 				LEFT JOIN 	"+RETSQLNAME("SA3")+" SA3_SA1	ON SA3_SA1.A3_COD=SA1.A1_P_VEND
cQry+=" 				LEFT JOIN	"+RETSQLNAME("Z42")+" Z42_SOC	ON Z42_SOC.Z42_CPF=SA1.A1_P_SOCIO
cQry+=" WHERE 
cQry+=" 	SE1.D_E_L_E_T_='' AND E1_SALDO > 0 AND SE1.E1_SITUACA<>'6'
cQry+=" AND SC5.D_E_L_E_T_='' AND SC5.C5_MDCONTR = '' AND SC5.C5_P_NUM = ''
cQry+=" AND SA1.D_E_L_E_T_='' 
cQry+=" AND ISNULL(SA3_SA1.D_E_L_E_T_,'')=''
If !lJob .and. !Empty(cCliDe)
	cQry+="  AND SA1.A1_COD >= '"+cCliDe+"'
EndIf
If !lJob .and. !Empty(cCliAte)
	cQry+="  AND SA1.A1_COD <= '"+cCliAte+"'
EndIf
cQry+=" GROUP BY SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SE1.E1_PEDIDO,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
cQry+=" 		SE1.E1_VALOR,SE1.E1_SALDO,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,
cQry+=" 		SA3_SA1.A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,SA1.A1_P_VEND,Z42_SOC.Z42_IDUSER,SA3_SA1.A3_NOME,Z42_SOC.Z42_NOUSER
cQry+=" 
//-- Titulos SEM Pedidos-------------------------------------------------------------------------------------------------------
If !lJob .and. Empty(cCliDe) .and. Empty(cCliAte)
	cQry+=" UNION ALL
	cQry+=" SELECT	'<N/D>' as PROPOSTA,
	cQry+=" 		'<N/D>' as CONTRATO,		
	cQry+=" 		'<N/D>' AS CLIENTE,
	cQry+=" 		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
	cQry+=" 		SE1.E1_PEDIDO AS PEDIDO,
	cQry+=" 		SE1.E1_VENCREA AS VENCTO,
	cQry+=" 		SE1.E1_VLCRUZ AS VALOR,
	cQry+=" 		ROUND((SE1.E1_VLCRUZ*SE1.E1_SALDO)/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
	cQry+=" 		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
	cQry+=" 		'<N/D>' AS COD_SOCIO,
	cQry+=" 		'<N/D>' AS NOME,
	cQry+=" 		'<N/D>' AS EMAIL,
	cQry+=" 		'<N/D>' AS COD_GERENTE,
	cQry+=" 		'<N/D>' AS NOME_GERENTE,
	cQry+=" 		'<N/D>' AS MAIL_GERENTE,
	cQry+=" 		SE1.E1_EMISSAO AS EMISSAO,
	cQry+=" 		SE1.E1_MOEDA AS MOEDA,
	cQry+="		'<N/D>' AS PROJETO
	cQry+=" FROM "+RETSQLNAME("SE1")+" SE1
	cQry+=" WHERE 
	cQry+=" 	SE1.D_E_L_E_T_='' AND E1_SALDO > 0 AND SE1.E1_SITUACA<>'6' AND (E1_TIPO='NF' OR E1_SERIE='ND')
	cQry+=" AND SE1.E1_PEDIDO = ''
	cQry+=" GROUP BY SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SE1.E1_PEDIDO,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
	cQry+=" 		SE1.E1_VALOR,SE1.E1_SALDO,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,
	cQry+=" 		SE1.E1_EMISSAO,SE1.E1_MOEDA
EndIf
*/

cQry+="  SELECT 
cQry+=" 	 	Z55.Z55_NUM as PROPOSTA,
cQry+="  		CN9.CN9_NUMERO as CONTRATO,		
cQry+="  		CASE WHEN (Z55.Z55_GLOBAL = '1' AND Z55.Z55_GLOCOB = '2') THEN RTRIM(SA1.A1_NOME)+' - '+RTRIM(Z55.Z55_CLIGLO) ELSE SA1.A1_NOME END AS CLIENTE,
cQry+="  		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" 		cast(
cQry+=" 		STUFF((SELECT ';'+C5_NUM FROM "+RETSQLNAME("SC5")+" C5INTE
cQry+=" 		WHERE C5INTE.D_E_L_E_T_='' AND C5INTE.C5_NOTA=SC5.C5_NOTA AND C5INTE.C5_SERIE=SC5.C5_SERIE
cQry+=" 		FOR XML PATH('')
cQry+=" 		),1,1,'') 
cQry+=" 		 as varchar(50))
cQry+=" 		AS PEDIDO, 
cQry+="  		SE1.E1_VENCREA AS VENCTO,
cQry+="  		SE1.E1_VLCRUZ AS VALOR,
cQry+="  		ROUND((SE1.E1_VLCRUZ*(SE1.E1_SALDO-SE1.E1_DECRESC))/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+="  		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
cQry+="  		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN Z42_SOC.Z42_IDUSER ELSE (CASE WHEN ISNULL(Z42CLI.Z42_IDUSER,'') <> '' THEN Z42CLI.Z42_IDUSER ELSE (CASE WHEN ISNULL(CN9.CN9_P_GER   ,'') <> '' THEN CN9.CN9_P_GER ELSE (CASE WHEN ISNULL(SA1.A1_P_VEND,'') <> '' THEN SA1.A1_P_VEND ELSE '' END) END) END) END) AS COD_SOCIO,
cQry+="  		(CASE WHEN ISNULL(Z42_SOC.Z42_NOUSER  ,'') <> '' THEN Z42_SOC.Z42_NOUSER ELSE (CASE WHEN ISNULL(Z42CLI.Z42_NOUSER  ,'') <> '' THEN Z42CLI.Z42_NOUSER ELSE (CASE WHEN ISNULL(SA3_CN9.A3_NOME ,'') <> '' THEN SA3_CN9.A3_NOME ELSE (CASE WHEN ISNULL(SA3_SA1.A3_NOME,'') <> '' THEN SA3_SA1.A3_NOME ELSE '' END) END) END) END) AS NOME,
cQry+="  		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_SOC.Z42_IDUSER)+'''' ELSE (CASE WHEN ISNULL(Z42CLI.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42CLI.Z42_IDUSER)+'''' ELSE (CASE WHEN ISNULL(SA3_CN9.A3_EMAIL,'') <> '' THEN SA3_CN9.A3_EMAIL ELSE (CASE WHEN ISNULL(SA3_SA1.A3_EMAIL,'') <> '' THEN SA3_SA1.A3_EMAIL ELSE '' END) END) END) END) AS EMAIL,
cQry+="  		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN Z42_GER.Z42_IDUSER ELSE ''  END) AS COD_GERENTE,
cQry+="  		(CASE WHEN ISNULL(Z42_GER.Z42_NOUSER  ,'') <> '' THEN Z42_GER.Z42_NOUSER ELSE ''  END) AS NOME_GERENTE,
cQry+="  		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_GER.Z42_IDUSER)+'''' ELSE ''  END) AS MAIL_GERENTE,
cQry+="  		SE1.E1_EMISSAO AS EMISSAO,
cQry+="  		SE1.E1_MOEDA AS MOEDA,
cQry+="  		cast(PRO.Z53_CODIGO as varchar(10)) AS PROJETO
cQry+=" 		 FROM "+RETSQLNAME("CN9")+" AS CN9
cQry+=" 		 JOIN "+RETSQLNAME("SC5")+" AS SC5 ON SC5.C5_MDCONTR=CN9.CN9_NUMERO AND SC5.C5_FILIAL=CN9.CN9_FILIAL
cQry+=" 		 JOIN "+RETSQLNAME("SE1")+" AS SE1 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG
cQry+=" 		 LEFT JOIN "+RETSQLNAME("Z55")+" AS Z55 ON Z55.Z55_NUM = CN9.CN9_P_NUM AND Z55.Z55_FILIAL = CN9.CN9_FILIAL AND Z55.Z55_STATUS = 'E' AND Z55.D_E_L_E_T_ <> '*'
cQry+="  		 LEFT JOIN "+RETSQLNAME("Z42")+" Z42_SOC	ON Z55.Z55_SOCIO=Z42_SOC.Z42_CPF AND Z42_SOC.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN "+RETSQLNAME("Z42")+" Z42_GER	ON Z55.Z55_GERENT=Z42_GER.Z42_CPF AND Z42_GER.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN "+RETSQLNAME("SA1")+" AS SA1 ON SA1.A1_COD=CN9.CN9_CLIENT 
cQry+=" 		 LEFT JOIN "+RETSQLNAME("SA3")+" SA3_CN9	ON SA3_CN9.A3_COD=CN9.CN9_P_GER AND SA3_CN9.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN "+RETSQLNAME("SA3")+" SA3_SA1	ON SA3_SA1.A3_COD=SA1.A1_P_VEND AND SA3_SA1.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN "+RETSQLNAME("Z42")+" AS Z42CLI ON Z42CLI.Z42_CPF = SA1.A1_P_SOCIO AND Z42CLI.D_E_L_E_T_ <> '*'
cQry+=" 		 LEFT JOIN	Controle.dbo.INT_PROJETOS PRO ON SUBSTRING(PRO.Z54_CODIGO,1,charindex('.',PRO.Z54_CODIGO)-1) = Z55.Z55_NUM COLLATE Latin1_General_BIN AND PRO.M0_CODIGO='"+cEmpAnt+"'
cQry+=" 		 WHERE SC5.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SE1.D_E_L_E_T_=''
cQry+=" 		 AND SE1.E1_SALDO>0 AND CN9.CN9_SITUAC<>'10' AND SE1.E1_SITUACA<>'6' AND SE1.E1_SITUACA<>'5' AND SE1.E1_SITUACA<>'8'"	//Renato Oliveira, pediu para incluir a situação 5,e 8 referente a intercompany 
If !lJob .and. !Empty(cCliDe)
	cQry+="  AND SA1.A1_COD >= '"+cCliDe+"'
EndIf
If !lJob .and. !Empty(cCliAte)
	cQry+="  AND SA1.A1_COD <= '"+cCliAte+"'
EndIf
cQry+=" 		GROUP BY Z55.Z55_NUM,CN9.CN9_NUMERO,SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SC5.C5_NOTA,SC5.C5_SERIE,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
cQry+="  		SE1.E1_VALOR,SE1.E1_SALDO,SE1.E1_DECRESC,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,Z42_SOC.Z42_IDUSER,Z42_SOC.Z42_NOUSER,SA3_CN9.A3_EMAIL, 
cQry+="  		SA3_SA1.A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,CN9.CN9_P_GER,SA1.A1_P_VEND,Z42_SOC.Z42_CPF,SA3_CN9.A3_NOME,SA3_SA1.A3_NOME,Z42_GER.Z42_CPF,
cQry+="  		Z42_GER.Z42_IDUSER,Z42_GER.Z42_NOUSER,PRO.Z53_CODIGO,Z55.Z55_GLOBAL, Z55.Z55_GLOCOB, Z55.Z55_CLIGLO,Z42CLI.Z42_IDUSER,Z42CLI.Z42_NOUSER
	
cQry+=" 		 UNION 
		
cQry+=" 		 SELECT 
cQry+=" 		 	Z55.Z55_NUM as PROPOSTA,
cQry+="  		'' as CONTRATO,		
cQry+="  		CASE WHEN (Z55.Z55_GLOBAL = '1' AND Z55.Z55_GLOCOB = '2') THEN RTRIM(SA1.A1_NOME)+' - '+RTRIM(Z55.Z55_CLIGLO) ELSE SA1.A1_NOME END AS CLIENTE,
cQry+="  		SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" 		cast(
cQry+=" 		STUFF((SELECT ';'+C5_NUM FROM "+RETSQLNAME("SC5")+" C5INTE
cQry+=" 		WHERE C5INTE.D_E_L_E_T_='' AND C5INTE.C5_NOTA=SC5.C5_NOTA AND C5INTE.C5_SERIE=SC5.C5_SERIE
cQry+=" 		FOR XML PATH('')
cQry+=" 		),1,1,'') 
cQry+=" 		 as varchar(50))
cQry+=" 		AS PEDIDO, 
cQry+="  		SE1.E1_VENCREA AS VENCTO,
cQry+="  		SE1.E1_VLCRUZ AS VALOR,
cQry+="  		ROUND((SE1.E1_VLCRUZ*(SE1.E1_SALDO-SE1.E1_DECRESC))/SE1.E1_VALOR -(CASE WHEN E1_VALOR>=5000 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) AS 'SALDO_LIQ',
cQry+="  		datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
cQry+="  		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN Z42_SOC.Z42_IDUSER ELSE (CASE WHEN ISNULL(Z42CLI.Z42_IDUSER,'') <> '' THEN Z42CLI.Z42_IDUSER ELSE (CASE WHEN ISNULL(SA1.A1_P_VEND,'') <> '' THEN SA1.A1_P_VEND ELSE '' END) END) END) AS COD_SOCIO,
cQry+="  		(CASE WHEN ISNULL(Z42_SOC.Z42_NOUSER  ,'') <> '' THEN Z42_SOC.Z42_NOUSER ELSE (CASE WHEN ISNULL(Z42CLI.Z42_NOUSER  ,'') <> '' THEN Z42CLI.Z42_NOUSER ELSE (CASE WHEN ISNULL(SA3_SA1.A3_NOME,'') <> '' THEN SA3_SA1.A3_NOME ELSE '' END) END) END) AS NOME,
cQry+="  		(CASE WHEN ISNULL(Z42_SOC.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_SOC.Z42_IDUSER)+'''' ELSE (CASE WHEN ISNULL(Z42CLI.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42CLI.Z42_IDUSER)+'''' ELSE (CASE WHEN ISNULL(SA3_SA1.A3_EMAIL,'') <> '' THEN SA3_SA1.A3_EMAIL ELSE '' END) END) END) AS EMAIL,
cQry+="  		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN Z42_GER.Z42_IDUSER ELSE ''  END) AS COD_GERENTE,
cQry+="  		(CASE WHEN ISNULL(Z42_GER.Z42_NOUSER  ,'') <> '' THEN Z42_GER.Z42_NOUSER ELSE ''  END) AS NOME_GERENTE,
cQry+="  		(CASE WHEN ISNULL(Z42_GER.Z42_IDUSER  ,'') <> '' THEN '&'''+RTRIM(Z42_GER.Z42_IDUSER)+'''' ELSE ''  END) AS MAIL_GERENTE,
cQry+="  		SE1.E1_EMISSAO AS EMISSAO,
cQry+="  		SE1.E1_MOEDA AS MOEDA,
cQry+="  		cast(PRO.Z53_CODIGO as varchar(10)) AS PROJETO
cQry+=" 		 FROM "+RETSQLNAME("SE1")+" SE1
cQry+=" 		 JOIN "+RETSQLNAME("SC5")+" AS SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG
cQry+=" 		 LEFT JOIN "+RETSQLNAME("SA1")+" AS SA1 ON SA1.A1_COD=SE1.E1_CLIENTE 
cQry+=" 		 LEFT JOIN "+RETSQLNAME("Z55")+" AS Z55 ON Z55.Z55_NUM = SC5.C5_P_NUM AND SC5.C5_FILIAL = Z55.Z55_FILIAL AND Z55.Z55_STATUS = 'E' AND Z55.D_E_L_E_T_ <> '*'
cQry+=" 	 	 LEFT JOIN "+RETSQLNAME("Z42")+" AS Z42CLI ON Z42CLI.Z42_CPF = SA1.A1_P_SOCIO AND Z42CLI.D_E_L_E_T_ <> '*'
cQry+=" 		 LEFT JOIN "+RETSQLNAME("Z42")+" Z42_SOC	ON Z55.Z55_SOCIO=Z42_SOC.Z42_CPF AND Z42_SOC.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN "+RETSQLNAME("Z42")+" Z42_GER	ON Z55.Z55_GERENT=Z42_GER.Z42_CPF AND Z42_GER.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN "+RETSQLNAME("SA3")+" SA3_SA1	ON SA3_SA1.A3_COD=SA1.A1_P_VEND AND SA3_SA1.D_E_L_E_T_=''
cQry+=" 		 LEFT JOIN	Controle.dbo.INT_PROJETOS PRO ON SUBSTRING(PRO.Z54_CODIGO,1,charindex('.',PRO.Z54_CODIGO)-1) = Z55.Z55_NUM COLLATE Latin1_General_BIN AND PRO.M0_CODIGO='"+cEmpAnt+"'
cQry+=" 		 WHERE SE1.D_E_L_E_T_='' AND SC5.D_E_L_E_T_='' AND E1_TIPO IN ('NF')
cQry+=" 		 AND SE1.E1_SALDO>0 AND SE1.E1_SITUACA<>'6' AND SE1.E1_SITUACA<>'5' AND SE1.E1_SITUACA<>'8' "	//Renato Oliveira, pediu para incluir a situação 5,e 8 referente a intercompany
cQry+=" 		 AND C5_MDCONTR ='' 
If !lJob .and. !Empty(cCliDe)
	cQry+="  AND SA1.A1_COD >= '"+cCliDe+"'
EndIf
If !lJob .and. !Empty(cCliAte)
	cQry+="  AND SA1.A1_COD <= '"+cCliAte+"'
EndIf		
cQry+=" 		GROUP BY Z55.Z55_NUM,SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SC5.C5_NOTA,SC5.C5_SERIE,SE1.E1_VENCREA,SE1.E1_VLCRUZ,
cQry+="  		SE1.E1_VALOR,SE1.E1_SALDO,SE1.E1_DECRESC,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,Z42_SOC.Z42_IDUSER,Z42_SOC.Z42_NOUSER, 
cQry+="  		SA3_SA1.A3_EMAIL,SE1.E1_EMISSAO,SE1.E1_MOEDA,SA1.A1_P_VEND,Z42_SOC.Z42_CPF,SA3_SA1.A3_NOME,Z42_GER.Z42_CPF,
cQry+="  		Z42_GER.Z42_IDUSER,Z42_GER.Z42_NOUSER,PRO.Z53_CODIGO,Z55.Z55_GLOBAL, Z55.Z55_GLOCOB, Z55.Z55_CLIGLO,Z42CLI.Z42_IDUSER,Z42CLI.Z42_NOUSER

cQry+=" ORDER BY COD_SOCIO,COD_GERENTE,PROPOSTA,CONTRATO,VALOR DESC 

conout(cQry)

If select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount
                 
//Carrega as informações de quais Codigos devem ser apresentados.
aFiltroSoc := {}
lFiltro := .F.
If !lJob .And. (!EMPTY(cSocDe) .or. !EMPTY(cSocAte))
	aFiltroSoc := GetSocios()
	lFiltro := .T.
EndIf                         

If nRecCount >0
	QRYTEMP->(DbGotop())
	While QRYTEMP->(!EOF())
		If lJob                           
			If (cTipo_=="1" .and. QRYTEMP->DIAS <> 6 .and. QRYTEMP->DIAS >= 1) .or.;//Tipo 1 Diario, apenas os que estão a 6 dias vencidos
				(cTipo_=="2" .And. QRYTEMP->DIAS >= 1 .and. QRYTEMP->DIAS <= 6)
				QRYTEMP->(DbSkip())
				Loop
    		EndIf
		Else
			lSocio := lGerente := .F.
			If !EMPTY(cSocDe) .or. !EMPTY(cSocAte) 
				lSocio		:= aScan(aFiltroSoc,{|x| ALLTRIM(x[1]) == ALLTRIM(QRYTEMP->COD_SOCIO  )	.And. x[2] == "1" .And. ALLTRIM(x[3]) == ALLTRIM(QRYTEMP->NOME)} ) <> 0
				lGerente 	:= aScan(aFiltroSoc,{|x| ALLTRIM(x[1]) == ALLTRIM(QRYTEMP->COD_GERENTE)	.And. x[2] == "2" .And. ALLTRIM(x[3]) == ALLTRIM(QRYTEMP->NOME_GERENTE)} ) <> 0
				If !lSocio .And. !lGerente
					QRYTEMP->(DbSkip())
					Loop
				EndIf
			EndIf
		EndIf        

		cMailSoc := IIF(LEFT(QRYTEMP->EMAIL,1)=="&",UsrRetMail(&(SUBSTR(QRYTEMP->EMAIL,2,Len(QRYTEMP->EMAIL)))),QRYTEMP->EMAIL)
		cMailGer := IIF(LEFT(QRYTEMP->MAIL_GERENTE,1)=="&",UsrRetMail(&(SUBSTR(QRYTEMP->MAIL_GERENTE,2,Len(QRYTEMP->EMAIL)))),QRYTEMP->MAIL_GERENTE)

//		If !EMPTY(cMailSoc)
			If lJob .or. !lFiltro .or. (lFiltro .And. lSocio)//Montagem das Informações dos Socios
				If (nPos:=aScan(aRetSoc, {|x| ALLTRIM(x[1][3]) == ALLTRIM(cMailSoc)})) == 0
					aAdd(aRetSoc,{{QRYTEMP->COD_SOCIO,QRYTEMP->NOME,ALLTRIM(cMailSoc)},{	{"VENCIDOS",{}},;
																	   						{"A VENCER",{}} }})
		
					nPos:=aScan(aRetSoc, {|x| ALLTRIM(x[1][3]) == ALLTRIM(cMailSoc)})			
		
					aAdd(aRetSoc[nPos][2][1][2],aAux)
					aAdd(aRetSoc[nPos][2][2][2],aAux)
				EndIf
		
				aAdd(aRetSoc[nPos][2][IIF(QRYTEMP->DIAS>0,1,2)][2],{	QRYTEMP->PROPOSTA,QRYTEMP->CONTRATO,QRYTEMP->CLIENTE,QRYTEMP->NF,QRYTEMP->PEDIDO,;
																		QRYTEMP->VENCTO,QRYTEMP->VALOR,QRYTEMP->SALDO_LIQ,QRYTEMP->DIAS,QRYTEMP->COD_SOCIO,;
																		QRYTEMP->NOME,cMailSoc,QRYTEMP->COD_GERENTE,QRYTEMP->NOME_GERENTE,;
																		cMailGer,QRYTEMP->EMISSAO,QRYTEMP->MOEDA,QRYTEMP->PROJETO})
			EndIf
//		EndIf

		If !EMPTY(cMailGer)
			If lJob .or. !lFiltro .or. (lFiltro .And. lGerente)//Montagem das Informações dos Gerentes	
				If !EMPTY(QRYTEMP->COD_GERENTE) .and.;
					ALLTRIM(QRYTEMP->COD_GERENTE) <> "<N/D>"//Gerente so vai ser enviado caso esteja associado a um Titulo, caso contrario tratativa pelo socio.
					If (nPos:=aScan(aRetSoc, {|x| ALLTRIM(x[1][3]) == ALLTRIM(cMailGer)})) == 0
						aAdd(aRetSoc,{{QRYTEMP->COD_GERENTE,QRYTEMP->NOME_GERENTE,ALLTRIM(cMailGer)},{	{"VENCIDOS",{}},;
															   								  			{"A VENCER",{}} }})
		
						nPos:=aScan(aRetSoc, {|x| ALLTRIM(x[1][3]) == ALLTRIM(cMailGer)})			
			
						aAdd(aRetSoc[nPos][2][1][2],aAux)
						aAdd(aRetSoc[nPos][2][2][2],aAux)
					EndIf
			
					aAdd(aRetSoc[nPos][2][IIF(QRYTEMP->DIAS>0,1,2)][2],{	QRYTEMP->PROPOSTA,QRYTEMP->CONTRATO,QRYTEMP->CLIENTE,QRYTEMP->NF,QRYTEMP->PEDIDO,;
																			QRYTEMP->VENCTO,QRYTEMP->VALOR,QRYTEMP->SALDO_LIQ,QRYTEMP->DIAS,QRYTEMP->COD_SOCIO,;
																			QRYTEMP->NOME,cMailSoc,QRYTEMP->COD_GERENTE,QRYTEMP->NOME_GERENTE,;
																			cMailGer,QRYTEMP->EMISSAO,QRYTEMP->MOEDA,QRYTEMP->PROJETO})
				EndIf
			EndIf
		EndIf          
		QRYTEMP->(DbSkip())
	Enddo
Endif

Return aRetSoc//{aRetSoc,aRetGer}

/*
Funcao      : MailAud()
Parametros  : 
Retorno     : 
Objetivos   : Criação do Email para envio.
Autor       : Jean Victor Rocha
Data/Hora   : 30/10/2013
*/
*--------------------------------------*
Static Function MailAud(nTpEstru,aDados)
*--------------------------------------*
cHtml := ""                            

Default aDados := {}

Do Case
	Case nTpEstru == 0 //Inicialização
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
		cHtml+=' Responsavel: '+ IIF(EMPTY(aDados[3]),"",ALLTRIM(aDados[2])) + ' Cod.: '+IIF(EMPTY(aDados[3]),"",ALLTRIM(aDados[1]))+' Email:'+ALLTRIM(aDados[3] )
		cHtml+='	<br>'

	Case nTpEstru == 9 //Fechamento
		cHtml+=' Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL.'
		cHtml+=' </body>'
		cHtml+=' </html>'
	
	Case nTpEstru == 1 .or. nTpEstru == 2
		nPosData	:= aScan(aDados[1],{|x| Alltrim(x) == "Vencimento"})//Pega a Posição da data no array
		nPosData2	:= aScan(aDados[1],{|x| Alltrim(x) == "Emissao"})//Pega a Posição da data no array
		nPosValor	:= aScan(aDados[1],{|x| Alltrim(x) == "Valor Original R$"})//Pega a Posição do valor original no array
		nPosSaldo	:= aScan(aDados[1],{|x| Alltrim(x) == "Saldo Liq R$"})//Pega a Posição do saldo no array
		nPosDias	:= aScan(aDados[1],{|x| Alltrim(x) == "Dias Vencidos"})	//Pega a Posição dos dias vencidos
		nPosMoeda	:= aScan(aDados[1],{|x| Alltrim(x) == "Moeda"})//Pega a Posição da Moeda

		If nTpEstru == 1                                      
			cHtml+='   <p align="center"><b> Vencidos </b></p>
		ElseIf nTpEstru == 2
			cHtml+='   <p align="center"><b> A Vencer </b></p>
		EndIf
		cHtml+='   <table width="100%" cellpadding="0" cellspacing="0" border="0"  style="border:1px solid #000000">'
		
		//Titulos
		cHtml+='   <tr>'
		For j:=1 to len(aDados[1])
			cHtml+='   <td align="center" class="CorTopoBorda" >'+aDados[1][j]+'</td>'
		Next i               
		cHtml+='   </tr>'
				
		//Registros
		For j:=2 to Len(aDados)
			cHtml+='   <tr>'
			For b:=1 to len(aDados[j])
				If ValType(aDados[j][b]) == "N"
					If	b == nPosDias .or.;
						b == nPosMoeda
						cDado := ALLTRIM(cValtoChar(aDados[j][b]))
					Else	
						cDado := ALLTRIM(TRANS(aDados[j][b],"@E 999,999,999,999.99"))
					Endif
				Else
					cDado := ALLTRIM(aDados[j][b])
				EndIf

				If j%2 <> 0//Definição do Estilo da Linha
					cEstiloLin := "CorLinhaBorda" 
				Else
					cEstiloLin := "Borda"
				EndIf				

				If EMPTY(cDado) .Or. ALLTRIM(cDado) == "<N/D>" 
						cHtml+='   <td class="'+cEstiloLin+'" >&nbsp;</td>'
				Else
					if b == nPosData .or. b == nPosData2
						cHtml+='   <td align="center" class="'+cEstiloLin+'" >'+DTOC(STOD(cDado))+'</td>'
					elseif b == nPosValor .OR. b == nPosSaldo
						cHtml+='   <td align= "right" class="'+cEstiloLin+'" >'+cDado+'</td>'
					elseif b == nPosDias .or. b == nPosMoeda
						cHtml+='   <td align="center" class="'+cEstiloLin+'" >'+cDado+'</td>'
					else
						cHtml+='   <td class="'+cEstiloLin+'" >'+cDado+'</td>'
					endif
				EndIf
				
			Next b			
			cHtml+='   </tr>'
		Next j
		cHtml+='   </table>'
		cHtml+='   <br>'		

EndCase

Return cHtml

/*
Funcao      : SendSocio()
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Jean Victor Rocha
Data/Hora   : 30/10/2013
*/
*----------------------------------*
Static Function SendSocio(aSoc,cMsg)
*----------------------------------*
//Local cAssunto:="Socio - Posicao de Cobrancas "+SM0->M0_NOME
Local cAssunto:="Posicao de Cobrancas "+SM0->M0_NOME

If lJob	
	If EMPTY(aSoc[3])
		_cTo:="gtbr.contasreceber@br.gt.com" //"renato.oliveira@br.gt.com" // mauro.bouhadoun@br.gt.com
		cAssunto += " , sem responsavel."
	Else
		_cTo:=aSoc[3]
	Endif
Else
	If EMPTY(aSoc[3]) 
		cAssunto += " , sem responsavel."
	EndIf
	_cTo := cEmail
EndIf

//Envia o e-mail
//ENVIA_EMAIL("","Socio - Posição Cobranças",cAssunto,cMsg,_cTo,"")
ENVIA_EMAIL("","Posição Cobranças",cAssunto,cMsg,_cTo,"")

Return .T.

/*
Funcao      : SendGer()
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Jean Victor Rocha
Data/Hora   : 30/10/2013
*/
*-------------------------*
Static Function GetSocios()         
*-------------------------*
Local aRet := {}
Local cQrySoc := ""

cQrySoc += " Select Z42.Z42_IDUSER as ID_SOCIO,Z42.Z42_TIPOFU as TIPO, Z42.Z42_NOUSER as NOME "//Z42.Z42_NOMEFU as NOME 
cQrySoc += " From "+RETSQLNAME("Z42")+" Z42
cQrySoc += " Where Z42.D_E_L_E_T_ <> '*' 
If !EMPTY(cSocDe)
	cQrySoc += " AND Z42.Z42_CPF >= '"+cSocDe+"'
EndIf
If !EMPTY(cSocAte)
	cQrySoc += " AND Z42.Z42_CPF <= '"+cSocAte+"'     
EndIf
cQrySoc += " Union ALL

cQrySoc += " Select SA3.A3_COD as ID_SOCIO,'1' as TIPO,SA3.A3_NOME as NOME 
cQrySoc += " From "+RETSQLNAME("Z42")+" Z42
cQrySoc += " 	Left Join (Select * From "+RETSQLNAME("SA3")+" Where D_E_L_E_T_ <> '*') AS SA3 on (RTRIM(SA3.A3_NOME) = RTRIM(Z42.Z42_NOMEFU) OR RTRIM(SA3.A3_NOME) = RTRIM(Z42.Z42_NOUSER))
cQrySoc += " Where Z42.D_E_L_E_T_ <> '*'
cQrySoc += " AND SA3.A3_COD <> ''
If !EMPTY(cSocDe)
	cQrySoc += " AND Z42.Z42_CPF >= '"+cSocDe+"'
EndIf
If !EMPTY(cSocAte)
	cQrySoc += " AND Z42.Z42_CPF <= '"+cSocAte+"'     
EndIf

If select("TMPSOC") > 0
	TMPSOC->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySoc), "TMPSOC", .F., .F. )

While TMPSOC->(!EOF())
	aAdd(aRet,{TMPSOC->ID_SOCIO,TMPSOC->TIPO,TMPSOC->NOME})
	TMPSOC->(DbSkip())
EndDo

Return aRet

/*
Funcao      : PrepEmai()
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 05/08/2015
*/
*----------------------------------*
Static Function PrepEmai(cQualResp)
*----------------------------------*

Default cQualResp:= ""

if !empty(cQualResp)

	aSocios:=QuerySocio(cQualResp)
	For nSeq:=1 to len(aSocios)
		_cTo:=""	
	
		cMsg := MontaEm1(cTipo_,aSocios[nSeq][1],aSocios[nSeq][2],cQualResp)//Monta o corpo do e-mail
	
		DBSelectArea("SM0")
		DbSetOrder(1)
		DbSeek(cEmpAnt)

		cAssunto:="Posicao de Cobrancas"	

		If lJob	
			if empty(aSocios[nSeq][1])
				_cTo:="gtbr.contasreceber@br.gt.com"//"renato.oliveira@br.gt.com"
				
				if cQualResp == "SOC"
					cAssunto:="Posicao de Cobrancas "+SM0->M0_NOME+", sem socio responsavel."
			    elseif cQualResp == "CTA"
			    	cAssunto:="Posicao de Cobrancas "+SM0->M0_NOME+", sem gerente conta."
			    elseif cQualResp == "CTB"
			    	cAssunto:="Posicao de Cobrancas "+SM0->M0_NOME+", sem gerente contabil."
			    endif
			    
			else
				_cTo:=aSocios[nSeq][2]
			endif 
		Else
			If empty(aSocios[nSeq][1]) 
				if cQualResp == "SOC"
					cAssunto:="Posicao de Cobrancas, sem socio responsavel."
				elseif cQualResp == "CTA"
					cAssunto:="Posicao de Cobrancas, sem gerente conta."
				elseif cQualResp == "CTB"
			    	cAssunto:="Posicao de Cobrancas, sem gerente contabil."				
				endif
			EndIf
			_cTo := cEmail
		EndIf
			     
		//Envia o e-mail
		If !EMPTY(cMsg)
			ENVIA_EMAIL("","Posição Cobranças",cAssunto,cMsg,_cTo,"")
		EndIf
	Next

endif
	
Return