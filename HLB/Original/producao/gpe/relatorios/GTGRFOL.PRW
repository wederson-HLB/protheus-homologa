#include "Protheus.CH"
#include "APWEBEX.CH"
#include "TBICONN.CH"


/*
+-----------------------------------------------------------------------------
| Fun็ใo | GTGRFOL()  | Autor | Ana Carolina Gabriel  	|  Data  | 24/01/2011|
+----------------------------------------------------------------------------+
| Descri็ใo |  Gera um relatorio de folha de pagamento, com todas as verbas  |
|			|  e totais com data do periodo atual							 |
+----------------------------------------------------------------------------+
| Uso		|		 Gera็ใo de Relatorio                                    |
+----------------------------------------------------------------------------+

Funcao      : GTGRFOL 
Parametros  : cEmp,cFil
Retorno     : Nenhum
Objetivos   : Gera um relatorio de folha de pagamento, com todas as verbas e totais com data do periodo atual
Autor     	: Ana Carolina Gabriel  	 	
Data     	: 24/01/2011
Obs         : 
TDN         : 
Revisใo     : Tiago Luiz Mendon็a 
Data/Hora   : 15/03/2012
M๓dulo      : Gestใo Pessoal.
Cliente     : Todos.
*/

*---------------------------------*
 User Function GTGRFOL(cEmp,cFil)
*---------------------------------* 

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
NINSSSF := 0 
NIRSF := 0   
NINSDT := 0  

aBaseFGTS:={}

//=====================================================================================================================================================
//==					   								 PAYROLL PAYROLL FOR THE MONTH
//=====================================================================================================================================================
 
 
 //-------------------------------------------------------------------------------------------------------------------------
 // Se as tabelas temporarias estiverem abertas, fecha.
 //------------------------------------------------------------------------------------------------------------------------- 
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
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจValores de Encargos de Empresas.     
//=====================================================================================================================================================

////-----  Percorre parametros para valores dos calculos - Parametro 14, ENCARGOS DA EMPRESA
cQryTRV:= "SELECT * FROM SRX"+cEmp+"0"   + CRLF
cQryTRV +=   "WHERE RX_TIP = '14' AND D_E_L_E_T_ <> '*' "  + CRLF

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQryTRV),'TRV',.F.,.T.)  //execu็ใo da query

//Percorre a tabela temporaria onde estใo indicados os valores dos encargos   para a  separa็ใo da sring por valores especificados
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
                                           

 //-------------------------------------------------------------------------------------------------------------------------
 //										 Verifica as Verbas MARCADAS COMO =  .T. 
 //-------------------------------------------------------------------------------------------------------------------------
cQuery:= "SELECT RV_COD ,RV_PAYROLL ,RV_TIPOCOD, RV_DPAYROL FROM SRV"+cEmp+"0 "  +CRLF
cQuery+= "	WHERE RV_PAYROLL = 'T' AND D_E_L_E_T_ <> '*' " +CRLF

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TRT',.F.,.T.)  //execu็ใo da query

//-------------------------------------------------------------------------------------------------------------------------
//                  Separa por Empregado as verbas indicadas em TRT(TABELA TEMPORARIA DE Verbas MARCADAS COMO =  .T. ) 
//		se os memos se encontram na SRC
//-------------------------------------------------------------------------------------------------------------------------

cQry += " SELECT RA.RA_NOME AS EMPLOYEE ,CT.CTT_DESC01 AS DEPARTAMENTO ,RA.RA_ADMISSA AS HIRING_DATE" +CRLF
While TRT->(!eof())
  	If !EMPTY( ALLTRIM(TRT->RV_DPAYROL)) .and. TRT->RV_COD <> 'B00'
		cQry += " ,MAX(CASE WHEN RV.RV_COD = '"+ TRT->RV_COD +"' THEN RC.RC_VALOR ELSE 0 END) AS	'C"+ TRT->RV_COD+"'   " +CRLF
    	IF TRT->RV_COD <>'001'  .AND. 	TRT->RV_COD <> 'B00'
			AADD(aTRT, {ALLTRIM(TRT->RV_DPAYROL), TRT->RV_COD , RV_TIPOCOD }  )    //Adiciona as Colunas Dentro de um Array
		ENDIF
	EndIf
	TRT->(DBSKIP())
enddo    
cQry +=" ,MAX(CASE WHEN RV.RV_COD = 'B00' THEN RC.RC_VALOR ELSE 0 END) AS	'SALARIO_B'  "    
cQry +=" ,MAX(CASE WHEN RV.RV_COD = '001' THEN RC.RC_VALOR ELSE 0 END) AS	'SALARIO_BASE'  "    
cQry += "  FROM SRC"+cEmp+"0 AS RC		"+CRLF
cQry += " INNER JOIN SRV"+cEmp+"0 AS RV ON RC.RC_PD = RV.RV_COD		" +CRLF
//cQry += " INNER JOIN SRA"+cEmp+"0 AS RA ON RA.RA_MAT = RC.RC_MAT AND RA.RA_SITFOLH <> 'D'   " +CRLF 
cQry += " INNER JOIN SRA"+cEmp+"0 AS RA ON RA.RA_MAT = RC.RC_MAT AND RA.RA_SALARIO<>0 AND (RA.RA_DEMISSA='' OR SUBSTRING(RA.RA_DEMISSA,1,6) = '"+GETMV('MV_FOLMES')+"') "+CRLF
cQry += " INNER JOIN CTT"+cEmp+"0 AS CT ON RA.RA_CC = CT.CTT_CUSTO  " +CRLF
cQry += " WHERE RC.D_E_L_E_T_='' AND RV.D_E_L_E_T_='' AND RA.D_E_L_E_T_='' AND CT.D_E_L_E_T_='' "+CRLF
cQry += " AND RC.RC_FILIAL = '"+xFilial("SRC")+"' AND RV.RV_FILIAL='"+xFilial("SRV")+"' AND CT.CTT_FILIAL='"+xFilial("CTT")+"' AND RA.RA_FILIAL='"+xFilial("SRA")+"'  "+CRLF
cQry += " GROUP BY RA.RA_NOME, RA.RA_SALARIO ,  CT.CTT_DESC01 , RA.RA_MAT,RA.RA_ADMISSA" +CRLF

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQry),'TRB',.F.,.T.)  //execu็ใo da query
                                                                                     
