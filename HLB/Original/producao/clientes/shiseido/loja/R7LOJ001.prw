#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"

/*
Funcao      : R7LOJ001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Chamada das funções padrões do loja para tratamento da integração
Autor     	: Tiago Luiz Mendonça
Data     	: 07/05/2012                       
Obs         : Esse rdmake será também utilizado em JOB para otmizar o processo de integração
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Loja. 
Cliente     : Shiseido
*/

*-------------------------*
 User Function R7LOJ001()
*-------------------------*  
 
Local cDB          
Local cProd  
Local cQry       
Local cAux

Local lSeek    := .T.    
Local lGrava   := .T.
Local lCli     := .T.
Local lCanc    := .F.   

Local cArqSL1
Local cArqSL2 
Local cArqSL4 
Local cArqSFI  

Local aCpsAux := {}
Local aCpsSL1 := {}
Local aCpsSL2 := {} 
Local aCpsSL4 := {}  
Local aCpsSFI := {}  
  

Private nConWall  
Private nConGt02     
   
Private cEmp       
        
Private aArea    
Private aAreaSL1  
Private aAreaSL2  
Private aAreaSL4 

Private lCupom    := .F.
Private lCliente  := .F. 
Private lJob      := .F.
                          
Private aCpsSA1   := {}        

Private cFormaPg := ""

//Testa para verificar se está sendo feito pelo JOB ou pelo menu				                        
If Select("SX3")<=0
	RpcSetType(3)
	RpcSetEnv("R7", "01")  //Abre ambiente em rotinas automáticas  
	lJob:=.T. 
EndIf				                        
	  
