#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------------------------------
#DEFINE ENTER CHR(13)+CHR(10)
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Q6EST001
Realiza a importação dos arquivos de entrada de notas
                                                 
@author    Marcio Martins Pereira
@Manut     Sandro Silva 
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
User Function Q6EST001()

	Local oBtnSair
	Local oBtnImp
	Local nJanAltu := 140                                   
	Local nJanLarg := 650                                                     
	Local oBtnArq
	
	//Local lAtuDic := If(!ChkFile("Z0G"),AtuaDic(),) 
	
	Private oSayArq, oGetArq, cGetArq := Space(200)
	Private oDlg
	Private nQtdOk   	:= 0
	Private lSchedule	:= FWGetRunSchedule()
	Private cRootPath   := GetSrvProfString("RootPath", "\undefined")    //retorna o caminho do rootpath  
	Private lImposto 
	                                                                                
	//Pastas definidas no sftp temasek
	                                              
	Private cINT083Out := GetNewPar('EZ_6Q083'  ,'/pwldbms/PRD/WD/INT083/')
    Private cINT083In  := GetNewPar('EZ_6Q083IN','/pwldbms/PRD/WD/INT083/IN/')	
    Private cINT084    := GetNewPar('EZ_6Q084'  ,'/pwldbms/PRD/WD/INT084/')  
    
    //PREPARE ENVIRONMENT EMPRESA "6Q" FILIAL "01" TABLES "SD1","SF1","SA2","SED","SE4","SB1","SFT" MODULO "FAT"   
    
	//Pastas definidas no servidor HLB
	Private cLocArq 	:= '\6qsimport\entradas\'
	Private cLocRetErr 	:= '\6qsimport\retornos\errorlog\'
	Private cLocRetaTx	:= '\6qsimport\retornos\taxlines\'	
   	Private cLocLogs    := '\6qsimport\logs\'      
	Private cLocLgEr    := '\6qsimport\logs\erro\'  
	Private cLocAprov   := '\6qsimport\retornos\taxlines\aprovacao\'
	
	Private lForcaSchd	:= .T. //GetNewPar('EZ_6QSSCHD' ,.F.)	// Se .T. -> Força a Execução sem a intervenção do usuário
	Private cMsgPlan	:= ""
	Private cMsg		:= ""

	Private cLogSF1   := ''   
	Private cLogIMP   := ''
	Private aCpos     := {}
	Private aCposImp  := {}  
	Private aImpostos := {}   
	Private aFiles    := {}
	
	aAdd(aCpos,{"NUMERO"  	,"C", 9,0})
	aAdd(aCpos,{"SERIE" 	,"C", 3,0})
	aAdd(aCpos,{"FORNECEDOR","C",14,0})
	aAdd(aCpos,{"ITEMNF" 	,"C", 4,0})   
	aAdd(aCpos,{"DESCRICAO" ,"C",60,0})

	aAdd(aCposImp,{"DTEMISSAO" 	,"C",  8,0})
	aAdd(aCposImp,{"NUMERO" 	,"C",  9,0})
	aAdd(aCposImp,{"SERIE"		,"C",  3,0})
	aAdd(aCposImp,{"ESPECDOCU" 	,"C",  5,0})   
	aAdd(aCposImp,{"FORNECEDOR" ,"C", 14,0})
	aAdd(aCposImp,{"PRODUTO" 	,"C", 15,0})
	aAdd(aCposImp,{"LINEMEMO" 	,"C",200,0})
	aAdd(aCposImp,{"ITEMNF" 	,"C",  4,0})
	aAdd(aCposImp,{"CENTROCU" 	,"C",  9,0})
	aAdd(aCposImp,{"ITEMCONT" 	,"C",  9,0})
	aAdd(aCposImp,{"CLASSEVL" 	,"C",  9,0})
	aAdd(aCposImp,{"VALIRR" 	,"N", 16,2})   
	
	If lForcaSchd
	   lSchedule := .F.
	Endif
	
	//-----------------------------------------------------------------------------
	// Tratametno para criação das pastas -> Schedule
	//-----------------------------------------------------------------------------
	If !ExistDir('\6QSIMPORT\')
		MakeDir('\6QSIMPORT\')
	EndIf
	
	If !ExistDir(cLocArq)      //'\6QSIMPORT\ENTRADAS\' 
		MakeDir(cLocArq)
	EndIf	

	If !ExistDir(cLocLogs)     //'\6QSIMPORT\LOGS\'      
		MakeDir(cLocLogs)
	Endif

	If !ExistDir(cLocLgEr)     //'\6QSIMPORT\LOGS\ERRO\'  
		MakeDir(cLocLgEr)
	Endif 
	
	If !ExistDir(cLocRetErr)   //'\6QSIMPORT\RETORNOS\ERRORLOG\'
		MakeDir(cLocRetErr)
	Endif 
	
	If !ExistDir(cLocRetaTx)    //'\6QSIMPORT\RETORNOS\TAXLINES\'	
		MakeDir(cLocRetaTx)
	Endif  
	
	If !ExistDir(cLocAprov)     //'\6QSIMPORT\RETORNOS\TAXLINES\APROVACAO\'
		MakeDir(cLocAprov)
	Endif 	

	//-----------------------------------------------------------------------------
	
	If !lSchedule
	    //If Len(Directory ( cLocArq + "*.pgp")) = 0 
			//captura o arquivo encriptado no SFTP e baixa para o servidor HLB disponibilizando para integração.
			Processa( {|| U_CaptureSFTP(cLocArq,cINT083Out,cLocLogs,cLocLgEr)}, "Aguarde...", "Realizando download do arquivo...",.F.) 
		//ENDIF

		DEFINE MSDIALOG oDlg TITLE "Importação de Fornecedores e Notas Fiscais" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		@ 003, 003     GROUP oGrpPar TO 060, (nJanLarg/2)     PROMPT "Parâmetros: "         OF oDlg COLOR 0, 16777215 PIXEL
		//Caminho do arquivo
		@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"                  SIZE 060, 007 OF oDlg PIXEL
		@ 010, 070 MSGET      oGetArq VAR    cGetArq                     SIZE 240, 010 OF oDlg PIXEL
		oGetArq:bHelp := {||    ShowHelpCpo(    "cGetArq",;
		{"Arquivo CSV que se importado."+STR_PULA+"Exemplo: C:\teste.csv"},2,{},2)}		
		@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlg ACTION (U_EZPegaArq(cLocArq)) PIXEL
			
		@ 040, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlg ACTION (oDlg:End()) PIXEL
		@ 040, (nJanLarg/2)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"  SIZE 60, 014 OF oDlg ACTION (Processa({|| EZLeArquivo(), oDlg:End()}, "Aguarde...")) PIXEL
	
		ACTIVATE MSDIALOG oDlg CENTERED
	
	Else
		
		Conout("6QEST001 -> Schedule -> EZLeArquivo")
		Processa({|| EZLeArquivo()}, "Aguarde...")
        //EZLeArquivo()		
        //Encerra o PREPARE ENVIRONMENT    	    	
    	//RESET ENVIRONMENT
	Endif	

Return Nil
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EZLeArquivo
Realiza a leitura do(s) arquivo(s)

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function EZLeArquivo()

	Local nBytes
	Local oFile
	Local cLinha   := ''
	Local cSQLRmv  := ''
	Local nLinha   := 1
	Local nCont	   := 0
	Local nCabec   := 0 
	Local aVirgula := {}
	Local aFileLog := {}	 
	Local aFileTax := {}
	Local aFileDel := {}
	Local nX	   := 1
	Local nM	   := 1
	Local nN	   := 1 
    Local nU       := 1 
    Local nD       := 1    
    Local nE       := 1   
    Local nW       := 1
	Local nHnd     := 0
	Local cArqZG0  := GetNextAlias() 
	Local aDados   := {}
	Private aCabec := {}	// Armazeno o cabeçalho para saber a posição
	Private Itens  := {}	
	Private aItem  := {}
	//Private aFiles := {}
	Private nErros := 0
	Private cMsg   := ''	
    Private	cArqProc
	//--------------------------------------------------------------
	// Chamada para o FTP
	//--------------------------------------------------------------
	//-----------------------------------------------------------------------------
	// FTP para uso no schedule
	// Posso realizar uma chamada neste trecho para a rotina de busca no FTP
	//----------------------------------------------------------------------------- 
	//----------------------------------------------------------------------------- 
    aDir(cGetArq,aFiles,,,,,.F.)  //carrega o arquivo selecionado para integrar
	
	For nX := 1 to Len(aFiles)
	
	    U_EzDelZ0G(cLocArq+aFiles[nX]) // verifica se ja houve integração do arquivo, caso positivo remove todos os registros com status diferentes de '1' na tabela Z0G
		
		If lSchedule
		   cGetArq := cLocArq+aFiles[nX]                                                                     
		Endif		
		
		If File(cGetArq)
			oFile := FWFileReader():New(cGetArq)
			nBytes := ft_flastrec()
		Else
			Conout("Erro ao abrir: "+cGetArq,"Error")  
			Return
		Endif
				
		If Select("LOGTMP") > 0
		   LOGTMP->(DbCloseArea())
		EndIf

		If Select("IMPTMP") > 0
		   IMPTMP->(DbCloseArea())
		EndIf
		
		cLogSF1 := CriaTrab(aCpos,.T.)   
		dbUseArea(.T.,,cLogSF1,"LOGTMP",.F.,.F.) 

		cLogIMP := CriaTrab(aCposImp,.T.)   
		dbUseArea(.T.,,cLogIMP,"IMPTMP",.F.,.F.)		
		cArqProc := (cLocArq+aFiles[nX])    
		//-----------------------------------------------------------------------------
		If (oFile:Open())
			
			aCabec	:= {}
			aItens	:= {} 
			aItem	:= {}			
			aDados  := {}
			nLinha	:= 1
			
			ProcRegua(nBytes/30)
			
			conout("6QEST001 -> Processando arquivo: " + cGetArq)
					
			While (oFile:hasLine())
				
				cLinha := Alltrim(Upper(oFile:GetLine()))

				If nLinha < 3
				   nLinha++
				   ft_fskip()
				   Loop
				EndIf     	            

				IncProc("Lendo arquivo... Linha " + cValToChar(nLinha))

				aVirgula := {}
				aItens	 := {}
				nCont := 0 
				For ni:= 1 To Len(cLinha)
				
					If SubStr(cLinha,ni,1)==";"
						aAdd(aVirgula,ni)						
						If nLinha == 3						
							CpoDicion := AllTrim(SubStr(cLinha,If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1),aVirgula[Len(aVirgula)]-If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1)))														
							aAdd(aCabec, { 	CpoDicion , Posicione("SX3",2,CpoDicion,"X3_TIPO") })
						Else
							aAdd(aItens, AllTrim(SubStr(cLinha,If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1),aVirgula[Len(aVirgula)]-If(nCont==0,1,aVirgula[Len(aVirgula)-1]+1))) )
						Endif						
						nCont++																
					EndIf
					
				Next ni
				
				If Len(aItens) > 0 
					aAdd(aItem , aItens)
				Endif
				
				nLinha++ 
			
			Enddo			
			
		Endif  				
		
		oFile:Close()	
		
		If Len(aCabec) > 0 .and. Len(aItem) = 0    // Arquivo com cabeçalho e sem linhas de dados  
     	  Conout("6QEST001 -> Schedule -> Renomeado Arquivos: "+aFiles[nX]+" pasta: "+cLocArq)        	     	  			   	      
          fRename(cLocArq+aFiles[nX]+'.pgp',cLocArq+Substr(aFiles[nX]+".pgp",1,Rat(".pgp",aFiles[nX]+".pgp"))+'dcp',,.F.) //Renomeia o arquivo sem linha de dados criptografado na pasta entrada para decriptado.
          fRename(cLocArq+aFiles[nX],cLocArq+Substr(aFiles[nX],1,Rat(".csv",aFiles[nX]       ))+'int',,.F.) //Renomeia o arquivo sem linha de dados da pasta entrada para integrado.                
	      Conout("6QEST001 -> Schedule -> Arquivo "+aFiles[nX]+" Arquivo contendo somente cabecalho sem linha de dados.")   
   		  U_EZESTLOG("SF1",'', "NOTAS ENTRADA", "3",cLocArq+aFiles[nX],"Arquivo contendo somente cabecalho sem linha de dados.")      //Grava Log de processamento		    		 
	      MsgInfo("Arquivo contendo somente cabecalho sem linha de dados.","Geração de Notas")
		EndIf		
		
		If Len(aCabec) > 0 .and. Len(aItem) > 0 
			
			nPsNota  := Ascan( aCabec, {|x| Alltrim(x[1])  == "F1_DOC" 	  } )
			nPsSerie := Ascan( aCabec, {|x| Alltrim(x[1])  == "F1_SERIE"  } )
			nPsCNPJ	 := Ascan( aCabec, {|x| Alltrim(x[1])  == "A2_CGC" 	  } )
			nPsProd	 := Ascan( aCabec, {|x| Alltrim(x[1])  == "D1_COD" 	  } )
			nPsEspe  := Ascan( aCabec, {|x| Alltrim(x[1])  == "F1_ESPECIE"} ) 
			nPsMemo  := Ascan( aCabec, {|x| Alltrim(x[1])  == "D1_P_LMEMO"} )
			
			If nPsNota == 0 .Or. nPsSerie == 0 .Or. nPsCNPJ == 0
			   Conout("6QEST001 -> Erro ao carregar os registros, verifique o documento a ser importado")
			Else
			   Conout("6QEST001 -> Schedule -> Processando importacao de notas ")				
			   EZImpNfs(aCabec,aItem)
			Endif		  		
		
			GeraCSV()     // \6QSIMPORT\RETORNOS\ErrorLog\	                  - Gera error log se houver inconsistência na integração		
	
			GeraAprov()   // \6QSIMPORT\RETORNOS\ErrorLog\TaxLines\Aprovacao  - Gera Impostos para analise e aprovação   
                                                                       
            lReprocessa := .F.
   	        If LOGTMP->(Reccount()) > 0   //Arquivo com inconsistência 	                      
	   	       If MsgYesNo("Reprocessa","Arquivo com Rejeição.")  
  	   	          fRename(cLocArq+aFiles[nX]+'.pgp',cLocArq+Substr(aFiles[nX]+".pgp",1,Rat(".pgp",aFiles[nX]+".pgp"))+'dcp',,.F.)
			      lReprocessa := .T.
			   Else   		   
	   		      lReprocessa := .F.	   
			      fRename(cLocArq+aFiles[nX],cLocArq+Substr(aFiles[nX],1,Rat(".csv",aFiles[nX]))+'int',,.F.) //Renomeia o arquivo da pasta entrada para integrado.    
			      fRename(cLocArq+aFiles[nX]+'.pgp',cLocArq+Substr(aFiles[nX]+".pgp",1,Rat(".pgp",aFiles[nX]+".pgp"))+'dcp',,.F.) //Renomeia o arquivo criptografado na pasta entrada para decriptado.
			   EndIf
			Else
			    fRename(cLocArq+aFiles[nX],cLocArq+Substr(aFiles[nX],1,Rat(".csv",aFiles[nX]))+'int',,.F.) //Renomeia o arquivo da pasta entrada para integrado.    
			    fRename(cLocArq+aFiles[nX]+'.pgp',cLocArq+Substr(aFiles[nX]+".pgp",1,Rat(".pgp",aFiles[nX]+".pgp"))+'dcp',,.F.) //Renomeia o arquivo criptografado na pasta entrada para decriptado.
			EndIf
		    
		EndIf
		MsgInfo("Geração de Nota Concluído.","Geração de Notas")
		                                                                               
	Next nX		

	If lForcaSchd
		cMsgFim := ""
		If Len(aFiles) == 0
			cMsgFim := "Não Foram Encontrados arquivos na pasta" + CRLF
		Endif
		cMsgFim += "Processamento finalizado!"
	Endif

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EZImpNfs
Realiza a importação das notas de entrada

