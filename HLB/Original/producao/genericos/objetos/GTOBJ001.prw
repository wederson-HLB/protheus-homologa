#include 'totvs.ch'
#include 'ap5mail.ch'

/*
Classe      : Logimaster
Descrição   : Objeto de integração com a Logimaster.
*/
*---------------*
Class Logimaster
*---------------*
Data cTipoArq
Data cTipoNf
Data cNomeArq
Data cFolder
Data cFtp
Data cUsrFtp
Data cSenFtp
Data cArquivo
Data cMailFrom
Data cMailTo
Data cMailCc
Data cMailBody
Data cVerPed

Method New() CONSTRUCTOR
Method GeraArq()
Method GeraCapaNf()
Method GeraItemNf()
Method GeraProd()
Method GeraTxt()
Method SendMail()
Method SetMailFrom()
Method SetMailTo()
Method SetMailCc()
Method SetMailBody()

EndClass

*----------------------------*
Method New() Class Logimaster
*----------------------------*
::cTipoArq  := ""
::cTipoNf   := ""
::cFolder   := "\ftp\G6\"
::cFtp      := "200.148.204.118"
::cUsrFtp   := "HLB"
::cSenFtp   := "gran154*"
::cNomeArq  := ""
::cArquivo  := ""
::cMailFrom := "integracao@chemtool.com.br"
::cMailTo   := "cpo@logimasters.com.br"
::cMailCc   := "ssmith@chemtool.com"
::cMailBody := ""
::cVerPed   := ""

Return Self

*-------------------------------------------*
Method GeraArq(cTipo,cOper) Class Logimaster
*-------------------------------------------*
Local lRet  := .T.
Local lConn := .F.

Local cTexto    := ""
Local cMailBody := ""

Local nHandle := 0

Default cTipo := ""

::cTipoArq  := cTipo
::cTipoNF   := cOper

If Empty(::cTipoArq) .or. !( AllTrim(::cTipoArq) $ "NF|PROD")
	MsgInfo("Parametros incorretos para o método GeraArq().","Atenção")
	Return .F.
EndIf

If AllTrim(::cTipoArq) == "NF"
	If Empty(::cTipoNF) .or. !( AllTrim(::cTipoNF) $ "S|E")
		MsgInfo("Parametros incorretos para o método GeraArq().","Atenção")
		Return .F.
	EndIf
EndIf

//Define o nome do arquivo.
If AllTrim(::cTipoArq) == "NF"
	If ::cTipoNF == "S"
		::cVerPed  := SomaVer(MaxVer(SC5->C5_NUM))
		::cNomeArq := "NFS"+StrZero(Day(dDataBase),2)+StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),8,2)+".txt"
	ElseIf ::cTipoNF == "E"
		::cNomeArq := "NFE"+StrZero(Day(dDataBase),2)+StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),8,2)+".txt"
	EndIf

ElseIf AllTrim(::cTipoArq) == "PROD"
	::cNomeArq := "PLE"+StrZero(Day(dDataBase),2)+StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),8,2)+".txt"
EndIf

::cArquivo := ::cFolder+::cNomeArq

//Cria o arquivo
nHandle := FCreate(::cArquivo)

If nHandle < 0 
	MsgInfo("Erro ao criar arquivo - fError: " + AllTrim(Str(Ferror())),"Atenção")
	Return .F.
EndIf

//Gera o arquivo txt
If  AllTrim(::cTipoArq) == "NF"
	cTexto := Self:GeraCapaNf()
	cTexto += Self:GeraItemNf()
ElseIf AllTrim(::cTipoArq) == "PROD"
	cTexto := Self:GeraProd()
EndIf

//Grava o arquivo
FWrite(nHandle,cTexto)
                                                       	
//Fecha o arquivo
FClose(nHandle)

//Conecta no ftp
lConn := FtpConnect(::cFtp,21,::cUsrFtp,::cSenFtp)

If !lConn
	MsgInfo("Não foi possivel se comunicar com o ftp.","Atenção")
	Return .F.
EndIf

//Grava o arquivo no ftp
If !FtpUpload(::cArquivo,::cNomeArq)
	MsgInfo("Não foi possivel gravar o arquivo no ftp.","Atenção")		
	Return .F.
EndIf

//Desconecta
FtpDisconnect()

//Envia o e-mail de confirmação.
cMailBody := "O arquivo " + AllTrim(::cNomeArq) + "  de integração da Chemtool foi gerado e disponibilizado na pasta FTP."
Self:SetMailBody(cMailBody)
Self:SendMail()

Return lRet

*-----------------------------------*
Method GeraCapaNf() Class Logimaster 
*-----------------------------------*
Local lTransp := .F.

Local cTexto  := ""
Local cSeqSC9 := "" 

Local nTotal := 0
Local nSaldo := 0

