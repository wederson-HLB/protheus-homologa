#Include "apwebex.ch"
#include "tbiconn.ch"     
#include "totvs.ch"  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDGRA2  ºAutor  ³Tiago Luiz Mendonça º Data ³  31/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de graficos de chamados de help-desk.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                
/*
Funcao      : GTHDGRA2
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX de grafico de chamados.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/08/11 20:00
Revisão     : Jean Victor Rocha
Data/Hora   : 04/01/2013
*/

*--------------------------*
  User Function GTHDGRA2()
*--------------------------*    

Local cHtml  := ""   
Local cMes   := ""
Local cAux   := ""
Local cCab   := ""
Local cItens := ""

Local dDate  := DATE()
   
Local lAux  := .F.

Local n      :=	0  
Local i      :=	0 
Local nTotal :=	0
Local nPPer  :=	0
Local nPCham :=	0  

Local n1     := 0
Local n2     := 0
Local n3     := 0
Local n4     := 0
Local n5     := 0
Local n6     := 0
Local n7     := 0
Local n8     := 0
Local n9     := 0    


Local aAux   := {}    

   		                 
//IF !(HttpPost->cPass) == "H12233"
//	Return .F.
//EndIf   		   

//Conecta na empresa
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" USER "administrador" PASSWORD 'hdgt@23' MODULO "FAT"      

RpcSetType(3)
RpcSetEnv("01", "01") 
  
WEB EXTENDED INIT  cHtml 

cHtml += '<html> '   
cHtml += '<link rel="shortcut icon" href="favicon.ico">'
cHtml += "<table border='0' width='1010', height='050' align=center > "
cHtml += '	<tr>'
cHtml += '		<td> '
cHtml += '			<center> '
cHtml += '				<font size="4" face="Verdana" > '
cHtml += '	 				<b>Estatísticas de Chamados </b>'
cHtml += '				</font>'
cHtml += '				<HR>' 
cHtml += '              <Br>'
cHtml += '			</center>'
cHtml += '		</td>'
cHtml += '	</tr>'
cHtml += '</table>'			
       
cHtml += '<table border="0" align=center >'

//1º Linha----------------------------------------------------------------------------------------------------------------------------
cHtml += '<Tr>'

//Posicao I - Grafico I - 
cHtml += "		<Td  width='500', height='500'>" 
cHtml += '		<font size="2" face="Verdana" > '                                   
cHtml += '			<b><center>Chamados Abertos e Solucionados por dia</center></b>' 
cHtml += '		</font>'
cHtml += '    <script type="text/javascript" src="https://www.google.com/jsapi"></script> '
cHtml += '    <script type="text/javascript">'
cHtml += '      google.load("visualization", "1", {packages:["corechart"]});'
cHtml += '      google.setOnLoadCallback(drawChart); '
cHtml += '      function drawChart() {'
cHtml += '        var data = new google.visualization.DataTable(); '
cHtml += "       data.addColumn('string', 'Meses');
cHtml += "        data.addColumn('number', 'Solucionados');" 
cHtml += "        data.addColumn('number', 'Abertos');"
cHtml += "         data.addRows([
 
    GraficoIII("DADOS")
	TempZ01H->(DbGoTop())
 
	While TempZ01H->(!Eof())      
		//Quantidade de chamados encerrados
		cAux:=GraficoIII("QTDE",TempZ01H->Z01_DT_ENC)
	    If  Alltrim(cAux) <> "0" // Chamados encerrados não pode ser 0.    
	    	If !(lAux)   // Variavel para tratar a virgula no html
	    	   	lAux:=.T.
	    	Else
	    		cHtml +=","	
	    	EndIf
 			cHtml += " ['"+Substr(Alltrim(TempZ01H->Z01_DT_ENC),7,2)+"',"+GraficoIII("QTDE",TempZ01H->Z01_DT_ENC)+","+GraficoIII("QTDA",TempZ01H->Z01_DT_ENC)+"]" // Retorna a quantidade de chamados abertos e encerrados.
		EndIf	
	 	TempZ01H->(DbSkip())
   EndDo         

cHtml += "         ]); 
cHtml +="         var chart = new google.visualization.AreaChart(document.getElementById('chart_03'));  "
cHtml +="         chart.draw(data, {width: 560, height: 500, title:  ' ', legend: {position: 'top', textStyle: {}},"

//cHtml +="                           hAxis: {title: ' Mês de "+RetMes(dtos(dDataBase))+"', titleTextStyle: {color: 'Black'}}"
If RetMes(dtos(dDataBase)) <> RetMes(dtos(dDataBase-30))
	cHtml +="                           hAxis: {title: ' Mês de "+RetMes(dtos(dDataBase-30))+" / "+RetMes(dtos(dDataBase))+"', titleTextStyle: {color: 'Black'}}"
Else
	cHtml +="                           hAxis: {title: ' Mês de "+RetMes(dtos(dDataBase))+"', titleTextStyle: {color: 'Black'}}"
EndIf

cHtml +="                          });"
cHtml +="       } "
cHtml +="     </script>"
cHtml +="   </head>"
cHtml +="   <body>"
cHtml +='     <div id="chart_03"></div>'
cHtml +="   </body>"  
cHtml += '</Td>'

// Posicao 2 - Grafico IV - Chamados concluídos por analista
cHtml += "	<Td  width='500', height='500'>" 
cHtml += '		<font size="2" face="Verdana" > '                                   
cHtml += '			<b><center>Chamados concluídos hoje - '+Alltrim(GraficoIV("TOTAL"))+' Chamados </center></b>' 
cHtml += '		</font>'

cHtml +='     	<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
cHtml +='    	<script type="text/javascript">'
cHtml +='      		google.load("visualization", "1", {packages:["corechart"]});'
cHtml +='      		google.setOnLoadCallback(drawChart);'
cHtml +='      		function drawChart() {'
cHtml +='        	var data = new google.visualization.DataTable();'
cHtml +="        	data.addColumn('string', 'Atendentes');"
cHtml +="        	data.addColumn('number', 'Chamados');"
cHtml +='        	data.addRows('+Alltrim(GraficoIV("Analistas"))+');'  //Retorna quantidade de chamado concluído por analista.
    
    n:=0
	TempZ02A->(DbGoTop())
	
	While TempZ02A->(!Eof())                
	 	// Verifica se o atendente finalizou chamado
	 	If (i:=Val(GraficoIV("QTD",TempZ02A->Z02_CODUSR))) > 0 
			Z03->(DbSetOrder(2))                  
			If Z03->(DbSeek(xFilial("Z03")+TempZ02A->Z02_CODUSR))   // Posiciona nos atendentes
				cHtml += '        data.setValue('+Alltrim(str(n))+', 0,'+"'"+Upper(Alltrim(Z03->Z03_NOME))+"'"+');'// Retorna a quantidade de chamados abertos
  			EndIf
  			cHtml += '        data.setValue('+Alltrim(str(n))+', 1,'+Alltrim(GraficoIV("QTD",TempZ02A->Z02_CODUSR))+');'// Retorna a quantidade de chamados encerrados
         	n++
        EndIf
	 	TempZ02A->(DbSkip())
    EndDo   

