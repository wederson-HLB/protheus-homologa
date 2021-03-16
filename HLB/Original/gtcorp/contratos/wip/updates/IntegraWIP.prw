#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"

#DEFINE ENTER chr(13)+chr(10)

*------------------------*
User Function IntegraWIP()
*------------------------*
Local cFile    := "D:\wip.csv"
Local cNomeArq := ""
Local cLog     := ""
Local cDest    := "\bkp\"

Local aIntWIP := {}

If !MsgYesNo("Confirma inicio da integração de propostas WIP?")
	Return Nil
EndIf

If !File(cFile)
	MsgInfo("O arquivo "+cFile+" não foi encontrado!" ,"Arquivo")      
	Return .F.
EndIf

cNomeArq := RetFileName(cFile)
     
//verifica se existe o arquivo na pasta temporaria e apaga
If File(cDest+cNomeArq)
	fErase(cDest+cNomeArq)
EndIf                 
   
//Copia o arquivo XLS para o Temporario para ser executado
If !CpyT2S(cFile,cDest,.T.) 
	MsgInfo("Problemas na copia do arquivo "+cFile+" para "+cDest,"CpyT2S()")
	Return .F.
EndIf          

cArq := cDest+cNomeArq+".csv"

//Carrega o array baseado na planilha
Processa( {|| aIntWIP:= CargaArray(AllTrim(cArq)) } ,;
            "Aguarde, carregando planilha..."+ENTER+"Pode demorar...") 

If Len(aIntWIP) > 0
	
	Processa( {|| cLog := IntegraArq(aIntWIP) } ,;
            "Aguarde, gravando dados..."+ENTER+"Pode demorar...") 
	
    ExibeLog(cLog)
Else
	MsgInfo("A planilha não possui dados para integração.","Atenção")
EndIf

Return Nil

*------------------------------*
Static Function CargaArray(cArq)
*------------------------------*
Local cLinha  := ""
Local nLin    := 1 
Local nLinTit := 1
Local nTotLin := 0
Local aDados  := {}
Local cFile   := cArq
Local nHandle := 0

//abre o arquivo csv gerado na temp
nHandle := Ft_Fuse(cFile)
If nHandle == -1
   Return aDados
EndIf
Ft_FGoTop()                                                         
nLinTot := FT_FLastRec()
ProcRegua(nLinTot)

//Pula as linhas de cabeçalho
While nLinTit > 0 .AND. !Ft_FEof()
   Ft_FSkip()
   nLinTit--
EndDo

//percorre todas linhas do arquivo csv
Do While !Ft_FEof()
   //exibe a linha a ser lida
   IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
   nLin++
   //le a linha
   cLinha := Ft_FReadLn()
   //verifica se a linha está em branco, se estiver pula
   If Empty(AllTrim(StrTran(cLinha,';','')))
      Ft_FSkip()
      Loop
   EndIf

   //Trata os caracteres estranhos
   cLinha := StrTran(cLinha,"´","")
   
   //transforma as aspas duplas em aspas simples
   cLinha := StrTran(cLinha,'"',"'")
   cLinha := '{"'+cLinha+'"}' 
   //adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
   cLinha := StrTran(cLinha,';','","')
   aAdd(aDados, &cLinha)
   
   //passa para a próxima linha
   FT_FSkip()
   //
EndDo

//libera o arquivo CSV
FT_FUse()             

//Exclui o arquivo csv
If File(cFile)
   FErase(cFile)
EndIf

Return aDados

*---------------------------------*
Static Function IntegraArq(aIntWIP)
*---------------------------------*
Local cLog      := ""
Local cLogValid := ""
Local cLogErro  := ""
Local cLogGrv   := ""

Local cFaturar  := ""
Local cContrato := ""
Local cPropSis  := ""
Local cTipoPro  := ""
Local cCpfSocio := ""
Local cDivisao  := ""
Local cNatureza := ""
Local cCpfSoCli := ""
Local cDespAlim := ""
Local cDespHosp := ""
Local cDespPAe  := ""
Local cDespEst  := ""
Local cDespDesl := ""
Local cMoeda    := ""
Local cHoras    := ""
Local cTxMedia  := ""
Local cRecuper  := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local cVlTotal  := ""
Local cGrupo    := ""

Local nI := 0
Local nX := 0    

Local aZB01 := {} //Auditores SP
Local aZB02 := {} //Auditores RJ
Local aZB03 := {} //Auditores CP
Local aZB04 := {} //Auditores POA
Local aZB05 := {} //Auditores GO
Local aZB06 := {} //Auditores MG
Local aZF01 := {} //Corporate SP
Local aZF02 := {} //Corporate BH

