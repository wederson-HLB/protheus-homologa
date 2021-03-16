#include "rwmake.ch"
#INCLUDE 'TBICONN.CH'
#include "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"

/*
Funcao      : IMPLNETI
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão de etiquetas
Autor       : Tiago Luiz Mendonça
Data/Hora   : 02/07/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 07/02/2012
Módulo      : Faturamento.
*/ 



*------------------------------*                     
  User Function IMPLNETI() 
*------------------------------*  
      
Local nX:=1 
Local cPerg:="LnDOC"  
Local cPorta:="LPT1" 
Local cNota,cSerie
Local nQtd,cVol,nTipo                     

  /*
  If !(cEmpAnt $ "40" ) //.Or. cEmpAnt $ "99" )  
      MsgStop("Rotina especificaNeogem, liberado apenas para empresa teste","Atenção") 
      Return .F.
   EndIf
    
  */
  
  IF !(Pergunte(cPerg,.T.))
     Return .F.
  EndIf         
  
  cNota :=mv_par01     
  cSerie:=mv_par02 
  nTipo :=mv_par03
  
  DbSelectArea("SF2")   
  SF2->(DbSetOrder(1))
  If !(SF2->(DbSeek(xFilial("SF2")+cNota+cSerie)))
     MsgStop("Nenhuma nota encontrada, verifique os parametros.","Atenção")         
     Return .F.
  EndIf
   
  cVol:=Alltrim(Str(SF2->F2_VOLUME1))      
  nQtd:=SF2->F2_VOLUME1 
  
  DbSelectArea("SA1") 
  SA1->(DbSetOrder(1))
  SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
                        
  DbSelectArea("SA4") 
  SA4->(DbSetOrder(1))
  SA4->(DbSeek(xFilial("SA4")+SF2->F2_TRANSP))  
      
  DbSelectArea("SD2") 
  SD2->(DbSetOrder(3))
  SD2->(DbSeek(xFilial("SD2")+cNota+cSerie))
  
  MSCBPRINTER("ELTRON",cPorta,,97,.F.) 
  
  If nTipo==1     
  
     MSCBLOADGRF("neogen.pcx")
     MSCBBEGIN(1,6,97) 
     MSCBGRAFIC(2,3,"neogen")
     MSCBEND()
  
  
  Else
  
  For i:=1 to nQtd

     MSCBBEGIN(1,6,97) 
     
     MSCBSAY(15,11,'NEOGEN DO BRASIL',"N","2","3,3")   
     
     MSCBSAY(10,23,'NOTA FISCAL : '+Alltrim(cNota),"N","2","2,2")   
     
     MSCBSAY(10,30,'CLIENTE - '+Alltrim(SA1->A1_COD),"N","2","1,2")
     MSCBSAY(10,35,Alltrim(SA1->A1_NOME),"N","2","1,2")
     MSCBSAY(10,40,Alltrim(SA1->A1_END),"N","2","1,2")
     MSCBSAY(10,45,Alltrim(SA1->A1_BAIRRO),"N","2","1,2")   
     MSCBSAY(10,50,Alltrim(SA1->A1_MUN)+" - "+Alltrim(SA1->A1_EST)+' CEP. '+Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")),"N","2","1,2")
     //MSCBSAY(10,55,' CEP. '+Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")),"N","2","1,2")      
      
     MSCBSAY(10,60,'DATA '+DTOC(DDATABASE),"N","2","1,2") 
     MSCBSAY(10,65,'TRANSPORTADORA - '+Alltrim(SA4->A4_NOME),"N","2","1,2")  
     MSCBSAY(10,70,'PEDIDO - '+Alltrim(SD2->D2_PEDIDO) ,"N","2","1,2")
     MSCBSAY(10,82,'VOLUME',"N","2","3,3")  
     MSCBSAY(40,82,Alltrim(Str(i))+'/'+cVol,"N","2","3,3")    
   
     MSCBEND()
   
  next
  
  EndIf

MSCBCLOSEPRINTER()


Return
