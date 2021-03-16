#Include "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDA003  ºAutor  ³Tiago Luiz Mendonça º Data ³  31/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de graficos de chamados de help-desk.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                
/*
Funcao      : GTHDGRAPH
Parametros  : Nenhum                       '
Retorno     : Nil
Objetivos   : Rotina APWBEX de grafico de chamados.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/08/11 20:00
*/

*--------------------------*
  User Function GTHDGRAPH()
*--------------------------*    

Local cHtml := ""   
  
   WEB EXTENDED INIT cHtml

      cHtml += ExecInPage("Login")    
         ConOut("Senha antes")   

   WEB EXTENDED END 
   
Return cHtml 
   
*----------------------------*
  User Function IdLogin()
*----------------------------*
   
Local cHtml := ""   
  
   WEB EXTENDED INIT cHtml
   
   If !Empty(HttpPost->cUser)
      If !Empty(HttpPost->cPass)
         If Alltrim(HttpPost->cPass)="H12233"   
            ConOut("Senha Ok") 
            cHtml  +=U_GTHDGRA2() 
         Else
            ConOut(HttpPost->cUser)
            ConOut(HttpPost->cPass)
         EndIf
      Else
         ConOut("Informe a senha")
      EndIf          
   Else
     ConOut("Informe o usuario")
   Endif

WEB EXTENDED END 


Return  cHtml  


