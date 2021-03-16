
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDAEMP  ºAutor  Tiago Luiz Mendonça  º Data ³  04/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de gravação dos dados do TimeSheet                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


/*
Funcao      : GTHDTSH()
Objetivos   : Grava a tabela de timesshet
Autor       : Tiago Luiz Mendonça
Data/Hora   : 07/11/2011
*/   

*-------------------------------*
  User function GTHDTSH(cCodigo)   
*-------------------------------*  

Z07->(DbSetOrder(1))
If Z07->(DbSeek(xFilial("Z07")+cCodigo))  //Verifica se Time já foi lançado  
	MsgInfo("TimeSheet gerado em "+DTOC(Z07->Z07_DATA))    
Else  
	Z03->(DbSetOrder(1))	
	If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODATE)) // Posiciona no atendente 
		If !Empty(Z03->Z03_USR_T)	
			Z04->(DbSetOrder(1))
	   		If Z04->(DbSeek(xFilial("Z04")+Z01->Z01_CODEMP+Z01->Z01_FILEMP)) // Posiciona no cliente
		   		If !Empty(Z04->Z04_CNPJ) .And. !Empty(Z04->Z04_NOME)    
		   	   		If !Empty(Z01->Z01_HRGAST) .And. !Empty(Z01->Z01_TIMEOB)
			   			RecLock("Z07",.T.)
			   			Z07->Z07_CODIGO := Z01->Z01_CODIGO
						Z07->Z07_DATA   := Z01->Z01_DT_ENC
						Z07->Z07_USR_T	:= Z03->Z03_USR_T
						Z07->Z07_HR_ID	:= "8"
						Z07->Z07_HORA	:= Substr(Z01->Z01_HRGAST,1,2)
						Z07->Z07_MINUTO	:= Substr(Z01->Z01_HRGAST,4,2)
						Z07->Z07_OBS	:= Z01->Z01_TIMEOB                        	
						Z07->Z07_TIPO	:= "5"
						Z07->Z07_COBRAR	:= "S"
						Z07->Z07_CNPJ	:= Z04->Z04_CNPJ
						Z07->Z07_CLIENT	:= Z04->Z04_NOME
						Z07->Z07_IMPORT	:= ""
						Z07->(MsUnlock())
						
						MsgInfo("TimeSheet gravado com sucesso ")   
						
				    Else
				    	MsgAlert("TimeSheet não foi gravado. (Z01_HRGAST/Z01_TIMEOB)")  
					EndIf
				Else 
					MsgAlert("TimeSheet não foi gravado. (Z04_CNPJ/Z04_NOME)")
				EndIf			                                                           
			Else
				MsgAlert("TimeSheet não foi gravado. (Z01_CODEMP/Z01_FILEMP)")
			EndIf
		Else
			MsgAlert("TimeSheet não foi gravado. (Z03_USR_T)")
		EndIf		
	Else
		MsgAlert("TimeSheet não foi gravado. (Z01_CODATE)")
	EndIf
	
EndIf				


Return