For nI:=1 To Len(aIntWIP)
    
	IncProc("Carregando Linha "+AllTrim(Str(nI))+" de "+AllTrim(Str(Len(aIntWIP))))

	//Carrega as variaveis
	cTipoPro  := Upper(AllTrim(aIntWIP[nI][02]))
	cFaturar  := Upper(AllTrim(aIntWIP[nI][03]))
    cCpfSocio := StrZero(Val(aIntWIP[nI][07]),11)
	cMoeda    := Upper(AllTrim(aIntWIP[nI][10]))
	cVlTotal  := AllTrim(aIntWIP[nI][11])
    cDivisao  := Upper(AllTrim(aIntWIP[nI][15]))
	cNatureza := Upper(AllTrim(aIntWIP[nI][16]))
    cHoras    := AllTrim(aIntWIP[nI][17])
    cTxMedia  := AllTrim(aIntWIP[nI][18])
    cRecuper  := AllTrim(aIntWIP[nI][19])
    cDataIni  := AllTrim(aIntWIP[nI][20])
    cDataFim  := AllTrim(aIntWIP[nI][21])
    cCpfSoCli := StrZero(Val(aIntWIP[nI][41]),11)    
    cDespAlim := Upper(AllTrim(aIntWIP[nI][42]))
	cDespHosp := Upper(AllTrim(aIntWIP[nI][43]))
	cDespPAe  := Upper(AllTrim(aIntWIP[nI][44]))
	cDespEst  := Upper(AllTrim(aIntWIP[nI][45]))
	cDespDesl := Upper(AllTrim(aIntWIP[nI][46]))
    cContrato := StrZero(Val(aIntWIP[nI][47]),15)
	cPropSis  := Upper(AllTrim(aIntWIP[nI][48]))
	cGrupo    := Upper(AllTrim(aIntWIP[nI][49]))
   
	/////////////////////////////////////////
	//Validação de informações obrigatórias//
	/////////////////////////////////////////

	//Valida o tipo da proposta
	If Empty(cTipoPro)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de tipo da proposta." + ENTER
		Loop
	ElseIf cTipoPro <> "AUDIT" .and. cTipoPro <> "ADVISORY" .and. cTipoPro <> "TAX"  
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de tipo da proposta incorreto." + ENTER
		Loop
	EndIf

	//Valida se o CPF do sócio foi informado
	If Empty(cCpfSocio)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Sócio da Proposta." + ENTER
		Loop
	EndIf	
    
	//Valida a Moeda
	If !Empty(cMoeda) .and. cMoeda <> "REAL" .and. cMoeda <> "DOLAR" .and.;
	                        cMoeda <> "LIBRA" .and. cMoeda <> "EURO" .and.;
							cMoeda <> "DOLAR CANADENSE"
		
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Moeda incorreta." + ENTER
		Loop
    EndIf
    
	//Valida o valor Total
    If Empty(cVlTotal) .and. cTipoPro <> "TAX"  
    	cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Valor Total." + ENTER
		Loop   
    EndIf

	lErro := .F.
    If !Empty(cVlTotal)
	    For nX:=Len(cVlTotal) To 1 Step -1
    		If !(Substr(cVlTotal,nX,1) $ "0123456789,.") 
    		    lErro := .T.
    		    Exit
			EndIf    	
		Next
		
		If lErro
		    cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Valor Total incorretas." + ENTER
			Loop 		
		EndIf
	EndIf	

	//Valida se a Divisão foi informada.
	If Empty(cDivisao)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Divisao do Serviço." + ENTER
		Loop
	
	ElseIf cDivisao <> "ASSURANCE" .and. cDivisao <> "TAX - IMPOSTOS DIRETOS" .and.;
		   cDivisao <> "TAX - IMPOSTOS INDIRETOS" .and. cDivisao <> "TAX - TRABALHISTA/PREV." .and.; 
		   cDivisao <> "TAX - INTERNATIONAL" .and. cDivisao <> "TAX - EXPATRIADOS" .and.;
		   cDivisao <> "ITS - INFORMATION TECHNOLOGY" .and. cDivisao <> "BRS - BUSSINESS RISK SERVICES" .and.;
		   cDivisao <> "TAS - TRANSACTION ADV. SERV." .and. cDivisao <> "BAS - BUSSINESS ADV. SERV."
	
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Divisao Incorreta." + ENTER
		Loop	   
	EndIf	
    
	//Valida se a Natureza foi informada.
	If Empty(cNatureza)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Natureza do Serviço." + ENTER
		Loop

	ElseIf cNatureza <> "COM EMISSÃO DE PARECER" .and. cNatureza <> "SEM EMISSÃO DE PARECER" .and.;
	       cNatureza <> "ESPECIAL" .and. cNatureza <> "SUPORT AUDIT" .and.;
		   cNatureza <> "COMPLIANCE" .and. cNatureza <> "CONSULTORIA" .and.;
	       cNatureza <> "REVISÃO" .and. cNatureza <> "DUE DILIGENCE" .and.;
	       cNatureza <> "CORPORATE FINANCE"
	       
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza Incorreta." + ENTER
		Loop      
    
	Else
	
		If cNatureza == "COM EMISSÃO DE PARECER"
			        
			If cDivisao <> "ASSURANCE"           
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf

		ElseIf cNatureza == "SEM EMISSÃO DE PARECER"
        
  			If cDivisao <> "ASSURANCE"           
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
        
		ElseIf cNatureza == "ESPECIAL"

  			If cDivisao <> "ASSURANCE"           
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf

		ElseIf cNatureza == "SUPORT AUDIT"

  			If cDivisao <> "TAX - IMPOSTOS DIRETOS" .and. cDivisao <> "TAX - IMPOSTOS INDIRETOS" .and.;
  		       cDivisao <> "TAX - TRABALHISTA/PREV." .and. cDivisao <> "TAX - INTERNATIONAL" .and.;
               cDivisao <> "ITS - INFORMATION TECHNOLOGY" .and. cDivisao <> "BRS - BUSSINESS RISK SERVICES" .and.;
  			   cDivisao <> "BAS - BUSSINESS ADV. SERV." .and. cDivisao <> "TAS - TRANSACTION ADV. SERV."
  			
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
		
		ElseIf cNatureza == "COMPLIANCE"

  			If cDivisao <> "TAX - TRABALHISTA/PREV." .and. cDivisao <> "TAX - EXPATRIADOS" .and.;
  			   cDivisao <> "ITS - INFORMATION TECHNOLOGY" .and. cDivisao <> "BRS - BUSSINESS RISK SERVICES" .and.;
  			   cDivisao <> "BAS - BUSSINESS ADV. SERV."
  			   
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
		
		ElseIf cNatureza == "CONSULTORIA"
        
  			If cDivisao <> "TAX - IMPOSTOS DIRETOS" .and. cDivisao <> "TAX - IMPOSTOS INDIRETOS" .and.;
  		       cDivisao <> "TAX - TRABALHISTA/PREV." .and. cDivisao <> "TAX - INTERNATIONAL" .and.;
               cDivisao <> "ITS - INFORMATION TECHNOLOGY" .and. cDivisao <> "BRS - BUSSINESS RISK SERVICES" .and.;
  			   cDivisao <> "TAS - TRANSACTION ADV. SERV." .and. cDivisao <> "BAS - BUSSINESS ADV. SERV." .and.;
  			   cDivisao <> "TAX - EXPATRIADOS"
  			
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
        
		ElseIf cNatureza == "REVISÃO"
        
  			If  cDivisao <> "TAX - IMPOSTOS DIRETOS" .and. cDivisao <> "TAX - IMPOSTOS INDIRETOS" .and.;
    			cDivisao <> "TAX - INTERNATIONAL"
    			
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
        
		ElseIf cNatureza == "DUE DILIGENCE"
        
  			If cDivisao <> "TAS - TRANSACTION ADV. SERV."           
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
        
		ElseIf cNatureza == "CORPORATE FINANCE"
			
			If cDivisao <> "TAS - TRANSACTION ADV. SERV."           
				cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza não relacionada a Divisão." + ENTER
				Loop      
			EndIf
		
		Else
			cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Natureza Incorreta." + ENTER
			Loop      
		EndIf

	EndIf
    
    //Valida as horas previstas
    If Empty(cHoras) .and. cTipoPro <> "TAX"  
    	cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Horas Previstas." + ENTER
		Loop   
    EndIf

	lErro := .F.
    If !Empty(cHoras)
	    For nX:=Len(cHoras) To 1 Step -1
    		If !(Substr(cHoras,nX,1) $ "0123456789,.") 
    		    lErro := .T.
    		    Exit
			EndIf    	
		Next
		
		If lErro
		    cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Horas Previstas incorretas." + ENTER
			Loop 		
		EndIf
	EndIf
    
    //Valida a Taxa Média
    If Empty(cTxMedia) .and. cTipoPro <> "TAX"  
    	cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Taxa Média." + ENTER
		Loop   
    EndIf
    
  	lErro := .F.
    If !Empty(cTxMedia)
	    For nX:=Len(cTxMedia) To 1 Step -1
	    	If !(Substr(cTxMedia,nX,1) $ "0123456789,.") 
	    	    lErro := .T.
    		    Exit
			EndIf    	
		Next
		
		If lErro
	 		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Taxa Média incorretas." + ENTER
			Loop 		
		EndIf
    EndIf
    
    //Valida a Recuperação
	/*
	If Empty(cRecuper) 
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de % de Recuperação." + ENTER
		Loop   		
	EndIf

  	lErro := .F. 
 	If !Empty(cRecuper)
	    For nX:=Len(cRecuper) To 1 Step -1
	    	If !(Substr(cRecuper,nX,1) $ "0123456789,.%") 
				lErro := .T.
    		    Exit
			EndIf    	
		Next
		
		If lErro
			cLogValid += "Linha "+AllTrim(Str(nX))+" possui informação de % de Recuperação incorreta." + ENTER
			Loop 
		EndIf
    EndIf 
    */
    
    //Valida a data inicial
    If Empty(cDataIni)
    	cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Data de Inicio." + ENTER
		Loop   	
    Else
    	cDataIni := StrTran(cDataIni,".","/")
    	cDataIni := StrTran(cDataIni,"-","/")
    	
   	  	lErro := .F. 
    	For nX:=Len(cDataIni) To 1 Step -1
	    	If !(Substr(cDataIni,nX,1) $ "0123456789/") 
				lErro := .T.
    		    Exit		
			EndIf    	
		Next
	
		If lErro	
			cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Data de Inicio incorreta." + ENTER
			Loop 
		EndIf
		
    EndIf
    
    //Valida a data final prevista
    If Empty(cDataFim)
    	cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Data Final prevista." + ENTER
		Loop   	
    Else
    	cDataFim := StrTran(cDataFim,".","/")
    	cDataFim := StrTran(cDataFim,"-","/")

   	  	lErro := .F. 
    	For nX:=Len(cDataFim) To 1 Step -1
	    	If !(Substr(cDataFim,nX,1) $ "0123456789/") 
	    	    lErro := .T.
	    	    Exit		
			EndIf    	
		Next
		
		If lErro	
			cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Data Final prevista incorreta." + ENTER
			Loop 	
		EndIf
    EndIf
     
	//Valida se o Sócio do Cliente foi informado.
	If Empty(cCpfSoCli)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Sócio do Cliente." + ENTER
		Loop
	EndIf	
    
	//Valida se a Despesa de Alimentação foi informada
	If Empty(cDespAlim)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Despesa de Alimentação." + ENTER
		Loop
	ElseIf cDespAlim <> "REEMBOLSÁVEL" .and. cDespAlim <> "NÃO REEMBOLSÁVEL" .and. cDespAlim <> "N/A" 
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Despesa de Alimentação incorreta." + ENTER
		Loop
	EndIf

    //Valida se a Despesa de Hospedagem foi informada
	If Empty(cDespHosp)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Despesa de Hospedagem." + ENTER
		Loop
	ElseIf cDespHosp <> "REEMBOLSÁVEL" .and. cDespHosp <> "NÃO REEMBOLSÁVEL" .and. cDespHosp <> "N/A" 
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Despesa de Hospedagem incorreta." + ENTER
		Loop
	EndIf 

    //Valida se a Despesa de Passagem Aerea foi informada
	If Empty(cDespPAe)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Despesa de Passagem Aerea." + ENTER
		Loop
	ElseIf cDespPAe <> "REEMBOLSÁVEL" .and. cDespPAe <> "NÃO REEMBOLSÁVEL" .and. cDespPAe <> "N/A" 
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Despesa de Passagem Aerea incorreta." + ENTER
		Loop
	EndIf 

    //Valida se a Despesa de Estacionamento foi informada
	If Empty(cDespEst)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Despesa de Estacionamento." + ENTER
		Loop
	ElseIf cDespEst <> "REEMBOLSÁVEL" .and. cDespEst <> "NÃO REEMBOLSÁVEL" .and. cDespEst <> "N/A" 
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Despesa de Estacionamento incorreta." + ENTER
		Loop
	EndIf 

    //Valida se a Despesa de Deslocamento foi informada
	If Empty(cDespDesl)
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de Despesa de Deslocamento." + ENTER
		Loop
	ElseIf cDespDesl <> "REEMBOLSÁVEL" .and. cDespDesl <> "NÃO REEMBOLSÁVEL" .and. cDespDesl <> "N/A" 
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de Despesa de Deslocamento incorreta." + ENTER
		Loop
	EndIf 

	//Valida se existe contrato.
	If Empty(cContrato) .and. cGrupo <> "GRUPO"
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de contrato." + ENTER
		Loop
	EndIf	
	
	//Valida se existe numero de proposta no sistema.
	If Empty(cPropSis) .and. cGrupo == "GRUPO"
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de proposta no sistema." + ENTER
		Loop
	EndIf	
    
	If !Empty(cGrupo) .and. cGrupo <> "GRUPO"
		cLogValid += "Linha "+AllTrim(Str(nI))+" possui informação de grupo incorreto." + ENTER
		Loop
	EndIf

	///////////////////////////////
	//Separa as linhas por filial//
	///////////////////////////////
	If cFaturar == 	"GT AUDITORES SP"
    	aAdd(aZB01,aIntWIP[nI])
	ElseIf cFaturar == 	"GT AUDITORES RJ"
    	aAdd(aZB02,aIntWIP[nI])
	ElseIf cFaturar == 	"GT AUDITORES CP"
	    aAdd(aZB03,aIntWIP[nI])
	ElseIf cFaturar == 	"GT AUDITORES POA"
    	aAdd(aZB04,aIntWIP[nI])
	ElseIf cFaturar == 	"GT AUDITORES GO"
    	aAdd(aZB05,aIntWIP[nI])
	ElseIf cFaturar == 	"GT AUDITORES BH"
    	aAdd(aZB06,aIntWIP[nI])
	ElseIf cFaturar == 	"GT CORPORATE"
    	aAdd(aZF01,aIntWIP[nI])
	Else
		cLogValid += "Linha "+AllTrim(Str(nI))+" não possui informação de local de faturamento." + ENTER
		Loop				
	EndIf
