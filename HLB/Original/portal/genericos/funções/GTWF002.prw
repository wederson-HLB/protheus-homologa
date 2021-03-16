#Include 'Protheus.ch'

#Define FRASE_CHAVE    1
#Define FRASE_TRADUCAO 2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTWF002   �Autor  �Daniel F. Lira      � Data �  15/01/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��es para traducao do portal GT.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GT                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
Fun��o    : GTWF002()
Objetivo  : Altera a tabela de tradu��o na sessao
Autor     : Daniel F. Lira
Data      : 17/01/2013
*/
User Function GTWF002(cIdioma)
	// Le idioma ou por parametro ou por HttpPost
	If !Empty(HttpPost->cIdioma)
		HttpSession->cIdioma := HttpPost->cIdioma
	Else
		HttpSession->cIdioma := cIdioma
	EndIf
	
	// Zera a tabela
	HttpSession->aTabelaFrase := CarregaTabela(HttpSession->cIdioma)
Return 'ok'


/*
Fun��o    : WFTraduzir()
Objetivo  : Tenta traduzir a frase atraves do cadastro na tabela ZW8 
Autor     : Daniel F. Lira
Data      : 17/01/2013
Parametros: cChave: Frase que sera traduzida
*/
User Function WFTraduzir(cChave)
	Local cIdioma      := HttpSession->cIdioma
	Local aTabelaFrase := HttpSession->aTabelaFrase
	
	// Chave veio pelo metodo POST (se sim � javascript)
	If Empty(cChave)
		cChave := AllTrim(Unescape(HttpPost->cChave))
	EndIf
	
	// Se nao selecionar lingua retorna a propria chave
	If cIdioma == Nil
		Return cChave
	EndIf
Return BuscaFrase(aTabelaFrase, cChave)


/*
Fun��o    : CarregarTabela(cIdioma)
Objetivo  : Faz a leitura da ZW8 para um array para evitar multiplas consultas 
Autor     : Daniel F. Lira
Data      : 17/01/2013
Parametros: cIdioma: O Idioma a se carregado
Retorno   : Array com as tradu��es para o idioma
*/
Static Function CarregaTabela(cIdioma)
	Local aTabelaFrase := {}
	
	If Select("SX2") == 0
		U_WFPrepEnv()
	EndIf
	
	DbCloseArea('ZW8')
	ZW8->(DbSetOrder(1))
	ZW8->(DbGoTop())
	
	// Carrega todas as frases para um array
	If ZW8->(DbSeek(xFilial('ZW8')+cIdioma))
		// Enquanto tiver frases para o idioma
		While AllTrim(ZW8->ZW8_IDIOMA) == AllTrim(cIdioma)
			AAdd(aTabelaFrase, {AllTrim(ZW8->ZW8_CHAVE), AllTrim(ZW8->ZW8_TRADUC)})
			ZW8->(DbSkip())
		EndDo
	EndIf

// Retorna o array com as frases
Return aTabelaFrase


/*
Fun��o    : BuscaFrase(aTabelaFrase, cChave)
Objetivo  : Verificar se a chave que esta sendo buscada existe no array de tradu��es 
Autor     : Daniel F. Lira
Data      : 17/01/2013
Parametros: aTabelaFrase: Tabela com as tradu��es
            cChave      : Chave se ser� consultada
Retorno   : Frase traduzida
*/
Static Function BuscaFrase(aTabelaFrase, cChave)
	Local nI            := 1
	Local cChaveAcentos := ''
	
	If ValType(cChave) != 'C'
		Return cChave
	EndIf
	
	cChaveAcentos := RemoveAcentos(cChave)
	
	// Procura a frase no array
	For nI := 1 To Len(aTabelaFrase)
		// Se encontrar retorna
		If aTabelaFrase[nI][FRASE_CHAVE] == cChave .Or. aTabelaFrase[nI][FRASE_CHAVE] == cChaveAcentos
			Return aTabelaFrase[nI][FRASE_TRADUCAO]
		EndIf
	Next nI

// Retorna a propria chave se nao encontrar
Return cChave


/*
Fun��o    : RemoveAcentos(cExp)
Objetivo  : Remove os acentos da string 
Autor     : Daniel F. Lira
Data      : 18/01/2013
Parametros: cExp: Frase a ser corrigida
Retorno   : Frase corrigida
*/
Static Function RemoveAcentos(cExp)
	cExp := StrTran(cExp,"�","c")
	cExp := StrTran(cExp,Chr(166)," ")
	cExp := StrTran(cExp,Chr(167)," ")
	cExp := StrTran(cExp,"�","a")
	cExp := StrTran(cExp,"�","a")
	cExp := StrTran(cExp,"�","a")
	cExp := StrTran(cExp,"�","a")
	cExp := StrTran(cExp,"�","e")
	cExp := StrTran(cExp,"�","e")
	cExp := StrTran(cExp,"�","e")
	cExp := StrTran(cExp,"�","i")
	cExp := StrTran(cExp,"�","i")
	cExp := StrTran(cExp,"�","o")
	cExp := StrTran(cExp,"�","o")
	cExp := StrTran(cExp,"�","o")
	cExp := StrTran(cExp,"�","o")
	cExp := StrTran(cExp,"�","u")
	cExp := StrTran(cExp,"�","u")
	cExp := StrTran(cExp,"�","A")
	cExp := StrTran(cExp,"�","A")
	cExp := StrTran(cExp,"�","A")
	cExp := StrTran(cExp,"�","A")
	cExp := StrTran(cExp,"�","E")
	cExp := StrTran(cExp,"�","E")
	cExp := StrTran(cExp,"�","E")
	cExp := StrTran(cExp,"�","I")
	cExp := StrTran(cExp,"�","I")
	cExp := StrTran(cExp,"�","O")
	cExp := StrTran(cExp,"�","O")
	cExp := StrTran(cExp,"�","O")
	cExp := StrTran(cExp,"�","O")
	cExp := StrTran(cExp,"�","U")
	cExp := StrTran(cExp,"�","C")
Return(cExp)