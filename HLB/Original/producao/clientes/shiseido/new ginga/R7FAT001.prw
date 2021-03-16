#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa R7FAT001∫ Autor ≥ Equipe de Desenvolvimento ∫ Data ≥ 12/10/11 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ NEW GINGA SHISHEIDO                                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/  

/*
Funcao      : R7FAT001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : New Ginga
Autor     	: Tiago Luiz MendonÁa                             
Data     	: 12/10/11                    
Obs         : Func„o chamada no JOB
TDN         : 
Revis„o     : Tiago Luiz MendonÁa	
Data/Hora   : 17/07/12
MÛdulo      : Generico
Cliente     : Shiseido
*/

*--------------------------*
  User Function R7FAT001()  
*--------------------------*  
          
Local lConnect := .F.

Private lJob 

Private dDataX  //Data base para geraÁ„o dos arquivos.    

Private cDirFTP := "\ftp\R7\GINGA\" 

Private  aArqs  := {}
   

//Testa para verificar se a chamada n„o estÅEno Schedule
If Select("SX3")<=0
	RpcSetType(2)
	RpcSetEnv("R7", "01")  //Abre ambiente em rotinas autom·ticas   
	lJob:=.T.
Else    

	If !(cEmpAnt $ "R7")
		MsgInfo("Especifico Shiseido ","HLB BRASIL")
		Return .F.
	EndIf	    
		       
	If !(MsgYesNO("Deseja realmente executar os arquivos do New Ginga","Shiseido"))
		lRet:=.F.
	EndIf    
	lJob:=.F.
EndIf  

dDataX:=dDataBase-1   //Data base para geraÁ„o dos arquivos. 
//dDataX:=CTOD('29/05/2017')  

//GeraÁ„o do arquivo M1 - Material Master
U_R7FAT0M1()                             
               
// GeraÁ„o do arquivo M4 - Whosale Retail Price Master
U_R7FAT0M4()  

// GeraÁ„o do arquivo M5 - Set Component Master
U_R7FAT0M5() 
                        
// GeraÁ„o do arquivo M6 - Retailer Master
U_R7FAT0M6() 

// GeraÁ„o do arquivo T17 - Sales Company Receipt Results (daily)
U_R7FATT17() 

// GeraÁ„o do arquivo T18 - Sales Company Inventory Results (daily)
U_R7FATT18() 

// GeraÁ„o do arquivo T21 - Sales Company Shipping Results (daily)
U_R7FATT21() 

// GeraÁ„o do arquivo T22 - Sales Company Returns Results (daily)
U_R7FATT22() 

// GeraÁ„o do arquivo T23 - Sales Out of Stock Results (daily)
U_R7FATT23() 

// GeraÁ„o do arquivo T26 - Store Sales (daily)
//U_R7FATT26()  - N„o serÅEenviado conforme email 16/02/2012.  
   
/*
dDataX:=CTOD('01/09/2015')  
While dDataX<(DATE()-1)
	U_R7FAT0M1()
	U_R7FAT0M4()  
	U_R7FAT0M5() 
	U_R7FAT0M6() 
	U_R7FATT17() 
	U_R7FATT18() 
	U_R7FATT21() 
	U_R7FATT22() 
	U_R7FATT23()  
	dDataX+=1
Enddo
*/

lConnect:=ConectaFTP()
            
If lConnect           
                            
	
	FTPDirChange(cDirFtp)  // Monta o diretÛrio do FTP, serÅEgravado na raiz "/"
	 
	For i=1 to Len(aArqs)	
		// Grava Arquivo no FTP
	 	If FTPUpLoad(cDirFTP+alltrim(aArqs[i]),alltrim(aArqs[i]))
	  		Conout("Arquivo "+alltrim(aArqs[i])+" gerado com sucesso no FTP interno.")   		
		Else 
 			Conout("O Arquivo "+alltrim(aArqs[i])+" n„o pode ser gravado no FTP interno") 
		EndIf  
	Next	
	
EndIf
	 
FTPDisconnect()   

If lJob                    
	RpcClearEnv()
EndIf   

Return


// Cadastro da linha do produto
*--------------------------*
  User Function R7FATC01()
*--------------------------*
                             
	If cEmpAnt $ "R7"                                                
		Axcadastro("ZX1","Linha de Produto")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf   
 
Return


// Beauty Method A - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function  R7FATC02() 
*--------------------------*
        
 	If cEmpAnt $ "R7"  
		Axcadastro("ZX2","Beauty Method A")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf
 
Return  


// Beauty Method B - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC03() 
*--------------------------*
        
    If cEmpAnt $ "R7"   
		Axcadastro("ZX3","Beauty Method B")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf 

Return 


// Multi Brand - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC04() 
*--------------------------*
      
	If cEmpAnt $ "R7"  
		Axcadastro("ZX4","Mult Brand")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf 

Return


// Sub Line  - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC05() 
*--------------------------*
    
    If cEmpAnt $ "R7"   
		Axcadastro("ZX5","Sub Line")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf 

Return


// Item Type - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC06() 
*--------------------------*
        
	If cEmpAnt $ "R7" 
		Axcadastro("ZX6","Item Type")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf        

Return


// Canal Visibility - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC07() 
*--------------------------*
        
   	If cEmpAnt $ "R7"    
		Axcadastro("ZX7","Canal Visibility")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf       

Return


// Canal DistribuiÁ„o - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC08() 
*--------------------------*
      
	If cEmpAnt $ "R7" 
		Axcadastro("ZX8","Canal DistribuiÁ„o")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf       

Return


// Ponto de Venda - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC09() 
*--------------------------*
        
	If cEmpAnt $ "R7" 
		Axcadastro("ZX9","Ponto de Venda")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf         

Return       


// Global Brand - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC0A() 
*--------------------------*
    	  
	If cEmpAnt $ "R7" 	
		Axcadastro("ZXA","Global Brand")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf         

Return


// Line Group - ManutenÁ„o da tabela fornececida pela Shiseido Jap„o
*--------------------------*
  User Function R7FATC0B() 
*--------------------------*
        
	If cEmpAnt $ "R7" 
		Axcadastro("ZXB","Line Group")
	Else
    	MsgInfo("Especifico Shiseido ","HLB")  
	EndIf         

Return


// GeraÁ„o do arquivo M1 - Material Master
*--------------------------*
  User Function R7FAT0M1()  