@author    Marcio Martins Pereira
@version   1.xx
@since     15/07/2019
/*/
//------------------------------------------------------------------------------------------
Static Function EZImpNfs(aCabec,aItem)

    Local lNota     := .F.
	Local nY  		:= 1
	Local nPs 		:= 0
	Local cCNPJ		:= ''
	Local cDoc		:= ''
	Local aLinAux	:= {}
	Local aRetorno	:= {}

	Private aCabSF1 		:= {}
	Private aIteSD1			:= {}	
	Private nP  	   		:= 1	
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile 	:= .T.
	
	ProcRegua(Len(aItem))	

	cCNPJ  := aItem[1,nPsCNPJ]
	cDoc   := aItem[1,nPsNota]
	cSerie := aItem[1,nPsSerie]					
	cMemo  := aItem[1,nPsMemo]					
	
	For nP := 1 to Len(aItem)		

		cCNPJ 	  := aItem[nP,nPsCNPJ]
		cDoc  	  := aItem[nP,nPsNota]
		cSerie    := aItem[nP,nPsSerie]
		cChaveDoc := Padr(cDoc,TamSX3("F1_DOC")[1])+Padr(cSerie,TamSX3("F1_SERIE")[1]) 
		cNotaClie := Padr(cDoc,TamSX3("F1_DOC")[1])+Padr(cSerie,TamSX3("F1_SERIE")[1])+cCNPJ   
		cMemo     := aItem[nP,nPsMemo]
		 
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3))
		If !SA2->(dbSeek(xFilial('SA2')+cCNPJ))			
			//-----------------------------------------------------------------------------------							
			//-> Tratamento do log para informar que o fornecedor não existe 
			//-----------------------------------------------------------------------------------			
			GrvLogTmp(cDoc,cSerie,cCNPJ,StrZero(1,4),"Supplier not found")			
			U_EZESTLOG("SF1", cNotaClie, "NOTAS ENTRADA", "0", cArqProc, "Supplier not found" )	// 0=Com Erro / 1=Com Sucesso		
		Else				
		    If Empty(SA2->A2_NATUREZ)
		       U_EZESTLOG("SF1", cNotaClie, "NOTAS ENTRADA", "0", cArqProc, "Fornecedor sem natureza cadastrada" )	// 0=Com Erro / 1=Com Sucesso
		    EndIf		   
		    
			If cDoc == aItem[nP,nPsNota]
				
				If Len(aCabSF1) == 0						
					IncProc("Nota n. " + cDoc)
					//Conout("6QEST001 -> Processando nota n. " + cDoc)						
					aAdd(aCabSF1,{"F1_FORNECE"	, SA2->A2_COD		,	Nil})
					aAdd(aCabSF1,{"F1_LOJA"		, SA2->A2_LOJA		,	Nil})  
					For nY := 1 to Len(aCabec)
						If Substr(aCabec[nY,1],1,3) == "F1_"
						If aCabec[nY,2]=="D"
							cConteudo := STOD(aItem[nP,nY])
						ElseIf aCabec[nY,2]=="N"
							cConteudo := Val(aItem[nP,nY])
						Else
							cConteudo := aItem[nP,nY]
						Endif							
						aAdd(aCabSF1,{Alltrim(aCabec[nY,1]),cConteudo,Nil})
						Endif
					Next nY
					aCabSF1 := FWVetByDic(aCabSF1, "SF1")
				Endif									                      				

            	If Empty(cMemo)
            	   aCabSF1 := {}
			       GrvLogTmp(cDoc,cSerie,cCNPJ,StrZero(1,4),"note without linememo")			
   			       U_EZESTLOG("SF1", cNotaClie, "NOTAS ENTRADA", "0", cArqProc, "Nota sem D1_P_LMEMO" )	// 0=Com Erro / 1=Com Sucesso            	
            	EndIf           	    
          	    /*
                lNota := NumNota(cMemo,Alltrim(Str(val(cdoc))) )          	
       		    
       		    If lNota  
       		       aCabSF1 := {}
				   GrvLogTmp(cDoc,cSerie,cCNPJ,StrZero(1,4),"wrong note number ")			
	 			   U_EZESTLOG("SF1", cNotaClie, "NOTAS ENTRADA", "0", cArqProc, "Numero de Nota errado." )	// 0=Com Erro / 1=Com Sucesso
			    EndIf            	            	
			    */            	            	
				aLinAux  := {}
				For nY := 1 to Len(aCabec)
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+aItem[nP,nPsProd]))					
					If Substr(aCabec[nY,1],1,3) == "D1_"
						If aCabec[nY,2]=="D"
							cConteudo := STOD(aItem[nP,nY])
						ElseIf aCabec[nY,2]=="N"
							cConteudo := Val(aItem[nP,nY])
						Else
							cConteudo := aItem[nP,nY]
						Endif
						aAdd(aLinAux,{Alltrim(aCabec[nY,1]), cConteudo ,Nil})
					Endif
				Next nY
				aadd(aIteSD1,FWVetByDic(aLinAux,"SD1",.F.,1))					
			Endif
		
		Endif
		
		cCNPJ  := aItem[nP,nPsCNPJ]
		cDoc   := aItem[nP,nPsNota]
		cSerie := aItem[nP,nPsSerie]
        cMemo  := aItem[nP,nPsMemo]

		If ( nP+1 > Len(aItem) )  .Or. ( cDoc <> aItem[nP+1,nPsNota] )
			
			If Len(aCabSF1) > 0 .And. Len(aIteSD1) > 0
				
				nPsCndpg  := Ascan( aCabSF1, 	{|x| Alltrim(x[1])  == "F1_COND" 	} )
				nPsForne  := Ascan( aCabSF1, 	{|x| Alltrim(x[1])  == "F1_FORNECE" } )
				nPsLoja   := Ascan( aCabSF1, 	{|x| Alltrim(x[1])  == "F1_LOJA" 	} )
				nPsDocSF1 := Ascan( aCabSF1, 	{|x| Alltrim(x[1])  == "F1_DOC" 	} )
				nPsSerSF1 := Ascan( aCabSF1, 	{|x| Alltrim(x[1])  == "F1_SERIE"	} )
				nPsIteSD1 := Ascan( aIteSD1[1], {|x| Alltrim(x[1])  == "D1_ITEM" 	} )
				
				dbSelectArea("SF1")
				SF1->(dbSetOrder(1))	// F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
				If !SF1->(dbSeek(xFilial("SF1")+cChaveDoc+SA2->(A2_COD+A2_LOJA)))
					
					lMsErroAuto := .F.
					
					aIteSD1 := FWVetByDic(aIteSD1,"SD1",.T.,1)             
										
					//-----------------------------------------------------------------------------
					// Apenas reposicionamentos para evitar erro no execauto
					//-----------------------------------------------------------------------------
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))

					dbSelectArea("SED")
					SED->(dbSetOrder(1))
					SED->(dbSeek(xFilial("SED")+SA2->A2_NATUREZ)) 
					
					aAdd(aCabSF1,{"E2_NATUREZ",SA2->A2_NATUREZ,Nil})																			
					
					dbSelectArea("SE4")
					SE4->(dbSetOrder(1))
					SE4->(dbSeek(xFilial("SE4")+aCabSF1[nPsCndpg,2]))
					
					Processa({|| MSExecAuto({|x, y, z| Mata103(x, y, z)}, aCabSF1, aIteSD1, 3) }, "Nota " + cDoc)
					//MSExecAuto({|x, y, z| Mata103(x, y, z)}, aCabSF1, aIteSD1, 3) 
					If lMSErroAuto
						aMsgProc  := {}
					   	cMsgProc  := ""
						aAutoErro := GetAutoGRLog()
						aMsgProc  := GeraLOG(aAutoErro)
						If Len(aMsgProc) > 0
							//-----------------------------------------------------------------------------------							
							//-> Tratamento do log para ERRO 
							//-----------------------------------------------------------------------------------
							GrvLogTmp(aCabSF1[nPsDocSF1,2],aCabSF1[nPsSerSF1,2],SA2->A2_CGC,aMsgProc[1],aMsgProc[2])
						    U_EZESTLOG("SF1",cNotaClie, "NOTAS ENTRADA", "0", cArqProc, aMsgProc[2] )	// 0=Com Erro / 1=Com Sucesso
					   EndIf
					Else
					   //-----------------------------------------------------------------------------------							
					   //-> Tratamento do log para operação com sucesso
					   //-----------------------------------------------------------------------------------
					   //GrvLogTmp(aCabSF1[nPsDocSF1,2],aCabSF1[nPsSerSF1,2],SA2->A2_CGC,"0000","Successfully processed")
					   //U_EZESTLOG("SFT", cNotaClie , "NOTAS ENTRADA", "1", cGetArq, "Documento aguardando Aprovação."	)	// 0=Com Erro / 1=Com Sucesso
					   GrvImpTmp(aCabSF1[nPsDocSF1,2],aCabSF1[nPsSerSF1,2],SA2->A2_CGC)
						U_EZESTLOG("SFT", cNotaClie , "NOTAS ENTRADA", "4", cArqProc, "Documento aguardando Aprovação."	)	// 0=Com Erro / 1=Com Sucesso	
					   /*
					   If !lImposto //sem imposto 							   
					      U_EZESTLOG("SF1", cNotaClie , "NOTAS ENTRADA", "1", cGetArq, "Arquivo Processado com sucesso."	)	// 0=Com Erro / 1=Com Sucesso
					   Else
                          U_EZESTLOG("SFT", cNotaClie , "NOTAS ENTRADA", "4", cGetArq, "Documento aguardando Aprovação."	)	// 0=Com Erro / 1=Com Sucesso					       
					   EndIf  
					   */ 
					EndIf                    
				Else
					//-----------------------------------------------------------------------------------							
					//-> Tratamento do log informando já foi realizado anteriormente
					//-----------------------------------------------------------------------------------				
					
					GrvLogTmp(aCabSF1[nPsDocSF1,2],aCabSF1[nPsSerSF1,2],SA2->A2_CGC,"0000","document already included")
					U_EZESTLOG("SF1", cNotaClie, "NOTAS ENTRADA", "3", cArqProc, "Documento ja incluido" )	// 0=Com Erro / 1=Com Sucesso				
					
				Endif
				
			Endif
			
			aCabSF1 := {}
			aIteSD1 := {}
						
		Endif
					
	Next nP

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvLogTmp
Grava o log de cada processamento no LOGTMP

