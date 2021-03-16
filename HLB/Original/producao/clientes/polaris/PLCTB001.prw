#include "PROTHEUS.ch"

/*
Funcao      : PLCTB001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Relatorio em CSV com informações contábeis de folha no padrão: *1 (Específico Polaris (PL))
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012    11:55
Revisão		: 
Data/Hora   : 
Módulo      : Contabilidade
*/

/* 
*1
 ||----------------------------------------------------------------------------------------------------------------------------||
 || Coluna                  Dados                                                   Comentário                                 ||
 ||  A                        Número da Conta Contábil          A mesma conta do Plano de Contas do Microsiga                  ||
 ||  B                        Texto                                                    Descrever "Folha de Pagamento Mes/Ano"  ||
 ||  C                        Valor                                                     Valor em R$ do Lançamento              ||
 ||  D                        Departamento                                  Número do Departamento "4xx"                       ||
 ||----------------------------------------------------------------------------------------------------------------------------||
*/

*---------------------*
User Function PLCTB001()
*---------------------*
Local cPerg := "PLCTB001"
Private oDlg

If !cEmpAnt $ "PL/99"
	MsgInfo("Esse relatório é especifico para a empresa Polaris.","Atenção")
	Return Nil
EndIf

//Monta a pergunta
AjustaSx1(cPerg)

If Pergunte(cPerg,.T.)

//******************Régua de processamento*******************
                                           //retira o botão X
  DEFINE DIALOG oDlg TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
                                          
    // Montagem da régua
    nMeter := 0
    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},150,oDlg,150,14,,.T.)
  
  ACTIVATE DIALOG oDlg CENTERED ON INIT(GeraDados(oMeter,oDlg))
  
//*************************************	

EndIf

Return Nil

/*
Funcao      : GeraDados()
Parametros  : oMeter,oDlg
Retorno     : Nil
Objetivos   : Função para criar a estrutura do csv e processar a query.
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012
*/

*-------------------------*
Static Function GeraDados(oMeter,oDlg)
*-------------------------*
Local aDados  	:= {}
Local aCampos 	:= {}
Local cQry		:=""

	
	aCampos := {{"ContaContabil"  ,"C",020,0},;
				{"Texto"    	  ,"C",015,0},;
				{"Valor" 		  ,"N",014,2},;
				{"Departamento"	  ,"C",003,0}}
    
	//Carrega a query
	cQry:=CriaQuery(DTOS(MV_PAR01),DTOS(MV_PAR02),(MV_PAR03),(MV_PAR04))

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
	
	if nRecCount <= 0
		MsgInfo("Não há informações neste período!","Atenção")
		oDlg:end()//finaliza a barra
		return
	endif
	//seta o total da regua
	oMeter:nTotal:=nRecCount*2
	//Inicia a régua
	oMeter:Set(0)

QRYTEMP->(Dbgotop())
While QRYTEMP->(!EOF())

    //Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=5 // atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua
    
	//iif(empty(Alltrim(QRYTEMP->DEPARTAMENTO)),"101",Alltrim(QRYTEMP->DEPARTAMENTO)) })   //Departamento
	//AOA - 01/03/2016 - Ajuste para lançar Centro de Custo 101 para todas contas contabeis iniciadas com 1 e 2
   	aAdd(aDados,{AllTrim(QRYTEMP->CONTA),;      	//Conta
		         Alltrim(QRYTEMP->CDATA),;      	//Descrição de folha de pagamento + mes/ano
		         QRYTEMP->VALOR,;      	   			//Valor
				 IIF(Substr(AllTrim(QRYTEMP->CONTA),1,1) $ "1/2","101",IIF(Empty(Alltrim(QRYTEMP->DEPARTAMENTO)),"101",Alltrim(QRYTEMP->DEPARTAMENTO)))	})   //Departamento	
   		QRYTEMP->(DbSkip())	
EndDo

QRYTEMP->(DbCloseArea())

//Grava arquivo em excel.
FtToExcel(aCampos,aDados)

Return Nil

/*
Funcao      : FtToExcel()
Parametros  : aStruct,aDados
Retorno     : Nil
Objetivos   : Função para criar o arquivo csv com as informações da query
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012
*/
*---------------------------------------*
Static Function FtToExcel(aStruct,aDados)
*---------------------------------------*
Local aArea		:= GetArea()
Local cArquivo  := ""
Local cPath		:= ""
Local cExt      := ""
Local nY		:= 0      
Local nX        := 0      
Local cBuffer   := ""     
Local oExcelApp := Nil    
Local nHandle   := 0
Local xValor    := Nil    

Local cDest 	:= GetTempPath() //Retorna o caminho da pasta temporária do sistema atual.
Local cArquivo	:= alltrim(CriaTrab(NIL,.F.)) //cria nome aleatório
	
If Empty(cExt)
	cExt := ".csv"
EndIf

cPath    := AllTrim(cDest)
cArquivo := AllTrim(cArquivo)+AllTrim(cExt) 

If File(cPath+cArquivo)
	FErase(cPath+cArquivo)
EndIf
		
If (nHandle := FCreate(cPath+cArquivo)) > 0

//cBuffer += "<table border='1'>"

	For nX := 1 To Len(aDados)

    //Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=5 // atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua

//cBuffer += "<tr>"

		For nY := 1 To Len(aStruct)
			xValor := aDados[nX][nY]				
			Do Case
				Case aStruct[nY][2]=="C"
					If ValType(xValor) == "N"
						If xValor == 0
							xValor := ""
						Else
							xValor := AllTrim(Str(xValor))
						EndIf						
					EndIf
				Case aStruct[nY][2]=="N"
				    If ValType(xValor) <> "N"
						xValor := Val(xValor)
