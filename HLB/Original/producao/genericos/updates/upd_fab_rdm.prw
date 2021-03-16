/*
Autor    : Fabrica de Software
Data     : 26/11/2010
Objetivo : Atualizacao e criacao dos dicionarios
*/
#INCLUDE "Protheus.ch"
//#Include "Average.ch"
#Include "XMLXFUN.CH"

#define FO_READWRITE  2
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)
#define ENTER CHR(13)+CHR(10)
STATIC lCompartilhado := .F.
*=================================*
User Function Upd_Fabr(cNomeUpd)
*=================================*
Local oDlg
Local cTitulo := "Update Fabrica de Software - Average - Versao AWF101"
Local oOK := LoadBitmap(GetResources(),'LBOK')
Local oNO := LoadBitmap(GetResources(),'LBNO')
Local lMarcaItem := .F.
Local aTitulo    := {"","Id","Status","Data Ultima Execucao","Descricao do Update"}
Local aListaUpd  := {}
Local aColsSize  := {}
/*
IF VALTYPE(cNomeUpd) # "C" .OR. EMPTY(cNomeUpd) .OR.  LEN(ALLTRIM(cNomeUpd)) > 7 .OR. LEFT(UPPER(cNomeUpd),2) # "U_"
   MSGSTOP("Favor passar o parametro cNomeUpd com o nome inicial do Update do Cliente com 7 caracteres no maximo e iniciado com 'U_' ( Ex.: RETURN U_Upd_Fabr('U_UpdXX') ), Obrigado","Atencao Usuario: U_Upd_Fabr('U_UpdXX')")
   RETURN .F.
ENDIF
*/
//ALTERAÇÃO NO TAMANHO DO NOME DO UPDATE PARA 10 (LEONARDO EZ4 - 03/01/2019)
IF VALTYPE(cNomeUpd) # "C" .OR. EMPTY(cNomeUpd) .OR.  LEN(ALLTRIM(cNomeUpd)) > 10 .OR. LEFT(UPPER(cNomeUpd),2) # "U_"
   MSGSTOP("Atencao Usuario: U_Upd_Fabr('"+ALLTRIM(cNomeUpd)+"')<br>Favor passar o parametro cNomeUpd com o nome inicial do Update do Cliente com 10 caracteres no maximo e iniciado com 'U_' ( Ex.: RETURN U_Upd_Fabr('U_UpdXX') ), Obrigado","Atencao Usuario: U_Upd_Fabr('U_UpdXX')")
   RETURN .F.
ENDIF
Private lSelecEmp := .T. //.T. aparece o botao para marcar empresa e .F. nao aparece o botao e o update eh executado em todas as empresas
Default cNomeUpd  := "U_UpdXX" //Alterar XX para as iniciais do Nome do Cliente
Private cTexto    := ""
Private aEmpFilP   := {}
Private __cInterNet:= Nil
Private aLogRet := {}

//Campos do Update
Private aSx3    := {}
Private aSx1    := {}
Private aSX5    := {}
Private aSX6    := {}
Private aSX7    := {}
Private aSx2    := {}
Private aSIX    := {}
Private aEEA    := {}
Private aCpoDel := {}
Private aHelp   := {}
Private aSxa    := {}
Private aSxb    := {}
Private aAltera := {}
Private aMenu   := {}
//COLORS.CH
//#define CLR_BLACK             0               // RGB(   0,   0,   0 )
//#define CLR_BLUE        8388608               // RGB(   0,   0, 128 )
//#define CLR_GREEN         32768               // RGB(   0, 128,   0 )
//#define CLR_RED             128               // RGB( 128,   0,   0 )
Private nCor1   := CLR_GREEN//32768
Private nCor2   := CLR_BLUE //8388608
Private nCor3   := CLR_RED  //128
Private nCor4   := CLR_GREEN//32768
Private nCor5   := CLR_BLUE //8388608

//Fim Campos do Update

If !MyOpenSM0Ex(@aEmpFilP,.F.)
   Return .F.
EndIf

SET DELETED ON//Registros deletados não seram lidos

dbSelectArea("SM0")
dbGoTop()


IF EMPTY(SM0->M0_CODIGO) .OR. EMPTY(SM0->M0_CODFIL)
   ConOut("Abrindo Empresa "+SM0->M0_CODIGO+" Filial "+SM0->M0_CODFIL)
   MSGSTOP("SIGAMAT desposiconado, campos M0_CODIGO ou M0_CODFIL em branco: Delete o aqruivo SIGAMAT.IND; Entre na tela de selecao de Empresas/Filiais das ")
   RETURN .F.
ENDIF
ConOut("Abrindo Empresa "+SM0->M0_CODIGO+" Filial "+SM0->M0_CODFIL)
RpcSetType(3)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas

lProcessa:=.T.
aListaUpd := GetListUpd(cNomeUpd)

Define Msdialog oDlg Title cTitulo From 00,00 To 600,700 Pixel
    *
    oPanelTop := tPanel():New(10,10,"",oDlg,,,,,,100,100)
    oPanelTop:Align := CONTROL_ALIGN_ALLCLIENT //Topo - CONTROL_ALIGN_ALLCLIENT - CONTROL_ALIGN_TOP
    *
    oPanelBut := tPanel():New(10,10,"",oDlg,,,,,,100,100)
    oPanelBut:Align := CONTROL_ALIGN_BOTTOM //Rodapé - CONTROL_ALIGN_BOTTOM
    *
    aColsSize := {05,20,25,15,50} //Tamanho das colunas
//  oListUpd := TWBrowse():New(01,01,348,150,,aTitulo,aColsSize,oPanelTop,,,,,,,,,,,,,"ARRAY",.T.)
    oListUpd := TWBrowse():New(01,01,348,200,,aTitulo,aColsSize,oPanelTop,,,,,,,,,,,,,"ARRAY",.T.)
    If Len(aListaUpd) > 0
	   oListUpd:bLDblClick := {|| aListaUpd[oListUpd:nAt,1] := !aListaUpd[oListUpd:nAt,1], oListUpd:Refresh()}
	   oListUpd:SetArray(aListaUpd)
