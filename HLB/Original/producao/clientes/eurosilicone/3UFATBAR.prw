#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'
#include "TOTVS.CH"

/*
Funcao      : 3UFATPACK
Parametros  : 
Retorno     : 
Objetivos   : Emitir relatório de romaneio.
Autor       : Tiago Luiz Mendonça 
Data        : 16/12/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Faturamento.
*/ 
                
                     
*---------------------------*
  User Function 3UFATPACK() 
*---------------------------*

  Local cItem  
  Local oDlg,oMain
  Local lOK:=.F.  
  
  Private lRet:=.T.
  Private nPagina:=1
  Private oPrint
  Private cPedido:=Space(6)

  Private oFont1   := TFont():New('Courier new',,-10,.T.)   
  Private oFont2   := TFont():New('Tahoma',,18,.T.)  
  Private oFont3   := TFont():New('Tahoma',,12,.T.) 
  Private oFont4   := TFont():New('Arial',,11,,.T.,,,,,.f. )   
  Private oFont5   := TFont():New('Arial',,9,,.T.,,,,,.f. )    
  Private oFont6   := TFont():New('Arial',,8,,.T.,,,,,.f. )   
  Private oFont7   := TFont():New('Arial',,6,,.T.,,,,,.f. ) 
  
  If !(cEmpAnt $ "3U" .Or. cEmpAnt $ "99" )  
      MsgStop("Rotina especificaNeogem, liberado apenas para empresa teste","Atenção") 
      Return .F.
   EndIf       
   

   DEFINE MSDIALOG oDlg TITLE "Selecionar o pedido" From 1,7 To 10,39 OF oMain     
   
      @ 015,008 SAY "Escolha o pedido : "  PIXEL SIZE 60,30 OF oDlg 
      @ 015,070 Get cPedido  F3 "SC5" 
      @ 035,040 BMPBUTTON TYPE 1 ACTION(lOk:=.T.,oDlg:End()) 
      @ 035,070 BMPBUTTON TYPE 2 ACTION(lOk:=.F.,oDlg:End()) 

   ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())
   
   If Alltrim(cPedido) == "" .And. lOK 
      MsgStop("O pedido não pode ser em branco","EUROSILICONE")
   EndIf   
    
   If lOK .and. Alltrim(cPedido) <> "" 
      ZX3->(DbSetOrder(2))
      If !(ZX3->(DbSeek(xFilial("ZX3")+cPedido)))     
         MsgStop("Pedido não encontrado, verifique se o numero está correto","EUROSILICONE")  
         Return .F.
      EndIf   
   EndIf 
   
                               	
   // Monta objeto para impressão
   oPrint := TMSPrinter():New("Impressão de Packing List")
 
   // Define orientação da página para Retrato
   // pode ser usado oPrint:SetLandscape para Paisagem
   oPrint:SetPortrait()
    
   // Mostra janela de configuração de impressão
   oPrint:Setup()

   //Inicia página
   oPrint:StartPage()  
    
    //Papel A4
   oPrint:SetpaperSize(9)                                                
    
   MontaRel() 
   
   If !(lRet)
      Return .F.     
   EndIf
   
   oPrint:EndPage()
                        
   // Mostra tela de visualização de impressão
   oPrint:Preview() 
   
   //Finaliza Objeto 
   oPrint:End() 
	


Return     

*----------------------------*
  Static Function MontaRel() 
*----------------------------*
      
Local n:=1
Local nLinha:=1350 
Local nLinBar:=12
Local nColBar:=1 
Local nLinUN:=1420 
Local lEsq:=.T.

