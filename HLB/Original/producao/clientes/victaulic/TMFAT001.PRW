#include "TOTVS.CH"
#include "RWMAKE.CH"
#include "topconn.ch"    
#include "colors.ch"

/*
Funcao      : TMFAT001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Pick-List (Expedicao) 
Autor       : João Silva
Data        : 01/07/2013     

Revisão     : Jean Victor Rocha          
Data        : 27/06/2014
 
Revisão     : Tiago Luiz Mendonça     
Data        : 27/07/2014   

Módulo      : Faturamento.

*/                        
*----------------------*                                                                                                    
User Function TMFAT001()   
*----------------------*

Private cPerg   := "TMFAT01"
Private nTotal  := 0
Private nPagina := 0
Private aLibP   := {}
Private aImp    := {}

Private nTipoPick
Private cPedidoDe
//Private cPedidoAte
Private nTipoExcel
Private lImp     := .T.   

Private  cQryParc := ""
Private cQrySelect:= ""
Private cQryFrom  := ""
Private cQryWhere := ""
Private cQryWhere1:= ""
Private cQryOrder := ""
Private cQryGrup  := ""  
Private aStru  	  := {}

IF SM0->M0_CODIGO $ "TM/9Y"  

   Begin Sequence         		                                 
		
			
		//AjustaSx1()
		If Pergunte(cPerg)    
		
			nTipoPick	:= mv_par01   //1-Previa; 2-Efetiva; 3-Gerado
			cPedidoDe	:= mv_par02
			nTipoExcel	:= mv_par03
			
			If nTipoPick == 2 .and.;
				 ExistEfetiva() .and.;
				 !MSGYESNO("Desejar realmente efetivar a impressão do picking, a reserva do pedido não poderá ser estornada"+;
				 			", Deseja continuar?",;
							"Victaulic")
				Return .F.
			EndIf
			       
			Query()
	                
	        // Valida a impressão apenas para PREVIA ou EFETIVA
	 		If nTipoPick <> 3           
   				If !(lImp)
					MsgStop("Este pedido foi configurado com 'PARCIAL NAO' e possui itens bloqueados, picking não pode ser impresso","Victaulic")
					Return .F.
				EndIf
               
			EndIf
				
			SQL->(DbGoTop())
			If SQL->(!EoF()) 
	 			Processa({|| CriaLayout("SQL")})
		  	Else   
		   		If lImp
		     		Alert("Não foi encontrado registro, pedido inválido ou pick gerado. Verifique os parametros")
		       		Return .F.
	    	   EndIf
	    	EndIf
		EndIf

   End Sequence
EndIf

Return .T.

*-------------------------*
STATIC Function AjustaSx1()
*-------------------------*
Local i := 0
Local nCount := 0
Local aSx1		:= {}
Local aSX1Estrut:= {"X1_GRUPO" ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA" ,"X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL",;
	               "X1_PRESEL" ,"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01"  ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02",;
	               "X1_DEF02"  ,"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03"  ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
	               "X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05"  ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5",;
	               "X1_CNT05"  ,"X1_F3"     ,"X1_PYME"   ,"X1_GRPSXG" ,"X1_HELP"   ,"X1_PICTURE","X1_IDFIL" }

aAdd(aSX1,{cPerg,"01","Tipo ?"      ,"¿Tipo ?"     ,"Type ?"      ,"mv_ch1","N",01,0,0,"C","","mv_par01","Previa"	,"Avance"	,"Preview"	,"","","Efetiva"	,"Eficaz"	,"Effective"	,"","","Gerado","Gerado","Gerado","","","","","","","","","","","","","","","","",""})
aAdd(aSX1,{cPerg,"02","Pedido ?" ,"¿De pedido ?","From order ?","mv_ch2","C",06,0,0,"G","","mv_par02",""			,""			,""			,"","" ,""			,""		   	,""				,"","","","","","","","","","","","","","","","","SC5","","","","",""})
//aAdd(aSX1,{cPerg,"03","Ate pedido ?","¿A pedido ?" ,"To order ?"  ,"mv_ch3","C",06,0,0,"G","","mv_par03",""			,""			,""			,"","" ,""			,""			,""				,"","","","","","","","","","","","","","","","","SC5","","","","",""})
aAdd(aSX1,{cPerg,"03","Excel ?"     ,"¿Excel ?"    ,"Excel ?"     ,"mv_ch3","N",01,0,0,"C","","mv_par03","Sim"		,"Sim"		,"Sim"		,"","","Nao"		,"Nao"		,"Nao"			,"","","","","","","","","","","","","","","","","","","","","",""})
   
aRecSX1 := {}
SX1->(DbSetOrder(1))
If SX1->(DbSeek(aSX1[1][1]))
	While SX1->(!EOF()) .and. ALLTRIM(SX1->X1_GRUPO) == ALLTRIM(cPerg)
		nCount++
		If nCount > Len(aSX1) 
			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
		Else
			aAdd(aRecSX1,SX1->(Recno()))
		EndIf
		SX1->(DbSkip())
	EndDo
