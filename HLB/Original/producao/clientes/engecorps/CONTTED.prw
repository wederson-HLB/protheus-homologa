#include "rwmake.ch"        

/*
Funcao      : CONTTED
Parametros  : Nenhum
Retorno     : nCont
Objetivos   : Contar linhas dos Segmentos A e B do Sispag da Empresa Engecorps, finalizado pela rotina U_CONTFIM no trailer do arquivo.
Autor     	: Vitor Bedin
Data     	: 22/07/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 

*----------------------------*
  User Function CONTTED()   
*----------------------------*
 
Local nCont:=0 

nCont:=Val(GetMv("MV_P_CONT"))+1 
 
SX6->(DbSetOrder(1))
If SX6->(DbSeek(xFilial()+"MV_P_CONT"))
   SX6->(RecLock("SX6",.F.))   
   SX6->X6_CONTEUD:=Alltrim(Str(nCont))
   SX6->(MsUnlock())
EndIf

Return nCont