cHtml +="        	var chart = new google.visualization.ColumnChart(document.getElementById('chart04'));"
cHtml +="        	chart.draw(data, {width: 560, height: 500, title: 'Suporters Performance',colors: ['#824BB0'],legend: {position: 'none', textStyle: {}},"  
cHtml +=" 						 hAxis: {title: 'Atendentes', titleTextStyle: {color: 'Black'}} "
cHtml +="                         });"
cHtml +="      		}"
cHtml +="   	 </script>"
cHtml +="   	<body>"
cHtml +='     		<div id="chart04"></div>'
cHtml +="  		</body>"
cHtml += '</Td>'

cHtml += '</Tr>'                                                   

//2º Linha----------------------------------------------------------------------------------------------------------------------------

cHtml += '<tr>'

//Posicao 3 - Grafico III - Chamados por módulos
cHtml += " 	<Td  width='500', height='500' >"    
cHtml += '		<font size="2" face="Verdana" > '  
cHtml += '			<Br>'      
cHtml += '			<Br>'
cHtml += '			<center><b>Chamados abertos ('+Alltrim(GraficoI("TOT"))+') por módulos ('+Alltrim(GraficoI("MOD"))+')</b></Center>'
cHtml += '		</font>'       
cHtml += '    	<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
cHtml += '    	<script type="text/javascript">  '
cHtml += '      	google.load("visualization", "1", {packages:["corechart"]});  '
cHtml += '      	google.setOnLoadCallback(drawChart);'
cHtml += '      	function drawChart() { '
cHtml += '        	var data = new google.visualization.DataTable(); '
cHtml += "        	data.addColumn('string', 'Task');"
cHtml += "        	data.addColumn('number', 'Hours per Day');"
cHtml += '        	data.addRows('+Alltrim(GraficoI("MOD"))+');'  // GraficoI("MOD")) Retorna o número de módulos usados no chamado

	n:=0
	TempZ01A->(DbGoTop())

	If TempZ01A->(!BOF() .and. !EOF())

    	While TempZ01A->(!Eof())   
    		cHtml += "        data.setValue("+Alltrim(str(n))+", 0, '"+Alltrim(UPPER(TempZ01A->Z01_MODULO))+"');"  
			cHtml += '        data.setValue('+Alltrim(str(n))+', 1,'+Alltrim(GraficoI("QTD",TempZ01A->Z01_MODULO))+');'// Retorna a quantidade de chamados por módulo    	       	    	
	    	n++ 
	    	TempZ01A->(DbSkip())  
    	EndDo         

    EndIf     

cHtml += "       	var chart = new google.visualization.PieChart(document.getElementById('chart01'));"
cHtml += "        	chart.draw(data, {width: 560, height: 500, title: ' ', is3D: true}); "
cHtml += '   		   }'
cHtml += '    	</script>'
cHtml += '  	<body>'
cHtml += '    		<div id="chart01"></div>'
cHtml += '  	</body>'   
cHtml += '</Td>'                                                   

//Posicao 4 - Grafico II - Chamados abertos x concluídos mensalmente
cHtml += "		<Td  width='500', height='500'>" 
cHtml += '		<font size="2" face="Verdana" > '     
cHtml += '			<Br>'      
cHtml += '			<Br>                              
cHtml += '			<b><center>Chamados abertos e concluídos por mês</center></b>' 
cHtml += '		</font>'                               
cHtml +='     	<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
cHtml +='    	<script type="text/javascript">'
cHtml +='      		google.load("visualization", "1", {packages:["corechart"]});'
cHtml +='      		google.setOnLoadCallback(drawChart);'
cHtml +='      		function drawChart() {'
cHtml +='        	var data = new google.visualization.DataTable();'
cHtml +="        	data.addColumn('string', 'PERIODO');"
cHtml +="        	data.addColumn('number', 'Abertos');"
cHtml +="        	data.addColumn('number', 'Solucionados');"      
cHtml +="        	data.addColumn('number', 'Cancelados');"
cHtml +="        	data.addColumn('number', 'Pendentes');"
cHtml +='        	data.addRows('+Alltrim(GraficoII("ANOSXMES"))+');'  //Retorna quantidades de periodos anos x meses de atendimento.

    n:=0
	TempZ01C->(DbGoTop())
	While TempZ01C->(!Eof())                
		
	
		//If TempZ01C->PERIODO >= DTOS(Date()-365)
   		If TempZ01C->PERIODO >=	DTOS(YearSub( Date() , 1 ))
 			cMes  := LEFT(RetMes(TempZ01C->PERIODO),3)+"/"+SUBSTR(TempZ01C->PERIODO,1,4)
			nPPer := Val(GraficoII("TOTAL",TempZ01C->PERIODO))-Val(GraficoII("ENCERRADO",TempZ01C->PERIODO))-Val(GraficoII("CANCELADO",TempZ01C->PERIODO))
 			cHtml += "        data.setValue("+Alltrim(str(n))+", 0, '"+Alltrim(UPPER(cMes))+"');"  // Retorna o mes do periodo  
			cHtml += '        data.setValue('+Alltrim(str(n))+', 1,'+Alltrim(GraficoII("TOTAL",TempZ01C->PERIODO))+');'// Retorna a quantidade de chamados abertos
	  		cHtml += '        data.setValue('+Alltrim(str(n))+', 2,'+Alltrim(GraficoII("ENCERRADO",TempZ01C->PERIODO))+');'// Retorna a quantidade de chamados encerrados
	        cHtml += '        data.setValue('+Alltrim(str(n))+', 3,'+Alltrim(GraficoII("CANCELADO",TempZ01C->PERIODO))+');'// Retorna a quantidade de chamados cancelados
    	    cHtml += '        data.setValue('+Alltrim(str(n))+', 4,'+Alltrim(Str(nPPer))+');'// Retorna a quantidade de chamados pendentes    
			n++
		EndIf      
	 	TempZ01C->(DbSkip()) 

   EndDo      
       
   //Totaliza
   	TempZ01X->(DbGoTop())
	While TempZ01X->(!Eof())                
		
		nPPer  := Val(GraficoII("TOTAL",TempZ01X->PERIODO))-Val(GraficoII("ENCERRADO",TempZ01X->PERIODO))-Val(GraficoII("CANCELADO",TempZ01X->PERIODO))
 		cMes   := LEFT(RetMes(TempZ01X->PERIODO),3)+"/"+SUBSTR(TempZ01X->PERIODO,1,4)
	    nPCham += nPPer
	 	TempZ01X->(DbSkip()) 

   EndDo      
   
   
   
      