Next

//Valida o preenchimento dos arrays.
If Len(aZB01) == 0 .and. Len(aZB02) == 0 .and. Len(aZB03) == 0 .and.;
   Len(aZB04) == 0 .and. Len(aZB05) == 0 .and. Len(aZB06) == 0 .and.;
   Len(aZF01) == 0 .and. Len(aZF02) == 0
	
	cLogValid += "Não foi informada a empresa e filial de faturamento em nenhuma linha." + ENTER
EndIf   

//////////////////////////////////////////////
//Inicio da gravação da empresa Auditores-SP//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZB" FILIAL "01"    

For nI:=1 To Len(aZB01)

	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Auditores SP")
     
    Begin Transaction
    	
    	GravaCapa(aZB01[nI],@cLogErro,@cLogGrv)
    
    End Transaction

Next

RESET ENVIRONMENT

//////////////////////////////////////////////
//Inicio da gravação da empresa Auditores-RJ//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZB" FILIAL "02"    

For nI:=1 To Len(aZB02)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Auditores RJ")
     
    Begin Transaction
    
    	GravaCapa(aZB02[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT

//////////////////////////////////////////////
//Inicio da gravação da empresa Auditores-CP//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZB" FILIAL "03" 

For nI:=1 To Len(aZB03)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Auditores CP")
	
    Begin Transaction
    
    	GravaCapa(aZB03[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT 

///////////////////////////////////////////////
//Inicio da gravação da empresa Auditores-POA//
///////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZB" FILIAL "04"

For nI:=1 To Len(aZB04)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Auditores POA")
    
    Begin Transaction
    
    	GravaCapa(aZB04[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT

//////////////////////////////////////////////
//Inicio da gravação da empresa Auditores-GO//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZB" FILIAL "05" 

For nI:=1 To Len(aZB05)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Auditores GO")
    
    Begin Transaction
    
    	GravaCapa(aZB05[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT
//////////////////////////////////////////////
//Inicio da gravação da empresa Auditores-BH//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZB" FILIAL "06"

For nI:=1 To Len(aZB06)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Auditores BH")
	
	Begin Transaction
    
    	GravaCapa(aZB06[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT
//////////////////////////////////////////////
//Inicio da gravação da empresa Corporate SP//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZF" FILIAL "01" 
For nI:=1 To Len(aZF01)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Corporate")
	
    Begin Transaction
    
    	GravaCapa(aZF01[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT
//////////////////////////////////////////////
//Inicio da gravação da empresa Corporate BH//
//////////////////////////////////////////////
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "ZF" FILIAL "02" 

For nI:=1 To Len(aZF02)
	
	IncProc("Gravando Linha "+AllTrim(Str(nI))+" de Corporate BH")
	
    Begin Transaction
    
    	GravaCapa(aZF02[nI],@cLogErro,@cLogGrv)

    End Transaction

Next

RESET ENVIRONMENT

/////////////////////
//Tratamento do Log//
/////////////////////

cLog += "--------------------------------------------" + ENTER
cLog += "Log de Integração de dados de propostas WIP." + ENTER
cLog += "Data: "+DtoC(dDataBase) + "Hora: " + Time()   + ENTER
cLog += "--------------------------------------------" + ENTER

If !Empty(cLogValid)
	cLog += ENTER
	cLog += "Mensagens de validação de dados da planilha: " + ENTER
	cLog += "---------------------------------------------" + ENTER
	cLog += cLogValid
EndIf

If !Empty(cLogErro)
	cLog += ENTER
	cLog += "Mensagens de erro de integração dos dados: " + ENTER
	cLog += "---------------------------------------------" + ENTER
	cLog += cLogErro
EndIf

If !Empty(cLogGrv)
	cLog += ENTER
	cLog += "Mensagens de exito na integração: " + ENTER
	cLog += "---------------------------------------------" + ENTER
	cLog += cLogGrv
EndIf

cLog += ENTER
cLog += "---------------------------------------------" + ENTER
cLog += "Fim do Log" + ENTER
cLog += "---------------------------------------------" 

Return cLog     

*----------------------------*
Static Function ExibeLog(cLog)
*----------------------------*
Local cFile :="" 
Local cMask := "Arquivos Texto (*.TXT) |*.txt|"

Local oFont
Local oMemo

__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cLog)

Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

@ 5,5 Get oMemo  Var cLog MEMO Size 200,145 Of oDlg Pixel
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cLog))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
Activate MsDialog oDlg Center

Return Nil

*------------------------------------------------*
Static Function GravaCapa(aLinha,cLogErro,cLogGrv)
*------------------------------------------------*
Local cContrato := ""
Local cProposta := ""
Local cPropSis  := ""
Local cFaturar  := ""
Local cCodCli   := ""
Local cLojCli   := ""
Local cTipoPro  := ""
Local cCodTipo  := ""
Local cCpfSocio := ""
Local cNomeSocio:= "" 
Local cCpfGer   := ""
Local cNomeGer  := ""
Local cCodResp  := ""
Local cNomResp  := ""
Local cDivisao  := ""
Local cNatureza := ""
Local cCodDiv   := ""
Local cCodNat   := ""
Local cHoras    := ""
Local cTxMedia  := ""
Local cRecuper  := ""
Local cDataIni  := "" 
Local cDataFim  := ""
Local cVlTotal  := ""
Local cAuxCNF   := ""
Local cDespAlim := ""
Local cDespHosp := ""
Local cDespPAe  := ""
Local cDespEst  := ""
Local cDespDesl := ""
Local cCpfSoCli := ""
Local cGrupo    := ""
Local cBanco    := "MSSQL/Controle"
Local cIp       := "10.0.30.5"

Local nTotCtr   := 0
Local nHoras    := 0
Local nTxMedia  := 0
Local nRecuper  := 0
Local nVlTotal  := 0
Local nSurcha   := 0
Local nVlSurCtr := 0
Local nVlSerCtr := 0
Local nTotLiqSur:= 0
Local nTotLiq   := 0
Local nVlCheio  := 0
Local nItem     := 0

Local dDataIni
Local dDataFim

Local aGrupo := {}

//Carrega as variaveis
cProposta := Upper(AllTrim(aLinha[01]))
cTipoPro  := Upper(AllTrim(aLinha[02]))
cFaturar  := Upper(AllTrim(aLinha[03]))
cNomeGer  := AllTrim(aLinha[04])
cCpfGer   := StrZero(Val(aLinha[05]),11)
cNomeSocio:= AllTrim(aLinha[06])
cCpfSocio := StrZero(Val(aLinha[07]),11)
cMoeda    := Upper(AllTrim(aLinha[10]))
cVlTotal  := AllTrim(aLinha[11])
cDivisao  := TrataAcento(Upper(AllTrim(aLinha[15])))
cNatureza := TrataAcento(Upper(AllTrim(aLinha[16])))
cHoras    := AllTrim(aLinha[17])
cTxMedia  := AllTrim(aLinha[18])
cRecuper  := AllTrim(aLinha[19])
cDataIni  := AllTrim(aLinha[20])
cDataFim  := AllTrim(aLinha[21])
cCpfSoCli := StrZero(Val(aLinha[41]),11)    
cDespAlim := Upper(AllTrim(aLinha[42]))
cDespHosp := Upper(AllTrim(aLinha[43]))
cDespPAe  := Upper(AllTrim(aLinha[44]))
cDespEst  := Upper(AllTrim(aLinha[45]))
cDespDesl := Upper(AllTrim(aLinha[46]))
cContrato := StrZero(Val(aLinha[47]),15)
cPropSis  := Upper(AllTrim(aLinha[48]))
cGrupo    := Upper(AllTrim(aLinha[49]))

//Valida a Proposta
Z55->(DbSetOrder(2))
If Z55->(DbSeek(xFilial("Z55")+cPropSis))
	cLogGrv += "A Proposta:"+cProposta+", já está cadastrada no sistema." + ENTER
	Return
EndIf

//Carrega o tipo da proposta
If cTipoPro == "AUDIT" 
	cCodTipo := "1"
ElseIf cTipoPro == "TAX" 
	cCodTipo := "2"
ElseIf cTipoPro == "ADVISORY"
	cCodTipo := "3"
EndIf

If Select("TMPCN9") > 0
	TMPCN9->(DbCloseArea())
EndIf

If cGrupo == "GRUPO"
	BeginSql Alias 'TMPCN9'
		SELECT CN9_NUMERO,CN9_P_NUM,CN9_CLIENT,CN9_LOJACL,CN9_P_QTHR,CN9_VLINI
        FROM %table:CN9%
        WHERE %notDel%
          AND CN9_FILIAL = %xFilial:CN9%
          AND CN9_SITUAC = '05'
          AND CN9_P_NUM = %exp:cPropSis%
		ORDER BY CN9_NUMERO	
	EndSql

Else
	BeginSql Alias 'TMPCN9'
		SELECT CN9_NUMERO,CN9_P_NUM,CN9_CLIENT,CN9_LOJACL,CN9_P_QTHR,CN9_VLINI
        FROM %table:CN9%
        WHERE %notDel%
          AND CN9_FILIAL = %xFilial:CN9%
          AND CN9_SITUAC in ('05','08')
          AND CN9_NUMERO = %exp:cContrato%
		ORDER BY CN9_NUMERO	
	EndSql
EndIf

//Valida o contrato
TMPCN9->(DbGoTop())
If TMPCN9->(EOF() .or. BOF())

	If cGrupo == "GRUPO"
		cLogErro += "A Proposta:"+cProposta+", não possui contratos vigentes no sistema." + ENTER
		Return
	Else
		cLogErro += "O contrato "+cContrato+" da Proposta:"+cProposta+", não está vigente no sistema." + ENTER
		Return
	EndIf
EndIf

While TMPCN9->(!EOF())
	
	//Carrega o contrato
	cContrato := AllTrim(TMPCN9->CN9_NUMERO)

	//Carrega a proposta do sistema
	cPropSis := Upper(AllTrim(TMPCN9->CN9_P_NUM))

	//Retorna o valor total
	nTotCtr += TMPCN9->CN9_VLINI

	//Retorna os valores das planilhas dos contratos
	CNB->(DbSetOrder(1))
	If CNB->(DbSeek(xFilial("CNB")+cContrato))
		While CNB->(!EOF()) .and. CNB->(CNB_FILIAL+CNB_CONTRA) == xFilial("CNB")+cContrato
		    
			//Surcharge
			If AllTrim(CNB->CNB_PRODUT) == "500057" .or. AllTrim(CNB->CNB_PRODUT) == "600057"
				nVlSurCtr += CNB->CNB_VLTOT
	
			//Serviços
			Else
				nVlSerCtr += CNB->CNB_VLTOT
			EndIf
					
			CNB->(DbSkip())	
		EndDo
	EndIf
	
	//Carrega o grupo
	aAdd(aGrupo,{cContrato,TMPCN9->CN9_CLIENT,TMPCN9->CN9_LOJACL,TMPCN9->CN9_P_QTHR,TMPCN9->CN9_VLINI})	
	
	TMPCN9->(DbSkip())
EndDo

TMPCN9->(DbCloseArea())

//Carrega o contrato
cContrato := AllTrim(aGrupo[1][1])

//Retorna o cliente (Sempre o primeiro do grupo)
cCodCli := AllTrim(aGrupo[1][2])
cLojCli := AllTrim(aGrupo[1][3])

//Valida o cliente
SA1->(DbSetOrder(1))
If !SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	cLogErro += "O contrato "+cContrato+" da Proposta:"+cProposta+", não possui cliente cadastrado no sistema." + ENTER
	Return
EndIf

//Valida o sócio
Z42->(DbSetOrder(2))
If !Z42->(DbSeek(xFilial("Z42")+cCpfSocio))
	cLogErro += "O sócio "+cNomeSocio+" da Proposta:"+cProposta+", não está cadastrado no controle de alçada." + ENTER
	Return
Else
	cNomeSocio := AllTrim(Z42->Z42_NOMEFU)
	cCodResp   := AllTrim(Z42->Z42_IDUSER)
	cNomResp   := AllTrim(Z42->Z42_NOUSER)
EndIf

//Valida o gerente
If cCpfGer <> "00000000000"
	Z42->(DbSetOrder(2))
	If !Z42->(DbSeek(xFilial("Z42")+cCpfGer))
		cLogErro += "O gerente "+cNomeGer+" da Proposta:"+cProposta+", não está cadastrado no controle de alçada." + ENTER
		Return
	Else
		cNomeGer := AllTrim(Z42->Z42_NOMEFU)
	EndIf
Else
	cCpfGer  := ""
	cNomeGer := ""
EndIf

//Valida a divisão
BeginSql Alias 'TMPZ58'
	SELECT Z58_CODIGO
	FROM %table:Z58%
	WHERE %notDel%
	  AND UPPER(Z58_DESCRI) = %exp:cDivisao%
	  AND Z58_TIPO = %exp:cCodTipo%
EndSql

TMPZ58->(DbGoTop())
If TMPZ58->(!EOF() .and. !BOF())
	cCodDiv := AllTrim(TMPZ58->Z58_CODIGO)
EndIf

TMPZ58->(DbCloseArea())

If Empty(cCodDiv)
	cLogErro += "A divisão "+cDivisao+" da Proposta:"+cProposta+", não está cadastrada no sistema." + ENTER
	Return
EndIf

//Valida a natureza
BeginSql Alias 'TMPZ57'
	SELECT Z57_CODIGO
	FROM %table:Z57%
	WHERE %notDel%
	  AND UPPER(Z57_DESCRI) = %exp:cNatureza%
	  AND Z57_CODDIV = %exp:cCodDiv%
EndSql

TMPZ57->(DbGoTop())
If TMPZ57->(!EOF() .and. !BOF())
	cCodNat := AllTrim(TMPZ57->Z57_CODIGO)
EndIf

TMPZ57->(DbCloseArea())

If Empty(cCodNat)
	cLogErro += "A natureza "+cNatureza+" da Proposta:"+cProposta+", não está cadastrada no sistema." + ENTER
	Return
EndIf


//Trata as horas
If Len(aGrupo) > 1

	nHoras := 0
	For nI:=1 To Len(aGrupo)
	    nHoras += Val(aGrupo[nI][4])
	Next
Else
	//Trata as horas
	cHoras := StrTran(cHoras,".","")
	cHoras := StrTran(cHoras,",",".")
	nHoras := Val(cHoras)
EndIf
nHoras := round(nHoras,2)

//Trata a Taxa Média
cTxMedia := StrTran(cTxMedia,".","")
cTxMedia := StrTran(cTxMedia,",",".")
nTxMedia := Val(cTxMedia)
nTxMedia := round(nTxMedia,2)

//Trata a % de Recuperação
If Empty(cRecuper)
	nRecuper := 50
Else
	cRecuper := StrTran(cRecuper,"%","")
	cRecuper := StrTran(cRecuper,".","")
	cRecuper := StrTran(cRecuper,",",".")
	nRecuper := Int(Val(cRecuper))
EndIf

//Trata o valor total
cVlTotal := StrTran(cVlTotal,".","")
cVlTotal := StrTran(cVlTotal,",",".")
nVlTotal := Val(cVlTotal)
nVlTotal := round(nVlTotal,2)

//Trata a data inicial
cDataIni := StrTran(cDataIni,".","/")
cDataIni := StrTran(cDataIni,"-","/")

dDataIni := CtoD(cDataIni)

//Trata a data final prevista
cDataFim := StrTran(cDataFim,".","/")
cDataFim := StrTran(cDataFim,"-","/")

dDataFim := CtoD(cDataFim)

//////////////////////////////////
//Calcula os valores da proposta//
//////////////////////////////////

//Calculo do Surcharge
If nVlSurCtr > 0
	nSurcha := (nVlSurCtr*100)/nVlSerCtr
	nSurcha := round(nSurcha,2)
Else
	nSurcha := 0
EndIf

//Calula o valor total Liquido com Surcharge
If nVlTotal == 0
	nTotLiqSur := 0
Else
	
	If Empty(cMoeda) .or. cMoeda == "REAL"
		If cFaturar == 	"GT AUDITORES GO"
			nTotLiqSur := nTotCtr - (nTotCtr*0.0925)
		Else
			nTotLiqSur := nTotCtr - (nTotCtr*0.1425)
		EndIf
	Else
		nTotLiqSur := nTotCtr - (nTotCtr*0.05)
	EndIf	    
	nTotLiqSur := round(nTotLiqSur,2)
EndIf

//Calula o calor total Liquido  sem Surcharge
If nVlTotal == 0
	nTotLiq := 0
Else
	If nSurcha > 0
		nTotLiq := nTotLiqSur - (nTotLiqSur*0.05)
	Else
		nTotLiq := nTotLiqSur
	EndIf
	
	nTotLiq := round(nTotLiq,2)
EndIf

//Calcula o valor cheio
nVlCheio := (nTotLiq*100)/nRecuper
nVlCheio := round(nVlCheio,2)

///////////////////////////////
//Atualiza o sócio do cliente//
///////////////////////////////
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	SA1->(RecLock("SA1",.F.))
	SA1->A1_P_SOCIO := cCpfSoCli
	SA1->(MsUnlock())
EndIf

////////////////////////////////////
//Atualiza o controle de numeração//
////////////////////////////////////
Z51->(DbSetOrder(1))
If !Z51->(DbSeek(xFilial("Z55")+cPropSis))
	Z51->(RecLock("Z51",.T.))
	Z51->Z51_FILIAL := xFilial("Z51")
	Z51->Z51_NUM    := cPropSis
	Z51->(MsUnlock())	
EndIf

/////////////////////////////////
//Inicia a gravação da proposta//
/////////////////////////////////
Z55->(RecLock("Z55",.T.))

Z55->Z55_FILIAL := xFilial("Z55")
Z55->Z55_FILORI	:= cFilAnt
Z55->Z55_DTINC	:= ddatabase	
Z55->Z55_TPVLR	:= "1"
Z55->Z55_STATUS := "E"
Z55->Z55_DESCST := "Proposta Ganha"

//Numero da proposta
Z55->Z55_NUM    := cPropSis
Z55->Z55_REVISA := "000"

//Tipo da Proposta
Z55->Z55_TPCTR := cCodTipo

//Informações do cliente
Z55->Z55_GLOBAL := "2"
Z55->Z55_TIPCLI := "2"
Z55->Z55_CLIENT := cCodCli
Z55->Z55_LOJA   := cLojCli
Z55->Z55_NOME   := SA1->A1_NOME

//Informação do Sócio
Z55->Z55_SOCIO  := cCpfSocio
Z55->Z55_NOMESO := cNomeSocio
Z55->Z55_USERRE := cCodResp
Z55->Z55_USERNO := cNomResp

//Informação do Gerente
Z55->Z55_GERENT := cCpfGer
Z55->Z55_NOMEGE := cNomeGer

//Moeda
If Empty(cMoeda) .or. cMoeda == "REAL"
	Z55->Z55_MOEDA := "01"
ElseIf cMoeda == "DOLAR"
	Z55->Z55_MOEDA := "02"	
ElseIf cMoeda == "LIBRA"
	Z55->Z55_MOEDA := "03"
ElseIf cMoeda == "EURO"
	Z55->Z55_MOEDA := "05"
ElseIf cMoeda == "DOLAR CANADENSE"
	Z55->Z55_MOEDA := "06"
EndIf

//Grava o Centro de Custo
If cFaturar == 	"GT AUDITORES SP"
	Z55->Z55_CC := "7101"
ElseIf cFaturar == 	"GT AUDITORES RJ"
	Z55->Z55_CC := "7103"
ElseIf cFaturar == 	"GT AUDITORES CP"
	Z55->Z55_CC := "7104"
ElseIf cFaturar == 	"GT AUDITORES POA"
	Z55->Z55_CC := "7106"
ElseIf cFaturar == 	"GT AUDITORES GO"
	Z55->Z55_CC := "7102"
ElseIf cFaturar == 	"GT CORPORATE"
	If cTipoPro == "TAX"
		Z55->Z55_CC := "7201"
	ElseIf cTipoPro == "ADVISORY"
		Z55->Z55_CC := "7202"
	EndIf
EndIf

//Valores 
Z55->Z55_VLRTOT := nTotCtr
Z55->Z55_VLRLIQ := nTotLiq
Z55->Z55_SURCHA := nSurcha
Z55->Z55_VLRLIS := nTotLiqSur

If Empty(cMoeda) .or. cMoeda == "REAL"

	If cFaturar == 	"GT AUDITORES GO"
		Z55->Z55_IMPOST := 9.25
	Else
		Z55->Z55_IMPOST := 14.25
	EndIf
Else
	Z55->Z55_IMPOST := 5
EndIf
	
Z55->(MsUnlock())

//////////////////////////////////
//Inicia a gravação dos serviços//
//////////////////////////////////

Z54->(RecLock("Z54",.T.))

Z54->Z54_FILIAL	:= xFilial("Z54")
Z54->Z54_FILORI	:= cFilAnt
Z54->Z54_NUMPRO	:= cPropSis
Z54->Z54_REVISA	:= "000"
Z54->Z54_CODIGO := cPropSis+".01"

Z54->Z54_CODDIV  := cCodDiv
Z54->Z54_DESCDIV := cDivisao
Z54->Z54_CODNAT  := cCodNat
Z54->Z54_DESCNA  := cNatureza
Z54->Z54_HORAPR  := nHoras
Z54->Z54_PRECOL  := nTotLiq
Z54->Z54_PRELSU  := nTotLiqSur
Z54->Z54_TAXAME  := nTxMedia
If nHoras > 0
	Z54->Z54_TXMESU  := Round((nTotLiqSur / nHoras),2)
EndIf
Z54->Z54_CUSTOT  := nVlCheio
Z54->Z54_RECUPE  := nRecuper
Z54->Z54_DTAINI  := dDataIni
Z54->Z54_DTAFIM  := dDataFim
Z54->Z54_RECORR  := "N"
Z54->Z54_RECQTD  := "" 
Z54->Z54_ANOINI  := ""

Z54->(MsUnlock())

///////////////////////////////////////
//Inicia a gravação de posicionamento//
///////////////////////////////////////

Z50->(RecLock("Z50",.T.)) 

Z50->Z50_FILIAL	:= xFilial("Z50")
Z50->Z50_ID		:= GETSXENUM("Z50","Z50_ID")
Z50->Z50_PROPOS	:= cPropSis
Z50->Z50_REVISA := "000"
Z50->Z50_DATA  	:= DATE()
Z50->Z50_HORA   := TIME()
Z50->Z50_PORCEN := "100"
Z50->Z50_MOTIVO := "Proposta incluida automaticamente."
Z50->Z50_USER  	:= ""

Z50->(MsUnlock())

//////////////////////////////////
//Inicia a gravação das parcelas//
//////////////////////////////////
If Len(aGrupo) > 1

	Z49->(RecLock("Z49",.T.))
	
	Z49->Z49_FILIAL	:= xFilial("Z49")
	Z49->Z49_PROPOS	:= cPropSis
	Z49->Z49_REVISA	:= "000"
	Z49->Z49_TIPO	:= "PROPOSTA"
	Z49->Z49_PARCEL	:= "1"
	Z49->Z49_VENCTO	:= dDataBase
	Z49->Z49_VALOR	:= nTotCtr
	Z49->Z49_INCDIP	:= "N"
	Z49->Z49_INCANO	:= "N"
	Z49->Z49_DTINC	:= dDataBase
	Z49->Z49_DIAVEN	:= dDataBase
	
	Z49->(MsUnLock())

Else
	BeginSql Alias 'TMPCNF'
		SELECT CNF_NUMERO,CNF_PARCEL,CNF_VLPREV,CNF_DTVENC
		FROM %table:CNF%
		WHERE %notDel% 
		  AND CNF_FILIAL = %xFilial:CN9%
		  AND CNF_CONTRA = %exp:cContrato% 
		ORDER BY CNF_NUMERO,CNF_PARCEL
	EndSql
	
	TMPCNF->(DbGoTop())
	While TMPCNF->(!EOF())
	
		If Empty(cAuxCNF)
			cAuxCNF := AllTrim(TMPCNF->CNF_NUMERO)
		ElseIf AllTrim(cAuxCNF) <> AllTrim(TMPCNF->CNF_NUMERO)
			Exit		
		EndIf
		
		Z49->(RecLock("Z49",.T.))
	
		Z49->Z49_FILIAL	:= xFilial("Z49")
		Z49->Z49_PROPOS	:= cPropSis
		Z49->Z49_REVISA	:= "000"
		Z49->Z49_TIPO	:= "PROPOSTA"
		Z49->Z49_PARCEL	:= TMPCNF->CNF_PARCEL
		Z49->Z49_VENCTO	:= StoD(TMPCNF->CNF_DTVENC)
		Z49->Z49_VALOR	:= TMPCNF->CNF_VLPREV
		Z49->Z49_INCDIP	:= "N"
		Z49->Z49_INCANO	:= "N"
		Z49->Z49_DTINC	:= dDataBase
		Z49->Z49_DIAVEN	:= StoD(TMPCNF->CNF_DTVENC)
		
		Z49->(MsUnLock())
		TMPCNF->(DbSkip())
	EndDo
	
	TMPCNF->(DbCloseArea())

EndIf	
//////////////////////////////////
//Inicia a gravação das despesas//
//////////////////////////////////

nItem := 0

//Grava despesa de alimentação
If cDespAlim <> "N/A"
	
	//Cafe da Manha
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000001"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespAlim == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
    EndIf
    
	//Almoço
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000002"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespAlim == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
	EndIf
	
	//Janta
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000003"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespAlim == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
	EndIf
EndIf

//Grava despesa de hospedagem
If cDespHosp <> "N/A"
	
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000004"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespHosp == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
	EndIf
EndIf

//Grava despesa de passagem aérea
If cDespPAe <> "N/A"
	
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000005"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespPAe == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
    EndIf
EndIf

//Grava despesa de deslocamento
If cDespDesl <> "N/A"
	
	//Quilometragem
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000006"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespDesl == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
    EndIf
	//Transporte Publico
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000007"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespDesl == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())
    EndIf
    
	//Pedagio
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000008"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespDesl == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())
    EndIf
    
	//Taxi
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000008"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespDesl == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())
    EndIf
EndIf

//Grava despesa de estacionamento
If cDespEst <> "N/A"
	
	nItem++

	Z56->(DbSetOrder(1))
	If Z56->(DbSeek(xFilial("Z56")+"000010"))

		Z52->(RecLock("Z52",.T.))
		
		Z52->Z52_FILIAL	:= xFilial("Z52")
		Z52->Z52_NUMPRO	:= cPropSis
		Z52->Z52_REVISA	:= "000"
		Z52->Z52_ITEM   := StrZero(nItem,2)
		Z52->Z52_CODIGO := AllTrim(Z56->Z56_CODIGO)
		Z52->Z52_DESCDE := AllTrim(Z56->Z56_DESCRI)
		
		If cDespEst == "REEMBOLSÁVEL"
			Z52->Z52_DEREEM := "1"
		Else
			Z52->Z52_DEREEM := "2"
		EndIf
		
		Z52->(MsUnlock())	
	EndIf
EndIf

/////////////////////////////////////////
//Inicia gravação das empresas de grupo//
/////////////////////////////////////////

//Grava o grupo de empresas
cCodACY := CriaVar("ACY_GRPVEN",.F.)
cCodAux := TkNumero("ACY","ACY_GRPVEN")
cCodACY := cCodAux

ACY->(RecLock("ACY",.T.))

ACY->ACY_FILIAL := xFilial("ACY")
ACY->ACY_GRPVEN := cCodACY
ACY->ACY_DESCRI := SA1->A1_NOME

ACY->(MsUnlock())

For nI:=1 To Len(aGrupo)
	
	If Len(aGrupo) > 1
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+aGrupo[nI][2]+aGrupo[nI][3]))
 
		//Atualiza o grupo
		SA1->(RecLock("SA1",.F.))
		SA1->A1_GRPVEN  := cCodACY	
		SA1->A1_P_SOCIO := cCpfSoCli
		SA1->(MsUnlock())
	    
	    //Calcula o percentual
	    nPerc := (aGrupo[nI][5]*100)/nTotCtr
	    nPerc := Round(nPerc,2)
	Else
		nPerc := 100
	EndIf
	    
	//Grava a empresa no grupo
	Z35->(RecLock("Z35",.T.))
			
	Z35->Z35_FILIAL := xFilial("Z35")
	Z35->Z35_PROPOS := cPropSis
	Z35->Z35_REVISA := "000"

	Z35->Z35_ITEM   :=StrZero(nI-1,2)
	Z35->Z35_NOME   := SA1->A1_NOME
	Z35->Z35_CGC    := SA1->A1_CGC
	Z35->Z35_PERCEN := nPerc 
	Z35->Z35_CODCLI := aGrupo[nI][2]
	Z35->Z35_LOJCLI := aGrupo[nI][3]
	
	Z35->(MsUnlock())
Next

///////////////////////////////////////////////////////////
//Inicia gravação da tabela de muro de geração de projeto//
///////////////////////////////////////////////////////////

//Define o tipo de conexão que será utilizado.
TCCONTYPE("TCPIP")

//Realiza a conexão com o banco de dados.
nCon := TCLink(cBanco,cIp)

//Verifica se foi conectado.
If nCon < 0
	cLogErro += "Erro ("+str(nCon,4)+") ao conectar com "+cBanco+" em "+cIp
    Return          	
EndIf

cInsMuro := "INSERT INTO Controle.dbo.INT_PROJETOS (Z54_CODIGO,Z54_DTAINI,Z54_DTAFIM,Z54_RECORR,Z54_RECQTD,Z54_ANOINI,M0_CODIGO,M0_CODFIL,M0_CGC) " 
cInsMuro += "VALUES ('"+cPropSis+".01','"+DtoS(dDataIni)+"','"+DtoS(dDataFim)+"','N','','','"+SM0->M0_CODIGO+"','"+SM0->M0_CODFIL+"',"+SM0->M0_CGC+")"

If TCSQLExec(cInsMuro) < 0
	cLogErro += "A Proposta:"+cProposta+", não foi incluida na Tabela de Muro. "+ ENTER + TCSQLError() + ENTER
	TcUnlink(nCon)
	Return
Endif

TcUnlink(nCon)

cLogGrv += "A Proposta:"+cProposta+", foi incluída com sucesso." + ENTER

Return              

*-------------------------------*
Static Function TrataAcento(cExp)
*-------------------------------*

cExp := StrTran(cExp,"á","a")
cExp := StrTran(cExp,"ã","a")
cExp := StrTran(cExp,"à","a")
cExp := StrTran(cExp,"â","a")
cExp := StrTran(cExp,"é","e")
cExp := StrTran(cExp,"è","e")
cExp := StrTran(cExp,"ê","e")
cExp := StrTran(cExp,"í","i")
cExp := StrTran(cExp,"ì","i")
cExp := StrTran(cExp,"ó","o")
cExp := StrTran(cExp,"ò","o")
cExp := StrTran(cExp,"õ","o")
cExp := StrTran(cExp,"ô","o")
cExp := StrTran(cExp,"ú","u")
cExp := StrTran(cExp,"ù","u")
cExp := StrTran(cExp,"Á","A")
cExp := StrTran(cExp,"À","A")
cExp := StrTran(cExp,"Â","A")
cExp := StrTran(cExp,"Ã","A")
cExp := StrTran(cExp,"É","E")
cExp := StrTran(cExp,"È","E")
cExp := StrTran(cExp,"Ê","E")
cExp := StrTran(cExp,"Í","I")
cExp := StrTran(cExp,"Ì","I")
cExp := StrTran(cExp,"Ó","O")
cExp := StrTran(cExp,"Ò","O")
cExp := StrTran(cExp,"Õ","O")
cExp := StrTran(cExp,"Ô","O")
cExp := StrTran(cExp,"Ú","U")

Return(cExp)