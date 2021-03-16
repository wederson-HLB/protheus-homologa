#INCLUDE "rwmake.ch"
#include 'topconn.ch'    
#include 'colors.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDR003  ºAutor  Tiago Luiz Mendonça  º Data ³  11/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de empresas x Ambientes                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDR003()
Objetivos   : Relatório de usuários
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/
*-------------------------*
  User Function GTHDR003()
*--------------------------*    

  
  Local cPerg:="HDREL003"  
                    
  Private oPrint
  Private lRet	  := .T.
  Private nPagina := 1
  
  Private cEIniCod   := "" 
  Private cEFimCod   := ""
  Private cEIniFil   := "" 
  Private cEFimFil   := ""  
  Private cAmbiente  := ""
  Private cCnab      := ""


  Private oFont1   := TFont():New('Courier new',,-10,.T.)   
  Private oFont2   := TFont():New('Tahoma',,18,.T.)  
  Private oFont3   := TFont():New('Tahoma',,12,.T.) 
  Private oFont4   := TFont():New('Arial',,11,,.T.,,,,,.f. )   
  Private oFont5   := TFont():New('Arial',,9,,.T.,,,,,.f. )    
  Private oFont6   := TFont():New('Arial',,8,,.T.,,,,,.f. )   
  Private oFont7   := TFont():New('Arial',,6,,.T.,,,,,.f. ) 
   

  IF !(Pergunte(cPerg,.T.))
  		Return .F.
  EndIf         
   

   cEIniCod := mv_par01 
   cEFimCod := mv_par03 
   
   cEIniFil := mv_par02 
   cEFimFil := mv_par04 

   cAmbiente:= mv_par05
   
   //AOA - 29/08/2016 - Tratamento para listar arquivos de configuração CNAB
   cCnab	:= mv_par06 

  
                               	
   // Monta objeto para impressão
   oPrint := TMSPrinter():New("Impressão de relatório de usuários")
 
   // Define orientação da página para Retrato
   // pode ser usado oPrint:SetLandscape para Paisagem
   oPrint:SetPortrait()
    
   // Mostra janela de configuração de impressão
   oPrint:Setup()

   // Inicia página
   oPrint:StartPage()  
    
    //Papel A4
   oPrint:SetpaperSize(9)                                                
                
 
   Processa( {|| MontaRel() }, "Aguarde...", "Processando os dados...",.F.) 
    
   
   If !(lRet)
      Return .F.     
   EndIf
   
   oPrint:EndPage()
                        
   // Mostra tela de visualização de impressão
   oPrint:Preview() 
   
   //Finaliza Objeto 
   oPrint:End() 
	


Return 

/*
Funcao      : MontaRel()
Objetivos   : Monta a estrutura do relatorio
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/    

*----------------------------*
  Static Function MontaRel() 
*----------------------------*

   
   If Empty(cEFimCod)  
      MsgStop("O campo de código de empresa 'ate' deve ser preenchido para impressão","Grant Thornton")   
      lRet:=.F.
      Return .F.
   EndIf 
   
   MontaTemp()
   
   MontaCab()
                   
   MontaDet()


Return

/*
Funcao      : MontaCab()
Objetivos   : Monta o cabecario do relatorio
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/    
      
*----------------------------*
  Static Function MontaCab()
*----------------------------*

Local oBrush := TBrush():New( , RGB(94,56,129))


   oPrint:FillRect({401, 23, 442, 2350}, oBrush)
   oPrint:FillRect({3202, 22, 3319, 2350}, oBrush)  
   
   oPrint:SayBitmap(20,20,"\system\logo.bmp",900,146)
      
   oPrint:Say(100,2050,"Pagina  "+Alltrim(Str(nPagina)),oFont1)    

  
   oPrint:Say(150,1150,"Relatorio de empresas",oFont2)
   oPrint:Say(215,1150,"Emissão : "+Dtoc(date()),oFont4) 
   
   oPrint:Say(405,35,"COD",oFont5,,CLR_WHITE)
   oPrint:Say(405,150,"FIL",oFont5,,CLR_WHITE)
   oPrint:Say(405,260,"FILIAL",oFont5,,CLR_WHITE)
   oPrint:Say(405,700,"NOME",oFont5,,CLR_WHITE)
   oPrint:Say(405,1100,"NOME COMPLETO",oFont5,,CLR_WHITE)
   oPrint:Say(405,2120,"AMBIENTE",oFont5,,CLR_WHITE)
      
   oPrint:Say(2810,45,"Observações Gerais ",oFont4)
   
   oPrint:Say(3230,900,"WWW.GRANTTHORNTON.COM.BR",oFont2,,CLR_WHITE) 
     		
   oPrint:Box(400,20,3320,2350)
   
   //Linhas do Cabecario

   oPrint:Line(400,20,400,2350)  //Linha
   oPrint:Line(440,20,440,2350)  //Linha

  
   oPrint:Line(2800,20,2800,2350)  //Linha    
   oPrint:Line(3150,20,3150,2350)  //Linha
   oPrint:Line(3200,20,3200,2350)  //Linha 
   //oPrint:Line(3150,1760,3200,1760)  //Coluna

   oPrint:Line(400,120,2800,120)    //Coluna 1 
   oPrint:Line(400,240,2800,240)    //Coluna 2
   oPrint:Line(400,690,2800,690)    //Coluna 3
   oPrint:Line(400,1090,2800,1090)    //Coluna 4
   oPrint:Line(400,2100,2800,2100)    //Coluna 5

Return   


/*
Funcao      : MontaTemp()
Objetivos   : Monta temporario com os dados que serão impressos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 11/04/2013
*/    

