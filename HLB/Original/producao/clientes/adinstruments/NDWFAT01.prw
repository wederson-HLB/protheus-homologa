#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : NDWFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal ADInstruments - Entrada e Saída       
Autor     	: Tiago Luiz Mendonça
Data     	: 18/03/2009 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/
     
*-------------------------*
 User Function NDWFAT01()   
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
If cEmpAnt $ "DW"
   If Pergunte("NFDW01",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03                             
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else
    MsgInfo("Especifico ADInstruments ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - ADInstruments"
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
wnRel    := NomeProg := 'NDWFAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - ADInstruments")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - ADInstruments")
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
Do While.Not.Eof() .And. cTipo <> "C"

   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F1_FORNECE+SQL->F1_LOJA))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
   

   cMensagem:= " "
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
   cText		:={}  
   
   nPesoLiq:= F1_P_PESOL
   nPesoBru:= F1_P_PESOB
   nVolume := F1_P_VOLUM
   cEspecie:= F1_P_ESPV
   cTransp := F1_P_TRANS
   
   
   
   IF !empty(ALLTRIM(D1_OBS))
      cMensagem := D1_OBS 
   Endif
   
   fCabSf1()
   
   xMEN_TRIB:={}	
   xCLAS_FIS:={}
   nLin     :=25 
     
   If AllTrim(cTipo)$ "C"
      @ nLin,018 pSay "Complemento de Importacao"
      @ nLin,129 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total (corpo da nota)
      @ 047,120 pSay nVALBRUT Picture "@E 999,999,999.99"       //Vlr Total Nota (rodapé)
     	
      IF !empty(cMensagem)
         @ 057,002 pSay SUBSTR(cMensagem,1,70)
		 @ 058,002 pSay SUBSTR(cMensagem,71,70)
      EndIF 
		                                   
	  If !Empty(cMensTes)
         @ 059,002 pSay SUBSTR(cMensTes,1,70)
         @ 060,002 pSay SUBSTR(cMensTes,71,70)
      EndIf
		
	  @ 063,000 pSay Chr(27)+"2"
	  @ 063,000 pSay Chr(18) 
	  @ 064,072 pSay cNota
	  @ 066,000 pSay ""   
	  SetPrc(0,0) 

   Elseif AllTrim(cTipo)$ "I"    
      @ nLin,018 pSay "COMPLEMENTO DE ICMS"                  //Descrição Produto
      @ 045,035 pSay nVALICM  Picture "@E 999,999,999.99"    //Vlr  ICMS
   
      IF !empty(cMensagem)
         @ 057,002 pSay SUBSTR(cMensagem,1,70)
         @ 058,002 pSay SUBSTR(cMensagem,71,70)
      EndIF
			
      @ 063,000 pSay Chr(27)+"2"
      @ 063,000 pSay Chr(18)
      @ 064,072 pSay cNota
      @ 066,000 pSay ""   
      SetPrc(0,0) 	       
      
   Else
      While F1_DOC+F1_SERIE == cCompara           
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
         
         If Ascan(cText, SF4->F4_TEXTO)==0
	        AADD(cText , SF4->F4_TEXTO)
         Endif 	  		
     	 	
         @ nLin,000 pSay SB1->B1_COD                               	//Código Produto
         @ nLin,018 pSay SB1->B1_DESC                              	//Descrição Produto
         @ nLin,060 pSay SB1->B1_POSIPI                            	//Classificação fiscal
         @ nLin,074 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            	//Situação Tributária
         @ nLin,081 pSay SB1->B1_UM                                	//Unidade
         @ nLin,080 pSay D1_QUANT  Picture "@E@Z 999,999.99"       	//Quantidade
         @ nLin,089 pSay D1_VUNIT  Picture "@E@Z 99,999,999.99"    	//Vlr Unitário    
         @ nLin,103 pSay D1_TOTAL  Picture "@E@Z 999,999,999.99"   	//Vlr Total
         @ nLin,122 pSay D1_PICM   Picture "99"               		//%ICMS    
         @ nLin,126 pSay D1_IPI    Picture "99"                  	//%IPI  
         @ nLin,129 pSay D1_VALIPI Picture "@E 99,999.99"          	//Vlr IPI
         
         IncRegua(F1_SERIE+" "+F1_DOC) 
       	
         DbSkip()
         
         nLin  +=1
         
         If nLin == 60
         
            @ 063,000 pSay Chr(27)+"2"
   			@ 063,000 pSay Chr(18)
   	  		@ 064,072 pSay cNota
		    @ 066,000 pSay ""   
   	  		SetPrc(0,0)  
         	fCabSf1()
           	nLin :=23   
           	                                                        	
         Endif      
      EndDo      
      
      // CALCULO DO IMPOSTO
      @ 054,001 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
	  @ 054,035 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
	  @ 054,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
	  @ 057,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
	  @ 057,035 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
	  @ 057,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
	  @ 057,084 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
	  @ 057,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota  
	  
	        	 
      If !Empty(cTransp)          
	     
	     SA4->(DbSetOrder(1))
         If SA4->(DbSeek("  "+Alltrim(cTransp)))   
            @ 060,001 pSay SA4->A4_NOME     
            @ 060,087 PSay "1"                            //Frete por conta do Emitente
            @ 060,117 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
            @ 063,001 pSay SA4->A4_END
            @ 063,077 pSay SA4->A4_MUN
            @ 063,109 pSay SA4->A4_EST
            If AllTrim(SA4->A4_INSEST) == "ISENTO" 
               @ 063,117 pSay "ISENTO" 
            Else      
               @ 063,117 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
            Endif       
            @ 065,003 pSay nVolume
            @ 065,028 pSay cEspecie
            @ 065,098 pSay nPesoBru        Picture "@E@Z 999,999,999.99"
            @ 065,120 pSay nPesoLiq        Picture "@E@Z 999,999,999.99"
         EndIf
      EndIf
	  
	  	
	  IF !empty(cMensagem)
	     @ 070,002 pSay SUBSTR(cMensagem,1,70)
		 @ 071,002 pSay SUBSTR(cMensagem,71,70)
      EndIF
          
	  @ 072,000 pSay Chr(27)+"2"
	  @ 072,000 pSay Chr(18)
	  @ 079,072 pSay cNota
	  @ 080,000 pSay ""   
	  SetPrc(0,0) 
   Endif
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
   @ 001,000 pSay Chr(18)
   @ 003,056 PSay "X"
   @ 003,072 pSay Alltrim(cNota)
   @ 005,000 pSay Chr(15)
   @ 008,001 pSay SF4->F4_TEXTO 
   
	@ 008,042 pSay SQL->D1_CF
  	
   If! AllTrim(cTipo) $ "B/D"
      @ 011,001 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 011,088 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 011,088 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 011,088 pSay SA2->A2_CGC
      Endif   
      @ 011,126 pSay Dtoc(cEMISSAO)
      @ 013,001 pSay SA2->A2_END
      @ 013,074 pSay SA2->A2_BAIRRO
      @ 013,106 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 015,001 pSay SA2->A2_MUN
      @ 015,055 pSay SA2->A2_TEL   
      @ 015,086 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 015,093 pSay "ISENTO" 
      Else      
	      @ 015,093 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
      Endif       
	   Else   
      @ 011,001 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 011,088 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 011,088 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 011,088 pSay SA1->A1_CGC
      Endif   
      @ 011,126 pSay Dtoc(cEMISSAO)
      @ 013,001 pSay SA1->A1_END
      @ 013,074 pSay SA1->A1_BAIRRO
      @ 013,106 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 015,001 pSay SA1->A1_MUN
      @ 015,055 pSay SA1->A1_TEL   
      @ 015,086 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 015,093 pSay "ISENTO" 
      Else      
         @ 015,093 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
      Endif       
   Endif
   @ 016,000 pSay Chr(27)+"0"
