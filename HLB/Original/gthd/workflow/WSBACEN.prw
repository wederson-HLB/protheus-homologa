#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECTS.CH"  
/*
Funcao      : DIABACEN
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Programa de integração de taxa
Autor       : Biale,Tiago Luiz Mendonça
Data/Hora   : 28/04/2010
Modificações: 16/04/2013 - MSM - Alterado regra para executar o job 1 vez e gravar a taxa em todos os ambientes
			  07/11/2014 - RRP - Alteração do fonte para inclusão do EURO para atualização automática. Chamado 022054. 
			  25/06/2015 - JVR - Tratamento para considerar os dados no GTHD, como, banco, porta, ambiente e outros.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 16/04/2012
Módulo      : Genérico.
*/
/*
PROCESSO: BUSCA DE DADOS BACEN PTAX VIA WEBSERVICE
----------------------------------------------------------------------
NOME: WSBACEN():NEW(dPar,nPar)
dPar ---> data da operacao financeira
npar ---> dado a resgatar, 1 para venda e 10813 para compra
----------------------------------------------------------------------
RETORNO: OBJETO COM ATRIBUTOS
::dData     := ----> DATA SOLICTADA
::dPTAX     := ----> DATA DE RETORNO (DIFERENTE QUANDO NAO HOUVE OPERACAO NADATA SOLICITADA)
::nTipo     := ----> TIPO SOLICITADO
::cTipo     := ----> DESCRICAO DO TIPO
::nValor    := -----> VALOR DE RETORNO
::cMensagem := -----> MENSAGEM DE OK OU ERRO
::lNodia    := .T.------> .T. PARA PTAX DO DIA SOLICITADO, .F. PTAX DO ULTIMO DIA VALIDO
::lStatus   := .T. -----> .T. PARA PROCESSAMENTO OK, .F. PARA ERRO    

OBS: TRATAMENTO PARA A DATA, O OBJETO TRATA APENAS 7 ANTECIPADOS DIAS FORA DATA
     EXEMPLO, SE SOLICITADO UM DOMINGO ELE TRAZ A ULTIMA SEXTA
     
     fonte TSTBACEN() 
----------------------------------------------------------------------
*/
*----------------------*
User Function DIABACEN()
*----------------------*
Local xPar1 := ""
Local xPar2 := 1     // CODIGO 1 PARA DOLAR
Local oBC
Local nDollar 	:= 0  
Local nEuro   	:= 0
Local nLibraEst	:= 0
Local nDollarCan:= 0
Local lLock   	:= .t.  
Local cQry		:= ""
Local nHndOra	:= 0
Local aTables := {"SM2"}

Private cDiaSemana := ""
//Private cDBOra 	:= "MSSQL7/"	//Nome do Banco de Dados / Nome do Ambiente
//Private cSrvOra := "10.0.30.5" 	//Servidor
//Private nPorta	:= 7890			//Porta
Private cMsgAuxErr	:= ""
Private cMsgAuxOk	:= ""

//MSM - 12/04/2013 - Incluido para evitar problemas com o formato da data
SET DATE FORMAT "dd/mm/yyyy"

xPar1 := DATE()

RPCSETTYPE(3)

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FIN" TABLES "SM2"
//RpcSetEnv( "YY","01", , , "FIN", , aTables, , , ,  )
		
//SELECT NO GTHD
cQry := " SELECT * FROM GTHD..Z10010 "
cQry += " WHERE D_E_L_E_T_='' "
cQry += " 	AND Z10_BANCO <> ''
cQry += " 	AND Z10_IPBD <> ''
cQry += " 	AND Z10_BLOQ <> 'S'
cQry += "   AND Z10_AMB not in ('GTHD')
If tcsqlexec(cQry)<0
	conout("Fonte:DIABACEN -- Ocorreu um problema na busca das informações no GTHD: FROM SQLTB717.GTHD.dbo.Z10010!!")
	return
EndIf

If select("TRBQRY")>0
	TRBQRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBQRY",.T.,.T.)

Count to nRecCount

