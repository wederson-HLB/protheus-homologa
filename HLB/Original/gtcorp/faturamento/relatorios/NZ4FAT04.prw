#include "topconn.ch"
#include "rwmake.ch"


/*
Funcao      : NZ4FAT04
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Nota Fiscal Pryor BPO - POA * Servicos   
Autor       : Renato Mendonça
Data/Hora   : 15/08/2007 
Revisão	    : Matheus Massarotto
Data/Hora   : 24/07/2012    12:21
Módulo      : Faturamento
*/

*------------------------*
User Function NZ4FAT04()
*------------------------*
SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos")
DbSelectArea("SM0")
   //CriaPerg() - Comentado em 04-03-08 - Não utilizado na versão 10 - ALM/JAPA
If cEmpAnt $ "Z4/ZB/99"  //JSS - 05/12/2012 "FOI ADICIONADO A EMPRESA ZB PARA ATENDER O CASO 008551"  
   If Pergunte("NFZ403    ",.T.)  
      _cDaNota := Mv_Par01                        
      _cAtNota := Mv_Par02
      _cSerie  := Mv_Par03
      fOkProc()
   Endif   
Else
    MsgInfo("Especifico Pryor BPO - POA ","A T E N C A O")  
Endif   

Return

//------------------------------------------------------------

Static Function fOkProc()

tamanho  :='P'
limite   :=80
titulo   :="Nota Fiscal - Servicos Pryor BPO - POA"
cDesc1   :=' '
cDesc2   :=''
cDesc3   :='Impressao em formulario de 80 colunas.'
aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
nLin     := 60
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := 'NZ4FAT03'
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
   MsgInfo("Favor verificar ","A T E N C A O")
   Return
Else
   fGerSf2()
   RptStatus({|| fImpSF2()},"Nota de Serviço - Pryor BPO - POA")
Endif   

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

Ms_Flush()

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
   cTipo    := F2_TIPO
   cCfop    := ""
   
   SF4->(DbSetOrder(1))
   SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
   SA4->(DbSetOrder(1))
   SA4->(DbSeek(xFilial("SA4")+SQL->F2_TRANSP))
   SC5->(dbSetOrder(1))
   SC5->(DbSeek(xFilial("SC5")+SQL->D2_PEDIDO))

   cMens    := Formula(SC5->C5_MENNOTA)
   cMensTes := Formula(SC5->C5_MENPAD)
   cCondPg  := SE4->E4_DESCRI
   cMensagem:= Alltrim(SC5->C5_OBS)
   XPCC_COF := XPCC_CSLL := XPCC_PIS := 0
   cIrrf		:= 0      
   aTit 		:= {}
   V			:= 1
   xReter   := 0
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
      If! Empty(F2_PREFIXO+F2_DUPL)
       Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
			IF Alltrim(SE1->E1_TIPO) == 'NF'	
	          //Aadd(aTit,{ SE1->E1_PREFIXO+SE1->E1_NUM+Space(05)+Transform(SE1->E1_VALOR,"@E 9,999,999.99")+Space(05)+Dtoc(SE1->E1_VENCREA)})  
	          Aadd(aTit,{SE1->E1_NUM + SE1->E1_PARCELA+Space(05)+Transform(SE1->E1_VALOR,"@E 9,999,999.99")+Space(10)+Dtoc(SE1->E1_VENCREA)})
			    SED->(DbSetOrder(1))
			    SED->(DbSeek(xFilial("SED")+SE1->E1_NATUREZ))
				 cPercIrf := SED->ED_PERCIRF
				 IF V == 1
				 	cVenc := SE1->E1_VENCREA
				 endif	
			 ELSEIF Alltrim(SE1->E1_TIPO) == 'IR-'
				cIrrf := SE1->E1_VALOR
          ELSEIF SE1->E1_TIPO = 'PI-'
      	   XPCC_PIS += SE1->E1_VALOR
          ELSEIF  SE1->E1_TIPO = 'CF-' 
			   XPCC_COF += SE1->E1_VALOR
          ELSEIF  SE1->E1_TIPO = 'CS-' 
			   XPCC_CSLL += SE1->E1_VALOR
			 ENDIF
			   xReter  := cIrrf + XPCC_PIS + XPCC_COF + XPCC_CSLL 	
          SE1->(DbSkip())
       EndDo
   Endif    
     
   aMerc    :={}
   aServ    :={}
   cCompara := F2_DOC+F2_SERIE
   While F2_DOC+F2_SERIE == cCompara           
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
         SF4->(DbSetOrder(1))
         SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
         SC6->(dbSetOrder(2))
         SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
         If AllTrim(SF4->F4_CF) $ "5949/5933".And.SF4->F4_ISS $ "S"
            Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SC6->C6_DESCRI),SC6->C6_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL, AllTrim(SC6->C6_DESCRIC)})
         Else                                    
            Aadd(aMerc,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_POSIPI,SB1->B1_ORIGEM+SF4->F4_SITTRIB,SB1->B1_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_IPI,D2_VALIPI,SC6->C6_DESCRI})
         Endif   
         If SA1->A1_EST $ SM0->M0_ESTCOB
            If! SF4->F4_CF $ cCfop
               cCfop += SF4->F4_CF+"/"
            Endif   
         Else                  
            If! "6"+SubStr(SF4->F4_CF,2,3) $ cCfop    
               cCfop += "6"+SubStr(SF4->F4_CF,2,3)+"/"
            Endif   
         Endif

         IncRegua(F2_SERIE+" "+F2_DOC)   
         DbSkip()
   End         
   
   fCabSf2()
   
   
   //IMPRIME FATURA
   i    :=1
   nLin :=019
   nCol :=000
   While i <= Len(aTit)
      @ nLin,nCol pSay aTit[i][1]
      nCol = nCol+Len(aTit[i][1])+10
      //nLin +=1
      i +=1
   End
   
   
   nMerc :=1    
   nServ :=1 
   nLin  :=22
   While nServ <= Len(aServ)
         @ nLin,000 pSay aServ[nServ][3] Picture "@E 9999"					// Quantidade
