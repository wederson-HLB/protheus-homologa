#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MT410TOK
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. Exclusão do Pedido de Venda. 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 05/04/2010     
Obs         : 
TDN         : Este ponto de entrada é executado ao clicar no botão OK e pode ser usado para validar a confirmação das operações: incluir,  alterar, copiar e excluir.Se o ponto de entrada retorna o conteúdo .T., o sistema continua a operação, caso contrário, volta para a tela do pedido.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/02/2012
Obs         : 
Módulo      : Faturamento.                           

*/
*-----------------------*
User Function  MT410TOK() 
*-----------------------*    
Local cRet 	   := ""
Local cErroST  := ""
Local cErroCF  := ""  
Local cErroTES := ""
Local cQry     := ""   
Local lParamFCI := SuperGetMv("MV_P_00107",.F.,.F.) 		//CAS - 06/10/2017 - Projeto TOTVS Fiscal - Empresas com o campo FCI obrigatório no item do pedido de Venda

//RRP - 28/11/2013 - Variável Mabra
Local cPosLote :=  aScan(aHeader, {|x| Alltrim(x[2]) == "C6_P_PBLQL"})   

Local cPosFCI :=  aScan(aHeader, {|x| Alltrim(x[2]) == "C6_FCICOD"})

Local nQtVol      :=  0   
Local nQtVolTotal :=  0
Local nResto      :=  0 
Local lLote       := .F. 
Local lRet        := .T.

Local aItens      := {}

If cEmpAnt $ ("KX/XC")  //Veraz
	If SC5->(FieldPos("C5_P_ROM")) > 0  
		cRet:=PROCNAME()
		If ParamIXB[1] == 1 
			If !Empty(SC5->C5_P_ROM) 
				ZX3->(DbSetOrder(1))          
				If ZX3->(DbSeek(xFilial("ZX3")+SC5->C5_P_ROM+SC5->C5_P_DLRY))  
					RecLock("ZX3",.F.)  
					ZX3->ZX3_VINC :="N"   
					ZX3->ZX3_MOVIM:=""  
					ZX3->(MsUnlock())    
				EndIf
			EndIf
		EndIf   
	EndIf  

//Tratamento de numero de serie x produtos - EUROSILICONE / TLM    
ElseIf cEmpAnt $ ("3U")
   lLote  :=  GetMv("MV_P_LOTE")
   If llote    
      aItens :=  aCols     
      nPos1  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO' })    
      nPos2  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_LOTECTL' })  
   
      SB1->(DbSetOrder(1))
      For i:=1 to Len(aItens)   
         If  Empty(aItens[i][nPos2])
            If SB1->(DbSeek(xFilial("SB1")+aItens[i][nPos1])) 
               If SB1->B1_RASTRO == "L"
                  lRet:=.F.
                  MsgStop("O lote deve ser preenchido","EUROSILICONE")
               EndIf
            EndIf
         EndIf 
      Next    
   EndIf  
   
   If ParamIXB[1] == 1  .Or. ParamIXB[1] == 4 // alterar ou apagar.
      ZX2->(DbSetOrder(1))
      If ZX2->(DbSeek(xFilial("ZX2")+SC5->C5_NUM))  
         lRet:=.F.
         MsgStop("Esse pedido está vinculado com as series dos itens, necessário estornar esse vinculo antes da alteração/exclusão do pedido.")
      EndIf
   EndIf      

