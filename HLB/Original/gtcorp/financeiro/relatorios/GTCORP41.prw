#Include "Protheus.ch"
#Include "Ap5mail.ch"
#Include "Topconn.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTCORP41
Parametros  : cTipo ('1')- Retorna os que estão 10 dias vencidos / ('2')- Retorna os vencidos a 10 ou mais dias
Retorno     : Nil
Objetivos   : Fonte utilizado por schedules, para envio de e-mail para os sócios responsáveis por seus títulos, dos quais os títulos (SE1) estão vencendo.
Autor       : Matheus Massarotto
Data/Hora   : 10/10/2012    15:39
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

User Function GTCORP41(aParam)
cTipo	:=aParam[1]//Tipo 1 - Retorna os que estão 10 dias vencidos, Tipo 2 - Retorna os vencidos a 10 dias ou mais 
cEmp	:=aParam[2]//Empresa que deverá ser executada a função
cFil	:=aParam[3]//Filial que sera executada a função

DEFAULT cFil:="01"

if Select("SX3")<=0
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cEmp Filial cFil
endif

Private aArea		:=GETAREA()
Private cNomeEmp	:=""
Private aSocios:={}

DEFAULT cTipo:="2"

if !cEmpAnt $ "Z4"
	CONOUT("Função não disponível para a empresa!")
	Return()
endif
                                                                                     
SET DATE FORMAT "dd/mm/yyyy"

aSocios:=QuerySocio(cTipo)

For nSeq:=1 to len(aSocios)
_cTo:=""	
	//Monta o corpo do e-mail
	cMsg:=MontaEm1(cTipo,aSocios[nSeq][1])
	                                 
	DBSelectArea("SM0")
	DbSetOrder(1)
	DbSeek(cEmpAnt)
	cNomeEmp:=SM0->M0_NOME
	
	cAssunto:="Posicao de Cobrancas Outsourcing: "+cNomeEmp
	
	if empty(aSocios[nSeq][1])
		//_cTo:="matheus.massarotto@br.gt.com;alexandre.mori@br.gt.com"
		_cTo:="sergio.tsujioka@br.gt.com"
		cAssunto:="Posicao de Cobrancas Outsourcing: "+cNomeEmp+", sem vendedor responsavel."
	else
		//_cTo:="matheus.massarotto@br.gt.com"
		
		if empty(aSocios[nSeq][2])
			_cTo:="sergio.tsujioka@br.gt.com"
			cAssunto:="Posicao de Cobrancas Outsourcing: "+cNomeEmp+", sem email de vendedor preenchido."
		else
			_cTo:=aSocios[nSeq][2]
		endif
		
		conout(aSocios[nSeq][2])
	endif
	
	//Envia o e-mail
	ENVIA_EMAIL("","Posição Cobranças",cAssunto,cMsg,_cTo,"")
Next

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

*-----------------------------------------------------------------------------------------*
Static Function ENVIA_EMAIL(cArquivo,cTitulo,cSubject,cBody,cTo,cCC)
*-----------------------------------------------------------------------------------------*
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg
Local cBody1   :=""
Local cCC      := "sergio.tsujioka@br.gt.com"

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
		CONOUT("Erro de gravação do Destino. ROTINA: GTCORP41 . Error = "+ str(ferror(),4),'Erro')
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
      BCC "matheus.massarotto@br.gt.com";
      SUBJECT cSubject BODY cBody1+cBody ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "matheus.massarotto@br.gt.com";
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
Data/Hora   : 22/05/2012	16:41
*/

*-----------------------------------*
Static Function MontaEm1(cTipo,cVendedor)
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
Local aDados:=Query(cTipo,cVendedor)
Local cDado:=""

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
//cHtml+='   		-ms-filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7A59A5, endColorstr=#FFFFFFFF);'

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
nPosData:=aScan(aDados[1],{|x| Alltrim(x) == "Vencimento"})
//Pega a Posição do valor original no array
nPosValor:=aScan(aDados[1],{|x| Alltrim(x) == "Valor Original"})
//Pega a Posição do saldo no array
nPosSaldo:=aScan(aDados[1],{|x| Alltrim(x) == "Saldo"})
//Pega a Posição dos dias vencidos
nPosDias:=aScan(aDados[1],{|x| Alltrim(x) == "Dias Vencidos"})

