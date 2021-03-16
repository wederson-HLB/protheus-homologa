#include "rwmake.ch"        
#include "colors.ch"        

/*
Funcao      : IU6FAT02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importação de arquivos para o faturamento no sistema    
Autor     	: Wederson L. Santana 
Data     	: 13/07/05
Obs         : Alteração no processo solicitado por Fabio Silva e Fabio Aguilar - chamado 4694 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/

*--------------------------*
  User Function IU6FAT02()        
*--------------------------*      

lCliente   :=.F.
lPedido    :=.F.
lProduto   :=.F.
lBOM       :=.F.
_cCHAVEPRO := SPACE(15)

wdir := 'V:\Team\EBS Shared Prod\receivables\Brasil'//RRP - 15/10/2012 - Alteração do diretório padrão conforme chamado 007670
//wdir := 'V:\TEAM\INTRALOX BRASIL INVOICING\PRYOR'
//wdir := 'D:\Arquivos\Clientes\Intralox\Team\'  //diretorio local para teste

@ 0,0 TO 240,600 DIALOG oDlg TITLE "Recepcao de Arquivos da INTRALOX EUA"

@ 05,10 TO 100,280

@ 15,040 Say "Diretorio dos Arquivos" COLOR CLR_HRED, CLR_WHITE
@ 55,040 CheckBox "Recebe Arquivo de Pedidos"  Var lPedido 
@ 65,040 CheckBox "Recebe Arquivo de Produtos" Var lProduto 
@ 75,040 CheckBox "Recebe Arquivo de Clientes" Var lCliente 
@ 15,100 Get wdir Picture "@!" Size 150,150 //Valid Execute(Existe)

@ 65,250 BmpButton Type 01 Action Processa({|| fOkProc() },"Selecionando Registros...")
@ 80,250 BmpButton Type 02 Action Close(oDlg)

ACTIVATE DIALOG oDlg  CENTERED

Return

//--------------------------------------------------

Static Function fOkProc()

Close(oDlg)
wdir := alltrim(wdir)
                                        
If Select("BOM")>0 
	BOM->(dbCloseArea())
EndIF 

If Select("PEDIDO")>0 
	PEDIDO->(dbCloseArea())
EndIF 

If Select("CLIENTE")>0 
	CLIENTE->(dbCloseArea())
EndIF 

If ! (lPedido .or. lCliente .or. lProduto)
     msgbox("Nenhum arquivo selecionado - processo concluido","Fim de Processamento","ALERT")
     Close(oDlg)
endif

if lPedido 
   If ! file(wdir+"\ORDERS\ORDERS.TXT")
        msgbox("Arquivo "+wdir+"\ORDERS\ORDERS.TXT nao encontrado","Fim de Processamento","ALERT")
        Close(oDlg)
        Return nil
   endif     
   lBOM := .T.   
   If ! file(wdir+"\BOM\BOM.TXT")
        msgbox("Arquivo "+wdir+"\BOM\BOM.TXT nao encontrado","Fim de Processamento","ALERT")
        Close(oDlg)
        Return nil
   Endif     
endif

If lProduto .and. ! (file(wdir+"\PRODUCTS\PRODUCTS.TXT"))
   msgbox("Arquivo "+wdir+"\PRODUCTS\PRODUCTS.TXT nao encontrado","Fim de Processamento","ALERT")
   Close(oDlg)
   Return nil
endif

if lCliente .and. ! file(wdir+"\CUSTOMERS\CUSTOMERS.TXT")
   msgbox("Arquivo "+wdir+"\CUSTOMERS\CUSTOMERS.TXT nao encontrado","Fim de Processamento","ALERT")
//if lCliente .and. ! file(wdir+"CUSTOMERS.TXT")
//   msgbox("Arquivo "+wdir+"CUSTOMERS.TXT nao encontrado","Fim de Processamento","ALERT")
   Close(oDlg)
   Return nil
endif

if lProduto
   xProd := {{"B1_COD"       ,"C",  12, 0},;
   {"B1_UM"        ,"C",   2, 0},;
   {"B1_POSIPI"    ,"C",  10, 0},;
   {"B1_IPI"       ,"N",   5, 2},;
   {"B1_REG"       ,"C",   4, 0},;
   {"B1_NATURE"    ,"C",   6, 0},;
   {"B1_DESCR01"   ,"C", 512, 0},;
   {"B1_DESCR02"   ,"C", 512, 0},;
   {"B1_DESCR03"   ,"C", 512, 0},;
   {"B1_DESCR04"   ,"C", 464, 0}}

   cProduto := CriaTrab(xProd,.T.)
   dbUseArea(.T.,,cProduto,"PRODUTO",.F.,.F.) // PARAMETRO 5-> ACESSO EXCLUSIVO AO ARQUIVO
   dbselectarea('PRODUTO')
   append from (wdir+"\PRODUCTS\PRODUCTS.TXT") SDF
   PRODUTO->(DbGotop())
   ProcRegua(RecCount())
   Do while ! PRODUTO->(eof())
      SB1->(DbSetOrder(1))
      if ! SB1->(dbseek(xfilial("SB2")+PRODUTO->B1_COD,.f.))
         if reclock("SB1",.T.)
            SB1->B1_FILIAL  :=  xfilial("SB1")
            SB1->B1_COD     :=  PRODUTO->B1_COD
            SB1->B1_DESC    :=  left(PRODUTO->B1_DESCR01,40)
            SB1->B1_TIPO    :=  "MP"
            SB1->B1_UM      :=  "PC"
            SB1->B1_LOCPAD  :=  "01"
            SB1->B1_GRUPO   :=  left(PRODUTO->B1_NATURE,1)+substr(PRODUTO->B1_NATURE,4,3)
            SB1->B1_IPI     :=  PRODUTO->B1_IPI 
            //SB1->B1_POSIPI  :=  PRODUTO->B1_POSIPI
            SB1->B1_POSIPI  := ClearVal(PRODUTO->B1_POSIPI)
            SB1->B1_CONTA   :=  ""
            SB1->B1_ORIGEM  :=  ""
            SB1->B1_CLASFIS :=  ""
            SB1->B1_DESCR01 :=  PRODUTO->B1_DESCR01
            SB1->B1_DESCR02 :=  PRODUTO->B1_DESCR02
         endif
      else
         if reclock("SB1",.F.)
            SB1->B1_DESC    :=  left(PRODUTO->B1_DESCR01,40)
            //SB1->B1_POSIPI  :=  PRODUTO->B1_POSIPI
            SB1->B1_POSIPI  := ClearVal(PRODUTO->B1_POSIPI)
            SB1->B1_DESCR01 :=  PRODUTO->B1_DESCR01
            SB1->B1_DESCR02 :=  PRODUTO->B1_DESCR02
         endif
      endif
      IncProc("Produto "+PRODUTO->B1_COD)
      PRODUTO->(dbskip())
   enddo
dbselectarea('PRODUTO')
   DBCLOSEAREA()
endif

if lCliente
   xCliente := {{"A1_COD"    ,"C",    6, 0},;
                {"A1_NOME"   ,"C",   40, 0},;
                {"A1_CGC"    ,"C",   14, 0},;
                {"A1_INSCR"  ,"C",   18, 0},;
                {"A1_END"    ,"C",   40, 0},;                
                {"A1_ENDFAT1","C",   40, 0},;
                {"A1_BAIRRO" ,"C",   40, 0},;
                {"A1_ENDCOB" ,"C",   40, 0},;                
                {"A1_ENDCOB1","C",   40, 0},;
                {"A1_BAICOB" ,"C",   40, 0},;
                {"A1_ENDENT" ,"C",   40, 0},;              
                {"A1_ENDENT1","C",   40, 0},;  
                {"A1_BAIENT" ,"C",  100, 0},; 
                {"A1_CEP"    ,"C",    8, 0},;
                {"A1_CEPCOB" ,"C",    8, 0},;
                {"A1_CEPENT" ,"C",    8, 0},;
                {"A1_MUN"    ,"C",   15, 0},;
                {"A1_CIDCOB" ,"C",   15, 0},;
                {"A1_CIDENT" ,"C",   15, 0},;
                {"A1_EST"    ,"C",    2, 0},;
                {"A1_ESTCOB" ,"C",    2, 0},;
                {"A1_ESTENT" ,"C",    2, 0},;
                {"A1_CONTATO","C",   40, 0},;
                {"A1_TIPO"   ,"C",    1, 0},;
                {"A1_MENS"   ,"C",  100, 0}}


   cCliente := CriaTrab(xCliente,.T.)
   if select("CLIENTE") > 0
	 dbclosearea("CLIENTE")
 endif

   dbUseArea(.T.,,cCliente,"CLIENTE",.F.,.F.) // PARAMETRO 5-> ACESSO EXCLUSIVO AO ARQUIVO
   dbselectarea('CLIENTE')
   append from (wdir+"\CUSTOMERS\CUSTOMERS.TXT") SDF
   //append from (wdir+"CUSTOMERS.TXT") SDF
   dbgotop()
   do while ! CLIENTE->(eof())
      SA1->(DbSetOrder(1))
      if ! SA1->(dbseek(xfilial("SA1")+CLIENTE->A1_COD,.f.))
         if reclock("SA1",.T.)
            SA1->A1_FILIAL   := xfilial("SA1")
            SA1->A1_COD      := CLIENTE->A1_COD
            SA1->A1_LOJA     := "01"
            SA1->A1_RISCO    := "A"
            SA1->A1_NOME     := CLIENTE->A1_NOME
            SA1->A1_NREDUZ   := LEFT(CLIENTE->A1_NOME,20)
            SA1->A1_END      := If(Empty(CLIENTE->A1_END),CLIENTE->A1_ENDENT,CLIENTE->A1_END)
            SA1->A1_ENDCFAT  := If(Empty(CLIENTE->A1_ENDFAT1),CLIENTE->A1_ENDENT1,CLIENTE->A1_ENDFAT1)  
            // SA1->A1_ENDFAT2  := CLIENTE->A1_ENDFAT2
            SA1->A1_MUN      := If(Empty(CLIENTE->A1_MUN),CLIENTE->A1_CIDENT,CLIENTE->A1_MUN)
            SA1->A1_EST      := If(Empty(CLIENTE->A1_EST),CLIENTE->A1_ESTENT,CLIENTE->A1_EST)
            SA1->A1_TIPO     := if(CLIENTE->A1_TIPO='C','F',CLIENTE->A1_TIPO)
            //TLM
            If !Empty(CLIENTE->A1_BAIRRO)
               SA1->A1_BAIRRO   := CLIENTE->A1_BAIRRO
            Elseif !Empty(CLIENTE->A1_BAICOB)
               SA1->A1_BAIRRO   := CLIENTE->A1_BAICOB 
            Elseif !Empty(CLIENTE->A1_BAIENT)   
               SA1->A1_BAIRRO   := CLIENTE->A1_BAIENT    
            EndIf
            SA1->A1_CEP      := If(Empty(CLIENTE->A1_CEP),CLIENTE->A1_CEPENT,CLIENTE->A1_CEP)
            SA1->A1_CONTATO  := CLIENTE->A1_CONTATO
            SA1->A1_ENDCOB   := CLIENTE->A1_ENDCOB
            SA1->A1_ENDCCOB  := CLIENTE->A1_ENDCOB1   
            SA1->A1_ENDENT   := CLIENTE->A1_ENDENT    
            SA1->A1_ENDCENT  := CLIENTE->A1_ENDENT1   
            // SA1->A1_ENDENT2  := CLIENTE->A1_ENDENT2
            SA1->A1_CGC      := CLIENTE->A1_CGC
            SA1->A1_INSCR    := CLIENTE->A1_INSCR
            SA1->A1_BAIRROC  := If(Empty(SA1->A1_BAIRROC),CLIENTE->A1_BAICOB,SA1->A1_BAIRROC)
            SA1->A1_CEPC     := CLIENTE->A1_CEPCOB
            SA1->A1_MUNC     := CLIENTE->A1_CIDCOB
            SA1->A1_ESTC     := CLIENTE->A1_ESTCOB
            SA1->A1_BAIRROE  := If(Empty(SA1->A1_BAIRROE),CLIENTE->A1_BAIENT,SA1->A1_BAIRROE)
            SA1->A1_CEPE     := CLIENTE->A1_CEPENT
            SA1->A1_MUNE     := CLIENTE->A1_CIDENT
            SA1->A1_ESTE     := CLIENTE->A1_ESTENT
         endif
      else
         if reclock("SA1",.F.)
            SA1->A1_NOME     := CLIENTE->A1_NOME
            SA1->A1_NREDUZ   := LEFT(CLIENTE->A1_NOME,20)
            SA1->A1_END      := If(Empty(CLIENTE->A1_END),CLIENTE->A1_ENDENT,CLIENTE->A1_END)
            SA1->A1_ENDCFAT  := If(Empty(CLIENTE->A1_ENDFAT1),CLIENTE->A1_ENDENT1,CLIENTE->A1_ENDFAT1)   
            // SA1->A1_ENDFAT2  := CLIENTE->A1_ENDFAT2
            SA1->A1_MUN      := If(Empty(CLIENTE->A1_MUN),CLIENTE->A1_CIDENT,CLIENTE->A1_MUN)
            SA1->A1_EST      := If(Empty(CLIENTE->A1_EST),CLIENTE->A1_ESTENT,CLIENTE->A1_EST)
            SA1->A1_TIPO     := if(CLIENTE->A1_TIPO='C','F',CLIENTE->A1_TIPO)
            //TLM
            If Empty(SA1->A1_BAIRRO) 
               If !Empty(CLIENTE->A1_BAIRRO)
                  SA1->A1_BAIRRO   := CLIENTE->A1_BAIRRO
               Elseif !Empty(CLIENTE->A1_BAICOB)
                  SA1->A1_BAIRRO   := CLIENTE->A1_BAICOB 
               Elseif !Empty(CLIENTE->A1_BAIENT)   
                  SA1->A1_BAIRRO   := CLIENTE->A1_BAIENT    
               EndIf
            EndIf
            //SA1->A1_BAIRRO   := If(Empty(SA1->A1_BAIRRO),CLIENTE->A1_BAIRRO,SA1->A1_BAIRRO)
            SA1->A1_CEP      := If(Empty(CLIENTE->A1_CEP),CLIENTE->A1_CEPENT,CLIENTE->A1_CEP)
            SA1->A1_CONTATO  := CLIENTE->A1_CONTATO
            SA1->A1_ENDCOB   := CLIENTE->A1_ENDCOB
            SA1->A1_ENDCCOB  := CLIENTE->A1_ENDCOB1 
            // SA1->A1_ENDCOB2  := CLIENTE->A1_ENDCOB2
            SA1->A1_ENDENT   := CLIENTE->A1_ENDENT
            SA1->A1_ENDCENT  := CLIENTE->A1_ENDENT1  
            // SA1->A1_ENDENT2  := CLIENTE->A1_ENDENT2
            SA1->A1_CGC      := CLIENTE->A1_CGC
            SA1->A1_INSCR    := CLIENTE->A1_INSCR
            SA1->A1_BAIRROC  := CLIENTE->A1_BAICOB
            SA1->A1_CEPC     := CLIENTE->A1_CEPCOB
            SA1->A1_MUNC     := CLIENTE->A1_CIDCOB
            SA1->A1_ESTC     := CLIENTE->A1_ESTCOB
            SA1->A1_BAIRROE  := CLIENTE->A1_BAIENT
            SA1->A1_CEPE     := CLIENTE->A1_CEPENT
            SA1->A1_MUNE     := CLIENTE->A1_CIDENT
            SA1->A1_ESTE     := CLIENTE->A1_ESTENT
         endif
      endif

      IncProc("Clientes "+CLIENTE->A1_NOME)
      CLIENTE->(dbskip())
   enddo
   DBSELECTAREA("CLIENTE")
   DBCLOSEAREA()
Endif

If lPedido
   xPedido:={{"C5_CLIENTE","C",  6,0},;
             {"C5_COBRANC","C",  6,0},;
             {"C5_RAZAOSO","C", 40,0},;
             {"C5_PEDCLIE","C", 20,0},;
             {"C6_DTFAT"  ,"C",  8,0},;
             {"C5_CONDPAG","C",  3,0},;
             {"C5_PEDIDO" ,"C",  6,0},;
             {"C5_DTPEDID","C",  8,0},;
             {"C6_SEQUENC","C",  3,0},;
             {"C6_PRODUTO","C", 12,0},;
             {"C6_QTDE"   ,"N", 10,2},;
             {"C6_UNITARI","N", 14,2},;
             {"C6_ICMS"   ,"N",  5,2},;
             {"C6_IPI"    ,"N",  5,2},;
             {"C6_VOLUMES","N",  5,0},;
             {"C6_PESOLIQ","N",  9,2},;
             {"C6_PESOBRT","N",  9,2},;
             {"C6_DESCR01","C",512,0},;
             {"C6_DESCR02","C",512,0},;
             {"C6_DESCR03","C",512,0},;
             {"C6_DESCR04","C",464,0}}

   If lBOM
      xBOM :={{"PEDIDO","C",6,0},;
              {"SEQ"       ,"C",    3, 0},;
              {"PRODUTO"   ,"C",   12, 0},;
              {"QUANT"     ,"N",    9, 2}}
      cBOM := CriaTrab(xBOM,.T.)
      dbUseArea(.T.,,cBOM,"BOM",.F.,.F.) // PARAMETRO 5-> ACESSO EXCLUSIVO AO ARQUIVO
      dbselectarea('BOM')        
      index on BOM->PEDIDO+BOM->SEQ to cBOM
      append from (wdir+"\BOM\BOM.TXT") SDF
   Endif

   cPedido := CriaTrab(xPedido,.T.)
   dbUseArea(.T.,,cPedido,"PEDIDO",.F.,.F.) // PARAMETRO 5-> ACESSO EXCLUSIVO AO ARQUIVO
   Index On PEDIDO->C5_PEDIDO TO cPEDIDO
   Append From (wdir+"\ORDERS\ORDERS.TXT") SDF

   DbSelectArea("PEDIDO")
   DbGotop()
   ProcRegua(RecCount())
   Do While.Not.Eof().And.!Empty(PEDIDO->C5_PEDIDO) 

      wpesoliq := 0
      wpesobrt := 0
      SC5->(DbSetOrder(1))
      If! SC5->(DbSeek(xFilial("SC5")+PEDIDO->C5_PEDIDO)) 
          SA1->(DbSetOrder(1))
          SA1->(DbSeek(xFilial("SA1")+PEDIDO->C5_CLIENTE))
          RecLock("SC5",.T.)
          Replace SC5->C5_FILIAL    With xFilial("SC5")
          Replace SC5->C5_NUM       With PEDIDO->C5_PEDIDO
          Replace SC5->C5_TIPO      With "N"
          Replace SC5->C5_TIPOCLI   With SA1->A1_TIPO
          Replace SC5->C5_CLIENTE   With PEDIDO->C5_CLIENTE
          Replace SC5->C5_LOJAENT   With '01'
          Replace SC5->C5_LOJACLI   With '01'
          Replace SC5->C5_TABELA    With '1'
          Replace SC5->C5_MOEDA     With 1
          Replace SC5->C5_EMISSAO   With ctod(PEDIDO->C5_DTPEDID)
          Replace SC5->C5_CONDPAG   With PEDIDO->C5_CONDPAG
          //Replace SC5->C5_MENPAD    With '001'
          Replace SC5->C5_FATURA    With PEDIDO->C5_COBRANC   
          SC5->(dbunlock())
      Endif
      i        :=1
      _Pedido  :=PEDIDO->C5_PEDIDO
      While _Pedido == PEDIDO->C5_PEDIDO.And.!Empty(PEDIDO->C5_PEDIDO)
            SC6->(DbSetOrder(1))
            If! SC6->(DbSeek(xFilial("SC6")+PEDIDO->C5_PEDIDO+StrZero(i,2)))
                IncProc("PEDIDOS "+PEDIDO->C5_PEDIDO)
                wProduto := If(Empty(PEDIDO->C6_PRODUTO),'99999',PEDIDO->C6_PRODUTO)
                SB1->(DbSetOrder(1))
                If SB1->(DbSeek(xFilial("SB1")+wProduto))                              
	                If SB1->B1_IPI <> PEDIDO->C6_IPI
	                   RecLock("SB1",.F.)
                      Replace B1_IPI With PEDIDO->C6_IPI
                      MsUnlock()
	                Endif   
		        Endif 
	           RecLock("SC6",.T.)
              Replace SC6->C6_FILIAL   With xFilial("SC6")
              Replace SC6->C6_ITEM     With StrZero(i++,2)
              //Replace SC6->C6_ITEM     With SOMA1(i)
              Replace SC6->C6_PRODUTO  With wProduto
              Replace SC6->C6_QTDVEN   With PEDIDO->C6_QTDE
              Replace SC6->C6_UNSVEN   With PEDIDO->C6_QTDE
              Replace SC6->C6_COMIS5   With PEDIDO->C6_VOLUMES  
              Replace SC6->C6_UM       With SB1->B1_UM
              Replace SC6->C6_SEGUM    With SB1->B1_SEGUM
              Replace SC6->C6_PRCVEN   With PEDIDO->C6_UNITARI
              Replace SC6->C6_PRUNIT   With PEDIDO->C6_UNITARI
              Replace SC6->C6_VALOR    With PEDIDO->C6_UNITARI * PEDIDO->C6_QTDE
              Replace SC6->C6_CLI      With PEDIDO->C5_CLIENTE
              Replace SC6->C6_LOJA     With '01'
              Replace SC6->C6_NUM      With PEDIDO->C5_PEDIDO
              Replace SC6->C6_LOCAL    With SB1->B1_LOCPAD
              Replace SC6->C6_ENTREG   With ctod(PEDIDO->C6_DTFAT)
              Replace SC6->C6_PEDCLI   With PEDIDO->C5_PEDCLIE
              Replace SC6->C6_DESCR01  With PEDIDO->C6_DESCR01 
              Replace SC6->C6_DESCR02  With PEDIDO->C6_DESCR02 
              Replace SC6->C6_DESCR03  With PEDIDO->C6_DESCR03 
              Replace SC6->C6_DESCR04  With PEDIDO->C6_DESCR04 
              Replace SC6->C6_LINE     With PEDIDO->C6_SEQUENC  
              
              /*
              If (cQuant2:=At("Pelo Total De ",PEDIDO->C6_DESCR01)) > 0
                                        
                 cCampo :=Substr(PEDIDO->C6_DESCR01,cQuant2+=14,4)
                 cQuant2:= Val(cCampo)
                 Replace SC6->C6_UNSVEN With cQuant2
              
              EndIf  */
              
              If Left(PEDIDO->C6_PRODUTO,5) <> '88888'
                   _cTes   :=fDefTes()                
                   If Empty(PEDIDO->C6_PRODUTO) 
                      Replace SC6->C6_TES With _cTes
                      Replace SC6->C6_CF  With If(SA1->A1_EST$'SP','5101','6101')  
                   Else
          	          Replace SC6->C6_TES With _cTes
                      Replace SC6->C6_CF  With If(SA1->A1_EST$'SP','5102','6102')  
                   Endif   
                   Replace SC6->C6_DESCRI With SB1->B1_DESC
              Else                                              
                   Replace SC6->C6_TES    With fDefTes() //---Poderia ter amarrada a TES ao produto , mas...
                   Replace SC6->C6_CF     With If(SA1->A1_EST='SP','5949','6949')
                   Replace SC6->C6_DESCRI With Left(PEDIDO->C6_DESCR01,30)
              Endif 
              SC6->(dbunlock())
       
              wpesoliq += PEDIDO->C6_PESOLIQ
              wpesobrt += PEDIDO->C6_PESOBRT

              If wProduto = '99999' .Or. wProduto = '9999TDBELT'  //TLM
        	          SB1->(dbseek(xFilial("SB1")+BOM->PRODUTO,.F.))
			          BOM->(dbseek(PEDIDO->C5_PEDIDO,.F.))
			          SA1->(dbseek(xFilial("SA1")+PEDIDO->C5_CLIENTE,.F.))
	                If fGeraMv()	    // Gera os componentes da OP pai
   	 	             fGeraOp()     // Gera a OP pai
			          Endif   
              Endif
            Endif        
            DbSelectArea("PEDIDO")
            DbSkip()
      End
      If SC5->(DbSeek(xFilial("SC5")+_Pedido))
          Reclock("SC5")
          Replace SC5->C5_PESOL   With wpesoliq
          Replace SC5->C5_PBRUTO  With wpesobrt
          SC5->(DbUnlock())
      Endif   
   EndDo
