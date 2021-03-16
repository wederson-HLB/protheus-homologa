#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TOTVS.CH"
#include "protheus.ch"
#INCLUDE "TBICONN.CH"

#define DMPAPER_A4 9    // A4 210 x 297 mm

/*
IMPRESSAO DO BOLETO BANCO BRASIL COM CODIGO DE BARRAS

E1_MULTA  = Vlr. da multa a cerca do recebimento
E1_JUROS  = Vlr. da taxa permanencia cobrada
E1_CORREC = vlr. da Correcao referente ao recebimento
E1_VALJUR = Taxa diaria, tem precedencia ao % juros
E1_PORCJUR = % juro atraso dia

Campos que devem ser criados
E1_DVNSNUM = C = 1
EE_XCART = C = 3
EE_DVCTA = C = 1
EE_DVAGE = C = 1

EE_TIPODAT = Mudar para 4 a data para baixar sair correta

MV_TXPER = Indique o % da Taxa de Juros e colocado no E1_PORCJUR, ele ira calcular o E1_VALJUR
MV_LJMULTA = Percentual de multa para os titulos em atraso. Utilizado na rotina de recebimento de titulos.

*/

User Function SUFIN01(_Exec,_cDef2Printer)
Local	aPergs     := {}
Local   _cQry := ""
Private lJob := .F.

MsgStop( 'Essa rotina foi descontinuada!',"HLB BRASIL" )
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?reparo o ambiente na qual sera executada a rotina de negocio      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

/*
If Select("SX2") == 0 // Se via JOB
	lJob := .T.
	ConOut(DTOC(DATE())+"-"+Time()+" Iniciando rotina para emiss? de boletos...")
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SA3","SED","SEE","SE1","SEA"
else
	DbSelectArea("SA3")
	DbSelectArea("SED")
	DbSelectArea("SEE")
	DbSelectArea("SE1")
	DbSelectArea("SEA")
Endif
*/

PRIVATE lExec      := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''
PRIVATE cNumBco    := ''
PRIVATE cMarca     := GetMark()
//PRIVATE cNroDoc  :=  ""  //Eduardo(03.02.2009)
PRIVATE Tamanho  := "M"
PRIVATE titulo   := "Impressao de Boleto com Codigo de Barras"
PRIVATE cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
PRIVATE cDesc2   := ""
PRIVATE cDesc3   := ""
PRIVATE cString  := "SE1"
PRIVATE wnrel    := "BOLETO LASER"
PRIVATE lEnd     := .F.
PRIVATE cPerg     :=Padr("RFIN001",10)
PRIVATE aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nLastKey := 0
PRIVATE aCampos :={}
PRIVATE _MsExec	:= .F.

DEFAULT _Exec := {}

_MsExec	:= len(_Exec) > 0

AjustaSx1(cPerg)

Pergunte(cPerg, !_MsExec)

if LastKey() == 27
	Return
	
elseif Len(_Exec) <> 22 .and. _MsExec
	Aviso("ERRO","Informar ao Dept. T.I. diferen? nos parametros vindo do Faturamento, o Boleto poder?ser impresso pela opção Relatorio->Personalização-> Boleto Laser!",{"OK"})
	Return
	
elseif _MsExec
	MV_PAR01 := _Exec[01]	// Prefixo
	MV_PAR02 := _Exec[02]
	MV_PAR03 := _Exec[03]	// Nr.
	MV_PAR04 := _Exec[04]
	MV_PAR05 := _Exec[05]	// Parcela
	MV_PAR06 := _Exec[06]
	MV_PAR07 := _Exec[07]	// Portador
	MV_PAR08 := _Exec[08]
	MV_PAR09 := _Exec[09]	// Cliente
	MV_PAR10 := _Exec[10]
	MV_PAR11 := _Exec[11]	// Loja
	MV_PAR12 := _Exec[12]
	MV_PAR13 := _Exec[13]	// Emiss?
	MV_PAR14 := _Exec[14]
	MV_PAR15 := _Exec[15]	// Vencimento
	MV_PAR16 := _Exec[16]
	MV_PAR17 := _Exec[17]	// Nr. Bordero
	MV_PAR18 := _Exec[18]
	MV_PAR19 := _Exec[19]	// Nr. Carga
	MV_PAR20 := _Exec[20]
	MV_PAR21 := _Exec[21]	// Msg1
	MV_PAR22 := _Exec[22]	// Msg2
endif

// Brando
_cQry := ""
_cQry += " SELECT DISTINCT"
_cQry += "    (SELECT "
_cQry += "       SUM(E1_VLCRUZ) "		//ISNULL(SUM(E1_VLCRUZ),0)
_cQry += "     FROM "
_cQry += "          "+RetSqlName("SE1")
_cQry += "     WHERE "
_cQry += "           D_E_L_E_T_ = ' ' "
_cQry += "       AND LTRIM(RTRIM(E1_TIPO)) = 'NCC'  "
_cQry += "       AND E1_CLIENTE = SE1.E1_CLIENTE  "
_cQry += "       AND E1_LOJA    = SE1.E1_LOJA "
_cQry += "     ) E1_NCC "
_cQry += "   ,(SELECT  "
_cQry += "       SUM(E1_VLCRUZ) "	// ISNULL(SUM(E1_VLCRUZ),0)
_cQry += "     FROM "
_cQry += "          "+RetSqlName("SE1")
_cQry += "     WHERE "
_cQry += "           D_E_L_E_T_ = ' ' "
_cQry += "       AND LTRIM(RTRIM(E1_TIPO)) = 'RA'  "
_cQry += "       AND E1_CLIENTE = SE1.E1_CLIENTE "
_cQry += "       AND E1_LOJA    = SE1.E1_LOJA "
_cQry += "     ) E1_RA "
_cQry += "   ,SE1.E1_TIPO "
_cQry += "   ,F2_CARGA E1_CARGA "
_cQry += "   ,E1_NUMBOR   "
_cQry += "   ,E1_PREFIXO   "
_cQry += "   ,E1_NUM "
_cQry += "   ,E1_PARCELA "
_cQry += "   ,E1_TIPO "
_cQry += "   ,E1_NATUREZ  "
_cQry += "   ,E1_PORTADO  "
_cQry += "   ,E1_CLIENTE "
_cQry += "   ,A1_NOME E1_NOME"
_cQry += "   ,E1_LOJA  "
_cQry += "   ,E1_EMISSAO "
_cQry += "   ,E1_VENCTO  "
_cQry += "   ,E1_VENCREA "
_cQry += "   ,E1_VLCRUZ  "
_cQry += "   ,E1_FILIAL  "
_cQry += "   ,E1_VEND1 "
_cQry += "   ,E1_SALDO "
_cQry += "   ,E1_HIST "
_cQry += "   ,E1_SDDECRE "
_cQry += "   ,E1_DESCFIN "
_cQry += " FROM "
_cQry += "    "+RetSqlName("SE1")+" SE1 "

// Nota fiscal de saida
_cQry += "    LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 "
_cQry += "    ON    SE1.E1_FILIAL  = SF2.F2_FILIAL "
_cQry += "      AND SE1.E1_NUM     = SF2.F2_DOC  "
_cQry += "      AND SE1.E1_PREFIXO = SF2.F2_SERIE "
_cQry += "      AND SE1.E1_CLIENTE = SF2.F2_CLIENTE "
_cQry += "      AND SE1.E1_LOJA    = SF2.F2_LOJA "
_cQry += "      AND SF2.D_E_L_E_T_ = ' ' "

// Bordero - Brando 02/10/2009
// Foi relacionado a tabela de bordero para buscar os titulos cuja a emissao
_cQry += "    LEFT OUTER JOIN "+RetSqlName("SEA")+" SEA "
_cQry += "    ON    SE1.E1_FILIAL  = SEA.EA_FILIAL "
_cQry += "      AND SE1.E1_NUM     = SEA.EA_NUM  "
_cQry += "      AND SE1.E1_PREFIXO = SEA.EA_PREFIXO "
_cQry += "      AND SE1.E1_PARCELA = SEA.EA_PARCELA "
// Fim Brando 02/10/2009

_cQry += "   ,"+RetSqlName("SA1")+" SA1 "
_cQry += " WHERE "
_cQry += 	"     SE1.D_E_L_E_T_ = ' ' "
_cQry += 	" AND SA1.A1_COD     = SE1.E1_CLIENTE "
_cQry += 	" AND SA1.A1_LOJA    = SE1.E1_LOJA "
_cQry += 	" AND LTRIM(RTRIM(SE1.E1_TIPO))  NOT IN ('NCC','RA','TX')  "
_cQry += 	" AND E1_FILIAL           = '"+xFilial("SE1") + "'
_cQry += 	" AND E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
_cQry += 	" AND E1_NUM     BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
_cQry += 	" AND E1_PARCELA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
//_cQry += 	" AND E1_PORTADO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
_cQry += 	" AND E1_CLIENTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
_cQry += 	" AND E1_LOJA    BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "

IF !Empty( AllTrim(MV_PAR19) )
	_cQry += " AND SF2.F2_CARGA BETWEEN '" + MV_PAR19+ "' AND '"+ MV_PAR20 + "' "
ENDIF

IF !Empty(MV_PAR17)
	_cQry += 	"   AND E1_NUMBOR BETWEEN '" + MV_PAR17 + "' AND '" + MV_PAR18 + "' "
ENDIF

if (MV_PAR13 <> CTOD("  /  /    ")) .AND. (MV_PAR14 <> CTOD("  /  /    "))
	_cQry += " AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR13)+"' AND '"+DTOS(MV_PAR14)+"' "
endif

if (MV_PAR15 <> CTOD("  /  /    ")) .AND. (MV_PAR16 <> CTOD("  /  /    "))
	_cQry += " AND E1_VENCREA BETWEEN '"+DTOS(MV_PAR15)+"' AND '"+DTOS(MV_PAR16)+"' "
endif

