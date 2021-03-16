/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa ³ MT10LOK  ³ HAMILTON É CLARO              ³ Data ³13/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PE na validacao das linhas do ACOLS NF entrada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Pryor                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

/*
Funcao      : MT100LOK 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. na validacao das linhas do ACOLS NF entrada
Autor       : Hamilton 
Data/Hora   : 13/04/2004   	
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/07/2012
Obs         : 
Módulo      : Compras.
Cliente     : Todos
*/
*----------------------*
USER FUNCTION MT100LOK()
*----------------------*
Local nPos1,nPos2,cRomaneio,cProduto,aValida,cLote //TLM       
Local aRomaneios:={} //TLM  

LOCAL   lRET           := .T.
PRIVATE nPos_PROD    	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
PRIVATE nPos_PEDIDO  	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})

If SM0->M0_CODIGO $ "DJ/" //EMPRESA wfi / FSI
	_cPRODUTO   := aCOLS[ n , nPos_PROD ]
	_cPEDIDO    := aCOLS[ n , nPos_PEDIDO ]
	IF !(aCols[ n,Len(aHeader)+1])  //se a linha nao estiver deletada.
		/// VERIFICA -- bloqueio de item por falta de pedido
		If Empty(_cPEDIDO) .AND. subst(_cProduto,1,2)<> "DE"  // Nao permite digitacao do prox. item caso o parametro do produto seja = S
			lRET := .F.
			Aviso("Informacao","O produto "+AllTrim(_cPRODUTO)+" "+AllTrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+_cPRODUTO,1))+" nao pode ser digitado sem pedido de compra",{"OK"})
		EndIf
	ENDIF
ENDIF 
        

/*
Funcao      : PE para forçar a inclusão do romaneio.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 10/02/09 
Obs         : PE na validacao das linhas do ACOLS NF entrada para inclusão do romaneio.
*/         
If cEmpAnt $ "KX/XC"  // Veraz
   If SD1->(FieldPos("D1_P_PACK")) > 0 
      nPos1:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_P_PACK"})
      nPos2:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
      cRomaneio   := aCOLS[ n , nPos1 ]  
      cProduto    := aCOLS[ n , nPos2 ] 
      Aadd(aRomaneios,cRomaneio)
      
      SB1->(DbSetOrder(1))

      If SB1->(DbSeek(xFilial("SB1")+cProduto))
         If SB1->(FieldPos("B1_P_SISTE")) > 0                                                      
            If SB1->B1_P_SISTE =="1"
               If Empty(cRomaneio)
                  lRet:=.F.
                  MsgStop("Romaneio deve ser preechido","Veraz")
               Else 
                  ZX1->(DbSetOrder(1))
                  ZX1->(DbSeek(xFilial("ZX1")+cRomaneio)) 
                  If !Empty(ZX1->ZX1_NOTA) 
                     MsgStop("Romaneio jEutilizado : NOTA "+Alltrim(ZX1->ZX1_NOTA)+" SERIE "+Alltrim(ZX1->ZX1_SERIE),"Veraz")   
                     lRet:=.F. 
                  EndIf   
               EndIf
               
               If Alltrim(cTipo) <> Alltrim(ZX1->ZX1_TIPO)
                  lRet:=.F.
                  MsgStop("Tipo da Nota diferente do tipo do romaneio","Veraz")
               EndIf 
               
               If Alltrim(ZX1->ZX1_ORIGEM)== "LOC"
                  lRet:=.F.
                  MsgStop("Romaneio origem 'LOC' - Local , deve ser usado tipo 'IMP' - Importação ","Veraz")
               EndIf
                
            EndIf
            If !Empty(cRomaneio)
                If SB1->B1_P_SISTE <> "1"
                 lRet:=.F.
                  MsgStop("Esse item não estEconfigurado como sistema, verifique o cadastro de produto, ou retire o romaneio.","Veraz")                
                EndIF               
            EndIf     
         EndIf
      EndIf
   EndIf
EndIf  

If cEmpAnt $ "3U"
   nPos1    := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_P_TIPOM"})      
   cProduto := aCOLS[ n , nPos1 ]  
            
   If Empty(Alltrim(cProduto))
      MsgAlert("O campo Tipo do produto deve ser preenchido","EUROSILICONE") 
      lRet:=.F.       
   EndIf     
        
EndIf
       
If cEmpAnt $ "IS/IJ"
   nPos1    := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})      
   cProduto := aCOLS[ n , nPos1 ]
   
   nPos2    := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_LOTECTL"})      
   cLote := aCOLS[ n , nPos2 ] 
   
   nPos3    := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})      
   cTES := aCOLS[ n , nPos3 ]  
                                   
   SF4->(DbSetOrder(1))
   If SF4->(DbSeek(xFilial("SF4")+cTES))                                      
       If SF4->F4_ESTOQUE == "S"
   			SB1->(DbSetOrder(1))
   			If SB1->(DbSeek(xFilial("SB1")+cProduto))
   				If Empty(Alltrim(cLote)) .And. Alltrim(SB1->B1_RASTRO)=="L"
      				MsgAlert("O campo Lote deve ser informado","PROMEGA")
      	   			lRet:=.F.
				EndIf
			EndIf      
   		EndIf     
   EndIf
