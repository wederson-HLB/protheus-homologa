/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UGTHD001  ºAutor  ³Eduardo C. Romanini º Data ³  12/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Update de atualização de dicionários para controle de       º±±
±±º          ³empresas no GTHD.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Help-Desk                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------------*
User Function UGTHD001(o)
*-----------------------*                      

If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"FAT",{|o| UGTHD001(o)}} }
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf

Return .T.     

*-------------------------*
Static Function UGTHD001(o)
*-------------------------*
Local hFile, hFile2
Local cBuffer    := ""
Local nSize      := 0
Local nInc 
Local cLine      := ""
Local aMenu      := {}
Local nLidos     := 0
Local cMenu      := ""
Local lAtu       := .F.


/////////////////////////
//Cadastro de Empresas.//
/////////////////////////

//           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"   ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"         ,"X3_DESCSPA"         ,"X3_DESCENG"         ,"X3_PICTURE"         ,"X3_VALID"                                       ,"X3_USADO"    ,"X3_RELACAO"        ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV"          ,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER","X3_CBOX"                                                                   ,"X3_CBOXSPA"                                                                ,"X3_CBOXENG"                                                                ,"X3_PICTVAR" ,"X3_WHEN"             ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD"
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_CODIGO" ,          ,             ,             ,              ,              ,              ,                     ,                     ,                     ,                     ,                                                 ,              ,                    ,        ,           ,                     ,           ,             ,            ,            ,            ,            ,             ,            ,                                                                            ,                                                                            ,                                                                            ,             ,"INCLUI"              ,            ,            ,            ,           ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_CODFIL" ,          ,             ,             ,              ,              ,              ,                     ,                     ,                     ,                     ,                                                 ,              ,                    ,        ,           ,                     ,           ,             ,            ,            ,            ,            ,             ,            ,                                                                            ,                                                                            ,                                                                            ,             ,"INCLUI"              ,            ,            ,            ,           ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_AMB"    ,          ,             ,             ,              ,              ,              ,                     ,                     ,                     ,                     ,                                                 ,              ,                    ,        ,           ,                     ,           ,             ,            ,            ,            ,            ,             ,            ,                                                                            ,                                                                            ,                                                                            ,             ,                      ,            ,            ,            ,           ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_SERVID" ,          ,             ,             ,              ,              ,              ,                     ,                     ,                     ,                     ,                                                 ,              ,                    ,        ,           ,                     ,           ,             ,            ,"N"         ,"V"         ,            ,             ,            ,                                                                            ,                                                                            ,                                                                            ,             ,                      ,            ,            ,            ,           ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_PORTA"  ,          ,             ,             ,              ,              ,              ,                     ,                     ,                     ,                     ,                                                 ,              ,                    ,        ,           ,                     ,           ,             ,            ,"N"         ,"V"         ,            ,             ,            ,                                                                            ,                                                                            ,                                                                            ,             ,                      ,            ,            ,            ,           ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_DTINC"  ,"D"       ,8            ,0            ,"Dt. Inclusao","Dt. Inclusao","Dt. Inclusao","Data de Inclusão"   ,"Data de Inclusão"   ,"Data de Inclusão"   ,"@D"                 ,""                                               ,TODOS_MODULOS ,"dDataBase"         ,""      ,0          ,TAM+DEC+ORDEM        ,""         ,""           ,""          ,"N"         ,"V"         ,"R"         ,""           ,""          ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_USRINC" ,"C"       ,30           ,0            ,"Usr.Inclusao","Usr.Inclusao","Usr.Inclusao","Usuario de Inclusão","Usuario de Inclusão","Usuario de Inclusão","@C"                 ,""                                               ,TODOS_MODULOS ,"Alltrim(cUserName)",""      ,0          ,TAM+DEC+ORDEM        ,""         ,""           ,""          ,"N"         ,"V"         ,"R"         ,""           ,""          ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,            })
Aadd(o:aSX3,{"Z04"        ,           ,"Z04_SIGMAT" ,"C"       ,1            ,0            ,"Sigamat"      ,"Sigamat"    ,"Sigamat"     ,"Cadastro no Sigamat","Cadastro no Sigamat","Cadastro no Sigamat","@!"                 ,""                                               ,NAO_USADO     ,"N"                 ,""      ,0          ,TAM+DEC+ORDEM        ,""         ,""           ,""          ,"N"         ,"V"         ,"R"         ,""           ,""          ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,            })

