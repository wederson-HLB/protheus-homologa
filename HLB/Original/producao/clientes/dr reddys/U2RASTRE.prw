#include "rwmake.ch"        

/*
Funcao      : U2RASTRE
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão relatório de rastreabilidade de produtos
Autor     	: Tiago Luiz Mendonça
Data     	: 11/06/2010
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Estoque.
*/

*----------------------------*
  User Function U2RASTRE()      
*----------------------------*   
                   
Private  nOrdem:= nTipo:= nCntImpr := 0   
Private  dDataIni,dDataFim 
Private  nlimite   := 220         
Private  cTamanho  := "G"
Private  nPag      := 1
Private  cDesc1    := "Rastreabilidade de produtos"
Private  cDesc2    := ""
Private  cDesc3    := ""
Private  aOrd      := {}          
Private  m_pag     := 1
Private  cRodaTxt  := "REGISTRO(S)"
Private  aLinha    := {}
Private  nomeprog  := "U2Rastre"
Private  nLastKey  := 0
Private  cPerg     := "U201"
Private  nivel     := 1  
Private  wnrel     := "U2Rastre"  
Private  aCampos   := {}                    
Private  lin       := 100
Private  cTitulo   := "Rastreabilidade de lotes"
Private  aReturn   := { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
Private  cLoteIni  :=cLoteFim :=cProdIni :=cProdFim :=""
Private  cTipES,cTipIDT

If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf  

If !(cEmpAnt $ "U2" .Or. cEmpAnt $ "99" )  
   MsgStop("Rotina especifica Dr Reddys","Atenção") 
   Return .F.
EndIf

          // Variaveis utilizadas para Impressao do Cabecalho e Rodape

cString  :="WORK"
cabec2:=""

pergunte(cPerg,.T.)

cTitulo := cTitulo + ", de "+ Alltrim(mv_par01) + " a "+Alltrim(mv_par02)

cLoteIni  := mv_par01
cLoteFim  := mv_par02  
cProdIni  := mv_par03
cProdFim  := mv_par04
cTipES    := mv_par05  
cTipIDT   := mv_par06

If cTipES == 1
   cabec1   := "    Lote      Produto       Descrição                     Armazem    Qtd    Nota      Serie  Data     Forn.\Cliente                              Endereço "
   //            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
Else
   cabec1   := "    Lote      Produto       Descrição                     Armazem    Qtd    Nota      Serie  Data     Cliente                                  Endereço "
   //            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
EndIf


MontaQry()
            
wnrel:=SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey()== 27 .or. nLastKey== 27 
	Return
Endif
         
SetDefault(aReturn,cString)

If LastKey()== 27 .Or. nLastKey==27
   dbSelectArea("WORK")
   DbCloseArea("WORK")
   Return
Endif
                 
RptStatus({|| GeraDados()},cTitulo)

If aReturn[5] == 1  
     Set Printer TO
     dbcommitAll()
     ourspool(wnrel)
Endif

Ms_Flush()

Return .T.


*----------------------------*
  Static Function GeraDados()
*----------------------------*

Work->(DbGoTop())
                  
If Work->(Eof())
  MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
  WORK->(DbCloseArea())
  Return .F.
EndIf 

Do while Work->(!Eof()) 

   SomaLin()   
   
   If cTipES=1
   
      @ lin,003 PSAY Work->D1_LOTECTL
      @ lin,014 PSAY Work->D1_COD
      SB1->(DbSetOrder(1))
      If SB1->(DbSeek(xFilial("SB1")+Work->D1_COD))
         @ lin,029 PSAY SB1->B1_DESC
      EndIf
   
      @ lin,061 PSAY Work->D1_LOCAL
      @ lin,065 PSAY Work->D1_QUANT  picture    "@E 99999.99"
      @ lin,076 PSAY Work->D1_DOC
      @ lin,087 PSAY Work->D1_SERIE
      @ lin,092 PSAY DTOC(work->D1_EMISSAO) 
      If Work->D1_TIPO $ "B/D"
         SA1->(DbSetOrder(1))   
         If SA1->(DbSeek(xFilial("SA1")+Work->D1_FORNECE))
            @ lin,102 PSAY SA1->A1_NOME 
            @ lin,143 PSAY ALLTRIM(SA1->A1_END) + " - " + ALLTRIM(SA1->A1_MUN) + "," + " " + SA1->A1_EST +" - CEP " + SA1->A1_CEP              
         EndIf
      Else
         SA2->(DbSetOrder(1))   
         If SA2->(DbSeek(xFilial("SA2")+Work->D1_FORNECE))
            @ lin,102 PSAY SA2->A2_NOME
            @ lin,143 PSAY ALLTRIM(SA2->A2_END) + " - " + ALLTRIM(SA2->A2_MUN) + "," + " " + SA2->A2_EST +" - CEP "  + SA2->A2_CEP                      
         EndIf
      EndIf  

   
   Else   
   
      @ lin,003 PSAY Work->D2_LOTECTL
      @ lin,014 PSAY Work->D2_COD
      SB1->(DbSetOrder(1))
      If SB1->(DbSeek(xFilial("SB1")+Work->D2_COD))
         @ lin,029 PSAY SB1->B1_DESC
      EndIf
   
      @ lin,061 PSAY Work->D2_LOCAL
      @ lin,065 PSAY Work->D2_QUANT  picture    "@E 99999.99"
      @ lin,076 PSAY Work->D2_DOC
      @ lin,087 PSAY Work->D2_SERIE
      @ lin,092 PSAY DTOC(work->D2_EMISSAO) 
      If Work->D2_TIPO $ "B/D"
         SA2->(DbSetOrder(1))   
         If SA2->(DbSeek(xFilial("SA2")+Work->D2_CLIENTE))
            @ lin,102 PSAY SA2->A2_NOME                                                                    	
            @ lin,143 PSAY ALLTRIM(SA2->A2_END) + " - " + ALLTRIM(SA2->A2_MUN) + "," + " " + SA2->A2_EST +" - CEP " + SA2->A2_CEP                 
         EndIf
      Else
         SA1->(DbSetOrder(1))   
         If SA1->(DbSeek(xFilial("SA1")+Work->D2_CLIENTE))
            @ lin,102 PSAY SA1->A1_NOME
            @ lin,143 PSAY ALLTRIM(SA1->A1_END) + " - " + ALLTRIM(SA1->A1_MUN) + "," + " " + SA1->A1_EST +" - CEP "  + SA1->A1_CEP        
         EndIf
      EndIf  

   
   EndIf                                  

   Work->(dbskip())

EndDo  
 
 SomaLin()  
 SomaLin()
       
@ lin,000 PSAY replicate("_",220)    
                  
Roda(nCntImpr,cRodaTxt,cTamanho)  

     

Return .T.
           
*----------------------------*
  Static Function MontaQry()
*----------------------------* 
Local nI := 0                                  
Local cFil:=xFilial("SD1")

 
If cTipES == 1   //Entrada
 
   aStruSD1:= SD1->(DbStruct())        

   cQuery:= "SELECT D1.*"
   cQuery+=" FROM "+RetSqlName("SD1")+" D1 "
   cQuery+=" WHERE  D1.D_E_L_E_T_<>'*' and D1.D1_FILIAL ='"+cFil+"'"
   cQuery+=" AND D1.D1_LOTECTL>='"+cLoteIni+"'"
   cQuery+=" AND D1.D1_LOTECTL<='"+cLoteFim+"'" 
   cQuery+=" AND D1.D1_COD>='"+cProdIni+"'"
   cQuery+=" AND D1.D1_COD<='"+cProdFim+"'"
   cQuery+=" AND D1.D1_TIPO<>'C'"  
   
   If cTipIDT  = 1 // Importacao
      cQuery+=" AND D1.D1_TIPO='N' " 
      cQuery+=" AND D1_CF IN ('3949','3102') "
   ElseIf cTipIDT  = 2 // Devolução
      cQuery+=" AND D1.D1_TIPO='D' " 
      cQuery+=" AND D1_CF IN ('1202','1411') " 
   Else
      cQuery+=" AND D1.D1_TIPO IN ('D','N') "   
      cQuery+=" AND D1.D1_CF IN ('3949','3102','1202','1411') "  
   EndIf
                                                         
   cQuery	:=	ChangeQuery(cQuery)
   DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'WORK',.F.,.T.)

   For nI := 1 To Len(aStruSD1)
      If aStruSD1[nI][2] <> "C" .and.  FieldPos(aStruSD1[nI][1]) > 0
         TcSetField("WORK",aStruSD1[nI][1],aStruSD1[nI][2],aStruSD1[nI][3],aStruSD1[nI][4])
      EndIf
   Next nI
             
