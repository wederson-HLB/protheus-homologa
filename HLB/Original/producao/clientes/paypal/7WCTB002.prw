#Include 'Protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ7WCTB002  บ Autor ณRafael Rosa da Silvaบ Data ณ  28/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina que exporta os dados da tabela CT2, conforme layout บฑฑ
ฑฑบ          ณCOSIF (Leiaute dos Documentos 4010, 4016, 4020 e 4026		  บฑฑ 
ฑฑบ          ณBalancetes/Balan็os Patrimoniais Anal๚‘icos)				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HLB BRASIL									  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function 7WCTB002()

Local aParamBox	:= {}
Local cTitulo	:= "Leiaute dos Documentos 4010, 4016, 4020 e 4026"
Local aRet		:= {}
Local nTamFil	:= Len(cFilAnt)

aAdd(aParamBox, {1,"Filial de :"	,Space(nTamFil)		,"@!"	,"","",".T.",30	,.F.} )
aAdd(aParamBox, {1,"Filial AtE"	,Space(nTamFil)		,"@!"	,"","",".T.",30	,.F.} )
aAdd(aParamBox, {1,"Emissao de :"	,FirstDay(dDatabase),"@D"	,"","",".T.",60	,.F.} )
aAdd(aParamBox, {1,"Emissao AtE"	,LastDay(dDatabase)	,"@D"	,"","",".T.",60	,.F.} )
//  [2] : Descri็ใo
//  [3] : String contendo o inicializador do campo
//  [4] : String contendo a Picture do campo
//  [5] : String contendo a valida็ใo
//  [6] : Consulta F3
//  [7] : String contendo a valida็ใo When
//  [8] : Tamanho do MsGet
//  [9] : Flag .T./.F. Parโmetro Obrigat๓rio ?

aAdd(aParamBox, {6,"Selecione o Diretorio:",Space(80),"","","",80,.T.,"Arquivo .TXT |*.TXT","C:\",GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY})
// Tipo 6 -> File
//  [2] : Descri็ใo
//  [3] : String contendo o inicializador do campo
//  [4] : String contendo a Picture do campo
//  [5] : String contendo a valida็ใo
//  [6] : String contendo a valida็ใo When
//  [7] : Tamanho do MsGet
//  [8] : Flag .T./.F. Parโmetro Obrigat๓rio ?
//  [9] : Texto contendo os tipos de arquivo Ex.: "Arquivos .CSV |*.CSV"
//  [10]: Diret๓rio inicial do cGetFile
//  [11]: PARAMETROS do cGETFILE

aAdd(aParamBox, {2,"Cod Documento:"		,1,{'4010','4016','4020','4026'}	,40,"",.F.} )
aAdd(aParamBox, {2,"Tipo Remessa:"		,1,{'Envio','Reenvio'}				,40,"",.F.} )
// Tipo 2 -> Combo
//  [2] : Descri็ใo
//  [3] : Num้rico contendo a op็ใo inicial do combo
//  [4] : Array contendo as op็๕es do Combo
//  [5] : Tamanho do Combo
//  [6] : Valida็ใo
//  [7] : Flag .T./.F. Parโmetro Obrigat๓rio ?

// Parametros da fun็ใo Parambox()
// -------------------------------
// 1- Vetor com as configura็๕es
// 2- T๚‘ulo da janela
// 3- Vetor passador por referencia que cont้m o retorno dos parโmetros
// 4- Code block para validar o botใo Ok
// 5- Vetor com mais bot๕es al้m dos bot๕es de Ok e Cancel
// 6- Centralizar a janela
// 7- Se nใo centralizar janela coordenada X para in๚€io
// 8- Se nใo centralizar janela coordenada Y para in๚€io
// 9- Utiliza o objeto da janela ativa
//10- Nome do perfil se caso for carregar
//11- Salvar os dados informados por perfil

If ParamBox(aParamBox,cTitulo,@aRet)
	//JVR - 027663 - Tratamento para o Combobox, pois quando selecionado, ele retorna o conteudo e nao a posi็ใo.
	If ValType(aRet[6]) == "C"
		nPos := aScan(aParamBox[6][4],{|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(aRet[6])) })
		If nPos <> 0
			aRet[6] := nPos
		Else
			MsgInfo("Falha no tratamento de filtros[6], favor entrar em contato com o Suporte!","HLB BRASIL.")
			Return
		EndIf
	EndIf
	If ValType(aRet[7]) == "C"
		nPos := aScan(aParamBox[7][4],{|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(aRet[7])) })
		If nPos <> 0
			aRet[7] := nPos
		Else
			MsgInfo("Falha no tratamento de filtros[7], favor entrar em contato com o Suporte!","HLB BRASIL.")
			Return
		EndIf
	EndIf
	
	Processa( {|| OkGeraTxt(aRet) }, "Aguarde...", "Filtrando os dados...",.F.)		
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OKGERATXTบ Autor ณ AP5 IDE            บ Data ณ  28/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao chamada pelo botao OK na tela inicial de processamenบฑฑ
ฑฑบ          ณ to. Executa a geracao do arquivo texto.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function OkGeraTxt(aRet)