//            "X7_CAMPO"   ,"X7_SEQUENC" ,"X7_REGRA"        ,"X7_CDOMIN" ,"X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE"                 , "X7_CONDIC" ,X7_PROPRI
Aadd(o:aSx7,{"Z04_AMB"     ,"001"        ,"Z10->Z10_SERVID" ,"Z04_SERVID","P"      , "S"      , "Z10"     , "1"       , "xFilial('Z10')+M->Z04_AMB",""           ,"S"})
Aadd(o:aSx7,{"Z04_AMB"     ,"002"        ,"Z10->Z10_PORTA"  ,"Z04_PORTA" ,"P"      , "N"      , ""        , ""        , ""                         ,""           ,"S"})

////////////////////////////////
//Relação Ambientes X Servidor//
////////////////////////////////

//           "INDICE" ,"ORDEM" ,"CHAVE"                                               ,"DESCRICAO"                 ,"DESCSPA"                   ,"DESCENG"                   ,"PROPRI" ,"F3" ,"NICKNAME" ,"SHOWPESQ" 
Aadd(o:aSIX,{"Z10"    ,"1"     ,"Z10_FILIAL+Z10_AMB"                                  ,"Ambiente"                  ,"Ambiente"                  ,"Ambiente"                  ,"U"      ,""   ,""         ,""        })