cArqSL1  :=  "SL1"+alltrim(cEmpAnt)+"0" 
cArqSL2  :=  "SL2"+alltrim(cEmpAnt)+"0" 
cArqSL4  :=  "SL4"+alltrim(cEmpAnt)+"0"  
cArqSFI  :=  "SFI"+alltrim(cEmpAnt)+"0"  
cEmp     :=  alltrim(cEmpAnt)+"0"   
aArea    :=  GetArea()
aAreaSL1 :=  GetArea("SL1")
aAreaSL2 :=  GetArea("SL2")
aAreaSL4 :=  GetArea("SL4")			
aStruSA1 :=  SA1->(dbStruct()) 						                        
				                                
                          
 //Abre conexão com banco de interface
 nConWall := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 
               
 //Testa conexão
 If nConWall < 0
 	MsgInfo("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix")
 	If lJob
 		RpcClearEnv()
 	EndIf
 	Return .F.
 Else
 	ConOut("Conectado no Dbwall...")
 EndIf
   
 chkFile("SL1")
 chkFile("SL2")
 chkFile("SL4")  
                                                                                                                          
 If Select("cTempSL1") > 0
	cTempSL1->(DbCloseArea())	               
 EndIf  
 
  //TLM 20130926 - Realiza o backp da tabela	  
 ConOut("Realizando backup...")     
 cQuery := "Insert into SL1MICROVIX  select * from SL1"+cEmp+"  where L1_P_INT = ' ' and L1_EMISSAO > '20130925'"
 TCSQLExec(cQuery)
 cQuery := "Insert into SL2MICROVIX  select * from SL2"+cEmp+"  where L2_P_INT = ' ' and L2_EMISSAO > '20130925'"   
 TCSQLExec(cQuery) 
 cQuery:= "Insert into SL4MICROVIX  select * from SL4"+cEmp+"  where L4_P_INT = ' ' and L4_DATA    > '20130925'"
 TCSQLExec(cQuery)   
 cQuery := "Insert into SFIMICROVIX  select * from SFI"+cEmp+"  where FI_P_INT = ' ' and FI_DTMOVTO > '20130925'"   	  
 TCSQLExec(cQuery)   
 	  
 aStruSL1 := SL1->(dbStruct())
    
 //Cria temporario dos cupons que serão integrados.                              
 cQuery:=" SELECT * "
 cQuery+=" FROM SL1"+cEmp
 cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
 cQuery+=" AND L1_P_INT = ' ' ORDER BY L1_FILIAL,L1_SERIE,L1_DOC,L1_NUM"   
	
 TCQuery cQuery ALIAS "cTempSL1" NEW

 For nX := 1 To Len(aStruSL1)
 	If aStruSL1[nX,2]<>"C"
 		TcSetField("cTempSL1",aStruSL1[nX,1],aStruSL1[nX,2],aStruSL1[nX,3],aStruSL1[nX,4])
 	EndIf
 Next nX

 cTMP := CriaTrab(NIL,.F.)
 Copy To &cTMP
 dbCloseArea()
 dbUseArea(.T.,,cTMP,"cTempSL1",.T.)  
	  
                                                                                                                    
 If Select("cTempSFI") > 0
	cTempSFI->(DbCloseArea())	               
 EndIf
	  
 aStruSFI := SFI->(dbStruct())
    
 //Cria temporario da redução que será integrada.                              
 cQuery:=" SELECT * "
 cQuery+=" FROM SFI"+cEmp
 cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
 cQuery+=" AND FI_P_INT = ' ' ORDER BY FI_FILIAL,FI_DTMOVTO"   
	
 TCQuery cQuery ALIAS "cTempSFI" NEW

 For nX := 1 To Len(aStruSFI)
 	If aStruSFI[nX,2]<>"C"
 		TcSetField("cTempSFI",aStruSFI[nX,1],aStruSFI[nX,2],aStruSFI[nX,3],aStruSFI[nX,4])
 	EndIf
 Next nX

 cTMP := CriaTrab(NIL,.F.)
 Copy To &cTMP
 dbCloseArea()
 dbUseArea(.T.,,cTMP,"cTempSFI",.T.) 
 	  
 //Alinhado que a redução Z não precisa de validação, deve ser um espelho
 cQry := "Update SFI"+cEmp+" set FI_P_INT='S', FI_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where FI_P_INT='  '"
	  
 //Executa a query
 TCSQLExec(cQry)  	  
	  
 cTempSL1->(DbGoTop())
 
 //Nenhum cupom encontrado para integração
 If !(cTempSL1->(!BOF() .and. !EOF())) 
                                                                                	
    //FEcha conexão 
 	If TcUnlink(nConWall) 
	   
		ConOut("Conexão com DbWall fechada...")
		                     
		//Verifica se existe redução Z para integrar
		cTempSFI->(DbGoTop()) 
        IF (cTempSFI->(!BOF() .and. !EOF()))

			 //Temporario com  redução Z de cupons que serão gravados                 
			 SFI->(DbSetOrder(1))
			 SFI->(DbGoTop())
			 
			  //Temporario com os itens de cupons que serão gravados                                                                                       
			 If !(cTempSFI->(!BOF() .and. !EOF()))  
			 	ConOut("Dados de redução Z (SFI) não encontrados...")
			 	If lJob
			 		RpcClearEnv()
			 	EndIf
			 	Return .F.
			 Else
			 	While cTempSFI->(!EOF()) 
			 		//Adiciona os campos incluídos em um array.
			   		For nI := 1 To SFI->(FCount())
			 	  		//Tratamento do campo novo versão 11
   		   				If alltrim(FieldName(nI)) <> "FI_NCRED"
 							aAdd(aCpsAux,{FieldName(nI),&('cTempSFI->'+FieldName(nI))})    
			   			EndIf
			   		Next 
			   		
			   		aAdd(aCpsSFI,aCpsAux)
			   		aCpsAux:={}
			   		
			   		cTempSFI->(DbSkip())	
			   	EndDo	
			 EndIf                 
			                         
			 If Select("SFIPROD") > 0
			 	SFIPROD->(DbCloseArea())
			 EndIf
			
			 //Abre a tabela do ambiente que será atualizado.
			 USE &cArqSFI ALIAS "SFIPROD" Shared NEW VIA "TOPCONN" 
			
			//Inclusão dos novos dados
			 For nI:=1 to Len(aCpsSFI) 
			 	
			 	For nP := 1 To Len(aCpsSFI[nI])    
			 		 
			 		//Testa se o campo existe 
			 		If SFIPROD->(FieldPos(aCpsSFI[nI][nP][1])) > 0
			 	   	          
			 	   	    //Busca o próximo sequencial para o FI_NUMERO
			 	 		If Alltrim(aCpsSFI[nI][nP][1]) == "FI_NUMERO" 
			 	 					 	 		
							If Select("SFINUM") > 0
								SFINUM->(dbCloseArea())
							EndIf                        
							
							cQuery := " SELECT max(FI_NUMERO)+ 1 AS FI_NUM"+Chr(10)
							cQuery += " FROM "+RetSqlName("SFI")+Chr(10)
							cQuery += " WHERE FI_FILIAL='"+aCpsSFI[nI][2][2]+"'"
							cQuery += " AND D_E_L_E_T_ <> '*' "
							
							TCQuery cQuery ALIAS "SFINUM" NEW
							
							aCpsSFI[nI][nP][2]:=Replicate("0",6-len(alltrim(str(SFINUM->FI_NUM))))+Alltrim(Str(SFINUM->FI_NUM))
					    	
					    	//aCpsSFI[nI][nP][2]:= GetSx8Num("SFI","FI_NUMERO") 
					   		//ConfirmSX8()			   		
						EndIf 
															 	   	          
			 	   	    //Atualiza o campo FI_SUBTRIB
			 	 		If Alltrim(aCpsSFI[nI][nP][1]) == "FI_SUBTRIB"  
			 	 			nPosValCon:= aScan(aCpsSFI[nI],{ |X,Y|  X[1]==  "FI_VALCON" }) 
			 	 			If nPosValCon > 0
			 	 				aCpsSFI[nI][nP][2]:= aCpsSFI[nI][nPosValCon][2]
			 	 		    EndIf
			 	 		EndIf   
			 	 		
			 	 		//Atualiza o campo FI_PDV
			 	 		If Alltrim(aCpsSFI[nI][nP][1]) == "FI_PDV"  
							aCpsSFI[nI][nP][2]:= "01"
			 	 		EndIf   
			 	 		
			 	 		//Atualiza os zeros a esquerda dos documentos 
			 	 		If Alltrim(aCpsSFI[nI][nP][1]) == "FI_NUMINI"  
							aCpsSFI[nI][nP][2]:=Replicate("0",6-len(alltrim(aCpsSFI[nI][nP][2])))+Alltrim(aCpsSFI[nI][nP][2]) 
			 	 		EndIf
			 	 		
			 	 		//Atualiza os zeros a esquerda dos documentos 
			 	 		If Alltrim(aCpsSFI[nI][nP][1]) == "FI_NUMFIM"  
							aCpsSFI[nI][nP][2]:=Replicate("0",6-len(alltrim(aCpsSFI[nI][nP][2])))+Alltrim(aCpsSFI[nI][nP][2]) 
			 	 		EndIf  
								
						//Verifica se a redução existe
						If lSeek  			
							//FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ                                                                                                                         				
							If SFI->(DbSeek(aCpsSFI[nI][2][2]+DTOS(aCpsSFI[nI][1][2])+aCpsSFI[nI][8][2]))  
								//Redução já existe
								lGrava := .F.
							EndIf  
							//Não é mais necessário checar se a redução existe
							lSeek    := .F.   
							//Redução Z não existe, inclusão
							SFIPROD->(RecLock("SFIPROD",.T.))		
						EndIf  
						
						//Grava a redução na SFI	
						If lGrava 			
				   			SFIPROD->(FieldPut(FieldPos(aCpsSFI[nI][nP][1]),aCpsSFI[nI][nP][2]))
				   		EndIf	 
				   		  	   			   		
			   		EndIf
			   
			 	Next 
			 	    
			 	//Fecha o RecLock
			 	If lGrava  
			 		ConOut("Gravado SFI...")
			 		SFIPROD->(MsUnlock()) 
			 	EndIf   
			 	 
			 	//Seta para checar se existe a próxima redução
			 	lSeek  := .T.
			 	//Seta para gravar a próxima redução 
			 	lGrava := .T. 
			 
			 Next  
			         
			 SFIPROD->(DbCloseArea()) 
		  
		EndIf	 	    
		  	 
		If lJob
			RpcClearEnv()
		EndIf   
		
		Return .F.
 	Else
 		ConOut("Problema ao fechar a conexão com DbWall...")
 	EndIf          
 
 	
 Else
     
 	//Valida os dados gravados pelo Microvix
  	ConOut("Validando...")    
   	Validacoes()
          
    //Grava os temporarios para finalizar a conexao com o Muro
    ConOut("Montando temporarios ...")     
    GeraWork() 
        

 EndIf 
 
                     
 //Fecha conexão o banco
 If TcUnlink(nConWall) 	
	ConOut("Conexão com DbWall fechada...")      
 Else
 	ConOut("Problema ao fechar a conexão com DbWall...") 
 	If lJob
 		RpcClearEnv()
    EndIf
    
 	Return .F.
 EndIf      
 
 ConOut("Preparando para gravar SA1...") 
  
 //Caso tenha um cliente novo
 If lCliente 
	            
	//Array com os novos clientes
	For i:=1 to Len(aCpsSA1)
      
  		// aCpsSA1
  		//1.A1_CGC,2.A1_FILIAL,3.A1_NOME,4.A1_NREDUZ,5.A1_TIPO,6.A1_END,7.A1_BAIRRO,8.A1_CEP,9.A1_EST,10.A1_COD_MUN,11.A1_MUN,12.A1_DDD,13.A1_TEL
 		   
 		SA1->(DbSetOrder(3)) 
   		If !(SA1->(DbSeek(aCpsSA1[i][2]+aCpsSA1[i][1])))
 		
	 		RecLock("SA1",.T.)
	 		 
	 		//Grava o novo cliente 
	 		SA1->A1_FILIAL :=aCpsSA1[i][2] 
	 		SA1->A1_COD    :=GetSx8Num("SA1","A1_COD")   
	 		ConfirmSX8() 
	 		SA1->A1_LOJA   :="01"
	 		SA1->A1_CGC    :=aCpsSA1[i][1] 
	 		SA1->A1_NOME   :=aCpsSA1[i][3]
	 		SA1->A1_NREDUZ :=aCpsSA1[i][4]
	 		SA1->A1_TIPO   :=aCpsSA1[i][5]  
	 		SA1->A1_CONTA  :="112110004"  //Conta informada pelo Depto Contabilidade   
	 		
	 		//Campos obrigatorios do cliente não preechidos terá os dados do cliente padrão 000002 defido por lojas : 04,05 e 06.
	 		   
	 		//Tratamento do endereço
	 		If !Empty(aCpsSA1[i][6])
	 	   		SA1->A1_END    :=aCpsSA1[i][6]
	 		Else   
	 		
	 			If Select("SQL") > 0
					SQL->(dbCloseArea())
				EndIf

				cQuery := " SELECT A1_END "+Chr(10)
				cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
				cQuery += " WHERE A1_FILIAL = '"+aCpsSA1[i][2]+"'"+Chr(10)
				cQuery += " AND D_E_L_E_T_ <> '*' AND A1_COD='000002' AND A1_LOJA='01'"
			
				TCQuery cQuery ALIAS "SQL" NEW

				SA1->A1_END    :=AllTrim(SQL->A1_END)    
	 			 		
	 		EndIf 
	 		          
	 		//Tratamento do bairro
	 		If !Empty(aCpsSA1[i][7])
	 			SA1->A1_BAIRRO :=aCpsSA1[i][7]
	 		Else 
	 		
	 			If Select("SQL") > 0
					SQL->(dbCloseArea())
				EndIf

				cQuery := " SELECT A1_BAIRRO "+Chr(10)
				cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
				cQuery += " WHERE A1_FILIAL = '"+aCpsSA1[i][2]+"'"+Chr(10)
				cQuery += " AND D_E_L_E_T_ <> '*' AND A1_COD='000002' AND A1_LOJA='01'"
			
				TCQuery cQuery ALIAS "SQL" NEW

				SA1->A1_BAIRRO    :=AllTrim(SQL->A1_BAIRRO)    
	 				 		
	 		EndIf  
	 		       
	 		//Tratamento do CEP
	 		If !Empty(aCpsSA1[i][8])
	 	   		SA1->A1_CEP    :=aCpsSA1[i][8]
	 		Else 
	 		
	 			If Select("SQL") > 0
					SQL->(dbCloseArea())
				EndIf

				cQuery := " SELECT A1_CEP "+Chr(10)
				cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
				cQuery += " WHERE A1_FILIAL = '"+aCpsSA1[i][2]+"'"+Chr(10)
				cQuery += " AND D_E_L_E_T_ <> '*' AND A1_COD='000002' AND A1_LOJA='01'"
			
				TCQuery cQuery ALIAS "SQL" NEW

				SA1->A1_CEP    :=AllTrim(SQL->A1_CEP)  
	 		
	 		EndIf   
	 		
	 		//Tratamento do estado
	 		If !Empty(aCpsSA1[i][9])
	 			SA1->A1_EST    :=aCpsSA1[i][9]
	 		Else  
	 		
	 			If Select("SQL") > 0
					SQL->(dbCloseArea())
				EndIf

				cQuery := " SELECT A1_EST "+Chr(10)
				cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
				cQuery += " WHERE A1_FILIAL = '"+aCpsSA1[i][2]+"'"+Chr(10)
				cQuery += " AND D_E_L_E_T_ <> '*' AND A1_COD='000002' AND A1_LOJA='01'"
			
				TCQuery cQuery ALIAS "SQL" NEW

				SA1->A1_EST    :=AllTrim(SQL->A1_EST)  
	 		
	 		EndIf    
	 		    
	 		//Tratamento do código do município
	 		If !Empty(aCpsSA1[i][10])
	 			SA1->A1_COD_MUN:=aCpsSA1[i][10]
	 		Else    
	 		
	 			If Select("SQL") > 0
					SQL->(dbCloseArea())
				EndIf

				cQuery := " SELECT A1_COD_MUN "+Chr(10)
				cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
				cQuery += " WHERE A1_FILIAL = '"+aCpsSA1[i][2]+"'"+Chr(10)
				cQuery += " AND D_E_L_E_T_ <> '*' AND A1_COD='000002' AND A1_LOJA='01'"
			
				TCQuery cQuery ALIAS "SQL" NEW

				SA1->A1_COD_MUN    :=AllTrim(SQL->A1_COD_MUN)  	
	 		
	 		EndIf 
	 		
	 		//Tratamento do município
	 		If !Empty(aCpsSA1[i][11])
	 			SA1->A1_MUN    :=aCpsSA1[i][11]  
	 		Else  
	 		
	 			If Select("SQL") > 0
					SQL->(dbCloseArea())
				EndIf

				cQuery := " SELECT A1_MUN "+Chr(10)
				cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
				cQuery += " WHERE A1_FILIAL = '"+aCpsSA1[i][2]+"'"+Chr(10)
				cQuery += " AND D_E_L_E_T_ <> '*' AND A1_COD='000002' AND A1_LOJA='01'"
			
				TCQuery cQuery ALIAS "SQL" NEW

				SA1->A1_MUN    :=AllTrim(SQL->A1_MUN) 
	 		
	 	    EndIf   
	 	    
	 	    If Select("SQL") > 0
				SQL->(dbCloseArea())
			EndIf
	 	    
	 		SA1->A1_DDD    :=aCpsSA1[i][12]
	 		SA1->A1_TEL    :=aCpsSA1[i][13] 
	        SA1->A1_COMPLEM:="Cliente integrado pelo sistema da loja - Microvix"
	
	 		SA1->(MsUnlock())  
	 	
	 	EndIf
    	
	Next 
	
	SA1->(DBCloseArea())

 EndIf  
 
 SL1->(DbSetOrder(2)) 
 SL1->(DbGoTop())
               
 ConOut("Preparando para gravar SL1...")  
  
 //Temporario com os cupons que serão gravados                 
 cTempSL1->(DbGoTop())                                                                         
 If !(cTempSL1->(!BOF() .and. !EOF()))
    ConOut("Dados de cupons(SL1) não encontrados no temporario...")
 	If lJob
 		RpcClearEnv()
 	EndIf
 	
 	Return .F.
 Else
 	While cTempSL1->(!EOF()) 
 		//Adiciona os campos incluídos em um array.
   		For nI := 1 To SL1->(FCount())
 			aAdd(aCpsAux,{FieldName(nI),&('cTempSL1->'+FieldName(nI))})    
   		Next 
   		
   		aAdd(aCpsSL1,aCpsAux)
   		aCpsAux:={}
   		
   		cTempSL1->(DbSkip())	
   	EndDo	
 EndIf                 
                         
 If Select("SL1PROD") > 0
 	SL1PROD->(DbCloseArea())
 EndIf

 //Abre a tabela do ambiente que será atualizado.
 USE &cArqSL1 ALIAS "SL1PROD" Shared NEW VIA "TOPCONN" 
		
 //Inclusão dos novos dados
 For nI:=1 to Len(aCpsSL1) 
 	
 	For nP := 1 To Len(aCpsSL1[nI])    
 		 
 		//Testa se o campo existe 
 		If SL1PROD->(FieldPos(aCpsSL1[nI][nP][1])) > 0
 	   	          
 	   	    //Busca o próximo sequencial para o L1_NUM
 	 		If Alltrim(aCpsSL1[nI][nP][1]) == "L1_NUM"
		   		//aCpsSL1[nI][nP][2]:= GetSx8Num("SL1","L1_NUM") 
		   		aCpsSL1[nI][nP][2]:=L1NUMORC()
		   		//ConfirmSX8()
		   		ConOut("Numero cupom + filial :"+aCpsSL1[nI][nP][2]+"/"+aCpsSL1[nI][1][2])
			EndIf 
			
			//Primeiro loop entra para atualizar o cliente 
			If lCli             
			      
			    //Procura posição do CNPJ e Codigo
				nPosCCG:= aScan(aCpsSL1[nI],{ |X,Y|  X[1]==  "L1_CGCCLI" })  
		  		nPosCli:= aScan(aCpsSL1[nI],{ |X,Y|  X[1]==  "L1_CLIENTE" })  
				
				//Caso o CNPJ esteja preenchido procura no cadastro SA1 e atualiza o array do cupom para gravação
	 	 		If Alltrim(aCpsSL1[nI][nPosCCG][1]) == "L1_CGCCLI"
			    	If !Empty(Alltrim(aCpsSL1[nI][nPosCCG][2]))	
			    		SA1->(DbSetOrder(3)) 
	   					If SA1->(DbSeek(aCpsSL1[nI][1][2]+aCpsSL1[nI][nPosCCG][2]+"01")) 	
							aCpsSL1[nI][nPosCli][2]:=SA1->A1_COD		   	    
			   	   		EndIf
			   	    EndIf 
				EndIf 
				  
				//não necessário buscar mais o cliente para esse cupom
				lCli:=.F.
				  	   		   	
			EndIf  
			       
			nPosSit:= aScan(aCpsSL1[nI],{ |X,Y|  X[1]==  "L1_SITUA" })
						
			//Verifica se o cupom existe 
			If lSeek    				
				If SL1->(DbSeek(aCpsSL1[nI][1][2]+aCpsSL1[nI][14][2]+aCpsSL1[nI][13][2]))  
					//Cupom já existe
				EndIf   
				//Preeche como PR para aguardar a gravação do SL2 e SL4, após a gravação a situação é atualizada para RX
				aCpsSL1[nI][nPosSit][2]:= "PR"
				//Não é mais necessário checar se o cupom existe
				lSeek  := .F. 
				//Cupom não existe
				If lGrava  
					SL1PROD->(RecLock("SL1PROD",.T.))  
				EndIf			
			EndIf  
			
			//Grava o cupom na SL1	
			If lGrava  
	   			SL1PROD->(FieldPut(FieldPos(aCpsSL1[nI][nP][1]),aCpsSL1[nI][nP][2])) 
	   			//Seta .T. para atualizar os cupons integrados.
	   			lCupom:=.T.
	   		EndIf	 
	   		   		
   		EndIf
 	
 	Next 
 	    
 	//Fecha o RecLock
 	If lGrava 
   		ConOut("Gravado SL1...")
 		SL1PROD->(MsUnlock()) 
 	EndIf   
 	 
 	//Seta para checar se existe o próximo cupom 
 	lSeek  := .T.
 	//Seta para gravar o próximo cupom 
 	lGrava := .T.    
 	//Seta para procurar o cliente para o próximo cupom
 	lCli   := .T.
 
 Next  
         
 SL1PROD->(DbCloseArea())
                       
 ConOut("Preparando para gravar SL2...")    
   
 SL2->(DbSetOrder(3))
 SL2->(DbGoTop())
 
 //Temporario com os itens de cupons que serão gravados                 
 cTempSL2->(DbGoTop())                                                                         
 If !(cTempSL2->(!BOF() .and. !EOF()))
 	ConOut("Dados de cupons(SL2) não encontrados...")
 	If lJob
 		RpcClearEnv()
 	EndIf
 	Return .F.
 Else
 	While cTempSL2->(!EOF()) 
 		//Adiciona os campos incluídos em um array.
   		For nI := 1 To SL2->(FCount()) 
   			//Tratamento do campo memo versão 11
   			If alltrim(FieldName(nI)) <> "L2_VDOBS"  .AND. alltrim(FieldName(nI)) <> "L2_TOTIMP" 
 				aAdd(aCpsAux,{FieldName(nI),&('cTempSL2->'+FieldName(nI))})    
   	    	EndIf
   		Next 
   		
   		aAdd(aCpsSL2,aCpsAux)
   		aCpsAux:={}
   		
   		cTempSL2->(DbSkip())	
   	EndDo	
 EndIf                 
                         
 If Select("SL2PROD") > 0
 	SL2PROD->(DbCloseArea())
 EndIf

 //Abre a tabela do ambiente que será atualizado.
 USE &cArqSL2 ALIAS "SL2PROD" Shared NEW VIA "TOPCONN" 
		

 //Inclusão dos novos dados, array com as linhas de intes de cupons
 For nI:=1 to Len(aCpsSL2) 
 	   
 	//Dimensão com campos e conteúdos
 	For nP := 1 To Len(aCpsSL2[nI])    
 		 
 		//Testa se o campo existe 
 		If SL2PROD->(FieldPos(aCpsSL2[nI][nP][1])) > 0
 	   	          
 	   	    //Busca o sequencial da capa do cupom SL1
 	 		If Alltrim(aCpsSL2[nI][nP][1]) == "L2_NUM"   
 	 		            
 	 		     //Loop de todos os cabeçarios
 	 		     For nL:=1 to Len(aCpsSL1)   
 	 		                                  
 	 		         //Procura as posições da chave : Filial + Nota + Serie
 	 		         nPosFil:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_FILIAL" }) 
 	 		     	 nPosDoc:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_DOC"    }) 
 	 		     	 nPosSer:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_SERIE"  })
 	 		     	 nPosNum:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_NUM"    })  
 	 		     	 
 	 		     	 // Testa se a chave é igual entre SL1 e SL2
 	 		     	 If aCpsSL1[nL][nPosFil][2]+aCpsSL1[nL][nPosDoc][2]+aCpsSL1[nL][nPosSer][2] == aCpsSL2[nI][1][2]+aCpsSL2[nI][16][2]+aCpsSL2[nI][17][2]           	 	 

	 	 	         	//Atualza o SL2 com a sequencia do SL1
	 	 		 	 	aCpsSL2[nI][nP][2]:= aCpsSL1[nL][nPosNum][2]   		 
	 	 		    
	 	 		     EndIf                                                                  	
		   		
		   		Next 
		   		
			EndIf  
			
			If Alltrim(aCpsSL2[nI][nP][1]) == "L2_PRODUTO"
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+aCpsSL2[nI][nP][2]))
					   
					//Tratamento para TES utilizada no Cupom Fiscal
					
					nPosTES :=aScan(aCpsSL2[nI],{ |X,Y|  X[1]==  "L2_TES" }) 
					nPosCF  :=aScan(aCpsSL2[nI],{ |X,Y|  X[1]==  "L2_CF" })
					
					If SB1->(FieldPos("B1_P_CFTES")) > 0
						SF4->(DbSetOrder(1))     
						
						//Verifica se o campo de TES para Cupom está preenchido no cadastro de produto
						If !Empty(SB1->B1_P_CFTES) 					
							If SF4->(DbSeek(xFilial("SF4")+SB1->B1_P_CFTES))
								aCpsSL2[nI][nPosTES][2]:=SB1->B1_P_CFTES		
								aCpsSL2[nI][nPosCF][2]:=SF4->F4_CF
					   		Else                     
					   			//Caso não encontre TES preenchida segue a regra passada pelo Depto. Fiscal
					   	 		If Alltrim(SB1->B1_POSIPI) == "96033000" 
									aCpsSL2[nI][nPosTES][2]:="56M"	
							   		aCpsSL2[nI][nPosCF][2]:="5405"							
								Else
						   			aCpsSL2[nI][nPosTES][2]:="5OQ" 
						   			aCpsSL2[nI][nPosCF][2]:="5405" 
						   		EndIf	
					   		EndIf     
					   	Else	
					   		//Caso não tenha TES preenchida segue a regra passada pelo Depto. Fiscal					
							If Alltrim(SB1->B1_POSIPI) == "96033000" 
								aCpsSL2[nI][nPosTES][2]:="56M"	
								aCpsSL2[nI][nPosCF][2]:="5405"							
							Else
						   		aCpsSL2[nI][nPosTES][2]:="5OQ" 
						   		aCpsSL2[nI][nPosCF][2]:="5405"
						   	EndIf	
						EndIf  
						
					EndIf		
				
				EndIf 
			     			
			EndIf			
					
			//Verifica se o cupom existe e não está cancelado
			If lSeek  
				SL2->(DbSetOrder(1))
			    //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO                                                                                                                             
				nPosNum   :=aScan(aCpsSL2[nI],{ |X,Y|  X[1]==  "L2_NUM" })
				nPosItem  :=aScan(aCpsSL2[nI],{ |X,Y|  X[1]==  "L2_ITEM" })	
			   	nPosProd  :=aScan(aCpsSL2[nI],{ |X,Y|  X[1]==  "L2_PRODUTO" })
			   	//Testa para verificar se esta duplicado 			
				If SL2->(DbSeek(aCpsSL2[nI][1][2]+aCpsSL2[nI][nPosNum][2]+aCpsSL2[nI][nPosItem][2]+aCpsSL2[nI][nPosProd][2]))   
					lGrava := .F.  
				EndIf  
				//Não é mais necessário buscar o item do cupom para os outros campos
				lSeek  := .F. 
				//Cria o registro novo no SL2
				SL2PROD->(RecLock("SL2PROD",.T.))		
			EndIf  
			
			//Grava o cupom na SL2	
			If lGrava                     
				//Campo Memo
				If Alltrim(aCpsSL2[nI][1][2]) <> "L2_VDOBS"
	   				SL2PROD->(FieldPut(FieldPos(aCpsSL2[nI][nP][1]),aCpsSL2[nI][nP][2]))
	   			EndIf
	   		EndIf	 
	   		  	   			   		
   		EndIf
 	   	
 	Next 
 	    
 	//Fecha o RecLock
 	If lGrava  
 		ConOut("Gravado SL2...")
 		SL2PROD->(MsUnlock()) 
 	EndIf   
 	 
 	//Seta para checar se existe o próximo cupom 
 	lSeek  := .T.
 	//Seta para gravar o próximo cupom 
 	lGrava := .T. 
 
 Next  
         
 SL2PROD->(DbCloseArea())
 
 ConOut("Preparando para gravar SL4...")  
 
 SL4->(DbSetOrder(5))
 SL4->(DbGoTop())
 
  //Temporario com os itens de cupons que serão gravados                                                                                       
 If !(cTempSL4->(!BOF() .and. !EOF()))  
 	ConOut("Dados de cupons(SL4) não encontrados...")
 	If lJob
 		RpcClearEnv()
 	EndIf
 	Return .F.
 Else
 	While cTempSL4->(!EOF()) 
 		//Adiciona os campos incluídos em um array.
   		For nI := 1 To SL4->(FCount())
 			aAdd(aCpsAux,{FieldName(nI),&('cTempSL4->'+FieldName(nI))})    
   		Next 
   		
   		aAdd(aCpsSL4,aCpsAux)
   		aCpsAux:={}
   		
   		cTempSL4->(DbSkip())	
   	EndDo	
 EndIf                 
                         
 If Select("SL4PROD") > 0
 	SL4PROD->(DbCloseArea())
 EndIf

 //Abre a tabela do ambiente que será atualizado.
 USE &cArqSL4 ALIAS "SL4PROD" Shared NEW VIA "TOPCONN" 
		
 //Inclusão dos novos dados
 For nI:=1 to Len(aCpsSL4) 
 	
 	For nP := 1 To Len(aCpsSL4[nI])    
 		 
 		//Testa se o campo existe 
 		If SL4PROD->(FieldPos(aCpsSL4[nI][nP][1])) > 0
 	   	          
 	   	    //Busca o próximo sequencial para o L1_NUM
 	 		If Alltrim(aCpsSL4[nI][nP][1]) == "L4_NUM"
		   		
		   		//Loop de todos os cabeçarios
 	 			For nL:=1 to Len(aCpsSL1)   
 	 		                                  
 	 		 		//Procura as posições da chave : Filial + Nota + Serie
 	 		   		nSL1Fil:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_FILIAL" }) 
 	 		     	nSL1Doc:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_DOC"    }) 
 	 		     	nSL1Ser:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_SERIE"  })  
 	 		     	nSL1Num:= aScan(aCpsSL1[nL],{ |X,Y|  X[1]==  "L1_NUM"    })   
 	 		     	 	 		    	 		     	 
 	 		     	// Teste se a chave é igual entre SL1 e SL4
 	 		     	 If aCpsSL1[nL][nSL1Fil][2]+aCpsSL1[nL][nSL1Doc][2]+aCpsSL1[nL][nSL1Ser][2] == aCpsSL4[nI][1][2]+aCpsSL4[nI][14][2]+aCpsSL4[nI][16][2]        	 	 
	 	 		 	 	
	 	 		 		//Atualza o SL2 com a sequencia do SL4
	 	 		 	 	aCpsSL4[nI][nP][2]:= aCpsSL1[nL][nPosNum][2]   		 
	 	 		    
	 	 		     EndIf                                                                  	
		   		
		   		Next		   	
		   		
			EndIf  
			
			nPosSit:= aScan(aCpsSL4[nI],{ |X,Y|  X[1]==  "L4_SITUA" })
					
			//Verifica se o cupom existe e não está cancelado
			If lSeek 
				SL4->(DbSetOrder(4))
			    //L4_FILIAL+L4_NUM+L4_ITEM                                                                                                                                                                                                                                                                     
				nPosNum   :=aScan(aCpsSL4[nI],{ |X,Y|  X[1]==  "L4_NUM" })
				nPosItem  :=aScan(aCpsSL4[nI],{ |X,Y|  X[1]==  "L4_ITEM" })
				//Testa para verificar se esta duplicado	     				
			  	If SL4->(DbSeek(aCpsSL4[nI][1][2]+aCpsSL4[nI][nPosNum][2]+aCpsSL4[nI][nPosItem ][2])) 					
					lGrava := .F.
			  	EndIf  
				//Não é mais necessário buscar checar se o cupom existe
				lSeek  := .F. 
				//Cupom não existe
				SL4PROD->(RecLock("SL4PROD",.T.))		
		   	EndIf  
			
			//Grava o cupom na SL1	
			If lGrava 			
	   			SL4PROD->(FieldPut(FieldPos(aCpsSL4[nI][nP][1]),aCpsSL4[nI][nP][2]))
	   		EndIf	 
	   		  	   			   		
   		EndIf
   
 	Next 
 	    
 	//Fecha o RecLock
 	If lGrava  
 		ConOut("Gravado SL4...")
 		SL4PROD->(MsUnlock()) 
 	EndIf   
 	 
 	//Seta para checar se existe o próximo cupom 
 	lSeek  := .T.
 	//Seta para gravar o próximo cupom 
 	lGrava := .T. 
 	//Seta como não cancelado 
 	lCanc  :=.F.
 
 Next  
         
 SL4PROD->(DbCloseArea()) 
    
 //Temporario com  redução Z de cupons que serão gravados                 
 SFI->(DbSetOrder(1))
 SFI->(DbGoTop())
 
  //Temporario com os itens de cupons que serão gravados                                                                                       
 If !(cTempSFI->(!BOF() .and. !EOF()))  
 
 	If lCupom       
	 	//Atualiza a situação para RX dos cupons processados 'PR'
	 	cQry := "Update SL1"+cEmp+" set L1_SITUA='RX', L1_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where L1_SITUA='PR' "		  				 
		TCSQLExec(cQry)  		  					
		Conout("Status alterado de PR para RX ... "+cQry) 
	EndIf          

 	ConOut("Dados de redução Z (SFI) não encontrados...")
 	If lJob
 		RpcClearEnv()
 	EndIf
 	
 	 Return .F.

 Else
 	While cTempSFI->(!EOF()) 
 		//Adiciona os campos incluídos em um array.
   		For nI := 1 To SFI->(FCount())
			//Tratamento do campo novo versão 11
   			If alltrim(FieldName(nI)) <> "FI_NCRED"
 				aAdd(aCpsAux,{FieldName(nI),&('cTempSFI->'+FieldName(nI))})            
 			EndIf	
   		Next 
   		
   		aAdd(aCpsSFI,aCpsAux)
   		aCpsAux:={}
   		
   		cTempSFI->(DbSkip())	
   	EndDo	
 EndIf                 
                         
 If Select("SFIPROD") > 0
 	SFIPROD->(DbCloseArea())
 EndIf

 //Abre a tabela do ambiente que será atualizado.
 USE &cArqSFI ALIAS "SFIPROD" Shared NEW VIA "TOPCONN" 

