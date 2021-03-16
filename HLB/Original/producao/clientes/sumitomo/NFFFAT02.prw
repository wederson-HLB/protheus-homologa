#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : FFNFAT02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Sumitomo - Entrada e Saída 
Autor     	: José Augusto	
Data     	: 19/06/2007
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.
*/
 
*-------------------------*
 User Function NFFFAT02()
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos,_cCanDuplo")
DbSelectArea("SM0")                                                            

If cEmpAnt $ "FF"
   If Pergunte("NFFF01    ",.T.)			  
      _cDaNota   := Mv_Par01                        
      _cAtNota   := Mv_Par02
      _cSerie    := Mv_Par03
      _cTpMov    := Mv_Par04
      _cCanDuplo := Mv_Par05
      fOkProc()
   Endif
Else
    MsgInfo("Especifico Sumitomo ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Sumitomo"
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
wnRel    := NomeProg := 'NFFFAT02'
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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Sumitomo")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Sumitomo")
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
   SA4->(DbSetOrder(1))
   SA4->(DbSeek(xFilial("SA4")+SQL->F1_TRANSP))
   
   SE2->(DbSetOrder(1))
   SE2->(DbSeek(xFilial("SE1")+SQL->F1_PREFIXO+SQL->F1_DUPL))
   

   //cMensTes := Formula(SF4->F4_FORMULA) 
   SM4->(DbSetOrder(1))
   If SM4->(dbSeek(xFilial() + SF4->F4_FORMULA))
      cMensTes:=SM4->M4_FORMULA
   EndIf
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
   cDadosA  := F1_DADOSA    
   cPbruto  := F1_PBRUTO//F1_P_PESOB
   cPliquid := F1_PLIQUI//F1_PESOL
   cVolume  := F1_VOLUME1//F1_P_VOLUM
   cEspecie := F1_ESPECI1//F1_P_ESPV 
   
   cText		:={}
  	xMEN_TRIB:={}
   xCLAS_FIS:={}
                 
   //If Ascan(cText, SF4->F4_TEXTO)==0
		AADD(cText , SF4->F4_TEXTO)                               
	//Endif
   aValpag :={}
   aDatpag :={}
   //FATURA
   If! Empty(SQL->F1_PREFIXO+SQL->F1_DUPL)
       Do While.Not.Eof().And.SQL->F1_PREFIXO+SQL->F1_DUPL == SE2->E2_PREFIXO+SE2->E2_NUM
          Aadd(aValPag,{ transform(SE2->E2_VALOR,"@E 9,999,999.99")})
          Aadd(aDatPag,{ Dtoc(SE2->E2_VENCREA)})
          SE2->(DbSkip())
       EndDo
   Endif
   
   
   fCabSf1()
   nLin     :=28
   
  If AllTrim(cTipo)$ "C"
  	  @ nLin,017 pSay "Complemento de Importação"
     @ nLin,100 pSay nVALBRUT  Picture "@E@Z 999,999,999.99"   //Vlr Total
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
         //	SF4->(DbSetOrder(1))
         //	SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
     		//If Ascan(cText, SF4->F4_TEXTO)==0
		  	//	AADD(cText , SF4->F4_TEXTO)                               
	  		//Endif
	      	@ nLin,001 pSay SB1->B1_COD                                      //Código Produto
         If LEN(SB1->B1_DESC) > 60
	         @ nLin,015 pSay SUBSTR(SB1->B1_DESC,1,60)                        //Descrição Produto
		      nLin+=1
	         @ nLin,015 pSay SUBSTR(SB1->B1_DESC,61,60)                       //Descrição Produto
         Else	
	         @ nLin,015 pSay SB1->B1_DESC                                     //Descrição Produto
		   EndIf
				@ nLin,086 pSay SB1->B1_POSIPI			                          //Classificação Fiscal
	      	@ nLin,105 pSay D1_CLASFIS			Picture "999"                   //Situação Tributária
         	@ nLin,112 pSay SB1->B1_UM			                                //Unidade
         	@ nLin,119 pSay D1_QUANT			Picture "@E@Z 999,999.99"       //Quantidade
         	@ nLin,135 pSay D1_VUNIT 			Picture "@E@Z 999,999.999999"   //Preco Bruto         
         	//@ nLin,150 pSay D1_VUNIT		   Picture "@E@Z 9,999,999.99"     //Vlr Unitário    
         	@ nLin,165 pSay D1_TOTAL		   Picture "@E@Z 9,999,999.99"     //Vlr Total
         	@ nLin,192 pSay D1_PICM				Picture "99"               	  //% ICMS    
         	@ nLin,201 pSay D1_IPI			   Picture "99"               	  //% IPI
        		@ nLin,210 pSay D1_VALIPI			Picture "@E 99,999.99"          //Vlr IPI 
         If !Empty(SQL->D1_LOTECTL)
            nLin +=1 
            @ nLin,015 pSay " Lote: " + D1_LOTECTL
         EndIf
       	IncRegua(F1_SERIE+" "+F1_DOC) 
         DbSkip()
         nLin  +=1	
         If nLin > 51   
  				@ 059,001 pSay SA4->A4_NOME                                  
				@ 059,099 PSay "2"                                            //Tipo de frete definido como 2 a pedido do Cliente.
			   @ 059,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
			   @ 061,001 pSay SA4->A4_END
			   @ 061,075 pSay SA4->A4_MUN
			   @ 061,118 pSay SA4->A4_EST
			   
			   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
				   @ 061,125 pSay "ISENTO" 
			   Else      
			      @ 061,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
			   Endif  
	
				@ 063,003 PSAY cVolume     Picture "@E 999,999.99"             // Quant. Volumes
			   @ 063,017 PSAY cEspecie    Picture "@!"                        // Especie
			   @ 063,055 PSAY " "                                             // Res para Marca
			   @ 063,080 PSAY " "                                             // Res para Numero
			   @ 063,124 PSAY cPbruto     Picture "@E 999,999.9999"           // Peso Bruto
			   @ 063,143 PSAY cPliquid    Picture "@E 999,999.9999"           
			   
     		  	@ 067,000 pSay Chr(18)
				If _cCanDuplo == 1
				   @ 067,055 pSay cNota  
				EndIf 
     		  	@ 067,125 pSay cNota 
	  		  	@ 072,000 pSay " "   
     		  	SetPrc(0,0)          
            fCabSf1()
            nLin	:=	30
         Endif
     End         
  Endif 
  
