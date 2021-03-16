#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : TMFAT005
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Adicionar informações ao picking list 
Autor       : Tiago Luiz Mendonça
Data        : 25/07/2013
Revisão     :        
Data        : 
Módulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function TMFAT005()   
*----------------------* 

Local oDlg
Local oMain

Local lOk := .F.   

Private cC5_MENNOTA := space(400)   

Private cC5_ESP1 	:= space(10)  
Private cC5_ESP2 	:= space(10)   
Private cC5_ESP3 	:= space(10)   
Private cC5_ESP4 	:= space(10)  

Private nC5_VOL1 	:= 00000  
Private nC5_VOL2 	:= 00000 
Private nC5_VOL3 	:= 00000   
Private nC5_VOL4 	:= 00000   

	SC9->(DbSetOrder(1))
	If SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM))  
	
		cC5_MENNOTA :=  SC5->C5_MENNOTA   
		
		nC5_VOL1 :=  SC5->C5_VOLUME1 
		nC5_VOL2 :=  SC5->C5_VOLUME2 
		nC5_VOL3 :=  SC5->C5_VOLUME3 
		nC5_VOL4 :=  SC5->C5_VOLUME4 		 		 

		cC5_ESP1 :=  SC5->C5_ESPECI1 
		cC5_ESP2 :=  SC5->C5_ESPECI2 
		cC5_ESP3 :=  SC5->C5_ESPECI3 
		cC5_ESP4 :=  SC5->C5_ESPECI4 		
		
		While SC9->(!EOF()) .And. SC5->C5_NUM == SC9->C9_PEDIDO
	    	
	    	If SC9->C9_P_PICK == "S" 
	        	lOk:=.T.
		    EndIf                   	
		   
			SC9->(DbSkip())
		EndDo   
	
	EndIf
     
	If lOk

                                                      
		DEFINE MSDIALOG oDlg TITLE "Informações adicionais" From 1,7 To 15,90 OF oMain     
   
   			@ 010,008 SAY "ESPECIE 1"
     		@ 010,060 GET cC5_ESP1  PICTURE "@!"  size 40,10   

   			@ 023,008 SAY "ESPECIE 2"
     		@ 023,060 GET cC5_ESP2  PICTURE "@!"  size 40,10   

   			@ 036,008 SAY "ESPECIE 3"
     		@ 036,060 GET cC5_ESP3  PICTURE "@!"  size 40,10   
     		
    		@ 049,008 SAY "ESPECIE 4"
     		@ 049,060 GET cC5_ESP4  PICTURE "@!"  size 40,10       		

   			@ 010,150 SAY "VOLUME 1"
     		@ 010,200 GET nC5_VOL1  PICTURE "@E 99999"  size 25,10   

   			@ 023,150 SAY "VOLUME 2"
     		@ 023,200 GET nC5_VOL2  PICTURE "@E 99999"  size 25,10  

   			@ 036,150 SAY "VOLUME 3"
     		@ 036,200 GET nC5_VOL3  PICTURE "@E 99999"  size 25,10  

   			@ 049,150 SAY "VOLUME 4"
     		@ 049,200 GET nC5_VOL4  PICTURE "@E 99999"  size 25,10                                                     

   			@ 062,008 SAY "MENS. NOTA"
     		@ 062,060 GET cC5_MENNOTA  size 170,10 

       		@ 080,150 BMPBUTTON TYPE 1 ACTION(Processa({|| Process()},"Processando..."),oDlg:End()) 
      	  	@ 080,190 BMPBUTTON TYPE 2 ACTION(oDlg:End()) 
    
   		ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())
	
	Else        
         
		Alert("Esse pedido não possui picking list gerado, ajuste as informações em modo de alteração","Victaulic")
		Return .F.

	EndIf    


Return

*---------------------------*
  Static Function Process() 
*---------------------------*  
  

If MsgYesNo("Deseja atualizar o pedido com os itens informados ?","Victaulic")
                                                                            
	RecLock("SC5",.F.)          
	SC5->C5_MENNOTA := cC5_MENNOTA
	SC5->C5_VOLUME1 := nC5_VOL1 
	SC5->C5_VOLUME2 := nC5_VOL2 
	SC5->C5_VOLUME3 := nC5_VOL3 
	SC5->C5_VOLUME4 := nC5_VOL4 	
	SC5->C5_ESPECI1 := cC5_ESP1                      
	SC5->C5_ESPECI2 := cC5_ESP2                      
	SC5->C5_ESPECI3 := cC5_ESP3                      
	SC5->C5_ESPECI4 := cC5_ESP4                      
	SC5->(MsUnlock())
          
Else   

	MsgInfo("Dados nao foram atualizados","HLB")      

EndIf    	
  

Return           
                                     




