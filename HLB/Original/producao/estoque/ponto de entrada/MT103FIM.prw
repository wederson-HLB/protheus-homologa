#Include 'Protheus.ch'

/*
Funcao      : MT103FIM()
Objetivos   : Ponto de entrada para validação da integridade entre romaneio e nota de entrada.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 03/02/2009 
Obs         : Tratamento para interface de integração Veraz.   
*/
*---------------------------*             
User Function MT103FIM()
*---------------------------*
Local nPos:=0 
Local i   :=0 

Local aRomaneio,cRomaneio,cDocumento,cSerie,dData
Local aArea		:= {}
Local aArray 	:= {}
Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
Local nInssEmp  := 0
Local nNumFL	:= ""  
Local lFluig 	:= SuperGetMv("MV_P_00109",.T.,.F.) //RSB - 23/10/2017 - Utiliza Fluig

Local cTitPai	:= ""

Private xPreSel
Private lMsErroAuto := .F. 
 
//AOA - 08/02/2018 - Projeto doTerra (customizado por William Souza)
IF cEmpAnt $ "N6" .AND. cFilAnt == "02"
	aArea := GetArea()
	
	u_N6WS001(PARAMIXB[1],PARAMIXB[2],SF1->(RECNO()))
	
	RestArea(aArea)
EndIF	


//RSB - 23/10/2017 - Exibe a tela do numero do Fluig após a gravação do documento de entrada.   
//CAS - 04/01/2018 - Não exibir Telinha do Fluig p/ Solaris/Sullair nas Integrações - Ticket #22302
If SD1->(FieldPos("D1_P_NUMFL"))>0 .And. !(cEmpAnt $ "HH/HJ")
	If nConfirma == 1 .and. lFluig .and. (nOpcao == 3 .or. nOpcao == 4)
		U_GTGEN042()
	Endif
Endif
            

If cEmpAnt $ "KX/XC" //Veraz  
                                                     					
	aRomaneio:={} 
     
	cDocumento:=SD1->D1_DOC
	cSerie    :=SD1->D1_SERIE
     
	SD1->(DbGoTop()) 
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial("SD1")+cDocumento+cSerie ))     
	While SD1->(!EOF()) .And.   ( Alltrim(cDocumento) == Alltrim(cNFiscal)  .And. Alltrim(cSerie)==Alltrim(SD1->D1_SERIE) ) 
		Aadd(aRomaneio,{SD1->D1_P_PACK,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_COD})    
		dData:=SD1->D1_EMISSAO
		SD1->(DbSkip())             
	EndDo
     
	If !Empty(aRomaneio)
                           
		For i:=1 to Len(aRomaneio)
        
			ZX1->(DbSetOrder(1))
			ZX2->(DbSetOrder(1))         
        
			cRomaneio  :=Alltrim(aRomaneio[i][1])   
			cDocumento :=Alltrim(aRomaneio[i][2])
			cSerie     :=Alltrim(aRomaneio[i][3])
            
			If cRomaneio <> "" 
              
				If ZX1->(DbSeek(xFilial("ZX1")+cRomaneio))  
					RecLock("ZX1",.F.)
					ZX1->ZX1_NOTA   :=cDocumento
					ZX1->ZX1_SERIE   :=cSerie  
					ZX1->ZX1_DT_NF :=dData  
					ZX1->ZX1_VINC :="V"  // "V" Vinculado a nota fiscal de entrada
					ZX1->(MsUnlock()) 
				EndIf                                           
      
				ZX2->(DbSeek(xFilial("ZX2")+cRomaneio))
      
				While ZX2->(!EOF()) .And. Alltrim(cRomaneio)==Alltrim(ZX2->ZX2_NUM)
					RecLock("ZX2",.F.)
					ZX2->ZX2_NOTA    :=cDocumento
					ZX2->ZX2_SERIE   :=cSerie
					ZX2->ZX2_DT_NF   :=dData
					ZX2->(MsUnlock())                  
					ZX2->(DbSkip())
				EndDo        
			EndIf
		Next
	EndIf
    
// Tratamento de produto x serie - EUROSILICONE / TLM 
ElseIf cEmpAnt $ "3U"   
  
	Processa({|| ProcSerie() })

//ER - Tratamento de integração da Chemtool com o armazem (Logimaster)
ElseIf cEmpAnt $ "G6" 

	If nOpcao == 3 .and. nConfirma == 1 //Confirmação da inclusão da nota.
		Processa({|| IntLogimaster() })
	EndIf