*--------------------------*   

	Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSB1Hdl
	Local nLogHdl
	Local cSB1txt := cDirArq+"M1_"+DTOS(dDataX+1)+".txt"
	Local cLinha
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	
	Private cLog 

	
	
	If !File(Alltrim(cDirLog)+"M1_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"M1_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"M1_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SB1QRY") > 0

 		SB1QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SB1QRY'

		SELECT
			'0' AS [DEL_FLAG],
			'   ' AS [REC_C_BY],         		
			//'001' AS [M_BRAN_C],
			B1_P_MULTB AS [M_BRAN_C],
			B1_COD AS [G_CODE],
			'1' AS [L_MAT_FLAG],
			B1_DESCING AS [ITEM_DES],
			B1_P_LGP AS [LINE_GRO],
			'   ' AS [C_ITEM_G],
			B1_P_BEA AS [B_MET_A],
			B1_P_BEB AS [B_MET_B],
			B1_P_ITEMT AS [ITEM_TYP],
			REPLICATE(' ', 50) AS [HAR_CODE],
			ENTRADAS.ENTRADA AS [ITEM_LAU],
			SAIDAS.SAIDA AS [ITEM_DIS],
			'10' AS [G_BRAND],
			B1_P_CJP AS [LINE],	
			B1_P_LGP AS [SUB_LINE],//REPLICATE(' ', 20) AS [SUB_LINE],
			REPLICATE(' ', 20) AS [B_CAT_L_1],
			REPLICATE(' ', 20) AS [B_CAT_L_2],
			REPLICATE(' ', 20) AS [B_CAT_L_3],
			'0' AS [G_FLAG]
		FROM
			SB1R70
		LEFT OUTER JOIN
			(
				SELECT
					CODIGO,
					ENTRADA
				FROM
					(	
						SELECT
							B1_COD AS [CODIGO],
							T1.ENTRADA AS [ENTRADA]
						FROM 
							SB1R70 
						LEFT OUTER JOIN
							(
								SELECT 
									D1_COD AS [CODIGO],
									MIN(D1_EMISSAO) AS [ENTRADA] 
								FROM 
									SD1R70 
								WHERE 
									D_E_L_E_T_<>'*' AND 
									D1_TIPO='N' 
								GROUP BY 
									D1_COD
							) AS T1
						ON
							B1_COD=T1.CODIGO
						WHERE
							D_E_L_E_T_<>'*'
					) AS T2
			) AS [ENTRADAS]
		ON
			B1_COD=ENTRADAS.CODIGO 
		LEFT OUTER JOIN
			(
				SELECT
					CODIGO,
					SAIDA
				FROM
					(	
						SELECT
							B1_COD AS [CODIGO],
							T1.SAIDA AS [SAIDA]
						FROM 
							SB1R70 
						LEFT OUTER JOIN
							(
								SELECT 
									D2_COD AS [CODIGO],
									MAX(D2_EMISSAO) AS [SAIDA] 
								FROM 
									SD2R70 
								WHERE 
									D_E_L_E_T_<>'*' AND 
									D2_TIPO='N' 
								GROUP BY 
									D2_COD
							) AS T1
						ON
							B1_COD=T1.CODIGO AND
							B1_MSBLQL='1'
						WHERE
							D_E_L_E_T_<>'*'
					) AS T2
			) AS [SAIDAS]
		ON
			B1_COD=SAIDAS.CODIGO 
    	WHERE
			D_E_L_E_T_<>'*' AND
			B1_TIPO IN ('ME', 'PP') AND
			//B1_TIPO='ME' AND
			B1_MSBLQL <>'1' AND
			B1_ATIVO <>'N' AND
			B1_GRUPO NOT IN (' ', '0001', '715') AND
			B1_COD <> 'TESTE'   
		Order by
		B1_COD	
			
			
	EndSql 
   	
	nSB1Hdl:= FCreate(cSB1txt) // Tenta criar o arquivo M1

	If nSB1Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo M1.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SB1QRY->(DbGoTop())
	
	If SB1QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo M1...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo M1.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
	//	FClose(nSB1Hdl)
	
	//	Return .F. 
	
	Endif

	cLinha := "F" + "M1" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 315)
	cLinha += cEOL
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo M1.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSB1Hdl)

		Return .F. 

	EndIf

   	While SB1QRY->(!Eof()) 	
   	            
   		cLinha := SB1QRY->DEL_FLAG + SB1QRY->REC_C_BY + SB1QRY->M_BRAN_C
   		cLinha += Alltrim(SB1QRY->G_CODE) + replicate(" ", 15 - len(Alltrim(SB1QRY->G_CODE))) 
   		cLinha += SB1QRY->L_MAT_FLAG
   		cLinha += Alltrim(left(SB1QRY->ITEM_DES, 40)) + replicate(" ", 40 - len(Alltrim(left(SB1QRY->ITEM_DES, 40))))
		cLinha += Alltrim(SB1QRY->LINE_GRO) + replicate(" ", 20 - len(Alltrim(SB1QRY->LINE_GRO)))
		cLinha += SB1QRY->C_ITEM_G
		cLinha += Alltrim(SB1QRY->B_MET_A) + replicate(" ", 20 - len(Alltrim(SB1QRY->B_MET_A)))
		cLinha += Alltrim(SB1QRY->B_MET_B) + replicate(" ", 20 - len(Alltrim(SB1QRY->B_MET_B)))		
		cLinha += Alltrim(SB1QRY->ITEM_TYP) + replicate(" ", 20 - len(Alltrim(SB1QRY->ITEM_TYP)))		
		cLinha += SB1QRY->HAR_CODE
   		cLinha += SB1QRY->ITEM_LAU + SB1QRY->ITEM_DIS
   		cLinha += Alltrim(SB1QRY->G_BRAND) + replicate(" ", 20 - len(Alltrim(SB1QRY->G_BRAND)))
   		cLinha += Alltrim(SB1QRY->LINE) + replicate(" ", 20 - len(Alltrim(SB1QRY->LINE)))
   		cLinha += SB1QRY->SUB_LINE + SB1QRY->B_CAT_L_1 + SB1QRY->B_CAT_L_2 + SB1QRY->B_CAT_L_3 + REPLICATE(" ", 16)  + SB1QRY->G_FLAG
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no M1...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo M1.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSB1Hdl)

			Return .F. 

		EndIf

		nContador := nContador + 1

   		SB1QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 339) + cEOL // RodapÅE
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo M1.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSB1Hdl)

		Return .F. 

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSB1Hdl)                                                                

	FClose(nLogHdl)                                                                
    
 	aAdd(aArqs,"M1_"+DTOS(dDataX+1)+".txt")
 
Return


// GeraÁ„o do arquivo M4 - Whosale Retail Price Master
*--------------------------*
  User Function R7FAT0M4() 