//Inclusão dos novos dados
 For nI:=1 to Len(aCpsSFI) 
 	
 	For nP := 1 To Len(aCpsSFI[nI])    
 		 
 		//Testa se o campo existe 
 		If SFIPROD->(FieldPos(aCpsSFI[nI][nP][1])) > 0
 	   	          
 	   	    //Busca o próximo sequencial para o FI_NUMERO
 	 		If Alltrim(aCpsSFI[nI][nP][1]) == "FI_NUMERO" 
 	 		
				If Select("SFINUM") > 0
					SFINUM->(dbCloseArea())
				EndIf                        
							
				cQuery := " SELECT max(FI_NUMERO)+ 1 AS FI_NUM"+Chr(10)
				cQuery += " FROM "+RetSqlName("SFI")+Chr(10)
				cQuery += " WHERE FI_FILIAL='"+aCpsSFI[nI][2][2]+"'"
				cQuery += " AND D_E_L_E_T_ <> '*' "
							
				TCQuery cQuery ALIAS "SFINUM" NEW
							
				aCpsSFI[nI][nP][2]:=Replicate("0",6-len(alltrim(str(SFINUM->FI_NUM))))+Alltrim(Str(SFINUM->FI_NUM))
 	 			   		
			EndIf   
			
			//Atualiza o campo FI_SUBTRIB
			If Alltrim(aCpsSFI[nI][nP][1]) == "FI_SUBTRIB"  
				nPosValCon:= aScan(aCpsSFI[nI],{ |X,Y|  X[1]==  "FI_VALCON" }) 
			 	If nPosValCon > 0
			 		aCpsSFI[nI][nP][2]:= aCpsSFI[nI][nPosValCon][2]
			 	EndIf
			EndIf 
			
			//Atualiza o campo FI_PDV
			If Alltrim(aCpsSFI[nI][nP][1]) == "FI_PDV"  
				aCpsSFI[nI][nP][2]:= "01"
			EndIf  
			
			//Atualiza os zeros a esquerda dos documentos 
			If Alltrim(aCpsSFI[nI][nP][1]) == "FI_NUMINI"  
				aCpsSFI[nI][nP][2]:=Replicate("0",6-len(alltrim(aCpsSFI[nI][nP][2])))+Alltrim(aCpsSFI[nI][nP][2]) 
			 EndIf
			 	 		
			 //Atualiza os zeros a esquerda dos documentos 
			 If Alltrim(aCpsSFI[nI][nP][1]) == "FI_NUMFIM"  
				aCpsSFI[nI][nP][2]:=Replicate("0",6-len(alltrim(aCpsSFI[nI][nP][2])))+Alltrim(aCpsSFI[nI][nP][2]) 
			 EndIf     
					
			//Verifica se a redução existe
			If lSeek  			
				//FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ                                                                                                                         				
				If SFI->(DbSeek(aCpsSFI[nI][2][2]+DTOS(aCpsSFI[nI][1][2])+aCpsSFI[nI][8][2]))  
					//Redução Z já existe
					lGrava := .F.
				EndIf  
				//Não é mais necessário buscar a redução
				lSeek  := .F. 
				//Redução não existe
				SFIPROD->(RecLock("SFIPROD",.T.))		
			EndIf  
			
			//Grava a redução da SFI
			If lGrava 			
	   			SFIPROD->(FieldPut(FieldPos(aCpsSFI[nI][nP][1]),aCpsSFI[nI][nP][2]))
	   		EndIf	 
	   		  	   			   		
   		EndIf
   
 	Next 
 	    
 	//Fecha o RecLock
 	If lGrava  
 		ConOut("Gravado SFI...")
 		SFIPROD->(MsUnlock()) 
 	EndIf   
 	 
 	//Seta para checar se existe a próxima redução Z
 	lSeek  := .T.
 	//Seta para gravar a próxima redução Z 
 	lGrava := .T. 
 
 Next  
         
 SFIPROD->(DbCloseArea()) 
 
 If lCupom       
 	//Atualiza a situação para RX dos cupons processados 'PR'
 	cQry := "Update SL1"+cEmp+" set L1_SITUA='RX', L1_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where L1_SITUA='PR' "		  				 
	TCSQLExec(cQry)  		  					
	Conout("Status alterado de PR para RX ... ") 
 EndIf  

 ConOut("Gravação finalizada...")  
 
 If nConWall < 0
 	ConOut("Desconectado no Dbwall...") 
 Else
 	ConOut("Conectado no Dbwall...")
 EndIf     
   
 

 cTempSL1->(DbCloseArea())	               
 cTempSL2->(DbCloseArea())	               
 cTempSL4->(DbCloseArea())	               
 cTempSFI->(DbCloseArea())	               

 RestArea(aAreaSl4)
 RestArea(aAreaSL2)
 RestArea(aAreaSL1)
 RestArea(aArea)			
 
 If lJob 
 	RpcClearEnv()
 EndIf   

