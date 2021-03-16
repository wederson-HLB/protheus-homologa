#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#Include "pryor.ch"
#include "Fileio.ch"

/*
Funcao      : TableInd
Parametros  : 
Retorno     : .T.
Objetivos   : Usado para criar tabela e indices ver01
Autor       : Adriane Sayuri Kamiya
Data/Hora   : 30/07/2008    15:39
Revisão	    : Matheus Massarotto                   
Data/Hora   : 06/09/2012 - 10:57
Módulo      : Genérico
*/

*----------------------*
User Function TableInd()
*----------------------*

Private cBuffer,nBtLidos,aLog,cEol,_cTime,nLinReg,nNumLin,nHdl3
Private cArquivo := SPACE(3)

@ 200,001 To 380,420 Dialog oDlg Title "Criar Tabela e Índice..."
@ 001,002 To 089,209
@ 015,020 Say "Informe as Tabelas a serem criadas. " COLOR CLR_HRED, CLR_WHITE
@ 055,005 Say "Tabela " COLOR CLR_HBLUE, CLR_WHITE
@ 055,025 Get cArquivo Size 150,150
@ 070,128 BmpButton Type 01 Action GerarTable()
@ 070,158 BmpButton Type 02 Action Close(oDlg)
                  
ACTIVATE DIALOG oDlg  CENTERED

Return .T.

*-------------------------*
STATIC FUNCTION GerarTable()
*-------------------------*
Local i := 0
Local j:= 0
Local m:= 0

Private aArquivo := {}

cArquivo = Alltrim(cArquivo)                                 

If (Len(cArquivo) >= 3) .And. (Len(cArquivo) % 3) = 0  
   For i:= 1 to Len(Alltrim(cArquivo))
      Aadd(aArquivo, (Substr(cArquivo,j,3)))
      j:= i * 3 + 1
   Next
EndIf

For m:= 1 to len(aArquivo)
   SX2->(DbSetOrder(1))
   If !SX2->(DbSeek(aArquivo[m]))
      MsgStop("Tabela "+ aArquivo[m] +" não existe no SX2!")
   Else 
      If chkFile(aArquivo[m])
      MsgInfo("Tabela "+ aArquivo[m] +" criada com sucesso!")
      EndIf
   EndIf   
   m++
Next  

    
Return .T.



