#Include "rwmake.ch"

/*
Funcao      : GTEIC003
Objetivos   : Alterar o parametro de numeração sequencial de nota fiscal
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 06/12/2010
*/

*----------------------------*
  User Function GTEIC003() 
*----------------------------*  
       
Local cItem  
Local oDlg,oMain
Local lOK:=lMail:=.F.  
Local aItens:={"","Sim-Automatico","Nao-Manual"}     
Local cEmail :="" 
Local cTipo  :=""

  
DEFINE MSDIALOG oDlg TITLE "Alterar numeração automatica de NF" From 1,7 To 10,39 OF oMain     
   
   @ 015,008 SAY "Selecione Sim ou Nao ? "  
   @ 015,070 COMBOBOX cItem ITEMS aItens SIZE 57,20 
   @ 035,040 BMPBUTTON TYPE 1 ACTION(lOk:=.T.,oDlg:End()) 
   @ 035,070 BMPBUTTON TYPE 2 ACTION(lOk:=.F.,oDlg:End()) 
    
ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())

If lOK
   
   SX6->(DbSetOrder(1))
   If SX6->(DbSeek(xFilial("SX6")+"MV_NF_AUTO"))
      
      RecLock("SX6",.F.)  
      
      If Alltrim(cItem) == "Sim-Automatico"     
         SX6->X6_CONTEUD:="S" 
         cTipo:="S"
         lMail:=.T.
      ElseIf Alltrim(cItem) == "Nao-Manual" 
         SX6->X6_CONTEUD:="N"
         lMail:=.T.
         cTipo:="N"
      EndIf
         
      SX6->(MsUnlock())
      
   EndIf

EndIf

If lMail      
    
   // Parametro para enviar notificação para qualquer pessoa. 
   If SX6->(DbSeek(xFilial("SX6")+"MV_P_AUTNF ")) // Ex: faturamento@hlb.com.br ; comex@hlb.com.br  
      
      If !Empty(GetMv("MV_P_AUTNF"))
      
         oEmail:= DEmail():New()
         oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
         oEmail:cTo	     	:=  GetMv("MV_P_AUTNF")                   
         If  cTipo=="S"  
	        oEmail:cSubject	:=	"Atenção : Alterado o paramentro de controle de numeração de NF Fiscal para Automatico "
         Else
            oEmail:cSubject	:=	"Atenção : Alterado o paramentro de controle de numeração de NF Fiscal para Manual "
         EndIf
         
         oEmail:cBody   	:= 	cEmail
	     oEmail:Envia()       
	  
	  EndIf   

   EndIf

EndIf   

Return .T.          


