
#include "topconn.ch"
#include "rwmake.ch"


/*
Funcao      : NHOFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal AlPunto - Entrada e Saída
Autor     	: Adriane Sayuri Kamiya
Data     	: 06/04/2009 
Obs         : FONTE 10 / DRAFT
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*------------------------*
 User Function NHOFAT01()  
*------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
If cEmpAnt $ "HO"
   If Pergunte("NFHO01",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else
   MsgInfo("Especifico ALPUNTO !","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - ALPUNTO
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
wnRel    := NomeProg := 'NHOFAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - AlPunto")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - AlPunto")
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
   SA4->(DbSetOrder(1))
   SA4->(DbSeek(xFilial("SA4")+SQL->F1_TRANSP))
   

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
   nPBRUTOE := F1_PBRUTO
   nPLIQUIE := F1_PLIQUI
   nVOLUME  := F1_VOLUME1
   nESPECIE := F1_ESPECI1
   cCompara := F1_DOC+F1_SERIE
   cText		:= ""
   
   xMEN_TRIB:={}
   xCLAS_FIS:={}
   nLin     :=024
   
   cCfop  := " "
   cSQLNF := ""
   cSQLSR := ""                                              
   aMensTes:= {}
   
   cMenOBS :=SQL->D1_OBS 
   
  /* nPLIQUI :=SQL->D1_P_LIQ 
   nPBRUTO :=SQL->D1_P_BRUTO
   cTransp :=alltrim(SQL->D1_P_TRANS)
   cEspecie:=SQL->D1_P_ESPEC
   nVolume :=SQL->D1_P_VOLUM*/

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
     	 
     	 @ nLin,000 pSay Chr(15)	
         @ nLin,000 pSay SB1->B1_COD                               	        //Código Produto
         @ nLin,011 pSay SB1->B1_DESC                              	        //Descrição Produto
  	     @ nLin,082 pSay SB1->B1_PESO			                            //Peso Liquido (b1_peso)
         @ nLin,093 pSay SB1->B1_POSIPI                            	        //Classificação fiscal
         @ nLin,103 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            	        //Situação Tributária
         @ nLin,109 pSay SB1->B1_UM                                	        //Unidade
         @ nLin,114 pSay SQL->D1_QUANT  Picture "@E@Z 999,999.99"       	//Quantidade
         @ nLin,121 pSay SQL->D1_VUNIT  Picture "@E@Z 99,999,999.99"    	//Vlr Unitário    
         @ nLin,135 pSay SQL->D1_TOTAL  Picture "@E@Z 999,999,999.99"   	//Vlr Total
         @ nLin,152 pSay SQL->D1_PICM   Picture "99"               			//%ICMS    
         @ nLin,157 pSay SQL->D1_IPI    Picture "99"               			//%IPI
         @ nLin,164 pSay SQL->D1_VALIPI Picture "@E 99,999.99"          	//Vlr IPI
       	IncRegua(SQL->F1_SERIE+" "+ SQL->F1_DOC)
       	DbSelectArea("SQL") 
         DbSkip()
         nLin  +=1
         	If nLin > 37
         	   @ 045,100 pSay Chr(18)
               @ 045,147 pSay cNota
               @ 051,000 pSay ""   
               SetPrc(0,0)  
               fCabSf1()
               nLin :=024
         	Endif   
   End         
       
// CALCULO DO IMPOSTO
   @ 039,000 pSay Chr(15)
   @ 039,002 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 039,023 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 039,094 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 041,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 041,023 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 041,040 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 041,068 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 041,094 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
                                      
 
