#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : NR7FAT01
Parametros  : 
Retorno     : 
Objetivos   : Nota Fiscal Shiseido - Entrada e Saída - Antigo
Parametros  :
Autor       : Renato Mendonça
Data/Hora   : 12/12/2006
Revisão	    : Renato Rezende
Data/Hora   : 21/11/2012
Módulo      : Faturamento
*/

*-----------------------*
User Function NR7FAT01()
*-----------------------*
SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")                                                            
If cEmpAnt $ "R7"
   If Pergunte("NFR701    ",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif
Else
    MsgInfo("Especifico Shiseido ","A T E N C A O")  
Endif   

Return

*------------------------* 
Static Function fOkProc()
*------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Shiseido"
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
wnRel    := NomeProg := 'NR7FAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Shiseido")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Shiseido")
Endif   

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

Ms_Flush()

Return

//Emite Nota Fiscal de Entrada
*------------------------*
Static Function fImpSF1()
*------------------------*

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
   nBsIcmRet:= F1_BRICMS
   nIcmsRet := F1_ICMSRET
   cText		:={}
  	xMEN_TRIB:={}
   xCLAS_FIS:={}
   xVOLUME  := SQL->F1_P_VOLUM
   xESPECIE := SQL->F1_P_ESPEC
   xPBRUTO  := SQL->F1_P_BRUTO
   xPLIQUI  := SQL->F1_P_LIQUI
    
   
   fCabSf1()
   nLin     :=29
   
  if AllTrim(cTipo)$ "C"
  	  @ nLin,017 pSay "Complemento de Importação"
     @ nLin,100 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total
  else
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
	      	@ nLin,001 pSay SB1->B1_COD                                      //Código Produto
         IF LEN(SB1->B1_DESC) > 60
	         @ nLin,018 pSay SUBSTR(SB1->B1_DESC,1,60)                     //Descrição Produto
		      nLin+=1
	         @ nLin,018 pSay SUBSTR(SB1->B1_DESC,61,60)                    //Descrição Produto
         ELSE	
	         @ nLin,018 pSay SB1->B1_DESC                                  //Descrição Produto
		   ENDIF
				@ nLin,086 pSay SB1->B1_POSIPI			                          //Classificação Fiscal
	      	@ nLin,100 pSay D1_CLASFIS			Picture "999"                   //Situação Tributária
         	@ nLin,107 pSay SB1->B1_UM			                                //Unidade
         	@ nLin,112 pSay D1_QUANT			Picture "@E@Z 999,999.99"       //Quantidade
         	@ nLin,125 pSay D1_VUNIT 			Picture "@E@Z 999,999.99"       //Preco Bruto         
         	@ nLin,150 pSay D1_VUNIT		   Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         	@ nLin,170 pSay D1_TOTAL		   Picture "@E@Z 9,999,999.99"     //Vlr Total
         	@ nLin,187 pSay D1_PICM				Picture "99"               	  //% ICMS    
         	@ nLin,193 pSay D1_IPI			   Picture "99"               	  //% IPI
        		@ nLin,198 pSay D1_VALIPI			Picture "@E 99,999.99"          //Vlr IPI
       	IncRegua(F1_SERIE+" "+F1_DOC) 
         DbSkip()
         nLin  +=1
         If nLin == 59
				nLin	:=	74
     		  	@ 075,000 pSay Chr(18)
     		  	@ 075,115 pSay cNota
	  		  	@ 078,000 pSay " "   
     		  	SetPrc(0,0)          
            fCabSf1()
            nLin	:=	29
         Endif
   End         
  Endif 
  
// CALCULO DO IMPOSTO
	@ 61,005  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
	@ 61,035  PSAY nVALICM		    Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 61,065  PSAY nBsIcmRet		 Picture "@E 999,999,999.99"  // Base ICMS Ret.
	@ 61,090  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	@ 61,120  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
	@ 63,005  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
	@ 63,035  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
	@ 63,090  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
	@ 63,120  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
	@ 70,005  PSAY xVOLUME 			 Picture "@E 9,999.99" 			// Volumes
	@ 70,025  PSAY xESPECIE			 Picture "@!"						// Especie
	@ 70,102  PSAY xPBRUTO			 Picture "@E 999,999.99"		// Peso Bruto
	@ 70,120  PSAY xPLIQUI			 Picture "@E 999,999.99" 		// Peso Líquido

	@ 075,000 pSay Chr(18)
   @ 075,115 pSay cNota
	@ 078,000 pSay " "   
   SetPrc(0,0)          
   
EndDo
Return 

//Emite cabeçalho da nfe.
*------------------------*
Static Function fCabSf1()
*------------------------*

@ 000, 000 PSAY Chr(15)                     
@ 006,001 PSAY chr(18)
@ 007,100 pSay "X"  
@ 007,115 pSay cNota
@ 008,000 PSAY chr(15)

If !empty(cMensTes)
	@ 009, 002 PSAY SUBSTR(cMensTes,1,40)
	@ 010, 002 PSAY SUBSTR(cMensTes,41,40)
	@ 011, 002 PSAY SUBSTR(cMensTes,81,40)
EndIf
   
@ 12, 000 PSAY chr(18)

	@ 012,031 pSay ALLTRIM(SF4->F4_TEXTO)
	@ 012,066 pSay SF4->F4_CF
  	
   If! Alltrim(cTipo) $ "B/D"
       @ 015,031 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 015,090 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 015,090 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 015,090 pSay SA2->A2_CGC
       Endif   
       @ 015,113 pSay Dtoc(cEMISSAO)
       @ 017,031 pSay SA2->A2_END
       @ 017,081 pSay SA2->A2_BAIRRO
       @ 017,099 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 019,031 pSay SA2->A2_MUN
       @ 019,068 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 019,085 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 019,090 pSay "ISENTO" 
       Else      
          @ 019,090 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 015,031 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 015,090 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 015,090 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 015,090 pSay SA1->A1_CGC
       Endif   
       @ 015,113 pSay Dtoc(cEMISSAO)
       @ 017,031 pSay SA1->A1_END
       @ 017,081 pSay SA1->A1_BAIRRO
       @ 017,099 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 019,031 pSay SA1->A1_MUN
       @ 019,068 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 019,085 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 019,090 pSay "ISENTO" 
       Else      
          @ 019,090 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Endif
@ 21, 000 PSAY CHR(15)
@ 24, 000 PSAY CHR(18)
@ 25, 000 PSAY CHR(15)

@ 25,058 PSAY extenso(nVALBRUT,.F.,1)


Return

//Emite nfs.
*------------------------*
Static Function fImpSF2()
*------------------------*

DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()

   nBaseIcm := F2_BASEICM
   nValIcm  := F2_VALICM
   nValMerc := F2_VALMERC
   nIcmsRet := F2_ICMSRET
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
   

   cMensTes := Formula(SF4->F4_FORMULA)       
   aVal :={}
   aVen :={}
   //FATURA
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})
          Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
          SE1->(DbSkip())
       EndDo
   Endif    
   cText		:={}     
   aMerc    :={}
   aServ    :={}
   nPerc		:={}
   ImpDupl	:= 0
   cCompara := F2_DOC+F2_SERIE
   While F2_DOC+F2_SERIE == cCompara           
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

         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,AllTrim(SB1->B1_DESC),SB1->B1_POSIPI,D2_CLASFIS,SB1->B1_UM,D2_QUANT,D2_PRUNIT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI})
         Endif   
			         

  			If Ascan(cText, SF4->F4_TEXTO)==0
				AADD(cText , SF4->F4_TEXTO)
			Endif
			                
          If SQL->D2_EST $ SM0->M0_ESTCOB
            If! SQL->D2_CF $ cCfop
			      cCfop += SQL->D2_CF      
	         Endif             
         Elseif AllTrim(SQL->D2_EST) = 'EX'                 
            If! Right(SQL->D2_CF,4) $ cCfop    
               cCfop += "7"+Right(SQL->D2_CF,4)
             Endif
         Elseif SQL->D2_EST <> SM0->M0_ESTCOB
            If! Right(SQL->D2_CF,4) $ cCfop    
               cCfop += "6"+Right(SQL->D2_CF,4)
             Endif                          
         Else
            If! Right(SQL->D2_CF,4) $ cCfop    
               cCfop += "6"+Right(SQL->D2_CF,4)
            Endif 
         Endif
         
         nPosi := aScan(nPerc,{|_cCpo| _cCpo[1] == SQL->D2_PICM})
        
         If nPosi==0
				AADD(nPerc,{SQL->D2_PICM,SQL->D2_VALICM})
			ELSE	
			   nPerc[nposi,2]+=SQL->D2_VALICM
			endif
         

         If nIcmsRet > 0
				nBsIcmRet:=F3_VALOBSE
			Else
				nBsIcmRet:=0
			Endif
         
         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         