// CALCULO DO IMPOSTO
	@ 54,013  PSAY nBASEICM        Picture "@E@Z 999,999,999.99"  // Base do ICMS
	@ 54,043  PSAY nVALICM	       Picture "@E@Z 999,999,999.99"  // Valor do ICMS
	@ 54,075  PSAY nBsIcmRet	   Picture "@E@Z 999,999,999.99"  // Base ICMS Ret.
	@ 54,100  PSAY nIcmsRet        Picture "@E@Z 999,999,999.99"  // Valor  ICMS Ret.
	@ 54,137  PSAY nVALMERC        Picture "@E@Z 999,999,999.99"  // Valor Tot. Prod.
	@ 56,013  PSAY nFRETE          Picture "@E@Z 999,999,999.99"  // Valor do Frete
	@ 56,043  PSAY nSEGURO         Picture "@E@Z 999,999,999.99"  // Valor Seguro
	@ 56,100  PSAY nVALIPI	       Picture "@E@Z 999,999,999.99"  // Valor do IPI
	@ 56,137  PSAY nVALBRUT        Picture "@E@Z 999,999,999.99"  // Valor Total NF   
	
	//Transportadora
	@ 059,001 pSay SA4->A4_NOME                                  
	@ 059,099 PSay "2"                                            //Tipo de frete definido como 2 a pedido do Cliente.
   @ 059,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 061,001 pSay SA4->A4_END
   @ 061,075 pSay SA4->A4_MUN
   @ 061,118 pSay SA4->A4_EST
   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
	   @ 061,125 pSay "ISENTO" 
   Else      
      @ 061,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   Endif  
	
	@ 63, 003 PSAY cVolume     Picture "@E 999,999.99"             // Quant. Volumes
   @ 63, 017 PSAY cEspecie    Picture "@!"                        // Especie
   @ 63, 055 PSAY " "                                             // Res para Marca
   @ 63, 080 PSAY " "                                             // Res para Numero
   @ 63, 124 PSAY cPbruto     Picture "@E 999,999.9999"           // Peso Bruto
   @ 63, 143 PSAY cPliquid    Picture "@E 999,999.9999"       

	@ 067,000 pSay Chr(18)                              
	If _cCanDuplo == 1
	   @ 067,055 pSay cNota  
	EndIf
   @ 067,125 pSay cNota
	@ 072,000 pSay " "   
   SetPrc(0,0)          
   
EndDo
Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1() 
Local nNumLinhas
Local nLinhaCorrente
Local nTamanhoLinha := 60
Local nLc := 1

@ 000,000 PSAY Chr(15)                     
//@ 001,001 PSAY chr(18)
//@ 003,000 PSAY chr(15)
   