For i:=1 to len(aDados)

	cHtml+='   <tr>'
		
		For j:=1 to len(aDados[i])-3	

			if ValType(aDados[i][j])=="N"
				if j==nPosDias
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
					if j==nPosData
						cHtml+='   <td class="CorLinhaBorda" align="center">'+DTOC(STOD(cDado))+'</td>'
					elseif j==nPosValor .OR. j==nPosSaldo
						cHtml+='   <td align="right" class="CorLinhaBorda">'+cDado+'</td>'
					elseif j==nPosDias 
						cHtml+='   <td align="center" class="CorLinhaBorda">'+cDado+'</td>'
					else
						cHtml+='   <td class="CorLinhaBorda">'+cDado+'</td>'
					endif
				else
					if j==nPosData
						cHtml+='   <td class="Borda" align="center">'+DTOC(STOD(cDado))+'</td>'
					elseif j==nPosValor .OR. j==nPosSaldo
						cHtml+='   <td align="right" class="Borda">'+cDado+'</td>'
					elseif j==nPosDias
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
Data/Hora   : 22/05/2012	09:41
*/

*-----------------------------*
Static Function Query(cTipo,cVendedor)
*-----------------------------*
Local cQry		:=""
Local aDados	:={}
Local nTotQtde	:=0	//Variavel para total
Local nTotValor	:=0	//Variavel para total
Local nTotSaldo	:=0	//Variavel para total

conout("GTCORP41 - Socio:"+valtype(cVendedor))
/*
cQry+=" SELECT CN9.CN9_NUMERO,"+CRLF 
cQry+=" SA1.A1_COD+' - '+SA1.A1_NOME AS CLIENTE,"+CRLF
cQry+=" SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,"+CRLF
cQry+=" SE1.E1_VENCREA AS VENCTO,"+CRLF
cQry+=" SE1.E1_VALOR AS VALOR,"+CRLF
cQry+=" SE1.E1_SALDO AS SALDO,"+CRLF
//cQry+=" 'Aberto' AS CSTATUS,"+CRLF
cQry+=" datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,"+CRLF
cQry+=" CN9.CN9_P_GER,"+CRLF
cQry+=" ISNULL(SA3.A3_NOME,'') AS A3_NOME,"+CRLF
cQry+=" ISNULL(SA3.A3_EMAIL,'') A3_EMAIL"+CRLF
cQry+=" FROM "+RETSQLNAME("SE1")+" SE1"+CRLF
cQry+=" JOIN "+RETSQLNAME("SC5")+" SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM"+CRLF
cQry+=" JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9.CN9_NUMERO=SC5.C5_MDCONTR"+CRLF
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA"+CRLF
cQry+=" LEFT JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD=CN9.CN9_P_GER"+CRLF
cQry+=" WHERE E1_SALDO>0 AND C5_MDCONTR<>'' AND SC5.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''"+CRLF
cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate())"+iif(cTipo=="1","=11",">=11")+" AND CN9.CN9_P_GER='"+cSocio+"'"+CRLF
cQry+=" GROUP BY CN9_NUMERO,SA1.A1_COD+' - '+SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_SALDO,CN9.CN9_P_GER, A3_NOME, A3_EMAIL"+CRLF
cQry+=" ORDER BY CN9_P_GER,VENCTO
*/

