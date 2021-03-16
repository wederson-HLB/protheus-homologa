#include "Protheus.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M410LIOK บAutor  ณ Alexandre Caetano บ Data ณ  10/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada de validacao da linha do pedido de venda  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Grant Thorton                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Funcao      : M410LIOK
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. para validar se a TES movimenta Estoque e o Produto for tipo PA  perguntar ao usuario quando campo OP for vazio
Autor       : Alexandre Caetano 
Data        : 10/11/2012
TDN         : M410LIOK - Valida็ใo de linha de pedido ( < UPAR> ) --> URET                                                                                                      
Revisใo     : Tiago Luiz Mendon็a
Data/Hora   : 15/10/2012
M๓dulo      : Faturamento.
Cliente     : Illumina
*/             
*----------------------*
User Function M410LIOK()  
*----------------------*
Local aArea := GetArea() 
Local nPosTES, nPosProd, nPosOP
Local aDesconto := {}

//RRP - 26/08/2014 - Variแveis Exeltis
Local _nPosPrd,_nPosQt1,_nPosQt2,_nPosArm

//RRP - 28/11/2013 - Variแveis Mabra
//JSS - 04/04/2014 -  Alterado para solucionar o erro na importa็ใo chamado 018124 .
Local dDataLim := 0
Local nPosBlo := aScan(aHeader, {|x| Alltrim(x[2]) == "C6_P_PBLQL"})
Local nPosVen := aScan(aHeader, {|x| Alltrim(x[2]) == "C6_DTVALID"}) 
Local lBloqPos:= SC6->(FieldPos("C6_P_PBLQL")) > 0

//JSS-27/11/2015 Chamado 030516 
Local nVal1,nVal2,nPrcVen,nPrcVen,nPrcDes := 0
local nDesc1 	:= 0
Local nDesc2 	:= 0
Local nPosVlUn  := 0
Local nPosVlTo  := 0
Local nPosQtdV 	:= 0
Local nPosVlTb 	:= 0
Local nPosPD3   := 0
Local nPosVD3   := 0
Local nPrcTab 	:= 0
Local nQtdVen 	:= 0

Private lRet  := .T.

If cEmpAnt $ ("4M")  //Ilumina Teste       
	nPosTES		:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_TES"})  
	nPosProd	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
	nPosOP      :=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_P_OP"})

	SF4->(DBSetOrder(1))
	SF4->(DBSeek( xFilial("SF4") + aCols[n, nPosTES ] ) ) 
	SB1->(DBSetOrder(1))
	SB1->(DBSeek( xFilial("SB1") + aCols[n, nPosProd] ) ) 

	If SF4->F4_ESTOQUE = "S" .and. SB1->B1_TIPO = "PA" .and. Empty(aCols[n, nPosOP])
		If !MsgYesNo("O campo de OP nใo foi informado, deseja realmente nใo preecher", "Aten็ใo!!")
		   lRet := .f.
		Endif    	
	Endif  
Endif

//RRP - 28/11/2013 - Solicita็ใo Mabra. Chamado 015210
//RRP - 23/07/2014 - Inclusใo empresa Exeltis. Chamado 020283  
//JSS 04/04/2014 - Alterado para solucionar o erro na importa็ใo chamado 018124 .  
//WFA 19/09/2018 - Altera็ใo na valida็ใo do campo C6_P_PBLQL.
If cEmpAnt $ "JK/SU/LG" //Mabra/Exeltis
	If (INCLUI .OR. ALTERA) .AND. lBloqPos
		If !Empty(aCols[n,nPosVen])// Se Dt.Lote nao esta vazio no pedido, valida o Vencimento
			dDataLim:= DaySum(Date(),Val(SA1->A1_P_TEMPL)) // Soma os dias definidos no cadastro de cliente a data
			If aCols[n,nPosVen] <= dDataLim
				If MsgYesNo("Data Limite do Lote do Produto inferior a Data Limite estabelecida no cadastro do Cliente,seu uso serแ autorizado somente mediante senha de libera็ใo, Solicitar Libera็ใo ?")
					lRet:= u_JKFAT012() // Fun็ใo para Liberar Lote Produto 
					If !lRet   
						aCols[n,nPosBlo] := "S"
					Else
						aCols[n,nPosBlo] := "N"
					Endif
	    	    Else
	    	    	aCols[n,nPosBlo] := "S"  
	    	    	lRet := .F.
	    	    Endif                                       
			Else // Data Limite nao ้ menor que data vencimento
	    		aCols[n,nPosBlo] := "N"  
	    	Endif                           
		Else
			aCols[n,nPosBlo] := "N"  
		Endif                                                 
	Endif