Local _cNomArq	:= Alltrim(aRet[5]) + "COSIF_" + dTos(dDataBase) + StrTran(Time(),":","") + ".TXT"
Local _nHdl		:= fCreate(_cNomArq)

If _nHdl == -1
    MsgAlert("O arquivo de nome " + _cNomArq + " nao pode ser criado! Verifique os parametros.","Atencao!")
    Return
Endif

Processa({|| RunCont(_nHdl,aRet) },"Processando...")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ RUNCONT  บ Autor ณ AP5 IDE            บ Data ณ  28/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunCont(_nHdl,aRet)

Local _cLin	:= 0
Local _cEOL	:= "CHR(13)+CHR(10)"
Local _cAlias	:= GetNextAlias()
Local _aArea	:= GetArea()
Local _cQry	:= ""
Local _aCodDoc:= {'4010','4016','4020'	,'4026'}
Local _aTpRem	:= {'I','S'}
Local _nQtdReg:= 0
Local _cConta	:= ""
Local _cSinal	:= "" 

If Empty(_cEOL)
    _cEOL := CHR(13) + CHR(10)
Else
    _cEOL := Trim(_cEOL)
    _cEOL := &_cEOL
Endif

/*
SELECT CT2_DEBITO, CT2_CREDIT, SUM(CT2_VALOR) VLRPRICOL, 0 VLRSEGCOL, 0 VLRTERCOL FROM CT2990
 WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ'
   AND CT2_DATA   BETWEEN '20140101' AND '20141231'
   AND D_E_L_E_T_ = ' '
   AND (CT2_DEBITO <> ' ' OR CT2_CREDIT <> ' ')
 GROUP BY CT2_DEBITO, CT2_CREDIT
*/

_cQry := "SELECT CT2_DEBITO, CT2_CREDIT, SUM(CT2_VALOR) VLRPRICOL, 0 VLRSEGCOL, 0 VLRTERCOL FROM " + RetSqlName("CT2")
_cQry += " WHERE CT2_FILIAL BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "'"
_cQry += "   AND CT2_DATA   BETWEEN '" + dTos(aRet[3]) + "' AND '" + dTos(aRet[4]) + "'"
_cQry += "   AND D_E_L_E_T_ = ' '"
_cQry += "   AND (CT2_DEBITO <> ' ' OR CT2_CREDIT <> ' ')"
_cQry += " GROUP BY CT2_DEBITO, CT2_CREDIT"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.F.,.T.)

ProcRegua( RecCount() ) // Numero de registros a processar

