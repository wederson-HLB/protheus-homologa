#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"

/*
Funcao      : XCFAT001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar planilha com dados de vendas baseado nas notas de saída do sistema.
Autor     	: Tiago Luiz Mendonça
Data     	: 13/02/2013                       
Obs         : 
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Faturamento 
Cliente     : Dialogic
*/

*-------------------------*
 User Function XCFAT001()
*-------------------------*  
                              
                       
                       
Private nLin     := 100  	                                  
Private nZeros   := 1 
Private nGera    := 1
Private nTipo    := 1
Private nCntImpr := 0

Private cNome    := ""
Private cIndex   := ""
Private cCabec1  := ""
Private cCabec2  := ""
Private cFil     := ""
Private cArqOrig := ""
Private cArqPath := ""
Private cTes     := ""
Private cPerg    := "XCFAT001"

Private dDataIni
Private dDataFim

Private aCampos  := {}

If !(cEmpAnt $ "XC/KX")
   MsgAlert("Rotina não disponivel para essa empresa","Atenção")
   Return .F.
EndIf                 

If !(pergunte(cPerg,.T.))
	Return
EndIf
        
dbSelectArea("SX6")
cTes     := GetMv("MV_P_TESRE", .F. ,  )      

nZeros   := mv_par03  
nGera    := mv_par04 
nTipo    := mv_par05 
 
If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf  

If nZeros == 1
	 
	aCampos := { {"cust_numb"      ,"C" ,06,0 } ,;
		     	 {"cust_name"      ,"C" ,40,0 } ,;
	             {"trx_type"       ,"C" ,04,0 } ,;
	             {"trans_date"     ,"D" ,10,0 } ,;           
	             {"trx_number"     ,"C" ,09,0 } ,;
	             {"order_type"     ,"C" ,15,0 } ,;
	             {"order_numb"     ,"C" ,06,0 } ,;
	             {"order_line"     ,"C" ,03,0 } ,;
		         {"po_number"      ,"C" ,15,0 } ,;
	             {"item_numbe"     ,"C" ,15,0 } ,;
	             {"item_descr"     ,"C" ,50,0 } ,;
	             {"ordered_qu"     ,"N" ,09,02} ,;
	             {"currency_c"     ,"C" ,07,0 } ,;
	             {"ex_rate"        ,"N" ,08,02} ,;
	             {"quantity"       ,"N" ,12,02} ,;
	             {"unit_selli"     ,"N" ,12,02} ,;
	             {"order_sell"     ,"N" ,12,02} ,;
	             {"order_tota"     ,"N" ,12,02} ,;
			     {"creation_d"     ,"D" ,10,0 } ,;  		     
			     {"promise_da"     ,"D" ,10,0 } ,;  
			     {"requested_"     ,"C" ,03,0 } ,;  
			     {"term_name"      ,"C" ,03,0 } ,;  
			     {"waybill"        ,"C" ,15,0 } ,;  	
			     {"org_id"         ,"C" ,03,0 } ,;            
			     {"line_type"      ,"C" ,04,0 } ,; 
	             {"IRRF_PIS_C"     ,"N" ,12,2 } ,;
	             {"ISS"            ,"N" ,12,2 } ,;
	             {"IPI"            ,"N" ,12,2 } ,;
	   	    	 {"ICMS"           ,"N" ,12,2 } ,; 
	   	    	 {"TypeofSale"     ,"C" ,10,0 } ,; 
	             {"Acceptance"     ,"D" ,10,0 } ,;      
	             {"ContractNu"     ,"C" ,20,0 } ,; 
	             {"ProposalNU"     ,"C" ,20,0 } ,; 
	             {"ShipDate"       ,"D" ,10,0 } ,;   
	             {"PaymentTer"     ,"C" ,15,0 }}  
	               