Local aLayout := {}

If AllTrim(::cTipoNF) == "E" //Notas de Entrada
   
	//Posiciona no Fornecedor
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))

	//Posiciona na Transportadora
	lTransp := !Empty(SF1->F1_TRANSP)
    If lTransp
		SA4->(DbSetOrder(1))
		SA4->(DbSeek(xFilial("SA4")+SF1->F1_TRANSP))
    EndIf

	//Define o Layout
	             //Seq  Conteudo                          Tipo   Tam
	aAdd(aLayout,{ 01 ,"01"                              , "C" , 02 }) //TIPO REGISTRO
	aAdd(aLayout,{ 02 ,"CHEMTOOL"                        , "C" , 15 }) //CODIGO DEPOSITANTE
	aAdd(aLayout,{ 03 ,SA2->A2_CGC                       , "C" , 15 }) //CODIGO EMPRESA
	aAdd(aLayout,{ 04 ,SA2->A2_CGC                       , "C" , 15 }) //CGC EMPRESA
	aAdd(aLayout,{ 05 ,SA2->A2_NOME                      , "C" , 40 }) //NOME EMPRESA
	aAdd(aLayout,{ 06 ,SA2->A2_END                       , "C" , 40 }) //ENDERECO EMPRESA
	aAdd(aLayout,{ 07 ,SA2->A2_BAIRRO                    , "C" , 25 }) //BAIRRO EMPRESA
	aAdd(aLayout,{ 08 ,SA2->A2_MUN                       , "C" , 25 }) //MUNICIPIO EMPRESA
	aAdd(aLayout,{ 09 ,SA2->A2_EST                       , "C" , 02 }) //UF EMPRESA
	aAdd(aLayout,{ 10 ,SA2->A2_CEP                       , "C" , 09 }) //CEP EMPRESA
	aAdd(aLayout,{ 11 ,SA2->A2_INSCR                     , "C" , 15 }) //INCRICAO EMPRESA
	aAdd(aLayout,{ 12 ,SF1->F1_ESPECIE                   , "C" , 05 }) //TIPO DOCUMENTO
	aAdd(aLayout,{ 13 ,SF1->F1_SERIE                     , "C" , 05 }) //SERIE DOCUMENTO
	aAdd(aLayout,{ 14 ,SF1->F1_DOC                       , "C" , 10 }) //NUMERO DOCUMENTO
	aAdd(aLayout,{ 15 ,"CHEMTOOL"                        , "C" , 15 }) //CODIGO MATRIZ
	aAdd(aLayout,{ 16 ,                                  , "N" , 10 }) //CODIGO ESTABELECIMENTO
	aAdd(aLayout,{ 17 ,""                                , "C" , 06 }) //NATUREZA OPERACAO
	aAdd(aLayout,{ 18 ,""                                , "C" , 10 }) //CONHECIMENTO TRANSPORTE
	aAdd(aLayout,{ 19 ,SF1->F1_EMISSAO                   , "D" , 08 }) //DATA EMISSAO
	aAdd(aLayout,{ 20 ,SF1->F1_VALBRUT                   , "N" , 20 }) //VALOR TOTAL DOCUMENTO
	aAdd(aLayout,{ 21 ,SF1->F1_VALMERC                   , "N" , 20 }) //VALOR TOTAL PRODUTO
	aAdd(aLayout,{ 22 ,SF1->F1_VALICM                    , "N" , 20 }) //VALOR ICMS
	aAdd(aLayout,{ 23 ,SF1->F1_ICMSRET                   , "N" , 20 }) //VALOR ICMS SUB
	aAdd(aLayout,{ 24 ,SF1->F1_VALIPI                    , "N" , 20 }) //VALOR IPI
	aAdd(aLayout,{ 25 ,SF1->F1_FRETE                     , "N" , 20 }) //VALOR FRETE
	aAdd(aLayout,{ 26 ,SF1->F1_BASEICM                   , "N" , 20 }) //BASE ICMS
	aAdd(aLayout,{ 27 ,SF1->F1_BRICMS                    , "N" , 20 }) //BASE ICMS SUB
	aAdd(aLayout,{ 28 ,SF1->F1_BASEIPI                   , "N" , 20 }) //BASE IPI
	aAdd(aLayout,{ 29 ,SF1->F1_SEGURO                    , "N" , 20 }) //VALOR SEGURO
	aAdd(aLayout,{ 30 ,SF1->F1_DESCONT                   , "N" , 20 }) //VALOR DESCONTO
	aAdd(aLayout,{ 31 ,                                  , "N" , 20 }) //VALOR ACRESCIMO
	
	If lTransp
		aAdd(aLayout,{ 32 , SA4->A4_CGC                  , "C" , 15 }) //CODIGO TRANSPORTADORA
	Else
		aAdd(aLayout,{ 32 , ""                           , "C" , 15 }) //CODIGO TRANSPORTADORA
	EndIf
	
	aAdd(aLayout,{ 33 , ""                               , "C" , 25 }) //INFORMACAO ADICIONAL 1
	aAdd(aLayout,{ 34 , ""                               , "C" , 25 }) //INFORMACAO ADICIONAL 2
	aAdd(aLayout,{ 35 , ""                               , "C" , 25 }) //INFORMACAO ADICIONAL 3
	aAdd(aLayout,{ 36 ,SA2->A2_CGC                       , "C" , 15 }) //CODIGO EMPRESA ENTREGA
	aAdd(aLayout,{ 37 , ""                               , "C" , 15 }) //CODIGO EMPRESA FATURAMENTO
	aAdd(aLayout,{ 38 , ""                               , "C" , 15 }) //CODIGO EMPRESA DESTINO
	aAdd(aLayout,{ 39 , ""                               , "C" , 15 }) //CODIGO EMPRESA EMITENTE
	aAdd(aLayout,{ 40 , dDataBase                        , "D" , 08 }) //DATA MOVIMENTO
	aAdd(aLayout,{ 41 ,SF1->F1_PBRUTO                    , "N" , 20 }) //PESO BRUTO
	aAdd(aLayout,{ 42 ,SF1->F1_PLIQUI                    , "N" , 20 }) //PESO LIQUIDO
	aAdd(aLayout,{ 43 , ""                               , "C" , 06 }) //CFOP
	aAdd(aLayout,{ 44 , ""                               , "C" , 05 }) //ESPECIE DOCUMENTO
	aAdd(aLayout,{ 45 , ""                               , "C" , 10 }) //TIPO EMPRESA
	aAdd(aLayout,{ 46 ,SA2->A2_TIPO                      , "C" , 01 }) //TIPO PESSOA EMPRESA
	aAdd(aLayout,{ 47 , ""                               , "C" , 10 }) //ESTADO DOCUMENTO
	aAdd(aLayout,{ 48 ,SF1->F1_ESPECI1                   , "C" , 40 }) //ESPECIE VOLUME
	aAdd(aLayout,{ 49 ,SF1->F1_VOLUME1                   , "N" , 20 }) //QUANTIDADE VOLUME
	aAdd(aLayout,{ 50 , ""                               , "C" , 10 }) //MARCA VOLUME
	aAdd(aLayout,{ 51 , ""                               , "C" , 10 }) //NUMERO VOLUME
	aAdd(aLayout,{ 52 ,SF1->F1_TPFRETE                   , "N" , 10 }) //TIPO FRETE
	aAdd(aLayout,{ 53 , ""                               , "C" , 07 }) //PLACA VEICULO
	aAdd(aLayout,{ 53 , ""                               , "C" , 02 }) //UF VEICULO

