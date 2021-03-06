#Include "PROTHEUS.CH"
#Include "FINA435.CH"


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FinA435  � Autor � Aldo Barbosa dos Santos� Data � 31/05/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno da comunica��o banc�ria via Job - Pagar             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � FinA205()                                                   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS                                          ���
��������������������������������������������������������������������������Ĵ��
���           	�  /  /  �      �                                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function UFinA435(aParam)

Local nCntFor

// Executa apenas se for chamado pelo Schedule
// a variavel abaixo e util para debug da rotina via execucao normal
Private lExecJob := .F.
Private aMsgSch  := {}

// seta uma empreas 
//RpcSetEnv( '99', '01' )

Private cCadastro  := STR0001 // "Retorno Bancario Automatico (Pagar)"

ConOut("*** CUSTOMIZA��O EZ4 "+cCadastro+Dtoc(Date())+" "+Time()+" LINHA: 36")

if Valtype(aParam) <> "A"
	ConOut("*** - "+STR0002) // "Processo pode ser executado apenas via Schedule"
	Return Nil
Endif

lExecJob := .T.

// manter posicionado pois o FINA200 vai utilizar estas informacoes
if Valtype(aParam) == "A"
	RpcSetEnv( aParam[1], aParam[2] )
Endif

BatchProcess(cCadastro, cCadastro , "FA435JOB" , { || FA435JOB() } , { || .F. } )

// se o parametro nao esta definido, envia as mensagens para o console
If Empty(GetMv("MV_RETMAIL",, "")) .and. Len(aMsgSch) > 0
	For nCntFor := 1 to Len(aMsgSch)
		ConOut(aMsgSch[nCntFor])
	Next
EndIf

ConOut("*** CUSTOMIZA��O EZ4 "+cCadastro+Dtoc(Date())+" "+Time()+" LINHA: 59")

Return Nil



/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FA435JOB � Autor � Aldo Barbosa dos Santos� Data � 15/05/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno da comunica��o banc�ria via Job                     ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � FA435JOB()                                                  ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS                                          ���
��������������������������������������������������������������������������Ĵ��
���           	�  /  /  �      �                                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FA435JOB()

Local cPerg	:= Padr("AFI430",Len(SX1->X1_GRUPO))
Local cQuery  // query de bancos que serao executados automaticamente
Local aVetPar // vetor das perguntas
Local cAlias  // alias temporario dos banco que serao executados
Local nA, nB

SEE->( Dbsetorder(1))

// le as perguntas do FINA430 que serao modificadas de acordo com os novos
// campos da tabela de bancos
//Pergunte(cPergunta,lAsk,cTitle,lOnlyView,oDlg,lUseProf,aPerg,lBreakLine,lHasHelp)
Pergunte(cPerg,    .F., Nil,    Nil,     Nil, .F.)

// seleciona todas as contas que estao programadas para recebimento automatico
cQuery := "SELECT R_E_C_N_O_ REGSEE "
cQuery += " FROM "+RetSqlName("SEE")+ " SEE "
cQuery += "WHERE EE_FILIAL ='"+xFilial("SEE")+"'"
cQuery += "  AND EE_RETAUT IN ('2','3') " // 1.recebimento; 3.ambos
cQuery += "  AND SEE.D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY EE_DIRREC"

cAlias := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.T.,.T.)

