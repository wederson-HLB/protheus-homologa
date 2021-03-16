#include 'totvs.ch'
#include 'tbiconn.ch'
#include 'xmlxfun.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWW001   ºAutor  ³Eduardo C. Romanini º Data ³  03/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Web Service para integração entre a solicitação de Fatura-  º±±
±±º          ³mento e o Bizagi.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Função  : GTWW001
Objetivo: Rotina para gerar um processo no Bizagi.
Autor   : Eduardo C. Romanini
Data    : 03/05/2012
*/
*----------------------------*
User Function GTWW001(cCodigo)
*----------------------------*
Local cXml    := ""
Local cXmlRet := ""
Local cEmp    := Substr(HttpSession->cEmpresa,1,2)
Local cFil    := Substr(HttpSession->cEmpresa,3,2)
Local cBanco  := ""
Local cIp     := ""
Local cTipo   := ""
Local cTab    := ""
Local cError  := ""
Local cWarning:= ""
Local cProcId := ""

Local nCon := 0

Local aCon := {}

Local oWs
Local oXmlRet

Default cCodigo := ZF0->ZF0_CODIGO

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

//Retorna o ambiente da empresa logada
aCon  := U_WFRetBanco(cEmp,cFil)
cBanco:= aCon[1]
cIp   := aCon[2]

//Posiciona o registro na solicitação.
ZF0->(DbSetOrder(1))
If !ZF0->(DbSeek(xFilial("ZF0")+cEmp+cFil+cCodigo))
	Return .F.
EndIf

//Cria o xml 
cXml := '<?xml version="1.0" encoding="utf-8" ?>'
cXml += "<BizAgiWSParam>"

//Define o usuário
//cXml += "<domain>GT</domain>"
//cXml += "<userName>admon</userName>"

//Define o Processo
cXml += "<Cases>"
cXml += "<Case>"
cXml += "<Process>Faturamento</Process>"
cXml += "<Entities>"
cXml += "<App>"

cXml += "<Faturamento>"

cXml += "<CodigoSolicitacao>"
cXml +=  EncodeUTF8( _NoTags(AllTrim(ZF0->ZF0_CODIGO)))
cXml += "</CodigoSolicitacao>"

//Informações do solicitante
ZW0->(DbSetOrder(1))
If ZW0->(DbSeek(xFilial("ZW0")+AllTrim(ZF0->ZF0_LOGIN)))
	cXml += "<NomeSolicitante>"
	cXml += EncodeUTF8( _NoTags(AllTrim(ZW0->ZW0_NOME)))
	cXml += "</NomeSolicitante>"

	cXml += "<EmailSolicitante>"
	cXml += EncodeUTF8( _NoTags(AllTrim(ZW0->ZW0_EMAIL)))
	cXml += "</EmailSolicitante>"
EndIf

//Informações da Empresa
cXml += "<Empresa>"

	cXml += "<CodFil>"
	cXml +=  _NoTags(AllTrim(ZF0->ZF0_CODEMP)+AllTrim(ZF0->ZF0_CODFIL))
	cXml += "</CodFil>"

	cXml += "<Codigo>"
	cXml +=  _NoTags(AllTrim(ZF0->ZF0_CODEMP))
	cXml += "</Codigo>"

	cXml += "<Filial>"
	cXml += _NoTags(AllTrim(ZF0->ZF0_CODFIL))
	cXml += "</Filial>"

	ZW1->(DbSetOrder(1))
	If ZW1->(DbSeek(xFilial("ZW1")+AllTrim(ZF0->ZF0_CODEMP)+AllTrim(ZF0->ZF0_CODFIL)))	
		cXml += "<Nome>"
		cXml += _NoTags(AllTrim(ZW1->ZW1_NFANT))
		cXml += "</Nome>"

		cXml += "<CNPJ>"
		cXml += _NoTags(AllTrim(ZW1->ZW1_CNPJ))
		cXml += "</CNPJ>"
	EndIf

cXml += "</Empresa>"

//Tipo da solicitação
cXml += "<TipoDaSolicitacao>"

If ZF0->ZF0_TIPO == "M"
	cTipo := "M"
	cXml += "Mercantil"
ElseIf ZF0->ZF0_TIPO == "S"
	cTipo := "S"
	cXml += "Servico"
EndIf
cXml += "</TipoDaSolicitacao>"

//Pedido
If !Empty(ZF0->ZF0_PEDIDO)
	cXml += "<Pedido>"	
	cXml += _NoTags(AllTrim(ZF0->ZF0_PEDIDO))
	cXml += "</Pedido>"	
EndIf

