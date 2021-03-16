#Include "Rwmake.ch"
#Include "Colors.ch"
#Include "MsOle.ch"

/*
Funcao      : FIRGPE02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Integração com o Microsoft Word    
Autor     	: Wederson L. Santana
Data     	: 06/10/2006
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Gestão Pessoal.
*/

*-------------------------*
 User Function FIRGPE02()
*-------------------------*

_nSemana :=0
_cArquivo:=Space(80)
_cMatricula:=Space(06)
_cTurno1 :=Space(50)
_cTurno2 :=Space(50)
_cTestem1:=Space(60)
_cTestem2:=Space(60)
_cArquivo:="Informe o local do arquivo"

@ 000,0 To 300,400 Dialog oEscolha Title ""
@ 020,1 To 111,200
@ 112,1 To 150,200

@ 005,010 Get _cArquivo Size 150,150                         
@ 005,150 BmpButton Type 14 Action fBuscaArq()
@ 025,010 Say "Funcionario" COLOR CLR_HBLUE, CLR_WHITE
@ 025,060 Get _cMatricula F3 "SRA" Size 50,15                                                               
@ 040,010 Say "Turno 1:" COLOR CLR_HBLUE, CLR_WHITE
@ 040,060 Get _cTurno1 Size 80,15
@ 055,010 Say "Turno 2:" COLOR CLR_HBLUE, CLR_WHITE
@ 055,060 Get _cTurno2 Size 80,15                                                                           
//@ 070,010 Say "Horas Semanais:" COLOR CLR_HBLUE, CLR_WHITE
//@ 070,060 Get _nSemana Size 50,15
//@ 085,010 Say "Testemunha 1:" COLOR CLR_HBLUE, CLR_WHITE
//@ 085,060 Get _cTestem1 Size 90,15
//@ 100,010 Say "Testemunha 2:" COLOR CLR_HBLUE, CLR_WHITE
//@ 100,060 Get _cTestem2 Size 90,15                                                                           
@ 115,135 Button "_Confirma  " Size 50,15 Action Processa( {|| fImpWord() },"Selecionando Registros...",,.T. )
@ 130,135 Button "_Abandona  " Size 50,15 Action Close(oEscolha)
@ 115,010 Say "Integração com Microsoft Word" COLOR CLR_HRED, CLR_WHITE
@ 125,010 Say "Sera impresso de acordo com os parametros"
@ 135,010 Say "selecionados pelo usuario."

Activate Dialog oEscolha Center

Return

//--------------------------------------------------   

Static Function fBuscaArq()
	cType := "Arq.   | *.DOC"
	_cArquivo := cGetFile(cType, OemToAnsi("Selecione arquivo "+Subs(cType,1,6)))
Return(NIL)

//--------------------------------------------

Static Function fImpWord()

SRA->(DbSetOrder(1))
SRA->(DbSeek(xFilial("SRA")+_cMatricula))

SRJ->(DbSetOrder(1))
SRJ->(DbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))

DbSelectArea("SM0")

hWord := OLE_CreateLink()
OLE_SetPropertie( hWord, oleWdPrintBack, .F.)
OLE_SetPropertie( hWord, oleWdVisible, .T.)
OLE_NewFile(hWord,_cArquivo)

