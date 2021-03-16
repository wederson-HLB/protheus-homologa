#include 'protheus.ch'


/*
FUN��O		:   Update
*/

*==============================*
USER FUNCTION GRSX3081() //GRSX3081
*==============================*

U_Upd_Fabr('U_USX3081')

RETURN .T.

/*/{Protheus.doc} USX3081
//TODO Inclus�o
@author Alessandro Rodrigues/Daniel Lima
@since 18/01/2018
@version 1.0
@return ${return}, ${return_description}
@param lDesc, logical, descricao
@type function
/*/
USER FUNCTION USX3081(lDesc)
	*=====================================================================================================================================*
	Local cOrd := '', i:=0, cOrdXA := 0, cOrdTrb := 0
	Local aCpos := {}
	Local cNoUsa       := U_GetUsado( {{},.F.},.F.) //Campo nao usado
	Local cUsado       := U_GetUsado( {{},.F.},.T.) //Campo usado em todos os modulos
	Local cReservObrig := U_GetReserv({.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}) //Campo     Obrigatorio
	Local cReserv      := U_GetReserv({.T.,.T.,.T.,.T.,.T.,.T.,.F.,.T.}) //Campo Nao Obrigatorio
	Local cX2Path:='' , cX2Suf:=''
	Local cPCNPJ := "@R 99.999.999/9999-99"
	Local c1S2N := "1=Sim;2=Nao"
	local cCombo := "01=Pag-Remessa;02=Pag-Retorno;03=Pag-Backup;04=Rec-Remessa;05=Rec-Retorno;06=Rec-Backup;07=Extrato;08=Comprovante"  //CAS 16-07-2019 Incluido o item "08=Comprovante"

	If lDesc
		Return "updates de campos"
	EndIf


	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*************** SX2- Tabelas do sistema ***********************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/
	SX2->(dbSetOrder(1))
	SX2->(dbSeek("SEE")) // USA COMO MODELO
	cX2Path := SX2->X2_PATH
	cX2Suf  := SubStr(SX2->X2_ARQUIVO,4)
	aSX2 := {}
	//Z0D_FILIAL+Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA+Z0D_OPERA+Z0D_DIR
	aAdd(aSX2,{"Z0D",cX2Path,"Z0D"+cX2Suf,"Diretorio Bancos","Diretorio Bancos","Diretorio Bancos","","E","E","E",0,"","Z0D_FILIAL+Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA+Z0D_OPERA+Z0D_DIR","N", 06,"Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA+Z0D_OPERA+Z0D_DIR","","","1","2","2",0,0,0})

	aAdd(aSX2,{"Z0F",cX2Path,"Z0F"+cX2Suf,"Log Retorno CNAB","Log Retorno CNAB","Log Retorno CNAB","","E","E","E",0,"","Z0F_FILIAL+Z0F_IDCNAB+Z0F_REFBAN+Z0F_OCORRE+Z0F_DTPROC+Z0F_HRPROC","N", 06,"Z0F_IDCNAB+Z0F_REFBAN+Z0F_OCORRE+Z0F_DTPROC+Z0F_HRPROC","","","1","2","2",0,0,0})


	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*************** SXA - Pastas e agrupamentos *******************//
	//*************** dos campos do sistema       *******************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////

    /*=====================================================================================================================================*/
	//Cria��o de pasta para a tabela SE2
	/*
	cChaveXA := "SE2"
	SXA->(DbSetOrder(1))
	SXA->(DbSeek( AVKEY(cChaveXA,'XA_ALIAS') ))
	Do While !SXA->(EOF()) .And. SXA->XA_ALIAS == AVKEY(cChaveXA,'XA_ALIAS')
		cOrdXA := VAL(SXA->XA_ORDEM)
		IF SXA->XA_DESCRIC == "Pag. Tributos                 "
			cOrdTrb := VAL(SXA->XA_ORDEM)

		ENDIF
		SXA->(DbSkip())
	EndDo

	//dbSelectArea("SXA")
	aSXA := {}
	IF cOrdXA == 0
		cOrdXA := cOrdXA + 1
		//         XA_ALIAS	| XA_ORDEM               | XA_DESCRIC        | XA_DESCSPA         | XA_DESCENG        | XA_PROPRI | XA_AGRUP | XA_TIPO
		AADD(aSXA,{cChaveXA ,CVALTOCHAR(cOrdXA)      , "Dados Gerais"   , "Dados Gerais"    , "Dados Gerais"   , "U"       , ""       , ""})

	ENDIF

	IF cOrdTrb == 0
		cOrdTrb := cOrdXA + 1
		AADD(aSXA,{cChaveXA , CVALTOCHAR(cOrdTrb) , "Pag. Tributos" , "Pag. Tributos"  , "Pag. Tributos"  , "U"   , ""    , ""})
	ELSE
		AADD(aSXA,{cChaveXA , CVALTOCHAR(cOrdTrb) , "Pag. Tributos" , "Pag. Tributos"  , "Pag. Tributos"  , "U"   , ""    , ""})
	ENDIF
*/
	/*=====================================================================================================================================*/
	
	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*************** SX3- Campos das Tabelas ***********************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////

	dbSelectArea("SX3")
	aSX3 := {}

	//Cria��o de campos na tabela SEE
	cChave := "SEE"
	SX3->(DbSetOrder(1))
	SX3->(DbSeek( AVKEY(cChave,'X3_ARQUIVO') ))
	Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == AVKEY(cChave,'X3_ARQUIVO')
		cOrd := SX3->X3_ORDEM
		SX3->(DbSkip())
	EndDo
	SX3->(DbSetOrder(2))



	cCampo := "Z0F_FILIAL"
	aAdd(aSX3,{"Z0F","01" ,cCampo,"C",AVSX3("EE_FILIAL",3),0,"Filial","","","Filial do Sistema","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0F_IDCNAB"
	aAdd(aSX3,{"Z0F","02",cCampo,"C",10,0,"Id. Cnab","","","Identificador Cnab","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_BANCO"
	aAdd(aSX3,{"Z0F","03" ,cCampo,"C",AVSX3("EE_CODIGO",3),0,"Banco","","","Banco","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0F_AGE"
	aAdd(aSX3,{"Z0F","04" ,cCampo,"C",AVSX3("EE_AGENCIA",3),0,"Agencia","","","Agencia","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0F_CTA"
	aAdd(aSX3,{"Z0F","05" ,cCampo,"C",AVSX3("EE_CONTA",3),0,"Conta","","","Conta","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0F_PREFIX"
	aAdd(aSX3,{"Z0F","06",cCampo,"C",3,0,"Prefixo","","","Prefixo do Titulo","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_NUM"
	aAdd(aSX3,{"Z0F","07",cCampo,"C",9,0,"No. Titulo","","","Numero do Titulo","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_PARCEL"
	aAdd(aSX3,{"Z0F","08",cCampo,"C",1,0,"Parcela","","","Parcela do Titulo","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_TIPO"
	aAdd(aSX3,{"Z0F","09",cCampo,"C",3,0,"Tipo","","","Tipo do Titulo","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_FORCLI"
	aAdd(aSX3,{"Z0F","10",cCampo,"C",6,0,"For/Cli","","","Fornecedor/Cliente","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_NOMFC"
	aAdd(aSX3,{"Z0F","11",cCampo,"C",60,0,"Nome For/Cli","","","Nome Fornecedor/Cliente","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})
	
	cCampo := "Z0F_CGCCPF"
	aAdd(aSX3,{"Z0F","12",cCampo,"C",14,0,"CNPJ/CPF","","","CNPJ/CPF Forn/Cli","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_DTEMIS"
	aAdd(aSX3,{"Z0F","13",cCampo,"D",8,0,"DT Emissao","","","Data de Emissao do Titulo","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_DTVENC"
	aAdd(aSX3,{"Z0F","14",cCampo,"D",8,0,"Dt. Vencto","","","Data Vencimento","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_DTBAIX"
	aAdd(aSX3,{"Z0F","15",cCampo,"D",8,0,"Dt. Baixa","","","Data Baixa","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_DTPROC"
	aAdd(aSX3,{"Z0F","16",cCampo,"D",8,0,"Dt. Process","","","Data Processamento","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})
	
	cCampo := "Z0F_HRPROC"
	aAdd(aSX3,{"Z0F","17" ,cCampo,"C",08,0,"Hr Process","","","Hora Processamento","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_VALOR"
	aAdd(aSX3,{"Z0F","18",cCampo,"N",16,2,"Vlr. Titulo","","","Valor Titulo","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})
	
	cCampo := "Z0F_REFBAN"
	aAdd(aSX3,{"Z0F","19",cCampo,"C",10,0,"Ocorr Banco ","","","Codigo Ocorrencia Banco","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})
	
	cCampo := "Z0F_OCORRE"
	aAdd(aSX3,{"Z0F","20",cCampo,"C",02,0,"Ocorr Sist.","","","Codigo Ocorrencia Sistema","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_DESCOC"
	aAdd(aSX3,{"Z0F","21",cCampo,"C",250,0,"Descr.","","","Descricao Ocorrencia","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_DTENVI"
	aAdd(aSX3,{"Z0F","22",cCampo,"D",8,0,"Dt. Envio","","","Data Envio Email","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})
	
	cCampo := "Z0F_HRENVI"
	aAdd(aSX3,{"Z0F","23" ,cCampo,"C",08,0,"Hr Envio","","","Hora Envio Email","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "Z0F_NUMBOR"
	aAdd(aSX3,{"Z0F","24" ,cCampo,"C",06,0,"Num Bordero","","","Numero do Bordero","","","","",cUsado,"","",;
	,cReserv,"","","U","S","A","R","","","","","","","","","","","","","","","N","N","","","",""})



	//CAMPOS DA TABELA Z0D "DIRETORIO DOS BANCOS"
	//Z0D_FILIAL+Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA+Z0D_OPERA+Z0D_DIR
	cCampo := "Z0D_FILIAL"
	aAdd(aSX3,{"Z0D","01" ,cCampo,"C",AVSX3("EE_FILIAL",3),0,"Filial","","","Filial do Sistema","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_BANCO"
	aAdd(aSX3,{"Z0D","02" ,cCampo,"C",AVSX3("EE_CODIGO",3),0,"Banco","","","Banco","","","","",cUsado,"","SA6",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_AGE"
	aAdd(aSX3,{"Z0D","03" ,cCampo,"C",AVSX3("EE_AGENCIA",3),0,"Agencia","","","Agencia","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_CTA"
	aAdd(aSX3,{"Z0D","04" ,cCampo,"C",AVSX3("EE_CONTA",3),0,"Conta","","","Conta","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_SUBCTA"
	aAdd(aSX3,{"Z0D","05" ,cCampo,"C",AVSX3("EE_SUBCTA",3),0,"SubConta","","","SubConta","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_DIR"
	aAdd(aSX3,{"Z0D","06" ,cCampo,"C",250,0,"Diretorio","","","Diretorio do Banco","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCombo := "01=Pag-Remessa;02=Pag-Retorno;03=Pag-Backup;04=Rec-Remessa;05=Rec-Retorno;06=Rec-Backup;07=Extrato;08=Comprovante"  //CAS 16-07-2019 Incluido o item "08=Comprovante"
	cCampo := "Z0D_OPERA"
	aAdd(aSX3,{"Z0D","07" ,cCampo,"C",02,0,"Operacao","","","Operacao do Banco","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","",cCombo,cCombo,cCombo,,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_STATUS"
	aAdd(aSX3,{"Z0D","08" ,cCampo,"C",01,0,"Status","","","Status da criacao","","","","",cNoUsa,"","",;
	1,cReserv,"","","U","N","","","","","","","",,,,,"1","","","","","","","","","",""})

	/*cCampo := "Z0D_MSG"
	aAdd(aSX3,{"Z0D","08" ,cCampo,"C",06,0,"Mensagem","","","Mensagem na Ciracao","","","","",cNoUsa,"","",;
	1,cReserv,"","","U","N","","","","","","","",,,,,"1","","","","","","","","","",""})*/

	cCampo := "Z0D_M_MSG"
	aAdd(aSX3,{"Z0D","09" ,cCampo,"M",999,0,"Mensagem","","","Mensagem na Criacao","","","","",cUsado,"","",;
	1,cReserv,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_DTCRI"
	aAdd(aSX3,{"Z0D","10" ,cCampo,"D",08,0,"Dt Criacao","","","Data Criacao/Alteracao","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_HRCRI"
	aAdd(aSX3,{"Z0D","11" ,cCampo,"C",08,0,"Hr Criacao","","","Hora Criacao/Alteracao","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCampo := "Z0D_USCRI"
	aAdd(aSX3,{"Z0D","12" ,cCampo,"C",60,0,"US Criacao","","","Usuario Criacao/Alteracao","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","A","R","","","","","",,,,,"1","","","","","","","","","",""})

	cCombo := "01=Pag-Remessa;02=Pag-Retorno;03=Pag-Backup;04=Rec-Remessa;05=Rec-Retorno;06=Rec-Backup;07=Extrato;08=Comprovante"  //CAS 16-07-2019 Incluido o item "08=Comprovante"
	cCampo := "Z0D_ALTERA"
	aAdd(aSX3,{"Z0D","13" ,cCampo,"C",01,0,"Alterado","","","Pasta Alterada","","","","",cUsado,"","",;
	1,cReservObrig,"","","U","S","V","R","","",cCombo,cCombo,cCombo,,,,,"1","","","","","","","","","",""})



	//CAMPO SE UTILIZA LAYOUT DA ACCESSTAGE OU N�O
	cCampo := "EE_P_ACCES"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	//Campos|Alias||Ordem||Campo||Tipo||Tamanho||Decimal||Titulo||Titulo SPA||Titulo USA||Descricao||Descricao SPA||Descricao USA||Picture||Validacao||
	//Usado||Rela��o||F3||Nivel||Reservado||Check||Trigger||Propri||Browse||Visual||Contexto||Obrigatorio||Valid User||Combo Box||Combo Box SPA||
	//Combo Box USA||PictVar||Editar||Inici. Browse||GRPSXG||Folder||Pyme||CondSQL||ChkSQL||IdxSRV||Ortogra||IdxFLD||Tela||Agrup||PosLgt||MModal|
	aAdd(aSX3,{cChave ,cOrdX3 ,cCampo,"C", 01,0,"FEBRABAN","","","Utiliza Febraban","","","","U_GTFIN038(2,'')",cUsado,"","",;
	1,cReserv,"","","U","S","A","R","","",c1S2N,c1S2N,c1S2N,,,,,"1","","","","","","","","","",""})

	cCampo := "EE_P_NOEMP"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{cChave ,cOrdX3 ,cCampo,"C", 60,0,"NOME EMP","","","Nome Empresa na Pasta","","","","U_GTFIN039(1,'')",cUsado,"U_GTFIN038(1,'')","",;
	1,cReserv,"","","U","S","A","R","","",,,,,,,,"1","","","","","","","","","",""})

	cCombo := "A=Aceito;N=Nao Aceito"
    cCampo := "EE_P_ACEIT"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SEE",cOrdX3,cCampo,"C",1,0,"Aceite","Aceite","Aceite","Aceite","Aceite","Aceite","@!","",;
	               cUsado,"'A'","",0,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","1","S","","","","","","","","",""})
	EndIf

	cCombo := "1=Frente do Boleto de Pagamento;2=Verso do Boleto de Pagamento;3=Inst. Ficha Compensa��o"
	cCampo := "EE_P_TPIMP"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEE",cOrdX3,cCampo,"C",1,0,"Tip.Impres","Tip.Impres","Tip.Impres","Tipo Impressao","Tipo Impressao","Tipo Impressao","@!","",;
				cUsado,"'1'","",0,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","3","S","","","","","","","","",""})


	/************************************************************************************
	************************************************************************************
	INFORMA��ES DE PROTESTO E MULTA PARA CNAB A RECEBER
	************************************************************************************
	*************************************************************************************/

	//C�DIGO PROTESTO
	//EE_P_PROTE
	cCombo := "1=Protestar Dias Corridos;2=Protestar Dias �teis;3=N�o Protestar;4=Protestar Fim Falimentar - Dias �teis;5=Protestar Fim Falimentar - Dias Corridos;8=Negativa��o sem Protesto;9=Cancelamento Protesto Autom�tico"
	cCampo := "EE_P_PROTE"
	//If !SX3->(DbSeek(cCampo))
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEE",cOrdX3,cCampo,"C",1,0,"Cod Protesto","Cod Protesto","Cod Protesto","Codigo Protesto","Codigo Protesto","Codigo Protesto","","",;
				cUsado,"","",0,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","1","S","","","","","","","","",""})
	
	//PERCENTUAL DE MULTA
	cCampo := "EE_P_PERMT"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEE",cOrdX3,cCampo,"N",5,2,"Perc Multa","Perc Multa","Perc Multa","Percentual Multa","Percentual Multa","Percentual Multa","@E 999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","1","","","","","N","N","","","",""})

	//CODIGO JUROS
	cCombo := "1=Valor por Dia;2=Taxa Mensal;3=Isento"
	cCampo := "EE_P_TIPO"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEE",cOrdX3,cCampo,"C",1,0,"Tp Juros","Tp Juros","Tp Juros","Tipo Juros","Tipo Juros","Tipo Juros","","",;
		cUsado,"","",,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","1","S","","","","","","","","",""})

	//PERCENTUAL JUROS
	cCampo := "EE_P_PERJR"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEE",cOrdX3,cCampo,"N",6,3,"Perc Juros","Perc Juros","Perc Juros","Percentual Juros","Percentual Juros","Percentual Juros","@E 999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","1","","","","","N","N","","","",""})

	//CAMPO DE EMAIL PARA RECEBER AS OCORRENCIAS
	cCampo := "EE_P_EMAIL"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{cChave ,cOrdX3 ,cCampo,"C", 250,0,"Email.Ocorre","","","Email para receber Ocorre","","","","",cUsado,"","",;
	1,cReserv,"","","U","S","A","R","","",,,,,,,,"2","","","","","","","","","",""})
	
	cCampo := "A1_P_PROTE"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"C",1,0,"Cod Protesto","Cod Protesto","Cod Protesto","Codigo Protesto","Codigo Protesto","Codigo Protesto","","",;
				cUsado,"","",0,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","2","S","","","","","","","","",""})

	cCampo := "A1_P_DIASP"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"C",02,0,"Dias Protest","Dias Protest","Dias Protest","Dias para protesto","Dias para protesto","Dias para protesto","99","",;
				cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","","","","","2","S","","","","","","","","",""})

	
	//CODIGO MULTA
	cCombo := "1=Valor Fixo;2=Percentual"
	cCampo := "E1_P_TPMUL"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE1",cOrdX3,cCampo,"C",1,0,"Tp Multa","Tp Multa","Tp Multa","Tipo Multa","Tipo Multa","Tipo Multa","","",;
		cUsado,"'2'","",1,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","3","S","","","","","","","","",""})

	//PERCENTUAL DE MULTA
	cCampo := "A1_P_PERMT"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"N",5,2,"Perc Multa","Perc Multa","Perc Multa","Percentual Multa","Percentual Multa","Percentual Multa","@E 999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","2","","","","","N","N","","","",""})

	cCampo := "A1_P_TIPO"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"C",1,0,"Tp Juros","Tp Juros","Tp Juros","Tipo Juros","Tipo Juros","Tipo Juros","","",;
		cUsado,"","",,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","2","S","","","","","","","","",""})
	
	cCampo := "A1_P_PERJR"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"N",5,2,"Perc Juros","Perc Juros","Perc Juros","Percentual Juros","Percentual Juros","Percentual Juros","@E 999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","2","","","","","N","N","","","",""})

	//CAMPO PARA VERIFICAR SE CONSIDERA MULTA, JUROS E PROTESTO DO CLIENTE OU DOS PARAMETROS
	cCombo := "1=Cliente;2=Parametro Banco"
	cCampo := "A1_P_CL_PA"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"C",1,0,"Client/Param","Client/Param","Client/Param","Considera Cli/Param","Considera Cli/Param","Considera Cli/Param","","",;
		cUsado,"'2'","",0,cReserv,"","","U","S","A","R","","",cCombo,cCombo,cCombo,"","","","","2","S","","","","","","","","",""})



	//***************************************************************//
	//*************** SX3- Campos Tributos CNAB *********************//
	//***************************************************************//
	//Cria��o de campos na tabela SE2
	cChave := "SE2"
	SX3->(DbSetOrder(1))
	SX3->(DbSeek( AVKEY(cChave,'X3_ARQUIVO') ))
	Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == AVKEY(cChave,'X3_ARQUIVO')
		cOrd := SX3->X3_ORDEM
		SX3->(DbSkip())
	EndDo
	SX3->(DbSetOrder(2))

	cCampo := "E2_P_MULTA"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",16,2,"Multa","Multa","Multa","Valor da Multa","Valor da Multa","Valor da Multa","@E 9,999,999,999,999.99","",;
	cUsado,"","",,cReserv,"","S","U","N","A","R","","","","","","","","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_JUROS"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",16,2,"Juros","Juros","Juros","Valor do Juros","Valor do Juros","Valor do Juros","@E 9,999,999,999,999.99","",;
	cUsado,"","",,cReserv,"","S","U","N","A","R","","","","","","","","","","","","","","","N","N","","","",""})
	
	cCbTrib := "01=FGTS;16=DARF Normal;18=DARF Simples;17=GPS;19=IPTU;21=DARJ;25=IPVA;26=Licenciamento;27=DPVAT;22=GARE-SP ICMS;23=DARE-SP DR"
	cCampo := "E2_P_TRIB"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",02,0,"Tributos","Tributos","Tributos","Tipos de Tributos","Tipos de Tributos","Tipos de Tributos","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","",cCbTrib,cCbTrib,cCbTrib,"","","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_CODRE"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",4,0,"Cod. Recolhi","Cod. Recolhi","Cod. Recolhi","Cod. Recolhimento","Cod. Recolhimento","Cod. Recolhimento","","",;
				   cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(!Empty(M->E2_P_TRIB),.T.,.F.)","","","","","","","","N","N","","","",""})
	
	cContrib := "01=CNPJ;02=CPF;03=PIS/PASEP;04=CEI;06=NB;07=N� do T�tulo;08=DEBCAD;09=REFERENCIA"
	cCampo := "E2_P_TPCON"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",02,0,"Contribuinte","Contribuinte","Contribuinte","Tipo Contribuinte","Tipo Contribuinte","Tipo Contribuinte","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","",cContrib,cContrib,cContrib,"","IIF(!Empty(M->E2_P_TRIB),.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_CGCON"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",14,0,"CNPJ/CPF","CNPJ/CPF","CNPJ/CPF","CNPJ/CPF do Contribuinte","CNPJ/CPF do Contribuinte","CNPJ/CPF do Contribuinte","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(!Empty(M->E2_P_TRIB),.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_NMCON"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",30,0,"Nom Contrib","Nom Contrib","Nom Contrib","Nome Contribuinte","Nome Contribuinte","Nome Contribuinte","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(!Empty(M->E2_P_TRIB),.T.,.F.)","","","","","","","","N","N","","","",""})


	cCampo := "E2_P_COMPE"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"D",08,0,"Compet/Apur","Compet/Apur","Compet/Apur","Compet�ncia/Apura��o","Compet�ncia/Apura��o","Compet�ncia/Apura��o","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(!Empty(M->E2_P_TRIB),.T.,.F.)","","","","","","","","N","N","","","",""})

/*******************************
INICIO GPS
*******************************************/

	cCampo := "E2_P_VRENT"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",13,2,"Out Entidade","Out Entidade","Out Entidade","Outras entidades","Outras entidades","Outras entidades","@E 9,999,999,999.99","",;
	cUsado,"","",,cReserv,"","S","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB=='17',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_VLINS"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",13,2,"Vl Total","Vl Total","Vl Total","Valor Total GPS","Valor Total GPS","Valor Total GPS","@E 9,999,999,999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB=='17',.T.,.F.)","","","","","","","","N","N","","","",""})
/*******************************
FIM GPS
*******************************************/

/*******************************
INICIO DARF NORMAL
*******************************************/
	cCampo := "E2_P_REFE"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",17,0,"Num. Referen","Num. Referen","Num. Referen","Numero de Referencia","Numero de referencia","Numero de referencia","@!","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB=='16',.T.,.F.)","","","","","","","","N","N","","","",""})
/*******************************
FIM DARF NORMAL
*******************************************/

/*******************************
INICIO DARF SIMLES
*******************************************/
	cCampo := "E2_P_REBRU"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",13,2,"Rec. Bruta","Rec. Bruta","Rec. Bruta","Rec. Bruta","Rec. Bruta","Rec. Bruta","@E 999,999,999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB=='18',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_PERRB"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",5,2,"Perc Rec Brt","Perc Rec Brt","Perc Rec Brt","Perc Rec Brt","Perc Rec Brt","Perc Rec Brt","@E 999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB=='18',.T.,.F.)","","","","","","","","N","N","","","",""})
/*******************************
FIM DARF SIMPLES
*******************************************/

/*******************************
INICIO GARE
*******************************************/
	cCampo := "E2_P_INSCR"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",12,0,"Ins. Estad.","Ins. Estad.","Ins. Estad.","Inscricao Estadual","Inscricao Estadual","Inscricao Estadual","@!","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'22/23',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_DIVAT"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",13,0,"Gare Div atv","Gare Div atv","Gare Div atv","Divida Ativa/ Numero Etiq","Divida Ativa/ Numero Etiq","Divida Ativa/ Numero Etiq","@!","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'22/23',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_PARCE"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",13,0,"Gare Parcela","Gare Parcela","Gare Parcela","Num. Parcela da Notificac","Num. Parcela da Notificac","Num. Parcela da Notificac","@!","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'22/23',.T.,.F.)","","","","","","","","N","N","","","",""})

/*******************************
FIM GARE
*******************************************/

/*******************************
INICIO IPVA/DPVAT/LICENCIAMENTO
*******************************************/

	cCampo := "E2_P_RENAV"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",12,0,"Renavan","Renavan","Renavan","Codigo Renavan","Codigo Renavan","Codigo Renavan","@E 999999999999","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'25/26/27',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_UFIPV"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",2,0,"UF","UF","UF","Unidade da Federa��o","Unidade da Federa��o","Unidade da Federa��o","@!","",;
	cUsado,"","12",1,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'25/26/27',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_CDMUN"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",5,0,"Cd.Municipio","Cd.Municipio","Cd.Municipio","C�digo do Municipio","C�digo do Municipio","C�digo do Municipio","","Vazio() .Or. ExistCpo('CC2',M->E2_P_UFIPV+M->E2_P_CDMUN)",;
	cUsado,"","CC2SE2",1,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'25/26/27',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_PLACA"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",10,0,"Placa","Placa","Placa","Placa","Placa","Placa","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'25/26/27',.T.,.F.)","","","","","","","","N","N","","","",""})

	cParcela := "1=Parc.Unica C/Desconto;2=Parc.Unica S/Desconto;3=Parc.-N�1;4=Parc.-N�2;5=Parc.-N�3;6=Parc.-N�4;7=Parc.-N�5;8=Parc.-N�6"
	cCampo := "E2_P_OPPAG"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",1,0,"OP. Pagto","OP. Pagto","OP. Pagto","Op��o de Pagamento","Op��o de Pagamento","Op��o de Pagamento","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","",cParcela,cParcela,cParcela,"","IIF(M->E2_P_TRIB$'25',.T.,.F.)","","","","","","","","N","N","","","",""})

	cRetirada := "1=Correio;2=DETRAN/CIRETRAN"
	cCampo := "E2_P_OPRET"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",1,0,"OP. Retirada","OP. Retirada","OP. Retirada","Op��o de Retirada do CRVL","Op��o de Retirada do CRVL","Op��o de Retirada do CRVL","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","",cRetirada,cRetirada,cRetirada,"","IIF(M->E2_P_TRIB$'26',.T.,.F.)","","","","","","","","N","N","","","",""})

/***********************************
FIM IPVA/DPVAT/LICENCIAMENTO
****************************************/

/***********************************
INICIO DARJ
****************************************/
	cCampo := "E2_P_DCORI"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",16,0,"Doc Orig.","Doc Orig.","Doc Orig.","Doc Original DARJ","Doc Original DARJ","Doc Original DARJ","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'21',.T.,.F.)","","","","","","","","N","N","","","",""})

	cCampo := "E2_P_VLMON"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"N",13,2,"Atua Monet.","Atua Monet.","Atua Monet.","Atualizacao Monetaria","Atualizacao Monetaria","Atualizacao Monetaria","@E 9,999,999,999.99","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'21',.T.,.F.)","","","","","","","","N","N","","","",""})

	

/***********************************
FIM DARJ
****************************************/

/***********************************
INICIO FGTS
****************************************/
	cCampo := "E2_P_IDFGT" //(16)  - Campo Identificador do FGTS
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",16,0,"ID FGTS","ID FGTS","ID FGTS","Identificador FGTS","Identificador FGTS","Identificador FGTS","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'01',.T.,.F.)","","","","","","","","N","N","","","",""})
	
	cCampo := "E2_P_LCSOC" //(9)   - Lacre do Conectividade Social
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",9,0,"Lacre Soc.","Lacre Soc.","Lacre Soc.","Lacre Conect. Social","Lacre Conect. Social","Lacre Conect. Social","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'01',.T.,.F.)","","","","","","","","N","N","","","",""})
	
	cCampo := "E2_P_DGSOC" //(2)   - D�gito do Lacre do Conectividade Social
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",2,0,"Dig. L. Soc.","Dig. L. Soc.","Dig. L. Soc.","Dig. Lac. Social","Dig. Lac. Social","Dig. Lac. Social","","",;
	cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","IIF(M->E2_P_TRIB$'01',.T.,.F.)","","","","","","","","N","N","","","",""})




/***********************************
FIM FGTS
****************************************/

	cCampo := "E2_LINDIG"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",48,0,"Linha Dig.","Linha Dig.","Linha Dig.","Linha Digit�vel","Linha Digit�vel","Linha Digit�vel","","",;
	               cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","1","","","","","N","N","","","",""})
	EndIf

	cCampo := "E2_FORBCO"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",3,0,"Banco For.","Banco For.","Banco For.","Banco do Fornecedor","Banco do Fornecedor","Banco do Fornecedor","@!","",;
	               cUsado,"","FIL",1,cReserv,"","","U","N","A","R","","","","","","","","","","1","","","","N","","N","","","",""})
	EndIf

	cCampo := "E2_FORAGE"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",5	,0,"Agencia For.","Agencia For.","Agencia For.","Agencia Bancaria Fornec.","Agencia Bancaria Fornec.","Agencia Bancaria Fornec. ","@!","",;
	               cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","",".F.","","","1","","","","N","","N","","","",""})
	EndIf

	cCampo := "E2_FORCTA"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",10,0,"Conta For.","Conta For.","Conta For.","Conta do Fornecedor","Conta do Fornecedor","Conta do Fornecedor","@!","",;
	               cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","",".F.","","","1","","","","N","","N","","","",""})
	EndIf    	
	
	cCampo := "E2_FAGEDV"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",1,0,"DV Agencia","DV Agencia","DV Agencia","Digito Verificador Agenc.","Digito Verificador Agenc.","Digito Verificador Agenc.","@!","",;
	               cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","","","","","1","S","","","N","","N","","","1","2"})
	EndIf

	cCampo := "E2_FCTADV"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",2,0,"DV Conta","DV Conta","DV Conta","Digito Verificador Conta","Digito Verificador Conta","Digito Verificador Conta","@!","",;
	               cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","","","","","1","S","","","N","","N","","","1","2"})
	EndIf

	cCampo := "E2_P_NOMBN"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",20,0,"Nom Benefic","Nom Benefic","Nom Benefic","NOME BENEFICIARIO","NOME BENEFICIARIO","NOME BENEFICIARIO","@!","",;
			    cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","1","","","","","N","N","","","",""})
	
	cCampo := "E2_P_CGCBN"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",14,0,"CNPJ/CPF-BN","CNPJ/CPF-BN","CNPJ/CPF-BN","CNPJ/CPF BENEFICIARIO","CNPJ/CPF BENEFICIARIO","CNPJ/CPF BENEFICIARIO","","",;
				   cUsado,"","",,cReserv,"","","U","N","A","R","","","","","","","","","","1","","","","","N","N","","","",""})

	cCombo := "F=Fisico;J=Juridico;X=Outros"
	cCampo := "E2_P_TIPO"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",1,0,"Tipo","Tipo","Tipo","Tipo do Beneficiario","Tipo do Beneficiario","Tipo do Beneficiario","@!","",;
				   cUsado,"","",,cReserv,"","","U","N","A","R","","",cCombo,cCombo,cCombo,"","","","","1","","","","","N","N","","","",""})
	
	cCombo := "0=Inclusao;1=Consulta;2=Suspensao;4=Reativacao;5=Alteracao;7=Liquidacao;9=Exclusao"
	cCampo := "E2_P_TPMV"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",1,0,"Tp Movi.","Tp Movi.","Tp Movi.","Tipo de Movimento","Tipo de Movimento","Tipo de Movimento","","",;
				   cUsado,"'0'","",,cReserv,"","","U","N","A","R","","",cCombo,cCombo,cCombo,"","","","","1","","","","","N","N","","","",""})
	
	cCombo := "00=Inclusao Reg. Liberado;99=Exclusao Reg Incluido Anterior"
	cCampo := "E2_P_INSMV"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",2,0,"Inst. Movi.","Inst. Movi.","Inst. Movi.","Instraucao p/ Movimento","Instraucao p/ Movimento","Instraucao p/ Movimento","","",;
				   cUsado,"'00'","",,cReserv,"","","U","N","A","R","","",cCombo,cCombo,cCombo,"","","","","1","","","","","N","N","","","",""})
	
	cCombo := "BRL=Real;USD=Dolar;PTE=Portugues;FRF=Frances;CHF=Suico;JPY=Ien;GBP=Libra;ITL=Lira;DEM=Alemao"
	cCampo := "E2_P_TPMOE"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SE2",cOrdX3,cCampo,"C",3,0,"Tp Moeda","Tp Moeda","Tp Moeda","Tipo de Moeda ","Tipo de Moeda","Tipo de Moeda","","",;
				   cUsado,"'BRL'","",,cReserv,"","","U","N","A","R","","",cCombo,cCombo,cCombo,"","","","","1","","","","","N","N","","","",""})
	


	//Cria��o de campos na tabela SA2
	cChave := "SA2"
	SX3->(DbSetOrder(1))
	SX3->(DbSeek( AVKEY(cChave,'X3_ARQUIVO') ))
	Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == AVKEY(cChave,'X3_ARQUIVO')
		cOrd := SX3->X3_ORDEM
		SX3->(DbSkip())
	EndDo

	SX3->(DbSetOrder(2))
	cCampo := "A2_DVAGE"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SA2",cOrdX3,cCampo,"C",1,0,"DV Ag Cnab","DV Ag Cnab","DV Ag Cnab","Digito Verific. Agencia","Digito Verific. Agencia","Digito Verific. Agencia","@!","",;
	               cUsado,"","",1,cReserv,"","","U","","","","","","","","","","","","","1","N","","","N","","N","","","2","2"})
	EndIf

	cCampo := "A2_DVCTA"
	If !SX3->(DbSeek(cCampo))
		IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
		aAdd(aSX3,{"SA2",cOrdX3,cCampo,"C",2,0,"DV Cta Cnab","DV Cta Cnab","DV Cta Cnab","Digito Verificador Conta","Digito Verificador Conta","Digito Verificador Conta","@!","",;
	               cUsado,"","",1,cReserv,"","","U","","","","","","","","","","","","","1","N","","","N","","N","","","2","2"})
	EndIf		

	

	//CAMPOS DA SE1 - CONTAS A RECEBER
    
	cCampo := "E1_P_MULTA"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE1",cOrdX3,cCampo,"N",16,2,"Multa","Multa","Multa","Valor da Multa","Valor da Multa","Valor da Multa","@E 9,999,999,999,999.99","",;
	cUsado,"","",,cReserv,"","S","U","N","A","R","","","","","","","","","","3","","","","","N","N","","","",""})

	cCampo := "E1_P_JUROS"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SE1",cOrdX3,cCampo,"N",16,2,"Juros","Juros","Juros","Valor do Juros","Valor do Juros","Valor do Juros","@E 9,999,999,999,999.99","",;
	cUsado,"","",,cReserv,"","S","U","N","A","R","","","","","","","","","","3","","","","","N","N","","","",""})

	
	cCampo := "A1_P_AGECL"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"C",5,0,"Agencia Cli.","Agencia Cli.","Agencia Cli.","Agencia Bancaria Client.","Agencia Bancaria Client.","Agencia Bancaria Client. ","@!","",;
				cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","","","","","2","","","","N","","N","","","",""})


	cCampo := "A1_P_CTACL"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SA1",cOrdX3,cCampo,"C",10,0,"Conta Cli.","Conta Cli.","Conta Cli.","Conta do Cliente","Conta do Cliente","Conta do Cliente","@!","",;
				cUsado,"","",1,cReserv,"","","U","N","A","R","","","","","","","","","","2","","","","N","","N","","","",""})


	//Cria��o de campos na tabela SEA
	cChave := "SEA"
	SX3->(DbSetOrder(1))
	SX3->(DbSeek( AVKEY(cChave,'X3_ARQUIVO') ))
	Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == AVKEY(cChave,'X3_ARQUIVO')
		cOrd := SX3->X3_ORDEM
		SX3->(DbSkip())
	EndDo
	SX3->(DbSetOrder(2))

	cCampo := "EA_P_IDCNA"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEA",cOrdX3,cCampo,"C",10,0,"Id. Cnab","Id. Cnab","Id. Cnab","Identificador Cnab","Identificador Cnab","Identificador Cnab","@!","",;
				cNoUsa,"","",1,cReserv,"","","U","N","","","","","","","","","","","","","S","","","N","N","N","","","1","2"})
	
	cCampo := "EA_P_ARQ"
	IIf(! DbSeek(cCampo), cOrdX3 := cOrd := OrdemSX3(cOrd), cOrdX3 := SX3->X3_ORDEM)
	aAdd(aSX3,{"SEA",cOrdX3,cCampo,"C",250,0,"Arq. Cnab","Arq. Cnab","Arq. Cnab","Arquivo Cnab","Arquivo Cnab","Arquivo Cnab","@!","",;
				cNoUsa,"","",1,cReserv,"","","U","N","","","","","","","","","","","","","S","","","N","N","N","","","1","2"})
    

    

	/*=====================================================================================================================================*/

	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*************** SX1- Perguntas do usu�rio *********************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/
   
    aSX1 := {}
	//X1_GRUPO | X1_ORDEM |  X1_PERGUNT | X1_PERSPA | X1_PERENG | X1_VARIAVL | X1_TIPO | X1_TAMANHO | X1_DECIMAL | X1_PRESEL | X1_GSC | 
	//X1_VALID | X1_VAR01 | X1_DEF01 | X1_DEFSPA1 | X1_DEFENG1 | X1_CNT01 | X1_VAR02 | X1_DEF02 | X1_DEFSPA2 | X1_DEFENG2 | X1_CNT02 | 
	//X1_VAR03 | X1_DEF03 | X1_DEFSPA3 | X1_DEFENG3 | X1_CNT03 | X1_VAR04 | X1_DEF04 | X1_DEFSPA4 | X1_DEFENG4 | X1_CNT04 | X1_VAR05 |
	//X1_DEF05 | X1_DEFSPA5 | X1_DEFENG5 | X1_CNT05 | X1_F3 | X1_PYME | X1_GRPSXG | X1_HELP | X1_PICTURE | X1_IDFIL 
    aAdd(aSX1,{"GTFIN040","01","Filial de?","","","mv_ch1","C",2,0,0,"G",;
	"","mv_ch1","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","SM0","","","","",""})

	aAdd(aSX1,{"GTFIN040","02","Filial at?","","","mv_ch2","C",2,0,0,"G",;
	"","mv_ch2","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","SM0","","","","",""})

	aAdd(aSX1,{"GTFIN040","03","Banco?","","","mv_ch3","C",3,0,0,"G",;
	"","mv_ch3","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","SA6","","007","","",""})

	aAdd(aSX1,{"GTFIN040","04","Agencia?","","","mv_ch4","C",5,0,0,"G",;
	"","mv_ch4","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","","","008","","",""})

	aAdd(aSX1,{"GTFIN040","05","Conta?","","","mv_ch5","C",10,0,0,"G",;
	"","mv_ch5","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","","","009","","",""})

	aAdd(aSX1,{"GTFIN040","06","DT Processamento de?","","","mv_ch6","D",8,0,0,"G",;
	"","mv_ch6","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","","","","","",""})

	aAdd(aSX1,{"GTFIN040","07","DT Processamento at?","","","mv_ch7","D",8,0,0,"G",;
	"","mv_ch7","","","","","","","","","",;
	"","","","","","","","","","","",;
	"","","","","","","","","",""})
	
	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*********** SIX - �ndices das tabelas do sistema **************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/

	aSIX := {}
	//Z0D_FILIAL+Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA+Z0D_OPERA+Z0D_DIR
	aAdd(aSIX,{"Z0D","1","Z0D_FILIAL+Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA","Filial+Banco+Agencia+Conta+SubConta","","","U","","","S","2","3"})
	aAdd(aSIX,{"Z0D","2","Z0D_FILIAL+Z0D_BANCO+Z0D_AGE+Z0D_CTA+Z0D_SUBCTA+Z0D_OPERA","Filial+Banco+Agencia+Conta+SubConta+Operacao","","","U","","","S","2","3"})
	aAdd(aSIX,{"SA6","4","A6_FILIAL+A6_COD+A6_CODCLI+A6_LOJCLI","Filial+Banco+CodCliente+LojaCliente","","","U","","","S","2","3"})
	aAdd(aSIX,{"Z0F","1","Z0F_FILIAL+Z0F_IDCNAB+Z0F_REFBAN+Z0F_OCORRE+Z0F_DTPROC+Z0F_HRPROC","Filial+IdCnab+REFBAN+Ocorre+DtProc+HrProc","","","U","","","S","2","3"})
	aAdd(aSIX,{"Z0F","2","Z0F_FILIAL+Z0F_IDCNAB+Z0F_OCORRE+Z0F_DTPROC+Z0F_HRPROC","Filial+IdCnab+Ocorre+DtProc+HrProc","","","U","","","S","2","3"})
	aAdd(aSIX,{"Z0F","3","Z0F_FILIAL+Z0F_PREFIX+Z0F_NUM+Z0F_PARCEL+Z0F_TIPO+Z0F_FORCLI","Filial+Prefixo+Titulo+Parcela+ForneCli","","","U","","","S","2","3"})
	/*=====================================================================================================================================*/

	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*************** SX6 - Par�metros do sistema *******************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/

	aSX6 := {}
	//Parametros     |Filial|   |Vari�vel|   |Tipo| |Descri��o|                                             |Descri��o E| |Descri��o I| |Descri��o|                                    |Descri��o E| |Descri��o I| |Descri��o| |Descri��o E| |Descri��o I| |Conte�do|                                |Connnte�do E| |Conte�do I| |Propriedade|  |PYME|  |X6_VALID| |X6_INIT|	|X6_DEFPOR|	|X6_DEFSPA|	|X6_DEFENG
	aAdd(aSX6,       {xFilial(),"MV_P_00122" ,"L"   ,"Se a empresa � Corporativa (.T.) ou Cliente (.F.)"   ,""           ,""           ," cria diret�rio (corporativo) ou (cliente)"  	,""           ,""           ,""         ,""           ,""           ,".F."                                    ,""          ,""          ,"U"           ,""     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_P_00130" ,"L"   ,"Se a empresa utiliza a rotina da Accesstage (.T.)"   ,""           ,""           ," se n�o (.F.)"  								,""           ,""           ,""         ,""           ,""           ,".F."                                    ,""          ,""          ,"U"           ,""     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_P_00131" ,"C"   ,"Email para recebimento da ocorrencias CNAB retorn"   ,""           ,""           ,"nado via Accesstage"  							,""           ,""           ,""         ,""           ,""           ,"log.finnet@hlb.com.br"               	  ,""          ,""          ,"U"           ,""     ,""        ,""       ,""         ,""         ,"" })				//CAS - 10/09/2020 Adicionado o e-mail "log.finnet@hlb.com.br" no conteudo do parametro
	aAdd(aSX6,       {xFilial(),"MV_P_00132" ,"C"   ,"Endere�o do servidor dos diret�rios CNAB Accessta"   ,""           ,""           ,"ge"  											,""           ,""           ,""         ,""           ,""           ,"\\SRVDCAPP04.ZION.LAN\FINNET\FINNET\"	  ,""          ,""          ,"U"           ,""     ,""        ,""       ,""         ,""         ,"" })				//CAS - 01/04/2020 \\SRVDCHOMAPP05.zion.lan\FINNET\FINNET\    -  CAS - 22/01/2020 Ajustado o caminho para \\SRVDCAPP04.PCS.LAN\FINNET\FINNET\   OSB: era \\SRVDCAPP04\e$\FINNET\ 
	//aAdd(aSX6,       {""    ,"EZ_SAPSWD"  ,"N"   ,"Sequencial tabela SWD para agrupamento de despesas"  ,""           ,""           ,""                                            	,""           ,""           ,""         ,""           ,""           ,"0000000000"                             ,""          ,""          ,"U"           ,""     ,""        ,""       ,""         ,""         ,"" })

	//CAS - 15/09/2020 Ajuste nos parametros para arredondar valor dos impostos do PCC
	//Parametros     |Filial|   |Vari�vel|   |Tipo| |Descri��o|                                             |Descri��o E| 										 	|Descri��o I| 											|Descri��o|                                    			|Descri��o E| 											|Descri��o I| 											|Descri��o| 											|Descri��o E| 											|Descri��o I| 											|Conte�do|      |Connnte�do E| |Conte�do I| |Propriedade|  |PYME|  |X6_VALID| |X6_INIT|	|X6_DEFPOR|	|X6_DEFSPA|	|X6_DEFENG
	aAdd(aSX6,       {xFilial(),"MV_RNDCOF"  ,"L"   ,"Informe o critério de arredondamento do COFINS de "   ,"Informe el critério de rredondeo de COFINS de     "	,"Enter the roundoff criterion of COFINS withholding"	,"retenção. As opções validas são: .T. arrendonda,  "	,"retencion. Las opciones validas son: .T. rrendonde"	,"Valid options are: .T.round off,                  "	,".F. trunca.                                       "	,".F. trunca.                                       "	,".F. truncate.                                     "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_RNDCSL"  ,"L"   ,"Informe o critério de arredondamento da CSLL. As  "   ,"Informe el criterio de redondeo de la CSLL. Las   "	,"Enter the round criterion of CSLL. The valid      "	,"opções válidas são: .T. arredonda, .F. trunca.    "	,"opciones válidas son: .T. redondea, .F. interrumpe"	,"options are: .T. round. .F. truncate.             "	,"                                                  "	,"                                                  "	,"                                                  "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_RNDPIS"  ,"L"   ,"Informe o critério de arredondamento do PIS de    "   ,"Informe el criterio de redondeo del PIS de        "	,"Enter the round off criterion of PIS withholding  "	,"retenção. As opções validas são: .T. arrendonda,  "	,"retencion. Las opciones validas son: .T.rendondea "	,"Valid options are: .T.round off,                  "	,".F. trunca.                                       "	,".F. trunca.                                       "	,".F. truncate.                                     "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_RNDSOBR" ,"L"   ,"Indica se no truncamento dos impostos, o valor    "   ,"Indica si, cuando se divida el valor del impuesto,"	,"It indicates whether in tax truncation, value     "	,"referente a terceira casa decimal (sobras)        "	,"el tercer decimal (sobras)                        "	,"referring to the third decimal place (surplus) are"	,"continuam a ser consideradas (.T.), ou nao (.F.)  "	,"aun se considerara (.T.), o no (.F.)              "	,"still considered (.T.) or not (.F.).              "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })
	//CAS - 11/02/2021 Ajuste nos parametros para arredondar valor dos impostos do ISS/INS/IRF
	aAdd(aSX6,       {xFilial(),"MV_RNDISS"  ,"L"   ,"Controle para arredondamento de ISS onde .T. é    "   ,"Control para redondeo de ISS donde .T. se         "	,"ISS round off controi, whose .T. means            "	,"arredondado e .F. não é arredondado               "	,"redondeara y .F. no se redondeara.                "	,"rounded off and .F. is not rounded off.           "	,"                                                  "	,"                                                  "	,"                                                  "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_RNDINS"  ,"L"   ,"Informe o critério de arredondamento da INSS. As  "   ,"Informe el criterio de redondeo de INSS. Las      "	,"Enter round up criterion for INSS.                "	,"opções válidas são: .T. arredonda, .F. trunca.    "	,"opciones validas son: .T. redondea, .F. omite.    "	,"Valid options:: .T. round, .F. breaks.            "	,"                                                  "	,"                                                  "	,"                                                  "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })
	aAdd(aSX6,       {xFilial(),"MV_RNDIRF"  ,"L"   ,"Informe o critério de arredondamento da IRRF. As  "   ,"Informe el criterio de redondeo del IRRF. Las     "	,"Enter round criterion for IRRF.                   "	,"opções válidas são: .T. arredonda, .F. trunca.    "	,"opciones validas son: .T. redondea, .F. omite.    "	,"Valid options:: .T. round, .F. breaks.            "	,"                                                  "	,"                                                  "	,"                                                  "	,".T."			,".T."			,".T."      ,"S"           ,"S"     ,""        ,""       ,""         ,""         ,"" })

	/*=====================================================================================================================================*/

	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*********** SX7 - Gatilhos de campos do sistema ***************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/
	aSX7 := {}

	//SE2 CONTAS A PAGAR
	AADD(aSX7,{ "E2_P_MULTA", "001", "M->E2_P_MULTA", "E2_MULTA","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E2_P_JUROS", "001", "M->E2_P_JUROS", "E2_JUROS","P", "N", "", 0, "", "", "U" })

	AADD(aSX7,{ "E2_CODBAR", "001", "IIF(EMPTY(E2_LINDIG),U_GTFIN038(10,''),E2_LINDIG)", "E2_LINDIG","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E2_LINDIG", "001", "IIF(EMPTY(E2_CODBAR),U_GTFIN038(10,''),E2_CODBAR)", "E2_CODBAR","P", "N", "", 0, "", "", "U" })

	AADD(aSX7,{ "E2_VALOR", "001", "M->E2_VALOR", "E2_P_VLINS","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E2_P_VRENT", "001", "(M->E2_VALOR+M->E2_P_VRENT)", "E2_P_VLINS","P", "N", "", 0, "", "", "U" })

	//Posicione("SA2",1,xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA,"A2_BANCO")  
	//IF(ALLTRIM(GetVersao(.F.)) == '11')       
	//cCampo := "A2_DVCTA"
	//cCampo := "A2_DVAGE"                      
	    AADD(aSX7,{ "E2_FORNECE", "Z01", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_BANCO')", "E2_FORBCO","P", "N", "", 0, "", "", "U" })
	    AADD(aSX7,{ "E2_FORNECE", "Z02", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_AGENCIA')", "E2_FORAGE","P", "N", "", 0, "", "", "U" })
		AADD(aSX7,{ "E2_FORNECE", "Z03", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_DVCTA')", "E2_FAGEDV","P", "N", "", 0, "", "", "U" })
	    AADD(aSX7,{ "E2_FORNECE", "Z04", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_NUMCON')", "E2_FORCTA","P", "N", "", 0, "", "", "U" })
		AADD(aSX7,{ "E2_FORNECE", "Z05", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_DVAGE')", "E2_FCTADV","P", "N", "", 0, "", "", "U" })
	//ENDIF

	AADD(aSX7,{ "E2_FORNECE", "Z06", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_NOME')", "E2_P_NOMBN","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E2_FORNECE", "Z07", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_CGC')", "E2_P_CGCBN","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E2_FORNECE", "Z08", "Posicione('SA2',1,xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA,'A2_TIPO')", "E2_P_TIPO","P", "N", "", 0, "", "", "U" })

	
	//SE1 CONTAS A RECEBER
	AADD(aSX7,{ "E1_P_MULTA", "001", "M->E1_P_MULTA", "E1_MULTA","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E1_P_JUROS", "001", "M->E1_P_JUROS", "E1_JUROS","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E1_P_MULTA", "002", "IIF(M->E1_DECRESC>0,0,M->E1_P_MULTA+M->E1_P_JUROS)", "E1_ACRESC","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "E1_P_JUROS", "002", "IIF(M->E1_DECRESC>0,0,M->E1_P_JUROS+M->E1_P_MULTA)", "E1_ACRESC","P", "N", "", 0, "", "", "U" })

    //SA1 CADASTRO CLIENTES
	AADD(aSX7,{ "A1_BCO1", "001", "Posicione('SA6',4,xFilial('SA6')+M->A1_BCO1+M->A1_COD+M->A1_LOJA,'A6_AGENCIA')", "A1_P_AGECL","P", "N", "", 0, "", "", "U" })
	AADD(aSX7,{ "A1_BCO1", "002", "Posicione('SA6',4,xFilial('SA6')+M->A1_BCO1+M->A1_COD+M->A1_LOJA,'Alltrim(A6_NUMCON)+A6_DVCTA')", "A1_P_CTACL","P", "N", "", 0, "", "", "U" })

	/*=====================================================================================================================================*/

	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//***********       SXB - Consulta padr�o         ***************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/
	SXB->(DbSetOrder(1))
	aSXB := {}

	//CONSULTA PADR�O ESTADO E MUNICIPIO
	        //{XB_ALIAS, XB_TIPO, XB_SEQ, XB_COLUNA,  XB_DESCRI,            XB_DESCSPA,           XB_DESCENG,           XB_CONTEM                     }
	AADD(aSXB,{"CC2SE2", "1",     "01",   "DB",       "Municipio Tributos", "Municipio Tributos", "Municipio Tributos", "CC2"                         })
	AADD(aSXB,{"CC2SE2", "2",     "01",   "01",       "Estado+Municipio",   "Estado+Municipio",   "Estado+Municipio",   ""                            })
	AADD(aSXB,{"CC2SE2", "4",     "01",   "01",       "Estado",             "Estado",             "Estado",             "CC2_EST"                     })
	AADD(aSXB,{"CC2SE2", "4",     "01",   "02",       "Cod.IBGE",           "Cod.IBGE",           "Cod.IBGE",           "CC2_CODMUN"                  })
	AADD(aSXB,{"CC2SE2", "4",     "01",   "03",       "Municipio",          "Municipio",          "Municipio",          "CC2_MUN"                     })
	AADD(aSXB,{"CC2SE2", "5",     "01",   "",         "Valor de Retorno",   "Valor de Retorno",   "Valor de Retorno",   "CC2->CC2_CODMUN"             })
	AADD(aSXB,{"CC2SE2", "6",     "01",   "",         "Filtro",             "Filtro",             "Filtro",             "CC2->CC2_EST==M->E2_P_UFIPV" })

	AADD(aSXB,{"ARQCNB", "1",     "01",   "RE",       "Arquivo Cnab", "Arquivo Cnab", "Arquivo Cnab", "Z0F"                         })
	AADD(aSXB,{"ARQCNB", "2",     "01",   "01",       "",   "",   "",   "U_GTFIN039(5,'AFI430')"                            })
	AADD(aSXB,{"ARQCNB", "5",     "01",   "",         "",   "",   "",   ""             })
	//CAS 16-07-2019 Inclu�do no Consulta Padr�o(ARQCNR) para o grupo de perguntas do Contas a Receber(AFI200)
	AADD(aSXB,{"ARQCNR", "1",     "01",   "RE",       "Arquivo Cnab", "Arquivo Cnab", "Arquivo Cnab", "Z0F"                         })
	AADD(aSXB,{"ARQCNR", "2",     "01",   "01",       "",   "",   "",   "U_GTFIN039(5,'AFI200')"                            })
	AADD(aSXB,{"ARQCNR", "5",     "01",   "",         "",   "",   "",   ""             })

	If !SXB->(DbSeek("FIL"))
		//CONSULTA PADR�O BANCO FORNECEDOR
		AADD(aSXB,{"FIL", "1",     "01",   "DB",       "C/C de fornecedores", "C/C de fornecedores", "C/C de fornecedores", "FIL"                                                  })
		AADD(aSXB,{"FIL", "2",     "01",   "01",       "Fornecedor+Banco",    "Fornecedor+Banco",    "Fornecedor+Banco",    ""                                                     })
		AADD(aSXB,{"FIL", "4",     "01",   "01",       "Conta",               "Conta",               "Conta",               "FIL_CONTA"                                            })
		AADD(aSXB,{"FIL", "4",     "01",   "02",       "Ag�ncia",             "Ag�ncia",             "Ag�ncia",             "FIL_AGENCI"                                           })
		AADD(aSXB,{"FIL", "4",     "01",   "03",       "Banco",               "Banco",               "Banco",               "FIL_BANCO"                                            })
		AADD(aSXB,{"FIL", "5",     "01",   "",         "",                    "",                    "",                    "FIL_BANCO"                                            })
		AADD(aSXB,{"FIL", "5",     "02",   "",         "",                    "",                    "",                    "FIL_AGENCI"                                           })
		AADD(aSXB,{"FIL", "5",     "03",   "",         "",                    "",                    "",                    "FIL_CONTA"                                            })
		AADD(aSXB,{"FIL", "6",     "01",   "",         "",                    "",                    "",                    "FIL_FORNEC==SA2->A2_COD .And. FIL_LOJA==SA2->A2_LOJA" })
	EndIf
	
	
	/*=====================================================================================================================================*/

	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//***********       XNU - Menu do sistema         ***************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////
	/*=====================================================================================================================================*/
	
	//aMenu := {}
	//AADD(aMenu,{"SIGAFIN","U_PADRAO","U_UFINA130"    ,""     ,"Par�metros de Bancos"      ,"1"        ,{}     ,     .F.   ,"SIGAFIN"  , "6"     }) //incluir menu e items
	//AADD(aMenu,{"SIGAEIC","U_TESTE1","U_TESTE2"    ,             ,"Opcao 2"      ,"3"        ,{}     ,     .F.   ,"SIGAEIC"  , "5"     }) //incluir menu e items



	/*=====================================================================================================================================*/
	Return .T.
	*=====================================================================================================================================*

/*/{Protheus.doc} OrdemSX3
//TODO Descri��o auto-gerada.
@author Alessandro Rodrigues/Daniel Lima
@since 18/01/2018
@version 1.0
@return ${return}, ${return_description}
@param cOrd, characters, descricao
@type function
/*/
Static Function OrdemSX3(cOrd)
	*=====================================================================================================================================*
	Local cOrdem := ""

	If Right(cOrd,1) == "9"
		cOrdem := Soma1(Left(cOrd,1)) + "0"
	Else
		cOrdem := Soma1(cOrd)
	EndIf

	cOrd := cOrdem

	Return cOrdem
	*=====================================================================================================================================*
//########## Fim do Fonte Carregado em : 07/02/2018 as 16:04:10 #############
