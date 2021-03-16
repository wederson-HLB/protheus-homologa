#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE01NFESEFAZ ºAutor ³Eduardo C. Romaniniº  Data ³  11/11/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada do fonte NfeSefaz, responsavel pela        º±±
±±º          ³transmissão de Notas Fiscais Eletronicas.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------*
User Function PE01NFESEFAZ()
*--------------------------*
//Declaração das variaveis
Local lMens1 := .F.
Local lMens2 := .F.
Local lMens3 := .F.
Local lExp	 := .F.

Local cCodEmp    := AllTrim(SM0->M0_CODIGO)
Local cNota      := ""
Local cSerie     := ""
Local cEntSai    := ""
Local cPedido    := ""
Local cPedCli    := ""
Local cMsgAux    := ""
Local cEspecie   := "" 
Local cMVNFEMSF4 := AllTrim(GetNewPar("MV_NFEMSF4","")) 
Local cSeek		 := ""
Local cEndEntreg := ""
Local cCodSufr	 := "" 

Local nI         := 0
Local nAux       := 0
Local nIni       := 0
Local nFim       := 0
Local nBaseStIt  := 0
Local nValorSTIt := 0
Local nDescon    := 0
Local nTotVal    := 0
Local nDescItem  := 0
Local nDescRep   := 0
Local nPDescon   := 0
Local nNumItem   := 0

Local aRet	    := {}
Local aProd	    := ParamIXB[01]
Local cMensCli  := ParamIXB[02]
Local cMensFis  := ParamIXB[03]
Local aDest	    := ParamIXB[04]
Local aNota     := ParamIXB[05]
Local aInfoItem := ParamIXB[06]
Local aDupl	    := ParamIXB[07]
Local aTransp   := ParamIXB[08]
Local aEntrega  := ParamIXB[09]
Local aRetirada := ParamIXB[10]
Local aVeiculo  := ParamIXB[11]
Local aReboque	:= ParamIXB[12]
Local aNfVincRur:= ParamIXB[13] 
Local aEspVol   := ParamIXB[14]
Local aNfVinc   := ParamIXB[15]
Local aDetPag   := ParamIXB[16]
Local aObsCont	:= ParamIXB[17]

Local aPedCom   := ParamIXB[18]
Local aExp      := ParamIXB[19]
Local aTotal    := ParamIXB[20]


Local aDados    := {}
Local aArea     := {}
Local aArea2    := {}
Local aArea3    := {}
Local aArea4	:= {}
Local Quebra	:= ""

//RSB - 04/05/2017 - Montagem e calculo da mensagem da Informações Complementares.
Local nVol_Total := 0 
Local nCalc_Total := 0
//Variavies de valores  
Local nResto := 0
Local nUnit := 0 
Local nMult := 0
Local nMast := 0 
//Variaveis para quantidade de caixas
Local nUnit_Qtd := 0 
Local nMult_Qtd := 0
Local nMast_Qtd := 0 
//Variaveis de calculo
Local nUnit_Calc := 0 
Local nMult_Calc := 0
Local nMast_Calc := 0	  
//Variaveis de calculo
Local nPesoLiq 	 := 0
Local nPesoBruto := 0 
Local lEspecie   := .T.
//=============================================================
Local aProdAgrupa
Local nPosCod
Local aStProd 

/*
	* Leandro Brito - Inclusao array de impostos, sempre serEo ultimo elemento do ParamIxb ( nfesefaz ), caso o padrão venha a ter novos elementos em uma futura versão
*/
Local aCst			:= ParamIxb[ 21 ] 
Local aIcms			:= ParamIxb[ 22 ] 
Local aIpi			:= ParamIxb[ 23 ] 
Local aICMSST		:= ParamIxb[ 24 ] 
Local aPIS			:= ParamIxb[ 25 ] 
Local aCOFINS		:= ParamIxb[ 26 ] 
Local aCOFINSST		:= ParamIxb[ 27 ] 
Local aISSQN		:= ParamIxb[ 28 ] 
Local aAdi			:= ParamIxb[ 29 ] 
Local aICMUFDest	:= ParamIxb[ 30 ] 
Local aIPIDevol		:= ParamIxb[ 31 ] 
Local aPisAlqZ		:= ParamIxb[ 32 ] 
Local aCofAlqZ		:= ParamIxb[ 33 ] 
Local aCsosn		:= ParamIxb[ 34 ] 


//Tratamentos customizados
cNota   := aNota[2]
cSerie  := aNota[1]

If AllTrim(aNota[4]) == "1"
	cEntSai := "S" //Saúa
Else
	cEntSai := "E" //Entrada
EndIf

//<--RRP-24/09/2012-Tratamento CSTs de Substituição Tributária-->//
//RRP - 12/02/2014 - Ducati retirada chamado 014955 / Rokonet retirada chamado 017054
If !(cEmpAnt) $ 'PF/FB'
	For nI:=1 To Len(aProd)
		If AllTrim(aProd[nI][23]) $ "10/60/70"
			If !Empty(cMensCli)
				cMensCli += " "				
			EndIf
			

			If aDest[9]== "SP" //Estado do Cliente
				
				//TLM 03/06/2014 - Chamado 018786 
				//cMensCli += "Substituicao Tributaria Art.313-A ao 313-Z20 do RICMS/00 - O destinatario devera, com relacao as operacoes com mercadorias ou prestacoes de servicos recebidas com imposto retido, escriturar o documento fiscal nos termos do artigo 278 do RICMS."
				cMensCli += "O destinatario devera, com relacao as operacoes com mercadorias ou prestacoes de servicos recebidas com imposto retido, escriturar o documento fiscal nos termos do artigo 278 do RICMS."

			EndIf
			/* TLM 03/06/2014 - Chamado 018786 
			Else
				cMensCli += "Substituicao Tributaria Art.313-A ao 313-Z20 do RICMS/00."
			EndIf
            */
			
		EndIf	 
		Exit  //break     
	Next
EndIf
//<--Fim do tratamento CSTs de Substituição Tributária-->//

//Tratamento para todas as empresas
If cEntSai == "E" //Nf de Entrada

	aArea := SD1->(GetArea())        

	For nI:=1 To Len(aProd)
		
		//RRP - 19/08/2013 - Verificando a nota se EDevolução ou Beneficiamento
		If !(SF1->F1_TIPO) $ "DB"
			cSeek := xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]
		Else
			//MSM - 27/05/2015 - O cliente estava disposicionando quando ele tem mais de uma loja, ficando sempre na primeira loja. 
								//Por isso, foi substituido de SA1->A1_COD+SA1->A1_LOJA para SF1->F1_FORNECE+SF1->F1_LOJA
			cSeek := xFilial("SD1")+cNota+cSerie+SF1->F1_FORNECE+SF1->F1_LOJA+aProd[nI][2]+aInfoItem[nI][4]
		EndIf
		
		//Mensagem complementar
		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(cSeek))

			If SD1->(FieldPos("D1_OBS")) > 0 .And. !Empty(SD1->D1_OBS)
				If !(AllTrim(SD1->D1_OBS) $ AllTrim(cMensCli))
					If !Empty(cMensCli)
						cMensCli += " "
					EndIf
					cMensCli += AllTrim(SD1->D1_OBS)
				EndIf
			EndIf			
		EndIf
	Next
		
	RestArea(aArea)
	
EndIf

//Nf de Saida - RRP - 29/01/2014 - Customização para todos os clientes
If cEntSai == "S"
	//Retirada as empresas abaixo, pois jEpossuem a Tag xPed em suas customizações.
	If !(cEmpAnt) $ "EF/U6/3R/ED/I7"

		//Informações do Produto
		aArea := SC6->(GetArea())
		
		aPedCom := {}
		
		For nI:=1 To Len(aProd)
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
			
				//Tag xPed					
				If !Empty(SC6->C6_PEDCLI)
					If SC6->(FieldPos("C6_P_ITCLI")) > 0
						aAdd(aPedCom,{SC6->C6_PEDCLI,SC6->C6_P_ITCLI})
					Else
						aAdd(aPedCom,{SC6->C6_PEDCLI,""})
					EndIf
				Else
					aadd(aPedCom,{})
				EndIf
			Else
				aadd(aPedCom,{})	
			EndIf
		Next
	EndIf
EndIf		

//Promega
If cCodEmp == "IS" 

	If cEntSai == "S" //Nf de Saida
		
		//Informações do Cliente
        aDest[5] := MyGetEnd(SA1->A1_END,"SA1")[4] //Complemento de endereço.
		
		//Mensagem do cliente
		If !Empty(SA1->A1_COMPLEM)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			cMensCli += "Compl. Endereço: " + SA1->A1_COMPLEM //Complemento do endereço.
		EndIf
		 
		For nI:=1 To Len(aInfoItem)
			If !Empty(aInfoItem[nI][1])
				If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
					If !Empty(cPedido)
		            	cPedido += " / "
					EndIf			
					cPedido += AllTrim(aInfoItem[nI][1])
				EndIf
			EndIf
			
			If !Empty(aProd[nI][19])
				aProd[nI][25] := aProd[nI][19] //Controle de Lote
			EndIf
			
		Next
		
		If !Empty(cPedido)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "Pedido(s):" + Alltrim(cPedido) //Pedidos de Venda
		EndIf
	
	Else //Nf de Entrada
		
		For nI:=1 To Len(aInfoItem)

			If !Empty(aProd[nI][19])
				aProd[nI][25] := aProd[nI][19] //Controle de Lote
			EndIf
			
		Next							
	EndIf
//Angelmed RRP 03/10/2012 - Tratamento para carregar o lote no XML igual a empresa Sirona
ElseIf cCodEmp == "HM"
	If cEntSai == "S" //Nf de Saida
        //Informações de produtos
		aArea  := SD2->(GetArea())		
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] := "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
			EndIf			
		Next

		RestArea(aArea)
		
	Else //Nf de Entrada
        //Informações de produtos		
		aArea := SD1->(GetArea())
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		
		RestArea(aArea)

	EndIf 	