*----------------------------*
  Static Function MontaTemp() 
*----------------------------*

                                                                         
	If Select("QRYZ04") > 0

	QRYZ04->(DbCloseArea())	               

   	EndIf
   	     
   	If cCnab=1	   	
	   	If Empty(Alltrim(cAmbiente))     
		   	                
		    BeginSql Alias 'QRYZ04'
		
				SELECT *  
				FROM
				%Table:Z04%
				WHERE 
					Z04_FILIAL = %exp:xFilial("Z04")%  AND 
					%notDel% AND
					Z04_AMB NOT IN ('PORTAL','AP7','AP7_2','AP7_3') AND 
					Z04_CODIGO >=  %exp:cEIniCod% AND Z04_CODFIL >= %exp:cEIniFil% AND 
					Z04_CODIGO <=  %exp:cEFimCod% AND Z04_CODFIL <= %exp:cEFimFil% AND 
					(Z04_NCNABR<>  %exp:''% OR Z04_NCNABP <>  %exp:''% OR Z04_NCNABF <>  %exp:''%)//AOA - 29/08/2016 - Tratamento para listar arquivos de configuração CNAB
				ORDER 
					BY Z04_CODIGO,Z04_AMB		
			EndSql  
	  
		Else    
		
		    BeginSql Alias 'QRYZ04'
		
				SELECT *  
				FROM
				%Table:Z04%
				WHERE 
					Z04_FILIAL = %exp:xFilial("Z04")%  AND 
					%notDel% AND 
					Z04_AMB =  %exp:cAmbiente% AND
					Z04_AMB NOT IN ('PORTAL','AP7','AP7_2','AP7_3') AND 
					(Z04_NCNABR<>  %exp:''% OR Z04_NCNABP <>  %exp:''% OR Z04_NCNABF <>  %exp:''%) //AOA - 29/08/2016 - Tratamento para listar arquivos de configuração CNAB
				ORDER 
					BY Z04_CODIGO,Z04_AMB			
			EndSql  	
		
		EndIf		
				                                   
    Else
    	   	
	   	If Empty(Alltrim(cAmbiente))     
		   	                
		    BeginSql Alias 'QRYZ04'
		
				SELECT *  
				FROM
				%Table:Z04%
				WHERE 
					Z04_FILIAL = %exp:xFilial("Z04")%  AND 
					%notDel% AND
					Z04_AMB NOT IN ('PORTAL','AP7','AP7_2','AP7_3') AND 
					Z04_CODIGO >=  %exp:cEIniCod% AND Z04_CODFIL >= %exp:cEIniFil% AND 
					Z04_CODIGO <=  %exp:cEFimCod% AND Z04_CODFIL <= %exp:cEFimFil% 
				ORDER 
					BY Z04_CODIGO,Z04_AMB		
			EndSql  
	  
		Else    
		
		    BeginSql Alias 'QRYZ04'
		
				SELECT *  
				FROM
				%Table:Z04%
				WHERE 
					Z04_FILIAL = %exp:xFilial("Z04")%  AND 
					%notDel% AND 
					Z04_AMB =  %exp:cAmbiente% AND
					Z04_AMB NOT IN ('PORTAL','AP7','AP7_2','AP7_3') 
				ORDER 
					BY Z04_CODIGO,Z04_AMB			
			EndSql  	
		
		EndIf		
    EndIf           
    
Return   

/*
Funcao      : MontaDet()
Objetivos   : Monta temporario com os dados que serão impressos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 11/04/2013
*/    

*----------------------------*
  Static Function MontaDet() 
*----------------------------*  

Local cEmp   := ""
Local cAmb   := "" 
Local cChave := ""    
           