@author    Marcio Martins Pereira
@version   1.xx
@since     22/07/2019
/*/
//------------------------------------------------------------------------------------------
Static Function GrvLogTmp(cDoc,cSerie,cCNPJ,cItemNF,cDescricao)

Reclock("LOGTMP",.T.)
LOGTMP->NUMERO		:= cDoc	
LOGTMP->SERIE		:= cSerie 
LOGTMP->FORNECEDOR	:= cCNPJ
LOGTMP->ITEMNF		:= cItemNF
LOGTMP->DESCRICAO 	:= cDescricao
LOGTMP->(MsUnlock())

Return


 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvImpTmp
Grava o log de cada processamento no IMPTMP

@author    Marcio Martins Pereira
@version   1.xx
@since     05/08/2019
/*/
//------------------------------------------------------------------------------------------
Static Function GrvImpTmp(cDoc,cSerie,cCNPJ)

Local aAreaSFT	:= GetArea()
Local nM		:= 0 
Local cSQL		:= ''
Local cAliasSFT := GetNextAlias()
Local aImpostos := { "D1_VALIRR" , "FT_VRETPIS" , "FT_VRETCOF" , "FT_VRETCSL" , "D1_VALISS" , "D1_VALINS" 	}
Local aDescImp  := { "IRRF" 	 , "PIS" 		, "COFINS" 		, "CSSL" 	  , "ISS" 		, "INSS"		}
Local aClassVal := { "SC1923" 	 , "SC1927"		, "SC1911" 		, "SC1914" 	  , "SC1924"	, "SC1922"		}