//Nosso Pedido
If !Empty(ZF0->ZF0_NOSSOP)
	cXml += "<NossoPedido>"	
	cXml += _NoTags(AllTrim(ZF0->ZF0_NOSSOP))
	cXml += "</NossoPedido>"	
EndIf

//Natureza da Operação ou Tipo de Serviço
If !Empty(ZF0->ZF0_NATOPE)
	cXml += "<NaturezaDaOperacao>"	
	cXml += _NoTags(AllTrim(ZF0->ZF0_NATOPE))
	cXml += "</NaturezaDaOperacao>"	
EndIf

//Condição de pagamento
If !Empty(ZF0->ZF0_CONPGT)
	cXml += "<CondicaoPagamento>"	
	cXml += _NoTags(AllTrim(ZF0->ZF0_CONPGT))
	cXml += "</CondicaoPagamento>"	
EndIf

//Destino da Mercadoria
If cTipo == "M"
	If !Empty(ZF0->ZF0_DESTME)
		cXml += "<DestinacaoMercadoria>"
		 
		If ZF0->ZF0_DESTME == "R"
			cXml += "Revenda"
		ElseIf ZF0->ZF0_DESTME == "C"
			cXml += "Consumo Final"
		EndIf
				
		cXml += "</DestinacaoMercadoria>"
	EndIf
EndIf

If cTipo == "S"

	//Cliente Estrangeiro
	cXml += "<PgtoClienteEstrangeiro>"

	If ZF0->ZF0_CLIEST == "B"
		cXml += "Brasil"
	ElseIf ZF0->ZF0_CLIEST == "E"
		cXml += "Exterior"
	EndIf

	cXml += "</PgtoClienteEstrangeiro>"
	
	//Contrato
	If AllTrim(ZF0->ZF0_CONTRA) == "S"
		cXml += "<Contrato>true</Contrato>"
		cXml += "<NumeroDoContrato>"+_NoTags(Alltrim(ZF0->ZF0_NUMCON))+"</NumeroDoContrato>"
		cXml += "<VigenciaDoContrato>"+_NoTags(Alltrim(ZF0->ZF0_VIGCON))+"</VigenciaDoContrato>"
	Else
		cXml += "<Contrato>false</Contrato>"
	EndIf
	
EndIf

//Nf Emitida para Fornecedor
cXml += "<NFEmitidaParaFornecedor>"

If cTipo == "S"
	cXml += "Não"
Else
	If ZF0->ZF0_NFFORN == "S"
		cXml += "Sim"
	Else
		cXml += "Não"
	EndIf
EndIf
cXml += "</NFEmitidaParaFornecedor>"

//Destinatario
If ZF0->ZF0_INCDES == "S"
	cXml += "<NovoDestinatario>true</NovoDestinatario>"
Else
	cXml += "<NovoDestinatario>false</NovoDestinatario>"	
Endif

cXml += "<Destinatario>"

cXml += "<Codigo>"+_NoTags(Left(AllTrim(ZF0->ZF0_CODDES),6))+"</Codigo>"
cXml += "<Loja>"+_NoTags(Right(AllTrim(ZF0->ZF0_CODDES),2))+"</Loja>"	
cXml += "<Nome>"+_NoTags(AllTrim(ZF0->ZF0_NOMDES))+"</Nome>"
cXml += "<CNPJ>"+_NoTags(AllTrim(ZF0->ZF0_CNPJDE))+"</CNPJ>"
cXml += "<Endereco>"+_NoTags(AllTrim(ZF0->ZF0_ENDDES))+"</Endereco>"
cXml += "<CEP>"+_NoTags(AllTrim(ZF0->ZF0_CEPDES))+"</CEP>"
cXml += "<Estado>"+_NoTags(AllTrim(ZF0->ZF0_ESTDES))+"</Estado>"
cXml += "<Cidade>"+_NoTags(AllTrim(ZF0->ZF0_CIDDES))+"</Cidade>"		
cXml += "<Bairro>"+_NoTags(AllTrim(ZF0->ZF0_BAIDES))+"</Bairro>"
cXml += "<IE>"+_NoTags(AllTrim(ZF0->ZF0_IEDEST))+"</IE>"
cXml += "<EMail>"+_NoTags(AllTrim(ZF0->ZF0_MAILDE))+"</EMail>"

If cTipo == "S"
	cXml += "<NIF>"+_NoTags(AllTrim(ZF0->ZF0_NIF))+"</NIF>"
EndIf

cXml += "</Destinatario>"