//_cQry += " AND E1_SALDO > 0 "
_cQry += " AND E1_SALDO > 0 AND E1_TIPO NOT IN ('CF-','CS-','IN-','IR-','PI-','IS-') "
_cQry += " ORDER BY E1_PREFIXO,E1_NUM,E1_PARCELA "

//Aviso( "MSG BOLETO", EncodeUTF8(_cQry), {"Ok"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?brir a Query ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {}
aadd(aCampos,{ "E1_OK"		   	,"C",02,0 })
aadd(aCampos,{ "E1_EMISSAO" 	,"D",08,0 })
aadd(aCampos,{ "E1_PREFIXO"		,"C",len(SE1->E1_PREFIXO),0})
aadd(aCampos,{ "E1_NUM"			,"C",len(SE1->E1_NUM),0 })
aadd(aCampos,{ "E1_PARCELA"		,"C",len(SE1->E1_PARCELA),0 })
aadd(aCampos,{ "E1_CLIENTE"		,"C",len(SE1->E1_CLIENTE),0 })
aadd(aCampos,{ "E1_LOJA"  		,"C",len(SE1->E1_LOJA),0 })
aadd(aCampos,{ "E1_NOME"		,"C",40,0 })
aadd(aCampos,{ "E1_VENCTO" 		,"D",08,0 })
aadd(aCampos,{ "E1_VENCREA"		,"D",08,0 })
aadd(aCampos,{ "E1_VLCRUZ"		,"N",15,2 })
aadd(aCampos,{ "E1_SALDO"		,"N",15,2 })
aadd(aCampos,{ "E1_NCC"	      	,"N",10,2 })//JSS - ALTERADO O TAMANHO DE 8 PARA 10 PARA SOLUÇÃO DO CHAMADO 031471
aadd(aCampos,{ "E1_RA"	      	,"N",10,2 })//JSS - ALTERADO O TAMANHO DE 8 PARA 10 PARA SOLUÇÃO DO CHAMADO 031471
aadd(aCampos,{ "E1_CARGA"		,"C",06,0})
aadd(aCampos,{ "E1_NUMBOR"		,"C",06,0})
aadd(aCampos,{ "E1_TIPO"		,"C",03,0})
aadd(aCampos,{ "E1_NATUREZ"		,"C",10,0 })
aadd(aCampos,{ "E1_PORTADO"		,"C",03,0})
aadd(aCampos,{ "E1_FILIAL"	   	,"C",03,0 })
aadd(aCampos,{ "E1_VEND1"	   	,"C",06,0 })
aadd(aCampos,{ "E1_DESCFIN"		,"N",08,5 })

cArqSE1  := CriaTrab(aCampos, .T.)
cNtxSE1  := CriaTrab(nil,.f.)
dbUseArea(.T.,__LocalDriver,cArqSE1,"TSE1",.F.)

Processa({|| SqlToTrb(_cQry, aCampos, "TSE1")}) // Cria arquivo temporario
INDEX ON E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO TO &cNtxSE1

cMarca:=GetMark()
cMarca:=soma1(cMarca)

aStruSE1	:= {		{"E1_OK" 				,""			,02,0},;
{"E1_EMISSAO" 	,"Dt. Emiss?"		,08,0},;//	,"@D 99/99/9999"},;
{"E1_PREFIXO" 	,"Prefixo"	, len(SE1->E1_PREFIXO),0},;
{"E1_NUM" 		,"Titulo"	,len(SE1->E1_NUM),0},;
{"E1_PARCELA" 	,"Parcela"	,len(SE1->E1_PARCELA),0},;
{"E1_CLIENTE" 	,"Cliente"	,len(SE1->E1_CLIENTE),0},;
{"E1_LOJA" 		,"Loja"		,len(SE1->E1_LOJA),0},;
{"E1_NOME" 		,"Nome"		,40,0},;
{"E1_VENCTO" 	,"Dt. Vencto"		,08,0},;//	,"@D 99/99/9999"},;
{"E1_VENCREA"	,"Dt. Vencto Real"	,08,0},;
{"E1_VLCRUZ"	,"Valor"	,"@E 999,999.99"},;
{"E1_RA" 		,"RA"		,"@E 999,999.99"},;
{"E1_NCC" 		,"NCC"		,"@E 999,999.99"},;
{"E1_TIPO" 		,"Tipo"		,03,0},;
{"E1_CARGA" 	,"Carga"	,06,0},;
{"E1_NUMBOR" 	,"Bordero"	,06,0},;
{"E1_NATUREZ" 	,"Natureza"	,10,0},;
{"E1_VEND1" 	,"Vendedor"	,06,0},;
{"E1_PORTADO" 	,"Portado"	,03,0} }

TSE1->( dbGotop() )

if !_MsExec
	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
	@ 001,001 TO 170,350 BROWSE "TSE1" FIELDS aStruSE1 MARK "E1_OK"  Object oBrowIncPed
	
	oBtn1 := tButton():New(180,050,"Desmarca Todos   " ,oDlg,{|| u_fMarTudo(cMarca,.t.)},060,015,,,,.T.)
	oBtn2 := tButton():New(180,110,"Marca Todos      " ,oDlg,{|| u_fMarTudo(cMarca,.f.)},060,015,,,,.T.)
	oBtn3 := tButton():New(180,170,"Inverte Seleção  " ,oDlg,{|| u_fMarTudo(cMarca,nil)},060,015,,,,.T.)
	oBtn4 := tButton():New(180,230,"Imprimir Boletos " ,oDlg,{|| lExec := .T.,MontaRel(),Close(oDlg)},060,015,,,,.T.)
	oBtn4 := tButton():New(180,290,"    Cancelar     " ,oDlg,{|| lExec := .F.,Close(oDlg)},060,015,,,,.T.)
	
	ACTIVATE DIALOG oDlg CENTERED
	
else
	lExec := .T.
	u_fMarTudo(cMarca,.F.)
	MontaRel(_cDef2Printer)
	
endif

TSE1->( dbCloseArea() )
fErase(cArqSE1 + ".DBF")
fErase(cNtxSE1 + ordBagExt())
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?rograma  ? fMarTudo?Autor ?Brando                ?Data ?19/07/07 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS		      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
/*/
User Function fMarTudo(cMarca, ltudo)
Local aArea := TSE1->(GetArea())

TSE1->( dbGoTop() )

While !TSE1->( Eof() )
	
	RecLock("TSE1",.F.)
	if lTudo        // Marca todos os Itens
		TSE1->E1_OK := cMarca
		
	elseIf !lTudo   // Desmarca todos os itens
		TSE1->E1_OK := "  "
		
	else                   // Inverte a Seleção
		
		if TSE1->E1_OK == cMarca
			TSE1->E1_OK := "  "
		else
			TSE1->E1_OK := cMarca
		endif
		
	endIf
	
	TSE1->( MsUnLock() )
	TSE1->( dbSkip() )
	
Enddo

RestArea(aArea)
if !_MsExec
	oDlg:Refresh()
endif
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?rograma  ? MontaRel?Autor ?Brando                ?Data ?19/07/07 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS		      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function MontaRel(_cDef2Printer)
RptStatus({|lEnd| ImpDet(_cDef2Printer) },"Processando Impress? Boletos...") //"Processando"
Return


Static Function ImpDet(_cDef2Printer)
LOCAL oPrint
LOCAL nX      := 0
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
SM0->M0_ENDCOB                                     ,; //[2]Endere?
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+              ; //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText     := {SuperGetMv("MV_MENBOL1",,"  ")   ,;    // Primeiro texto para comentario
SuperGetMv("MV_MENBOL2",,"  ")   ,;    // Segundo texto para comentario
SuperGetMv("MV_MENBOL3",,"  ")   ,;
" ",;
" " }    // Terceiro texto para comentario

LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat	   := 0
LOCAL cNosso       := ""
LOCAL _aVlrNF	   := {}
LOCAL cFilePrint   := ""

Private _cConvenio := ""
Private _cCarteira := ""

Private cString  := "SE1"
Private wnrel    := "BOLETO BANCARIO"
//Private cPerg     :="BOLETOBB  "
Private titulo   := "Impressao de Boleto com Codigo de Barras"
Private cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
Private cDesc2   := ""
Private cDesc3   := ""
Private Tamanho  := "G"

Private aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private nLastKey := 0

//oPrint:= TMSPrinter():New( "Boleto Bancario Laser" )

cFilePrint := "BOLETO"+ cFilAnt + Str( Year( date() ),4) + StrZero( Month( date() ), 2) +;
StrZero( Day( date() ),2) + Left(Time(),2) + Substr(Time(),4,2) + Right(Time(),2)

oPrint := FWMSPrinter():New(cFilePrint /*1-Arq. Spool*/, /*2-Spool/PDF*/, .T. /*3-Legado*/,;
/*4-Dir. Salvar*/, !Type("_cDef2Printer")=="U" /*5-N? Exibe Setup*/, /*6-Classe TReport*/,;
/*7-oPrintSetup*/, iif(Type("_cDef2Printer")=="U","",_cDef2Printer) /*8-Impressora For?da*/ )

oPrint:SetPortrait()
oPrint:SetPaperSize(9) // A4

If nLastKey == 27
	Set Filter to
	Return
Endif

TSE1->( dbGoTop() )
SetRegua( TSE1->( LastRec() ) )


