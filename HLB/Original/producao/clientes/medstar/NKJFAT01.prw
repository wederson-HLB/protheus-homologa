#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : Nota Fiscal MedStar
Objetivos   : Imprimir notas de entradas e saída
Autor       : Adriane Sayuri Kamiya
Data/Hora   : 10/07/2009 
Obs         : Fonte 12 - Draft
*/
 
/*
Funcao      : NKJFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal MedStar - Imprimir notas de entradas e saída
Autor     	: Adriane Sayuri Kamiya
Data     	: 10/07/2009 
Obs         : Fonte Draft, 12
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/
    
*------------------------*
 User Function NKJFAT01()  
*------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
If cEmpAnt $ "KJ"
//   If Pergunte("KJNFAT    ",.T.)  
   If Pergunte("NFKJ01    ",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else
    MsgInfo("Especifico MEDSTAR","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - MEDSTAR"
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
wnRel    := NomeProg := 'NKJFAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - MEDSTAR")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - MEDSTAR")
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
   SE2->(DbSetOrder(1))
   SE2->(DbSeek(xFilial("SE2")+SQL->F1_PREFIXO+SQL->F1_SERIE))
   

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
   cText		:= ""
   
   xMEN_TRIB:={}
   xCLAS_FIS:={}
   nLin     :=24
   
   cPosIpi := ""         
   aPosIpi := {} 
   
   cOBS:= ""
   
   cCfop  := " "
   cSQLNF := ""
   cSQLSR := "" 
   aMensTes:= {} 

             
   cOBS:=!Empty(SQL->D1_OBS)

    //Verifica os TES que existem na nf (seleção distinta)
	
    cOBS:= SQL->D1_DOC
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
		      cText += ALLTRIM(SF0->F4_TEXTO)
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
         
      @ nLin,005 pSay SB1->B1_COD                               	      //Código Produto
      @ nLin,015 pSay SB1->B1_DESC                              	      //Descrição Produto
      @ nLin,065 pSay SB1->B1_CLASFIS                            	      //Classificação fiscal
      @ nLin,070 pSay alltrim(SB1->B1_ORIGEM)+alltrim(SF4->F4_SITTRIB) //Situação Tributária
      @ nLin,076 pSay SB1->B1_UM                                	      //Unidade
      @ nLin,079 pSay SQL->D1_QUANT  Picture "@E@Z 999,999.99"       	//Quantidade
      @ nLin,091 pSay SQL->D1_VUNIT  Picture "@E@Z 99,999,999.99"    	//Vlr Unitário    
      @ nLin,109 pSay SQL->D1_TOTAL  Picture "@E@Z 999,999,999.99"   	//Vlr Total
      @ nLin,125 pSay SQL->D1_PICM   Picture "99"               			//%ICMS    
      @ nLin,129 pSay SQL->D1_IPI    Picture "99"               			//%IPI       
      If !Empty(SQL->D1_VALIPI)
         @ nLin,132 pSay SQL->D1_VALIPI  Picture "@E 999.99"          	//Vlr IPI
      Else
         @ nLin,132 pSay SQL->D1_VALIPI  Picture "@E 9.99" 
      EndIf
      
      
      SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SB1->B1_COD))
         If ! Alltrim(SB1->B1_POSIPI) $ cPosIpi 
            cPosIpi += Alltrim(SB1->B1_POSIPI) + ","   
            Aadd(aPosIpi,SB1->B1_CLASFIS + " " + Alltrim(SB1->B1_POSIPI))   
         EndIf  
          	
      IncRegua(SQL->F1_SERIE+" "+ SQL->F1_DOC)
      DbSelectArea("SQL") 
      DbSkip()
      nLin  +=1
      If nLin > 40   
         @ 063,000 pSay Chr(18)            
         @ 066,076 pSay cNota
         @ 070,000 pSay ""		   
     	 SetPrc(0,0)  
         fCabSf1()
         nLin :=24
      Endif
   EndDo  
          
   // CALCULO DO IMPOSTO
   @ 045,009 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 045,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 045,065 PSAY nBrIcms Picture "@E 999,999,999.99"  // Base ICMS Ret.
   @ 045,090 PSAY nIcmsRet Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
   @ 045,123 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 047,009 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 047,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 047,065 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 047,090 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 047,123 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota       
   

   If! Empty(cMensTes)
	  @ 056,006 pSay SUBSTR(cMensTes,1,50)
      @ 057,006 pSay SUBSTR(cMensTes,51,50)
   EndIf
   
   @ 058,006 pSay SUBSTR(cOBS,1,50)
   @ 059,006 pSay SUBSTR(cOBS,51,50) 
   
   cTextoCfop := ""
   j := 1         
   While j <= Len(aPosIpi)
      cTextoCfop += aPosIpi[j] + " / " 
      j++
   End 
   
   If Len(cTextoCfop) > 65 
      @ 060,006 pSay Substr(cTextoCfop,1,65)
      @ 061,006 pSay Substr(cTextoCfop,66,130)
   Else
   	@ 060,006 pSay cTextoCfop
   EndIf  
 
  
   @ 063,000 pSay Chr(18)            
   @ 066,072 pSay cNota
   @ 070,000 pSay ""   
   SetPrc(0,0) 

EndDo

SQL->(dbCloseArea())


Return 

       
//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
   @ 003,000 pSay Chr(18) 
   @ 003,061 PSay "X"
   @ 003,072 pSay Alltrim(cNota)
   @ 005,000 pSay Chr(15) 
 
   @ 007,005 pSay ALLTRIM(cText)
   @ 007,046 pSay cCfop
   
   If! AllTrim(cTipo) $ "B/D"
      @ 010,005 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 010,098 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 010,098 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 010,098 pSay SA2->A2_CGC
      Endif   
      @ 010,128 pSay Dtoc(cEMISSAO)
      @ 012,005 pSay SA2->A2_END
      @ 012,080 pSay SA2->A2_BAIRRO
      @ 012,107 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 014,005 pSay SA2->A2_MUN
      @ 014,055 pSay SA2->A2_TEL   
      @ 014,080 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 014,100 pSay "ISENTO" 
      Else      
	     @ 014,100 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
      Endif       
   Else   
      @ 010,005 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 010,098 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 010,098 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 010,098 pSay SA1->A1_CGC
      Endif   
      @ 010,128 pSay Dtoc(cEMISSAO)
      @ 012,005 pSay SA1->A1_END
      @ 012,080 pSay SA1->A1_BAIRRO
      @ 012,107 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 014,005 pSay SA1->A1_MUN
      @ 014,055 pSay SA1->A1_TEL   
      @ 014,080 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 014,100 pSay "ISENTO" 
      Else      
         @ 014,100 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
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
   nBsIcmRet:= F2_BRICMS
   nIcmsRet := F2_ICMSRET
   cTipo    := F2_TIPO
   nVlrIPI  := 0
   cCfop    := ""
   cMensTes := ""
   xMEN_TRIB:={}
   xCLAS_FIS:={}  
   lICMSUBS	:= .F.
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
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DOC)) 
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

   //FATURA
   If! Empty(SQL->F2_PREFIXO + SQL->F2_DUPL)
       Do While.Not.Eof().And. SQL->F2_PREFIXO + SQL->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ (SE1->E1_PREFIXO)+(SE1->E1_NUM)+Space(1)+(SE1->E1_PARCELA)})
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 999,999.99")})
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
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))

         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,IIF(!EMPTY(Alltrim(SB5->B5_CEME)),Alltrim(SB5->B5_CEME),AllTrim(SC6->C6_DESCRI)),;
            SB1->B1_POSIPI,Alltrim(SB1->B1_ORIGEM)+Alltrim(SF4->F4_SITTRIB),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,;
            ALLTRIM(SC6->C6_DESCRI),SA7->A7_CODCLI,D2_LOTECTL,SB1->B1_GRUPO,D2_DESCON,SC6->C6_DESCONT,SC6->C6_ICMSRET,SB1->B1_CLASFIS,D2_DESCON})
         Endif   
		
         IncRegua(F2_SERIE+" "+F2_DOC)                                                             
         DbSkip()
   Enddo         
   
   fCabSf2()   
   
   i:= 1 
   nCol_num := 17    
   nCol_val := 44
   nCol_Ven := 63
   nLin :=017
   While i <= Len(aTit) 
      @ nLin, nCol_num pSay aTit[i][1]
      @ nLin, nCol_Val pSay aVal[i][1]
      @ nLin, nCol_Ven pSay aVen[i][1]
      i+= 1
     If i == 2 .or. i == 4
        nCol_num := 080    
        nCol_val := 107
        nCol_Ven := 128    
     EndIf  
     If i==3       
        nLin += 1
        nCol_num := 17    
        nCol_val := 44
        nCol_Ven := 63
     EndIf
   EndDo
                             
   If !Empty(SA1->A1_ENDCOB)  
      @ 018, 006 pSay Alltrim(SA1->A1_ENDCOB) 
   EndIf
   
   //Itens da Nota
   nMerc := 1   
   nLin := 24
   cPosIpi := ""
   aPosIpi := {}     
             
   IF Alltrim(cTipo) $ "N/D/C/B"  
      While nMerc <= Len(aMerc)
         @ nLin,005 pSay aMerc[nMerc][01]                                 //Código Produto
	     IF LEN(aMerc[nMerc][02]) > 50
            @ nLin,015 pSay Alltrim(SUBSTR(aMerc[nMerc][02],1,50))                 //Descrição Produto
		    nLin+=1
	        @ nLin,015 pSay Alltrim(SUBSTR(aMerc[nMerc][02],51,50))               //Descrição Produto   	         
	        If !Empty(aMerc[nMerc][20])
	           nLin+=1 
	           @ nLin,019 pSay "Desconto: "
	           @ nLin,025 pSay aMerc[nMerc][20]
	        EndIf   
         ELSE	
	        @ nLin,015 pSay Alltrim(aMerc[nMerc][02])                             //Descrição Produto  
	        If !Empty(aMerc[nMerc][20])
	           nLin+=1 
	           @ nLin,019 pSay "Desconto: "
	           @ nLin,025 pSay aMerc[nMerc][20]  
	        EndIf   
		 ENDIF
		 If !Empty(aMerc[nMerc][14])
		    @ nLin,050 pSay "Lote: " + AllTrim(aMerc[nMerc][14])                   //Lote		 
		    //Else 
		        //@ nLin,050 pSay "                "
		 EndIf
		 @ nLin,065 pSay aMerc[nMerc][19]			                      //Classificação Fiscal
	     @ nLin,070 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,075 pSay aMerc[nMerc][05]                                //Unidade
         @ nLin,078 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,090 pSay aMerc[nMerc][07]+(aMerc[nMerc][16]/aMerc[nMerc][06]) Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         @ nLin,108 pSay aMerc[nMerc][08]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,125 pSay aMerc[nMerc][09] Picture "99"               	  //% ICMS    
         @ nLin,128 pSay aMerc[nMerc][10] Picture "99"               	  //% IPI
         @ nLin,131 pSay "0,00" //aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI                   
                  
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+aMerc[nMerc][01]))
         If ! Alltrim(aMerc[nMerc][03]) $ cPosIpi 
            cPosIpi += Alltrim(aMerc[nMerc][03]) + ","   
            Aadd(aPosIpi,SB1->B1_CLASFIS + " " + Alltrim(SB1->B1_POSIPI))   
         EndIf         
         
         nLin++
                  
         
         If  nLin > 42 
             
            If  nMerc<>Len(aMerc) 
               @ 062,000 pSay Chr(18)            
               @ 063,076 pSay cNota
               @ 069,000 pSay " "   
               SetPrc(0,0)           
               fCabSf2()
               nLin:=24  
            
            EndIf 
            
         Endif   
             
         nMerc +=1
      
      EndDo 
          
      // CALCULO DO IMPOSTO  
      @ 045,009 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
      @ 045,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
      IF nBsIcmRet > 0 .And. nIcmsRet > 0  //ELSE							// SE for .T. ele imprime o icms substituição          
		@ 045,065 PSAY nBsIcmRet Picture "@E 999,999,999.99"  // Base ICMS Ret.
		@ 045,090 PSAY nIcmsRet Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	  ENDIF
      @ 045,123 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
      @ 047,009 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
      @ 047,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
      @ 047,065 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
      @ 047,090 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
      @ 047,123 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
      
      //TRANSPORTADORA
      @ 050,006 pSay Alltrim(SA4->A4_NOME)+'- ('+alltrim(SA4->A4_DDD)+')'+SA4->A4_TEL
      If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
         @ 050,85 PSay "1"
      ElseIf SC5->C5_TPFRETE == "F"   
         @ 050,85 PSay "2"   
      Endif   
      @ 050,120 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
      @ 052,006 pSay SA4->A4_END
      @ 052,080 pSay SA4->A4_MUN
      @ 052,107 pSay SA4->A4_EST
      If AllTrim(SA4->A4_INSEST) == "ISENTO" 
         @ 052,120 pSay "ISENTO" 
      Else      
         @ 052,120 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
      Endif       
    
      @ 053,006 pSay SC5->C5_VOLUME1
      @ 053,033 pSay SC5->C5_ESPECI1
      @ 053,120 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
      @ 053,143 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"
      @ 055,006 pSay SUBSTR(SC5->C5_MENNOTA,1,50)         
      @ 056,006 pSay SUBSTR(SC5->C5_MENNOTA,51,50)         
      
   Elseif Alltrim(cTipo) = "P"                                                                
      While nMerc <= Len(aMerc)
         nVlrIPI += aMerc[nMerc][11]
         nMerc +=1
      End 
         @ nLin,015 pSay "Complemento de IPI"                          //Descrição Produto 
         @ nLin,109 pSay nVlrIPI        Picture "@E 99,999.99"         //Vlr Total   
         @ 048,123  pSay nVALMERC        Picture "@E 999,999,999.99"    //Vlr Produtos
         @ 055,006  pSay SUBSTR(SC5->C5_MENNOTA,01,50)          
         @ 056,006  pSay SUBSTR(SC5->C5_MENNOTA,51,50)          

   Else    
      If !Empty(aMerc[1][18])
         @ nLin,015  PSAY "Complemento de ICMS ST"   
         @ nLin,109  PSAY aMerc[1][18]  Picture "@E 99,999.99"        
      	 @ 048,065 PSAY nBsIcmRet Picture "@E 999,999,999.99"  // Base ICMS Ret.
    	 @ 048,090 PSAY nIcmsRet Picture "@E 999,999,999.99"  // Valor  ICMS Ret.  
    	 @ 050,123 pSay nIcmsRet Picture "@E 999,999,999.99" //Vlr Nota
      Else  
         @ nLin,015 pSay "Complemento de ICMS"                        //Descrição Produto 
         @ nLin,109  PSAY nVALICM  Picture "@E 99,999.99"                   
         @ 045,009 pSay nVALICM  Picture "@E 999,999,999.99"          //Vlr  ICMS
         @ 045,038 pSay nVALMERC Picture "@E 999,999,999.99"          //Vlr Produtos     
      EndIf   
         @ 055,006  pSay SUBSTR(SC5->C5_MENNOTA,01,50)          
         @ 056,006  pSay SUBSTR(SC5->C5_MENNOTA,51,50)      
   EndIf
  
  If! Empty(cMensTes)                	
      @ 057,006 pSay SUBSTR(cMensTes,1,50)
	  @ 058,006 pSay SUBSTR(cMensTes,51,100)
   ENDIF
      
   If! Empty(cMensPed) .And. Empty(cMensTes)
      @ 057,006 pSay SUBSTR(cMensPed,1,50)
      @ 058,006 pSay SUBSTR(cMensPed,51,100)
   ENDIF
                     
   cTextoCfop := ""
   j := 1         
   While j <= Len(aPosIpi)
      cTextoCfop += aPosIpi[j] + " / " 
      j++
   End 
   
   If Len(cTextoCfop) > 65 
      @ 059,006 pSay Substr(cTextoCfop,1,65)
      @ 060,006 pSay Substr(cTextoCfop,66,130)
   Else
   	@ 059,006 pSay cTextoCfop
   EndIf  
      
   If !Empty(SA1->A1_ENDENT)  
      @ 060, 006 pSay Alltrim(SA1->A1_ENDENT) 
   EndIf 
   
    @ 063,000 pSay Chr(18)
    @ 065,073 pSay cNota
    @ 070,000 pSay ""   
    SetPrc(0,0)   

EndDo

SQL->(dbCloseArea())

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 003,000 pSay Chr(18)
   @ 003,051 PSay "X"
   @ 003,072 pSay AllTrim(cNota)  
   @ 005,000 pSay Chr(15)
	
   @ 007,005 pSay ALLTRIM(cText)
   @ 007,046 pSay cCfop
   
   If! Alltrim(cTipo) $ "B/D"
       @ 010,005 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 010,98 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 010,98 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,98 pSay SA1->A1_CGC
       Endif   
       @ 010,128 pSay Dtoc(cEMISSAO)
       @ 012,005 pSay SA1->A1_END
       @ 012,080 pSay SA1->A1_BAIRRO
       @ 012,107 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 014,005 pSay SA1->A1_MUN
       @ 014,055 pSay "("+Alltrim(SA1->A1_DDD)+")"+SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 014,080 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 014,100 pSay "ISENTO" 
       Else      
          @ 014,100 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 010,005 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 010,98 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 010,98 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,98 pSay SA2->A2_CGC
       Endif   
       @ 010,128 pSay Dtoc(cEMISSAO)
       @ 012,005 pSay SA2->A2_END
       @ 012,080 pSay SA2->A2_BAIRRO
       @ 012,107 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 014,005 pSay SA2->A2_MUN
       @ 014,055 pSay "("+Alltrim(SA2->A2_DDD)+")"+SA2->A2_TEL // Picture "@R (99)9999-9999"
       @ 014,080 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 014,100 pSay "ISENTO" 
       Else      
          @ 014,100 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Endif    
          
      //Número Título
   
  
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
   
cQuery := "SELECT D2_TES,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,F2_BRICMS,F2_ICMSRET, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO,F2_FILIAL "+Chr(10)+CHR(13)
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

