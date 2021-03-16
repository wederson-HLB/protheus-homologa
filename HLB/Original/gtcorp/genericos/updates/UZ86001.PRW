/*
Funcao      : UZ86001
Parametros  : 
Retorno     : Nenhum
Objetivos   : Criar tabela Z86 e Z85
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*----------------------*
User Function UZ86001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
*----------------------*
If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"GCT",{|o| UZ86001(o)}} }//MMM=(EIC,EEC,EDC,EFF,ECO)/M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf
Return .T.                 

*-------------------------*
Static Function UZ86001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
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
   Aadd(o:aSIX,{"Z86"    ,"1"     ,"Z86_FILIAL+Z86_TPCTR+Z86_NUM"  	  ,"Tipo+Num"       ,"Tipo+Num"       ,"Tipo+Num"       ,"U"      ,""   ,""         ,"S"        })
   Aadd(o:aSIX,{"Z86"    ,"2"     ,"Z86_FILIAL+Z86_NUM"  	  		  ,"Num"            ,"Num"            ,"Num"            ,"U"      ,""   ,""         ,"S"        })

   Aadd(o:aSIX,{"Z85"    ,"1"     ,"Z85_FILIAL+Z85_NUM+Z85_ITEM+Z85_PRODUT"    ,"Num+Item+Produto"    ,"Num+Item+Produto"    ,"Num++ItemProduto"    ,"U"      ,""   ,""         ,"S"        })   
   ////////////////////////
   //Criação dos Pergunte//
   ////////////////////////
   //             "X1_GRUPO" ,"X1_ORDEM"      ,"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL"
   //aAdd(o:aSX1,{"EIC154   ","01"            ,            ,           ,           ,            ,         ,            ,            ,           ,   	 ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,        })

   ///////////////////////
   //Criação das tabelas//
   ///////////////////////  
   //             "X2_CHAVE","X2_PATH","X2_ARQUIVO"             ,"X2_NOME"                  ,"X2_NOMESPA"               ,"X2_NOMEENG"               							,"X2_ROTINA" ,"X2_MODO" ,"X2_DELET" ,"X2_TTS" ,"X2_UNICO"              ,"X2_PYME" ,"X2_MODULO"
   Aadd(o:aSX2,{"Z86"     ,"\SYSTEM\" ,"Z86"+SM0->M0_CODIGO+"0" ,"Capa Cad Controle Proposta"        ,"Capa Cad Controle Proposta"        ,"Capa Cad Controle Proposta"        ,""          ,"E"       ,0          ,""       ,"" ,"S"       , 0         })

   Aadd(o:aSX2,{"Z85"     ,"\SYSTEM\" ,"Z85"+SM0->M0_CODIGO+"0" ,"Itens Cad Controle Proposta"        ,"Itens Cad Controle Proposta"        ,"Itens Cad Controle Proposta"        ,""          ,"E"       ,0          ,""       ,"" ,"S"       , 0         })   
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
   //           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"           ,"X3_DESCRIC"  					,"X3_DESCSPA"   				,"X3_DESCENG"    				 ,"X3_PICTURE" ,"X3_VALID"  ,"X3_USADO"  		,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV" 				,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER"															,"X3_CBOX" 					 		,"X3_CBOXSPA"   ,"X3_CBOXENG"   ,"X3_PICTVAR" ,"X3_WHEN"             						,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"
   Aadd(o:aSX3,{"Z86"        ,"01"       ,"Z86_FILIAL" ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial do Sistema"   , "Filial"     					,"Filial"       				,"Filial"        				 , ""          ,""          ,NAO_USADO  		,""               ,""      ,0          ,TAM+DEC+OBRIGAT				,""         ,""           ,"U"          ,"N"         ,""          ,""          ,""          ,""           										   					,""        					 		,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z86"        ,"02"       ,"Z86_TPCTR " ,"C"       ,1            ,0            ,"Tipo"         ,"Tipo"         ,"Tipo"                , "Tipo Contrato"  				,"Tipo Contrato"				,"Tipo Contrato" 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     	    ,"" 												   					,"1=AUDITING;2=TAX;3=ADVISORY"		,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z86"        ,"03"       ,"Z86_NUM "   ,"C"       ,12           ,0            ,"Numero"       ,"Numero"       ,"Numero"              , "Numero" 						,"Numero"						,"Numero" 		 				 , ""          ,""          ,TODOS_MODULOS 		,"'.'"            ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,""           															,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })   
   Aadd(o:aSX3,{"Z86"        ,"04"       ,"Z86_SOCIO " ,"C"       ,6            ,0            ,"Socio"        ,"Socio"        ,"Socio"               , "Socio"  	   					,"Socio"	   					,"Socio" 		 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SA3"   ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('SA3', M->Z86_SOCIO, 1)"        						   		,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z86"        ,"05"       ,"Z86_NOMESO" ,"C"       ,100          ,0            ,"Nome Socio"   ,"Nome Socio"   ,"Nome Socio"          , "Nome Socio"  					,"Nome Socio"					,"Nome Socio"  				 	 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           															,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z86"        ,"06"       ,"Z86_PROSPE" ,"C"       ,6            ,0            ,"Prospect"     ,"Prospect"     ,"Prospect"            , "Prospect"  						,"Prospect"	   					,"Prospect" 		 			 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SUSZ86",0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"U_Z86_PROS() .AND. ExistCpo('SUS', M->Z86_PROSPE+M->Z86_PLOJA, 1)"  	,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z86"        ,"07"       ,"Z86_PLOJA"  ,"C"       ,2            ,0            ,"Prosp Loja"   ,"Prosp Loja"   ,"Prosp Loja"        	 , "Prospect Loja"  				,"Prospect Loja"				,"Prospect Loja"  				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"U_Z86_PROS() .AND. ExistCpo('SUS', M->Z86_PROSPE+M->Z86_PLOJA, 1)" 	,""							   		,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z86"        ,"08"       ,"Z86_PNOME"  ,"C"       ,100          ,0            ,"Nome Prosp"   ,"Nome Prosp"   ,"Nome Prosp"          , "Nome Prospect"  				,"Nome Prospect"				,"Nome Prospect"  				 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           															,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z86"        ,"09"       ,"Z86_VALOR"  ,"N"       ,14           ,2            ,"Vlr Venda"    ,"Vlr Venda"    ,"Vlr Venda"           , "Valor Venda"  					,"Valor Venda" 					,"Valor Venda"   				 , cPICTURE    ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME 						,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           															,""									,""             ,""             ,""           ,"IIF((M->Z86_STATUS)$'2/3',.F.,.T.)"		,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z86"        ,"10"       ,"Z86_DESCON" ,"N"       ,14           ,2            ,"Desconto"     ,"Desconto"     ,"Desconto"            , "Desconto"    					,"Desconto"						,"Desconto"   	 				 , cPICTURE    ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME 						,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           															,""									,""             ,""             ,""           ,"IIF((M->Z86_STATUS)$'2/3',.F.,.T.)"       ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z86"        ,"11"       ,"Z86_VLRTOT" ,"N"       ,14           ,2            ,"Vlr c/ Impos" ,"Vlr c/ Impos" ,"Vlr c/ Impos"        , "Valor total c/ Impostos"		,"Valor total c/ Impostos"		,"Valor total c/ impostos"   	 , cPICTURE    ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,NOME						,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,""           								   							,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z86"        ,"12"       ,"Z86_STATUS" ,"C"       ,1            ,0            ,"Status"       ,"Status"       ,"Status"              , "Status"  		     			,"Status"			   			,"Status"  		  			     , ""    	   ,""          ,TODOS_MODULOS		,""               ,""      ,0          ,NOME						,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,""           								   							,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })         
   Aadd(o:aSX3,{"Z86"        ,"13"       ,"Z86_MOTIVO" ,"C"       ,100          ,0            ,"Motivo"    	  ,"Motivo"       ,"Motivo" 	         , "Motivo"  						,"Motivo"						,"Motivo"  					     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,""           								   							,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z86"        ,"14"       ,"Z86_DTINC " ,"D"       ,8            ,0            ,"Data Inc"     ,"Data Inc"     ,"Data Inc"            , "Data Inclusao" 					,"Data Inclusao"				,"Data Inclusao" 				 , ""          ,""          ,NAO_USADO 			,""      		  ,""	   ,0          ,TAM+DEC+ORDEM		 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           															,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z86"        ,"15"       ,"Z86_DTAPRO" ,"D"       ,8            ,0            ,"Data Apro"    ,"Data Apro"    ,"Data Apro"           , "Data Aprovacao"					,"Data Aprovacao"				,"Data Aprovacao" 				 , ""          ,""          ,NAO_USADO 			,""      		  ,""	   ,0          ,TAM+DEC+ORDEM		 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           															,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z86"        ,"16"       ,"Z86_DTRECU" ,"D"       ,8            ,0            ,"Data Recu"    ,"Data Recu"    ,"Data Recu"           , "Data Recusa"					,"Data Recusa"					,"Data Recusa" 				 	 , ""          ,""          ,NAO_USADO 			,""      		  ,""	   ,0          ,TAM+DEC+ORDEM		 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           															,""									,""             ,""             ,""           ,""                    						,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z86"        ,"17"       ,"Z86_USERGI" ,"C"       ,17           ,0            ,"Log de Inclu" ,"Log de Inclu" ,"Log de Inclu"		 ,"Log de Inclusao"    				,"Log de Inclusao"    			,"Log de Inclusao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           								   							,""                                 ,""             ,""             ,""           ,""                    						,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		   })
   Aadd(o:aSX3,{"Z86"        ,"18"       ,"Z86_USERGA" ,"C"       ,17           ,0            ,"Log de Alter" ,"Log de Alter" ,"Log de Alter"		 ,"Log de Altercao"    				,"Log de Altercao"    			,"Log de Altercao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           															,""                                 ,""             ,""             ,""           ,""                    						,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		   })   

   Aadd(o:aSX3,{"Z85"        ,"01"       ,"Z85_FILIAL" ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial do Sistema"   , "Filial"     					,"Filial"       				,"Filial"        				 , ""          ,""          ,NAO_USADO  		,""               ,""      ,0          ,TAM+DEC+OBRIGAT				,""         ,""           ,"U"          ,"N"         ,""          ,""          ,""          ,""           									,""        					 		,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z85"        ,"02"       ,"Z85_ITEM"   ,"C"       ,2            ,0            ,"Item" 		  ,"Item" 	      ,"Item" 	             , "Item"  							,"Item"							,"Item" 	 				     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           									,""									,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z85"        ,"03"       ,"Z85_NUM "   ,"C"       ,12           ,0            ,"Numero"       ,"Numero"       ,"Numero"              , "Numero" 						,"Numero"						,"Numero" 		 				 , ""          ,""          ,NAO_USADO 			,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,""           ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           									,""									,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z85"        ,"04"       ,"Z85_PRODUT" ,"C"       ,15           ,0            ,"Produto"      ,"Produto"      ,"Produto"             , "Produto"  						,"Produto"	   					,"Produto" 		 				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SB1Z85",0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,""           									,""									,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z85"        ,"05"       ,"Z85_DESCRI" ,"C"       ,50           ,0            ,"Descricao"    ,"Descricao"    ,"Descricao"           , "Descricao"  					,"Descricao"					,"Descricao"  				     , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           									,""									,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z85"        ,"06"       ,"Z85_STATUS" ,"C"       ,1            ,0            ,"Status"       ,"Status"       ,"Status"              , "Status"  		     			,"Status"			   			,"Status"  		  			     , ""          ,""          ,TODOS_MODULOS 		,"'1'"            ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           									,"1=PENDENTE;2=APROVADO;3=RECUSADO"	,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z85"        ,"07"       ,"Z85_OK" 	   ,"C"       ,2            ,0            ,"Marcado"      ,"Marcado"      ,"Marcado"             , "Marcado"  		     			,"Marcado"			   			,"Marcado"  		  		     , ""          ,""          ,NAO_USADO 			,""            	  ,""      ,0          ,TAM+DEC+ORDEM				,""         ,""           ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           									,""									,""             ,""             ,""           ,""                    ,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z85"        ,"08"       ,"Z85_USERGI" ,"C"       ,17           ,0            ,"Log de Inclu" ,"Log de Inclu" ,"Log de Inclu"		 ,"Log de Inclusao"    				,"Log de Inclusao"    			,"Log de Inclusao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           									,""                                 ,""             ,""             ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		   })
   Aadd(o:aSX3,{"Z85"        ,"09"       ,"Z85_USERGA" ,"C"       ,17           ,0            ,"Log de Alter" ,"Log de Alter" ,"Log de Alter"		 ,"Log de Altercao"    				,"Log de Altercao"    			,"Log de Altercao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           									,""                                 ,""             ,""             ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		   })

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
   //            "X7_CAMPO"   ,"X7_SEQUENC" ,"X7_REGRA"        															 ,"X7_CDOMIN"  ,"X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE"              , "X7_CONDIC"            ,"X7_PROPRI
  	Aadd(o:aSx7,{"Z86_PROSPE" ,"001"        ,'POSICIONE("SUS",1,xFilial("SUS")+M->Z86_PROSPE+M->Z86_PLOJA,"US_NOME")',"Z86_PNOME"  ,"P"      , "N"      , ""        ,           , "", "",  "U"})
  	Aadd(o:aSx7,{"Z86_PLOJA"  ,"001"        ,'POSICIONE("SUS",1,xFilial("SUS")+M->Z86_PROSPE+M->Z86_PLOJA,"US_NOME")',"Z86_PNOME"  ,"P"      , "N"      , ""        ,           , "", "",  "U"})
  	Aadd(o:aSx7,{"Z86_VALOR"  ,"001"        ,'ROUND(((M->Z86_VALOR-M->Z86_DESCON)/0.8575),2)' 						 ,"Z86_VLRTOT" ,"P"      , "N"      , ""        ,           , "", "",  "U"})
	Aadd(o:aSx7,{"Z86_DESCON" ,"001"        ,'ROUND(((M->Z86_VALOR-M->Z86_DESCON)/0.8575),2)' 						 ,"Z86_VLRTOT" ,"P"      , "N"      , ""        ,           , "", "",  "U"})
	Aadd(o:aSx7,{"Z86_SOCIO"  ,"001"        ,'POSICIONE("SA3",1,xFilial("SA3")+M->Z86_SOCIO,"A3_NOME")' 			 ,"Z86_NOMESO" ,"P"      , "N"      , ""        ,           , "", "",  "U"})

	Aadd(o:aSx7,{"Z85_PRODUT" ,"001"        ,'POSICIONE("SB1",1,xFilial("SB1")+M->Z85_PRODUT,"B1_DESC")' 			 ,"Z85_DESCRI" ,"P"      , "N"      , ""        ,           , "", "",  "U"})
   ///////////////////////////////
   //Criação de Consultas Padrão//
   ///////////////////////////////
   //           "XB_ALIAS" ,"XB_TIPO" ,"XB_SEQ" ,"XB_COLUNA" ,"XB_DESCRI"         ,"XB_DESCSPA"        ,"X5_DESCENG"        ,"XB_CONTEM"
   
   Aadd(o:aSXB,{ "SB1Z85"     , "1"      ,"01"     ,"DB"        ,"Produto para tab Z85"   ,"Produto para tab Z85"   ,"Produto para tab Z85"   ,"SB1"                            })
   Aadd(o:aSXB,{ "SB1Z85"     , "2"      ,"01"     ,"01"        ,"Codigo"				  ,"Codigo"					,"Product"				  ,""                               })
   Aadd(o:aSXB,{ "SB1Z85"     , "4"      ,"01"     ,"01"        ,"Codigo"         		  ,"Codigo"         		,"Product"         		  ,"B1_COD"                         })
   Aadd(o:aSXB,{ "SB1Z85"     , "4"      ,"01"     ,"02"        ,"Descricao"         	  ,"Descripcion"         	,"Description"         	  ,"B1_DESC"                        })
   Aadd(o:aSXB,{ "SB1Z85"     , "5"      ,"01"     ,""          ,""                    	  ,""                 	    ,""                    	  ,"SB1->B1_COD"                    })
   Aadd(o:aSXB,{ "SB1Z85"     , "5"      ,"02"     ,""          ,""                    	  ,""                   	,""                    	  ,"SB1->B1_DESC "                  })
   Aadd(o:aSXB,{ "SB1Z85"     , "6"      ,"01"     ,""          ,""                    	  ,""                     	,""                    	  ,"U_GTCORP22()"					})
   
   Aadd(o:aSXB,{ "Z86"     , "1"      ,"01"     ,"DB"        ,"Consulta Drafts"   	  ,"Consulta Drafts"   		,"Consulta Drafts"   	  ,"Z86"                              		})
   Aadd(o:aSXB,{ "Z86"     , "2"      ,"01"     ,"01"        ,"Tipo+Num"			  ,"Tipo+Num"				,"Tipo+Num"				  ,""                                		})
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"01"        ,"Tipo"         		  ,"Tipo"         			,"Type"         		  ,"Z86_TPCTR"                       		})
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"02"        ,"Numero"         	  	  ,"Numero"       	  		,"Number"   	       	  ,"Z86_NUM"                         		})
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"03"        ,"Socio"         	  	  ,"Socio"       	  		,"Partner"   	       	  ,"Z86_SOCIO"                      		})   
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"04"        ,"Nome"         	  	  ,"Nome"       	  		,"Name"  	 	       	  ,"Z86_NOMESO"                     		})
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"05"        ,"Prospect"       	  	  ,"Prospect"      	  		,"Prospect"	 	       	  ,"Z86_PROSPE"                       		})
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"06"        ,"Prosp Loja"        	  ,"Prosp Loja"    	  		,"Prosp Store"	       	  ,"Z86_PLOJA"                        		})
   Aadd(o:aSXB,{ "Z86"     , "4"      ,"01"     ,"07"        ,"Nome Prosp"        	  ,"Nome Prosp"    	  		,"Name Prosp"	   	  	  ,"Z86_PNOME"                        		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"01"     ,""          ,""                    	  ,""                 	    ,""                    	  ,"Z86->Z86_NUM"                 		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"02"     ,""          ,""                    	  ,""                 	    ,""                    	  ,"Z86->Z86_TPCTR"               		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"03"     ,""          ,""                    	  ,""                   	,""                    	  ,"'.'"		                  		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"04"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_SOCIO"               		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"05"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_NOMESO"              		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"06"     ,""          ,""                    	  ,""                   	,""                    	  ,"''"					          		})   
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"07"     ,""          ,""                    	  ,""                   	,""                    	  ,"''"              			  		})   
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"08"     ,""          ,""                    	  ,""                   	,""                    	  ,"''"              			  		})   
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"09"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_PROSPE"              		})   
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"10"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_PLOJA" 	          		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"11"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_PNOME" 	          		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"12"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_VALOR" 	          		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"13"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_DESCON" 	          		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"14"     ,""          ,""                    	  ,""                   	,""                    	  ,"Z86->Z86_VLRTOT" 	          		})
   Aadd(o:aSXB,{ "Z86"     , "5"      ,"15"     ,""          ,""                    	  ,""                   	,""                    	  ,"U_GTGATZ88()" 	              		})
   Aadd(o:aSXB,{ "Z86"     , "6"      ,"01"     ,""          ,""                    	  ,""                     	,""                    	  ," !ALLTRIM(Z86->Z86_STATUS) $ '2/3'"})

   Aadd(o:aSXB,{ "SUSZ86"     , "1"      ,"01"     ,"DB"        ,"Prospects"   			  ,"Prospects"   			,"Prospects"   			  ,"SUS"                            })
   Aadd(o:aSXB,{ "SUSZ86"     , "2"      ,"01"     ,"01"        ,"Codigo"				  ,"Codigo"					,"Codigo"				  ,""                               })
   Aadd(o:aSXB,{ "SUSZ86"     , "2"      ,"02"     ,"02"        ,"Nome"				  	  ,"Nombre"					,"Name"				  	  ,""                               })
   Aadd(o:aSXB,{ "SUSZ86"     , "2"      ,"03"     ,"03"        ,"Telefone"				  ,"Telefono"				,"Phone Number"		  	  ,""                               })
   Aadd(o:aSXB,{ "SUSZ86"     , "3"      ,"01"     ,"01"        ,"Cadastra Novo"		  ,"Registra Nuevo"			,"Add new"		  	 	  ,"01"                             })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"01"     ,"01"        ,"Codigo"         		  ,"Codigo"         		,"Code"         		  ,"US_COD"                         })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"01"     ,"02"        ,"Loja"         	  	  ,"Tienda"         		,"Unit"         	  	  ,"US_LOJA"                        })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"01"     ,"03"        ,"Nome"         	  	  ,"Nombre"         		,"Name"         	  	  ,"SUBSTR(US_NOME,1,30)"           })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"02"     ,"01"        ,"Nome"         	  	  ,"Nombre"         		,"Name"         	  	  ,"SUBSTR(US_NOME,1,30)"           })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"02"     ,"02"        ,"Codigo"         		  ,"Codigo"         		,"Code"         		  ,"US_COD"                         })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"02"     ,"03"        ,"Loja"         	  	  ,"Tienda"         		,"Unit"         	  	  ,"US_LOJA"                        })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"03"     ,"01"        ,"Telefone"         	  ,"Telefono"         		,"Phone Number"    		  ,"US_TEL"                         })
   Aadd(o:aSXB,{ "SUSZ86"     , "4"      ,"03"     ,"02"        ,"Nome"         	  	  ,"Nombre"         		,"Name"         	  	  ,"SUBSTR(US_NOME,1,30)"           })   
   Aadd(o:aSXB,{ "SUSZ86"     , "5"      ,"01"     ,""          ,""                    	  ,""                 	    ,""                    	  ,"SUS->US_COD"                    })
   Aadd(o:aSXB,{ "SUSZ86"     , "5"      ,"02"     ,""          ,""                    	  ,""                   	,""                    	  ,"SUS->US_LOJA"                   })
   Aadd(o:aSXB,{ "SUSZ86"     , "6"      ,"01"     ,""          ,""                    	  ,""                     	,""                    	  ,"SUS->US_STATUS<>'6'"			})
   

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