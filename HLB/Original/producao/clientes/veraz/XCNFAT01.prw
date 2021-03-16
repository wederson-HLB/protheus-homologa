#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : XCNFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Veraz - Entrada e Saída       
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/08
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*-------------------------*
  User Function XCNFAT01()  
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")                                                            
If cEmpAnt $ "XC"
   If Pergunte("NFXC01    ",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else                                                                     
    MsgInfo("Especifico Veraz ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Veraz"
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
wnRel    := NomeProg := 'XCNFAT01'
cTipo    := ""                          \

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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Veraz")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Veraz")
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
Do While.Not.Eof() .and. AllTrim(cTipo)<> "C" 

   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F1_FORNECE+SQL->F1_LOJA))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
   SE2->(DbSetOrder(1))
   SE2->(DbSeek(xFilial("SE2")+SQL->F1_PREFIXO+SQL->F1_DUPL))
   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))  

   cMensTes :=Formula(SF4->F4_FORMULA)    
   cClassif := Alltrim(SQL->D1_CLASFIS)+Alltrim(SF4->F4_SITTRIB)
                
   
   DbSelectArea('SQL')
   
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
   nBsIcmRet:= F1_BRICMS
   nIcmsRet := F1_ICMSRET
   cText 	:={}   
   xMEN_TRIB:={}
   xCLAS_FIS:={} 
   lVen     :=.T.
   //xVOLUME  := SQL->F1_P_VOLUM
   //xESPECIE := SQL->F1_P_ESPEC
   xPBRUTO  := 0
   xPLIQUI  := 0 
   cMenOBS  := SQL->D1_OBS 
   cDescProd:= ""
   nMerc    := 0  
   n        := 1 
   nValsemICMS :=0  
   nValcomICMS :=0
   nValRedBase :=0
   nValDesconto:=0
   aMerc:={}
   aLote:={} 
   nLote:=0
   cAuxB1COD:=""
   cAgrupaItens:=""
   nNrItens:=0 
   cAuxImp:="" 
   cText:=""  
   cCfop:=""         
     
     While SQL->F1_DOC+SQL->F1_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
         SB5->(DbSetOrder(1))
         SB5->(DbSeek(xFilial("SB5")+SQL->D1_COD))
		 SF4->(DbSetOrder(1))
         SF4->(Dbseek(xFilial("SF4")+SQL->D1_TES)) 
         
         If SF4->(DbSeek(xFilial()+SQL->D1_TES))
            If! Alltrim(SF4->F4_TEXTO) $ cText
               If Len(Alltrim(cText)) < 1 
                  cText += Alltrim(SF4->F4_TEXTO)
               Else
                  cText +="/"+Alltrim(SF4->F4_TEXTO)
               EndIf
            Endif
         EndIf   
         
         If! Alltrim(SQL->D1_CF) $ cCfop
            If Len(Alltrim(cCfop)) < 1 
               cCfop += Alltrim(SQL->D1_CF)
            Else
               cCfop +="/"+Alltrim(SQL->D1_CF)
            EndIf
         Endif               
    		           		
		 If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
		    AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
		    AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))
	     Endif
       	        
         xPLIQUI+=SB1->B1_PESO*SQL->D1_QUANT  
         xPBRUTO+=SB1->B1_PESBRU*SQL->D1_QUANT
       
         cClassif := Alltrim(SQL->D1_CLASFIS)
                             
         Aadd(aMerc,{SB1->B1_COD,Alltrim(SB1->B1_DESC),;
         SB1->B1_POSIPI,cClassif,SB1->B1_UM,SQL->D1_QUANT,;
         SQL->D1_VUNIT,SQL->D1_TOTAL,SQL->D1_PICM,SQL->D1_IPI,SQL->D1_VALIPI,;
         AllTrim(SB5->B5_CEME),SQL->D1_LOTECTL})                 
    
         DbSkip()     	       	
      EndDo        

      fCabSf1() 
       
      nLin     :=20 
       
      nMerc:=1 
                  
      While nMerc <= Len(aMerc)    
                                                 	  
        @ nLin,010 pSay aMerc[nMerc][01]                                           //Código Produto
              
           
	    @ nLin,041 pSay SUBSTR(aMerc[nMerc][02],1,55)                              //Descrição Produto

        @ nLin,138 pSay aMerc[nMerc][03]			                               //Classificação Fiscal
        @ nLin,151 pSay aMerc[nMerc][04]	       Picture "999"                   //Situação Tributária
        @ nLin,158 pSay aMerc[nMerc][05]			                               //Unidade
        @ nLin,165 pSay aMerc[nMerc][06]		   Picture "@E@Z 999,999.99"       //Quantidade
        @ nLin,175 pSay aMerc[nMerc][07]	       Picture "@E@Z 9,999,999.999999" //Vlr Unitário    
        @ nLin,196 pSay aMerc[nMerc][08]		   Picture "@E@Z 9,999,999.99"     //Vlr Total
        @ nLin,219 pSay aMerc[nMerc][09]		   Picture "99"               	   //% ICMS    
        @ nLin,224 pSay aMerc[nMerc][10]		   Picture "99"               	   //% IPI
        @ nLin,231 pSay aMerc[nMerc][11]		   Picture "@E 99,999.99"          //Vlr IPI      
          
         nLin+=1  
	          
	       
         IncRegua(SQL->F1_SERIE+" "+SQL->F1_DOC) 
         SQL->(DbSkip())
         
           
         If  nLin>44  
         
            If  nMerc<>Len(aMerc) 
                       	       
	           @ 060,000 pSay Chr(18)
               @ 071,127 pSay cNota
	  	       @ 078,000 pSay " "   
     	       SetPrc(0,0)          
               fCabSf1()
            
              nLin:=	20
           
           EndIf 
         
         EndIf    
                                                  
        nMerc+=1
                
    End
  
    @ 48,000 pSay Chr(15)   
   // CALCULO DO IMPOSTO
	@ 48,025  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
	@ 48,060  PSAY nVALICM		   Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 48,120  PSAY nBsIcmRet       Picture "@E 999,999,999.99"  // Base ICMS Ret.
	@ 48,160  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	@ 48,205  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
	@ 50,025  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
	@ 50,060  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
	@ 50,160  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
	@ 50,205  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
	//@ 57,020  PSAY xVOLUME 		   Picture "@E 9,999.99" 			// Volumes
	//@ 57,055  PSAY xESPECIE		   Picture "@!"						// Especie
	@ 57,200  PSAY xPBRUTO		   Picture "@E 999,999.99"		// Peso Bruto
	@ 57,220  PSAY xPLIQUI		   Picture "@E 999,999.99" 		// Peso Líquido
            
   
   If! Empty(cMensTes)
	   @ 061,009 pSay SUBSTR(cMensTes,1,50)
	   @ 062,009 pSay SUBSTR(cMensTes,51,100)
   EndIf
   
   If! Empty(cMenOBS)
      @ 063,009 pSay SUBSTR(cMenOBS,1,50)  
      @ 064,009 pSay SUBSTR(cMenOBS,50,50)
   EndIf

	@ 065,000 pSay Chr(18)
    @ 071,127 pSay cNota
	@ 078,000 pSay " "   
   SetPrc(0,0)          
   
