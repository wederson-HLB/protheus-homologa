#include "Protheus.ch"
#include "Topconn.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �JKFAT009     �Autor  �Innovare Solu��es   � Data �  10/22/13���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function JKFAT009()   

Local cQryPro := "" 
Local lRet := .T. 
Local nLinhas := 0
	

cQryPro:= " SELECT Z4_CODPRO,Z1_COD,Z1_BLQVEN FROM " + RETSQLNAME("SZ4")+ " Z4," + RETSQLNAME("SZ1")+ " Z1"
cQryPro+= " WHERE Z4.D_E_L_E_T_<>'*' AND Z1.D_E_L_E_T_<>'*'"
cQryPro+= " AND Z4_FILIAL = Z1_FILIAL"
cQryPro+= " AND Z4_ALVARA = Z1_COD"	
cQryPro+= " AND Z4_CODPRO = '" + M->C6_PRODUTO + "'"
cQryPro+= " AND Z1_STATUS = 'A'"
	

If SELECT("QSZ4") > 1
	QSZ4->(DbCloseArea())
Endif 
				     
TcQuery cQryPro New Alias "QSZ4"    
 


Count To nLinhas // conta a quandiade registros encontrados na query  
                 
QSZ4->(DbGoTop()) 

DbSelectArea("SZ3")
SZ3->(DbSetOrder(2))


if nLinhas > 1 // Produto possui mais de 1 Alvar�
     
 	
 	While QSZ4->(!EOF())
 	
 	
 				if SZ3->(DbSeek(XFILIAL("SZ3")+M->C5_CLIENTE+M->C5_LOJACLI+QSZ4->Z1_COD+"A")) // Verifica se cliente possui Alvara Ativo para o produto selecionado
                		
                		if (SZ3->Z3_VALIDAD - Date()) > 0 .AND. (SZ3->Z3_VALIDAD - Date()) < 30    // valida se Alvara vencera em menos de 30 dias
			
			
								MsgInfo("Alvar� N� " + QSZ4->Z1_COD + " Vencer� em "+ cValtoChar((SZ3->Z3_VALIDAD - Date())) + " Dias", "Favor Verificar !", "Aten��o" )
		
		
						Elseif (SZ3->Z3_VALIDAD - Date()) <= 0  // Valida se Alvara ja esta vencido
		
								If QSZ4->Z1_BLQVEN == "S" .AND. EMPTY(SZ3->Z3_PROTOC)
			     
								   	if MsgYesNo("Alvar� do Cliente para compra deste produto se encontra Vencido, Liberar Venda ? ","Aten��o")
									
									
										lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
									    
									    if !lRet 
									    	Exit // Abandona loop se pelo menos 1 produto nao permitir venda sem Alvar� 
									    Endif
									
									Else 
									
										lRet := .F.	
										Exit    
									
						            Endif
						
								Elseif QSZ4->Z1_BLQVEN == "S" .AND. !EMPTY(SZ3->Z3_PROTOC) // Se o cliente estiver com o Alvara vencido, porem existe o numero de protocolo de renova��o, libera.
			    
			  							lRet := .T.	
			
								Else // Se n�o Bloqueia, somente avisa que o Alvar� esta vencido
										Alert("Alvar� do Cliente para compra deste produto se encontra Vencido, Favor Verificar !","Aten��o")
									    lRet:= .T.
								Endif
                        EndIf
				Else // Se nao encontrado Alvar� Ativo para o cliente, valida se Alvar� bloqueia venda
    
			    	    If QSZ4->Z1_BLQVEN == "S"
			    	    	
			    	    	if MsgYesNo("Alvar� n� "+ QSZ4->Z1_COD  +"  para compra deste produto Encerrado ou Inexistente, Liberar Venda ?","Aten��o")
						
								lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
							    
							    if !lRet 
							    	Exit // Abandona loop se pelo menos 1 produto nao permitir venda sem Alvar� 
							    Endif

							Else
								lRet := .F.
								Exit // Abandona loop se pelo menos 1 produto nao permitir venda sem Alvar�
							Endif
			    	    
			    	    Else // Alvara nao Bloqueia Venda
			    	    
			    	        lRet := .T.
			    	    Endif
				Endif

     
     	QSZ4->(DbSkip())	
     
    EndDo
     

ElseIf nLinhas == 1  // Produto possui somente 1 Alvar�
    
	
	if SZ3->(DbSeek(XFILIAL("SZ3")+M->C5_CLIENTE+M->C5_LOJACLI+QSZ4->Z1_COD+"A")) // Verifica se cliente possui Alvara Ativo para o produto selecionado
     
		if (SZ3->Z3_VALIDAD - Date()) > 0 .AND. (SZ3->Z3_VALIDAD - Date()) < 30    // valida se Alvara vencera em menos de 30 dias
			
			
				MsgInfo("Alvar� N� " + QSZ4->Z1_COD + " Vencer� em "+ cValtoChar((SZ3->Z3_VALIDAD - Date())) + " Dias", "Favor Verificar !", "Aten��o" )
		
		
		Elseif (SZ3->Z3_VALIDAD - Date()) <= 0  // Valida se Alvara ja esta vencido
		
			If QSZ4->Z1_BLQVEN == "S" .AND. EMPTY(SZ3->Z3_PROTOC)// Verifica se � permitido venda com Alvara Vencido
			     
				if MsgYesNo("Alvar� do Cliente para compra deste produto se encontra Vencido, Liberar Venda?","Aten��o")
			   					
			   					lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
									    						
				Else
					lRet := .F.
				Endif
			
			Elseif QSZ4->Z1_BLQVEN == "S" .AND. !EMPTY(SZ3->Z3_PROTOC) // Se o cliente estiver com o Alvara vencido, porem existe o numero de protocolo de renova��o, libera.
			    
			  	lRet := .T.	
			
			Else // Se n�o Bloqueia, somente avisa que o Alvar� esta vencido
				Alert("Alvar� do Cliente para compra deste produto se encontra Vencido, Favor Verificar !","Aten��o")
			    lRet:= .T.
			Endif
		Endif       

    Else // Se nao encontrado Alvar� Ativo para o cliente, valida se Alvar� bloqueia venda
    
    	    If QSZ4->Z1_BLQVEN == "S"
    	    	
    	    	if MsgYesNo("Alvar� do Cliente para compra deste produto Encerrado ou Inexistente, Liberar Venda? ","Aten��o")
			   			
			   			lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
									    
				Else
					lRet := .F.
			    Endif
    	    Else // Alvaro nao Bloqueia Venda
    	    
    	        lRet := .T.
    	    Endif
    
    Endif

Else // Produto nao controlado por Alvar�

 lRet := .T.	
	

EndIf
    
    

Return lRet	