Endif

If Select("BOM")>0 
	BOM->(dbCloseArea())  
	If File("cBom.CDX")
	   FErase("cBom.CDX")	 //indice gerado
	Endif   
Endif

If Select("PEDIDO")>0 
	PEDIDO->(dbCloseArea())
EndIf 

If Select("CLIENTE")>0 
	CLIENTE->(dbCloseArea())
EndIf 

Return Nil

//----------------------------------------------------Gera a OP pai

Static Function fGeraOp()

   _cCHAVEPRO := "99999" + SPACE(10)

   SB2->(DbSetOrder(1))
   SB2->(DbSeek(xFILIAL("SB2")+_cCHAVEPRO+"01"))  
   
   SZA->(DbSetOrder(1))
   If!  DbSeek(xFILIAL("SZA")+PEDIDO->C5_PEDIDO +StrZero(Val(PEDIDO->C6_SEQUENC),2)+PEDIDO->C6_SEQUENC)
	    RecLock("SZA",.T.)		
        SZA->ZA_FILIAL  := xFILIAL("SZA")
        SZA->ZA_NUM     := PEDIDO->C5_PEDIDO
        SZA->ZA_ITEM    := StrZero(Val(PEDIDO->C6_SEQUENC),2)
        SZA->ZA_SEQUEN  := PEDIDO->C6_SEQUENC
        //SZA->ZA_PRODUTO := "99999"    -- TLM
        SZA->ZA_PRODUTO := wProduto
        SZA->ZA_LOCAL   := SB1->B1_LOCPAD
        SZA->ZA_QUANT   := PEDIDO->C6_QTDE
        SZA->ZA_UM      := "PC"
        SZA->ZA_DATPRI  := ctod(PEDIDO->C6_DTFAT)
		  SZA->ZA_DATPRF  := ctod(PEDIDO->C6_DTFAT)
		  SZA->ZA_EMISSAO := ctod(PEDIDO->C6_DTFAT)
		  SZA->ZA_PRIOR   := "500"
		  SZA->ZA_QUJE    := PEDIDO->C6_QTDE
		  SZA->ZA_DATRF   := ctod(PEDIDO->C6_DTFAT)
	     MsUnlock()	
		   
		  Reclock("SC6",.F.)  
		  SC6->C6_ITEMOP:= StrZero(Val(PEDIDO->C6_SEQUENC),2)
		  SC6->C6_OP   := "S"
		  SC6->C6_NUMOP:= PEDIDO->C5_PEDIDO
		  MsUnlock()	
		   
		  RecLock("SZB",.T.)		
		  ZB_FILIAL := xFILIAL("SZB")
		  ZB_P_TM   := "100"
	 	  //ZB_COD  := "99999"                       
		  ZB_COD    := wProduto
		  ZB_UM     := SB1->B1_UM
		  ZB_QUANT  := PEDIDO->C6_QTDE
		  ZB_CF     := "PR0"
		  ZB_CONTA  := SB1->B1_CONTA
		  ZB_OP     := PEDIDO->C5_PEDIDO +StrZero(Val(PEDIDO->C6_SEQUENC),2)+PEDIDO->C6_SEQUENC
		  ZB_LOCAL  := SB1->B1_LOCPAD
		  ZB_DOC    := PEDIDO->C5_PEDIDO
		  ZB_EMISSAO:= ctod(PEDIDO->C6_DTFAT)
		  ZB_GRUPO  := SB1->B1_GRUPO
		  ZB_TIPO   := SB1->B1_TIPO
		  ZB_PARCTOT:= "T"
		  MsUnlock()	
	Endif