EndDo  

SQL->(dbCloseArea())

Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
 
@ 001,000 pSay chr(18)   

@ 003,133 pSay cNota                               
@ 005,109 pSay "X"

@ 007,000 pSay chr(15)   
  
@ 009,015 pSay cText
@ 009,068 pSay cCfop

  
   If! Alltrim(cTipo) $ "B/D"
       
       @ 012,015 pSay SA2->A2_NOME
       
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 012,160 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 012,160 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 012,160 pSay SA2->A2_CGC
       Endif   
       
       @ 012,218 pSay Dtoc(cEMISSAO)
   
                
       @ 014,015 pSay SA2->A2_END
       @ 014,120 pSay SA2->A2_BAIRRO
       @ 014,180 pSay SA2->A2_CEP   Picture "@R 99.999-999"

       @ 016,015 pSay SA2->A2_MUN
       @ 016,125 pSay SA2->A2_TEL  

                                            
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 016,170 pSay "ISENTO" 
       Else      
          @ 016,170 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif  
                         
   Else 
   
       @ 012,015 pSay SA1->A1_NOME
       
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 012,160 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 012,160 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 012,160 pSay SA1->A1_CGC
       Endif   
       
       @ 012,218 pSay Dtoc(cEMISSAO) 
       
       If !empty(cMensTes) 
          @ 010, 001 PSAY SUBSTR(cMensTes,1,58)         
          @ 011, 001 PSAY SUBSTR(cMensTes,59,58)      
       EndIf
              
       @ 014,015 pSay SA1->A1_END
       @ 014,120 pSay SA1->A1_BAIRRO
       @ 014,180 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      
       @ 016,015 pSay SA1->A1_MUN
       @ 016,125 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 016,170 pSay "ISENTO" 
       Else      
          @ 016,170 pSay SA1->A1_INSCR //Picture "@R 999.999.999.9999"  
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
   nIcmsRet := F2_ICMSRET
   nBasIcmsRet:= F2_BRICMS
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
   cClassif :=""
   nPesTotLiq:=0 
   nPesTotBru:=0
   xMEN_TRIB :={}
   xCLAS_FIS :={}	  	
   cCfop     := ""  	
   xCFOP     := {}
   cSQLNF    :=""
   cSQLSR    :=""
   xTES      := {}    
   cText     :=""
    lICMSUBS  := .F.
   cMsg313_E := ""
   cMsg313_G := ""
   lSemDupl  := .F.
   nBaseSTit := 0
   nValorSTit:= 0
   lImprime  :=.F.
   cMenNota  :=""
  				
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
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   SA3->(DbSetOrder(1)) 
   SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1))
   SD2->(DbSetOrder(3))
   SD2->(DbSeek(xFilial("SD2")+SQL->D2_DOC+SQL->D2_SERIE))
   SF4->(DbSetOrder(1))
   SF4->(Dbseek(xFilial("SF4")+SQL->D2_TES))                   
       
   cMensPed := Formula(SC5->C5_MENPAD)  
   cMensTes := FORMULA(SF4->F4_FORMULA)      
   cClassif := Alltrim(SQL->D2_CLASFIS)+Alltrim(SF4->F4_SITTRIB)
   cMenNota := SC5->C5_MENNOTA 
   nDespesas:= SC5->C5_DESPESA
     

   aMerc    :={}
   aServ    :={}
   nPerc	:={} 
   aLote    :={}
   nNrItens := 0
   n        := 1 
   nAliqIcms:= SQL->D2_PICM
   nNrItens := 0  
   ImpDupl	:= 0  
   cCompara := SQL->F2_DOC+SQL->F2_SERIE 
   ctes     := SQL->D2_TES 
   cAgrupaItens:="" 
   nMerc    := 0 
   nLote    := 0  
   cAuxB1COD:= ""
     
      While SQL->F2_DOC+SQL->F2_SERIE == cCompara           
         
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))   
         SB5->(DbSetOrder(1))
         SB5->(DbSeek(xFilial("SB5")+SQL->D2_COD))
         SA7->(DbSetOrder(1))
         SA7->(DbSeek(xFilial("SA7")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->D2_COD))
         SF3->(DbSetOrder(4))
         SF3->(DbSeek(xFilial("SF3")+SA1->A1_COD+SA1->A1_LOJA+SQL->F2_DOC+SQL->F2_SERIE))

         If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
            AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
            AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))                                       
         Endif 
         
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
                 
                                                                               
         Aadd(aMerc,{SB1->B1_COD,AllTrim(SC6->C6_DESCRI),;
         SB1->B1_POSIPI,cClassif,SB1->B1_UM,SQL->D2_QUANT,;
         SQL->D2_PRUNIT,SQL->D2_PRCVEN,SQL->D2_TOTAL,SQL->D2_PICM,SQL->D2_IPI,SQL->D2_VALIPI, SQL->D2_DESCON, ;
         SQL->D2_DESC,AllTrim(SB5->B5_CEME),SC6->C6_LOTECTL})        

         
         If! Alltrim(SQL->D2_CF) $ cCfop
            If Len(Alltrim(cCfop)) < 1 
               cCfop += Alltrim(SQL->D2_CF)
            Else
               cCfop +="/"+ Alltrim(SQL->D2_CF)
            EndIf
         Endif
         
         If SF4->(DbSeek(xFilial()+SQL->D2_TES))
            If! Alltrim(SF4->F4_TEXTO) $ cText
               If Len(Alltrim(cText)) < 1 
                  cText += Alltrim(SF4->F4_TEXTO)
               Else
                  cText +="/"+Alltrim(SF4->F4_TEXTO)
               EndIf
            Endif
         EndIf
                       
         nPosi := aScan(nPerc,{|_cCpo| _cCpo[1] == SQL->D2_PICM})
            
         If nPosi==0
            AADD(nPerc,{SQL->D2_PICM,SQL->D2_VALICM})
         Else	
            nPerc[nposi,2]+=SQL->D2_VALICM
         Endif
         
         nBsIcmRet :=0
         nPesTotLiq+=SB1->B1_PESO*SQL->D2_QUANT  
         nPesTotBru+=SB1->B1_PESBRU*SQL->D2_QUANT
	     
         DBSELECTAREA("SQL")
         IncRegua(SQL->F2_SERIE+" "+SQL->F2_DOC)   
         DbSkip()
      Enddo         
  
   
   fCabSf2()   


   nMerc :=1
   nLin  :=20
   nPos  :=1
   @ nLin,000 pSay Chr(15)
   IF Alltrim(cTipo) = "I"
      @ nLin+3,025  PSAY "COMPLEMENTO DE I.C.M.S."
   ElseIf Alltrim(cTipo) = "P"
      @ nLin+3,025  PSAY "COMPLEMENTO DE I.P.I."
      @ nLin+3,190  PSAY aMerc[nMerc][10]		     Picture "99"
      @ nLin+3,199  PSAY nVALIPI		  			 Picture "@E 99,999,999.99"
   Else	
      While nMerc <= Len(aMerc)  
         @ nLin,000 pSay Chr(15)
         @ nLin,010 pSay aMerc[nMerc][01]                                             //Código Produto
         If Len(aMerc[nMerc][02]) < 90
            @ nLin,041 pSay SUBSTR(aMerc[nMerc][02],1,90)                             //Descrição Produto
         Else
            @ nLin,041 pSay SUBSTR(aMerc[nMerc][02],1,90)                             //Descrição Produto
            nLin++
            @ nLin,041 pSay SUBSTR(aMerc[nMerc][02],91,180)                           //Descrição Produto
         EndIf
         
         @ nLin,138 pSay aMerc[nMerc][03]			                                  //Classificação Fiscal
	     @ nLin,151 pSay aMerc[nMerc][04] Picture "999"                               //Situação Tributária
         @ nLin,158 pSay aMerc[nMerc][05]                                             //Unidade
         @ nLin,162 pSay aMerc[nMerc][06] Picture "@E@Z 999,999"                      //Quantidade                      
         @ nLin,173 pSay aMerc[nMerc][08] Picture "@E@Z 9,999,999.999999"             //Vlr Unitário    
         @ nLin,196 pSay aMerc[nMerc][09] Picture "@E@Z 9,999,999.99"                 //Vlr Total
         @ nLin,219 pSay aMerc[nMerc][10] Picture "99"               	              //% ICMS    
         @ nLin,225 pSay aMerc[nMerc][11] Picture "99"               	              //% IPI
         @ nLin,232 pSay aMerc[nMerc][12] Picture "@E 99,999.99"                      //Vlr IPI
	     
	     nLin+=1


         If nLin > 44
            
            If  nMerc<>Len(aMerc) 
                  
               @ 070,000 pSay Chr(18)                          
               @ 072,127 pSay cNota
               @ 078,000 pSay " "   
               SetPrc(0,0)          
               fCabSf2()
               nLin:=	20      
            
            EndIf 
              
         Endif     
         
         nMerc +=1
               
      End
   Endif
        
   @ 48,000 pSay Chr(15) 
  
   If cTipo $"I"	
      @ 48, 060  PSAY nVALICM			Picture "@E 999,999,999.99"  // Valor do ICMS
   ElseIf cTipo == "P"
      @ 48, 025  PSAY nBASEICM       Picture "@E 999,999,999.99"  // Base do ICMS
      @ 48, 060  PSAY nVALICM        Picture "@E 999,999,999.99"  // Valor do ICMS
      @ 50, 160  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
   Else
      IF !lICMSUBS    //SE for .F. ele imprime o icms normal                         
	     @ 48,025  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
	     @ 48,060  PSAY nVALICM		   Picture "@E 999,999,999.99"  // Valor do ICMS
	  ELSE		  // SE for .T. ele imprime o icms substituição          
	     @ 48,120  PSAY nBsIcmRet	   Picture "@E 999,999,999.99"  // Base ICMS Ret.
	     @ 48,160  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	  ENDIF
	
	  @ 48,205  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.                                                                                  
      @ 50,025  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
	  @ 50,060  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
	  @ 50,125  PSAY nDespesas       Picture "@E 999,999,999.99"  // Valor Despesas 
	  @ 50,160  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
	  @ 50,205  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF

   EndIf

   //Transportadora
   @ 053,025 pSay SA4->A4_NOME                
   
   If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
      @ 053,139 PSay "1"
   ElseIf SC5->C5_TPFRETE == "F"   
      @ 053,139 PSay "2"   
   Endif
   
   @ 053,203 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 055,025 pSay SA4->A4_END
   @ 055,110 pSay SA4->A4_MUN
   @ 055,191 pSay SA4->A4_EST
   @ 055,203 pSay SA4->A4_INSEST
   
   @ 57,020  PSAY SC5->C5_VOLUME1 	 Picture "@E 9,999.99" 			// Volumes
   @ 57,055  PSAY SC5->C5_ESPECI1    Picture "@!"					// Especie
   @ 57,200  PSAY nPbruto	         Picture "@E 999,999.99"		// Peso Bruto
   @ 57,220  PSAY nPliqui		     Picture "@E 999,999.99" 		// Peso Líquido 
       
   If! Empty(cMensTes)                	
      @ 061,009 pSay SUBSTR(cMensTes,1,80)
	  @ 062,009 pSay SUBSTR(cMensTes,81,80)
   ENDIF
      
   If !Empty(cMensPed) .And. Empty(cMensTes)
      @ 061,009 pSay SUBSTR(cMensPed,1,80)
      @ 062,009 pSay SUBSTR(cMensPed,81,80) 
   EndIf    
   
   If !empty(cMenNota)
      @ 063,009 pSay SUBSTR(cMenNota,01,80)
      @ 064,009 pSay SUBSTR(cMenNota,81,80)
      @ 065,009 pSay SUBSTR(cMenNota,161,80)            
   EndIf                                            

   @ 065,000 pSay Chr(18)                          
   @ 072,127 pSay cNota
   @ 078,000 pSay " "   
   SetPrc(0,0)  
   
