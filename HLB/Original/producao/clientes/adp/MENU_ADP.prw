#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa � Menu GT-ADP     �Autor� Cesar Chena                � Data � 22/07/2015 ���
������������������������������������������������������������������������������������͹��
���Desc.    � Menu principal para geracao de relatorios ADP Systems                  ���
������������������������������������������������������������������������������������͹��
���Uso      � HLB BRASIL                                                         ���
������������������������������������������������������������������������������������͹��
����������������������������������������������������������������������������������������
*/
USER FUNCTION MENU_ADP()

Private _i 			:= 1
Private _cList
Private _oList
Private _oDlg
Private _aEstrut 	:= {}
Private _aEstItem	:= {}
Private _aDir    	:= {}
Private _aDados 	:= {}
Private _cNF 		:= ""
Private cPath		:= "c:\Relatorios\                                  "
////*
Private cPathH		:= ALLTRIM(cPath)+"HIST\"
Private cPathL		:= ALLTRIM(cPath)+"LOG\"
Private cPathO		:= ALLTRIM(cPath)+"OUT\"
Private cPathT		:= ALLTRIM(cPath)+"TMP\" 
Private cArqZipx 	:= ""
////*/
Private cPeriodo    := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
PRIVATE _cPer5ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer5fin := ""

Private cNomeEmx := ""
Private cNomeEmp := STRTRAN(ALLTRIM(SM0->M0_NOME),".","-")
PRIVATE cCodemp := upper(ALLTRIM(SM0->M0_CODIGO))

Private nYear := VAL(subs(cPeriodo,4,4))//AOA - 27/01/2017 - Variavel n�o estava sendo declarada, usado padr�o dos demais fontes GTADP.

for x = 1 to len(cNomeEmp)
	if substr(cNomeEmp,x,1) <> " "
		cNomeEmx := cNomeEmx + substr(cNomeEmp,x,1)	
	endif
next x

cNomeEmp := alltrim(cNomeEmx)

// monta periodo 5 final 
If subs(cPeriodo,1,2) $ "04/06/09/11"
	_cPer5fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
	_cPer5fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
Elseif subs(cPeriodo,1,2) $ "02"
	If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
		_cPer5fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
	Else
		_cPer5fin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
	Endif
Endif

private _cDtContab := subs(_cPer5fin,7,2)+"/"+subs(_cPer5fin,5,2)+"/"+subs(_cPer5fin,1,4)
Private _cFilialI	:= "  "
Private _cFilialF	:= "99"
Private _cRegime    := "N"
Private _cShuttle	:= "N"
Private _cTransf	:= ""

Private _cOpenPath  := "C:\Totvs 11\Microsiga\Protheus\Protheus11_Data\"
Private oNoMarked	:= LoadBitmap(GetResources(),'LBNO')
Private oMarked	    := LoadBitmap(GetResources(),'LBOK')

DbSelectArea("SX5")
DbSetOrder(1)                   
DbSeek(xFilial("SX5")+"00"+"X1",.f.)
If !Found()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "00"	
	SX5->X5_CHAVE  := "X1"
	SX5->X5_DESCRI := "relatorios (ADP)"
	MsUnlock()
Endif//Armazena os dados da tabela X0 do SX5

//Armazena os dados da tabela X1 do SX5 no array
DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5")+"X1",.f.)
If !Found()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "01"
	SX5->X5_DESCRI := "Summary Variance Report"
	SX5->X5_DESCSPA := "GTADP_01"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "02"
	SX5->X5_DESCRI := "Employee Variance Report"
	SX5->X5_DESCSPA := "GTADP_02"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "03"
	SX5->X5_DESCRI := "Gross to Net Report"
	SX5->X5_DESCSPA := "GTADP_03"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "04"
	SX5->X5_DESCRI := "Payment Report"
	SX5->X5_DESCSPA := "GTADP_04"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "05"
	SX5->X5_DESCRI := "Financial Reconciliation Report"
	SX5->X5_DESCSPA := "GTADP_05"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "06"
	SX5->X5_DESCRI := "GL File"
	SX5->X5_DESCSPA := "GTADP_06"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "07"
	SX5->X5_DESCRI := "Pay Slip"
	SX5->X5_DESCSPA := "GTADP_07"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "08"
	SX5->X5_DESCRI := "SRF"
	SX5->X5_DESCSPA := "GTADP_08"
	MsUnlock()
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "09"
	SX5->X5_DESCRI := "Shuttle"
	SX5->X5_DESCSPA := "GTADP_09"
	MsUnlock()	
