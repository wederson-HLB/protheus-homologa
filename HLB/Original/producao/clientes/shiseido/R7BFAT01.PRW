#include "rwmake.ch"
#include "colors.ch"

/*
Funcao      : R7BFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para manutenção das projecoes 
Autor     	: Wederson Lourenco Santana                               
Data     	: 21/06/2005                     
Obs         : Projeto Ginga 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Generico. 
Cliente     : Shiseido
*/

*-------------------------*
 User Function R7BFAT01()
*-------------------------*


DbSelectArea("SZ7")                                                                      
aRotina := {{"Pesquisar",'AxPesqui'   ,0,1},{"Visualizar",'U_fVisual()',0,2},;
            {"Alterar"  ,"U_fAltera()",0,3},{"Excluir "  ,"U_fExclui()",0,4},;
            {"Incluir"  ,"U_fInclui()",0,5}}  

cCadastro := "Manutencao das Projecoes"

mBrowse(01,01,30,70,"SZ7",,,,,,)

Return(Nil)

//-------------------------------------------------------------

User Function fVisual()   

@ 000,000 To 380,280 Dialog oDlg Title "Visualizacao"
@ 001,001 To 025,140
@ 025,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Say SZ7->Z7_CODE+"- "+SubStr(SZ7->Z7_DESC ,1,29)
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Say SZ7->Z7_ANO

@ 030,041 Say "Valor"
@ 030,088 Say "  Quantidade"

@ 040,005 Say "Janeiro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 040,040 Get SZ7->Z7_JANVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 040,090 Get SZ7->Z7_JANQTD When .F. Size 040,040
@ 050,005 Say "Fevereiro" COLOR CLR_HBLUE, CLR_WHITE 
@ 050,040 Get SZ7->Z7_FEVVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 050,090 Get SZ7->Z7_FEVQTD When .F. Size 040,040
@ 060,005 Say "Marco"     COLOR CLR_HBLUE, CLR_WHITE 
@ 060,040 Get SZ7->Z7_MARVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 060,090 Get SZ7->Z7_MARQTD When .F. Size 040,040
@ 070,005 Say "Abril"     COLOR CLR_HBLUE, CLR_WHITE 
@ 070,040 Get SZ7->Z7_ABRVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 070,090 Get SZ7->Z7_ABRQTD When .F. Size 040,040
@ 080,005 Say "Maio"      COLOR CLR_HBLUE, CLR_WHITE 
@ 080,040 Get SZ7->Z7_MAIVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 080,090 Get SZ7->Z7_MAIQTD When .F. Size 040,040
@ 090,005 Say "Junho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 090,040 Get SZ7->Z7_JUNVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 090,090 Get SZ7->Z7_JUNQTD When .F. Size 040,040
@ 100,005 Say "Julho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 100,040 Get SZ7->Z7_JULVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 100,090 Get SZ7->Z7_JULQTD When .F. Size 040,040
@ 110,005 Say "Agosto"    COLOR CLR_HBLUE, CLR_WHITE 
@ 110,040 Get SZ7->Z7_AGOVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 110,090 Get SZ7->Z7_AGOQTD When .F. Size 040,040
@ 120,005 Say "Setembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 120,040 Get SZ7->Z7_SETVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 120,090 Get SZ7->Z7_SETQTD When .F. Size 040,040
@ 130,005 Say "Outubro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 130,040 Get SZ7->Z7_OUTVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 130,090 Get SZ7->Z7_OUTQTD When .F. Size 040,040
@ 140,005 Say "Novembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 140,040 Get SZ7->Z7_NOVVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 140,090 Get SZ7->Z7_NOVQTD When .F. Size 040,040
@ 150,005 Say "Dezembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 150,040 Get SZ7->Z7_DEZVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 150,090 Get SZ7->Z7_DEZQTD When .F. Size 040,040

@ 170,045 Button "_Sair  " Size 50,15 Action Close(oDlg)
Activate Dialog oDlg Center

Return

//----------------------------------------------------------

User Function fAltera()   