ImpDupl	:= Len(aMerc)
pTotal	:= (Len(aMerc)/30+0.47)
pTotal	:= Round(pTotal,0)
j			:= 1
   fCabSf2()   


   nMerc :=1
   nLin  :=29
   nPos  :=1

	IF Alltrim(cTipo) = "I"
		@ nLin+3,025  PSAY "COMPLEMENTO DE I.C.M.S."
	ElseIf Alltrim(cTipo) = "P"
		@ nLin+3,025  PSAY "COMPLEMENTO DE I.P.I."
		@ nLin+3,115  PSAY aMerc[nMerc][10]		  Picture "99"
		@ nLin+3,125  PSAY nVALIPI		  			  Picture "@E 99,999,999.99"
	Else	
   While nMerc <= Len(aMerc)
         @ nLin,001 pSay aMerc[nMerc][01]                                 //Código Produto
         IF LEN(aMerc[nMerc][02]) > 60
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],1,60)                 //Descrição Produto
		      nLin+=1
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],61,60)                //Descrição Produto
         ELSE	
	         @ nLin,018 pSay aMerc[nMerc][02]                              //Descrição Produto
		   ENDIF
		   @ nLin,086 pSay aMerc[nMerc][03]			                          //Classificação Fiscal
	      @ nLin,100 pSay aMerc[nMerc][04] Picture "999"                   //Situação Tributária
         @ nLin,107 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,112 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,125 pSay aMerc[nMerc][07] Picture "@E@Z 999,999.99"       //Preco Bruto         
         @ nLin,150 pSay aMerc[nMerc][08] Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         @ nLin,170 pSay aMerc[nMerc][09] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,187 pSay aMerc[nMerc][10] Picture "99"               	  //% ICMS    
         @ nLin,193 pSay aMerc[nMerc][11] Picture "99"               	  //% IPI
         @ nLin,198 pSay aMerc[nMerc][12] Picture "@E 99,999.99"          //Vlr IPI
         nLin  +=1
         ImpDupl -= 1
         If nLin == 59 .And. Len(aMerc) > 30
            @ 066,001 pSay SA4->A4_NOME                
				   If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
				      @ 066,084 PSay "1"
				   ElseIf SC5->C5_TPFRETE == "F"   
				      @ 066,084 PSay "2"   
					Endif                                                                                                        
					   @ 066,112 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
					   @ 068,001 pSay SA4->A4_END
					   @ 068,073 pSay SA4->A4_MUN
					   @ 068,103 pSay SA4->A4_EST   
				   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
					   @ 068,112 pSay "ISENTO" 
				   Else      
				   	@ 068,112 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
				   Endif       
			   nLin	:=	74
     		  	@ 075,000 pSay Chr(18)
     		  	@ 075,115 pSay cNota
	  		  	@ 078,000 pSay " "   
     		  	SetPrc(0,0)          
            fCabSf2()
            nLin	:=	29
         Endif       
         nMerc +=1
                
   End
   Endif
   