Elseif cEmpAnt $ "LX/LW/99"
	    
	/*	Esse tratamento foi migrado para o fonte P.E - SF1100I- TLM Tratamento de fatura 20140828
	If nOpcao == 3 .and. nConfirma == 1 //Confirmação da inclusão da nota.
		//Chama tela para inserção do número da PO
		CadPO()
	  
	Endif
	*/
	
	if MsgYesNo("Deseja gerar a impressão da capinha de retenções?")
		U_GTEST002()
	endif
	//RRP - 11/11/2015 - Ajuste para gravar o SE2 apenas na inclusão e se gerar duplicata	
	If Alltrim(SF4->F4_DUPLIC)=="S" .AND. nOpcao == 3
		If SE2->(FieldPos("E2_P_FATUR"))>0 
			RecLock("SE2",.F.)
			SE2->E2_P_FATUR  := SF1->F1_P_FATUR
			MsUnLock()
		Endif
	EndIf
	
//Grupo Solaris
ElseIf cEmpAnt $ "HH/HJ/IK/"
	//RRP - 03/03/2017 - Gravar número do Protocolo no SF1 e SE2
	//Apenas na Inclusão do Documento
	If nOpcao == 3 .OR. nOpcao == 4 //Inclusão e Classificação
		//Botão confirmar
		//RRP - 30/05/2017 - Ajuste para rotinas via WebService. IsBlind() Retorna se há interface com usuário.
		If nConfirma == 1 .AND. (!(Alltrim(UPPER(FunName())) $ "INTPRYOR") .AND. !IsBlind()) .OR. (Alltrim(UPPER(FunName())) $ "U_GTGEN047") //CAS - 04/09/2019 Ajuste para tratar a função U_GTGEN047 e trazer a tela do Protocolo
			//Tela para preencimento do número do protocolo
			U_HHEST003(2)
		EndIf
		//Update apenas na confirmação da inclusão		
		If nConfirma == 1
			//Validação se os campos customizados existem
			If SE2->(FieldPos("E2_P_NUMFL"))>0 .AND. SE2->(FieldPos("E2_P_NDOC"))>0 .AND. SE2->(FieldPos("E2_P_IDPRO"))>0
				If SD1->(FieldPos("D1_P_NDOC"))>0 .AND. SD1->(FieldPos("D1_P_NUMFL"))>0 .AND. SD1->(FieldPos("D1_P_IDPRO"))>0
					If SF1->(FieldPos("F1_P_IDPRO"))>0
						//Update direto no banco para atualiza os campos Customizados no SE2	
						TcSqlExec( "UPDATE " + RetSqlName( "SE2" ) + " SET E2_P_NDOC = '" + SD1->D1_P_NDOC + "' ,E2_P_IDPRO = " + Alltrim(cValtoChar(SF1->F1_P_IDPRO)) + ",E2_P_NUMFL = " + Alltrim(cValtoChar(SD1->D1_P_NUMFL)) +;
								   " WHERE E2_FILORIG = '" + SF1->F1_FILIAL + "' AND E2_NUM = '" + SF1->F1_DUPL + "' AND E2_PREFIXO = '" + SF1->F1_PREFIXO + "' AND " +;
								   " E2_FORNECE = '" + SF1->F1_FORNECE + "' AND E2_LOJA = '" + SF1->F1_LOJA + "' " )
						
						//RRP - 17/03/2017 - Atualizar campo no SD1
						//Atualiza campo D1_P_IDPRO
						TcSqlExec( "UPDATE " + RetSqlName( "SD1" ) + " SET D1_P_IDPRO = " + Alltrim(cValtoChar(SF1->F1_P_IDPRO)) + " WHERE D1_FILIAL = '" + SF1->F1_FILIAL + "' AND " +;
									"D1_DOC = '" + SF1->F1_DOC + "' AND D1_SERIE = '" + SF1->F1_SERIE + "' AND D1_FORNECE = '" + SF1->F1_FORNECE + "' AND D1_LOJA = '" + SF1->F1_LOJA + "' " )
				
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//RPB - 10/11/2016 - Tratamento para que o cod fluig (D1_P_NUMFL) seja carragado automaticamente finanaceiro (E2_P_NUMFL)
//RSB - 03/07/2017 - Tratamento para que só aconteça quando for inclusão e Classificação. #8133
If nOpcao == 3 .OR. nOpcao == 4 //Inclusão e Classificação 
	If Alltrim(SF4->F4_DUPLIC)=="S" 						//CAS - 22-11-2017 - Tratamento somente para quando gerar Financeiro. #4714
		If SD1->(FieldPos("D1_P_NUMFL"))>0
			nNumFL := SD1->D1_P_NUMFL
		EndIf
		If !Empty(nNumFL)
		   If SE2->(FieldPos("E2_P_NUMFL"))>0			                                                
		       RecLock("SE2",.F.)
		       	SE2->E2_P_NUMFL := nNumFL
			   MsUnlock()          
		   EndIf
		EndIf	
	EndIF