while !TSE1->( Eof() )
	
	IncRegua()
	
	If TSE1->E1_OK = '  '
		
		SE1->( DbSetOrder(2), DbSeek( xFilial("SE1") + TSE1->E1_CLIENTE + TSE1->E1_LOJA + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA + TSE1->E1_TIPO ) )
		cNroDoc    :=  ""
		
		if !NrBordero()
			Set Filter to
			Aviso("ATENÇÃO","O banco "+SEE->EE_CODIGO+" nº esta configurado para Impress? Boleto Laser",{"OK"})
			Return
		endif
		
		//Posiciona na Tabela do bordero.
		SEA->( DBSetOrder(1) )
		if !SEA->( DBSeek( xFilial("SEA") + SE1->E1_NUMBOR + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA + TSE1->E1_TIPO ) )
			Alert("Titulo nao localizado no bordero selecionado. Pref. "+Alltrim(TSE1->E1_PREFIXO)+" Tit. "+Alltrim(TSE1->E1_NUM))
			Return
		endif
		
		//Posiciona na Arq de Parametros CNAB
		SEE->( DbSetOrder(1) )
		if !SEE->( DbSeek(xFilial("SEE")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)+"001",.T.) )
			alert("Erro na leitura dos parametros do banco do bordero gerado (Sub-conta diferente de 001),")
			return
		EndIf
		
		//Posiciona o SA6 (Bancos)
		SA6->( DbSetOrder(1) )
		if !SA6->( DbSeek(xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON) ,.T.) )
			Alert("Banco do bordero ("+Alltrim(SEA->EA_PORTADO)+" - "+Alltrim(SEA->EA_AGEDEP)+" - "+Alltrim(SEA->EA_NUMCON)+") nao localizado no cadastro de Bancos.")
			Return
		endif
		
		if Empty(SEE->EE_CODEMP)
			alert("Informar o convenio do banco no cadastro de parametros do banco (EE_CODEMP) !")
			return nil
		endif
		
		if Empty(SEE->EE_TABELA)
			alert("Informar a tabela do banco no cadastro de parametros do banco (EE_TABELA) !")
			return nil
		endif
		
		_cConvenio := AllTrim(SEE->EE_CODEMP) // Tamanho de 7.
		_cCarteira := Alltrim(SEE->EE_CODCART)
		
		//Posiciona o SA1 (Cliente)
		SA1->( DbSetOrder(1) )
		SA1->( DbSeek(xFilial("SA1")+TSE1->E1_CLIENTE+TSE1->E1_LOJA,.T.) )
		
		If SEE->EE_CODIGO == '001'  // Banco do Brasil
			aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
			"BANCO BRASIL"     ,; // [2]Nome do Banco
			Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Ag?cia
			Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
			Alltrim(SEE->EE_DVCTA),; 	// [5]D?ito da conta corrente
			_cCarteira ,; // [6]Codigo da Carteira
			"9" ,; // [7] Digito do Banco
			"ATÉ O VENCIMENTO, PREFERENCIALMENTE EM TODA REDE BANCO DO BRASIL" ,; // [8] Local de Pagamento1
			"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO BANCO DO BRASIL",; // [9] Local de Pagamento2
			SEE->EE_DVAGE,; 	//[10] Digito Verificador da agencia
			_cConvenio,;     //[11] C?igo Cedente fornecido pelo Banco
			iif( SEE->(FieldPos("EE_XCODEMP"))>0,SEE->EE_XCODEMP, SEE->EE_CODEMP) }	//[12] C?igo Cedente fornecido pelo Banco
			
		ElseIf SEE->EE_CODIGO == '341'  // Itau
			aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
			"Banco Itaú S.A."     ,; // [2]Nome do Banco
			Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Ag?cia
			Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
			Alltrim(SEE->EE_DVCTA),; 	// [5]D?ito da conta corrente
			_cCarteira ,; // [6]Codigo da Carteira
			"7" ,; // [7] Digito do Banco
			"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ" ,; // [8] Local de Pagamento1
			"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO ITAÚ",; // [9] Local de Pagamento2
			SEE->EE_DVAGE,;//[10] Digito Verificador da agencia
			_cConvenio}	//[11] C?igo Cedente fornecido pelo Banco
			
		ElseIf SEE->EE_CODIGO == '237'  // Bradesco
			aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
			"BRADESCO S.A."     ,; // [2]Nome do Banco
			Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Ag?cia
			Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
			Alltrim(SEE->EE_DVCTA),; 	// [5]D?ito da conta corrente
			_cCarteira ,; // [6]Codigo da Carteira
			"2" ,; // [7] Digito do Banco
			"ATÉ O VENCIMENTO, PREFERENCIALMENTE NAS AGÊNCIAS BRADESCO" ,; // [8] Local de Pagamento1
			"APÓS O VENCIMENTO, NAS AGÊNCIAS DO BRADESCO",; // [9] Local de Pagamento2
			SEE->EE_DVAGE,;	//[10] Digito Verificador da agencia
			_cConvenio}	//[11] C?igo Cedente fornecido pelo Banco
			
		ElseIf SEE->EE_CODIGO == '033'  				// Santander
			aDadosBanco  := {SEE->EE_CODIGO          	,;	// [1]Numero do Banco
			"SANTANDER S.A."     		,; // [2]Nome do Banco
			AllTrim(SEE->EE_AGENCIA)   ,;	// [3]Ag?cia
			Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
			Alltrim(SEE->EE_DVCTA),; 	// [5]D?ito da conta corrente ( e para ser vazio )
			_cCarteira ,; // [6]Codigo da Carteira
			"2" ,; // [7] Digito do Banco
			"ATÉ O VENCIMENTO, PREFERENCIALMENTE NAS AGÊNCIAS SANTANDER" ,; // [8] Local de Pagamento1
			"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO SANTANDER",; // [9] Local de Pagamento2
			SEE->EE_DVAGE,;	//[10] Digito Verificador da agencia
			_cConvenio}	//[11] C?igo Cedente fornecido pelo Banco
			
		ElseIf SEE->EE_CODIGO == '756'  // Banco Sicoob
			aDadosBanco  := {SEE->EE_CODIGO          ,;		// [1]Numero do Banco
			"SICOOB"     ,; 				// [2]Nome do Banco
			AllTrim(SubStr(SEE->EE_AGENCIA,1,4)) ,;	// [3]Ag?cia
			AllTrim(SEE->EE_CONTA),; 		// [4]Conta Corrente -2
			AllTrim(SEE->EE_DVCTA),; 		// [5]D?ito da conta corrente
			_cCarteira ,; 					// [6]Codigo da Carteira
			"0" ,; 						// [7] Digito do Banco
			"Pagavel em qualquer banco até a data de vencimento." ,; // [8] Local de Pagamento1
			"",; // [9] Local de Pagamento2
			"",; 	//[10] Digito Verificador da agencia
			_cConvenio}	//[11] C?igo Cedente fornecido pelo Banco
		Endif
		
		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Raz? Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]C?igo
			AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endere?
			AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
			SA1->A1_EST                                      ,;     	// [5]Estado
			SA1->A1_CEP                                      ,;      	// [6]CEP
			SA1->A1_CGC										 ,;  		// [7]CGC
			SA1->A1_PESSOA									  }     	// [8]PESSOA
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Raz? Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]C?igo
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endere?
			AllTrim(SA1->A1_MUN )	                            ,;   	// [4]Cidade
			SA1->A1_ESTC	                                    ,;   	// [5]Estado
			SA1->A1_CEPC                                        ,;   	// [6]CEP
			SA1->A1_CGC											,;		// [7]CGC
			SA1->A1_PESSOA										 }		// [8]PESSOA
		Endif
		
		nVlrAbat   :=  SomaAbat(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,"R",1,,TSE1->E1_CLIENTE,TSE1->E1_LOJA)
		
		//
		// Incrementa sequencia do nosso numero no parametro banco
		//
		cDigNosso := " "
		_cont     := 0
		
		DbSelectArea("SE1")
		SE1->( DBSetOrder(1) )
		If SE1->( DBSeek(XFILIAL("SE1")+TSE1->E1_PREFIXO+TSE1->E1_NUM+TSE1->E1_PARCELA+TSE1->E1_TIPO) )
			If !Empty(SE1->E1_NUMBCO)
				cNroDoc 	:= SubStr(Alltrim(SE1->E1_NUMBCO),1, Len(Alltrim(SE1->E1_NUMBCO))-1)
				//cDigNosso 	:= SE1->E1_XDVNNUM
				_cont:=1
			Endif
		EndIf
		
		If !Empty(cNroDoc)
			If SEE->EE_CODIGO $ '033'	// Santander nosso nr tem o tamanho fixo 12 + digito
				cNroDoc := StrZero((Val(Alltrim(cNroDoc))),12)
				cDigNosso := Dig11Santander(@cNroDoc)
			EndIf
		Else
			
			Begin Transaction //INICIO ATHOS 19/09/2012
			
			If SEE->EE_CODIGO == '001'
				if Len( AllTrim(SEE->EE_CODEMP) ) < 7
					cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),5)
					cDigNosso := Dig11BB(AllTrim(SEE->EE_CODEMP)+cNroDoc )		//CALC_di9(SEE->EE_CODEMP+cNosso)
				elseif Len( AllTrim(SEE->EE_CODEMP) ) == 7
					cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),10)
					cDigNosso := ""	//DigitoBB(cNosso) Nao existe para este convenio
				endif
				
			elseIf SEE->EE_CODIGO == '341'
				cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),8)
				
				//
				//  IDENTIFICAR PQ RETIRARAM A CARTEIRA PARA CALCULAR O DAC
				//
				cTexto    := aDadosBanco[03] + aDadosBanco[04] + aDadosBanco[6] + cNroDoc
				//cTexto    := Alltrim(aDadosBanco[03]) + Alltrim(aDadosBanco[04]) + cNroDoc
				cDigNosso := Modu10(cTexto)
				
			elseIf SEE->EE_CODIGO == '237'
				cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),11)
				if aDadosBanco[6] == "02"
					cDigNosso := Modu11(Alltrim(aDadosBanco[6]) + cNroDoc , 7 )
				else
					cDigNosso := BradMod11(Alltrim(aDadosBanco[6]) + cNroDoc)
				endif
				
			elseIf SEE->EE_CODIGO $ '033'	// Santander nosso nr tem o tamanho fixo 12 + digito
				_cEE_FAXATU := SubStr(SEE->EE_FAXATU,1,TamSx3("EE_FAXATU")[1]-1)
				cNroDoc := StrZero((Val(Alltrim(_cEE_FAXATU))+1),TamSx3("EE_FAXATU")[1]-1)
				cDigNosso := Dig11Santander(@cNroDoc)
				
			elseIf SEE->EE_CODIGO $ '756'	// SICOOB nosso nr tem o tamanho fixo 07
				cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),7)
				cDigNosso := DigNNSicoob(cNroDoc,AllTrim(SEE->EE_CODEMP),AllTrim(SEE->EE_AGENCIA))
			Else
				cNroDoc := Replicate('9',TamSx3("EE_FAXATU")[1])
			EndIf
			
			RecLock("SE1",.F.)
			SE1->E1_NUMBCO  := cNroDoc+cDigNosso //aNossoN   // Nosso n?ero (Ver f?mula para calculo)
			//SE1->E1_XDVNNUM := cDigNosso // inclu?a para gravar digito verificador do nosso n?ero
			SE1->( MsUnlock() )
			
			// atuliza a faixa atual do parametro banco
			RecLock("SEE",.F.)
			SEE->EE_FAXATU := cNroDoc+cDigNosso
			SEE->( MsUnlock() )
			//fim
			
			End Transaction
            //AOA - 16/07/2015 - Alteração c?igo do nosso n?ero. Chamado 028052.
			If !Empty(SE1->E1_NUMBCO) .And. SEE->EE_CODIGO $ '033'
				cNroDoc 	:= SubStr(Alltrim(SE1->E1_NUMBCO),1, Len(Alltrim(SE1->E1_NUMBCO))-1)
				cNroDoc 	:= StrZero((Val(Alltrim(cNroDoc))),12)
				cDigNosso 	:= Dig11Santander(@cNroDoc)
			Endif
			
		Endif
		
		//
		//Monta codigo de barras
		//
		aCB_RN_NN    := Ret_cBarra(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,TSE1->E1_TIPO,;
		Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4] ,aDadosBanco[5],;
		cNroDoc,(TSE1->E1_SALDO - nVlrAbat)	, aDadosBanco[6] ,"9"	) // Alterado por Joao Vitor | Infinit 15/02/2016
		
		aDadosTit	:= {  	TSE1->E1_NUM + AllTrim(TSE1->E1_PARCELA)	,;  // [1] N?ero do t?ulo
		TSE1->E1_EMISSAO                         	,; 	// [2] Data da emiss? do t?ulo
		dDataBase          							,;	// [3] Data da emiss? do boleto
		TSE1->E1_VENCREA                          	,; 	// [4] Data do vencimento
		(TSE1->E1_SALDO - nVlrAbat)  				,;  // [5] Valor do t?ulo
		aCB_RN_NN[3]                       			,;  // [6] Nosso n?ero (Ver f?mula para calculo) // de 3 coloquei 9
		TSE1->E1_PREFIXO							,;  // [7] Prefixo da NF
		"DM"										,;	// [8] Tipo do Titulo
		TSE1->E1_SALDO * (TSE1->E1_DESCFIN/100)  }		// [9] Desconto financeiro
		
		
		//------------------------------------------------------------------------------------------------------------------------------
		//				TEXTO PADRAO PARA MSG NO CORPO DO BOLETO
		//------------------------------------------------------------------------------------------------------------------------------
		
		aBolText[1] := iif( Empty(aBolText[1]),"", aBolText[1])
		
		aBolText[2] := "ATENÇÃO SR. CAIXA: "
		
		if GetMV("MV_LJMULTA") > 0
			aBolText[3] := "Apó Vencimento, Multa de "+ Transform(GetMV("MV_LJMULTA"),"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform((TSE1->E1_SALDO*(GetMV("MV_LJMULTA")/100)),"@E 99,999.99"))
		endif
		
		if GetMV("MV_TXPER") > 0 .and. GetMV("MV_LJMULTA") > 0
			aBolText[4] := "Mora Diária de "+ Transform(GetMV("MV_TXPER"),"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( TSE1->E1_SALDO*GetMV("MV_TXPER") )/100),"@E 99,999.99"))+"."
			
		elseif GetMV("MV_TXPER") > 0
			aBolText[3] := "Mora Diária de "+ Transform(GetMV("MV_TXPER"),"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( TSE1->E1_SALDO*GetMV("MV_TXPER") )/100),"@E 99,999.99"))
			
		endif
		
		if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
			aBolText[5] := "Desconto concedido de R$ "+AllTrim(Transform(aDadosTit[9] ,"@E 99,999.99"))+" para pagamento até a data de vencimento."
		else
			aBolText[5] := ""
		endif
		
		//------------------------------------------------------------------------------------------------------------------------------
		
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)
		nX := nX + 1
		
	EndIf
	
	TSE1->( dbSkip() )
	IncProc()
	nI += 1
	
Enddo

oPrint:Preview()		// Visualiza antes de imprimir
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?rograma  ? Impress ?Autor ?Kesley M Martins      ?Data ?19/07/07 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?so       ?TOTVS                                                      ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,aNossoN)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)

oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)

oFont8   := TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10n := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n := TFont():New("Arial",9,12,.T.,.f.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova p?ina

/******************/
/* PRIMEIRA PARTE */
/******************/
nRow1	:= 0
nRowSay := 035

oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

oPrint:Say(nRowSay+0095,513,aDadosBanco[1]+"-"+aDadosBanco[7] ,oFont20 )	// [1]Numero do Banco   + [7] DV Banco
oPrint:Say(nRowSay+0095,100,aDadosBanco[2],oFont12 )						// [2]Nome do Banco
//oPrint:SayBitmap(nRow1+0080,100,"\BBrasil.bmp",400,075)					// Mostra Figura do Banco

oPrint:Say(nRowSay+0084,1900,"Comprovante de Entrega",oFont10n)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say(nRowSay+0150,100 ,"Cedente",oFont8)
oPrint:Say(nRowSay+0200,100 ,aDadosEmp[1],oFont10n)				//Nome + CNPJ

oPrint:Say(nRowSay+0150,1060,"Agência/Código Cedente",oFont8)
If aDadosBanco[1] == '001'
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[12]))
Else
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
EndIf

//oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]) ,oFont10n)

oPrint:Say(nRowSay+0150,1510,"Nro.Documento",oFont8)
oPrint:Say(nRowSay+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela

oPrint:Say(nRowSay+0250,100 ,"Sacado",oFont8)
oPrint:Say(nRowSay+0300,100 ,aDatSacado[1],oFont10n)				//Nome

oPrint:Say(nRowSay+0250,1060,"Vencimento",oFont8)
oPrint:Say(nRowSay+0300,1060,StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4),oFont10n)

oPrint:Say(nRowSay+0250,1510,"Valor do Documento",oFont8)
oPrint:Say(nRowSay+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10n)

oPrint:Say(nRowSay+0400,0100,"Recebi(emos) o bloqueto/t?ulo",oFont10)
oPrint:Say(nRowSay+0430,0100,"com as caracter?ticas acima.",oFont10)

oPrint:Say(nRowSay+0350,1060,"Data",oFont8)
oPrint:Say(nRowSay+0350,1410,"Assinatura",oFont8)
oPrint:Say(nRowSay+0450,1060,"Data",oFont8)
oPrint:Say(nRowSay+0450,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say(nRowSay+0165,1910,"(  )Mudou-se"               ,oFont10n)
oPrint:Say(nRowSay+0195,1910,"(  )Ausente"                ,oFont10n)
oPrint:Say(nRowSay+0225,1910,"(  )Não existe nº indicado" ,oFont10n)
oPrint:Say(nRowSay+0255,1910,"(  )Recusado"               ,oFont10n)
oPrint:Say(nRowSay+0285,1910,"(  )Não procurado"          ,oFont10n)
oPrint:Say(nRowSay+0315,1910,"(  )Endere? insuficiente"  ,oFont10n)
oPrint:Say(nRowSay+0345,1910,"(  )Desconhecido"           ,oFont10n)
oPrint:Say(nRowSay+0375,1910,"(  )Falecido"               ,oFont10n)
oPrint:Say(nRowSay+0405,1910,"(  )Outros(anotar no verso)",oFont10n)


/*****************/
/* SEGUNDA PARTE */
/*****************/
nRow2  := 000
nRowSay:= 035

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0590, nI,nRow2+0590, nI+30)
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

