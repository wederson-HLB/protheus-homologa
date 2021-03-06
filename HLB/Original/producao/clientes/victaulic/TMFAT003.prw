#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'
#include "TOTVS.CH"

/*
Funcao      : TMFAT003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir relat?rio de or?amento.
Autor     	: Renato Rezende
Data     	: 25/06/2014
TDN         : 
M?dulo      : Faturamento.
Empresa		: Victaulic
*/

*-------------------------*
  User Function TMFAT003() 
*-------------------------*
Local aImpostos		:= {}

Private lRet		:= .T.
Private nPagina		:= 1
Private oPrint
Private cNumOrc		:= "" 
Private cPerg		:= ""  

Private oFont1		:= TFont():New('Courier new',,-10,.T.)   
Private oFont2		:= TFont():New('Tahoma',,18,.T.)  
Private oFont3		:= TFont():New('Tahoma',,12,.T.) 
Private oFont4		:= TFont():New('Arial',,11,,.T.,,,,,.f.)   
Private oFont5		:= TFont():New('Arial',,9,,.T.,,,,,.f. )    
Private oFont6		:= TFont():New('Arial',,8,,.T.,,,,,.f. )   
Private oFont7		:= TFont():New('Arial',,6,,.T.,,,,,.f. ) 
  
//Verificando se est? na empresa Victaulic
If !(cEmpAnt) $ "TM"
     MsgInfo("Rotina n?o implementada para essa empresa!","HLB BRASIL")
     Return
EndIf
 
cPerg := "TMFAT3"
//Criando Pergunte 
CriaPerg()
//Chamando Pergunte
IF !(Pergunte(cPerg,.T.))
	Return .F.
EndIf         
   
cNumOrc:=mv_par01
                               	
// Monta objeto para impress?o
oPrint := TMSPrinter():New("Impress?o de Or?amento")
 
// Define orienta??o da p?gina para Retrato
// pode ser usado oPrint:SetLandscape para Paisagem
oPrint:SetPortrait()
    
// Mostra janela de configura??o de impress?o
oPrint:Setup()

// Inicia p?gina
oPrint:StartPage()  
    
//Papel A4
oPrint:SetpaperSize(9)                                                
    
MontaRel() 
   
If !(lRet)
	Return .F.     
EndIf
   
oPrint:EndPage()
                        
// Mostra tela de visualiza??o de impress?o
oPrint:Preview() 
   
//Finaliza Objeto 
oPrint:End() 

Return     

*----------------------------*
  Static Function MontaRel() 
*----------------------------*
      
Local n:=1
Local nLinha:=1555   

Private nTotal:=0 
Private nTotalIPI:=0
Private nTotICMSST:=0  
Private cIcms,nPos
Private cEst :=GetMv("MV_ESTICM ") 
   
If Empty(cNumOrc)  
	MsgStop("Nenhum Or?amento encontrado para impress?o","HLB BRASIL")   
	lRet:=.F.
	Return .F.
EndIf 

DbSelectArea("SCJ")
SCJ->(DbSetOrder(1))
If !(SCJ->(DbSeek(xFilial("SCJ")+Alltrim(cNumOrc))))
	MsgStop("Nenhum Or?amento encontrado para impress?o","HLB BRASIL")   
	lRet:=.F.
	Return .F.
EndIf 
         
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))  
   
//DbSelectArea("SA4")
//SA4->(DbSetOrder(1))
//SA4->(DbSeek(xFilial("SA4")+SCJ->CJ_P_TRANP))  
   
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial("SE4")+SCJ->CJ_CONDPAG))   
   
DbSelectArea("SA3")
SA3->(DbSetOrder(1))
SA3->(DbSeek(xFilial("SA3")+SCJ->CJ_P_VEND1)) 
   
MontaCab()
   
DbSelectArea("SCK")
SCK->(DbSetOrder(1)) 
   
DbSelectArea("SB1")
SB1->(DbSetOrder(1))
   
