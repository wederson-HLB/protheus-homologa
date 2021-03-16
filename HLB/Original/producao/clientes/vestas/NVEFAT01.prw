#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : NVEFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Vestas - Imprimir notas de entradas e saída
Autor     	: Tiago Luiz Mendonça
Data     	: 01/06/2009 
Obs         : FONTE 10 / DRAFT
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*-------------------------*                                                
 User Function NVEFAT01()   
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
If cEmpAnt $ "VE"
   If Pergunte("NFVE01",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif   
Else
    MsgInfo("Especifico Vestas ","A T E N C A O")  
Endif                                   

Return
                                                              
//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Vestas"
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
wnRel    := NomeProg := 'NVEFAT01'
cTipo    := ""
nLinMen  := 070                            

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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Vestas")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Vestas")
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
   cText		:={}
   cCfop    := D1_CF            
   fCabSf1()
	xMEN_TRIB:={}
   xCLAS_FIS:={}
   nLin     :=20
   cOBS:= ""
   
   
//FR
   SD1->(DbSetOrder(1))
   IF SD1->(DbSeek(xFilial("SD1")+SQL->F1_DOC+SQL->F1_SERIE))
	   Do While.Not.Eof().And.SQL->F1_DOC + SQL->F1_SERIE == SD1->D1_DOC + SD1->D1_SERIE
	   		If SD1->D1_ITEM == "0001"
		          If !Empty(SD1->D1_OBS) 
		          	cOBS += SD1->D1_OBS		          
		          Endif		    	
	        Endif
	        SD1->(DbSkip())
	   EndDo
   ENDIF
//FR   
   
   
   
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

         @ nLin,002 pSay SB1->B1_COD                               	//Código Produto
         @ nLin,013 pSay SB1->B1_DESC                              	//Descrição Produto
         //@ nLin,058 pSay SB1->B1_POSIPI                            	//Classificação fiscal
         @ nLin,075 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            	//Situação Tributária
         @ nLin,080 pSay SB1->B1_UM                                	//Unidade
         @ nLin,085 pSay D1_QUANT  Picture "@E@Z 999,999" 				//Quantidade
         @ nLin,098 pSay D1_VUNIT  Picture "@E@Z 9999999.999"    	//Vlr Unitário    
         @ nLin,110 pSay D1_TOTAL  Picture "@E@Z 9999999.99"   	//Vlr Total
         @ nLin,121 pSay D1_PICM   Picture "99"               		//%ICMS    
         @ nLin,125 pSay D1_IPI    Picture "99"               		//%IPI
         @ nLin,126 pSay D1_VALIPI Picture "@R 999,999,999.99"          	//Vlr IPI  
                           
         //TLM 
         nLin  +=1  
         @ nLin,023 pSay "NCM : "			          		//Classificação Fiscal 
         @ nLin,030 pSay  SB1->B1_POSIPI			        //Classificação Fiscal       
       
       	IncRegua(F1_SERIE+" "+F1_DOC) 
         DbSkip()
         nLin  +=1
         	If nLin > 37  
               @ 060,000 pSay Chr(18)
               @ 061,070 pSay cNota
               @ 066,000 pSay ""   
               SetPrc(0,0)   
           	   fCabSf1()
           	   nLin :=20
         	Endif
   End         
