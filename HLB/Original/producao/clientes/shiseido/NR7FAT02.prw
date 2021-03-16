#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : NR7FAT01
Parametros  : 
Retorno     : 
Objetivos   : Nota Fiscal Shiseido - Entrada e Saída - Novo
Parametros  :
Autor       : Renato Mendonça
Data/Hora   : 12/12/2006
Revisão	    : Renato Rezende
Data/Hora   : 21/11/2012
Módulo      : Faturamento
*/

*-----------------------*
User Function NR7FAT02()
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

*-----------------------*
Static Function fOkProc()
*-----------------------*

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
*-----------------------*
Static Function fImpSF1()
*-----------------------*

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
   
   SM4->(DbSetOrder(1))
   SM4->(DbSeek(xFilial("SM4")+SF4->F4_FORMULA))                           

   cMensTes := Alltrim(SM4->M4_FORMULA)     
   cMensTes := AllTrim(Formula(SF4->F4_FORMULA))  //--> Alterado por Antonio Carlos 20080326 11:49

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
   cText	:={}   
   xMEN_TRIB:={}
   xCLAS_FIS:={}
   xVOLUME  := SQL->F1_P_VOLUM
   xESPECIE := SQL->F1_P_ESPEC
   xPBRUTO  := SQL->F1_P_BRUTO
   xPLIQUI  := SQL->F1_P_LIQUI    
   cMensOBS := SQL->D1_OBS
   
   cCfop := D1_CF   
   
   fCabSf1()     
   
   nLin     :=29
   
  if AllTrim(cTipo)$ "C"
  	  @ nLin,017 pSay "Complemento de Importação"
     @ nLin,100 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total
  else
   While SQL->F1_DOC+SQL->F1_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
         SB5->(DbSetOrder(1))
         SB5->(DbSeek(xFilial("SB5")+SQL->D1_COD))
		
		
		If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
		   AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
		   AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))
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
	    @ nLin,100 pSay SQL->D1_CLASFIS			    Picture "999"                   //Situação Tributária
        @ nLin,107 pSay SB1->B1_UM			                                //Unidade
        @ nLin,112 pSay SQL->D1_QUANT			    Picture "@E@Z 999,999.99"       //Quantidade
        @ nLin,125 pSay SQL->D1_VUNIT 			    Picture "@E@Z 999,999.99"       //Preco Bruto         
        @ nLin,150 pSay SQL->D1_VUNIT		        Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
        @ nLin,170 pSay SQL->D1_TOTAL		        Picture "@E@Z 9,999,999.99"     //Vlr Total
        @ nLin,187 pSay SQL->D1_PICM				Picture "99"               	  //% ICMS    
        @ nLin,193 pSay SQL->D1_IPI			        Picture "99"               	  //% IPI
        @ nLin,198 pSay SQL->D1_VALIPI			    Picture "@E 99,999.99"          //Vlr IPI
       	
       	IncRegua(SQL->F1_SERIE+" "+SQL->F1_DOC) 
        SQL->(DbSkip())
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
	@ 61,035  PSAY nVALICM		   Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 61,065  PSAY nBsIcmRet  	   Picture "@E 999,999,999.99"  // Base ICMS Ret.
	@ 61,090  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	@ 61,120  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
	@ 63,005  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
	@ 63,035  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro  
    @ 63,065  PSAY nDespesa        Picture "@E 999,999,999.99"  // Valor Seguro  	
	@ 63,090  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
	@ 63,120  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
	@ 70,005  PSAY xVOLUME 		   Picture "@E 9,999.99" 			// Volumes
	@ 70,025  PSAY xESPECIE		   Picture "@!"						// Especie
	@ 70,102  PSAY xPBRUTO		   Picture "@E 999,999.99"		// Peso Bruto
	@ 70,120  PSAY xPLIQUI		   Picture "@E 999,999.99" 		// Peso Líquido

	@ 075,000 pSay Chr(18)
    @ 075,115 pSay cNota
	@ 078,000 pSay " "   
   SetPrc(0,0)          
   
EndDo
Return 

//Emite cabeçalho da nfe.

*-----------------------*
Static Function fCabSf1()
*-----------------------*

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
	@ 012,066 pSay cCfop//SF4->F4_CF
  
   @ 013, 000 PSAY chr(15)
   
   If !Empty(cMensOBS)
      @ 013, 002 PSAY SUBSTR(cMensOBS,1,40)
      @ 014, 002 PSAY SUBSTR(cMensOBS,41,40)
   EndIf     
   
   @ 015, 000 PSAY chr(18)
   
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
*-----------------------*
Static Function fImpSF2()
*-----------------------*

DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()

   nBaseIcm := F2_BASEICM
   nValIcm  := F2_VALICM
   nValMerc := F2_VALMERC
   nIcmsRet := F2_ICMSRET
   nBsIcmRet:= F2_BRICMS
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
   cCfop     := ""  	
   xCFOP     := {}
   cSQLNF    :=""
   cSQLSR    :=""
   xTES      := {}    
   //cText	 :={}    //--> Antonio Carlos 20080326 14:30
   cText     :=""
     	
   lICMSUBS  := .F.
   cMsg313_E := ""
   cMsg313_G := ""
   lSemDupl  := .F.
   nBaseSTit := 0
   nValorSTit:= 0     
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
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   SA3->(DbSetOrder(1)) 
   SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1))
   SD2->(DbSetOrder(3))
   SD2->(DbSeek(xFilial("SD2")+SQL->D2_DOC+SQL->D2_SERIE))
   



If SC5->C5_TIPOCLI = 'S' .AND. !EMPTY(SQL->F2_ICMSRET)  
	lICMSUBS:= .T.                        
Else
	lICMSUBS := .F.     
Endif

//FR
//Verifica os TES que existem na nf (seleção distinta)
	cSQLNF := SQL->D2_DOC
	cSQLSR := SQL->D2_SERIE
	xTES := fCallTES(cSQLNF,cSQLSR)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))			
			If Empty(cText)
  			  cText := ALLTRIM(SF4->F4_TEXTO)
			Else 
			   //--> Inplementado por Antonio Carlos 20080327 17:51
			   If !ALLTRIM(SF4->F4_TEXTO) $ cText
                  cText+="/"
			  	  cText += ALLTRIM(SF4->F4_TEXTO)
                  //cText += "/" //--> In ibido por Antonio Carlos 20080326 14:41
			   Endif			
           EndIf 
		Next
   Endif
//Verifica os CFOPs correspondentes (distintos)
   xCFOP := fCallCFOP(cSQLNF,cSQLSR)
	If len(xCFOP) > 0
		For f:= 1 to len(xCFOP)
			//cCfop += xCFOP[f] 	+ "/" //--> Inibido Antonio Carlos 20080426 14:45
			cCfop += xCFOP[f]
			If f > 1
 			   cCfop += "/"
		    EndIf  
		Next
	Endif