EndIf

//RRP - 26/08/2014 - Chamado 020789
//RSB - 07/11/2017 - Inclusใo da nova base da Exeltis LG. P11_24 Ticket #18249
If cEmpAnt $ "SU/LG" //Exeltis
	//RRP - 08/11/2018 - Retirada a customiza็ใo. Ticket 50405.
	/*_nPosPrd := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_PRODUTO"})
	_nPosQt1 := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_QTDVEN"})
	_nPosQt2 := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_UNSVEN"})
	_nPosArm := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_LOCAL"})
	If M->C5_TIPO == "N"
		SB1->(dbSetOrder(1))
		If aCols[n,_nPosArm] <> "02"
			If aCols[n,_nPosQt2] > 0 .AND. Int(aCols[n,_nPosQt2]) <> aCols[n,_nPosQt2]
				SB1->(dbSeek(xFilial()+aCols[n,_nPosPrd]))
				lRet := .F.
				MsgStop("Quando o armazem nao for o FRACIONADO, a quantidade deve ser multipla de "+AllTrim(Str(SB1->B1_CONV)))
			EndIf
		EndIf
	EndIf*/
	//JSS - 24/11/2015 Chamado 030516
	lRet 		:= .T.
	nDesc1 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_XDESCO1"})
	nDesc2 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_XDESCO2"})
	nPosVlUn  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRCVEN"})
	nPosVlTo  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALOR"})
	nPosQtdV 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_QTDVEN"})
	nPosVlTb 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRUNIT"})
	nPosPD3   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_DESCONT"})
	nPosVD3   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALDESC"})
	nPrcTab 	:= aCols[n][nPosVlTb]
	nQtdVen 	:= aCols[n][nPosQtdV]	
	
	/*********** Calculos Iniciais ***********/
	nVal1 	:= a410Arred(nPrcTab * (1-(aCols[n][nDesc1]/100)))
	nVal2 	:= a410Arred(nVal1   * (1-(aCols[n][nDesc2]/100)))
	nPrcVen := a410Arred(nVal2   * (1 -(aCols[n][nPosPD3]/100)))
	nPercD	:= aCols[n][nPosPD3]
	nValD	:= a410Arred((nVal2  * aCols[n][nPosQtdV])* nPercD/100)	
	
	If aCols[n][nPosVlUn]*aCols[n][nPosQtdV] != nPrcVen*aCols[n][nPosQtdV]
		SX3->(dbSetOrder(2))
		/*********** PRECO ***********************/
		aCols[n][nPosVlUn] := nPrcVen
		A410MultT("C6_PRCVEN",nPrcVen) ;a410ZERA()
		SX3->(dbSeek("C6_PRCVEN"))
		If ExistTrigger("C6_PRCVEN") .and. N != Nil
			RunTrigger(2,n)
		EndIf
		/*********** Desconto1 ***********/
		SX3->(dbSeek("C6_XDESCO1"))
		If ExistTrigger('C6_XDESCO1') .and. n != Nil
			RunTrigger(2,n)//,nil,,'C6_XDESCO1')
		Endif
		/*********** Desconto2 ***********/
		SX3->(dbSeek("C6_XDESCO2"))
		If ExistTrigger('C6_XDESCO2') .and. n != Nil
			RunTrigger(2,n,nil)//,,'C6_XDESCO2')
		Endif
		/*********** Desconto3 *****************/
		aCols[n][nPosPD3] := nPercD
		aCols[n][nPosVD3] := nValD

		Ma410rodap()
	EndIf