//Sumitomo
ElseIf cCodEmp == "FF" 

	//Mensagem do cliente
	If cEntSai == "S" //Saida

		//Informações do Cliente
		If AllTrim(SA1->A1_TIPO) == "L"
			aDest[14] :=  AllTrim(SA1->A1_INSCRUR)//Inscrição Estadual
		EndIf
    
		aArea  := SC5->(GetArea())
        aArea2 := SD2->(GetArea())
		aArea3 := SFT->(GetArea())	
		
		For nI:=1 To Len(aInfoItem)
			If !Empty(aInfoItem[nI][1])
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+aInfoItem[nI][1]))
	
	        		If !Empty(SC5->C5_P_ENDEN) .and. !Alltrim(SC5->C5_P_ENDEN) $ cMsgAux
						If !Empty(cMsgAux)
							cMsgAux += " / "
						EndIf
	
						cMsgAux += Alltrim(SC5->C5_P_ENDEN)
					EndIf
					
					
					//Complemento da mensagem da nota no pedido de venda
					If !Empty(AllTrim(SC5->C5_P_MSGNF))
						If  !(AllTrim(SC5->C5_P_MSGNF) $ cMensCli)
						
							nIni := At(AllTrim(SC5->C5_MENNOTA),cMensCli)    //Posição inicial da msg padrão
					        nAux := (nIni+ Len(AllTrim(SC5->C5_MENNOTA)))-1  //Tamanho da msg padrão
							nFim := Len(Alltrim(cMensCli))                   //Tamanho total da msg do cliente
							nFim := nFim - nAux   	                         //Tamanho do texto após o C5_MENNOTA
							
							cMensCli := Left(cMensCli,nAux) + Alltrim(SC5->C5_P_MSGNF) + " " + Right(cMensCli,nFim)
						
						EndIf					
					EndIf
					
				EndIf
			EndIf
		
		    //Tratamento de lote.
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
			 		aProd[nI][25] := AllTrim(SD2->D2_LOTECTL) //Informações complementares do produto.
				EndIf
			EndIf		
            
			//RRP - 27/05/2013 - Tratamento para descrição complementar do produto.
			SB5->(dbSetOrder(1))
			SFT->(DbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2])) .and. !Empty(SB5->B5_CEME)

				aProd[nI][25] += "#"
				aProd[nI][25] += " " + AllTrim(SB5->B5_CEME)
				
				If SFT->(DbSeek(xFilial("SFT")+"S"+cSerie+cNota+SA1->A1_COD+SA1->A1_LOJA+AvKey(aInfoItem[nI][4],"FT_ITEM")+aProd[nI][2]))
					If SFT->FT_VALPIS > 0 .or. SFT->FT_VALCOF > 0
						aProd[nI][25] += " PIS: R$ " + AllTrim(Transform(SFT->FT_VALPIS,"@E 999,999.99")) +;
				   			             " COFINS: R$ " + AllTrim(Transform(SFT->FT_VALCOF,"@E 999,999.99"))
					EndIf 
				EndIf
			ElseIf SFT->(DbSeek(xFilial("SFT")+"S"+cSerie+cNota+SA1->A1_COD+SA1->A1_LOJA+AvKey(aInfoItem[nI][4],"FT_ITEM")+aProd[nI][2]))
				If SFT->FT_VALPIS > 0 .or. SFT->FT_VALCOF > 0
					aProd[nI][25] += "#"

					aProd[nI][25] += " PIS: R$ " + AllTrim(Transform(SFT->FT_VALPIS,"@E 999,999.99")) +;
				    	             " COFINS: R$ " + AllTrim(Transform(SFT->FT_VALCOF,"@E 999,999.99"))
				EndIf	
				
			EndIf
 
		Next

		RestArea(aArea)
		RestArea(aArea2)
		RestArea(aArea3)
	
		If !Empty(cMsgAux)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
	
			cMensCli += "Local de Entrega: " + Alltrim(cMsgAux) //Local de Entrega
		EndIf
	
	Else //Nf de Entrada

		aArea  := SD1->(GetArea())        
		aArea2 := SFT->(GetArea())        
			
		For nI:=1 To Len(aProd)
	
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD1->D1_P_OBS2)
					If !(AllTrim(SD1->D1_P_OBS2) $ AllTrim(cMensCli))
						If !Empty(cMensCli)
							cMensCli += " "
						EndIf
						cMensCli += AllTrim(SD1->D1_P_OBS2)
					EndIf
				EndIf			
						
				If !Empty(SD1->D1_LOTECTL)
					aProd[nI][25] := AllTrim(SD1->D1_LOTECTL)
				EndIf
			EndIf   
			
			//RRP - 27/05/2013 - Tratamento para descrição complementar do produto.
			SB5->(dbSetOrder(1))
			SFT->(DbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2])) .and. !Empty(SB5->B5_CEME)

				aProd[nI][25] += "#"
				aProd[nI][25] += " " + AllTrim(SB5->B5_CEME)
				//RRP - 17/06/2013 - Ajuste no posicionamento do CliFor+Loja
				If SFT->(DbSeek(xFilial("SFT")+"E"+cSerie+cNota+SFT->FT_CLIEFOR+SFT->FT_LOJA+AvKey(aInfoItem[nI][4],"FT_ITEM")+aProd[nI][2]))
					If SFT->FT_VALPIS > 0 .or. SFT->FT_VALCOF > 0
						aProd[nI][25] += " PIS: R$ " + AllTrim(Transform(SFT->FT_VALPIS,"@E 999,999.99")) +;
				   			             " COFINS: R$ " + AllTrim(Transform(SFT->FT_VALCOF,"@E 999,999.99"))
					EndIf 
				EndIf
			//RRP - 17/06/2013 - Ajuste no posicionamento do CliFor+Loja
			ElseIf SFT->(DbSeek(xFilial("SFT")+"E"+cSerie+cNota+SFT->FT_CLIEFOR+SFT->FT_LOJA+AvKey(aInfoItem[nI][4],"FT_ITEM")+aProd[nI][2]))
				If SFT->FT_VALPIS > 0 .or. SFT->FT_VALCOF > 0
					aProd[nI][25] += "#"

					aProd[nI][25] += " PIS: R$ " + AllTrim(Transform(SFT->FT_VALPIS,"@E 999,999.99")) +;
				    	             " COFINS: R$ " + AllTrim(Transform(SFT->FT_VALCOF,"@E 999,999.99"))
				EndIf	
				
			EndIf
			
		Next
			
		RestArea(aArea)
		RestArea(aArea2)	
	EndIf	

//Salton
ElseIf cCodEmp == "EQ" 

	If cEntSai == "S" 

		//Mensagem do cliente
		If !Empty(SA1->A1_ENDENT)

			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "Local de Entrega: "+Alltrim(SA1->A1_ENDENT) + " / " //Local de Entrega
		
			If !Empty(SA1->A1_BAIRROE)
				cMensCli += " - "+Alltrim(SA1->A1_BAIRROE)  
			EndIf
			If !Empty(SA1->A1_MUNE)
				cMensCli += " - "+Alltrim(SA1->A1_MUNE)  
			EndIf               
			If !Empty(SA1->A1_ESTE)
				cMensCli += " / "+Alltrim(SA1->A1_ESTE)   
			EndIf
			If !Empty(SA1->A1_CEPE)
				cMensCli += "  "+Alltrim(SA1->A1_CEPE)   
			EndIf	
		EndIf

        //Pedido de Venda
		aArea:= SC5->(GetArea())

		For nI:=1 To Len(aInfoItem)
			If !Empty(aInfoItem[nI][1])
				SC5->(DbSetOrder(1))
				If DbSeek(xFilial("SC5")+aInfoItem[nI][1])
					If !(AllTrim(SC5->C5_P_PED) $ cPedido)
						If !Empty(cPedido)
		            		cPedido += " / "
						EndIf			
			
						cPedido += AllTrim(SC5->C5_P_PED)
					EndIf
				EndIf
			EndIf
		Next

        RestArea(aArea)

		If !Empty(cPedido)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "Pedido:" + Alltrim(cPedido) //Pedidos de Venda
		EndIf

	EndIf

//Omnia
ElseIf cCodEmp == "OB" 

	If cEntSai == "S" //Nf de Saida

		If !Empty(SA1->A1_ENDREC)
			
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
			cMensCli += "Local de Entrega: "+Alltrim(SA1->A1_ENDREC) //Local de Entrega
		EndIf   
		        
		//Informações complementares do produto			
		aArea:= SB5->(GetArea())

		For nI:=1 To Len(aProd)
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
		Next
		
		RestArea(aArea)

	EndIf


//Vestas
ElseIf cCodEmp == "VE"

	If cEntSai == "S" //Nf de Saida

		//Informações complementares do produto			
		aArea:= SB5->(GetArea())

		For nI:=1 To Len(aProd)
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					aProd[nI][4] := AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
		Next
		
		RestArea(aArea)
	
	EndIf

//FSI
ElseIf cCodEmp == "EF"
    
	If cEntSai == "S" //Nf de Saida	
	
		//RRP - 30/07/2015 - Ajuste para notas de Devolução ou Beneficiamento.
		cEndEntreg	:= ""
		cCodSufr	:= "" 
	
		If !SF2->F2_TIPO $ "DB"
			cEndEntreg	:= SA1->A1_ENDENT
			cCodSufr	:= SA1->A1_SUFRAMA
		Else
			cEndEntreg	:= SA2->A2_END
		EndIf
		
		If !Empty(cEndEntreg)
			
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
			cMensCli += "Local de Entrega: "+Alltrim(cEndEntreg) //Local de Entrega
		EndIf   	
		
		If !Empty(cCodSufr)
			
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
			cMensCli += "Codigo Suframa: "+Alltrim(cCodSufr) //Cod. Suframa
		EndIf   	
		
		//Descrição do produto			
		aArea:= SB1->(GetArea())
        
		aPedCom := {}

		For nI:=1 To Len(aProd)

			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))

				//Tag xPed					
				If !Empty(SC6->C6_PEDCLI)
					If SC6->(FieldPos("C6_P_ITCLI")) > 0
						aAdd(aPedCom,{SC6->C6_PEDCLI,SC6->C6_P_ITCLI})
					Else
						aAdd(aPedCom,{SC6->C6_PEDCLI,""})
					EndIf
				Else
					aadd(aPedCom,{})
				EndIf
			EndIf	

			SB1->(dbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aProd[nI][2]))
				aProd[nI][4] := AllTrim(SB1->B1_DESREC)
			EndIf		
		Next
		
		RestArea(aArea)
        
		//Pedidos
		aArea:= SC5->(GetArea())

		For nI:=1 To Len(aInfoItem)
			If !Empty(aInfoItem[nI][1])
				
				If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
					If !Empty(cPedido)
		            	cPedido += " / "
					EndIf			
					cPedido += AllTrim(aInfoItem[nI][1])	
				EndIf    
			
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+aInfoItem[nI][1]))
					
					If !Empty(SC5->C5_P_PEDCL)
						If !(Alltrim(SC5->C5_P_PEDCL) $ cPedCli) 	
							If !Empty(cPedCli)
			        	    	cPedCli += " / "
							EndIf			
							cPedCli += AllTrim(SC5->C5_P_PEDCL)	
						EndIf
					EndIf					
				
			   	EndIf
			EndIf
        Next
		RestArea(aArea)		
		
		If !Empty(cPedido)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "N/Pedido:" + Alltrim(cPedido) //Pedidos de Venda
		EndIf
		
		If !Empty(cPedCli)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "S/Pedido:" + Alltrim(cPedCli) //Pedidos do Cliente
		EndIf 
	
	ElseIf cEntSai == "E" //Nf de Entrada
        //MSM - 22/06/2015 - Adicionado para tratar a descrição do produto, solicitado pela michelles@fsifilters.com.br 
        //					 em e-mail enviado ao protheus no dia 25/05/2015
		//Descrição do produto			
		aArea:= SB1->(GetArea())
        
		For nI:=1 To Len(aProd)

			SB1->(dbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aProd[nI][2]))
				aProd[nI][4] := AllTrim(SB1->B1_DESREC)
			EndIf
					
		Next
		
		RestArea(aArea)	
	
	EndIf

//MindLab
ElseIf cCodEmp == "MN"

	If cEntSai == "S" //Nf de Saida	

   		If !Empty(SA1->A1_ENDENT)
			
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
			cMensCli += "Local de Entrega: "+Alltrim(SA1->A1_ENDENT) //Local de Entrega
		EndIf   		
        
        //Pedido de Venda
		For nI:=1 To Len(aInfoItem)
			If !Empty(aInfoItem[nI][1])
				If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
					If !Empty(cPedido)
	    	        	cPedido += " / "
					EndIf			
					cPedido += AllTrim(aInfoItem[nI][1])
				EndIf
			EndIf
		Next

		If !Empty(cPedido)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "Pedido(s):" + Alltrim(cPedido) //Pedidos de Venda
		EndIf

	EndIf

