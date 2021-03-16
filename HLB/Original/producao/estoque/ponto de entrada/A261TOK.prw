/*
Funcao      : Valida��o de usu�rio
Objetivos   : N�o permitir determinadas movimenta��es em armazem. 
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 14/07/10
*/ 
              
/*
Funcao      : A261TOK
Parametros  : Nenhum
Retorno     : lRet   
Objetivos   : N�o permitir determinadas movimenta��es em armazem.
Autor     	: Tiago Luiz Mendon�a
Data     	: 08/09/08 
Obs         : 
TDN         : P.E. Localizado no inicio da fun��o A261TudoOk( ) . VALIDACAO DA TRANSFERENCIA MOD 2 O ponto sera disparado no inicio da chamada da funcao de validacao geral dos itens digitados. Serve para validar se o movimento pode ser efetuado ou nao.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Estoque.
Cliente     : Dr Reddys / Shiseido
*/


*--------------------------*
  User Function A261TOK()
*--------------------------*
  
Local i:= 0
Local lRet:=.T.  
Local aItens 


   If cEmpAnt $ "U2" 
            
      aItens:=aCols 
       
      If alltrim(cUserName) $ "REDDYS02"
                   
         For i:=1 to Len(aItens)
         
            If aCols[i][4] <> '02' //origem 
               MsgStop("Usu�rio sem permiss�o para realizar esse movimento. Este us�rio tem permiss�o apenas para transferencia de armazem 02 -> 03","DrReddys")
               lRet:=.F.     
               Exit
            ElseIf aCols[i][9] <> '03'//destino   
               MsgStop("Usu�rio sem permiss�o para realizar esse movimento. Este us�rio tem permiss�o apenas para transferencia de armazem 02 -> 03","DrReddys")
               lRet:=.F. 
               Exit
            EndIf  
             
         Next
      EndIf 
      
      If alltrim(cUserName) $ "REDDYS03"
                   
         For i:=1 to Len(aItens)
         
            If aCols[i][4] == '03' //origem 
               MsgStop("Usu�rio sem permiss�o para realizar esse movimento. Este us�rio n�o tem permiss�o apenas para transferencia de armazem 03.","DrReddys")
               lRet:=.F.     
               Exit
            ElseIf aCols[i][9] == '03'//destino   
               MsgStop("Usu�rio sem permiss�o para realizar esse movimento. Este us�rio n�o tem permiss�o apenas para transferencia de armazem 03.","DrReddys")
               lRet:=.F. 
               Exit
            EndIf  
             
         Next
      EndIf
 
   EndIf

    //WFA - Exeltis - Preenchimento de lote destino com a mesma informa��o do lote de origem quando destino estiver em branco. Chamado: #14515.
	If cEmpAnt $ 'LG'
   		
   		For i:=1 to Len(aCols)
   			If aCols[i][19] == '' .and. aCols[i][11] <> ''
   				aCols[i][19] := aCols[i][11]
   			EndIf
   		Next 
   		
   		//CAS - 19/09/2018 - Tratamento para empresa Exeltis (Conforme e-mail da Fabiana Leonel) ----------------------------------- 
		//Pr� Preenchimento N�mero Documento com '000000000'
		If CDOCUMENTO == "000000000" 
			CDOCUMENTO := GetSXENum("SD3","D3_DOC") 
			SD3->(ConfirmSX8()) 
			MsgInfo("Transfer�ncia gravada com o N�mero do Documento " +Alltrim(CDOCUMENTO))   													
		Else  
			MsgInfo("Transfer�ncia gravada com o N�mero do Documento " +Alltrim(CDOCUMENTO))
		EndIF   		
   		//Pr� Preenchimento N�mero Documento com '000000000' ---------------------------------------------------------
  		
 	EndIf
 
Return lRet