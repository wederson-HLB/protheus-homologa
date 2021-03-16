#Include 'TOTVS.CH'
#Include "TOPCONN.CH"
#Include "TBICONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGTGEN022  บAutor  ณEduardo C. Romanini บ Data ณ  22/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo generica que recupera as informa็๕es de historico    บฑฑ
ฑฑบ          ณde todos os funcionarios da GT e grava em uma tabela no     บฑฑ
ฑฑบ          ณbanco de dados para consulta por programas externos.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TimeSheet e WIP                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*----------------------*
User Function GTGEN022()
*----------------------*
Local lLoop := .T.

Local cTabSRA   := ""

Local nI := 0

Private lDemiss   := .F.
Private cAliasTmp := GetNextAlias()
Private aHistFun  := {}

ConOut("GTGEN022:Inicio do Processamento - "+DtoC(Date())+" - "+Time())

PREPARE ENVIRONMENT EMPRESA "CH" FILIAL "01"

//Cria Tabela Temporแria
CriaTemp(cAliasTmp)

//Retorna todas as empresas do Sigamat
BeginSql Alias 'SM0TMP'
	
	SELECT M0_CODIGO,M0_CODFIL
	FROM SIGAMAT
	WHERE M0_CODIGO <> 'YY'
	  AND %notDel%
	ORDER BY M0_CODIGO,M0_CODFIL
EndSql

SM0TMP->(DbGoTop())
While SM0TMP->(!EOF())
    
	ConOut("GTGEN022:Inicio Processamento Empresa "+SM0TMP->M0_CODIGO+"  - "+DtoC(Date())+" - "+Time())
    
    cTabSRA := "% SRA"+AllTrim(SM0TMP->M0_CODIGO)+"0 %"
 
	If SM0TMP->M0_CODIGO $ "ZB/ZF/ZG/Z4/MP/MQ/MW/MY/PN" 
		cCampoRA:= "%RA_P_WIPFU%"
	Else 
		cCampoRA:= "%'' AS 'RA_P_WIPFU'%"
	EndIf
	
	BeginSql Alias 'SRATMP'
		SELECT RA_FILIAL,RA_MAT,RA_CC,RA_NOME,RA_CIC,RA_EMAIL,RA_ADMISSA,RA_DEMISSA,RA_CODFUNC, 
		       LEFT(RA_BCDEPSA, 3) AS 'BCOSAL', SUBSTRING(RA_BCDEPSA,4,LEN(RA_BCDEPSA)) AS 'AGSAL', RA_CTDEPSA,
		       LEFT(RA_P_BCORD, 3) AS 'BCOEXR', SUBSTRING(RA_P_BCORD,4,LEN(RA_P_BCORD)) AS 'AGEXR', RA_P_CTARD,
		       %exp:cCampoRA%	
	    FROM %exp:cTabSRA%
		WHERE %notDel%
		  AND RA_FILIAL = %exp:SM0TMP->M0_CODFIL%
		  AND RA_RESCRAI not in ('30','31')
	    ORDER BY RA_FILIAL,RA_MAT
	EndSql

	SRATMP->(DbGoTop())
	While SRATMP->(!EOF())
		
		//Zera o array de historico
		aHistFun := {}
		
		//Zera a variavel de Demissใo
		lDemiss := .F.
		
		//Tratamento para CPF nใo cadastrado
		If Empty(SRATMP->RA_CIC)
			SRATMP->(DbSkip())
			Loop
		EndIf

		ConOut("GTGEN022:Inicio do Processamento Funcionario "+SRATMP->RA_CIC+"  - "+DtoC(Date())+" - "+Time())
		
		//Verifica se o funcionแrio foi demitido
		If !Empty(SRATMP->RA_DEMISSA)
			lDemiss := .T.
		EndIf

		//Grava informa็๕es do funcionแrio
		aAdd(aHistFun,{SRATMP->RA_MAT,;     //[1]:Matricula 
		               SM0TMP->M0_CODIGO,;  //[2]:Empresa
		               SRATMP->RA_FILIAL,;  //[3]:Filial
		               SRATMP->RA_CC,;      //[4]:Centro de Custo
		               SRATMP->RA_CODFUNC,; //[5]:Fun็ใo
		               SRATMP->RA_ADMISSA,; //[6]:Data Inicial
		               If(!Empty(SRATMP->RA_DEMISSA),SRATMP->RA_DEMISSA,DtoS(dDataBase)),; //[7]:Data Final
		               If(lDemiss,"D",""),; //[8]:Situa็ใo 
						SRATMP->RA_P_WIPFU})//[9]:Fun็ใo WIP
						
		//Pesquisa o hist๓rico de Transferencias	 
		BuscaSRE(AllTrim(SRATMP->RA_MAT),AllTrim(SM0TMP->M0_CODIGO),AllTrim(SRATMP->RA_FILIAL),AllTrim(SRATMP->RA_CC))

		//Pesquisa o hist๓rico de Movimenta็๕es de Fun็ใo	    
	    BuscaSR7()
		        
        For nI:=1 To Len(aHistFun)

		    //Grava a Tabela temporแria
			(cAliasTmp)->(DbAppend())  
		
			(cAliasTmp)->RA_MAT     := aHistFun[nI][1]
			(cAliasTmp)->RA_CIC     := SRATMP->RA_CIC
			(cAliasTmp)->RA_CC      := aHistFun[nI][4]
			(cAliasTmp)->RA_NOME    := SRATMP->RA_NOME 
			(cAliasTmp)->RA_EMAIL   := SRATMP->RA_EMAIL
			(cAliasTmp)->A6_COD     := If(!Empty(SRATMP->BCOEXR),SRATMP->BCOEXR,SRATMP->BCOSAL)
			(cAliasTmp)->A6_AGENCIA := If(!Empty(SRATMP->AGEXR),SRATMP->AGEXR,SRATMP->AGSAL)
			(cAliasTmp)->RA_CTDEPSA := If(!Empty(SRATMP->RA_P_CTARD),SRATMP->RA_P_CTARD,SRATMP->RA_CTDEPSA)
			(cAliasTmp)->M0_CODIGO  := aHistFun[nI][2]
			(cAliasTmp)->M0_CODFIL  := aHistFun[nI][3]
			(cAliasTmp)->R7_FUNCAO  := aHistFun[nI][5]
			(cAliasTmp)->DATA_INI   := StoD(aHistFun[nI][6])
			(cAliasTmp)->DATA_FIM   := StoD(aHistFun[nI][7])
			(cAliasTmp)->SITUACAO   := aHistFun[nI][8]
			(cAliasTmp)->R7_P_WIPFU := aHistFun[nI][9]
			
			(cAliasTmp)->(MsUnlock())
    	Next

		ConOut("GTGEN022:Final do Processamento Funcionario "+SRATMP->RA_CIC+"  - "+DtoC(Date())+" - "+Time())

		SRATMP->(DbSkip())
	EndDo			

	//Fecha a tabela
	SRATMP->(DbCloseArea())

	ConOut("GTGEN022:Final do Processamento Empresa "+SM0TMP->M0_CODIGO+"  - "+DtoC(Date())+" - "+Time())
		
	SM0TMP->(DbSkip())			
