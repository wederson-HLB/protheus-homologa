#include "totvs.ch"   
#INCLUDE "rwmake.ch"
#include 'topconn.ch'    
#include 'colors.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HBEST001  ∫Autor  Tiago Luiz MendonÁa  ∫ Data ≥ 28/08/12    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥RelatÛrio de notas de entradas                              ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Hazera                                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

/*
Funcao      : HBEST001
Objetivos   : RelatÛrio de notas de entrada
Autor       : Jean Victor Rocha
Data/Hora   : 28/08/2012
Cliente     : Hazera
Modulo      : Estoque
*/
*--------------------------*
  User Function HBEST001()
*--------------------------*    
If !cEmpAnt $ "HB|99"
   	MsgInfo("Especifico Hazera ","A T E N C A O")
   	Return .T.
Endif  

Private cAlias := "WORK"
Private cPerg:="HBEST001"  
                    
  Private oPrint
  Private lRet	  := .T.
  
  Private nPagina := 1
  
  Private cNotaIni := "" 
  Private cNotaFim := ""
  Private cDataIni := "" 
  Private cDataFim := ""  

  Private oFont1   := TFont():New('Courier new',,-10,.T.)   
  Private oFont2   := TFont():New('Tahoma',,18,.T.)  
  Private oFont3   := TFont():New('Tahoma',,12,.T.) 
  Private oFont4   := TFont():New('Arial',,11,,.T.,,,,,.f. )   
  Private oFont5   := TFont():New('Arial',,9,,.T.,,,,,.f. )    
  Private oFont6   := TFont():New('Arial',,8,,.T.,,,,,.f. )   
  Private oFont7   := TFont():New('Arial',,7,,.T.,,,,,.f. ) 
  
AjustaSX1()
If !Pergunte(cPerg,.T.)  
	Return .T.
Endif  

	cEmissaoDe 	:= DTOS(Mv_Par01)
	cEmissaoAte := DTOS(Mv_Par02)
	cNFDe  		:= Mv_Par03
	cSerDe 		:= Mv_Par04
	cNFAte  	:= Mv_Par05
	cSerAte 	:= Mv_Par06
	lExcel 		:= Mv_Par07 == 1
	                               	
   // Monta objeto para impress„o
   oPrint := TMSPrinter():New("Impress„o de relatÛrio de Itens da NF.")
 
   // Define orientaÁ„o da p·gina para Retrato
   // pode ser usado oPrint:SetLandscape para Paisagem
   oPrint:SetPortrait()
    
   // Mostra janela de configuraÁ„o de impress„o
   oPrint:Setup()

   // Inicia p·gina
   oPrint:StartPage()  
    
    //Papel A4
   oPrint:SetpaperSize(9)                                                

   Processa( {|| MontaRel() }, "Aguarde...", "Processando os dados...",.F.) 

   If !(lRet)
      Return .F.     
   EndIf

   oPrint:EndPage()

   // Mostra tela de visualizaÁ„o de impress„o
   oPrint:Preview() 

   //Finaliza Objeto 
   oPrint:End() 

If lExcel
	Processa({|| GeraXLS() })
EndIf

Return 

*-------------------------*
Static Function AjustaSX1()
*-------------------------*

U_PUTSX1(cPerg,"01" ,"Emissao De: ? ","" ,"" ,"mv_ch1","D"	,08, 0 , ,"G","",""   ,"","","mv_par01",""		,"","","" ,""		,"",""	,"","",""	,"","","","","","",{"Data Inicial de emiss„o"	} 	,{},{})
U_PUTSX1(cPerg,"02" ,"Emissao Ate: ?","" ,"" ,"mv_ch2","D"	,08, 0 , ,"G","",""   ,"","","mv_par02","" 		,"","","" ,""		,"",""	,"","",""	,"","","","","","",{"Data Final de emiss„o" 	}	,{},{})
U_PUTSX1(cPerg,"03" ,"NF De: ?      ","" ,"" ,"mv_ch3","C"	,09, 0 , ,"G","",""	  ,"","","mv_par03","" 		,"","","" ,""		,"",""	,"","",""	,"","","","","","",{"Numero NF inicial."  		}	,{},{})
U_PUTSX1(cPerg,"04" ,"Serie De: ?   ","" ,"" ,"mv_ch4","C"	,02, 0 , ,"G","",""   ,"","","mv_par04","" 		,"","","" ,""		,"",""	,"","",""	,"","","","","","",{"Serie NF inicial."  		}	,{},{})
U_PUTSX1(cPerg,"05" ,"NF Ate: ?     ","" ,"" ,"mv_ch5","C"	,09, 0 , ,"G","",""   ,"","","mv_par05","" 		,"","","" ,""		,"",""	,"","",""	,"","","","","","",{"Numero NF Final."   		}	,{},{})
U_PUTSX1(cPerg,"06" ,"Serie Ate: ?  ","" ,"" ,"mv_ch6","C"	,02, 0 , ,"G","",""   ,"","","mv_par06","" 		,"","","" ,""		,"",""	,"","",""	,"","","","","","",{"Serie NF Final."  			}	,{},{})
U_PUTSX1(cPerg,"07" ,"Gera Excel?   ","" ,"" ,"mv_ch7","N"	,01, 0 , ,"C","",""   ,"","","mv_par07","1=Sim"	,"","","1","2=N„o"	,"",""	,"","",""	,"","","","","","",{"Informe se gera excel."	}	,{},{})