Else

  	aCampos := { {"cust_numb"      ,"C" ,06,0 } ,;
		     	 {"cust_name"      ,"C" ,40,0 } ,;
	             {"trx_type"       ,"C" ,10,0 } ,;
	             {"trans_date"     ,"D" ,10,0 } ,;           
	             {"trx_number"     ,"C" ,09,0 } ,;
	             {"order_type"     ,"C" ,15,0 } ,;
	             {"order_numb"     ,"C" ,06,0 } ,;
	             {"order_line"     ,"C" ,03,0 } ,;
		         {"po_number"      ,"C" ,15,0 } ,;
	             {"item_numbe"     ,"C" ,15,0 } ,;
	             {"item_descr"     ,"C" ,50,0 } ,;
	             {"ordered_qu"     ,"C" ,09,0 } ,;
	             {"currency_c"     ,"C" ,07,0 } ,;
	             {"ex_rate"        ,"C" ,08,0 } ,;
	             {"quantity"       ,"C" ,12,0 } ,;
	             {"unit_selli"     ,"C" ,12,0 } ,;
	             {"order_sell"     ,"C" ,12,0 } ,;
	             {"order_tota"     ,"C" ,12,0 } ,;
			     {"creation_d"     ,"D" ,10,0 } ,;  		     
			     {"promise_da"     ,"D" ,03,0 } ,;  
			     {"requested_"     ,"C" ,03,0 } ,;  
			     {"term_name"      ,"C" ,03,0 } ,;  
			     {"waybill"        ,"C" ,15,0 } ,;  	
			     {"org_id"         ,"C" ,03,0 } ,;            
			     {"line_type"      ,"C" ,04,0 } ,; 
	             {"IRRF_PIS_C"     ,"C" ,12,0 } ,;
	             {"ISS"            ,"C" ,12,0 } ,;
	             {"IPI"            ,"C" ,12,0 } ,;
	   	    	 {"ICMS"           ,"C" ,12,0 } ,; 
	   	    	 {"TypeofSale"     ,"C" ,10,0 } ,; 
	             {"Acceptance"     ,"D" ,10,0 } ,;      
	             {"ContractNu"     ,"C" ,20,0 } ,; 
	             {"ProposalNU"     ,"C" ,20,0 } ,; 
	             {"ShipDate"       ,"D" ,10,0 } ,;   
	             {"PaymentTer"     ,"C" ,15,0 }}  

     

	EndIf


//cNome  := CriaTrab(aCampos,.t.)
//RRP - 06/03/2019 - Ajuste para gerar em DBF o relatorio
cNome  := CriaTrab(Nil,.F.)
dbCreate(cNome,aCampos,"DBFCDXADS" ) 
dbUseArea(.T.,"DBFCDXADS",cNome,"WORK",.F.,.F.)


