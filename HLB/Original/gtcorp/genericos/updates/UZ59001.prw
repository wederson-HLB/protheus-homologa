/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UZ59001   ºAutor  ³Eduardo C. Romanini º Data ³  18/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Update para criação da tabela Z59, utilizada na gravação    º±±
±±º          ³de logs de integrações através de arquivos.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------*
User Function UZ59001(o)
*----------------------*
If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"FIS",{|o| UZ59001(o)}} }
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf
Return .T.     

*------------------------*
Static Function UZ59001(o)
*------------------------*


//////////////////////
//Criação de Indices//
//////////////////////
   
//           "INDICE" ,"ORDEM" ,"CHAVE"                       ,"DESCRICAO"                 ,"DESCSPA"                   ,"DESCENG"                   ,"PROPRI" ,"F3" ,"NICKNAME" ,"SHOWPESQ" 
Aadd(o:aSIX,{"Z59"    ,"1"     ,"Z59_FILIAL+Z59_ID+Z59_SEQUEN","Id + Sequencia"            ,"Id + Sequencia"            ,"Id + Sequencia"            ,"U"      ,""   ,""         ,""        })

///////////////////////
//Criação das tabelas//
///////////////////////  
//Cadastros
//           "X2_CHAVE","X2_PATH","X2_ARQUIVO"             ,"X2_NOME"          ,"X2_NOMESPA"       ,"X2_NOMEENG"       ,"X2_ROTINA" ,"X2_MODO" ,X2_MODOUN,"X2_MODOEMP","X2_DELET" ,"X2_TTS","X2_UNICO"                    ,"X2_PYME" ,"X2_MODULO","X2_DISPLAY"
Aadd(o:aSX2,{"Z59"     ,"\DATA\" ,"Z59"+SM0->M0_CODIGO+"0" ,"Log de Integração","Log de Integração","Log de Integração",""          ,"C"       ,"C"      ,"C"         ,0          ,""      ,"Z59_FILIAL+Z59_ID+Z59_SEQUEN","S"       , 0         ,""          })


//////////////////////
//Criação dos Campos//                                                                                                                    
//////////////////////  

//***USADO***
//Caso seja alterar USADO, seguir regra de no campo X3_USADO usar:
//TODOS_MODULOS = Todos os modulos.
//NAO_USADO     = Não usado  

//***RESERVADO*** // inserir os nomes das defines que deseja colocar no reservado, por exemplo NOME+TIPO+TAM+DEC+OBRIGAT
//NOME
//TIPO
//TAM 
//DEC 
//ORDEM
//OBRIGAT
//USO

//Tabela de Usuarios
//           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"   ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"         ,"X3_DESCSPA"         ,"X3_DESCENG"         ,"X3_PICTURE"         ,"X3_VALID"                                       ,"X3_USADO"    ,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV"          ,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER","X3_CBOX"                                                                   ,"X3_CBOXSPA"                                                                ,"X3_CBOXENG"                                                                ,"X3_PICTVAR" ,"X3_WHEN"             ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"
Aadd(o:aSX3,{"Z59"        ,"01"       ,"Z59_FILIAL" ,"C"       ,2            ,0            ,"Filial"      ,"Filial"      ,"Filial"      ,"Filial do Sistema"  ,"Filial do Sistema"  ,"Filial do Sistema"  , ""                  ,""                                               ,NAO_USADO     ,""               ,""      ,0          ,TAM+DEC+OBRIGAT      ,""         ,""           ,""          ,"N"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"02"       ,"Z59_ID"     ,"C"       ,6            ,0            ,"ID"          ,"ID"          ,"ID"          ,"ID da Integração"   ,"ID da Integração"   ,"ID da Integração"   , "@9"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"03"       ,"Z59_SEQUEN" ,"C"       ,3            ,0            ,"Sequencia"   ,"Sequencia"   ,"Sequencia"   ,"Sequencia"          ,"Sequencia"          ,"Sequencia"          , "@9"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"04"       ,"Z59_DATA"   ,"D"       ,8            ,0            ,"Data"        ,"Data"        ,"Data"        ,"Data"               ,"Data"               ,"Data"               , "@D"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"05"       ,"Z59_HORA"   ,"C"       ,5            ,0            ,"Hora"        ,"Hora"        ,"Hora"        ,"Hora"               ,"Hora"               ,"Hora"               , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"06"       ,"Z59_USER"   ,"C"       ,40           ,0            ,"Usuario"     ,"Usuario"     ,"Usuario"     ,"Usuario"            ,"Usuario"            ,"Usuario"            , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"07"       ,"Z59_NOMARQ" ,"C"       ,60           ,0            ,"Nome Arquivo","Nome Arquivo","Nome Arquivo","Nome Arquivo"       ,"Nome Arquivo"       ,"Nome Arquivo"       , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"08"       ,"Z59_CONARQ" ,"M"       ,60           ,0            ,"Conteudo Arq","Conteudo Arq","Conteudo Arq","Conteudo Arquivo"   ,"Conteudo Arquivo"   ,"Conteudo Arquivo"   , ""                  ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"09"       ,"Z59_ROTINA" ,"C"       ,30           ,0            ,"Rotina"      ,"Rotina"      ,"Rotina"      ,"Rotina Integração"  ,"Rotina Integração"  ,"Rotina Integração"  , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"10"       ,"Z59_TABELA" ,"C"       ,3            ,0            ,"Tabela"      ,"Tabela"      ,"Tabela"      ,"Tabela"             ,"Tabela"             ,"Tabela"             , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"11"       ,"Z59_ORDEM"  ,"N"       ,1            ,0            ,"Ordem"       ,"Ordem"       ,"Ordem"       ,"Ordem"              ,"Ordem"              ,"Ordem"              , ""                  ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"12"       ,"Z59_CHAVE"  ,"C"       ,120          ,0            ,"Chave"       ,"Chave"       ,"Chave"       ,"Chave"              ,"Chave"              ,"Chave"              , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"13"       ,"Z59_TIPO"   ,"C"       ,1            ,0            ,"Tipo Opercao","Tipo Opercao","Tipo Opercao","Tipo da Operação"   ,"Tipo da Operação"   ,"Tipo da Operação"   , "@!"                ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})
Aadd(o:aSX3,{"Z59"        ,"14"       ,"Z59_LOG"    ,"M"       ,60           ,0            ,"Log  Opercao","Log  Opercao","Log  Opercao","Log da Operação"    ,"Log da Operação"    ,"Log da Operação"    , ""                  ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           ,})

Return