cQry+=" SELECT SE1.E1_FILIAL,
cQry+=" SA1.A1_COD+' - '+SA1.A1_NOME AS CLIENTE,
cQry+=" SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA AS NF,
cQry+=" SE1.E1_VENCREA AS VENCTO,
cQry+=" SE1.E1_VALOR AS VALOR,
cQry+=" SE1.E1_SALDO AS SALDO,
cQry+=" datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS,
cQry+=" ISNULL(SA3.A3_NOME,'') AS A3_NOME,
cQry+=" ISNULL(SA3.A3_EMAIL,'') A3_EMAIL
cQry+=" FROM SE1Z40 SE1
cQry+=" JOIN SA1Z40 SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" LEFT JOIN SA3Z40 SA3 ON SA3.A3_COD=SA1.A1_VEND
cQry+=" WHERE E1_SALDO>0 AND SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate())>=11 AND SE1.E1_TIPO='NF' AND SA3.A3_COD='"+cVendedor+"' AND SA3.A3_P_REMAI='T'
cQry+=" GROUP BY SE1.E1_FILIAL,SA1.A1_COD+' - '+SA1.A1_NOME,SE1.E1_PREFIXO+' '+SE1.E1_NUM+''+SE1.E1_PARCELA,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_SALDO,A3_NOME, A3_EMAIL
cQry+=" ORDER BY VENCTO
    
		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0

			AADD(aDados,{"Filial","Cliente","Título","Vencimento","Valor Original","Saldo","Dias Vencidos","","",""})
			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())

				AADD(aDados,{QRYTEMP->E1_FILIAL,QRYTEMP->CLIENTE,QRYTEMP->NF,QRYTEMP->VENCTO,QRYTEMP->VALOR,QRYTEMP->SALDO,QRYTEMP->DIAS,"",QRYTEMP->A3_NOME,QRYTEMP->A3_EMAIL})
				nTotSaldo+=QRYTEMP->SALDO
				nTotValor+=QRYTEMP->VALOR
				nTotQtde++
				QRYTEMP->(DbSkip())
			Enddo
				AADD(aDados,{"<b><center>TOTAIS</center></b>","&nbsp;","<center>"+cvaltochar(nTotQtde)+" títulos</center>","",nTotValor,nTotSaldo,"&nbsp;","","",""})
		endif
Return(aDados)

/*
Funcao      : QuerySocio()
Parametros  : cTipo
Retorno     : aSocios
Objetivos   : Cria a query e retorna um array com as informações |Cod Sócio|E-mail Socio|
Autor       : Matheus Massarotto
Data/Hora   : 22/05/2012	09:41
*/
*-------------------------------*
Static Function QuerySocio(cTipo)
*-------------------------------*
Local cQry:=""
Local aSocios:={}
Local cExc := "paulo.dortas@br.gt.com"//Exceções.

/*
cQry+=" SELECT CN9.CN9_P_GER,SA3.A3_EMAIL"+CRLF
cQry+=" FROM "+RETSQLNAME("SE1")+" SE1"+CRLF
cQry+=" JOIN "+RETSQLNAME("SC5")+" SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM"+CRLF
cQry+=" JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9.CN9_NUMERO=SC5.C5_MDCONTR"+CRLF
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA"+CRLF
cQry+=" LEFT JOIN "+RETSQLNAME("SA3")+" SA3 ON SA3.A3_COD=CN9.CN9_P_GER"+CRLF
cQry+=" WHERE E1_SALDO>0 AND C5_MDCONTR<>'' AND SC5.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''"+CRLF
cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate())"+iif(cTipo=="1","=11",">=11")+CRLF
cQry+=" GROUP BY CN9.CN9_P_GER,SA3.A3_EMAIL"+CRLF
cQry+=" ORDER BY CN9_P_GER"
*/

cQry+=" SELECT SA3.A3_COD,ISNULL(SA3.A3_EMAIL,'') A3_EMAIL
cQry+=" FROM SE1Z40 SE1
cQry+=" JOIN SA1Z40 SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA
cQry+=" LEFT JOIN SA3Z40 SA3 ON SA3.A3_COD=SA1.A1_VEND
cQry+=" WHERE E1_SALDO>0 AND SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''
cQry+=" AND datediff(day,SE1.E1_VENCREA,getdate())>=11 AND SE1.E1_TIPO='NF' AND SA3.A3_P_REMAI='T'
cQry+=" GROUP BY A3_COD,A3_EMAIL
cQry+=" ORDER BY A3_COD

		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
		
		Count to nRecCount
        
		if nRecCount >0

			QRYTEMP->(DbGotop())
		    
			While QRYTEMP->(!EOF())
				If !ALLTRIM(UPPER(QRYTEMP->A3_EMAIL)) $ ALLTRIM(UPPER(cExc))
					AADD(aSocios,{QRYTEMP->A3_COD,QRYTEMP->A3_EMAIL})
				EndIf
				QRYTEMP->(DbSkip())
			Enddo
		
		endif

Return(aSocios)