SCK->(DbSeek(xFilial("SCK")+Alltrim(cNumOrc)))
While SCK->(!EOF()) .And. SCK->CK_NUM == Alltrim(cNumOrc)  
            
	SB1->(DbSeek(xFilial("SB1")+SCK->CK_PRODUTO+SCK->CK_LOCAL)) 
      
	oPrint:Say(nLinha,30,Substr(Alltrim(SCK->CK_PRODUTO),1,15),oFont5) 
	oPrint:Say(nLinha,295,Alltrim(SCK->CK_DESCRI),oFont6)
	If !Empty(SCK->CK_P_VLRST)  
		oPrint:Say(nLinha+40,710,"C?lculo do ICMS ST"+Transform(SCK->CK_P_VLRST,"@E 9,999,999.99"),oFont6)     				
	EndIf
	oPrint:Say(nLinha,1150,Alltrim(SB1->B1_POSIPI),oFont6)   
	//oPrint:Say(nLinha,1310,SCK->CK_P_PRAZO,oFont6)                 
	oPrint:Say(nLinha,1490,Alltrim(SCK->CK_UM),oFont6) 
	oPrint:Say(nLinha,1570,Alltrim(Str(SCK->CK_QTDVEN)),oFont5)
	oPrint:Say(nLinha,1690,Transform(SCK->CK_PRCVEN,"@E 9,999,999.99"),oFont5)
      
	If SA1->A1_CONTRIB =='2'
		cIcms:='18%'
	Else   
		nPos:=At(Alltrim(SA1->A1_EST),Alltrim(cEst)) 
		cIcms:=SubStr(Alltrim(cEst),nPos+2,2)+"%"
	EndIf
          
	oPrint:Say(nLinha,1908,(Transform(SB1->B1_IPI,"@E 99"))+"%",oFont5)
	//oPrint:Say(1555,1985,(Transform(SB1->B1_PICM,"@E 99"))+"%",oFont5) 
	oPrint:Say(nLinha,1983,cIcms,oFont5)
	oPrint:Say(nLinha,2075,Transform(SCK->CK_VALOR,"@E 9,999,999,999.99"),oFont5) 
    
    //Calcular os impostos do or?amento
	aImpostos := {U_GTFAT008(SCK->CK_VALOR,SCK->CK_QTDVEN,SCK->CK_PRCVEN)}

	//nTotalIPI+=(SCK->CK_VALOR*(SB1->B1_IPI/100))
	nTotalIPI+= aImpostos[1][3]
	nTotal+=SCK->CK_VALOR
	nTotICMSST+=SCK->CK_P_VLRST      
      
	If !Empty(SCK->CK_P_VLRST)  
		nLinha+=80
	Else
		nLinha+=40
	EndIf
	n++   
      
	If nLinha>2730
            
		oPrint:Say(2880,45,"Frete por conta do cliente (FOB) - Favor indicar a transportadora no ato do pedido",oFont6)
		oPrint:Say(2920,45,"Favor confirmar todos os dados para faturamento e entrega",oFont6)
		oPrint:Say(2960,45,"Prazo de entrega sujeito a confirma??o no fechamento do pedido",oFont6)
		//oPrint:Say(3000,45,Alltrim(SubStr(SCJ->CJ_P_OBS,1,100)),oFont6)
		If Empty(SCJ->CJ_P_VEND1) 
			oPrint:Say(3240,400,"N?O PREENCHIDO NO OR?AMENTO",oFont5)
		Else     
			DbSelectArea("SA3")
			SA3->(DbSetOrder(1))
			If SA3->(DbSeek(xFilial("SA3")+SCJ->CJ_P_VEND1))
				oPrint:Say(3240,220,"VENDEDOR: "+Alltrim(UPPER(SA3->A3_NOME))+ " EMAIL: "+alltrim(SA3->A3_EMAIL)+" TELEFONE:"+Alltrim(Transform(SA3->A3_TEL,"@R (99) 9999-9999")),oFont5)
			EndIf
		EndIf
		oPrint:EndPage()   
		oPrint:StartPage() 
		oPrint:SetPortrait()
		oPrint:SetpaperSize(9)
		nPagina++
		MontaCab()
		nLinha:=1555

	EndIf
   
	SCK->(DbSkip())   
      
EndDo      
   
oPrint:Say(2875,1840,"Valor IPI R$",oFont5)  
oPrint:Say(2945,1840,"ICMS ST R$",oFont5) 
oPrint:Say(3015,1830,"Total s/ IPI R$",oFont5)
oPrint:Say(3085,1830,"Total c/ IPI R$",oFont5)
oPrint:Say(3155,1660,"Total c/ IPI + ICMS ST R$",oFont5)
   
oPrint:Say(2880,45,"Frete por conta do cliente (FOB) - Favor indicar a transportadora no ato do pedido",oFont6)
oPrint:Say(2920,45,"Favor confirmar todos os dados para faturamento e entrega",oFont6)
oPrint:Say(2960,45,"Prazo de entrega sujeito a confirma??o no fechamento do pedido",oFont6)
//oPrint:Say(3020,45,Alltrim(SubStr(SCJ->CJ_P_OBS,1,100)),oFont6)
//oPrint:Say(3155,45," ***************************** OBRIGADO POR FAZER NEG?CIOS CONOSCO! ***************************** ",oFont5)   
   
