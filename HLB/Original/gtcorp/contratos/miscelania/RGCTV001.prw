#include "rwmake.ch"  

/*
Funcao      : RGCTV001  
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : 
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 26/01/2012
Módulo      : Contratos.
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