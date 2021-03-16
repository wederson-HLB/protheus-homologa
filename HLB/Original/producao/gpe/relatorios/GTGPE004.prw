#include "rwmake.ch"
#include "protheus.ch"                      
/*
Funcao      : GTGPE004
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Payroll em Excel
Autor       : Jean Victor Rocha
Data/Hora   : 04/07/2013
Obs         : 
TDN         : 
Obs         : 
Cliente     : SteelCase
*/                 
*-----------------------*
User Function GTGPE004()
*-----------------------*
Local nHdl
Local cXML 			:= ""
Private cDest 		:= GetTempPath()
Private cPerg		:= "GTGPE004"
Private oExcel 		:= FWMSEXCEL():New()
Private cDest 		:= GetTempPath()
Private cArq 		:= "PayRoll.XML"
Private nBytesSalvo := 0 
Private aConsol 	:= {}
Private aTotCC	 	:= {}

//Validação da empresa que esta executando a função.
/*If !(cEmpAnt $ "9N/1Z")
	MsgAlert("Customização não disponivel para empresa!","HLB BRASIL")
	Return .T.
EndIf*/

//Tela com Parametros.         
AjustaSX1()

If !Pergunte(cPerg,.T.)
	Return()
EndIf

If EMPTY(MV_PAR08) .or. EMPTY(MV_PAR09)
	MsgAlert("Os campos 'Categorias' e 'Situacoes' são de preenchimento obrigatorio!","HLB BRASIL")
	Return .T.
EndIf

//Gera arquivo fisico. 
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 		:= FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
nBytesSalvo := FWRITE(nHdl, cXML ) 		// Gravação do seu Conteudo.
fclose(nHdl) 							// Fecha o Arquivo que foi Gerado	
    
	//Processamento ---------------------------------------------------------
	//Busca os Dados, tabela temporaria.
	GetInfo()
	
	QRY->(DbGoTop())
	If QRY->(!EOF())
		//Monta em XML
		cXML := WriteXML()	
		
		//Abre o Excel
		GrvXML(cXML)	
	Else
		MsgAlert("Sem dados para exibição, verificar parametros!","HLB BRASIL")
	EndIF
	
	//Fecha tabela Temporaria.
	If select("QRY")>0
		QRY->(DbCloseArea())
	Endif
	//---------------------------------------------------------
	
If nBytesSalvo >= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
  
Return .T.