oPrint:Say(nRowSay+0660,518,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// [1]Numero do Banco
oPrint:Say(nRowSay+0660,100,aDadosBanco[2],oFont12 )		// [2]Nome do Banco
//oPrint:SayBitmap(nRow2+0630,100,"\BBrasil.bmp",400,075)	// Figura do Banco do Brasil
oPrint:Say(nRowSay+0644,1800,"Recibo do Sacado",oFont10n)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say(nRowSay+0710,100 ,"Local de Pagamento",oFont8)
oPrint:Say(nRowSay+0730,400 ,aDadosBanco[8] ,oFont10n)
oPrint:Say(nRowSay+0760,400 ,aDadosBanco[9] ,oFont10n)

oPrint:Say(nRowSay+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
nCol := 1855+(374-(len(cString)*22))
oPrint:Say(nRowSay+0750,nCol,cString,oFont12)

oPrint:Say(nRowSay+0810,100 ,"Cedente"                                        ,oFont8)
oPrint:Say(nRowSay+0870,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

oPrint:Say(nRowSay+0810,1810,"Agência/Cóigo Cedente",oFont8)
If aDadosBanco[1] == '001'
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[12]))
Else
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
EndIf

//cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]) )
nCol := 1860+(374-(len(cString)*22))
oPrint:Say(nRowSay+0865,nCol,cString,oFont11c)

oPrint:Say(nRowSay+0910,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say(nRowSay+0940,100, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4),oFont10n)

oPrint:Say(nRowSay+0910,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say(nRowSay+0940,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

oPrint:Say(nRowSay+0910,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say(nRowSay+0940,1050,aDadosTit[8]										,oFont10n) //Tipo do Titulo

oPrint:Say(nRowSay+0910,1305,"Aceite"                                         ,oFont8)
oPrint:Say(nRowSay+0940,1400,"N"                                             ,oFont10n)

oPrint:Say(nRowSay+0910,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say(nRowSay+0940,1550,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4),oFont10n) // Data impressao

oPrint:Say(nRowSay+0910,1810,"Nosso N?ero"                                   ,oFont8)

If aDadosBanco[1] == '001'
	cString := Substr(aDadosTit[6],1,3) + Substr(aDadosTit[6],4) + iif( Len(AllTrim(SEE->EE_CODEMP))>=7,"", "-" + SE1->E1_XDVNNUM)
else
	cString := Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)
Endif

nCol := 1850+(374-(len(cString)*22))
oPrint:Say(nRowSay+0940,nCol,cString,oFont11c)

oPrint:Say(nRowSay+0980,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say(nRowSay+0980,505 ,"Carteira"                                       ,oFont8)
oPrint:Say(nRowSay+1010,555 ,aDadosBanco[6]                                  	,oFont10n)

oPrint:Say(nRowSay+0980,755 ,"Espécie"                                        ,oFont8)
oPrint:Say(nRowSay+1010,805 ,"R$"                                             ,oFont10n)

oPrint:Say(nRowSay+0980,1005,"Quantidade"                                     ,oFont8)
oPrint:Say(nRowSay+0980,1485,"Valor"                                          ,oFont8)

oPrint:Say(nRowSay+0980,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1840+(374-(len(cString)*22))
oPrint:Say(nRowSay+1010,nCol,cString ,oFont11c)

oPrint:Say(nRowSay+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

oPrint:Say(nRowSay+1060,100 ,aBolText[1],oFont10n)
oPrint:Say(nRowSay+1090,100 ,aBolText[2],oFont10n)
oPrint:Say(nRowSay+1140,100 ,aBolText[3],oFont10n)
oPrint:Say(nRowSay+1190,100 ,aBolText[4],oFont10n)
oPrint:Say(nRowSay+1240,100 ,aBolText[5],oFont10n)

// MSG dos Parametros
if !Empty(MV_PAR21)
	oPrint:Say(nRowSay+1360,100, AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
endif

oPrint:Say(nRowSay+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say(nRowSay+1120,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say(nRowSay+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say(nRowSay+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say(nRowSay+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

if aDadosTit[9] > 0 .and. aDadosTit[4] >= dDataBase
	cString := Alltrim(Transform( aDadosTit[9],"@E 999,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say(nRowSay+1080,nCol,cString,oFont11c)
endif

oPrint:Say(nRowSay+1400,100 ,"Sacado"                                         ,oFont8)
oPrint:Say(nRowSay+1405,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
oPrint:Say(nRowSay+1445,400 ,aDatSacado[3]                                    ,oFont10n)
oPrint:Say(nRowSay+1485,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say(nRowSay+1580,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
Else
	oPrint:Say(nRowSay+1580,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
EndIf

//oPrint:Say(nRowSay+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

oPrint:Say(nRowSay+1560,100 ,"Sacador/Avalista",oFont8)
oPrint:Say(nRowSay+1640,1500,"Autenticação Mecánica",oFont8)


oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )


/******************/
/* TERCEIRA PARTE */
/******************/

nRow3   := -80

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1860, nI, nRow3+1860, nI+30)
Next nI

nRowSay := -85
nRow3   := -110

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

//oPrint:SayBitmap(nRow3+1922,100,"\BBrasil.bmp",400,075)			// [2]Nome do Banco
oPrint:Say(nRowSay+1945,100,aDadosBanco[2],oFont12 )		// 	[2]Nome do Banco
oPrint:Say(nRowSay+1945,518,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// 	[1]Numero do Banco
oPrint:Say(nRowSay+1945,755,aCB_RN_NN[2],oFont20)			//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say(nRowSay+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say(nRowSay+2020,400 ,aDadosBanco[8],oFont10n)
oPrint:Say(nRowSay+2055,400 ,aDadosBanco[9],oFont10n)

oPrint:Say(nRowSay+2000,1810,"Vencimento",oFont8)

cString := StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
nCol	 	 := 1850+(374-(len(cString)*22))
oPrint:Say(nRowSay+2045,nCol,cString,oFont12)

oPrint:Say(nRowSay+2100,100 ,"Cedente",oFont8)
oPrint:Say(nRowSay+2150,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

oPrint:Say(nRowSay+2100,1810,"Agêcia/Código Cedente",oFont8)
If aDadosBanco[1] == '001'
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[12]))
Else
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
EndIf

//cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
nCol 	 := 1830+(374-(len(cString)*22))
oPrint:Say(nRowSay+2150,nCol,cString ,oFont11c)

oPrint:Say (nRowSay+2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRowSay+2230,100, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4), oFont10n)

oPrint:Say(nRowSay+2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say(nRowSay+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

oPrint:Say(nRowSay+2200,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say(nRowSay+2230,1050,aDadosTit[8]										,oFont10n) //Tipo do Titulo

oPrint:Say(nRowSay+2200,1305,"Aceite"                                         ,oFont8)
oPrint:Say(nRowSay+2230,1400,"N"                                             ,oFont10n)

oPrint:Say(nRowSay+2200,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say(nRowSay+2230,1550,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4)                               ,oFont10n) // Data impressao

oPrint:Say(nRowSay+2200,1810,"Nosso Número"                                   ,oFont8)

If aDadosBanco[1] == '001'
	cString := Substr(aDadosTit[6],1,3) + Substr(aDadosTit[6],4) + iif( Len(AllTrim(SEE->EE_CODEMP))>=7,"", "-" + SE1->E1_XDVNNUM)
else
	cString := Alltrim(Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4))
Endif

nCol 	 := 1830+(374-(len(cString)*22))
oPrint:Say(nRowSay+2230,nCol,cString,oFont11c)

oPrint:Say(nRowSay+2270,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say(nRowSay+2270,505 ,"Carteira"                                       ,oFont8)
oPrint:Say(nRowSay+2300,555 ,aDadosBanco[6]                                  	,oFont10n)

oPrint:Say(nRowSay+2270,755 ,"Espécie"                                        ,oFont8)
oPrint:Say(nRowSay+2300,805 ,"R$"                                             ,oFont10n)

oPrint:Say(nRowSay+2270,1005,"Quantidade"                                     ,oFont8)
oPrint:Say(nRowSay+2270,1485,"Valor"                                          ,oFont8)

oPrint:Say(nRowSay+2270,1810,"Valor do Documento"                          	,oFont8)

cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1840+(374-(len(cString)*22))
oPrint:Say(nRowSay+2300,nCol,cString,oFont11c)

oPrint:Say(nRowSay+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

oPrint:Say(nRowSay+2320,100 ,aBolText[1],oFont10n)
oPrint:Say(nRowSay+2445,100 ,aBolText[2],oFont10n)
oPrint:Say(nRowSay+2495,100 ,aBolText[3],oFont10n)
oPrint:Say(nRowSay+2545,100 ,aBolText[4],oFont10n)
oPrint:Say(nRowSay+2595,100 ,aBolText[5],oFont10n)


If _cont = 1 .and. Empty(aBolText[4]+aBolText[5])
	oPrint:Say(nRowSay+2590,100 ,"/////ATENÇÃO/////--> SEGUNDA VIA",oFont10n)
EndIf

if !Empty(MV_PAR21)
	oPrint:Say(nRowSay+2640,100 ,AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
endif

oPrint:Say(nRowSay+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say(nRowSay+2410,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say(nRowSay+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say(nRowSay+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say(nRowSay+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say(nRowSay+2690,100 ,"Sacado"                                         ,oFont8)
oPrint:Say(nRowSay+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
oPrint:Say(nRowSay+2743,400 ,aDatSacado[3]                                    ,oFont10n)
oPrint:Say(nRowSay+2786,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado

if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
	cString := Alltrim(Transform(aDadosTit[9],"@E 999,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say(nRowSay+2370,nCol,cString,oFont11c)
endif

//nRow3 -= 015
oPrint:Say  (nRow3+2875,100 ,"Sacador/Avalista"                               ,oFont8)

if aDatSacado[8] = "J"
	oPrint:Say(nRowSay+2870,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
Else
	oPrint:Say(nRowSay+2870,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
EndIf

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )
oPrint:Line (nRow3+2920,100,nRow3+2920,2300  )

oPrint:Say(nRowSay+2915,1680,"Autenticação Mecânica - Ficha de Compensação"   ,oFont8)

// FWMsBar(cTypeBar, nRow, nCol, cCode,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)-->
oPrint:FwMsBar("INT25" /*cTypeBar*/, 66 /*nRow*/, 2.40 /*nCol*/,;
aCB_RN_NN[1] /*cCode*/, oPrint, .F. /*Calc6. Digito Verif*/,;
/*Color*/, /*Imp. na Horz*/, 0.025 /*Tamanho*/, 0.85 /*Altura*/, , , ,.F. )

oPrint:EndPage() // Finaliza a p?ina
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?uncao    ?etDados  ?utor  ?icrosiga           ?Data ? 02/13/04   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?esc.     ?Gera o codigo de barras.        					          º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?so       ?BOLETOS                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
cBanco		,cAgencia	,cConta		,cDacCC	,;
cNroDoc		,nValor		,cCart		,cMoeda	)

Local cNosso		:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local cTexto        := ""
Local aRet			:= {}

//DEFAULT nValor := 0
cAgencia   := StrZero(Val(cAgencia),4)
cNosso     := ""


If cBanco == '001' .and. len( AllTrim(_cConvenio) ) == 6 	// Banco do Brasil
	//
	// CONVENIO 6 POSICOES
	//
	
	cConta	   := StrZero( val(cConta),8)
	cNosso     := _cConvenio + cNroDoc
	cDigNosso  := CALC_di9(cNosso)
	cCart      := cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo livre
	cCampoL    := _cConvenio + cNroDoc + cAgencia + cConta + cCart
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + Substr(_cConvenio,1,5)
	cDig1    := DIGIT001( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := SUBSTR(cCampoL,6,10)	//cNroDoc + cAgencia
	cDig2    := DIGIT001( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT001( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
	
elseif cBanco == '001' .and. len( AllTrim(_cConvenio) ) == 7
	//
	// CONVENIO 7 POSICOES
	//
	
	cNosso     := StrZero(Val(_cConvenio),7)+StrZero(Val(cNroDoc),10)
	cDigNosso  := ""	//CALC_di9(cNosso) - Nao existe para este convenio
	cCart      := cCart
	
	// campo livre
	cCampoL    := StrZero(Val(_cConvenio),13)+strzero(Val(cNroDoc),10)+cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Strzero(val(Substr(cBarra,4,1)),6)
	cDig1    := DIGIT001( cParte1 )
	
	cParte2  := SUBSTR(cCampoL,6,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
	cDig2    := DIGIT001( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT001( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '341' // Itau
	
	If cCart $ '126/131/146/150/168'
		cTexto := cCart + cNroDoc
	Else
		cTexto := cAgencia + cConta + cCart + cNroDoc
	EndIf
	
	cTexto2 := cAgencia + cConta
	
	cDigCC  := Modu10(cTexto2)
	
	cNosso    := cCart + '/' + cNroDoc + '-' + cDigNosso
	cCart     := cCart
	
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	cValor:= StrZero(nValor * 100, 10)
	
	/* Calculo do codigo de barras */
	cCdBarra:= cBanco + cMoeda + cFatorValor + cCart + cNroDoc + cDigNosso +;
	cAgencia + cConta + cDigCC + "000"
	
	cDigCdBarra:= Modu11(cCdBarra,9)
	
	cCdBarra := Left(cCdBarra,4) + cDigCdBarra + Substr(cCdBarra,5,40)
	
	/* Calculo da representacao numerica */
	//	cCampo1:= "341" + "9" + cCart + Substr(cNosso, 5, 2)
	//	cCampo2:= Substr(cNosso, 7, 6) + Substr(cNosso, 14, 1) + Substr(cAgencia, 1, 3)
	//	cCampo3:= Substr(cAgencia, 4, 1) + cConta + cDacCC + "000"
	cCampo1:= cBanco+cMoeda+Substr(cCdBarra,20,5)
	cCampo2:= Substr(cCdBarra,25,10)
	cCampo3:= Substr(cCdBarra,35,10)
	
	cCampo4:= Substr(cCdBarra, 5, 1)
	cCampo5:= cFatorValor
	
	/* Calculando os DACs dos campos 1, 2 e 3 */
	cCampo1:= cCampo1 + Modu10(cCampo1)
	cCampo2:= cCampo2 + Modu10(cCampo2)
	cCampo3:= cCampo3 + Modu10(cCampo3)
	
	cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
	cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
	cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
	cRepNum += cCampo4 + "  "
	cRepNum += cCampo5
	
	Aadd(aRet,cCdBarra)
	Aadd(aRet,cRepNum)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '237' // Bradesco
	cNosso     := cCart + '/' + cNroDoc + '-' + cDigNosso
	
	// campo livre
	cCampoL    := cAgencia+cCart+cNroDoc+StrZero(Val(cConta),7)+'0'
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Substr(cBarra,20,5)
	cDig1    :=  Modu10( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := SUBSTR(cBarra,25,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
	cDig2    :=  Modu10( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cBarra,35,10)
	cDig3    :=  Modu10( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '033' 	// Santander
	cNosso    := cNroDoc + '-' + cDigNosso
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	cBarra := cBanco 										//Codigo do banco na camara de compensacao
	cBarra += cMoeda  										//Codigo da Moeda
	cBarra += Fator()						  	    		//Fator Vencimento
	cBarra += strzero(nValor*100,10)						//Strzero(Round(SE1->E1_SALDO,2)*100,10)		//Valor (ALTERADO PARA PEGAR O SALDO DO TITULO E N? O VALOR)
	cBarra += "9"                                           //Sistema - Fixo
	cBarra += _cConvenio									//C?igo Cedente
	cBarra += cNroDoc + cDigNosso							//Nosso numero
	cBarra += "0"											//IOS
	cBarra += _cCarteira					     			//Tipo de Cobran?
	
	cDigBarra := Modu11(cBarra)								//DAC codigo de barras
	
	cBarra := SubStr(cBarra,1,4) + cDigBarra + SubStr(cBarra,5,39)
	
	
	// composicao da linha digitavel  1 PARTE DE 1
	cParte1 := cBanco 		 				     	//Codigo do banco na camara de compensacao
	cParte1 += cMoeda								//Cod. Moeda
	cParte1 += "9"									//Fixo "9" conforme manual Santander
	cParte1 += Substr(_cConvenio,1,4)				//C?igo do Cedente (Posição 1 a 4)
	
	cDig1 := Substr(cParte1,1,9)                  //Pega variavel sem o '.'
	
	cParte1 += Modu10(cDig1)				  	    //Digito verificador do campo
	
	
	// composicao da linha digitavel 1 PARTE DE 2
	cParte2 := Substr(_cConvenio,5,3)			//C?igo do Cedente (Posição 5 a 7)
	cParte2 += Substr(cNroDoc + cDigNosso,1,7)			//Nosso Numero (Posição 1 a 7)
	
	cDig2 := Substr(cParte2,1,10)					//Pega variavel sem o '.'
	
	cParte2 += Modu10(cDig2)					    //Digito verificador do campo
	
	
	// composicao da linha digitavel 2 PARTE DE 1
	cParte3 := SubStr(cNroDoc + cDigNosso,8,6)  		//Nosso Numero (Posição 8 a 13)
	cParte3 +="0"									//IOS (Fixo "0")
	cParte3 +=_cCarteira							//Tipo Cobran? (101-Cobran? Simples R?ida Com Registro)
	
	cDig3 := Substr(cParte3,1,10) 			        //Pega variavel sem o '.'
	
	cParte3 += Modu10(cDig3)				     	//Digito verificador do campo
	
	
	// composicao da linha digitavel 4 PARTE
	cParte4 := SubStr(cBarra,5,1)				//Digito Verificador do C?igo de Barras
	
	
	// composicao da linha digitavel 5 PARTE
	cParte5 := Fator()							//Fator de vencimento
	cParte5 += strzero(nValor*100,10)			//Valor do titulo (Saldo no E1)
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+cParte5
	
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
	
ElseIf cBanco == '756' // Sicoob
	
	cConta	   := StrZero( val(cConta),8)
	cNosso    := cNroDoc + '-' + cDigNosso
	cCart      := cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo livre
	cCampoL    := Left(cCart,1) + cAgencia + Right(cCart,2) + StrZero( Val(_cConvenio),7) + cNroDoc + cDigNosso + StrZero( Val(se1->e1_parcela),3)
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := SubStr(cLivre,1,4) + cDigBarra + SubStr(cLivre,5,39)
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + Left(cCart,1) + cAgencia
	cDig1    := DIGIT001( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := Right(cCart,2) + StrZero( Val(see->ee_codemp), 7) +	Left(cNroDoc,1)
	cDig2    := DIGIT001( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := Right(cNroDoc,6) + cDigNosso + StrZero( Val(se1->e1_parcela),3)
	cDig3    := DIGIT001( cParte3 )		//DigitoLinhaDigitavel(cParte3)	//
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
	
EndIf

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?uncao    ?ALC_di9  ?utor  ?icrosiga           ?Data ? 02/13/04   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?esc.     ?ara calculo do nosso numero do banco do brasil             º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?so       ?BOLETOS                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function CALC_di9(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?rograma  ?Modulo11 ?Autor ?RAIMUNDO PEREIRA      ?Data ?01/08/02 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?so       ?Especifico para Clientes Microsiga                         ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/

Static Function Modulo11(cData)
Local L, D, P := 0

L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End

If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return(D)




/******************************************************************************************************************/
//CONVENIO COM 6 POSICOES BB
/******************************************************************************************************************/
Static Function Dig11BB(cData)
Local Auxi := 0, sumdig := 0

cbase  := cData
lbase  := LEN(cBase)
base   := 9	//7
sumdig := 0
Auxi   := 0
iDig   := lBase

while iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
endDo

auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf

Return(auxi)








/******************************************************************************************************************/
Static Function DigitoBB(cData)
Local Auxi := 0, sumdig := 0
cbase  := cData
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf

Return(auxi)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?uncao    ?IGIT001  ?utor  ?icrosiga           ?Data ? 02/13/04   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?esc.     ?ara calculo da linha digitavel do Banco do Brasil          º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?so       ?BOLETOS                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function DIGIT001(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))

if sumdig == 9
	nDezena := VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12)))
else
	nDezena := VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
endif

auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf
Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?uncao    ?ATOR		?utor  ?icrosiga           ?Data ? 02/13/04   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?esc.     ?alculo do FATOR  de vencimento para linha digitavel.       º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?so       ?BOLETOS                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static function Fator()
If Len( ALLTRIM( SUBSTR( dtos(TSE1->E1_VENCREA),7,4) ) ) = 4
	cData := SUBSTR( dtos(TSE1->E1_VENCREA),7,4)+SUBSTR( dtos(TSE1->E1_VENCREA),4,2)+SUBSTR( dtos(TSE1->E1_VENCREA),1,2)
Else
	cData := "20"+SUBSTR( dtos(TSE1->E1_VENCREA),7,2)+SUBSTR( dtos(TSE1->E1_VENCREA),4,2)+SUBSTR( dtos(TSE1->E1_VENCREA),1,2)
EndIf

cFator := STR(1000+(TSE1->E1_VENCREA-STOD("20000703")),4)
Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?uncao    ?ALC_5p   ?utor  ?icrosiga           ?Data ? 02/13/04   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?esc.     ?alculo do digito do nosso numero do                        º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?so       ?BOLETOS                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function CALC_5p(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf
Return(str(auxi,1,0))


/******************************************************************************************************************/
/******************************************************************************************************************/
Static Function CdBarra_Itau()
/******************************************************************************************************************/
Local cDigCdBarra
Local cFatVencto:= ""
Local cValor
Local nValor
Local cCampo1:= ""
Local cCampo2:= ""
Local cCampo3:= ""
Local cCampo4:= ""
Local cCampo5:= ""

cFatVencto:= StrZero(FatVencto(SEE->EE_CODIGO), 4)
nValor:= Valliq()
cValor:= StrZero(nValor * 100, 10)

/* Calculo do codigo de barras */
cCdBarra:= SEE->EE_CODIGO + "9" + cFatVencto + cValor + cCartEmp + Substr(cNossoNum, 5, 8) + Substr(cNossoNum, 14, 1) +;
cAgeEmp + cCtaEmp + cDigEmp + "000"

cDigCdBarra:= Modu11(cCdBarra,9)

cCdBarra:= SEE->EE_CODIGO + "9" + cDigCdBarra + StrZero(FatVencto(SEE->EE_CODIGO), 4) + StrZero(Int(nValor * 100), 10) + cCartEmp + ;
Substr(cNossoNum, 5, 8) + Substr(cNossoNum, 14, 1) + cAgeEmp + cCtaEmp + cDigEmp + "000"

/* Calculo da representacao numerica */
cCampo1:= "341" + "9" + cCartEmp + Substr(cNossoNum, 5, 2)
cCampo2:= Substr(cNossoNum, 7, 6) + Substr(cNossoNum, 14, 1) + Substr(cAgeEmp, 1, 3)
cCampo3:= Substr(cAgeEmp, 4, 1) + cCtaEmp + cDigEmp + "000"
cCampo4:= Substr(cCdBarra, 5, 1)
cCampo5:= cFatVencto + cValor

/* Calculando os DACs dos campos 1, 2 e 3 */
cCampo1:= cCampo1 + Modu10(cCampo1)
cCampo2:= cCampo2 + Modu10(cCampo2)
cCampo3:= cCampo3 + Modu10(cCampo3)

cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
cRepNum += cCampo4 + "  "
cRepNum += cCampo5
Return







/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?un‡„o    ?JUSTASX1 ?Autor ?Carlos F. Martins  ?Data ? 19/06/09   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?escri‡„o ?Funcao auxiliar chamada para criar os parametros do        º±?
±±?         ?relatorio na tabela de parametros.                         º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?so       ?Programa principal                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/

Static Function ajustasx1()

U_PUTSX1(cPerg,"01","De Prefixo"      ,"De Prefixo"      ,"De Prefixo"      ,"mv_ch1","C",03,0,0,"G","","","","","MV_PAR01","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"02","Ate Prefixo"     ,"Ate Prefixo"     ,"Ate Prefixo"     ,"mv_ch2","C",03,0,0,"G","","","","","MV_PAR02","","","","ZZZ"     ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"03","De Numero"       ,"De Numero"       ,"De Numero"       ,"mv_ch3","C",09,0,0,"G","","","","","MV_PAR03","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"04","Ate Numero"      ,"Ate Numero"      ,"Ate Numero"      ,"mv_ch4","C",09,0,0,"G","","","","","MV_PAR04","","","","ZZZZZZ"  ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"05","De Parcela"      ,"De Parcela"      ,"De Parcela"      ,"mv_ch5","C",03,0,0,"G","","","","","MV_PAR05","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"06","Ate Parcela"     ,"Ate Parcela"     ,"Ate Parcela"     ,"mv_ch6","C",03,0,0,"G","","","","","MV_PAR06","","","","Z"       ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"07","De Portador"     ,"De Portador"     ,"De Portador"     ,"mv_ch7","C",03,0,0,"G","","SA6","","","MV_PAR07","","","","001"     ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"08","Ate Portador"    ,"Ate Portador"    ,"Ate Portador"    ,"mv_ch8","C",03,0,0,"G","","SA6","","","MV_PAR08","","","","001"     ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"09","De Cliente"      ,"De Cliente"      ,"De Cliente"      ,"mv_ch9","C",06,0,0,"G","","SA1","","","MV_PAR09","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"10","Ate Cliente"     ,"Ate Cliente"     ,"Ate Cliente"     ,"mv_cha","C",06,0,0,"G","","SA1","","","MV_PAR10","","","","ZZZZZZ"  ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"11","De Loja"         ,"De Loja"         ,"De Loja"         ,"mv_chb","C",02,0,0,"G","","","","","MV_PAR11","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"12","Ate Loja"        ,"Ate Loja"        ,"Ate Loja"        ,"mv_chc","C",02,0,0,"G","","","","","MV_PAR12","","","","ZZ"      ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"13","De Emissao"      ,"De Emissao"      ,"De Emissao"      ,"mv_chd","D",08,0,0,"G","","","","","MV_PAR13","","","","01/01/01","","","","","","","","","","","","")
U_PUTSX1(cPerg,"14","Ate Emissao"     ,"Ate Emissao"     ,"Ate Emissao"     ,"mv_che","D",08,0,0,"G","","","","","MV_PAR14","","","","31/12/10","","","","","","","","","","","","")
U_PUTSX1(cPerg,"15","De Vencimento"   ,"De Vencimento"   ,"De Vencimento"   ,"mv_chf","D",08,0,0,"G","","","","","MV_PAR15","","","","01/01/01","","","","","","","","","","","","")
U_PUTSX1(cPerg,"16","Ate Vencimento"  ,"Ate Vencimento"  ,"Ate Vencimento"  ,"mv_chg","D",08,0,0,"G","","","","","MV_PAR16","","","","31/12/10","","","","","","","","","","","","")
U_PUTSX1(cPerg,"17","Do Bordero"      ,"Do Bordero"      ,"Do Bordero"      ,"mv_chh","C",06,0,0,"G","","","","","MV_PAR17","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"18","Ate Bordero"     ,"Ate Bordero"     ,"Ate Bordero"     ,"mv_chi","C",06,0,0,"G","","","","","MV_PAR18","","","","ZZZZZZ"  ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"19","Da Carga"        ,"Da Carga"        ,"Da Carga"        ,"mv_chj","C",06,0,0,"G","","DAK","","","MV_PAR19","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"20","Ate Carga"       ,"Ate Carga"       ,"Ate Carga"       ,"mv_chl","C",06,0,0,"G","","DAK","","","MV_PAR20",""   ,""   ,"","ZZZZZZ"  ,"","","","","","","","","","")
U_PUTSX1(cPerg,"21","Mensagem 1"      ,"Mensagem 1"      ,"Mensagem 1"      ,"mv_chm","C",50,0,0,"G","","","","","MV_PAR21","","","",""        ,"","","","","","","","","","","","")
U_PUTSX1(cPerg,"22","Mensagem 2"      ,"Mensagem 2"      ,"Mensagem 2"      ,"mv_chn","C",50,0,0,"G","","","","","MV_PAR22","","","",""        ,"","","","","","","","","","","","")
Return


Static Function Modu10(cLinha)
/******************************************************************************************************************/
Local nSoma:= 0
Local nResto
Local nCont
Local cDigRet
Local nResult
Local lDobra:= .f.
Local cValor
Local nAux

For nCont:= Len(cLinha) To 1 Step -1
	lDobra:= !lDobra
	
	If lDobra
		cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1)) * 2))
	Else
		cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1))))
	EndIf
	
	For nAux:= 1 To Len(cValor)
		nSoma += Val(Substr(cValor, nAux, 1))
	Next n
Next nCont

nResto:= MOD(nSoma, 10)

nResult:= 10 - nResto

If nResult == 10
	cDigRet:= "0"
Else
	cDigRet:= StrZero(10 - nResto, 1)
EndIf
Return cDigRet


/******************************************************************************************************************/
Static Function Modu11(cLinha,cBase,cTipo)
/******************************************************************************************************************/
Local cDigRet
Local nSoma:= 0
Local nResto
Local nCont
Local nFator:= 9
Local nResult
Local _cBase := If( cBase = Nil , 9 , cBase )
Local _cTipo := If( cTipo = Nil , '' , cTipo )
//alert(cLinha)

For nCont:= Len(cLinha) TO 1 Step -1
	nFator++
	If nFator > _cBase
		nFator:= 2
	EndIf
	
	nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
Next nCont

nResto:= Mod(nSoma, 11)

nResult:= 11 - nResto

If _cTipo = 'P'   // Bradesco
	If nResto == 0
		cDigRet:= "0"
	ElseIf  nResto == 1
		cDigRet:= "P"
	Else
		cDigRet:= StrZero(11 - nResto, 1)
	EndIf
Else
	If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
		cDigRet:= "1"
	Else
		cDigRet:= StrZero(11 - nResto, 1)
	EndIf
EndIf
Return cDigRet



Static Procedure NrBordero()
Local nBordero := ""
Local aBanco := { {"001","B"}, {"237","R"},{"033","S"},{"756","C"},{"341","I"} }
Local lFindSEA := .F.
Local nPos := 0

SA1->( dbSetOrder(1), DbSeek( xFilial("SA1") + TSE1->E1_CLIENTE + TSE1->E1_LOJA ) )
if !Empty(SA1->A1_BCO1)
	SEE->( dbSetOrder(1), DbSeek( xFilial("SEE") + SA1->A1_BCO1 ))
Else
	SEE->( dbSetOrder(1), DbSeek( xFilial("SEE") + "033" ))// Santander
EndIf

nPos := AScan ( aBanco, {|x| x[1] == SEE->EE_CODIGO } )

if nPos == 0
	Return .F.
	
elseif !Empty(SE1->E1_PORTADO)
	//	Return .T.
	
endif

// X - Codigo Banco
// XX - Ano Bordero
// X - Codigo Mes
// XX - Dias

nBordero := aBanco[nPos,2] + StrZero( day( dDataBase ),2 ) + Upper(chr( 64+Month( dDataBase ) ) ) + Right( Str( Year( date() ),4 ), 2 )

//Posiciona na Agencia/Conta e Configuracoes bancarias
SEE->( DbSeek( xFilial("SEE")+aBanco[nPos,1] ) )
SA6->( DbSeek( xFilial("SA6")+SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA) )

RecLock("SE1")

SE1->E1_PORTADO := SEE->EE_CODIGO
SE1->E1_AGEDEP	:= SEE->EE_AGENCIA
SE1->E1_CONTA	:= SEE->EE_CONTA
SE1->E1_SITUACA	:= '1'
SE1->E1_OCORREN	:= '01'
SE1->E1_NUMBOR	:= M->nBordero
SE1->E1_DATABOR	:= dDataBase

SE1->( MsUnlock() )
SE1->( DbCommit() )

//
//	Coloca o titulo no bordero
//
SEA->( dbSetOrder( 1 ) )

lFindSEA := SEA->( DbSeek( xFilial( "SEA" )+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,.F. ) )

RecLock( "SEA",!lFindSEA )

if !lFindSEA
	
	SEA->EA_FILIAL  := xFilial( "SEA" )
	SEA->EA_PREFIXO := SE1->E1_PREFIXO
	SEA->EA_NUM     := SE1->E1_NUM
	SEA->EA_PARCELA := SE1->E1_PARCELA
	SEA->EA_FILORIG := cFilAnt
	
endif

SEA->EA_NUMBOR  := SE1->E1_NUMBOR
SEA->EA_TIPO    := SE1->E1_TIPO
SEA->EA_CART    := "R"
SEA->EA_PORTADO := SE1->E1_PORTADO
SEA->EA_AGEDEP  := SE1->E1_AGEDEP
SEA->EA_DATABOR := SE1->E1_DATABOR
SEA->EA_NUMCON  := SE1->E1_CONTA
SEA->EA_SITUACA := SE1->E1_SITUACA
SEA->EA_TRANSF  := 'S'
SEA->EA_SITUANT := '0'

SEA->( msUnLock() )
SEA->( dbCommit() )

Return .T.

/**************************************************************************************/
Static Function BradMod11(NumBoleta)
Local Modulo   := 11
Local strmult  := "2765432765432"
Local BaseDac  := M->NumBoleta  //Carteira + N Nro
Local VarDac   := 0, idac := 0

// Calculo do numero bancario + digito e valor do juros

For idac := 1 To 13
	VarDac := VarDac + Val(Subs(BaseDac, idac, 1)) * Val (Subs (strmult, idac, 1))
Next idac

VarDac  := Modulo - VarDac % Modulo
VarDac  := Iif (VarDac == 10, "P", Iif (VarDac == 11, "0", Str (VarDac, 1)))

Return VarDac



//
// Função para Colocar o D?ito no C?igo de Barras - SICOOB
//
Static Function DigBarSiCoob(CodigoBarra)
Local Indice := '43290876543298765432987654329876543298765432'
Local somax := 0, contador := 0, digito := 0

for contador:=1 to 44
	
	if contador <> 5
		somax += ( val( Substr(CodigoBarra,contador,1) ) * Val( Substr(CodigoBarra,contador,1) ) )
		digito := 11 - Mod(SomaX,11)
	endif
	
	if (digito <= 1) .or. (digito > 9)
		digito := 1
	endif
	
next contador

//Colocar o digito no codigo barra
//codigobarra[5] := inttostr(digito)[1];
return digito



//
// Função para Validação do C?igo de Barras - SICOOB
//
Static Function ValidaCodigoBarra(codigobarra)
Local Indice := '43290876543298765432987654329876543298765432'
Local somax := 0, contador := 0, digito := 0

for contador:=1 to 44
	
	if contador <> 5
		somax += Val( Substr(codigobarra,contador,1) ) * Val( Substr(indice,contador,1) )
		digito := 11 - Mod(SomaX,11)
	endif
	
	if (digito <= 1) .or. (digito > 9)
		digito := 1
	endif
	
next contador
Return digito


//
//Função para Definir o Pr?imo M?tiplo de 10 - SICOOB
//
Static Function Multiplo10(numero)
Local result := 0

while Mod(numero,10) <> 0
	numero += 1
	result := numero
enddo
Return result


//
//Função para Definir Digito Nosso Numero  - SICOOB
//
Static Function SiCoobMod11(NumBoleta)
Local Modulo   := 11
Local strmult  := "319731973197319731973"
//Local strmult  := "1973197319731973"
Local BaseDac  := M->NumBoleta  //Carteira + N Nro
Local VarDac   := 0, idac := 0

// Calculo do numero bancario + digito e valor do juros
For idac := 1 To len(NumBoleta)
	VarDac += Val(Subs(BaseDac, idac, 1)) * Val (Subs (strmult, idac, 1))
Next idac

VarDac  := Modulo - VarDac % Modulo
VarDac  := Iif (VarDac < 2 .or. VarDac >= 10, "0", Str(VarDac) )
Return VarDac


Static Function DigNNSicoob(cNNum,cCodEmp,cCodCoop,cParcela)
Local cCoop   := cCodCoop
Local cClie   := StrZero(Val(cCodEmp),10)
Local nMod    := 11
Local nSoma   := 0

Default cNNum 	:= '0000001'
Default cParcela:= '001'

aCons := {3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3}

cSeq := cCoop+cClie+cNNum
For nI := 1 to Len(cSeq)
	nSoma += Val(SubStr(cSeq,nI,1))*aCons[nI]
Next

nDigit := (nSoma % nMod)
//cDigit := AllTrim(Str( iif( nDigit <= 1,0, iif(nDigit >= 10,1,nDigit)) ) )

if nDigit <= 1
	cDigit := '0'
else
	cDigit := AllTrim(Str(nMod - nDigit))
endif

Return cDigit


//
// Função para Definir Linha Digital - SICOOB
//
Static Function DigitoLinhaDigitavel(linhadigitavel)
Local Indice := '2121212120121212121201212121212'
Local digito :=0, soma:=0, mult:=0, contador:=0
Local codigobarra := ""
Local nResult := ""

//c?culo do primeiro d?ito
soma := 0

for contador := 10 to 1 Step -1
	
	mult := Val( Substr(linhadigitavel,contador,1) ) * Val( Substr(indice,contador,1) )
	if mult >= 10
		nResult := StrZero(mult,2)
		soma += Val( Left(nResult,1) ) + Val( Right(nResult,2) )
	else
		soma += mult
	endif
	
next contador

digito := multiplo10(soma) - soma

//Coloca o primeiro digito na linha digit?el
linhadigitavel := Left(linhadigitavel,09,1) + Str(digito,1) + Substr(linhadigitavel,11,40)

//c?culo do segundo d?ito
soma := 0

for contador:=11 to 20
	
	mult := Val( Substr(linhadigitavel,contador,1) ) * Val( Substr(indice,contador,1) )
	if mult >= 10
		nResult := StrZero(mult,2)
		soma += Val( Left(nResult,1) ) + Val( Right(nResult,2) )
	else
		soma += mult
	endif
	
next contador

digito := multiplo10(soma) - soma

//Coloca o segundo digito na linha digit?el
linhadigitavel := Left( linhadigitavel,20) + Str(digito,1) + Substr(linhadigitavel,22,40)

//c?culo do terceiro d?ito
soma := 0

for contador:=22 to 31
	
	mult := Val( Substr(linhadigitavel,contador,1) ) * Val( Substr(indice,contador,1) )
	if mult >= 10
		nResult := StrZero(mult,2)
		soma += Val( Left(nResult,1) ) + Val( Right(nResult,2) )
	else
		soma += mult
	endif
	
next contador

//digito := multiplo10(soma) – soma

//Coloca o terceiro digito na linha digit?el
linhadigitavel := Left( linhadigitavel,1,31) + Str(digito,1) + Substr(linhadigitavel,33,40)

//Monta o codigo de barra para verificar o ?timo d?ito

codigobarra := SubStr(linhadigitavel, 01, 03) //C?igo do Banco
codigobarra += SubStr(linhadigitavel, 04, 01) //Moeda
codigobarra += SubStr(linhadigitavel, 33, 01) //Digito Verificador
codigobarra += SubStr(linhadigitavel, 34, 04) //fator de vencimento
codigobarra += SubStr(linhadigitavel, 38, 10) //valor do documento
codigobarra += SubStr(linhadigitavel, 05, 01) //Carteira
codigobarra += SubStr(linhadigitavel, 06, 04) //Agencia
codigobarra += SubStr(linhadigitavel, 11, 02) //Modalidade Cobranca
codigobarra += SubStr(linhadigitavel, 13, 07) //C?igo do Cliente
codigobarra += SubStr(linhadigitavel, 20, 01) + SubStr(linhadigitavel, 22, 7)//Nosso Numero
codigobarra += SubStr(linhadigitavel, 29, 03) //Parcela

codigobarra := DigitoCodigoBarra(codigobarra);
//Coloca o primeiro digito na linha digit?el
linhadigitavel := Left(linhadigitavel,32) + Substr(codigobarra,5,1) + Substr(linhadigitavel,32)
Return {linhadigitavel,codigobarra}




/******************************************************************************************************************/
//CONVENIO SANTANDER
/******************************************************************************************************************/
Static Function Dig11Santander(cData)
Local Auxi := 0, sumdig := 0

cbase  := cData
lbase  := Len(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase

for iDig:=len(cBase) to 1 Step -1
	
	if base == 9
		base := 2
	endIf
	
	auxi   := Val(SubStr(cBase, iDig, 1)) * base
	sumdig := SumDig+auxi
	base   += 1
	
next iDig

auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "1"
ElseIf auxi == 1 .or. auxi == 0
	auxi := "0"
Else
	auxi := str(11-auxi,1,0)
EndIf

Return(auxi)