EndIf

SX1->(DbSetOrder(1))
For i:= 1 To Len(aSX1)
	If Len(aRecSX1) == Len(aSX1) .or.;
	   (Len(aRecSX1) <> 0 .and. Len(aRecSX1) >= i)
		SX1->(DbGoTo(aRecSX1[i]))
		SX1->(RecLock("SX1",.F.))
		For j:=1 To Len(aSX1[i])
			If SX1->(FieldPos(aSX1Estrut[j])) > 0 .And. aSX1[i,j] != NIL
				SX1->(FieldPut(SX1->(FieldPos(aSX1Estrut[j])) ,aSX1[i,j]))
			EndIf
		Next j
		SX1->(MsUnlock())
	Else
		RecLock("SX1",.T.)
		For j:=1 To Len(aSX1[i])
			If SX1->(FieldPos(aSX1Estrut[j])) > 0 .And. aSX1[i,j] != NIL
				SX1->(FieldPut(SX1->(FieldPos(aSX1Estrut[j])) ,aSX1[i,j]))
			EndIf
		Next j
  		SX1->(MsUnlock())
	EndIf
Next i

Return

*----------------------------*
Static Function ExistEfetiva()
*----------------------------*
Local lRet := ""
Local cQry := ""

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf 

cQry := " SELECT COUNT(SC9.C9_PEDIDO) AS COUNT
cQry += " From "+RetSqlName("SC9")+" SC9
cQry += " 		LEFT JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM
cQry += " WHERE SC9.D_E_L_E_T_ <> '*' 
cQry += "		AND SC6.D_E_L_E_T_ <> '*'
cQry += " 		AND SC9.C9_BLEST = '  '
cQry += " 		AND SC9.C9_NFISCAL = '  '

If !EMPTY(cPedidoDe)
	cQry += " 	AND SC9.C9_PEDIDO = '"+cPedidoDe+"'
EndIf  

//If !EMPTY(cPedidoAte)
//	cQry += " 	AND SC9.C9_PEDIDO <= '"+cPedidoAte+"'
//EndIf     

If (SC9->(FieldPos("C9_P_PICK")) > 0)
	cQry += "	AND SC9.C9_P_PICK <> 'S'
EndIf	
    
TCQuery cQry ALIAS "QRY" NEW   

QRY->(DbGoTop())
If QRY->(!EOF())
	lRet := QRY->COUNT > 0
EndIf

Return lRet
                  
*--------------------------*
Static Function Query()   
*--------------------------*

Local i

//ECR - 06/05/14
//Cria query para identificar se o pedido foi liberado por parcialmente
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf 

cQryParc := " SELECT SC9.C9_PEDIDO,C9_BLEST,SUM(SC6.C6_QTDVEN) AS TOTVEN,SUM(SC9.C9_QTDLIB) AS TOTLIB,SUM(SC6.C6_QTDENT) AS TOTENT
cQryParc += " From "+RetSqlName("SC9")+" SC9
cQryParc += " 		LEFT JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM
cQryParc += " WHERE SC9.D_E_L_E_T_ <> '*' 
cQryParc += "		AND SC6.D_E_L_E_T_ <> '*'
cQryParc += " 		AND SC9.C9_NFISCAL = '  '
If !EMPTY(cPedidoDe)
	cQryParc += " 	AND SC9.C9_PEDIDO = '"+cPedidoDe+"'
EndIf
//EndIf       

cQryParc += " GROUP BY SC9.C9_PEDIDO,C9_BLEST 
cQryParc += " ORDER BY SC9.C9_PEDIDO

TCQuery cQryParc ALIAS "QRY" NEW   


/*  TLM - 07/07/2014

 aImp  - Controla a impressão
 aLibP - Controla a flag parcial ou não
  

*/

QRY->(DbGoTop())
While QRY->(!EOF())
	SC5->(DbSetOrder(1))
	
	If SC5->(DbSeek(xFilial("SC5")+QRY->C9_PEDIDO))                      
   	   
 		//Nao pode faturar parcial
   		If SC5->C5_P_PARC == "N"  
   			//Item bloqueado 
   			If QRY->C9_BLEST == "02"
		   		aAdd(aImp,{AllTrim(QRY->C9_PEDIDO),.F.})     
			Else
				If QRY->TOTVEN <> QRY->TOTLIB+QRY->TOTENT   			
			   		aAdd(aImp,{AllTrim(QRY->C9_PEDIDO),.F.})     
			 		aAdd(aLibP,{AllTrim(QRY->C9_PEDIDO),.T.})   
				Else
					aAdd(aImp,{AllTrim(QRY->C9_PEDIDO),.T.})   
			   		aAdd(aLibP,{AllTrim(QRY->C9_PEDIDO),.F.})				
				EndIf			
				//aAdd(aImp,{AllTrim(QRY->C9_PEDIDO),.T.})   
			 	//aAdd(aLibP,{AllTrim(QRY->C9_PEDIDO),.F.})   
			EndIf
        Else
       		//Item bloqueado 
   			If QRY->C9_BLEST == "02"
		   		aAdd(aLibP,{AllTrim(QRY->C9_PEDIDO),.T.})     
			Else 
				If QRY->TOTVEN <> QRY->TOTLIB+QRY->TOTENT   
					aAdd(aLibP,{AllTrim(QRY->C9_PEDIDO),.T.})  
				Else                                                 
					aAdd(aLibP,{AllTrim(QRY->C9_PEDIDO),.F.})    
				EndIf
			EndIf    
        
        EndIf  
    EndIF 
    QRY->(DbSkip())   