//Okuma
ElseIf cCodEmp == "ED"

	If cEntSai == "S" //Nf de Saida	

		//Mensagem para o Cliente		
	   	If !Empty(SA1->A1_P_MENNF)

			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
			cMensCli += Alltrim(SA1->A1_P_MENNF)
		EndIf  	
        
		//Código do produto			
		aArea:= SB1->(GetArea())

		For nI:=1 To Len(aProd)
			//RRP - 24/03/2015 - Ajustando NFe 3.1 valida a TAG aExp.
			If SubStr(Alltrim(aProd[nI][7]),1,1) == "7"
				lExp:=.T.			
			EndIf
			SB1->(dbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aProd[nI][2]))
				If !Empty(SB1->B1_P_COD)
					aProd[nI][2] := AllTrim(SB1->B1_P_COD)
				EndIf	
			EndIf		
		Next
		
		RestArea(aArea)

		//Informação complementar do produto
		aArea:= SC6->(GetArea())
        
		If lExp
			aExp := {}
		EndIf
        aPedCom := {}

		For nI:=1 To Len(aInfoItem)
			//RRP - 24/03/2015 - Ajustando NFe 3.1 valida a TAG aExp.
			If lExp
				aadd(aExp,{})
				aDados := {}
			EndIf		
			
			If !Empty(aInfoItem[nI][1])
				//RRP - 24/03/2015 - Ajustando NFe 3.1 valida a TAG aExp.
				If lExp
					If SM0->M0_CODFIL = "01"
						aAdd(aDados,{"ZA02","ufEmbarq"  , "SP" ,"",""})
				    	aAdd(aDados,{"ZA03","xLocEmbarq", "SAO PAULO" ,"",""})
				    	aAdd(aDados,{"","","", "" ,"" })    //I51
				    	aAdd(aDados,{"","", "", "" ,"" })   //I53
				    	aAdd(aDados,{"","", "", "" ,"" })   //I54
				    	aAdd(aDados,{"","", "", "" ,"" })   //I55
				    	aAdd(aDados,{"","", "", "" ,"" })   //ZA04
					Else
				    	aAdd(aDados,{"ZA02","ufEmbarq"  , "AM" ,"","",""})
				    	aAdd(aDados,{"ZA03","xLocEmbarq", "MANAUS" ,"","",""})
				    	aAdd(aDados,{"","","", "" ,"" })	//I51
				    	aAdd(aDados,{"","", "", "" ,"" })	//I53
				    	aAdd(aDados,{"","", "", "" ,"" })	//I54
				    	aAdd(aDados,{"","", "", "" ,"" })	//I55
				    	aAdd(aDados,{"","", "", "" ,"" })	//ZA04
					EndIf
				    	
		    		aAdd(aExp[Len(aExp)],aDados)
		   		EndIf

				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))

					//Tag xPed					
					If !Empty(SC6->C6_PEDCLI)
						//aAdd(aPedCom,{SC6->C6_PEDCLI,Alltrim(Str(Len(aPedCom)+1))})
						aAdd(aPedCom,{SC6->C6_PEDCLI,SC6->C6_ITEMCLI})
					Else
						aadd(aPedCom,{})
					EndIf
					
					//Pedido do Cliente.		
					If !Empty(SC6->C6_PEDCLI) .and. !Empty(SC6->C6_P_COD)
						
						If !Empty(aProd[nI][25])
							aProd[nI][25] += " "
						EndIf
						
						aProd[nI][25] := PadR(SC6->C6_P_COD,15)+PadR(SC6->C6_PEDCLI,6)+StrZero(Val(SC6->C6_ITEM),3)
					EndIf
					
				EndIf							
			EndIf		
		Next

		RestArea(aArea)

	Else //Nf de Entrada
	
		aArea  := SB1->(GetArea())

		For nI:=1 To Len(aProd)
			
			//Código do produto			
			SB1->(dbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aProd[nI][2]))
				If !Empty(SB1->B1_P_COD)
					aProd[nI][2] := AllTrim(SB1->B1_P_COD)
				EndIf	
			EndIf		
		Next
		
		RestArea(aArea)
			
   	EndIf		

//Shiseido
ElseIf cCodEmp == "R7"

	If cEntSai == "S" //Nf de Saida	

		//Tratamento de Desconto
		aArea  := SC5->(GetArea())
		aArea2 := SB1->(GetArea())

		For nI:=1 To Len(aInfoItem)
			If !Empty(aInfoItem[nI][1])

				If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
					If !Empty(cPedido)
	    	        	cPedido += " / "
					EndIf			
					cPedido += AllTrim(aInfoItem[nI][1])
				EndIf

				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+aInfoItem[nI][1])) .And. SC5->( FieldPos( 'C5_DESCTAB' ) ) > 0
				
					SB1->(DbSetOrder(1))
					If SB1->(DbSeek(xFilial("SB1")+aProd[nI][2]))
						If SC5->C5_DESCTAB > 0  .And. SB1->B1_TIPO <> "PP"
							
							If !("Desconto de " $ cMensCli )
								If !Empty(cMensCli)
									cMensCli += " "
								EndIf
								
								cMensCli += "Desconto de "+ Alltrim(Str(SC5->C5_DESCTAB))+"%"
								
							EndIf
							
						EndIf			
					EndIf

				EndIf
			EndIf
		Next

        //Pedido de Venda
		If !Empty(cPedido)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "Pedido(s):" + Alltrim(cPedido) //Pedidos de Venda
		EndIf
        
		RestArea(aArea)
		RestArea(aArea2)
        
		//Tratamento de ICMS ST
        aArea  := SD2->(GetArea())

		lAgrupaIt := AllTrim( GetNewPar( "MV_P_AGRP" , "S" ) ) == "S"  //** Leandro Brito - 12/02/2018 - Agrupamento do itens mesmo codigo na NFS
		
		//posiciona no SA1, pois estEdisposicionado. 
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		
		/*  
			* Leandro Brito 
			* Alglutinação de Itens mesmo código
		*/
		If lAgrupaIt
			aAuxProd := {}
			aAuxCst := {}  	                         
			aAuxIcms := {}  	 
			aAuxIpi := {}  	
			aAuxICMSST := {}  		
			aAuxPIS := {}  	
			aAuxCOF := {}  	
			aAuxCOFST := {}  	
			aAuxISSQN := {}  		
			aAuxICMUFDest := {}  	
			aAuxIPIDevol := {}  	
			aAuxPisAlqZ := {}  	
			aAuxCofAlqZ := {}  	
			aAuxCsosn := {}  	
			
						
			For nI := 1 To Len( aProd ) 
				If ( nPosCod := Ascan( aAuxProd , { | x | AllTrim( x[ 2 ] ) == AllTrim( aProd[ nI ][ 2 ] ) } ) ) = 0
					Aadd( aAuxProd , aClone( aProd[ nI ] ) )
					Aadd( aAuxCst , aClone( aCst[ nI ] ) ) 
					Aadd( aAuxIcms , aClone( aIcms[ nI ] ) )
					Aadd( aAuxIpi , aClone( aIpi[ nI ] ) )
					Aadd( aAuxICMSST , aClone( aICMSST[ nI ] ) )
					Aadd( aAuxPIS , aClone( aPIS[ nI ] ) )
					Aadd( aAuxCOF , aClone( aCOFINS[ nI ] ) )
					Aadd( aAuxCOFST , aClone( aCOFINSST[ nI ] ) )
					Aadd( aAuxISSQN , aClone( aISSQN[ nI ] ) )
					Aadd( aAuxICMUFDest , aClone( aICMUFDest[ nI ] ) )
					Aadd( aAuxIPIDevol , aClone( aIPIDevol[ nI ] )  )
					Aadd( aAuxPisAlqZ , aClone( aPisAlqZ[ nI ] )  )
					Aadd( aAuxCofAlqZ , aClone( aCofAlqZ[ nI ] )  )																																																		
					Aadd( aAuxCsosn , aClone( aCsosn[ nI ] )  )																																																							
				Else
					aAuxProd[ nPosCod ][ 9 ] += aProd[ nI ][ 9 ] // Quantidade Comercial
					aAuxProd[ nPosCod ][ 12 ] += aProd[ nI ][ 12 ] // Quantidade Tributavel					
					aAuxProd[ nPosCod ][ 10 ] += aProd[ nI ][ 10 ]  // Desconto
					aAuxProd[ nPosCod ][ 13 ] += aProd[ nI ][ 13 ]  // Frete
					aAuxProd[ nPosCod ][ 14 ] += aProd[ nI ][ 14 ]  // Seguro
					aAuxProd[ nPosCod ][ 15 ] += aProd[ nI ][ 15 ]
					aAuxProd[ nPosCod ][ 21 ] += aProd[ nI ][ 21 ]
					aAuxProd[ nPosCod ][ 26 ] += aProd[ nI ][ 26 ]
					aAuxProd[ nPosCod ][ 30 ] += aProd[ nI ][ 30 ]
					aAuxProd[ nPosCod ][ 31 ] += aProd[ nI ][ 31 ]
					aAuxProd[ nPosCod ][ 32 ] += aProd[ nI ][ 32 ]
					aAuxProd[ nPosCod ][ 35 ] += aProd[ nI ][ 35 ]
					aAuxProd[ nPosCod ][ 36 ] += aProd[ nI ][ 36 ]
					aAuxProd[ nPosCod ][ 37 ] += aProd[ nI ][ 37 ]
					aAuxProd[ nPosCod ][ 43 ] += aProd[ nI ][ 43 ]
					
					If Len( aAuxIcms[ nPosCod ] ) > 0  .And. Len( aIcms[ nI ] ) > 0
						aAuxIcms[ nPosCod ][ 5 ] += aIcms[ nI ][ 5 ]  // Base Calculo
						aAuxIcms[ nPosCod ][ 7 ] += aIcms[ nI ][ 7 ]  // Valor Tributavel
						aAuxIcms[ nPosCod ][ 9 ] += aIcms[ nI ][ 9 ]  // Qtde 
						aAuxIcms[ nPosCod ][ 12 ] += aIcms[ nI ][ 12 ]  // Icms Diferido
                    EndIf
                    
					If Len( aAuxIpi[ nPosCod ] ) > 0 .And. Len( aIpi[ nI ] ) > 0
						aAuxIpi[ nPosCod ][ 6 ] += aIpi[ nI ][ 6 ]  // Base Calculo 
						aAuxIpi[ nPosCod ][ 7 ] += aIpi[ nI ][ 7 ]  // Quantidade
						aAuxIpi[ nPosCod ][ 10 ] += aIpi[ nI ][ 10 ]  // Valor Tributavel 
					EndIf																				
					
					If Len( aAuxICMSST[ nPosCod ] ) > 0  .And. Len( aICMSST[ nI ] ) > 0
						aAuxICMSST[ nPosCod ][ 5 ] += aICMSST[ nI ][ 5 ]  // Base Calculo
						aAuxICMSST[ nPosCod ][ 7 ] += aICMSST[ nI ][ 7 ]  // Valor Tributavel
						aAuxICMSST[ nPosCod ][ 9 ] += aICMSST[ nI ][ 9 ]  // Quantidade Tributavel
					EndIf
					
					If Len( aAuxPIS[ nPosCod ] ) > 0 .And. Len( aPIS[ nI ] ) > 0
						aAuxPIS[ nPosCod ][ 2 ] += aPIS[ nI ][ 2 ]  // Base Calculo
						aAuxPIS[ nPosCod ][ 4 ] += aPIS[ nI ][ 4 ]  // Valor Tributavel
						aAuxPIS[ nPosCod ][ 5 ] += aPIS[ nI ][ 5 ]  // Quantidade  
					EndIf
					
					If Len( aAuxCOF[ nPosCod ] ) > 0 .And. Len( aCOFINS[ nI ] ) > 0
						aAuxCOF[ nPosCod ][ 2 ] += aCOFINS[ nI ][ 2 ]  // Base Calculo
						aAuxCOF[ nPosCod ][ 4 ] += aCOFINS[ nI ][ 4 ]  // Valor Tributavel
						aAuxCOF[ nPosCod ][ 5 ] += aCOFINS[ nI ][ 5 ]  // Quantidade  
					EndIf 
					
					If Len( aAuxCOFST[ nPosCod ] ) > 0 .And. Len( aCOFINSST[ nI ] ) > 0
						aAuxCOFST[ nPosCod ][ 2 ] += aCOFINSST[ nI ][ 2 ]  // Base Calculo
						aAuxCOFST[ nPosCod ][ 4 ] += aCOFINSST[ nI ][ 4 ]  // Valor Tributavel
						aAuxCOFST[ nPosCod ][ 5 ] += aCOFINSST[ nI ][ 5 ]  // Quantidade 
					EndIf
					
					If Len( aAuxISSQN[ nPosCod ] ) > 0 .And. Len( aISSQN[ nI ] ) > 0
						aAuxISSQN[ nPosCod ][ 3 ] += aISSQN[ nI ][ 3 ]  // Valor Tributavel
						aAuxISSQN[ nPosCod ][ 7 ] += aISSQN[ nI ][ 7 ]  // Valor Deducao
						aAuxISSQN[ nPosCod ][ 9 ] += aISSQN[ nI ][ 9 ]  // Valor Retido 
					EndIf
					
					If Len( aAuxICMUFDest[ nPosCod ] ) > 0  .And. Len( aICMUFDest[ nI ] ) > 0
						aAuxICMUFDest[ nPosCod ][ 1 ] += aICMUFDest[ nI ][ 1 ]  // Base Calculo
						aAuxICMUFDest[ nPosCod ][ 6 ] += aICMUFDest[ nI ][ 6 ]  // Valor Cred. UF Dest
						aAuxICMUFDest[ nPosCod ][ 7 ] += aICMUFDest[ nI ][ 7 ]  // Valor Icms UF Dest 
						aAuxICMUFDest[ nPosCod ][ 8 ] += aICMUFDest[ nI ][ 8 ]  // Valor Icms UF Remet
					EndIf
				
					If Len( aAuxIPIDevol[ nPosCod ] ) > 0 .And. Len( aIPIDevol[ nI ] ) > 0
						aAuxIPIDevol[ nPosCod ][ 2 ] += aIPIDevol[ nI ][ 2 ]  // Valor IPI Devolucao
				    EndIf
				EndIf
			Next     
			
			aProd 		:= AClone( aAuxProd  )
			aCst 		:= AClone( aAuxCst ) 
			aIcms 		:= AClone( aAuxIcms ) 
			aIpi 		:= AClone( aAuxIpi ) 
			aICMSST 	:= AClone( aAuxICMSST )
			aPIS 		:= AClone( aAuxPIS )
			aCOFINS 	:= AClone( aAuxCOF )
			aCOFINSST 	:= AClone( aAuxCOFST )
			aISSQN 		:= AClone( aAuxISSQN )
			aISSQN 		:= AClone( aAuxICMUFDest )
			aIPIDevol 	:= AClone( aAuxIPIDevol )
			aPisAlqZ 	:= AClone( aAuxPisAlqZ )
			aCofAlqZ 	:= AClone( aAuxCofAlqZ )
			aCsosn 		:= AClone( aAuxCsosn )
			
			For nI:=1 To Len(aProd)
				SD2->(DbSetOrder(3))
				SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]))
				nBaseStProd := 0
				nIcmStProd := 0
				While SD2->( !Eof() .And. D2_FILIAL +D2_DOC +D2_SERIE  + D2_CLIENTE + D2_LOJA + D2_COD == xFilial( 'SD2' )+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2] )
					
					If Alltrim(SD2->D2_CF) $ '5405'.and. SD2->D2_LOCAL <> '06'  .And. SD2->( FieldPos( 'D2_P_IVABS' ) ) > 0
						nBaseStIt += SD2->D2_P_IVABS
						nValorSTIt+= SD2->D2_P_IVAVL
						
						nBaseStProd += SD2->D2_P_IVABS
						nIcmStProd += SD2->D2_P_IVAVL
					EndIf                    
					nAux += SD2->D2_QUANT
					
	            	SD2->( DbSkip() )
				EndDo                
				
				//Mensagem complementar do produto
				If ( nBaseStProd > 0 )
                	aProd[nI][25] := "Base ST: "+Alltrim(Transform(nBaseStProd,"@ze 999,999,999.99"))+ " Icms ST: "+Alltrim(Transform(nIcmStProd,"@ze 999,999,999.99"))
			 	EndIf
				
			Next		
		Else

			For nI:=1 To Len(aProd)
				SD2->(DbSetOrder(3))
				If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
					
					//Mensagem complementar do produto
					If !Empty(SD2->D2_P_IVAVL) .AND.Alltrim(SD2->D2_CF) $ '5405'.AND.SD2->D2_LOCAL <> '06'
	                	aProd[nI][25] := "Base ST: "+Alltrim(Transform(SD2->D2_P_IVABS,"@ze 999,999,999.99"))+ " Icms ST: "+Alltrim(Transform(SD2->D2_P_IVAVL,"@ze 999,999,999.99"))
				 	EndIf
		
					aProd[nI][25] :=  cvaltochar(aProd[nI][16]) +" / "+aProd[nI][25] //Preço Unit.
	
					If Alltrim(SD2->D2_CF) $ '5405'.and. SD2->D2_LOCAL <> '06'
						nBaseStIt += SD2->D2_P_IVABS
						nValorSTIt+= SD2->D2_P_IVAVL
					EndIf                    
					nAux += SD2->D2_QUANT
	
				EndIf
			Next
        
        EndIf
        
		If !Empty(cMensCli)
			cMensCli += " "
		EndIf
		cMensCli += "Quantidade: " + Alltrim(Str(nAux))

		If nBaseStIt > 0 .And. nValorSTIt > 0
			cMensCli += " Base ST : " + Alltrim(Transform((nBaseStIt),"@ze 999,999,999.99")) + ".......ICMS ST : " + Alltrim(Transform((nValorSTIt),"@ze 999,999,999.99"))
		EndIf
           
		//CAS - 17/09/2019 Tratamento para rejeição 927, reordenando os itens para retirar as lacunas, devido ao agrupamento em função dos lotes 
		For nI := 1 To Len( aProd )
			aProd[ nI ][1] := nI
		Next

		RestArea(aArea)

	EndIf

