#include 'totvs.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³X19GRAVA  ºAutor  ³Eduardo C. Romanini º Data ³  30/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada para replicação das formulas para os demais ±±
±±º          ³ambientes, apos a inclusão.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

/*
Funcao      : X19GRAVA
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de Entrada para replicação das formulas para os demais ambientes, apos a inclusão 
Autor       : Eduardo C. Romanini 
TDN         : Disponibilizado um ponto de entrada na rotina de Cadastro de Fórmulas (CFGX019) a ser executado após a inserção, alteração ou exclusão do registro. Somente Eexecutado ao confirmar o cadastro.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Fiscal/Faturamento/Estoque.
*/     


*------------------------*
 User function X19Grava()
*------------------------*  

Local cAlias := ParamIxb[1]
Local nRecno := ParamIxb[2]
Local nOpc   := ParamIxb[3]  

Local cBanco := ""
Local cIpBco := "10.0.30.5"
Local cAmb   := GetEnvServer ()
Local cArqM4 := "SM4YY0"
Local cFilM4 := ""
Local cCodM4 := ""

Local nCon := 0
Local nDel := 0
Local nI   := 0
Local nP   := 0

Local aCpsM4  := {}
Local aAmb    := {}
Local aAreaM4 := SM4->(GetArea())

If nOpc == 3 //Inclusão

	//Verifica se a empresa aponta para a tabela generica.
	SX2->(DbSetOrder(1))
	If SX2->(DbSeek("SM4"))
		If Right(AllTrim(SX2->X2_ARQUIVO),3) <> "YY0"
			MsgInfo("Para essa empresa, a Formula não serEreplicada nos demais ambientes.","Atenção")
			Return
		EndIf  
	EndIf
	
	aAmb := {{"MSSQL7/Amb01_P10","AMB01/ENV01/ENV02/LOCAL1/SistemaAmb01"},;
	         {"MSSQL7/Amb02_P10","AMB02/ENV03/ENV04/LOCAL2/SistemaAmb02"},;
	         {"MSSQL7/Amb03_P10","AMB03/ENV05/ENV06/LOCAL3/SistemaAmb03"},;
	         {"MSSQL7/GT01"     ,"GT01"},;
	         {"MSSQL7/GT02"     ,"GT02"},;
	         {"MSSQL7/GT03"     ,"GT03"},;
	         {"MSSQL7/GTIS_P10" ,"GTIS"},; 
	         {"MSSQL7/GTRJ_P10" ,"GTRJ"},; 
	         {"MSSQL7/P11_01"   ,"P11_01/P11_01A/P11_01B/P11_01C/P11_01D"},; 
	         {"MSSQL7/P11_02"   ,"P11_02/P11_02A/P11_02B/P11_02C/P11_02D"},; 
	         {"MSSQL7/P11_03"   ,"P11_03/P11_03A/P11_03B/P11_03C/P11_03D"},; 
	         {"MSSQL7/P11_04"   ,"P11_04/P11_04A/P11_04B/P11_04C/P11_04D"},; 
	         {"MSSQL7/P11_05"   ,"P11_05/P11_05A/P11_05B/P11_05C/P11_05D"},; 
	         {"MSSQL7/P11_06"   ,"P11_06/P11_06A/P11_06B/P11_06C/P11_06D"},; 
	         {"MSSQL7/P11_07"   ,"P11_07/P11_07A/P11_07B/P11_07C/P11_07D"},; 
	         {"MSSQL7/P11_08"   ,"P11_08/P11_08A/P11_08B/P11_08C/P11_08D"},; 
		     {"MSSQL7/P11_09"   ,"P11_09/P11_09A/P11_09B/P11_09C/P11_09D"},; 
	         {"MSSQL7/P11_10"   ,"P11_10/P11_10A/P11_10B/P11_10C/P11_10D"},; 
	 	  	 {"MSSQL7/P11_11"   ,"P11_11/P11_11A/P11_11B/P11_11C/P11_11D"},; 
			 {"MSSQL7/P11_12"   ,"P11_12/P11_12A/P11_12B/P11_12C/P11_12D"},; 
	         {"MSSQL7/P11_13"   ,"P11_13/P11_13A/P11_13B/P11_13C/P11_13D"},; 
	         {"MSSQL7/P11_14"   ,"P11_14/P11_14A/P11_14B/P11_14C/P11_14D"},; 
	         {"MSSQL7/P11_15"   ,"P11_15/P11_15A/P11_15B/P11_15C/P11_15D"},; 
	         {"MSSQL7/P11_16"   ,"P11_16/P11_16A/P11_16B/P11_16C/P11_16D"},; 
	         {"MSSQL7/P11_17"   ,"P11_17/P11_17A/P11_17B/P11_17C/P11_17D"},;
	         {"MSSQL7/P11_18"   ,"P11_18/P11_18A/P11_18B/P11_18C/P11_18D"},;
	         {"MSSQL7/P11_19"   ,"P11_19/P11_19A/P11_19B/P11_19C/P11_19D"},;                                                                                                                                                         
	         {"MSSQL7/P11_20"   ,"P11_20/P11_20A/P11_20B/P11_20C/P11_20D"}}
	   
	//Retira o ambiente que estElogado do array aAmb.
	For nI := 1 To Len(aAmb)
		If AllTrim(Upper(cAmb)) $ aAmb[nI,2]
			nDel := nI
		EndIf
	Next   
	
	If nDel > 0
		aDel(aAmb,nDel)
		aSize(aAmb,Len(aAmb)-1)
	Else
		MsgInfo("Para esse ambiente a Formula não serEreplicada nos demais ambientes.","Atenção")
		Return Nil
	EndIf
	
	//Adiciona os campos para indice
	cFilM4 := xFilial("SM4")
	cCodM4 := (cAlias)->M4_CODIGO
	   
	//Adiciona os campos incluúos em um array.
	For nI := 1 To SM4->(FCount())
		aAdd(aCpsM4,{FieldName(nI),&('SM4->'+FieldName(nI))})    
	Next
	
	//Replicação da TES nos demais ambientes.   
	For nI := 1 To Len(aAmb)   
		cBanco := aAmb[nI][1]
	      
		//Realiza a conexão com o banco de dados.
		nCon := TCLink(cBanco,cIpBco)
	
		If nCon < 0
			MsgInfo("Erro ao conectar com o banco de dados: " + cBanco,"Atenção")
	         
		Else
	        
			If Select("M4TMP") > 0
				M4TMP->(DbCloseArea())
			EndIf
	
			//Abre a tabela do ambiente que serEatualizado.
			USE &cArqM4 ALIAS "M4TMP" Shared NEW VIA "TOPCONN" INDEX "SM4YY01"

			M4TMP->(RecLock("M4TMP",.T.))
	         
			For nP := 1 To Len(aCpsM4)
				If M4TMP->(FieldPos(aCpsM4[nP][1])) > 0
					M4TMP->(FieldPut(FieldPos(aCpsM4[nP][1]),aCpsM4[nP][2]))
				EndIf
			Next
	           
			M4TMP->(MsUnlock())
			M4TMP->(DbCloseArea())
	
			//Encerra a conexão
			TCunLink(nCon)
	        
			//Restaura a area.
			RestArea(aAreaM4)
			
			MsgInfo("Formula atualizada com sucesso em " + aAmb[nI][1],"Atenção")    
	
		EndIf
	     	
	Next
	
	If Select("M4TMP") > 0
		M4TMP->(DbCloseArea())
	EndIf

EndIf

Return 