Else   
   
   aStruSD2:= SD2->(DbStruct())           

   cQuery:= "SELECT D2.*"
   cQuery+=" FROM "+RetSqlName("SD2")+" D2 "
   cQuery+=" WHERE  D2.D_E_L_E_T_<>'*' and D2.D2_FILIAL ='"+cFil+"'"        
   cQuery+=" AND D2.D2_LOTECTL>='"+cLoteIni+"'"
   cQuery+=" AND D2.D2_LOTECTL<='"+cLoteFim+"'" 
   cQuery+=" AND D2.D2_COD>='"+cProdIni+"'"
   cQuery+=" AND D2.D2_COD<='"+cProdFim+"'"
   cQuery+=" AND D2.D2_TIPO<>'C'" 
   cQuery+=" AND D2.D2_CF IN ('5910','5102','5949','5911','5102','6102','5106','6106','6108','6403','5403','5910') "
                                           
   cQuery	:=	ChangeQuery(cQuery)
   DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'WORK',.F.,.T.)

   For nI := 1 To Len(aStruSD2)
      If aStruSD2[nI][2] <> "C" .and.  FieldPos(aStruSD2[nI][1]) > 0
         TcSetField("WORK",aStruSD2[nI][1],aStruSD2[nI][2],aStruSD2[nI][3],aStruSD2[nI][4])
      EndIf
   Next nI

EndIf

Return


*----------------------------*
  Static Function Somalin()
*----------------------------*

   lin := lin + 1
   
   if lin > 58
       cabec(ctitulo,cabec1,cabec2,wnrel,cTamanho,nTipo)
       lin := 8
   endif

Return(nil)   
   
   