EndDo

QRY->(dbCloseArea())            
For i=1 to Len(aImp) 
	If !(aImp[i][2])
		lImp := aImp[i][2]
	EndIf	
Next

//Query de retorno dos dados
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf 

//Query de retorno dos dados
If Select("SQL2") > 0
	SQL2->(dbCloseArea())
EndIf 


aStru := {SC9->(dbStruct()),SC1->(dbStruct()), SC5->(dbStruct())}

ProcRegua(Len(aStru))

cQrySelect := "SELECT SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_SEGUM,SB1.B1_PESO,SB1.B1_PESBRU,"
cQrySelect += "	SC9.C9_DATALIB,SC9.C9_ITEM,SC9.C9_QTDLIB,SC9.C9_LOCAL,SC9.C9_NFISCAL,SC9.R_E_C_N_O_ AS RECSC9,"
cQrySelect += "	SC5.C5_NUM,SC5.C5_EMISSAO,SC5.C5_P_PARC,SC9.C9_PEDIDO,SC5.C5_CLIENT,SC5.C5_LOJAENT, "
cQrySelect += "	SA1.A1_NOME,SA1.A1_END,SA1.A1_CEP,SA1.A1_MUN,SA1.A1_EST,SA1.A1_BAIRRO,SA1.A1_INSCR,SA1.A1_CGC,"
cQrySelect += "	SA1.A1_ENDENT,SA1.A1_CEPE,SA1.A1_MUNE,SA1.A1_ESTE,SA1.A1_BAIRROE"

If (SC9->(FieldPos("C9_P_ID")) > 0)
	cQrySelect += "	,SC9.C9_P_ID"
EndIf

cQryFrom   += " FROM "+ RetSqlName("SC9") + " SC9"
cQryFrom   += "	INNER JOIN "+RetSqlName("SB1") + " SB1 " + "ON SB1.B1_COD = SC9.C9_PRODUTO"
cQryFrom   += "	INNER JOIN "+RetSqlName("SC5") + " SC5 " + "ON SC5.C5_NUM = SC9.C9_PEDIDO"
cQryFrom   += "	INNER JOIN "+RetSqlName("SA1") + " SA1 " + "ON SC5.C5_CLIENT = SC9.C9_CLIENTE"

cQryWhere  += " WHERE SC9.D_E_L_E_T_  <> '*' AND SC5.D_E_L_E_T_  <> '*' AND SC9.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
cQryWhere  += "	AND SC9.C9_CLIENTE	= SA1.A1_COD" 
cQryWhere  += "	AND SC9.C9_LOJA		= SA1.A1_LOJA" 
cQryWhere  += "	AND SC9.C9_PRODUTO	= SB1.B1_COD "
cQryWhere  += "	AND SC9.C9_FILIAL   = '"+xFilial("SC9")+"' "
cQryWhere  += "	AND SC9.C9_BLEST	= ''"

//Nao gerado
If nTipoPick <> 3  
	cQryWhere  += "	AND SC9.C9_NFISCAL	= ''"
EndIf   

If !EMPTY(cPedidoDe)
	cQryWhere += " 	AND SC9.C9_PEDIDO = '"+cPedidoDe+"'"
EndIf
                       
If (SC9->(FieldPos("C9_P_PICK")) > 0)
	
	//Gerado
	If nTipoPick  == 3  
		cQryWhere1 += " AND SC9.C9_P_PICK ='S'
	Else
		cQryWhere1 += " AND SC9.C9_P_PICK = '  '	
	EndIF  
	
EndIf

cQryGrup   += " Group BY SC5.C5_NUM

cQryOrder  += " ORDER BY SC5.C5_NUM         

TCQuery cQrySelect+cQryFrom+cQryWhere+cQryWhere1+cQryOrder ALIAS "SQL" NEW 

For i:=1 to len(aStru)
	For nX := 1 To Len(aStru[i])
	    If aStru[i][nX,2]<>"C"
	 	    TcSetField("SQL",aStru[i][nX,1],aStru[i][nX,2],aStru[i][nX,3],aStru[i][nX,4])
	    EndIf
	Next nX  
Next i 
        

TCQuery cQrySelect+cQryFrom+cQryWhere+cQryWhere1+cQryOrder ALIAS "SQL2" NEW 

For i:=1 to len(aStru)
	For nX := 1 To Len(aStru[i])
	    If aStru[i][nX,2]<>"C"
	 	    TcSetField("SQL2",aStru[i][nX,1],aStru[i][nX,2],aStru[i][nX,3],aStru[i][nX,4])
	    EndIf
	Next nX  
