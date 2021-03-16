#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "ap5mail.ch"
#INCLUDE "SHELL.CH"
#include "APWEBEX.CH"

/*
+-----------------------------------------------------------------------------
| Fun็ใo | GTRELSRD() | Autor | Ana Carolina Gabriel  	|  Data  | 24/01/2011|
+----------------------------------------------------------------------------+
| Descri็ใo |  Gera um relatorio de folha de pagamento, com todas as verbas  |
|			|  e totais com data determinada em pergunte - SRD ACUMULADOS    |
+----------------------------------------------------------------------------+
| Uso		|		 Gera็ใo de Relatorio                                    |
+----------------------------------------------------------------------------+

Funcao      : GTRELSRD
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera um relatorio de folha de pagamento, com todas as verbas e totais com data determinada em pergunte - SRD ACUMULADOS
Autor     	: Ana Carolina Gabriel  	 	
Data     	: 24/01/2011
Obs         : Gera็ใo de Relatorio  
TDN         : 
Revisใo     : Tiago Luiz Mendon็a 
Data/Hora   : 15/03/2012
M๓dulo      : Gestใo Pessoal.
Cliente     : Todos.
*/
   
*------------------------------------------*
 User Function GTRELSRD()
*------------------------------------------*
Local cData	:= ""
Local cTipo	:= ""
Local cEmp	:= cEmpAnt
Local cHtml	:= ""


If !MsgYesNo("Esta rotina foi unificada a 'Payroll Atual' e nใo ira receber novas atualiza็๕es. Deseja utiliza-la mesmo assim?","HLB BRASIL")
	Return .T.
EndIf

cQry	:=''
cAlias	:= 'TRT'

aVerba	:=	{}
aTRT := {}
aTotais:= {}

ncont:= 0
nSalario:=0  
nSalarioB:=0
z:=1

nTot := 0
nTotProv := 0
nTotDesc:= 0
aTotTot:={}   


aTotTotP   :=0
aTotTotD :=0
aTotTotT:=  0    
NINSSS :=0 
nIRFERIAS:=0 
nIr:= 0            

lTVerbsI:=.F.
aBaseINSS:={}
aBase500:={}

aBaseFGTS:={} 

nWITHHOLDINGINCOMETAX:=0

Private cDest		:= ""
Private cArq		:= ""
Private nBytesSalvo	:= 0
//=====================================================================================================================================================
//==					   								 PAYROLL PAYROLL FOR THE MONTH
//=====================================================================================================================================================

//RRP - 11/09/2013 - Ajuste no fonte para nใo causar estouro de variavel.
// Inclusใo das perguntas no SX1
U_PUTSX1( 'FOLHAPGTO', "01", "Data", "Data:", "Date:", "", "D",8,00,00,"G","" , "","","","MV_PAR01") //Defini็ใo de Data
U_PUTSX1( 'FOLHAPGTO', "02", "Tipo do Arquivo", "Tipo do Arquivo", "Tipo do Arquivo", "", "C",8,00,00,"C","",'' , "","","MV_PAR02",'HTML','HTML','HTML','',"Excel" , "Excel ","Excel","Email" , 'Email' ,'Email',"") //Defini็ใo de Tipo de Arquivo

//	Se a Opera็ใo for Abortada.
If !Pergunte('FOLHAPGTO',.T.)
	Return()
EndIf

cData	:= DTOS( MV_PAR01 )  //Data da Gera็ใo da Folha
cTipo	:= MV_PAR02 		//Extensใo de Arquivo Gerado

cDest	:=  GetTempPath()
//cDest	:=  "C:\"
If cValtochar(cTIPO) == '1'
	If FILE (cDest+"payroll.html")
		FERASE (cDest+"payroll.html")
	endif
	cArq	:= "payroll.html"
ElseIf cValtochar(cTIPO) == '2' .OR.  cValtochar(cTIPO) == '3'
	If FILE (cDest+"payroll.xls")
		FERASE (cDest+"payroll.xls")
	EndIf
	cArq	:= "payroll.xls"
EndIf
         
 IF SELECT('TRT')>0
 TRT->(DBCLOSEAREA())
 ENDIF     
 
 IF SELECT('TRV')>0
 TRT->(DBCLOSEAREA())
 ENDIF  
  
  IF SELECT('TRB')>0
 TRT->(DBCLOSEAREA())
 ENDIF  