//Donaldson
ElseIf cCodEmp == "I7"

	If cEntSai == "S" //Nf de Saida	

		//Mensagem ustomizada   	
		SZZ->(DbSetOrder(1))
		If SZZ->(DbSeek(xFilial("SZZ") + "S" + cNota + cSerie + SF2->F2_CLIENTE + SF2->F2_LOJA))
			While SZZ->(! Eof()) .and. SZZ->ZZ_FILIAL  == xFilial("SZZ") .and. SZZ->ZZ_TIPODOC == "S"	.and. SZZ->ZZ_DOC  == SF2->F2_DOC ;
	    	    	          	 .and. SZZ->ZZ_SERIE == SF2->F2_SERIE .and. SZZ->ZZ_CLIFOR  == SF2->F2_CLIENTE .and. SZZ->ZZ_LOJA  == SF2->F2_LOJA .And. cMsgAux <> SZZ->ZZ_CODMENS 
                          
				If !Empty(cMensCli)
					cMensCli += " "
				EndIf

				cMensCli += Alltrim(SZZ->ZZ_TXTMENS)
				cMsgAux:=SZZ->ZZ_CODMENS 
					
				SZZ->(DbSkip())
			EndDo
		EndIf

		//Complemento do produto         
        aArea := SC6->(GetArea())
       
		For nI:=1 To Len(aInfoItem)	
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
			
				If !Empty(SC6->C6_PEDCLI)
		           aProd[nI][25] := AllTrim(SC6->C6_PEDCLI)
        		EndIf	
				
			EndIf
		Next
		
		RestArea(aArea)		
        

	Else //Nf Entrada
   	
   	    //Especie e Volume
		If (FieldPos("F1_ZZTRANS"))>0
			cEspecie := Upper(FieldGet(FieldPos("F1_ZZESPEC")))
			If !Empty(cEspecie)
				nAux := aScan(aEspVol,{|x| x[1] == cEspecie})
				If ( nAux==0 )
					aadd(aEspVol,{ cEspecie, FieldGet(FieldPos("F1_ZZVOLUM")) , SF1->F1_PESOL , SF1->F1_ZZPBRUT})
				Else
					aEspVol[nAux][2] += FieldGet(FieldPos("F1_ZZVOLUM"))
				EndIf		    
			EndIf
		EndIf
		
		//Transportadora
		aArea := SA4->(GetArea())
		aArea2 := SD1->(GetArea())

		If FieldPos("F1_ZZTRANS") > 0 .And. !Empty(SF1->F1_ZZTRANS)
			dbSelectArea("SA4")
			dbSetOrder(1)
			MsSeek(xFilial("SA4")+SF1->F1_ZZTRANS)
			aadd(aTransp,AllTrim(SA4->A4_CGC))
			aadd(aTransp,SA4->A4_NOME)
			aadd(aTransp,SA4->A4_INSEST)
			aadd(aTransp,SA4->A4_END)
			aadd(aTransp,SA4->A4_MUN)
			aadd(aTransp,Upper(SA4->A4_EST)	) 
			aadd(aTransp,SA4->A4_EMAIL	) // TLM 
		EndIf 
		
		//Verifica o item para adicionar a transportadora		
		If Empty(aTransp)
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA))
				If !Empty(SD1->D1_P_TRANS)
					dbSelectArea("SA4")
					dbSetOrder(1)
					MsSeek(xFilial("SA4")+SD1->D1_P_TRANS)
					aadd(aTransp,AllTrim(SA4->A4_CGC))
					aadd(aTransp,SA4->A4_NOME)
					aadd(aTransp,SA4->A4_INSEST)
					aadd(aTransp,SA4->A4_END)
					aadd(aTransp,SA4->A4_MUN)
					aadd(aTransp,Upper(SA4->A4_EST)	)
				EndIf
			EndIf		
		EndIf
			
		RestArea(aArea)
		RestArea(aArea2)

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aInfoItem)
			//Total
			If aInfoItem[nI][3] == "04N" 					
				aTotal[2] := 0
			EndIf
		Next
		
		RestArea(aArea)
						
	EndIf

//Veraz
ElseIf cCodEmp == "XC"

	If cEntSai == "S" //Nf de Saida
		
		//Informações do Produto
		aArea := SC6->(GetArea())
	
		For nI:=1 To Len(aProd)
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
							 		
				If !Empty(SC6->C6_P_COD)
					aProd[nI][2] := AllTrim(SC6->C6_P_COD) //Codigo
				EndIf
				
				If !Empty(SC6->C6_P_DESC)
					aProd[nI][4] := AllTrim(SC6->C6_P_DESC) //Descrição
				EndIf
						
			EndIf
		Next
		
		RestArea(aArea)	

	EndIf
 
//ACCEDIAN
ElseIf cCodEmp == "EI"

	If cEntSai == "S" //Nf de Saida
		
		//Informações do Produto
		aArea := SC6->(GetArea())
	
		For nI:=1 To Len(aProd)
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
							 		
				If !Empty(SC6->C6_P_COD)
					aProd[nI][2] 	:= AllTrim(SC6->C6_P_COD) //Codigo
					nNumItem 		:= nNumItem+10
					aProd[nI][4] 	:= SUBSTR("ITEM - "+STRZERO(nNumItem,5)+" "+AllTrim(SC6->C6_DESCRI),1,120) //Descrição
					aProd[nI][25] 	:= AllTrim(SC6->C6_PRODUTO) //Descrição complementar
				EndIf
						
			EndIf
			
		Next
				
		RestArea(aArea)

	EndIf
	
    //AOA - 19/09/2016 - Inclusao de lote na NF, chamado 036218 
	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
		
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
                	aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf

//AOA - 19/09/2016 - Inclusao de lote na NF, chamado 036220
ElseIf cEmpAnt == "OU"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
		
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
                	aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf
				
