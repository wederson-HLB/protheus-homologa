#include "topconn.ch"
#include "rwmake.ch"   
#INCLUDE "colors.ch"

/*
Funcao      : U2NFAT01
Parametros  : Nenhum
Retorno     : dDataDesc
Objetivos   : Nota Fiscal Dr Reddy´s - Entrada e Saída  
Autor     	: Wederson L. Santana 
Data     	: 17/03/2004
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

*------------------------*
 User Function U2NFAT01()
*------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,_cPerg,cFornece,cLoja")

_cPerg:="U2NFAT    "

If cEmpAnt $ "U2"
   //fCriaPerg()
   If Pergunte(_cPerg,.T.)
      _cDaNota := Mv_Par01
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      _cTpMov  := Mv_Par04
       fOkProc()  
   Endif
Else
    MsgInfo("Especifico Dr Reddy´s"," A T E N C A O ")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf


tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Dr Reddy's"
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
wnRel    := NomeProg := 'U2NFAT01'
nALIQICMP:=GetMV('MV_ICMPAD')
cESTICM  :=GETMV('MV_ESTICM')
nAliqUFD :=0
nAliqREP :=0

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
   RptStatus({|| fImpSF1()},"Nota de Entrada - Dr Reddy's")
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Saida - Dr Reddy's")
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
   cNota    := SQL->F1_DOC
   cEmissao := SQL->F1_EMISSAO
   nValMerc := SQL->F1_VALMERC          
   nValIpi  := SQL->F1_VALIPI
   //nValIcm  := SQL->F1_VALICM
   //nBaseIcm := SQL->F1_BASEICM
   nValBrut := SQL->F1_VALBRUT
   nDespesa := SQL->F1_DESPESA
   nFrete   := SQL->F1_FRETE
   nBrIcms  := SQL->F1_BRICMS
   nIcmsRet := SQL->F1_ICMSRET
   nSeguro  := SQL->F1_SEGURO
   cTipo    := SQL->F1_TIPO
   cCompara := SQL->F1_DOC+F1_SERIE
   nDescont := SQL->F1_DESCONT  
   nVal_comp:= SQL->F1_VALBRUT
   nPICMS:= SQL->D1_PICM

   nValIcm  := 0
   nBaseIcm := 0
   _PercDesc := 0  //calcula o percentual do desconto
    cText		:={}
   nPREPICM  :=0
   nVREPICM  :=0
   xMEN_TRIB:={}
   xCLAS_FIS:={}
   _TotVal:=0 
   
   fCabSf1()                 
   @ 015,000 pSay Chr(15)     
   //@ 016,000 pSay Chr(27)+"0"     
   
   nLin:=023
   //@ 021,000 pSay Chr(27)+"2"   
   
   
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
         If !Empty(SQL->D1_NFORI)
            IF SF2->F2_DOC<>SQL->D1_NFORI
               DbSelectArea('SF2')
               DbSetOrder(2)
               DbGotop()
               DbSeek(xFilial('SF2')+SQL->D1_FORNECE+SQL->D1_LOJA+SQL->D1_NFORI+SQL->D1_SERIORI)
               If Found()
                  nPREPICM  :=SF2->F2_PREPICM
                  nVREPICM  :=SF2->F2_VREPICM
               EndIf   
            Else
               nPREPICM  :=SF2->F2_PREPICM
               nVREPICM  :=SF2->F2_VREPICM
            EndIf

         EndIf    
	     
	     _TotVal += (SQL->D1_VUNIT * SQL->D1_QUANT)

         nValIcm  += SQL->D1_VALICM
         nBaseIcm += SQL->D1_BASEICM
         @ nLin,016 pSay SubStr(SB1->B1_COD,1,12)
         @ nLin,034 pSay SubStr(SB1->B1_DESC,1,30)
         @ nLin,149 pSay SB1->B1_POSIPI
         @ nLin,165 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB
         @ nLin,172 pSay SB1->B1_UM
         @ nLin,178 pSay SQL->D1_QUANT   Picture "@E 99999"
         @ nLin,197 pSay SQL->D1_LOTECTL                     //JOSÉ
         @ nLin,210 pSay SQL->D1_VUNIT   Picture "@E 999,999,999.99"
         @ nLin,231 pSay SQL->D1_TOTAL   Picture "@E 999,999,999.99"
         @ nLin,247 pSay SQL->D1_PICM    Picture "@E 99.99"
         @ nLin,253 pSay SQL->D1_IPI     Picture "@E 99.99"
         @ nLin,262 pSay SQL->D1_VALIPI  Picture "@E 999,999.99"             
         nLin ++
         If nLin ==047
            @ 062,000 pSay Chr(18)
            @ 063,150 pSay cNota
            @ 067,000 pSay ""   
            SetPrc(0,0)   
            fCabSf1()                                 
            nLin:=022
            @ nLin,000 pSay Chr(15)     
         Endif
         DbSelectArea("SQL")
         IncRegua(SQL->F1_SERIE+" "+SQL->F1_DOC)   
         DbSkip()
   EndDo       
   If nDescont > 0
	  nLin:= nLin + 1
	  @ nLin,165 pSay "Sub Total ..."           
	  @ nLin,189 pSay  _TotVal Picture "@E 999,999,999.99"	//Valor total sem desconto         
	  nLin:= nlin + 1
	  @ nLin,165 pSay "Desc ..." 
	  _PercDesc := ( nDescont / _TotVal ) * 100   //calcula o percentual do desconto
	  @ nLin,175 pSay _PercDesc Picture "@e 999.99"+"%" //Percentual de desconto
	  @ nLin,189 pSay nDescont Picture "@E 999,999,999.99"	
	  nLin:= nlin + 1
	  @ nLin,165 pSay "Sub Total ..." 
	  @ nLin,189 pSay (_TotVal-nDescont) Picture "@E 999,999,999.99"	//valor total com desconto
	  nLin++         
     If nVREPICM > 0
	     @ nLin,165 pSay "Repasse ICMS ..." +Transform(nPREPICM,"@R 999.9999 %") 
	     @ nLin,193 pSay TransForm(nVREPICM,"@R 999,999.99")
	     nLin++         
	 EndIf    
      @ nLin,189 Psay "--------------"
	  nLin++         
	  @ nLin,165 pSay "Valor Liquido... R$ "
	  @ nLin,189 pSay Transform(nVal_comp,"@E 999,999,999.99")
	  nLin++         

   	  nLin++
   	  nLin++
     If nVREPICM > 0
        @ nLin,049 pSay "Abaixo segue informacoes de ICMS, que e o valor total do produto (ja sem os descontos) x o percentual da regiao (neste caso "+Transform(nPICMS,"@R 999.9999 %" )
 	    nLin++
      EndIf
   EndIf
   
   @ 050,000 pSay Chr(18)        
   
   @ 051,010 pSay nBaseIcm Picture "@E 999,999,999.99"
   @ 051,030 pSay nValIcm  Picture "@E 999,999,999.99"
   If !Empty(nBrIcms) .And. !Empty(nIcmsRet)
      @ 051,050 pSay nBrIcms  Picture "@E 999,999,999.99"
      @ 051,070 pSay nIcmsRet  Picture "@E 999,999,999.99"
   EndIf 
   
   @ 051,094 pSay nValMerc Picture "@E 999,999,999.99"
   
   @ 053,010 pSay nFrete   Picture "@E 999,999,999.99"
   @ 053,030 pSay nSeguro  Picture "@E 999,999,999.99"
   @ 053,050 pSay nDespesa Picture "@E 999,999,999.99"
   @ 053,070 pSay nValIpi  Picture "@E 999,999,999.99"
   @ 053,094 pSay nValBrut Picture "@E 999,999,999.99"
   
//   @ 061,007 pSay SC5->C5_VOLUME1
//   @ 061,022 pSay SC5->C5_ESPECI1

   @ 063,150 pSay cNota
   @ 067,000 pSay ""   
   SetPrc(0,0)   
EndDo

Return 

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
   //@ 001,000 pSay Chr(27)+"M"
   @ 002,132 pSay "X"
   @ 002,154 pSay cNota

   If! Empty(cMensTes)                 
      @ 003,012 pSay SubStr(cMensTes,01,45)  
      @ 004,012 pSay SubStr(cMensTes,46,45)  
      @ 005,012 pSay SubStr(cMensTes,91,45)  
   Endif   
   If! Empty(SQL->D1_OBS)                 
      @ 007,012 pSay SubStr(SQL->D1_OBS,01,45)  
   Endif   
   
   @ 007,067 pSay SF4->F4_TEXTO
   @ 007,103 pSay SF4->F4_CF              
   
   @ 008,012 PSAY "Endereco:Av.Guido Caloi-GALPAO 11 JD.SAO LUIS"
   @ 009,012 pSay "SAO PAULO-CEP 05802-140"
   If AllTrim(cTipo) $ "B/D"
       @ 010,067 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 010,131 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 010,131 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,131 pSay SA1->A1_CGC
       Endif   
       @ 010,153 pSay cEmissao //Dtoc(dDataBase)

       @ 012,067 pSay SubStr(SA1->A1_END,1,29)
       @ 012,117 pSay SA1->A1_BAIRRO
       @ 012,140 pSay SA1->A1_CEP   Picture "@R 99.999-999"

       @ 014,067 pSay SA1->A1_MUN
       @ 014,093 pSay SA1->A1_TEL   
       @ 014,126 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 014,133 pSay "ISENTO" 
       Else      
          @ 014,133 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
          @ 010,067 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 010,131 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 010,131 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,131 pSay SA2->A2_CGC
       Endif   
       @ 010,153 pSay cEmissao //Dtoc(dDataBase)
       @ 012,067 pSay SubStr(SA2->A2_END,1,29)
       @ 012,117 pSay SA2->A2_BAIRRO
       @ 012,140 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 014,067 pSay SA2->A2_MUN
       @ 014,093 pSay SA2->A2_TEL   
       @ 014,126 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 014,133 pSay "ISENTO" 
       Else      
          @ 014,133 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Endif    
Return

//----------------------------------------------------------- Emite nfs.

Static Function fImpSF2()
cTipo:=""
cTexto_143:=""              

DbSelectArea("SQL")
DbGoTop()    

SetRegua(RecCount())
Do While.Not.Eof().And.cTipo <> "I"
  
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
   SC6->(DbSetOrder(1))
   SC6->(DbSeek(xFilial("SC6")+SQL->D2_PEDIDO+SQL->D2_ITEMPV))  
   SM4->(DbSetOrder(1))   
   SM4->(DbSeek(xFilial("SM4")+SF4->F4_FORMULA))
   
   cCfop := SC6->C6_CF
   
   //cMensTes := Formula(SF4->F4_FORMULA)
   cMensTes := SM4->M4_FORMULA                
   nBaseIcm := SQL->F2_BASEICM
   nValIcm  := SQL->F2_VALICM
   
   nBasIcmsRet:= SQL->F2_BRICMS 	//Base ICMS substit.
   nIcmsRet   := SQL->F2_ICMSRET   //Vlr. ICMS substit.
   
   nValMerc := SQL->F2_VALMERC
   nFrete   := SQL->F2_FRETE  
   nSeguro  := SQL->F2_SEGURO
   nDespesa := SQL->F2_DESPESA
   nValIpi  := SQL->F2_VALIPI
   nValBrut := SQL->F2_VALBRUT
   cEmissao := SQL->F2_EMISSAO
   cNota    := SQL->F2_DOC
   nPbruto  := SQL->F2_PBRUTO
   nPliqui  := SQL->F2_PLIQUI
   nValCofi := 0
   nValCsll := 0
   nValPis  := 0
   cTipo    := SQL->F2_TIPO
	nDescont := SQL->F2_DESCONT
	nVal_Merc:= SQL->F2_VALMERC
	nVal_comp:= SQL->F2_VALFAT
	xMENS_PED:= SC5->C5_MENNOTA
	xPED_SM4 := ""
	xSF4_SM4 := ""
   cRecolhe_Emb:=SQL->RECOLHE 
   nPREPICM  :=SQL->F2_PREPICM
   nVREPICM  :=SQL->F2_VREPICM
   lICMSUBS := .F.
   cMsg313_A:= ""
   nPICMS    := 0 
   nAliqUFD :=Val( Substr(cESTICM,At(SQL->F2_EST,cESTICM)+2,2))
	
   cSQLNF   := ""
   cSQLSR   := ""
   xTES     := {}
   aMensTes := {}
   cMensTes := ""
   cCfop    := ""       
   cText    := ""
   nVlrICMST:= 0
   
   If! Empty(SC5->C5_MENPAD)
      xPed_SM4:=FORMULA(SC5->C5_MENPAD)
      DbSelectArea("SQL")                  
   Endif

  // If! Empty(SF4->F4_FORMULA)
  //     xSF4_SM4:=FORMULA(SF4->F4_FORMULA)
  // EndIf      
      
//FR - 11/01/08: faz críticas qto ao estado e o tipo de cliente
// a fim de imprimir ou não as bases / vlr icms
If SC5->C5_TIPOCLI = 'S'
	lICMSUBS:= .T.      // Se for SP e pessoa Jurídica,
							  //imprime base e valor do icms de substituição e não imprime a base/vlr do icms normal
Else
	lICMSUBS := .F.     // Se for SP mas a pessoa for física, não imprime o icms substituição e imprime o normal.
Endif

//Verifica os TES que existem na nf (seleção distinta)
	cSQLNF := SQL->D2_DOC
	cSQLSR := SQL->D2_SERIE
	xTES := fCallTES(cSQLNF,cSQLSR)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1)) 
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))		   		
			If !Empty(SF4->F4_FORMULA)
			   SM4->(DbSetOrder(1))
			   SM4->(DbSeek(xFilial("SM4")+SF4->F4_FORMULA))
			   Aadd(aMensTes,SM4->M4_FORMULA)				
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

   fCabSf2()
   
   //@ 015,000 pSay Chr(15)+Chr(27)+"0"     
   //@ 016,000 pSay Chr(15)
   //@ 017,000 pSay Chr(27)+"0"                   
   
   //--> Imprime Observação Especial para Produto Especifico
   If SQL->RECOLHE='S' 
      cTexto_143:=""              
      SM4->(DbSetOrder(1))
	  SM4->(DbSeek(xFilial("SM4")+"143"))	       
      cTexto_143:=SM4->M4_FORMULA    
      If !Empty(cTexto_143)
         @015,013 Psay Substr(cTexto_143,1,87)
         @016,012 Psay Substr(cTexto_143,88,87)
      EndIf
   EndIf   
   
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
   If! Empty(SQL->F2_PREFIXO+SQL->F2_DUPL)
       nLin :=017
       nCol1:=165
       nCol2:=195                                    
       nCont:=1
       Do While !SE1->(Eof()).And. SQL->F2_PREFIXO + SQL->F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM.And.nLin <= 019
          If AllTrim(SE1->E1_TIPO) $ "NF"
             IF cTipo <> "I"                   
	             If (nCont%2)#0
	                @ nLin,125 pSay SE1->E1_PREFIXO+SE1->E1_NUM
	             Endif   
	             @ nLin,nCol1 pSay Transform(SE1->E1_VALOR,"@E 9,999,999.99")
	             @ nLin,nCol2 pSay Dtoc(SE1->E1_VENCREA) 
             ENDIF
             If (nCont%2)#0 
                nCol1+=055
                nCol2+=055
             Else    
                nCol1:=165
                nCol2:=195
                nLin ++
             Endif   
             nCont ++
          ElseIf AllTrim(SE1->E1_TIPO) $ "PI-"
                 nValPis := SE1->E1_VALOR
          ElseIf AllTrim(SE1->E1_TIPO) $ "CS-"    
                 nValCsll:= SE1->E1_VALOR
          ElseIf AllTrim(SE1->E1_TIPO) $ "CF-"    
                 nValCofi:= SE1->E1_VALOR
          Endif
          SE1->(DbSkip())
       EndDo
   Endif                        
   nLin:=023
   //@ 021,000 pSay Chr(27)+"2"
   cCompara := SQL->F2_DOC + SQL->F2_SERIE
	_TotVal   := 0
   _PercDesc := 0

	if AllTrim(cTipo)$ "I"
       If SC6->C6_ICMSRET > 0 
          While !SC6->(eof()) .AND. SC6->C6_NOTA == SQL->F2_DOC .AND. SC6->C6_SERIE == SQL->F2_SERIE
             nVlrICMST += SC6->C6_ICMSRET
             SC6->(DbSkip())
           End 
          @ nLin,017 pSay "Complemento de ICMS ST"
          @ nLin,230 pSay nVlrICMST  Picture "@E@Z 999,999,999.99"   //Vlr Comp.ICms
       Else
          @ nLin,017 pSay "Complemento de ICMS"
          @ nLin,230 pSay nValIcm  Picture "@E@Z 999,999,999.99"   //Vlr Comp.ICms
       EndIf   
    else
	   While SQL->F2_DOC+SQL->F2_SERIE == cCompara           
	         SB1->(DbSetOrder(1))
	         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
			 
			 //FR
	         If lICMSUBS
		         If fCallNCM_A(SQL->D2_COD)
		         	If Empty(cMsg313_A)
		         		cMsg313_A := "OP.SUJ.REG.DE SUBS.TRIBUT.,CFE.ART.313-A DO RICMS/SP E DA PORT.CAT 126/2007"   //75
		         	Endif	         
		     	 Endif		     	
		      Endif
	         //FR	         
             
             nPICMS:=SQL->D2_PICM
	         SF4->(DbSetOrder(1))
	         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
	         SC6->(DbSetOrder(1))
	         SC6->(DbSeek(xFilial("SC6")+SQL->D2_PEDIDO+SQL->D2_ITEMPV))

	         @ nLin,012 pSay SubStr(SB1->B1_COD,1,12)
	         @ nLin,029 pSay SubStr(SC6->C6_DESCRI,1,70) 
	         @ nLin,114 pSay "PMC "+Transform(SC6->C6_P_PCM,"@E 999,999,999.99")
	         @ nLin,149 pSay SB1->B1_POSIPI
	         @ nLin,163 pSay SB1->B1_ORIGEM+SF4->F4_SITTRIB
	         @ nLin,170 pSay SB1->B1_UM
	         @ nLin,177 pSay SQL->D2_QUANT   Picture "@E 99999"
	         @ nLin,194 pSay SQL->D2_LOTECTL          //JOSÉ  
	         @ nLin,207 pSay SQL->D2_PRUNIT  Picture "@E 999,999,999.99" 
	         _TotVal += (SQL->D2_PRUNIT * SQL->D2_QUANT)
	         @ nLin,230 pSay (SQL->D2_PRUNIT * SQL->D2_QUANT)   Picture "@E 999,999,999.99"			//230
	         @ nLin,247 pSay SQL->D2_PICM    Picture "@E 99.9"//247
	         @ nLin,252 pSay SQL->D2_IPI     Picture "@E 99.9"//252
	         @ nLin,259 pSay SQL->D2_VALIPI  Picture "@E 999,999.99"             //259
	         nLin ++
	         If nLin ==047
	            @ 062,000 pSay Chr(18)
	            @ 063,150 pSay cNota
	            @ 067,000 pSay ""   
	            SetPrc(0,0)   
	            fCabSf2()          
	            nLin:=022
	            //@ nLin,000 pSay Chr(15)     
	         Endif
	                  
	         IncRegua(SQL->F2_SERIE+" "+SQL->F2_DOC)   
	         DbselectArea("SQL")
	         DbSkip()
	   EndDo         

	   nLin:= nLin + 1
       If nDescont > 0 
  	      @ nLin,165 pSay "Sub Total ..."           
	      @ nLin,189 pSay  _TotVal Picture "@E 999,999,999.99"	//Valor total sem desconto         
	      nLin:= nlin + 1
	      @ nLin,165 pSay "Desc ..." 
	      _PercDesc := ( nDescont / _TotVal ) * 100   //calcula o percentual do desconto
	      @ nLin,175 pSay _PercDesc Picture "@e 999.99"+"%" //Percentual de desconto
	      @ nLin,189 pSay nDescont Picture "@E 999,999,999.99"	
	      nLin:= nlin + 1
	      @ nLin,165 pSay "Sub Total ..." 
	      @ nLin,189 pSay (_TotVal-nDescont) Picture "@E 999,999,999.99"	//valor total com desconto
          If nVREPICM > 0 
  	         nLin++         
	         @ nLin,165 pSay "Repasse ICMS ..." +Transform(nPREPICM,"@R 999.9999 %") 
	         @ nLin,193 pSay TransForm(nVREPICM,"@R 999,999.99")
	      EndIf   
	      nLin++         
          @ nLin,189 Psay "--------------"
	      nLin++         
	      @ nLin,165 pSay "Valor Liquido... R$ "
	      @ nLin,189 pSay Transform(nVal_comp,"@E 999,999,999.99")
	      nLin++         
	   EndIf   
	   //FR
     	/*If !Empty(cMsg313_A)
   		   @nLin,12 pSay cMsg313_A
   		   nLin ++
   		   //@nLin,12 pSay "BC.ICMS Proprio:"
   	      //@nLin,29 pSay nBaseIcm Picture "@E 999,999,999.99"
   		   //@nLin,44 pSay "VLR.ICMS:"
   		   //@nLin,54 pSay nValIcm  Picture "@E 999,999,999.99" 
   	    Endif
        //FR   
        */
      If lICMSubs
         @ nLin ,012 pSay "“Substituição Tributária–Art.313-A do RICMS/00”"
         nLin++                                                             
         @ nLin ,012 pSay "“O destinatário deverá, com relação às operações com mercadorias ou prestações de serviços"
         nLin++                                                                                                                                                                                                       
         @ nLin ,012 pSay "recebidas com imposto retido, escriturar o documento fiscal nos termos do artigo 278 do RICMS.”"
      EndIf  
        

        If nVREPICM > 0
   		   nLin++
   		   nLin++
           @ nLin,049 pSay "Abaixo segue informacoes de ICMS, que e o valor total do produto (ja sem os descontos) x o percentual da regiao (neste caso "+Transform(nPICMS,"@R 999.9999 %" )
   		   nLin++
        EndIf
     endif
     
     If nLin > 38
        nLin:=44
     Else   
        nlin:=38
     EndIf
     
     If !Empty(xMENS_PED)
        @nLin,012 PSAY xMENS_PED
        nLin++         
  	 EndIf
  	       
     If !Empty(SA1->A1_ENDENT)
        nLin++         
        @nLin,000 PSAY Chr(18)+"E N D E R E C O   D E   E N T R E G A: "+ SA1->A1_ENDENT +Chr(15)
        nLin++         
  	 EndIf


   If nValPis+nValCofi+nValCsll > 0
      @ 048,028 pSay "PIS/COFINS/CSLL  "+Transform(nValPis,"@E 999,999.99")+"/"+Transform(nValCofi,"@E 999,999.99")+"/"+Transform(nValCsll,"@E 999,999.99")
   Endif   
   @ 050,000 pSay Chr(18)        