// CALCULO DO IMPOSTO
   @ 040,001 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 040,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS  
   
   If !Empty(nBrICMS) .and. !Empty(nIcmsRet)
      @ 040,060 pSay nBrICMS  Picture "@E 999,999,999.99" //Base ICMS Substituição	
      @ 040,084 pSay nIcmsRet Picture "@E 999,999,999.99" //Vlr  ICMS Substituição
   EndIf
   
   @ 040,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 042,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 042,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 042,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 042,090 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 042,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota  
   
   //TRANSPORTADORA - ENTRADA
      @ 045,002 pSay SA4->A4_NOME                
      @ 045,071 PSay "1"   
      @ 045,115 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
      @ 047,002 pSay SA4->A4_END
      @ 047,053 pSay SA4->A4_MUN
      @ 047,100 pSay SA4->A4_EST
      If AllTrim(SA4->A4_INSEST) == "ISENTO" 
         @ 047,115 pSay "ISENTO" 
      Else      
         @ 047,115 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
      Endif       
      @ 049,005 pSay nVOLUME
      @ 049,018 pSay nESPECIE
      @ 049,090 pSay nPBRUTOE          Picture "@E@Z 999,999,999.99"
      @ 049,120 pSay nPLIQUIE          Picture "@E@Z 999,999,999.99"
		
   If  !Empty(cMensTes)
	  	@ 051,002 pSay SUBSTR(cMensTes,1,65)
		@ 052,002 pSay SUBSTR(cMensTes,66,65) 
		@ 053,002 pSay SUBSTR(cMensTes,131,65)
	EndIf
	
	If !Empty(cOBS)
		@054,002 pSay SUBSTR(cOBS,1,65)
		@055,002 pSay SUBSTR(cOBS,66,65)
		@056,002 pSay SUBSTR(cOBS,131,65)
	Endif


   @ 059,000 pSay Chr(27)+"2"
   @ 060,000 pSay Chr(18)
   @ 061,071 pSay cNota
   @ 066,000 pSay ""   
   SetPrc(0,0) 
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1() 

   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
   
   @ 001,000 pSay Chr(18)
   @ 001,058 PSay "X"
   @ 001,072 pSay Alltrim(cNota)
   @ 005,000 pSay Chr(15)
   @ 006,003 pSay SF4->F4_TEXTO
   @ 006,043 pSay cCfop
  	
   If! AllTrim(cTipo) $ "B/D"
      @ 009,003 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 009,087 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 009,087 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 009,087 pSay SA2->A2_CGC
      Endif   
      @ 009,124 pSay Dtoc(cEMISSAO)
      @ 011,003 pSay SA2->A2_END
      @ 011,068 pSay SA2->A2_BAIRRO
      @ 011,105 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 013,003 pSay SA2->A2_MUN
      @ 013,053 pSay SA2->A2_TEL   
      @ 013,080 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 013,090 pSay "ISENTO" 
      Else      
	      @ 013,090 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
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
      @ 009,124 pSay Dtoc(cEMISSAO)
      @ 011,003 pSay SA1->A1_END
      @ 011,073 pSay SA1->A1_BAIRRO
      @ 011,105 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 013,003 pSay SA1->A1_MUN
      @ 013,053 pSay SA1->A1_TEL   
      @ 013,080 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 013,090 pSay "ISENTO" 
      Else      
         @ 013,090 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
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
   //nICMSRET := F2_ICMSRET //ASK 08/04/08 - Substituição Tributária
   //nBRICMS  := F2_BRICMS  //ASK 08/04/08 - Substituição Tributária
   cCfop    := ""
   cMensTes := ""
   xMEN_TRIB :={}
   xCLAS_FIS :={}
   aMensTes  :={}
	
	lDadosIcms := .F.		
			
   nBIcms_ST  := 0
   nVlIcms_ST := 0
   nBIcmP_ST  := 0
   nVlIcmP_ST := 0
   nBaseIcms  := 0
   nVlIcms    := 0
   nVlrICMST  := 0
                         
   
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
                               

   //ASK 08/04/08 - Substituição Tributária a fim de imprimir ou não as bases / vlr icms
   //ASK 02/06/08 - Chamado 26478 A partir de Junho/08 outros estados possuirão Substituição Tributária.
   If /*SQL->F2_EST = 'SP' .and.*/ SC5->C5_TIPOCLI = 'S'
	   lICMSUBS:= .T.      // Se for SP e pessoa Jurídica,
	   						  //imprime base e valor do icms de substituição e não imprime a base/vlr do icms normal
   Else
	   lICMSUBS := .F.     
   Endif

   cMensTes := Formula(SC5->C5_MENPAD)          
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
   EndIf    
   cText	:=""
   
   If! Alltrim(SQL->D2_CF) $ cCfop
      If Len(Alltrim(cCfop)) < 1 
         cCfop += Alltrim(SQL->D2_CF)
      Else
         cCfop +="/"+ Alltrim(SQL->D2_CF)
      EndIf
   Endif
         
   If SF4->(DbSeek(xFilial()+SQL->D2_TES))
      If! Alltrim(SF4->F4_TEXTO) $ cText
         If Len(Alltrim(cText)) <	 1 
            cText += Alltrim(SF4->F4_TEXTO)
         Else
            cText +="/"+Alltrim(SF4->F4_TEXTO)
         EndIf
      Endif
   EndIf
   
       
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
            Aadd(aMerc,{SB1->B1_COD,IIF(!EMPTY(Alltrim(SB5->B5_CEME)),Alltrim(SB5->B5_CEME),AllTrim(SB1->B1_DESC)),;
            SB1->B1_POSIPI,Alltrim(SB1->B1_ORIGEM)+AllTrim(SF4->F4_SITTRIB),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,;
            D2_PICM,D2_IPI,D2_VALIPI,ALLTRIM(SC6->C6_DESCRI),SA7->A7_CODCLI,D2_LOTECTL,SB1->B1_GRUPO,D2_DESCON,SC6->C6_DESCONT,SC6->C6_ICMSRET})
         Endif   

         If lIcmSubs
            nBIcms_ST  += SQL->D2_BRICMS
            nVlIcms_ST += SQL->D2_ICMSRET
            nBIcmP_ST  += SQL->D2_BASEICM
            nVlIcmP_ST += SQL->D2_VALICM
            lDadosICMS:= .T.
         EndIf
         
         nBaseIcms += SQL->D2_BASEICM
         nVlIcms   += SQL->D2_VALICM
                     
         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         
   
   fCabSf2()
   