ElseIf AllTrim(::cTipoNF) == "S" //Notas de Saída.

	//Posiciona no Fornecedor
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

	//Posiciona na Transportadora
	lTransp := !Empty(SF2->F2_TRANSP)
    If lTransp
		SA4->(DbSetOrder(1))
		SA4->(DbSeek(xFilial("SA4")+SC5->C5_TRANSP))
    EndIf
    
	//Pesquisa a ultima versão de liberação
	BeginSql Alias 'QRYSC9'
		SELECT MAX(C9_SEQUEN) as SEQUEN
		FROM %table:SC9%
		WHERE %notDel%
		  AND C9_PEDIDO = %exp:SC5->C5_NUM%
	EndSql
	    
	QRYSC9->(DbGoTop())
	cSeqSC9	:= QRYSC9->SEQUEN
	QRYSC9->(DbCloseArea())

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		While SC6->(!EOF()) .and. SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6")+SC5->C5_NUM

			SC9->(DbSetOrder(1))
			If SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)+cSeqSC9))
	
        		SC9->(RecLock("SC9",.F.))
				SC9->C9_VERARQ := ::cVerPed
				SC9->(MsUnlock())

				nTotal += SC9->C9_QTDLIB * SC9->C9_PRCVEN    		
            EndIf
		
			SC6->(DbSkip())
		EndDo
    EndIf

	//Define o Layout
	             //Seq  Conteudo                          Tipo   Tam
	aAdd(aLayout,{ 01 ,"03"                              , "C" , 02 }) //TIPO REGISTRO
	aAdd(aLayout,{ 02 ,"CHEMTOOL"                        , "C" , 15 }) //CODIGO DEPOSITANTE
	aAdd(aLayout,{ 03 ,SA1->A1_CGC                       , "C" , 15 }) //CODIGO EMPRESA
	aAdd(aLayout,{ 04 ,SA1->A1_CGC                       , "C" , 15 }) //CGC EMPRESA
	aAdd(aLayout,{ 05 ,SA1->A1_NOME                      , "C" , 40 }) //NOME EMPRESA
	aAdd(aLayout,{ 06 ,SA1->A1_END                       , "C" , 40 }) //ENDERECO EMPRESA
	aAdd(aLayout,{ 07 ,SA1->A1_BAIRRO                    , "C" , 25 }) //BAIRRO EMPRESA
	aAdd(aLayout,{ 08 ,SA1->A1_MUN                       , "C" , 25 }) //MUNICIPIO EMPRESA
	aAdd(aLayout,{ 09 ,SA1->A1_EST                       , "C" , 02 }) //UF EMPRESA
	aAdd(aLayout,{ 10 ,SA1->A1_CEP                       , "C" , 09 }) //CEP EMPRESA
	aAdd(aLayout,{ 11 ,SA1->A1_INSCR                     , "C" , 15 }) //INCRICAO EMPRESA
	aAdd(aLayout,{ 12 ,"PED"                             , "C" , 05 }) //TIPO DOCUMENTO
	aAdd(aLayout,{ 13 ,"PED"                             , "C" , 05 }) //SERIE DOCUMENTO
	aAdd(aLayout,{ 14 ,SC5->C5_NUM + ::cVerPed           , "C" , 10 }) //NUMERO DOCUMENTO
	aAdd(aLayout,{ 15 ,"CHEMTOOL"                        , "C" , 15 }) //CODIGO MATRIZ
	aAdd(aLayout,{ 16 ,                                  , "N" , 10 }) //CODIGO ESTABELECIMENTO
	aAdd(aLayout,{ 17 ,""                                , "C" , 06 }) //NATUREZA OPERACAO
	aAdd(aLayout,{ 18 ,""                                , "C" , 10 }) //CONHECIMENTO TRANSPORTE
	aAdd(aLayout,{ 19 ,SC5->C5_EMISSAO                   , "D" , 08 }) //DATA EMISSAO
	aAdd(aLayout,{ 20 ,nTotal                            , "N" , 20 }) //VALOR TOTAL DOCUMENTO
	aAdd(aLayout,{ 21 ,nTotal                            , "N" , 20 }) //VALOR TOTAL PRODUTO
	aAdd(aLayout,{ 22 ,                                  , "N" , 20 }) //VALOR ICMS
	aAdd(aLayout,{ 23 ,                                  , "N" , 20 }) //VALOR ICMS SUB
	aAdd(aLayout,{ 24 ,                                  , "N" , 20 }) //VALOR IPI
	aAdd(aLayout,{ 25 ,                                  , "N" , 20 }) //VALOR FRETE
	aAdd(aLayout,{ 26 ,                                  , "N" , 20 }) //BASE ICMS
	aAdd(aLayout,{ 27 ,                                  , "N" , 20 }) //BASE ICMS SUB
	aAdd(aLayout,{ 28 ,                                  , "N" , 20 }) //BASE IPI
	aAdd(aLayout,{ 29 ,                                  , "N" , 20 }) //VALOR SEGURO
	aAdd(aLayout,{ 30 ,                                  , "N" , 20 }) //VALOR DESCONTO
	aAdd(aLayout,{ 31 ,                                  , "N" , 20 }) //VALOR ACRESCIMO
	
	If lTransp
		aAdd(aLayout,{ 32 , SA4->A4_CGC                  , "C" , 15 }) //CODIGO TRANSPORTADORA
	Else
		aAdd(aLayout,{ 32 , ""                           , "C" , 15 }) //CODIGO TRANSPORTADORA
	EndIf
	
	aAdd(aLayout,{ 33 , ""                               , "C" , 25 }) //INFORMACAO ADICIONAL 1
	aAdd(aLayout,{ 34 , ""                               , "C" , 25 }) //INFORMACAO ADICIONAL 2
	aAdd(aLayout,{ 35 , ""                               , "C" , 25 }) //INFORMACAO ADICIONAL 3
	aAdd(aLayout,{ 36 ,SA1->A1_CGC                       , "C" , 15 }) //CODIGO EMPRESA ENTREGA
	aAdd(aLayout,{ 37 , ""                               , "C" , 15 }) //CODIGO EMPRESA FATURAMENTO
	aAdd(aLayout,{ 38 , ""                               , "C" , 15 }) //CODIGO EMPRESA DESTINO
	aAdd(aLayout,{ 39 , ""                               , "C" , 15 }) //CODIGO EMPRESA EMITENTE
	aAdd(aLayout,{ 40 ,dDataBase                         , "D" , 08 }) //DATA MOVIMENTO
	aAdd(aLayout,{ 41 ,SC5->C5_PBRUTO                    , "N" , 20 }) //PESO BRUTO
	aAdd(aLayout,{ 42 ,SC5->C5_PESOL                     , "N" , 20 }) //PESO LIQUIDO
	aAdd(aLayout,{ 43 , ""                               , "C" , 06 }) //CFOP
	aAdd(aLayout,{ 44 , ""                               , "C" , 05 }) //ESPECIE DOCUMENTO
	aAdd(aLayout,{ 45 , ""                               , "C" , 10 }) //TIPO EMPRESA
	aAdd(aLayout,{ 46 ,SA1->A1_TIPO                      , "C" , 01 }) //TIPO PESSOA EMPRESA
	aAdd(aLayout,{ 47 , ""                               , "C" , 10 }) //ESTADO DOCUMENTO
	aAdd(aLayout,{ 48 , ""                               , "C" , 40 }) //ESPECIE VOLUME
	aAdd(aLayout,{ 49 ,                                  , "N" , 20 }) //QUANTIDADE VOLUME
	aAdd(aLayout,{ 50 , ""                               , "C" , 10 }) //MARCA VOLUME
	aAdd(aLayout,{ 51 , ""                               , "C" , 10 }) //NUMERO VOLUME
	aAdd(aLayout,{ 52 ,                                  , "N" , 10 }) //TIPO FRETE
	aAdd(aLayout,{ 53 , ""                               , "C" , 07 }) //PLACA VEICULO
	aAdd(aLayout,{ 53 , ""                               , "C" , 02 }) //UF VEICULO