//         @ nLin,009 pSay aServ[nServ][2]											// Unidade de Medida
         @ nLin,022 pSay aServ[nServ][1]+ " - "+ aServ[nServ][6]         // Descrição do Serviço 
         @ nLin,115 pSay aServ[nServ][4] Picture "@E 999,999,999.99"    // Valor unitário
         @ nLin,140 pSay aServ[nServ][5] Picture "@E 999,999,999.99"    // Valor total
     //    nLin +=1                       
     // If Len(aServ[nServ][6]) > 0
	 //		@ nLin,017 pSay aServ[nServ][6]                                // Descrição do Serviço         
     // EndIf                             
         nLin +=1
         If nServ == 15.And.nServ <= Len(aServ)                                                         
   			@ 044,000 pSay Chr(27)+"0"
   			@ 045,000 pSay Chr(15)
   			@ 054,000 pSay " "  
            fCabSf2()
            nLin :=22
         Endif       
      nServ +=1
   End                
   	nLin  :=nLin+4
   	@ 028,005    Psay "ATENCAO: Reter 4,65% referente PIS/COFINS/CSLL ,somando os pagamentos dentro do mes para o mesmo prestador do servico e sendo este valor superior "
	@ 029,014 Psay "a R$ 5.000,00, conforme Lei 10.925/04 (A responsabilidade pela retencao e do contratante do servico)"
      
   	nLin += 2
	IF XPCC_PIS+XPCC_COF+XPCC_CSLL > 0
	    @ 031,005 Psay "PIS/COFINS/CSLL: "+Transform(XPCC_PIS,"@E@Z 99,999.99")+"/"+Transform(XPCC_COF,"@E@Z 99,999.99")+"/"+Transform(XPCC_CSLL,"@E@Z 99,999.99")               
	    nLin += 1
	ENDIF
	IF cIrrf >0
		@ 032,005 Psay "IRRF 1,50%:"
   	    @ 032,016 Psay cIrrf Picture "@E 999,999,999.99"      // Valor do IR
  		nLin += 1
   ENDIF	

	IF xReter > 0
		@ 033,005 Psay "TOTAL A RETER:"                  
	   	@ 033,017 Psay XPCC_PIS+XPCC_COF+XPCC_CSLL+cIrrf Picture "@E 999,999,999.99"      // Total de impostos retidos   
	  	nLin += 4
	ENDIF	
  		
		@ 037,005 Psay "VALOR LIQUIDO:"              
	   	@ 037,017 Psay nValBrut - (XPCC_PIS+XPCC_COF+XPCC_CSLL+cIrrf) Picture "@E 999,999,999.99"   // Valor Liquido
		
	if  !Empty(cMensagem)
	    nLin += 1
 		@ nLin,017 pSay cMensagem
 	endif
		
 //	if  !Empty(cMens)
 //		nLin += 2
 //	   @ nLin,025 pSay SUBSTR(cMens,1,65)      	
 //		IF LEN(cMens) > 65
 //			nLin += 1
 //		   @ nLin,025 pSay SUBSTR(cMens,66,65)      	
 //		ENDIF
 //  endif 
 //  if  !Empty(cMensTes)
 //		nLin += 1
 //	   @ nLin,025 pSay SUBSTR(cMensTes,1,65)      	
 //		IF LEN(cMensTes) > 65
 //			nLin += 1
 //		   @ nLin,025 pSay SUBSTR(cMensTes,66,65)      	
 //		ENDIF
 //  endif 	
      @ 043,140 pSay nValBrut Picture "@E 999,999,999.99"    			// Valor total   
     
 
   @ 044,000 pSay Chr(27)+"0"
   @ 045,000 pSay Chr(15)
   @ 054,000 pSay " "   
   SetPrc(0,0)   

EndDo

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

Return 

//-----------------------------------------------------------

Static Function fCabSf2()
   @ 001,000 pSay Chr(27)+"2"
   @ 007,000 pSay Chr(15)
   @ 008,100 pSay Dtoc(cEMISSAO)
   @ 011,020 pSay SA1->A1_NOME
   @ 012,020 pSay SA1->A1_END
   @ 013,020 pSay SA1->A1_MUN
   @ 013,108 pSay SA1->A1_EST   
   
   If Len(AllTrim(SA1->A1_CGC)) == 14 
   	@ 014,020 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
   ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
      @ 014,020 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
 	ElseIf! Empty(SA1->A1_CGC)   
  		@ 014,020 pSay SA1->A1_CGC
   Endif   
     
   If AllTrim(SA1->A1_INSCR) == "ISENTO" 
   	@ 014,118 pSay "ISENTO" 
   ElseIf! Empty(SA1->A1_INSCR)      
   	@ 014,118 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
   Endif 
   
   @ 015,020 pSay SA1->A1_INSCRM   
   
Return

//-----------------------------------------------------------

Static Function fGerSf2()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())
   
cQuery := "SELECT * " 
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

Static Function CriaPerg()

cPerg:="NFZ403    "
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