*--------------------------*
	
	Local cDirArq:="\ftp\R7\GINGA\"
    Local cDirLog:="\ftp\Log\"
	Local nSB1Hdl
	Local nLogHdl
	Local cSB1txt := cDirArq+"M4_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog 

	If !File(Alltrim(cDirLog)+"M4_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"M4_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"M4_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SB1QRY") > 0

		SB1QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SB1QRY'

		SELECT
			'0' AS [DEL_FLAG],
			B1_P_LGP AS [LINE],	
			'001' AS [M_BRAN_C],
			B1_COD AS [G_CODE],
			'780' AS [COM_CODE],
			'780' AS [SHIPP],
			ENTRADAS.ENTRADA AS [ITEM_LAU],
			SAIDAS.SAIDA AS [ITEM_DIS],
			'025' AS [RET_CURR],
			0 AS [RET_PRIC],
			'025' AS [WHO_CURR],
			D2_PRCVEN AS [WHO_PRIC],
			'025' AS [COG_CURR],
			T7.D1_VUNIT AS [COG_PRIC]
		FROM
			SB1R70
		LEFT OUTER JOIN
			(
				SELECT
					CODIGO,
					ENTRADA
				FROM
					(	
						SELECT
							B1_COD AS [CODIGO],
							T1.ENTRADA AS [ENTRADA]
						FROM 
							SB1R70 
						LEFT OUTER JOIN
							(
								SELECT 
									D1_COD AS [CODIGO],
									MIN(D1_EMISSAO) AS [ENTRADA] 
								FROM 
									SD1R70 
								WHERE 
									D_E_L_E_T_<>'*' AND 
									//D1_TP IN ('ME', 'PA') AND  
									D1_TP IN ('ME') AND
									D1_TIPO='N'
								GROUP BY 
									D1_COD
							) AS T1
						ON
							B1_COD=T1.CODIGO
						WHERE
							D_E_L_E_T_<>'*'
					) AS T2
			) AS [ENTRADAS]
		ON
			B1_COD=ENTRADAS.CODIGO 
		LEFT OUTER JOIN
			(
				SELECT
					CODIGO,
					SAIDA
				FROM
					(	
						SELECT
							B1_COD AS [CODIGO],
							T1.SAIDA AS [SAIDA]
						FROM 
							SB1R70 
						LEFT OUTER JOIN
							(
								SELECT 
									D2_COD AS [CODIGO],
									MAX(D2_EMISSAO) AS [SAIDA] 
								FROM 
									SD2R70 
								WHERE 
									D_E_L_E_T_<>'*' AND 
									//D2_TP IN ('ME', 'PA') AND
									D2_TP IN ('ME') AND
									D2_TIPO='N'
								GROUP BY 
									D2_COD
							) AS T1
						ON
							B1_COD=T1.CODIGO AND
							B1_MSBLQL='1'
						WHERE
							D_E_L_E_T_<>'*'
					) AS T2
			) AS [SAIDAS]
		ON
			B1_COD=SAIDAS.CODIGO 
		LEFT OUTER JOIN
			(
				SELECT
					T1.D2_COD AS D2_COD,
					T1.D2_EMISSAO AS D2_EMISSAO,
					T2.D2_PRCVEN AS D2_PRCVEN
				FROM
					(
						SELECT 
							D2_COD, 
							MAX(D2_EMISSAO) AS D2_EMISSAO
						FROM 
							SD2R70 
						WHERE 
							D_E_L_E_T_<>'*' AND
							//D2_TP IN ('ME', 'PA') AND    
							D2_TP IN ('ME') AND
							D2_TIPO='N'
						GROUP BY 
							D2_COD 
					) AS T1
				INNER JOIN
					(	
						SELECT
							D2_COD,
							MAX(D2_EMISSAO) AS D2_EMISSAO,
							AVG(D2_PRCVEN) AS D2_PRCVEN 
						FROM
							SD2R70
						WHERE
							D_E_L_E_T_<>'*' AND
							//D2_TP IN ('ME', 'PA') AND  
							D2_TP IN ('ME') AND
							D2_TIPO='N'
						GROUP BY 
							D2_COD
					) AS T2
				ON
					T1.D2_COD=T2.D2_COD AND 
					T1.D2_EMISSAO=T2.D2_EMISSAO
			) AS T4
		ON
			B1_COD=T4.D2_COD 
		LEFT OUTER JOIN
			(
				SELECT
					T5.D1_COD AS D1_COD,
					T5.D1_EMISSAO AS D1_EMISSAO,
					T6.D1_VUNIT AS D1_VUNIT
				FROM
					(
						SELECT 
							D1_COD, 
							MAX(D1_EMISSAO) AS D1_EMISSAO
						FROM 
							SD1R70 
						WHERE 
							D_E_L_E_T_<>'*' AND
							//D1_TP IN ('ME', 'PA') AND 
							D1_TP IN ('ME') AND
							D1_TIPO='N'
						GROUP BY 
							D1_COD 
					) AS T5
				INNER JOIN
					(	
						SELECT
							D1_COD,
							MAX(D1_EMISSAO) AS D1_EMISSAO,
							AVG(D1_VUNIT) AS D1_VUNIT
						FROM
							SD1R70
						WHERE
							D_E_L_E_T_<>'*' AND
							//D1_TP IN ('ME', 'PA') AND
							D1_TP IN ('ME') AND
							D1_TIPO='N'
						GROUP BY 
							D1_COD
					) AS T6
				ON
					T5.D1_COD=T6.D1_COD AND 
					T5.D1_EMISSAO=T6.D1_EMISSAO
			) AS T7
		ON
			B1_COD=T7.D1_COD 
		WHERE
			D_E_L_E_T_<>'*'	AND
			B1_TIPO IN ('ME','PP') AND 
			B1_MSBLQL <>'1' AND
			B1_ATIVO <>'N' AND
			B1_GRUPO NOT IN (' ', '0001', '715') 	
	   	ORDER BY B1_COD
								
	EndSql 
   	
	nSB1Hdl:= FCreate(cSB1txt) // Tenta criar o arquivo M4

	If nSB1Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo M4.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SB1QRY->(DbGoTop())
	
	If SB1QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo M4...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo M4.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
		//FClose(nSB1Hdl)
	
		//Return .F. 
	
	Endif

	cLinha := "F" + "M4" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 174)
	cLinha += cEOL
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo M4.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSB1Hdl)

		Return .F. 

	EndIf

   	While SB1QRY->(!Eof()) 	
   	            
   		cLinha := SB1QRY->DEL_FLAG
   		cLinha += Alltrim(SB1QRY->LINE) + replicate(" ", 20 - len(Alltrim(SB1QRY->LINE)))
   		cLinha += SB1QRY->M_BRAN_C
   		cLinha += Alltrim(SB1QRY->G_CODE) + replicate(" ", 15 - len(Alltrim(SB1QRY->G_CODE)))    		
		cLinha += SB1QRY->COM_CODE
		cLinha += Alltrim(SB1QRY->SHIPP) + replicate(" ", 20 - len(Alltrim(SB1QRY->SHIPP)))
   		cLinha += SB1QRY->ITEM_LAU + SB1QRY->ITEM_DIS
   		cLinha += Alltrim(SB1QRY->RET_CURR) + replicate(" ", 20 - len(Alltrim(SB1QRY->RET_CURR)))
   		cLinha += cvaltochar(Noround(SB1QRY->RET_PRIC, 2)) + replicate(" ", 18 - len(cvaltochar(Noround(SB1QRY->RET_PRIC, 2))))
   		cLinha += Alltrim(SB1QRY->WHO_CURR) + replicate(" ", 20 - len(Alltrim(SB1QRY->WHO_CURR)))
   		cLinha += cvaltochar(Noround(SB1QRY->WHO_PRIC, 2)) + replicate(" ", 18 - len(cvaltochar(Noround(SB1QRY->WHO_PRIC, 2))))
   		cLinha += Alltrim(SB1QRY->COG_CURR) + replicate(" ", 20 - len(Alltrim(SB1QRY->COG_CURR)))
   		cLinha += cvaltochar(Noround(SB1QRY->COG_PRIC, 2)) + replicate(" ", 18 - len(cvaltochar(Noround(SB1QRY->COG_PRIC, 2))))
   		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no M4...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo M4.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSB1Hdl)

			Return .F. 

		EndIf

		nContador := nContador + 1

   		SB1QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 198) + cEOL // RodapÅE
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo M4.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSB1Hdl)

		Return .F. 

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSB1Hdl)                                                                

	FClose(nLogHdl)                                                                

 	aAdd(aArqs,"M4_"+DTOS(dDataX+1)+".txt")
 