Return 

/*
Funcao      : VALIDACOES
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para validar os dados do cupom fiscal
Autor     	: Tiago Luiz Mendonça
Data     	: 07/05/2012 
*/

*-----------------------------*
  Static Function VALIDACOES()
*-----------------------------* 

Local nParcelas  := 0 
Local nTotalSL1  := 0
Local nTotalSL2  := 0
Local nTotalSL4  := 0
Local nDif       := 0 
Local nRet       := 0 

Local cTable     := "" 
                     
SL1->(DbSetOrder(1)) 
SL1->(DbGoTop())
SL2->(DbSetOrder(3))
SL2->(DbGoTop())
SL4->(DbSetOrder(5))
SL4->(DbGoTop())

While cTempSL1->(!EOF()) 
     
    //Função padrão Totvs para abrir o indice na segunda execução da rotina com a função TcLink
	FRTADEFTAB(Posicione("SX2",1,"SL1","Alltrim(X2_ARQUIVO)"),"SL1",nConWall)  
	SL1->(DbSetOrder(1)) 
	
 	//If SL1->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))                                                                                                                                 
	If SL1->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_NUM))
	         
		cFormaPG:=cTempSL1->L1_FORMPG
		
		If cTempSL1->L1_SITUA == SL1->L1_SITUA
		
			RecLock("SL1",.F.)  
			
			ConOut("Validando SL1...")
			
			//Verifica campos obrigatorios 
		                                                       
			If Empty(SL1->L1_FILIAL)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:="Cpo:  filial vazio / " 
			EndIf   
			 
			//Cliente "22222222222" padrão no Microvix, não validar, utilizado para de/para 
			If !Empty(SL1->L1_CGCCLI) .And.  AllTrim(SL1->L1_CGCCLI) <> "22222222222"  
	
				If Select("cTempSA1") > 0
				   cTempSA1->(dbCloseArea())
				EndIf                         
				
   
				cQuery:=" SELECT * "
				cQuery+=" FROM SA1"+cEmp
				cQuery += " WHERE A1_CGC = '"+Alltrim(SL1->L1_CGCCLI)+"' AND"   
				cQuery += " A1_FILIAL = '"+Alltrim(SL1->L1_FILIAL)+"'"
					
				 TCQuery cQuery ALIAS "cTempSA1" NEW
				
				  
				 For nX := 1 To Len(aStruSA1)
				 	If aStruSA1[nX,2]<>"C"
				 		TcSetField("cTempSA1",aStruSA1[nX,1],aStruSA1[nX,2],aStruSA1[nX,3],aStruSA1[nX,4])
					EndIf  
				 Next nX
				
				 cTMP := CriaTrab(NIL,.F.)
				 Copy To &cTMP
				 dbCloseArea()  
				 dbUseArea(.T.,,cTMP,"cTempSA1",.T.)

				 
				//Testa se o cliente existe
				IF Empty(cTempSA1->A1_CGC)
					SL1->L1_P_INT:="N"
		 			SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  cliente não encontrado na tabela SA1 / "							
				Else                                     
					
					RecLock("cTempSA1",.F.)
				
					//Verifica se o cliente já foi cadastrado  
					If Alltrim(cTempSA1->A1_P_INT) <> "S"
					   
						If Empty(cTempSA1->A1_NOME) 
					 		SL1->L1_P_INT:="N"
		 					SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo: Nome cliente vazio SA1 / "							
					 	EndIf 
					 	If Empty(cTempSA1->A1_NREDUZ)  
					 		cTempSA1->A1_NREDUZ:=substr(cTempSA1->A1_NOME,1,20)							
					 	EndIf   
					 	If Empty(cTempSA1->A1_TIPO) 
		 					cTempSA1->A1_TIPO:="F" 
					 	EndIf
   					 	
					 	If Empty(SL1->L1_P_INT)  
							cQry := "Update SA1"+cEmp+" set A1_P_INT='P', A1_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where A1_CGC='"+Alltrim(SL1->L1_CGCCLI)+"' AND A1_FILIAL='"+Alltrim(SL1->L1_FILIAL)+"'"
		  					nRet = TCSQLExec(cQry)  		  					
				   			lCliente:=.T. 
				   			Conout("A1_P_INT atualizado com CNPJ... "+SL1->L1_CGCCLI)
				   		EndIf
				   		
				   	EndIf	
				
					SA1->(MsUnlock())
				
				EndIf  
			
			EndIf
			If Empty(SL1->L1_EMISSAO)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  emissao vazio / "	 
			EndIf
			If Empty(SL1->L1_VLRTOT) 
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  valor total vazio / "	
			EndIf
			If Empty(SL1->L1_VLRLIQ)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  valor liquido vazio / "	
			EndIf
			If Empty(SL1->L1_DOC) 
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  documento vazio / "	
			EndIf
			If Empty(SL1->L1_SERIE) 
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  serie vazio / "    
		    EndIf
		    If Empty(SL1->L1_VALBRUT)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  valor bruto vazio / "    
		 	EndIf
		 	If Empty(SL1->L1_PARCELA)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  parcela vazio / "   	 	
			EndIf
			If Empty(SL1->L1_VALMERC)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  valor mercadoria vazio / "
			EndIf
			If Empty(SL1->L1_FORMPG)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  forma pagto. vazio / "	
			EndIf 
			If Empty(SL1->L1_VEND)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo vendedor vazio / "	
			EndIf
			If Empty(SL1->L1_HORA)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:  hora vazio / "
			EndIf
			If Empty(SL1->L1_SITUA)
		   		SL1->L1_P_INT:="N"
		 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Cpo:   situacao vazio / "
		    EndIf
		    	   	    	     
		    nTotalSL1 :=  SL1->L1_VLRLIQ	     
		    	       	    
		    	       	    
		    SL1->(MsUnlock())
	    Else
	    	ConOut("Chave SL1 :"+alltrim(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC)+" não localizado no DbWall para validação")
	    	cTempSL1->(DbSkip())
	        loop
	    EndIf                     
        
    EndIf
    
	nTotalSL2:=0  
	
	//Função padrão Totvs para abrir o indice na segunda execução da rotina com a função TcLink
	FRTADEFTAB(Posicione("SX2",1,"SL2","Alltrim(X2_ARQUIVO)"),"SL2",nConWall)  
	SL2->(DbSetOrder(1)) 
	   
    //If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC)
    If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_NUM))      
     		
     	While SL2->(!EOF()) .And. SL2->L2_FILIAL+SL2->L2_NUM == cTempSL1->L1_FILIAL+cTempSL1->L1_NUM ;
     	 					.And. cTempSL1->L1_SITUA == SL2->L2_SITUA
     	  
     		RecLock("SL2",.F.)     
     		
     		ConOut("Validando SL2...")
     	                
     		//Verifica campos obrigatorios 
     	
         	If Empty(SL2->L2_FILIAL) 
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:="Cpo:  filial vazio / " 
			EndIf
			If Empty(SL2->L2_PRODUTO)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  produto vazio / " 
			EndIf
			If Empty(SL2->L2_ITEM)
 				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  item vazio / " 
			EndIf
			If Empty(SL2->L2_DESCRI)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  descricao vazio / " 
			EndIf
			If Empty(SL2->L2_QUANT)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  quantidade vazio / " 
			EndIf
			If Empty(SL2->L2_VRUNIT)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  valor unit. vazio / " 
			EndIf
			If Empty(SL2->L2_VLRITEM)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  valot item vazio / " 
			EndIf
			If Empty(SL2->L2_DOC)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  documento vazio / " 
			EndIf
			If Empty(SL2->L2_SERIE)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  serie vazio / " 
			EndIf
			If Empty(SL2->L2_EMISSAO)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  emissao vazio / " 
			EndIf
			If Empty(SL2->L2_VEND)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  vendedor vazio / " 
			EndIf
			If Empty(SL2->L2_SITUA)
				SL2->L2_P_INT:="N"
	 	   		SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Cpo:  situacao vazio / "  
     	    EndIf  
     	    
     	    
     	    //Validações
     	    
     	    If (SL2->L2_QUANT * SL2->L2_VRUNIT ) <> SL2->L2_VLRITEM
          		
          		SL2->L2_P_INT:="N"
		 		SL2->L2_P_OBS:=alltrim(SL2->L2_P_OBS)+" Valor total inválido ( qtd x unit )"  
		 		
		 		RecLock("SL1",.F.)
       			SL1->L1_P_INT:="N"
 				SL1->L1_P_OBS:=Alltrim(SL1->L1_P_OBS)+" Verificar itens (SL2) desse documento / "
       			SL1->(MsUnlock())                                
          	Else
             	nTotalSL2+=(SL2->L2_QUANT * SL2->L2_VRUNIT ) 
                  
 			EndIf         
 			
 			If SL1->L1_P_INT == "N"  
				SL2->L2_P_INT:="N"
		 		SL2->L2_P_OBS:=alltrim(SL2->L2_P_OBS)+" Verificar cupom (SL1) desse documento"
			EndIf  
 			
 
     	    If Empty(SL2->L2_P_INT) 
     	    
     	    	SL2->L2_P_INT :="P"
     	    	GrvFixos("SL2")	
   	    	
     	    ELse    
     	                  	    
     	    	RecLock("SL1",.F.)
       			SL1->L1_P_INT:="N"  
       			SL2->L2_P_INT:="N"
 				SL1->L1_P_OBS:=Alltrim(SL1->L1_P_OBS)+" Verificar itens (SL2) desse documento / "
       			SL1->(MsUnlock())
     	    
     	    EndIF
     	    
			SL2->(MsUnlock())
			
     		SL2->(DbSkip())
     	                     
     	EndDo 
         
    Else    
    
        //Não encontrou nenhum item para o cupom  
        RecLock("SL1",.F.)
    	SL1->L1_P_INT:="N"
 		SL1->L1_P_OBS:=Alltrim(SL1->L1_P_OBS)+" Linha de itens SL2 não encontrada / "
    	SL1->(MsUnlock())
    
    	ConOut("Chave SL2 :"+alltrim(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC)+" não localizado no DbWall para validação")
                                           
	EndIf                                                                                                                         
  
	nTotalSL4 :=0
	nParcelas :=0
	                           
	SL4->(DbGoTop())   
	//Função padrão Totvs para abrir o indice na segunda execução da rotina com a função TcLink
	FRTADEFTAB(Posicione("SX2",1,"SL4","Alltrim(X2_ARQUIVO)"),"SL4",nConWall)  
	SL4->(DbSetOrder(1))          
    
    //If SL4->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+alltrim(cTempSL1->L1_DOC)))    
    
    If SL4->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_NUM))
     	
     	While SL4->(!EOF()) .And. SL4->L4_FILIAL+SL4->L4_NUM == cTempSL1->L1_FILIAL+cTempSL1->L1_NUM;
     						.And. cTempSL1->L1_SITUA == SL4->L4_SITUA 
    	
     		RecLock("SL4",.F.)
     		
     		ConOut("Validando SL4...")
     		    		
         	If Empty(SL4->L4_FILIAL) 
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:="Cpo:  filial vazio / " 
	 	   	EndIf	
			If Empty(Sl4->L4_P_DOC)	  
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:=Alltrim(SL4->L4_P_OBS)+" Cpo:  documento vazio / " 
	 	   	EndIf	
			If Empty(SL4->L4_P_SERIE)	
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:=Alltrim(SL4->L4_P_OBS)+" Cpo:  serie vazio / " 			
	 	   	EndIf	
			If Empty(SL4->L4_DATA)	
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:=Alltrim(SL4->L4_P_OBS)+" Cpo:  data  vazio / "    			
	 	   	EndIf	
			If Empty(SL4->L4_VALOR)	
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:=Alltrim(SL4->L4_P_OBS)+" Cpo:  valor vazio / " 			
	 	   	EndIf	
			If Empty(SL4->L4_FORMA)
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:=Alltrim(SL4->L4_P_OBS)+" Cpo:  forma pagto. vazio / " 			
	 	   	EndIf	
			If Empty(SL4->L4_SITUA)
				SL4->L4_P_INT:="N"
	 	   		SL4->L4_P_OBS:=Alltrim(SL4->L4_P_OBS)+" Cpo:  situacao vazio / " 			
			EndIf  
			
	        nTotalSL4+=SL4->L4_VALOR        
			nParcelas++    
			 
			If SL1->L1_P_INT == "N"  
				SL4->L4_P_INT:="N"
		 		SL4->L4_P_OBS:=alltrim(SL4->L4_P_OBS)+" Verificar cupom (SL1) desse documento"
			EndIf
			
			SL2->(DbSetOrder(1)) 
    		If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_NUM))       
    						
				If SL2->L2_P_INT == "N"  
					SL4->L4_P_INT:="N"
			 		SL4->L4_P_OBS:=alltrim(SL4->L4_P_OBS)+" Verificar item (SL2) desse documento"
				EndIf 
			 		
			EndIf
			
			
			// Parcelas ok para integração
			If Empty(SL4->L4_P_INT)  
			
     	    	SL4->L4_P_INT :="P"	   	    	
     	    	GrvFixos("SL4")
     	    	     	    
     	    ELse   
     	    	
     	    	//Parcela com problema, itens e capa não podem ser integrados                  
     	    	
     	    	If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     				While SL2->(!EOF()) .And. SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	  				RecLock("SL2",.F.)
     	    			SL2->L2_P_INT:="N"
 			   			SL2->L2_P_OBS:=Alltrim(SL2->L2_P_OBS)+" Verificar parcelas (SL4) desse documento / "     	    		                  
     	    		    SL2->(MsUnlock()) 
     	    			SL2->(DbSkip())      
     	            EndDo
     	    	EndIf    
     	    
     	    	RecLock("SL1",.F.)
       			SL1->L1_P_INT:="N"
 				SL1->L1_P_OBS:=Alltrim(SL1->L1_P_OBS)+" Verificar parcelas (SL4) desse documento / "
       			SL1->(MsUnlock())   
       				   
     	    
     	    EndIF
			
			SL4->(MsUnlock())
	
	    	SL4->(DbSkip())   
	    	
		EndDo
	    
		//Valida a quantidade de parcelas entre a capa do cupon e as parcelas na tabela SL4
		If SL1->L1_PARCELA <> nParcelas 
		                                      
			RecLock("SL1",.F.)
    		SL1->L1_P_INT:="N"
 	   		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Quantidade de parcelas (SL4) diferente da capa (SL1)  / "
    		SL1->(MsUnlock())      
    		
    		If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     			While SL2->(!EOF()) .And. SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	  			RecLock("SL2",.F.)
     	    		SL2->L2_P_INT:="N"
 			   		SL2->L2_P_OBS:=alltrim(SL2->L2_P_OBS)+" Quantidade de parcelas (SL4) diferente da capa (SL1)  / "     	    		                  
     	   			SL2->(MsUnlock()) 
     	    		SL2->(DbSkip())      
     	      	EndDo
     	   EndIf   
     	   
     	   	SL4->(DbSetOrder(5))
    		If SL4->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     	
     			While SL4->(!EOF()) .And. SL4->L4_FILIAL+SL4->L4_P_SERIE+SL4->L4_P_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	   			RecLock("SL4",.F.)
     	    		SL4->L4_P_INT:="N"
 			   		SL4->L4_P_OBS:=alltrim(SL4->L4_P_OBS)+" Quantidade de parcelas (SL4) diferente da capa (SL1)  / "     	    		                  
     	   			SL4->(MsUnlock()) 
     	    		SL4->(DbSkip())      
     	      	EndDo
     	   
     	    EndIf   
     	   
		
		EndIf
		
		//Valida o total da capa com o total das parcelas 
		If nTotalSL1 <> nTotalSL4 
		
			RecLock("SL1",.F.)
    		SL1->L1_P_INT:="N"
 	   		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Total (SL1): "+alltrim(str(nTotalSL1))+" difere (SL4): "+alltrim(str(nTotalSL4))+" / "
    		SL1->(MsUnlock())      
    		
    		If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     			While SL2->(!EOF()) .And. SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	  			RecLock("SL2",.F.)
     	    		SL2->L2_P_INT:="N"
 			   		SL2->L2_P_OBS:=alltrim(SL2->L2_P_OBS)+" Total (SL1): "+alltrim(str(nTotalSL1))+" difere (SL4): "+alltrim(str(nTotalSL4))+" / "   	    		                  
     	   			SL2->(MsUnlock()) 
     	    		SL2->(DbSkip())      
     	      	EndDo
     	    EndIf
     	    
     	    SL4->(DbSetOrder(5))
    		If SL4->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     	
     			While SL4->(!EOF()) .And. SL4->L4_FILIAL+SL4->L4_P_SERIE+SL4->L4_P_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	   			RecLock("SL4",.F.)
     	    		SL4->L4_P_INT:="N"
 			   		SL4->L4_P_OBS:=alltrim(SL4->L4_P_OBS)+" Total (SL1): "+alltrim(str(nTotalSL1))+" difere (SL4): "+alltrim(str(nTotalSL4))+" / "    	    		                  
     	   			SL4->(MsUnlock()) 
     	    		SL4->(DbSkip())      
     	      	EndDo
     	   
     	    EndIf     
		
		
		EndIF  
		            
		nDif:=nTotalSL2-nTotalSL4  
		                
	    //Trata diferença de rateio de desconto entre item e parcelas.
		If ABS(nDif) > 1
		
			RecLock("SL1",.F.)            
    		SL1->L1_P_INT:="N"
 	   		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Total (SL2): "+alltrim(str(nTotalSL2))+" difere (SL4): "+alltrim(str(nTotalSL4))+" / "
    		SL1->(MsUnlock())      
    		
    		If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     			While SL2->(!EOF()) .And. SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	  			RecLock("SL2",.F.)
     	    		SL2->L2_P_INT:="N"
 			   		SL2->L2_P_OBS:=alltrim(SL2->L2_P_OBS)+" Total (SL2): "+alltrim(str(nTotalSL2))+" difere (SL4): "+alltrim(str(nTotalSL4))+" / "   	    		                  
     	   			SL2->(MsUnlock()) 
     	    		SL2->(DbSkip())      
     	      	EndDo
     	    EndIf
     	    
     	    SL4->(DbSetOrder(5))
    		If SL4->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     	
     			While SL4->(!EOF()) .And. SL4->L4_FILIAL+SL4->L4_P_SERIE+SL4->L4_P_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	   			RecLock("SL4",.F.)
     	    		SL4->L4_P_INT:="N"
 			   		SL4->L4_P_OBS:=alltrim(SL4->L4_P_OBS)+" Total (SL2): "+alltrim(str(nTotalSL2))+" difere (SL4): "+alltrim(str(nTotalSL4))+" / "    	    		                  
     	   			SL4->(MsUnlock()) 
     	    		SL4->(DbSkip())      
     	      	EndDo
     	   
     	    EndIf     
		
		
		EndIF

	
	Else     
	     
		//Não encontrou nenhuma parcela para o cupom
		RecLock("SL1",.F.)
    	SL1->L1_P_INT:="N"
 		SL1->L1_P_OBS:=alltrim(SL1->L1_P_OBS)+" Linha de parcelas (SL4) não encontrada / "
    	SL1->(MsUnlock())
    	
    	ConOut("Chave SL4 :"+alltrim(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC)+" não localizado no DbWall para validação")	
    	
    	If SL2->(DbSeek(cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC))
     		While SL2->(!EOF()) .And. SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC == cTempSL1->L1_FILIAL+cTempSL1->L1_SERIE+cTempSL1->L1_DOC  
     	 		RecLock("SL2",.F.)
     	   		SL2->L2_P_INT:="N"
 			   	SL2->L2_P_OBS:=alltrim(SL2->L2_P_OBS)+" Linha de parcelas (SL4) não encontrada / "     	    		                  
     	  		SL2->(MsUnlock()) 
     	    	SL2->(DbSkip())      
     	     EndDo
    	EndIf  
	
	EndIf  
	    
	//Pendente para integração, validado.
	If Empty(SL1->L1_P_INT)
		RecLock("SL1",.F.)
		SL1->L1_P_INT :="P"	
		GrvFixos("SL1")
   		SL1->(MsUnlock())
	EndIf
		
	cTempSL1->(DbSkip())
	  
