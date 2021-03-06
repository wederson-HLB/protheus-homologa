#Include "Topconn.ch"
#Include "Rwmake.ch"

/*
Funcao      : 96NFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal servi?o ADL   
Autor     	: Jos? Ferreira 
Data     	: 
Obs         : 
TDN         : 
Revis?o     : Tiago Luiz Mendon?a 
Data/Hora   : 13/03/2012
M?dulo      : Faturamento.
*/

*-------------------------*
 User Function 96NFAT01()
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
Private cPerg := "NF9601    "
CriaPerg()
If cEmpAnt $ "96/48/"
   If Pergunte(cPerg,.T.)
      _cDaNota := Mv_Par01
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
   
      fOkProc()
   Endif
Else
    MsgInfo("Especifico ADL ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf


tamanho  :='P'
limite   :=80
titulo   :="Nota Fiscal - Entrada / Saida - ADL"
cDesc1   :=' '
cDesc2   :=''
cDesc3   :='Impressao em formulario de 80 colunas.'
aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
nLin     := 60
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := '96NFAT01'
cTipo    := ""

wnrel:=SetPrint(,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)

If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
	Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .or. nLastKey == 27
	Return
Endif

If _cTpMov == 1
   fGerSf1()
   RptStatus({|| fImpSF1()},"Nota de Entrada - ADL")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - ADL")
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
   
   nLin     :=22
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
	If AllTrim(cTipo)$ "C"
      @ nLin,017 pSay "Complemento de Importa??o"
      @ nLin,100 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total	
   Else
	   While F1_DOC+F1_SERIE == cCompara           
	         SB1->(DbSetOrder(1))
	         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
	         SF4->(DbSetOrder(1))
	         SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
	         @ nLin,000 pSay SB1->B1_COD                               //C?digo Produto
	         @ nLin,017 pSay SB1->B1_DESC                              //Descri??o Produto
	         @ nLin,069 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            //Situa??o Tribut?ria
	         @ nLin,077 pSay SB1->B1_UM                                //Unidade
	         @ nLin,078 pSay D1_QUANT  Picture "@E@Z 999,999.99"       //Quantidade
	         @ nLin,088 pSay D1_CUSTO  Picture "@E@Z 99,999,999.99"    //Vlr Unit?rio    
	         @ nLin,100 pSay D1_TOTAL  Picture "@E@Z 999,999,999.99"   //Vlr Total
	         @ nLin,118 pSay D1_PICM   Picture "@E 99.9"               //% ICMS    
	         @ nLin,123 pSay D1_IPI    Picture "@E 99.9"               //% IPI
	         @ nLin,128 pSay D1_VALIPI Picture "@E 99,999.99"          //Vlr IPI
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
	Endif
	  
   @ 047,000 pSay Chr(27)+"0"
   @ 048,000 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 048,030 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 048,060 pSay nBrIcms  Picture "@E 999,999,999.99" //Base ICMS Subst.
   @ 048,080 pSay nIcmsRet Picture "@E 999,999,999.99" //Vlr  ICMS Subst.
   @ 048,123 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 050,000 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 050,030 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 050,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 050,080 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 050,123 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
  
   @ 070,020 pSay cMensTes
 
   @ 071,000 pSay Chr(27)+"2"
   @ 071,000 pSay Chr(18)
   @ 074,002 pSay cNota

   @ 078,000 pSay ""   
   SetPrc(0,0)   
EndDo
Return 

//----------------------------------------------------------- Emite cabe?alho da nfe.

Static Function fCabSf1()
   
   @ 000,000 pSay Chr(18)                         
   @ 020,058 pSay SF4->F4_TEXTO
   @ 021,058 pSay cCfop
   @ 022,058 pSay Dtoc(dDataBase)

   If Alltrim(cTipo) $ "B/D"
       @ 025,010 pSay SA1->A1_NOME
       @ 026,010 pSay SubStr(SA1->A1_END,1,20) //40
       @ 026,041 pSay SubStr(SA1->A1_BAIRRO,1,8)//30       
       If! Empty(SA1->A1_CEP)
           @ 026,050 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       Endif	    
       @ 027,010 pSay SA1->A1_MUN
       @ 027,044 pSay SA1->A1_EST
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 028,010 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 028,010 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       ElseIf! Empty(SA1->A1_CGC)   
          @ 028,010 pSay SA1->A1_CGC
       Endif   
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 028,034 pSay "ISENTO" 
       ElseIf! Empty(SA1->A1_INSCR)      
          @ 028,030 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
       @ 028,055 pSay SA1->A1_INSCRM 
   Else
       @ 025,010 pSay SA2->A2_NOME
       @ 026,010 pSay SA2->A2_END
       @ 026,080 pSay SA2->A2_BAIRRO
       @ 026,050 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 027,010 pSay SA2->A2_MUN
       @ 027,044 pSay SA2->A2_EST
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 028,010 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 028,010 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       ElseIf! Empty(SA2->A2_CGC)   
          @ 028,010 pSay SA2->A2_CGC
       Endif   
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 028,034 pSay "ISENTO" 
       ElseIf! Empty(SA2->A2_INSCR)      
          @ 028,030 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif    
       @ 028,055 pSay SA2->A2_INSCRM 
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
   nValBrut := F2_VALBRUT + F2_DESCONT
   cNota    := F2_DOC
   cEmissao := F2_EMISSAO
   nPbruto  := F2_PBRUTO
   nPliqui  := F2_PLIQUI
   nValIss  := F2_VALISS
   nBaseIss := F2_BASEISS
   nValCofi := F2_VALCOFI
   nValCsll := F2_VALCSLL
   nValPis  := F2_VALPIS
   nDescont := F2_DESCONT
   cTipo    := F2_TIPO
   cCfop    := ""
   
   nPerc    := ((((nValBrut-nDescont)*100)/nValBrut)-100)*-1 //Comiss?o da ag?ncia - percentual
   
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
   SE4->(DbSetOrder(1))
   SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
   cCondPag:= SE4->E4_DESCRI
   cMens		:= Alltrim(SC5->C5_MENNOTA)
   cMensTes := Formula(SC5->C5_MENPAD)       

   XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
   cIrrf		:= 0
	xReter 	:= 0
   aTit :={}
   V:= 1
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
 			IF Alltrim(SE1->E1_TIPO) == 'NF'	
	          Aadd(aTit,{ SE1->E1_PREFIXO+SE1->E1_NUM+Space(1)+SE1->E1_PARCELA+Space(10)+Dtoc(SE1->E1_VENCREA)+Space(13)+Transform(SE1->E1_VALOR-SE1->E1_IRRF,"@E 9,999,999.99")+space(30)})
  	          xReter  := xReter + cIrrf + XPCC_PIS + XPCC_COF + XPCC_CSLL
				 IF V == 1
				 	cVenc := SE1->E1_VENCREA 
				 	 V += 1
				 endif		 
	      EndIf
			 IF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
			 endif	
          IF SE1->E1_TIPO = 'PI-'
      	   XPCC_PIS += SE1->E1_VALOR
  			 endif	
          IF  SE1->E1_TIPO = 'CF-' 
			   XPCC_COF += SE1->E1_VALOR
 			 endif	  
          IF  SE1->E1_TIPO = 'CS-' 
			   XPCC_CSLL += SE1->E1_VALOR
  			 endif  
          SE1->(DbSkip())
       EndDo
   Endif    
     
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
            Aadd(aServ,{SC6->C6_DESCRI,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,SC6->C6_DESCRI,SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,SC6->C6_DESCRI})
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
   
   @ 013,020 PSAY Alltrim(cCondPag)
   i    :=1
   nCol :=2
   nLin :=15      
      While i <= Len(aTit)
      IF I == 3 
			nCol :=2
			nLin :=17
      ENDIF      
      @ nLin,nCol pSay aTit[i][1]
      nCol +=70 
      i +=1
   End

   nServ :=1 
   nLin  :=22
   While nServ <= Len(aServ)
         @ nLin,007 pSay aServ[nServ][2]      
         @ nLin,015 pSay aServ[nServ][3] Picture "@E 9999"
			IF LEN(aServ[nServ][1]) >75
	         @ nLin,026 pSay SUBSTR(aServ[nServ][1],1,73)
	          nLin+=1 
	         @ nLin,026 pSay SUBSTR(aServ[nServ][1],74,73)
	      ELSE
	         @ nLin,026 pSay aServ[nServ][1]
   		ENDIF 
         @ nLin,113 pSay aServ[nServ][5] Picture "@E 999,999,999.99"   
         nLin +=1                       
         If nServ == 15.And.nServ <= Len(aServ)
            @ 064,000 pSay Chr(27)+"0"
            @ 065,000 pSay Chr(27)+"2"
            @ 066,000 pSay ""   
            SetPrc(0,0)   
            fCabSf2()
            nLin :=32
         Endif       
      nServ +=1
   End                

/*   If XPCC_COF+XPCC_CSLL+XPCC_PIS > 0
	   @ nLin,002 Psay "ATENCAO: Reter 4,65% referente PIS/COFINS/CSLL ,somando os pagamentos dentro do mes para o mesmo prestador do servico e sendo"
      @ nLin+=1,002 Psay "este valor superior a R$ 5.000,00 conforme Lei 10.925/04 (A responsabilidade pela retencao e do contratante do servico)."
      @ nLin+=1,015 pSay "PIS/ COFINS/ CSLL/ IRRF  "+Transform(XPCC_PIS,"@E@Z 999,999.99")+"/"+Transform(XPCC_COF,"@E@Z 999,999.99")+"/"+Transform(XPCC_CSLL,"@E@Z 999,999.99")+"/"+Transform(cIrrf,"@E@Z 999,999.99")
   ELSEIF cIrrf > 0 
      @ nLin+=1,015 pSay "IRRF "+Transform(cIrrf,"@E@Z 999,999.99")
   Endif   */ 
   
   	nLin +=1
  	IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
     	@ nLin,002    Psay "ATENCAO: Reter 4,65% referente PIS/COFINS/CSLL ,somando os pagamentos dentro do mes para o mesmo "
		@ nLin+=1,002 Psay "prestador do servico e sendo este valor superior a R$ 5.000,00 conforme Lei 10.925/04"
      @ nLin+=1,002 Psay " (A responsabilidade pela retencao e do contratante do servico)."   
   	nLin += 2
	   @ nLin,026 Psay "PIS/COFINS/CSLL  "+Transform(XPCC_PIS,"@E@Z 999,999.99")+"/"+Transform(XPCC_COF,"@E@Z 999,999.99")+"/"+Transform(XPCC_CSLL,"@E@Z 999,999.99")               
	   nLin += 1
	ENDIF
		@ nLin,026 Psay "IRRF 1,50%:"
   	@ nLin,040 Psay cIrrf Picture "@E 999,999,999.99"      // Valor do IR
	nLin += 1
		@ nLin,026 Psay "TOTAL A RETER:"                   
		@ nLin,040 Psay xReter Picture "@E 999,999,999.99"      // Total de impostos retidos   
  	nLin += 1
		@ nLin,026 Psay "VALOR LIQUIDO:"                   
		@ nLin,040 Psay nValBrut - xReter Picture "@E 999,999,999.99"   // Valor Liquido

	if  !Empty(cMens)
		nLin += 2
	   @ nLin,026 pSay SUBSTR(cMens,1,46)      	
		IF LEN(cMens) > 46
			nLin += 1
		   @ nLin,026 pSay SUBSTR(cMens,47,46)      	
		ENDIF
   endif 
   if  !Empty(cMensTes)
		nLin += 1
	   @ nLin,026 pSay SUBSTR(cMensTes,1,46)      	
		IF LEN(cMensTes) > 46
			nLin += 1
		   @ nLin,026 pSay SUBSTR(cMensTes,47,46)      	
		ENDIF
   endif 

   @ 034,113 Psay nValBrut-nDescont Picture "@E 999,999,999.99"



   @ 046,000 pSay Chr(27)+"2"
   @ 047,000 pSay Chr(18)
   @ 048,000 pSay ""   
   SetPrc(0,0)   
   
EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()

   @ 000,000 pSay Chr(15)                         
   @ 004,083 pSay SF4->F4_TEXTO
//   @ 008,093 pSay "PUBLICIDADE"
   @ 006,083 pSay Day(cEmissao)
   @ 006,095 pSay MesExtenso(Month(cEmissao))
   @ 006,110 pSay Year(cEmissao)

   If! Alltrim(cTipo) $ "B/D"
       @ 008,014 pSay SA1->A1_NOME
       @ 009,014 pSay SA1->A1_END
       @ 009,057 pSay SubStr(SA1->A1_BAIRRO,1,20)
       @ 010,014 pSay SA1->A1_MUN
       @ 010,097 pSay SA1->A1_EST
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 011,023 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 011,023 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       ElseIf! Empty(SA1->A1_CGC)   
          @ 011,023 pSay SA1->A1_CGC
       Endif   
       If AllTrim(SA1->A1_INSCR) == "ISENTO"  .OR. EMPTY(SA1->A1_INSCR)
          @ 011,100 pSay "ISENTO" 
       ElseIf! Empty(SA1->A1_INSCR)      
          @ 011,100 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       ElseIf Empty(SA1->A1_INSCR)
          @ 011,100 pSay "ISENTO"    
       Endif    
   Else
       @ 008,014 pSay SA2->A2_NOME
       @ 009,014 pSay SA2->A2_END
       @ 009,057 pSay SubStr(SA2->A2_BAIRRO,1,20)
       @ 010,014 pSay SA2->A2_MUN
       @ 010,097 pSay SA2->A2_EST
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 011,023 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 011,023 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       ElseIf! Empty(SA2->A2_CGC)   
          @ 011,023 pSay SA2->A2_CGC
       Endif   
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 011,100 pSay "ISENTO" 
       ElseIf! Empty(SA2->A2_INSCR)      
          @ 011,100 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       ElseIf Empty(SA2->A2_INSCR)
          @ 011,100 pSay "ISENTO"    
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
                                   
//cQuery := "SELECT * " 
cQuery := "SELECT D2_TES,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO "+Chr(10)+CHR(13)
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