Return

//----------------------------------------------------------- Emite nfs.
Static Function fImpSF2()
DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()      

   lICMSUBS :=.F. 
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
   xMEN_TRIB :={}
   xCLAS_FIS :={}
   nBsIcmRet:=nIcmsRet:=0
  				
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

           
   If !Empty(SF4->F4_FORMULA)
      cMensTes := Formula(SF4->F4_FORMULA)       
   Else
      cMensTes := Formula(SC5->C5_MENPAD)       
   EndIf
   
   
   aTit :={}
   aVal :={}
   aVen :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
//FATURA
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ (SE1->E1_PREFIXO)+(SE1->E1_NUM)+Space(1)+(SE1->E1_PARCELA)})
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})
          Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
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
            Aadd(aMerc,{SB1->B1_COD,IIF(!EMPTY(Alltrim(SB5->B5_CEME)),Alltrim(SB5->B5_CEME),AllTrim(SB1->B1_DESC)),SB1->B1_POSIPI,;
            SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,ALLTRIM(SC6->C6_DESCRI),;
            SA7->A7_CODCLI,D2_LOTECTL,SB1->B1_GRUPO,D2_DTVALID})
         Endif   

  			If Ascan(cText, SF4->F4_TEXTO)==0
				AADD(cText , SF4->F4_TEXTO)
			Endif
           
          If SQL->D2_EST $ SM0->M0_ESTCOB
            If! SQL->D2_CF $ cCfop
			      cCfop += SQL->D2_CF+"/"      
	         Endif             
         Elseif AllTrim(SQL->D2_EST) = 'EX'                 
            If! Right(SQL->D2_CF,4) $ cCfop    
               cCfop += "7"+Right(SQL->D2_CF,4)+"/"
             Endif
         Elseif SQL->D2_EST <> SM0->M0_ESTCOB
            If! Right(SQL->D2_CF,4) $ cCfop    
               cCfop += "6"+Right(SQL->D2_CF,4)+"/"
             Endif                          
         Else
            If! Right(SQL->D2_CF,4) $ cCfop    
               cCfop += "6"+Right(SQL->D2_CF,4)+"/"
            Endif 
         Endif    
         
         If  !Empty(SQL->D2_BRICMS) .And. !Empty(SQL->D2_ICMSRET)
            nBsIcmRet  += SQL->D2_BRICMS
            nIcmsRet   += SQL->D2_ICMSRET  
            lICMSUBS:=.T.
         EndIf 
         
         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         
   fCabSf2()
   