EndDo  
     
        
Return  

/*
Funcao      : GERAWORK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para os temporarios de dados que serão gravados na produção
Autor     	: Tiago Luiz Mendonça
Data     	: 07/05/2012 
*/

*----------------------------*
  Static Function GERAWORK()
*----------------------------* 

Local  nX   
Local  cTMP

Local  aStruSL1 :={}      
Local  aStruSL2 :={} 
Local  aStruSL4 :={} 
Local  aStruSFI :={} 
Local  aStruCA  :={} 
                           

    If Select("cTempSL1") > 0
		cTempSL1->(DbCloseArea())	               
	EndIf
	
	//Cria estrutura baseada no SL1
	aStruSL1:= SL1->(dbStruct())      
     
    //Cria temporario dos cupons que serão integrados.                              
 	cQuery:=" SELECT * "
	cQuery+=" FROM SL1"+cEmp
	cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
    cQuery+=" AND L1_P_INT = 'P' "   
	
	TCQuery cQuery ALIAS "cTempSL1" NEW

	For nX := 1 To Len(aStruSL1)
	    If aStruSL1[nX,2]<>"C"
		    TcSetField("cTempSL1",aStruSL1[nX,1],aStruSL1[nX,2],aStruSL1[nX,3],aStruSL1[nX,4])
	    EndIf
	Next nX

	cTMP := CriaTrab(NIL,.F.)
	Copy To &cTMP
	dbCloseArea()
	dbUseArea(.T.,,cTMP,"cTempSL1",.T.) 
	
	Sl1->(DbGoTop())

    //Atualiza todos os cupons "P - pendentes" como S no muro de interação
	cQry := "Update SL1"+cEmp+" set L1_P_INT='S', L1_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where L1_P_INT='P'"
	  
	//Executa a query 
	TCSQLExec(cQry) 
		
	ConOut("Temporario SL1 gerado ...")
	       	 
    If Select("cTempSL2") > 0
		cTempSL2->(DbCloseArea())	               
	EndIf
	      
	//Cria estrutura baseada no SL2
	aStruSL2= SL2->(dbStruct())      
                                   
 	cQuery:=" SELECT  " 
 	cQuery+=" L2_FILIAL,	L2_NUM,		L2_PRODUTO,	L2_ITEM,	L2_DESCRI,	L2_QUANT,	L2_VRUNIT,	L2_VLRITEM,"	
	cQuery+=" L2_LOCAL,		L2_UM,		L2_DESC,	L2_VALDESC,	L2_TES	,	L2_CF,		L2_VENDIDO,	L2_DOC,	"
	cQuery+=" L2_SERIE,		L2_PDV,		L2_VALICM,"	
	cQuery+=" L2_VALIPI,	L2_VALISS,	L2_BASEICM,	L2_TABELA,	L2_STATUS,	L2_EMISSAO,"	
	cQuery+=" L2_DESCPRO,	L2_CUSTO1,	L2_CUSTO2,	L2_FLSERV,	L2_GRADE,	L2_VEND	,	L2_BCONTA,	L2_LOCALIZ,	"
	cQuery+=" L2_LOTECTL,	L2_NLOTE,	L2_NSERIE,	L2_PRCTAB,	L2_SITUA,	L2_RESERVA,	L2_LOJARES,	L2_PEDFAT,"	
	cQuery+=" L2_VALFRE,	L2_SEGURO,	L2_DESPESA,	L2_EMPRES,	L2_FILRES,	L2_ORCRES,	L2_PREMIO,	L2_ICMSRET,"	
	cQuery+=" L2_ENTREGA,	L2_BRICMS,	L2_VALPIS,	L2_VALCOFI,	L2_VALCSLL,	L2_VALPS2,	L2_VALCF2,	L2_BASEPS2,	"
	cQuery+=" L2_BASECF2,	L2_ALIQPS2,	L2_ALIQCF2,	L2_ITEMSD1,	L2_SEGUM,	L2_PEDRES,	L2_FDTENTR,	L2_CODCONT,"	
	cQuery+=" L2_NUMORIG,	L2_DOCPED,	L2_SERPED,	L2_VALEPRE,	L2_CODREG,	L2_MARCA,	L2_VLDESRE,	L2_TIPO	,"
	cQuery+=" L2_MODELO,	L2_ESPECIE,	L2_QUALIDA,	L2_SITTRIB,	L2_FDTMONT,	L2_VDMOST,	L2_DESCORC,	L2_PROVENT,"
	cQuery+=" L2_SERPDV,	L2_CONTDOC,	L2_PAFMD5,	L2_LEGCOD,	L2_TURNO,	L2_P_INT,	L2_P_OBS,	L2_DTVALID,"	
	cQuery+=" L2_CODLAN,	L2_VDOBS,	L2_PEDSC5,	L2_ITESC6,	L2_SEQUEN,	L2_SOLCOM,	L2_CODLPRE,	L2_GARANT,	"
	cQuery+=" L2_ITLPRE,	L2_MSMLPRE,	L2_REMLPRE,	L2_DTSDFID,	L2_NUMCFID,	L2_VLRCFID,	L2_PROCFID	 "
 	cQuery+=" FROM SL2"+cEmp
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' And " 
    cQuery+=" L2_P_INT = 'P' "   
	
	TCQuery cQuery ALIAS "cTempSL2" NEW

  
	For nX := 1 To Len(aStruSL2)
	    If aStruSL2[nX,2]<>"C"
		    TcSetField("cTempSL2",aStruSL2[nX,1],aStruSL2[nX,2],aStruSL2[nX,3],aStruSL2[nX,4])
	    EndIf
	Next nX

	cTMP := CriaTrab(NIL,.F.)
	Copy To &cTMP
	dbCloseArea()
	dbUseArea(.T.,,cTMP,"cTempSL2",.T.) 
	
    //Atualiza todos os itens de cupons "P - pendentes" como S no muro de interação
	cQry := "Update SL2"+cEmp+" set L2_P_INT='S', L2_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where L2_P_INT='P'"
	  
	//Executa a query
	TCSQLExec(cQry)  		
	
	ConOut("Temporario SL2 gerado ...")
	
	If Select("cTempSL4") > 0
		cTempSL4->(DbCloseArea())	               
	EndIf
	
	//Cria estrutura baseada no SL4
	aStruSL4:= SL4->(dbStruct())      
                                   
 	cQuery:=" SELECT * "
	cQuery+=" FROM SL4"+cEmp
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' And " 
    cQuery+=" L4_P_INT = 'P' "   
	
	TCQuery cQuery ALIAS "cTempSL4" NEW

  
	For nX := 1 To Len(aStruSL4)
	    If aStruSL4[nX,2]<>"C"
		    TcSetField("cTempSL4",aStruSL4[nX,1],aStruSL4[nX,2],aStruSL4[nX,3],aStruSL4[nX,4])
	    EndIf
	Next nX

	cTMP := CriaTrab(NIL,.F.)
	Copy To &cTMP
	dbCloseArea()
	dbUseArea(.T.,,cTMP,"cTempSL4",.T.)  
   
    //Atualiza todos as parcelas  "P - pendentes" como S no muro de interação
	cQry := "Update SL4"+cEmp+" set L4_P_INT='S', L4_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where L4_P_INT='P'"
	  
	//Executa a query
	TCSQLExec(cQry)  
	
	ConOut("Temporario SL4 gerado ...")

  	//Possui cliente novo para integração
	If lCliente 
	
		If Select("cTempSA1") > 0
			cTempSA1->(DbCloseArea())	               
		EndIf 
                                   
 		cQuery:=" SELECT * "
   		cQuery+=" FROM SA1"+cEmp
   		cQuery+=" WHERE " 
   		cQuery+=" A1_P_INT = 'P'  "   
	
		TCQuery cQuery ALIAS "cTempSA1" NEW

        While cTempSA1->(!EOF())
			aAdd(aCpsSA1,{cTempSA1->A1_CGC,cTempSA1->A1_FILIAL,UPPER(cTempSA1->A1_NOME),UPPER(cTempSA1->A1_NREDUZ),cTempSA1->A1_TIPO,;
			cTempSA1->A1_END,cTempSA1->A1_BAIRRO,cTempSA1->A1_CEP,cTempSA1->A1_EST,cTempSA1->A1_COD_MUN,cTempSA1->A1_MUN,cTempSA1->A1_DDD,cTempSA1->A1_TEL})
             
    		cTempSA1->(DbSkip())
 		EndDo  
 		
 		If Select("cTempSA1") > 0
			cTempSA1->(DbCloseArea())	               
		EndIf
 		
 		
 	EndIf    
 
 
