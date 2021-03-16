#include "protheus.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �JKFAT005  �Autor  �Innovare Solu��es   � Data �  10/21/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Amarra��o Cliente x Alvara                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
                        	

User Function JKFAT005()


Local aCores := {}
Private cCadastro := "Clientes x Alvar�"
Private aRotina := {}  


Private aRotina := 	{{ "Pesquisar"  ,"AxPesqui",0 , 1},;  //"Pesquisar"			
					 { "Visualizar" ,"AxVisual", 0 , 2},;  //"Visualizar"			
					 { "Incluir"    ,"U_JKFAT006()", 0 , 3},;  //"Incluir"			
					 { "Alterar"    ,"U_JKFAT006()", 0 , 4 },;  //"Alterar"			
					 { "Excluir"    ,"AxDeleta", 0 , 5 },;  //"Excluir"
					 {"Legenda" 	,"U_JKFAT008()" ,0,6}} // Legenda





AADD(aCores,{"Z3_SITUA == 'A'" ,"BR_VERDE" })
AADD(aCores,{"Z3_SITUA == 'E'" ,"BR_VERMELHO" })


dbSelectArea("SZ3")
dbSetOrder(1)    


mBrowse(6, 1,22,75,"SZ3",,,,,,aCores)

Return .T.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �JKFAT006  �Autor  �Innovare Solu��es   � Data �  10/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza Inclus�o ou Altera��o                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function JKFAT006()   


Local aParam  := {} 
Private aButtons:= {} 
Private aCpos := {"Z3_PROTOC","Z3_DTPROTO"} 

if INCLUI   


	nOpca := AxInclui("SZ3",SZ3->(Recno()), 3,,,, "U_JKFAT007()", .F., , aButtons, aParam,,,.T.,,,,,) 


Elseif ALTERA


	If SZ3->Z3_SITUA == "E"	
	     
		Alert("Este Alvar� n�o pode ser alterado pois ja se encontra na situa��o de Encerrado !","Aten��o")
		Return .F.
	
	Endif              
	
		
	
	nOpca := AxAltera("SZ3",SZ3->(Recno()),4,,aCpos,,,,,,aButtons,aParam,,,.T.,,,,,)



EndIf


Return

   
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �JKFAT007   �Autor  �Innovare Solucoes  � Data �  10/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza Status de Alvara								   ��
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function JKFAT007()


Local cQuery := "" 


		cQuery := "	SELECT Z3_FILIAL,Z3_CODCLI,Z3_LOJA,Z3_ALVARA,Z3_VALIDAD,Z3_SITUA FROM " + RETSQLNAME("SZ3")
		cQuery += "	WHERE D_E_L_E_T_<>'*'
		cQuery += "	AND Z3_CODCLI = '" + M->Z3_CODCLI + "'" 
		cQuery += "	AND Z3_LOJA   = '" + M->Z3_LOJA   + "'"
		cQuery += "	AND Z3_ALVARA = '" + M->Z3_ALVARA + "'"
		cQuery += "	AND Z3_SITUA  = 'A' " //  Busca somente com status de Ativo
		
		
		If SELECT("QSZ3") > 1
			QSZ3->(DbCloseArea())
		Endif 
				                                                          
		
		TcQuery cQuery New Alias "QSZ3" 
		
	
		// Valida se existe algum Alvara com Status de Ativo para o Alvara Informado
		If !Empty(QSZ3->Z3_ALVARA)
		     
			If QSZ3->Z3_VALIDAD > DTOS(DATE()) // Valida se o Alvara informado ainda nao esta vencido.
		
		    	   If MsgYesNo("Existe Alvar� Ativo para o cliente infornado com Validade At� " + DTOC(STOD(QSZ3->Z3_VALIDAD)) + " . Deseja Continuar ? " ,"Aten��o")
		                
		                	                
		                DbSelectArea("SZ3") 
		           		SZ3->(DbSetOrder(2))
		           			
		           		SZ3->(DbSeek(XFILIAL("SZ3")+M->Z3_CODCLI+M->Z3_LOJA+M->Z3_ALVARA+"A")) // Posiciona no registro para Encerrar o Alvara anterior
		           		
		           		Begin Transaction
		           		
		           			Reclock("SZ3",.F.)
		           			
		           				SZ3->Z3_SITUA := "E" // Encerra o Alvar� Anterior
		           			
		           			
		           			SZ3->(MsUnlock())
		           		
		           		End Transaction
		    
		    	   Else
		    	  
		    	  		Return .F.
		    	  
		    	  
		    	   Endif
		    
		    
		    Else // Se existe Alvar� mais ja esta vencido nao solita permiss�o
		    
		    			DbSelectArea("SZ3") 
		           		SZ3->(DbSetOrder(1))
		           			
		           		SZ3->(DbSeek(XFILIAL("SZ3")+M->Z3_CODCLI+M->Z3_LOJA+M->Z3_ALVARA)) // Posiciona no registro para Encerrar o Alvara anterior
		           		
		           		Begin Transaction
		           		
		           			Reclock("SZ3",.F.)
		           			
		           				SZ3->Z3_SITUA := "E" // Encerra o Alvar� Anterior
		           			
		           			
		           			SZ3->(MsUnlock())
		           		
		           		End Transaction
		    
		    
		    
		    Endif
		    
		Endif
		
		        

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �JKFAT008 �Autor  �Innovare Solucoes    � Data �  08/09/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function JKFAT008()
                                                                                            
Local cCadastro:= "Cliente x Alvar�"            


acores1 := {{'BR_VERMELHO',"Alvar� Encerrado"},;
			{'BR_VERDE',"Alvar� Ativo"}}

BrwLegenda(cCadastro,"Cliente x Alvar�",acores1)

Return Nil

 