Return

//-------------------------------------Cria movimento com os componentes da OP pai

Static Function fGeraMv()
   _nTotal :=0
   _cMotivo:=""
   lRet    :=.T.
   DbSelectArea("BOM")     
   DbGotop()
   If DbSeek(PEDIDO->C5_PEDIDO+PEDIDO->C6_SEQUENC)
      Do While.Not.Eof().And.PEDIDO->C5_PEDIDO+PEDIDO->C6_SEQUENC == BOM->PEDIDO+BOM->SEQ
	     SB2->(DbSetOrder(1))
         SB2->(DbSeek(xFilial("SB2")+BOM->PRODUTO+Space(03)+"01"))
  	     SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+BOM->PRODUTO+Space(03)+"01"))
         If BOM->QUANT > 0                                   
            RecLock("SZB",.T.)		
		      ZB_FILIAL := xFILIAL("SZB")
		      ZB_P_TM   := "501"
		      ZB_COD    := BOM->PRODUTO                       
		      ZB_UM     := SB1->B1_UM
		      ZB_QUANT  := BOM->QUANT
		      ZB_CF     := "RE6"
		      ZB_CONTA  := SB1->B1_CONTA
		      ZB_OP     := PEDIDO->C5_PEDIDO +StrZero(Val(PEDIDO->C6_SEQUENC),2)+PEDIDO->C6_SEQUENC
		      ZB_LOCAL  := SB1->B1_LOCPAD
		      ZB_DOC    := PEDIDO->C5_PEDIDO
		      ZB_EMISSAO:= ctod(PEDIDO->C6_DTFAT)
		      ZB_GRUPO  := SB1->B1_GRUPO
		      ZB_TIPO   := SB1->B1_TIPO
		      ZB_PARCTOT:= ""
		      _cMotivo  := "0"
		      MsUnlock()	
		   Else   
            _cMotivo  := "1"
		   Endif
		   DbSelectArea("BOM")
		   DbSkip()
      EndDo
   Else
      _cMotivo :="2"
      lRet:=.F.
   Endif          
   If _cMotivo $ "1/2"
      U_YYSMTP1(PEDIDO->C5_PEDIDO,_cMotivo)
   Endif   