//IMPRIME FATURA
   i    :=1
   nCol :=8
   nLin :=018
   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol +=15
      i +=1
   End
   nLin +=1
   nCol :=7
   i    :=1
	While i <= Len(aVal)
      @ nLin,nCol pSay aVal[i][1]
      nCol +=15
      i +=1        
   End     
   //Endereco de cobranca
 	if  !EMPTY(SA1->A1_ENDCOB)
		@ nLin,095 PSAY SA1->A1_ENDCOB
   ENDIF       
   nLin +=1
   //Endereco de cobranca   
	if  !EMPTY(SA1->A1_ENDCOB)
		@ nLin,095 PSAY "Bairro: " + SA1->A1_BAIRROC
		@ nLin,123 PSAY "CEP: " + SA1->A1_CEPC		
   ENDIF        
   nCol :=9
   i    :=1   
   While i <= Len(aVen)
      @ nLin,nCol pSay aVen[i][1]
      nCol +=15
      i +=1
   End
      
// Impressão Endereço de Cobrança      
	if  !EMPTY(SA1->A1_ENDCOB)
		@ nLin,095 PSAY "Mun: "+SA1->A1_MUNC
		@ nLin,125 PSAY "Est: "+SA1->A1_ESTC		
   ENDIF    

   nMerc :=1
   nLin  :=23
   nPos  :=1
 IF Alltrim(cTipo) $ "N/D/C/B"
   While nMerc <= Len(aMerc)
         @ nLin,000 pSay aMerc[nMerc][01]                                 //Código Produto
			IF LEN(aMerc[nMerc][02]) > 37
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],1,37)                                 //Descrição Produto
				nLin+=1 
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],38,37)                                 //Descrição Produto
				IF LEN(aMerc[nMerc][02]) > 75
					nLin+=1
		         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],76,37)                                 //Descrição Produto		
				ENDIF
			ELSE	
	         @ nLin,018 pSay aMerc[nMerc][02]                                 //Descrição Produto       
			ENDIF
	      @ nLin,060 pSay aMerc[nMerc][03]			                          //Classificação Fiscal
	      @ nLin,074 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,079 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,080 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,089 pSay aMerc[nMerc][07] Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         @ nLin,103 pSay aMerc[nMerc][08] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,121 pSay aMerc[nMerc][09] Picture "99"               	  //% ICMS    
         @ nLin,125 pSay aMerc[nMerc][10] Picture "99"               	  //% IPI
         @ nLin,129 pSay aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI
         nLin  +=1   
         If !Empty(aMerc[nMerc][14])
            @ nLin,018 pSay "LOTE :"+aMerc[nMerc][14]
            @ nLin,042 pSay "VALIDADE :"+DTOC(aMerc[nMerc][16])
		 EndIf
		 nLin+=1
         If nMerc > 18.And.nMerc <= Len(aMerc)
            i   :=1  
            nLin:=53  
            nPos:=16
            While i <= Len(aMerc)
                 If Len(aMerc[i][03]) > 0.And.nLin <= 70
                    @ nLin,000 pSay aMerc[i][03]
                    nLin += 1
                 Endif
               i +=1     
     				@ 063,000 pSay Chr(18)
     				@ 064,072 pSay cNota
	  				@ 066,000 pSay ""   
     				SetPrc(0,0)          
            End        
           fCabSf2()
            
         Endif       
         nMerc +=1
   End

