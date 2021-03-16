#include 'protheus.ch'


/*
FUNÇÃO		:   Update
*/

*==============================*
USER FUNCTION GRSX3082() //GRSX3082
*==============================*

U_Upd_Fabr('U_USX3082')

RETURN .T.

/*/{Protheus.doc} USX3082
//TODO Inclusão
@author Alessandro Rodrigues/Daniel Lima
@since 18/01/2018
@version 1.0
@return ${return}, ${return_description}
@param lDesc, logical, descricao
@type function
/*/
USER FUNCTION USX3082(lDesc)
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

    /******************************
    alteração campos SX3 
    ******************************/

    SX3->(DbSetOrder(2))

	//Alteração de campos - INICIO
	aAltera := {}

	/******************************
    alteração das pastas dos campos
    ******************************/

	/*cOrdTrb := 0
	cChaveXA := "SE2"
	SXA->(DbSetOrder(1))
	SXA->(DbSeek( AVKEY(cChaveXA,'XA_ALIAS') ))
	Do While !SXA->(EOF()) .And. SXA->XA_ALIAS == AVKEY(cChaveXA,'XA_ALIAS')
		IF SXA->XA_DESCRIC == "Pag. Tributos                 "
			cOrdTrb := VAL(SXA->XA_ORDEM)
		ENDIF
		SXA->(DbSkip())
	EndDo

	//SE ESTIVER NA VERSÃO 11 DO PROTHEUS COLOCA TODOS OS CAMPOS NA PASTA 1
	IF(ALLTRIM(GetVersao(.F.)) == '11')  
		cChave := "SE2"
		SX3->(DbSetOrder(1))
		SX3->(DbSeek( AVKEY(cChave,'X3_ARQUIVO') ))
		Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == AVKEY(cChave,'X3_ARQUIVO')
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_FOLDER', '1',} )
			SX3->(DbSkip())
		EndDo
	ENDIF

    //MANTER NESSA POSIÇÃO POIS ESTA PEGANDO O NUMERO DA PASTA
    //FOLDER PARA TRIBUTOS
	aUnidCpo := {"E2_P_TRIB"  ,"E2_P_TPCON" ,"E2_P_CGCON" ,"E2_P_COMPE" ,"E2_P_VRENT","E2_P_REFE" ,;
    "E2_P_REBRU" ,"E2_P_PERRB" ,"E2_P_INSCR" ,"E2_P_DIVAT","E2_P_PARCE" ,"E2_P_RENAV" ,"E2_P_UFIPV" ,;
    "E2_P_CDMUN" ,"E2_P_PLACA","E2_P_OPPAG" ,"E2_P_OPRET" ,"E2_P_DCORI" ,"E2_P_VLMON" ,"E2_P_CODRE",;
    "E2_P_MULTA" ,"E2_P_JUROS" ,"E2_P_NMCON" ,"E2_P_VLINS" ,"E2_P_IDFGT","E2_P_LCSOC","E2_P_DGSOC"}

	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			aAdd( aAltera, {"SX3",      2, SX3->X3_CAMPO, 'X3_FOLDER', CVALTOCHAR(cOrdTrb),} )
		ENDIF
	Next i

	*/


	//CAMPO TIPO DATA DA TABELA SEE ALTERANDO PARA VISIVEL E USADO
	//aUnidCpo := {"EE_TIPODAT", "E2_MULTA", "E2_JUROS"}
	aUnidCpo := {"EE_TIPODAT"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_USADO', cUsado, SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_VISUAL', "A", SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_CONTEXT', "R", SX3->X3_ARQUIVO} )
		EndIf
	Next i
	
	//CAS - 01/09/2020 - Ajuste para deixar os campos EE_DVAGE/EE_DVCTA editáveis
	aUnidCpo := {"EE_DVAGE"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_USADO', cUsado, SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_VISUAL', "A", SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_CONTEXT', "R", SX3->X3_ARQUIVO} )
		EndIf
	Next i
	aUnidCpo := {"EE_DVCTA"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_USADO', cUsado, SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_VISUAL', "A", SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_CONTEXT', "R", SX3->X3_ARQUIVO} )
		EndIf
	Next i

	aUnidCpo := {"EE_CODEMP"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_TAMANHO', 020, SX3->X3_ARQUIVO} )
			
		EndIf
	Next i

	aUnidCpo := {"EE_DIRPAG","EE_DIRREC","EE_BKPPAG","EE_BKPREC"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_TAMANHO', 99, SX3->X3_ARQUIVO} )
			
		EndIf
	Next i
	
	//CAMPO TIPO DATA DA TABELA SEE ALTERANDO PARA VISIVEL E USADO
	aUnidCpo := {"E2_MULTA", "E2_JUROS"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_USADO', cNoUsa, SX3->X3_ARQUIVO} )
		EndIf
	Next i

	//CAMPOS CODIGO DE BARRAS
	If SX3->(DbSeek( AVKEY("E2_CODBAR",'X3_CAMPO') ))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
		IF ( SX3->X3_TAMANHO > 44)
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_TAMANHO', 44, SX3->X3_ARQUIVO} )
		ENDIF
		IF(ALLTRIM(GetVersao(.F.)) == '11') 
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_VALID', "Vazio() .OR. U_GTFIN039(2,M->E2_CODBAR)", SX3->X3_ARQUIVO} )
		ENDIF
		aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_TRIGGER', "S", SX3->X3_ARQUIVO} )
		aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_USADO', cUsado, SX3->X3_ARQUIVO} )
	EndIf

	//CAMPO LINHA DIGITAVEL
	If SX3->(DbSeek( AVKEY("E2_LINDIG",'X3_CAMPO') ))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
		IF(ALLTRIM(GetVersao(.F.)) == '11') 
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_VALID', "Vazio() .OR. U_GTFIN039(2,M->E2_LINDIG)", SX3->X3_ARQUIVO} )
		ENDIF
		aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_TRIGGER', "S", SX3->X3_ARQUIVO} )
	EndIf

	
	//GATILHOS PARA OS CAMPOS
	aUnidCpo := {"A1_BCO1", "E2_VALOR", "E2_P_VRENT", "E2_FORNECE"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_TRIGGER', "S", SX3->X3_ARQUIVO} )
		EndIf
	Next i

	aUnidCpo := {"E2_FORBCO"}
	For i:=1 To Len(aUnidCpo)
		If SX3->(DbSeek( AVKEY(aUnidCpo[i],'X3_CAMPO') ))
			//{Alias , Indice, Chave, Campo a ser alterado, conteudo, }
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_F3', 'FIL', SX3->X3_ARQUIVO} )
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_PROPRI', 'U', SX3->X3_ARQUIVO} )
			
		EndIf
	Next i
	//Alteração de campos - FIM

    //Alteração do pergunte
	SX1->(DbSetOrder(1))

	//PERGUNTE REMESSA A PAGAR - AFI420
	If SX1->(DbSeek( 'AFI420    '+'01'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI420")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI420    '+'03'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI420")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI420    '+'04'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI420")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI420    '+'05'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI420")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI420    '+'08'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI420")'  } )
	EndIf

	//PERGUNTE REMESSA A PAGAR - FIN650
	If SX1->(DbSeek( 'FIN650    '+'01'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_TAMANHO', 99   } )						//CAS 16-07-2019 Incluída esta linha para aumento do campo para 99
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_GSC', 'F'   } )							//CAS 16-07-2019 Incluída esta linha para alterar o Grupo para 'F'
	EndIf	

	//PERGUNTE RETORNO A PAGAR - AFI430
	If SX1->(DbSeek( 'AFI430    '+'03'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI430")'  } )
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_TAMANHO', 99   } )						//CAS 16-07-2019 Incluída esta linha para aumento do campo para 99
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_F3', 'ARQCNB'   } )						//CAS 16-07-2019 Incluída esta linha para Consulta padrao 'ARQCNB'
	EndIf
	
	If SX1->(DbSeek( 'AFI430    '+'04'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI430")'  } )
	EndIf
	
	If SX1->(DbSeek( 'AFI430    '+'05'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI430")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI430    '+'08'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI430")'  } )
	EndIf

	//PERTUNTE REMESSA A RECEBER - AFI150
	If SX1->(DbSeek( 'AFI150    '+'01'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI150")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI150    '+'03'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI150")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI150    '+'04'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI150")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI150    '+'05'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI150")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI150    '+'08'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI150")'  } )
	EndIf

	////PERGUNTE RETORNO A RECEBER - AFI200
	
	If SX1->(DbSeek( 'AFI200    '+'04'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI200")'  } )
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_TAMANHO', 99   } )						//CAS 16-07-2019 Incluída esta linha para aumento do campo para 99
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_F3', 'ARQCNR'   } )						//CAS 16-07-2019 Incluída esta linha para Consulta padrao 'ARQCNR' do Contas a Receber 
	EndIf
	
	If SX1->(DbSeek( 'AFI200    '+'05'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI200")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI200    '+'06'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI200")'  } )
	EndIf
	If SX1->(DbSeek( 'AFI200    '+'09'))
		//{Alias , Indice, Chave, Campo a ser alterado, conteudo, se recria o arquivo}
		aADD(aAltera, {"SX1", 1, SX1->X1_GRUPO+SX1->X1_ORDEM ,'X1_VALID', 'U_GTFIN038(3,"AFI200")'  } )
	EndIf
	
	////PERGUNTE AFI430 RETORNO DE PAGAMENTO MANUAL FINA430 

	


	

    /*=====================================================================================================================================*/

	///////////////////////////////////////////////////////////////////
	//***************************************************************//
	//*************** SXA - Pastas e agrupamentos *******************//
	//*************** dos campos do sistema       *******************//
	//***************************************************************//
	///////////////////////////////////////////////////////////////////

	/*=====================================================================================================================================*/
	//Criação de pasta para a tabela SE2
	cChaveXA := "SE2"
	SXA->(DbSetOrder(1))
	SXA->(DbSeek( AVKEY(cChaveXA,'XA_ALIAS') ))
	Do While !SXA->(EOF()) .And. SXA->XA_ALIAS == AVKEY(cChaveXA,'XA_ALIAS')
		cOrdXA := VAL(SXA->XA_ORDEM)
		cOrdTrb := IF(SXA->XA_DESCRIC == "Pag. Tributos                 ",VAL(SXA->XA_ORDEM),0)
		SXA->(DbSkip())
	EndDo

	//dbSelectArea("SXA")
	aSXA := {}
	IF cOrdXA == 0
		cOrdXA := cOrdXA + 1
		//         XA_ALIAS	| XA_ORDEM               | XA_DESCRIC        | XA_DESCSPA         | XA_DESCENG        | XA_PROPRI | XA_AGRUP | XA_TIPO
		AADD(aSXA,{cChaveXA ,CVALTOCHAR(cOrdXA)      , "Dados Gerais"   , "Dados Gerais"    , "Dados Gerais"   , "U"       , ""       , ""})

	ENDIF

	//SE ESTIVER NA VERSÃO 11 DO PROTHEUS COLOCA TODOS OS CAMPOS NA PASTA 1
	IF(ALLTRIM(GetVersao(.F.)) == '11')  
		cChave := "SE2"
		SX3->(DbSetOrder(1))
		SX3->(DbSeek( AVKEY(cChave,'X3_ARQUIVO') ))
		Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == AVKEY(cChave,'X3_ARQUIVO')
			aAdd( aAltera, {"SX3",  2, SX3->X3_CAMPO, 'X3_FOLDER', '1',} )
			SX3->(DbSkip())
		EndDo
	ENDIF

	IF cOrdTrb == 0
		cOrdTrb := cOrdXA + 1
		AADD(aSXA,{cChaveXA , CVALTOCHAR(cOrdTrb) , "Pag. Tributos" , "Pag. Tributos"  , "Pag. Tributos"  , "U"   , ""    , ""})
	ELSE
		AADD(aSXA,{cChaveXA , CVALTOCHAR(cOrdTrb) , "Pag. Tributos" , "Pag. Tributos"  , "Pag. Tributos"  , "U"   , ""    , ""})
	ENDIF


	//FOLDER PARA TRIBUTOS
	aCpoSE2 := {"E2_P_TRIB"  ,"E2_P_TPCON" ,"E2_P_CGCON" ,"E2_P_COMPE" ,"E2_P_VRENT",;
				"E2_P_REFE"  ,"E2_P_REBRU" ,"E2_P_PERRB" ,"E2_P_INSCR" ,"E2_P_DIVAT",;
				"E2_P_PARCE" ,"E2_P_RENAV" ,"E2_P_UFIPV" ,"E2_P_CDMUN" ,"E2_P_PLACA",;
				"E2_P_OPPAG" ,"E2_P_OPRET" ,"E2_P_DCORI" ,"E2_P_VLMON" ,"E2_P_CODRE",;
				"E2_P_MULTA" ,"E2_P_JUROS" ,"E2_P_NMCON" ,"E2_P_VLINS" ,"E2_P_IDFGT",;
				"E2_P_LCSOC","E2_P_DGSOC"}

	For c:=1 To Len(aCpoSE2)
		SX3->(DbSetOrder(2))
	   If SX3->(DbSeek( AVKEY(aCpoSE2[c],'X3_CAMPO') ))
	                   //{Alias, Indice,         Chave, Campo a ser alterado,            conteudo,}
	      aAdd( aAltera, {"SX3",      2, SX3->X3_CAMPO,          'X3_FOLDER', CVALTOCHAR(cOrdTrb),} )
	   EndIf
	Next c

    
	/*=====================================================================================================================================*/
	Return .T.
	*=====================================================================================================================================*

/*/{Protheus.doc} OrdemSX3
//TODO Descrição auto-gerada.
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
