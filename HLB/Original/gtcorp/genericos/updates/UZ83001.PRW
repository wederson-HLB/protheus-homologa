/*
Funcao      : UZ83001
Parametros  : 
Retorno     : Nenhum
Objetivos   : Criar tabela Z83
Autor       : Matheus Massarotto
Data/Hora   : 10/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*----------------------*
User Function UZ83001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
*----------------------*
If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"GCT",{|o| UZ83001(o)}} }//MMM=(EIC,EEC,EDC,EFF,ECO)/M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf
Return .T.                 

*-------------------------*
Static Function UZ83001(o)//M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)/xxxxxx=Chamado Average
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
   Aadd(o:aSIX,{"Z83"    ,"1"     ,"Z83_FILIAL+Z83_CODIGO"    ,"Codigo"       	,"Codigo"         ,"Code"       	,"U"      ,""   ,""         ,"S"        })

   ////////////////////////
   //Criação dos Pergunte//
   ////////////////////////
   //             "X1_GRUPO" ,"X1_ORDEM"      ,"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL"
   //aAdd(o:aSX1,{"EIC154   ","01"            ,            ,           ,           ,            ,         ,            ,            ,           ,   	 ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,        })

   ///////////////////////
   //Criação das tabelas//
   ///////////////////////  
   //             "X2_CHAVE","X2_PATH","X2_ARQUIVO"             ,"X2_NOME"                  ,"X2_NOMESPA"               ,"X2_NOMEENG"               			,"X2_ROTINA" ,"X2_MODO" ,"X2_DELET" ,"X2_TTS" ,"X2_UNICO"   ,"X2_PYME" ,"X2_MODULO"
   Aadd(o:aSX2,{"Z83"     ,"\SYSTEM\" ,"Z83"+SM0->M0_CODIGO+"0" ,"Cadastro de Departamento" ,"Cadastro de Departamento" ,"Cadastro de Departamento"        		,""          ,"C"       ,0          ,""       ,"" 			,"S"       , 0         })

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
   //           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"    ,"X3_TITSPA"    ,"X3_TITENG"           ,"X3_DESCRIC"  					,"X3_DESCSPA"   				,"X3_DESCENG"    				 ,"X3_PICTURE" ,"X3_VALID"  ,"X3_USADO"  		,"X3_RELACAO"     					,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV" 				,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER"														,"X3_CBOX" 					 		,"X3_CBOXSPA"   ,"X3_CBOXENG"   ,"X3_PICTVAR" ,"X3_WHEN"             				,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"
   Aadd(o:aSX3,{"Z83"        ,"01"       ,"Z83_FILIAL" ,"C"       ,2            ,0            ,"Filial"       ,"Filial"       ,"Filial do Sistema"   , "Filial"     					,"Filial"       				,"Filial"        				 , ""          ,""          ,NAO_USADO  		,""               					,""      ,0          ,TAM+DEC+OBRIGAT			,""         ,"S"          ,"U"          ,"N"         ,""          ,""          ,""          ,""           														,""        					 		,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })
   Aadd(o:aSX3,{"Z83"        ,"02"       ,"Z83_CODIGO" ,"C"       ,6           	,0            ,"Codigo Dep"   ,"Codigo Dep"   ,"Code Dep"            , "Codigo Departamento" 			,"Codigo Departamento"			,"Code Department" 			     , ""          ,""          ,TODOS_MODULOS 		,'GETSXENUM("Z83",Z83->Z83_CODIGO)' ,""      ,0          ,TAM+DEC+ORDEM+OBRIGAT		,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""     		,"ExistChav('Z83', M->Z83_CODIGO, 1)"								,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })   
   Aadd(o:aSX3,{"Z83"        ,"03"       ,"Z83_DESCDE" ,"C"       ,100          ,0            ,"Descricao"    ,"Descripcion"  ,"Description"         , "Descricao"  					,"Descripcion"					,"Description"  			     , ""          ,""          ,TODOS_MODULOS 		,""               					,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM 	,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z83"        ,"04"       ,"Z83_RESPON" ,"C"       ,6            ,0            ,"Responsavel"  ,"Responsable"  ,"Sponsor"         	 , "Responsavel"  					,"Responsable"					,"Sponsor" 						 , ""          ,""          ,TODOS_MODULOS 		,""               					,"Z84"   ,0          ,TAM+DEC+OBRIGAT+ORDEM 	,""         ,"S"          ,"U"          ,"S"         ,"A"         ,"R"         ,""          ,"ExistCpo('Z84', M->Z83_RESPON, 1)"								,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z83"        ,"05"       ,"Z83_DESCRE" ,"C"       ,100          ,0            ,"Nome"    	  ,"Nombre"  	  ,"Name"         		 , "Nome"  							,"Nombre"						,"Name"  			     		 , ""          ,""          ,TODOS_MODULOS 		,""               					,""      ,0          ,TAM+DEC+ORDEM 			,""         ,"S"          ,"U"          ,"S"         ,"V"         ,"R"         ,""          ,""           														,""									,""             ,""             ,""           ,""                    				,""          ,""          ,"1"         ,""         ,            ,           ,           ,            ,                    })      
   Aadd(o:aSX3,{"Z83"        ,"06"       ,"Z83_USERGI" ,"C"       ,17           ,0            ,"Log de Inclu" ,"Log de Inclu" ,"Log de Inclu"		 ,"Log de Inclusao"    				,"Log de Inclusao"    			,"Log de Inclusao"    			 , ""          ,""          ,NAO_USADO     		,""               					,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           														,""                                 ,""             ,""             ,""           ,""                    				,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		  })
   Aadd(o:aSX3,{"Z83"        ,"07"       ,"Z83_USERGA" ,"C"       ,17           ,0            ,"Log de Alter" ,"Log de Alter" ,"Log de Alter"		 ,"Log de Altercao"    				,"Log de Altercao"    			,"Log de Altercao"    			 , ""          ,""          ,NAO_USADO     		,""               					,""      ,9          ,NOME+TIPO+TAM+DEC+USO		,""         ,""           ,""           ,"N"         ,"V"         ,""          ,""          ,""           														,""                                 ,""             ,""             ,""           ,""                    				,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           		  })   

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
  	Aadd(o:aSx7,{"Z83_RESPON" ,"001"        ,'POSICIONE("Z84",1,xFilial("Z84")+M->Z83_RESPON,"Z84_NOME")'				 ,"Z83_DESCRE"  ,"P"      , "N"      , ""        ,           , "", "",  "U"})
   ///////////////////////////////

   //Criação de Consultas Padrão//
   ///////////////////////////////
   //           "XB_ALIAS" ,"XB_TIPO" ,"XB_SEQ" ,"XB_COLUNA" ,"XB_DESCRI"         		,"XB_DESCSPA"        		,"X5_DESCENG"        			,"XB_CONTEM"
   
   Aadd(o:aSXB,{ "Z83"     , "1"      ,"01"     ,"DB"        ,"Consulta Departamento"   ,"Consulta Departamento"   	,"Consultation Departament"   	,"Z83"                            })
   Aadd(o:aSXB,{ "Z83"     , "2"      ,"01"     ,"01"        ,"Codigo Dep"			  	,"Codigo Dep"				,"Code Dep"			  			,""                               })
   Aadd(o:aSXB,{ "Z83"     , "2"      ,"02"     ,"02"        ,"Descricao"			  	,"Descripcion"				,"Description"				  	,""                               })
   Aadd(o:aSXB,{ "Z83"     , "3"      ,"01"     ,"01"        ,"Cadastro Novo"        	,"Registra Nuevo"      		,"Add New"       		  		,"01"                     		  })   
   Aadd(o:aSXB,{ "Z83"     , "4"      ,"01"     ,"01"        ,"Codigo Dep"         		,"Codigo Dep"       		,"Code Dep"        		  		,"Z83_CODIGO"                     })
   Aadd(o:aSXB,{ "Z83"     , "4"      ,"01"     ,"02"        ,"Descricao"      	    	,"Descripcion"     	    	,"Description"     	  			,"Z83_DESCDE" 	                  })
   Aadd(o:aSXB,{ "Z83"     , "4"      ,"02"     ,"01"        ,"Descricao"      	    	,"Descripcion"     	    	,"Description"     	  			,"Z83_DESCDE" 	                  })
   Aadd(o:aSXB,{ "Z83"     , "4"      ,"02"     ,"02"        ,"Codigo Dep"         		,"Codigo Dep"       		,"Code Dep"        		  		,"Z83_CODIGO"                     })
   Aadd(o:aSXB,{ "Z83"     , "5"      ,"01"     ,""          ,""                    	,""                 	    ,""                    	  		,"Z83->Z83_CODIGO"                })
   Aadd(o:aSXB,{ "Z83"     , "5"      ,"02"     ,""          ,""                    	,""                   		,""                    	  		,"Z83->Z83_DESCDE"                })
   //Aadd(o:aSXB,{ "Z83"     , "6"      ,"01"     ,""          ,""                    	,""                     	,""                    	  		,""								  })

   Aadd(o:aSXB,{ "Z83Z78"  , "1"      ,"01"     ,"DB"        ,"Consulta Departamento"   ,"Consulta Departamento"   	,"Consultation Departament"   	,"Z83"                            })
   Aadd(o:aSXB,{ "Z83Z78"  , "2"      ,"01"     ,"01"        ,"Codigo Dep"			  	,"Codigo Dep"				,"Code Dep"			  			,""                               })
   Aadd(o:aSXB,{ "Z83Z78"  , "2"      ,"02"     ,"02"        ,"Descricao"			  	,"Descripcion"				,"Description"				  	,""                               })
   Aadd(o:aSXB,{ "Z83Z78"  , "3"      ,"01"     ,"01"        ,"Cadastro Novo"        	,"Registra Nuevo"      		,"Add New"       		  		,"01"                     		  })   
   Aadd(o:aSXB,{ "Z83Z78"  , "4"      ,"01"     ,"01"        ,"Codigo Dep"         		,"Codigo Dep"       		,"Code Dep"        		  		,"Z83_CODIGO"                     })
   Aadd(o:aSXB,{ "Z83Z78"  , "4"      ,"01"     ,"02"        ,"Descricao"      	    	,"Descripcion"     	    	,"Description"     	  			,"Z83_DESCDE" 	                  })
   Aadd(o:aSXB,{ "Z83Z78"  , "4"      ,"02"     ,"01"        ,"Descricao"      	    	,"Descripcion"     	    	,"Description"     	  			,"Z83_DESCDE" 	                  })
   Aadd(o:aSXB,{ "Z83Z78"  , "4"      ,"02"     ,"02"        ,"Codigo Dep"         		,"Codigo Dep"       		,"Code Dep"        		  		,"Z83_CODIGO"                     })
   Aadd(o:aSXB,{ "Z83Z78"  , "5"      ,"01"     ,""          ,""                    	,""                 	    ,""                    	  		,"Z83->Z83_CODIGO"                })
   Aadd(o:aSXB,{ "Z83Z78"  , "5"      ,"02"     ,""          ,""                    	,""                   		,""                    	  		,"Z83->Z83_DESCDE"                })
/*   Aadd(o:aSXB,{ "Z83Z78"  , "5"      ,"03"     ,""          ,""                    	,""                   		,""                    	  		,"''"				              })
   Aadd(o:aSXB,{ "Z83Z78"  , "5"      ,"04"     ,""          ,""                    	,""                   		,""                    	  		,"''"				              })
   Aadd(o:aSXB,{ "Z83Z78"  , "5"      ,"05"     ,""          ,""                    	,""                   		,""                    	  		,"''"				              })
   Aadd(o:aSXB,{ "Z83Z78"  , "5"      ,"06"     ,""          ,""                    	,""                   		,""                    	  		,"''"				              })
*/ Aadd(o:aSXB,{ "Z83Z78"  , "6"      ,"01"     ,""          ,""                    	,""                     	,""                    	  		,""								  })

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