Endif
	
//RRP - 24/11/2014 - Tratamento de geração dos títulos no financeiro para o RPA.
If (Alltrim(SF1->F1_ESPECIE) == "RPA" .OR. Alltrim(SF1->F1_ESPECIE) == "NFPS") .AND. nConfirma == 1 .AND. ;
	Alltrim(SF1->F1_TIPO) = "N"
	
	//Verifica se o Fornecedor está vinculado ao Funcionário
	aArea := SA2->(GetArea())
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	
	If SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
		If !Empty(Alltrim(SA2->A2_NUMRA))
	
			//Verifica se a TES gera financeiro
			If Alltrim(SF4->F4_DUPLIC)=="S"
		
				//Garante a Contabilizao Off-Line na Inclusao do Titulo
				GrvProfSX1("FIN050","04",2)
			
				aArray := { { "E2_PREFIXO"  , SF1->F1_PREFIXO     	, NIL },;
						 	{ "E2_NUM"      , SF1->F1_DOC       	, NIL },;
				            { "E2_TIPO"     , "NF"              	, NIL },;
				            { "E2_FORNECE"  , SF1->F1_FORNECE   	, NIL },;
				            { "E2_LOJA"  	, SF1->F1_LOJA		   	, NIL },;
				            { "E2_VALOR"    , SF1->F1_VALBRUT   	, NIL },;
				            { "E2_ORIGEM"	, "MATA100"				, NIL },;
				            { "E2_EMISSAO"	, dDataBase				, Nil },;
				            { "E2_NATUREZ"	, SED->ED_CODIGO		, Nil },;
				            { "E2_ISS"		, SF1->F1_ISS			, Nil },;
				            { "E2_VENCTO"	, dDataBase				, Nil }}
				
				If nOpcao == 3 //3 - Inclusao
			   		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)
			 	ElseIf nOpcao == 5 //5 - Exclusão
			 		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)
			 	EndIf
			 		//Restaura o parametro da Contabilizacao selecionado anteriormente
					GrvProfSX1("FIN050","04",xPreSel)
			 	
				//Validando se foi incluído os título via ExecAuto
				If !(lMsErroAuto) .AND. nOpcao == 3
				   	//Criando a referência do documento com os títulos do SE2
					SF1->(RecLock("SF1", .F.))
				   		SF1->F1_DUPL := SF1->F1_DOC
			   		SF1->(MsUnlock())
				
					//20% INSS Patronal
					nInssEmp 	:= SF1->F1_VALBRUT*0.2
					cTitPai		:= SF1->F1_PREFIXO+SF1->F1_DOC+" NF "+SF1->F1_FORNECE+SF1->F1_LOJA
					
					DbSelectArea("SA2")
					SA2->(DbSetOrder(1))
					If SA2->(DbSeek(xFilial("SA2")+"INSS  01"))
					
						//Gravando o INSS parte empresa
						SE2->(RecLock("SE2", .T.))
							SE2->E2_FILIAL 	:= xFilial("SE2")
							SE2->E2_PREFIXO	:= SF1->F1_PREFIXO
							SE2->E2_NUM    	:= SF1->F1_DOC
							SE2->E2_TIPO   	:= "TX"
							SE2->E2_PARCELA	:= StrZero(1,TamSX3("E1_PARCELA")[1],0)
							SE2->E2_NATUREZ	:= "4201"
							SE2->E2_FORNECE	:= SA2->A2_COD
							SE2->E2_NOMFOR	:= SA2->A2_NOME
							SE2->E2_LOJA  	:= SA2->A2_LOJA
							SE2->E2_VALOR  	:= nInssEmp
							SE2->E2_ORIGEM	:= "MATA100"
							SE2->E2_EMISSAO	:= dDataBase
							SE2->E2_TITPAI 	:= cTitPai
							//O vencimento do INSS Patronal será gravado igual o INSS retido, no dia 15 do mês subsequente.
							SE2->E2_VENCTO 	:= LastDay(DaySum(FirstDate(MonthSum(dDataBase,1)),14),3) //LastDay - Proximo dia útil, DaySum - Soma 14 dias, FristDate - Primeira data do Mês, MonthSum - Soma 1 mês na data
							SE2->E2_VENCREA	:= LastDay(DaySum(FirstDate(MonthSum(dDataBase,1)),14),3)
							SE2->E2_EMIS1	:= dDataBase
							SE2->E2_LA		:= "S" 
							SE2->E2_SALDO	:= nInssEmp
							SE2->E2_VENCORI	:= LastDay(DaySum(FirstDate(MonthSum(dDataBase,1)),14),3)
							SE2->E2_MOEDA	:= 1 
							SE2->E2_VLCRUZ	:= nInssEmp
							SE2->E2_FILORIG	:= cFilAnt
						SE2->(MsUnlock())
						
						SA2->(DbCloseArea())
					EndIF
			
				//Validando se foi excluído os títulos via ExecAuto	
				ElseIf !(lMsErroAuto) .AND. nOpcao == 5
					If SE2->(DbSeek(xFilial("SE2")+SF1->F1_PREFIXO+SF1->F1_DOC+StrZero(1,TamSX3("E1_PARCELA")[1],0)+"TX INSS  01")) //E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
				   		SE2->(RecLock("SE2", .F.))
				   			SE2->(DbDelete())
				   		SE2->(MsUnlock())
			   		EndIf
				Endif
			EndIf
		EndIf
		RestArea(aArea)
	EndIf