//JOSE
	IF cTipo $ "I" 
	   If !nVlrICMST > 0
   	      @ 051,030 pSay nValIcm  Picture "@E 999,999,999.99"	  
	      @ 053,094 pSay nVal_comp Picture "@E 999,999,999.99"
	   Else
	      @ 051,070 pSay nIcmsRet  Picture "@E 999,999,999.99"	  
	      @ 053,094 pSay nIcmsRet Picture "@E 999,999,999.99"  
	   EndIf   
   ELSE
   	//FR
     //	IF !lICMSUBS            //SE for .F. ele imprime o icms normal
	   	@ 051,010 pSay nBaseIcm Picture "@E 999,999,999.99"
	   	@ 051,030 pSay nValIcm  Picture "@E 999,999,999.99"	 
	  	
	  	IF lICMSUBS
	   	    @ 51,050  PSAY nBasIcmsRet		 Picture "@E 999,999,999.99"  // Base ICMS Ret.
	    	@ 51,070  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
		ENDIF
		//FR - Novo tratamento para ICMS de substituição.
		
	   @ 051,094 pSay nValMerc Picture "@E 999,999,999.99"
	   @ 053,010 pSay nFrete   Picture "@E 999,999,999.99"
	   @ 053,030 pSay nSeguro  Picture "@E 999,999,999.99"
	   @ 053,050 pSay nDespesa Picture "@E 999,999,999.99"
	   @ 053,070 pSay nValIpi  Picture "@E 999,999,999.99"
	   @ 053,094 pSay nValBrut Picture "@E 999,999,999.99"
	ENDIF   
   @ 056,007 pSay SA4->A4_NOME
   If! Empty(SC5->C5_TPFRETE)
       @ 056,069 PSay If(AllTrim(SC5->C5_TPFRETE)$ "F","1","2")
   Endif    
   @ 056,090 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
   
   @ 058,007 pSay SA4->A4_END
   @ 058,050 pSay SA4->A4_MUN
   @ 058,083 pSay SA4->A4_EST
   @ 058,091 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
   
   @ 060,007 pSay SC5->C5_VOLUME1
   @ 060,022 pSay SC5->C5_ESPECI1
