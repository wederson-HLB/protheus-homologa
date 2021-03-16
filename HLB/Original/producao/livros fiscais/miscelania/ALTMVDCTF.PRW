#include "rwmake.ch"     
#Include "colors.ch"
                                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALTMVDCTF ºAutor Adriane Sayuri        º Data ³  09/16/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela apresentada antes da chamada da rotina MATA978        º±±
±±º          ³ para alteração da TES.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   

/*
Funcao      : ALTMVDCTF
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela apresentada antes da chamada da rotina MATA978 para alteração da TES. 
Autor     	: Adriane Sayuri
Data     	: 09/16/10 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Livros Fiscais.
*/

*---------------------------*
  User Function ALTMVDCTF()  
*---------------------------*

Local cConteudo0:= SPACE(250)
Local cConteudo1:= SPACE(250)
Local cConteudo2:= SPACE(250)
Local cConteudo3:= SPACE(250)
Local cConteudo4:= SPACE(250)
Private nLinha    := 40
Private aConteudo := {}
Private cNomeEmp  := AllTrim(SM0->M0_NOME)
Private oDlg1

                        
CriaMVDCTF() 

cConteudo0:= PadR(GetMV("MV_DCTF000"),250)
cConteudo1:= PadR(GetMV("MV_DCTF001"),250)
cConteudo2:= PadR(GetMV("MV_DCTF002"),250)
cConteudo3:= PadR(GetMV("MV_DCTF003"),250)
cConteudo4:= PadR(GetMV("MV_DCTF004"),250)
      
@ 100,001 to 740,760 Dialog oDlg1 Title "Esta rotina irá alterar os parametros para geração do DCTF -"+cNomeEmp
@ 010,020 Say "Atenção ao alterar ou preencher os parâmetros. Siga atentamente as instruções abaixo: " COLOR CLR_HRED, CLR_WHITE
@ 030,020 Say "Exemplo de conteúdo: "
@ 040,020 Say "5960=596001S;5987=598701S;5979=597901S;0561=056101S;5952=595202Q;"
@ 060,020 Say "A composição do conteúdo é WWWW=XXXXYYZ, em que:"
@ 080,020 Say "WWWW: Código de receita utilizado no sistema Protheus."
@ 090,020 Say "XXXX: Código de receita na DCTF com a mesma característica do código do sistema."
@ 100,020 Say "YY: Variação de acordo com a DCTF."
@ 110,020 Say "Z: Periodicidade de acordo com o código da receita na DCTF. Deve ser informado:"
@ 130,020 Say "D: para periodicidade Diaria;"  
@ 140,020 Say "S: para periodicidade Semanal;"     
@ 150,020 Say "X: para periodicidade Decendial;"  
@ 160,020 Say "Q: para periodicidade Quinzenal;"  
@ 170,020 Say "M: para periodicidade Mensal;"  
@ 130,150 Say "B: para periodicidade Bimestral;"  
@ 140,150 Say "T: para periodicidade Trimestral;"  
@ 150,150 Say "U: para periodicidade Quadrimestral;"  
@ 160,150 Say "E: para periodicidade Semestral;"  
@ 170,150 Say "A: para periodicidade Anual."  
@ 190,020 Say "Para separar grupos de relacionamento, utilize sempre o ponto e vírgula (';')."  
@ 200,020 Say "O ponto-e-vírgula é obrigatório sempre no final, como último caracter, mesmo quando houver, apenas 1 item. Ex: 0561=056101S;"  

@ 215,020 Say "DTCF000: "  
@ 215,050 Get cConteudo0 Picture "@!" Size 300,20
@ 230,020 Say "DCTF001: "  
@ 230,050 Get cConteudo1 Picture "@!" Size 300,20
@ 245,020 Say "DCTF002: "  
@ 245,050 Get cConteudo2 Picture "@!" Size 300,20
@ 260,020 Say "DCTF003: "  
@ 260,050 Get cConteudo3 Picture "@!" Size 300,20
@ 275,020 Say "DCTF004: "  
@ 275,050 Get cConteudo4 Picture "@!" Size 300,20

