#include "rwmake.ch"
 
/*
Funcao      : RGCTG001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gatilho para apresentacao do markbrowse dos Produtos referentes a Nota de Débito a serem Reembolsaveis
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contratos.
*/     

*------------------------*
 User Function RGCTG001()
*-------------------------*

Private lMSHelpAuto := .F. // para mostrar os erros na tela
Private lMsErroAuto := .F.
Private cProdND     := ""  //Campo ref. produto ND
Private cND         := ""
Private nQuant      := 0

If Inclui .or. Altera
	If Altera 
    	cProdND       := Alltrim(CN9->CN9_P_ITND) //Campo ref. produto ND
    	M->CN9_P_ITND := Alltrim(CN9->CN9_P_ITND)
	Endif
	aProd  := {}
	If ! SelecaoFiltros()
		Return
	EndIf
	
	cProdND := ""
	AEVAL(aProd,{|x| If(x[1],cProdND += StrZero(x[4],9),)})
	
	***************
	
	***************
	cArq:=""
	_aStru:={}
	AADD(_aStru,{"RB_OK"       , "C" , 2, 0})
	AADD(_aStru,{"RB_PRODUTO"  , "C" ,15, 0})
	AADD(_aStru,{"RB_DESCRI"   , "C" ,40, 0})
	cArq:=CriaTrab(_aStru,.T.)
	dbUseArea(.T.,,cArq,"TRB")
	
	Processa({|| ESBPR01()})      // Alimenta Arq. Temp.de bancos com saldos
	
	
	dbSelectArea("TRB")
	dbGoTop()
	
	aCampos2 := {}
	AADD(aCampos2,{"RB_OK"        ,, " "                 , "@!"})
	AADD(aCampos2,{"RB_PRODUTO"   ,, "Cod.Produto"       , "@!"})
	AADD(aCampos2,{"RB_DESCRI"    ,, "Descricao"         , "@!"})
	lInverte   := .F.
	cmarca     := GetMark()
	lInvert1   := .F.
	cmarc1     := GetMark()
	
	
//	cProdND := Alltrim(cProdND) //TRB->RB_PONTOVD 
                       
    dbSelectArea("TMP")
    dbCloseArea("TMP")
    dbSelectArea("TRB")
    dbCloseArea("TRB")
Endif 

Return(cND)

***************

*************************
Static Function ESBPR01()

dbSelectArea("TMP")
DbGoTop()

While !Eof() 
    dbSelectArea("SB1")
    dBGoTo(TMP->RECNO)
	
	If ! Alltrim(STRZERO(RECNO(),9)) $ cProdND   // Filtro dos produtos de ND
		IncProc("Selecionando Produtos Remebolsaveis - Nota de Débito....")
        dbSelectArea("TMP")
		dbSkip()
		Loop
	EndIf
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	RB_PRODUTO   := SB1->B1_COD
    RB_DESCRI    := SB1->B1_DESC
	MsUnLock()
	nQuant       += 1
    cND          += Iif(Empty(cND),Alltrim(SB1->B1_COD),"/"+Alltrim(SB1->B1_COD))
	dbSelectArea("TMP")
	
	IncProc("Selecionando Produtos Reembolsaveis - Nota de Debito....")
	dbSkip()

EndDo
cND += "/"           

Return NIL


///////////////////////////////
Static Function SelecaoFiltros()
Local oDlgSelec, nOpc := 1
Local   oOk        := LoadBitMap(GetResources(),"LBOK")
Local   oNo        := LoadBitMap(GetResources(),"LBNO")
Local aAmbiente := GetArea(), lReturn := .T.

aProd := {}

cQuery := "" 
cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_GRUPO, R_E_C_N_O_ RECNO "
cQuery += ' FROM '+ RetSQLname("SB1")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+ " '"
cQuery += " AND B1_GRUPO = 'ND  ' "
cQuery += " AND B1_MSBLQL <> '1' "
cQuery += " ORDER BY B1_COD+B1_DESC "
MEMOWRIT("SELSB1.SQL",cQuery)
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)
dbSelectArea("TMP")
DbGoTop()

While !Eof() 
    dbSelectArea("SB1")
    dBGoTo(TMP->RECNO)

    If Inclui                    
    	AADD( aProd, { .T., SB1->B1_COD,SB1->B1_DESC,RECNO() } )
	    dbSelectArea("TMP")
   		dbSkip()
   	Else
		If Alltrim(SB1->B1_COD) $ cProdND
        	AADD( aProd, { .T., SB1->B1_COD,SB1->B1_DESC,RECNO() } )
		Else
        	AADD( aProd, { .F., SB1->B1_COD,SB1->B1_DESC,RECNO() } )
		Endif
	    dbSelectArea("TMP")
   		dbSkip()
   	Endif
EndDo

If Len(aProd) == 0
	
	MsgStop("Não há Produtos definidos como Item de Nota de Débito Reembolsaveis no cadastro!!! Favor revisar o cadastro de Produtos")
	
	RestArea( aAmbiente )
	Return(.F.)
EndIf

@ 080,080 TO 450,550 DIALOG oDlgSelec TITLE "Filtro de Produtos"
@ 038,010 TO 137,222 TITLE "Selecao de Produtos Reembolsaveis - Nota de Debito"
@ 3.5,1.7 LISTBOX oListBox1 VAR cListBox1 FIELDS HEADER "  ", "PRODUTO", "DESCRICAO" SIZE 200,52 ON DBLCLICK;
(aProd := MarcaItem(oListBox1:nAt,aProd),oListBox1:Refresh()) //NOSCROLL

oListBox1:SetArray(aProd)
oListBox1:bLine := { || {If(aProd[oListBox1:nAt,1],oOk,oNo),aProd[oListBox1:nAt,2],aProd[oListBox1:nAt,3],aProd[oListBox1:nAt,4]}}

@ 137,156 BMPBUTTON TYPE 1  ACTION (nOpc:=1,Close(oDlgSelec)) OBJECT oBtn1
@ 137,196 BMPBUTTON TYPE 2  ACTION (nOpc:=2,Close(oDlgSelec)) OBJECT oBtn2

oBtn1:Enable()
oBtn2:Enable()

ACTIVATE DIALOG oDlgSelec CENTERED

RestArea( aAmbiente )

If nOpc == 2 //Fechar
	lReturn := .F.
EndIf

Return lReturn

////////////////////////////////////
Static Function MarcaItem(nAt,aList)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Marca somente uma opcao 								         	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aList[nAt,1] := !aList[nAt,1]

Return aList


/////////////////////////////////
Static Procedure MarcaTudo(aList)

Aeval(aList,{|aElem|aElem[1] := lMarcaItem})

lMarcaItem := !lMarcaItem

Return