Next i 
          
//Contador de Paginas
If Select("COUNT") > 0
	COUNT->(dbCloseArea())
EndIf 
TCQuery "SELECT CASE when COUNT(SC5.C5_NUM)>49 then (COUNT(SC5.C5_NUM)/49)+1 else 1 end  AS PAGINAS"+cQryFrom+cQryWhere+cQryGrup ALIAS "COUNT" NEW   

nTotal := 0

COUNT->(DbGoTop())
While COUNT->(!Eof())
	nTotal += COUNT->PAGINAS 
    COUNT->(DbSkip())
EndDo
COUNT->(dbCloseArea())

Return      
 
*--------------------------*
Static Function CriaLayout()   
*--------------------------*
//Declara a variável objeto do relatório
Private oPrint
Private nLinha := 0 
Private nLinha2:= 0
//Cria os objetos fontes que serão utilizadoas através do método TFont()                            
Private oFont5      := TFont():New('Arial',,07,,.F.,,,,,.F. )       // 5
Private oFont07     := TFont():New('Arial',07,07,,.F.,,,,.T.,.F.)	// 07
Private oFont07n    := TFont():New('Arial',07,07,,.T.,,,,.T.,.F.)   // 07
Private oFont08     := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.)  	// 08
Private oFont08n    := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.)   // 08 
Private oFont08c    := TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.) // 08
Private oFont08cn   := TFont():New('Courier New',08,08,,.T.,,,,.T.,.F.) // 08
Private oFont09     := TFont():New('Arial',09,09,,.F.,,,,.T.,.F.)  	// 09
Private oFont09n    := TFont():New('Arial',09,09,,.T.,,,,.T.,.F.)   // 09
Private oFont09c    := TFont():New('Courier New',09,09,,.F.,,,,.T.,.F.) // 09
Private oFont09cn   := TFont():New('Courier New',09,09,,.T.,,,,.T.,.F.) // 09
Private oFont10     := TFont():New('Tahoma',10,11,,.F.,,,,.T.,.F.)  // 11
Private oFont10n    := TFont():New('Tahoma',10,11,,.T.,,,,.T.,.F.)  // 11

Private nTotQtdLib	:= 0
Private nTotPesoL	:= 0
Private nTotPesoLT	:= 0
Private nTotPesoB	:= 0
Private nTotPesoBT	:= 0   

Private cAux        := ""				
Private nAux        := 0  

Begin Sequence
	//Cria objeto TMSPrinter()               
	oPrint:= TMSPrinter():New( "Impressão de Pick-List "+ALLTRIM(FWEmpName(cEmpAnt)) )  
	oPrint:SetPortrait()  //Página tipo retrato
	oPrint:StartPage()   //Inicia uma nova página
	oPrint:SetpaperSize(9)  //Papel A4

	cPedido := ""
	SQL->(!EOF())
	While SQL->(!EOF())
		//Cria o Cabeçalho do Relatório
		If cPedido <> SQL->C5_NUM
			If cPedido <> ""
				ReportTotal(oPrint)
				oPrint:EndPage()   
		  		oPrint:StartPage() 
		  		oPrint:SetPortrait()
		  		oPrint:SetpaperSize(9)
			EndIf

			nPagina++
			BoxGeral(oPrint) //Molduras externas
			ReportHeader(oPrint)
			cPedido := SQL->C5_NUM
		ElseIf nLinha > 3050
			oPrint:EndPage()   
			oPrint:StartPage() 
			oPrint:SetPortrait()
			oPrint:SetpaperSize(9)
			
			nPagina++
			BoxGeral(oPrint) //Molduras externas
			ReportHeader(oPrint)
		EndIf
		
		Processa({||ReportDetail(oPrint)    })

		//Verifica se é o fim da pagina e gera uma nova, alem de  atualizar o numero de pagina.
		nLinha	:= nLinha2 //JSS
		nLinha	+=	30  
		IncProc("Gerando...")
		SQL->(DbSkip())
	EndDo
 
	ReportTotal(oPrint)	
	SQL->(DbGoTop())
	    
	If nTipoExcel == 1
		GeraExcel()
	EndIf
	
	oPrint:Preview()//Preview da Impressao
	oPrint:EndPage()//Finaliza a página

	//Finaliza Objeto 
	oPrint:End() 
    SQL->(DbGoTop())
	//Desativa Impressora
	ms_flush() 

End Sequence

Return

*----------------------------------*
Static Function ReportHeader(oPrint)
*----------------------------------*   

Local lLibP := .F.
Local nPos  := 0