@ 295,110 Button "_Confirmar" Size 50,15 Action ConfParam(cConteudo0, cConteudo1, cConteudo2, cConteudo3, cConteudo4) 
@ 295,200 Button "_Sair" Size 40,15 Action Close(oDlg1)
Activate Dialog oDlg1 CENTERED


Return                                                 

/*----------------------------------------------------------------------------------*/
Static Function ConfParam(cConteudo0, cConteudo1, cConteudo2, cConteudo3, cConteudo4)
/*----------------------------------------------------------------------------------*/
            
Local lGravou := .F.
Local lTem    := .F.  
 
                 
If Empty(cConteudo0) .And. Empty(cConteudo1) .And. Empty(cConteudo2) .And. Empty(cConteudo3) .And.!Empty(cConteudo4) 
   MsgStop("Não foram preenchidos nenhum parâmetro.","Atenção!")
EndIF

DbSelectArea("SX6")   
SX6->(DbSetOrder(1))

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF001"))
   lExistParam := .T.
EndIf

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF002"))
   lExistParam := .T.
EndIf

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF003"))
   lExistParam := .T.
EndIf

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF004"))
   lExistParam := .T.
EndIf
     
If  ApMsgYesNo("Deseja gravar as alterações nos parametros do DCTF?","Comfirma")
   If lTem
      CriaMVDCTF() 
   Else
   

   SX6->(DbGoTop())
   
   If SX6->(DbSeek(xFilial("SX6")+"MV_DCTF000"))
      RecLock("SX6",.f.)
      Replace X6_CONTEUD With Alltrim(cConteudo0)
      Replace X6_CONTSPA With Alltrim(cConteudo0)
      Replace X6_CONTENG With Alltrim(cConteudo0)
      MsUnlock()
      lGravou := .T.
   EndIf

   If SX6->(DbSeek(xFilial("SX6")+"MV_DCTF001"))
      RecLock("SX6",.f.)
      Replace X6_CONTEUD With Alltrim(cConteudo1)
      Replace X6_CONTSPA With Alltrim(cConteudo1)
      Replace X6_CONTENG With Alltrim(cConteudo1)
      MsUnlock()
      lGravou := .T.
   EndIf

   If SX6->(DbSeek(xFilial("SX6")+"MV_DCTF002"))
      RecLock("SX6",.f.)
      Replace X6_CONTEUD With Alltrim(cConteudo2)
      Replace X6_CONTSPA With Alltrim(cConteudo2)
      Replace X6_CONTENG With Alltrim(cConteudo2)
      MsUnlock()
      lGravou := .T.
   EndIf

   If SX6->(DbSeek(xFilial("SX6")+"MV_DCTF003"))
      RecLock("SX6",.f.)
      Replace X6_CONTEUD With Alltrim(cConteudo3)
      Replace X6_CONTSPA With Alltrim(cConteudo3)
      Replace X6_CONTENG With Alltrim(cConteudo3)
      MsUnlock()    
      lGravou := .T.
   EndIf

   If SX6->(DbSeek(xFilial("SX6")+"MV_DCTF004"))
      RecLock("SX6",.f.)
      Replace X6_CONTEUD With Alltrim(cConteudo4)
      Replace X6_CONTSPA With Alltrim(cConteudo4)
      Replace X6_CONTENG With Alltrim(cConteudo4)
      MsUnlock()
      lGravou := .T.
   EndIf
EndIf

EndIf

If lGravou     
   Close(oDlg1)                                        
EndIf                    

Return .T. 

/*-------------------------*/
Static Function CriaMVDCTF() 
/*-------------------------*/
Local lRet := .F.