EndIf
	
//Gera o Arquivo
cTexto := Self:GeraTxt(aLayout)

Return cTexto

*-----------------------------------*
Method GeraItemNf() Class Logimaster 
*-----------------------------------*
Local cTexto  := ""
Local cVersao := ""

Local nSaldo := 0

Local aLayout := {}

If AllTrim(::cTipoNF) == "E" //Nf de Entrada

	//Posiciona no Fornecedor
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))

	//Posiciona nos itens da nota.
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		While SD1->(!EOF() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
            
			aLayout := {}
			
			//Posiciona a TES
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
		
			//Define o Layout
	    	//            Seq  Conteudo                           Tipo  Tam
			aAdd(aLayout,{ 01 ,"02"                             , "C" , 02 }) //TIPO REGISTRO
			aAdd(aLayout,{ 02 ,SA2->A2_CGC                      , "C" , 15 }) //CODIGO EMPRESA
			aAdd(aLayout,{ 03 ,SF1->F1_ESPECIE                  , "C" , 05 }) //TIPO DOCUMENTO
			aAdd(aLayout,{ 04 ,SF1->F1_SERIE                    , "C" , 05 }) //SERIE DOCUMENTO
			aAdd(aLayout,{ 05 ,SF1->F1_DOC                      , "C" , 10 }) //NUMERO DOCUMENTO
			aAdd(aLayout,{ 06 ,"CHEMTOLL"                       , "C" , 15 }) //CODIGO DEPOSITANTE
			aAdd(aLayout,{ 07 ,SD1->D1_COD                      , "C" , 25 }) //CODIGO PRODUTO
			aAdd(aLayout,{ 08 ,SD1->D1_QUANT                    , "N" , 20 }) //QUANTIDADE
			aAdd(aLayout,{ 09 ,SD1->D1_UM                       , "C" , 05 }) //TIPO UC
			aAdd(aLayout,{ 10 ,""                               , "N" , 20 }) //FATOR TIPO UC
			aAdd(aLayout,{ 11 ,SD1->D1_PICM                     , "N" , 20 }) //ALIQUOTA ICMS
			aAdd(aLayout,{ 12 ,SD1->D1_IPI                      , "N" , 20 }) //ALIQUOTA IPI
			aAdd(aLayout,{ 13 ,SD1->D1_VUNIT                    , "N" , 20 }) //VALOR UNITARIO
			aAdd(aLayout,{ 14 ,SD1->D1_ALIQSOL                  , "N" , 20 }) //ALIQUOTA ICMS SUB
			aAdd(aLayout,{ 15 ,""                               , "N" , 10 }) //TIPO LOGISTICO
			aAdd(aLayout,{ 16 ,""                               , "C" , 15 }) //DADO LOGISTICO
			aAdd(aLayout,{ 17 ,""                               , "C" , 05 }) //CLASSE PRODUTO
			aAdd(aLayout,{ 18 ,SD1->D1_ITEM                     , "N" , 03 }) //SEQUENCIA ITEM
			aAdd(aLayout,{ 19 ,""                               , "C" , 25 }) //INFORMACAO ADICIONAL 1
			aAdd(aLayout,{ 20 ,""                               , "C" , 25 }) //INFORMACAO ADICIONAL 2
			aAdd(aLayout,{ 21 ,""                               , "C" , 25 }) //INFORMACAO ADICIONAL 3
			aAdd(aLayout,{ 22 ,""                               , "C" , 06 }) //NATUREZA OPERACAO
			aAdd(aLayout,{ 23 ,SF4->F4_CF                       , "C" , 06 }) //CFOP
			aAdd(aLayout,{ 24 ,SD1->D1_CLASFIS                  , "C" , 10 }) //CLASSIFICACAO FISCAL
			aAdd(aLayout,{ 25 ,""                               , "N" , 10 }) //SITUACAO TRIBUTARIA
			aAdd(aLayout,{ 26 ,SD1->D1_VALDESC                  , "N" , 20 }) //VALOR DESCONTO
			aAdd(aLayout,{ 27 ,""                               , "N" , 20 }) //VALOR ACRESCIMO
			aAdd(aLayout,{ 28 ,""                               , "C" , 15 }) //ID TIPO UC
			aAdd(aLayout,{ 29 ,""                               , "C" , 25 }) //ID PRODUTO

			//Gera o Arquivo
			cTexto += Self:GeraTxt(aLayout)

            SD1->(DbSkip())
						
		EndDo
    EndIf

ElseIf AllTrim(::cTipoNF) == "S" //Nf de Saida

	//Posiciona no Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

	//Pesquisa a ultima versão de liberação
	BeginSql Alias 'QRYSC9'
		SELECT MAX(C9_SEQUEN) as SEQUEN
		FROM %table:SC9%
		WHERE %notDel%
		  AND C9_PEDIDO = %exp:SC5->C5_NUM%
	EndSql
	    
	QRYSC9->(DbGoTop())
	cSeqSC9	:= QRYSC9->SEQUEN
	QRYSC9->(DbCloseArea())

	SC9->(DbSetOrder(1))
    SC9->(DbSeek(xFilial("SC5")+SC5->C5_NUM))	
	While SC9->(!EOF()) .and. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC5")+SC5->C5_NUM

		//Imprime apenas a liberação atual.	    
	    If AllTrim(cSeqSC9) <> AllTrim(SC9->C9_SEQUEN)
        	SC9->(DbSkip())
        	Loop
		EndIf		

        SC6->(DbSetOrder(1))
        SC6->(DbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM)))
	
		//Define o Layout
    	//            Seq  Conteudo                           Tipo  Tam
		aAdd(aLayout,{ 01 ,"04"                             , "C" , 02 }) //TIPO REGISTRO
		aAdd(aLayout,{ 02 ,SA1->A1_CGC                      , "C" , 15 }) //CODIGO EMPRESA
		aAdd(aLayout,{ 03 ,"PED"                            , "C" , 05 }) //TIPO DOCUMENTO
		aAdd(aLayout,{ 04 ,"PED"                            , "C" , 05 }) //SERIE DOCUMENTO
		aAdd(aLayout,{ 05 ,SC5->C5_NUM + ::cVerPed          , "C" , 10 }) //NUMERO DOCUMENTO
		aAdd(aLayout,{ 06 ,"CHEMTOLL"                       , "C" , 15 }) //CODIGO DEPOSITANTE
		aAdd(aLayout,{ 07 ,SC6->C6_PRODUTO                  , "C" , 25 }) //CODIGO PRODUTO
		aAdd(aLayout,{ 08 ,SC9->C9_QTDLIB                   , "N" , 20 }) //QUANTIDADE
		aAdd(aLayout,{ 09 ,SC6->C6_UM                       , "C" , 05 }) //TIPO UC
		aAdd(aLayout,{ 10 ,""                               , "N" , 20 }) //FATOR TIPO UC
		aAdd(aLayout,{ 11 ,                                 , "N" , 20 }) //ALIQUOTA ICMS
		aAdd(aLayout,{ 12 ,                                 , "N" , 20 }) //ALIQUOTA IPI
		aAdd(aLayout,{ 13 ,SC6->C6_PRCVEN                   , "N" , 20 }) //VALOR UNITARIO
		aAdd(aLayout,{ 14 ,                                 , "N" , 20 }) //ALIQUOTA ICMS SUB
		aAdd(aLayout,{ 15 ,""                               , "N" , 10 }) //TIPO LOGISTICO
		aAdd(aLayout,{ 16 ,""                               , "C" , 15 }) //DADO LOGISTICO
		aAdd(aLayout,{ 17 ,""                               , "C" , 05 }) //CLASSE PRODUTO
		aAdd(aLayout,{ 18 ,SC6->C6_ITEM                     , "C" , 03 }) //SEQUENCIA ITEM
		aAdd(aLayout,{ 19 ,""                               , "C" , 25 }) //INFORMACAO ADICIONAL 1
		aAdd(aLayout,{ 20 ,""                               , "C" , 25 }) //INFORMACAO ADICIONAL 2
		aAdd(aLayout,{ 21 ,""                               , "C" , 25 }) //INFORMACAO ADICIONAL 3
		aAdd(aLayout,{ 22 ,""                               , "C" , 06 }) //NATUREZA OPERACAO
		aAdd(aLayout,{ 23 ,SC6->C6_CF                       , "C" , 06 }) //CFOP
		aAdd(aLayout,{ 24 ,SC6->C6_CLASFIS                  , "C" , 10 }) //CLASSIFICACAO FISCAL
		aAdd(aLayout,{ 25 ,                                 , "N" , 10 }) //SITUACAO TRIBUTARIA
		aAdd(aLayout,{ 26 ,                                 , "N" , 20 }) //VALOR DESCONTO
		aAdd(aLayout,{ 27 ,                                 , "N" , 20 }) //VALOR ACRESCIMO
		aAdd(aLayout,{ 28 ,""                               , "C" , 15 }) //ID TIPO UC
		aAdd(aLayout,{ 29 ,""                               , "C" , 25 }) //ID PRODUTO

		//Gera o Arquivo
		cTexto += Self:GeraTxt(aLayout)

		SC9->(DbSkip())
	EndDo