//Local de Cobrança
If !Empty(ZF0->ZF0_NOMCOB)

	cXml += "<LocalCobranca>"

		cXml += "<Nome>"+_NoTags(AllTrim(ZF0->ZF0_NOMCOB))+"</Nome>"
		cXml += "<Endereco>"+_NoTags(AllTrim(ZF0->ZF0_ENDCOB))+"</Endereco>"
		cXml += "<CEP>"+_NoTags(AllTrim(ZF0->ZF0_CEPCOB))+"</CEP>"
		cXml += "<Estado>"+_NoTags(AllTrim(ZF0->ZF0_ESTCOB))+"</Estado>"
		cXml += "<Cidade>"+_NoTags(AllTrim(ZF0->ZF0_CIDCOB))+"</Cidade>"		
		cXml += "<Bairro>"+_NoTags(AllTrim(ZF0->ZF0_BAICOB))+"</Bairro>"

	cXml += "</LocalCobranca>"

EndIf

//Local de Entrega
cXml += "<LocalEntrega>"

	cXml += "<Nome>"+_NoTags(AllTrim(ZF0->ZF0_NOMENT))+"</Nome>"
	cXml += "<CNPJ>"+_NoTags(AllTrim(ZF0->ZF0_CNPJEN))+"</CNPJ>"
	cXml += "<Endereco>"+_NoTags(AllTrim(ZF0->ZF0_ENDENT))+"</Endereco>"
	cXml += "<CEP>"+_NoTags(AllTrim(ZF0->ZF0_CEPENT))+"</CEP>"
	cXml += "<Estado>"+_NoTags(AllTrim(ZF0->ZF0_ESTENT))+"</Estado>"
	cXml += "<Cidade>"+_NoTags(AllTrim(ZF0->ZF0_CIDENT))+"</Cidade>"		
	cXml += "<Bairro>"+_NoTags(AllTrim(ZF0->ZF0_BAIENT))+"</Bairro>"
	cXml += "<IE>"+_NoTags(AllTrim(ZF0->ZF0_IEENTR))+"</IE>"

cXml += "</LocalEntrega>"

//Local de Saída
If cTipo == "M"
	If !Empty(ZF0->ZF0_NOMSAI)
		cXml += "<LocalDeSaida>"+_NoTags(AllTrim(ZF0->ZF0_NOMSAI))+"</LocalDeSaida>"
	EndIf

	If !Empty(ZF0->ZF0_CNPJSA)
		cXml += "<CNPJDeSaida>"+_NoTags(AllTrim(ZF0->ZF0_CNPJSA))+"</CNPJDeSaida>"
	EndIf
EndIf

//Transportadora
If cTipo == "M"
	
	If ZF0->ZF0_INCTRA == "S"
		cXml += "<NovaTransportadora>true</NovaTransportadora>"
	Else
		cXml += "<NovaTransportadora>false</NovaTransportadora>"	
	EndIf

	cXml += "<Transportadora>"

		cXml += "<Codigo>"+_NoTags(Left(AllTrim(ZF0->ZF0_CODTRA),6))+"</Codigo>"
		cXml += "<Nome>"+_NoTags(AllTrim(ZF0->ZF0_NOMTRA))+"</Nome>"
		cXml += "<CNPJ>"+_NoTags(AllTrim(ZF0->ZF0_CNPJTA))+"</CNPJ>"
		cXml += "<Endereco>"+_NoTags(AllTrim(ZF0->ZF0_ENDTRA))+"</Endereco>"
		cXml += "<CEP>"+_NoTags(AllTrim(ZF0->ZF0_CEPTRA))+"</CEP>"
		cXml += "<Estado>"+_NoTags(AllTrim(ZF0->ZF0_ESTTRA))+"</Estado>"
		cXml += "<Cidade>"+_NoTags(AllTrim(ZF0->ZF0_CIDTRA))+"</Cidade>"		
		cXml += "<Bairro>"+_NoTags(AllTrim(ZF0->ZF0_BAITRA))+"</Bairro>"
		cXml += "<IE>"+_NoTags(AllTrim(ZF0->ZF0_IETRAN))+"</IE>"
		
		If !Empty(ZF0->ZF0_COLETA)
			cXml += "<NumeroDeColeta>"+_NoTags(AllTrim(ZF0->ZF0_COLETA))+"</NumeroDeColeta>"
		EndIf
	
		If ZF0->ZF0_FRETE == "E"
			cXml += "<TipoDeFrete>Emitente</TipoDeFrete>"
		ElseIf ZF0->ZF0_FRETE == "D"
			cXml += "<TipoDeFrete>Destinatario</TipoDeFrete>"
		EndIf

		If !Empty(ZF0->ZF0_ESPECI)
			cXml += "<Especie>"+_NoTags(AllTrim(ZF0->ZF0_ESPECI))+"</Especie>"
		EndIf

		If !Empty(ZF0->ZF0_QTDESP)
			cXml += "<QuantidadeEspecie>"+_NoTags(AllTrim(Str(ZF0->ZF0_QTDESP)))+"</QuantidadeEspecie>"
		EndIf

		If !Empty(ZF0->ZF0_PESLIQ)
			cXml += "<PesoLiquido>"+_NoTags(AllTrim(Str(ZF0->ZF0_PESLIQ)))+"</PesoLiquido>"
		EndIf
	
		If !Empty(ZF0->ZF0_PESBRU)
			cXml += "<PesoBruto>"+_NoTags(AllTrim(Str(ZF0->ZF0_PESBRU)))+"</PesoBruto>"
		EndIf
		
	cXml += "</Transportadora>"