if nRecCount > 0
	TRBQRY->(DbGotop())                    
	
	xPar2	:= 1     // CODIGO 1 PARA DOLAR
	oBC		:= WSBACEN():NEW(xPar1,xPar2)
	nDollar	:= oBC:NVALOR

	oBc		:= nil  
	xPar2	:= 21623 //Série Libra esterlina (venda)
	oBC		:= WSBACEN():NEW(xPar1,xPar2)
	nLibraEst	:= oBC:NVALOR 

	oBc		:= nil  
	xPar2	:= 21619 //Série EURO no banco central
	oBC		:= WSBACEN():NEW(xPar1,xPar2)
	nEuro	:= oBC:NVALOR 
	
	oBc		:= nil  
	xPar2	:= 21635 //Série Dólar Canadense (venda)
	oBC		:= WSBACEN():NEW(xPar1,xPar2)
	nDollarCan	:= oBC:NVALOR 

	If nDollar > 0 .OR. nEuro > 0
		While TRBQRY->(!EOF())
			//MSM - 27/05/2015 - Alteração para tratar rotina para novo release
			//cDBOra	:= Alltrim(TRBQRY->Z10_AMB)
			//cAmb	:= Alltrim(TRBQRY->Z10_AMB)
			//cBanco	:= cAmb
	        /*if Alltrim(TRBQRY->Z10_RELEAS) == "R8"
	        	nPorta:=7891
	        endif
			if "AMB" $ UPPER(cAmb)
				cBanco+="_P10"
			elseif "GTIS" $ UPPER(cAmb)
				cBanco+="_P10"
			elseif "GTRJ" $ UPPER(cAmb)
				cBanco+="_P10"
			elseif "GTLP" $ UPPER(cAmb)
				cBanco+="_P10"
			elseif "GTCORP" $ UPPER(cAmb)
				cBanco+="_P11"
			endif*/
			//cDBOra+=Alltrim(cBanco)
			//nHndOra := TcLink(cDbOra,cSrvOra,nPorta) //Abre uma conexão com o Servidor TOPConnect
			nHndOra := TcLink( ALLTRIM(TRBQRY->Z10_BANCO),TRBQRY->Z10_IPBD,VAL(TRBQRY->Z10_TOPORT))//Abre conexão com o Servidor TOP
			If nHndOra < 0 
				//Conout("Função DIABACEN: Erro ao conectar no banco, Server: "+cSrvOra+", Porta:"+cvaltochar(nPorta)+", DataBase:"+cDBOra)
				Conout("Função DIABACEN: Erro ao conectar no banco,"+;
						" Server: "+TRBQRY->Z10_IPBD+", Porta:"+TRBQRY->Z10_TOPORT+", DataBase:"+TRBQRY->Z10_BANCO)
				//EnviaMail("Erro",0,cAmb)
			   	if !empty(cMsgAuxErr)
				   	cMsgAuxErr += ", "
			   	endif
			   	//cMsgAuxErr += alltrim(Upper(cAmb))
			   	cMsgAuxErr += Upper(Alltrim(TRBQRY->Z10_AMB))
			Else
				//Chama rotina para atualizar a moeda
				If Select("M2TMP") > 0
					M2TMP->(DbCloseArea())
				EndIf

				//Verifico se existe a tabela no banco
				if !TCCanOpen("SM2YY0")
					conout("Fonte:DIABACEN -- Não existe a tabela SM2YY0 no ambiente:"+Upper(Alltrim(TRBQRY->Z10_AMB)) )
				   	
				   	if !empty(cMsgAuxErr)
					   	cMsgAuxErr += ", "
				   	endif
					cMsgAuxErr += Upper(Alltrim(TRBQRY->Z10_AMB))+"("+ALLTRIM(TRBQRY->Z10_RELEAS)+")"
					TRBQRY->(DbSkip())
					Loop
				endif

				//Abre a tabela do ambiente que será atualizado.
				USE "SM2YY0" ALIAS "M2TMP" Shared NEW VIA "TOPCONN" INDEX "SM2YY01"
					M2TMP->(DbSetOrder(1))
					If M2TMP->(DbSeek(DTOS(DATE())))
						M2TMP->(RecLock("M2TMP",.F.))
					Else
						M2TMP->(RecLock("M2TMP",.T.))
					EndIf
					M2TMP->M2_DATA	 := DATE()
					M2TMP->M2_MOEDA2 := nDollar
					M2TMP->M2_MOEDA4 := Round(1,4)
					M2TMP->M2_MOEDA5 := nEuro

					If "GTCORP" $ UPPER(Alltrim(TRBQRY->Z10_AMB))
						M2TMP->M2_MOEDA3 := nLibraEst
						M2TMP->M2_MOEDA6 := nDollarCan
					EndIf

					M2TMP->(MsUnlock())
					M2TMP->(DbCloseArea())
		     	COMMIT
				
				TcUnlink(nHndOra)//Encerra uma conexão com o TOPConnect.
			   	if !empty(cMsgAuxOk)
				   	cMsgAuxOk+=", "
			   	endif
			   	cMsgAuxOk += Upper(Alltrim(TRBQRY->Z10_AMB))+"("+ALLTRIM(TRBQRY->Z10_RELEAS)+")"

			   	//EnviaMail("Ok",nDollar,cAmb)
			Endif
			TRBQRY->(DbSkip())
		Enddo
	EndIf