EndIf
			
Return cTexto

*---------------------------------*
Method GeraProd() Class Logimaster 
*---------------------------------*
Local lCompl := .F.

Local cTexto := ""
Local cLinha := ""

Local aLayout := {}

SB1->(DbSetOrder(1))
SB1->(DbGoTop())
While SB1->(!EOF())
    
	aLayout := {}

	SB5->(DbSetOrder(1))
	lCompl := SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))	
		
	//Define o Layout
	//            Seq  Conteudo                           Tipo  Tam
	aAdd(aLayout,{ 01 ,"06"                              , "C" , 02 })
	aAdd(aLayout,{ 02 ,"CHEMTOOL"                        , "C" , 15 })
	aAdd(aLayout,{ 03 ,SB1->B1_COD                       , "C" , 25 })
	aAdd(aLayout,{ 04 ,SB1->B1_DESC                      , "C" , 40 })
	aAdd(aLayout,{ 05 ,""                                , "C" , 40 })		
	aAdd(aLayout,{ 06 ,""                                , "C" , 15 })
	aAdd(aLayout,{ 07 ,""                                , "C" , 06 })
	aAdd(aLayout,{ 08 ,SB1->B1_CLASFIS                   , "C" , 10 })

	If lCompl
		aAdd(aLayout,{ 09 ,SB5->B5_LARGLC                    , "N" , 20 })
		aAdd(aLayout,{ 10 ,SB5->B5_COMPRLC                   , "N" , 20 })
		aAdd(aLayout,{ 11 ,SB5->B5_ALTURLC                   , "N" , 20 })
	Else
		aAdd(aLayout,{ 09 ,                                  , "N" , 20 })
		aAdd(aLayout,{ 10 ,                                  , "N" , 20 })
		aAdd(aLayout,{ 11 ,                                  , "N" , 20 })
	EndIf

	aAdd(aLayout,{ 12 ,SB1->B1_PESO                      , "N" , 20 })
	aAdd(aLayout,{ 13 ,SB1->B1_PESBRU                    , "N" , 20 })
	aAdd(aLayout,{ 14 ,""                                , "C" , 100})
	aAdd(aLayout,{ 15 ,                                  , "N" , 10 })	
	aAdd(aLayout,{ 16 ,SB1->B1_UM                        , "C" , 05 })
	aAdd(aLayout,{ 17 ,SB1->B1_CONV                      , "N" , 20 })
	aAdd(aLayout,{ 18 ,""                                , "C" , 25 })
	aAdd(aLayout,{ 19 ,""                                , "C" , 15 })
	aAdd(aLayout,{ 20 ,""                                , "C" , 25 })
	aAdd(aLayout,{ 21 ,""                                , "C" , 25 })
	aAdd(aLayout,{ 22 ,""                                , "C" , 25 })
	aAdd(aLayout,{ 23 ,""                                , "C" , 25 })
	aAdd(aLayout,{ 24 ,""                                , "C" , 25 })

	If lCompl
		aAdd(aLayout,{ 25 ,SB5->B5_CEME                      , "C" , 80 })
	Else
		aAdd(aLayout,{ 25 ,""                                , "C" , 80 })	
	EndIf

	aAdd(aLayout,{ 26 ,""                                , "C" , 15 })
	aAdd(aLayout,{ 27 ,""                                , "C" , 15 })

	//Gera o Arquivo
	cLinha := Self:GeraTxt(aLayout)
	cTexto += cLinha	
	
	SB1->(DbSkip())

