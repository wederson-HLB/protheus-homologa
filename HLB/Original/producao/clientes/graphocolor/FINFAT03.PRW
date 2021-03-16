#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : FINFAT03
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Covit - Entrada e Saída   
Autor     	: Priorty1
Data     	: 12/08/2005 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

*------------------------* 
 User Function FINFAT03()
*------------------------* 

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
If cEmpAnt $ "FI"
   If Pergunte("NFFI03",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else
    MsgInfo("Especifico COVIT ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - COVIT Brasil"
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
wnRel    := NomeProg := 'FINFAT03'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - COVIT")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - COVIT")
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
   

   cMensTes := Formula(SF4->F4_FORMULA)
   cNota    := F1_DOC
   cEmissao := F1_EMISSAO
   nValMerc := IF(F1_TIPO$"I",0.00,F1_VALMERC)
   nValIpi  := F1_VALIPI
   nValIcm  := F1_VALICM
   nBaseIcm := F1_BASEICM
   nValBrut := IF(F1_TIPO$"I",0.00,F1_VALBRUT)
   nDespesa := F1_DESPESA
   nFrete   := F1_FRETE
   nBrIcms  := F1_BRICMS
   nIcmsRet := F1_ICMSRET
   nSeguro  := F1_SEGURO
   cTipo    := F1_TIPO
   cCompara := F1_DOC+F1_SERIE
   cText		:= ""                             
   MensD1   := D1_P_MENS
   
	xMEN_TRIB:={}
   xCLAS_FIS:={}
   nLin     :=21
   
   cPosIpi := ""
   aPosIpi := {} 
   
   cCfop  := " "
   cSQLNF := ""
	cSQLSR := "" 
	aMensTes:= {}
	
	pPesoLiq := 0
	pPesoBru := 0
   

//Verifica os TES que existem na nf (seleção distinta)
	cSQLNF := SQL->D1_DOC
	cSQLSR := SQL->D1_SERIE
	xTES := fCallTESD1(cSQLNF,cSQLSR)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))				
			If !Empty(SF4->F4_FORMULA)
				Aadd(aMensTes,SF4->F4_FORMULA)				
			Endif
			If Empty(cText)
				cText := ALLTRIM(SF4->F4_TEXTO)
				cText += "/"
			Else
				cText += ALLTRIM(SF4->F4_TEXTO)
				cText += "/"
			Endif			
		Next
   Endif
//Verifica os CFOPs correspondentes (distintos)
   xCFOP := fCallCFOPD1(cSQLNF,cSQLSR)
	If len(xCFOP) > 0
		For f:= 1 to len(xCFOP)
			cCfop += xCFOP[f]
			cCfop += " "			
		Next
	Endif

   fCabSf1()
   While SQL->F1_DOC + SQL->F1_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
         SB5->(DbSetOrder(1))
         SB5->(DbSeek(xFilial("SB5")+SQL->D1_COD))
			If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
				AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
				AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))
			Endif
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
     		
       	pPesoLiq	 += (SB1->B1_PESO * SQL->D1_QUANT)	
			pPesoBru	 += (SB1->B1_PESBRU * SQL->D1_QUANT)
         @ nLin,002 pSay SB1->B1_COD                               	      //Código Produto
         @ nLin,014 pSay SB1->B1_DESC                              	      //Descrição Produto
         @ nLin,072 pSay SB1->B1_CLASFIS                             	      //Classificação fiscal
         @ nLin,077 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            	      //Situação Tributária
         @ nLin,083 pSay SB1->B1_UM                                	      //Unidade
         @ nLin,087 pSay SQL->D1_QUANT  Picture "@E@Z 999,999.99"       	//Quantidade
         @ nLin,097 pSay SQL->D1_VUNIT  Picture "@E@Z 99,999,999.99"    	//Vlr Unitário    
         @ nLin,107 pSay SQL->D1_TOTAL  Picture "@E@Z 999,999,999.99"   	//Vlr Total
         @ nLin,122 pSay SQL->D1_PICM   Picture "99"               			//%ICMS    
         @ nLin,126 pSay SQL->D1_IPI    Picture "99"               			//%IPI
         @ nLin,132 pSay SQL->D1_VALIPI Picture "@E 99,999.99"          	//Vlr IPI
       	
       	If ! Alltrim(SB1->B1_POSIPI) $ cPosIpi 
            cPosIpi += Alltrim(SB1->B1_POSIPI) + ","   
            Aadd(aPosIpi,SB1->B1_CLASFIS + " " + Alltrim(SB1->B1_POSIPI))   
         EndIf
          	
       	IncRegua(SQL->F1_SERIE+" "+ SQL->F1_DOC)
       	DbSelectArea("SQL") 
         DbSkip()
         nLin  +=1
         	If nLin == 39
     		  		@ 061,000 pSay Chr(18)
     		  		@ 062,072 pSay cNota
	  		  		@ 066,000 pSay ""   
     		  		SetPrc(0,0)  
            	fCabSf1()
            	nLin :=21
         	Endif
   End         