//FR  

   SM4->(DbSetOrder(1))
   SM4->(DbSeek(xFilial("SM4")+SF4->F4_FORMULA))                           

   //cMensTes := Formula(SF4->F4_FORMULA)        
   cMensTes := Alltrim(SM4->M4_FORMULA)       
    
   aVal :={}
   aVen :={}
   //FATURA
   If !Empty(SQL->F2_PREFIXO+SQL->F2_DUPL)
       //Do While !Not.Eof().And.SQL->F2_PREFIXO+SQL->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM //--> iNIBIDO pOR aNTONIOcARLOS 20080326 17:52
       //--> IMPLEMENTADO pOR aNTONIOcARLOS 20080326 17:52        
       DbSelectArea('SE1')
       DbSetOrder(1)
       DbSeek(xFilial('SE1')+SQL->F2_PREFIXO+SQL->F2_DUPL,.T.)
        
       While !Eof() .And. SE1->E1_PREFIXO+SE1->E1_NUM == SQL->F2_PREFIXO+SQL->F2_DUPL 
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})   
          Aadd(aVen,{ Dtoc(SE1->E1_VENCREA)})
          SE1->(DbSkip())
       EndDo      
   Else
   
      lSemDupl := .T.    
   
   Endif    
   //cText	:={}    //--> Antonio Carlos 20080326 14:30

   aMerc    :={}
   aServ    :={}
   nPerc		:={}
   ImpDupl	:= 0
   cCompara := SQL->F2_DOC+SQL->F2_SERIE
   While SQL->F2_DOC+SQL->F2_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
         
         //FR       
         //If nIcmsRet > 0  //--> Implementado Antonio Carlos 20080327 - 12:05
          /*If fCallNCM_E(SQL->D2_COD)  .and. lICMSUBS
            	If Empty(cMsg313_E)
         		   //cMsg313_E := "OPERACAO SUJEITA AO REGIME DE SUBS. TRIBUTARIA, NOS TERMOS DO ART.313-E DO RICMS/SP E DA PORT.CAT 125/2007" //--> Alterado Antonio Carlos 20080326 14:14
         		   cMsg313_E := "OP.SUJ.REG.DE SUBS.TRIBUT.CFE.ART.313-ERICMS/SP.PORT.CAT125/2007"
         	    Endif
            Elseif fCallNCM_G(SQL->D2_COD) .and. lICMSUBS
         	   If Empty(cMsg313_G)
         	      //cMsg313_G := "OPERACAO SUJEITA AO REGIME DE SUBS. TRIBUTARIA, NOS TERMOS DO ART.313-G DO RICMS/SP E DA PORT.CAT 124/2007"//--> Alterado Antonio Carlos 20080326 14:14
         		  cMsg313_G := "OP.SUJ.REG.DE SUBS.TRIBUT.CFE.ART.313-GRICMS/SP.PORT.CAT125/2007"
         	   Endif
            Endif*/
         //EndIf   	
         //FR
   
         //--> Caso Não encontre mensagem vinda do texto padrão assumi as mensagens customizadadas
         //    Implementado por Antonio Carlos em 20080326 11:48
         /*If Empty(cMensTes)
            cMensTes+= cMsg313_E
            cMensTes+= cMsg313_G
         EndIf*/
         //--------------------------------------------------------   
         
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
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),;
            SB1->B1_UM,SQL->D2_QUANT,SQL->D2_PRCVEN,SQL->D2_TOTAL,SC6->C6_DESCRI})
         Else                                                                     
         
            Aadd(aMerc,{SB1->B1_COD,AllTrim(SB1->B1_DESC),;
            SB1->B1_POSIPI,SQL->D2_CLASFIS,SB1->B1_UM,SQL->D2_QUANT,;
            SQL->D2_PRUNIT,SQL->D2_PRCVEN,SQL->D2_TOTAL,SQL->D2_PICM,SQL->D2_IPI,SQL->D2_VALIPI, SQL->D2_DESCON, SQL->D2_DESC,SQL->D2_P_IVABS,SQL->D2_P_IVAVL,SC6->C6_ICMSRET})
            
            nBaseStIt+= SQL->D2_P_IVABS
            nValorSTIt+= SQL->D2_P_IVAVL
         Endif   
                                             
         
         nPosi := aScan(nPerc,{|_cCpo| _cCpo[1] == SQL->D2_PICM})
        
         If nPosi==0
				AADD(nPerc,{SQL->D2_PICM,SQL->D2_VALICM})
			ELSE	
			   nPerc[nposi,2]+=SQL->D2_VALICM
			endif
         
         /*If nIcmsRet > 0
            SF3->(DbSetOrder(4))
            SF3->(DbSeek(xFilial("SF3")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_DOC+SQL->F2_SERIE))
			//nBsIcmRet := SF3->F3_VALOBSE  //--> Inibido Antonio Carlos 20080326 17:27
			nBsIcmRet := SF3->F3_BASERET    //--> Implementado por Antonio Carlos 20080326 17:27
         Else
			nBsIcmRet:=0
		 Endif*/
         
         DBSELECTAREA("SQL")
         IncRegua(SQL->F2_SERIE+" "+SQL->F2_DOC)   
         DbSkip()
   Enddo         

ImpDupl	:= Len(aMerc)
For i := 1 to len(aMerc)
   If aMerc[i][15]>0 .And. aMerc[i][16]>0
      ImpDupl ++  
   End