EndIf	     

//Envia e-mail no final da execução
EnviaMail(nDollar,nEuro,cMsgAuxErr,cMsgAuxOk,nLibraEst,nDollarCan)     

RESET ENVIRONMENT
oBc := nil
//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
RETURN

/*
=================================================
Objeto de tratamento do acesso aos dados do BACEN
=================================================
*/      
CLASS WSBacen

//======================
METHOD NEW() constructor

//=============
METHOD finish()  

DATA dData   // data da operacao
DATA dPTAX   // data do ptax
DATA nTipo   // tipo
DATA cTipo
DATA nValor  
DATA cDia
DATA cMensagem           
DATA lNoDia
DATA lStatus 

ENDCLASS
                     
//=====================================
METHOD NEW(_dData,_nTipo) CLASS WsBacen      
Private cSoapSend	:= ""
Private cSoapAction := ""
Private cURL := ""
Private aSem := {"DOMINGO","SEGUNDA","TERCA","QUARTA","QUINTA","SEXTA","SABADO"}
Private nProc := 0
Private __lWsErro //:= .f.  //variavel para controle de erro, se .t. erro de operacao
Private __cWSErro //:= ""   // variavel com o log de erro caso __lWSErro seja .t.
Private __dData //:= _dData
Private __dPTAX //:= _dData 
Private __nTipo //:= _nTipo
Private __cTipo //:= IIF(_nTipo == 1, "VENDA" , IIF(_nTipo==10813,"Compra","Indeterminado") )
Private __nValor //:= 0
Private __cDia   //:= aSem[dow(::dPTAX)]
Private __cMensagem //:= "Objeto Iniciado"
Private __lNoDia  //:= .t.
Private __lStatus //:= .T.

DEFAULT _dData := date()
DEFAULT _NTIPO := 1 // VENDA

__lWsErro := .f.  //variavel para controle de erro, se .t. erro de operacao
__cWSErro := ""   // variavel com o log de erro caso __lWSErro seja .t.
__dData := _dData
__dPTAX := _dData 
__nTipo := _nTipo
__cTipo := IIF(_nTipo == 1, "VENDA" , IIF(_nTipo==10813,"Compra","Indeterminado") )
__nValor := 0
__cDia   := aSem[dow(__dPTAX)]
__cMensagem := "Objeto Iniciado"
__lNoDia  := .t.
__lStatus := .T.

cURL := 'https://www3.bcb.gov.br/wssgs/services/FachadaWSSGS'

cSoapAction := ""
 
oRet := GETSEFAZ(__dPtax,__nTipo)
     
While !UPPER(VALTYPE(oRet)) == "O" .and. nProc < 7
	nProc++ 
	__dPTAX := __dPTAX - 1
	oRet := GETSEFAZ(__dPtax,__nTipo)
EndDo
  