Return(lRet)

//-----------------------------------------------------------------//
//--Wederson L. Santana - Pryor Tecnology - 14/07/05               //
//-----------------------------------------------------------------//
//--Cria Parametros utilizados pela rotina se não existir          //
//-----------------------------------------------------------------//
//--29/08/05 --> Carrega as TES conforme condições infomadas por   //
//--pela Roseli/Rosana.                                                   //
//-----------------------------------------------------------------//

Static Function fDefTes()
Local _cRet:=""

DbSelectArea("SX6")
//--------------------------------------------------ESTADOS
If! DbSeek("  MV_FATUF01")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATUF01"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Estados Red. BC 73,34%" 
	X6_CONTEUD  := "RS/SC/PR/SP/MG/RJ"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATUF02")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATUF02"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Estados Red. BC 73,43%" 
	X6_CONTEUD  := "ES/BA/GO/MS/MT/TO/AC/AM/PA/RR/RN/SE/CE/RO/PB/AL/AP/PI/PE/MA"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------C1P01
If! DbSeek("  MV_FATES01")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES01"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS com IPI" 
	X6_DESC1    := "/Red BC 73,34%)"
	X6_CONTEUD  := "85A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES02")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES02"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS sem IPI" 
   X6_DESC1    := "/Red BC 73,34%)"
	X6_CONTEUD  := "70A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES03")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES03"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS com IPI" 
	X6_DESC1    := "/Red BC 73,43%)"
	X6_CONTEUD  := "93F"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