//JOSE
//	if AllTrim(cTipo)$ "I"
//		@ 060,085 pSay nVal_comp        Picture "@E@Z 999,999.99"   
// 	ELSE
   @ 060,085 pSay nPBRUTO        Picture "@E@Z 999,999.99"
//   ENDIF
   @ 060,094 pSay nPLIQUI        Picture "@E@Z 999,999.99"

   @ 063,150 pSay cNota
   @ 066,000 pSay ""   
   @ 067,000 pSay ""   
   SetPrc(0,0)   
EndDo

Return 

//-----------------------------------------------------------

Static Function fCabSf2()

   //@ 000,000 Psay Chr(27)+Chr(80)

   //@ 001,000 pSay Chr(27)+"M"
   
   @ 001,009 pSay SC5->C5_NUM
   @ 001,037 pSay cEmissao//SC5->C5_EMISSAO
   @ 002,124 pSay "X"
   @ 002,154 pSay cNota

//JOSÉ
  // @ 003,000 pSay Chr(15)
  // @ 003,012 pSay xPed_SM4
  // @ 004,012 PSay Substr(xSF4_SM4,1,90)
  // @ 005,012 PSay Substr(xSF4_SM4,91,90)
  // @ 006,012 PSay Substr(xSF4_SM4,181,90)
     
   
   If Len(aMensTes)= 1 
      @ 003,000 pSay Chr(15)
      @ 003,012 pSay Substr(aMensTes[1],1,90)
      @ 004,012 PSay Substr(aMensTes[1],91,90)
   EndIf
   
   If Len(aMensTes)>1      //Só cabem dois no formulário   
      @ 003,000 pSay Chr(15)
      @ 003,012 pSay Substr(aMensTes[1],1,90)
      @ 004,012 PSay Substr(aMensTes[1],91,90)
      @ 005,012 PSay Substr(aMensTes[2],1,90)
      @ 006,012 PSay Substr(aMensTes[2],91,90)
   EndIf
    
   
   @ 007,000 pSay Chr(15)
   @ 007,012 PSAY "ENDERECO: AV.GUIDO CALOI, 1985 GALPAO 11 "
   
   If Len(cText) < 36 .OR. Len(cCfop) < 6
      @ 007,080 PSAY Chr(18) 
      @ 007,096 pSay Left(cText, len(cText)-1) //SF4->F4_TEXTO
      @ 007,132 pSay Left(cCfop, len(cCfop)-1) //SF4->F4_CF              
   Else
      @ 007,106 pSay Left(cText, len(cText)-1) //SF4->F4_TEXTO
      @ 007,166 pSay Left(cCfop, len(cCfop)-1) //SF4->F4_CF              
   EndIf
   
   @ 008,000 pSay Chr(15)
   @ 008,012 pSay "JD.SAO LUIS - SAO PAULO/SP CEP: 05802-140 "+Chr(18)
   @ 010,000 pSay Chr(15)
   @ 010,012 pSay "TELEFONE: 5515.8100 - R.8119 "+Chr(18)

   If! AllTrim(cTipo) $ "B/D"
       @ 010,080 pSay SA1->A1_NOME
       If Len(AllTrim(SA1->A1_CGC)) == 14 
          @ 010,144 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
          @ 010,144 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
       Else   
          @ 010,144 pSay SA1->A1_CGC
       Endif   
       @ 010,167 pSay cEmissao //Dtoc(dDataBase)
       @ 012,064 pSay SubStr(SA1->A1_END,1,35)
       @ 012,114 pSay SA1->A1_BAIRRO
       @ 012,139 pSay SA1->A1_CEP   Picture "@R 99.999-999"

       If! Empty(xPED_SM4)                 //jose 
          @ 012,007 pSay SubStr(xPED_SM4,01,45)  
  	    	 @ 013,007 pSay SubStr(xPED_SM4,46,45)  
          @ 014,007 pSay SubStr(xPED_SM4,91,45)  
       ENDIF
       
       @ 014,064 pSay SA1->A1_MUN
       @ 014,088 pSay SA1->A1_TEL   
       @ 014,125 pSay SA1->A1_EST
       If AllTrim(SA1->A1_INSCR) == "ISENTO" 
          @ 014,130 pSay "ISENTO" 
       Else      
          @ 014,130 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
       Endif    
   Else
       @ 010,080 pSay SA2->A2_NOME
       If Len(AllTrim(SA2->A2_CGC)) == 14 
          @ 010,144 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
       ElseIf Len(AllTrim(SA2->A2_CGC)) == 11   
          @ 010,144 pSay SA2->A2_CGC Picture "@R 999.999.999-99"            
       Else   
          @ 010,144 pSay SA2->A2_CGC
       Endif   
       @ 010,167 pSay cEmissao //Dtoc(dDataBase)
       @ 012,064 pSay SubStr(SA2->A2_END,1,35)
       @ 012,114 pSay SA2->A2_BAIRRO
       @ 012,139 pSay SA2->A2_CEP   Picture "@R 99.999-999"
       @ 014,064 pSay SA2->A2_MUN
       @ 014,088 pSay SA2->A2_TEL   
       @ 014,125 pSay SA2->A2_EST
       If AllTrim(SA2->A2_INSCR) == "ISENTO" 
          @ 014,130 pSay "ISENTO" 
       Else      
          @ 014,130 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"  
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
   