Do Case
	Case nProc == 7
		__nValor    := 0
        __cDia      := aSem[dow(__dPTAX)]
        __cMensagem := "Processado inversao de data com mais de 7 niveis"
        __lNoDia    := .f.
        __lStatus   := .f.

	case UPPER(VALTYPE(oRet)) == "O"
        __nValor    := val(oRet:_MULTIREF:TEXT)
        __cDia      := aSem[dow(__dPTAX)]
        __cMensagem := "Processado em "+DTOC(DATE())+" PTAX DE "+DTOC(__dPTAX)+" | "+__cTipo
        __lNoDia    := iif(__dData == __dPTAX,.t.,.f.)
        __lStatus   := .t.
      
	case __lWsErro 
       __nValor    := 0
       __cDia      := aSem[dow(__dPTAX)]
       __cMensagem := "Falha |"+__cWSErro
       __lNoDia    := .f.
       __lStatus   := .f.
      
	otherwise
        __nValor    := 0
        __cDia      := aSem[dow(__dPTAX)]
        __cMensagem := "Falha inesperada |Abra um chamado para equipe de sistemas."
        __lNoDia    := .f.
        __lStatus   := .f.

endcase 
   
::dData := __dData          
::dPTAX := __dPTAX
::nValor    := val(oRet:_MULTIREF:TEXT)
::cDia      := aSem[dow(__dPTAX)]
::cMensagem := "Processado em "+DTOC(DATE())+" PTAX DE "+DTOC(__dPTAX)+" | "+__cTipo
::lNoDia    := iif(__dData == __dPTAX,.t.,.f.)
::lStatus   := .t.

RETURN(self)

//===========================
method Finish() class wsbacen
::dData     := STOD("")
::dPTAX     := STOD("")
::nTipo     := 0
::cTipo     := ""
::nValor    := 0
::cDia      := ""
::cMensagem := ""  
::lStatus   := .F. 
return(self) 
                                                                      
*---------------------------------*
STATIC FUNCTION GETSEFAZ(_xx1,_xx2)
*---------------------------------*
//---------------------------------------------
// SOAP REQUEST RETIRADO DA FERRAMENTA SOAPUI
//---------------------------------------------
x1 := alltrim(str(int(_xx2)))
x2 := STRZERO(DAY(_xx1),2)+"/"+strzero(month(_xx1),2)+"/"+strzero(year(_xx1),4) 

cSoapSend := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
cSoapSend += '					 xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pub="http://publico.ws.casosdeuso.sgs.pec.bcb.gov.br">'
cSoapSend += '   <soapenv:Header/>'
cSoapSend += '   <soapenv:Body>'
cSoapSend += '      <pub:getValor soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
cSoapSend += '         <in0 xsi:type="xsd:long">'+x1+'</in0>'
cSoapSend += '         <in1 xsi:type="xsd:string">'+x2+'</in1>'
cSoapSend += '      </pub:getValor>'
cSoapSend += '   </soapenv:Body>'
cSoapSend += '</soapenv:Envelope>'

oXml := ITFSvcSoapCall(cUrl, cSoapSend, cSoapAction, 2)

return(oXML)

*--------------------------------------------------------------------*
STATIC Function ITFSvcSoapCall(cUrl, cSoapSend, cSoapAction, DbgLevel)
*--------------------------------------------------------------------*
// variaveis para o request e reponse do post
Local XMLPostRet := ""
Local nTimeOut	:= 120
Local aHeadOut	:= {}
Local XMLHeadRet := ""
// variaveis para checar o header response
Local cHeaderRet := ""
Local nPosCType := 0
Local nPosCTEnd := 0
// variaveis para o parser XML
Local oXmlRet := NIL
Local cError := ""
Local cWarning := ""
// variaveis para retirar ENVELOPE e BODY
Local aTmp1 := {}
Local aTmp2 := {}
Local cEnvSoap := ""
Local cEnvBody := ""
Local cSoapPrefix := ""
// variaveis para determinar soapfault
Local cFaultString := ""
Local cFaultCode := ""

DEFAULT DbgLevel := 2

// Adiciona informaçoes no header HTTP
aadd(aHeadOut,'SOAPAction: '+cSoapAction)
aadd(aHeadOut,'Content-Type: text/xml; charset=utf-8' )
// Acrescenta o UserAgent na requisição ...
aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')

If DbgLevel > 0
	conout(padc(" SOAPSEND ",79,"-"))
	conout(strtran(cSoapSend,"><",">"+CHR(13)+CHR(10)+"<"))
	conout(replicate("-",79))
Endif

// REALIZANDO O POST
XMLPostRet := HttpPost(cUrl,"",cSoapSend,nTimeOut,aHeadOut,@XMLHeadRet)

// Verifica Retorno
If XMLPostRet == NIL
	wserrolog("WSCERR044 / Não foi possível POST : URL " + cURL)
	return .f.
ElseIf Empty(XMLPostRet)
	If !empty(XMLHeadRet)
		wserrolog("WSCERR045 / Retorno Vazio de POST : URL "+cURL+' ['+XMLHeadRet+']')
		return .f.
	Else
		wserrolog("WSCERR045 / Retorno Vazio de POST : URL "+cURL)
		return .f.
	Endif
Endif

If DbgLevel > 0
	conout(padc(" POST RETURN ",79,'='))
	If !empty(XMLHeadRet)
		conout(XMLHeadRet)
		conout(replicate('-',79))
	Endif
	conout(XMLPostRet)
	conout(replicate('=',79))
Endif

// --------------------------------------------------------
// Antes de Mandar o XML para o PArser , Verifica se o Content-Type é XML !
// --------------------------------------------------------
If !empty(XMLHeadRet)
	cHeaderRet := XMLHeadRet
	nPosCType := at("CONTENT-TYPE:",Upper(cHeaderRet))
	If nPosCType > 0
		cHeaderRet := substr(cHeaderRet,nPosCType)
		nPosCTEnd := at(CHR(13)+CHR(10) , cHeaderRet)
		cHeaderRet := substr(cHeaderRet,1,IIF(nPosCTEnd > 0 ,nPosCTEnd-1, NIL ) )
		If !"XML"$upper(cHeaderRet)
			wserrolog("WSCERR064 / Invalid Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
						" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
			return .f.
		Endif
	Else
		wserrolog("WSCERR065 / EMPTY Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
						" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
		return .f.
	Endif
Endif

//--------------------------------------------------------
// Passa pela XML Parser...
//-------------------------------------------------------
oXmlRet := XmlParser(XMLPostRet,'_',@cError,@cWarning)

If !empty(cWarning)
	wserrolog('WSCERR046 / XML Warning '+cWarning+' ( POST em '+cURL+' )'+CHR(13)+CHR(10)+" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
	return .f.
ElseIf !empty(cError)
	wserrolog('WSCERR047 / XML Error '+cError+' ( POST em '+cURL+' )'+CHR(13)+CHR(10)+" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
	return .f.
ElseIF oXmlRet = NIL
	wserrolog('WSCERR073 / Build '+GETBUILD()+' XML Internal Error.'+CHR(13)+CHR(10)+" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
	return .f.
Endif

//--------------------------------------------------------
// Identifica os nodes inicias ENVELOPE e BODY Eles devem ser os primeiros niveis do XML
// RETIRA OS NODES E RETORNA APENAS OS DADOS
//--------------------------------------------------------
If Empty(aTmp1 := ClassDataArr(oXmlRet))
	aTmp1 := NIL
	wserrolog('WSCERR056 / Invalid XML-Soap Server Response : soap-envelope not found.')
	return .f.
Endif

If empty(cEnvSoap := aTmp1[1][1])
	aTmp1 := NIL
	wserrolog('WSCERR057 / Invalid XML-Soap Server Response : soap-envelope empty.')
	return .f.
Endif

// Limpa a variável temporária
aTmp1 := NIL

// ITFxGetInfo no lugar de xGetInfo é uma função da LIB de WEB SERVICES
// Elimina este node, re-atribuindo o Objeto
oXmlRet := ITFxGetInfo( oXmlRet, cEnvSoap  )

If valtype(oXmlRet) <> 'O'
	wserrolog('WSCERR058 / Invalid XML-Soap Server Response : Invalid soap-envelope ['+cEnvSoap+'] object as valtype ['+valtype(oXmlRet)+']')
	return .f.
Endif

If Empty(aTmp2 := ClassDataArr(oXmlRet))
	aTmp2 := NIL
	wserrolog('WSCERR059 / Invalid XML-Soap Server Response : soap-body not found.')
	return .f.
Endif

If empty(cEnvBody := aTmp2[1][1])
	aTmp2 := NIL
	wserrolog('WSCERR060 / Invalid XML-Soap Server Response : soap-body envelope empty.')
	return .f.
Endif

// Limpa a variável temporária
aTmp2 := NIL

// Elimina este node, re-atribuindo o Objeto
oXmlRet := ITFxGetInfo( oXmlRet, cEnvBody )

If valtype(oXmlRet) <> 'O'
	wserrolog('WSCERR061 / Invalid XML-Soap Server Response : Invalid soap-body ['+cEnvBody+'] object as valtype ['+valtype(oXmlRet)+']')
	return .f.
Endif

cSoapPrefix := substr(cEnvSoap,1,rat("_",cEnvSoap)-1)

If Empty(cSoapPrefix)
	wserrolog('WSCERR062 / Invalid XML-Soap Server Response : Unable to determine Soap Prefix of Envelope ['+cEnvSoap+']')
	return .f.
Endif

//--------------------------------------------------------
// TRATAMENTO DO SOAP FAULT, CASO TENHA SIDO RETORNADO UM
//--------------------------------------------------------
If ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:TEXT" ) != NIL
	// Se achou um soap_fault....
	
	cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
	
	If !empty(cFaultString)
		// deve ser protocolo soap 1.0 ou 1.1
		cFaultCode := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
		cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" )
	Else
		// caso contrario, trato como soap 1.2
		cFaultCode := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
		If Empty(cFaultCode)
			cFaultCode := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_CODE:TEXT" )
		Else
			cFaultCode += " [FACTOR] " + ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTACTOR:TEXT" )
		EndIf
		DEFAULT cFaultCode := ""
		cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_DETAIL:TEXT" )
		If !Empty(cFaultString)
			cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" ) + " [DETAIL] " + cFaultString
		Else
			cFaultString :=  ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_REASON:"+cSoapPrefix+"_TEXT:TEXT" )
			DEFAULT cFaultString := ""
			cFaultString += " [DETAIL] " + ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_DETAIL:TEXT" )
			DEFAULT cFaultString := ""
		Endif
	Endif
	
	// Aborta processamento atual com EXCEPTION
	wserrolog('WSCERR048 / SOAP FAULT '+cFaultCode+' ( POST em '+cURL+' ) : ['+cFaultString+']')
	return .f.
	
Endif

//--------------------------------------------------------
// Passou por Tudo .. então retorna um XML parseado Bonitinho ...
//--------------------------------------------------------

return oXmlRet

/* ----------------------------------------------------------------------------------
Funcao        ITFxGetInfo no lugar de xGetInfo
Parametros     oObj = Objeto XML
cObjCpoInfo = propriedade:xxx do objeto a retornar
Retorno        Conteudo solicitado. Caso não exista , retorna xDefault
Se xDefault não especificado , default = NIL
Exemplo        xGetInfo( oXml , '_SOAP_ENVELOPE:_SOAP_BODY:_NODE:TEXT' )
---------------------------------------------------------------------------------- */
*----------------------------------------------------------------------*
STATIC FUNCTION ITFxGetInfo( oXml ,cObjCpoInfo , xDefault , cNotNILMsg )
*----------------------------------------------------------------------*
Local bEval    := &('{ |x| x:' + cObjCpoInfo +' } ')
Local xRetInfo
Local bOldError := Errorblock({|e| Break(e) })

BEGIN SEQUENCE
xRetInfo := eval(bEval , oXml)
RECOVER
xRetInfo := NIL
END SEQUENCE

ErrorBlock(bOldError)

DEFAULT xRetInfo := xDefault

If xRetInfo == NIL .and. !empty(cNotNILMsg)
	__XMLSaveInfo := .T.
	wserrolog("WSCERR041 / "+cNotNILMsg)
Endif

Return xRetInfo    

/*
===========================================================================================
funcao wserrolog(cTexto)
Faz o tratamento das excecoes, gravando no log do console e liberando as variaveis de ambiente
__lWsErro := .t. ou seja, com erro
__cWSErro := "Texto do erro"

*/
*-------------------------------*
Static function wserrolog(cParam)
*-------------------------------*
__lWsErro := .t.
__cWSErro := alltrim(cParam) 

ConOut(replicate("=",50))
ConOut(".")
ConOut("  wserrolog ")
ConOut("  Data: "+DTOC(DATE())+"  Hora: "+time())
ConOut("  "+cParam)
ConOut(".") 
ConOut(".")
ConOut(".")
ConOut(replicate("=",50))
                  
return nil   

*-----------------------------------------------------------------------------*
Static Function EnviaMail(nVal,nVal2,cMsgAuxErr,cMsgAuxOk,nLibraEst,nDollarCan)     
*-----------------------------------------------------------------------------*
Local cServer   := AllTrim(GetNewPar("MV_RELSERV"," ")) //"mail.br.gt.com" //
Local cAccount  := AllTrim(GetNewPar("MV_RELFROM"," ")) //"totvs@br.gt.com" // 
Local cPassword := AllTrim(GetNewPar("MV_RELPSW" ," ")) //"Protheus@2010" //
Local cFrom 	:= "taxa.sistema@br.gt.com" //AllTrim(GetNewPar("MV_RELFROM"," "))
Local cTo       := ""
Local lOk      	:= .F.
Local cHtml     := ""
Local cSubject  := "Atualizacao de taxa"
Local cAnexos   := ""    
//Local cAmb      := GetEnvServer ()  
Local nPos   
Local cC
//DEFAULT	cAmb	:= ""
cTo += "log.sistemas@br.gt.com, tiago.mendonca@br.gt.com, renato.rezende@br.gt.com, jean.rocha@br.gt.com,"
cTo += " camilla.barbosa@br.gt.com, rogerio.silva@br.gt.com, maria.edvania@br.gt.com, cristhiane.maluly@br.gt.com, eliana.silva@br.gt.com, vitor.santos@br.gt.com"

cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
cEmail += '<title>Nova pagina 1</title></head><body>'
cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
cEmail += 'Taxa gravada no(s) ambiente(s) abaixo:</b></u></font></p>'   
cEmail += '<p><font face="Courier New" size="2">Ambiente(s) : '+alltrim(cMsgAuxOk)+'</p>'  
cEmail += '<p><font face="Courier New" size="2">Data		: '+DTOC(Date())+'</p>' 
cEmail += '<p><font face="Courier New" size="2">(2) Dollar           : '+ Alltrim(Str(nVal))+'</p>'
cEmail += '<p><font face="Courier New" size="2">(3) Libra esterlina	 : '+ Alltrim(Str(nLibraEst))+' (Apenas GTCORP)</p>'
cEmail += '<p><font face="Courier New" size="2">(4) Moeda4           : 1.00</p>'
cEmail += '<p><font face="Courier New" size="2">(5) Euro	         : '+ Alltrim(Str(nVal2))+'</p>'
cEmail += '<p><font face="Courier New" size="2">(6) Dollar Canadense : '+ Alltrim(Str(nDollarCan))+' (Apenas GTCORP)</p>'

If alltrim(cDiaSemana) == "SEXTA" 
	cEmail += '<p><font face="Courier New" size="2">TAXA REPLICADA PARA SABADO E DOMINGO</p>' 
EndIf   
If !EMPTY(cMsgAuxErr)
	cEmail += '<p>-----------------------------------------------------------------------------------------------------------------------------</p>'
	cEmail += 'Taxa não gravada no(s) ambiente(s) abaixo: </b></u></font></p>'   
	cEmail += '<p><font face="Courier New" size="2">Ambiente(s) : '+alltrim(cMsgAuxErr)+'</p>'  
EndIf         
cEmail += '<br>'   
cEmail += '<br>'
         	 
cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
cEmail += '<p align="center">www.grantthornton.com.br</p>'
cEmail += '</body></html>'

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk      

   If lOk  
	  SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cEmail ATTACHMENT cAnexos Result lOk  
   EndIf

DISCONNECT SMTP SERVER 
   
Return