EndDo

Return cTexto

*---------------------------------------*
Method GeraTxt(aLayout) Class Logimaster 
*---------------------------------------*
Local cTexto    := ""
Local cTipo     := ""
Local cConteudo := ""

Local nI        := 0
Local nConteudo := 0
Local nTamanho  := 0

For nI:=1 To Len(aLayout)
	cTipo    := aLayout[nI][3]
	nTamanho := aLayout[nI][4]

	If cTipo == "C"
		
		cConteudo := If(aLayout[nI][2] == Nil ,"" ,AllTrim(aLayout[nI][2]))
		If Len(cConteudo) == nTamanho 	      	      
			cConteudo := cConteudo
		ElseIf Len(cConteudo) < nTamanho 	      	           
			cConteudo := PadR(cConteudo,nTamanho)
		Else 	
			cConteudo := Left(cConteudo,nTamanho)
		EndIf
	
	ElseIf cTipo == "N" 

		nConteudo := If(aLayout[nI][2]== Nil ,"",aLayout[nI][2])
		Do Case
			Case ValType(nConteudo) = "N"
				cConteudo := Str(nConteudo,nTamanho,4)
				cConteudo := StrTran(AllTrim(cConteudo),".","")
			Case ValType(nConteudo) = "D"
				cConteudo := AllTrim(SubStr(DtoS(nConteudo),1,nTamanho))
				cConteudo := StrTran(AllTrim(cConteudo),".","")
			Case ValType(nConteudo) = "C"
				cConteudo := StrZero(Val(nConteudo),nTamanho,4)
				cConteudo := StrTran(AllTrim(cConteudo),".","")
		EndCase 
		cConteudo := PadL(cConteudo,nTamanho,"0")

	ElseIf cTipo == "D" 

		cConteudo := If(aLayout[nI][2] == Nil ,"" ,AllTrim(Dtos(aLayout[nI][2])))
		
		If nTamanho == 8
			cConteudo := Substr(cConteudo,7,2) + Substr(cConteudo,5,2) + Substr(cConteudo,1,4)
		ElseIf nTamanho == 6
			cConteudo := Substr(cConteudo,7,2) + Substr(cConteudo,5,2) + Substr(cConteudo,3,2)
		EndIf
	
	EndIf           

	cTexto += cConteudo