// CALCULO DO IMPOSTO
   @ 041,002 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 041,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 041,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 043,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 043,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 043,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 043,084 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 043,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
  
  	pPesoLiq := 0
	pPesoBru := 0

   @ 050,095 pSay pPesoLiq        Picture "@E@Z 999,999,999.99"
   @ 050,120 pSay pPesoBru        Picture "@E@Z 999,999,999.99"
   
   @ 053,003 pSay Substr(MensD1,1,65)
   @ 054,003 pSay Substr(MensD1,66,65)
   @ 055,003 pSay Substr(MensD1,131,70)
   
	If! Empty(cMensTes)
		@ 056,003 pSay SUBSTR(cMensTes,1,65)
	   @ 057,003 pSay SUBSTR(cMensTes,66,65)
   EndIf

   cTextoCfop := ""
   j := 1         
   While j <= Len(aPosIpi)
      cTextoCfop += aPosIpi[j] + " / " 
      j++
   End 
   
   If Len(cTextoCfop) > 65 
      @ 058,004 pSay Substr(cTextoCfop,1,65)
      @ 059,004 pSay Substr(cTextoCfop,66,65)
   Else
   	@ 058,004 pSay cTextoCfop
   EndIf                                        
        
   @ 061,000 pSay Chr(18)
   @ 062,072 pSay cNota
   @ 066,000 pSay ""   
   SetPrc(0,0) 
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
   @ 001,000 pSay Chr(18)
   @ 001,050 PSay "X"
   @ 001,074 pSay Alltrim(cNota)
   @ 004,000 pSay Chr(15)
   
   @ 006,003 pSay cText
   @ 006,042 pSay cCfop
  	
   If! AllTrim(cTipo) $ "B/D"
      @ 009,003 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 009,087 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 009,087 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 009,087 pSay SA2->A2_CGC
      Endif   
      @ 009,128 pSay Dtoc(cEMISSAO)
      @ 011,003 pSay SA2->A2_END
      @ 011,070 pSay SA2->A2_BAIRRO
      @ 011,106 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 013,003 pSay SA2->A2_MUN
      @ 013,055 pSay SA2->A2_TEL   
      @ 013,081 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 013,088 pSay "ISENTO" 
      Else      
	      @ 013,088 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
      Endif       
	Else   
      @ 009,003 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 009,087 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 009,087 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 009,087 pSay SA1->A1_CGC
      Endif   
      @ 009,128 pSay Dtoc(cEMISSAO)
      @ 011,003 pSay SA1->A1_END
      @ 011,070 pSay SA1->A1_BAIRRO
      @ 011,106 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 013,003 pSay SA1->A1_MUN
      @ 013,055 pSay SA1->A1_TEL   
      @ 013,081 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 013,088 pSay "ISENTO" 
      Else      
         @ 013,088 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
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
   nDescont := F2_DESCONT
   cTipo    := F2_TIPO
   nVlrIPI  := 0
   cCfop    := ""
	cMensTes := ""
	xMEN_TRIB :={}
  	xCLAS_FIS :={}
  	
  	aMensTes:= {}
  	cSQLNF := ""
	cSQLSR := ""
	cText := ""
  				
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
   
   SD2->(DbSetOrder(3))
   SD2->(DbSeek(xFilial("SD2")+SQL->F2_DOC+SQL->F2_SERIE))