Return


// GeraÁ„o do arquivo M5 - Set Component Master
*--------------------------*
  User Function R7FAT0M5() 
*--------------------------*
	
	Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSB1Hdl
	Local nLogHdl
	Local cSB1txt := cDirArq+"M5_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog 

	If !File(Alltrim(cDirLog)+"M5_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"M5_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"M5_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SB1QRY") > 0

		SB1QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SB1QRY'

		SELECT
			'0' AS [DEL_FLAG],
			'780' AS [REC_C_BY],         		
			B1_P_LGP AS [LINE],	
			'001' AS [M_BRAN_C],
			B1_COD AS [G_CODE],
			ENTRADAS.ENTRADA AS [ITEM_LAU],
			SAIDAS.SAIDA AS [ITEM_DIS],
			'780' AS [SUB_R_CR],	
			B1_P_SUBL  AS [SUBLINE],
			'001' AS [SUB_M_BR],
			B1_COD AS [SUB_G_CO],
			B1_P_KQTD AS [QTD]
		FROM
			SB1R70
		LEFT OUTER JOIN
			(
				SELECT
					CODIGO,
					ENTRADA
				FROM
					(	
						SELECT
							B1_COD AS [CODIGO],
							T1.ENTRADA AS [ENTRADA]
						FROM 
							SB1R70 
						LEFT OUTER JOIN
							(
								SELECT 
									D1_COD AS [CODIGO],
									MIN(D1_EMISSAO) AS [ENTRADA] 
								FROM 
									SD1R70 
								WHERE 
									D_E_L_E_T_<>'*' AND 
									D1_TIPO='N' 
								GROUP BY 
									D1_COD
							) AS T1
						ON
							B1_COD=T1.CODIGO
						WHERE
							D_E_L_E_T_<>'*'
					) AS T2
			) AS [ENTRADAS]
		ON
			B1_COD=ENTRADAS.CODIGO 
		LEFT OUTER JOIN
			(
				SELECT
					CODIGO,
					SAIDA
				FROM
					(	
						SELECT
							B1_COD AS [CODIGO],
							T1.SAIDA AS [SAIDA]
						FROM 
							SB1R70 
						LEFT OUTER JOIN
							(
								SELECT 
									D2_COD AS [CODIGO],
									MAX(D2_EMISSAO) AS [SAIDA] 
								FROM 
									SD2R70 
								WHERE 
									D_E_L_E_T_<>'*' AND 
									D2_TIPO='N' 
								GROUP BY 
									D2_COD
							) AS T1
						ON
							B1_COD=T1.CODIGO AND
							B1_MSBLQL='1'
						WHERE
							D_E_L_E_T_<>'*'
					) AS T2
			) AS [SAIDAS]
		ON
			B1_COD=SAIDAS.CODIGO 
		WHERE
			D_E_L_E_T_<>'*'	AND
			//B1_DESC LIKE '%KIT%' AND
			B1_P_KIT = '1' AND 
			B1_TIPO IN ('ME', 'PP') AND
			//B1_TIPO='ME' AND
			B1_MSBLQL <>'1' AND
			B1_ATIVO <>'N' AND
			B1_GRUPO NOT IN (' ', '0001', '715') AND
			B1_COD <> 'TESTE'   	
		Order by
		B1_COD				
								
	EndSql 
   	
	nSB1Hdl:= FCreate(cSB1txt) // Tenta criar o arquivo M5

	If nSB1Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo M5.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SB1QRY->(DbGoTop())
	
	If SB1QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo M5...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo M5.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
		//FClose(nSB1Hdl)
	
		//Return .F. 
	
	Endif

	cLinha := "F" + "M5" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 83)
	cLinha += cEOL
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo M5.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSB1Hdl)

		Return .F. 

	EndIf

   	While SB1QRY->(!Eof()) 	
   	            
   		cLinha := SB1QRY->DEL_FLAG + SB1QRY->REC_C_BY
   		cLinha += Alltrim(SB1QRY->LINE) + replicate(" ", 20 - len(Alltrim(SB1QRY->LINE)))
   		cLinha += SB1QRY->M_BRAN_C
   		cLinha += Alltrim(SB1QRY->G_CODE) + replicate(" ", 15 - len(Alltrim(SB1QRY->G_CODE)))    		
   		cLinha += SB1QRY->ITEM_LAU + SB1QRY->ITEM_DIS + SB1QRY->REC_C_BY
   		cLinha += Alltrim(SB1QRY->LINE) + replicate(" ", 20 - len(Alltrim(SB1QRY->LINE)))
   		cLinha += SB1QRY->M_BRAN_C
   		cLinha += Alltrim(SB1QRY->G_CODE) + replicate(" ", 15 - len(Alltrim(SB1QRY->G_CODE)))    		
		cLinha += cvaltochar(noround(SB1QRY->QTD, 0)) + replicate(" ", 16 - len(cvaltochar(noround(SB1QRY->QTD, 0))))    				
   		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no M5...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo M5.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSB1Hdl)

			Return .F. 

		EndIf

		nContador := nContador + 1

   		SB1QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 107) + cEOL // RodapÅE
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo M5.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSB1Hdl)

		Return .F. 

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSB1Hdl)                                                                

	FClose(nLogHdl)
	
 	aAdd(aArqs,"M5_"+DTOS(dDataX+1)+".txt")	                                                                
 
Return

      
// GeraÁ„o do arquivo M6 - Retailer Master
*--------------------------*
  User Function R7FAT0M6() 