Return  

/*
Funcao      : GRVFIXOS
Parametros  : cTp
Retorno     : Nenhum
Objetivos   : Funcão para validar os dados do cupom fiscal
Autor     	: Tiago Luiz Mendonça
Data     	: 07/05/2012   
Obs         : Todos os cadastros fixados devem existir no sistema, não existe validação para esses dados.
*/              

*------------------------------*
  Static Function GRVFIXOS(cTp)
*------------------------------* 


If cTp  == "SL1"                

    //Vendedor padrão no protheus
	SL1->L1_VEND    := "000001"  
	
	//Cliente padrão no protheus
	If Empty(SL1->L1_CLIENTE) 
		//Cliente padrão para as lojas - 000002
		SL1->L1_CLIENTE := "000002"  
	EndIf  
	          
	//Cliente padrão no Microvix
	If alltrim(SL1->L1_CGCCLI)=="22222222222" 
	   
		//Cliente padrão para as lojas - 000002
		SL1->L1_CLIENTE := "000002" 
		     
		//CPF de clientes em branco convertido para o da Shiseido. 
	    If SL1->L1_FILIAL == "04"
	    	SL1->L1_CGCCLI := "03973238000434" 
	    ElseIf  SL1->L1_FILIAL == "05" 
	    	SL1->L1_CGCCLI := "03973238000515" 
	    ElseIf  SL1->L1_FILIAL == "06"      
	    	SL1->L1_CGCCLI := "03973238000604" 	    
	    ElseIf  SL1->L1_FILIAL == "07" 
	    	SL1->L1_CGCCLI := "03973238000787" 
	    ElseIf  SL1->L1_FILIAL == "08"
	    	SL1->L1_CGCCLI := "03973238000868" 
	    EndIf 
	   	
	EndIf  
	
	SL1->L1_LOJA    := "01"
	SL1->L1_TIPOCLI := "R"  
	SL1->L1_DTLIM   := SL1->L1_EMISSAO 
	SL1->L1_PDV     := "01"
	SL1->L1_TIPO    := "V"
	SL1->L1_OPERADO := "CL2"
	SL1->L1_CONDPG  := "CN"
	SL1->L1_CONFVEN := "SSSSSSSSNSSS"
	SL1->L1_IMPRIME := "1S"
	SL1->L1_ESTACAO := "001"    
	SL1->L1_NUMCFIS := SL1->L1_DOC    
	SL1->L1_NUMMOV  := "1 "

	If Alltrim(SL1->L1_FORMPG) =="R$" 
		SL1->L1_DINHEIR := SL1->L1_VALMERC  
		SL1->L1_OUTROS  := 0
		SL1->L1_ENTRADA := SL1->L1_VALMERC  
	Else
   		SL1->L1_OUTROS  := SL1->L1_VALMERC		
	EndIf

	
	//Tratamento de desconto
	If !EMPTY(SL1->L1_DESCONT)        
	
		If Alltrim(SL1->L1_FORMPG) =="R$" 
			SL1->L1_DINHEIR := SL1->L1_VALMERC  
			SL1->L1_OUTROS  := 0
	   		SL1->L1_ENTRADA := SL1->L1_VLRTOT  - SL1->L1_DESCONT   //Valor de entrada deve considerar o total com o desconto
		Else
   	   		SL1->L1_OUTROS  := SL1->L1_VLRTOT  - SL1->L1_DESCONT 
		EndIf	
		
		SL1->L1_VLRTOT  := SL1->L1_VLRTOT  - SL1->L1_DESCONT   //Valor total deve considerar o desconto.            
   		SL1->L1_VALBRUT := SL1->L1_VALBRUT - SL1->L1_DESCONT   //Valor bruto deve considerar o desconto.    
   
	EndIf
	  
	//Existem cupons com mais de uma parcela com forma de Pg "R$" isso causa problema na gravação do SE1
	If SL1->L1_PARCELA <> 1   
		SL1->L1_FORMPG:="CC"	
	EndIf 
	

			                  