Return .t.

/*
Funcao      : MontaRel()
Objetivos   : Monta a estrutura do relatorio
Autor       : 
Data/Hora   : 
*/  
*----------------------------*
Static Function MontaRel() 
*----------------------------*
   If Empty(cEmissaoAte) 
      MsgStop("Campo 'Emiss„o ate' deve ser informado.","HLB BRASIL")   
      lRet:=.F.
      Return .F.
   EndIf 
   If Empty(cNFAte) 
      MsgStop("Campo 'NF ate' deve ser informado.","HLB BRASIL")   
      lRet:=.F.
      Return .F.
   EndIf 
   If Empty(cSerAte) 
      MsgStop("Campo 'Serie ate' deve ser informado.","HLB BRASIL")   
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
Autor       : 
Data/Hora   : 
*/    
*----------------------------*
Static Function MontaCab()
*----------------------------*
Local oBrush := TBrush():New( , RGB(60,179,113))

   oPrint:FillRect({402, 23, 442, 2450}, oBrush)
   oPrint:FillRect({3202, 23, 3316, 2450}, oBrush)  

   oPrint:SayBitmap(40,50,"\system\lgrl"+cEmpAnt+".bmp",369,354)
   oPrint:Say(100,2250,"Pagina  "+Alltrim(Str(nPagina)),oFont1)    

   oPrint:Say(150,1000,"Itens de NFs de Entrada.",oFont4)
   oPrint:Say(200,1000,"Emiss„o : "+Dtoc(date()),oFont5) 

   oPrint:Say(405,0030	,"N.Fiscal"		,oFont5,,CLR_WHITE)
   oPrint:Line(400,0190,2800,0190)//190

   oPrint:Say(405,0195	,"Serie"		,oFont5,,CLR_WHITE)
   oPrint:Line(400,0280,2800,0280) //70

   oPrint:Say(405,0285	,"Forn."   		,oFont5,,CLR_WHITE)
   oPrint:Line(400,0410,2800,0410)//150

   oPrint:Say(405,0415	,"Cod.Prod."	,oFont5,,CLR_WHITE)
   oPrint:Line(400,0590,2800,0590)//190

   oPrint:Say(405,0595	,"Descr.Produto",oFont5,,CLR_WHITE)
   oPrint:Line(400,1130,2800,1130)//540

   oPrint:Say(405,1135	,"Qtde"			,oFont5,,CLR_WHITE)
   oPrint:Line(400,1280,2800,1280)//160   

   oPrint:Say(405,1285	,"Vlr Unit."	,oFont5,,CLR_WHITE)
   oPrint:Line(400,1440,2800,1440)//160

   oPrint:Say(405,1445	,"N∫ Lote"		,oFont5,,CLR_WHITE)
   oPrint:Line(400,1605,2800,1605)//140

   oPrint:Say(405,1610	,"E. Date"	,oFont5,,CLR_WHITE)
   oPrint:Line(400,1735,2800,1735)//200

   oPrint:Say(405,1740	,"% Gem"		,oFont5,,CLR_WHITE)
   oPrint:Line(400,1860,2800,1860)

   oPrint:Say(405,1865	,"T. Date"	,oFont5,,CLR_WHITE)
   oPrint:Line(400,1990,2800,1990)

   oPrint:Say(405,1995	,"Invoice"	,oFont5,,CLR_WHITE)
  
   oPrint:Say(2930,45,"ObservaÁıes Gerais ",oFont4)
     		
   oPrint:Box(400,20,3320,2450)
  
   oPrint:Line(2800,20,2800,2450)  //Linha    
   oPrint:Line(3200,20,3200,2450)  //Linha 
      