//===================================================================================================================================================== 
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจValores de Encargos de Empresas.

cQryTRV:= "SELECT * FROM SRX"+cEmp+"0"   + CRLF
cQryTRV +=   "WHERE RX_TIP = '14' AND D_E_L_E_T_='' " + CRLF

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQryTRV),'TRV',.F.,.T.)  //execu็ใo da query

dbselectarea('TRV') 
TRV->(dbgotop())
cEncargos:=TRV->RX_TXT  

// %  Empresa   
nPOS:= AT(" ", ltrim(cEncargos) ) 
cEncargos1 :=  substr(ltrim(cEncargos), 1, nPOS) 
nEncargos :=  val(cEncargos1)  /100

cEncargos :=  stuff(cEncargos, 1, nPOS,' ')

//% Terceiros 
nPOS:= AT(" ", ltrim(cEncargos) ) 
cEncargos1 :=  substr(ltrim(cEncargos), 1, nPOS) 
nEncargos +=  val(cEncargos1)  /100

cEncargos :=  stuff(ltrim(cEncargos), 1, nPOS,' ')

//% Acid.Trab.
nPOS:= AT(" ", ltrim(cEncargos) ) 
cEncargos1 :=  substr(ltrim(cEncargos), 1, nPOS) 
nEncargos +=  val(cEncargos1)  /100

//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ  Verbas .T.
cQuery:= "SELECT RV_COD ,RV_PAYROLL ,RV_TIPOCOD, RV_DPAYROL FROM SRV"+cEmp+"0 "  +CRLF
cQuery+= "	WHERE RV_PAYROLL = 'T' AND D_E_L_E_T_=''" +CRLF 
cQuery+= "ORDER BY RV_TIPOCOD " +CRLF  //JSS - ADD ORDER BY RV_TIPOCOD  - CHAMDO 019980

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TRT',.F.,.T.)  //execu็ใo da query


cQry += " SELECT RA.RA_NOME AS EMPLOYEE ,CT.CTT_DESC01 AS DEPARTAMENTO ,RA.RA_ADMISSA AS HIRING_DATE " +CRLF  

//---- Adicionando verbas selecionadas na Query

While TRT->(!eof()) // .AND. !EMPTY( ALLTRIM(TRT->RV_DPAYROL)) .and. TRT->RV_COD <> 'B00'

if !EMPTY( ALLTRIM(TRT->RV_DPAYROL)) .and. TRT->RV_COD <> 'B00'
	cQry += " ,MAX(CASE WHEN RV.RV_COD = '"+ TRT->RV_COD +"' THEN RD.RD_VALOR ELSE 0 END) AS	'"+ STRTRAN(ALLTRIM(TRT->RV_DPAYROL),' ','_') +"'   " +CRLF
	
    IF TRT->RV_COD <>'001'  .AND. 	TRT->RV_COD <> 'B00'
		AADD(aTRT, {ALLTRIM(TRT->RV_DPAYROL), TRT->RV_COD , RV_TIPOCOD }  )    //Adiciona as Colunas Dentro de um Array
	ENDIF
endif
	
	TRT->(DBSKIP())
enddo    

//**ALTERADO
if aScan(aTRT, { |X,Y|  X[2] == "C94"})>0
	if aScan(aTRT, { |X,Y|  X[2] == "C93"})>0
		if aScan(aTRT, { |X,Y|  X[2] == "C83"})>0
			lTVerbsI:=.T.
		endif
	endif
endif
//**

