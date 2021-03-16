#Include "topconn.ch"
#Include "rwmake.ch"

/*
Funcao      : PRNFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal PetroTechnik - Entrada e Saída    
Autor     	: Tiago Luiz Mendonça  
Data     	: 17/06/2009 
Obs         : FONTE 10 - DRAFT 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*-------------------------*
  User Function PRNFAT01()
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos,cPerg")
                                                     
If cEmpAnt $ "PR"
   cPerg:="NFAT01    "
   fCriaPerg()
   If Pergunte(cPerg,.T.)  
      _cDaNota := Mv_Par01
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04                                           
      fOkProc()
   Endif
Else
    MsgInfo("Especifico PetroTechnik ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()      

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - PetroTechnik"
cDesc1   :=' '
cDesc2   :=''
cDesc3   :='Impressao em formulario de 220 colunas.'
aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
nLin     := 60
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := 'PRNFAT01'
cTipo    := ""                           

wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)

If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
	Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .or. nLastKey == 27
	Return
Endif

If _cTpMov == 1
   fGerSf1()
   RptStatus({|| fImpSF1()},"Nota de Entrada - PetroTechnik")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - PetroTechnik")
Endif   

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

Ms_Flush()

Return

//---------------------------------------------------- Emite Nota Fiscal de Entrada

Static Function fImpSF1()

DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()

   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F1_FORNECE+SQL->F1_LOJA))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
   
   nLin     := 22
   cMensTes := Formula(SF4->F4_FORMULA)
   cNota    := F1_DOC
   cEmissao := F1_EMISSAO
   nValMerc := F1_VALMERC
   nValIpi  := F1_VALIPI
   nValIcm  := F1_VALICM
   nBaseIcm := F1_BASEICM
   nValBrut := F1_VALBRUT
   nDespesa := F1_DESPESA
   nFrete   := F1_FRETE
   nBrIcms  := F1_BRICMS
   nIcmsRet := F1_ICMSRET
   nSeguro  := F1_SEGURO
   cTipo    := F1_TIPO
   cCompara := F1_DOC+F1_SERIE
   MensD1   := D1_OBS

   fCabSf1()
   While F1_DOC+F1_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
 
         @ nLin,002 pSay SB1->B1_COD                               //Código Produto
         @ nLin,018 pSay SB1->B1_DESC                              //Descrição Produto
         @ nLin,058 pSay SB1->B1_POSIPI                            //Classificação fiscal
         @ nLin,071 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            //Situação Tributária
         @ nLin,076 pSay SB1->B1_UM                                //Unidade
         @ nLin,077 pSay D1_QUANT  Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,086 pSay D1_CUSTO  Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
         @ nLin,100 pSay D1_TOTAL  Picture "@E@Z 999,999,999.99"   //Vlr Total
         @ nLin,116 pSay D1_PICM   Picture "@E 99"                 //% ICMS    
         @ nLin,121 pSay D1_IPI    Picture "@E 99"                 //% IPI
         @ nLin,127 pSay D1_VALIPI Picture "@E 99,999.99"          //Vlr IPI
         
         IncRegua(F1_SERIE+" "+F1_DOC)   
         DbSkip()
         nLin  +=1
   End         

   @ 046,000 pSay Chr(27)+"0"
   @ 047,010 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 047,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 047,064 pSay nBrIcms  Picture "@E 999,999,999.99" //Base ICMS Subst.
   @ 047,090 pSay nIcmsRet Picture "@E 999,999,999.99" //Vlr  ICMS Subst.      
   @ 047,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 050,010 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 050,038 pSay nSEGURO  Picture "@E 999,999,'999.99" //Vlr Seguro
   @ 050,064 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 050,090 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 050,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota


   @ 062,002 pSay Substr(MensD1,1,70)
   @ 063,002 pSay Substr(MensD1,71,70)
   @ 064,002 pSay Substr(MensD1,141,70)
   If! Empty(cMensTes)
      @ 065,002 pSay SUBSTR(cMensTes,1,46)
   	  @ 066,002 pSay SUBSTR(cMensTes,47,46)
   ENDIF
   nLin:=69     

   @ 070,000 pSay Chr(27)+"2"
   @ 071,000 pSay Chr(18)
   @ 074,071 pSay cNota
   @ 077,000 pSay ""   
   SetPrc(0,0)  
 
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
@ 000,000 pSay Chr(18)
@ 001,071 pSay cNota
@ 002,057 PSay "X"
@ 005,000 pSay Chr(15)

@ 007,002 pSay SF4->F4_TEXTO
@ 007,042 pSay SF4->F4_CF
 
If! Alltrim(cTipo) $ "B/D"
    @ 010,002 pSay SA2->A2_NOME
    If Len(AllTrim(SA2->A2_CGC)) == 14 
       @ 010,090 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
    ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
       @ 010,090 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
    Else   
       @ 010,090 pSay SA2->A2_CGC
    Endif   
    @ 010,123 pSay Dtoc(cEMISSAO)
    @ 012,002 pSay SA2->A2_END
    @ 012,071 pSay SA2->A2_BAIRRO
    @ 012,105 pSay SA2->A2_CEP   Picture "@R 99.999-999"
    @ 014,002 pSay SA2->A2_MUN
    @ 014,060 pSay SA2->A2_TEL   Picture "@R (99)9999-9999"
    @ 014,082 pSay SA2->A2_EST
    If AllTrim(SA2->A2_INSCR) == "ISENTO" 
       @ 014,101 pSay "ISENTO" 
    Else      
       @ 014,101 pSay SA2->A2_INSCR 
    Endif    
Else
    @ 010,002 pSay SA1->A1_NOME
    If Len(AllTrim(SA1->A1_CGC)) == 14 
       @ 010,090 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
    ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
       @ 010,090 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
    Else   
       @ 010,090 pSay SA1->A1_CGC
    Endif   
    @ 010,123 pSay Dtoc(cEMISSAO)
    @ 012,002 pSay SA1->A1_END
    @ 012,071 pSay SA1->A1_BAIRRO
    @ 012,105 pSay SA1->A1_CEP   Picture "@R 99.999-999"
    @ 014,002 pSay SA1->A1_MUN
    @ 014,060 pSay SA1->A1_TEL   Picture "@R (99)9999-9999"
    @ 014,082 pSay SA1->A1_EST
    If AllTrim(SA1->A1_INSCR) == "ISENTO" 
       @ 014,101 pSay "ISENTO" 
    Else      
       @ 014,101 pSay SA1->A1_INSCR 
    Endif    
Endif    
   
Return

//----------------------------------------------------------- Emite nfs.
Static Function fImpSF2()
DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()

   nBaseIcm := F2_BASEICM
   nValIcm  := F2_VALICM
   nValMerc := F2_VALMERC
   nFrete   := F2_FRETE  
   nSeguro  := F2_SEGURO
   nDespesa := F2_DESPESA
   nValIpi  := F2_VALIPI
   nValBrut := F2_VALBRUT
   cNota    := F2_DOC
   cEmissao := F2_EMISSAO
   nPbruto  := F2_PBRUTO
   nPliqui  := F2_PLIQUI
   nValIss  := F2_VALISS
   nBaseIss := F2_BASEISS
   nValCofi := F2_VALCOFI
   nValCsll := F2_VALCSLL
   nValPis  := F2_VALPIS
   cTipo    := F2_TIPO
   cCfop    := ""
	cMensTes := ""
  				
   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F2_CLIENTE+SQL->F2_LOJA))
   SA4->(DbSetOrder(1))
   SA4->(DbSeek(xFilial("SA4")+SQL->F2_TRANSP))
   SC5->(dbSetOrder(1))
   SC5->(DbSeek(xFilial("SC5")+SQL->D2_PEDIDO))
   
   cMensTes := Formula(SC5->C5_MENPAD)       
   
//FATURA
   aTit :={}
   aVal :={}
   aVen :={}
   XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
   cIrrf		:= xReter := XLIQ := 0  
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          If AllTrim(SE1->E1_TIPO) $ "NF"
          Aadd(aTit,{ (SE1->E1_PREFIXO)+(SE1->E1_NUM)+Space(1)+(SE1->E1_PARCELA)})
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})
          Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
			 ELSEIF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
          ELSEIF SE1->E1_TIPO = 'PI-'
      	   XPCC_PIS += SE1->E1_VALOR
          ELSEIF  SE1->E1_TIPO = 'CF-' 
			   XPCC_COF += SE1->E1_VALOR
          ELSEIF  SE1->E1_TIPO = 'CS-' 
			   XPCC_CSLL += SE1->E1_VALOR
			 ENDIF 
			   xReter  := cIrrf + XPCC_PIS + XPCC_COF + XPCC_CSLL
			   XLIQ    := nVALBRUT - xReter
       SE1->(DbSkip()) 
       EndDo    
   Endif   
   
   cTexto	:=""     
   aMerc    :={}
   aServ    :={}
   cCompara := F2_DOC+F2_SERIE
   While F2_DOC+F2_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB, ;
            SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,ALLTRIM(SC6->C6_DESCRI),D2_ITEM})
         Endif   

         If SA1->A1_EST $ SM0->M0_ESTCOB
            If! SF4->F4_CF $ cCfop
               cCfop += SF4->F4_CF+"/"
               cTexto+= SF4->F4_TEXTO
            Endif   
         ElseIf SQL->F2_EST $ "EX"  // Nota de importação
            If! SF4->F4_CF $ cCfop
               cCfop += SF4->F4_CF+"/"
               cTexto+= SF4->F4_TEXTO
            Endif    
         Else                  
            If! "6"+SubStr(SF4->F4_CF,2,3) $ cCfop    
               cCfop += "6"+SubStr(SF4->F4_CF,2,3)+"/"
               cTexto+= SF4->F4_TEXTO
            Endif   
         Endif

         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         
  
   fCabSf2()
   
//IMPRIME FATURA
   i    :=1
   nCol :=14
   @ 015,000 pSay Chr(27)+"0"
   nLin :=016
   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol +=30
      i +=1
   End
   nLin +=1
   nCol :=14
	i    :=1
	While i <= Len(aVal)
      @ nLin,nCol pSay AllTrim(aVal[i][1])
      nCol +=30
      i +=1        
   End     
   nLin +=1
   nCol :=14
	i    :=1   
   While i <= Len(aVen)
      @ nLin,nCol pSay aVen[i][1]
      nCol +=30
      i +=1
   End

//Imprime Endereço de Cobrança      
	if  !EMPTY(SA1->A1_ENDCOB)
		@ nLin,095 PSAY SA1->A1_ENDCOB
   ENDIF 
   
   nLin +=1 
   @ nLin,000 pSay Chr(27)+"2"

   nMerc :=1
   nLin  :=22
   nPos  :=1
   While nMerc <= Len(aMerc)
         @ nLin,002 pSay aMerc[nMerc][01]                                 //ITEM       
         If Len(aMerc[nMerc][12]) > 35  
            @ nLin,018 pSay Substr(aMerc[nMerc][12],1,35)                                 //Descrição Produto
            nLin++
            @ nLin,018 pSay SubStr(aMerc[nMerc][12],36,35)                                 //Descrição Produto
         Else
            @ nLin,018 pSay aMerc[nMerc][12]                                 //Descrição Produto
         EndIf
         
         @ nLin,058 pSay aMerc[nMerc][03]                                 //Classificação Fiscal
         @ nLin,071 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,077 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,081 pSay aMerc[nMerc][06] //Picture "@E@Z 9999.99"          //Quantidade
         @ nLin,085 pSay aMerc[nMerc][07] Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
         @ nLin,099 pSay aMerc[nMerc][08] Picture "@E@Z 999,999,999.99"   //Vlr Total
         @ nLin,117 pSay aMerc[nMerc][09] Picture "@E 99"                 //% ICMS    
         @ nLin,121 pSay aMerc[nMerc][10] Picture "@E 99"                 //% IPI
         @ nLin,127 pSay aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI
         nLin  +=1
         nMerc +=1    
   End
   If nValPis+nValCofi+nValCsll > 0 .And. Len(aMerc) > 0
      @ nLin,015 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E@Z 999,999.99")+"/"+Transform(nValCofi,"@E@Z 999,999.99")+"/"+Transform(nValCsll,"@E@Z 999,999.99")
   Endif   
  
   nServ :=1
   nLin  :=41
   While nServ <= Len(aServ)
         @ nLin,002 pSay aServ[nServ][1]
         @ nLin,079 pSay aServ[nServ][3] Picture "@E 9999.99"
         @ nLin,090 pSay aServ[nServ][4] Picture "@E 99,999.99"
         @ nLin,104 pSay aServ[nServ][5] Picture "@E 99,999.99"            
         nServ ++
   End
   
   nLin +=2
   
   If XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
	   @ nLin,002 Psay "ATENCAO: Reter 4,65% referente PIS/COFINS/CSLL, caso houver pagamentos dentro do mes para o mesmo prestador de serviço e "
      @ nLin+=1,002 Psay "sendo esse valor acima de R$ 5.000,00 conforme Lei 10.925/04 (A responsabilidade pela retencao e do contratante do servico)."
      @ nLin+=1,002 pSay "Valor do IRRF.: "+Transform(cIrrf,"@E@Z 999,999.99")+" PIS/COFINS/CSLL  "+Transform(XPCC_PIS,"@E@Z 999,999.99")+"/"+Transform(XPCC_COF,"@E@Z 999,999.99")+"/"+Transform(XPCC_CSLL,"@E@Z 999,999.99")
      @ nLin+=1,002 pSay "Total a Reter.: "+Transform(xReter,"@E@Z 999,999.99")+" Valor Liquido: "+Transform(XLIQ,"@E@Z 999,999.99")
   Endif
   IF Len(aServ) > 0 
      @ nLin,120 pSay nVALMERC Picture "@E 999,999,999.99" //Total de Servicos	   
   ENDIF
   @ 045,001 pSay Chr(27)+"0"
   @ 047,010 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 047,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   IF Len(aMerc) > 0                                                           
   @ 047,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   ENDIF
   @ 050,010 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 050,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 050,064 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 050,090 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 050,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
   
   @ 054,002 pSay SA4->A4_NOME                 
   If SC5->C5_TPFRETE $ "F"
      @ 054,084 PSay "1"
   ElseIf SC5->C5_TPFRETE $ "C"   
      @ 054,084 PSay "2"   
   Endif   
   @ 054,115 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 057,002 pSay SA4->A4_END
   @ 057,075 pSay SA4->A4_MUN
   @ 057,105 pSay SA4->A4_EST
   @ 057,115 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   @ 059,006 pSay SC5->C5_VOLUME1
   @ 059,035 pSay SC5->C5_ESPECI1
   @ 059,098 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
   @ 059,117 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"

   @ 064,002 pSay SubStr(SC5->C5_MENNOTA,1,70)         
   @ 065,002 pSay SubStr(SC5->C5_MENNOTA,71,70)   
   @ 066,002 pSay SubStr(SC5->C5_MENNOTA,141,70)      
	If! Empty(cMensTes)
	   @ 067,002 pSay SubStr(cMensTes,1,70)
   	   @ 068,002 pSay SubStr(cMensTes,71,70)
   Endif

   nLin:=69     

   @ 070,000 pSay Chr(27)+"2"
   @ 071,000 pSay Chr(18)
   @ 073,071 pSay cNota
   @ 077,000 pSay ""   
   SetPrc(0,0)   

EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 000,000 pSay Chr(18)
   @ 001,071 pSay cNota
   @ 001,050 PSay "X"
   @ 005,000 pSay Chr(15)

   @ 006,002 pSay cTexto
   @ 006,045 pSay cCfop

   If! Alltrim(cTipo) $ "B/D"
       @ 009,002 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 009,090 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 009,090 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,090 pSay SA1->A1_CGC
       Endif   
       @ 009,123 pSay Dtoc(cEMISSAO)
       @ 011,002 pSay SA1->A1_END
       @ 011,082 pSay SA1->A1_BAIRRO
       @ 011,106 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 013,002 pSay SA1->A1_MUN
       @ 013,060 pSay SA1->A1_TEL   Picture "@R 9999-9999"
       @ 013,082 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 013,101 pSay "ISENTO" 
       Else     
          @ 013,101 pSay SA1->A1_INSCR 
       Endif    
   Else
       @ 009,002 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 009,090 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 009,090 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,090 pSay SA2->A2_CGC
       Endif   
       @ 009,123 pSay Dtoc(cEMISSAO)
       @ 011,002 pSay SA2->A2_END
       @ 011,082 pSay SA2->A2_BAIRRO
       @ 011,106 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 013,002 pSay SA2->A2_MUN
       @ 013,060 pSay SA2->A2_TEL   Picture "@R 9999-9999"
       @ 013,082 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 013,101 pSay "ISENTO" 
       Else      
          @ 013,101 pSay SA2->A2_INSCR 
       Endif    
   Endif    
   
Return

//-----------------------------------------------------------

Static Function fGerSf1()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF1 :={}
aStruSD1 :={}    
aStruSF1:= SF1->(dbStruct())
aStruSD1:= SD1->(dbStruct())
   
cQuery := "SELECT * " 
cQuery += "FROM "+RetSqlName("SF1")+" SF1 , "+RetSqlName("SD1")+" SD1 WHERE "+Chr(10)
cQuery += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "+Chr(10)
cQuery += "SF1.F1_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF1.F1_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF1.F1_DOC+SF1.F1_SERIE = SD1.D1_DOC+SD1.D1_SERIE AND "+Chr(10)
cQuery += "SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF1.F1_DOC "
   
TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","F1_EMISSAO","D",08,0)

For nX := 1 To Len(aStruSF1)
    If aStruSF1[nX,2]<>"C"
 	    TcSetField("SQL",aStruSF1[nX,1],aStruSF1[nX,2],aStruSF1[nX,3],aStruSF1[nX,4])
    EndIf
Next nX

For nX := 1 To Len(aStruSD1)
    If aStruSD1[nX,2]<>"C"
	    TcSetField("SQL",aStruSD1[nX,1],aStruSD1[nX,2],aStruSD1[nX,3],aStruSD1[nX,4])
    EndIf
Next nX

Return

//------------------------------------------------------------------

Static Function fGerSf2()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}               

aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())
   
cQuery := "SELECT D2_TES,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEM,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_EST,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_TES "

TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","F2_EMISSAO","D",08,0)

For nX := 1 To Len(aStruSF2)
    If aStruSF2[nX,2]<>"C"
 	    TcSetField("SQL",aStruSF2[nX,1],aStruSF2[nX,2],aStruSF2[nX,3],aStruSF2[nX,4])
    EndIf
Next nX

For nX := 1 To Len(aStruSD2)
    If aStruSD2[nX,2]<>"C"
	    TcSetField("SQL",aStruSD2[nX,1],aStruSD2[nX,2],aStruSD2[nX,3],aStruSD2[nX,4])
    EndIf
Next nX

Return

//-------------------------------------------------------------

Static Function fCriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                 4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Nota de     	","","","mv_ch1","C",06,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Nota ate     	","","","mv_ch2","C",06,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Serie     		","","","mv_ch3","C",03,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Tipo     		","","","mv_ch4","N",01,00,00,"C","","Mv_Par04","Entrada","","","","","Saida","","","","","","","","","","","","","","","","","","","","","",""})

dbSelectArea("SX1")
For i := 1 to Len(aRegistros)
	If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
		While !RecLock("SX1",.T.)
		End
		For j:=1 to FCount()
			FieldPut(j,aRegistros[i,j])
		Next
		MsUnlock()
	Endif
Next i

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])

Return(Nil)
