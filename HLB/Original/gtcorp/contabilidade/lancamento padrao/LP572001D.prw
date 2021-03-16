#Include "Rwmake.ch"  

/*
Funcao      : LP572001_D
Parametros  : Nenhum
Retorno     : cRet
Objetivos   : Lançamento que verifica a natureza e retorna a conta
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contabilidade.
*/    
    
*-------------------------*
  User function LP572001_D
*-------------------------*

Local cRet:=""

If !Empty(SEU->EU_P_NATUR)
	
	cNat:=SEU->EU_P_NATUR
	
	DbSelectArea("SED")
	DbSetOrder(1)
	If DbSeek(xFilial("SED")+cNat)
		cRet:=SED->ED_CONTA	
	EndIf                  
	
Else
	cRet:=SED->ED_CONTA
EndIf


Return cRet