//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ    VALORES DE VERBAS NA TABELA DE ACUMULADOS   
cQry +=" ,MAX(CASE WHEN RV.RV_COD = 'B00' THEN RD.RD_VALOR ELSE 0 END) AS	'SALARIO_B'  "    
cQry +=" ,MAX(CASE WHEN RV.RV_COD = '001' THEN RD.RD_VALOR ELSE 0 END) AS	'SALARIO_BASE'  "    
cQry += "  FROM SRD"+cEmp+"0 AS RD		"+CRLF
cQry += " INNER JOIN SRV"+cEmp+"0 AS RV ON RD.RD_PD = RV.RV_COD		" +CRLF
//cQry += " INNER JOIN SRA"+cEmp+"0 AS RA ON RA.RA_MAT = RD.RD_MAT AND RD.RD_DATPGT = '"+cData+"' AND  RA.RA_SITFOLH <> 'D'   " +CRLF
//cQry += " INNER JOIN SRA"+cEmp+"0 AS RA ON RA.RA_MAT = RD.RD_MAT AND RD.RD_DATPGT = '"+cData+"' AND RA.RA_SALARIO<>0 AND (RA.RA_DEMISSA='' OR SUBSTRING(RA.RA_DEMISSA,1,6) = '"+GETMV('MV_FOLMES')+"') "+CRLF
cQry += " INNER JOIN SRA"+cEmp+"0 AS RA ON RA.RA_MAT = RD.RD_MAT AND RD.RD_DATARQ = '"+SUBSTR(cData,1,6)+"' AND RA.RA_SALARIO<>0 AND (RA.RA_DEMISSA='' OR SUBSTRING(RA.RA_DEMISSA,1,6) >= '"+SUBSTR(cData,1,6)+"') "+CRLF
cQry += " INNER JOIN CTT"+cEmp+"0 AS CT ON RA.RA_CC = CT.CTT_CUSTO  " +CRLF
cQry += " WHERE RD.D_E_L_E_T_='' AND RV.D_E_L_E_T_='' AND RA.D_E_L_E_T_='' AND CT.D_E_L_E_T_='' AND RD.RD_FILIAL='"+xFilial("SRD")+"' AND RA.RA_FILIAL='"+xFilial("SRA")+"' AND CT.CTT_FILIAL='"+xFilial("CTT")+"' AND RV.RV_FILIAL='"+xFilial("SRV")+"'  "+CRLF
cQry += " GROUP BY RA.RA_NOME, RA.RA_SALARIO ,  CT.CTT_DESC01 , RA.RA_MAT,RA.RA_ADMISSA " +CRLF 

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQry),'TRB',.F.,.T.)  //execu็ใo da query


//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ H T M L

//RRP - 11/09/2013 - Ajuste no fonte para nใo causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Cria็ใo do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Grava็ใo do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml:=''
cHtml+='<html>   '+CRLF
cHtml+='<head>'+CRLF
cHtml+='<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'+CRLF
cHtml+='<title>PAYROLL</title>'+CRLF
cHtml+='<style type="text/css">'+CRLF
cHtml+='<!--'+CRLF
cHtml+='.style1 {font-family: Arial, Helvetica, sans-serif}'+CRLF
cHtml+='.style3 {font-size: 16px}'+CRLF
cHtml+='.style5 {font-size: 12px}'+CRLF
cHtml+='.style6 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #FFFFFF; }'+CRLF
cHtml+='.style7 {color: #FFFFFF}'+CRLF
cHtml+='.style14 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; }'+CRLF
cHtml+='.style17 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; color: #FFFFFF; }'+CRLF
cHtml+='.style19 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }'+CRLF
cHtml+='.style2 {	color: #FF0000;	font-family: Arial, Helvetica, sans-serif;	font-weight: bold;	font-size: 14px;}'+CRLF
cHtml+='.style4 {	color: #000099;	font-family: Arial, Helvetica, sans-serif;	font-weight: bold;	font-size: 14px;}  '+CRLF
cHtml+='-->'+CRLF
cHtml+='</style>'+CRLF
cHtml+='</head>'+CRLF
cHtml+='<body>'+CRLF
cHtml+='<div>'+CRLF

//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจCabe็alho da tabelaจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
cHtml+='  <table border="0">'+CRLF
cHtml+=' <tr>'+CRLF
cHtml+='   <td height="36" colspan="'+cValtoChar(5+len(aTRT)+3)+'" bgcolor="#bdaee1"><div align="left" class="style1"><STRONG>PAYROLL FOR THE MONTH OF ' +				;
UPPER(cmonth(stod(cData)))+'</STRONG></div></td>'+CRLF
cHtml+=' </tr>'+CRLF
cHtml+='    <td bgcolor="#451F45"><h4 class="style6">EMPLOYEE</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">DEPARTAMENT</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">BASE SALARY</td>'+CRLF  
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">MONTH SALARY</td>'+CRLF 
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">HIRING DATE</td>'+CRLF