ElseIf cTp == "SL2"
	                
	//Campos obrigatórios
	SL2->L2_VENDIDO := "S" 
	SL2->L2_VENDIDO := "S"        
	SL2->L2_PDV		:= "01"
	SL2->L2_TABELA  := "1"     
	SL2->L2_GRADE   := "N"  
	SL2->L2_VEND    := "000001" 
	          
	If !Empty(SL2->L2_DESCPRO)
		SL2->L2_PRCTAB  :=  SL2->L2_VRUNIT  + SL2->L2_DESCPRO
	Else
		SL2->L2_PRCTAB  :=  SL2->L2_VRUNIT 	
	EndIf      
	
	SL2->L2_ITEMSD1 := "000000" 
	SL2->L2_LOCAL   := "11"  
	                          
	// TLM - 20130905 - Tratamento de SPED Fiscal -  Loja Pernanbuco
	If SL2->L2_FILIAL == "11"
		SL2->L2_SITTRIB := "F1" 
	Else
		SL2->L2_SITTRIB := "F" 	
	EndIf
	
	
	SL2->L2_PDV     := "01"  
	
ElseIf cTp == "SL4"

	//Preenche a administradora na forma de pagamento    
	IF Alltrim(SL4->L4_FORMA) = "CC"
		SL4->L4_ADMINIS := "001 - CREDITO " 
  	ElseIf Alltrim(SL4->L4_FORMA) = "DD"  
   		SL4->L4_ADMINIS := "002 - DEBITO " 
   	EndIf  
	
 	IF Empty(Alltrim(SL4->L4_OBS))
		SL4->L4_FORMA:="R$"  //Campo vazio padrão dinheiro.
	EndIf
				
	                                   
   
EndIf  




Return


/*
Funcao      : R7LOJ002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para cancelar os cupons 
Autor     	: Tiago Luiz Mendonça
Data     	: 07/05/2012 
Obs         : O "For" deverá ser alterado quando houver implantação de mais lojas/filiais.
*/              

*--------------------------*
  User Function R7LOJ002()
*--------------------------*  
 
Local cEmp 
Local cFil  
Local aCanc      := {}

Private lJob     := .F.                                      
Private LEXCAUTO := .T.  

//Testa para verificar se a chamada não está no Schedule
If Select("SX3")<=0
	lJob:=.T.