nValJan:=SZ7->Z7_JANVAL 
nQtdJan:=SZ7->Z7_JANQTD 
nValFev:=SZ7->Z7_FEVVAL 
nQtdFev:=SZ7->Z7_FEVQTD 
nValMar:=SZ7->Z7_MARVAL 
nQtdMar:=SZ7->Z7_MARQTD 
nValAbr:=SZ7->Z7_ABRVAL 
nQtdAbr:=SZ7->Z7_ABRQTD 
nValMai:=SZ7->Z7_MAIVAL 
nQtdMai:=SZ7->Z7_MAIQTD 
nValJun:=SZ7->Z7_JUNVAL 
nQtdJun:=SZ7->Z7_JUNQTD 
nValJul:=SZ7->Z7_JULVAL 
nQtdJul:=SZ7->Z7_JULQTD 
nValAgo:=SZ7->Z7_AGOVAL 
nQtdAgo:=SZ7->Z7_AGOQTD 
nValSet:=SZ7->Z7_SETVAL 
nQtdSet:=SZ7->Z7_SETQTD 
nValOut:=SZ7->Z7_OUTVAL 
nQtdOut:=SZ7->Z7_OUTQTD 
nValNov:=SZ7->Z7_NOVVAL 
nQtdNov:=SZ7->Z7_NOVQTD 
nValDez:=SZ7->Z7_DEZVAL 
nQtdDez:=SZ7->Z7_DEZQTD 

@ 000,000 To 380,280 Dialog oDlg Title "Alteracao"
@ 001,001 To 025,140
@ 025,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Say SZ7->Z7_CODE+"- "+SubStr(SZ7->Z7_DESC ,1,29)
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Say SZ7->Z7_ANO

@ 030,041 Say "Valor"
@ 030,088 Say "  Quantidade"

@ 040,005 Say "Janeiro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 040,040 Get nValJan Size 040,040 Picture "@E 999,999,999.99" 
@ 040,090 Get nQtdJan Size 040,040 Picture "@E 999999999"
@ 050,005 Say "Fevereiro" COLOR CLR_HBLUE, CLR_WHITE 
@ 050,040 Get nValFev Size 040,040 Picture "@E 999,999,999.99" 
@ 050,090 Get nQtdFev Size 040,040 Picture "@E 999999999"
@ 060,005 Say "Marco"     COLOR CLR_HBLUE, CLR_WHITE 
@ 060,040 Get nValMar Size 040,040 Picture "@E 999,999,999.99" 
@ 060,090 Get nQtdMar Size 040,040 Picture "@E 999999999"
@ 070,005 Say "Abril"     COLOR CLR_HBLUE, CLR_WHITE 
@ 070,040 Get nValAbr Size 040,040 Picture "@E 999,999,999.99" 
@ 070,090 Get nQtdAbr Size 040,040 Picture "@E 999999999"
@ 080,005 Say "Maio"      COLOR CLR_HBLUE, CLR_WHITE 
@ 080,040 Get nValMai Size 040,040 Picture "@E 999,999,999.99" 
@ 080,090 Get nQtdMai Size 040,040 Picture "@E 999999999"
@ 090,005 Say "Junho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 090,040 Get nValJun Size 040,040 Picture "@E 999,999,999.99" 
@ 090,090 Get nQtdJun Size 040,040 Picture "@E 999999999"
@ 100,005 Say "Julho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 100,040 Get nValJul Size 040,040 Picture "@E 999,999,999.99" 
@ 100,090 Get nQtdJul Size 040,040 Picture "@E 999999999"
@ 110,005 Say "Agosto"    COLOR CLR_HBLUE, CLR_WHITE 
@ 110,040 Get nValAgo Size 040,040 Picture "@E 999,999,999.99" 
@ 110,090 Get nQtdAgo Size 040,040 Picture "@E 999999999"
@ 120,005 Say "Setembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 120,040 Get nValSet Size 040,040 Picture "@E 999,999,999.99" 
@ 120,090 Get nQtdSet Size 040,040 Picture "@E 999999999"
@ 130,005 Say "Outubro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 130,040 Get nValOut Size 040,040 Picture "@E 999,999,999.99" 
@ 130,090 Get nQtdOut Size 040,040 Picture "@E 999999999"
@ 140,005 Say "Novembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 140,040 Get nValNov Size 040,040 Picture "@E 999,999,999.99" 
@ 140,090 Get nQtdNov Size 040,040 Picture "@E 999999999"
@ 150,005 Say "Dezembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 150,040 Get nValDez Size 040,040 Picture "@E 999,999,999.99" 
@ 150,090 Get nQtdDez Size 040,040 Picture "@E 999999999"                                                        

