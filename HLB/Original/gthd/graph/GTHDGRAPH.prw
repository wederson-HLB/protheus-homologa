#Include "APWEBEX.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDA003  �Autor  �Tiago Luiz Mendon�a � Data �  31/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de graficos de chamados de help-desk.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                
/*
Funcao      : GTHDGRAPH
Parametros  : Nenhum                       '
Retorno     : Nil
Objetivos   : Rotina APWBEX de grafico de chamados.
Autor       : Tiago Luiz Mendon�a
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