Begin Sequence    

	//TLM - Se possuir pelo menos um item bloqueado o pedido é parcial
	For i=1 to Len(aLibP) 
		If (aLibP[i][2])
			lLibP := aLibP[i][2]
   		EndIf	
	Next  
	
	//Logo
	oPrint:SayBitmap(230,110,"\System\LGRL"+ALLTRIM(cEmpAnt)+".jpg",526,178) 

	//Cliente 
	SA1->(DbSetOrder(6))                
	SA1->(dbSeek(xFilial("SA1")+SQL->C5_CLIENT+SQL->C5_LOJAENT))  
   
	//Imprime detalhes do cabeçalho relatorio
	oPrint:Say(170,695,"PICK-LIST",oFont10n,,CLR_BLACK)

	oPrint:Say(270,695,"Razão Social: ",oFont08n,,CLR_BLACK)
	oPrint:Say(270,955,Alltrim(SQL->A1_NOME),oFont08,,CLR_BLACK)      
	
	If Empty(SQL->A1_ENDENT)
		oPrint:Say(310,695,"Endereço: ",oFont08n,,CLR_BLACK)
   		oPrint:Say(310,955,Alltrim(SQL->A1_END)+" - "+Alltrim(SQL->A1_BAIRRO),oFont08,,CLR_BLACK)
		oPrint:Say(350,695,"Município: ",oFont08n,,CLR_BLACK)
		oPrint:Say(350,955,Alltrim(SQL->A1_MUN),oFont08,,CLR_BLACK)
	Else
		oPrint:Say(310,695,"Endereço Entrega: ",oFont08n,,CLR_BLACK)
   		oPrint:Say(310,955,Alltrim(SQL->A1_ENDENT)+" - "+Alltrim(SQL->A1_BAIRROE),oFont08,,CLR_BLACK)
		oPrint:Say(350,695,"Município Entrega: ",oFont08n,,CLR_BLACK)
		oPrint:Say(350,955,Alltrim(SQL->A1_MUNE),oFont08,,CLR_BLACK)   
	EndIf
	
	oPrint:Say(390,695,"CNPJ: ",oFont08n,,CLR_BLACK)
	oPrint:Say(390,955,Alltrim(Transform(SQL->A1_CGC,"@R 99.999.999/9999-99")),oFont08,,CLR_BLACK)
	oPrint:Say(430,695,"Inscr. Estadual: ",oFont08n,,CLR_BLACK)
	oPrint:Say(430,955,Alltrim(SQL->A1_INSCR),oFont08,,CLR_BLACK)

	oPrint:Say(170,1830,"PEDIDO:",oFont10n,,CLR_BLACK)            
	oPrint:Say(170,2050,Alltrim(SQL->C5_NUM+IIF(lLibP," P","")),oFont10,,CLR_BLACK)
	oPrint:Say(350,1830,"Data Geração:",oFont08n,,CLR_BLACK)            
	oPrint:Say(350,2050,DTOC(DATE()),oFont08,,CLR_BLACK)
	oPrint:Say(390,1830,"Hora Geração:",oFont08n,,CLR_BLACK)            
	oPrint:Say(390,2050,Alltrim(TIME()),oFont08,,CLR_BLACK) 
	oPrint:Say(430,1830,"Colaborador:",oFont08n,,CLR_BLACK)            
	oPrint:Say(430,2050,ALLTRIM(cUserName),oFont08,,CLR_BLACK) 
	
	//Impressão do cabeçalho das colunas                                           
  	nLinha:=600
   	oPrint:Say(nLinha,0100,"CODIGO"				,oFont09cn,,CLR_BLACK)
	oPrint:Say(nLinha,0360,"DESC. MATERIAL"		,oFont09cn,,CLR_BLACK)//505
	oPrint:Say(nLinha,1015,"UM"					,oFont09cn,,CLR_BLACK)//1550
	oPrint:Say(nLinha,1120,"QTDE."				,oFont09cn,,CLR_BLACK)//1640
	oPrint:Say(nLinha,1280,"AMZ "				,oFont09cn,,CLR_BLACK)//1870
	oPrint:Say(nLinha,1368,"Dt.Lib."			,oFont09cn,,CLR_BLACK)
	oPrint:Say(nLinha,1590,"PESO L."			,oFont09cn,,CLR_BLACK)//2035
	oPrint:Say(nLinha,1770,"PESO L.TOT"			,oFont09cn,,CLR_BLACK)//2190
	oPrint:Say(nLinha,2010,"PESO B."			,oFont09cn,,CLR_BLACK)
	oPrint:Say(nLinha,2175,"PESO B.TOT"			,oFont09cn,,CLR_BLACK)

	oPrint:Say(3350,2100,"Pagina "+AllTrim(str(nPagina))+"/"+(Alltrim(str(nTotal))),oFont5,,CLR_BLACK)

	nLinha := 700

	If nTipoPick == 1
		oPrint:SayBitmap(nLinha,110,"\System\PREVIA.PNG",2270,2430) 
	EndIf

End Sequence                                          

Return  

*----------------------------------*
Static Function ReportDetail(oPrint)   
*----------------------------------*   
//Imprime os dados das colunas   	   			   	   

Local sDesc := ""
Local nDesc := 0
Local nIni 	:= 1
Local nFin 	:= 35 

oPrint:Say(nLinha,0105,Alltrim(SQL->B1_COD),oFont08c,,CLR_BLACK)