Private nTotal:=0 
Private nTotalIPI:=0  
   
      
   DbSelectArea("SA1")
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+ZX3->ZX3_CLIENT+ZX3->ZX3_LOJA))       
   
   MontaCab()
   
   ZX3->(DbSetOrder(2))
   ZX3->(DbSeek(xFilial("ZX3")+Alltrim(cPedido)))
   While ZX3->(!EOF()) .And. ZX3->ZX3_PEDIDO == Alltrim(cPedido)  
                     
      If lEsq   
         SB1->(DbSetOrder(1))      
         If SB1->(DbSeek(xFilial("SB1")+ZX3->ZX3_COD))
            oPrint:Say(nLinha,30,Alltrim(ZX3->ZX3_COD)+" "+Alltrim(SB1->B1_DESC)+" - 1 UN",oFont5)
         Else
            oPrint:Say(nLinha,30,ZX3->ZX3_COD,oFont5)    
         EndIf                          	
   
   	     MsBar3("CODE128",nLinBar,nColBar,ZX3->ZX3_CODBAR,oPrint, .F.,   , NIL, 0.022, 0.8,.T.,NIL,NIL,.F.,NIL)  
   	                 	         
   	     lEsq:=.F.
   	     
   	  Else  
   	  
   	     SB1->(DbSetOrder(1))      
         If SB1->(DbSeek(xFilial("SB1")+ZX3->ZX3_COD))
            oPrint:Say(nLinha,1250,Alltrim(ZX3->ZX3_COD)+" "+Alltrim(SB1->B1_DESC)+" - 1 UN",oFont5)
         Else
            oPrint:Say(nLinha,1250,ZX3->ZX3_COD,oFont5)    
         EndIf
   
   	     MsBar3("CODE128",nLinBar,nColBar+9.5,ZX3->ZX3_CODBAR,oPrint, .F.,   , NIL, 0.022, 0.8,.T.,NIL,NIL,.F.,NIL)    
   	     
   	     lEsq:=.T. 
   	     
   	     nLinBar+=1.9  
         nLinha+=230
         n++     
   	     
   	     
   	  EndIf 
   	  
   	  //Ajuste
      If n==6
         nLinBar+=0.1  
      EndIf 
      
      If n > 7 
            
         oPrint:Say(3005,25,"HORA_______ :________",oFont5) 
         oPrint:Say(3090,25,"DATA_______/_______/________",oFont5)
         oPrint:Say(3005,580,"Cliente:___________________________",oFont5)
         oPrint:Say(3090,580,"Entrega:___________________________",oFont5)
   
         oPrint:Say(3005,1300,"HORA_______ :______",oFont5) 
         oPrint:Say(3090,1300,"DATA_______/_______/_______",oFont5)
         oPrint:Say(3005,1800,"Cliente:_______________________",oFont5)
         oPrint:Say(3090,1800,"Receb. :_______________________",oFont5)
                                                 
         oPrint:Say(3205,45,"",oFont6)
         //oPrint:Say(3210,980,"EUROSILICONE ",oFont2)
         oPrint:Say(3280,45,"",oFont6)

         oPrint:EndPage()   
         oPrint:StartPage() 
         oPrint:SetPortrait()
         oPrint:SetpaperSize(9)
         nPagina++
         MontaCab()
         n:=1
         nLinha:=1350 
         nLinBar:=12
         nColBar:=1 
         lEsq:=.T.  
      
      EndIf
   
      ZX3->(DbSkip())   
      
   EndDo                                                           
   
   oPrint:Say(3005,25,"HORA_______ :________",oFont5) 
   oPrint:Say(3090,25,"DATA_______/_______/________",oFont5)
   oPrint:Say(3005,580,"Cliente:___________________________",oFont5)
   oPrint:Say(3090,580,"Entrega:___________________________",oFont5)
   
   oPrint:Say(3005,1300,"HORA_______ :______",oFont5) 
   oPrint:Say(3090,1300,"DATA_______/_______/_______",oFont5)
   oPrint:Say(3005,1800,"Cliente:__________________________",oFont5)
   oPrint:Say(3090,1800,"Receb. :__________________________",oFont5)
   //oPrint:Say(3205,45,"",oFont6)
   //oPrint:Say(3210,980,"EUROSILICONE ",oFont2)
   //oPrint:Say(3280,45,"",oFont6)