DbSelectArea("SX6")   
SX6->(DbSetOrder(1))

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF001"))
   RecLock("SX6",.T.)  
   SX6->X6_FIL    := ''
   SX6->X6_VAR    := 'MV_DCTF001'
   SX6->X6_TIPO   := 'C'
   SX6->X6_DESCRIC:= 'Referencia de codigos de retencäo do sistema para '
   SX6->X6_DSCSPA := 'Referencia de cod. de retencion del sistema para  '
   SX6->X6_DSCENG := 'Reference of the system withholding codes for     '
   SX6->X6_DESC1  := 'os adotados pela DCTF com a periodicidade         '
   SX6->X6_DSCSPA1:= 'los adoptados por DCTF con la periodicidad        '
   SX6->X6_DSCENG1:= 'those adopted by DCTF with the corresponding      '
   SX6->X6_DESC2  := 'correspondente                                    '
   SX6->X6_DSCSPA2:= 'correspondiente                                   '
   SX6->X6_DSCENG2:= 'periodicity.                                      '
   SX6->X6_PROPRI := 'S'
   SX6->X6_PYME   := 'S'  
   lRet := .T.
   MsUnlock()  
EndIf

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF002"))
   RecLock("SX6",.T.)  
   SX6->X6_FIL    := ''
   SX6->X6_VAR    := 'MV_DCTF002'
   SX6->X6_TIPO   := 'C'
   SX6->X6_DESCRIC:= 'Referencia de codigos de retencäo do sistema para '
   SX6->X6_DSCSPA := 'Referencia de cod. de retencion del sistema para  '
   SX6->X6_DSCENG := 'Reference of the system withholding codes for     '
   SX6->X6_DESC1  := 'os adotados pela DCTF com a periodicidade         '
   SX6->X6_DSCSPA1:= 'los adoptados por DCTF con la periodicidad        '
   SX6->X6_DSCENG1:= 'those adopted by DCTF with the corresponding      '
   SX6->X6_DESC2  := 'correspondente                                    '
   SX6->X6_DSCSPA2:= 'correspondiente                                   '
   SX6->X6_DSCENG2:= 'periodicity.                                      '
   SX6->X6_PROPRI := 'S'
   SX6->X6_PYME   := 'S'    
   lRet := .T.
   MsUnlock()
EndIf

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF003"))
   RecLock("SX6",.T.)  
   SX6->X6_FIL    := ''
   SX6->X6_VAR    := 'MV_DCTF003'
   SX6->X6_TIPO   := 'C'
   SX6->X6_DESCRIC:= 'Referencia de codigos de retencäo do sistema para '
   SX6->X6_DSCSPA := 'Referencia de cod. de retencion del sistema para  '
   SX6->X6_DSCENG := 'Reference of the system withholding codes for     '
   SX6->X6_DESC1  := 'os adotados pela DCTF com a periodicidade         '
   SX6->X6_DSCSPA1:= 'los adoptados por DCTF con la periodicidad        '
   SX6->X6_DSCENG1:= 'those adopted by DCTF with the corresponding      '
   SX6->X6_DESC2  := 'correspondente                                    '
   SX6->X6_DSCSPA2:= 'correspondiente                                   '
   SX6->X6_DSCENG2:= 'periodicity.                                      '
   SX6->X6_PROPRI := 'S'
   SX6->X6_PYME   := 'S'    
   lRet := .T.
   MsUnlock()   
EndIf

If !SX6->(DbSeek(xFilial("SX6")+"MV_DCTF004"))
   RecLock("SX6",.T.)  
   SX6->X6_FIL    := ''
   SX6->X6_VAR    := 'MV_DCTF004'
   SX6->X6_TIPO   := 'C'
   SX6->X6_DESCRIC:= 'Referencia de codigos de retencäo do sistema para '
   SX6->X6_DSCSPA := 'Referencia de cod. de retencion del sistema para  '
   SX6->X6_DSCENG := 'Reference of the system withholding codes for     '
   SX6->X6_DESC1  := 'os adotados pela DCTF com a periodicidade         '
   SX6->X6_DSCSPA1:= 'los adoptados por DCTF con la periodicidad        '
   SX6->X6_DSCENG1:= 'those adopted by DCTF with the corresponding      '
   SX6->X6_DESC2  := 'correspondente                                    '
   SX6->X6_DSCSPA2:= 'correspondiente                                   '
   SX6->X6_DSCENG2:= 'periodicity.                                      '
   SX6->X6_PROPRI := 'S'
   SX6->X6_PYME   := 'S'    
   lRet := .T.
   MsUnlock()   
EndIf

Return lRet                                      