EndIf

//Dados Adicinais
If !Empty(ZF0->ZF0_INFADI)
	cXml += "<DadosAdicionais>"+_NoTags(AllTrim(ZF0->ZF0_INFADI))+"</DadosAdicionais>"
EndIf

cXml += "<Produtos>"

//Itens da solicitação
ZF1->(DbSetOrder(1))
If ZF1->(DbSeek(xFilial("ZF1")+cEmp+cFil+cCodigo))
	While ZF1->(!EOF()) .and. ZF1->(ZF1_FILIAL+ZF1_CODEMP+ZF1_CODFIL+ZF1_CODIGO) == xFilial("ZF1")+cEmp+cFil+cCodigo

		cXml += "<Produtos>"

		cXml += "<Codigo>"+_NoTags(AllTrim(ZF1->ZF1_CODPRO))+"</Codigo>"
		cXml += "<Descricao>"+_NoTags(AllTrim(ZF1->ZF1_DESPRO))+"</Descricao>"
		cXml += "<UnidadeMedida>"+_NoTags(AllTrim(ZF1->ZF1_UNID))+"</UnidadeMedida>"
   		cXml += "<Quantidade>"+_NoTags(AllTrim(Str(ZF1->ZF1_QTDE)))+"</Quantidade>"
   		cXml += "<PrecoUnit>"+_NoTags(AllTrim(Transform(ZF1->ZF1_PRECO,"@R")))+"</PrecoUnit>"
   		cXml += "<Armazem>"+_NoTags(AllTrim(ZF1->ZF1_LOCAL))+"</Armazem>"

		cXml += "</Produtos>"
				
		ZF1->(DbSkip())
	EndDo		
EndIf

cXml += "</Produtos>"

cXml += "</Faturamento>"

cXml += "</App>"
cXml += "</Entities>"
cXml += "</Case>"
cXml += "</Cases>"
cXml += "</BizAgiWSParam>"

//Chama o WebService do Bizagi
oWs :=  WSWorkflowEngineSOA():New()

//Utiliza o metodo para criar o processo no Bizagi
If !oWs:createCasesAsString(cXml)

	cSvcError   := GetWSCError()		// Resumo do erro
	cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	cSoapFDescr := GetWSCError(3)		// Soap Fault Description

	If !empty(cSoapFCode) 
		// Caso a ocorrência de erro esteja com o fault_code preenchido , 
		// a mesma teve relação com a chamada do serviço . 
		ConOut(cSoapFDescr)
		ConOut(cSoapFCode)
	Else
		// Caso a ocorrência não tenha o soap_code preenchido 
		// Ela está relacionada a uma outra falha , 
		// provavelmente local ou interna.
		ConOut(cSvcError)
		ConOut('FALHA INTERNA DE EXECUCAO DO SERVIÇO')
	Endif
Else
	//Retorno do metodo       
	
	cXmlRet := oWs:CCREATECASESASSTRINGRESULT
EndIf

//Tratamento do retono da integração com o Bizagi
If !Empty(cXmlRet)
	cXmlRet := EncodeUTF8(cXmlRet)
	oXmlRet := XmlParser( cXmlRet, "_", @cError, @cWarning)
    
	//Retorna o numero do processo
	cProcId := oXmlRet:_PROCESSES:_PROCESS:_PROCESSRADNUMBER:TEXT
    
	//Grava o numero do processo
	If !Empty(cProcId) .and. Alltrim(cProcId) <> '0'
		ZF0->(RecLock("ZF0",.F.))
		ZF0->ZF0_NUMPRO := cProcId	
		ZF0->(MsUnlock())
	EndIf
EndIf

Return .T.