//TRANSPORTADORA - ENTRADA
   @ 043,000 pSay SA4->A4_NOME                
   @ 043,072 PSay "1"   
   @ 043,093 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 044,000 pSay SA4->A4_END
   @ 044,066 pSay SA4->A4_MUN
   @ 044,090 pSay SA4->A4_EST
   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
      @ 044,094 pSay "ISENTO" 
   Else      
      @ 044,094 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   Endif              
   
   @ 045,100 pSay Chr(18)     
   @ 045,146 pSay AllTrim(cNota)
   
   @ 046,000 pSay Chr(15)
   @ 046,004 pSay nVOLUME
   @ 046,020 pSay nESPECIE
   @ 046,070 pSay nPBRUTOE          Picture "@E@Z 999,999,999.99"
   @ 046,094 pSay nPLIQUIE          Picture "@E@Z 999,999,999.99" 
     
   @ 051,000 pSay ""   
   SetPrc(0,0)  
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
    @ 001,000 pSay Chr(15)    
    If !empty(cMensTes)
       @ 001,001 pSay Substr(cMensTes,1,50)
       @ 002,001 pSay Substr(cMensTes,51,50)    
    EndIf
    
    @ 002,080 pSay Chr(18)    
    @ 002,126 pSay AllTrim(cNota)  
    @ 002,138 pSay AllTrim(cNota)  
  
    @ 003,000 pSay Chr(15)    
   
    If !Empty(cMensTes)
       @ 003,001 pSay Substr(cMensTes,101,50)   
       @ 004,001 pSay Substr(cMensTes,151,50) 
       
    EndIf   
    @ 005,001 pSay Substr(cMenOBS,1,50)
    @ 006,001 pSay Substr(cMenOBS,51,50)    
    
    //@ 006,000 pSay Chr(18) 
    @ 006,070 pSay Chr(18)
    @ 006,113 PSay "X" 
    @ 007,000 pSay Chr(15)       
    
    @ 007,001 pSay Substr(cMenOBS,101,50)
    @ 008,001 pSay Substr(cMenOBS,151,50)  
     
    //@ 008,000 pSay Chr(15)     
   	@ 011,060 pSay ALLTRIM(cText)
	@ 011,088 pSay cCfop

   If! AllTrim(cTipo) $ "B/D"
      @ 013,060 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 013,124 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 013,124 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 013,124 pSay SA2->A2_CGC
      Endif   
      @ 013,160 pSay Dtoc(cEMISSAO)
      @ 015,060 pSay SA2->A2_END
      @ 015,114 pSay SA2->A2_BAIRRO
      @ 015,143 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 016,060 pSay SA2->A2_MUN
      //@ 011,070 pSay SA2->A2_TEL   
      @ 016,118 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 016,125 pSay "ISENTO" 
      Else      
	     @ 016,125 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
      Endif       
   Else   
      @ 013,060 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 013,124 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 013,124 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 013,124 pSay SA1->A1_CGC
      Endif   
      @ 013,160 pSay Dtoc(cEMISSAO)
      @ 015,060 pSay SA1->A1_END
      @ 015,114 pSay SA1->A1_BAIRRO
      @ 015,143 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 016,060 pSay SA1->A1_MUN
      //@ 016,070 pSay SA1->A1_TEL   
      @ 016,118 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 016,125 pSay "ISENTO" 
      Else      
         @ 016,125 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
      Endif       
   Endif
Return