EndDo
        
SQL->(dbCloseArea())

Return 
    
//----------------------------------------------------------- cabeçalho nfs.

Static Function fCabSf2()

@ 003,133 pSay cNota         
@ 005,094 pSay chr(18)+"X"     
                       
@ 007,000 pSay chr(15)    

     
@ 009,015 pSay cText
@ 009,068 pSay cCfop


   If! Alltrim(cTipo) $ "B/D"        
       @ 012,015 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 012,160 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 012,160 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 012,160 pSay SA1->A1_CGC
       Endif                      
                           
       @ 012,218 pSay Dtoc(cEMISSAO)  
    
       @ 014,015 pSay SA1->A1_END
       @ 014,120 pSay SA1->A1_BAIRRO
       @ 014,180 pSay SA1->A1_CEP   Picture "@R 99.999-999"  

       @ 016,015 pSay SA1->A1_MUN
       @ 016,100 pSay SA1->A1_EST
       @ 016,125 pSay SA1->A1_TEL  
       
       
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 016,170 pSay "ISENTO" 
       Else      
          @ 016,170 pSay SA1->A1_INSCR //Picture "@R 999.999.999.9999"  
       Endif 
                
   Else            
       @ 009,067 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 009,167 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 009,167 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 009,167 pSay SA2->A2_CGC
       Endif   
       
       @ 009,202 pSay Dtoc(cEMISSAO)          
                                               
       @ 011,067 pSay SA1->A1_END
       @ 011,144 pSay SA1->A1_BAIRRO
       @ 011,186 pSay SA1->A1_CEP   Picture "@R 99.999-999"  
       
       @ 013,067 pSay SA2->A2_MUN
       @ 013,110 pSay SA2->A2_TEL 
       @ 013,155 pSay SA2->A2_EST  
       
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 013,170 pSay "ISENTO" 
       Else      
          @ 013,170 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
   
