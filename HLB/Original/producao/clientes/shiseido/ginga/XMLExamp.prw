#include "XMLXFUN.CH"
#define CRLF CHR(13)+CHR(10) 

/*
Funcao      : XMLExamp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ginga 
Autor     	:                                
Data     	:                      
Obs         :  
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Generico. 
Cliente     : Shiseido
*/

*------------------------*
 User Function XMLExamp()
*------------------------*

Local oXMLObj,oNode,nCnt
Local cXMLFile    := "C:\GINGA\GS780SCM09_20040126.XML"
Local cXmlVersion := ""      /// "1.0"
Local cXmlEncoding := ""     /// "utf-8"
Local nBookCount  := nCustomerCount := 0
Local cMsg        := ""

//------------------------------------------------------------------------------
// Crição do objeto a partir de um arquivo XML com conteúdo...
//------------------------------------------------------------------------------
CREATE oXMLObj XMLFILE cXMLFile
/*
If XMLError() != XERROR_SUCCESS
	Alert("Erro na leitura do arquivo XML: " + XMLErrorMessage())
	Return
Endif   
*/

// Informações do documento XML...
cXmlVersion    := oXMLObj:__xml:_version:text
cXmlEncoding   := oXMLObj:__xml:_encoding:text

nBookCount     := Len(oXMLObj:_libdoc:_books:_book)
nCustomerCount := Len(oXMLObj:_libdoc:_customers:_customer)

//------------------------------------------------------------------------------
// Monta a mensagem para exibição ao usuário...
//------------------------------------------------------------------------------
cMsg := "Leitura do arquivo " + cXMLFile + CRLF + CRLF
cMsg += "-----------------------------------------------------------------------" + CRLF
cMsg += "Versão: " + cXmlVersion + " Encoding: " + cXmlEncoding + CRLF
cMsg += "No. Livros: " + Str(nBookCount,5,0) + " No. Clientes: " + Str(nCustomerCount,5,0) + CRLF
cMsg += "-----------------------------------------------------------------------" + CRLF + CRLF
                  
For nCnt := 1 To nCustomerCount
	oNode := oXMLObj:_libdoc:_customers:_customer[nCnt]
	cMsg  += "Cliente " + cValToChar(nCnt) + ": " + oNode:_name:text + CRLF
Next nCnt

cMsg += CRLF

For nCnt := 1 To nBookCount
	oNode := oXMLObj:_libdoc:_books:_book[nCnt]
	cMsg  += "Livro " + cValToChar(nCnt) +  ": " + oNode:_title:text + CRLF
Next nCnt

cMsg += CRLF + "-----------------------------------------------------------------------"

Alert(cMsg)                                                                

Return