//Verifica os TES que existem na nf (seleção distinta)

	cSQLNF := SD2->D2_DOC
	cSQLSR := SD2->D2_SERIE
	xTES := fCallTES(cSQLNF,cSQLSR)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))				
			If !Empty(SF4->F4_FORMULA)
				Aadd(aMensTes,SF4->F4_FORMULA)				
			Endif
			If Empty(cText)
				cText := ALLTRIM(SF4->F4_TEXTO)
				cText += "/"
			Else
				cText += ALLTRIM(SF4->F4_TEXTO)
				cText += "/"
			Endif			
		Next
   Endif
//Verifica os CFOPs correspondentes (distintos)
   xCFOP := fCallCFOP(cSQLNF,cSQLSR)
	If len(xCFOP) > 0
		For f:= 1 to len(xCFOP)
			cCfop += xCFOP[f] + "/"			
		Next
	Endif

   DbSelectArea("SQL")
   cMensTes := Formula(SF4->F4_FORMULA)       
   cMensPed := Formula(SC5->C5_MENPAD)
   aTit :={}
   aVal :={}
   aVen :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   //FATURA
   If! Empty(SQL->F2_PREFIXO + SQL->F2_DUPL)
       Do While.Not.Eof().And.SQL->F2_PREFIXO + SQL->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ (SE1->E1_PREFIXO)+(SE1->E1_NUM)+Space(1)+(SE1->E1_PARCELA)})
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 999,999,999.99")})
          Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
          SE1->(DbSkip())
       EndDo
   Endif    
     
   aMerc    :={}
   aServ    :={}
   cCompara := SQL->F2_DOC + SQL->F2_SERIE
   While F2_DOC+F2_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
         SB5->(DbSetOrder(1))
         SB5->(DbSeek(xFilial("SB5")+SQL->D2_COD))
         SA7->(DbSetOrder(1))
         SA7->(DbSeek(xFilial("SA7")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->D2_COD))

			If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
				AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
				AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))
			Endif
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))

         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,IIF(!EMPTY(Alltrim(SB5->B5_CEME)),Alltrim(SB5->B5_CEME),AllTrim(SB1->B1_DESC)),SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,ALLTRIM(SC6->C6_DESCRI),SA7->A7_CODCLI,D2_LOTECTL,SB1->B1_GRUPO,D2_DESCON,SC6->C6_DESCONT,SB1->B1_CLASFIS,SC6->C6_DESCRI,SC6->C6_PEDCLI})
         Endif   
		
         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   Enddo         
   
   fCabSf2()
     
   //Número Título SÓ TEM ESPAÇO PARA 2 TITULOS.
   nLin :=016        
                      
   If Len(atit) > 0    
      @ nLin, 018 pSay aTit[1][1]
      @ nLin, 042 pSay aVen[1][1]
      @ nLin, 061 pSay aVal[1][1] 
      
      If Len(atit)>1
         @ nLin, 075 pSay aTit[2][1]
         @ nLin, 101 pSay aVen[2][1]
         @ nLin, 120 pSay aVal[2][1]
      EndIf
   EndIf   
    
   //Itens da Nota
   nMerc := 1   
   nLin := 20
   cPosIpi := ""
   aPosIpi := {}     
           