DbSelectArea("WORK")
cIndex:=CriaTrab(Nil,.F.)
IndRegua("WORK",cIndex,"TRX_NUMBER+ITEM_NUMBE",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

  
tamanho  :=	'G'
limite   :=	220
titulo   :=	"Relatorio de vendas"
cDesc1   :=	' '
cDesc2   :=	''
cDesc3   :=	'Impressao em formulario de 220 colunas.'
aReturn  := { 'Zebrado', 1,'Faturamento', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
nLin     := 60
m_pag    := 1
aOrd     := {}
wnRel    := 'XCFAT001'
NomeProg := 'XCFAT001'
cTipo    := ""

// Variaveis utilizadas para Impressao do Cabecalho e Rodape
cString  := "SQL"
cCabec1   := "Cliente                      Emissao   Nota       Purchase          Produto        QTD     Vlr.Unit   Vlr.Total Type   P/IR/C    Iss     Ipi       Icms       Acceptance       Contract        Proposal        Payment term" 
//            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
cCabec2:=""
                    
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho) 

If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
	Return
Endif
         
SetDefault(aReturn,cString)

If LastKey()== 27 .Or. nLastKey==27
   dbSelectArea("WORK")
   DbCloseArea("WORK")
   Return
Endif

RptStatus({|| GeraDados()},Titulo)

//Set Device To Screen

If aReturn[5] == 1  
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

Ms_Flush()
             
Return .T.   

*----------------------------*
  Static Function GeraDados()
*----------------------------*
        
Local cAux     := "" 
Local cVal     := ""  

Local nAux	   := 0
Local nValIRRF := 0

Titulo := Titulo + ", de "+dtoc(mv_par01) + " a "+dtoc(mv_par02)

dDataIni  := mv_par01
dDataFim  := mv_par02  
          
cFil:=CFILANT 
                    
MontaQry1()  

QRB->(DbGoTop())
                  
If QRB->(Eof())
	MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
	QRB->(DbCloseArea())
	WORK->(DbCloseArea())
 	Return .F.
EndIf 
      
//Grava primeiro a linha de itens sem impostos     
Do While QRB->(!Eof())  
                   
	// Execeções para TES
    // WFA - 22/05/2018 - Inclusão de CFOPs de Exportação. Ticket: #35083
 	If !((QRB->D2_TES $ cTES) .OR. (SUBSTR(QRB->D2_CF, 0, 1) == "7"))
  		QRB->(DbSkip())
		loop
  	Endif 
         
   	SC5->(DbSetOrder(1))  
    SC5->(DbSeek(xFilial()+QRB->C6_NUM))
    
	SA1->(DbSetOrder(1))  
    SA1->(DbSeek(xFilial()+QRB->D2_CLIENTE+QRB->D2_LOJA))
   
	SB1->(DbSetOrder(1))
 	SB1->(DbSeek(xFilial()+QRB->D2_COD))
   
	SE4->(DbSetOrder(1))
 	SE4->(DbSeek(xFilial()+SC5->C5_CONDPAG))

	SF4->(DbSetOrder(1))
 	SF4->(DbSeek(xFilial()+QRB->D2_TES))
    
    /* Execeções para tipo                             
    	
		1=Hardware;
		2=Software;
		3=Service;
		4=Supply                                                                                        
    	5-Todos    
    
    */
 	
 	If nTipo <> 5   // Todos 
 		If Alltrim(Str(nTipo)) <> alltrim(SC5->C5_P_TIP)
  			QRB->(DbSkip())
			loop
  		EndIF
  	Endif     
       
    	 
    RecLock("Work",.T.)
	Work->CUST_NUMB     := QRB->D2_CLIENTE      
  	Work->CUST_NAME     := QRB->A1_NOME 
 	Work->TRX_NUMBER    := QRB->D2_DOC                          
 	Work->PO_NUMBER     := SC5->C5_P_PO  
 	Work->ORDER_TYPE    := SC5->C5_P_TPORD
 	Work->WAYBILL       := SC5->C5_P_WAYB   
 	Work->TRX_TYPE      := QRB->D2_CF 
	Work->ORDER_NUMB    := SC5->C5_NUM 	
	Work->ORDER_LINE    := QRB->D2_ITEM	
   	Work->TRANS_DATE    := STOD(QRB->D2_EMISSAO)  
   	Work->CREATION_D    := SC5->C5_EMISSAO    
	Work->SHIPDATE      := SC5->C5_P_DTS 

            	
 	If Alltrim(SC5->C5_P_TIP)  == "1"
 		Work->TYPEOFSALE := "Hardware"                 
	ElseIf Alltrim(SC5->C5_P_TIP) == "2"
 		Work->TYPEOFSALE := "Software"      
	ElseIf Alltrim(SC5->C5_P_TIP) == "3"
 		Work->TYPEOFSALE := "Service"    
	ElseIf Alltrim(SC5->C5_P_TIP) == "4"
 		Work->TYPEOFSALE:= "Supply"    
    ElseIf Empty(Alltrim(SC5->C5_P_TIP)) 
  		Work->TYPEOFSALE := ""     
    EndIf 
	
	Work->ITEM_NUMBE 	:= QRB->D2_COD
 	Work->ITEM_DESCR    := SB1->B1_DESC 
   	Work->ORG_ID        := "398"
    Work->LINE_TYPE     := "LINE"

   // If Empty(SC5->C5_P_ACCDT)
   //		Work->ACCEPTANCE    := ""
//	Else	
		Work->ACCEPTANCE    := SC5->C5_P_ACCDT     
  //  EndIf
  
    Work->CONTRACTNU    := SC5->C5_P_CONTR 
    Work->PROPOSALNU    := SC5->C5_P_PROP
    Work->CURRENCY_C    := SC5->C5_P_MOED    
    Work->PAYMENTTER    := SE4->E4_DESCRI
	
	
	If nZeros == 1                          
	
		Work->EX_RATE      := SC5->C5_P_TX 	
	   	Work->QUANTITY     := QRB->D2_QUANT  
	    Work->UNIT_SELLI   := QRB->D2_PRCVEN     
	    Work->ORDER_SELL   := QRB->D2_TOTAL-QRB->D2_VALICM-QRB->D2_VALIPI-QRB->D2_VALCOF-QRB->D2_VALCSL-QRB->D2_VALISS-QRB->D2_VALPIS
	    Work->ORDER_TOTA   := QRB->D2_TOTAL 
	    Work->IRRF_PIS_C   := 00.00 
		Work->ISS          := 00.00 
		Work->IPI          := 00.00 
		Work->ICMS         := 00.00 	
	
	Else  


		cVal   	   		:=	Alltrim(Transform(SC5->C5_P_TX ,"@E 99999999.99")) 
		nPos	   		:=	At(",",Alltrim(cVal))   
		Work->EX_RATE  	:= 	Stuff(cVal,nPos,1,".") 
                               
		cVal   	   		:=	Alltrim(Transform(QRB->D2_QUANT,"@E 99999999.99")) 
		nPos	   		:=	At(",",Alltrim(cVal))   
		Work->QUANTITY 	:= 	Stuff(cVal,nPos,1,".") 
		
		cVal 			:=	Alltrim(Transform(QRB->D2_PRCVEN,"@E 99999999.99")) 
		nPos	   		:=	At(",",Alltrim(cVal))   
		Work->UNIT_SELLI  :=  Stuff(cVal,nPos,1,".")     
                        
		nAux            :=  QRB->D2_TOTAL-QRB->D2_VALICM-QRB->D2_VALIPI-QRB->D2_VALCOF-QRB->D2_VALCSL-QRB->D2_VALISS-QRB->D2_VALPIS
		cVal 			:=	Alltrim(Transform(nAux,"@E 99999999.99")) 
		nPos	   		:=	At(",",Alltrim(cVal))   
		Work->ORDER_SELL :=  Stuff(cVal,nPos,1,".") 
		
		cVal 			:=	Alltrim(Transform(QRB->D2_TOTAL,"@E 99999999.99")) 
		nPos	   		:=	At(",",Alltrim(cVal))   
		Work->ORDER_TOTA:=  Stuff(cVal,nPos,1,".") 
	    
	    Work->IRRF_PIS_C:= "00.00" 
		Work->ISS       := "00.00" 
		Work->IPI       := "00.00" 
		Work->ICMS      := "00.00" 		
	
	EndIf
	
	Work->(MsUnLock())    
      
 	QRB->(DbSkip())       
      
EndDo   


//Grava linha dos impostos
QRB->(DbGoTop()) 

Do While QRB->(!Eof())  
                   
	// Execeções para TES
	// WFA - 22/05/2018 - Inclusão de CFOPs de Exportação. Ticket: #35083
 	If !((QRB->D2_TES $ cTES) .OR. (SUBSTR(QRB->D2_CF, 0, 1) == "7"))
  		QRB->(DbSkip())
		loop
  	Endif 
         
   	SC5->(DbSetOrder(1))  
    SC5->(DbSeek(xFilial()+QRB->C6_NUM))
    
	SA1->(DbSetOrder(1))  
    SA1->(DbSeek(xFilial()+QRB->D2_CLIENTE+QRB->D2_LOJA))
   
	SB1->(DbSetOrder(1))
 	SB1->(DbSeek(xFilial()+QRB->D2_COD))
   
	SE4->(DbSetOrder(1))
 	SE4->(DbSeek(xFilial()+SC5->C5_CONDPAG))

	SF4->(DbSetOrder(1))
 	SF4->(DbSeek(xFilial()+QRB->D2_TES))
    
    /* Execeções para tipo                             
    	
		1=Hardware;
		2=Software;
		3=Service;
		4=Supply                                                                                        
    	5-Todos    
    
    */
 	
 	If nTipo <> 5   // Todos 
 		If Alltrim(Str(nTipo)) <> alltrim(SC5->C5_P_TIP)
  			QRB->(DbSkip())
			loop
  		EndIF
  	Endif     
        	 
    RecLock("Work",.T.)
	Work->CUST_NUMB     := QRB->D2_CLIENTE      
  	Work->CUST_NAME     := QRB->A1_NOME 
 	Work->TRX_NUMBER    := QRB->D2_DOC                          
 	Work->PO_NUMBER     := SC5->C5_P_PO  
 	Work->ORDER_TYPE    := SC5->C5_P_TPORD 
 	Work->WAYBILL       := SC5->C5_P_WAYB
 	Work->TRX_TYPE      := QRB->D2_CF 
	Work->ORDER_NUMB    := SC5->C5_NUM 	
	Work->ORDER_LINE    := QRB->D2_ITEM
   	Work->TRANS_DATE    := STOD(QRB->D2_EMISSAO)  
   	Work->CREATION_D    := SC5->C5_EMISSAO    
	Work->SHIPDATE      := SC5->C5_P_DTS    	
  
  	
 	If Alltrim(SC5->C5_P_TIP)  == "1"
 		Work->TYPEOFSALE := "Hardware"                 
	ElseIf Alltrim(SC5->C5_P_TIP) == "2"
 		Work->TYPEOFSALE := "Software"      
	ElseIf Alltrim(SC5->C5_P_TIP) == "3"
 		Work->TYPEOFSALE := "Service"    
	ElseIf Alltrim(SC5->C5_P_TIP) == "4"
 		Work->TYPEOFSALE := "Supply"    
    ElseIf Empty(Alltrim(SC5->C5_P_TIP)) 
  		Work->TYPEOFSALE := ""     
    EndIf 


	Work->ITEM_NUMBE    := QRB->D2_COD
 	Work->ITEM_DESCR	:= SB1->B1_DESC 
   	Work->ORG_ID        := "398"
    Work->LINE_TYPE     := "TAX"            
   	Work->ACCEPTANCE    := SC5->C5_P_ACCDT        
  
    Work->CONTRACTNU    := SC5->C5_P_CONTR 
    Work->PROPOSALNU    := SC5->C5_P_PROP     
    Work->CURRENCY_C    := SC5->C5_P_MOED
    Work->PAYMENTTER    := SE4->E4_DESCRI
 	Work->TRX_TYPE      := QRB->D2_CF 
 		
	//Valor IRRF disponivel apenas no SF2
	If QRB->F2_VALIRRF <> 0
		nAux     := COUNT(QRB->D2_DOC,QRB->D2_SERIE,QRB->D2_CLIENTE,QRB->D2_LOJA)	 		
		//Rateia entre os itens
		nValIRRF := (QRB->F2_VALIRRF/val(nAux))
		DbCloseArea("SQL") 
	EndIf	
	
	If nZeros == 1                  
	   	           
		Work->EX_RATE       := SC5->C5_P_TX 	
	   	Work->QUANTITY      := QRB->D2_QUANT 
	    Work->UNIT_SELLI    := 0 //QRB->D2_PRCVEN     
	    Work->ORDER_SELL    := 0 //QRB->D2_TOTAL-QRB->D2_VALICM-QRB->D2_VALIPI-QRB->D2_VALCOF-QRB->D2_VALCSL-QRB->D2_VALISS
	    Work->ORDER_TOTA    := QRB->D2_VALICM+QRB->D2_VALIPI+QRB->D2_VALCOF+QRB->D2_VALCSL+QRB->D2_VALISS+QRB->D2_VALPIS+nValIRRF
	    Work->IRRF_PIS_C    := QRB->D2_VALPIS + QRB->D2_VALCOF + QRB->D2_VALCSL + nValIRRF
		Work->ISS           := QRB->D2_VALISS
		Work->IPI           := QRB->D2_VALIPI
		Work->ICMS          := QRB->D2_VALICM 
		      
	Else    
	
		cVal   	   		 := Alltrim(Transform(SC5->C5_P_TX ,"@E 99999999.99")) 
		nPos	   		 := At(",",Alltrim(cVal))   
		Work->EX_RATE  	 := Stuff(cVal,nPos,1,".") 
	
		Work->QUANTITY 	 := "00.00"
		
		Work->UNIT_SELLI := "00.00"  

		Work->ORDER_SELL :=  "00.00"
		
		cVal 			 :=  Alltrim(Transform(QRB->D2_VALICM+QRB->D2_VALIPI+QRB->D2_VALCOF+QRB->D2_VALCSL+QRB->D2_VALISS+QRB->D2_VALPIS+nValIRRF,"@E 99999999.99")) 
		nPos	   		 :=	At(",",Alltrim(cVal))   
		Work->ORDER_TOTA :=  Stuff(cVal,nPos,1,".") 

		cVal 			 :=	Alltrim(Transform(QRB->D2_VALPIS+QRB->D2_VALCOF+QRB->D2_VALCSL+nValIRRF,"@E 99999999.99")) 
		nPos	   		 :=	At(",",Alltrim(cVal))   	    
	    Work->IRRF_PIS_C :=  Stuff(cVal,nPos,1,".") 
			
		cVal 			 :=	Alltrim(Transform(QRB->D2_VALISS,"@E 99999999.99")) 
		nPos	   		 :=	At(",",Alltrim(cVal))  		
		Work->ISS        :=  Stuff(cVal,nPos,1,".") 
		
		cVal 			 :=	Alltrim(Transform(QRB->D2_VALIPI,"@E 99999999.99")) 
		nPos	   		 :=	At(",",Alltrim(cVal)) 
		Work->IPI        :=  Stuff(cVal,nPos,1,".")  

		cVal 			 :=	Alltrim(Transform(QRB->D2_VALICM ,"@E 99999999.99")) 
		nPos	   		 :=	At(",",Alltrim(cVal)) 		
		Work->ICMS       :=  Stuff(cVal,nPos,1,".") 
	
	EndIf
	
	Work->(MsUnLock())    
      
 	QRB->(DbSkip())       
      
EndDo 
    
nLin += 100

Work->(dbGoTop())

If  Work->(Eof())
	Msginfo("Nenhum da encontrado, verifique os paramentros","Dialogic")  
	DbCloseArea("WORK") 
	DbCloseArea("QRB") 	
	Return .F.
EndIf


Do while Work->(!Eof()) 

   SomaLin()
   
   If nZeros == 1    
   
	   @ nLin,000 PSAY Work->CUST_NUMB
	   @ nLin,007 PSAY Work->CUST_NAME
	   @ nLin,030 PSAY alltrim(Work->TRANS_DATE)
	   @ nLin,040 PSAY Work->TRX_NUMBER 
	   @ nLin,054 PSAY Work->PO_NUMBER
	   @ nLin,069 PSAY Work->ITEM_NUMBE 	
	   @ nLin,081 PSAY Work->QUANTITY 	        picture    "@E 99999.99"
	   @ nLin,091 PSAY Work->UNIT_SELLI  		picture    "@E 9,999,999.99"  
	   @ nLin,103 PSAY Work->ORDER_TOTA      picture    "@E 9,999,999.99"
	   @ nLin,116 PSAY Work->LINE_TYPE
	   @ nLin,121 PSAY Work->IRRF_PIS_C     //picture    "@E 99999.99"    
	   @ nLin,131 PSAY Work->ISS     		//picture    "@E 99999.99"        
	   @ nLin,139 PSAY Work->IPI     		//picture    "@E 99999.99"       
	   @ nLin,151 PSAY Work->ICMS   		//picture    "@E 99999.99"		
	   @ nLin,161 PSAY Work->ACCEPTANCE             
	   @ nLin,178 PSAY Work->CONTRACTNU    
	   @ nLin,198 PSAY Work->PROPOSALNU     
	   @ nLin,214 PSAY Work->PAYMENTTER

   Else

	   @ nLin,000 PSAY Work->CUST_NUMB
	   @ nLin,007 PSAY Work->CUST_NAME
	   @ nLin,030 PSAY alltrim(Work->TRANS_DATE)
	   @ nLin,041 PSAY Work->TRX_NUMBER 
	   @ nLin,053 PSAY Work->PO_NUMBER
	   @ nLin,069 PSAY Work->ITEM_NUMBE 	
	   @ nLin,085 PSAY alltrim(Work->QUANTITY) 	        //picture    "@E 99999.99"
	   @ nLin,092 PSAY alltrim(Work->UNIT_SELLI)  		//picture    "@E 9,999,999.99"  
	   @ nLin,103 PSAY alltrim(Work->ORDER_TOTA)      //picture    "@E 9,999,999.99"
	   @ nLin,113 PSAY alltrim(Work->LINE_TYPE)
	   @ nLin,121 PSAY alltrim(Work->IRRF_PIS_C)            //picture    "@E 99999.99"    
	   @ nLin,130 PSAY alltrim(Work->ISS)     		//picture    "@E 99999.99"        
	   @ nLin,139 PSAY alltrim(Work->IPI)     		//picture    "@E 99999.99"       
	   @ nLin,148 PSAY alltrim(Work->ICMS)   		//picture    "@E 99999.99"		
	   @ nLin,160 PSAY Work->ACCEPTANCE             
	   @ nLin,170 PSAY Work->CONTRACTNU    
	   @ nLin,191 PSAY Work->PROPOSALNU  
	   @ nLin,212 PSAY Work->PAYMENTTER
   
   
   EndIf

   Work->(dbskip())

EndDo                                                                                            
 
 SomaLin()  
 SomaLin()
       
@ nlin,000 PSAY replicate("_",220)    

 SomaLin() 
 SomaLin()   

/* 
@ nLin,000 PSAY "TOTAIS"
@ nLin,081 PSAY nTotQuant  picture    "@E 99,999,999.99"
@ nLin,099 PSAY nTotal     picture    "@E 999,999,999.99"
@ nLin,113 PSAY nTotCus    picture    "@E 999,999,999.99"
@ nLin,138 PSAY nTotCom1   picture    "@E 99,999,999.99"
@ nLin,160 PSAY nTotCom2   picture    "@E 99,999,999.99"  
@ nLin,192 PSAY nTotSeg    picture    "@E 99,999,999.99"
@ nLin,205 PSAY nTotFrete  picture    "@E 99,999,999.99"
  
*/

 SomaLin()  
 
@ nLin,000 PSAY replicate("_",220)                          

 
Roda(nCntImpr,"",tamanho)  

DbselectArea("WORK") 
DbCloseArea("WORK") 
   
If nGera == 1      

	cArqOrig := "\SYSTEM\"+cNome+".dbf"
	cPath     := AllTrim(GetTempPath())                                                   
	CpyS2T( cArqOrig , cPath, .T. )
	                              
	If ApOleClient("MsExcel")
		
		oExcelApp:=MsExcel():New()
	 	//oExcelApp:WorkBooks:Open("Z:\AMB01\SYSTEM\"+cNome+".DBF") 
	  	oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
	   	oExcelApp:SetVisible(.T.)   
	
	Else 
		
		Alert("Excel não instalado") 
	
	EndIf
    FErase(cArqOrig)
EndIf
  

dbSelectArea("QRB")
DbCloseArea("QRB") 

Erase &cNome+".DBF"
Erase &cNome+".DTC"


Return

*----------------------------*
  Static Function Somalin()
*----------------------------*

nLin := nLin + 1
   
If nLin > 58
	cabec(titulo,cCabec1,cCabec2,wnrel,tamanho)
 	nLin := 8
EndIf

Return(nil)        

*----------------------------*
  Static Function MontaQry1()
*----------------------------*

aStruSF2:= SF2->(DbStruct())      

cQuery:=" SELECT "
cQuery+=" A1.A1_FILIAL,A1.A1_COD,A1.A1_LOJA,A1.D_E_L_E_T_,A1.A1_NOME, "
cQuery+=" F2.F2_SERIE,F2.F2_DOC,F2.F2_FILIAL,F2.F2_EMISSAO,F2.D_E_L_E_T_,F2.F2_VALIRRF, "
cQuery+=" D2.D2_SERIE,D2.D2_DOC,D2.D2_PEDIDO,D2.D2_ITEMPV,D2.D2_FILIAL,D2.D2_CLIENTE,D2.D2_LOJA,D2.D2_ITEM,D2.D2_COD,D2.D2_EMISSAO,D2.D_E_L_E_T_,D2.D2_TES,D2.D2_CF,D2.D2_QUANT,D2.D2_PRCVEN, "
cQuery+=" D2.D2_TOTAL,D2.D2_VALICM,D2.D2_VALIPI,D2.D2_VALCOF,D2.D2_VALCSL,D2.D2_VALISS,D2.D2_VALPIS,D2.D2_TOTAL, "
cQuery+=" C6.C6_FILIAL,C6.C6_NUM,C6.C6_ITEM,C6.D_E_L_E_T_ "
cQuery+=" FROM "+RetSqlName("SF2")+" F2,"+RetSqlName("SD2")+" D2, "+RetSqlName("SA1")+" A1, "+RetSqlName("SC6")+" C6 "
cQuery+=" WHERE  F2.F2_SERIE+F2.F2_DOC=D2.D2_SERIE+D2.D2_DOC "
cQuery+=" AND C6.C6_NUM=D2.D2_PEDIDO"
cQuery+=" AND C6.C6_ITEM=D2.D2_ITEMPV" 
cQuery+=" AND F2.F2_FILIAL ='"+cFil+"'"
cQuery+=" AND F2.F2_EMISSAO >= '"+Dtos(dDataIni)+"'"+Chr(10)     
cQuery+=" AND F2.F2_EMISSAO <= '"+Dtos(dDataFim)+"'"+Chr(10) 
cQuery+=" AND F2.F2_CLIENTE+F2.F2_LOJA = D2.D2_CLIENTE+D2.D2_LOJA "
cQuery+=" AND A1.A1_COD+A1.A1_LOJA=F2.F2_CLIENTE+F2.F2_LOJA "
cQuery+=" AND A1.D_E_L_E_T_ <> '*' "
cQuery+=" AND F2.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_<>'*' AND C6.D_E_L_E_T_<>'*' "
cQuery+=" ORDER BY D2.D2_EMISSAO,D2.D2_DOC,D2.D2_SERIE,D2.D2_COD,D2.D2_ITEM,D2.D2_CLIENTE"    
                                                         

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

For nI := 1 To Len(aStruSF2)
	If aStruSF2[nI][2] <> "C" .and.  FieldPos(aStruSF2[nI][1]) > 0
		TcSetField("QRB",aStruSF2[nI][1],aStruSF2[nI][2],aStruSF2[nI][3],aStruSF2[nI][4])
	EndIf
Next nI


Return       
               

// Conta quantos itens tem por nota fiscal de saída
*----------------------------------------------------*
   Static Function COUNT(cDoc,cSerie,cCliente,cLoja)
*----------------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT COUNT(*) QTD"+Chr(10)
cQuery += " FROM "+RetSqlName("SD2")+Chr(10)
cQuery += " WHERE D2_DOC = '"+Alltrim(cDoc)+"'"+Chr(10)
cQuery += " AND D2_SERIE = '"+Alltrim(cSerie)+"'"+Chr(10)
cQuery += " AND D2_CLIENTE = '"+Alltrim(cCliente)+"'"+Chr(10)
cQuery += " AND D2_LOJA = '"+Alltrim(cLOJA)+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' and D2_FILIAL='"+xFilial("SF2")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->QTD)

Return Nil