EndIf

//RRP - 21/09/2016 - Customização Vogel
If cEmpAnt $ u_EmpVogel()

	If !Empty(SF1->F1_DUPL)	
		aArea:=GetArea()
		If Select("QSC7")>0
			QSC7->(DbCloseArea())
		EndIf
		
		cQuery:=" SELECT TOP 1 C7_P_REF FROM "+RetSqlName("SC7")+" AS C7
		cQuery+=" 	JOIN "+RetSqlName("SD1")+" AS D1 ON D1.D_E_L_E_T_ <> '*' AND D1.D1_FILIAL+D1.D1_DOC+D1.D1_SERIE+D1.D1_FORNECE+D1.D1_LOJA = '"+SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+"'"
		cQuery+="  WHERE C7.D_E_L_E_T_ <> '*'
		cQuery+=" 	 AND C7.C7_NUM = D1.D1_PEDIDO
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "QSC7" ,.T.,.F.)	
	    
		Count to nRecCount
		If nRecCount > 0
			QSC7->(DbGoTop())
			cQuery2:= "UPDATE "+RetSqlName("SE2")+" SET E2_P_REF = '"+QSC7->C7_P_REF+"' "
			cQuery2+= "WHERE D_E_L_E_T_ <> '*' AND E2_FILORIG+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA = '"+SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_PREFIXO+SF1->F1_FORNECE+SF1->F1_LOJA+"' "
	        
			If TcSqlExec(cQuery2) < 0
				MsgInfo("Não foi possível atualizar o número do pedido Sistech no Financeiro!","Grant Thronton")
			EndIf
		EndIf
		QSC7->(DbCloseArea())		
		RestArea(aArea)
	EndIf		
EndIf
  

Return

// Tratamento de produto x serie - EUROSILICONE / TLM 
*---------------------------*             
Static Function ProcSerie()
*---------------------------* 