Return   

/*
Funcao      : MontaTemp()
Objetivos   : Querr, busca dos dados.
Autor       : Jean Victor Rocha
Data/Hora   :
*/    
*----------------------------*
Static Function MontaTemp() 
*----------------------------*

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())	               
   	EndIf

    BeginSql Alias cAlias
		Select F1.F1_FILIAL,F1.F1_DOC,F1.F1_EMISSAO,F1.F1_SERIE,F1.F1_FORNECE,D1.D1_COD,B1.B1_DESC,D1.D1_QUANT,D1.D1_VUNIT,D1.D1_LOTECTL,
				D1.D1_P_ENTRY,D1.D1_P_PER,D1.D1_P_TEST,D1.D1_CONHEC
		From %table:SD1% D1 left outer join(Select F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_EMISSAO
										From %table:SF1%	
								   		Where %notDel%) F1 on D1.D1_FILIAL	= F1.F1_FILIAL 	AND
															D1.D1_DOC 		= F1.F1_DOC 	AND
															D1.D1_SERIE 	= F1.F1_SERIE 	AND
															D1.D1_FORNECE 	= F1.F1_FORNECE
						left outer join(Select B1_COD,B1_DESC
										From %table:SB1%		
						   				Where D_E_L_E_T_ <> '*') B1 on B1.B1_COD = D1.D1_COD
		Where 	D1.%notDel% AND 
				F1.F1_EMISSAO 	>= %exp:cEmissaoDe% AND
				F1.F1_EMISSAO 	<= %exp:cEmissaoAte% AND
				F1.F1_DOC 		>= %exp:cNFDe% AND
				F1.F1_DOC 		<= %exp:cNFAte% AND
				F1.F1_SERIE 	>= %exp:cSerDe% AND
				F1.F1_SERIE 	<= %exp:cSerAte% AND
				F1.F1_FILIAL	 = %exp:xFilial("SF1")% AND 
				D1.D1_COD like 'RNC%'				
		Order by F1.F1_DOC,F1.F1_SERIE
	EndSql  

Return   