*--------------------------*
	
    Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSB1Hdl
	Local nLogHdl
	Local cSB1txt := Alltrim(cDirArq)+"M6_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog 

	If !File(Alltrim(cDirLog)+"M6_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"M6_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"M6_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SB1QRY") > 0

 		SB1QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SB1QRY'
    
		SELECT
			'0' AS [DEL_FLAG],
			'780' AS [SALES_CO],         		
			A1_COD AS [RET_COD],	
			A1_NOME AS [RET_NOM],
			A1_P_LJP AS [CHANNEL],
			'11' AS [DISTR_CH],
			' ' AS [CHAN_TP]	
		FROM
			SA1R70
		WHERE
			D_E_L_E_T_<>'*'	AND
			A1_MSBLQL <>'1' 
			ORDER BY A1_COD
								
	EndSql 
   	
	nSB1Hdl:= FCreate(cSB1txt) // Tenta criar o arquivo M6

	If nSB1Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo M6.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SB1QRY->(DbGoTop())
	
	If SB1QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo M6...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo M6.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
		//FClose(nSB1Hdl)
	
		//Return .F. 
	
	Endif

	cLinha := "F" + "M6" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 201)
	cLinha += cEOL
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo M6.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSB1Hdl)

		Return .F. 

	EndIf

   	While SB1QRY->(!Eof()) 	
   	            
   		cLinha := SB1QRY->DEL_FLAG + SB1QRY->SALES_CO
   		cLinha += Alltrim(SB1QRY->RET_COD) + replicate(" ", 15 - len(Alltrim(SB1QRY->RET_COD)))
   		cLinha += Alltrim(SB1QRY->RET_NOM) + replicate(" ", 100 - len(Alltrim(SB1QRY->RET_NOM)))
   		cLinha += Alltrim(SB1QRY->CHANNEL) + replicate(" ", 20 - len(Alltrim(SB1QRY->CHANNEL)))
   		cLinha += Alltrim(SB1QRY->DISTR_CH) + replicate(" ", 20 - len(Alltrim(SB1QRY->DISTR_CH)))
   		cLinha += Alltrim(SB1QRY->CHAN_TP) + replicate(" ", 20 - len(Alltrim(SB1QRY->CHAN_TP)))
		cLinha += replicate(" ", 20) // Point of Sales Type
		cLinha += replicate(" ", 20) // Global Key Customer
   		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no M6...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo M6.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSB1Hdl)

			Return .F. 

		EndIf

		nContador := nContador + 1

   		SB1QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 225) + cEOL // RodapÅE
	
 	If FWrite(nSB1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo M6.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSB1Hdl)

		Return .F. 

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSB1Hdl)                                                                

	FClose(nLogHdl) 
	
	aAdd(aArqs,"M6_"+DTOS(dDataX+1)+".txt")                                                               
 
Return
    

// GeraÁ„o do arquivo T17 - Sales Company Receipt Results (daily)
*--------------------------*
  User Function R7FATT17() 
*--------------------------*
      
	Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSD1Hdl
	Local nLogHdl
	Local cSD1txt := Alltrim(cDirArq)+"T17_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cDtParam := DtoS(dDataX)  // Dados utilizados para movimentaÁ„o data -1  
	Local cEOL := Chr(13) + Chr(10)   
	Local nContador := 0
	Local nFSeek
	Private cLog         

	If !File(Alltrim(cDirLog)+"T17_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"T17_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"T17_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	                                    
	
	If Select("SD1QRY") > 0

		SD1QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SD1QRY'

		SELECT 
			D1_COD,
			SUM(D1_QUANT) AS [D1QTD],
			SUM(D1_TOTAL) AS [D1VLR]   
		FROM
			SD1R70
		WHERE 
			D1_FILIAL = %exp:xFilial("SD1")%  AND 
			%notDel% AND 
			D1_DTDIGIT = %exp:cDtParam% AND
			D1_TIPO = 'N' AND
			D1_TES IN  ( SELECT F4_CODIGO FROM SF4R70 where F4_ATUATF='N' AND F4_ESTOQUE='S')
		GROUP BY 
			D1_COD
		ORDER 
			BY D1_COD
			
	EndSql 
   	
	nSD1Hdl:= FCreate(cSD1txt) // Tenta criar o arquivo T17

	If nSD1Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo T17.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SD1QRY->(DbGoTop())
	
	If SD1QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo T17...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo T17.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
		
		//FClose(nSD1Hdl)

		//Return .F.
	                            	
	Endif

	cLinha := "F" + "T17" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 86)
	cLinha += cEOL
	
 	If FWrite(nSD1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo T17.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSD1Hdl) 
		
		Return .F.

	EndIf

   	While SD1QRY->(!Eof())
   	
   	    cLinha := cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX))  	  	            
   		cLinha += "780" 
   		
   		SB1->(DbSetOrder(1))

   		If SB1->(DbSeek(xFilial("SB1")+SD1QRY->D1_COD))

			cLinha += Alltrim(SB1->B1_P_LGP) + Space(20 - Len(Alltrim(SB1->B1_P_LGP)))

		EndIf 
		 
		cLinha += "001"+Alltrim(SD1QRY->D1_COD) + Space(15 - Len(Alltrim(SD1QRY->D1_COD)))
		cLinha += "025" + Space(17)
		cLinha += Alltrim(Str(SD1QRY->D1QTD)) + Space(18 - Len(Alltrim(str(SD1QRY->D1QTD))))
		cLinha += Alltrim(Str(SD1QRY->D1VLR)) + Space(18 - Len(Alltrim(str(SD1QRY->D1VLR))))		
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSD1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no T17...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo T17.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSD1Hdl)

			Return .F.
		
		EndIf

		nContador := nContador + 1

   		SD1QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 111) + cEOL // RodapÅE
	
 	If FWrite(nSD1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo T17.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSD1Hdl)
                            
  		Return .F.
                            
	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSD1Hdl)                                                                

	FClose(nLogHdl)   
	
 	aAdd(aArqs,"T17_"+DTOS(dDataX+1)+".txt")	                 
	
Return

      
// GeraÁ„o do arquivo T18 - Sales Company Inventory Results (daily)
*--------------------------*
  User Function R7FATT18() 
