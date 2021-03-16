#Include "Topconn.ch"
#Include "Rwmake.ch"

/*
Funcao      : 48NFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Discovery Publicidade - Entrada e Saída   
Autor     	: Wederson L. Santana  
Data     	: 15/12/2005 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

*------------------------*
 User Function 48NFAT01()  
*------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
Private cPerg := "NF4801    "
CriaPerg()
If cEmpAnt $ "48"
   If Pergunte(cPerg,.T.)
      _cDaNota := Mv_Par01
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
   
      fOkProc()
   Endif
Else
    MsgInfo("Especifico Discovery Publicidade","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf


tamanho  :='P'
limite   :=80
titulo   :="Nota Fiscal - Entrada / Saida - Discovery Publicidade"
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
nCol     := 15
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := '48NFAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Discovery Publicidade")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Discovery Publicidade")
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
      @ nLin,017 pSay "Complemento de Importação"
      @ nLin,100 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total	
   Else
	   While F1_DOC+F1_SERIE == cCompara           
	         SB1->(DbSetOrder(1))
	         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
	         SF4->(DbSetOrder(1))
	         SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
	         @ nLin,000 pSay SB1->B1_COD                               //Código Produto
	         @ nLin,017 pSay SB1->B1_DESC                              //Descrição Produto
	         @ nLin,069 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            //Situação Tributária
	         @ nLin,077 pSay SB1->B1_UM                                //Unidade
	         @ nLin,078 pSay D1_QUANT  Picture "@E@Z 999,999.99"       //Quantidade
	         @ nLin,088 pSay D1_CUSTO  Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
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

//----------------------------------------------------------- Emite cabeçalho da nfe.

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
   
   nPerc    := ((((nValBrut-nDescont)*100)/nValBrut)-100)*-1 //Comissão da agência - percentual
   
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



   cNumPi   := SC5->C5_P_PI
   cBcoDep  := SC5->C5_P_BANCO
   cAgcDep  := SC5->C5_P_AGENC
   cCcDep   := SC5->C5_P_CONTA
   cAgenc   := SC5->C5_P_AGC
   cNomeAge := SC5->C5_P_NMAGC
   nPeriodo := Val(SC5->C5_P_VINCU)
   cAno     := SC5->C5_P_VIANO
   cMens		:= Alltrim(SC5->C5_MENNOTA)
   cMensTes := Formula(SC5->C5_MENPAD)
   xVend 	:= {}
   cVend		:= {}
   

For i:= 1 to 5
	xVend := ("SC5->C5_VEND"+(ALLTRIM(STR(I))))
	If! Empty(&xVend)   
   	SA3->(dbSetOrder(1))
   	SA3->(DbSeek(xFilial("SA3")+&xVend))
		Aadd(cVend,{SA3->A3_NOME})
	EndIF   
End
   
   aTit :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   V:= 1
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ SE1->E1_PREFIXO+SE1->E1_NUM+Space(05)+Dtoc(SE1->E1_VENCREA)+Space(07)+Transform(SE1->E1_VALOR,"@E 9,999,999.99")})
			 IF V == 1
			 	cVenc := SE1->E1_VENCREA
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
            Aadd(aServ,{AllTrim(SC6->C6_DESCRI),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI,D2_DESCON})
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

   
   fCabSf2()
   
/*   i    :=1
   nCol :=0
   nLin :=18
   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol +=46
      If nCol == 138
          nCol :=0
          nLin +=1
      Endif
      i +=1
   End
*/
   nMerc :=1
   nLin  :=24     
   @ 023,000 pSay Chr(15)
   While nMerc <= Len(aMerc)
         @ nLin,022 pSay aMerc[nMerc][01]+Space(01)+aMerc[nMerc][12]       //Código Produto
         If Len(aMerc[nMerc][1]+Space(01)+aMerc[nMerc][6])>62  
            nLin ++
            @ nLin,022 pSay SubStr(aMerc[nMerc][1]+Space(01)+aMerc[nMerc][6],63,62)            
         Endif
         @ nLin,113 pSay aMerc[nMerc][08] Picture "@E@Z 999,999,999.99"    //Vlr Total

         nLin  +=1
         If nMerc == 17.And.nMerc <= Len(aMerc)
            If MsgYesNo("Insira o proximo formulario !","A T E N C A O")
               @ 051,000 pSay Chr(27)+"2"
               @ 052,000 pSay Chr(18)
               @ 053,000 pSay ""   
               SetPrc(0,0)   

               fCabSf2()
               nLin :=24
            Endif   
         Endif       
         nMerc +=1    
   End
    
   nServ :=1 
   While nServ <= Len(aServ)
         @ nLin,022 pSay SubStr(aServ[nServ][1],1,62)//+" TOTAL BRUTO"
         nLin +=1
         @ nLin,022 pSay "TOTAL BRUTO"
         If Len(aServ[nServ][1]+" TOTAL BRUTO")>62  
            nLin ++
            @ nLin,022 pSay SubStr(aServ[nServ][1],63,62)
         Endif
         @ nLin,113 pSay aServ[nServ][5]+aServ[nServ][7] Picture "@E 999,999,999.99"   
         nLin +=1

         If nLin == 40.And.nServ <= Len(aServ)
            If MsgYesNo("Insira o proximo formulario !","A T E N C A O")
               @ 051,000 pSay Chr(27)+"2"
               @ 052,000 pSay Chr(18)
               @ 053,000 pSay ""   
               SetPrc(0,0)   

               fCabSf2()
               nLin :=24
            Endif   
         Endif       
                               
      nServ +=1
   End                
   If nPerc > 0.And.nLin < 38
      @ nLin+=1,022 pSay "COMISSAO AGENCIA ("+AllTrim(Str(Round(nPerc,2)))+" %) R$ "+TransForm(nDescont,"@E 999,999,999.99")
      @ nLin+=1,022 pSay "TOTAL LIQUIDO    ("+space(10)+TransForm(nValBrut-nDescont,"@E 999,999,999.99")
   Endif 
   
   If! Empty(cNumPi).And.nLin < 39
       @ nLin+=1,022 pSay "PI no. "+cNumPi
   Endif
   
   If nPeriodo > 0.And.nLin < 39
      @ nLin+=1,022 pSay "VEICULACAO "+MesExtenso(nPeriodo)+"/"+cAno
   Endif

   If! Empty(cAgenc).And.nLin < 39
       @ nLin+=1,022 pSay "AGENCIA: "+cNomeAge
   Endif
      
   If! Empty(cBcoDep).And.nLin < 40
       @ nLin+=1,022 pSay "PAGAMENTO - DEPOSITO EM CONTA CORRENTE"
       @ nLin+=1,022 pSay if(Alltrim(cBcoDep) == '745','NOME: CITIBANK ','')+"Banco: "+cBcoDep+" Agencia: "+cAgcDep+" Conta: "+cCcDep
   Endif
      
   If nValPis+nValCofi+nValCsll > 0
      @ nLin+=1,022 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E@Z 999,999.99")+"/"+Transform(nValCofi,"@E@Z 999,999.99")+"/"+Transform(nValCsll,"@E@Z 999,999.99")
   Endif   
	if  !Empty(cMens)
		nLin += 2
	   @ nLin,022 pSay SUBSTR(cMens,1,46)      	
		IF LEN(cMens) > 46
			nLin += 1
		   @ nLin,022 pSay SUBSTR(cMens,47,46)      	
		ENDIF
   endif 
   if  !Empty(cMensTes)
		nLin += 2
	   @ nLin,022 pSay SUBSTR(cMensTes,1,46)      	
		IF LEN(cMensTes) > 46                                           
			nLin += 1
		   @ nLin,022 pSay SUBSTR(cMensTes,47,46)      	
		ENDIF
   endif 	      	
   
	nLin += 1       
	nCol += 25
   @ nLin,022 pSay "Vendedor(s): "
   For i:=1 to LEN(cVend)
   @ nLin,nCol pSay Alltrim((cVend[i,1])) + " / "
   nCol += Len(Alltrim(cVend[i,1])) + 3
   end
   
   @ 041,113 Psay nValBrut-nDescont Picture "@E 999,999,999.99"



   @ 049,000 pSay Chr(27)+"2"
   @ 050,000 pSay Chr(18)
   @ 051,000 pSay ""   
   SetPrc(0,0)   
   
EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()

   @ 000,000 pSay Chr(15)                         
   @ 007,093 pSay SF4->F4_TEXTO
   @ 008,093 pSay "PUBLICIDADE"
   @ 009,093 pSay Day(cEmissao)
   @ 009,104 pSay MesExtenso(Month(cEmissao))
   @ 009,126 pSay Year(cEmissao)

   If! Alltrim(cTipo) $ "B/D"
       @ 013,014 pSay SA1->A1_NOME
       @ 014,014 pSay SA1->A1_END
       @ 014,057 pSay SubStr(SA1->A1_BAIRRO,1,20)
       @ 016,014 pSay SA1->A1_MUN
       @ 016,087 pSay SA1->A1_EST
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 017,023 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 017,023 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       ElseIf! Empty(SA1->A1_CGC)   
          @ 017,023 pSay SA1->A1_CGC
       Endif   
       If AllTrim(SA1->A1_INSCR) == "ISENTO"  .OR. EMPTY(SA1->A1_INSCR)
          @ 017,100 pSay "ISENTO" 
       ElseIf! Empty(SA1->A1_INSCR)      
          @ 017,100 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       ElseIf Empty(SA1->A1_INSCR)
          @ 017,100 pSay "ISENTO"    
       Endif    
       @ 019,023 pSay SA1->A1_INSCRM 
       @ 019,100 pSay Dtoc(cVenc)
   Else
       @ 013,014 pSay SA2->A2_NOME
       @ 014,014 pSay SA2->A2_END
       @ 014,057 pSay SubStr(SA2->A2_BAIRRO,1,20)
       @ 016,014 pSay SA2->A2_MUN
       @ 016,087 pSay SA2->A2_EST
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 017,023 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 017,023 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       ElseIf! Empty(SA2->A2_CGC)   
          @ 017,023 pSay SA2->A2_CGC
       Endif   
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 017,100 pSay "ISENTO" 
       ElseIf! Empty(SA2->A2_INSCR)      
          @ 017,100 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       ElseIf Empty(SA2->A2_INSCR)
          @ 017,100 pSay "ISENTO"    
       Endif    
       @ 019,023 pSay SA2->A2_INSCRM 
       @ 019,100 pSay Dtoc(cVenc)

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
   
cQuery := "SELECT D2_TES,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)+CHR(13)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)+CHR(13)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)+CHR(13)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)+CHR(13)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND "+Chr(10)+CHR(13)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "+Chr(10)+CHR(13)
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

