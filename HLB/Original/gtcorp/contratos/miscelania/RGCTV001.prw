#include "rwmake.ch"  

/*
Funcao      : RGCTV001  
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : 
Autor       : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 26/01/2012
M�dulo      : Contratos.
*/

*--------------------------*
  User Function RGCTV001()    
*--------------------------*

Local cArea := GetArea()
Local lRet  := .T.

If Altera
    If CN9->CN9_SITUAC $ "05"
        lRet := .F.
    Endif
Endif

Return (lRet)