// Cálculo do Imposto  
If cTipo $"I"	
	@ 61, 035  PSAY nVALICM			 Picture "@E 999,999,999.99"  // Valor do ICMS
ElseIf cTipo == "P"
	@ 58, 001  PSAY nBASEICM       Picture "@E 999,999,999.99"  // Base do ICMS
	@ 58, 025  PSAY nVALICM        Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 60, 080  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
Else
	@ 61,005  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
	@ 61,035  PSAY nVALICM		    Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 61,065  PSAY nBsIcmRet		 Picture "@E 999,999,999.99"  // Base ICMS Ret.
	@ 61,090  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	@ 61,120  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
	@ 63,005  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
	@ 63,035  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
	@ 63,090  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
	@ 63,120  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
EndIf

//Transportadora
   @ 066,001 pSay SA4->A4_NOME                
   If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
      @ 066,084 PSay "1"
   ElseIf SC5->C5_TPFRETE == "F"   
      @ 066,084 PSay "2"   
   Endif
	If (ALLTRIM(SA4->A4_COD)  == "100")   
   @ 066, 087 pSay "DXT-2133"                                                                                                           
   EndIf
   @ 066,112 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 068,001 pSay SA4->A4_END
   @ 068,073 pSay SA4->A4_MUN
   @ 068,103 pSay SA4->A4_EST
   
   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
	   @ 068,112 pSay "ISENTO" 
   Else      
   	@ 068,112 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   Endif       
   
  
   nLin:=74     

	@ 075,000 pSay Chr(18)
   @ 075,115 pSay cNota
	@ 078,000 pSay " "   
   SetPrc(0,0)  
EndDo

Return 

//Cabeçalho nfs.
*------------------------*
Static Function fCabSf2()
*------------------------*
   
@ 000, 000 PSAY Chr(15)                     


If pTotal > 1
	@ 002,020 pSay "Form.:"
   @ 002,027 pSay j
	@ 002,028 pSay " / "
	@ 002,031 pSay pTotal	
   j+=1
Endif   
	
If !empty(SC5->C5_MENNOTA)
   @ 003,002 pSay SUBSTR(SC5->C5_MENNOTA,1,40)         
   @ 004,002 pSay SUBSTR(SC5->C5_MENNOTA,41,40)
   @ 005,002 pSay SUBSTR(SC5->C5_MENNOTA,81,40)
EndIf