@ 170,015 Button "_Sair  " Size 50,15 Action Close(oDlg)
@ 170,080 Button "_Confirma  " Size 50,15 Action Processa( {|| OkAltera() },"Gravando Registro...",,.T. )
Activate Dialog oDlg Center

Return

//----------------------------------------------------

User Function fExclui()   

@ 000,000 To 380,280 Dialog oDlg Title "Exclusao"
@ 001,001 To 025,140
@ 025,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Say SZ7->Z7_CODE+"- "+SubStr(SZ7->Z7_DESC ,1,29) 
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Say SZ7->Z7_ANO

@ 030,041 Say "Valor"
@ 030,088 Say "  Quantidade"

@ 040,005 Say "Janeiro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 040,040 Get SZ7->Z7_JANVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 040,090 Get SZ7->Z7_JANQTD When .F. Size 040,040
@ 050,005 Say "Fevereiro" COLOR CLR_HBLUE, CLR_WHITE 
@ 050,040 Get SZ7->Z7_FEVVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 050,090 Get SZ7->Z7_FEVQTD When .F. Size 040,040
@ 060,005 Say "Marco"     COLOR CLR_HBLUE, CLR_WHITE 
@ 060,040 Get SZ7->Z7_MARVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 060,090 Get SZ7->Z7_MARQTD When .F. Size 040,040
@ 070,005 Say "Abril"     COLOR CLR_HBLUE, CLR_WHITE 
@ 070,040 Get SZ7->Z7_ABRVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 070,090 Get SZ7->Z7_ABRQTD When .F. Size 040,040
@ 080,005 Say "Maio"      COLOR CLR_HBLUE, CLR_WHITE 
@ 080,040 Get SZ7->Z7_MAIVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 080,090 Get SZ7->Z7_MAIQTD When .F. Size 040,040
@ 090,005 Say "Junho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 090,040 Get SZ7->Z7_JUNVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 090,090 Get SZ7->Z7_JUNQTD When .F. Size 040,040
@ 100,005 Say "Julho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 100,040 Get SZ7->Z7_JULVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 100,090 Get SZ7->Z7_JULQTD When .F. Size 040,040
@ 110,005 Say "Agosto"    COLOR CLR_HBLUE, CLR_WHITE 
@ 110,040 Get SZ7->Z7_AGOVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 110,090 Get SZ7->Z7_AGOQTD When .F. Size 040,040
@ 120,005 Say "Setembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 120,040 Get SZ7->Z7_SETVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 120,090 Get SZ7->Z7_SETQTD When .F. Size 040,040
@ 130,005 Say "Outubro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 130,040 Get SZ7->Z7_OUTVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 130,090 Get SZ7->Z7_OUTQTD When .F. Size 040,040
@ 140,005 Say "Novembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 140,040 Get SZ7->Z7_NOVVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 140,090 Get SZ7->Z7_NOVQTD When .F. Size 040,040
@ 150,005 Say "Dezembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 150,040 Get SZ7->Z7_DEZVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 150,090 Get SZ7->Z7_DEZQTD When .F. Size 040,040

@ 170,015 Button "_Sair  " Size 50,15 Action Close(oDlg)
@ 170,080 Button "_Confirma  " Size 50,15 Action Processa( {|| OkExclui() },"Excluindo Registro...",,.T. )
Activate Dialog oDlg Center

Return

//------------------------------------------------

User Function fInclui()   

nValJan:=nQtdJan:=nValFev:=nQtdFev:=nValMar:=nQtdMar:=nValAbr:=nQtdAbr:=nValMai:=nQtdMai:=0
nValJun:=nQtdJun:=nValJul:=nQtdJul:=nValAgo:=nQtdAgo:=nValSet:=nQtdSet:=nValOut:=nQtdOut:=0
nValNov:=nQtdNov:=nValDez:=nQtdDez:=0

cCodigo   :=Space(06)
cDescricao:=Space(29)
cAno      :=Space(04)