//@ 002, 000 PSAY chr(18)  	                             
      
   If !Empty(cDadosA)
      //nNumLinhas := MLCOUNT(cDadosA,nTamanhoLinha)
      For nLinhaCorrente := 1 To 15
	      @ nLc,003 PSAY MEMOLINE(cDadosA,nTamanhoLinha,nLinhaCorrente,,.F.)
	     If! Alltrim(cTipo) $ "B/D" 
	      If nLc = 1
	         @ 001,190 pSay "X"  
            @ 001,215 pSay cNota
	      ElseIf nLc = 7                 
	         For I := 1 To Len(cText)                                          
	            col := Len(Alltrim(cText[1]))+1
   	         If I == 1
   		         @ 007,082 pSay ALLTRIM(cText[1])
   	         EndIf
   	         If cText[I] <> cText[1]
	   	            @ 007,col pSay "/"+cText[I]
   	         EndIf
             Next 
	         //@ 007,082 pSay ALLTRIM(SF4->F4_TEXTO)
	         @ 007,126 pSay SF4->F4_CF
	      ElseIf nLc = 10               
	         @ 010,082 pSay Alltrim(SA2->A2_NOME) 
	         If Len(AllTrim(SA2->A2_CGC)) == 14 
               @ 010,170 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
            ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
               @ 010,170 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
            Else   
               @ 010,170 pSay SA2->A2_CGC 
            Endif             
            @ 010,212 pSay Dtoc(cEMISSAO)
	      ElseIf nLc = 12  
	         @ 012,082 pSay Alltrim(SA2->A2_END)
            @ 012,150 pSay SA2->A2_BAIRRO
            @ 012,190 pSay Alltrim(SA2->A2_CEP)   Picture "@R 99.999-999"   
         ElseIf nLc = 14   
            @ 014,082 pSay Alltrim(SA2->A2_MUN)
            @ 014,125 pSay Alltrim(SA2->A2_TEL)  // Picture "@R (99)9999-9999"
            @ 014,160 pSay Alltrim(SA2->A2_EST)
            If AllTrim(SA2->A2_INSCR) == "ISENTO" 
               @ 014,180 pSay "ISENTO" 
            Else      
               @ 014,180 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
            Endif
//FR            
         Elseif nLc = 18
         	If len(aValPag) > 0
         		For pg:=1 to len(aValPag)
         			If pg = 1
	         			@017,115 pSay aValPag[pg]
	         			@017,135 pSay aDatPag[pg]
	         		Elseif pg = 2
	         			@017,165 pSay aValPag[pg]
	         			@017,185 pSay aDatPag[pg]
	         		Elseif pg = 3
	         			@018,115 pSay aValPag[pg]
	         			@018,135 pSay aDatPag[pg]
	         		Elseif pg = 4
	         			@018,165 pSay aValPag[pg]
	         			@018,185 pSay aDatPag[pg]
	         		Endif         		
         		Next
         	Endif         	
         Elseif nLc = 20         	
	         	SE4->(DbSetOrder(1))
   				SE4->(DbSeek(xFilial("SE4")+SQL->F1_COND))
	         	If !Empty(SE4->E4_DESCRI)
	         		cConPagDesc := SE4->E4_DESCRI     		
	           		@ 019,095 pSay cConPagDesc picture "@!"
	            Endif                  	