Local nQTD:=0 
Local cDocumento,cSerie,cCli,cCliDesc,cDocOri,cSerieOri 
Local cEmail:=cCod:=cTipo:=cPedido:=""  
Local aItens:={}        
Local n:= 1
Local i:= 0
Local cTES := GETMV("MV_P_TES_E") // TES que devem ter serie informada na entrada.
  
   If ParamIXB[1] == 3  //Inclui
       
      If !Empty(cNFiscal) .And. SF1->F1_TIPO $ "B/D/N"  .And. SD1->D1_TES $ cTES
      
         ZX0->(DbGoTop()) 
         ZX0->(DbSetOrder(2))
         If !(ZX0->(DbSeek(xFilial("ZX0")+SD1->D1_DOC+SD1->D1_SERIE)))   
                                             					
            cDocumento:=SD1->D1_DOC
            cSerie    :=SD1->D1_SERIE

            RecLock("ZX0",.T.) 
            ZX0->ZX0_FILIAL := xFilial("ZX0")
            ZX0->ZX0_DOC   := SD1->D1_DOC
            ZX0->ZX0_SERIE := SD1->D1_SERIE 
            ZX0->ZX0_DTNF  := SD1->D1_EMISSAO 
            If SD1->D1_TIPO $ "B/D"
               ZX0->ZX0_STATUS:= "DEV"
            Else
               ZX0->ZX0_STATUS:= "SEM"
            EndIf
            ZX0->ZX0_CLIENT:= SD1->D1_FORNECE                                                                                      
            ZX0->ZX0_LOJA  := SD1->D1_LOJA    
            ZX0->ZX0_TIPO  := SD1->D1_TIPO
            ZX0->ZX0_USER  := cUserName
         
            cCli  := SD1->D1_FORNECE
            cTipo := SD1->D1_TIPO            
     
            If SD1->D1_TIPO $ "B/D"
       
               SA1->(DbSetOrder(1))
               If SA1->(DbSeek(xFilial("SA1")+ZX0->ZX0_CLIENT+ZX0->ZX0_LOJA))
                  ZX0->ZX0_CLIDES:=SA1->A1_NOME   
               EndIf 
                   
               ZX2->(DbSetOrder(2))
               If ZX2->(DbSeek(xFilial("ZX2")+SD1->D1_NFORI+SD1->D1_SERIORI))
                   ZX0->ZX0_PEDIDO:=ZX2->ZX2_PEDIDO 
                   cPedido:=ZX0->ZX0_PEDIDO
               EndIf
            
               cCliDesc:=SA1->A1_NOME
    
            Else
    
               SA2->(DbSetOrder(1))
               If SA2->(DbSeek(xFilial("SA2")+ZX0->ZX0_CLIENT+ZX0->ZX0_LOJA))
                  ZX0->ZX0_CLIDES:=SA2->A2_NOME   
               EndIf
            
               cCliDesc:=SA2->A2_NOME  
    
            EndIf    
             
            ZX0->(MsUnlock()) 
   
            SD1->(DbGoTop()) 
            SD1->(DbSetOrder(1))
            SD1->(DbSeek(xFilial("SD1")+cDocumento+cSerie ))     
            While SD1->(!EOF()) .And. ( Alltrim(cDocumento) == Alltrim(SD1->D1_DOC)  .And. Alltrim(cSerie)==Alltrim(SD1->D1_SERIE) )    
     
               nQtd:=SD1->D1_QUANT
               
               If !(Substr(SD1->D1_COD,1,2) == "DE")
        
                  For i:=1 to nQtd   
               
                     IncProc("Aguarde, gerando espelho para series") 
                              
                     RecLock("ZX1",.T.)  
                     ZX1->ZX1_FILIAL := xFilial("ZX1")
                     ZX1->ZX1_TIPO   := SD1->D1_TIPO
                     ZX1->ZX1_COD    := SD1->D1_COD 
                     ZX1->ZX1_QTD    := 1
                     ZX1->ZX1_ITEM   := strzero(n,4,0)
                     ZX1->ZX1_SEQORI := SD1->D1_ITEM 
                     ZX1->ZX1_CLIENT := SD1->D1_FORNECE
                     ZX1->ZX1_LOJA   := SD1->D1_LOJA
                     ZX1->ZX1_LOCAL  := SD1->D1_LOCAL
                     SB1->(DbSetOrder(1))
                     If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
                        ZX1->ZX1_DESCOD :=SB1->B1_DESC 
                     EndIf
                     ZX1->ZX1_TIPO   := SD1->D1_TIPO
                     //ZX1->ZX1_LOTE   := SD1->D1_LOTECTL
                     ZX1->ZX1_DOC    := cDocumento
                     ZX1->ZX1_SERIE  := cSerie
                     ZX1->ZX1_DTNF   := dDataBase
                     ZX1->ZX1_STATUS := "SEM"    
                     ZX1->ZX1_TES    := SD1->D1_TES
                     ZX1->ZX1_CF     := SD1->D1_CF 
                     ZX1->ZX1_LOJA   := SD1->D1_LOJA  
                     If Alltrim(SD1->D1_P_TIPOM) == "D"
                        ZX1->ZX1_LOCAL :="03" 
                     Else
                        ZX1->ZX1_LOCAL  := SD1->D1_LOCAL
                     EndIf
                     ZX1->ZX1_NFORI  := SD1->D1_NFORI
                     ZX1->ZX1_SERIOR := SD1->D1_SERIORI   
                     cDocOri         := SD1->D1_NFORI
                     cSerieOri       := SD1->D1_SERIORI    
                        
                     ZX1->ZX1_P_MEDI  :=  SD1->D1_P_MEDIC
                     ZX1->ZX1_P_DESM  :=  SD1->D1_P_DESCM
                     ZX1->ZX1_P_PAC   :=  SD1->D1_P_PAC
                     ZX1->ZX1_P_DESP  :=  SD1->D1_P_DESCP   
                                              
                     SF4->(DbSetOrder(1))
                     If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
                        ZX1->ZX1_PODER3:=SF4->F4_PODER3
                     EndIf
                   
                     //If SD1->D1_COD <> cCod
                        Aadd(aItens,{SD1->D1_ITEM,SD1->D1_COD,Alltrim(Str(SD1->D1_QUANT)),ZX1->ZX1_DESCOD})
                       // cCod:=SD1->D1_COD 
                     //EndIf                        
               
                     ZX1->(MsUnlock())                  
                  
                     n++
                    
                  Next
                    
                  
               EndIf   
        
               SD1->(DbSkip())             
    
            EndDo
         
            If ParamIXB[2] == 1 .And. MsgYesNo("Deseja enviar e-mail para o almoxarifado","EUROSILICONE")
           
               cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
   	           cEmail += '<title>Nova pagina 1</title></head><body>'
               cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
               If cTipo $ 'B/D'
                  cEmail += 'NOTA DE DEVOLUÇÃO EUROSILICONE</b></u></font></p>'
                  cEmail += '<p><font face="Courier New" size="2">Nota de entrada:'+cDocumento+' serie: '+Alltrim(cSerie)
                  cEmail += '<p><font face="Courier New" size="2">Nota de Origem: '+Alltrim(cDocORI)+' serie: '+Alltrim(cSerieORI)
                  If !Empty(cPedido)
                     cEmail += '<p><font face="Courier New" size="2">Pedido:'+cPedido
                  EndIf
                  cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br>'     
                  cEmail += 'Cliente&nbsp;&nbsp;&nbsp;&nbsp; : '+cCli     
                  cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(cCliDesc)+'<br><p>'   
             
               Else 
                  cEmail += 'NOTA DE ENTRADA EUROSILICONE</b></u></font></p>' 
                  cEmail += '<p><font face="Courier New" size="2">Nota de entrada: '+cDocumento+' serie: '+Alltrim(cSerie)
                  cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br>'   
                  cEmail += 'Fornecedor&nbsp;&nbsp;&nbsp;&nbsp; : '+cCli     
                  cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(cCliDesc)+'<br><p>'   
               EndIf
               cEmail += 'Usuário&nbsp;&nbsp;&nbsp;&nbsp; : '+alltrim(cUserName)+'<br>'     
               cEmail += 'Data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Dtoc(date())+'<br>'
               cEmail += 'Horario&nbsp;&nbsp;&nbsp;&nbsp; : '+Time()+'<br>'
               cEmail += '<p><p>ESTRUTURA<p>'
               cEmail += '<table border="1" width="1200" style="padding: 0"><tr>'
               cEmail += '<td width="40"><font face="Courier New" size="2">Item</font></td>'
               cEmail += '<td width="113"><font face="Courier New" size="2">Produto</font></td>'     
               cEmail += '<td width="113"><font face="Courier New" size="2">QTD</font></td>'
               cEmail += '<td width="300"><font face="Courier New" size="2">Descrição</font></td>'  
               cEmail += '<td width="300"><font face="Courier New" size="2">Serie</font></td>'
   
               For i:=1 to Len(aItens)
   
                  cEmail += '	<tr>'   
                  cEmail += '		<td width="40"><font face="Courier New" size="2">'+aItens[i][1]+'</font></td>' 
                  cEmail += '		<td width="113"><font face="Courier New" size="2">'+aItens[i][2]+'</font></td>'       
                  cEmail += '		<td width="378"><font face="Courier New" size="2">'+aItens[i][3]+'</font></td>'    
                  cEmail += '		<td width="378"><font face="Courier New" size="2">'+aItens[i][4]+'</font></td>' 
                  cEmail += '		<td width="378"><font face="Courier New" size="2"><center>INCLUIR</center></font></td>'
                  cEmail += '		<td width="111" align="right">'
	              cEmail += '	</tr>'    

               Next     
   		 
               cEmail += '</table>'
               cEmail += '<br>'
               cEmail += '<br>'
               cEmail += '<br>'
               cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
               cEmail += '<p align="center">www.grantthornton.com.br</p>'
               cEmail += '</body></html>'
	  
               cFile := "\SYSTEM\"+alltrim(cDocumento)+Alltrim(cSerie)+".html"
               nHdl := FCreate( cFile )
               FWrite( nHdl,  cEmail, Len( cEmail ) )
               FClose( nHdl )      
         
               oEmail           :=  DEmail():New()
               oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
               oEmail:cTo		:=  AllTrim(GetMv("MV_P_EMAIL"))   // Ex: "tiago.mendonca@pryor.com.br"   
               If cTipo $ 'B/D'                 
                  oEmail:cSubject	:=	"Nota: " +Alltrim(cDocumento)+" Serie: "+cSerie+" incluida referente ao pedido: "+cPedido
               Else
                  oEmail:cSubject	:=	"Nota: " +Alltrim(cDocumento)+" Serie: "+cSerie+" incluida." 
               EndIf
               
               oEmail:cBody   	:= 	cEmail
               oEmail:cAnexos   :=  cFile
               oEmail:Envia()
      
               cText:="Geração de Pedido"     
               //MsgInfo("Pedido "+Alltrim(cNum)+" gerado com sucesso, enviado e-mail para o almoxerifado.","EUROsilicone")     
               FErase(cFile) 		 
	   
		   EndIf
		
		EndIf
							 
      EndIf

   EndIf
  
   If ParamIXB[1] == 5   //Exclusão
   
      If ParamIXB[2] == 1    // OK     
         
         If SD1->D1_TES $ cTES .And. SF1->F1_TIPO $ "B/D/N"   
            MsgAlert("O espelho para inclusão de serie foi apagado.","EUROSILICONE")
         EndIf
           
      ElseIf ParamIXB[2] == 0  //Cancelar
            
         //("Teste","TESTE")   
      
      EndIf
      
   EndIf