//RRP - 23/01/2017 - Empresa desativada.    
// Tratamento de embalagem x produto - TLM   
/*ElseIf cEmpAnt $ ("HZ")
   nPosQtde    :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN' })  
   aItens      :=  aCols
   nPosItem    :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO' })  
   
   SB1->(DbSetOrder(1))
   For i:=1 to Len(aItens)   
      If SB1->(DbSeek(xFilial("SB1")+aItens[i][nPosItem])) 
         If SB1->B1_QE == 0 
            MsgAlert("O campo Qtd/Embalagem utilizado no calculo de Volume está zerado no cadastro do produto " + Alltrim(aItens[i][nPosItem]))
         EndIf

         nQtVol := int(aItens[i][nPosQtde]/SB1->B1_QE)

         If nQtVol < 1
            nQtVol :=1
            nResto :=0
         Else 
            nResto := aItens[i][nPosQtde]%SB1->B1_QE
         EndIf
         
         If nResto > 0 
            nQtVol += nResto 
         EndIf
         nQtVolTotal += nQtVol
      EndIf
   Next  
   
   If nQtVolTotal > 0
      M->C5_VOLUME1:=nQtVolTotal
      M->C5_ESPECI1:="CAIXA(S)"
      lRet := .T.
   EndIf
*/
// Grava Flag de OP Utilizada no Arquivo SD3 
ElseIf cEmpAnt $ ("4M/2C")  //Ilumina Teste
	cArea     := GetArea()                   
 	nPosProd  := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})  
  	nPosOP    := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_P_OP"})   
  	  	
  	SD3->( DbSetOrder(1) )               
   	For i := 1 to Len(aCols)     	
   		If Altera
	    	//Apaga o numero de pedido vinculado na OP
 	   		cQry := "Update SD3"+alltrim(cEmpAnt)+"0 set D3_P_NUM=' ' where D3_P_NUM='"+alltrim(M->C5_NUM)+"' and D3_COD='"+aCols[i, nPosProd]+"'" 

 	   		TCSQLExec(cQry)   
 	  		//Executa a query
			If (TCSQLExec(cQry) < 0)   
				MsgInfo(" Erro na execução da alteração(P.E MT410TOK - TCSQLError()), entrar em contato com suporte :  " + TCSQLError())  
			EndIf 	
	    	
   		EndIf	
   	
		if SD3->( DbSeek( xFilial("SD3") + aCols[i, nPosOP] + aCols[i, nPosProd] ) )
	    	Reclock("SD3",.f.)
	    	SD3->D3_P_NUM := iif( !INCLUI .and. !ALTERA, Space( Len(SC5->C5_NUM) ),M->C5_NUM )
	    	SD3->(MsUnlock())  
	   	    	
	   	Endif	   
    Next i 
    
    RestArea(cArea)
    
//RRP - 28/11/2013 - Solicitação Mabra. Chamado 015210
//RRP - 23/07/2014 - Inclusão empresa Exeltis. Chamado 020283 
//WFA - 19/19/2018 - Inclusão da empresa Exeltis, código LG.
ElseIf cEmpAnt $ ("JK/SU/LG")  //Mabra/Exeltis
	If INCLUI .AND. len(aCols)>= 1 .OR. ALTERA .AND. len(aCols)>= 1
		For i:= 1 to len(aCols)
			if aCols[i,cPosLote] == "S"
				xmaghelpfis("Atenção","Existe(m) Produto(s) com Limite(s) de Vencimento(s) não aceito pelo Cliente neste Pedido de Venda!","Solicite Liberação do Lote do produto utilizado ou utilize outro Lote.")
				lRet := .F.
			Endif
		Next i     
	Endif

//Validação especifica Twiter
ElseIf cEmpAnt $ "TP"

   	nPosRef  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_P_REF' })  
    lFataRef := .F.
    
	SE4->(DbSetOrder(1))
	If SE4->(FieldPos("E4_P_DESC")) <> 0 .and. SC5->(FieldPos("C5_P_NUM")) <> 0 .and. SC6->(FieldPos("C6_P_REF")) <> 0
		If SE4->(DbSeek(xFilial("SE4")+M->C5_CONDPAG))
			If ALLTRIM(UPPER(SE4->E4_P_DESC)) == 'PREPAYMENT'
                //MSM - 05/06/2015 - tratamento para checar o Io_Line_Number dos itens do pedido
                for i:=1 to len(aCols)
                	if empty(aCols[i][nPosRef])
                		lFataRef:=.T.
                	endif
                next

				If EMPTY(M->C5_P_NUM) .or. lFataRef
							
					MsgInfo("Condição de pagamento do tipo 'PREPAYMENT', devem ser informados os campos de 'IO number'(Capa) e 'Order Ref'(Item) !","HLB BRASIL")
					lRet := .F.
				
				EndIf
			EndIf
		EndIf
	EndIf       

EndIf
//RSB - 28/09/2017 - Inclusão empresa Monster. Ticket #11517
//RSB - 28/09/2017 - Verificação se o campo esta preenchido ou não. Ticket #11517  
If lParamFCI	   		//CAS - 06/10/2017 - Projeto TOTVS Fiscal (Substituindo o Ticket acima) - Empresas com o campo FCI obrigatório no item do pedido de Venda			 

	If INCLUI .OR. ALTERA .AND. len(aCols)>= 1
		//WFA - 28/06/2018 - Verifica se o campo C6_FCICOD existe no grid aberto. Ticket: #31211
		If cPosFCI > 0
			For i:= 1 to len(aCols)
				if Empty(aCols[i,cPosFCI])
					IF MSGYESNO("Campo FCI no item do pedido em branco. Confirma a inclusão do pedido?")
						lRet :=	.T. 
						Exit
					Else
						lRet :=	.F. 
						Exit
					Endif
				Endif
			Next i
		Else
			Aviso("HLB BRASIL","O campo de código do FCI não foi localizado.", {"Fechar"}, 1)
		EndIf
	Endif

Endif       

Return lRet