/*
Funcao      : GetInfo()
Parametros  : 
Retorno     : 
Objetivos   : Função que executara a query na busca dos dados a serem impressos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GetInfo()
*------------------------------*
Local cQry 		:= ""
Local cVerba 	:= ""
Local cSit 		:= ""
Local cCat		:= ""
                           

cQry += " Select SRD.RD_FILIAL as FILIAL,SRD.RD_MAT as MAT
cQry += " From "+RetSqlName("SRD")+" SRD

//Tratamento que exigem que seja verificado junto ao cadastro de funcionarios, Inner Join, SRA - Cadastro de funcionarios.
If !EMPTY(MV_PAR08) .or. !EMPTY(MV_PAR09)
	cQry += " inner join (Select * From "+RetSqlName("SRA")+" Where D_E_L_E_T_ <> '*'
	If !EMPTY(MV_PAR08)//Situacoes a Imp. ?
		cSit := ""
		For nFor := 1 To Len(MV_PAR08)
			cSit += "'"+Subs(MV_PAR08,nFor,1)+"'"
			cSit += "," 
		Next nFor
		cSit := LEFT(cSit,LEN(cSit)-1)
		cQry += " AND RA_SITFOLH in ("+cSit+")
	EndIf
	If !EMPTY(MV_PAR09)//Categorias a Imp. ? 
		cCat := ""
		For nFor := 1 To Len(MV_PAR09)
			cCat += "'"+Subs(MV_PAR09,nFor,1)+"'"
			cCat += "," 
		Next nFor
		cCat := LEFT(cCat,LEN(cCat)-1)
		cQry += " AND RA_CATFUNC in ("+cCat+")
	EndIf
	cQry += ") as SRA on SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT" 
	
EndIF

cQry += " Where SRD.D_E_L_E_T_ <> '*'  
                   
//ANO
If !EMPTY(MV_PAR01)
	cQry += " AND LEFT(SRD.RD_DATARQ,4) = '"+MV_PAR01+"'
EndIF

//Tratamento de tabela compartilhada
If xFilial("SRD") <> ""
	If !EMPTY(MV_PAR02)//Filial De 
		cQry += " AND SRD.RD_FILIAL >= '"+MV_PAR02+"'
	EndIF
	If !EMPTY(MV_PAR03)//Filial Até?
		cQry += " AND SRD.RD_FILIAL >= '"+MV_PAR03+"'
	EndIF
EndIf
//Centro de Custo De ?
If !EMPTY(MV_PAR04)
	cQry += " AND SRD.RD_CC >= '"+MV_PAR04+"'
EndIF
//Centro de Custo Ate ?
If !EMPTY(MV_PAR05)
	cQry += " AND SRD.RD_CC <= '"+MV_PAR05+"'
EndIF
//Matricula De ?
If !EMPTY(MV_PAR06)
	cQry += " AND SRD.RD_MAT >= '"+MV_PAR06+"'
EndIF
//Matricula Ate ?
If !EMPTY(MV_PAR07)
	cQry += " AND SRD.RD_MAT <= '"+MV_PAR07+"'
EndIF

//Codigos a Listar ? //Cont. Cod. a Listar ?
If !EMPTY(MV_PAR10+MV_PAR11)//Codigos a Listar ? //Cont. Cod. a Listar ?
	For nFor := 1 To Len(ALLTRIM(MV_PAR10+MV_PAR11)) Step 3
		cVerba += "'"+Subs(MV_PAR10+MV_PAR11,nFor,3)+"'"
		If Len(ALLTRIM(MV_PAR10+MV_PAR11)) > ( nFor+3 )
			cVerba += "," 
		Endif
	Next nFor
	cQry += " AND SRD.RD_PD in ("+cVerba+")
EndIF
                                         

If MV_PAR14 = 1
	cQry += " UNION
	cQry += " Select SRT.RT_FILIAL as FILIAL,SRT.RT_MAT as MAT
	cQry += " From "+RetSqlName("SRT")+" SRT
	
	//Tratamento que exigem que seja verificado junto ao cadastro de funcionarios, Inner Join, SRA - Cadastro de funcionarios.
	If !EMPTY(MV_PAR08) .or. !EMPTY(MV_PAR09)
		cQry += " inner join (Select * From "+RetSqlName("SRA")+" Where D_E_L_E_T_ <> '*'
		If !EMPTY(MV_PAR08)//Situacoes a Imp. ?
			cQry += " AND RA_SITFOLH in ("+cSit+")
		EndIf
		If !EMPTY(MV_PAR09)//Categorias a Imp. ? 
			cQry += " AND RA_CATFUNC in ("+cCat+")
		EndIf
		cQry += ") as SRA on SRA.RA_FILIAL = SRT.RT_FILIAL AND SRA.RA_MAT = SRT.RT_MAT" 
	EndIF
	
	cQry += " Where SRT.D_E_L_E_T_ <> '*'  
	//ANO
	If !EMPTY(MV_PAR01)
		cQry += " AND LEFT(SRT.RT_DATACAL,4) = '"+MV_PAR01+"'
	EndIF
	//Tratamento de tabela compartilhada
	If xFilial("SRT") <> ""
		If !EMPTY(MV_PAR02)//Filial De 
			cQry += " AND SRT.RT_FILIAL >= '"+MV_PAR02+"'
		EndIF
		If !EMPTY(MV_PAR03)//Filial Até?
			cQry += " AND SRT.RT_FILIAL >= '"+MV_PAR03+"'
		EndIF
	EndIf
	//Centro de Custo De ?
	If !EMPTY(MV_PAR04)
		cQry += " AND SRT.RT_CC >= '"+MV_PAR04+"'
	EndIF
	//Centro de Custo Ate ?
	If !EMPTY(MV_PAR05)
		cQry += " AND SRT.RT_CC <= '"+MV_PAR05+"'
	EndIF
	//Matricula De ?
	If !EMPTY(MV_PAR06)
		cQry += " AND SRT.RT_MAT >= '"+MV_PAR06+"'
	EndIF
	//Matricula Ate ?
	If !EMPTY(MV_PAR07)
		cQry += " AND SRT.RT_MAT <= '"+MV_PAR07+"'
	EndIF
	//Codigos a Listar ? //Cont. Cod. a Listar ?
	If !EMPTY(MV_PAR10+MV_PAR11)//Codigos a Listar ? //Cont. Cod. a Listar ?
		For nFor := 1 To Len(ALLTRIM(MV_PAR10+MV_PAR11)) Step 3
			cVerba += "'"+Subs(MV_PAR10+MV_PAR11,nFor,3)+"'"
			If Len(ALLTRIM(MV_PAR10+MV_PAR11)) > ( nFor+3 )
				cVerba += "," 
			Endif
		Next nFor
		cQry += " AND SRT.RT_VERBA in ("+cVerba+")
	EndIF               
Else
	cQry += " Group By SRD.RD_FILIAL,SRD.RD_MAT
EndIF

If select("QRY")>0
	QRY->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)

Return .T.

/*
Funcao      : OpenExcel()
Parametros  : cXml
Retorno     : 
Objetivos   : Função para abrir o excel
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function OpenExcel(cXml)
*------------------------------*
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF
 
If (nHandle:=FCreate(cDest+cArq, 0)) == -1
	MsgAlert("Erro na criação do Arquivo!","HLB BRASIL")
	Return .T.
EndIf
FClose(nHandle)	

nHandle := Fopen(cDest+cArq,2)
FSeek(nHandle,0,2)
FWRITE(nHandle, cXML )
fclose(nHandle) 

SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel

Return .T.    

/*
Funcao      : GrvXML()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GrvXML(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

/*
Funcao      : AjustaSX1()
Parametros  : 
Retorno     : 
Objetivos   : Ajusta o Dicionario SX1 da empresa.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function AjustaSX1()
*------------------------------*
U_PUTSX1( cPerg, "01", "Ano ?"					, "Ano?"  					, "Ano?"   					, "", "C",4 ,00,00,"G",''							 				, ""	,"","","MV_PAR01","","","","2012"	,"","","","","","","","","","","","",{"Informe o Ano que deseja","considerar para impressao do","Relatório, no formato AAAA."},{},{},"")
U_PUTSX1( cPerg, "02", "Filial De ?  "	   		, "Filial De ?  " 	   		, "Filial De ?  " 	  		, "", "C",2 ,00,00,"G",'' 						 					, "XM0"	,"","","MV_PAR02","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione o Código da Filial ","Inicial para Filtrar os dados do","Relatório."},{},{},"")
U_PUTSX1( cPerg, "03", "Filial Até?"	 	  		, "Filial Até?" 	  	 	, "Filial Até ?  " 	   		, "", "C",2 ,00,00,"G",'' 						 					, "XM0"	,"","","MV_PAR03","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione o Código da Final ","Inicial para Filtrar os dados do","Relatório."},{},{},"")
U_PUTSX1( cPerg, "04", "Centro de Custo De ?  "	, "Centro de Custo De ?  " 	, "Centro de Custo De ?  " 	, "", "C",9 ,00,00,"G",'' 						 					, "CTT"	,"","","MV_PAR04","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione o Código do Centro","de Custo Inicial para Filtrar os dados  ","do Relatório."},{},{},"")
U_PUTSX1( cPerg, "05", "Centro de Custo Até?"	 	, "Centro de Custo Até?"  	, "Centro de Custo Até ?  " , "", "C",9 ,00,00,"G",'' 						 					, "CTT"	,"","","MV_PAR05","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione o Código do Centro","de Custo Final para Filtrar os dados  ","do Relatório."},{},{},"")
U_PUTSX1( cPerg, "06", "Matricula De ?  "	   		, "Matricula De ?  " 	   	, "Matricula De ?  " 		, "", "C",6 ,00,00,"G",'' 						 					, "SRA" ,"","","MV_PAR06","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione o Código de","Matrícula Inicial para Filtrar os dados ","do Relatório."},{},{},"")
U_PUTSX1( cPerg, "07", "Matricula Até?"	 		, "Matricula Até?" 	  	 	, "Matricula Até ?  " 		, "", "C",6 ,00,00,"G",'' 						 					, "SRA" ,"","","MV_PAR07","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione o Código de","Matrícula Final para Filtrar os dados ","do Relatório."},{},{},"")
U_PUTSX1( cPerg, "08", "Situacoes a Imp. ? "	 	, "Situacoes a Imp. ? "  	, "Situacoes a Imp. ? " 	, "", "C",5 ,00,00,"G",'fSituacao'				  					, "" 	,"","","MV_PAR08","","","",""		,"","","","","","","","","","","","",{"Informe ou selecione as situacoes para  ","filtro dos funcionarios que serao","impressos no relatorio. A situacao do  ","funcionario sera considerada conforme ","opcao informada abaixo: 'Historica' = ","mes a mes no periodo selecionado; ou","'Atual' = campo Sit.Folha do Funcionario","no mes corrente."},{},{},"")
U_PUTSX1( cPerg, "09", "Categorias a Imp. ?" 		, "Categorias a Imp. ? "  	, "Categorias a Imp. ?" 	, "", "C",15,00,00,"G",'fCategoria'				  					, ""	,"","","MV_PAR09","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione as Categorias para ","Filtrar os Funcionários que serão","impressos no Relatório."},{},{},"")
U_PUTSX1( cPerg, "10", "Codigos a Listar ?" 		, "Codigos a Listar ?"  	, "Codigos a Listar ?" 		, "", "C",60,00,00,"G",'fVerbas(NIL,MV_PAR10,20) '					, ""	,"","","MV_PAR10","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione as Verbas que   ","deseja imprimir no Relatório."},{},{},"")
U_PUTSX1( cPerg, "11", "Cont. Cod. a Listar ?" 	, "Cont. Cod. a Listar ?"  	, "Cont. Cod. a Listar ?" 	, "", "C",60,00,00,"G",'fVerbas(NIL,MV_PAR11,20) '					, ""	,"","","MV_PAR11","","","",""		,"","","","","","","","","","","","",{"Informe ou Selecione a continuação das","Verbas que deseja imprimir no Relatório"},{},{},"")
U_PUTSX1( cPerg, "12", "Consolidado ?" 			, "Consolidado?"  			, "Consolidado ?"  			, "", "N",1 ,00,01,"C",''											, ""	,"","","MV_PAR12","Sim","","",""	,"Não","","","","","","","","","","","",{"Selecione a opção para geração das","informações de consolidado."},{},{},"")
U_PUTSX1( cPerg, "13", "Total por CC ?" 			, "Total por CC ?"  		, "Total por CC ?"   		, "", "N",1 ,00,01,"C",''											, ""	,"","","MV_PAR13","Sim","","",""	,"Não","","","","","","","","","","","",{"Selecione a opção para geração das","informações de Total por Centro de Custo."},{},{},"")
U_PUTSX1( cPerg, "14", "Exibe Provisão?" 			, "Exibe Provisão?"  		, "Exibe Provisão?"   		, "", "N",1 ,00,01,"C",''											, ""	,"","","MV_PAR14","Sim","","",""	,"Não","","","","","","","","","","","",{"Selecione a opção para geração das","informações de Provisão."},{},{},"")
U_PUTSX1( cPerg, "15", "Imp. Bases?" 		  		, "Imp. Bases?"  	  		, "Imp. Bases?"   			, "", "N",1 ,00,01,"C",''											, ""	,"","","MV_PAR15","Sim","","",""	,"Não","","","","","","","","","","","",{"Selecione a opção para exibir as","verbas do tipo Base no relatorio."},{},{},"")

Return .T.

/*
Funcao      : WriteXML()
Parametros  : 
Retorno     : 
Objetivos   : Cria o Arquivo XMl para geração do Excel
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function WriteXML()
*------------------------*
Local cXML := ""      
Local cQry := ""
Local cVerba := ""     
Local cFilMat:= ""
Local i

Private nRowsTable := 0
        
cXML += WorkXML("OPEN")
cXML += DefStyle() 

QRY->(DbGoTop())
While QRY->(!EOF())    
	aDados := {}
	For i:=1 To 2
		//Busca as informações de lançamentos do funcionario.	
		If i == 1
			cQry := " Select SRD.RD_PD as PD, SRD.RD_DATARQ+'01' as DATAPD, SRD.RD_VALOR as  VALOR, SRD.RD_CC as CC, 'SRD' as ORIGEM
			cQry += " From "+RetSqlName("SRD")+" SRD
			cQry += " Where SRD.D_E_L_E_T_ <> '*'
			cQry += " AND SRD.RD_FILIAL = '"+QRY->FILIAL	+"'
			cQry += " AND SRD.RD_MAT 	= '"+QRY->MAT	+"'
			//ANO
			If !EMPTY(MV_PAR01)
				cQry += " AND LEFT(SRD.RD_DATARQ,4) = '"+MV_PAR01+"'
			EndIF
			//Centro de Custo De ?
			If !EMPTY(MV_PAR04)
				cQry += " AND SRD.RD_CC >= '"+MV_PAR04+"'
			EndIF
			//Centro de Custo Ate ?
			If !EMPTY(MV_PAR05)
				cQry += " AND SRD.RD_CC <= '"+MV_PAR05+"'
			EndIF
			//Codigos a Listar ? //Cont. Cod. a Listar ?
			If !EMPTY(MV_PAR10+MV_PAR11)//Codigos a Listar ? //Cont. Cod. a Listar ?
				For nFor := 1 To Len(ALLTRIM(MV_PAR10+MV_PAR11)) Step 3
					cVerba += "'"+Subs(MV_PAR10+MV_PAR11,nFor,3)+"'"
					If Len(ALLTRIM(MV_PAR10+MV_PAR11)) > ( nFor+3 )
						cVerba += "," 
					Endif
				Next nFor
				cQry += " AND SRD.RD_PD in ("+cVerba+")
			EndIF              
			cQry += " Order By SRD.RD_PD,SRD.RD_DATARQ
				     
		ElseIf i == 2 .And. MV_PAR14 = 1//Impressão de Provisão ativado.
			cQry := " Select SRT.RT_VERBA as PD, SRT.RT_DATACAL as DATAPD, SRT.RT_VALOR - ISNULL(SRT2.RT_VALOR,0) as  VALOR, SRT.RT_CC as CC, 'SRT' as ORIGEM
			cQry += " From "+RetSqlName("SRT")+" SRT  
			cQry += " Left Join (Select * From "+RetSqlName("SRT")+" Where D_E_L_E_T_ <> '*'	) as SRT2 on SRT.RT_FILIAL = SRT2.RT_FILIAL
			cQry += " 														AND SRT.RT_MAT = SRT2.RT_MAT
			cQry += " 														AND SRT.RT_VERBA = SRT2.RT_VERBA
			cQry += "														AND SRT.RT_TIPPROV = SRT2.RT_TIPPROV
			cQry += " 														AND LEFT(SRT2.RT_DATACAL,6) = LEFT(CONVERT(varchar(11),DATEADD(m,-1,SRT.RT_DATACAL),112) ,6)
			cQry += " Where SRT.D_E_L_E_T_ <> '*'
			cQry += " AND SRT.RT_FILIAL = '"+QRY->FILIAL	+"'
			cQry += " AND SRT.RT_MAT 	= '"+QRY->MAT	+"'
			//ANO
			If !EMPTY(MV_PAR01)
				cQry += " AND LEFT(SRT.RT_DATACAL,4) = '"+MV_PAR01+"'
			EndIF
			//Centro de Custo De ?
			If !EMPTY(MV_PAR04)
				cQry += " AND SRT.RT_CC >= '"+MV_PAR04+"'
			EndIF
			//Centro de Custo Ate ?
			If !EMPTY(MV_PAR05)
				cQry += " AND SRT.RT_CC <= '"+MV_PAR05+"'
			EndIF
			//Codigos a Listar ? //Cont. Cod. a Listar ?
			If !EMPTY(MV_PAR10+MV_PAR11)//Codigos a Listar ? //Cont. Cod. a Listar ?
				For nFor := 1 To Len(ALLTRIM(MV_PAR10+MV_PAR11)) Step 3
					cVerba += "'"+Subs(MV_PAR10+MV_PAR11,nFor,3)+"'"
					If Len(ALLTRIM(MV_PAR10+MV_PAR11)) > ( nFor+3 )
						cVerba += "," 
					Endif
				Next nFor
				cQry += " AND SRT.RT_VERBA in ("+cVerba+")
			EndIF              
			cQry += " Order By SRT.RT_VERBA,SRT.RT_DATACAL	
		EndIf
	
		If select("TMP")>0
			TMP->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)
		
		nPos   := 0
		TMP->(DbGoTop())
		While TMP->(!EOF())
			//Posiciona na Verba para buscar informações.
			SRV->(DbSetOrder(1))
			SRV->(DbSeek(xFilial("SRV")+TMP->PD))

			If TMP->ORIGEM == "SRT" .or. IIF(MV_PAR15==1,.T.,SRV->RV_TIPOCOD<>"3")//Descarta informações de Base dependendo do parametro de filtros.
		  		If TMP->ORIGEM == "SRT" .or. SRV->RV_TIPOCOD == "1" .or. SRV->RV_TIPOCOD == "3"//Provento/base
		  			nFator := 1                                              
				ElseIf SRV->RV_TIPOCOD == "2"//Desconto
		  			nFator := -1			
				EndIf
				If (nPos := aScan(aDados, {|x| x[1] == TMP->PD}) ) <> 0
			   		aDados[npos][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
			 	Else                       
			 		aAdd(aDados,{TMP->PD,/*JAN*/0,/*FEV*/0,/*MAR*/0,/*ABR*/0,/*MAI*/0,/*JUN*/0,/*JUL*/0,/*AGO*/0,;
			 								/*SET*/0,/*OUT*/0,/*NOV*/0,/*DEZ*/0,/*OUTROS*/0})
			 		aDados[aScan(aDados, {|x| x[1] == TMP->PD})][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
			 	EndIf
			 	//Carrega as informações para o Consolidado. 
			 	If MV_PAR12 == 1
					If (nPos := aScan(aConsol, {|x| x[1] == TMP->PD}) ) <> 0
				   		aConsol[npos][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
				 	Else                       
				 		aAdd(aConsol,{TMP->PD,/*JAN*/0,/*FEV*/0,/*MAR*/0,/*ABR*/0,/*MAI*/0,/*JUN*/0,/*JUL*/0,/*AGO*/0,;
				 								/*SET*/0,/*OUT*/0,/*NOV*/0,/*DEZ*/0,/*OUTROS*/0})
				 		aConsol[aScan(aConsol, {|x| x[1] == TMP->PD})][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
				 	EndIf
				EndIf
				//Carrega as informações para o Total por centro de custo
			 	If MV_PAR13 == 1
			 		cChave := TMP->CC +"|"+ TMP->PD +"|"+ IIF(nFator>0,"+","-")
			 		
			 		If (nPos := aScan(aTotCC, {|x| x[1] == cChave}) ) <> 0
				   		aTotCC[npos][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
				 	Else                       
				 		aAdd(aTotCC,{cChave,/*JAN*/0,/*FEV*/0,/*MAR*/0,/*ABR*/0,/*MAI*/0,/*JUN*/0,/*JUL*/0,/*AGO*/0,;
				 								/*SET*/0,/*OUT*/0,/*NOV*/0,/*DEZ*/0,/*OUTROS*/0})
				 		aTotCC[aScan(aTotCC, {|x| x[1] == cChave})][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
				 	EndIf
			 		
				EndIf
			EndIf
			TMP->(DbSkip())
		EndDo
	Next i

	If select("TMP")>0
		TMP->(DbCloseArea())
	Endif	
    
	//Posiciona no registro do cadastro de funcionarios para utilizar informações
 	SRA->(DbSetOrder(1))
 	SRA->(DbSeek(QRY->FILIAL+QRY->MAT))
 	//While SRA->(!EOF()) .And. QRY->FILIAL == SRA->RA_FILIAL .And. QRY->MAT == SRA->RA_MAT// .and. !EMPTY(SRA->RA_DEMISSA)
 	//	SRA->(DbSkip())
 	//EndDo

	cXML += WorkSheet("OPEN",SRA->RA_NOME) 
	cXML += TableSheet("OPEN")
	cXML += RowLastTable()

	//cXML += '    <Row ss:Index="3">
	cXML += '    <Row >
	cXML += '     <Cell ss:Index="2"><Data ss:Type="String">Employee :</Data></Cell>
	cXML += '     <Cell ss:MergeAcross="6" ss:StyleID="s132"><Data ss:Type="String">'+ALLTRIM(SRA->RA_NOME)+'</Data></Cell>
	cXML += '    </Row>

	//Grava no arquivo fisico e limpa memoria da variavel
	cXML := GrvXML(cXML)
	
	cXML += HeaderTable()
	
	nRowsTable := 0	
	For i:=1 to len(aDados)
		cXML += RowTable(aDados[i])
	Next i
	
	cXML += TotalTable(nRowsTable)
		
	cXML += TableSheet("CLOSE")
	cXML += WorkSheet("CLOSE")

	//Grava no arquivo fisico e limpa memoria da variavel
	cXML := GrvXML(cXML)
	QRY->(DbSkip())
EndDo   
 
If MV_PAR12 == 1
	cXML := GrvXML(cXML)
	cXML += PrintConsol()
EndIf

If MV_PAR13 == 1
	cXML := GrvXML(cXML)
	cXML += PrintTotCC()
EndIf

cXML += WorkXML("CLOSE")       

Return cXML

/*
Funcao      : WorkXML()
Parametros  : cOpc
Retorno     : 
Objetivos   : Criação de uma nova estrutura de XML.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function WorkXML(cOpc)
*----------------------------------------* 
Local cXML := "" 

If cOpc = "OPEN" 
	cXML += '  <?xml version="1.0"?>
	cXML += '  <?mso-application progid="Excel.Sheet"?>
	cXML += '  <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += '   xmlns:o="urn:schemas-microsoft-com:office:office"
	cXML += '   xmlns:x="urn:schemas-microsoft-com:office:excel"
	cXML += '   xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += '   xmlns:html="http://www.w3.org/TR/REC-html40">

ElseIf cOpc = "CLOSE" 
	cXML += ' </Workbook>  
	
EndIf

Return cXML

/*
Funcao      : DefStyle()
Parametros  : cOpc
Retorno     : 
Objetivos   : Definição dos stilos que sera utilizado no XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function DefStyle()
*----------------------------------------* 
Local cXML := "" 

cXML += '   <Styles>
cXML += '    <Style ss:ID="Default" ss:Name="Normal">
cXML += '     <Alignment ss:Vertical="Bottom"/>
cXML += '     <Borders/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '     <Interior/>
cXML += '     <NumberFormat/>
cXML += '     <Protection/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s68">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#FFFFFF"
cXML += '      ss:Bold="1" ss:Underline="Single"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s76">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s77">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '     <Borders/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s79">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s80">
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s81">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cXML += '      ss:Bold="1"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s83">
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"
cXML += '      ss:Bold="1"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s85">
cXML += '     <NumberFormat ss:Format="#,##0;[Red]\-#,##0"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s91">
cXML += '     <Interior/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s92">
cXML += '     <Interior/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s93">
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s126">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cXML += '      ss:Bold="1"/>
cXML += '     <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s127">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s128">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '    </Style>
cXML += '    <Style ss:ID="s129">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s130">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXML += '      ss:Bold="1"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s131">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXML += '      ss:Bold="1"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s132">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cXML += '      ss:Bold="1"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s133">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#FFFFFF"
cXML += '      ss:Bold="1" ss:Underline="Single"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s134">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#FFFFFF"
cXML += '      ss:Bold="1" ss:Underline="Single"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s135">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/>
cXML += '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '     <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s136">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom" ss:Indent="2"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>
cXML += '     <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s137">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cXML += '      ss:Bold="1"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s138">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/>
cXML += '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cXML += '      ss:Bold="1"/>
cXML += '     <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s139">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0;[Red]\-#,##0"/>
cXML += '    </Style>
cXML += '   </Styles>

Return cXML

/*
Funcao      : WorkSheet()
Parametros  : cOpc
Retorno     : 
Objetivos   : Criação de uma novo WorkSheet.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function WorkSheet(cOpc,cNameSheet)
*----------------------------------------* 
Local cXML := "" 

Default cNameSheet := STRTRAN(TIME(),"",":")

If cOpc = "OPEN" 
	cXML += '   <Worksheet ss:Name="'+ALLTRIM(cNameSheet)+'">

ElseIf cOpc = "CLOSE" 
	cXML += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += '    <PageSetup>
	cXML += '     <Layout x:Orientation="Landscape"/>
	cXML += '     <Header x:Margin="0.3"/>
	cXML += '     <Footer x:Margin="0.3"/>
	cXML += '     <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
	cXML += '    </PageSetup>
	cXML += '    <Print>
	cXML += '     <ValidPrinterInfo/>
	cXML += '     <PaperSizeIndex>9</PaperSizeIndex>
	cXML += '     <Scale>62</Scale>
	cXML += '     <HorizontalResolution>600</HorizontalResolution>
	cXML += '     <VerticalResolution>600</VerticalResolution>
	cXML += '    </Print>
   	If cNameSheet == "CONSOLIDATED"
		cXML += '    <TabColorIndex>53</TabColorIndex>
	ElseIf cNameSheet == "COST CENTER"
		cXML += '    <TabColorIndex>21</TabColorIndex>
	EndIf
	cXML += '    <PageBreakZoom>60</PageBreakZoom>
	cXML += '    <Selected/>
	cXML += '    <DoNotDisplayGridlines/>
	cXML += '    <FreezePanes/>
	cXML += '    <FrozenNoSplit/>
	cXML += '    <SplitHorizontal>4</SplitHorizontal>
	cXML += '    <TopRowBottomPane>4</TopRowBottomPane>
	cXML += '    <SplitVertical>5</SplitVertical>
	cXML += '    <LeftColumnRightPane>5</LeftColumnRightPane>
	cXML += '    <ActivePane>0</ActivePane>
	cXML += '    <Panes>
	cXML += '     <Pane>
	cXML += '      <Number>3</Number>
	cXML += '      <ActiveRow>2</ActiveRow>
	cXML += '      <ActiveCol>1</ActiveCol>
	cXML += '      <RangeSelection>R3C2:R3C6</RangeSelection>
	cXML += '     </Pane>
	cXML += '     <Pane>
	cXML += '      <Number>1</Number>
	cXML += '      <ActiveRow>2</ActiveRow>
	cXML += '      <ActiveCol>1</ActiveCol>
	cXML += '      <RangeSelection>R3C2:R3C6</RangeSelection>
	cXML += '     </Pane>
	cXML += '     <Pane>
	cXML += '      <Number>2</Number>
	cXML += '      <ActiveRow>2</ActiveRow>
	cXML += '      <ActiveCol>1</ActiveCol>
	cXML += '      <RangeSelection>R3C2:R3C6</RangeSelection>
	cXML += '     </Pane>
	cXML += '     <Pane>
	cXML += '      <Number>0</Number>
	cXML += '      <ActiveRow>40</ActiveRow>
	cXML += '      <ActiveCol>3</ActiveCol>
	cXML += '     </Pane>
	cXML += '    </Panes>
	cXML += '    <ProtectObjects>False</ProtectObjects>
	cXML += '    <ProtectScenarios>False</ProtectScenarios>
	cXML += '   </WorksheetOptions>
	cXML += '  </Worksheet>
EndIf

Return cXML

/*
Funcao      : RowLastTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação de uma novo WorkSheet.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function RowLastTable()
*-----------------------------* 
Local cXML := ""

cXML += '    <Row ss:Height="15.75">
cXML += '     <Cell ss:Index="2" ss:StyleID="s83"><Data ss:Type="String">'+AllTrim(SM0->M0_NOMECOM)+'</Data></Cell>
cXML += '    </Row>

Return cXML

/*
Funcao      : TableSheet()
Parametros  : 
Retorno     : 
Objetivos   : Criação da Tabela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function TableSheet(cOpc)
*-----------------------------* 
Local cXML := ""

If cOpc = "OPEN" 
	cXML += '    <Table ss:ExpandedColumnCount="48" ss:ExpandedRowCount="20000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="6"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="57"/>
	cXML += '     <Column ss:Width="56.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="50.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="3.75"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="8" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="11" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="14" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="17" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="20" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="23" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="26" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="29" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="32" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="35" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="38" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="41" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="36.75" ss:Span="1"/> 
	cXML += '     <Column ss:Index="44" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="36.75" ss:Span="1"/>

ElseIf cOpc = "CLOSE" 
	cXML += '   </Table>
	
EndIf

Return cXML

/*
Funcao      : HeaderTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação do cabeçalho da tabela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function HeaderTable(cNameSheet)
*-----------------------------* 
Local cXML := ""

Default cNameSheet := ""
   
//cXML += '    <Row ss:Index="5" ss:AutoFitHeight="0">
cXML += '    <Row ss:AutoFitHeight="0">
If cNameSheet <> "COST CENTER"
	cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:MergeDown="1" ss:StyleID="s133"><Data ss:Type="String">Payroll</Data></Cell>
Else
	cXML += '     <Cell ss:Index="2" ></Cell> 
EndIf
cXML += '     <Cell ss:Index="6" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">January</Data></Cell>
cXML += '     <Cell ss:Index="9" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">February</Data></Cell>
cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">March</Data></Cell>
cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">April</Data></Cell>
cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">May</Data></Cell>
cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">June</Data></Cell>
cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">July</Data></Cell>
cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">August</Data></Cell>
cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">September</Data></Cell>
cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">October</Data></Cell>
cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">November</Data></Cell>
cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">December</Data></Cell>
cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">Other</Data></Cell>
cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">Consolidated</Data></Cell>
cXML += '    </Row>
cXML += '   <Row ss:AutoFitHeight="0">
cXML += '    <Cell ss:Index="6" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="9" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '    <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+MV_PAR01+'</Data></Cell>
cXML += '   </Row>

Return cXML

/*
Funcao      : RowTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação de um novo registro no excel.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function RowTable(aDados)
*-----------------------------*
Local cXML := ""        
Local cCod	:= ""
Local cDesc := ""

//Posiciona na Verba para buscar informações.
SRV->(DbSetOrder(1))
If SRV->(DbSeek(xFilial("SRV")+aDados[1]))
	cCod	:= SRV->RV_COD
	If SRV->(FieldPos("RV_PAYROLL")) > 0 .And.  SRV->(FieldPos("RV_DPAYROL")) > 0 .And. SRV->RV_PAYROLL
		cDesc := ALLTRIM(SRV->RV_DPAYROL)
	Else
		cDesc := ALLTRIM(SRV->RV_DESC)
	EndIf
	If EMPTY(cDesc)
		cDesc := ALLTRIM(SRV->RV_DESC)
	EndIf	
Else
	cCod	:= ""
	cDesc := ALLTRIM(aDados[1])
EndIf

//cXML += '    <Row ss:Index="8">
cXML += '    <Row >
cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:StyleID="s128"><Data ss:Type="String">'+cCod+' - '+cDesc+'</Data></Cell>
cXML += '     <Cell ss:StyleID="s76"></Cell>
cXML += '     <Cell ss:Index="6"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[2],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="9"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[3],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[4],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[5],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[6],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[7],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[8],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[9],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[10],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[11],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[12],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[13],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[14],"9999999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s126" ss:Formula="=SUM(RC[-36]:RC[-1])"></Cell>
cXML += '    </Row>
nRowsTable++

cXML += LnEmpty()
nRowsTable++

Return cXml

/*
Funcao      : TotalTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação do cabeçalho da tabela.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function TotalTable(nRowsTable)
*-----------------------------*
Local cXML := ""  

cXML += '    <Row ss:Height="16.5">
cXML += '     <Cell ss:Index="2"  ss:MergeAcross="2" ss:StyleID="s136"><Data ss:Type="String">TOTAL</Data></Cell>
cXML += '     <Cell ss:Index="6"  ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="9"  ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s138" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '    </Row>

Return cXml

/*
Funcao      : PrintConsol()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela impressão do Consolidado.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function PrintConsol()
*-----------------------------*
Local cXML := "" 
Local i

cXML += WorkSheet("OPEN","CONSOLIDATED") 
cXML += TableSheet("OPEN")
cXML += RowLastTable()

//cXML += '    <Row ss:Index="3">
cXML += '    <Row >
cXML += '     <Cell ss:MergeAcross="6" ss:StyleID="s132"><Data ss:Type="String">Consolidated report</Data></Cell>
cXML += '    </Row>

cXML += HeaderTable()
	
//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)

nRowsTable := 0		
For i:=1 to len(aConsol)
	cXML += RowTable(aConsol[i])
Next i
	
//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)
	
cXML += TotalTable(nRowsTable)
	
cXML += TableSheet("CLOSE")
cXML += WorkSheet("CLOSE","CONSOLIDATED")

Return cXml

/*
Funcao      : PrintTotCC()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela impressão da WorkSheet com total por Centro de Custo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function PrintTotCC()
*-----------------------------*
Local i
Local cXML		:= "" 
Local cCc		:= ""
Local cVerba	:= ""
Local cFator	:= ""
Local cDesc		:= ""
Local nRowsTable:= 0


SRV->(DbSetOrder(1))
CTT->(DbSetOrder(1))

aTotCC := aSort(aTotCC,,, { |x, y| x[1] < y[1] })

cXML += WorkSheet("OPEN","COST CENTER") 
cXML += TableSheet("OPEN")
cXML += RowLastTable()

cXML += '    <Row >
cXML += '     <Cell ss:MergeAcross="6" ss:StyleID="s132"><Data ss:Type="String">Cost Center</Data></Cell>
cXML += '    </Row>

cXML += HeaderTable("COST CENTER")
	
//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)

For i:=1 to len(aTotCC)
	
	If cCc <> Left(aTotCC[i][1],AT("|",aTotCC[i][1])-1)
  		If !EMPTY(cCc)
			cXML += TotalTable(nRowsTable)
			nRowsTable := 0
			cXML += LnEmpty()
		EndIf  
		
		cXML += LnEmpty()
   		CTT->(DbSeek(xFilial("CTT")+Left(aTotCC[i][1],AT("|",aTotCC[i][1])-1)))
		cXML += '    <Row >
		cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:StyleID="s128"><Data ss:Type="String">'+CTT->CTT_CUSTO+' - '+ALLTRIM(CTT->CTT_DESC01)+'</Data></Cell>
		cXML += '     <Cell ></Cell>
		cXML += '     <Cell ss:Index="6" ></Cell>
		cXML += '     <Cell ss:Index="9" ></Cell>
		cXML += '     <Cell ss:Index="12"></Cell>
		cXML += '     <Cell ss:Index="15"></Cell>
		cXML += '     <Cell ss:Index="18"></Cell>
		cXML += '     <Cell ss:Index="21"></Cell>
		cXML += '     <Cell ss:Index="24"></Cell>
		cXML += '     <Cell ss:Index="27"></Cell>
		cXML += '     <Cell ss:Index="30"></Cell>
		cXML += '     <Cell ss:Index="33"></Cell>
		cXML += '     <Cell ss:Index="36"></Cell>
		cXML += '     <Cell ss:Index="39"></Cell>
		cXML += '     <Cell ss:Index="42"></Cell>
		cXML += '     <Cell ss:Index="45"></Cell>
		cXML += '    </Row>
		cXML += LnEmpty()	
     
	EndIf
	
	cFator	:= RIGHT(aTotCC[i][1],1)
	cVerba	:= SubStr(aTotCC[i][1],AT("|",aTotCC[i][1])+1,3)
	cCc		:= Left(aTotCC[i][1],AT("|",aTotCC[i][1])-1)
	
	//Posiciona na Verba para buscar informações.
	SRV->(DbSeek(xFilial("SRV")+cVerba))
	
	If SRV->(FieldPos("RV_PAYROLL")) > 0 .And.  SRV->(FieldPos("RV_DPAYROL")) > 0 .And. SRV->RV_PAYROLL
		cDesc := ALLTRIM(SRV->RV_DPAYROL)
	Else
		cDesc := ALLTRIM(SRV->RV_DESC)
	EndIf
	
	cXML += '    <Row >
	cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:StyleID="s128"><Data ss:Type="String">'+SRV->RV_COD+' - '+cDesc+'</Data></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:Index="6"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][2],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="9"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][3],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][4],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][5],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][6],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][7],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][8],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][9],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][10],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][11],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][12],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][13],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][14],"9999999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s126" ss:Formula="=SUM(RC[-36]:RC[-1])"></Cell>
	cXML += '    </Row>

	cXML += LnEmpty()
	nRowsTable += 2 
	cXML := GrvXML(cXML)
Next i                                    

cXML += TotalTable(nRowsTable)
	
//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)
	
cXML += TableSheet("CLOSE")
cXML += WorkSheet("CLOSE","COST CENTER")

Return cXml

/*
Funcao      : LnEmpty()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela impressão de Linha em branco na WorkSheet com total por Centro de Custo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------*
Static Function LnEmpty()
*-----------------------------*
Local cXml := ""
	cXML += '    <Row ss:AutoFitHeight="0" ss:Height="3.75">
	cXML += '     <Cell ss:Index="2" ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="9" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="12" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="15" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="18" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="21" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="24" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="27" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="30" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="33" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="36" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="39" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="42" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="45" ss:StyleID="s81"></Cell>
	cXML += '     <Cell ss:StyleID="s81"></Cell>
	cXML += '    </Row>

Return cXml
