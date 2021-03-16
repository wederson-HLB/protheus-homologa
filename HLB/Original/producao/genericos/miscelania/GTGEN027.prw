#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"

/*
Funcao      : GTGEN027
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Criar tabela/indice  
Autor     	: Tiago Luiz Mendonça.  
Data     	: 02/04/2014
Obs         : 
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Generico
Cliente     : Todos
*/  

*--------------------------*
  User Function GTGEN027() 
*--------------------------*  
       
Local oDlg
Local oMain     

Local cDe   	:= "   "
Local cAte  	:= "   "   


	DEFINE MSDIALOG oDlg TITLE "Cria indice/tabela" From 1,7 To 10,35 OF oMain     
   
   		@ 010,008 SAY "De tabela"
     	@ 010,060 GET cDe   size 10,10   
      	@ 023,008 SAY "Ate tabela"
       	@ 023,060 GET cAte  size 10,10    
        @ 037,025 BMPBUTTON TYPE 1 ACTION(If(Empty(cAte),MsgInfo("Necessario preencher o campo Ate","HLB"),Processa({|| Process(cDe,cAte)},"Processando..."))) 
        @ 037,055 BMPBUTTON TYPE 2 ACTION(oDlg:End()) 
    
    ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())

Return

*-----------------------------------*
  Static Function Process(cDe,cAte) 
*-----------------------------------*  

Local oDlg
Local oMain     
Local oMemo

Local cTexto	:= "" 
Local cFile 	:= ""
Local cMask 	:= "Arquivos Texto (*.TXT) |*.txt|"


SX2->(DbSetOrder(1))
If SX2->(DbSeek(alltrim(cDe)))
            	
	While SX2->(!EOF()) .And. SX2->X2_CHAVE <= cATe  
    			
   		If chkFile(SX2->X2_CHAVE)   
     		cTexto += "Tabela "+SX2->X2_CHAVE+" criada/atualizada com sucesso."+CHR(13)+CHR(10)
       	Else
        	cTexto += "Erro tabela "+SX2->X2_CHAVE+", verificar. "+CHR(13)+CHR(10)       	
        EndIf
                	
    	SX2->(DbSkip())
 	EndDo                                         
                        
  	If 	!Empty(cTexto)  
                
   		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
		
	 	Define FONT oFont NAME "Mono AS" Size 5,12
		Define MsDialog oDlg Title "Log do processamento" From 3,0 to 340,417 Pixel

		@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont

		Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel
		Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		Activate MsDialog oDlg Center
                 
  	Else     
  	       
   		MsgInfo("Tabela(s) não encontrada(s)","HLB")   
   		 
   	EndIf 
          
Else   

	MsgInfo("Tabela(s) não encontrada(s)","HLB")      

EndIf    	
  

Return           
                                     