//FR         	         
         
         
         EndIf  
         nLc ++     
        Else  
	      If nLc = 1
	         @ 001,190 pSay "X"  
            @ 001,215 pSay cNota
	      ElseIf nLc = 7                 
	         For I := 1 To Len(cText)                                          
	            col := Len(Alltrim(cText[1]))+1
   	         If I == 1
   		         @ 007,082 pSay ALLTRIM(cText[1])
   	         EndIf
   	         If cText[I] <> cText[1]
	   	            @ 007,col pSay "/"+cText[I]
   	         EndIf
             Next 
	         //@ 007,082 pSay ALLTRIM(SF4->F4_TEXTO)
	         @ 007,126 pSay SF4->F4_CF
	      ElseIf nLc = 10               
	         @ 010,082 pSay Alltrim(SA1->A1_NOME) 
	         If Len(AllTrim(SA1->A1_CGC)) == 14 
               @ 010,170 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
            ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
               @ 010,170 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
            Else   
               @ 010,170 pSay SA1->A1_CGC 
            Endif             
            @ 010,212 pSay Dtoc(cEMISSAO)
	      ElseIf nLc = 12  
	         @ 012,082 pSay Alltrim(SA1->A1_END)
            @ 012,150 pSay SA1->A1_BAIRRO
            @ 012,190 pSay Alltrim(SA1->A1_CEP)   Picture "@R 99.999-999"   
         ElseIf nLc = 14   
            @ 014,082 pSay Alltrim(SA1->A1_MUN)
            @ 014,125 pSay Alltrim(SA1->A1_TEL)  // Picture "@R (99)9999-9999"
            @ 014,160 pSay Alltrim(SA1->A1_EST)
            If AllTrim(SA1->A1_INSCR) == "ISENTO" 
               @ 014,180 pSay "ISENTO" 
            Else      
               @ 014,180 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
            Endif  
         EndIf  
         nLc ++         
        Endif 
      Next
   ElseIf! Alltrim(cTipo) $ "B/D"  
	    @ 001,190 pSay "X"  
       @ 001,215 pSay cNota   
       For I := 1 To Len(cText)                                          
	       col := Len(Alltrim(cText[1]))+1
   	    If I == 1
   	       @ 007,082 pSay ALLTRIM(cText[1])
   	    EndIf
   	    If cText[I] <> cText[1]
	   	    @ 007,col pSay "/"+cText[I]
   	    EndIf
       Next 
       //@ 007,082 pSay ALLTRIM(SF4->F4_TEXTO)
	    @ 007,126 pSay SF4->F4_CF
       @ 010,082 pSay Alltrim(SA2->A2_NOME) 
	    If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 010,170 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 010,170 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,170 pSay SA2->A2_CGC 
       Endif             
       @ 010,21 pSay Dtoc(cEMISSAO)
	    @ 012,082 pSay Alltrim(SA2->A2_END)
       @ 012,150 pSay SA2->A2_BAIRRO
       @ 012,190 pSay Alltrim(SA2->A2_CEP)   Picture "@R 99.999-999"   
       @ 014,082 pSay Alltrim(SA2->A2_MUN)
       @ 014,125 pSay Alltrim(SA2->A2_TEL)  // Picture "@R (99)9999-9999"
       @ 014,160 pSay Alltrim(SA2->A2_EST)
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 014,180 pSay "ISENTO" 
       Else      
          @ 014,180 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else  
	    @ 001,190 pSay "X"  
       @ 001,215 pSay cNota   
       For I := 1 To Len(cText)                                          
	       col := Len(Alltrim(cText[1]))+1
   	    If I == 1
   	       @ 007,082 pSay ALLTRIM(cText[1])
   	    EndIf
   	    If cText[I] <> cText[1]
	   	    @ 007,col pSay "/"+cText[I]
   	    EndIf
       Next 
       //@ 007,082 pSay ALLTRIM(SF4->F4_TEXTO)
	    @ 007,126 pSay SF4->F4_CF
       @ 010,082 pSay Alltrim(SA1->A1_NOME) 
	    If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 010,170 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 010,170 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,170 pSay SA1->A1_CGC 
       Endif             
       @ 010,212 pSay Dtoc(cEMISSAO)
	    @ 012,082 pSay Alltrim(SA1->A1_END)
       @ 012,150 pSay SA1->A1_BAIRRO
       @ 012,190 pSay Alltrim(SA1->A1_CEP)   Picture "@R 99.999-999"    
       @ 014,082 pSay Alltrim(SA1->A1_MUN)
       @ 014,125 pSay Alltrim(SA1->A1_TEL)  // Picture "@R (99)9999-9999"
       @ 014,160 pSay Alltrim(SA1->A1_EST)
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 014,180 pSay "ISENTO" 
       Else      
          @ 014,180 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif      
   Endif   

   If !empty(cMensTes)
   	@ 018, 003 PSAY SUBSTR(cMensTes,1,40)
   	@ 019, 003 PSAY SUBSTR(cMensTes,41,40)
   	@ 020, 003 PSAY SUBSTR(cMensTes,81,40)
   EndIf

@ 21, 000 PSAY CHR(15)
@ 24, 000 PSAY CHR(18)
@ 25, 000 PSAY CHR(15)


Return

//----------------------------------------------------------- Emite nfs.
Static Function fImpSF2()
DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())


//---Customização solicitada pela Sumitomo - Liberação de NF´s para emissão - documentação em \\rdmake\cliente\sumitomo\

//If Empty(SQL->F2_P_FLAG).And.!(__cUserId $ "000222/000236/000000/000119/000194")
If Empty(SQL->F2_P_FLAG).And.!(__cUserId $ "000266/000259/000126/000000/000257/000489/000503")
    MsgInfo("Nota "+SQL->F2_SERIE+AllTrim(SQL->F2_DOC)+" nao liberada para emissao !","A T E N C A O")
ELse

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
   cPbruto  := F2_PBRUTO
   cPliquid := F2_PLIQUI
   cVolume  := F2_VOLUME1
   cEspecie := F2_ESPECI1 
   nVlrIPI  := 0
   cCfop    := ""
	cMensTes := ""
	xMEN_TRIB :={}
  	xCLAS_FIS :={}
  	aMensTES  :={}
  	nBsIcmRet :=0      
  
  				
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
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
	
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SQL->D2_DOC+SQL->D2_SERIE))
                                           
   //JAP - 28-06-07
   cDadosR  := SC5->C5_DADOSR

   //cMensTes := Formula(SF4->F4_FORMULA) 
   SM4->(DbSetOrder(1))      
   If SM4->(dbSeek(xFilial() + SF4->F4_FORMULA))
      cMensTes:=SM4->M4_FORMULA
   EndIf
   aVal :={}
   aVen :={}
   //FATURA
   If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
          Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})
          Aadd(aVen,{ Dtoc(SE1->E1_VENCORI)})
          SE1->(DbSkip())
       EndDo
   Endif    
   cText	:={}     
   aMerc    :={}
   aServ    :={}
   nPerc	:={}
   ImpDupl	:= 0
   cCompara := F2_DOC+F2_SERIE