Local n      := 1 
Local nPos   := 0
Local nLin   := 460 
Local lFirst := .T.
 
	ProcRegua(QRYZ04->(RecCount()))
	
	While QRYZ04->(!EOF())  
		 
		IncProc()
			            
		oPrint:Say(nLin,35,QRYZ04->Z04_CODIGO,oFont5,,)
		oPrint:Say(nLin,150,QRYZ04->Z04_CODFIL,oFont5,,)
		oPrint:Say(nLin,260,QRYZ04->Z04_NOMFIL,oFont5,,)  	
		oPrint:Say(nLin,700,QRYZ04->Z04_NOME,oFont5,,)  	
		oPrint:Say(nLin,1100,QRYZ04->Z04_NOMECO,oFont5,,)								
		oPrint:Say(nLin,2120,QRYZ04->Z04_AMB,oFont5,,)
		//CNAB
		
		nLin:=nLin+40    
			
		n++             
			
		If nLin>2770 
			
			oPrint:Say(2900,45,"PARAMETROS : ",oFont5,,)
	  		oPrint:Say(2900,530,"De Código: "+Alltrim(cEIniCod)+" Filial: "+cEIniFil ,oFont5,,)
		   	oPrint:Say(2960,530,"Até Código: "+Alltrim(cEFimCod)+" Filial: "+cEFimFil,oFont5,,)
	            	       
		    oPrint:EndPage()   
		    oPrint:StartPage() 
		    oPrint:SetPortrait()
		    oPrint:SetpaperSize(9)
		    nPagina++
		    MontaCab()
		    nLin:=460 
	      
	  	EndIf   
	   		   		
   		QRYZ04->(DbSkip()) 
	
	EndDo  
			
	oPrint:Say(2900,45,"PARAMETROS : ",oFont5,,)
	oPrint:Say(2900,530,"De Código: "+Alltrim(cEIniCod)+" Filial: "+cEIniFil,oFont5,,)
	oPrint:Say(2960,530,"Até Código: "+Alltrim(cEFimCod)+" Filial: "+cEFimFil,oFont5,,)    
	oPrint:Say(3020,530,"User: "+alltrim(cUserName) ,oFont5,,)    	
            	                                                                                                 
    
	 Montaxls()       	       
	              
Return
      
//Foi quebrado em etapas para não causar estouro de variavel.
*----------------------------*
Static Function Montaxls()
*----------------------------*

Local cMsg   := ""   
Local cLinha := ""

Private cDest	:=  GetTempPath()
Private cArq	:= "HD_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"

nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cMsg ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cMsg += "<html>  
cMsg += "	<Header>"   
cMsg += "	<style>"  
cMsg +=" .DataHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal; "
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:center;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:.5pt solid #808080;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:.5pt solid #808080;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".DataLinhaImpar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:center;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=" .DataLinhaPar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:center;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	background:#E3E3E3;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"

cMsg +=".HistoricoHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:.5pt solid #808080;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:none;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".HistoricoLinhaImpar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"

cMsg +=".HistoricoLinhaPar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	background:#E3E3E3;
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"

cMsg +=".ValorHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:.5pt solid #808080;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:none;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".ValorLinhaImpar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +='    mso-number-format:"\#\,\#\#0\.00\;\[Red\]\0022-\0022\\ \#\,\#\#0\.00";'  
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".ValorLinhaPar"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:190;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +='	mso-number-format:"\#\,\#\#0\.00\;\[Red\]\0022-\0022\\ \#\,\#\#0\.00";'
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="	border-top:none;"
cMsg +="	border-right:none;"
cMsg +="	border-bottom:.5pt solid silver;"
cMsg +="	border-left:none;"
cMsg +="	background:#E3E3E3;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"

cMsg +=".SaldoHeader"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:windowtext;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +='	font-family:"";'
cMsg +="	mso-generic-font-family:auto;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:Standard;"
cMsg +="	text-align:right;"
cMsg +="	vertical-align:bottom;"
cMsg +="    border-top:.5pt solid #808080;"
cMsg +="	border-right:.5pt solid #808080;"
cMsg +="	border-bottom:.5pt solid #808080;"
cMsg +="	border-left:none;"
cMsg +="	background:silver;"
cMsg +="	mso-pattern:black none;"
cMsg +="	white-space:nowrap;}"
  
cMsg +=".Titulo"
cMsg +="	{padding:0px;"
cMsg +="	mso-ignore:padding;"
cMsg +="	color:black;"
cMsg +="	font-size:8.0pt;"
cMsg +="	font-weight:700;"
cMsg +="	font-style:normal;"
cMsg +="	text-decoration:none;"
cMsg +="	font-family:Verdana, sans-serif;"
cMsg +="	mso-font-charset:0;"
cMsg +="	mso-number-format:General;"
cMsg +="	text-align:general;"
cMsg +="	vertical-align:middle;"
cMsg +="	mso-background-source:auto;"
cMsg +="	mso-pattern:auto;"
cMsg +="	white-space:nowrap;}"