EndIf 

/*   
	* 10/01/2018
	* Leandro Brito - BRL 
	* Valida็๕es Empresa U2 ( Dr. Reddyดs )
*/                                         
If ( cEmpAnt $ 'U2' )
	/*
		* Valida se o armazem pode ser utilizado 
	*/	                                        
	If !u_VldLocal( GdFieldGet( 'C6_LOCAL' , n ) , 'S' )
		lRet := .F.
		MsgStop( 'Armazem nao permitido em opera็๕es de saํda.' )
	EndIf	

EndIf



nPosNfori := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_NFORI"})
If nPosNfori <> 0 .and. !EMPTY(aCOLS[n,nPosNfori])           
	nPosLocal	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_LOCAL"})
	nPosLote	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_LOTECTL"})
	
	nPosNfori	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_NFORI"})
	nPosSeriori	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_SERIORI"})
	nPosItemori	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEMORI"})
	nPosProduto	:=  Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
	
	lRet := ValDadosOri(xFilial("SD1"),aCOLS[n,nPosNfori],aCOLS[n,nPosSeriori],aCOLS[n,nPosItemori],aCOLS[n,nPosProduto],M->C5_CLIENTE,M->C5_LOJACLI,;
						aCOLS[n,nPosLote],aCOLS[n,nPosLocal])
EndIf
RestArea(aArea)

Return(lRet)

/*
Funcao      : ValDadosOri 
Parametros  : 
Retorno     : 
Objetivos   : Fun็ใo para valida็ใo dos dados da NF de origem
Autor       : Jean Victor Rocha
Data/Hora   : 04/02/2016
Obs         : 
Cliente     : Todos
*/
*-----------------------------------------------------------------------------------------------*
Static Function ValDadosOri(cFil, cNFOri, cSerieOri, cItemOri, cCodi, cForn, cLoj, cLote, cLocal)
*-----------------------------------------------------------------------------------------------*
Local lRet := .T.
Local aAreaSD1 := SD1->(GetArea())
Local cMsgAlert := ""

SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 
If SD1->(MsSeek(cFil+cNFOri+cSerieOri+cForn+cLoj+cCodi+cItemOri))
	If ALLTRIM(SD1->D1_LOTECTL) <> ALLTRIM(cLote)
		lRet := .F.
		cMsgAlert += "O Lote deve ser o mesmo da NF origem ("+ALLTRIM(SD1->D1_LOTECTL)+")!" +CHR(10)+CHR(13)
	EndIf
	If ALLTRIM(SD1->D1_LOCAL) <> ALLTRIM(cLocal)
		lRet := .F.
		cMsgAlert += "O Armazem deve ser o mesmo da NF origem ("+ALLTRIM(SD1->D1_LOCAL)+")!" +CHR(10)+CHR(13)
	EndIf
Else
	MsgInfo("Falha na busca da NF origem ("+cFil+cNFOri+cSerieOri+cForn+cLoj+cCodi+cItemOri+") para valida็๕es!")
Endif

If !EMPTY(cMsgAlert)
	MsgAlert(cMsgAlert,"Grant Thornton Brasil")
EndIf

RestArea(aAreaSD1)

Return lRet


/*
Funcao      : VldLocal 
Parametros  : cLocal => Armazem a ser verificado , cEntSai => 'S' ( saida ) ou 'E' Entrada
Retorno     : 
Objetivos   : Validar se o armazem podera ser utilizado na entrada ou saida
Autor       : Leandro Diniz de Brito
Data/Hora   : 11/01/2018
Obs         : 
Cliente     : U2
*/
*----------------------------------------------*
User Function VldLocal( cLocal , cEntSai )      
*----------------------------------------------*                                       
Local lValido := .T.  

If NNR->( DbSetOrder( 1 ) , DbSeek( xFilial( 'NNR' )  + cLocal ) ) 
	lValido := If( cEntSai == 'S' , ( NNR->NNR_P_BLQS <> '1' ) , ( NNR->NNR_P_BLQE <> '1' ) )
EndIf


Return( lValido )