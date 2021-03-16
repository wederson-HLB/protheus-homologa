#INCLUDE "RWMAKE.CH"           

/*
Funcao      : BUSCA_PCM
Parametros  : cOpcao
Retorno     : nRetorno
Objetivos   : Função que retorna campo DA1_P_PCM/DA1_F_PCM da tabela de preço
Autor     	: 
Data     	: 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/
  
*--------------------------------*
 USER FUNCTION BUSCA_PCM(cOpcao)   
*--------------------------------*
    
     Local aArea:=GetArea()
     Local lSaida:=.F.
     Local nP_PCM:=0
     Local nF_PCM:=0
     Local nRetorno:=0
     
     DbSelectArea('DA1')
     DbSetOrder(2)
     DbSeek(xFilial('DA1')+SB1->B1_COD+M->C5_TABELA,.T.)
     While !EOF() .And. (DA1->DA1_CODTAB+DA1->DA1_CODPRO)==(M->C5_TABELA+SB1->B1_COD) .And. !lSaida   
           //--> Busca Tabela
           DbSelectArea('DA0')
           DbSetOrder(1)
           DbSeek(xFilial('DA0')+M->C5_TABELA)
           
           If M->C5_EMISSAO >= DA0->DA0_DATDE .And. (M->C5_EMISSAO <= DA0->DA0_DATATE .OR. EMPTY(DA0->DA0_DATATE)) .AND. DA0->DA0_ATIVO='1'
              IF M->C5_EMISSAO <= DA1->DA1_DATVIG .OR. EMPTY(DA1->DA1_DATVIG)
                 nP_PCM:=DA1->DA1_P_PCM          
                 nF_PCM:=DA1->DA1_F_PCM
                 lSaida:=.T.
              EndIf
           EndIf 
           If !lSaida   
              DbSelectArea('DA1')
              DbSetOrder(2)
              DbSkip()
           EndIf
      EndDo         
      RestArea(aArea)
      
      If cOpcao =="P"
         nRetorno:=nP_PCM
      Else
         nRetorno:=nF_PCM
      EndIf              
      
Return(nRetorno)      