EndDo

//Fecha a tabela
SM0TMP->(DbCloseArea())

//Grava a tabela de hist๓rico de funcionแrios
GrvInclude()

RESET ENVIRONMENT 

ConOut("GTGEN022:Final do Processamento - "+DtoC(Date())+" - "+Time())

Return Nil


*---------------------------------*
Static Function CriaTemp(cAliasTmp)
*---------------------------------*
Local cNome   := ""
Local cIndex  := ""
//Local cIndex2 := ""

Local aCampos:={}

aAdd(aCampos,{"RA_MAT"    ,"C",06,0})
aAdd(aCampos,{"RA_CIC"    ,"C",11,0})
aAdd(aCampos,{"RA_CC"     ,"C",04,0})
aAdd(aCampos,{"RA_NOME"   ,"C",60,0})
aAdd(aCampos,{"RA_EMAIL"  ,"C",60,0})
aAdd(aCampos,{"A6_COD"    ,"C",05,0})
aAdd(aCampos,{"A6_AGENCIA","C",08,0})
aAdd(aCampos,{"RA_CTDEPSA","C",15,0})
aAdd(aCampos,{"M0_CODIGO" ,"C",02,0})
aAdd(aCampos,{"M0_CODFIL" ,"C",02,0})
aAdd(aCampos,{"R7_FUNCAO" ,"C",04,0})
aAdd(aCampos,{"DATA_INI"  ,"D",08,0})
aAdd(aCampos,{"DATA_FIM"  ,"D",08,0})
aAdd(aCampos,{"SITUACAO"  ,"C",01,0})
aAdd(aCampos,{"R7_P_WIPFU","C",02,0})

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
Endif

cNome := CriaTrab(aCampos)
dbUseArea(.T.,,cNome,cAliasTmp,.T.,.F.)