//==========================================================================================================================================
//														H T M L    
//==========================================================================================================================================
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
cHtml+='   <td height="36" colspan="'+cValtoChar(5+len(aTRT)+3)+'" bgcolor="#bdaee1"><div align="left" class="style1"><STRONG>PAYROLL</STRONG></div></td>'+CRLF
cHtml+=' </tr>'+CRLF
cHtml+='    <td bgcolor="#451F45"><h4 class="style6">EMPLOYEE</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">DEPARTAMENT</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">BASE SALARY</td>'+CRLF  
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">MONTH SALARY</td>'+CRLF 
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">HIRING DATE</td>'+CRLF

//==================================================================================
//-----------------------------  Adicionando os nomes das verbas nos Cabe็alhos   
//==================================================================================
for x:=1 to len(aTRT)
	cHtml+='      <td bgcolor="#451F45"><h4 class="style6">' + aTRT[x][1] + ' </td>' +CRLF
next 
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL PROVENTOS</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL DESCONTOS</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL</td>'+CRLF
cHtml+='    </td>'+CRLF

TRB->(dbgotop())

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
	    if 	TRT->RV_COD <> '001' .AND.	TRT->RV_COD <> 'B00'  .AND.   !EMPTY( ALLTRIM(TRT->RV_DPAYROL))
	    	//Tratamento para pegar os valores das colunas especificadas por Apelidos
			AADD(aTotais[ncont],{ iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   		&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))), TRT->RV_TIPOCOD  })    
   
     //----- I R	   		 
	   		  if 	TRT->RV_COD == '510' //   IRRF S/SALARIO         
	   		  		nIR:=iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   	 					  		&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))   + nIR 
		  
	   		  elseif	TRT->RV_COD == '521' //  IRRF S/ FERIAS      
	   		  		nIRFERIAS :=iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   	  							&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))  +nIRFERIAS    
	   	  							
	   	  	elseif TRT->RV_COD == '515' //IRRF S/13บ SAL.       
	   		  		NIRSF :=iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   	   							&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))) +NIRSF
	  //----- I N S S
	   		  elseif TRT->RV_COD == '500' // INSS                  
	   		  		NINSSS :=iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   	   							&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))) +NINSSS 
	   	   							
	   	  	  elseif TRT->RV_COD == '502'    // INSS S/ 13บSAL.     
	   		  		NINSDT :=iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   	   							&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))) +NINSDT
	   	   							
	   	   	 elseif TRT->RV_COD == '501'   // INSS S/ FERIAS      
	   		  		NINSSSF :=iif(valtype(&(strtran(alltrim('C'+TRT->RV_COD)," ","_")))<>'c',iif(empty(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))),0,&(strtran(alltrim('C'+TRT->RV_COD),' ','_'))),;
	   	   							&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))) +NINSSSF 
	   	   	 
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
	
		nTotProv:= 0
		nTotDesc:= 0
	z++
	cHtml+='    </tr>'+CRLF
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

//aScan(aTRT, { |X,Y|  X[2] == "B20"})

TRB->(dbgotop())
While TRB->(!EOF()) .and. i <= len(aTotTot)  
		cHtml+='<TR>'
		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+Capital(EMPLOYEE )	+'</td>'+CRLF
		//cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran( CVALTOCHAR(NOROUND(aTotTot[i][1] * nEncargos ,2)),'.',',')	 +'</td>'+CRLF
		//cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran(cvaltochar(aTotTot[i][1] * 0.08),'.',',') +'</td>'+CRLF
		
		//alterado Matheus - 01/06/11
		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran( CVALTOCHAR(NOROUND(aBaseFGTS[i][1] * nEncargos ,2)),'.',',')	 +'</td>'+CRLF
		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+strtran(cvaltochar(aBaseFGTS[i][1] * 0.08),'.',',') +'</td>'+CRLF
		cHtml+='</TR>'

//        nInss := (aTotTot[i][1] * nEncargos)  + nInss
//        nFgts := (aTotTot[i][1] * 0.08)+ nFGTS

		//alterado Matheus - 01/06/11
        nInss := (aBaseFGTS[i][1] * nEncargos)  + nInss
        nFgts := (aBaseFGTS[i][1] * 0.08)+ nFGTS		
		i++	
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
cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+strtran(cValtoChar(NOROUND(nInss + NINSSSF + NINSDT + NINSSS,2)),'.',',') +'</td> </tr> '+CRLF
cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF            
//NFGTS=
cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ strtran(cValtoChar(NOROUND(nFgts,2)),'.',',')+'</td> </tr> '+CRLF
cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">WITHHOLDING INCOME TAX</td>'+CRLF  
//NIR = 
//NIRSF 
//NIRFERIAS =
cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ strtran(cValtoChar(NIRSF+nIR+nIRFERIAS),'.',',')+'</td> </tr> '+CRLF
//*/
cHtml+='  </table>'+CRLF
cHtml+='</div>'+CRLF
cHtml+='</body>'+CRLF
cHtml+='</html>'+CRLF
cHtml+=''+CRLF

TRV->(dbcloseAREA())
TRB->(dbcloseAREA())
TRT->(dbcloseAREA())

Return cHtml