//JSS - 22/08/2014 - Criado tratamento para infromar o nome do produto completo(B1_DESC) e sua descrição tecnica(B5_CEME)  
//Inicio
nLinha2	:= nLinha
If Len(AllTrim(SQL->B1_DESC)) >= 30
	SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
	If SB5->(DbSeek(xFilial("SB5")+SQL->B1_COD))
			sDesc:= AllTrim(SQL->B1_DESC) +" "+ AllTrim(SB5->B5_CEME)  
			nDesc:= Len(sDesc)
			
		   	While nDesc >= 0
				oPrint:Say(nLinha2,0365,SubStr(sDesc,nIni,nFin),oFont08c,,CLR_BLACK)
				
				nLinha2	+=30
				nIni	+=35 
				nDesc	-=35
				
			EndDo
	Else	
			sDesc:= AllTrim(SQL->B1_DESC)  
			nDesc:= Len(sDesc)
						
			While nDesc >= 0
				oPrint:Say(nLinha2,0365,SubStr(sDesc,nIni,nFin),oFont08c,,CLR_BLACK)
				
				nLinha2	+=30
				nIni	+=35 
				nDesc	-=35
				
			EndDo 	 
	EndIf 
Else
	oPrint:Say(nLinha,0365,SubStr(SQL->B1_DESC,1,35),oFont08c,,CLR_BLACK)	 
EndIF
//Fim

oPrint:Say(nLinha,1010,Alltrim(SQL->B1_UM),oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1082,PADL(AllTrim (Transform(SQL->C9_QTDLIB	,"@R 99,999.99")),10),oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1285,Alltrim(SQL->C9_LOCAL),oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1360,DTOC(SQL->C9_DATALIB),oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1550,PADL(AllTrim (Transform(SQL->B1_PESO		,"@R 99,999.99"))			   ,10)	,oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1788,PADL(AllTrim (Transform((SQL->B1_PESO*SQL->C9_QTDLIB),"@R 99,999.99"))  ,10)	,oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1980,PADL(AllTrim (Transform(SQL->B1_PESBRU	,"@R 99,999.99"))			   ,10)	,oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,2190,PADL(AllTrim (Transform((SQL->B1_PESBRU*SQL->C9_QTDLIB),"@R 99,999.99")),10)	,oFont08c,,CLR_BLACK)
	
nTotQtdLib	+= SQL->C9_QTDLIB
nTotPesoL	+= SQL->B1_PESO
nTotPesoLT	+= (SQL->B1_PESO*SQL->C9_QTDLIB)
nTotPesoB	+= SQL->B1_PESBRU
nTotPesoBT	+= (SQL->B1_PESBRU*SQL->C9_QTDLIB)

If nTipoPick == 2 .and. SC9->(FieldPos("C9_P_PICK")) <> 0
	SC9->(dbSetOrder(1))
	SC9->(DbGoTo(SQL->RECSC9))
	SC9->(RecLock("SC9",.F.))
	SC9->C9_P_PICK := "S"
	
    If cAux <>  SC9->C9_PEDIDO 
		nAux := PickNumber()
		cAux :=SC9->C9_PEDIDO 
		SC9->C9_P_ID   := nAux 
	Else
		SC9->C9_P_ID   := nAux 
	EndIF	 
	
	
	SC9->(MsUnlock())
EndIf 


Return

*----------------------------------*
Static Function ReportTotal(oPrint)   
*----------------------------------*   
oPrint:Line(nLinha-5,110,nLinha-5,2380)    //Cabeçalho das colunas
oPrint:Say(nLinha,0105,"TOTAIS:",oFont08c,,CLR_BLACK)
oPrint:Say(nLinha,1132,PADL(AllTrim (Transform(nTotQtdLib	,"@R 9,999,999.99")),10),oFont08n,,CLR_BLACK)
oPrint:Say(nLinha,1600,PADL(AllTrim (Transform(nTotPesoL	,"@R 9,999,999.99")),10),oFont08n,,CLR_BLACK)
oPrint:Say(nLinha,1838,PADL(AllTrim (Transform(nTotPesoLT	,"@R 9,999,999.99")),10),oFont08n,,CLR_BLACK)
oPrint:Say(nLinha,2030,PADL(AllTrim (Transform(nTotPesoB	,"@R 9,999,999.99")),10),oFont08n,,CLR_BLACK)
oPrint:Say(nLinha,2240,PADL(AllTrim (Transform(nTotPesoBT	,"@R 9,999,999.99")),10),oFont08n,,CLR_BLACK)

nTotQtdLib	:= 0
nTotPesoL	:= 0
nTotPesoLT	:= 0
nTotPesoB	:= 0
nTotPesoBT	:= 0

nLinha	+=	50

Return

*------------------------------*
Static Function BoxGeral(oPrint)   
*------------------------------*
Local L:= 1420
Private oPen := TPen():New(,7,CLR_BLACK)     

Begin Sequence 
   oPrint:Box(155,90,530,650)      //Logo  
   oPrint:Box(155,670,530,2400)    //Titulo do documento                                       
   oPrint:Box(570,90,3150,2400)    //Detalhes                                           
   oPrint:Line(670,90,670,2400)    //Cabeçalho das colunas
