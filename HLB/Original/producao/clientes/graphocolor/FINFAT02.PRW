#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : FINFAT02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Covit - Entrada e Saída   
Autor     	: José Ferreira 
Data     	: 12/08/2005 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

*------------------------*
 User Function FINFAT02()
*------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
If cEmpAnt $ "FI"
   If Pergunte("NFFI01    ",.T.)  
      _cDaNota := Mv_Par01
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else
    MsgInfo("Especifico Covit ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

tamanho  :='M'
limite   :=120
titulo   :="Nota Fiscal - Entrada / Saida - Covit"
cDesc1   :=' '
cDesc2   :=''
cDesc3   :='Impressao em formulario de 120 colunas.'
aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
nLin     := 60
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := 'FINFAT02'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Covit")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Covit")
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
   MensD1   := D1_P_MENS
   fCabSf1()
   
   While F1_DOC+F1_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
 
 			
         @ nLin,002 pSay SB1->B1_COD                               //Código Produto
         @ nLin,017 pSay SB1->B1_DESC                              //Descrição Produto
         @ nLin,086 pSay SB1->B1_POSIPI                            //Classificação fiscal
         @ nLin,105 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            //Situação Tributária
         @ nLin,112 pSay SB1->B1_UM                                //Unidade
         @ nLin,115 pSay D1_QUANT  Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,135 pSay D1_CUSTO  Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
         @ nLin,150 pSay D1_TOTAL  Picture "@E@Z 999,999,999.99"   //Vlr Total
         @ nLin,175 pSay D1_PICM   Picture "@E 99.9"               //% ICMS    
         @ nLin,183 pSay D1_IPI    Picture "@E 99.9"               //% IPI
         @ nLin,190 pSay D1_VALIPI Picture "@E 99,999.99"          //Vlr IPI
         IncRegua(F1_SERIE+" "+F1_DOC)   
         DbSkip()
         nLin  +=1
         If nLin == 32
            @ 075,000 pSay Chr(18)
            @ 075,110 pSay cNota
            @ 078,000 pSay ""   
            SetPrc(0,0)   
            fCabSf1()
            nLin :=21
         Endif
   End         
 //CALCULO DO IMPOSTO         
   @ 044,000 pSay Chr(27)+"0"

   @ 045,000 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 045,045 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 045,090 pSay nBrIcms  Picture "@E 999,999,999.99" //Base ICMS Subst.
   @ 045,125 pSay nIcmsRet Picture "@E 999,999,999.99" //Vlr  ICMS Subst.      
   @ 045,190 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 048,000 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 048,045 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 048,090 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 048,125 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 048,190 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota

   @ 062,020 pSay Substr(MensD1,1,60)
   @ 063,010 pSay Substr(MensD1,61,70)
   @ 064,010 pSay Substr(MensD1,141,70)


   @ 066,020 pSay cMensTes

   @ 070,000 pSay Chr(27)+"2"
   @ 070,000 pSay Chr(18)
   @ 076,110 pSay cNota

   @ 078,000 pSay ""   
   SetPrc(0,0)   
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
   @ 000,000 pSay Chr(18)
   @ 002,089 PSay "X"
   @ 002,110 pSay cNota
   @ 005,000 pSay Chr(15)
   @ 006,002 pSay SF4->F4_TEXTO
   @ 006,055 pSay SF4->F4_CF
   If! AllTrim(cTipo) $ "B/D"
      @ 009,002 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 009,140 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 009,140 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 009,140 pSay SA2->A2_CGC
      Endif   
      @ 009,190 pSay Dtoc(cEMISSAO)
      @ 011,002 pSay SA2->A2_END
      @ 011,103 pSay SA2->A2_BAIRRO
      @ 011,140 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 013,002 pSay SA2->A2_MUN
      @ 013,103 pSay SA2->A2_TEL   
      @ 013,140 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
   Else   
      @ 009,002 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 009,140 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 009,140 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 009,140 pSay SA1->A1_CGC
      Endif   
      @ 009,150 pSay Dtoc(cEMISSAO)
      @ 011,002 pSay SA1->A1_END
      @ 011,103 pSay SA1->A1_BAIRRO
      @ 011,140 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 013,002 pSay SA1->A1_MUN
      @ 013,103 pSay SA1->A1_TEL   
//      @ 013,072 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 013,140 pSay "ISENTO" 
      Else      
         @ 013,140 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
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
   aTit :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
//FATURA
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ SE1->E1_PREFIXO+SE1->E1_NUM+Space(17)+transform(SE1->E1_VALOR,"@E 9,999,999.99")+Space(14)+Dtoc(SE1->E1_VENCREA)})
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
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,SC6->C6_DESCRI})
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
               cCfop += "6"+SubStr(SC6->C6_CF,2,3)+"/"
            Endif   
         Endif

         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         
//   DbSkip(-1)
   
   fCabSf2()
   