@ 000,000 To 380,280 Dialog oDlg Title "Inclusao"
@ 001,001 To 027,140
@ 026,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Get cCodigo     F3 "XB1" Size 010,010 Valid fValCamp() 
@ 005,054 Get cDescricao  Size 085,085 When .F.
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Get cAno Size 010,010 Valid fValid()
@ 017,055 Say "(AAAA)

@ 030,041 Say "Valor"
@ 030,088 Say "  Quantidade"

@ 040,005 Say "Janeiro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 040,040 Get nValJan Size 040,040 Picture "@E 999,999,999.99" 
@ 040,090 Get nQtdJan Size 040,040 Picture "@E 999999999"
@ 050,005 Say "Fevereiro" COLOR CLR_HBLUE, CLR_WHITE 
@ 050,040 Get nValFev Size 040,040 Picture "@E 999,999,999.99" 
@ 050,090 Get nQtdFev Size 040,040 Picture "@E 999999999"
@ 060,005 Say "Marco"     COLOR CLR_HBLUE, CLR_WHITE 
@ 060,040 Get nValMar Size 040,040 Picture "@E 999,999,999.99" 
@ 060,090 Get nQtdMar Size 040,040 Picture "@E 999999999"
@ 070,005 Say "Abril"     COLOR CLR_HBLUE, CLR_WHITE 
@ 070,040 Get nValAbr Size 040,040 Picture "@E 999,999,999.99" 
@ 070,090 Get nQtdAbr Size 040,040 Picture "@E 999999999"
@ 080,005 Say "Maio"      COLOR CLR_HBLUE, CLR_WHITE 
@ 080,040 Get nValMai Size 040,040 Picture "@E 999,999,999.99" 
@ 080,090 Get nQtdMai Size 040,040 Picture "@E 999999999"
@ 090,005 Say "Junho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 090,040 Get nValJun Size 040,040 Picture "@E 999,999,999.99" 
@ 090,090 Get nQtdJun Size 040,040 Picture "@E 999999999"
@ 100,005 Say "Julho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 100,040 Get nValJul Size 040,040 Picture "@E 999,999,999.99" 
@ 100,090 Get nQtdJul Size 040,040 Picture "@E 999999999"
@ 110,005 Say "Agosto"    COLOR CLR_HBLUE, CLR_WHITE 
@ 110,040 Get nValAgo Size 040,040 Picture "@E 999,999,999.99" 
@ 110,090 Get nQtdAgo Size 040,040 Picture "@E 999999999"
@ 120,005 Say "Setembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 120,040 Get nValSet Size 040,040 Picture "@E 999,999,999.99" 
@ 120,090 Get nQtdSet Size 040,040 Picture "@E 999999999"
@ 130,005 Say "Outubro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 130,040 Get nValOut Size 040,040 Picture "@E 999,999,999.99" 
@ 130,090 Get nQtdOut Size 040,040 Picture "@E 999999999"
@ 140,005 Say "Novembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 140,040 Get nValNov Size 040,040 Picture "@E 999,999,999.99" 
@ 140,090 Get nQtdNov Size 040,040 Picture "@E 999999999"
@ 150,005 Say "Dezembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 150,040 Get nValDez Size 040,040 Picture "@E 999,999,999.99" 
@ 150,090 Get nQtdDez Size 040,040 Picture "@E 999999999"                                                        

@ 170,015 Button "_Sair  " Size 50,15 Action Close(oDlg)
@ 170,080 Button "_Confirma  " Size 50,15 Action Processa( {|| OkInclui() },"Gravando Registro...",,.T. )
Activate Dialog oDlg Center

Return

//-----------------------------------------

Static Function OkExclui()
Reclock("SZ7",.F.)
Delete
MsUnlock()
Close(oDlg)
Return

//-----------------------------------------

Static Function OkAltera()

