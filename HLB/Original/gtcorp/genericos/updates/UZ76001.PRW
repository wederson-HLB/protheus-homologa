/*
Funcao      : UZ76001
Parametros  : 
Retorno     : Nenhum
Objetivos   : Criar tabela Z76
Autor       : Matheus Massarotto
Data/Hora   : 30/05/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*----------------------*
User Function UZ76001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
*----------------------*
If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"FIN",{|o| UZ76001(o)}} }//MMM=(EIC,EEC,EDC,EFF,ECO)/M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf
Return .T.                 

*-------------------------*
Static Function UZ76001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
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
   
   //             "INDICE" ,"ORDEM" ,"CHAVE"                  			,"DESCRICAO"      ,"DESCSPA"        	,"DESCENG"        	,"PROPRI" ,"F3" ,"NICKNAME" ,"SHOWPESQ" 
   Aadd(o:aSIX,{"Z76"    ,"1"     ,"Z76_FILIAL+Z76_EMP+Z76_FIL"  	  ,"Empresa+Filial"   ,"Empresa+Filial"     ,"Business+Branch"  ,"U"      ,""   ,""         ,"S"        })

   ////////////////////////
   //Criação dos Pergunte//
   ////////////////////////
   //             "X1_GRUPO" ,"X1_ORDEM"      ,"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL"
   //aAdd(o:aSX1,{"EIC154   ","01"            ,            ,           ,           ,            ,         ,            ,            ,           ,   	 ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,        })

   ///////////////////////
   //Criação das tabelas//
   ///////////////////////  
   //             "X2_CHAVE","X2_PATH","X2_ARQUIVO"         ,"X2_NOME"                  	,"X2_NOMESPA"               	,"X2_NOMEENG"               							,"X2_ROTINA" ,"X2_MODO" ,"X2_DELET" ,"X2_TTS" ,"X2_UNICO"              ,"X2_PYME" ,"X2_MODULO"
   Aadd(o:aSX2,{"Z76"     ,"\SYSTEM\" ,"Z76YY0" 			,"Centro de Custo X Empresa"    ,"Centro de Custo X Empresa"    ,"Cost Center X Company"        ,""          ,"E"       ,0          ,""       ,"" ,"S"       , 0         })

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
   //           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"           ,"X3_DESCRIC"  					,"X3_DESCSPA"   				,"X3_DESCENG"    				 ,"X3_PICTURE" ,"X3_VALID"  ,"X3_USADO"  		,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV" 				,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER"																					,"X3_CBOX" 					 		,"X3_CBOXSPA"   ,"X3_CBOXENG"   ,"X3_PICTVAR" ,"X3_WHEN"             				,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"
   Aadd(o:aSX3,{"Z76"        ,"01"       ,"Z76_FILIAL" ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial do Sistema"   , "Filial"     					,"Filial"       				,"Filial"        				 , ""          ,""          ,NAO_USADO  		,""               ,""      ,0          ,TAM+DEC+OBRIGAT				,""         ,""           ,"U"          ,"N"         ,""          ,""          ,""          ,""           																					,""        					 		,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z76"        ,"02"       ,"Z76_EMP"    ,"C"       ,2            ,0            ,"Empresa"      ,"Empresa"      ,"Business"            , "Cod Empresa" 					,"Cod Empresa"					,"Cod Business"			 		 , ""          ,""          ,TODOS_MODULOS 		,""               ,"SM0Z76",0          ,TAM+DEC+OBRIGAT+ORDEM		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""     		,"ExistCpo('SM0', M->Z76_EMP, 1) .and. ExistChav('Z76', M->Z76_EMP+M->Z76_FIL, 1)"        		,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })   
   Aadd(o:aSX3,{"Z76"        ,"03"       ,"Z76_DESCEM ","C"       ,50           ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description" 				 	 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     	    ,"" 										   													,""									,""             ,""             ,""           ,"" 									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z76"        ,"04"       ,"Z76_FIL "   ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial"              , "Cod Filial" 					,"Cod Filial"					,"Cod Filial" 	 				 , ""          ,""          ,TODOS_MODULOS 		,""            	  ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,"ExistCpo('SM0', M->Z76_EMP+M->Z76_FIL, 1) .and. ExistChav('Z76', M->Z76_EMP+M->Z76_FIL, 1)"   ,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })   
   Aadd(o:aSX3,{"Z76"        ,"05"       ,"Z76_DESCFI" ,"C"       ,50           ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description" 				 	 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     	    ,"" 										   													,""									,""             ,""             ,""           ,"" 									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z76"        ,"06"       ,"Z76_CCUSTO" ,"C"       ,9            ,0            ,"C Custo" 	  ,"C Custo"   	  ,"C Cost"          	 , "Centro Custo"  					,"Centro Custo"					,"Cost Center"  				 , ""          ,""          ,TODOS_MODULOS 		,""               ,"CTT"   ,0          ,TAM+DEC+OBRIGAT+ORDEM 		,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,"ExistCpo('CTT', M->Z76_CCUSTO, 1)"															,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z76"        ,"07"       ,"Z76_DESCCC" ,"C"       ,50           ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description" 				 	 , ""          ,""          ,TODOS_MODULOS 		,""               ,""      ,0          ,TAM+DEC+ORDEM 				,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     	    ,"" 										   													,""									,""             ,""             ,""           ,"" 									,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z76"        ,"08"       ,"Z76_USERGI" ,"C"       ,17           ,0            ,"Log de Inclu" ,"Log de Inclu" ,"Log de Inclu"		 ,"Log de Inclusao"    				,"Log de Inclusao"    			,"Log de Inclusao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           																					,""                                 ,""             ,""             ,""           ,""                    				,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		  })
   Aadd(o:aSX3,{"Z76"        ,"09"       ,"Z76_USERGA" ,"C"       ,17           ,0            ,"Log de Alter" ,"Log de Alter" ,"Log de Alter"		 ,"Log de Altercao"    				,"Log de Altercao"    			,"Log de Altercao"    			 , ""          ,""          ,NAO_USADO     		,""               ,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           																					,""                                 ,""             ,""             ,""           ,""                    				,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		  })   

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
  	Aadd(o:aSx7,{"Z76_CCUSTO" ,"001"        ,'POSICIONE("CTT",1,xFilial("CTT")+M->Z76_CCUSTO,"CTT_DESC01")' 			 ,"Z76_DESCCC" ,"P"      , "N"      , ""        ,           , "", "",  "U"})
	
   ///////////////////////////////
   //Criação de Consultas Padrão//
   ///////////////////////////////
   //           "XB_ALIAS" ,"XB_TIPO" ,"XB_SEQ" ,"XB_COLUNA" ,"XB_DESCRI"         ,"XB_DESCSPA"        ,"X5_DESCENG"        ,"XB_CONTEM"
   
   Aadd(o:aSXB,{ "SM0Z76"     , "1"      ,"01"     ,"DB"        ,"Empresa para tab Z76"   ,"Empresa para tab Z76"   ,"Empresa para tab Z76"   ,"SM0"                            })
   Aadd(o:aSXB,{ "SM0Z76"     , "2"      ,"01"     ,"01"        ,"Codigo"				  ,"Codigo"					,"Business"				  ,""                               })
   Aadd(o:aSXB,{ "SM0Z76"     , "4"      ,"01"     ,"01"        ,"Empresa"         		  ,"Empresa"         		,"Business"         	  ,"M0_CODIGO"                      })
   Aadd(o:aSXB,{ "SM0Z76"     , "4"      ,"01"     ,"02"        ,"Descricao"         	  ,"Descripcion"         	,"Description"         	  ,"M0_NOMECOM"                     })
   Aadd(o:aSXB,{ "SM0Z76"     , "4"      ,"01"     ,"03"        ,"Filial"         	  	  ,"Filial"         		,"Filial"         	  	  ,"M0_CODFIL"                      })
   Aadd(o:aSXB,{ "SM0Z76"     , "4"      ,"01"     ,"04"        ,"Descricao"      	  	  ,"Descripcion"       		,"Description"     	  	  ,"M0_FILIAL"                      })
   Aadd(o:aSXB,{ "SM0Z76"     , "5"      ,"01"     ,""          ,""                    	  ,""                 	    ,""                    	  ,"SM0->M0_CODIGO"                 })
   Aadd(o:aSXB,{ "SM0Z76"     , "5"      ,"02"     ,""          ,""                    	  ,""                   	,""                    	  ,"SM0->M0_NOMECOM"                })
   Aadd(o:aSXB,{ "SM0Z76"     , "5"      ,"03"     ,""          ,""                    	  ,""                   	,""                    	  ,"SM0->M0_CODFIL"                 })
   Aadd(o:aSXB,{ "SM0Z76"     , "5"      ,"04"     ,""          ,""                    	  ,""                   	,""                    	  ,"SM0->M0_FILIAL"                 })
   Aadd(o:aSXB,{ "SM0Z76"     , "6"      ,"01"     ,""          ,""                    	  ,""                     	,""                    	  ,""								})

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