cSQL := " SELECT FT_EMISSAO, FT_NFISCAL, FT_SERIE, FT_ESPECIE, A2_CGC,A2_NREDUZ, FT_PRODUTO, B1_DESC, FT_ITEM, D1_CC, D1_CONTA, D1_ITEMCTA, D1_CLVL, " + CRLF 
cSQL += " D1_VALIRR, FT_VRETPIS, FT_VRETCOF, FT_VRETCSL, D1_VALISS, D1_VALINS " + CRLF
cSQL += " FROM " + RETSQLNAME("SFT") + " SFT (NOLOCK) " + CRLF
cSQL += " INNER JOIN " + RETSQLNAME("SD1") + " SD1 (NOLOCK) ON	SD1.D1_FILIAL	= SFT.FT_FILIAL " + CRLF

cSQL += " 								AND SD1.D1_FORNECE	= SFT.FT_CLIEFOR AND SD1.D1_LOJA	= SFT.FT_LOJA  " + CRLF
cSQL += " 								AND SD1.D1_DOC		= SFT.FT_NFISCAL AND SD1.D1_SERIE	= SFT.FT_SERIE " + CRLF 
cSQL += " 								AND SD1.D1_ITEM		= SFT.FT_ITEM  " + CRLF  
cSQL += " INNER JOIN " + RETSQLNAME("SA2") + " SA2 (NOLOCK) ON " + CRLF
cSQL += " SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SFT.FT_CLIEFOR AND SA2.A2_LOJA = SFT.FT_LOJA " + CRLF
cSQL += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 (NOLOCK) ON " + CRLF
cSQL += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SFT.FT_PRODUTO " + CRLF
cSQL += " WHERE	SFT.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = '' AND " + CRLF
cSQL += " SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND " + CRLF
cSQL += " SA2.A2_CGC = '" + cCNPJ + "' AND SFT.FT_NFISCAL = '" + cDoc + "' AND SFT.FT_SERIE = '" + cSerie + "' " + CRLF

DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasSFT), .F., .T.)

//lImposto := .F.
While !(cAliasSFT)->(Eof())
	For nM := 1 to Len(aImpostos) 
		//If (cAliasSFT)->&(aImpostos[nM]) > 0 
			Reclock("IMPTMP",.T.)
			IMPTMP->DTEMISSAO 	:= (cAliasSFT)->FT_EMISSAO
			IMPTMP->NUMERO	 	:= (cAliasSFT)->FT_NFISCAL
			IMPTMP->SERIE		:= (cAliasSFT)->FT_SERIE
			IMPTMP->ESPECDOCU 	:= (cAliasSFT)->FT_ESPECIE
			IMPTMP->FORNECEDOR 	:= (cAliasSFT)->A2_CGC
			IMPTMP->PRODUTO 	:= (cAliasSFT)->FT_PRODUTO
			IMPTMP->LINEMEMO 	:= aDescImp[nM]+' '+(cAliasSFT)->FT_NFISCAL+' '+(cAliasSFT)->A2_NREDUZ
			IMPTMP->ITEMNF	 	:= StrZero(nM,4) 
			IMPTMP->CENTROCU 	:= (cAliasSFT)->D1_CC
			IMPTMP->ITEMCONT 	:= (cAliasSFT)->D1_ITEMCTA
			IMPTMP->CLASSEVL 	:= aClassVal[nM]
			IMPTMP->VALIRR 		:= (cAliasSFT)->&(aImpostos[nM])*-1   
			//lImposto := .T. 
			IMPTMP->(MsUnlock())  
		//Endif
	Next nM
	(cAliasSFT)->(dbSkip())
Enddo

(cAliasSFT)->(dbCloseArea())

RestArea(aAreaSFT)   

Return   

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EZPegaArq
Pega os arquivos no diretório apontado pelo usuário

@author    Marcio Martins Pereira
@version   1.xx
@since     02/05/2019
/*/
//------------------------------------------------------------------------------------------
Static Function EZPegaArq()

	Local cArqAux := ""

    U_GerSFTP('GET',"*.pgp",cLocArq,cINT083Out,cLocLogs,cLocLgEr)
	cArqAux := cGetFile( "Arquivo Texto *.csv | *.csv",;    //Mascara
	"Arquivo...",;                        					//Tatulo
	,;                                   				    //Numero da mascara
	,;                                				        //Diretario Inicial
	.F.,;                   			    	         	//.F. == Abrir; .T. == Salvar 
	GETF_LOCALHARD,;              				       		//Diretrio full. Ex.: 'C:\TOTVS\arquivo.xlsx'
	.F.)                                					//Nao exibe diretrio do servidor

	cGetArq := PadR(cArqAux,200)
	oGetArq:Refresh()

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EZESTLOG
Rotina para gravação de logs.
@param		cTabela		- Tabela Principal, exemplo: "SF1"
			cChaveDoc		- Chave de pesquisa, exemplo F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA "123456789UNI00123401"
			cProcesso	- Nome da rotina	
			cStatus		- 0=Com Erro / 1=Com Sucesso / 3= Atencao / 4= Aprovação
			cArquivo	- Nome do arquivo que está sendo processado
			cMensagem	- Se "ok" vázio, Se Erro, apresenta error.log
@author    	Marcio Martins Pereira
@version   	1.xx
@since     	15/07/2019
/*/
//------------------------------------------------------------------------------------------
User Function EZESTLOG(cTabela, cChaveDoc, cProcesso, cStatus, cArquivo, cMensagem)

	Local 	_aArea 		:= GetArea()
	Default cMensagem   := ""

	Z0G->(DBSelectArea("Z0G"))
	RecLock("Z0G", .T.)
	Z0G->Z0G_FILIAL := xFilial("Z0G")
	Z0G->Z0G_DATA	:= Date()
	Z0G->Z0G_HORA	:= Time()
	Z0G->Z0G_USER	:= SubStr(cUsuario, 7, 15)
	Z0G->Z0G_TABELA	:= cTabela
	Z0G->Z0G_CHAVE	:= cChaveDoc
	Z0G->Z0G_PROCES	:= cProcesso
	Z0G->Z0G_STATUS	:= cStatus
	Z0G->Z0G_ARQUIV := cArquivo
	Z0G->Z0G_MENSAG	:= cMensagem
	Z0G->(MSUnLock())

	RestArea(_aArea)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraLOG
Função para tratar o log de processamento
@author     
@version    
@since     26/06/2019
/*/
//------------------------------------------------------------------------------------------
Static Function GeraLOG(aAutoErro)  
    
Local nPsOK       := 1    
Local nX      := 1  
Local aRetMsg := {}
Local cStatus := ''
Local cRet        := "" 
Local cRetInvalid := "" 
Local aRetAjuda   := {}

For nX := 1 to Len(aAutoErro)

   	// Retorno o Item que deu erro
   	nPsOK := At("D1_ITEM ",aAutoErro[nX])	// Manter essa definição assim "D1_ITEM " 
   	If nPsOK > 0
   		nPosCol := Rat(":=",aAutoErro[nX])
   		If nPosCol > 0 
   			nPosCol += 2
   			AADD(aRetMsg,StrZero(Val(SubStr(aAutoErro[nX],nPosCol)),4))
   		Endif
   	Endif
   	
   	// Retorno o erro efetivo   
   	If At("Invalido",aAutoErro[nX]) > 0
   		cConteudo := RetTraduc(Alltrim(aAutoErro[nX]),@cStatus)
   		If cStatus == '1'
   		   AADD(aRetMsg,StrZero(0,4))
   		Endif
   		AADD(aRetMsg,cConteudo)
    Endif
    
    If At("Erro -->",aAutoErro[nX]) > 0
	   cRetInvalid += Alltrim(aAutoErro[nX])
  	   AADD(aRetMsg,"Item Line Inconsistency")
	EndIf 
Next nX
 
                       
Return aRetMsg



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetTraduc
Retorna a tradução do erro "Invalido" apresentado no retorno do execauto. 

@author    
@version   
@since     18/07/2019
/*/
//------------------------------------------------------------------------------------------
Static Function RetTraduc(cConteudo,cStatus)

Local cCampo  := SubStr(cConteudo,24,10) 
Local cString := Posicione("SX3",2,cCampo,"X3_TITENG")
Local cRet 	  := ''

If !Empty(cString)
	cRet := cString + " - " + cCampo + StrTran(SubStr(cConteudo,34),"Invalido","Invalid")
	cStatus:= ''
Else
	cRet := StrTran(StrTran(StrTran(cConteudo,"- ",""),"=",""),"Invalido","Invalid")
	cStatus:= '1'
Endif    

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraCSV
Criação de CSV com a inconsistência gerada pelo MsExecAuto 

@author    
@version   
@since     25/06/2019
/*/
//------------------------------------------------------------------------------------------
Static function GeraCSV()

Local nX 
Local nHandle := 0					   
Local lSai    := .F.			
Local cText   := "WORKDAY_AP_INVOICES_"
Local nPsText := AT(cText,Upper(cGetArq))
Local cHora   := Alltrim(SubStr(cGetArq,nPsText+Len(cText),100))	// Retorno data e hora do arquivo original 
Local cNomLog := cLocRetErr+"Microsiga_InvoicesErrorLog_"+cHora 

If File(cNomLog)
   fErase(cNomLog)
EndIf

nHandle := If(LOGTMP->(Reccount()) > 0,FCreate(cNomLog,,,.F.),0)

If nHandle > 0
         
   // Grava o cabecalho do arquivo
   aEval(aCpos, {|e, nX| fWrite(nHandle, If(aCpos[nX,1]=="DESCRICAO","<Error Description>",e[1]) + If(nX <= Len(aCpos), ";", ""))})   
   fWrite(nHandle, ENTER ) // Pula linha
      
   LOGTMP->(dbgotop())
   while LOGTMP->(!Eof())
	
	For nX := 1 to Len(aCpos)	      
		IF aCpos[nX][2] == "C"
		   _uValor := LOGTMP->&(aCpos[nX][1])
		ELSE
		   _uValor := LOGTMP->&(aCpos[nX][1])
		ENDIF		
       
        If nX <= len(aCpos)           
           fWrite(nHandle, _uValor + ";" )                            	
        EndIf
	Next nX	 
	
    fWrite(nHandle,ENTER )
               
    LOGTMP->(dbskip())
               
   EndDo       
   
   Conout("6QEST001 -> Schedule -> Gerado Arquivo de Log: "+cNomLog+" Pasta: "+cLocRetErr)  
 
EndIf          
fClose(nHandle)     

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraAprov
Geração de CSV com os impostos para aprovação.

@author    
@version   
@since     07/01/2020
/*/
//------------------------------------------------------------------------------------------
Static function GeraAprov()

Local nHandle := 0
Local lSai    := .F.
Local nX
Local cText   := "WORKDAY_AP_INVOICES_"
Local nPsText := AT(cText,Upper(cGetArq))
//Local cHora   := StrTran(Time(),":","")       
Local cHora   := Alltrim(SubStr(cGetArq,nPsText+Len(cText),100))	// Retorno data e hora do arquivo original 
Local cNomLog := cLocAprov+"Microsiga_AP_Invoices_with_Tax_lines_"+cHora

If File(cNomLog)    //se houver arquivo processado excluir para 
   fErase(cNomLog)
EndIf

nHandle := If(IMPTMP->(Reccount()) > 0,FCreate(cNomLog,,,.F.),0)

If nHandle > 0
         
   // Grava o cabecalho do arquivo
   aEval(aCposImp, {|e, nX| fWrite(nHandle, e[1] + ";" )})
   fWrite(nHandle, ENTER ) // Pula linha
      
   IMPTMP->(dbgotop())
   while IMPTMP->(!Eof())
	
	For nX := 1 to Len(aCposImp)	      
		IF aCposImp[nX][2] == "C"
		   _uValor := Alltrim(IMPTMP->&(aCposImp[nX][1]))
		ELSE
			_uValor := Alltrim(Transform(IMPTMP->&(aCposImp[nX][1]),"9999999.99"))
		ENDIF				
        
        If nX <= len(aCposImp)
        	If nX == len(aCposImp)
        		fWrite(nHandle, _uValor )
        	Else
           		fWrite(nHandle, _uValor + ";" )
         	Endif
        EndIf
	Next nX
	               
    fWrite(nHandle,ENTER )
               
    IMPTMP->(dbskip())
               
   EndDo
   
   Conout("6QEST001 -> Schedule -> Gerado Arquivo de Tax Line: "+cNomLog)  
   
EndIf          
fClose(nHandle)     

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
//Função para utilização no Schedule 
@author Marcio Martins pereira
@since 07/05/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function SchedDef()

	Local _aPar 	:= {}		//array de retorno
	Local _cPerg	:= PadR("6QEST001", 10)

	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
				_cPerg	,;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//Titulo (para Relatorio)

Return _aPar
//--< fim de arquivo >----------------------------------------------------------------------


