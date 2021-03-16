#include "topconn.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³4YFAT01   ºAutor  ³Joao Silva          º  Data ³  09/01/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nota Fiscal em formulario continuo para empresa Godigital.  º±±
±±º          ³												              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*------------------------*
User Function 4YFAT01()                 
*------------------------*

//Declaração das variaveis
Private cDaNota := " " 
Private cAtNota := " "
Private cSerie  := " "

//Verifica se empresa e Godigital ou Teste
DbSelectArea("SM0")

If cEmpAnt $ "4Y"   

   If Pergunte("NF4Y01    ",.T.)  

      cDaNota := Mv_Par01                        
      cAtNota := Mv_Par02
      cSerie  := Mv_Par03

      fOkProc()  

   EndIf   
Else
    MsgInfo("Especifico Empresa Godigital","A T E N C A O")  
Endif   

Return

/*
Funcao      : fOkProc
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao em formulario
Autor       : Joao Silva
Data/Hora   : 09/01/2013
*/

Static Function fOkProc()

tamanho  :='P'
limite   :=80
titulo   :="Nota Fiscal Godigital"
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
wnRel    := NomeProg := '4YFAT01'
cTipo    := ""

wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)

If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
	Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .or. nLastKey == 27
	Return
Endif

fGerSf2()
RptStatus({|| fImpSF2()},"Nota Fiscal Godigital")

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

Ms_Flush()

Return

/*
Funcao      : fImpSF2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Imprimir emissao nfs.
Autor       : Joao Silva
Data/Hora   : 09/01/2013
*/

Static Function fImpSF2()

Local lIn := .T.

DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()

	nBaseIcm := SQL->F2_BASEICM
	nValIcm  := SQL->F2_VALICM
	nValMerc := SQL->F2_VALMERC
 	nFrete   := SQL->F2_FRETE  
  	nSeguro  := SQL->F2_SEGURO
  	nDespesa := SQL->F2_DESPESA
  	nValIpi  := SQL->F2_VALIPI
  	nValBrut := SQL->F2_VALBRUT
  	cNota    := SQL->F2_DOC
  	cEmissao := SQL->F2_EMISSAO
  	nPbruto  := SQL->F2_PBRUTO
  	nPliqui  := SQL->F2_PLIQUI
  	nValIss  := SQL->F2_VALISS
  	nBaseIss := SQL->F2_BASEISS
  	nValCofi := SQL->F2_VALCOFI
  	nValCsll := SQL->F2_VALCSLL
  	nValPis  := SQL->F2_VALPIS
  	cTipo    := SQL->F2_TIPO
  	
   

  	SF2->(DbSetOrder(1))
  	SF2->(DbSeek(xFilial("SF2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
  	SA1->(DbSetOrder(1))
  	SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
  	SA4->(DbSetOrder(1))
  	SA4->(DbSeek(xFilial("SA4")+SQL->F2_TRANSP))
  	SE1->(DbSetOrder(1))
  	SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial("SED")+SE1->E1_NATUREZ))
	
			      	
 	XPCC_COF	:= 0
  	XPCC_CSLL 	:= 0
  	XPCC_PIS 	:= 0
  	nIrrf		:= 0      
  	nIss        := 0
  	V			:= 1
  	xReter   	:= 0

  	nPiss       := 0   	
  	nPcsll      := 0  	
  	nPpis       := 0   	
  	nPirrf      := 0
  	nPcofins    := 0

  	aVencto 	:= {}//SE1->E1_VENCTO 
  	
  	SE1->(DbSetOrder(2))
 	SE1->(DbSeek(xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_SERIE+SQL->F2_DOC))
 	cComparap:= xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_SERIE+SQL->F2_DOC
  	
  	While xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == cComparap //JSS - Adicionado o tratamento para apresentar todas de pagamento dos titulos parcelados
  		
  		AADD (aVencto, SE1->E1_VENCTO)
  	
   		SE1->(DbSkip())
 
 	EndDo   		    
  		   	     
    aMerc    :={}
    aServ    :={}
    cCompara := SQL->F2_DOC+SQL->F2_SERIE

	SD2->(DbSetOrder(3))
 	SD2->(DbSeek(xFilial("SD2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
 	cCompara:= xFilial("SD2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA
   	
	While xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cCompara           
   		 
 		SB1->(DbSetOrder(1))
     	SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
      	SC5->(dbSetOrder(1))
       	SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
        SC6->(dbSetOrder(2))
        SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
         
        Aadd(aServ,{AllTrim(SB1->B1_COD)+" - "+AllTrim(SC6->C6_DESCRI),SC6->C6_UM,SD2->D2_QUANT,SD2->D2_PRCVEN,SD2->D2_TOTAL, AllTrim(SC6->C6_DESCRI)})
       
 		SB1->(dbSetOrder(1))
  		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))

	
 		If !Empty(SD2->D2_VALPIS)
 			XPCC_PIS += SD2->D2_VALPIS
   			nPpis    := SB1->B1_PPIS
   		EndIf  

  		If !Empty(SD2->D2_VALCOF)        
    		XPCC_COF += SD2->D2_VALCOF
			nPcofins := SB1->B1_PCOFINS
    	EndIf   
    	
    	If !Empty(SD2->D2_VALCSL)        
    		XPCC_CSLL += SD2->D2_VALCSL
			nPcsll := SD2->D2_ALQCSL
    	EndIf
    		
    	If !Empty(SF2->F2_VALIRRF)
			If nIrrf == 0 
				nIrrf := SF2->F2_VALIRRF
			EndIf
			If Empty(SED->ED_PERCIRF)
				nPirrf := GETMV("MV_ALIQIRF")
			Else
				nPirrf := SED->ED_PERCIRF 
			EndIf	
		EndIf    
		  						
  		If !Empty(SD2->D2_VALISS)
			nIss += SD2->D2_VALISS
			nPiss := SD2->D2_ALIQISS	
		EndIf   
		
		If lIn       
		
	  		cMens    	:= SC5->C5_MENNOTA
 			cMensTes 	:= Formula(SC5->C5_MENPAD)
  			cCondPg  	:= SE4->E4_DESCRI
  			cMensagem	:= Alltrim(cMens)+" "+Alltrim(cMensTes)+" "
  			
	  		//RRP - 11/02/2015 - Ajuste para lei da transparência. Chamado 024329. 
	  		If (SF2->(FieldPos("F2_TOTIMP")) > 0)
				If SF2->F2_TOTIMP > 0
					cMensagem += " Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
				EndIf
			EndIf
	 		
 			lIn :=.F.
 		
 		EndIf
 		
   		SD2->(DbSkip())

 
 	EndDo  
   
   	xReter  := nIrrf + XPCC_PIS + XPCC_COF + XPCC_CSLL 	       
   
   	fCabSf2()
             
              
   	If !Empty(SC5->(C5_P_TIT)) 
   		If Len(SC5->(C5_P_TIT )) > 75
			@ 17,000 pSay Alltrim(Substr(SC5->(C5_P_TIT),1,75))         // Descrição do titulo	    
			@ 18,000 pSay  Alltrim(Substr(SC5->(C5_P_TIT),76,75))       // Descrição do titulo	   
   		Else
        	@ 17,000 pSay Alltrim(SC5->(C5_P_TIT))         // Descrição do titulo	
     	EndIf
 	EndIf 
     
   	nLin  :=19          
    
 	For i=1 to Len(aServ)
                        
		If Len(aServ[i][6] ) > 75	 			
        	@ nLin,000 pSay Substr(aServ[i][6],1,75)          // Descrição do Serviço     
        	nLin++
        	@ nLin,000 pSay Substr(aServ[i][6],76,150)          // Descrição do Serviço  
  		Else 
        	@ nLin,000 pSay  aServ[i][6]          // Descrição do Serviço  
  		
  		EndIf
           
        @ nLin,088 pSay aServ[i][5] Picture "@E 999,999,999.99"       // Valor total
                                            
        nLin +=1
       
       	If nLin > 35 .And. i <= Len(aServ)                                                         
   			

   			SetPrc(0,0)  
            fCabSf2()
            nLin :=17   
            
            
      	Endif

	Next 
	
	If (nLin+5) > 35                                                        
   			
   			SetPrc(0,0)  
            fCabSf2()
            nLin :=17   
                     
 	Endif     

  	SE1->(DbSetOrder(2))
 	SE1->(DbSeek(xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_SERIE+SQL->F2_DOC))
 	cComparap:= xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_SERIE+SQL->F2_DOC
  	nLin = nLin+5 
  	I:= 1
  	
  	While xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == cComparap 
  		IF AllTrim(SE1->E1_TIPO) == "NF"  //JSS - Adicionado o tratamento para apresentar todas de pagamento dos titulos parcelados
  			@ nLin,000 Psay "DATA DE VENCIMENTO: "+ Dtoc(SE1->E1_VENCTO)           // Data Vencimento       JSS - Adicionado por solicitacao do cliente em chamado :009428    
 			i++
 			nLin++
 		EndIf
 	SE1->(DbSkip())
 
 	EndDo 	
 	       
	//nLin = nLin+5 
	//@ nLin,000 Psay "DATA DE VENCIMENTO: "+ Dtoc(aVencto[1])           // Data Vencimento       JSS - Adicionado por solicitacao do cliente em chamado :009428    
	//nLin++
	@ nLin,000 Psay "DADOS PARA DEPOSITO: SANTANDER (033) / AGENCIA: 3002 / C/C: 13000257-7"// Dados para deposito      JSS - Adicionado por solicitacao do cliente em chamado :009428    

	IF XPCC_PIS+XPCC_COF+XPCC_CSLL+nIrrf + nIss > 0
	 
	                 
	    //Aliquotas
	    //@ 037,000 Psay Transform(nPiss,"@E@Z 999.99")      //ISS   JSS - Retirado por solicitacao do cliente em chamado :009428  
	    @ 037,017 Psay Transform(nPcsll,"@E@Z 999.99")     //CSLL           
	    @ 037,036 Psay Transform(nPpis,"@E@Z 999.99")      //PIS           
	    @ 037,054 Psay Transform(nPirrf,"@E@Z 999.99")     //IRRF
	    @ 037,077 Psay Transform(nPcofins,"@E@Z 999.99")   //COFINS 

	    
	    //Valores
	    //@ 039,000 Psay Transform(nIss,"@E@Z 999,999.99")        //ISS    JSS - Retirado por solicitacao do cliente em chamado :009428     
	    @ 039,013 Psay Transform(XPCC_CSLL,"@E@Z 9,999,999.99")   //CSLL           
	    @ 039,032 Psay Transform(XPCC_PIS,"@E@Z 9,999,999.99")    //PIS           
	    @ 039,052 Psay Transform(nIrrf,"@E@Z 9,999,999.99")       //IRRF
	    @ 039,070 Psay Transform(XPCC_COF,"@E@Z 9,999,999.99")    //COFINS    	   
	
   ENDIF	
	@ 039,087 Psay nValBrut Picture "@E 999,999,999.99"   // Valor Bruto - RRP - 16/08/2013 - Adicionado por solicitacao do cliente em chamado :014086
	@ 041,087 Psay nValBrut - (XPCC_PIS+XPCC_COF+XPCC_CSLL+nIrrf) Picture "@E 999,999,999.99"   // Valor Liquido

		
	If !Empty(cMensagem)
		If len(cMensagem) > 85 
	 		@ 44,000 pSay SubStr(Alltrim(cMensagem),1,95) 
	 		@ 45,000 pSay SubStr(Alltrim(cMensagem),96,95)
	 		@ 46,000 pSay SubStr(Alltrim(cMensagem),191,95)
	 	Else	
	 		@ 44,000 pSay cMensagem  
 		EndIf                              
 	EndIf

   SetPrc(0,0)  
   
   SQL->(DbSkip()) 

EndDo

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

Return 

/*
Funcao      : fCabSf2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Imprime cabeçalho da NF
Autor       : Joao Silva
Data/Hora   : 09/01/2013
*/

Static Function fCabSf2() 

   @ 001,000 pSay Chr(27)
   @ 005,000 pSay Chr(15)
   @ 005,095 pSay Dtoc(cEMISSAO)
   @ 009,012 pSay SA1->A1_NOME
   @ 011,012 pSay AllTrim(SA1->A1_END) +" - "+AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST)                        
 
   
   If Len(AllTrim(SA1->A1_CGC)) == 14 
   	@ 013,012 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
  		ElseIf Len(AllTrim(SA1->A1_CGC)) == 11   
      		@ 013,012 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
   				ElseIf! Empty(SA1->A1_CGC)   
  	  				@ 013,012 pSay SA1->A1_CGC
   Endif   
     
   If AllTrim(SA1->A1_INSCR) == "ISENTO" 
   	@ 013,87 pSay "ISENTO" 
    	ElseIf! Empty(SA1->A1_INSCR)      
   			@ 013,87 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"  
   Endif 
   
Return   

/*
Funcao      : fGerSf2()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca dados digitados no parametro ( SX1 )
Autor       : Joao Silva
Data/Hora   : 09/01/2013
*/

Static Function fGerSf2()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2 := SF2->(dbStruct())                                          
aStruSD2 := SD2->(dbStruct())
   
cQuery := "SELECT * " 
cQuery += "FROM "+RetSqlName("SF2")+" SF2 where "
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' 
cQuery += "AND D_E_L_E_T_<>'*' AND SF2.F2_DOC BETWEEN '"+cDaNota+"' AND '"+cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+cSerie+"'
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE "

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
 
/*
Funcao      : CriaPerg()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria as perguntas no x1 caso nao exista.
Autor       : Joao Silva
Data/Hora   : 09/01/2013
*/

Static Function CriaPerg()

cPerg:="NF4Y01    "
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                        4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Da  Nota     		","","","mv_ch1","C",06,00,00,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Ate Nota     		","","","mv_ch2","C",06,00,00,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Serie       		   ","","","mv_ch3","C",03,00,00,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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