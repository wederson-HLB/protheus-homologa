#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"          
#Include "colors.ch"   
#Include "pryor.ch" 
#include "Fileio.ch"   

/*
Funcao      : I49FAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importacao de dados     
Autor     	: José Augusto P. Alves  
Data     	: 15/01/07 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

  
*---------------------------------------*
USER FUNCTION I49FAT01() //FUNÇÃO INICIAL              
*---------------------------------------*
  
Private cBuffer,nHd13,nBtLidos,nHdl3,aLog,cEol,_cTime,_dDtConDe,_dDtConAt   
cCombo   := ""
aItems   := {"Faturamento","Clientes"}  
cArquivo := "C:\"+Space(50)

@ 200,001 To 380,420 Dialog oLeTxt Title "Importação dados "
@ 001,002 To 089,209 
@ 015,020 Say "Discovery " COLOR CLR_HRED, CLR_WHITE 
@ 025,020 Say "Importação de:"
@ 045,020 Say "Selecione o arquivo a ser importado:"
@ 025,060 ComboBox cCombo Items aItems Size 50,50  
@ 055,005 Say "Local " COLOR CLR_HBLUE, CLR_WHITE 
@ 055,020 Get cArquivo Size 180,180    
@ 070,098 BmpButton Type 14 Action fBuscaArq()
@ 070,128 BmpButton Type 01 Action fOkOpc()
@ 070,158 BmpButton Type 02 Action Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return     

//******************************************************************************************************************
//-------------------------------------------------------------------Abre Arquivo-----------------------------------
 
*-------------------------*
STATIC FUNCTION fBuscaArq()
*-------------------------*

cType    := "Arq.  | *.TXT"
cArquivo := Upper(cGetFile(cType, OemToAnsi("Selecione arquivo "+Subs(cType,1,6))))

If "PEDIDOS.TXT" $ cArquivo
   cCombo := "Faturamento"
Elseif "CLIENTES.TXT" $ cArquivo
   cCombo := "Clientes" 
EndIf

//cCombo   := If("PEDIDOS.TXT" $ cArquivo ,"Faturamento","Clientes")                 
               
Return(Nil)
            
//******************************************************************************************************************
//-------------------------------------------------------------------Direciona--------------------------------------

*----------------------*
STATIC FUNCTION fOkOpc()               
*----------------------*

   Close(oLeTxt)
   _cOcor:="VAZIO"
   cExec :=If(cCombo$ "Faturamento","1","2")
   If "1" $ cExec
      Processa ({||fOkArq("PED")},"Faturamento Discovery      ")     
   ElseIf "2" $ cExec   
      Processa ({||fOkArq("CLI")},"Clientes Discovery         ")  
   Else
      MsgInfo(" PEDIDOS.TXT - Arquivo de Pedidos / CLIENTES.TXT - Arquivo de Clientes")
   EndIf 
           
Return          

//**************************************************************************************************************************
//-------------------------------------------------------------------Leitura do Arquivo Pedidos-----------------------------

*---------------------------*
STATIC FUNCTION fOkArq(cTipo) 
*---------------------------*

Private aArray := {} 
Private nTamArq
Private cTexto  := "" 
Private cAscii  := ""   
Private cInfo   := ""   
Private Coluna  := 1 
Private cTamTab := If(cTipo $ "PED",27,15)
                  
cArq   := cTipo
fCriaTrab(cArq) 
DbUseArea(.T.,, "\UTIL\"+cArq, cArq, )

If cTipo $ "PED"
   DbSelectArea("PED")
Else
   DbSelectArea("CLI")
EndIf  

If File(cArquivo)            
   nHD      := fOpen(cArquivo)
   nTamArq  := fSeek(nHD,FS_SET,FS_END) 
   fSeek(nHD,0,0)
   cTexto := fReadStr(nHD,nTamArq)                                    
   While nTamArq > 0
      aAdd(aArray,Substr(cTexto,Coluna,1))
      Coluna++  
      cAscii := Asc(Substr(cTexto,Coluna,1))                                 
      If cAscii = 13
         nTamArray := Len(aArray)
         While nTamArray > 0
            nTab   := 0 
            nCont1 := 1 
            If cTipo $ "PED"
               PED->(DbAppend())
            Else
               CLI->(DbAppend())
            EndIf
            While nTab <= cTamTab               
               If Asc(aArray[nCont1]) <> 9                        
                  If Asc(aArray[nCont1]) <> 10 .And. Asc(aArray[nCont1]) <> 13 
                     cInfo += aArray[nCont1]
                  EndIf   
                     nCont1++
                     nTamArray--
               ElseIf Asc(aArray[nCont1]) = 9
                  InsereDados(nTab,cInfo)
                  cInfo  := ""
                  nTab++
                  nCont1++ 
                  nTamArray--
                  If nTab = cTamTab     
                     Aadd(aArray,"	")
                  EndIf
               EndIf  
            EndDo                                                      
         EndDo 
         aArray := {} 
      EndIf       
      nTamArq-- 
   EndDo                                             
   MsgInfo("Arquivo" + cTipo + "Gerado com Sucesso!")
   If cTipo $ "PED"
      ImportaCli()
   Else
      ImportaFor()
   EndIf   
   MsgInfo("Importação Gerada com Sucesso!") 
EndIf               
               
If cTipo $ "PED"
   PED->(DbCloseArea())
Else
   CLI->(DbCloseArea())
EndIf


Return       

           
//******************************************************************************************************************     
//------------------------------------------------Criação do Arquivo de Trabalho------------------------------------                                                             

*----------------------------------*
STATIC FUNCTION fCriaTrab(cArq)
*----------------------------------*
 
cArqTMP :="\UTIL\"+cArq                                     
aCampos := {}
 
AADD(aCAMPOS,{"A" ,"C",020,0})
AADD(aCAMPOS,{"B" ,"C",020,0})
AADD(aCAMPOS,{"C" ,"C",020,0})
AADD(aCAMPOS,{"D" ,"C",020,0})
AADD(aCAMPOS,{"E" ,"C",020,0})
AADD(aCAMPOS,{"F" ,"C",020,0})
AADD(aCAMPOS,{"G" ,"C",020,0})
AADD(aCAMPOS,{"H" ,"C",020,0})
AADD(aCAMPOS,{"I" ,"C",020,0}) 
AADD(aCAMPOS,{"J" ,"C",020,0})
AADD(aCAMPOS,{"K" ,"C",020,0})
AADD(aCAMPOS,{"L" ,"C",020,0})
AADD(aCAMPOS,{"M" ,"C",020,0})
AADD(aCAMPOS,{"N" ,"C",020,0})
AADD(aCAMPOS,{"O" ,"C",020,0})   
If cArq $ "CLI"                
   AADD(aCAMPOS,{"P" ,"C",080,0})
ElseIf cArq $ "PED"               
   AADD(aCAMPOS,{"P" ,"C",020,2})
   AADD(aCAMPOS,{"Q" ,"C",020,0})
   AADD(aCAMPOS,{"R" ,"C",020,0})
   AADD(aCAMPOS,{"S" ,"C",020,0})
   AADD(aCAMPOS,{"T" ,"C",020,0})
   AADD(aCAMPOS,{"U" ,"C",050,0})
   AADD(aCAMPOS,{"V" ,"C",020,0})
   AADD(aCAMPOS,{"W" ,"C",020,0})
   AADD(aCAMPOS,{"X" ,"C",020,0})
   AADD(aCAMPOS,{"Y" ,"C",020,0})
   AADD(aCAMPOS,{"Z" ,"C",020,0})
   AADD(aCAMPOS,{"AA" ,"C",020,0})
   AADD(aCAMPOS,{"AB" ,"C",050,0})
EndIf
                                  
If File("\UTIL\"+cArq+".DBF")
   FErase("\UTIL\"+cArq+".DBF")
Endif
DbCreate("\UTIL\"+cArq,aCAMPOS)       
 
Return

//------------------------------------------------Inserção no Arquivo-----------------------------------------------                                                             

*-------------------------------------*
STATIC FUNCTION InsereDados(nTab,cInfo)
*-------------------------------------*   
 
Begin Sequence                                       

   fName := FIELD(nTab+1)
   FIELD->&fName := cInfo                                      

End Sequence      

Return      

//------------------------------------------------Importação de Clientes-----------------------------------------------                                                             

*------------------------------------*
STATIC FUNCTION ImportaCli()
*------------------------------------*   

Private lCliente := .F.

Begin Sequence                                       
   
   DbSelectArea("SA1")
   SA1->(DbSetOrder(3))
   CLI->(DbGoTop())
   
   Do While Cli->(!Eof())
                         
      cCnpj := CLI->B
      cCnpj := StrTran(cCnpj, ".", "")
      cCnpj := StrTran(cCnpj, "/", "") 
      cCnpj := Alltrim(StrTran(cCnpj, "-", ""))                          
   
      lCliente := dbSeek(xFilial("SA1")+cCnpj)
      
      If !lCliente
         SA1->(DbAppend())
         SA1->A1_COD     := CLI->A
         SA1->A1_LOJA    := "01"
         SA1->A1_NOME    := CLI->E
         SA1->A1_NREDUZ  := CLI->E
         SA1->A1_TIPO    := "F"
         SA1->A1_END     := CLI->F+CLI->G
         SA1->A1_MUN     := CLI->H
         SA1->A1_EST     := CLI->I
         SA1->A1_CONTA   := "001"
         SA1->A1_CGC     := CLI->B
         SA1->A1_INSCR   := CLI->C
         SA1->A1_CONTATO := CLI->L
         SA1->A1_TEL     := CLI->M
         SA1->A1_FAX     := CLI->N
         SA1->A1_EMAIL   := CLI->O                       
      EndIf
      
      Cli->(DbSkip())
           
   EndDo    
   
   DbCloseArea("SA1")
   
End Sequence      

Return
//------------------------------------------------Fim do Programa---------------------------------------------------