//cIndex2:=CriaTrab(Nil,.F.)
//IndRegua(cAliasTmp,cIndex2,"RA_CIC+TIPO_MOV",,,"Selecionando Registro...")

cIndex:=CriaTrab(Nil,.F.)
IndRegua(cAliasTmp,cIndex,"RA_CIC+DTOS(DATA_INI)",,,"Selecionando Registro...")

//DbSelectArea(cAliasTmp)
//DbSetIndex(cIndex2+OrdBagExt())

DbSelectArea(cAliasTmp)
DbSetIndex(cIndex+OrdBagExt())

DbSetOrder(1)

Return Nil

*----------------------------------*
Static Function BuscaSR7(cMat,cFunc)
*----------------------------------*
Local cTabSR7   := ""
Local cAliasSR7 := GetNextAlias()
Local cQuery    := ""
Local cCodFun   := ""

Local nPos := 0
Local nI   := 0
Local nY   := 0

Local aMovFun := {}

//Tratamento para verificar se a tabela existe
cQuery := " SELECT NAME FROM sysobjects "
cQuery += " WHERE name = 'SR7"+AllTrim(SM0TMP->M0_CODIGO)+"0' "
cQuery += " AND XTYPE = 'U' " 

If(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)

TCQ->(DbGoTop())
If TCQ->(EOF())
	//Fecha a tabela
	TCQ->(DbCloseArea())
	Return .F.
EndIf

//Consulta as movimenta็๕es de cargo
cTabSR7 := "% SR7"+AllTrim(SM0TMP->M0_CODIGO)+"0 %"

cCampoR7:= "%'' AS 'R7_P_WIPFU'%"
//alterar MSM
if SM0TMP->M0_CODIGO $ "ZB/ZF/ZG/Z4/MP/MQ/MW/MY/PN"

	BeginSql Alias cAliasSR7
		
		SELECT R7_FILIAL,R7_MAT,R7_DATA,R7_FUNCAO,R7_TIPO,R7_P_WIPFU
		FROM %exp:cTabSR7%
		WHERE %notDel%
		  AND R7_FUNCAO <> ' '
		  AND R7_FILIAL = %exp:SRATMP->RA_FILIAL% 
		  AND R7_MAT = %exp:SRATMP->RA_MAT%
		ORDER BY R7_DATA
		
	EndSql

else

 	BeginSql Alias cAliasSR7
		
		SELECT R7_FILIAL,R7_MAT,R7_DATA,R7_FUNCAO,R7_TIPO,%exp:cCampoR7%
		FROM %exp:cTabSR7%
		WHERE %notDel%
		  AND R7_FUNCAO <> ' '
		  AND R7_FILIAL = %exp:SRATMP->RA_FILIAL% 
		  AND R7_MAT = %exp:SRATMP->RA_MAT%
		ORDER BY R7_DATA
		
	EndSql
  
endif
	
//Ordena o array por data de incial
aSort(aHistFun,,,{|x,y| x[6]<y[6]})

//Verifica as movimenta็๕es de cargo do funcionแrio 
cCodFun := ""
(cAliasSR7)->(DbGoTop())
While (cAliasSR7)->(!EOF())
   	 
	If AllTrim(cCodFun) <> AllTrim((cAliasSR7)->R7_FUNCAO)
        aAdd(aMovFun,{AllTrim((cAliasSR7)->R7_FUNCAO),AllTrim((cAliasSR7)->R7_DATA),AllTrim((cAliasSR7)->R7_P_WIPFU)})
	EndIf	

	cCodFun := AllTrim((cAliasSR7)->R7_FUNCAO)

	(cAliasSR7)->(DbSkip())
EndDo

//Fecha a tabela
(cAliasSR7)->(DbCloseArea())

