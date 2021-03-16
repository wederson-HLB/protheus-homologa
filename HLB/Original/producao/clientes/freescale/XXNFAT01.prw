#Include "topconn.ch"
#Include "rwmake.ch"

/*
Funcao      : 96NFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Freescale Semicondutores - Entrada e Saída    
Autor     	: Wederson L. Santana
Data     	: 22/12/2004 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*-------------------------*
 User Function XXNFAT01()
*-------------------------*

Private cPerg := "NFXX01    "                           

CriaPerg()

If cEmpAnt $ "II/CD/E4/DN/30/Z0/"
   If Pergunte(cPerg,.T.)
      _cDaNota := Mv_Par01
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
   
      fOkProc()
   Endif
Else
    MsgInfo("Especifico Freescale Semicondutores","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf



tamanho  :='G'
limite   :=80
titulo   :="Nota Fiscal - Entrada / Saida - Freescale Semicondutores"
cDesc1   :=' '
cDesc2   :=''
cDesc3   :='Impressao em formulario de 132 colunas.'
aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := 'XXNFAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Freescale Semicondutores")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Freescale Semicondutores")
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
cTipo:=""
DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof().And.cTipo <> "C"

   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F1_FORNECE+SQL->F1_LOJA))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
   
   nLin     :=21
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

   fCabSf1()
	if AllTrim(cTipo)$ "C"
      @ nLin,017 pSay "Complemento de Importação"
      @ nLin,100 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total	
   else
	   While F1_DOC+F1_SERIE == cCompara           
	         SB1->(DbSetOrder(1))
	         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
	         SF4->(DbSetOrder(1))
	         SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
	         @ nLin,000 pSay SB1->B1_COD                               //Código Produto
	         @ nLin,019 pSay SB1->B1_DESC                              //Descrição Produto
	         @ nLin,085 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            //Situação Tributária
	         @ nLin,090 pSay SB1->B1_UM                                //Unidade
	         @ nLin,092 pSay D1_QUANT  Picture "@E@Z 999,999.99"       //Quantidade
	         @ nLin,102 pSay D1_CUSTO  Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
	         @ nLin,115 pSay D1_TOTAL  Picture "@E@Z 999,999,999.99"   //Vlr Total
	         @ nLin,139 pSay Alltrim(str(D1_PICM))
	         @ nLin,142 pSay  Alltrim(str(D1_IPI))
	         @ nLin,144 pSay D1_VALIPI Picture "@E 99,999.99"          //Vlr IPI
				IF VAL(D1_ITEM) == 1
//					IF !EMPTY(D1_OBS)
 //						cMens:= D1_OBS
//					ENDIF	
				ENDIF	
	         IncRegua(F1_SERIE+" "+F1_DOC)   
	         DbSkip()
	         nLin  +=1
	         If nLin == 32
	            @ 068,000 pSay Chr(18)
	            @ 068,002 pSay cNota
	            @ 072,000 pSay ""   
	            SetPrc(0,0)   
	            fCabSf1()
	            nLin :=22
	         Endif
	   End         
	endif
	  
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
   @ 042,000 pSay Chr(27)+"0"
   @ 043,000 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 043,030 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 043,060 pSay nBrIcms  Picture "@E 999,999,999.99" //Base ICMS Subst.
   @ 043,085 pSay nIcmsRet Picture "@E 999,999,999.99" //Vlr  ICMS Subst.
   @ 043,123 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 045,000 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 045,030 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 045,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 045,085 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 045,123 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
  
   @ 055,001 pSay cMensTes     
	
//	IF !EMPTY(cMens)
//		@ 056,001 pSay cMens
//	ENDIF	     		   
 
   @ 072,000 pSay Chr(27)+"2"
   @ 075,000 pSay Chr(18)
   @ 076,080 pSay cNota

   @ 080,000 pSay ""   
   SetPrc(0,0)   
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
   @ 000,000 pSay Chr(18)
   @ 002,069 PSay "X"
   @ 002,080 pSay cNota
   @ 004,000 pSay Chr(18)
   @ 008,001 pSay SF4->F4_TEXTO
   @ 008,043 pSay SF4->F4_CF
   If! AllTrim(cTipo) $ "B/D"
      @ 010,001 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 010,105 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 010,105 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 010,105 pSay SA2->A2_CGC
      Endif   
      @ 010,136 pSay Dtoc(cEMISSAO)
      @ 011,001 pSay SA2->A2_END
      @ 011,080 pSay SA2->A2_BAIRRO
      @ 011,117 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 013,001 pSay SA2->A2_MUN
      @ 013,058 pSay SA2->A2_TEL   
      @ 013,094 pSay SA2->A2_EST
      @ 013,105 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
   Else   
      @ 010,001 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 010,105 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 010,105 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 010,105 pSay SA1->A1_CGC
      Endif   
      @ 010,136 pSay Dtoc(cEMISSAO)
      @ 011,001 pSay SA1->A1_END
      @ 011,080 pSay SA1->A1_BAIRRO
      @ 011,177 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 013,001 pSay SA1->A1_MUN
      @ 013,058 pSay SA1->A1_TEL   
      @ 013,094 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 013,105 pSay "ISENTO" 
      Else      
         @ 013,105 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
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

//   cMensTes := Formula(SF4->F4_FORMULA)
     cMensTes := Formula(SC5->C5_MENPAD) 
   
   
      
   aTit :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ SE1->E1_PREFIXO+SE1->E1_NUM+Space(05)+Dtoc(SE1->E1_VENCREA)+Space(07)+Transform(SE1->E1_VALOR,"@E 9,999,999.99")})
          SE1->(DbSkip())
       EndDo
   Endif    
   cText		:={}  
   aMerc    :={}
   aServ    :={}
   cCompara := F2_DOC+F2_SERIE
   While F2_DOC+F2_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
         SB5->(DbSetOrder(1))
         SB5->(DbSeek(xFilial("SB5")+SQL->D2_COD))
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SC6->C6_DESCRI),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,SB1->B1_DESC+SB5->B5_CEME,SB1->B1_POSIPI,Alltrim(SB1->B1_ORIGEM)+Alltrim(SF4->F4_SITTRIB),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,SC6->C6_DESCRI})
         Endif   

			If Ascan(cText, SF4->F4_TEXTO)==0
				AADD(cText , SF4->F4_TEXTO)
			Endif

         If SA1->A1_EST $ SM0->M0_ESTCOB
            If! SF4->F4_CF $ cCfop
               cCfop += SF4->F4_CF+"/"
            Endif   
         Else                  
            If! "6"+SubStr(SF4->F4_CF,2,3) $ cCfop    
               cCfop += "6"+SubStr(SF4->F4_CF,2,3)+"/"
            Endif   
         Endif

         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         
//   DbSkip(-1)
   
   fCabSf2()
//IMPRIME FATURA   
   i    :=1
   nCol :=0
   nLin :=15

   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol +=46
      If nCol == 138
          nCol :=0
          nLin +=1
      Endif
      i +=1
   End

   nMerc :=1
   nLin  :=21
   nPos  :=1
   nTotSe:= 0
   While nMerc <= Len(aMerc)
         @ nLin,000 pSay aMerc[nMerc][01]                                 //Código Produto
         @ nLin,019 pSay aMerc[nMerc][02]                                 //Descrição Produto
         @ nLin,074 pSay aMerc[nMerc][03]                                 //Classificação Fiscal
         @ nLin,085 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,090 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,092 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,102 pSay aMerc[nMerc][07] Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
         @ nLin,115 pSay aMerc[nMerc][08] Picture "@E@Z 999,999,999.99"   //Vlr Total
         @ nLin,139 pSay Alltrim(STR(aMerc[nMerc][09]))
         @ nLin,142 pSay Alltrim(STR(aMerc[nMerc][10]))
         @ nLin,144 pSay aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI
         nLin  +=1
         If nMerc == 10.And.nMerc <= Len(aMerc)
            i   :=1  
            nLin:=64  
            nPos:=16
            While i <= Len(aMerc)
                 If Len(aMerc[i][03]) > 0.And.nLin <= 70
                    @ nLin,000 pSay aMerc[i][03]
                    nLin += 1
                 Endif
                 i +=1
            End        
			   @ 072,000 pSay Chr(27)+"2"
		   	@ 073,000 pSay Chr(18)
		   	@ 074,002 pSay cNota
			   @ 078,000 pSay ""   
			   SetPrc(0,0)   
            fCabSf2()
            nLin :=22
         Endif       
         nMerc +=1    
   End
   If nValPis+nValCofi+nValCsll > 0
      @ nLin,015 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E@Z 999,999.99")+"/"+Transform(nValCofi,"@E@Z 999,999.99")+"/"+Transform(nValCsll,"@E@Z 999,999.99")
   Endif   
   
   nServ :=1 
   nLin  :=36
   While nServ <= Len(aServ)
         @ nLin,019 pSay SUBSTR(aServ[nServ][1],1,55)
         @ nLin,075 pSay aServ[nServ][2]      
         @ nLin,078 pSay aServ[nServ][3]
         @ nLin,080 pSay aServ[nServ][4] Picture "@E 999,999,999.99"
         @ nLin,098 pSay aServ[nServ][5] Picture "@E 999,999,999.99"   
			nTotSe += aServ[nServ][5]
			IF nLin == 38
			   @ nLin,128 pSay nValIss  Picture "@E@Z 9,999,999.99"
			endif
			IF nLin == 41
			   @ nLin,128 pSay nTotSe  Picture "@E@Z 9,999,999.99"
			endif


         nLin +=1                       
         If nServ == 6.And.nServ <= Len(aServ)
			   @ 072,000 pSay Chr(27)+"2"
            @ 073,000 pSay Chr(18)
            @ 074,080 pSay cNota
            @ 078,000 pSay ""   
            SetPrc(0,0)   

            fCabSf2()
            nLin :=36
         Endif       
      nServ +=1
   End                
	IF nLin < 38 .and. nTotSe > 0
	   @ 037,132 pSay nValIss  Picture "@E@Z 9,999,999.99"
	   @ 041,132 pSay nTotSe  Picture "@E@Z 9,999,999.99"
	endif




//   @ 045,070 pSay nValIss  Picture "@E@Z 9,999,999.99"
//   @ 045,123 pSay nBaseIss Picture "@E@Z 999,999,999.99"
  
   @ 042,000 pSay Chr(27)+"0"
   
   @ 043,000 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 043,030 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 043,123 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 045,000 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 045,030 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 045,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 045,085 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 045,123 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota

//TRANSPORTADORA   
   @ 048,000 pSay SA4->A4_NOME                 
   If SC5->C5_TPFRETE $ "F"
      @ 048,085 PSay "1"
   ElseIf SC5->C5_TPFRETE $ "C"   
      @ 048,085 PSay "2"   
   Endif   
   @ 048,130 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 050,000 pSay SA4->A4_END
   @ 050,080 pSay SA4->A4_MUN
   @ 050,115 pSay SA4->A4_EST
   @ 050,130 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   @ 052,002 pSay SC5->C5_VOLUME1
   @ 052,023 pSay "VOLUME"//SC5->C5_ESPECI1
   @ 052,110 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
   @ 052,130 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"

   @ 055,001 pSay SC5->C5_MENNOTA 
   @ 056,001 pSay cMensTes        
   
   @ 072,000 pSay Chr(27)+"2"
   @ 075,000 pSay Chr(18)
   @ 076,080 pSay cNota
   @ 080,000 pSay ""   
   SetPrc(0,0)   

EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 000,000 pSay Chr(18)
   @ 002,061 PSay "X"
   @ 002,080 pSay cNota
   @ 004,000 pSay Chr(15)
   nCol := 2
	FOR I := 1 TO LEN(cText)
   	IF I == 1
   		@ 008,nCol pSay ALLTRIM(cText[1])
   		nCol+= len(ALLTRIM(cText[1]))
   	ENDIF
   	IF cText[I] <> cText[1]
	   	@ 008,nCol pSay "/"+cText[I]
   	endif
   NEXT


   @ 008,043 pSay cCfop

   If! Alltrim(cTipo) $ "B/D"
       @ 010,001 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 010,105 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 010,105 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,105 pSay SA1->A1_CGC
       Endif   
       @ 010,136 pSay Dtoc(cEMISSAO)
       @ 011,001 pSay SA1->A1_END
       @ 011,080 pSay SA1->A1_BAIRRO
       @ 011,117 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       
       @ 013,001 pSay SA1->A1_MUN
       @ 013,058 pSay SA1->A1_TEL   Picture "@R (99)9999-9999"
       @ 013,094 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 013,105 pSay "ISENTO" 
       Else      
          @ 013,105 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 010,001 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 010,105 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 010,105 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,105 pSay SA2->A2_CGC
       Endif   
       @ 010,136 pSay Dtoc(cEMISSAO)
       @ 011,001 pSay SA2->A2_END
       @ 011,080 pSay SA2->A2_BAIRRO
       @ 011,177 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 013,001 pSay SA2->A2_MUN
       @ 013,058 pSay SA2->A2_TEL   Picture "@R (99)9999-9999"
       @ 013,094 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 013,105 pSay "ISENTO" 
       Else      
          @ 013,105 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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

cTMP := CriaTrab(NIL,.F.)
Copy To &cTMP
dbCloseArea()
dbUseArea(.T.,,cTMP,"SQL",.T.)

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
   
cQuery := "SELECT * " 
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

Static Function CriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                        4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Da  Nota     		","","","mv_ch1","C",06,00,00,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Ate Nota     		","","","mv_ch2","C",06,00,00,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Serie       		   ","","","mv_ch3","C",03,00,00,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Entrada/Saida 		","","","mv_ch4","N",01,00,00,"C","","mv_par04","Entrada","","","","","Saida","","","","","","","","","","","","","","","","","","","","","",""})

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