OLE_SetDocumentVar(hWord, 'GPE_NOME_EMPRESA', SM0->M0_NOMECOM)
OLE_SetDocumentVar(hWord, 'GPE_CID_EMPRESA', AllTrim(SM0->M0_CIDCOB))
OLE_SetDocumentVar(hWord, 'GPE_END_EMPRESA', SM0->M0_ENDCOB)
OLE_SetDocumentVar(hWord, 'GPE_BAI_EMPRESA', SM0->M0_BAIRCOB)
OLE_SetDocumentVar(hWord, 'GPE_CEP_EMPRESA',Transform(SM0->M0_CEPCOB,"@R 99999-999"))
OLE_SetDocumentVar(hWord, 'GPE_ESTADO', SM0->M0_ESTCOB)
OLE_SetDocumentVar(hWord, 'GPE_CNPJ_EMPRESA',Transform(SM0->M0_CGC,"@R 999.999.999/999-99") )
OLE_SetDocumentVar(hWord, 'GPE_CGC_EMPRESA',Transform(SM0->M0_CGC,"@R 999.999.999/999-99") )
OLE_SetDocumentVar(hWord, 'GPE_NOME', SRA->RA_NOME)
OLE_SetDocumentVar(hWord, 'GPE_NUMERO_CTPS', SRA->RA_NUMCP)
OLE_SetDocumentVar(hWord, 'GPE_CTPS', SRA->RA_NUMCP)
OLE_SetDocumentVar(hWord, 'GPE_SERIE_CTPS', SRA->RA_SERCP)
OLE_SetDocumentVar(hWord, 'GPE_UF_CTPS', SRA->RA_UFCP)
OLE_SetDocumentVar(hWord, 'GPE_DESC_FUNCAO', Alltrim(SRJ->RJ_DESC))
OLE_SetDocumentVar(hWord, 'GPE_SALARIO', AllTrim(Transform(SRA->RA_SALARIO,"@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, 'GPE_SALARIO_EXTENSO', Extenso(SRA->RA_SALARIO))
OLE_SetDocumentVar(hWord, 'GPE_POR_MES_HORA',AllTrim(Transform(SRA->RA_SALARIO/SRA->RA_HRSMES,"@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, 'GPE_TURNO_1', AllTrim(_cTurno1))
OLE_SetDocumentVar(hWord, 'GPE_TURNO_2', AllTrim(_cTurno2))
OLE_SetDocumentVar(hWord, 'GPE_TOTAL_HRS_SEMANAL',AllTrim(Transform(SRA->RA_HRSEMAN,"@E 999.99")))
OLE_SetDocumentVar(hWord, 'GPE_TOTAL_HRS_EXTENSO', StrTran(Extenso(SRA->RA_HRSEMAN),"REAIS",""))
OLE_SetDocumentVar(hWord, 'GPE_DATA',AllTrim(Str(Day(dDataBase)))+" de "+MesExtenso(dDataBase)+" de "+AllTrim(Str(Year(dDataBase)))) 
OLE_SetDocumentVar(hWord, 'GPE_DATA_ADMISSAO',AllTrim(Str(Day(SRA->RA_ADMISSA)))+" de "+MesExtenso(SRA->RA_ADMISSA)+" de "+AllTrim(Str(Year(SRA->RA_ADMISSA)))) 
OLE_SetDocumentVar(hWord, 'GPE_NOME_EMPRESA', AllTrim(SM0->M0_NOMECOM))
OLE_SetDocumentVar(hWord, 'GPE_NOME_FUNCIONARIO',AllTrim(SRA->RA_NOME))
OLE_SetDocumentVar(hWord, 'GPE_NOME',AllTrim(SRA->RA_NOME))
OLE_SetDocumentVar(hWord, 'GPE_ENDERECO',AllTrim(SRA->RA_ENDEREC)+" "+AllTrim(SRA->RA_COMPLEM))
OLE_SetDocumentVar(hWord, 'GPE_BAIRRO',AllTrim(SRA->RA_BAIRRO))
OLE_SetDocumentVar(hWord, 'GPE_MUNICIPIO',AllTrim(SRA->RA_MUNICIP))
OLE_SetDocumentVar(hWord, 'GPE_ESTADO',AllTrim(SRA->RA_ESTADO))
OLE_SetDocumentVar(hWord, 'GPE_DESC_BCO_SAL',Left(AllTrim(SRA->RA_BCDEPSA),3))
OLE_SetDocumentVar(hWord, 'GPE_BCO_AG_DEP_SAL',Right(AllTrim(SRA->RA_BCDEPSA),4))
OLE_SetDocumentVar(hWord, 'GPE_CTA_DEP_SAL',AllTrim(SRA->RA_CTDEPSA))
//OLE_SetDocumentVar(hWord, 'GPE_TESTEMUNHA_1', AllTrim(_cTestem1))
//OLE_SetDocumentVar(hWord, 'GPE_TESTEMUNHA_2', AllTrim(_cTestem2))

OLE_UpdateFields( hWord )

If MsgYesNo("Imprime o Documento ?")
	OLE_PrintFile( hWord, 'PART', 1, 1,1)
Endif
If MsgYesNo("Fecha o Microsoft Word ?")
	OLE_CloseFile( hWord )
	OLE_CloseLink( hWord )
Endif
Return