#include "XMLXFUN.CH"
#define CRLF CHR(13)+CHR(10)


/*
Funcao      : XMLMask
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ginga 
Autor     	:                                
Data     	:                      
Obs         :  
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Generico. 
Cliente     : Shiseido
*/

*------------------------*
 User Function XMLMask()
*------------------------*

Local oXMLObj,oNode,nCnt
Local cXMLFile    := "C:\GINGA\GS780SCM.XML"
Local cXmlVersion := cXmlEncoding   := ""
Local nBookCount  := nCustomerCount := 0
Local cMsg        := ""

//------------------------------------------------------------------------------
// Cri��o do objeto a partir de um arquivo XML m�scara...
// Os n�s para o cliente e para o livro s�o informados como array (pois pode
// existir mais de um desses items)
//------------------------------------------------------------------------------
CREATE oXMLObj XMLFILE cXMLFile SETASARRAY _libdoc:_customers:_customer,_libdoc:_books:_book

If XMLError() != XERROR_SUCCESS
	Alert("Erro na leitura do arquivo XML: " + XMLErrorMessage())
	Return
Endif   



Return