cHtml +="        	var chart = new google.visualization.BarChart(document.getElementById('chart02'));"
cHtml +="        	chart.draw(data, {width: 560, height:500, title: ' ',legend: {position: 'top', textStyle: {fontSize: 11}},"
cHtml +="                          vAxis: {title: 'Periodo x Quantidade', titleTextStyle: {color: 'black'}}," 
cHtml +="                          hAxis: {title: 'Chamados Pendentes :"+Alltrim(Str(nPCham))+"', titleTextStyle: {color: 'RED'}},"  
cHtml +=" 						 colors:['#C0C0C0','green','purple','blue'] "
cHtml +="                         });"
cHtml +="      		}"
cHtml +="   	 </script>"
cHtml +="   	<body>"
cHtml +='     		<div id="chart02"></div>'
cHtml +="  		</body>"
cHtml += '</Td>'

cHtml += '</Tr>'                                                   

//3º Linha----------------------------------------------------------------------------------------------------------------------------
cHtml += '<Tr>'

//Posicao 5 - Grafico V - Chamados por ocorrencias    
cHtml += " 	<Td  width='500', height='500' >"    
cHtml += '		<font size="2" face="Verdana" > '
cHtml += '<Br>'
cHtml += '<Br>'
cHtml += '			<center><b>Chamados solucionados ('+Alltrim(GraficoV("TOT"))+') por classificação ('+Alltrim(GraficoV("TIP"))+')</b></Center>'
cHtml += '		</font>'       
cHtml += '    	<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
cHtml += '    	<script type="text/javascript">  '
cHtml += '      	google.load("visualization", "1", {packages:["corechart"]});  '
cHtml += '      	google.setOnLoadCallback(drawChart);'
cHtml += '      	function drawChart() { '
cHtml += '        	var data = new google.visualization.DataTable(); '
cHtml += "        	data.addColumn('string', 'Task');"
cHtml += "        	data.addColumn('number', 'Hours per Day');"
cHtml += "        	data.addRows("+Alltrim(GraficoV("TIP"))+");"  // Retorna o tipo de classificação usados no chamados

	n:=0
	TempZ01A->(DbGoTop())

	If TempZ01A->(!BOF() .and. !EOF())

    	While TempZ01A->(!Eof())   
    		cHtml += "        data.setValue("+Alltrim(str(n))+", 0, '"+Alltrim(RetOcr(Alltrim(UPPER(TempZ01A->Z01_CLASSI))))+"');"  
			cHtml += '        data.setValue('+Alltrim(str(n))+', 1,'+Alltrim(GraficoV("QTO",TempZ01A->Z01_CLASSI))+');'// Retorna a quantidade de chamados por classificação   	       	    	
	    	n++ 
	    	TempZ01A->(DbSkip())  
    	EndDo         

    EndIf     

cHtml += "       	var chart = new google.visualization.PieChart(document.getElementById('chart06'));"
cHtml += "        	chart.draw(data, {width: 560, height: 500, title: ' ', is3D: true}); "
cHtml += '   		   }'
cHtml += '    	</script>'
cHtml += '  	<body>'
cHtml += '    		<div id="chart06"></div>'
cHtml += '  	</body>'   
cHtml += '</Td>'                                                   
             
//Posicao 6 - Grafico VI - Chamados por empresas  TOP 15  
cHtml += " 	<Td  width='500', height='500' >"    
cHtml += '		<font size="2" face="Verdana" > '
cHtml += '<Br>'
cHtml += '<Br>'
cHtml += '			<center><b>Chamados aberto por empresa </b></Center>'
cHtml += '		</font>'  
cHtml += '<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
cHtml += '<script type="text/javascript">'
cHtml += "google.load('visualization', '1', {packages: ['corechart']});"
cHtml += '     </script>'
cHtml += '     <script type="text/javascript">'
cHtml += '       function drawVisualization() { '
cHtml +=          'var data = google.visualization.arrayToDataTable([ '
    GraficoVI()       
    cCab+="['Month'"
	cItens+="[''"
	TempZ01J->(DbGoTop())
	If TempZ01J->(!BOF() .and. !EOF())
    	While TempZ01J->(!Eof())   
			If !Empty(TempZ01J->Z01_CODEMP)   
				Z04->(DbSetOrder(1))
				If Z04->(DbSeek(xFilial("Z04")+Alltrim(TempZ01J->Z01_CODEMP)))
					//If Alltrim(Z04->Z04_ATIVO)="S"
					If Alltrim(Z04->Z04_MSBLQL)<>"1"
						cCab+=",'"+Alltrim(Z04->Z04_NOME)+"'"
            	   		cItens+=","+Alltrim(Str(TempZ01J->QTD))     
            		EndIf	
            	EndIf
            EndIf
			TempZ01J->(DbSkip())  
    	EndDo         
    EndIf 
    cCab+="]"
	cItens+="]"    
cHtml +=cCab
cHtml +=","+cItens 
cHtml += '         ]); '   
cHtml += '         var options = {'
cHtml += "           width: 560, height: 500,title : '', "
cHtml += '           vAxis: {title: "Chamados"},'
cHtml += '           hAxis: {title: "Empresas"},'
cHtml += '           seriesType: "bars",'
cHtml += '           series: {15: {type: "line"}},'
cHtml += "           legend: {position: 'top', textStyle: {fontSize: 10}}"
cHtml += '         };'
cHtml += "         var chart = new google.visualization.ComboChart(document.getElementById('chart_div08'));"
cHtml += "         chart.draw(data, options);"
cHtml += "       }"
cHtml += "       google.setOnLoadCallback(drawVisualization);"
cHtml += '     </script>'
cHtml += '   </head>'
cHtml += '   <body style="font-family: Arial;border: 0 none;">'
cHtml += '     <div id="chart_div08" style="width: 500px; height: 500px;"></div>'
cHtml += '   </body>'
cHtml += '</Td>'

//4º Linha----------------------------------------------------------------------------------------------------------------------------
cHtml += '<Tr>'

