#include "TOTVS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTCORP01  ºAutor  Tiago Luiz Mendonça  º Data ³  28/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula valor do dollar                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                      
                    

                                                                      
/*
Funcao      : GTCORP01()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Calculo do dollar para pedidos com moeda 2.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 28/11/2011
*/
*-----------------------------*
 User Function GTCORP01(cTipo)
*-----------------------------*
Local nPos1   := 0 
Local nPos2   := 0
Local nPos3   := 0
Local cTabela := ""
Local aCampos := {}   
Local cMoeda  :=""
Default cTipo := "SC6" 

If cTipo == "SC6"
	aAdd(aCampos,"C5_MOEDA")
	aAdd(aCampos,"C5_EMISSAO")
	aAdd(aCampos,"C6_P_BRL")
	aAdd(aCampos,"C6_QTDVEN")
	aAdd(aCampos,"C6_PRCVEN")                 
	aAdd(aCampos,"C6_VALOR")
	cTabela := "SC5"                                          
	cEmissao := &("M->C5_EMISSAO")
	cMoeda := &("M->C5_MOEDA")
ElseIf cTipo == "CNB"
	aAdd(aCampos,"CN9_MOEDA")
	aAdd(aCampos,"CNA_DTINI")
	aAdd(aCampos,"CNB_P_BRL")
	aAdd(aCampos,"CNB_QUANT")
	aAdd(aCampos,"CNB_VLUNIT")
	aAdd(aCampos,"CNB_VLTOT")      
	cTabela := "CN9"
	aArea := GetArea()
	cEmissao :=  DATE()
	If FunName() == "CNTA100"
	    cMoeda := &("M->CN9_MOEDA")
	Else
		cMoeda :=  Posicione(cTabela, 1, xFilial(cTabela)+CNB->CNB_CONTRA, aCampos[1]) 
	Endif
	RestArea(aArea)  
Endif                                                                                
   
nPos1  :=  aScan(aHeader, { |x| Alltrim(x[2]) == aCampos[4] }) 
nPos2  :=  aScan(aHeader, { |x| Alltrim(x[2]) == aCampos[5] })
nPos3  :=  aScan(aHeader, { |x| Alltrim(x[2]) == aCampos[6] }) 
 

If cMoeda == 1
		 
   	// Valor unitario	 
 	aCols[n][nPos2] := &("M->"+aCampos[3])
	
	//Valor total
	aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
	   
Else                                                                            
    	
   	If Inclui
   		// Valor unitario	 
   		//aCols[n][nPos2] :=  xMoeda(&("M->"+aCampos[3]), 1, (cTabela)->&(aCampos[1]), &("M->"+aCampos[2]))
   		aCols[n][nPos2] :=  xMoeda(&("M->"+aCampos[3]), 1, cMoeda, cEmissao)
   	Else
   		// Valor unitario
   		aCols[n][nPos2] :=  xMoeda(&("M->"+aCampos[3]), 1, cMoeda, cEmissao) 
   	EndIf
		                                                        
	//Valor total
   	aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]      
	    
EndIf

Return .T.