//-----------------------------  Adicionando os VALORES das verbas nos Cabe็alhos
for x:=1 to len(aTRT)
	cHtml+='      <td bgcolor="#451F45"><h4 class="style6">' + aTRT[x][1] + ' </td>' +CRLF
next   


cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL PROVENTOS</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL DESCONTOS</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL</td>'+CRLF
cHtml+='    </td>'+CRLF

TRB->(dbgotop())

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

While TRB->(!EOF())   
	TRT->(dbgotop())      
	
	//--------      Linhas e colunas com os respectivos valores
	cHtml+='    <tr>'+CRLF
	cHtml+='      <td nowrap bgcolor="#F2E1F2"><span class="style14" >'+ Capital(EMPLOYEE)	+'</td>'+CRLF
	CHtml+='      <td nowrap  bgcolor="#F2E1F2"><span class="style14" >'+ Capital(DEPARTAMENTO)	 +'</td>'+CRLF
		cHtml+='      <td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" >'+ STRTRAN(cVALTOCHAR(SALARIO_B ),'.',',')			+'</td>'+CRLF
	cHtml+='      <td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" >'+ STRTRAN(cVALTOCHAR(SALARIO_BASE ),'.',',')			+'</td>'+CRLF
	cHtml+='      <td nowrap bgcolor="#F2E1F2"><div align="right"><span class="style14">'+ cmonth(stod(cvaltochar(HIRING_DATE)))+' / '		+		;
   															cvaltochar(DAY(stod(HIRING_DATE)) )+' / '+cvaltochar(YEAR(STOD(HIRING_DATE)) ) +'</td>'+CRLF
	
	AADD(aTotais,{})
	ncont++
	//------------------------ Adiciona Verbas e Valores em um Array
	WHILE TRT->(!EOF())  
	    if 	TRT->RV_COD <> '001' .AND.	TRT->RV_COD <> 'B00'
			AADD(aTotais[ncont],{ iif(valtype(&(strtran(alltrim(TRT->RV_DPAYROL)," ","_")))<>'c',iif(empty(&(strtran(alltrim(TRT->RV_DPAYROL)," ","_"))),0,&(strtran(alltrim(TRT->RV_DPAYROL),' ','_'))),;
	   		&(strtran(alltrim(TRT->RV_DPAYROL)," ","_"))), TRT->RV_TIPOCOD  })    
	   		 
	   		  if 	TRT->RV_COD <> '510'    

	   		  		nIRFERIAS :=iif(valtype(&(strtran(alltrim(TRT->RV_DPAYROL)," ","_")))<>'c',iif(empty(&(strtran(alltrim(TRT->RV_DPAYROL)," ","_"))),0,&(strtran(alltrim(TRT->RV_DPAYROL),' ','_'))),;
	   	  							&(strtran(alltrim(TRT->RV_DPAYROL)," ","_")))  +nIRFERIAS
	   		 
	   		 
	   		  elseif TRT->RV_COD <> '501'   
	   		  		NINSSS :=iif(valtype(&(strtran(alltrim(TRT->RV_DPAYROL)," ","_")))<>'c',iif(empty(&(strtran(alltrim(TRT->RV_DPAYROL)," ","_"))),0,&(strtran(alltrim(TRT->RV_DPAYROL),' ','_'))),;
	   	   							&(strtran(alltrim(TRT->RV_DPAYROL)," ","_"))) +NINSSS
	   		  endif
	   		
	   		TRT->(DBSKIP())  
		else 
	   		TRT->(DBSKIP())  
		endif
	ENDDO
	     
	//Soma do Cแlculo Total - Coluna 
	nSalario := SALARIO_BASE + nSalario 
	nSalarioB :=SALARIO_B +	nSalarioB 
	 
	FOR y:=1 to len(aTRT)
		cHtml+=' <td bgcolor="#F2E1F2"><div align="right"><span class="style14">' + strtran( cvaltochar(aTotais[z][y][1]),'.',',') + '</td>'+CRLF
	  
	   	//if aTRT[y][3]	=='3'       
	   	//	nTotProv := aTotais[z][y][1] +  nTotProv   
	   	
	   	//alterado matheus - 02/06/2011	
		if aTRT[y][3]	=='1' 
	   		nTotProv := aTotais[z][y][1] +  nTotProv      
	   		
	    ELSEif aTRT[y][3]	=='2'
	   		nTotDesc := aTotais[z][y][1] +  nTotDesc  
		endif
                                                                                       
  	NEXT
	
	nTotProv  := SALARIO_BASE + nTotProv    
	
	cHtml+='<td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" ><STRONG>'+strtran( cValtoChar(nTotProv),'.',',') + '</TD>'+CRLF
	cHtml+='<td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" ><STRONG>'+strtran( cValtoChar(nTotDesc) ,'.',',')+ '</TD>'+CRLF
	
		nTot := nTotProv - nTotDesc  // Calculo da ultima coluna -  TOTAIS
	cHtml+='<td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" ><STRONG>'+strtran(  cValtoChar( nTot ),'.',',') + '</TD>'+CRLF
	
	aadd(aTotTot,{nTotProv,nTotDesc,nTot})
	
	//alterado Matheus - 01/06/11
	aadd(aBaseFGTS,{aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "B20"})][1]})
    
	//**ALTERADO - 10/08/2011 - tratar coluna WITHHOLDING INCOME TAX
   	if aScan(aTRT, { |X,Y|  X[2] == "510"})>0
    	   	if aScan(aTRT, { |X,Y|  X[2] == "521"})>0
    	   		nWITHHOLDINGINCOMETAX+=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "510"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "521"})][1]
    	   	else
	    	   	nWITHHOLDINGINCOMETAX+=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "510"})][1]
    	   	endif
    elseif aScan(aTRT, { |X,Y|  X[2] == "521"})>0
    	nWITHHOLDINGINCOMETAX+=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "521"})][1]
    endif	

	//**ALTERADO
   	if aScan(aTRT, { |X,Y|  X[2] == "500"})>0
   		if aScan(aTRT, { |X,Y|  X[2] == "501"})>0    	
			if aScan(aTRT, { |X,Y|  X[2] == "502"})>0   
		    	aadd(aBase500,{aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "501"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "502"})][1]})
		    else
			    aadd(aBase500,{aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "501"})][1]})
		    endif
		else
	 		if aScan(aTRT, { |X,Y|  X[2] == "502"})>0		
			    aadd(aBase500,{aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "502"})][1]})	 		
	 		else
				aadd(aBase500,{aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]})	 		
	 		endif
		endif
    else
	    aadd(aBase500,{0})
    endif
    
    if lTVerbsI
    	if aScan(aTRT, { |X,Y|  X[2] == "500"})>0
    	
    		if aScan(aTRT, { |X,Y|  X[2] == "501"})>0    	
    			if aScan(aTRT, { |X,Y|  X[2] == "502"})>0    	
    				nValIN_:=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C94"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C93"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C83"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "501"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "502"})][1]
    			else
					nValIN_:=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C94"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C93"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C83"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "501"})][1]
    			endif
    		else
	    		if aScan(aTRT, { |X,Y|  X[2] == "502"})>0    	
	    			nValIN_:=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C94"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C93"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C83"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "502"})][1]   			
    			else 
	    			nValIN_:=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C94"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C93"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C83"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "500"})][1]
    			endif
    		endif		
    	else 
    		nValIN_:=aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C94"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C93"})][1]+aTotais[z][aScan(aTRT, { |X,Y|  X[2] == "C83"})][1]
    	endif    	
    	aadd(aBaseINSS,{nValIN_})	
    endif
	//**
		nTotProv:= 0
		nTotDesc:= 0
	z++
	cHtml+='    </tr>'+CRLF
	
	cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	
	TRB->(DBSKIP())
	
