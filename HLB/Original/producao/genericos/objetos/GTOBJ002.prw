#include 'totvs.ch'

/*
Classe      : GTIntNfServ
Descricao   : Objeto de integracao de notas fiscais de servico.
              atraves do arquivo gerado pela prefeitura.
Autor       : Eduardo C. Romanini
Alterações  : 	06/03/2015 - Leandro Brito - Desenvolvimento da Integracao de Notas Fiscais de Serviços Prestados  
				06/03/2015 - Leandro Brito - Desenvolvimento Layout Nota Carioca - Serviços Prestados
				18/09/2015 - Leandro Brito - Desenvolvimento Layout Nota Paulista  - Serviços Prestados	 
Data        : 25/05/2013
*/                   
*----------------*
Class GTIntNfServ 
*----------------*
Data cArquivo     //Caminho e nome do arquivo de itegracao
Data cContArq     //Conteudo do arquivo
Data cPrefeitura  //Nome da prefeitura de onde foi gerado o arquivo
Data cTipoArq     //Tipo do arquivo(Txt,CSV ou Txt Retorno)
Data cTipoNf      //Tipo da Nota Fiscal (servicos Tomados ou Prestados)
Data cErro        //Varaiavel com erros encontrados na integracao.

Data aNfPos       //Amarracao do numero e Serie da Nf com a sua posicao no array aNotas
Data aNotas       //Informacaes de capa das Notas Fiscais
Data lContOnline  //Indica se contabiliza OnLine
Data lMostraLan   //Indica se mostra lancamento 
Data cTesDef      //Tes Default
Data cNatDef      //Natureza Default
Data cContaDef    //Conta Default
Data cCondDef     //Cond. Pagto Default
 

Data oWizard	  //Objeto wizard
Data oIntArq      //Objeto com as informacaes do arquivo de integracao

Method New() CONSTRUCTOR
Method Wizard()           //Apresenta o Wizard de integracao
Method LerArquivo()       //Realiza a leitura do arquivo de integracao
Method CarregaNf()        //Carrega as notas fiscais, baseado no arquivo
Method RetPosNf()         //Retorna a posicao da Nf no array aNotas
Method GravaItens()       //Grava os itens de cada nota
Method IntegraNf()        //Realiza a integracao das notas fiscais de servicos tomados

Method LeArqPrest()       // Efetua a leitura do arquivo de servicos prestados
Method LoadNFPS()         // Carrega as notas fiscais de prestacaes de servico, baseado no arquivo
Method IntegraNFPS()      // Realiza a integracao das notas fiscais de servicos prestados

EndClass      

/*
Classe      : GTIntArq
Descricao   : Objeto do arquivo de integracao de notas fiscais de servico.
Autor       : Eduardo C. Romanini
Data        : 06/06/2013
*/ 
*-------------*
Class GTIntArq
*-------------*
Data aCabec  
Data aDetalhes  
Data aRodape 

Method New() CONSTRUCTOR
Method Carrega()

EndClass     

//------------------------------------------------------------------------------------------------//
//                                 Declaracao dos Mutodos                                         //
//------------------------------------------------------------------------------------------------//
/*
Metodo      : New
Classe      : GTIntNfServ
Descricao   : Contrutor da classe
Autor       : Eduardo C. Romanini
Data        : 06/06/2013
*/ 
*-----------------------------*
Method New() Class GTIntNfServ 
*-----------------------------*
::cArquivo    := ""
::cContArq    := ""
::cPrefeitura := ""
::cTipoArq    := ""
::cTipoNf     := "" 
::cErro       := ""

::aNotas      := {}
::aNfPos      := {}
::lContOnline := .F.
::lMostraLan	:= .F.

//Instancia o objeto com os detalhes do arquivo
::oIntArq := GTIntArq():New()

//Chama o Wizard
Self:Wizard()

Return Self

/*
Metodo      : Wizard
Classe      : GTIntNfServ
Descricao   : Cria o Wizard de integracao
Autor       : Eduardo C. Romanini
Data        : 06/06/2013
*/ 
*--------------------------------*
Method Wizard() Class GTIntNfServ 
*--------------------------------*