Next
pTotal	:= (ImpDupl/30+0.47)
pTotal	:= Round(pTotal,0)
j	    := 1
   fCabSf2()   


   nMerc :=1
   nLin  :=29
   nPos  :=1

	IF Alltrim(cTipo) = "I"
        If aMerc[nMerc][17] > 0
          While nMerc <= Len(aMerc)
             nVlrICMST += aMerc[nMerc][17]
             nMerc +=1
          End                 
          @ nLin+3,025  PSAY "COMPLEMENTO DE ICMS - ST"  
          @ nLin+3,170 pSay nVlrICMST        Picture "@E 99,999.99"         //Vlr Total            
        Else   
		    @ nLin+3,025  PSAY "COMPLEMENTO DE ICMS"
		EndIf
	ElseIf Alltrim(cTipo) = "P"
		@ nLin+3,025  PSAY "COMPLEMENTO DE IPI"
		@ nLin+3,115  PSAY aMerc[nMerc][10]		  Picture "99"
		@ nLin+3,125  PSAY nVALIPI		  			  Picture "@E 99,999,999.99"
	Else	
   While nMerc <= Len(aMerc)
         @ nLin,001 pSay aMerc[nMerc][01]                                             //Código Produto
         IF LEN(aMerc[nMerc][02]) > 60
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],1,60)                            //Descrição Produto
		      nLin+=1
	         @ nLin,018 pSay SUBSTR(aMerc[nMerc][02],61,60)                           //Descrição Produto
         ELSE	
	         @ nLin,018 pSay aMerc[nMerc][02]                                         //Descrição Produto
		 ENDIF
		 @ nLin,086 pSay aMerc[nMerc][03]			                                  //Classificação Fiscal
	     @ nLin,100 pSay aMerc[nMerc][04] Picture "999"                               //Situação Tributária
         @ nLin,107 pSay aMerc[nMerc][05]                                             //Unidade
         @ nLin,112 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"                   //Quantidade
         
       //  @ nLin,134 pSay aMerc[nMerc][07] Picture "@E@Z 999,999.99"                 //Desconto        
         If !lSemDupl .And. !Empty(aMerc[nMerc][13]) .AND. aMerc[nMerc][13] > 0 
             nDesconto:= aMerc[nMerc][13] / aMerc[nMerc][06]
             @ nLin,125 pSay aMerc[nMerc][08] + nDesconto Picture "@E@Z 999,999.99"   //Desconto
         Else  
             @ nLin,125 pSay aMerc[nMerc][08] Picture "@E@Z 999,999.99"               //Preco Bruto                  
         EndIf       
         
         If !lSemDupl .And. aMerc[nMerc][14] > 0 .And. aMerc[nMerc][13] > 0 
            @ nLin,134 pSay aMerc[nMerc][14] Picture "@E@Z 9,999,999.99"              //% Desconto             
         Else 
            @ nLin,134 pSay " "                                                       //% Desconto             
         EndIf
         
         @ nLin,150 pSay aMerc[nMerc][08] Picture "@E@Z 9,999,999.99"                 //Vlr Unitário    
         @ nLin,170 pSay aMerc[nMerc][09] Picture "@E@Z 9,999,999.99"                 //Vlr Total
         @ nLin,187 pSay aMerc[nMerc][10] Picture "99"               	              //% ICMS    
         @ nLin,193 pSay aMerc[nMerc][11] Picture "99"               	              //% IPI
         @ nLin,198 pSay aMerc[nMerc][12] Picture "@E 99,999.99"                      //Vlr IPI
        If aMerc[nMerc][15]>0 .And. aMerc[nMerc][16]>0
            nLin +=1
            @ nLin,018 pSay "Base ST: " + Transform(aMerc[nMerc][15],"@E@Z 999,999,999.99")
            @ nLin,045 pSay "Icm ST: " + Transform(aMerc[nMerc][16],"@E@Z 999,999,999.99")
         EndIf

         nLin  +=1
         ImpDupl -= 1
         If nLin == 59 //.And. Len(aMerc) > 30      
            
            If nMerc<>Len(aMerc)  // Nao pode ser o ultimo item para chamar o formulario.
               
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
     		   @ 075,116 pSay cNota
	  		   @ 078,000 pSay " "   
     		   SetPrc(0,0)          
               fCabSf2()
               nLin	:=	29
            
            EndIf
         
         Endif       
         nMerc +=1                                                                   
                
   End
   Endif
   
// Cálculo do Imposto  
If cTipo $"I"	
   If nVlrICMST > 0
      @ 061,090  pSay nVlrICMST        Picture "@E 999,999,999.99"    //Vlr ICMS Rodapé
      @ 063,120  pSay nVlrICMST        Picture "@E 999,999,999.99"    //Vlr Nota
   Else
	@ 61, 035  PSAY nVALICM			 Picture "@E 999,999,999.99"  // Valor do ICMS 
   EndIf
ElseIf cTipo == "P"
	  @ 58, 001  PSAY nBASEICM       Picture "@E 999,999,999.99"  // Base do ICMS
	  @ 58, 025  PSAY nVALICM        Picture "@E 999,999,999.99"  // Valor do ICMS
	  @ 60, 080  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI	  
Else
	//IF !lICMSUBS            //SE for .F. ele imprime o icms normal                         
		@ 61,005  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
		@ 61,035  PSAY nVALICM		    Picture "@E 999,999,999.99"  // Valor do ICMS
    IF lICMSUBS  //ELSE							// SE for .T. ele imprime o icms substituição          
		@ 61,065  PSAY nBsIcmRet		 Picture "@E 999,999,999.99"  // Base ICMS Ret.
		@ 61,090  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	ENDIF                                                                                  
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
   @ 075,112 pSay cNota
	@ 078,000 pSay " "   
   SetPrc(0,0)  