If Alltrim(cTipo) $ "N/D/C/B"
   
   While nMerc <= Len(aMerc)
      @ nLin,002 pSay aMerc[nMerc][01]                                         //Descrição Produto
      If !Empty(aMerc[nMerc][20])
         @ nLin,014 pSay aMerc[nMerc][19]+ " - Ped. Cli:"+aMerc[nMerc][20]     //Descrição Produto + Pedido do cliente	      
      Else                            
         @ nLin,014 pSay aMerc[nMerc][19]
      EndIf
      @ nLin,072 pSay aMerc[nMerc][18]			                               //Classificação Fiscal
	  @ nLin,077 pSay aMerc[nMerc][04]                                         //Situação Tributária
      @ nLin,083 pSay aMerc[nMerc][05]                                         //Unidade
      @ nLin,087 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"               //Quantidade
      @ nLin,095 pSay aMerc[nMerc][07]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
      @ nLin,109 pSay aMerc[nMerc][08]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Total
      @ nLin,122 pSay aMerc[nMerc][09] Picture "99"               	           //% ICMS    
      @ nLin,126 pSay aMerc[nMerc][10] Picture "99"               	           //% IPI
      @ nLin,124 pSay aMerc[nMerc][11] Picture "@E 999,999,999.99"             //Vlr IPI                   
         
      SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+aMerc[nMerc][01]))
         If ! Alltrim(aMerc[nMerc][03]) $ cPosIpi 
            cPosIpi += Alltrim(aMerc[nMerc][03]) + ","   
            Aadd(aPosIpi,SB1->B1_CLASFIS + " " + Alltrim(SB1->B1_POSIPI))   
         EndIf
   
         If aMerc[nMerc][16]>0
            nLin +=1
            @ nLin,016 pSay "Desconto "+Transform(aMerc[nMerc][17],"@E 999.99")+"%"       
            @ nLin,097 pSay aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"
         EndIf
         
         nLin++
         
         If nLin > 37  
            nLin:=22         
            @ 060,000 pSay Chr(18)
            @ 061,072 pSay cNota
            @ 066,000 pSay " "   
            SetPrc(0,0)           
            
            fCabSf2() 
            
         Endif       
         nMerc +=1
      EndDo               
      
      If nValPis+nValCofi+nValCsll > 0
         @ nLin,015 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E@Z 999,999.99")+"/"+Transform(nValCofi,"@E@Z 999,999.99")+"/"+Transform(nValCsll,"@E@Z 999,999.99")
      Endif   
     
      // CALCULO DO IMPOSTO  
      @ 040,002 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
      @ 040,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
      @ 040,120 pSay nVALMERC+nDescont Picture "@E 999,999,999.99" //Vlr Produtos
      @ 042,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
      @ 042,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
      @ 042,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
      @ 042,086 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
      @ 042,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
      
      //TRANSPORTADORA
      @ 045,003 pSay SA4->A4_NOME                
      If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
         @ 045,073 PSay "1"
      ElseIf SC5->C5_TPFRETE == "F"   
         @ 045,073 PSay "2"   
      Endif   
      @ 045,117 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
      
      @ 047,003 pSay SA4->A4_END
      @ 047,070 pSay SA4->A4_MUN
      @ 047,102 pSay SA4->A4_EST
      If AllTrim(SA4->A4_INSEST) == "ISENTO" 
         @ 047,117 pSay "ISENTO" 
      Else      
         @ 047,117 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
      Endif       
    
      @ 049,003 pSay SC5->C5_VOLUME1
      @ 049,022 pSay SC5->C5_ESPECI1
      @ 049,095 pSay SC5->C5_PBRUTO  Picture "@E@Z 999,999,999.99"
      @ 049,120 pSay SC5->C5_PESOL   Picture "@E@Z 999,999,999.99"
      @ 052,003 pSay SUBSTR(SC5->C5_MENNOTA,1,65)         
      @ 053,003 pSay SUBSTR(SC5->C5_MENNOTA,66,65) 
         
   
   If! Empty(cMensTes)
	     @ 054,004 pSay SUBSTR(cMensTes,1,65)
	     @ 055,004 pSay SUBSTR(cMensTes,66,65)
   ENDIF
      
   If! Empty(cMensPed) .And. Empty(cMensTes)
	   @ 054,004 pSay SUBSTR(cMensPed,1,65)
	   @ 055,004 pSay SUBSTR(cMensPed,66,65)
   ENDIF
  
   cTextoCfop := ""
   j := 1         
   While j <= Len(aPosIpi)
      cTextoCfop += aPosIpi[j] + " / " 
      j++
   End 
   
   If Len(cTextoCfop) > 65 
      @ 056,004 pSay Substr(cTextoCfop,1,65)
      @ 057,004 pSay Substr(cTextoCfop,66,65)
   Else
   	@ 056,004 pSay cTextoCfop
   EndIf                                        
  