//Posicao 7 - Grafico VII - Comparativo mensal de chamados    
cHtml += " 	<Td  width='500', height='500' >"    
cHtml += '		<font size="2" face="Verdana" > '
cHtml += '<Br>'
cHtml += '<Br>'
cHtml += '		<center><b>Comparativo mensal de chamados abertos</b></Center>'
cHtml += '		</font>'       
cHtml += '    	<script type="text/javascript" src="https://www.google.com/jsapi"></script>'       
cHtml += '     	<script type="text/javascript">'
cHtml += "      	google.load('visualization', '1', {packages: ['corechart']});"
cHtml += '     	</script>'
cHtml += '    	<script type="text/javascript">  '
cHtml += '      function drawVisualization() {'
cHtml += '         var data = google.visualization.arrayToDataTable(['
cHtml += "         ['Anos'" 
	
	GrVII("ANOS")

    Temp8a->(DbGoTop())
	If Temp8a->(!BOF() .and. !EOF())
    	While Temp8a->(!Eof())     	       	    	
			cHtml += ",'"+Alltrim(Temp8a->ANOS)+"'"
	    	aadd(aAux,Temp8a->ANOS)
	    	Temp8a->(DbSkip())	 
    	EndDo         
    EndIf 
    cHtml +="],"    
		
	i:=len(aAux)
		For n:=1 to 12 
			cAux  := STRZERO(n,2)
	 		cHtml += "['"+substr(RetMes(alltrim("XXXX"+cAux)),1,3)+"',"
	 		For j:=1 to Len(aAux)
	 	   		cHtml += GrVII("QTD",aAux[j]+cAux)+","
	 		Next j
	        cHtml += "]"
	        If n<>12                                  
	   			cHtml+=","
			EndIf        
		Next
	cHtml += "           ]); "		

cHtml += "         var options = {"
cHtml += "           width: 560, height: 500,title : '', "
cHtml += "           title : ' Ano x Mês x Quantidade', "
cHtml += '           vAxis: {title: "Quantidade"},'
cHtml += '           hAxis: {title: "Mês"},'
cHtml += '           seriesType: "bars",'
cHtml += '           series: {5: {type: "line"}},'
//cHtml += "  		colors:['#C0C0C0','green','purple','blue','Red']" 
cHtml += "         };"

cHtml += "         var chart = new google.visualization.ComboChart(document.getElementById('chart07'));"
cHtml += "         chart.draw(data, options);"
cHtml += "       }"
cHtml += "       google.setOnLoadCallback(drawVisualization);"
cHtml += '    	</script>'
cHtml += '  	<body>'
cHtml += '    		<div id="chart07"></div>'
cHtml += '  	</body>'   
cHtml += '</Td>'                                                   
             

//Posicao 8 - Grafico VIII - Comparativo mensal de chamados x classificação    
cHtml += " 	<Td  width='500', height='500' >"    
cHtml += '		<font size="2" face="Verdana" > '
cHtml += '<Br>'
cHtml += '<Br>'
cHtml += '		<center><b>Comparativos mensal por problema</b></Center>'
cHtml += '		</font>'       
cHtml += '    	<script type="text/javascript" src="https://www.google.com/jsapi"></script>'       
cHtml += '     	<script type="text/javascript">'
cHtml += "      	google.load('visualization', '1', {packages: ['corechart']});"
cHtml += '     	</script>'
cHtml += '    	<script type="text/javascript">  '
cHtml += '      function drawVisualization() {'
cHtml += '         var data = google.visualization.arrayToDataTable(['
cHtml += "			['Month', 'Parametrização', 'Erro Sistêmico', 'Cr. Usuário', 'Erro Oper.','Dúvida','Personalização','Pacote','Cr. Empresa','Migração','Média mensal'],"
                              //05               //01             //06           //08         //04      //07            //02     //03          //09       //

	For i=1 to 6 
	
			
      	dDate:= MonthSub(Date(),6-i)	
	      
		GrVIII(AnoMes(dDate)) 
		
		nTotal:=n1:=n2:=n3:=n4:=n5:=n6:=n7:=n8:=n9:=0 

		TempZ01A->(DbGoTop())
		While TempZ01A->(!EOF())
			If Empty(TempZ01A->Z01_CLASSI)
				If TempZ01A->Z01_OCORRE == "01"
					n1+=TempZ01A->QTDCLAS
				ElseIf  TempZ01A->Z01_OCORRE == "02" 
			   		n2+=TempZ01A->QTDCLAS	
				ElseIf  TempZ01A->Z01_OCORRE == "03" 
			   		n3+=TempZ01A->QTDCLAS			   
				ElseIf  TempZ01A->Z01_OCORRE == "04" 
			   		n4+=TempZ01A->QTDCLAS				
				ElseIf  TempZ01A->Z01_OCORRE == "05" 
			   		n5+=TempZ01A->QTDCLAS				
				ElseIf  TempZ01A->Z01_OCORRE == "06" 
			   		n6+=TempZ01A->QTDCLAS	
			 	ElseIf  TempZ01A->Z01_OCORRE == "07" 
			   		n7+=TempZ01A->QTDCLAS	
				ElseIf  TempZ01A->Z01_OCORRE == "08" 
			   		n8+=TempZ01A->QTDCLAS
				ElseIf  TempZ01A->Z01_OCORRE == "09" 
			   		n9+=TempZ01A->QTDCLAS				   						   		
				EndIf
			Else
				If TempZ01A->Z01_CLASSI == "01"
					n1+=TempZ01A->QTDCLAS
				ElseIf  TempZ01A->Z01_CLASSI == "02" 
			   		n2+=TempZ01A->QTDCLAS	
				ElseIf  TempZ01A->Z01_CLASSI == "03" 
			   		n3+=TempZ01A->QTDCLAS			   
				ElseIf  TempZ01A->Z01_CLASSI == "04" 
			   		n4+=TempZ01A->QTDCLAS				
				ElseIf  TempZ01A->Z01_CLASSI == "05" 
			   		n5+=TempZ01A->QTDCLAS				
				ElseIf  TempZ01A->Z01_CLASSI == "06" 
			   		n6+=TempZ01A->QTDCLAS
			 	ElseIf  TempZ01A->Z01_CLASSI == "07" 
			   		n7+=TempZ01A->QTDCLAS	
				ElseIf  TempZ01A->Z01_CLASSI == "08" 
			   		n8+=TempZ01A->QTDCLAS 
				ElseIf  TempZ01A->Z01_CLASSI == "09" 
			   		n9+=TempZ01A->QTDCLAS				   						   		
				EndIf				
			
			EndIf   
			
			TempZ01A->(DbSkip())		   
		
		EndDo	
		 //			['Month', 'Parametrização', 'Erro Sistêmico', 'Cr. Usuário', 'Erro Oper.','Dúvida','Personalização','Pacote','Cr. Empresa','Migração'],"
                              //05               //01             //06           //08         //04      //07            //02     //03          //09
		 
		nTotal:=Round((n1+n2+n3+n4+n5+n6+n7+n8+n9)/9,0)

		cHtml += "           ['"+RetMes(AnoMes(dDate))+"',"+alltrim(Str(n5))+","+alltrim(Str(n1))+","+alltrim(Str(n6))+","+alltrim(Str(n8))+","+alltrim(Str(n4))+","+alltrim(Str(n7))+","+alltrim(Str(n2))+","+alltrim(Str(n3))+","+alltrim(Str(n9))+","+alltrim(Str(nTotal))+"]"
		//cHtml += "           ['2005/06',  135,      1120,        599,             1268,          288,      682],"
		
		
		If i <> 6  
			cHtml+=","
		EndIf
		//cHtml += "           ['2008/09',  136,      691,         629,             1026,          366,      569.6] "

  
  	Next		

		                                         
cHtml += "           ]); "		

    
cHtml += "         var options = {"
cHtml += "           width: 560, height: 500, "
cHtml += "           title : 'Chamados x Mês x Classificação', "
cHtml += '           vAxis: {title: "Quantidade"},'
cHtml += '           hAxis: {title: "Mês"},'
cHtml += '           seriesType: "bars",'
cHtml += '           series: {9: {type: "line"}},'
cHtml += "   		colors:['blue','red','orange','green','purple','#00BFFF','#F781F3','#00FF00','#B40404','black']" 
cHtml += "         };"

cHtml += "         var chart = new google.visualization.ComboChart(document.getElementById('chart08'));"
cHtml += "         chart.draw(data, options);"
cHtml += "       }"
cHtml += "       google.setOnLoadCallback(drawVisualization);"
cHtml += '    	</script>'
cHtml += '  	<body>'
cHtml += '    		<div id="chart08"></div>'
cHtml += '  	</body>'   
cHtml += '</Td>'     
cHtml += '</Tr>'
cHtml += '</table>'
cHtml += '<meta http-equiv="refresh" content="300;">'
cHtml += '</html>'




cHtml += '</Tr>'
cHtml += '</table>'
cHtml += '<meta http-equiv="refresh" content="300;">'
cHtml += '</html>'
  

WEB EXTENDED END     

HttpLeaveSession()

RpcClearEnv()   

Return cHtml     

/*
Funcao      : GraficoI
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico I
Autor       : Tiago Luiz Mendonça
Data/Hora   : 01/09/11 10:00
*/
  
*------------------------------------*               
 Static Function GraficoI(cTipo,cMod)
*------------------------------------*
  
Local cRet:="" 
Local n   :=1                        

Default cTipo:=""
Default cMod :="" 

//Mod - Busca a quantidade de módulos vinculados a chamados
If Alltrim(cTipo) == "MOD"
    

    If Select("TempZ01A") > 0
		TempZ01A->(DbCloseArea())	               
	EndIf
    
    BeginSql Alias 'TempZ01A' 
        
        //Chamados agrupados por módulos não cancelados
    	SELECT Z01_MODULO,COUNT(Z01_MODULO) as QTD 
     	FROM %Table:Z01%
      	WHERE %notDel%
        AND Z01_FILIAL = %exp:xFilial("Z01")%
        AND Z01_STATUS <> 3
    	Group by Z01_MODULO
    	Order by QTD desc     
    
    EndSql   
    
    TempZ01A->(DbGoTop())
	If TempZ01A->(!BOF() .and. !EOF())
    	While TempZ01A->(!Eof())     	       	    	
	    	n++
	    	TempZ01A->(DbSkip())	 
    	EndDo         
    EndIf     

	cRet:=Alltrim(Str(n)) 

//TIP - Busca a quantidade de erros vinculados a chamados
ElseIf Alltrim(cTipo) == "TIP"
    
    If Select("TempZ01A") > 0
		TempZ01A->(DbCloseArea())	               
	EndIf
    
    BeginSql Alias 'TempZ01A' 
        
        //Chamados agrupados por módulos não cancelados
    	SELECT Z01_OCORRE,COUNT(Z01_OCORRE) as QTD 
     	FROM %Table:Z01%
      	WHERE %notDel%
        AND Z01_FILIAL = %exp:xFilial("Z01")%
        AND Z01_STATUS <> 3
    	Group by Z01_OCORRE
    	Order by QTD desc     
    
    EndSql   
    
    TempZ01A->(DbGoTop())
	If TempZ01A->(!BOF() .and. !EOF())
    	While TempZ01A->(!Eof())     	       	    	
	    	n++
	    	TempZ01A->(DbSkip())	 
    	EndDo         
    EndIf     

	cRet:=Alltrim(Str(n)) 
                         
                           
//Quantidades de chamados abertos por módulo, filtrado pela cMod
ElseIf 	Alltrim(cTipo) == "QTD"    
    
    If Select("TempZ01B") > 0
		TempZ01B->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT Count(*) QTD "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_STATUS <> 3 AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_MODULO = '"+Alltrim(cMod)+"'

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01B",.T.,.T.) 

   	cRet:= Alltrim(Str(TempZ01B->QTD))  
   	
   	TempZ01B->(DbCloseArea())	


//Quantidades de chamados abertos por módulo, filtrado pela cMod
ElseIf 	Alltrim(cTipo) == "QTO"    
    
    If Select("TempZ01B") > 0
		TempZ01B->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT Count(*) QTD "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_STATUS <> 3 AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_OCORRE = '"+Alltrim(cMod)+"'

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01B",.T.,.T.) 

   	cRet:= Alltrim(Str(TempZ01B->QTD))  
   	
   	TempZ01B->(DbCloseArea())	


//Quantidades de chamados abertos - TOTAL   
ElseIf 	Alltrim(cTipo) == "TOT"    

    If Select("TempZ01D") > 0
		TempZ01D->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT Count(*) TOT "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01D",.T.,.T.) 

   	cRet:= Alltrim(Str(TempZ01D->TOT))  
   	
   	TempZ01D->(DbCloseArea())	
   
EndIf  

Return cRet  

 
/*
Funcao      : GraficoI
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico II
Autor       : Tiago Luiz Mendonça
Data/Hora   : 01/09/11 13:30
*/
   
*-------------------------------------*               
 Static Function GraficoII(cTipo,cMod)
*-------------------------------------*
  
Local cRet:="" 
Local n   :=0                       

Default cTipo:=""
Default cMod :="" 


