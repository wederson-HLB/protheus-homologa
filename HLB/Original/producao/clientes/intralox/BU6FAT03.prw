#Include "rwmake.ch"          
#Include "colors.ch"

/*
Funcao      : BU6FAT03
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Interface para visualização das TES utilizadas no processo de importação dos arquivos texto para faturamento   
Autor     	: Wederson L. Santana 
Data     	: 30/08/05 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

*------------------------*
 User Function BU6FAT03()  
*------------------------*

Private cCombo

If cEmpAnt $ "U6"
   fCriaSx6()
   cCombo := ""
   aItems := {"Importado montado (BELT)     ",;
              "Importado componentes (99999)",;
              "Clean in Place               ",;
              "Nacional                     ",;
              "Importado                    ",;
              "Servicos                      "}  

   @ 200,001 To 380,420 Dialog oLeTxt Title "Faturamento - Intralox"
   @ 001,002 To 089,209 
   @ 005,020 Say "Manutencao das TES utilizadas pela"
   @ 005,110 Say "INTRALOX " COLOR CLR_HRED, CLR_WHITE 
   @ 033,020 Say "Produto " COLOR CLR_HBLUE, CLR_WHITE 
   @ 040,020 ComboBox cCombo Items aItems Size 90,90  
   @ 070,128 BmpButton Type 01 Action fOkOpc()
   @ 070,158 BmpButton Type 02 Action Close(oLeTxt)

   Activate Dialog oLeTxt Centered
Else
    MsgInfo("Especifico Intralox !"," A T E N C A O")
Endif   

Return

//--------------------------------------------------Direciona

Static Function fOkOpc()

cExec :=If("montado"$cCombo,"1",If("componentes"$cCombo,"2",If("Clean"$cCombo,"3",;
        If("Nacional"$cCombo,"4",If("Servicos"$cCombo,"6","5")))))
If "1" $ cExec
   fOkBrw1()
Endif   
If "2" $ cExec   
   fOkBrw2()
Endif   
If "3" $ cExec
   fOkBrw3()
Endif   
If "4" $ cExec
   fOkBrw4()
Endif   
If "5" $ cExec
   fOkBrw5()
Endif      
If "6" $ cExec
   fOkBrw6()
Endif      
Return

//---------------------------------------------------

Static Function fOkBrw1()
DbSelectArea("SX6")
If DbSeek("  MV_FATES05")
	_cConteud :=X6_CONTEUD 
EndIf                   
If DbSeek("  MV_FATES06")
	_cConteud2 :=X6_CONTEUD
EndIf

@ 200,001 To 380,420 Dialog oLeBrw1 Title "Faturamento - Intralox"
@ 001,002 To 011,209 
@ 012,002 To 065,105
@ 012,110 To 065,209
@ 003,020 Say cCombo 
@ 030,020 Say "Venda Consumidor Final " COLOR CLR_HBLUE, CLR_WHITE       
@ 030,130 Say "Venda Revendedor " COLOR CLR_HBLUE, CLR_WHITE       
@ 040,020 Get _cConteud  Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cConteud)
@ 040,130 Get _cConteud2 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cConteud2)
@ 070,055 Button "_Alterar" Size 50,15 Action fAlterar(_cConteud,_cConteud2,"","",1)
@ 070,110 Button "_Sair"    Size 50,15 Action Close(oLeBrw1)

Activate Dialog oLeBrw1 Centered

Return

//---------------------------------------------------

Static Function fOkBrw2()
DbSelectArea("SX6")
If DbSeek("  MV_FATES07")
	_cConteud :=X6_CONTEUD  
EndIf                   
If DbSeek("  MV_FATES08")
	_cConteud2 :=X6_CONTEUD 
EndIf

@ 200,001 To 380,420 Dialog oLeBrw2 Title "Faturamento - Intralox"
@ 001,002 To 011,209 
@ 012,002 To 065,105
@ 012,110 To 065,209
@ 003,020 Say cCombo 
@ 030,020 Say "Venda Consumidor Final " COLOR CLR_HBLUE, CLR_WHITE       
@ 030,130 Say "Venda Revendedor " COLOR CLR_HBLUE, CLR_WHITE       
@ 040,020 Get _cConteud  Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cConteud)
@ 040,130 Get _cConteud2 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cConteud2)
@ 070,055 Button "_Alterar" Size 50,15 Action fAlterar(_cConteud,_cConteud2,"","",2)
@ 070,110 Button "_Sair"    Size 50,15 Action Close(oLeBrw2)

Activate Dialog oLeBrw2 Centered

Return

//---------------------------------------------------

Static Function fOkBrw3()
DbSelectArea("SX6")
DbSeek("  MV_FATES01")
_cFaTes01 := X6_CONTEUD  
DbSeek("  MV_FATES02")
_cFaTes02 :=X6_CONTEUD  
DbSeek("  MV_FATES03")
_cFaTes03 :=X6_CONTEUD  
DbSeek("  MV_FATES04")
_cFaTes04 :=X6_CONTEUD  

@ 200,001 To 380,420 Dialog oLeBrw3 Title "Faturamento - Intralox"
@ 001,002 To 011,209 
@ 012,002 To 065,105
@ 012,110 To 065,209
@ 003,010 Say cCombo 
@ 015,010 Say "Sul/Sudeste,exceto ES" COLOR CLR_HRED, CLR_WHITE       
@ 015,120 Say "Norte/Nordeste e ES " COLOR CLR_HRED, CLR_WHITE       
@ 022,010 Say "Venda Consumidor Final" COLOR CLR_HBLUE, CLR_WHITE       
@ 022,120 Say "Venda Consumidor Final" COLOR CLR_HBLUE, CLR_WHITE       
@ 030,010 Get _cFaTes01 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes01)
@ 030,120 Get _cFaTes03 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes03)
@ 041,010 Say "Venda Revendedor " COLOR CLR_HBLUE, CLR_WHITE       
@ 041,120 Say "Venda Revendedor " COLOR CLR_HBLUE, CLR_WHITE       
@ 050,010 Get _cFaTes02 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes02)
@ 050,120 Get _cFaTes04 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes04)
@ 070,055 Button "_Alterar" Size 50,15 Action fAlterar(_cFaTes01,_cFaTes02,_cFaTes03,_cFaTes04,3)
@ 070,110 Button "_Sair"    Size 50,15 Action Close(oLeBrw3)

Activate Dialog oLeBrw3 Centered

Return

//---------------------------------------------------

Static Function fOkBrw4()
DbSelectArea("SX6")
DbSeek("  MV_FATES09") //"Especifico Intralox-Nacional,ICMS com IPI " 
_cFaTes09   :=X6_CONTEUD 
DbSeek("  MV_FATES10") //"Especifico Intralox-Nacional,ICMS sem IPI" 
_cFaTes10   :=X6_CONTEUD  

@ 200,001 To 380,420 Dialog oLeBrw4 Title "Faturamento - Intralox"
@ 001,002 To 011,209 
@ 012,002 To 065,105
@ 012,110 To 065,209
@ 003,020 Say cCombo 
@ 030,020 Say "Venda Consumidor Final " COLOR CLR_HBLUE, CLR_WHITE       
@ 030,130 Say "Venda Revendedor " COLOR CLR_HBLUE, CLR_WHITE       
@ 040,020 Get _cFaTes09  Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes09)
@ 040,130 Get _cFaTes10  Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes10)
@ 070,055 BmpButton Type 01 Action fAlterar(_cFaTes09,_cFaTes10,"","",4)
@ 070,110 BmpButton Type 02 Action Close(oLeBrw4)

Activate Dialog oLeBrw4 Centered

Return

//---------------------------------------------------

Static Function fOkBrw5()
DbSelectArea("SX6")
DbSeek("  MV_FATES11") //"Especifico Intralox-Importado,ICMS com IPI " 
_cFaTes11 :=X6_CONTEUD 
DbSeek("  MV_FATES12") //"Especifico Intralox-Importado,ICMS sem IPI" 
_cFaTes12 :=X6_CONTEUD  

@ 200,001 To 380,420 Dialog oLeBrw5 Title "Faturamento - Intralox"
@ 001,002 To 011,209 
@ 012,002 To 065,105
@ 012,110 To 065,209
@ 003,020 Say cCombo 
@ 030,020 Say "Venda Consumidor Final " COLOR CLR_HBLUE, CLR_WHITE       
@ 030,130 Say "Venda Revendedor " COLOR CLR_HBLUE, CLR_WHITE       
@ 040,020 Get _cFaTes11 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes11)
@ 040,130 Get _cFaTes12 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes12)
@ 070,055 Button "_Alterar" Size 50,15 Action fAlterar(_cFaTes11,_cFaTes12,"","",5)
@ 070,110 Button "_Sair"    Size 50,15 Action Close(oLeBrw5)

Activate Dialog oLeBrw5 Centered

Return

//-------------------------------------------------Servicos

Static Function fOkBrw6()
DbSelectArea("SX6")
DbSeek("  MV_FATES13") 
_cFaTes13 :=X6_CONTEUD 

@ 200,001 To 380,420 Dialog oLeBrw6 Title "Faturamento - Intralox"
@ 001,002 To 011,209 
@ 012,002 To 065,209
@ 003,020 Say cCombo 
@ 030,020 Say "Prestacao de servicos " COLOR CLR_HBLUE, CLR_WHITE       
@ 040,020 Get _cFaTes13 Size 030,030 Picture "@R XXX" F3 "SZ2" Valid fOkProc(_cFaTes13)
@ 070,055 Button "_Alterar" Size 50,15 Action fAlterar(_cFaTes13,"","","",6)
@ 070,110 Button "_Sair"    Size 50,15 Action Close(oLeBrw6)

Activate Dialog oLeBrw6 Centered

Return

//-------------------------------------------------ALtera o conteúdo dos parâmeros

Static Function fAlterar(_cVar1,_cVar2,_cVar3,_cVar4,_nOpc)
Do Case
   Case _nOpc==1
        Close(oLeBrw1)
        If SX6->(DbSeek("  MV_FATES05"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar1       
	        MsUnlock()
        EndIf                   
        If SX6->(DbSeek("  MV_FATES06"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar2       
	        MsUnlock()
        EndIf
   Case _nOpc==2     
        Close(oLeBrw2)
        If SX6->(DbSeek("  MV_FATES07"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar1       
	        MsUnlock()
        EndIf                   
        If SX6->(DbSeek("  MV_FATES08"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar2       
	        MsUnlock()
        EndIf
   Case _nOpc==3
        Close(oLeBrw3)
        If SX6->(DbSeek("  MV_FATES01"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar1       
	        MsUnlock()
        Endif   
        If SX6->(DbSeek("  MV_FATES02"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar2       
	        MsUnlock()
        Endif
        If SX6->(DbSeek("  MV_FATES03"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar3       
	        MsUnlock()
        Endif   
        If SX6->(DbSeek("  MV_FATES04"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar4       
	        MsUnlock()
        Endif
   Case _nOpc==4
        Close(oLeBrw4)
        If SX6->(DbSeek("  MV_FATES09"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar1       
	        MsUnlock()
	     Endif   
        If SX6->(DbSeek("  MV_FATES10"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar2       
	        MsUnlock()
        Endif
   Case _nOpc==5
        Close(oLeBrw5)
        If SX6->(DbSeek("  MV_FATES11"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar1       
	        MsUnlock()
        Endif      
        If SX6->(DbSeek("  MV_FATES12"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar2       
	        MsUnlock()
        Endif   
       Case _nOpc==6
        Close(oLeBrw6)
        If SX6->(DbSeek("  MV_FATES13"))
           Reclock("SX6",.F.)
	        Replace X6_CONTEUD With _cVar1       
	        MsUnlock()
        Endif      
EndCase
Return

//--------------------------------------------------Valida TES informada

Static Function fOkProc(_cTes)

lRet :=.T.
SZ2->(DbSetOrder(3))
If! SZ2->(DbSeek(xFilial("SZ2")+cEmpAnt+cFilAnt+_cTes))
    lRet :=.F.
    MsgInfo("TES nao habilitada para esta empresa !","A T E N C A O ")
EndIf
Return(lRet)

//--------------------------------------------------Cria os parâmetros caso não exista

Static Function fCriaSx6()

DbSelectArea("SX6")
//--------------------------------------------------ESTADOS
If! DbSeek("  MV_FATUF01")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATUF01"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Estados Red. BC 73,34%" 
	X6_CONTEUD  := "RS/SC/PR/SP/MG/RJ"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATUF02")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATUF02"
	X6_TIPO		:= "C"
	X6_DESCRIC	:="Especifico Intralox-Estados Red. BC 73,43%" 
	X6_CONTEUD  :="ES/BA/GO/MS/MT/TO/AC/AM/PA/RR/RN/SE/CE/RO/PB/AL/AP/PI/PE/MA"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------C1P01
If! DbSeek("  MV_FATES01")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES01"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS com IPI" 
	X6_DESC1    := "/Red BC 73,34%)"
	X6_CONTEUD  := "85A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES02")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES02"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS sem IPI" 
   X6_DESC1    := "/Red BC 73,34%)"
	X6_CONTEUD  := "70A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES03")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES03"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS com IPI" 
	X6_DESC1    := "/Red BC 73,43%)"
	X6_CONTEUD  := "93F"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES04")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES04"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS sem IPI" 
	X6_DESC1    := "/Red BC 73,43%)"
	X6_CONTEUD  := "71A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------BELT
If! DbSeek("  MV_FATES05")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES05"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-BELT(Importado,ICMS com IPI) " 
	X6_CONTEUD  := "74A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES06")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES06"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-BELT(Importado,ICMS sem IPI)" 
	X6_CONTEUD  := "73A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------99999
If! DbSeek("  MV_FATES07")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES07"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-99999(Importado,ICMS com IPI) " 
	X6_CONTEUD  := "51A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES08")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES08"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-99999(Importado,ICMS sem IPI)" 
	X6_CONTEUD  := "50A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf 

//--------------------------------------------------Nacional
If! DbSeek("  MV_FATES09")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES09"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Nacional,ICMS com IPI " 
	X6_CONTEUD  := "51A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES10")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES10"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Nacional,ICMS sem IPI" 
	X6_CONTEUD  := "50A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------Importado
If! DbSeek("  MV_FATES11")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES11"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Importado,ICMS com IPI " 
	X6_CONTEUD  := "74A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES12")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES12"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Importado,ICMS sem IPI" 
	X6_CONTEUD  := "73A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
//---------------------------------------------------Servicos
If! DbSeek("  MV_FATES13")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES13"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Servicos" 
	X6_CONTEUD  := "91X"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

Return