Return
             
*----------------------------*
  Static Function MontaCab()
*----------------------------*

Local oBrush := TBrush():New( , CLR_GRAY )

   oPrint:FillRect({1301, 23, 1342, 2348}, oBrush)
   //oPrint:FillRect({1402, 23, 1442, 2348}, oBrush)
   //oPrint:FillRect({1502, 23, 1542, 2348}, oBrush)
   //oPrint:FillRect({3202, 23, 3316, 2348}, oBrush)     
   
   oPrint:SayBitmap(130,20,"D:\Ambientes\P10\System\lgrl3u.bmp",1300,300)
      
   oPrint:Say(190,2050,"Pagina  "+Alltrim(Str(nPagina)),oFont1)    
   oPrint:Say(300,1850,"Pedido "+cPedido,oFont2)
   oPrint:Say(400,1960,"Emissão :"+Dtoc(date()),oFont3) 
  
   oPrint:Say(470,20,SM0->M0_NOMECOM,oFont4)
   oPrint:Say(550,20,"Escritório Comercial:",oFont4) 
   oPrint:Say(610,20,Alltrim(SM0->M0_ENDCOB),oFont5) 
   oPrint:Say(670,20,Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" ,"+Alltrim(SM0->M0_ESTCOB)+" - CEP "+Alltrim(SM0->M0_CEPCOB),oFont5)  
   oPrint:Say(730,20,"Telefone: ("+Substr(SM0->M0_TEL,1,2)+") "+Substr(SM0->M0_TEL,3,4)+"-"+Substr(SM0->M0_TEL,7,4)+"  FAX: ("+Substr(SM0->M0_FAX,1,2)+") "+Substr(SM0->M0_FAX,3,4)+"-"+Substr(SM0->M0_FAX,7,4) ,oFont5)
    
   oPrint:Say(550,1200,"Local de Emissão da NF:",oFont4) 
   oPrint:Say(610,1200,Alltrim(SM0->M0_ENDCOB),oFont5) 
   oPrint:Say(670,1200,Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" ,"+Alltrim(SM0->M0_ESTCOB)+" - CEP "+Alltrim(SM0->M0_CEPCOB),oFont5)   
   oPrint:Say(710,1200,"CNPJ: "+Alltrim(SM0->M0_CGC)+"  INSC: "+Alltrim(SM0->M0_INSC),oFont5) 
       
   oPrint:Say(870,20,"Faturamento: ",oFont4)
   oPrint:Say(930,20,UPPER(SA1->A1_NOME),oFont4)  
   oPrint:Say(990,20,Alltrim(SA1->A1_END)+" , "+Alltrim(SA1->A1_COMPLEM),oFont5) 
   oPrint:Say(1050,20,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP"+Alltrim(SA1->A1_CEP),oFont5)
   oPrint:Say(1110,20,"Contato: "+Alltrim(SA1->A1_CONTATO),oFont5) 
   oPrint:Say(1170,20,"Email: "+Alltrim(SA1->A1_EMAIL),oFont5)
   oPrint:Say(1230,20,"CNPJ: "+Alltrim(SA1->A1_CGC)+"  INSC: "+Alltrim(SA1->A1_INSCR),oFont5)  
                
   SC5->(DbSetOrder(1))
   If SC5->(DbSeek(xFilial("SC5")+cPedido))
      If !Empty(SC5->C5_P_ENTR)
         ZX6->(DbSetOrder(1)) 
         If ZX6->(DbSeek(xFilial("ZX6")+SC5->C5_P_ENTR))  
            If Alltrim(ZX6->ZX6_TIPO) == "C"
               oPrint:Say(870,1200,"Entrega: ",oFont4)
               oPrint:Say(930,1200,Alltrim(SA1->A1_END)+" , "+Alltrim(SA1->A1_COMPLEM),oFont5) 
               oPrint:Say(990,1200,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP"+Alltrim(SA1->A1_CEP),oFont5)
               oPrint:Say(1050,1200,"CNPJ: "+Alltrim(SA1->A1_CGC)+"  INSC: "+Alltrim(SA1->A1_INSCR),oFont5)  
                      
            Else 
               oPrint:Say(870,1200,"Entrega: ",oFont4) 
               oPrint:Say(930,1200,UPPER(ZX6->ZX6_NOME),oFont4)  
               oPrint:Say(990,1200,Alltrim(ZX6->ZX6_END),oFont5) 
               oPrint:Say(1050,1200,Alltrim(ZX6->ZX6_MUN)+" ,"+Alltrim(ZX6->ZX6_EST)+" - CEP"+Alltrim(ZX6->ZX6_CEP),oFont5)
               oPrint:Say(1110,1200,"Contato : "+ZX6->ZX6_CONTAT,oFont5)              
            EndIf                                  
         Else
            oPrint:Say(870,1200,"Entrega: ",oFont4)
            oPrint:Say(930,1200,Alltrim(SA1->A1_END)+" , "+Alltrim(SA1->A1_COMPLEM),oFont5) 
            oPrint:Say(990,1200,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP"+Alltrim(SA1->A1_CEP),oFont5)
            oPrint:Say(1050,1200,"CNPJ: "+Alltrim(SA1->A1_CGC)+"  INSC: "+Alltrim(SA1->A1_INSCR),oFont5)         
         EndIf     
      Else
         oPrint:Say(870,1200,"Entrega: ",oFont4)
         oPrint:Say(930,1200,Alltrim(SA1->A1_END)+" , "+Alltrim(SA1->A1_COMPLEM),oFont5) 
         oPrint:Say(990,1200,Alltrim(SA1->A1_MUN)+" ,"+Alltrim(SA1->A1_EST)+" - CEP"+Alltrim(SA1->A1_CEP),oFont5)
         oPrint:Say(1050,1200,"CNPJ: "+Alltrim(SA1->A1_CGC)+"  INSC: "+Alltrim(SA1->A1_INSCR),oFont5)  
      EndIf
   
   
      oPrint:Say(1190,1200,"Nome do paciente: "+SC5->C5_P_DESCP,oFont5)   
      oPrint:Say(3220,30,"OBS: "+SC5->C5_P_OBS,oFont5)  

   
   EndIf
   

		
   oPrint:Say(1305,25,"PRODUTO",oFont5)
   oPrint:Say(1305,1115,"OBS",oFont5)
   oPrint:Say(1305,1225,"PRODUTO",oFont5) 
   oPrint:Say(1305,2220,"OBS",oFont5) 

		
   oPrint:Box(1300,20,3320,2350)
   
   //Linhas do Cabecario
   oPrint:Line(1340,20,1340,2350)  //Linha
   oPrint:Line(1560,20,1560,2355)  //Linha   
   oPrint:Line(1790,20,1790,2350)  //Linha    
   oPrint:Line(2020,20,2020,2350)  //Linha     
   oPrint:Line(2240,20,2240,2350)  //Linha  
   oPrint:Line(2480,20,2480,2350)  //Linha   
   oPrint:Line(2700,20,2700,2350)  //Linha
   //oPrint:Line(2280,20,2280,2350)  //Linha    
   //oPrint:Line(2620,20,2620,2350)  //Linha
   oPrint:Line(1300,1075,2960,1075)  //Coluna  
   oPrint:Line(1300,1220,3150,1220)  //Coluna
   oPrint:Line(1300,2180,2960,2180)  //Coluna
  
   oPrint:Line(2960,20,2960,2350)  //Linha    
   oPrint:Line(3150,20,3150,2350)  //Linha
   //oPrint:Line(3200,20,3200,2350)  //Linha 

      
Return   


