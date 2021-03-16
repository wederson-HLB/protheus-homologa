#include "totvs.ch"   
#INCLUDE "rwmake.ch"
#include 'topconn.ch'    
#include 'colors.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDR002  ºAutor  Tiago Luiz Mendonça  º Data ³  02/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de empresas                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDR002()
Objetivos   : Relatório de usuários
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/
*-------------------------*
  User Function GTHDR002()
*--------------------------*    

  
  Local cPerg:="HDREL002"  
                    
  Private oPrint
  Private lRet	  := .T.
  Private nPagina := 1
  
  Private cEIniCod   := "" 
  Private cEFimCod   := ""
  Private cEIniFil   := "" 
  Private cEFimFil   := ""  
  Private cEIniNome  := "" 
  Private cEFimNome  := ""  

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
   cEFimCod := mv_par04 
   
   cEIniFil := mv_par02 
   cEFimFil := mv_par05 

   cEIniNome:= mv_par03 
   cEFimNome:= mv_par06 
  
                               	
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


   oPrint:FillRect({402, 23, 442, 2348}, oBrush)
   oPrint:FillRect({3202, 23, 3316, 2348}, oBrush)  
   
   oPrint:SayBitmap(20,20,"\system\gtlogo.bmp",1300,300)
      
   oPrint:Say(100,2050,"Pagina  "+Alltrim(Str(nPagina)),oFont1)    

  
   oPrint:Say(150,1150,"RELATORIO DE EMPRESAS",oFont4)
   oPrint:Say(200,1150,"Emissão : "+Dtoc(date()),oFont4) 
   
   oPrint:Say(405,35,"EMPRESA",oFont5,,CLR_WHITE)
   oPrint:Say(405,500,"DEPARTAMENTO",oFont5,,CLR_WHITE)
   oPrint:Say(405,900,"CARGO",oFont5,,CLR_WHITE)
   oPrint:Say(405,1200,"SUPERIOR",oFont5,,CLR_WHITE)
   oPrint:Say(405,1500,"AMBIENTE",oFont5,,CLR_WHITE)
   oPrint:Say(405,1700,"COLABORADOR",oFont5,,CLR_WHITE)
   
   oPrint:Say(2810,45,"Observações Gerais ",oFont4)
   
   oPrint:Say(3158,900,"WWW.GRANTTHORNTON.COM.BR",oFont4) 
     		
   oPrint:Box(400,20,3320,2350)
   
   //Linhas do Cabecario

   oPrint:Line(400,20,400,2350)  //Linha
   oPrint:Line(440,20,440,2350)  //Linha

  
   oPrint:Line(2800,20,2800,2350)  //Linha    
   oPrint:Line(3150,20,3150,2350)  //Linha
   oPrint:Line(3200,20,3200,2350)  //Linha 
   //oPrint:Line(3150,1760,3200,1760)  //Coluna

   oPrint:Line(400,540,2800,540)    //Coluna 1 
   oPrint:Line(400,890,2800,890)    //Coluna 2
   oPrint:Line(400,1190,2800,1190)    //Coluna 3
   oPrint:Line(400,1490,2800,1490)    //Coluna 5
   oPrint:Line(400,1690,2800,1690)    //Coluna 6

      
Return   