EndIf
     
If lJob

	//loop da loja 4 até a 14                           
	For i=4 to 14           
	
		//Testa novamente para setar o ambiente		                        
		If Select("SX3")<=0
			RpcSetType(3)       
		
			cFil:=If(len(alltrim(str(i)))>1,alltrim(str(i)),"0"+alltrim(str(i)))  // i=filial executada
			RpcSetEnv("R7",cFil)  //Abre ambiente em rotinas automáticas  
			lJob:=.T. 
		EndIf				                        
			  
		cEmp      :=  alltrim(cEmpAnt)+"0" 
		
		If Select("cTempCanc") > 0
			cTempCanc->(DbCloseArea())	               
		EndIf
		
		 //Abre conexão com banco de interface
		 nConWall := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 
		
		 If nConWall < 0
		 	ConOut("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix (1) ...  LOJA "+alltrim(cFil))
		 	Return .F.
		 Else
		 	ConOut("Conectado no Dbwall (1)...  LOJA "+alltrim(cFil))
		 EndIf   
			      
		 //Cria estrutura baseada no SL1
		 aStruCA:= SL1->(dbStruct())      
		                                   
		 cQuery:=" SELECT * "
		 cQuery+=" FROM CAN"+cEmp
		 cQuery+=" WHERE  CAN_P_INT=' ' AND " 
		 cQuery+=" CAN_SITUA = 'CA' AND CAN_FILIAL='"+cFil+"'"   
			
		 TCQuery cQuery ALIAS "cTempCanc" NEW
		
		  
		 For nX := 1 To Len(aStruCA)
		 	If aStruCA[nX,2]<>"C"
		 		TcSetField("cTempCanc",aStruCA[nX,1],aStruCA[nX,2],aStruCA[nX,3],aStruCA[nX,4])
			EndIf  
		 Next nX
		
		 cTMP := CriaTrab(NIL,.F.)
		 Copy To &cTMP
		 dbCloseArea()  
		 dbUseArea(.T.,,cTMP,"cTempCanc",.T.)
		 	 
	 	 //Fecha conexão 
		 If TcUnlink(nConWall) 
			   
			ConOut("Conexão com DbWall fechada (1) ... LOJA "+alltrim(cFil))
				                     
			//Verifica se existe cupons cancelados
			cTempCanc->(DbGoTop()) 
		 	IF (cTempCanc->(!BOF() .and. !EOF()))   
		  		 
		  		ConOut("Arquivo de cancelados gerado... LOJA "+alltrim(cFil))
		  		
		  		While cTempCanc->(!EOF())  
		  		
		  		    //Função padrão Totvs para abrir o indice na segunda execução da rotina com a função TcLink
		   			FRTADEFTAB(Posicione("SX2",1,"SL1","Alltrim(X2_ARQUIVO)"),"SL1",nConWall)  
				 	                     
				 	SL1->(DbSetOrder(2))
				 	If SL1->(DbSeek(cTempCanc->CAN_FILIAL+cTempCanc->CAN_SERIE+cTempCanc->CAN_DOC)) 
				 	 	 
				 	    //TLM 20130924 - Tratamento está causando problema na SD2 - todas as tabelas são canceladas com excessão da SD2.          
						//If !Empty(SL1->L1_PDV) 
	 					//	RecLock("SL1",.F.) 
	 					//	SL1->L1_PDV:=""
	 					//	SL1->(MsUnlock())	 					
	 				    //EndIf    
				 	 	     
				 	 	//Cancela os processados
				 	 	If alltrim(SL1->L1_SITUA)=="OK" .And. !Empty(SL1->L1_DOC)  
				 	   		//Função padrão responsavel pelo cancelamento dos cupons 
							aAdd(aCanc,SL1->L1_DOC)
				  			ConOut("Cupom "+SL1->L1_NUM+" cancelado...")		 	 	
							FRTEXCLUSA(SL1->L1_NUM)						  
				  		EndIf 
				  		
					EndIf                
					
					cTempCanc->(DbSkip())       
				
				EndDo    
				
		 	Else
		  		ConOut("Nenhum cupom  encontrado para cancelar... LOJA "+alltrim(cFil))
			EndIf			
				
		 EndIf 
		
		
		 //Abre conexão com banco de interface
		 nConWall := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 
		
		 If nConWall < 0
		 	MsgInfo("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix(2) ... LOJA "+alltrim(cFil))
		 	Return .F.                                                                                        
		 Else
		 	ConOut("Conectado no Dbwall(2)... LOJA "+alltrim(cFil))
		 EndIf   
			    
		 For n:=1 to Len(aCanc)
			
			//Atualiza os cupons cancelados no muro de interação   
			cQry := "Update CAN"+cEmp+" set CAN_P_INT='S', CAN_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where CAN_P_INT='  ' AND CAN_FILIAL='"+alltrim(cFil)+"'  AND CAN_DOC='"+aCanc[n]+"'" 
	   
			ConOut(cQry)	 		  
			//Executa a query
			TCSQLExec(cQry)  
		 
		 Next 
		 
		 //Fecha conexão 
		 If TcUnlink(nConWall) 
		 	ConOut("Conexão com DbWall fechada(2)... LOJA "+alltrim(cFil))
		 EndIf		                     
	       
		 //Limpa o array com as notas canceladas
		 aCanc:={}
		  
		 //Reseta o ambiente conectado
	  	 RpcClearEnv()
		 
	Next   

Else
			                        
	cEmp      :=  alltrim(cEmpAnt)+"0"
	cFil      :=  xFilial("SL1") 
		
	If Select("cTempCanc") > 0
		cTempCanc->(DbCloseArea())	               
	EndIf
		
	//Abre conexão com banco de interface
	nConWall := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 
		
	If nConWall < 0
		MsgInfo("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix (1) ...  LOJA "+cFil)
		Return .F.
	Else
		MsgInfo("Conectado no Dbwall...  LOJA "+cFil,"Shiseido")
	EndIf   
			      
	//Cria estrutura baseada no SL1
	aStruCA:= SL1->(dbStruct())      
		                                   
	cQuery:=" SELECT * "
	cQuery+=" FROM CAN"+cEmp
	cQuery+=" WHERE  CAN_P_INT=' ' AND " 
	cQuery+=" CAN_SITUA = 'CA' AND CAN_FILIAL='"+cFil+"'"   
			
	TCQuery cQuery ALIAS "cTempCanc" NEW
		
		  
	For nX := 1 To Len(aStruCA)
		If aStruCA[nX,2]<>"C"
			TcSetField("cTempCanc",aStruCA[nX,1],aStruCA[nX,2],aStruCA[nX,3],aStruCA[nX,4])
		EndIf  
	Next nX
		
	cTMP := CriaTrab(NIL,.F.)
	Copy To &cTMP
	dbCloseArea()  
	dbUseArea(.T.,,cTMP,"cTempCanc",.T.)
		 	 
	//FEcha conexão 
	If TcUnlink(nConWall) 
			   				                     
		//Verifica se existe redução Z para integrar
		cTempCanc->(DbGoTop()) 
		If (cTempCanc->(!BOF() .and. !EOF()))   
		  		 		  		
		 	While cTempCanc->(!EOF())  
		  		
		  		//Função padrão Totvs para abrir o indice na segunda execução da rotina com a função TcLink
		   		FRTADEFTAB(Posicione("SX2",1,"SL1","Alltrim(X2_ARQUIVO)"),"SL1",nConWall)  
				 	                     
				SL1->(DbSetOrder(2))
				If SL1->(DbSeek(cTempCanc->CAN_FILIAL+cTempCanc->CAN_SERIE+cTempCanc->CAN_DOC)) 
				 	 	     
					//TLM 20130924 - Tratamento está causando problema na SD2 - todas as tabelas são canceladas com excessão da SD2.  
					//If !Empty(SL1->L1_PDV) 
	 		   		//	RecLock("SL1",.F.) 
	 		   		//	SL1->L1_PDV:=""
		 			//	SL1->(MsUnlock())	 					
	 				//EndIf    

					//Cancela os processados
				 	If alltrim(SL1->L1_SITUA)=="OK" .And. !Empty(SL1->L1_DOC)  
				 		//Função padrão responsavel pelo cancelamento dos cupons 
						aAdd(aCanc,SL1->L1_DOC) 	 	
						FRTEXCLUSA(SL1->L1_NUM)						  
				  	EndIf 
				  		
				EndIf                
					
				cTempCanc->(DbSkip())       
				
			EndDo    
				
		Else
		 	MsgInfo("Nenhum cupom  encontrado para cancelar... LOJA "+cFil,"Shiseido")
		EndIf	
		
		//Conecta novamente no DBWall para atualizar os cupons que foram cancelados.
   		nConWall := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 
		  
		//Testa conexão
		If nConWall < 0
			MsgInfo("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix (1) ...  LOJA "+cFil)
			Return .F.
		EndIf   		
		
		//Loop nos documentos cancelados para atualizar o status na interface		
		For n:=1 to Len(aCanc)
			
			//Atualiza os cupons cancelados no muro de interação   
			cQry := "Update CAN"+cEmp+" set CAN_P_INT='S', CAN_P_OBS=' Data da integração "+DTOS(dDataBase)+" Hora: "+Time()+"' where CAN_P_INT='  ' AND CAN_FILIAL='"+cFil+"'  AND CAN_DOC='"+aCanc[n]+"'"  		  
			//Executa a query
			TCSQLExec(cQry)  
		 
		Next 
		 	                     
		//Limpa o array com as notas canceladas
		aCanc:={}
		               
		//Fecha conexão com o muro
		TcUnlink(nConWall) 
		  
	EndIf  
	
EndIf
	
Return  

/*
Funcao      : L1NUMORC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para retornar o numero do cupom L1_NUM
Autor     	: Tiago Luiz Mendonça
Data     	: 29/06/2012 
Obs         :
*/              
                                                              

*--------------------------*
  Static Function L1NUMORC  
*--------------------------*
   
Local cOrcam   
Local cMay
Local nTent
Local cJob  :="1"


cOrcam := GetSx8Num("SL1","L1_NUM")
  
 // Caso o SXE e o SXF estejam corrompidos cNumOrc estava se repetindo.
 cMay := Alltrim(xFilial("SL1"))+cOrcam
 FreeUsedCode()
 
 SL1->(dbSetOrder(1))
 // Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
 nTent := 0
 While SL1->(dbSeek(xFilial("SL1")+cOrcam)) .Or. !MayIUseCode(cMay)
 	
 	If ++nTent > 20
   		// "Impossivel gerar numero sequencial de orcamento correto."
   		If cJob == "1"
   			Connout("Impossivel gerar numero sequencial de orcamento correto.")
  		Else
    		MsgBox("Impossivel gerar numero sequencial de orcamento correto.","Integração Shiseido X Linx","ALERT")
   		Endif
  	Endif
  	
  	ConfirmSx8()
  	
  	cOrcam    := GetSx8Num("SL1","L1_NUM")
  	
  	FreeUsedCode()
  	
  	cMay := Alltrim(xFilial("SL1"))+cOrcam
 
 EndDo
 
 ConfirmSX8()
           

Return cOrcam    