DbSetOrder(1)
If DbSeek(xFilial("SZ7")+SZ7->Z7_CODE+SZ7->Z7_ANO)
	Reclock("SZ7",.F.)
	Replace SZ7->Z7_JANVAL With nValJan
   Replace SZ7->Z7_JANQTD With nQtdJan
   Replace SZ7->Z7_FEVVAL With nValFev
   Replace SZ7->Z7_FEVQTD With nQtdFev
   Replace SZ7->Z7_MARVAL With nValMar
   Replace SZ7->Z7_MARQTD With nQtdMar
   Replace SZ7->Z7_ABRVAL With nValAbr
   Replace SZ7->Z7_ABRQTD With nQtdAbr
   Replace SZ7->Z7_MAIVAL With nValMai
   Replace SZ7->Z7_MAIQTD With nQtdMai
   Replace SZ7->Z7_JUNVAL With nValJun
   Replace SZ7->Z7_JUNQTD With nQtdJun
   Replace SZ7->Z7_JULVAL With nValJul
   Replace SZ7->Z7_JULQTD With nQtdJul
   Replace SZ7->Z7_AGOVAL With nValAgo
   Replace SZ7->Z7_AGOQTD With nQtdAgo
   Replace SZ7->Z7_SETVAL With nValSet
   Replace SZ7->Z7_SETQTD With nQtdSet
   Replace SZ7->Z7_OUTVAL With nValOut
   Replace SZ7->Z7_OUTQTD With nQtdOut
   Replace SZ7->Z7_NOVVAL With nValNov
   Replace SZ7->Z7_NOVQTD With nQtdNov
   Replace SZ7->Z7_DEZVAL With nValDez
   Replace SZ7->Z7_DEZQTD With nQtdDez
	MsUnlock()
Endif	      
Close(oDlg)
Return

//-----------------------------------------

Static Function OkInclui()

Reclock("SZ7",.T.)
Replace SZ7->Z7_CODE   With cCodigo
Replace SZ7->Z7_DESC   With SubStr(cDescricao,1,34)
Replace SZ7->Z7_ANO    With cAno
Replace SZ7->Z7_JANVAL With nValJan
Replace SZ7->Z7_JANQTD With nQtdJan
Replace SZ7->Z7_FEVVAL With nValFev
Replace SZ7->Z7_FEVQTD With nQtdFev
Replace SZ7->Z7_MARVAL With nValMar
Replace SZ7->Z7_MARQTD With nQtdMar
Replace SZ7->Z7_ABRVAL With nValAbr
Replace SZ7->Z7_ABRQTD With nQtdAbr
Replace SZ7->Z7_MAIVAL With nValMai
Replace SZ7->Z7_MAIQTD With nQtdMai
Replace SZ7->Z7_JUNVAL With nValJun
Replace SZ7->Z7_JUNQTD With nQtdJun
Replace SZ7->Z7_JULVAL With nValJul
Replace SZ7->Z7_JULQTD With nQtdJul
Replace SZ7->Z7_AGOVAL With nValAgo
Replace SZ7->Z7_AGOQTD With nQtdAgo
Replace SZ7->Z7_SETVAL With nValSet
Replace SZ7->Z7_SETQTD With nQtdSet
Replace SZ7->Z7_OUTVAL With nValOut
Replace SZ7->Z7_OUTQTD With nQtdOut
Replace SZ7->Z7_NOVVAL With nValNov
Replace SZ7->Z7_NOVQTD With nQtdNov
Replace SZ7->Z7_DEZVAL With nValDez
Replace SZ7->Z7_DEZQTD With nQtdDez
MsUnlock()
Close(oDlg)
Return

//-----------------------------------------

Static Function fValid()
lRet  :=.T.       
nRecno:=Recno()
DbSelectArea("SZ7")
DbSetOrder(1)
If DbSeek(xFilial("SZ7")+cCodigo)//+cAno) //Wederson 22/06/05 -->Deixado dessa forma por problemas no indice
   While Z7_FILIAL+Z7_CODE+Z7_ANO == xFilial("SZ7")+cCodigo+cAno 
         MsgInfo("Projecao para este ano ja inclusa !","A T E N C A O")
         lRet:=.F.
         DbSkip()
   End      
Endif      
If Empty(cAno)
   MsgInfo("Informe o ano !","A T E N C A O")
   lRet:=.F.
Endif            
DbGoto(nRecno)
Return(lRet)

//-------------------------------------------

Static Function fValCamp()
lRet:=.T.
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cCodigo))
cDescricao:=SB1->B1_DESC
If Empty(cCodigo)
   lRet:=.F.
Endif
Return(lRet)