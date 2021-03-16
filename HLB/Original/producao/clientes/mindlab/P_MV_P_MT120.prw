#include "Protheus.ch"   

/*
Funcao      : P_MV_P_MT120
Parametros  : 
Retorno     : 
Objetivos   : Fonte para manipular parametro MV_P_MT120, com e-mails.
Autor       : Matheus Massarotto
Data/Hora   : 01/07/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*---------------------------*
 User Function P_MV_P_MT120 
*---------------------------*

Private oDlg
Private oProv
Private cProv:=space(100)

//Verifica e cria o parametro 
	lAchou := SX6->( dbSeek( xFilial( "SX6" ) + "MV_P_MT120" ) )
	If !lAchou 
		RecLock( "SX6" , .T. )
			X6_VAR     := "MV_P_MT120"
			X6_TIPO    := "C"
			X6_CONTEUD := ""
			X6_DESCRIC := "E-mails que receberao msg apos inclusao do pedido"  // espaço max. de 50 caracteres
			X6_DESC1   := "compra."
		SX6->(MsUnLock())
	EndIf
//---------------------------


DEFINE MSDIALOG oDlg TITLE "PARAMETRO EMAIL" FROM 000,000 TO 500,317 PIXEL

Private aMails:= STRTOKARR(GETMV("MV_P_MT120"),";")
Private oListBox

Private aMailsAux:= STRTOKARR(GETMV("MV_P_MT120"),";")

                                                        //190
@005,005 LISTBOX oListBox FIELDS HEADER "E-mails" SIZE 150,200 OF oDlg PIXEL 
@225,005 BUTTON "Incluir" SIZE 030,013 PIXEL OF oDlg ACTION(altpareminc(cProv),cProv:=space(100),oListBox:refresh())
@225,040 BUTTON "Remover" SIZE 030,013 PIXEL OF oDlg ACTION(altparemexc(oListBox:nAt),oListBox:refresh()) 
@225,089 BUTTON "Salvar" SIZE 030,013 PIXEL OF oDlg ACTION(altparemsal(aMails))  
@225,124 BUTTON "Sair" SIZE 030,013 PIXEL OF oDlg ACTION( IIF(len(aMailsAux)<>len(aMails),IIF(Aviso("Atencao","Deseja sair sem salvar?",{"Sim","Não"},2)==1,oDlg:end(),),oDlg:end()) ) 
@210,005 MSGET oProv Var cProv SIZE 150,010 PIXEL OF oDlg
oListBox:setarray(aMails)     //PICTURE "@"
oListBox:bLine:={||{aMails[oListBox:nAt]}}  

                                                                                          
ACTIVATE MSDIALOG oDlg CENTERED

Return

//----------------------------------------------
//Função para incluir no ListBox
//----------------------------------------------

Static Function altpareminc(cProv)
If Alltrim(cProv)<>"" 
	AADD(aMails,Alltrim(cProv))
	oListBox:bLine:={||{aMails[oListBox:nAt]}}
EndIf
Return 

//----------------------------------------------
//Função para Remover no ListBox
//----------------------------------------------

Static Function altparemexc(nLinha)
If len(aMails)>0 
	ADEL(aMails,nLinha)
	ASIZE(aMails, (ASCAN(aMails,{|x|x==NIL}))-1)

	oListBox:bLine:={||{aMails[oListBox:nAt]}} 
EndIf
Return 

//----------------------------------------------
//Função para salvar no Parametro
//----------------------------------------------

Static Function altparemsal(aMails)
Local cCont:=""
	For i:=1 to len(aMails)
		cCont+=Alltrim(aMails[i])+";"
	Next

   	aMailsAux:=aClone(aMails)
   	
   	PUTMV("MV_P_MT120",cCont)
   	MSGALERT("Salvo com SUCESSO!!!", "SUCESSO")

Return