ENDDO

/*จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
											Linha com o conteudo de TOTAIS.
จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ */
cHtml+='<TR> <td height="36" colspan="2" bgcolor="#bdaee1"><div align="left" class="style1"><STRONG>TOTAL</STRONG></TD>'+CRLF   
cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(nSalarioB),'.',',')+ '</TD>'+CRLF
cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(nSalario),'.',',')+ '</TD>'+CRLF
cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+'   '+ '</TD>'+CRLF

for y:=1 to len(aTRT)
	cTotal := 0
	for z:=1 to len(aTotais)
		cTotal  += aTotais[z][y][1]
	next
	
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+strtran( cvaltochar(cTotal),'.',',')+ '</TD>'+CRLF
next


for x:=1 to len(aTotTot)      
	aTotTotP:= aTotTot[x][1] +	aTotTotP
	aTotTotD:= aTotTot[x][2] +	aTotTotD
	aTotTotT:= aTotTot[x][3] +	aTotTotT
next  
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(aTotTotP),'.',',')+ '</TD>'+CRLF 
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(aTotTotD),'.',',')+ '</TD>'+CRLF
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(aTotTotT),'.',',')+ '</TD>'+CRLF


//======================================================================================================================================================
//==						  							COMPANY COSTS OF EACH EMPLOYEE
//======================================================================================================================================================
cHtml+='</tr><tr><td>'+CRLF
cHtml+='<P>&nbsp;</P>'+CRLF
cHtml+='<P>&nbsp;</P>'+CRLF
cHtml+='</tr></td>'+CRLF
cHtml+='<tr><td height="36" colspan="3" bgcolor="#bdaee1"><div align="left" class="style1"><strong>COMPANY COSTS OF EACH EMPLOYEE</strong></td>'+CRLF
cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">EMPLOYEE</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">SOCIAL SECURITY</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF

i:= 1 
nFgts :=0   
nInss :=0   

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

TRB->(dbgotop())
While TRB->(!EOF()) .and. i <= len(aTotTot)  
		cHtml+='<TR>'
		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+Capital(EMPLOYEE )	+'</td>'+CRLF
//		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran( CVALTOCHAR(NOROUND(aTotTot[i][1] * nEncargos ,2)),'.',',')	 +'</td>'+CRLF
//		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran(cvaltochar(aTotTot[i][1] * 0.08),'.',',') +'</td>'+CRLF
        
		//alterado Matheus - 01/06/11
//		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran( CVALTOCHAR(NOROUND(aBaseFGTS[i][1] * nEncargos ,2)),'.',',')	 +'</td>'+CRLF
//		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran(cvaltochar(aBaseFGTS[i][1] * 0.08),'.',',') +'</td>'+CRLF
//		cHtml+='</TR>'
		
//        nInss := (aTotTot[i][1] * nEncargos)  + nInss
//        nFgts := (aTotTot[i][1] * 0.08)+ nFGTS

		//alterado Matheus - 01/06/11
//        nInss := (aBaseFGTS[i][1] * nEncargos)  + nInss
//        nFgts := (aBaseFGTS[i][1] * 0.08)+ nFGTS

		//**ALTERADO
		if lTVerbsI
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran( CVALTOCHAR(NOROUND(aBaseINSS[i][1] ,2) ),'.',',')	 +'</td>'+CRLF
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran(cvaltochar(aBaseFGTS[i][1] * 0.08),'.',',') +'</td>'+CRLF
			cHtml+='</TR>'        	
        else
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran( CVALTOCHAR(NOROUND((aBaseFGTS[i][1] * nEncargos)+aBase500[i][1] ,2) ),'.',',')	 +'</td>'+CRLF
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran(cvaltochar(aBaseFGTS[i][1] * 0.08),'.',',') +'</td>'+CRLF
			cHtml+='</TR>'        
	    endif

		if lTVerbsI         
	        nInss := aBaseINSS[i][1]  + nInss
	        nFgts := (aBaseFGTS[i][1] * 0.08)+ nFGTS
        else 
        	nInss := ((aBaseFGTS[i][1] * nEncargos)+aBase500[i][1])  + nInss
        	nFgts := (aBaseFGTS[i][1] * 0.08)+ nFGTS        
        endif  
        //**
        
		i++
		
	cHtml := Grv(cHtml) //Grava e limpa memoria da variavel. 
		
	TRB->(DBSKIP())      //PROXIMO REGISTRO     		
ENDDO

cHtml+='<tr><td height="36" bgcolor="#bdaee1"><div align="left" class="style1"><strong>TOTAL </strong></td>'+CRLF
cHtml+='<td height="36"  bgcolor="#bdaee1"><div align="right"class="style1"><strong>'+strtran(cValtoChar(NOROUND(nInss,2)),'.',',')+'</strong></td>'+CRLF
cHtml+='<td height="36"  bgcolor="#bdaee1"><div align="right" class="style1"><strong>'+strtran(cValtoChar(NOROUND(nFgts,2)),'.',',')+'</strong></td></TR>'+CRLF