/*
Funcao      : MontaTemp()
Objetivos   : Monta temporario com os dados que serão impressos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/    

*----------------------------*
  Static Function MontaTemp() 
*----------------------------*

                                                                         
	If Select("QRYZ08") > 0

	QRYZ08->(DbCloseArea())	               

   	EndIf
   	                
    BeginSql Alias 'QRYZ08'

		SELECT *  
		FROM
		Z08010 Z08
		INNER JOIN Z05010 Z05 on Z05.Z05_EMAIL = Z08.Z08_FUNC 
		INNER JOIN Z04010 Z04 on Z08.Z08_EMP = Z04.Z04_CODIGO AND Z08.Z08_FIL = Z04.Z04_CODFIL	
		WHERE 
			Z08.Z08_FILIAL = %exp:xFilial("Z08")%  AND 
			Z04.%notDel% AND 
			Z05.%notDel% AND   
			Z08.%notDel% AND
			Z08.Z08_EMP >=  %exp:cEIniCod% AND
			Z08.Z08_EMP <=  %exp:cEFimCod% 
		ORDER 
			BY Z08.Z08_EMP,Z04.Z04_AMB			
	EndSql  
	                                   

Return   

/*
Funcao      : MontaDet()
Objetivos   : Monta temporario com os dados que serão impressos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
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
 
    ProcRegua(1000)

	While QRYZ08->(!EOF())  
		 
		IncProc()
			            
		If cEmp <> Alltrim(UPPER(QRYZ08->Z08_DESCRI))
			
			oPrint:Say(nLin,37,QRYZ08->Z08_EMP+"/"+QRYZ08->Z08_FIL+" - "+UPPER(Alltrim(QRYZ08->Z08_DESCRI)) ,oFont5,,)
			cEmp:=Alltrim(UPPER(QRYZ08->Z08_DESCRI))    
			             
	 		oPrint:Line(nLin-5,20,nLin-5,2350)  //Linha       	
								
		EndIf
		
		If cChave <> QRYZ08->Z05_DEPTO+QRYZ08->Z05_CARGO+QRYZ08->Z05_SUP+QRYZ08->Z04_AMB+QRYZ08->Z05_NOME 
			                                                  		
			If SX5->(DbSeek(xFilial("SX5")+"Z2"+QRYZ08->Z05_DEPTO))
	   			oPrint:Say(nLin,550,Alltrim(SX5->X5_DESCRI),oFont5,,)
	    	EndIf  
	    	
	    	If SX5->(DbSeek(xFilial("SX5")+"Z8"+QRYZ08->Z05_CARGO))
	   			oPrint:Say(nLin,910,Alltrim(SX5->X5_DESCRI),oFont5,,)
	    	EndIf 
	    	             
	    	nPos:=At("@",QRYZ08->Z05_SUP) 
	    	If nPos > 0
	    		oPrint:Say(nLin,1210,Alltrim(Substr(QRYZ08->Z05_SUP,1,nPos-1)),oFont5,,)    
	    	EndIf
	    	
			cAmb:=GetAmb(Alltrim(QRYZ08->Z04_AMB))      
	  		oPrint:Say(nLin,1510,Alltrim(cAmb),oFont5,,)
	  		
	   		oPrint:Say(nLin,1710,Alltrim(UPPER(QRYZ08->Z05_NOME)) ,oFont5,,)	
		       
			cCHave:=QRYZ08->Z05_DEPTO+QRYZ08->Z05_CARGO+QRYZ08->Z05_SUP+QRYZ08->Z04_AMB+QRYZ08->Z05_NOME
			
			nLin:=nLin+40    
			
			n++             
			
			If nLin>2770 
			
				 oPrint:Say(2900,45,"PARAMETROS : ",oFont5,,)
				 oPrint:Say(2900,300,"De empresa  : ",oFont5,,)
				 oPrint:Say(2960,300,"Até empresa : ",oFont5,,) 
	   	   		 oPrint:Say(2900,530,Alltrim(cEIniCod)+"/"+cEIniFil +" - "+cEIniNome ,oFont5,,)
		   		 oPrint:Say(2960,530,Alltrim(cEFimCod)+"/"+cEIniFil +" - "+cEFimNome ,oFont5,,)
	            	       
		         oPrint:EndPage()   
		         oPrint:StartPage() 
		         oPrint:SetPortrait()
		         oPrint:SetpaperSize(9)
		         nPagina++
		         MontaCab()
		         nLin:=460 
	      
	   		EndIf   
	   		
   		EndIf
   		
   		QRYZ08->(DbSkip()) 
	
	EndDo  
			
	oPrint:Say(2900,45,"PARAMETROS : ",oFont5,,)
	oPrint:Say(2900,300,"De empresa  :",oFont5,,)
	oPrint:Say(2960,300,"Até empresa :",oFont5,,) 
	oPrint:Say(2900,530,Alltrim(cEIniCod)+"/"+cEIniFil +" - "+cEIniNome ,oFont5,,)
	oPrint:Say(2960,530,Alltrim(cEFimCod)+"/"+cEIniFil +" - "+cEFimNome ,oFont5,,)
            	       
	              
Return
      

/*
Funcao      : GetAmb()
Objetivos   : Converte o numero do ambiente em string para impressão
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2012
*/    

*-----------------------------*
  Static Function GetAmb(cAmb) 
*-----------------------------*  
          
Local cRet               
                             
If !Empty(cAmb)   
    
	
	/* TLM 01/11/2013 - Alteração da nomenclatura dos ambientes.
	If cAmb == "1"
		cRet:="AMB01"
	ElseIf cAmb == "2"	
		cRet:="AMB02"
	ElseIf cAmb == "3"	
		cRet:="AMB03"
	ElseIf cAmb == "4"		
		cRet:="GT01"
	ElseIf cAmb == "5"		
		cRet:="GT02"
	ElseIf cAmb == "6"	
		cRet:="GT03"
	ElseIf cAmb == "7"		
		cRet:="GTIS"
	ElseIf cAmb == "8"			
		cRet:="GTCORP"
	ElseIf cAmb == "9"		
		cRet:="PAGUS" 
	Else
		cRet:=" --- "	
	EndIf  
	*/
	
	cRet:=cAmb
	
Else
	cRet:=" --- "	
EndIf			

Return cRet 