//  oListUpd:bLine := {|| {If(aListaUpd[oListUpd:nAt,01],oOK,oNO), aListaUpd[oListUpd:nAt,02], aListaUpd[oListUpd:nAt,03],;
//                         If(aListaUpd[oListUpd:nAt,04],"Executado","Não Executado"), aListaUpd[oListUpd:nAt,05] } }
	   oListUpd:bLine := {|| {If(aListaUpd[oListUpd:nAt,01],oOK,oNO), aListaUpd[oListUpd:nAt,02],;
	                          If(aListaUpd[oListUpd:nAt,04],"Executado","Não Executado"), aListaUpd[oListUpd:nAt,05], aListaUpd[oListUpd:nAt,03] } }
	EndIf

	//Botoes de Controle
    oBotao1:=TButton():New( 05,05, 'EXECUTAR', oPanelBut,{|| RpcClearEnv(), __cInterNet := Nil , Processa( {|| FsProcUpd(aListaUpd), oListUpd:Refresh()} ) , oPanelBut:End()},075,015,, ,,.T.,,,,{|| lProcessa },,)
	oBotao1:setcolor(nCor1)

	oBotao2:=TButton():New( 05,120, 'Marca / Desmarca Todos', oPanelBut,{|| Aeval(aListaUpd,{|aElem| aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },075,015,, ,,.T.,,,,,,)
	oBotao2:setcolor(nCor2)

    oBotao3:=TButton():New( 05,240, 'SAIR', oPanelBut,{|| RpcClearEnv(), oDlg:End()},075,015,,,,.T.,,,,,,)
	oBotao3:setcolor(nCor3)

    If lSelecEmp
       oBotao4:=TButton():New(30,05,'Selecionar Empresas',oPanelBut,{|| aListaUpd[oListUpd:nAt,06] := SelectEmp(aListaUpd[oListUpd:nAt,06]) },075,015,, ,,.T.,,,,,,)
       oBotao4:setcolor(nCor4)
    EndIf

    oBotao5:=TButton():New( 30,120, 'Ultimo Log', oPanelBut,{|| LogUpd() },075,015,, ,,.T.,,,,,,)
    oBotao5:setcolor(nCor5)

Activate MsDialog oDlg Centered

Return Nil

/*
Funcao   : SelectEmp
Autor    : Daniel Lima
Data     : 29/11/2010
Objetivo :
*/
*==================================*
Static Function SelectEmp(aEmpresas)
*==================================*
Local oDlgSM0
Local oListBox
Local aHList     := {}
Local oOk        := LoadBitMap(GetResources(),"LBOK")
Local oNo        := LoadBitMap(GetResources(),"LBNO")
Local lMarcaItem := .T.

Define MsDialog oDlgSM0 Title 'Selecione as Empresas para o processamento...' From 9,0 To 30,52

AAdd( aHList, ' ')
AAdd( aHList, 'Empresa' )
AAdd( aHList, 'Filial' )
AAdd( aHList, 'Nome' )
AAdd( aHList, 'Id.')

oListBox := TWBrowse():New(005,005,155,145,,aHList,,oDlgSM0,,,,,,,,,,,,,"ARRAY", .T.)
oListBox:SetArray( aEmpresas )
oListBox:bLine := {|| {	If(aEmpresas[oListBox:nAT,1], oOk, oNo),;
						aEmpresas[oListBox:nAT,2],;
						aEmpresas[oListBox:nAT,3],;
						aEmpresas[oListBox:nAT,4],;
						aEmpresas[oListBox:nAT,5]}}

oListBox:bLDblClick := {|| aEmpresas[oListBox:nAt,1] := !aEmpresas[oListBox:nAt,1], oListBox:Refresh()}

Define SButton From    4,170 Type 1  Action (oDlgSM0:End())   Enable Of oDlgSM0
Define SButton From 18.5,170 Type 11 Action (lMarcaItem := !aEmpresas[oListBox:nAT,1] , Aeval(aEmpresas,{|aElem|aElem[1] := lMarcaItem}) ,oListBox:Refresh());
               ONSTOP 'Marca/Desmarca' Enable Of oDlgSM0

ACTIVATE MSDIALOG oDlgSM0 CENTERED

Return( aEmpresas )

*----------------------------------------------*
Static Function MyOpenSM0Ex(aEmpresas,lSoAbre)
*----------------------------------------------*
Local lOpen := .F.
Local nLoop := 0
LOCAL lPergunta:=.T.//AWF - Quando for enviar patch para o cliente altere para .F.
//LOCAL lCompartilhado:=.F.//Virou STATIC

DO WHILE .T.

   IF !lSoAbre
      IF !lPergunta .OR. MSGYESNO("Abrir SIGAMAT.EMP Exclusivo ?")
         lCompartilhado:=.F.
      ELSE
         lCompartilhado:=.T.
      ENDIF
   ENDIF

   For nLoop := 1 To 20
       ConOut(STRZERO(nLoop,2)+"-Tentativa de abrir o SIGAMAT.EMP exclusivo...")
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", lCompartilhado, lCompartilhado )
       If !Empty( Select( "SM0" ) )
          lOpen := .T.
          dbSetIndex("SIGAMAT.IND")
	   Exit
       EndIf
       Sleep( 500 )
   Next nLoop

   If !lOpen

      ConOut("Nao foi possivel a abertura da tabela de empresas de forma exclusiva!")

      IF MSGYESNO("Nao foi possivel a abertura da tabela de empresas de forma exclusiva, Deseja tentar novamente ?",STRZERO(nLoop-1,2)+" tentativas de abrir o SIGAMAT.EMP exclusivo")
         LOOP
      ENDIF

   EndIf

   EXIT

ENDDO

IF lSoAbre
   Return( lOpen )
ENDIF

If lOpen

   If aEmpresas == Nil
      aEmpresas := {}
   EndIf
   dbSelectArea("SM0")
   dbGoTop()
   lMarca:=.T.//Para marcar só a primeira filial de cada empresa
   cEmp:=""
   Do While !Eof()
      If SM0->(DELETED())
         dbSkip()
         LOOP
      ENDIF
      If aScan(aEmpresas,{|x| x[2]+x[3] == M0_CODIGO+M0_CODFIL}) == 0
         IF cEmp # M0_CODIGO
            lMarca:=.T.
            cEmp:=M0_CODIGO
         ENDIF
         aAdd(aEmpresas, {lMarca,M0_CODIGO,M0_CODFIL,M0_FILIAL,Recno()} )
         lMarca:=.F.
      EndIf
      dbSkip()
   EndDo
EndIf

Return( lOpen )

*======================================================*
Static Function FsProcUpd(aListaUpd)
*======================================================*
Local nEmpresa, nX, nCnt, aEmpresas
Local lExecutou := .F.
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local oDlgProc := GetWndDefault()

Private aArqUpd := {}

//Array que controla o retorno
aLogRet := {}

__cInterNet := Nil
ProcRegua(Len(aListaUpd[1,6]))
oDlgProc:SetText("Executando funcao: "+aListaUpd[1,2])

If !MyOpenSM0Ex(,.T.)
   Return .F.
EndIf
IncProc("Atualizando Emp: "+SM0->M0_CODIGO+"-"+SM0->M0_CODFIL+"-"+ALLTRIM(SM0->M0_NOME))

cTexto := ""

dbSelectArea("SM0")

lSairTudo:=.F.
lSairRDM :=.F.
For nCnt:= 1 To Len(aListaUpd)

  	If !aListaUpd[nCnt][1] //Verifica se o Update sera Executado
       LOOP
    EndIf

    oDlgProc:SetText("Executando funcao: "+aListaUpd[nCnt][2])

    aEmpresas:=ACLONE(aListaUpd[nCnt][6])
    lQBGBase :=aListaUpd[nCnt][7]
    __cInterNet := Nil
    ProcRegua(Len(aEmpresas))

    For nEmpresa := 1 To Len(aEmpresas)

        If !aEmpresas[nEmpresa][1]
           LOOP
        EndIf

        SM0->(dbGoto(aEmpresas[nEmpresa][5]))
        __cInterNet := Nil
        IncProc("Atualizando Emp: "+SM0->M0_CODIGO+"-"+ALLTRIM(SM0->M0_CODFIL)+"-"+ALLTRIM(SM0->M0_NOME))
        RpcSetType(3)
        RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
        __cInterNet := Nil

        ConOut("[[[*** Atualizando Emp: "+SM0->M0_CODIGO+"-"+ALLTRIM(SM0->M0_CODFIL)+"-"+ALLTRIM(SM0->M0_NOME)+" ***]]]")
    	
        lExecutou := .T. //Caso tenha executado o Update ao menos uma vez
	
        nModulo := 17 //SIGAEIC
        lMsFinalAuto := .F.
        cIdUpd := aListaUpd[nCnt][2]

        //Adicionando no Array a Empresa
        aAdd(aLogRet, {cIdUpd+"+"+SM0->M0_CODIGO+"+"+SM0->M0_CODFIL, {} } )
    	cTexto:=" "
//  	cTexto += Replicate("-",065)+CHR(13)+CHR(10)
//  	cTexto += "Empresa.: "+SM0->M0_CODIGO+" - "+SM0->M0_NOME+CHR(13)+CHR(10)
//  	cTexto += "Filial..: "+SM0->M0_CODFIL+" - "+SM0->M0_FILIAL+CHR(13)+CHR(10)

        InitArray() //Zera os Arrays

        lRet := &("U_"+aListaUpd[nCnt][2]+"(.F.)" ) //Executa a Funcao para inserir as informacoes no Array

        IF lSairRDM .OR. lSairTudo
           cTexto+="lSairRDM .OR. lSairTudo ativado"
           U_UPDLOG(cTexto,"UPD")
           EXIT
        ENDIF

        IF !lQBGBase

           AtuSX3(SM0->M0_CODIGO,@aLogRet)

           cTexto:=" "
           __SetX31Mode(.F.)
           For nX := 1 To Len(aArqUpd)
    		   //IncProc(SM0->M0_CODIGO+"-Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
    		   If Select(aArqUpd[nx])>0
                  dbSelecTArea(aArqUpd[nx])
                  dbCloseArea()
               EndIf
    		   X31UpdTable(aArqUpd[nx])
    		   If __GetX31Error()
//  		      Alert(__GetX31Trace())
    		      Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
    		      cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
    		   EndIf
           Next nX
//         If !(__GetX31Error())

           CheckUpd(cIdUpd,,"1") //A Funcao atualiza a data de execucao

           cTexto += __GetX31Trace()//Essa funcao devolve os status de todos os arquivos atualizados//"Tabela atualizada com sucesso: "+aArqUpd[nx] +CHR(13)+CHR(10)
  		   __SetX31Mode()//Limpa o Logd os status de todos os arquivos atualizados
//	     EndIf

//         IF !EMPTY(cTexto)//AWF - mesmo em branco tem que gravar uma linha no LOG para nao dar erro
              U_UPDLOG(cTexto,"UPD")
//         ENDIF
  		
        ELSE

  	      IF lRet
             CheckUpd(cIdUpd,,"1") //A Funcao atualiza a data de execucao
          ELSE
             cTexto+="O rdmake U_"+aListaUpd[nCnt][2]+"(.F.) retornou Falso"
  		  ENDIF
          IF EMPTY(cTexto)//AWF - mesmo em branco tem que gravar uma linha no LOG para nao dar erro
             cTexto:=" "
          ENDIF
          U_UPDLOG(cTexto,"UPD")

        ENDIF

        RpcClearEnv()

        If !MyOpenSM0Ex(,.T.)
           lSairTudo:=.T.
           EXIT
        EndIf

    Next

    IF lSairTudo
       EXIT
    ENDIF

    IF LEN(aMenu) > 0
       cTexto:=""
       cTexto += UpdateMenu() //Gera o Menu fora, para nao executar por empresa...
       U_UPDLOG(cTexto,"Menu")
    ENDIF

Next

If lExecutou
   //Tela de Log
   LogUpd()

   //Log Temporario...

  /* cTexto  := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
   cFileLog:= MemoWrite(Criatrab(,.f.)+".UPD",cTexto)

   Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

     @05,05 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
     oMemo:bRClicked := {||AllwaysTrue()}

     Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
     Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ;
                     ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
   Activate MsDialog oDlg Center
			
   nArq:=FCreate("UPDATE.LOG")
   FWRITE(nArq,cTexto)
   FCLOSE(nArq)

*/
Else
   MsgInfo("Não foi selecionado nenhum Update.")
EndIf

Return Nil

*==================================*
Static Function AtuSX3(cEmp,aLogRet)
*==================================*
Local cTexto := '',h
Local nCont

If ValType(aLogRet) # "A"
   aLogRet := {}
   //Adicionando no Array a Empresa
   aAdd(aLogRet, {cEmp, {} } )
EndIf

For H := 1 To Len(aSx3)
    AAdd(aHelp,{aSx3[H,3] ,{aSx3[H,10] } })
Next


//ProcRegua(Len(aCampos)+Len(aSx2)+Len(aSx3)+Len(aSx5)+Len(aSx6)+Len(aSx7)+Len(aSix))
For nCont :=1 to Len(aSx2)
    //IncProc("Atualizando SX2...")
    //cTexto += EICAtuSXX("SX2",1,aSx2[nCont],"A Tabela (SX2)",aSx2[nCont][1],cEmp)//atualizando SX2
    aAdd(aLogRet[Len(aLogRet)][2], {"SX2", EICAtuSXX("SX2",1,aSx2[nCont],"A Tabela (SX2)",aSx2[nCont][1]) } )
Next

For nCont :=1 to Len(aSx1)
    aAdd(aLogRet[Len(aLogRet)][2], {"SX1", EICAtuSXX("SX1",1,aSx1[nCont],"O Pergunte (SX1)", AVKEY(aSX1[nCont][1],"X1_GRUPO")+AVKEY(aSX1[nCont][2],"X1_ORDEM")) })
Next


For nCont :=1 to Len(aSx3)
    //IncProc("Atualizando SX3...")
    //cTexto += EICAtuSXX("SX3",2,aSx3[nCont],"O Campo" , AVKEY(aSx3[nCont][3],"X3_CAMPO") )//atualizando sx3
    aAdd(aLogRet[Len(aLogRet)][2], {"SX3", EICAtuSXX("SX3",2,aSx3[nCont],"O Campo" , AVKEY(aSx3[nCont][3],"X3_CAMPO") ) } )
Next

For nCont :=1 to Len(aSx5)
    //IncProc("Atualizando SX5...")
    //cTexto += EICAtuSXX("SX5",1,aSx5[nCont],"A Tabela (SX5)", xFilial("SX5") + AVKEY(aSX5[nCont][2],"X5_TABELA") + aSX5[nCont][3] )//atualizando sx5
    //aAdd(aLogRet[Len(aLogRet)][2], {"SX5", EICAtuSXX("SX5",1,aSx5[nCont],"A Tabela (SX5)", xFilial("SX5") + AVKEY(aSX5[nCont][2],"X5_TABELA") + aSX5[nCont][3] ) } )//AWF - 2012/10/31
    aAdd(aLogRet[Len(aLogRet)][2], {"SX5", EICAtuSXX("SX5",1,aSx5[nCont],"A Tabela (SX5)", AVKEY(aSx5[nCont][1],"X5_FILIAL")+AVKEY(aSX5[nCont][2],"X5_TABELA")+AVKEY(aSX5[nCont][3],"X5_CHAVE") )} )
Next

For nCont :=1 to Len(aSx6)
    //IncProc("Atualizando SX6...")
    //cTexto += EICAtuSXX("SX6",1,aSx6[nCont],"O Parametro",aSx6[nCont][1]+AVKEY(aSx6[nCont][2],"X6_VAR") )//atualizando SX6
    aAdd(aLogRet[Len(aLogRet)][2], {"SX6", EICAtuSXX("SX6",1,aSx6[nCont],"O Parametro",AVKEY(aSx6[nCont][1],"X6_FIL")+AVKEY(aSx6[nCont][2],"X6_VAR") ) } )
Next

For nCont :=1 to Len(aSx7)
    //IncProc("Atualizando SX7...")
    //cTexto += EICAtuSXX("SX7",1,aSx7[nCont],"O gatilho",AVKEY(aSx7[nCont][1],"X7_CAMPO")+AVKEY(aSx7[nCont][2],"X7_SEQUENC") )//atualizando SX7
    aAdd(aLogRet[Len(aLogRet)][2], {"SX7", EICAtuSXX("SX7",1,aSx7[nCont],"O gatilho",AVKEY(aSx7[nCont][1],"X7_CAMPO")+AVKEY(aSx7[nCont][2],"X7_SEQUENC") ) } )
Next

For nCont :=1 to Len(aSix)
    //IncProc("Atualizando SIX...")
    //cTexto += EICAtuSXX("SIX",1,aSix[nCont],"O Indice",aSix[nCont][1]+aSix[nCont][2])//atualizando SIX
    aAdd(aLogRet[Len(aLogRet)][2], {"SIX", EICAtuSXX("SIX",1,aSix[nCont],"O Indice",aSix[nCont][1]+aSix[nCont][2]) } )
Next

For nCont :=1 To Len(aSxa)
    //IncProc("Atualizando SXA...")
    //cTexto += EICAtuSXX("SXA",1,aSxa[nCont],"A Pasta" , AVKEY(aSxa[nCont][1],"XA_ALIAS")+AVKEY(aSxa[nCont][2],"XA_ORDEM") )//atualizando sxa
    aAdd(aLogRet[Len(aLogRet)][2], {"SXA", EICAtuSXX("SXA",1,aSxa[nCont],"A Pasta" , AVKEY(aSxa[nCont][1],"XA_ALIAS")+AVKEY(aSxa[nCont][2],"XA_ORDEM") ) } )
Next

For nCont :=1 to Len(aSxb)
   	//IncProc("Atualizando SXB...")
   	//cTexto += EICAtuSXX("SXB",1,aSxb[nCont],"A Consulta (SXB)",AVKEY(aSxb[nCont][1],"XB_ALIAS")+aSxb[nCont][2]+aSxb[nCont][3]+aSxb[nCont][4])//atulizando SxB
   	aAdd(aLogRet[Len(aLogRet)][2], {"SXB", EICAtuSXX("SXB",1,aSxb[nCont],"A Consulta (SXB)",AVKEY(aSxb[nCont][1],"XB_ALIAS")+aSxb[nCont][2]+aSxb[nCont][3]+aSxb[nCont][4]) } )
Next

For nCont :=1 to Len(aEEA)
    //IncProc("Atualizando EEA...")
    //cTexto += EICAtuSXX("EEA",1,aEEA[nCont],"O Documento (EEA)", xFilial("EEA") + AVKEY(aEEA[nCont,2],"EEA_COD") )//Atualizando EEA
    aAdd(aLogRet[Len(aLogRet)][2], {"EEA", EICAtuSXX("EEA",1,aEEA[nCont],"O Documento (EEA)", xFilial("EEA") + AVKEY(aEEA[nCont,2],"EEA_COD") ) } )
Next

For nCont :=1 to Len(aAltera)
//  UpIncProc("Atualizando "+cAlias+"...")
    cAlias :=aAltera[nCont][1]
    nOrder :=aAltera[nCont][2]
    cSeek  :=aAltera[nCOnt][3] //Coloque o conteudo já com o AVKEY() para acertar seek
    cCpoAtu:=aAltera[nCOnt][4]
    cConteu:=aAltera[nCOnt][5]
    IF LEN(aAltera[nCOnt]) = 6
       cAliasAtu:=aAltera[nCOnt][6]
    ELSE
       cAliasAtu:=""
    ENDIF
    //cTexto +=AlteraCpo(cAlias,nOrder,cCpoAtu,cConteu,"A Chave do Alias "+cAlias, cSeek, cAliasAtu )
    aAdd(aLogRet[Len(aLogRet)][2], {"Alt",AlteraCpo(cAlias,nOrder,cCpoAtu,cConteu,"A Chave do Alias "+cAlias, cSeek, cAliasAtu )} )
Next

For nCont :=1 to Len(aCpoDel)
    cAlias :=aCpoDel[nCont][1]
    nOrder :=aCpoDel[nCont][2]
    cSeek  :=aCpoDel[nCOnt][3] //Coloque o conteudo já com o AVKEY() para acertar seek
    IF LEN(aCpoDel[nCOnt]) = 4
       cAliasAtu:=aCpoDel[nCOnt][4]
    ELSE
       cAliasAtu:=""
    ENDIF

    cRetorno:=DelReg(cAlias,nOrder,cSeek,cAliasAtu)
    U_UPDLOG(cRetorno,"Del")
//  aAdd(aLogRet[Len(aLogRet)][2], {"DEL", DelReg(cAlias,nOrder,cSeek,cAliasAtu) } )
Next

//FRR - 10/05/2010 - Atualiza o SX1, utilizando a função PUTSX1
//IncProc("Atualizando SX1...")
//EECATUSX1()

Return cTexto

*-----------------------------------------------------------*
Static Function DelReg(cAlias,nOrder,cChave,cAliasAtu)
*-----------------------------------------------------------*
Local lAchou := .F.
Local cMsg := ""

   dbSelectArea(cAlias)
   (cAlias)->( dbSetOrder(nOrder) )
   If (cAlias)->( dbSeek(cChave))
      (cAlias)->(RecLock(cAlias,.F.))
      (cAlias)->(DBDELETE())
      (cAlias)->(MSUnLock())
      lAchou  := .T.
      IF cAliasAtu # NIL .AND. !EMPTY(cAliasAtu)
         IF aScan( aArqUpd,cAliasAtu )== 0
            AADD( aArqUpd,cAliasAtu )
         ENDIF
      ENDIF
   EndIf

   If lAchou
      cMsg += "A Chave do Alias "+cAlias+": " +cChave +' foi deletada com sucesso. (D)'
   Else
      cMsg += "A Chave do Alias "+cAlias+": " +cChave +' ja foi deletada. '
   EndIf

   IF cAlias = "SX3" .AND. cAliasAtu # NIL .AND. !EMPTY(cAliasAtu)
      DBSELECTAREA(cAliasAtu)
//    cChave:=ALLTRIM(cChave)
      IF (cAliasAtu)->(FIELDPOS(cChave)) # 0
         cMsg += CHR(13)+CHR(10)+"Campo " +cChave +" existe na Tabela "+cAliasAtu
      ELSE
         cMsg += CHR(13)+CHR(10)+"Campo " +cChave +" nao existe na Tabela "+cAliasAtu
      ENDIF
   ENDIF

Conout(cMsg)
Return cMsg
*---------------------------------------------------------------------------*
Static Function EICAtuSXX(cAlias,nOrder,aSxx,cMenssage,cSeek,cEmp)
*---------------------------------------------------------------------------*
Local cTexto := ''
Local lInclui := .F.
Local nI
Default cEmp := ""
Begin Sequence

   DBSelectArea(cAlias)
   (cAlias)->( DBSetOrder(nOrder) )
   lInclui:= !(cAlias)->( DBSeek(cSeek) )

   //DRL 09/12/2010 - Tratamento do campo Usado - SX3
   If cAlias == "SX3"

      Do While Len(aSxx) <= 42
         aAdd(aSxx, Nil)
      EndDo

      aSxx := aClone(AdjSX3(aSxx,lInclui))
   ElseIf cAlias == "SX2"
      If aSxx[3] == Nil .Or. Empty(aSxx[3])
         aSxx[3] := AllTrim(aSxx[1]) + cEmp
      EndIf
   //Fim DRL - Tratamento do campo usado - SX3
   ElseIf cAlias == "SX6"
      If !Empty(SX6->X6_CONTEUD)
         aSxx[13] := SX6->X6_CONTEUD
      EndIf
      If !Empty(SX6->X6_CONTSPA)
         aSxx[14] := SX6->X6_CONTSPA
      EndIf
      If !Empty(SX6->X6_CONTEUD)
         aSxx[15] := SX6->X6_CONTENG
      EndIf
      If aSxx[5] == Nil .Or. Empty(aSxx[5])
         aSxx[5] := aSxx[4]
      EndIf
      If aSxx[6] == Nil .Or. Empty(aSxx[6])
         aSxx[6] := aSxx[4]
      EndIf

      If aSxx[8] == Nil .Or. Empty(aSxx[8])
         aSxx[8] := aSxx[7]
      EndIf
      If aSxx[9] == Nil .Or. Empty(aSxx[9])
         aSxx[9] := aSxx[7]
      EndIf

      If aSxx[11] == Nil .Or. Empty(aSxx[11])
         aSxx[11] := aSxx[10]
      EndIf
      If aSxx[12] == Nil .Or. Empty(aSxx[12])
         aSxx[12] := aSxx[10]
      EndIf
   EndIf

   RecLock(cAlias,lInclui)
   For nI:=1 to (cAlias)->(Fcount())
      If nI <= Len(aSxx)
        If aSxx[nI] # Nil
           IF cAlias = "SX3" .AND. ValType(aSxx[nI]) = "C"//AWF - 24/09/2014 - Para corregir o erro de sumi os campos da tabela atualizada quando tem espacos no conteudo da array
              aSxx[nI]:=ALLTRIM(aSxx[nI])
           ENDIF
           (cAlias)->( FieldPut(nI,aSxx[nI]) )
        EndIf
      Else
        Exit
      EndIf
   Next
   (cAlias)->( MSUnLock() )
   If lInclui
      cTexto :=  cMenssage +" " +cSeek +" foi incluido com sucesso. (I)"//+ CHR(13)+CHR(10)
   Else
      cTexto :=  cMenssage +" " +cSeek +" foi atualizado com sucesso."//+CHR(13)+CHR(10)
   EndIf

   If cAlias == "SX3"
      nPos := aScan(aHelp,{|e| ALLTRIM(e[1]) == ALLTRIM(cSeek) })
      If nPos > 0//Campo           ,Help Portugues,Help Espanhol ,Help Ingles
         PutHelp("P"+aHelp[nPos][1],aHelp[nPos][2],aHelp[nPos][2],aHelp[nPos][2],.T.)
      EndIf

      IF aScan( aArqUpd,aSxx[1] )== 0
         AADD( aArqUpd,aSxx[1] )
      ENDIF
   ELSEIf cAlias == "SIX"
      IF aScan( aArqUpd,aSxx[1] )== 0
         AADD( aArqUpd,aSxx[1] )
      ENDIF
   EndIf

End Sequence
Conout(cTexto)
Return cTexto

/*
Autor    : Daniel Lima
Data     : 12/01/2010
Objetivo : Retorna o Array do SX3 ajustado.
*/
*=============================*
Static Function AdjSX3(aAdjSX3,lInclui)
*=============================*

//DRL Ajusta a Ordem caso esteja vazia
If lInclui
   If aAdjSX3[SX3->(FieldPos("X3_ORDEM"))] == Nil .Or. Empty(aAdjSX3[SX3->(FieldPos("X3_ORDEM"))]) //X3_ORDEM

      nOldRec := SX3->(RecNo())
      nOldInd := SX3->(IndexOrd())
      SX3->(dbSetOrder(1))
      SX3->(dbGoTop())
      SX3->(dbSeek(aAdjSX3[1]),,.T.) //Posiciona no ultimo registro
      aAdjSX3[SX3->(FieldPos("X3_ORDEM"))] := Soma1(SX3->X3_ORDEM)
      SX3->(dbGoTo(nOldRec))
      SX3->(dbSetOrder(nOldInd))
   EndIf
Else
// aAdjSX3[SX3->(FieldPos("X3_ORDEM"))] := SX3->X3_ORDEM//AWF 2013/04/26 - Tirei pq ao rodar o update de novo nao acertava com as novas ordens
EndIf

//Ajustes das Descricoes
If aAdjSX3[SX3->(FieldPos("X3_TITSPA"))] == Nil .Or. Empty(aAdjSX3[SX3->(FieldPos("X3_TITSPA"))]) //X3_TITSPA
   aAdjSX3[SX3->(FieldPos("X3_TITSPA"))] := aAdjSX3[7]
EndIf

If aAdjSX3[SX3->(FieldPos("X3_TITENG"))] == Nil .Or. Empty(aAdjSX3[SX3->(FieldPos("X3_TITENG"))]) //X3_TITENG
   aAdjSX3[SX3->(FieldPos("X3_TITENG"))] := aAdjSX3[7]
EndIf

If aAdjSX3[SX3->(FieldPos("X3_DESCRIC"))] == Nil .Or. Empty(aAdjSX3[SX3->(FieldPos("X3_DESCRIC"))]) //X3_DESCRIC
   aAdjSX3[SX3->(FieldPos("X3_DESCRIC"))] := aAdjSX3[7]
EndIf

If aAdjSX3[SX3->(FieldPos("X3_DESCSPA"))] == Nil .Or. Empty(aAdjSX3[SX3->(FieldPos("X3_DESCSPA"))]) //X3_DESCSPA
   aAdjSX3[SX3->(FieldPos("X3_DESCSPA"))] := aAdjSX3[10]
EndIf

If aAdjSX3[SX3->(FieldPos("X3_DESCENG"))] == Nil .Or. Empty(aAdjSX3[SX3->(FieldPos("X3_DESCENG"))]) //X3_DESCENG
   aAdjSX3[SX3->(FieldPos("X3_DESCENG"))] := aAdjSX3[10]
EndIf
//Fim - Ajustes das Descricoes

If aAdjSX3[SX3->(FIELDPOS("X3_USADO"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_USADO"))]) //X3_USADO
   aAdjSX3[SX3->(FIELDPOS("X3_USADO"))] := GetUsado()
EndIf

If aAdjSX3[SX3->(FIELDPOS("X3_RESERV"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_RESERV"))]) //X3_RESERV - Se Reserv em Branco Preenche...
   aAdjSX3[SX3->(FIELDPOS("X3_RESERV"))] := X3Reserv("xxxxxx x") //Reserv Padrao, tudo editavel e nao obrigatorio
EndIf

If aAdjSX3[SX3->(FIELDPOS("X3_PROPRI"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_PROPRI"))]) //X3_PROPRI
   aAdjSX3[SX3->(FIELDPOS("X3_PROPRI"))] := "U"
EndIf

If aAdjSX3[SX3->(FIELDPOS("X3_BROWSE"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_BROWSE"))]) //X3_BROWSE
   aAdjSX3[SX3->(FIELDPOS("X3_BROWSE"))] := "N"
EndIf

If aAdjSX3[SX3->(FIELDPOS("X3_VISUAL"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_VISUAL"))]) //X3_VISUAL
   aAdjSX3[SX3->(FIELDPOS("X3_VISUAL"))] := "A"
EndIf

If aAdjSX3[SX3->(FIELDPOS("X3_CONTEXT"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_CONTEXT"))]) //X3_CONTEXT
   aAdjSX3[SX3->(FIELDPOS("X3_CONTEXT"))] := "R"
EndIf

If aAdjSX3[SX3->(FIELDPOS("X3_PYME"))] == Nil .Or. Empty(aAdjSX3[SX3->(FIELDPOS("X3_PYME"))]) //X3_PYME
   aAdjSX3[SX3->(FIELDPOS("X3_PYME"))] := "S"
EndIf

Return aAdjSX3

/*
Autor    : Daniel Lima
Data     : 12/01/2010
Objetivo : Retorna o Array do SX3 ajustado.
*/
/*=============================*
Static Function AdjSX6(aAdjSX6)
*=============================*

If aAdjSX6[SX6->(FieldPos("X6_DSCSPA"))] == Nil .Or. Empty(aAdjSX6[SX6->(FieldPos("X6_DSCSPA"))]) //"X6_DSCSPA"
   aAdjSX6[SX6->(FieldPos("X6_DSCSPA"))] := aAdjSX6[SX6->(FieldPos("X6_DESCRIC"))]
EndIf

If aAdjSX6[SX6->(FieldPos("X6_DSCENG"))] == Nil .Or. Empty(aAdjSX6[SX6->(FieldPos("X6_DSCENG"))]) //"X6_DSCENG"
   aAdjSX6[SX6->(FieldPos("X6_DSCENG"))] := aAdjSX6[SX6->(FieldPos("X6_DESCRIC"))]
EndIf

If aAdjSX6[SX6->(FieldPos("X6_CONTSPA"))] == Nil .Or. Empty(aAdjSX6[SX6->(FieldPos("X6_CONTSPA"))]) //"X6_CONTSPA"
   aAdjSX6[SX6->(FieldPos("X6_CONTSPA"))] := aAdjSX6[SX6->(FieldPos("X6_CONTEUD"))]
EndIf

If aAdjSX6[SX6->(FieldPos("X6_CONTENG"))] == Nil .Or. Empty(aAdjSX6[SX6->(FieldPos("X6_CONTENG"))]) //"X6_CONTENG"
   aAdjSX6[SX6->(FieldPos("X6_CONTENG"))] := aAdjSX6[SX6->(FieldPos("X6_CONTEUD"))]
EndIf

Return aAdjSX6*/

/*
Autor    : Daniel Lima
Data     : 09/12/2010
Objetivo : Retornar as informacoes criptografada do campo usado
*/
*==============================*
Static Function GetUsado(cCampo)
*==============================*
Local cUsado
//Retorna um array com todos os modulos
//Local aModulos := RetModName()

If cCampo == Nil .Or. Empty(cCampo)
   cUsado := Str2Bin(FirstBitOn( Space(99)+"x  " )) //Criptografa o Usado
Else
   cUsado := cCampo
EndIf

Return cUsado

*-----------------------------------------------------------------------------------------*
Static Function AlteraCpo(cAlias,nOrder,cOrigem,cConteudo,cMenssage,cSeek,cAliasAtu)
*-----------------------------------------------------------------------------------------*
Local cTexto  := ''

Begin Sequence

IF (cAlias)->(FIELDPOS(cOrigem)) = 0
   cTexto :=  "Campo "+cOrigem+" nao existe no Alias " +cAlias
   BREAK
ENDIF

IF cAlias == 'SX6' //PARAMETRO NAO TEM AVSX3 ENTAO USAR PADR
   nPos := AT(UPPER(cSeek),'MV')

   //SABER SE NO SEEK TA VINDO FILIAL
   IF SUBSTR(cSeek,1,2) <> 'MV'
      cFil:= SUBSTR(cSeek,1,len(SM0->M0_CODFIL))
   ELSE
      cFil:= '  '
   ENDIF

   cMv  := SUBSTR(cSeek,nPos,len(cSeek))
   nTam := len(cMv)
   nDif := 10 - nTam // pra saber quantos caracteres faltam pra preencher 10 que é o tamanho do X6_VAR
   cMv  := PADR(cMv,nTam+nDif)
   cSeek:= cFil + cMv

ENDIF


DBSelectArea(cAlias)
(cAlias)->( DBSetOrder(nOrder) )

IF (cAlias)->( DBSeek(cSeek) )
   (cAlias)->( RecLock(cAlias,.F.) )
   (cAlias)->&((cAlias)->(cOrigem)):= cConteudo
   (cAlias)->( MSUnLock() )

   IF cAliasAtu # NIL .AND. !eMPTY(cAliasAtu)
      IF aScan( aArqUpd,cAliasAtu )== 0
         AADD( aArqUpd,cAliasAtu )
      ENDIF
   ENDIF

   cTexto :=  cMenssage +" " +cSeek +' foi alterada com sucesso. '// +CHR(13)+CHR(10)
Else
   cTexto :=  cMenssage +" " +cSeek +' não encontrado. '// +CHR(13)+CHR(10)
EndIf

IF !EMPTY(cAliasAtu) .AND. aScan( aArqUpd,cAliasAtu )== 0
   AADD( aArqUpd,cAliasAtu)
ENDIF


End Sequence
Conout(cTexto)
Return cTexto

/*
Funcao     : UpdateMenu()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Inclui novas opções no Menu
Autor      : Daniel Lima
Data/Hora  : 31/03/2010
*/
*------------------------*
Static  Function UpdateMenu()
*------------------------*
Local hFile, hFile2
Local cBuffer    := ""
Local nSize      := 0
Local cTextO     := ''
Local nI         := 0
Local lMenu      := .F.// Se for .T. ira criar um menu PRINCIPAL e um item menu, caso contrario so ira criar um item menu
Local nX
Local cModulo    := ""
Local cFile      := ""
Local cBase      := ""
Local cFuncao    := ""
Local cDesGrupo  := ""
Local cDesItem1  := ""
Local cType      := ""
Local cNroModulo := ""
Local lMenuInMenu:= .F. // By JPP - 16/09/2010 - 08:54 - Esta variável indica se será criado um Menu dentro de outro Menu.
//                                                                                                              XNU do Usuario
             //MODULO    ,BASE    ,FUNCAO        ,DESCR.MENU   ,DESCR.ITEM     ,TIPO FUNCAO,TABELAS,lMenuInMenu,ARQUIVO XNU,NRO MÓDULO
//AADD(aMenu,{"SIGAEEC","EECAP100","AvIntPdVenda",""           ,"Integracao PV","3"        ,{}     ,     .F.   ,"SIGAEEC"  , "5"     }) //incluir menu e items
             //    1        2         3              4                 5            6         7           8         9        10
//Exemplo de inserir menu principal
//AADD(aMenu,{"SIGAEIC","EECAP100","U_TESTE1"    ,"Menu 1"     ,"Opcao 1"      ,"3"        ,{}     ,     .F.   ,"SIGAEIC"  , "5"     }) //incluir menu e items
//AADD(aMenu,{"SIGAEIC","U_TESTE1","U_TESTE2"    ,             ,"Opcao 2"      ,"3"        ,{}     ,     .F.   ,"SIGAEIC"  , "5"     }) //incluir menu e items
//AADD(aMenu,{"SIGAEIC","U_TESTE2","U_TESTE3"    ,             ,"Opcao 3"      ,"3"        ,{}     ,     .F.   ,"SIGAEIC"  , "5"     }) //incluir menu e items
//Exemplo de inserir menu dentro de outro
//AADD(aMenu,{"SIGAEIC","EECAP100","U_TESTE1"    ,"Menu 2"     ,"Opcao 1"      ,"3"        ,{}     ,     .T.   ,"SIGAEIC"  , "5"     }) //incluir menu e items
//AADD(aMenu,{"SIGAEIC","U_TESTE1","U_TESTE2"    ,             ,"Opcao 2"      ,"3"        ,{}     ,     .F.   ,"SIGAEIC"  , "5"     }) //incluir menu e items
//AADD(aMenu,{"SIGAEIC","U_TESTE2","U_TESTE3"    ,             ,"Opcao 3"      ,"3"        ,{}     ,     .F.   ,"SIGAEIC"  , "5"     }) //incluir menu e items

Begin Sequence
   For nI:=1 To Len(aMenu)
      cModulo    := aMenu[nI][1]
      cBase      := aMenu[nI][2]
      cFuncao    := aMenu[nI][3]
      cDesGrupo  := aMenu[nI][4]
      cDesItem1  := aMenu[nI][5]
      cType      := aMenu[nI][6]
      lMenuInMenu:= aMenu[nI][8] // By JPP - 16/09/2010 - 08:54 - Esta variável indica se será criado um Menu dentro de outro Menu.
      IF LEN(aMenu[nI]) > 8 .AND. aMenu[nI][9] != Nil .AND. !Empty(aMenu[nI][9])
         cFile   := ALLTRIM(aMenu[nI][9])+".XNU"
      ELSE
         cFile   := cModulo + ".XNU"
      ENDIF
      If LEN(aMenu[nI]) > 9 .AND. aMenu[nI][10] != Nil .AND. !Empty(aMenu[nI][10])
         cNroModulo := aMenu[nI][10]
      Else
         //KLR - 07/12/11 - tratamento do nro do módulo
         cNroModulo := retModulo(cFile)
      EndIf

      If cNroModulo == "0"
         cTexto+="Não foi possível abrir o arquivo "+cFile+ENTER
         Loop
      EndIf

      If LEN(aMenu[nI]) > 10 .AND. aMenu[nI][11] != Nil .AND. !Empty(aMenu[nI][11])//AWF - 2013/09/17
         cAcesso := aMenu[nI][11]
      Else
         cAcesso := ""
      EndIf

      If lMenuInMenu// By JPP - 16/09/2010 - 08:54 - Esta variável indica se será criado um Menu dentro de outro Menu.
         lMenu:= .F.
      ElseIf !Empty(cDesGrupo) //Indica se ira incluir uma opçao nova no menu PRINCIPAL
         lMenu:= .T.
      Else // Indica se será criado um subitem do menu.
         lMenu:= .F.
      EndIf

      If Empty(cBase)
         cTexto+="Nenhuma Funcao Base foi informada. O Menu nao foi atualizado."+ENTER
         LOOP
      EndIf
      hFile := fOpen(cFile,FO_READWRITE+FO_EXCLUSIVE)

      IF fError() <> 0
         cTexto+="Nao foi possível abrir o arquivo de menu: "+cFile+ENTER
         LOOP
      Endif

      //Verifica o Tamaqnho Total do Arquivo
      nSize := fSeek(hFile,0,2)

      //Posiciona no Inicio do Arquivo
      FSeek(hFile,0)

      cBuffer  := Space(nSize) //Aloca buffer
      FRead(hFile,@cBuffer,nSize) //Efetua leitura

      //Fecha arquivo
      FClose(hFile)
      //Verifica se a função que será incluída não existe no menu.
      nPos := At(AllTrim(Upper(cFuncao)),Upper(cBuffer))

     If nPos == 0

        FRename(cFile,Left(cFile,Len(cFile) - 4)+"_OLD.XNU")

        hFile2 := FCreate(cFile,0)
        //FRename(cFile,Left(cFile,Len(cFile) - 4)+"_OLD.XNU")

        nPos1 := At(Alltrim(Upper(cBase)),Upper(cBuffer))

        If nPos1 = 0
           cTexto+="Funcao base: "+cBase+" nao encontrada no arquivo de menu: "+cFile+ENTER
           fClose(hFile2)
           LOOP
        EndIf

        If lMenu
           nPos2 := At('<MENU STATUS="ENABLE">',Upper(Substr(cBuffer,nPos1,nSize)) )
        Else
           nPos2 := At('</MENUITEM>',Upper(SubStr(cBuffer,nPos1,nSize)))
        EndIf

        If nPos2 = 0
           cTexto+='</MENUITEM> ou <MENU STATUS="ENABLE"> nao encontrado  no arquivo de menu: '+cFile+ENTER
           fClose(hFile2)
           LOOP
        EndIf

        nPos  := nPos1 + nPos2

        If lMenuInMenu  // By JPP - 16/09/2010 - 09:10
           cMenu :=chr(13)+chr(10)
           cMenu += Space(24)+'<Menu Status="Enable">'                                     +ENTER
		   cMenu += Space(24)+'<Title lang="pt">'+cDesGrupo+'</Title>'                     +ENTER
		   cMenu += Space(24)+'<Title lang="es">'+cDesGrupo+'</Title>'                     +ENTER
		   cMenu += Space(24)+'<Title lang="en">'+cDesGrupo+'</Title>'                     +ENTER
		   cMenu += Space(24)+"<MenuItem Status="+CHR(34)+"Enable"+CHR(34)+">"             +ENTER
           cMenu += Space(32)+"<Title lang="+CHR(34)+"pt"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(32)+"<Title lang="+CHR(34)+"es"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(32)+"<Title lang="+CHR(34)+"en"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(32)+"<Function>"+cFuncao+"</Function>"                           +ENTER
           cMenu += Space(32)+"<Type>"+cType+"</Type>"                                     +ENTER
           If Len(aMenu[nI][7]) <> 0
              For nX:=1 To Len(aMenu[nI][7])
                  cMenu += Space(32)+"<Tables>"+aMenu[nI][7][nX]+"</Tables>"		       +ENTER
              Next
           EndIf
           cMenu += Space(32)+"<Access>xxxxxxxxxx</Access>"                                +ENTER
           cMenu += Space(32)+"<Module>"+cNroModulo+"</Module>"                            +ENTER
           cMenu += Space(24)+"</MenuItem>"                                                +ENTER
           cMenu += Space(24)+"</Menu>"                                                    +ENTER
        ElseIf lMenu
           cMenu :=chr(13)+chr(10)
           cMenu += Space(24)+'<Menu Status="Enable">'                                     +ENTER
		   cMenu += Space(24)+'<Title lang="pt">'+cDesGrupo+'</Title>'                     +ENTER
		   cMenu += Space(24)+'<Title lang="es">'+cDesGrupo+'</Title>'                     +ENTER
		   cMenu += Space(24)+'<Title lang="en">'+cDesGrupo+'</Title>'                     +ENTER
		   cMenu += Space(24)+"<MenuItem Status="+CHR(34)+"Enable"+CHR(34)+">"             +ENTER
           cMenu += Space(32)+"<Title lang="+CHR(34)+"pt"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(32)+"<Title lang="+CHR(34)+"es"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(32)+"<Title lang="+CHR(34)+"en"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(32)+"<Function>"+cFuncao+"</Function>"                           +ENTER
           cMenu += Space(32)+"<Type>"+cType+"</Type>"                                     +ENTER
           If Len(aMenu[nI][7]) <> 0
              For nX:=1 To Len(aMenu[nI][7])
                  cMenu += Space(32)+"<Tables>"+aMenu[nI][7][nX]+"</Tables>"		       +ENTER
              Next
           EndIf
           cMenu += Space(32)+"<Access>xxxxxxxxxx</Access>"                                +ENTER
           cMenu += Space(32)+"<Module>"+cNroModulo+"</Module>"                            +ENTER
           cMenu += Space(24)+"</MenuItem>"                                                +ENTER
           cMenu += Space(24)+"</Menu>"                                                    +ENTER
        Else
           cMenu :=chr(13)+chr(10)
           cMenu += Space(12)+"<MenuItem Status="+CHR(34)+"Enable"+CHR(34)+">"             +ENTER
           cMenu += Space(16)+"<Title lang="+CHR(34)+"pt"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(16)+"<Title lang="+CHR(34)+"es"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(16)+"<Title lang="+CHR(34)+"en"+CHR(34)+">"+cDesItem1+"</Title>" +ENTER
           cMenu += Space(16)+"<Function>"+cFuncao+"</Function>"                           +ENTER
           cMenu += Space(16)+"<Type>"+cType+"</Type>"                                     +ENTER
           If Len(aMenu[nI][7]) <> 0
              For nX:=1 to len(aMenu[nI][7])
                  cMenu += Space(16)+"<Tables>"+aMenu[nI][7][nX]+"</Tables>"		       +ENTER
              Next
           EndIf
           cMenu += Space(16)+"<Access>xxxxxxxxxx</Access>"                                +ENTER
           cMenu += Space(16)+"<Module>"+cNroModulo+"</Module>"                            +ENTER
           cMenu += Space(12)+"</MenuItem>"                                                +ENTER
         EndIf

        If lMenu
           cBuffer := Substr(cBuffer,1,nPos1+nPos2-2) + cMenu + Substr(cBuffer,nPos1+nPos2-2,nSize)
        Else
           cBuffer := Substr(cBuffer,1,nPos1+nPos2+11) + cMenu + Substr(cBuffer,nPos1+nPos2+11,nSize)
        EndIf
        Fwrite(hFile2,cBuffer,Len(cBuffer))
        cTexto+="Menu: "+cFile+" - '"+cFuncao+"' incluido com sucesso. (I)"+ENTER
     Else
        cTexto+="Menu: "+cFile+" - '"+cFuncao+"' ja foi incluido"+ENTER
     EndIf
     fClose(hFile2)
   Next

End Sequence
Conout(cTexto)
Return cTexto

/*
Funcao   : GetListUpd
Autor    : Daniel Lima
Data     : 29/11/2010
Objetivo :
*/
*========================================================*
Static Function GetListUpd(cNomeUpd)
*========================================================*
Local nCnt, aRet := {}
Local cFunc, cDescFunc
Local cIdUpd
Local dDtExec := ""
Local lOkUpd  := .F.
PRIVATE lTodasFilial:=.F.
PRIVATE aEmpFil:=ACLONE(aEmpFilP)
//For nCnt:=1 To 999 // DESABILITADO (LEONARDO EZ4 03/01/2018)
    cFunc := cNomeUpd//+StrZero(nCnt,3)// DESABILITADO (LEONARDO EZ4 03/01/2018)
    If FindFunction( cFunc )

       InitArray() //Inicializa os Arrays para nao ocorrer erro
       aEmpFil   :=ACLONE(aEmpFilP)//Inicia de novo pq se tiver algum rdmake alterando o proximo rdmake tb ficava alterado
       lMarca    :=.T.
       lTodasFilial:=.F.
       cIdUpd    := Right(cFunc, Len(cFunc) - 2)
       dDtExec   := ""
       lOkUpd    := CheckUpd(cIdUpd, @dDtExec,"2") //A Funcao verifica se o Update foi executado...
       lMarca    := !lOkUpd   //IAC 19/05/2011 se ja foi executado vir desmarcado e vice versa
       cDescFunc := &(cFunc + "(.T.)")//Executa a funcao passando o parametro .T. para pegar a descricao e saber quais as empresas e filiais a serem executads aEmpFil

       ConOut("Funcao  "+cFunc+" encontrada: "+cDescFunc)

       IF lTodasFilial
          Aeval(aEmpFil,{|aElem| aElem[1] := .T.})
       ENDIF

       aAdd(aRet, {lMarca, cIdUpd,cDescFunc, lOkUpd, CTOD(dDtExec) , ACLONE(aEmpFil) , lTodasFilial })
    EndIf
//Next // DESABILITADO (LEONARDO EZ4 03/01/2018) 

If Len(aRet) = 0
   cFunc     := cNomeUpd+StrZero(1,3)
   cIdUpd    := Right(cFunc, Len(cFunc) - 2)
   aAdd(aRet, {.F., cIdUpd,"Funcao: "+cFunc+ " nao encontrada", .F., CTOD(dDtExec) , ACLONE(aEmpFil), lTodasFilial })
   MSGSTOP("Nenhuma Funcao iniciada com os caracteres "+cNomeUpd+" encontrada." )
   lProcessa:=.F.
ENDIF

Return aRet

/*
Funcao  : InitArray
Autor   : Daniel Lima
Data    : 30/11/2010
Objetivo: Inicializar os arrays dos dicionarios
*/
*=========================*
Static Function InitArray()
*=========================*

aSx3   := {}
aSX5   := {}
aSX6   := {}
aSX7   := {}
aSx2   := {}
aSIX   := {}
aEEA   := {}
aCpoDel:= {}
aHelp  := {}
aSxa   := {}
aSxb   := {}
aAltera:= {}
aMenu  := {}

Return Nil

/*
Funcao :
Autor : Daniel Lima
Data :
Alterado : Kanaãm
Data Alt: 05/03/2011
Objetivo :
*/
*======================*
Static Function LogUpd()
*======================*
Local oDlgLog, nCnt, i
Local oTree
Local oFont
Local oPanel
Local lSair := .F.
Local aDescSx := {}

Private nPanelAnt:= 1 //Panel interior para colocar como Hide

Private cTxtShow := ''
Private aDadosBrw := {}
Private aPanel  := {}
Private aBrwLog := {}

//Array dos Logs do Panel
/*
Private aSx2Log   := {}
Private aSx3Log   := {}
Private aSX5Log   := {}
Private aSX6Log   := {}
Private aSX7Log   := {}
Private aSxaLog   := {}
Private aSxbLog   := {}
Private aSIXLog   := {}
Private aRDMLog   := {}
*/
//Define FONT oFontM NAME "Mono AS" Size 6,15 BOLD
//Define FONT oFont NAME "Tahoma" SIZE 0, -10
DEFINE FONT oFont NAME "Courier New" SIZE 0,14
oFontM:=oFont
*
Define MsDialog oDlgLog Title 'LOG das Atualizacoes, consulte tambem o arquivo "UPDATE.LOG - Versao AWF100"' Pixel From 00,00 To 450,700
   *
   oTree           := DbTree():New(005,002,220,115,oDlgLog,,,.T.)
   oTree:lShowHint := .T.
   oTree:oFont     := oFont
   oTree:bChange   := {|| TrocaFolder(oTree) }
   *
   //-- Chama a Rotina de Construcao do Tree
   MsgRun('Aguarde, Montando o Tree com as atualizacoes...',,{|| LoadTreeUpd(oTree, aLogRet, @oDlgLog, @aPanel)} )
   *
   //Criando os Grids
   nArq:=FCreate("UPDATE.LOG")
   For i:=1 To Len(aPanel)
                         //Linha,Coluna,,,Largura,Altura 250,205
       oList1 := TListBox():New(001,001,,,232,194,,aPanel[i],,,,.T.)
       nPosEmp := aScan(aLogRet, {|x| x[1] == aPanel[i]:cName } )
       aTabAux:={}
       FWRITE( nArq , aPanel[i]:cName+"-"+aPanel[i]:cCaption+CHR(13)+CHR(10) )
       For nCnt:=1 To Len(aLogRet[nPosEmp][2])
           If aLogRet[nPosEmp][2][nCnt][1] == aPanel[i]:cCaption
//            aAdd( &("a"+aPanel[i]:cCaption+"Log"), aLogRet[nPosEmp][2][nCnt][2] )
              aAdd( aTabAux, aLogRet[nPosEmp][2][nCnt][2] )
              FWRITE(nArq  , aLogRet[nPosEmp][2][nCnt][2]+CHR(13)+CHR(10) )

           EndIf
       Next
       oList1:SetArray(ACLONE(aTabAux))
       oList1:oFont:= oFontM

   Next
   FCLOSE(nArq)

   *
   //Define SButton From 210,260 Type 13 Action (MsFreeObj(@oPanel, .T.), TMSGrvLog( aLogRet )) Enable Of oDlgLog
   Define SButton From 210,295 Type 2  Action (oDlgLog:End()) Enable Of oDlgLog
   *
Activate MsDialog oDlgLog Centered
*
oPanel := Nil
*
Return Nil


*===========================*
Static Function TrocaFolder(oTree)
*===========================*

aPanel[nPanelAnt]:Hide()

If Val(oTree:GetCargo()) > 0
   aPanel[Val(oTree:GetCargo())]:Show()
   nPanelAnt := Val(oTree:GetCargo())
EndIf

Return

*=========================================================*
Static Function LoadTreeUpd(oTree,aLogUpd, oDlgLog, aPanel)
*=========================================================*
Local i,j
Local aTabTree := {}

For i := 1 To Len(aLogUpd)
    *
    //aLogUpd[n][1] = Empresa
    //aLogUpd[n][2][x][1] = Empresa - Tabela
    *
    oTree:AddTree("Rdm+Emp+Fil "+aLogUpd[i][1],.T.,,,"FOLDER5","FOLDER6",Space(15))
	
	aTabTree := {}
	
	For j:=1 To Len(aLogUpd[i][2])
    	If aScan(aTabTree, aLogUpd[i][2][j][1] ) == 0
    	   aAdd(aTabTree, aLogUpd[i][2][j][1])
    	                         //Linha,Coluna                 //Largura,Altura
    	   aAdd(aPanel, tPanel():New(005,114,"",oDlgLog,,,,,CLR_WHITE,255,205,.T.) )
    	   aPanel[Len(aPanel)]:cCaption := aLogUpd[i][2][j][1] //Caption com o nome da tabela
    	   aPanel[Len(aPanel)]:cName := aLogUpd[i][1]
           aPanel[Len(aPanel)]:Hide()
           cTit:=IF("SX" $ aLogUpd[i][2][j][1] .OR. aLogUpd[i][2][j][1] $ "SIX,EEA",'Arq.: ' + aLogUpd[i][2][j][1],aLogUpd[i][2][j][1])
           oTree:AddTreeItem(cTit,'',, cValToChar( Len(aPanel) ) ) //Chave Posicao no Array do Panel
    	
//  	   TreeDescIt(aPanel[Len(aPanel)], aLogUpd, i, aLogUpd[i][2][j][1] )
    	
        EndIf
    Next
	oTree:EndTree()
Next i

Return

/*
Funcao   : TreeDescIt
Autor    : Daniel Lima
Data     : 30/11/2010
Objetivo :
*/
/*=================================================================*
Static Function TreeDescIt(oPanel, aLogRet, nPosEmp, cTab)
*=================================================================*
Local nCnt

If nPosEmp < 1
   Return Nil
EndIf

For nCnt:=1 To Len(aLogRet[nPosEmp][2])
    If aLogRet[nPosEmp][2][nCnt][1] == cTab
       aAdd(aDadosBrw, {aLogRet[nPosEmp][2][nCnt][2]} )
    EndIf
Next

Return

/*
Autor    : Daniel Lima
Data     : 01/12/2010
Objetivo :
Alteração: Kanaãm
Data	 : 03/03/2011
*/
*============================================================*
Static Function CheckUpd(cIdUpd, cDtExec, cStatus)
*============================================================*
Local lRet := .F.
Local cArquivo	:="\DATA\LOG_UPD"
Local cAlias	:="LOG"
//Local cInd		:="INDID"
Local aStruc := {{"ID"		, "C"		, 10, 0},;
				 {"STAUPD"	, "C"		, 01, 0},;
				 {"DTEXEC"	, "D"		, 08, 0}}
Default cDtExec := ""

#IFDEF TOP
If cStatus = "1" //cDtExec == ""
   cDtExec := DTOC(Date())
EndIf
If !MsFile(cArquivo)//,,"TOPCONN")//!File(cArquivo+".DBF")
   dBCreate(cArquivo,aStruc/*, "TOPCONN"*/)
   If !MsFile(cArquivo/*,,"TOPCONN"*/)
      MSGINFO("Arquivo Log_Upd nao pode ser criado.","Nao existe: "+cArquivo)
      RETURN .F.
   ELSE
      MSGINFO("Arquivo Log_Upd criado COM SUCESSO.")
   ENDIF

   Use (cArquivo) Alias (cAlias) EXCLUSIVE NEW Via "TOPCONN"
// dbUseArea(.T.,"TOPCONN",cArquivo,cAlias,.F.,.F.)
   IF !USED()
      MSGINFO("Arquivo Log_Upd nao pode ser aberto.","Nao existia: "+cArquivo)
      RETURN .F.
   ENDIF
   //(cAlias)->(dBCreateIndex(cInd, "ID", , .F.))
   //(cAlias)->(dBClearIndex())
Else

   IF SELECT(cAlias) = 0
      Use (cArquivo) Alias (cAlias) EXCLUSIVE NEW Via "TOPCONN"
//    dbUseArea(.T.,"TOPCONN",cArquivo,cAlias,.F.,.F.)
      IF !USED()
         MSGINFO("Arquivo LogUpd nao pode ser aberto.","Existe: "+cArquivo)
         RETURN .F.
      ENDIF
   ENDIF
	//(cAlias)->(dBSetIndex(cInd))
	//(cAlias)->(dBSetOrder(1))
   IndRegua("LOG",cArquivo+OrdBagExt(),"ID")
	
	If ((cAlias)->(dbSeek(cIdUpd)))
	   IF cStatus = "1"//Executado
		  (cAlias)->STAUPD := cStatus//"2"
          (cAlias)->DTEXEC := CTOD(cDtExec)
       ELSE
          cDtExec:=DTOC((cAlias)->DTEXEC)
       ENDIF
       IF (cAlias)->STAUPD = "1"//Executado
           lMarca:=.F.
           lRet  := .T.
       ENDIF
	Else
        (cAlias)->(dbAppend())
		(cAlias)->ID := cIdUpd		
		(cAlias)->STAUPD := cStatus//"2"
        (cAlias)->DTEXEC := CTOD(cDtExec)		
		lRet := .F.
	EndIf
//  (cAlias)->(dBClearIndex())
	(cAlias)->(dBCloseArea())
	DBSELECTAREA("SX2")
EndIf
#ENDIF

Return lRet

/*
Autor    : Daniel Lima
Data     : 01/12/2010
Objetivo :
*/
/*============================================*
Static Function ControlXml(aListaUpd, cArqXml)
*============================================*
Local cError   := ""
Local cWarning := ""
Local oXml     := NIL
Local nCnt1
Local lNewNod, nCnt

Default aListaUpd := {}
Default cArqXml   := Upper(GetSrvProfString("STARTPATH","")) + "Upd_Fab.xml"
	
//Gera o Objeto XML
oXml := XmlParserFile( CriaXML(cArqXml), "_", @cError, @cWarning )

For nCnt:= 1 To Len(aListaUpd)

    If oXml == Nil
       oXml := XmlParserFile( (cArqXml), "_", @cError, @cWarning )
    EndIf

    lNewNod := .T.

    If XmlChildCount( oXml:_Update ) > 0 .And. ValType(oXml:_Update:_Upd) == "A"
       For nCnt1:=1 To Len(oXml:_Update:_Upd)
           If oXml:_Update:_Upd[nCnt1]:_Id:Text == aListaUpd[nCnt][2]
              lNewNod := .F.
              Exit
           EndIf
       Next
    EndIf

    If !lNewNod
       LOOP
    EndIf

    XmlNewNode(oXml:_Update,"Upd","Upd","NOD")

    //Cria os dados do Nodo
    XmlNewNode(oXml:_Update:Upd,"Id"      ,"Id"      ,"NOD")
    XmlNewNode(oXml:_Update:Upd,"Desc"    ,"Desc"    ,"NOD")
    XmlNewNode(oXml:_Update:Upd,"Status"  ,"Status"  ,"NOD")
    XmlNewNode(oXml:_Update:Upd,"dataExec","dataExec","NOD")
    oXml:_Update:Upd:Id:Text     := aListaUpd[nCnt][2]
    oXml:_Update:Upd:Desc:Text   := aListaUpd[nCnt][3]

    If aListaUpd[nCnt][1] //Caso tenha sido executado o Update
       oXml:_Update:Upd:Status:Text := "1"
       oXml:_Update:Upd:dataExec:Text := DTOC(Date())
       aListaUpd[nCnt][4] := .T.
    Else
       oXml:_Update:Upd:Status:Text := "2"
    EndIf

    //Por causa do Problema dos nodos, salva e Reabre
    SAVE oXml XMLFILE (cArqXml)

Next

If oXml # Nil
   //Grava o Objeto XML
   SAVE oXml XMLFILE (cArqXml)
EndIf

Return
*/

/*==============================*
Static Function CriaXML(cDirXml)
*==============================*
Local nArq

//Verifica se o arquivo existe, do contrario ele cria
If File(cDirXml)
   Return cDirXml
EndIf

nArq := FCreate(cDirXml)

If nArq = -1
   MsgStop("Não foi possível criar o arquivo de controle do update feche todas planilhas do excel, o Excel e outras sessões do Easy.")
   Return
EndIf

FWrite(nArq,'<?xml version="1.0" encoding="UTF-8"?>' + CHR(13)+CHR(10) )
FWrite(nArq,"<Update>" + CHR(13)+CHR(10) )
FWrite(nArq,"</Update>" + CHR(13)+CHR(10) )

FClose(nArq) //Fecha o arquivo

Return cDirXml
*/

/*
Autor      : Daniel Lima
Data       : 14/12/2010
Objetivo   : Retornar a Conteudo do Usado
Parametros : aDados - Array com os dados para preenchimento do X3_USADO
             aDados[1] == Array com o numero ou o nome do modulo do usado (em branco assume todos os modulos)
             aDados[2] == Logico se .T. Sera editavel na inclusao e bloqueado para edicao na alteracao, se .F. sera editavel sempre.
             lUsado    == Logico se .T. é usado, .F. se nao é não-usado
*/
*======================================*
User Function GetUsado(aDados,lUsado)
*======================================*
Local nCnt
Local cUsado := Space(103)
//Retorna um array com todos os modulos
Local aModulos := RetModName()

Default lUsado := .T.
Default aDados := {{}, .F.}

If !lUsado
   cUsado := Str2Bin(FirstBitOn(cUsado))
   Return cUsado
EndIf

//aDados[1][n] == Modulos selecionados
For nCnt := 1 To Len(aDados[1])
    If ValType(aDados[1][nCnt]) == "N"
       cUsado := Stuff(cUsado, aDados[1][nCnt] ,1,"x")
    Else
       cUsado := Stuff(cUsado, aScan(aModulos,{|x| x[2] == aDados[1][nCnt]}) ,1,"x")
    EndIf
Next

If Len(aDados[1]) == 0 //Se for zero sera utilizado para todos os modulos
   cUsado := Stuff(cUsado,100,1,"x")
EndIf

//aDados[2] == .T. eh chave e .F. nao eh chave
If aDados[2]
   cUsado := Stuff(cUsado,101,1,"x")
EndIf

cUsado := Str2Bin(FirstBitOn(cUsado))

Return cUsado

/*
Autor      : Daniel Lima
Data       : 10/12/2010
Objetivo   : Retornar a Conteudo do Resev.
Parametros : aReserv - Array com os dados para preenchimento do X3_RESERV
             aReserv[1] - Permite Alterar o Nome do Campo
             aReserv[2] - Permite Alterar o Tipo do Campo
             aReserv[3] - Permite Alterar o Tamanho do Campo
             aReserv[4] - Permite Alterar o Decimal do Campo
             aReserv[5] - Permite Alterar a Validacao do Campo
             aReserv[6] - Permite Alterar a Ordem do Campo
             aReserv[7] - Informa se o Campo eh Obrigatorio
             aReserv[8] - Permite Alterar o Uso do Campo
*/
*==============================*
User Function GetReserv(aReserv)
*==============================*
Local nCnt
Local cReserv := Space(9)

For nCnt := 1 To Len(aReserv)
    If nCnt > Len(cReserv)
       EXIT
    EndIf

    If aReserv[nCnt]
       cReserv := Stuff(cReserv,nCnt,1,"x")
    EndIf
Next

cReserv := X3Reserv(cReserv)

Return cReserv

//DRL - Ainda em desenvolvimento
//Data 14/12/2010
*==========================*
User Function NewAtuMenu()
*==========================*
//Local cError := "", cWarning := ""
Local cArqMenu   := Upper(GetSrvProfString("STARTPATH","")) + "Sigaeic.xnu"

Private __lPyme

             //MODULO    ,BASE      ,FUNCAO   ,DESCR.MENU          ,DESCR.ITEM        ,TIPO FUNCAO,TABELAS
//AADD(aMenu,{"sigaeic","EICIP150","EICRelDrx","" ,"Relatorio DEREX","3",{} }) //incluir menu e items

FT_FUse(cArqMenu) // Abre o arquivo

ConOut("Quantidade de linhas do menu: " + Str(Ft_FLastRec(),6) )

Ft_FGoTop() //Posiciona no Topo do Arquivo

While !Ft_FEof() //Verifica se nao esta no final do arquivo
      //ConOut("Ponteiro ["+str(FT_FRECNO(),6)+"] Linha ["+FT_FReadln()+"]")

      Ft_FSkip()
EndDo

FT_FUse() //Fecha o arquivo

Return Nil

*=================================*
USER FUNCTION UPDLOG(cTexto,cChave)
*=================================*
LOCAL nTamMemo:=80,M

FOR M := 1 TO MLCOUNT(cTexto,nTamMemo)
    aAdd(aLogRet[Len(aLogRet)][2], {cChave, ALLTRIM(MEMOLINE(cTexto,nTamMemo,M)) } )
NEXT

RETURN .T.

/*
Função   : retModulo
Autor    : Kanaãm L. R. Rodrigues
Data     : 07/12/11
Objetivo : retorna módulo do arquivo xnu passado como parâmetro
*/
*=================================*
Static Function retModulo(cFile)
*=================================*
Local cModulo  := "0"
Local nIni     := 0
Local nFim     := 0
Local nHandle

//procura módulo do menu e adiciona ao array
nHandle := Ft_FUse(cFile)

//se for -1 ocorreu erro na abertura
If nHandle != -1
   Ft_FGoTop()

   /*
   passa as linhas até achar a primeira ocorrência do <Access> pois a próxima linha é o módulo
   a busca não foi feita por "<Module>" pois a 1ª ocorrência da tag no xnu pode estar vazia
   por ser um cabeçalho do xnu.
   */
   While !("<Access>" $ Ft_FReadLn()) .AND. !Ft_FEof()
      Ft_FSkip()
   EndDo
   //pula a linha para ir para a linha onde está a tag <Module>
   Ft_FSkip()
   cModulo := Ft_FReadLn()
   //verifica se está na tag <Module> para caso o arquivo não possua a tag não realizar nenhuma ação
   If "<Module>" $ cModulo
      nIni := At(">", cModulo)+1
      nFim := Rat("<",cModulo)
      //captura o que está entre as tags <Module> e </Module>
      cModulo := SubStr(cModulo,nIni,(nFim-nIni))
   EndIf
   Ft_Fuse()
EndIf

Return cModulo
//########## Fim do Fonte Carregado em : 07/02/2018 as 16:02:09 #############