//					Else
//						xValor := TRANSFORM(xValor," 999999999.99")
					EndIf
				Case aStruct[nY][2]=="D"
				    If ValType(xValor) <> "D"
						xValor := Stod(xValor)
  					EndIf
			EndCase
//			cBuffer += "<td>"
//			cBuffer += xValor
			cBuffer += ToXlsFormat(xValor)
//			cBuffer += xValor
//			cBuffer += "</td>"
			cBuffer += ";"
			//cBuffer += CHR(9)//tabulação
		Next nY
		cBuffer += CRLF
//cBuffer += "</tr>"
	Next nX	

//cBuffer += "</table>"

	FWrite(nHandle, cBuffer)
	FClose(nHandle)
	
	sleep(1000)
		If ApOleClient("MsExcel") 
			msginfo("Excel gerado com sucesso!")
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath + cArquivo)
			oExcelApp:SetVisible(.T.)
		Else
			MsgStop("Microsoft Excel nao instalado.")
		EndIf

Else
	MsgStop("Erro na criacao do arquivo na estacao local. Contate o administrador do sistema")
EndIf	

oDlg:end()//finaliza a barra

RestArea(aArea)
Return
/*
Funcao      : AjustaSx1()
Parametros  : cPerg
Retorno     : Nil
Objetivos   : Função para criar/ajustar a pergunta
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012
*/
*------------------------------*
Static Function AjustaSx1(cPerg)
*------------------------------*

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}

aHlpPor := {}
Aadd( aHlpPor, "Data inicial dos lançamentos contabeis.")
U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/12","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Data final dos lançamentos contabeis.")
U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/12","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Filial inicial.")
U_PUTSX1(cPerg,"03","Filial De ?","Filial De ?","Filial De ?","mv_ch3","C",02,0,0,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Filial final.")
U_PUTSX1(cPerg,"04","Filial Ate ?","Filial Ate ?","Filial Ate ?","mv_ch4","C",02,0,0,"G","","","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

Return

/*
Funcao      : CriaQuery()
Parametros  : DataIni,DataFim
Retorno     : Nil
Objetivos   : Função para criar a query
Autor       : Matheus Massarotto
Data/Hora   : 19/04/2012
*/
*------------------------------*
Static Function CriaQuery(DataIni,DataFim,FilIni,FilFin)
*------------------------------*
Local cQry:=""

cQry+=" SELECT "+CRLF
cQry+=" CASE CT2_DC WHEN '1' THEN CT2_DEBITO ELSE CT2_CREDIT END AS CONTA,"+CRLF
cQry+=" 'Payroll '+SUBSTRING(CT2_DATA,5,2)+'/'+SUBSTRING(CT2_DATA,1,4) AS CDATA,"+CRLF
cQry+=" CASE CT2_DC WHEN '1' THEN -CT2_VALOR ELSE CT2_VALOR END AS VALOR,"+CRLF
cQry+=" CASE CT2_DC WHEN '1' THEN SUBSTRING(CT2_CCD,3,3) ELSE SUBSTRING(CT2_CCC,3,3) END AS DEPARTAMENTO,"+CRLF
cQry+=" CT2_DATA"+CRLF
cQry+=" FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE CT2_FILIAL BETWEEN '"+FilIni+"' AND '"+FilFin+"' AND CT2_ROTINA='GPEM110' AND CT2_MOEDLC='01' AND D_E_L_E_T_='' AND CT2_DC IN ('1','2') AND CT2_DATA BETWEEN '"+DataIni+"' AND '"+DataFim+"'"+CRLF

cQry+=" UNION ALL"+CRLF

cQry+=" SELECT "+CRLF
cQry+=" CT2_DEBITO AS CONTA,"+CRLF
cQry+=" 'Payroll '+SUBSTRING(CT2_DATA,5,2)+'/'+SUBSTRING(CT2_DATA,1,4) AS CDATA,"+CRLF
cQry+=" -CT2_VALOR AS VALOR,"+CRLF
cQry+=" SUBSTRING(CT2_CCD,3,3) AS DEPARTAMENTO,"+CRLF
cQry+=" CT2_DATA"+CRLF
cQry+=" FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE CT2_FILIAL BETWEEN '"+FilIni+"' AND '"+FilFin+"'  AND CT2_ROTINA='GPEM110' AND CT2_MOEDLC='01' AND D_E_L_E_T_='' AND CT2_DC IN ('3') AND CT2_DATA BETWEEN '"+DataIni+"' AND '"+DataFim+"'"+CRLF

cQry+=" UNION ALL"+CRLF

cQry+=" SELECT "+CRLF
cQry+=" CT2_CREDIT AS CONTA,"+CRLF
cQry+=" 'Payroll '+SUBSTRING(CT2_DATA,5,2)+'/'+SUBSTRING(CT2_DATA,1,4) AS CDATA,"+CRLF
cQry+=" CT2_VALOR AS VALOR,"+CRLF
cQry+=" SUBSTRING(CT2_CCC,3,3) AS DEPARTAMENTO,"+CRLF
cQry+=" CT2_DATA"+CRLF
cQry+=" FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE CT2_FILIAL BETWEEN '"+FilIni+"' AND '"+FilFin+"'  AND CT2_ROTINA='GPEM110' AND CT2_MOEDLC='01' AND D_E_L_E_T_='' AND CT2_DC IN ('3') AND CT2_DATA BETWEEN '"+DataIni+"' AND '"+DataFim+"'"+CRLF
cQry+=" ORDER BY CT2_DATA"

Return(cQry)
