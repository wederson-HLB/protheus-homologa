
/*
Funcao      : FFV001
Parametros  : Nenhum
Retorno     : lRet 
Objetivos   : Implementa��o de cr�tica para que o usu�rio cadastrado no par�metro MV_VLUSUFF n�o emita notas relacionadas as�rie informada no par�metro MV_VLSERFF
Autor     	: Wederson L. Santana
Data     	: 24/05/05 
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/03/2012
M�dulo      : Faturamento.
Cliente     : Sumitomo.
*/

*-----------------------*
 User Function FFV001()   
*-----------------------*

Local lRet :=.T. 
DbSelectArea("SX6")
If !DbSeek("  MV_VLUSUFF")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_VLUSUFF"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Valida usuario p/ emissao NF"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If !DbSeek("  MV_VLSERFF")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_VLSERFF"                         
	X6_TIPO		:= "C"                                
	X6_DESCRIC	:= "Valida serie p/ emissao NF"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                                                
If! Empty(GetMv("MV_VLUSUFF"))                        
    If __cUserId $ GetMv("MV_VLUSUFF")               
       If AllTrim(Mv_Par03) $ GetMv("MV_VLSERFF")
          MsgInfo("Serie "+AllTrim(GetMv("MV_VLSERFF"))+" nao permitida, "+Chr(10)+Chr(13)+"para o usuario !","A T E N C A O")
          lRet:=.F.
       Endif      
       Mv_Par03:="3"
       Mv_Par04:=2
   Endif                    
   
Endif
Return(lRet)