If !(_cAlias)->( EOF() )
	/*
	Cabe็alho
	Identifica็ใo do registro. 			001 E003 A (003) Valor fixo "#A1"
	C๓digo do Documento. 				004 E007 N (004) 4010, 4016, 4020 ou 4026.
	CNPJ ou Id_Bacen da Institui็ใo 	008 E015 A (008) CNPJ ou Id_Bacen da Institui็ใo com 8 posi็๕es.
	Filler. 								016 E029 A (014) Espa็os em branco.
	Database do documento. 				030 - 035 N (006) Database do documento no formato MMAAAA.
	Tipo de Remessa. 						036 - 036 A (001) Especifica o tipo de remessa: 	'I' Quando primeira remessa do documento para a database 
																									'S' Quando substitui็ใo de informa็ใo jEvalidada anteriormente
	Filler. 								037 - 071 A (035) Espa็os em branco.
	*/
	
	//Monta a Linha do Cabecalho
	_cLin := "#A1"
	_cLin += _aCodDoc[aRet[6]]
	_cLin += SubStr(SM0->M0_CGC,1,8)
	_cLin += Space(14)
	_cLin += StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4) 
	_cLin += _aTpRem[aRet[7]]
	_cLin += Space(35)
	
	//Acrescenta a quebra da linha
	_cLin += _cEOL
	
	//Realiza a gravacao do Cabecalho
    _cLin := Stuff(_cLin,01,Len(_cLin),_cLin)

    If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
        If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
            Return
        Endif
    Endif
    
    //Acrescenta o Cabecalho no totalizador
    _nQtdReg++
	    	 
	While !(_cAlias)->( EOF() )
	
		_cConta	:= IIF(Empty(CT2_DEBITO), CT2_CREDIT,CT2_DEBITO)
		_cSinal	:= IIF(Empty(CT2_DEBITO), "+","-")
		 
	    IncProc()

		/*
		Itens
		C๓digo de conta. 						001 E010 N (010) C๓digo da conta do plano COSIF.
		Filler. 								011 E014 A (004) Espa็os em branco.
		Valor da primeira coluna. 			015 E032 N (018) Valor Absoluto do Total da Conta.Valor em moeda nacional com centavos e sem v๚gula.
		Sinal do valor da primeira coluna. 033 E033 A (001) Sinal do valor ("+" ou "").
		Valor da segunda coluna. 			034 E051 N (018) Valor Absoluto do Realizแvel/Exig๚“el atE90 dias. Valor em moeda nacional com centavos e sem v๚gula.
		Sinal do valor da segunda coluna. 	052 E052 A (001) Sinal do valor ("+" ou "").
		Valor da terceira coluna. 			053 E070 N (018) Valor Absoluto do Realizแvel/Exig๚“el ap๓s 90 dias. Valor em moeda nacional com centavos e sem v๚gula.
		Sinal do valor da terceira coluna. 071 E071 A (001) Sinal do valor ("+" ou "").
		*/
			
		_cLin := PadR(_cConta,10)
		_cLin += Space(4)
		
		_cLin += StrZero(Int(Round((_cAlias)->VLRPRICOL,2)*100),18)
		_cLin += _cSinal
		
		_cLin += StrZero(Int(Round((_cAlias)->VLRSEGCOL,2)*100),18)
		_cLin += _cSinal
		
		_cLin += StrZero(Int(Round((_cAlias)->VLRTERCOL,2)*100),18)
		_cLin += _cSinal 				 

		//Acrescenta a quebra da linha
		_cLin += _cEOL
			
		//Realiza a gravacao dos Itens
	    _cLin := Stuff(_cLin,01,Len(_cLin),_cLin)
	
	    If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	        If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	            Exit
	        Endif
	    Else
		    //Acrescenta o Item no totalizador
		    _nQtdReg++
	    EndIf
	
	    (_cAlias)->( dbSkip() )
	End
	
	//Acrescenta o Rodape no totalizador
    _nQtdReg++
	
	/*
	Identifica็ใo do registro 	001 E002 A (002) Valor fixo "@1"
	N๚mero de registros. 		003 E008 N (006) Total de registros gravados, inclusive o de identifica็ใo e controle final.
	Filler. 						009 E071 A (063) Espa็os em branco.
	*/
	//Monta a Linha do Rodape
	_cLin := "@1"
	_cLin += StrZero(_nQtdReg,6)
	_cLin += Space(63) 	 	
		
	//Acrescenta a quebra da linha
	_cLin += _cEOL
	
	//Realiza a gravacao do Rodape
    _cLin := Stuff(_cLin,01,Len(_cLin),_cLin)

    If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
        If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
            Return
        Endif
    Endif
Else
	MsgAlert("Nใo existem dados para serem gerados, conforme os parametros indicados. Favor revisar os parametros.")
EndIf

(_cAlias)->( dbCloseArea() )

fClose(_nHdl)

RestArea(_aArea)

Return