//Quantidades de Anos x Meses em lançamentos de chamados
If Alltrim(cTipo) == "ANOSXMES"

    If Select("TempZ01C") > 0
		TempZ01C->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT LEFT(Z01_DTABER,6) as PERIODO "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	//cQuery+=" AND Z01_DTABER >= '"+DTOS(DATE()-365)+"' "
	cQuery+=" AND Z01_DTABER >= '"+	DTOS(YearSub( Date() , 1 ))+"' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"'  group by LEFT(Z01_DTABER,6) ORDER BY LEFT(Z01_DTABER,6) "

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01C",.T.,.T.) 

    TempZ01C->(DbGoTop())
	If TempZ01C->(!BOF() .and. !EOF())
    	While TempZ01C->(!Eof())     	       	    	
	    	n++
	    	TempZ01C->(DbSkip())	 
    	EndDo         
    EndIf     
	//n--//Retira o mês anterior ao do limite.
	cRet:=Alltrim(Str(n))  
	
	If Select("TempZ01X") > 0
		TempZ01X->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT LEFT(Z01_DTABER,6) as PERIODO "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
  //	cQuery+=" AND Z01_DTABER >= '"+DTOS(DATE())+"' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"'  group by LEFT(Z01_DTABER,6) ORDER BY LEFT(Z01_DTABER,6) "

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01X",.T.,.T.) 

	
	
//Quantidade de Chamados lançados por mês, filtrado pela variavel cMod	
ElseIf Alltrim(cTipo) == "TOTAL"    

    If Select("TempZ01E") > 0
		TempZ01E->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT COUNT(*) AS QTD  "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' AND  LEFT(Z01_DTABER,6)='"+cMod+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01E",.T.,.T.) 

	cRet:=Alltrim(Str(TempZ01E->QTD))    	
	      

//Quantidades de Chamados encerrados no periodo, filtrado pela variavel cMod		
ElseIf Alltrim(cTipo) == "ENCERRADO"    

    If Select("TempZ01F") > 0
		TempZ01F->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT COUNT(Z01_STATUS) AS QTD  "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' and Z01_STATUS='2' AND  LEFT(Z01_DTABER,6)='"+cMod+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01F",.T.,.T.) 

	cRet:=Alltrim(Str(TempZ01F->QTD))          
	
//Quantidades de Chamados cancelados no periodo, filtrado pela variavel cMod		
ElseIf Alltrim(cTipo) == "CANCELADO"    

    If Select("TempZ01H") > 0
		TempZ01H->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT COUNT(Z01_STATUS) AS QTD  "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' and Z01_STATUS='3' AND  LEFT(Z01_DTABER,6)='"+cMod+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01H",.T.,.T.) 

	cRet:=Alltrim(Str(TempZ01H->QTD))   	
	
EndIf	
	       
Return cRet
    

/*
Funcao      : GraficoIII
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico III
Autor       : Tiago Luiz Mendonça
Data/Hora   : 01/09/11 13:30
*/
   
*-------------------------------------*               
 Static Function GraficoIII(cTipo,cMod)
*-------------------------------------*
  
Local cRet   :="" 
Local nDias  :=0                       
Local n      :=0

Default cTipo:=""
Default cMod :="" 


//Quantidades de periodos 
If Alltrim(cTipo) == "DADOS"

    If Select("TempZ01H") > 0
		TempZ01H->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT Z01_DT_ENC "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	//cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' and Z01_DT_ENC <> '' and Z01_DT_ENC like '"+Alltrim(Substr(dtos(dDataBase),1,6))+"%'" 
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' and Z01_DT_ENC <> '' and Z01_DT_ENC > '"+Alltrim(dtos(dDataBase-30))+"%'" 
	cQuery+=" Group By Z01_DT_ENC"    

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01H",.T.,.T.)   
		
    TempZ01H->(DbGoTop())
	If TempZ01H->(!BOF() .and. !EOF())
    	While TempZ01H->(!Eof())     	       	    	
	    	n++
	    	TempZ01H->(DbSkip())	 
    	EndDo         
    EndIf     
            

	cRet:=n
                          
// Quantidade de chamados fechado no dia   
ElseIf Alltrim(cTipo) == "QTDE"

    If Select("TempZ01I") > 0
		TempZ01I->(DbCloseArea())	               
	EndIf
    
    //Seleciona todos chamados encerrados por dia
    cQuery:=" SELECT  Z01_CODIGO"
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_STATUS <> '3' AND  Z01_DT_ENC ='"+cMod+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01I",.T.,.T.) 
	
	// Conta a quantidade de chamados encerrados no dia
	TempZ01I->(DbGoTop())
	If TempZ01I->(!BOF() .and. !EOF())
   
    	While TempZ01I->(!Eof())     	       	    	
	    	
	    	Z01->(DbSetorder(1))    
	        If Z01->(DbSeek(xFilial("Z01")+TempZ01I->Z01_CODIGO)) 
	        	If  "Solução:" $ Z01->Z01_PARECE
	        		n++ 
	        	
	        	EndIf
	        EndIf
	        
	    	TempZ01I->(DbSkip())	 
    	EndDo         
    EndIf  
       
    cRet:= Alltrim(Str(n))	   	

// Quantidade de chamados fechado no dia   
ElseIf Alltrim(cTipo) == "QTDA"

    If Select("TempZ01I") > 0
		TempZ01I->(DbCloseArea())	               
	EndIf
    
    //Seleciona todos chamados encerrados por dia
    cQuery:=" SELECT  Z01_CODIGO"
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_STATUS <> '3' AND  Z01_DTABER ='"+cMod+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01I",.T.,.T.) 
	                      
	n:=0
	
	// Conta a quantidade de chamados encerrados no dia
	TempZ01I->(DbGoTop())
	If TempZ01I->(!BOF() .and. !EOF())
   
    	While TempZ01I->(!Eof())     	       	    	
	   
	    	n++ 
	     	TempZ01I->(DbSkip())	     
	     	
    	EndDo         
    EndIf  
       
    cRet:= Alltrim(Str(n))	   	

EndIf



Return cRet	


/*
Funcao      : GraficoIV
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico IV
Autor       : Tiago Luiz Mendonça
Data/Hora   : 06/10/11 13:30
*/
   
*-------------------------------------*               
 Static Function GraficoIV(cTipo,cMod)
*-------------------------------------*
  
Local cRet   :="" 
Local nDias  :=0                       
Local n      :=0
Local i      :=0


Default cTipo:=""
Default cMod :="" 