EndDo

Return 
    
//Cabeçalho nfs.
*-----------------------*
Static Function fCabSf2()
*-----------------------*

lImpPed := .F.
   
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

//ASK 26/08/2008 - Chamado 28588
/*//@ 006,001 PSAY chr(18) Inibido Antonio Carlos 20080326 16:56
if !Empty(cMsg313_E+cMsg313_G) .and. lICMSUBS //--> Implementado Antonio Carlos 20080326 15:11
   //--> Implementadfo Antonio Carlos 20080326 15:02
   @ 007,002 pSay  chr(15)+"Base  ICMS : "+Transform(nBaseIcm,"@R 999,999,999.99")
EndIf

@ 007,156 pSay chr(18)+"X"  
@ 007,177 pSay cNota+chr(15)
if !Empty(cMsg313_E+cMsg313_G)  .and. lICMSUBS //--> Implementado Antonio Carlos 20080326 15:11
   //--> Implementadfo Antonio Carlos 20080326 15:02
   @ 008,002 pSay  "Valor ICMS : "+Transform(nValIcm,"@R 999,999,999.99")
 EndIf*/

If !empty(cMensTes)
   @ 006, 002 PSAY SUBSTR(cMensTes,1,40)
   @ 007, 002 PSAY SUBSTR(cMensTes,41,40)
EndIf

@ 007,156 pSay chr(18)+"X"  
@ 007,177 pSay cNota+chr(15)
                   
If !empty(cMensTes)
   @ 008, 002 PSAY SUBSTR(cMensTes,81,40)
EndIf
                               
If lICMSubs
   @ 009, 002 PSAY "“Substituição Tributária – Art.313-E"
   @ 010, 002 PSAY "e 313-G do RICMS/00”"
   @ 011, 002 PSAY "“O destinatário deverá, com relação às"  
   @ 012, 002 PSAY "operações com mercadorias ou prestações"  
EndIf

   @ 012,030 PSAY chr(18)
   @ 012,041 pSay cText
   @ 012,078 pSay cCfop

   @ 013, 000 PSAY chr(15)
   
If lICMSubs
   @ 013, 002 PSAY "de serviços recebidas com imposto retido," 
   @ 014, 002 PSAY "escriturar o documento fiscal nos termos"
   @ 015, 002 PSAY " do artigo 278 do RICMS."       
EndIf
   @ 015, 030 PSAY chr(18)
            
   If! Alltrim(cTipo) $ "B/D"
       @ 015,041 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 015,101 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 015,101 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 015,101 pSay SA1->A1_CGC
       Endif   
       @ 015,124 pSay Dtoc(cEMISSAO)

       If !Empty(nBaseSTit) .And. !Empty(nValorSTit) // Imprime nos dados adicionais os totais de base e valor de icms st por item
          @ 016,000 PSAY chr(15)       
          @ 016,002 pSay "Total B.ICMS ST: "+Alltrim(Transform(nBaseSTit,"@R 999,999,999.99"))
          @ 017,000 PSAY chr(15)                 
          @ 017,002 pSay "Total Vl.ICMS ST: "+Alltrim(Transform(nValorSTit,"@R 999,999,999.99"))+chr(18)
          @ 017,041 pSay SA1->A1_END
          @ 017,091 pSay SA1->A1_BAIRRO                       
          @ 017,099 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       Else
          @ 017,029 pSay SA1->A1_END
          @ 017,081 pSay SA1->A1_BAIRRO
          @ 017,099 pSay SA1->A1_CEP   Picture "@R 99.999-999"
       EndIf
              
       @ 019,029 pSay SA1->A1_MUN
       @ 019,069 pSay SA1->A1_TEL  // Picture "@R (99)9999-9999"
       @ 019,085 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 019,090 pSay "ISENTO" 
       Else      
          @ 019,090 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 015,041 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 015,101 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 015,101 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 015,101 pSay SA2->A2_CGC
       Endif   
       @ 015,124 pSay Dtoc(cEMISSAO)
       
       If !Empty(nBaseSTit) .And. !Empty(nValorSTit) // Imprime nos dados adicionais os totais de base e valor de icms st por item
          @ 016,000 PSAY chr(15)
          @ 016,002 pSay "Total B.ICMS ST: "+Alltrim(Transform(nBaseSTit,"@R 999,999,999.99"))
          @ 017,000 PSAY chr(15)
          @ 017,002 pSay "Total Vl.ICMS ST: "+Alltrim(Transform(nValorSTit,"@R 999,999,999.99"))+chr(18)
          @ 017,041 pSay SA2->A2_END
          @ 017,091 pSay SA2->A2_BAIRRO
          @ 017,099 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       Else
          @ 017,031 pSay SA2->A2_END
          @ 017,081 pSay SA2->A2_BAIRRO
          @ 017,099 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       EndIf
   
       @ 019,029 pSay SA2->A2_MUN
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