/*=====================================================================================================================================*/
// A T U A L I Z A Ç Ã O   D E   D I C I O N Á R I O 
/*=====================================================================================================================================*/
Static Function AtuaDic()  // Cria ou atualIza os objetos de dicionario

	Local i:=0
	Local aDados:={}
	Local nTamFil:=6
	Local cReservO := GetReserv( {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.} ) // Campo obrigatorio
	Local cReserv  := GetReserv( {.T.,.T.,.T.,.T.,.T.,.T.,.F.,.T.} ) // Campo NAO obrigatorio
	Local cUsado   := GetUsado()                                    // Campo Usado
	Local cNaoUsado:= GetUsado(,.F.)                                // Campo Não Usado
	
	Conout("ATUADIC " + Time())

	//
	// SX2 -> Z0G Tabela 
	//
	aDados:={}
	aAdd( aDados, { ;
		'Z0G'																	, ; //X2_CHAVE
		'LOG DE PROCESSAMENTO'													, ; //X2_NOME
		''																		, ; //X2_UNICO
		'C'																		, ; //X2_MODO
		'C'																		, ; //X2_MODOUN
		'C'																		} ) //X2_MODOEMP
	
	SX2->(dbSetOrder(1)) // X2_CHAVE
	SX2->(dbGoTop())
	cAux := SubStr(SX2->X2_ARQUIVO,4)
	for i:= 1 to len(aDados)
	    SX2->( RecLock("SX2", !dbSeek(aDados[i,1])))
	    SX2->X2_CHAVE   := aDados[i,1]
	    SX2->X2_ARQUIVO := aDados[i,1]+cAux
	    SX2->X2_NOME    := aDados[i,2]
	    SX2->X2_UNICO   := aDados[i,3]
	    SX2->X2_MODO    := aDados[i,4]
	    SX2->X2_MODOUN  := aDados[i,5]
	    SX2->X2_MODOEMP := aDados[i,6]
	    SX2->(dbUnlock())
	next

//-------------------------------------------------------------------------------------------------------------
// Z0G INICIO
//-------------------------------------------------------------------------------------------------------------

	//
	// Z0G Indices 
	//
	
	aDados:={}
	aadd(aDados, { ;
		'Z0G'																	, ;	// INDICE
		'1'																		, ;	// ORDEM
		'Z0G_FILIAL+DTOS(Z0G_DATA)+Z0G_HORA'									, ;	// CHAVE
		'DATA+HORA'    															, ;	// DESCRICAO
		'DATA+HORA'    															, ;	// DESCSPA
		'DATA+HORA'    															, ;	// DESCENG
		'U'																		, ; // PROPRI
		''																		, ; // F3
		''																		, ; // NICKNAME
		'S'																		} ) // SHOWPESQ
	*	
	SIX->(dbSetOrder(1)) // INDICE+ORDEM
	For i:= 1 to Len(aDados)
	    SIX->( RecLock("SIX",!dbSeek(aDados[i,1]+aDados[i,2])) )
	    SIX->INDICE     := aDados[i,1]
	    SIX->ORDEM      := aDados[i,2]
	    SIX->CHAVE      := aDados[i,3]
	    SIX->DESCRICAO  := aDados[i,4]
	    SIX->DESCSPA	:= aDados[i,5]
	    SIX->DESCENG	:= aDados[i,6]
	    SIX->PROPRI		:= aDados[i,7]
	    SIX->F3			:= aDados[i,8]
	    SIX->NICKNAME	:= aDados[i,9]
	    SIX->SHOWPESQ   := aDados[i,10]
	    SIX->(dbUnlock())
	Next
    	
	//
	// SX3 -> Z0G Campos 
	//
	
	SX3->(dbSetOrder(2)) // X3_CAMPO
	SX3->( dbSeek("F1_FILIAL"))
	nTamFil:=SX3->X3_TAMANHO
	aDados:={}
	
	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'01'													, ; //X3_ORDEM
		'Z0G_FILIAL'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		nTamFil													, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Filial'												, ; //X3_TITULO
		'Filial do Sistema'										, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cNaoUsado												, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'N'														, ; //X3_BROWSE
		''														, ; //X3_VISUAL
		''														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT
	
	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'02'													, ; //X3_ORDEM
		'Z0G_DATA'												, ; //X3_CAMPO
		'D'														, ; //X3_TIPO
		8														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Data'													, ; //X3_TITULO
		'Data'													, ; //X3_DESCRIC
		''														, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'03'													, ; //X3_ORDEM
		'Z0G_HORA'												, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		8														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Hora'													, ; //X3_TITULO
		'Hora'													, ; //X3_DESCRIC
		'99:99:99'												, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;	
		'Z0G'													, ; //X3_ARQUIVO
		'04'													, ; //X3_ORDEM
		'Z0G_USER'												, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		15														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Usuario'												, ; //X3_TITULO
		'Usuario'												, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'05'													, ; //X3_ORDEM
		'Z0G_TABELA'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		3														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Tabela'												, ; //X3_TITULO
		'Tabela'												, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'06'													, ; //X3_ORDEM
		'Z0G_CHAVE'												, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		50														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Chave'													, ; //X3_TITULO
		'Chave'													, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'07'													, ; //X3_ORDEM
		'Z0G_PROCES'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		20														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Chave'													, ; //X3_TITULO
		'Chave'													, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'08'													, ; //X3_ORDEM
		'Z0G_STATUS'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		1														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Status'												, ; //X3_TITULO
		'Status'												, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		'0=Processado com erro;1=Processado com sucesso'		, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'09'													, ; //X3_ORDEM
		'Z0G_MENSAG'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		60														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Mensagem'												, ; //X3_TITULO
		'Mensagem'												, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT

	aAdd( aDados, { ;
		'Z0G'													, ; //X3_ARQUIVO
		'09'													, ; //X3_ORDEM
		'Z0G_ARQUIV'											, ; //X3_CAMPO
		'C'														, ; //X3_TIPO
		150														, ; //X3_TAMANHO
		0														, ; //X3_DECIMAL
		'Arquivo'												, ; //X3_TITULO
		'Arquivo'												, ; //X3_DESCRIC
		'@!'													, ; //X3_PICTURE
		cReserv													, ; //X3_RESERV
		cUsado													, ; //X3_USADO	cUsado / cNaoUsado
		'U'														, ; //X3_PROPRI
		'S'														, ; //X3_BROWSE
		'V'														, ; //X3_VISUAL
		'R'														, ; //X3_CONTEXT
		''														, ; //X3_F3
		''														, ; //X3_VALID	
		''														, ; //X3_RELACAO
		''														, ; //X3_CBOX	
		1														, ; //X3_NIVEL
		''														, ; //X3_TRIGGER
		''														} ) //X3_OBRIGAT
	
	For i:= 1 to Len(aDados)
	    SX3->(RecLock("SX3", !dbSeek(padr(aDados[i,3],10))))
	    SX3->X3_ARQUIVO := aDados[i,1]
	    SX3->X3_ORDEM   := aDados[i,2]
	    SX3->X3_CAMPO   := aDados[i,3]
	    SX3->X3_TIPO    := aDados[i,4]
	    SX3->X3_TAMANHO := aDados[i,5]
	    SX3->X3_DECIMAL := aDados[i,6]
	    SX3->X3_TITULO  := aDados[i,7]
	    SX3->X3_DESCRIC := aDados[i,8]
	    SX3->X3_PICTURE := aDados[i,9]
	    SX3->X3_RESERV  := aDados[i,10]
	    SX3->X3_USADO   := aDados[i,11]
	    SX3->X3_PROPRI  := aDados[i,12]
	    SX3->X3_BROWSE  := aDados[i,13]
	    SX3->X3_VISUAL  := aDados[i,14]
	    SX3->X3_CONTEXT := aDados[i,15]
	    SX3->X3_F3      := aDados[i,16]
	    SX3->X3_VALID   := aDados[i,17]
	    SX3->X3_RELACAO := aDados[i,18]
	    SX3->X3_CBOX    := aDados[i,19]
	    SX3->X3_NIVEL	:= aDados[i,20]
	    SX3->X3_TRIGGER	:= aDados[i,21]
	    SX3->X3_OBRIGAT	:= aDados[i,22]
	    SX3->(dbUnlock())
	Next
		
	//
	// SX6 -> Parametros 
	//
	
	aDados:={}
	// CAMPOS CHAVE
	//			 X6_FILIAL	,X6_VAR			 C6_TIPO	X6_DESCRIC								X6_PROPRI, X6_CONTEUD		
	aadd(aDados,{"","EZ_6Q083"  ,"C","Dir. no SFTP p/ captura de Arquivos"             ,"U",'/scptstsftp/BEAMS/DR3/WD/INT083/'})
    aadd(aDados,{"","EZ_6Q083IN","C","Dir. no SFTP p/ envio Arquivos Log"	           ,"U",'/scptstsftp/BEAMS/DR3/WD/INT083/IN/'})	
    aadd(aDados,{"","EZ_6Q084"  ,"C","Dir. no SFTP p/ envio Tax Lines"    	           ,"U",'/scptstsftp/BEAMS/DR3/WD/INT084/'})
   	aadd(aDados,{"","EZ_6Q085"  ,"C","Dir. no SFTP p/ captura de Arquivos"             ,"U",'/scptstsftp/BEAMS/DR3/WD/INT085/'})     
    aadd(aDados,{"","EZ_6Q085IN","C","Dir. no SFTP p/ envio Arquivos Log"	           ,"U",'/scptstsftp/BEAMS/DR3/WD/INT085/IN/'})	 
	aadd(aDados,{"","EZ_6QSSCHD","L","Flag que indica se força a Execução sem a intervenção do usuário","U",".T."})
		
	For i:= 1 to Len(aDados)
	    SX6->(RecLock("SX6", !dbSeek(padr(aDados[i,2],10))))
	    SX6->X6_FIL		:= aDados[i,1]
	    SX6->X6_VAR		:= aDados[i,2]
	    SX6->X6_TIPO	:= aDados[i,3]
	    SX6->X6_DESCRIC	:= aDados[i,4]
	    SX6->X6_PROPRI	:= aDados[i,5]  
	    SX6->X6_CONTEUD	:= aDados[i,6]  
	    SX6->(dbUnlock())
	Next	
	
	// realizar a atualização do banco
	
	aDados:={"Z0G"}
	for i:= 1 to len(aDados)
		(aDados[i])->(DBCLOSEAREA())
	    X31UpdTable( aDados[i] )
	next
	
	Alert(__GetX31Trace())
    
	Conout("ATUADIC " + Time())
	
