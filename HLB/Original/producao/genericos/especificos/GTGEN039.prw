#INCLUDE "rwmake.ch" 
#INCLUDE "PROTHEUS.CH"

/*
Funcao      : GTGEN039
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Teste
Autor       : Richard Steinhauser Busso
Data/Hora   : 24/05/2017
Uso	: U_GTGEN039()
*/

*------------------------------------*
User Function GTGEN039() 
*------------------------------------*
//Campos de Execução
local SF4area := getarea()
//Campos da Tela
Local oGet1
Local oSay1
Local oSButton1
Local oSButton2
Local cFiltro
Private cTES := Space(3)
Static oDlg

//Tela de Seleção de qual a TES

  DEFINE MSDIALOG oDlg TITLE "Cópia da TES" FROM 000, 000  TO 130, 220 COLORS 0, 16777215 PIXEL

    @ 021, 004 SAY oSay1 PROMPT "Código da TES :" SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 020, 051 MSGET oGet1 VAR cTES SIZE  054, 010 F3 "SF4" OF oDlg COLORS 0, 16777215 PIXEL
    DEFINE SBUTTON oSButton1 FROM 044, 050 TYPE 01 Action ( Iif(ProcCopia(upper(cTES)),Close(oDlg),"")) OF oDlg ENABLE
    DEFINE SBUTTON oSButton2 FROM 044, 081 TYPE 02 Action ( Close(oDlg) ) OF oDlg ENABLE

  ACTIVATE MSDIALOG oDlg CENTERED

	Restarea(SF4area) 

Return  

/*
Funcao      : ProcCopia()
Autor       : Richard Steinhauser Busso
Data/Hora   : 24/05/2017
Uso			: U_GTCOPTES()
*/

Static Function ProcCopia()    
Local _A  
Local cCpo
Local lRet 

	lRet := MsgYesNo("Realmente deseja realizar a cópia da TES "+cTES+"","Alerta")
 	If lRet 
		dbSelectarea("SF4")
		dbSetOrder(1)
		
		If SF4->(dbSeek(xFilial() + cTES))
			FOR _A:=1 TO FCOUNT() 
			     cCpo:=Trim(FieldName(_a)) 
			     If cCpo <> "F4_CODIGO"
			     	M->&cCpo := SF4->&cCpo
			     Endif
			Next _a 
		Else
	   		MSGALERT("TES "+cTES+" não localizada.","Alerta")
	   		lRet := .F.	
		Endif
		    
		SF4->(dbCloseArea())    
    Endif
Return lRet

