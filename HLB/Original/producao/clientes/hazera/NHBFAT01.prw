#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : NHBFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Hazera - Entrada e Saída    
Autor     	: Flávia Rocha
Data     	: 29/08/2007 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*------------------------*
 User Function NHBFAT01()
*------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
   fCriaPerg()
If cEmpAnt $ "HB"
   If Pergunte("NFHB01    ",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
      fOkProc()
   Endif   
Else
    MsgInfo("Especifico Hazera ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Hazera"
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
wnRel    := NomeProg := 'NHBFAT01'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Hazera")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Hazera")
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

   //SF4->(DbSetOrder(1))
   //SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F1_FORNECE+SQL->F1_LOJA))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
   

   //cMensTes := Formula(SF4->F4_FORMULA)
   cNota    := F1_DOC
   cSerie   := F1_SERIE
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
   fCabSf1()
	xMEN_TRIB:={}
   xCLAS_FIS:={}
   nLin     :=26
   
  	aMensTES  :={}
  	//nBsIcmRet :=0      
  	xTES	    :={}
  	
  	xTES := fTESD1(cNota,cSerie)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))				
			Aadd(aMensTes,SF4->F4_FORMULA)	
		Next
	Endif
   
   /*
   SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial("SD1")+SQL->D1_DOC+SQL->D1_SERIE))
     
	SD1->(DbSetOrder(1))
	SD1->(DbGotop())
  	SD1->(DbSeek(xFilial("SD1")+cCompara))
	While !eof("SD1") .and. (cCompara == SD1->D1_DOC + SD1->D1_SERIE)
				xTES:= SD1->D1_TES
				SF4->(DbSetOrder(1)) 
				SF4->(DbSeek(xFilial("SF4")+xTES))				
				Aadd(aMensTes,SF4->F4_FORMULA)		
				SD1->(dbskip())
	Enddo		
   */      
        

   While SQL->F1_DOC+SQL->F1_SERIE == cCompara           
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
         @ nLin,001 pSay ALLTRIM(SB1->B1_COD)                       	//Código Produto
         @ nLin,015 pSay ALLTRIM(SB1->B1_DESC)                      	//Descrição Produto
         @ nLin,063 pSay SB1->B1_POSIPI                            	//Classificação fiscal
         @ nLin,077 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB            	//Situação Tributária
         @ nLin,082 pSay SB1->B1_UM                                	//Unidade
         @ nLin,083 pSay SQL->D1_QUANT  Picture "@E@Z 999,999.99"       	//Quantidade
         @ nLin,091 pSay SQL->D1_VUNIT  Picture "@E@Z 99,999,999.99"    	//Vlr Unitário    
         @ nLin,108 pSay SQL->D1_TOTAL  Picture "@E@Z 999,999,999.99"   	//Vlr Total
         @ nLin,124 pSay SQL->D1_PICM   Picture "99"               			//%ICMS    
         @ nLin,128 pSay SQL->D1_IPI    Picture "99"               			//%IPI
         @ nLin,132 pSay SQL->D1_VALIPI Picture "@E 99,999.99"          	//Vlr IPI
       	IncRegua(SQL->F1_SERIE+" "+SQL->F1_DOC) 
         DbSelectArea("SQL")
         DbSkip()
         nLin  +=1
         	If nLin > 51
				   @ 072,000 pSay Chr(27)+"2"
					@ 073,000 pSay Chr(18)
	  				@ 079,072 pSay cNota
					@ 086,000 pSay ""   
	  				SetPrc(0,0)   
	           	fCabSf1()
	           	nLin :=26
         	Endif
   End         
