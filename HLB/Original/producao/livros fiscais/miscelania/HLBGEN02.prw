#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.ch" 
#Include "TOTVS.ch"     

/*
Funcao      : HLBGEN02()
Objetivos   : Replicar IBPT para todos ambientes com base no P12_01
Autor       : Anderson Arrais
Data/Hora   : 01/08/2019
*/                          
*------------------------*
 User Function HLBGEN02()
*------------------------*
Local 	cQuery		:= ""

Private cPerg  		:= "HLBGEN02"
Private nIncProd	:= 0
Private oProcess

If LEFT(GetEnvServer(),6) <> "P12_01"
     MsgInfo("Rotina não implementada para esse ambiente, favor usar P12_01!","HLB BRASIL")
     Return
Else
	aHlpPor := {}
	Aadd( aHlpPor, "Limpar Tabela: vai deletar os dados IBPT do P12_01.")
	Aadd( aHlpPor, "Replicar IBPT: vai replicar os dados da P12_01 para os demais.") 
	U_PUTSX1(cPerg,"01","O que fazer?","O que fazer?","O que fazer?","mv_ch1","N",01,0,1,"C","","","","S","mv_par01","Limpar Tabela","Limpar Tabela","Limpar Tabela","","Replicar IBPT","Replicar IBPT","Replicar IBPT","","","","","","","","","",aHlpPor,"","")
	
	If !pergunte(cPerg,.T.)
		return()
	EndIf
	
	nIncProd	:= mv_par01
	
EndIf

If nIncProd = 1

	//Limpar tabela P12_01     
	cQuery:= " DELETE P12_01..CLKYY0 "
	Conout(cQuery)
	
	If !MsgYesNo("Essa rotina pode demorar varios MINUTOS, deseja continuar?","HLB BRASIL")
		Return .F. 
	Else
		oProcess := MsNewProcess():New( { || TCSQLEXEC(cQuery) } , "Limpando tabela CLKYY0 do ambiente P12_01" , "Aguarde..." , .F. )
 		oProcess:Activate()	
	EndIf
	
ElseIf nIncProd = 2

	//Início da query
	cQuery:= " DECLARE @AMBIENTE    INT	" +CRLF
	cQuery+= " DECLARE @CONTADOR    INT " +CRLF
	cQuery+= " DECLARE @CQRYDRP1    VARCHAR(max) " +CRLF
	cQuery+= " DECLARE @CQRYDRP2    VARCHAR(max) " +CRLF
	cQuery+= " set @AMBIENTE = 1 " +CRLF
	cQuery+= " set @CONTADOR = 2 " +CRLF
	cQuery+= " WHILE @CONTADOR <= 28 " +CRLF
	cQuery+= " BEGIN " +CRLF
	cQuery+= " set @AMBIENTE = @AMBIENTE+1 " +CRLF
	cQuery+= " set @CQRYDRP1 = 'DELETE P12_'+REPLICATE('0',2-LEN(@AMBIENTE))+CONVERT(VARCHAR(2),@AMBIENTE)+'..CLKYY0 ' " +CRLF
	cQuery+= " set @CQRYDRP2 = 'INSERT INTO P12_'+REPLICATE('0',2-LEN(@AMBIENTE))+CONVERT(VARCHAR(2),@AMBIENTE)+'..CLKYY0 SELECT * FROM P12_01..CLKYY0' " +CRLF
	cQuery+= " SET @CONTADOR = @CONTADOR+1 " +CRLF
	//cQuery+= " print(@CQRYDRP1) " +CRLF //TESTE
	//cQuery+= " print(@CQRYDRP2) " +CRLF //TESTE
	cQuery+= " EXEC(@CQRYDRP1) " +CRLF //PRODUCAO
	cQuery+= " EXEC(@CQRYDRP2) " +CRLF //PRODUCAO
	cQuery+= " END "  
	Conout(cQuery)
	
	If !MsgYesNo("Essa rotina pode demorar algumas HORAS, deseja continuar?","HLB BRASIL")
		Return .F. 
	Else
		oProcess := MsNewProcess():New( { || TCSQLEXEC(cQuery) } , "Replicando tabela IBPT do ambiente P12_01 para todos os outros." , "Aguarde..." , .F. )
 		oProcess:Activate()	
	EndIf

EndIf

Return