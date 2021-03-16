#include "rwmake.ch"
#include "colors.ch"

/*
Funcao      : R7BFAT02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para manutenção das previsões de recebimento  
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
 User Function R7BFAT02()
*-------------------------*

DbSelectArea("SZ8")                                                                      
aRotina := {{"Pesquisar",'AxPesqui'   ,0,1},{"Visualizar",'U_fOkVis()',0,2},;
            {"Alterar"  ,"U_fOkAlt()",0,3},{"Excluir "  ,"U_fOkExc()",0,4},;
            {"Incluir"  ,"U_fOkInc()",0,5}}  

cCadastro := "Manutencao das Previsoes de Recebimento"

mBrowse(01,01,30,70,"SZ8",,,,,,)

Return(Nil)

//-------------------------------------------------------------

User Function fOkVis()   

@ 000,000 To 380,280 Dialog oDlg Title "Visualizacao"
@ 001,001 To 025,140
@ 025,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Say SZ8->Z8_CODE+"- "+SubStr(SZ8->Z8_DESCR,1,29)
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Say SZ8->Z8_ANO

@ 030,038 Say "Valor"
@ 030,088 Say "Quantidade"

@ 040,005 Say "Janeiro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 040,040 Get SZ8->Z8_JANVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 040,090 Get SZ8->Z8_JAN    When .F. Size 040,040
@ 050,005 Say "Fevereiro" COLOR CLR_HBLUE, CLR_WHITE 
@ 050,040 Get SZ8->Z8_FEVVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 050,090 Get SZ8->Z8_FEV    When .F. Size 040,040
@ 060,005 Say "Marco"     COLOR CLR_HBLUE, CLR_WHITE 
@ 060,040 Get SZ8->Z8_MARVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 060,090 Get SZ8->Z8_MAR    When .F. Size 040,040
@ 070,005 Say "Abril"     COLOR CLR_HBLUE, CLR_WHITE 
@ 070,040 Get SZ8->Z8_ABRVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 070,090 Get SZ8->Z8_ABR    When .F. Size 040,040
@ 080,005 Say "Maio"      COLOR CLR_HBLUE, CLR_WHITE 
@ 080,040 Get SZ8->Z8_MAIVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 080,090 Get SZ8->Z8_MAI    When .F. Size 040,040
@ 090,005 Say "Junho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 090,040 Get SZ8->Z8_JUNVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 090,090 Get SZ8->Z8_JUN    When .F. Size 040,040
@ 100,005 Say "Julho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 100,040 Get SZ8->Z8_JULVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 100,090 Get SZ8->Z8_JUL    When .F. Size 040,040
@ 110,005 Say "Agosto"    COLOR CLR_HBLUE, CLR_WHITE 
@ 110,040 Get SZ8->Z8_AGOVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 110,090 Get SZ8->Z8_AGO    When .F. Size 040,040
@ 120,005 Say "Setembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 120,040 Get SZ8->Z8_SETVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 120,090 Get SZ8->Z8_SET    When .F. Size 040,040
@ 130,005 Say "Outubro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 130,040 Get SZ8->Z8_OUTVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 130,090 Get SZ8->Z8_OUT    When .F. Size 040,040
@ 140,005 Say "Novembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 140,040 Get SZ8->Z8_NOVVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 140,090 Get SZ8->Z8_NOV    When .F. Size 040,040
@ 150,005 Say "Dezembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 150,040 Get SZ8->Z8_DEZVAL When .F. Size 040,040 Picture "@E 999,999,999.99" 
@ 150,090 Get SZ8->Z8_DEZ    When .F. Size 040,040

@ 170,045 Button "_Sair  " Size 50,15 Action Close(oDlg)
Activate Dialog oDlg Center

Return

//----------------------------------------------------------

User Function fOkAlt()   
nValJan:=SZ8->Z8_JANVAL
nQtdJan:=SZ8->Z8_JAN
nQtdFev:=SZ8->Z8_FEV
nValFev:=SZ8->Z8_FEVVAL
nQtdMar:=SZ8->Z8_MAR
nValMar:=SZ8->Z8_MARVAL
nQtdAbr:=SZ8->Z8_ABR
nValAbr:=SZ8->Z8_ABRVAL
nQtdMai:=SZ8->Z8_MAI
nValMai:=SZ8->Z8_MAIVAL
nQtdJun:=SZ8->Z8_JUN
nValJun:=SZ8->Z8_JUNVAL
nQtdJul:=SZ8->Z8_JUL
nValJul:=SZ8->Z8_JULVAL
nQtdAgo:=SZ8->Z8_AGO
nValAgo:=SZ8->Z8_AGOVAL
nQtdSet:=SZ8->Z8_SET
nValSet:=SZ8->Z8_SETVAL
nQtdOut:=SZ8->Z8_OUT
nValOut:=SZ8->Z8_OUTVAL
nQtdNov:=SZ8->Z8_NOV
nValNov:=SZ8->Z8_NOVVAL
nQtdDez:=SZ8->Z8_DEZ
nValDez:=SZ8->Z8_DEZVAL

@ 000,000 To 380,280 Dialog oDlg Title "Alteracao"
@ 001,001 To 025,140
@ 025,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Say SZ8->Z8_CODE+"- "+SubStr(SZ8->Z8_DESCR,1,29)
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Say SZ8->Z8_ANO

@ 030,038 Say "  Valor"
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

User Function fOkExc()   

@ 000,000 To 380,280 Dialog oDlg Title "Exclusao"
@ 001,001 To 025,140
@ 025,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Say SZ8->Z8_CODE+"- "+SubStr(SZ8->Z8_DESCR,1,29) 
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Say SZ8->Z8_ANO
                            
@ 030,038 Say "  Valor"
@ 030,088 Say "  Quantidade"

@ 040,005 Say "Janeiro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 040,040 Get SZ8->Z8_JANVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 040,090 Get SZ8->Z8_JAN    When .F. Size 040,040
@ 050,005 Say "Fevereiro" COLOR CLR_HBLUE, CLR_WHITE 
@ 050,040 Get SZ8->Z8_FEVVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 050,090 Get SZ8->Z8_FEV    When .F. Size 040,040
@ 060,005 Say "Marco"     COLOR CLR_HBLUE, CLR_WHITE 
@ 060,040 Get SZ8->Z8_MARVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 060,090 Get SZ8->Z8_MAR    When .F. Size 040,040
@ 070,005 Say "Abril"     COLOR CLR_HBLUE, CLR_WHITE 
@ 070,040 Get SZ8->Z8_ABRVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 070,090 Get SZ8->Z8_ABR    When .F. Size 040,040
@ 080,005 Say "Maio"      COLOR CLR_HBLUE, CLR_WHITE 
@ 080,040 Get SZ8->Z8_MAIVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 080,090 Get SZ8->Z8_MAI    When .F. Size 040,040
@ 090,005 Say "Junho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 090,040 Get SZ8->Z8_JUNVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 090,090 Get SZ8->Z8_JUN    When .F. Size 040,040
@ 100,005 Say "Julho"     COLOR CLR_HBLUE, CLR_WHITE 
@ 100,040 Get SZ8->Z8_JULVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 100,090 Get SZ8->Z8_JUL    When .F. Size 040,040
@ 110,005 Say "Agosto"    COLOR CLR_HBLUE, CLR_WHITE 
@ 110,040 Get SZ8->Z8_AGOVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 110,090 Get SZ8->Z8_AGO    When .F. Size 040,040
@ 120,005 Say "Setembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 120,040 Get SZ8->Z8_SETVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 120,090 Get SZ8->Z8_SET    When .F. Size 040,040
@ 130,005 Say "Outubro"   COLOR CLR_HBLUE, CLR_WHITE 
@ 130,040 Get SZ8->Z8_OUTVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 130,090 Get SZ8->Z8_OUT    When .F. Size 040,040
@ 140,005 Say "Novembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 140,040 Get SZ8->Z8_NOVVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 140,090 Get SZ8->Z8_NOV    When .F. Size 040,040
@ 150,005 Say "Dezembro"  COLOR CLR_HBLUE, CLR_WHITE 
@ 150,040 Get SZ8->Z8_DEZVAL When .F. Size 040,040 Picture "@E 999,999,999.99"
@ 150,090 Get SZ8->Z8_DEZ    When .F. Size 040,040

@ 170,015 Button "_Sair  " Size 50,15 Action Close(oDlg)
@ 170,080 Button "_Confirma  " Size 50,15 Action Processa( {|| OkExclui() },"Excluindo Registro...",,.T. )
Activate Dialog oDlg Center

Return

//------------------------------------------------

User Function fOkInc()   

nValJan:=nValFev:=nValMar:=nValAbr:=nValMai:=0
nValJun:=nValJul:=nValAgo:=nValSet:=nValOut:=0
nValNov:=nValDez:=0

nQtdJan:=nQtdFev:=nQtdMar:=nQtdAbr:=nQtdMai:=0
nQtdJun:=nQtdJul:=nQtdAgo:=nQtdSet:=nQtdOut:=0
nQtdNov:=nQtdDez:=0

cCodigo   :=Space(06)
cDescricao:=Space(29)
cAno      :=Space(04)

@ 000,000 To 380,280 Dialog oDlg Title "Inclusao"
@ 001,001 To 027,140
@ 026,001 To 164,140
@ 165,001 To 188,140

@ 005,005 Say "Codigo "   COLOR CLR_HRED, CLR_WHITE 
@ 005,025 Get cCodigo    F3 "XB1" Size 010,010 Valid fValCamp()
@ 005,054 Get cDescricao Size 085,085 When .F.
@ 015,005 Say "Ano"       COLOR CLR_HRED, CLR_WHITE 
@ 015,025 Get cAno Size 010,010 Valid fValid()
@ 017,055 Say "(AAAA)

@ 030,038 Say "  Valor"
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

DbSetOrder(1)
If DbSeek(xFilial("SZ8")+SZ8->Z8_CODE+SZ8->Z8_ANO)
	Reclock("SZ8",.F.)
	Delete
	MsUnlock()
Endif	      
Close(oDlg)

Return

//-----------------------------------------

Static Function OkAltera()

DbSetOrder(1)
If DbSeek(xFilial("SZ8")+SZ8->Z8_CODE+SZ8->Z8_ANO)
	Reclock("SZ8",.F.)
   Replace SZ8->Z8_JAN    With nQtdJan
   Replace SZ8->Z8_JANVAL With nValJan
   Replace SZ8->Z8_FEV    With nQtdFev
   Replace SZ8->Z8_FEVVAL With nValFev
   Replace SZ8->Z8_MAR    With nQtdMar
   Replace SZ8->Z8_MARVAL With nValMar
   Replace SZ8->Z8_ABR    With nQtdAbr
   Replace SZ8->Z8_ABRVAL With nValAbr
   Replace SZ8->Z8_MAI    With nQtdMai
   Replace SZ8->Z8_MAIVAL With nValMai
   Replace SZ8->Z8_JUN    With nQtdJun
   Replace SZ8->Z8_JUNVAL With nValJun
   Replace SZ8->Z8_JUL    With nQtdJul
   Replace SZ8->Z8_JULVAL With nValJul
   Replace SZ8->Z8_AGO    With nQtdAgo
   Replace SZ8->Z8_AGOVAL With nValAgo
   Replace SZ8->Z8_SET    With nQtdSet
   Replace SZ8->Z8_SETVAL With nValSet
   Replace SZ8->Z8_OUT    With nQtdOut
   Replace SZ8->Z8_OUTVAL With nValOut
   Replace SZ8->Z8_NOV    With nQtdNov
   Replace SZ8->Z8_NOVVAL With nValNov
   Replace SZ8->Z8_DEZ    With nQtdDez
   Replace SZ8->Z8_DEZVAL With nValDez
	MsUnlock()
Endif	      
Close(oDlg)
Return

//-----------------------------------------

Static Function OkInclui()

Reclock("SZ8",.T.)
Replace SZ8->Z8_CODE   With cCodigo
Replace SZ8->Z8_DESCR  With cDescricao
Replace SZ8->Z8_ANO    With cAno
Replace SZ8->Z8_JAN    With nQtdJan
Replace SZ8->Z8_FEV    With nQtdFev
Replace SZ8->Z8_MAR    With nQtdMar
Replace SZ8->Z8_ABR    With nQtdAbr
Replace SZ8->Z8_MAI    With nQtdMai
Replace SZ8->Z8_JUN    With nQtdJun
Replace SZ8->Z8_JUL    With nQtdJul
Replace SZ8->Z8_AGO    With nQtdAgo
Replace SZ8->Z8_SET    With nQtdSet
Replace SZ8->Z8_OUT    With nQtdOut
Replace SZ8->Z8_NOV    With nQtdNov
Replace SZ8->Z8_DEZ    With nQtdDez
Replace SZ8->Z8_JANVAL With nValJan
Replace SZ8->Z8_FEVVAL With nValFev
Replace SZ8->Z8_MARVAL With nValMar
Replace SZ8->Z8_ABRVAL With nValAbr
Replace SZ8->Z8_MAIVAL With nValMai
Replace SZ8->Z8_JUNVAL With nValJun
Replace SZ8->Z8_JULVAL With nValJul
Replace SZ8->Z8_AGOVAL With nValAgo
Replace SZ8->Z8_SETVAL With nValSet
Replace SZ8->Z8_OUTVAL With nValOut
Replace SZ8->Z8_NOVVAL With nValNov
Replace SZ8->Z8_DEZVAL With nValDez

MsUnlock()
Close(oDlg)
Return

//-----------------------------------------

Static Function fValid()
lRet  :=.T.      
nRecno:=Recno()
DbSelectArea("SZ8")
DbSetOrder(1)
If DbSeek(xFilial("SZ8")+cCodigo)//+cAno)//Wederson 22/06/05 -->Deixado dessa forma por problemas no indice
   While Z8_FILIAL+Z8_CODE+Z8_ANO == xFilial("SZ8")+cCodigo+cAno
         MsgInfo("Projecao para este ano ja inclusa !","A T E N C A O")
         lRet:=.F.
         DbSkip()
   End      
Endif      
If Empty(cDescricao)
   MsgInfo("Descricao nao preenchida !","A T E N C A O")
Endif
If Empty(cAno)
   MsgInfo("Informe o ano !","A T E N C A O")
   lRet:=.F.
Endif 
DbGoto(nRecno)
Return(lRet)

//--------------------------------------------------------

Static Function fValCamp()
lRet:=.T.
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cCodigo))
cDescricao:=SB1->B1_DESC
If Empty(cCodigo)
   lRet:=.F.
Endif
Return(lRet)