//IMPRIME FATURA
   i    :=1
   nCol :=2
   nLin :=17
   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol +=68
      If nCol == 138
          nCol :=0
          nLin +=1
      Endif
      i +=1
   End

   nMerc :=1
   nLin  :=21
   nPos  :=1
   While nMerc <= Len(aMerc)
         @ nLin,002 pSay aMerc[nMerc][01]                                 //Código Produto
         @ nLin,017 pSay aMerc[nMerc][12]                                 //Descrição Produto
         @ nLin,086 pSay aMerc[nMerc][03]                                 //Classificação Fiscal
         @ nLin,105 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,112 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,115 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,135 pSay aMerc[nMerc][07] Picture "@E@Z 99,999,999.99"    //Vlr Unitário    
         @ nLin,150 pSay aMerc[nMerc][08] Picture "@E@Z 999,999,999.99"   //Vlr Total
         @ nLin,175 pSay aMerc[nMerc][09] Picture "@E 99.9"               //% ICMS    
         @ nLin,183 pSay aMerc[nMerc][10] Picture "@E 99.9"               //% IPI
         @ nLin,190 pSay aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI
         nLin  +=1
         
         If nLin >42 .And. nMerc <= Len(aMerc)
            i   :=1  
            nLin:=65  
            nPos:=16                   
            //ASK 06/05/2008 Erro ao imprimir 
            /*While i <= Len(aMerc)    
                 If Len(aMerc[i][03]) > 0.And.nLin <= 70
                    @ nLin,000 pSay aMerc[i][03]
                    nLin += 1
                 Endif
                 i +=1
            End */       
            @ 069,000 pSay Chr(18)
            @ 070,002 pSay cNota
            @ 073,000 pSay ""   
            SetPrc(0,0)   
  
            fCabSf2()
            
            nLin :=21
         Endif       
         nMerc +=1    
   End
   If nValPis+nValCofi+nValCsll > 0
      @ nLin,015 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E@Z 999,999.99")+"/"+Transform(nValCofi,"@E@Z 999,999.99")+"/"+Transform(nValCsll,"@E@Z 999,999.99")
   Endif   
   

// CALCULO DO IMPOSTO
   @ 044,000 pSay Chr(27)+"0"
   @ 045,000 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 045,045 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 045,190 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 048,000 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 048,045 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 048,090 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 048,125 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 048,190 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
   
//TRANSPORTADORA
   @ 052,003 pSay SA4->A4_NOME                 
   If SC5->C5_TPFRETE $ "F"
      @ 052,115 PSay "1"
   ElseIf SC5->C5_TPFRETE $ "C"   
      @ 052,115 PSay "2"   
   Endif   
   @ 052,170 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 055,003 pSay SA4->A4_END
   @ 055,090 pSay SA4->A4_MUN
   @ 055,158 pSay SA4->A4_EST
   @ 055,170 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   @ 057,005 pSay SC5->C5_VOLUME1
   @ 057,035 pSay SC5->C5_ESPECI1
   @ 057,165 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
   @ 057,180 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"

   @ 061,020 pSay SUBSTR(SC5->C5_MENNOTA,1,60)         
   @ 062,010 pSay SUBSTR(SC5->C5_MENNOTA,61,70)
   @ 063,010 pSay SUBSTR(SC5->C5_MENNOTA,131,70)   
   @ 064,010 pSay SUBSTR(SC5->C5_MENNOTA,201,70)      
	If! Empty(cMensTes)
	   @ 065,010 pSay SUBSTR(cMensTes,1,70)
   	@ 066,010 pSay SUBSTR(cMensTes,71,70)
   ENDIF
   n1es:=1         
   n2es:=60
   nLin:=67     

   @ 072,000 pSay Chr(27)+"2"
   @ 072,000 pSay Chr(18)
   @ 075,110 pSay cNota

   @ 079,000 pSay ""   
   SetPrc(0,0)   

EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 000,000 pSay Chr(18)
   @ 001,110 pSay cNota
   @ 002,077 PSay "X"
   @ 005,000 pSay Chr(15)

	FOR I := 1 TO LEN(cText)
   	IF I == 1
   		@ 006,002 pSay ALLTRIM(cText[1])
   	ENDIF
   	IF cText[I] <> cText[1]
	   	@ 006,020 pSay "/"+cText[I]
   	endif
   NEXT

   @ 006,055 pSay cCfop

   If! Alltrim(cTipo) $ "B/D"
       @ 009,002 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 009,140 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 009,140 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,140 pSay SA1->A1_CGC
       Endif   
       @ 009,190 pSay Dtoc(cEMISSAO)
       @ 011,002 pSay SA1->A1_END
       @ 011,103 pSay SA1->A1_BAIRRO
       @ 011,140 pSay SA1->A1_CEP   Picture "@R 99.999-999"
//       @ 010,190 pSay Dtoc(dDataBase)
       @ 013,002 pSay SA1->A1_MUN
       @ 013,103 pSay SA1->A1_TEL   Picture "@R (99)9999-9999"
//       @ 012,072 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 013,140 pSay "ISENTO" 
       Else      
          @ 013,140 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 009,002 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 009,140 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 009,140 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,140 pSay SA2->A2_CGC
       Endif   
       @ 009,150 pSay Dtoc(cEMISSAO)
       @ 011,002 pSay SA2->A2_END
       @ 011,103 pSay SA2->A2_BAIRRO
       @ 011,140 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 013,002 pSay SA2->A2_MUN
       @ 013,103 pSay SA2->A2_TEL   Picture "@R (99)9999-9999"
//       @ 012,072 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 013,140 pSay "ISENTO" 
       Else      
          @ 013,140 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
//AADD(aRegistros,{cPerg,"01","Emissao de     		","","","mv_ch1","D",08,00,00,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