Endif

DbSelectArea("SX5")
DbSetOrder(1)
If !DbSeek(xFilial("SX5")+"X1"+"09")
	RecLock("SX5",.t.)
	SX5->X5_TABELA := "X1"
	SX5->X5_CHAVE  := "09"
	SX5->X5_DESCRI := "Shuttle"
	SX5->X5_DESCSPA := "GTADP_09"
	MsUnlock()	
Endif

DbSeek(xFilial("SX5")+"X1",.f.)
While SX5->X5_TABELA="X1"
	AADD(_aDados,{.t.,SX5->X5_CHAVE,SX5->X5_DESCRI,SX5->X5_DESCSPA})
	DbSkip()
End
If len(_aDados)=0
	Aviso("ATEN��O", "N�o encontrada lista de relat�rios!. Verifique!", {"Ok"} )
	Return
Endif

SRV->(DbSetOrder(1))
If SRV->(FieldPos("RV_P_ADP")) == 0
	Aviso("ATEN��O", "Necessario atualiza��o do ambiente para execu��o da Rotina. Entrar em contato com o Suporte!", {"Ok"} )
	Return
EndIf


//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"X0"+"CID")
	cCID := X5_DESCRI
Else
	Aviso("ATEN��O", "N�o encontrada tabela X0!. Verifique!", {"Ok"} ) 
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
	cENTITY := X5_DESCRI