//----------------------------------------------------------- Emite nfs.
Static Function fImpSF2()
DbSelectArea("SQL")
DbGoTop()         
SetRegua(RecCount())
Do While.Not.Eof()
   
   nIcmsRet := F2_ICMSRET
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
   nVlrICMST:= 0
   cCfop    := ""
   cMensTes := ""
   xMEN_TRIB :={}
   xCLAS_FIS :={}
  	
   aMensTes:= {}
   cSQLNF := ""
   cSQLSR := ""
   cText := ""   
   CdESCRI := "" 
   cMenNota := ""
   cMensPed := ""
   lDadosIcms := .F.		
   nBIcms_ST  := 0
   nVlIcms_ST := 0
   nBIcmP_ST  := 0
   nVlIcmP_ST := 0
   nBaseIcms  := 0
   nVlIcms    := 0				
   
   nCol_num := 0    
   nCol_ven := 0
   nCol_Val := 0
   aTit     := {}
   aVal     := {}
   aVen     := {}
   
   
     
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
      
   If (SC5->C5_FILIAL = '01' .And. SC5->C5_TIPOCLI = 'S' ) .Or. (SC5->C5_FILIAL = '02' .And. Alltrim(SC5->C5_TIPOCLI) $ 'S/R' )
      lICMSUBS:= .T.      
   Else
      lICMSUBS := .F.     
   Endif

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
   For j:= 1 to len(aMensTes)
      cMensTes := Formula(aMensTes[j])      
   Next
   If !Empty(SC5->C5_MENPAD)  
      cMensPed := Formula(SC5->C5_MENPAD)
   EndIf
   cMenNota := SC5->C5_MENNOTA
   aTit :={}
   aVal :={}
   aVen :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   //FATURA
   If! Empty(SQL->F2_PREFIXO + SQL->F2_DUPL)
       Do While.Not.Eof().And.SQL->F2_PREFIXO + SQL->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
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
//     	    Aadd(aMerc,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,ALLTRIM(SC6->C6_DESCRI),SA7->A7_CODCLI,D2_LOTECTL,SB1->B1_GRUPO})
            Aadd(aMerc,{SB1->B1_COD,IIF(!EMPTY(Alltrim(SB5->B5_CEME)),Alltrim(SB5->B5_CEME),AllTrim(SB1->B1_DESC)),SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,ALLTRIM(SC6->C6_DESCRI),SA7->A7_CODCLI,D2_LOTECTL,SB1->B1_GRUPO,D2_DESCON,SC6->C6_DESCONT,SB1->B1_PESO,SC6->C6_ICMSRET})
         Endif                            
         
   
		 nBIcms_ST  += SQL->D2_BRICMS
         nVlIcms_ST += SQL->D2_ICMSRET
         
				
         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   Enddo         
      

   fCabSf2()
   
   
   //Número Título
   i:= 1 
   nCol_num := 62    
   nCol_Val := 85
   nCol_ven := 100
   nLin :=019
   
   If len(aTit) > 0
      If aTit[1][1] <> ''
         @ nLin, 062 pSay AllTrim(aTit[1][1])
         @ nLin, 085 pSay AllTrim(aVal[1][1])
         @ nLin, 103 pSay AllTrim(aVen[1][1])
      EndIf
   EndIf
   If len(aTit) > 2
      @ nLin, 118 pSay AllTrim(aTit[3][1])
      @ nLin, 140 pSay AllTrim(aVal[3][1])
      @ nLin, 160 pSay AllTrim(aVen[3][1])
   EndIf 
   If len(aTit) > 1
      nLin += 1 
      @ nLin, 062 pSay AllTrim(aTit[2][1])
      @ nLin, 085 pSay AllTrim(aVal[2][1])
      @ nLin, 103 pSay AllTrim(aVen[2][1])
   EndIf
   If len(aTit) > 3
      @ nLin, 118 pSay AllTrim(aTit[4][1])
      @ nLin, 140 pSay AllTrim(aVal[4][1])
      @ nLin, 160 pSay AllTrim(aVen[4][1])
   EndIf
   
   nLin += 1
   
   //Itens da Nota
   nMerc := 1   
   nLin := 024
   IF Alltrim(cTipo) $ "N/D/C/B"
      While nMerc <= Len(aMerc)
         @ nLin,000 pSay aMerc[nMerc][01]                       //Código Produto  
         If Empty(aMerc[nMerc][12])                             //ASK 07/07/2008 Alterado para buscar a descrição do pedido.        
            cDescri:= Alltrim(aMerc[nMerc][02])
         Else 
            cDescri:= Alltrim(aMerc[nMerc][12] )
         EndIf   
	     IF LEN(cDescri) > 80 
	        @ nLin,011 pSay SUBSTR(cDescri,1,80)                //Descrição Produto
		     nLin+=1
	         @ nLin,011 pSay SUBSTR(cDescri,81,80)              //Descrição Produto
	     ELSE	
	         @ nLin,011 pSay cDescri                            //Descrição Produto
		 ENDIF
	 	 If aMerc[nMerc][18]>0
		    @ nLin,082 pSay aMerc[nMerc][18]			                      //Peso Liquido (b1_peso)
	     EndIf  
	     @ nLin,093 pSay aMerc[nMerc][03]			                      //Classificação Fiscal
	     @ nLin,103 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,109 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,114 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,122 pSay aMerc[nMerc][07]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         @ nLin,137 pSay aMerc[nMerc][08]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,152 pSay aMerc[nMerc][09] Picture "99"               	  //% ICMS    
         @ nLin,157 pSay aMerc[nMerc][10] Picture "99"               	  //% IPI
         @ nLin,164 pSay aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI                   
         /*If aMerc[nMerc][16]>0
            nLin +=1
            @ nLin,016 pSay "Desconto "+Transform(aMerc[nMerc][17],"@E 999.99")+"%"       
            @ nLin,086 pSay aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"
         EndIf*/
         nLin  +=1
         If  nLin > 37
            i   :=1  
            nLin:=024  
            nPos:=16
            @ 046,100 pSay Chr(18)     
            @ 046,147 pSay AllTrim(cNota)  
            @ 051,000 pSay ""   
            SetPrc(0,0)  
            fCabSf2() 
         Endif       
         nMerc +=1
      End  

      // CALCULO DO IMPOSTO
     
      @ 039,002 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
      @ 039,023 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
          
      @ 039,040 pSay nBIcms_ST  Picture "@E 999,999,999.99" //Base ICMS Substituição	
      @ 039,068 pSay nVlIcms_ST Picture "@E 999,999,999.99" //Vlr  ICMS Substituição
      
      @ 039,094 pSay nVALMERC+nDescont Picture "@E 999,999,999.99" //Vlr Produtos
      
      @ 041,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
      @ 041,023 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
      @ 041,040 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
      @ 041,068 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
      @ 041,094 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
      
      //TRANSPORTADORA
      @ 043,000 pSay SA4->A4_NOME                
      If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
         @ 043,072 PSay "1"
      ElseIf SC5->C5_TPFRETE == "F"   
         @ 043,072 PSay "2"   
      Endif   
      @ 043,093 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
      @ 044,000 pSay SA4->A4_END
      @ 044,066 pSay SA4->A4_MUN
      @ 044,090 pSay SA4->A4_EST
      If AllTrim(SA4->A4_INSEST) == "ISENTO" 
         @ 044,094 pSay "ISENTO" 
      Else      
         @ 044,094 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
      Endif      
      @ 045,100 pSay Chr(18)     
      @ 045,146 pSay AllTrim(cNota)   

      @ 046,000 pSay Chr(15)           
      @ 046,004 pSay SC5->C5_VOLUME1
      @ 046,020 pSay SC5->C5_ESPECI1
      @ 046,070 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
      @ 046,094 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"
       
    
     
     
   //Impressão de Nota de Complemento de IPI
   Elseif Alltrim(cTipo) = "P"                                                                
      While nMerc <= Len(aMerc)
         nVlrIPI += aMerc[nMerc][11]
         nMerc +=1
      End 
         @ nLin,011 pSay "Complemento de IPI"                          //Descrição Produto 
         @ nLin,137 pSay nVlrIPI        Picture "@E 99,999.99"         //Vlr Total            
         @ 041,068  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr IPI Rodapé
         @ 041,094  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr Nota Rodapé
   //Impressão de Nota de Complemento de ICMS
   Else      
      If aMerc[nMerc][19] > 0
         While nMerc <= Len(aMerc)
            nVlrICMST += aMerc[nMerc][19]
            nMerc +=1
         End                 
         @ nLin,011  PSAY "COMPLEMENTO DE ICMS - ST"  
         @ 039,068    pSay nVlrICMST        Picture "@E 99,999.99"         //Vlr Total            
      Else   
	     @ nLin,011 pSay "Complemento de ICMS"                         //Descrição Produto 
         @ nLin,137 pSay nVALICM        Picture "@E 99,999.99"         //Vlr Total            
         @ 039 ,023  pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
      EndIf
      
   EndIf
   
      
     
   n1es:=1         
   n2es:=60
   nLin:=77     

   @ 045,000 pSay Chr(18)
   @ 047,065 pSay cNota
   @ 051,000 pSay ""   
   SetPrc(0,0)   

EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
                              
    @ 001,000 pSay Chr(15)    
    @ 001,001 pSay Substr(cMenNota,1,50)
    @ 002,001 pSay Substr(cMenNota,51,50)    
    
    @ 002,080 pSay Chr(18)    
    @ 002,126 pSay AllTrim(cNota)  
    @ 002,138 pSay AllTrim(cNota)  
  
    @ 003,000 pSay Chr(15)    
    @ 003,001 pSay Substr(cMenNota,101,50)    
    @ 004,001 pSay Substr(cMenNota,151,50)
    @ 005,001 pSay Substr(cMenNota,201,50)
    @ 006,001 pSay Substr(cMensTES,1,50)
    
    @ 007,000 pSay Chr(18) 
    @ 007,073 PSay "X"        

    @ 008,000 pSay Chr(15)   
    @ 008,001 pSay Substr(cMensTES,51,50)    
    @ 009,001 pSay Substr(cMensTES,101,50)   
    @ 011,001 pSay Substr(cMensPed,1,50)
    @ 011,060 pSay ALLTRIM(cText)
	@ 011,088 pSay cCfop 
	@ 012,001 pSay Substr(cMensPed,51,50)    
    @ 013,001 pSay Substr(cMensPed,101,50)      
    
   
   If! Alltrim(cTipo) $ "B/D"
       @ 013,060 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 013,124 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 013,124 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 013,124 pSay SA1->A1_CGC
       Endif   
       @ 013,160 pSay Dtoc(cEMISSAO)
       @ 014,001 pSay Substr(cMensPed,151,50)
       @ 015,060 pSay SA1->A1_END
       @ 015,114 pSay SA1->A1_BAIRRO
       @ 015,143 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 016,060 pSay SA1->A1_MUN
      // @ 017,066 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 016,118 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 016,125 pSay "ISENTO" 
       Else      
          @ 016,125 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 013,060 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 013,124 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 013,124 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 013,124 pSay SA2->A2_CGC
       Endif   
       @ 013,160 pSay Dtoc(cEMISSAO)
       @ 014,001 pSay Substr(cMensPed,151,50)
       @ 015,060 pSay SA2->A2_END
       @ 015,114 pSay SA2->A2_BAIRRO
       @ 015,143 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 016,060 pSay SA2->A2_MUN
     //  @ 017,066 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 016,118 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 016,125 pSay "ISENTO" 
       Else      
          @ 016,125 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_ICMSRET,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "D2_BRICMS,D2_ICMSRET,D2_BASEICM,D2_VALICM,"+Chr(10)+CHR(13)
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