EndIf
 
If cEmpAnt $ "68"  // Chamado 42117   
  //nPos3:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"})    
  nPos4:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_CF"})
  //cNfOri  := aCOLS[ n , nPos3 ]  
  cCfop   := aCOLS[ n , nPos4 ] 
  //If !Empty(cNfOri)
     If cTipo == "N" .Or. cTipo == "B"
        If (cCfop $ "1201/1202/1503/1504/1411/1203/1204") 
           lRet:=.F.
           MsgStop("Tipo da nota deve ser 'D-Devolução' para CFOP's  1201/ 1202/ 1503/ 1504/ 1411/ 1203 /1204 ","Pryor")   
        EndIf
     EndIf    
  //EndIf
EndIf 


/*   
	* 10/01/2018
	* Leandro Brito - BRL 
	* Validações Empresa U2 ( Dr. Reddy´s )
*/                                         
If ( cEmpAnt $ 'U2' )
	/*
		* Valida se o armazem pode ser utilizado 
	*/	                                        
	If !u_VldLocal( GdFieldGet( 'D1_LOCAL' , n ) , 'E' )   //** Funcao VldLocal ( MT410LOK.PRW )
		lRet := .F.
		MsgStop( 'Armazem nao permitido em operações de entrada.' )
	EndIf	

EndIf

//Tratamento para validação do Lote e Armazem da devolução de acordo com a remessa.
//RRP - 23/03/2016 - Ajuste para habilitar por parâmetro a customização.
SX6->(DbSetOrder(1))
If !SX6->(DbSeek(xFilial("SX6")+"MV_P_00069") )
	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "MV_P_00069"
	SX6->X6_TIPO    := "L"
	SX6->X6_DESCRIC := "Habilitar ou Desabilitar o tratamento para validac"
	SX6->X6_DESC1	:= "do Lote e Armazem da dev. de acordo c/ a remessa. "
	SX6->X6_CONTEUD := ".T."
	SX6->X6_PROPRI  := "U"
	SX6->(MsUnlock())
EndIf

//RPB - 17/06/2016 - Valida somente o campo D1_NFORI para as notas com tipo "Devolução" e "Beneficio", Chamado: 033774 
If cTipo == "D" .Or. cTipo == "B"

	If SUPERGETMV("MV_P_00069",.F.,.T.)
		nPosA := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"})
		If nPosA <> 0 .and. !EMPTY(aCOLS[n,nPosA])
			//Dados da NF de origem atual
			nPosA := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"})
			nPosB := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIORI"})
			nPosC := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMORI"})
			nPosD := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
		
			//Dados da NF atual, para ser comparado
			nPos1 := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_LOTECTL"})
			nPos2 := Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})        
		
			lRet := ValDadosOri(xFilial("SD1"),aCOLS[n,nPosA],aCOLS[n,nPosB],aCOLS[n,nPosC],aCOLS[n,nPosD],cA100For,cLoja,;
								aCOLS[n,nPos1],aCOLS[n,nPos2])
		 EndIf
	EndIf
	
EndIf

Return(lRet) 
           
/*
Funcao      : ValDadosOri 
Parametros  : 
Retorno     : 
Objetivos   : Função para validação dos dados da NF de origem
Autor       : Jean Victor Rocha
Data/Hora   : 04/02/2016
Obs         : 
Cliente     : Todos
*/
*-----------------------------------------------------------------------------------------------*
Static Function ValDadosOri(cFil, cNFOri, cSerieOri, cItemOri, cCodi, cForn, cLoj, cLote, cLocal)
*-----------------------------------------------------------------------------------------------*
Local lRet := .T.
Local aAreaSD2 := SD2->(GetArea())
Local cMsgAlert := ""

SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If SD2->(MsSeek(cFil+cNFOri+cSerieOri+cForn+cLoj+cCodi+cItemOri))
	If ALLTRIM(SD2->D2_LOTECTL) <> ALLTRIM(cLote)
		lRet := .F.
		cMsgAlert += "O Lote deve ser o mesmo da NF origem ("+ALLTRIM(SD2->D2_LOTECTL)+")!" +CHR(10)+CHR(13)
	EndIf
	If ALLTRIM(SD2->D2_LOCAL) <> ALLTRIM(cLocal)
		If SM0->M0_CODIGO <> 'LG' .AND. SM0->M0_CODIGO <> 'JO' //CAS - 11/04/2018 - Ajuste para a empresa Exelti, Ticket #25463 //Paulo-EZ4 - 19/06/2019 - Ajuste para a empresa Monster,Ticket #11925, para poder trocar o armazem de origem.
			lRet := .F.
			cMsgAlert += "O Armazem deve ser o mesmo da NF origem ("+ALLTRIM(SD2->D2_LOCAL)+")!" +CHR(10)+CHR(13)
		EndIf
	EndIf
Else
	MsgInfo("Falha na busca da NF origem ("+cFil+cNFOri+cSerieOri+cForn+cLoj+cCodi+cItemOri+") para validações!")
Endif

If !EMPTY(cMsgAlert)
	MsgAlert(cMsgAlert,"HLB BRASIL")
EndIf

RestArea(aAreaSD2)

Return lRet