Do While (cAlias)->( ! Eof())
	// manter posicionado pois o FINA430 vai utilizar estas informacoes
	SEE->( Dbgoto( (cAlias)->REGSEE))

	//����������������������������������������������������Ŀ
	//� Perguntas do FINA430                               �
	//�                                                    �
	//� MV_PAR01: Mostra Lanc. Contab  ? Sim Nao           �
	//� MV_PAR02: Aglutina Lanc. Contab? Sim Nao           �
	//� MV_PAR03: Arquivo de Entrada   ?                   �
	//� MV_PAR04: Arquivo de Config    ?                   �
	//� MV_PAR05: Banco                ?                   �
	//� MV_PAR06: Agencia              ?                   �
	//� MV_PAR07: Conta                ?                   �
	//� MV_PAR08: SubConta             ?                   �
	//� MV_PAR09: Contabiliza          ?                   �
	//� MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2  �
	//� MV_PAR11: Processa filiais     ? Modelo1 Modelo 2  �
	//������������������������������������������������������

	// verifica se todos os parametros necessarios foram preechindos e grava no log
	if ! SEE->EE_RETAUT $ "123" .or. FA205ERRO()
		(cAlias)->( Dbskip())
		Loop
	Endif	

	// atualiza o pergunte do FINA200 de acordo com a tabela de bancos
	aVetPar := {{mv_par01,'2'						},; // 01	Mostra Lanc Contab ?
					{mv_par02,SEE->EE_AGLCTB		},; // 02	Aglut Lancamentos ?
					{mv_par03, mv_par03          	},; // 03	Arquivo de Entrada ?
					{mv_par04,SEE->EE_CFGPAG		},; // 04	Arquivo de Config ?
					{mv_par05,SEE->EE_CODIGO		},; // 05	Codigo do Banco ?
					{mv_par06,SEE->EE_AGENCIA		},; // 06	Codigo da Agencia ?
					{mv_par07,SEE->EE_CONTA			},; // 07	Codigo da Conta ?
					{mv_par08,SEE->EE_SUBCTA		},; // 08	Codigo da Sub-Conta ?
					{mv_par09, '2'						},; // 09	Contabiliza On Line ?
					{mv_par10,SEE->EE_CNABPG 		},; // 10	Configuracao CNAB ?
					{mv_par11,SEE->EE_PROCFL		},; // 11	Processa Filial?
					{mv_par12,'2'						}}  // 12	Considera Multiplas naturezas ?

	// le os arquivos do diretorio configurado
	cDirArq := Alltrim(SEE->EE_DIRPAG)
	cDirBk  := Alltrim(SEE->EE_BKPPAG)
	aArq    := Directory(cDirArq+"*.*")
	For nA := 1 to Len(aArq)
		// armazena o nome do arquivo nos parametros
		aVetPar[03,2] := cDirArq+aArq[nA,1]

		// atualiza as perguntas do FINA430 conforme os dados do arquivo de bancos
		SX1->( dbSetORder(1))
		For nB := 1 to Len(aVetPar)
			If SX1->( DbSeek(PadR( cPerg, Len(SX1->X1_GRUPO)) +Strzero(nB,2)))
				Reclock("SX1",.F.)
				ConOut("## EZ4 - FINA430: "+CVALTOCHAR(nB)+" = "+CVALTOCHAR(aVetPar[nB,2]))
					SX1->X1_CNT01 := SUBSTR(aVetPar[nB,2],1,60)
					SX1->X1_CNT02 := SUBSTR(aVetPar[nB,2],61)

				if SX1->X1_GSC == "C"
					SX1->X1_PRESEL := Val(aVetPar[nB,2])
				Endif	

				SX1->( MsUnlock() )
		    EndIf
		Next

		// atualiza o pergunte do FINR650
		aVet650 := {{mv_par01	, aVetPar[03,2]	},; // 01 Arquivo de Entrada ?          	 
						{mv_par02	, SEE->EE_CFGPAG	},; // 02 Arquivo de Config ?           	
						{mv_par03	, SEE->EE_CODIGO	},; // 03 Codigo do Banco ?             
						{mv_par04	, SEE->EE_AGENCIA	},; // 04 Codigo da Agencia ?           
						{mv_par05	, SEE->EE_CONTA	},; // 05 Codigo da Conta ?             
						{mv_par06	, SEE->EE_SUBCTA	},; // 06 Codigo da SubConta ?          
						{mv_par07	, "2"					},; // 07 Carteira ?  1=Receber;2=Pagar
						{mv_par08	, SEE->EE_CNABPG	}}  // 08 Configuracao CNAB ?           

		// atualiza as perguntas do FINR650 conforme os dados do arquivo de bancos
		SX1->( dbSetORder(1))
		For nB := 1 to Len(aVet650)
			If SX1->( DbSeek(PadR("FIN650", Len(SX1->X1_GRUPO)) +Strzero(nB,2)))
				Reclock("SX1",.F.)
				ConOut("## EZ4 - FINR650: "+CVALTOCHAR(nB)+" = "+CVALTOCHAR(aVet650[nB,2]))
					SX1->X1_CNT01 := SUBSTR(aVet650[nB,2],1,60)
					SX1->X1_CNT02 := SUBSTR(aVet650[nB,2],61)

				if SX1->X1_GSC == "C"
					SX1->X1_PRESEL := Val(aVet650[nB,2])
				Endif	

				SX1->( MsUnlock() )
		    EndIf
		Next

  		// controle de mensagens de erro
  		aMsgSch := {}

  		// controle de titulos baixados
  		aFA205R := {}

		// executa a consistencia antes de executar o recebimento
		FINR650()

		// executa o programa de recebimento
		FINA430()

//		if Len(aMsgSch) > 0 .or. Len(aFA205R) > 0
		//FA205MAIL(STR0001,aVetPar[03,2],aMsgSch) // "Retorno Bancario Automatico (Pagar)"
		
		if Len(aMsgSch) == 0
			// copia o arquivo para o diretorio de backup
			cArq 	:= aArq[nA,1] // Substr(aVetPar[03,2],rat("\",aVetPar[03,2])+1,len(aVetPar[03,2]))
			if ! _CopyFile(aVetPar[03,2], cDirBk+cArq)
				Conout(STR0003+aVetPar[03,2]+STR0004+cDirBk) // "N�o foi possivel copiar o arquivo " # " para o diretorio "
			Else
				Ferase(aVetPar[03,2])
      	Endif
		Endif		
		
	Next

	(cAlias)->( Dbskip())

Enddo

(cAlias)->( DbcloseArea())

Return