//Intralox
ElseIf cCodEmp == "U6"

	If cEntSai == "S" //Nf de Saida

		//Informações do Produto
		aArea := SC6->(GetArea())
		
		aPedCom := {}
		
		For nI:=1 To Len(aProd)
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
			
				//RRP - 12/11/2012 - Tag xPed - Chamado 008081					
				If !Empty(SC6->C6_PEDCLI)
					If SC6->(FieldPos("C6_P_ITCLI")) > 0
						aAdd(aPedCom,{SC6->C6_PEDCLI,SC6->C6_P_ITCLI})
					Else
						aAdd(aPedCom,{SC6->C6_PEDCLI,""})
					EndIf
				Else
					aadd(aPedCom,{})
				EndIf
				//RRP - 12/11/2012 - Final do tratamento para a Tag xPed
				
				If !Empty(SC6->C6_DESCR01)
					aProd[nI][4]  := Substr(SC6->C6_DESCR01,1,120) //Descrição
					aProd[nI][25] := Substr(SC6->C6_DESCR01,120,Len(SC6->C6_DESCR01)) //Complemento
				EndIf
			   
				If !Empty(SC6->C6_PEDCLI)
					If !(Alltrim(SC6->C6_PEDCLI) $ cPedCli) 	
						If !Empty(cPedCli)
							cPedCli += " / "
						EndIf			
						cPedCli += AllTrim(SC6->C6_PEDCLI)	
					EndIf
				EndIf					
						
				If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
					If !Empty(cPedido)
	    	        	cPedido += " / "
					EndIf			
					cPedido += AllTrim(aInfoItem[nI][1])
				EndIf
									
			EndIf
		Next

		If !Empty(cMensCli)
			cMensCli += " "
		EndIf
		cMensCli += "O comprador declara concordar que o presente pedido de compra esta sujeito as - CONDIÇÕES GERAIS DE VENDA DA INTRALOX BRASIL LTDA - devidamente registrada sob o no.6953440, no 3o. Cart.Reg.Titulos e Doc.,a Rua XV de Novembro,80-São Paulo/SP."
		
		If !Empty(cPedCli)
			cMensCli += " Pedido: " + Alltrim(cPedCli) //Pedidos do Cliente
		EndIf
		
		If !Empty(cPedido)
			cMensCli += " Nosso Pedido: " + Alltrim(cPedido) //Pedidos de Venda
		EndIf
		
		RestArea(aArea)	
	
	EndIf	

//Sirona
ElseIf cCodEmp == "SI"
	
	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea  := SF4->(GetArea())	
		aArea2 := SC6->(GetArea())
		aArea3 := SD2->(GetArea())		

		For nI:=1 To Len(aProd)
			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] := "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
							
			EndIf			
			
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4")+aInfoItem[nI][3]))			
				If Alltrim(SF4->F4_ESTOQUE) == "N"
			 		
				 	SC6->(DbSetOrder(1))
					If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))	
						
						If !Empty(Alltrim(SC6->C6_P_LOTE)) .And. !Empty(Alltrim(DtoC(SC6->C6_P_DATA)))
				
							If !Empty(SC6->C6_P_LOTE)
								aProd[nI][19] := SC6->C6_P_LOTE
								aProd[nI][25] :="Lote: " + Alltrim(SC6->C6_P_LOTE)+" Validade: "+Alltrim(DtoC(SC6->C6_P_DATA))
							EndIf	
							
						EndIf
			
					EndIf
			 		
				EndIf
			EndIf
		Next

		RestArea(aArea)
		RestArea(aArea2)
		RestArea(aArea3)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aProd)

			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		
		RestArea(aArea)

	EndIf		

//Freescale
ElseIf cCodEmp == "II"

	If cEntSai == "S" //Nf de Saida

		//Informações complementares do produto			
		aArea:= SB5->(GetArea())

		For nI:=1 To Len(aProd)
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
		Next
		
		RestArea(aArea)
    EndIf

//Chemtool
ElseIf cCodEmp == "G6"
	If cEntSai == "S" //Nf de Saida
		//Informações complementares do produto			
		aArea:= SB5->(GetArea())
		For nI:=1 To Len(aProd)
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		

			If !Empty(aInfoItem[nI][1])
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += "Pedido: " + AllTrim(aInfoItem[nI][1])
			EndIf			

			//Mensagem complementar
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] += " Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
			EndIf
		Next
		RestArea(aArea)
		
		//Imprime o cliente de entrega        
		If SF2->(F2_CLIENTE+F2_LOJA) <> SF2->(F2_CLIENT+F2_LOJENT)
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT))	
				aArea:= SA1->(GetArea())
				cMensCli += "End. Entrega: " + Alltrim(SA1->A1_ENT)+ " - " +AllTrim(SA1->A1_MUN) + " - " +  AllTrim(SA1->A1_EST)
				RestArea(aArea)
			EndIf
		EndIf
	
	Else //Nf de Entrada
        //Informações de produtos		
		aArea := SD1->(GetArea())
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		RestArea(aArea)
    EndIf

//Perstorp
ElseIf cCodEmp == "A6"
	
	If cEntSai == "S" //Nf de Saida	

		//Informações complementares
		aArea  := SB5->(GetArea())
        aArea2 := SD2->(GetArea())
        
		lMens1 := .F.

		For nI:=1 To Len(aProd)

			If !Empty(aProd[nI][19])
				aProd[nI][25] := aProd[nI][19] + " # " //Controle de Lote
			EndIf

			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					aProd[nI][25] += AllTrim(SB5->B5_CEME) //Inf. complementar do produto
				EndIf	
			EndIf		
			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
		      	If Alltrim(SD2->D2_CF) $ '5106/6106'
					lMens1 := .T. 	
		      	EndIf
			EndIf	
		Next
		
		//Mensagem complementar da nota		
		If lMens1
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
	   		cMensCli += "Mercadorias serão retiradas no armazem geral Natam Express Transportes Ltda Rua Angelo Franchini , 165 - galpão 05 - Parque Jaçatuba  - CEP 09290-416- Santo Andre - SP - CNPJ : 01.782.115/0001-48 "
		EndIf
		
		RestArea(aArea)
		RestArea(aArea2)
		
	EndIf

//NeoGen
ElseIf cCodEmp == "LN"

	If cEntSai == "S" //Nf de Saida

		aArea  := SB5->(GetArea())
		aArea2 := SD2->(GetArea())
        
		lMens1 := .F.
		lMens2 := .F.
		lMens3 := .F.

		For nI:=1 To Len(aProd)

			//RSB - Controle de Lote / Data de validade
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(aProd[nI][19])
					aProd[nI][25] += aProd[nI][19] +"|"+ Right(DTOS(SD2->D2_DTVALID),2)+"/"+substr(DTOS(SD2->D2_DTVALID),5,2)+"/"+left(DTOS(SD2->D2_DTVALID),4) 
				EndIf	
			EndIf

			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				
				If !Empty(SB5->B5_CEME)
					aProd[nI][25] +=  " # " + AllTrim(SB5->B5_CEME) //Inf. complementar do produto
				EndIf	
	            
				If AllTrim(SB5->B5_CERT) == "S"
					lMens1 := .T.				
				EndIf
			EndIf		

			If AllTrim(aProd[nI][2]) $ "D12568757-BZL|D12709702-BZL|D12709609-BZL|D12709568-BZL|D12709557-BZL|D12670638-BZL|D12669952-|D12670592-" //Cod. Produto
				lMens2 := .T.                
			EndIf
                
			If AllTrim(aProd[nI][5]) $ "38089429|34029019" //NCM
				lMens3 := .T.
			EndIf                
		Next
		
		//Mensagem Complementar da Nota
		If lMens1
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
 			cMensCli +="DECLARAMOS QUE OS PRODUTOS, ESTAO EMBALADOS ADEQUADAMENTE PARA SUPORTAR OS RISCOS NORMAIS "
 			cMensCli +="DE CARREGAMENTO, DESCARREGAMENTO,TRANSBORDO E TRANSPORTE E ATENDE A REGULAMENTACAO EM VIGOR."
		EndIf
		
		If lMens2
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
	
			cMensCli +=" NF EMITIDA CONFORME DECRETO 96044/88, ART.22."
		EndIf

		If lMens3
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli +="Mercadoria para uso exclusivo na agricultura."    
		EndIf
		
		RestArea(aArea2)
		RestArea(aArea)

	Else //Nf de Entrada

   		aArea  := SB5->(GetArea())
		aArea2 := SD1->(GetArea())
		
		For nI:=1 To Len(aProd)

			//RSB - Controle de Lote / Data de Validade
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(aProd[nI][19])
					aProd[nI][25] += aProd[nI][19] +"|"+ Right(DTOS(SD1->D1_DTVALID),2)+"/"+substr(DTOS(SD1->D1_DTVALID),5,2)+"/"+left(DTOS(SD1->D1_DTVALID),4) 
				EndIf
            Endif


			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))

				If !Empty(SB5->B5_CEME)
					aProd[nI][25] +=  " # " + AllTrim(SB5->B5_CEME) //Inf. complementar do produto
				EndIf	
	            
				If AllTrim(SB5->B5_CERT) == "S"
					lMens1 := .T.				
				EndIf	
			EndIf
		Next

		//Mensagem Complementar da Nota
		If lMens1
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
 			cMensCli +="DECLARAMOS QUE OS PRODUTOS, ESTAO EMBALADOS ADEQUADAMENTE PARA SUPORTAR OS RISCOS NORMAIS "
 			cMensCli +="DE CARREGAMENTO, DESCARREGAMENTO,TRANSBORDO E TRANSPORTE E ATENDE A REGULAMENTACAO EM VIGOR."
		EndIf
        
		RestArea(aArea2)
		RestArea(aArea)
    
    EndIf

//Polaris
ElseIf cCodEmp == "PL"

	If cEntSai == "S" //Nf de Saida

		aArea  := SB5->(GetArea())
		aArea2 := SC6->(GetArea())

		For nI:=1 To Len(aProd)
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
			
		 	SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))	
				If !Empty(SC6->C6_P_CHASS)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] +="Chassi: "+Alltrim(SC6->C6_P_CHASS)
				EndIf
			EndIf
			
		Next
		
		RestArea(aArea)	
		RestArea(aArea2)	
    
	Else //Nf de Entrada	

        aArea  := SD1->(GetArea())
		aArea2 := SB5->(GetArea())
		
		For nI:=1 To Len(aProd)
		
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))

				SB5->(dbSetOrder(1))
				If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
					If !Empty(SB5->B5_CEME)
						If !Empty(aProd[nI][25])
							aProd[nI][25] += " "
						EndIf
						aProd[nI][25] += AllTrim(SB5->B5_CEME)
					EndIf	
				EndIf		
											
				If !Empty(SD1->D1_P_CHASS)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] +="Chassi: "+Alltrim(SD1->D1_P_CHASS) //Mensagem complementar do produto
				EndIf
				        
			EndIf

		Next

		RestArea(aArea)
		RestArea(aArea2)	
		  	
	EndIf

//Ceres RRP 03/10/2012 - Tratamento para carregar o lote no XML igual a empresa Sirona
ElseIf cCodEmp == "CZ"
	If cEntSai == "S" //Nf de Saida
        //Informações de produtos
		aArea  := SD2->(GetArea())		
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] := "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
			EndIf			
		Next

		RestArea(aArea)
		
	Else //Nf de Entrada
        //Informações de produtos		
		aArea := SD1->(GetArea())
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		
		RestArea(aArea)

	EndIf
//JSS - 029559 ADD Informações complementares do produto			
		aArea:= SB5->(GetArea())

		For nI:=1 To Len(aProd)
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
		Next
		
		RestArea(aArea)
	
