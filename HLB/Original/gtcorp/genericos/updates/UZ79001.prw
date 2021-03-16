/*
Funcao      : UZ79001
Parametros  : 
Retorno     : Nenhum
Objetivos   : Criar tabela Z79 e Z78
Autor       : Matheus Massarotto
Data/Hora   : 15/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*----------------------*
User Function UZ79001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
*----------------------*
If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"GCT",{|o| UZ79001(o)}} }//MMM=(EIC,EEC,EDC,EFF,ECO)/M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf
Return .T.                 

*-------------------------*
Static Function UZ79001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
*-------------------------*

   //*******Instruções**********//
   //O AVUPDATE se encarregará de atualizar dicionario e base de dados.
   //Quando um campo não é preenchido, o AVUPDATE mantém o conteudo do dicionário atual.
   //Quando não forem preenchidos campos obrigatórios do dicionário, o update não fará inclusão, apenas alteração.
   //Utilizar os comentários abaixo como molde para preenchimento dos dados.
   //APAGAR OS COMENTÁRIOS APÓS O TÉRMINO DO UPDATE.
   //***************************//
   
   //////////////////////
   //Criação de Indices//
   //////////////////////
   
   //             "INDICE" ,"ORDEM" ,"CHAVE"                  ,"DESCRICAO"      ,"DESCSPA"        ,"DESCENG"        ,"PROPRI" ,"F3" ,"NICKNAME" ,"SHOWPESQ" 
   Aadd(o:aSIX,{"Z79"    ,"1"     ,"Z79_FILIAL+Z79_TPCTR+Z79_NUM"  	  ,"Tipo+Num"       ,"Tipo+Num"       ,"Tipo+Num"       ,"U"      ,""   ,""         ,"S"        })

   Aadd(o:aSIX,{"Z78"    ,"1"     ,"Z78_FILIAL+Z78_NUM+Z78_ITEM+Z78_DEPART+Z78_AREA+Z78_SERVIC"    ,"Item+Num+Departamento+Area+Servico"    ,"Item+Num+Departamento+Area+Servicio"    ,"Item+Num+Deparament+Area+Service"    ,"U"      ,""   ,""         ,"S"        })   
   ////////////////////////
   //Criação dos Pergunte//
   ////////////////////////
   //             "X1_GRUPO" ,"X1_ORDEM"      ,"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL"
   //aAdd(o:aSX1,{"EIC154   ","01"            ,            ,           ,           ,            ,         ,            ,            ,           ,   	 ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,        })

   ///////////////////////
   //Criação das tabelas//
   ///////////////////////  
   //             "X2_CHAVE","X2_PATH","X2_ARQUIVO"             ,"X2_NOME"                  ,"X2_NOMESPA"               ,"X2_NOMEENG"               							,"X2_ROTINA" ,"X2_MODO" ,"X2_DELET" ,"X2_TTS" ,"X2_UNICO"              ,"X2_PYME" ,"X2_MODULO"
   Aadd(o:aSX2,{"Z79"     ,"\SYSTEM\" ,"Z79"+SM0->M0_CODIGO+"0" ,"Capa Cad Controle Proposta"        ,"Capa Cad Controle Proposta"        ,"Capa Cad Controle Proposta"        ,""          ,"E"       ,0          ,""       ,"" ,"S"       , 0         })

   Aadd(o:aSX2,{"Z78"     ,"\SYSTEM\" ,"Z78"+SM0->M0_CODIGO+"0" ,"Itens Cad Controle Proposta"        ,"Itens Cad Controle Proposta"        ,"Itens Cad Controle Proposta"        ,""          ,"E"       ,0          ,""       ,"" ,"S"       , 0         })   
   //////////////////////
   //Criação dos Campos//                                                                                                                    
   //////////////////////  
   //***USADO***
   //Caso seja alterar USADO, seguir regra de no campo X3_USADO usar:
   //TODOS_MODULOS = Todos os modulos.
   //TODOS_AVG     = Modulos EIC, EEC, EDC, EFF, ECO
   //BASICO_AVG    = Modulos EIC, EEC, EDC  
   //EIC_USADO     = EIC
   //EEC_USADO     = EEC
   //EDC_USADO     = EDC
     //NAO_USADO     := "€€€€€€€€€€€€€€ "
     //RESERV		   := "þA"
   //***RESERVADO*** // inserir os nomes das defines que deseja colocar no reservado, por exemplo NOME+TIPO+TAM+DEC+OBRIGAT
   //NOME
   //TIPO
   //TAM 
   //DEC 
   //ORDEM
    cPICTURE	  :="@E 99,999,999,999.99 "
   	//OBRIGAT		  := "€"
   //USO
   //           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"           ,"X3_DESCRIC"  					,"X3_DESCSPA"   				,"X3_DESCENG"    				 ,"X3_PICTURE" ,"X3_VALID"  ,"X3_USADO"  		,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV" 				,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER"														,"X3_CBOX" 					 		,"X3_CBOXSPA"   ,"X3_CBOXENG"   ,"X3_PICTVAR" ,"X3_WHEN"             				,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"
   Aadd(o:aSX3,{"Z79"        ,"01"       ,"Z79_FILIAL" ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial do Sistema"   , "Filial"     					,"Filial"       				,"Filial"        				 , ""          ,""          ,NAO_USADO  		,""               ,""      ,0          ,TAM+DEC+OBRIGAT				,""         ,""           ,"U"          ,"N"         ,""          ,""          ,""          ,""           														,""        					 		,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"02"       ,"Z79_DRAFT"  ,"C"       ,12           ,0            ,"Draft"        ,"Draft"        ,"Draft"               , "Numero Draft" 					,"Numero Draft"					,"Numero Draft" 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"Z86"   ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('Z86', M->Z79_DRAFT, 2)"        							,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })   
   Aadd(o:aSX3,{"Z79"        ,"03"       ,"Z79_TPCTR " ,"C"       ,1            ,0            ,"Tipo"         ,"Tipo"         ,"Tipo"                , "Tipo Contrato"  				,"Tipo Contrato"				,"Tipo Contrato" 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     	    ,"" 										   						,"1=AUDITING;2=TAX;3=ADVISORY"		,""             ,""             ,""           ,"IIF(!empty(M->Z79_DRAFT),.F.,.T.) " ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"04"       ,"Z79_NUM "   ,"C"       ,12           ,0            ,"Numero"       ,"Numero"       ,"Numero"              , "Numero" 						,"Numero"						,"Numero" 		 				 , ""          ,""          ,TODOS_MODULOS 		,"'.'"            ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })   
   Aadd(o:aSX3,{"Z79"        ,"05"       ,"Z79_SOCIO " ,"C"       ,6            ,0            ,"Socio"        ,"Socio"        ,"Socio"               , "Socio"  	   					,"Socio"	   					,"Socio" 		 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SA3"   ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('SA3', M->Z79_SOCIO, 1)"            						,""									,""             ,""             ,""           ,"IIF(!empty(M->Z79_DRAFT),.F.,.T.) " ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"06"       ,"Z79_NOMESO" ,"C"       ,100          ,0            ,"Nome Socio"   ,"Nome Socio"   ,"Nome Socio"          , "Nome Socio"  					,"Nome Socio"					,"Nome Socio"  				 	 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"07"       ,"Z79_CLIENT" ,"C"       ,6            ,0            ,"Cliente"      ,"Cliente"      ,"Cliente"             , "Cliente"  						,"Cliente"	   					,"Cliente" 		 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SA1"   ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('SA1', M->Z79_CLIENT+M->Z79_LOJA, 1)"					,""									,""             ,""             ,""           ,"IIF(!empty(M->Z79_DRAFT),.F.,.T.) " ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"08"       ,"Z79_LOJA"   ,"C"       ,2            ,0            ,"Loja"     	  ,"Loja"     	  ,"Loja"            	 , "Loja Cliente"  					,"Loja Cliente"					,"Loja Cliente"  				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('SA1', M->Z79_CLIENT+M->Z79_LOJA, 1)"   					,""							   		,""             ,""             ,""           ,"IIF(!empty(M->Z79_DRAFT),.F.,.T.) " ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"09"       ,"Z79_NOME"   ,"C"       ,100          ,0            ,"Nome Cli"     ,"Nome Cli"     ,"Nome Cli"            , "Nome Cliente"  					,"Nome Cliente"					,"Nome Cliente"  				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""											   						,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"10"       ,"Z79_PROSPE" ,"C"       ,6            ,0            ,"Prospect"     ,"Prospect"     ,"Prospect"            , "Prospect"  						,"Prospect"	   					,"Prospect" 		 			 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SUSZ86",0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"U_Z79_PROS() .AND. ExistCpo('SUS', M->Z79_PROSPE+M->Z79_PLOJA,1)"	,""									,""             ,""             ,""           ,"IIF(!empty(M->Z79_DRAFT),.F.,.T.) " ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"11"       ,"Z79_PLOJA"  ,"C"       ,2            ,0            ,"Prosp Loja"   ,"Prosp Loja"   ,"Prosp Loja"        	 , "Prospect Loja"  				,"Prospect Loja"				,"Prospect Loja"  				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"U_Z79_PROS() .AND. ExistCpo('SUS', M->Z79_PROSPE+M->Z79_PLOJA,1)"	,""							   		,""             ,""             ,""           ,"IIF(!empty(M->Z79_DRAFT),.F.,.T.) " ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"12"       ,"Z79_PNOME"  ,"C"       ,100          ,0            ,"Nome Prosp"   ,"Nome Prosp"   ,"Nome Prosp"          , "Nome Prospect"  				,"Nome Prospect"				,"Nome Prospect" 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"13"       ,"Z79_TPVLR"  ,"C"       ,1            ,0            ,"Utiliza Vlr"  ,"Utiliza Vlr"  ,"Uses Value"          , "Utiliza Vlr" 	     			,"Utiliza Vlr"		   			,"Uses Value"	  			     , ""    	   ,""          ,TODOS_MODULOS		,"'1'"            ,""      ,0          ,NOME						,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           														,"1=Valor Venda;2=Valor c/ Imposto"	,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z79"        ,"14"       ,"Z79_VALOR"  ,"N"       ,14           ,2            ,"Vlr Venda"    ,"Vlr Venda"    ,"Vlr Venda"           , "Valor Venda"  					,"Valor Venda" 					,"Valor Venda"   				 , cPICTURE    ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME 						,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           								   						,""									,""             ,""             ,""           ,"IIF(M->Z79_TPVLR=='2',.F.,.T.)"		,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z79"        ,"15"       ,"Z79_DESPER" ,"N"       ,6            ,2            ,"% Desconto"   ,"% Desconto"   ,"% Desconto"          , "% Desconto"    					,"% Desconto"					,"% Desconto"   	 			 , "@E 999.99" ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME 						,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           														,""									,""             ,""             ,""           ,""									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })            
   Aadd(o:aSX3,{"Z79"        ,"16"       ,"Z79_DESCON" ,"N"       ,14           ,2            ,"Desconto"     ,"Desconto"     ,"Desconto"            , "Desconto"    					,"Desconto"						,"Desconto"   	 				 , cPICTURE    ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME 						,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           														,""									,""             ,""             ,""           ,"" 									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z79"        ,"17"       ,"Z79_VLRTOT" ,"N"       ,14           ,2            ,"Vlr c/ Impos" ,"Vlr c/ Impos" ,"Vlr c/ Impos"        , "Valor total c/ Impostos"		,"Valor total c/ Impostos"		,"Valor total c/ impostos"   	 , cPICTURE    ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME						,""         ,"S"          ,"U"          ,"S"         ,"R"         ,"R"         ,""     		,""           														,""									,""             ,""             ,""           ,"IIF(M->Z79_TPVLR=='1',.F.,.T.)"  	,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z79"        ,"18"       ,"Z79_TIME"   ,"C"       ,8            ,0            ,"Qtd Horas"    ,"Qtd Horas"    ,"Qtd Hours"         	 , "Quantidade de Horas"			,"Horas Cantidad"				,"Amount Hours" 				 , ""  		   ,""          ,TODOS_MODULOS		,""      		  ,""	   ,0          ,NOME		 				,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,""           								   						,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"19"       ,"Z79_STATUS" ,"C"       ,1            ,0            ,"Status"       ,"Status"       ,"Status"              , "Status"  		     			,"Status"			   			,"Status"  		  			     , ""    	   ,""          ,TODOS_MODULOS		,""               ,""      ,0          ,NOME						,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z79"        ,"20"       ,"Z79_MOTIVO" ,"C"       ,100          ,0            ,"Motivo"    	  ,"Motivo"       ,"Motivo" 	         , "Motivo"  						,"Motivo"						,"Motivo"  					     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,""           								   						,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z79"        ,"21"       ,"Z79_DTINC " ,"D"       ,8            ,0            ,"Data Inc"     ,"Data Inc"     ,"Data Inc"            , "Data Inclusao" 					,"Data Inclusao"				,"Data Inclusao" 				 , ""          ,""          ,NAO_USADO 			,""      		  ,""	   ,0          ,TAM+DEC+ORDEM		 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           								   						,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"22"       ,"Z79_DTAPRO" ,"D"       ,8            ,0            ,"Data Apro"    ,"Data Apro"    ,"Data Apro"           , "Data Aprovacao"					,"Data Aprovacao"				,"Data Aprovacao" 				 , ""          ,""          ,NAO_USADO 			,""      		  ,""	   ,0          ,TAM+DEC+ORDEM		 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"23"       ,"Z79_DTRECU" ,"D"       ,8            ,0            ,"Data Recu"    ,"Data Recu"    ,"Data Recu"           , "Data Recusa"					,"Data Recusa"					,"Data Recusa" 				 	 , ""          ,""          ,NAO_USADO 			,""      		  ,""	   ,0          ,TAM+DEC+ORDEM		 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           								   						,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z79"        ,"24"       ,"Z79_USERGI" ,"C"       ,17           ,0            ,"Log de Inclu" ,"Log de Inclu" ,"Log de Inclu"		 ,"Log de Inclusao"    				,"Log de Inclusao"    			,"Log de Inclusao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           														,""                                 ,""             ,""             ,""           ,""                    				,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		  })
   Aadd(o:aSX3,{"Z79"        ,"25"       ,"Z79_USERGA" ,"C"       ,17           ,0            ,"Log de Alter" ,"Log de Alter" ,"Log de Alter"		 ,"Log de Altercao"    				,"Log de Altercao"    			,"Log de Altercao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           														,""                                 ,""             ,""             ,""           ,""                    				,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		  })   

   Aadd(o:aSX3,{"Z78"        ,"01"       ,"Z78_FILIAL" ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial do Sistema"   , "Filial"     					,"Filial"       				,"Filial"        				 , ""          ,""          ,NAO_USADO  		,""               ,""      ,0          ,TAM+DEC+OBRIGAT				,""         ,""           ,"U"          ,"N"         ,""          ,""          ,""          ,""           																										   				,""        					 		,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z78"        ,"02"       ,"Z78_ITEM"   ,"C"       ,2            ,0            ,"Item" 		  ,"Item" 	      ,"Item" 	             , "Item"  							,"Item"							,"Item" 	 				     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           								   																		   				,""									,""             ,""             ,""           ,""                   									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"03"       ,"Z78_NUM "   ,"C"       ,12           ,0            ,"Numero"       ,"Numero"       ,"Numero"              , "Numero" 						,"Numero"						,"Numero" 		 				 , ""          ,""          ,NAO_USADO 			,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,""           ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           								   																		   				,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z78"        ,"04"       ,"Z78_DEPART" ,"C"       ,6            ,0            ,"Departameto"  ,"Departamento" ,"Department"          , "Departamento" 					,"Departamento"					,"Department" 		 			 , ""          ,""          ,TODOS_MODULOS 		,""               ,"Z83Z78",0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('Z83', M->Z78_DEPART, 1)"																								,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z78"        ,"05"       ,"Z78_DESCDE" ,"C"       ,50           ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description"  			     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           																														,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      

   Aadd(o:aSX3,{"Z78"        ,"06"       ,"Z78_AREA"   ,"C"       ,6            ,0            ,"Area"      	  ,"Area"      	  ,"Area"             	 , "Area"  							,"Area"		   					,"Area" 		 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"Z82Z78",0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('Z82', M->Z78_AREA, 1) .and. U_Z78PZ80(aCols[oGetDados:Obrowse:nAt][2]+M->Z78_AREA)"										,""									,""             ,""             ,""           ,"IIF(!empty(aCols[oGetDados:Obrowse:nAt][2]),.T.,.F.)" 	,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"07"       ,"Z78_DESCAR" ,"C"       ,50           ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description"  			     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           																														,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"08"       ,"Z78_SERVIC" ,"C"       ,6            ,0            ,"Servico"      ,"Servicio"     ,"Service"           	 , "Servico"  						,"Servicio"						,"Service"  				     , ""          ,""          ,TODOS_MODULOS 		,""               ,"Z81Z78",0          ,TAM+DEC+OBRIGAT+ORDEM		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,"ExistCpo('Z81', M->Z78_SERVIC, 1) .and. U_Z78PZ80(aCols[oGetDados:Obrowse:nAt][2]+aCols[oGetDados:Obrowse:nAt][4]+M->Z78_SERVIC)"	,""									,""             ,""             ,""           ,"IIF(!empty(aCols[oGetDados:Obrowse:nAt][4]),.T.,.F.)"	,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"09"       ,"Z78_DESCSE" ,"C"       ,50           ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description"  			     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           																														,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"10"       ,"Z78_VOLUME" ,"N"       ,10           ,0            ,"Volume"       ,"Volumen"      ,"Volume"              , "Volume"  		     			,"Volumen"			   			,"Volume"  		  			     , "9999999999",""          ,TODOS_MODULOS 		,"1"              ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,""           																														,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      

   Aadd(o:aSX3,{"Z78"        ,"11"       ,"Z78_STATUS" ,"C"       ,1            ,0            ,"Status"       ,"Status"       ,"Status"              , "Status"  		     			,"Status"			   			,"Status"  		  			     , ""          ,""          ,NAO_USADO 			,"'1'"            ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           																														,"1=PENDENTE;2=APROVADO;3=RECUSADO"	,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"12"       ,"Z78_OK" 	   ,"C"       ,2            ,0            ,"Marcado"      ,"Marcado"      ,"Marcado"             , "Marcado"  		     			,"Marcado"			   			,"Marcado"  		  		     , ""          ,""          ,NAO_USADO 			,""            	  ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           																														,""									,""             ,""             ,""           ,""                    									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z78"        ,"13"       ,"Z78_USERGI" ,"C"       ,17           ,0            ,"Log de Inclu" ,"Log de Inclu" ,"Log de Inclu"		 ,"Log de Inclusao"    				,"Log de Inclusao"    			,"Log de Inclusao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           																														,""                                 ,""             ,""             ,""           ,""                    									,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		   })
   Aadd(o:aSX3,{"Z78"        ,"14"       ,"Z78_USERGA" ,"C"       ,17           ,0            ,"Log de Alter" ,"Log de Alter" ,"Log de Alter"		 ,"Log de Altercao"    				,"Log de Altercao"    			,"Log de Altercao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           																										   				,""                                 ,""             ,""             ,""           ,""                    									,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		   })
   
   ///////////////////////
   //Criação dos Folders//
   ///////////////////////
   //             "XA_ALIAS" ,"XA_ORDEM" ,"XA_DESCRIC"           ,"XA_DESCSPA"           ,"XA_DESCENG"           ,"XA_PROPRI" 
   //Aadd(o:aSXA,{"EYG"      ,"1"        ,"Tipo de Container"    ,"Tipo de Container"    ,"Tipo de Container"    ,"S"        })   

   ////////////////////////////////
   //Criação de Tabelas Genéricas//
   ////////////////////////////////
   //              "X5_FILIAL" ,"X5_TABELA" ,"X5_CHAVE"  ,"X5_DESCRI","X5_DESCSPA",  "X5_DESCENG"
   //Aadd(o:aSx5, {""          ,"Z8"        ,"AUD"         ,"0001/12"  ,"0001/12"	  ,"0001/12"})
   //Aadd(o:aSx5, {""          ,"Z8"        ,"TAX"         ,"0001/12"  ,"0001/12"	  ,"0001/12"})
   //Aadd(o:aSx5, {""          ,"Z8"        ,"ADV"         ,"0001/12"  ,"0001/12"	  ,"0001/12"})
      
   /////////////////////////
   //Criação de Parâmetros//
   /////////////////////////
   //             "X6_FILIAL" ,"X6_VAR"     ,"X6_TIPO" ,"X6_DESCRIC"                                    ,"X6_DSCSPA"                                     ,"X6_DSCENG"                                      ,"X6_DESC1" ,"X6_DSCSPA1" ,"X6_DSCENG1" ,"X6_DESC2"  ,"X6_DSCSPA2" ,"X6_DSCENG2" ,"X6_CONTEUD" ,"X6_CONTSPA" ,"X6_CONTENG" ,"X6_PROPRI" ,"X6_PYME"
   //Aadd(o:aSX6,{ "  "       ,"MV_AVG0146" ,"L"       ,"Habilita a nova rotina de estufagem no Sigaeec","Habilita a nova rotina de estufagem no Sigaeec","Habilita a nova rotina de estufagem no Sigaeec" ,""         ,""           ,""           ,""          ,""           ,""           ,".F."          ,".T."          ,".T."          ,".T."         ,".T."      })
   
   ///////////////////////                 
   //Criação de Gatilhos//
   ///////////////////////
   //            "X7_CAMPO"   ,"X7_SEQUENC" ,"X7_REGRA"        															 ,"X7_CDOMIN"  	,"X7_TIPO"	, "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE"     , "X7_CONDIC"            ,"X7_PROPRI
  	Aadd(o:aSx7,{"Z79_CLIENT" ,"001"        ,'POSICIONE("SA1",1,xFilial("SA1")+M->Z79_CLIENT+M->Z79_LOJA,"A1_NOME")' 	,"Z79_NOME"   	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})
  	Aadd(o:aSx7,{"Z79_LOJA"   ,"001"        ,'POSICIONE("SA1",1,xFilial("SA1")+M->Z79_CLIENT+M->Z79_LOJA,"A1_NOME")' 	,"Z79_NOME"   	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})
  	Aadd(o:aSx7,{"Z79_PROSPE" ,"001"        ,'POSICIONE("SUS",1,xFilial("SUS")+M->Z79_PROSPE+M->Z79_PLOJA,"US_NOME")'	,"Z79_PNOME"  	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})
 	Aadd(o:aSx7,{"Z79_PLOJA"  ,"001"        ,'POSICIONE("SUS",1,xFilial("SUS")+M->Z79_PROSPE+M->Z79_PLOJA,"US_NOME")'	,"Z79_PNOME"  	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})
  	
  	Aadd(o:aSx7,{"Z79_VALOR"  ,"001"        ,'ROUND(((M->Z79_VALOR-M->Z79_DESCON)/0.8575),2)' 						 	,"Z79_VLRTOT" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='1'",  "U"})
	Aadd(o:aSx7,{"Z79_DESCON" ,"001"        ,'ROUND(((M->Z79_VALOR-M->Z79_DESCON)/0.8575),2)' 						 	,"Z79_VLRTOT" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='1'",  "U"})

	Aadd(o:aSx7,{"Z79_VALOR"  ,"002"        ,'ROUND(((M->Z79_VALOR-(M->Z79_VALOR *((M->Z79_DESPER)/100) ) )/0.8575),2)'	,"Z79_VLRTOT" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='1'",  "U"})
	Aadd(o:aSx7,{"Z79_DESPER" ,"001"        ,'ROUND(((M->Z79_VALOR-(M->Z79_VALOR *((M->Z79_DESPER)/100) ) )/0.8575),2)'	,"Z79_VLRTOT" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='1'",  "U"})

	Aadd(o:aSx7,{"Z79_DESPER" ,"003"        ,'ROUND((M->Z79_VALOR *((M->Z79_DESPER)/100) ),2)' 							,"Z79_DESCON" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='1'",  "U"})
	Aadd(o:aSx7,{"Z79_DESPER" ,"004"        ,'ROUND((M->Z79_VLRTOT *((M->Z79_DESPER)/100) ),2)' 						,"Z79_DESCON" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='2'",  "U"})

	Aadd(o:aSx7,{"Z79_DESCON" ,"003"        ,'ROUND(( (M->Z79_DESCON/M->Z79_VALOR)*100 ),2)' 						 	,"Z79_DESPER" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='1'",  "U"})
	Aadd(o:aSx7,{"Z79_DESCON" ,"004"        ,'ROUND(( (M->Z79_DESCON/M->Z79_VLRTOT)*100 ),2)' 						 	,"Z79_DESPER" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='2'",  "U"})
	
  	Aadd(o:aSx7,{"Z79_VLRTOT" ,"001"        ,'ROUND(((M->Z79_VLRTOT-M->Z79_DESCON)*0.8575),2)' 						 	,"Z79_VALOR"  	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='2'",  "U"})
	Aadd(o:aSx7,{"Z79_DESCON" ,"002"        ,'ROUND(((M->Z79_VLRTOT-M->Z79_DESCON)*0.8575),2)' 						 	,"Z79_VALOR" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='2'",  "U"})  	

	Aadd(o:aSx7,{"Z79_VLRTOT" ,"002"        ,'ROUND(((M->Z79_VLRTOT-(M->Z79_VLRTOT *((M->Z79_DESPER)/100) ))*0.8575),2)',"Z79_VALOR"  	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='2'",  "U"})
	Aadd(o:aSx7,{"Z79_DESPER" ,"002"        ,'ROUND(((M->Z79_VLRTOT-(M->Z79_VLRTOT *((M->Z79_DESPER)/100) ))*0.8575),2)',"Z79_VALOR" 	,"P"      	, "N"      , ""        ,           , ""				, "M->Z79_TPVLR=='2'",  "U"})
	
	Aadd(o:aSx7,{"Z79_SOCIO"  ,"001"        ,'POSICIONE("SA3",1,xFilial("SA3")+M->Z79_SOCIO,"A3_NOME")' 			 	,"Z79_NOMESO" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})


	Aadd(o:aSx7,{"Z78_DEPART"  ,"001"        ,'POSICIONE("Z83",1,xFilial("Z83")+M->Z78_DEPART,"Z83_DESCDE")'		 	,"Z78_DESCDE" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	Aadd(o:aSx7,{"Z78_DEPART"  ,"002"        ,'""'		 																,"Z78_AREA" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	Aadd(o:aSx7,{"Z78_DEPART"  ,"003"        ,'""'		 																,"Z78_DESCAR" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	Aadd(o:aSx7,{"Z78_DEPART"  ,"004"        ,'""'		 																,"Z78_SERVIC" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	Aadd(o:aSx7,{"Z78_DEPART"  ,"005"        ,'""'		 																,"Z78_DESCSE" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	

	Aadd(o:aSx7,{"Z78_AREA"    ,"001"        ,'POSICIONE("Z82",1,xFilial("Z82")+M->Z78_AREA,"Z82_DESCAR")'				,"Z78_DESCAR" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	Aadd(o:aSx7,{"Z78_AREA"    ,"002"        ,'""'		 																,"Z78_SERVIC" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	Aadd(o:aSx7,{"Z78_AREA"    ,"003"        ,'""'		 																,"Z78_DESCSE" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	

	Aadd(o:aSx7,{"Z78_VOLUME"  ,"001"        ,'U_Z78VOLUME()'															,"Z79_TIME" 	,"P"      	, "N"      , ""        ,           , ""				, "",  "U"})	
	//Aadd(o:aSx7,{"Z88_TPCTR" ,"001"         ,'U_GTCORP18(M->Z88_TPCTR)' 						 					 ,"Z88_NUM"    ,"P"      , "N"      , ""        ,           , "", "",  "U"})

   ///////////////////////////////
   //Criação de Consultas Padrão//
   ///////////////////////////////
   //           "XB_ALIAS" ,"XB_TIPO" ,"XB_SEQ" ,"XB_COLUNA" ,"XB_DESCRI"         ,"XB_DESCSPA"        ,"X5_DESCENG"        ,"XB_CONTEM"
   
 

   ///////////////////////////////////
   //Carregamento do Help de Campos //
   ///////////////////////////////////
   //   **Em caso de Help de campo (F1) somente usar o aHelpProb com o Nome do campo**
   //   Aadd(o:aHelpProb,{"AVG0005373",{"teste ","problema ..."}}) 
   //   Aadd(o:aHelpSol ,{"AVG0005373",{"teste ","solucao ..."}})
   
   ///////////////////////////
   //Exclusões de dicionário//
   ///////////////////////////
   // Necessário preencher o dicionário e colocar um array com os campos chave para encontrar o registro nesse dicionário.
   //             DICIONÁRIO CHAVE
   //aAdd(o:aDel,{"SXB"     ,{ "EE9"     , "1"      ,"01"     ,"DB"        ,  ,   ,   ,                              }})
   //aAdd(o:aDel,{"SX3"     ,{         ,       ,"EYG_FILIAL" ,       ,            ,            ,       ,       ,   ,      ,       ,        ,           ,          ,          ,               ,      ,          ,          ,         ,           ,          ,         ,          ,          ,          ,          ,        ,            ,            ,           ,        ,          ,          ,            ,      ,            ,           ,           ,            ,           ,         }})

   //Return cTexto - Pode ser retornado texto para o log do update.
   
Return NIL