//Quantidades de analistas 
If Alltrim(cTipo) == "Analistas"

    If Select("TempZ02A") > 0
		TempZ02A->(DbCloseArea())	               
	EndIf
                                   
 	cQuery:=" SELECT Z02_CODUSR"
	cQuery+=" FROM "+RetSqlName("Z02")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' And " 
	cQuery+=" Z02_DATA = '"+dtos(dDataBase)+"'" 
	cQuery+=" And Z02_TIPO ='S' and Z02_CODUSR<>'000000' "        	
	cQuery+=" AND Z02_FILIAL = '"+xFilial("Z02")+"'  group by Z02_CODUSR"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ02A",.T.,.T.)   
		
    TempZ02A->(DbGoTop())
	If TempZ02A->(!BOF() .and. !EOF())
    	While TempZ02A->(!Eof())     	       	    	
	    		n++     
	    		TempZ02A->(DbSkip())
	  	EndDo         
    EndIf     
    
	cRet:=Alltrim(Str(n))   
	
	If Select("TempZ02B") > 0
		TempZ02B->(DbCloseArea())	               
	EndIf
	
	cQuery:=" SELECT  Z02_CODUSR,Z02_CODIGO"
	cQuery+=" FROM "+RetSqlName("Z02")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' And " 
	cQuery+=" Z02_DATA = '"+dtos(dDataBase)+"'" 
	cQuery+=" And Z02_TIPO ='S' and Z02_CODUSR<>'000000' "        	
	cQuery+=" AND Z02_FILIAL = '"+xFilial("Z02")+"' Group by Z02_CODUSR,Z02_CODIGO Order by Z02_CODUSR"
                                                     
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ02B",.T.,.T.)   
		                           
EndIf  

//Quantidade de chamados por analista
If Alltrim(cTipo)=="QTD"
   
    If Select("TempZ02B") > 0
		TempZ02B->(DbCloseArea())	               
	EndIf
                                   
 	cQuery:=" SELECT Z02_CODUSR,Z02_CODIGO"
	cQuery+=" FROM "+RetSqlName("Z02")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' And " 
	cQuery+=" Z02_DATA = '"+dtos(dDataBase)+"'" 
	cQuery+=" And Z02_TIPO ='S' "        	
	cQuery+=" And Z02_FILIAL = '"+xFilial("Z02")+"' AND Z02_CODUSR='"+alltrim(cMod)+"'"
	cQuery+=" Group by Z02_CODUSR,Z02_CODIGO" 
	
	
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ02B",.T.,.T.)   
		    
	Z01->(DbSetOrder(1))
    TempZ02B->(DbGoTop())
	If TempZ02B->(!BOF() .and. !EOF())
    	While TempZ02B->(!Eof())     	       	    	
	    	If Z01->(DbSeek(xFilial("Z01")+TempZ02B->Z02_CODIGO))
	    		If !Empty(Z01->Z01_DT_ENC) 
	    			n++
	    		EndIf
	    	EndIf		
	    	TempZ02B->(DbSkip())	 
    	EndDo         
    EndIf     
    
	cRet:=Alltrim(Str(n))

EndIf
                     
//Quantidade total de chamado encerrados no dia.
If Alltrim(cTipo)=="TOTAL"
   
    If Select("TempZ01C") > 0
		TempZ01C->(DbCloseArea())	               
	EndIf
                                   
 	cQuery:=" SELECT Z01_CODIGO"
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' And " 
	cQuery+=" Z01_DT_ENC = '"+dtos(dDataBase)+"'"         	
	cQuery+=" And Z01_STATUS='2' And Z01_FILIAL = '"+xFilial("Z01")+"' 
	cQuery+=" Group by Z01_CODIGO" 	
	
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01C",.T.,.T.)   
		
    TempZ01C->(DbGoTop())
	If TempZ01C->(!BOF() .and. !EOF())
    	While TempZ01C->(!Eof())  
    	
    		If Select("TempZ01D") > 0
				TempZ01D->(DbCloseArea())	               
			EndIf

    		BeginSql Alias 'TempZ01D' 
        
           		//Chamados agrupados por módulos não cancelados
       	   		SELECT MAX(Z02_ITEM) As Max ,Z02_CODUSR 
     	   		FROM %Table:Z02%
      	   			WHERE %notDel%
        	   		AND Z02_FILIAL = %exp:xFilial("Z02")%
        			AND Z02_CODIGO  =%exp:TempZ01C->Z01_CODIGO%
        			AND Z02_CODUSR  = '000000' 
    		   		Group by Z02_CODUSR    
    
   			 EndSql   
    	
    		TempZ01D->(DbGoTop())
         	If !(TempZ01D->(!BOF() .and. !EOF()))  
    	    	n++
    	    EndIf
    	    	
	    	TempZ01C->(DbSkip())	 
    	EndDo         
    EndIf     
    
	cRet:=Alltrim(Str(n))

EndIf

Return cRet	 

/*
Funcao      : GraficoV
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico V
Autor       : Tiago Luiz Mendonça
Data/Hora   : 09/01/12 10:00
*/
  
*------------------------------------*               
 Static Function GraficoV(cTipo,cMod)
*------------------------------------*
  
Local cRet   := "" 
Local n      := 0                        

Default cTipo:=""
Default cMod :="" 

//TIP - Busca a quantidade de erros vinculados a chamados
If Alltrim(cTipo) == "TIP"
    
    If Select("TempZ01A") > 0
		TempZ01A->(DbCloseArea())	               
	EndIf
    
    BeginSql Alias 'TempZ01A' 
        
        //Chamados agrupados por classificação não cancelados
    	SELECT Z01_CLASSI,COUNT(Z01_CLASSI) as QTD 
     	FROM %Table:Z01%
      	WHERE %notDel%
        AND Z01_FILIAL = %exp:xFilial("Z01")%
        AND Z01_STATUS <> 3 
        AND Z01_CLASSI <> ' '
    	Group by Z01_CLASSI
    	Order by QTD desc     
    
    EndSql   
    
    TempZ01A->(DbGoTop())
	If TempZ01A->(!BOF() .and. !EOF())
    	While TempZ01A->(!Eof())     	       	    	
	    	n++
	    	TempZ01A->(DbSkip())	 
    	EndDo         
    EndIf     
                                           
	cRet:=Alltrim(Str(n)) 
                         
                           
//Quantidades de chamados classificados, filtrado pela cMod
ElseIf 	Alltrim(cTipo) == "QTO"    
    
    If Select("TempZ01B") > 0
		TempZ01B->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT Count(*) QTD "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_STATUS <> 3 AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_CLASSI  = '"+Alltrim(cMod)+"'

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01B",.T.,.T.) 

   	cRet:= Alltrim(Str(TempZ01B->QTD))  
   	
   	TempZ01B->(DbCloseArea())	
   	