//@ 21,008 PSAY Alltrim(SC6->C6_PEDCLI)

//Imprime Fatura
IF ImpDupl <= 30
   @ 021, 000 PSAY CHR(15)      
   nCol := 058
   nLin := 022
   nAjuste := 0             
   If !Len(aVen) = 0
      For i:= 1 to Len(aVen)       
	     @ nLin, nCol + nAjuste      PSAY aVen[i][1]                             
		 @ nLin, nCol + 18 + nAjuste PSAY aVal[i][1]
		 nAjuste := nAjuste + 38
	   	 If nAjuste >= 39
		    nLin    := nLin + 1
		   	If nLin == 23
			   @ 23,008 PSAY Alltrim(SC5->C5_NUM)
			   lImpPed := .T.
			Endif
		   	nAjuste := 0
	   	 Endif
         Next
   Endif    
Else	
	@ 022, 000 PSAY CHR(15)      
	@ 022, 058 PSAY "XXXXXXXX"
	@ 022, 076 PSAY "XXXXXXXX"
	@ 022, 094 PSAY "XXXXXXXX"
	@ 022, 112 PSAY "XXXXXXXX"
	@ 023, 008 PSAY Alltrim(SC5->C5_NUM)
	lImpPed:= .T.
	@ 023, 058 PSAY "XXXXXXXX"
	@ 023, 076 PSAY "XXXXXXXX"
	@ 023, 094 PSAY "XXXXXXXX"		
	@ 023, 112 PSAY "XXXXXXXX"
EndIf
           
If !lImpPed    //Para imprimir o Pedido, não estava imprimindo...
   @ 023, 008 PSAY Alltrim(SC5->C5_NUM)
EndIf

@ 24,000 PSAY CHR(18)

If cTipo != "C"
	@ 25,001 PSAY ALLTRIM(SA3->A3_NREDUZ) +  ' - COD.:' + ALLTRIM(SA3->A3_COD)
EndIf             

	@ 25,031 PSAY CHR(15)   

IF ImpDupl <= 30
@ 25,058 PSAY extenso(nVALBRUT,.F.,1)
Endif
  
Return

*-----------------------*
Static Function fGerSf1()
*-----------------------*

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

*-----------------------*
Static Function fGerSf2()
*-----------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())
   
cQuery := "SELECT D2_SERIE,D2_DOC,D2_TES,F2_EST,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_VALICM,D2_IPI,D2_VALIPI,D2_PRUNIT,D2_CLASFIS,D2_LOCAL, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESC,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,D2_P_IVABS,D2_P_IVAVL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO,F2_ICMSRET,F2_BRICMS "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC = SD2.D2_DOC AND "+Chr(10)
cQuery += "SF2.F2_SERIE = SD2.D2_SERIE AND "+Chr(10)
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

*-----------------------*
Static Function CriaPerg()
*-----------------------*

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

*----------------------------------------*
Static Function fCallCFOP(cSQLNF,cSQLSR)  
*----------------------------------------*
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

*----------------------------------------*
Static Function fCallTES(cSQLNF,cSQLSR)   
*----------------------------------------*

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

*--------------------------------*
Static Function fCallNCM_E(cCod)
*--------------------------------*

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
cQryUH += "'33030010','33042010','33042090',"                          //--> Implementado por Antonio Carlos 20080326
cQryUH += "'3304.30.00','3304.91.00','3304.99.90','3305.20.00','3305.30.00',"
cQryUH += "'33043000','33049100','33049990','33052000','33053000',"   //--> Implementado por Antonio Carlos 20080326 
cQryUH += "'3304.99.10','3305.90.00',"
cQryUH += "'33049910','33059000')"                                   //--> Implementado por Antonio Carlos 20080326
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

*--------------------------------*
Static Function fCallNCM_G(cCod)
*--------------------------------*

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