//Meda Pharma RRP 31/07/2013 - Tratamento para carregar o lote no XML igual a empresa Sirona
ElseIf cCodEmp == "3R"
	
	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea  := SF4->(GetArea())	
		aArea2 := SC6->(GetArea())
		aArea3 := SD2->(GetArea())		

		For nI:=1 To Len(aProd)
			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] := "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
							
			EndIf			
			
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4")+aInfoItem[nI][3]))			
				If Alltrim(SF4->F4_ESTOQUE) == "N"
			 		
				 	SC6->(DbSetOrder(1))
					If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
					
						//RRP - 14/10/2013 - Tag xPed					
						If !Empty(SC6->C6_PEDCLI)
							If SC6->(FieldPos("C6_P_ITCLI")) > 0
								aAdd(aPedCom,{SC6->C6_PEDCLI,SC6->C6_P_ITCLI})
							Else
								aAdd(aPedCom,{SC6->C6_PEDCLI,""})
							EndIf
						Else
							aadd(aPedCom,{})
						EndIf						
						
						If !Empty(Alltrim(SC6->C6_P_LOTE)) .And. !Empty(Alltrim(DtoC(SC6->C6_P_DATA)))
				
							If !Empty(SC6->C6_P_LOTE)
								aProd[nI][19] := SC6->C6_P_LOTE
								aProd[nI][25] :="Lote: " + Alltrim(SC6->C6_P_LOTE)+" Validade: "+Alltrim(DtoC(SC6->C6_P_DATA))
							EndIf	
							
						EndIf
			
					EndIf
			 		
				EndIf
			EndIf
		Next
		
		//RRP - 02/08/2013 - Inclusão de mensagem padrão conforme chamado 013823
		If !Empty(cMensCli)
			cMensCli += " "
		EndIf
   		cMensCli += "Local de origem da carga: Globex Armazenagem Multimodal Ltda - CNPJ: 10.359.730/0001-37 - Av. Vitório Rossi Martini, No. 31, Distrito Industrial , Indaiatuba - SP."
		cMensCli += " Responsabilidade do frete por conta da Globex."//RRP - 22/08/2013 - Inclusão de mensagem padrão conforme chamado 014179

		RestArea(aArea)
		RestArea(aArea2)
		RestArea(aArea3)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aProd)

			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		
		RestArea(aArea)

	EndIf

//Dr. Reddys
ElseIf cCodEmp == "U2"

  	If cEntSai == "S" //Nf de Saida
    	
    	aArea  := SB1->(GetArea())
    	aArea2 := SC6->(GetArea())
		aArea3 := SD2->(GetArea())        

		lMens1 := .F.
		lMens2 := .F.
    	
    	For nI:=1 To Len(aProd)
			           	
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aProd[nI][2]))
			 	SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
				
					If SB1->B1_GRUPO = 'F001' .And. SC6->C6_LOCAL='03'
						lMens1 := .T.					
					EndIf
				
	    		EndIf
			EndIf				
			
			If AllTrim(aProd[nI][2]) $ "001.01.017|001.01.018|001.01.019|001.01.020|001.01.021|001.01.022|002.01.017"
				lMens2 := .T.
			EndIf

			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				nDescon   += SD2->D2_DESCON+SD2->D2_DESCZFR
				nTotVal   += SD2->D2_QUANT * SD2->D2_PRUNIT  
				nDescItem += (SD2->D2_QUANT * SD2->D2_PRUNIT)  * (SD2->D2_DESC /100)
			EndIf			

			If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
				If !Empty(cPedido)
	   	        	cPedido += " / "
				EndIf			
				cPedido += AllTrim(aInfoItem[nI][1])
			EndIf 
			
			//** LDB - 12/01/2018 
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(aProd[nI][19])
					aProd[nI][25] += aProd[nI][19] +"|"+ Right(DTOS(SD2->D2_DTVALID),2)+"/"+substr(DTOS(SD2->D2_DTVALID),5,2)+"/"+left(DTOS(SD2->D2_DTVALID),4) 
				EndIf	
			EndIf			

		Next
		
		//Informações Complementares da nota        
        If lMens1
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf
			
			cMensCli += Alltrim(Formula('143'))
        EndIf
        
        If lMens2
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += CRLF + " * PRODUTO PERTENCENTE A PORT. 344/98  LISTA C1"        
        EndIf
        
		If !Empty(cPedido)
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += "Pedido(s):" + Alltrim(cPedido) //Pedidos de Venda
		EndIf

		RestArea(aArea)
		RestArea(aArea2)
		RestArea(aArea3)

		aArea := SC5->(GetArea())

		If nDescon > 0              
			nDescRep := nDescon - nDescItem
			nPDescon := ((nDescon-nDescRep) / nTotVal ) * 100   

			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+aInfoItem[1][1]))
				If SC5->C5_DESC4 > 0 .And. nDescRep > 0
					If !Empty(cMensCli)
						cMensCli += " "
					EndIf
					
					cMensCli += "Repasse ICMS: " +Alltrim(Transform(SC5->C5_DESC4,"@R 999.99%")) + '.......'+Alltrim(TransForm(nDescRep,"@R 999,999.99"))+'   /   '
				EndIf
            EndIf

			If nDescon > nDescRep
				If !Empty(cMensCli)
					cMensCli += " "
				EndIf
		
				cMensCli += "Desconto " +Alltrim(Transform(nPDescon,"@R 999.99%"))+ "......."+ Alltrim(Transform((nDescon-nDescRep),"@ze 999,999,999.99")) + '   /   '
			EndIf
		EndIf

		RestArea(aArea)		
		
    	
	Else //Nf de Entrada

		aArea  := SD1->(GetArea())
		aArea2 := SA4->(GetArea())
		lMens  := .F.
		
		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA))
			//RRP - 23/11/2012 - Carregar a Tag <vol> apenas se existirem dados.
			If !Empty(SD1->D1_P_ESPEC)
	    		aadd(aEspVol,{ SD1->D1_P_ESPEC, SD1->D1_P_VOLUM , SD1->D1_P_LIQ , SD1->D1_P_BRUTO})	
            EndIf
            
			If !Empty(SD1->D1_P_TRANS) .And. Empty(aTransp)
				SA4->(dbSetOrder(1))
				If SA4->(DbSeek(xFilial("SA4")+SD1->D1_P_TRANS))
					aadd(aTransp,AllTrim(SA4->A4_CGC))
					aadd(aTransp,SA4->A4_NOME)
					aadd(aTransp,SA4->A4_INSEST)
					aadd(aTransp,SA4->A4_END)
					aadd(aTransp,SA4->A4_MUN)
					aadd(aTransp,Upper(SA4->A4_EST)	)
				EndIf
			EndIf
		EndIf

        //Informações de produtos		
		For nI:=1 To Len(aProd)

			If AllTrim(aProd[nI][2]) $ "001.01.017|001.01.018|001.01.019|001.01.020|001.01.021|001.01.022|002.01.017"
				lMens := .T.
			EndIf

			//Mensagem complementar
			/*
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
			*/
			//** LDB - 12/01/2018 
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(aProd[nI][19])
					aProd[nI][25] += aProd[nI][19] +"|"+ Right(DTOS(SD1->D1_DTVALID),2)+"/"+substr(DTOS(SD1->D1_DTVALID),5,2)+"/"+left(DTOS(SD1->D1_DTVALID),4) 
				EndIf
            Endif			
		Next

		//Mensagem Complementar da nota		        
        If lMens
			If !Empty(cMensCli)
				cMensCli += " "
			EndIf

			cMensCli += CRLF + " * PRODUTO PERTENCENTE A PORT. 344/98  LISTA C1"        
        EndIf	

		RestArea(aArea)
		RestArea(aArea2)		

	EndIf	

//Kapci
ElseIf cCodEmp == "KD"

	
    If cEntSai == "E" //Nf Entrada

		aArea  := SD1->(GetArea())
		aArea2 := SA4->(GetArea())
		
		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA))
	    	aadd(aEspVol,{ SD1->D1_P_ESPEC, SD1->D1_P_VOLUM , SD1->D1_P_LIQ , SD1->D1_P_BRUTO})	

			If !Empty(SD1->D1_P_TRANS) .And. Empty(aTransp)
				SA4->(dbSetOrder(1))
				If SA4->(DbSeek(xFilial("SA4")+SD1->D1_P_TRANS))
					aadd(aTransp,AllTrim(SA4->A4_CGC))
					aadd(aTransp,SA4->A4_NOME)
					aadd(aTransp,SA4->A4_INSEST)
					aadd(aTransp,SA4->A4_END)
					aadd(aTransp,SA4->A4_MUN)
					aadd(aTransp,Upper(SA4->A4_EST)	)
				EndIf
			EndIf
		EndIf

		RestArea(aArea)
		RestArea(aArea2)		

	EndIf
	
//Chery
ElseIf cCodEmp == "6H"
	//Nf de Saida ou entrada
	aArea  := SB5->(GetArea())
	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	RestArea(aArea)

//Ducati
//RRP - 15/02/2013 - Inclusão do complemento do produto conforme chamado 010122
ElseIf cCodEmp == "PF"
	//Nf de Saida ou entrada
	aArea  := SB5->(GetArea())
	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	RestArea(aArea)	

//Hazera
ElseIf cCodEmp == "HB"
	//If cEntSai == "S" //Nf de Saida	
		For nI:=1 To Len(aProd)
			If !Empty(aProd[nI][19])
				aProd[nI][25] := aProd[nI][19] //Controle de Lote
			EndIf
		Next
	//EndIf

//Illumina
ElseIf cCodEmp == "2C" //"4M"

	If cEntSai == "S" //Nf de Saida	
		
		For nI:=1 To Len(aProd)
           
			cMsgAux := ""
			
			//Tratamento para itens do tipo Kit
        	SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
			
				If !Empty(SC6->C6_P_OP)
					SD3->(DbSetOrder(1))
					If SD3->(DbSeek(xFilial("SD3")+SC6->C6_P_OP))
						
						nAux    := 0
	
						While SD3->(!EOF()) .and. SD3->(D3_FILIAL+D3_OP) == xFilial("SD3")+SC6->C6_P_OP
	               	
							//Inicia a impressão dos componentes do kit.
							If SD3->D3_CF <> "PR0"
								
								SB1->(DbSetOrder(1))
								If SB1->(DbSeek(xFilial("SB1")+SD3->D3_COD))
	                           
	                           	nAux++
	                            	
									If nAux == 1
										cMsgAux += "Kit Formado por:"
	                            Else
	                            	cMsgAux += " - "
	                            EndIf
	                            	 
									cMsgAux += " Item: " + AllTrim(Str(nAux))
	                            cMsgAux += " Prod: " + AllTrim(SD3->D3_COD)
	
									BeginSql Alias 'TMP'
									    SELECT D5_LOTECTL, D5_DTVALID
									    FROM %table:SD5%
									    WHERE %notDel%
									      AND D5_OP = %exp:SD3->D3_OP%
									      AND D5_NUMSEQ = %exp:SD3->D3_NUMSEQ%
									      AND D5_PRODUTO = %exp:SD3->D3_COD%
									      AND D5_LOCAL = %exp:SD3->D3_LOCAL%
									EndSql
	                            
	                            //Imprime as informações de Lote dos componentes.    
									TMP->(DbGoTop())
									If TMP->(!EOF() .and. !BOF())
										cMsgAux += " Lote: " + AllTrim(TMP->D5_LOTECTL)
										cMsgAux += " Vld.: " + DtoC(StoD(TMP->D5_DTVALID))
									EndIf
	
									TMP->(DbCloseArea())
	                                                        	
								EndIf
								
							EndIf
							SD3->(DbSkip())
						EndDo
						
						//Retira o traço do final e grava a as informações do componente.
						If Len(cMsgAux) > 0
							cMsgAux := AllTrim(cMsgAux)
							cMsgAux := Substr(cMsgAux,1,Len(cMsgAux)-1)
							aProd[nI][25] := cMsgAux
						EndIf
						
					EndIf
				
				//Tratamento para itens que não são Kits	
				Else
				
					SF4->(DbSetOrder(1))
					If SF4->(DbSeek(xFilial("SF4")+aInfoItem[nI][3]))			
						
						//Tratamento para nota de saúa do armazem.
						//Essa nota Eapenas para fins fiscais e portanto não atualiza estoque.
						//Porém por solicitação da Anvisa, possui tratamento customizado para impressão do lote.
						If Alltrim(SF4->F4_ESTOQUE) == "N"

							If !Empty(Alltrim(SC6->C6_P_LOTE)) .And. !Empty(Alltrim(DtoC(SC6->C6_P_DATA)))
				
								If !Empty(SC6->C6_P_LOTE)
									aProd[nI][19] := SC6->C6_P_LOTE
									aProd[nI][25] :="Lote: " + Alltrim(SC6->C6_P_LOTE)+" Vld.: "+Alltrim(DtoC(SC6->C6_P_DATA))
								EndIf	
							
							EndIf
						
						//Tratamento para nota de venda ao consumidor final.
						//O item a seguir Eum componente e portanto não faz parte de um kit. 
						Else
							
							aProd[nI][25] := aProd[nI][19]	
												
						EndIf
					EndIf
				EndIf
			EndIf
		
		Next
		
		//RRP - 10/04/2013 - Tratamento para adicionar infomações na mensagem complementar		
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+aInfoItem[1][1]))		

			If !Empty(Alltrim(SC5->C5_P_TPFRE)) .AND. Alltrim(SC5->C5_P_TPFRE) <> "NP"
				Do Case
			
					Case Alltrim(SC5->C5_P_TPFRE) == "RO"
				
						cMensCli +=" - Transporte Rodoviário"	
			
					Case Alltrim(SC5->C5_P_TPFRE) == "AE"
					
						cMensCli +=" - Transporte Aéreo"
			
				EndCase
			EndIf
		EndIf

	   cMensCli +="  -  Produtos destinados exclusivamente para pesquisa cientúƒica."
	
	Else //Nf de Entrada

		aArea := SD1->(GetArea())

		For nI:=1 To Len(aProd)

			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD1->D1_LOTECTL)
					aProd[nI][25] := "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		
		RestArea(aArea)

	EndIf
	