cMsg += ".Dados"
cMsg += "	{padding:0px;"
cMsg += "	mso-ignore:padding;
cMsg += "	color:black;
cMsg += "	font-size:8.0pt;
cMsg += "	font-weight:190;
cMsg += "	font-style:normal;
cMsg += "	text-decoration:none;"
cMsg += '	font-family:"";'
cMsg += "	mso-generic-font-family:auto;"
cMsg += "	mso-font-charset:0;"
cMsg += "	mso-number-format:Standard;"
cMsg += "	text-align:general;"
cMsg += "	vertical-align:middle;"
cMsg += "	mso-background-source:auto; "
cMsg += "	mso-pattern:auto;"
cMsg += "	white-space:nowrap;}"
cMsg += "</style></head>"
cMsg += "<body>"
cMsg += '<img width="553" height="70" src="http://www.grantthornton.com.br/globalassets/1.-member-firms/global/logos/logo.png" >'
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<tr><td></td></tr>"
cMsg += "		<tr>"
cMsg += "			<td colspan='7' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='Arial' color='black' size='4'> "+SM0->M0_NOME+"</font></td>"
cMsg += "		</tr>"
cMsg += "		<tr>
cMsg += "		</tr>
cMsg += "		<tr>"  

If Empty(cAmbiente)
	cMsg += '			<td class="Titulo" colspan="6">'
	cMsg += "				De : "+Alltrim(cEIniCod)+" Filial: "+cEIniFil +"até :"+Alltrim(cEFimCod)+" Filial: "+cEFimFil +"</td>"
Else
	cMsg += '			<td class="Titulo" colspan="6">'
	cMsg +="Ambiente: "+				cAmbiente+	"</td>"
EndIF

cMsg += "		</tr>"
cMsg += "	<tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "			 	Código"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				Filial"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				Código  /  Nome"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Nome reduzido"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Nome completo"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Ambiente"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Cnab Receber"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Cnab Pagar"
cMsg += "			 </td>"
cMsg += '			 <td class="DataHeader" />'
cMsg += "				 Cnab Folha"
cMsg += "			 </td>"
cMsg += "		 </tr>"

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
       
QRYZ04->(DbGoTop())
While QRYZ04->(!EOF())  
    
	If alltrim(cLinha) <> '<td class="DataLinhaImpar" />'
    	cLinha:='<td class="DataLinhaImpar" />'
	Else
    	cLinha:='<td class="DataLinhaPar" />'	
	EndIf    


	cMsg += "<tr>"
	cMsg += cLinha
	cMsg += '="     '+QRYZ04->Z04_CODIGO+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="'+QRYZ04->Z04_CODFIL+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += '="     '+QRYZ04->Z04_NOMFIL+'"'
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ04->Z04_NOME
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ04->Z04_NOMECO
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ04->Z04_AMB
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ04->Z04_NCNABR//AOA - 29/08/2016 - Tratamento para listar arquivos de configuração CNAB
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ04->Z04_NCNABP//AOA - 29/08/2016 - Tratamento para listar arquivos de configuração CNAB
	cMsg += "	</td>"
	cMsg += cLinha
	cMsg += QRYZ04->Z04_NCNABF//AOA - 29/08/2016 - Tratamento para listar arquivos de configuração CNAB
	cMsg += "	</td>"

	cMsg += "</tr>"    
	
	cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.
	QRYZ04->(DbSkip())

EndDo

cMsg += "	</table>"
cMsg += "	<BR>"
cMsg += "	<BR>"
cMsg += "	<colspan='2'>Data extraction : "+Dtoc(DATE())+" - "+TIME()

cMsg += "</html> "

cMsg := GrvXLS(cMsg) //Grava e limpa memoria da variavel.

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	If ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	
	sleep(8000) //MSM - Para dar tempo de gerar o arquivo
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
EndIf

	sleep(8000) //MSM - Para dar tempo de gerar o arquivo         

FErase(cDest+cArq) 

If select("QRYZ04")>0
	QRYZ04->(DbCloseArea())
EndIf 


Return cMsg

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*

Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

*-------------------------------*
Static Function NumtoExcel(nCont)
*-------------------------------*

Local cRet := ""
Local nValor:= nCont
Local cValor:= TRANSFORM(nValor, "@R 99999999999.99")
Local nLen := LEN(ALLTRIM(cValor))

cRet := SUBSTR(ALLTRIM(cValor),0,nLen-3)+","+RIGHT(ALLTRIM(cValor),2)

Return cRet