End Sequence

Return

*-------------------------*             
Static Function GeraExcel()
*-------------------------*
Local lLibP 	:= .F.
Local nPos 		:= 0
Local nModel	:= 0
Local aWork  	:= {}
                
Private oExcelApp

If Select("WORK") > 0
   WORK->(DbCloseArea())
EndIf  

If (SC9->(FieldPos("C9_P_ID")) > 0)

	aCampos := {   	{"PEDIDO"  ,"C",06,0  } ,;     
				   	{"ID"      ,"N",06,0  } ,; 
        			{"TIPO"    ,"C",15,0  } ,;
           			{"SEQ"     ,"C",03,0  } ,;
              		{"EMISSAO" ,"D",10,0  } ,;   
              		{"LIBERAC" ,"D",10,0  } ,;  
               		{"PRODUTO" ,"C",15,0  } ,;
               		{"DESCRIC" ,"C",230,0 } ,; //JSS Alterado de {"DESCRIC" ,"C",100,0 } ,;
               		{"UM"      ,"C",02,0  } ,;
               		{"ARMAZ"   ,"C",02,0  } ,;
               		{"PESO_UNI","N",10,2  } ,;
               		{"PESO_BRU","N",10,2  } ,;
               		{"QTD"     ,"N",10,2  } ,;
               		{"CODCLI"  ,"C",06,0  } ,; 
               		{"NOME"    ,"C",40,0  } ,; 
               		{"CIDADE"  ,"C",25,0  } ,;
               		{"ESTADO"  ,"C",02,0  } ,;             
               		{"ENDERC"  ,"C",30,0  } ,;
               		{"CEP"     ,"C",08,0  } ,;    
               		{"BAIRRO"  ,"C",30,0  } ,;
               		{"CGC"     ,"C",14,0  } ,;
			   		{"INSCRC"  ,"C",18,0  } } 
nModel := 1
Else 

	aCampos := {   	{"PEDIDO"  ,"C",06,0  } ,;     
        			{"TIPO"    ,"C",15,0  } ,;
           			{"SEQ"     ,"C",03,0  } ,;
              		{"EMISSAO" ,"D",10,0  } ,;   
              		{"LIBERAC" ,"D",10,0  } ,;  
               		{"PRODUTO" ,"C",15,0  } ,;
               		{"DESCRIC" ,"C",230,0 } ,; //JSS Alterado de {"DESCRIC" ,"C",100,0 } ,;
               		{"UM"      ,"C",02,0  } ,;
               		{"ARMAZ"   ,"C",02,0  } ,;
               		{"PESO_UNI","N",10,2  } ,;
               		{"PESO_BRU","N",10,2  } ,;
               		{"QTD"     ,"N",10,2  } ,;
               		{"CODCLI"  ,"C",06,0  } ,; 
               		{"NOME"    ,"C",40,0  } ,; 
               		{"CIDADE"  ,"C",25,0  } ,;
               		{"ESTADO"  ,"C",02,0  } ,;             
               		{"ENDERC"  ,"C",30,0  } ,;
               		{"CEP"     ,"C",08,0  } ,;    
               		{"BAIRRO"  ,"C",30,0  } ,;
               		{"CGC"     ,"C",14,0  } ,; 
               		{"ID"      ,"N",06,0  } ,; 
			   		{"INSCRC"  ,"C",18,0  } } 
               
EndIf

               
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,__LOCALDRIVER,cNome,"WORK",.F.,.F.)


cIndex := CriaTrab(Nil,.F.)
IndRegua("WORK",cIndex,"WORK->PEDIDO",,,"Selecionando Registro...")

DbSelectArea("WORK")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1) 

DbSelectArea("SQL2")                              
SQL2->(DbGoTop()) 
Do While SQL2->(!Eof())  

    RecLock("WORK",.T.)
	WORK->PEDIDO   := SQL2->C9_PEDIDO  
  
	If (SC9->(FieldPos("C9_P_ID")) > 0)
		If nTipoPick == 2
			WORK->ID       := nAux	
		Else
			WORK->ID       := SQL2->C9_P_ID	
		EndIf
	EndIF

	//TLM - Se possuir pelo menos um item bloqueado o pedido é parcial
	For i=1 to Len(aLibP) 
		If (aLibP[i][2])
			lLibP := aLibP[i][2]
   		EndIf	
	Next  
	
	WORK->TIPO := IIF(lLibP,"PARCIAL","TOTAL")
	WORK->EMISSAO  := SQL2->C5_EMISSAO 
	WORK->LIBERAC  := SQL2->C9_DATALIB
	WORK->PRODUTO  := SQL2->B1_COD
	WORK->SEQ      := SQL2->C9_ITEM                                   
	//JSS
	SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
	If SB5->(DbSeek(xFilial("SB5")+SQL2->B1_COD))
			sDesc:= AllTrim(SQL2->B1_DESC) +" "+ AllTrim(SB5->B5_CEME)
	Else
	     	sDesc:= AllTrim(SQL2->B1_DESC)
	EndIf
	
	WORK->DESCRIC  := sDesc //JSS 
	WORK->UM       := SQL2->B1_UM  
	WORK->ARMAZ    := SQL2->C9_LOCAL
	WORK->PESO_UNI := SQL2->B1_PESO
	WORK->PESO_BRU := SQL2->B1_PESBRU
	WORK->QTD      := SQL2->C9_QTDLIB
	WORK->CODCLI   := SQL2->C5_CLIENT
	WORK->NOME     := SQL2->A1_NOME
	WORK->CIDADE   := SQL2->A1_END
	WORK->ESTADO   := SQL2->A1_EST            
	WORK->ENDERC   := SQL2->A1_END
	WORK->CEP      := SQL2->A1_CEP
	WORK->BAIRRO   := SQL2->A1_BAIRRO
	WORK->CGC      := SQL2->A1_CGC
	WORK->INSCRC   := SQL2->A1_INSCR
    WORK->(MsUnlock())
	SQL2->(DbSkip())   