//           "X2_CHAVE","X2_PATH" ,"X2_ARQUIVO"             ,"X2_NOME"                  ,"X2_NOMESPA"               ,"X2_NOMEENG"               ,"X2_ROTINA" ,"X2_MODO" ,"X2_DELET" ,"X2_TTS" ,"X2_UNICO"                                            ,"X2_PYME" ,"X2_MODULO"
Aadd(o:aSX2,{"Z10"     ,"\SYSTEM\","Z10"+SM0->M0_CODIGO+"0" ,"Ambientes X Servidor    " ,"Ambientes X Servidor    " ,"Ambientes X Servidor    " ,""          ,"C"       ,0          ,""       ,"Z10_FILIAL+Z10_AMB"                                 ,"S"       , 0         })
                                      	
//           "X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"   ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"         ,"X3_DESCSPA"         ,"X3_DESCENG"         ,"X3_PICTURE"         ,"X3_VALID"                                       ,"X3_USADO"    ,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV"          ,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT" ,"X3_VLDUSER","X3_CBOX"                                                                   ,"X3_CBOXSPA"                                                                ,"X3_CBOXENG"                                                                ,"X3_PICTVAR" ,"X3_WHEN"             ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD"
Aadd(o:aSX3,{"Z10"        ,"01"       ,"Z10_FILIAL" ,"C"       ,2            ,0            ,"Filial"      ,"Filial"      ,"Filial"      ,"Filial do Sistema"  ,"Filial do Sistema"  ,"Filial do Sistema"  , ""                  ,""                                               ,NAO_USADO     ,""               ,""      ,0          ,TAM+DEC+OBRIGAT      ,""         ,""           ,""          ,"N"         ,""          ,""          ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           })
Aadd(o:aSX3,{"Z10"        ,"02"       ,"Z10_AMB"    ,"C"       ,6            ,0            ,"Ambiente"    ,"Ambiente"    ,"Ambiente"    ,"Ambiente"           ,"Ambiente"           ,"Ambiente"           , "@!"                ,"Vazio() .or. ExistCpo('SX5','Z9'+M->Z10_AMB)"   ,TODOS_MODULOS ,""               ,"Z9"    ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,"A"         ,"R"         ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,"INCLUI"              ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           })
Aadd(o:aSX3,{"Z10"        ,"03"       ,"Z10_SERVID" ,"C"       ,30           ,0            ,"Servidor"    ,"Servidor"    ,"Servidor"    ,"Servidor"           ,"Servidor"           ,"Servidor"           , ""                  ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,"A"         ,"R"         ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           })
Aadd(o:aSX3,{"Z10"        ,"04"       ,"Z10_PORTA"  ,"C"       ,4            ,0            ,"Porta"       ,"Porta"       ,"Porta"       ,"Porta"              ,"Porta"              ,"Porta"              , "9999"              ,""                                               ,TODOS_MODULOS ,""               ,""      ,0          ,TAM+DEC+OBRIGAT+ORDEM,""         ,""           ,""          ,"S"         ,"A"         ,"R"         ,""          ,""           ,""                                                                          ,""                                                                          ,""                                                                          ,""           ,""                    ,""          ,""          ,""          ,""         ,            ,           ,           ,            ,           })

cRet  := ""
cModulo := "sigaesp" //Help-Desk

//Seleciona o arquivo de menu a ser alterado.
cFile := cModulo + ".xnu"
hFile := fOpen(cFile,FO_READWRITE)

If fError() <> 0
	MsgStop("Não foi possível abrir o arquivo de menu.","Aviso")
	lRet := .F.
	Break
Endif

//Verifica o Tamanho total do arquivo
nSize := fSeek(hFile,0,2)

//Posiciona no Inicio do Arquivo
FSeek(hFile,0)      
ProcRegua(nSize)
//carrega o arquivo.
Do While nLidos < nSize
	IncProc("Carregando arquivo: " + Alltrim(cFile))
	nLidos += o:LerLinha(hFile,@cLine,nSize)
	If Empty(cLine)
		Loop
	Endif
	aAdd(aMenu,Alltrim(cLine)) 
EndDo
   
//Fecha arquivo
FClose(hFile)
   
If aScan(aMenu,{|e| Upper('<Title lang="pt">Ambientes X Servidor</Title>') $ Upper(StrTran(e,CHR(9),""))}) == 0
	nPos := aScan(aMenu,{|e| Upper('<Title lang="pt">Colaboradores x Empresas</Title>') $ Upper(StrTran(e,CHR(9),""))})-1
	nPosFim   := aScan(aMenu,{|e| Upper('</MenuItem>') $ Upper(StrTran(e,CHR(9),""))},nPos+1)
      
	cNovaOpcao := '			<MenuItem Status="Enable">'+Chr(13)+Chr(10)+;
				  '				<Title lang="pt">Ambientes X Servidor</Title>'+Chr(13)+Chr(10)+;
                  '				<Title lang="es">Ambientes X Servidor</Title>'+Chr(13)+Chr(10)+;
                  '				<Title lang="en">Ambientes X Servidor</Title>'+Chr(13)+Chr(10)+;
                  '				<Function>GTHDC007</Function>'+Chr(13)+Chr(10)+;
                  '				<Type>3</Type>'+Chr(13)+Chr(10)+;
                  '				<Access>xxxxxxxxxx</Access>'+Chr(13)+Chr(10)+;
                  '				<Module>05</Module>'+Chr(13)+Chr(10)+;
                  '				<Owner>4</Owner>'+Chr(13)+Chr(10)+;
                  '			</MenuItem>'+Chr(13)+Chr(10)
      
	aAdd(aMenu,NIL)
	aIns(aMenu,nPosFim+1)
	aMenu[nPosFim+1] := cNovaOpcao      
	
	lAtu := .T.
EndIf

If lAtu    
	//Renomeia o menu antigo
	FRename(cFile, cModulo + "_OLD.XNU")

	hFile2 := FCreate(cFile,0)
	ProcRegua(len(aMenu))
	For nInc := 1 to Len(aMenu)
		IncProc("Atualizando Menu" + AllTrim(cModulo) + "... ")      
		cBuffer += aMenu[nInc] + ENTER
	Next    

	Fwrite(hFile2,cBuffer,Len(cBuffer))  
	fClose(hFile2)         

	cRet := "Menu do módulo " + AllTrim(cModulo) + " atualizado." + ENTER
EndIf

Return cRet