//FR

	cSQLNF := SQL->D2_DOC
	cSQLSR := SQL->D2_SERIE
	xTES := fCallTES(cSQLNF,cSQLSR)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))				
			If !Empty(SF4->F4_FORMULA)
				Aadd(aMensTes,SF4->F4_FORMULA)	
			Endif
		Next
   Endif
//FR
   
 
   
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

         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,D2_QUANT,D2_PRCVEN,;
            D2_TOTAL,SC6->C6_DESCRI})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,AllTrim(SC6->C6_DESCRI),SB1->B1_POSIPI,SQL->D2_CLASFIS,;
            SB1->B1_UM,SQL->D2_QUANT,SQL->D2_PRUNIT,SQL->D2_PRCVEN,SQL->D2_TOTAL,SQL->D2_PICM,;
            SQL->D2_IPI,SQL->D2_VALIPI,SQL->D2_LOTECTL,SQL->D2_DESCON})
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
         
         IncRegua(SQL->F2_SERIE+" "+SQL->F2_DOC)   
         DBSELECTAREA("SQL")
         DbSkip()
   Enddo 

   ImpDupl	:= Len(aMerc)
   pTotal	:= (Len(aMerc)/30+0.47)
   pTotal	:= Round(pTotal,0)
   j			:= 1
   fCabSf2()   


   nMerc :=1
   nLin  :=28
   nPos  :=1

	IF Alltrim(cTipo) = "I"
		@ nLin+3,017  PSAY "COMPLEMENTO DE I.C.M.S."
	ElseIf Alltrim(cTipo) = "P"
		@ nLin+3,017  PSAY "COMPLEMENTO DE I.P.I."
		@ nLin+3,115  PSAY aMerc[nMerc][10]		  Picture "99"
		@ nLin+3,210  PSAY nVALIPI		  			  Picture "@E 99,999,999.99"
	Else	
      While nMerc <= Len(aMerc)
         @ nLin,001 pSay aMerc[nMerc][01]                                 //Código Produto
         IF LEN(aMerc[nMerc][02]) > 60
	         @ nLin,015 pSay SUBSTR(aMerc[nMerc][02],1,60)                 //Descrição Produto
		      nLin+=1
	         @ nLin,015 pSay SUBSTR(aMerc[nMerc][02],61,60)                //Descrição Produto
         ELSE	
	         @ nLin,015 pSay aMerc[nMerc][02]                              //Descrição Produto
		   ENDIF
			@ nLin,086 pSay aMerc[nMerc][03]			                          //Classificação Fiscal
	      @ nLin,105 pSay aMerc[nMerc][04] Picture "999"                   //Situação Tributária
         @ nLin,112 pSay aMerc[nMerc][05]                                 //Unidade
         @ nLin,119 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
         //@ nLin,135 pSay aMerc[nMerc][07] Picture "@E@Z 999,999.99"     //Preco Bruto         
         @ nLin,135 pSay (aMerc[nMerc][09] + aMerc[nMerc][14]) / (aMerc[nMerc][06]) Picture "@E@Z 9,999,999.999999"     //Vlr Unitário    
         @ nLin,165 pSay aMerc[nMerc][09] + aMerc[nMerc][14] Picture "@E@Z 9,999,999.99"     //Vlr Total
         @ nLin,192 pSay aMerc[nMerc][10] Picture "99"               	  //% ICMS    
         @ nLin,201 pSay aMerc[nMerc][11] Picture "99"               	  //% IPI
         @ nLin,210 pSay aMerc[nMerc][12] Picture "@E 99,999.99"          //Vlr IPI   
         If !Empty(aMerc[nMerc][13])                    
            nLin +=1                                   
            If !Empty(aMerc[nMerc][14])
            @nLin,015 pSay " Lote: " + aMerc[nMerc][13] + "/ Com Desconto"
            @nLin,165 pSay aMerc[nMerc][14] * (-1) Picture "@E@Z 9,999,999.99" 
            Else 
               @nLin,015 pSay " Lote: " + aMerc[nMerc][13] 
            EndIf
         ElseIf !Empty(aMerc[nMerc][14])
            @nLin,015 pSay "Com Desconto"
            @nLin,165 pSay aMerc[nMerc][14] * (-1) Picture "@E@Z 9,999,999.99" 
         EndIf  
         nLin  +=1
         ImpDupl -= 1
         If nLin > 51  
   		   @ 060,001 pSay SA4->A4_NOME                
   		   If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
      	      @ 060,098 PSay "1"
            ElseIf SC5->C5_TPFRETE == "F"   
               @ 060,098 PSay "2"   
            Endif
            @ 060,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
            @ 062,001 pSay SA4->A4_END
            @ 062,075 pSay SA4->A4_MUN
            @ 062,113 pSay SA4->A4_EST
            If AllTrim(SA4->A4_INSEST) == "ISENTO" 
	            @ 062,125 pSay "ISENTO" 
            Else      
   	         @ 062,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
            Endif       
			    @ 065,000 pSay Chr(18)      &&67
     		  	@ 065,055 pSay cNota        
     		  	@ 065,125 pSay cNota 
	  		  	@ 072,000 pSay " "   
     		  	SetPrc(0,0)          
            fCabSf1()
            nLin	:=	30
         Endif       
         nMerc +=1  
      End
   Endif
   