Next

cTexto += Chr(13)+Chr(10)

Return cTexto

*-----------------------------------------*
Method SetMailFrom(cFrom) Class Logimaster
*-----------------------------------------*
::cMailFrom := cFrom

Return Nil

*-------------------------------------*
Method SetMailTo(cTo) Class Logimaster
*-------------------------------------*
::cMailTo := cTo

Return Nil

*------------------------------------*
Method SetMailCc(cCC) Class Logimaster
*------------------------------------*
::cMailCc := cCc

Return Nil

*----------------------------------------*
Method SetMailBody(cBody) Class Logimaster
*----------------------------------------*
::cMailBody := cBody

Return Nil

*--------------------------------*
Method SendMail() Class Logimaster
*--------------------------------*
Local lOk        := .F.
Local lAutentica := GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação

Local cServer   := AllTrim(GetNewPar("MV_RELSERV",""))
Local cAccount  := AllTrim(GetNewPar("MV_RELACNT",""))
Local cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))
Local cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
Local cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
Local cFrom     := ::cMailFrom
Local cTo       := ::cMailTo
Local cCC       := ::cMailCc
Local cSubject  := "Aviso de geracaoo do arquivo Logimaster"
Local cBody     := ::cMailBody

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOk

If !lOk
	MsgInfo("Falha na Conexão com Servidor de E-Mail")