//-------------------------------------------------------------------------------------------------------------
// Z0G TERMINO
//-------------------------------------------------------------------------------------------------------------

Return .T.


/*=====================================================================================================================================*/
Static Function GetUsado(aDados,lUsado)
Local nCnt
Local cUsado := Space(103)
//Retorna um array com todos os modulos
Local aModulos := RetModName()

Default lUsado := .T.
Default aDados := {{}, .F.}

If !lUsado
   cUsado := Str2Bin(FirstBitOn(cUsado))
   Return cUsado
EndIf

//aDados[1][n] == Modulos selecionados
For nCnt := 1 To Len(aDados[1])
    If ValType(aDados[1][nCnt]) == "N"
       cUsado := Stuff(cUsado, aDados[1][nCnt] ,1,"x")
    Else
       cUsado := Stuff(cUsado, aScan(aModulos,{|x| x[2] == aDados[1][nCnt]}) ,1,"x")
    EndIf
Next
If Len(aDados[1]) == 0 //Se for zero sera utilizado para todos os modulos
   cUsado := Stuff(cUsado,100,1,"x")
EndIf
If aDados[2] //aDados[2] == .T. eh chave e .F. nao eh chave
   cUsado := Stuff(cUsado,101,1,"x")
EndIf
Return Str2Bin(FirstBitOn(cUsado))
/*=====================================================================================================================================*/

/*=====================================================================================================================================*/
Static Function GetReserv(aReserv)
Local nCnt, cReserv := Space(9)
For nCnt := 1 To Len(aReserv)
    If aReserv[nCnt]
       cReserv := Stuff(cReserv,nCnt,1,"x")
    EndIf
Next
Return X3Reserv(cReserv)
/*=====================================================================================================================================*/

/*
If File(UPPER(cArqLogEr)) .AND. lRet
MailLog(cArqLogEr,lRet)
lRet:= .F.            
ElseIf !lRet
MailLog(cArqLogEr,lRet)
EndIf
*/
Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EzDelZ0G
Remover do log o arquivo integrado,caso seja reintegração
                                                 
@author    Sandro Silva
@Manut     Sandro Silva 
@version   1.xx
@since     28/01/2020
/*/
//------------------------------------------------------------------------------------------
User Function EzDelZ0G(cArquiv)   

Local _aArea  := GetArea()     

DbSelectArea("Z0G")
Z0G->( DbSetOrder(3))	
If Z0G->(DbSeek(xFilial("Z0G")+cArquiv) )                                                               
   While Z0G->(!Eof()) .And. Z0G->Z0G_FILIAL = xFilial("Z0G") .And. Z0G->Z0G_ARQUIV = cArquiv
	   If Z0G->Z0G_STATUS $ '0,3,4'   //se houver status 0,4,3 remover do arquivo.
	      RecLock("Z0G", .F.)
	      Z0G->(DbDelete())
	      Z0G->(MSUnLock())	   
	   EndIf	
   	   Z0G->( DbSkip() )
   EndDo		
EndIf
RestArea(_aArea)
Return
                           

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} NumNota
Realiza validação entre o número da nota informada no line memo e a nota
                                                 
@author    Sandro Silva
@Manut     Sandro Silva 
@version   1.xx
@since     28/01/2020
/*/
//------------------------------------------------------------------------------------------
Static Function NumNota(cPalavra, cCaracter)

Local aArea     := GetArea()
Local nTotal    := 0
Local nAtual    := 0  
Local cString   := ''
Local lTotal    := .F.     
//Percorre todas as letras da palavra
For nAtual := 1 To Len(cPalavra)
    //Se a posição atual for igual ao caracter procurado, incrementa o valor    
    If !Isalpha( Substr( cPalavra, nAtual,1) )                                   
       If Substr( cPalavra, nAtual,1) <> "_"
	      cString += Substr(cPalavra, nAtual, 1)  
	   Else
		  Exit   	  
	   EndIf   
	EndIf
Next
If Len(Alltrim(cString)) > Len(Alltrim(cCaracter)) .Or. Len(Alltrim(cString)) < Len(Alltrim(cCaracter) )
   lTotal := .T.
EndIf
    
RestArea(aArea)
Return lTotal
