#include "Protheus.ch"
#include "Topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJKFAT009     บAutor  ณInnovare Solu็๕es   บ Data ณ  10/22/13บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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


if nLinhas > 1 // Produto possui mais de 1 Alvarแ
     
 	
 	While QSZ4->(!EOF())
 	
 	
 				if SZ3->(DbSeek(XFILIAL("SZ3")+M->C5_CLIENTE+M->C5_LOJACLI+QSZ4->Z1_COD+"A")) // Verifica se cliente possui Alvara Ativo para o produto selecionado
                		
                		if (SZ3->Z3_VALIDAD - Date()) > 0 .AND. (SZ3->Z3_VALIDAD - Date()) < 30    // valida se Alvara vencera em menos de 30 dias
			
			
								MsgInfo("Alvarแ Nบ " + QSZ4->Z1_COD + " Vencerแ em "+ cValtoChar((SZ3->Z3_VALIDAD - Date())) + " Dias", "Favor Verificar !", "Aten็ใo" )
		
		
						Elseif (SZ3->Z3_VALIDAD - Date()) <= 0  // Valida se Alvara ja esta vencido
		
								If QSZ4->Z1_BLQVEN == "S" .AND. EMPTY(SZ3->Z3_PROTOC)
			     
								   	if MsgYesNo("Alvarแ do Cliente para compra deste produto se encontra Vencido, Liberar Venda ? ","Aten็ใo")
									
									
										lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
									    
									    if !lRet 
									    	Exit // Abandona loop se pelo menos 1 produto nao permitir venda sem Alvarแ 
									    Endif
									
									Else 
									
										lRet := .F.	
										Exit    
									
						            Endif
						
								Elseif QSZ4->Z1_BLQVEN == "S" .AND. !EMPTY(SZ3->Z3_PROTOC) // Se o cliente estiver com o Alvara vencido, porem existe o numero de protocolo de renova็ใo, libera.
			    
			  							lRet := .T.	
			
								Else // Se nใo Bloqueia, somente avisa que o Alvarแ esta vencido
										Alert("Alvarแ do Cliente para compra deste produto se encontra Vencido, Favor Verificar !","Aten็ใo")
									    lRet:= .T.
								Endif
                        EndIf
				Else // Se nao encontrado Alvarแ Ativo para o cliente, valida se Alvarแ bloqueia venda
    
			    	    If QSZ4->Z1_BLQVEN == "S"
			    	    	
			    	    	if MsgYesNo("Alvarแ nบ "+ QSZ4->Z1_COD  +"  para compra deste produto Encerrado ou Inexistente, Liberar Venda ?","Aten็ใo")
						
								lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
							    
							    if !lRet 
							    	Exit // Abandona loop se pelo menos 1 produto nao permitir venda sem Alvarแ 
							    Endif

							Else
								lRet := .F.
								Exit // Abandona loop se pelo menos 1 produto nao permitir venda sem Alvarแ
							Endif
			    	    
			    	    Else // Alvara nao Bloqueia Venda
			    	    
			    	        lRet := .T.
			    	    Endif
				Endif

     
     	QSZ4->(DbSkip())	
     
    EndDo
     

ElseIf nLinhas == 1  // Produto possui somente 1 Alvarแ
    
	
	if SZ3->(DbSeek(XFILIAL("SZ3")+M->C5_CLIENTE+M->C5_LOJACLI+QSZ4->Z1_COD+"A")) // Verifica se cliente possui Alvara Ativo para o produto selecionado
     
		if (SZ3->Z3_VALIDAD - Date()) > 0 .AND. (SZ3->Z3_VALIDAD - Date()) < 30    // valida se Alvara vencera em menos de 30 dias
			
			
				MsgInfo("Alvarแ Nบ " + QSZ4->Z1_COD + " Vencerแ em "+ cValtoChar((SZ3->Z3_VALIDAD - Date())) + " Dias", "Favor Verificar !", "Aten็ใo" )
		
		
		Elseif (SZ3->Z3_VALIDAD - Date()) <= 0  // Valida se Alvara ja esta vencido
		
			If QSZ4->Z1_BLQVEN == "S" .AND. EMPTY(SZ3->Z3_PROTOC)// Verifica se ้ permitido venda com Alvara Vencido
			     
				if MsgYesNo("Alvarแ do Cliente para compra deste produto se encontra Vencido, Liberar Venda?","Aten็ใo")
			   					
			   					lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
									    						
				Else
					lRet := .F.
				Endif
			
			Elseif QSZ4->Z1_BLQVEN == "S" .AND. !EMPTY(SZ3->Z3_PROTOC) // Se o cliente estiver com o Alvara vencido, porem existe o numero de protocolo de renova็ใo, libera.
			    
			  	lRet := .T.	
			
			Else // Se nใo Bloqueia, somente avisa que o Alvarแ esta vencido
				Alert("Alvarแ do Cliente para compra deste produto se encontra Vencido, Favor Verificar !","Aten็ใo")
			    lRet:= .T.
			Endif
		Endif       

    Else // Se nao encontrado Alvarแ Ativo para o cliente, valida se Alvarแ bloqueia venda
    
    	    If QSZ4->Z1_BLQVEN == "S"
    	    	
    	    	if MsgYesNo("Alvarแ do Cliente para compra deste produto Encerrado ou Inexistente, Liberar Venda? ","Aten็ใo")
			   			
			   			lRet:= u_JKFAT012() // Chama rotina para solicitar liberacao por senha
									    
				Else
					lRet := .F.
			    Endif
    	    Else // Alvaro nao Bloqueia Venda
    	    
    	        lRet := .T.
    	    Endif
    
    Endif

Else // Produto nao controlado por Alvarแ

 lRet := .T.	
	

EndIf
    
    

Return lRet	