// CALCULO DO IMPOSTO
   @ 055,001 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
   @ 055,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
   @ 055,120 pSay nVALMERC Picture "@E 999,999,999.99" //Vlr Produtos
   @ 057,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
   @ 057,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
   @ 057,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
   @ 057,084 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
   @ 057,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota


   @ 072,000 pSay Chr(27)+"2"
   @ 073,000 pSay Chr(18)
   @ 079,072 pSay cNota
   @ 086,000 pSay ""   
   SetPrc(0,0) 
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   
   @ 001,000 pSay Chr(18)
   @ 003,057 PSay "X"
   @ 003,072 pSay Alltrim(cNota)
   @ 005,000 pSay Chr(15)
   @ 008,001 pSay SF4->F4_TEXTO
   @ 008,045 pSay SF4->F4_CF
  	
   If! AllTrim(cTipo) $ "B/D"
      @ 012,001 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 012,085 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 012,085 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 012,085 pSay SA2->A2_CGC
      Endif   
      @ 012,126 pSay Dtoc(cEMISSAO)
      @ 014,001 pSay SA2->A2_END
      @ 014,076 pSay SA2->A2_BAIRRO
      @ 014,105 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 016,001 pSay SA2->A2_MUN
      @ 016,053 pSay SA2->A2_TEL   
      @ 016,087 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 016,091 pSay "ISENTO" 
      Else      
	      @ 016,091 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
      Endif       
	Else   
      @ 012,001 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 012,085 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 012,085 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 012,085 pSay SA1->A1_CGC
      Endif   
      @ 012,126 pSay Dtoc(cEMISSAO)
      @ 014,001 pSay SA1->A1_END
      @ 014,076 pSay SA1->A1_BAIRRO
      @ 014,105 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 016,001 pSay SA1->A1_MUN
      @ 016,053 pSay SA1->A1_TEL   
      @ 016,087 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 016,089 pSay "ISENTO" 
      Else      
         @ 016,089 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
      Endif       
   Endif
   @ 018,000 pSay Chr(27)+"0"
Return

//----------------------------------------------------------- Emite nfs.
Static Function fImpSF2()

Local xTES      := {}
Local aMensTES  :={}

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
   cSerie	:= F2_SERIE
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
  	nBsIcmRet :=0      
  	xTRANSP   :=""
  				
   //SF4->(DbSetOrder(1))
   //SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SQL->F2_CLIENTE+SQL->F2_LOJA))
   SA4->(DbSetOrder(1))
   SA4->(DbSeek(xFilial("SA4")+SQL->F2_TRANSP))
   xTRANSP := SA4->A4_NOME
   SC5->(dbSetOrder(1))
   SC5->(DbSeek(xFilial("SC5")+SQL->D2_PEDIDO))


   cMensTes := Formula(SC5->C5_MENPAD)
   aTit :={}
   aVal :={}
   aVen :={}
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
      
   //FATURA   
   If! Empty(SQL->F2_PREFIXO+SQL->F2_DUPL)
       Do While !EOF() .AND. SQL->F2_PREFIXO+SQL->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aTit,{ (SE1->E1_PREFIXO)+(SE1->E1_NUM)+Space(1)+(SE1->E1_PARCELA)})
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})
          Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
          SE1->(DbSkip())
       EndDo
   Endif    
   
   xTES := fCallTES(cNota,cSerie)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))				
			If !empty(SF4->F4_FORMULA)
				Aadd(aMensTes,SF4->F4_FORMULA)
			Endif
		Next
	Endif  	
   
   cText		:={}     
   aMerc    :={}
   aServ    :={}
   cCompara := SQL->F2_DOC+SQL->F2_SERIE   
   While SQL->F2_DOC+SQL->F2_SERIE == cCompara           
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
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,SQL->D2_QUANT,;
            SQL->D2_PRCVEN,SQL->D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,IIF(!EMPTY(Alltrim(SB5->B5_CEME)),Alltrim(SB5->B5_CEME),AllTrim(SB1->B1_DESC)),;
            SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,SQL->D2_QUANT,;
            SQL->D2_PRCVEN,SQL->D2_TOTAL,SQL->D2_PICM,SQL->D2_IPI,SQL->D2_VALIPI,;
            ALLTRIM(SC6->C6_DESCRI),SA7->A7_CODCLI,SQL->D2_LOTECTL,SB1->B1_GRUPO,SQL->D2_DESCON,SC6->C6_DESCONT})
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
         
         IncRegua(SQL->F2_SERIE+" "+SQL->F2_DOC)   
         DbSelectArea("SQL")
         DbSkip()
   Enddo         
   
   fCabSf2()
   