// Cálculo do Imposto  
If cTipo $"I"	
	@ 54, 043  PSAY nVALICM			 Picture "@E 999,999,999.99"  // Valor do ICMS
ElseIf cTipo == "P"
	@ 54, 013  PSAY nBASEICM       Picture "@E 999,999,999.99"  // Base do ICMS
	@ 54, 043  PSAY nVALICM        Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 56, 137  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
Else
	@ 54,013  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
	@ 54,043  PSAY nVALICM		    Picture "@E 999,999,999.99"  // Valor do ICMS
	@ 54,075  PSAY nBsIcmRet		 Picture "@E 999,999,999.99"  // Base ICMS Ret.
	@ 54,100  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
	@ 54,137  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
	@ 56,013  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
	@ 56,043  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
	@ 56,100  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
	@ 56,137  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
EndIf
                                                                                              
//Transportadora
   @ 059,001 pSay SA4->A4_NOME                
   If (SC5->C5_TPFRETE  == "C")  .OR. (Alltrim(SC5->C5_TPFRETE) == "")
      @ 059,098 PSay "1"
   ElseIf SC5->C5_TPFRETE == "F"   
      @ 059,098 PSay "2"   
   Endif
   @ 059,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   @ 061,001 pSay SA4->A4_END
   @ 061,075 pSay SA4->A4_MUN
   @ 061,113 pSay SA4->A4_EST
   If AllTrim(SA4->A4_INSEST) == "ISENTO" 
	   @ 061,125 pSay "ISENTO" 
   Else      
   	@ 061,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   Endif   
   
   @ 63, 003 PSAY cVolume     Picture "@E 999,999.99"             // Quant. Volumes
   @ 63, 017 PSAY cEspecie    Picture "@!"                        // Especie
   @ 63, 055 PSAY " "                                             // Res para Marca
   @ 63, 080 PSAY " "                                             // Res para Numero
   @ 63, 124 PSAY cPbruto     Picture "@E 999,999.9999"           // Res para Peso Bruto
   @ 63, 143 PSAY cPliquid    Picture "@E 999,999.9999"       
                
	@ 067,000 pSay Chr(18)      
	If _cCanDuplo == 1
	   @ 067,055 pSay Alltrim(cNota)  
	EndIf                        
   @ 067,125 pSay Alltrim(cNota)
	@ 072,000 pSay " "   
   SetPrc(0,0)
   
   If! __cUserId $ "000266/000259/000126/000000/000257/000489/000503"
		cQuery :=""
		cQuery := "UPDATE SF2FF0 SET F2_P_FLAG = '2' "+Chr(10)
		cQuery += " WHERE F2_FILIAL = '"+xFilial("SF2")+"' "+Chr(10)
		cQuery += "AND F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
		cQuery += " F2_SERIE = '"+alltrim(_cSerie)+"' AND D_E_L_E_T_ <> '*'"
		TcSqlExec(cQuery) 
   Endif 
   
 EndDo  

Endif         

Return 

//-----------------------------------------------------------Emite cabeçalho da nfs.

Static Function fCabSf2()  
Local nNumLinhas
Local nLinhaCorrente
Local nTamanhoLinha := 60
Local nLc := 1  
Local cEndCobFat := ""
Local cDesConPag := ""
   