oPrint:Say(2875,2100,Transform(nTotalIPI,"@E 9,999,999,999.99"),oFont5)   
oPrint:Say(2945,2100,Transform(nTotICMSST,"@E 9,999,999,999.99"),oFont5)  
oPrint:Say(3015,2100,Transform(nTotal,"@E 9,999,999,999.99"),oFont5)
oPrint:Say(3085,2100,Transform(nTotal+nTotalIPI,"@E 9,999,999,999.99"),oFont5) 
oPrint:Say(3155,2100,Transform(nTotal+nTotalIPI+nTotICMSST,"@E 9,999,999,999.99"),oFont5)                                 
   
   
   
If Empty(SCJ->CJ_P_VEND1) 
	oPrint:Say(3240,1000,"VENDEDOR N?O PREENCHIDO NO OR?AMENTO",oFont5)
Else 
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(xFilial("SA3")+SCJ->CJ_P_VEND1))
		oPrint:Say(3240,220,"VENDEDOR: "+Alltrim(UPPER(SA3->A3_NOME))+ "   EMAIL: "+alltrim(SA3->A3_EMAIL)+"  TELEFONE: "+Alltrim(Transform(SA3->A3_TEL,"@R (99) 9999-9999")),oFont5)
	EndIf
EndIf

Return

*----------------------------*
  Static Function MontaCab()
*----------------------------*

Local oBrush := TBrush():New( , RGB(247,154,42) )//Cor Laranja

oPrint:FillRect({1301, 23, 1342, 2348}, oBrush)
oPrint:FillRect({1402, 23, 1442, 2348}, oBrush)
oPrint:FillRect({1502, 23, 1542, 2348}, oBrush)
oPrint:FillRect({3202, 23, 3316, 2348}, oBrush)  
   
oPrint:SayBitmap(130,20,"\system\FAT_LGRLTM.bmp",1300,300)
      
oPrint:Say(190,2050,"Pagina  "+Alltrim(Str(nPagina)),oFont1)    
oPrint:Say(300,1800,"Or?amento "+cNumOrc,oFont2)
oPrint:Say(400,1960,"Emiss?o :"+Dtoc(date()),oFont3) 
  
oPrint:Say(470,20,SM0->M0_NOMECOM,oFont4)
oPrint:Say(550,20,"Escrit?rio Comercial:",oFont4) 
oPrint:Say(610,20,Alltrim(SM0->M0_ENDCOB),oFont5) 
oPrint:Say(670,20,Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" ,"+Alltrim(SM0->M0_ESTCOB)+" - CEP "+Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont5)  
oPrint:Say(730,20,"Telefone: "+Alltrim(SM0->M0_TEL) +" / FAX: "+Alltrim(SM0->M0_FAX),oFont5)
         
oPrint:Say(550,1200,"Local de Emiss?o da NF:",oFont4) 
oPrint:Say(610,1200,Alltrim(SM0->M0_ENDCOB),oFont5) 
oPrint:Say(670,1200,Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" ,"+Alltrim(SM0->M0_ESTCOB)+" - CEP "+Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont5)   
oPrint:Say(730,1200,"CNPJ: "+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"))+"  INSC: "+Alltrim(Transform(SM0->M0_INSC,"@R 999.999.999.9999")),oFont5) 
       
oPrint:Say(870,20,"Faturamento: ",oFont4)
oPrint:Say(930,20,UPPER(SA1->A1_NOME),oFont4)  
oPrint:Say(990,20,Alltrim(SA1->A1_END),oFont5) 
oPrint:Say(1050,20,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP "+Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")),oFont5)
oPrint:Say(1110,20,"Contato: "+Alltrim(SA1->A1_CONTATO),oFont5)
oPrint:Say(1170,20,"Email: "+Alltrim(SA1->A1_EMAIL),oFont5)       
oPrint:Say(1230,20,"CNPJ: "+Alltrim(Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))+"  INSC: "+IIF(!Empty(SA1->A1_INSCR),Alltrim(Transform(SA1->A1_INSCR,"@R 999.999.999.9999")),""),oFont5)  
    
If Len(Alltrim(SA1->A1_NOME)) < 41
	oPrint:Say(870,1200,"Entrega: ",oFont4)
	oPrint:Say(930,1200,Alltrim(SA1->A1_END),oFont5) 
	oPrint:Say(990,1200,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP "+Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")),oFont5)
	oPrint:Say(1050,1200,"CNPJ: "+Alltrim(Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))+"  INSC: "+IIF(!Empty(SA1->A1_INSCR),Alltrim(Transform(SA1->A1_INSCR,"@R 999.999.999.9999")),""),oFont5)  