If! DbSeek("  MV_FATES04")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES04"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-C1P01(Importado/ICMS sem IPI" 
	X6_DESC1    := "/Red BC 73,43%)"
	X6_CONTEUD  := "71A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------BELT
If! DbSeek("  MV_FATES05")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES05"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-BELT(Importado,ICMS com IPI) " 
	X6_CONTEUD  := "74A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES06")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES06"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-BELT(Importado,ICMS sem IPI)" 
	X6_CONTEUD  := "73A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------99999
If! DbSeek("  MV_FATES07")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES07"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-99999(Importado,ICMS com IPI) " 
	X6_CONTEUD  := "51A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES08")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES08"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-99999(Importado,ICMS sem IPI)" 
	X6_CONTEUD  := "50A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------Nacional
If! DbSeek("  MV_FATES09")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES09"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Nacional,ICMS com IPI " 
	X6_CONTEUD  := "51A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES10")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES10"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Nacional,ICMS sem IPI" 
	X6_CONTEUD  := "50A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf

//--------------------------------------------------Importado
If! DbSeek("  MV_FATES11")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES11"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Importado,ICMS com IPI " 
	X6_CONTEUD  := "74A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf                   
If! DbSeek("  MV_FATES12")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES12"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Especifico Intralox-Importado,ICMS sem IPI" 
	X6_CONTEUD  := "73A"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