@ 006,001 PSAY chr(18)
@ 007,091 pSay "X"  
@ 007,115 pSay cNota
@ 008,000 PSAY chr(15)

If !empty(cMensTes)
	@ 009, 002 PSAY SUBSTR(cMensTes,1,40)
	@ 010, 002 PSAY SUBSTR(cMensTes,41,40)
	@ 011, 002 PSAY SUBSTR(cMensTes,81,40)
EndIf

@ 12, 000 PSAY chr(18)

	FOR I := 1 TO LEN(cText)                                          
	 col := Len(Alltrim(cText[1]))+1
   	IF I == 1
   		@ 012,031 pSay ALLTRIM(cText[1])
   	ENDIF
   	IF cText[I] <> cText[1]
	   	@ 012,col pSay "/"+cText[I]
   	endif
   NEXT

	@ 012,066 pSay cCfop
   
   If! Alltrim(cTipo) $ "B/D"
       @ 015,031 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 015,090 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 015,090 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 015,090 pSay SA1->A1_CGC
       Endif   
       @ 015,113 pSay Dtoc(cEMISSAO)
       @ 017,031 pSay SA1->A1_END
       @ 017,081 pSay SA1->A1_BAIRRO
       @ 017,099 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 019,031 pSay SA1->A1_MUN
       @ 019,069 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 019,085 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 019,090 pSay "ISENTO" 
       Else      
          @ 019,090 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 015,031 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 015,090 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 015,090 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 015,090 pSay SA2->A2_CGC
       Endif   
       @ 015,113 pSay Dtoc(cEMISSAO)
       @ 017,031 pSay SA2->A2_END
       @ 017,081 pSay SA2->A2_BAIRRO
       @ 017,099 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 019,031 pSay SA2->A2_MUN
       @ 019,069 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 019,085 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 019,090 pSay "ISENTO" 
       Else      
          @ 019,090 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Endif
   
nLin := 19
y	  := 1
If cTipo != "C"
	For I:=1 to Len(nPerc)
		@ nLin, Y PSAY CHR(15)
		@ nLin, PCOL()+1 PSAY ALLTRIM(STR(nPerc[I,1],2,0))
		@ nLin, PCOL()+1 PSAY "% - "
		@ nLin, PCOL()+1 PSAY nPerc[I,2] Picture("@E 99,999.99")
		y := y + pcol()+3
		if y >= 25
			nLin := nLin + 1
			y:= 0
		endif
	next
endif


@ 21,008 PSAY Alltrim(SC6->C6_PEDCLI)

//Imprime Fatura
IF ImpDupl <= 30
	@ 021, 000 PSAY CHR(15)      
	nCol := 058
	nLin := 022
	nAjuste := 0             
	If! Empty(aVen)
    	For i:= 1 to Len(aVen)       
		 	 @ nLin, nCol + nAjuste      PSAY aVen[i][1]                             
		  	 @ nLin, nCol + 18 + nAjuste PSAY aVal[i][1]
		  	 nAjuste := nAjuste + 38
	   	If nAjuste >= 39
		   	nLin    := nLin + 1
		   		If nLin == 23
			   		@ 23,008 PSAY Alltrim(SC5->C5_NUM)
				   Endif
		   	nAjuste := 0
	   	Endif
      Next
	Endif    
Else	
	@ 021, 000 PSAY CHR(15)      
	@ 022, 058 PSAY "XXXXXXXX"
	@ 022, 076 PSAY "XXXXXXXX"
	@ 022, 094 PSAY "XXXXXXXX"
	@ 022, 112 PSAY "XXXXXXXX"
	@ 023, 008 PSAY Alltrim(SC5->C5_NUM)
	@ 023, 058 PSAY "XXXXXXXX"
	@ 023, 076 PSAY "XXXXXXXX"
	@ 023, 094 PSAY "XXXXXXXX"		
	@ 023, 112 PSAY "XXXXXXXX"
EndIF

@ 24,000 PSAY CHR(18)

If cTipo != "C"
	@ 25,001 PSAY ALLTRIM(SA3->A3_NREDUZ) +  ' - COD.:' + ALLTRIM(SA3->A3_COD)
	@ 25,031 PSAY CHR(15)
EndIf             

IF ImpDupl <= 30
@ 25,058 PSAY extenso(nVALBRUT,.F.,1)
Endif
  
Return

*------------------------*
Static Function fGerSf1()
*------------------------*

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
cQuery += "SF1.F1_FORMUL = 'S'  AND "+Chr(10)
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

*------------------------*
Static Function fGerSf2()
*------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())
   
cQuery := "SELECT D2_TES,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_VALICM,D2_IPI,D2_VALIPI,D2_PRUNIT,D2_CLASFIS, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO,F2_ICMSRET "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_COD "

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

*------------------------*
Static Function CriaPerg()
*------------------------*

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