/*
Funcao      : MontaDet()
Objetivos   : Monta temporario com os dados que ser„o impressos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/    
*----------------------------*
  Static Function MontaDet() 
*----------------------------*  
Local cUser  := ""
Local cAmb   := ""     
           
Local n      := 1
Local nPos   := 0
Local nLin   := 460 
Local lFirst := .T.  

Local nTotVal := 0
Local nTotQtd := 0

    ProcRegua(1000)

	While (cAlias)->(!EOF())  
		IncProc()
		//Conteudo Impresso.	            
		oPrint:Say(nLin,32	,ALLTRIM((cAlias)->F1_DOC)		,oFont6,,)
 		oPrint:Line(nLin-5,20,nLin-5,2450)  //Linha       	
		oPrint:Say(nLin,197	,ALLTRIM((cAlias)->F1_SERIE)	,oFont6,,)
		oPrint:Say(nLin,287	,ALLTRIM((cAlias)->F1_FORNECE)	,oFont6,,)
   		oPrint:Say(nLin,0417,ALLTRIM((cAlias)->D1_COD)		,oFont6,,)
  		oPrint:Say(nLin,0597,ALLTRIM((cAlias)->B1_DESC)		,oFont6,,)
  		oPrint:Say(nLin,1137,AllTrim(Transform((cAlias)->D1_QUANT,"@E 999,999,999.99")) ,oFont6,,)
		oPrint:Say(nLin,1282,AllTrim(Transform((cAlias)->D1_VUNIT,"@E 999,999,999.99"))	,oFont6,,)
		oPrint:Say(nLin,1442,AllTrim((cAlias)->D1_LOTECTL)	,oFont6,,)
   		oPrint:Say(nLin,1612,DTOC(STOD(ALLTRIM((cAlias)->D1_P_ENTRY)))		,oFont6,,)	
   		oPrint:Say(nLin,1742,AllTrim(Transform((cAlias)->D1_P_PER,"@E 9999.99"))		,oFont6,,)
   		oPrint:Say(nLin,1867,DTOC(STOD(ALLTRIM((cAlias)->D1_P_TEST)))		,oFont6,,)
   		oPrint:Say(nLin,1997,BuscaInvoice((cAlias)->D1_CONHEC)	,oFont7,,)
        
		nTotVal += (cAlias)->D1_VUNIT
		nTotQtd += (cAlias)->D1_QUANT

		nLin:=nLin+40

		If nLin>2770 
			oPrint:Say(2820,0030,"Totais:"	 									,oFont5,,)	
			oPrint:Say(2820,1137,AllTrim(Transform(nTotVal,"@E 999,999,999.99")),oFont5,,)
	  		oPrint:Say(2820,1282,AllTrim(Transform(nTotQtd,"@E 999,999,999.99")),oFont5,,)			
			oPrint:Line(2860,20,2860,2450)  //Linha
			nTotVal:=nTotQtd:=0
			oPrint:Say(3020,45,"PARAMETROS  :",oFont5,,)
   			oPrint:Say(3020,320,"Dt.Emissao :",oFont5,,)
   			oPrint:Say(3080,320,"NF inicial :",oFont5,,)
   			oPrint:Say(3140,320,"NF Final   :",oFont5,,)
   			oPrint:Say(3020,550,Alltrim(DTOC(STOD(ALLTRIM(cEmissaoDe)))+" AtÅE"+DTOC(STOD(ALLTRIM(cEmissaoate)))),oFont5,,)
   			oPrint:Say(3080,550,Alltrim(cNFDe +" / "+cSerDe ),oFont5,,)
   			oPrint:Say(3140,550,Alltrim(cNFAte+" / "+cSerAte),oFont5,,)
 
	         oPrint:EndPage()   
	         oPrint:StartPage() 
	         oPrint:SetPortrait()
	         oPrint:SetpaperSize(9)
	         nPagina++
	         MontaCab()
	         nLin:=460 
   		EndIf   
   		(cAlias)->(DbSkip()) 
	EndDo               
			oPrint:Say(2820,0030,"Totais:"	 									,oFont5,,)	
			oPrint:Say(2820,1137,AllTrim(Transform(nTotVal,"@E 999,999,999.99")),oFont5,,)
	  		oPrint:Say(2820,1282,AllTrim(Transform(nTotQtd,"@E 999,999,999.99")),oFont5,,)			
			oPrint:Line(2860,20,2860,2450)  //Linha
			nTotVal:=nTotQtd:=0
			oPrint:Say(3020,45,"PARAMETROS  :",oFont5,,)
   			oPrint:Say(3020,320,"Dt.Emissao :",oFont5,,)
   			oPrint:Say(3080,320,"NF inicial :",oFont5,,)
   			oPrint:Say(3140,320,"NF Final   :",oFont5,,)
   			oPrint:Say(3020,550,Alltrim(DTOC(STOD(ALLTRIM(cEmissaoDe)))+" AtÅE"+DTOC(STOD(ALLTRIM(cEmissaoate)))),oFont5,,)
   			oPrint:Say(3080,550,Alltrim(cNFDe +" / "+cSerDe ),oFont5,,)
   			oPrint:Say(3140,550,Alltrim(cNFAte+" / "+cSerAte),oFont5,,)

Return

*-------------------------*
Static Function GeraXLS()
*-------------------------*
Local nHdl
Local cHtml		:= ""
Private cDest	:=  GetTempPath()
Private cArqMV  := "NF"
 
cArq := ALLTRIM(cArqMV)+".xls"
	
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl   		:= FCREATE(cDest+cArq,0 )//CriaÁ„o do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cHtml )  //GravaÁ„o do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado	

cHtml := Montaxls()

If nBytesSalvo <= 0   // VerificaÁ„o do arquivo (GRAVADO OU NAO) e definiÁ„o de valor de Bytes retornados.
	MsgStop("Erro de gravaÁ„o do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
          
FErase(cDest+cArq)

Return .T.    

*-------------------------*
Static Function Montaxls()
*-------------------------*
Local cMsg := ""
Local i,j 

Local aCampos := {"F1_DOC","F1_SERIE","F1_FORNECE","D1_COD","B1_DESC","D1_QUANT","D1_VUNIT","D1_P_ENTRY","D1_P_PER","D1_P_TEST","D1_CONHEC"}

ProcRegua((cAlias)->(RecCount()))

(cAlias)->(DbGoTop())

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data ExecuÁ„o:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b> Itens NFs de Entrada.              </b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
	For i:=1 to (cAlias)->(FCount())
		If aScan(aCampos,{|x| x == (cAlias)->(Fieldname(i))}) <> 0
			cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
			If (cAlias)->(Fieldname(i)) == "D1_CONHEC"
				cMsg += "		<font face='times' color='black' size='3'> <b> Invoice</b></font>"
			Else 
				cMsg += "		<font face='times' color='black' size='3'> <b> "+ RETSX3((cAlias)->(Fieldname(i)), "TIT") +"</b></font>"			
			EndIf
			cMsg += "		</td>"
		EndIf
	Next i
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

k:= 0
nIncTempo := 0

(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	cMsg += "		 <tr>"
	For i:=1 to (cAlias)->(FCount((cAlias)->(&((cAlias)->(Fieldname(i))))))
		lChar := .F.
		If aScan(aCampos,{|x| x == (cAlias)->(Fieldname(i))}) <> 0
			If (cAlias)->(Fieldname(i)) == "D1_P_ENTRY" .or. (cAlias)->(Fieldname(i)) == "D1_P_TEST"
				cCont := DTOC(STOD(ALLTRIM((cAlias)->D1_P_ENTRY)))
			ElseIf (cAlias)->(Fieldname(i)) == "D1_CONHEC"
				cCont := BuscaInvoice((cAlias)->D1_CONHEC)
			ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "D"
				cCont := DtoC((cAlias)->(&((cAlias)->(Fieldname(i)))))
			ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "N"
				cCont := NumtoExcel(i)			
			ElseIf ValType((cAlias)->(&((cAlias)->(Fieldname(i))))) == "C"
				For j:=1 to Len(ALLTRIM( (cAlias)->(&((cAlias)->(Fieldname(i)))) ))
					cAux := SubStr((cAlias)->(&((cAlias)->(Fieldname(i)))),j,1)
					If ASC(cAux) < 48 .or. ASC(cAux) > 57
						lChar := .T.
					EndIf
				Next j
                If lChar .or. EMPTY((cAlias)->(&((cAlias)->(Fieldname(i)))))
                	cCont := (cAlias)->(&((cAlias)->(Fieldname(i))))
                Else
					cCont := '=TEXTO('+ALLTRIM(STR(VAL((cAlias)->(&((cAlias)->(Fieldname(i)))))))+';"'+STRZERO(0,LEN((cAlias)->(&((cAlias)->(Fieldname(i))))))+'")'//quando for numero
				EndIf
			EndIf                                                                                                                          
			cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
			cMsg += "				<font face='times' color='black' size='3'>"+cCont
			cMsg += "			</td>"
		EndIf
	Next i
	cMsg += "		 </tr>"
	(cAlias)->(DbSkip())
	IncProc(" - Gerando arquivo Excel...")	
	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gracaÁ„o)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf
	nIncTempo++
	k++
EndDo

cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "
cMsg := GrvXLS(cMsg)

Return cMsg

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

*------------------------------------*
Static Function RETSX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
		Case cFuncao == "TIT"
			xRet := SX3->X3_TITULO
	EndCase
EndIf
RestOrd(aOrd)
Return xRet  

*----------------------------------*
Static Function NumtoExcel(i,lValor)
*----------------------------------*
Local cRet		:= ""
Local nValor	:= 0
Default lValor	:= .F.
If lValor
	nValor := i
Else
	nValor := (cAlias)->(&((cAlias)->(Fieldname(i))))
EndIf
If RIGHT(TRANSFORM(nValor, "@R 99999999999.99"),2) == "00"
	cRet := ALLTRIM(STR(nValor))
ElseIf RIGHT(TRANSFORM(nValor, "@R 99999999999.99"),1) == "0"
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-2)+","+RIGHT(ALLTRIM(STR(nValor)),1)
Else
	cRet := SUBSTR(ALLTRIM(STR(nValor)),0,LEN(ALLTRIM(STR(nValor)))-3)+","+RIGHT(ALLTRIM(STR(nValor)),2)
EndIf
Return cRet

*----------------------------------*
Static Function BuscaInvoice(cHawb)
*----------------------------------*
Local cRet := ""

SW9->(DbSetOrder(3))
If SW9->(DbSeek(xFilial("SW9")+cHawb))
	cRet := ALLTRIM(SW9->W9_INVOICE)
EndIf

Return cRet