//--------------------------------------------------------------------------------Serviços
If! DbSeek("  MV_FATES13")
	RecLock("SX6",.T.)
	X6_VAR		:= "MV_FATES13"
	X6_TIPO		:= "C"
	X6_DESCRIC	:= "Faturamento servicos" 
	X6_CONTEUD  := "91X"
	X6_PROPRI	:= "U"
	MsUnLock()
EndIf
//--------------------------------------------------------------------------------Demais Produtos
If SubStr(SB1->B1_ORIGEM,1,1)$ "0"     //-----------------------------------------Nacional
   _cRet:=If(AllTrim(SA1->A1_TIPO)$"R",GetMv("MV_FATES10"),GetMv("MV_FATES09"))
Endif   
If SubStr(SB1->B1_ORIGEM,1,1)$ "1" //-----------------------------------------Importado  
   _cRet:=If(AllTrim(SA1->A1_TIPO)$"R",GetMv("MV_FATES12"),GetMv("MV_FATES11"))
Endif

If "CIP01" $ SB1->B1_COD
   cParam1 :=GetMv("MV_FATUF01")     //Estados do Sul/Sudeste,exceto ES.
   cParam2 :=GetMv("MV_FATUF02")     //Estados do Norte/Nordeste e ES.
   If AllTrim(SA1->A1_EST) $ cParam1 
      _cRet := GetMv("MV_FATES01")   //ICMS com IPI na base.
      If AllTrim(SA1->A1_TIPO) $ "R" 
         _cRet :=GetMv("MV_FATES02") //ICMS sem IPI na base.
      EndIf
   Endif   
   If AllTrim(SA1->A1_EST) $ cParam2 
      _cRet := GetMv("MV_FATES03")   //ICMS com IPI na base.       
      If AllTrim(SA1->A1_TIPO) $ "R" 
         _cRet :=GetMv("MV_FATES04") //ICMS sem IPI na base.
      EndIf
   Endif