//IMPRIME FATURA
   i    :=1
   nCol :=13
   nLin :=16
        
   While i <= Len(aTit)
      If i<2
         @ nLin,nCol    pSay Alltrim(aTit[i][1])
         @ nLin,nCol+25 pSay AllTrim(aVal[i][1])
         @ nLin,nCol+49 pSay AllTrim(aVen[i][1])
      ElseIf i=2
         @ nLin,nCol+70  pSay Alltrim(aTit[i][1])
         @ nLin,nCol+90  pSay AllTrim(aVal[i][1])
         @ nLin,nCol+113 pSay AllTrim(aVen[i][1])
      EndIf   
      i ++
   EndDo
  

   nMerc :=1
   nLin  :=20            
   nPos  :=1
   

   If Alltrim(cTipo) $ "N/D/C/B"
      While nMerc <= Len(aMerc) 
        	@ nlin,000 PSAY CHR(15)
         @ nLin,002 pSay aMerc[nMerc][01]                                 						 //Código Produto
	      If LEN(aMerc[nMerc][02]) > 55
	         @ nLin,014 pSay alltrim(SUBSTR(aMerc[nMerc][02],1,55))                 						 //Descrição Produto
		      nLin+=1
	         @ nLin,013 pSay alltrim(SUBSTR(aMerc[nMerc][02],56,55))                						 //Descrição Produto
         Else	
	         @ nLin,014 pSay aMerc[nMerc][02]                              						 //Descrição Produto
		   EndIf 
	     //@ nLin,060 pSay aMerc[nMerc][03]			          						                //Classificação Fiscal
	     @ nLin,075 pSay aMerc[nMerc][04]						                                  //Situação Tributária
         @ nLin,080 pSay aMerc[nMerc][05]                                 						 //Unidade
         @ nLin,084 pSay aMerc[nMerc][06] Picture "@E@Z 999,999"   						       //Quantidade
         @ nLin,094 pSay aMerc[nMerc][07]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.999"     //Vlr Unitário    
         @ nLin,106 pSay aMerc[nMerc][08]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,120 pSay aMerc[nMerc][09] Picture "99"        						             //% ICMS    
         @ nLin,124 pSay aMerc[nMerc][10] Picture "99"               	  						 //% IPI
         @ nLin,125 pSay aMerc[nMerc][11] Picture "@R 999,999,999.99"          	                 //Vlr IPI                   
         
         
           nLin  +=1  
         @ nLin,023 pSay "NCM : "			          		//Classificação Fiscal 
         @ nLin,030 pSay  aMerc[nMerc][03]			        //Classificação Fiscal  
          
           
         /*
         If aMerc[nMerc][16]>0
            nLin +=1
            @ nLin,018 pSay "Desconto "+Transform(aMerc[nMerc][17],"@E 999.99")+"%"       
            @ nLin,101 pSay aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"
         EndIf   
         */
         nLin  +=1  
         If nLin > 37  
               @ 058,000 pSay Chr(18)
               @ 061,072 pSay cNota
               @ 066,000 pSay ""   
               SetPrc(0,0)   
           	   fCabSf2()
           	   nLin :=20
         	Endif
    
        /* If nLin == 37.And.nMerc <= Len(aMerc)
            If nMerc <> Len(aMerc)
      		   @ 058,000 pSay Chr(18)
  		       @ 061,072 pSay cNota
	           @ 066,000 pSay ""
   		       SetPrc(0,0)	      
			   fCabSf2()
			   nLin:=20
            Endif  
         EndIf*/       
         nMerc +=1
      EndDo
      
      @ 040,002 pSay nBaseIcms Picture "@E 999,999,999.99" //Base ICMS
      @ 040,038 pSay nVlIcms  Picture "@E 999,999,999.99" //Vlr  ICMS                  
      
      If lICMSubs
         @ 040,060 pSay nBIcms_ST  Picture "@E 999,999,999.99" //Base ICMS Substituição	
         @ 040,084 pSay nVlIcms_ST Picture "@E 999,999,999.99" //Vlr  ICMS Substituição
      EndIf
            
      @ 040,120 pSay nVALMERC+nDescont Picture "@E 999,999,999.99" //Vlr Produtos
      @ 042,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
      @ 042,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
      @ 042,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
      @ 042,087 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI 
      @ 042,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
      //TRANSPORTADORA
      @ 045,002 pSay SA4->A4_NOME                
      If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
         @ 045,070 PSay "1"
      ElseIf SC5->C5_TPFRETE == "F"   
         @ 045,070 PSay "2"   
      Endif   
      @ 045,115 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
      @ 047,002 pSay SA4->A4_END
      @ 047,073 pSay SA4->A4_MUN
      @ 047,100 pSay SA4->A4_EST
      If AllTrim(SA4->A4_INSEST) == "ISENTO" 
         @ 047,115 pSay "ISENTO" 
      Else      
         @ 047,115 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
      Endif       
      @ 049,005 pSay SC5->C5_VOLUME1
      @ 049,035 pSay SC5->C5_ESPECI1
      @ 049,090 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
      @ 049,120 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"

		xTES := fCallTES(_cDaNota,_cSerie)
		If len(xTES) > 0
			For nt:= 1 to len(xTES)
				SF4->(DbSetOrder(1)) 
				SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))				
				If !Empty(SF4->F4_FORMULA)
					Aadd(aMensTes,SF4->F4_FORMULA)	
				Endif
			Next
	    Endif
     
     DbSelectArea("SQL")      
                                                 
   
     If !EMPTY(cMensTes)
	     @ 051,002 pSay SUBSTR(cMensTes,1,75) //052
	     @ 052,002 pSay SUBSTR(cMensTes,76,75)     //053
	  EndIf   
 
      @ 053,002 pSay SUBSTR(SC5->C5_MENNOTA,1,75)	   //054
      @ 054,002 pSay SUBSTR(SC5->C5_MENNOTA,76,75)          //055
      @ 055,002 pSay SUBSTR(SC5->C5_MENNOTA,151,75)              //056
      @ 056,002 pSay SUBSTR(SC5->C5_MENNOTA,226,75)// RAM 111209      //057   
      @ 057,002 pSay SUBSTR(SC5->C5_MENNOTA,301,75)
      
   ElseIf Alltrim(cTipo) = "P"                                                                
      While nMerc <= Len(aMerc)
         nVlrIPI += aMerc[nMerc][11]
         nMerc +=1
      End 
         @ nLin,018 pSay "Complemento de IPI"                          //Descrição Produto 
         @ nLin,099 pSay nVlrIPI        Picture "@E 99,999.99"         //Vlr Total            
         @ 042,087  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr IPI Rodapé
         @ 042,120  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr Nota Rodapé
			@ 053,001 pSay SUBSTR(SC5->C5_MENNOTA,1,75)            //052	
			@ 054,001 pSay SUBSTR(SC5->C5_MENNOTA,76,75)                 //053
			@ 055,001 pSay SUBSTR(SC5->C5_MENNOTA,151,75)                     //054
			@ 056,001 pSay SUBSTR(SC5->C5_MENNOTA,226,75)// RAM 111209             //055
			@ 057,001 pSay SUBSTR(SC5->C5_MENNOTA,301,75)// RAM 111209                  //056  
   Else 
      If aMerc[nMerc][18] > 0
         While nMerc <= Len(aMerc)
            nVlrICMST += aMerc[nMerc][18]
            nMerc +=1
         End                               
         @ nLin,018 pSay "Complemento de ICMS ST"                        //Descrição Produto 
         @ nLin,099 pSay nVlrICMST        Picture "@E 999,999,999.99"    //Vlr Total            
         @ 040,087  pSay nVlrICMST        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
         @ 040,120  pSay nVlrICMST        Picture "@E 999,999,999.99"    //Vlr Nota
			@ 053,001 pSay SUBSTR(SC5->C5_MENNOTA,1,75)             //052
			@ 054,001 pSay SUBSTR(SC5->C5_MENNOTA,76,75)                 //053
			@ 055,001 pSay SUBSTR(SC5->C5_MENNOTA,151,75)                     //054
			@ 056,001 pSay SUBSTR(SC5->C5_MENNOTA,226,75)// RAM 111209             //055
			@ 057,001 pSay SUBSTR(SC5->C5_MENNOTA,301,75)// RAM 111209                  //056
		Else	                                 
         //@ nLin,018 pSay "Complemento de ICMS"                         //Descrição Produto 
         //@ nLin,099 pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr Total    
           @ nLin,018 pSay "Complemento de ICMS "                                //Descrição Produto 
           @ nLin,099 pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr Total                         
           @ 040,038  pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
		   @ 053,001 pSay SUBSTR(SC5->C5_MENNOTA,1,75)     //052   
		   @ 054,001 pSay SUBSTR(SC5->C5_MENNOTA,76,75)         //053
		   @ 055,001 pSay SUBSTR(SC5->C5_MENNOTA,151,75)            //054
		   @ 056,001 pSay SUBSTR(SC5->C5_MENNOTA,226,75)// RAM 111209    //055
		   @ 057,001 pSay SUBSTR(SC5->C5_MENNOTA,301,75)// RAM 111209         //056
	   EndIf
	EndIf
   
   n1es:=1         
   n2es:=60  
    
		@ 058,000 pSay Chr(18)
  		@ 061,072 pSay cNota
		@ 064,000 pSay ""
   	SetPrc(0,0)

EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   
   @ 001,000 pSay Chr(18)
   @ 001,048 PSay "X"
   @ 001,073 pSay AllTrim(cNota)
   @ 005,000 pSay Chr(15)
   
   @ 006,002 pSay cText
   @ 006,040 pSay cCfop
   
   If! Alltrim(cTipo) $ "B/D"
       @ 009,002 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 009,088 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 009,088 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,088 pSay SA1->A1_CGC
       Endif   
       @ 009,127 pSay Dtoc(cEMISSAO)
       @ 011,002 pSay SA1->A1_END
       @ 011,072 pSay SA1->A1_BAIRRO
       @ 011,104 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 013,002 pSay SA1->A1_MUN
       @ 013,058 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 013,079 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 013,091 pSay "ISENTO" 
       Else      
          @ 013,091 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 009,002 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 009,088 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 009,088 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,088 pSay SA2->A2_CGC
       Endif   
       @ 009,127 pSay Dtoc(cEMISSAO)
       @ 011,002 pSay SA2->A2_END
       @ 011,072 pSay SA2->A2_BAIRRO
       @ 011,104 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 013,002 pSay SA2->A2_MUN
       @ 013,058 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 013,079 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 013,091 pSay "ISENTO" 
       Else      
          @ 013,091 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
cQuery += "SF1.F1_DOC = SD1.D1_DOC AND "+Chr(10)  
cQuery += "SF1.F1_SERIE = SD1.D1_SERIE AND "+Chr(10)
cQuery += "SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "+Chr(10)    
cQuery += "AND SF1.F1_FORMUL = 'S' AND SD1.D1_FORMUL = 'S' "+Chr(10)
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
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_ICMSRET, F2_BRICMS,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "D2_BRICMS,D2_ICMSRET,D2_BASEICM,D2_VALICM,D2_BASEICM,D2_VALICM,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO, F2_EST "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC = SD2.D2_DOC AND "+Chr(10) 
cQuery += "SF2.F2_SERIE =SD2.D2_SERIE AND "+Chr(10)
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

/*-------------------------*/
Static Function fCallTES(_cDaNota,_cSerie)   
/*-------------------------*/
Local aTESdif:={}
Local cNota  := _cDaNota
Local cSerie := _cSerie

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