EndIf

If lAutentica
	If !MailAuth(cUserAut,cPassAut)
		MsgInfo("Falha na Autenticacao do Usuario")
		DISCONNECT SMTP SERVER RESULT lOk
	EndIf
EndIf

SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody RESULT lOK

If !lOK 
	MsgInfo("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
EndIf

DISCONNECT SMTP SERVER

If lOk 
	MsgInfo("E-mail enviado com sucesso.")
EndIf

Return Nil

*------------------------------*
Static Function SomaVer(cVerAtu)
*------------------------------*
Local cVersao := "" 

Local nPos := 0

Local aVersoes := {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

If Empty(cVerAtu)
	cVersao := aVersoes[1]
Else
	nPos := aScan(aVersoes,cVerAtu)
	cVersao := aVersoes[nPos+1]
EndIf

Return cVersao

*-----------------------------*
Static Function MaxVer(cPedido)
*-----------------------------*
Local cVersao := "" 

SC9->(DbSetOrder(1))
SC9->(DbSeek(xFilial("SC9")+cPedido))	
While SC9->(!EOF()) .and. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+cPedido
	
	If !Empty(SC9->C9_VERARQ) 
		If SC9->C9_VERARQ > cVersao
			cVersao := SC9->C9_VERARQ
		EndIf
	EndIf

	SC9->(DbSkip())
EndDo

Return cVersao