cQuery := "SELECT SF1.*,SD1.*" 
cQuery += "FROM "+RetSqlName("SF1")+" SF1 , "+RetSqlName("SD1")+" SD1 WHERE "+Chr(10)
cQuery += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "+Chr(10)
cQuery += "SF1.F1_DOC BETWEEN '"+Alltrim(_cDaNota)+"' AND '"+Alltrim(_cAtNota)+"' AND "+Chr(10)
cQuery += "SF1.F1_SERIE = '"+Alltrim(_cSerie)+"' AND "+Chr(10)
cQuery += "SF1.F1_FORMUL = 'S' AND SD1.D1_FORMUL = 'S' AND "+Chr(10)
cQuery += "SF1.F1_DOC= SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND "+Chr(10)
cQuery += "SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF1.F1_DOC, SD1.D1_COD "
   
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

cQuery := " SELECT F2_VALICM, F2_TRANSP,F2_VALISS,F2_LOJA,F2_CLIENTE,F2_BASEISS,F2_VALMERC,F2_VALCOFI,F2_VALCSLL,F2_VALPIS ,F2_DESCONT,F2_TIPO,F2_ICMSRET,F2_BRICMS,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DOC,F2_EMISSAO,F2_PBRUTO, "+Chr(10)+CHR(13)
cQuery += " F2_VALICM,F2_PLIQUI,F2_PREFIXO, F2_PLIQUI,F2_DUPL,F2_VALMERC,F2_ICMSRET,F2_BRICMS,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DOC,F2_EMISSAO,F2_PBRUTO, "+Chr(10)+CHR(13)
cQuery += " F2_DUPL,F2_BASEICM, F2_SERIE,F2_DOC,F2_EMISSAO,D2_FILIAL, D2_TES,D2_PEDIDO,D2_DOC,D2_SERIE,D2_COD,D2_QUANT,D2_PRCVEN,D2_CLASFIS,D2_TOTAL,D2_ITEMPV, "+Chr(10)+CHR(13)
cQuery += " D2_CLASFIS,D2_PRUNIT,D2_VALICM,D2_CF ,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,D2_DESCON,D2_DESC,D2_LOTECTL "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+Alltrim(_cDaNota)+"' AND '"+Alltrim(_cAtNota)+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+Alltrim(_cSerie)+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_COD,SD2.D2_TES "

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