*--------------------------*
	
	Local cDirArq:="\ftp\R7\GINGA\"
    Local cDirLog:="\ftp\Log\"
	Local nSB2Hdl
	Local nLogHdl
	Local cSB2txt := Alltrim(cDirArq)+"T18_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Local cAux
	Private cLog
	
	If !File(Alltrim(cDirLog)+"T18_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"T18_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"T18_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SB2QRY") > 0

		SB2QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SB2QRY'

		SELECT 
			SUM(B2_QATU) AS B2_QATU ,
			SUM(B2_VATU1) AS B2_VATU1,
			B2_COD  
		FROM
			SB2R70
		WHERE 
			B2_FILIAL = %exp:xFilial("SB2")%  
			AND D_E_L_E_T_<>'*'	AND
			SUBSTRING(B2_COD,1,2)<>'DE' AND B2_COD <> 'TESTE' 
			GROUP BY B2_COD
			ORDER BY B2_COD
			
	EndSql 
   	
	nSB2Hdl:= FCreate(cSB2txt) // Tenta criar o arquivo T18

	If nSB2Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo T18.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SB2QRY->(DbGoTop())
	
	If SB2QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo T18...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo T18.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
		//FClose(nSB2Hdl)

		//Return .F.
	
	Endif

	cLinha := "F" + "T18" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 86)
	cLinha += cEOL
	
 	If FWrite(nSB2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo T18.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSB2Hdl)
		
		Return .F.

	EndIf

   	While SB2QRY->(!Eof())
   	
   		SB1->(DbSetOrder(1))
   		If SB1->(DbSeek(xFilial("SB1")+SB2QRY->B2_COD))
   			If SB1->B1_MSBLQL == '1' .OR. SB1->B1_ATIVO == 'N'  .OR. !(SB1->B1_TIPO $ ('ME/PP/PA'))                 
   				SB2QRY->(DbSkip())
   				Loop
			EndIf   		
   		Else  //Se n„o tem o produto cadastrado pula o item
   			SB2QRY->(DbSkip())//RRP - 30/09/2015 - Ajuste para looping infinito.
   			Loop
   		EndIf
   	
   	    cLinha := cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX))  	
   	            
   		cLinha += "780" 
   		
   		If SB1->(DbSeek(xFilial("SB1")+SB2QRY->B2_COD))
   			cLinha += SB1->B1_P_LGP+Space(16)    
		EndIf 
		          
		If Len(Alltrim(SB1->B1_P_MULTB)) == 1
			cAux:= "00"+Alltrim(SB1->B1_P_MULTB)
		ElseIf Len(Alltrim(SB1->B1_P_MULTB)) == 2
			cAux:= "0"+Alltrim(SB1->B1_P_MULTB)
		Elseif Len(Alltrim(SB1->B1_P_MULTB)) == 3
			cAux:= SB1->B1_P_MULTB  
		Else
			cAux:= Space(3)		 
		EndIf	
			                                          
		cLinha += cAux
		cLinha += SB2QRY->B2_COD
		cLinha += "025"+Space(17)
		cLinha += Alltrim(Str(SB2QRY->B2_QATU))  + Space(18-Len(Alltrim(str(SB2QRY->B2_QATU))))
		cLinha += Alltrim(Str(SB2QRY->B2_VATU1)) + Space(18-Len(Alltrim(str(SB2QRY->B2_VATU1))))
		
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSB2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no T18...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo T18.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSB2Hdl)

			Return .F.

		EndIf

		nContador := nContador + 1

   		SB2QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 111) + cEOL // RodapÅE
	
 	If FWrite(nSB2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo T18.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSB2Hdl)
		
		Return .F.

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSB2Hdl)                                                                

	FClose(nLogHdl)
	
 	aAdd(aArqs,"T18_"+DTOS(dDataX+1)+".txt")	                                                                
 
Return


// GeraÁ„o do arquivo T21 - Sales Company Shipping Results (daily)
*--------------------------*
  User Function R7FATT21() 
*--------------------------*

	Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSD2Hdl
	Local nLogHdl
	Local cSD2txt := Alltrim(cDirArq)+"T21_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cDtParam := DtoS(dDataX) // Dados utilizados para movimentaÁ„o data -1 
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog 

	If !File(Alltrim(cDirLog)+"T21_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"T21_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"T21_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SD2QRY") > 0

 		SD2QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SD2QRY'

		SELECT 
			D2_COD,
			D2_CLIENTE,
			SUM(D2_QUANT) AS [D2QTD],
			SUM(D2_TOTAL) + SUM(D2_ICMSRET) + SUM(D2_VALIPI)  AS [D2VLR],
			SUM(D2_TOTAL) - SUM(D2_VALICM) - SUM(D2_VALPIS) - SUM(D2_VALCOF) AS [D2VLRLIQ]   //RSB - 26/07/2017 - PROJETO - Valor Liquido
			
		
		FROM
			SD2R70
		WHERE 
			D2_FILIAL = %exp:xFilial("SD2")%  
			AND %notDel%
			AND D2_EMISSAO = %exp:cDtParam%
			//AND D2_TP IN ('ME', 'PA', 'PP') 
			AND D2_TP = 'ME'
			AND D2_TES NOT IN ('76W','76N','63V','76T','85L','77T','78T','73V','56T','59V','67V','61L','75X','93X','54H','54I','69T','50O', '83W', '51R', '55R', '58Y', '5AG', '5GQ', '5NC', '75T','94D','51A','58Y','61L','63V','69T','73V','75T','76T','76U','76W','76X','76Y','76Z','77T','78T','85L','53M','59V') //RSB - 26/07/2017 -  Adicionado as TES
			AND D2_TIPO='N'
		GROUP BY 
			D2_COD,
			D2_CLIENTE
		ORDER 
			BY D2_COD
			
	EndSql 
   	
	nSD2Hdl:= FCreate(cSD2txt) // Tenta criar o arquivo T21

	If nSD2Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo T21.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SD2QRY->(DbGoTop())
	
	If SD2QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo T21...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo T21.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
		//FClose(nSD2Hdl)
		
		//Return .F.
	
	Endif

	cLinha := "F" + "T21" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 101)
	cLinha += cEOL

 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo T21.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSD2Hdl)

		Return .F.

	EndIf

   	While SD2QRY->(!Eof())
   	
   	    cLinha := cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX))  	
   	    cLinha += "780" 
   		
   		SB1->(DbSetOrder(1))
   		
   		If SB1->(DbSeek(xFilial("SB1")+SD2QRY->D2_COD))
   		
			cLinha += Alltrim(SB1->B1_P_LGP)  + Space(20 - Len(Alltrim(SB1->B1_P_LGP)))   			
		
		EndIf 
		
		cLinha += "001" 
		cLinha += Alltrim(SD2QRY->D2_COD)  + Space(15 - Len(Alltrim(SD2QRY->D2_COD)))
		cLinha += Alltrim(SD2QRY->D2_CLIENTE)  + Space(15-Len(Alltrim(SD2QRY->D2_CLIENTE)))
		cLinha += "025" + Space(17)
		cLinha += Alltrim(Str(SD2QRY->D2QTD))  + Space(18-Len(Alltrim(str(SD2QRY->D2QTD))))
		//cLinha += Alltrim(Str(SD2QRY->D2VLR)) + Space(18-Len(Alltrim(str(SD2QRY->D2VLR))))
		cLinha += Alltrim(Str(SD2QRY->D2VLRLIQ)) + Space(18-Len(Alltrim(str(SD2QRY->D2VLRLIQ)))) //RSB - 26/07/2017 - PROJETO - Valor Liquido
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no T21...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo T21.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSD2Hdl)

			Return .F. 

		EndIf

		nContador := nContador + 1

   		SD2QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 126) + cEOL // RodapÅE
	
 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo T21.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSD2Hdl)

		Return .F. 

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSD2Hdl)                                                                

	FClose(nLogHdl)  
	
 	aAdd(aArqs,"T21_"+DTOS(dDataX+1)+".txt")	                                                          
 
Return  