@ 000, 000 PSAY Chr(15)                     

   If !Empty(cDadosR)
      For nLinhaCorrente := 1 To 15
         @ nLc, 003 PSAY MEMOLINE(cDadosR,nTamanhoLinha,nLinhaCorrente,,.F.)
       IF Alltrim(cTipo) $ "B/D"  
         If nLc = 1
            @ 001,178 pSay "X"  
            @ 001,215 pSay cNota 
         ElseIf nLc = 7
            	For I := 1 To Len(cText)                                          
	               col := Len(Alltrim(cText[1]))+1
   	            If I == 1
   		            @ 007,082 pSay ALLTRIM(cText[1])
   	            EndIf
   	            If cText[I] <> cText[1]
	   	            @ 007,col pSay "/"+cText[I]
   	            EndIf
               Next  
               @ 007,126 pSay cCfop                     
         ElseIf nLc = 10
            @ 010,082 pSay Alltrim(SA2->A2_NOME) 
            If Len(AllTrim(SA2->A2_CGC)) == 14 
               @ 010,170 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
            ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
               @ 010,170 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
            Else   
               @ 010,170 pSay SA2->A2_CGC
            Endif   
            @ 010,212 pSay Dtoc(cEMISSAO)
         ElseIf nLc = 12
            @ 012,082 pSay Alltrim(SA2->A2_END)
            @ 012,150 pSay SA2->A2_BAIRRO
            @ 012,190 pSay Alltrim(SA2->A2_CEP)   Picture "@R 99.999-999" 
         ElseIf nLc = 14
            @ 014,082 pSay Alltrim(SA2->A2_MUN)
            @ 014,125 pSay Alltrim(SA2->A2_TEL)  // Picture "@R (99)9999-9999"
            @ 014,160 pSay Alltrim(SA2->A2_EST) 
            If AllTrim(SA2->A2_INSCR) == "ISENTO" 
               @ 014,180 pSay "ISENTO" 
            Else      
               @ 014,180 pSay Alltrim(SA2->A2_INSCR) Picture "@R 999.999.999.999"  
            Endif  
         EndIf   
		 ELSE         
         If nLc = 1
            @ 001,178 pSay "X"  
            @ 001,215 pSay cNota 
         ElseIf nLc = 7
            	For I := 1 To Len(cText)                                          
	               col := Len(Alltrim(cText[1]))+1
   	            If I == 1
   		            @ 007,082 pSay ALLTRIM(cText[1])
   	            EndIf
   	            If cText[I] <> cText[1]
	   	            @ 007,col pSay "/"+cText[I]
   	            EndIf
               Next  
               @ 007,126 pSay cCfop                     
         ElseIf nLc = 10
            @ 010,082 pSay Alltrim(SA1->A1_NOME) 
            If Len(AllTrim(SA1->A1_CGC)) == 14 
               @ 010,170 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
            ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
               @ 010,170 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
            Else   
               @ 010,170 pSay SA1->A1_CGC
            Endif   
            @ 010,212 pSay Dtoc(cEMISSAO)
         ElseIf nLc = 12
            @ 012,082 pSay Alltrim(SA1->A1_END)
            @ 012,150 pSay SA1->A1_BAIRRO
            @ 012,190 pSay Alltrim(SA1->A1_CEP)   Picture "@R 99.999-999" 
         ElseIf nLc = 14
            @ 014,082 pSay Alltrim(SA1->A1_MUN)
            @ 014,125 pSay Alltrim(SA1->A1_TEL)  // Picture "@R (99)9999-9999"
            @ 014,160 pSay Alltrim(SA1->A1_EST) 
            If AllTrim(SA1->A1_INSCR) == "ISENTO" 
               @ 014,180 pSay "ISENTO" 
            Else      
               @ 014,180 pSay Alltrim(SA1->A1_INSCR) Picture "@R 999.999.999.999"  
            Endif  
         EndIf
        ENDIF 
         nLc ++
      Next 
   Else   
      If !empty(SC5->C5_MENNOTA)
         @ 001,002 pSay SUBSTR(SC5->C5_MENNOTA,1,60) 
         @ 001,178 pSay "X"  
         @ 001,215 pSay cNota        
         @ 002,002 pSay SUBSTR(SC5->C5_MENNOTA,61,60) 
         @ 003,002 pSay SUBSTR(SC5->C5_MENNOTA,121,60) 
         @ 004,002 pSay SUBSTR(SC5->C5_MENNOTA,181,60)
         @ 005,002 pSay SUBSTR(SC5->C5_MENNOTA,241,60)  
         @ 006,002 pSay SUBSTR(SC5->C5_MENNOTA,301,60)
         @ 007,002 pSay SUBSTR(SC5->C5_MENNOTA,361,60)
      Else 
         @ 001,178 pSay "X"  
         @ 001,215 pSay cNota
      EndIf      
      For I := 1 To Len(cText)                                          
	      col := Len(Alltrim(cText[1]))+1
   	   If I == 1
   	      @ 007,082 pSay ALLTRIM(cText[1])
   	   EndIf
   	   If cText[I] <> cText[1]
	      @ 007,col pSay "/"+cText[I]
   	   EndIf
      Next  
      @ 007,126 pSay cCfop      
      If !Empty(SUBSTR(SC5->C5_MENNOTA,421,60)) 
         @ 008,002 pSay SUBSTR(SC5->C5_MENNOTA,421,60)   
      EndIf
      If !Empty(SUBSTR(SC5->C5_MENNOTA,481,60))
         @ 009,002 pSay SUBSTR(SC5->C5_MENNOTA,481,60) 
      Endif
      
  	 IF Alltrim(cTipo) $ "B/D"
		@ 010,082 pSay SA2->A2_NOME
      If Len(AllTrim(SA2->A2_CGC)) == 14 
         @ 010,170 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
         @ 010,170 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
      Else   
         @ 010,170 pSay SA2->A2_CGC
      Endif   
      @ 010,212 pSay Dtoc(cEMISSAO)
      @ 012,082 pSay SA2->A2_END
      @ 012,150 pSay SA2->A2_BAIRRO
      @ 012,190 pSay SA2->A2_CEP   Picture "@R 99.999-999"
      @ 014,082 pSay SA2->A2_MUN
      @ 014,125 pSay SA2->A2_TEL  
      @ 014,160 pSay SA2->A2_EST
      If AllTrim(SA2->A2_INSCR) == "ISENTO" 
         @ 014,180 pSay "ISENTO" 
      Else      
         @ 014,180 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
      Endif
            	
  	 ELSE
  	 
      @ 010,082 pSay SA1->A1_NOME
      If Len(AllTrim(SA1->A1_CGC)) == 14 
         @ 010,170 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
      ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
         @ 010,170 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
      Else   
         @ 010,170 pSay SA1->A1_CGC
      Endif   
      @ 010,212 pSay Dtoc(cEMISSAO)
      @ 012,082 pSay SA1->A1_END
      @ 012,150 pSay SA1->A1_BAIRRO
      @ 012,190 pSay SA1->A1_CEP   Picture "@R 99.999-999"
      @ 014,082 pSay SA1->A1_MUN
      @ 014,125 pSay SA1->A1_TEL  
      @ 014,160 pSay SA1->A1_EST
      If AllTrim(SA1->A1_INSCR) == "ISENTO" 
         @ 014,180 pSay "ISENTO" 
      Else      
         @ 014,180 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
      Endif    
    ENDIF  
   Endif            
                