cHtml+='<td></td>'+CRLF
cHtml+='<td></td></tr>'+CRLF


//======================================================================================================================================================
//==																	 SOCIAL COST
//======================================================================================================================================================


cHtml+='</tr><tr><td>'+CRLF
cHtml+='<P>&nbsp;</P>'+CRLF
cHtml+='<P>&nbsp;</P>'+CRLF
cHtml+='</tr></td>'+CRLF
cHtml+='<tr><td height="36" colspan="2" bgcolor="#CCCCCC"><div align="left" class="style1"><strong>SOCIAL COST</strong></td></tr>'+CRLF
cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">SOCIAL SECURITY</td>  '+CRLF
//cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+cValtoChar(NOROUND(nInss+nINSSS,2)) +'</td> </tr> '+CRLF
//Alterada 10/08/2011
cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+cValtoChar(NOROUND(nInss,2)) +'</td> </tr> '+CRLF
cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF
cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ cValtoChar(NOROUND(nFgts,2))+'</td> </tr> '+CRLF
cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">WITHHOLDING INCOME TAX</td>'+CRLF
//cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ cValtoChar(nIR+nIRFERIAS)+'</td> </tr> '+CRLF

if !empty(nWITHHOLDINGINCOMETAX)
	cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ cValtoChar(nWITHHOLDINGINCOMETAX)+'</td> </tr> '+CRLF
else
	cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ cValtoChar(nIR+nIRFERIAS)+'</td> </tr> '+CRLF
endif

cHtml+='  </table>'+CRLF
cHtml+='</div>'+CRLF
cHtml+='</body>'+CRLF
cHtml+='</html>'+CRLF
cHtml+=''+CRLF

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
 
//RRP - 11/09/2013 - Ajuste no fonte para nใo causar estouro de variavel.
If nBytesSalvo <= 0   //Verifica็ใo do arquivo (GRAVADO OU NAO) e defini็ใo de valor de Bytes retornados.
	if ferror()	== 516
		MsgStop("Erro de grava็ใo do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	else
		MsgStop("Erro de grava็ใo do Destino. Error = "+ str(ferror(),4),'Erro')
    endif
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	
	sleep(8000) //Para dar tempo de gerar o arquivo
	If cValtochar(cTipo) == '3'
		SENDMAIL()	
	Else 
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel ou Html
	EndIf
endif

	sleep(8000) //Para dar tempo de gerar o arquivo         

FErase(cDest+cArq)

TRV->(dbcloseAREA())
TRB->(dbcloseAREA())
TRT->(dbcloseAREA())

Return cHtml

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variแvel cHtml em partes para nใo causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 11/09/2013
M๓dulo      : Gestใo Pessoal.
Cliente     : Todos.
*/
*------------------------------*
Static Function Grv(cHtml)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

//=========================================================================================================================================
// 							   				Envia Email ?
//=========================================================================================================================================
*------------------------------*
STATIC FUNCTION SENDMAIL //(cPara,cMsg,cAssunto, cAnexo)
*------------------------------*
cAnexo	 := curdir()+'payroll.xls'
cPara  	 := space(60)
cCCo	 := space(60)
cAssunto := space(60)
cMsg	 := ''


DEFINE MSDIALOG oDlg TITLE " Send PayRoll" FROM 000, 000  TO 350, 470 COLORS 0, 16777215 PIXEL

@ 037, 007 SAY oParaS PROMPT "Para" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 052, 007 SAY oCCoS PROMPT "CCo" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 023, 007 SAY oAssuntoS PROMPT "Assunto" SIZE 024, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 072, 007 SAY oMsgS PROMPT "Mensagem" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 023, 033 MSGET oAssunto VAR cAssunto SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 037, 033 MSGET oParaG VAR cPara SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 052, 033 MSGET oCCoG VAR cCCo SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 072, 033 GET 	oMsg VAR cMsg OF oDlg MULTILINE SIZE 171, 072 COLORS 0, 16777215 HSCROLL PIXEL

@ 148, 124 BUTTON oEnviar PROMPT "Enviar" SIZE 037, 012 OF oDlg  ACTION {||U_GTFOLMAIL(cPara,cCCo,cMsg,cAssunto, cAnexo),oDlg:END()} PIXEL
@ 148, 164 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION oDlg:END() PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

RETURN