Endif   
If "BELT" $ SB1->B1_COD
       _cRet := GetMv("MV_FATES05")   //ICMS com IPI na base.
       If AllTrim(SA1->A1_TIPO) $ "R" 
          _cRet :=GetMv("MV_FATES06") //ICMS sem IPI na base.
       EndIf
Endif       
If "99999" $ SB1->B1_COD
       _cRet := GetMv("MV_FATES07")   //ICMS com IPI na base.
       If AllTrim(SA1->A1_TIPO) $ "R" 
          _cRet :=GetMv("MV_FATES08") //ICMS sem IPI na base.
       EndIf
Endif
If "88888" $ SB1->B1_COD
   _cRet := GetMv("MV_FATES13")
Endif
Return(_cRet)             

//--------------------------------------------------------//
//--Ponto de entrada na exclusão do pedido                //
//--------------------------------------------------------//
//--Wederson L. Santana                                   //
//--------------------------------------------------------//

User Function MTA410E()

If cEmpAnt $ "U6"
   _cAlias :=Alias()
   _nOrder :=DbSetOrder()
   _nRecno :=Recno()

   SZA->(DbSetOrder(1))
   If SZA->(DbSeek(xFilial("SZA")+SC6->C6_NUMOP+SC6->C6_ITEMOP))
      Reclock("SZA",.F.)
      Delete
      MsUnlock()

      SZB->(DbSetOrder(1))
      If SZB->(DbSeek(xFilial("SZB")+SC6->C6_NUMOP+SC6->C6_ITEMOP+StrZero(Val(SC6->C6_ITEMOP),3)))
         cNumOp:=xFilial("SZB")+SC6->C6_NUMOP+SC6->C6_ITEMOP+StrZero(Val(SC6->C6_ITEMOP),3)
         While cNumOp == SZB->ZB_FILIAL+SZB->ZB_OP
               Reclock("SZB",.F.)
               Delete
               MsUnlock()
               DbSkip()
         End      
      Endif
   Endif
   DbSelectArea(_cAlias)
   DbSetOrder(_nOrder)
   DbGoto(_nRecno)
Endif
Return(.T.)           


// TLM 06/07/2010
*----------------------------------*
  Static Function ClearVal(cCampo)
*----------------------------------*      
   
   If valtype(cCampo) =="N" 
      cCampo:=Alltrim(Str(cCampo))  
   EndIf  

   nPos:=At(".",Alltrim(cCampo))   
   While 0 < nPos                          
      cCampo:=Stuff(cCampo,nPos,1,"")
      nPos:=At(".",Alltrim(cCampo))   
   EndDo        

Return (cCampo)                   