// GeraÁ„o do arquivo T22 - Sales Company Returns Results (daily)
*--------------------------*
  User Function R7FATT22() 
*--------------------------*  

	Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSD1Hdl
	Local nLogHdl
	Local cSD1txt := Alltrim(cDirArq)+"T22_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cDtParam := DtoS(dDataX) // Dados utilizados para movimentaÁ„o data -1 
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog         

	If !File(Alltrim(cDirLog)+"T22_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"T22_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"T22_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SD1QRY") > 0

 		SD1QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SD1QRY'

		SELECT 
			D1_COD,
			D1_FORNECE,
			SUM(D1_QUANT) AS [D1QTD],
			SUM(D1_TOTAL) + SUM(D1_ICMSRET) + SUM(D1_VALIPI) AS [D1VLR]   
		FROM
			SD1R70
		WHERE 
			D1_FILIAL = %exp:xFilial("SD1")%  
			AND %notDel%
			AND D1_EMISSAO = %exp:cDtParam%
			//AND D1_TP IN ('ME', 'PA', 'PP')   
			AND D1_TP='ME'
			AND D1_TIPO='D'
		GROUP BY 
			D1_COD,
			D1_FORNECE
		ORDER 
			BY D1_COD
			
	EndSql 
   	
	nSD1Hdl:= FCreate(cSD1txt) // Tenta criar o arquivo T22

	If nSD1Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo T22.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SD1QRY->(DbGoTop())
	
	If SD1QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo T22...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo T22.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
	                            
		//FClose(nSD1Hdl)
	
		//Return .F. 
	
	Endif

	cLinha := "F" + "T22" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 101)
	cLinha += cEOL
	
 	If FWrite(nSD1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo T22.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSD1Hdl)

		Return .F. 

	EndIf

   	While SD1QRY->(!Eof())
   	
   	    cLinha := cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX))  	
   	    cLinha += "780" 
   		
   		SB1->(DbSetOrder(1))
   		
   		If SB1->(DbSeek(xFilial("SB1")+SD1QRY->D1_COD))
   		
			cLinha += Alltrim(SB1->B1_P_LGP)  + Space(20 - Len(Alltrim(SB1->B1_P_LGP)))   			
		
		EndIf 
		
		cLinha += "001" 
		cLinha += Alltrim(SD1QRY->D1_COD)  + Space(15 - Len(Alltrim(SD1QRY->D1_COD)))
		cLinha += Alltrim(SD1QRY->D1_FORNECE)  + Space(15-Len(Alltrim(SD1QRY->D1_FORNECE)))
		cLinha += "025" + Space(17)
		cLinha += Alltrim(Str(SD1QRY->D1QTD))  + Space(18-Len(Alltrim(str(SD1QRY->D1QTD))))
		cLinha += Alltrim(Str(SD1QRY->D1VLR)) + Space(18-Len(Alltrim(str(SD1QRY->D1VLR))))
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSD1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no T22...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo T22.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSD1Hdl)

			Return .F. 

		EndIf

		nContador := nContador + 1

   		SD1QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 126) + cEOL // RodapÅE
	
 	If FWrite(nSD1Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo T22.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)
		
		FClose(nSD1Hdl)

		Return .F. 

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSD1Hdl)                                                                

	FClose(nLogHdl)  
	 
 	aAdd(aArqs,"T22_"+DTOS(dDataX+1)+".txt")	                                                      
 
Return  


// GeraÁ„o do arquivo T23 - Sales Company Out of Stock Results (daily)
*--------------------------*
  User Function R7FATT23() 
*--------------------------*

	Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"     
	Local nSD2Hdl
	Local nLogHdl
	Local cSD2txt := Alltrim(cDirArq)+"T23_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cDtParam := DtoS(dDataX)
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog 

	If !File(Alltrim(cDirLog)+"T23_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"T23_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"T23_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SD2QRY") > 0

 		SD2QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SD2QRY'

		SELECT 
			C9_PRODUTO,
			C9_CLIENTE,
			SUM(C9_QTDLIB) AS [QTD],
			SUM(C9_PRCVEN) AS [PRECO]
		FROM
			SC9R70
		WHERE
			C9_FILIAL = %exp:xFilial("SC9")%  
			AND %notDel%
			AND C9_DATALIB = %exp:cDtParam%
			AND C9_BLEST = '02'
		GROUP BY
			C9_CLIENTE,
			C9_PRODUTO
		ORDER BY
			C9_PRODUTO
	
	EndSql 
   	
	nSD2Hdl:= FCreate(cSD2txt) // Tenta criar o arquivo T23

	If nSD2Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo T23.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		Return .F. 

  	EndIf
	
	SD2QRY->(DbGoTop())
	
	If SD2QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo T23...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo T23.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)
    
//		FClose(nSD2Hdl)

		//Return .F.
	                            	
	Endif

	cLinha := "F" + "T23" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 101)
	cLinha += cEOL

 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo T23.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSD2Hdl)

		Return .F.

	EndIf

   	While SD2QRY->(!Eof())
   	
   	    cLinha := cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX))  	
   	    cLinha += "780" 
   		
   		SB1->(DbSetOrder(1))
   		
   		If SB1->(DbSeek(xFilial("SB1")+SD2QRY->C9_PRODUTO))
   		
			cLinha += Alltrim(SB1->B1_P_LGP)  + Space(20 - Len(Alltrim(SB1->B1_P_LGP)))   			
		
		EndIf 
		
		cLinha += "001" 
		cLinha += Alltrim(SD2QRY->C9_PRODUTO) + Space(15-Len(Alltrim(SD2QRY->C9_PRODUTO)))
		cLinha += Alltrim(SD2QRY->C9_CLIENTE) + Space(15-Len(Alltrim(SD2QRY->C9_CLIENTE)))
		cLinha += "025" + Space(17)
		cLinha += Alltrim(Str(SD2QRY->QTD))  + Space(18-Len(Alltrim(str(SD2QRY->QTD))))
		cLinha += Alltrim(Str(SD2QRY->PRECO)) + Space(18-Len(Alltrim(str(SD2QRY->PRECO))))
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no T23...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo T23.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nLogHdl)
			
			FClose(nSD2Hdl)

			Return .F.
    	
		EndIf

		nContador := nContador + 1

   		SD2QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 126) + cEOL // RodapÅE
	
 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo T23.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)		

		FClose(nSD2Hdl)

		Return .F.

	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSD2Hdl)                                                                

	FClose(nLogHdl)        
	                                                        
 	aAdd(aArqs,"T23_"+DTOS(dDataX+1)+".txt")
 
Return


// GeraÁ„o do arquivo T26 - Store Sales (daily)
*--------------------------*
  User Function R7FATT26() 