Return

/*
Funcao      : IntLogimaster()
Objetivos   : Gerar arquivo de integração da Chemtool com o armazem (Logimaster).
Autor       : Eduardo C. Romanini
Data/Hora   : 02/03/2012 
*/   
*-----------------------------*
Static Function IntLogimaster()
*-----------------------------*
Local oInt
           '
oInt := Logimaster():New()
oInt:GeraArq("NF","E") //Gera o arquivo de nota fiscal do tipo entrada.
oInt:GeraArq("PROD")   //Gera o arquivo do cadastro de produtos.

Return Nil

/*
Funcao      : CadPO()
Objetivos   : Gerar tela para inserção do número da PO que será gravada em campo customizado no F1
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2014 
*/
*-------------------*
Static Function CadPO
*-------------------*
Local cGet1:=space(20)
Local cGet2:=space(50)
Local oDlg1,oGrp1,oSay1,oGet1,oSay2,oGet2,oBtn1,oBtn2


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

If (SF1->(FieldPos("F1_P_FATUR")) > 0)
   
	oDlg1      := MSDialog():New( 227,414,400,672,"Cadastro de PO / FATURA",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 004,004,060,124,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 012,020,{||"Código PO:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 020,020,{|u| if(PCount()>0,cGet1:=u,cGet1)},oGrp1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet1",,)
	oSay2      := TSay():New( 032,020,{||"Fatura:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet2      := TGet():New( 040,020,{|u| if(PCount()>0,cGet2:=u,cGet2)},oGrp1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet2",,)
	oBtn1      := TButton():New( 064,012,"Salvar",oDlg1,{||  IIF(empty(Alltrim(cGet1)+alltrim(cGet2)),alert("Preencha algum dos campos !"),( IIF(MsgYesNo("Deseja realmente salvar estes código de PO e FATURA?"),(SalvaPO(cGet1,cGet2),oDlg1:end()),) )) },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 064,080,"Cancelar",oDlg1,{|| IIF(MsgYesNo("Deseja realmente cancelar?"),oDlg1:end(),) },037,012,,,,.T.,,"",,,,.F. )

Else

	oDlg1      := MSDialog():New( 227,514,352,772,"Cadastro de PO",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 004,004,040,124,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 012,020,{||"Código PO:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 020,020,{|u| if(PCount()>0,cGet1:=u,cGet1)},oGrp1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet1",,)
	oBtn1      := TButton():New( 044,012,"Salvar",oDlg1,{||  IIF(empty(cGet1),alert("Preencha o campo código!"),( IIF(MsgYesNo("Deseja realmente salvar este código de PO?"),(SalvaPO(cGet1),oDlg1:end()),) )) },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 044,080,"Cancelar",oDlg1,{|| IIF(MsgYesNo("Deseja realmente cancelar?"),oDlg1:end(),) },037,012,,,,.T.,,"",,,,.F. )

EndIf

oDlg1:Activate(,,,.T.)

Return

/*
Funcao      : SalvaPO()
Objetivos   : Grava em campo customizado no F1 o número da PO
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2014 
*/
*-------------------------------------*
Static Function SalvaPO(cGet1,cGet2)
*------------------------------------*	
	
	if SF1->(FieldPos("F1_P_PO"))>0
		RecLock("SF1",.F.)
			SF1->F1_P_PO:=cGet1
		MsUnLock()
	endif       
	
	If SF1->(FieldPos("F1_P_FATUR"))>0
		RecLock("SF1",.F.)
			SF1->F1_P_FATUR:=cGet2
		MsUnLock()
	Endif       

	       
Return

/*
Função  : GrvProfSX1()
Objetivo: Altera o valor do pergunte no SX1
Autor   : Renato Rezende
Data    : 04/09/2014
*/
*-------------------------------------------------*
 Static Function GrvProfSX1(cGrupo,cPerg,xValor)
*-------------------------------------------------*
Local cUserName := ""
Local cMemoProf := ""
Local cLinha    := ""

Local nLin := 0

Local aLinhas := {}

cGrupo := PadR(cGrupo,Len(SX1->X1_GRUPO)," ")

SX1->(DbSetOrder(1))
If SX1->(DbSeek(cGrupo+cPerg,.F.))

	If Type("__cUserId") == "C" .and. !Empty(__cUserId)
		PswOrder(1)
  		PswSeek(__cUserID)
		cUserName := cEmpAnt+PswRet(1)[1,2]
	    
		//Pesquisa o pergunte no Profile
		If FindProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")
            
			//Armazena o memo de parametros do pergunte
			cMemoProf := RetProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")

			//Gera array com todas as linhas dos parametros	        
			For nLin:=1 To MlCount(cMemoProf)
				aAdd(aLinhas,AllTrim(MemoLine(cMemoProf,,nLin))+ CHR(13) + CHR(10))
			Next
			
			//Guarda o back-up do valor do parâmetro selecionado
			xPreSel := Substr(aLinhas[Val(cPerg)],5,1) 
			
			//Monta uma linha com o novo conteudo do parametro atual.
			// Pos 1 = tipo (numerico/data/caracter...)
			// Pos 2 = '#'
			// Pos 3 = GSC
			// Pos 4 = '#'
			// Pos 5 em diante = conteudo.
            cLinha = SX1->X1_TIPO + "#" + SX1->X1_GSC + "#" + If(SX1->X1_GSC == "C", cValToChar(xValor),AllTrim(Str(xValor)))+ CHR(13) + CHR(10)
			
			//Grava a linha no array
			aLinhas[Val(cPerg)] = cLinha
			
			//Monta o memo atualizado
			cMemoProf := ""
			For nLin:=1 To Len(aLinhas)
   				cMemoProf += aLinhas[nLin]
       		Next
            
			//Grava o profile com o novo memo
			WriteProfDef(cUserName,cGrupo,"PERGUNTE", "MV_PAR", ; 	// Chave antiga
                    	 cUserName,cGrupo, "PERGUNTE", "MV_PAR", ; 	// Chave nova
     					 cMemoProf) 								// Novo conteudo do memo.
			
		//Caso não exista Profile alterar o SX1
		Else
			//Gravando conteudo antigo
			xPresel:= SX1->X1_PRESEL
			Do Case
				Case SX1->X1_GSC == "C"
					Reclock ("SX1",.F.)
					SX1->X1_PRESEL := Val(cValToChar(xValor))
					SX1->(MsUnlock())
			EndCase
		EndIf
	EndIf
EndIf

Return Nil