/*----------------------------------------*/
Static Function fCallCFOP(cSQLNF,cSQLSR)  
/*----------------------------------------*/
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

//---------------------------------------------------------------------------
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

/*
Static Function fCallNCM_E(cCod)

Local cCodigo:= cCod
Local lRet:= .F.
Local cQryUH:= ""

If Select ("SQLNCM") > 0
	DbSelectarea("SQLNCM")
	dbCloseArea()
Endif
	
cQryUH := "SELECT SB1.B1_POSIPI AS B1NCM FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"
cQryUH += " WHERE SB1.B1_COD = '"+ cCodigo + "' AND SB1.B1_POSIPI IN("
cQryUH += "'3303.00.10','3304.20.10','3304.20.90',"
cQryUH += "'33030010','33042010','33042090',"                        
cQryUH += "'3304.30.00','3304.91.00','3304.99.90','3305.20.00','3305.30.00',"
cQryUH += "'33043000','33049100','33049990','33052000','33053000',"
cQryUH += "'3304.99.10','3305.90.00',"
cQryUH += "'33049910','33059000')"                                 
TCQUERY cQryUH NEW ALIAS "SQLNCM"
dbSelectArea("SQLNCM")
dbGoTop()
If Select ("SQLNCM") > 0	
	lRet:= .T.
Else
	lRet:= .F.
Endif
  
SQLNCM->(DbCloseArea())

Return(lRet)          
            
//------------------------------------------------------------------------------
Static Function fCallNCM_G(cCod)

Local cCodigo:= cCod
Local lRetorno:= .F.
Local cQryNCM:= ""

If Select ("SQLG") > 0
	DbSelectarea("SQLG")
	dbCloseArea()
Endif
	
cQryNCM := "SELECT SB1.B1_POSIPI AS B1NCM FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"
cQryNCM += " WHERE SB1.B1_COD = '"+ cCodigo + "' AND SB1.B1_POSIPI IN('3305.10.00'"
cQryNCM += ",'3306.10.00','3306.20.00','3306.90.00','3307.10.00','3307.20.10','3307.20.90'"
cQryNCM += ",'3307.30.00','3307.90.00','3401.19.00')"


TCQUERY cQryNCM NEW ALIAS "SQLG"
dbSelectArea("SQLG")
dbGoTop()
If Select ("SQLG") > 0	
	lRet:= .T.
Else
	lRet:= .F.
Endif
  
SQLG->(DbCloseArea())

Return(lRetorno)
                  */