//Atualiza o hist๓rico com as altera็๕es
If Len(aMovFun) > 1
	For nI:=1 To Len(aMovFun)

	   If nI == 1
	    	If AllTrim(aMovFun[nI][1]) <> AllTrim(aHistFun[1][5])
	    		
	    		//Atualiza a Fun็ใo da primeira movimenta็ใo
	   	    	nPos := 1
	    	    aHistFun[nPos][5] := AllTrim(aMovFun[nI][1])
   	    	    aHistFun[nPos][9] := AllTrim(aMovFun[nI][3])
	    	EndIf
		Else
			
			nPos := aScan(aHistFun,{|a| a[6]<= AllTrim(aMovFun[nI][2]) .and. a[7]>=AllTrim(aMovFun[nI][2])})
		    If nPos > 0
	        	
	        	//Adiciona um novo item no array
	        	aAdd(aHistFun,{"","","","","","","","",""})
	        	aIns(aHistFun,nPos+1)      
	        	aHistFun[nPos+1] := {"","","","","","","","",""}
	        	
	        	//Carrega os campos
	        	aHistFun[nPos+1][1] := aHistFun[nPos][1]
	        	aHistFun[nPos+1][2] := aHistFun[nPos][2]
	        	aHistFun[nPos+1][3] := aHistFun[nPos][3]
	        	aHistFun[nPos+1][4] := aHistFun[nPos][4]      	        	
	  			aHistFun[nPos+1][5] := aHistFun[nPos][5]      	        	
				aHistFun[nPos+1][6] := AllTrim(aMovFun[nI][2])
				aHistFun[nPos+1][7] := aHistFun[nPos][7]
				aHistFun[nPos+1][8] := If(lDemiss,"D","")            
				aHistFun[nPos+1][9] := aHistFun[nPos][9]
				
				//Atualiza a data final da periodo anterior        	
	        	aHistFun[nPos][7] := DtoS(DaySub(StoD(AllTrim(aMovFun[nI][2])),1))
		               
				//Atualiza a situa็ใo    	
	        	aHistFun[nPos][8] := If(lDemiss,"D","")         

	            //Atualiza o nPos para atualizar as proximas movimenta็๕es
	         	nPos := nPos+1
			
			EndIf
		
		EndIf
		
		//Atualiza a fun็ใo para as proximas movimenta็๕es
		If nPos > 0 .and. nPos <= Len(aHistFun)
			For nY:=nPos To Len(aHistFun)
				aHistFun[nY][5] := AllTrim(aMovFun[nI][1])
				aHistFun[nY][9] := AllTrim(aMovFun[nI][3])
			Next
		EndIf
	Next
EndIf

Return .T.

*------------------------------------------*
Static Function	BuscaSRE(cMat,cEmp,cFil,cCC)
*------------------------------------------*
Local cTabSRE := ""
Local cAliasSRE := GetNextAlias()
Local cQuery    := ""
Local cDataAux  := ""

Local nPos := 0

//Tratamento para verificar se a tabela existe
cQuery := " SELECT NAME FROM sysobjects "
cQuery += " WHERE name = 'SRE"+AllTrim(cEmp)+"0' "
cQuery += " AND XTYPE = 'U' " 

If(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)

TCQ->(DbGoTop())
If TCQ->(EOF())
	//Fecha a tabela
	TCQ->(DbCloseArea())
	Return .F.
EndIf

//Consulta as movimenta็๕es de cargo
cTabSRE := "% SRE"+AllTrim(cEmp)+"0 %"

BeginSql Alias cAliasSRE
	SELECT RE_DATA,RE_EMPD,RE_FILIALD,RE_MATD,RE_CCD
	FROM %exp:cTabSRE%
	WHERE %notDel%
	  AND RE_EMPP = %exp:cEmp%
	  AND RE_FILIALP = %exp:cFil%
	  AND RE_MATP = %exp:cMat%
	  AND RE_CCP = %exp:cCC%
 	ORDER BY RE_DATA DESC
EndSql