EndDo  

//AOA - 07/12/2018 - Ajuste feito para fazer a correção da planilha excel para versão 12
DbselectArea("WORK") 
WORK->(DbGoTop())
 
//cNomeArq := "TMFAT001-"+cValtoChar(WORK->PEDIDO)
//cArqOrig 	:= "\SYSTEM\"+cNome+".DBF"
//cPath       := AllTrim(GetTempPath())                                                   
//CpyS2T( cArqOrig , cPath, .T. )
cArqOrig := cGetFile( '*.*' , 'Selecionar Pasta', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),.T., .T. )
cArqOrig += cNome+".XLS"
                              
If ApOleClient("MsExcel")
     //Previa não gera Excel
    If !(nTipoPick == 1)//Previa
		oExcelApp := FwMsExcel():New()
	    oExcelApp:AddworkSheet(cNome)
    	oExcelApp:AddTable(cNome,cNome)
        
        For i := 1 to len (aCampos)
        	oExcelApp:AddColumn(cNome,cNome,aCampos[i][1],1,1,.F.)	
        Next i
		If nModel == 1
        	While WORK->(!Eof())  
	        	oExcelApp:AddRow(cNome,cNome,{WORK->PEDIDO  ,;
											WORK->ID      ,;
											WORK->TIPO	  ,;
											WORK->SEQ     ,;
											WORK->EMISSAO ,;
											WORK->LIBERAC ,;
											WORK->PRODUTO ,;
											WORK->DESCRIC ,;
											WORK->UM      ,;
											WORK->ARMAZ   ,;
											WORK->PESO_UNI,;
											WORK->PESO_BRU,;
											WORK->QTD     ,;
											WORK->CODCLI  ,;
											WORK->NOME    ,;
											WORK->CIDADE  ,;
											WORK->ESTADO  ,;
											WORK->ENDERC  ,;
											WORK->CEP     ,;
											WORK->BAIRRO  ,;
											WORK->CGC     ,;
											WORK->INSCRC  })	
	        	WORK->(DbSkip())   
			EndDo  
		Else
			While WORK->(!Eof())  
	        	oExcelApp:AddRow(cNome,cNome,{WORK->PEDIDO  ,;
											WORK->TIPO	  ,;
											WORK->SEQ     ,;
											WORK->EMISSAO ,;
											WORK->LIBERAC ,;
											WORK->PRODUTO ,;
											WORK->DESCRIC ,;
											WORK->UM      ,;
											WORK->ARMAZ   ,;
											WORK->PESO_UNI,;
											WORK->PESO_BRU,;
											WORK->QTD     ,;
											WORK->CODCLI  ,;
											WORK->NOME    ,;
											WORK->CIDADE  ,;
											WORK->ESTADO  ,;
											WORK->ENDERC  ,;
											WORK->CEP     ,;
											WORK->BAIRRO  ,;
											WORK->CGC     ,;
											WORK->ID      ,;
											WORK->INSCRC  })	
	        	WORK->(DbSkip())   
			EndDo  
		EndIf
		
		oExcelApp:Activate() 
		oExcelApp:GetXMLFile( cArqOrig )
		
		//oExcelApp:=MsExcel():New()
  		//oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
   		//oExcelApp:SetVisible(.T.)   
	EndIf
Else 
	Alert("Excel não instalado") 
EndIf    

DbSelectArea("SQL2")


DbCloseArea("SQL2") 
DbCloseArea("WORK") 

Erase &cNome+".DBF"  

Return    

*--------------------------*
Static Function PickNumber()   
*---------------------------*
 
If Select("IDSC9") > 0
	IDSC9->(dbCloseArea())
EndIf                        

cQuery := "SELECT max(C9_P_ID)+ 1 AS NUM"+Chr(10)
cQuery += " FROM "+RetSqlName("SC9")+Chr(10)
cQuery += " WHERE"
cQuery += " D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "IDSC9" NEW

Return IDSC9->NUM    