cQuery := "SELECT F2_BASEICM "+;
          ",F2_VALICM"+;
          ",F2_VALMERC"+;
          ",F2_FRETE"+;  
          ",F2_SEGURO"+;
          ",F2_DESPESA"+;
          ",F2_VALIPI"+;
          ",F2_VALBRUT"+;
          ",F2_DOC"+;
          ",F2_EMISSAO"+;
          ",F2_PBRUTO"+;
          ",F2_PLIQUI"+;
          ",F2_VALISS"+;
          ",F2_BASEISS"+;
          ",F2_VALCOFI"+;
          ",F2_VALCSLL"+;
          ",F2_VALPIS"+;
          ",F2_ICMSRET,F2_BRICMS,F2_EST,F2_TIPO,F2_CLIENTE,F2_LOJA,F2_TRANSP,F2_PREFIXO,F2_DUPL,F2_SERIE,F2_DESCONT,F2_VALFAT,F2_PREPICM,F2_VREPICM"
cQuery += ",D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,D2_TES,D2_PEDIDO,D2_COD,D2_ITEMPV,D2_SERIE,D2_DOC,D2_LOTECTL,D2_PRUNIT,D2_GRUPO,CASE  WHEN (SELECT COUNT(*) FROM "+RetSqlName("SD2")+" SD2 WHERE  D_E_L_E_T_<>'*' AND D2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND D2_SERIE= '"+_cSerie+"' AND D2_GRUPO='F001')> 0 THEN 'S' ELSE 'N' END AS RECOLHE "  
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)
//cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND "+Chr(10)
cQuery += "SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND "+Chr(10) 
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

