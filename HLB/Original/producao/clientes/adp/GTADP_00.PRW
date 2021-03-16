#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณParametros GT-ADPบAutorณ Cesar Chena                บ Data ณ 22/07/2015 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ Parametros para geracao de relatorios ADP Systems                      บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ HLB BRASIL                                                         บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
USER FUNCTION GTADP_00()

Private _i 			:= 1
Private _cList          
Private _oList         
Private _oDlg        
Private _aEstrut 	:= {}	
Private _aEstItem	:= {}	
Private _aDir    	:= {}
Private _aDados 	:= {}
Private _cNF 		:= ""   
Private cCID		:= ""
Private cENTITY 	:= ""
Private cLID		:= ""
Private _cOpenPath  := "C:\Totvs 11\Microsiga\Protheus\Protheus11_Data\"
Private oNoMarked	:= LoadBitmap(GetResources(),'LBNO')
Private oMarked	    := LoadBitmap(GetResources(),'LBOK')

DbSelectArea("SX5")
DbSetOrder(1)                   
DbSeek(xFilial("SX5")+"00"+"X0",.f.)
If !Found()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "00"	
	SX5->X5_CHAVE  := "X0"
	SX5->X5_DESCRI := "Parโmetros da empresa (ADP)"
	MsUnlock()
Endif
//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
DbSetOrder(1)                   
DbSeek(xFilial("SX5")+"X0"+"CID",.f.)
If !Found()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X0"	
	SX5->X5_CHAVE  := "CID"
	SX5->X5_DESCRI := "CID"
	MsUnlock()
Endif
cCID := X5_DESCRI
//Aviso("ATENวรO", "Nใo encontrada tabela X0!. Verifique!", {"Ok"} )
DbSeek(xFilial("SX5")+"X0"+"ENTITY",.f.)
If !Found() 
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X0"	
	SX5->X5_CHAVE  := "ENTITY"
	SX5->X5_DESCRI := "ENTITY"
	MsUnlock()
Endif
cENTITY := X5_DESCRI
//Aviso("ATENวรO", "Nใo encontrada tabela X0!. Verifique!", {"Ok"} )
DbSeek(xFilial("SX5")+"X0"+"LID",.f.)
If !Found()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X0"	
	SX5->X5_CHAVE  := "LID"
	SX5->X5_DESCRI := "LID"
	MsUnlock()
Endif
cLID := X5_DESCRI
//Aviso("ATENวรO", "Nใo encontrada tabela X0!. Verifique!", {"Ok"} )

DEFINE MSDIALOG _oDlg FROM 100,150 TO 450,800 PIXEL TITLE "Parใmetros de Relat๓rios HLB - ADP Systems"
@ 05, 5  SAY "Preencha os parโmetros desejados"
@ 25, 5  SAY "Chave                 Conte๚do"
@ 50,005 SAY "CID:"   
@ 50,040 GET cCID 
@ 65,005 SAY "ENTITY:"   
@ 65,040 GET cENTITY   
@ 80,005 SAY "LID:"   
@ 80,040 GET cLID  

@ 163,240 BUTTON OemToAnsi("Confirma") 	   		   SIZE 050,11 ACTION Processa( {|| ProcGrv(cCID,cENTITY,cLID) }) OF _oDlg PIXEL 
@ 163,290 BUTTON OemToAnsi("Sair")  	   		   SIZE 030,11 ACTION Processa( {|| Val_Sai() }) OF _oDlg PIXEL
ACTIVATE DIALOG _oDlg CENTERED

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunction  ณProcGrv   บAutor  ณCesar Chena         บ Data ณ  16/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAuterado  ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PROCGRV(cCID,cENTITY,cLID)

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"X0"+"CID")
	RecLock("SX5")
	X5_DESCRI := cCID
	MsUnlock()
Else
	Aviso("ATENวรO", "Nใo encontrada tabela X0!. Verifique!", {"Ok"} )
Endif
If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
	RecLock("SX5")
	X5_DESCRI := cENTITY
	MsUnlock()
Else
	Aviso("ATENวรO", "Nใo encontrada tabela X0!. Verifique!", {"Ok"} )
Endif
If DbSeek(xFilial("SX5")+"X0"+"LID")
	RecLock("SX5")
	X5_DESCRI := cLID
	MsUnlock()
Else
	Aviso("ATENวรO", "Nใo encontrada tabela X0!. Verifique!", {"Ok"} )
Endif

Aviso("ATENวรO", "Parโmetros gravados!", {"Ok"} )

Close(_oDlg)

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ Val_Sai	| Autor ณ Cesar Chena               บDataณ16/06/15  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Valida Saida da geracao dos relatorios/planilhas             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 - 1 = Executado no listbox                             ณฑฑ
ฑฑณ          ณ ExpO1 - Objeto listbox                                       ณฑฑ
ฑฑณ          ณ ExpA1 - Vetor contendo os itens do listbox                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/
Static Function Val_Sai 

If MsgYesNo("Deseja realmente abandonar a rotina ?")
	Close(_oDlg)
Endif

Return 