// CALCULO DO IMPOSTO  
   IF !lICMSUBS    //SE for .F. ele imprime o icms normal                         
      @ 045,001  PSAY nBASEICM       Picture "@E 999,999,999.99"  // Base do ICMS
	  @ 045,035  PSAY nVALICM		 Picture "@E 999,999,999.99"  // Valor do ICMS
   ELSE		  // SE for .T. ele imprime o icms substituição          
	  @ 045,060  PSAY nBsIcmRet	   Picture "@E 999,999,999.99"  // Base ICMS Ret.
	  @ 045,060  PSAY nIcmsRet      Picture "@E 999,999,999.99"  // Valor  ICMS Ret.  
   EndIf	  
   @ 045,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 047,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 047,035 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 047,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 047,084 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 047,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
//TRANSPORTADORA
   @ 050,001 pSay SA4->A4_NOME                
   If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
      @ 050,086 PSay "1"
   ElseIf SC5->C5_TPFRETE == "F"   
      @ 050,086 PSay "2"   
   Endif   
   @ 050,117 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 052,001 pSay SA4->A4_END
   @ 052,073 pSay SA4->A4_MUN
   @ 052,106 pSay SA4->A4_EST
   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
   @ 052,117 pSay "ISENTO" 
      Else      
   @ 052,117 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   Endif       
   @ 054,003 pSay SC5->C5_VOLUME1
   @ 054,035 pSay SC5->C5_ESPECI1
   @ 054,100 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
   @ 054,120 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"
   @ 057,001 pSay SUBSTR(SC5->C5_MENNOTA,1,70)
   @ 058,001 pSay SUBSTR(SC5->C5_MENNOTA,71,70)   
   @ 059,001 pSay SUBSTR(SC5->C5_MENNOTA,141,70)      
  
	If! Empty(cMensTes)
	   @ 060,001 pSay SUBSTR(cMensTes,1,72)
	   @ 061,001 pSay SUBSTR(cMensTes,73,100)
   ENDIF
   
 Elseif Alltrim(cTipo) = "P"                                                                
      While nMerc <= Len(aMerc)
         nVlrIPI += aMerc[nMerc][11]
         nMerc +=1
      End 
         @ nLin,018 pSay "Complemento de IPI"                          //Descrição Produto 
         @ nLin,099 pSay nVlrIPI        Picture "@E 99,999.99"         //Vlr Total            
         @ 046,084  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr IPI Rodapé
         @ 046,120  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr Nota Rodapé
         @ 057,001  pSay SUBSTR(SC5->C5_MENNOTA,1,80)       
 Elseif Alltrim(cTipo) = "I"                                                                
         @ nLin,018 pSay "Complemento de ICMS"                         //Descrição Produto 
         @ 046,038  pSay nVALICM        Picture "@E 99,999.99"         //Vlr Total            
         //@ 057,120  pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
         @ 057,005  pSay SUBSTR	(SC5->C5_MENNOTA,1,80) 
EndIf
   
   
   
   n1es:=1         
   n2es:=60
   nLin:=77     

     @ 063,000 pSay Chr(18)
     @ 064,072 pSay cNota
     @ 066,000 pSay ""   
     SetPrc(0,0)   


EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 001,000 pSay Chr(18)
   @ 003,048 PSay "X"
   @ 003,072 pSay AllTrim(cNota)
   @ 005,000 pSay Chr(15)

	FOR I := 1 TO LEN(cText)                                          
	 col := Len(Alltrim(cText[1]))+1
   	IF I == 1
   		@ 009,001 pSay ALLTRIM(cText[1])
   	ENDIF
   	IF cText[I] <> cText[1]
	   	@ 009,col pSay "/"+cText[I]
   	endif
   NEXT

	@ 009,042 pSay cCfop
   
   If! Alltrim(cTipo) $ "B/D"
       @ 011,001 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 011,88 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 011,88 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 011,88 pSay SA1->A1_CGC
       Endif   
       @ 011,126 pSay Dtoc(cEMISSAO)
       @ 013,001 pSay SA1->A1_END
       @ 013,072 pSay SA1->A1_BAIRRO
       @ 013,106 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 015,001 pSay SA1->A1_MUN
       @ 015,055 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 015,083 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 015,90 pSay "ISENTO" 
       Else      
          @ 015,90 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 011,001 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 011,88 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 011,88 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 011,88 pSay SA2->A2_CGC
       Endif   
       @ 011,126 pSay Dtoc(cEMISSAO)
       @ 013,001 pSay SA2->A2_END
       @ 013,072 pSay SA2->A2_BAIRRO
       @ 013,106 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 015,001 pSay SA2->A2_MUN
       @ 015,055 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 015,083 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 015,87 pSay "ISENTO" 
       Else      
          @ 015,87 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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

cQuery := "SELECT D2_TES,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,D2_EST,D2_CF, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_BRICMS,D2_ICMSRET, D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,D2_DTVALID,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
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