Else
	oPrint:Say(870,1420,"Entrega: ",oFont4)
	oPrint:Say(930,1420,Alltrim(SA1->A1_END),oFont5) 
	oPrint:Say(990,1420,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP "+Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")),oFont5)
	oPrint:Say(1050,1420,"CNPJ: "+Alltrim(Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))+"  INSC: "+IIF(!Empty(SA1->A1_INSCR),Alltrim(Transform(SA1->A1_INSCR,"@R 999.999.999.9999")),""),oFont5)  
EndIf  
   
oPrint:Say(1230,1800,"www.victaulic.com",oFont4)

oPrint:Say(1305,295,"Representante ",oFont5)
If Empty(SCJ->CJ_P_VEND1)
	oPrint:Say(1350,160,"VENDEDOR N?O PREENCHIDO NO OR?AMENTO",oFont5) 
Else
	oPrint:Say(1350,160,alltrim(SA3->A3_NOME),oFont5)
EndIf

oPrint:Say(1305,1200,"Condi??o de Pagamento",oFont5)
oPrint:Say(1350,1255,Alltrim(SE4->E4_DESCRI),oFont5)
//oPrint:Say(1305,2010,"Valid. da Proposta",oFont5) 
//oPrint:Say(1350,2100,Alltrim(SCJ->CJ_P_VALID),oFont5)  
   
oPrint:Say(1405,295,"Fone",oFont5)  
oPrint:Say(1450,225,Alltrim(Transform(SA3->A3_TEL,"@R (99) 9999-9999")),oFont5) 
//oPrint:Say(1405,1280,"Transportadora",oFont5) 
//oPrint:Say(1450,1020,alltrim(SA4->A4_NOME),oFont5)
//oPrint:Say(1405,2090,"Frete",oFont5)
//oPrint:Say(1450,2100,IIF(ALLTRIM(SCJ->CJ_P_TPFRE)$"C","CIF","FOB"),oFont5)    

oPrint:Say(1505,80,"Codigo",oFont5)
oPrint:Say(1505,550,"Descri??o",oFont5)
oPrint:Say(1505,1185,"NCM",oFont5)
oPrint:Say(1505,1330,"Entrega",oFont5)
oPrint:Say(1505,1485,"UN",oFont5)
oPrint:Say(1505,1580,"QTD",oFont5)
oPrint:Say(1505,1700,"Unit. s/ IPI",oFont5)
oPrint:Say(1505,1920,"IPI",oFont5)
oPrint:Say(1505,1980,"ICMS",oFont5)
oPrint:Say(1505,2150,"Total",oFont5)   
   
oPrint:Say(2810,45,"Observa??es Gerais ",oFont4)

oPrint:Box(1300,20,3320,2350)

//Linhas do Cabecario
oPrint:Line(1340,20,1340,2350)  //Linha
oPrint:Line(1400,20,1400,2350)  //Linha
oPrint:Line(1440,20,1440,2350)  //Linha
oPrint:Line(1500,20,1500,2350)  //Linha
oPrint:Line(1540,20,1540,2350)  //Linha
oPrint:Line(1300,850,1500,850)  //Coluna 

oPrint:Line(2800,20,2800,2350)  //Linha    
oPrint:Line(3150,20,3150,2350)  //Linha
oPrint:Line(3200,20,3200,2350)  //Linha 
//oPrint:Line(3150,1760,3200,1760)  //Coluna

oPrint:Line(1500,290,2800,290)    //Coluna 1 
oPrint:Line(1500,1140,2800,1140)  //Coluna 2
oPrint:Line(1500,1300,2800,1300)  //Coluna 3
oPrint:Line(1500,1475,2800,1475)  //Coluna 4
oPrint:Line(1500,1550,2800,1550)  //Coluna 5
oPrint:Line(1500,1680,2800,1680)  //Coluna 6
oPrint:Line(1300,1900,2800,1900)  //Coluna 7 
oPrint:Line(1500,1975,2800,1975)  //Coluna 8 
oPrint:Line(1500,2065,3200,2065)  //Coluna 9  
      
Return

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: Renato Rezende  	 	
Data     	: 25/06/2014
M?dulo      : Faturamento.
Cliente     : Victaulic.
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*

U_PUTSX1(cPerg, "03", "Orcamento ?",     "Orcamento ?",        	"Orcamento ?",      "mv_ch1","C",6,0,0, "G","","ZCJ" ,"","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")

Return