If Empty(aVen) .And. !Empty(Alltrim(SA1->A1_ENDREC))
   @ 017,003 pSay "End. Receb.: " + SA1->A1_ENDREC     
EndIf

//Imprime Fatura
IF ImpDupl <= 30
	nCol := 135
	nLin := 018 
	If !Empty(aVen) .And. Len(aVen) <= 4
    	For i:= 1 to Len(aVen)      
	      If i = 1
	         If !Empty(Alltrim(SA1->A1_ENDREC))
    		    @ 017,003 pSay "End. Receb.: " + SA1->A1_ENDREC     
            EndIf
	         	@ 017, 115           PSAY aVen[i][1]                             
		     	@ 017, 135           PSAY aVal[i][1]
		  	ElseIf i = 2                            
		  	   @ 017, 165           PSAY aVen[i][1]                             
		  	   @ 017, 185           PSAY aVal[i][1] 
		  	ElseIf i = 3 
		  	   @ 018, 115           PSAY aVen[i][1]                             
		  	   @ 018, 135           PSAY aVal[i][1]
		  	ElseIf i = 4 
		  	   @ 018, 165           PSAY aVen[i][1]                             
		  	   @ 018, 185           PSAY aVal[i][1] 
		  	EndIf
      Next  
      If !Empty(SE4->E4_DESCRI)
         cDesConPag := SE4->E4_DESCRI 
      EndIf
      If !Empty(SA1->A1_ENDCOB)
         cEndCobFat := SA1->A1_ENDCOB
      EndIf
	Endif    
EndIf

If ALLTRIM(SE4->E4_CODIGO) = '004'
   cDesConPag := SE4->E4_DESCRI 
EndIf


If !Empty(cMensTes)                     
   @ 019, 003 PSAY SUBSTR(cMensTes,1,60)
  	@ 020, 003 PSAY SUBSTR(cMensTes,61,60) 
  	If !Empty(cDesConPag)
  	   @ 020, 095 pSay AllTrim(cDesConPag) 
  	   cDesConPag := ""
  	EndIf
  	@ 021, 003 PSAY SUBSTR(cMensTes,121,60)
EndIf

        
If !Empty(cDesConPag)
   @ 020, 095 pSay AllTrim(cDesConPag) 
EndIf       
If !Empty(cEndCobFat)
   @ 022, 095 pSay Alltrim(cEndCobFat)    
EndIf   
  
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
cQuery += "SF1.F1_SERIE = '"+Alltrim(_cSerie)+"' AND "+Chr(10)
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

//------------------------------------------------------------------

Static Function fGerSf2()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())
   
cQuery := "SELECT D2_DOC,D2_SERIE,D2_TES,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_VALICM,D2_IPI,D2_VALIPI,D2_PRUNIT,D2_CLASFIS, "+Chr(10)+CHR(13)
cQuery += "D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VOLUME1,F2_ESPECI1,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO,F2_ICMSRET, F2_P_FLAG "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC >= '"+_cDaNota+"' AND SF2.F2_DOC <='"+_cAtNota+"' AND "+Chr(10)
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
//**************************************************************************************** 

/*-------------------------*/
Static Function fCallTES(cSQLNF,cSQLSR)   
/*-------------------------*/
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