//IMPRIME FATURA
   i    :=1
   nCol :=10
   @ 016,000 pSay Chr(27)+"0"
   nLin :=019
   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol +=30
      i +=1
   End
   nLin +=2
   nCol :=10
	i    :=1
	While i <= Len(aVal)
      @ nLin,nCol pSay aVal[i][1]
      nCol +=30
      i +=1        
   End     
   nLin +=2
   nCol :=10
	i    :=1   
   While i <= Len(aVen)
      @ nLin,nCol pSay aVen[i][1]
      nCol +=30
      i +=1
   End

   // Impressão Endereço de Cobrança      
	if  !EMPTY(SA1->A1_ENDCOB)
		@ nLin,095 PSAY SA1->A1_ENDCOB
   ENDIF    

   nMerc :=1
   nLin  :=27
   nPos  :=1

   IF Alltrim(cTipo) $ "N/D/C/B"
      While nMerc <= Len(aMerc)
         @ nLin,000 pSay aMerc[nMerc][01]                                 //Código Produto
	      IF LEN(aMerc[nMerc][02]) > 37
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],1,37)                 //Descrição Produto
		      nLin+=1
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],38,37)                //Descrição Produto
			   IF LEN(aMerc[nMerc][02]) > 75
		   	   nLin+=1
		         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],76,37)             //Descrição Produto		
			   ENDIF
         ELSE	
	         @ nLin,018 pSay aMerc[nMerc][02]                              //Descrição Produto
		   ENDIF
	      @ nLin,063 pSay aMerc[nMerc][03]			                          //Classificação Fiscal
	      @ nLin,077 pSay aMerc[nMerc][04]                                 //Situação Tributária
         @ nLin,082 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,083 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         @ nLin,092 pSay aMerc[nMerc][07]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         @ nLin,105 pSay aMerc[nMerc][08]+aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,124 pSay aMerc[nMerc][09] Picture "99"               	  //% ICMS    
         @ nLin,129 pSay aMerc[nMerc][10] Picture "99"               	  //% IPI
         @ nLin,133 pSay aMerc[nMerc][11] Picture "@E 99,999.99"          //Vlr IPI                   
         If aMerc[nMerc][16]>0
            nLin +=1
            @ nLin,018 pSay "Desconto "+Transform(aMerc[nMerc][17],"@E 999.99")+"%"       
            @ nLin,101 pSay aMerc[nMerc][16] Picture "@E@Z 9,999,999.99"
         EndIf
         nLin  +=1
         //If nLin == 48.And.nMerc <= Len(aMerc)
         If nLin > 51 .And.nMerc <= Len(aMerc)
         	@ nLin,000 pSay "Continua..."
            i   :=1  
            nLin:=53  
            nPos:=16
               i +=1     
			   @ 076,000 pSay Chr(27)+"2"
				@ 077,000 pSay Chr(18)
				@ 081,072 pSay cNota
				@ 087,000 pSay ""  
		   	SetPrc(0,0)	      
			   fCabSf2()
			   @ 016,000 pSay Chr(27)+"0"
			   nLin:=25 
         Endif       
         nMerc +=1
      End

      // CALCULO DO IMPOSTO
      @ 056,001 pSay nBASEICM Picture "@E 999,999,999.99" //Base ICMS
      @ 056,038 pSay nVALICM  Picture "@E 999,999,999.99" //Vlr  ICMS
      @ 056,120 pSay nVALMERC+nDescont Picture "@E 999,999,999.99" //Vlr Produtos
      @ 058,002 pSay nFRETE   Picture "@E 999,999,999.99" //Vlr Frete
      @ 058,038 pSay nSEGURO  Picture "@E 999,999,999.99" //Vlr Seguro
      @ 058,060 pSay nDESPESA Picture "@E 999,999,999.99" //Vlr Despesa
      @ 058,084 pSay nVALIPI  Picture "@E 999,999,999.99" //Vlr IPI
      @ 058,120 pSay nVALBRUT Picture "@E 999,999,999.99" //Vlr Nota
      //TRANSPORTADORA
      //@ 062,001 pSay SA4->A4_NOME                
      @ 062,001 pSay xTRANSP
      If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
         @ 062,089 PSay "1"
      ElseIf SC5->C5_TPFRETE == "F"   
         @ 062,089 PSay "2"   
      Endif   
      @ 062,117 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
      @ 065,001 pSay SA4->A4_END
      @ 065,077 pSay SA4->A4_MUN
      @ 065,113 pSay SA4->A4_EST
      If AllTrim(SA4->A4_INSEST) == "ISENTO" 
         @ 065,119 pSay "ISENTO" 
      Else      
         @ 065,119 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
      Endif       
      @ 067,003 pSay SC5->C5_VOLUME1
      @ 067,035 pSay SC5->C5_ESPECI1
      @ 067,100 pSay nPBRUTO        Picture "@E@Z 999,999,999.99"
      @ 067,120 pSay nPLIQUI        Picture "@E@Z 999,999,999.99"