Else
	Aviso("ATEN��O", "N�o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"LID")
	cLID := X5_DESCRI
Else
	Aviso("ATEN��O", "N�o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif


DEFINE MSDIALOG _oDlg FROM 100,150 TO 450,800 PIXEL TITLE "Menu de Relat�rios HLB - ADP Systems"
@ 05, 5  SAY "Marque os relat�rios desejados e clique no bot�o <Processa>"
@ 20, 5  LISTBOX _oList VAR _cList FIELDS HEADER "","Codigo","Relatorio","Rotina" ;
FIELDSIZES 15,25,150,30 SIZE 310,095 OF _oDlg PIXEL ON DBLCLICK Marca(_oList,_aDados)
_oList:SetArray(_aDados)
_oList:bLine := { || {Iif(_aDados[_oList:nAT,01],oMarked,oNoMarked),_aDados[_oList:nAt,2],_aDados[_oList:nAt,3],_aDados[_oList:nAt,4]}}

@ 130,250 BUTTON OemToAnsi("Caminho") 	   SIZE 050,11 ACTION Processa( {|| CriaPath(cPath) }) OF _oDlg PIXEL
_oDlg:Refresh()
@ 130,005 SAY "Informe o caminho dos relat�rios:"
@ 130,090 GET cPath VALID VAL_PATH(ALLTRIM(cPath))
@ 145,005 SAY "Informe o per��do dos relat�rios:"
@ 145,090 GET cPeriodo PICTURE "@E 99/9999" VALID VAL_PERIOD(cPeriodo)

//////////  francisco neto 19/09/201

@ 145,120 SAY "Filial de inicio:"
@ 145,155 GET _cFilialI  

@ 145,170 SAY "Filial de fim:"
@ 145,200 GET _cFilialF VALID VAL_cFilialF(_cFilialF)
if cCodemp = "40"
	@ 145,220 SAY "Dt Contabil.:"
	@ 145,255 GET _cDtContab picture "@E 99/99/9999" size 050,050  
endif
@ 160,010 BUTTON OemToAnsi("Inverter Sele��o") SIZE 080,11 ACTION Processa( {|| MTodos(_oList,_aDados) }) OF _oDlg PIXEL

@ 160,240 BUTTON OemToAnsi("Processa") 	   		   SIZE 050,11 ACTION Processa( {|| ProcRel(_oList,_aDados,ALLTRIM(cPath),cPeriodo) }) OF _oDlg PIXEL
@ 160,290 BUTTON OemToAnsi("Sair")  	   		   SIZE 030,11 ACTION Processa( {|| Val_Sai() }) OF _oDlg PIXEL
ACTIVATE DIALOG _oDlg CENTERED

RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function  �ProcRel   �Autor  �Cesar Chena         � Data �  16/06/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Auterado  �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION PROCREL(_oList,_aDados,cPath,cPeriodo)
Local i
Local oDlg
Local cMemo
Local cFile    :=""
Local cMask    :="*.txt|"
Local oFont
Local cMark 

If RIGHT(AllTrim(cPath),1) <> "\"
	cPath := AllTrim(cPath) + "\"
EndIf

//Cria o diretorio caso nao exista
If MAKEDIR(cPath) == 0
	Aviso( "Importante", "O Diret�rio '" +cPath+ "' foi criado",{"Ok"})
EndIf    

/////*
If MAKEDIR(cPathH) == 0
	Aviso( "Importante", "O Diret�rio '" +cPathH+ "' foi criado",{"Ok"})
EndIf    

If MAKEDIR(cPathL) == 0
	Aviso( "Importante", "O Diret�rio '" +cPathL+ "' foi criado",{"Ok"})
EndIf    

If MAKEDIR(cPathO) == 0
	Aviso( "Importante", "O Diret�rio '" +cPathO+ "' foi criado",{"Ok"})
EndIf    

If MAKEDIR(cPathT) == 0
	Aviso( "Importante", "O Diret�rio '" +cPathT+ "' foi criado",{"Ok"})
EndIf    
////*/

Farol:=.f.
for x := 1 to len(_aDados)
    if _aDados[ x , 1 ]
       Farol:=.t.
    endif
next
if !Farol
	alert('Nenhum relatorio foi selecionado')
endif
if Alltrim(cPeriodo) = '/'
   Farol:=.f.
	alert('O parametro Periodo �Ede preenchimento obrigatorio')
endif   
If RIGHT(cPeriodo,4)+LEFT(cPeriodo,2) > GETMV("MV_FOLMES")
	Farol:=.f.
	alert('Periodo informado ainda nao foi calculado')
endif

if Farol
	
	cNomeRel := _aDados[ _oList:nAT, 1 ]
	For i:=1 to len(_aDados)
		cMark    := _aDados[ i , 1 ]
		cNomeRel := _aDados[ i , 4 ]     
		
		If cMark
			If i=1
				Processa( {|| U_GTADP_01(cPath,cPeriodo) })
			Elseif i=2
				Processa( {|| U_GTADP_02(cPath,cPeriodo) })
			Elseif i=3
				Processa( {|| U_GTADP_03(cPath,cPeriodo) })
			Elseif i=4
				Processa( {|| U_GTADP_04(cPath,cPeriodo) })
			Elseif i=5
				Processa( {|| U_GTADP_05(cPath,cPeriodo) })
			Elseif i=6
				Processa( {|| U_GTADP_06(cPath,cPeriodo) })
			Elseif i=7
				Processa( {|| U_GTADP_07(cPath,cPeriodo) })
			Elseif i=8
				Processa( {|| U_GTADP_08(cPath,cPeriodo) })
			Elseif i=9
				Processa( {|| U_GTADP_09(cPath,cPeriodo) })
			Endif
		Endif
	Next

	MsgInfo("Fim do processamento.","Aten��o")
		
	Close(_oDlg)
endif

Return()

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Marca		| Autor � Cesar Chena               �Data�16/06/15  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca itens do listbox                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Executado no listbox                             ���
���          � ExpO1 - Objeto listbox                                       ���
���          � ExpA1 - Vetor contendo os itens do listbox                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Static Function Marca(_oList,_aDados)

Local _i 	:= 1
Local _nPos := _oList:nAT

//-- Inverte Marcacao do item posicionado


//For _i := 1 TO Len(_aDados)
//	If _i == _nPos
_aDados[ _oList:nAT, 1 ] := !_aDados[ _oList:nAT, 1 ]
//	EndIf
//	_oList:nAT	 := _i
//	_aDados[ _oList:nAT, 1 ] := !_aDados[ _oList:nAT, 1 ]
//Next

_oList:Refresh()

Return

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MTodos	| Autor � Cesar Chena               �Data�16/06/15  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca todos itens do listbox                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Executado no listbox                             ���
���          � ExpO1 - Objeto listbox                                       ���
���          � ExpA1 - Vetor contendo os itens do listbox                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Static Function Mtodos(_oList,_aDados)

Local _i 	:= 1
Local _nPos := _oList:nAT

For _i := 1 TO Len(_aDados)
	_oList:nAT	 := _i
	//If _aDados[ _oList:nAT, 1 ]
	_aDados[ _oList:nAT, 1 ] := !_aDados[ _oList:nAT, 1 ]
	//Else
	//	_aDados[ _oList:nAT, 1 ] := _aDados[ _oList:nAT, 1 ]
	//Endif
Next

_oList:nAT	 := 1
_oList:Refresh()

Return

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CriaPath	| Autor � Cesar Chena               �Data�16/06/15  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cria path para a gravacao do relatorio/planilha              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Executado no listbox                             ���
���          � ExpO1 - Objeto listbox                                       ���
���          � ExpA1 - Vetor contendo os itens do listbox                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Static Function Criapath

cPath	:= cGetFile("","Local",0,"",.T.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY)
cPath   += IIf( Right( AllTrim( cPath ), 1 ) <> '\' , '\', '' )

Return(cPath)

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Val_Path	| Autor � Cesar Chena               �Data�16/06/15  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida path para a gravacao do relatorio/planilha            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Executado no listbox                             ���
���          � ExpO1 - Objeto listbox                                       ���
���          � ExpA1 - Vetor contendo os itens do listbox                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Static Function Val_path

Private cRet := .t.

If !LisDir(cPath)
	Aviso("ATEN��O", "� necess�rio informar um caminho para grava��o dos relat�rios. Verifique!", {"Ok"} )
	cPath := "C:\"+space(77)
	cRet := .f.
Endif

Return(cRet)

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Val_Period| Autor � Cesar Chena               �Data�16/06/15  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Periodo para a gravacao do relatorio/planilha         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Executado no listbox                             ���
���          � ExpO1 - Objeto listbox                                       ���
���          � ExpA1 - Vetor contendo os itens do listbox                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Static Function Val_period

Private cRet := .t.

If val(subs(cPeriodo,1,2)) < 1 .or. val(subs(cPeriodo,1,2)) > 12
	Aviso("ATEN��O", "� necess�rio informar um m�s v�lido para gera��o dos relat�rios. Verifique!", {"Ok"} )
	cRet := .f.
Endif
If val(subs(cPeriodo,4,4)) < 2000 .or. val(subs(cPeriodo,4,4)) > 2020
	Aviso("ATEN��O", "� necess�rio informar um ano v�lido para gera��o dos relat�rios. Verifique!", {"Ok"} )
	cRet := .f.
Endif

Return(cRet)


///////  francisco neto  19/09/2016
Static Function VAL_cFilialF

Private cRet := .t.

///If  len(alltrim(_cFilialI)) = 0 
///	Aviso("ATEN��O", "Informe uma filial para inicio do relat�rio. Verifique!", {"Ok"} )
///	cRet := .f.
///Endif
If  len(alltrim(_cFilialF)) = 0 
	Aviso("ATEN��O", "Informe uma filial para fim do relat�rio. Verifique!", {"Ok"} )
	cRet := .f.
Endif

Return(cRet)


///////  francisco neto  22/09/2016
Static Function VAL_cRegime

Private cRet := .t.

If  len(alltrim(_cRegime)) = 0 .or. !upper(_cRegime) $('SN')
	Aviso("ATEN��O", "Informe S ou N. Verifique!", {"Ok"} )
	cRet := .f.
Endif

Return(cRet)




/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Val_Sai	| Autor � Cesar Chena               �Data�16/06/15  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Saida da geracao dos relatorios/planilhas             ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - 1 = Executado no listbox                             ���
���          � ExpO1 - Objeto listbox                                       ���
���          � ExpA1 - Vetor contendo os itens do listbox                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������*/
Static Function Val_Sai

If MsgYesNo("Deseja realmente abandonar a rotina ?")
	Close(_oDlg)
Endif

Return