*--------------------------*  

    Local cDirArq:="\ftp\R7\GINGA\"
	Local cDirLog:="\ftp\Log\"
	Local nSD2Hdl
	Local nLogHdl
	Local cSD2txt := Alltrim(cDirArq)+"T26_"+DTOS(dDataX+1)+".txt
	Local cLinha
	Local cDtParam := DtoS(dDataX) // Dados utilizados para movimentaÁ„o data -1 
	Local cEOL := Chr(13) + Chr(10)
	Local nContador := 0
	Local nFSeek
	Private cLog 
                      
 
	If !File(Alltrim(cDirLog)+"T26_Log.txt") // Cria ou abre o arquivo de log
	
		nLogHdl := FCreate(Alltrim(cDirLog)+"T26_Log.txt")

	Else
	
		nLogHdl := FOpen(Alltrim(cDirLog)+"T26_Log.txt", 18)		

		nFSeek := FSeek(nLogHdl, 0, 2)

	EndIf
	
	If Select("SD2QRY") > 0

 		SD2QRY->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'SD2QRY'

		SELECT 
			D2_COD,
			D2_CLIENTE,
			SUM(D2_QUANT) AS [D2QTD],
			SUM(D2_TOTAL) AS [D2VLR]   
		FROM
			SD2R70
		WHERE 
			D2_FILIAL = %exp:xFilial("SD2")%  
			AND %notDel%
			AND D2_EMISSAO = %exp:cDtParam%
			//AND D2_TP IN ('ME', 'PA', 'PP') 
			AND D2_TP='ME'
			AND D2_TIPO='N'
		GROUP BY 
			D2_COD,
			D2_CLIENTE
		ORDER 
			BY D2_COD
			
	EndSql 
   	
	nSD2Hdl:= FCreate(cSD2txt) // Tenta criar o arquivo T26

	If nSD2Hdl == -1 // Caso n„o consiga...

		DataLog()
	   
	   	cLog += "N„o foi poss˙ìel criar o arquivo T26.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

    	Return .F.
	
  	EndIf
	
	SD2QRY->(DbGoTop())
	
	If SD2QRY->(Bof() .and. Eof()) // Caso n„o existam registros a serem transferidos para o arquivo T26...

    	DataLog()
	
		cLog += "N„o existem registros para gerar o arquivo T26.txt" + cEOL

		FWrite(nLogHdl, cLog)   

		FClose(nLogHdl)

		//FClose(nSD2Hdl)

		//Return .F.
			                            	
	Endif

	cLinha := "F" + "T26" + replicate(" ", 18) + cvaltochar(year(dDataX)) // CabeÁalho
	cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
	cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
	cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
	cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
	cLinha += replicate(" ", 101)
	cLinha += cEOL
	
 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o cabeÁalho...
 	
		DataLog()

		cLog += "N„o foi poss˙ìel criar o cabeÁalho do arquivo T26.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nLogHdl)

		FClose(nSD2Hdl)

		Return .F.

	EndIf

   	While SD2QRY->(!Eof())
   	
   	    cLinha := cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX))  	
   	    cLinha += "780" 
   		
   		SB1->(DbSetOrder(1))
   		
   		If SB1->(DbSeek(xFilial("SB1")+SD2QRY->D2_COD))
   		
			cLinha += Alltrim(SB1->B1_P_LGP)  + Space(20 - Len(Alltrim(SB1->B1_P_LGP)))   			
		
		EndIf 
		
		cLinha += "001" 
		cLinha += Alltrim(SD2QRY->D2_COD)  + Space(15 - Len(Alltrim(SD2QRY->D2_COD)))
		cLinha += Alltrim(SD2QRY->D2_CLIENTE)  + Space(15-Len(Alltrim(SD2QRY->D2_CLIENTE)))
		cLinha += "025" + Space(17)
		cLinha += Alltrim(Str(SD2QRY->D2QTD))  + Space(18-Len(Alltrim(str(SD2QRY->D2QTD))))
		cLinha += Alltrim(Str(SD2QRY->D2VLR)) + Space(18-Len(Alltrim(str(SD2QRY->D2VLR))))
		cLinha += cvaltochar(year(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX))
		cLinha += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) 
		cLinha += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0))
		cLinha += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
		cLinha += replicate("0", 3) + cEOL

	 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever um registro no T26...
	 	
			DataLog()

			cLog += "Erro ao gerar linha de dados do arquivo T26.txt" + cEOL

			FWrite(nLogHdl, cLog)

			FClose(nSD2Hdl)
    	
			Return .F.

		EndIf

		nContador := nContador + 1

   		SD2QRY->(DBSkip())

	EndDo     

	cLinha := "E" + cvaltochar(nContador) + replicate(" ", 10 - len(cvaltochar(nContador))) + replicate(" ", 126) + cEOL // RodapÅE
	
 	If FWrite(nSD2Hdl, cLinha) != Len(cLinha) // Caso n„o consiga escrever o rodapÅE.. 
        
		DataLog()

		cLog += "N„o foi poss˙ìel criar o rodapÅEdo arquivo T26.txt" + cEOL

		FWrite(nLogHdl, cLog)

		FClose(nSD2Hdl)

		Return .F.
		
	EndIf

	DataLog()

	cLog += "TÈrmino normal. Foram gravados " + cvaltochar(nContador) + " registros" + cEOL
	    
	FWrite(nLogHdl, cLog)	
	
	FClose(nSD2Hdl)                                                                

	FClose(nLogHdl)  

 	aAdd(aArqs,"T26_"+DTOS(dDataX+1)+".txt")	 
	                                                               
Return


// Data e hora para arquivos de log
*--------------------------*
  Static Function DataLog()  
*--------------------------*  

cLog := cvaltochar(year(dDataX+1)) + "-"
cLog += replicate("0", 2 - len(cvaltochar(month(dDataX)))) + cvaltochar(month(dDataX)) + "-"
cLog += replicate("0", 2 - len(cvaltochar(day(dDataX)))) + cvaltochar(day(dDataX)) + " " 
cLog += replicate("0", 2 - len(cvaltochar(noround(seconds()/3600, 0)))) + cvaltochar(noround(seconds()/3600, 0)) + ":"
cLog += replicate("0", 2 - len(cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)))) + cvaltochar(noround((seconds()/3600 - noround(seconds()/3600, 0))*60, 0)) + ":"
cLog += replicate("0", 2 - len(cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0)))) + cvaltochar(noround((seconds()/60 - noround(seconds()/60, 0))*60, 0))
cLog += chr(9)

Return      
    
/*
Funcao      : ConectaFTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Func„o para conectar no FTP
Autor     	: Tiago Luiz MendonÁa
Data     	: 15/04/2013 
Obs         :
*/   

*-----------------------------*
 Static Function ConectaFTP()
*-----------------------------*

Local cPath 	:= GETMV("MV_P_FTP") // "200.196.242.81"
Local clogin	:= GETMV("MV_P_USR") // "tiago"
Local cPass 	:= GETMV("MV_P_PSW") // "123" 
Local lRet		:= .F.

cPath  := Alltrim(cPath)
cLogin := Alltrim(cLogin)
cPass  := Alltrim(cPass) 

// Conecta no FTP
lRet := FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)                         