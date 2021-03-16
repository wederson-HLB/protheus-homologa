#include "rwmake.ch"
#include "protheus.ch"                      
/*
Funcao      : OS010GRV
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. Apos gravação da tabela de preço
Autor       : Jean Victor Rocha
Data/Hora   : 14/05/2012
Obs         : 
TDN         : http://tdn.totvs.com/kbm#16526
Obs         : 
Cliente     : Todos
*/                 
*-----------------------*
User function OS010GRV()
*-----------------------*
Processa({|| MAIN()})
Return .T.


*-----------------------*
Static Function MAIN()
*-----------------------*

ProcRegua(400)//numero qualquer apenas para criar uma tela...

If cEmpAnt $ "R7" .AND.; // Shiseido
	DA1->DA1_CODTAB = '014' .or. DA1->DA1_CODTAB = '013'

   	SB0->(DbSetOrder(1))
    SB1->(DbSetOrder(1))
      
    DA1->(DbGoTop())
	While DA1->(!EOF()) 
		IncProc("Aguarde - Atualizando registros no Microvix...")
		If DA1->DA1_CODTAB = '014' .or. DA1->DA1_CODTAB = '013'
	        If DA1->DA1_CODTAB = '014'
		        SB0->(DbGoTop())
		        If SB0->(DbSeek(xFilial("SB0")+DA1->DA1_CODPRO))
		        	RecLock("SB0",.F.)
		        	SB0->B0_PRV1:=DA1->DA1_PRCVEN
		        	SB0->(MsUnlock())     
		        Else 
		        	RecLock("SB0",.T.)
		        	SB0->B0_COD :=DA1->DA1_CODPRO
		        	SB0->B0_PRV1:=DA1->DA1_PRCVEN
		        	SB0->(MsUnlock())       
		        EndIf 
			EndIf
	
	    	//Abre conexão com banco de interface
	   		nCon := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 
	
	   		If nCon < 0
		   		MsgInfo("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix")  
		   		MsgInfo("Base de dados Microvix não foi atualizada")  
		   		Return .F.         
			EndIf  
	
	   		If Select("cTemp") > 0
		   		cTemp->(DbCloseArea())	               
	  		EndIf
	
	   	    BeginSql Alias 'cTemp' 
	        	//Busca o código na tabela de muro
	       		SELECT codigoproduto
	     	   		FROM PRODUTOS
	     	   		WHERE
	        		codigoproduto = %exp:alltrim(DA1->DA1_CODPRO)%  
	    	EndSql   
	
		    SB1->(DbSeek(xFilial("SB1")+DA1->DA1_CODPRO))

	    	If  DA1->DA1_CODTAB = '013'
	        	RecLock("SB1",.F.)
				SB1->B1_CUSTD := DA1->DA1_PRCVEN
	        	SB1->(MsUnlock()) 
	    	EndIf

	    	If DA1->DA1_CODTAB = '014'
		    	If cTemp->(!BOF() .and. !EOF())
		   		    //Atualiza - tabela padrão Microvix 
		       		cQry := "Update PRODUTOS set nomeproduto='"+Alltrim(SB1->B1_DESC)+"',codebar='"			+Alltrim(SB1->B1_CODBAR)+ ;
		       																		"',preco_custo="   		+Alltrim(str(SB1->B1_CUSTD))+ ;
		       																		" ,preco_venda="   		+Alltrim(str(DA1->DA1_PRCVEN))+;
		       																		" ,codigo_setor='"		+Alltrim(SB1->B1_P_BEA)+;
		       																		"',codigo_linha='" 		+Alltrim(SB1->B1_P_BEB)+;
		       																		"',codigo_marca='" 		+Alltrim(SB1->B1_GRUPO)+;
		       																		"',descricao_basica='"	+Alltrim(SB1->B1_DESCING)+;
		       																		"',unidade='"  	   		+Alltrim(SB1->B1_UM)+;
		       																		"',ativo='"		  		+SB1->B1_MSBLQL+ ; 
		       																		"',ncm='"		  		+SB1->B1_POSIPI+ ;
		       		"' where codigoproduto ='"+Alltrim(DA1->DA1_CODPRO)+"'"	          
				Else
					//Inclui  - tabela padrão Microvix 
					cQry := "Insert into PRODUTOS(codigoproduto,nomeproduto,codebar,preco_custo,preco_venda,codigo_setor,codigo_linha,codigo_marca,descricao_basica,ativo,unidade,ncm) values('"+Alltrim(DA1->DA1_CODPRO)+"','"+Alltrim(SB1->B1_DESC)+"','"+SB1->B1_CODBAR+"',"+Alltrim(str(SB1->B1_CUSTD))+","+Alltrim(str(DA1->DA1_PRCVEN))+",'"+Alltrim(SB1->B1_P_BEA)+"','"+Alltrim(SB1->B1_P_BEB)+"','"+Alltrim(SB1->B1_GRUPO)+"','"+Alltrim(SB1->B1_DESCING)+"','"+Alltrim(SB1->B1_MSBLQL)+"','"+SB1->B1_UM+"','"+SB1->B1_POSIPI+"')"
		   		EndIf            
	        ElseIf DA1->DA1_CODTAB = '013'     
	        	If cTemp->(!BOF() .and. !EOF())
		   		    //Atualiza - tabela padrão Microvix 
		       		cQry := "Update PRODUTOS set preco_custo="   		+Alltrim(str(SB1->B1_CUSTD))+ ;
				       		" where codigoproduto ='"+Alltrim(DA1->DA1_CODPRO)+"'"	          
				EndIf
	        EndIf
	        //Exibe a mensagem de erro
	  	  	If (TCSQLExec(cQry) < 0)
	      		Return MsgStop("TCSQLError() :" + TCSQLError())
			EndIf      
	
	        //Fecha temporario                     
	  		If Select("cTemp") > 0
		   		cTemp->(DbCloseArea())	               
	  		EndIf
	
	    	//Fecha conexão o banco
	    	TcUnlink(nCon) 
		EndIf
		DA1->(DbSKIP())
	EndDo
EndIf

Return .T.