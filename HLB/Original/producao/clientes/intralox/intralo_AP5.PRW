#include "rwmake.ch"

/*
Funcao      : intralo
Parametros  : 
Retorno     : 
Objetivos   : INTRALOX - Modelo da Nota Fiscal de 132 colunas
Autor       : 
Data/Hora   : 22/08/2012    10:14
Revisão		: Matheus Massarotto
Data/Hora   : 
Módulo      : Faturamento
*/

*---------------------*
User Function intralo()        // incluido pelo assistente de conversao do AP5 IDE em 22/08/01
*---------------------*

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M,xDESC1,xDESC2,xDESC3,xDESC4")
SetPrvt("MEX,MBR,MEXT,MEXT2,TAMANHO,LIMITE,_nQtdNF,_nContNF")
SetPrvt("TITULO,CDESC1,CDESC2,CDESC3,CNATUREZA,ARETURN,xTot_Vol")
SetPrvt("NOMEPROG,CPERG,NLASTKEY,LCONTINUA,NLIN,WNREL")
SetPrvt("NTAMNF,CSTRING,CPEDANT,NLININI,XNUM_NF,XSERIE")
SetPrvt("XEMISSAO,XTOT_FAT,XLOJA,XFRETE,XSEGURO,XBASE_ICMS")                                 
SetPrvt("XBASE_IPI,XVALOR_ICMS,XICMS_RET,XVALOR_IPI,XVALOR_MERC,XNUM_DUPLIC")
SetPrvt("XCOND_PAG,XPBRUTO,XPLIQUI,XTIPO,XESPECIE,XVOLUME")
SetPrvt("XBASEISS,CPEDATU,CITEMATU,XPED_VEND,XITEM_PED,XNUM_NFDV")
SetPrvt("XPREF_DV,XICMS,XCOD_PRO,XQTD_PRO,XQTD2_PRO,XPRE_UNI")
SetPrvt("XPRE_TAB,XIPI,XVAL_IPI,XDESC,XVAL_DESC,XVAL_MERC")
SetPrvt("XTES,XCF,XICMSOL,XICM_PROD,XCST,XTEXTOCST")
SetPrvt("XDTVALID,XLOTE,XDESCRICAOC,I,XPESO_PRO")
SetPrvt("XPESO_UNIT,XDESCRICAO,XDESCRICA01,XDESCRICA02,XUNID_PRO,XUNID2_PRO")
SetPrvt("XFATOR_PRO,XCOD_TRIB,XMEN_TRIB,XCOD_FIS,XCLAS_FIS,XMEN_POS")
SetPrvt("XISS,XTIPO_PRO,XLUCRO,XCLFISCAL,XPESO_LIQ,NPELEM")
SetPrvt("XPESO_LIQUID,XPED,XPESO_BRUTO,XP_LIQ_PED,XCLIENTE,XNUM_SC5")
SetPrvt("XTIPO_CLI,XCOD_MENS,XMENSAGEM,XTPFRETE,XCONDPAG,XCOD_VEND")
SetPrvt("XDESC_NF,XDESC_PAG,XPED_CLI,XDESC_PRO,J,XCOD_CLI")
SetPrvt("XNOME_CLI,XEND_CLI,XBAIRRO,XCEP_CLI,XCOB_CLI,XREC_CLI")
SetPrvt("XMUN_CLI,XEST_CLI,XCGC_CLI,XINSC_CLI,XTRAN_CLI,XTEL_CLI")
SetPrvt("XFAX_CLI,XSUFRAMA,XCALCSUF,ZFRANCA,XVENDEDOR,XBSICMRET")
SetPrvt("XNOME_TRANSP,XEND_TRANSP,XMUN_TRANSP,XEST_TRANSP,XVIA_TRANSP,XCGC_TRANSP")
SetPrvt("XTEL_TRANSP,XPARC_DUP,XVENC_DUP,XVALOR_DUP,XDUPLICATAS,XNATUREZA")
SetPrvt("XMENS_TES,XMENS_PED,XFORNECE,XNFORI,XPEDIDO,XPESOPROD")
SetPrvt("XMENSOBS,XMENSIMP,XOBSIMP,XFAX,NOPC,CCOR")
SetPrvt("NTAMDET,XB_ICMS_SOL,XV_ICMS_SOL,_SERV,_VENDA,_CTOTMEN")
SetPrvt("CTOTMEN,XTEXTO1,XTEXTO2,XTEXTO,NCOL,NTAMOBS")
SetPrvt("COBS1,COBS2,COBS3,COBS4,NAJUSTE,BB,nDespesa")

//-----------------------------------------------------------------------------
//Nota Fiscal de Entrada/Saida  - SEM IMPRESSAO DO LOTE
//Utilizado para o Cliente - INTRALOX - Modelo da Nota Fiscal de 132 colunas
//-----------------------------------------------------------------------------
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Ambientais                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01             // Da Nota Fiscal                       ³
³ mv_par02             // Ate a Nota Fiscal                    ³
³ mv_par03             // Da Serie                             ³
³ mv_par04             // Nota Fiscal de Entrada/Saida         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/

CbTxt      :=""
CbCont     :=""
nOrdem     :=0
Alfa       :=0
Z          :=0
M          :=0
MEX        :=0
MBR        :=SPAC(50)
MEXT       :=SPAC(50)
MEXT2      :=SPAC(50)
tamanho    :="G"
limite     :=220
titulo     :=PADC("Programa de Impressao de Nota Fiscal - Cisco",74)
cDesc1     :="Este programa ira emitir a Nota Fiscal de Entrada/Saida"
cDesc2     :="para a Empresa "+SM0->M0_NOMECOM
cDesc3     :=PADC("NF ",74)+SM0->M0_NOME
cNatureza  :=""
aReturn    := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog   :="INTRALO"
cPerg      :="NFSIGW    "
nLastKey   := 0
lContinua  := .T.
nLin       :=0
wnrel      := "NFINTRA"
xTot_Vol   :=0
_OK        :=.F.
_K         :=.F.
nDespesa   :=0

if !u_versm0("U6")    // VERIFICA EMPRESA  intralox
	return
endif

Pergunte(cPerg,.F.)
cString:="SF2"

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

VerImp()

#IFDEF WINDOWS
	RptStatus({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF
xSeguro := xFrete:=0
If mv_par04 == 2
	DbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
	DbSetOrder(1)
	DbSeek(xFilial("SF2")+mv_par01+mv_par03,.t.)
	DbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+mv_par01+mv_par03)
	cPedant := SD2->D2_PEDIDO
Else
	DbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
	DbSetOrder(1)
	DbSeek(xFilial("SF1")+mv_par01+mv_par03,.t.)
	DbSelectArea("SD1")                // * Itens da Nota Fiscal de Entrada
	DbSetOrder(3)
Endif

SetRegua(Val(mv_par02)-Val(mv_par01))
If mv_par04 == 2
	DbSelectArea("SF2")
	While !eof() .and. SF2->F2_DOC    <= mv_par02 .and. lContinua
		If SF2->F2_SERIE #mv_par03    // Se a Serie do Arquivo for Diferente
			DbSkip()                    // do Parametro Informado !!!
			Loop
		Endif
		#IFNDEF WINDOWS
			IF LastKey()==286
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			Endif
		#ELSE
			IF lAbortPrint
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			Endif
		#ENDIF
		nLinIni:=nLin                         // Linha Inicial da Impressao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio de Levantamento dos Dados da Nota Fiscal              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// * Cabecalho da Nota Fiscal
		xNUM_NF     :=SF2->F2_DOC             // Numero
		xSERIE      :=SF2->F2_SERIE           // Serie
		xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
		xTOT_FAT    :=IIF(SF2->F2_TIPO=="P",SF2->F2_VALIPI,SF2->F2_VALFAT )  // Valor Total da Fatura
		
		if xTOT_FAT == 0
			xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
		endif
		
		MEXT:=extenso(xTOT_FAT,.F.,1)
		
		xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
		xFRETE      :=SF2->F2_FRETE           // Frete
		xSEGURO     :=SF2->F2_SEGURO          // Seguro
		xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
		xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
		xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
		xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
		xVALOR_IPI  :=SF2->F2_VALIPI          // Valor  do IPI
		xVALOR_MERC :=SF2->F2_VALMERC         // Valor  da Mercadoria
		xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
		xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
		xPBRUTO     :=SF2->F2_PBRUTO          // Peso Bruto
		xPLIQUI     :=SF2->F2_PLIQUI          // Peso Liquido
		xTIPO       :=SF2->F2_TIPO            // Tipo do Pedido
		xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
		xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido
		xBASEISS    :=SF2->F2_BASEISS         // Valor do ISS
		DbSelectArea("SD2")                   // * Itens de Venda da N.F.
		DbSetOrder(3)
		DbSeek(xFilial("SD2")+xNUM_NF+xSERIE)
		cPedAtu := SD2->D2_PEDIDO
		cItemAtu := SD2->D2_ITEMPV
		xPED_VEND:={}                         // Numero do Pedido de Venda
		xITEM_PED:={}                         // Numero do Item do Pedido de Venda
		xNUM_NFDV:={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
		xPREF_DV :={}                         // Serie  quando houver devolucao
		xICMS    :={}                         // Porcentagem do ICMS
		xCOD_PRO :={}                         // Codigo  do Produto
		xQTD_PRO :={}                         // Peso/Quantidade do Produto
		xQTD2_PRO:={}                         // Quantidade pela 2a.UM.
		xPRE_UNI :={}                         // Preco Unitario de Venda
		xPRE_TAB :={}                         // Preco Unitario de Tabela
		xIPI     :={}                         // Porcentagem do IPI
		xVAL_IPI :={}                         // Valor do IPI
		xDESC    :={}                         // Desconto por Item
		xVAL_DESC:={}                         // Valor do Desconto
		xVAL_MERC:={}                         // Valor da Mercadoria
		xTES     :={}                         // TES
		xCF      :={}                         // Classificacao quanto natureza da Operacao
		xICMSOL  :={}                         // Base do ICMS Solidario
		xICM_PROD:={}                         // ICMS do Produto
		xCST     :={}
		xTEXTOCST:={}
		xNatureza:={}  
		xISS_ALIQ :={}
		xISS_BASE :={}
		xISS_VLR  :={}
		
		xMensTes := ""		 
		//  xDTVALID :={}
		//  xLote    :={}
		while !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
			If SD2->D2_SERIE #mv_par03 //.OR. SD2->D2_TES == "502"   // Se a Serie do Arquivo for Diferente
				DbSkip()                   // do Parametro Informado !!!
				Loop
			Endif
			DbSelectArea("SF4")                   // * Tipos de Entrada e Saida
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+SD2->D2_TES)
			If !Empty(SF4->F4_FORMULA)
				xMensTes += FORMULA(SF4->F4_FORMULA)
				xMensTes += "/"
			Endif
			
			AADD(xNatureza ,SF4->F4_TEXTO)
			DbSelectArea("SX5")
			DbSeek(xfilial("SX5")+"AA",.T.)
			DbSelectArea("SD2")
			
			AADD(xPED_VEND ,SD2->D2_PEDIDO)
			AADD(xITEM_PED ,SD2->D2_ITEMPV)
			AADD(xNUM_NFDV ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
			AADD(xPREF_DV  ,SD2->D2_SERIORI)
			AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
			
			AADD(xCOD_PRO  ,SD2->D2_COD)
			AADD(xTEXTOCST ,SX5->X5_DESCRI)
			
			AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
			AADD(xQTD2_PRO ,SD2->D2_QTSEGUM)   // Guarda as quant. 2UM da NF
			AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
			AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
			AADD(xIPI      ,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
			AADD(xVAL_IPI  ,SD2->D2_VALIPI)
			AADD(xDESC     ,SD2->D2_DESC)
			AADD(xVAL_MERC ,SD2->D2_TOTAL)
			AADD(xTES      ,SD2->D2_TES)
			AADD(xCF       ,SD2->D2_CF)
			AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))      
			//AADD(xDTVALID  ,SD2->D2_DTVALID)
			//AADD(xLOTE     ,subs(SD2->D2_LOTECTL,1,10))
     		AADD(xISS_ALIQ ,IIf(Empty(SD2->D2_ALIQISS),0,SD2->D2_ALIQISS))      
     		AADD(xISS_BASE ,IIf(Empty(SD2->D2_BASEISS),0,SD2->D2_BASEISS)) 
     		AADD(xISS_VLR  ,IIf(Empty(SD2->D2_VALISS),0,SD2->D2_VALISS)) 
			
			DbSkip()
		End
		
		//    DbSelectArea("SB5")                     // * Dados Adicionais do Produto
		//    DbSetOrder(1)
		xDESCRICAOC :={}                         // Descricao Cientifica do Produto
		//    I:=1
		//    For I:=1 to Len(xCOD_PRO)
		//       AADD(xDESCRICAOC ,SB5->B5_CEME)
		//    Next
		
		DbSelectArea("SB1")                     // * Desc. Generica do Produto
		DbSetOrder(1)
		xPESO_PRO    :={}                       // Peso Liquido
		xPESO_UNIT   :={}                       // Peso Unitario do Produto
		xDESCRICAO   :={}                       // Descricao do Produto
		xDESCRICA01   :={}                       // Descricao do Produto
		xDESCRICA02   :={}                       // Descricao do Produto
		xUNID_PRO    :={}                       // Unidade Primaria do Produto
		xUNID2_PRO   :={}                       // Unidade Secundaria do Produto
		xFATOR_PRO   :={}                       // Fator de conversao do Produto
		xCOD_TRIB    :={}                       // Codigo de Tributacao
		xMEN_TRIB    :={}                       // Mensagens de Tributacao
		xCOD_FIS     :={}                       // Codigo Fiscal
		xCLAS_FIS    :={}                       // Classificacao Fiscal
		xMEN_POS     :={}                       // Mensagem da Posicao IPI
		xISS         :={}                       // Aliquota de ISS
		xTIPO_PRO    :={}                       // Tipo do Produto
		xLUCRO       :={}                       // Margem de Lucro p/ ICMS Solidario
		xCLFISCAL    :={}
		xPESO_LIQ    := 0
		I            :=1
		For I:=1 to Len(xCOD_PRO)
			DbSeek(xFilial("SB1")+xCOD_PRO[I])
			AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
			xPESO_LIQ  := xPESO_LIQ + xPESO_PRO[I]
			AADD(xPESO_UNIT , SB1->B1_PESO)
			AADD(xUNID_PRO  , SB1->B1_UM)
			AADD(xUNID2_PRO , SB1->B1_SEGUM)
			AADD(xFATOR_PRO , SB1->B1_CONV)
			AADD(xDESCRICAO , subs(SB1->B1_DESC,1,30))
			AADD(xDESCRICA01 , SB1->B1_DESCR01)
			AADD(xDESCRICA02 , SB1->B1_DESCR02)
			AADD(xCOD_TRIB  , SB1->B1_CLASFIS)
			If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
				AADD(xMEN_TRIB , SB1->B1_CLASFIS)
			Endif
			AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
			npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)
			If SB1->B1_ALIQISS > 0
				AADD(xISS ,SB1->B1_ALIQISS)
			Endif
			
			For fr:=1 to len(xTES)
				SF4->(DbSeek(xFilial("SF4")+xTES[fr]))
				AADD(xCST,(ALLTRIM (SB1->B1_ORIGEM)+ SF4->F4_SITTRIB))        //ALE
			Next
			AADD(xTIPO_PRO ,SB1->B1_TIPO)
			AADD(xLUCRO    ,SB1->B1_PICMRET)
			// Calculo do Peso Liquido da Nota Fiscal
			/*
			xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
			For B:=1 to Len(xPESO_PRO)
			xPESO_LIQUID:=xPESO_LIQUID+xPESO_PRO[B]
			Next
			*/
		Next
		DbSelectArea("SC5")                            // * Pedidos de Venda
		DbSetOrder(1)
		xPED        := {}
		xPESO_BRUTO := 0
		xPESO_LIQUID := 0
		xP_LIQ_PED  := 0
		For II:=1 to Len(xPED_VEND)
			DbSeek(xFilial("SC5")+xPED_VEND[II])
			If ASCAN(xPED,xPED_VEND[II])==0
				DbSeek(xFilial("SC5")+xPED_VEND[II])
				xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
				xNUM_SC5    :=SC5->C5_NUM               // Numero do Pedido
				xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
				xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
				xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
				xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
				xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
				xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
				xPESO_LIQUID :=SC5->C5_PESOL // Peso Liquido
				
				//				xP_LIQ_PED  :=xP_LIQ_PED + SC5->C5_PESOL // Peso Liquido
				xCOD_VEND:= {SC5->C5_VEND1,;             // Codigo do Vendedor 1
				SC5->C5_VEND2,;             // Codigo do Vendedor 2
				SC5->C5_VEND3,;             // Codigo do Vendedor 3
				SC5->C5_VEND4,;             // Codigo do Vendedor 4
				SC5->C5_VEND5}              // Codigo do Vendedor 5
				xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
				SC5->C5_DESC2,;             // Desconto Global 2
				SC5->C5_DESC3,;             // Desconto Global 3
				SC5->C5_DESC4}              // Desconto Global 4
				AADD(xPED,xPED_VEND[II])
			Endif
			If xP_LIQ_PED >0
				xPESO_LIQ := xP_LIQ_PED
			Endif
		Next II
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa da Condicao de Pagto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !EMPTY(xCONDPAG)
			DbSelectArea("SE4")                    // Condicao de Pagamento
			DbSetOrder(1)
			DbSeek(xFilial("SE4")+xCONDPAG)
			xDESC_PAG := SE4->E4_DESCRI
		ENDIF
		DbSelectArea("SC6")                    // * Itens de Pedido de Venda
		DbSetOrder(1)
		xPED_CLI :={}                          // Numero de Pedido
		xDESC_PRO:={}                          // Descricao aux do produto
		xDESC1   :={}                          // Descricao aux do produto
		xDESC2   :={}                          // Descricao aux do produto
		xDESC3   :={}                          // Descricao aux do produto
		xDESC4   :={}                          // Descricao aux do produto
		xTot_Vol :=0                           // Total de Volume
		// xLOTE    :={}                       // Lote Fornecedor (Saidas)
		J:=Len(xPED_VEND)
		For I:=1 to J
			DbSeek(xFilial("SC6")+xPED_VEND[I]+xITEM_PED[I])
			//IF SC6->C6_TES != "502"
			AADD(xPED_CLI ,SC6->C6_PEDCLI)
			AADD(xDESC_PRO,SC6->C6_DESCRI)
			AADD(xVAL_DESC,SC6->C6_VALDESC)
			AADD(xDESC1,SC6->C6_DESCR01)
			AADD(xDESC2,SC6->C6_DESCR02)
			AADD(xDESC3,SC6->C6_DESCR03)
			AADD(xDESC4,SC6->C6_DESCR04)
			xTot_Vol:=xTot_Vol+SC6->C6_COMIS5
			
			// AADD(xLOTE    ,subs(SC6->C6_LOTECTL,1,10))
			//ENDIF
		Next
		If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'
			DbSelectArea("SA1")                // * Cadastro de Clientes
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+xCLIENTE+xLOJA)
			xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
			xNOME_CLI:=SA1->A1_NOME            // Nome
			xEND_CLI :=SA1->A1_END             // Endereco
			xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
			xCEP_CLI :=SA1->A1_CEP             // CEP
			xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
			xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
			xMUN_CLI :=SA1->A1_MUN             // Municipio
			xEST_CLI :=SA1->A1_EST             // Estado
			xCGC_CLI :=SA1->A1_CGC             // CGC
			xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
			xTEL_CLI :=SA1->A1_TEL             // Telefone
			xFAX_CLI :=SA1->A1_FAX             // Fax
			xSUFRAMA :=SA1->A1_SUFRAMA         // Codigo Suframa
			xCALCSUF :=SA1->A1_CALCSUF         // Calcula Suframa
			// Alteracao p/ Calculo de Suframa
			if !empty(xSUFRAMA) .and. xCALCSUF =="S"
				IF XTIPO == 'D' .OR. XTIPO == 'B'
					zFranca := .F.
				else
					zFranca := .T.
				endif
			Else
				zfranca:= .F.
			endif
		Else
			zFranca:=.F.
			DbSelectArea("SA2")                // * Cadastro de Fornecedores
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+xCLIENTE+xLOJA)
			xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
			xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
			xEND_CLI :=SA2->A2_END             // Endereco
			xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
			xCEP_CLI :=SA2->A2_CEP             // CEP
			xCOB_CLI :=""                      // Endereco de Cobranca
			xREC_CLI :=""                      // Endereco de Entrega
			xMUN_CLI :=SA2->A2_MUN             // Municipio
			xEST_CLI :=SA2->A2_EST             // Estado
			xCGC_CLI :=SA2->A2_CGC             // CGC
			xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
			xTEL_CLI :=SA2->A2_TEL             // Telefone
			xFAX_CLI :=SA2->A2_FAX             // Fax
		Endif
		DbSelectArea("SA3")                   // * Cadastro de Vendedores
		DbSetOrder(1)
		xVENDEDOR:={}                         // Nome do Vendedor
		I:=1
		J:=Len(xCOD_VEND)
		For I:=1 to J
			DbSeek(xFilial("SA3")+xCOD_VEND[I])
			Aadd(xVENDEDOR,SA3->A3_NREDUZ)
		Next
		If xICMS_RET >0                          // Apenas se ICMS Retido > 0
			DbSelectArea("SF3")                   // * Cadastro de Livros Fiscais
			DbSetOrder(4)
			DbSeek(xFilial("SF3")+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
			If Found()
				xBSICMRET:=F3_VALOBSE
			Else
				xBSICMRET:=0
			Endif
		Else
			xBSICMRET:=0
		Endif
		DbSelectArea("SA4")                   // * Transportadoras
		DbSetOrder(1)
		DbSeek(xFilial("SA4")+SF2->F2_TRANSP)
		xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
		xEND_TRANSP  :=SA4->A4_END            // Endereco
		xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
		xEST_TRANSP  :=SA4->A4_EST            // Estado
		xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
		xCGC_TRANSP  :=SA4->A4_CGC            // CGC
		xTEL_TRANSP  :=SA4->A4_TEL            // Fone
		DbSelectArea("SE1")                   // * Contas a Receber
		DbSetOrder(1)
		xPARC_DUP  :={}                       // Parcela
		xVENC_DUP  :={}                       // Vencimento
		xVALOR_DUP :={}                       // Valor
		xDUPLICATAS:=IIF(DbSeek(xFilial("SE1")+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
		while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
			If !("NF" $ SE1->E1_TIPO)
				DbSkip()
				Loop
			Endif
			AADD(xPARC_DUP ,SE1->E1_PARCELA)
			AADD(xVENC_DUP ,SE1->E1_VENCTO)
			AADD(xVALOR_DUP,SE1->E1_VALOR)
			DbSkip()
		EndDo
		DbSelectArea("SF4")                   // * Tipos de Entrada e Saida
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+xTES[1])

		AADD(xNATUREZA,SF4->F4_TEXTO)
 		xMENS_PED := ""
		If ! empty(SF4->F4_FORMULA)
			xMensTes += ALLTRIM(FORMULA(SF4->F4_FORMULA))
			xMensTes += "/"		
		Endif
		
		if ! empty(SC5->C5_MENPAD)
			  xMENS_PED := Formula(XCOD_MENS)
		endif
		Imprime()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Termino da Impressao da Nota Fiscal                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncRegua()                    // Termometro de Impressao
		nLin:=0
		DbSelectArea("SF2")
		DbSkip()                      // passa para a proxima Nota Fiscal
	EndDo
Else
	DbSelectArea("SF1")              // * Cabecalho da Nota Fiscal Entrada
	DbSeek(xFilial("SF1")+mv_par01+mv_par03,.t.)
	xMensTes := ""
	While !eof() .and. SF1->F1_DOC <= mv_par02 .and. SF1->F1_SERIE == mv_par03 .and. lContinua
		//If SF1->F1_SERIE #mv_par03    // Se a Serie do Arquivo for Diferente
		//If SF1->F1_FORMUL != "S"       // Se nao for formulario proprio
		//	DbSkip()
		//	Loop
		//Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa  regua de impressao                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetRegua(Val(mv_par02)-Val(mv_par01))
		#IFNDEF WINDOWS
			IF LastKey()==286
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			Endif
		#ELSE
			IF lAbortPrint
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			Endif
		#ENDIF
		nLinIni:=nLin                         // Linha Inicial da Impressao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio de Levantamento dos Dados da Nota Fiscal              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xNUM_NF     :=SF1->F1_DOC             // Numero
		xSERIE      :=SF1->F1_SERIE           // Serie
		xFORNECE    :=SF1->F1_FORNECE         // Cliente/Fornecedor
		xEMISSAO    :=SF1->F1_EMISSAO         // Data de Emissao
		xTOT_FAT    :=SF1->F1_VALBRUT         // Valor Bruto da Compra
		
		MEXT:=extenso(xTOT_FAT,.F.,1)
		
		xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
		xFRETE      :=SF1->F1_FRETE           // Frete
		nDespesa    :=SF1->F1_DESPESA         // Despesa
		xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
		xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
		xBSICMRET   :=SF1->F1_BRICMS          // Base do ICMS Retido
		xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
		xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
		xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
		xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
		xNUM_DUPLIC :=SF1->F1_DUPL            // Numero da Duplicata
		xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
		xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
		xNFORI      :=SF1->F1_NFORI           // NF Original
		xPREF_DV    :=SF1->F1_SERIORI         // Serie Original
		xPeso_Liquid:=SF1->F1_PESOL
		xPeso_Bruto :=SF1->F1_P_PESOB
		xEspecie    :=SF1->F1_P_ESPV
		xVolume     :=SF1->F1_P_VOLUM 
				
		DbSelectArea("SD1")                   // * Itens da N.F. de Compra
		DbSetOrder(1)                                                                          //    2026   27 28
		DbSeek(xFilial("SD1")+xNUM_NF+xSERIE+xFORNECE+xLOJA)
		cPedAtu := SD1->D1_PEDIDO
		cItemAtu:= SD1->D1_ITEMPC
		xPEDIDO  :={}                              // Numero do Pedido de Compra
		xITEM_PED:={}                              // Numero do Item do Pedido de Compra
		xNUM_NFDV:={}                              // Numero quando houver devolucao
		xPREF_DV :={}                              // Serie  quando houver devolucao
		xICMS    :={}                              // Porcentagem do ICMS
		xCOD_PRO :={}                              // Codigo  do Produto
		xQTD_PRO :={}                              // Peso/Quantidade do Produto
		xQTD2_PRO:={}                              // Peso/Quant. 2UM do Produto
		xPRE_UNI :={}                              // Preco Unitario de Compra
		xIPI     :={}                              // Porcentagem do IPI
		xPESOPROD:={}                              // Peso do Produto
		xVAL_IPI :={}                              // Valor do IPI
		xDESC    :={}                              // Desconto por Item
		xVAL_DESC:={}                              // Valor do Desconto
		xVAL_MERC:={}                              // Valor da Mercadoria
		xTES     :={}                              // TES
		xCF      :={}                              // Classificacao quanto natureza da Operacao
		xICMSOL  :={}                              // Base do ICMS Solidario
		xICM_PROD:={}                              // ICMS do Produto
		//xLOTE  :={}                              // Lote do Fornecedor
		xMENSOBS :=space(200)                      // Mensagem Ref. N.Fiscal Entrada
		xMENSIMP :=space(60)                       // Mensagem Ref. N.Fiscal Entrada
		//xDTVALID :={}                            // Data de validade do Lote
		xMEN_TRIB:={}
		xCST     :={}                              // Codigo da Sit.Tributaria
		xTEXTOCST:={}                              // Texto da Sit. Tributaria
		xOBSIMP  :={}                              // Observacoes p/importacao
		
		while !eof() .and. SD1->D1_DOC==xNUM_NF .and. SD1->D1_SERIE == xSERIE .and. ;
			SD1->D1_FORNECE==xFORNECE
			IF Val(SD1->D1_ITEM) == 1
				xMENSIMP := SD1->D1_OBS              //Mensagem do primeiro item
			ENDIF
			DbSelectArea("SF4")                   // * Tipos de Entrada e Saida
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+SD1->D1_TES)
			If !Empty(SF4->F4_FORMULA)
				xMensTes += FORMULA(SF4->F4_FORMULA)
				xMensTes += "/"
			
			Endif
			
			DbSelectArea("SD1")
			AADD(xPEDIDO   ,SD1->D1_PEDIDO)           // Ordem de Compra
			AADD(xITEM_PED ,SD1->D1_ITEMPC)         // Item da O.C.
			AADD(xNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
			AADD(xPREF_DV  ,SD1->D1_SERIORI)        // Serie Original
			AADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
			
			AADD(xCOD_PRO  ,SD1->D1_COD)            // Produto
			AADD(xQTD_PRO  ,SD1->D1_QUANT)          // Guarda as quant. da NF
			AADD(xQTD2_PRO ,SD1->D1_QTSEGUM)        // Guarda as quant. 2UM da NF
			AADD(xPRE_UNI  ,SD1->D1_VUNIT)          // Valor Unitario
			AADD(xIPI      ,SD1->D1_IPI)            // % IPI
			AADD(xVAL_IPI  ,SD1->D1_VALIPI)         // Valor do IPI
			AADD(xPESOPROD ,SD1->D1_PESO)           // Peso do Produto
			AADD(xDESC     ,SD1->D1_DESC)           // % Desconto
			AADD(xVAL_MERC ,SD1->D1_TOTAL)          // Valor Total
			AADD(xTES      ,SD1->D1_TES)            // Tipo de Entrada/Saida
			AADD(xCF       ,SD1->D1_CF)             // Codigo Fiscal
			AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
			// Inclusao para pegar o No. de Lote para impressao
			// If !Empty(SD1->D1_LOTEFOR)
			//    AADD(xLOTE     ,SD1->D1_LOTEFOR)        // Lote Fornecedor
			// Else
			//    AADD(xLOTE     ,SD1->D1_LOTECTL)        // Lote Fornecedor
			// Endif
			// AADD(xDTVALID  ,SD1->D1_DTVALID)           // Data Validade
			Dbskip()
		End
		DbSelectArea("SF4")                        // * Tipos de Entrada e Saida
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+xTes[1])
//JOSE
		xNATUREZA:=SF4->F4_TEXTO                   // Natureza da Operacao
		//xMensTes := FORMULA(SF4->F4_FORMULA)
		DbSelectArea("SB1")                        // * Desc. Generica do Produto
		DbSetOrder(1)
		xUNID_PRO  :={}                              // Unidade do Produto
		xDESC_PRO  :={}                              // Descricao do Produto
		xMEN_POS   :={}                              // Mensagem da Posicao IPI
		xDESCRICAO :={}                              // Descricao do Produto
		xDESCRICA01 :={}                              // Descricao do Produto
		xDESCRICA02 :={}                              // Descricao do Produto
		xCOD_TRIB  :={}                              // Codigo de Tributacao
		xMEN_TRIB  :={}                              // Mensagens de Tributacao
		xCOD_FIS   :={}                              // Codigo Fiscal
		xCLAS_FIS  :={}                              // Classificacao Fiscal
		xISS       :={}                              // Aliquota de ISS
		xCST       :={}
		xTIPO_PRO  :={}                              // Tipo do Produto
		xLUCRO     :={}                              // Margem de Lucro p/ ICMS Solidario
		xCLFISCAL  :={}
		xSUFRAMA   :=""
		xCALCSUF   :=""
		I          :=1
		For I := 1 to Len(xCOD_PRO)
			DbSeek(xFilial("SB1")+xCOD_PRO[I])
			DbSelectArea("SB1")
			AADD(xDESC_PRO ,subs(SB1->B1_DESC,1,30))
			AADD(xUNID_PRO ,SB1->B1_UM)
			AADD(xCOD_TRIB ,SB1->B1_CLASFIS)
			If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
				AADD(xMEN_TRIB ,SB1->B1_CLASFIS)
			Endif
			AADD(xDESCRICAO ,subs(SB1->B1_DESC,1,30))
			AADD(xDESCRICA01 ,SB1->B1_DESCR01)
			AADD(xDESCRICA02 ,SB1->B1_DESCR02)
			If SB1->B1_ALIQISS > 0
				AADD(xISS,SB1->B1_ALIQISS)
			Endif
			AADD(xCST, (SB1->B1_ORIGEM+SF4->F4_SITTRIB)) //ALE
			AADD(xTIPO_PRO , SB1->B1_TIPO)
			AADD(xLUCRO    , SB1->B1_PICMRET)
			AADD(xCLAS_FIS , SB1->B1_POSIPI)
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa da Condicao de Pagto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE4")                    // Condicao de Pagamento
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+xCOND_PAG)
		xDESC_PAG := SE4->E4_DESCRI
		If xTIPO == "D" .Or. xTIPO == "B"
			DbSelectArea("SA1")                // * Cadastro de Clientes
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+xFORNECE)
			xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
			xNOME_CLI:=SA1->A1_NOME            // Nome
			xEND_CLI :=SA1->A1_END             // Endereco
			xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
			xCEP_CLI :=SA1->A1_CEP             // CEP
			xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
			xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
			xMUN_CLI :=SA1->A1_MUN             // Municipio
			xEST_CLI :=SA1->A1_EST             // Estado
			xCGC_CLI :=SA1->A1_CGC             // CGC
			xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
			xTEL_CLI :=SA1->A1_TEL             // Telefone
			xFAX_CLI :=SA1->A1_FAX             // Fax
		Else
			DbSelectArea("SA2")                // * Cadastro de Fornecedores
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+xFORNECE+xLOJA)
			xCOD_CLI :=SA2->A2_COD             // Codigo do Cliente
			xNOME_CLI:=SA2->A2_NOME            // Nome
			xEND_CLI :=SA2->A2_END             // Endereco
			xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
			xCEP_CLI :=SA2->A2_CEP             // CEP
			xCOB_CLI :=""                      // Endereco de Cobranca
			xREC_CLI :=""                      // Endereco de Entrega
			xMUN_CLI :=SA2->A2_MUN             // Municipio
			xEST_CLI :=SA2->A2_EST             // Estado
			xCGC_CLI :=SA2->A2_CGC             // CGC
			xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
			xTRAN_CLI:=SF1->F1_P_TRANS 			//SA2->A2_TRANSP          // Transportadora
			xTEL_CLI :=SA2->A2_TEL             // Telefone
			xFAX     :=SA2->A2_FAX             // Fax
		EndIf
		DbSelectArea("SE1")                   // * Contas a Receber
		DbSetOrder(1)
		xPARC_DUP  :={}                       // Parcela
		xVENC_DUP  :={}                       // Vencimento
		xVALOR_DUP :={}                       // Valor
		xDUPLICATAS:=IIF(DbSeek(xFilial("SE1")+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
		while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
			AADD(xPARC_DUP ,SE1->E1_PARCELA)
			AADD(xVENC_DUP ,SE1->E1_VENCTO)
			AADD(xVALOR_DUP,SE1->E1_VALOR)
			DbSkip()
		EndDo
		xNOME_TRANSP :=" "           // Nome Transportadora
		xEND_TRANSP  :=" "           // Endereco
		xMUN_TRANSP  :=" "           // Municipio
		xEST_TRANSP  :=" "           // Estado
		xVIA_TRANSP  :=" "           // Via de Z
		xCGC_TRANSP  :=" "           // CGC
		xTEL_TRANSP  :=" "           // Fone
		xTPFRETE     :=" "           // Tipo de Frete
		//xVOLUME      := 0            // Volume
		//xESPECIE     :=" "           // Especie
		xPESO_LIQ    := 0            // Peso Liquido
		//xPESO_BRUTO  := 0            // Peso Bruto
		xCOD_MENS    :=SPACE(1)      // Codigo da Mensagem
		xMENSAGEM    :=" "           // Mensagem da Nota
		//xPESO_LIQUID := 0
		
		//busca transportadora  hfp
		DbSelectArea("SA4")					     // * Transportadoras
		DbSetOrder(1)
		DbSeek(xFilial("SA4")+xTRAN_CLI)
		xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
		xEND_TRANSP  :=SA4->A4_END            // Endereco
		xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
		xEST_TRANSP  :=SA4->A4_EST            // Estado
		xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
		xCGC_TRANSP  :=SA4->A4_CGC            // CGC
		xTEL_TRANSP  :=SA4->A4_TEL            // Fone
		
		Imprime()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Termino da Impressao da Nota Fiscal                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncRegua()                    // Termometro de Impressao
		nLin:=0
		DbSelectArea("SF1")
		DbSkip()                     // e passa para a proxima Nota Fiscal
	EndDo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do Programa da Nota Fiscal                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
Retindex("SF2")
DbSelectArea("SF1")
Retindex("SF1")
DbSelectArea("SD2")
Retindex("SD2")
DbSelectArea("SD1")
Retindex("SD1")
Set Device To Screen   
SetPgEject(.F.)
If aReturn[5] == 1
	Set Printer TO
	DbcommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VERIMP   ³ Autor ³ Anizio Lucio Ferreira ³ Data ³ 31/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica posicionamento de papel na Impressora             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cisco.prg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function VerImp()
nLin:= 0                // Contador de Linhas
nLinIni:=0
If aReturn[5]==2
	nOpc       := 1
	#IFNDEF WINDOWS
		cCor       := "B/BG"
	#ENDIF
	While .T.
		SetPrc(0,0)
		DbCommitAll()
		@ nLin ,000 PSAY " "
		//      @ nLin ,004 PSAY "*"
		//      @ nLin ,022 PSAY "."
		#IFNDEF WINDOWS
			Set Device to Screen
			DrawAdvWindow(" Formulario ",10,25,14,56)
			SetColor(cCor)
			@ 12,27 Say "Formulario esta posicionado?"
			nOpc:=Menuh({"Sim","Nao","Cancela Impressao"},14,26,"b/w,w+/n,r/w","SNC","",1)
			Set Device to Print
		#ELSE
			IF MsgYesNo("Fomulario esta posicionado ? ")
				nOpc := 1
			ElseIF MsgYesNo("Tenta Novamente ? ")
				nOpc := 2
			Else
				nOpc := 3
			Endif
		#ENDIF
		Do Case
			Case nOpc==1
				lContinua:=.T.
				Exit
			Case nOpc==2
				Loop
			Case nOpc==3
				lContinua:=.F.
				Return
		EndCase
	End
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ IMPDET   ³ Autor ³ Anizio Lucio Ferreira ³ Data ³ 31/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao de Linhas de Detalhe da Nota Fiscal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cisco.prg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function IMPDET()
//nTamDet := 17         // Tamanho da Area de Detalhe
I:=1
J:=1
xB_ICMS_SOL:=0         // Base  do ICMS Solidario
xV_ICMS_SOL:=0         // Valor do ICMS Solidario
_serv :={}
_venda :={}

FOR II := ((nTamDet*(_nContNF-1))+1) to Len(xCOD_PRO)  //(_nContNF*nTamDet)
	
	IF xTIPO=="N"
		//   _cTotmen := mv_par05+mv_par06+mv_par07+mv_par08+mv_par09+mv_par10+mv_par11
		_cTotmen := " "
	ENDIF
	
	If xTipo=="C"
		// cTotmen := mv_par05+mv_par06+mv_par07+mv_par08+mv_par09+mv_par10+mv_par11
		cTotmen := " "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o conteudo das mensagens dos parametros de 05 a 11 for va-³
		//³  zio, trata-se de uma NF de Complemento de Precos. Caso con -³
		//³  trario, trata-se de NF de Complemento de Desp.Alfandegarias.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If Empty(_cTotmen)
			@ nLin+3, 11 PSAY "COMPLEMENTO DE PRECO."
			@ nLin+3, 71 PSAY xTOT_FAT Picture "@E 99,999,999.99"
		Else
			@ nLin+3, 11  PSAY "COMPLEMENTO DE DESPESAS ALFANDEGARIAS,"
			@ nLin+5, 11  PSAY "EXPOSTO NO CAMPO 'DADOS ADICIONAIS'."
		Endif
		RETURN
	ElseIf xTipo=="I"
		@ nLin+3, 11  PSAY "COMPLEMENTO DE I.C.M.S."
		@ nLin+3, 71  PSAY xTOT_FAT   Picture "@E 99,999,999.99"
		RETURN
	ElseIf xTipo=="P"
		@ nLin+3,011  PSAY "COMPLEMENTO DE I.P.I."
		@ nLin+3,115  PSAY xICM_PROD[1]     Picture"99"
		@ nLin+3,125  PSAY xVALOR_IPI   Picture "@E 99,999,999.99"
		RETURN
	Else
		If II <= Len(xCOD_PRO)
			xTexto:=" "
			If mv_par04 == 1
				DBSELECTAREA("SB1")
				DBSETORDER(1)
				DBSEEK(xFilial("SB1")+xCOD_PRO[II])
				xTexto1 :=ALLTRIM(SB1->B1_DESCR01)
				xTexto2 :=ALLTRIM(SB1->B1_DESCR02)
				xTexto  :=xTexto1 +" "+xTexto2
			ELSEIf mv_par04 == 2
				xTexto1 :=ALLTRIM(xDESC1[II])
				xTexto2 :=ALLTRIM(xDESC2[II])
				xTexto3 :=ALLTRIM(xDESC3[II])
				xTexto4 :=ALLTRIM(xDESC4[II])
				xTexto  :=xTexto1 +" "+xTexto2+" "+xTexto3+" "+xTexto4
			ENDIF
			IF EMPTY(XTEXTO)
				xTexto:= ALLTRIM(xDESCRICAO[II])
			ENDIF
			_cServLox:=GETMV("MV_U6SERV")  // mudado hamilton o abaixo dava erro!!!
			//if xTES[II] == "502"
			//	LOOP
			//			elseif xTES[II] == "999" .AND. xTES[II] != "502"
			//_cServLox:=GETMV("MV_U6SERV")
			if (ALLTRIM(xTES[II]) $ _cServLox) //.AND. xTES[II] <> "502"
				AADD(_serv , { xDESC_PRO[II],xVAL_MERC[II],xQTD_PRO[II],xPRE_UNI[II], xISS_ALIQ[II], xISS_BASE[II] })
				LOOP
				//else
				
				//AADD(_venda,{ xCOD_PRO[II],xDESC_PRO[II],xCLAS_FIS[II],xCST[II],;
				//xUNID_PRO[II],xQTD_PRO[II],xPRE_UNI[II],xVAL_MERC[II],;
				//xICM_PROD[II],xIPI[II],xVAL_IPI[II],xTexto })
				//xx := len(_venda)
			endif
			
		ENDIF
		
		if SUBSTR(xCOD_PRO[II],1,5)!="99999"
			@ nLin,001 PSAY xCOD_PRO[II]
		endif
		//		@ nLin,001 PSAY xCOD_PRO[II] //SUBSTR(_venda[II,1],1,9) //cODIGO
		
		IF Len(xtexto) <= 85
			@ nLin,023 PSAY SUBSTR(xTexto,1,85)       //Descricao
			IF EMPTY(xCLAS_FIS[II])
				@ nLin,115 PSAY "9999.99.90" //Classificacao Fiscal
			else
				@ nLin,115 PSAY xCLAS_FIS[II] //_venda[II,3]    //Classificacao Fiscal
			endif
			@ nLin,128 PSAY xCST[II]                                    //  - CST
			@ nLin,136 PSAY xUNID_PRO[II]                               // UNIDADE
			@ nLin,140 PSAY xQTD_PRO[II]      Picture"@E 999,999"       // QTD.
			@ nLin,151 PSAY xPRE_UNI[II]      Picture"@E 99,999,999.99" // PR.UNIT.
			@ nLin,169 PSAY xVAL_MERC[II]     Picture"@E 99,999,999.99" // PR.TOTAL
			@ nLin,185 PSAY xICM_PROD[II]     Picture"99.9"             // ALIQ ICMS
			@ nLin,190 PSAY xIPI[II]          Picture"99.9"             // ALIQ IPI
			@ nLin,193 PSAY xVAL_IPI[II]      Picture"@E 9,999,999.99"  // VALOR IPI
			nLin :=nLin+1
		ElseIf Len(xtexto) <= 170
			@ nLin,023 PSAY SUBSTR(xTexto,1,85)       //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,86,85)     //Descricao
			IF EMPTY(xCLAS_FIS[II])
				@ nLin,115 PSAY "9999.99.90" //Classificacao Fiscal
			else
				@ nLin,115 PSAY xCLAS_FIS[II] //_venda[II,3]    //Classificacao Fiscal
			endif
			@ nLin,128 PSAY xCST[II]                                    //  - CST
			@ nLin,136 PSAY xUNID_PRO[II]                               // UNIDADE
			@ nLin,140 PSAY xQTD_PRO[II]      Picture"@E 999,999"       // QTD.
			@ nLin,151 PSAY xPRE_UNI[II]      Picture"@E 99,999,999.99" // PR.UNIT.
			@ nLin,169 PSAY xVAL_MERC[II]     Picture"@E 99,999,999.99" // PR.TOTAL
			@ nLin,185 PSAY xICM_PROD[II]     Picture"99"               // ALIQ ICMS
			@ nLin,190 PSAY xIPI[II]          Picture"99"               // ALIQ IPI
			@ nLin,193 PSAY xVAL_IPI[II]      Picture"@E 9,999,999.99"  // VALOR IPI
			nLin :=nLin+1
		ElseIf Len(xtexto) <= 255
			@ nLin,023 PSAY SUBSTR(xTexto,1,85)       //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,86,85)     //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,171,85)    //Descricao
			IF EMPTY(xCLAS_FIS[II])
				@ nLin,115 PSAY "9999.99.90" //Classificacao Fiscal
			else
				@ nLin,115 PSAY xCLAS_FIS[II] //_venda[II,3]    //Classificacao Fiscal
			endif
			@ nLin,128 PSAY xCST[II]                                    //  - CST
			@ nLin,136 PSAY xUNID_PRO[II]                               // UNIDADE
			@ nLin,140 PSAY xQTD_PRO[II]      Picture"@E 999,999"       // QTD.
			@ nLin,151 PSAY xPRE_UNI[II]      Picture"@E 99,999,999.99" // PR.UNIT.
			@ nLin,169 PSAY xVAL_MERC[II]     Picture"@E 99,999,999.99" // PR.TOTAL
			@ nLin,185 PSAY xICM_PROD[II]     Picture"99"               // ALIQ ICMS
			@ nLin,190 PSAY xIPI[II]          Picture"99"               // ALIQ IPI
			@ nLin,193 PSAY xVAL_IPI[II]      Picture"@E 9,999,999.99"  // VALOR IPI
			nLin :=nLin+1
		ElseIf Len(xtexto) <= 340
			@ nLin,023 PSAY SUBSTR(xTexto,1,85)       //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,86,85)     //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,171,85)    //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,256,85)    //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,341,85)    //Descricao
			nLin:=nLin+1
			IF EMPTY(xCLAS_FIS[II])
				@ nLin,115 PSAY "9999.99.90" //Classificacao Fiscal
			else
				@ nLin,115 PSAY xCLAS_FIS[II] //_venda[II,3]    //Classificacao Fiscal
			endif
			@ nLin,128 PSAY xCST[II]                                    //  - CST
			@ nLin,136 PSAY xUNID_PRO[II]                               // UNIDADE
			@ nLin,140 PSAY xQTD_PRO[II]      Picture"@E 999,999"       // QTD.
			@ nLin,151 PSAY xPRE_UNI[II]      Picture"@E 99,999,999.99" // PR.UNIT.
			@ nLin,169 PSAY xVAL_MERC[II]     Picture"@E 99,999,999.99" // PR.TOTAL
			@ nLin,185 PSAY xICM_PROD[II]     Picture"99"               // ALIQ ICMS
			@ nLin,190 PSAY xIPI[II]          Picture"99"               // ALIQ IPI
			@ nLin,193 PSAY xVAL_IPI[II]      Picture"@E 9,999,999.99"  // VALOR IPI
			nLin :=nLin+1
		ElseIf Len(xtexto) <= 425
			@ nLin,023 PSAY SUBSTR(xTexto,1,85)       //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,86,85)     //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,171,85)    //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,256,85)    //Descricao
			IF EMPTY(xCLAS_FIS[II])
				@ nLin,115 PSAY "9999.99.90" //Classificacao Fiscal
			else
				@ nLin,115 PSAY xCLAS_FIS[II] //_venda[II,3]    //Classificacao Fiscal
			endif
			@ nLin,128 PSAY xCST[II]                                    //  - CST
			@ nLin,136 PSAY xUNID_PRO[II]                               // UNIDADE
			@ nLin,140 PSAY xQTD_PRO[II]      Picture"@E 999,999"       // QTD.
			@ nLin,151 PSAY xPRE_UNI[II]      Picture"@E 99,999,999.99" // PR.UNIT.
			@ nLin,169 PSAY xVAL_MERC[II]     Picture"@E 99,999,999.99" // PR.TOTAL
			@ nLin,185 PSAY xICM_PROD[II]     Picture"99"               // ALIQ ICMS
			@ nLin,190 PSAY xIPI[II]          Picture"99"               // ALIQ IPI
			@ nLin,193 PSAY xVAL_IPI[II]      Picture"@E 9,999,999.99"  // VALOR IPI
			nLin :=nLin+1
		ElseIf Len(xtexto) <= 510
			@ nLin,023 PSAY SUBSTR(xTexto,1,85)       //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,86,85)     //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,171,85)    //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,256,85)    //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,341,85)    //Descricao
			nLin:=nLin+1
			@ nLin,023 PSAY SUBSTR(xTexto,426,85)    //Descricao
			IF EMPTY(xCLAS_FIS[II])
				@ nLin,115 PSAY "9999.99.90" //Classificacao Fiscal
			else
				@ nLin,115 PSAY xCLAS_FIS[II] //_venda[II,3]    //Classificacao Fiscal
			endif
			@ nLin,128 PSAY xCST[II]                                    //  - CST
			@ nLin,136 PSAY xUNID_PRO[II]                               // UNIDADE
			@ nLin,140 PSAY xQTD_PRO[II]      Picture"@E 999,999"       // QTD.
			@ nLin,151 PSAY xPRE_UNI[II]      Picture"@E 99,999,999.99" // PR.UNIT.
			@ nLin,169 PSAY xVAL_MERC[II]     Picture"@E 99,999,999.99" // PR.TOTAL
			@ nLin,185 PSAY xICM_PROD[II]     Picture"99"               // ALIQ ICMS
			@ nLin,190 PSAY xIPI[II]          Picture"99"               // ALIQ IPI
			@ nLin,193 PSAY xVAL_IPI[II]      Picture"@E 9,999,999.99"  // VALOR IPI
			nLin :=nLin+1
		Endif
		
		//Next I
		
	EndIf
NEXT II

nLin := 42    //Linha Inicio dados de Servicos
For I:=1 to Len(_serv)
	@ nLin, 023 PSAY substr(_serv[I,1],1,100)
	
	/*	if Len(alltrim(_serv[I,1])) > 099
	nLin := nLin + 1
	@ nLin, 023 PSAY substr(_serv[I,1],100,100)
	endif
	*/
	@ nLin, 144  PSAY "2828"
	@ nLin, 155  PSAY Alltrim(Str(_serv[I,5]))
	@ nLin, 160  PSAY _serv[I,2] * (_serv[I,5]/100)  Picture "@E 99,999.99"
	@ nLin, 172 PSAY _serv[I,2]                      Picture "@E 99,999,999.99"  //_serv[II,4]
	@ nLin, 186 PSAY _serv[I,2]                      Picture "@E 99,999,999.99"
	nLin := nLin + 1
Next
if Len(_serv) > 1
	@ nLin, 144  PSAY "TOTAL ISS"
	@ nLin, 155  PSAY Alltrim(Str(_serv[I,5]))
	@ nLin, 160  PSAY xBASEISS * (_serv[I,5]/100)    Picture "@E 99,999.99"
	@ nLin, 172  PSAY xBASEISS                       Picture "@E 99,999,999.99"  //_serv[II,4]
	@ nLin, 186  PSAY xBASEISS                       Picture "@E 99,999,999.99"
	nLin := nLin + 1
endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ IMPMENP  ³ Autor ³ Anizio Lucio Ferreira ³ Data ³ 30/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao Mensagem Padrao da Nota Fiscal                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cisco.prg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Inicio da Funcao    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 22/08/01 ==>    Function IMPMENP
Static Function IMPMENP()
nCol:= 05
If !Empty(xCOD_MENS)
@ nLin, NCol PSAY FORMULA(xCOD_MENS)
Endif
Return
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Fim da Funcao       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MENSOBS  ³ Autor ³ Anizio Lucio Ferreira ³ Data ³ 31/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao Mensagem no Campo Observacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cisco.prg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// Substituido pelo assistente de conversao do AP5 IDE em 22/08/01 ==> Function MENSOBS
Static Function MENSOBS()
nTamObs:=050
nCol:=030
@ nLin, nCol PSAY UPPER(SUBSTR(xMENSAGEM,1,nTamObs))
nlin:=nlin+1
@ nLin, nCol PSAY UPPER(SUBSTR(xMENSAGEM,131,nTamObs))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MENSOBS1 ³ Autor ³ Anizio Lucio Ferreira ³ Data ³ 31/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao Mensagem no Campo Dados Adic. Inf.Esquerdo       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cisco.prg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/01 ==> Function OBS1
Static Function OBS1()
nTamObs:=169  //200
cObs1 := UPPER(SUBSTR(xMENSOBS,1,42))
cObs2 := UPPER(SUBSTR(xMENSOBS,43,42))
cObs3 := UPPER(SUBSTR(xMENSOBS,85,42))
cObs4 := UPPER(SUBSTR(xMENSOBS,127,42))
Return


// *****************************************
// *****************************************

Static Function DUPLIC()
aContrato:={"","","",""}
aContrato[1]:="O comprador declara concordar que o presente pedido de com-"
aContrato[2]:="pra esta sujeito as - CONDIÇÕES GERAIS DE VENDA DA INTRALOX"
aContrato[3]:="BRASIL LTDA - devidamente registrada sob o no.6953440, no 3"
aContrato[4]:="Cart.Reg.Titulos e Doc.,a Rua XV de Novembro,80-São Paulo/SP."

@ nLin, 000 PSAY CHR(15)      // Compressão da Fonte
//nCol := 06858
nAjuste := 0
h1:=nlin-1  //ajuste
h2:=1
For BB:= 1 to Len(xVALOR_DUP)
	// AJUSTE COLOCADO AQUI PARA NAO INCREMENTAR ERRADO NA SAIDA PARA VALIDACAO MENSAGEM
	If nAjuste >= 39
		nLin    := nLin + 1
		nAjuste := 0
	Endif
	
	if h1 <> nlin
		@ nLin, 001 psay aContrato[h2]
		h1:=nlin
		h2++
	endif
	If xDUPLICATAS==.T. .and. BB<=Len(xVALOR_DUP)
		// @ nLin, nCol            PSAY xNUM_DUPLIC + " " + xPARC_DUP[BB]
		@ nLin, nCol + nAjuste      PSAY xVENC_DUP[BB]                             // ANTES nCol +10
		@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[BB] Picture("@E 9,999,999.99") // ANTES nCol +10
		IF BB=1
			@ nLin, 135 PSAY xCob_Cli    //  ENDEREÇO COBRANÇA
		ENDIF
		
		nAjuste := nAjuste + 33
	Endif
next
IF H2>1
	NLIN++
ENDIF

IF LEN(xValor_dup)=0  // sem dulicata
	// imprime o vetor todo aqui
	@ nLin, 001 psay aContrato[1]
	@ nLin, 135 PSAY xCob_Cli    //  ENDEREÇO COBRANÇA
	@ ++nLin, 001 psay aContrato[2]
	@ ++nLin, 001 psay aContrato[3]
	@ ++nLin, 001 psay aContrato[4]
else
	
	for cc:=h2 to 4
		@ nLin, 001 psay aContrato[cc]
		NLIN++
	next
endif
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ IMPRIME  ³ Autor ³ Anizio Lucio Ferreira ³ Data ³ 31/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime a Nota Fiscal de Entrada e de Saida                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ cisco.prg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/01 ==> Function Imprime
Static Function Imprime()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              IMPRESSAO DA N.F. DA Nfiscal                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho da N.F.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Definindo Qtd. de NF's a serem impressas para o Pedido Atual
nTamDet  := 17            // Tamanho da Area de Detalhe
_nQtdNF  := Len(xCOD_PRO) / nTamDet
_nQtdNF  := IIf(_nQtdNF > Int(_nQtdNF),Int(_nQtdNF)+1,_nQtdNF)

For _nContNF := 1 to _nQtdNF
	
	@ 00, 000 PSAY Chr(15)                     // Compressao de Impressao
	If mv_par04 == 2
		@ 01, 012 PSAY xPED_CLI[1]    //Numero do Pedido do Cliente
	endif
	If mv_par04 == 1
		@ 02, 176 PSAY "X"
	Else
		@ 02, 015 PSAY xNUM_SC5   //Numero do Nosso Pedido
		@ 02, 159 PSAY "X"
	Endif
	@ 02, 199 PSAY xNUM_NF                     // Numero da Nota Fiscal
	
	//-----------------------------------------------------------------------------
	// dados do estabelecimento emitente
	//-----------------------------------------------------------------------------
	IF !EMPTY(xMENSIMP)
		@ 03,001 PSAY substr(xmensimp,1,60)
	ENDIF
	if ! empty(xmensIMP) .and. len(xmensIMP) > 60
		@ 04,001 PSAY substr(xmensIMP,61,60)
	endif
	//if ! empty(xmens_tes)
	if ! empty(xMensTes)
		//@ 05,001 PSAY substr(xmens_tes,1,60)
		@ 05,001 PSAY ALLTRIM(substr(xMensTes,1,60))
	endif
	//if ! empty(xmens_tes) .and. len(xmens_tes) > 60
	if ! empty(xMensTes) .and. len(xMensTes) > 60
		//@ 06,001 PSAY substr(xmens_tes,61,60)
		@ 06,001 PSAY ALLTRIM(substr(xMensTes,61,60))
	endif
//jOSÉ


	IF MV_PAR04 == 2
		FOR Y:=1 TO Len(xCOD_PRO)
			IF Y == 1
				@ 06,065 PSAY xNATUREZA[1]		
	   	ENDIF
			if  Y > 1 .and. xNATUREZA[1] <> xNATUREZA[Y]
				@ 06,086 PSAY "/"   
   			@ 06,088 PSAY xNATUREZA[Y]
         	y := Len(xCOD_PRO)
			endif					
		
	   next
   ELSE
		@ 06,070 PSAY xNATUREZA            // Texto da Natureza de Operacao
   ENDIF
	//_nCol:=113
	_nCFOS:=0
	_aCFOS:={}
	
	FOR Y:=1 TO Len(xCOD_PRO)
		If Ascan(_aCFOS,alltrim(xCF[Y]))==0
			AADD(_aCFOS, alltrim(xCF[Y]))
			//_nCFOS++
		Endif
	next
	@ 06,112 PSAY " " // ajusta carro impressao
	
	FOR Y:=1 TO Len(_aCFOS)
		if y <>1 .and. len(_aCFOS)>=y
			@ 06,pcol()+1 PSAY "/"      // Codigo da Natureza de Operacao
		endif
		@ 06,pcol()+1 PSAY _aCFOS[y]      // Codigo da Natureza de Operacao
		
		//		@ 06,pcol()+1 PSAY _aCFOS[y]      // Codigo da Natureza de Operacao
	next
	_OK:=.F.
	//if ! empty(xmens_tes) .and. len(xmens_tes) > 120
	if ! empty(xMensTes) .and. len(xMensTes) > 120
		//@ 07,001 PSAY substr(xmens_tes,121,60)
		@ 07,001 PSAY ALLTRIM(substr(xMensTes,121,60))
	endif
	
	if ! empty(xmens_ped)
		@ 08,001 PSAY substr(xmens_ped,1,60)
	endif
	
	if ! empty(xmens_ped) .and. len(xmens_ped) > 60
		@ 09,001 PSAY substr(xmens_ped,61,60)
	endif
	
	//-----------------------------------------------------------------------------
	// Impressao dos Dados do Cliente
	//-----------------------------------------------------------------------------
	@ 09, 067 PSAY xNOME_CLI              //Nome do Cliente
	If !EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
		@ 09, 159 PSAY xCGC_CLI      Picture"@R 99.999.999/9999-99"
	Else
		@ 09, 159 PSAY " "                // Caso seja vazioEndif
	Endif
	@ 09, 194 PSAY xEMISSAO              // Data da Emissao do Documento
	
	if ! empty(xmens_ped) .and. len(xmens_ped) > 120
		@ 10,001 PSAY substr(xmens_ped,121,60)
	endif
	
	if ! empty(xmens_ped) .and. len(xmens_ped) > 180
		@ 11,001 PSAY substr(xmens_ped,181,60)
	endif
	@ 11, 067 PSAY xEND_CLI                            // Endereco
	@ 11, 145 PSAY xBAIRRO                             // Bairro
	@ 11, 172 PSAY xCEP_CLI Picture"@R 99999-999"      // CEP
	//@ 11, 187 PSAY left(mv_par05,AT(" ",mv_par05))   // Reservado  p/Data Saida/Entrada
	
	if ! empty(xmens_ped) .and. len(xmens_ped) > 240
		@ 12,001 PSAY substr(xmens_ped,241,60)
	endif
	
	@ 13, 001 PSAY UPPER(SUBSTR(xMENSAGEM,01,60))      // Mensagem da Nota digitada no pedido
	@ 13, 067 PSAY xMUN_CLI                            // Municipio
	@ 13, 115 PSAY xTEL_CLI                            // Telefone/FAX
	@ 13, 149 PSAY xEST_CLI                            // U.F.
	IF Empty(xINSC_CLI)
		@ 13, 162 PSAY "ISENTO"                            // Insc. Estadual
	Else
		@ 13, 162 PSAY xINSC_CLI                           // Insc. Estadual
	EndIf
	
	@ 14, 001 PSAY UPPER(SUBSTR(xMENSAGEM,61,60))      // Mensagem da Nota digitada no pedido
	//VERIFICA SE VAZIO PARA NAO ESTOURAR A MENSAGEM QUE VAI IMPRIMIR JUNTO COM A FUNCAO
	//ABAIXO DUPLIC
	LLFF:=EMPTY(SUBSTR(xMENSAGEM,121,60))
	IF !LLFF  //TEM DADOS
		@ 15, 001 PSAY UPPER(SUBSTR(xMENSAGEM,121,60))     // Mensagem da Nota digitada no pedido
	ENDIF
	
	If mv_par04 == 2
		IF !LLFF  //ESTÁ EM BRANCO
			nLin:=16
		ELSE
			nLin:=15
		ENDIF
		BB:=1
		nCol := 069            //  duplicatas
		//DUPLIC()  mudado para teste
		DUPLIC1()  // NOVA ROTINA
	Endif
	
	nLin := 22
	ImpDet()                 // Detalhe da NF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo dos Impostos                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _nContNF == _nQtdNF  //.AND. xTipo <> "C"     // Esta emitindo a £ltima NF
		If xTipo == "I"
			@ 48, 045  PSAY xVALOR_ICMS     Picture "@E@Z 999,999,999.99"  // Valor do ICMS
		 //@ 50, 140  PSAY xTOT_FAT        Picture "@E@Z 999,999,999.99"  // Valor Total NF -- Alteração Chamado: 5570
		ElseIf xTipo == "P"
			@ 48, 015  PSAY xBASE_ICMS      Picture "@E@Z 999,999,999.99"  // Base do ICMS
			@ 48, 035  PSAY xVALOR_ICMS     Picture "@E@Z 999,999,999.99"  // Valor do ICMS
			@ 50, 110  PSAY xVALOR_IPI      Picture "@E@Z 999,999,999.99"  // Valor IPI
			@ 50, 140  PSAY xTOT_FAT        Picture "@E@Z 999,999,999.99"  // Valor Total NF
		Else
			@ 48, 006  PSAY xBASE_ICMS      Picture "@E   999,999,999.99"  // Base do ICMS
			@ 48, 035  PSAY xVALOR_ICMS     Picture "@E   999,999,999.99"  // Valor do ICMS
			@ 48, 065  PSAY xBSICMRET       Picture "@E@Z 999,999,999.99"  // Base ICMS Ret.
			@ 48, 091  PSAY xICMS_RET       Picture "@E@Z 999,999,999.99"  // Valor  ICMS Ret.
			@ 48, 124  PSAY xVALOR_MERC     Picture "@E   999,999,999.99"  // Valor Tot. Prod.
			@ 50, 006  PSAY xFRETE          Picture "@E@Z 999,999,999.99"  // Valor do Frete
			@ 50, 035  PSAY xSEGURO         Picture "@E@Z 999,999,999.99"  // Valor Seguro
			@ 50, 055  PSAY nDespesa        Picture "@E   999,999,999.99"  // Valor Despesa
			@ 50, 075  PSAY xVALOR_IPI      Picture "@E   999,999,999.99"  // Valor do IPI
			@ 50, 124  PSAY xTOT_FAT        Picture "@E   999,999,999.99"  // Valor Total NF

		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao Dados da Transportadora  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 53, 001  PSAY xNOME_TRANSP                                 // Nome da Transport.
		If xTPFRETE=='C' .or. mv_par04= 1                                             // Frete por conta do
			@ 53, 083 PSAY "1"                                        // Emitente (1)
		Else                                                         //     ou
			@ 53, 083 PSAY "2"                                        // Destinatario (2)
		Endif
		@ 53, 090 PSAY " "                                           // Res. p/Placa do Veiculo
		@ 53, 104 PSAY " "                                           // Res. p/xEST_TRANSP                          // U.F.
		
		If !EMPTY(xCGC_TRANSP)                                       // Se C.G.C. Transportador nao for Vazio
			@ 53,120 PSAY xCGC_TRANSP Picture"@R 99.999.999/9999-99"
		Endif      
		@ 55, 001 PSAY xEND_TRANSP                                   // Endereco Transp.
		@ 55, 085 PSAY xMUN_TRANSP                                   // Municipio
		@ 55, 108 PSAY xEST_TRANSP                                   // U.F.
		@ 55, 130 PSAY " "                                           // Reservado p/Insc. Estad.
		@ 57, 001 PSAY xVOLUME  Picture"@E 999,999.99"              // Quant. Volumes
		@ 57, 027 PSAY xESPECIE Picture"@!"                          // Especie
		@ 57, 050 PSAY " "                                           // Res para Marca
		@ 57, 070 PSAY " "                                           // Res para Numero
		@ 57, 105 PSAY xPESO_BRUTO     Picture"@E@Z 999,999.99"      // Res para Peso Bruto
		@ 57, 125 PSAY xPESO_LIQUID    Picture"@E@Z 999,999.99"      // Res para Peso Liquido
	Else
		If xTipo == "I"
			@ 48, 045  PSAY "******"
			@ 50, 140  PSAY "******"
		ElseIf xTipo == "P"
			@ 48, 015  PSAY "**************"  // Base do ICMS
			@ 48, 035  PSAY "**************"  // Valor do ICMS
			@ 50, 110  PSAY "**************"  // Valor IPI
			@ 50, 140  PSAY "**************"  // Valor Total NF
		ElseIf xTipo == "C"
			@ 48, 006  PSAY xBASE_ICMS      Picture"@E   999,999,999.99"  // Base do ICMS
			@ 48, 035  PSAY xVALOR_ICMS     Picture"@E   999,999,999.99"  // Valor do ICMS
			@ 48, 065  PSAY xBSICMRET       Picture"@E@Z 999,999,999.99"  // Base ICMS Ret.
			@ 48, 091  PSAY xICMS_RET       Picture"@E@Z 999,999,999.99"  // Valor  ICMS Ret.
			@ 48, 124  PSAY xVALOR_MERC     Picture"@E   999,999,999.99"  // Valor Tot. Prod.
			@ 50, 006  PSAY xFRETE          Picture"@E@Z 999,999,999.99"  // Valor do Frete
			@ 50, 035  PSAY xSEGURO         Picture"@E@Z 999,999,999.99"  // Valor Seguro
			@ 50, 091  PSAY xVALOR_IPI      Picture"@E   999,999,999.99"  // Valor do IPI
			@ 50, 124  PSAY xTOT_FAT        Picture"@E   999,999,999.99"  // Valor Total NF
		Else
			@ 48, 001  PSAY "**************"  // Base do ICMS
			@ 48, 030  PSAY "**************"  // Valor do ICMS
			@ 48, 060  PSAY "**************"  // Base ICMS Ret.
			@ 48, 086  PSAY "**************"  // Valor  ICMS Ret.
			@ 48, 119  PSAY "**************"  // Valor Tot. Prod.
			@ 50, 001  PSAY "**************"  // Valor do Frete
			@ 50, 030  PSAY "**************"  // Valor Seguro
			@ 50, 086  PSAY "**************"  // Valor do IPI
			@ 50, 119  PSAY "**************"  // Valor Total NF
			
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao Dados da Transportadora  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 53, 001  PSAY Replicate("*",Len(xNOME_TRANSP))       // Nome da Transport.
		@ 53, 081 PSAY "*"                                     // Emitente (1)
		
		@ 53, 090 PSAY " "                                     // Res. p/Placa do Veiculo
		@ 53, 104 PSAY " "                                     // Res. p/xEST_TRANSP                          // U.F.
		
		@ 53,111 PSAY Replicate("*",Len(xCGC_TRANSP))          // CGC da Transp.
		
		@ 55, 001 PSAY Replicate("*",Len(xEND_TRANSP))         // Endereco Transp.
		@ 55, 085 PSAY Replicate("*",Len(xMUN_TRANSP))         // MunicipioxMUN_TRANSP                                   // Municipio
		@ 55, 110 PSAY Replicate("*",Len(xEST_TRANSP))         // U.F.
		@ 55, 130 PSAY " "                                     // Reservado p/Insc. Estad.
		@ 57, 001 PSAY xVOLUME  Picture "@E 999,999.99"              // Quant. Volumes
		@ 57, 030 PSAY xESPECIE Picture "@!"                          // Especie
		@ 57, 050 PSAY " "                                           // Res para Marca
		@ 57, 070 PSAY " "                                           // Res para Numero
		@ 57, 105 PSAY xPESO_BRUTO     Picture "@E@Z 999,999.99"      // Res para Peso Bruto
		@ 57, 125 PSAY xPESO_LIQUID    Picture "@E@Z 999,999.99"      // Res para Peso Liquido
	
	Endif
	
	@ 61, 195 PSAY xNUM_NF                   // Numero da Nota Fiscal
	@ 66, 000 PSAY chr(18)                   // Descompressao de Impressao
	SetPrc(0,0)                              // (Zera o Formulario)
	if xTipo == "C"
		exit
	endif
NEXT
Return .T.



/////////////////////////////////////////
//  NOVA DUPLICATA + MENSAGEM



Static Function DUPLIC1()
aContrato:={"","","",""}
aContrato[1]:="O comprador declara concordar que o presente pedido de com-"
aContrato[2]:="pra esta sujeito as - CONDIÇÕES GERAIS DE VENDA DA INTRALOX"
aContrato[3]:="BRASIL LTDA - devidamente registrada sob o no.6953440, no 3"
aContrato[4]:="Cart.Reg.Titulos e Doc.,a Rua XV de Novembro,80-São Paulo/SP."

//@ nLin, 000 PSAY CHR(15)      // Compressão da Fonte
//nCol := 06858

// PRIMEIRA MENSAGEM
@ nLin++, 001 psay aContrato[1]

nAjuste := 0
// segunda linha mensagem e 1 e 2 duplica + local cobranca
@ nLin, 001 psay aContrato[2]
IF LEN(xVENC_DUP) >=1
	@ nLin, nCol + nAjuste      PSAY xVENC_DUP[1]
	@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[1] Picture("@E 9,999,999.99")
ENDIF
nAjuste := nAjuste + 33
IF LEN(xVENC_DUP) >=2
	@ nLin, nCol + nAjuste      PSAY xVENC_DUP[2]
	@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[2] Picture("@E 9,999,999.99")
ENDIF
@ nLin, 135 PSAY xCob_Cli    //  ENDEREÇO COBRANÇA
nAjuste := 0

// 3a. linha mensagem e 3 e 4 duplica
nlin++
@ nLin, 001 psay aContrato[3]
IF LEN(xVENC_DUP) >=3
	@ nLin, nCol + nAjuste      PSAY xVENC_DUP[3]
	@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[3] Picture("@E 9,999,999.99")
ENDIF
nAjuste := nAjuste + 33
IF LEN(xVENC_DUP) >=4
	@ nLin, nCol + nAjuste      PSAY xVENC_DUP[4]
	@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[4] Picture("@E 9,999,999.99")
ENDIF
//@ nLin, 135 PSAY xCob_Cli    //  ENDEREÇO COBRANÇA
nAjuste := 0

// 4a. linha mensagem e 5 e 6 duplica
nlin++
@ nLin, 001 psay aContrato[4]
IF LEN(xVENC_DUP) >=5
	@ nLin, nCol + nAjuste      PSAY xVENC_DUP[5]
	@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[5] Picture("@E 9,999,999.99")
ENDIF
nAjuste := nAjuste + 33
IF LEN(xVENC_DUP) >=6
	@ nLin, nCol + nAjuste      PSAY xVENC_DUP[6]
	@ nLin, nCol + 16 + nAjuste PSAY xVALOR_DUP[6] Picture("@E 9,999,999.99")
ENDIF
//@ nLin, 135 PSAY xCob_Cli    //  ENDEREÇO COBRANÇA
nAjuste := 0

return