//ALLIANCE
//RRP - 29/08/2013 - Inclusão de customização
ElseIf cEmpAnt == "5F"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
                	aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf
	
	//Informações complementares do produto para notas de Saúas ou Entradas					
	aArea:= SB5->(GetArea())

	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	RestArea(aArea)
	
//STEELCASE
//RRP - 04/09/2013 - Inclusão de customização
ElseIf cEmpAnt == "9N"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
		
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        

		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
                	aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf
	
	//RRP - 25/10/2013 - Informações complementares do produto para notas de Saúas ou Entradas. Chamado 015243.				
	aArea:= SB5->(GetArea())

	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	RestArea(aArea)

//Equant
//RRP - 10/01/2014 - Inclusão de customização
ElseIf cEmpAnt $ "LW/LX"
	aAreaC5 := SC5->(GetArea())
	
	If cEntSai == "S" //Nf de Saida
		//RRP - 12/05/2014 - Código BEP. Chamado 018830.
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+aInfoItem[1][1]))
				
	   		If SC5->(FieldPos("C5_P_REF")) > 0 .AND. !Empty(SC5->C5_P_REF)
				
				If !Empty(cMensCli)
					cMensCli += " "
				EndIf
				
				cMensCli += "Código BEP: "+Alltrim(SC5->C5_P_REF) //Código obra
			EndIf
        EndIf

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_NUMSERI)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += " - (N.Serie: " + AllTrim(SD2->D2_NUMSERI) + ")"
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
		RestArea(aAreaC5)
	
	EndIf

//Dexa
//RRP - 28/01/2014 - Inclusão de customização
ElseIf cEmpAnt == "KQ"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        
                              	
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf
	
//ALLIED
//RRP - 12/02/2014 - Inclusão de customização
ElseIf cEmpAnt == "9P"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea := SD2->(GetArea())		

		For nI:=1 To Len(aProd)			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			
		Next
		RestArea(aArea)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        
                              	
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf

//VICTAULIC 
//MSM - 01/05/2014 - Tratamento para atender o chamado: 018642
ElseIf cCodEmp == "TM"
	aAreaC5 := SC5->(GetArea())

	if cEntSai == "S" //Nf de Saida	
		SC5->(DbSetOrder(1))
		if SC5->(DbSeek(xFilial("SC5")+aInfoItem[1][1]))
				
	   		if !Empty(SC5->C5_OBRA)
				
				if !Empty(cMensCli)
					cMensCli += " "
				endIf
				
				cMensCli += "Código Obra: "+Alltrim(SC5->C5_OBRA) //Código obra
			endIf
        
        endif

	endif   

	//RRP - 29/08/2013 - Informações complementares do produto para notas de Saúas ou Entradas					
	aArea:= SB5->(GetArea())

	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	
	RestArea(aArea)
	RestArea(aAreaC5)
	
//RRP - 21/07/2014 - Inclusão da Customização. Chamado 020058.
ElseIf cCodEmp == "GX"//MERIT
	
	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea  := SF4->(GetArea())	
		aArea2 := SC6->(GetArea())
		aArea3 := SD2->(GetArea())		

		For nI:=1 To Len(aProd)
			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
							
			EndIf			
			
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4")+aInfoItem[nI][3]))			
				If Alltrim(SF4->F4_ESTOQUE) == "N"
			 		
				 	SC6->(DbSetOrder(1))
					If SC6->(DbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))	
						
						If !Empty(Alltrim(SC6->C6_P_LOTE)) .And. !Empty(Alltrim(DtoC(SC6->C6_P_DATA)))
				
							If !Empty(SC6->C6_P_LOTE)
								If !Empty(aProd[nI][25])
									aProd[nI][25] += " "
								EndIf
								aProd[nI][19] := SC6->C6_P_LOTE
								aProd[nI][25] +="Lote: " + Alltrim(SC6->C6_P_LOTE)+" Validade: "+Alltrim(DtoC(SC6->C6_P_DATA))
							EndIf	
							
						EndIf
			
					EndIf
			 		
				EndIf
			EndIf
		Next

		RestArea(aArea)
		RestArea(aArea2)
		RestArea(aArea3)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())

		For nI:=1 To Len(aProd)

			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
                	aProd[nI][25] += "Lote: " + AllTrim(SD1->D1_LOTECTL) + " Validade: " + DtoC(SD1->D1_DTVALID)
				EndIf				
			EndIf
		Next
		RestArea(aArea)
	EndIf
	
	//Informações complementares do produto para notas de Saúas ou Entradas
	aAreaB5:= SB5->(GetArea())
						
	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	RestArea(aAreaB5)
	
//RRP - 22/10/2014 - Alteração da Customização feita pela empresa InfinIT Tecnologia. Chamado 022139.
//RRP - 15/12/2014 - Correção. Chamado 022780.
ElseIf cCodEmp $ "SU/LG"//Exeltis

	If cEntSai == "S" //Nf de Saida
	
		aArea	:= GetArea()
		aArea2	:= GetArea("SD2")
		aArea3	:= GetArea("SC5")
		aArea4	:= GetArea("SC6")
		Quebra	:= " || "
		
		//--< processamento >-----------------------------------------------------------------------
		/////////////////////////////////////////////////
		// NESSECIDADE //////////////////////////////////
		//PEDIDO -> 42565 PEDIDO CLIENTE -> 11008
		//VENDEDOR -> 210402 - RECOL - AC PROPAGANDA
		//POS. -> 0,00 0,00
		//NEG. -> 0,00 0,00
		//NAP. -> 0,00 0,00
		//PIS. -> 0,00 0,00
		//COFINS -> 0,00 0,00
		//REPASSE -> 1.303,17
		//BANCO DO BRASIL S/A - PARC. 01/3 VENCTO. 01/01/2014
		//Volume . -> 0,1318
		//PRAÇA DE PAGAMENTO >>> GOIÂNIA-GO <<<
		
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))
		SD2->(DBSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	
		DbSelectArea("SC5")
		SC5->(DBSetOrder(1))
		SC5->(DBSeek(xFilial("SC5")+SD2->D2_PEDIDO))
	
		DBSelectArea("SC6")
		SC6->(DBSetOrder(1))
		SC6->(DBSeek(xFilial("SC6")+SC5->C5_NUM))
	 
		RecnoSC6 := SC6->(RECNO())
		RepasseValor := 0
		While SC6->(!EOF()) .and. SC6->C6_NUM == SC5->C5_NUM
			If SC6->C6_DESCONT > 0 //VALIDA INDETERMINAÇÃO MATEMÁTICA
				RepasseValor += SC6->C6_VALDESC  //SC6->C6_VALOR*(SC6->C6_DESCONT/100)
			EndIf
			SC6->( dbSkip() )
		EndDo
		SC6->(DbGoto(RecnoSc6))
		
		
		cMensCli += " PEDIDO -> "+ SC5->C5_NUM + Quebra +;
			"PEDIDO CLIENTE -> "+SC6->C6_PEDCLI+ Quebra +;
			"VENDEDOR -> "+SC5->C5_VEND1+" - "+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")+" " + Quebra  +;
			"POS. -> 0,00 0,00 " + Quebra  +;
			"NEG. -> 0,00 0,00 " + Quebra  +;
			"NAP. -> 0,00 0,00 " + Quebra  +;
			"PIS. -> 0,00 0,00 " + Quebra  +;
			"COFINS -> 0,00 0,00 " + Quebra  +;
			"REPASSE -> "+Transform(RepasseValor,"@E 9,999,999.99") +" " + Quebra  +;
			"Volume . -> "+CVALTOCHAR(SC5->C5_VOLUME1)+" " + Quebra
	
		//RRP - 09/05/2018 - Inclusão da TAG para a AGV
		cMensCli += " [#"+Alltrim(SC5->C5_NUM)+"#]"
	    
		//Informações de produtos
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] := "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))+" "
				EndIf	
			EndIf			
		Next
	
		RestArea(aArea4)
		RestArea(aArea3)
		RestArea(aArea2)
		RestArea(aArea)

	Else //Nf de Entrada
        //Informações de produtos		
		aArea := SD1->(GetArea())
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD1->D1_LOTECTL)
					aProd[nI][25] := "Lote: "+AllTrim(SD1->D1_LOTECTL)+" Validade: "+Alltrim(DtoC(SD1->D1_DTVALID))+" "
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf

//JVR - 11/06/2015 - PFI - Lote e validade
ElseIf cCodEmp == "NW"
	If cEntSai == "S" //Nf de Saida
        //Informações de produtos
		aArea  := SD2->(GetArea())		
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
				If !Empty(SD2->D2_LOTECTL)
					aProd[nI][25] := "Lote: "+Alltrim(SD2->D2_LOTECTL)+" Validade: "+Alltrim(DtoC(SD2->D2_DTVALID))
				EndIf	
			EndIf			
		Next

		RestArea(aArea)
	Else //Nf de Entrada
        //Informações de produtos		
		aArea := SD1->(GetArea())
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				//Mensagem adicional do produto
                If !Empty(SD1->D1_LOTECTL)
                	aProd[nI][25] := "Lote: "+AllTrim(SD1->D1_LOTECTL)+" Validade: "+Alltrim(DtoC(SD1->D1_DTVALID))
				EndIf				
			EndIf
		Next
		RestArea(aArea)

	EndIf 	

//MSM - 30/06/2015 - Empresa: Zinpro - Tratamento de Lote - Chamado: 027735 
ElseIf cCodEmp == "08"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea  := SD2->(GetArea())		
		aAreaB5:= SB5->(GetArea())
		
		For nI:=1 To Len(aProd)			
            //Complemento de produto
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
			//Lote
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			

		Next
		
		RestArea(aArea)
		RestArea(aAreaB5)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        
		aAreaB5:= SB5->(GetArea())
		                              	
		For nI:=1 To Len(aProd)
            //Complemento de produto
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		

			//Lote
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf


		Next
		RestArea(aArea)

	EndIf

//RRP - 28/06/2016 - Empresa: Nelson
ElseIf cCodEmp == "BE"
	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea  := SA7->(GetArea())		
		aAreaB5:= SB5->(GetArea())
		
		For nI:=1 To Len(aProd)			
            //Complemento de produto
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
			//Código de cliente no SA7
			SA7->(DbSetOrder(1))
			If SA7->(DbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]))
				If !Empty(SA7->A7_CODCLI)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "/"+Alltrim(SA7->A7_CODCLI)
				EndIf	
			EndIf			

		Next
		
		RestArea(aArea)
		RestArea(aAreaB5)
			
	Else //Nf de Entrada
        
		aAreaB5:= SB5->(GetArea())
		                              	
		For nI:=1 To Len(aProd)
            //Complemento de produto
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf

		Next
		RestArea(aArea)

	EndIf

//RRP - 07/04/2017 - Empresa: Renesola
ElseIf cCodEmp == "JG"

	If cEntSai == "S" //Nf de Saida
		//Mensagem complementar na nota fiscal
		If !Empty(cMensCli)
			cMensCli += " "
		EndIf
		
		//RSB - 04/05/2017 - Montagem e calculo da mensagem da Informações Complementares.
		//Informações de produtos
		aArea  := SD2->(GetArea())		
		For nI:=1 To Len(aProd)
			//Mensagem complementar
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
			
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1") + aProd[nI][2]))
				
				nResto := SD2->D2_QUANT
				nUnit  := SB1->B1_P_UNQTD  
				nMult  := SB1->B1_P_MUQTD
				nMast  := SB1->B1_P_MAQTD
				
				If nMast <= nResto .and. nMast > 0  
					While nMast <= nResto
							nResto := nResto - nMast  
							nMast_Qtd	+= 1
							nMast_Calc	+= SB1->B1_P_MADIC * SB1->B1_P_MADIL * SB1->B1_P_MADIA
							nPesoLiq	+= SB1->B1_P_MAPL 
							nPesoBruto	+= SB1->B1_P_MAPB
						loop
					Enddo
				Endif 
				
				If nMult <= nResto .and. nMult > 0  
					While nMult <= nResto
							nResto := nResto - nMult  
							nMult_Qtd += 1
							nMult_Calc	+= SB1->B1_P_MUDIC * SB1->B1_P_MUDIL * SB1->B1_P_MUDIA 
							nPesoLiq	+= SB1->B1_P_MUPL 
							nPesoBruto	+= SB1->B1_P_MUPB
						loop
					Enddo
				Endif
				
				If nUnit <= nResto .and. nUnit > 0
					While nUnit <= nResto
							nResto := nResto - nUnit  
							nUnit_Qtd += 1
							nUnit_Calc	+= SB1->B1_P_UNDIC * SB1->B1_P_UNDIL * SB1->B1_P_UNDIA
							nPesoLiq	+= SB1->B1_P_UNPL 
							nPesoBruto	+= SB1->B1_P_UNPB
						loop
					Enddo
				Endif
				
				SB1->(dbCloseArea())
				
			EndIf			
		Next

		RestArea(aArea)
         
		//Montagem das mensagens e calculo do total
				If nUnit_Qtd > 0 
			   		cMensCli += " " + cValtochar(nUnit_Qtd) + " Volume(s) Caixa Unitaria, com " + strTran(cValtochar(ROUND(nUnit_Calc,3)),".",",") + " M3 - "
			    Endif
			    
			    If nMult_Qtd > 0 
			   		cMensCli += " " + cValtochar(nMult_Qtd) + " Volume(s) Caixa Multipla, com " + strTran(cValtochar(ROUND(nMult_Calc,3)),".",",") + " M3 - "
			    Endif
			    
			    If nMast_Qtd > 0 
			   		cMensCli += " " + cValtochar(nMast_Qtd) + " Volume(s) Caixa Master, com " + strTran(cValtochar(ROUND(nMast_Calc,3)),".",",") + " M3 - "
			    Endif
				
				nVol_Total  := nMast_Qtd + nMult_Qtd + nUnit_Qtd
				nCalc_Total := nMast_Calc + nMult_Calc + nUnit_Calc
				
				If nVol_Total > 0 .and. nCalc_Total > 0 
					cMensCli += " TOTAL: " + cValtochar(nVol_Total) + " VOLUME(s), COM " + strTran(cValtochar(ROUND(nCalc_Total,3)),".",",") + " M3 "+SPACE(2) 
					cMensCli += " PESO LIQUIDO:" + cValtochar(nPesoLiq) + "KG / PESO BRUTO:" + cValtochar(nPesoBruto)+ "KG" +SPACE(2) 
			   	    
					If len(aEspVol) == 0
						aadd(aEspVol,{ "Caixa", nVol_Total, nPesoLiq , nPesoBruto}) 
					Endif	
                Endif
		
		//cMensCli += "Local de coleta: Armazens Gerais Agricola Ltda - Rua Projetada PS 333, Aeroporto, Varginha MG - CNPJ: 21.378.906/0001-14 "
		//RSB - 26/09/2017 - Alteração de mensagem de endereço da Renesola
		//RSB - 14/11/2017 - Alteração de mensagem de endereço da Renesola
		If SD2->D2_FILIAL $ "01"
			//cMensCli += "Local de coleta: Argos Outsourcing Solutions Ltda - R. Landri Sales, 1070, Cidade Aracilia, Guarulhos - SP - CNPJ:10.978.186/0001-01 I.E:336.589.424.115 "
	    	cMensCli += "Local de coleta: Argos Outsourcing Solutions Ltda - R. Dona Catharina Maria de Jesus, nº 400, Galpão 04/05/06, Bonsucesso, Guarulhos - SP - CNPJ: 10.978.186/0003-73 I.E: 336.520.104.119 "	
		Else
			cMensCli += "Local de coleta: Armazens Gerais Agricola Ltda - Rua Projetada PS 333, Aeroporto, Varginha MG - CNPJ: 21.378.906/0001-14 "		
		Endif
			
	EndIf
    
    //Complemento de produto    
	aAreaB5:= SB5->(GetArea())
	                              	
	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf

	Next
	RestArea(aAreaB5)

//RRP - 20/09/2017 - Inclusão da empresa Perdue	
ElseIf cEmpAnt == "JB"

	aAreaC5 := SC5->(GetArea())
	
	If cEntSai == "S" //Nf de Saida
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+aInfoItem[1][1]))
				
	   		If SC5->(FieldPos("C5_P_MSGNF")) > 0 .AND. !Empty(SC5->C5_P_MSGNF)
				
				If !Empty(cMensCli)
					cMensCli += " "
				EndIf
				
				cMensCli += Alltrim(SC5->C5_P_MSGNF) //Mensagem Nota
			EndIf
        EndIf
    EndIf
	RestArea(aAreaC5)
	
    //Complemento de produto    
	aAreaB5:= SB5->(GetArea())
	                              	
	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf

	Next
	RestArea(aAreaB5)

//JVR - 06/08/2018 - doTerra - Tratamento para dados do destinatario
ElseIf cEmpAnt == "N6"
	aAreaC5 := SC5->(GetArea())
	If cEntSai == "S" //Nf de Saida
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+aInfoItem[1][1]))
	   		If SC5->(FieldPos("C5_P_ENDEN")) > 0 .AND. !Empty(SC5->C5_P_ENDEN)
				nRecCount := 0
				If Select("ZX4PE01") > 0
					ZX4PE01->(DbCloseArea())
				EndIf
				cQry := "SELECT TOP 1 *
				cQry += " FROM "+RetSqlName("ZX4")
				cQry += " WHERE D_E_L_E_T_ <> '*'
				cQry += "	AND ZX4_CODEND = '"+SC5->C5_P_ENDEN+"'
				DbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), "ZX4PE01", .F., .T.)
				Count to nRecCount
				ZX4PE01->(DbGoTop())
				If nRecCount > 0
					If !Empty(cMensCli)
						cMensCli += " "
					EndIf
					cMensCli += "Contato do destinatário: "+Alltrim(ZX4PE01->ZX4_NOME) //Nome contato para entrega
				EndIf
				ZX4PE01->(DbCloseArea())
			EndIf
        EndIf
	EndIf
    
	RestArea(aAreaC5)
	
    //Complemento de produto    
	aAreaB5:= SB5->(GetArea())
	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf
	Next
	RestArea(aAreaB5)

//MSM - 10/10/2018 - Empresa: AGBITECH - Tratamento de Lote - Chamado: 47548
ElseIf cCodEmp == "RY"

	If cEntSai == "S" //Nf de Saida

        //Informações de produtos
		aArea  := SD2->(GetArea())		
		aAreaB5:= SB5->(GetArea())
		
		For nI:=1 To Len(aProd)			
            //Complemento de produto
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		
			//Lote
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
				If !Empty(SD2->D2_LOTECTL)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+Alltrim(SD2->D2_LOTECTL)
				EndIf	
			EndIf			

		Next
		
		RestArea(aArea)
		RestArea(aAreaB5)
			
	Else //Nf de Entrada

		aArea := SD1->(GetArea())        
		aAreaB5:= SB5->(GetArea())
		                              	
		For nI:=1 To Len(aProd)
            //Complemento de produto
			SB5->(dbSetOrder(1))
			If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
				If !Empty(SB5->B5_CEME)
					If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += AllTrim(SB5->B5_CEME)
				EndIf	
			EndIf		

			//Lote
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie+SA2->A2_COD+SA2->A2_LOJA+aProd[nI][2]+aInfoItem[nI][4]))
                If !Empty(SD1->D1_LOTECTL)
                	If !Empty(aProd[nI][25])
						aProd[nI][25] += " "
					EndIf
					aProd[nI][25] += "Lote: "+AllTrim(SD1->D1_LOTECTL)
				EndIf				
			EndIf


		Next
		RestArea(aArea)

	EndIf


//Caso a empresa nao tenha nenhum tratamento feito acima.
Else

	//RRP - 29/08/2013 - Informações complementares do produto para notas de Saúas ou Entradas					
	aArea:= SB5->(GetArea())

	For nI:=1 To Len(aProd)
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[nI][2]))
			If !Empty(SB5->B5_CEME)
				If !Empty(aProd[nI][25])
					aProd[nI][25] += " "
				EndIf
				aProd[nI][25] += AllTrim(SB5->B5_CEME)
			EndIf	
		EndIf		
	Next
	
	RestArea(aArea)
	
EndIf

//Gravação do retorno
aadd(aRet,aProd)
aadd(aRet,cMensCli)
aadd(aRet,cMensFis)
aadd(aRet,aDest)
aadd(aRet,aNota)
aadd(aRet,aInfoItem)
aadd(aRet,aDupl)
aadd(aRet,aTransp)
aadd(aRet,aEntrega)
aadd(aRet,aRetirada)
aadd(aRet,aVeiculo)
aadd(aRet,aReboque)
aadd(aRet,aNfVincRur)
aadd(aRet,aEspVol)
aadd(aRet,aNfVinc)
aadd(aRet,aDetPag)
aadd(aRet,aObsCont)

aadd(aRet,aPedCom)
aadd(aRet,aExp)
aadd(aRet,aTotal)
Aadd(aRet,aCst)
Aadd(aRet,aIcms)
Aadd(aRet,aIpi)
Aadd(aRet,aICMSST)
Aadd(aRet,aPIS)
Aadd(aRet,aCOFINS)
Aadd(aRet,aCOFINSST)
Aadd(aRet,aISSQN)
Aadd(aRet,aAdi)
Aadd(aRet,aICMUFDest)
Aadd(aRet,aIPIDevol)
Aadd(aRet,aPisAlqZ)
Aadd(aRet,aCofAlqZ)
Aadd(aRet,aCsosn)

RETURN aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyGetEnd  ³ Autor ³ Liber De Esteban             ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o participante e do DF, ou se tem um tipo de endereco ³±±
±±³          ³ que nao se enquadra na regra padrao de preenchimento de endereco  ³±±
±±³          ³ por exemplo: Enderecos de Area Rural (essa verificção e feita     ³±±
±±³          ³ atraves do campo ENDNOT).                                         ³±±
±±³          ³ Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo    ³±±
±±³          ³ Endereco (sem numero ou complemento). Caso contrario ira retornar ³±±
±±³          ³ o padrao do FisGetEnd                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs.     ³ Esta funcao so pode ser usada quando ha um posicionamento de      ³±±
±±³          ³ registro, pois serEverificado o ENDNOT do registro corrente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS-Copia do NFeSefaz                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyGetEnd(cEndereco,cAlias)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlias+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlias+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco, (&(cAlias+"->"+cCmpEst)))
EndIf

Return aRet
