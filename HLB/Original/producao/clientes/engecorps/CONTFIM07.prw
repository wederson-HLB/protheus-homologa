#include "rwmake.ch"        

/*
Funcao      : CONTFIM
Parametros  : Nenhum
Retorno     : cEspaco
Objetivos   : Finaliza contador Sispag Seg A e B, e gera 211 espa�os em branco no arquivo para atender o Layout. Zerar o parametro MV_P_CONT ap�s a grava��o dos dados no arquivo Sispag.
Autor     	: Vitor Bedin	
Data     	: 22/07/2010
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 08/02/2012
M�dulo      : Financeiro.
*/ 

*-------------------------*
  User Function CONTFIM()   
*-------------------------*
 
Local nCont1:=0 
Local cEspaco:= space(211)
 
SX6->(DbSetOrder(1))
If SX6->(DbSeek(xFilial()+"MV_P_CONT"))
   SX6->(RecLock("SX6",.F.))   
   SX6->X6_CONTEUD:=Alltrim(Str(nCont1))
   SX6->(MsUnlock())
EndIf

Return cEspaco               