ElseIf Alltrim(cTipo) = "P"    

   @ nLin,015 pSay "Complemento de IPI"                          //Descrição Produto 
   @ nLin,124 pSay nVlrIPI        Picture "@E 99,999.99"         //Vlr Total            
   @ 042 ,086  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr IPI Rodapé     
   
   @ 052,003 pSay SUBSTR(SC5->C5_MENNOTA,1,65)         
   @ 053,003 pSay SUBSTR(SC5->C5_MENNOTA,66,65) 
         
   
   If! Empty(cMensTes)
	     @ 054,004 pSay SUBSTR(cMensTes,1,65)
	     @ 055,004 pSay SUBSTR(cMensTes,66,65)
   ENDIF
      
   If! Empty(cMensPed) .And. Empty(cMensTes)
	   @ 054,004 pSay SUBSTR(cMensPed,1,65)
	   @ 055,004 pSay SUBSTR(cMensPed,66,65)
   ENDIF
  
Else 
   
   @ nLin,015 pSay aMerc[nMerc][19]                              //Descrição Produto 
   @ nLin,109 pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr Total            
   @ 040,038  pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
   
   @ 052,003 pSay SUBSTR(SC5->C5_MENNOTA,1,65)         
   @ 053,003 pSay SUBSTR(SC5->C5_MENNOTA,66,65) 
         
   
   If! Empty(cMensTes)
	     @ 054,004 pSay SUBSTR(cMensTes,1,65)
	     @ 055,004 pSay SUBSTR(cMensTes,66,65)
   ENDIF
      
   If! Empty(cMensPed) .And. Empty(cMensTes)
	   @ 054,004 pSay SUBSTR(cMensPed,1,65)
	   @ 055,004 pSay SUBSTR(cMensPed,66,65)
   ENDIF

EndIf   
    nLin:=77     

    @ 060,000 pSay Chr(18)
    @ 061,072 pSay cNota
	 @ 065,000 pSay ""   
    SetPrc(0,0)   

EndDo
SQL->(dbCloseArea())

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 001,000 pSay Chr(18)
   @ 001,049 PSay "X"
   @ 001,074 pSay AllTrim(cNota)  
   @ 004,000 pSay Chr(15)
	
	@ 006,003 pSay ALLTRIM(cText)
	@ 006,042 pSay cCfop
   
   If! Alltrim(cTipo) $ "B/D"
       @ 009,003 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 009,087 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 009,087 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,087 pSay SA1->A1_CGC
       Endif   
       @ 009,128 pSay Dtoc(cEMISSAO)
       @ 011,003 pSay SA1->A1_END
       @ 011,070 pSay SA1->A1_BAIRRO
       @ 011,106 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 013,003 pSay SA1->A1_MUN
       @ 013,055 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 013,081 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 013,88 pSay "ISENTO" 
       Else      
          @ 013,88 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 009,003 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 009,87 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 009,87 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,87 pSay SA2->A2_CGC
       Endif   
       @ 009,130 pSay Dtoc(cEMISSAO)
       @ 011,003 pSay SA2->A2_END
       @ 011,070 pSay SA2->A2_BAIRRO
       @ 011,106 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 013,003 pSay SA2->A2_MUN
       @ 013,055 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 013,081 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 013,88 pSay "ISENTO" 
       Else      
          @ 013,88 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