// FR 28/08/07: Novo tratamento para impressão das msg's dos TES 
// para quando houver TES's diferentes em uma mesma nota.
nLin := 74
If Empty(cMensTes)
	If len(aMensTes) > 0		
		For ms:=1 to len(aMensTes)
			cMensTes := Formula(aMensTes[ms])
			@ nLin, 001 PSAY SUBSTR(cMensTes,1,80)
			nLin++
	  		@ nLin, 001 PSAY SUBSTR(cMensTes,61,80)
	  		nLin++	  		 		   		
	  	Next
	  	@ nLin,001 pSay SUBSTR(SC5->C5_MENNOTA,1,80) 
	Endif	       
Else
	   @ nLin,001 pSay SUBSTR(cMensTes,1,80)
	   nLin++
	   @ nLin,001 pSay SUBSTR(cMensTes,71,80)
	   nLin++
	   @ nLin,001 pSay SUBSTR(SC5->C5_MENNOTA,1,80)  		   			   
Endif	   
          
	   IF nValPis+nValCofi+nValCsll > 0
         @ 75,001 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E@Z 999,999.99")+"/"+Transform(nValCofi,"@E@Z 999,999.99")+"/"+Transform(nValCsll,"@E@Z 999,999.99")   
      ENDIF

   Elseif Alltrim(cTipo) = "P"                                                                
      While nMerc <= Len(aMerc)
         nVlrIPI += aMerc[nMerc][11]
         nMerc +=1
      End 
         @ nLin,018 pSay "Complemento de IPI"                          //Descrição Produto 
         @ nLin,099 pSay nVlrIPI        Picture "@E 99,999.99"         //Vlr Total            
         @ 058,084  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr IPI Rodapé
         @ 058,120  pSay nVlrIPI        Picture "@E 999,999,999.99"    //Vlr Nota Rodapé
         @ 074,001  pSay SUBSTR(SC5->C5_MENNOTA,1,80)       
   Else
         @ nLin,018 pSay "Complemento de ICMS"                         //Descrição Produto 
         @ nLin,099 pSay nVALICM        Picture "@E 99,999.99"         //Vlr Total            
         @ 056,038  pSay nVALICM        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
         @ 074,001  pSay SUBSTR	(SC5->C5_MENNOTA,1,80) 
   EndIf
   
   n1es:=1         
   n2es:=60
      
	   @ 076,000 pSay Chr(27)+"2"
		@ 077,000 pSay Chr(18)
		@ 081,072 pSay cNota
		@ 087,000 pSay ""  
   	SetPrc(0,0)

EndDo

Return 

//-----------------------------------------------------------  cabeçalho nfs

Static Function fCabSf2()
   
   @ 001,000 pSay Chr(18)
   @ 003,050 PSay "X"
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

	@ 009,044 pSay cCfop
   
   If! Alltrim(cTipo) $ "B/D"
       @ 012,001 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 012,088 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 012,088 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 012,088 pSay SA1->A1_CGC
       Endif   
       @ 012,127 pSay Dtoc(cEMISSAO)
       @ 014,001 pSay SA1->A1_END
       @ 014,075 pSay SA1->A1_BAIRRO
       @ 014,105 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       @ 016,001 pSay SA1->A1_MUN
       @ 016,058 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 016,086 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 016,091 pSay "ISENTO" 
       Else      
          @ 016,091 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 012,001 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 012,088 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 012,088 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 012,088 pSay SA2->A2_CGC
       Endif   
       @ 012,127 pSay Dtoc(cEMISSAO)
       @ 014,001 pSay SA2->A2_END
       @ 014,075 pSay SA2->A2_BAIRRO
       @ 014,105 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 016,001 pSay SA2->A2_MUN
       @ 016,058 pSay SA2->A2_TEL  // Picture "@R (99)9999-9999"
       @ 016,086 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 016,091 pSay "ISENTO" 
       Else      
          @ 016,091 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
   
cQuery := "SELECT D2_DOC,D2_SERIE,D2_TES,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI, "+Chr(10)+CHR(13)
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

Static Function fCriaPerg()

cPerg:="NFHB01    "
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


/*-------------------------*/
Static Function fTESD1(_cDaNota,_cSerie)   
/*-------------------------*/
Local aTESdif:={}
Local cNota  := _cDaNota
Local cSerie := _cSerie

If Select("TEMPTES") > 0
	dbSelectArea("TEMPTES")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD1.D1_TES AS ITEMTES"
cQryFR	+= " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"
cQryFR	+= " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
cQryFR   += " AND SD1.D1_DOC = '"+cNota+"'"
cQryFR   += " AND SD1.D1_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD1.D_E_L_E_T_ <> '*'"

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