//Quantidades de chamados abertos - TOTAL   
ElseIf 	Alltrim(cTipo) == "TOT"    

    If Select("TempZ01D") > 0
		TempZ01D->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT Count(*) TOT "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_CLASSI <> ' ' AND Z01_FILIAL = '"+xFilial("Z01")+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TempZ01D",.T.,.T.) 

   	cRet:= Alltrim(Str(TempZ01D->TOT))  
   	
   	TempZ01D->(DbCloseArea())	
   
EndIf  

Return cRet  


/*
Funcao      : GraficoVI
Parametros  : Nenhum
Retorno     : Arquivo temporario
Objetivos   : Busca valores para o Grafico VI
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/12/11 10:00
*/
  
*---------------------------*               
 Static Function GraficoVI()  
*---------------------------*
  
	
	If Select("TempZ01J") > 0
   		TempZ01J->(DbCloseArea())	               
	EndIf    

	BeginSql Alias 'TempZ01J' 
        
        //Chamados agrupados por empresas 
    	SELECT top 15 Z01_CODEMP, Count(Z01_CODEMP) as QTD 
     	FROM %Table:Z01%
      	WHERE %notDel%
        AND Z01_FILIAL = %exp:xFilial("Z01")%
        AND Z01_STATUS <> 3
    	Group by Z01_CODEMP
    	Order by QTD desc     
    
    EndSql   

Return

/*
Funcao      : GrVII
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico VIII
Autor       : Tiago Luiz Mendonça
Data/Hora   : 06/02/13 13:30
*/
   
*----------------------------------*               
 Static Function GrVII(cTipo,cMod)
*----------------------------------*
  
Local cRet := "" 
Local n    := 0                       

Default cTipo:=""
Default cMod :="" 


//Quantidades de anos dos chamados
If Alltrim(cTipo) == "ANOS"

    If Select("Temp8a") > 0
		Temp8a->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT LEFT(Z01_DTABER,4) as ANOS "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"'  group by LEFT(Z01_DTABER,4) ORDER BY LEFT(Z01_DTABER,4) "

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"Temp8a",.T.,.T.) 


EndIf


//Quantidades de anos dos chamados
If Alltrim(cTipo) == "QTD"

    If Select("Temp8b") > 0
		Temp8b->(DbCloseArea())	               
	EndIf
    
    cQuery:=" SELECT COUNT(*) AS TOT "
	cQuery+=" FROM "+RetSqlName("Z01")
	cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
	cQuery+=" AND Z01_FILIAL = '"+xFilial("Z01")+"' and LEFT(Z01_DTABER,6)='"+alltrim(cMod)+"'"

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"Temp8b",.T.,.T.) 
       
	
 	cRet:= Alltrim(Str(Temp8b->TOT)) 
    
EndIf


Return cRet               

/*
Funcao      : GrVIII
Parametros  : cTipo,cMod
Retorno     : Quantidade
Objetivos   : Busca valores para o Grafico VIII
Autor       : Tiago Luiz Mendonça
Data/Hora   : 05/06/13 10:00
*/
  
*------------------------------------*               
 Static Function GrVIII(cMes)
*------------------------------------*
  
Local cMes

	cMes:=alltrim(cMes)+"%"
	    
    If Select("TempZ01A") > 0
		TempZ01A->(DbCloseArea())	               
	EndIf
    
    BeginSql Alias 'TempZ01A' 
        
        //Chamados agrupados por classificação não cancelados
    	SELECT Z01_CLASSI,COUNT(Z01_CLASSI) as QTDCLAS,Z01_OCORRE 
     	FROM %Table:Z01%
      	WHERE %notDel%
        AND Z01_FILIAL = %exp:xFilial("Z01")%   
        AND Z01_DTABER like %exp:cMes%
        AND Z01_STATUS <> 3 
    	Group by Z01_CLASSI,Z01_OCORRE
    	Order by Z01_CLASSI     
    
    EndSql   


Return  



/*
Funcao      : RetMes
Parametros  : cPeriodo
Retorno     : cRet 
Objetivos   : Converte a data em uma strig de texto 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 01/09/11 15:30
*/
   
*-------------------------------------*               
 Static Function RetMes(cPeriodo)
*-------------------------------------*
       
Local cRet:=""  
        
If SubStr(cPeriodo,5,2) == "01" 
	cRet:="Janeiro" 
ElseIf  SubStr(cPeriodo,5,2) == "02" 
	cRet:="Fevereiro" 
ElseIf  SubStr(cPeriodo,5,2) == "03" 
	cRet:="Março" 
ElseIf  SubStr(cPeriodo,5,2) == "04" 
	cRet:="Abril" 
ElseIf  SubStr(cPeriodo,5,2) == "05" 
	cRet:="Maio"                  
ElseIf  SubStr(cPeriodo,5,2) == "06" 
	cRet:="Junho" 
ElseIf  SubStr(cPeriodo,5,2) == "07" 
	cRet:="Julho" 
ElseIf  SubStr(cPeriodo,5,2) == "08" 
	cRet:="Agosto" 
ElseIf  SubStr(cPeriodo,5,2) == "09" 
	cRet:="Setembro" 
ElseIf  SubStr(cPeriodo,5,2) == "10" 
	cRet:="Outubro" 
ElseIf  SubStr(cPeriodo,5,2) == "11" 
	cRet:="Novembro" 
ElseIf  SubStr(cPeriodo,5,2) == "12" 
	cRet:="Dezembro" 										
EndIf  
  
  
Return cRet       


/*
Funcao      : RetOcr
Parametros  : cTipo
Retorno     : cRet 
Objetivos   : Converte o código pela descrição
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/12/11 15:30
*/
   
*------------------------------*               
 Static Function RetOcr(cTipo)
*------------------------------*
       
Local cRet  
        
If Alltrim(cTipo) == "01" 
	cRet:="Erro Sistêmico" 
ElseIf  Alltrim(cTipo) == "02" 
	cRet:="Pacote" 
ElseIf  Alltrim(cTipo) == "03" 
	cRet:="Cr. Empresa" 
ElseIf  Alltrim(cTipo) == "04"  
	cRet:="Dúvida" 
ElseIf  Alltrim(cTipo) == "05"  
	cRet:="Parametrização"                  
ElseIf  Alltrim(cTipo) == "06" 
	cRet:="Cr. Usuário" 
ElseIf  Alltrim(cTipo) == "07" 
	cRet:="Personalização" 	
ElseIf Alltrim(cTipo) == "08"
	cRet:="Erro Operacional" 
ElseIf Alltrim(cTipo) == "09"
	cRet:="Migração"											
EndIf  
  
  
Return cRet       