//-----------------------------------------------------
Static Function fCallNCM_A(cCod)

Local cCodigo:= cCod
Local lRet:= .F.
Local cQry:= ""

If Select ("SQLNCM") > 0
	DbSelectarea("SQLNCM")
	dbCloseArea()
Endif
	
cQry := "SELECT SB1.B1_POSIPI AS B1NCM FROM "+RetSqlName("SB1")+" SB1 (NOLOCK)"
cQry += " WHERE SB1.B1_COD = '"+ cCodigo + "' AND SB1.B1_POSIPI LIKE '3003%' "
cQry += " OR SB1.B1_POSIPI LIKE '3004%'"
cQry += " AND SB1.D_E_L_E_T_ <> '*'"

TCQUERY cQry NEW ALIAS "SQLNCM"
dbSelectArea("SQLNCM")
dbGoTop()
If Select ("SQLNCM") > 0	
	lRet:= .T.
Else
	lRet:= .F.
Endif
  
SQLNCM->(DbCloseArea())

Return(lRet)          

/*-------------------------------------*/
Static Function fCallCFOP(cSQLNF,cSQLSR)  
/*-------------------------------------*/
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


/*------------------------------------*/
Static Function fCallTES(cSQLNF,cSQLSR)   
/*------------------------------------*/
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


//------------------------------------------------------------------------------

Static Function fCriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                 4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{_cPerg,"01","Nota de     	","","","mv_ch1","C",06,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"02","Nota ate     	","","","mv_ch2","C",06,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"03","Serie     		","","","mv_ch3","C",03,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{_cPerg,"04","Tipo     		","","","mv_ch4","N",01,00,00,"C","","Mv_Par04","Entrada","","","","","Saida","","","","","","","","","","","","","","","","","","","","","",""})

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