//Cria o Objeto Wizard 
::oWizard := APWizard():New("Atencao"/*<chTitle>*/,;
							"Assistente de integracao de Notas Fiscais de servico, a partir de arquivo."/*<chMsg>*/, ; 
							"integracao de Notas Fiscais de servico"/*<cTitle>*/, ;
							"Esse assistente ira auxiliu-lo na integracao das notas fiscais de servico, geradas a partir do"+;
							"arquivo de retorno do site da prefeitura da localidade de prestacao do servico."/*<cText>*/,;
							{|| .T.}/*<bNext>*/, ;
							{|| .T.}/*<bFinish>*/,;
							/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

::oWizard:NewPanel(	"Integracao de Notas Fiscais de Servicos"/*<chTitle>*/,;
				 	"Preencha os parametros abaixo."/*<chMsg>*/,;
				 	{||.T.}/*<bBack>*/,;
				 	{|| If(ValidParam(Self),(If(::cTipoNf == 'T' , ::oWizard:nPanel +=  1 , .T. ) ,Self:LerArquivo()),.F.)}/*<bNext>*/,;
				 	{||.T.}/*<bFinish>*/,;
				 	.T./*<.lPanel.>*/,;
				 	{|| TelaParam(Self)}/*<bExecute>*/ )
				 	
::oWizard:NewPanel(	"Integracao de Notas Fiscais de Servicos"/*<chTitle>*/,;
				 	"Preencha os parametros abaixo."/*<chMsg>*/,;
				 	{||.T.}/*<bBack>*/,;
				 	{|| ValidaDados( Self ) }/*<bNext>*/,;
				 	{||.F.}/*<bFinish>*/,;
				 	.T./*<.lPanel.>*/,;
				 	{|| DadosDef(Self) }/*<bExecute>*/ )					 	

::oWizard:NewPanel(	"Integracao de Notas Fiscais de Servicos"/*<chTitle>*/,;
				 	"Selecione as notas que serao integradas."/*<chMsg>*/,;
				 	{|| If(!Empty(::cErro),(If(::cTipoNf == 'T' , ::oWizard:nPanel -=  1 , .T. ),.T.),.F.)}/*<bBack>*/,;
				 	{|| If(!Empty(::cErro),.F.,ValidConfig(Self))}/*<bNext>*/,;
				 	{||.F.}/*<bFinish>*/,;
				 	.T./*<.lPanel.>*/,;
				 	{|| If(!Empty(::cErro),TelaErro(Self),TelaPreInt(Self))}/*<bExecute>*/ )

				 	
::oWizard:NewPanel(	"Integracao de Notas Fiscais de Servicos"/*<chTitle>*/,;
				 	"Realizando a integracao."/*<chMsg>*/,;
				 	{||.F.}/*<bBack>*/,;
				 	{||.F.}/*<bNext>*/,;
				 	{||.T.}/*<bFinish>*/,;
				 	.T./*<.lPanel.>*/,;
				 	{|| TelaIntegra(Self)}/*<bExecute>*/ )
				 	

				 			 	

::oWizard:Activate( .T./*<.lCenter.>*/,;
					{||.T.}/*<bValid>*/, ;
				 	{||.T.}/*<bInit>*/, ;
				 	{||.T.}/*<bWhen>*/ )


Return 

/*
Metodo      : LerArquivo()
Classe      : GTIntNfServ
Descricao   : Realiza a leitura do arquivo de integracao
Autor       : Eduardo C. Romanini
Data        : 06/06/2013
*/
*------------------------------------*
Method LerArquivo() Class GTIntNfServ
*------------------------------------*
Local cLinha   := ""
Local cTipoAnt := ""

Local nH      := 0
Local nTamArq := 0

Local aCabec  := {}
Local aNotas  := {}
Local aRodape := {}


If ( ::cTipoNF == 'P' )
   Self:LeArqPrest()
   Return( .T. )
EndIf   

nH := FT_FUSE(::cArquivo)  

FT_FGOTOP()
While !FT_FEof()

	//Retorna a Linha
	cLinha := FT_FREADLN()
    
	//Grava o conteudo do arquivo
	::cContArq += cLinha

 	//Cabeualho
 	If Left(cLinha,1) == "1"
	        
    	aAdd(aCabec,{	Substr(cLinha,01,01)      ,; //[01] - Tipo do Registro
    				 	Substr(cLinha,02,03)      ,; //[02] - Versuo do Arquivo
    				 	Substr(cLinha,05,08)      ,; //[03] - Incricao Municipal do Contribuinte
    				 	StoD(Substr(cLinha,13,08)),; //[04] - Data Inicial do periodo
    				 	StoD(Substr(cLinha,21,08))}) //[05] - Data Final do periodo
    				 	
  	//Notas Fiscais
 	ElseIf Left(cLinha,1) == "2" .and. Len(cLinha) > 500
   
    	aAdd(aNotas,{	Substr(cLinha,001,01)       ,; //[01] - Tipo do Registro
    					Substr(cLinha,002,08)       ,; //[02] - NF-e
    					StoD(Substr(cLinha,010,08)) ,; //[03] - Data de Emissuo
    					Substr(cLinha,018,06)       ,; //[04] - Hora de Emissuo
    					Substr(cLinha,024,08)       ,; //[05] - Cudigo de Verificacao da NF-e
    					Substr(cLinha,032,05)       ,; //[06] - Tipo do RPS
    					Substr(cLinha,037,05)       ,; //[07] - Serie do RPS
    					Substr(cLinha,042,12)       ,; //[08] - Numero do RPS
    					StoD(Substr(cLinha,054,08)) ,; //[09] - Data de Emissuo do RPS
    					Substr(cLinha,062,08)       ,; //[10] - Inscricao Municipal do Prestador
    					Substr(cLinha,070,01)       ,; //[11] - Tipo de Identificacao do Prestador
    					If(Substr(cLinha,070,01)=="1",Right(Substr(cLinha,071,14),11),Substr(cLinha,071,14)),; //[12] - CNPJ/CPF do Prestador
    					Substr(cLinha,085,75)       ,; //[13] - Razuo Social do Prestador
    					AllTrim(Substr(cLinha,160,03))+" "+AllTrim(Substr(cLinha,163,50))+;
    					", "+AllTrim(Substr(cLinha,213,10))+" "+AllTrim(Substr(cLinha,223,30)),; //[14] - Endereco do Prestador
	   					AllTrim(Substr(cLinha,253,30)),; //[15] - Bairro do Prestador
	   					AllTrim(Substr(cLinha,283,50)),; //[16] - Cidade do Prestador     
						AllTrim(Substr(cLinha,333,02)),; //[17] - Estado do Prestador
	   					AllTrim(Substr(cLinha,335,08)),; //[18] - CEP do Prestador 
	   					AllTrim(Substr(cLinha,343,75)),; //[19] - E-mail do Prestador 
	   					AllTrim(Substr(cLinha,418,01)),; //[20] - Opcao pelo Simples
	   					AllTrim(Substr(cLinha,419,01)),; //[21] - Situacao da Nota Fiscal
	   					StoD(Substr(cLinha,420,08)) ,; //[22] - Data de Cancelamento
						AllTrim(Substr(cLinha,428,12)),; //[23] - Num. da Guia
						StoD(Substr(cLinha,440,08)) ,; //[24] - Data de Quitacao da Guia
						Val(Substr(cLinha,448,13)+"."+Substr(cLinha,461,02)) ,; //[25] - Valor dos servicos
	   					Val(Substr(cLinha,463,13)+"."+Substr(cLinha,476,02)) ,; //[26] - Valor das Deducaes    
	   					Substr(cLinha,478,05)       ,; //[27] - Cudigo do servico
	   					Val(Substr(cLinha,483,02)+"."+Substr(cLinha,476,02)) ,; //[28] - Aliquota de ISS
	   					Val(Substr(cLinha,487,13)+"."+Substr(cLinha,481,02)) ,; //[29] - Valor do ISS
	   					Val(Substr(cLinha,502,13)+"."+Substr(cLinha,515,02)) ,; //[30] - Valor do Crudito
	   					Substr(cLinha,517,01)       ,; //[31] - ISS Retido
						Substr(cLinha,518,01)       ,; //[32] - Tipo de Identificacao do Tomador
						If(Substr(cLinha,518,01)=="1",Right(Substr(cLinha,519,14),11),Substr(cLinha,519,14)),; //[33] - CNPJ/CPF do Tomador
						StrTran(AllTrim(Substr(cLinha,886)),"|",CRLF) }) //[34] - Descricao dos servicos   
    					
	//Rodapu
	ElseIf Left(cLinha,1) == "9"
        
    	aAdd(aRodape,{	Substr(cLinha,01,01)     ,; //[01] - Tipo do Registro
    			 		Val(Substr(cLinha,02,08)),; //[02] - Numero de linhas de detalhe do arquivo
    			   		Val(Substr(cLinha,09,13)+"."+Substr(cLinha,22,02)) ,;//[03] - Valor Total dos servicos
				   		Val(Substr(cLinha,24,13)+"."+Substr(cLinha,37,02)) ,;//[04] - Valor Total das Deducaes
				   		Val(Substr(cLinha,39,13)+"."+Substr(cLinha,52,02)) ,;//[05] - Soma dos Valores de ISS
						Val(Substr(cLinha,54,13)+"."+Substr(cLinha,67,02))}) //[06] - Valor total dos cruditos
	Else
	    
		//Adiciona a continuacao da Descricao dos servicos.
		If Len(aNotas) <> 0 .and. cTipoAnt == "2"
			aNotas[Len(aNotas)][34] += StrTran(AllTrim(cLinha),"|",CRLF)  
		EndIf		
	
	EndIf	   				 	
    
	//Guarda o tipo da linha anterior
	cTipoAnt := Left(cLinha,1)
	
	FT_FSKIP()
EndDo

FT_FUSE()

If Len(aCabec) == 0 .or. Len(aNotas) == 0 .or. Len(aRodape)== 0
	::cErro := "O formato do arquivo selecionado u invalido." + CRLF
ElseIf AllTrim(aNotas[1][33]) <> AllTrim(SM0->M0_CGC)
   ::cErro := "O arquivo Nao possui informacaes dessa empresa." + CRLF
Else
	::cErro := ""
	//Carrega o objeto com as informacaes do arquivo
	::oIntArq:Carrega(aCabec,aNotas,aRodape)
EndIf
	
Return .T.

/*
Metodo      : CarregaNf
Classe      : GTIntNfServ
Descricao   : Carrega as informacaes da NF, baseado na leitura dos arquivos.
Autor       : Eduardo C. Romanini
Alteracao   : 02/03/2015 - Leandro Brito - Desenvolvimento nota de prestacao de servicos
Data        : 11/06/2013
*/ 
*-----------------------------------*
Method CarregaNf() Class GTIntNfServ
*-----------------------------------*
Local lExistFor := .F.

Local cCgdFor  := ""
Local cCodFor  := ""
Local cLojaFor := ""
Local cNFe     := ""
Local cSerie   := ""
Local cEmis    := ""
Local cNaturez := ""

Local nI := 0
         
Local aDetalhes := {}
Local aItens    := {}

/*
** 02/03/2015 - Leandro Brito - Tratamento NFPS
*/
If ( ::cTipoNf == 'P' )
	Self:LoadNFPS()
	Return
EndIf

//Carrega as informacaes do arquivo.
aDetalhes := aClone(::oIntArq:aDetalhes)


For nI:=1 To Len(aDetalhes)

	//Tratamento para retornar o CPF ou CNPJ do Fornecedor
	If aDetalhes[nI][11] == "1" 
		cCgcFor := Right(aDetalhes[nI][12],11)
	ElseIf aDetalhes[nI][11] == "2"
		cCgcFor := Right(aDetalhes[nI][12],14)
    Else
	    cCgcFor := ""
    EndIf

	//Retorna o Cudigo do Fornecedor
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2")+cCgcFor))
    	cCodFor  := SA2->A2_COD
    	cLojaFor := SA2->A2_LOJA
    	cNaturez := SA2->A2_NATUREZ
    	lExistFor := .T.
	Else
		cCodFor  := ""
		cLojaFor := ""
		cNaturez := ""
		lExistFor := .F.
	EndIf                                                      	

    //Carrega o numero da nota com 6 digitos
	cNFe   := Right(AllTrim(aDetalhes[nI][02]),6)

	//Carrega a serie da nota.
	cSerie := ""

	//Carrega a data de emissuo da nota
	cEmis  := DtoS(aDetalhes[nI][03])

	//Verifica se a nota ju estu cadastrada no sistema.
	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf

	BeginSql Alias 'TMP'
		SELECT F1_DOC,F1_SERIE,F1_EMISSAO
		FROM %table:SF1%
		WHERE %notDel%
		  AND F1_FILIAL = %xFilial:SF1%
		  AND F1_DOC = %exp:cNFe%
		  AND F1_SERIE = %exp:cSerie%
		  AND F1_EMISSAO = %exp:cEmis%
		  AND F1_FORNECE = %exp:cCodFor%
		  AND F1_LOJA = %exp:cLojaFor%
	EndSql

	TMP->(DbGoTop())
	
	//Encontrou no sistema
	If TMP->(!EOF())
	
	    //Carrega o array de notas fiscais
		aAdd(::aNotas,{ .T.                  ,; //Indicador de nota ju existente no sistema
					 	.F.                  ,; //Marcacao de integracao da Nota
					 	TMP->F1_DOC          ,; //Numero da Nota Fiscal
					 	TMP->F1_SERIE        ,; //Serie da Nota Fiscal
					 	StoD(TMP->F1_EMISSAO),; //Data da Nota Fiscal
					 	lExistFor            ,; //Indicador de fornecedor ju existente no sistema
					 	cCodFor			     ,; //Cudigo do Fornecedor
					 	cLojaFor			 ,; //Loja do Fornecedor
					 	aDetalhes[nI][34]    ,; //Descricao do servico
					 	""                   ,; //Condicao de Pagamento
					 	cNaturez             ,; //Natureza
					 	aItens               ,; //Itens da Nota
					 	cCgcFor				 }) //Cnpj/CPF
	
	
	    //Carrega o array de amarracao da nota.
    	aAdd(::aNfPos, {TMP->F1_DOC,nI})
	
	//Nao encontrou no sistema	
	Else

	    //Carrega o array de notas fiscais
		aAdd(::aNotas,{ .F.                 ,; //Indicador de nota ju existente no sistema
					 	.F.                 ,; //Marcacao de integracao da Nota
					 	Right(aDetalhes[nI][02],6)	,; //Numero da Nota Fiscal
					 	""	                ,; //Serie da Nota Fiscal
					 	aDetalhes[nI][03]	,; //Data da Nota Fiscal
					 	lExistFor           ,; //Indicador de fornecedor ju existente no sistema
					 	cCodFor	        	,; //Cudigo do Fornecedor
					 	cLojaFor    		,; //Loja do Fornecedor
					 	aDetalhes[nI][34]   ,; //Descricao do servico
					 	""                  ,; //Condicao de Pagamento
					 	cNaturez            ,; //Natureza
					 	aItens              ,; //Itens da Nota
					 	cCgcFor				}) //Cnpj/CPF
   
		    //Carrega o array de amarracao da nota.
    	aAdd(::aNfPos,{Right(aDetalhes[nI][02],6),nI})
	
	EndIf
Next

//Ordena o array pelo numero das notas fiscais
aSort(::aNotas,,,{|x,y| x[1] < y[1]})

//Fecha o alias da tabela temporuria
If Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf        

Return

/*
Metodo      : RetPosNf
Classe      : GTIntNfServ
Descricao   : Retorna a posicao da nota no array aNotas
Autor       : Eduardo C. Romanini
Data        : 13/06/2013
*/ 
*---------------------------------------*
Method RetPosNf(cNota) Class GTIntNfServ
*---------------------------------------*
Local nPos := 0

If Len(::aNotas) > 0 .and. Len(::aNfPos) > 0
	nPos := aScan(::aNfPos,{|a| AllTrim(a[1]) == AllTrim(cNota)})
EndIf

Return nPos

/*
Metodo      : GravaItens
Classe      : GTIntNfServ
Descricao   : Grava os itens das notas fiscais
Autor       : Eduardo C. Romanini
Data        : 13/06/2013
*/
*-----------------------------------------------*
Method GravaItens(nPos,aItens) Class GTIntNfServ
*-----------------------------------------------*
Local lRet := .T.

Local cCodProd := ""
Local cTes     := ""

Local nI     := 0
Local nQtd   := 0
Local nVUnit := 0
Local nTotal := 0

Local aItAux := {}

If Len(aItens) > 0

	For nI:=1 To Len(aItens)
		cCodProd := aItens[nI][1] //Cudigo do Produto
		nQtd     := aItens[nI][2] //Quantidade
		nVUnit   := aItens[nI][3] //Valor Uniturio
		nTotal   := aItens[nI][4] //Valor Total
		cTes     := aItens[nI][5] //Tipo de Entrada
        
        aAdd(aItAux,{cCodProd,nQtd,nVUnit,nTotal,cTes})
	Next

	//Adiciona o item no array aNotas
	::aNotas[nPos][12] := aClone(aItAux)

Else
	::aNotas[nPos][12] := {}
EndIf



Return lRet

/*
Metodo      : IntegraNf
Classe      : GTIntNfServ
Descricao   : Realiza a integracao das notas fiscais.
Autor       : Eduardo C. Romanini
Data        : 13/06/2013
*/
*----------------------------------------*
Method IntegraNf(oMeter) Class GTIntNfServ
*----------------------------------------*
Local lGravou := .F.

Local cLog     := ""
Local cPathLog := AllTrim(GetTempPath())

Local nI     := 0
Local nP     := 0
Local nPosNf := 0

Local aCab     := {}
Local aItens   := {}
Local aDet	   := {}	
Local aForn    := {}
Local aInfoLog := {}

Local oLog

//Atualiza o valor total da regua.
oMeter:SetTotal(Len(::aNotas))

For nI:=1 To Len(::aNotas)
    
	aForn  := {}
    aCab   := {}
    aDet   := {}
	aItens := {}

	oMeter:Set(nI)

	//Verifica se a nota foi marcada para integracao
	If ::aNotas[nI][2]
         
        nPosNf := Self:RetPosNf(::aNotas[nI][3])
        
	    //Verifica se o fornecedor seru incluudo.
		If !::aNotas[nI][6]
			
			aForn := {	{"A2_COD"   ,::aNotas[nI][7]                ,nil},;
						{"A2_LOJA"  ,::aNotas[nI][8]                ,nil},;
            	        {"A2_NOME"  ,::oIntArq:aDetalhes[nPosNf][13],nil},;
                    	{"A2_NREDUZ",::oIntArq:aDetalhes[nPosNf][13],nil},;
                    	{"A2_END"   ,::oIntArq:aDetalhes[nPosNf][14],nil},;
                    	{"A2_EST"   ,::oIntArq:aDetalhes[nPosNf][17],nil},;
                    	{"A2_MUN"   ,::oIntArq:aDetalhes[nPosNf][16],nil},;
                    	{"A2_BAIRRO",::oIntArq:aDetalhes[nPosNf][15],nil},;
                    	{"A2_CEP"   ,::oIntArq:aDetalhes[nPosNf][18],nil},;
		          	 	{"A2_TIPO"  ,If(Len(::oIntArq:aDetalhes[nPosNf][12])<14,"F","J"),nil},;
                    	{"A2_CGC"   ,::oIntArq:aDetalhes[nPosNf][12],nil} }

			//Realiza a integracao
			Begin Transaction
		 		lMsErroAuto := .F.
	            
				//integracao do fornecedor.
		   		MSExecAuto({|x,y| Mata020(x,y)},aForn,3)
	
				If lMsErroAuto
					cLog += MostraErro(cPathLog)
	
		   			DisarmTransaction()
	   		
		   		Else
		   			cLog += "Fornecedor "+ ::aNotas[nI][7] +" - " + ::aNotas[nI][8] + " integrado com sucesso."+CRLF
		   			
		   			lGravou := .T.
		   			
		   			//Adiciona o detalhe do log.
		   			aAdd(aInfoLog,{"SA2",1,xFilial("SA2")+::aNotas[nI][7]+::aNotas[nI][8],"I"})
		   			
	   			EndIf             	
            End Transaction        	
                    	
        EndIf

		aCab := {{"F1_DOC"    ,Right(::aNotas[nI][03],6),Nil,Nil},;	
				 {"F1_SERIE"  ,::aNotas[nI][04],Nil,Nil},;
				 {"F1_EMISSAO",::aNotas[nI][05],Nil,Nil},;
				 {"F1_FORNECE",::aNotas[nI][07],Nil,Nil},;
				 {"F1_LOJA"   ,::aNotas[nI][08],Nil,Nil},;
				 {"F1_TIPO"   ,"N"             ,Nil,Nil},;
				 {"F1_FORMUL" ,"N"             ,Nil,Nil},;
 				 {"F1_ESPECIE","NF"            ,Nil,Nil},;
 				 {"F1_COND"   ,::aNotas[nI][10],Nil,Nil},;
 				 {"E2_NATUREZ",::aNotas[nI][11],Nil,Nil}}
 				 
 		For nP:=1 To Len(::aNotas[nI][12])
 			aItens := {	{"D1_COD"  ,::aNotas[nI][12][nP][1],Nil},;
 						{"D1_QUANT",::aNotas[nI][12][nP][2],Nil},;
 						{"D1_VUNIT",::aNotas[nI][12][nP][3],Nil},; 		
 						{"D1_TOTAL",::aNotas[nI][12][nP][4],Nil},;
 						{"D1_TES"  ,::aNotas[nI][12][nP][5],Nil}}
 			
 			aAdd(aDet,aItens) 		
 		Next		 
	  
	    //Realiza a integracao
		Begin Transaction
	 		lMsErroAuto := .F.
	        
			//integracao da nota de entrada
		   	MsExecAuto({|x,y,z,w|Mata103(x,y,z,w)},aCab,aDet,3,.F.)
	
			If lMsErroAuto
				cLog += MostraErro(cPathLog)
	
		   		DisarmTransaction()
	   		
	   		Else
	   			cLog += "Nota Fiscal "+ Right(::aNotas[nI][03],6) + " integrada com sucesso."+CRLF

	   			lGravou := .T.	   			

	   			//Adiciona o detalhe do log.
	   			aAdd(aInfoLog,{"SF1",1,xFilial("SF1")+Right(::aNotas[nI][03],6)+::aNotas[nI][04]+::aNotas[nI][07]+::aNotas[nI][08]+"N","I"})

	   		EndIf   
	
		End Transaction
	EndIf
	
Next

//Grava o log, caso houve gravacao.
If lGravou                         
	oLog := GTIntLog():New(::cArquivo,::cContArq,"GTOBJ002",cLog,aInfoLog)	
EndIf

Return cLog

/*
Metodo      : New
Classe      : GTIntArq
Descricao   : Contrutor da classe
Autor       : Eduardo C. Romanini
Data        : 10/06/2013
*/ 
*--------------------------*
Method New() Class GTIntArq 
*--------------------------*
aCabec    := {}
aDetalhes := {}
aRodape   := {}

Return Self

/*
Metodo      : Carrega
Classe      : GTIntArq
Descricao   : Carrega as informacaes do arquivo
Autor       : Eduardo C. Romanini
Data        : 10/06/2013
*/ 
*---------------------------------------------------*
Method Carrega(aCabec,aNotas,aRodape) Class GTIntArq
*---------------------------------------------------*
::aCabec    := aClone(aCabec)
::aDetalhes := aClone(aNotas)
::aRodape   := aClone(aRodape)

Return Nil

//------------------------------------------------------------------------------------------------//
//                            Declaracao das Funcaes Auxiliares                                   //
//------------------------------------------------------------------------------------------------//

/*
Funcao      : TelaParam
Descricao   : Exibe a tela de parumetros da integracao
Autor       : Eduardo C. Romanini
Data        : 25/05/2013
*/
*-------------------------------------*
Static Function TelaParam(oGTIntNfServ) 
*-------------------------------------*
Local cPrefeitura := ""
Local cTipoArq    := ""

Local nTipoNf := 0
                                        	
Local aTipoNf     := {"Tomados","Prestados"}
Local aPrefeitura := {"Sao Paulo" , "Rio de Janeiro"}    
Local aTipoArq    := {"TXT"}

Local bGetArqInt := {|| oGTIntNfServ:cArquivo := cGetFile("Arquivos de texto (*.txt) | *.txt", "Arquivo de integracao de NFe de servico",1,"C:\",.F.,nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE ),.F.),;
                        oGetArq:Refresh() }

Local oPanel                          
Local oIntNf
Local oLbTipoNf
Local oRdTipoNf
Local oLbPref
Local oCBPref
Local oLbTipoArq
Local oCBTipoArq
Local oLbArq
Local oGetArq
Local oBtnArq



//Painel do Wizard, onde a tela seru apresentada
oPanel := oGTIntNfServ:oWizard:oMPanel[oGTIntNfServ:oWizard:nPanel]

//Campo Tipo da Nota Fiscal
oLbTipoNf := TSay():New( 005, 008,{|| "Tipo da Nota de servico:"},oPanel,,,.F.,.F.,.F.,.T.,,,,, .F.,.F.,.F.,.F.,.F.)
oRdTipoNf := TRadMenu():New(004,075,aTipoNf,,oPanel,,,,,,,,200,200,,,,.T.)	
oRdTipoNf:bChange := {|| oGTIntNfServ:cTipoNf := If(nTipoNf == 1,"T","P")}
oRdTipoNf:bSetGet := {|u| If(PCount()==0,nTipoNf,nTipoNf:=u)}
oRdTipoNf:bWhen   := {|| .T.}
oRdTipoNf:bValid  := {|| .T.}

//Seleciona a 1u opcao do Tipo da Nota Fiscal
oRdTipoNf:SetOption(1)
nTipoNf := 1
oGTIntNfServ:cTipoNf := "T"

//Desabilita a 2u opcao do Tipo da Nota Fiscal(Ainda nao desenvolvido)
//oRdTipoNf:EnableItem(2,.F.)


//Campo Prefeitura
oLbPref := TSay():New( 032, 008,{|| "Prefeitura:"},oPanel,,,.F.,.F.,.F.,.T.,,,,, .F.,.F.,.F.,.F.,.F.)

cPrefeitura := aPrefeitura[1]
oGTIntNfServ:cPrefeitura := cPrefeitura
oCBPref := tComboBox():New(031,075,,aPrefeitura,100,20,oPanel,,,,,,.T.) 

oCBPref:bChange := {|| oGTIntNfServ:cPrefeitura := cPrefeitura }

oCBPref:bSetGet := {|u| If(PCount()==0,cPrefeitura,cPrefeitura:=u)}

//Campo Tipo do Arquivo
oLbTipoArq := TSay():New( 045, 008,{|| "Tipo da Nota de servico:"},oPanel,,,.F.,.F.,.F.,.T.,,,,, .F.,.F.,.F.,.F.,.F.)

cTipoArq := aTipoArq[1]
oGTIntNfServ:cTipoArq := cTipoArq
oCBTipoArq := tComboBox():New(044,075,,aTipoArq,100,20,oPanel,,,,,,.T.) 
oCBTipoArq:bChange := {|| oGTIntNfServ:cTipoArq := cTipoArq}
oCBTipoArq:bSetGet := {|u| If(PCount()==0,cTipoArq,cTipoArq:=u)}

//Campo Arquivo de integracao
oLbArq := TSay():New( 058, 008,{|| "Arquivo:"},oPanel,,,.F.,.F.,.F.,.T.,,,,, .F.,.F.,.F.,.F.,.F.)

oGetArq := TGet():New(057,075,,oPanel,160,8,,,,,,,,.T.,,,,,,,.T.)
oGetArq:bSetGet := {|u| If(PCount()==0,oGTIntNfServ:cArquivo,oGTIntNfServ:cArquivo:=u)}
                                                                                      	
oBtnArq := TBtnBmp2():New(110,480,24,24,"PESQUISA",,,,bGetArqInt,oPanel)

Return Nil

/*
Funcao      : ValidParam
Descricao   : Validacao da tela de parumetros da integracao
Autor       : Eduardo C. Romanini
Data        : 25/05/2013
*/ 
*--------------------------------------*
Static Function ValidParam(oGTIntNfServ) 
*--------------------------------------*
Local lRet := .T.

//Valida o tipo da Nota
If Empty(oGTIntNfServ:cTipoNf)
	MsgInfo("Selecione o tipo da nota de servico.","Atencao")
	Return .F.
EndIf         

//Valida a Prefeitura
If Empty(oGTIntNfServ:cPrefeitura)
	MsgInfo("Selecione a prefeitura","Atencao")
	Return .F.
EndIf

//Valida a Prefeitura
If Empty(oGTIntNfServ:cTipoArq)
	MsgInfo("Selecione o tipo do arquivo","Atencao")
	Return .F.
EndIf

//Valida o arquivo
If Empty(oGTIntNfServ:cArquivo)
	MsgInfo("Selecione o arquivo de integracao","Atencao")
	Return .F.
EndIf


Return lRet  

/*
Funcao      : TelaErro
Descricao   : Tela de exibicao de erro
Autor       : Eduardo C. Romanini
Data        : 18/06/2013
*/ 
*------------------------------------*
Static Function TelaErro(oGTIntNfServ)
*------------------------------------*
Local cLog := ""

Local oPanel
Local oLbTit
Local oTmLog

//Retorna o Painel do Wizard
oPanel := oGTIntNfServ:oWizard:oMPanel[oGTIntNfServ:oWizard:nPanel]

cLog := oGTIntNfServ:cErro

//Label de informacao
oLbTit := TSay():New(10,20,{|| "Foram encontrados erros na integracao."},oPanel,,,,,,.T.,CLR_RED,CLR_WHITE,260,15) 
oLbTit:lTransparent := .T.

//Caixa de apresentacao do log
oTmLog := TMultiGet():Create(oPanel,{|u|if(Pcount()>0,cLog:=u,cLog)},25,20,260,90,,.T.,,,,.T.,,,,,,.T.) 

Return 

/*
Funcao      : TelaPreInt
Descricao   : Tela de configuracao da integracao
Autor       : Eduardo C. Romanini
Data        : 11/06/2013
*/ 
*--------------------------------------*
Static Function TelaPreInt(oGTIntNfServ)
*--------------------------------------*
Local nI := 0
Local nX := 0

Local cPesq   		:= Space(14)
Local cCmbIndice 	:= ""

Local aCabec  		:= {}
Local aTamCab 		:= {}
Local aNfs    		:= {}
Local aIndices		:= {"CNPJ/CPF","Num. Doc"}
Local aNfsIni		:= {}

Local bMark 		:= {|| }

Local oPanel
Local oBrw
Local oOK   := LoadBitmap(GetResources(),'br_verde')
Local oNo   := LoadBitmap(GetResources(),'br_vermelho')
Local oMk   := LoadBitmap(GetResources(),'lbok')
Local oNoMk := LoadBitmap(GetResources(),'lbno')
Local oLck  := LoadBitmap(GetResources(),'lbtik')

//Carrega as Notas Fiscais
oGTIntNfServ:CarregaNf()

//Retorna o Painel do Wizard
oPanel := oGTIntNfServ:oWizard:oMPanel[oGTIntNfServ:oWizard:nPanel]

//Retorna as Notas Fiscais
aNfs 	:= aClone(oGTIntNfServ:aNotas)

If ( oGTIntNfServ:cTipoNF == 'T' )  //** servicos Tomados

	//Ajuste no array de exibicao	
	For nI:=1 To Len(aNfs)

    	//Exibe o nome do fornecedor
   		//Adiciona a posicao 8 do array
   		aAdd(aNfs[nI],aNfs[nI][9])
   		aIns(aNfs[nI],9)
    
		//Adiciona o nome do fornecedor no array de exibicao
		If !Empty(aNfs[nI][7])//Cod. Fornecedor
    		SA2->(DbSetOrder(1))
    		If SA2->(DbSeek(xFilial("SA2")+aNfs[nI][7]+aNfs[nI][8])) 	
				aNfs[nI][9] := AllTrim(SA2->A2_NOME)
    		Else
    			aNfs[nI][9] := ""
	    	EndIf
		Else
			aNfs[nI][9] := ""
		EndIf		
	
	Next

	//Define as regras de marcacao
	bMark := {|| If(aNfs[oBrw:nAt,1],;
					oLck,;                      //Marcacao de Nota ju cadastrada 
					(If (aNfs[oBrw:nAt,2],;
						oMk,;                   //Marcado
						oNoMk);                 //Nao Marcado
					);	
			  )}
    
	//RRP - Inclusão de filtro por CNPJ no Browser.
	//Filtro Inicial BKP
	aNfsIni := aClone(aNfs)

	//Cria o Browse com as notas
	// Texto de pesquisa
	@03,060 MSGET oPesq VAR cPesq SIZE 080,010 COLOR CLR_BLACK PIXEL OF oPanel
	// Interface para selecao de indice e filtro
	@03,005 COMBOBOX cCmbIndice ITEMS aIndices SIZE 055,010 PIXEL OF oPanel
	//Botao
	@03,140 Button 'Filtrar' Size 035,010 PIXEL Of oPanel ACTION;
	(IIF(Empty(cPesq),oBrw:SetArray(aNfs:= aClone(aNfsIni)),oBrw:SetArray(BrowFilter(aNfs,cPesq,aNfsIni,cCmbIndice))) ,oBrw:GoTop(),oBrw:Refresh() )		
	
 
	
	oBrw := TWBrowse():New( 15/*08*/ , 05, 290, 125,,,,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	// Seta array para o browse
	oBrw:SetArray(aNfs)
		
	// Adiciona colunas
	oBrw:AddColumn( TCColumn():New(''               ,bMark,,,,"CENTER",,.T.,.T.,,,,.F.,) )  //Botuo de Marcacao
	oBrw:AddColumn( TCColumn():New(''               ,{ || If(aNfs[oBrw:nAt,1],oOK,oNo)},,,,"CENTER",,.T.,.T.,,,,.F.,) )    //Legenda de NF ju existente
	oBrw:AddColumn( TCColumn():New('Nota Fiscal'    ,{ || aNfs[oBrw:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Serie'          ,{ || aNfs[oBrw:nAt,04] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Data'           ,{ || aNfs[oBrw:nAt,05] },,,,"CENTER",,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Cod.Forn.'      ,{ || aNfs[oBrw:nAt,07] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Loja'           ,{ || aNfs[oBrw:nAt,08] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrw:AddColumn( TCColumn():New('CNPJ/CPF'       ,{ || aNfs[oBrw:nAt,14] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )  
	oBrw:AddColumn( TCColumn():New('Fornecedor'     ,{ || aNfs[oBrw:nAt,09] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Descricao'      ,{ || aNfs[oBrw:nAt,10] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 

Else  //** servicos Prestados

	//Ajuste no array de exibicao	
	For nI:=1 To Len(aNfs)

    	//Exibe o nome do cliente
   		//Adiciona a posicao 8 do array
   		aAdd(aNfs[nI],aNfs[nI][9])
   		aIns(aNfs[nI],9)
    
		//Adiciona o nome do fornecedor no array de exibicao
		If !Empty(aNfs[nI][7])//Cod. Cliente
    		SA1->(DbSetOrder(1))
    		If SA1->(DbSeek(xFilial("SA1")+aNfs[nI][7]+aNfs[nI][8])) 	
				aNfs[nI][9] := AllTrim(SA1->A1_NOME)
    		Else
    			aNfs[nI][9] := ""
	    	EndIf
		Else
			aNfs[nI][9] := ""
		EndIf		
	
	Next

	//Define as regras de marcacao
	bMark := {|| If(aNfs[oBrw:nAt,1],;
					oLck,;                      //Marcacao de Nota ju cadastrada 
					(If (aNfs[oBrw:nAt,2],;
						oMk,;                   //Marcado
						oNoMk);                 //Nao Marcado
					);	
			  )}

	/*
		** Traz os itens marcados
	*/
	u_Job02Mark( oGTIntNfServ , aNfs ) 
	
	//Cria o Browse com as notas
	@03,05 Button 'Marca\Desmarca Todos' Size 80,10 Action( u_Job02Mark( oGTIntNfServ , aNfs ),oBrw:GoTop(),oBrw:Refresh() ) Of oPanel Pixel
	@05,100     CheckBox oCheck1 Var oGTIntNfServ:lContOnline Prompt "Contab. On-Line"    Size 80,9 Of oPanel Pixel	
	@05,170     CheckBox oCheck1 Var oGTIntNfServ:lMostraLan Prompt "Mostra Lancamentos"    Size 80,9 Of oPanel Pixel	
	oBrw := TWBrowse():New( 15/*08*/ , 05, 290, 122,,,,oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )		

	// Seta array para o browse
	oBrw:SetArray(aNfs) 

	// Adiciona colunas
	oBrw:AddColumn( TCColumn():New(''               ,bMark,,,,"CENTER",,.T.,.T.,,,,.F.,) )  //Botuo de Marcacao
	oBrw:AddColumn( TCColumn():New(''               ,{ || If(aNfs[oBrw:nAt,1],oOK,oNo)},,,,"CENTER",,.T.,.T.,,,,.F.,) )    //Legenda de NF ju existente
	oBrw:AddColumn( TCColumn():New('Nota Fiscal'    ,{ || aNfs[oBrw:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Serie'          ,{ || aNfs[oBrw:nAt,04] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Data'           ,{ || aNfs[oBrw:nAt,05] },,,,"CENTER",,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Cod.Cliente.'      ,{ || aNfs[oBrw:nAt,07] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Loja'           ,{ || aNfs[oBrw:nAt,08] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Cliente'     ,{ || aNfs[oBrw:nAt,09] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 
	oBrw:AddColumn( TCColumn():New('Descricao'      ,{ || aNfs[oBrw:nAt,10] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) ) 

	oBrw:GoTop()
	oBrw:Refresh()

EndIf

//Define as regras de duplo-clique
oBrw:bLDblClick := {|| DbCliPreInt(@aNfs,oBrw,oGTIntNfServ),oBrw:DrawSelect()}
                               	
Return

/*
Funcao      : BrowFilter
Descricao   : Filtro das notas fiscais
Autor       : Renato Rezende
Data        : 14/03/2017
*/
*-----------------------------------------------------------*
 Static Function BrowFilter(aNfs,cPesq,aNfsIni,cCmbIndice)
*-----------------------------------------------------------*
Local lAchou 	:= .F.
Local aFiltro	:= {}
Local nR		:= 0

For nR:=1 to len(aNfs)
	If cCmbIndice == "CNPJ/CPF"
		If Alltrim(cPesq) == Alltrim(aNfs[nR][14])
			AADD(aFiltro,aClone(aNfs[nR]))
			lAchou := .T.
		EndIf
	EndIf
	If cCmbIndice == "Num. Doc"
		If Alltrim(cPesq) == Alltrim(aNfs[nR][03])
			AADD(aFiltro,aClone(aNfs[nR]))
			lAchou := .T.
		EndIf
	EndIf
Next nR 

//Ajuste no array de exibicao
If lAchou
	aNfs:= aClone(aFiltro)
Else
	MsgInfo("Filtro não retornou nenhum registo!","HLB BRASIL")
EndIf

Return aNfs

/*
Funcao      : DbCliPreInt
Descricao   : Marcacao das notas fiscais para integracao
Autor       : Eduardo C. Romanini
Data        : 11/06/2013
*/ 
*---------------------------------------------------*
Static Function DbCliPreInt(aNfs,oBrw,oGTIntNfServ)
*---------------------------------------------------*

//Verifica se a NF ainda Nao existe no sistema
If !aNfs[oBrw:nAt,1]
	//Verifica se o item Nao estu marcado
	If !aNfs[oBrw:nAt,2]
		//Chama a tela de configuracao da NF.
		aNfs[oBrw:nAt,2] := If( oGTIntNfServ:cTipoNF == 'T' , PreConfigNF(oGTIntNfServ,aNfs[oBrw:nAt],oBrw:nAt) , ConfigNFPS(oGTIntNfServ,aNfs[oBrw:nAt],oBrw:nAt)) 
	Else
		aNfs[oBrw:nAt,2] := .F.	
	EndIf
    
	//Atualiza o objeto de notas fiscais
	oGTIntNfServ:aNotas[oBrw:nAt,2] := aNfs[oBrw:nAt,2]
	
//NF ju estu cadastrada
Else
	MsgInfo("Essa Nota Fiscal ja esta cadastrada no sistema","Atencao")
EndIf

Return Nil  

/*
Funcao      : PreConfigNF
Descricao   : Tela de Configuracao da Nota Fiscal
Autor       : Eduardo C. Romanini
Data        : 11/06/2013
*/ 
*-----------------------------------------------------*
Static Function PreConfigNF(oGTIntNfServ,aNf,nPosNotas)
*-----------------------------------------------------*          
Local lRet   := .F.
Local lGrava := .F.

Local cFieldOk := ""
Local cLinOk   := ""

Local nI      := 0
Local nPos    := 0
Local nPosAux := 0
Local nPosCod := 0
Local nPosQtd := 0
Local nPosVUn := 0
Local nPosTot := 0
Local nPosDel := 0

Local aSizeAut  := {}
Local aCposEnc  := {}
Local aCposIt   := {}
Local aCpoGDa   := {}
Local aHeader   := {}
Local aCols     := {}
Local aItens    := {}
Local aFolder   := {"Nota Fiscal","Fornecedor"}
Local aAlter    := {}

Local bOk     := {|| If(ValPreConfig(oGTIntNfServ,aNf),(lGrava:=.T.,oDlg:End()),)}
Local bCancel := {|| oDlg:End()}

Local oDlg
Local oLayer
Local oCabec
Local oItens
Local oMsgBar
Local oFontBar
Local oBarItem

Private oEnch 
Private oMGet
Private oNfServ := oGTIntNfServ
//Maximizacao da tela em relacao a area de trabalho
aSizeAut := MsAdvSize()	

//Dados da Nota Fiscal de servico
/*
Estrutura do vetor
[1] - Titulo	
[2] - campo	
[3] - Tipo	
[4] - Tamanho	
[5] - Decimal	
[6] - Picture	
[7] - Valid	
[8] - Obrigat	
[9] - Nivel	
[10]- Inicializador Padruo	
[11]- F3         	
[12]- when	
[13]- visual	
[14]- chave	
[15]- box	
[16]- folder	
[17]- nao alteravel	
[18]- pictvar	            	
[19]- gatilho
*/     
//Pasta Nota Fiscal
aAdd(aCposEnc,{"Nota Fiscal","NF"     ,"C",020,0,""                 ,"",.T.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Data"       ,"DTNF"   ,"D",008,0,"@D"               ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Vl.servicos","VALOR"  ,"N",012,2,"@E 999,999,999.99","",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Cod.servico","CODSERV","C",005,0,"99999"            ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
//aAdd(aCposEnc,{"Aliq.ISS"   ,"ALIQISS","N",004,2,"@E 99.99"         ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
//aAdd(aCposEnc,{"Valor ISS"  ,"VALISS" ,"N",012,2,"@E 999,999,999.99","",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
//aAdd(aCposEnc,{"ISS Retido" ,"ISSRET" ,"C",003,0,"@!"               ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Vl.Credito" ,"VALCRE" ,"N",012,2,"@E 999,999,999.99","",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"servicos."  ,"SERV"   ,"M",255,0,"@!"               ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Cond. Pagto","COND"   ,"C",003,0,""                 ,"",.T.,1,"","SE4","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Natureza"   ,"NATUREZ","C",010,0,""                 ,"",.T.,1,"","SED","",.F.,.F.,"",1,.F.,"",""})

//Pasta Fornecedor
aAdd(aCposEnc,{"Codigo"     ,"CODFOR" ,"C",06,0,"@!"               ,"",.T.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Loja"       ,"LOJFOR" ,"C",02,0,"@!"               ,"",.T.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"CPF/CNPJ"   ,"CGCFOR" ,"C",14,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Nome"       ,"NOMEFOR","C",75,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Insc.Munic.","IMFOR"  ,"C",08,0,"99999999"         ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Endereco"   ,"ENDFOR" ,"C",80,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Bairro"     ,"BAIFOR" ,"C",30,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Cidade"     ,"CIDFOR" ,"C",50,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Estado"     ,"ESTFOR" ,"C",02,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"CEP"        ,"CEPFOR" ,"C",09,0,"99999-999"        ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})

//Retorna a posicao da Nf no array de detalhes do arquivo 
nPos := oGTIntNfServ:RetPosNf(aNf[3])

//Carrega as variaveis de memuria
If nPos > 0 
	M->NF      := aNf[3]
	M->DTNF    := aNf[5]
	M->VALOR   := oGTIntNfServ:oIntArq:aDetalhes[nPos][25]
	M->CODSERV := oGTIntNfServ:oIntArq:aDetalhes[nPos][27]
	//M->ALIQISS := oGTIntNfServ:oIntArq:aDetalhes[nPos][28]
	//M->VALISS  := oGTIntNfServ:oIntArq:aDetalhes[nPos][29]
	//M->ISSRET  := If(oGTIntNfServ:oIntArq:aDetalhes[nPos][21]=="S","Sim","Nao")
	M->VALCRE  := oGTIntNfServ:oIntArq:aDetalhes[nPos][30]
	M->SERV    := oGTIntNfServ:oIntArq:aDetalhes[nPos][34]
	M->COND    := Space(3)
    M->NATUREZ := If(!Empty(aNf[11]),aNf[11],Space(10)) 
	M->CGCFOR  := oGTIntNfServ:oIntArq:aDetalhes[nPos][12]
	M->NOMEFOR := oGTIntNfServ:oIntArq:aDetalhes[nPos][13]
	M->IMFOR   := oGTIntNfServ:oIntArq:aDetalhes[nPos][10]
	M->ENDFOR  := oGTIntNfServ:oIntArq:aDetalhes[nPos][14]
	M->BAIFOR  := oGTIntNfServ:oIntArq:aDetalhes[nPos][15]
	M->CIDFOR  := oGTIntNfServ:oIntArq:aDetalhes[nPos][16]	
	M->ESTFOR  := oGTIntNfServ:oIntArq:aDetalhes[nPos][17]	
	M->CEPFOR  := oGTIntNfServ:oIntArq:aDetalhes[nPos][18]
	M->CODFOR  := ""
    M->LOJFOR  := ""
	
	//Verifica se o forncedor ju existe na base
	If aNf[6]
		M->CODFOR  := aNf[7]
    	M->LOJFOR  := aNf[8]
	Else
		//Verifica se o mesmo fornecedor ju estu sendo utilizado em outra nota marcada
		For nI:=1 To Len(oGTIntNfServ:aNotas)

			//Verifica se Nao u a nota que estu sendo marcada no momento
			If nI <> nPosNotas
				
				//Verifica se a nota estu marcada
				If oGTIntNfServ:aNotas[nI][2]

					//Retorna a posicao da nota no arquivo
					nPosAux := oGTIntNfServ:RetPosNf(oGTIntNfServ:aNotas[nI][3])

					//Verifica se o CPF/CNPJ u o mesmo					
					If oGTIntNfServ:oIntArq:aDetalhes[nPos][12] == oGTIntNfServ:oIntArq:aDetalhes[nPosAux][12] 
						
						M->CODFOR := oGTIntNfServ:aNotas[nI][7]
						M->LOJFOR := oGTIntNfServ:aNotas[nI][8]
						Exit					
					EndIf 
				EndIf
			EndIf
		Next 		
		
		If Empty(M->CODFOR) .and. Empty(M->LOJFOR)
			//Carrega o proximo cudigo livre de fornecedor.
			SA2->(DbSetOrder(1))
			SA2->(DbGoBottom())
			SA2->(DbSkip(-1))
		
			M->CODFOR  := GetSXENum("SA2","A2_COD")                                                                                                       
    		M->LOJFOR  := "01"
   		EndIf
	EndIf
	
EndIf

//Verifica se o forncedor Nao existe na base
If !aNf[6]
	aAdd(aAlter,"CODFOR")
	aAdd(aAlter,"LOJFOR")
EndIf

aAdd(aAlter,"COND")
aAdd(aAlter,"NATUREZ")

//Dados dos itens da nota

//Define a estrutura da tabela temporuria
aCposIt := {{"ITEM"  ,"C",04,0},;
          	{"CODIGO","C",15,0},;
			{"QUANT" ,"N",11,2},;
        	{"VUNIT" ,"N",14,2},;
         	{"TOTAL" ,"N",14,2}}

//            TITULO        ,CAMPO   ,PICTURE             ,TAMANHO,DECIMAL,VALID,,TIPO,F3   ,,CBOX,RELACAO,WHEN   
aAdd(aHeader,{"Item"        ,"ITEM"  ,"9999"             ,04     ,0      ,".T." ,,"C" ,     ,,""  ,""     ,""  })
aAdd(aHeader,{"Codigo"      ,"CODIGO","@!"               ,15     ,0      ,".T." ,,"C" ,"ALT",,""  ,""     ,""  })
aAdd(aHeader,{"Tipo Entrada","TES"   ,"@9"               ,3      ,0      ,".T." ,,"C" ,"SF4",,""  ,""     ,""  })
aAdd(aHeader,{"Quant."      ,"QUANT" ,"@E 99999999.99"   ,11     ,2      ,".T." ,,"N" ,     ,,""  ,""     ,""  })
aAdd(aHeader,{"Valor Unit." ,"VUNIT" ,"@E 999,999,999.99",14     ,2      ,".T." ,,"N" ,     ,,""  ,""     ,""  })
aAdd(aHeader,{"Valor Total" ,"TOTAL" ,"@E 999,999,999.99",14     ,2      ,".T." ,,"N" ,     ,,""  ,""     ,""  })

aCols:={Array(Len(aHeader)+1)}
aCols[1,Len(aHeader)+1]:=.F.	

For nI:=1 To Len(aHeader)
	If aHeader[nI][8] == "C"
		aCols[1][nI] := Space(aHeader[nI][4])
	ElseIf aHeader[nI][8] == "N"
		aCols[1][nI] := 0
	ElseIf aHeader[nI][8] == "D"
		aCols[1][nI] := CtoD("  /  /  ")
	EndIf
	
	//Carrega o primeiro item
	If aHeader[nI][2] == "ITEM"
		aCols[1][nI] := "0001"
	EndIf
	
	//Carrega a quantidade inicial
	If aHeader[nI][2] == "QUANT"
		aCols[1][nI] := 1
	EndIf
	
	//Carrega o valor uniturio com o valor total dos servicos
	If aHeader[nI][2] == "VUNIT"
		aCols[1][nI] := M->VALOR 
	EndIf

	//Carrega o total com o valor total dos servicos
	If aHeader[nI][2] == "TOTAL"
		aCols[1][nI] := M->VALOR 
	EndIf
	
Next

//Define os campos que seruo editaveis
aCpoGDa := {"CODIGO","QUANT","VUNIT","TES","NATUREZ"}

//Define a funcao de validacao dos campos
cFieldOk := "U_ValCpoItCon"

//Define a funcao de validacao das linhas]
cLinOk := "U_ValLinItCon"

//Tela de Configuracao da Nota Fiscal
DEFINE MSDIALOG oDlg FROM aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] PIXEL TITLE "Configuracaes da Nota Fiscal" 

//Cria o objeto FWLayer
oLayer := FWLayer():new()

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botuo de fechar
oLayer:init(oDlg,.T.)

//Cria as linhas do Layer
oLayer:addLine("Lin01",50,.F.)
oLayer:addLine("Lin02",50,.F.)

//Cria as colunas do Layer
oLayer:addCollumn('Col01',100,.F.,"Lin01")
oLayer:addCollumn('Col02',100,.F.,"Lin02")

//Adiciona Janelas as colunas
oLayer:addWindow('Col01','L1_Win01','Dados da Nota Fiscal',100,.T.,.T.,{|| },"Lin01",{|| })
oLayer:addWindow('Col02','L2_Win01','Produtos'            ,100,.T.,.T.,{|| },"Lin02",{|| })

//Retorna o painel de Dados da NFS
oCabec:= oLayer:GetWinPanel('Col01','L1_Win01',"Lin01") 

//Exibe a enchoice com os dados da nota fiscal.
oEnch := MsMGet():New(,,3,,,,,{000,000,400,600},aAlter,,,,,oCabec,.F.,.T.,,,,,aCposEnc,aFolder,.T.)
oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT

//Retorna o painel de Itens da NFS
oItens:= oLayer:GetWinPanel('Col02','L2_Win01',"Lin02")      

//Exibe o grid para inclusuo dos itens da nota
oMGet := MsNewGetDados():New(0,0,oItens:nHeight,oItens:nWidth,GD_INSERT+GD_UPDATE+GD_DELETE,cLinOk,"AllwaysTrue","+ITEM",aCpoGDa,1,,cFieldOk,,,oItens,aHeader,aCols)    
oMGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//Define a fonte da barra de status
oFontBar := TFont():New('Courier New',,-14,.T.)

//Exibe a barra de status
oMsgBar  := TMsgBar():New(oDlg,"integracao de Nota Fiscal de servico",.F.,.F.,.F.,.F.,RGB(255,255,255),,oFontBar,.F.)
oBarItem := TMsgItem():New( oMsgBar,"Arquivo de integracao: " + oGTIntNfServ:cArquivo, 100,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bOK , bCancel )

aItens := {}

//Marca a nota fiscal para integracao.
If lGrava

	//Grava o cudigo do fornecedor
	If !aNf[6] //Verifica se o fornecedor ainda Nao estu cadastrado.
		oGTIntNfServ:aNotas[nPosNotas][7] := M->CODFOR
		oGTIntNfServ:aNotas[nPosNotas][8] := M->LOJFOR
	EndIf		
    
    //Grava a condicao de pagamento
    oGTIntNfServ:aNotas[nPosNotas][10] := M->COND
    
    //Grava a natureza
    oGTIntNfServ:aNotas[nPosNotas][11] := M->NATUREZ
    
	//Carrega a posicao dos campos no grid
	nPosCod := aScan(oMGet:aHeader,{|x| x[2] == "CODIGO"})
	nPosQtd := aScan(oMGet:aHeader,{|x| x[2] == "QUANT"})
	nPosVUn := aScan(oMGet:aHeader,{|x| x[2] == "VUNIT"})
	nPosTot := aScan(oMGet:aHeader,{|x| x[2] == "TOTAL"})
	nPosTes := aScan(oMGet:aHeader,{|x| x[2] == "TES"})
	nPosDel := Len(oMGet:aCols[1])

	//Grava os itens da Nota
	For nI:=1 To Len(oMGet:aCols)
		If !oMGet:aCols[nI][nPosDel]
			aAdd(aItens,{oMGet:aCols[nI][nPosCod],; //Cudigo do Produto
				   		 oMGet:aCols[nI][nPosQtd],; //Quantidade
						 oMGet:aCols[nI][nPosVUn],; //Valor Uniturio
						 oMGet:aCols[nI][nPosTot],; //Valor Total
						 oMGet:aCols[nI][nPosTes]}) //TES
		EndIf			
    Next

	//Marcacao do item
	lRet := .T.

Else
	SA2->(RollBackSX8())	
EndIf

//Grava os itens no objeto.
oGTIntNfServ:GravaItens(nPosNotas,aItens)

Return lRet    

/*
Funcao      : ValCpoItCon
Descricao   : Validacao de campos do grid de itens na tela de configuracao das notas.
Autor       : Eduardo C. Romanini
Data        : 12/06/2013
*/ 
*-------------------------*
User Function ValCpoItCon()
*-------------------------*
Local lRet := .T.

Local cCampo := Substr(AllTrim(ReadVar()),4)

Local xValor := &(ReadVar())

Local nLin    := oMGet:nAt
Local nPosCod := aScan(oMGet:aHeader,{|x| x[2] == "CODIGO"})
Local nPosQtd := aScan(oMGet:aHeader,{|x| x[2] == "QUANT"})
Local nPosVUn := aScan(oMGet:aHeader,{|x| x[2] == "VUNIT"})
Local nPosTot := aScan(oMGet:aHeader,{|x| x[2] == "TOTAL"})
Local nPosTes := aScan(oMGet:aHeader,{|x| x[2] == "TES"})

//Validacao do cudigo do item
If cCampo == "CODIGO"
	
	If !Empty(xValor)
		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(xFilial("SB1")+xValor))
			MsgInfo("Esse produto nao esta cadastrado.","Atencao")
			Return .F.
		EndIf
	EndIf

//Validacao da Quantidade
ElseIf cCampo == "QUANT"

	If xValor < 0
		MsgInfo("A quantidade Nao pode ser negativa","Atencao")
		Return .F.	
	EndIf
    
	//Calcula o valor total
	oMGet:aCols[nLin][nPosTot] := xValor * oMGet:aCols[nLin][nPosVUn]

//Validacao do Valor Uniturio
ElseIf cCampo == "VUNIT"
	
	If xValor < 0
		MsgInfo("O valor unitario Nao pode ser negativo","Atencao")
		Return .F.	
	EndIf		
   
	//Calcula o valor total
	oMGet:aCols[nLin][nPosTot] := xValor * oMGet:aCols[nLin][nPosQtd]

//Validacao do Tipo de Entrada
ElseIf cCampo == "TES"
	If !Empty(xValor)
		SF4->(DbSetOrder(1))
		If !SF4->(DbSeek(xFilial("SF4")+xValor))
			MsgInfo("Essa TES Nao esta cadastrada.","Atencao")
			Return .F.
		Else
			//If SF4->F4_TIPO <> "E"
			If oNfServ:cTipoNF == 'T' .And. SF4->F4_TIPO <> 'E' 
				MsgInfo("Essa TES Nao e do tipo 'Entrada'.","Atencao")
				Return .F.
			EndIf
			
			If oNfServ:cTipoNF == 'P' .And. SF4->F4_TIPO <> 'S' 
				MsgInfo("Essa TES Nao e do tipo 'Saida'.","Atencao")
				Return .F.
			EndIf			
			
			If SF4->F4_ISS <> "S" 
				MsgInfo("Essa TES invulida para notas de servico.","Atencao")
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

//Atualiza o objeto
oMGet:Refresh()

Return lRet

/*
Funcao      : ValLinItCon
Descricao   : Validacao da linha de itens na tela de configuracao das notas.
Autor       : Eduardo C. Romanini
Data        : 12/06/2013
*/ 
*-------------------------*
User Function ValLinItCon()
*-------------------------*    
Local lRet := .T.

Local nLin    := oMGet:nAt
Local nPosCod := aScan(oMGet:aHeader,{|x| x[2] == "CODIGO"})
Local nPosQtd := aScan(oMGet:aHeader,{|x| x[2] == "QUANT"})
Local nPosVUn := aScan(oMGet:aHeader,{|x| x[2] == "VUNIT"})
Local nPosTot := aScan(oMGet:aHeader,{|x| x[2] == "TOTAL"}) 
Local nPosTes := aScan(oMGet:aHeader,{|x| x[2] == "TES"})
Local nPosDel := Len(oMGet:aCols[nLin])

//Valida de a linha estu deletada
If oMGet:aCols[nLin][nPosDel]
	Return .T.	
EndIf

//Valida se o produto foi informado
If Empty(oMGet:aCols[nLin][nPosCod])
	MsgInfo("O codigo do produto Nao foi informado.","Atencao")
	Return .F.
EndIf

//Valida se a quantidade foi informada
If oMGet:aCols[nLin][nPosQtd] <= 0
	MsgInfo("A quantidade Nao foi informada.","Atencao")
	Return .F.
EndIf

//Valida se o valor uniturio foi informado
If oMGet:aCols[nLin][nPosVUn] <= 0
	MsgInfo("O valor unitario Nao foi informado.","Atencao")
	Return .F.
EndIf

//Valida se a Tes foi informada
If Empty(oMGet:aCols[nLin][nPosTes])
	MsgInfo("A TES Nao foi informada.","Atencao")
	Return .F.
EndIf

Return lRet

/*
Funcao      : ValPreConfig
Descricao   : Validacao da tela de configuracao das notas.
Autor       : Eduardo C. Romanini
Data        : 12/06/2013
*/ 
*--------------------------------------------*
Static Function ValPreConfig(oGTIntNfServ,aNf)
*--------------------------------------------*                 
Local lRet := .T.

Local nI      := 0
Local nTotal  := 0
Local nPosNf  := 0
Local nPosCod := aScan(oMGet:aHeader,{|x| x[2] == "CODIGO"})
Local nPosQtd := aScan(oMGet:aHeader,{|x| x[2] == "QUANT"})
Local nPosVUn := aScan(oMGet:aHeader,{|x| x[2] == "VUNIT"})
Local nPosTot := aScan(oMGet:aHeader,{|x| x[2] == "TOTAL"})
Local nPosTes := aScan(oMGet:aHeader,{|x| x[2] == "TES"})
Local nPosDel := Len(oMGet:aCols[1])

Local cTipoNF := oGTIntNfServ:cTipoNf

//Retorna a posicao da Nf no array de detalhes do arquivo 
nPosNf := oGTIntNfServ:RetPosNf(aNf[3])

//Verifica os campos obrigaturios da capa
If !Obrigatorio(oEnch:aGets,oEnch:aTela)
	Return .F.
EndIf

//Verifica se o fornecedor informado ju estu cadastrado.
If !aNf[6]
	
	If ( cTipoNF == 'T' )
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(xFilial("SA2")+M->CODFOR+M->LOJFOR))
			MsgInfo("O codigo e a loja do fornecedor informados, ja se encontram cadastrados no sistema.","Atencao")
			Return .F.
		EndIf
	EndIf
	
	If ( cTipoNF == 'P' )
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+M->CODCLI+M->LOJCLI))
			MsgInfo("O cudigo e a loja do clientes informados, ja se encontram cadastrados no sistema.","Atencao")
			Return .F.
		EndIf
	EndIf
EndIf

//Verifica se a condicao de pagamento existe.
SE4->(DbSetOrder(1))
If !SE4->(DbSeek(xFilial("SE4")+M->COND))
	MsgInfo("A condicao de pagamento informada, Nao esta cadastrada no sistema.","Atencao")
	Return .F.
EndIf   

//Verifica se a condicao de pagamento existe.
//If ( cTipoNF == 'T' )
	SED->(DbSetOrder(1))
	If !SED->(DbSeek(xFilial("SED")+M->NATUREZ))
		MsgInfo("A natureza informada, Nao esta cadastrada no sistema.","Atencao")
		Return .F.
	EndIf
//EndIf

//Verifica os itens
For nI:=1 To Len(oMGet:aCols)
	//Verifica se o produto foi informado    
	If Empty(oMGet:aCols[nI][nPosCod])
		MsgInfo("O cudigo do produto Nao foi informado no item " + AllTrim(Str(nI)),"Atencao")
		Return .F.
	EndIf    
    
	//Verifica se a quantidade foi informada    
	If oMGet:aCols[nI][nPosQtd] <= 0 
		MsgInfo("A quantidade Nao foi informada no item " + AllTrim(Str(nI)),"Atencao")
		Return .F.
	EndIf    

	//Verifica se o valor uniturio foi informado    
	If oMGet:aCols[nI][nPosVUn] <= 0
		MsgInfo("O Valor Unitario Nao foi informado no item " + AllTrim(Str(nI)),"Atencao")
		Return .F.
	EndIf    

	//Verifica se a TES foi informada    
	If Empty(oMGet:aCols[nI][nPosTes])
		MsgInfo("A TES Nao foi informada no item " + AllTrim(Str(nI)),"Atencao")
		Return .F.
	EndIf    

	//Carrega o valor total dos itens
	If !oMGet:aCols[nI][nPosDel]							
		nTotal += oMGet:aCols[nI][nPosTot]
	EndIf
Next

If ( cTipoNF == 'T' )
	If nTotal <> oGTIntNfServ:oIntArq:aDetalhes[nPosNf][25]
		MsgInfo("O valor total dos itens Nao pode ser diferente do valor total dos servicos.","Atencao")	
		Return .F.
	EndIf
EndIf

If ( cTipoNF == 'P' )
	If nTotal <> oGTIntNfServ:oIntArq:aDetalhes[nPosNf][52]
		MsgInfo("O valor total dos itens Nao pode ser diferente do valor total dos servicos.","Atencao")	
		Return .F.
	EndIf
EndIf

Return lRet 

/*
Funcao      : ValidConfig
Descricao   : Validacao da tela de configuracao das notas.
Autor       : Eduardo C. Romanini
Data        : 13/06/2013
*/ 
*---------------------------------------*
Static Function ValidConfig(oGTIntNfServ)
*---------------------------------------*
Local lRet := .T.

Local nI     := 0
Local nCount := 0

For nI:=1 To Len(oGTIntNfServ:aNotas)
	
	//Verifica se a nota Nao estu cadastrada no sistema e estu marcada.
	If !oGTIntNfServ:aNotas[nI][1] .and. oGTIntNfServ:aNotas[nI][2]
		nCount++
	EndIf
Next

//Verifica se existe nota para integracao
If nCount <= 0
	MsgInfo("Selecione ao menos uma nota fiscal para integracao.","Atencao")
	Return .F.
EndIf

Return lRet 

/*
Funcao      : TelaIntegra
Descricao   : Tela de integracao das notas fiscais
Autor       : Eduardo C. Romanini
Data        : 13/06/2013
*/       

*---------------------------------------*
Static Function TelaIntegra(oGTIntNfServ)
*---------------------------------------*
Local cLog := ""

Local nMeter := 0

Local oPanel
Local oMeter
Local oFont
Local oLbTit
Local oTMLog

Local dDataOld := dDataBase
//Retorna o Painel do Wizard
oPanel := oGTIntNfServ:oWizard:oMPanel[oGTIntNfServ:oWizard:nPanel]

//Label de informacao
oLbTit := TSay():New(10,20,{|| "Realizando a integracao das notas fiscais..."},oPanel,,,,,,.T.,CLR_RED,CLR_WHITE,260,15) 
oLbTit:lTransparent := .T.

//Cria a regua de processamento
oMeter := TMeter():New(25,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oPanel,260,15,,.T.,,,.T.)

//Caixa de apresentacao do log
oTmLog := TMultiGet():Create(oPanel,{|u|if(Pcount()>0,cLog:=u,cLog)},40,20,260,90,,.T.,,,,.T.,,,,,,.T.) 

//Executa a integracao

If ( oGTIntNfServ:cTipoNf == 'T' )  //** integracao notas de servicos tomados
	cLog := oGTIntNfServ:IntegraNf(@oMeter)
Else
	cLog := oGTIntNfServ:IntegraNFPS(@oMeter) //** integracao notas de servicos prestados
EndIf	
dDataBase := dDataOld

Return Nil 

/*
Metodo      : LeArqPrest()
Classe      : GTIntNfServ
Descricao   : Realiza a leitura do arquivo de integracao - Nota de Prestacao de servicos
Autor       : Leandro Diniz de Brito
Observacaes : Adaptado a partir do metodo 'LeArquivo'
Data        : 02/03/2015
*/
*------------------------------------*
Method LeArqPrest() Class GTIntNfServ
*------------------------------------*
Local cLinha   := ""
Local cTipoAnt := ""

Local nH      := 0
Local nTamArq := 0

Local aCabec  := {}
Local aNotas  := {}
Local aRodape := {}

Local aEstru := { { "LINHA" , "C" , 2500 , 0 } }
Local cArqTemp  := CriaTrab( ,.f. )

Local cFile  := Alltrim( ::cArquivo )


::cErro := ""

If !CpyT2S( cFile  , AllTrim( GetSrvProfString( "StartPath" , "" ) ) )
   ::cErro := "Erro na copia do arquivo para o servidor." + CRLF
   Return
EndIf   

cFile := SubStr( cFile , RAt( "\" , cFile ) + 1 )  
DbCreate( cArqTemp+'.dbf'  , aEstru ) 
dbUseArea( .T. ,, cArqTemp+'.dbf'  ,'ARQUIVO' , .T. , .F. )

Append FROM &(cFile) SDF 
DbGotop()

While !Eof() 

	cLinha := AllTrim( ARQUIVO->LINHA )
    
	//Grava o conteudo do arquivo
	//::cContArq += cLinha

 	/*
 		** Leandro Brito - 06/03/2015 ** 
 		Para criar um novo layout basta adicionar um novo 'Case' abaixo e manter as mesmas posicaes dos arrays aCabec, aDetalhes e aRodape .
 		A partir disso, a rotina faru todo o tramento de validacao e integracao .  
 		As linhas de comentarios dos campos que estuo com asterisco ( * ) informa as posicaes que suo usadas na rotina ( validacao, exibicao de dados e integracao )
 	*/
 	Do Case 
	 	
 	Case ::cPrefeitura == "Rio de Janeiro"
	 	//Cabeualho
	 	If Left(cLinha,1) == "1"
	        
	    	aAdd(aCabec,{	Substr(cLinha,01,02)      ,; //[01] - Tipo do Registro
   	 					 	Substr(cLinha,03,03)      ,; //[02] - Versuo do Arquivo
    					 	Substr(cLinha,06,01)      ,; //[03] - Identificacao do contribuinte
    				 		Substr(cLinha,7,14),; //[04] - CNPJ Contribuinte
    				 		Substr(cLinha,21,15),; //[05] - Inscricao Municipal Contribuinte
							StoD( Substr(cLinha,36,08) ),; //[06] - Periodo Inicial
    				 		StoD( Substr(cLinha,44,08) ) } ) //[07] - Periodo Final

    				 	
	  	//Notas Fiscais
	 	ElseIf Left(cLinha,1) == "2" .and. Len(cLinha) > 500
   
 		   	aAdd(aNotas,{	SubsTr( cLinha , 1 , 2 ) ,; // 01 - Tipo de Registro
    						SubStr( cLinha , 3 , 15 ) ,; //02 - Numero da nota fiscal eletronica *
    						SubStr( cLinha , 18 , 01 ) ,; //03 - Status da Nota     					
    						SubStr( cLinha , 19 , 09 ) ,; //04 - Codigo de Verificacao    					
    						StoD( SubStr( cLinha , 28 , 08 ) ) ,; //05 - Data/Hora Emissao da Nota *
							SubStr( cLinha , 42 , 01 ) ,; //06 - Tipo de RPS 
   		 					SubStr( cLinha , 43 , 05 ) ,; //07 - Serie do RPS   
   		 					SubStr( cLinha , 48 , 15 ) ,; //08 - Numero do RPS 
   	 						StoD( SubStr( cLinha , 63 , 08 ) ) ,; //09 - Data Emissao RPS
    						SubStr( cLinha , 71 , 01 ) ,; //10 - CPF/CNPJ *
    						If( SubStr( cLinha , 71 , 1 ) == '2' , SubStr( cLinha , 72 , 14 ) , SubStr( cLinha , 75 , 11 ) )  ,; //11 - CPF/CNPJ *
    						SubStr( cLinha , 86 , 15 ) ,; //12 - Inscricao Municipal Prestador *
    						SubStr( cLinha , 101 , 15 ) ,; //13 - Inscricao Municipal  *
    						SubStr( cLinha , 116 , 115 ) ,; //14 - Razao Social Prestador *
    						SubStr( cLinha , 231 , 60 ) ,; //15 - Nome Fantasia Prestador * 
    						SubStr( cLinha , 291 , 03 ) ,; //16 - Tipo Endereco *
    						SubStr( cLinha , 294 , 125 ) ,; //17 - Endereco Prestador *    					    					    					    					    					    					    					    					    					    											
    						SubStr( cLinha , 419 , 10 ) ,; //18 - Numero endereco *
    						SubStr( cLinha , 429 , 60 ) ,; //19 - Complmento endereco *    					    					    					    					
    						SubStr( cLinha , 489 , 72 ) ,; //20 - Bairro *
    						SubStr( cLinha , 561 , 50 ) ,; //21 - Cidade *
    						SubStr( cLinha , 611 , 02 ) ,; //22 - UF *
    						SubStr( cLinha , 613 , 02 ) ,; //23 - CEP *
    						SubStr( cLinha , 621 , 11 ) ,; //24 - Telefone *
    						SubStr( cLinha , 632 , 80 ) ,; //25 - Email *
    						SubStr( cLinha , 712 , 01 ) ,; //26 - CPF/CNPJ Tomador *
    						If( SubStr( cLinha , 712 , 1 ) == '2' , SubStr( cLinha , 713 , 14 ) , SubStr( cLinha , 716 , 11 ) )  ,; //27 - Numero CPF/CNPJ Tomador *
    						SubStr( cLinha , 727 , 15 ) ,; //28 - Inscricao Municipal Tomador *
    						SubStr( cLinha , 742 , 15 ) ,; //29 - Inscricao Estadual Tomador *
    						SubStr( cLinha , 757 , 115 ) ,; //30 - Razao Social Tomador *
    						SubStr( cLinha , 872 , 03 ) ,; //31 - Tipo de logradouro Tomador *
    						SubStr( cLinha , 875 , 125 ) ,; //32 - Endereco Tomador    			 *		    					    					    					    					    					    					
    						SubStr( cLinha , 1000 , 10 ) ,; //33 - Numero Endereco Tomador *
    						SubStr( cLinha , 1010 , 60 ) ,; //34 - Complemento Endereco Tomador *
							SubsTr( cLinha , 1070 , 72 )  ,; //35 - Bairro Tomador *
    						SubStr( cLinha , 1142 , 50 ) ,; //36 - Cidade Tomador *
    						SubStr( cLinha , 1192 , 02 ) ,; //37 - UF Tomador     	 *				
    						SubStr( cLinha , 1194 , 08 ) ,; //38 - CEP    				 *	
    						SubStr( cLinha , 1202 , 11 ) ,; //39 - Telefone *
							SubStr( cLinha , 1213 , 80 ) ,; //40 - Email *
    						SubStr( cLinha , 1293 , 02 ) ,; //41 - Tipo de servico da Nota
    						SubStr( cLinha , 1295 , 50 ) ,; //42 - Cidade de prestacao servico
    						SubStr( cLinha , 1345 , 02 ) ,; //43 - UF Prestacao servico
    						SubStr( cLinha , 1347 , 02 ) ,; //44 - Regime Especial de Tributacao
    						SubStr( cLinha , 1349 , 01 ) ,; //45 - Simples Nacional ?
    						SubStr( cLinha , 1350 , 01 ) ,; //46 - Incentivo Cultural
    						SubStr( cLinha , 1351 , 04 ) ,; //47 - Cod.Servico Lista Federal
    						SubStr( cLinha , 1355 , 11 ) ,; //48 - Brancos
    						SubStr( cLinha , 1366 , 03 ) ,; //49 - Cod. Beneficio
    						SubStr( cLinha , 1369 , 06 ) ,; //50 - Cod.Servico Lista Municipal *
    						Val(SubStr( cLinha , 1375 , 05 ) )/100 ,; //51 - Aliquota ISS    	 *				    					    					    					    					    					    					    					    					    											
    						Val( SubStr( cLinha , 1380 , 15 ) )/100 ,; //52 - Valor dos servicos *
    						Val( SubStr( cLinha , 1395 , 15 ) )/100 ,; //53 - Valor das deducaes    					    					    					    					
    						Val( SubStr( cLinha , 1410 , 15 ) )/100 ,; //54 - Valor do desconto Condicionado 
    						Val( SubStr( cLinha , 1425 , 15 ) )/100 ,; //55 - Valor do Desconto Incondicionado
    						Val( SubStr( cLinha , 1440 , 15 ) )/100 ,; //56 - Valor Cofins
    						Val( SubStr( cLinha , 1455 , 15 ) )/100,; //57 - Valor CSLL
    						Val( SubStr( cLinha , 1470 , 15 ) )/100,; //58 - Valor INSS
    						Val( SubStr( cLinha , 1485 , 15 ) )/100,; //59 - Valor IRPJ
    						Val( SubStr( cLinha , 1500 , 15 ) )/100,; //60 - Valor PIS
    						Val( SubStr( cLinha , 1515 , 15 ) )/100,; //61 - Valor outras retencaes
    						Val( SubStr( cLinha , 1530 , 15 ) )/100,; //62 - Valor ISS *
    						Val( SubStr( cLinha , 1545 , 15 ) )/100,; //63 - Valor Credito
    						SubStr( cLinha , 1560 , 01 ) ,; //64 - ISS retido ?
    						StoD( SubStr( cLinha , 1561 , 08 ) ),; //65 - Data Cancelamento
    						StoD( SubStr( cLinha , 1569 , 08 ) ),; //66 - Data Competencia    					    					    					    					    					    					    					
    						SubStr( cLinha , 1577 , 15 ) ,; //67 - Numero GUIA
    						StoD( SubStr( cLinha , 1592 , 08 ) ) ,; //68 - Data quitacao da GUIA    					    					    					    					    					
    						SubStr( cLinha , 1600 , 15 ) ,; //69 - Numero Protocolo
    						SubStr( cLinha , 1615 , 15 ) ,; //70 - Codigo Obra
    						SubStr( cLinha , 1630 , 15 ) ,; //71 - Anotacao responsabilidade tecnica
    						SubStr( cLinha , 1645 , 15 ) ,; //72 - Numero NF Substituida
    						SubStr( cLinha , 1660 , 15 ) ,; //73 - Numero NF Substituta
    						StrTran( NoAcento( AllTrim( SubStr( cLinha , 1675 , 4000 ) ) ),"u","") ; //74 - Descricao do servico  *
    		} )
    					
		//Rodapu
		ElseIf Left(cLinha,1) == "9"
        
    		aAdd(aRodape,{	Substr(cLinha,01,01)     ,; //01 - Tipo do Registro
    				 		Val(Substr(cLinha,03,08)),; //02 - Numero de linhas de detalhe do arquivo
    						Val( SubStr( cLinha , 11 , 15 ) )/100,; //03 - Valor Total servicos
    						Val( SubStr( cLinha , 26 , 15 ) )/100,; //04 - Valor Deducaes
    						Val( SubStr( cLinha , 41 , 15 ) )/100,; //05 - Valor Descontos condicionados
    						Val( SubStr( cLinha , 56 , 15 ) )/100,; //06 - Valor Descontos incondicionados
    						Val( SubStr( cLinha , 71 , 15 ) )/100,; //07 - Valor Cofins Retido
    						Val( SubStr( cLinha , 86 , 15 ) )/100,; //08 - Valor CSLL Retido 
    						Val( SubStr( cLinha , 101 , 15 ) )/100,; //09 - Valor INSS Retido
    						Val( SubStr( cLinha , 116 , 15 ) )/100,; //10 - Valor IRPJ Retido
    						Val( SubStr( cLinha , 131 , 15 ) )/100,; //11 - Valor PIS Retido
    						Val( SubStr( cLinha , 146 , 15 ) )/100,; //12 - Valor Outras Retencoes
    						Val( SubStr( cLinha , 161 , 15 ) )/100,; //13 - Valor ISS 
    						Val( SubStr( cLinha , 176 , 15 ) )/100 } ) //14 - Valor Total dos Creditos
    					    					    					    					
    					
		EndIf	   				 	

 	Case ::cPrefeitura == "Sao Paulo"
 	
	 	//Cabeualho
	 	If Left(cLinha,1) == "1"
	        
	    	aAdd(aCabec,{	Substr(cLinha,01,01)      ,; //[01] - Tipo do Registro
   	 					 	Substr(cLinha,02,03)      ,; //[02] - Versuo do Arquivo
    					 	                          ,; //[03] - Identificacao do contribuinte
    				 		                          ,; //[04] - CNPJ Contribuinte
    				 		Substr(cLinha,05,08),; //[05] - Inscricao Municipal Contribuinte
							StoD( Substr(cLinha,13,08) ),; //[06] - Periodo Inicial
    				 		StoD( Substr(cLinha,21,08) ) } ) //[07] - Periodo Final

    				 	
	  	//Notas Fiscais
	 	ElseIf Left(cLinha,1) == "2" .and. Len(cLinha) > 500
   
 		   	aAdd(aNotas,{	SubsTr( cLinha , 01 , 01 ) ,; // 01 - Tipo de Registro
    						SubStr( cLinha , 02 , 08 ) ,; //02 - Numero da nota fiscal eletronica *
    						                           ,; //03 - Status da Nota     					
    						SubStr( cLinha , 24 , 08 ) ,; //04 - Codigo de Verificacao    					
    						StoD( SubStr( cLinha , 10 , 08 ) ) ,; //05 - Data/Hora Emissao da Nota *
							SubStr( cLinha , 32 , 05 ) ,; //06 - Tipo de RPS 
   		 					SubStr( cLinha , 37 , 05 ) ,; //07 - Serie do RPS   
   		 					SubStr( cLinha , 42 , 12 ) ,; //08 - Numero do RPS 
   	 						StoD( SubStr( cLinha , 54 , 08 ) ) ,; //09 - Data Emissao RPS
    						SubStr( cLinha , 70 , 01 ) ,; //10 - CPF/CNPJ *
    						If( SubStr( cLinha , 70 , 1 ) == '2' , SubStr( cLinha , 71 , 14 ) , SubStr( cLinha , 74 , 11 ) )  ,; //11 - CPF/CNPJ *
    						SubStr( cLinha , 62 , 08 ) ,; //12 - Inscricao Municipal Prestador *
    						                            ,; //13 - Inscricao Estadual   *
    						SubStr( cLinha , 085 , 75  ) ,; //14 - Razao Social Prestador *
    						SubStr( cLinha , 085 , 75 ) ,; //15 - Nome Fantasia Prestador * 
    						SubStr( cLinha , 160 , 03 ) ,; //16 - Tipo Endereco *
    						SubStr( cLinha , 163 , 50  ) ,; //17 - Endereco Prestador *    					    					    					    					    					    					    					    					    					    											
    						SubStr( cLinha , 213 , 10 ) ,; //18 - Numero endereco *
    						SubStr( cLinha , 223 , 30 ) ,; //19 - Complmento endereco *    					    					    					    					
    						SubStr( cLinha , 253 , 30 ) ,; //20 - Bairro *
    						SubStr( cLinha , 283 , 50 ) ,; //21 - Cidade *
    						SubStr( cLinha , 333 , 02 ) ,; //22 - UF *
    						SubStr( cLinha , 335 , 08 ) ,; //23 - CEP *
    						""                          ,; //24 - Telefone *
    						SubStr( cLinha , 343 , 75 ) ,; //25 - Email *
    						SubStr( cLinha , 518 , 01 ) ,; //26 - CPF/CNPJ Tomador *
    						If( SubStr( cLinha , 518 , 1 ) == '2' , SubStr( cLinha , 519 , 14 ) , SubStr( cLinha , 522 , 11 ) )  ,; //27 - Numero CPF/CNPJ Tomador *
    						SubStr( cLinha , 533 , 08 ) ,; //28 - Inscricao Municipal Tomador *
    						SubStr( cLinha , 541 , 12 ) ,; //29 - Inscricao Estadual Tomador *
    						SubStr( cLinha , 553 , 75 ) ,; //30 - Razao Social Tomador *
    						SubStr( cLinha , 628 , 03 ) ,; //31 - Tipo de logradouro Tomador *
    						SubStr( cLinha , 631 , 50 ) ,; //32 - Endereco Tomador    			 *		    					    					    					    					    					    					
    						SubStr( cLinha , 681 , 10 ) ,; //33 - Numero Endereco Tomador *
    						SubStr( cLinha , 691 , 30 ) ,; //34 - Complemento Endereco Tomador *
							SubsTr( cLinha , 721 , 30 )  ,; //35 - Bairro Tomador *
    						NoAcento(SubStr( cLinha , 751 , 50 )) ,; //36 - Cidade Tomador *
    						SubStr( cLinha , 801 , 02 ) ,; //37 - UF Tomador     	 *				
    						SubStr( cLinha , 803 , 08 ) ,; //38 - CEP    				 *	
    						""                           ,; //39 - Telefone *
							SubStr( cLinha , 811 , 75 ) ,; //40 - Email *
    						""                           ,; //41 - Tipo de servico da Nota
    						SubStr( cLinha , 283 , 50 ) ,; //42 - Cidade de prestacao servico
    						SubStr( cLinha , 333 , 02 ) ,; //43 - UF Prestacao servico
    						""                           ,; //44 - Regime Especial de Tributacao
    						SubStr( cLinha , 418 , 01 ) ,; //45 - Simples Nacional ?
    						""                           ,; //46 - Incentivo Cultural
    						""                           ,; //47 - Cod.Servico Lista Federal
    						""                           ,; //48 - Brancos
    						""                           ,; //49 - Cod. Beneficio
    						SubStr( cLinha , 478 , 05 ) ,; //50 - Cod.Servico Lista Municipal *
    						Val( SubStr( cLinha , 483 , 04 ) )/100 ,; //51 - Aliquota ISS    	 *				    					    					    					    					    					    					    					    					    											
    						Val( SubStr( cLinha , 448 , 15 ) )/100 ,; //52 - Valor dos servicos *
    						Val( SubStr( cLinha , 463 , 15 ) )/100 ,; //53 - Valor das deducaes    					    					    					    					
    						0                                       ,; //54 - Valor do desconto Condicionado 
    						0                                       ,; //55 - Valor do Desconto Incondicionado
    						Val( SubStr( cLinha , 1052 , 15 ) )/100 ,; //56 - Valor Cofins
    						Val( SubStr( cLinha , 1097 , 15 ) )/100,; //57 - Valor CSLL
    						Val( SubStr( cLinha , 1067 , 15 ) )/100,; //58 - Valor INSS
    						Val( SubStr( cLinha , 1082 , 15 ) )/100,; //59 - Valor IRPJ
    						Val( SubStr( cLinha , 1037 , 15 ) )/100,; //60 - Valor PIS
    						0                                      ,; //61 - Valor outras retencaes
    						Val( SubStr( cLinha , 487 , 15 ) )/100,; //62 - Valor ISS *
    						Val( SubStr( cLinha , 502 , 15 ) )/100,; //63 - Valor Credito
    						SubStr( cLinha , 517 , 01 ) ,; //64 - ISS retido ?
    						StoD( SubStr( cLinha , 420 , 08 ) ),; //65 - Data Cancelamento
    						StoD( SubStr( cLinha , 10 , 08 ) ),; //66 - Data Competencia    					    					    					    					    					    					    					
    						SubStr( cLinha , 428 , 12 ) ,; //67 - Numero GUIA
    						StoD( SubStr( cLinha , 440 , 08 ) ) ,; //68 - Data quitacao da GUIA    					    					    					    					    					
    						""                                 ,; //69 - Numero Protocolo
    						SubStr( cLinha , 1154 , 12 ) ,; //70 - Codigo Obra
    						""                           ,; //71 - Anotacao responsabilidade tecnica
    						""                           ,; //72 - Numero NF Substituida
    						SubStr( cLinha , 886 , 08 ) ,; //73 - Numero NF Substituta
    						NoAcento( AllTrim( SubStr( cLinha , 1373  ) ) ) ; //74 - Descricao do servico  *
    		} )
    		
    		If Empty( aCabec[ 01 ][ 04 ] ) .And. !Empty( Atail( aNotas )[ 11 ] )
				aCabec[ 01 ][ 04 ] := Atail( aNotas )[ 11 ]    		
    		EndIf
    					
		//Rodapu
		ElseIf Left(cLinha,1) == "9"
        
    		aAdd(aRodape,{	Substr(cLinha,01,01)     ,; //01 - Tipo do Registro
    				 		Val(Substr(cLinha,02,07)),; //02 - Numero de linhas de detalhe do arquivo
    						Val( SubStr( cLinha , 09 , 15 ) )/100,; //03 - Valor Total servicos
    						Val( SubStr( cLinha , 24 , 15 ) )/100,; //04 - Valor Deducaes
    						0                                    ,; //05 - Valor Descontos condicionados
    						0                                    ,; //06 - Valor Descontos incondicionados
    						0                                    ,; //07 - Valor Cofins Retido
    						0                                    ,; //08 - Valor CSLL Retido 
    						0                                     ,; //09 - Valor INSS Retido
    						0                                     ,; //10 - Valor IRPJ Retido
    						0                                     ,; //11 - Valor PIS Retido
    						0                                     ,; //12 - Valor Outras Retencoes
    						Val( SubStr( cLinha , 39 , 15 ) )/100,; //13 - Valor ISS 
    						Val( SubStr( cLinha , 54 , 15 ) )/100 } ) //14 - Valor Total dos Creditos
    					    					    					    					
    					
		EndIf 	
 	
	OtherWise
	
		::cErro := "Layout Nao disponivel." + CRLF
		Exit

	EndCase
	    
	//Guarda o tipo da linha anterior
	cTipoAnt := Left(cLinha,1)
	
	DbSkip()
EndDo

If Select( 'ARQUIVO' ) > 0
   ARQUIVO->( DbCloseArea() )
   E_EraseArq( cArqTemp )
EndIf

FErase( cFile )

If Empty( ::cErro )
	If Len(aCabec) == 0 .or. Len(aNotas) == 0 .or. Len(aRodape)== 0
		::cErro := "O formato do arquivo selecionado u invalido." + CRLF
	ElseIf AllTrim(aCabec[1][04]) <> AllTrim(SM0->M0_CGC)    
   		::cErro := "O arquivo Nao possui informacaes dessa empresa." + CRLF
	Else
		::cErro := ""
		//Carrega o objeto com as informacaes do arquivo
		::oIntArq:Carrega(aCabec,aNotas,aRodape)
	EndIf
EndIf
	
Return .T.


/*
Metodo      : LoadNFPS
Classe      : GTIntNfServ
Descricao   : Carrega as informacaes da NF, baseado na leitura dos arquivos.
Autor       : Leandro Brito
Data        : 02/03/2015
*/ 
*-----------------------------------*
Method LoadNFPS() Class GTIntNfServ
*-----------------------------------*
Local lExistCli := .F.

Local cCgcCli  := ""
Local cCodCli  := ""
Local cLojaCli := ""
Local cNFe     := ""
Local cSerie   := ""
Local cEmis    := ""
Local cNaturez := ""
Local cCond    := ""
Local nI := 0
         
Local aDetalhes := {}
Local aItens    := {}

//Carrega as informacaes do arquivo.
aDetalhes := aClone(::oIntArq:aDetalhes)


For nI:=1 To Len(aDetalhes)

	//Tratamento para retornar o CPF ou CNPJ do Cliente
    cCgcCli := PadR( aDetalhes[nI][27] , Len( SA1->A1_CGC ) ) 

	//Retorna o Cudigo do Fornecedor
	SA1->(DbSetOrder(3))
	If SA1->(DbSeek(xFilial("SA1")+cCgcCli))
    	cCodCli  := SA1->A1_COD
    	cLojaCli := SA1->A1_LOJA
    	cNaturez := "" //SA1->A1_NATUREZ
    	cCond    := "" //SA1->A1_COND
    	lExistCli := .T.
	Else
		cCodCli  := ""
		cLojaCli := ""
		cNaturez := ""
		cCond    := ""
		lExistCli := .F.
	EndIf

    //Carrega o numero da nota com 6 digitos
	cNFe   := Right(AllTrim(aDetalhes[nI][02]),6)

	//Carrega a Serie da nota.
	cSerie := ""

	//Carrega a data de emissuo da nota
	cEmis  := DtoS(aDetalhes[nI][05])

	//Verifica se a nota ju estu cadastrada no sistema.
	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf

	BeginSql Alias 'TMP'
		SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_COND
		FROM %table:SF2%
		WHERE %notDel%
		  AND F2_FILIAL = %xFilial:SF2%
		  AND F2_DOC = %exp:cNFe%
		  AND F2_CLIENTE = %exp:cCodCli%
		  AND F2_LOJA = %exp:cLojaCli%
	EndSql

	TMP->(DbGoTop())
	
	//Encontrou no sistema
	If TMP->(!EOF())
	
	    //Carrega o array de notas fiscais
		aAdd(::aNotas,{ .T.                  ,; //Indicador de nota ju existente no sistema
					 	.F.                  ,; //Marcacao de integracao da Nota
					 	TMP->F2_DOC          ,; //Numero da Nota Fiscal
					 	TMP->F2_SERIE        ,; //Serie da Nota Fiscal
					 	StoD(TMP->F2_EMISSAO),; //Data da Nota Fiscal
					 	lExistCli            ,; //Indicador de fornecedor ju existente no sistema
					 	cCodCli			     ,; //Cudigo do Fornecedor
					 	cLojaCli			 ,; //Loja do Fornecedor
					 	aDetalhes[nI][74]    ,; //Descricao do servico
					 	TMP->F2_COND                   ,; //Condicao de Pagamento
					 	cNaturez             ,; //Natureza
					 	aItens     } ) //Itens da Nota
	
	
	    //Carrega o array de amarracao da nota.
    	aAdd(::aNfPos, {TMP->F2_DOC,nI})
	
	//Nao encontrou no sistema	
	Else

	    //Carrega o array de notas fiscais
		aAdd(::aNotas,{ .F.                 ,; //Indicador de nota ju existente no sistema
					 	.F.                 ,; //Marcacao de integracao da Nota
					 	Right(aDetalhes[nI][02],6)	,; //Numero da Nota Fiscal
					 	Left(aDetalhes[nI][07],Len( SF2->F2_SERIE ) )	                ,; //Serie da Nota Fiscal
					 	aDetalhes[nI][05]	,; //Data da Nota Fiscal
					 	lExistCli           ,; //Indicador de fornecedor ju existente no sistema
					 	cCodCli	        	,; //Cudigo do Fornecedor
					 	cLojaCli    		,; //Loja do Fornecedor
					 	aDetalhes[nI][74]   ,; //Descricao do servico
					 	cCond                  ,; //Condicao de Pagamento
					 	cNaturez            ,; //Natureza
					 	aItens            } )  // Itens da Nota
   
		    //Carrega o array de amarracao da nota.
    	aAdd(::aNfPos,{Right(aDetalhes[nI][02],6),nI})
	
	EndIf
Next

//Ordena o array pelo numero das notas fiscais
aSort(::aNotas,,,{|x,y| x[1] < y[1]})

//Fecha o alias da tabela temporuria
If Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf        

Return

/*
Funcao      : ConfigNFPS
Descricao   : Tela de Configuracao da Nota Fiscal
Autor       : Leandro Brito 
Observacaoes: Adaptado a partir da funcao PreConfigNF
Data        : 04/03/2015
*/ 
*-----------------------------------------------------*
Static Function ConfigNFPS(oGTIntNfServ,aNf,nPosNotas)
*-----------------------------------------------------*          
Local lRet   := .F.
Local lGrava := .F.

Local cFieldOk := ""
Local cLinOk   := ""

Local nI      := 0
Local nPos    := 0
Local nPosAux := 0
Local nPosCod := 0
Local nPosQtd := 0
Local nPosVUn := 0
Local nPosTot := 0
Local nPosDel := 0

Local aSizeAut  := {}
Local aCposEnc  := {}
Local aCposIt   := {}
Local aCpoGDa   := {}
Local aHeader   := {}
Local aCols     := {}
Local aItens    := {}
Local aFolder   := {"Nota Fiscal","Cliente"}
Local aAlter    := {}

Local bOk     := {|| If(ValPreConfig(oGTIntNfServ,aNf),(lGrava:=.T.,oDlg:End()),)}
Local bCancel := {|| oDlg:End()}

Local oDlg
Local oLayer
Local oCabec
Local oItens
Local oMsgBar
Local oFontBar
Local oBarItem
Local cItem 

Local lInclui := ( Len( oGTIntNfServ:aNotas[ nPosNotas ][ 12 ] ) == 0 )

Private oEnch 
Private oMGet
Private oNfServ := oGTIntNfServ
//Maximizacao da tela em relacao a area de trabalho
aSizeAut := MsAdvSize()	

//Dados da Nota Fiscal de servico
/*
Estrutura do vetor
[1] - Titulo	
[2] - campo	
[3] - Tipo	
[4] - Tamanho	
[5] - Decimal	
[6] - Picture	
[7] - Valid	
[8] - Obrigat	
[9] - Nivel	
[10]- Inicializador Padruo	
[11]- F3         	
[12]- when	
[13]- visual	
[14]- chave	
[15]- box	
[16]- folder	
[17]- nao alteravel	
[18]- pictvar	            	
[19]- gatilho
*/     
//Pasta Nota Fiscal
aAdd(aCposEnc,{"Nota Fiscal","NF"     ,"C",020,0,""                 ,"",.T.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Serie","SERIE"     ,"C",003,0,""                    ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Data"       ,"DTNF"   ,"D",008,0,"@D"               ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Vl.servicos","VALOR"  ,"N",012,2,"@E 999,999,999.99","",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Cod.servico","CODSERV","C",Len(SB1->B1_CODISS),0,"@!"            ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Aliq.ISS"   ,"ALIQISS","N",004,2,"@E 99.99"         ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Valor ISS"  ,"VALISS" ,"N",012,2,"@E 999,999,999.99","",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"servicos."  ,"SERV"   ,"M",255,0,"@!"               ,"",.F.,1,"",""   ,"",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Cond. Pagto","COND"   ,"C",003,0,""                 ,"",.T.,1,"","SE4","",.F.,.F.,"",1,.F.,"",""})
aAdd(aCposEnc,{"Natureza"   ,"NATUREZ","C",010,0,""                 ,"",.T.,1,"","SED","",.F.,.F.,"",1,.F.,"",""})

//Pasta Cliente
aAdd(aCposEnc,{"Codigo"     ,"CODCLI" ,"C",06,0,"@!"               ,"",.T.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Loja"       ,"LOJCLI" ,"C",02,0,"@!"               ,"",.T.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"CPF/CNPJ"   ,"CGCCLI" ,"C",14,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Nome"       ,"NOMECLI","C",75,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Insc.Munic.","IMCLI"  ,"C",08,0,"99999999"         ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Endereco"   ,"ENDCLI" ,"C",80,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Bairro"     ,"BAICLI" ,"C",30,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Cidade"     ,"CIDCLI" ,"C",50,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"Estado"     ,"ESTCLI" ,"C",02,0,"@!"               ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})
aAdd(aCposEnc,{"CEP"        ,"CEPCLI" ,"C",09,0,"99999-999"        ,"",.F.,1,"","","",.F.,.F.,"",2,.F.,"",""})

//Retorna a posicao da Nf no array de detalhes do arquivo 
nPos := oGTIntNfServ:RetPosNf(aNf[3])

//Carrega as variaveis de memuria

If nPos > 0 
	M->NF      := aNf[3]
	M->DTNF    := aNf[5]
	M->SERIE   := aNf[4]
	M->VALOR   := oGTIntNfServ:oIntArq:aDetalhes[nPos][52]
	M->CODSERV := oGTIntNfServ:oIntArq:aDetalhes[nPos][50]
	M->ALIQISS := oGTIntNfServ:oIntArq:aDetalhes[nPos][51]
	M->VALISS  := oGTIntNfServ:oIntArq:aDetalhes[nPos][62]
	M->SERV    := oGTIntNfServ:oIntArq:aDetalhes[nPos][74]
	M->COND    := oGTIntNfServ:cCondDef //If( !Empty( aNf[11] ) , aNf[11] ,  Space(3) )
	M->NATUREZ := oGTIntNfServ:cNatDef //If(!Empty(aNf[12]),aNf[12],Space(10)) 
	M->CGCCLI  := oGTIntNfServ:oIntArq:aDetalhes[nPos][27]
	M->NOMECLI := oGTIntNfServ:oIntArq:aDetalhes[nPos][30]
	M->IMCLI   := oGTIntNfServ:oIntArq:aDetalhes[nPos][28]
	M->ENDCLI  := oGTIntNfServ:oIntArq:aDetalhes[nPos][32]
	M->BAICLI  := oGTIntNfServ:oIntArq:aDetalhes[nPos][35]
	M->CIDCLI  := oGTIntNfServ:oIntArq:aDetalhes[nPos][36]	
	M->ESTCLI  := oGTIntNfServ:oIntArq:aDetalhes[nPos][37]	
	M->CEPCLI  := oGTIntNfServ:oIntArq:aDetalhes[nPos][38]
	M->CODCLI  := ""
    M->LOJCLI  := ""
	
	//Verifica se o cliente ju existe na base
	If lInclui
		If aNf[6]
			M->CODCLI  := aNf[7]
	    	M->LOJCLI  := aNf[8]
	
		Else
			//Verifica se o mesmo fornecedor ju estu sendo utilizado em outra nota marcada
			For nI:=1 To Len(oGTIntNfServ:aNotas)
	
				//Verifica se Nao u a nota que estu sendo marcada no momento
				If nI <> nPosNotas
					
					//Verifica se a nota estu marcada
					If oGTIntNfServ:aNotas[nI][2]
	
						//Retorna a posicao da nota no arquivo
						nPosAux := oGTIntNfServ:RetPosNf(oGTIntNfServ:aNotas[nI][3])
	
						//Verifica se o CPF/CNPJ u o mesmo					
						If oGTIntNfServ:oIntArq:aDetalhes[nPos][27] == oGTIntNfServ:oIntArq:aDetalhes[nPosAux][27] 
							
							M->CODCLI := oGTIntNfServ:aNotas[nI][7]
							M->LOJCLI := oGTIntNfServ:aNotas[nI][8]
							Exit					
						EndIf 
					EndIf
				EndIf
			Next 		
			
			If Empty(M->CODCLI) .and. Empty(M->LOJCLI)
			
				M->CODCLI  := GetSXENum("SA1","A1_COD")                                                                                                       
	    		M->LOJCLI  := "01"
	   		EndIf
		EndIf
	EndIf	
EndIf

//Verifica se o forncedor Nao existe na base
If !aNf[6]
	aAdd(aAlter,"CODCLI")
	aAdd(aAlter,"LOJCLI")
EndIf

aAdd(aAlter,"COND")
aAdd(aAlter,"NATUREZ")
aAdd(aAlter,"SERIE")
//Dados dos itens da nota

//Define a estrutura da tabela temporuria
aCposIt := {{"ITEM"  ,"C",04,0},;
          	{"CODIGO","C",15,0},;
			{"QUANT" ,"N",11,2},;
        	{"VUNIT" ,"N",14,2},;
         	{"TOTAL" ,"N",14,2}}

//            TITULO        ,CAMPO   ,PICTURE             ,TAMANHO,DECIMAL,VALID,,TIPO,F3   ,,CBOX,RELACAO,WHEN   
aAdd(aHeader,{"Item"        ,"ITEM"  ,"9999"             ,04     ,0      ,".T." ,,"C" ,     ,,""  ,""     ,""  })
aAdd(aHeader,{"Codigo"      ,"CODIGO","@!"               ,15     ,0      ,".T." ,,"C" ,"ALT",,""  ,""     ,""  })
aAdd(aHeader,{"Tipo Saida","TES"   ,"@9"               ,3      ,0      ,".T." ,,"C" ,"SF4",,""  ,""     ,""  })
aAdd(aHeader,{"Quant."      ,"QUANT" ,"@E 99999999.99"   ,11     ,2      ,".T." ,,"N" ,     ,,""  ,""     ,""  })
aAdd(aHeader,{"Valor Unit." ,"VUNIT" ,"@E 999,999,999.99",14     ,2      ,".T." ,,"N" ,     ,,""  ,""     ,""  })
aAdd(aHeader,{"Valor Total" ,"TOTAL" ,"@E 999,999,999.99",14     ,2      ,".T." ,,"N" ,     ,,""  ,""     ,""  })

nPosCod := aScan(aHeader,{|x| x[2] == "CODIGO"})
nPosQtd := aScan(aHeader,{|x| x[2] == "QUANT"})
nPosVUn := aScan(aHeader,{|x| x[2] == "VUNIT"})
nPosTot := aScan(aHeader,{|x| x[2] == "TOTAL"})
nPosTes := aScan(aHeader,{|x| x[2] == "TES"})
nPosDel := Len( aHeader ) + 1	
If ( lInclui ) //** Inclusao

	aCols:={Array(Len(aHeader)+1)}
	aCols[1,Len(aHeader)+1]:=.F.	
	SB1->( DbSetOrder( 1 ) )
	For nI:=1 To Len(aHeader)
		If aHeader[nI][8] == "C"
			aCols[1][nI] := Space(aHeader[nI][4])
		ElseIf aHeader[nI][8] == "N"
			aCols[1][nI] := 0
		ElseIf aHeader[nI][8] == "D"
			aCols[1][nI] := CtoD("  /  /  ")
		EndIf
	
		//Carrega o primeiro item
		If aHeader[nI][2] == "ITEM"
			aCols[1][nI] := "0001"
		EndIf
		
		//Carrega a quantidade inicial
		If aHeader[nI][2] == "QUANT"
			aCols[1][nI] := 1
		EndIf
		
		//Carrega o valor uniturio com o valor total dos servicos
		If aHeader[nI][2] == "VUNIT"
			aCols[1][nI] := M->VALOR 
		EndIf
	
		//Carrega o total com o valor total dos servicos
		If aHeader[nI][2] == "TOTAL"
			aCols[1][nI] := M->VALOR 
		EndIf
		
		//Carrega o produto default sendo codigo do ISS 
		If aHeader[nI][2] == "CODIGO"
			If SB1->( DbSeek( xFilial() + PadR( M->CODSERV , Len( SB1->B1_COD ) ) ) ) 
				aCols[1][nI] := SB1->B1_COD
			EndIf	 
		EndIf
		
		If aHeader[nI][2] == "TES"
			//If SB1->( DbSeek( xFilial() + PadR( M->CODSERV , Len( SB1->B1_COD ) ) ) ) 
				aCols[1][nI] := oGTIntNfServ:cTesDef //SB1->B1_TS
			//EndIf	 
		EndIf	
			
	Next

Else  //** Leandro Brito - Tratamento alteracao 
	M->SERIE 		:= oGTIntNfServ:aNotas[ nPosNotas ][ 04 ] 
	M->COND  		:= oGTIntNfServ:aNotas[ nPosNotas ][ 10 ]
	M->NATUREZ  	:= oGTIntNfServ:aNotas[ nPosNotas ][ 11 ]
	M->CODCLI  	:= oGTIntNfServ:aNotas[ nPosNotas ][ 07 ]
	M->LOJCLI  	:= oGTIntNfServ:aNotas[ nPosNotas ][ 08 ]
	
	cItem := StrZero( 0 , 4 )
	For nI := 1 To Len( oGTIntNfServ:aNotas[ nPosNotas ][ 12 ] )
		Aadd( aCols , Array( Len( aHeader ) + 1 ) )
		Atail( aCols )[ 1 ] := Soma1( cItem ) 
		Atail( aCols )[ nPosCod ] := oGTIntNfServ:aNotas[ nPosNotas ][ 12 ][ nI ][ 1 ] //* Codigo 
		Atail( aCols )[ nPosQtd ] := oGTIntNfServ:aNotas[ nPosNotas ][ 12 ][ nI ][ 2 ] //* Quantidade
		Atail( aCols )[ nPosVUn ] := oGTIntNfServ:aNotas[ nPosNotas ][ 12 ][ nI ][ 3 ] //* Valor Unitario
		Atail( aCols )[ nPosTot ] := oGTIntNfServ:aNotas[ nPosNotas ][ 12 ][ nI ][ 4 ] //* Valor Total
		Atail( aCols )[ nPosTes ] := oGTIntNfServ:aNotas[ nPosNotas ][ 12 ][ nI ][ 5 ] //* TES
	 	Atail( aCols )[ nPosDel ] := .F.
	 Next  

EndIf	

//Define os campos que seruo editaveis
aCpoGDa := {"CODIGO","QUANT","VUNIT","TES","NATUREZ"}

//Define a funcao de validacao dos campos
cFieldOk := "U_ValCpoItCon"

//Define a funcao de validacao das linhas]
cLinOk := "U_ValLinItCon"

//Tela de Configuracao da Nota Fiscal
DEFINE MSDIALOG oDlg FROM aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] PIXEL TITLE "Configuracaes da Nota Fiscal" 

//Cria o objeto FWLayer
oLayer := FWLayer():new()

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botuo de fechar
oLayer:init(oDlg,.T.)

//Cria as linhas do Layer
oLayer:addLine("Lin01",50,.F.)
oLayer:addLine("Lin02",50,.F.)

//Cria as colunas do Layer
oLayer:addCollumn('Col01',100,.F.,"Lin01")
oLayer:addCollumn('Col02',100,.F.,"Lin02")

//Adiciona Janelas as colunas
oLayer:addWindow('Col01','L1_Win01','Dados da Nota Fiscal',100,.T.,.T.,{|| },"Lin01",{|| })
oLayer:addWindow('Col02','L2_Win01','Produtos'            ,100,.T.,.T.,{|| },"Lin02",{|| })

//Retorna o painel de Dados da NFS
oCabec:= oLayer:GetWinPanel('Col01','L1_Win01',"Lin01") 

//Exibe a enchoice com os dados da nota fiscal.
oEnch := MsMGet():New(,,3,,,,,{000,000,400,600},aAlter,,,,,oCabec,.F.,.T.,,,,,aCposEnc,aFolder,.T.)
oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT

//Retorna o painel de Itens da NFS
oItens:= oLayer:GetWinPanel('Col02','L2_Win01',"Lin02")      

//Exibe o grid para inclusuo dos itens da nota
oMGet := MsNewGetDados():New(0,0,oItens:nHeight,oItens:nWidth,GD_INSERT+GD_UPDATE+GD_DELETE,cLinOk,"AllwaysTrue","+ITEM",aCpoGDa,1,,cFieldOk,,,oItens,aHeader,aCols)    
oMGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//Define a fonte da barra de status
oFontBar := TFont():New('Courier New',,-14,.T.)

//Exibe a barra de status
oMsgBar  := TMsgBar():New(oDlg,"integracao de Nota Fiscal de servico",.F.,.F.,.F.,.F.,RGB(255,255,255),,oFontBar,.F.)
oBarItem := TMsgItem():New( oMsgBar,"Arquivo de integracao: " + oGTIntNfServ:cArquivo, 100,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bOK , bCancel )

aItens := {}

//Marca a nota fiscal para integracao.
If lGrava

	//Grava o cudigo do cliente
	If !aNf[6] //Verifica se o cliente ainda Nao estu cadastrado.
		oGTIntNfServ:aNotas[nPosNotas][7] := M->CODCLI
		oGTIntNfServ:aNotas[nPosNotas][8] := M->LOJCLI
	EndIf		
    
    //Grava a condicao de pagamento
    oGTIntNfServ:aNotas[nPosNotas][10] := M->COND
    
    //Grava a natureza
    oGTIntNfServ:aNotas[nPosNotas][11] := M->NATUREZ
    
    //Grava a serie
    oGTIntNfServ:aNotas[nPosNotas][04] := M->SERIE   
    aNf[4] := M->SERIE   
       
    
	//Grava os itens da Nota
	For nI:=1 To Len(oMGet:aCols)
		If !oMGet:aCols[nI][nPosDel]
			aAdd(aItens,{oMGet:aCols[nI][nPosCod],; //Cudigo do Produto
				   		 oMGet:aCols[nI][nPosQtd],; //Quantidade
						 oMGet:aCols[nI][nPosVUn],; //Valor Uniturio
						 oMGet:aCols[nI][nPosTot],; //Valor Total
						 oMGet:aCols[nI][nPosTes]}) //TES
		EndIf			
    Next

	//Marcacao do item
	lRet := .T.

Else
	If __lSx8
		SA1->(RollBackSX8())
   EndIf
EndIf

//Grava os itens no objeto.
oGTIntNfServ:GravaItens(nPosNotas,aItens)

Return lRet    

/*
Metodo      : IntegraNFPS
Classe      : GTIntNfServ
Descricao   : Realiza a integracao das notas fiscais.
Autor       : Leandro Diniz de Brito
Data        : 09/03/2015
*/
*----------------------------------------*
Method IntegraNFPS(oMeter) Class GTIntNfServ
*----------------------------------------*
Local lGravou := .F.

Local cLog     := ""
Local cPathLog := AllTrim(GetTempPath())

Local nI     := 0
Local nP     := 0
Local nPosNf := 0

Local aCab     := {}
Local aItens   := {}
Local aDet	   := {}	
Local aCli    := {}
Local aInfoLog := {}
Local nLenCGC  := Len( SA1->A1_CGC )
Local nLenMun  := Len( CC2->CC2_MUN )
Local nLenCli  := Len( SA1->A1_COD )
Local nLenLoj  := Len( SA1->A1_LOJA )
Local oLog

Local lContinua := .T.
Local lEstoque
Local cItem
Local i 
Local cSerie
Local cRet 
Local lPais := SA1->( FieldPos( 'A1_CODPAIS' ) ) > 0  
Local cCodMun
Local cEst


Private 	aPvlNfs:={},aBloqueio:={}


//Atualiza o valor total da regua.
oMeter:SetTotal(Len(::aNotas))

For nI:=1 To Len(::aNotas)
    
	aCli  := {}
	aCab   := {}
	aDet   := {}
	aItens := {}

	oMeter:Set(nI)

	//Verifica se a nota foi marcada para integracao
	If ::aNotas[nI][2]
        
        nPosNf := Self:RetPosNf(::aNotas[nI][3])

	    //Verifica se o cliente seru incluudo.
		SA1->( DbSetOrder( 3 ) )
		If SA1->( !DbSeek( xFilial() + PadR( ::oIntArq:aDetalhes[nPosNf][27] , nLenCGC ) ) )
			SA1->( DbSetOrder( 1 ) )
			::aNotas[nI][7] := PadR( ::aNotas[nI][7] , nLenCli )
			::aNotas[nI][8] := PadR( ::aNotas[nI][8] , nLenLoj )		
				
			If Empty( AllTrim( ::aNotas[nI][7] ) ) .Or. ;
				SA1->( DbSeek( xFilial() + ::aNotas[nI][7] + ::aNotas[nI][8] ) )
				
				cCodCli := ::aNotas[nI][7]
				::aNotas[nI][8] := '01' 

				
				While SA1->( DbSeek( xFilial() + cCodCli + ::aNotas[nI][8] ) )
					cCodCli := PadR( GetSxeNum( 'SA1' , 'A1_COD' ) , nLenCli ) 
					ConfirmSx8()
				EndDo
				
				::aNotas[nI][7] := cCodCli
				
			EndIf	 
			
			aCli := {	{"A1_COD"   , ::aNotas[nI][7]                ,nil},;
						{"A1_LOJA"  , ::aNotas[nI][8]                ,nil},;
		          	 	{"A1_PESSOA"  ,If(Len(AllTrim( ::oIntArq:aDetalhes[nPosNf][27])) <14,"F","J"),nil},;
		          	 	{"A1_TIPO"  ,'F',nil},;		          	 	
            	       {"A1_NOME"  ,Upper(::oIntArq:aDetalhes[nPosNf][30]),nil},;
                    	{"A1_NREDUZ",Upper(::oIntArq:aDetalhes[nPosNf][30]),nil},;
                    	{"A1_INSCR"   ,If( Val( ::oIntArq:aDetalhes[nPosNf][29] ) > 0 , ::oIntArq:aDetalhes[nPosNf][29] , '' ) ,nil},;
                    	{"A1_INSCRM"   ,If( Val( ::oIntArq:aDetalhes[nPosNf][28] ) > 0 , ::oIntArq:aDetalhes[nPosNf][28] , '' ),nil},;                    	
                    	{"A1_END"   ,Upper(AllTrim( ::oIntArq:aDetalhes[nPosNf][32] ) + "," + AllTrim( ::oIntArq:aDetalhes[nPosNf][33] )),nil},;
                    	{"A1_EST"   ,If( Empty(::oIntArq:aDetalhes[nPosNf][37]),AllTrim( GetMV("MV_ESTADO") ) , ::oIntArq:aDetalhes[nPosNf][37] ) , ,nil},;
                    	{"A1_MUN"   ,Upper(::oIntArq:aDetalhes[nPosNf][36]),nil},;
                    	{"A1_BAIRRO",Upper(::oIntArq:aDetalhes[nPosNf][35]),nil},;
                    	{"A1_CEP"   ,::oIntArq:aDetalhes[nPosNf][38],nil},;
                    	{"A1_COND"   ,::cCondDef,nil},;
                    	{"A1_CONTA"   ,::cContaDef,nil},;                    	
                    	{"A1_NATUREZ"   ,::cNatDef,nil},;
                    	{"A1_EMAIL"   ,::oIntArq:aDetalhes[nPosNf][40],nil},;                    	
                    	{"A1_CGC"   ,::oIntArq:aDetalhes[nPosNf][27],nil} }
                    	

			If !Empty( ::oIntArq:aDetalhes[nPosNf][36] ) .And. ;
				CC2->( DbSetOrder( 2 ) , DbSeek( xFilial() + PadR( Upper( ::oIntArq:aDetalhes[nPosNf][36] ) , nLenMun ) ) )
				cCodMun := ""  
				cEst := aCli[ Ascan( aCli , { | x | x[ 1 ] == 'A1_EST' } ) ][ 2 ] 
				While CC2->( !Eof() .And. CC2_FILIAL + CC2_MUN == xFilial( 'CC2' ) + PadR( Upper( ::oIntArq:aDetalhes[nPosNf][36] ) , nLenMun ) )
					If AllTrim( CC2->CC2_EST ) == AllTrim( cEst )
						cCodMun := CC2->CC2_CODMUN
						Exit
					EndIf
					CC2->( DbSkip() )
				EndDo 
				If !Empty( cCodMun )
					Aadd( aCli , { 'A1_COD_MUN' , AllTrim( cCodMun ) , Nil } )				
				EndIf
			EndIf
			
			If lPais
				Aadd( aCli , { 'A1_CODPAIS' , '01058' , Nil } )	
			EndIf			     
			                   	

			//Realiza a integracao
			Begin Transaction
		 		lMsErroAuto := .F.
	            
				//integracao do Cliente.
		   		CC2->( DbSetOrder( 1 ) ) 
		   		MSExecAuto({|x,y| Mata030(x,y)},aCli,3)
	
				If lMsErroAuto
					cLog += MostraErro(cPathLog)
	
		   			DisarmTransaction()
	   		
		   		Else
		   			cLog += "Cliente "+ ::aNotas[nI][7] +" - " + ::aNotas[nI][8] + " integrado com sucesso."+CRLF
		   			
		   			lGravou := .T.
		   			
		   			//Adiciona o detalhe do log.
		   			aAdd(aInfoLog,{"SA1",1,xFilial("SA1")+::aNotas[nI][7]+::aNotas[nI][8],"I"})
		   			
	   			EndIf             	
            End Transaction        	
                    	
        ElseIf ( AllTrim( SA1->A1_COD ) <> AllTrim( ::aNotas[nI][7] ) ) .Or. ( AllTrim( SA1->A1_LOJA ) <> AllTrim( ::aNotas[nI][8] ) )
				::aNotas[nI][7] := 	SA1->A1_COD		 
				::aNotas[nI][8] :=   SA1->A1_LOJA
                    	
        EndIf
        
  		If !Empty( ::oIntArq:aDetalhes[nPosNf][05] ) //** Emissao NF
  			dDataBase := ::oIntArq:aDetalhes[nPosNf][05]
  		EndIf	
        /*
        	** Grava Pedido de Venda 
        */
       lContinua := .T.
		aCab := { ;
        			{ 'C5_NUM' , ::aNotas[nI][3] , Nil } ,;        			
        			{ 'C5_TIPO' , 'N' , Nil } ,;
        			{ 'C5_CLIENTE' , ::aNotas[nI][7] , Nil } ,;
					{ 'C5_LOJACLI' , ::aNotas[nI][8] , Nil } ,;
        			{ 'C5_CONDPAG' , ::aNotas[nI][10] , Nil } ,;
        			{ 'C5_EMISSAO' , dDataBase , Nil } ;
			      }
       
       lEstoque := .F.  			
		cItem    := Replicate( '0' , Len( SC6->C6_ITEM ) )
		For nP:=1 To Len(::aNotas[nI][12])
		
		    /*
		    **	Avalia se existe alguma TES que movimenta estoque, neste caso grava somente pedido de venda 
		    */
		    If !lEstoque
		    	lEstoque := ( Posicione( 'SF4' , 1 , xFilial( 'SF4' ) + ::aNotas[nI][12][1][5] , 'F4_ESTOQUE' ) == 'S' )
		    EndIf
		    	
			cItem  := Soma1( cItem )
			aItens := { { "C6_ITEM" , cItem , Nil  } ,;
							{"C6_PRODUTO"  ,::aNotas[nI][12][nP][1],Nil},;
							{"C6_QTDVEN",::aNotas[nI][12][nP][2],Nil},;
							{"C6_QTDLIB",::aNotas[nI][12][nP][2],Nil},;			
							{"C6_PRCVEN",::aNotas[nI][12][nP][3],Nil},; 		
							{"C6_VALOR",::aNotas[nI][12][nP][4],Nil},;
							{"C6_TES"  ,::aNotas[nI][12][nP][5],Nil}}
			
			aAdd(aDet,aItens) 		
		Next
		
		//Realiza a integracao
		Begin Transaction
	 		lMsErroAuto := .F.
	        
			//integracao da nota de entrada
		   	MsExecAuto({|x,y,z,w|Mata410(x,y,z)},aCab,aDet,3)
	
			If lMsErroAuto
				lContinua := .F.
				cLog += MostraErro(cPathLog)
	
		   		DisarmTransaction()
	   		
	   		Else
	   			cLog += "Pedido de Venda "+ Right(::aNotas[nI][03],6) + " integrado com sucesso."+CRLF

	   			lGravou := .T.	   			

	   			//Adiciona o detalhe do log.
	   			aAdd(aInfoLog,{"SC5",1,xFilial("SC5")+Right(::aNotas[nI][03],6),"I"})

	   		EndIf   
	
		End Transaction
		
		/*
			** Caso gravou pedido de venda e a TES nao movimenta estoque, gera nota fiscal de saida ( Prestacao de servicos ). 
		*/
		
		If lContinua .And. !lEstoque
		
			/*
				** Liberacao do Pedido de Venda
			*/
			SC5->( DbSetOrder( 1 ) )
			SC5->( DbSeek( xFilial() + ::aNotas[nI][3] ) ) 
			aPvlNfs:={} ;aBloqueio:={}
			Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
			Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
          
          If !Empty( aBloqueio )
             
             /*
             		** Se houve algum bloqueio nao gera NF
             */
             For i := 1 To Len( aBloqueio )
                cLog += "Pedido " + aBloqueio[ i ][ 1 ] + " - Produto " + aBloqueio[ i ][ 4 ] + " com bloqueio de credito. "  
             Next
          
          Else
          
	          /*
    	      		** Gera Nota Fiscal de Saida
       	   */
				//Private cGtNumNf := PadL( AllTrim( ::aNotas[nI][03] ) , Len( SC5->C5_NUM ) , '0' ) 
				cRet := ""
				If SX5->( DbSetOrder( 1 ), DbSeek( xFilial() + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( ::aNotas[nI][04] , Len( SX5->X5_CHAVE ) ) ) )
					
					SX5->( RecLock( "SX5" , .F. ) )
					SX5->X5_DESCRI := AllTrim( ::aNotas[nI][03] )
					SX5->( MSUnlock() )
					
					cRet := MaPvlNfs( aPvlNfs ,;
					          ::aNotas[nI][04] ,;
					          ::lMostraLan ,; //** Mostra Lancamentos Contabeis
					          .F. ,; //** Aglutina Lanuamentos
					          ::lContOnline ,; //** Cont. On Line ?
					          .F. ,; //** Cont. Custo On-line ?
					          .F. ,; //** Reaj. na mesma N.F.?
					          3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
					          1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
					          .F.,;  //** Atualiza Cli.X Prod?
					          .F. ,,,,,,; //** Ecf ?
					          dDataBase )
				Else
						cLog += "Nota Fiscal "+ cRet + " NAO gerada . Serie " + ::aNotas[nI][04] + " nao parametrizada no sistema."+CRLF	
				EndIf		
				
				          
				If !Empty( cRet )
					cLog += "Nota Fiscal "+ cRet + " gerada com sucesso."+CRLF

	   				lGravou := .T.	   			

	   				//Adiciona o detalhe do log.
	   				aAdd(aInfoLog,{"SF2",1,xFilial("SF2")+Right(::aNotas[nI][03],6),"I"})
	   				
				Else
					cLog += "Nota Fiscal "+ cRet + " NAO gerada ."+CRLF				
				
				EndIf	   								                    
          
          EndIf
					
		
		
		EndIf
        

	EndIf
	
Next

//Grava o log, caso houve gravacao.
If lGravou                         
	oLog := GTIntLog():New(::cArquivo,::cContArq,"GTOBJ002",cLog,aInfoLog)	
EndIf

While __lSx8
	SA1->(ConfirmSX8())
EndDo
Return cLog
/*
Funcao..............: Job02Mark
Objetivo............: Efetuar marca todos da tela de itens
Autor...............: Leandro Diniz de Brito 
*/
*-----------------------------------------------*
User Function Job02Mark( oGTIntNfServ , aNfs )
*-----------------------------------------------*
Local nPos 
Local cCodProd

Local cTes
Local nPosNotas 

Local nLenCGC := Len( SA1->A1_CGC )


SA1->( DbSetOrder( 3 ) )
SB1->( DbSetOrder( 1 ) )
For nPosNotas := 1 To Len( oGTIntNfServ::aNotas ) 

	If oGTIntNfServ::aNotas[ nPosNotas ][ 1 ]
		Loop
	EndIf
		
	nPos := oGTIntNfServ:RetPosNf(oGTIntNfServ::aNotas[nPosNotas][3])

	If nPos > 0

		If !oGTIntNfServ::aNotas[ nPosNotas ][ 2 ]
			
			
			cCodProd := ''
			If SB1->( DbSeek( xFilial() + PadR( oGTIntNfServ:oIntArq:aDetalhes[nPos][50] , Len( SB1->B1_COD ) ) ) ) 
				cCodProd := SB1->B1_COD
			EndIf
			
		
/*		
			If !Empty( cCodProd ) .And. !Empty( oGTIntNfServ:aNotas[ nPosNotas ][ 10 ] ) .And. ;
	   			!Empty( cTes ) .And. !Empty( oGTIntNfServ:aNotas[ nPosNotas ][ 11 ] )

	   			oGTIntNfServ:aNotas[ nPosNotas ][ 12 ] := { { cCodProd , 1 , oGTIntNfServ:oIntArq:aDetalhes[nPos][52] , oGTIntNfServ:oIntArq:aDetalhes[nPos][52] , cTes } }
    		   	aNfs[ nPosNotas ][ 2 ] := .T.
				oGTIntNfServ::aNotas[ nPosNotas ][ 2 ]  := .T.     	
	       EndIf	
*/
	       
			If !Empty( cCodProd ) .And. ;                  		//** Codigo Produto
				!Empty( oGTIntNfServ:cContaDef ) .And. ;   		//** Conta Contabil Default
	   			!Empty( oGTIntNfServ:cTesDef ) .And. ;     		//** Tes Default
	   			!Empty( oGTIntNfServ:cNatDef ) .And. ;     		//** Natureza Default
				!Empty( oGTIntNfServ:cCondDef ) 			 		//** Condicao de Pagamento		   			
				( oGTIntNfServ:oIntArq:aDetalhes[nPos][52] > 0 ) //** Valor servicos

	   			oGTIntNfServ:aNotas[ nPosNotas ][ 12 ] := { { cCodProd ,;
	   																 1 , ;
	   																 oGTIntNfServ:oIntArq:aDetalhes[nPos][52] ,;
	   																 oGTIntNfServ:oIntArq:aDetalhes[nPos][52] ,;
	   																 oGTIntNfServ:cTesDef } }
	   																 
				oGTIntNfServ:aNotas[ nPosNotas ][ 10 ]	:=	oGTIntNfServ:cCondDef	
				oGTIntNfServ:aNotas[ nPosNotas ][ 11 ]	:=	oGTIntNfServ:cNatDef
				
				If Empty( oGTIntNfServ::aNotas[ nPosNotas ][ 7 ] ) 
					If SA1->( DbSeek( xFilial() + PadR( oGTIntNfServ:oIntArq:aDetalhes[nPos][27] , nLenCGC ) ) )
						oGTIntNfServ:aNotas[ nPosNotas ][ 07 ]  := SA1->A1_COD
						oGTIntNfServ:aNotas[ nPosNotas ][ 08 ]	 := SA1->A1_LOJA 
					Else	
						oGTIntNfServ:aNotas[ nPosNotas ][ 07 ]  := GetSXENum("SA1","A1_COD")
					   	oGTIntNfServ:aNotas[ nPosNotas ][ 08 ]	 := '01'

					EndIf
				EndIf	   																 
    		   	aNfs[ nPosNotas ][ 2 ] := .T.
				oGTIntNfServ::aNotas[ nPosNotas ][ 2 ]  := .T.     	
	       EndIf		       
	       
		Else
		
			oGTIntNfServ:aNotas[ nPosNotas ][ 12 ] := {}
    	   	aNfs[ nPosNotas ][ 2 ] := .F.
			oGTIntNfServ::aNotas[ nPosNotas ][ 2 ]  := .F.     	
		EndIf
	EndIf
Next	

Return

/*
Funcao............: DadosDef
Objetivo..........: Permitir alterar dados default para gravacao do pedido e cliente
Autor.............: Leandro Diniz de Brito
Data..............: 19/03/2015
*/
*----------------------------------------------*
Static Function DadosDef( oGTIntNfServ )
*----------------------------------------------*
Local oPanel   	:= oGTIntNfServ:oWizard:GetPanel( oGTIntNfServ:oWizard:nPanel ) 
Local oGet1,oGet2,oGet3,oGet4


oGTIntNfServ:cContaDef 	:= PadR( GetNewPar( 'MV_P_00045' , '' ) , Len( CT1->CT1_CONTA ) )
oGTIntNfServ:cNatDef		:= PadR( GetNewPar( 'MV_P_00046' , '' ) , Len( SED->ED_CODIGO ) )			
oGTIntNfServ:cTesDef		:= PadR( GetNewPar( 'MV_P_00047' , '' ) , Len( SF4->F4_CODIGO ) )
oGTIntNfServ:cCondDef	:= PadR( GetNewPar( 'MV_P_00048' , '' ) , Len( SE4->E4_CODIGO ) )


@ 03,05 Say 'Dados que serao utilizados no cadastro do cliente e do pedido.'  Size 300,10 of oPanel Pixel

@ 17,05 Say 'C.Contabil'  Size 60,10 of oPanel Pixel
@ 29,05 Say 'Natureza'  Size 60,10 of oPanel Pixel
@ 41,05 Say 'TS Padrao'  Size 60,10 of oPanel Pixel
@ 53,05 Say 'Cond.Pagto'  Size 60,10 of oPanel Pixel

@ 17,80 MsGet oGet1 Var oGTIntNfServ:cContaDef  F3( 'CT1' ) Valid( ExistCpo( 'CT1', oGTIntNfServ:cContaDef , 1  ) ) Size 60,10 of oPanel Pixel
@ 29,80 MsGet oGet2 Var oGTIntNfServ:cNatDef  F3( 'SED' ) Valid( ExistCpo( 'SED' , oGTIntNfServ:cNatDef , 1 ) ) Size 60,10 of oPanel Pixel
@ 41,80 MsGet oGet3 Var oGTIntNfServ:cTesDef  F3( 'SF4' ) Valid( ExistCpo( 'SF4' , oGTIntNfServ:cTesDef , 1 ) ) Size 60,10 of oPanel Pixel
@ 53,80 MsGet oGet4 Var oGTIntNfServ:cCondDef  F3( 'SE4' ) Valid( ExistCpo( 'SE4' , oGTIntNfServ:cCondDef , 1 ) ) Size 60,10 of oPanel Pixel

oGet1:SetFocus()

Return( .T. )

/*
Funcao............: ValidaDados
Objetivo..........: Validacao Tela de dados defautl para gravacao do pedido e cliente
Autor.............: Leandro Diniz de Brito
Data..............: 19/03/2015
*/ 
*----------------------------------------------*
Static Function ValidaDados( oGTIntNfServ )
*----------------------------------------------*
Local lRet := .T.

If Empty( oGTIntNfServ:cContaDef ) .Or. ;
	Empty( oGTIntNfServ:cNatDef ) .Or. ;
	Empty( oGTIntNfServ:cTesDef ) .Or. ;
	Empty( oGTIntNfServ:cCondDef )
	
	MsgStop( 'Preencher todos os parametros.' )
	lRet := .F.

EndIf


Return( lRet )

static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString