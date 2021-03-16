#include "rwmake.ch"
#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

/*
Funcao      : Z4NFAT06
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Nota Fiscal Pryor BPO - CAMPINAS * Servicos   
Autor       : SETOR DE INFORMATICA
Data/Hora   : 24/09/1998 
Revisão	    : Matheus Massarotto
Data/Hora   : 25/07/2012    12:21
Módulo      : Faturamento
*/

*----------------------*
User Function Z4NFAT06()
*----------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("MEX,MBR,TAMANHO,LIMITE,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,WNREL,WMES,XMENIRRF")
SetPrvt("NTAMNF,CSTRING,CPEDANT,NLININI,XNUM_NF,XSERIE")
SetPrvt("XEMISSAO,XTOT_FAT,XLOJA,XFRETE,_VRRET,XSEGURO,XVALOR_ICMS")
SetPrvt("XICMS_RET,XVALOR_IPI,XVALOR_MERC,XNUM_DUPLIC,XCOND_PAG,XPBRUTO")
SetPrvt("XPLIQUI,XTIPO,XESPECIE,XVOLUME,CPEDATU,CITEMATU")
SetPrvt("XPED_VEND,XITEM_PED,XNUM_NFDV,XPREF_DV,XICMS,XCOD_PRO")
SetPrvt("XQTD_PRO,XQTD2_PRO,XPRE_UNI,XPRE_TAB,XPREFIXO,XIPI,XVAL_IPI")
SetPrvt("XDESC,XVAL_DESC,XVAL_MERC,XTES,XCF,XICMSOL")         

SetPrvt("X_VAL_PIS,XVAL_COF,XVAL_CSLL")
SetPrvt("XPCC_PIS,XPCC_COF,XPCC_CSLL")

SetPrvt("XICM_PROD,XTEXTOCST,XMENSTES,XPESO_PRO,XPESO_UNIT,XDESCRICAO")
SetPrvt("XCOMPLEM,XUNID_PRO,XUNID2_PRO,XFATOR_PRO,XCOD_TRIB,XMEN_TRIB")
SetPrvt("XCOD_FIS,XCLAS_FIS,XMEN_POS,XISS,XTIPO_PRO,XLUCRO")
SetPrvt("XCLFISCAL,XPESO_LIQ,I,NPELEM,XPESO_LIQUID,XPED")
SetPrvt("XPESO_BRUTO,XP_LIQ_PED,XCLIENTE,XTIPO_CLI,XCOD_MENS,XMENSAGEM")
SetPrvt("XTPFRETE,XCONDPAG,XCOD_VEND,XDESC_NF,XDESC_PAG,XPED_CLI")
SetPrvt("XLOTE,J,XCOD_CLI,XNOME_CLI,XEND_CLI,XBAIRRO")
SetPrvt("XCEP_CLI,XCOB_CLI,XREC_CLI,XMUN_CLI,XEST_CLI,XCGC_CLI")
SetPrvt("XINSC_CLI,XTRAN_CLI,XTEL_CLI,XFAX_CLI,XIRRF,XSUFRAMA")
SetPrvt("XCALCSUF,ZFRANCA,XVENDEDOR,XBSICMRET,XNATUREZA,XPARC_DUP")
SetPrvt("XVENC_DUP,XVALOR_DUP,XDUPLICATAS,NOPC,CCOR,NTAMDET")
SetPrvt("XB_ICMS_SOL,XV_ICMS_SOL,_CTOTMEN,NCOL,NAJUSTE,BB")

/*
-----------------------------------------------------------------------------
Programa  |  PRYOR    Autor : SETOR DE INFORMATICA  : Data : 24/09/98
----------|------------------------------------------------------------------
Descri‡ao | Nota Fiscal de Servicos para a PRYOR CONSULTING
----------|------------------------------------------------------------------
Uso       | Especifico para PRYOR CONSULTING
-----------------------------------------------------------------------------
Define Variaveis Ambientais
-----------------------------------------------------------------------------
Variaveis utilizadas para parametros
mv_par01             // Da Nota Fiscal
mv_par02             // Ate a Nota Fiscal
mv_par03             // Da Serie
mv_par04             // Nota Fiscal de Entrada/Saida
-----------------------------------------------------------------------------
*/
#IFNDEF WINDOWS

#ENDIF
CbTxt      :=""
CbCont     :=""
nOrdem     :=0
Alfa       :=0
_VRRET     :=0
Z          :=0
M          :=0
MEX        :=0
MBR        :=SPAC(50)
tamanho    :="G"
limite     :=220
titulo     :=PADC("Programa de Impressao de Nota Fiscal - Pryor",74)
cDesc1     :="Este programa ira emitir a Nota Fiscal de Servicos"
cDesc2     :="para a Empresa Pryor Consulting Services"
cDesc3     :=PADC("NF PRYOR",74)
cNatureza  :=""
aReturn    := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog   :="Pryor"
cPerg      :="NFSIGW    "   
nLastKey   := 0
lContinua  := .T.
nLin       :=0
wnrel      := "Z4NFAT06"
wmes       := {'JANEIRO','FEVEREIRO','MARCO','ABRIL','MAIO','JUNHO','JULHO','AGOSTO','SETEMBRO','OUTUBRO','NOVEMBRO','DEZEMBRO'}
xMenIRRF   := "" 
aTitulos   := {}
nTamNf:=72     // Apenas Informativo

Pergunte(cPerg,.F.)               // Pergunta no SX1
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
   RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 12/12/01 ==>    RptStatus({|| Execute(RptDetail)})
   Return
	Static Function RptDetail()
#ENDIF
If mv_par04 == 2
   DbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
   DbSetOrder(1)
   DbSeek(xFilial()+mv_par01+mv_par03,.t.)
   DbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
   DbSetOrder(3)
   DbSeek(xFilial()+mv_par01+mv_par03)
   cPedant := SD2->D2_PEDIDO
Else
   DbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
   DbSetOrder(1)
   DbSeek(xFilial()+mv_par01+mv_par03,.t.)
   DbSelectArea("SD1")                // * Itens da Nota Fiscal de Entrada
   DbSetOrder(3)
Endif

if !u_versm0("Z4")    // VERIFICA EMPRESA
   return
endif



SetRegua(Val(mv_par02)-Val(mv_par01))
If mv_par04 == 2
   DbSelectArea("SF2")
   While !eof() .and. SF2->F2_DOC    >= mv_par01 .and. SF2->F2_DOC <= MV_PAR02 .AND. lContinua
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

      xNUM_NF     :=SF2->F2_DOC             // Numero
      xSERIE      :=SF2->F2_SERIE           // Serie
      xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
      xPREFIXO    :=SF2->F2_PREFIXO
      xTOT_FAT    :=IIF(SF2->F2_TIPO=="P",SF2->F2_VALIPI,SF2->F2_VALFAT )  // Valor Total da Fatura

      if xTOT_FAT == 0
         xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
      endif

      xLOJA        :=SF2->F2_LOJA            // Loja do Cliente
      xFRETE       :=SF2->F2_FRETE           // Frete
      xSEGURO      :=SF2->F2_SEGURO          // Seguro
      xVALOR_ICMS  :=SF2->F2_VALICM          // Valor  do ICMS
      xICMS_RET    :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
      xVALOR_IPI   :=SF2->F2_VALIPI          // Valor  do IPI
      xVALOR_MERC  :=SF2->F2_VALMERC         // Valor  da Mercadoria
      xNUM_DUPLIC  :=SF2->F2_DUPL            // Numero da Duplicata
      xCOND_PAG    :=SF2->F2_COND            // Condicao de Pagamento
      xPBRUTO      :=SF2->F2_PBRUTO          // Peso Bruto
      xPLIQUI      :=SF2->F2_PLIQUI          // Peso Liquido
      xTIPO        :=SF2->F2_TIPO            // Tipo do Pedido
      xESPECIE     :=SF2->F2_ESPECI1         // Especie 1 no Pedido
      xVOLUME      :=SF2->F2_VOLUME1         // Volume 1 no Pedido
      
      xVAL_PIS     :=SF2->F2_VALPIS          // VALOR DO PIS
		xVAL_COF     :=SF2->F2_VALCOFI         // VALOR DO COFINS
      xVAL_CSLL    :=SF2->F2_VALCSLL         // VALOR DA CONTRIB. SOCIAL		
      xINSS        :=SF2->F2_VALINSS
      
      nDesconto    :=SF2->F2_DESCONT
      XPCC_COF     :=XPCC_CSLL:=XPCC_PIS:=0
    
      DbSelectArea("SD2")                   // * Itens de Venda da N.F.
      DbSetOrder(3)
      DbSeek(xFilial()+xNUM_NF+xSERIE)
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
      xTEXTOCST:={}    
      xDesconto:={}
      while !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
         If SD2->D2_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
            DbSkip()                   // do Parametro Informado !!!
            Loop
         Endif
         DbSelectArea("SF4")                   // * Tipos de Entrada e Saida
         DbSetOrder(1)
         DbSeek(xFilial()+SD2->D2_TES)
         xMensTes := FORMULA(SF4->F4_FORMULA)
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
         AADD(xDesconto ,SD2->D2_DESCON)         
         AADD(xTES      ,SD2->D2_TES)
         AADD(xCF       ,SD2->D2_CF)
         AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))

         DbSkip()
      End

      DbSelectArea("SC6")                     // * Itens do pedido de vendas
      DbSetOrder(2)

      DbSelectArea("SB1")                     // * Desc. Generica do Produto
      DbSetOrder(1)
      xPESO_PRO    :={}                       // Peso Liquido
      xPESO_UNIT   :={}                       // Peso Unitario do Produto
      xDESCRICAO   :={}                       // Descricao do Produto
      xCOMPLEM     :={}                       // Descricao do Produto
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
         DbSelectArea("SB1")
         DbSeek(xFilial()+xCOD_PRO[I])
         DbSelectArea("SC6")
         DbSeek(xFilial()+xCOD_PRO[I]+xPED_VEND[I]+xITEM_PED[I])
         AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
         xPESO_LIQ  := xPESO_LIQ + xPESO_PRO[I]
         AADD(xPESO_UNIT , SB1->B1_PESO)
         AADD(xUNID_PRO  , SB1->B1_UM)
         AADD(xUNID2_PRO , SB1->B1_SEGUM)
         AADD(xFATOR_PRO , SB1->B1_CONV)
         AADD(xDESCRICAO , SC6->C6_DESCRI)
         AADD(xCOMPLEM 	 , SC6->C6_DESCRIC)         
         AADD(xCOD_TRIB  , SB1->B1_CLASFIS)
         If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
            AADD(xMEN_TRIB , SB1->B1_CLASFIS)
         Endif
         AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)
         If SB1->B1_ALIQISS > 0
            AADD(xISS ,SB1->B1_ALIQISS)
         Endif
         AADD(xTIPO_PRO ,SB1->B1_TIPO)
         AADD(xLUCRO    ,SB1->B1_PICMRET)
         xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
         For II:=1 to Len(xPESO_PRO)
            xPESO_LIQUID:=xPESO_LIQUID+xPESO_PRO[II]
         Next II
      Next I
      DbSelectArea("SC5")                            // * Pedidos de Venda
      DbSetOrder(1)
      xPED        := {}
      xPESO_BRUTO := 0
      xP_LIQ_PED  := 0
      For I:=1 to Len(xPED_VEND)
         DbSeek(xFilial()+xPED_VEND[I])
         If ASCAN(xPED,xPED_VEND[I])==0
            DbSeek(xFilial()+xPED_VEND[I])
            xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
            xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
            xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
            xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
            xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
            xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
            xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
            xP_LIQ_PED  :=xP_LIQ_PED + SC5->C5_PESOL // Peso Liquido
            xCOD_VEND:= {SC5->C5_VEND1,;             // Codigo do Vendedor 1
                         SC5->C5_VEND2,;             // Codigo do Vendedor 2
                         SC5->C5_VEND3,;             // Codigo do Vendedor 3
                         SC5->C5_VEND4,;             // Codigo do Vendedor 4
                         SC5->C5_VEND5}              // Codigo do Vendedor 5
            xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
                         SC5->C5_DESC2,;             // Desconto Global 2
                         SC5->C5_DESC3,;             // Desconto Global 3
                         SC5->C5_DESC4}              // Desconto Global 4 
            xOBS     :=  SC5->C5_OBS                 // Observação do Pedido de Venda
            AADD(xPED,xPED_VEND[I])
         Endif
         If xP_LIQ_PED >0
            xPESO_LIQ := xP_LIQ_PED
         Endif
      Next
      DbSelectArea("SE4")                    // Condicao de Pagamento
      DbSetOrder(1)
      DbSeek(xFilial("SE4")+xCONDPAG)
      xDESC_PAG := SE4->E4_DESCRI
      DbSelectArea("SC6")                    // * Itens de Pedido de Venda
      DbSetOrder(1)
      xPED_CLI :={}                          // Numero de Pedido
      J:=Len(xPED_VEND)
      For I:=1 to J
         DbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
         AADD(xPED_CLI ,SC6->C6_PEDCLI)
         AADD(xVAL_DESC,SC6->C6_VALDESC)
         AADD(xDESCRICAO , SC6->C6_DESCRI)
         AADD(xCOMPLEM 	 , SC6->C6_DESCRIC)         
      Next
      If xTIPO $ 'NCPISTO'
         DbSelectArea("SA1")                // * Cadastro de Clientes
         DbSetOrder(1)
         DbSeek(xFilial()+xCLIENTE+xLOJA)
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
         xINSM_CLI:=SA1->A1_INSCRM           // Inscricao municipal
         xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
         xTEL_CLI :=SA1->A1_TEL             // Telefone
         xFAX_CLI :=SA1->A1_FAX             // Fax
         xIRRF    :=SE1->E1_IRRF            // Irrf sobre a nota fiscal
         xSUFRAMA :=SA1->A1_SUFRAMA         // Codigo Suframa
         xCALCSUF :=SA1->A1_CALCSUF         // Calcula Suframa
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
         DbSeek(xFilial()+xCLIENTE+xLOJA)
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
         xINSM_CLI:=SA2->A2_INSCRM           // Inscricao MUNICIPAL
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
         DbSeek(xFilial()+xCOD_VEND[I])
         Aadd(xVENDEDOR,SA3->A3_NREDUZ)
      Next
      If xICMS_RET >0                          // Apenas se ICMS Retido > 0
         DbSelectArea("SF3")                   // * Cadastro de Livros Fiscais
         DbSetOrder(4)
         DbSeek(xFilial()+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
         If Found()
            xBSICMRET:=F3_VALOBSE
         Else
            xBSICMRET:=0
         Endif
      Else
         xBSICMRET:=0
      Endif
      DbSelectArea("SF4")                   // * Tipos de Entrada e Saida
      DbSetOrder(1)
      DbSeek(xFilial()+xTES[1])
      xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao
      xMensTes := FORMULA(SF4->F4_FORMULA)
      DbSelectArea("SE1")                   // * Contas a Receber
      DbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(DbSeek(xFilial()+xPREFIXO+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
      x_IRRF_DUP :={}                       // irrf
      x_INSS_DUP :={}							  // inss
      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         If SE1->E1_TIPO = 'PI-'
      	   XPCC_PIS += SE1->E1_VALOR
         ELSEIF  SE1->E1_TIPO = 'CF-' 
			   XPCC_COF += SE1->E1_VALOR
         ELSEIF  SE1->E1_TIPO = 'CS-' 
			   XPCC_CSLL += SE1->E1_VALOR
         ENDIF

         If !("NF" $ SE1->E1_TIPO)
            DbSkip()
            Loop
         Endif
   
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         AADD(x_IRRF_DUP,SE1->E1_IRRF)
         AADD(x_INSS_DUP,SE1->E1_INSS)         
         DbSkip()
      EndDo  

	   Imprime()

      IncRegua()                    // Termometro de Impressao
      nLin:=0
      DbSelectArea("SF2")
      DbSkip()                      // passa para a proxima Nota Fiscal
   EndDo
Endif

DbSelectArea("SF2")
Retindex("SF2")
DbSelectArea("SF1")
Retindex("SF1")
DbSelectArea("SD2")
Retindex("SD2")
DbSelectArea("SD1")
Retindex("SD1")
Set Device To Screen   
If aReturn[5] == 1
   Set Printer TO
   DbcommitAll()
   ourspool(wnrel)
Endif
MS_FLUSH()
return
/*
//-----------+-------------------------------------------------------------------------------------
// Funcao    | VERIMP    Autor  SETOR DE INFORMATICA   Data  24/09/99
//-----------|-------------------------------------------------------------------------------------
// Descricao | Verifica posicionamento de papel na Impressora
//-----------|-------------------------------------------------------------------------------------
// Uso       | pryor.prg
//-----------+-------------------------------------------------------------------------------------
*/

Static Function VerImp()
nLin:= 0                // Contador de Linhas
nCol:= 0                // Contador de Colunas
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
      @ nLin ,004 PSAY " "
      @ nLin ,022 PSAY " "
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

/*
//-----------+-------------------------------------------------------------------------------------
// Funcao    | IMPDET    Autor  SETOR DE INFORMATICA   Data  24/09/99
//-----------|-------------------------------------------------------------------------------------
// Descricao | Impressao de Linhas de Detalhe da Nota Fiscal
//-----------|-------------------------------------------------------------------------------------
// Uso       | pryor.prg
//-----------+-------------------------------------------------------------------------------------
*/

Static Function IMPDET()
nTamDet := len(xCOD_PRO)  //05 //11         // Tamanho da Area de Detalhe
I:=1
J:=1
xB_ICMS_SOL:=0         // Base  do ICMS Solidario
xV_ICMS_SOL:=0         // Valor do ICMS Solidario

IF xTIPO=="N"
   _cTotmen := " "
ENDIF

/*
------------------------------------------------------------
IMPRESSAO DOS ITENS DA NOTA
------------------------------------------------------------
*/ 

_VRRET := xPCC_PIS + xPCC_COF + xPCC_CSLL + x_IRRF_DUP[1] + xINSS       

For I:=1 to nTamDet
    nCol:= LEN(xCOD_PRO[I])+LEN(xDESCRICAO[I])+13
    @ nLin,013 PSAY ALLTRIM(xCOD_PRO[I])
    @ nLin,023 PSAY ALLTRIM(xDESCRICAO[I])
    if ! empty(xCOMPLEM[I])
       @ nLin,nCol PSAY ALLTRIM(xCOMPLEM[I])
    endif
    @ nLin,110 PSAY xVAL_MERC[I]+xDesconto[I] picture "@E 999,999,999.99"
    nLin :=nLin+2   
    
    If  _VRRET > 0 .And. I=4 .Or. I=8 .Or. I=12 .Or. I=16 
       ImpCab()
    EndIf     
    
Next          
                      

IF LEN(x_IRRF_DUP)=0  // VAZIO?
   AADD(x_IRRF_DUP,0)  //ADICIONA COM VALOR ZERO, SOMENTE PARA MEXER NOS CODIGOS ABAIXO
ENDIF   

If nDesconto > 0
   @ nLin,015 Psay "DESCONTO "
   @ nLin,110 Psay nDesconto Picture "@E 999,999,999.99"
   nLin +=2
 Endif
//_VRRET := xPCC_PIS + xPCC_COF + xPCC_CSLL + x_IRRF_DUP[1] + xINSS


iF _VRRET > 0
	   @ nLin,002 Psay "ATENCAO: Reter 4,65% referente PIS/COFINS/CSLL ,somando os pagamentos dentro do mes para o mesmo prestador do servico e sendo"
      @ nLin+=1,002 Psay "este valor superior a R$ 5.000,00 conforme Lei 10.925/04 (A responsabilidade pela retencao e do contratante do servico)."
      nLin +=1
      IF XPCC_PIS > 0
	      @ nLin, 029  PSAY "VALOR DO PIS 0,65%"
         @ nLin, 063  PSAY XPCC_PIS   Picture"@E 9,999,999.99"
	      nLin :=nLin+1
      ENDIF
	   If xPCC_COF > 0
	      @ nLin, 029  PSAY "VALOR DO COFINS 3,0%"
	      @ nLin, 063  PSAY xPCC_COF   Picture"@E 9,999,999.99"
	      nLin :=nLin+1
	   Endif
	   If xPCC_CSLL > 0
	      @ nLin, 029  PSAY "VALOR DA CONTR. SOCIAL 1,0%"
	      @ nLin, 063  PSAY xPCC_CSLL   Picture "@E 9,999,999.99"
	      nLin :=nLin+1
	   Endif
	   If x_IRRF_DUP[1] # 0.00
	      @ nLin, 029  PSAY "VALOR DO I.R.R.F. "+ "1,5%"//If(xINSS # 0.00,"1,0%","1,5%")
	      @ nLin, 063  PSAY x_IRRF_DUP[1]   Picture "@E 9,999,999.99"
	      nLin :=nLin+1
	   Endif
	   If xINSS # 0.00
	      @ nLin, 029  PSAY "VALOR DO I.N.S.S 11,0%"
	      @ nLin, 063  PSAY xINSS   Picture "@E 9,999,999.99"
	      nLin :=nLin+1
	   Endif
	   
	   @ nLin, 029  PSAY "TOTAL A RETER:         "
	   @ nLin, 063  PSAY _VRRET   Picture"@E 9,999,999.99"
	   nLin :=nLin+2
	   @ nLin, 029  PSAY "VALOR LIQUIDO:         "
	   @ nLin, 063  PSAY (xtot_FAT - _VRRET)   Picture"@E 9,999,999.99"
	   nLin :=nLin+2
	   
Endif  
@ 41,023 PSAY "OBS: " + xOBS //Obs da Nota
@ 41,110 PSAY xtot_FAT   picture "@E 999,999,999.99"  // total da Nota Fiscal

Return

/*
//-----------+-------------------------------------------------------------------------------------
// Funcao    | DUPLIC   Autor  SETOR DE INFORMATICA   Data  24/09/99
//-----------|-------------------------------------------------------------------------------------
// Descricao | Imprime a Condicao de Pagamento  
//-----------|-------------------------------------------------------------------------------------
// Uso       | pryor.prg
//-----------+-------------------------------------------------------------------------------------
*/

Static Function DUPLIC()
  nCol := 075   
  nAjuste := 0
 For BB:= 1 to Len(xVALOR_DUP)
     If xDUPLICATAS==.T. .and. BB<=Len(xVALOR_DUP)
        @ nLin, nCol + 10       PSAY xVENC_DUP[BB]
        nAjuste := nAjuste + 50 
     Endif
     If nAjuste >= 099
        nLin    := nLin + 1
        nAjuste := 0
     Endif  
 Next
 Return

/*
//-----------+-------------------------------------------------------------------------------------
// Funcao    | IMPRIME   Autor  SETOR DE INFORMATICA   Data  24/09/99
//-----------|-------------------------------------------------------------------------------------
// Descricao | Imprime a Nota Fiscal de Entrada e de Saida
//-----------|-------------------------------------------------------------------------------------
// Uso       | pryor.prg
//-----------+-------------------------------------------------------------------------------------
*/
Static Function Imprime()

@ 00, 000 PSAY Chr(15)                        // Compressao de Impressao
@ 08,085 PSAY "PRESTACAO DE SERVICOS"         // Texto da Natureza de Operacao

@ 09,085 PSAY day(xEMISSAO) pictURE '99'     // Dia da Emissao do Documento
@ 09,090 PSAY wmes[month(xEMISSAO)]       // Dia da Emissao do Documento
@ 09,105 PSAY year(xEMISSAO)     // Ano da Emissao do Documento

@  14,015 PSAY xNOME_CLI              //Nome do Cliente
@  15,015 PSAY xEND_CLI               // Endereco
@  16,015 PSAY xMUN_CLI               // Municipio
@  16,075 PSAY xEST_CLI               // U.F.
If ! EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
   @ 17,015 PSAY xCGC_CLI    Picture"@R 99.999.999/9999-99"
Endif
IF Empty(xINSC_CLI)
   @ 17,075 PSAY "ISENTO"             // Insc. Estadual
Else
   @ 17,075 PSAY xINSC_CLI            // Insc. Estadual
EndIf

IF !EMPTY(xINSM_CLI)
   @ 18,015 PSAY xINSM_CLI            // Insc. MUNICIPAL
ENDIF

nlin:=018
DUPLIC()

nLin := 24
ImpDet()                 // Detalhe da NF

@ 51, 000 PSAY " "
SetPrc(0,0)                              // (Zera o Formulario)
Return .T.     

Static Function ImpCab()

@ 00, 000 PSAY Chr(15)                        // Compressao de Impressao
@ 08,085 PSAY "PRESTACAO DE SERVICOS"         // Texto da Natureza de Operacao

@ 09,085 PSAY day(xEMISSAO) pictURE '99'     // Dia da Emissao do Documento
@ 09,090 PSAY wmes[month(xEMISSAO)]       // Dia da Emissao do Documento
@ 09,105 PSAY year(xEMISSAO)     // Ano da Emissao do Documento

@  14,015 PSAY xNOME_CLI              //Nome do Cliente
@  15,015 PSAY xEND_CLI               // Endereco
@  16,015 PSAY xMUN_CLI               // Municipio
@  16,075 PSAY xEST_CLI               // U.F.
If ! EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
   @ 17,015 PSAY xCGC_CLI    Picture"@R 99.999.999/9999-99"
Endif
IF Empty(xINSC_CLI)
   @ 17,075 PSAY "ISENTO"             // Insc. Estadual
Else
   @ 17,075 PSAY xINSC_CLI            // Insc. Estadual
EndIf

IF !EMPTY(xINSM_CLI)
   @ 18,015 PSAY xINSM_CLI            // Insc. MUNICIPAL
ENDIF

nlin:=018
DUPLIC()

nLin := 24

Return .T.