cQuery += "SF1.F1_FORMUL = 'S' AND SD1.D1_FORMUL = 'S' AND "+Chr(10)
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
   
cQuery := "SELECT D2_TES,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI, "+Chr(10)+CHR(13)
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
//------------------------------------------------------------------
/*-------------------------*/
Static Function fCallTESD1(cSQLNF,cSQLSR)   
/*-------------------------*/
Local aTESdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPTES") > 0
	dbSelectArea("TEMPTES")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD1.D1_TES AS ITEMTES"
cQryFR	+= " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"
cQryFR	+= " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
cQryFR   += " AND SD1.D1_DOC = '"+cNota+"'"
cQryFR   += " AND SD1.D1_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD1.D1_FORMUL = 'S' "
cQryFR	+= " AND SD1.D_E_L_E_T_ <> '*' "

TCQUERY cQryFR NEW ALIAS "TEMPTES"
dbSelectArea("TEMPTES")
dbGoTop()
While .not. eof()
	Aadd(aTESdif,TEMPTES->ITEMTES)	
   dbSelectArea("TEMPTES")
   TEMPTES->(Dbskip())
Enddo
TEMPTES->(DbCloseArea())

Return(aTESdif)



//-------------------------------------------------------------

//-------------------------
Static Function fCallCFOPD1(cSQLNF,cSQLSR)  
//-------------------------
Local aCFOPdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPCF") > 0
	dbSelectArea("TEMPCF")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD1.D1_CF AS CFOPS"
cQryFR	+= " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"
cQryFR	+= " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
cQryFR   += " AND SD1.D1_DOC = '"+cNota+"'"
cQryFR   += " AND SD1.D1_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD1.D1_FORMUL = 'S' "
cQryFR	+= " AND SD1.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPCF"
dbSelectArea("TEMPCF")
dbGoTop()
While .not. eof()
	Aadd(aCFOPdif,TEMPCF->CFOPS)	
   dbSelectArea("TEMPCF")
   TEMPCF->(Dbskip())
Enddo
TEMPCF->(DbCloseArea())

Return(aCFOPdif)

//-------------------------------------
Static Function fCallTES(cSQLNF,cSQLSR)   
//-------------------------------------
Local aTESdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPTES") > 0
	dbSelectArea("TEMPTES")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD2.D2_TES AS ITEMTES"
cQryFR	+= " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"
cQryFR	+= " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
cQryFR   += " AND SD2.D2_DOC = '"+cNota+"'"
cQryFR   += " AND SD2.D2_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD2.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPTES"
dbSelectArea("TEMPTES")
dbGoTop()
While .not. eof()
	Aadd(aTESdif,TEMPTES->ITEMTES)	
   dbSelectArea("TEMPTES")
   TEMPTES->(Dbskip())
Enddo
TEMPTES->(DbCloseArea())

Return(aTESdif)


//--------------------------------------
Static Function fCallCFOP(cSQLNF,cSQLSR)  
//--------------------------------------
Local aCFOPdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPCF") > 0
	dbSelectArea("TEMPCF")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD2.D2_CF AS CFOPS"
cQryFR	+= " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"
cQryFR	+= " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
cQryFR   += " AND SD2.D2_DOC = '"+cNota+"'"
cQryFR   += " AND SD2.D2_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD2.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPCF"
dbSelectArea("TEMPCF")
dbGoTop()
While .not. eof()
	Aadd(aCFOPdif,TEMPCF->CFOPS)	
   dbSelectArea("TEMPCF")
   TEMPCF->(Dbskip())
Enddo
TEMPCF->(DbCloseArea())

Return(aCFOPdif)



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