(cAliasSRE)->(DbGoTop())
If (cAliasSRE)->(!EOF())
    
	//Verifica se houve transferencia
	If AllTrim((cAliasSRE)->RE_EMPD) <> AllTrim(cEmp) .or. AllTrim((cAliasSRE)->RE_FILIALD) <> AllTrim(cFil) .or. ;
	   AllTrim((cAliasSRE)->RE_MATD) <> AllTrim(cMat) .or. AllTrim((cAliasSRE)->RE_CCD) <> AllTrim(cCC)	
        
        //Verifica se jแ foi gravado o registro
    	nPos := aScan(aHistFun,{|a| AllTrim(a[1])==AllTrim((cAliasSRE)->RE_MATD) .and.;
									AllTrim(a[2])==AllTrim((cAliasSRE)->RE_EMPD) .and.;
       	              				AllTrim(a[3])==AllTrim((cAliasSRE)->RE_FILIALD) .and.;
								    AllTrim(a[4])==AllTrim((cAliasSRE)->RE_CCD) })

    	If nPos == 0    

	    	//Procura o perํodo para altera็ใo
	    	nPos := aScan(aHistFun,{|a| a[6]<=(cAliasSRE)->RE_DATA .and. a[7]>=(cAliasSRE)->RE_DATA})
	    	If nPos > 0
				
				//Recupera a data Inicial Anterior
				cDataAux := aHistFun[nPos][6]
				
				//Altera a data inicial do periodo alterior
				aHistFun[nPos][6] := (cAliasSRE)->RE_DATA
				
				//Grava informa็๕es do funcionแrio
				aAdd(aHistFun,{(cAliasSRE)->RE_MATD,;    //[1]:Matricula 
			    	           (cAliasSRE)->RE_EMPD,;    //[2]:Empresa
			        	       (cAliasSRE)->RE_FILIALD,; //[3]:Filial
			            	   (cAliasSRE)->RE_CCD,;     //[4]:Centro de Custo
				               aHistFun[nPos][5],;       //[5]:Fun็ใo
				               cDataAux,;                //[6]:Data Inicial
			    	           "",;                      //[7]:Data Final
			    	           If(lDemiss,"D",""),;		 //[8]:Situa็ใo
			    	           aHistFun[nPos][9]})//WipFu   
			    	           
				If (cAliasSRE)->RE_DATA == cDataAux
					aHistFun[Len(aHistFun)][7] := (cAliasSRE)->RE_DATA
				Else
					aHistFun[Len(aHistFun)][7] := DtoS(DaySub(StoD((cAliasSRE)->RE_DATA),1))
				EndIf
			    	           
			    //Carrega as varivaveis
				cFil := (cAliasSRE)->RE_FILIALD
				cEmp := (cAliasSRE)->RE_EMPD
				cMat := (cAliasSRE)->RE_MATD
				cCC  := (cAliasSRE)->RE_CCD
	
			    //Pesquisa o hist๓rico de Transferencias	 
				BuscaSRE(cMat,cEmp,cFil,cCC)
			
			EndIf    
    	EndIf
	EndIf
EndIf

//Fecha a tabela
(cAliasSRE)->(DbCloseArea())

Return .T.      

*--------------------------*
Static Function GrvInclude()
*--------------------------*
Local cCmd := ""

(cAliasTmp)->(DbSetOrder(1))
(cAliasTmp)->(DbGoTop())

ConOut("GTGEN022:Inicio Grava็ใo - "+DtoC(Date())+" - "+Time())

//nCon := TCLink("MSSQL/Controle","10.0.30.5")
nCon := TCLink("MSSQL/Controle","10.0.30.5",7894)
If nCon < 0
	ConOut("GTGEN022:Erro de Conexใo - "+DtoC(Date())+" - "+Time())
	Return .F.
EndIf

//Apaga todos os registros da tabela
cCmd := "DELETE FROM TOTVS_HIST_FUN_AUX"

If TCSQLExec(cCmd) < 0
	ConOut("GTGEN022:Erro da Grava็ใo - "+DtoC(Date())+" - "+Time())
	Return .F.
Endif

//Inicia a grava็ใo
While (cAliasTmp)->(!EOF())
   
	If !Empty((cAliasTmp)->RA_CIC)
		cCmd := "INSERT INTO TOTVS_HIST_FUN_AUX (RA_MAT,RA_CIC,RA_CC,RA_NOME,RA_EMAIL,A6_COD,A6_AGENCIA,RA_CTDEPSA,M0_CODIGO,M0_CODFIL,R7_FUNCAO,DATA_INI,DATA_FIM,SITUACAO,R7_P_WIPFU)"
		cCmd += " VALUES ( "
		
		cCmd += "'"+AllTrim((cAliasTmp)->RA_MAT) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->RA_CIC) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->RA_CC) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->RA_NOME) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->RA_EMAIL) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->A6_COD) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->A6_AGENCIA) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->RA_CTDEPSA) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->M0_CODIGO) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->M0_CODFIL) + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->R7_FUNCAO) + "', "
		cCmd += "'"+AllTrim(DtoS((cAliasTmp)->DATA_INI)) + "', "
		cCmd += "'"+AllTrim(DtoS((cAliasTmp)->DATA_FIM))  + "', "
		cCmd += "'"+AllTrim((cAliasTmp)->SITUACAO)  + "',"
		cCmd += "'"+AllTrim((cAliasTmp)->R7_P_WIPFU)  + "'"		

		cCmd += " )"
	
		If TCSQLExec(cCmd) < 0
			ConOut("GTGEN022:Erro da Grava็ใo - "+DtoC(Date())+" - "+Time())
			Return .F.
		Endif
	EndIf	
	(cAliasTmp)->(DbSkip())
EndDo

TCUnlink(nCon)

ConOut("GTGEN022:Fim da Grava็ใo - "+DtoC(Date())+" - "+Time())

Return .T.