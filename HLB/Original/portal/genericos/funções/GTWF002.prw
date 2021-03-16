#Include 'Protheus.ch'

#Define FRASE_CHAVE    1
#Define FRASE_TRADUCAO 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWF002   ºAutor  ³Daniel F. Lira      º Data ³  15/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funções para traducao do portal GT.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Função    : GTWF002()
Objetivo  : Altera a tabela de tradução na sessao
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
Função    : WFTraduzir()
Objetivo  : Tenta traduzir a frase atraves do cadastro na tabela ZW8 
Autor     : Daniel F. Lira
Data      : 17/01/2013
Parametros: cChave: Frase que sera traduzida
*/
User Function WFTraduzir(cChave)
	Local cIdioma      := HttpSession->cIdioma
	Local aTabelaFrase := HttpSession->aTabelaFrase
	
	// Chave veio pelo metodo POST (se sim é javascript)
	If Empty(cChave)
		cChave := AllTrim(Unescape(HttpPost->cChave))
	EndIf
	
	// Se nao selecionar lingua retorna a propria chave
	If cIdioma == Nil
		Return cChave
	EndIf
Return BuscaFrase(aTabelaFrase, cChave)


/*
Função    : CarregarTabela(cIdioma)
Objetivo  : Faz a leitura da ZW8 para um array para evitar multiplas consultas 
Autor     : Daniel F. Lira
Data      : 17/01/2013
Parametros: cIdioma: O Idioma a se carregado
Retorno   : Array com as traduções para o idioma
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
Função    : BuscaFrase(aTabelaFrase, cChave)
Objetivo  : Verificar se a chave que esta sendo buscada existe no array de traduções 
Autor     : Daniel F. Lira
Data      : 17/01/2013
Parametros: aTabelaFrase: Tabela com as traduções
            cChave      : Chave se será consultada
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
Função    : RemoveAcentos(cExp)
Objetivo  : Remove os acentos da string 
Autor     : Daniel F. Lira
Data      : 18/01/2013
Parametros: cExp: Frase a ser corrigida
Retorno   : Frase corrigida
*/
Static Function RemoveAcentos(cExp)
	cExp := StrTran(cExp,"ç","c")
	cExp := StrTran(cExp,Chr(166)," ")
	cExp := StrTran(cExp,Chr(167)," ")
	cExp := StrTran(cExp,"á","a")
	cExp := StrTran(cExp,"ã","a")
	cExp := StrTran(cExp,"à","a")
	cExp := StrTran(cExp,"â","a")
	cExp := StrTran(cExp,"é","e")
	cExp := StrTran(cExp,"è","e")
	cExp := StrTran(cExp,"ê","e")
	cExp := StrTran(cExp,"í","i")
	cExp := StrTran(cExp,"ì","i")
	cExp := StrTran(cExp,"ó","o")
	cExp := StrTran(cExp,"ò","o")
	cExp := StrTran(cExp,"õ","o")
	cExp := StrTran(cExp,"ô","o")
	cExp := StrTran(cExp,"ú","u")
	cExp := StrTran(cExp,"ù","u")
	cExp := StrTran(cExp,"Á","A")
	cExp := StrTran(cExp,"À","A")
	cExp := StrTran(cExp,"Â","A")
	cExp := StrTran(cExp,"Ã","A")
	cExp := StrTran(cExp,"É","E")
	cExp := StrTran(cExp,"È","E")
	cExp := StrTran(cExp,"Ê","E")
	cExp := StrTran(cExp,"Í","I")
	cExp := StrTran(cExp,"Ì","I")
	cExp := StrTran(cExp,"Ó","O")
	cExp := StrTran(cExp,"Ò","O")
	cExp := StrTran(cExp,"Õ","O")
	cExp := StrTran(cExp,"Ô","O")
	cExp := StrTran(cExp,"Ú","U")
	cExp := StrTran(cExp,"Ç","C")
Return(cExp)